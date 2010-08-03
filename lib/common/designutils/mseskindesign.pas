{ MSEide Copyright (c) 2010 by Martin Schreiber
   
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
unit mseskindesign;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseskin,mseclasses,classes;
 
type
 tskinhandlerdesign = class(tskinhandler)
  protected
   factiveskincontrollerdesign: skincontrollerarty;
   procedure updateactive(const sender: tcustomskincontroller); override;
//   procedure updateskindesign(const ainfo: skininfoty);
//   procedure removeskindesign(const ainfo: skininfoty);
//   procedure doactivate(const sender: tcustomskincontroller); override;
//   procedure dodeactivate(const sender: tcustomskincontroller); override;
 end;
 
implementation
uses
 msedesigner;
 
{ tskinhandlerdesign }
{
procedure tskinhandlerdesign.updateskindesign(const ainfo: skininfoty);
begin
 updateskin1(ainfo,factiveskincontrollerdesign);
end;

procedure tskinhandlerdesign.removeskindesign(const ainfo: skininfoty);
begin
 removeskin1(ainfo,factiveskincontrollerdesign);
end;
}
procedure tskinhandlerdesign.updateactive(const sender: tcustomskincontroller);
begin
 if csdesigning in sender.componentstate then begin
   //do nothing
//  setactive(sender,factiveskincontrollerdesign,
//              @updateskindesign,oninitskinobjectdesign{,
//              @removeskindesign,onremoveskinobjectdesign});
 end
 else begin
  inherited;
 end;
end;
{
procedure tskinhandlerdesign.doactivate(const sender: tcustomskincontroller);
var
 int1: integer;
begin
 if csdesigning in sender.componentstate then begin
  for int1:= 0 to designer.modules.count - 1 do begin
   designer.modules.itempo[int1]^.instance.updateskin(true);
  end;
 end;
end;

procedure tskinhandlerdesign.dodeactivate(const sender: tcustomskincontroller);
var
 int1: integer;
begin
 if csdesigning in sender.componentstate then begin
  for int1:= 0 to designer.modules.count - 1 do begin
   designer.modules.itempo[int1]^.instance.removeskin(true);
  end;
 end;
end;
}
initialization
 setskinhandler(tskinhandlerdesign.create);
end.
