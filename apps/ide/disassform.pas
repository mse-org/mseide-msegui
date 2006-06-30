{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
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

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegdbutils,msegrids,msetypes,msestrings;

type
 tdisassfo = class(tdockform)
   grid: tstringgrid;
   procedure disassfoonshow(const sender: TObject);
  private
   faddress: cardinal;
   procedure internalrefresh;
  public
   gdb: tgdbmi;
   procedure refresh(const addr: ptrint);
   procedure clear;
 end;

var
 disassfo: tdisassfo;

implementation

uses
 disassform_mfm,sourceform,sourcepage,mseformatstr,sysutils;

{ tdisassfo }

procedure tdisassfo.disassfoonshow(const sender: TObject);
begin
 internalrefresh;
end;

procedure tdisassfo.clear;
begin
 grid.clear;
end;

procedure tdisassfo.internalrefresh;
var
 ar1: asmlinearty;
 int1,int2: integer;
 apage: tsourcepage;
 aline: integer;
 start,stop: cardinal;
 fname1: filenamety;
 ca1,ca2: cardinal;

begin
 grid.rowcount:= 0;
 if visible and gdb.active then begin
  int2:= 0;
  if gdb.infoline(faddress,fname1,aline,start,stop) <> gdb_ok then begin
   start:= faddress;
   stop:= faddress + $100;
   aline:= 0;
  end;
  grid.beginupdate;
  try
   while int2 < grid.rowsperpage do begin
    if gdb.disassemble(ar1,start,stop) = gdb_ok then begin
     if aline > 0 then begin
      apage:= sourcefo.openfile(fname1);
      grid.rowcount:= int2 + 1 + length(ar1);
      if (apage <> nil) and (aline > 0) and (aline <= apage.grid.rowcount) then begin
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
end;

procedure tdisassfo.refresh(const addr: ptrint);
begin
 faddress:= addr;
 internalrefresh;
end;

end.
