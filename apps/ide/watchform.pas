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
unit watchform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 mseforms,msedataedits,msewidgetgrid,msegdbutils,msegraphedits,msedock,msegrids,
 msegui,msestrings,msemenus;

type
 twatchfo = class(tdockform)
   grid: twidgetgrid;
   expression: tstringedit;
   expresult: tstringedit;
   gripopup: tpopupmenu;
   watchon: tbooleanedit;
   watcheson: tbooleanedit;
   procedure expressionondataentered(const sender: tobject);
   procedure expresultonsetvalue(const sender: tobject; var avalue: msestring; var accept: boolean);
   procedure resultcellevent(const sender: TObject; var info: celleventinfoty);
   procedure watchesononchange(const sender: TObject);
   procedure watchesononsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
   procedure deletallexecute(const sender: TObject);
  public
   gdb: tgdbmi;
   procedure clear(const all: boolean = false);
   procedure refresh;
   procedure refreshitem(const index: integer);
   procedure addwatch(aexpression: msestring);
 end;

var
 watchfo: twatchfo;


implementation
uses
 watchform_mfm,main,msewidgets,projectoptionsform,actionsmodule,msegraphutils,
 mseguiglob;

{ twatchfo }

procedure twatchfo.watchesononsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
 actionsmo.watchesonact.checked:= avalue;
end;

procedure twatchfo.resultcellevent(const sender: TObject; var info: celleventinfoty);
var
 rect1: rectty;
begin
 with info,expresult do begin
  if (eventkind = cek_firstmousepark) and textclipped(cell.row,rect1) then begin
   inc(rect1.cy,12);
   application.showhint(expresult,gridvalue[cell.row],rect1,cp_bottomleft,-1);
  end;
 end;
end;

procedure twatchfo.watchesononchange(const sender: TObject);
begin
 projectoptions.modified:= true;
 refresh;
end;

procedure twatchfo.expressionondataentered(const sender: tobject);
begin
 projectoptions.modified:= true;
 refreshitem(grid.row);
end;

procedure twatchfo.clear(const all: boolean = false);
begin
 if all then begin
  grid.clear;
 end
 else begin
  expresult.fillcol('');
 end;
end;

procedure twatchfo.refreshitem(const index: integer);
var
 mstr1: msestring;
begin
 if gdb.active then begin
  if watcheson.value and watchon[index] then begin
   gdb.readpascalvariable(expression[index],mstr1);
   if (expresult[index] <> mstr1) then begin
    grid.rowfontstate[index]:= 0;
   end
   else begin
    grid.rowfontstate[index]:= -1;
   end;
   expresult[index]:= mstr1;
  end
  else begin
   grid.rowfontstate[index]:= -1;
   expresult[index]:= '<disabled>';
  end;
 end
 else begin
  expresult[index]:= '';
 end;
end;

procedure twatchfo.refresh;
var
 int1: integer;
begin
 for int1:= 0 to grid.rowcount -1 do begin
  refreshitem(int1);
 end;
end;

procedure twatchfo.expresultonsetvalue(const sender: tobject; var avalue: msestring; var accept: boolean);
var
 str1: string;
begin
 accept:= gdb.writepascalvariable(expression.value,avalue,str1) = gdb_ok;
 if accept then begin
  avalue:= str1;
 end
 else begin
  showerror(str1);
 end;
end;

procedure twatchfo.addwatch(aexpression: msestring);
var
 int1: integer;
begin
 int1:= grid.appendrow;
 expression[int1]:= aexpression;
 if gdb.active then begin
  refreshitem(int1);
 end;
end;

procedure twatchfo.deletallexecute(const sender: TObject);
begin
 if askok('Do you wish to delete all watches?','Confirmation') then begin
  grid.clear;
 end;
end;

end.
