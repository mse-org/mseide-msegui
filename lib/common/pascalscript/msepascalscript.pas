unit msepascalscript;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 uPSComponent,msestrings;
 
type 
 tmsepsscript = class(tpsscript)
  public
   function compilermessagetext: msestring;
   function compilermessagear: msestringarty;
 end;

implementation

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

end.
