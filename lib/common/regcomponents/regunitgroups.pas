{ MSEide Copyright (c) 2007-2013 by Martin Schreiber
   
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
 registerunitgroup(['msetabs'],['msegui','msemenus','mseguiglob','mseapplication','sysutils','msestat','msestatfile','msestrings','msestream','msewidgets','msegraphutils','msedragglob','msescrollbar']);
 registerunitgroup(['msetoolbar'],['msegui','msemenus','mseguiglob','msewidgets']);
 registerunitgroup(['msedataedits'],['msegui','msemenus','mseguiglob','msestrings','mseedit','mseificomp','mseifiglob','mseglob','msetypes']);
 registerunitgroup(['msegraphedits'],['msegui','msemenus','mseguiglob','msegraphics','msescrollbar','msetypes','mseificomp','mseifiglob','mseglob']);
 registerunitgroup(['msesimplewidgets'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewidgets']);
 registerunitgroup(['msegrids'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','msestrings']);
 registerunitgroup(['msewidgets'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['mseact'],['mseificomp','mseifiglob','mseglob']);
 registerunitgroup(['mseificomp'],['mseifiglob','mseglob','mseificompglob']);
 registerunitgroup(['mseactions'],['mseact','mseclasses']);
 registerunitgroup(['msemenuwidgets'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msewidgetgrid'],['msegui','msemenus','mseguiglob','msegrids','msegraphics','msetypes']);
 registerunitgroup(['mseforms'],['msegui','msemenus','mseguiglob','msegraphutils','msewidgets','msegraphics','mseglob','mseevent','msestat','mseguiintf','msedragglob','msedock']);
 registerunitgroup(['msedock'],['msegui','msemenus','mseguiglob','msegraphutils','msedragglob']);
 registerunitgroup(['msesplitter'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedispwidgets'],['msegui','msemenus','mseguiglob','msestrings','mserichstring']);
 registerunitgroup(['mselistbrowser'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msedatanodes','msestat','msegrids']);
 registerunitgroup(['msefiledialog'],['msegui','msemenus','mseguiglob','mselistbrowser','msegrids','msestrings','msesys','msebitmap','mseglob','msedataedits','mseedit']);
 registerunitgroup(['msedialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','mseglob','msetypes']);
 registerunitgroup(['msestringcontainer'],['msestrings']);
 registerunitgroup(['msecolordialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msegraphutils']);
 registerunitgroup(['msememodialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msetextedit'],['msegui','msemenus','mseguiglob','mseedit','msestrings','mseeditglob','msegrids']);
 registerunitgroup(['msesyntaxedit'],['msegui','msemenus','mseguiglob','mseedit','msestrings','msetextedit','mseeditglob','msegrids']);
 registerunitgroup(['msereport'],['msegui','msemenus','mseguiglob','msesplitter','mdb','mseifiglob','mserichstring','msegraphics','msestrings']);
 registerunitgroup(['msesysenv'],['msestrings']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter','sysutils']);
 registerunitgroup(['mseprocmonitorcomp'],['msesystypes']);
 registerunitgroup(['mserttistat'],['msestat']);
 registerunitgroup(['mseprocess'],['msepipestream']);
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
 registerunitgroup(['msebarcode'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['mseopenglwidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['mseopenglcanvaswidget'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewindowwidget']);
 registerunitgroup(['msedb'],['mdb','mseifiglob']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['mseterminal'],['msegui','msemenus','mseguiglob','mseedit','msestrings']);
 registerunitgroup(['msedataimage'],['msegui','msemenus','mseguiglob']);
 registerunitgroup(['msecalendardatetimeedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msefoldedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msegrids']);
 registerunitgroup(['mserealsumedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msetypes']);
 registerunitgroup(['mseguirttistat'],['mserttistat','msestat','msegui']);
 registerunitgroup(['mseguithreadcomp'],['msethreadcomp']);
 registerunitgroup(['msesignal'],['msetypes']);
 registerunitgroup(['msesigfft'],['msetypes','msesignal']);
 registerunitgroup(['msesiggui'],['msegui','msemenus','mseguiglob','msetypes','msedataedits','msestrings','mseedit','msegraphutils','msegraphics','msechartedit','msesignal']);
 registerunitgroup(['msesigfftgui'],['msegui','msemenus','mseguiglob','msegraphutils','msegraphics','msesignal','msesigfft']);
 registerunitgroup(['msesigmidi'],['msemidi','msedatamodules']);
 registerunitgroup(['mseaudio'],['msestrings']);
 registerunitgroup(['msesqldb'],['msedatabase','sysutils','msqldb','msebufdataset','mdb','msedb']);
 registerunitgroup(['msedbedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','mselookupbuffer','msegraphedits','msetypes','msegrids','msegraphics','mdb']);
 registerunitgroup(['msesqlresult'],['msqldb','sysutils']);
 registerunitgroup(['msqldb'],['sysutils']);
 registerunitgroup(['mseibconnection'],['msedatabase','sysutils']);
 registerunitgroup(['msepqconnection'],['msedatabase','sysutils']);
 registerunitgroup(['mseodbcconn'],['msedatabase','sysutils']);
 registerunitgroup(['mselocaldataset'],['msebufdataset','mdb','msedb']);
 registerunitgroup(['msedbdispwidgets'],['msegui','msemenus','mseguiglob','msestrings']);
 registerunitgroup(['msedbgraphics'],['mdb','msegui','msemenus','mseguiglob']);
 registerunitgroup(['msedbdialog'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msegraphutils','mseglob','msetypes']);
 registerunitgroup(['msedbcalendardatetimeedit'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit']);
 registerunitgroup(['msedbevents'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysqlconn'],['msedatabase','sysutils']);
 registerunitgroup(['msedblookup'],['msegui','msemenus','mseguiglob','msedataedits','msestrings']);
 registerunitgroup(['mseifidbcomp'],['msesqlresult','msqldb','sysutils']);
 registerunitgroup(['mseifidialogcomp'],['mseapplication','mseglob']);
 registerunitgroup(['mseifigui'],['mseifi','mseifilink','mseifiglob','mseglob','msegui','msemenus','mseguiglob','msegrids','msetypes','mseforms']);
 registerunitgroup(['mseifiendpoint'],['msestrings']);
 registerunitgroup(['mseifi'],['msesercomm']);
 registerunitgroup(['mseifilink'],['mseifiglob','mseglob']);
 registerunitgroup(['msesockets'],['msesercomm','msesys']);
 registerunitgroup(['mseifids'],['mdb','msebufdataset','msedb','msesqldb']);
 registerunitgroup(['mseifidbgui'],['msegui','msemenus','mseguiglob','msegrids','msetypes']);
 registerunitgroup(['msepascalscript'],['uPSComponent','uPSCompiler','uPSRuntime','uPSPreProcessor']);
 registerunitgroup(['msecommutils'],['msegui','msemenus','mseguiglob','msedataedits','msestrings','mseedit','msecommport']);
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
