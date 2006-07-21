unit mseformatpnm;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
const
 pnmlabel = 'pnm';
 
implementation
uses
 classes,msegraphics,msebitmap,fpreadpnm,msegraphicstream,msestockobjects;

type
 tmsefpreaderpnm = class(tfpreaderpnm)
  protected
   function  InternalCheck(Str: TStream): boolean; override;
 end;
 
{ tmsefpreaderpnm }

function tmsefpreaderpnm.InternalCheck(Str: TStream): boolean;
var
 int1: integer;
 ar1: array[0..1] of char;
begin
 result:= false;
 int1:= str.position;
 try
  str.readbuffer(ar1,sizeof(ar1));
  if (ar1[0] = 'P') and (ar1[1] >= '1') and (ar1[1] <= '6') then begin
   result:= true;
  end;
 finally
  str.position:= int1;
 end;
end;
 
function readgraphic(const source: tstream; const index: integer; 
                const dest: tobject): boolean;
begin
 if dest is tbitmap then begin
  result:= readfpgraphic(source,tmsefpreaderpnm,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  result:= false;
 end;
end;

initialization
 registergraphicformat(pnmlabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         stockobjects.captions[sc_PNM_Image],['*.pnm','*.pgm','*.pbm']);
end.
