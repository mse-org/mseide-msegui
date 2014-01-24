{ MSEgui Copyright (c) 2010-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemidi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream,classes,mclasses,mseclasses,sysutils,msestrings,msetimer,msetypes;

const 
 defaultmidimaxdatasize = 1000000;
// defaulttimescaleus = 1000000*60/(120*120);
 defaulttempo = 120; //beats per minute
 defaultticksperbeat = 120;
 
 mc_endoftrack = 47;
 mc_keysig = 89;
 mc_timesig = 88;
 mc_tempo = 81;
 mc_trackname = 3;
 mc_instrumentname = 4;
 
type
 midierrorty = (em_ok,em_nostream,em_fileformat,em_notrack,em_trackdata);

 emidiexception = class(exception);

 midichannelty = (mic_0,mic_1,mic_2,mic_3,mic_4,mic_5,mic_6,mic_7,
                  mic_8,mic_9,mic_10,mic_11,mic_12,mic_13,mic_14,mic_15);
 midichannelsty = set of midichannelty;
                  
 idstringty = array[0..3] of char;
 midichunkheaderty = record
  id: idstringty;
  size: longword;
 end;

 midichunkty = record
  header: midichunkheaderty;
  data: record //variable
  end;
 end;
  
 midifileheaderty = record
  formattype: word;
  numberoftracks: word;
  timedivision: word;
 end;

 midimessagekindty = (mmk_none,mmk_noteoff,mmk_noteon,mmk_notepressure,
                      mmk_controller,mmk_programchange,mmk_channelpressure,
                      mmk_pitchbend,mmk_system);
const
 midichannelmessages = [mmk_noteoff,mmk_noteon,mmk_notepressure,
                      mmk_controller,mmk_programchange,mmk_channelpressure];
type
 midieventinfoty = record
  track: integer;
  kind: midimessagekindty;
  channel: byte;
  par1: byte;
  par2: byte;
 end;
 trackeventinfoty = record
  delta: longword;
  event: midieventinfoty;
 end;
 ptrackeventinfoty = ^trackeventinfoty;
   
 tmidistream = class(tbufstream)
  private
   ftrackcount: integer;
   ftimedivision: longword;
   ftracksize: longword;
   fmetadata: string;
   fstatus: byte;
   fmaxdatasize: longword;
   ftracknum: integer;
  protected
   function readtrackbyte(out adata: byte): boolean;
   function readtrackdatabyte(out adata: byte): boolean; //check bit 7
   function readtrackword(out adata: word): boolean;
   function readtracklongword(out adata: word): boolean;
   function readtrackdata(out adata; const acount: integer): boolean; overload;
   function readtrackvarlength(out adata: longword): boolean;

   function readbyte(out adata: byte): boolean;
   function readword(out adata: word): boolean;
   function readlongword(out adata: word): boolean;
   function readchunkheader(out adata: midichunkheaderty): boolean;

   function checkchunkheader(const aid: idstringty;
                                         const asize: integer): boolean;
   function readfileheader(out adata: midifileheaderty): boolean;
   function skip(const adist: longword): boolean;
  public
   constructor create(ahandle: integer); override;
   function initfile: boolean;
   function starttrack: boolean;
   function skiptrack: boolean;
   function readtrackdata(out adata: trackeventinfoty): boolean; overload;
   function getmetadata(const alen: integer; out avalue: longword): boolean;
   property timedivision: longword read ftimedivision;
   property metadata: string read fmetadata;
   property maxdatasize: longword read fmaxdatasize write fmaxdatasize 
                         default defaultmidimaxdatasize;
 end;

 trackeventty = procedure(const sender: tobject;
                         var ainfo: midieventinfoty) of object;

 midisourcestatety = (mss_inited,mss_tracksloaded,mss_eventsmerged,
                      mss_endoftrack);
 midisourcestatesty = set of midisourcestatety;

const
 loadstates = [mss_inited,mss_tracksloaded,mss_eventsmerged];
type                          
 trackinfoty = record
  disabled: boolean;
  trackname: string;
  instrumentname: string;
  keysig: byte;
  tempo: longword; //micro seconds per quarter note
  timesig: longword;
  channels: midichannelsty;
 end;
 trackinfoarty = array of trackinfoty;

 trackbufferarty = array of trackeventinfoty;
 trackbufferararty = array of trackbufferarty;
  
 tmidisource = class(tmsecomponent)
  private
   fstream: tmidistream;
   factive: boolean;
   fontrackevent: trackeventty;
   fstarttime: longword;
   feventtime: longword;
   ftimer: tsimpletimer;
   ftracks: trackinfoarty;
   ftrackbuffer: trackbufferararty;
   feventbuffer: trackbufferarty;
   feventindex: integer;
   ftimescale: real; //miditicks to us
   ftempo: real;
   ftimesum: real;
   procedure setstream(const avalue: tmidistream);
   procedure setactive(const avalue: boolean);
   procedure settempo(const avalue: real);
  protected
   fstate: midisourcestatesty;
   ftrackevent: trackeventinfoty;
   function ticksperbeat: integer;
   procedure error(const aerror: midierrorty);
   procedure clear;
   procedure initstream;
   procedure mergeevents;
   procedure checkdata;
   procedure start;
   procedure stop;
   function checkresult(const aresult: boolean;
                       const aerror: midierrorty): boolean; {$ifdef FPC}inline;{$endif}
   procedure processevent;
   procedure dotrackevent; virtual;
   procedure dotimer(const sender: tobject);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure loadtracks;
   property active: boolean read factive write setactive;
   property stream: tmidistream read fstream write setstream;
                                //owns the stream
   property tracks: trackinfoarty read ftracks;
   property tempo: real read ftempo write settempo; //beats per minute
  published
   property ontrackevent: trackeventty read fontrackevent write fontrackevent;
 end;
 
const  
 midimessagetable: array[0..7] of midimessagekindty = (
  mmk_noteoff,              //8c
  mmk_noteon,               //9c
  mmk_notepressure,         //ac
  mmk_controller,           //bc
  mmk_programchange,        //cc
  mmk_channelpressure,      //dc
  mmk_pitchbend,            //ec
  mmk_system);              //fx

 midiparcount: array[midimessagekindty] of integer = (
 // mmk_none,mmk_noteoff,mmk_noteon,mmk_notepressure,
    0,       2,          2,         2,
 // mmk_controller,mmk_programchange,mmk_channelpressure,
    2,             1,                1,
 // mmk_pitchbend,mmk_system
    2,            0);

implementation
uses
 msesysutils,msedatalist,msearrayutils; 
const
 errormessages: array[midierrorty] of msestring = (
  '',
  'No midi stream',
  'No midi file.',
  'No track found.',
  'Invalid track data.'
  );
  
function swap(const avalue: word): word; {$ifdef FPC}inline;{$endif}
                                                overload;
begin
 result:= (avalue shl 8) or (avalue shr 8);
end;

procedure swap1(var avalue: word); {$ifdef FPC}inline;{$endif}
                                                 overload;
begin
 avalue:= (avalue shl 8) or (avalue shr 8);
end;

function swap(const avalue: longword): longword; {$ifdef FPC}inline;{$endif}
                                                            overload;
begin
 result:= (swap(word(avalue)) shl 16) or swap(word(avalue shr 16));
end;

procedure swap1(var avalue: longword); {$ifdef FPC}inline;{$endif} overload;
begin
 avalue:= (swap(word(avalue)) shl 16) or swap(word(avalue shr 16));
end;
 
{ tmidistream }

constructor tmidistream.create(ahandle: integer);
begin
 fmaxdatasize:= defaultmidimaxdatasize;
// ftimescaleus:= defaulttimescaleus;
 inherited;
end;

function tmidistream.readbyte(out adata: byte): boolean;
begin
 result:= read(adata,sizeof(adata)) = sizeof(adata);
end;

function tmidistream.readword(out adata: word): boolean;
begin
 result:= read(adata,sizeof(adata)) = sizeof(adata);
 swap1(adata);
end;

function tmidistream.readlongword(out adata: word): boolean;
begin
 result:= read(adata,sizeof(adata)) = sizeof(adata);
 swap1(adata);
end;

function tmidistream.readtrackbyte(out adata: byte): boolean;
var
 int1: integer;
begin
 result:= ftrackcount >= sizeof(adata);
 if result then begin
  int1:= read(adata,sizeof(adata));
  ftrackcount:= ftrackcount - int1;
  result:= int1 = sizeof(adata);
 end;
end;

function tmidistream.readtrackdatabyte(out adata: byte): boolean;
begin
 result:= readtrackbyte(adata);
 if result and (adata and $80 <> 0) then begin
  result:= false;
  fstatus:= adata; //try to resync
 end;
end;

function tmidistream.readtrackword(out adata: word): boolean;
var
 int1: integer;
begin
 result:= ftrackcount >= sizeof(adata);
 if result then begin
  int1:= read(adata,sizeof(adata));
  ftrackcount:= ftrackcount - int1;
  result:= int1 = sizeof(adata);
  if result then begin
   swap1(adata);
  end;
 end;
end;

function tmidistream.readtracklongword(out adata: word): boolean;
var
 int1: integer;
begin
 result:= ftrackcount >= sizeof(adata);
 if result then begin
  int1:= read(adata,sizeof(adata));
  ftrackcount:= ftrackcount - int1;
  result:= int1 = sizeof(adata);
  if result then begin
   swap1(adata);
  end;
 end;
end;

function tmidistream.readtrackdata(out adata; const acount: integer): boolean;
var
 int1: integer;
begin
 result:= ftrackcount >= acount;
 if result then begin
  int1:= read(adata,acount);
  ftrackcount:= ftrackcount - int1;
  result:= int1 = acount;
 end;
end;

function tmidistream.readchunkheader(out adata: midichunkheaderty): boolean;
begin
 result:= read(adata,sizeof(adata)) = sizeof(adata);
 swap1(adata.size);
end;

function tmidistream.checkchunkheader(const aid: idstringty;
               const asize: integer): boolean;
var
 header1: midichunkheaderty;
begin
 result:= readchunkheader(header1) and (header1.size = asize) and
                     (header1.id = aid);
end;

function tmidistream.readfileheader(out adata: midifileheaderty): boolean;
begin
 result:= checkchunkheader('MThd',6);
 if result then begin
  result:= read(adata,sizeof(adata)) = sizeof(adata);
  if result then begin
   with adata do begin
    swap1(formattype);
    swap1(numberoftracks);
    swap1(timedivision);
   end;
  end;
 end;
end;

function tmidistream.initfile: boolean;
var
 header: midifileheaderty;
begin
 ftracknum:= -1;
 result:= readfileheader(header);
 if result then begin
  with header do begin
   ftrackcount:= numberoftracks;
   ftimedivision:= timedivision;
  end;
  result:= ftimedivision > 0;
 end;
end;

function tmidistream.starttrack: boolean;
var
 header: midichunkheaderty;
begin
 repeat
  result:= readchunkheader(header);
  if result then begin
   with header do begin
    ftracksize:= header.size;
    if id = 'MTrk' then begin
     ftrackcount:= ftracksize;
     inc(ftracknum);
     break;
    end;
    result:= skip(ftracksize);
   end;
  end;
 until not result;
end;

function tmidistream.skiptrack: boolean;
var
 header: midichunkheaderty;
begin
 repeat
  result:= readchunkheader(header);
  if result then begin
   with header do begin
    ftracksize:= header.size;
    if id = 'MTrk' then begin
     result:= skip(ftracksize);
     inc(ftracknum);
     break;
    end;
    result:= skip(ftracksize);
   end;
  end;
 until not result;
end;


function tmidistream.skip(const adist: longword): boolean;
var
 lint1: int64;
begin
 lint1:= position;
 result:= seek(adist,socurrent)-lint1 = adist;
end;

function tmidistream.readtrackvarlength(out adata: longword): boolean;
var
 by1: byte;  
begin
 result:= true;
 adata:= 0;
 while result and (ftrackcount > 0) do begin
  dec(ftrackcount);
  result:= read(by1,1) = 1;
  adata:= (adata shl 7) or by1 and $7f;
  if by1 and $80 = 0 then begin
   break;
  end;
 end;
end;
{
function tmidistream.readtrackevent(out adata: trackeventinfoty): boolean;
var
 stat1: byte;
 lwo1: longword;
 rea1: real;
begin
 fillchar(adata,sizeof(adata),0);
 result:= readtrackvarlength(adata.delta);
 if not result then exit;

 if adata.delta <> 0 then begin
  ftimesum:= ftimesum + adata.delta*ftimescaleus;
  adata.delta:= round(ftimesum);
  ftimesum:= ftimesum - adata.delta;
 end;
   
 result:= readtrackbyte(stat1);
 if not result then exit;
 if (stat1 and $80) <> 0 then begin
  fstatus:= stat1;
  result:= readtrackdatabyte(adata.event.par1);
  if not result then exit;
 end
 else begin
  adata.event.par1:= stat1;
  stat1:= fstatus;
 end;
 adata.event.kind:= messagetable[(stat1 shr 4) and $7];
 if adata.event.kind = mmk_system then begin
  result:= readtrackvarlength(lwo1) and (lwo1 <= fmaxdatasize);
  if not result then exit;
  setlength(fmetadata,lwo1); 
  if lwo1 > 0 then begin
   result:= readtrackdata(pointer(fmetadata)^,lwo1);
  end;
 end
 else begin
  adata.event.channel:= stat1 and $0f;
  if parcount[adata.event.kind] > 1 then begin
   result:= readtrackdatabyte(adata.event.par2);
  end;
 end;
end;
}
function tmidistream.readtrackdata(out adata: trackeventinfoty): boolean;
var
 stat1: byte;
 lwo1: longword;
// rea1: real;
begin
 fillchar(adata,sizeof(adata),0);
 adata.event.track:= ftracknum;
 fmetadata:= '';
 result:= readtrackvarlength(adata.delta);
 if not result then exit;
 result:= readtrackbyte(stat1);
 if not result then exit;
 if (stat1 and $80) <> 0 then begin
  fstatus:= stat1;
  result:= readtrackdatabyte(adata.event.par1);
  if not result then exit;
 end
 else begin
  adata.event.par1:= stat1;
  stat1:= fstatus;
 end;
 adata.event.kind:= midimessagetable[(stat1 shr 4) and $7];
 if adata.event.kind = mmk_system then begin
  result:= readtrackvarlength(lwo1) and (lwo1 <= fmaxdatasize);
  if not result then exit;
  setlength(fmetadata,lwo1); 
  if lwo1 > 0 then begin
   result:= readtrackdata(pointer(fmetadata)^,lwo1);
  end;
 end
 else begin
  adata.event.channel:= stat1 and $0f;
  if midiparcount[adata.event.kind] > 1 then begin
   result:= readtrackdatabyte(adata.event.par2);
  end;
 end;
end;

function tmidistream.getmetadata(const alen: integer;
                                           out avalue: longword): boolean;
var
 int1: integer;
begin
 result:= length(fmetadata) = alen;
 if result then begin
  avalue:= 0;
  for int1:= 1 to alen do begin
   avalue:= (avalue shl 8) or byte(fmetadata[int1]);
  end;
 end;
end;

{ tmidisource }

constructor tmidisource.create(aowner: tcomponent);
begin
 tempo:= defaulttempo;
 inherited;
 ftimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}dotimer,false,
                     [to_single,to_absolute,to_autostart]);
