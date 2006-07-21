unit mseformatjpg;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
const
 jpglabel = 'jpg';
 
implementation
uses
 classes,msegraphics,msebitmap,fpreadjpeg,msegraphicstream,msestockobjects,
 msestream;
 
type
 tmsefpreaderjpeg = class(tfpreaderjpeg)
  protected
   function  InternalCheck(Str: TStream): boolean; override;
 end;
 
function readgraphic(const source: tstream; const index: integer; 
                const dest: tobject): boolean;
begin
 if dest is tbitmap then begin
  result:= readfpgraphic(source,tmsefpreaderjpeg,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  result:= false;
 end;
end;

{ tmsefpreaderjpeg }

function tmsefpreaderjpeg.InternalCheck(Str: TStream): boolean;
var
 int1: integer;
 ar1: array[0..1] of byte;
begin
 result:= false;
 int1:= str.position;
 try
  str.readbuffer(ar1,sizeof(ar1));
  if (ar1[0] = $ff) and (ar1[1] = $d8) then begin
   result:= true;
  end;
 finally
  str.position:= int1;
 end;
end;

initialization
 registergraphicformat(jpglabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         stockobjects.captions[sc_JPEG_Image],['*.jpg','*.jpeg']);

end.
