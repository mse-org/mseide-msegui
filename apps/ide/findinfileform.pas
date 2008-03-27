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
unit findinfileform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 finddialogform,mseforms,msegrids,msethreadcomp,msesimplewidgets,
 msesysutils,msedispwidgets,msetypes,msestrings,msewidgetgrid,msetextedit,
 msestat,msetabs,projectoptionsform;

type

 filesourcety = (fs_indirectories,fs_inopenfiles);
 findinfileoptionty = (fifo_subdirs);
 findinfileoptionsty = set of findinfileoptionty;

 findinfileinfoty = record
  findinfo: findinfoty;
  options: findinfileoptionsty;
  directory: filenamety;
  filemask: msestring;
  resultlist: ttextedit;
 end;

 tfindinfilefo = class(tdockform)
   tabs: ttabwidget;
  private
  public
   procedure newsearch(const info: findinfileinfoty);
 end;

procedure dofindinfile;

var
 findinfilefo: tfindinfilefo;
 findinfileinfo: findinfileinfoty;

implementation
uses
 findinfiledialogform,main,findinfileform_mfm,msefileutils,msestream,
 msesys,msegui,sysutils,mserichstring,msegraphics,sourceform,sourcepage,
 findinfilepage,mseeditglob;

procedure dofindinfile;
begin
 if findinfiledialogexecute(findinfileinfo,false) then begin
  findinfilefo.newsearch(findinfileinfo);
  findinfilefo.activate;
 end;
end;

{ tfindinfilefo }

procedure tfindinfilefo.newsearch(const info: findinfileinfoty);
begin
 tabs.add(itabpage(tfindinfilepagefo.create(self,info)));
end;

end.
