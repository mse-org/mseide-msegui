unit msepascalscript;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,uPSComponent,uPSCompiler,uPSRuntime,msestrings,mseforms,mseclasses,
 typinfo,mselist,uPSPreProcessor;

type 

 tpasc = class(tpsscript)
  public
   function compilermessagetext: msestring;
   function compilermessagear: msestringarty;
 end;

 ttestobj = class(tcomponent)
  private
   fprop: string;
  public
   constructor create;
   procedure testproc;
   procedure testproc1; virtual;
   property prop: string read fprop write fprop;
 end;
 
 tformscript = class(tpasc)
  private
   fowner: tmsecomponent;
  protected
   procedure docompimport(Sender: TObject; x: TPSPascalCompiler);
   procedure docompile(sender: tpsscript);
   procedure doexecimport(Sender: TObject; se: TPSExec;
                                      x: TPSRuntimeClassImporter);
   procedure doexecute(sender: tpsscript);
  public
   constructor create(aowner: tmsecomponent);
 end;
 
 methpropinfoty = record
  propinfo: ppropinfo;
  instance: tobject;
  name: string;
 end;
 pmethpropinfoty = ^methpropinfoty;
 
 tmethproplist = class(trecordlist)
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   procedure dosetmethodprop(Reader: TReader; Instance: TPersistent;
               PropInfo: PPropInfo; const TheMethodName: string;
               var Handled: boolean);
  public
   constructor create;
   procedure additem(const apropinfo: ppropinfo; const ainstance: tobject;
                          const aname: string);
   procedure linkmethods(const ascript: tpasc);
 end;

 tpascform = class(tmseform)
  private
   fscript: tformscript;
   fmethlist: tmethproplist;
   function getps_script: tstrings;
   procedure setps_script(const avalue: tstrings);
   function getps_plugins: tpsplugins;
   procedure setps_plugins(const avalue: tpsplugins);
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure readstate(reader: treader); override;
   procedure doafterload; override;
   function isscript: boolean;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   destructor destroy; override;
   property script: tformscript read fscript;
  published
   property ps_script: tstrings read getps_script write setps_script;
   property ps_plugins: tpsplugins read getps_plugins write setps_plugins;
 end;
 
 pascformclassty = class of tpascform;
 
function createpascform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function loadpascform(const filename: filenamety): tpascform;

implementation
uses
 msestream,msegui,msesys,sysutils,msetmpmodules;
type
 tmsecomponent1 = class(tmsecomponent);
 
function loadpascform(const filename: filenamety): tpascform;
var
 stream1: ttextstream;
 stream2: tmemorystream;
 reader1: treader;
begin
 stream1:= nil;
 stream2:= nil;
 try
//  result:= tpascform.create(application,false);
  stream1:= ttextstream.create(filename,fm_read);
  stream2:= tmemorystream.create;
  objecttexttobinary(stream1,stream2);
  stream2.position:= 0;
  result:= tpascform(createtmpmodule('tpascform',stream2));
 finally
  stream1.free;
  stream2.free;
 end;
end;
{ 
function loadpascform(const filename: filenamety): tpascform;
var
 methlist: tmethproplist;
 stream1: ttextstream;
 stream2: tmemorystream;
 reader1: treader;
begin
 methlist:= tmethproplist.create;
 stream1:= nil;
 stream2:= nil;
 reader1:= nil;
 beginloadtmpmodule;
 try
  try
   result:= tpascform.create(application,false);
   stream1:= ttextstream.create(filename,fm_read);
   stream2:= tmemorystream.create;
   objecttexttobinary(stream1,stream2);
   stream2.position:= 0;
   reader1:= treader.create(stream2,4048);
   reader1.onsetmethodproperty:= @methlist.dosetmethodprop;
   reader1.readrootcomponent(result);
   if not result.fscript.compile then begin
    raise exception.create('Error compiling script of '+result.name+':'+lineend+
             result.fscript.compilermessagetext);
   end;
   methlist.linkmethods(result.fscript);
   addtmpmodule(result);
  except
   result.free;
   raise;
  end;
 finally
  endloadtmpmodule;
  reader1.free;
  stream1.free;
  stream2.free;
  methlist.free;
 end;
end;
} 
function createpascform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
begin
 result:= pascformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tmethproplist }

constructor tmethproplist.create;
begin
 inherited create(sizeof(methpropinfoty),[rels_needsfinalize,rels_needscopy]);
end;

procedure tmethproplist.additem(const apropinfo: ppropinfo;
               const ainstance: tobject; const aname: string);
var
 info: methpropinfoty;
begin
 with info do begin
  propinfo:= apropinfo;
  instance:= ainstance;
  name:= aname;
 end;  
 add(info);
end;

procedure tmethproplist.dosetmethodprop(Reader: TReader; Instance: TPersistent;
               PropInfo: PPropInfo; const TheMethodName: string;
               var Handled: boolean);
begin
 additem(propinfo,instance,themethodname);
 handled:= true;
end;

procedure tmethproplist.finalizerecord(var item);
begin
 finalize(methpropinfoty(item));
end;

procedure tmethproplist.copyrecord(var item);
begin
 with methpropinfoty(item) do begin
  stringaddref(name);  
 end;
end;

