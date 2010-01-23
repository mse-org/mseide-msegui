{ MSEgui Copyright (c) 2010 by Martin Schreiber

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
 classes,mseclasses,msepipestream,msestrings,msestatfile,msestat,msesys,
 mseevent,msetypes;
type
 processstatety = (prs_listening);
 processstatesty = set of processstatety;
 processoptionty = (pro_output,pro_erroroutput,pro_input,
                    pro_tty, //linux only
                    pro_inactive,pro_nostdhandle //windows only
                    );
 processoptionsty = set of processoptionty;
  
 tmseprocess = class(tmsecomponent,istatfile)
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
   procedure setoutput(const avalue: tpipereaderpers);
   procedure seterroroutput(const avalue: tpipereaderpers);
   function getactive: boolean;
   procedure setactive(const avalue: boolean);
   procedure setstatfile(const avalue: tstatfile);
   procedure updatecommandline;
   function getcommandline: string;
   procedure setcommandline(const avalue: string);
  protected
   fstate: processstatesty;
   procedure loaded; override;
   procedure listen;
   procedure unlisten;
   procedure finalizeexec;
   procedure receiveevent(const event: tobjectevent); override;
   procedure doprocfinished;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  public
   function running: boolean;
   procedure terminate;
   procedure kill;
   function waitforprocess: integer; //returns exitcode
   property input: tpipewriter read finput;
   property commandline: string read getcommandline write setcommandline;
                 //overrides filename and parameter
   property prochandle: prochandlety read fprochandle;
   property exitcode: integer read fexitcode;
  published
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property filename: filenamety read ffilename write ffilename;
   property parameter: msestring read fparameter write fparameter;
   property active: boolean read getactive write setactive default false;
   property options: processoptionsty read foptions write foptions default [];
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property output: tpipereaderpers read foutput write setoutput;
   property erroroutput: tpipereaderpers read ferroroutput write seterroroutput;
   property onprocfinished: notifyeventty read fonprocfinished write fonprocfinished;
 end;
 
implementation
uses
 mseprocutils,msefileutils,mseapplication,mseprocmonitor,sysutils,msesysintf;
 
{ tmseprocess }

constructor tmseprocess.create(aowner: tcomponent);
begin
 fprochandle:= invalidprochandle;
 finput:= tpipewriter.create;
 foutput:= tpipereaderpers.create;
 ferroroutput:= tpipereaderpers.create;
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

procedure tmseprocess.setactive(const avalue: boolean);
var
 outp: tpipereader;
 erroroutp: tpipereader;
 inp: tpipewriter;
begin
 outp:= nil;
 erroroutp:= nil;
 inp:= nil;
 if componentstate * [csloading,csdesigning] <> [] then begin
  factive:= avalue;
 end
 else begin
  if avalue <> active then begin
   finalizeexec;
   if avalue then begin
    updatecommandline;
    if pro_output in foptions then begin
     outp:= foutput.pipereader;
    end;
    if pro_erroroutput in foptions then begin
     erroroutp:= ferroroutput.pipereader;
    end;
    if pro_input in foptions then begin
     inp:= finput;
    end;
    fprochandle:= execmse2(fcommandline1,inp,outp,erroroutp,false,-1,
                pro_inactive in foptions,false,
                         pro_tty in foptions,pro_nostdhandle in foptions);
    listen;
   end;
  end;
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
  inc(flistenid);
  pro_listentoprocess(fprochandle,ievent(self),pointer(flistenid));
  include(fstate,prs_listening);
 end;
 application.unlock;
end;

procedure tmseprocess.unlisten;
begin
 application.lock;
 try
  if prs_listening in fstate then begin
   pro_unlistentoprocess(fprochandle,ievent(self));   
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

procedure tmseprocess.receiveevent(const event: tobjectevent);
var
 int1,int2,int3: integer;
begin
 if (event.kind = ek_childproc) and (prs_listening in fstate) then begin 
  with tchildprocevent(event) do begin
   if data = pointer(flistenid) then begin
    int1:= application.unlockall;
    int2:= foutput.pipereader.overloadsleepus;
    int3:= ferroroutput.pipereader.overloadsleepus;
    foutput.pipereader.overloadsleepus:= 0;
    ferroroutput.pipereader.overloadsleepus:= 0;
    while not (foutput.pipereader.eof and ferroroutput.pipereader.eof) do begin
     sleep(100); //wait for last chars
    end;
    application.relockall(int1);
    foutput.pipereader.overloadsleepus:= int2;
    ferroroutput.pipereader.overloadsleepus:= int3;
    fexitcode:= execresult;
    fprochandle:= invalidprochandle;
    exclude(fstate,prs_listening);
    doprocfinished;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tmseprocess.doprocfinished;
begin
 if canevent(tmethod(fonprocfinished)) then begin
  fonprocfinished(self);
 end;
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

function tmseprocess.waitforprocess: integer;
var
 int1: integer;
begin
 unlisten;
 if running then begin
  int1:= application.unlockall;
  try
   result:= mseprocutils.waitforprocess(fprochandle);
   fexitcode:= result;
   fprochandle:= invalidprochandle;
   while not (foutput.pipereader.eof and ferroroutput.pipereader.eof) do begin
    sleep(100); //wait for last chars
   end;
  finally
   application.relockall(int1);
  end;
  doprocfinished;
 end;
end;

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

end.
