{ MSEgui Copyright (c) 2017 by Martin Schreiber

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
 classes,mclasses,mseclasses,msetypes,mseespeakng,msearrayprops;
type
 espeakoptionty = (eso_nospeakaudio);
 espeakoptionsty = set of espeakoptionty;
 speakoptionty = (so_cancel,so_wait,so_ssml,so_phonemes,so_endpause);

 speakoptionsty = set of speakoptionty;

 tespeakng = class;

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
   fname: msestring;
   flanguage: msestring;
   fidentifier: msestring;
   fage: card8;
   fvariant: card8;
   procedure setgender(const avalue: genderty);
   procedure setpitch(const avalue: int32);
   procedure setrate(const avalue: int32);
   procedure setvolume(const avalue: int32);
   procedure setrange(const avalue: int32);
   procedure setpunctuation(const avalue: punctuationty);
   procedure setcapitals(const avalue: int32);
   procedure setwordgap(const avalue: int32);
   procedure setname(const avalue: msestring);
   procedure setlanguage(const avalue: msestring);
   procedure setidentifier(const avalue: msestring);
   procedure setage(const avalue: card8);
   procedure setvariant(const avalue: card8);
  protected
   procedure changed();
  public
   constructor create(aowner: tobject); override;
  published
 //  property name: msestring read fname write setname;
   property name: msestring read fname write setname;
   property language: msestring read flanguage write setlanguage;
                  //example: en-uk
   property identifier: msestring read fidentifier write setidentifier;
                  // the filename for this voice within
                  //espeak-ng-data/voices
   property gender: genderty read fgender write setgender default gen_none;
   property age: card8 read fage write setage default 0;
   property variant: card8 read fvariant write setvariant default 0;

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
   property punctuation: punctuationty read fpunctuation 
                          write setpunctuation default pu_none;
     {espeakPUNCTUATION:  which punctuation characters to announce:
         value in espeak_PUNCT_TYPE (none, all, some),
         see espeak_GetParameter() to specify which characters are announced.}
   property capitals: int32 read fcapitals write setcapitals default 0;
     {espeakCAPITALS: announce capital letters by:
         0=none,
         1=sound icon,
         2=spelling,
         3 or higher, by raising pitch.  
           This values gives the amount in Hz by which the pitch
            of a word raised to indicate it has a capital letter.}
   property wordgap: int32 read fwordgap write setwordgap default 0;
     {espeakWORDGAP:  pause between words, units of 10mS (at the default speed)}
 end;

 tvoices = class(townedpersistentarrayprop)
  private
   function getitems(const index: int32): tvoice;
   procedure setitems(const index: int32; const avalue: tvoice);
  protected
   procedure checkcount(var acount: integer) override;
  public
   constructor create(const aowner: tespeakng);
   property items[const index: int32]: tvoice read getitems write setitems; default;
 end;

 speakstatety = (ss_voicevalid,ss_punctuationvalid);
 speakstatesty = set of speakstatety;
  
 tespeakng = class(tmsecomponent)
  private
   factive: boolean;
   fdatapath: filenamety;
   foptions: espeakoptionsty;
   fdevice: msestring;
   fbufferlength: int32;
   fbufferlengt: int32;
   fvoicedefault: int32;
   fvoices: tvoices;
   fpunctuationlist: msestring;
   procedure setactive(const avalue: boolean);
   procedure setvoicedefault(avalue: int32);
   procedure setvoices(const avalue: tvoices);
   procedure setpunctuationlist(const avalue: msestring);
  protected
   fstate: speakstatesty;
   flastvoice: int32;
   procedure loaded() override;
   procedure connect();
   procedure disconnect();
   procedure checkerror(const astate: espeak_ng_status);
   procedure voicechanged();
   procedure checkvoice(avoice: int32);
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
  published
   property active: boolean read factive write setactive default false;
   property datapath: filenamety read fdatapath write fdatapath;
   property options: espeakoptionsty read foptions write foptions default [];
   property device: msestring read fdevice write fdevice;
   property bufferlength: int32 read fbufferlength write fbufferlengt default 0;
                                           //ms, 0 -> 60ms
   property voicedefault: int32 read fvoicedefault 
                                   write setvoicedefault default 0;
   property voices: tvoices read fvoices write setvoices;
   property punctuationlist: msestring read fpunctuationlist
                                                 write setpunctuationlist;
                                          //for voice.punctuation pu_some
 end;
 
implementation
uses
 msestrings,msefileutils,msectypes;

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

constructor tvoices.create(const aowner: tespeakng);
begin
 inherited create(aowner,tvoice);
 count:= 1;
end;

procedure tvoices.checkcount(var acount: integer);
begin
 if acount < 1 then begin
  acount:= 1;
 end;
 inherited;
end;
 
{ tespeakng }

constructor tespeakng.create(aowner: tcomponent);
begin
 inherited;
 fvoices:= tvoices.create(self);
end;

destructor tespeakng.destroy();
begin
 active:= false;
 fvoices.free();
 inherited;
end;

procedure tespeakng.setactive(const avalue: boolean);
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

procedure tespeakng.setvoicedefault(avalue: int32);
begin
 if (avalue < 0) or (avalue >= fvoices.count) then begin
  avalue:= 0;
 end;
 fvoicedefault:= avalue;
end;

procedure tespeakng.setvoices(const avalue: tvoices);
begin
 fvoices.assign(avalue);
end;

procedure tespeakng.setpunctuationlist(const avalue: msestring);
begin
 fpunctuationlist:= avalue;
 exclude(fstate,ss_punctuationvalid);
end;

procedure tespeakng.loaded();
begin
 inherited;
 if factive then begin
  factive:= false;
  active:= true;
 end;
end;

procedure tespeakng.connect();
var
 m1: espeak_ng_OUTPUT_MODE;
begin
 if not (csdesigning in componentstate) then begin
  voicechanged();
  initializeespeakng([],stringtoutf8(tosysfilepath(fdatapath)));
  m1:= 0;
  if not (eso_nospeakaudio in foptions) then begin
   m1:= m1 or ENOUTPUT_MODE_SPEAK_AUDIO;
  end;
  checkerror(espeak_ng_InitializeOutput(m1,0,nil));
 end;
end;

procedure tespeakng.disconnect();
begin
 if not (csdesigning in componentstate) then begin
  releaseespeakng();
 end;
end;

procedure tespeakng.checkerror(const astate: espeak_ng_status);
begin
 if astate <> 0 then begin
  componentexception(self,utf8tostring(espeakngerrormessage(astate)));
 end;
end;

procedure tespeakng.voicechanged();
begin
 exclude(fstate,ss_voicevalid);
end;

procedure tespeakng.checkvoice(avoice: int32);
var
 info1: espeak_voice;
 s1,s2,s3: string;
 ar1: card32arty;
 i1: int32;
begin
 if avoice < 0 then begin
  avoice:= fvoicedefault;
 end;
 if (avoice >= fvoices.count) then begin
  avoice:= 0;
 end;
 if not (ss_punctuationvalid in fstate) then begin
  include(fstate,ss_punctuationvalid);
  setlength(ar1,length(fpunctuationlist));
  for i1:= 0 to high(ar1) do begin
   ar1[i1]:= ord(fpunctuationlist[i1+1]);
  end;
  checkerror(espeak_ng_setpunctuationlist(pointer(ar1)));
 end;
 if not (ss_voicevalid in fstate) or (flastvoice <> avoice) then begin
  include(fstate,ss_voicevalid);
  flastvoice:= avoice;
  fillchar(info1,sizeof(info1),0);
  with voices[avoice] do begin
   s1:= stringtoutf8(name);
   info1.name:= pointer(s1);
   s2:= stringtoutf8(language);
   info1.languages:= pointer(s2);
   s3:= stringtoutf8(tosysfilepath(identifier));
   info1.identifier:= pointer(s3);
   info1.gender:= ord(gender);
   info1.age:= age;
   info1.variant:= variant;
   checkerror(espeak_ng_setvoicebyproperties(@info1));
   checkerror(espeak_ng_setparameter(espeakRATE,rate,0));
   checkerror(espeak_ng_setparameter(espeakVOLUME,volume,0));
   checkerror(espeak_ng_setparameter(espeakPITCH,pitch,0));
   checkerror(espeak_ng_setparameter(espeakRANGE,range,0));
   checkerror(espeak_ng_setparameter(espeakPUNCTUATION,ord(punctuation),0));
   checkerror(espeak_ng_setparameter(espeakCAPITALS,capitals,0));
   checkerror(espeak_ng_setparameter(espeakWORDGAP,wordgap,0));
  end;
 end;
end;
{
 espeak_VOICE = record
  name: pcchar;      // a given name for this voice. UTF8 string.
  languages: pcchar;  // list of pairs of (byte) priority + 
                      //(string) language (and dialect qualifier)
  identifier: pcchar; // the filename for this voice within
                      //espeak-ng-data/voices
  gender: cuchar;  // 0=none 1=male, 2=female,
  age: cuchar;     // 0=not specified, or age in years
  variant: cuchar; // only used when passed as a parameter to 
                   //espeak_SetVoiceByProperties
  xx1: cuchar;     // for internal use
  score: cint;       // for internal use
  spare: pointer;     // for internal use
 end;
}

procedure tespeakng.speak(const atext: msestring;
               const aoptions: speakoptionsty = []; const avoice: int32 = -1);
var
 s1: string;
 f1: cuint;
begin
 if not factive then begin
  exit;
 end;
 if so_cancel in aoptions then begin
  checkerror(espeak_ng_cancel());
 end;
 if atext <> '' then begin
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
  checkerror(espeak_ng_synthesize(pchar(s1),length(s1),0,pos_character,0,
                 f1,nil,nil));
 end;
 if so_wait in aoptions then begin
  checkerror(espeak_ng_synchronize());
 end;
end;

procedure tespeakng.speakcharacter(const achar: char32;
        const aoptions: speakoptionsty = []; const avoice: int32 = -1);
begin
 if not factive then begin
  exit;
 end;
 if so_cancel in aoptions then begin
  checkerror(espeak_ng_cancel());
 end;
 checkvoice(avoice);
 checkerror(espeak_ng_speakcharacter(ord(achar)));
 if so_wait in aoptions then begin
  checkerror(espeak_ng_synchronize());
 end;
end;

procedure tespeakng.speakkeyname(const akey: msestring;
               const aoptions: speakoptionsty = []; const avoice: int32 = -1);
begin
 if not factive then begin
  exit;
 end;
 if so_cancel in aoptions then begin
  checkerror(espeak_ng_cancel());
 end;
 if akey <> '' then begin
  checkvoice(avoice);
  checkerror(espeak_ng_speakkeyname(pchar(stringtoutf8(akey))));
 end;
 if so_wait in aoptions then begin
  checkerror(espeak_ng_synchronize());
 end;
end;

{ tvoice }

constructor tvoice.create(aowner: tobject);
begin
 fpitch:= 50;
 frate:= espeakRATE_NORMAL;
 fvolume:= 100;
 frange:= 50;
 inherited;
end;

procedure tvoice.changed();
begin
 tespeakng(fowner).voicechanged();
end;

procedure tvoice.setgender(const avalue: genderty);
begin
 if avalue <> fgender then begin
  fgender:= avalue;
  changed();
 end;
end;

procedure tvoice.setpitch(const avalue: int32);
begin
 if avalue <> fpitch then begin
  fpitch:= avalue;
  changed();
 end;
end;

procedure tvoice.setrate(const avalue: int32);
begin
 if avalue <> frate then begin
  frate:= avalue;
  changed();
 end;
end;

procedure tvoice.setvolume(const avalue: int32);
begin
 if avalue <> fvolume then begin
  fvolume:= avalue;
  changed();
 end;
end;

procedure tvoice.setrange(const avalue: int32);
begin
 if avalue <> frange then begin
  frange:= avalue;
  changed();
 end;
end;

procedure tvoice.setpunctuation(const avalue: punctuationty);
begin
 if avalue <> fpunctuation then begin
  fpunctuation:= avalue;
  changed();
 end;
end;

procedure tvoice.setcapitals(const avalue: int32);
begin
 if avalue <> fcapitals then begin
  fcapitals:= avalue;
  changed();
 end;
end;

procedure tvoice.setwordgap(const avalue: int32);
begin
 if avalue <> fwordgap then begin
  fwordgap:= avalue;
  changed();
 end;
end;

procedure tvoice.setname(const avalue: msestring);
begin
 if avalue <> fname then begin
  fname:= avalue;
  changed();
 end;
end;

procedure tvoice.setlanguage(const avalue: msestring);
begin
 if avalue <> flanguage then begin
  flanguage:= avalue;
  changed();
 end;
end;

procedure tvoice.setidentifier(const avalue: msestring);
begin
 if avalue <> fidentifier then begin
  fidentifier:= avalue;
  changed();
 end;
end;

procedure tvoice.setage(const avalue: card8);
begin
 if avalue <> fage then begin
  fage:= avalue;
  changed();
 end;
end;

procedure tvoice.setvariant(const avalue: card8);
begin
 if avalue <> fvariant then begin
  fvariant:= avalue;
  changed();
 end;
end;

end.
