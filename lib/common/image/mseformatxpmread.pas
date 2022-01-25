{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatxpmread;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 xpmlabel = 'xpm';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpreadxpm,msegraphicstream,msefpimage;

type
 tmsefpreaderxpm = class(tfpreaderxpm)
  protected
   procedure InternalRead  (Str: TStream; Img:TFPCustomImage); override;
 end;

function readgraphic(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
begin
 if dest is tbitmap then begin
  result:= readfpgraphic(source,tmsefpreaderxpm,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  result:= false;
 end;
end;

{ tmsefpreadertaxpm }

procedure tmsefpreaderxpm.InternalRead(Str: TStream; Img: TFPCustomImage);
begin
 img.usepalette:= true;
 inherited;
end;

procedure registerformat;
begin
 registergraphicformat(xpmlabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         'XPM_Image',['*.xpm']);
end;

initialization
 registerformat();
end.
