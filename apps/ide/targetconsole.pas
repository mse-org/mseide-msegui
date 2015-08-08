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
unit targetconsole;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,mseterminal,msewidgetgrid,msestrings,msedatalist,
 classes,mclasses,msemenus,msestat,msetypes;

type
 ttargetconsolefo = class(tdockform)
   terminal: tterminal;
   grid: twidgetgrid;
   popupmen: tpopupmenu;
   procedure sendtext(const sender: tobject; var atext: msestring;
                                                 var donotsend: Boolean);
   procedure targetconsoleonidle(var again: Boolean);
   procedure clearexe(const sender: TObject);
   procedure popupupdateexe(const sender: tcustommenu);
  private
   fbuffer: tmsestringdatalist;
   ffindpos: gridcoordty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear;
   procedure addtext(const atext: string);
   procedure dofind;
   procedure repeatfind;
 end;
 
var
 targetconsolefo: ttargetconsolefo;

procedure updatestat(const statfiler: tstatfiler);
 
implementation
uses
 targetconsole_mfm,msegdbutils,main,finddialogform,projectoptionsform,
 actionsmodule,sourcepage;

procedure updatestat(const statfiler: tstatfiler);
begin
 updatefindvalues(statfiler,projectoptions.targetconsolefindinfo);
end;

procedure ttargetconsolefo.sendtext(const sender: tobject;
                               var atext: msestring; var donotsend: Boolean);
begin
 mainfo.gdb.targetwriteln(ansistring(atext));
 donotsend:= true;
 terminal.inputcolindex:= length(terminal.text);
 terminal.addline('');
end;

procedure ttargetconsolefo.clear;
begin
 grid.clear;
end;

procedure ttargetconsolefo.addtext(const atext: string);
begin
 fbuffer.addchars(msestring(atext));
end;

constructor ttargetconsolefo.create(aowner: tcomponent);
begin
 fbuffer:= tmsestringdatalist.create;
 fbuffer.maxcount:= 600;
 inherited create(aowner);
end;

destructor ttargetconsolefo.destroy;
begin
 inherited;
 fbuffer.free;
end;

procedure ttargetconsolefo.targetconsoleonidle(var again: Boolean);
var
 int1: integer;
begin
 if fbuffer.count > 0 then begin
  terminal.beginupdate;
  try
   for int1:= 0 to fbuffer.count - 2 do begin
    terminal.addchars(fbuffer[int1]+lineend);
   end;
   terminal.addchars(fbuffer[fbuffer.count-1]);
   fbuffer.clear;
  finally
   terminal.endupdate;
  end;
 end;
end;

procedure ttargetconsolefo.clearexe(const sender: TObject);
begin
 grid.clear;
end;

procedure ttargetconsolefo.dofind;
var
 ainfo: findinfoty;
begin
 ainfo:= projectoptions.targetconsolefindinfo;
 if not terminal.hasselection then begin
  ainfo.selectedonly:= false;
 end;
// ainfo.text:= edit.selectedtext;
 if finddialogexecute(ainfo) then begin
  projectoptions.targetconsolefindinfo:= ainfo;
  findintextedit(terminal,projectoptions.targetconsolefindinfo,ffindpos);
 end;
end;

procedure ttargetconsolefo.repeatfind;
begin
 findintextedit(terminal,projectoptions.targetconsolefindinfo,ffindpos);
end;

procedure ttargetconsolefo.popupupdateexe(const sender: tcustommenu);
begin
 with actionsmo do begin
  find.enabled:= true;
  repeatfind.enabled:= true;
 end;
end;

end.
