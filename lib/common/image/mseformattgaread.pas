unit mseformattgaread;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 tgalabel = 'tga';
 
implementation
uses
 classes,msegraphics,msebitmap,fpreadtga,msegraphicstream,msestockobjects;
 
type
 tmsefpreadertarga = class(tfpreadertarga)
  protected
   function  InternalCheck(Str: TStream): boolean; override;
 end;
 
function readgraphic(const source: tstream; const index: integer; 
                const dest: tobject): boolean;
begin
 if dest is tbitmap then begin
  result:= readfpgraphic(source,tmsefpreadertarga,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  result:= false;
 end;
end;

{ tmsefpreadertarga }

function tmsefpreadertarga.InternalCheck(Str: TStream): boolean;
var
 int1: integer;
 ar1: array[0..2] of byte;
begin
 result:= false;
 int1:= str.position;
 try
  str.readbuffer(ar1,sizeof(ar1));
  if ((ar1[1] = $00) or (ar1[1] = $01)) and 
      (ar1[2] > 0) and (ar1[2] <= 11) then begin
   result:= true;
  end;
 finally
  str.position:= int1;
 end;
end;

initialization
 registergraphicformat(tgalabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         stockobjects.captions[sc_TARGA_Image],['*.tga']);
end.
