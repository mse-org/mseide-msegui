{ MSEgui Copyright (c) 2010-2012 by Martin Schreiber

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
 classes,mseclasses,msepipestream,msestrings,msestatfile,msestat,msesystypes,
 mseevent,msetypes,mseprocmonitor;
const 
 defaultpipewaitus = 0;
type
 processstatety = (prs_listening,prs_waitcursor);
 processstatesty = set of processstatety;
 processoptionty = (pro_output,pro_erroroutput,pro_input,pro_errorouttoout,
                    pro_tty,pro_echo,pro_icanon,  //linux only
                    pro_nowaitforpipeeof,pro_nopipeterminate,
                    pro_inactive,pro_nostdhandle, //windows only
                    pro_waitcursor,pro_checkescape,pro_processmessages,
                               //kill process if esc pressed
                    pro_ctrlc                     //for tterminal
                    );
 processoptionsty = set of processoptionty;
const
 defaultgetprocessoutputoptions = [pro_inactive];
 defaultgetprocessoutputoptionserrorouttoout = [pro_inactive,pro_errorouttoout];
 defaultstartprocessoptions = [pro_inactive];
 
type   
 tmseprocess = class(tmsecomponent,istatfile,iprocmonitor)
  private
   finput: tpipewriter;
   foutput: tpipereaderpers;
   ferroroutput: tpipereaderpers;
   ffilename: filenamety;
   fparameter: msestring;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   factive: boolean;
   fprochandle: prochandlety;
   foptions: processoptionsty;
   fonprocfinished: notifyeventty;
   flistenid: ptruint;
   fexitcode: integer;
   fcommandline: string;
   fcommandline1: string;
   fpipewaitus: integer;
   procedure setoutput(const avalue: tpipereaderpers);
   procedure seterroroutput(const avalue: tpipereaderpers);
   function getactive: boolean;
   procedure setactive(const avalue: boolean);
   procedure setstatfile(const avalue: tstatfile);
   procedure updatecommandline;
   function getcommandline: string;
   procedure setcommandline(const avalue: string);
   procedure procend;
   procedure setoptions(const avalue: processoptionsty);
  protected
   fstate: processstatesty;
   procedure loaded; override;
   procedure listen;
   procedure unlisten;
   procedure finalizeexec;
   procedure receiveevent(const event: tobjectevent); override;
   procedure waitforpipeeof;
   procedure doprocfinished;

    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   procedure postprocessdied;
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
   property input: tpipewriter read finput;
   property commandline: string read getcommandline write setcommandline;
                 //overrides filename and parameter
   property prochandle: prochandlety read fprochandle;
   property exitcode: integer read fexitcode;
  published
   property filename: filenamety read ffilename write ffilename;
   property parameter: msestring read fparameter write fparameter;
   property active: boolean read getactive write setactive default false;
   property options: processoptionsty read foptions write setoptions default [];
   property pipewaitus: integer read fpipewaitus write fpipewaitus 
                                                 default defaultpipewaitus;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property output: tpipereaderpers read foutput write setoutput;
   property erroroutput: tpipereaderpers read ferroroutput write seterroroutput;
   property onprocfinished: notifyeventty read fonprocfinished write fonprocfinished;
 end;

function getprocessoutput(const acommandline: string; const todata: string;
                         out fromdata: string; out errordata: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions): integer; overload;
                         //returns program exitcode, -1 in case of error
function getprocessoutput(const acommandline: string; const todata: string;
                         out fromdata: string;
                         const atimeout: integer = -1;
                    const aoptions: processoptionsty = 
              defaultgetprocessoutputoptionserrorouttoout): integer; overload;
                         //returns program exitcode, -1 in case of error

function startprocessandwait(const acommandline: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions): integer; overload;
                         //returns program exitcode, -1 in case of error
implementation
uses
 mseprocutils,msefileutils,mseapplication,sysutils,msesysintf,msebits,msesys,
 msesysutils;
type
 tstringprocess = class(tmseprocess)
  private
   ffromdata: string;
   ferrordata: string;
   procedure fromavail(const sender: tpipereader);
   procedure erroravail(const sender: tpipereader);
  public
   constructor create(aowner: tcomponent); override;
 end;
 
function getprocessoutput1(const acommandline: string; const todata: string;
               out fromdata: string; out errordata: string;
               const atimeout: integer; const aoptions: processoptionsty): integer;
                         //returns program exitcode, -1 in case of error
var
 proc1: tstringprocess;
begin
 result:= -1;
 proc1:= tstringprocess.create(nil);
 try
  with proc1 do begin
   commandline:= acommandline;
   options:= aoptions + [pro_output,pro_erroroutput,pro_input];
   active:= true;
   if todata <> '' then begin
    try
     input.write(todata);
    except
    end;
   end;
   if atimeout < 0 then begin
    result:= waitforprocess;
   end
   else begin
    if waitforprocess(atimeout) then begin
     result:= exitcode;
    end;
   end;
   fromdata:= proc1.ffromdata;
   errordata:= proc1.ferrordata;
  end;
 finally
  proc1.free;
 end;
end;

function startprocessandwait(const acommandline: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                            defaultstartprocessoptions): integer; overload;
                         //returns program exitcode, -1 in case of error
var
 proc1: tmseprocess;
begin
 result:= -1;
 proc1:= tstringprocess.create(nil);
 try
  with proc1 do begin
   commandline:= acommandline;
   options:= aoptions - [pro_output,pro_erroroutput,pro_input];
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

function getprocessoutput(const acommandline: string; const todata: string;
                         out fromdata: string; out errordata: string;
                         const atimeout: integer = -1;
                          const aoptions: processoptionsty = 
                            defaultgetprocessoutputoptions): integer;
begin
 result:= getprocessoutput1(acommandline,todata,fromdata,errordata,
                                                          atimeout,aoptions);
end;
 
function getprocessoutput(const acommandline: string; const todata: string;
                         out fromdata: string;
                         const atimeout: integer = -1;
                         const aoptions: processoptionsty = 
                      defaultgetprocessoutputoptionserrorouttoout): integer;
var
 str1: string;
begin
 result:= getprocessoutput1(acommandline,todata,fromdata,str1,
                                             atimeout,aoptions);
end;
 
{ tmseprocess }

constructor tmseprocess.create(aowner: tcomponent);
begin
 fprochandle:= invalidprochandle;
 finput:= tpipewriter.create;
 foutput:= tpipereaderpers.create;
 ferroroutput:= tpipereaderpers.create;
 fpipewaitus:= defaultpipewaitus;
 inherited;
end;

destructor tmseprocess.destroy;
begin
 finalizeexec;
 inherited;
 finput.free;
 foutput.free;
 ferroroutput.free;
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
 if not (pro_nopipeterminate in foptions) then begin
  foutput.pipereader.terminate;
  ferroroutput.pipereader.terminate;
 end;
end;

procedure tmseprocess.procend;
begin  
 fprochandle:= invalidprochandle;
 waitforpipeeof;
 if prs_waitcursor in fstate then begin
  exclude(fstate,prs_waitcursor);
  application.endwait;
 end;  
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
   finalizeexec;
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
      inp:= finput;
     end;
     if pro_tty in foptions then begin
      group:= 0;
      sessionleader:= true;
     end;
     opt1:= [];
     if sessionleader then begin
      include(opt1,exo_sessionleader);
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
     fprochandle:= execmse2(syscommandline(fcommandline1),
           inp,outp,erroroutp,{sessionleader,}group,opt1
           {pro_inactive in foptions,false,
                          pro_tty in foptions,pro_nostdhandle in foptions});
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
begin
 result:= false;
 bo1:= prs_listening in fstate;
 unlisten;
 if bo1 then begin
  int1:= application.unlockall;
  if foptions*[pro_checkescape,pro_processmessages] <> [] then begin
   ts1:= timestep(atimeoutus);
   repeat
    if pro_processmessages in foptions then begin
     application.processmessages;
    end;
    result:= mseprocutils.getprocessexitcode(fprochandle,fexitcode,100000);
   until result or (pro_checkescape in foptions) and application.waitescaped or 
                                          (atimeoutus >= 0) and timeout(ts1);
   if not result then begin
    terminateprocess(fprochandle);
    procend;
   end;
  end
  else begin
   result:= mseprocutils.getprocessexitcode(fprochandle,fexitcode,atimeoutus);
  end;
  application.relockall(int1);
 end
 else begin
  result:= true;
 end;
 if result  then begin
  procend;
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
 if not (prs_listening in fstate) and (fprochandle <> invalidprochandle) then begin
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
 finput.close;
 foutput.pipereader.terminateandwait;
 ferroroutput.pipereader.terminateandwait;
 application.lock;
 unlisten;
 if fprochandle <> invalidprochandle then begin
  pro_killzombie(fprochandle);
  fprochandle:= invalidprochandle;
 end;
 application.unlock;
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
  sleepus(0); //shed_yield
  while not (foutput.pipereader.eof and ferroroutput.pipereader.eof) and 
                      not ((fpipewaitus <> 0) and timeout(lwo1)) do begin
   sleepus(10000); //wait for last chars
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

function tmseprocess.getcommandline: string;
begin
 updatecommandline;
 result:= fcommandline1;
end;

procedure tmseprocess.setcommandline(const avalue: string);
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
 application.lock;
 try
  if running then begin
   syserror(sys_terminateprocess(fprochandle));
  end;
 finally
  application.unlock;
 end;
end;

procedure tmseprocess.kill;
begin
 application.lock;
 try
  if running then begin
   syserror(sys_killprocess(fprochandle));
  end;
 finally
  application.unlock;
 end;
end;

procedure tmseprocess.setoptions(const avalue: processoptionsty);
const
 mask: processoptionsty = [pro_erroroutput,pro_errorouttoout];
begin
 foptions:= processoptionsty(
   setsinglebit({$ifdef FPC}longword{$else}word{$endif}(avalue),
                {$ifdef FPC}longword{$else}word{$endif}(foptions),
                {$ifdef FPC}longword{$else}word{$endif}(mask)));
end;

{ tstringprocess }

constructor tstringprocess.create(aowner: tcomponent);
begin
 inherited;
 options:= options + [pro_output,pro_erroroutput,pro_input];
 output.pipereader.oninputavailable:= {$ifdef FPC}@{$endif}fromavail;
 erroroutput.pipereader.oninputavailable:= {$ifdef FPC}@{$endif}erroravail;
end;

procedure tstringprocess.fromavail(const sender: tpipereader);
begin
 if sender.active then begin
  ffromdata:= ffromdata + sender.readdatastring;
 end;
end;

procedure tstringprocess.erroravail(const sender: tpipereader);
begin
 if sender.active then begin
  ferrordata:= ferrordata + sender.readdatastring;
 end;
end;

end.
