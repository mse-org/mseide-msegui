unit mseformatxpm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 xpmlabel = 'xpm';
 
implementation
uses
 classes,msegraphics,msebitmap,fpreadxpm,msegraphicstream,msestockobjects,
 fpimage;
 
type
 tmsefpreaderxpm = class(tfpreaderxpm)
  protected
   procedure InternalRead  (Str:TStream; Img:TFPCustomImage); override;
 end;
 
function readgraphic(const source: tstream; const index: integer; 
                const dest: tobject): boolean;
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

initialization
 registergraphicformat(xpmlabel,{$ifdef FPC}@{$endif}readgraphic,nil,
         stockobjects.captions[sc_XPM_Image],['*.xpm']);
end.
