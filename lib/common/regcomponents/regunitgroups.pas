{ MSEide Copyright (c) 2007 by Martin Schreiber
   
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
unit regunitgroups;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf;
 
procedure reggroups;
begin

registerunitgroup(['mbufdataset'],
	['db']);

registerunitgroup(['memds'],
	['db']);

registerunitgroup(['mibconnection'],
	['msqldb','ibase60dyn','db','msedbevents']);

registerunitgroup(['mmysql40conn'],
	['msqldb','db']);

registerunitgroup(['mmysql41conn'],
	['msqldb','db']);

registerunitgroup(['mmysql50conn'],
	['msqldb','db']);

registerunitgroup(['modbcconn'],
	['msqldb','db']);

registerunitgroup(['mpqconnection'],
	['msqldb']);

registerunitgroup(['msebufdataset'],
	['msestrings','db']);

registerunitgroup(['msedbdialog'],
	['db','msegrids']);

registerunitgroup(['msedbdispwidgets'],
	['msedb','msetypes','mseguiglob','db']);

registerunitgroup(['msedbedit'],
	['db','msetypes','msewidgetgrid','msegrids','msedb','msestrings','mseguiglob','msescrollbar','mseeditglob','mseinplaceedit','msekeyboard']);

registerunitgroup(['msedbf'],
	['msestrings','msedb']);

registerunitgroup(['msedbgraphics'],
	['msebitmap','msebintree']);

registerunitgroup(['msedb'],
	['msetypes','db','msestrings']);

registerunitgroup(['mseibconnection'],
	['db']);

registerunitgroup(['mselookupbuffer'],
	['msetypes','msestrings']);

registerunitgroup(['msememds'],
	['msedb']);

registerunitgroup(['msesdfdata'],
	['msestrings','msedb','db']);

registerunitgroup(['msesqldb'],
	['db','msedb']);

registerunitgroup(['msesqlite3conn'],
	['msqldb','db']);

registerunitgroup(['msesqlite3ds'],
	['msedb','db']);

registerunitgroup(['msqldb'],
	['db','msedb']);

registerunitgroup(['msecolordialog'],
	['msegraphics']);

registerunitgroup(['msefiledialog'],
	['msedatanodes','msestrings','msetypes','msestat']);

registerunitgroup(['msepopupcalendar'],
	['mseinplaceedit']);

registerunitgroup(['msedataedits'],
	['msestatfile','msestrings','msewidgetgrid','msestat','mseinplaceedit','msetypes','msedropdownlist','mseformatstr','msedatalist','mseevent']);

registerunitgroup(['msedatanodes'],
	['msestrings','msegraphutils','msegraphics','mseinplaceedit','msestat']);

registerunitgroup(['msedropdownlist'],
	['msegrids','msekeyboard','mseguiglob','mseevent']);

registerunitgroup(['mseedit'],
	['msegraphutils','mseeditglob']);

registerunitgroup(['msegraphedits'],
	['msetypes','msegraphics','msegraphutils','mseevent','msestat','msebitmap','msewidgetgrid']);

registerunitgroup(['mselistbrowser'],
	['msetypes','msedatanodes','msegrids','mseevent','msegraphics','mseinplaceedit']);

registerunitgroup(['mseterminal'],
	['msestrings','mseevent']);

registerunitgroup(['msetextedit'],
	['msestrings','mserichstring','msearrayprops','msegrids','msegraphics','msetypes']);

registerunitgroup(['msewidgetgrid'],
	['msegrids','msegraphics','msedatalist','mseevent']);

registerunitgroup(['mseformatbmpico'],
	['msebitmap']);

registerunitgroup(['msegraphicstream'],
	['msebitmap']);

registerunitgroup(['mseactions'],
	['mseshapes']);

registerunitgroup(['msearrayprops'],
	['msetypes','msegraphics','msestrings','mseguiglob']);

registerunitgroup(['msebitmap'],
	['msegraphics','msegraphutils']);

registerunitgroup(['mseclasses'],
	['msestrings','msetypes','mseguiglob','typinfo']);

registerunitgroup(['msedatalist'],
	['msestrings','msetypes']);

registerunitgroup(['msedrag'],
	['msegraphutils']);

registerunitgroup(['msedrawtext'],
	['msegraphutils','msegraphics']);

registerunitgroup(['msefileutils'],
	['msesys']);

registerunitgroup(['mseformatstr'],
	['msestrings']);

registerunitgroup(['msegraphics'],
	['msegraphutils']);

registerunitgroup(['msegui'],
	['msegraphutils','msegraphics','msestrings','mseevent','mseguiglob','msearrayprops','msetypes']);

registerunitgroup(['mselist'],
	['msetypes']);

registerunitgroup(['msemenus'],
	['mseshapes','mseevent']);

registerunitgroup(['msemenuwidgets'],
	['msegraphutils','msegraphics','mseevent','msemenus']);

registerunitgroup(['msepointer'],
	['msetypes','msegraphutils']);

registerunitgroup(['msepostscriptprinter'],
	['msegraphics','mserichstring','msegraphutils','msetypes']);

registerunitgroup(['mseprinter'],
	['msestream','msestatfile','mserichstring','msestrings','msegraphutils']);

registerunitgroup(['msereal'],
	['msetypes']);

registerunitgroup(['mserichstring'],
	['msetypes','msestrings']);

registerunitgroup(['msescrollbar'],
	['msetypes']);

registerunitgroup(['mseshapes'],
	['msegraphics','mseevent','mseguiglob']);

registerunitgroup(['msestatfile'],
	['msestat','msestrings']);

registerunitgroup(['msestat'],
	['msetypes','msestream','msestrings']);

registerunitgroup(['msestockobjects'],
	['msegraphics']);

registerunitgroup(['msestream'],
	['msesys']);

registerunitgroup(['msewidgets'],
	['msestrings','msegraphics','mseguiglob','msetypes','msescrollbar','msegraphutils','mseevent']);

registerunitgroup(['msereport'],
	['mserichstring','msegraphics','msetypes','msegraphutils','db','msestrings',
  'msestream']);

registerunitgroup(['msecommport'],
	['msethread']);

registerunitgroup(['mseprocutils'],
	['msepipestream']);

registerunitgroup(['msesysenv'],
	['msestrings']);

registerunitgroup(['msedial'],
	['msegraphics']);

registerunitgroup(['msedispwidgets'],
	['msetypes']);

registerunitgroup(['msedock'],
	['mseguiglob','msestat','msegraphutils']);

registerunitgroup(['mseeditglob'],
	['msetypes']);

registerunitgroup(['mseforms'],
	['msestrings','mseevent','msedock','msestat']);

registerunitgroup(['msegrids'],
	['mseevent','msegraphics','mseguiglob','msegraphutils','msetypes','msestat','msedatalist','msepipestream','msedrawtext','msestrings']);

registerunitgroup(['mseimage'],
	['msebitmap','msegraphics']);

registerunitgroup(['mseinplaceedit'],
	['msestrings','msegraphutils','msetypes']);

registerunitgroup(['mseobjectpicker'],
	['mseguiglob','msegraphutils']);

registerunitgroup(['msesimplewidgets'],
	['msegraphics','msestrings','mseevent','msedrawtext','msewidgets']);

registerunitgroup(['msesplitter'],
	['msestatfile','msegraphics','msepointer','msetypes']);

registerunitgroup(['msetabs'],
	['msetabsglob','mseevent','msestatfile','msestat','msegraphutils','msetypes']);

registerunitgroup(['msetoolbar'],
	['msestatfile','msegraphics','msestrings','mseshapes','mseevent']);

registerunitgroup(['msewindowwidget'],
	['msetypes']);
end;

initialization
 reggroups;
end.
