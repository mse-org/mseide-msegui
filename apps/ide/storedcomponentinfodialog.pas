{ MSEide Copyright (c) 2008 by Martin Schreiber
   
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
unit storedcomponentinfodialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,componentstore,msesimplewidgets,
 msewidgets,msebitmap,msedataedits,msedatanodes,mseedit,msefiledialog,msegrids,
 mselistbrowser,msestrings,msesys,msetypes;
type
 tstoredcomponentinfodialogfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   filepath: tfilenameedit;
   compname: tstringedit;
   compdesc: tmemoedit;
   procedure doclosequery(const sender: tcustommseform;
                   var amodalresult: modalresultty);
   procedure namedataentered(const sender: TObject);
  private
   infopo: pstoredcomponentinfoty;
  public
   constructor create(var ainfo: storedcomponentinfoty); reintroduce;
   procedure checkfilename;
 end;
var
 storedcomponentinfodialogfo: tstoredcomponentinfodialogfo;
 
implementation
uses
 storedcomponentinfodialog_mfm,msefileutils;
 
{ tstoredcomponentinfodialogfo }

constructor tstoredcomponentinfodialogfo.create(var ainfo: storedcomponentinfoty);
begin
 infopo:= @ainfo;
 inherited create(nil);
 with ainfo do begin
  self.caption:= 'Store Component '+componentname+': '+compclass;
  self.compname.value:= compname;
  self.compdesc.value:= compdesc;
  self.filepath.value:= filepath;
 end;
end;

procedure tstoredcomponentinfodialogfo.doclosequery(const sender: tcustommseform;
               var amodalresult: modalresultty);
begin
 if amodalresult = mr_ok then begin
  with infopo^ do begin
   compname:= self.compname.value;
   compdesc:= self.compdesc.value;
   filepath:= self.filepath.value;
  end;
 end;
end;

procedure tstoredcomponentinfodialogfo.namedataentered(const sender: TObject);
begin
 checkfilename;
end;

procedure tstoredcomponentinfodialogfo.checkfilename;
begin
 if compname.value <> '' then begin
  filepath.value:= uniquefilename(filedir(filepath.value) +
                 replacechar(compname.value,' ','_') + '.cmp');
 end;
end;

end.
