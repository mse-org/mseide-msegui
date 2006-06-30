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
unit finddialogform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseforms,msesimplewidgets,msedataedits,msegraphedits,msetextedit,msestrings,
 msetypes,msestat,projectoptionsform;

type

 tfinddialogfo = class(tmseform)
   findtext: thistoryedit;
   casesensitive: tbooleanedit;
   statfile1: tstatfile;
   wholeword: tbooleanedit;
   selectedonly: tbooleanedit;
   ok: tbutton;
   cancel: tbutton;
  private
   procedure valuestoinfo(out info: findinfoty);
   procedure infotovalues(const info: findinfoty);
 end;

function finddialogexecute(var info: findinfoty): boolean;

implementation
uses
 msegui,finddialogform_mfm;

function finddialogexecute(var info: findinfoty): boolean;
var
 fo: tfinddialogfo;
begin
 fo:= tfinddialogfo.create(nil);
 try
  fo.infotovalues(info);
  result:= fo.show(true,nil) = mr_ok;
  if result then begin
   fo.valuestoinfo(info);
  end;
 finally
  fo.Free;
 end;
end;

{ tfinddialogfo }

procedure tfinddialogfo.valuestoinfo(out info: findinfoty);
begin
 with info do begin
  text:= findtext.value;
  history:= findtext.dropdown.valuelist.asarray;
  options:= encodesearchoptions(not casesensitive.value,wholeword.value);
  selectedonly:= self.selectedonly.value;
 end;
end;

procedure tfinddialogfo.infotovalues(const info: findinfoty);
begin
 with info do begin
  findtext.value:= text;
  findtext.dropdown.valuelist.asarray:= history;
  casesensitive.value:= not (so_caseinsensitive in options);
  wholeword.value:= so_wholeword in options;
//  self.selectedonly.value:= selectedonly;
 end;
end;

end.
