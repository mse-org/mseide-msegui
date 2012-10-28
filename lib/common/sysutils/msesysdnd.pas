{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysdnd;
//under construction

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseevent,msegui,msetypes,msegraphutils,mseguiglob,msedrag,msestrings,
 msemime;
type

 tsysdndevent = class(twindowevent)
  private
  public
   ftypes: stringarty;   
   fpos: pointty;
   fshiftstate: shiftstatesty;
   fscroll: boolean;
   fdndkind: drageventkindty;
   constructor create(const adndkind: drageventkindty;
            const awinid: winidty; const apos: pointty;
            const ashiftstate: shiftstatesty; const ascroll: boolean;
            const atypes: stringarty);
 end;

 tsysmimedragobject = class(tmimedragobject)
  private
  protected
   function getdata: string; override;
   function gettext: msestring; override;
  public
 end;
  
implementation
uses
 msearrayutils,mseguiintf;
 
{ tsysdndevent }

constructor tsysdndevent.create(const adndkind: drageventkindty;
                 const awinid: winidty; const apos: pointty;
                 const ashiftstate: shiftstatesty; const ascroll: boolean;
                 const atypes: stringarty);
begin
 fdndkind:= adndkind;
 fpos:= apos;
 fshiftstate:= ashiftstate;
 fscroll:= ascroll;
 ftypes:= atypes;
 inherited create(ek_sysdnd,awinid);
end;

{ tsysmimedragobject }

function tsysmimedragobject.getdata: string;
begin
 guierror(gui_sysdndreaddata(result,typeindex),'Can not read sysdnd data.');
end;

function tsysmimedragobject.gettext: msestring;
begin
 guierror(gui_sysdndreadtext(result,typeindex),'Can not read sysdnd text.');
end;

end.
