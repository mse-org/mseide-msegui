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
unit threadsform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegrids,msegdbutils,msetypes,msestrings;

type
 tthreadsfo = class(tdockform)
   grid: tstringgrid;
   procedure threadsfoonshow(const sender: TObject);
   procedure gridoncellevent(const sender: TObject; var info: celleventinfoty);
  private
   fids: integerarty;
   frefreshedrow: integer;
  public
   gdb: tgdbmi;
   procedure refresh;
   procedure clear;
 end;

var
 threadsfo: tthreadsfo;

implementation
uses
 threadsform_mfm,sysutils,sourceform,msefileutils,main,stackform;

{ tthreadsfo }

procedure tthreadsfo.clear;
begin
 grid.clear;
end;

procedure tthreadsfo.refresh;
var
 int1: integer;
 ar1: threadinfoarty;
 wstr1: msestring;
begin
 frefreshedrow:= -1;
 if visible and gdb.cancommand then begin
  if gdb.getthreadinfolist(ar1) = gdb_ok then begin
   setlength(fids,length(ar1));
   grid.rowcount:= length(ar1);
   for int1:= 0 to high(ar1) do begin
    with ar1[int1] do begin
     fids[int1]:= id;
     grid[0][int1]:= inttostr(threadid);
     case state of
      ts_active: begin
       wstr1:= '*active*';
       frefreshedrow:= int1;
       grid.row:= int1;
      end
      else begin
       wstr1:= 'unknown';
      end;
     end;
     grid[1][int1]:= wstr1;
     grid[2][int1]:= stackframe;
    end;
   end;
  end
  else begin
   clear;
  end;
 end;
end;

procedure tthreadsfo.threadsfoonshow(const sender: TObject);
begin
 refresh;
end;

procedure tthreadsfo.gridoncellevent(const sender: TObject; var info: celleventinfoty);
var
 stopinfo: stopinfoty;
begin
 case info.eventkind of
  cek_enter: begin
   if (frefreshedrow <> info.cell.row) and
         (gdb.threadselect(fids[info.cell.row],
                  stopinfo.filename,stopinfo.line) = gdb_ok) then begin
    refresh;
    stackfo.refresh;
    mainfo.refreshframe;
    if stopinfo.filename <> '' then begin
     stopinfo.filedir:= '';
     sourcefo.locate(stopinfo);
    end;
{
    if gdb.getsourcename(wstr1) = gdb_ok then begin
     with stopinfo do begin
      splitfilepath(wstr1,filedir,filename);
      if gdb.stacklistframes(ar1,0,0) = gdb_ok then begin
       line:= ar1[0].line;
       sourcefo.locate(stopinfo);
      end;
     end;
    end;
}
   end;
  end;
 end;
 if iscellclick(info,[ccr_dblclick]) then begin
  sourcefo.activate;
 end;
end;

end.
