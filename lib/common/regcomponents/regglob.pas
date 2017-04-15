{ MSEide Copyright (c) 1999-2011 by Martin Schreiber

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
unit regglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msepropertyeditors,typinfo,msebitmap,msestrings;
 
type
 tstockglypheditor = class(tenumpropertyeditor)
  protected
   function hasimagelist(): boolean;
   function gettypeinfo: ptypeinfo; override;
   function getdefaultstate: propertystatesty; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
  public
   procedure edit; override;
 end;

 tstockglypharraypropertyeditor = class(tintegerarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 timagenrpropertyeditor = class(tordinalpropertyeditor)
  private
   fintf: iimagelistinfo;
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

implementation
uses
 msestockobjects,mseimageselectorform,mseclasses,mseformatstr;
 
{ tstockglypharraypropertyeditor }

function tstockglypharraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tstockglypheditor;
end;

{ tstockglypheditor }

function tstockglypheditor.gettypeinfo: ptypeinfo;
begin
 result:= typeinfo(stockglyphty);
end;

function tstockglypheditor.hasimagelist(): boolean;
var
 intf1: iimagelistinfo;
begin
 result:= getcorbainterface(fprops[0].instance,
           typeinfo(iimagelistinfo),intf1) and (intf1.getimagelist() <> nil);
end;

function tstockglypheditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
 if hasimagelist then begin
  result:= result - [ps_valuelist];
 end;
end;

procedure tstockglypheditor.setvalue(const value: msestring);
begin
 if hasimagelist then begin
  setordvalue(strtointvalue(ansistring(value)));
 end
 else begin
  inherited;
 end;
end;

function tstockglypheditor.getvalue: msestring;
begin
 if hasimagelist then begin
  result:= inttostrmse(getordvalue);
 end
 else begin
  result:= inherited getvalue();
 end;
end;

procedure tstockglypheditor.edit;
var
 int1: integer;
 intf1: iimagelistinfo;
 list1: timagelist;
begin
 int1:= getordvalue;
 intf1:= nil;
 if getcorbainterface(fprops[0].instance,
              typeinfo(iimagelistinfo),intf1) then begin
  list1:= intf1.getimagelist;
 end;
 if list1 = nil then begin
  list1:= stockobjects.glyphs;
 end;
 timageselectorfo.create(nil,list1,int1);
 setordvalue(int1);
end;

{ timagenrpropertyeditor }

function timagenrpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 if getcorbainterface(fprops[0].instance,typeinfo(iimagelistinfo),fintf) and 
                     (fintf.getimagelist <> nil) then begin
  result:= result + [ps_dialog];
 end;
end;

procedure timagenrpropertyeditor.edit;
var
 int1: integer;
begin
 if fintf <> nil then begin
  int1:= getordvalue;
  timageselectorfo.create(nil,fintf.getimagelist,int1);
  setordvalue(int1);
 end;
end;

end.
