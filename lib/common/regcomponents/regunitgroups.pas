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
 registerunitgroup(['msewidgets'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msemenuwidgets'],['msemenus','mseevent','msegui']);
 registerunitgroup(['mseactions'],['mseact']);
 registerunitgroup(['msefiledialog'],['msemenus','mseevent','msegui','mselistbrowser','msegrids','msesys','msebitmap','mseedit','msestrings','msedataedits']);
 registerunitgroup(['mseforms'],['msemenus','mseevent','msegui','mseglob','msegraphics','msestat']);
 registerunitgroup(['msesimplewidgets'],['msemenus','mseevent','msegui','msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msedispwidgets'],['msemenus','mseevent','msegui','msestrings','msetypes']);
 registerunitgroup(['msedataedits'],['msemenus','mseevent','msegui','mseedit','msestrings','msetypes']);
 registerunitgroup(['msetoolbar'],['msemenus','mseevent','msegui','msewidgets']);
 registerunitgroup(['msegrids'],['msemenus','mseevent','msegui','msetypes']);
 registerunitgroup(['msetabs'],['msemenus','mseevent','msegui','msewidgets']);
 registerunitgroup(['msedock'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter']);
 registerunitgroup(['msesplitter'],['msemenus','mseevent','msegui']);
 registerunitgroup(['mseedit'],['msemenus','mseevent','msegui','msestrings']);
 registerunitgroup(['msewidgetgrid'],['msemenus','mseevent','msegui','msegrids','msetypes']);
 registerunitgroup(['mselistbrowser'],['msemenus','mseevent','msegui','msegrids','mseedit','msestrings','msedataedits','msedatanodes']);
 registerunitgroup(['msedialog'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits','mseglob']);
 registerunitgroup(['msegraphedits'],['msemenus','mseevent','msegui','msegraphics','msetypes']);
 registerunitgroup(['msesockets'],['msesys']);
 registerunitgroup(['msetextedit'],['msemenus','mseevent','msegui','mseinplaceedit','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msemenus','mseevent','msegui','msetextedit','mseinplaceedit','msegrids']);
 registerunitgroup(['msecolordialog'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits','msegraphutils']);
 registerunitgroup(['msememodialog'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits']);
 registerunitgroup(['msereport'],['msemenus','mseevent','msegui','msesplitter','msegraphics','msestrings']);
 registerunitgroup(['mseprinter'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits']);
 registerunitgroup(['mseimage'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msedial'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msewindowwidget'],['msemenus','mseevent','msegui','msegraphics','msegraphutils']);
 registerunitgroup(['msechart'],['msemenus','mseevent','msegui','msegraphutils','msegraphics']);
 registerunitgroup(['mseopenglwidget'],['msemenus','mseevent','msegui','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['db']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['msedataimage'],['msemenus','mseevent','msegui']);
 registerunitgroup(['mseterminal'],['msemenus','mseevent','msegui','msestrings']);
 registerunitgroup(['mseskin'],['mseclasses']);
 registerunitgroup(['msesqldb'],['msqldb','sysutils','msebufdataset','db','msedb']);
 registerunitgroup(['msedbedit'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits','msedialog','mseglob','msetypes','msegrids']);
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
 registerunitgroup(['msedbdispwidgets'],['msemenus','mseevent','msegui','msestrings','msetypes']);
 registerunitgroup(['msedbgraphics'],['db','msemenus','mseevent','msegui']);
 registerunitgroup(['msedbdialog'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits','msegraphutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3ds'],['db']);
 registerunitgroup(['mseifids'],['db','msebufdataset','msedb','msesqldb']);
 registerunitgroup(['mseifigui'],['msemenus','mseevent','msegui','msegrids','msetypes']);
 registerunitgroup(['ZSqlMetadata'],['db']);
 registerunitgroup(['ZSqlProcessor'],['sysutils']);
 registerunitgroup(['msezeos'],['db']);
 registerunitgroup(['msepascalscript'],['uPSComponent','uPSCompiler','uPSRuntime','uPSPreProcessor']);
 registerunitgroup(['msecommutils'],['msemenus','mseevent','msegui','mseedit','msestrings','msedataedits','msecommport']);

end;

initialization
 reggroups;
end.
