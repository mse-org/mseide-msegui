{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseterminal;

{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}

interface
uses
 msetypes,msegrids,classes,mclasses,msestream,mseclasses,msepipestream,mseevent,
 mseinplaceedit,
 msetextedit,msestrings,msesys,mseeditglob,msemenus,msegui,mseguiglob,
 mseprocess,msegridsglob,mseedit,mseglob,msewidgetgrid,msegraphics;
type
 sendtexteventty = procedure(const sender: tobject; 
                       var atext: msestring; var donotsend: boolean) of object;
 receivetexteventty = procedure(const sender: tobject; 
                  var atext: ansistring; const errorinput: boolean) of object;
 terminaloptionty = (teo_readonly,teo_bufferchunks,teo_stripescsequence,
                                                                      teo_utf8);
 terminaloptionsty = set of terminaloptionty;
const
 defaultterminaleditoptions = (defaulttexteditoptions + [oe_caretonreadonly])-
                                                                [oe_linebreak];
 defaultterminaloptions = [{teo_tty}];
 defaultoptionsprocess = [pro_output,pro_errorouttoout,pro_input,
                        pro_winpipewritehandles,pro_inactive,pro_tty,pro_ctrlc];
type 
// terminalstatety = ({ts_running,}ts_listening);
// terminalstatesty = set of terminalstatety;
 
 
 tterminal = class(tcustomtextedit,igridwidget)
  private
   foninputpipebroken: notifyeventty;
   fonerrorpipebroken: notifyeventty;
   finputcolindex: integer;
   fonsendtext: sendtexteventty;
   fonreceivetext: receivetexteventty;
   foptions: terminaloptionsty;
   fmaxchars: integer;
   fupdatingcount: integer;
   fonprocfinished: notifyeventty;
   fmaxcommandhistory: integer;
   fcommandhistory: msestringarty;
   fhistoryindex: integer;
   fprocess: tcustommseprocess;
   function getinputfd: integer;
   procedure setinoutfd(const Value: integer);
   procedure setoptions(const avalue: terminaloptionsty);
   function getoutputfd: integer;
   procedure setoutputfd(const avalue: integer);
   function geterrorfd: integer;
   procedure seterrorfd(const avalue: integer);
   function getoptionsprocess: processoptionsty;
   procedure setoptionsprocess(const avalue: processoptionsty);
   procedure setmaxcommandhistory(const avalue: integer);
   function getcommand: msestring;
   procedure setcommand(const avalue: msestring);
   function getpipewaitus: integer;
   procedure setpipewaitus(const avalue: integer);
   function getprompt: msestring;
   procedure setprompt(const avalue: msestring);
   procedure setprocess(const avalue: tcustommseprocess);
  protected
   finternalprocess: tcustommseprocess;
   procedure linkprocess(const aprocess: tcustommseprocess);
   procedure unlinkprocess(const aprocess: tcustommseprocess);
   function curprocess: tcustommseprocess;
   procedure setreadonly1(const avalue: boolean);
   procedure igridwidget.setreadonly = setreadonly1;
   procedure setreadonly(const avalue: boolean); override;
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);
   procedure doprocfinished(const sender: tobject);
   function echoisoff: boolean;
   function echooff(out aechoisoff: boolean): boolean;
   procedure echoon(const avalue: boolean);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure docellevent(const ownedcol: boolean; 
                                     var info: celleventinfoty); override;
   procedure updateeditpos;
