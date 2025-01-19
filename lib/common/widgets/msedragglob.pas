{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedragglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,msegraphutils,mseguiglob,mseevent;

type
 dragobjstatety = (dos_dropped,dos_sysdnd,dos_write,dos_sysdroppending);
 dragobjstatesty = set of dragobjstatety;

 pdragobject = ^tdragobject;
 tdragobject = class(tnullinterfacedobject)
  private
   fpickpos: pointty;
   fdroppos: pointty;
   function getdropped: boolean;
  protected
   finstancepo: pdragobject;
   fsender: tobject;
   fstate: dragobjstatesty;
   fsysdndintf: isysdnd;
   feventintf: ievent;
   factions: dndactionsty;
   function checksysdnd(const aaction: sysdndactionty;
                             const arect: rectty): boolean;
    //isysdnd
   function geteventintf: ievent;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
                          const apickpos: pointty; //clientorigin
                          const aactions: dndactionsty = []);
   destructor destroy; override;
   function sender: tobject;
   procedure acepted(const apos: pointty); virtual;        //screenorigin
   procedure refused(const apos: pointty); virtual;        //screenorigin
   property pickpos: pointty read fpickpos write fpickpos; //clientorigin
   property droppos: pointty read fdroppos write fdroppos; //screenorigin
   property state: dragobjstatesty read fstate;
   property dropped: boolean read getdropped;
   property actions: dndactionsty read factions write factions;
 end;

 drageventkindty = (dek_begin,dek_check,dek_drop,dek_end,
                    dek_leavesysdnd,dek_leavewidget);

 draginfoty = record
  eventkind: drageventkindty;
  pos: pointty;           //origin = clientrect.pos
  pickpos: pointty;       //origin = screenorigin
  clientpickpos: pointty; //origin = clientrect.pos
  dragobjectpo: pdragobject;
  accept: boolean;
 end;

implementation

uses
 mseapplication,msegui,mseguiintf;
type
 tguiapplication1 = class(tguiapplication);

{ tdragobject }

constructor tdragobject.create(const asender: tobject; var instance: tdragobject;
                                 const apickpos: pointty;
                                 const aactions: dndactionsty);
begin
 fsender:= asender;
 finstancepo:= @instance;
 if finstancepo <> nil then begin
  instance.Free;
  instance:= self;
 end;
 fpickpos:= apickpos;
 factions:= aactions;
 tguiapplication1(application).dragstarted;
end;

destructor tdragobject.destroy;
begin
 checksysdnd(sdnda_destroyed,nullrect);
 if finstancepo <> nil then begin
  finstancepo^:= nil;
 end;
 inherited;
end;

function tdragobject.getdropped: boolean;
begin
 result:= dos_dropped in fstate;
end;

procedure tdragobject.acepted(const apos: pointty);
begin
 //dummy
end;

procedure tdragobject.refused(const apos: pointty);
begin
 //dummy
end;

function tdragobject.sender: tobject;
begin
 result:= fsender;
end;

function tdragobject.checksysdnd(const aaction: sysdndactionty;
                                 const arect: rectty): boolean;
begin
 result:= false;
 if dos_sysdnd in fstate then begin
{$ifndef usesdl}
  gui_sysdnd(aaction,fsysdndintf,arect,result);
{$endif}
 end;
end;

function tdragobject.geteventintf: ievent;
begin
 result:= feventintf;
end;

end.
