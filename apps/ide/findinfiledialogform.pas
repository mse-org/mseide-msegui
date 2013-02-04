{ MSEide Copyright (c) 1999-2011 by Martin Schreiber
   
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
unit findinfiledialogform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 finddialogform,findinfileform,mseforms,msedataedits,msesimplewidgets,
 msegraphedits,msefiledialog,msetypes,mseglob,mseguiglob,msegui,msestat,
 msestatfile,mseevent,msemenus,msesplitter,msegraphics,msegraphutils,msewidgets,
 msestrings;

type

 tfindinfiledialogfo = class(tmseform)
   findtext: thistoryedit;
   statfile1: tstatfile;
   dir: tfilenameedit;
   mask: thistoryedit;
   tlayouter1: tlayouter;
   indirectories: tbooleaneditradio;
   casesensitive: tbooleanedit;
   tlayouter2: tlayouter;
   wholeword: tbooleanedit;
   inopenfiles: tbooleaneditradio;
   tlayouter4: tlayouter;
   tlayouter3: tlayouter;
   ok: tbutton;
   cancel: tbutton;
   subdirs: tbooleanedit;
   procedure dironbeforeexecute(const sender: tfiledialogcontroller;
                   var dialogkind: filedialogkindty; var aresult: modalresultty);
   procedure dirshowhint(const sender: TObject; var info: hintinfoty);
   procedure chaindirectories(const sender: TObject);
   procedure chainopenfiles(const sender: TObject);
   procedure dirgetfilenameexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
  private
   procedure valuestoinfo(out info: findinfileinfoty);
   procedure infotovalues(const info: findinfileinfoty);
 end;

function findinfiledialogexecute(var info: findinfileinfoty;
                                        const useinfo: boolean): boolean;

implementation
uses
 msebits,findinfiledialogform_mfm,projectoptionsform;

function findinfiledialogexecute(var info: findinfileinfoty; const useinfo: boolean): boolean;
var
 fo: tfindinfiledialogfo;
begin
 fo:= tfindinfiledialogfo.create(nil);
 try
  if useinfo then begin
   fo.infotovalues(info);
  end;
  result:= fo.show(true,nil) = mr_ok;
  if result then begin
   fo.valuestoinfo(info);
  end;
 finally
  fo.Free;
 end;
end;

{ tfindinfiledialogfo }

procedure tfindinfiledialogfo.dironbeforeexecute(
  const sender: tfiledialogcontroller; var dialogkind: filedialogkindty;
  var aresult: modalresultty);
begin
 sender.filterlist.asarrayb:= mask.dropdown.valuelist.asarray;
 sender.filter:= mask.value;
end;
{
procedure tfindinfiledialogfo.infotovalues(const info: findinfileinfoty);
begin
 with info.findinfo do begin
  findtext.value:= text;
  findtext.dropdown.valuelist.asarray:= history;
  casesensitive.value:= not (so_caseinsensitive in options);
  wholeword.value:= so_wholeword in options;
 end;
 with info do begin
  indirectories.checkedtag:= ord(filesource);
  dir.value:= directory;
  dir.controller.history:= directoryhistory;
  mask.value:= filemask;
  mask.dropdown.valuelist.asarray:= filemaskhistory;
  subdirs.value:= fifo_subdirs in options;
 end;
end;
}
procedure tfindinfiledialogfo.valuestoinfo(out info: findinfileinfoty);
begin
 with info.findinfo do begin
  text:= findtext.value;
  history:= findtext.dropdown.valuelist.asarray;
  options:= encodesearchoptions(not casesensitive.value,wholeword.value);
 end;
 with info do begin
  directory:= dir.value;
  filemask:= mask.value;
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(options),ord(fifo_subdirs),subdirs.value);
  if inopenfiles.value then begin
   source:= fs_inopenfiles;
  end
  else begin
   source:= fs_indirectories;
  end;
 end;
end;

procedure tfindinfiledialogfo.infotovalues(const info: findinfileinfoty);
begin
 with info.findinfo do begin
  findtext.value:= text;
  findtext.dropdown.valuelist.asarray:= history;
  casesensitive.value:= not (so_caseinsensitive in options);
  wholeword.value:= so_wholeword in options;
 end;
 with info do begin
  dir.value:= directory;
  mask.value:= filemask;
  subdirs.value:= fifo_subdirs in options;
  if source = fs_inopenfiles then begin
   inopenfiles.value:= true;
  end
  else begin
   indirectories.value:= true;
  end;
 end;
end;

procedure tfindinfiledialogfo.dirshowhint(const sender: TObject;
               var info: hintinfoty);
begin
 hintmacros(tcustomstringedit(sender),info);
{
 if dir.editor.textclipped then begin
  info.caption:= dir.value;
 end;
}
end;

procedure tfindinfiledialogfo.chaindirectories(const sender: TObject);
begin
 if indirectories.value then begin
  inopenfiles.value:= false;
  dir.enabled:= true;
  mask.enabled:= true;
  subdirs.enabled:= true;
 end;
end;

procedure tfindinfiledialogfo.chainopenfiles(const sender: TObject);
begin
 if inopenfiles.value then begin
  indirectories.value:= false;
  dir.enabled:= false;
  mask.enabled:= false;
  subdirs.enabled:= false;
 end;
end;

procedure tfindinfiledialogfo.dirgetfilenameexe(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 expandprmacros1(avalue);
end;

end.
