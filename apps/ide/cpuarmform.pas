{ MSEide Copyright (c) 1999-2013 by Martin Schreiber
   
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
unit cpuarmform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,
 msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits,mseifiglob;

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
   r11: tintegeredit;
   r10: tintegeredit;
   r9: tintegeredit;
   fps: tintegeredit;
   cpsr: tintegeredit;
   r12: tintegeredit;
   sp: tintegeredit;
   r6: tintegeredit;
   lr: tintegeredit;
   pc: tintegeredit;
   r7: tintegeredit;
   r8: tintegeredit;
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
  protected
   procedure updateregisternames() override;
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

procedure tcpuarmfo.updateregisternames();
var
 comp1: tintegeredit;
 i1: int32;
begin
 comp1:= cpsr;
 cpsr.name:= 'cpsr';
 cpsr:= comp1;
 for i1 := high(fregisternames) downto 0 do begin
  if fregisternames[i1] = 'xpsr' then begin //for segger j-link
   comp1:= cpsr;
   cpsr.name:= 'xpsr';
   cpsr:= comp1;
   break;
  end;
 end;
 cpsr.frame.caption:= cpsr.name;
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