//   function stripescapesequences(avalue: msestring): msestring;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function prochandle: integer;
   function execprog(const acommandline: msestring;
                    const aworkingdirectory: filenamety = '';
                    const aparams: msestringarty = nil; 
                    const aenvvars: msestringarty = nil): integer;
     //returns prochandle
   procedure terminateprocess;
   procedure killprocess;
   function waitforprocess: integer; //returns exitcode
   function exitcode: integer;
   function running: boolean;
   procedure addchars(const avalue: msestring); virtual;
   procedure addline(const avalue: msestring); //thread safe
   procedure writestr(const atext: string);
   procedure writestrln(const atext: string);
   property inputfd: integer read getinputfd write setinoutfd;
   property outputfd: integer read getoutputfd write setoutputfd;
   property errorfd: integer read geterrorfd write seterrorfd;
   procedure beginupdate; override;
   procedure endupdate;  override;
   property prompt: msestring read getprompt write setprompt;
   property command: msestring read getcommand write setcommand;
   property commandhistory: msestringarty read fcommandhistory 
                                                    write fcommandhistory;
   property inputcolindex: integer read finputcolindex write finputcolindex;
  published
   property process: tcustommseprocess read fprocess write setprocess;
        //replaces internal process,
        //event properties in source will be owerwritten
   property optionsedit1; //before optionsedit!
   property optionsedit default defaultterminaleditoptions;
   property font;
   property cursorreadonly;
   property maxchars: integer read fmaxchars write fmaxchars default 0;
   property maxcommandhistory: integer read fmaxcommandhistory 
                                     write setmaxcommandhistory default 0;
   property tabulators;

   property caretwidth;
   property textflags;
   property textflagsactive;

   property marginlinepos;
                     //offset to innerclientrect.x
   property marginlinecolor;

   property onchange;
   property ontextedited;
   property onkeydown;
   property onkeyup;
   property oncopytoclipboard;
   property onpastefromclipboard;

   property oninputpipebroken: notifyeventty read foninputpipebroken 
                                                   write foninputpipebroken;
   property onerrorpipebroken: notifyeventty read fonerrorpipebroken 
                                                   write fonerrorpipebroken;
   property onprocfinished: notifyeventty 
                  read fonprocfinished write fonprocfinished;
   
   property onsendtext: sendtexteventty read fonsendtext write fonsendtext;
   property onreceivetext: receivetexteventty read fonreceivetext 
                                                      write fonreceivetext;
   property options: terminaloptionsty read foptions write setoptions 
                          default defaultterminaloptions;
   property optionsprocess: processoptionsty read getoptionsprocess 
                            write setoptionsprocess default defaultoptionsprocess;
   property pipewaitus: integer read getpipewaitus write setpipewaitus
                                   default defaultpipewaitus;
 end;

implementation
uses
 msesysutils,mseprocutils,msewidgets,mseprocmonitor,
 msekeyboard,sysutils,msesysintf,rtlconsts,msegraphutils,msearrayutils,
 msesysintf1,mserichstring,msedatalist
 {$ifdef unix},mselibc{$endif};
type
 tinplaceedit1 = class(tinplaceedit);
 
{ tterminal }

constructor tterminal.create(aowner: tcomponent);
begin
 foptions:= defaultterminaloptions;
// fhistoryindex:= -1;
 inherited;
 optionsedit:= defaultterminaleditoptions;
 finternalprocess:= tcustommseprocess.create(nil);
 linkprocess(finternalprocess);
 with finternalprocess do begin
  output.overloadsleepus:= 50000;
  erroroutput.overloadsleepus:= 50000;
  options:= defaultoptionsprocess;
//  options:= [pro_output,pro_erroroutput,pro_input,pro_tty];
 end
end;

destructor tterminal.destroy;
begin
 process:= nil; //unlink
 finternalprocess.free;
 inherited;
end;

procedure tterminal.linkprocess(const aprocess: tcustommseprocess);
begin
 if not (csdesigning in componentstate) then begin
  with aprocess do begin
   output.oninputavailable:= @doinputavailable;
   output.onpipebroken:= @dopipebroken;
   erroroutput.oninputavailable:= @doinputavailable;
   erroroutput.onpipebroken:= @dopipebroken;
   onprocfinished:= @doprocfinished;
  end;
 end;
end;

procedure tterminal.unlinkprocess(const aprocess: tcustommseprocess);
begin
 if not (csdesigning in componentstate) then begin
  with aprocess do begin
   output.oninputavailable:= nil;
   output.onpipebroken:= nil;
   erroroutput.oninputavailable:= nil;
   erroroutput.onpipebroken:= nil;
   onprocfinished:= nil;
  end;
 end;
end;

function tterminal.curprocess: tcustommseprocess;
begin
 result:= fprocess;
 if result = nil then begin
  result:= finternalprocess;
 end;
end;

procedure tterminal.docellevent(const ownedcol: boolean; 
                                           var info: celleventinfoty);
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

function tterminal.getprompt: msestring;
var
 int1: integer;
begin
 result:= '';
 if fgridintf <> nil then begin
  int1:= fgridintf.getcol.grid.rowhigh;
  if int1 >= 0 then begin
   result:= copy(gridvalue[int1],0,finputcolindex);
  end;
 end;
end;

