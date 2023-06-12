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
unit componentpaletteform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msetabs,msetoolbar,msegraphutils,msestat,mseguiglob,msebitmap,
 msedragglob,msetypes{msestrings};

type
 tcomponentpalettefo = class(tdockform)
   componentpages: ttabbar;
   componentpalette: ttoolbar;
   procedure componentgrouponchildscaled(const sender: TObject);
   procedure componentpalettedragdrop(const sender: TObject;
      const apos: pointty; var dragobject: tdragobject; var processed: boolean);
   procedure componentpagesactivetabchange(const sender: TObject);
   procedure componentpalettebuttonchanged(const sender: tobject;
                                             const button: tcustomtoolbutton);
   procedure foonreadstat(const sender: TObject; const reader: tstatreader);
  public
   procedure updatecomponentpalette(init: boolean);
   procedure resetselected;
 end;

var
 componentpalettefo: tcomponentpalettefo;

implementation
uses
 componentpaletteform_mfm,main,projectoptionsform,msedesignintf,mseshapes,
 mseactions,classes,mclasses,mseact,componentstore;

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
  const button: tcustomtoolbutton);
begin
 if not application.terminated then begin
  with registeredcomponents do begin
   if tclass(button.tagpo) = selectedclass then begin
    selectedclass:= nil;
   end;
   if as_checked in button.state then begin
    componentstorefo.resetselected;
    selectedclass:= mclasses.tcomponentclass(button.tagpo);
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
 ar1: comppagearty;
begin
 resetselected;
 if init then begin
  with componentpages do begin
   beginupdate;
   try
    tabs.count:= 0;
    ar1:= registeredcomponents.pagenames;
    tabs.count:= length(ar1);
//    tabs.additems(registeredcomponents.pagenames);
    if tabs.count > 0 then begin
     activetab:= 0;
    end;
    for int1:= 0 to tabs.count - 1 do begin
     with tabs[int1] do begin
      tag:= int1 + 1;
      caption:= ar1[int1].caption;
      hint:= ar1[int1].hint;
     end;
    end;
   finally
    componentpages.endupdate;
   end;
  end;
 end;

 componentpalette.beginupdate;
 registeredcomponents.defaultorder:= true;
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
       imagelist.options := [bmo_masked];
       imagenr:= icon;
       hint:= msestring(classtyp.classname);
       tagpo:= classtyp;
      end;
     end;
    end;
   end;
   if int2 <= registeredcomponents.pagehigh then begin
    componentpalette.buttons.order(registeredcomponents.pagecomporders[int2]);
   end;
  end;
 finally
  registeredcomponents.defaultorder:= false;
  componentpalette.endupdate;
 end;
end;

procedure tcomponentpalettefo.foonreadstat(const sender: TObject;
                                                  const reader: tstatreader);
begin
 updatecomponentpalette(true);
end;

procedure tcomponentpalettefo.resetselected;
begin
 componentpalette.buttons.resetradioitems(0);
end;

end.
