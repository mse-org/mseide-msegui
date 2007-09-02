unit msepascalscript;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,uPSComponent,uPSCompiler,uPSRuntime,msestrings,mseforms,mseclasses;
 
type 
 tmsepsscript = class(tpsscript)
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
 
 tformscript = class(tmsepsscript)
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
 
 tscriptform = class(tmseform)
  private
   fscript: tformscript;
   function getps_script: tstrings;
   procedure setps_script(const avalue: tstrings);
   function getps_plugins: tpsplugins;
   procedure setps_plugins(const avalue: tpsplugins);
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   destructor destroy; override;
   property script: tformscript read fscript;
  published
   property ps_script: tstrings read getps_script write setps_script;
   property ps_plugins: tpsplugins read getps_plugins write setps_plugins;
 end;
 
 scriptformclassty = class of tscriptform;
 
function createscriptform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function loadscriptform(const filename: filenamety): tscriptform;

implementation
uses
 typinfo,mselist,msestream,msegui,msesys,sysutils;
type
 tmsecomponent1 = class(tmsecomponent);
 
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
   procedure linkmethods(const ascript: tmsepsscript);
 end;

var
 fscriptmodules: tmodulelist;

function findscriptmodulebyname(const name: string): tcomponent;
begin
 result:= fscriptmodules.findmodulebyname(name);
end;

function loadscriptform(const filename: filenamety): tscriptform;
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
 lockfindglobalcomponent;
 fscriptmodules.unlock;
 begingloballoading;
 try
  try
   result:= tscriptform.create(application,false);
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
   fscriptmodules.add(result);
   globalfixupreferences;
   notifygloballoading;
   result.doafterload;
  except
   result.free;
   raise;
  end;
 finally
  endgloballoading;
  fscriptmodules.lock;
  unlockfindglobalcomponent;
  reader1.free;
  stream1.free;
  stream2.free;
  methlist.free;
 end;
end;
 
function createscriptform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
begin
 result:= scriptformclassty(aclass).create(nil,false);
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

procedure tmethproplist.linkmethods(const ascript: tmsepsscript);
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

{ tmsepsscript }

function tmsepsscript.compilermessagetext: msestring;
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

function tmsepsscript.compilermessagear: msestringarty;
var
 int1: integer;
begin
 result:= nil;
 setlength(result,compilermessagecount);
 for int1:= 0 to compilermessagecount - 1 do begin
  result[int1]:= compilermessages[int1].messagetostring;
 end;
end;

{ tscriptform }

constructor tscriptform.create(aowner: tcomponent; load: boolean);
begin
 fscript:= tformscript.create(self);
 fscript.setsubcomponent(true);
 inherited;
end;

destructor tscriptform.destroy;
begin
 fscript.free;
 inherited;
end;

class function tscriptform.getmoduleclassname: string;
begin
 result:= 'tscriptform';
end;

function tscriptform.getps_script: tstrings;
begin
 result:= fscript.script;
end;

procedure tscriptform.setps_script(const avalue: tstrings);
begin
 fscript.script.assign(avalue); 
end;

function tscriptform.getps_plugins: tpsplugins;
begin
 result:= fscript.plugins;
end;

procedure tscriptform.setps_plugins(const avalue: tpsplugins);
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

initialization
 fscriptmodules:= tmodulelist.create(false);
 fscriptmodules.lock;
 registerfindglobalcomponentproc({$ifdef FPC}@{$endif}findscriptmodulebyname);
finalization
 freeandnil(fscriptmodules);
end.
