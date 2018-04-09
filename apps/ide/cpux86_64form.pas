{ MSEide Copyright (c) 2009-2013 by Martin Schreiber
   
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
unit cpux86_64form;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 classes,mclasses,msegui,mseclasses,mseforms,msegdbutils,msetypes,msedataedits,
 msegraphics,msegraphedits,cpuform,msegraphutils,mseguiglob,msemenus,
 msesimplewidgets,msewidgets,mseedit,msestrings,msesplitter;

type

 tcpux86_64fo = class(tcpufo)
   tspacer1: tspacer;
   r14: tint64edit;
   r13: tint64edit;
   r12: tint64edit;
   r11: tint64edit;
   r10: tint64edit;
   r15: tint64edit;
   r9: tint64edit;
   r8: tint64edit;
   io: tbooleanedit;
   nt: tbooleanedit;
   c: tbooleanedit;
   p: tbooleanedit;
   a: tbooleanedit;
   z: tbooleanedit;
   s: tbooleanedit;
   t: tbooleanedit;
   i: tbooleanedit;
   d: tbooleanedit;
   o: tbooleanedit;
   eflags: tint64edit;
   rip: tint64edit;
   rsp: tint64edit;
   rbp: tint64edit;
   rdi: tint64edit;
   rsi: tint64edit;
   rdx: tint64edit;
   rcx: tint64edit;
   rbx: tint64edit;
   rax: tint64edit;
   r: tbooleanedit;
   v: tbooleanedit;
   procedure flagonchange(const sender: TObject);
   procedure flagsetvalue(const sender: TObject; var avalue: Boolean; var accept: Boolean);
//   procedure ononchange(const sender: TObject);
   procedure regsetvalue(const sender: TObject; var avalue: Int64; var accept: Boolean);
   procedure cpufoonchildscaled(const sender: TObject);
  public
   constructor create(aowner: tcomponent); override;
//   function flagedit(const aindex: integer): tcustombooleanedit; override;
 end;

implementation
uses
 cpux86_64form_mfm,main,sysutils,mseformatstr,msebits;

{ tcpux86_64fo }

constructor tcpux86_64fo.create(aowner: tcomponent);
begin
 inherited create(aowner);
 fflagswidget64:= eflags;
 fflagscontainer:= tspacer1;
end;

procedure tcpux86_64fo.flagonchange(const sender: TObject);
begin
 doflagonchange(sender);
end;

procedure tcpux86_64fo.flagsetvalue(const sender: TObject;
                   var avalue: Boolean; var accept: Boolean);
begin
 doflagsetvalue(sender,avalue,accept);
end;
{
procedure tcpux86_64fo.ononchange(const sender: TObject);
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
}
procedure tcpux86_64fo.regsetvalue(const sender: TObject; var avalue: Int64; var accept: Boolean);
begin
 doregset64value(sender,avalue,accept);
end;

procedure tcpux86_64fo.cpufoonchildscaled(const sender: TObject);
begin
 placeyorder(rax.bounds_y,[0],[rax,rbx,rcx,rdx,rbp,rsi,rdi]);
 placeyorder(rdi.bounds_y+2*rdi.bounds_cy,[0],[r8,r9]);
 placeyorder(eflags.bounds_y,[0],[eflags,rsp,rip]);
 placeyorder(rbp.bounds_y,[0],[r10,r11,r12,r13,r14,r15]);
end;
{
function tcpux86_64fo.flagedit(const aindex: integer): tcustombooleanedit;
begin
 result:= c.tagitem(aindex);
end;
}
end.
