{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysdnd;
//under construction

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 mseevent,msetypes,msegraphutils,mseguiglob,msedrag,msestrings,
 msemime,mseglob,msegui;
 
type

 tsysdndevent = class(twindowevent)
  private
  public
   ftypes: stringarty;   
   fpos: pointty;
   fshiftstate: shiftstatesty;
   fscroll: boolean;
   fdndkind: drageventkindty;
   faction: dndactionty;
   constructor create(const adndkind: drageventkindty;
            const awinid: winidty; const apos: pointty;
            const ashiftstate: shiftstatesty; const ascroll: boolean;
            const atypes: stringarty; const aaction: dndactionty);
 end;

 tsysdndstatusevent = class(tobjectevent)
  private
   faccept: boolean;
  public
   constructor create(const aintf: ievent; const aaccept: boolean);
   property accept: boolean read faccept;
 end;
 
 tsysmimedragobject = class(tmimedragobject,isysdnd)
  private
  protected
   procedure checkwritable;
   procedure setdata(const avalue: string); override;
   procedure settext(const avalue: msestring); override;
   function getdata: string; override;
   function gettext: msestring; override;
   procedure cancelsysdnd; virtual;
    //isysdnd
   function gettypes: stringarty;
   function getaction: dndactionty;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
         const apickpos: pointty; const atypes: array of string;
                  const aaction: dndactionty = dnda_none;
                             const aintf: imimesource = nil); override;
   constructor createwrite(const asender: tobject; var instance: tdragobject;
               const apickpos: pointty; const atypes: array of string;
               const aaction: dndactionty = dnda_none;
               const aintf: imimesource = nil);
 end;
  
implementation
uses
 msearrayutils,mseguiintf,sysutils;
 
{ tsysdndevent }

constructor tsysdndevent.create(const adndkind: drageventkindty;
                 const awinid: winidty; const apos: pointty;
                 const ashiftstate: shiftstatesty; const ascroll: boolean;
                 const atypes: stringarty; const aaction: dndactionty);
begin
 fdndkind:= adndkind;
 fpos:= apos;
 fshiftstate:= ashiftstate;
 fscroll:= ascroll;
 ftypes:= atypes;
 faction:= aaction;
 inherited create(ek_sysdnd,awinid);
end;

{ tsysmimedragobject }

constructor tsysmimedragobject.create(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const atypes: array of string;
                       const aaction: dndactionty = dnda_none;
                       const aintf: imimesource = nil);
begin
 fsysdndintf:= isysdnd(self);
 include(fstate,dos_sysdnd);
 inherited create(asender,instance,apickpos,atypes,aaction,aintf);
end;

constructor tsysmimedragobject.createwrite(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const atypes: array of string;
               const aaction: dndactionty = dnda_none;
               const aintf: imimesource = nil);
begin
 include(fstate,dos_sysdnd);
 inherited createwrite(asender,instance,apickpos,atypes,aaction,aintf);
end;

function tsysmimedragobject.getdata: string;
begin
 if dos_write in fstate then begin
  result:= inherited getdata;
 end
 else begin
  result:= '';
  gui_sysdndreaddata(result,typeindex);
//  guierror(gui_sysdndreaddata(result,typeindex),'Can not read sysdnd data.');
 end;
end;

function tsysmimedragobject.gettext: msestring;
begin
 if dos_write in fstate then begin
  result:= inherited gettext;
 end
 else begin
  result:= '';
  gui_sysdndreadtext(result,typeindex);
//  guierror(gui_sysdndreadtext(result,typeindex),'Can not read sysdnd text.');
 end;
end;

procedure tsysmimedragobject.checkwritable;
begin
 if not (dos_write in fstate) then begin
  raise exception.create('Dragobject is readonly');
 end;
end;

procedure tsysmimedragobject.setdata(const avalue: string);
begin
 checkwritable;
 inherited;
end;

procedure tsysmimedragobject.settext(const avalue: msestring);
begin
 checkwritable;
 inherited;
end;

procedure tsysmimedragobject.cancelsysdnd;
begin
 destroy;
end;

function tsysmimedragobject.gettypes: stringarty;
begin
 result:= types;
end;

function tsysmimedragobject.getaction: dndactionty;
begin
 result:= faction;
end;

{ tsysdndstatusevent }

constructor tsysdndstatusevent.create(const aintf: ievent;
               const aaccept: boolean);
begin
 faccept:= aaccept;
 inherited create(ek_sysdndstatus,aintf);
end;

end.
