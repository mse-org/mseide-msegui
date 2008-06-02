unit cpuavr32form;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits;

type
 tcpuavr32fo = class(tcpufo)
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
   sr: tintegeredit;
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
   function internalrefresh: boolean; override;
  public
   constructor create(aowner: tcomponent); override;
 end;
 
implementation
uses
 cpuavr32form_mfm,main,msegdbutils;

{ tcpuavr32fo }
 
constructor tcpuavr32fo.create(aowner: tcomponent);
begin
 inherited create(aowner);
 fflagswidget:= sr;
end;

procedure tcpuavr32fo.regsetvalue(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
var
 str1: string;
begin
 if mainfo.gdb.cancommand then begin
  with tintegeredit(sender) do begin
   if mainfo.gdb.setsystemregister(0,value) <> gdb_ok then begin
    accept:= false;
   end;
  end;
 end
 else begin
  accept:= false;
 end;
end;

procedure tcpuavr32fo.flagssetvalue(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 doflagsetvalue(sender,avalue,accept);
end;

procedure tcpuavr32fo.flagonchange(const sender: TObject);
begin
 doflagonchange(sender);
end;

function tcpuavr32fo.internalrefresh: boolean;
var
 int1: ptrint;
begin
 result:= inherited internalrefresh;
 if result then begin
  if mainfo.gdb.getsystemregister(0,int1) = gdb_ok then begin
   if sr.value <> int1 then begin
    sr.font.color:= cl_red;
   end
   else begin
    sr.font.color:= cl_black;
   end;
   sr.value:= int1;
   result:= true;
  end
  else begin
   result:= false;
  end;
 end;
end;

end.
