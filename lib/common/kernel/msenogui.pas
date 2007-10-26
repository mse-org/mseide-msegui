{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msenogui;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 sysutils,classes,mseapplication,mseevent;
type
 tnoguiapplication = class(tcustomapplication)
  protected
   procedure dopostevent(const aevent: tevent); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure showexception(e: exception; const leadingtext: string = '');
                                  override;
   procedure settimer(const us: integer); override;
 end;
 
function application: tnoguiapplication;
 
implementation
uses
 msesysutils;
var
 appinst: tnoguiapplication;
 
function application: tnoguiapplication;
begin
 if appinst = nil then begin
  tnoguiapplication.create(nil);
//  appinst.initialize;
 end;
 result:= appinst;
end;

{ tnoguiapplication }

constructor tnoguiapplication.create(aowner: tcomponent);
begin
 inherited;
 appinst:= self;
end;

procedure tnoguiapplication.dopostevent(const aevent: tevent);
begin
 eventlist.add(aevent);
end;

procedure tnoguiapplication.showexception(e: exception;
               const leadingtext: string = '');
begin
 writestderr('EXCEPTION:');
 writestderr(leadingtext+e.message,true);
end;

procedure tnoguiapplication.settimer(const us: integer);
begin
end;

initialization
 registerapplicationclass(tnoguiapplication);
end.
