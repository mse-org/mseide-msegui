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
unit replacedialogform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseguiglob,msegui,mseclasses,mseforms,msegraphedits,msedataedits,msesimplewidgets,
 msestat,msestatfile,mseglob,
 projectoptionsform;

type
 treplacedialogfo = class(tmseform)
   casesensitive: tbooleanedit;
   findtext: thistoryedit;
   replacetext: thistoryedit;
   selectedonly: tbooleanedit;
   statfile1: tstatfile;
   promptonreplace: tbooleanedit;
   tintegerbutton1: tbutton;
   tintegerbutton2: tbutton;
   tintegerbutton3: tbutton;
   wholeword: tbooleanedit;
  private
   procedure valuestoinfo(out info: replaceinfoty);
   procedure infotovalues(const info: replaceinfoty);
 end;
 
function replacedialogexecute(var info: replaceinfoty): modalresultty;

implementation
uses
 replacedialogform_mfm,msestrings;

function replacedialogexecute(var info: replaceinfoty): modalresultty;
var
 fo: treplacedialogfo;
begin
 fo:= treplacedialogfo.create(nil);
 try
  fo.infotovalues(info);
  result:= fo.show(true,nil);
  if result in [mr_ok,mr_all] then begin
   fo.valuestoinfo(info);
  end;
 finally
  fo.Free;
 end;
end;

{ treplacedialogfo }
 
procedure treplacedialogfo.valuestoinfo(out info: replaceinfoty);
begin
 with info.find do begin
  text:= findtext.value;
  history:= findtext.dropdown.valuelist.asarray;
  options:= encodesearchoptions(not casesensitive.value,wholeword.value);
  selectedonly:= self.selectedonly.value;
 end;
 info.prompt:= promptonreplace.value;
 info.replacetext:= replacetext.value;
end;

procedure treplacedialogfo.infotovalues(const info: replaceinfoty);
begin
 with info.find do begin
  findtext.value:= text;
  findtext.dropdown.valuelist.asarray:= history;
  casesensitive.value:= not (so_caseinsensitive in options);
  wholeword.value:= so_wholeword in options;
//  self.selectedonly.value:= selectedonly;
 end;
end;

end.
