unit mseformatpng;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
const
 pnglabel = 'png';
 
implementation
uses
 classes,msegraphics,msebitmap,fpreadpng,msegraphicstream,msestockobjects;
 
type
 tmsefpreaderpng = class(tfpreaderpng)
  protected
//   function  InternalCheck(Str: TStream): boolean; override;
 end;
 
function readgraphic(const source: tstream; const index: integer; 
                const dest: tobject): boolean;
begin
 if dest is tbitmap then begin
  result:= readfpgraphic(source,tmsefpreaderpng,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  result:= false;
 end;
end;

{ tmsefpreaderpng }
{
function tmsefpreaderpng.InternalCheck(Str: TStream): boolean;
var
 int1: integer;
 ar1: array[0..7] of char;
begin
 result:= false;
 int1:= str.position;
 try
  str.readbuffer(ar1,sizeof(ar1));
  if ar1 = #137#80#78#71#13#10#26#10 then begin
   result:= true;
  end;
 finally
  str.position:= int1;
 end;
end;
}
initialization
 registergraphicformat(pnglabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         stockobjects.captions[sc_PNG_Image],['*.png']);
end.
