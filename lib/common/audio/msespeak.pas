{ MSEgui Copyright (c) 2017-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
// under construction
//
unit msespeak;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseclasses,msetypes,mseespeakng,msearrayprops,
 msethread,mseevent,msesystypes;
type
 espeakoptionty = (eso_nospeakaudio);
 espeakoptionsty = set of espeakoptionty;
 speakoptionty = (so_cancel,so_wait,so_ssml,so_phonemes,so_endpause);

 speakoptionsty = set of speakoptionty;

 tcustomespeakng = class;

 genderty = (gen_none,gen_male,gen_female);
 punctuationty = (pu_none,pu_all,pu_some);
 tvoice = class(townedpersistent)
  private
   fgender: genderty;
   fpitch: int32;
   frate: int32;
   fvolume: int32;
   frange: int32;
   fpunctuation: punctuationty;
   fcapitals: int32;
   fwordgap: int32;
   flanguage: msestring;
   fvoicename: msestring;
   fidentifier: msestring;
   fvariant: msestring;
   fage: card8;
   fvariantnum: card8;
   fpunctuationlist: msestring;
   procedure setgender(const avalue: genderty);
   procedure setpitch(const avalue: int32);
   procedure setrate(const avalue: int32);
   procedure setvolume(const avalue: int32);
   procedure setrange(const avalue: int32);
   procedure setpunctuation(const avalue: punctuationty);
   procedure setcapitals(const avalue: int32);
   procedure setwordgap(const avalue: int32);
   procedure setlanguage(const avalue: msestring);
   procedure setidentifier(const avalue: msestring);
   procedure setvoicename(const avalue: msestring);
   procedure setvariant(const avalue: msestring);
   procedure setage(const avalue: card8);
   procedure setvariantnum(const avalue: card8);
   procedure setpunctuationlist(const avalue: msestring);
  protected
   fid: string;
   procedure change();
  public
   constructor create(aowner: tobject); override;
  published
   property identifier: msestring read fidentifier write setidentifier; 
    //voice selection 1. priority
                  // the filename for this voice within
                  //espeak-ng-data/voices
   property voicename: msestring read fvoicename write setvoicename;
    //voice selection used if identifier = '', example: de
   property variant: msestring read fvariant write setvariant;
    //appended to identifier or voicename, example: f3

 
    //values below used for voice selection if identifier and voicename = ''
   property language: msestring read flanguage write setlanguage;
                  //example: en-uk
   property variantnum: card8 read fvariantnum write setvariantnum default 0;
   property gender: genderty read fgender write setgender default gen_none;
   property age: card8 read fage write setage default 0;

    //voice independent parameters
   property rate: int32 read frate write setrate default espeakRATE_NORMAL;
     {espeakRATE:    speaking speed in word per minute.  Values 80 to 450.}
   property volume: int32 read fvolume write setvolume default 100;
     {espeakVOLUME:  volume in range 0-200 or more.
                     0=silence, 100=normal full volume, greater values may
                     produce amplitude compression or distortion}
   property pitch: int32 read fpitch write setpitch default 50;
     {espeakPITCH:   base pitch, range 0-100.  50=normal}
   property range: int32 read frange write setrange default 50;
     {espeakRANGE:   pitch range, range 0-100. 0-monotone, 50=normal}
   property punctuationlist: msestring read fpunctuationlist
                                                 write setpunctuationlist;
   property punctuation: punctuationty read fpunctuation 
                          write setpunctuation default pu_none;
     {espeakPUNCTUATION:  which punctuation characters to announce:
         value in espeak_PUNCT_TYPE (none, all, some),
         see espeak_GetParameter() to specify which characters are announced.}
   property capitals: int32 read fcapitals write setcapitals default -1;
     {espeakCAPITALS: announce capital letters by:
         0=none,
         1=sound icon,
         2=spelling,
         3 or higher, by raising pitch.  
           This values gives the amount in Hz by which the pitch
            of a word raised to indicate it has a capital letter.}
   property wordgap: int32 read fwordgap write setwordgap default -1;
                                                   //-1 = default
     {espeakWORDGAP:  pause between words, units of 10mS (at the default speed)}
 end;

 tvoices = class(townedpersistentarrayprop)
  private
   function getitems(const index: int32): tvoice;
   procedure setitems(const index: int32; const avalue: tvoice);
  protected
   procedure setcount1(acount: integer; doinit: boolean); override;
  public
   constructor create(const aowner: tcustomespeakng); reintroduce;
   property items[const index: int32]: tvoice read getitems
                                                write setitems; default;
 end;

 speakmodety = (smo_text,smo_char,smo_key);
 tspeakevent = class(tmseevent)
  protected
   fmode: speakmodety;
   fvoice: int32;
   foptions: speakoptionsty;
   ftext: msestring;
   fchar: char32;
  public
   constructor create(const text: msestring; const options: speakoptionsty;
                                                         const voice: int32);
   constructor create(const achar: char32; const options: speakoptionsty;
                                                         const voice: int32);
   constructor createkey(const key: msestring; const options: speakoptionsty;
                                                         const voice: int32);
 end;
{
 tspeakthread = class(teventthread)
  protected
   fidlecond: condty;
  public
   constructor create(const athreadproc: threadprocty;
                     const afreeonterminate: boolean = false;
                     const astacksizekb: integer = 0); overload; override;
   destructor destroy(); override;
   procedure clearevents() override;
 end;
}  
 speakstatety = (ss_voicevalid,ss_connected,ss_disconnected,
                 ss_canceled,ss_idle);
 speakstatesty = set of speakstatety;
 
 espeakngeventty = procedure(const sender: tcustomespeakng) of object;
  
 tcustomespeakng = class(tmsecomponent)
  private
   factive: boolean;
   fdatapath: filenamety;
   foptions: espeakoptionsty;
   fdevice: msestring;
   fbufferlength: int32;
   fvoicedefault: int32;
   fvoices: tvoices;
   fpunctuationlist: msestring;
   fvolume: flo64;
   frate: flo64;
   fpitch: flo64;
   frange: flo64;
   fwordgap: int32;
   flanguage: msestring;
   fidentifier: msestring;
   fvariant: msestring;
   fgender: genderty;
   fage: card8;
   fvariantnum: card8;
   fcapitals: int32;
   fvoicename: msestring;
   fonbeforeconnect: espeakngeventty;
   procedure setactive(const avalue: boolean);
   procedure setvoicedefault(avalue: int32);
   procedure setvoices(const avalue: tvoices);
   procedure setpunctuationlist(const avalue: msestring);
   procedure setvolume(const avalue: flo64);
   procedure setrate(const avalue: flo64);
   procedure setpitch(const avalue: flo64);
   procedure setrange(const avalue: flo64);
   procedure setwordgap(const avalue: int32);
   procedure setlanguage(const avalue: msestring);
   procedure setidentifier(const avalue: msestring);
   procedure setvariant(const avalue: msestring);
   procedure setgender(const avalue: genderty);
   procedure setage(const avalue: card8);
   procedure setvariantnum(const avalue: card8);
   procedure setcapitals(const avalue: int32);
   procedure setvoicename(const avalue: msestring);
  protected
   fstate: speakstatesty;
   flastvoice: int32;
   fspeakthread: teventthread;
   fidlecond: condty;
   procedure doasyncevent(var atag: int32) override;
   function speakexe(athread: tmsethread): int32;
   procedure loaded() override;
   procedure connect();
   procedure disconnect();
   procedure checkerror(const astate: espeak_ng_status);
   procedure voicechanged();
   procedure checkvoice(avoice: int32);
   procedure internalspeak(const atext: msestring; 
                               const aoptions: speakoptionsty;
                                                 const avoice: int32);
   procedure internalspeakcharacter(const achar: char32;
                             const aoptions: speakoptionsty;
                                           const avoice: int32);
   procedure internalspeakkeyname(const akey: msestring;
                                     const aoptions: speakoptionsty;
                                                      const avoice: int32);
   procedure lock();
   procedure unlock();
   procedure beginchange();
   procedure endchange();
   
   procedure postidle();
   procedure postevent(const aevent: tspeakevent);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   procedure speak(const atext: msestring; const aoptions: speakoptionsty = [];
                        const avoice: int32 = -1); //-1 -> default
   procedure speakcharacter(const achar: char32;
                             const aoptions: speakoptionsty = [];
                                const avoice: int32 = -1); //-1 -> default
   procedure speakkeyname(const akey: msestring;
                             const aoptions: speakoptionsty = [];
                                const avoice: int32 = -1); //-1 -> default
   procedure wait();
   procedure cancel();
   property active: boolean read factive write setactive default false;
   property datapath: filenamety read fdatapath write fdatapath;
   property options: espeakoptionsty read foptions write foptions default [];
   property device: msestring read fdevice write fdevice;
   property bufferlength: int32 read fbufferlength 
                                          write fbufferlength default 0;
                                           //ms, 0 -> 60ms
   property voicedefault: int32 read fvoicedefault 
                                   write setvoicedefault default 0;
   property voices: tvoices read fvoices write setvoices;
   property identifier: msestring read fidentifier write setidentifier;
   property voicename: msestring read fvoicename write setvoicename;
   property variant: msestring read fvariant write setvariant;

   property language: msestring read flanguage write setlanguage;
   property gender: genderty read fgender write setgender default gen_none;
   property age: card8 read fage write setage default 0;
   property variantnum: card8 read fvariantnum write setvariantnum default 0;

   property volume: flo64 read fvolume write setvolume;    //default 1.0
   property rate: flo64 read frate write setrate;          //default 1.0
   property pitch: flo64 read fpitch write setpitch;       //default 1.0
   property range: flo64 read frange write setrange;       //default 1.0
   property capitals: int32 read fcapitals write setcapitals default 0;
   property wordgap: int32 read fwordgap write setwordgap default 0;
                                                          //n*10ms
   property punctuationlist: msestring read fpunctuationlist
                                                 write setpunctuationlist;
                                          //for voice.punctuation pu_some
   property onbeforeconnect: espeakngeventty read fonbeforeconnect 
                                                      write fonbeforeconnect;
 end;

 tespeakng = class(tcustomespeakng)
  published
   property active;
   property datapath;
   property options;
   property device;
   property bufferlength;
   property voicedefault;
   property voices;
   property language;
   property identifier;
   property voicename;
   property variant;
   property gender;
   property age;
   property variantnum;
   property volume;
   property rate;
   property pitch;
   property range;
   property wordgap;
   property punctuationlist;
   property onbeforeconnect;
 end;

implementation
uses
 msestrings,msefileutils,msectypes,mseapplication,msesysintf1,
 sysutils,msesysutils{$ifdef mswindows},activex{$endif};
const
 disconnecttag = 5936727;
 
{ tspeakevent }

constructor tspeakevent.create(const text: msestring;
                   const options: speakoptionsty; const voice: int32);
begin
 fmode:= smo_text;
 foptions:= options;
 fvoice:= voice;
 ftext:= text;
end;

constructor tspeakevent.create(const achar: char32;
               const options: speakoptionsty; const voice: int32);
begin
 fmode:= smo_char;
 foptions:= options;
 fvoice:= voice;
 fchar:= achar;
end;

constructor tspeakevent.createkey(const key: msestring;
               const options: speakoptionsty; const voice: int32);
begin
 fmode:= smo_key;
 foptions:= options;
 fvoice:= voice;
 ftext:= key;
end;

{ tvoices }

function tvoices.getitems(const index: int32): tvoice;
begin
 checkindex(index);
 result:= tvoice(fitems[index]);
end;

procedure tvoices.setitems(const index: int32; const avalue: tvoice);
begin
 checkindex(index);
 fitems[index].assign(avalue);
end;

constructor tvoices.create(const aowner: tcustomespeakng);
begin
 inherited create(aowner,tvoice);
 count:= 1;
end;

procedure tvoices.setcount1(acount: integer; doinit: boolean);
begin
 tcustomespeakng(fowner).lock();
 if (acount < 1) and not (aps_destroying in fstate) then begin
  acount:= 1;
 end;
 inherited;
 tcustomespeakng(fowner).unlock();
end;
 
{ tcustomespeakng }

constructor tcustomespeakng.create(aowner: tcomponent);
begin
 fvolume:= 1;
 frate:= 1;
 fpitch:= 1;
 frange:= 1;
 inherited;
 fvoices:= tvoices.create(self);
end;

destructor tcustomespeakng.destroy();
begin
 active:= false;
 fvoices.free();
 inherited;
end;

procedure tcustomespeakng.setactive(const avalue: boolean);
begin
 if avalue <> factive then begin
  if not(csloading in componentstate) then begin
   if avalue then begin
    connect();
   end
   else begin
    disconnect();
   end;
  end;
  factive:= avalue;
 end;
end;

procedure tcustomespeakng.setvoicedefault(avalue: int32);
begin
 if (avalue < 0) or (avalue >= fvoices.count) then begin
  avalue:= 0;
 end;
 fvoicedefault:= avalue;
end;

procedure tcustomespeakng.setvoices(const avalue: tvoices);
begin
 fvoices.assign(avalue);
end;

procedure tcustomespeakng.setpunctuationlist(const avalue: msestring);
begin
 if fpunctuationlist <> avalue then begin
  beginchange();
  fpunctuationlist:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setvolume(const avalue: flo64);
begin
 if fvolume <> avalue then begin
  beginchange();
  fvolume:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setrate(const avalue: flo64);
begin
 if frate <> avalue then begin
  beginchange();
  frate:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setpitch(const avalue: flo64);
begin
 if fpitch <> avalue then begin
  beginchange();
  fpitch:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setrange(const avalue: flo64);
begin
 if frange <> avalue then begin
  beginchange();
  frange:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setwordgap(const avalue: int32);
begin
 if fwordgap <> avalue then begin
  beginchange();
  fwordgap:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setlanguage(const avalue: msestring);
begin
 if flanguage <> avalue then begin
  beginchange();
  flanguage:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setidentifier(const avalue: msestring);
begin
 if fidentifier <> avalue then begin
  beginchange();
  fidentifier:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setvariant(const avalue: msestring);
begin
 if fvariant <> avalue then begin
  beginchange();
  fvariant:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setvoicename(const avalue: msestring);
begin
 if fvoicename <> avalue then begin
  beginchange();
  fvoicename:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.doasyncevent(var atag: int32);
begin
 if atag = disconnecttag then begin
  active:= false;
 end
 else begin
  inherited;
 end;
end;

procedure tcustomespeakng.setgender(const avalue: genderty);
begin
 if fgender <> avalue then begin
  beginchange();
  fgender:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setage(const avalue: card8);
begin
 if fage <> avalue then begin
  beginchange();
  fage:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setvariantnum(const avalue: card8);
begin
 if fvariantnum <> avalue then begin
  beginchange();
  fvariantnum:= avalue;
  endchange();
 end;
end;

procedure tcustomespeakng.setcapitals(const avalue: int32);
begin
 if fcapitals <> avalue then begin
  beginchange();
  fcapitals:= avalue;
  endchange();
 end;
end;

function tcustomespeakng.speakexe(athread: tmsethread): int32;
var
 ev1: tspeakevent;
 b1: boolean;
begin
{$ifdef mswindows}
 coinitialize(nil);
{$endif}
 with teventthread(athread) do begin
  while not terminated do begin
   pointer(ev1):= waitevent();
   if ev1 is tspeakevent then begin
    lock();
    b1:= ss_disconnected in fstate;
    checkerror(espeak_ng_setcancelstate(0));
    unlock();
    if not b1 then begin
     try
      case ev1.fmode of
       smo_text: begin
        internalspeak(ev1.ftext,ev1.foptions,ev1.fvoice);
       end;
       smo_char: begin
        internalspeakcharacter(ev1.fchar,ev1.foptions,ev1.fvoice);
       end;
       smo_key: begin
        internalspeakkeyname(ev1.ftext,ev1.foptions,ev1.fvoice);
       end;
      end;
     except
      application.handleexception();
     end;
    end;
   end;
   ev1.free();
   eventlist.lock();
   if eventlist.count = 0 then begin
    postidle();
   end;
   eventlist.unlock();
  end;
  postidle();
 end;
{$ifdef mswindows}
 couninitialize();
{$endif}
 result:= 0;
end;

procedure tcustomespeakng.loaded();
begin
 inherited;
 if factive then begin
  factive:= false;
  active:= true;
 end;
end;

procedure tcustomespeakng.connect();
var
 m1: espeak_ng_OUTPUT_MODE;
 s1: string;
begin
 if not (csdesigning in componentstate) then begin
  if assigned(fonbeforeconnect) then begin
   fonbeforeconnect(self);
  end;
  exclude(fstate,ss_disconnected);
  include(fstate,ss_idle);
  sys_condcreate(fidlecond);
  voicechanged();
  s1:= stringtoutf8ansi(tosysfilepath(fdatapath));
  initializeespeakng([],s1);
  
  m1:= ENOUTPUT_MODE_SYNCHRONOUS; 
//  m1:= 0;//ENOUTPUT_MODE_SYNCHRONOUS; 
             //espeak_ng_cancel() does not work in synchronous mode
  if not (eso_nospeakaudio in foptions) then begin
   m1:= m1 or ENOUTPUT_MODE_SPEAK_AUDIO;
  end;
  checkerror(espeak_ng_InitializeOutput(m1,fbufferlength,nil));
  include(fstate,ss_connected);
  fspeakthread:= teventthread.create(@speakexe);
 end;
end;

procedure tcustomespeakng.disconnect();
begin
 if not (csdesigning in componentstate) then begin
  cancel();
  fspeakthread.free();
  sys_conddestroy(fidlecond);
  exclude(fstate,ss_connected);
  releaseespeakng();
 end;
end;

procedure tcustomespeakng.checkerror(const astate: espeak_ng_status);
begin
 if (astate <> 0) and (astate <> ENS_SPEECH_STOPPED) then begin
  componentexception(self,utf8tostring(espeakngerrormessage(astate)));
 end;
end;

procedure tcustomespeakng.voicechanged();
begin
 exclude(fstate,ss_voicevalid);
end;

procedure tcustomespeakng.checkvoice(avoice: int32);
var
 info1: espeak_voice;
 name1,lang1,ident1,variant1: string;
 s1: string;
 ms1: msestring;
 ar1: card32arty;
 i1: int32;
 err1: espeak_ng_STATUS;
{$ifdef mse_debugassistive}
 p1: pespeak_voice;
{$endif}
begin
 lock();
 try
  if avoice < 0 then begin
   avoice:= fvoicedefault;
  end;
  if (avoice >= fvoices.count) then begin
   avoice:= 0;
  end;
  if not (ss_voicevalid in fstate) or (flastvoice <> avoice) then begin
   include(fstate,ss_voicevalid);
   flastvoice:= avoice;
   fillchar(info1,sizeof(info1),0);
   with voices[avoice] do begin
    if language <> '' then begin
     lang1:= stringtoutf8(language);
    end
    else begin
     lang1:= stringtoutf8(self.flanguage);
    end;
    info1.languages:= pointer(lang1);
    if identifier <> '' then begin
     ident1:= stringtoutf8(tosysfilepath(identifier));
    end
    else begin
     ident1:= stringtoutf8(tosysfilepath(self.identifier));
    end;
    info1.identifier:= pointer(ident1);
    if voicename <> '' then begin
     name1:= stringtoutf8(tosysfilepath(voicename));
    end
    else begin
     name1:= stringtoutf8(tosysfilepath(self.voicename));
    end;
    info1.name:= pointer(name1);
    if variant <> '' then begin
     variant1:= stringtoutf8(tosysfilepath(variant));
    end
    else begin
     variant1:= stringtoutf8(tosysfilepath(self.variant));
    end;
    info1.name:= pointer(name1);
    if gender <> gen_none then begin
     info1.gender:= ord(gender);
    end
    else begin
     info1.gender:= ord(self.gender);
    end;
    if age > 0 then begin
     info1.age:= age;
    end
    else begin
     info1.age:= self.age;
    end;
    if variantnum > 0 then begin
     info1.variant:= variantnum;
    end
    else begin
     info1.variant:= self.variantnum;
    end;
    if punctuationlist <> '' then begin
     ms1:= punctuationlist;
    end
    else begin
     ms1:= self.punctuationlist;
    end;
    setlength(ar1,length(ms1)+1); //terminating #0
    for i1:= 0 to high(ar1)-1 do begin
     ar1[i1]:= ord(ms1[i1+1]);
    end;
    checkerror(espeak_ng_setpunctuationlist(pointer(ar1)));
    if fid <> '' then begin
     err1:= espeak_ng_setvoicebyname(pchar(fid));
    end
    else begin
     s1:= '';
     if ident1 <> '' then begin
      s1:= ident1;
     end
     else begin
      if name1 <> '' then begin
       s1:= name1;
      end;
     end;
     if s1 <> '' then begin
      if variant1 <> '' then begin
       s1:= s1+'+'+variant1;
      end;
      err1:= espeak_ng_setvoicebyname(pchar(s1));
     end
     else begin
      err1:= espeak_ng_setvoicebyproperties(@info1);
     end;
     if err1 = ENS_OK then begin
      fid:= espeak_getcurrentvoice()^.identifier;
     end;
    end;
   {$ifdef mse_debugassistive}
    p1:= espeak_getcurrentvoice();
    debugwriteln(inttostr(avoice)+':'+p1^.identifier+':'+p1^.name);
   {$endif}
    if err1 <> ENS_OK then begin
     include(fstate,ss_disconnected);
     asyncevent(disconnecttag,[peo_local,peo_first]);
     checkerror(err1);
    end;
    checkerror(espeak_ng_setparameter(espeakRATE,round(rate*self.rate),0));
    checkerror(espeak_ng_setparameter(espeakVOLUME,
                                           round(volume*self.volume),0));
    checkerror(espeak_ng_setparameter(espeakPITCH,round(pitch*self.pitch),0));
    checkerror(espeak_ng_setparameter(espeakRANGE,round(range*self.range),0));
    checkerror(espeak_ng_setparameter(espeakPUNCTUATION,
                                                  ord(punctuation),0));
    if capitals < 0 then begin
     i1:= self.capitals;
    end
    else begin
     i1:= capitals;
    end;
    checkerror(espeak_ng_setparameter(espeakCAPITALS,i1,0));
    if wordgap < 0 then begin
     i1:= self.wordgap;
    end
    else begin
     i1:= wordgap;
    end;
    checkerror(espeak_ng_setparameter(espeakWORDGAP,i1,0));
   end;
  end;
 finally
  unlock();
 end;
end;

procedure tcustomespeakng.wait();
begin
 if not (ss_connected in fstate) then begin
  exit;
 end;
 with fspeakthread do begin
  sys_condlock(fidlecond);
  while true do begin
   if ss_idle in fstate then begin
    sys_condunlock(fidlecond);
    break;
   end
   else begin
    sys_condwait(fidlecond,0);
   end;
  end;
 end;
// checkerror(espeak_ng_synchronize());
end;

procedure tcustomespeakng.cancel();
begin
 if not (ss_connected in fstate) then begin
  exit;
 end;
{$ifdef mse_debugassistive}
 debugwriteln('---cancel');
{$endif}
 fspeakthread.clearevents();
 include(fstate,ss_canceled);
// fspeakthread.lock();
 checkerror(espeak_ng_setcancelstate(1));
// fspeakthread.unlock();
// postidle();
end;

procedure tcustomespeakng.internalspeak(const atext: msestring;
               const aoptions: speakoptionsty; const avoice: int32);
var
 s1: string;
 f1: cuint;
begin
  checkvoice(avoice);
  f1:= espeakCHARS_UTF8;
  if so_ssml in aoptions then begin
   f1:= f1 or espeakSSML;
  end;
  if so_phonemes in aoptions then begin
   f1:= f1 or espeakPHONEMES;
  end;
  if so_endpause in aoptions then begin
   f1:= f1 or espeakENDPAUSE;
  end;
  s1:= stringtoutf8(atext);
  replacechar1(s1,c_tab,' ');
// {$ifdef mse_debugassistive}
//   debugwriteln(inttostr(length(s1))+':'+s1);
// {$endif}
  checkerror(espeak_ng_synthesize(pchar(s1),length(s1)+1, //terminating #0
                               0,pos_character,0,f1,nil,nil));
end;

procedure tcustomespeakng.lock();
begin
 if ss_connected in fstate then begin
  fspeakthread.lock();
 end;
end;

procedure tcustomespeakng.unlock();
begin
 if ss_connected in fstate then begin
  fspeakthread.unlock();
 end;
end;

procedure tcustomespeakng.beginchange();
begin
 lock();
end;

procedure tcustomespeakng.endchange();
begin
 voicechanged();
 unlock();
end;

procedure tcustomespeakng.postidle();
begin
 sys_condlock(fidlecond);
 include(fstate,ss_idle);
 sys_condbroadcast(fidlecond);
 sys_condunlock(fidlecond);
end;

procedure tcustomespeakng.postevent(const aevent: tspeakevent);
begin
 if ss_canceled in fstate then begin
  wait();
  exclude(fstate,ss_canceled);
 end;
 fspeakthread.eventlist.lock();
 sys_condlock(fidlecond);
 exclude(fstate,ss_idle);
 fspeakthread.postevent(aevent);
 sys_condunlock(fidlecond);
 fspeakthread.eventlist.unlock();
end;

procedure tcustomespeakng.speak(const atext: msestring;
               const aoptions: speakoptionsty = []; const avoice: int32 = -1);
var
 c1: char16;
begin
 if not (ss_connected in fstate) then begin
  exit;
 end;
 if so_cancel in aoptions then begin
  cancel();
 end;
{$ifdef mse_debugassistive}
 debugwriteln('**'+inttostr(avoice)+'   '+string(atext));
{$endif}
 if atext <> '' then begin
  c1:= atext[length(atext)];
  if (c1 in ['.',',',':',';','?','!']) then begin
   postevent(tspeakevent.create(atext+' ',aoptions,avoice));
                        //last punctuation not spoken, espeak bug?
  end
  else begin
   postevent(tspeakevent.create(atext,aoptions,avoice));
  end;
 end;
 if so_wait in aoptions then begin
  wait();
 end;
end;

procedure tcustomespeakng.internalspeakcharacter(const achar: char32;
                       const aoptions: speakoptionsty; const avoice: int32);
begin
 checkvoice(avoice);
 checkerror(espeak_ng_speakcharacter(ord(achar)));
end;

procedure tcustomespeakng.speakcharacter(const achar: char32;
        const aoptions: speakoptionsty = []; const avoice: int32 = -1);
begin
 if not (ss_connected in fstate) then begin
  exit;
 end;
 if so_cancel in aoptions then begin
  cancel();
 end;
{$ifdef mse_debugassistive}
 debugwriteln('***'+inttostr(avoice)+'  '+string(unicodechar(achar)));
{$endif}
 postevent(tspeakevent.create(achar,aoptions,avoice));
 if so_wait in aoptions then begin
  wait();
 end;
end;

procedure tcustomespeakng.internalspeakkeyname(const akey: msestring;
                       const aoptions: speakoptionsty; const avoice: int32);
begin
 checkvoice(avoice);
 checkerror(espeak_ng_speakkeyname(pchar(stringtoutf8(akey))));
end;

procedure tcustomespeakng.speakkeyname(const akey: msestring;
               const aoptions: speakoptionsty = []; const avoice: int32 = -1);
begin
 if not (ss_connected in fstate) then begin
  exit;
 end;
 if so_cancel in aoptions then begin
  cancel();
 end;
{$ifdef mse_debugassistive}
 debugwriteln('****'+inttostr(avoice)+' '+string(akey));
{$endif}
 if akey <> '' then begin
  postevent(tspeakevent.createkey(akey,aoptions,avoice));
 end;
 if so_wait in aoptions then begin
  wait();
 end;
end;

{ tvoice }

constructor tvoice.create(aowner: tobject);
begin
 fpitch:= 50;
 frate:= espeakRATE_NORMAL;
 fvolume:= 100;
 frange:= 50;
 fcapitals:= -1;
 fwordgap:= -1;
 inherited;
end;
{
procedure tvoice.beginchange();
begin
 tcustomespeakng(fowner).lock();
end;

procedure tvoice.endchange();
begin
 tcustomespeakng(fowner).voicechanged();
 tcustomespeakng(fowner).unlock();
end;
}
procedure tvoice.setgender(const avalue: genderty);
begin
 if avalue <> fgender then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fgender:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setpitch(const avalue: int32);
begin
 if avalue <> fpitch then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fpitch:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setrate(const avalue: int32);
begin
 if avalue <> frate then begin
  change();
  tcustomespeakng(fowner).beginchange();
  frate:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setvolume(const avalue: int32);
begin
 if avalue <> fvolume then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fvolume:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setrange(const avalue: int32);
begin
 if avalue <> frange then begin
  change();
  tcustomespeakng(fowner).beginchange();
  frange:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setpunctuation(const avalue: punctuationty);
begin
 if avalue <> fpunctuation then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fpunctuation:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setcapitals(const avalue: int32);
begin
 if avalue <> fcapitals then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fcapitals:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setwordgap(const avalue: int32);
begin
 if avalue <> fwordgap then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fwordgap:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setvoicename(const avalue: msestring);
begin
 if avalue <> fvoicename then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fvoicename:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setvariant(const avalue: msestring);
begin
 if avalue <> fvariant then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fvariant:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setlanguage(const avalue: msestring);
begin
 if avalue <> flanguage then begin
  change();
  tcustomespeakng(fowner).beginchange();
  flanguage:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setidentifier(const avalue: msestring);
begin
 if avalue <> fidentifier then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fidentifier:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setage(const avalue: card8);
begin
 if avalue <> fage then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fage:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setvariantnum(const avalue: card8);
begin
 if avalue <> fvariantnum then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fvariantnum:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.setpunctuationlist(const avalue: msestring);
begin
 if avalue <> fpunctuationlist then begin
  change();
  tcustomespeakng(fowner).beginchange();
  fpunctuationlist:= avalue;
  tcustomespeakng(fowner).endchange();
 end;
end;

procedure tvoice.change();
begin
 fid:= '';
end;

end.
