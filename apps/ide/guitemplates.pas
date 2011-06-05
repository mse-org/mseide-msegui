unit guitemplates;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msegui,mseskin,msestrings,
 msesysenv;

type
 envvarty = (env_macrodef,env_vargroup,env_np,env_ns,
             env_fpcdir,env_fpclibdir,env_msedir,env_mselibdir,env_syntaxdefdir,
             env_templatedir,env_compstoredir,env_compiler,env_debugger,
             env_exeext,env_target,
             env_filename);
const
 sysenvvalues: array[envvarty] of argumentdefty =
  ((kind: ak_pararg; name: '-macrodef'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_pararg; name: '-macrogroup'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_par; name: 'np'; anames: nil; flags: []; initvalue: ''), //no project
   (kind: ak_par; name: 'ns'; anames: nil; flags: []; initvalue: ''), //no skin
   (kind: ak_envvar; name: 'FPCDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'FPCLIBDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'MSEDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'MSELIBDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'SYNTAXDEFDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'TEMPLATEDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'COMPSTOREDIR'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'COMPILER'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'DEBUGGER'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'EXEEXT'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_envvar; name: 'TARGET'; anames: nil; flags: []; initvalue: ''),
   (kind: ak_arg; name: ''; anames: nil; flags: []; initvalue: ''));

 firstenvvarmacro = env_fpcdir;   
 lastenvvarmacro = env_target;   
 
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
  for int1:= ord(firstenvvarmacro) to ord(lastenvvarmacro) do begin
             //envvar macros can be overridden by --macrodef
   if defined[int1] then begin
    setlength(result,high(result) + 2);
    with result[high(result)] do begin
     name:= sysenvvalues[envvarty(int1)].name;
     value:= guitemplatesmo.sysenv.value[int1];
    end;
   end;
  end;
  ar1:= values[ord(env_macrodef)];
  for int1:= 0 to high(ar1) do begin
   ar2:= nil;
   splitstringquoted(ar1[int1],ar2,msechar('"'),msechar(','));
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
