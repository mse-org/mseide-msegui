{ MSEide Copyright (c) 2007-2014 by Martin Schreiber
   
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
 registerunitgroup(['msegui'],['msegraphics','msegraphutils']);
 registerunitgroup(['mseskin'],['mseclasses']);
 registerunitgroup(['mseedit'],['msegui','msemenus','mseguiglob','msegraphics','mseapplication','sysutils','msestat','msestatfile','msestrings','msestream']);
 registerunitgroup(['msetabs'],['msegui','msemenus','mseguiglob','msegraphics','msewidgets','msegraphutils','msedragglob','msescrollbar']);
 registerunitgroup(['msetoolbar'],['msegui','msemenus','mseguiglob','msegraphics','msewidgets']);
 registerunitgroup(['msedataedits'],['msegui','msemenus','mseguiglob','msegraphics','msestrings','mseedit','mseificomp','mseifiglob','mseglob','mseact','msetypes']);
 registerunitgroup(['msegraphedits'],['msegui','msemenus','mseguiglob','msegraphics','msescrollbar','msetypes','mseificomp','mseifiglob','mseglob']);
 registerunitgroup(['msesimplewidgets'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msegrids'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','msestrings']);
 registerunitgroup(['msewidgets'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['mseificomp'],['mseifiglob','mseglob','mseificompglob']);
 registerunitgroup(['mseactions'],['mseclasses']);
 registerunitgroup(['mseprocess'],['msepipestream']);
 registerunitgroup(['msemenuwidgets'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msewidgetgrid'],['msegui','msemenus','mseguiglob','msegraphics','msegrids','msetypes']);
 registerunitgroup(['mseforms'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewidgets','mseglob','mseevent','msestat','mseguiintf','mseapplication','msedragglob','msedock']);
 registerunitgroup(['msedock'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msedragglob']);
 registerunitgroup(['msesplitter'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedispwidgets'],['msegui','msemenus','mseguiglob','msegraphics','msestrings','mserichstring']);
 registerunitgroup(['mselistbrowser'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','msedatanodes','msestat','msegrids','msegraphutils']);
 registerunitgroup(['msefiledialog'],['msegui','msemenus','mseguiglob','msegraphics','mselistbrowser','msegrids','msestrings','msesys','msebitmap','mseglob','msedataedits','mseedit','msedatanodes']);
 registerunitgroup(['msedialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','mseglob','msetypes']);
 registerunitgroup(['msestringcontainer'],['msestrings']);
 registerunitgroup(['msecolordialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','msegraphutils']);
 registerunitgroup(['msememodialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msetextedit'],['msegui','msemenus','mseguiglob','msegraphics','mseedit','msestrings','mseeditglob','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msegui','msemenus','mseguiglob','msegraphics','mseedit','msestrings','msetextedit','mseeditglob','msegrids']);
 registerunitgroup(['msereport'],['msegui','msemenus','mseguiglob','msegraphics','msesplitter','mdb','mseifiglob','mserichstring','msestrings']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter','sysutils','msestrings']);
 registerunitgroup(['mseprocmonitorcomp'],['msesystypes']);
 registerunitgroup(['mserttistat'],['msestat']);
 registerunitgroup(['mseprinter'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit']);
 registerunitgroup(['mseimage'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedial'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msewindowwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msechart'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msepolygon'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msepickwidget'],['msegui','msemenus','mseguiglob','msegraphics','mseobjectpicker','msepointer','msetypes']);
 registerunitgroup(['msetraywidget'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedockpanelform'],['msestrings','msemenus']);
 registerunitgroup(['msechartedit'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msetypes']);
 registerunitgroup(['msebarcode'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['mseopenglwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['mseopenglcanvaswidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['mdb','mseifiglob']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['mseterminal'],['msegui','msemenus','mseguiglob','msegraphics','mseedit','msestrings']);
 registerunitgroup(['msedataimage'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msecalendardatetimeedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msefoldedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','msegrids']);
 registerunitgroup(['mserealsumedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','msetypes']);
 registerunitgroup(['mseguirttistat'],['mserttistat','msestat','msegui']);
 registerunitgroup(['mseguithreadcomp'],['msethreadcomp']);
 registerunitgroup(['msesignal'],['msetypes']);
 registerunitgroup(['msesigfft'],['msetypes','msesignal']);
 registerunitgroup(['msesiggui'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','msegraphedits','msedataedits','msestrings','mseedit','msegraphutils','msechartedit','msesignal']);
 registerunitgroup(['msesigfftgui'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msesignal','msesigfft']);
 registerunitgroup(['msesigmidi'],['msemidi','msedatamodules']);
 registerunitgroup(['mseaudio'],['msestrings']);
 registerunitgroup(['msesqldb'],['msedatabase','sysutils','msqldb','msebufdataset','mdb','msedb','msestrings']);
 registerunitgroup(['msedbedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','mselookupbuffer','msegraphedits','msetypes','msegrids','mdb']);
 registerunitgroup(['msesqlresult'],['msqldb','sysutils']);
 registerunitgroup(['msqldb'],['sysutils']);
 registerunitgroup(['msedbdispwidgets'],['msegui','msemenus','mseguiglob','msestrings']);
 registerunitgroup(['mseibconnection'],['msedatabase','sysutils']);
 registerunitgroup(['msefbconnection'],['msedatabase','sysutils']);
 registerunitgroup(['msefbservice'],['msestrings','sysutils']);
 registerunitgroup(['msepqconnection'],['msedatabase','sysutils']);
 registerunitgroup(['mseodbcconn'],['msedatabase','sysutils']);
 registerunitgroup(['mselocaldataset'],['msebufdataset','mdb','msedb']);
 registerunitgroup(['msedbgraphics'],['mdb','msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedbdialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','msegraphutils','mseglob','msetypes']);
 registerunitgroup(['msedbcalendardatetimeedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msedbevents'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysqlconn'],['msedatabase','sysutils']);
 registerunitgroup(['msedblookup'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings']);
 registerunitgroup(['mseifidbcomp'],['msesqlresult','msqldb','sysutils']);
 registerunitgroup(['mseifidialogcomp'],['mseapplication','mseglob']);
 registerunitgroup(['mseifigui'],['mseifi','mseifilink','mseifiglob','mseglob','msegui','msemenus','mseguiglob','msegraphics','msegrids','msetypes','mseforms']);
 registerunitgroup(['mseifiendpoint'],['msestrings']);
 registerunitgroup(['mseifi'],['msesercomm']);
 registerunitgroup(['mseifilink'],['mseifiglob','mseglob']);
 registerunitgroup(['msesockets'],['msesercomm','msesys']);
 registerunitgroup(['mseifids'],['mdb','msebufdataset','msedb','msesqldb','msestrings']);
 registerunitgroup(['mseifidbgui'],['msegui','msemenus','mseguiglob','msegraphics','msegrids','msetypes']);
 registerunitgroup(['msecommutils'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msestrings','mseedit','msecommport']);
 registerunitgroup(['msemysql40conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql41conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysql50conn'],['msedatabase','sysutils']);
 registerunitgroup(['msedbf'],['mdbf','dbf_idxfile','mdb']);
 registerunitgroup(['msesdfdata'],['mdb']);
 registerunitgroup(['msememds'],['mdb']);
end;

initialization
 reggroups;
end.
