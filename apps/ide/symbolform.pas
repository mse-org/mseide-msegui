{ MSEide Copyright (c) 2010 by Martin Schreiber
   
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
unit symbolform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedock,msedataedits,
 mseedit,msegrids,msestrings,msetypes,msewidgetgrid,msegraphedits;

type
 tsymbolfo = class(tdockform)
   grid: twidgetgrid;
   symbol: tstringedit;
   syminfo: tstringedit;
   symaddr: tstringedit;
   tpopupmenu1: tpopupmenu;
   path: tstringedit;
   line: tintegeredit;
   procedure symboldataent(const sender: TObject);
   procedure symbolcha(const sender: tdatacol; const aindex: Integer);
   procedure deleteallex(const sender: TObject);
   procedure cellev(const sender: TObject; var info: celleventinfoty);
   procedure showex(const sender: TObject);
  protected
   procedure checksymbol(const aindex: integer);
  public
   procedure updatesymbols;   
 end;
var
 symbolfo: tsymbolfo;

implementation
uses
 symbolform_mfm,msegdbutils,main,sysutils,msewidgets,mseformatstr,sourceform;

procedure tsymbolfo.checksymbol(const aindex: integer);
var
 str1,str2: msestring;
 err: gdbresultty;
 mstr1: msestring;
 int1: integer;
 ad1,ad2,ad3: qword;
begin
 str2:= trim(symbol[aindex]);
 if str2 = '' then begin
  syminfo[aindex]:= '';
  symaddr[aindex]:= '';
 end
 else begin
  if (length(str2) > 0) and (str2[1] = '$') then begin
   str2:= '0x'+copy(str2,2,bigint);
  end;
  err:= mainfo.gdb.infosymbol(str2,str1);
  if err = gdb_notactive then begin
   mstr1:= 'GDB not active.';
   syminfo[aindex]:= mstr1;
   symaddr[aindex]:= mstr1;
   exit;
  end;
  syminfo[aindex]:= trim(removelinebreaks(str1));
  path[aindex]:= '';
  line[aindex]:= 0;
  if not startsstr('0x',str2) then begin
   mainfo.gdb.infoaddress(str2,str1);
  end
  else begin
   str1:= '';
   if trystrtointvalue64(str2,ad1) then begin
    if mainfo.gdb.infoline(ad1,mstr1,int1,ad2,ad3) = gdb_ok then begin
     path[aindex]:= mstr1;
     line[aindex]:= int1;
     str1:= mstr1+':'+inttostr(int1);     
    end;
   end;    
  end;
  symaddr[aindex]:= trim(removelinebreaks(str1));
 end;
end;

procedure tsymbolfo.symboldataent(const sender: TObject);
begin
 checksymbol(grid.row);
end;

procedure tsymbolfo.symbolcha(const sender: tdatacol; const aindex: Integer);
var
 int1: integer;
begin
 if aindex < 0 then begin
  for int1:= 0 to grid.rowhigh do begin
   checksymbol(int1);
  end;
 end
 else begin
  checksymbol(aindex);
 end;
end;

procedure tsymbolfo.updatesymbols;
begin
 if visible then begin
  symbolcha(nil,-1);
 end;
end;

procedure tsymbolfo.deleteallex(const sender: TObject);
begin
 if askyesno('Do you wish to delete all symbols?') then begin
  grid.clear;
 end;
end;

procedure tsymbolfo.cellev(const sender: TObject; var info: celleventinfoty);
begin
 if iscellclick(info,[ccr_dblclick]) then begin
  sourcefo.showsourceline(path[info.cell.row],line[info.cell.row]-1,0,true);
 end;
end;

procedure tsymbolfo.showex(const sender: TObject);
begin
 updatesymbols;
end;

end.