end;

destructor tmidisource.destroy;
begin
 stream:= nil;
 ftimer.free;
 inherited;
end;

function tmidisource.checkresult(const aresult: boolean;
               const aerror: midierrorty): boolean;
begin
 result:= aresult;
 if not aresult then begin
  error(aerror);
 end;
end;

procedure tmidisource.clear;
begin
 fstate:= fstate - loadstates;
 ftracks:= nil;
 ftrackbuffer:= nil;
 feventbuffer:= nil;
 ftempo:= defaulttempo;
 feventindex:= 0;
 ftimesum:= 0;
end;

procedure tmidisource.setstream(const avalue: tmidistream);
begin
 active:= false;
 fstream.free;
 fstream:= avalue;
 clear;
end;

procedure tmidisource.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  factive:= avalue;
  if avalue then begin
   start;
  end
  else begin
   stop;
  end;
 end;
end;

procedure tmidisource.error(const aerror: midierrorty);
begin
 raise emidiexception.create(self.name+': '+errormessages[aerror]);
end;

procedure tmidisource.dotrackevent;
begin
 if assigned(fontrackevent) then begin
  fontrackevent(self,ftrackevent.event);
 end;
end;

procedure tmidisource.dotimer(const sender: tobject);
begin
 dotrackevent;
 processevent;
