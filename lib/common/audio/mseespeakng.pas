{/* eSpeak NG API.
 *
 * Copyright (C) 2015-2017 Reece H. Dunn
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */}

unit mseespeakng;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msectypes,msetypes,sysutils,msestrings;
 {$packrecords c}
 
const
{$ifdef mswindows}
 {$define wincall}
 espeaknglib: array[0..0] of filenamety = ('espeak-ng.dll');
{$else}
 sqlite3lib: array[0..1] of filenamety = 
                               ('libespeak-ng.so.1','libespeak-ng.so'); 
{$endif}

 ENS_GROUP_MASK = $70000000;
 ENS_GROUP_ERRNO = $00000000;     //* Values 0-255 map to errno error codes. */
 ENS_GROUP_ESPEAK_NG = $10000000; //* eSpeak NG error codes. */

//* eSpeak NG 1.49.0 */
 ENS_OK = 0;
 ENS_COMPILE_ERROR = $100001FF;
 ENS_VERSION_MISMATCH = $100002FF;
 ENS_FIFO_BUFFER_FULL = $100003FF;
 ENS_NOT_INITIALIZED = $100004FF;
 ENS_AUDIO_ERROR = $100005FF;
 ENS_VOICE_NOT_FOUND = $100006FF;
 ENS_MBROLA_NOT_FOUND = $100007FF;
 ENS_MBROLA_VOICE_NOT_FOUND = $100008FF;
 ENS_EVENT_BUFFER_FULL = $100009FF;
 ENS_NOT_SUPPORTED = $10000AFF;
 ENS_UNSUPPORTED_PHON_FORMAT = $10000BFF;
 ENS_NO_SPECT_FRAMES = $10000CFF;
 ENS_EMPTY_PHONEME_MANIFEST = $10000DFF;
 ENS_SPEECH_STOPPED = $10000EFF;

//* eSpeak NG 1.49.2 */
 ENS_UNKNOWN_PHONEME_FEATURE = $10000FFF;
 ENS_UNKNOWN_TEXT_ENCODING = $100010FF;

 espeakCHARS_AUTO =        0;
 espeakCHARS_UTF8 =        1;
 espeakCHARS_8BIT =        2;
 espeakCHARS_WCHAR =       3;
 espeakCHARS_16BIT =       4;
 espeakSSML =            $10;
 espeakPHONEMES =       $100;
 espeakENDPAUSE =      $1000;
 espeakKEEP_NAMEDATA = $2000;

 ENOUTPUT_MODE_SYNCHRONOUS = $0001;
 ENOUTPUT_MODE_SPEAK_AUDIO = $0002;

type
 espeak_ng_OUTPUT_MODE = cint32;

 espeak_PARAMETER = (
  espeakSILENCE=0, //* internal use */
  espeakRATE=1,
  espeakVOLUME=2,
  espeakPITCH=3,
  espeakRANGE=4,
  espeakPUNCTUATION=5,
  espeakCAPITALS=6,
  espeakWORDGAP=7,
  espeakOPTIONS=8,   // reserved for misc. options.  not yet used
  espeakINTONATION=9,

  espeakRESERVED1=10,
  espeakRESERVED2=11,
  espeakEMPHASIS,   //* internal use */
  espeakLINELENGTH, //* internal use */
  espeakVOICETYPE,  // internal, 1=mbrola
  N_SPEECH_PARAM    //* last enum */
 );

 espeak_POSITION_TYPE = (
  POS_CHARACTER = 1,
  POS_WORD,
  POS_SENTENCE
 );

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
 pespeak_VOICE = ^ espeak_VOICE;


 espeak_ng_STATUS = cuint;
 {
 espeak_ng_OUTPUT_MODE = (
  ENOUTPUT_MODE_SYNCHRONOUS = $0001,
  ENOUTPUT_MODE_SPEAK_AUDIO = $0002
 );
}
 espeak_ng_CONTEXT_TYPE = (
  ERROR_CONTEXT_FILE,
  ERROR_CONTEXT_VERSION
 );

 espeak_ng_ERROR_CONTEXT_ = record
  _type: espeak_ng_CONTEXT_TYPE;
  name: pchar;
  version: cint;
  expected_version: cint;
 end;
 espeak_ng_ERROR_CONTEXT = ^espeak_ng_ERROR_CONTEXT_;

 tespeakerror = class(exception)
  public
   constructor create(const err: espeak_ng_STATUS);
 end;
 
