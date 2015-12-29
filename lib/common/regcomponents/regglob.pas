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
 msepropertyeditors,typinfo,msebitmap;
 
type
 tstockglypheditor = class(tenumpropertyeditor)
  protected
   function gettypeinfo: ptypeinfo; override;
   function getdefaultstate: propertystatesty; override;
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
 msestockobjects,mseimageselectorform,mseclasses;
 
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

function tstockglypheditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tstockglypheditor.edit;
var
 int1: integer;
begin
 int1:= getordvalue;
 timageselectorfo.create(nil,stockobjects.glyphs,int1);
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
