{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegdbutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 msestream,mseclasses,classes,msetypes,mseevent,msehash,msepipestream,msestrings,
 msegui,msedatalist;

//todo: 64bit,
//non native pointersize and byte endian for remote debugging

type
 gdbresultty = (gdb_ok,gdb_error,gdb_timeout,gdb_dataerror,gdb_message,gdb_running,
                gdb_writeerror);

 sigflagty = (sfl_internal,sfl_stop,sfl_handle);
 sigflagsty = set of sigflagty;


const
 gdberrortexts: array[gdbresultty] of string =
          ('','Error','Timeout','Data error','Message','Target running',
           'Write error');
 niltext = 'nil';

type
 gdbstatety = (gs_syncget,gs_syncack,gs_clicommand,gs_clilist,gs_started,
                    gs_execloaded,gs_attached,gs_detached,
                    gs_internalrunning,gs_running,gs_interrupted,gs_restarted,gs_closing);
 gdbstatesty = set of gdbstatety;

 recordclassty = (rec_done,rec_running,rec_connected,rec_error,rec_exit,
                  rec_stopped);
 resultclassty = rec_done..rec_exit;
 asyncclassty = rec_stopped..rec_stopped;
const
 recordclassnames: array[recordclassty] of string =
         ('done','running','connected','error','exit','stopped');
 defaultsynctimeout = 2000000; //2 seconds
type
 valuekindty = (vk_value,vk_tuple,vk_list);
 gdbeventkindty = (gek_done,gek_error,gek_running,gek_stopped,gek_targetoutput,
                                          gek_writeerror);

 resultinfoty = record
  variablename: string;
  valuekind: valuekindty;
  value: string;
 end;
 resultinfoarty = array of resultinfoty;
 resultinfoararty = array of resultinfoarty;

 stopreasonty = (sr_none,sr_error,sr_startup,sr_exception,
                 sr_breakpoint_hit,sr_watchpointtrigger,
                 sr_end_stepping_range,sr_function_finished,
                 sr_exited_normally,sr_exited,sr_detached,sr_signal_received);
const
 stopreasontext: array[stopreasonty] of string = (
          '',
          'Error',
          'Startup',
          'Exception',
          'Breakpoint hit',
          'Watchpoint triggered',
          'End stepping range',
          'Function finished',
          'Exited normally',
          'Exited',
          'Detached',
          'Signal received'
          );
type
 stopinfoty = record
  reason: stopreasonty;
  bkptno: integer;
  threadid: integer;
  exitcode: integer;
  filename: filenamety;
  filedir: filenamety;
  line: integer;
  addr: cardinal;
  func: string;
  signalname: string;
  signalmeaning: string;
  messagetext: string;
  expression,oldvalue,newvalue: string;
 end;
{
 errorinfoty = record
  messagetext: string;
 end;
}
 breakpointinfoty = record
  line: integer;    //1. line = 0
  path: filenamety;
//  filename: string;
  bkptno: integer;
  bkpton: boolean;
  ignore: integer;
  passcount: integer;
  condition,conditionmessage: string;
 end;
 pbreakpointinfoty = ^breakpointinfoty;
 breakpointinfoarty = array of breakpointinfoty;

 watchpointkindty = (wpk_write,wpk_readwrite,wpk_read);

 watchpointinfoty = record
  kind: watchpointkindty;
  wptno: integer;
  expression: string;
  ignore: integer;
  condition: string;
  conditionmessage: string;
 end;

 paraminfoty = record
  name: string;
  value: string;
 end;
 paraminfoarty = array of paraminfoty;

 frameinfoty = record
  level: integer;
  addr: pointer;
  func: string;
  filename: filenamety;
  line: integer;
  params: paraminfoarty;
 end;
 frameinfoarty = array of frameinfoty;

 registerinfoty = record
  num: integer;
  bits: string; //hex notation
 end;
 registerinfoarty = array of registerinfoty;

 asmlinety = record
  address: cardinal;
  instruction: string;
 end;
 asmlinearty = array of asmlinety;

 disassty = record
  line: integer;
  asmlines: asmlinearty;
 end;
 disassarty = array of disassty;

 tgdbmi = class;

 gdbeventty = procedure(const sender: tgdbmi; var eventkind: gdbeventkindty;
                        const values: resultinfoarty; const stoppinfo: stopinfoty) of object;

 tgdbevent = class(tobjectevent)
  public
   eventkind: gdbeventkindty;
   values: resultinfoarty;
 end;

 setnumprocty = procedure(var dataarray; const index: integer; const text: string);
 setlenprocty = procedure(var dataarray; const len: integer);

 threadstatety = (ts_none,ts_active);

 threadinfoty = record
  id: integer;       //gdb id
  threadid: integer; //system id
  state: threadstatety;
  stackframe: string;
 end;
 threadinfoarty = array of threadinfoty;

{$ifdef UNIX}
 tpseudoterminal = class
  private
   fdevicename: string;
   finput: tpipereader;
   foutput: tpipewriter;
   procedure closeinp;
  public
   constructor create;
   destructor destroy; override;
   procedure restart;
   property devicename: string read fdevicename;
   property input: tpipereader read finput;
   property output: tpipewriter read foutput;
 end;
{$endif} 

 tgdbmi = class(tguicomponent)
  private
   fpointersize: integer;
   fgdbto: tpipewriter;
   fgdbfrom,fgdberror: tpipereader;
   {$ifdef UNIX}
   ftargetterminal: tpseudoterminal;
   {$endif}
   fgdb: integer; //processhandle
   fstate: gdbstatesty;
   fsequence: cardinal;
   fconsolesequence: cardinal;
   frunsequence: cardinal;
   fsyncsequence: cardinal;
   fsyncvalues: resultinfoarty;
   fsynceventkind: gdbeventkindty;
   fclivalues: string;
   fclivaluelist: stringarty;
   fonevent: gdbeventty;
   fonerror: gdbeventty;
   fguiintf: boolean;
   fsourcefiles: thashedmsestrings;
   fsourcefiledirs: filenamearty;  //dirs for fsourcefiles
   fexceptionbkpt: integer;
   fstoponexception: boolean;
   ferrormessage: string;
   fprocid: cardinal;
   {$ifdef mswindows}
   finterruptthreadid: longword;
   {$endif}
   fworkingdirectory: filenamety;
   fprogparameters: string;
   finterruptcount: integer;
   fignoreexceptionclasses: stringarty;
   flogtext: string;
   flastbreakpoint: integer;
   fenvvars: doublestringarty;
   ftargetdebugbegin,ftargetdebugend: ptrint;
   {$ifdef mswindows}
   fnewconsole: boolean;
   {$endif}
   procedure setstoponexception(const avalue: boolean);
   procedure checkactive;
   procedure resetexec;
   function getrunning: boolean;
   function getexecloaded: boolean;
   function getattached: boolean;
   procedure setignoreexceptionclasses(const avalue: stringarty);
  protected
   {$ifdef UNIX}
   procedure targetfrom(const sender: tpipereader);
   {$endif}
   procedure gdbfrom(const sender: tpipereader);
   procedure gdberror(const sender: tpipereader);
   procedure interpret(const line: string);
   procedure consoleoutput(const text: string);
   procedure targetoutput(const text: string);
   procedure logoutput(const text: string);
   procedure sequenceend;
   procedure receiveevent(const event: tobjectevent); override;
   procedure doevent(const token: cardinal; const eventkind: gdbeventkindty;
                       const values: resultinfoarty);
   function internalcommand(acommand: string): boolean;
   function synccommand(const acommand: string; atimeout: integer = defaultsynctimeout): gdbresultty;
   function clicommand(const acommand: string; list: boolean = false;
                              timeout: integer = defaultsynctimeout): gdbresultty;
   function getcliresult(const acommand: string; var aresult: stringarty): gdbresultty;
   function getcliresultstring(const acommand: string; var aresult: string): gdbresultty;
   function getclistring(const aname: string; const response: string; out aresult: string): boolean;
   function getcliinteger(const aname: string; const response: string; out aresult: integer): boolean;

   function decodelist(const noname: boolean; const inp: string;
                            var value: resultinfoarty): boolean;
   function ispointervalue(const avalue: string;
             out pointervalue: ptrint): boolean;
   function matchpascalformat(const typeinfo: string; const value: string): msestring;
   function getpcharvar(address: cardinal): string;
   function getpmsecharvar(address: cardinal): msestring;
   function getnumarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue; setnumproc: setnumprocty; setlenproc: setlenprocty): boolean;
   function getpascalvalue(const avalue: string): string;
   function getbkptid: integer;
   function getwptid: integer;
   procedure initinternalbkpts;
   procedure initproginfo;
   function internaldisassemble(out aresult: disassarty; command: string;
                           const mixed: boolean): gdbresultty;
   function getshortstring(const address: string; out avalue: string): boolean;
   function setenv(const aname,avalue: string): gdbresultty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure startgdb(commandline: string);
   procedure closegdb;
   function interrupttarget: gdbresultty; //stop for breakpointsetting
   function restarttarget: gdbresultty;

   function togdbfilepath(const filename: filenamety): filenamety;

   procedure consolecommand(acommand: string);
   function micommand(const command: string; out values: resultinfoarty): gdbresultty;
                  //false on error or timeout, values = nil on timeout
   function geterrormessage(const aresult: gdbresultty): string;
   property errormessage: string read ferrormessage;
      //for synccommand if error = gdb_message

   function handle(const signame: string; const aflags: sigflagsty): gdbresultty;
              //
   function breakinsert(var info: breakpointinfoty): gdbresultty; overload;
   function breakinsert(const funcname: string): integer; overload;
                //returns bkpt id, -1 on error
   function breaklist(var list: breakpointinfoarty; full: boolean): gdbresultty;
               //full = false -> only bkptno and passcount
   function breakdelete(bkptnum: integer): gdbresultty; //bkptnum = 0 -> all
   function breakenable(bkptnum: integer; value: boolean): gdbresultty; //bkptnum = 0 -> all
   function breakafter(bkptnum: integer; const passcount: integer): gdbresultty;
   function breakcondition(bkptnum: integer; const condition: string): gdbresultty;
   function watchinsert(var info: watchpointinfoty): gdbresultty;

   function getstopinfo(const response: resultinfoarty; out info: stopinfoty): boolean;
