{ MSEide Copyright (c) 1999-2010 by Martin Schreiber
   
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
 classes,msemenus;

type
 ttargetconsolefo = class(tdockform)
   terminal: tterminal;
   grid: twidgetgrid;
   tpopupmenu1: tpopupmenu;
   procedure tartgetconsoleonshow(const sender: TObject);
   procedure sendtext(const sender: tobject; var atext: msestring;
                                                 var donotsend: Boolean);
   procedure targetconsoleonidle(var again: Boolean);
   procedure clearexe(const sender: TObject);
  private
   fbuffer: tmsestringdatalist;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear;
   procedure addtext(const atext: string);
 end;
 
var
 targetconsolefo: ttargetconsolefo;
 
implementation
uses
 targetconsole_mfm,msegdbutils,main;

procedure ttargetconsolefo.tartgetconsoleonshow(const sender: TObject);
begin
// terminal.datalist.add('Target console is not working yet!');
end;

procedure ttargetconsolefo.sendtext(const sender: tobject;
                               var atext: msestring; var donotsend: Boolean);
begin
 mainfo.gdb.targetwriteln(atext);
 donotsend:= true;
end;

procedure ttargetconsolefo.clear;
begin
 grid.clear;
end;

procedure ttargetconsolefo.addtext(const atext: string);
begin
 fbuffer.addchars(atext);
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

end.
