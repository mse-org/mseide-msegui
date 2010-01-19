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

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 mseforms,msedataedits,msewidgetgrid,msegdbutils,msegraphedits,msedock,msegrids,
 msegui,msestrings,msemenus,mseedit,mseevent,msetypes,msegraphics,msebitmap;

type
 twatchfo = class(tdockform)
   grid: twidgetgrid;
   expression: tstringedit;
   expresult: tstringedit;
   gripopup: tpopupmenu;
   watchon: tbooleanedit;
   watcheson: tbooleanedit;
   sizecode: tintegeredit;
   formatcode: tdatabutton;
   timagelist1: timagelist;
   procedure expressionondataentered(const sender: tobject);
   procedure expresultonsetvalue(const sender: tobject; var avalue: msestring; var accept: boolean);
   procedure resultcellevent(const sender: TObject; var info: celleventinfoty);
   procedure watchesononchange(const sender: TObject);
   procedure watchesononsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
   procedure deletallexecute(const sender: TObject);
   procedure formatexecute(const sender: TObject);
   procedure popupdate(const sender: tcustommenu);
   procedure sizeexecute(const sender: TObject);
   procedure addwatchpoint(const sender: TObject);
   procedure addresswatch(const sender: TObject);
   procedure formatent(const sender: TObject);
   procedure resetformats(const sender: TObject);
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
 mseguiglob,mseformatstr,msebits,sysutils,watchpointsform,memoryform;
type
 numformatty = (nf_default,nf_bin,nf_decs,nf_decu,nf_hex);
 numsizety = (ns_default,ns_8,ns_16,ns_32,ns_64);
 
{ twatchfo }

procedure twatchfo.watchesononsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
 actionsmo.watchesonact.checked:= avalue;
end;

procedure twatchfo.resultcellevent(const sender: TObject; var info: celleventinfoty);
var
 rect1: rectty;
begin
{
 with info,expresult do begin
  if (eventkind = cek_firstmousepark) and textclipped(cell.row,rect1) then begin
   inc(rect1.cy,12);
   application.showhint(grid,gridvalue[cell.row],rect1,cp_bottomleft,-1);
  end;
 end;
 }
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
 fc: numformatty;
 fs: numsizety;
 int641: int64;
 int2: integer;
begin
 if (index >= 0) and gdb.cancommand then begin
  if watcheson.value and watchon[index] then begin
   gdb.readpascalvariable(expression[index],mstr1);
   fc:= numformatty(formatcode[index]);
   if fc <> nf_default then begin
    if trystrtointvalue64(mstr1,qword(int641)) then begin
     int2:= highestbit64(int641);
     if int2 <= 0 then begin
      int2:= 1;
     end;
     fs:= numsizety(sizecode[index]);
     case fc of
      nf_bin: begin
       int2:= int2+1; //bitcount
       case fs of 
        ns_8: int2:= 8; 
        ns_16: int2:= 16; 
        ns_32: int2:= 32; 
        ns_64: int2:= 64; 
       end;
       mstr1:= '%'+bintostr(qword(int641),int2);
      end;
      nf_decs: begin
       case fs of
        ns_8: mstr1:= inttostr(shortint(int641));
        ns_16: mstr1:= inttostr(smallint(int641));
        ns_32: mstr1:= inttostr(integer(int641));
        else mstr1:= inttostr(int641);
       end;
      end;
      nf_decu: begin
       mstr1:= inttostr(qword(int641));
      end;
      nf_hex: begin
       int2:= int2 div 4 + 1; //nibble count
       case fs of 
        ns_8: int2:= 2; 
        ns_16: int2:= 4; 
        ns_32: int2:= 8; 
        ns_64: int2:= 16; 
       end;
       mstr1:= '0x'+hextostr(qword(int641),int2);
      end;
     end;
    end;
   end;
   if (expresult[index] <> mstr1) then begin
    grid.rowfontstate[index]:= 0;
   end
   else begin
    grid.rowfontstate[index]:= -1;
   end;
   expresult[index]:= removelinebreaks(mstr1);
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
 memoryfo.refresh;
end;

procedure twatchfo.expresultonsetvalue(const sender: tobject; 
                     var avalue: msestring; var accept: boolean);
var
 str1: string;
begin
 gdb.interrupttarget;
 accept:= gdb.writepascalvariable(expression.value,avalue,str1) = gdb_ok;
 if accept then begin
  refresh;
  avalue:= str1;
 end
 else begin
  showerror(str1);
  tstringedit(sender).editor.undo;
 end;
 gdb.restarttarget;
end;

procedure twatchfo.addwatch(aexpression: msestring);
var
 int1: integer;
begin
 int1:= grid.appendrow;
 expression[int1]:= aexpression;
 if gdb.cancommand then begin
  refreshitem(int1);
 end;
end;

procedure twatchfo.deletallexecute(const sender: TObject);
begin
 if askok('Do you wish to delete all watches?','Confirmation') then begin
  grid.clear;
 end;
end;

procedure twatchfo.formatexecute(const sender: TObject);
var
 int1: integer;
begin
 with tmenuitem(sender) do begin
  int1:= checkedtag;
  if formatcode.value <> int1 then begin
   formatcode.value:= int1;
   refreshitem(grid.row);
  end;
 end;
end;

procedure twatchfo.formatent(const sender: TObject);
begin
 sizecode.value:= 0; //ns_default
 refreshitem(grid.row);
end;

procedure twatchfo.resetformats(const sender: TObject);
begin
 formatcode.fillcol(0);
 sizecode.fillcol(0);
 refresh; 
end;


procedure twatchfo.sizeexecute(const sender: TObject);
var
 int1: integer;
begin
 with tmenuitem(sender) do begin
  int1:= checkedtag;
  if sizecode.value <> int1 then begin
   sizecode.value:= int1;
   refreshitem(grid.row);
  end;
 end;
end;

procedure twatchfo.popupdate(const sender: tcustommenu);
begin
 sender.menu.itembyname('format').checkedtag:= formatcode.value;
 sender.menu.itembyname('size').checkedtag:= sizecode.value;
end;

procedure twatchfo.addwatchpoint(const sender: TObject);
begin
 watchpointsfo.addwatch(expression.value);
end;

procedure twatchfo.addresswatch(const sender: TObject);
//todo: make language independent
var
 str1: ansistring;
begin
 if gdb.symboladdress(expression.value,str1) = gdb_ok then begin
  str1:= '('+str1+'^)';
  case tmenuitem(sender).tag of
   0: begin
    str1:= 'byte'+str1;
   end;
   1: begin
    str1:= 'word'+str1;
   end;
   2: begin
    str1:= 'longword'+str1;
   end;
   3: begin
    str1:= 'qword'+str1;
   end;
  end;
  watchpointsfo.addwatch(str1);
 end
 else begin
  showerror(str1);
 end;
end;

end.
