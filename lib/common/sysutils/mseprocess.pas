{ MSEgui Copyright (c) 2010-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseprocess;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseclasses,msepipestream,msestrings,msestatfile,msestat,
 msesystypes,mseevent,msetypes,mseprocmonitor,mseapplication,msedatalist;
const 
 defaultpipewaitus = 0;
type
 processstatety = (prs_listening,prs_waitcursor);
 processstatesty = set of processstatety;
 processoptionty = (pro_output,pro_erroroutput,pro_input,pro_errorouttoout,
                    pro_shell,    //default on linux
                    pro_noshell,  //default on windows,
                    pro_inactive,pro_nostdhandle, //windows only
                    pro_newconsole,pro_nowindow,pro_detached,    //windows only
                    pro_allowsetforegroundwindow, //windows only
                    pro_group,                    //linux only
                    pro_sessionleader,            //linux only
                    pro_settty,                   //linux only
                    pro_tty,pro_echo,pro_icanon,  //linux only
                    pro_nowaitforpipeeof,
                    pro_nopipeterminate,  //not used
                    pro_usepipewritehandles,pro_winpipewritehandles,
                    pro_waitcursor,pro_checkescape,pro_escapekill,
                               //terminate or kill process if esc pressed
                    pro_processmessages,
                    pro_ctrlc                     //for tterminal
                    );
 processoptionsty = set of processoptionty;
const
 defaultprocessoptions = [pro_winpipewritehandles];
             //there is no other way on win32 to 
             //terminate read on a hanging process
 defaultgetprocessoutputoptions = defaultprocessoptions + [pro_inactive];
 defaultgetprocessoutputoptionserrorouttoout = 
                    defaultprocessoptions + [pro_inactive,pro_errorouttoout];
 defaultstartprocessoptions = defaultprocessoptions + [pro_inactive];
 
type   
 tmseprocess = class;
 
 tmseprocess = class(tactcomponent,istatfile,iprocmonitor)
  private
   finput: tpipewriterpers;
   foutput: tpipereaderpers;
   ferroroutput: tpipereaderpers;
   ffilename: filenamety;
   fparameter: msestring;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   factive: boolean;
   fprochandle: prochandlety;
   flastprochandle: prochandlety;
   foptions: processoptionsty;
   fonprocfinished: notifyeventty;
   flistenid: ptruint;
   fexitcode: integer;
   fcommandline: msestring;
   fcommandline1: msestring;
   fworkingdirectory: filenamety;
   fpipewaitus: integer;
   fstatpriority: integer;
   foncheckabort: updatebooleaneventty;
   fparams: tmsestringdatalist;
   fenvvars: tmsestringdatalist;
   procedure setoutput(const avalue: tpipereaderpers);
   procedure seterroroutput(const avalue: tpipereaderpers);
   function getactive: boolean;
   procedure setstatfile(const avalue: tstatfile);
   procedure updatecommandline;
   function getcommandline: msestring;
   procedure setcommandline(const avalue: msestring);
   procedure procend;
   procedure setoptions(const avalue: processoptionsty);
   procedure setinput(const avalue: tpipewriterpers);
   procedure setparams(const avalue: tmsestringdatalist);
   procedure setenvvars(const avalue: tmsestringdatalist);
  protected
   fstate: processstatesty;
   procedure setactive(const avalue: boolean); override;
   procedure loaded; override;
   procedure listen;
   procedure unlisten;
   procedure finalizeexec;
   procedure receiveevent(const event: tobjectevent); override;
   procedure waitforpipeeof;
   procedure doprocfinished;
   procedure postprocessdied;

    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
    //iprocmonitor
   procedure processdied(const aprochandle: prochandlety;
                 const aexecresult: integer; const adata: pointer);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function running: boolean;
   procedure terminate;
   procedure kill;
   function waitforprocess: integer; overload; //returns exitcode
   function waitforprocess(const atimeoutus: integer): boolean; overload;
                                              //true if process finished
   property commandline: msestring read getcommandline write setcommandline;
                 //overrides filename and parameter
   property prochandle: prochandlety read fprochandle;
   property lastprochandle: prochandlety read flastprochandle;
   property exitcode: integer read fexitcode;
  published
   property filename: filenamety read ffilename write ffilename;
   property parameter: msestring read fparameter write fparameter;
   property workingdirectory: filenamety read fworkingdirectory 
                                                write fworkingdirectory;
   property params: tmsestringdatalist read fparams write setparams;
   property envvars: tmsestringdatalist read fenvvars write setenvvars;
   property active: boolean read getactive write setactive default false;
   property options: processoptionsty read foptions write setoptions 
                                                default defaultprocessoptions;
   property pipewaitus: integer read fpipewaitus write fpipewaitus 
                                                 default defaultpipewaitus;
                                                //0 -> infinite
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority 
                                       write fstatpriority default 0;
   property input: tpipewriterpers read finput write setinput;
   property output: tpipereaderpers read foutput write setoutput;
   property erroroutput: tpipereaderpers read ferroroutput write seterroroutput;
   property onprocfinished: notifyeventty read fonprocfinished 
                                                     write fonprocfinished;
   property oncheckabort: updatebooleaneventty 
                          read foncheckabort write foncheckabort;
 end;

function getprocessoutput(const acommandline: msestring; const todata: string;
                         out fromdata: string; out errordata: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
                         //returns program exitcode, -1 in case of error
                         //-2 in case of maxdatalen reached
function getprocessoutput(const acommandline: msestring; const todata: string;
                         out fromdata: string;
                         const atimeout: integer = -1;
                    const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptionserrorouttoout;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
                         //returns program exitcode, -1 in case of error
                         //-2 in case of maxdatalen reached
function getprocessoutput(out prochandle: prochandlety;
                         const acommandline: msestring; const todata: string;
                         out fromdata: string; out errordata: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
                         //returns program exitcode, -1 in case of error
                         //-2 in case of maxdatalen reached
function getprocessoutput(out prochandle: prochandlety;
                         const acommandline: msestring; const todata: string;
                         out fromdata: string;
                         const atimeout: integer = -1;
                    const aoptions: processoptionsty = 
                              defaultgetprocessoutputoptionserrorouttoout;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
                         //returns program exitcode, -1 in case of error
                         //-2 in case of maxdatalen reached

function startprocessandwait(const acommandline: msestring;
                     const atimeout: integer = -1;
                     const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions;
                       const acheckabort: updatebooleaneventty = nil): integer;
                         //returns program exitcode, -1 in case of error
implementation
uses
 mseprocutils,msefileutils,sysutils,msesysintf,msebits,msesys,
 msesysutils;
type
 tstringprocess = class(tmseprocess)
  private
   ffromdata: string;
   ffromcount: sizeint;
   ferrordata: string;
   ferrorcount: sizeint;
   fmaxdatalen: sizeint;
   fmaxdatareached: boolean;
   procedure readdata(const sender: tpipereader;
                                    var adata: string; var acount: sizeint);
   procedure fromavail(const sender: tpipereader);
   procedure erroravail(const sender: tpipereader);
  public
   constructor create(const amaxdatalen: sizeint = 0); reintroduce;
 end;
 
function getprocessoutput1(const prochandlepo: pprochandlety;
               const acommandline: msestring; const todata: string;
               out fromdata: string; out errordata: string;
               const atimeout: integer; const aoptions: processoptionsty;
                             const acheckabort: updatebooleaneventty;
                                     const amaxdatalen: integer): integer;
                         //returns program exitcode, -1 in case of error,
                         //-2 in case of maxdatalen reached
var
 proc1: tstringprocess;
begin
 result:= -1;
 proc1:= tstringprocess.create(amaxdatalen);
 try
  with proc1 do begin
   commandline:= acommandline;
   options:= aoptions + [pro_output,pro_erroroutput,pro_input];
   oncheckabort:= acheckabort;
   active:= true;
   if prochandlepo <> nil then begin
    application.lock;
    prochandlepo^:= prochandle;
    application.unlock;
   end;
   if todata <> '' then begin
    try
     input.pipewriter.write(todata);
    except
    end;
    input.pipewriter.close;
   end;
   if atimeout < 0 then begin
    result:= waitforprocess;
   end
   else begin
    if waitforprocess(atimeout) then begin
     result:= exitcode;
    end;
   end;
   if fmaxdatareached then begin
    result:= -2;
   end;
   if result <> -1 then begin
    setlength(proc1.ffromdata,proc1.ffromcount);
    fromdata:= proc1.ffromdata;
    setlength(proc1.ferrordata,proc1.ferrorcount);
    errordata:= proc1.ferrordata;
   end;
  end;
 finally
  application.lock;
  if prochandlepo <> nil then begin
   prochandlepo^:= invalidprochandle;
  end;
  proc1.release;
//  proc1.free; //calls application.unlockall
  application.unlock;
 end;
end;

function startprocessandwait(const acommandline: msestring;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                                            defaultstartprocessoptions;
                       const acheckabort: updatebooleaneventty = nil): integer;
                         //returns program exitcode, -1 in case of error
                         //-2 in case of maxdatalen reached
var
 proc1: tmseprocess;
begin
 result:= -1;
 proc1:= tmseprocess.create(nil);
 try
  with proc1 do begin
   commandline:= acommandline;
   options:= aoptions - [pro_output,pro_erroroutput,pro_input];
   oncheckabort:= acheckabort;
   active:= true;
   if atimeout < 0 then begin
    result:= waitforprocess;
   end
   else begin
    if waitforprocess(atimeout) then begin
     result:= exitcode;
    end;
   end;
  end;
 finally
  proc1.free;
 end;
end;

function getprocessoutput(const acommandline: msestring; const todata: string;
                         out fromdata: string; out errordata: string;
                         const atimeout: integer = -1;
                          const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
begin
 result:= getprocessoutput1(nil,acommandline,todata,fromdata,errordata,
                                 atimeout,aoptions,acheckabort,amaxdatalen);
end;
 
function getprocessoutput(const acommandline: msestring; const todata: string;
                         out fromdata: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                      defaultgetprocessoutputoptionserrorouttoout;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
var
 str1: string;
begin
 result:= getprocessoutput1(nil,acommandline,todata,fromdata,str1,
                                atimeout,aoptions,acheckabort,amaxdatalen);
end;

function getprocessoutput(out prochandle: prochandlety;
                         const acommandline: msestring; const todata: string;
                         out fromdata: string; out errordata: string;
                         const atimeout: integer = -1;
                          const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
begin
 result:= getprocessoutput1(@prochandle,acommandline,todata,fromdata,errordata,
                                atimeout,aoptions,acheckabort,amaxdatalen);
end;
 
function getprocessoutput(out prochandle: prochandlety;
                         const acommandline: msestring; const todata: string;
                         out fromdata: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                          defaultgetprocessoutputoptionserrorouttoout;
                       const acheckabort: updatebooleaneventty = nil;
                       const amaxdatalen: integer = 0): integer;
var
 str1: string;
begin
 result:= getprocessoutput1(@prochandle,acommandline,todata,fromdata,str1,
                                 atimeout,aoptions,acheckabort,amaxdatalen);
end;
 
{ tmseprocess }

constructor tmseprocess.create(aowner: tcomponent);
begin
 foptions:= defaultprocessoptions;
 fprochandle:= invalidprochandle;
 finput:= tpipewriterpers.create(self);
 foutput:= tpipereaderpers.create(self);
 ferroroutput:= tpipereaderpers.create(self);
 fpipewaitus:= defaultpipewaitus;
 fparams:= tmsestringdatalist.create;
 fenvvars:= tmsestringdatalist.create;
 inherited;
end;

destructor tmseprocess.destroy;
begin
 finalizeexec();
 finput.free();    
 foutput.free();         //calls application.unlockall
 ferroroutput.free();    //calls application.unlockall
 fparams.free();
 fenvvars.free();
 inherited;
// finput.free;
// foutput.free;
// ferroroutput.free;
end;

procedure tmseprocess.setoutput(const avalue: tpipereaderpers);
begin
 foutput.assign(avalue);
end;

procedure tmseprocess.seterroroutput(const avalue: tpipereaderpers);
begin
 ferroroutput.assign(avalue);
end;

function tmseprocess.getactive: boolean;
begin
 if componentstate * [csloading,csdesigning] <> [] then begin
  result:= factive;
 end
 else begin
  result:= fprochandle <> invalidprochandle;
 end;
end;

procedure tmseprocess.doprocfinished;
begin
 if canevent(tmethod(fonprocfinished)) then begin
  fonprocfinished(self);
 end;
 {
 if not (pro_nopipeterminate in foptions) then begin
  foutput.pipereader.terminate;
  ferroroutput.pipereader.terminate;
 end;
 }
end;

procedure tmseprocess.procend;
begin  
 fprochandle:= invalidprochandle;
 foutput.pipereader.writehandle:= invalidfilehandle;
 ferroroutput.pipereader.writehandle:= invalidfilehandle;
 waitforpipeeof;
 if prs_waitcursor in fstate then begin
  exclude(fstate,prs_waitcursor);
  application.endwait;
 end;
 finalizeexec();
 doprocfinished;
end;

procedure tmseprocess.postprocessdied;
begin
 exclude(fstate,prs_listening);
 application.postevent(tchildprocevent.create(ievent(self),fprochandle,
                                   fexitcode,pointer(flistenid)));
 fprochandle:= invalidprochandle;
end;

procedure tmseprocess.setactive(const avalue: boolean);
var
 outp: tpipereader;
 erroroutp: tpipereader;
 inp: tpipewriter;
 sessionleader: boolean;
 group: integer;
 opt1: execoptionsty;
// str1: ansistring;
// mstr1: msestring;
begin
 sessionleader:= false;
 group:= -1;
 if componentstate * [csloading,csdesigning] <> [] then begin
  factive:= avalue;
 end
 else begin
  if avalue <> active then begin
   outp:= nil;
   erroroutp:= nil;
   inp:= nil;
   finalizeexec();
   if avalue then begin
    application.lock;
    try
     updatecommandline;
     if pro_output in foptions then begin
      outp:= foutput.pipereader;
     end;
     if pro_erroroutput in foptions then begin
      erroroutp:= ferroroutput.pipereader;
     end
     else begin
      if pro_errorouttoout in foptions then begin
       erroroutp:= foutput.pipereader;
      end;
     end;
     if pro_input in foptions then begin
      inp:= finput.pipewriter;
     end;
     if pro_group in foptions then begin
      group:= 0;
     end;
     if pro_sessionleader in foptions then begin
      sessionleader:= true;
      group:= -1;
     end;
     opt1:= [];
     if sessionleader then begin
      include(opt1,exo_sessionleader);
     end;
     if pro_settty in foptions then begin
      include(opt1,exo_settty);
     end;
     if pro_shell in foptions then begin
      include(opt1,exo_shell);
     end;
     if pro_noshell in foptions then begin
      include(opt1,exo_noshell);
     end;
     if pro_inactive in foptions then begin
      include(opt1,exo_inactive);
     end;
     if pro_tty in foptions then begin
      include(opt1,exo_tty);
     end;
     if pro_echo in foptions then begin
      include(opt1,exo_echo);
     end;
     if pro_icanon in foptions then begin
      include(opt1,exo_icanon);
     end;
     if pro_nostdhandle in foptions then begin
      include(opt1,exo_nostdhandle);
     end;
     if pro_newconsole in foptions then begin
      include(opt1,exo_newconsole);
     end;
     if pro_nowindow in foptions then begin
      include(opt1,exo_nowindow);
     end;
     if pro_detached in foptions then begin
      include(opt1,exo_detached);
     end;
     if pro_allowsetforegroundwindow in foptions then begin
      include(opt1,exo_allowsetforegroundwindow);
     end;
     if pro_usepipewritehandles in foptions then begin
      include(opt1,exo_usepipewritehandles);
     end;
     if pro_winpipewritehandles in foptions then begin
      include(opt1,exo_winpipewritehandles);
     end;
     {
     if fworkingdirectory <> '' then begin
      mstr1:= filepath(fworkingdirectory);
      sys_tosysfilepath(mstr1);
      str1:= mstr1;
     end;
     }
     try
      fprochandle:= execmse2(syscommandline(fcommandline1),
                       inp,outp,erroroutp,group,opt1,fworkingdirectory,
                       fparams.asarray,fenvvars.asarray);
//      fprochandle:= execmse2(syscommandline(fcommandline1),
//                                    inp,outp,erroroutp,group,opt1,str1);
     except
      fprochandle:= invalidprochandle;
      flastprochandle:= invalidprochandle;
      finalizeexec();
      fexitcode:= -1;
      raise;
     end;
     flastprochandle:= fprochandle;
     if fprochandle = invalidprochandle then begin
      finalizeexec;
     end
     else begin
      if pro_waitcursor in foptions then begin
       include(fstate,prs_waitcursor);
       application.beginwait;
      end;
      listen;
     end;
    finally
     application.unlock;
    end;
   end;
  end;
 end;
end;

procedure tmseprocess.receiveevent(const event: tobjectevent);
begin
 if (event.kind = ek_childproc) then begin 
  with tchildprocevent(event) do begin
   if data = pointer(flistenid) then begin
    procend;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

function tmseprocess.waitforprocess(const atimeoutus: integer): boolean;
                                              //true if process finished
var
 int1: integer;
 bo1: boolean;
 ts1: longword;
 procerr: processexiterrorty;
 i2: int32;
begin
 result:= false;
 procerr:= pee_ok;
 bo1:= prs_listening in fstate;
 unlisten;
 if bo1 then begin
  int1:= application.unlockall;
  if (foptions*[pro_checkescape,pro_processmessages] <> []) or 
              assigned(foncheckabort) then begin
   ts1:= timestep(atimeoutus);
   i2:= 100000;
   if (atimeoutus >= 0) and (atimeoutus < i2) then begin
    i2:= atimeoutus;
   end;
   repeat
    if pro_processmessages in foptions then begin
     application.relockall(int1);
     application.processmessages;
     int1:= application.unlockall;
    end;
    procerr:= mseprocutils.getprocessexitcode(fprochandle,fexitcode,i2);
    bo1:= (procerr <> pee_timeout) or ((atimeoutus >= 0) and timeout(ts1));
    if not bo1 then begin
     if (pro_checkescape in foptions) then begin
      bo1:= application.waitescaped;
     end;
     if assigned(foncheckabort) then begin
      foncheckabort(self,bo1);
     end;
    end; 
   until bo1;
   result:= procerr = pee_ok;
   if not result then begin
    if pro_escapekill in foptions then begin
     killprocess(fprochandle);
    end
    else begin
     terminateprocess(fprochandle);
    end;
    procend;
   end;
  end
  else begin
   procerr:= mseprocutils.getprocessexitcode(fprochandle,fexitcode,atimeoutus);
   result:= procerr = pee_ok;
  end;
  application.relockall(int1);
 end
 else begin
  result:= true;
 end;
 if result or (procerr = pee_error) then begin
  procend();
 end;
end;

function tmseprocess.waitforprocess: integer;
begin
 result:= -1;
 if waitforprocess(-1) then begin
  result:= fexitcode;
 end;
end;

procedure tmseprocess.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

function tmseprocess.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tmseprocess.dostatread(const reader: tstatreader);
begin
 ffilename:= reader.readmsestring('file',ffilename);
 fparameter:= reader.readmsestring('param',fparameter);
end;

procedure tmseprocess.dostatwrite(const writer: tstatwriter);
begin
 writer.writemsestring('file',ffilename);
 writer.writemsestring('param',fparameter);
end;

procedure tmseprocess.statreading;
begin
 //dummy
end;

procedure tmseprocess.statread;
begin
 //dummy
end;

procedure tmseprocess.loaded;
begin
 inherited;
 active:= factive;
end;

procedure tmseprocess.listen;
begin
 application.lock;
 if not (prs_listening in fstate) and 
                      (fprochandle <> invalidprochandle) then begin
  pro_listentoprocess(fprochandle,iprocmonitor(self),pointer(flistenid));
  include(fstate,prs_listening);
 end;
 application.unlock;
end;

procedure tmseprocess.unlisten;
begin
 application.lock;
 try
  inc(flistenid);
  if prs_listening in fstate then begin
   pro_unlistentoprocess(fprochandle,iprocmonitor(self));   
  end;
  exclude(fstate,prs_listening);
 finally
  application.unlock;
 end;
end;

procedure tmseprocess.finalizeexec;
begin
 finput.pipewriter.close();
 foutput.pipereader.terminateandwait();
 ferroroutput.pipereader.terminateandwait();
 application.lock;
 unlisten;
 if fprochandle <> invalidprochandle then begin
  pro_killzombie(fprochandle);
  fprochandle:= invalidprochandle;
 end;
 application.unlock;
 foutput.pipereader.close();
 ferroroutput.pipereader.close();
end;

procedure tmseprocess.waitforpipeeof;
var
 int1,int2,int3: integer;
 lwo1: longword;
begin
 if not (pro_nowaitforpipeeof in foptions) then begin
  int1:= application.unlockall;
  int2:= foutput.pipereader.overloadsleepus;
  int3:= ferroroutput.pipereader.overloadsleepus;
  foutput.pipereader.overloadsleepus:= 0;
  ferroroutput.pipereader.overloadsleepus:= 0;
  lwo1:= timestep(fpipewaitus);
//  sleepus(0); //shed_yield
  sys_schedyield();
  while not (foutput.pipereader.eof and ferroroutput.pipereader.eof) and 
                            ((fpipewaitus = 0) or not timeout(lwo1)) do begin
   sleepus(1000); //wait for last chars
  end;
  application.relockall(int1);
  if (foutput.pipereader.eof and ferroroutput.pipereader.eof) then begin
   foutput.pipereader.waitfor;          //process data
   ferroroutput.pipereader.waitfor;     //process data
  end;
  foutput.pipereader.overloadsleepus:= int2;
  ferroroutput.pipereader.overloadsleepus:= int3;
 end;
end;

procedure tmseprocess.processdied(const aprochandle: prochandlety;
               const aexecresult: integer; const adata: pointer);
begin
 if (prs_listening in fstate) and (adata = pointer(flistenid)) then begin
  fexitcode:= aexecresult;
  postprocessdied;
 end
end;

procedure tmseprocess.updatecommandline;
begin
 if fcommandline <> '' then begin
  fcommandline1:= fcommandline;
 end
 else begin
  fcommandline1:= tosysfilepath(ffilename);
  if fparameter <> '' then begin
   fcommandline1:= fcommandline1 + ' ' + fparameter;
  end;
 end;
end;

function tmseprocess.getcommandline: msestring;
begin
 updatecommandline;
 result:= fcommandline1;
end;

procedure tmseprocess.setcommandline(const avalue: msestring);
begin
 fcommandline:= avalue;
end;


{
function tmseprocess.waitforprocess: integer;
var
 int1: integer;
begin
 int1:= application.unlockall;
 try
  unlisten;
  result:= fexitcode;
  if running then begin
   result:= mseprocutils.waitforprocess(fprochandle);
   fexitcode:= result;
   procend;
  end;
 finally
  application.relockall(int1);
 end;
end;

function tmseprocess.waitforprocess(const atimeoutus: integer): boolean;
                                              //true if process finished
var
 int1: integer;
begin
 int1:= application.unlockall;
 try
  unlisten;
  if running then begin
   result:= mseprocutils.getprocessexitcode(fprochandle,fexitcode,atimeoutus);
   if result then begin
    procend;
   end
   else begin
    application.lock;
    try
     listen;
     result:= mseprocutils.getprocessexitcode(fprochandle,fexitcode,0);
     if result then begin
      unlisten;
     end;
    finally
     application.unlock;
    end;
    if result then begin
     procend;
    end;
   end;
  end
  else begin
   result:= true;
  end;
 finally
  application.relockall(int1);
 end;
end;
}

function tmseprocess.running: boolean;
begin
 result:= fprochandle <> invalidprochandle;
end;

procedure tmseprocess.terminate;
begin
{$ifdef mswindows}
 kill();
{$else}
 application.lock;
 try
  if running then begin
   syserror(sys_terminateprocess(fprochandle));
  end;
 finally
  application.unlock;
 end;
{$endif}
end;

procedure tmseprocess.kill;
begin
 application.lock;
 try
  if running then begin
   finput.pipewriter.close;
   syserror(sys_killprocess(fprochandle));
   foutput.pipereader.terminate;
   ferroroutput.pipereader.terminate;
//   syserror(sys_killprocess(fprochandle));
  end;
 finally
  application.unlock;
 end;
end;

procedure tmseprocess.setoptions(const avalue: processoptionsty);
{$ifndef FPC}
const
 mask1: processoptionsty = [pro_erroroutput,pro_errorouttoout];
 mask2: processoptionsty = [pro_shell,pro_noshell];
 mask3: processoptionsty = [pro_sessionleader,pro_group];
{$endif}
begin
 foptions:= processoptionsty(
 {$ifdef FPC}
   setsinglebit(longword(avalue),
                longword(foptions),
                [longword([pro_erroroutput,pro_errorouttoout]),
                 longword([pro_shell,pro_noshell]),
                 longword([pro_sessionleader,pro_group])]));
 {$else}
   setsinglebitar32(longword(avalue),
                longword(foptions),
                [longword(mask1),longword(mask2),longword(mask3)]));
 {$endif}
 exclude(foptions,pro_nopipeterminate);
 if foptions * [pro_nowaitforpipeeof{,pro_nopipeterminate}] = [] then begin
  exclude(foptions,pro_usepipewritehandles);
 end;
end;

function tmseprocess.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

procedure tmseprocess.setinput(const avalue: tpipewriterpers);
begin
 finput.assign(avalue);
end;

procedure tmseprocess.setparams(const avalue: tmsestringdatalist);
begin
 fparams.assign(avalue);
end;

procedure tmseprocess.setenvvars(const avalue: tmsestringdatalist);
begin
 fenvvars.assign(avalue);
end;

{ tstringprocess }

constructor tstringprocess.create(const amaxdatalen: sizeint = 0);
begin
 fmaxdatalen:= amaxdatalen;
 inherited create(nil);
 options:= options + [pro_output,pro_erroroutput,pro_input];
 output.pipereader.oninputavailable:= {$ifdef FPC}@{$endif}fromavail;
 erroroutput.pipereader.oninputavailable:= {$ifdef FPC}@{$endif}erroravail;
end;

procedure tstringprocess.readdata(const sender: tpipereader;
                                    var adata: string; var acount: sizeint);
begin
 if sender.active then begin
  if adata = '' then begin
   adata:= sender.readbuffer; //try to get complete small results without
                              //buffer oversize
   acount:= length(adata);
  end
  else begin
   sender.appenddatastring(adata,acount);
  end;
  if (fmaxdatalen > 0) and (acount > fmaxdatalen) then begin
   kill();
   fmaxdatareached:= true;
  end;
 end;
end;

procedure tstringprocess.fromavail(const sender: tpipereader);
begin
 readdata(sender,ffromdata,ffromcount);
end;

procedure tstringprocess.erroravail(const sender: tpipereader);
begin
 readdata(sender,ferrordata,ferrorcount);
end;

end.
