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
   procedure createexe(const sender: TObject);
 end;
var
 cpuarmm3fo: tcpuarmm3fo;
implementation
uses
 cpuarmm3form_mfm,msedataedits;
 
procedure tcpuarmm3fo.createexe(const sender: TObject);
var
 comp1: tintegeredit;
begin
{
 comp1:= cpsr;
 cpsr.name:= 'xpsr';
 cpsr:= comp1;
}
end;

end.
