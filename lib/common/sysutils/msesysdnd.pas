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
 mseevent,msegui,msetypes,msegraphutils,mseguiglob,msedrag;
type
 
 tsysdndevent = class(twindowevent)
  private
  public
   fpos: pointty;
   fshiftstate: shiftstatesty;
   fscroll: boolean;
   ftypes: stringarty;
   constructor create(const awinid: winidty; const apos: pointty;
            const ashiftstate: shiftstatesty; const ascroll: boolean;
            const atypes: stringarty);
 end;

 tmimedragobject = class(tdragobject)
  private
   ftypes: stringarty;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
               const apickpos: pointty; const atypes: stringarty);
 end;

 tsysmimedragobject = class(tmimedragobject)
 end;
  
implementation

{ tsysdndevent }

constructor tsysdndevent.create(const awinid: winidty; const apos: pointty;
                 const ashiftstate: shiftstatesty; const ascroll: boolean;
                 const atypes: stringarty);
begin
 fpos:= apos;
 fshiftstate:= ashiftstate;
 fscroll:= ascroll;
 ftypes:= atypes;
 inherited create(ek_sysdnd,awinid);
end;

{ tmimedragobject }

constructor tmimedragobject.create(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const atypes: stringarty);
begin
 ftypes:= atypes;
 inherited create(asender,instance,apickpos);
end;

end.
