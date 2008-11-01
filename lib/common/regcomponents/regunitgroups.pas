{ MSEide Copyright (c) 2007-2008 by Martin Schreiber
   
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
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 msedesignintf;
 
procedure reggroups;
begin
 registerunitgroup(['mseapplication'],['sysutils']);
 registerunitgroup(['msestatfile'],['msestat']);
 registerunitgroup(['msewidgets'],['msegui','msemenus','mseevent']);
 registerunitgroup(['msemenuwidgets'],['msegui','msemenus','mseevent']);
 registerunitgroup(['mseactions'],['mseact']);
 registerunitgroup(['msefiledialog'],['msegui','msemenus','mseevent','msegrids','msegraphics','msedatanodes','mselistbrowser','msegraphutils','msesys','msebitmap','msestrings','mseglob','mseedit','msedataedits']);
 registerunitgroup(['mseforms'],['msegui','msemenus','mseevent','msegraphutils','msewidgets','msegraphics','mseglob','msestat','msedock']);
 registerunitgroup(['msesimplewidgets'],['msegui','msemenus','mseevent','msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msedispwidgets'],['msegui','msemenus','mseevent','msestrings','msetypes']);
 registerunitgroup(['msedataedits'],['msegui','msemenus','mseevent','mseedit','msestrings','msetypes']);
 registerunitgroup(['msetoolbar'],['msegui','msemenus','mseevent','msewidgets','mseact']);
 registerunitgroup(['msegrids'],['msegui','msemenus','mseevent','msegraphics','msetypes','msestrings']);
 registerunitgroup(['msetabs'],['msegui','msemenus','mseevent','msewidgets']);
 registerunitgroup(['msedock'],['msegui','msemenus','mseevent','msegraphutils']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter']);
 registerunitgroup(['msesplitter'],['msegui','msemenus','mseevent']);
 registerunitgroup(['mseedit'],['msegui','msemenus','mseevent','msestrings']);
 registerunitgroup(['msewidgetgrid'],['msegui','msemenus','mseevent','msegrids','msegraphics','msetypes']);
 registerunitgroup(['mselistbrowser'],['msegui','msemenus','mseevent','msegrids','mseedit','msestrings','msedataedits','msedatanodes','msestat']);
 registerunitgroup(['msedialog'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits','mseglob']);
 registerunitgroup(['msegraphedits'],['msegui','msemenus','mseevent','msegraphics','msetypes']);
 registerunitgroup(['msetextedit'],['msegui','msemenus','mseevent','mseinplaceedit','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msegui','msemenus','mseevent','msetextedit','mseinplaceedit','msegrids']);
 registerunitgroup(['msecolordialog'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits','msegraphutils']);
 registerunitgroup(['msememodialog'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits']);
 registerunitgroup(['msereport'],['msegui','msemenus','mseevent','msesplitter','db','mserichstring','msegraphics','msestrings']);
 registerunitgroup(['mseprinter'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits']);
 registerunitgroup(['mseimage'],['msegui','msemenus','mseevent']);
 registerunitgroup(['msedial'],['msegui','msemenus','mseevent']);
 registerunitgroup(['msewindowwidget'],['msegui','msemenus','mseevent','msegraphics','msegraphutils']);
 registerunitgroup(['msechart'],['msegui','msemenus','mseevent','msegraphutils','msegraphics']);
 registerunitgroup(['msepolygon'],['msegui','msemenus','mseevent','msegraphics']);
 registerunitgroup(['msepickwidget'],['msegui','msemenus','mseevent','msegraphics','msegraphutils','mseguiglob','msepointer','msetypes']);
 registerunitgroup(['mseopenglwidget'],['msegui','msemenus','mseevent','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['db']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['msedataimage'],['msegui','msemenus','mseevent']);
 registerunitgroup(['mseterminal'],['msegui','msemenus','mseevent','msestrings']);
 registerunitgroup(['mseskin'],['mseclasses']);
 registerunitgroup(['mseguithreadcomp'],['msethreadcomp']);
 registerunitgroup(['msesqldb'],['msedatabase','sysutils','msqldb','msebufdataset','db','msedb']);
 registerunitgroup(['msedbedit'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits','msedialog','mseglob','msetypes','msegrids','msegraphics','db','mselookupbuffer']);
 registerunitgroup(['msqldb'],['sysutils']);
 registerunitgroup(['mseibconnection'],['msedatabase','sysutils']);
 registerunitgroup(['msepqconnection'],['msedatabase','sysutils']);
 registerunitgroup(['mseodbcconn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql40conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql41conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql50conn'],['msedatabase','sysutils']);
 registerunitgroup(['msedbf'],['dbf','dbf_idxfile','db']);
 registerunitgroup(['msesdfdata'],['db']);
 registerunitgroup(['msememds'],['db']);
 registerunitgroup(['msedbdispwidgets'],['msegui','msemenus','mseevent','msestrings','msetypes']);
 registerunitgroup(['msedbgraphics'],['db','msegui','msemenus','mseevent']);
 registerunitgroup(['msedbdialog'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits','msegraphutils']);
 registerunitgroup(['msedbevents'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msecommutils'],['msegui','msemenus','mseevent','mseedit','msestrings','msedataedits','msecommport']);

end;

initialization
 reggroups;
end.
