{ MSEide Copyright (c) 1999-2008 by Martin Schreiber
   
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
unit cpui386form;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 classes,msegui,mseclasses,mseforms,msegdbutils,msetypes,msedataedits,msegraphics,
 msegraphedits,cpuform;

type

 tcpui386fo = class(tcpufo)
   eax: tintegeredit;
   ebx: tintegeredit;
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
   procedure flagonchange(const sender: TObject);
   procedure flagsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
   procedure ononchange(const sender: TObject);
   procedure regsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
   procedure cpufoonchildscaled(const sender: TObject);
  public
   constructor create(aowner: tcomponent); override;
 end;

implementation
uses
 cpui386form_mfm,main,sysutils,mseformatstr,msebits,msestrings,msegraphutils;

{ tcpui386fo }

constructor tcpui386fo.create(aowner: tcomponent);
begin
 inherited create(aowner);
 fflagswidget:= eflags;
end;

procedure tcpui386fo.flagonchange(const sender: TObject);
begin
 doflagonchange(sender);
end;

procedure tcpui386fo.flagsetvalue(const sender: TObject;
                   var avalue: Boolean; var accept: Boolean);
begin
 doflagsetvalue(sender,avalue,accept);
end;

procedure tcpui386fo.ononchange(const sender: TObject);
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

procedure tcpui386fo.regsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
begin
 doregsetvalue(sender,avalue,accept);
end;

procedure tcpui386fo.cpufoonchildscaled(const sender: TObject);
begin
 placeyorder(eax.bounds_y,[0],[eax,ebx,ecx,edx,esi,edi,ebp]);
 placeyorder(eflags.bounds_y,[0],[eflags,esp,eip]);
 placeyorder(esi.bounds_y,[0],[cs,ds,es]);
 placeyorder(esi.bounds_y,[0],[fs,gs,ss]);
end;

end.
