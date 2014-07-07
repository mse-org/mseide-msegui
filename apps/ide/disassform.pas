{ MSEide Copyright (c) 1999-2014 by Martin Schreiber
   
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
unit disassform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegdbutils,msegrids,msetypes,msestrings,mseevent,
 msegraphics,mseguiglob,msemenus;

type
 tdisassfo = class(tdockform)
   grid: tstringgrid;
   popupmen: tpopupmenu;
   procedure disassfoonshow(const sender: TObject);
   procedure keydo(const sender: twidget; var info: keyeventinfoty);
   procedure deact(const sender: TObject);
   procedure act(const sender: TObject);
   procedure befdrawcell(const sender: tcol; const canvas: tcanvas;
                   var cellinfo: cellinfoty; var processed: Boolean);
   procedure addrcellevent(const sender: TObject; var info: celleventinfoty);
   procedure scrollrows(const sender: tcustomgrid; var step: Integer);
   procedure celleventexe(const sender: TObject; var info: celleventinfoty);
   procedure popupupdate(const sender: tcustommenu);
   procedure showbreakexe(const sender: TObject);
  private
   faddress: qword;
   ffirstaddress: qword;
   flastaddress: qword;
   factiverow: integer;
   fshortcutsswapped: boolean;
   procedure swapshortcuts;
   procedure internalrefresh;
   procedure addlines(const aaddress: qword; const alinecount: integer);
   procedure addpreviouslines(const asetrow: boolean);
  public
   gdb: tgdbmi;
   procedure refresh(const addr: qword);
   procedure clear;
   procedure resetactiverow;
   procedure resetshortcuts;
 end;

var
 disassfo: tdisassfo;

implementation

uses
 disassform_mfm,sourceform,sourcepage,mseformatstr,sysutils,msekeyboard,mseglob,
 actionsmodule,breakpointsform,msegraphutils,mseeditglob,msegridsglob;

{ tdisassfo }

procedure tdisassfo.disassfoonshow(const sender: TObject);
begin
 internalrefresh;
end;

procedure tdisassfo.clear;
begin
 grid.clear;
end;

procedure tdisassfo.addlines(const aaddress: qword; const alinecount: integer);
var
 ar1: asmlinearty;
 int1,int2: integer;
 apage: tsourcepage;
 aline: integer;
 start,stop: qword;
 fname1: filenamety;
 ca1,ca2: qword;
 endrow: integer;
 digits: integer;
 
begin
 int2:= grid.rowcount;
 endrow:= int2 + alinecount;
 digits:= gdb.pointerhexdigits;
 if gdb.infoline(aaddress,fname1,aline,start,stop) <> gdb_ok then begin
  start:= aaddress;
  stop:= aaddress + $100;
  aline:= 0;
 end;
 if start < ffirstaddress then begin
  ffirstaddress:= start;
 end;
 grid.beginupdate;
 try
  while int2 < endrow do begin
   flastaddress:= stop;
   if gdb.disassemble(ar1,start,stop) = gdb_ok then begin
    if aline > 0 then begin
     apage:= sourcefo.openfile(fname1);
     grid.rowcount:= int2 + 1 + length(ar1);
     grid[3][int2]:= inttostr(aline-1);
     if (apage <> nil) and (aline > 0) and 
                              (aline <= apage.grid.rowcount) then begin
      grid[1][int2]:= apage.edit[aline-1];
      grid[2][int2]:= fname1;
     end
     else begin
      grid[1][int2]:= '<line ' + inttostr(aline)+'>';
     end;
     grid.rowcolorstate[int2]:= 1;
     inc(int2);
    end
    else begin
     grid.rowcount:= int2 + length(ar1);
    end;
    for int1:= 0 to high(ar1) do begin
     with ar1[int1] do begin
      grid[0][int2]:= hextostr(address,digits);
      grid[1][int2]:= instruction;
      if address = faddress then begin
       factiverow:= int2;
       grid.rowcolorstate[int2]:= 0;
      end;
     end;
     inc(int2);
    end;
    if gdb.infoline(stop,fname1,aline,ca1,ca2) = gdb_ok then begin
     start:= ca1;
     stop:= ca2;
    end
    else begin
     break;
    end;
   end
   else begin
    break;
   end;
  end;
  if (factiverow >= 0) and (factiverow <= grid.rowcount) then begin
   grid.showcell(makegridcoord(invalidaxis,factiverow));
  end;
 finally
  grid.endupdate;
 end;
end;

procedure tdisassfo.internalrefresh;
begin
 if isvisible and gdb.cancommand then begin
  grid.beginupdate;
  try
   grid.rowcount:= 0;
   addlines(faddress,grid.rowsperpage);
  finally
   grid.endupdate;
  end;
 end;
end;

procedure tdisassfo.refresh(const addr: qword);
begin
 ffirstaddress:= not qword(0);
 faddress:= addr;
 internalrefresh;
end;

procedure tdisassfo.resetactiverow;
begin
 if (factiverow < grid.rowcount) then begin
  grid.rowcolorstate[factiverow]:= -1;
 end;
end;

procedure tdisassfo.addpreviouslines(const asetrow: boolean);
var
 rowcountbefore,rowbefore,activerowbefore{,firstvisiblerowbefore}: integer;
// int1: integer;
begin
 with grid do begin
  rowcountbefore:= rowcount;
//  firstvisiblerowbefore:= firstvisiblerow;
  rowbefore:= row;
  activerowbefore:= factiverow;
  clear;
  addlines((ffirstaddress and not qword($7))-$40,rowcountbefore+$48);
  if asetrow then begin
   row:= rowbefore + factiverow - activerowbefore;
  end
  else begin
   showcell(makegridcoord(col,factiverow-activerowbefore),cep_top,true);
  end;
 end;
end;
 
procedure tdisassfo.scrollrows(const sender: tcustomgrid; var step: Integer);
begin
 if (step > 0) then begin
  if sender.firstvisiblerow = 0 then begin
   addpreviouslines(false);
  end;
 end
 else begin
  if sender.lastvisiblerow = sender.rowhigh then begin
   addlines(flastaddress,grid.rowsperpage);
  end;
 end;
end;

procedure tdisassfo.keydo(const sender: twidget; var info: keyeventinfoty);
begin
 if visible and gdb.cancommand then begin
  with grid,info do begin
   if (shiftstate = []) then begin
    if ((key = key_down) or (key = key_pagedown)) and (row = rowhigh) then begin
     addlines(flastaddress,grid.rowsperpage);
    end
    else begin
     if ((key = key_up) or (key = key_pageup)) and (row = 0) then begin
      addpreviouslines(true);
      showcell(focusedcell,cep_top);
     end;
    end;
   end;
  end;
 end;
end;

procedure tdisassfo.swapshortcuts;
var
 sho1: shortcutty;
begin
 with actionsmo do begin
  sho1:= step.shortcut;
  step.shortcut:= stepi.shortcut;
  stepi.shortcut:= sho1;
  sho1:= next.shortcut;
  next.shortcut:= nexti.shortcut;
  nexti.shortcut:= sho1;
 end;
end;

procedure tdisassfo.resetshortcuts;
begin
 if fshortcutsswapped then begin
  swapshortcuts;
  fshortcutsswapped:= false;
 end;
end;

procedure tdisassfo.deact(const sender: TObject);
begin
 if (application.inactivewindow <> window) then begin
  resetshortcuts;
 end; 
end;

procedure tdisassfo.act(const sender: TObject);
begin
 if not fshortcutsswapped then begin
  swapshortcuts;
  fshortcutsswapped:= true;
 end;
end;

procedure tdisassfo.befdrawcell(const sender: tcol; const canvas: tcanvas;
               var cellinfo: cellinfoty; var processed: Boolean);
begin
 with cellinfo do begin
  if pmsestring(datapo)^ <> '' then begin
   if breakpointsfo.isactivebreakpoint(
                             strtohex64(pmsestring(datapo)^)) then begin
    color:= cl_ltred;
   end;
  end;
 end;
end;

procedure tdisassfo.addrcellevent(const sender: TObject;
               var info: celleventinfoty);
begin
 with info do begin
  if iscellclick(info,[ccr_buttonpress]) then begin
   breakpointsfo.toggleaddrbreakpoint(
                    strtohex64(self.grid[cell.col][cell.row]));
   grid.invalidatecell(cell);
  end;
 end;
end;

procedure tdisassfo.celleventexe(const sender: TObject;
               var info: celleventinfoty);
var
 int1: integer;
begin
 if (info.cell.col = 1) and iscellclick(info,[ccr_dblclick]) then begin
  int1:= info.cell.row;
  while (int1 >= 0) and (grid[2][int1] = '') do begin
   dec(int1);
  end;
  if int1 < 0 then begin
   int1:= info.cell.row;
   while (int1 < grid.rowcount) and (grid[2][int1] = '') do begin
    inc(int1);
   end;
  end;
  if (int1 >= 0) and (int1 < grid.rowcount) then begin
   sourcefo.showsourceline(grid[2][int1],strtoint(grid[3][int1]),0,true);
  end;
 end;
end;

procedure tdisassfo.popupupdate(const sender: tcustommenu);
begin
 popupmen.menu.itembyname('showbreak').enabled:= grid.focusedcellvalid and
    (grid[0][grid.row] <> '') and
    breakpointsfo.isactivebreakpoint(strtohex64(grid[0][grid.row]));          
end;

procedure tdisassfo.showbreakexe(const sender: TObject);
begin
 breakpointsfo.showbreakpoint(
                    strtohex64(self.grid[0][grid.row]),true);
end;

end.
