unit cpuarmm3form;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,cpuarmform,
 msegraphedits,mseifiglob,msetypes;

type
 tcpuarmm3fo = class(tcpuarmfo)
   tbooleanedit21: tbooleanedit;
   tbooleanedit22: tbooleanedit;
   tbooleanedit23: tbooleanedit;
  protected
 end;
var
 cpuarmm3fo: tcpuarmm3fo;
implementation
uses
 cpuarmm3form_mfm,msedataedits;
 
end.
