{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepipestream;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 msestream,msethread,msesystypes,classes,mclasses,msebits,mseclasses,
 msetypes;

type

 pr_piperesultty = (pr_empty,pr_data,pr_line);

 tpipewriter = class(ttextstream)
  private
   fconnected: boolean;
   function gethandle: integer;
  protected
   procedure sethandle(value: integer); override;
   function dowrite(const buffer; count: longint): longint; virtual;
  public
   constructor create; reintroduce;
//   destructor destroy; override;
{$ifdef FPC}
   function Write(const Buffer; Count: Longint): Longint; override; overload;
{$endif}
   procedure connect(const ahandle: integer); //does not own handle
//   function releasehandle: filehandlety; virtual;
   property handle: integer read gethandle write sethandle; //owns handle
 end;

 tpipereader = class;

 pipereadereventty = procedure(const sender: tpipereader) of object;

 //todo: no thread.kill, single thread for all pipreaders
 bufferty = array[0..defaultbuflen-1] of char;

 pipereaderoptionty = (pro_nolock);
 pipereaderoptionsty = set of pipereaderoptionty;

 tpipereader = class(tpipewriter)
  private
   fpipebuffer: string;
   fdatastatus: pr_piperesultty;
   foninputavailable: pipereadereventty;
   fonpipebroken: pipereadereventty;
   finputcond: condty;
   fwritehandle: integer;
   foverloadsleepus: integer;
   foptions: pipereaderoptionsty;
   function checkdata: pr_piperesultty;
   procedure clearpipebuffer;
   function getresponseflag: boolean;
   procedure setresponseflag(const Value: boolean);
   procedure setwritehandle(const Value: integer);
  protected
   fthread: tsemthread;         //simulate nonblocking pipes on windows
   fmsbuf: bufferty;
   fmsbufcount: integer;
   fowner: tmsecomponent;
   function execthread(thread: tmsethread): integer; virtual;
   procedure sethandle(value: integer); override;
   procedure setbuflen(const Value: integer); override;
   function doread(var buf; const acount: integer; out readcount: integer;
                  const nonblocked: boolean = false): boolean; virtual;
          //true of no error
   function readbytes(var buf): integer; override;
   procedure doinputavailable;
   procedure dochange; virtual;
   function readbuf: string;
  public
   constructor create;
   destructor destroy; override;

   function releasehandle: filehandlety override;
   function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
                   //no seek, result always 0
   function readdatastring: string; override;
   procedure appenddatastring(var adata: string; var acount: sizeint);

   function readbuffer: string; //does not try to get additional data
   function readuln(var value: string): boolean;
   function readuln(var value: string; out hasmoredata: boolean): boolean;
           //bringt auch unvollstaendige zeilen, false wenn unvollstaendig
           //no decoding
   function readstrln(var value: string): boolean; override;
           //bringt nur vollstaendige zeilen, sonst false
           //no decoding
   procedure clear; override;
   procedure terminate(const noclosehandle: boolean = false);
   procedure terminateandwait(const noclosehandle: boolean = false);
   procedure waitfor;
   function waitforresponse(timeoutusec: integer = 0;
                      resetflag: boolean = true): boolean;
             //false if timeout or error
   function active: boolean; //true if handle set and not eof or error
   property responseflag: boolean read getresponseflag write setresponseflag;
   property text: string read fpipebuffer;
   property writehandle: integer read fwritehandle write setwritehandle;
   property overloadsleepus: integer read foverloadsleepus
                 write foverloadsleepus default -1;
           //checks application.checkoverload before calling oninputavaliable
           //if >= 0
   property options: pipereaderoptionsty read foptions
                                             write foptions default [];
   property oninputavailable: pipereadereventty read foninputavailable
                                                      write foninputavailable;
   property onpipebroken: pipereadereventty read fonpipebroken
                                                           write fonpipebroken;
   property owner: tmsecomponent read fowner;
end;

 tpipereadercomp = class(tmsecomponent)
  private
   fpipereader: tpipereader;
   function getoninputavailable: pipereadereventty;
   function getonpipebroken: pipereadereventty;
   procedure setoninputavailable(const Value: pipereadereventty);
   procedure setonpipebroken(const Value: pipereadereventty);
   function getoverloadsleepus: integer;
   procedure setoverloadsleepus(const avalue: integer);
   function getopions: pipereaderoptionsty;
   procedure setoptions(const avalue: pipereaderoptionsty);
   function getencoding: charencodingty;
   procedure setencoding(const avalue: charencodingty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property pipereader: tpipereader read fpipereader;
  published
   property options: pipereaderoptionsty read getopions
                                        write setoptions default [];
   property encoding: charencodingty read getencoding write setencoding
                                                         default ce_locale;
   property overloadsleepus: integer read getoverloadsleepus
                  write setoverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property oninputavailable: pipereadereventty read getoninputavailable write setoninputavailable;
   property onpipebroken: pipereadereventty read getonpipebroken write setonpipebroken;
 end;

 tpipereaderpers = class(tpersistent)
  private
   fpipereader: tpipereader;
   function getoninputavailable: pipereadereventty;
   function getonpipebroken: pipereadereventty;
   procedure setoninputavailable(const Value: pipereadereventty);
   procedure setonpipebroken(const Value: pipereadereventty);
   function getoverloadsleepus: integer;
   procedure setoverloadsleepus(const avalue: integer);
   function getopions: pipereaderoptionsty;
   procedure setoptions(const avalue: pipereaderoptionsty);
   function getencoding: charencodingty;
   procedure setencoding(const avalue: charencodingty);
  public
   constructor create(const aowner: tmsecomponent);
   destructor destroy; override;
   property pipereader: tpipereader read fpipereader;
  published
   property options: pipereaderoptionsty read getopions
                                        write setoptions default [];
   property encoding: charencodingty read getencoding write setencoding
                                                         default ce_locale;
   property overloadsleepus: integer read getoverloadsleepus
                  write setoverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property oninputavailable: pipereadereventty read getoninputavailable write setoninputavailable;
   property onpipebroken: pipereadereventty read getonpipebroken write setonpipebroken;
 end;

 tpipewriterpers = class(tpersistent)
  private
   fpipewriter: tpipewriter;
   function getencoding: charencodingty;
   procedure setencoding(const avalue: charencodingty);
  public
   constructor create(const aowner: tmsecomponent);
   destructor destroy; override;
   property pipewriter: tpipewriter read fpipewriter;
  published
   property encoding: charencodingty read getencoding write setencoding
                                                         default ce_locale;
 end;

{$ifdef UNIX}
function readfilenonblock(const handle: thandle; var buf; const acount: integer;
                     const nonblocked: boolean): integer; //-1 on error
{$endif}

implementation
uses
  {$ifdef UNIX}mselibc, {$else}windows, {$endif}
 mseapplication,msesysintf1,msesysintf,sysutils,msesysutils;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

{ tpipewriter }

constructor tpipewriter.create;
begin
 inherited create(invalidfilehandle);
end;
{
destructor tpipewriter.destroy;
begin
 sethandle(invalidfilehandle);
 inherited;
end;
}
{
function tpipewriter.releasehandle: filehandlety;
begin
 result:= handle;
 fhandle:= invalidfilehandle;
end;
}
procedure tpipewriter.connect(const ahandle: integer);
begin
 handle:= ahandle;
 if ahandle <> invalidfilehandle then begin
  fconnected:= true;
 end;
end;

procedure tpipewriter.sethandle(value: integer);
begin
 if fconnected then begin
  fhandle:= invalidfilehandle;
  fconnected:= false;
 end;
 inherited;
 bufoffset:= nil;
end;

function tpipewriter.dowrite(const buffer; count: longint): longint;
begin
 result:= inherited write(buffer,count);
end;

function tpipewriter.gethandle: integer;
begin
result:= inherited handle;
end;

{$ifdef FPC}
function tpipewriter.Write(const Buffer; Count: Longint): Longint;
begin
 result:= dowrite(buffer,count);
end;
{$endif}

{ tpipereader }

constructor tpipereader.create;
begin
 sys_condcreate(finputcond);
 fwritehandle:= invalidfilehandle;
 foverloadsleepus:= -1;
 inherited;
 include(fstate,tss_notopen);
end;

destructor tpipereader.destroy;
begin
 terminateandwait;
 writehandle:= invalidfilehandle;
 inherited;
 sys_conddestroy(finputcond);
end;

function tpipereader.releasehandle: filehandlety;
begin
 terminateandwait(true);
 freeandnil(fthread);
 writehandle:= invalidfilehandle;
 result:= inherited releasehandle();
end;

procedure tpipereader.sethandle(value: integer);
begin
 if handle <> invalidfilehandle then begin
  terminateandwait;
 end;
 freeandnil(fthread);
 inherited;
 if value <> invalidfilehandle then begin
  writehandle:= invalidfilehandle;
  fstate:= fstate - [tss_notopen,tss_eof,tss_error,tss_pipeactive];
  fmsbufcount:= 0;
  fthread:= tsemthread.create({$ifdef FPC}@{$endif}execthread);
 end;
end;

procedure tpipereader.setwritehandle(const Value: integer);
begin
 if fwritehandle <> invalidfilehandle then begin
  sys_closefile(fwritehandle);
 end;
 fwritehandle := Value;
end;

procedure tpipereader.terminate(const noclosehandle: boolean = false);
var
 by1: byte;
begin
 if fthread <> nil then begin
  fthread.terminate;

  if fthread.running then begin
   fthread.sempost;
   if fwritehandle <> invalidfilehandle then begin
    by1:= 0;
    sys_write(fwritehandle,@by1,1); //wake up thread
   end
   else begin
    // inherited sethandle(invalidfilehandle);
    {$ifdef unix}
    pthread_kill(fthread.id,sigio);

   end;
   writehandle:= invalidfilehandle;

  end;

 end;

 if not noclosehandle then begin
  inherited sethandle(invalidfilehandle);
 end;
 include(fstate,tss_notopen);
{$endif}
end;

procedure tpipereader.terminateandwait(const noclosehandle: boolean = false);
begin
 if fthread <> nil then begin
  terminate(noclosehandle);
  application.waitforthread(fthread);
 end;
end;

procedure tpipereader.waitfor;
begin
 if fthread <> nil then begin
  application.waitforthread(fthread);
 end;
end;

procedure tpipereader.setbuflen(const Value: integer);
begin
 if value < defaultbuflen then begin
  inherited setbuflen(defaultbuflen);
 end
 else begin
  inherited;
 end;
end;

{$ifdef UNIX}
function readfilenonblock(const handle: thandle; var buf; const acount: integer;
                     const nonblocked: boolean): integer; //-1 on error
begin
 if nonblocked then begin
  setfilenonblock(handle,true);
 end;
 result:= sys_read(handle,@buf,acount);
 if nonblocked then begin
  if (result < 0) and (sys_getlasterror = EAGAIN) then begin
   result:= 0;
  end;
  setfilenonblock(handle,false);
 end;
end;
{$endif}

function tpipereader.doread(var buf; const acount: integer;
                              out readcount: integer;
                             const nonblocked: boolean = false): boolean;
begin
{$ifdef mswindows}
 readcount:= sys_read(Handle,@buf,acount);
 if readcount < 0 then begin
  result:= false;
 end;
// result:= fileRead(Handle,buf,acount)
{$else}
 readcount:= readfilenonblock(handle,buf,acount,
                         nonblocked and not (tss_unblocked in fstate));
{$endif}
 result:= readcount >= 0;
 if not result then begin
  readcount:= 0;
 end;
end;

function tpipereader.execthread(thread: tmsethread): integer;
var
 int1: integer;
 {$ifdef unix}
 info: pollfd;
 {$endif}
begin
 fthread:= tsemthread(thread);
 {$ifdef unix}
 info.fd:= handle;
 info.events:= pollin;
 {$endif}
 with fthread do begin
  while not terminated and not (tss_error in fstate) do begin
  {$ifdef unix}
   if (poll(@info,1,-1) > 0) and not terminated then begin
  {$else}
   if true then begin
  {$endif}
    int1:= sys_read(Handle,@fmsBuf,sizeof(fmsbuf));
    if not terminated then begin
     if {$ifdef mswindows}int1 < 0{$else}(int1 <= 0){$endif} then begin
                      //on win32 int1 can be 0
      include(fstate,tss_error); //broken pipe
     end
     else begin
      fmsbufcount:= int1;
     end;
     if (int1 > 0) or (tss_error in fstate) then begin
      include(fstate,tss_pipeactive);
      doinputavailable;
      if not terminated and not (tss_error in fstate) then begin
       semwait;
      end;
     end;
    end;
   end;
  end;
  include(fstate,tss_eof);
 end;
 result:= 0;
end;

function tpipereader.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
 inherited seek(offset,origin);
 result:= 0;
end;

procedure tpipereader.doinputavailable;
var
 needslock: boolean;
begin
 if (tss_haslink in fstate) or
         assigned(foninputavailable) or assigned(fonpipebroken) then begin
  if foverloadsleepus >= 0 then begin
   while not fthread.terminated and application.checkoverload(-1) do begin
    sleepus(foverloadsleepus);
   end;
  end;
  needslock:= not (pro_nolock in foptions) and not fthread.terminated;
  if needslock then begin
   application.lock;
  end;
  try
   if not fthread.terminated then begin
    if assigned(foninputavailable) then begin
     foninputavailable(self);
    end;
    if eof and assigned(fonpipebroken) then begin
     fonpipebroken(self);
    end;
    dochange;
   end;
  finally
   if needslock then begin
    application.unlock;
   end;
  end;
 end;
 sys_condlock(finputcond);
 include(fstate,tss_response);
 sys_condbroadcast(finputcond);
 sys_condunlock(finputcond);
end;

procedure tpipereader.clearpipebuffer;
begin
 fpipebuffer:= '';
 fdatastatus:= pr_empty;
end;

function tpipereader.readbytes(var buf): integer;

 procedure getmorebytes;
{$ifdef mswindows}
 var
  int1: integer;
{$endif}
 begin
 {$ifdef mswindows}
  if peeknamedpipe(handle,nil,0,nil,@int1,nil) and (int1 > 0) then begin
   if int1 > sizeof(fmsbuf) then begin
    int1:= sizeof(fmsbuf);
   end;
   if not doread(fmsbuf,int1,fmsbufcount) then begin
    fstate:= fstate + [tss_error,tss_eof];
   end;
  end
  else begin
   fmsbufcount:= 0;
  end;
 {$else}
  if not doread(fmsbuf,sizeof(fmsbuf),fmsbufcount,true) then begin
    fstate:= fstate + [tss_error,tss_eof]; //broken pipe
  end;
 {$endif}
  if fmsbufcount = 0 then begin
   exclude(fstate,tss_pipeactive);
   fthread.sempost;
  end
  else begin
   include(fstate,tss_pipeactive);
  end;
 end;

begin
 result:= fmsbufcount;
 if result > 0 then begin
  move(fmsbuf,buf,fmsbufcount);
  getmorebytes;
 end
 else begin
  if sys_getcurrentthread = fthread.id then begin //check again fore more
   include(fstate,tss_pipeactive);
   if fthread.semcount > 0 then begin
    fthread.semwait; //reset semaphore
   end;
   getmorebytes;
   result:= fmsbufcount;
   if result > 0 then begin
    move(fmsbuf,buf,fmsbufcount);
    getmorebytes;
   end;
  end;
  if tss_error in fstate then begin
   include(fstate,tss_eof);
  end;
 end;
end;

function tpipereader.readbuf: string;
var
 int1: integer;
begin
 if bufoffset <> nil then begin
  int1:= bufend-bufoffset;
  setlength(result,int1);
  move(bufoffset^,result[1],int1);
  bufoffset:= nil;
 end
 else begin
  result:= '';
 end;
end;

function tpipereader.readbuffer: string;
var
 int1: integer;
begin
 result:= readbuf;
 if fmsbufcount > 0 then begin
  int1:= length(result);
  setlength(result,int1+fmsbufcount);
  move(fmsbuf,result[int1+1],fmsbufcount);
  fmsbufcount:= 0;
  exclude(fstate,tss_pipeactive);
  fthread.sempost;
 end;
end;

function tpipereader.readdatastring: string;
var
 int1: integer;
 len1: sizeint;
begin
 result:= readbuffer;
 len1:= length(result);
 while true do begin
  int1:= readbytes(fbuffer^);
  if int1 > 0 then begin
   len1:= len1+int1;
   if len1 > length(result) then begin
    setlength(result,2*len1);
   end;
   move(fbuffer^,result[len1-int1+1],int1);
  end
  else begin
   break;
  end;
 end;
 setlength(result,len1);
end;

procedure tpipereader.appenddatastring(var adata: string; var acount: sizeint);
var
 len1: sizeint;
 i1: int32;
begin
 i1:= 0;
 if bufoffset <> nil then begin
  i1:= bufend - bufoffset;
 end;
 len1:= acount + i1 + fmsbufcount;
 if len1 > length(adata) then begin
  setlength(adata,2*len1);
 end;
 if bufoffset <> nil then begin
  move(bufoffset^,(pointer(adata)+acount)^,i1);
  bufoffset:= nil;
 end;
 move(fmsbuf,(pointer(adata)+acount+i1)^,fmsbufcount);
 fmsbufcount:= 0;

 repeat
 {$ifdef mswindows}
  if peeknamedpipe(handle,nil,0,nil,@i1,nil) and (i1 > 0) then begin
   if len1+i1 > length(adata) then begin
    setlength(adata,2*(len1+i1));
   end;
   if not doread((pointer(adata)+len1)^,i1,i1) then begin
    fstate:= fstate + [tss_error,tss_eof];
   end;
  end
  else begin
   break;
  end;
 {$else}
  if len1 >= length(adata) then begin
   setlength(adata,2*len1+64);
  end;
  i1:= length(adata) - len1; //fill current buffer
  if not doread((pointer(adata)+len1)^,i1,i1,true) then begin
   fstate:= fstate + [tss_error,tss_eof]; //broken pipe
  end;
  if i1 = 0 then begin
   break;
  end;
 {$endif}
  len1:= len1 + i1;
 until fstate * [tss_error,tss_eof] <> [];
 acount:= len1;
 exclude(fstate,tss_pipeactive);
 fthread.sempost;
end;

function tpipereader.checkdata: pr_piperesultty;
var
 str1: string;
 bo1: boolean;
begin
 if not (tss_error in fstate) and
          ((bufend <> bufoffset) or (tss_pipeactive in fstate) or
                             (sys_getcurrentthread = fthread.id)) then begin
  bo1:= inherited readstrln(str1);
  fpipebuffer:= fpipebuffer + str1;
  if bo1 then begin
   fdatastatus:= pr_line;
  end
  else begin
   if str1 <> '' then begin
    fdatastatus:= pr_data;
   end;
   if not (tss_error in fstate) then begin
    exclude(fstate,tss_eof);
   end;
   bufoffset:= nil; //neu laden
  end;
  result:= fdatastatus;
 end
 else begin
  result:= pr_empty;
 end;
end;

function tpipereader.readuln(var value: string;
               out hasmoredata: boolean): boolean;
begin
 value:= '';
 result:= false;
// if (tss_pipeactive in fstate) or (fdatastatus <> pr_empty) then begin
  repeat
   if fdatastatus = pr_empty then begin
    checkdata;
   end;
   value:= value + fpipebuffer;
   result:= fdatastatus = pr_line;
   clearpipebuffer;
   checkdata;
  until result or (fdatastatus = pr_empty);
// end;
 hasmoredata:= fdatastatus <> pr_empty;
end;

function tpipereader.readuln(var value: string): boolean;
var
 b1: boolean;
begin
 result:= readuln(value,b1);
end;

function tpipereader.readstrln(var value: string): boolean;
begin
 case checkdata of
  pr_line: begin
   result:= true;
   value:= fpipebuffer;
   clearpipebuffer;
  end;
  else begin
   result:= false;
   value:= '';
  end;
 end;
end;

procedure tpipereader.clear;
begin
 clearpipebuffer;
 bufoffset:= nil;
end;

function tpipereader.waitforresponse(timeoutusec: integer = 0;
                            resetflag: boolean = true): boolean;
             //false if timeout or error
begin
 sys_condlock(finputcond);
 result:= responseflag;
 if not result then begin
  if not eof then begin
   result:= sys_condwait(finputcond,timeoutusec) = sye_ok;
  end;
 end;
 if result and resetflag then begin
  responseflag:= false;
 end;
 sys_condunlock(finputcond);
end;

function tpipereader.getresponseflag: boolean;
begin
 result:= tss_response in fstate;
end;

procedure tpipereader.setresponseflag(const Value: boolean);
begin
 updatebit({$ifdef FPC}longword{$else}byte{$endif}(fstate),ord(tss_response),value);
end;

function tpipereader.active: boolean;
begin
 result:= (handle <> invalidfilehandle) and (fstate * [tss_error,tss_eof] = []); 
end;


procedure tpipereader.dochange;
begin
 //dummy
end;

{ tpipereadercomp }

constructor tpipereadercomp.create(aowner: tcomponent);
begin
 fpipereader:= tpipereader.create;
 fpipereader.fowner:= self;
 inherited;
end;

destructor tpipereadercomp.destroy;
begin
 fpipereader.free;
 inherited;
end;

function tpipereadercomp.getoninputavailable: pipereadereventty;
begin
 result:= fpipereader.foninputavailable;
end;

function tpipereadercomp.getonpipebroken: pipereadereventty;
begin
 result:= fpipereader.fonpipebroken;
end;

procedure tpipereadercomp.setoninputavailable(
  const Value: pipereadereventty);
begin
 fpipereader.foninputavailable:= value;
end;

procedure tpipereadercomp.setonpipebroken(const Value: pipereadereventty);
begin
 fpipereader.fonpipebroken:= value;
end;

function tpipereadercomp.getoverloadsleepus: integer;
begin
 result:= fpipereader.overloadsleepus;
end;

procedure tpipereadercomp.setoverloadsleepus(const avalue: integer);
begin
 fpipereader.overloadsleepus:= avalue;
end;

function tpipereadercomp.getopions: pipereaderoptionsty;
begin
 result:= fpipereader.options;
end;

procedure tpipereadercomp.setoptions(const avalue: pipereaderoptionsty);
begin
 fpipereader.options:= avalue;
end;

function tpipereadercomp.getencoding: charencodingty;
begin
 result:= fpipereader.encoding;
end;

procedure tpipereadercomp.setencoding(const avalue: charencodingty);
begin
 fpipereader.encoding:= avalue;
end;

{ tpipereaderpers }

constructor tpipereaderpers.create(const aowner: tmsecomponent);
begin
 fpipereader:= tpipereader.create;
 fpipereader.fowner:= aowner;
 inherited create;
end;

destructor tpipereaderpers.destroy;
begin
 fpipereader.free;
 inherited;
end;

function tpipereaderpers.getoninputavailable: pipereadereventty;
begin
 result:= fpipereader.foninputavailable;
end;

function tpipereaderpers.getonpipebroken: pipereadereventty;
begin
 result:= fpipereader.fonpipebroken;
end;

procedure tpipereaderpers.setoninputavailable(
  const Value: pipereadereventty);
begin
 fpipereader.foninputavailable:= value;
end;

procedure tpipereaderpers.setonpipebroken(const Value: pipereadereventty);
begin
 fpipereader.fonpipebroken:= value;
end;

function tpipereaderpers.getoverloadsleepus: integer;
begin
 result:= fpipereader.overloadsleepus;
end;

procedure tpipereaderpers.setoverloadsleepus(const avalue: integer);
begin
 fpipereader.overloadsleepus:= avalue;
end;

function tpipereaderpers.getopions: pipereaderoptionsty;
begin
 result:= fpipereader.options;
end;

procedure tpipereaderpers.setoptions(const avalue: pipereaderoptionsty);
begin
 fpipereader.options:= avalue;
end;

function tpipereaderpers.getencoding: charencodingty;
begin
 result:= fpipereader.encoding;
end;

procedure tpipereaderpers.setencoding(const avalue: charencodingty);
begin
 fpipereader.encoding:= avalue;
end;

{ tpipewriterpers }

constructor tpipewriterpers.create(const aowner: tmsecomponent);
begin
 fpipewriter:= tpipewriter.create;
 inherited create;
end;

destructor tpipewriterpers.destroy;
begin
 fpipewriter.free;
 inherited;
end;

function tpipewriterpers.getencoding: charencodingty;
begin
 result:= fpipewriter.encoding;
end;

procedure tpipewriterpers.setencoding(const avalue: charencodingty);
begin
 fpipewriter.encoding:= avalue;
end;

{$ifdef UNIX}
var
 sigpipebefore: tsignalhandler;
initialization
  sigpipebefore:= signal(sigpipe,tsignalhandler(sig_ign));
finalization
 signal(sigpipe,sigpipebefore);
{$endif}

end.