end;

procedure tmidisource.processevent;
var
 lwo1: longword;
begin
 while feventindex <= high(feventbuffer) do begin
  ftrackevent:= feventbuffer[feventindex];
  inc(feventindex);
  with ftrackevent do begin
   if delta = 0 then begin
    dotrackevent;
   end
   else begin
    ftimesum:= ftimesum +delta*ftimescale;
    lwo1:= round(ftimesum);
    ftimesum:= ftimesum - lwo1;
    feventtime:= feventtime + lwo1;
    ftimer.interval:= feventtime;
    break;
   end;
  end;
 end;
end;

procedure tmidisource.initstream;
begin
 if not (mss_inited in fstate) then begin
  if fstream = nil then begin
   error(em_nostream);
  end;
  checkresult(fstream.initfile,em_fileformat);
  tempo:= tempo; //update timescale
  include(fstate,mss_inited);
 end;
end;

procedure tmidisource.loadtracks;
var
 int1,int2,int3: integer;
 trackdata: trackeventinfoty;
begin
 initstream;
 if not (mss_tracksloaded in fstate) then begin
  setlength(ftracks,fstream.ftrackcount);
  setlength(ftrackbuffer,length(ftracks));
  for int1:= 0 to high(ftracks) do begin
   checkresult(fstream.starttrack,em_notrack);
   with ftracks[int1] do begin
    int2:= 0;
    while true do begin
     checkresult(fstream.readtrackdata(trackdata),em_trackdata);
     with trackdata.event do begin
      case kind of
       mmk_noteoff,mmk_noteon,mmk_notepressure,
       mmk_controller,mmk_programchange,mmk_channelpressure,
       mmk_pitchbend: begin
        int3:= additemindex(ftrackbuffer[int1],typeinfo(trackbufferarty),int2);
        ftrackbuffer[int1][int3]:= trackdata;
        include(channels,midichannelty(trackdata.event.channel and $0f));
       end;
       mmk_system: begin
        case par1 of
         mc_keysig: begin
          keysig:= par2;
         end;
         mc_tempo: begin
          checkresult(fstream.getmetadata(3,tempo),em_trackdata);
         end;
         mc_timesig: begin
          checkresult(fstream.getmetadata(4,timesig),em_trackdata);
         end;
         mc_trackname: begin
          trackname:= fstream.metadata;
         end;
         mc_instrumentname: begin
          instrumentname:= fstream.metadata;
         end;
         mc_endoftrack: begin
          break;
         end;
        end;
       end;
      end;
     end;
    end;
    setlength(ftrackbuffer[int1],int2);
   end;
  end;  
  if (ftracks <> nil) and (ftracks[0].tempo > 0) then begin
   tempo:= 60000000/ftracks[0].tempo;
  end;
  include(fstate,mss_tracksloaded);
 end;
