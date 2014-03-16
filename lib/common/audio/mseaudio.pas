{ MSEgui Copyright (c) 2010-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseaudio;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseclasses,msethread,msetypes,msepulseglob,msepulsesimple,
 msesys,msestrings;
 
type

 sampleformatty = (sfm_u8,sfm_8alaw,sfm_8ulaw,
                   sfm_s16,sfm_s24,sfm_s32,sfm_f32,smf_s2432,
                   sfm_s16le,sfm_s24le,sfm_s32le,sfm_f32le,smf_s2432le,
                   sfm_s16be,sfm_s24be,sfm_s32be,sfm_f32be,smf_s2432be);
const
 defaultsampleformat = sfm_s16;
 defaultsamplechannels = 1;
 defaultsamplerate = 44100;
 defaultlatency = 0.1;
 
{$ifdef endian_little}
 pulsesampleformatmatrix: array[sampleformatty] of pa_sample_format_t =
 //sfm_u8,      sfm_8alaw,     sfm_8ulaw,
  (PA_SAMPLE_U8,PA_SAMPLE_ALAW,PA_SAMPLE_ULAW,
 //sfm_s16,        sfm_s24,        sfm_s32,        
   PA_SAMPLE_S16LE,PA_SAMPLE_S24LE,PA_SAMPLE_S32LE,
 //sfm_f32,            smf_s2432,
   PA_SAMPLE_FLOAT32LE,PA_SAMPLE_S24_32LE,
 //sfm_s16le,      sfm_s24le,      sfm_s32le,
   PA_SAMPLE_S16LE,PA_SAMPLE_S24LE,PA_SAMPLE_S32LE,
 //sfm_f32le,          smf_s2432le,
   PA_SAMPLE_FLOAT32LE,PA_SAMPLE_S24_32LE,
 //sfm_s16be,      sfm_s24be,       sfm_s32be,
   PA_SAMPLE_S16BE,PA_SAMPLE_S24BE,PA_SAMPLE_S32BE,
 //sfm_f32be,          smf_s2432be);
   PA_SAMPLE_FLOAT32BE,PA_SAMPLE_S24_32BE);
{$else}
 pulsesampleformatmatrix: array[sampleformatty] of pa_sample_format_t =
 //sfm_u8,      sfm_8alaw,     sfm_8ulaw,
  (PA_SAMPLE_U8,PA_SAMPLE_ALAW,PA_SAMPLE_ULAW,
 //sfm_s16,        sfm_s24,        sfm_s32,        
   PA_SAMPLE_S16BE,PA_SAMPLE_S24BE,PA_SAMPLE_S32BE,
 //sfm_f32,            smf_s2432,
   PA_SAMPLE_FLOAT32BE,PA_SAMPLE_S24_32BE,
 //sfm_s16le,      sfm_s24le,      sfm_s32le,
   PA_SAMPLE_S16LE,PA_SAMPLE_S24LE,PA_SAMPLE_S32LE,
 //sfm_f32le,          smf_s2432le,
   PA_SAMPLE_FLOAT32LE,PA_SAMPLE_S24_32LE,
 //sfm_s16be,      sfm_s24be,       sfm_s32be,
   PA_SAMPLE_S16BE,PA_SAMPLE_S24BE,PA_SAMPLE_S32BE,
 //sfm_f32be,          smf_s2432be);
   PA_SAMPLE_FLOAT32BE,PA_SAMPLE_S24_32BE);
{$endif}

 samplesizematrix: array[sampleformatty] of integer =
 //sfm_u8,      sfm_8alaw,     sfm_8ulaw,
  (1,           1,             1,
 //sfm_s16,     sfm_s24,       sfm_s32,        
   2,           1,             4,
 //sfm_f32,     smf_s2432,
   4,           4,
 //sfm_s16le,   sfm_s24le,     sfm_s32le,
   2,           1,             4,
 //sfm_f32le,   smf_s2432le,
   4,           4,
 //sfm_s16be,   sfm_s24be,     sfm_s32be,
   2,           1,             4,
 //sfm_f32be,   smf_s2432be);
   4,           4);

 samplebuffersizematrix: array[sampleformatty] of integer =
 //sfm_u8,      sfm_8alaw,     sfm_8ulaw,
  (1,           1,             1,
 //sfm_s16,     sfm_s24,       sfm_s32,        
   2,           3,             4,
 //sfm_f32,     smf_s2432,
   4,           4,
 //sfm_s16le,   sfm_s24le,     sfm_s32le,
   2,           3,             4,
 //sfm_f32le,   smf_s2432le,
   4,           4,
 //sfm_s16be,   sfm_s24be,     sfm_s32be,
   2,           3,             4,
 //sfm_f32be,   smf_s2432be);
   4,           4);

type

 toutstreamthread = class(tmsethread)
 end;

 sendeventty = procedure(var data: pointer) of object;
                  //data = 
                  //bytearty       (sfm_u8,sfm_8alaw,sfm_8ulaw,
                  //                sfm_s24,sfm_s24le,sfm_s24be)
                  //smallintarty   (sfm_s16,sfm_s16le,sfm_s16be)
                  //integerarty    (sfm_s32,smf_s2432,sfm_s32le,smf_s2432le,
                  //                sfm_s32be,smf_s2432be)
                  //or singlearty  (sfm_f32,sfm_f32le,sfm_f32be)
 
 erroreventty = procedure(const sender: tobject; const errorcode: integer;
                  const errortext: msestring) of object;

 tcustomaudioout = class(tmsecomponent)
  private
   fthread: toutstreamthread;
   fstacksizekb: integer;
   fonsend: sendeventty;
   fonerror: erroreventty;
   fserver: msestring;
   fdev: msestring;
   fchannels: integer;
   frate: integer;
   flatency: real;
   procedure setactive(const avalue: boolean);
  protected
   factive: boolean;
   fformat: sampleformatty;
   fappname: msestring;
   fstreamname: msestring;
   fpulsestream: ppa_simple;
   procedure initnames; virtual;
   procedure loaded; override;
   procedure run; virtual;
   procedure stop; virtual;
   function threadproc(sender: tmsethread): integer; virtual;   
   procedure raiseerror(const aerror: integer);
   procedure doerror(const aerror: integer);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
//   function lock: boolean;
//   procedure unlock;

   property active: boolean read factive write setactive default false;
   property server: msestring read fserver write fserver;
   property dev: msestring read fdev write fdev;
   property appname: msestring read fappname write fappname;
   property streamname: msestring read fstreamname write fstreamname;
   property channels: integer read fchannels write fchannels 
                                                 default defaultsamplechannels;
   property format: sampleformatty read fformat write fformat 
                                              default defaultsampleformat;
   property rate: integer read frate write frate default defaultsamplerate;
   property stacksizekb: integer read fstacksizekb write fstacksizekb default 0;
   property latency: real read flatency write flatency; 
           //seconds, 0 -> server default
   property onsend: sendeventty read fonsend write fonsend;
   property onerror: erroreventty read fonerror write fonerror;
 end;

 taudioout = class(tcustomaudioout)
  published
   property active;
   property server;
   property dev;
   property appname;
   property streamname;
   property channels;
   property format;
   property rate;
   property latency;
   property stacksizekb;
   property onsend;
   property onerror;
 end;
  
implementation
uses
 sysutils,msesysintf,mseapplication,msepulse;
 
{ tcustomaudioout }

constructor tcustomaudioout.create(aowner: tcomponent);
begin
// syserror(sys_mutexcreate(fmutex),self);
 fchannels:= defaultsamplechannels;
 fformat:= defaultsampleformat;
 frate:= defaultsamplerate;
 flatency:= defaultlatency;
 inherited;
end;

destructor tcustomaudioout.destroy;
begin
 active:= false;
 inherited;
// sys_mutexdestroy(fmutex);
end;

procedure tcustomaudioout.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  if componentstate * [csloading,csdesigning] = [] then begin
   if not avalue then begin
    stop;
   end
   else begin
    run;
   end;
  end
  else begin
   factive:= avalue;
  end;
 end;
end;

procedure tcustomaudioout.stop;
begin
 if fthread <> nil then begin
  fthread.terminate;
  application.waitforthread(fthread);
  freeandnil(fthread);
  pa_simple_free(fpulsestream);
  releasepulsesimple;
 end;
 factive:= false;
end;

procedure tcustomaudioout.run;
var
 ss: pa_sample_spec;
 int1: integer;
 buattr: pa_buffer_attr;
begin
 initializepulsesimple([]);
 fillchar(ss,sizeof(ss),0);
 fillchar(buattr,sizeof(buattr),0);
 with buattr do begin
  maxlength:= longword(-1); 
  tlength:= longword(-1);
  prebuf:= longword(-1);
  minreq:= longword(-1);
  fragsize:= longword(-1);
 end;
 if flatency > 0 then begin
  int1:= round(flatency*frate*samplebuffersizematrix[fformat]*fchannels);
  buattr.tlength:= int1;
 end;
 ss.format:= pulsesampleformatmatrix[fformat];
 ss.rate:= frate;
 ss.channels:= fchannels;
 fpulsestream:= pa_simple_new(pointer(string(fserver)),
                pointer(string(fappname)),
                pa_stream_playback,pointer(string(fdev)),
                pointer(string(fstreamname)),
                @ss,nil,@buattr,@int1);
 if fpulsestream = nil then begin
  raiseerror(int1);
 end;
 fthread:= toutstreamthread.create({$ifdef FPC}@{$endif}threadproc,false,
                                      fstacksizekb);
 factive:= true;
end;

procedure tcustomaudioout.initnames;
begin
 if fappname = '' then begin
  fappname:= application.applicationname;
 end;
 if fstreamname = '' then begin
  fstreamname:= name;
 end;
end;

procedure tcustomaudioout.loaded;
begin
 inherited;
 if not (csdesigning in componentstate) then begin
  initnames;
  if factive and (fthread = nil) then begin
   run;
  end;
 end;
end;
{
function tcustomaudioout.lock: boolean;
begin
 result:= sys_mutexlock(fmutex) = sye_ok;
end;

procedure tcustomaudioout.unlock;
begin
 sys_mutexunlock(fmutex);
end;
}
function tcustomaudioout.threadproc(sender: tmsethread): integer;
var
 data: pointer;
 int1: integer;
 datasize: integer;
begin
 result:= 0;
 if canevent(tmethod(fonsend)) then begin
  factive:= true;
  datasize:= samplesizematrix[fformat];
  while not sender.terminated do begin
   data:= nil;
//   lock;
//   try
    fonsend(data);
//   finally
//    unlock;
//   end;
   if data <> nil then begin
    if pa_simple_write(fpulsestream,data,length(bytearty(data))*datasize,
                                                  @int1) <> 0 then begin
     doerror(int1);
     break;
    end;     
   end;
  end;
 end;
end;

procedure tcustomaudioout.raiseerror(const aerror: integer);
begin
 raise exception.create(pa_strerror(aerror));
end;

procedure tcustomaudioout.doerror(const aerror: integer);
begin
 application.lock;
 try
  if canevent(tmethod(fonerror)) then begin
   fonerror(self,aerror,pa_strerror(aerror));
  end;
 finally
  application.unlock;
 end;
end;

end.