procedure tterminal.setprompt(const avalue: msestring);
//var
// mstr1: msestring;
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   if rowhigh >= 0 then begin
    gridvalue[rowhigh]:= avalue + 
                          copy(gridvalue[rowhigh],finputcolindex+1,bigint);
    finputcolindex:= length(avalue);
    if row = rowhigh then begin
     feditor.curindex:= bigint;
    end;
   end;
  end;
 end;
end;

procedure tterminal.setprocess(const avalue: tcustommseprocess);
begin
 if fprocess <> nil then begin
  unlinkprocess(fprocess);
 end;
 fprocess:= avalue;
 if fprocess <> nil then begin
  linkprocess(fprocess);
 end;
end;

function tterminal.getcommand: msestring;
var
 int1: integer;
begin
 result:= '';
 if fgridintf <> nil then begin
  int1:= fgridintf.getcol.grid.rowhigh;
  if int1 >= 0 then begin
   result:= copy(gridvalue[int1],finputcolindex+1,bigint);
  end;
 end;
end;

procedure tterminal.setcommand(const avalue: msestring);
//var
// int1: integer;
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   if rowhigh >= 0 then begin
    gridvalue[rowhigh]:= copy(gridvalue[rowhigh],1,finputcolindex)+avalue;
    if row = rowhigh then begin
     feditor.curindex:= bigint;
    end;
   end;
  end;
 end;
end;

procedure tterminal.editnotification(var info: editnotificationinfoty);
var
 mstr1: msestring;
 bo1,bo2,bo3: boolean;
 ar1: msestringarty;
 int1: integer;
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   case info.action of
    ea_textedited: begin
     if echoisoff then begin
      feditor.format:= updatefontstyle(feditor.format,
                                 finputcolindex,bigint,fs_blank,true);
     end;
    end;
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
    ea_delchar: begin
     if (info.dir = gd_left) and (editpos.col <= finputcolindex) then begin
      info.action:= ea_none;
     end;
    end;
    ea_textentered: begin
     if (row = rowhigh) and not (teo_readonly in foptions) then begin
      info.action:= ea_none;
      mstr1:= copy(feditor.text,finputcolindex+1,bigint);
      if (fmaxcommandhistory > 0) and not running then begin
       fhistoryindex:= 0;
       if((fcommandhistory = nil) or (fcommandhistory[0] <> mstr1))  then begin
        if (fcommandhistory = nil) then begin
         setlength(fcommandhistory,1);
        end;
        fcommandhistory[0]:= mstr1;
        insertitem(fcommandhistory,0,'');
        if length(fcommandhistory) > fmaxcommandhistory then begin
         setlength(fcommandhistory,fmaxcommandhistory);
        end;
       end;
      end;
      bo1:= false;
      if assigned(fonsendtext) then begin
       fonsendtext(self,mstr1,bo1);
      end;
      if not bo1 then begin
       bo2:= echooff(bo3);
       try
        if teo_utf8 in foptions then begin
         curprocess.input.pipewriter.writeln(stringtoutf8ansi(mstr1));
        end
        else begin
         curprocess.input.pipewriter.writeln(mstr1);
        end;
        if not bo3 then begin
         datalist.add('');
        end;
       except
        feditor.text:= '';
        gridvalue[row]:= copy(gridvalue[row],1,finputcolindex);
       end;
       echoon(bo2);
      end;
//      else begin
//       datalist.add('');
//      end;
      updateeditpos;
     end;
    end;
    ea_pasteselection: begin
     if msewidgets.pastefromclipboard(mstr1,info.bufferkind) then begin
      clearselection;
      ar1:= breaklines(mstr1);
      if high(ar1) >= 0 then begin
//       datalist[rowhigh]:= datalist[rowhigh] + ar1[0];
       editor.inserttext(ar1[0],false);
       for int1:= 1 to high(ar1) do begin
        tinplaceedit1(editor).checkaction(ea_textentered);
        datalist[rowhigh]:= ar1[int1];
       end;
       if high(ar1) > 0 then begin
        editpos:= makegridcoord(length(datalist[rowhigh]),rowhigh);
       end;
      end;
//      editpos:= makegridcoord(length(datalist[rowhigh]),rowhigh);
     end;
     info.action:= ea_none;
    end;
   end;
   if info.action <> ea_none then begin
    inherited;
   end;
  end;
 end;
end;

function tterminal.echoisoff: boolean;
{$ifdef unix}
var
 terminfo: termios;
{$endif}
begin
 result:= false;
{$ifdef unix}
 if (pro_echo in curprocess.options) and running and
        (msetcgetattr(outputfd,terminfo) = 0) then begin
  result:= terminfo.c_lflag and echo = 0;
 end; 
{$endif}
end;

