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
unit componentpaletteform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msetabs,msetoolbar,msegraphutils,msestat;

type
 tcomponentpalettefo = class(tdockform)
   componentpages: ttabbar;
   componentpalette: ttoolbar;
   procedure componentgrouponchildscaled(const sender: TObject);
   procedure componentpalettedragdrop(const sender: TObject;
      const apos: pointty; var dragobject: tdragobject; var processed: boolean);
   procedure componentpagesactivetabchange(const sender: TObject);
   procedure componentpalettebuttonchanged(const sender: TObject;
    const button: ttoolbutton);
   procedure foonreadstat(const sender: TObject; const reader: tstatreader);
  public
   procedure updatecomponentpalette(init: boolean);
 end;

var
 componentpalettefo: tcomponentpalettefo;

implementation
uses
 componentpaletteform_mfm,main,projectoptionsform,msedesignintf,mseshapes,
 mseactions,classes,mseact;

procedure tcomponentpalettefo.componentpalettedragdrop(const sender: TObject;
      const apos: pointty; var dragobject: tdragobject; var processed: boolean);
begin
 registeredcomponents.pagecomporders[componentpages.activetag - 1]:=
          ttoolbar(sender).buttons.idents;
 projectoptionsmodified;
end;

procedure tcomponentpalettefo.componentpagesactivetabchange(const sender: TObject);
begin
 updatecomponentpalette(false);
 componentpalette.firstbutton:= 0;
end;

procedure tcomponentpalettefo.componentpalettebuttonchanged(const sender: TObject;
  const button: ttoolbutton);
begin
 if not application.terminated then begin
  with registeredcomponents do begin
   if tclass(button.tag) = selectedclass then begin
    selectedclass:= nil;
   end;
   if as_checked in button.state then begin
    selectedclass:= tcomponentclass(button.tag);
   end;
  end;
 end;
end;

procedure tcomponentpalettefo.componentgrouponchildscaled(const sender: TObject);
begin
 placeyorder(0,[0],[componentpages,componentpalette],0);
end;

procedure tcomponentpalettefo.updatecomponentpalette(init: boolean);
var
 int1,int2: integer;
begin
 if init then begin
  with componentpages do begin
   beginupdate;
   try
    tabs.count:= 0;
    tabs.additems(registeredcomponents.pagenames);
    if tabs.count > 0 then begin
     activetab:= 0;
    end;
    for int1:= 0 to tabs.count - 1 do begin
     tabs[int1].tag:= int1 + 1;
    end;
   finally
    componentpages.endupdate;
   end;
  end;
 end;

 componentpalette.beginupdate;
 try
  int2:= componentpages.activetag - 1;
  componentpalette.buttons.count:= 0;
  if int2 >= 0 then begin
   for int1:= 0 to registeredcomponents.count - 1 do begin
    with registeredcomponents.itempo(int1)^ do begin
     if page = int2 then begin
      with componentpalette.buttons.add do begin
       options:= [mao_checkbox,mao_radiobutton];
       imagelist:= registeredcomponents.imagelist;
       imagenr:= icon;
       hint:= classtyp.classname;
       tag:= integer(classtyp);
      end;
     end;
    end;
   end;
   if int2 <= registeredcomponents.pagehigh then begin
    componentpalette.buttons.order(registeredcomponents.pagecomporders[int2]);
   end;
  end;
 finally
  componentpalette.endupdate;
 end;
end;

procedure tcomponentpalettefo.foonreadstat(const sender: TObject;
                                                  const reader: tstatreader);
begin
 updatecomponentpalette(true);
end;

end.
