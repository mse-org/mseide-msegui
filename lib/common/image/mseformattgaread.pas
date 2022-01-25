{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformattgaread;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
const
 tgalabel = 'tga';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpreadtga,msegraphicstream;

type
 tmsefpreadertarga = class(tfpreadertarga)
  protected
   function  InternalCheck(Str: TStream): boolean; override;
 end;

function readgraphic(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
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

procedure registerformat;
begin
 registergraphicformat(tgalabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         'TARGA_Image',['*.tga']);
end;

initialization
 registerformat();
end.
