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

 tscriptform = class(tmseform)
  private
   fscript: tmsepsscript;
   procedure setscript(const avalue: tmsepsscript);
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   destructor destroy; override;
  published
   property script: tmsepsscript read fscript write setscript;
 end;
 
 scriptformclassty = class of tscriptform;
 
function createscriptform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;

implementation
type
 tmsecomponent1 = class(tmsecomponent);
 
function createscriptform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
begin
 result:= scriptformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
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
 fscript:= tmsepsscript.create(nil);
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

procedure tscriptform.setscript(const avalue: tmsepsscript);
begin
 fscript.assign(avalue);
end;

end.