function tterminal.echooff(out aechoisoff: boolean): boolean;
{$ifdef unix}
var
 terminfo: termios;
{$endif}
begin
 result:= false;
 aechoisoff:= false;
{$ifdef unix}
 if (pro_echo in curprocess.options) and running and
        (msetcgetattr(outputfd,terminfo) = 0) then begin
  result:= terminfo.c_lflag and echo <> 0;
  aechoisoff:= not result;
  if result then begin
   tcdrain(outputfd);
   usleep(0); //why is this necessary? no tcdrain without
   terminfo.c_lflag:= terminfo.c_lflag and not echo;
   msetcsetattr(outputfd,tcsadrain,terminfo);
  end;
 end; 
{$endif} 
end;

procedure tterminal.echoon(const avalue: boolean);
{$ifdef unix}
var
 terminfo: termios;
{$endif}
begin
{$ifdef unix}
 if avalue and (msetcgetattr(inputfd,terminfo) = 0) then begin
  terminfo.c_lflag:= terminfo.c_lflag or echo;
  tcdrain(outputfd);
  usleep(0); //why is this necessary? no tcdrain without
  msetcsetattr(outputfd,tcsadrain,terminfo);
 end;
{$endif} 
end;

procedure tterminal.dokeydown(var info: keyeventinfoty);
begin
 if fgridintf <> nil then begin
  with info do begin
   if (key = key_c) and (shiftstate = [ss_ctrl]) and 
              (pro_ctrlc in optionsprocess) and running then begin
    command:= '^C';
    finputcolindex:= finputcolindex + 2;
    include(info.eventstate,es_processed);
    try
     curprocess.terminate;
    except
     curprocess.kill;
    end;
   end
   else begin
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
     if (fmaxcommandhistory > 0) and not running then begin
      include(info.eventstate,es_processed);
      case key of
       key_up,key_down: begin
        if fcommandhistory = nil then begin
         setlength(fcommandhistory,1);
         fhistoryindex:= 0;
        end;
        fcommandhistory[fhistoryindex]:= command;
        if key = key_up then begin
         if fhistoryindex < high(fcommandhistory) then begin
          inc(fhistoryindex);
         end;
        end
        else begin
         if fhistoryindex > 0 then begin
          dec(fhistoryindex);
         end;
        end;
        command:= fcommandhistory[fhistoryindex];
       end;
       else begin
        exclude(info.eventstate,es_processed);
       end;
      end;
      if (es_processed in eventstate) and (fgridintf <> nil) then begin
       fgridintf.getcol.grid.row:= bigint;
       feditor.curindex:= bigint;
       if not (teo_readonly in foptions) then begin
        optionsedit:= optionsedit - [oe_readonly];
       end;
      end;
     end;
    end;
    if not (es_processed in eventstate) then begin
     inherited;
    end;
   end;
  end;  
 end;
end;

procedure tterminal.updateeditpos;
var
 int1: integer;
begin
 if (fgridintf <> nil) and (fupdatingcount = 0) then begin
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
 int1: integer;
begin
 try
  if teo_bufferchunks in foptions then begin
   str1:= sender.readbuffer;
  end
  else begin
   str1:= sender.readdatastring;
  end;
  if not (csdestroying in componentstate) then begin
   if canevent(tmethod(fonreceivetext)) then begin
    fonreceivetext(self,str1,sender = curprocess.erroroutput.pipereader);
   end;
   if teo_utf8 in foptions then begin
    addchars(utf8tostringansi(str1));
   end
   else begin
    addchars(msestring(str1));
   end;
   if teo_bufferchunks in foptions then begin
    int1:= application.unlockall;
    sleepus(0); //sched_yield
    application.relockall(int1);
   end;
  end;
 except
 end;
end;

procedure tterminal.addchars(const avalue: msestring);			
var
 mstr1: msestring;
begin
 if fgridintf <> nil then begin
  if datalist.count > 0 then begin
   mstr1:= datalist[datalist.count-1];
   if length(mstr1) > finputcolindex then begin   
    datalist[datalist.count-1]:= copy(mstr1,1,finputcolindex); 
                                          //remove entered characters
   end; 
  end;
  if teo_stripescsequence in foptions then begin
   mstr1:= stripescapesequences(avalue);
  end
  else begin
   mstr1:= avalue;
  end;
  datalist.addchars(mstr1,[aco_processeditchars],fmaxchars);
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
 if sender = curprocess.output.pipereader then begin
  if canevent(tmethod(foninputpipebroken)) then begin
   foninputpipebroken(self);
  end;
 end
 else begin
  if canevent(tmethod(fonerrorpipebroken)) then begin
   fonerrorpipebroken(self);
  end;
 end;
