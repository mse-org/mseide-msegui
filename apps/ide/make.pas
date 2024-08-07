{ MSEide Copyright (c) 1999-2013 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit make;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses

 msetypes,msestrings,msepipestream,msesystypes;

procedure domake(atag: integer);
procedure abortmake;
function making: boolean;
function buildmakecommandline(const atag: integer): msestring;
function addmessagetext(const sender: tpipereader;
                              const procid: pprocidty): string;

procedure dodownload;
procedure abortdownload;
function downloading: boolean;
function downloadresult: integer;
function runscript(const script: filenamety;
                             const clearscreen,setmakedir: boolean): boolean;
{$ifdef darwin}
procedure RunWithoutDebugMac(Const AFilename: String; Aparam: String);
 var 
 targetcons: boolean = false;
{$endif}                             

implementation
uses
  {$IFDEF darwin}
   Process,
   debuggerform,
   targetconsole,
  {$ENDIF}
 mseprocutils,main,projectoptionsform,sysutils,msegrids,
 sourceform,mseeditglob,msefileutils,msesys,
 msesysutils,msegraphics,messageform,msedesignintf,msedesigner,
 mseprocmonitor,mseevent,
 classes,mclasses,mseclasses,mseapplication,msestream,
 msegui,actionsmodule;

type
 tprogrunner = class(tactcomponent)
  private
   fexitcode: integer;
   fmessagefile: ttextstream;
   fnofilecopy: boolean;
   ffinished: boolean;
   fmessagefinished: boolean;
   fsetmakedir: boolean;
   messagepipe: tpipereader;
  protected
   fcanceled: boolean;
   procid: integer;
   procedure doasyncevent(var atag: integer); override;
   procedure inputavailable(const sender: tpipereader);
   procedure messagefinished(const sender: tpipereader);
   procedure dofinished; virtual;
   function getcommandline: msestring; virtual;
   procedure runprog(const acommandline: msestring);
  public
   constructor create(const aowner: tcomponent;
                         const clearscreen,setmakedir: boolean); reintroduce;
   destructor destroy; override;
 end;

 tscriptrunner = class(tprogrunner)
  private
   fscriptpath: filenamety;
  protected
   function getcommandline: msestring; override;
   procedure dofinished; override;
  public
   constructor create(const aowner: tcomponent; const ascriptpath: filenamety;
                                         const clearscreen,setmakedir: boolean);
   property exitcode: integer read fexitcode;
   property canceled: boolean read fcanceled;
 end;

 makestepty = (maks_before,maks_make,maks_after,maks_finished);
 tmaker = class(tprogrunner)
  private
   ftargettimestamp: tdatetime;
   fmaketag: integer;
   fstep: makestepty;
   fscriptnum: integer;
   fcurrentdir: filenamety;
  protected
   procedure doasyncevent(var atag: integer); override;
   procedure dofinished; override;
   function getcommandline: msestring; override;
  public
   constructor create(atag: integer); reintroduce;
 end;

 tloader = class(tprogrunner)
  protected
   procedure dofinished; override;
   function getcommandline: msestring; override;
  public
   constructor create(aowner: tcomponent);
 end;

var
 maker: tmaker;
 loader: tloader;
 
{$ifdef darwin}
procedure RunWithoutDebugMac(Const AFilename: String; Aparam: String);

var 
  AProcess: TProcess;
  thecommand: string;
  AStringList: TStringList;
  BytesRead    : longint;
  Buffer       : array[1..2048] of byte;
  OutputStream, OutputStream2 : TStream;

begin

  AProcess := TProcess.Create(Nil);

  {$WARN SYMBOL_DEPRECATED OFF}
  AProcess.CommandLine := ansistring(tosysfilepath(filepath(UTF8Decode(AFilename), fk_file, True))) + ' ' + Aparam;
  {$WARN SYMBOL_DEPRECATED ON}

  AProcess.Options := [poUsePipes];

  if targetcons  = false then
     messagefo.messages.clear else targetconsolefo.clear;

  application.processmessages;

  AProcess.Execute;

  AStringList := TStringList.Create;

  OutputStream := TMemoryStream.Create;

  repeat
    BytesRead := AProcess.Output.Read(Buffer, 2048);

    OutputStream.write(Buffer, BytesRead);

    OutputStream2 := OutputStream;

    OutputStream2.Position := 0;

    AStringList.LoadFromStream(OutputStream2);

    if targetcons  = false then
       messagefo.addtext(AStringList.text) else   
       targetconsolefo.addtext(AStringList.text);

    application.processmessages;

  until BytesRead = 0;
 
  if targetcons  = false then
    messagefo.messages.clear else targetconsolefo.clear;

  OutputStream.Position := 0;
  
  AStringList.LoadFromStream(OutputStream);

  if targetcons  = false then
       messagefo.addtext(AStringList.text) else   
       targetconsolefo.addtext(AStringList.text);

  mainfo.setstattext('Process done', mtk_finished);

  // debuggerfo.project_make.Enabled := True;

  AStringList.Free;
  AProcess.Free;
  OutputStream.Free;
  targetcons  := false;
end;
{$endif} 

function making: boolean;
begin
 result:= (maker <> nil) and (maker.procid <> invalidprochandle);
end;

function downloading: boolean;
begin
 result:= (loader <> nil) and (loader.procid <> invalidprochandle);
end;

function downloadresult: integer;
begin
 result:= -1;
 if loader <> nil then begin
  result:= loader.fexitcode;
 end;
end;

procedure killmake;
begin
 freeandnil(maker);
end;

procedure killload;
begin
 freeandnil(loader);
end;

procedure domake(atag: integer);
var
 bo1: boolean;
begin
 killmake;
 bo1:= false;
 designnotifications.beforemake(idesigner(designer),atag,bo1);
 if not bo1 then begin
  maker:= tmaker.Create(atag);
  if projectoptions.s.closemessages then begin
   messagefo.messages.show;
  end;
 end;
end;

procedure abortmake;
begin
 if maker <> nil then begin
  killmake;
  mainfo.setstattext(actionsmo.c[ord(ac_makeaborted)],mtk_error);
 end;
end;

procedure abortdownload;
begin
 if loader <> nil then begin
  killload;
  mainfo.setstattext(actionsmo.c[ord(ac_downloadaborted)],mtk_error);
 end;
end;

function buildmakecommandline(const atag: integer): msestring;

 function normalizename(const aname: filenamety): filenamety;
 begin
  result:= tosysfilepath(filepath(trim(aname),fk_file,true));
 end;

var
 int1,int2,step: integer;
 str1,str2,str3: msestring;
 ar1: filenamearty;
// wstr1: filenamety;
begin
 with projectoptions,k,texp do begin
  if makecommand = '' then begin
   result:= '';
   exit;
  end;
  unquotefilename(makecommand,ar1);
  if ar1 <> nil then begin
   tosysfilepath1(ar1[0]);
  end;
  str3:= quotefilename(ar1);
  str1:= str3;
  if (targetfile <> '') and (targpref <> '') then begin
   str1:= str1 + ' '+quotefilename(targpref+normalizename(targetfile));
  end;
  int2:= high(unitdirs);
  int1:= high(unitdirson);
  if int1 < int2 then begin
   int2:= int1;
  end;
  if not projectoptions.k.reversepathorder then begin
   int1:= int2;
   int2:= -1;
   step:= -1;
  end
  else begin
   int1:= 0;
   int2:= int2+1;
   step:= 1;
  end;
  while int1 <> int2 do begin
//  for int1:= int1 to int2 do begin
   if (atag and unitdirson[int1] <> 0) and
         (unitdirs[int1] <> '') then begin
    str2:= normalizename(unitdirs[int1]);
    if unitdirson[int1] and $10000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(unitpref+str2);
    end;
    if unitdirson[int1] and $20000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(incpref+str2);
    end;
    if unitdirson[int1] and $40000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(libpref+str2);
    end;
    if unitdirson[int1] and $80000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(objpref+str2);
    end;
   end;
   inc(int1,step);
  end;
  for int1:= 0 to high(makeoptions) do begin
   if makeoptionson[int1] and optaftermainfilemask = 0 then begin
    if (atag and makeoptionson[int1] <> 0) and
          (makeoptions[int1] <> '') then begin
     str1:= str1 + ' ' + makeoptions[int1];
    end;
   end;
  end;
  str1:= str1 + ' ' + quotefilename(normalizename(mainfile));
  for int1:= 0 to high(makeoptions) do begin
   if makeoptionson[int1] and optaftermainfilemask <> 0 then begin
    if (atag and makeoptionson[int1] <> 0) and
          (makeoptions[int1] <> '') then begin
     str1:= str1 + ' ' + makeoptions[int1];
    end;
   end;
  end;
 end;
 result:= str1;
end;

procedure dodownload;
begin
 killload;
 if projectoptions.s.closemessages then begin
  messagefo.messages.show;
 end;
 loader:= tloader.create(nil);
end;

function runscript(const script: filenamety;
                            const clearscreen,setmakedir: boolean): boolean;
var
 runner: tscriptrunner;
begin
 result:= script = '';
 if not result then begin
  runner:= tscriptrunner.create(nil,script,clearscreen,setmakedir);
  try
   result:= not runner.canceled and (runner.fexitcode = 0);
  finally
   runner.release;
  end;
 end;
end;

{ tprogrunner }

constructor tprogrunner.create(const aowner: tcomponent;
                              const clearscreen,setmakedir: boolean);
begin
 inherited create(aowner);
 with projectoptions,s.texp do begin
  if s.copymessages and (messageoutputfile <> '') and not fnofilecopy then begin
   fmessagefile:= ttextstream.create(messageoutputfile,fm_create);
  end;
  messagepipe:= tpipereader.create;
  messagepipe.oninputavailable:= {$ifdef FPC}@{$endif}inputavailable;
  messagepipe.onpipebroken:= {$ifdef FPC}@{$endif}messagefinished;
  if clearscreen then begin
   messagefo.messages.rowcount:= 0;
  end;
  procid:= invalidprochandle;
  fsetmakedir:= setmakedir;
  runprog(getcommandline);
 end;
end;

destructor tprogrunner.destroy;
begin
 if (procid <> invalidprochandle) then begin
  try
   killprocess(procid);
  except
  end;
  procid:= invalidprochandle;
 end;
 messagepipe.Free;
 fmessagefile.free;
 inherited;
end;

procedure tprogrunner.runprog(const acommandline: msestring);
var
 wdbefore: filenamety;
begin
 if acommandline = '' then begin
  fexitcode:= 0;
  fmessagefinished:= true;
  ffinished:= true;
  exit;
 end;
 fexitcode:= 1; //defaulterror
 fmessagefinished:= false;
 ffinished:= false;
 procid:= invalidprochandle;
 
 {$ifdef darwin}
 procid:= 0;
 {$else}
  procid:= invalidprochandle; 
 {$endif} 
 
 with projectoptions,k.texp do begin
  if fsetmakedir and (makedir <> '') then begin
   wdbefore:= setcurrentdirmse(makedir);
  end;
  try

 {$ifdef darwin}
  targetcons  := false;
  mainfo.setstattext('Compiling ' + gettargetfile + '...' , mtk_signal);
  RunWithoutDebugMac(ansistring(acommandline), '');
 {$else}
  procid:= execmse2(UTF8Decode(acommandline),nil,messagepipe,messagepipe,-1,[exo_inactive,exo_tty]);
 {$endif} 
    
  except
   on e1: exception do begin
    fcanceled:= true;
    if e1 is eoserror then begin
{$warnings off}
     fexitcode:= eoserror(e).error;
{$warnings on}
    end;
    application.handleexception(nil,actionsmo.c[ord(ac_runerrorwith)]+
                                                msestring(acommandline)+'": ');
   end;
  end;
  if fsetmakedir and (makedir <> '') then begin
   setcurrentdirmse(wdbefore);
  end;
 end;
end;

procedure tprogrunner.doasyncevent(var atag: integer);
begin
 if getprocessexitcode(procid,fexitcode,5000000) <> pee_ok then begin
  messagefo.messages.appendrow([actionsmo.c[ord(ac_errortimeout)]]);
  messagefo.messages.appendrow(['']);
  killprocess(procid);
 end;
 procid:= invalidprochandle;
end;

procedure tprogrunner.dofinished;
begin
 ffinished:= true;
 asyncevent(0);
end;

procedure tprogrunner.messagefinished(const sender: tpipereader);
begin
 fmessagefinished:= true;
 dofinished;
end;

function addmessagetext(const sender: tpipereader;
                                         const procid: pprocidty): string;
var
 str1: string;
begin
 result:= '';
 str1:= sender.readdatastring;
 while application.checkoverload(-1) do begin
  if (procid <> nil) and (procid^ = invalidprochandle) then begin
   exit;
  end;
  application.unlock;
  sleepus(100000);
  application.lock;
 end;
 messagefo.addtext(str1);
 result:= str1;
end;

procedure tprogrunner.inputavailable(const sender: tpipereader);
var
 str1: string;
begin
 str1:= addmessagetext(sender,@procid);
 if fmessagefile <> nil then begin
  fmessagefile.writestr(str1);
 end;
end;

function tprogrunner.getcommandline: msestring;
begin
 result:= ''; //dummy
end;

{ tmaker }

constructor tmaker.create(atag: integer);
begin
 fstep:= maks_before;
 fmaketag:= atag;
 ftargettimestamp:= getfilemodtime(gettargetfile);
 fcurrentdir:= getcurrentdirmse;
 inherited create(nil,true,true);
 if procid <> invalidprochandle then begin
  
  {$ifndef darwin}
  mainfo.setstattext(actionsmo.c[ord(ac_making)],mtk_running);
 {$endif} 
  
  messagefo.messages.font.options:= messagefo.messages.font.options +
                                                      [foo_nonantialiased];
 end
 else begin
  mainfo.setstattext(actionsmo.c[ord(ac_makenotrunning)],mtk_error);
  designnotifications.aftermake(idesigner(designer),fexitcode);
 end;
end;

procedure tmaker.dofinished;
begin
 if ftargettimestamp <> getfilemodtime(gettargetfile) then begin
  mainfo.targetfilemodified;
 end;
 inherited;
end;

function tmaker.getcommandline: msestring;
begin
 result:= '';
 with projectoptions,k do begin
  if fstep = maks_before then begin
   while fscriptnum <= high(befcommandon) do begin
    if (befcommandon[fscriptnum] and fmaketag <> 0) and
                           (fscriptnum <= high(texp.befcommand)) then begin
     result:= k.texp.befcommand[fscriptnum];
     break;
    end;
    inc(fscriptnum);
   end;
   if fscriptnum <= high(befcommandon) then begin
    inc(fscriptnum);
    exit;
   end
   else begin
    fstep:= maks_make;
   end;
  end;
  if fstep = maks_make then begin
   result:= buildmakecommandline(fmaketag);
   fscriptnum:= 0;
   fstep:= maks_after;
   exit;
  end;
  if fstep = maks_after then begin
   while fscriptnum <= high(aftcommandon) do begin
    if (aftcommandon[fscriptnum] and fmaketag <> 0) and
                           (fscriptnum <= high(k.texp.aftcommand)) then begin
     result:= k.texp.aftcommand[fscriptnum];
     break;
    end;
    inc(fscriptnum);
   end;
   if fscriptnum <= high(aftcommandon) then begin
    inc(fscriptnum);
    exit;
   end
   else begin
    fstep:= maks_finished;
   end;
  end;
 end;
end;

procedure tmaker.doasyncevent(var atag: integer);
 procedure finished;
 begin
  setcurrentdirmse(fcurrentdir);
  designnotifications.aftermake(idesigner(designer),fexitcode);
  messagefo.messages.font.options:= messagefo.messages.font.options +
              [foo_antialiased2];
 end;
var
 str1: msestring;
begin
 inherited;
 str1:= getcommandline;
 if (fstep = maks_finished) or (fexitcode <> 0) then begin
  finished;
 end
 else begin
  runprog(str1);
  if procid = invalidprochandle then begin
   finished;
  end;
 end;
end;

{ tloader }

constructor tloader.create(aowner: tcomponent);
begin
 inherited create(aowner,false,true);
 if procid <> invalidprochandle then begin
  mainfo.setstattext(actionsmo.c[ord(ac_downloading)],mtk_running);
 end
 else begin
  mainfo.setstattext(actionsmo.c[ord(ac_downloadnotrunning)],mtk_error);
 end;
end;

procedure tloader.dofinished;
begin
 inherited;
end;

function tloader.getcommandline: msestring;
begin
 result:= projectoptions.d.texp.uploadcommand;
end;

{ tscriptrunner }

constructor tscriptrunner.create(const aowner: tcomponent;
               const ascriptpath: filenamety; const clearscreen: boolean;
               const setmakedir: boolean);
begin
 fscriptpath:= tosysfilepath(ascriptpath);
 fnofilecopy:= true;
 if clearscreen then begin
  messagefo.messages.rowcount:= 0;
 end;
 messagefo.messages.appendrow(ascriptpath);
 messagefo.messages.appendrow('');
 inherited create(aowner,false,setmakedir);
 if not fcanceled then begin
  fcanceled:= not application.waitdialog(nil,'"'+ascriptpath+
               actionsmo.c[ord(ac_running)],
     actionsmo.c[ord(ac_script)],nil,nil,nil);
 end;
end;

function tscriptrunner.getcommandline: msestring;
begin
 result:= fscriptpath;
end;

procedure tscriptrunner.dofinished;
begin
 inherited;
 application.terminatewait;
end;

end.