procedure tmethproplist.linkmethods(const ascript: tpasc);
var
 int1: integer;
 meth1: tmethod;
begin
 for int1:= 0 to count - 1 do begin
  with pmethpropinfoty(fdata)[int1] do begin
   meth1:= ascript.getprocmethod(struppercase(name));
   setmethodprop(instance,propinfo,meth1);
  end;
 end;
end;

{ tpasc }

function tpasc.compilermessagetext: msestring;
var
 int1: integer;
begin
 result:= '';
 for int1:= 0 to compilermessagecount - 1 do begin
  result:= result+compilermessages[int1].messagetostring + lineend;
 end;
 if result <> '' then begin
  setlength(result,length(result)-length(lineend));
 end;
end;

function tpasc.compilermessagear: msestringarty;
var
 int1: integer;
begin
 result:= nil;
 setlength(result,compilermessagecount);
 for int1:= 0 to compilermessagecount - 1 do begin
  result[int1]:= compilermessages[int1].messagetostring;
 end;
end;

{ tpascform }

constructor tpascform.create(aowner: tcomponent; load: boolean);
begin
 fscript:= tformscript.create(self);
 fscript.setsubcomponent(true);
 inherited;
end;

destructor tpascform.destroy;
begin
 fmethlist.free;
 fscript.free;
 inherited;
end;

function tpascform.isscript: boolean;
begin
 result:= (cs_tmpmodule in fmsecomponentstate) and 
                            not (csdesigning in componentstate);
end;

procedure tpascform.readstate(reader: treader);
begin
 if isscript then begin
  freeandnil(fmethlist);
  fmethlist:= tmethproplist.create;
//  try
   reader.onsetmethodproperty:= @fmethlist.dosetmethodprop;
   inherited;
   {
   if not fscript.compile then begin
    raise exception.create('Error compiling script of '+name+':'+lineend+
             fscript.compilermessagetext);
   end;
   methlist.linkmethods(fscript);
  finally
   methlist.free;
  end;
  }
 end
 else begin
  inherited;
 end;
end;

procedure tpascform.doafterload;
begin
 if isscript then begin
  try
   if not fscript.compile then begin
    raise exception.create('Error compiling script of '+name+':'+lineend+
             fscript.compilermessagetext);
   end;
   fmethlist.linkmethods(fscript);
  finally
   freeandnil(fmethlist);
  end;
 end;
 inherited;
end;

class function tpascform.getmoduleclassname: string;
begin
 result:= 'tpascform';
end;

class function tpascform.hasresource: boolean;
begin
 result:= self <> tpascform;
end;

function tpascform.getps_script: tstrings;
begin
 result:= fscript.script;
end;

procedure tpascform.setps_script(const avalue: tstrings);
begin
 fscript.script.assign(avalue); 
end;

function tpascform.getps_plugins: tpsplugins;
begin
 result:= fscript.plugins;
end;

procedure tpascform.setps_plugins(const avalue: tpsplugins);
begin
 fscript.plugins.assign(avalue);
end;

{ tformscript }

constructor tformscript.create(aowner: tmsecomponent);
begin
 fowner:= aowner;
 inherited create(nil);
 compileroptions:= [icAllowNoBegin,icAllowNoEnd,icBooleanShortCircuit];
 oncompimport:= @docompimport;
 oncompile:= @docompile;
 onexecimport:= @doexecimport;
 onexecute:= @doexecute;
end;

procedure tformscript.docompimport(Sender: TObject; x: TPSPascalCompiler);
var
 int1: integer;
begin
 with fowner do begin
  with x.addclassn(x.findclass('TCOMPONENT'),'ttestobj') do begin
   registermethod('procedure testproc;');
   registermethod('procedure testproc1;');
   registermethod('constructor create;');
  end;
  for int1:= 0 to componentcount - 1 do begin
   with components[int1] do begin
    if x.findclass(classname) = nil then begin
     x.addclassn(x.findclass('TCOMPONENT'),classname);
    end;
   end;
  end;
 end;
end;

procedure tformscript.docompile(sender: tpsscript);
var
 int1: integer;
begin
 with fowner do begin
  for int1:= 0 to componentcount - 1 do begin
   with components[int1] do begin
    sender.addregisteredvariable(name,classname);
   end;
  end;
 end;
end;

procedure tformscript.doexecimport(Sender: TObject; se: TPSExec;
               x: TPSRuntimeClassImporter);
begin
 with x.add(ttestobj) do begin
  registermethod(@ttestobj.testproc,'TESTPROC');
  registervirtualmethod(@ttestobj.testproc1,'TESTPROC1');
  registerconstructor(@ttestobj.create,'CREATE');
 end;
end;

procedure tformscript.doexecute(sender: tpsscript);
var
 int1: integer;
 comp1: tcomponent;
begin
 with sender do begin
  setvartoinstance('SELF',owner);
  with fowner do begin
   for int1:= 0 to componentcount - 1 do begin
    comp1:= components[int1];
    setvartoinstance(struppercase(comp1.name),comp1);
   end;
  end;
 end;
end;

{ ttestobj }

procedure ttestobj.testproc;
begin
 msegui.beep;
end;

procedure ttestobj.testproc1;
begin
 msegui.beep;
end;

constructor ttestobj.create;
begin
 inherited create(nil);
 name:= 'qwertz';
end;

end.
