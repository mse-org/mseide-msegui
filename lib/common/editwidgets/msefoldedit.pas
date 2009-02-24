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
 classes,mseclasses,msedataedits,msegraphics,mseguiglob,msegrids,mseevent,msegui,
     msegraphutils,msebitmap,mseeditglob,msedatalist,msewidgetgrid,mseedit,
     msedrawtext;

const
 defaultfoldedittextflags = defaulttextflags + [tf_clipo];
 defaultfoldedittextflagsactive = defaulttextflagsactive + [tf_clipo];
type
 tgridmsestringintdatalist = class(tmsestringintdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tfoldedit = class(tstringedit)
  private
   foncellevent: celleventty;
   fonclientmouseevent: mouseeventty;
   flevelstep: integer;
   fimagesize: sizety;
   fimnr_base: integer;
   fimnr_expanded: integer;
   fimnr_selected: integer;
   fimnr_readonly: integer;
   fimnr_subitems: integer;
   fimagelist: timagelist;
   fdefault: msestringintty;
   
   procedure setlevelstep(const avalue: integer);
   procedure setimagesize(const avalue: sizety);
   procedure setimagewidth(const avalue: integer);
   procedure setimageheight(const avalue: integer);
   procedure setimnr_base(const avalue: integer);
   procedure setimnr_expanded(const avalue: integer);
   procedure setimnr_selected(const avalue: integer);
   procedure setimnr_readonly(const avalue: integer);
   procedure setimnr_subitems(const avalue: integer);
   procedure setimagelist(const avalue: timagelist);
  protected
   procedure updatelayout;
   procedure drawimage(const acanvas: tcanvas;
                       const ainfo: prowfoldinfoty; var arect: rectty;
                       const isselected,isreadonly: boolean;
                       const datapo: pmsestringintty);
   procedure drawcell(const canvas: tcanvas); override;
   procedure clientmouseevent(var ainfo: mouseeventinfoty); override;
   procedure docellevent(const ownedcol: boolean;
                                         var info: celleventinfoty); override;
   procedure updatecellzone(const alevel: integer; const apos: pointty;
                                         var azone: cellzonety); virtual;
   procedure dopaint(const acanvas: tcanvas); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdefaultvalue: pointer; override;
//   function getinnerframe: framety; override;
   function imageshift(arow: integer): integer;
                    //-1 -> focused row
   procedure setupeditor; override;
  public
   constructor create(aowner: tcomponent); override;
   property imagesize: sizety read fimagesize write setimagesize;
  published
   property oncellevent: celleventty read foncellevent write foncellevent;
   property onclientmouseevent: mouseeventty read fonclientmouseevent 
                           write fonclientmouseevent;
   property levelstep: integer read flevelstep write setlevelstep default 10;
   property imnr_base: integer read fimnr_base write setimnr_base default 0;
   property imnr_expanded: integer read fimnr_expanded write setimnr_expanded default 0;
   property imnr_selected: integer read fimnr_selected write setimnr_selected default 0;
   property imnr_readonly: integer read fimnr_readonly write setimnr_readonly default 0;
   property imnr_subitems: integer read fimnr_subitems write setimnr_subitems default 0;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagewidth: integer read fimagesize.cx write setimagewidth default 0;
   property imageheight: integer read fimagesize.cy write setimageheight default 0;
   property textflags default defaultfoldedittextflags;
   property textflagsactive default defaultfoldedittextflagsactive;
 end;
 
implementation
uses
 msestockobjects;

type
 tdatacols1 = class(tdatacols);
 twidgetcol1 = class(twidgetcol);

{ tgridmsestringintdatalist }

constructor tgridmsestringintdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
end;

function tgridmsestringintdatalist.getdefault: pointer;
begin
 result:= twidgetcol1(fowner).fintf.getdefaultvalue;
end;

  
{ tfoldedit }

constructor tfoldedit.create(aowner: tcomponent);
begin
 flevelstep:= 10;
 fdefault.int:= -1;
 inherited;
 textflags:=  defaultfoldedittextflags;
 textflagsactive:=  defaultfoldedittextflagsactive;
end;

procedure tfoldedit.drawimage(const acanvas: tcanvas; 
                  const ainfo: prowfoldinfoty; var arect: rectty;
                  const isselected,isreadonly: boolean;
                  const datapo: pmsestringintty);
const
 boxsize = 11;
var
 levelshift: integer;
 int1,int2,int3,int4: integer;
 glyph1: stockglyphty;
 lines: segmentarty;
 ycenter,xbefore: integer;
begin
 if ainfo <> nil then begin
  with ainfo^ do begin
   xbefore:= arect.x;
   ycenter:= arect.cy div 2;
   levelshift:= flevelstep*foldlevel;
   glyph1:= stg_none;
   if haschildren then begin
    if isopen then begin
     glyph1:= stg_boxexpanded;
    end
    else begin
     glyph1:= stg_boxexpand;
    end;
   end;
   inc(arect.x,levelshift);
   int3:= flevelstep + flevelstep div 2;
   int4:= 0;
   setlength(lines,foldlevel+2);
   for int2:= 0 to high(nolines) - 1 do begin
    with lines[int4] do begin
     if not nolines[int2] then begin
      a.x:= int3;
      b.x:= int3;
      a.y:= 0;
      b.y:= arect.cy;
      inc(int4);
     end;
    end;
    inc(int3,flevelstep);
   end;
   if foldlevel > 0 then begin
    with lines[int4] do begin
     a.x:= int3;
     b.x:= int3;
     a.y:= 0;
     if (glyph1 = stg_none) then begin
      if nolines[high(nolines)] then begin
       b.y:= ycenter;
      end
      else begin
       b.y:= arect.cy;
      end;
      inc(int4);
      with lines[int4] do begin
       a.x:= int3;
       b.x:= int3 + flevelstep div 2;
       a.y:= ycenter;
       b.y:= ycenter;
      end;
     end
     else begin
      b.y:= ycenter - boxsize div 2;
      if not nolines[high(nolines)] then begin
       inc(int4);
       with lines[int4] do begin
        a.x:= int3;
        b.x:= int3;
        a.y:= ycenter + boxsize div 2;
        b.y:= arect.cy;
       end;
      end;
     end;  
     inc(int4);
    end;
   end;
   if int4 > 0 then begin
    setlength(lines,int4);
    drawdottedlinesegments(acanvas,lines,cl_shadow);
   end;
   if glyph1 <> stg_none then begin
    int1:= arect.cx;
    arect.cx:= flevelstep;
    stockobjects.glyphs.paint(acanvas,ord(glyph1),arect,
                                [al_ycentered,al_xcentered],cl_glyph);
    arect.cx:= int1;
   end;
   inc(arect.x,flevelstep);
   if fimagelist <> nil then begin
    if (datapo <> nil) and (datapo^.int <> -1) then begin
     int1:= datapo^.int;
    end
    else begin
     int1:= fimnr_base { fimagenr};
     if isopen then begin
      inc(int1,fimnr_expanded);
     end;
     if isselected then begin
      inc(int1,fimnr_selected);
     end;
     if isreadonly then begin
      inc(int1,fimnr_readonly);
     end;
     if isselected then begin
      inc(int1,fimnr_selected);
     end;
     if haschildren then begin
      inc(int1,fimnr_subitems);
     end;
    end;
    if int1 >= 0 then begin
     fimagelist.paint(acanvas,int1,arect,[al_ycentered]);
    end;
    inc(arect.x,fimagelist.width);
   end;
   arect.cx:= arect.cx - (arect.x-xbefore);
  end;
 end;
end;

procedure tfoldedit.drawcell(const canvas: tcanvas);
var
 rect1: rectty;
 int1,int2,int3: integer;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  rect1:= rect;
  drawimage(canvas,foldinfo,rect,selected,readonly,pmsestringintty(datapo));
  int1:= innerrect.x;
  int2:= innerrect.cx;
  try
   int3:= rect1.x - rect.x;         //apply adjustments to innerrect
   innerrect.x:= innerrect.x + int3;
   innerrect.cx:= innerrect.cx - int3;
   if innerrect.cx < 0 then begin
    innerrect.cx:= 0;
   end;
   inherited;
  finally
   innerrect.x:= int1;
   innerrect.cx:= int2;
   rect:= rect1;
  end;
 end;
end;

procedure tfoldedit.dopaint(const acanvas: tcanvas);
var
 rect1: rectty;
 int1: integer;
begin
 if (fgridintf <> nil) then begin
  acanvas.rootbrushorigin:= fgridintf.getbrushorigin;
  rect1:= clientrect;
  with fgridintf.getcol,grid do begin
   int1:= row;
   if int1 >= 0 then begin //not csdesigning
    drawimage(acanvas,rowfoldinfo,rect1,
          datacols.selected[makegridcoord(index,int1)],
          rowreadonlystate[int1],nil);
   end
   else begin
    drawimage(acanvas,rowfoldinfo,rect1,false,false,nil);
   end;
  end;
 end;
 inherited;
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
     if row1 >= 0 then begin //no csdesigning
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
  updatelayout;
 end;
end;

procedure tfoldedit.setimageheight(const avalue: integer);
begin
 if fimagesize.cy <> avalue then begin
  fimagesize.cy := avalue;
  updatelayout;
//  invalidate;
 end;
end;

procedure tfoldedit.setimagewidth(const avalue: integer);
begin
 if fimagesize.cx <> avalue then begin
  fimagesize.cx := avalue;
  updatelayout;
//  invalidate;
 end;
end;

procedure tfoldedit.setimagesize(const avalue: sizety);
begin
 if (fimagesize.cx <> avalue.cx) or (fimagesize.cy <> avalue.cy) then begin
  fimagesize:= avalue;
  updatelayout;
 end;
end;

procedure tfoldedit.setimagelist(const avalue: timagelist);
begin
 if fimagelist <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  if (fimagelist <> nil) and (csdesigning in componentstate) then begin
   fimagesize:= fimagelist.size;
  end;
  updatelayout;
//  invalidate;
 end;
end;

procedure tfoldedit.setimnr_base(const avalue: integer);
begin
 if fimnr_base <> avalue then begin
  fimnr_base:= avalue;
  invalidate;
 end;
end;

procedure tfoldedit.setimnr_expanded(const avalue: integer);
begin
 if fimnr_expanded <> avalue then begin
  fimnr_expanded:= avalue;
  invalidate;
 end;
end;

procedure tfoldedit.setimnr_selected(const avalue: integer);
begin
 if fimnr_selected <> avalue then begin
  fimnr_selected:= avalue;
  invalidate;
 end;
end;

procedure tfoldedit.setimnr_readonly(const avalue: integer);
begin
 if fimnr_readonly <> avalue then begin
  fimnr_readonly:= avalue;
  invalidate;
 end;
end;

procedure tfoldedit.setimnr_subitems(const avalue: integer);
begin
 if fimnr_subitems <> avalue then begin
  fimnr_subitems := avalue;
  invalidate;
 end;
end;

procedure tfoldedit.updatelayout;
begin
 formatchanged;
end;

function tfoldedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridmsestringintdatalist.create(sender);
end;

function tfoldedit.getdefaultvalue: pointer;
begin
 result:= @fdefault;
end;

function tfoldedit.imageshift(arow: integer): integer;
begin
 result:= 0;
 if fimagelist <> nil then begin
  inc(result,fimagelist.width);
 end;
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   if arow < 0 then begin
    arow:= row;
   end;
   if arow >= 0 then begin
    inc(result,(rowfoldlevel[arow]+1)*flevelstep);
   end;
  end;
 end;
end;

procedure tfoldedit.setupeditor;
var
 int1: integer;
 rect1,rect2: rectty;
begin
 inherited;
 int1:= imageshift(-1);
 if int1 > 0 then begin
  rect1:= feditor.cliprect;
  rect2:= feditor.destrect;
  inc(rect1.x,int1);
  dec(rect1.cx,int1);
  if rect1.cx < 0 then begin
   rect1.cx:= 0;
  end;
  inc(rect2.x,int1);
  dec(rect2.cx,int1);
  if rect2.cx < 0 then begin
   rect2.cx:= 0;
  end;
  feditor.updatepos(rect2,rect1);
 end;
end;
{
function tfoldedit.getinnerframe: framety;
begin
 result:= inherited getinnerframe;
// result.left:= result.left + imageshift(-1);
end;
}
end.
