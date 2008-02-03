unit guitemplates;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msegui,mseskin,msestrings,
 msesysenv;

type
 envvarty = (env_vargroup,env_np,env_ns,env_filename);
const
 sysenvvalues: array[envvarty] of argumentdefty =
  ((kind: ak_pararg; name: '-macrogroup'; anames: nil; flags: [arf_integer]),
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
var
 guitemplatesmo: tguitemplatesmo;
implementation
uses
 guitemplates_mfm;

procedure tguitemplatesmo.cre(const sender: TObject);
begin
 sysenv.init(sysenvvalues);
 skin.active:= not sysenv.defined[ord(env_ns)];
end;

end.
