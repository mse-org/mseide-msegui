{ MSEide Copyright (c) 1999-2013 by Martin Schreiber

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

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msesimplewidgets,msedataedits,msegraphedits,msetextedit,msestrings,
 msetypes,msestat,msestatfile,projectoptionsform,mseglob,mseevent,msegui,
 msemenus,msesplitter,msegraphics,msegraphutils,msewidgets,mseguiglob,
 mseificomp,mseificompglob,mseifiglob,msescrollbar;

type

 tfinddialogfo = class(tmseform)
   findtext: thistoryedit;
   statfile1: tstatfile;
   ok: tbutton;
   tlayouter4: tlayouter;
   tlayouter3: tlayouter;
   wholeword: tbooleanedit;
   backward: tbooleanedit;
   tlayouter2: tlayouter;
   casesensitive: tbooleanedit;
   selectedonly: tbooleanedit;
   tlayouter1: tlayouter;
   tlayouter5: tlayouter;
   cancel: tbutton;
   tbutton2: tbutton;
  private
   procedure valuestoinfo(out info: findinfoty);
   procedure infotovalues(const info: findinfoty);
 end;

procedure updatefindvalues(const astatfiler: tstatfiler;
                                          var aoptions: findinfoty);
function finddialogexecute(var info: findinfoty): boolean;

implementation
uses
 finddialogform_mfm;

procedure updatefindvalues(const astatfiler: tstatfiler;
                                          var aoptions: findinfoty);
var
 int1: integer;
begin
 with astatfiler,aoptions do begin
  updatevalue('finddtext',text);
  updatevalue('findhistory',history);
  int1:= {$ifdef FPC}longword{$else}byte{$endif}(options);
  updatevalue('findoptions',int1);
  options:= searchoptionsty({$ifdef FPC}longword{$else}byte{$endif}(int1));
 end;
end;

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
  options:= encodesearchoptions(not casesensitive.value,wholeword.value,
                                                      false,backward.value);
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
  backward.value:= so_backward in options;
//  self.selectedonly.value:= selectedonly;
 end;
end;

end.
