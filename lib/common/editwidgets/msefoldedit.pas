{ MSEgui Copyright (c) 2009-2013 by Martin Schreiber

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
 classes,mclasses,mseclasses,msedataedits,msegraphics,mseguiglob,msegrids,
 mseevent,msegui,
 msegraphutils,msebitmap,mseeditglob,msedatalist,msewidgetgrid,mseedit,
 msedrawtext,msetypes,msestat,msepointer,msemenus,msestrings,msegridsglob;

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

 foldeditoptionty = (feo_menulevel,feo_menuissum);
 foldeditoptionsty = set of foldeditoptionty;
 
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
   
   fimnr_value: integer;
   fimnr_valuebase: integer;
   fimnr_valueexpanded: integer;
   fimnr_valueselected: integer;
   fimnr_valuereadonly: integer;
   fimnr_valuesubitems: integer;
   fimagelistvalue: timagelist;
   foptions: foldeditoptionsty;
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
   function getgridimnr(index: integer): integer;
   procedure setgridimnr(index: integer; const avalue: integer);
   function getgridimnrs: integerarty;
   procedure setgridimnrs(const avalue: integerarty);
   procedure setimnr_value(const avalue: integer);
   procedure setimnr_valuebase(const avalue: integer);
   procedure setimnr_valueexpanded(const avalue: integer);
   procedure setimnr_valueselected(const avalue: integer);
   procedure setimnr_valuereadonly(const avalue: integer);
   procedure setimnr_valuesubitems(const avalue: integer);
   procedure setimagelistvalue(const avalue: timagelist);
   procedure dolevelup(const sender: tobject);
   procedure doleveldown(const sender: tobject);
   procedure doissum(const sender: tobject);
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
   procedure updatecellzone(const row: integer; const apos: pointty;
                                           var result: cellzonety); override;
   procedure updatelevelcellzone(const alevel: integer; const apos: pointty;
                                         var azone: cellzonety); virtual;
   function getcellcursor(const arow: integer;
                      const acellzone: cellzonety): cursorshapety; override;
   procedure doonpaint(const acanvas: tcanvas); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdefaultvalue: pointer; override;
   function imageshift(arow: integer): integer;
                    //-1 -> focused row
   procedure setupeditor; override;
   procedure gridtovalue(arow: integer); override;
   procedure valuetogrid(arow: integer); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure updatepopupmenu(var amenu: tpopupmenu; 
                                var mouseinfo: mouseeventinfoty); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure synctofontheight; override;
   property imagesize: sizety read fimagesize write setimagesize;
   property gridimnr[index: integer]: integer
                                    read getgridimnr write setgridimnr;
   property gridimnrs: integerarty read getgridimnrs write setgridimnrs;
  published
   property options: foldeditoptionsty read foptions write foptions default [];
   property oncellevent: celleventty read foncellevent write foncellevent;
   property onclientmouseevent: mouseeventty read fonclientmouseevent 
                           write fonclientmouseevent;
   property levelstep: integer read flevelstep write setlevelstep default 10;

   property imnr_base: integer read fimnr_base write setimnr_base default 0;
   property imnr_expanded: integer read fimnr_expanded 
                                         write setimnr_expanded default 0;
   property imnr_selected: integer read fimnr_selected 
                                         write setimnr_selected default 0;
   property imnr_readonly: integer read fimnr_readonly 
                                         write setimnr_readonly default 0;
   property imnr_subitems: integer read fimnr_subitems 
                                         write setimnr_subitems default 0;
                      
                      
   property imnr_value: integer read fimnr_value write setimnr_value default -1;
             //-1 -> use imagelist, imnr_base, imnr_expanded, imnr_selected
             //imnr_readonly, imnr_subitems
             //-2 none
             // >= 0 use imagelistvalue, imnr_value + imnr_base, imnr_expanded, imnr_selected
             //imnr_readonly, imnr_subitems
   property imnr_valuebase: integer read fimnr_valuebase 
                                       write setimnr_valuebase default 0;
   property imnr_valueexpanded: integer read fimnr_valueexpanded 
                                       write setimnr_valueexpanded default 0;
   property imnr_valueselected: integer read fimnr_valueselected
                                       write setimnr_valueselected default 0;
   property imnr_valuereadonly: integer read fimnr_valuereadonly
                                       write setimnr_valuereadonly default 0;
   property imnr_valuesubitems: integer read fimnr_valuesubitems
                                       write setimnr_valuesubitems default 0;

   property imagelist: timagelist read fimagelist write setimagelist;
   property imagelistvalue: timagelist read fimagelistvalue
                                       write setimagelistvalue;
   property imagewidth: integer read fimagesize.cx write setimagewidth default 0;
   property imageheight: integer read fimagesize.cy write setimageheight default 0;
   property textflags default defaultfoldedittextflags;
   property textflagsactive default defaultfoldedittextflagsactive;
//   property cursor default cr_default;
 end;
 
implementation
uses
 msestockobjects,msesumlist,mseact;

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
 result:= nil;
 with twidgetcol1(fowner) do begin
  if fintf <> nil then begin
   result:= fintf.getdefaultvalue;
  end;
 end;
end;
  
{ tfoldedit }

constructor tfoldedit.create(aowner: tcomponent);
begin
 flevelstep:= 10;
 fdefault.int:= -1;
 fimnr_value:= -1;
 inherited;
// cursor:= cr_default;
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
 imli1: timagelist;
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
   imli1:= nil;
   if datapo <> nil then begin
    int1:= datapo^.int;
   end
   else begin
    int1:= fimnr_value;
   end;
   if int1 <> -1 then begin
    if fimagelistvalue <> nil then begin
     imli1:= fimagelistvalue;     
     inc(int1,fimnr_valuebase);
     if isopen then begin
      inc(int1,fimnr_valueexpanded);
     end;
     if isselected then begin
      inc(int1,fimnr_valueselected);
     end;
     if isreadonly then begin
      inc(int1,fimnr_valuereadonly);
     end;
     if isselected then begin
      inc(int1,fimnr_valueselected);
     end;
     if haschildren then begin
      inc(int1,fimnr_valuesubitems);
     end;
    end;
   end
   else begin
    if fimagelist <> nil then begin
     imli1:= fimagelist;
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
   end;
   if (imli1 <> nil) and (int1 >= 0) then begin
    int2:= arect.cx;
    arect.cx:= fimagesize.cx;
    imli1.paint(acanvas,int1,arect,[al_ycentered,al_xcentered]);
    inc(arect.x,fimagesize.cx);
    arect.cx:= int2;
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
   int3:= rect.x - rect1.x;         //apply adjustments to innerrect
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

procedure tfoldedit.doonpaint(const acanvas: tcanvas);
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
 foldlevel1: byte;
 zone1: cellzonety; 
 row1: integer;
begin
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,ainfo);
 end;
 if not (es_processed in ainfo.eventstate) and (fgridintf <> nil) then begin
  with ainfo do begin
   if isleftbuttondown(ainfo,[]) then begin
{$warnings off}
    with fgridintf.getcol.grid,tdatacols1(datacols).frowstate do begin
{$warnings on}
     row1:= row;
     if row1 >= 0 then begin //no csdesigning
      getfoldstate(row1,isvisible1,foldlevel1,haschildren1,isopen1);
      zone1:= cz_default;
      updatelevelcellzone(foldlevel1,ainfo.pos,zone1);
      if (zone1 = cz_default) and 
                         (ainfo.pos.x >= foldlevel1 * flevelstep) then begin
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
    updatelevelcellzone(fgridintf.getcol.grid.rowfoldlevel[info.cell.row],
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

procedure tfoldedit.updatelevelcellzone(const alevel: integer; const apos: pointty;
                                                         var azone: cellzonety);
var
 int1: integer;
begin
 int1:= (alevel+1) * flevelstep;
 if apos.x >= int1 + fimagesize.cx then begin
  azone:= cz_caption;
 end
 else begin
  if apos.x >= int1 then begin
   azone:= cz_image;
  end;
 end;
end;

procedure tfoldedit.updatecellzone(const row: integer; const apos: pointty;
                                           var result: cellzonety);
begin
 if row >= 0 then begin
  updatelevelcellzone(fgridintf.getcol.grid.rowfoldlevel[row],apos,result);
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

procedure tfoldedit.setimagelistvalue(const avalue: timagelist);
begin
 if fimagelistvalue <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelistvalue));
  if (fimagelistvalue <> nil) and (csdesigning in componentstate) then begin
   fimagesize:= fimagelistvalue.size;
  end;
  updatelayout;
