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
const
 defaultmidiattackvalueoptions = [vso_exp,vso_null];
 defaultmidiattackvaluemin = 0.1; //20 dB
 defaultmidireleasevalueoptions = [];
 defaultmidireleasevaluemin = 0;
 defaultmidipressurevalueoptions = [];
 defaultmidipressurevaluemin = 0;
 defaultmidivaluemax = 1;
 paramscale = 1/127; //0..1
type  
 tsigmidisource = class;
 
 tsigmidiconnector = class(tsigeventconnector)
  private
   ffrequout: tdoubleoutputconn;
   ftrigout: tdoubleoutputconn;
   ffrequ_min: double;
   fattack: doublescaleinfoty;
   fpressure: doublescaleinfoty;
   frelease: doublescaleinfoty;
   fsource: tsigmidisource;
   fchannel: integer;
   fattackout: tdoubleoutputconn;
   fpressureout: tdoubleoutputconn;
   freleaseout: tdoubleoutputconn;
   procedure setfrequout(const avalue: tdoubleoutputconn);
   procedure settrigout(const avalue: tdoubleoutputconn);
   procedure setsource(const avalue: tsigmidisource);
   procedure setchannel(const avalue: integer);
   procedure setattack_min(const avalue: double);
   procedure setattack_max(const avalue: double);
   procedure setattack_options(const avalue: valuescaleoptionsty);
   procedure setpressure_min(const avalue: double);
   procedure setpressure_max(const avalue: double);
   procedure setpressure_options(const avalue: valuescaleoptionsty);
   procedure setrelease_min(const avalue: double);
   procedure setrelease_max(const avalue: double);
   procedure setrelease_options(const avalue: valuescaleoptionsty);
   procedure setattackout(const avalue: tdoubleoutputconn);
   procedure setpressureout(const avalue: tdoubleoutputconn);
   procedure setreleaseout(const avalue: tdoubleoutputconn);
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
   property attackout: tdoubleoutputconn read fattackout write setattackout;
   property pressureout: tdoubleoutputconn read fpressureout 
                                                write setpressureout;
   property releaseout: tdoubleoutputconn read freleaseout write setreleaseout;
  published
   property frequ_min: double read ffrequ_min write ffrequ_min;
   property attack_min: double read fattack.min write setattack_min;
   property attack_max: double read fattack.max write setattack_max;
   property attack_options: valuescaleoptionsty read fattack.options 
              write setattack_options default defaultmidiattackvalueoptions;

   property pressure_min: double read fpressure.min write setpressure_min;
   property pressure_max: double read fpressure.max write setpressure_max;
   property pressure_options: valuescaleoptionsty read fpressure.options 
             write setpressure_options default defaultmidipressurevalueoptions;

   property release_min: double read frelease.min write setrelease_min;
   property release_max: double read frelease.max write setrelease_max;
   property release_options: valuescaleoptionsty read frelease.options 
            write setrelease_options default defaultmidireleasevalueoptions;

   property source: tsigmidisource read fsource write setsource;
   property channel: integer read fchannel write setchannel default 0;
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
   procedure patchchanged;
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
 initscale(defaultmidiattackvaluemin,defaultmidivaluemax,
                                   defaultmidiattackvalueoptions,fattack);
 initscale(defaultmidireleasevaluemin,defaultmidivaluemax,
                                   defaultmidireleasevalueoptions,frelease);
 initscale(defaultmidipressurevaluemin,defaultmidivaluemax,
                                   defaultmidipressurevalueoptions,fpressure);
 ffrequ_min:= 0.001;
 ffrequout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ffrequout.name:= 'frequout';
 ftrigout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ftrigout.name:= 'trigout';
 fattackout:= tdoubleoutputconn.create(self,isigclient(self),true);
 fattackout.name:= 'attackout';
 fpressureout:= tdoubleoutputconn.create(self,isigclient(self),true);
 fpressureout.name:= 'pressureout';
 freleaseout:= tdoubleoutputconn.create(self,isigclient(self),true);
 freleaseout.name:= 'releaseout';
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
 setlength(result,5);
 result[0]:= ftrigout;
 result[1]:= ffrequout;
 result[2]:= fattackout;
 result[3]:= fpressureout;
 result[4]:= freleaseout;
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
    mmk_notepressure: begin
     fpressure.value:= par2*paramscale;
     tdoubleoutputconn1(fpressureout).fvalue:= scalevalue(fpressure);
    end;
    mmk_noteon: begin
     tdoubleoutputconn1(ffrequout).fvalue:= intpower(2.0,par1 div 12) * 
                          chromaticscale[par1 mod 12] * ffrequ_min;
     if par2 = 0 then begin
      ftrigvalue:= -1;
      frelease.value:= 0;
      tdoubleoutputconn1(freleaseout).fvalue:= scalevalue(frelease);
     end
     else begin
      ftrigvalue:= 1;
      fattack.value:= par2*paramscale;
      tdoubleoutputconn1(fattackout).fvalue:= scalevalue(fattack);
     end;
     tdoubleoutputconn1(ftrigout).fvalue:= ftrigvalue;
    end;
    mmk_noteoff: begin
     ftrigvalue:= -1;
     frelease.value:= par2*paramscale;
     tdoubleoutputconn1(freleaseout).fvalue:= scalevalue(frelease);
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

