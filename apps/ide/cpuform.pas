{ MSEide Copyright (c) 1999-2007 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit cpuform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 classes,msegui,mseclasses,mseforms,msegdbutils,msetypes,msedataedits,
 msegraphics,msegraphedits,mseevent,msemenus,msestat,msedispwidgets;

type

 tcpufo = class(tdockform)
   on: tbooleanedit;
   stoptime: tdatetimedisp;
   procedure cpuonshow(const sender: TObject);
   procedure ononchange(const sender: TObject);
   procedure updastat(const sender: TObject; const filer: tstatfiler); virtual;
   procedure aftread(const sender: TObject);
   procedure befwrite(const sender: TObject);
  protected
   fflagswidget: tintegeredit;
   fflagswidget64: tint64edit;
   fregisternames: stringarty;
   fedits: array of tdataedit;
   irqoffvalue: boolean;
   procedure doregsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
   procedure doregset64value(const sender: TObject; var avalue: Int64; var accept: Boolean);
   procedure doflagsetvalue(const sender: TObject;
                   var avalue: Boolean; var accept: Boolean);
   procedure doflagonchange(const sender: TObject);
   function internalrefresh: boolean; virtual;
   procedure updatereadstatvalues; virtual;
   procedure updatewritestatvalues; virtual;
   procedure updatelayout(const dsender: twidget); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure refresh; virtual;
   procedure beforecontinue; virtual;
  end;

var
 cpufo: tcpufo;

procedure createcpufo;

implementation
uses
 cpuform_mfm,main,sysutils,mseformatstr,msebits,msestrings,msegraphutils,
 cpui386form,cpux86_64form,cpuarmform,cpucpu32form,cpuavr32form,projectoptionsform;
var
 currentproc: processorty;
  
procedure createcpufo;
begin
 mainfo.gdb.processorname:= projectoptions.texp.gdbprocessor;
 if (cpufo = nil) or (currentproc <> mainfo.gdb.processor) then begin
  freeandnil(cpufo);
  currentproc:= mainfo.gdb.processor;
  case mainfo.gdb.processor of
   pro_i386: begin
    application.createform(tcpui386fo,cpufo);
   end;
   pro_x86_64: begin
    application.createform(tcpux86_64fo,cpufo);
   end;
   pro_arm: begin
    application.createform(tcpuarmfo,cpufo);
   end;
   pro_cpu32: begin
    application.createform(tcpucpu32fo,cpufo);
   end;
   pro_avr32: begin
    application.createform(tcpuavr32fo,cpufo);
   end;
   else begin
    application.createform(tcpufo,cpufo);
   end;
  end;
 end;
end;

{ tcpufo }

function tcpufo.internalrefresh: boolean;
var
 ar1: registerinfoarty;
 int1,int2: integer;
 comp1: tcomponent;
 ed1: tdataedit;
 str1: msestring;
begin
 result:= false;
 if fregisternames = nil then begin
  if mainfo.gdb.listregisternames(fregisternames) <> gdb_ok then begin
   exit;
  end;
  fedits:= nil;
  setlength(fedits,length(fregisternames));
  for int1:= 0 to high(fregisternames) do begin
   if fregisternames[int1] <> '' then begin
    for int2:= 0 to componentcount - 1 do begin
     comp1:= components[int2];
     if (comp1.Name = fregisternames[int1]) then begin
      if (comp1 is tdataedit) then begin
       fedits[int1]:= tdataedit(comp1);
       comp1.Tag:= int1;
      end;
      break;
     end;
    end;
   end;
  end;
 end;
 if mainfo.gdb.listregistervalues(ar1) = gdb_ok then begin
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    if (num >= 0) and (num <= high(fedits)) then begin
     ed1:= fedits[num];
     if ed1 <> nil then begin
      str1:= ed1.text;
      ed1.text:= ar1[int1].bits;
      ed1.checkvalue(true);
      if ed1.text <> str1 then begin
       ed1.font.color:= cl_red;
      end
      else begin
       ed1.font.color:= cl_black;
      end;
     end;
    end;
   end;
  end;
  result:= true;
 end;
end;

procedure tcpufo.refresh;
begin
 if visible and mainfo.gdb.cancommand and on.value then begin
  internalrefresh;
 end;
end;

procedure tcpufo.cpuonshow(const sender: TObject);
begin
 refresh;
end;

procedure tcpufo.ononchange(const sender: TObject);
var
 int1: integer;
begin
 if on.value then begin
  for int1:= 0 to childrencount - 1 do begin
   children[int1].enabled:= true;
  end;
  refresh;
 end
 else begin
  for int1:= 0 to childrencount - 1 do begin
   if children[int1] <> sender then begin
    children[int1].enabled:= false;
   end;
  end;
 end;
end;

procedure tcpufo.doregsetvalue(const sender: TObject; var avalue: Integer;
                    var accept: Boolean);
//var
// str1: string;
begin
 if mainfo.gdb.cancommand then begin
  with tintegeredit(sender) do begin
   if mainfo.gdb.setregistervalue(fregisternames[tag],avalue) <> gdb_ok then begin
//   if mainfo.gdb.writepascalvariable(
//        '$'+fregisternames[tag],inttostr(avalue),str1) <> gdb_ok then begin
    accept:= false;
   end;
  end;
 end
 else begin
  accept:= false;
 end;
end;

procedure tcpufo.doregset64value(const sender: TObject; var avalue: Int64;
                    var accept: Boolean);
//var
// str1: string;
begin
 if mainfo.gdb.cancommand then begin
  with tintegeredit(sender) do begin
   if mainfo.gdb.setregistervalue(fregisternames[tag],avalue) <> gdb_ok then begin
//   if mainfo.gdb.writepascalvariable(
//        '$'+fregisternames[tag],inttostr(avalue),str1) <> gdb_ok then begin
    accept:= false;
   end;
  end;
 end
 else begin
  accept:= false;
 end;
end;

procedure tcpufo.doflagsetvalue(const sender: TObject;
                   var avalue: Boolean; var accept: Boolean);
begin
 if fflagswidget <> nil then begin
  with tbooleanedit(sender) do begin
   if avalue then begin
    fflagswidget.value:= longword(fflagswidget.value) or bits[tag];
   end
   else begin
    fflagswidget.value:= longword(fflagswidget.value) and not bits[tag];
   end;
   fflagswidget.checkvalue;
  end;
 end
 else begin
  if fflagswidget64 <> nil then begin
   with tbooleanedit(sender) do begin
    if avalue then begin
     fflagswidget64.value:= longword(fflagswidget64.value) or bits[tag];
    end
    else begin
     fflagswidget64.value:= longword(fflagswidget64.value) and not bits[tag];
    end;
    fflagswidget64.checkvalue;
   end;
  end;
 end;
end;

procedure tcpufo.doflagonchange(const sender: TObject);
var
 int1: integer;
 ed1: tcustombooleanedit;
 bo1: boolean;
 ca1: longword;
begin
 if fflagswidget <> nil then begin
  ca1:= fflagswidget.value;
  for int1:= 0 to 31 do begin
   ed1:= on.tagitem(int1);
   if (ed1 <> nil) then begin
    bo1:= bits[int1] and ca1 <> 0;
    if ed1.value <> bo1 then begin
     ed1.frame.colorclient:= cl_ltred;
    end
    else begin
     ed1.frame.colorclient:= cl_active;
    end;
    ed1.value:= bo1;
   end;
  end;
 end
 else begin
  if fflagswidget64 <> nil then begin
   ca1:= fflagswidget64.value;
   for int1:= 0 to 31 do begin
    ed1:= on.tagitem(int1);
    if (ed1 <> nil) then begin
     bo1:= bits[int1] and ca1 <> 0;
     if ed1.value <> bo1 then begin
      ed1.frame.colorclient:= cl_ltred;
     end
     else begin
      ed1.frame.colorclient:= cl_active;
     end;
     ed1.value:= bo1;
    end;
   end;
  end;
 end;
end;

procedure tcpufo.beforecontinue;
begin
 //dummy
end;

procedure tcpufo.updastat(const sender: TObject; const filer: tstatfiler);
begin
 filer.updatevalue('irqoff',irqoffvalue);
end;

procedure tcpufo.updatereadstatvalues;
begin
 //dummy
end;

procedure tcpufo.updatewritestatvalues;
begin
 //dummy
end;

procedure tcpufo.aftread(const sender: TObject);
begin
 updatereadstatvalues;
end;

procedure tcpufo.befwrite(const sender: TObject);
begin
 updatewritestatvalues;
end;

constructor tcpufo.create(aowner: tcomponent);
begin
 inherited create(aowner);
end;

procedure tcpufo.updatelayout(const dsender: twidget);
begin
 aligny(wam_center,[stoptime,on]);
 inherited;
end;

end.
