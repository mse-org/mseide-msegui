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
unit cpucpu32form;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,
 msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,cpuform,msesplitter,msedataedits,
 mseedit,msestrings,msetypes,msegraphedits;

type
 tcpucpu32fo = class(tcpufo)
   tspacer1: tspacer;
   c: tbooleanedit;
   S: tbooleanedit;
   tbooleanedit6: tbooleanedit;
   tbooleanedit4: tbooleanedit;
   tbooleanedit7: tbooleanedit;
   tbooleanedit8: tbooleanedit;
   tbooleanedit9: tbooleanedit;
   tbooleanedit10: tbooleanedit;
   tbooleanedit5: tbooleanedit;
   tbooleanedit3: tbooleanedit;
   tbooleanedit2: tbooleanedit;
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
   vbr: tintegeredit;
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
   sfc: tintegeredit;
   dfc: tintegeredit;
   procedure flagssetvalue(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure regsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure flagonchange(const sender: TObject);
  public
   constructor create(aowner: tcomponent); override;
   function flagedit(const aindex: integer): tcustombooleanedit; override;
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

function tcpucpu32fo.flagedit(const aindex: integer): tcustombooleanedit;
begin
 result:= c.tagitem(aindex);
end;

end.
