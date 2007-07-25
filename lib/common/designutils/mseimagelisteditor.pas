{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseimagelisteditor;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseforms,msegui,msebitmap,msesimplewidgets,msegraphics,mselistbrowser,msegrids,
 msefiledialog,msestat,msestatfile,msestrings,msegraphedits,msecolordialog;

type
 timagelisteditorfo = class(tmseform)
   ok: tbutton;
   cancel: tbutton;                                                  
   add: tbutton;
   clear: tbutton;
   disp: tlistview;
   imagelist: timagelist;
   filedialog: tfiledialog;
   statfile1: tstatfile;
   stretch: tbooleanedit;
   transparentcolor: tcoloredit;
   masked: tbooleanedit;
   procedure addonexecute(const sender: tobject);
   procedure clearonexecute(const sender: tobject);
   procedure disponitemevent(const sender: tcustomlistview; const index: integer;
                       var info: celleventinfoty);
   procedure disponitemsmoved(const sender: tcustomgrid;
                  const fromindex,toindex,count: integer);

//   procedure disponpaint(const sender: twidget; const canvas: tcanvas);
   procedure layoutchanged(const sender: tcustomlistview);
  private
   procedure listchange(const sender: tobject);
 end;

function editimagelist(aimagelist: timagelist): modalresultty;

implementation
uses
 mseimagelisteditor_mfm,msetypes,msegraphutils,sysutils,
 msekeyboard,msedatanodes,msefileutils,msegraphicstream;

function editimagelist(aimagelist: timagelist): modalresultty;
var
 dialog: timagelisteditorfo;
begin
 dialog:= timagelisteditorfo.create(nil);
 try
  with dialog do begin
   imagelist.onchange:= {$ifdef FPC}@{$endif}listchange;
   imagelist.Assign(aimagelist);
   result:= show(true);
   if result = mr_ok then begin
    aimagelist.Assign(imagelist);
   end;
  end;
 finally
  dialog.Free;
 end;
end;

{ timagelisteditorfo }

procedure timagelisteditorfo.addonexecute(const sender: tobject);
var
 bmp,bmp1: tmaskedbitmap;
 ar1: filenamearty;
 int1: integer;
begin
 filedialog.controller.filename:= filedialog.controller.lastdir;
 filedialog.controller.filterlist.asarraya:= graphicfilefilternames;
 filedialog.controller.filterlist.asarrayb:= graphicfilemasks;
 if filedialog.execute = mr_ok then begin
  unquotefilename(filedialog.controller.filename,ar1);
  bmp:= tmaskedbitmap.create(false);
  bmp1:= tmaskedbitmap.create(bmp.monochrome);
  try
   for int1:= 0 to high(ar1) do begin
    bmp.transparentcolor:= cl_none;
    bmp.loadfromfile(ar1[int1],
               graphicformatlabels[filedialog.controller.filterindex]);
    if not bmp.masked then begin
     bmp.transparentcolor:= transparentcolor.value;
    end;
    bmp.masked:= masked.value;
//    if imagelist.masked and not bmp.masked then begin
//     bmp.automask;
//    end;
    if stretch.value then begin
     bmp1.size:= imagelist.size;
     bmp.stretch(bmp1);
     imagelist.addimage(bmp1);
    end
    else begin    
     imagelist.addimage(bmp);
    end;
   end;
  finally
   bmp.Free;
   bmp1.free;
  end;
 end;
end;

procedure timagelisteditorfo.clearonexecute(const sender: tobject);
begin
 imagelist.clear;
end;
{
procedure timagelisteditorfo.disponpaint(const sender: twidget;
  const canvas: tcanvas);
var
 int1: integer;
 dest: rectty;
begin
 dest.pos:= nullpoint;
 dest.size:= imagelist.size;
 for int1:= 0 to fimagelist.count - 1 do begin
  fimagelist.paint(canvas,dest,int1);
  inc(dest.x,fimagelist.width);
  if dest.x + dest.cx > disp.clientrect.cx then begin
   dest.x:= 0;
   inc(dest.y,fimagelist.height);
  end;
 end;
end;
}
procedure timagelisteditorfo.disponitemevent(const sender: tcustomlistview;
  const index: integer; var info: celleventinfoty);
var
 int1,int2: integer;

begin
 case cellkeypress(info) of
  key_delete: begin
   imagelist.beginupdate;
   try
    int2:= 0;
    for int1:= 0 to disp.itemlist.count - 1 do begin
     if ns_selected in disp.itemlist[int1].state then begin
      imagelist.deleteimage(int2);
     end
     else begin
      inc(int2);
     end;
    end;
    with disp do begin
     datacols.clearselection;
     if focusedindex >= 0 then begin
      items[focusedindex].selected:= true;
     end;
    end;
   finally
    imagelist.endupdate;
   end;
  end;
 end;
end;

procedure timagelisteditorfo.disponitemsmoved(const sender: tcustomgrid;
                  const fromindex,toindex,count: integer);
begin
 imagelist.moveimage(fromindex,toindex);
 listchange(nil);
end;

procedure timagelisteditorfo.listchange(const sender: tobject);
var
 int1{,int2}: integer;
begin
// int2:= disp.itemlist.count;
 disp.itemlist.count:= imagelist.count;
 disp.beginupdate;
 for int1:= 0 {int} to disp.itemlist.count - 1 do begin
  with disp.itemlist[int1] do begin
   caption:= inttostr(int1);
   imagenr:= int1;
  end;
 end;
 disp.endupdate;
end;

procedure timagelisteditorfo.layoutchanged(const sender: tcustomlistview);
begin
 with sender do begin
  itemlist.imagewidth:= cellwidth;
  itemlist.imageheight:= cellheight - font.glyphheight;
 end;
end;

end.
