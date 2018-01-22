{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

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
 classes,mclasses,mseerr,msetypes;
const
 invalidaxis = -bigint;
 defaultbase64linelength = 76; //todo: find better place
 
type
 shortcutty = type word;
 shortcutconstty = array[0..2] of shortcutty;
 shortcutarty = array of shortcutty;
 modalresultty = (mr_none,mr_canclose,mr_windowclosed,mr_windowdestroyed,
                  mr_escape,mr_f10, 
                  mr_exception,
                  mr_cancel,mr_abort,mr_ok,mr_yes,mr_no,mr_all,
                  mr_yesall,mr_noall,
                  mr_ignore,mr_skip,mr_skipall,mr_continue);
 pmodalresultty = ^modalresultty;
 modalresultsty = set of modalresultty;

 inullinterface = interface
  //no referencecount, only for fpc, not available in delphi
 end;
 
// {$ifdef FPC}
// tnullinterfacedobject = class(tobject) //not used
// end;
// {$else}
 tnullinterfacedobject = class(tobject,iunknown)
  protected
   function _addref: integer;
                  {$ifdef FPC}
                    {$ifdef mswindows}stdcall{$else} cdecl{$endif};
                  {$else}stdcall;{$endif}
                   
   function _release: integer;
                  {$ifdef FPC}
                   {$ifdef mswindows}stdcall{$else} cdecl{$endif};
                  {$else}stdcall;{$endif}
   function queryinterface(
                {$ifdef fpc_has_constref}constref{$else}const{$endif}
                 iid: tguid; out obj): hresult;
                  {$ifdef FPC}
                   {$ifdef mswindows}stdcall{$else} cdecl{$endif};
                  {$else}stdcall;{$endif}
 end;
// {$endif}
 
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

//{$ifndef fpc}
function tnullinterfacedobject._addref: integer;
                  {$ifdef FPC}
                       {$ifdef mswindows}stdcall{$else} cdecl{$endif};
                  {$else}stdcall;{$endif}
begin
 result:= -1;
end;

function tnullinterfacedobject._release: integer;
                  {$ifdef FPC}
                   {$ifdef mswindows}stdcall{$else} cdecl{$endif};
                  {$else}stdcall;{$endif}
begin
 result:= -1;
end;

function tnullinterfacedobject.QueryInterface(
             {$ifdef fpc_has_constref}constref{$else}const{$endif}
                                        IID: TGUID; out Obj): HResult;
                  {$ifdef FPC}
                                {$ifdef mswindows}stdcall{$else} cdecl{$endif};
                  {$else}stdcall;{$endif}
begin
 if getinterface(iid, obj) then begin
   result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;
//{$endif}

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
