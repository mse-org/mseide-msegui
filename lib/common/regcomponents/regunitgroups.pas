{ MSEide Copyright (c) 2007-2010 by Martin Schreiber
   
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
 registerunitgroup(['mseact'],['msestat','mseifiglob','mseglob']);
 registerunitgroup(['mseificomp'],['mseifiglob','mseglob','msestrings','msetypes','mseificompglob']);
 registerunitgroup(['msewidgets'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['mseactions'],['mseact','mseclasses']);
 registerunitgroup(['msemenuwidgets'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msefiledialog'],['msegui','msescrollbar','msemenus','mseguiglob','msegrids','msegraphics','msedatanodes','mselistbrowser','msegraphutils','msestrings','msesys','msebitmap','mseglob','mseedit','msedataedits']);
 registerunitgroup(['mseforms'],['msegui','msemenus','mseguiglob','msegraphutils','msewidgets','msegraphics','mseglob','mseevent','msestat','mseguiintf','msedock']);
 registerunitgroup(['msesimplewidgets'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msedispwidgets'],['msegui','msemenus','mseguiglob','msestrings','msetypes']);
 registerunitgroup(['msedataedits'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msetypes']);
 registerunitgroup(['msetoolbar'],['msegui','msemenus','mseguiglob','msewidgets','mseact']);
 registerunitgroup(['msegrids'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','msestrings']);
 registerunitgroup(['msetabs'],['msegui','msemenus','mseguiglob','msewidgets']);
 registerunitgroup(['msedock'],['msegui','msemenus','mseguiglob','msegraphutils']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter','sysutils']);
 registerunitgroup(['mseprocmonitorcomp'],['msesys']);
 registerunitgroup(['msesplitter'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['mseedit'],['msegui','msemenus','mseguiglob','msestrings']);
 registerunitgroup(['msewidgetgrid'],['msegui','msemenus','mseguiglob','msegrids','msegraphics','msetypes']);
 registerunitgroup(['mselistbrowser'],['msegui','msemenus','mseguiglob','msegrids','msestrings','mseedit','msedataedits','msedatanodes','msestat']);
 registerunitgroup(['msedialog'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','mseglob','msetypes']);
 registerunitgroup(['msegraphedits'],['msegui','msemenus','mseguiglob','msegraphics','msetypes']);
 registerunitgroup(['mseifi'],['msesockets']);
 registerunitgroup(['msesockets'],['msesys']);
 registerunitgroup(['msetextedit'],['msegui','msemenus','mseguiglob','msestrings','mseeditglob','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msegui','msemenus','mseguiglob','msestrings','msetextedit','mseeditglob','msegrids']);
 registerunitgroup(['msecolordialog'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','msegraphutils']);
 registerunitgroup(['msememodialog'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits']);
 registerunitgroup(['msereport'],['msegui','msemenus','mseguiglob','msesplitter','db','mserichstring','msegraphics','msestrings']);
 registerunitgroup(['mseprinter'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits']);
 registerunitgroup(['mseimage'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedial'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msewindowwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msechart'],['msegui','msemenus','mseguiglob','msegraphutils','msegraphics']);
 registerunitgroup(['msepolygon'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msepickwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msepointer','msetypes']);
 registerunitgroup(['msetraywidget'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['mseopenglwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['db']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['msedataimage'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msecalendardatetimeedit'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits']);
 registerunitgroup(['mseterminal'],['msegui','msemenus','mseguiglob','msestrings']);
 registerunitgroup(['msefoldedit'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','msegrids']);
 registerunitgroup(['mserealsumedit'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','msetypes']);
 registerunitgroup(['mseprocess'],['msepipestream']);
 registerunitgroup(['mseskin'],['mseclasses']);
 registerunitgroup(['mseguithreadcomp'],['msethreadcomp']);
 registerunitgroup(['msesqldb'],['msedatabase','sysutils','msqldb','msebufdataset','db','msedb']);
 registerunitgroup(['msedbedit'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','mselookupbuffer','msetypes','msegrids','msegraphics','db']);
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
 registerunitgroup(['mselocaldataset'],['msebufdataset','db','msedb']);
 registerunitgroup(['msedbdispwidgets'],['msegui','msemenus','mseguiglob','msestrings','msetypes']);
 registerunitgroup(['msedbgraphics'],['db','msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedbdialog'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','msegraphutils','mseglob','msetypes']);
 registerunitgroup(['msedbcalendardatetimeedit'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits']);
 registerunitgroup(['msedbevents'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysqlconn'],['msedatabase','sysutils']);
 registerunitgroup(['msedblookup'],['msegui','msemenus','mseguiglob','msestrings','msedataedits']);
 registerunitgroup(['mseifids'],['db','msebufdataset','msedb','msesqldb']);
 registerunitgroup(['mseifigui'],['mseifilink','mseifiglob','mseglob','msegui','msemenus','mseguiglob','msegrids','msetypes']);
 registerunitgroup(['mseifilink'],['mseifiglob','mseglob']);
 registerunitgroup(['mseifidbgui'],['msegui','msemenus','mseguiglob','msegrids','msetypes']);
 registerunitgroup(['ZSqlMetadata'],['db']);
 registerunitgroup(['ZSqlProcessor'],['sysutils']);
 registerunitgroup(['msezeos'],['db']);
 registerunitgroup(['msepascalscript'],['uPSComponent','uPSCompiler','uPSRuntime','uPSPreProcessor']);
 registerunitgroup(['msecommutils'],['msegui','msemenus','mseguiglob','msestrings','mseedit','msedataedits','msecommport']);

end;

initialization
 reggroups;
end.
