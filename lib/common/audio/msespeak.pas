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

 tvoice = class(townedpersistent)
 end;
 
 tvoices = class(townedpersistentarrayprop)
  protected
   procedure checkcount(var acount: integer) override;
  public
   constructor create(const aowner: tespeakng);
 end;
 
 tespeakng = class(tmsecomponent)
  private
   factive: boolean;
   fdatapath: filenamety;
   foptions: espeakoptionsty;
   fdevice: msestring;
   fbufferlength: int32;
   fbufferlengt: int32;
   fdefaultvoice: int32;
   fvoices: tvoices;
   procedure setactive(const avalue: boolean);
   procedure setdefaultvoice(avalue: int32);
   procedure setvoices(const avalue: tvoices);
  protected
   procedure loaded() override;
   procedure connect();
   procedure disconnect();
   procedure checkerror(const astate: espeak_ng_status);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   procedure speak(const atext: msestring; const aoptions: speakoptionsty = [];
                        const avoice: int32 = -1); //-1 -> default
  published
   property active: boolean read factive write setactive default false;
   property datapath: filenamety read fdatapath write fdatapath;
   property options: espeakoptionsty read foptions write foptions default [];
   property device: msestring read fdevice write fdevice;
   property bufferlength: int32 read fbufferlength write fbufferlengt default 0;
                                           //ms, 0 -> 60ms
   property defaultvoice: int32 read fdefaultvoice write setdefaultvoice;
   property voices: tvoices read fvoices write setvoices;
 end;
 
implementation
uses
 msestrings,msefileutils,msectypes;

{ tvoices }

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

procedure tespeakng.setdefaultvoice(avalue: int32);
begin
 if (avalue < 0) or (avalue >= fvoices.count) then begin
  avalue:= 0;
 end;
 fdefaultvoice:= avalue;
end;

procedure tespeakng.setvoices(const avalue: tvoices);
begin
 fvoices.assign(avalue);
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

procedure tespeakng.speak(const atext: msestring;
               const aoptions: speakoptionsty = []; const avoice: int32 = -1);
var
 s1: string;
 f1: cuint;
begin
 if so_cancel in aoptions then begin
  checkerror(espeak_ng_cancel());
 end;
 if atext <> '' then begin
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

end.
