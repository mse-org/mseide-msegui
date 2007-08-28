unit msepascalscript;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,uPSComponent,msestrings,mseforms,mseclasses;
 
type 
 tmsepsscript = class(tpsscript)
  public
   function compilermessagetext: msestring;
   function compilermessagear: msestringarty;
 end;

 tformscript = class(tmsepsscript)
  public
   constructor create(aowner: tcomponent);
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
 finally
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
 fscript:= tformscript.create(nil);
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

constructor tformscript.create(aowner: tcomponent);
begin
 inherited;
 compileroptions:= [icAllowNoBegin,icAllowNoEnd,icBooleanShortCircuit];
end;

end.