//   function geterrorinfo(const response: resultinfoarty; out info: stopinfoty): boolean;

   function getvalueindex(const response: resultinfoarty; const aname: string): integer;
                 //-1 if not found
   function getenumvalue(const response: resultinfoarty;
          const aname: string; const enums: array of string; var avalue: integer): boolean;
   function gettuplevalue(const response: resultinfoarty; const aname: string;
                 var avalue: resultinfoarty): boolean; overload;
   function gettuplevalue(const response: resultinfoty;
                 var avalue: resultinfoarty): boolean; overload;
   function gettuplevalue(const response: resultinfoty;  const aname: string;
                 var avalue: resultinfoarty): boolean; overload;
   function gettuplestring(const response: resultinfoarty; const aname: string;
                 var avalue: string): boolean; overload;

   function getstringvalue(const response: resultinfoarty; const aname: string;
                 var avalue: string): boolean; overload;
   function getstringvalue(const response: resultinfoty; const aname: string;
                 var avalue: string): boolean; overload;
   function getintegervalue(const response: resultinfoarty; const aname: string;
                 var avalue: integer): boolean; overload;
   function getintegervalue(const response: resultinfoty; const aname: string;
                 var avalue: integer): boolean; overload;
   function getbooleanvalue(const response: resultinfoarty; const aname: string;
                 var avalue: boolean): boolean;
   function getptrintvalue(const response: resultinfoarty; const aname: string;
                 var avalue: ptrint): boolean; overload;
   function getptrintvalue(const response: resultinfoty; const aname: string;
                 var avalue: ptrint): boolean; overload;

   function getarrayvalue(const response: resultinfoarty; const aname: string;
                 const hasitemnames: boolean;
                 var avalue: resultinfoarty): boolean;

   function gettuplearrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: resultinfoararty): boolean;
   function getstringarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: stringarty): boolean;
   function getbytearrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: bytearty): boolean;
   function getwordarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: wordarty): boolean;
   function getlongwordarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: longwordarty): boolean;

   function fileexec(const filename: filenamety): gdbresultty;
   function attach(const procid: longword; out info: stopinfoty): gdbresultty;
   function detach: gdbresultty;
   function getprocid(var aprocid: longword): boolean;
                //true if ok
   function clearenvvars: gdbresultty;
   function setenvvar(const aname,avalue: string): gdbresultty;

   procedure run;
   procedure continue;
   procedure next;
   procedure step;
   procedure finish;
   procedure nexti;
   procedure stepi;
   procedure interrupt;
   procedure abort;
   procedure targetwriteln(const avalue: string); 
               //sends text to target if running

   procedure debugbegin; //calls GUI_DEBUGBEGIN in target
   procedure debugend;   //calls GUI_DEBUGEND in target,
                         //automatically on every target start
   
   function active: boolean;  //gdb running
   function started: boolean; //target active, run command applied or attached
   property running: boolean read getrunning; //target running

   function threadselect(const aid: integer; out filename: filenamety; 
                                             out line: integer): gdbresultty;
   function getthreadidlist(out idlist: integerarty): gdbresultty;
   function getthreadinfolist(out infolist: threadinfoarty): gdbresultty;

   function readmemorybytes(const address: ptrint; const count: integer;
                 var aresult: bytearty): gdbresultty;
   function readmemorywords(const address: ptrint; const count: integer;
                 var aresult: wordarty): gdbresultty;
   function readmemorypointer(const address: ptrint; out aresult: ptrint): gdbresultty;

   function readpascalvariable(const varname: string; out aresult: msestring): gdbresultty;
   function writepascalvariable(const varname: string; const value: string;
                var aresult: string): gdbresultty;
   function evaluateexpression(const expression: string;
                  var aresult: string): gdbresultty;
   function symboltype(const symbol: string; var aresult: string): gdbresultty;
   function stacklistframes(out list: frameinfoarty; first: integer = 0;
                    last: integer = 100): gdbresultty;
   function selectstackframe(const aframe: integer): gdbresultty;
   function getsourcename(var path: filenamety; frame: integer = 0): gdbresultty;
   function getprocaddress(const procname: string;
                        out aaddress: ptrint): gdbresultty;

   function getpc(out addr: ptrint): gdbresultty;
   function getregistervalue(const aname: string; out avalue: ptrint): gdbresultty;
   function listregisternames(out aresult: stringarty): gdbresultty;
   function listregistervalues(out aresult: registerinfoarty): gdbresultty;
   function listlines(const path: filenamety;
                          out lines: integerarty; out addresses: ptrintarty): gdbresultty;

   function infoline(const filename: filenamety; const line: integer;
                         out start,stop: cardinal): gdbresultty; overload;
   function infoline(const address: cardinal; out filename: filenamety; out line: integer;
                         out start,stop: cardinal): gdbresultty; overload;
   function disassemble(out aresult: asmlinearty; const filename: filenamety;
                 const line: integer; const count: integer): gdbresultty; overload;
   function disassemble(out aresult: asmlinearty; const start,stop: cardinal): gdbresultty; overload;
   function disassemble(out aresult: disassarty; const filename: filenamety;
                 const line: integer; const count: integer): gdbresultty; overload;
   function disassemble(out aresult: disassarty; const start,stop: cardinal): gdbresultty; overload;

   property guiintf: boolean read fguiintf write fguiintf default true;
   property execloaded: boolean read getexecloaded;
   property attached: boolean read getattached;
   property stoponexception: boolean read fstoponexception write setstoponexception default false;
   property ignoreexceptionclasses: stringarty read fignoreexceptionclasses write
                     setignoreexceptionclasses;

   property progparameters: string read fprogparameters write fprogparameters;
   property workingdirectory: filenamety read fworkingdirectory write fworkingdirectory;
   {$ifdef mswindows}
   property newconsole: boolean read fnewconsole write fnewconsole;
   {$endif}
  published
   property onevent: gdbeventty read fonevent write fonevent;
   property onerror: gdbeventty read fonerror write fonerror;
 end;

implementation

uses
 sysutils,mseformatstr,mseprocutils,msesysutils,msefileutils,
 msebits,msesys,msesysintf,mseguiintf
        {$ifdef UNIX},libc{$else},windows{$endif};

const                                      
 stopreasons: array[stopreasonty] of string = 
           //sr_none sr_error sr_startup sr_exception
             ('',     '',     '',          '',      
              'breakpoint-hit','watchpoint-trigger',
              'end-stepping-range','function-finished','exited-normally',
              'exited','detached','signal-received');

procedure getcstring(var text: pchar);
var
 po1: pchar;
