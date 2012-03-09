{ MSEide Copyright (c) 1999-2012 by Martin Schreiber
   
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
unit messageform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegrids,msemenus,msedataedits,msesimplewidgets;

type
 tmessagefo = class(tdockform)
   messages: tstringgrid;
   tpopupmenu1: tpopupmenu;
   procedure messagesoncellevent(const sender: tobject; var info: celleventinfoty);
   procedure copyexe(const sender: TObject);
 end;
var
 messagefo: tmessagefo;
implementation
uses
 messageform_mfm,sourcepage,sourceform,msewidgets,msestrings;
 
procedure tmessagefo.messagesoncellevent(const sender: tobject;
  var info: celleventinfoty);
var
 page: tsourcepage;
begin
 if (info.cell.row >= 0) and iscellclick(info,[ccr_dblclick]) then begin
  locateerrormessage(
    messagefo.messages[0].datalist.getparagraph(info.cell.row),page);
 end;
end;

procedure tmessagefo.copyexe(const sender: TObject);
begin
 copytoclipboard(messages.datacols[0].datalist.concatstring('',lineend));
end;

end.
