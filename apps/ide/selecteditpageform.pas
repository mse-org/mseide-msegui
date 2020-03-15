{ MSEide Copyright (c) 1999-2010 by Martin Schreiber

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
unit selecteditpageform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,mselistbrowser,msetypes,msestrings,msegrids,msegui,msedispwidgets,
 msestat,msesimplewidgets,mseglob,msegridsglob;

type
 tselecteditpagefo = class(tmseform)
   list: tlistview;
   pathdisp: tstringdisp;
   openfilebutton: tbutton;
   procedure doonitemevent(const sender: tcustomlistview; const index: Integer;
              var info: celleventinfoty);
//   procedure doonshowhint(const sender: TObject; var info: hintinfoty);
   procedure fooncreate(const sender: TObject);
   procedure openfileonexecute(const sender: TObject);
   procedure formonchildscaled(const sender: TObject);
  private
   fpaths,frelpaths,fnames: filenamearty;
   fsortlist: integerarty;
  public
 end;

procedure selecteditpage;
procedure updatestat(const filer: tstatfiler);

implementation

uses
 selecteditpageform_mfm,sourceform,msedatalist,msedatanodes,msegraphutils,main,
 msefileutils,mseguiglob,msearrayutils;
var
 colwidth: integer;
 pos: rectty;

procedure updatestat(const filer: tstatfiler);
begin
 filer.setsection('selecteditpage');
 filer.updatevalue('colwidth',colwidth);
 with pos do begin
  filer.updatevalue('x',x);
  filer.updatevalue('y',y);
  filer.updatevalue('cx',cx);
  filer.updatevalue('cy',cy);
 end;
end;

procedure selecteditpage;
var
 fo: tselecteditpagefo;
begin
 fo:= tselecteditpagefo.create(nil);
 try
  fo.list.cellwidth:= colwidth;
  if (pos.cx > 0) and (pos.y > 0) then begin
   fo.widgetrect:= pos;
  end;
  if fo.show(true,sourcefo.window) = mr_ok then begin
   sourcefo.show;
   sourcefo.setfocus;
  end;
  colwidth:= fo.list.cellwidth;
  pos:= fo.window.normalwindowrect;
 finally
  fo.Free;
 end;
end;

{ tselecteditpagefo }

procedure tselecteditpagefo.doonitemevent(const sender: tcustomlistview;
                     const index: Integer; var info: celleventinfoty);
begin
 if iscellclick(info) then begin
  sourcefo.tabwidget.activepageindex:= fsortlist[index];
  window.modalresult:= mr_ok;
 end
 else begin
  if info.eventkind = cek_enter then begin
   if findfile(frelpaths[fsortlist[index]]) then begin
    pathdisp.value:= filepath(frelpaths[fsortlist[index]]);
   end
   else begin
    pathdisp.value:= fpaths[fsortlist[index]];
   end;
  end;
 end;
end;
{
procedure tselecteditpagefo.doonshowhint(const sender: TObject; var info: hintinfoty);
var
 item1: tlistitem;
begin
 item1:= list.itematpos(info.posrect.pos);
 if item1 <> nil then begin
  with info do begin
   caption:= fpaths[fsortlist[item1.index]];
   include(flags,hfl_show);
   showtime:= 0;
  end;
 end;
end;
}
procedure tselecteditpagefo.fooncreate(const sender: TObject);
var
 int1,int2: integer;
begin
 setlength(fpaths,sourcefo.count);
 setlength(frelpaths,sourcefo.count);
 setlength(fnames,sourcefo.count);
 for int1:= 0 to high(fpaths) do begin
  fpaths[int1]:= sourcefo.items[int1].filepath;
  frelpaths[int1]:= sourcefo.items[int1].relpath;
  fnames[int1]:= sourcefo.items[int1].filename;
 end;
 sortarray(fnames,sms_upi,fsortlist);
 list.itemlist.add(fnames);
 int2:= sourcefo.tabwidget.activepageindex;
 for int1:= 0 to high(fsortlist) do begin
  if fsortlist[int1] = int2 then begin
   list.focusedindex:= int1;
   break;
  end;
 end;
end;

procedure tselecteditpagefo.openfileonexecute(const sender: TObject);
begin
 if mainfo.opensource(fk_source,false) then begin
  release;
 end;
end;

procedure tselecteditpagefo.formonchildscaled(const sender: TObject);
begin
 placeyorder(0,[1],[list,pathdisp],1);
 openfilebutton.height:= pathdisp.height;
 aligny(wam_center,[pathdisp,openfilebutton]);
 list.synctofontheight;
end;

initialization
 colwidth:= 100;
end.
