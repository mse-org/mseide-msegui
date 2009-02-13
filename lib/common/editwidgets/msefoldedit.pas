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
 classes,msedataedits,msegraphics,mseguiglob,msegrids,mseevent,msegui,
     msegraphutils;

type
 tfoldedit = class(tstringedit)
  private
   foncellevent: celleventty;
   fonclientmouseevent: mouseeventty;
   flevelstep: integer;
   procedure setlevelstep(const avalue: integer);
  protected
   procedure drawcell(const canvas: tcanvas); override;
   procedure clientmouseevent(var ainfo: mouseeventinfoty); override;
   procedure docellevent(const ownedcol: boolean;
                                         var info: celleventinfoty); override;
   procedure updatecellzone(const alevel: integer; const apos: pointty;
                                         var azone: cellzonety); virtual;
  public
   constructor create(aowner: tcomponent); override;
  published
   property oncellevent: celleventty read foncellevent write foncellevent;
   property onclientmouseevent: mouseeventty read fonclientmouseevent 
                           write fonclientmouseevent;
   property levelstep: integer read flevelstep write setlevelstep default 10;
 end;
 
implementation
uses
 msestockobjects;

type
 tdatacols1 = class(tdatacols);
  
{ tfoldedit }

constructor tfoldedit.create(aowner: tcomponent);
begin
 flevelstep:= 10;
 inherited;
end;

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
   int1:= flevelstep*foldlevel1;
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
var
 isvisible1,haschildren1,isopen1: boolean;
 foldlevel1: foldlevelty;
 zone1: cellzonety; 
 row1: integer;
begin
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,ainfo);
 end;
 if not (es_processed in ainfo.eventstate) and (fgridintf <> nil) then begin
  with ainfo do begin
   if isleftbuttondown(ainfo,[]) then begin
    with fgridintf.getcol.grid,tdatacols1(datacols).frowstate do begin
     row1:= row;
     getfoldstate(row1,isvisible1,foldlevel1,haschildren1,isopen1);
     zone1:= cz_default;
     updatecellzone(foldlevel1,ainfo.pos,zone1);
     if zone1 = cz_default then begin
      if isopen1 then begin
       hidechildren(row1);
      end
      else begin
       showchildren(row1);
      end;
     end;
    end;
   end;  
  end;
  if not (es_processed in ainfo.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tfoldedit.docellevent(const ownedcol: boolean;
               var info: celleventinfoty);
begin
 with info do begin
  if ownedcol then begin
   if (eventkind in mousecellevents) and (info.cell.row >= 0) then begin
    updatecellzone(fgridintf.getcol.grid.rowfoldlevel[info.cell.row],
                    info.mouseeventinfopo^.pos,info.zone);
   end
   else begin
    if eventkind = cek_exit then begin
//     filtertext:= '';
    end;
   end;
  end;
{
  if (info.eventkind = cek_enter) or 
                    (info.eventkind = cek_exit) then begin
   if oe_locate in foptionsedit then begin
    editing:= false;
   end;
   factiverow:= info.newcell.row;
   if fvalue <> nil then begin
    if info.eventkind = cek_enter then begin
     updateitemvalues(info.newcell.row,1);
    end
    else begin
     updateitemvalues(info.cellbefore.row,1);
    end;
   end;
  end;
}
 end;
 if canevent(tmethod(foncellevent)) then begin
  foncellevent(self,info);
 end;
 inherited;
end;

procedure tfoldedit.updatecellzone(const alevel: integer; const apos: pointty;
                                                         var azone: cellzonety);
var
 int1: integer;
begin
 int1:= (alevel+1) * flevelstep;
 if apos.x >= int1 then begin
  azone:= cz_caption;
 end;
end;

procedure tfoldedit.setlevelstep(const avalue: integer);
begin
 if avalue <> flevelstep then begin
  flevelstep:= avalue;
  formatchanged;
 end;
end;

end.
