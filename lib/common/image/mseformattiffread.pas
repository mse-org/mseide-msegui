{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformattiffread;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 tifflabel = 'tif';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpreadtiff,msegraphicstream;

type
 tmsefpreadertiff = class(tfpreadertiff)
  protected
//   function  InternalCheck(Str: TStream): boolean; override;
 end;

function readgraphic(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
begin
 if dest is tbitmap then begin
  result:= readfpgraphic(source,tmsefpreadertiff,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  result:= false;
 end;
end;

{ tmsefpreadertiff }
{
function tmsefpreadertiff.InternalCheck(Str: TStream): boolean;
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
procedure registerformat;
begin
 registergraphicformat(tifflabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         'TIFF_Image',['*.tif','*.tiff']);
end;

initialization
 registerformat();
end.
