unit cpuarmform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits;

type
 tcpuarmfo = class(tcpufo)
   tspacer1: tspacer;
   tspacer2: tspacer;
   tlayouter1: tlayouter;
   r1: tintegeredit;
   r0: tintegeredit;
   r4: tintegeredit;
   r3: tintegeredit;
   r2: tintegeredit;
   r5: tintegeredit;
   sp: tintegeredit;
   lr: tintegeredit;
   pc: tintegeredit;
   tbooleanedit16: tbooleanedit;
   tbooleanedit17: tbooleanedit;
   tbooleanedit18: tbooleanedit;
   tbooleanedit19: tbooleanedit;
   tbooleanedit20: tbooleanedit;
   tbooleanedit15: tbooleanedit;
   tbooleanedit14: tbooleanedit;
   tbooleanedit13: tbooleanedit;
   tbooleanedit12: tbooleanedit;
   tbooleanedit11: tbooleanedit;
   tbooleanedit10: tbooleanedit;
   tbooleanedit9: tbooleanedit;
   tbooleanedit8: tbooleanedit;
   tbooleanedit7: tbooleanedit;
   tbooleanedit6: tbooleanedit;
   tbooleanedit5: tbooleanedit;
   tbooleanedit4: tbooleanedit;
   tbooleanedit3: tbooleanedit;
   tbooleanedit2: tbooleanedit;
   c: tbooleanedit;
   tlayouter2: tlayouter;
   r6: tintegeredit;
   r7: tintegeredit;
   r8: tintegeredit;
   r11: tintegeredit;
   r10: tintegeredit;
   r9: tintegeredit;
   fps: tintegeredit;
   cpsr: tintegeredit;
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
  public
   constructor create(aowner: tcomponent); override;
   function flagedit(const aindex: integer): tcustombooleanedit; override;
 end;

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

function tcpuarmfo.flagedit(const aindex: integer): tcustombooleanedit;
begin
 result:= c.tagitem(aindex);
end;

end.
