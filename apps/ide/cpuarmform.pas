unit cpuarmform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits;

type
 tcpuarmfo = class(tcpufo)
   tlayouter1: tlayouter;
   r1: tintegeredit;
   r0: tintegeredit;
   r4: tintegeredit;
   r3: tintegeredit;
   r2: tintegeredit;
   tlayouter2: tlayouter;
   r5: tintegeredit;
   r6: tintegeredit;
   r7: tintegeredit;
   r8: tintegeredit;
   r11: tintegeredit;
   r10: tintegeredit;
   r9: tintegeredit;
   sp: tintegeredit;
   lr: tintegeredit;
   pc: tintegeredit;
   fps: tintegeredit;
   cpsr: tintegeredit;
   c: tbooleanedit;
   tbooleanedit2: tbooleanedit;
   tbooleanedit3: tbooleanedit;
   tbooleanedit4: tbooleanedit;
   tbooleanedit5: tbooleanedit;
   tbooleanedit6: tbooleanedit;
   tbooleanedit7: tbooleanedit;
   tbooleanedit8: tbooleanedit;
   tbooleanedit9: tbooleanedit;
   tbooleanedit10: tbooleanedit;
   tbooleanedit11: tbooleanedit;
   tbooleanedit12: tbooleanedit;
   tbooleanedit13: tbooleanedit;
   tbooleanedit14: tbooleanedit;
   tbooleanedit15: tbooleanedit;
   tbooleanedit20: tbooleanedit;
   tbooleanedit19: tbooleanedit;
   tbooleanedit18: tbooleanedit;
   tbooleanedit17: tbooleanedit;
   tbooleanedit16: tbooleanedit;
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
  public
   constructor create(aowner: tcomponent); override;
 end;
var
 cpuarmfo: tcpuarmfo;
implementation
uses
 cpuarmform_mfm;

{ tcpuarmfo }
 
constructor tcpuarmfo.create(aowner: tcomponent);
begin
 inherited create(aowner);
 fflagswidget:= cpsr;
end;

procedure tcpuarmfo.regsetvalue(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
 doregsetvalue(sender,avalue,accept);
end;

procedure tcpuarmfo.flagssetvalue(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 doflagsetvalue(sender,avalue,accept);
end;

procedure tcpuarmfo.flagonchange(const sender: TObject);
begin
 doflagonchange(sender);
end;

end.
