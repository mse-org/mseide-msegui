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
//to do: clean up and completing 
procedure reggroups;
begin
 registerunitgroup(['mseapplication'],['sysutils']);
 registerunitgroup(['msestatfile'],['msestat']);
 registerunitgroup(['msemenuwidgets'],['msemenus','mseevent','msegui']);
 registerunitgroup(['mseguiactions'],['mseactions']);
 registerunitgroup(['msefiledialog'],['msemenus','mseevent','msegui',
         'mselistbrowser','msegrids','mseedit','msestrings','msedataedits']);
 registerunitgroup(['mseforms'],['msemenus','mseevent','msegui','mseguiglob',
         'msegraphics','msestat']);
 registerunitgroup(['msesimplewidgets'],['msemenus','mseevent','msegui',
         'msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msedispwidgets'],['msemenus','mseevent','msegui',
         'msestrings','msetypes']);
 registerunitgroup(['msedataedits'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msetypes']);
 registerunitgroup(['msetoolbar'],['msemenus','mseevent','msegui','msewidgets']);
 registerunitgroup(['msegrids'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msetabs'],['msemenus','mseevent','msegui','msewidgets']);
 registerunitgroup(['msedock'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter']);
 registerunitgroup(['msesplitter'],['msemenus','mseevent','msegui']);
 registerunitgroup(['mseedit'],['msemenus','mseevent','msegui','msestrings']);
 registerunitgroup(['msewidgetgrid'],['msemenus','mseevent','msegui','msegrids']);
 registerunitgroup(['mselistbrowser'],['msemenus','mseevent','msegui','msegrids',
         'mseedit','msestrings','msedataedits','msedatanodes']);
 registerunitgroup(['msedialog'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msedataedits','mseguiglob']);
 registerunitgroup(['msegraphedits'],['msemenus','mseevent','msegui',
         'msegraphics','msetypes']);
 registerunitgroup(['msesockets'],['msesys']);
 registerunitgroup(['msetextedit'],['msemenus','mseevent','msegui',
         'mseinplaceedit','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msemenus','mseevent','msegui',
         'msetextedit','mseinplaceedit','msegrids']);
 registerunitgroup(['msecolordialog'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msedataedits','msegraphutils']);
 registerunitgroup(['msereport'],['msemenus','mseevent','msegui','msegraphics',
         'msestrings']);
 registerunitgroup(['mseprinter'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msedataedits']);
 registerunitgroup(['mseimage'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msedial'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msewindowwidget'],['msemenus','mseevent','msegui',
         'msegraphics','msegraphutils']);
 registerunitgroup(['msechart'],['msemenus','mseevent','msegui','msegraphutils',
         'msegraphics']);
 registerunitgroup(['mseopenglwidget'],['msemenus','mseevent','msegui',
         'msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['db']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['msedbgraphics'],['db','msemenus','mseevent','msegui']);
 registerunitgroup(['msedataimage'],['msemenus','mseevent','msegui']);
 registerunitgroup(['msedbdispwidgets'],['msemenus','mseevent','msegui',
         'msestrings','msetypes']);
 registerunitgroup(['msedbedit'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msedataedits','msedialog','mseguiglob','msetypes',
         'msegrids']);
 registerunitgroup(['mseterminal'],['msemenus','mseevent','msegui','msestrings']);
 registerunitgroup(['msesqldb'],['msqldb','sysutils','msebufdataset','db']);
 registerunitgroup(['msqldb'],['sysutils']);
 registerunitgroup(['msedbf'],['db','dbf','dbf_idxfile']);
 registerunitgroup(['msesdfdata'],['db']);
 registerunitgroup(['msememds'],['db']);
 registerunitgroup(['msedbdialog'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msedataedits']);
 registerunitgroup(['msesqlite3ds'],['db']);
 registerunitgroup(['ZSqlMetadata'],['db']);
 registerunitgroup(['ZSqlProcessor'],['sysutils']);
 registerunitgroup(['msezeos'],['db']);
 registerunitgroup(['msepascalscript'],['uPSComponent','uPSCompiler',
         'uPSRuntime','uPSPreProcessor']);
 registerunitgroup(['msecommutils'],['msemenus','mseevent','msegui','mseedit',
         'msestrings','msedataedits','msecommport']);

{
 registerunitgroup(['msegui'],['mseevent','msegraphics','msegraphutils',
   'mseclasses','msestrings','msetypes','sysutils']);
 registerunitgroup(['msemenus'],['msegui']);
 registerunitgroup(['msemenuwidgets'],['msemenus']);
 registerunitgroup(['mseforms'],['msegui','msemenus','msestat','msedock']);
 registerunitgroup(['msewidgets'],['msemenus']);
 registerunitgroup(['msesimplewidgets'],['msemenus','msewidgets']);
 registerunitgroup(['msedispwidgets'],['msewidgets']);
 registerunitgroup(['msetoolbar'],['msesimplewidgets']);
 registerunitgroup(['msegrids'],['msesimplewidgets']);
 registerunitgroup(['msetabs'],['msesimplewidgets']);
 registerunitgroup(['msedock'],['msesimplewidgets']);
 registerunitgroup(['msesplitter'],['msesimplewidgets']);
 registerunitgroup(['mseimage'],['msesimplewidgets']);
 registerunitgroup(['msedial'],['msesimplewidgets']);
 registerunitgroup(['msewindowwidget'],['msesimplewidgets']);
 registerunitgroup(['mseopenglwidget'],['msewindowwidget']);
 registerunitgroup(['msechart'],['msesimplewidgets']);
 registerunitgroup(['mseedit'],['msesimplewidgets']);
 registerunitgroup(['msedataedits'],['mseedit']);
 registerunitgroup(['msegrids'],['mseedit']);
 registerunitgroup(['msewidgetgrid'],['msegrids']);
 registerunitgroup(['mselistbrowser'],
             ['msesimplewidgets','msedatanodes','msegrids']);
 registerunitgroup(['msegraphedits'],['msesimplewidgets']);
 registerunitgroup(['msetextedit'],['msedataedits','msegrids','mseinplaceedit']);
 registerunitgroup(['msesyntaxedit'],['msetextedit']);
 registerunitgroup(['msedataimage'],['msesimplewidgets']);
 registerunitgroup(['mseterminal'],['msetextedit']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['mseprinter'],['msedataedits']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['msefiledialog'],['mselistbrowser','msedataedits']);
 registerunitgroup(['msecolordialog'],['msedataedits']);
 registerunitgroup(['msecommutils'],['msedataedits']);
 registerunitgroup(['msedb'],['db']);
 registerunitgroup(['msedbedit'],['msedataedits','msewidgetgrid']);
 registerunitgroup(['db'],['sysutils']);
 registerunitgroup(['msebufdataset'],['msedb']);
 registerunitgroup(['msqldb'],['msedatabase','msebufdataset']);
 registerunitgroup(['msesqldb'],['msqldb']);
 registerunitgroup(['msesqlresult'],['msqldb']);
 registerunitgroup(['msedatabase'],['sysutils']);
 registerunitgroup(['mseibconnection'],['msedatabase']);
 registerunitgroup(['msepqconnection'],['msedatabase']);
 registerunitgroup(['mseodbcconn'],['msedatabase']);
 registerunitgroup(['msesqlite3conn'],['msedatabase']);
 registerunitgroup(['msemysql50conn'],['msedatabase']);
 registerunitgroup(['msemysql40conn'],['msedatabase']);
 registerunitgroup(['msemysql41conn'],['msedatabase']);
 registerunitgroup(['msedbf'],['db','dbf','dbf_idxfile']);
 registerunitgroup(['msesdfdata'],['db']);
 registerunitgroup(['msesqlite3ds'],['db']);
 registerunitgroup(['msedbgraphics'],['msesimplewidgets']);
 registerunitgroup(['msedbdispwidgets'],['msedispwidgets']);
 registerunitgroup(['msereport'],['msedataedits','mserichstring']);
 registerunitgroup(['ZSqlMetadata'],['db']);
 registerunitgroup(['ZSqlProcessor'],['sysutils']);
 registerunitgroup(['msezeos'],['msedb']);
 }
end;

initialization
 reggroups;
end.