end;

type
 trackmergeinfoty = record
  po: ptrackeventinfoty;
  time: longword;
 end;
 trackmergeinfoarty = array of trackmergeinfoty;
 
procedure tmidisource.mergeevents;    //todo: optimize
var
 int1,int2,int3,int4,int5,int6: integer;
 ar1: trackmergeinfoarty;
 lwo1: longword;
begin
 loadtracks;
 if high(ftracks) < 0 then begin
  exit;
 end;
 if not (mss_eventsmerged in fstate) then begin
  int2:= 0;
  int3:= 0;
  setlength(ar1,length(ftracks));
  for int1:= 0 to high(ftracks) do begin
   if not ftracks[int1].disabled and (ftrackbuffer[int1] <> nil) then begin
    int4:= length(ftrackbuffer[int1]);
    int2:= int2 + int4;
    setlength(ftrackbuffer[int1],int4+1);
    ftrackbuffer[int1][int4].delta:= bigint; //endmarker
    ar1[int3].po:= pointer(ftrackbuffer[int1]);
    inc(int3);
   end;
  end;
  setlength(ar1,int3);
  setlength(feventbuffer,int2);
  {
  for int3:= 0 to high(ar1) do begin
   with ar1[int3] do begin
    time:= time + po^.delta; //init
   end;
  end;
  }
  lwo1:= 0;
  for int1:= 0 to int2 - 1 do begin
   with ar1[0] do begin
    int4:= time+po^.delta-lwo1;
   end;
   int5:= 0;
   for int3:= 1 to high(ar1) do begin
    with ar1[int3] do begin
     int6:= time+po^.delta-lwo1;
     if int6 < int4 then begin
      int4:= int6;
      int5:= int3;
     end;
    end;
   end;
   with ar1[int5] do begin
    feventbuffer[int1]:= po^;
    time:= time + po^.delta;
    with feventbuffer[int1] do begin
     delta:= time-lwo1;
    end;
    lwo1:= time;
    inc(po);
   end;
  end;
  ftrackbuffer:= nil;
  include(fstate,mss_eventsmerged);
 end;
end;

{
    fstarttime:= timestamp;
    feventtime:= fstarttime;
    processevent;
}
procedure tmidisource.checkdata;
begin
 mergeevents;
end;

procedure tmidisource.start;
begin
 checkdata;
 fstarttime:= timestamp;
 feventtime:= fstarttime;
 processevent;
end;

procedure tmidisource.stop;
begin
 ftimer.enabled:= false;
end;

procedure tmidisource.settempo(const avalue: real);
begin
 if avalue > 0 then begin
  ftempo:= avalue;
  ftimescale:= (60000000)/(ticksperbeat*avalue);
 end;
end;

function tmidisource.ticksperbeat: integer;
begin
 result:= defaultticksperbeat;
 if fstream <> nil then begin
  result:= fstream.timedivision;
 end;
end;

end.
