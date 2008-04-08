{ MSEide Copyright (c) 1999-2008 by Martin Schreiber
   
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
 msegui,mseclasses,mseforms,msegdbutils,msegrids,msetypes,msestrings,
 mseevent;

type
 tdisassfo = class(tdockform)
   grid: tstringgrid;
   procedure disassfoonshow(const sender: TObject);
   procedure keydo(const sender: twidget; var info: keyeventinfoty);
   procedure deact(const sender: TObject);
   procedure act(const sender: TObject);
  private
   faddress: cardinal;
   ffirstaddress: cardinal;
   flastaddress: cardinal;
   factiverow: integer;
   fshortcutsswapped: boolean;
   procedure swapshortcuts;
   procedure internalrefresh;
   procedure addlines(const aaddress: longword; const alinecount: integer);
  public
   gdb: tgdbmi;
   procedure refresh(const addr: ptrint);
   procedure clear;
   procedure resetactiverow;
 end;

var
 disassfo: tdisassfo;

implementation

uses
 disassform_mfm,sourceform,sourcepage,mseformatstr,sysutils,msekeyboard,mseglob,
 actionsmodule;

{ tdisassfo }

procedure tdisassfo.disassfoonshow(const sender: TObject);
begin
 internalrefresh;
end;

procedure tdisassfo.clear;
begin
 grid.clear;
end;

procedure tdisassfo.addlines(const aaddress: longword; 
                                            const alinecount: integer);
var
 ar1: asmlinearty;
 int1,int2: integer;
 apage: tsourcepage;
 aline: integer;
 start,stop: cardinal;
 fname1: filenamety;
 ca1,ca2: cardinal;
 endrow: integer;

begin
 int2:= grid.rowcount;
 endrow:= int2 + alinecount;
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
     if (apage <> nil) and (aline > 0) and 
                              (aline <= apage.grid.rowcount) then begin
      grid[1][int2]:= apage.edit[aline-1];
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
      grid[0][int2]:= hextostr(address,8);
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
 finally
  grid.endupdate;
 end;
end;

procedure tdisassfo.internalrefresh;
begin
 grid.rowcount:= 0;
 if visible and gdb.active then begin
  addlines(faddress,grid.rowsperpage);
 end;
end;

procedure tdisassfo.refresh(const addr: ptrint);
begin
 ffirstaddress:= cardinal(not 0);
 faddress:= addr;
 internalrefresh;
end;

procedure tdisassfo.resetactiverow;
begin
 if (factiverow < grid.rowcount) then begin
  grid.rowcolorstate[factiverow]:= -1;
 end;
end;

procedure tdisassfo.keydo(const sender: twidget; var info: keyeventinfoty);
var
 rowcountbefore,rowbefore,activerowbefore: integer;
 int1: integer;
begin
 if visible and gdb.active and not gdb.running then begin
  with grid,info do begin
   if (shiftstate = []) then begin
    if ((key = key_down) or (key = key_pagedown)) and (row = rowhigh) then begin
     addlines(flastaddress,grid.rowsperpage);
    end
    else begin
     if ((key = key_up) or (key = key_pageup)) and (row = 0) then begin
      rowcountbefore:= rowcount;
      rowbefore:= row;
      activerowbefore:= factiverow;
      clear;
      addlines((ffirstaddress and not $7)-$40,rowcountbefore+$48);
      row:= rowbefore + factiverow - activerowbefore;
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

procedure tdisassfo.deact(const sender: TObject);
begin
 if (application.inactivewindow <> window) and fshortcutsswapped then begin
  swapshortcuts;
  fshortcutsswapped:= false;
 end; 
end;

procedure tdisassfo.act(const sender: TObject);
begin
 if not fshortcutsswapped then begin
  swapshortcuts;
  fshortcutsswapped:= true;
 end;
end;

end.
