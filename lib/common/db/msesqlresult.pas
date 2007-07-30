unit msesqlresult;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msqldb,mseclasses,msedb;
 
type
 tsqlresult = class(tmsecomponent,isqlpropertyeditor)
  private
   fsql: tstringlist;
   factive: boolean;
   fconnection: tsqlconnection;
   procedure setsql(const avalue: tstringlist);
   function getactive: boolean;
   procedure setactive(avalue: boolean);
   procedure setconnection(const avalue: tsqlconnection);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function isutf8: boolean;
   property active: boolean read getactive write setactive;
  published
   property sql: tstringlist read fsql write setsql;
   property connection: tsqlconnection read fconnection write setconnection;
 end;
 
implementation

{ tsqlresult }

constructor tsqlresult.create(aowner: tcomponent);
begin
 fsql:= tstringlist.create;
 inherited;
end;

destructor tsqlresult.destroy;
begin
 inherited;
 fsql.free;
end;

procedure tsqlresult.setsql(const avalue: tstringlist);
begin
 fsql.assign(avalue);
end;

function tsqlresult.getactive: boolean;
begin
 result:= factive;
end;

procedure tsqlresult.setactive(avalue: boolean);
begin
 factive:= avalue;
end;

function tsqlresult.isutf8: boolean;
begin
 result:= false; //todo
end;

procedure tsqlresult.setconnection(const avalue: tsqlconnection);
begin
 
end;

end.
