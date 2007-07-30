unit regzeoslib;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 Classes,msedesignintf,ZDataset,ZConnection,ZSqlUpdate,ZStoredProcedure,ZSqlMetadata,
 ZSqlProcessor,ZSqlMonitor,ZSequence,msezeos,regzeoslib_bmp,regdb,
 msepropertyeditors,ZSqlStrings,ZAbstractRODataset,msegui,msedb,msestrings;
 
type
 tzprotocolpropertyeditor = class(tstringpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   function getvalues: msestringarty; override;
 end;
 
 tzquerysqlpropertyeditor = class(tsqlpropertyeditor)
  private
   factivebefore: boolean;
  protected
   procedure doafterclosequery(var amodalresult: modalresultty); override;
   function gettestbutton: boolean; override;
   function getutf8: boolean; override;
  public
   procedure edit; override;
 end;
 
 tzreadonlyquerysqlpropertyeditor = class(tsqlpropertyeditor)
  private
   factivebefore: boolean;
  protected
   procedure doafterclosequery(var amodalresult: modalresultty); override;
   function gettestbutton: boolean; override;
   function getutf8: boolean; override;
  public
   procedure edit; override;
 end;
 
procedure Register;
begin
 registercomponents('Zeos',[TZConnection, tmsezreadonlyquery, tmsezquery,
         tmseztable,
         TZUpdateSQL, tmsezstoredproc, TZSQLMetadata, TZSQLProcessor,
         TZSQLMonitor, TZSequence]);
 registerpropertyeditor(typeinfo(string),TZConnection,'Protocol',
                      tzprotocolpropertyeditor);
                      {
 registerpropertyeditor(typeinfo(tstrings),TmseZreadonlyQuery,'SQL',
                      tzreadonlyquerysqlpropertyeditor);
 registerpropertyeditor(typeinfo(tstrings),TmseZQuery,'SQL',
                      tzquerysqlpropertyeditor);
                      }
 registerpropertyeditor(typeinfo(tstrings),TZUpdateSQL,'DeleteSQL',
                      tsqlpropertyeditor);
 registerpropertyeditor(typeinfo(tstrings),TZUpdateSQL,'InsertSQL',
                      tsqlpropertyeditor);
 registerpropertyeditor(typeinfo(tstrings),TZUpdateSQL,'ModifySQL',
                      tsqlpropertyeditor);
 registerpropertyeditor(typeinfo(tstrings),TZUpdateSQL,'RefreshSQL',
                      tsqlpropertyeditor);
 registerpropertyeditor(typeinfo(tstrings),TZSqlProcessor,'RefreshSQL',
                      tsqlpropertyeditor);
end;

{ tzquerysqlpropertyeditor }

procedure tzquerysqlpropertyeditor.doafterclosequery(
                 var amodalresult: modalresultty);
begin
 if amodalresult = mr_canclose then begin
  tmsezquery(fprops[0].instance).active:= true;
 end;
end;

function tzquerysqlpropertyeditor.gettestbutton: boolean;
begin
 result:= true;
end;

function tzquerysqlpropertyeditor.getutf8: boolean;
begin
 result:= dso_utf8 in tmsezquery(fprops[0].instance).controller.options;
end;

procedure tzquerysqlpropertyeditor.edit;
begin
 factivebefore:= tmsezquery(fprops[0].instance).active;
 inherited;
 if not factivebefore then begin
  tmsezquery(fprops[0].instance).active:= false;
 end;
end;

{ tzreadonlyquerysqlpropertyeditor }

procedure tzreadonlyquerysqlpropertyeditor.doafterclosequery(
                 var amodalresult: modalresultty);
begin
 if amodalresult = mr_canclose then begin
  tmsezreadonlyquery(fprops[0].instance).active:= true;
 end;
end;

function tzreadonlyquerysqlpropertyeditor.gettestbutton: boolean;
begin
 result:= true;
end;

function tzreadonlyquerysqlpropertyeditor.getutf8: boolean;
begin
 result:= dso_utf8 in tmsezreadonlyquery(fprops[0].instance).controller.options;
end;

procedure tzreadonlyquerysqlpropertyeditor.edit;
begin
 factivebefore:= tmsezreadonlyquery(fprops[0].instance).active;
 inherited;
 if not factivebefore then begin
  tmsezreadonlyquery(fprops[0].instance).active:= false;
 end;
end;

{ tzprotocolpropertyeditor }

function tzprotocolpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_sortlist];
end;

function tzprotocolpropertyeditor.getvalues: msestringarty;
var
 list1: tstringlist;
 int1: integer;
begin
 list1:= tstringlist.create;
 try
  tzconnection(fprops[0].instance).getprotocolnames(list1);
  setlength(result,list1.count);
  for int1:= 0 to high(result) do begin
   result[int1]:= list1[int1];
  end;
 finally
  list1.free;
 end;
end;

initialization
 Register;
end.
