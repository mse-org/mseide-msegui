{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatpnmread;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}


interface
const
 pnmlabel = 'pnm';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpreadpnm,msegraphicstream;

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

function readgraphic(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
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

procedure registerformat;
begin
 registergraphicformat(pnmlabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         'PNM_Image',['*.pnm','*.pgm','*.pbm']);
end;

initialization
 registerformat();
end.