//  invalidate;
 end;
end;

procedure tfoldedit.setimnr_base(const avalue: integer);
begin
 if fimnr_base <> avalue then begin
  fimnr_base:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_expanded(const avalue: integer);
begin
 if fimnr_expanded <> avalue then begin
  fimnr_expanded:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_selected(const avalue: integer);
begin
 if fimnr_selected <> avalue then begin
  fimnr_selected:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_readonly(const avalue: integer);
begin
 if fimnr_readonly <> avalue then begin
  fimnr_readonly:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_subitems(const avalue: integer);
begin
 if fimnr_subitems <> avalue then begin
  fimnr_subitems:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_value(const avalue: integer);
begin
 if fimnr_value <> avalue then begin
  fimnr_value:= avalue;
  valuechanged;
 end;
end;

procedure tfoldedit.setimnr_valuebase(const avalue: integer);
begin
 if fimnr_valuebase <> avalue then begin
  fimnr_valuebase:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_valueexpanded(const avalue: integer);
begin
 if fimnr_valueexpanded <> avalue then begin
  fimnr_valueexpanded:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_valueselected(const avalue: integer);
begin
 if fimnr_valueselected <> avalue then begin
  fimnr_valueselected:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_valuereadonly(const avalue: integer);
begin
 if fimnr_valuereadonly <> avalue then begin
  fimnr_valuereadonly:= avalue;
  formatchanged;
 end;
