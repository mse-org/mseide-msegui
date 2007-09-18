unit msetmpmodules;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses;
 
procedure beginloadtmpmodule;
procedure endloadtmpmodule;
procedure addtmpmodule(const amodule: tmsecomponent);

function createtmpmodule(const aclassname: string;
                               const aobjdata: tstream): tmsecomponent;

implementation
uses
 sysutils,msegui;
type
 tmsecomponent1 = class(tmsecomponent);
 
var
 ftmpmodules: tmodulelist;

function createtmpmodule(const aclassname: string;
                               const aobjdata: tstream): tmsecomponent;
var
 class1: tpersistentclass;
begin
 class1:= findclass(aclassname);
 if not class1.inheritsfrom(tmsecomponent) then begin
  raise exception.create('Class "'+aclassname+
                     '" must inherit from tmsecomponent.');
 end;
 result:= tmsecomponent(class1.newinstance);
 with tmsecomponent1(result) do begin
  include(fmsecomponentstate,cs_noload);
  try
   beginloadtmpmodule;
   try
    create(application);
    exclude(fmsecomponentstate,cs_noload);
    aobjdata.readcomponent(result);
    addtmpmodule(result);
   finally
    endloadtmpmodule;
   end;
  except
   result.free;
   raise;
  end;
 end;
end;
 
function findtmpmodulebyname(const name: string): tcomponent;
begin
 result:= ftmpmodules.findmodulebyname(name);
end;

procedure beginloadtmpmodule;
begin
 lockfindglobalcomponent;
 ftmpmodules.unlock;
 begingloballoading;
end;

procedure endloadtmpmodule;
begin
 endgloballoading;
 ftmpmodules.lock;
 unlockfindglobalcomponent;
end;

procedure addtmpmodule(const amodule: tmsecomponent);
begin
 ftmpmodules.add(amodule);
 globalfixupreferences;
 notifygloballoading;
 tmsecomponent1(amodule).doafterload;
end;

initialization
 ftmpmodules:= tmodulelist.create(false);
 ftmpmodules.lock;
 registerfindglobalcomponentproc({$ifdef FPC}@{$endif}findtmpmodulebyname);
finalization
 freeandnil(ftmpmodules);
end.
