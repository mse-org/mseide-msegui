{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecommport;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses {$ifdef mswindows} windows,{$ifndef FPC} mmsystem,{$endif}
     {$else} mselibc,
     {$endif}
     classes,mclasses,msethread,mseguiglob,msecommtimer,mseevent,mseclasses,
     msesystypes,msestrings,msestat,msestatfile,msetypes,mseglob;

type
 commstatety = (
    coms_none,                //0
    coms_ok,                  //1
    coms_working,             //2
    coms_notopen,             //3
    coms_abort,               //4
    coms_timeout,             //5
    coms_exception,           //6
    coms_error,               //7
    coms_bufferoverflow,      //8
    coms_canceled,            //9
    coms_unknown,             //10
    coms_command,             //11
    coms_parameter,           //12
    coms_busy                 //13
            );

 errorrecty = record
  error: integer;
  text: msestring;
 end;
 perrorrecty = ^errorrecty;

const
 defaulteorchar = c_linefeed;

 cpf_none =                0;
 cpf_ok =                  1;
 cpf_working =             2;
 cpf_notopen =             3;
 cpf_abort =               4;
 cpf_timeout =             5;
 cpf_exception =           6;
 cpf_error =               7;
 cpf_bufferoverflow =      8;
 cpf_canceled =            9;
 
 cpf_unknown =            10;     //asciiprot errors
 cpf_command =            11;
 cpf_parameter =          12;
 cpf_busy =               13;
 cpf_user =              100;

 errortexte: array[commstatety] of errorrecty =
  (
   (error: cpf_none; text: ''),
   (error: cpf_ok; text: 'OK'),
   (error: cpf_working; text: 'busy'),
   (error: cpf_notopen; text: 'not open'),
   (error: cpf_abort; text: 'abort'),
   (error: cpf_timeout; text: 'timeout'),
   (error: cpf_exception; text: 'exception'),
   (error: cpf_error; text: 'error'),
   (error: cpf_bufferoverflow; text: 'bufferoverflow'),
   (error: cpf_canceled; text: 'canceled'),
   (error: cpf_unknown; text: 'unknown'),
   (error: cpf_command; text: 'command error'),
   (error: cpf_parameter; text: 'paramter error'),
   (error: cpf_busy; text: 'busy')
  );

 commerrors = ' 1    ok' + c_linefeed +
              ' 2    working' + c_linefeed +
              ' 3    port not open' + c_linefeed +
              ' 4    abort' + c_linefeed +
              ' 5    timeout' + c_linefeed +
              ' 6    exception' + c_linefeed +
              ' 7    error' + c_linefeed +
              ' 8    bufferoverflow' + c_linefeed +
              ' 9    canceled';

type
 commnrty = (cnr_invalid=-1,
                cnr_1,cnr_2,cnr_3,cnr_4,cnr_5,cnr_6,cnr_7,cnr_8,cnr_9);
 commbaudratety = (cbr_50,cbr_75,cbr_110,cbr_134,cbr_150,cbr_200,cbr_300,cbr_600,
                   cbr_1200,cbr_1800,cbr_2400,cbr_4800,cbr_9600,cbr_19200,
                   cbr_38400,cbr_57600,cbr_115200);
 commdatabitsty = (cdb_5,cdb_6,cdb_7,cdb_8);
 commstopbitty = (csb_1,csb_2);
 commparityty = (cpa_none,cpa_odd,cpa_even);

const
 {$ifdef UNIX}

 commname: array[commnrty] of string = ('','ttyS0','ttyS1','ttyS3','ttyS4','ttyS5',
                                        'ttyS6','ttyS7','ttyS8','ttyS9');
 {
 commname: array[commnrty] of string = ('ttys0','ttys1','ttys3','ttys4','ttys5',
                                        'ttys6','ttys7','ttys8','ttys9');
 }
 invalidfilehandle = ptruint(-1);
 infinitemse = cardinal(-1);
 B57600 =   $1001; //0010001
 B115200 =  $1002; //0010002
 commbaudflags: array[commbaudratety] of integer =
                     (B50,B75,B110,B134,B150,B200,B300,B600,
                      B1200,B1800,B2400,B4800,B9600,B19200,
                      B38400,B57600,B115200);
 commdatabitflags: array[commdatabitsty] of integer = (cs5,cs6,cs7,cs8);
 {$else}
 commname: array[commnrty] of string = ('','COM1','COM2','COM3','COM4','COM5',
                                        'COM6','COM7','COM8','COM9');  
 invalidfilehandle = INVALID_HANDLE_VALUE;
 infinitemse = INFINITE;
 {$endif}
 commbittime: array[commbaudratety] of real = 
          (1/50,1/75,1/110,1/134,1/150,1/200,1/300,1/600,
           1/1200,1/1800,1/2400,1/4800,1/9600,1/19200,
           1/38400,1/57600,1/115200);
 commbaudrates: array[commbaudratety] of integer = (
           50,75,110,134,150,200,300,600,  
           1200,1800,2400,4800,9600,19200,
           38400,57600,115200);

type

 tcustomrs232 = class(tpersistent)
  private
   fowner: tmsecomponent; //can be nil
   fhandle: ptruint;
   fcommnr: commnrty;
   frtstimevor: integer;  //in us fuer halbduplex
   frtstimenach: integer;
   fhalfduplex: boolean;
   fbaud: commbaudratety;
   fstopbit: commstopbitty;
   faparity: commparityty;
   fbyteus: integer;
   foncheckabort: checkeventty;
   {$ifdef mswindows}
   overlappedrx: toverlapped;
   overlappedtx: toverlapped;
   timer: tmmtimermse;
   commtimeouts: tcommtimeouts;
   {$endif}
   fdatabits: commdatabitsty;
   fcommname: filenamety;
   procedure updatebyteinfo;
   procedure Setbaud(const Value: commbaudratety);
   procedure Setcommnr(const Value: commnrty);
   procedure Setparity(const Value: commparityty);
   procedure Setstopbit(const Value: commstopbitty);
   function waitfortx(timeout: integer): boolean;    //timeout in us
   function defaulttimeout(us: longword; anzahl: integer; out timeout: longword): boolean;
             // timeout in us 0 -> 2*uebertragungszeit,
             // infinitemse -> kein timeout
   {$ifdef mswindows}
   procedure eotevent(sender: tobject);
   function setreadnonblocked(const anonblocked: boolean): boolean;
   {$endif}
   procedure setdatabits(const avalue: commdatabitsty);
   procedure setactive(const avalue: boolean);
   procedure setcommname(const avalue: filenamety);
  protected
   fvmin: char;
   fnoclosehandle: boolean;
   fonopen: proceventty;
   fonclose: proceventty;
   function canevent(const aevent: tmethod): boolean;
   function piperead(var buf; const acount: integer; out readcount: integer;
                    const nonblocked: boolean): boolean;
   function pipewrite(const buffer; count: longint): longint;
  public
   constructor create(const aowner: tmsecomponent;  //aowner can be nil
                      const aoncheckabort: checkeventty = nil);
   destructor destroy; override;
   function open: boolean;
   procedure close;
   function opened: boolean;
   procedure reset;
   procedure resetinput;
   procedure resetoutput;
   procedure setrts(active: boolean);
   procedure setdtr(active: boolean);
   function writestring(const dat: string; timeout: longword = 0;
                waitforeot: boolean = false): boolean;
  //timeout in us, wenn = 0 -> warten auf uebertragungsende, bei halbduplex sowiso
   function readbuffer(anzahl: integer; out dat;
                       timeout: longword = 0): integer;
            //list daten, true wenn gelungen, timeout in us 0 -> 2*uebertragungszeit
   function readstring(anzahl: integer; out dat: string;
                       timeout: longword = infinitemse): boolean;
            //list daten, true wenn gelungen, timeout in us 0 -> 2*uebertragungszeit
   function readavailbuffer(const maxcount: integer; out dat): integer;
   function readavailstring(const maxcount: integer): string;

   function transmissiontime(const acount: integer): longword; //bringt uebertragungszeit in us
   property active: boolean read opened write setactive;
   property handle: ptruint read fhandle;
   property commnr: commnrty read Fcommnr write Setcommnr default cnr_1;
   property commname: filenamety read fcommname write setcommname;
                         //overrides commnr
   property baud: commbaudratety read Fbaud write Setbaud default cbr_9600;
   property databits: commdatabitsty read fdatabits write setdatabits default cdb_8;
   property stopbit: commstopbitty read Fstopbit write Setstopbit default csb_1;
   property parity: commparityty read Faparity write Setparity default cpa_none;
   property halfduplex: boolean read fhalfduplex write fhalfduplex default false;
   property oncheckabort: checkeventty read foncheckabort;
   property rtstimevor: integer read frtstimevor write frtstimevor; //in us
   property rtstimenach: integer read frtstimenach write frtstimenach; //in us
   property byteus: integer read fbyteus;
 end;

 trs232 = class(tcustomrs232)
 end;
 
 tcommevent = class;
 commeventty = procedure(const sender: tcommevent) of object;
 tcommthread = class;

 tcommevent = class(tmseevent)
  private
   fstate: commstatety;
   fpersistent: boolean;
   fsem: semty;
  protected
   procedure process(const thread: tcommthread; var ok: boolean); virtual;
   procedure processed(const thread: tcommthread; var ok: boolean); virtual;
  public
   onerror: commeventty;   //synchronized with maineventloop
   onsuccess: commeventty; //synchronized with maineventloop
   timeout: integer; //us
   constructor create(persistent: boolean; atimeout: integer = 200000); virtual;
   destructor destroy; override;
   function state: commstatety;
   function waitfordata: boolean; //true if no error
 end;

 tcommthread = class(teventthread)
  private
  protected
   fowner: tmsecomponent;
   fport: trs232;
   fabort: boolean;
   fsendretries: integer;
   function checkabort(const sender: tobject): boolean; virtual;
   function execute(thread: tmsethread): integer; override;
  public
   constructor create(const aowner: tmsecomponent); //owner can be nil
   destructor destroy; override;
   function writestring(const dat: string; timeout: integer = 0): boolean;
  //timeout in us, wenn = 0 -> warten auf uebertragungsende, bei halbduplex sowiso
   function readstring(anzahl: integer; out dat: string;
                                         timeout: integer = 0): boolean;
   //list daten, true wenn gelungen, timeout in us, 0 -> doppelte uebertragungszeit
   procedure abort;  //alle laufende auftraege werden mit timeout abgebrochen
      //ruecksetzung bei leerer messagequeue, bei aufruf aus fremdem thread,
      // rueckkehr nach ruecksetzung
   procedure postevent(event: tcommevent);
   procedure reset; virtual;
   property port: trs232 read fport;
   property sendretries: integer read fsendretries write fsendretries default 0;
 end;

 tcommport = class(tmsecomponent,istatfile)
  private
   Fonconnectedchange: booleanchangedeventty;
   flastresult: integer;
   Fonportchange: notifyeventty;
   fopened: boolean;
   factive: boolean;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fstatpriority: integer;
   function getport: commnrty;
   procedure setport(const Value: commnrty);
   function getopened: boolean;
   function getbusy: boolean;
   function getbaudrate: commbaudratety;
   function getparity: commparityty;
   function getstopbit: commstopbitty;
   procedure Setbaudrate(const Value: commbaudratety);
   procedure Setparity(const Value: commparityty);
   procedure Setstopbit(const Value: commstopbitty);
   function gethalfduplex: boolean;
   procedure sethalfduplex(const Value: boolean);
   function getsendretries: integer;
   procedure setsendretries(const Value: integer);
   function getrtstimenach: integer;
   function getrtstimevor: integer;
   procedure setrtstimenach(const Value: integer);
   procedure setrtstimevor(const Value: integer);
   procedure setactive(const Value: boolean);
   procedure setstatfile(const Value: tstatfile);
//   function waitfordata(const event: tcomevent): comstatety;
//   function getpriority: tthreadprioritymse;
//   procedure setpriority(const Value: tthreadprioritymse);
   function getdatabits: commdatabitsty;
   procedure setdatabits(const avalue: commdatabitsty);
   function getportname: filenamety;
   procedure setportname(const avalue: filenamety);
  protected
   ftimeout: integer;
   fthread: tcommthread;
   procedure portchanged; virtual;
//   function createdatascanner(slavenr,adresse,anzahl,zykluszeit: integer;
//                   empfaengerproc: empfaengerprocty): tdatascanner; virtual;
//   function waitresult(const data: portdataty): boolean;
   function postandwait(const event: tcommevent): boolean; //true if ok
   procedure postevent(const event: tcommevent);
   procedure loaded; override;
   function extracterrortext(error: integer; errors: array of errorrecty;
             var text: msestring): boolean; //true if found
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
   procedure doafteropen; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function openport(raiseexception: boolean = false): boolean;
                                           // true wenn gelungen
   procedure closeport;
   procedure abort;
      //bricht laufende auftraege mit timeout ab, wird automatisch rueckgesetzt
   function geterrortext(error: integer): msestring;  virtual;
   function getlastresulttext: msestring;
   property thread: tcommthread read fthread;
   property opened: boolean read getopened;
   property busy: boolean read getbusy;
   property halfduplex: boolean read gethalfduplex write sethalfduplex default false;

   property objectlinker: tobjectlinker read getobjectlinker
                {$ifdef msehasimplements}implements istatfile{$endif};
  published
   property onportchange: notifyeventty read Fonportchange
        write fonportchange;
   property onconnectchanged: booleanchangedeventty read Fonconnectedchange
        write fonconnectedchange;
   property sendretries: integer read getsendretries write setsendretries default 0;
   property port: commnrty read getport write setport default cnr_1;
   property portname: filenamety read getportname write setportname;
                        //overrides port
   property baudrate: commbaudratety read getbaudrate write Setbaudrate default cbr_9600;
   property stopbit: commstopbitty read getstopbit write Setstopbit default csb_1;
   property parity: commparityty read getparity write Setparity default cpa_none;
   property databits: commdatabitsty read getdatabits write setdatabits default cdb_8;
   property rtstimevor: integer read getrtstimevor write setrtstimevor default 0;
   property rtstimenach: integer read getrtstimenach write setrtstimenach default 0;
   property timeout: integer read ftimeout write ftimeout default 200000;
//   property priority: tthreadprioritymse read getpriority write setpriority default tpnormal;
   property active: boolean read factive write setactive default false;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority 
                                       write fstatpriority default 0;
 end;

 tasciicommevent = class(tcommevent)
  protected
   procedure process(const thread: tcommthread; var ok: boolean); override;
  public
   commandstring: string;
   resultstring: string;
   resultcode: integer; //cpf_...
 end;

 asciicommeventclassty = class of tasciicommevent;
 
 tasciicommthread = class(tcommthread)
  private
   puffer: string;
   zeitstempel: longword; //in us
   timeoutstarted: boolean;
   feorchar: char;
   procedure starttimeout(step: longword);
   procedure closetimeout;
  protected
   function checkabort(const sender: tobject): boolean; override;
  public
   constructor create(const aowner: tmsecomponent);
   procedure reset; override;       //setzt commport zurueck
   function readln(timeout: integer; out dat: string): integer;
                       //cpf_io wenn gelungen
   function sendstring(const data: string; out antwort: string;
      timeout: integer): integer; overload;
   function sendstring(const data: string): integer; overload;
                              //no answer reading
   property eorchar: char read feorchar write feorchar default defaulteorchar;
 end;

 tasciicommport = class(tcommport)
  private
   function geteorchar: char;
   procedure seteorchar(const avalue: char);
   function getthread: tasciicommthread;
  protected
   function geteventclass: asciicommeventclassty; virtual;
  public
   constructor create(aowner: tcomponent); override;
   function send(const commandstring: string; out answer: string;
            atimeout: integer = 0): integer; overload;
   function send(const commandstrings: array of string): integer; overload;
                            //reads no answer
   property thread: tasciicommthread read getthread;
  published
   property halfduplex;
   property eorchar: char read geteorchar write seteorchar default defaulteorchar;
 end;

 asciiproterrorty = (ape_unknown,ape_command,ape_parameter,ape_busy);
 
const
 errorchar = '*';
 errorcodes: array[asciiproterrorty] of integer = 
  (cpf_unknown,cpf_command,cpf_parameter,cpf_busy);
  
type
 tasciiprotevent = class(tasciicommevent)
  private
  protected
   procedure processed(const thread: tcommthread; var ok: boolean); override;
  public
   constructor create(persistent: boolean; atimeout: integer = 200000); override;
 end;

 tasciiprotport = class(tasciicommport)
  protected
   function geteventclass: asciicommeventclassty; override;
  public
   function send(const commandstring: string; out answer: string;
            atimeout: integer = 0; aadress: integer = -1): integer;
                                     //-1: no address
 end; 
 
function checkcommport(commnr: commnrty): boolean;  //true wenn comport zur verfuegung
function crc16(const data; len: integer): word;
function bintoascii(const bytes: string): string; overload;
         // $0..$f->'A'..'P', lsb first
function bintoascii(const bytes: pchar; const len: integer): string; overload;
function asciitobin(const chars: string): string;

implementation
uses
// {$ifdef UNIX} {kernelioctl,}msesysbindings, {$endif}
 sysutils,mseapplication,msesysintf1,msesysintf,msesys,msesysutils,
 msepipestream,msefileutils,mseformatstr;

const
 asciipufferlaenge = 255;

 t_nichtoffen = 'not open';
 databitcounts: array[commdatabitsty] of integer = (5,6,7,8);

 {$ifdef mswindows}
const           // fuer tdcb.flags
    fBinary =           $0001;  // binary mode, no EOF check
    fParity =           $0002;  // enable parity checking
    fOutxCtsFlow =      $0004;  // CTS output flow control
    fOutxDsrFlow =      $0008;  // DSR output flow control
    fDtrControldisable = $0000; // DTR flow control type
    fDtrControlenable = $0010;
    fDsrSensitivity =   $0040;  // DSR sensitivity
    TXContinueOnXoff =  $0080;  // XOFF continues Tx

    fOutX =             $0100;  // XON/XOFF out flow control
    fInX =              $0200;  // XON/XOFF in flow control
    fErrorChar =        $0400;  // enable error replacement
    fNull =             $0800;  // enable null stripping
    fRtsControldisable = $0000; // RTS flow control
    fRtsControlenable = $1000;
    fRtsControlhandshake = $2000;
    fRtsControltoggle = $3000;
    fAbortOnError =     $4000;  // abort reads/writes on error
//    DWORD fDummy2:17;         // reserved
{
 defaultdcb: tdcb = (
    DCBlength: sizeof(tdcb);
    BaudRate: 9600;
    Flags: fbinary+fdtrcontrolenable+frtscontrolenable;
    wReserved: 0;
    XonLim: 256;
    XoffLim: 128;
    ByteSize: 8;
    Parity: NOPARITY;
    StopBits: ONESTOPBIT;
    XonChar: #17;
    XoffChar: #19;
    ErrorChar: #0;
    EofChar: #0;
    EvtChar: #0;
    wReserved1: 0;
 );
 }
 {$endif}

{/* Table of CRC values for high-order byte */}
const                              //crcpolynom = $a001;
 auchCRCHi: array[0..255] of byte = (
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0,
$80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0,
$80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
$00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1,
$81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1,
$81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0,
$80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40,
$01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, 
$81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, 
$80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40,
$01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0,
$80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, 
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, 
$80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, 
$00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, 
$80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, 
$01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, 
$80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40,
$01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, 
$81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0,
$80, $41, $00, $C1, $81, $40
) ;
 auchCRCLo: array[0..255] of byte = (
$00, $C0, $C1, $01, $C3, $03, $02, $C2, $C6, $06,
$07, $C7, $05, $C5, $C4, $04, $CC, $0C, $0D, $CD, 
$0F, $CF, $CE, $0E, $0A, $CA, $CB, $0B, $C9, $09, 
$08, $C8, $D8, $18, $19, $D9, $1B, $DB, $DA, $1A,
$1E, $DE, $DF, $1F, $DD, $1D, $1C, $DC, $14, $D4,
$D5, $15, $D7, $17, $16, $D6, $D2, $12, $13, $D3,
$11, $D1, $D0, $10, $F0, $30, $31, $F1, $33, $F3, 
$F2, $32, $36, $F6, $F7, $37, $F5, $35, $34, $F4, 
$3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE, $FA, $3A,
$3B, $FB, $39, $F9, $F8, $38, $28, $E8, $E9, $29,
$EB, $2B, $2A, $EA, $EE, $2E, $2F, $EF, $2D, $ED,
$EC, $2C, $E4, $24, $25, $E5, $27, $E7, $E6, $26,
$22, $E2, $E3, $23, $E1, $21, $20, $E0, $A0, $60,
$61, $A1, $63, $A3, $A2, $62, $66, $A6, $A7, $67,
$A5, $65, $64, $A4, $6C, $AC, $AD, $6D, $AF, $6F,
$6E, $AE, $AA, $6A, $6B, $AB, $69, $A9, $A8, $68,
$78, $B8, $B9, $79, $BB, $7B, $7A, $BA, $BE, $7E,
$7F, $BF, $7D, $BD, $BC, $7C, $B4, $74, $75, $B5,
$77, $B7, $B6, $76, $72, $B2, $B3, $73, $B1, $71,
$70, $B0, $50, $90, $91, $51, $93, $53, $52, $92,
$96, $56, $57, $97, $55, $95, $94, $54, $9C, $5C,
$5D, $9D, $5F, $9F, $9E, $5E, $5A, $9A, $9B, $5B,
$99, $59, $58, $98, $88, $48, $49, $89, $4B, $8B,
$8A, $4A, $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
$44, $84, $85, $45, $87, $47, $46, $86, $82, $42,
$43, $83, $41, $81, $80, $40
) ;

function crc16(const data; len: integer): word;
var
 uchcrchi,uchcrclo: byte;
 int1: integer;
 po: pbyte;
 by1: byte;
begin
 uchcrchi:= $ff;
 uchcrclo:= $ff;
 po:= @data;
 for int1:= len-1 downto 0 do begin
  by1:= po^ xor uchCRCHi;
  inc(po);
  uchCRCHi:= uchCRCLo xor auchCRCHi[by1];
  uchCRCLo:= auchCRCLo[by1] ;
 end;
// result:= (uchCRCHi shl 8) or uchCRCLo;
 result:= (uchCRCLo shl 8) or uchCRCHi;     //gedreht!
end;

function gettickus: longword; //laufzeit in us
 {$ifdef UNIX}
var
 t1: timeval;
begin
// gettimeofday(t1,ptimezone(nil){$ifdef FPC}^{$endif});
 gettimeofday(@t1,ptimezone(nil));
 result:= t1.tv_sec * 1000000 + t1.tv_usec;
end;
 {$else}
begin
 result:= windows.gettickcount*1000;
end;
 {$endif}

function commnrtocommname(commnr: commnrty): string;
begin
 if (commnr < low(commnrty)) or (commnr > high(commnrty)) then begin
  raise exception.Create('Invalid comnr: '+inttostr(integer(commnr))+'.');
 end;
 result:= commname[commnr];
end;

function checkcommport(commnr: commnrty): boolean;  //true wenn comport zur verfuegung //clx
var
 hcomm: thandle;
{$ifndef mswindows}
 info: termios;
{$endif}
begin
 {$ifdef mswindows}
 hcomm:= createfile(pchar(commname[commnr]), GENERIC_READ or GENERIC_WRITE, 0, nil,
               OPEN_EXISTING,0,0);
 if hcomm = invalidfilehandle then begin
  result:= false;
 end
 else begin
  result:= true;
  closehandle(hcomm);
 end;
 {$else}
 hcomm:= mselibc.open(PChar('/dev/'+commname[commnr]), o_rdwr or o_nonblock
             {,FileAccessRights});
 if hcomm = thandle(invalidfilehandle) then begin
  result:= false;
 end
 else begin
  result:=  msetcgetattr(hcomm,info) = 0;
  __close(hcomm);
 end;
 {$endif}
end;

function getbyte(char: pchar): byte;
begin
 result:= ord(char^)-ord('A') + ((ord((char+1)^)-ord('A')) shl 4);
end;

function getword(char: pchar): word;
begin
 result:= getbyte(char) + (getbyte(char+2) shl 8);
end;

function bintoascii(const bytes: pchar; const len: integer): string;
var
 int1: integer;
 po: pchar;
begin
 if len > 0 then begin
  setlength(result,2*len);
  po:= @result[1];
  for int1:= 0 to len-1 do begin
   po^:= char((pbyteaty(bytes)^[int1] and $0f) + ord('A'));
   inc(po);
   po^:= char((pbyteaty(bytes)^[int1] shr 4) + ord('A'));
   inc(po);
  end;
 end
 else begin
  result:= '';
 end;
end;

function bintoascii(const bytes: string): string;
begin
 result:= bintoascii(pointer(bytes),length(bytes));
end;

function asciitobin(const chars: string): string;
var
 po: pchar;
 int1: integer;
begin
 setlength(result,(length(chars)+1) div 2);
 po:= pointer(chars);
 for int1:= 1 to length(result) do begin
  result[int1]:= char(getbyte(po));
  inc(po,2);
 end;
end;

{ tcustomrs232 }

constructor tcustomrs232.create(const aowner: tmsecomponent; const
                      aoncheckabort: checkeventty = nil);
begin
 fcommnr:= cnr_1;
 fowner:= aowner;
 fhandle:= invalidfilehandle;
 fbaud:= cbr_9600;
 fdatabits:= cdb_8;
 fstopbit:= csb_1;
 faparity:= cpa_none;
 foncheckabort:= aoncheckabort;
 updatebyteinfo;
end;

destructor tcustomrs232.destroy;
begin
 close;
 inherited;
end;

procedure tcustomrs232.updatebyteinfo;
var
 openedvorher: boolean;
 int1: integer;
begin
 openedvorher:= opened;
 if openedvorher then begin
  close;
 end;
 int1:= 1 + databitcounts[fdatabits] + 1; //start + N daten + stop
 if fstopbit = csb_2 then begin
  inc(int1);
 end;
 if faparity <> cpa_none then begin
  inc(int1);
 end;
 fbyteus:= round(int1*1000000*commbittime[fbaud]);
 if openedvorher then begin
  open;
 end;
end;

function tcustomrs232.transmissiontime(const acount: integer): longword;
begin
 result:= fbyteus * acount;
end;

procedure tcustomrs232.Setbaud(const Value: commbaudratety);
begin
 if fbaud <> value then begin
  Fbaud := Value;
  updatebyteinfo;
 end;
end;

procedure tcustomrs232.Setcommnr(const Value: commnrty);
begin
 if (value < cnr_1) or (value > high(commnrty)) then begin
  raise exception.Create('Invalid commnr: '+inttostr(integer(value))+'.');
 end;
 if fcommnr <> value then begin
  Fcommnr := Value;
  updatebyteinfo;
 end;
end;

procedure tcustomrs232.setcommname(const avalue: filenamety);
begin
 if fcommname <> avalue then begin
  fcommname:= avalue;
  updatebyteinfo;
 end; 
end;

procedure tcustomrs232.Setparity(const Value: commparityty);
begin
 if faparity <> value then begin
  Faparity := Value;
  updatebyteinfo;
 end;
end;

procedure tcustomrs232.setdatabits(const avalue: commdatabitsty);
begin
 if fdatabits <> avalue then begin
  fdatabits:= avalue;
  updatebyteinfo;
 end;
end;

function tcustomrs232.canevent(const aevent: tmethod): boolean;
begin
 result:= (fowner = nil) or (fowner.canevent(aevent));
end;

procedure tcustomrs232.Setstopbit(const Value: commstopbitty);
begin
 if fstopbit <> value then begin
  Fstopbit := Value;
  updatebyteinfo;
 end;
end;

procedure tcustomrs232.reset;
begin
 if opened then begin
 {$ifdef UNIX}
  ioctl(fhandle,TCFLSH,[2]); //input und output flushen
 {$else}
  purgecomm(fhandle,PURGE_TXABORT+PURGE_RXABORT+PURGE_TXCLEAR+PURGE_RXCLEAR);
 {$endif}
 end;
end;

procedure tcustomrs232.resetinput;
begin
 if opened then begin
 {$ifdef UNIX}
  ioctl(fhandle,TCFLSH,[0]); //input flushen
 {$else}
  purgecomm(fhandle,PURGE_RXABORT+PURGE_RXCLEAR);
 {$endif}
 end;
end;

procedure tcustomrs232.resetoutput;
begin
 if opened then begin
 {$ifdef UNIX}
  ioctl(fhandle,TCFLSH,[1]); //output flushen
 {$else}
  purgecomm(fhandle,PURGE_TXABORT+PURGE_TXCLEAR);
 {$endif}
 end;
end;

procedure tcustomrs232.close;
begin
 if opened then begin
  if assigned(fonclose) then begin
   fonclose;
  end;
 {$ifdef UNIX}
  if not fnoclosehandle then begin
   __close(fhandle);
  end;
 {$else}
  if not fnoclosehandle then begin
   closehandle(fhandle);
  end;
  if overlappedrx.hevent <> 0 then begin
   closehandle(overlappedrx.hevent);
   overlappedrx.hEvent:= 0;
  end;
  if overlappedtx.hevent <> 0 then begin
   closehandle(overlappedtx.hevent);
   overlappedtx.hEvent:= 0;
  end;
  freeandnil(timer);
 {$endif}
 end;
 fhandle:= invalidfilehandle;
end;

function tcustomrs232.opened: boolean;
begin
 result:= fhandle <> invalidfilehandle;
end;

function tcustomrs232.open: boolean;
{$ifdef UNIX}
const
 iflagoff = BRKINT or INPCK or ISTRIP or IGNCR or INLCR or ICRNL or IUCLC or
            IXON or IXANY or IXOFF or IMAXBEL;
 iflagon = IGNBRK or IGNPAR;
 oflagoff = OPOST or OLCUC or ONLCR or OCRNL or ONOCR or ONLRET or OFILL or
            OFDEL or NLDLY or TABDLY or BSDLY or VTDLY or FFDLY;
 oflagon = 0;
 cflagoff = CBAUD or CSIZE or CSTOPB or PARENB or PARODD or HUPCL or CBAUDEX or
            CIBAUD or CRTSCTS ;
 cflagon = CREAD or CLOCAL;
 lflagoff = ISIG or ICANON or XCASE or ECHO or ECHOE or ECHOK or ECHONL or
            NOFLSH or TOSTOP or ECHOCTL or ECHOPRT or ECHOKE or IEXTEN;
 lflagon = 0;
var
 info: termios{ty};
 {$else}
var
 int1: integer;
 dcb: tdcb;
// bitzeit: real;
const           // fuer tdcb.flags
    fBinary =           $0001;  // binary mode, no EOF check
    fParity =           $0002;  // enable parity checking
    fOutxCtsFlow =      $0004;  // CTS output flow control
    fOutxDsrFlow =      $0008;  // DSR output flow control
    fDtrControldisable = $0000; // DTR flow control type
    fDtrControlenable = $0010;
    fDsrSensitivity =   $0040;  // DSR sensitivity
    TXContinueOnXoff =  $0080;  // XOFF continues Tx

    fOutX =             $0100;  // XON/XOFF out flow control
    fInX =              $0200;  // XON/XOFF in flow control
    fErrorChar =        $0400;  // enable error replacement
    fNull =             $0800;  // enable null stripping
    fRtsControldisable = $0000; // RTS flow control
    fRtsControlenable = $1000;
    fRtsControlhandshake = $2000;
    fRtsControltoggle = $3000;
    fAbortOnError =     $4000;  // abort reads/writes on error
//    DWORD fDummy2:17;         // reserved

 defaultdcb: tdcb = (
    DCBlength: sizeof(tdcb);
    BaudRate: 9600;
    Flags: fbinary{+fdtrcontrolenable+frtscontrolenable};
    wReserved: 0;
    XonLim: 256;
    XoffLim: 128;
    ByteSize: 8;
    Parity: NOPARITY;
    StopBits: ONESTOPBIT;
    XonChar: #17;
    XoffChar: #19;
    ErrorChar: #0;
    EofChar: #0;
    EvtChar: #0;
    wReserved1: 0;

 );

{$endif}

 procedure raiseerror;
 begin
  close;
  syserror(syelasterror,'trs232: Can not set port mode.');
 end;
var
 str1: string;
 
begin       //open
 close;
 if fcommname <> '' then begin
  str1:= ansistring(tosysfilepath(fcommname));
 end
 else begin
 {$ifdef MSWINDOWS}
  str1:= msecommport.commname[fcommnr];
 {$else}
  str1:= '/dev/'+msecommport.commname[fcommnr];
 {$endif}
 end;
 {$ifdef UNIX}
 fhandle:= mselibc.open(PChar(str1),o_rdwr or o_nonblock{,FileAccessRights});
 if integer(fhandle) >= 0 then begin
  msetcgetattr(fhandle,info);
  info.c_iflag:= info.c_iflag and not(iflagoff) or iflagon;
  info.c_oflag:= info.c_oflag and not(oflagoff) or oflagon;
  info.c_cflag:= info.c_cflag and not(cflagoff) or cflagon;
  info.c_lflag:= info.c_lflag and not(lflagoff) or lflagon;
  if fstopbit = csb_2 then begin
   info.c_cflag:= info.c_cflag or cstopb;
  end;
  if faparity <> cpa_none then begin
   info.c_cflag:= info.c_cflag or parenb;
  end;
  if faparity = cpa_odd then begin
   info.c_cflag:= info.c_cflag or parodd;
  end;
  info.c_line:= char(N_TTY);
  info.c_cc[VMIN]:= fvmin;
  info.c_cc[VTIME]:= #0;

  info.c_cflag:= info.c_cflag or commdatabitflags[fdatabits];
  cfsetispeed(info,commbaudflags[fbaud]);
  cfsetospeed(info,commbaudflags[fbaud]);
  if msetcsetattr(fhandle,TCSANOW,info) <> 0 then begin
   raiseerror;
  end;
  reset;
 end;
 {$else}
 int1:= 0;
 fillchar(overlappedrx,sizeof(overlappedrx),0);
 fillchar(overlappedtx,sizeof(overlappedtx),0);
 overlappedrx.hevent:= createevent(nil,true,false,nil);
 overlappedtx.hevent:= createevent(nil,true,false,nil);
 
 repeat
  fhandle:= createfile(pchar(str1),GENERIC_READ or GENERIC_WRITE, 0,
                                    nil,OPEN_EXISTING,FILE_FLAG_OVERLAPPED,0);
  if (fhandle = invalidfilehandle) and (pos('//./',str1) = 0) then begin
   str1:= '//./'+str1;
   fhandle:= createfile(pchar(str1),GENERIC_READ or GENERIC_WRITE, 0,
                                    nil,OPEN_EXISTING,FILE_FLAG_OVERLAPPED,0);
  end;
  if fhandle = invalidfilehandle then begin
   sleep(100);
  end;
  inc(int1);
 until (fhandle <> invalidfilehandle) or (int1 > 2);
 if fhandle <> invalidfilehandle then begin
  fillchar(commtimeouts,sizeof(commtimeouts),#0);  //keine timeouts
//  commtimeouts.readintervaltimeout:= maxdword;     //bei read sofortige rueckkehr
  setcommtimeouts(fhandle,commtimeouts);
  dcb:= defaultdcb;
  if fhalfduplex then begin
//   dcb.flags:= fbinary+fdtrcontrolenable+frtscontroltoggle;    //geht nicht bei win95!
//   dcb.flags:= fbinary+fdtrcontrolenable+frtscontroldisable;
   timer:= tmmtimermse.create;
  end;
  dcb.baudrate:= commbaudrates[fbaud];
  dcb.bytesize:= databitcounts[fdatabits];
  case fstopbit of
   csb_1: dcb.stopbits:= onestopbit;
   csb_2: begin
    dcb.stopbits:= twostopbits;
   end;
  end;
  case self.faparity of
   cpa_none: dcb.parity:= noparity;
   cpa_odd: dcb.parity:= oddparity;
   cpa_even: dcb.parity:= evenparity;
  end;
  if not setcommstate(fhandle,dcb) then begin
   raiseerror;
  end;
  reset;
 end;
 {$endif}
 result:= opened;
 if result and assigned(fonopen) then begin
  fonopen;
 end;
end;

procedure tcustomrs232.setrts(active: boolean);
{$ifndef mswindows}
var
 flags: integer;
{$endif}
begin
 if opened then begin
 {$ifdef UNIX}
  flags:= TIOCM_RTS;
  if active then begin
   ioctl(fhandle,TIOCMBIS,@flags);
  end
  else begin
   ioctl(fhandle,TIOCMBIC,@flags);
  end;
  {$else}
  if active then begin
   escapecommfunction(fhandle,windows.setrts);
  end
  else begin
   escapecommfunction(fhandle,windows.clrrts);
  end;
  {$endif}
 end;
end;

procedure tcustomrs232.setdtr(active: boolean);
{$ifndef mswindows}
var
 flags: integer;
{$endif}
begin
 if opened then begin
 {$ifdef UNIX}
  flags:= TIOCM_DTR;
  if active then begin
   ioctl(fhandle,TIOCMBIS,@flags);
  end
  else begin
   ioctl(fhandle,TIOCMBIC,@flags);
  end;
  {$else}
  if active then begin
   escapecommfunction(fhandle,windows.setdtr);
  end
  else begin
   escapecommfunction(fhandle,windows.clrdtr);
  end;
  {$endif}
 end;
end;

function tcustomrs232.waitfortx(timeout: integer): boolean;
  //fuer LINUX: um max ein tick verzoegert!
  //funktioniert nicht in win2k, vermutlich bug

 {$ifdef mswindows}
var
 ca1: longword;
 {$endif}
begin
 {$ifdef UNIX}
 ioctl(fhandle,tcsbrk,[-1]);
 result:= true;
 {$else}
 getcommmask(fhandle,ca1);
 if ca1 <> ev_txempty then begin
  raise exception.Create('trs232.waitfortx falsche commmask');
 end;
 waitcommevent(fhandle,ca1,@overlappedtx);
 result:= waitforsingleobject(overlappedtx.hevent,timeout div 1000) =
                                                               wait_object_0;
 if not result then begin
  setcommmask(fhandle,0); //overlapped puffer freigeben
 end;
 {$endif}
end;

{$ifdef mswindows}
procedure tcustomrs232.eotevent(sender: tobject);
begin
 setrts(false);
end;

{$endif}
function tcustomrs232.defaulttimeout(us: longword; anzahl: integer;
      out timeout: longword): boolean;
  // timeout in us 0 -> 2*uebertragungszeit,
begin
 timeout:= us;
 result:= us <> infinitemse;
 if result then begin
  if us = 0 then begin
   timeout:= transmissiontime(anzahl)*2+30000;
  end;
 end;
end;

function tcustomrs232.writestring(const dat: string; timeout: longword = 0;
      waitforeot: boolean = false): boolean;
  // timeout in us 0 -> 2*uebertragungszeit,
  // waitforeot -> warten auf uebertragungsende, bei halbduplex sowiso
var
 len: longword;
 {$ifdef UNIX}
 timed: boolean;
 int1: integer;
 ca1: longword;
 po: ^byte;
 time: longword;
 {$else}
 ca1: longword;
// time: longword;
// bo1: boolean;
 {$endif}
begin
 result:= false;
 if integer(fhandle) >= 0 then begin
  len:= length(dat);
  if len = 0 then begin
   result:= true;
   exit;
  end;
  if fhalfduplex then begin
   setrts(true);
   {$ifdef mswindows}
//   waitus(frtstimevor);
   timer.wait(frtstimevor+1000);
   timer.start(integer(len)*fbyteus+frtstimenach+1000,{$ifdef FPC}@{$endif}eotevent);
   {$else}
   waitus(frtstimevor);
//   usleep(frtstimevor);
   {$endif}
  end;
  {$ifdef UNIX}
  timed:= defaulttimeout(timeout,len,timeout);
  time:= timestep(timeout);
  po:= @dat[1];
  repeat
   int1:= __write(fhandle,po^,len);
   inc(po,int1);
   dec(len,int1);
  until (len = 0) or (timed and msesysutils.timeout(time));
  result:= len = 0;
  {$else}
  defaulttimeout(timeout,len,timeout);
  setcommmask(fhandle,0);
  setcommmask(fhandle,ev_txempty); //funktioniert nicht fuer w2k, waitcommevent kehrt sofort zurueck!
  if not writefile(fhandle,dat[1],len,ca1,@overlappedtx) then begin
   if getlasterror = ERROR_IO_PENDING then begin
    result:= waitforsingleobject(overlappedtx.hevent,timeout div 1000+1) =
                                                               WAIT_OBJECT_0;
   end;
  end
  else begin
   result:= true;
  end;
  if not result then begin
   purgecomm(fhandle,PURGE_TXABORT); //overlapped puffer freigeben
  end;
  {$endif}
  if fhalfduplex then begin
   if result then begin
    {$ifdef mswindows}
    timer.wait;
    {$else}
//    result:= false;
    time:= timestep(transmissiontime(length(dat)*2));
    repeat
     ioctl(fhandle,tiocsergetlsr,@ca1);
     result:= ca1 and TIOCSER_TEMT <> 0;
    until result or msesysutils.timeout(time);
    if result and (frtstimenach <> 0) then begin
     waitus(frtstimenach);
    end;
//    usleep(frtstimenach);
    {$endif}
   end;
   setrts(false);
  end
  else begin
   if waitforeot then begin
    result:= waitfortx(timeout);
   end;
  end;
 end;
 {$ifdef mswindows}
 purgecomm(fhandle,PURGE_TXABORT);   //overlapped puffer freigeben
 {$endif}
end;

function tcustomrs232.readbuffer(anzahl: integer; out dat;
                       timeout: longword = 0): integer;
            //list daten, bringt anzahl gelesene zeichen timeout in us 0 -> 2*uebertragungszeit
var
 po: ^byte;
 int1: integer;
 {$ifdef UNIX}
 time: longword;
 pollinfo: array[0..0] of pollfd;
 {$else}
 time: longword;
 bo1: boolean;
 {$endif}
 timed: boolean;
begin
 result:= 0;
 po:= @dat;
 if opened then begin
  if anzahl > 0 then begin
   timed:= defaulttimeout(timeout,anzahl,timeout);
   time:= timestep(timeout);
  {$ifdef mswindows}
   bo1:= windows.readfile(fhandle,po^,anzahl,longword(int1),@overlappedrx);
  {$else}
   if timed then begin
    fillchar(pollinfo,sizeof(pollinfo),0);
    with pollinfo[0] do begin
     fd:= fhandle;
     events:= pollin;
    end;
   end;
  {$endif}
   while true do begin
   {$ifdef UNIX}
    if timed then begin
     repeat
      int1:= poll(@pollinfo,1,timeout div 1000 + 1);
      if (int1 < 0) and (sys_getlasterror <> eintr) then begin
       break;
      end;
     until int1 >= 0;
     if int1 > 0 then begin
      int1:= __read(fhandle,po^,anzahl);
     end;
    end
    else begin
     int1:= __read(fhandle,po^,anzahl);
    end;
   {$else}
    if not bo1 then begin
     if not getoverlappedresult(fhandle,
                                   overlappedrx,longword(int1),false) then begin
      bo1:= windows.getlasterror = error_io_incomplete;
      if bo1 then begin
       bo1:= waitforsingleobject(
                        overlappedrx.hevent,timeout div 1000 + 1) = WAIT_OBJECT_0;
       if bo1 then begin
        bo1:= getoverlappedresult(fhandle,
                                   overlappedrx,longword(int1),false);
       end;
      end;
      if not bo1 then begin
       int1:= -1;
       purgecomm(fhandle,PURGE_RXABORT); //puffer freigeben
      end;
     end;
    end;
   {$endif}
    if int1 < 0 then begin
     break;
    end;
    if int1 <> 0 then begin
     inc(po,int1);
    end;
    anzahl:= anzahl - int1;
    result:= result + int1;
    if (anzahl <= 0) or timed and msesysutils.timeout(time) or
       (canevent(tmethod(foncheckabort)) and foncheckabort(self)) then begin
     break;
//    end
//    else begin
//     sleepus(fbyteus);
    end;
   end;
  end;
 end;
end;

(*
{$ifdef UNIX}
function tcustomrs232.readbuffer(anzahl: integer; out dat;
                       timeout: longword = 0): integer;
            //list daten, bringt anzahl gelesene zeichen timeout in us 0 -> 2*uebertragungszeit
var
 po: ^byte;
 int1: integer;
 time: timeval;
 timed: boolean;
begin
 result:= 0;
 po:= @dat;
 if opened then begin
  if anzahl > 0 then begin
   timed:= defaulttimeout(timeout,anzahl,timeout);
   time:= timestep(timeout);
   while true do begin
    int1:= __read(fhandle,po^,anzahl);
    if int1 < 0 then begin
     break;
    end;
    if int1 <> 0 then begin
     inc(po,int1);
    end;
    anzahl:= anzahl - int1;
    result:= result + int1;
    if (anzahl <= 0) or timed and zeitabgelaufen(time) or
       (canevent(foncheckabort) and foncheckabort(self)) then begin
     break;
    end
    else begin
     usleep(fbyteus);
    end;
   end;
  end;
 end;
end;

{$else}

function tcustomrs232.readbuffer(anzahl: integer; out dat;
                       timeout: longword = 0): integer;
            //liest daten, bringt anzahl gelesene zeichen timeout in us 0 -> 2*uebertragungszeit
var
 po: ^byte;
 int1: integer;
 bo1: boolean;
begin
 result:= 0;
 po:= @dat;
 if opened then begin
  if anzahl > 0 then begin
   if defaulttimeout(timeout,anzahl,timeout) then begin
    timeout:= timeout div 1000;
   end;
   bo1:= windows.readfile(fhandle,po^,anzahl,longword(result),@overlapped);
   if not bo1 and (getlasterror = ERROR_IO_PENDING) then begin
    bo1:= waitforsingleobject(overlapped.hevent,timeout) = WAIT_OBJECT_0;
   end;
   if not bo1 then begin
    purgecomm(fhandle,PURGE_RXABORT); //puffer freigeben
   end
   else begin
    if not getoverlappedresult(fhandle,overlapped,longword(result),false) then begin
     result:= 0;
    end;
   end;
  end;
 end;
end;
{$endif} //not unix
{$ifend}
*)

function tcustomrs232.readstring(anzahl: integer; out dat: string;
  timeout: longword = infinitemse): boolean;
  //timeout = 0 -> timeout = 2*uebertragungszeit
var
 int1: integer;
begin
 result:= false;
 if opened then begin
  setlength(dat,anzahl);
  int1:= readbuffer(anzahl,dat[1],timeout);
  setlength(dat,int1);
  result:= int1 = anzahl;
 end;
end;

function tcustomrs232.readavailbuffer(const maxcount: integer; out dat): integer;
begin
 result:= 0;
 if maxcount > 0 then begin
  piperead(dat,maxcount,result,true);
 end;
end;

function tcustomrs232.readavailstring(const maxcount: integer): string;
begin
 setlength(result,maxcount);
 setlength(result,readavailbuffer(maxcount,pointer(result)^));
end;

{$ifdef mswindows}
function tcustomrs232.setreadnonblocked(const anonblocked: boolean): boolean;
begin
 result:= true;
 if anonblocked then begin
  if commtimeouts.readintervaltimeout <> maxdword then begin
   commtimeouts.readintervaltimeout:= maxdword;  
   result:= setcommtimeouts(fhandle,commtimeouts);
  end;
 end
 else begin  
  if commtimeouts.readintervaltimeout <> 0 then begin
   commtimeouts.readintervaltimeout:= 0;  
   result:= setcommtimeouts(fhandle,commtimeouts);
  end;
 end;
 if not result then begin
  commtimeouts.readintervaltimeout:= maxdword div 2; //setting invalid
 end;
end;
{$endif}

function tcustomrs232.piperead(var buf; const acount: integer;
               out readcount: integer;
               const nonblocked: boolean): boolean;
{$ifdef mswindows}
var
 w1: ptruint;
 bo1: boolean;
{$endif}
begin
{$ifdef mswindows}
 bo1:= true;
 w1:= 0;
 bo1:= setreadnonblocked(nonblocked);
 if bo1 then begin
  if nonblocked then begin
   bo1:= windows.readfile(fhandle,buf,acount,w1,@overlappedrx);
  end
  else begin
   if acount > 0 then begin
    bo1:= windows.readfile(fhandle,buf,1,w1,@overlappedrx);
   end
   else begin
    bo1:= windows.readfile(fhandle,buf,0,w1,@overlappedrx);
   end;
   if not bo1 and (getlasterror = ERROR_IO_PENDING) then begin
    bo1:= getoverlappedresult(fhandle,overlappedrx,w1,true);
   end;
   if bo1 and (acount > 1) then begin
    bo1:= setreadnonblocked(true) and 
        windows.readfile(fhandle,(pchar(@buf)+1)^,acount-1,w1,@overlappedrx);
    if not bo1 and (getlasterror = ERROR_IO_PENDING) then begin
     bo1:= getoverlappedresult(fhandle,overlappedrx,w1,true);
    end;
    if bo1 then begin
     w1:= w1 + 1;
    end;
   end;
  end;
 end;  
 if not bo1 then begin
  readcount:= 0;
 end
 else begin
  readcount:= w1;
 end;
 result:= bo1;
{$else}
 readcount:= readfilenonblock(handle,buf,acount,nonblocked);
 result:= readcount >= 0;
{$endif}
end;

function tcustomrs232.pipewrite(const buffer; count: longint): longint;
{$ifdef mswindows}
var
 w1: ptruint;
 bo1: boolean;
{$endif}
begin
{$ifdef mswindows}
 bo1:= windows.writefile(fhandle,buffer,count,w1,@overlappedtx);
 if not bo1 and (getlasterror = ERROR_IO_PENDING) then begin
  bo1:= getoverlappedresult(fhandle,overlappedtx,w1,true);
 end;
 if bo1 then begin
  result:= w1;
 end
 else begin
  result:= -1;
 end;
{$else}
 result:= sys_write(fhandle,@buffer,count);
{$endif}
end;

procedure tcustomrs232.setactive(const avalue: boolean);
begin
 if avalue then begin
  open;
 end
 else begin
  close;
 end;
end;

{ tcommthread }

constructor tcommthread.create(const aowner: tmsecomponent);
begin
 fowner:= aowner;
 fport:= trs232.create(fowner,{$ifdef FPC}@{$endif}checkabort);
 inherited create({$ifdef FPC}@{$endif}execute);
end;

destructor tcommthread.destroy;
begin
 inherited;
 fport.Free;
end;

function tcommthread.readstring(anzahl: integer; out dat: string;
  timeout: integer): boolean;
begin
 result:= fport.readstring(anzahl,dat,timeout);
 if not result then begin
  fport.reset;                 //puffer freigeben
 end;
end;

function tcommthread.writestring(const dat: string;
  timeout: integer): boolean;
begin
 result:= fport.writestring(dat,timeout,timeout=0);
end;

procedure tcommthread.abort;
begin
 if running then begin
  fabort := true;
  inherited postevent(tmseevent.create(ek_abort));
  if sys_getcurrentthread <> id then begin
   while fabort do begin
    sys_threadschedyield;
   end;
  end;
 end;
end;

function tcommthread.checkabort(const sender: tobject): boolean;
begin
 result:= application.terminated or terminated or fabort;
end;

function tcommthread.execute(thread: tmsethread): integer;
var
 event: tmseevent;
 abort1: boolean;

 procedure freeevent;
 begin
  if event is tcommevent then begin
   with tcommevent(event) do begin
    if not fpersistent then begin
     free1;
    end
    else begin
     if abort1 then begin
      fstate:= coms_abort;
      sys_sempost(fsem);
     end;
    end;
   end;
  end
  else begin
   event.Free1;
  end;
 end;

var
 bo1,bo2: boolean;

begin
 repeat
  event:= waitevent;
  abort1:= fabort;
  if abort1 then begin
   freeevent;
   while eventcount > 0 do begin
    event:= waitevent;
    freeevent;
   end;
   fabort:= false;
  end
  else begin
   if event is tcommevent then begin
    with tcommevent(event) do begin
     bo2:= not fpersistent; //event can be destroyed later
     try
      bo1:= false;
      process(self,bo1);
     finally
      if bo2 then begin
       event.free1;
      end;
     end;
    end;
   end
   else begin
    event.Free1;
   end;
  end;
 until terminated;
 result:= 0;
end;

procedure tcommthread.reset;
begin
 fport.reset;
end;

procedure tcommthread.postevent(event: tcommevent);
begin
 with event do begin
  if fstate = coms_working then begin
   raise exception.Create('Comevent working!');
  end;
  fstate:= coms_working;
//  if fpersistent then begin
//   semreset{(fsem)};
//  end;
 end;
 inherited postevent(event);
end;

{ tcomevent }

constructor tcommevent.create(persistent: boolean; atimeout: integer = 200000);
begin
 fpersistent:= persistent;
 timeout:= atimeout;
 if fpersistent then begin
  sys_semcreate(fsem,0);
 end;
 inherited create(ek_user);
end;

destructor tcommevent.destroy;
begin
 if fpersistent then begin
  sys_semdestroy(fsem);
 end;
 inherited;
end;

procedure tcommevent.process(const thread: tcommthread; var ok: boolean);
begin
 processed(thread,ok);
end;

procedure tcommevent.processed(const thread: tcommthread; var ok: boolean);
begin
 if ok then begin
  fstate:= coms_ok;
  if assigned(onsuccess) then begin
   application.lock;
   try
    onsuccess(self);
   finally
    application.unlock;
   end;
  end;
 end
 else begin
  fstate:= coms_error;
  if assigned(onerror) then begin
   application.lock;
   try
    onerror(self);
   finally
    application.unlock;
   end;
  end;
 end;
 if fpersistent then begin
  sys_sempost(fsem);
 end;
end;

function tcommevent.state: commstatety;
begin
 result:= fstate;
end;

function tcommevent.waitfordata: boolean;
begin
 if not fpersistent then begin
  raise exception.Create('Comevent not persistent!');
 end;
 sys_semwait(fsem,0);
 result:= fstate = coms_ok;
end;

{ tasciicommthread }

constructor tasciicommthread.create(const aowner: tmsecomponent);
begin
 feorchar:= defaulteorchar;
 inherited;
end;

function tasciicommthread.checkabort(const sender: tobject): boolean;
begin
 result:= inherited checkabort(sender) or
     timeoutstarted and later(zeitstempel,gettickus);
end;

procedure tasciicommthread.closetimeout;
begin
 timeoutstarted:= false;
end;

procedure tasciicommthread.starttimeout(step: longword);
begin
 zeitstempel:= gettickus + step;
 timeoutstarted:= true;
end;

function tasciicommthread.readln(timeout: integer;
  out dat: string): integer;  //todo: optimize
var
 po,po1: pchar;
 laenge: integer; //longword;
 lwo1: longword;
 bo1,bo2: boolean;
// ca1: longword;
begin
 result:= cpf_timeout;
 dat:= '';
 laenge:= length(puffer);
 setlength(puffer,asciipufferlaenge);
 po:= pchar(puffer);           //start
 po1:= po;
 bo1:= false;
 bo2:= false;
 starttimeout(timeout);
 while not bo1 do begin
  po1:= strlscan(po1,feorchar,laenge-(po1-po));
  if po1 <> nil then begin
   dat:= dat + copy(puffer,1,po1-po);
   move(po1[1],po^,laenge-(po1-po));
   laenge:= laenge-(po1-po)-1;
   result:= cpf_ok;
   break;
  end;
  if laenge >= asciipufferlaenge then begin
   dat:= dat + puffer;
   uniquestring(puffer);
   laenge:= 0;
  {
   laenge:= 0; //platz fuer naechstes telegramm
   result:= cpf_bufferoverflow;
   break;     //puffer voll
  }
  end;
  po1:= po+laenge;
  lwo1:= fport.readbuffer(asciipufferlaenge-laenge,po1[0],fport.transmissiontime(2));
  laenge:= laenge + integer(lwo1);
  bo1:= bo2;
  bo2:= checkabort(nil);
 end;
 setlength(puffer,laenge);
 closetimeout;
end;

procedure tasciicommthread.reset;
begin
 puffer:= '';
 inherited;
end;

function tasciicommthread.sendstring(const data: string): integer;
begin
 if not fport.opened then begin
  result:= cpf_notopen;
  exit;
 end;
 result:= cpf_timeout;
 if fport.writestring(data+feorchar,0) then begin
  result:= cpf_ok;
 end;
end;

function tasciicommthread.sendstring(const data: string;
  out antwort: string; timeout: integer): integer;
var
 int1: integer;
 bo1: boolean;
// str1: string;
begin
 if not fport.opened then begin
  result:= cpf_notopen;
  exit;
 end;
 int1:= fsendretries;
 repeat
// while (result <> cpf_ok) and (int1 >= 0) do begin
  reset;     // puffer loeschen
  result:= sendstring(data);
  if result = cpf_ok then begin
   result:= cpf_timeout;
//  if fport.writestring(data+feorchar,0) then begin
   if fport.fhalfduplex then begin
//    sleep(20);
    bo1:= fport.readstring(length(data)+1,antwort,0); //eigene zeichen
   end
   else begin
    bo1:= true;
   end;
   if bo1 then begin
    result:= readln(timeout,antwort);
   end;
  end;
  dec(int1);
 until (result = cpf_ok) or (int1 < 0);
end;

{ tcommport }

constructor tcommport.create(aowner: tcomponent);
begin
 ftimeout:= 200000;
 if fthread = nil then begin
  fthread:= tcommthread.create(self);
 end;
 inherited;
end;

destructor tcommport.destroy;
begin
 freeandnil(fthread);
 inherited;
end;

procedure tcommport.abort;
begin
 fthread.abort;
end;

procedure tcommport.closeport;
begin
 fthread.fport.close;
 fopened:= false;
 portchanged;
end;

function tcommport.getbusy: boolean;
begin
 result:= fthread.eventcount > 0;
end;

function tcommport.getbaudrate: commbaudratety;
begin
 result:= fthread.fport.baud;
end;

procedure tcommport.Setbaudrate(const Value: commbaudratety);
begin
 fthread.fport.baud:= value;
end;

function tcommport.getdatabits: commdatabitsty;
begin
 result:= fthread.fport.databits;
end;

procedure tcommport.setdatabits(const avalue: commdatabitsty);
begin
 fthread.fport.databits:= avalue;
end;

function tcommport.extracterrortext(error: integer;
  errors: array of errorrecty; var text: msestring): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(errors) do begin
  if errors[int1].error = error then begin
   text:= errors[int1].text;
   result:= true;
   break;
  end;
 end;
end;

function tcommport.geterrortext(error: integer): msestring;
begin
 if not extracterrortext(error,errortexte,result) then begin
  result:= 'Error Nr.: '+inttostrmse(error);
 end;
end;

function tcommport.gethalfduplex: boolean;
begin
 result:= fthread.fport.halfduplex;
end;

procedure tcommport.sethalfduplex(const Value: boolean);
begin
 fthread.fport.halfduplex:= value;
end;

function tcommport.getlastresulttext: msestring;
begin
 result:= geterrortext(flastresult);
end;

function tcommport.getopened: boolean;
begin
 result:= (fthread <> nil ) and fopened and (fthread.fport.opened);
end;

function tcommport.getparity: commparityty;
begin
 result:= fthread.fport.parity;
end;

procedure tcommport.Setparity(const Value: commparityty);
begin
 fthread.fport.parity:= value;
end;

function tcommport.getport: commnrty;
begin
 result:= fthread.fport.commnr;
end;

procedure tcommport.setport(const Value: commnrty);
begin
 fthread.fport.commnr:= value;
 portchanged;
end;

function tcommport.getportname: filenamety;
begin
 result:= fthread.fport.commname;
end;

procedure tcommport.setportname(const avalue: filenamety);
begin
 fthread.fport.commname:= avalue;
 portchanged;
end;


function tcommport.getrtstimenach: integer;
begin
 result:= fthread.fport.frtstimenach;
end;

procedure tcommport.setrtstimenach(const Value: integer);
begin
 fthread.fport.rtstimenach:= value;
end;

function tcommport.getrtstimevor: integer;
begin
 result:= fthread.fport.frtstimevor;
end;

procedure tcommport.setrtstimevor(const Value: integer);
begin
 fthread.fport.rtstimevor:= value;
end;

function tcommport.getsendretries: integer;
begin
 result:= fthread.sendretries;
end;

procedure tcommport.setsendretries(const Value: integer);
begin
 fthread.sendretries:= value;
end;

function tcommport.getstopbit: commstopbitty;
begin
 result:= fthread.fport.stopbit;
end;

procedure tcommport.Setstopbit(const Value: commstopbitty);
begin
 fthread.fport.stopbit:= value;
end;

function tcommport.openport(raiseexception: boolean): boolean;
begin
 result:= fthread.fport.open;
 fopened:= true;
 if raiseexception and not result then begin
//  raise EFCreateError.Create(commname[fport.fcommnr]+' '+t_nichtoffen+'.');
  raise exception.Create(commname[fthread.fport.fcommnr]+' '+t_nichtoffen+'.');
 end;
 doafteropen;
 portchanged;
end;

procedure tcommport.portchanged;
begin
 if canevent(tmethod(fonportchange)) then begin
  fonportchange(self);
 end;
end;

function tcommport.postandwait(const event: tcommevent): boolean;
begin
 fthread.postevent(event);
 result:= event.waitfordata;
end;

procedure tcommport.postevent(const event: tcommevent);
begin
 fthread.postevent(event);
end;

procedure tcommport.setactive(const Value: boolean);
begin
 factive := Value;
 if componentstate * [csloading,csdesigning] = [] then begin
  if value then begin
   openport;
  end
  else begin
   closeport;
  end;
 end;
end;

procedure tcommport.loaded;
begin
 inherited;
 setactive(factive);
end;

procedure tcommport.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

function tcommport.getstatvarname: msestring;
begin
 Result := fstatvarname;
end;

procedure tcommport.dostatread(const reader: tstatreader);
begin
 port:= commnrty(reader.readinteger('port',integer(port),
             ord(low(commnrty)),ord(high(commnrty))));
end;

procedure tcommport.dostatwrite(const writer: tstatwriter);
begin
 writer.writeinteger('port',integer(port));
end;

procedure tcommport.statreading;
begin
 //dummy
end;

procedure tcommport.statread;
begin
 //dummy
end;

procedure tcommport.doafteropen;
begin
 //dummy;
end;

function tcommport.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ tasciicommport }

constructor tasciicommport.create(aowner: tcomponent);
begin
 fthread:= tasciicommthread.create(self);
 inherited;
end;

function tasciicommport.geteorchar: char;
begin
 result:= tasciicommthread(fthread).eorchar;
end;

procedure tasciicommport.seteorchar(const avalue: char);
begin
 tasciicommthread(fthread).eorchar:= avalue;
end;

function tasciicommport.send(const commandstring: string;
  out answer: string; atimeout: integer = 0): integer;
var
 ev: tasciicommevent;
begin
 if atimeout = 0 then begin
  atimeout:= ftimeout;
 end;
 ev:= geteventclass.create(true,atimeout);
 try
  ev.commandstring:= commandstring;
  tasciicommthread(fthread).postevent(ev);
  ev.waitfordata;
  if (ev.state = coms_ok) or (ev.state = coms_error) then begin
   result:= ev.resultcode;
   answer:= ev.resultstring;
  end
  else begin
   result:= integer(ev.state);
   answer:= '';
  end;
 finally
  ev.Free1;
 end;
end;

function tasciicommport.geteventclass: asciicommeventclassty;
begin
 result:= tasciicommevent;
end;

function tasciicommport.send(const commandstrings: array of string): integer;
var
 int1: integer;
// str1: string;
begin
 result:= cpf_none;
 for int1:= 0 to high(commandstrings) do begin
  result:= tasciicommthread(fthread).sendstring(commandstrings[int1]);
  if result <> cpf_ok then begin
   break;
  end;
 end;
end;

function tasciicommport.getthread: tasciicommthread;
begin
 result:= tasciicommthread(fthread);
end;

{ tasciicomevent }

procedure tasciicommevent.process(const thread: tcommthread; var ok: boolean);
begin
 if commandstring <> '' then begin
  with tasciicommthread(thread) do begin
   resultcode:= sendstring(commandstring,resultstring,timeout);
  end;
  ok:= resultcode = cpf_ok;
 end;
 inherited;
end;

{ tasciiprotevent }

constructor tasciiprotevent.create(persistent: boolean;
               atimeout: integer = 200000);
begin
 inherited;
end;

procedure tasciiprotevent.processed(const thread: tcommthread; var ok: boolean);
var
 int1: integer;
begin
 if ok and (length(resultstring) > 0) then begin
  if resultstring[1] = errorchar then begin
   ok:= false;
   if length(resultstring) = 1 then begin
    int1:= ord(ape_command);
   end
   else begin
    int1:= ord(resultstring[2]) - ord('A')+1;
    if (int1 < ord(ape_command)) or 
          (int1 > ord(high(asciiproterrorty))) then begin
     int1:= ord(ape_unknown);
    end;
   end;
   resultcode:= errorcodes[asciiproterrorty(int1)];
  end;
 end;
 inherited;
end;

{ asciiprotport }
 
function tasciiprotport.geteventclass: asciicommeventclassty;
begin
 result:= tasciiprotevent;
end;

function tasciiprotport.send(const commandstring: string; out answer: string;
               atimeout: integer = 0; aadress: integer = -1): integer;
begin
 if aadress = -1 then begin
  result:= inherited send(commandstring,answer,atimeout);
 end
 else begin
  result:= inherited send(char(byte(aadress) or $80) +
                        commandstring,answer,atimeout);
 end;
end;

end.
