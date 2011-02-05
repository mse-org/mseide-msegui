{ MSEide Copyright (c) 2007-2011 by Martin Schreiber
   
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
 registerunitgroup(['mseskin'],['mseclasses']);
 registerunitgroup(['mseedit'],['msegui','msemenus','mseguiglob','msestrings']);
 registerunitgroup(['msetabs'],['msegui','msemenus','mseguiglob','mseapplication','sysutils','msestat','msewidgets','msegraphutils','msescrollbar']);
 registerunitgroup(['msetoolbar'],['msegui','msemenus','mseguiglob','msewidgets','mseact']);
 registerunitgroup(['msedataedits'],['msegui','msemenus','mseguiglob','msestrings','mseedit','mseifiglob','mseglob','msetypes']);
 registerunitgroup(['msegraphedits'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','mseifiglob','mseglob']);
 registerunitgroup(['msesimplewidgets'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msegrids'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','msestrings']);
 registerunitgroup(['msewidgets'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['mseact'],['mseifiglob','mseglob']);
 registerunitgroup(['mseificomp'],['mseifiglob','mseglob','mseificompglob']);
 registerunitgroup(['mseactions'],['mseact','mseclasses']);
 registerunitgroup(['msemenuwidgets'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msewidgetgrid'],['msegui','msemenus','mseguiglob','msegrids','msegraphics','msetypes']);
 registerunitgroup(['mseforms'],['msegui','msemenus','mseguiglob','msegraphutils','msewidgets','msegraphics','mseglob','mseevent','msestat','mseguiintf','msedock']);
 registerunitgroup(['msedock'],['msegui','msemenus','mseguiglob','msegraphutils']);
 registerunitgroup(['msesplitter'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedispwidgets'],['msegui','msemenus','mseguiglob','msestrings','msetypes']);
 registerunitgroup(['mselistbrowser'],['msegui','msemenus','mseguiglob','msedatanodes','msegrids','msestrings','msedataedits','mseedit','msestat']);
 registerunitgroup(['msefiledialog'],['msegui','msemenus','mseguiglob','mselistbrowser','msegrids','msestrings','msesys','msebitmap','mseglob','msedataedits','mseedit']);
 registerunitgroup(['msedialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','mseglob','msetypes','msefileutils']);
 registerunitgroup(['msecolordialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msegraphutils']);
 registerunitgroup(['msememodialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msetextedit'],['msegui','msemenus','mseguiglob','mseedit','msestrings','mseeditglob','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msegui','msemenus','mseguiglob','mseedit','msestrings','msetextedit','mseeditglob','msegrids']);
 registerunitgroup(['msereport'],['msegui','msemenus','mseguiglob','msesplitter','db','mserichstring','msegraphics','msestrings']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter','sysutils']);
 registerunitgroup(['mseprocmonitorcomp'],['msesys']);
 registerunitgroup(['mserttistat'],['msestat']);
 registerunitgroup(['mseprinter'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['mseimage'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedial'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msewindowwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msechart'],['msegui','msemenus','mseguiglob','msegraphutils','msegraphics']);
 registerunitgroup(['msepolygon'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msepickwidget'],['msegui','msemenus','mseguiglob','msegraphics','mseobjectpicker','msepointer','msetypes']);
 registerunitgroup(['msetraywidget'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedockpanelform'],['msestrings','msemenus']);
 registerunitgroup(['msechartedit'],['msegui','msemenus','mseguiglob','msegraphutils','msegraphics','msetypes']);
 registerunitgroup(['mseopenglwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['db']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['msedataimage'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msecalendardatetimeedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['mseterminal'],['msegui','msemenus','mseguiglob','mseedit','msestrings']);
 registerunitgroup(['msefoldedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msegrids']);
 registerunitgroup(['mserealsumedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msetypes']);
 registerunitgroup(['mseprocess'],['msepipestream']);
 registerunitgroup(['mseguithreadcomp'],['msethreadcomp']);
 registerunitgroup(['msesignal'],['msetypes']);
 registerunitgroup(['msesigfft'],['msetypes','msesignal']);
 registerunitgroup(['msesiggui'],['msegui','msemenus','mseguiglob','msetypes','msedataedits','msestrings','mseedit','msegraphutils','msegraphics','msesignal']);
 registerunitgroup(['msesigfftgui'],['msegui','msemenus','mseguiglob','msegraphutils','msegraphics','msesignal','msesigfft']);
 registerunitgroup(['msesigmidi'],['msemidi','msedatamodules']);
 registerunitgroup(['msesockets'],['msesys']);
 registerunitgroup(['mseaudio'],['msestrings']);
 registerunitgroup(['msesqldb'],['msedatabase','sysutils','msqldb','msebufdataset','db','msedb']);
 registerunitgroup(['msedbedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','mselookupbuffer','msetypes','msegrids','msegraphics','db']);
 registerunitgroup(['msqldb'],['sysutils']);
 registerunitgroup(['mseibconnection'],['msedatabase','sysutils']);
 registerunitgroup(['msepqconnection'],['msedatabase','sysutils']);
 registerunitgroup(['mseodbcconn'],['msedatabase','sysutils']);
 registerunitgroup(['msedbf'],['dbf','dbf_idxfile','db']);
 registerunitgroup(['msesdfdata'],['db']);
 registerunitgroup(['msememds'],['db']);
 registerunitgroup(['mselocaldataset'],['msebufdataset','db','msedb']);
 registerunitgroup(['msedbdispwidgets'],['msegui','msemenus','mseguiglob','msestrings','msetypes']);
 registerunitgroup(['msedbgraphics'],['db','msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedbdialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msegraphutils','mseglob','msetypes']);
 registerunitgroup(['msedbcalendardatetimeedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msedbevents'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysqlconn'],['msedatabase','sysutils']);
 registerunitgroup(['msedblookup'],['msegui','msemenus','mseguiglob','msedataedits','msestrings']);
 registerunitgroup(['msesqlite3ds'],['db']);
 registerunitgroup(['mseifidbcomp'],['msesqlresult']);
 registerunitgroup(['mseifids'],['db','msebufdataset','msedb','msesqldb']);
 registerunitgroup(['mseifigui'],['mseifilink','mseifiglob','mseglob','msegui','msemenus','mseguiglob','msegrids','msetypes']);
 registerunitgroup(['mseifilink'],['mseifiglob','mseglob']);
 registerunitgroup(['mseifidbgui'],['msegui','msemenus','mseguiglob','msegrids','msetypes']);
 registerunitgroup(['msepascalscript'],['uPSComponent','uPSCompiler','uPSRuntime','uPSPreProcessor']);
 registerunitgroup(['msecommutils'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msecommport']);
 registerunitgroup(['msesercomm'],['msesockets']);
 registerunitgroup(['msemysql40conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql41conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql50conn'],['msedatabase','sysutils']);
end;

initialization
 reggroups;
end.
