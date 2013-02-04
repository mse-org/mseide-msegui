{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestringlistedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 Classes,msegrids,mseinplaceedit,mseeditglob,mseevent,msegraphics,msegraphutils,
 msedatalist,mserichstring,msestring,mseguiglob,msetypes;

type
 editposty = record
  col,row: integer;
 end;

const
 defaultstringlistcoloptions = [];
 invalideditpos: editposty = (col: -1; row: -1);

type

 tstringlistcol = class(tstringcol,iedit)
  private
   feditor: tinplaceedit;
   feditpos: editposty;
   feditcol: integer;
   fstartanchor: editposty;
   fendanchor: editposty;
   fsel1,fsel2: editposty;
   function getdata: trichstringdatalist;
   procedure selectstart(const pos: editposty);
   procedure selectend(const pos: editposty);
   procedure clearselection;
   procedure extendselection;
   procedure updateselection;
  protected
   function getoptionsedit: optionseditty; //iedit
   procedure editnotification(var info: editnotificationinfoty); virtual;

   procedure scrolled(const dist: pointty); override;
   procedure fontchanged(const sender: tobject); override;
   procedure dofocusedcellchanged(enter: boolean;
                  const cellbefore: gridcoordty; var newcell: gridcoordty;
                       const action: focuscellactionty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure clientmouseevent(const acell: gridcoordty; var info: mouseeventinfoty); override;
   procedure dokeyevent(var info: keyeventinfoty; up: boolean); override;
   function createdatalist: tdatalist; override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure drawfocusedcell(const canvas: tcanvas); override;
   procedure itemchanged(sender: tdatalist; index: integer); override;

  public
   constructor create(agrid: tcustomgrid; aowner: tgridarrayprop); override;
   destructor destroy; override;
   function getselection(out start,stop: editposty): boolean;
   property data: trichstringdatalist read getdata;
  published
   property font;
 end;

 tstringlistedit = class(tcustomgrid)
  private
   fstringlistcolindex: integer;
   function gettext: trichstringdatalist;
   procedure settext(const Value: trichstringdatalist);
   function gettextwidth: integer;
   procedure settextwidth(const Value: integer);
  protected
   procedure createdatacol(const index: integer; out item: tdatacol); override;
  public
   constructor create(aowner: tcomponent); override;
   property text: trichstringdatalist read gettext write settext;
  published
   property textwidth: integer read gettextwidth write settextwidth default 0;
   property font;
   property rowcount;
 end;

function makeeditpos(col,row: integer): editposty;

implementation
uses
 SysUtils,msegui;

type
 twidget1 = class(twidget);

function makeeditpos(col,row: integer): editposty;
begin
 result.col:= col;
 result.row:= row;
end;

{ tstringlistcol }

constructor tstringlistcol.create(agrid: tcustomgrid;
  aowner: tgridarrayprop);
begin
 inherited;
 foptions:= defaultstringlistcoloptions;
 feditor:= tinplaceedit.create(fgrid,iedit(self));
 fstartanchor:= invalideditpos;
 fendanchor:= invalideditpos;
 fsel1:= invalideditpos;
 fsel2:= invalideditpos;
end;

destructor tstringlistcol.destroy;
begin
 feditor.Free;
 ffont.free;
 inherited;
end;

procedure tstringlistcol.fontchanged(const sender: tobject);
begin
 inherited;
 if (sender = self) or (ffont = nil) then begin
  changed;
 end;
end;

procedure tstringlistcol.dofocusedcellchanged(enter: boolean;
                  const cellbefore: gridcoordty; var newcell: gridcoordty;
                  const action: focuscellactionty);
var
 rect1: rectty;
begin
 if enter then begin
  rect1:= fgrid.cellrect(newcell);
  feditor.setup(items[newcell.row],0,false,inflaterect(rect1,-1),
                   rect1,data.formats[newcell.row],nil,font);
  feditpos.row:= newcell.row;
  if action = fca_selectend then begin
   extendselection;
  end;
 // feditor.curindex:= feditcol;
  feditor.moveindex(feditcol,action = fca_selectend);
  feditor.dofocus;
 end
 else begin
  items[cellbefore.row]:= feditor.text;
  if action = fca_selectend then begin
   if fstartanchor.row < 0 then begin
    fstartanchor:= feditpos;
   end;
  end
  else begin
   clearselection;
  end;
  feditor.dodefocus;
 end;
 inherited;
end;

procedure tstringlistcol.clientmouseevent(const acell: gridcoordty;
                   var info: mouseeventinfoty);
begin
 feditor.mouseevent(info);
 inherited;
end;

procedure tstringlistcol.dokeyevent(var info: keyeventinfoty; up: boolean);
begin
 if not up then begin
  feditor.dokeydown(info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
procedure tstringlistcol.dokeyup(var info: keyeventinfoty);
begin
 feditor.dokeyup(info);
 if not info.processed then begin
  inherited;
 end;
end;
}
procedure tstringlistcol.editnotification(var info: editnotificationinfoty);
begin
 case info.action of
  ea_indexmoved: begin
   feditpos.col:= feditor.curindex;
   feditcol:= feditpos.col;
   if not(eas_shift in info.state) then begin
    selectstart(feditpos);
   end
   else begin
    selectend(feditpos);
   end;
  end;
  ea_clearselection: clearselection;
  ea_textedited: begin
   include(fstate,cos_noinvalidate);
   data.richitems[feditpos.row]:= feditor.richtext;
   exclude(fstate,cos_noinvalidate);
  end;
 end;
end;

function tstringlistcol.getoptionsedit: optionseditty;
begin
 result:= []; //[oe_noautoselect,oe_noresetselectonexit];
end;

procedure tstringlistcol.drawcell(const canvas: tcanvas);
begin
 ftextinfo.text.format:= data.formats[cellinfoty(canvas.drawinfopo^).cell.row];
 inherited;
end;

procedure tstringlistcol.drawfocusedcell(const canvas: tcanvas);
var
 po1: pointty;
begin
 drawcellbackground(canvas);
 po1:= fgrid.cellrect(cellinfoty(canvas.drawinfopo^).cell).pos;
 canvas.remove(po1);
 feditor.dopaint(canvas);
 canvas.move(po1);
end;

procedure tstringlistcol.scrolled(const dist: pointty);
begin
 inherited;
 feditor.scroll(dist);
 if fgrid.active then begin
  application.caret.move(dist);
 end;
end;

function tstringlistcol.createdatalist: tdatalist;
begin
 result:= trichstringdatalist.create;
end;

function tstringlistcol.getdata: trichstringdatalist;
begin
 result:= trichstringdatalist(fdata);
end;

procedure tstringlistcol.selectstart(const pos: editposty);
begin
 clearselection;
 fstartanchor:= pos;
 fendanchor:= invalideditpos;
end;

procedure tstringlistcol.selectend(const pos: editposty);
begin
 fendanchor:= pos;
 updateselection;
end;

procedure tstringlistcol.extendselection;
begin
 fendanchor:= feditpos;
 updateselection;
end;

procedure tstringlistcol.clearselection;
var
 int1: integer;
 po1,po2: editposty;
begin
 if getselection(po1,po2) then begin
  for int1:= po1.row to po2.row do begin
   updatefontstyle(data.getformatpo(int1)^,0,bigint,fs_selected,false);
   cellchanged(int1);
  end;
 end;
 fstartanchor:= feditpos;
 fendanchor:= invalideditpos;
 fsel1:= invalideditpos;
 fsel2:= invalideditpos;
end;

procedure tstringlistcol.updateselection;

 procedure setselected1(const po1,po2: editposty; select: boolean);
 var
  int1: integer;
 begin
  int1:= po2.col - po1.col;
  if po2.row > po1.row then begin
   int1:= bigint;
  end;
  updatefontstyle(data.getformatpo(po1.row)^,po1.col,int1,fs_selected,select);
  cellchanged(po1.row);
  for int1:= po1.row + 1 to po2.row-1 do begin
   updatefontstyle(data.getformatpo(int1)^,0,bigint,fs_selected,select);
   cellchanged(int1);
  end;
  if po2.row > po1.row then begin
   updatefontstyle(data.getformatpo(po2.row)^,0,po2.col,fs_selected,select);
   cellchanged(po2.row);
  end;
 end;

var
 po1,po2: editposty;
begin
 if getselection(po1,po2) then begin
  if fsel1.row >= 0 then begin
   setselected1(fsel1,po1,false);
   setselected1(po2,fsel2,false);
   setselected1(po1,fsel1,true);
   setselected1(fsel2,po2,true);
  end
  else begin
   setselected1(po1,po2,true);
  end;
  if feditpos.row >= po1.row then begin
   if feditpos.row = po1.row then begin
    feditor.selstart:= po1.col;
    if feditpos.row = po2.row then begin
     feditor.sellength:= po2.col - po1.col;
    end
    else begin
     feditor.sellength:= length(feditor.text);
    end;
   end
   else begin
    feditor.selstart:= 0;
    if feditpos.row = po2.row then begin
     feditor.sellength:= po2.col;
    end
    else begin
     feditor.sellength:= length(feditor.text);
    end;
   end;
  end;
  fsel1:= po1;
  fsel2:= po2;
 end;
end;

function tstringlistcol.getselection(out start, stop: editposty): boolean;
begin
 if (fstartanchor.row >= 0) and (fendanchor.row >= 0) then begin
  result:= true;
  if fendanchor.row < fstartanchor.row then begin
   start:= fendanchor;
   stop:= fstartanchor;
  end
  else begin
   stop:= fendanchor;
   start:= fstartanchor;
   if fendanchor.row = fstartanchor.row then begin
    if fendanchor.col < fstartanchor.col then begin
     start.col:= fendanchor.col;
     stop.col:= fstartanchor.col;
    end;
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

procedure tstringlistcol.doactivate;
begin
 feditor.doactivate;
 inherited;
end;

procedure tstringlistcol.dodeactivate;
begin
 feditor.dodeactivate;
 inherited;
end;

procedure tstringlistcol.itemchanged(sender: tdatalist; index: integer);
begin
 if not (cos_noinvalidate in fstate) and (feditpos.row >= 0) and
          ((index < 0) or (index = feditpos.row)) then begin
  feditor.richtext:= data.richitems[feditpos.row];
 end;
 inherited;
end;

{ tstringlistedit }

constructor tstringlistedit.create(aowner: tcomponent);
begin
 inherited;
 fstringlistcolindex:= 0;
 datacols.count:= 1;
end;

procedure tstringlistedit.createdatacol(const index: integer;
  out item: tdatacol);
begin
 if index = fstringlistcolindex then begin
  item:= tstringlistcol.create(self,fdatacols);
  item.options:= item.options + [co_fill];
 end;
end;

function tstringlistedit.gettext: trichstringdatalist;
begin
 result:= tstringlistcol(fdatacols[0]).data;
end;

procedure tstringlistedit.settextwidth(const Value: integer);
begin
 fdatacols[fstringlistcolindex].widthmin:= value;
end;

function tstringlistedit.gettextwidth: integer;
begin
 result:= fdatacols[fstringlistcolindex].widthmin;
end;

procedure tstringlistedit.settext(const Value: trichstringdatalist);
begin
 tstringlistcol(fdatacols[0]).data.assign(value);
end;

end.
