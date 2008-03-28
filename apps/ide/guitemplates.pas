unit guitemplates;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msegui,mseskin,msestrings,
 msesysenv;

type
 envvarty = (env_macrodef,env_vargroup,env_np,env_ns,env_filename);
const
 sysenvvalues: array[envvarty] of argumentdefty =
  ((kind: ak_pararg; name: '-macrodef'; anames: nil; flags: []),
   (kind: ak_pararg; name: '-macrogroup'; anames: nil; flags: []),
   (kind: ak_par; name: 'np'; anames: nil; flags: []), //no project
   (kind: ak_par; name: 'ns'; anames: nil; flags: []), //no skin
   (kind: ak_arg; name: ''; anames: nil; flags: []));
   
type
 tguitemplatesmo = class(tmsedatamodule)
   fadevertkonvex: tfacecomp;
   fadehorzconvex: tfacecomp;
   fadehorzconcave: tfacecomp;
   fadevertconcave: tfacecomp;
   skin: tskincontroller;
   fadecontainer: tfacecomp;
   nullface: tfacecomp;
   sysenv: tsysenvmanager;
   procedure cre(const sender: TObject);
 end;
 
function getcommandlinemacros: macroinfoarty;

var
 guitemplatesmo: tguitemplatesmo;
implementation
uses
 guitemplates_mfm;

function getcommandlinemacros: macroinfoarty;
var
 ar1,ar2: msestringarty;
 int1,int2,int3,int4: integer;
begin
 result:= nil;
 with guitemplatesmo.sysenv do begin
  ar1:= values[ord(env_macrodef)];
  for int1:= 0 to high(ar1) do begin
   ar2:= nil;
   splitstringquoted(ar1[int1],ar2,'"',',');
   if ar2 <> nil then begin
    int3:= length(result);
    int4:= (high(ar2)+2) div 2; //pair count
    setlength(result,int3+int4); 
    for int2:= 0 to int4-1 do begin
     with result[int2+int3] do begin
      int4:= int2 * 2;
      name:= ar2[int4];
      if int4 < high(ar2) then begin
       value:= ar2[int4+1]
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tguitemplatesmo.cre(const sender: TObject);
begin
 sysenv.init(sysenvvalues);
 skin.active:= not sysenv.defined[ord(env_ns)];
end;

end.
