{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
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

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 classes,msegui,mseclasses,mseforms,msegdbutils,msetypes,msedataedits,msegraphics,
 msegraphedits;

type

 tcpufo = class(tdockform)
   eax: tintegeredit;
   ebx: tintegeredit;
   on: tbooleanedit;
   ecx: tintegeredit;
   edx: tintegeredit;
   esi: tintegeredit;
   edi: tintegeredit;
   ebp: tintegeredit;
   esp: tintegeredit;
   eip: tintegeredit;
   eflags: tintegeredit;
   cs: tintegeredit;
   ds: tintegeredit;
   es: tintegeredit;
   fs: tintegeredit;
   gs: tintegeredit;
   ss: tintegeredit;
   o: tbooleanedit;
   d: tbooleanedit;
   i: tbooleanedit;
   t: tbooleanedit;
   s: tbooleanedit;
   r: tbooleanedit;
   nt: tbooleanedit;
   io: tbooleanedit;
   v: tbooleanedit;
   z: tbooleanedit;
   a: tbooleanedit;
   p: tbooleanedit;
   c: tbooleanedit;
   procedure cpuonshow(const sender: TObject);
   procedure flagonchange(const sender: TObject);
   procedure flagsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
   procedure ononchange(const sender: TObject);
   procedure regsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
   procedure cpufoonchildscaled(const sender: TObject);
  private
   fregisternames: stringarty;
   fedits: array of tdataedit;
  public
   gdb: tgdbmi;
   procedure refresh;
 end;

var
 cpufo: tcpufo;

implementation
uses
 cpuform_mfm,main,sysutils,mseformatstr,msebits,msestrings;

{ tcpufo }

procedure tcpufo.refresh;
var
 ar1: registerinfoarty;
 int1,int2: integer;
 comp1: tcomponent;
 ed1: tdataedit;
 str1: msestring;
begin
 if visible and gdb.active and on.value then begin
  if fregisternames = nil then begin
   if gdb.listregisternames(fregisternames) <> gdb_ok then begin
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
  if gdb.listregistervalues(ar1) = gdb_ok then begin
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
  end;
 end;
end;

procedure tcpufo.cpuonshow(const sender: TObject);
begin
 refresh;
end;

procedure tcpufo.flagonchange(const sender: TObject);
var
 int1: integer;
 ed1: tcustombooleanedit;
 bo1: boolean;
 ca1: cardinal;
begin
 ca1:= eflags.value;
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

procedure tcpufo.flagsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
 with tbooleanedit(sender) do begin
  if avalue then begin
   eflags.value:= cardinal(eflags.value) or bits[tag];
  end
  else begin
   eflags.value:= cardinal(eflags.value) and not bits[tag];
  end;
  eflags.checkvalue;
 end;
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

procedure tcpufo.regsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
var
 str1: string;
begin
 if gdb.active and not gdb.running then begin
  with tintegeredit(sender) do begin
   if gdb.writepascalvariable(
        '$'+fregisternames[tag],inttostr(avalue),str1) <> gdb_ok then begin
    accept:= false;
   end;
  end;
 end
 else begin
  accept:= false;
 end;
end;

procedure tcpufo.cpufoonchildscaled(const sender: TObject);
begin
 placeyorder(eax.bounds_y,[0],[eax,ebx,ecx,edx,esi,edi,ebp]);
 placeyorder(eflags.bounds_y,[0],[eflags,esp,eip]);
 placeyorder(esi.bounds_y,[0],[cs,ds,es]);
 placeyorder(esi.bounds_y,[0],[fs,gs,ss]);
end;

end.