end;

procedure tterminal.doprocfinished(const sender: tobject);
begin
 if canevent(tmethod(fonprocfinished)) then begin
  fonprocfinished(self);
 end;
end;

function tterminal.execprog(const acommandline: msestring;
                            const aworkingdirectory: filenamety = '';
                    const aparams: msestringarty = nil; 
                    const aenvvars: msestringarty = nil): integer;
begin
 with curprocess do begin
  active:= false;
//  if active then begin
//   componentexception(self,'Process already active.');
//  end;
  commandline:= acommandline;
  workingdirectory:= aworkingdirectory;
  params.asarray:= aparams;
  envvars.asarray:= aenvvars;
  active:= true;
  result:= lastprochandle;
 end;
end;

function tterminal.getinputfd: integer;
begin
 result:= curprocess.output.pipereader.handle;
end;

function tterminal.prochandle: integer;
begin
 result:= curprocess.prochandle;
end;

procedure tterminal.setinoutfd(const Value: integer);
begin
 curprocess.output.pipereader.handle:= value;
end;

function tterminal.waitforprocess: integer;
begin
 result:= curprocess.waitforprocess;
end;

function tterminal.exitcode: integer;
begin
 result:= curprocess.exitcode;
end;

function tterminal.running: boolean;
begin
 result:= curprocess.running;
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
 result:= curprocess.input.pipewriter.handle;
end;

procedure tterminal.setoutputfd(const avalue: integer);
begin
 curprocess.input.pipewriter.handle:= avalue;
end;

function tterminal.geterrorfd: integer;
begin
 result:= curprocess.erroroutput.pipereader.handle;
end;

procedure tterminal.seterrorfd(const avalue: integer);
begin
 curprocess.erroroutput.pipereader.handle:= avalue;
end;

procedure tterminal.writestr(const atext: string);
var
 bo1,bo2: boolean;
begin
 bo1:= echooff(bo2);
 try
  if sys_write(outputfd,pointer(atext),length(atext)) <> length(atext) then begin
   syserror(syelasterror);
  end;
 finally
  echoon(bo1);
 end;
end;

procedure tterminal.writestrln(const atext: string);
begin
 writestr(atext+lineend);
end;
{
function tterminal.getonprocfinished: notifyeventty;
begin
 result:= fprocess.onprocfinished;
end;

procedure tterminal.setonprocfinished(const avalue: notifyeventty);
begin
 fprocess.onprocfinished:= avalue;
end;
}
procedure tterminal.terminateprocess;
begin
 curprocess.terminate;
end;

procedure tterminal.killprocess;
begin
 curprocess.kill;
end;

function tterminal.getoptionsprocess: processoptionsty;
begin
 result:= finternalprocess.options;
end;

procedure tterminal.setoptionsprocess(const avalue: processoptionsty);
begin
 finternalprocess.options:= avalue;
end;

procedure tterminal.beginupdate;
begin
 inc(fupdatingcount);
 inherited;
end;

procedure tterminal.endupdate;
begin
 try
  inherited;
 finally
  dec(fupdatingcount);
  if fupdatingcount = 0 then begin
   updateeditpos;
  end;
 end;
end;

procedure tterminal.setmaxcommandhistory(const avalue: integer);
begin
 fmaxcommandhistory:= avalue;
 if length(fcommandhistory) > avalue then begin
  setlength(fcommandhistory,avalue);
 end;
 if fhistoryindex > high(fcommandhistory) then begin
  fhistoryindex:= high(fcommandhistory);
 end;
end;

function tterminal.getpipewaitus: integer;
begin
 result:= finternalprocess.pipewaitus;
end;

procedure tterminal.setpipewaitus(const avalue: integer);
begin
 finternalprocess.pipewaitus:= avalue;
end;

procedure tterminal.setreadonly(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [teo_readonly];
 end
 else begin
  options:= options - [teo_readonly];
 end;
 inherited;
end;

procedure tterminal.setreadonly1(const avalue: boolean);
begin
 //dummy for igridwidget
end;

end.
