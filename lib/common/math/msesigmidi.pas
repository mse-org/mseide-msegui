{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesigmidi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesignal,classes,msemidi,msetypes;
type
 tsigmidisource = class;
 
 tsigmidiconnector = class(tsigeventconnector)
  private
   ffrequout: tdoubleoutputconn;
   ftrigout: tdoubleoutputconn;
   ffrequmin: double;
   fsource: tsigmidisource;
   procedure setfrequout(const avalue: tdoubleoutputconn);
   procedure settrigout(const avalue: tdoubleoutputconn);
   procedure setsource(const avalue: tsigmidisource);
  protected
   ftrigvalue: double;
   procedure sighandler(const ainfo: psighandlerinfoty);
   function getoutputar: outputconnarty; override;
   function gethandler: sighandlerprocty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure midievent(const ainfo: midieventinfoty);
   property frequout: tdoubleoutputconn read ffrequout write setfrequout;
   property trigout: tdoubleoutputconn read ftrigout write settrigout;
  published
   property frequmin: double read ffrequmin write ffrequmin;
   property source: tsigmidisource read fsource write setsource;
 end;
 sigmidiconnectorarty = array of tsigmidiconnector;

 channelinfoty = record
  
 end;

 sigmidisourcestatety = (smss_patchvalid);
 sigmidisourcestatesty = set of sigmidisourcestatety;

 pconnectioninfoty = ^connectioninfoty;
 connectioninfoty = record
  dest: tsigmidiconnector;
  prev: pconnectioninfoty;
  next: pconnectioninfoty;
  key: byte;
 end;
 connectioninfoarty = array of connectioninfoty;
  
 sigchannelinfoty = record
  connections: connectioninfoarty;
  first,last: pconnectioninfoty;  
 end;
   
 sigchannelinfoarty = array of sigchannelinfoty;
 
 tsigmidisource = class(tmidisource)
  private
   fconnections: sigmidiconnectorarty;
  protected
   fsigstate: sigmidisourcestatesty;
   fchannels: sigchannelinfoarty;
   procedure registerconnector(const avalue: tsigmidiconnector);
   procedure unregisterconnector(const avalue: tsigmidiconnector);
   procedure dotrackevent; override;
   procedure updatepatch;
  public
   destructor destroy; override;
 end;
 
implementation
uses
 math,msedatalist;
type
 tsigcontroller1 = class(tsigcontroller);
 tdoubleoutputconn1 = class(tdoubleoutputconn);
 
{ tsigmidiconnector }

constructor tsigmidiconnector.create(aowner: tcomponent);
begin
 ffrequmin:= 0.001;
 ffrequout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ffrequout.name:= 'frequout';
 ftrigout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ftrigout.name:= 'trigout';
 inherited;
end;

destructor tsigmidiconnector.destroy;
begin
 source:= nil;
 inherited;
end;

procedure tsigmidiconnector.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 ainfo^.dest^:= ftrigvalue;
end;

function tsigmidiconnector.getoutputar: outputconnarty;
begin
 setlength(result,2);
 result[0]:= ftrigout;
 result[1]:= ffrequout;
end;

function tsigmidiconnector.gethandler: sighandlerprocty;
begin
 result:= @sighandler;
end;

procedure tsigmidiconnector.setfrequout(const avalue: tdoubleoutputconn);
begin
 ffrequout.assign(avalue);
end;

procedure tsigmidiconnector.settrigout(const avalue: tdoubleoutputconn);
begin
 ftrigout.assign(avalue);
end;

procedure tsigmidiconnector.midievent(const ainfo: midieventinfoty);
begin
 lock;
 try
  with ainfo do begin
   case kind of
    mmk_noteon: begin
     tdoubleoutputconn1(ffrequout).fvalue:= intpower(2.0,par1 div 12) * 
                          chromaticscale[par1 mod 12] * ffrequmin;
     if par2 = 0 then begin
      ftrigvalue:= -1;
     end
     else begin
      ftrigvalue:= 1;
     end;
    end;
    mmk_noteoff: begin
     ftrigvalue:= -1;
    end;
   end;
  end;
  if fcontroller <> nil then begin
   tsigcontroller1(fcontroller).execevent(isigclient(self));
  end;
 finally
  unlock;
 end;
end;

procedure tsigmidiconnector.setsource(const avalue: tsigmidisource);
begin
 if fsource <> avalue then begin
  if fsource <> nil then begin
   fsource.unregisterconnector(self);
  end;
  fsource:= avalue;
  if fsource <> nil then begin
   fsource.registerconnector(self);
  end;
 end;
end;

{ tsigmidisource }

destructor tsigmidisource.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fconnections) do begin
  fconnections[int1].fsource:= nil;
 end;
 inherited;
end;

procedure tsigmidisource.registerconnector(const avalue: tsigmidiconnector);
begin
 additem(pointerarty(fconnections),avalue);
 exclude(fsigstate,smss_patchvalid);
end;

procedure tsigmidisource.unregisterconnector(const avalue: tsigmidiconnector);
begin
 removeitem(pointerarty(fconnections),avalue);
 exclude(fsigstate,smss_patchvalid);
end;

procedure tsigmidisource.dotrackevent;
var
 int1: integer;
 po1: pconnectioninfoty;
 by1: byte;
begin
 inherited;
 if fconnections <> nil then begin
  if not (smss_patchvalid in fsigstate) then begin
   updatepatch;
  end;
  with fchannels[0] do begin
   po1:= first;
   by1:= ftrackevent.event.par1;
   repeat
    if po1^.key = by1 then begin
     break;
    end;
    po1:= po1^.next;
   until po1 = nil;
   if po1 <> first then begin
    if po1 = nil then begin
     po1:= last;
    end;
    if po1^.prev <> nil then begin
     po1^.prev^.next:= po1^.next;
    end;
    if (po1^.next <> nil) then begin
     po1^.next^.prev:= po1^.prev;
    end;
    first^.prev:= po1;
    po1^.next:= first;
    first:= po1;
    if po1 = last then begin
     last:= po1^.prev;
    end;
    po1^.prev:= nil;
   end;
   po1^.key:= by1;
   po1^.dest.midievent(ftrackevent.event);
  end;
 end;
end;

procedure tsigmidisource.updatepatch;
var
 int1: integer;
begin
 setlength(fchannels,1);
 with fchannels[0] do begin
  first:= nil;
  last:= nil;
  connections:= nil;
  setlength(connections,length(fconnections)); //init with zero
  if high(connections) >= 0 then begin
   first:= @connections[0];
   last:= @connections[high(connections)];
   for int1:= 0 to high(connections) do begin
    with connections[int1] do begin
     dest:= fconnections[int1];
     if int1 < high(connections) then begin
      next:= @connections[int1+1];
     end;
     if int1 > 0 then begin
      prev:= @connections[int1-1];
     end;
    end;
   end;
  end;
 end;
 include(fsigstate,smss_patchvalid);
end;

end.
