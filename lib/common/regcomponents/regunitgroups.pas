unit regunitgroups;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf;
 
procedure reggroups;
begin
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
	['db','msedb','mseguiglob']);

registerunitgroup(['msedbedit'],
	['db','msedb','msetypes','msewidgetgrid','msegrids','msestrings','msescrollbar','msegraphics','msekeyboard']);

registerunitgroup(['msedbf'],
	['msestrings']);

registerunitgroup(['msedb'],
	['msetypes','db']);

registerunitgroup(['mseibconnection'],
	['db']);

registerunitgroup(['mselookupbuffer'],
	['msetypes','msestrings']);

registerunitgroup(['msememds'],
	['msedb']);

registerunitgroup(['msepqconnection'],
	['db']);

registerunitgroup(['msesdfdata'],
	['msestrings']);

registerunitgroup(['msesqldb'],
	['db']);

registerunitgroup(['msqldb'],
	['db']);

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
	['msegrids','msestat','msetypes','msegraphutils','mseevent','msebitmap','msewidgetgrid']);

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
	['msegraphutils','msegraphics','msestrings','mseevent','mseguiglob','msearrayprops','msekeyboard','msetypes']);

registerunitgroup(['mselist'],
	['msetypes']);

registerunitgroup(['msemenus'],
	['mseshapes','mseevent']);

registerunitgroup(['msemenuwidgets'],
	['msegraphutils','msegraphics','msemenus']);

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
	['msegraphics','msetypes','msegraphutils','msestrings','msestream']);

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
	['msegraphutils','msegraphics','msetypes']);

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
	['mseevent','msestatfile','msestat','mseguiglob','msegraphutils','msetypes']);

registerunitgroup(['msetoolbar'],
	['msestatfile','msegraphics','msestrings','mseshapes','mseevent']);
end;

initialization
 reggroups;
end.
