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
unit stackform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msegrids,msetypes,msegdbutils,msegui,msedispwidgets,msemenus,mseguiintf;

type
 tstackfo = class(tdockform)
   grid: tstringgrid;
   filedisp: tstringdisp;
   address: tstringdisp;
   tpopupmenu1: tpopupmenu;
   procedure stackfoonshow(const sender: tobject);
   procedure gridoncellevent(const sender: tobject; var info: celleventinfoty);
   procedure formonchildscaled(const sender: TObject);
   procedure copytoclipboard(const sender: TObject);
  private
   frameinfo: frameinfoarty;
  public
   gdb: tgdbmi;
   procedure refresh;
   procedure clear;
   function showsource(const aframenr: integer): boolean;
   function infotext(const aframenr: integer): string;
 end;

var
 stackfo: tstackfo;

implementation

uses
 sysutils,stackform_mfm,sourceform,msefileutils,mseformatstr,main,mseguiglob,
 msegraphutils,msestrings,projectoptionsform;

{ tstackfo }

function tstackfo.showsource(const aframenr: integer): boolean;
begin
 if (aframenr >= 0) and (aframenr <= high(frameinfo)) then begin
  grid.row:= aframenr;
  with frameinfo[aframenr] do begin
   if filename <> '' then begin
    result:= sourcefo.showsourceline(objpath(filename),line-1,0,true) <> nil;
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

function tstackfo.infotext(const aframenr: integer): string;
begin
 if (aframenr >= 0) and (aframenr <= high(frameinfo)) then begin
  with frameinfo[aframenr] do begin
   result:= 'File: '+filename+':'+inttostr(line)+' '+'Function: '+func;
  end;
 end
 else begin
  result:= '';
 end;
end;

procedure tstackfo.gridoncellevent(const sender: tobject;
  var info: celleventinfoty);
var
// str1: msestring;
 rect1: rectty;
begin
 with info do begin
  case eventkind of
   cek_enter: begin
    filedisp.value:= self.grid[2][cell.row]+':'+self.grid[3][cell.row];
    address.value:= self.grid[4][cell.row];
    if (cellbefore.row >= 0) and (cellbefore.row <> newcell.row) then begin
     mainfo.stackframechanged(newcell.row);
    end;
   end;
   cek_exit: begin
    filedisp.value:= '';
    address.value:= '';
   end;
   cek_firstmousepark: begin
    if cell.col = 1 then begin
     with tstringgrid(sender) do begin
      if textclipped(cell,rect1) then begin
       inc(rect1.cy,12);
       application.showhint(twidget(sender),items[cell],rect1,cp_bottomleft,-1);
      end;
     end;
    end;
   end;
  end;
  if iscellclick(info,[ccr_dblclick]) then begin
   showsource(cell.row);
  end;
 end;
end;

procedure tstackfo.clear;
begin
 grid.rowcount:= 0;
end;

procedure tstackfo.refresh;
var
 int1,int2: integer;
 str1: string;
begin
 if visible and gdb.cancommand then begin
  gdb.stacklistframes(frameinfo);
  grid.row:= -1;
  grid.rowcount:= length(frameinfo);
  for int1:= 0 to high(frameinfo) do begin
   with frameinfo[int1] do begin
    grid[0][int1]:= inttostr(level);
    str1:= func + '(';
    if high(params) >= 0 then begin
     for int2:= 0 to high(params) do begin
      str1:= str1 + params[int2].name + '=' + 
            removelinebreaks(params[int2].value) + ', ';
     end;
     setlength(str1,length(str1)-2);
    end;
    grid[1][int1]:= str1 + ')';
    grid[2][int1]:= filename;
    grid[3][int1]:= inttostr(line);
    grid[4][int1]:= hextostr(cardinal(addr),8);
   end;
  end;
  if grid.rowcount > 0 then begin
   grid.row:= 0;
  end;
 end;
end;

procedure tstackfo.stackfoonshow(const sender: tobject);
begin
 refresh;
end;

procedure tstackfo.formonchildscaled(const sender: TObject);
begin
 placeyorder(0,[0],[address,grid],0);
 aligny(wam_center,[address,filedisp]);
end;

procedure tstackfo.copytoclipboard(const sender: TObject);
var
 str1: string;
 int1: integer;
begin
 str1:= '';
 for int1:= 0 to grid.rowhigh do begin
  str1:= str1 + '#'+inttostr(int1)+'  '+grid[4][int1]+' '+
          filename(grid[2][int1])+':'+
                grid[3][int1]+' '+grid[1][int1]+lineend;
 end;
 gui_copytoclipboard(str1);
end;

end.
