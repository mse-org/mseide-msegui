unit cpucpu32form;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits;

type
 tcpucpu32fo = class(tcpufo)
   tlayouter1: tlayouter;
   d1: tintegeredit;
   d0: tintegeredit;
   d4: tintegeredit;
   d3: tintegeredit;
   d2: tintegeredit;
   d5: tintegeredit;
   d6: tintegeredit;
   d7: tintegeredit;
   ps: tintegeredit;
   tlayouter2: tlayouter;
   a1: tintegeredit;
   a0: tintegeredit;
   a4: tintegeredit;
   a3: tintegeredit;
   a2: tintegeredit;
   a5: tintegeredit;
   fp: tintegeredit;
   usp: tintegeredit;
   pc: tintegeredit;
   ssp: tintegeredit;
   sfc: tintegeredit;
   dfc: tintegeredit;
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
   S: tbooleanedit;
   vbr: tintegeredit;
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
  public
   constructor create(aowner: tcomponent); override;
 end;
 
var
 cpucpu32fo: tcpucpu32fo;
 
implementation
uses
 cpucpu32form_mfm;

constructor tcpucpu32fo.create(aowner: tcomponent);
begin
 inherited create(aowner);
 fflagswidget:= ps;
end;
 
procedure tcpucpu32fo.flagssetvalue(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 doflagsetvalue(sender,avalue,accept);
end;

procedure tcpucpu32fo.regsetvalue(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
 doregsetvalue(sender,avalue,accept);
end;

procedure tcpucpu32fo.flagonchange(const sender: TObject);
begin
 doflagonchange(sender);
end;

end.
