{ MSEide Copyright (c) 2007-2018 by Martin Schreiber
   
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
 registerunitgroup(['mseedit'],['msegui','msemenus','mseguiglob','msegraphics','mseapplication','sysutils','msestat','msestatfile','msetypes','msestream']);
 registerunitgroup(['msetabs'],['msegui','msemenus','mseguiglob','msegraphics','msewidgets','msegraphutils','msedragglob','msescrollbar']);
 registerunitgroup(['msetoolbar'],['msegui','msemenus','mseguiglob','msegraphics','msewidgets']);
 registerunitgroup(['msedataedits'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','mseedit','mseificomp','mseifiglob','mseglob','mseificompglob','mseact','msedropdownlist']);
 registerunitgroup(['msegraphedits'],['msegui','msemenus','mseguiglob','msegraphics','msescrollbar','msetypes','mseificomp','mseifiglob','mseglob','mseificompglob']);
 registerunitgroup(['msesimplewidgets'],['msegui','msemenus','mseguiglob','msegraphics','mseclasses','msegraphutils','msewidgets']);
 registerunitgroup(['msegrids'],['msegui','msemenus','mseguiglob','msegraphics','msedragglob','msetypes']);
 registerunitgroup(['msewidgets'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['mseificomp'],['mseifiglob','mseglob','mseificompglob']);
 registerunitgroup(['mseactions'],['mseclasses']);
 registerunitgroup(['mseprocess'],['msepipestream']);
 registerunitgroup(['msemenuwidgets'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msewidgetgrid'],['msegui','msemenus','mseguiglob','msegraphics','msegrids','msetypes']);
 registerunitgroup(['msedispwidgets'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','mserichstring']);
 registerunitgroup(['msesplitter'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['mseforms'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msewidgets','mseglob','mseevent','mseclasses','msestat','mseguiintf','mseapplication','msedragglob','msedock']);
 registerunitgroup(['msedock'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msedragglob']);
 registerunitgroup(['mselistbrowser'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','msedatanodes','msestat','msegrids','mseificomp','mseifiglob','mseglob']);
 registerunitgroup(['mseifigui'],['mseifi','mseifilink','mseifiglob','mseglob','msegui','msemenus','mseguiglob','msegraphics','msegrids','msetypes','mseapplication','mseforms']);
 registerunitgroup(['mseifi'],['msesercomm']);
 registerunitgroup(['mseifilink'],['mseifiglob','mseglob']);
 registerunitgroup(['msesockets'],['msesercomm','msesys']);
 registerunitgroup(['mserttistat'],['msestat']);
 registerunitgroup(['msefiledialog'],['msegui','msemenus','mseguiglob','msegraphics','mselistbrowser','msegrids','msetypes','msesys','msebitmap','mseglob','msedataedits','mseedit','msedatanodes']);
 registerunitgroup(['msedialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','mseglob']);
 registerunitgroup(['msestringcontainer'],['msetypes']);
 registerunitgroup(['msecolordialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','msegraphutils']);
 registerunitgroup(['msememodialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit']);
 registerunitgroup(['msetextedit'],['msegui','msemenus','mseguiglob','msegraphics','mseedit','msetypes','mseeditglob','msegrids','mserichstring']);
 registerunitgroup(['msesyntaxedit'],['msegui','msemenus','mseguiglob','msegraphics','mseedit','msetypes','msetextedit','mseeditglob','msegrids','mserichstring']);
 registerunitgroup(['msereport'],['msegui','msemenus','mseguiglob','msegraphics','msesplitter','mdb','mseifiglob','mserichstring','msetypes']);
 registerunitgroup(['msesysenv'],['msetypes']);
 registerunitgroup(['msepostscriptprinter'],['mseprinter','sysutils','msetypes']);
 registerunitgroup(['mseprocmonitorcomp'],['msesystypes']);
 registerunitgroup(['mseprinter'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit']);
 registerunitgroup(['mseimage'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedial'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msewindowwidget'],['msegui','msemenus','mseguiglob','msegraphics','mseclasses','msetypes','msegraphutils']);
 registerunitgroup(['msechart'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msepolygon'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils']);
 registerunitgroup(['msepickwidget'],['msegui','msemenus','mseguiglob','msegraphics','mseclasses','mseobjectpicker','msepointer','msetypes']);
 registerunitgroup(['msetraywidget'],['msegui','msemenus','mseguiglob','msegraphics','mseclasses']);
 registerunitgroup(['msedockpanelform'],['msetypes','msemenus','mseclasses']);
 registerunitgroup(['msechartedit'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msetypes']);
 registerunitgroup(['msebarcode'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['mseopenglwidget'],['msegui','msemenus','mseguiglob','msegraphics','mseclasses','msegraphutils','msewindowwidget','msetypes']);
 registerunitgroup(['mseopenglcanvaswidget'],['msegui','msemenus','mseguiglob','msegraphics','mseclasses','msegraphutils','msewindowwidget','msetypes']);
 registerunitgroup(['msedb'],['mdb','msetypes','mseifiglob']);
 registerunitgroup(['msegdiprint'],['mseprinter']);
 registerunitgroup(['mseterminal'],['msegui','msemenus','mseguiglob','msegraphics','mseedit','msetypes','msetextedit','mseeditglob','msegrids','mserichstring']);
 registerunitgroup(['msedataimage'],['msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msecalendardatetimeedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit']);
 registerunitgroup(['msefoldedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','msegrids']);
 registerunitgroup(['mserealsumedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit']);
 registerunitgroup(['mseguirttistat'],['mserttistat','msestat','msegui']);
 registerunitgroup(['mseassistivehandler'],['msespeak','mseassistiveclient','mseguiglob','msegrids','msegraphutils','msetypes','mseassistiveserver','mseact','mseshapes','msemenuwidgets','mdb']);
 registerunitgroup(['mseguithreadcomp'],['msethreadcomp']);
 registerunitgroup(['msesignal'],['msetypes']);
 registerunitgroup(['msesigfft'],['msetypes','msesignal']);
 registerunitgroup(['msesiggui'],['msegui','msemenus','mseguiglob','msegraphics','msetypes','msegraphedits','msedataedits','mseedit','msegraphutils','msechartedit','msesignal']);
 registerunitgroup(['msesigfftgui'],['msegui','msemenus','mseguiglob','msegraphics','msegraphutils','msesignal','msesigfft']);
 registerunitgroup(['msesigmidi'],['msemidi','msedatamodules']);
 registerunitgroup(['mseaudio'],['msetypes']);
 registerunitgroup(['msesqldb'],['msedatabase','sysutils','msqldb','msebufdataset','mdb','msedb','msetypes']);
 registerunitgroup(['msedbedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','mselookupbuffer','msegraphedits','msegrids','mdb']);
 registerunitgroup(['msesqlresult'],['msqldb','sysutils','mselookupbuffer']);
 registerunitgroup(['msqldb'],['sysutils']);
 registerunitgroup(['msedbdispwidgets'],['msegui','msemenus','mseguiglob','msegraphics','msetypes']);
 registerunitgroup(['mseibconnection'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['msefb3connection'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['msefbservice'],['msetypes','sysutils']);
 registerunitgroup(['msefb3service'],['msetypes','sysutils']);
 registerunitgroup(['msepqconnection'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['mseodbcconn'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['mselocaldataset'],['msebufdataset','mdb','msedb']);
 registerunitgroup(['msedbgraphics'],['mdb','msegui','msemenus','mseguiglob','msegraphics']);
 registerunitgroup(['msedbdialog'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','msegraphutils','mseglob']);
 registerunitgroup(['msedbcalendardatetimeedit'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit']);
 registerunitgroup(['msedbevents'],['msedatabase','sysutils']);
 registerunitgroup(['msesqlite3conn'],['msedatabase','sysutils']);
 registerunitgroup(['msemysqlconn'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['msedblookup'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes']);
 registerunitgroup(['mserepps'],['msegui','msemenus','mseguiglob','msegraphics','msereport']);
 registerunitgroup(['mseifidbcomp'],['msesqlresult','msqldb','sysutils']);
 registerunitgroup(['mseifiendpoint'],['msetypes']);
 registerunitgroup(['mseifids'],['mdb','msebufdataset','msedb','msesqldb','msetypes']);
 registerunitgroup(['mseifidbgui'],['msegui','msemenus','mseguiglob','msegraphics','msegrids','msetypes']);
 registerunitgroup(['msecommutils'],['msegui','msemenus','mseguiglob','msegraphics','msedataedits','msetypes','mseedit','msecommport']);
 registerunitgroup(['msemysql40conn'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['msemysql41conn'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['msemysql50conn'],['msedatabase','sysutils','msqldb','msetypes']);
 registerunitgroup(['msedbf'],['mdbf','dbf_idxfile','mdb']);
 registerunitgroup(['msesdfdata'],['mdb']);
 registerunitgroup(['msememds'],['mdb']);
end;

initialization
 reggroups;
end.
