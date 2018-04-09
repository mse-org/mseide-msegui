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
unit cpurl78form;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,cpuform,msedataedits,
 mseedit,mseifiglob,msestrings,msetypes,classes,mclasses,msegraphedits,
 msesimplewidgets,msewidgets;

type
 tcpurl78fo = class(tcpufo)
   a: tintegeredit;
   x: tintegeredit;
   ax: tintegeredit;
   bc: tintegeredit;
   b: tintegeredit;
   c: tintegeredit;
   de: tintegeredit;
   d: tintegeredit;
   e: tintegeredit;
   hl: tintegeredit;
   h: tintegeredit;
   l: tintegeredit;
   psw: tintegeredit;
   tgroupbox1: tgroupbox;
   tbooleanedit9: tbooleanedit;
   tbooleanedit8: tbooleanedit;
   tbooleanedit7: tbooleanedit;
   tbooleanedit6: tbooleanedit;
   tbooleanedit5: tbooleanedit;
   tbooleanedit4: tbooleanedit;
   z: tbooleanedit;
   tbooleanedit2: tbooleanedit;
   sp: tintegeredit;
   pc: tintegeredit;
   es: tintegeredit;
   cs: tintegeredit;
   pmc: tintegeredit;
   bank0_r6: tintegeredit;
   bank0_r7: tintegeredit;
   bank0_rp3: tintegeredit;
   bank0_r4: tintegeredit;
   bank0_r5: tintegeredit;
   bank0_rp2: tintegeredit;
   bank0_r2: tintegeredit;
   bank0_r3: tintegeredit;
   bank0_rp1: tintegeredit;
   bank0_rp0: tintegeredit;
   bank0_r0: tintegeredit;
   bank0_r1: tintegeredit;
   bank1_r1: tintegeredit;
   bank1_r0: tintegeredit;
   bank1_rp0: tintegeredit;
   bank1_rp1: tintegeredit;
   bank1_r3: tintegeredit;
   bank1_r2: tintegeredit;
   bank1_rp2: tintegeredit;
   bank1_r5: tintegeredit;
   bank1_r4: tintegeredit;
   bank1_rp3: tintegeredit;
   bank1_r7: tintegeredit;
   bank1_r6: tintegeredit;
   bank2_r1: tintegeredit;
   bank2_r0: tintegeredit;
   bank2_rp0: tintegeredit;
   bank2_rp1: tintegeredit;
   bank2_r3: tintegeredit;
   bank2_r2: tintegeredit;
   bank2_rp2: tintegeredit;
   bank2_r5: tintegeredit;
   bank2_r4: tintegeredit;
   bank2_rp3: tintegeredit;
   bank2_r7: tintegeredit;
   bank2_r6: tintegeredit;
   bank3_r1: tintegeredit;
   bank3_r0: tintegeredit;
   bank3_rp0: tintegeredit;
   bank3_rp1: tintegeredit;
   bank3_r3: tintegeredit;
   bank3_r2: tintegeredit;
   bank3_rp2: tintegeredit;
   bank3_r5: tintegeredit;
   bank3_r4: tintegeredit;
   bank3_rp3: tintegeredit;
   bank3_r7: tintegeredit;
   bank3_r6: tintegeredit;
   mem: tintegeredit;
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagsetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
   function flagedit(const aindex: integer): tcustombooleanedit; override;
  public
   constructor create(aowner: tcomponent); override;
 end;
 
var
 cpurl78fo: tcpurl78fo;
implementation
uses
 cpurl78form_mfm;
 
constructor tcpurl78fo.create(aowner: tcomponent);
begin
 fneedsrefresh:= true;
 inherited;
 fflagswidget:= psw;
end;
 
procedure tcpurl78fo.regsetvalue(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
 doregsetvalue(sender,avalue,accept);
end;

procedure tcpurl78fo.flagsetvalue(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 doflagsetvalue(sender,avalue,accept);
end;

procedure tcpurl78fo.flagonchange(const sender: TObject);
begin
 doflagonchange(sender);
end;

function tcpurl78fo.flagedit(const aindex: integer): tcustombooleanedit;
begin
 result:= z.tagitem(aindex);
end;

end.
