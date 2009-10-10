{ MSEgui Copyright (c) 1999-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseterminal;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegrids,Classes,msestream,mseclasses,msepipestream,mseevent,mseinplaceedit,
 msetextedit,msestrings,msesys,mseeditglob,msemenus,msegui,mseguiglob;
type
 sendtexteventty = procedure(const sender: tobject; 
                       var atext: msestring; var donotsend: boolean) of object;
 receivetexteventty = procedure(const sender: tobject; 
                       var atext: ansistring; const errorinput: boolean) of object;
 terminaloptionty = (teo_readonly,teo_tty);
 terminaloptionsty = set of terminaloptionty;
const
 defaultterminaleditoptions = (defaulttexteditoptions + [oe_caretonreadonly])-
                            [oe_linebreak];
 defaultterminaloptions = [teo_tty];
type 
 terminalstatety = ({ts_running,}ts_listening);
 terminalstatesty = set of terminalstatety;
 
 tterminal = class(tcustomtextedit)
  private
   foutput: tpipewriter;
   finput: tpipereader;
   ferrorinput: tpipereader;
   fprochandle: integer;
   fexitcode: integer;
   foninputpipebroken: notifyeventty;
   fonerrorpipebroken: notifyeventty;
   fonprogfinished: notifyeventty;
   finputcolindex: integer;
   fonsendtext: sendtexteventty;
   fonreceivetext: receivetexteventty;
   foptions: terminaloptionsty;
   fmaxchars: integer;
   flistenid: ptruint;
   function getinputfd: integer;
   procedure setinoutfd(const Value: integer);
   procedure setoptions(const avalue: terminaloptionsty);
   function getoutputfd: integer;
   procedure setoutputfd(const avalue: integer);
   function geterrorfd: integer;
   procedure seterrorfd(const avalue: integer);
  protected
   fstate: terminalstatesty;

   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure docellevent(const ownedcol: boolean; 
                                     var info: celleventinfoty); override;
   procedure updateeditpos;
   procedure listen;
   procedure unlisten;
   procedure finalizeexec;
   
   procedure receiveevent(const event: tobjectevent); override;
   procedure doprogfinished;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function execprog(const commandline: string): integer;
     //returns procid
   function prochandle: integer;
   function waitforprocess: integer; //returns exitcode
   function exitcode: integer;
   function running: boolean;
   procedure addchars(const avalue: msestring);
   procedure addline(const avalue: msestring); //thread save
   procedure writestr(const atext: string);
   procedure writestrln(const atext: string);
   property inputfd: integer read getinputfd write setinoutfd;
   property outputfd: integer read getoutputfd write setoutputfd;
   property errorfd: integer read geterrorfd write seterrorfd;
  published
   property tabulators;
   property font;
   property maxchars: integer read fmaxchars write fmaxchars default 0;
   property oninputpipebroken: notifyeventty read foninputpipebroken 
                                                   write foninputpipebroken;
   property onerrorpipebroken: notifyeventty read fonerrorpipebroken 
                                                   write fonerrorpipebroken;
   property onprogfinished: notifyeventty read fonprogfinished write fonprogfinished;
   
   property onsendtext: sendtexteventty read fonsendtext write fonsendtext;
   property onreceivetext: receivetexteventty read fonreceivetext 
                                                      write fonreceivetext;
   property options: terminaloptionsty read foptions write setoptions 
                          default defaultterminaloptions;
 end;

implementation
uses
 msesysutils,mseprocutils,msewidgets,msetypes,mseprocmonitor,
 msekeyboard,sysutils,msesysintf,rtlconsts;

{ tterminal }

constructor tterminal.create(aowner: tcomponent);
begin
 fprochandle:= invalidprochandle;
 foptions:= defaultterminaloptions;
 inherited;
 optionsedit:= defaultterminaleditoptions;
 foutput:= tpipewriter.create;
 finput:= tpipereader.create;
 finput.oninputavailable:= {$ifdef FPC}@{$endif}doinputavailable;
 finput.onpipebroken:= {$ifdef FPC}@{$endif}dopipebroken;
 ferrorinput:= tpipereader.create;
 ferrorinput.oninputavailable:= {$ifdef FPC}@{$endif}doinputavailable;
 ferrorinput.onpipebroken:= {$ifdef FPC}@{$endif}dopipebroken;
 finput.overloadsleepus:= 50000;
 ferrorinput.overloadsleepus:= 50000;
end;

destructor tterminal.destroy;
begin
 finalizeexec;
 foutput.Free;
 finput.Free;
 ferrorinput.Free;
 inherited;
end;

procedure tterminal.listen;
begin
 application.lock;
 if not (ts_listening in fstate) and (fprochandle <> invalidprochandle) then begin
  inc(flistenid);
  pro_listentoprocess(fprochandle,ievent(self),pointer(flistenid));
  include(fstate,ts_listening);
 end;
 application.unlock;
end;

procedure tterminal.unlisten;
begin
 application.lock;
 try
  if ts_listening in fstate then begin
   pro_unlistentoprocess(fprochandle,ievent(self));   
  end;
  exclude(fstate,ts_listening);
 finally
  application.unlock;
 end;
end;

procedure tterminal.finalizeexec;
begin
 foutput.close;
 finput.terminateandwait;
 ferrorinput.terminateandwait;
 application.lock;
 unlisten;
 if fprochandle <> invalidprochandle then begin
  pro_killzombie(fprochandle);
  fprochandle:= invalidprochandle;
 end;
 application.unlock;
end;

procedure tterminal.docellevent(const ownedcol: boolean; var info: celleventinfoty);
begin
 case info.eventkind of
  cek_enter: begin
   if (info.newcell.row = fgridintf.getcol.grid.rowhigh) and 
             not (teo_readonly in foptions) then begin
    optionsedit:= optionsedit - [oe_readonly];
   end
   else begin
    optionsedit:= optionsedit + [oe_readonly];
   end;
  end;
 end;
 inherited;
end;

procedure tterminal.editnotification(var info: editnotificationinfoty);
var
 mstr1: msestring;
 bo1: boolean;
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   case info.action of
    ea_indexmoved: begin
     if editpos.row = datalist.count - 1 then begin
      if (editpos.col < finputcolindex) or (teo_readonly in foptions) then begin
       optionsedit:= optionsedit + [oe_readonly];
      end
      else begin
       optionsedit:= optionsedit - [oe_readonly];
      end;
     end;
    end;
    ea_textentered: begin
     if (row = rowhigh) and not (teo_readonly in foptions) then begin
      info.action:= ea_none;
      mstr1:= copy(feditor.text,finputcolindex+1,bigint);
      bo1:= false;
      if assigned(fonsendtext) then begin
       fonsendtext(self,mstr1,bo1);
      end;
      if not bo1 then begin
       try
        foutput.writeln(mstr1);
        datalist.add('');
       except
        feditor.text:= '';
        gridvalue[row]:= copy(gridvalue[row],1,finputcolindex);
       end;
      end
      else begin
       datalist.add('');
      end;
      updateeditpos;
     end;
    end;
   end;
   if info.action <> ea_none then begin
    inherited;
   end;
  end;
 end;
end;

procedure tterminal.dokeydown(var info: keyeventinfoty);
begin
 if fgridintf <> nil then begin
  with info do begin
   if shiftstate - [ss_shift] = [] then begin
    if (chars <> '') and
     ((editpos.row < datalist.count - 1) or 
                  (editpos.col < finputcolindex)) then begin
     editpos:= makegridcoord(bigint,bigint);
    end
    else begin
     if (key = key_home) and (editpos.row = datalist.count - 1) then begin
      editor.moveindex(finputcolindex,ss_shift in shiftstate);
      include(eventstate,es_processed);
     end;
    end; 
   end;
   if not (es_processed in info.eventstate) then begin
    inherited;
   end;
  end;
 end;
end;

procedure tterminal.updateeditpos;
var
 int1: integer;
begin
 if fgridintf <> nil then begin
  int1:= datalist.count-1;
  if int1 >= 0 then begin
   finputcolindex:= length(datalist[int1]);
  end;
  editpos:= makegridcoord(finputcolindex,int1);
 end;
end;

procedure tterminal.doinputavailable(const sender: tpipereader);
var
 str1: string;
begin
 application.checkoverload;
 try
  str1:= sender.readdatastring;
  if canevent(tmethod(fonreceivetext)) then begin
   fonreceivetext(self,str1,sender = ferrorinput);
  end;
  addchars(str1);
 except
 end;
end;

procedure tterminal.addchars(const avalue: msestring);			
begin
 if fgridintf <> nil then begin
  if datalist.count > 0 then begin
   datalist[datalist.count-1]:= copy(datalist[datalist.count-1],1,
          finputcolindex); //remove entered characters
  end;
  datalist.addchars(avalue,true,fmaxchars);
  updateeditpos;
 end;
end;

procedure tterminal.addline(const avalue: msestring);
begin
 if fgridintf <> nil then begin
  application.lock;
  try
   addchars(avalue+lineend);
  finally
   application.unlock;
  end;
 end;
end;

procedure tterminal.dopipebroken(const sender: tpipereader);
begin
 if sender = finput then begin
  if assigned(foninputpipebroken) then begin
   foninputpipebroken(self);
  end;
 end
 else begin
  if assigned(fonerrorpipebroken) then begin
   fonerrorpipebroken(self);
  end;
 end;
end;

function tterminal.execprog(const commandline: string): integer;
begin
 finalizeexec;
 result:= execmse2(commandline,foutput,finput,ferrorinput,false,-1,true,false,
                      teo_tty in foptions);
 fprochandle:= result;
 listen;
// include(fstate,ts_running);
end;

function tterminal.getinputfd: integer;
begin
 result:= finput.handle;
end;

function tterminal.prochandle: integer;
begin
 result:= fprochandle;
end;

procedure tterminal.setinoutfd(const Value: integer);
begin
 finput.handle:= value;
end;

function tterminal.waitforprocess: integer;
var
 int1: integer;
begin
{
 while running do begin
  application.processmessages;
 end;
 result:= fexitcode;
}
 unlisten;
 if running then begin
  int1:= application.unlockall;
  try
   result:= mseprocutils.waitforprocess(fprochandle);
   fexitcode:= result;
   fprochandle:= invalidprochandle;
   while not (finput.eof and ferrorinput.eof) do begin
    sleep(100); //wait for last chars
   end;
  finally
   application.relockall(int1);
  end;
  doprogfinished;
 end;
end;

function tterminal.exitcode: integer;
begin
 result:= fexitcode;
end;

function tterminal.running: boolean;
begin
 result:= fprochandle <> invalidprochandle;
end;

procedure tterminal.setoptions(const avalue: terminaloptionsty);
begin
 foptions:= avalue;
 if (teo_readonly in foptions) then begin
  optionsedit:= optionsedit + [oe_readonly];
 end;
end;

function tterminal.getoutputfd: integer;
begin
 result:= foutput.handle;
end;

procedure tterminal.setoutputfd(const avalue: integer);
begin
 foutput.handle:= avalue;
end;

function tterminal.geterrorfd: integer;
begin
 result:= ferrorinput.handle;
end;

procedure tterminal.seterrorfd(const avalue: integer);
begin
 ferrorinput.handle:= avalue;
end;

procedure tterminal.writestr(const atext: string);
begin
 if sys_write(outputfd,pointer(atext),length(atext)) <> length(atext) then begin
  syserror(syelasterror);
//  raise ewriteerror.create(swriteerror);
 end;
end;

procedure tterminal.writestrln(const atext: string);
begin
 writestr(atext+lineend);
end;

procedure tterminal.receiveevent(const event: tobjectevent);
begin
 if (event.kind = ek_childproc) and (ts_listening in fstate) then begin 
  with tchildprocevent(event) do begin
   if data = pointer(flistenid) then begin
    while not (finput.eof and ferrorinput.eof) do begin
     sleep(100); //wait for last chars
    end;
    fexitcode:= execresult;
    fprochandle:= invalidprochandle;
    exclude(fstate,ts_listening);
    doprogfinished;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tterminal.doprogfinished;
begin
 if canevent(tmethod(fonprogfinished)) then begin
  fonprogfinished(self);
 end;
end;

end.
