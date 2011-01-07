{ MSEgui Copyright (c) 2010-2011 by Martin Schreiber

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
 msesignal,classes,msemidi,msetypes,mseclasses,msedatamodules;
const
 defaultmidiattackvalueoptions = [vso_exp,vso_null];
 defaultmidiattackvaluemin = 0.1; //20 dB
 defaultmidireleasevalueoptions = [];
 defaultmidireleasevaluemin = 0;
 defaultmidipressurevalueoptions = [];
 defaultmidipressurevaluemin = 0;
 defaultmidivaluemax = 1;
 paramscale = 1/127; //0..1
 defaultconnectorname = 'midiconn';
 
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

 tsigmidimulticonnector = class;
 getvoiceclasseventty = procedure(const sender: tobject;
                           var avoiceclass: datamoduleclassty) of object;
 initvoiceeventty = procedure(const sender: tsigmidimulticonnector;
               const aindex: integer; const avoice: tmsedatamodule) of object;

 tdoubleoutmultiinpconn = class(tdoubleoutputconn)
  private
   finputs: tdoubleinpconnarrayprop;
  public
   constructor create(const aowner: tcomponent;
         const asigintf: isigclient; const aeventdriven: boolean); override;
   destructor destroy; override;
   property inputs: tdoubleinpconnarrayprop read finputs;
 end;
 
 tmidiconnoutputarrayprop = class(tdoubleoutconnarrayprop)
  private
   function getitems(const index: integer): tdoubleoutmultiinpconn;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   property items[const index: integer]: tdoubleoutmultiinpconn 
                                              read getitems; default;
 end;
 
 tsigmidimulticonnector = class(tdoublesigcomp,isigclient)
  private
   fongetvoiceclass: getvoiceclasseventty;
   fconnectorname: string;
   finputcount: integer;
   fpendinginputcount: integer;
   foutputcount: integer;
   fvoices: msedatamodulearty;
   fconnectors: sigmidiconnectorarty;
   foninitvoice: initvoiceeventty;
   foutputs: tmidiconnoutputarrayprop;
   finps: doublepoarty;
   fouts: doublepoarty;
   foutputhigh,finputhigh: integer;
   fsource: tsigmidisource;
   fchannel: integer;
   function getitems(const index: integer): tmsedatamodule;
   procedure setitems(const index: integer; const avalue: tmsedatamodule);
   procedure setinputcount(const avalue: integer);
   function getoutputcount: integer;
   procedure setoutputcount(const avalue: integer);
   procedure setsource(const avalue: tsigmidisource);
   procedure updatesource;
   procedure setchannel(const avalue: integer);
  protected
   procedure doinitvoice(const aindex: integer);
   procedure loaded; override;
    //isigclient
   procedure initmodel; override;
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
   function getinputar: inputconnarty; override;
   function getoutputar: outputconnarty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property items[const index: integer]: tmsedatamodule read getitems 
                                                     write setitems; default;
   property outputs: tmidiconnoutputarrayprop read foutputs;
  published
   property inputcount: integer read finputcount write setinputcount default 0;
   property outputcount: integer read getoutputcount 
                                             write setoutputcount default 0;
   property source: tsigmidisource read fsource write setsource;   
   property channel: integer read fchannel write setchannel default 0;
   property connectorname: string read fconnectorname write fconnectorname;
                                //'' -> defaultconnectorname
   property ongetvoiceclass: getvoiceclasseventty read fongetvoiceclass 
                                                  write fongetvoiceclass;
   property oninitvoice: initvoiceeventty read foninitvoice write foninitvoice;
 end;
  
implementation
uses
 math,msedatalist,sysutils;
type
 tsigcontroller1 = class(tsigcontroller);
 tdoubleoutputconn1 = class(tdoubleoutputconn);
 tdoubleinputconn1 = class(tdoubleinputconn);
 
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
   if po1 <> last then begin
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

{ tdoubleoutmultiinpconn }

constructor tdoubleoutmultiinpconn.create(const aowner: tcomponent;
               const asigintf: isigclient; const aeventdriven: boolean);
begin
 finputs:= tdoubleinpconnarrayprop.create(asigintf);
 inherited;
end;

destructor tdoubleoutmultiinpconn.destroy;
begin
 finputs.free;
 inherited;
end;

{ tmidiconnoutputarrayprop }

function tmidiconnoutputarrayprop.getitems(const index: integer):
                                             tdoubleoutmultiinpconn;
begin
 result:= tdoubleoutmultiinpconn(inherited getitems(index));
end;

procedure tmidiconnoutputarrayprop.createitem(const index: integer;
               var item: tpersistent);
begin
 item:= tdoubleoutmultiinpconn.create(fowner,fsigintf,feventdriven);
 tdoubleoutputconn(item).name:= fname+inttostr(index);
end;

{ tsigmidimulticonnector }

constructor tsigmidimulticonnector.create(aowner: tcomponent);
begin
 foutputs:= tmidiconnoutputarrayprop.create(self,'output',
                                              isigclient(self),false);
 inherited;
end;

destructor tsigmidimulticonnector.destroy;
begin
 inputcount:= 0;
 foutputs.free;
 inherited;
end;

function tsigmidimulticonnector.getitems(const index: integer): tmsedatamodule;
begin
 checkarrayindex(fvoices,index);
 result:= fvoices[index];
end;

procedure tsigmidimulticonnector.setitems(const index: integer;
               const avalue: tmsedatamodule);
begin
 checkarrayindex(fvoices,index);
 fvoices[index].assign(avalue);
end;

procedure tsigmidimulticonnector.doinitvoice(const aindex: integer);
begin
 lock;
 try
  with fconnectors[aindex] do begin
   channel:= self.fchannel;
   source:= self.fsource;
  end;
  if assigned(foninitvoice) then begin
   foninitvoice(self,aindex,fvoices[aindex]);
  end;
 finally
  unlock;
 end;
end;

procedure tsigmidimulticonnector.setinputcount(const avalue: integer);
var
 int1: integer;
 class1: datamoduleclassty;
 str1: string;
 voice1: tmsedatamodule;
 conn1: tcomponent;
begin
 if finputcount <> avalue then begin  
  if csloading in componentstate then begin
   fpendinginputcount:= avalue;
  end
  else begin
   if csdesigning in componentstate then begin
    finputcount:= avalue;
   end
   else begin
    lock;
    try
     if avalue <> finputcount then begin
      if avalue < finputcount then begin
       for int1:= finputcount-1 downto avalue do begin
        fvoices[int1].free;
        dec(finputcount);
       end;
      end
      else begin
       if not assigned(fongetvoiceclass) then begin
        raise exception.create('ongetvoiceclass not assigned.');
       end;
       class1:= nil;
       fongetvoiceclass(self,class1);
       if class1 = nil then begin
        raise exception.create('Voiceclass not set.');
       end;
       str1:= fconnectorname;
       if str1 = '' then begin
        str1:= defaultconnectorname;
       end;
       setlength(fvoices,avalue);     //max
       setlength(fconnectors,avalue); //max
       for int1:= 0 to foutputs.count - 1 do begin
        foutputs[int1].inputs.count:= avalue; //max
       end;
       for int1:= finputcount to avalue - 1 do begin
        voice1:= class1.create(nil);
        conn1:= voice1.findcomponent(str1);
        if not (conn1 is tsigmidiconnector) then begin
         voice1.free;
         raise exception.create('tmidiconnector "'+str1+'" not found.');
        end;
        fvoices[int1]:= voice1;
        fconnectors[int1]:= tsigmidiconnector(conn1);
        inc(finputcount);
        doinitvoice(int1);
       end;
      end;  
     end;
    finally
     setlength(fvoices,finputcount);
     setlength(fconnectors,finputcount);
     for int1:= 0 to foutputs.count - 1 do begin
      foutputs[int1].inputs.count:= finputcount;
     end;
     unlock;
    end;
   end;
  end;
 end;
end;

procedure tsigmidimulticonnector.initmodel;
var
 int1,int2,int3: integer;
begin
 setlength(fouts,foutputs.count);
 setlength(finps,finputcount*foutputs.count);
 finputhigh:= finputcount-1;
 foutputhigh:= foutputs.count-1;
 int3:= 0;
 for int1:= 0 to foutputhigh do begin
  with foutputs[int1] do begin
   fouts[int1]:= @fvalue;
   for int2:= 0 to finputhigh do begin
    finps[int3]:= @tdoubleinputconn1(inputs[int2]).fvalue;
    inc(int3);
   end;
  end;
 end;
 inherited;
end;

function tsigmidimulticonnector.gethandler: sighandlerprocty;
begin
 result:= @sighandler;
end;

procedure tsigmidimulticonnector.sighandler(const ainfo: psighandlerinfoty);
var
 int1,int2: integer;
 po1: ppdouble;
 do1: double;
begin
 po1:= ppdouble(finps);
 if po1 <> nil then begin
  for int1:= 0 to foutputhigh do begin
   do1:= 0;
   for int2:= finputhigh downto 0 do begin
    do1:= do1 + po1^^;
    inc(po1);
   end;
   fouts[int1]^:= do1;
  end;
  ainfo^.dest^:= pdouble(finps)^;
 end;
end;

function tsigmidimulticonnector.getinputar: inputconnarty;
var
 int1,int2,int3: integer;
begin
 setlength(result,finputcount*foutputs.count);
 int3:= 0;
 for int1:= 0 to foutputs.count - 1 do begin
  with foutputs[int1] do begin
   for int2:= 0 to finputcount - 1 do begin
    result[int3]:= inputs[int2];
    inc(int3);
   end;
  end;
 end;
end;

function tsigmidimulticonnector.getoutputar: outputconnarty;
begin
 result:= outputconnarty(copy(foutputs.fitems));
end;

function tsigmidimulticonnector.getoutputcount: integer;
begin
 result:= foutputs.count;
end;

procedure tsigmidimulticonnector.setoutputcount(const avalue: integer);
begin
 foutputs.count:= avalue;
end;

procedure tsigmidimulticonnector.setsource(const avalue: tsigmidisource);
begin
 if avalue <> fsource then begin
  setlinkedvar(avalue,fsource);
  updatesource;
 end;
end;

procedure tsigmidimulticonnector.updatesource;
var
 int1: integer;
begin
 lock;
 try
  for int1:= 0 to high(fconnectors) do begin
   with fconnectors[int1] do begin
    channel:= self.fchannel;
    source:= self.fsource;
   end;
  end;
 finally
  unlock;
 end;
end;

procedure tsigmidimulticonnector.setchannel(const avalue: integer);
begin
 if fchannel <> avalue then begin
  fchannel:= avalue;
  updatesource;
 end;
end;

procedure tsigmidimulticonnector.loaded;
begin
 inherited;
 lock;
 try
  inputcount:= fpendinginputcount;
 finally
  unlock;
 end;
end;

end.
