{ MSEgui Copyright (c) 2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefoldedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msedataedits,msegraphics,mseguiglob,msegrids,mseevent,msegui;

type
 tfoldedit = class(tstringedit)
  private
   foncellevent: celleventty;
   fonclientmouseevent: mouseeventty;
  protected
   procedure drawcell(const canvas: tcanvas); override;
   procedure clientmouseevent(var ainfo: mouseeventinfoty); override;
  published
   property oncellevent: celleventty read foncellevent write foncellevent;
   property onclientmouseevent: mouseeventty read fonclientmouseevent 
                           write fonclientmouseevent;
 end;
 
implementation
uses
 msegraphutils,msestockobjects;

type
 tdatacols1 = class(tdatacols);
  
{ tfoldedit }

procedure tfoldedit.drawcell(const canvas: tcanvas);
var
 isvisible1,haschildren1,isopen1: boolean;
 foldlevel1: foldlevelty;
 int1: integer;
 glyph1: stockglyphty;
 rect1: rectty;
begin
 inherited;
 with cellinfoty(canvas.drawinfopo^) do begin
  with tdatacols1(fgridintf.getcol.grid.datacols).frowstate do begin
   getfoldstate(cell.row,isvisible1,foldlevel1,haschildren1,isopen1);
   int1:= 5*foldlevel1;
   glyph1:= stg_none;
   if haschildren1 then begin
    if isopen1 then begin
     glyph1:= stg_boxexpanded;
    end
    else begin
     glyph1:= stg_boxexpand;
    end;
   end;
   rect1:= rect;
   inc(rect1.x,int1);
   canvas.drawline(makepoint(int1,0),makepoint(int1,rect1.cy),cl_red);
   if glyph1 <> stg_none then begin
    stockobjects.glyphs.paint(canvas,ord(glyph1),rect1,[al_ycentered],cl_glyph);
   end;
  end;
 end;
end;

procedure tfoldedit.clientmouseevent(var ainfo: mouseeventinfoty);
begin
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,ainfo);
 end;
 if not (es_processed in ainfo.eventstate) then begin
  
  if not (es_processed in ainfo.eventstate) then begin
   inherited;
  end;
 end;
end;

end.