end;

procedure tfoldedit.setimnr_valuesubitems(const avalue: integer);
begin
 if fimnr_valuesubitems <> avalue then begin
  fimnr_valuesubitems:= avalue;
  formatchanged;
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
  inc(result,fimagesize.cx);
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

function tfoldedit.getgridimnr(index: integer): integer;
var
 list: tdatalist;
begin
 list:= checkgriddata(index);
 if list <> nil then begin
  result:= tmsestringintdatalist(list).itemsb[index];
 end
 else begin
  result:= -1;
 end;
end;

procedure tfoldedit.setgridimnr(index: integer; const avalue: integer);
var
 list: tdatalist;
begin
 list:= checkgriddata(index);
 if list <> nil then begin
  tmsestringintdatalist(list).itemsb[index]:= avalue;
 end;
end;

function tfoldedit.getgridimnrs: integerarty;
begin
 checkgrid;
 result:= tmsestringintdatalist(fgridintf.getcol.datalist).asarrayb;
end;

procedure tfoldedit.setgridimnrs(const avalue: integerarty);
begin
 checkgrid;
 tmsestringintdatalist(fgridintf.getcol.datalist).asarrayb:= avalue;
end;

procedure tfoldedit.gridtovalue(arow: integer);
var
 val1: msestringintty;
begin
 fgridintf.getdata(arow,val1);
 fvalue:= val1.mstr;
 fimnr_value:= val1.int;
 valuetotext;
end;

procedure tfoldedit.valuetogrid(arow: integer);
var
 val1: msestringintty;
begin
 val1.mstr:= fvalue;
 val1.int:= fimnr_value;
 fgridintf.setdata(arow,val1);
end;

procedure tfoldedit.writestatvalue(const writer: tstatwriter);
begin
 inherited;
 writer.writeinteger(valuevarname+'_imnr',fimnr_value);
end;

procedure tfoldedit.readstatvalue(const reader: tstatreader);
begin
 inherited;
 if fgridintf = nil then begin
  imnr_value:= reader.readinteger(valuevarname+'_imnr',imnr_value);
 end;
end;

procedure tfoldedit.synctofontheight;
var
 size1: sizety;
begin
 inherited;
 size1:= paintsize;
 if size1.cy < fimagesize.cy then begin
  size1.cy:= fimagesize.cy;
  paintsize:= size1;
  if fgridintf <> nil then begin
   fgridintf.getcol.grid.datarowheight:= bounds_cy;
  end;
 end;
end;

procedure tfoldedit.dolevelup(const sender: tobject);
begin
 with fgridintf.getgrid do begin
  rowfoldlevel[-1]:= rowfoldlevel[-1] + 1;
 end;
end;

procedure tfoldedit.doleveldown(const sender: tobject);
begin
 with fgridintf.getgrid do begin
  rowfoldlevel[-1]:= rowfoldlevel[-1] - 1;
 end;
end;

procedure tfoldedit.doissum(const sender: tobject);
begin
 with fgridintf.getgrid do begin
  rowfoldissum[-1]:= not rowfoldissum[-1];
 end;
end;

procedure tfoldedit.updatepopupmenu(var amenu: tpopupmenu;
                                          var mouseinfo: mouseeventinfoty);
var
 state1: actionstatesty;
begin
 inherited;
 if fgridintf <> nil then begin
  if feo_menulevel in foptions then begin
   tpopupmenu.additems(amenu,self,mouseinfo,['Levelup','Leveldown'],
              [],[],[{$ifdef FPC}@{$endif}dolevelup,
              {$ifdef FPC}@{$endif}doleveldown]);
  end;
  if feo_menuissum in foptions then begin
   state1:= [];
   if fgridintf.getgrid.rowfoldissum[-1] then begin
    state1:= [as_checked];
   end;
   tpopupmenu.additems(amenu,self,mouseinfo,['Issum'],
              [[mao_checkbox]],[state1],[{$ifdef FPC}@{$endif}doissum],false);
  end;
 end;
end;

function tfoldedit.getcellcursor(const arow: integer;
               const acellzone: cellzonety): cursorshapety;
begin
 if acellzone = cz_caption then begin
  result:= inherited getcellcursor(arow,acellzone);
 end
 else begin
  result:= cr_arrow;
 end;
end;

{
function tfoldedit.getinnerframe: framety;
begin
 result:= inherited getinnerframe;
// result.left:= result.left + imageshift(-1);
end;
}
function createtgridmsestringintdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridmsestringintdatalist.create(aowner);
end;

initialization
 registergriddatalistclass(tgridmsestringintdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridmsestringintdatalist);
end.