var
 espeak_ng_ClearErrorContext:
  procedure(context: espeak_ng_ERROR_CONTEXT) 
                                {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_GetStatusCodeMessage:
  procedure(status: espeak_ng_STATUS; buffer: pcchar; length: size_t)
                                {$ifdef wincall}stdcall{$else}cdecl{$endif};
{
ESPEAK_NG_API void
espeak_ng_PrintStatusCodeMessage(espeak_ng_STATUS status,
                                 FILE *out,
                                 espeak_ng_ERROR_CONTEXT context);
}
 espeak_ng_InitializePath:
  procedure(path: pcchar){$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_Initialize:
  function(context: espeak_ng_ERROR_CONTEXT): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_InitializeOutput:
  function(output_mode: espeak_ng_OUTPUT_MODE; buffer_length: cint;
                                      device: pcchar): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_GetSampleRate:
  function(): cint {$ifdef wincall}stdcall{$else}cdecl{$endif};

 espeak_ng_SetParameter:
  function(parameter: espeak_PARAMETER; value: cint;
                                       relative: cint): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_SetPunctuationList:
  function(punctlist: pwchar_t): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_SetVoiceByName:
  function(name: pcchar): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_SetVoiceByProperties:
  function(voice_selector: pespeak_VOICE): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_Synthesize:
  function(text: pointer; size: size_t;
                     position: cuint;
                     position_type: espeak_POSITION_TYPE;
                     end_position: cuint;
                     flags: cuint;
                     unique_identifier: pcuint;
                     user_data: pointer): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
{from espeak_Synthesize():
/* Synthesize speech for the specified text.  
 The speech sound data is passed to the calling
 program in buffers by means of the callback function specified by 
 espeak_SetSynthCallback(). The command is asynchronous: 
 it is internally buffered and returns as soon as possible.
 If espeak_Initialize was previously called with AUDIO_OUTPUT_PLAYBACK
 as argument, the sound data are played by eSpeak.

text: The text to be spoken, terminated by a zero character.
   It may be either 8-bit characters,
   wide characters (wchar_t), or UTF8 encoding.  Which of these is determined 
   by the "flags" parameter.

size: Equal to (or greatrer than) the size of the text data, in bytes.
   This is used in order
   to allocate internal storage space for the text.  This value is not used for
   AUDIO_OUTPUT_SYNCHRONOUS mode.

position:  The position in the text where speaking starts. Zero indicates 
   speak from the
   start of the text.

position_type:  Determines whether "position" is a number of characters, words,
                or sentences.
   Values:

end_position:  If set, this gives a character position at which speaking
               will stop.  A value of zero indicates no end position.

flags:  These may be OR'd together:
   Type of character codes, one of:
      espeakCHARS_UTF8     UTF8 encoding
      espeakCHARS_8BIT     The 8 bit ISO-8859 character set for 
                           the particular language.
      espeakCHARS_AUTO     8 bit or UTF8  (this is the default)
      espeakCHARS_WCHAR    Wide characters (wchar_t)
      espeakCHARS_16BIT    16 bit characters.

   espeakSSML   Elements within < > are treated as SSML elements, 
                or if not recognised are ignored.

   espeakPHONEMES  Text within [[ ]] is treated as phonemes codes 
                   (in espeak's Hirshenbaum encoding).

   espeakENDPAUSE  If set then a sentence pause is added at the end of the 
                   text.  If not set then this pause is suppressed.

unique_identifier: This must be either NULL, or point to an integer variable to
    which eSpeak writes a message identifier number.
    eSpeak includes this number in espeak_EVENT messages which are the result of
    this call of espeak_Synth().

user_data: a pointer (or NULL) which will be passed to the callback function in
    espeak_EVENT messages.

Return: EE_OK: operation achieved
        EE_BUFFER_FULL: the command can not be buffered;
          you may try after a while to call the function again.
 EE_INTERNAL_ERROR.
}
 espeak_ng_SynthesizeMark:
  function(text: pointer; size: size_t;
                         index_mark: pcchar;
                         end_position: cuint;
                         flags: cuint;
                         unique_identifier: pcuint;
                         user_data: pointer): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
{from espeak_SynthesizeMark():
/* Synthesize speech for the specified text. 
   Similar to espeak_Synth() but the start position is
   specified by the name of a <mark> element in the text.

   index_mark:  The "name" attribute of a <mark> element within the
      text which specified the point at which synthesis starts.  UTF8 string.

   For the other parameters, see espeak_Synth()

   Return: EE_OK: operation achieved
           EE_BUFFER_FULL: the command can not be buffered;
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
}
 espeak_ng_SpeakKeyName:
  function(key_name: pchar): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_SpeakCharacter:
  function(character: wchar_t): espeak_ng_STATUS
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_Cancel:
  function(): espeak_ng_STATUS {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_Synchronize:
  function(): espeak_ng_STATUS {$ifdef wincall}stdcall{$else}cdecl{$endif};
 espeak_ng_Terminate:
  function(): espeak_ng_STATUS {$ifdef wincall}stdcall{$else}cdecl{$endif};
{
ESPEAK_NG_API espeak_ng_STATUS
espeak_ng_CompileDictionary(const char *dsource,
                            const char *dict_name,
                            FILE *log,
                            int flags,
                            espeak_ng_ERROR_CONTEXT *context);

ESPEAK_NG_API espeak_ng_STATUS
espeak_ng_CompileMbrolaVoice(const char *path,
                             FILE *log,
                             espeak_ng_ERROR_CONTEXT *context);

ESPEAK_NG_API espeak_ng_STATUS
espeak_ng_CompilePhonemeData(long rate,
                             FILE *log,
                             espeak_ng_ERROR_CONTEXT *context);

ESPEAK_NG_API espeak_ng_STATUS
espeak_ng_CompileIntonation(FILE *log,
                            espeak_ng_ERROR_CONTEXT *context);

/* eSpeak NG 1.49.1 */

ESPEAK_NG_API espeak_ng_STATUS
espeak_ng_CompilePhonemeDataPath(long rate,
                                 const char *source_path,
                                 const char *destination_path,
                                 FILE *log,
                                 espeak_ng_ERROR_CONTEXT *context);
}

function espeakngerrormessage(const err: espeak_ng_STATUS): string;

procedure initializeespeakng(const sonames: array of filenamety;
                          const espeakdatapath: string = ''); //[],'' = default
procedure releaseespeakng();

implementation
uses
 msedynload;
var
 libinfo: dynlibinfoty;
 err: espeak_ng_ERROR_CONTEXT_;

function espeakngerrormessage(const err: espeak_ng_STATUS): string;
var
 buf: array[0..500] of char;
begin
 espeak_ng_GetStatusCodeMessage(err,@buf,sizeof(buf));
 result:= string(pchar(@buf))
end;

procedure checkerror(const astate: espeak_ng_status);
begin
 if astate <> 0 then begin
  raise tespeakerror.create(astate);
 end;
end;

procedure ini(const data: pointer);
begin
 espeak_ng_InitializePath(data);
 checkerror(espeak_ng_Initialize(@err));
end;

procedure fini(const data: pointer);
begin
 espeak_ng_terminate();
end;

procedure initializeespeakng(const sonames: array of filenamety;
                          const espeakdatapath: string = '');

const
 funcs: array[0..16] of funcinfoty = (
  (n: 'espeak_ng_ClearErrorContext'; d: @espeak_ng_ClearErrorContext),
  (n: 'espeak_ng_GetStatusCodeMessage'; d: @espeak_ng_GetStatusCodeMessage),
  (n: 'espeak_ng_InitializePath'; d: @ espeak_ng_InitializePath),
  (n: 'espeak_ng_Initialize'; d: @espeak_ng_Initialize),
  (n: 'espeak_ng_InitializeOutput'; d: @espeak_ng_InitializeOutput),
  (n: 'espeak_ng_GetSampleRate'; d: @espeak_ng_GetSampleRate),
  (n: 'espeak_ng_SetParameter'; d: @espeak_ng_SetParameter),
  (n: 'espeak_ng_SetPunctuationList'; d: @espeak_ng_SetPunctuationList),
  (n: 'espeak_ng_SetVoiceByName'; d: @espeak_ng_SetVoiceByName),
  (n: 'espeak_ng_SetVoiceByProperties'; d: @espeak_ng_SetVoiceByProperties),
  (n: 'espeak_ng_Synthesize'; d: @espeak_ng_Synthesize),
  (n: 'espeak_ng_SynthesizeMark'; d: @espeak_ng_SynthesizeMark),
  (n: 'espeak_ng_SpeakKeyName'; d: @espeak_ng_SpeakKeyName),
  (n: 'espeak_ng_SpeakCharacter'; d: @espeak_ng_SpeakCharacter),
  (n: 'espeak_ng_Cancel'; d: @espeak_ng_Cancel),
  (n: 'espeak_ng_Synchronize'; d: @espeak_ng_Synchronize),
  (n: 'espeak_ng_Terminate'; d: @espeak_ng_Terminate)
 );
 errormessage = 'Can not load eSpeakNG library. ';
begin
 initializedynlib(libinfo,sonames,sqlite3lib,funcs,[],errormessage,@ini,false,
                                                      pointer(espeakdatapath));
end;

procedure releaseespeakng();
begin
 releasedynlib(libinfo,@fini);
end;

{ tespeakerror }

constructor tespeakerror.create(const err: espeak_ng_STATUS);
begin
 inherited create('eSpeak error:'+lineend+espeakngerrormessage(err));
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
