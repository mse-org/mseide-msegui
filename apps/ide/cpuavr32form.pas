unit cpuavr32form;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits,msesimplewidgets,msewidgets;

type
 tcpuavr32fo = class(tcpufo)
   fps: tintegeredit;
   tspacer1: tspacer;
   tbooleanedit16: tbooleanedit;
   tbooleanedit17: tbooleanedit;
   tbooleanedit18: tbooleanedit;
   tbooleanedit19: tbooleanedit;
   tbooleanedit20: tbooleanedit;
   tbooleanedit12: tbooleanedit;
   tbooleanedit14: tbooleanedit;
   tbooleanedit11: tbooleanedit;
   gm: tbooleanedit;
   tbooleanedit15: tbooleanedit;
   tbooleanedit7: tbooleanedit;
   tbooleanedit8: tbooleanedit;
   tbooleanedit21: tbooleanedit;
   tbooleanedit9: tbooleanedit;
   tbooleanedit10: tbooleanedit;
   tbooleanedit6: tbooleanedit;
   tbooleanedit5: tbooleanedit;
   tbooleanedit4: tbooleanedit;
   tbooleanedit3: tbooleanedit;
   tbooleanedit2: tbooleanedit;
   c: tbooleanedit;
   irqoff: tbooleanedit;
   exceptstack: tbutton;
   tlayouter2: tlayouter;
   r6: tintegeredit;
   r7: tintegeredit;
   r8: tintegeredit;
   r11: tintegeredit;
   r10: tintegeredit;
   r9: tintegeredit;
   r12: tintegeredit;
   sr: tintegeredit;
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
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
   function internalrefresh: boolean; override;
   procedure checkexcept(const sender: TObject);
   procedure irqoffset(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure afterla(const sender: tlayouter);
  private
   fgmbefore: boolean;
  protected
   procedure updatereadstatvalues; override;
   procedure updatewritestatvalues; override;
   procedure doirqoff;
   procedure irqrestore;
  public
   constructor create(aowner: tcomponent); override;
   function flagedit(const aindex: integer): tcustombooleanedit; override;
   procedure refresh; override;
   procedure beforecontinue; override;
 end;
 
implementation
uses
 cpuavr32form_mfm,main,msegdbutils,sourceform,mseformatstr,sysutils,
 disassform;
 
const
 modebits =   $01c00000;
 gmmask =     $00010000;
 exceptmode = $00800000; //irq level 0
{ tcpuavr32fo }
 
constructor tcpuavr32fo.create(aowner: tcomponent);
begin
 inherited create(aowner);
 fflagswidget:= sr;
end;

procedure tcpuavr32fo.regsetvalue(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
//var
// str1: string;
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
 int1: qword;
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
   exceptstack.enabled:= int1 and modebits >= exceptmode;
  end
  else begin
   result:= false;
  end;
 end;
 if not result then begin
  exceptstack.enabled:= false;
 end;
end;
//todo: fix 32/64
procedure tcpuavr32fo.checkexcept(const sender: TObject);

 procedure locateframe(const address: qword);
 var
  bo1: boolean;
  filename: filenamety;
  line: integer;
  start,stop: qword;
  str1: string;
  mstr1: msestring;
 begin
  disassfo.refresh(address);
  mstr1:= '';
  with mainfo.gdb do begin
   bo1:= infoline(address,filename,line,start,stop) = gdb_ok;
   if bo1 then begin
    if sourcefo.showsourceline(filename,line-1,0,true) <> nil then begin
     exit;
    end;
    mstr1:= filename+':'+inttostr(line);
   end;
   str1:= hextostr(address,8);
   if infosymbol('*0x'+str1,mstr1) = gdb_ok then begin
    mstr1:= mstr1+lineend+mstr1;
   end
   else begin
    mstr1:= mstr1+lineend+'Return address: '+str1;
   end;
  end;
  showmessage(mstr1,'Exception return');
 end;

var
 lwo1,lwo2,{lwo3,}lwo4: longword;
 lwo3,framead: qword;
begin
 with mainfo.gdb do begin
  if (getframeaddress(framead) = gdb_ok) then begin
   if readmemorylongword(framead+4,lwo1) = gdb_ok then begin
                                 //pc
//   setregistervalue('pc',lwo1);
    if readmemorylongword(framead,lwo2) = gdb_ok then begin
                                  //sr
     lwo4:= sr.value;             //backup
     if setsystemregister(0,lwo2) = gdb_ok then begin
                                  //for sp_app access
 //     if getregistervalue('sp',longint(lwo3)) = gdb_ok then begin
      if (getregistervalue('sp',lwo3) = gdb_ok) then begin
       if selectstackpointer(lwo3) = gdb_ok then begin
        mainfo.refreshframe;       
       end;
      end;
     end;
     setsystemregister(0,lwo4); //restore
    end;
   end;
   locateframe(lwo1);
  end;
 end;
end;

procedure tcpuavr32fo.doirqoff;
begin
 fgmbefore:= gm.value;
 if not gm.value then begin
  gm.value:= true;
  gm.checkvalue;
 end;
end;

procedure tcpuavr32fo.irqrestore;
begin
 if gm.value <> fgmbefore then begin
  gm.value:= fgmbefore;
  gm.checkvalue;
 end;
end;

procedure tcpuavr32fo.refresh;
begin
 if irqoff.value and mainfo.gdb.cancommand then begin
  inherited;
  doirqoff;
 end
 else begin
  inherited;
 end;
end;

procedure tcpuavr32fo.beforecontinue;
begin
 if irqoff.value and mainfo.gdb.cancommand then begin
  irqrestore;
 end;
 inherited;
end;

procedure tcpuavr32fo.irqoffset(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 if mainfo.gdb.cancommand then begin
  if avalue then begin
   doirqoff;
  end
  else begin
   irqrestore;
  end;
 end;
end;

procedure tcpuavr32fo.afterla(const sender: tlayouter);
begin
 aligny(wam_center,[exceptstack,irqoff]);
end;

procedure tcpuavr32fo.updatereadstatvalues;
begin
 irqoff.value:= irqoffvalue;
 inherited;
end;

procedure tcpuavr32fo.updatewritestatvalues;
begin
 irqoffvalue:= irqoff.value;
 inherited;
end;

function tcpuavr32fo.flagedit(const aindex: integer): tcustombooleanedit;
begin
 result:= c.tagitem(aindex);
end;

end.