begin
 if text <> nil then begin
  if text^ = '"' then begin
   po1:= text;
   repeat
    inc(po1);
    if po1^ = '\' then begin
     inc(po1,2);
    end;
   until (po1^ = '"') or (po1^ = #0);
   if po1^ <> #0 then begin
    text:= po1+1;
   end;
  end;
 end;
end;

procedure gettuple(var text: pchar);
var
 level: integer;
 po1: pchar;
begin
 if text <> nil then begin
  level:= 0;
  po1:= text;
  repeat
   case po1^ of
    '{': begin
     inc(level);
    end;
    '}': begin
     dec(level);
    end;
    '"': begin
     getcstring(po1);
     dec(po1);
    end;
   end;
   inc(po1);
  until (level <= 0) or (po1^ = #0);
  text:= po1;
 end;
end;

procedure getlist(var text: pchar);
var
 level: integer;
 po1: pchar;
begin
 if text <> nil then begin
  level:= 0;
  po1:= text;
  repeat
   case po1^ of
    '[': begin
     inc(level);
    end;
    ']': begin
     dec(level);
    end;
    '"': begin
     getcstring(po1);
     dec(po1);
    end;
    '{': begin
     gettuple(po1);
     dec(po1);
    end;
   end;
   inc(po1);
  until (level <= 0) or (po1^ = #0);
  text:= po1;
 end;
end;

procedure decoderesult(const noname: boolean; var text: pchar; out resultinfo: resultinfoty);

var
 po1,po2: pchar;
begin
 if noname then begin
  po1:= text;
 end
 else begin
  po1:= strscan(text,'=');
 end;
 with resultinfo do begin
  if po1 = nil then begin
   variablename:= text;
   value:= '';
  end
  else begin
   variablename:= psubstr(text,po1);
   if not noname then begin
    inc(po1);
   end;
   case po1^ of
    '"': begin
     value:= cstringtostringvar(po1);
     valuekind:= vk_value;
    end;
    '{': begin
     po2:= po1;
     gettuple(po1);
     value:= psubstr(po2+1,po1-1);
     valuekind:= vk_tuple;
    end;
    '[': begin
     po2:= po1;
     getlist(po1);
     value:= psubstr(po2+1,po1-1);
     valuekind:= vk_list;
    end;
   end;
  end;
 end;
 text:= po1;
end;

{ tgdbmi }

constructor tgdbmi.create(aowner: tcomponent);
begin
 fpointersize:= sizeof(pointer);
 fgdb:= invalidprochandle;
 fguiintf:= true;
 fsourcefiles:= thashedmsestrings.create;
 {$ifdef UNIX}
 ftargetterminal:= tpseudoterminal.create;
 ftargetterminal.input.oninputavailable:= {$ifdef FPC}@{$endif}targetfrom;
 {$endif}
 inherited;
end;

destructor tgdbmi.destroy;
begin
 closegdb;
 inherited;
 fsourcefiles.free;
 {$ifdef UNIX}
 ftargetterminal.free;
 {$endif}
end;

procedure tgdbmi.resetexec;
begin
 fstate:= fstate - [gs_internalrunning,gs_running,gs_execloaded,
                          gs_attached,gs_started,gs_detached,
                          gs_interrupted,gs_restarted];
 {$ifdef mswindows}
 finterruptthreadid:= 0;
 {$endif}
 finterruptcount:= 0;
 fprocid:= 0;
 flastbreakpoint:= 0;
 ftargetdebugbegin:= 0;
 ftargetdebugend:= 0;
end;

procedure tgdbmi.closegdb;
begin
 if not (gs_closing in fstate) then begin
  include(fstate,gs_closing);
  abort;
  if fgdbfrom <> nil then begin
   fgdbfrom.terminate;
  end;
  if fgdberror <> nil then begin
   fgdberror.terminate;
  end;
  if fgdb <> invalidprochandle then begin
//   try
//    abort;
//   except
//   end;
   killprocess(fgdb);
   fgdb:= invalidprochandle;
  end;
  fgdbto.free;
  fgdbto:= nil;
  fgdbfrom.free;
  fgdbfrom:= nil;
  fgdberror.free;
  fgdberror:= nil;
  fsourcefiles.clear;
  fsourcefiledirs:= nil;
  resetexec;
  exclude(fstate,gs_closing);
 end;
end;

procedure tgdbmi.startgdb(commandline: string);
{$ifdef UNIX}
var
 bo1: boolean;
 str1: string;
{$endif}
begin
 closegdb;
 fgdbto:= tpipewriter.create;
 fgdbfrom:= tpipereader.create;
 fgdberror:= tpipereader.create;
 fgdbfrom.oninputavailable:= {$ifdef FPC}@{$endif}gdbfrom;
 fgdberror.oninputavailable:= {$ifdef FPC}@{$endif}gdberror;
 fconsolesequence:= 0;
 frunsequence:= 0;
 fsequence:= 1;
 flastbreakpoint:= 0;
 fgdb:= execmse2(commandline+' --interpreter=mi --nx',fgdbto,fgdbfrom,fgdberror,
                false,-1,true,true,true);
 if fgdb <> invalidprochandle then begin
  clicommand('set breakpoint pending on');
  clicommand('set height 0');
  clicommand('set width 0');
  {$ifdef UNIX}
  bo1:= true;  
  if synccommand('-gdb-show inferior-tty') = gdb_ok then begin
   if getstringvalue(fsyncvalues,'value',str1) and (str1 <> '') then begin
    bo1:= false;
   end;
  end;
  if bo1 then begin
   clicommand('tty '+ftargetterminal.devicename);
  end;
  {$endif}
 end;
end;

function tgdbmi.getrunning: boolean;
begin
 result:= gs_running in fstate;
end;

function tgdbmi.getexecloaded: boolean;
begin
 result:= gs_execloaded in fstate;
end;

function tgdbmi.getattached: boolean;
begin
 result:= gs_attached in fstate;
end;

procedure tgdbmi.debugbegin; //calls GUI_DEBUGBEGIN in target
begin
 if ftargetdebugbegin <> 0 then begin
  clicommand('call '+inttostr(ftargetdebugbegin)+'()');
 end;
end;

procedure tgdbmi.debugend;   //calls GUI_DEBUGEND in target
begin
 if ftargetdebugend <> 0 then begin
  clicommand('call '+inttostr(ftargetdebugend)+'()');
 end;
end;

function tgdbmi.active: boolean;
begin
 result:= fgdb <> invalidprochandle;
end;

procedure tgdbmi.setstoponexception(const avalue: boolean);
begin
 if fstoponexception <> avalue then begin
  if gs_internalrunning in fstate then begin
   raise exception.Create('Target running!');
  end;
  if fexceptionbkpt >= 0 then begin
   breakenable(fexceptionbkpt,avalue);
   fstoponexception:= avalue;
  end;
 end;
end;

procedure tgdbmi.setignoreexceptionclasses(const avalue: stringarty);
var
 int1: integer;
begin
 setlength(fignoreexceptionclasses,length(avalue));
 for int1:= 0 to high(avalue) do begin
  fignoreexceptionclasses[int1]:= uppercase(avalue[int1]);
 end;
end;

procedure tgdbmi.checkactive;
begin
 if not active then begin
  raise exception.Create('GDB not active!');
 end;
end;

procedure tgdbmi.consoleoutput(const text: string);
begin
// write(text);
end;

procedure tgdbmi.targetoutput(const text: string);
var
 ev: tgdbevent;
begin
 if assigned(fonevent) then begin
  ev:= tgdbevent.create(ek_none,ievent(self));
  ev.eventkind:= gek_targetoutput;
  setlength(ev.values,1);
  ev.values[0].value:= text;
  application.postevent(ev);
 end;
end;

procedure tgdbmi.logoutput(const text: string);
begin
 flogtext:= text;
// consoleoutput(text);
end;

function tgdbmi.getprocid(var aprocid: longword): boolean;
var
 ar1,ar2: stringarty;
 int1: integer;
 str1: string;
begin
 result:= false;
 ar2:= nil;
 if getcliresult('info program',ar1) = gdb_ok then begin
  for int1:= 0 to high(ar1) do begin
   if (pos('child thread',ar1[int1]) > 0) or 
       (pos('attached thread',ar1[int1]) > 0) then begin
    splitstring(ar1[int1],ar2,' ');
    if high(ar2) > 0 then begin
     ar1:= nil;
     splitstring(ar2[high(ar2)],ar1,'.');
     if high(ar1) > 1 then begin
      try
       aprocid:= strtointvalue(ar1[0]);
       result:= true;
      except
      end;
     end;
    end;
    break;
   end
   else begin
    if (pos('child Thread',ar1[int1]) > 0) or
        (pos('attached Thread',ar1[int1]) > 0) then begin
     splitstring(ar1[int1],ar2,' ');
     if high(ar2) > 0 then begin
      str1:= ar2[high(ar2)];
      if (length(str1) > 2) and (str1[length(str1)-1] = ')') then begin
       str1:= copy(str1,1,length(str1) - 2);
       try
        aprocid:= strtointvalue(str1);
        result:= true;
       except
       end;
      end;
     end;
     break;
    end
    else begin
     if (pos('child process',ar1[int1]) > 0) or 
             (pos('attached process',ar1[int1]) > 0) then begin
      splitstring(ar1[int1],ar2,' ');
      if high(ar2) > 0 then begin
       str1:= ar2[high(ar2)];
       if (length(str1) > 1) and (str1[length(str1)] = '.') then begin
        str1:= copy(str1,1,length(str1) - 1);
        try
         aprocid:= strtointvalue(str1);
         result:= true;
        except
        end;
       end;
      end;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function tgdbmi.clearenvvars: gdbresultty;
var
 int1: integer;
begin
 result:= gdb_ok;
 if active then begin
  for int1:= 0 to high(fenvvars) do begin
   result:= clicommand('unset environement '+fenvvars[int1].a);
   if result <> gdb_ok then begin
    break;
   end;
  end;
 end;
 fenvvars:= nil;
end;

function tgdbmi.setenv(const aname,avalue: string): gdbresultty;
begin
 result:= synccommand('-gdb-set environment '+aname+'='+avalue);
end;

function tgdbmi.setenvvar(const aname,avalue: string): gdbresultty;
var
 int1: integer;
begin
 result:= gdb_ok;
 if active then begin
  setenv(aname,avalue);
 end;
 if result = gdb_ok then begin
  for int1:= 0 to high(fenvvars) do begin
   if aname = fenvvars[int1].a then begin
    fenvvars[int1].b:= avalue;
    exit;
   end;
  end;
  setlength(fenvvars,high(fenvvars)+2);
  with fenvvars[high(fenvvars)] do begin
   a:= aname;
   b:= avalue;
  end;
 end;
end;

function tgdbmi.getshortstring(const address: string; out avalue: string): boolean;
var
 str1: string;
 int1: ptrint;
 ar1: bytearty;
begin
 avalue:= '';
 result:= evaluateexpression(address,str1) = gdb_ok;
 if result then begin
  try
   int1:= strtoint(str1);
   if readmemorybytes(int1,1,ar1) = gdb_ok then begin
    if ar1[0] <> 0 then begin
     if readmemorybytes(int1+1,ar1[0],ar1) = gdb_ok then begin
      setlength(avalue,length(ar1));
      move(ar1[0],avalue[1],length(avalue));
      result:= true;
     end;
    end;
   end;
  except
  end;
 end;
end;

procedure tgdbmi.receiveevent(const event: tobjectevent);
var
 stopinfo: stopinfoty;
 bo1: boolean;
 int1: integer;
 str1,str2: string;
 {$ifdef mswindows}
 threadids: integerarty;
 mstr1: filenamety;
 {$endif}

begin
 if event is tgdbevent then begin
  finalize(stopinfo);
  fillchar(stopinfo,sizeof(stopinfo),0);
  with tgdbevent(event) do begin
   case eventkind of
    gek_stopped: begin
     exclude(fstate,gs_running);
     {$ifdef mswindows}
     if finterruptthreadid <> 0 then begin
      if getthreadidlist(threadids) = gdb_ok then begin
       if high(threadids) > 0 then begin
        if threadselect(threadids[1],mstr1,int1) = gdb_ok then begin
         setlength(values,3);
         with values[0] do begin
          variablename:= 'reason';
          valuekind:= vk_value;
          value:= stopreasons[sr_signal_received];
         end;
         with values[1] do begin
          variablename:= 'signal-name';
          valuekind:= vk_value;
          value:= 'SIGTRAP';
         end;
         with values[2] do begin
          variablename:= 'thread-id';
          valuekind:= vk_value;
          value:= inttostr(threadids[1]);
         end;
         if gettuplestring(fsyncvalues,'frame',str1) then begin
          setlength(values,4);
          with values[3] do begin
           variablename:= 'frame';
           valuekind:= vk_tuple;
           value:= str1;
          end;
         end;
        end;
       end;
      end;
      finterruptthreadid:= 0;
     end;
     {$endif mswindows}
     bo1:= getstopinfo(values,stopinfo);
     if not bo1 then begin
      stopinfo.messagetext:= 'Stop error: ' + stopinfo.messagetext;
     end
     else begin
      if (stopinfo.reason = sr_breakpoint_hit) and 
       (stopinfo.bkptno = fexceptionbkpt) then begin
       if getshortstring('($eax^+12)^',str1) then begin
        str2:= uppercase(str1);
        bo1:= false;
        for int1:= 0 to high(fignoreexceptionclasses) do begin
         if str2 = fignoreexceptionclasses[int1] then begin
          bo1:= true;
          break;
         end;
        end;
        if bo1 then begin
         fstate:= fstate + [gs_restarted,gs_running];
         continue;
         stopinfo.reason:= sr_none;
        end
        else begin
         stopinfo.messagetext:= 'Exception '+str1+'.';
         stopinfo.reason:= sr_exception;
        end;
       end;
      end;
      if stopinfo.reason in [sr_exited,sr_exited_normally] then begin
       exclude(fstate,gs_started);
      end;
      if stopinfo.reason = sr_startup then begin
       fprocid:= 0;
       getprocid(fprocid);
       {$ifdef UNIX}
       ftargetterminal.restart;
       {$endif}
      end;
     end;
    end;
    gek_running: begin
     include(fstate,gs_running);
    end;
    gek_error,gek_writeerror: begin
     getstringvalue(values,'msg',stopinfo.messagetext);
    end;
   end;
   if assigned(fonevent) and 
     not((eventkind = gek_stopped) and (stopinfo.reason = sr_none)) then begin
    fonevent(self,eventkind,values,stopinfo);
   end;
   if (eventkind = gek_error) and assigned(fonerror) then begin
    fonerror(self,eventkind,values,stopinfo);
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tgdbmi.doevent(const token: cardinal; const eventkind: gdbeventkindty;
                                   const values: resultinfoarty);
var
 ev: tgdbevent;
begin
 if token = fsyncsequence then begin
  fsyncvalues:= values;
  fsynceventkind:= eventkind;
  include(fstate,gs_syncack);
  exclude(fstate,gs_syncget);
 end;
 if not (gs_detached in fstate) then begin
  if eventkind = gek_running then begin
   frunsequence:= token;
   fstate:= fstate + [gs_internalrunning,gs_started];
  end;
  if eventkind = gek_stopped then begin
   exclude(fstate,gs_internalrunning);
  end;
  if (eventkind = gek_error) and (token = frunsequence) then begin
   doevent(token,gek_stopped,values);
  end
  else begin
   if assigned(fonevent) and (eventkind = gek_writeerror) or
      not ((eventkind = gek_stopped) and (gs_interrupted in fstate)) and
      not ((eventkind = gek_running) and (gs_restarted in fstate)) and
      not ((eventkind = gek_error) and (fsyncsequence <> 0) and
           (integer(token-fsyncsequence) < 0)) and
      ((token <> fsyncsequence) or (eventkind = gek_running) or
                                        (eventkind = gek_stopped)) then begin
    ev:= tgdbevent.create(ek_none,ievent(self));
    ev.eventkind:= eventkind;
    ev.values:= copy(values);
    application.postevent(ev);
   end;
   if eventkind = gek_running then begin
    exclude(fstate,gs_restarted);
   end;
  end;
 end;
end;

procedure tgdbmi.sequenceend;
begin
{
 if fsequence = 1 then begin //startup
  consoleoutput('(gdb)');
 end;
}
end;

function tgdbmi.decodelist(const noname: boolean; const inp: string;
                    var value: resultinfoarty): boolean;
var
 po1: pchar;
 int1: integer;
 str1: string;
begin
 result:= true;
 value:= nil;
 if (pointer(inp) <> nil) then begin
  str1:= inp; //avoid stringrelease
  po1:= pchar(str1);
  int1:= 0;
  while true do begin
   if int1 > high(value) then begin
    setlength(value,int1+16);
   end;
   decoderesult(noname,po1,value[int1]);
   inc(int1);
   if (po1 = nil) or (po1^ <> ',') then begin
    break;
   end;
   inc(po1);
  end;
  setlength(value,int1);
  str1:= ''; //avoid stringrelease
 end;
end;

procedure tgdbmi.interpret(const line: string);

var
 po1,po2: pchar;
 token: cardinal;
 ch1: char;
 recordclass: recordclassty;
 isconsole: boolean;
 resultar: resultinfoarty;

 function getrecordinfo(start,stop: recordclassty): boolean;
 var
  int1: integer;
 begin
  result:= false;
  int1:= length(resultar);
  for start:= start to stop do begin
   if startsstr(pchar(recordclassnames[start]),po2) then begin
    po2:= po2 + length(recordclassnames[start]);
    recordclass:= start;
    result:= true;
    while (po2 <> nil) and (po2^ = ',') do begin
     if int1 > high(resultar) then begin
      setlength(resultar,2*high(resultar)+8);
     end;
     inc(po2);
     decoderesult(false,po2,resultar[int1]);
     inc(int1);
    end;
    break;
   end;
  end;
  setlength(resultar,int1);
 end;

begin
 resultar:= nil;
 po1:= pchar(line);
 po2:= po1;
 while (po2^ >= '0') and (po2^ <= '9') do begin
  inc(po2);
 end;
 if po2 <> po1 then begin
  token:= strtoint(psubstr(po1,po2));
 end
 else begin
  token:= 0;
 end;
 isconsole:= token = fconsolesequence;
 if isconsole then begin
  fconsolesequence:= 0;
 end;
 ch1:= po2^;
 inc(po2);
 try
  case ch1 of
   '~': begin
    if gs_clicommand in fstate then begin
     if gs_clilist in fstate then begin
      setlength(fclivaluelist,high(fclivaluelist)+2);
      fclivaluelist[high(fclivaluelist)]:= cstringtostring(po2);
     end
     else begin
      fclivalues:= fclivalues + cstringtostring(po2);
     end;
    end
    else begin
     consoleoutput(cstringtostring(po2));
    end;
   end;
   '@': targetoutput(cstringtostring(po2));
   '&': logoutput(cstringtostring(po2));
   '^': begin    //result
    if getrecordinfo(low(resultclassty),high(resultclassty)) then begin
     case recordclass of
      rec_running: begin
       doevent(token,gek_running,resultar);
      end;
      rec_done: begin
       if isconsole then begin
        consoleoutput('(gdb)');
       end;
       doevent(token,gek_done,resultar);
      end;
      rec_error: begin
       if isconsole then begin
        if high(resultar) >= 0 then begin
         consoleoutput(resultar[0].value+#$0a'(gdb)');
        end;
       end;
       doevent(token,gek_error,resultar);
      end;
     end;
    end;
   end;
   '*','+','=': begin
    if getrecordinfo(low(asyncclassty),high(asyncclassty)) then begin
     case recordclass of
      rec_stopped: begin
       doevent(token,gek_stopped,resultar);
      end;
     end;
    end;
   end;
   '(': begin
    if startsstr(pchar('gdb)'),po2) then begin
     sequenceend;
    end;
   end;
   else begin
    if running then begin
     targetoutput(line+lineend);
    end;
   end;
  end;
 except
 end;
end;

procedure tgdbmi.gdberror(const sender: tpipereader);
var
 str1: string;
begin
 if fgdberror.eof then begin
  exit;
 end;
 str1:= fgdberror.readdatastring;
 targetoutput(str1);
// writedebug(str1);
end;

procedure tgdbmi.gdbfrom(const sender: tpipereader);
var
 str1,str2: string;
 bo1: boolean;
begin
 if fgdbfrom.eof then begin
  exit;
 end;
 bo1:= false; //compiler warning
 repeat
  if gs_syncget in fstate then begin
   bo1:= fgdbfrom.readstrln(str1);
  end
  else begin
   str1:= '';
   while true do begin
    bo1:= fgdbfrom.readuln(str2);
    str1:= str1 + str2;
    if bo1 or (str2 = '') then begin
     break;
    end;
    sleep(0);
   end;
  end;
  if bo1 then begin
   interpret(str1);
  end
  else begin
   if str1 <> '' then begin
    targetoutput(str1);
   end;
  end;
 until not bo1;
end;

{$ifdef UNIX}
procedure tgdbmi.targetfrom(const sender: tpipereader);
begin
 if not sender.eof then begin
  targetoutput(sender.readdatastring);
 end;
end;
{$endif}

function tgdbmi.internalcommand(acommand: string): boolean;
var
 ar1: resultinfoarty;
begin
 result:= false;
 checkactive;
 fgdbfrom.responseflag:= false;
 try
  fgdbto.writeln(inttostr(fsequence)+acommand);
  result:= true;
 except
  closegdb;
  setlength(ar1,1);
  with ar1[0] do begin
   variablename:= 'msg';
   valuekind:= vk_value;
   value:= 'Can not write to gdb.';
  end;
  doevent(fsequence,gek_writeerror,ar1);
//  raise;
 end;
 inc(fsequence);
 if fsequence = 0 then begin
  inc(fsequence);
 end;
end;

procedure tgdbmi.consolecommand(acommand: string);
begin
 internalcommand(acommand);
 fconsolesequence:= fsequence;
end;

function tgdbmi.synccommand(const acommand: string; 
                     atimeout: integer = defaultsynctimeout): gdbresultty;
var
 timestamp: cardinal;
 int1: integer;

begin
 result:= gdb_timeout;
 interrupttarget;
 setlength(fsyncvalues,0);
 fsyncsequence:= fsequence;
 exclude(fstate,gs_syncack);
 include(fstate,gs_syncget);
 if not internalcommand(acommand) then begin
  result:= gdb_writeerror;
  exit;
 end;
 timestamp:= timestep(atimeout); //max delay
 int1:= application.unlockall;
 try
  while not timeout(timestamp) do begin
   if not (gs_syncack in fstate) then begin
    fgdbfrom.waitforresponse(100000,true);
   end
   else begin
    if fsynceventkind = gek_error then begin
     if getstringvalue(fsyncvalues,'msg',ferrormessage) then begin
      result:= gdb_message;
     end
     else begin
      result:= gdb_error;
     end;
    end
    else begin
     result:= gdb_ok;
    end;
    break;
   end;
  end;
 finally
  application.relockall(int1);
  exclude(fstate,gs_syncget);
  fsyncsequence:= 0;
  restarttarget;
 end;
end;

function tgdbmi.geterrormessage(const aresult: gdbresultty): string;
begin
 if aresult = gdb_message then begin
  result:= errormessage;
 end
 else begin
  if (aresult < low(gdbresultty)) or (aresult > high(gdbresultty)) then begin
   result:= 'GDB Error ' + inttostr(ord(aresult));
  end
  else begin
   result:= gdberrortexts[aresult];
  end;
 end;
end;

function tgdbmi.micommand(const command: string; out values: resultinfoarty): gdbresultty;
                  //values = nil on timeout
begin
 result:= synccommand('-'+command);
 values:= fsyncvalues;
end;

function tgdbmi.togdbfilepath(const filename: filenamety): filenamety;
begin
 result:= quotefilename(tosysfilepath(filepath(filename)));
 {$ifdef mswindows}
 replacechar1(result,msechar('\'),msechar('/'));
 {$endif}
end;

function tgdbmi.fileexec(const filename: filenamety): gdbresultty;
begin
 abort;
 resetexec;
 if filename = '' then begin
  breakdelete(0);
  result:= synccommand('-file-exec-and-symbols');
 end
 else begin
  result:= synccommand('-file-exec-and-symbols '+togdbfilepath(filename),10000000);
  updatebit({$ifdef FPC}longword{$else}word{$endif}(fstate),
                 ord(gs_execloaded),result = gdb_ok);
  if result = gdb_ok then begin
   initinternalbkpts;
   initproginfo;
  end;
 end;
end;

function tgdbmi.attach(const procid: longword; out info: stopinfoty): gdbresultty;
var
 frames1: frameinfoarty;
begin
 abort;
 resetexec;
 result:= clicommand('attach '+inttostr(procid),false,10000000);
 finalize(info);
 fillchar(info,sizeof(info),0);
 info.reason:= sr_error;
 if result = gdb_ok then begin
  if getprocid(fprocid) and (fprocid = procid) then begin
   result:= stacklistframes(frames1,0,1);
   if (result = gdb_ok) or (result = gdb_message) then begin
    if result = gdb_message then begin
     info.messagetext:= errormessage;
     result:= gdb_ok;
    end
    else begin
     info.reason:= sr_startup;
     fstate:= fstate + [gs_execloaded,gs_attached,gs_started];
     with frames1[0] do begin
      info.filename:= filename;
      info.line:= line;
      info.messagetext:= 'Attached to process '+inttostr(procid) + ' File: '+
       filename+':'+inttostr(line)+' Function: '+func;
     end;
    end;
   end;
   initinternalbkpts;
   initproginfo;
  end
  else begin
   info.messagetext:= 'Can not Attach to process '+inttostr(procid);
  end;
 end;
 if result <> gdb_ok then begin
  if result = gdb_message then begin
   info.messagetext:= errormessage;
  end
  else begin
   info.messagetext:= gdberrortexts[result];
  end;
 end;
end;

function tgdbmi.detach: gdbresultty;
var
 ev: tgdbevent;
begin
 result:= synccommand('target-detach');
 if result = gdb_ok then begin
  ev:= tgdbevent.create(ek_none,ievent(self));
  ev.eventkind:= gek_stopped;
  setlength(ev.values,1);
  with ev.values[0] do begin
   variablename:= 'reason';
   valuekind:= vk_value;
   value:= 'detached';
  end;
  resetexec;
  include(fstate,gs_detached);
  application.postevent(ev);
 end;
end;

procedure tgdbmi.run;
var
 int1: integer;
 ar1,ar2: stringarty;
 ca1: cardinal;
 str1: string;
begin
 str1:= '';
 if getcliresult('info file',ar1) = gdb_ok then begin
  for int1:= 0 to high(ar1) do begin
   if startsstr('Entry point',ar1[int1]) then begin
    ar2:= nil;
    splitstring(ar1[int1],ar2,' ');
    if high(ar2) = 2 then begin
     str1:= ar2[2];
    end;
    break;
   end;
  end;
 end;
 if str1 <> '' then begin
  try
   ca1:= strtointvalue(str1);
   {$ifdef UNIX}
   ca1:= ca1+1; // todo: breakpoint at entrypoint does not work sometimes?
   {$endif}
   if synccommand('-break-insert -t *'+hextocstr(ca1,8)) <> gdb_ok then begin

    str1:= '';
   end;
  except
   str1:= '';
  end;
 end;
 if str1 = '' then begin
  synccommand('-break-insert -t main');
 end;
 synccommand('-exec-arguments '+ fprogparameters);
 synccommand('-environment-cd '+ tosysfilepath(filepath(fworkingdirectory)));
 for int1:= 0 to high(fenvvars) do begin
  with fenvvars[int1] do begin
   setenv(a,b);
  end;
 end;
 {$ifdef mswindows}
 if fnewconsole then begin
  synccommand('-gdb-set new-console on');
 end
 else begin
  synccommand('-gdb-set new-console off');
 end;
 {$endif}
 internalcommand('-exec-run');
end;

procedure tgdbmi.continue;
begin
 debugend;
 internalcommand('-exec-continue');
end;

procedure tgdbmi.next;
begin
 debugend;
 internalcommand('-exec-next');
end;

procedure tgdbmi.step;
begin
 debugend;
 internalcommand('-exec-step');
end;

procedure tgdbmi.finish;
begin
 debugend;
 internalcommand('-exec-finish');
end;

procedure tgdbmi.nexti;
begin
 debugend;
 internalcommand('-exec-next-instruction');
end;

procedure tgdbmi.stepi;
begin
 debugend;
 internalcommand('-exec-step-instruction');
end;

procedure tgdbmi.interrupt;
{$ifdef mswindows}
type
 createremotethreadty = function(hProcess: THandle; lpThreadAttributes: Pointer;
         dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine;
         lpParameter: Pointer; dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall;
var
 prochandle,modhandle,threadhandle: thandle;
 debugbreakaddr: pointer;
 createremotethreadaddr: createremotethreadty;
 bo1: boolean;
{$endif mswindows}
begin
// internalcommand('-exec-interrupt');
 if fprocid <> 0 then begin
 {$ifdef mswindows}
  prochandle:= openprocess(
   PROCESS_CREATE_THREAD or PROCESS_QUERY_INFORMATION or PROCESS_VM_OPERATION or
   PROCESS_VM_WRITE or PROCESS_VM_READ, False, fprocid);
  if prochandle <> 0 then begin
   bo1:= false;
   modhandle:= GetModuleHandle(kernel32);
   if modhandle <> 0 then begin
    debugbreakaddr:= windows.getprocaddress(modhandle,'DebugBreak');
    if debugbreakaddr <> nil then begin
     {$ifdef FPC}pointer(createremotethreadaddr){$else}
     createremotethreadaddr{$endif}:= windows.GetProcAddress(modhandle, 'CreateRemoteThread');
     if assigned(createremotethreadaddr) then begin
      threadhandle:= createremotethreadaddr(prochandle, nil, 0, debugbreakaddr,
                            nil, 0, finterruptthreadid);
      if threadhandle <> 0 then begin
       closehandle(threadhandle);
       bo1:= true;
      end;
     end;
    end;
   end;
   closehandle(prochandle);
   if not bo1 then begin
    GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, fprocid);
     //for win95
   end;
  end;
 {$else}
   kill(fprocid,sigint);
 {$endif !mswindows}
 end;
end;

function tgdbmi.interrupttarget: gdbresultty; //stop for breakpointsetting
var
 timestamp: cardinal;
 bo1: boolean;
begin
 result:= gdb_ok;
 inc(finterruptcount);
 if finterruptcount = 1 then begin
  timestamp:= timestep(1000000);
  if (gs_internalrunning in fstate) then begin
   include(fstate,gs_interrupted);
   interrupt;
   bo1:= application.unlock;
   repeat
    sleep(0);
   until not (gs_internalrunning in fstate) or timeout(timestamp);
   if bo1 then begin
    application.lock;
   end;
   if (gs_internalrunning in fstate) then begin
    exclude(fstate,gs_interrupted);
    dec(finterruptcount);
    result:= gdb_timeout;
   end;
  end;
 end;
end;

function tgdbmi.restarttarget: gdbresultty;
begin
 if finterruptcount > 0 then begin
  dec(finterruptcount);
  if finterruptcount = 0 then begin
   if gs_interrupted in fstate then begin
    exclude(fstate,gs_interrupted);
    include(fstate,gs_restarted);
    continue;
   end;
  end;
 end;
 result:= gdb_ok;
end;

procedure tgdbmi.abort;
begin
// internalcommand('-exec-abort');
 if started and (interrupttarget = gdb_ok) then begin
  exclude(fstate,gs_interrupted);
  clicommand('kill');
  finterruptcount:= 0;
 end;
end;

procedure tgdbmi.initinternalbkpts;
begin
 fexceptionbkpt:= breakinsert('FPC_RAISEEXCEPTION');
 if not fstoponexception and (fexceptionbkpt > 0) then begin
  breakenable(fexceptionbkpt,false); //disable breakpoint
 end;
end;

procedure tgdbmi.initproginfo;
begin
 getprocaddress('MSEGUIINTF_GUI_DEBUGBEGIN',ftargetdebugbegin);
 getprocaddress('MSEGUIINTF_GUI_DEBUGEND',ftargetdebugend);
end;

function tgdbmi.getbkptid: integer;
var
 tup1: resultinfoarty;
begin
 result:= -1;
 if gettuplevalue(fsyncvalues,'bkpt',tup1) then begin
  getintegervalue(tup1,'number',result);
 end;
 if result <> -1 then begin
  flastbreakpoint:= result;
 end;
end;

function tgdbmi.getwptid: integer;
var
 tup1: resultinfoarty;
begin
 result:= -1;
 if gettuplevalue(fsyncvalues,'wpt',tup1) or
        gettuplevalue(fsyncvalues,'hw-awpt',tup1) or
        gettuplevalue(fsyncvalues,'hw-rwpt',tup1) then begin
  getintegervalue(tup1,'number',result);
 end;
end;

function tgdbmi.handle(const signame: string; const aflags: sigflagsty): gdbresultty;
var
 str1: string;
begin
 if sfl_stop in aflags then begin
  str1:= 'stop';
 end
 else begin
  str1:= 'noprint';
 end;
 if sfl_handle in aflags then begin
  str1:= str1 + ' nopass';
 end
 else begin
  str1:= str1 + ' pass';
 end;
 result:= clicommand('handle '+signame+' '+str1);
end;

function tgdbmi.breakinsert(var info: breakpointinfoty): gdbresultty;
var
 str1: string;
begin
 with info do begin
  interrupttarget;
  flogtext:= '';
  str1:= filename(path)+':'+inttostr(line);
  result:= synccommand('-break-insert '+ str1);
  if (result = gdb_ok) or (result = gdb_message) then begin
   if (result = gdb_ok) and (flogtext <> '') or (result = gdb_message) then begin
    bkptno:= -1;
    result:= clicommand('break '+str1);
    inc(flastbreakpoint);
    bkptno:= flastbreakpoint;
    {
    ar1:= splitstring(fclivalues,' ');
    if (high(ar1) > 0) and (ar1[0] = 'Breakpoint') then begin
     try
      bkptno:= strtoint(ar1[1]);
     except
     end;
    end;
    }
   end
   else begin
    bkptno:= getbkptid;
   end;
   if bkptno < 0 then begin
    result:= gdb_error;
   end
   else begin
    if not bkpton then begin
     result:= breakenable(bkptno,false);
    end;
    if (result = gdb_ok) and (ignore > 0) then begin
     result:= breakafter(bkptno,ignore);
    end;
    if (result = gdb_ok) and (condition <> '') then begin
     result:= breakcondition(bkptno,condition);
     if result = gdb_message then begin
      conditionmessage:= errormessage;
     end;
    end;
   end;
  end
  else begin
   bkptno:= -1;
  end;
  restarttarget;
 end;
end;

function tgdbmi.breakinsert(const funcname: string): integer;
begin
 if synccommand('-break-insert '+funcname) <> gdb_ok then begin
  result:= -1;
 end
 else begin
  result:= getbkptid;
 end;
end;

function tgdbmi.watchinsert(var info: watchpointinfoty): gdbresultty;
var
 str1: string;
begin
 with info do begin
  case kind of
   wpk_readwrite: str1:= ' -a ';
   wpk_read: str1:= ' -r ';
   else str1:= ' ';
  end;
  result:= synccommand('-break-watch' + str1 + expression);
  if result = gdb_ok then begin
   wptno:= getwptid;
   if wptno < 0 then begin
    result:= gdb_error;
   end
   else begin
    if (result = gdb_ok) and (ignore > 0) then begin
     result:= breakafter(wptno,ignore);
    end;
    if (result = gdb_ok) and (condition <> '') then begin
     result:= breakcondition(wptno,condition);
     if result = gdb_message then begin
      conditionmessage:= errormessage;
     end;
    end;
   end;
   {
    if not bkpton then begin
     result:= breakenable(bkptno,false);
    end;
    if (result = gdb_ok) and (ignore > 0) then begin
     result:= breakafter(bkptno,ignore);
    end;
    if (result = gdb_ok) and (condition <> '') then begin
     result:= breakcondition(bkptno,condition);
     if result = gdb_message then begin
      conditionmessage:= errormessage;
     end;
    end;
   end;
    }
  end
  else begin
   wptno:= -1;
  end;
 end;
end;

function tgdbmi.breaklist(var list: breakpointinfoarty; full: boolean): gdbresultty;
var
 tup1: resultinfoarty;
 ar1: resultinfoarty;
 int1: integer;
 filename: string;
begin
 result:= synccommand('-break-list');
 if result = gdb_ok then begin
  result:= gdb_error;
  if gettuplevalue(fsyncvalues,'BreakpointTable',tup1) then begin
   if getarrayvalue(tup1,'body',true,ar1) then begin
    setlength(list,length(ar1));
    for int1:= 0 to high(ar1) do begin
     if gettuplevalue(ar1[int1],tup1) then begin
      with list[int1] do begin
       getintegervalue(tup1,'number',bkptno);
       getintegervalue(tup1,'times',passcount);
       if full then begin
        getintegervalue(tup1,'line',line);
        dec(line);
        getstringvalue(tup1,'file',filename);
        path:= filename;
        getbooleanvalue(tup1,'enabled',bkpton);
       end;
      end;
     end;
    end;
    result:= gdb_ok;
   end;
  end;
 end;
end;

function tgdbmi.breakdelete(bkptnum: integer): gdbresultty;
begin
 if bkptnum = 0 then begin
  result:= synccommand('-break-delete');
  initinternalbkpts;
 end
 else begin
  result:= synccommand('-break-delete '+inttostr(bkptnum));
 end;
end;

function tgdbmi.breakenable(bkptnum: integer; value: boolean): gdbresultty; //bkptnum = 0 -> all
begin
 if value then begin
  if bkptnum = 0 then begin
   result:= synccommand('-break-enable');
  end
  else begin
   result:= synccommand('-break-enable '+inttostr(bkptnum));
  end;
 end
 else begin
  if bkptnum = 0 then begin
   result:= synccommand('-break-disable');
  end
  else begin
   result:= synccommand('-break-disable '+inttostr(bkptnum));
  end;
 end;
end;

function tgdbmi.breakafter(bkptnum: integer; const passcount: integer): gdbresultty;
begin
 result:= synccommand('-break-after '+inttostr(bkptnum)+' '+inttostr(passcount));
end;

function tgdbmi.breakcondition(bkptnum: integer;
                     const condition: string): gdbresultty;
begin
 result:= synccommand('-break-condition '+inttostr(bkptnum)+' '+condition);
end;

function tgdbmi.getvalueindex(const response: resultinfoarty;
                       const aname: string): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(response) do begin
  if response[int1].variablename = aname then begin
   result:= int1;
   break;
  end;
 end;
end;

function tgdbmi.getstringvalue(const response: resultinfoarty; const aname: string;
                 var avalue: string): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if int1 >= 0 then begin
  with response[int1] do begin
   if valuekind = vk_value then begin
    avalue:= value;
    result:= true;
   end;
  end;
 end;
end;

function tgdbmi.getstringvalue(const response: resultinfoty; const aname: string;
                 var avalue: string): boolean;
var
 ar1: resultinfoarty;
begin
 setlength(ar1,1);
 ar1[0]:= response;
 result:= getstringvalue(ar1,aname,avalue);
end;

function tgdbmi.getptrintvalue(const response: resultinfoarty; const aname: string;
                 var avalue: ptrint): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if int1 >= 0 then begin
  with response[int1] do begin
   if valuekind = vk_value then begin
    try
     if (length(value) > 1) and (value[1] = '0') and (value[2] <> 'x') and
              (value[2] <> 'X') then begin
      avalue:= strtointvalue(value,nb_oct);
     end
     else begin
      avalue:= strtointvalue(value);
     end;
     result:= true;
    except
    end;
   end;
  end;
 end;
end;

function tgdbmi.getintegervalue(const response: resultinfoarty; const aname: string;
                 var avalue: integer): boolean;
var
 ptrint1: ptrint;
begin
 ptrint1:= avalue;
 result:= getptrintvalue(response,aname,ptrint1);
 avalue:= ptrint1;
end;

function tgdbmi.getptrintvalue(const response: resultinfoty; const aname: string;
                 var avalue: ptrint): boolean;

var
 ar1: resultinfoarty;
begin
 setlength(ar1,1);
 ar1[0]:= response;
 result:= getintegervalue(ar1,aname,avalue);
end;

function tgdbmi.getbooleanvalue(const response: resultinfoarty; const aname: string;
                 var avalue: boolean): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if int1 >= 0 then begin
  with response[int1] do begin
   if valuekind = vk_value then begin
    if value = 'y' then begin
     avalue:= true;
     result:= true;
    end
    else begin
     if value = 'n' then begin
      avalue:= false;
      result:= true;
     end;
    end;
   end;
  end;
 end;
end;

function tgdbmi.getintegervalue(const response: resultinfoty; const aname: string;
                 var avalue: integer): boolean;
var
 ptrint1: ptrint;
begin
 ptrint1:= avalue;
 result:= getptrintvalue(response,aname,ptrint1);
 avalue:= ptrint1;
end;

procedure setstringnum(var dataarray; const index: integer; const text: string);
begin
 stringarty(dataarray)[index]:= text;
end;

procedure setbytenum(var dataarray; const index: integer; const text: string);
begin
 bytearty(dataarray)[index]:= strtointvalue(text);
end;

procedure setwordnum(var dataarray; const index: integer; const text: string);
begin
 wordarty(dataarray)[index]:= strtointvalue(text);
end;

procedure setlongwordnum(var dataarray; const index: integer; const text: string);
begin
 longwordarty(dataarray)[index]:= strtointvalue(text);
end;

procedure setstringlen(var dataarray; const len: integer);
begin
 setlength(stringarty(dataarray),len);
end;

procedure setbytelen(var dataarray; const len: integer);
begin
 setlength(bytearty(dataarray),len);
end;

procedure setwordlen(var dataarray; const len: integer);
begin
 setlength(wordarty(dataarray),len);
end;

procedure setlongwordlen(var dataarray; const len: integer);
begin
 setlength(longwordarty(dataarray),len);
end;

function tgdbmi.getnumarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue; setnumproc: setnumprocty; setlenproc: setlenprocty): boolean;
var
 int1: integer;
 po1,po2: pchar;
 str1: string;
begin
 result:= false;
 bytearty(avalue):= nil;
 int1:= getvalueindex(response,aname);
 if int1 >= 0 then begin
  with response[int1] do begin
   if valuekind = vk_list then begin
    if value = '' then begin
     result:= true;
    end
    else begin
     int1:= 0;
     po1:= pointer(value);
     while po1^ <> #0 do begin
      if po1^ <> '"' then begin
       break;
      end;
      inc(po1);
      po2:= po1;
      while (po2^ <> '"') and (po2^ <> #0) do begin
       inc(po2);
      end;
      str1:= psubstr(po1,po2);
      if high(bytearty(avalue)) < int1 then begin
       setlenproc(avalue,int1+16);
      end;
      try
       setnumproc(avalue,int1,str1);
      except
       bytearty(avalue):= nil;
       exit;
      end;
      inc(int1);
      inc(po2);
      if po2^ = ',' then begin
       inc(po2);
      end;
      po1:= po2;
     end;
     setlenproc(avalue,int1);
     result:= true;
    end;
   end;
  end;
 end;
end;

function tgdbmi.getstringarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: stringarty): boolean;
begin
 result:= getnumarrayvalue(response,aname,avalue,{$ifdef FPC}@{$endif}setstringnum,{$ifdef FPC}@{$endif}setstringlen);
end;

function tgdbmi.getbytearrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: bytearty): boolean;
begin
 result:= getnumarrayvalue(response,aname,avalue,{$ifdef FPC}@{$endif}setbytenum,{$ifdef FPC}@{$endif}setbytelen);
end;

function tgdbmi.getwordarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: wordarty): boolean;
begin
 result:= getnumarrayvalue(response,aname,avalue,{$ifdef FPC}@{$endif}setwordnum,
                    {$ifdef FPC}@{$endif}setwordlen);
end;

function tgdbmi.getlongwordarrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: longwordarty): boolean;
begin
 result:= getnumarrayvalue(response,aname,avalue,{$ifdef FPC}@{$endif}setlongwordnum,
                    {$ifdef FPC}@{$endif}setlongwordlen);
end;

function tgdbmi.getenumvalue(const response: resultinfoarty; const aname: string;
                    const enums: array of string; var avalue: integer): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if (int1 >= 0) then begin
  with response[int1] do begin
   if valuekind = vk_value then begin
    for int1:= 0 to high(enums) do begin
     if value = enums[int1] then begin
      avalue:= int1;
      result:= true;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function tgdbmi.gettuplevalue(const response: resultinfoty;
                    var avalue: resultinfoarty): boolean;
begin
 with response do begin
  if valuekind = vk_tuple then begin
   result:= decodelist(false,value,avalue);
  end
  else begin
   result:= false;
  end;
 end;
end;

function tgdbmi.gettuplevalue(const response: resultinfoty; const aname: string;
                    var avalue: resultinfoarty): boolean;
begin
 with response do begin
  if (valuekind = vk_tuple) and (variablename = aname) then begin
   result:= decodelist(false,value,avalue);
  end
  else begin
   result:= false;
  end;
 end;
end;

function tgdbmi.gettuplevalue(const response: resultinfoarty;
  const aname: string; var avalue: resultinfoarty): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if (int1 >= 0) then begin
  result:= gettuplevalue(response[int1],avalue);
 end;
end;

function tgdbmi.gettuplestring(const response: resultinfoarty; const aname: string;
                 var avalue: string): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if (int1 >= 0) then begin
  with response[int1] do begin
   if valuekind = vk_tuple then begin
    avalue:= value;
    result:= true;
   end;
  end;
 end;
end;

function tgdbmi.getarrayvalue(const response: resultinfoarty;
  const aname: string; const hasitemnames: boolean; var avalue: resultinfoarty): boolean;
var
 int1: integer;
begin
 result:= false;
 int1:= getvalueindex(response,aname);
 if (int1 >= 0) then begin
  with response[int1] do begin
   if valuekind = vk_list then begin
    result:= decodelist(not hasitemnames,value,avalue);
   end;
  end;
 end;
end;

function tgdbmi.gettuplearrayvalue(const response: resultinfoarty; const aname: string;
                 var avalue: resultinfoararty): boolean;
var
 int1: integer;
 ar1: resultinfoarty;
begin
 result:= getarrayvalue(response,aname,false,ar1);
 setlength(avalue,length(ar1));
 for int1:= 0 to high(ar1) do begin
  if (ar1[int1].valuekind <> vk_tuple) or
           not gettuplevalue(ar1[int1],avalue[int1]) then begin
   result:= false;
   break;
  end;
 end;
end;

function tgdbmi.getsourcename(var path: filenamety; frame: integer = 0): gdbresultty;
var
 strar1: stringarty;
 int1: integer;
 bo1: boolean;
begin
 path:= '';
 if frame <> 0 then begin
//  result:= synccommand('-stack-select-frame '+inttostr(frame)); //does not change soourcefile
  result:= clicommand('frame ' + inttostr(frame));
  if result <> gdb_ok then begin
   exit;
  end;
 end;
 result:= getcliresult('info source',strar1);
 if frame <> 0 then begin
//  result:= synccommand('-stack-select-frame 0'); //does not change sourcefile
  result:= clicommand('frame 0');
 end;
 if result = gdb_ok then begin
  bo1:= false;
  for int1:= 0 to high(strar1) do begin
//   if startsstr('Located in ',strar1[int1]) then begin
//    path:= copy(strar1[int1],12,bigint);
//    break;
//   end
//   else begin
    if path = '' then begin
     if startsstr('Current source file is ',strar1[int1]) then begin
      path:= copy(strar1[int1],24,bigint);
     end;
    end
    else begin
     if not bo1 and startsstr('Compilation directory is ',strar1[int1]) then begin
      path:= copy(strar1[int1],26,bigint) + path;
      bo1:= true;
     end;
    end;
//   end;
  end;
 end;
end;

function tgdbmi.getprocaddress(const procname: string;
                           out aaddress: ptrint): gdbresultty;
var
 str1: string;
 ar1: stringarty;
 int1: integer;
begin
 aaddress:= 0;
 result:= getcliresultstring('info address ' + procname,str1);
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  ar1:= splitstring(trim(str1),' ',true);
  for int1:= 0 to high(ar1) do begin
   str1:= ar1[int1];
   if startsstr('0x',str1) then begin
    if str1[length(str1)] = '.' then begin
     setlength(str1,length(str1)-1);
    end;
    try
     aaddress:= strtoptrint(str1);
     result:= gdb_ok;
    except
    end;
    break;
   end;
  end;
 end;
end;
                        
function tgdbmi.getstopinfo(const response: resultinfoarty;
                  out info: stopinfoty): boolean;
var
 int1: integer;
 ar1: resultinfoarty;
 frame: resultinfoarty;
 str1: string;
 wstr1: filenamety;
begin
 finalize(info);
 fillchar(info,sizeof(info),0);
 with info do begin
  if getenumvalue(response,'reason',stopreasons,int1) then begin
   result:= true;
   reason:= stopreasonty(int1);
  end
  else begin
   reason:= sr_startup;
   result:= false;
  end;
  if reason = sr_breakpoint_hit then begin
   getintegervalue(response,'bkptno',info.bkptno);
  end;
  if reason = sr_signal_received then begin
   getstringvalue(response,'signal-name',signalname);
   getstringvalue(response,'signal-meaning',signalmeaning);
  end;
  if reason = sr_watchpointtrigger then begin
   if gettuplevalue(response,'wpt',ar1) then begin
    getstringvalue(ar1,'exp',expression);
   end;
   if gettuplevalue(response,'value',ar1) then begin
    getstringvalue(ar1,'old',oldvalue);
    getstringvalue(ar1,'new',newvalue);
   end;
  end;
  if reason = sr_exited then begin
   getintegervalue(response,'exit-code',exitcode);
  end
  else begin
   if not (reason in [sr_exited_normally,sr_detached]) then begin
    result:= getintegervalue(response,'thread-id',threadid);
    if gettuplevalue(response,'frame',frame) then begin
     getstringvalue(frame,'file',str1);
     filename:= str1;
     getintegervalue(frame,'line',line);
     getstringvalue(frame,'func',func);
     getintegervalue(frame,'addr',integer(addr));
     if getsourcename(wstr1)= gdb_ok then begin
      filedir:= msefileutils.filedir(wstr1);
     end;
    end;
   end;
  end;
  if result then begin
   messagetext:= stopreasontext[reason] + '.';
   if signalname <> '' then begin
    messagetext:= messagetext + ' Signal: ' + signalname;
   end;
   if signalmeaning <> '' then begin
    messagetext:= messagetext + ', ' + signalmeaning + '.';
   end;
   if filename <> '' then begin
    messagetext:= messagetext + ' File: ' + filename;
   end;
   if line > 0 then begin
    messagetext:= messagetext + ':'+inttostr(line);
   end;
   if func <> '' then begin
    messagetext:= messagetext + ' Function: ' + func;
   end;
   if exitcode <> 0 then begin
    messagetext:= messagetext + ' Exitcode: ' + inttostr(exitcode);
   end;
   if expression <> '' then begin
    messagetext:= messagetext + ' Expression: '+expression;
   end;
   if oldvalue <> '' then begin
    messagetext:= messagetext + ' old: '+oldvalue;
   end;
   if newvalue <> '' then begin
    messagetext:= messagetext + ' new: '+newvalue;
   end;
  end
  else begin
   if getstringvalue(response,'msg',messagetext) then begin
    if reason = sr_startup then begin
     reason:= sr_error;
    end;
   end;
  end;
 end;
end;
{
function tgdbmi.geterrorinfo(const response: resultinfoarty; out info: errorinfoty): boolean;
var
 int1: integer;
begin
 finalize(info);
 with info do begin
  fillchar(info,sizeof(info),0);
  result:= getstringvalue(response,'msg',messagetext);
 end;
end;
}
function tgdbmi.evaluateexpression(const expression: string; var aresult: string): gdbresultty;
begin
 aresult:= '';
 result:= synccommand('-data-evaluate-expression ' + '"'+expression+'"');
 case result of
  gdb_ok: begin
   getstringvalue(fsyncvalues,'value',aresult);
  end;
  gdb_error: begin
   getstringvalue(fsyncvalues,'msg',aresult);
  end;
  gdb_message: begin
   aresult:= errormessage;
  end;
 end;
end;

function tgdbmi.symboltype(const symbol: string; var aresult: string): gdbresultty;
begin
 result:= clicommand('ptype '+symbol);
 case result of
  gdb_ok: begin
   aresult:= fclivalues;
  end;
  gdb_message: begin
   aresult:= errormessage;
  end;
  else begin
   aresult:= '';
  end;
 end;
end;

function tgdbmi.threadselect(const aid: integer; out filename: filenamety; 
                                             out line: integer): gdbresultty;
var
 str1: string;
begin
 filename:= '';
 line:= 0;
 result:= synccommand('-thread-select ' + inttostr(aid));
 if result = gdb_ok then begin
  if getstringvalue(fsyncvalues,'file',str1) then begin
   filename:= str1;
  end;  
  getintegervalue(fsyncvalues,'line',line);
 end;
end;

function tgdbmi.getthreadidlist(out idlist: integerarty): gdbresultty;
var
 ar1: resultinfoarty;
 int1: integer;
begin
 idlist:= nil;
 result:= synccommand('-thread-list-ids');
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if gettuplevalue(fsyncvalues,'thread-ids',ar1) then begin
   setlength(idlist,length(ar1));
   for int1:= 0 to high(ar1) do begin
    if not getintegervalue(ar1[int1],'thread-id',idlist[int1]) then begin
     break;
    end;
   end;
   result:= gdb_ok;
  end;
 end;
end;

function tgdbmi.getthreadinfolist(out infolist: threadinfoarty): gdbresultty;
var
 int1,int2,int3: integer;
 ar1,ar2: stringarty;
begin
 infolist:= nil;
 ar1:= nil; //compiler warning
 ar2:= nil; //compiler warning
 result:= clicommand('info threads',true);
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  setlength(infolist,length(fclivaluelist));
  int2:= 0;
  for int1:= 0 to high(fclivaluelist) do begin
   with infolist[int2] do begin
    ar1:= splitstring(trim(fclivaluelist[int1]),' ',true);
    if high(ar1) >= 2 then begin
     if ar1[0] = '*' then begin
      state:= ts_active;
      ar1:= copy(ar1,1,bigint);
     end
     else begin
      state:= ts_none;
     end;
     if high(ar1) < 2 then begin
      exit;
     end;
     try
      id:= strtoint(ar1[0]);
     except
      exit;
     end;
     if ar1[1] = 'Thread' then begin
      ar1:= copy(ar1,2,bigint);
      if high(ar1) < 2 then begin
       exit;
      end;
     end;
     threadid:= 0;
     ar2:= splitstring(ar1[2],'.');
     if high(ar2) > 0 then begin
      try
       threadid:= strtohex(ar2[1]);
      except
      end;
     end
     else begin
      if (high(ar1) > 1) and (ar1[1] = '(LWP') then begin
       try
        threadid:= strtoint(copy(ar1[2],1,length(ar1[2])-1));
       except
       end;
//       int3:= threadid;
//       threadid:= id;
//       id:= int3;
//       ar1:= copy(ar1,2,bigint);
      end
      else begin
       try
        threadid:= strtohex(ar1[2]);
       except
       end;
      end;
     end;
     if high(ar1) >= 3 then begin
      stackframe:= ar1[3];
      for int3:= 4 to high(ar1) do begin
       stackframe:= stackframe + ' ' + ar1[int3];
      end;
     end;
     inc(int2);
    end;
   end;
  end;
  setlength(infolist,int2);
  result:= gdb_ok;
 end;
end;

function tgdbmi.readmemorybytes(const address: ptrint; const count: integer;
                 var aresult: bytearty): gdbresultty;
var
 ar1,ar2: resultinfoarty;
begin
 aresult:= nil;
 result:= synccommand('-data-read-memory '+ ptrinttocstr(address) + ' u 1 1 ' + inttostr(count));
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if getarrayvalue(fsyncvalues,'memory',false,ar1) then begin
   if gettuplevalue(ar1,'',ar2)  then begin
    if getbytearrayvalue(ar2,'data',aresult) then begin
     result:= gdb_ok;
    end;
   end;
  end;
 end;
end;

function tgdbmi.readmemorywords(const address: ptrint; const count: integer;
                 var aresult: wordarty): gdbresultty;
var
 ar1,ar2: resultinfoarty;
begin
 aresult:= nil;
 result:= synccommand('-data-read-memory '+ ptrinttocstr(address) + ' u 2 1 ' + inttostr(count));
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if getarrayvalue(fsyncvalues,'memory',false,ar1) then begin
   if gettuplevalue(ar1,'',ar2)  then begin
    if getwordarrayvalue(ar2,'data',aresult) then begin
     result:= gdb_ok;
    end;
   end;
  end;
 end;
end;

function tgdbmi.readmemorypointer(const address: ptrint; out aresult: ptrint): gdbresultty;
var
 ar1: bytearty;
begin
 result:= readmemorybytes(address,fpointersize,ar1);
 if result = gdb_ok then begin
  aresult:= pptrint(pointer(ar1))^;
 end;
end;

function tgdbmi.infoline(const filename: filenamety; const line: integer;
                         out start,stop: cardinal): gdbresultty;
var
 str1: string;
begin
 result:= getcliresultstring('info line '+filename+':'+inttostr(line),str1);
 if result = gdb_ok then begin
  if not getcliinteger('starts at address',str1,integer(start)) or
          not getcliinteger('ends at',str1,integer(stop)) then begin
   result:= gdb_dataerror;
  end;
 end;
end;

function tgdbmi.infoline(const address: cardinal; out filename: filenamety; out line: integer;
                         out start,stop: cardinal): gdbresultty;
var
 str1,str2: string;
begin
  result:= getcliresultstring('info line *'+inttostr(address),str1);
 if result = gdb_ok then begin
  if getclistring('of "',str1,str2) and getcliinteger('Line',str1,line) and
     getcliinteger('starts at address',str1,integer(start)) and
     getcliinteger('ends at',str1,integer(stop)) then begin
   filename:= copy(str2,1,length(str2)-1);
  end
  else begin
   result:= gdb_dataerror;
  end;
 end;
end;

function tgdbmi.internaldisassemble(out aresult: disassarty; command: string;
                 const mixed: boolean): gdbresultty;

 function getasm(const source: resultinfoararty; out dest: asmlinearty): boolean;
 var
  int1: integer;
 begin
  result:= false;
  setlength(dest,length(source));
  for int1:= 0 to high(source) do begin
   with dest[int1] do begin
    if not getintegervalue(source[int1],'address',integer(address)) then exit;
    if not getstringvalue(source[int1],'inst',instruction) then exit;
   end;
  end;
  result:= true;
 end;

var
 ar1,ar2: resultinfoarty;
 ar3: resultinfoararty;
 int1,int2: integer;
begin
 aresult:= nil;
 if mixed then begin
  command:= command + ' -- 1';
 end
 else begin
  command:= command + ' -- 0';
 end;
 result:= synccommand(command);
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if mixed then begin
   if getarrayvalue(fsyncvalues,'asm_insns',true,ar1) then begin
    int2:= 0;
    for int1:= 0 to high(ar1) do begin
     additem(aresult,typeinfo(disassarty),int2);
     if not gettuplevalue(ar1[int1],'src_and_asm_line',ar2) then exit;
     with aresult[int2-1] do begin
      if not getintegervalue(ar2,'line',line) then exit;
      if not gettuplearrayvalue(ar2,'line_asm_insn',ar3) then exit;
      if not getasm(ar3,asmlines) then exit;
     end;
    end;
    setlength(aresult,int2);
   end;
  end
  else begin
   if not gettuplearrayvalue(fsyncvalues,'asm_insns',ar3) then exit;
   setlength(aresult,1);
   if not getasm(ar3,aresult[0].asmlines) then exit;
  end;
  result:= gdb_ok;
 end;
end;

function tgdbmi.disassemble(out aresult: asmlinearty; const filename: filenamety;
                 const line: integer; const count: integer): gdbresultty;
var
 str1: string;
 ar1: disassarty;
begin
 str1:= '-data-disassemble -f '+filename+' -l '+inttostr(line) +
                 ' -n ' + inttostr(count);
 result:= internaldisassemble(ar1,str1,false);
 if result = gdb_ok then begin
  aresult:= ar1[0].asmlines;
 end;
end;

function tgdbmi.disassemble(out aresult: asmlinearty;
             const start,stop: cardinal): gdbresultty;
var
 str1: string;
 ar1: disassarty;
begin
 str1:= '-data-disassemble -s '+ptrinttocstr(start)+' -e '+ptrinttocstr(stop);
 result:= internaldisassemble(ar1,str1,false);
 if result = gdb_ok then begin
  aresult:= ar1[0].asmlines;
 end;
end;

function tgdbmi.disassemble(out aresult: disassarty; const filename: filenamety;
                  const line: integer; const count: integer): gdbresultty;
var
 str1: string;
begin
 str1:= '-data-disassemble -f '+filename+' -l '+inttostr(line) +
                 ' -n ' + inttostr(count);
 result:= internaldisassemble(aresult,str1,true);
end;

function tgdbmi.disassemble(out aresult: disassarty; const start,stop: cardinal): gdbresultty;
var
 str1: string;
begin
 str1:= '-data-disassemble -s '+ptrinttocstr(start)+' -e '+ptrinttocstr(stop);
 result:= internaldisassemble(aresult,str1,true);
end;

function tgdbmi.getregistervalue(const aname: string; out avalue: ptrint): gdbresultty;
var
 str1: string;
begin
 result:= evaluateexpression('$'+aname,str1);
 if result = gdb_ok then begin
  try
   avalue:= strtointvalue(str1);
  except
   result:= gdb_dataerror;
  end;
 end;
end;

function tgdbmi.getpc(out addr: ptrint): gdbresultty;
begin
 result:= getregistervalue('pc',addr);
end;

function tgdbmi.listregisternames(out aresult: stringarty): gdbresultty;
begin
 aresult:= nil;
 result:= synccommand('-data-list-register-names');
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if getstringarrayvalue(fsyncvalues,'register-names',aresult) then begin
   result:= gdb_ok;
  end;
 end;
end;

function tgdbmi.listregistervalues(out aresult: registerinfoarty): gdbresultty;
var
 ar1,ar2: resultinfoarty;
 int1: integer;
begin
 aresult:= nil;
 result:= synccommand('-data-list-register-values r');
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if getarrayvalue(fsyncvalues,'register-values',false,ar1) then begin
   setlength(aresult,length(ar1));
   for int1:= 0 to high(ar1) do begin
    if not gettuplevalue(ar1[int1],ar2) then begin
     exit;
    end;
    with aresult[int1] do begin
     if not getintegervalue(ar2,'number',num) then begin
      exit;
     end;
     if not getstringvalue(ar2,'value',bits) then begin
      exit;
     end;
    end;
   end;
   result:= gdb_ok;
  end;
 end;
end;

function tgdbmi.listlines(const path: filenamety;
                          out lines: integerarty; out addresses: ptrintarty): gdbresultty;
var
 ar1,ar2: resultinfoarty;
 int1: integer;
begin
 lines:= nil;
 addresses:= nil;
 result:= synccommand('-symbol-list-lines '+filename(path),5*defaultsynctimeout);
 if result = gdb_ok then begin
  result:= gdb_dataerror;
  if getarrayvalue(fsyncvalues,'lines',false,ar1) then begin
   setlength(lines,length(ar1));
   setlength(addresses,length(ar1));
   for int1:= 0 to high(ar1) do begin
    if not gettuplevalue(ar1[int1],ar2) then begin
     exit;
    end;
    if not getptrintvalue(ar2,'pc',addresses[int1]) then begin
     exit;
    end;
    if not getintegervalue(ar2,'line',lines[int1]) then begin
     exit;
    end;
   end;
  end;
  result:= gdb_ok;
 end;
end;

function tgdbmi.getpcharvar(address: cardinal): string;
const
 maxblocklength = 16;
var
 data: bytearty;
 po1: pchar;
 int1,int2: integer;
 bo1: boolean;
 blocklength: integer;
begin
 if address = 0 then begin
  result:= '''''';
 end
 else begin
  result:= '''';
  int1:= 2;
  blocklength:= maxblocklength;
  bo1:= false;
  repeat
   while true do begin
    if blocklength <= 0 then begin
     result:= 'Can not read memory at $'+inttohex(address,8);
     exit;
    end;
    if readmemorybytes(address,blocklength,data) <> gdb_ok then begin
     blocklength:= blocklength div 2;
    end
    else begin
     break;
    end;
   end;
   if high(data) >= 0 then begin
    po1:= strlscan(pchar(pointer(data)),#0,length(data));
    if po1 = nil then begin
     po1:= pchar(pointer(data))+length(data);
    end
    else begin
     bo1:= true;
    end;
    int2:= po1-pchar(pointer(data));
    setlength(result,length(result)+int2);
    move(data[0],result[int1],int2);
    inc(int1,int2);
    inc(address,int2);
   end;
  until bo1 or (length(data) < blocklength);
  result:= result + '''';
 end;
end;

function tgdbmi.getpmsecharvar(address: cardinal): msestring;
const
 maxblocklength = 16;
var
 data: wordarty;
 po1: pmsechar;
 int1,int2: integer;
 bo1: boolean;
 blocklength: integer;
begin
 if address = 0 then begin
  result:= '''''';
 end
 else begin
  result:= '''';
  int1:= 2;
  blocklength:= maxblocklength;
  bo1:= false;
  repeat
   while true do begin
    if blocklength <= 0 then begin
     result:= 'Can not read memory at $'+inttohex(address,8);
     exit;
    end;
    if readmemorywords(address,blocklength,data) <> gdb_ok then begin
     blocklength:= blocklength div 2;
    end
    else begin
     break;
    end;
   end;
   if high(data) >= 0 then begin
    po1:= msestrlscan(pmsechar(pointer(data)),#0,length(data));
    if po1 = nil then begin
     po1:= pmsechar(pointer(data))+length(data);
    end
    else begin
     bo1:= true;
    end;
    int2:= po1-pmsechar(pointer(data));
    setlength(result,length(result)+int2);
    move(data[0],result[int1],int2*sizeof(msechar));
    inc(int1,int2);
    inc(address,int2*sizeof(msechar));
   end;
  until bo1 or (length(data) < blocklength);
  result:= result + '''';
 end;
end;

function tgdbmi.ispointervalue(const avalue: string; out pointervalue: ptrint): boolean;
begin
 result:= trystrtoptrint(avalue,pointervalue);
end;

function tgdbmi.matchpascalformat(const typeinfo: string;
                                       const value: string): msestring;
const
 typetoken = 'type = ';
 dynartoken = 'array [0..-1] of ';
var
 ar1: stringarty;
 str1,str3: string;
 mstr1: msestring;
 ad1,ad2,ad3: ptrint;
 res1: gdbresultty;
 int1: integer;
begin
 ar1:= nil; //compiler warning
 result:= value;
 if ispointervalue(value,ad1) then begin
  ar1:= breaklines(typeinfo);
  if length(ar1) > 0 then begin
   if startsstr(typetoken,ar1[0]) then begin
    str1:= copy(ar1[0],length(typetoken)+1,length(ar1[0])-length(typetoken));
   end;
   if str1 = '^character' then begin
    result:= getpcharvar(ad1);
   end
   else begin
    if str1 = '^wchar' then begin
     result:= getpmsecharvar(ad1);
    end
    else begin
     if startsstr(dynartoken,str1) then begin
      if readmemorypointer(ad1,ad2) = gdb_ok then begin
       if ad2 = 0 then begin
        result:= niltext;
       end
       else begin
        if readmemorypointer(ad2-4,ad3) = gdb_ok then begin
        //read arrayhigh
         str3:= '^'+copy(str1,length(dynartoken)+1,bigint)+'('+ptrinttocstr(ad2)+')[';
         result:= '(';
         if ad2 >= 0 then begin
          for int1:= 0 to ad3 do begin
           if length(value) > 200 then begin
            result:= result +'...,';
            break;
           end;
           res1:= readpascalvariable(str3+inttostr(int1)+']',mstr1);
           result:= result + mstr1 + ',';
           if res1 <> gdb_ok then begin
            break;
           end;
          end;
          setlength(result,length(result)-1); //remove last comma
         end;
         result:= result + ')';
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tgdbmi.readpascalvariable(const varname: string; 
                                          out aresult: msestring): gdbresultty;
var
 str1,str2: string;
begin
 if running then begin
  result:= gdb_running;
  aresult:= '';
 end
 else begin
  result:= symboltype(varname,str1);
  if result = gdb_ok then begin
   result:= evaluateexpression(varname,str2);
   case result of
    gdb_ok: begin
     aresult:= matchpascalformat(str1,str2);
    end;
    gdb_message: begin
     aresult:= errormessage;
    end;
    else begin
     aresult:= '';
    end;
   end;
  end
  else begin
   aresult:= str1;
  end;
 end;
end;

function tgdbmi.writepascalvariable(const varname: string; const value: string;
                        var aresult: string): gdbresultty;
begin
 result:= evaluateexpression(varname+':= '+value,aresult);
end;

function tgdbmi.clicommand(const acommand: string; list: boolean = false;
                      timeout: integer = defaultsynctimeout): gdbresultty;
begin
 fclivalues:= '';
 fclivaluelist:= nil;
 include(fstate,gs_clicommand);
 try
  if list then begin
   include(fstate,gs_clilist);
  end
  else begin
   exclude(fstate,gs_clilist);
  end;
  result:= synccommand(acommand,timeout);
 finally
  exclude(fstate,gs_clicommand);
 end;
end;

function tgdbmi.getcliresult(const acommand: string; var aresult: stringarty): gdbresultty;
var
 int1: integer;
begin
 result:= clicommand(acommand);
 if result = gdb_ok then begin
  splitstring(fclivalues,aresult,c_linefeed);
  for int1:= 0 to high(aresult) do begin
   aresult[int1]:= trim(replacechar(aresult[int1],c_tab,' '));
  end;
 end;
end;

function tgdbmi.getcliresultstring(const acommand: string; var aresult: string): gdbresultty;
begin
 result:= clicommand(acommand);
 if result = gdb_ok then begin
  aresult:= fclivalues;
 end;
 replacechar1(aresult,#$0a,' ');
 replacechar1(aresult,#$0d,' ');
end;

function tgdbmi.getclistring(const aname: string; const response: string; out aresult: string): boolean;
var
 int1: integer;
 po1,po2: pchar;
begin
 int1:= pos(aname,response);
 if int1 > 0 then begin
  aresult:= '';
  result:= true;
  po1:= @response[int1+length(aname)];
  po2:= strnscan(po1,' ');
  if po2 <> nil then begin
   po1:= strscan(po2,' ');
   if po1 <> nil then begin
    setstring(aresult,po2,po1-po2);
   end
   else begin
    setstring(aresult,po2,length(response)-(po1-pchar(pointer(response))));
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

function tgdbmi.getcliinteger(const aname: string; const response: string; out aresult: integer): boolean;
var
 str1: string;
begin
 result:= getclistring(aname,response,str1);
 if result then begin
  try
   aresult:= strtointvalue(str1);
  except
   result:= false;
  end;
 end;
end;

function tgdbmi.getpascalvalue(const avalue: string): string;
const
 ansistringtag = '(ANSISTRING)';
var
 ca1: ptrint;
begin
 if startsstr(ansistringtag,avalue) then begin
  if ispointervalue(copy(avalue,length(ansistringtag)+1,bigint),ca1) then begin
   result:= getpcharvar(ca1);
   exit;
  end;
 end;
 result:= avalue;
end;

function tgdbmi.stacklistframes(out list: frameinfoarty; first,
  last: integer): gdbresultty;
var
 ar1,ar2,ar3,ar4: resultinfoarty;
 int1,int2: integer;
 str1: string;
begin
 result:= synccommand('-stack-info-depth '+ inttostr(last));
 if result = gdb_ok then begin
  getintegervalue(fsyncvalues,'depth',int1);
  if int1 < last then begin
   last:= int1;
  end;
  result:= synccommand('-stack-list-frames '+inttostr(first) + ' ' + inttostr(last));
  if result = gdb_ok then begin
   if getarrayvalue(fsyncvalues,'stack',true,ar1) then begin
    setlength(list,length(ar1));
    for int1:= 0 to high(list) do begin
     gettuplevalue(ar1[int1],ar2);
     with list[int1] do begin
      getintegervalue(ar2,'level',level);
      getintegervalue(ar2,'addr',integer(addr));
      getstringvalue(ar2,'func',func);
      getstringvalue(ar2,'file',str1);
      filename:= str1;
      getintegervalue(ar2,'line',line);
     end;
    end;
    result:= synccommand('-stack-list-arguments 1 '+inttostr(first) + ' ' + inttostr(last));
    if (result = gdb_ok) and (high(ar1) = high(list)) then begin
     if getarrayvalue(fsyncvalues,'stack-args',true,ar1) then begin
      for int1:= 0 to high(list) do begin
       gettuplevalue(ar1[int1],ar2);
       with list[int1] do begin
        getarrayvalue(ar2,'args',false,ar3);
        setlength(params,length(ar3));
        for int2:= 0 to high(ar3) do begin
         decodelist(false,ar3[int2].value,ar4);
         if high(ar4) = 1 then begin
          params[int2].name:= ar4[0].value;
          params[int2].value:= getpascalvalue(ar4[1].value);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tgdbmi.selectstackframe(const aframe: integer): gdbresultty;
begin
 result:= synccommand('-stack-select-frame '+inttostr(aframe));
end;

function tgdbmi.started: boolean;
begin
 result:= running or active and (fstate*[gs_started{,gs_attached}] <> []);
end;

procedure tgdbmi.targetwriteln(const avalue: string);
begin
 if running then begin
  {$ifdef UNIX}
  ftargetterminal.output.writeln(avalue);
  {$else}
  fgdbto.writeln(avalue);
  {$endif}
 end;
end;

{$ifdef UNIX}
{ tpseudoterminal }

constructor tpseudoterminal.create;
var
 pty: integer;

 procedure error;
 begin
  sys_closefile(pty);
  syserror(syelasterror,'Can not create pseudoterminal:');
 end;
 
const
 buflen = 100;
  
var
 ios: termios{ty};
 
begin
 pty:= invalidfilehandle;
 pty:= getpt;
 if pty < 0 then error;
 if (grantpt(pty) < 0) or (unlockpt(pty) < 0) then error;
 setlength(fdevicename,buflen);
 if ptsname_r(pty,@fdevicename[1],buflen) < 0 then error;
 setlength(fdevicename,length(pchar(fdevicename)));
 if msetcgetattr(pty,ios) <> 0 then error;
 ios.c_lflag:= ios.c_lflag and not (icanon or echo);
 ios.c_cc[vmin]:= #1;
 ios.c_cc[vtime]:= #0;
 if msetcsetattr(pty,tcsanow,ios) <> 0 then error;
 finput:= tpipereader.create;
 foutput:= tpipewriter.create;
// finput.handle:= pty;
 foutput.handle:= pty;
end;

destructor tpseudoterminal.destroy;
begin
 closeinp;
 foutput.releasehandle;
 foutput.free;
 finput.free;
end;

procedure tpseudoterminal.closeinp;
var
 ios: termios{ty};
begin
 finput.terminate;
 if finput.active then begin
  msetcgetattr(foutput.handle,ios);
  ios.c_lflag:= (ios.c_lflag and not (icanon)) or echo;
  ios.c_cc[vmin]:= #0;
  ios.c_cc[vtime]:= #0;
  msetcsetattr(foutput.handle,tcsanow,ios);
  foutput.writeln('');
 end;
end;

procedure tpseudoterminal.restart;
var
 ios: termios{ty};
begin
 closeinp;
 if foutput.handle <> invalidfilehandle then begin
  if msetcgetattr(foutput.handle,ios) = 0 then begin
   ios.c_lflag:= ios.c_lflag and not (icanon or echo);
   ios.c_cc[vmin]:= #1;
   ios.c_cc[vtime]:= #0;
   if msetcsetattr(foutput.handle,tcsanow,ios) = 0 then begin
    finput.releasehandle;
    finput.handle:= foutput.handle;
   end;
  end;
 end;
end;

{$endif unix}
 
end.
