{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestream;   
{$ifdef FPC}
 {$if defined(FPC) and (fpc_fullversion >= 020501)}
  {$define mse_fpc_2_6} 
 {$ifend}
 {$ifdef mse_fpc_2_6}
  {$define mse_hasvtunicodestring}
 {$endif}
{$endif}

{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

// {$WARN SYMBOL_PLATFORM off}
interface
uses 
 classes,mclasses,sysutils,msestrings,msetypes,msethread,msesystypes,msesys,msereal,
 mseevent,mseclasses,mseglob{,mseformatstr};

const
 defaultfilerights = [s_irusr,s_iwusr,s_irgrp,s_iwgrp,s_iroth,s_iwoth];
 defaultdirrights = [s_irusr,s_iwusr,s_ixusr,s_irgrp,s_iwgrp,
                     s_ixgrp,s_iroth,s_iwoth,s_ixoth];
type

 tmsefilestream = class;

 cryptoclientstatety = (ccs_open);
 cryptoclientstatesty = set of cryptoclientstatety;
 cryptohandlerdataty = array[0..32] of pointer;

 tcustomcryptohandler = class; 
 cryptoclientinfoty = record
  stream: tmsefilestream;
  link: tcustomcryptohandler;
  linkindex: integer;
//  chainend: tcustomcryptohandler;
// chainendindex: integer;
  {
  linkbuf: pbyte;
  linkbufsize: integer;
  linkbuflength: integer;
  linkbufpos: integer;
  }
  state: cryptoclientstatesty;
  handlerdata: cryptohandlerdataty;
 end;
 pcryptoclientinfoty = ^cryptoclientinfoty;
 cryptoclientinfoarty = array of cryptoclientinfoty;

 tcustomcryptohandler = class(tmsecomponent)
  private
   fclients: cryptoclientinfoarty;
   fchain: tcustomcryptohandler;
   procedure setchain(const avalue: tcustomcryptohandler);
  protected
   fchainend: tcustomcryptohandler;
   procedure flush(var aclient: cryptoclientinfoty); overload; virtual;
   procedure flushchain(var aclient: cryptoclientinfoty);
   procedure writeerror(var aclient: cryptoclientinfoty);
   procedure readerror(var aclient: cryptoclientinfoty);
   procedure finalizeclient(var aclient: cryptoclientinfoty); virtual;
   function checkopen(const aindex: integer): pcryptoclientinfoty;
   procedure connect(const aclient: tmsefilestream;
           const alink: tcustomcryptohandler; const aindex: integer;
                 out endhandler: tcustomcryptohandler; out endindex: integer);
   procedure disconnect({const aclient: tmsefilestream;
                             const alink: tcustomcryptohandler}
                             const aindex: integer);
   procedure open(var aclient: cryptoclientinfoty); virtual;
   procedure close(var aclient: cryptoclientinfoty); virtual;
   function read(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint; virtual;
   function write(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint; virtual;
   function seek(var aclient: cryptoclientinfoty;
                   const offset: int64; origin: tseekorigin): int64; virtual;
   function  getsize(var aclient: cryptoclientinfoty): int64; virtual;
   function getclient(const astream: tmsefilestream): pcryptoclientinfoty;
//   function getopenclient(const astream: tmsefilestream): pcryptoclientinfoty;
  public
   destructor destroy; override;
   procedure flush(const astream: tmsefilestream); overload;
   function encrypt(const adata: string; const base64: boolean = false;
               const maxlinelength: integer = defaultbase64linelength): string;
                                      overload;
   function encrypt(const adata: pointer; adatalength: integer;
                    const base64: boolean = false;
               const maxlinelength: integer = defaultbase64linelength): string;
                                      overload;
   function decrypt(const adata: string; const base64: boolean = false): string;
   function encrypttext(const atext: msestring;
                               const base64: boolean = false;
              const maxlinelength: integer = defaultbase64linelength): string;
   function decrypttext(const adata: string;
                               const base64: boolean = false): msestring;
  published
   property chain: tcustomcryptohandler read fchain write setchain;
 end;
 
   {$warnings off}
 tmsefilestream = class(thandlestream)
  private
   ffilename: filenamety;
   fopenmode: fileopenmodety;
   ffilerights: filerightsty;
   ftransactionname: filenamety;
   fcryptohandler: tcustomcryptohandler;
   fendhandler: tcustomcryptohandler;
   fendindex: integer;
//   function getmemory: pointer;
   procedure checkmemorystream;
   procedure setcryptohandler(const avalue: tcustomcryptohandler);
   function getfilerights: filerightsty;
   procedure setfilerights(const avalue: filerightsty);
  protected
   fmemorystream: tmemorystream;
   procedure sethandle(value: integer); virtual;
   procedure closehandle(const ahandle: integer); virtual;
   constructor internalcreate(const afilename: filenamety; 
                      const aopenmode: fileopenmodety;
                      const accessmode: fileaccessmodesty;
                      const rights: filerightsty;
                      out error: syserrorty); overload;
   function  getsize: int64; override;
   function  inheritedgetsize: int64;
   function inheritedread(var buffer; count: longint): longint;
   function inheritedwrite(const buffer; count: longint): longint;
   function inheritedseek(const offset: int64;
                                       origin: tseekorigin): int64;
   function getmemory: pointer; override;
  public
   constructor create(const afilename: filenamety; 
                      const aopenmode: fileopenmodety = fm_read;
                      const accessmode: fileaccessmodesty = [];
                      const rights: filerightsty = defaultfilerights); overload;
   constructor createtransaction(const afilename: filenamety;
                      rights: filerightsty = defaultfilerights); overload;
   constructor createtempfile(const prefix: filenamety; 
                                                  out afilename: filenamety);
   constructor create(ahandle: integer); overload; virtual; //allways called
   constructor create; overload; 
                                  //memorystream
   constructor create(const aopenmode: fileopenmodety); overload; 
                                  //memorystream
   constructor createstringcopy(const adata: string); //implies fm_read
   destructor destroy; override;
   class function trycreate(out ainstance: tmsefilestream;
             const afilename: filenamety;
             const aopenmode: fileopenmodety = fm_read;
             const accessmode: fileaccessmodesty = [];
             const rights: filerightsty = defaultfilerights): syserrorty;
   function read(var buffer; count: longint): longint; override;
   function write(const buffer; count: longint): longint; override;
   function seek(const offset: int64; origin: tseekorigin): int64; override;
   function readdatastring: string; override;
             //read available data
   procedure writedatastring(const value: rawbytestring); override;
   function isopen: boolean;
   property filename: filenamety read ffilename;
   property openmode: fileopenmodety read fopenmode;
   property transactionname: filenamety read ftransactionname;
   function close: boolean; //false on commit error
   procedure cancel; //calls close without commit, removes intermediate file
   procedure flushbuffer; virtual;
   procedure flush; virtual;

   procedure setsize(const newsize: int64); override;
   procedure clear; virtual;        //only for memorystream
//   property memory: pointer read getmemory;     //only for memorystream
   property filerights: filerightsty read getfilerights write setfilerights;
   property cryptohandler: tcustomcryptohandler read fcryptohandler 
                                                   write setcryptohandler;
 end;
   {$warnings on}

const
 defaultbuflen = 2048;
 minbuflen = 256;

type
 textstreamstatety = (tss_eof,tss_error,tss_notopen,tss_pipeactive,tss_response,
                      tss_nosigio,tss_unblocked,tss_haslink);
 textstreamstatesty = set of textstreamstatety;

 charencodingty = (ce_locale,ce_utf8,ce_ascii,ce_iso8859_1);
                         //ce_ascii -> 7Bit,
                         //string and msestrings -> pascalstrings

 tcustombufstream = class(tmsefilestream)
  private
   finternalbuffer: string;
   fbuflen: integer;
   fcachedposition: int64;

   fusewritebuffer: boolean;
   procedure setusewritebuffer(const avalue: boolean);
   function getbufpo: pchar;
  protected
   fwriting: boolean;
   fbuffer: pchar;
   bufoffset, bufend: pchar;
   fstate: textstreamstatesty;
   function getnotopen: boolean;
   procedure setbuflen(const Value: integer); virtual;
   function geteof: boolean;
   function readbytes(var buf): integer; virtual;
              //reads max. buflen bytes
   procedure internalwritebuffer(const buffer; count: longint);
  public
   constructor create(ahandle: integer); override;
   constructor createdata(const adata: rawbytestring);
   procedure clear; override;        //only for memorystream

   procedure setsize(const newsize: int64); override;
   function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
   function Read(var Buffer; Count: Longint): Longint; override;
   function Write(const Buffer; Count: Longint): Longint; override;

   procedure flushbuffer; override;

   property buflen: integer read fbuflen write setbuflen default defaultbuflen;
   property usewritebuffer: boolean read fusewritebuffer 
                                       write setusewritebuffer default false;
   property eof: boolean read geteof;
   property bufpo: pchar read getbufpo;
   procedure skip(const adist: integer); //skips characters
 end;

 tbufstream = class(tcustombufstream)
  public
 end;

 eolflagty = (eolf_linefeed,eolf_returnlinefeed);
 eolflagsty = set of eolflagty;
 eolstylety = (eol_unknown,eol_system,eol_unix,eol_windows);
 
 ttextstream = class(tcustombufstream)
  private
   fposvorher: int64;
   fsearchabortpo: pboolean;
   fsearchlinestartpos: longword;
   fsearchlinenumber: longword;
   fsearchpos: longword;
   fsearchfoundpos: longword;
   fsearchtext: string;
   fsearchtextlower: string;
   fsearchtextupper: string;
   fsearchoptions: searchoptionsty;
   fsearchtextvalid: boolean;
   feolstyle: eolstylety;
   procedure setsearchtext(const Value: string);
   function getmsesearchtext: msestring;
   procedure setmsesearchtext(const avalue: msestring);
   procedure setsearchoptions(const Value: searchoptionsty);
   procedure seteolstyle(const avalue: eolstylety);
  protected
   fencoding: charencodingty;
   feolflags: eolflagsty;
   feol: string;
   function encode(const value: msestring): string;
   function decode(const value: string): msestring;
  public
   constructor create(ahandle: integer); override;
   class function trycreate(out ainstance: ttextstream;
             const afilename: filenamety;
             const aopenmode: fileopenmodety = fm_read;
             const accessmode: fileaccessmodesty = [];
             const rights: filerightsty = defaultfilerights): syserrorty;
   procedure return;    //setzt filepointer auf letzte readln position
   
   procedure writestr(const value: string); //no encoding
   procedure writestrln(const value: string); //no encoding
   function readstrln(var value: string): boolean; overload; virtual;
               //not out, variable address will be checked for nil
               //no encoding
   procedure writetotext(var dest: text);   //no encoding

   procedure write(const value: string); reintroduce; overload;
   procedure write(const value: msestring); reintroduce; overload;
   procedure write(const value: real); reintroduce;  overload;
   procedure write(const value: integer); reintroduce; overload;
   procedure write(const value: boolean); reintroduce; overload;
   procedure write(const values: array of const); reintroduce; overload;

   procedure writeln; overload;
   procedure writeln(const value: string); overload; virtual;
   procedure writeln(const value: msestring); overload;
   procedure writeln(const value: real);  overload;
   procedure writeln(const value: integer);  overload;
   procedure writeln(const value: boolean);  overload;
   procedure writeln(const value: msestringarty);  overload;
   procedure writeln(const value: stringarty);  overload;
   procedure writeln(const values: array of const); overload;

   function readln: boolean; overload;
   function readln(var value: string): boolean; overload;      
           //true wenn zeile vollstaendig, sonst eof erreicht
   function readln(var value: msestring): boolean; overload;       
           //true wenn zeile vollstaendig, sonst eof erreicht
   function readln(out value: integer): boolean; overload;
           //true wenn zeile vollstaendig, sonst eof erreicht
   function readln(out value: boolean): boolean; overload;
           //true wenn zeile vollstaendig, sonst eof erreicht
   function readln(out value: real): boolean; overload;
           //true wenn zeile vollstaendig, sonst eof erreicht
   function readln(out value: msestringarty): boolean; overload;
           //true wenn zeile vollstaendig, sonst eof erreicht
   function readln(out value: stringarty): boolean; overload;
           //true wenn zeile vollstaendig, sonst eof erreicht

   procedure writestrings(const value: stringarty);
   procedure writemsestrings(const value: msestringarty);
   function readstrings: stringarty;
   function readmsestrings: msestringarty;
   function readmsedatastring: msestring; //returns remainig data 
   function readstring(const default: string): string;
                //liest string, bringt defaultwert bei fehler
   function readinteger(default: integer; min: integer = minint;
                            max: integer = maxint): integer;
                //liest integer, bringt defaultwert bei fehler
   function readboolean(default: boolean): boolean;
                //liest boolean, bringt defaultwert bei fehler
   function readreal(default: real; min: real = -bigreal;
                            max: real = bigreal): real;
                //liest double, bringt defaultwert bei fehler
                //       begrenzt wert auf min..max
   function findnext(const substring: string): boolean;
            //positioiniert filepointer auf erstes vorkommen von substring, true wenn gefunden
            //wenn nicht gefunden wird filepointer nicht veraendert
            //performance verbesserungswuerdig!!
   function linecount: integer;
            //zaehlt ab aktueller position anzahl linefeeds bis eof

   procedure resetsearch;
   function searchnext: boolean; //true wenn gefunden
   property nativesearchtext: string read fsearchtext write setsearchtext;
   property msesearchtext: msestring read getmsesearchtext 
                                                     write setmsesearchtext;
   property searchoptions: searchoptionsty read fsearchoptions 
                                                      write setsearchoptions;
   property searchpos: longword read fsearchpos write fsearchpos;
   property searchfoundpos: longword read fsearchfoundpos;
   property searchlinestartpos: longword read fsearchlinestartpos 
                                                    write fsearchlinestartpos;
   property searchlinenumber: longword read fsearchlinenumber 
                                                     write fsearchlinenumber;
   property searchabortpo: pboolean read fsearchabortpo write fsearchabortpo;

   property notopen: boolean read getnotopen;
   property encoding: charencodingty read fencoding write fencoding 
                                                         default ce_locale;
   function foundeolstyle: eolstylety; //found by readln
   property eolstyle: eolstylety read feolstyle 
                              write seteolstyle default eol_unknown;
                                       //for writeln
 end;

 ttextdatastream = class(ttextstream)
  private
   fquotechar: msechar;
   fseparator: msechar;
   fforcequote: boolean;
  public                //!!!!!!todo: correct encoding, (linebreaks, whitespaces ...)
   constructor create(ahandle: integer); override;
   function readcsvstring(out value: msestring): boolean;
                     //true if lineend
   function readcsvvalues(out values: msestringarty): boolean;
                     //true if lineend

   procedure writerecord(const fields: array of const); overload;
   procedure writerecord(const fields: msestringarty); overload;
   procedure writerecord(const fields: stringarty); overload;
   procedure writerecord(const fields: integerarty); overload;
   procedure writerecord(const fields: realarty); overload;
   procedure writerecord(const fields: int64arty); overload;
   procedure writerecord(const fields: booleanarty); overload;
   function readrecord(fields: array of pointer; types: string): boolean; //true if no error
                // b -> boolean
                // i -> integer
                // I -> int64
                // s -> ansistring
                // S -> msestring
                // r -> real
   property separator: msechar read fseparator write fseparator default ',';
   property quotechar: msechar read fquotechar write fquotechar default '"';
   property forcequote: boolean read fforcequote write fforcequote default false;
 end;

 tresourcefilestream = class(tmsefilestream)
  public
   procedure WriteResourceHeader(resourcetyp: word;
             const ResName: string; out FixupInfo: Integer);
 end;

 tcryptfilestream = class(tfilestream)      //seek nicht erlaubt!
         //used to obfuscate ini files, obsolete
  private
   seed: word;
   schluesseln: boolean;
   procedure krypt16(var buffer; count: integer);

  public
   constructor Create(const aFileName: string; Mode: Word);

   function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
   function Read(var Buffer; Count: Longint): Longint; override;
   function Write(const Buffer; Count: Longint): Longint; override;
                       //buffer wird veraendert!
 end;

 tstringcopystream = class(tmemorystream)
  private
   fdata: string;
  protected
   function getmemory: pointer; override;
  public
   constructor create(const adata: string);
   destructor destroy; override;
   function readdatastring: string; override;
   function write(const Buffer; Count: Longint): Longint; override;
 end;

 ttextstringcopystream = class(ttextdatastream)
  private
   fdata: string;
  protected
   function getmemory: pointer; override;
  public
   constructor create(const adata: string);
   destructor destroy; override;
   function write(const Buffer; Count: Longint): Longint; override;
 end;

 tmemorycopystream = class(tmemorystream)
  private
  protected
  public
   constructor create(const adata: pointer; const asize: integer);
   destructor destroy; override;
   function write(const Buffer; Count: Longint): Longint; override;
 end;

 tstringbufferstream = class(tmemorystream)
  private
   fdata: string;
   function getdata: string;
  protected
   function realloc(var newcapacity: ptrint): pointer; override;
  public
   constructor create(const adata: string);
   property data: string read getdata;
 end;

 ttextstringbufferstream = class(ttextdatastream)
  private
   function getdata: string;
  public
   constructor create(const adata: string;
                              const aopenmode: fileopenmodety = fm_create);
   property data: string read getdata;
 end;
  
function getnextbufferline(var data: pchar; len: integer): string;
                  //data = nil -> fertig
function getbufferline(const data: pchar; linenr,len: integer): string;
                  //1. zeile = 0
function getkeystring(const data: pchar; len: integer; name: string): string;
                  //bringt nach '<name>=' folgenden text
procedure setfilenonblock(handle: integer; value: boolean);

procedure copyvariantarray(const source: array of const; const dest: array of pointer);

function getrecordtypechars(const fields: array of const): string;
                // b -> boolean
                // i -> integer
                // I -> int64
                // s -> ansistring
                // S -> msestring
                // r -> real

function encodestring(const value: msestring; 
                           const encoding: charencodingty = ce_utf8): string;
function decodestring(const value: string; 
                   const encoding: charencodingty = ce_utf8): msestring;

function encoderecord(const fields: array of const;
               forcequote: boolean = false; const quotechar: msechar = '"';
               const separator: msechar = ','): msestring;
function decoderecord(const value: msestring;
                   const fields: array of pointer; const types: string;
               const quotechar: msechar = '"';
               const separator: msechar = ','): boolean; overload;
                // types:
                // b -> boolean
                // i -> integer
                // I -> int64
                // s -> ansistring
                // S -> msestring
                // r -> real

function readstreamdatastring(const astream: tstream): string; 
               //reads from current pos to eof               
function readfiledatastring(const afilename: filenamety): string;
function tryreadfiledatastring(const afilename: filenamety;
                                    out adata: string): syserrorty;
procedure writefiledatastring(const afilename: filenamety; const adata: string);
function trywritefiledatastring(const afilename: filenamety;
                                    const adata: string): syserrorty;

implementation

uses
 msefileutils,msebits,{msegui,}sysconst,msesysutils,
 msesysintf1,msesysintf,mseformatstr,msefloattostr,
 msedatalist,mseapplication,msearrayutils,
        {$ifdef UNIX} mselibc,
        {$else} windows,
        {$endif}
  rtlconsts;

{
 tmemorystreamcracker = class(tcustommemorystream)
  private
    FCapacity: Longint;
 end;
}
{$ifdef FPC}
type
 pboolean = ^boolean;
{$endif}

 {$ifdef MSWINDOWS}

 {$else}

  {$ifdef FPC}  //bug in bfcntlh.inc
  {
const
   O_ACCMODE = $3;
   O_RDONLY = $0;
   O_WRONLY = $1;
   O_RDWR = $2;
   O_CREAT = $40;
   O_EXCL = $80;
   O_NOCTTY = $100;
   O_TRUNC = $200;
   O_APPEND = $400;
   O_NONBLOCK = $800;
   O_NDELAY = O_NONBLOCK;
   O_SYNC = $1000;
   O_FSYNC = O_SYNC;
   O_ASYNC = $2000;

   O_DIRECT = $4000;
   O_DIRECTORY = $10000;
   O_NOFOLLOW = $20000;

   O_DSYNC = O_SYNC;
   O_RSYNC = O_SYNC;

   O_LARGEFILE = $8000;
   }
  {$endif}
 {$endif}
const
 windowseol = #$0d#$0a;
 unixeol = #$0a;

{$ifdef mswindows}
 syseol = windowseol;
{$else}
 syseol = unixeol;
{$endif}

(*
 windowseol: array[0..1] of char = (#$0d,#$0a);
 unixeol: array[0..0] of char = (#$0a);

 {$ifdef mswindows}
 syseol: array[0..1] of char = (#$0d,#$0a);
 {$else}
 syseol: array[0..0] of char = (#$0a);
 {$endif}
*)
const
 kryptsignatur = $9617ae3c;
type
 tstream1 = class(tstream);
 tmemorystream1 = class(tmemorystream);

function readfiledatastring(const afilename: filenamety): string;
var
 stream1: tmsefilestream;
begin
 stream1:= tmsefilestream.create(afilename);
 try
  result:= stream1.readdatastring;
 finally
  stream1.free;
 end;
end;

function tryreadfiledatastring(const afilename: filenamety;
                                    out adata: string): syserrorty;
var
 stream1: tmsefilestream;
begin
 adata:= '';
 result:= tmsefilestream.trycreate(stream1,afilename);
 if result = sye_ok then begin
  try
   adata:= stream1.readdatastring;
  except
   result:= sye_read;
  end;
  stream1.free;
 end;
end;

procedure writefiledatastring(const afilename: filenamety; const adata: string);
var
 stream1: tmsefilestream;
begin
 stream1:= tmsefilestream.create(afilename,fm_create);
 try
  stream1.writedatastring(adata);
 finally
  stream1.free;
 end;
end;

function trywritefiledatastring(const afilename: filenamety;
                                    const adata: string): syserrorty;
var
 stream1: tmsefilestream;
begin
 result:= tmsefilestream.trycreate(stream1,afilename,fm_create);
 if result = sye_ok then begin
  try
   stream1.writedatastring(adata);
  except
   result:= sye_write;
  end;
  stream1.free;
 end;
end;

function readstreamdatastring(const astream: tstream): string; 
               //reads from current pos to eof               
var
 size1: ptrint;
 pos1: ptrint;
 lint1,lint2: ptrint;
begin
 size1:= astream.size-astream.position;
 if size1 < 256 then begin
  size1:= 256;
 end;
 setlength(result,size1+1);
 pos1:= 0;
 while true do begin 
  lint1:= size1-pos1;
  lint2:= astream.read((pchar(pointer(result))+pos1)^,lint1+1);
  pos1:= pos1+lint2;
  if lint2 <= lint1 then begin
   setlength(result,pos1);
   break;
  end; 
  size1:= size1 * 2;
  setlength(result,size1+1);
 end;
end;

procedure streamerror;
begin
 syserror(syelasterror,'Streamerror: ');
end;

 {$ifdef UNIX}
procedure setfilenonblock(handle: integer; value: boolean);
var
 int1: integer;
begin
 int1:= fcntl(handle,f_getfl,[0]);
 if int1 = -1 then begin
  streamerror;
 end;
 if value then begin
  int1:= int1 or o_nonblock;
 end
 else begin
  int1:= int1 and not o_nonblock;
 end;
 if fcntl(handle,f_setfl,[int1]) = -1 then begin
  streamerror;
 end;
end;
 {$else}
procedure setfilenonblock(handle: integer; value: boolean);
begin
 raise exception.Create('nonblock not supported');
end;
 {$endif}

function getnextbufferline(var data: pchar; len: integer): string;
     //data = nil -> fertig
var
 po1: pchar;
 int1: integer;
begin
 result:= '';
 po1:= data;
 int1:= len;
 po1:= strlscan(po1,c_linefeed,int1);
 if po1 <> nil then begin
  int1:= po1-data;
  dec(int1);
  if (po1+int1)^ = c_return then begin
   dec(int1);
  end;
  if int1 > 0 then begin
   setlength(result,int1);
   move(data^,result[1],int1)
  end;
  inc(po1);
 end;
 data:= po1;
end;

function getbufferline(const data: pchar; linenr,len: integer): string;
                  //1. zeile = 0
var
 po1: pchar;
 int1: integer;
begin
 result:= '';
 po1:= data;
 for int1:= 0 to linenr do begin
  result:= getnextbufferline(po1,len-(po1-data));
 end;
end;

function getkeystring(const data: pchar; len: integer; name: string): string;
                  //bringt nach '<name>=' folgenden text
var
 po1: pchar;
begin
 result:= '';
 po1:= data;
 name:= name+'=';
 while po1 <> nil do begin
  result:= getnextbufferline(po1,len-(po1-data));
  if pos(name,result) = 1 then begin
   result:= copy(result,length(name)+1,length(result));
   break;
  end;
 end;
end;

function encodestring(const value: msestring; 
                           const encoding: charencodingty = ce_utf8): string;
begin
 case encoding  of
  ce_ascii: begin
   result:= stringtopascalstring(value);
  end;
  ce_utf8: begin
   result:= stringtoutf8ansi(value);
  end;
  ce_iso8859_1: begin
   result:= stringtolatin1(value);
  end;
  else begin //ce_locale
   result:= ansistring(value);
  end;
 end;
end;

function decodestring(const value: string; 
                   const encoding: charencodingty = ce_utf8): msestring;
begin
 case encoding  of
  ce_ascii: begin
   result:= pascalstringtostring(value);
  end;
  ce_utf8: begin
   result:= utf8tostringansi(value);
  end;
  ce_iso8859_1: begin
   result:= latin1tostring(value);
  end;
  else begin //ce_ansi or current locale
   result:= msestring(value);
  end;
 end;
end;

function encoderecord(const fields: array of const;
               forcequote: boolean = false; const quotechar: msechar = '"';
               const separator: msechar = ','): msestring;
var
 int1: integer;
 mstr1: msestring;
 first: boolean;
 seps: msestring;
begin
 first:= true;
 seps:= msechar(c_return) + msestring(c_linefeed) + msestring(quotechar) + separator;
 result:= '';
 for int1:= 0 to high(fields) do begin
  mstr1:= '';
  with tvarrec(fields[int1]) do begin
   case vtype of
    vtInteger:    mstr1:= inttostrmse(VInteger);
    vtBoolean:    if VBoolean then mstr1:= 'T' else mstr1:= 'F';
    vtChar:       mstr1:= msestring(VChar);
    vtExtended:   if not (vextended^ = emptyreal) then begin
                    mstr1:= doubletostring(VExtended^);
                  end;
    vtString:     mstr1:= msestring(VString^);
    vtWideChar:   mstr1:= VWideChar;
    vtPChar:      mstr1:= msestring(string(VPChar));
    vtPWideChar:  mstr1:= msestring(VPWideChar);
    vtAnsiString: mstr1:= msestring(ansistring(VAnsiString));
    vtCurrency:   mstr1:= currencytostrmse(VCurrency^);
    vtWideString: mstr1:= msestring(VWideString);
    {$ifdef mse_hasvtunicodestring}
    vtunicodeString: mstr1:= msestring(VunicodeString);
    {$endif}
    vtInt64:      mstr1:= inttostrmse(VInt64^);
   end;
  end;
//  escapechars(mstr1);
  if (mstr1 <> '') and (quotechar <> #0) then begin
   if forcequote or (findchars(mstr1,seps) <> 0) then begin
    mstr1:= quotestring(mstr1,quotechar);
   end;
  end;
  if not first then begin
   result:= result + separator + mstr1;
  end
  else begin
   result:= result + mstr1;
  end;
  first:= false;
 end;
end;

procedure copyvariantarray(const source: array of const; const dest: array of pointer);
var
 int1,int2: integer;
begin
 int2:= high(source);
 if int2 > high(dest) then begin
  int2:= high(dest);
 end;
 for int1:= 0 to int2 do begin
  case source[int1].vtype of
   vtInteger:    pinteger(dest[int1])^:= source[int1].vinteger;
   vtBoolean:    pboolean(dest[int1])^:= source[int1].VBoolean;
   vtChar:       pchar(dest[int1])^:= source[int1].VChar;
   vtExtended:   preal(dest[int1])^:= source[int1].VExtended^;
   vtString:     pshortstring(dest[int1])^:= source[int1].VString^;
   vtWideChar:   pwidechar(dest[int1])^:= source[int1].VWideChar;
   vtPChar:      ppchar(dest[int1])^:= source[int1].VPChar;
   vtPWideChar:  ppwidechar(dest[int1])^:= source[int1].VPwideChar;
   vtAnsiString: pansistring(dest[int1])^:= ansistring(source[int1].VAnsiString);
   vtCurrency:   pcurrency(dest[int1])^:= source[int1].Vcurrency^;
   vtwidestring: pmsestring(dest[int1])^:= msestring(source[int1].VwideString);
  {$ifdef mse_hasvtunicodestring}
   vtunicodestring: pmsestring(dest[int1])^:= msestring(source[int1].VunicodeString);
  {$endif}
   vtInt64:      pint64(dest[int1])^:= source[int1].Vint64^;
  end;
 end;
end;

function getrecordtypechars(const fields: array of const): string;
                // b -> boolean
                // i -> integer
                // I -> int64
                // s -> ansistring
                // S -> msestring
                // r -> real
var
 int1: integer;
 ch1: char;
begin
 setlength(result,length(fields));
 for int1:= 0 to high(fields) do begin
  ch1:= ' ';
  case fields[int1].VType of
   vtboolean: begin
    ch1:= 'b';
   end;
   vtinteger: begin
    ch1:= 'i';
   end;
   vtint64: begin
    ch1:= 'I';
   end;
   vtansistring: begin
    ch1:= 's';
   end;
  {$ifdef mse_hasvtunicodestring}
   vtunicodestring,
  {$endif}
   vtwidestring: begin
    ch1:= 'S';
   end;
   vtextended: begin
    ch1:= 'r';
   end;
  end;
  result[int1+1]:= ch1;
 end;
end;

function decoderecord(const value: msestring;
                   const fields: array of pointer; const types: string;
                // b -> boolean
                // i -> integer
                // I -> int64
                // s -> ansistring
                // S -> msestring
                // r -> real
               const quotechar: msechar = '"';
               const separator: msechar = ','): boolean;
var
 ar1: msestringarty;
 int1: integer;
begin
 result:= true;
 ar1:= nil;
 if quotechar <> #0 then begin
  splitstringquoted(value,ar1,quotechar,separator);
 end
 else begin
  splitstring(value,ar1,separator);
 end;
 for int1:= 0 to length(types) - 1 do begin
  if int1 > high(fields) then begin
   result:= false;
   break;
  end;
  if int1 > high(ar1) then begin
   break;
  end;
//  unescapechars(ar1[int1]);
  if fields[int1] <> nil then begin
   case types[int1+1] of
    ' ': begin
    end;
    'b': begin
     if ar1[int1] = 'T' then begin
      pboolean(fields[int1])^:= true;
     end
     else begin
      pboolean(fields[int1])^:= false;
     end;
    end;
    'i': begin
     result:= result and trystrtoint(ar1[int1],pinteger(fields[int1])^);
    end;
    'I': begin
     result:= result and trystrtoint64(ar1[int1],pint64(fields[int1])^);
    end;
    'r': begin
     if ar1[int1] = '' then begin
      preal(fields[int1])^:= emptyreal;
     end
     else begin
      result:= result and trystrtoreal(ar1[int1],preal(fields[int1])^);
     end;
    end;
    's': begin
     pstring(fields[int1])^:= ansistring(ar1[int1]);
    end;
    'S': begin
      pmsestring(fields[int1])^:= ar1[int1];
    end;
    else begin
     result:= false;
    end;
   end;
  end;
 end;
end;

{ tmsefilestream }

constructor tmsefilestream.create(ahandle: integer); //allways called
begin
 ffilerights:= defaultfilerights;
 inherited create(ahandle);
end;

constructor tmsefilestream.create;
begin
 if fmemorystream = nil then begin
  fmemorystream:= tmemorystream.create;
 end;
 create(invalidfilehandle);
end;

constructor tmsefilestream.create(const aopenmode: fileopenmodety);
begin
 fopenmode:= aopenmode;
 create;
end;

constructor tmsefilestream.createstringcopy(const adata: string);
begin
 fmemorystream:= tstringcopystream.create(adata);
 create(fm_read);
end;

constructor tmsefilestream.internalcreate(const afilename: filenamety; 
                      const aopenmode: fileopenmodety;
                      const accessmode: fileaccessmodesty;
                      const rights: filerightsty;
                      out error: syserrorty);
var
 ahandle: integer;
begin
 ffilename:= filepath(afilename);
 fopenmode:= aopenmode;
 if openmode = fm_append then begin
  error:= sys_openfile(ffilename,fm_readwrite,accessmode,rights,ahandle);
  if error <> sye_ok then begin
   error:= sys_openfile(ffilename,fm_create,accessmode,rights,ahandle);
  end;
 end
 else begin
  error:= sys_openfile(ffilename,aopenmode,accessmode,rights,ahandle);
 end;
 create(ahandle);
 if error = sye_ok then begin
  if aopenmode = fm_append then begin
   position:= size;
  end;
 end
 else begin
 end;
end;

class function tmsefilestream.trycreate(out ainstance: tmsefilestream;
               const afilename: filenamety;
               const aopenmode: fileopenmodety = fm_read;
               const accessmode: fileaccessmodesty = [];
               const rights: filerightsty = defaultfilerights): syserrorty;
begin
 ainstance:= internalcreate(afilename,aopenmode,accessmode,rights,result);
 if result <> sye_ok then begin
  freeandnil(ainstance);
 (*
 {$ifdef FPC}
  freeandnil(self);
 {$else}
  application.releaseobject(self);
 {$endif}
 *)
 end;
end;

constructor tmsefilestream.create(const afilename: filenamety;
            const aopenmode: fileopenmodety = fm_read;
            const accessmode: fileaccessmodesty = [];
            const Rights: filerightsty = defaultfilerights);  
            //!!!!todo linux lock
var
 mstr1: msestring;
 error: syserrorty;
begin
 internalcreate(afilename,aopenmode,accessmode,rights,error);
 if error <> sye_ok then begin
  mstr1:= ffilename;
  ffilename:= '';
  if aopenmode in [fm_create,fm_append] then begin
{$ifdef FPC}
   raise EFCreateError.CreateFmt(SFCreateError+lineend+'%s',[mstr1,
                                       sys_geterrortext(mselasterror)]);
{$else}

 {$if rtlversion > 14.1}
   raise EFCreateError.CreateResFmt(@SFCreateErrorEx,
       [mstr1, sys_geterrortext(mselasterror)]);
 {$else}
   raise EFCreateError.CreateResFmt(@SFCreateError,
       [mstr1, sys_geterrortext(mselasterror)]);
 {$ifend}
{$endif}
  end
  else begin
{$ifdef FPC}
   raise EFCreateError.CreateFmt(SFopenError+lineend+'%s',[mstr1,
                                               sys_geterrortext(mselasterror)]);
{$else}
  {$if rtlversion > 14.1}
   raise EFOpenError.CreateResFmt(@SFOpenErrorEx,
      [mstr1,sys_geterrortext(mselasterror)]);
  {$else}
   raise EFOpenError.CreateResFmt(@SFOpenError,
      [mstr1,sys_geterrortext(mselasterror)]);
  {$ifend}
{$endif}
  end;
 end;
end;

constructor tmsefilestream.createtransaction(const afilename: filenamety;
            rights: filerightsty = defaultfilerights);
begin
 if afilename = '' then begin
  raise exception.create('No transaction name.');
 end;
 ftransactionname:= afilename;
 create(intermediatefilename(afilename),fm_create,[fa_denywrite],rights);
end;

constructor tmsefilestream.createtempfile(const prefix: filenamety;
                                                   out afilename: filenamety);
begin
 application.lock;
 try
  create(intermediatefilename(msegettempdir+prefix),fm_create,[],
                            [msesys.s_irusr,msesys.s_iwusr]);
  afilename:= filename;
 finally
  application.unlock;
 end;
end;

destructor tmsefilestream.Destroy;
begin
 close;
 cryptohandler:= nil;
 inherited Destroy;
 fmemorystream.Free;
end;

procedure tmsefilestream.closehandle(const ahandle: integer);
begin
 sys_closefile(ahandle);
end;
 
procedure tmsefilestream.sethandle(value: integer);
begin
 if value <> handle then begin
  if handle <> invalidfilehandle then begin
   flushbuffer;
   closehandle(handle);
  end;
  fhandle:= value;
 end;
end;

function tmsefilestream.close: boolean;  //false on commit error
begin
 result:= true;
 if fendhandler <> nil then begin
  with fendhandler do begin
   if ccs_open in fclients[fendindex].state then begin
    try
     close(fclients[fendindex]);
    except
     application.handleexception;
    end;
   end;
  end;
 end;
 if (handle <> invalidfilehandle) and (ftransactionname <> '') and
          (ffilename <> '') then begin
  flush;
  sethandle(invalidfilehandle);
  result:= sys_renamefile(ffilename,ftransactionname) = sye_ok;
 end
 else begin
  sethandle(invalidfilehandle);
 end;
 ffilename:= '';
 ftransactionname:= '';
end;

procedure tmsefilestream.cancel;
var
 fstr1: filenamety;
begin
 if (ftransactionname <> '') and (ffilename <> '') then begin
  fstr1:= ffilename;
  ftransactionname:= '';
  close;
  sys_deletefile(fstr1);
 end
 else begin
  close;
 end;
end;

procedure tmsefilestream.flush;
begin
 if fendhandler <> nil then begin
  fendhandler.flushchain(fendhandler.fclients[fendindex]);
 end;
 flushbuffer;
 if handle <> invalidfilehandle then begin
  syserror(sys_flushfile(handle));
 end;
end;

function tmsefilestream.isopen: boolean;
begin
 result:= handle <> invalidfilehandle;
end;

function tmsefilestream.Read(var Buffer; Count: longint): Longint;
begin
// if fmemorystream <> nil then begin
//  result:= fmemorystream.Read(buffer,count);
// end
// else begin
  if fendhandler <> nil then begin
   with fendhandler do begin
    result:= read(checkopen(fendindex)^,buffer,count);
   end;
  end
  else begin
   result:= inheritedread(buffer,count);
  end;
// end;
end;

function tmsefilestream.Write(const Buffer; Count: longint): Longint;
begin
// if fmemorystream <> nil then begin
//  result:= fmemorystream.Write(Buffer,count);
// end
// else begin
  if fendhandler <> nil then begin
   with fendhandler do begin
    result:= write(checkopen(fendindex)^,buffer,count);
   end;
  end
  else begin
   result:= inheritedwrite(buffer,count);
  end;
// end;
end;

function tmsefilestream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
// if fmemorystream <> nil then begin
//  result:= fmemorystream.Seek(offset,origin);
// end
// else begin
  if fendhandler <> nil then begin
   with fendhandler do begin
    result:= seek(checkopen(fendindex)^,offset,origin);
   end;
  end
  else begin
   result:= inheritedseek(offset,origin);
  end;
// end;
end;

function tmsefilestream.getsize: int64;
begin
 if fendhandler <> nil then begin
  with fendhandler do begin
   result:= getsize(checkopen(fendindex)^);
  end;
 end
 else begin
  result:= inherited getsize;
 end;
end;

function tmsefilestream.readdatastring: string;
var
 int1,int2,int3: sizeint;
 lint1,lint2: int64;
begin
 if fcryptohandler = nil then begin
  if fmemorystream <> nil then begin
   result:= fmemorystream.readdatastring;
  end
  else begin
   result:= inherited readdatastring;
  end;
 end
 else begin
  if fmemorystream <> nil then begin
   lint1:= fmemorystream.size;
  end
  else begin
   lint1:= position;
   lint2:= inheritedseek(0,soend); //file size
   inheritedseek(lint1,sobeginning);
   lint1:= lint2-lint1;
  end;
  setlength(result,lint1-position);
  if result = '' then begin
   setlength(result,256); //possibly buffered block
  end;
  int1:= 0;
  while true do begin
   int3:= length(result)-int1;
   if int3 <= 0 then begin
    break;
   end;
   int2:= read((pchar(pointer(result))+int1)^,int3);
   int1:= int1 + int2;
   if int2 < int3 then begin
    break;
   end;
   setlength(result,length(result)*2); //grow buffer
  end;
  setlength(result,int1);
 end;
end;

procedure tmsefilestream.writedatastring(const value: rawbytestring);
begin
 if (value <> '') or (fcryptohandler <> nil) then begin
  writebuffer(pointer(value)^,length(value));
 end;
end;

procedure tmsefilestream.SetSize(const NewSize: Int64);
begin
 if fmemorystream <> nil then begin
  fmemorystream.SetSize(newsize);
 end
 else begin
  inherited;
 end;
end;
{
function tmsefilestream.getmemory: pointer;
begin
 result:= fmemorystream.memory;
end;
}
procedure tmsefilestream.checkmemorystream;
begin
 if fmemorystream = nil then begin
  raise exception.create('Must be memory stream.');
 end;
end;

procedure tmsefilestream.clear;
begin
 checkmemorystream;
 fmemorystream.clear; 
end;

procedure tmsefilestream.flushbuffer;
begin
 //dummy
end;

procedure tmsefilestream.setcryptohandler(const avalue: tcustomcryptohandler);
begin
// if fcryptohandler <> nil then begin
//  fcryptohandler.disconnect(self,nil);
// end;
 if fendhandler <> nil then begin
  try
   fendhandler.disconnect(fendindex);
  except
   application.handleexception;
  end;
  fendhandler:= nil;
 end;
 fcryptohandler:= avalue;
 if fcryptohandler <> nil then begin
  fcryptohandler.connect(self,nil,-1,fendhandler,fendindex);
 end;
end;

function tmsefilestream.inheritedread(var buffer; count: longint): longint;
begin
 if fmemorystream <> nil then begin
  result:= fmemorystream.Read(buffer,count);
 end
 else begin
  result:= sys_read(fhandle,@buffer,count);
 end;
 if result < 0 then begin
  result:= 0;
 end;
end;

function tmsefilestream.inheritedwrite(const buffer; count: longint): longint;
begin
 if fmemorystream <> nil then begin
  result:= fmemorystream.Write(Buffer,count);
 end
 else begin
  result:= sys_write(fhandle,@buffer,count);
 end;
 if result < 0 then begin
  result:= 0;
 end;
end;

function tmsefilestream.inheritedseek(const offset: int64;
               origin: tseekorigin): int64;
begin
 if fmemorystream <> nil then begin
  result:= fmemorystream.Seek(offset,origin);
 end
 else begin
  result:= inherited seek(offset,origin);
 end;
end;

function tmsefilestream.inheritedgetsize: int64;
begin
 result:= inherited getsize;
end;

function tmsefilestream.getmemory: pointer;
begin
 if fmemorystream <> nil then begin
  result:= fmemorystream.memory;
 end
 else begin
  result:= inherited getmemory;
 end;
end;

function tmsefilestream.getfilerights: filerightsty;
var
 stat1: fileinfoty;
begin
 if (fhandle <> invalidfilehandle) and sys_getfdinfo(fhandle,stat1) then begin
  result:= fileattributestofilerights(stat1.extinfo1.attributes);
 end
 else begin
  result:= ffilerights;
 end;
end;

procedure tmsefilestream.setfilerights(const avalue: filerightsty);
begin
 ffilerights:= avalue;
 if fhandle <> invalidfilehandle then begin
  sys_setfdrights(fhandle,avalue,ffilename);
 end;
end;

{ tresourcefilestream}

procedure TresourcefileStream.WriteResourceHeader(resourcetyp: word;
            const ResName: string; out FixupInfo: Integer);
var
  HeaderSize: Integer;
  Header: array[0..79] of Char;
begin
  Byte((@Header[0])^) := $FF;
  Word((@Header[1])^) := resourcetyp;
  HeaderSize := StrLen(StrUpper(StrPLCopy(pchar(@Header[3]), ResName, 63))) + 10;
  Word((@Header[HeaderSize - 6])^) := $1030;
  Longint((@Header[HeaderSize - 4])^) := 0;
  WriteBuffer(Header, HeaderSize);
  FixupInfo := Position;
end;

{ tcustombufstream }

constructor tcustombufstream.Create(AHandle: integer);
begin
// bufoffset:= nil;
 buflen:= defaultbuflen;
 inherited;
end;

constructor tcustombufstream.createdata(const adata: rawbytestring);
begin
 create;
 writedatastring(adata);
 position:= 0;
end;

procedure tcustombufstream.flushbuffer;
var
 po1: pointer;
begin
 if fwriting then begin
  fwriting:= false;
  if bufoffset <> nil then begin
   po1:= bufoffset;
   bufoffset:= nil;
   internalwritebuffer(fbuffer^,po1-fbuffer);   
  end;
 end;
end;

procedure tcustombufstream.internalwritebuffer(const buffer; count: longint);
var
 int1: integer;
begin
 int1:= inherited write(buffer,count);
 if (int1 >= 0) and (fcachedposition >= 0) then begin
  fcachedposition:= fcachedposition + int1;
 end;
 if int1 <> count then begin
  raise ewriteerror.create(swriteerror);
 end;
end;

function tcustombufstream.write(const buffer; count: longint): integer;
begin
 if fusewritebuffer then begin
  result:= count;
  if fwriting and (bufoffset <> nil) then begin
   if buflen - (bufoffset - fbuffer) < count then begin
    flushbuffer;
   end;
  end;
  if (bufoffset = nil) then begin
   if (buflen > count) then begin
    move(buffer,fbuffer^,count);
    bufoffset:= fbuffer+count;
    fwriting:= true;
   end
   else begin
    result:= inherited write(buffer,count);
    if (result >= 0) and (fcachedposition >= 0) then begin
     fcachedposition:= fcachedposition + result;
    end;
   end;
  end
  else begin
   if buflen - (bufoffset - fbuffer) >= count then begin
    move(buffer,bufoffset^,count);
    bufoffset:= bufoffset+count;
    fwriting:= true;
   end
   else begin
    result:= inherited write(buffer,count);
    if (result >= 0) and (fcachedposition >= 0) then begin
     fcachedposition:= fcachedposition + result;
    end;
   end;
  end
 end
 else begin
  result:= inherited write(buffer,count);
  if (result >= 0) and (fcachedposition >= 0) then begin
   fcachedposition:= fcachedposition + result;
  end;
 end;
end;
{
function tcustombufstream.Write(const Buffer; Count: Integer): Longint;
begin
 flushbuffer;
 bufoffset:= nil;
 result:= inherited write(buffer,count);
end;
}

procedure tcustombufstream.setbuflen(const Value: integer);
begin
 if fbuflen <> value then begin
  flushbuffer;
  fbuflen:= value;
  if fbuflen < minbuflen then begin
   fbuflen:= minbuflen;
  end;
  setlength(finternalbuffer,fbuflen);
  fbuffer:= pointer(finternalbuffer);
  bufoffset:= nil;
 end;
end;

function tcustombufstream.readbytes(var buf): integer;
begin
 result:= inherited read(buf,fbuflen);
 if result > 0 then begin
  exclude(fstate,tss_eof);
  if fcachedposition >= 0 then begin
   fcachedposition:= fcachedposition + result;
  end;
 end;
end;

function tcustombufstream.geteof: boolean;
begin
 result:= fstate * [tss_eof,tss_notopen,tss_error] <> [];
end;

function tcustombufstream.getnotopen: boolean;
begin
 result:= tss_notopen in fstate;
end;

procedure tcustombufstream.setusewritebuffer(const avalue: boolean);
begin
 flushbuffer;
 fusewritebuffer:= avalue;
end;

function tcustombufstream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
 if (origin = sobeginning) and (bufoffset <> nil) and 
                                          (fcryptohandler = nil) then begin
//  result:= inherited seek(0,socurrent);
  result:= fcachedposition;
  if result >= 0 then begin
   result:= seek(offset-result+(bufend-bufoffset),socurrent);
  end;
 end
 else begin
  if (origin = socurrent) and (offset = 0) then begin
   result:= fcachedposition;
//   result:= inherited seek(offset,origin);
   if (bufoffset <> nil) and (result >= 0) then begin
    result:= result + (bufoffset-bufend);
   end;
  end
  else begin
   flushbuffer;
   if (origin = socurrent) and (bufoffset <> nil) then begin
    if (offset < fbuffer - bufoffset) or (offset >= bufend-bufoffset) then begin
     result:= inherited seek(offset-(bufend-bufoffset),origin);
     fcachedposition:= result;
     bufoffset:= nil;
    end
    else begin
     bufoffset:= bufoffset + offset;
     result:= inherited seek(0,socurrent);
     fcachedposition:= result;
     if result >= 0 then begin
      result:= result + (bufoffset-bufend);
     end;
    end;
   end
   else begin
    result:= inherited seek(offset,origin);
    fcachedposition:= result;
    bufoffset:= nil;
   end;
   exclude(fstate,tss_eof);
  end;
 end;
end;

procedure tcustombufstream.skip(const adist: integer);
begin
 seek(adist,socurrent);
end;

function tcustombufstream.Read(var Buffer; Count: Longint): Longint;

 procedure fillbuffer;
 begin
  bufend:= fbuffer + readbytes(fbuffer^);
  bufoffset:= fbuffer;
 end;
 
//var
// int1: integer;
label
 endlab;
begin
 flushbuffer;
 if bufoffset = nil then begin
  if count >= buflen then begin
   result:= inherited read(buffer,count);
   if result > 0 then begin
    exclude(fstate,tss_eof);
    if fcachedposition >= 0 then begin
     fcachedposition:= fcachedposition + result;
    end;
   end;
   goto endlab;
  end
  else begin
   fillbuffer;
   if bufend = fbuffer then begin
    result:= 0;
    goto endlab;
   end;
  end;
 end;
 result:= bufend-bufoffset;
 if result > count then begin
  result:= count;
 end;
 move(bufoffset^,buffer,result);
 inc(bufoffset,result);
 if result < count then begin
  bufoffset:= nil;
  if not eof then begin
   result:= result + read((pchar(@buffer)+result)^,count-result);
  end;
 end; 
endlab:
 if result < count then begin
  include(fstate,tss_eof);
 end;
end;

procedure tcustombufstream.clear;
begin
 inherited;
 fstate:= [];
 bufoffset:= nil; 
 bufend:= nil; 
end;

function tcustombufstream.getbufpo: pchar;
var
 int1: integer;
begin
 if (bufoffset = nil) or (bufoffset = bufend) then begin
  int1:= readbytes(fbuffer^);
  if int1 > 0 then begin
   bufend:= fbuffer + int1;
   bufoffset:= fbuffer;
  end;
 end;
 result:= bufoffset;
end;

procedure tcustombufstream.setsize(const newsize: int64);
begin
 flushbuffer;
 if fcachedposition > newsize then begin
  fcachedposition:= newsize;
 end;
 bufoffset:= nil;
 inherited;
end;

{ tbufstream }


{ ttextstream }

constructor ttextstream.create(ahandle: integer);
begin
 eolstyle:= eol_unknown;
 inherited;
end;

function ttextstream.readstrln(var value: string): boolean;
     //true wenn zeile vollstaendig

 procedure fillbuffer;
 begin
  bufend:= fbuffer + readbytes(fbuffer^);
  bufoffset:= fbuffer;
 end;

var
 {int1,}int2,int3: integer;
 gefunden: boolean;
 po1,po2,pe: pchar;

begin
 if (tss_eof in fstate) then begin
  raise EInOutError.Create(sendoffile);
 end;
 flushbuffer;
 gefunden:= false;
 if @value <> nil then begin
  setlength(value,0);
 end;
 if bufoffset = nil then begin  //buffer ungueltig
  fillbuffer;
 end;
 fposvorher:= position{ + (bufend - bufoffset)};
 repeat
  po1:= nil;
  po2:= bufoffset;
  pe:= bufend;
  while po2 < pe do begin
   if po2^ = c_linefeed then begin
    include(feolflags,eolf_linefeed);
    po1:= po2;
    break;
   end;
   if (po2^ = c_return) then begin
    po1:= po2;
    break;
   end;
   inc(po2);
  end;
  if po1 <> nil then begin
   gefunden:= true;
  end
  else begin
   po1:= bufend;
  end;
  if @value <> nil then begin
   int2:= po1-bufoffset;
   if int2 > 0 then begin
    int3:= length(value);
    setlength(value,int3+int2);
    move(bufoffset^,value[int3+1],int2);     //anhaengen
   end;
  end;
  if po1 = bufend then begin    //noch nicht gefunden
   fillbuffer;
  end;
 until gefunden or (bufoffset = bufend);

 if gefunden then begin
  bufoffset:= po1;
 end
 else begin
  bufoffset:= bufend;
 end;

 if bufoffset < bufend then begin
  inc(bufoffset);
  if (bufoffset-1)^ = c_return then begin      //return-linefeed entfernen
   if bufoffset = bufend then begin
    fillbuffer;
   end;
   if bufoffset < bufend then begin
    if bufoffset^ = c_linefeed then begin
     include(feolflags,eolf_returnlinefeed);
     inc(bufoffset);
     if bufoffset = bufend then begin
      fillbuffer;
     end;
    end;
   end;
  end;
 end;

 result:= gefunden;
 updatebit({$ifdef FPC}longword{$else}byte{$endif}(fstate),
                                                ord(tss_eof),not result);
end;

procedure ttextstream.return;
begin
 position:= fposvorher;
end;

procedure ttextstream.writestr(const value: string);
begin
 writebuffer(value[1],length(value));
end;

function ttextstream.encode(const value: msestring): string;
begin
 result:= msestream.encodestring(value,fencoding);
end;

function ttextstream.decode(const value: string): msestring;
begin
 result:= msestream.decodestring(value,fencoding);
end;

procedure ttextstream.write(const value: string);
begin
 if fencoding = ce_locale then begin
  writestr(value);
 end
 else begin
  writestr(encode(msestring(value)));
 end;
end;

procedure ttextstream.write(const value: msestring);
begin
 writestr(encode(value));
end;

procedure ttextstream.write(const value: real);
begin
 write(realtostr(value));
end;

procedure ttextstream.write(const value: integer);
begin
 write(inttostr(value));
end;

procedure ttextstream.write(const value: boolean);
begin
 write(booltostr(value));
end;

procedure ttextstream.write(const values: array of const);
var
 int1: integer;
begin
 for int1:= 0 to high(values) do begin
  with tvarrec(values[int1]) do begin
   case vtype of
    vtInteger: write(VInteger);
//    vtBoolean       : (VBoolean: Boolean);
    vtChar: write(string(VChar));
    vtWideChar: write(msestring(VWideChar));
    vtExtended: write(VExtended^);
    vtString: write(VString^);
//           vtPointer       : (VPointer: Pointer);
    vtPChar: write(string(VPChar));
//           vtObject        : (VObject: TObject);
//           vtClass         : (VClass: TClass);
    vtPWideChar: write(msestring(VPWideChar));
    vtAnsiString: write(string(VAnsiString));
    vtCurrency: write(VCurrency^);
    vtVariant: write(msestring(VVariant^));
//           vtInterface     : (VInterface: Pointer);
    vtWideString: write(msestring(widestring(VWideString)));
//           vtInt64         : (VInt64: PInt64);
    vtUnicodeString: write(msestring(unicodestring(VUnicodeString)));
//           vtQWord         : (VQWord: PQWord);
   end;
  end;
 end;
end;

procedure ttextstream.writeln(const values: array of const);
begin
 write(values);
 write(feol);
end;

procedure ttextstream.writestrln(const value: string);
begin
 write(value+feol);
end;

procedure ttextstream.writeln;
begin
 write(feol);
end;

procedure ttextstream.writeln(const value: string);
begin
 write(value+feol);
end;

procedure ttextstream.writeln(const value: msestring);
begin
 write(value);
 write(feol);
end;

procedure ttextstream.writeln(const value: real);
begin
 writestrln(realtostr(value));
end;

procedure ttextstream.writeln(const value: integer);
begin
 writestrln(inttostr(value));
end;

procedure ttextstream.writeln(const value: boolean);
begin
 writestrln(booltostr(value));
end;

procedure ttextstream.writeln(const value: msestringarty);
var
 int1: integer;
begin
 writeln(length(value));
 for int1:= 0 to high(value) do begin
  writeln(value[int1]);
 end;
end;

procedure ttextstream.writeln(const value: stringarty);
var
 int1: integer;
begin
 writeln(length(value));
 for int1:= 0 to high(value) do begin
  writeln(string(value[int1]));
 end;
end;

function ttextstream.readln: boolean;
var
 str1: string;
begin
 result:= readstrln(str1);
end;

function ttextstream.readln(var value: string): boolean;
begin
 result:= readstrln(value);
 if fencoding <> ce_locale then begin
  value:= ansistring(decode(value));
 end;
end;

function ttextstream.readln(var value: msestring): boolean;
var
 str1: string;
begin
 result:= readstrln(str1);
 value:= decode(str1);
end;

function ttextstream.readln(out value: integer): boolean;
var
 str1: string;
begin
 result:= readstrln(str1);
 value:= strtoint(str1);
end;

function ttextstream.readln(out value: boolean): boolean;
var
 str1: string;
begin
 result:= readstrln(str1);
 value:= strtobool(str1);
end;

function ttextstream.readln(out value: real): boolean;
var
 str1: string;
begin
 result:= readstrln(str1);
 value:= strtoreal(str1);
end;

function ttextstream.readln(out value: msestringarty): boolean;
var
 str1: string;
 mstr1: msestring;
 int1: integer;
begin
 result:= readstrln(str1);
 if result then begin
  int1:= strtoint(str1);
 end
 else begin
  int1:= 0;
 end;
 setlength(value,int1);
 for int1:= 0 to int1-1 do begin
  if not result then begin
   exit;
  end;
  result:= readln(mstr1);
  value[int1]:= mstr1;
 end;
end;

function ttextstream.readln(out value: stringarty): boolean;
var
 str1: string;
 int1: integer;
begin
 result:= readstrln(str1);
 if result then begin
  int1:= strtoint(str1);
 end
 else begin
  int1:= 0;
 end;
 setlength(value,int1);
 for int1:= 0 to int1-1 do begin
  if not result then begin
   exit;
  end;
  result:= readln(str1);
  value[int1]:= str1;
 end;
end;

function ttextstream.readinteger(default: integer; min: integer = minint;
                            max: integer = maxint): integer;
  //liest integer, bringt defaultwert bei fehler
begin
 try
  readln(result);
  if (result < min) then begin
   result:= min;
  end
  else begin
   if result > max then begin
    result:= max;
   end;
  end;
 except
  result:= default;
 end;
end;

function ttextstream.readboolean(default: boolean): boolean;
  //liest boolean, bringt defaultwert bei fehler
begin
 try
  readln(result);
 except
  result:= default;
 end;
end;

function ttextstream.readreal(default: real; min: real = -bigreal;
                            max: real = bigreal): real;
begin
 try
  readln(result);
  if (result < min) then begin
   result:= min;
  end
  else begin
   if result > max then begin
    result:= max;
   end;
  end;
 except
  result:= default;
 end;
end;

function ttextstream.readstring(const default: string): string;
begin
 try
  readln(result);
 except
  result:= default;
 end;
end;

function ttextstream.findnext(const substring: string): boolean;
var
 buffer: string;
 int1,len,posstart,posvorher: integer;
begin
 len:= length(substring);
 result:= false;
 posstart:= position;
 if len > 0 then begin
  setlength(buffer,len);
  while true do begin
   posvorher:= position;
   int1:= read(buffer[1],len);
   if int1 < len then begin
   position:= posstart;
     break;
   end;
   if buffer = substring then begin
    position:= posvorher;
    result:= true;
    break;
   end;
   int1:= pos(substring[1],buffer);
   if int1 > 0 then begin
    position:= posvorher + int1;
   end;
  end;
 end;
end;

function ttextstream.linecount: integer;
var
 po1: ^string;
begin
 result:= 0;
 po1:= nil;
 while readln(string(po1^)) do begin
  inc(result);
 end;
end;

function ttextstream.foundeolstyle: eolstylety;
begin
 result:= eol_unknown;
 if eolf_linefeed in feolflags then begin
  result:= eol_unix;
 end;
 if eolf_returnlinefeed in feolflags then begin
  result:= eol_windows;
 end;
end;

procedure ttextstream.resetsearch;
begin
 fsearchlinestartpos:= 0;
 fsearchlinenumber:= 0;
 fsearchpos:= 0;
 fsearchfoundpos:= 0;
end;

procedure ttextstream.setsearchtext(const Value: string);
begin
 fsearchtext := Value;
 fsearchtextvalid:= false;
end;

function ttextstream.getmsesearchtext: msestring;
begin
 result:= decode(fsearchtext);
end;

procedure ttextstream.setmsesearchtext(const avalue: msestring);
begin
 setsearchtext(encode(avalue));
end;

procedure ttextstream.setsearchoptions(const Value: searchoptionsty);
begin
 fsearchoptions := Value;
 fsearchtextvalid:= false;
end;

procedure ttextstream.seteolstyle(const avalue: eolstylety);
begin
 case avalue of
  eol_unix: begin
   feol:= unixeol;
  end;
  eol_windows: begin
   feol:= windowseol;
  end;
  else begin
   feol:= syseol;
  end;
 end;
end;

function ttextstream.searchnext: boolean;
var
 bo1: boolean;
 ca1: longword;
 str1: string;
begin
 Position:= fsearchpos;
 bo1:= true;
 if (so_caseinsensitive in fsearchoptions) and not fsearchtextvalid then begin
  fsearchtextupper:= ansiuppercase(fsearchtext);
  fsearchtextlower:= ansilowercase(fsearchtext);
  fsearchtextvalid:= true;
 end;
 repeat
  if not bo1 then begin
   fsearchlinestartpos:= position;
   fsearchpos:= fsearchlinestartpos;
   inc(fsearchlinenumber);
  end
  else begin
   bo1:= false;
  end;
//  readln(str1);
  readstrln(str1); //no encoding
  if so_caseinsensitive in fsearchoptions then begin
   ca1:= stringsearch(fsearchtextupper,str1,1,fsearchoptions,fsearchtextlower);
  end
  else begin
   ca1:= stringsearch(fsearchtext,str1,1,fsearchoptions,'');
  end;
 until (ca1 <> 0) or eof or ((fsearchabortpo <> nil) and fsearchabortpo^);
 if ca1 <> 0 then begin
  fsearchfoundpos:= fsearchpos + ca1 - 1;
  result:= true;
 end
 else begin
  result:= false;
  fsearchfoundpos:= Position;
 end;
 fsearchpos:= fsearchfoundpos + longword(length(fsearchtext));
end;

function ttextstream.readstrings: stringarty;
var
 int1: integer;
 str1: string;
begin
 int1:= 0;
 result:= nil;
 while not eof do begin
  if not readln(str1) and (str1 = '') then begin
   break;
  end;
  additem(result,str1,int1);
 end;
 setlength(result,int1);
end;

function ttextstream.readmsestrings: msestringarty;
var
 int1: integer;
 mstr1: msestring;
begin
 int1:= 0;
 result:= nil;
 while not eof do begin
  if not readln(mstr1) and (mstr1 = '') then begin
   break;
  end;
  additem(result,mstr1,int1);
 end;
 setlength(result,int1);
end;

function ttextstream.readmsedatastring: msestring; //returns remainig data 
begin
 result:= decode(readdatastring);
end;

procedure ttextstream.writestrings(const value: stringarty);
var
 int1: integer;
begin
 for int1:= 0 to high(value) do begin
  writeln(string(value[int1]));
 end;
end;

procedure ttextstream.writemsestrings(const value: msestringarty);
var
 int1: integer;
begin
 for int1:= 0 to high(value) do begin
  writeln(value[int1]);
 end;
end;

procedure ttextstream.writetotext(var dest: text);
var
 str1: string;
begin
 while not eof do begin
  readstrln(str1);
  system.writeln(dest,str1);
 end;
end;

class function ttextstream.trycreate(out ainstance: ttextstream;
               const afilename: filenamety;
               const aopenmode: fileopenmodety = fm_read;
               const accessmode: fileaccessmodesty = [];
               const rights: filerightsty = defaultfilerights): syserrorty;
begin
 result:= inherited trycreate(tmsefilestream(ainstance),afilename,aopenmode,
                               accessmode,rights);
end;

{ ttextdatastream }

constructor ttextdatastream.create(ahandle: integer);
begin
 fseparator:= ',';
 fquotechar:= '"';
 inherited;
end;

procedure ttextdatastream.writerecord(const fields: array of const);
begin
 writeln(encoderecord(fields,fforcequote,fquotechar,fseparator));
end;

procedure ttextdatastream.writerecord(const fields: msestringarty);
var
 ar1: varrecarty;
 int1: integer;
begin
 setlength(ar1,length(fields));
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
  {$ifdef mse_hasvtunicodestring}
   vtype:= vtunicodestring;
   vunicodestring:= pointer(fields[int1]);
  {$else}
   vtype:= vtwidestring;
   vwidestring:= pointer(fields[int1]);
  {$endif}
  end;
 end;
 writerecord(ar1);
end;

procedure ttextdatastream.writerecord(const fields: stringarty);
var
 ar1: varrecarty;
 int1: integer;
begin
 setlength(ar1,length(fields));
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   vtype:= vtansistring;
   vansistring:= pointer(fields[int1]);
  end;
 end;
 writerecord(ar1);
end;

procedure ttextdatastream.writerecord(const fields: integerarty);
var
 ar1: varrecarty;
 int1: integer;
begin
 setlength(ar1,length(fields));
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   vtype:= vtinteger;
   vinteger:= fields[int1];
  end;
 end;
 writerecord(ar1);
end;

procedure ttextdatastream.writerecord(const fields: realarty);
var
 ar1: varrecarty;
 ar2: array of extended;
 int1: integer;
// ext1: extended;
begin
 setlength(ar1,length(fields));
 setlength(ar2,length(fields));
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   ar2[int1]:= fields[int1];
   vtype:= vtextended;
   vextended:= @ar2[int1];
  end;
 end;
 writerecord(ar1);
end;

procedure ttextdatastream.writerecord(const fields: int64arty);
var
 ar1: varrecarty;
 int1: integer;
begin
 setlength(ar1,length(fields));
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   vtype:= vtint64;
   vint64:= @fields[int1];
  end;
 end;
 writerecord(ar1);
end;

procedure ttextdatastream.writerecord(const fields: booleanarty);
var
 ar1: varrecarty;
 int1: integer;
begin
 setlength(ar1,length(fields));
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   vtype:= vtboolean;
   vboolean:= fields[int1];
  end;
 end;
 writerecord(ar1);
end;

function ttextdatastream.readcsvstring(out value: msestring): boolean;
var
 mstr2: msestring;
begin
 result:= readln(value);
 if odd(countchars(value,fquotechar)) then begin
  while not eof do begin
   result:= readln(mstr2);
   value:= value+lineend+mstr2;
   if odd(countchars(mstr2,fquotechar)) then begin
    break;
   end;
  end;
 end;
end;

function ttextdatastream.readrecord(fields: array of pointer; types: string): boolean;
                // b -> boolean
                // i -> integer
                // I -> int64
                // s -> ansistring
                // S -> msestring
                // r -> real
var
 mstr1: msestring;
begin
 result:= false;
 if not (not readcsvstring(mstr1) and (mstr1 = '') and eof) then begin
                //check terminating linefeed
  result:= decoderecord(mstr1,fields,types,fquotechar,fseparator);
 end;
end;

function ttextdatastream.readcsvvalues(out values: msestringarty): boolean;
var
 mstr1: msestring;
begin
 result:= readcsvstring(mstr1);
 splitstringquoted(mstr1,values,fquotechar,fseparator);
end;

{ tcryptfilestream }

constructor tcryptfilestream.Create(const aFileName: string; Mode: Word);
const
 schluessel = $51b2;
var
 wo1: word;
 int1: integer;
begin
 inherited;
 if mode = fmcreate then begin
  int1:= integer(kryptsignatur);
  writebuffer(int1,4);
  randomize;
  repeat
   wo1:= random($ffff);
  until wo1 <> 0;
  seed:= wo1;
  wo1:= wo1 xor schluessel;
  writebuffer(wo1,2);
 end
 else begin
  readbuffer(int1,4);
  if int1 <> integer(kryptsignatur) then begin
   raise exception.create(afilename + ' falsches Dateiformat!');
  end;
  readbuffer(seed,2);
  seed:= seed xor schluessel;
 end;
 schluesseln:= true;
end;

function tcryptfilestream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
 result:= 0; //compiler warning
 raise exception.create('seek nicht erlaubt!');
end;

procedure tcryptfilestream.krypt16(var buffer; count: integer);
const
 crcpolynom = $a001;
var
 int1,int2: integer;
 bo1: boolean;
 bytepo: ^byte;
begin
 bytepo:= @buffer;
 for int2:= count-1 downto 0 do begin
  for int1:= 0 to 7 do begin
   bo1:= odd(seed);
   seed:= seed shr 1;
   if bo1 then begin
    seed:= seed xor crcpolynom;
   end;
  end;
  bytepo^:= bytepo^ xor seed;
  inc(bytepo);
 end;
end;

function tcryptfilestream.Read(var Buffer; Count: Integer): Longint;
begin
 result:= inherited read(buffer,count);
 if schluesseln then begin
  krypt16(buffer,result);
 end;
end;

function tcryptfilestream.Write(const Buffer; Count: Integer): Longint;
var
 po: pointer;
begin
 if schluesseln then begin
  po:= @byte(buffer);
  krypt16(po^,count);
 end;
 result:= inherited write(buffer,count);
end;

{ tstringcopystream }

constructor tstringcopystream.create(const adata: string);
begin
 fdata:= adata;
 inherited create({fm_create});
 if adata <> '' then begin
  setpointer(pointer(adata),length(adata));
 end;
end;

destructor tstringcopystream.destroy;
begin
 setpointer(nil,0);
 inherited;
end;

function tstringcopystream.write(const Buffer; Count: Longint): Longint;
begin
 result:= 0;
end;

function tstringcopystream.readdatastring: string;
begin
 if position = 0 then begin
  result:= fdata;
 end
 else begin
  result:= inherited readdatastring;
 end;
end;

function tstringcopystream.getmemory: pointer;
begin
 result:= pointer(fdata);
end;

{ ttextstringcopystream }

constructor ttextstringcopystream.create(const adata: string);
begin
 fdata:= adata;
 inherited create(fm_read);
 if adata <> '' then begin
  tmemorystream1(fmemorystream).setpointer(pointer(adata),length(adata));
 end;
end;

destructor ttextstringcopystream.destroy;
begin
 tmemorystream1(fmemorystream).setpointer(nil,0);
 inherited;
end;

function ttextstringcopystream.write(const Buffer; Count: Longint): Longint;
begin
 result:= 0;
end;

function ttextstringcopystream.getmemory: pointer;
begin
 result:= pointer(fdata);
end;

{ tmemorycopystream }

constructor tmemorycopystream.create(const adata: pointer; const asize: integer);
begin
 inherited create;
 setpointer(adata,asize);
end;

destructor tmemorycopystream.destroy;
begin
 setpointer(nil,0);
 inherited;
end;

function tmemorycopystream.write(const Buffer; Count: Longint): Longint;
begin
 result:= 0;
end;

{ tcustomcryptohandler }

destructor tcustomcryptohandler.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fclients) do begin
  chain:= nil;
  with fclients[int1] do begin
   if (stream <> nil) then begin
    if link = nil then begin
     with stream do begin
      fcryptohandler:= nil;
      fendhandler:= nil;
//      fcryptoindex:= -1;
     end;
    end
    else begin
     link.fchain:= nil;
    end;
    finalizeclient(fclients[int1]);
//    stream:= nil;
   end;
  end;
 end;
 inherited;
end;

procedure tcustomcryptohandler.finalizeclient(var aclient: cryptoclientinfoty);
begin
 with aclient do begin
  stream:= nil;
 end;
end;

procedure tcustomcryptohandler.connect(const aclient: tmsefilestream;
                const alink: tcustomcryptohandler;
                const aindex: integer;
                out endhandler: tcustomcryptohandler; out endindex: integer);
var
 int1,int2,int3: integer;
// ha1: tcustomcryptohandler;
begin
 int3:= high(fclients);
 int2:= int3+1;
 for int1:= 0 to int3 do begin
  if fclients[int1].stream = nil then begin
   int2:= int1;
   break;
  end;
 end;
 if int2 > int3 then begin
  setlength(fclients,int2+1);
 end;
 endindex:= int2;
 endhandler:= self;
 fillchar(fclients[int2],sizeof(fclients[0]),0);
 with fclients[int2] do begin
  stream:= aclient;
  link:= alink;
  linkindex:= aindex;
//  state:= [];
 end;
 if fchain <> nil then begin
  fchain.connect(aclient,self,int2,endhandler,endindex);
 end;
end;

procedure tcustomcryptohandler.disconnect({const aclient: tmsefilestream;
               const alink: tcustomcryptohandler;} const aindex: integer);
var
 po1: pcryptoclientinfoty;
// int1: integer;
begin
 po1:= @fclients[aindex];
 with po1^ do begin
  if ccs_open in state then begin
   close(po1^);
  end;
  if link <> nil then begin
   link.disconnect(linkindex);
  end;
  finalizeclient(po1^);
 end;
(*
 if alink = nil then begin
  po1:= @fclients[aclient.fcryptoindex];
  with po1^ do begin
   if ccs_open in state then begin
    close(po1^);
   end;
   stream:= nil;
  end;
  fendhandler:= nil;
//  aclient.fcryptoindex:= -1;
 end
 else begin
  for int1:= 0 to high(fclients) do begin
   with fclients[int1] do begin
    if stream = aclient then begin
     finalizeclient(fclients[int1]);
//     stream:= nil;
    end;
   end;
  end;
  if fchain <> nil then begin
   fchain.disconnect(aclient,self);
  end;
 end;
 *)
end;

function tcustomcryptohandler.read(var aclient: cryptoclientinfoty; var buffer;
               count: longint): longint;
begin
 with aclient do begin
  if link = nil then begin
   result:= stream.inheritedread(buffer,count);
  end
  else begin
   result:= link.read(link.fclients[linkindex],buffer,count);
  end;
 end;
end;

function tcustomcryptohandler.write(var aclient: cryptoclientinfoty;
               const buffer; count: longint): longint;
begin
 with aclient do begin
  if link = nil then begin
   result:= stream.inheritedwrite(buffer,count);
  end
  else begin
   result:= link.write(link.fclients[linkindex],buffer,count);
  end;
 end;
end;

function tcustomcryptohandler.seek(var aclient: cryptoclientinfoty;
                          const offset: int64; origin: tseekorigin): int64;
begin
 with aclient do begin
  if link = nil then begin
   result:= stream.inheritedseek(offset,origin);
  end
  else begin
   result:= link.seek(link.fclients[linkindex],offset,origin);
  end;
 end;
end;

function tcustomcryptohandler.getsize(var aclient: cryptoclientinfoty): int64;
begin
 with aclient do begin
  if link = nil then begin
   result:= stream.inheritedgetsize;
  end
  else begin
   result:= link.getsize(link.fclients[linkindex]);
  end;
 end;
end;

procedure tcustomcryptohandler.open(var aclient: cryptoclientinfoty);
begin
 with aclient do begin
  include(state,ccs_open);
  if link <> nil then begin
   link.open(link.fclients[linkindex]);
  end;
 end;
end;

procedure tcustomcryptohandler.close(var aclient: cryptoclientinfoty);
begin
 with aclient do begin
  exclude(state,ccs_open);
  if link <> nil then begin
   link.close(link.fclients[linkindex]);
  end;
 end;
end;

function tcustomcryptohandler.checkopen(
                      const aindex: integer): pcryptoclientinfoty;
begin
 result:= @fclients[aindex];
 with result^ do begin
  if not (ccs_open in state) then begin
   self.open(result^);
  end;
 end;
end;

function tcustomcryptohandler.encrypt(const adata: pointer;
               adatalength: integer; const base64: boolean = false;
               const maxlinelength: integer = defaultbase64linelength): string;
var
 stream1: tmsefilestream;
// str1: string;
begin
 stream1:= tmsefilestream.create(fm_write);
 try
  stream1.cryptohandler:= self;
  stream1.write(adata^,adatalength);
  stream1.cryptohandler:= nil; //flush
  with stream1.fmemorystream do begin
   if base64 then begin
    result:= encodebase64(memory,size,maxlinelength);
   end
   else begin
    setlength(result,size);
    move(memory^,pointer(result)^,length(result));
   end;
  end;
 finally
  stream1.free;
 end;
end;

function tcustomcryptohandler.decrypt(const adata: string;
                           const base64: boolean = false): string;
var
 stream1: ttextstringcopystream;
 int1: integer;
begin
 if base64 then begin
  stream1:= ttextstringcopystream.create(decodebase64(adata));
 end
 else begin
  stream1:= ttextstringcopystream.create(adata);
 end;
 try
  stream1.cryptohandler:= self;
  setlength(result,length(adata));
  int1:= stream1.read(pointer(result)^,length(result));
  setlength(result,int1);
 finally
  stream1.free;
 end;
end;

function tcustomcryptohandler.encrypt(const adata: string;
                      const base64: boolean = false;
             const maxlinelength: integer = defaultbase64linelength): string;
begin
 result:= encrypt(pointer(adata),length(adata),base64,maxlinelength);
end;

function tcustomcryptohandler.encrypttext(const atext: msestring;
                               const base64: boolean = false;
              const maxlinelength: integer = defaultbase64linelength): string;
begin
 result:= encrypt(stringtoutf8ansi(atext),base64,maxlinelength);
end;

function tcustomcryptohandler.decrypttext(const adata: string;
                               const base64: boolean = false): msestring;
begin
 result:= utf8tostringansi(decrypt(adata,base64));
end;

procedure tcustomcryptohandler.setchain(const avalue: tcustomcryptohandler);

 procedure removechain(const ha: tcustomcryptohandler;
                                          const stre: tmsefilestream);
 var
  int1: integer;
 begin
  if ha <> nil then begin
   with ha do begin
    for int1:= 0 to high(fclients) do begin
     with fclients[int1] do begin
      if stream = stre then begin
       stream:= nil;
      end;
     end;
    end;
    removechain(ha.chain,stre);
   end;
  end;
 end;
 
var
 ha1: tcustomcryptohandler;
 int1: integer;
begin
 ha1:= avalue;
 while ha1 <> nil do begin
  if ha1 = self then begin
   componentexception(self,'Recursive handler chain.');
  end;
  ha1:= ha1.chain;
 end;
 if fchain <> nil then begin
  with fchain do begin
   for int1:= 0 to high(fclients) do begin
    with fclients[int1] do begin
     if (stream <> nil) and (link = self) then begin
      removechain(fchain,stream);
      stream:= nil;
     end;
    end;
   end;
  end;
 end;
 setlinkedvar(avalue,tmsecomponent(fchain));
end;

function tcustomcryptohandler.getclient(
                    const astream: tmsefilestream): pcryptoclientinfoty;
var
 ha1: tcustomcryptohandler;
 int1: integer;
begin
 result:= nil;
 ha1:= astream.fendhandler;
 int1:= astream.fendindex;
 while ha1 <> nil do begin
  if ha1 = self then begin
   result:= @fclients[int1];
   break;
  end;
  with ha1.fclients[int1] do begin
   ha1:= link;
   int1:= linkindex;
  end;
 end;
 if result = nil then begin
  componentexception(self,'Client stream not found.');
 end;
end;

procedure tcustomcryptohandler.writeerror(var aclient: cryptoclientinfoty);
begin
 raise ewriteerror.create(swriteerror);
end;

procedure tcustomcryptohandler.readerror(var aclient: cryptoclientinfoty);
begin
 raise ereaderror.create(sreaderror);
end;

procedure tcustomcryptohandler.flush(var aclient: cryptoclientinfoty);
begin
 //dummy
end;

procedure tcustomcryptohandler.flushchain(var aclient: cryptoclientinfoty);
begin
 if ccs_open in aclient.state then begin
  flush(aclient);
  with aclient do begin
   if link <> nil then begin
    link.flush(link.fclients[linkindex]);
   end;
  end;
 end;
end;

procedure tcustomcryptohandler.flush(const astream: tmsefilestream);
var
 po1: pcryptoclientinfoty;
begin
 po1:= getclient(astream);
 if ccs_open in po1^.state then begin
  flush(po1^);
 end;
end;

{ tstringbufferstream }

constructor tstringbufferstream.create(const adata: string);
begin
 inherited create();
 fdata:= adata;
 setpointer(pointer(fdata),length(fdata));
end;

function tstringbufferstream.getdata: string;
begin
 capacity:= size;
 result:= fdata;
end;

function tstringbufferstream.realloc(var newcapacity: ptrint): pointer;
begin
 if newcapacity > length(fdata) then begin
  newcapacity:= 2*newcapacity + 256;
 end;
 setlength(fdata,newcapacity);
 result:= pointer(fdata);
end;

{ ttextstringbufferstream }

constructor ttextstringbufferstream.create(const adata: string;
                               const aopenmode: fileopenmodety = fm_create);
begin
 fmemorystream:= tstringbufferstream.create(adata);
 inherited create(aopenmode);
end;

function ttextstringbufferstream.getdata: string;
begin
 result:= tstringbufferstream(fmemorystream).data;
end;

end.
