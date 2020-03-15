{ MSEide Copyright (c) 1999-2015 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit msefaceselectorform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,
 msedatanodes,mseedit,msegrids,mselistbrowser,msestrings,msetypes,msebitmap,
 msestatfile;
type
 tfaceselectorfo = class(tmseform)
   lv: tlistview;
   tstatfile1: tstatfile;
   procedure itemev(const sender: tcustomlistview; const index: Integer;
                   var info: celleventinfoty);
   procedure paintitemexe(const sender: titemviewlist; const canvas: tcanvas;
                   const item: tlistedititem);
   procedure layoutcha(const sender: tcustomlistview);
  private
   ffacelist: tfacelist;
   ffacenr: integer;
  public
   constructor create(const aowner: tcomponent; const afacelist: tfacelist;
                      var afacenr: integer); reintroduce;
 end;
implementation
uses
 msefaceselectorform_mfm,sysutils,mseformatstr;

{ tfaceselectorfo }

constructor tfaceselectorfo.create(const aowner: tcomponent;
               const afacelist: tfacelist; var afacenr: integer);
var
 int1: integer;
begin
 if afacelist <> nil then begin
  ffacelist:= afacelist;
  ffacenr:= afacenr;
  inherited create(aowner);
{
  with lv do begin
   int1:= aimagelist.width + 2;
   if int1 < 20 then begin
    int1:= 20;
   end;
   cellwidth:= int1;
   cellheight:= aimagelist.height + font.lineheight + 3;
   cellsize:= ms(35,40);
  end;
}
  with lv.itemlist do begin
//   imagelist:= aimagelist;
   count:= afacelist.list.count;
//   imagewidth:= aimagelist.width;
//   imageheight:= aimagelist.height+2;
   for int1:= 0 to count -1 do begin
    with items[int1] do begin
     imagenr:= int1;
     caption:= inttostrmse(int1);
    end;
   end;
  end;
  lv.focusedindex:= ffacenr;
  show(true);
  afacenr:= ffacenr;
 end;
 release;
end;

procedure tfaceselectorfo.itemev(const sender: tcustomlistview;
               const index: Integer; var info: celleventinfoty);
begin
 if iscellclick(info) then begin
  ffacenr:= index;
  window.modalresult:= mr_ok;
 end;
end;

procedure tfaceselectorfo.paintitemexe(const sender: titemviewlist;
               const canvas: tcanvas; const item: tlistedititem);
begin
 if ffacelist <> nil then begin
  ffacelist.paint(canvas,item.index,sender.layoutinfo.imagerect);
 end;
end;

procedure tfaceselectorfo.layoutcha(const sender: tcustomlistview);
begin
 sender.itemlist.imagesize:=
    ms(sender.cellwidth,sender.cellheight-sender.font.glyphheight-2);
end;

end.