procedure tsigmidiconnector.setchannel(const avalue: integer);
begin
 if fchannel <> avalue then begin
  fchannel:= avalue;
  if fsource <> nil then begin
   fsource.patchchanged;
  end;
 end;
end;

procedure tsigmidiconnector.setattack_min(const avalue: double);
begin
 fattack.min:= avalue;
 updatescale(fattack);
end;

procedure tsigmidiconnector.setattack_max(const avalue: double);
begin
 fattack.max:= avalue;
 updatescale(fattack);
end;

procedure tsigmidiconnector.setattack_options(const avalue: valuescaleoptionsty);
begin
 fattack.options:= avalue;
 updatescale(fattack);
end;

procedure tsigmidiconnector.setpressure_min(const avalue: double);
begin
 fpressure.min:= avalue;
 updatescale(fpressure);
end;

procedure tsigmidiconnector.setpressure_max(const avalue: double);
begin
 fpressure.max:= avalue;
 updatescale(fpressure);
end;

procedure tsigmidiconnector.setpressure_options(const avalue: valuescaleoptionsty);
begin
 fpressure.options:= avalue;
 updatescale(fpressure);
end;

procedure tsigmidiconnector.setrelease_min(const avalue: double);
begin
 frelease.min:= avalue;
 updatescale(frelease);
end;

procedure tsigmidiconnector.setrelease_max(const avalue: double);
begin
 frelease.max:= avalue;
 updatescale(frelease);
end;

procedure tsigmidiconnector.setrelease_options(const avalue: valuescaleoptionsty);
begin
 frelease.options:= avalue;
 updatescale(frelease);
end;

procedure tsigmidiconnector.setattackout(const avalue: tdoubleoutputconn);
begin
 fattackout.assign(avalue);
end;

procedure tsigmidiconnector.setpressureout(const avalue: tdoubleoutputconn);
begin
 fpressureout.assign(avalue);
end;

procedure tsigmidiconnector.setreleaseout(const avalue: tdoubleoutputconn);
begin
 freleaseout.assign(avalue);
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

procedure tsigmidisource.patchchanged;
begin
 exclude(fsigstate,smss_patchvalid);
end;

procedure tsigmidisource.registerconnector(const avalue: tsigmidiconnector);
begin
 additem(pointerarty(fconnections),avalue);
 patchchanged;
end;

procedure tsigmidisource.unregisterconnector(const avalue: tsigmidiconnector);
begin
 removeitem(pointerarty(fconnections),avalue);
 patchchanged;
end;

procedure tsigmidisource.dotrackevent;
var
 int1: integer;
 po1: pconnectioninfoty;
 by1: byte;
begin
 inherited;
 if not (smss_patchvalid in fsigstate) then begin
  updatepatch;
 end;
 with fchannels[ftrackevent.event.channel and $0f] do begin
  if connections <> nil then begin
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
 int1,int2: integer;
begin
 fchannels:= nil;
 setlength(fchannels,16);
 for int1:= 0 to high(fconnections) do begin
  with fchannels[fconnections[int1].channel and $0f] do begin
   int2:= high(connections)+1;
   setlength(connections,int2+1);
   connections[int2].dest:= fconnections[int1];
  end;
 end;
 for int2:= 0 to high(fchannels) do begin
  with fchannels[int2] do begin
   first:= nil;
   last:= nil;
//   connections:= nil;
//   setlength(connections,length(fconnections)); //init with zero
   if high(connections) >= 0 then begin
    first:= @connections[0];
    last:= @connections[high(connections)];
    for int1:= 0 to high(connections) do begin
     with connections[int1] do begin
//      dest:= fconnections[int1];
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
 end;
 include(fsigstate,smss_patchvalid);
end;

end.
