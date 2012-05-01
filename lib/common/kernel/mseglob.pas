{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses 
 classes,mseerr,msetypes;
const
 invalidaxis = -bigint;
type
 shortcutty = type word;
 shortcutarty = array of shortcutty;
 modalresultty = (mr_none,mr_canclose,mr_windowclosed,mr_windowdestroyed,
                  mr_escape,mr_f10, 
                  mr_exception,
                  mr_cancel,mr_abort,mr_ok,mr_yes,mr_no,mr_all,mr_noall,
                  mr_ignore);
 pmodalresultty = ^modalresultty;
 modalresultsty = set of modalresultty;

 inullinterface = interface
  //no referencecount, only for fpc, not available in delphi
 end;

 tnullinterfacedobject = class(tobject)
  protected
   function _addref: integer; stdcall;
   function _release: integer; stdcall;
   function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
 end;

 objecteventty = (oe_destroyed,oe_connect,oe_disconnect,
                  oe_changed,oe_designchanged,
                  oe_activate,oe_deactivate,oe_fired,oe_dataready,
                  oe_bindfields,oe_releasefields);
 objectlinkeventty = procedure(const sender: tobject;
                    const event: objecteventty) of object;
 iobjectlink = interface(inullinterface)
  procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                        ainterfacetype: pointer = nil; once: boolean = false);
  procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
               //source = 1 -> dest destroyed
  procedure objevent(const sender: iobjectlink; const event: objecteventty);
  function getinstance: tobject;
 end;

 mseerrorty = (mse_ok,mse_resnotfound);
 emse = class(eerror)
  private
    function geterror: mseerrorty;
  public
   constructor create(aerror: mseerrorty; atext: string);
   property error: mseerrorty read geterror;
 end;

function fullcomponentname(component: tcomponent): string;


procedure mseerror(error: mseerrorty; text: string = ''); overload;
procedure mseerror(error: mseerrorty; sender: tobject; text: string = ''); overload;

implementation
//uses
// mseclasses;
const
 errortexts: array[mseerrorty] of string = 
 ('',
  'Resource not found'
 );

function fullcomponentname(component: tcomponent): string;
begin
 result:= component.name;
 while component.owner <> nil do begin
  component:= component.owner;
  result:= component.name + '.' + result;
 end;
end;

procedure mseerror(error: mseerrorty; text: string); overload;
begin
 if error = mse_ok then begin
  exit;
 end;
 raise emse.create(error,text);
end;

procedure mseerror(error: mseerrorty; sender: tobject;
                       text: string = ''); overload;
begin
 if error = mse_ok then begin
  exit;
 end;
 if sender <> nil then begin
  text:= sender.classname + ' ' + text;
  if sender is tcomponent then begin
   text:= text + fullcomponentname(tcomponent(sender));
  end;
 end;
 mseerror(error,text);
end;

{ tnullinterfacedobject }

function tnullinterfacedobject._addref: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedobject._release: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedobject.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
 result:= hresult(e_nointerface);
end;

{ emse }

constructor emse.create(aerror: mseerrorty;  atext: string);
begin
 inherited create(integer(aerror),atext,errortexts);
end;

function emse.geterror: mseerrorty;
begin
 result:= mseerrorty(ferror);
end;

end.
