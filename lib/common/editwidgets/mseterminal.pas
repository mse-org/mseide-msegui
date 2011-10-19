{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

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
 msetextedit,msestrings,msesys,mseeditglob,msemenus,msegui,mseguiglob,
 mseprocess,msegridsglob,mseedit,mseglob;
type
 sendtexteventty = procedure(const sender: tobject; 
                       var atext: msestring; var donotsend: boolean) of object;
 receivetexteventty = procedure(const sender: tobject; 
                       var atext: ansistring; const errorinput: boolean) of object;
 terminaloptionty = (teo_readonly,teo_bufferchunks);
 terminaloptionsty = set of terminaloptionty;
const
 defaultterminaleditoptions = (defaulttexteditoptions + [oe_caretonreadonly])-
                            [oe_linebreak];
 defaultterminaloptions = [{teo_tty}];
 defaultoptionsprocess = [pro_output,pro_errorouttoout,pro_input,
                                                        pro_tty,pro_ctrlc];
type 
// terminalstatety = ({ts_running,}ts_listening);
// terminalstatesty = set of terminalstatety;
 
 
 tterminal = class(tcustomtextedit)
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
   fhistorybackup: msestring;
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
  protected
   fprocess: tmseprocess;
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);
   procedure doprocfinished(const sender: tobject);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure docellevent(const ownedcol: boolean; 
                                     var info: celleventinfoty); override;
   procedure updateeditpos;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function prochandle: integer;
   function execprog(const acommandline: string): integer;
     //returns prochandle
   procedure terminateprocess;
   procedure killprocess;
   function waitforprocess: integer; //returns exitcode
   function exitcode: integer;
   function running: boolean;
   procedure addchars(const avalue: msestring); virtual;
   procedure addline(const avalue: msestring); //thread save
   procedure writestr(const atext: string);
   procedure writestrln(const atext: string);
   property inputfd: integer read getinputfd write setinoutfd;
   property outputfd: integer read getoutputfd write setoutputfd;
   property errorfd: integer read geterrorfd write seterrorfd;
   procedure beginupdate; override;
   procedure endupdate;  override;
   property command: msestring read getcommand write setcommand;
   property commandhistory: msestringarty read fcommandhistory 
                                                    write fcommandhistory;
   property inputcolindex: integer read finputcolindex;
  published
   property optionsedit default defaultterminaleditoptions;
   property optionsedit1;
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
 end;

implementation
uses
 msesysutils,mseprocutils,msewidgets,msetypes,mseprocmonitor,
 msekeyboard,sysutils,msesysintf,rtlconsts,msegraphutils,msearrayutils;
type
 tinplaceedit1 = class(tinplaceedit);
 
{ tterminal }

constructor tterminal.create(aowner: tcomponent);
begin
 foptions:= defaultterminaloptions;
 fhistoryindex:= -1;
 inherited;
 optionsedit:= defaultterminaleditoptions;
 fprocess:= tmseprocess.create(nil);
 with fprocess do begin
  output.oninputavailable:= {$ifdef FPC}@{$endif}doinputavailable;
  output.onpipebroken:= {$ifdef FPC}@{$endif}dopipebroken;
  erroroutput.oninputavailable:= {$ifdef FPC}@{$endif}doinputavailable;
  erroroutput.onpipebroken:= {$ifdef FPC}@{$endif}dopipebroken;
  onprocfinished:= {$ifdef FPC}@{$endif}doprocfinished;
  output.overloadsleepus:= 50000;
  erroroutput.overloadsleepus:= 50000;
  options:= defaultoptionsprocess;
//  options:= [pro_output,pro_erroroutput,pro_input,pro_tty];
 end
end;

destructor tterminal.destroy;
begin
 fprocess.free;
 inherited;
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
var
 int1: integer;
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
 bo1: boolean;
 ar1: msestringarty;
// co1: gridcoordty;
 int1: integer;
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
    ea_delchar: begin
     if (info.dir = gd_left) and (editpos.col <= finputcolindex) then begin
      info.action:= ea_none;
     end;
    end;
    ea_textedited: begin
     fhistoryindex:= -1;
     fhistorybackup:= '';
    end;
    ea_textentered: begin
     if (row = rowhigh) and not (teo_readonly in foptions) then begin
      info.action:= ea_none;
      mstr1:= copy(feditor.text,finputcolindex+1,bigint);
      if (fmaxcommandhistory > 0) and not running then begin
       insertitem(fcommandhistory,0,mstr1);
       if length(fcommandhistory) > fmaxcommandhistory then begin
        setlength(fcommandhistory,fmaxcommandhistory);
       end;
      end;
      bo1:= false;
      if assigned(fonsendtext) then begin
       fonsendtext(self,mstr1,bo1);
      end;
      if not bo1 then begin
       try
        fprocess.input.writeln(mstr1);
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
    ea_pasteselection: begin
     if msewidgets.pastefromclipboard(mstr1) then begin
      clearselection;
      ar1:= breaklines(mstr1);
      if high(ar1) >= 0 then begin
       datalist[rowhigh]:= datalist[rowhigh] + ar1[0];
       for int1:= 1 to high(ar1) do begin
        tinplaceedit1(editor).checkaction(ea_textentered);
        datalist[rowhigh]:= ar1[int1];
       end;
      end;
      editpos:= makegridcoord(length(datalist[rowhigh]),rowhigh);
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
    if (key = key_c) and (shiftstate - [ss_ctrl] = []) and 
               (pro_ctrlc in optionsprocess) and running then begin
     command:= '^C';
     finputcolindex:= finputcolindex + 2;
     fprocess.terminate;
     include(info.eventstate,es_processed);
    end
    else begin
     if (fmaxcommandhistory > 0) and not running then begin
      include(info.eventstate,es_processed);
      case key of
       key_up: begin
        if fhistoryindex < high(fcommandhistory) then begin
         inc(fhistoryindex);
         if fhistoryindex = 0 then begin
          fhistorybackup:= command;
         end;
         command:= fcommandhistory[fhistoryindex];
        end;
       end;
       key_down: begin
        if fhistoryindex >= 0 then begin
         dec(fhistoryindex);
         if fhistoryindex < 0 then begin
          command:= fhistorybackup;
         end
         else begin
          command:= fcommandhistory[fhistoryindex];
         end;
        end;
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
    fonreceivetext(self,str1,sender = fprocess.erroroutput.pipereader);
   end;
   addchars(str1);
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
 if sender = fprocess.output.pipereader then begin
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

function tterminal.execprog(const acommandline: string): integer;
begin
 with fprocess do begin
  active:= false;
//  if active then begin
//   componentexception(self,'Process already active.');
//  end;
  commandline:= acommandline;
  active:= true;
  result:= prochandle;
 end;
end;

function tterminal.getinputfd: integer;
begin
 result:= fprocess.output.pipereader.handle;
end;

function tterminal.prochandle: integer;
begin
 result:= fprocess.prochandle;
end;

procedure tterminal.setinoutfd(const Value: integer);
begin
 fprocess.output.pipereader.handle:= value;
end;

function tterminal.waitforprocess: integer;
begin
 result:= fprocess.waitforprocess;
end;

function tterminal.exitcode: integer;
begin
 result:= fprocess.exitcode;
end;

function tterminal.running: boolean;
begin
 result:= fprocess.running;
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
 result:= fprocess.input.handle;
end;

procedure tterminal.setoutputfd(const avalue: integer);
begin
 fprocess.input.handle:= avalue;
end;

function tterminal.geterrorfd: integer;
begin
 result:= fprocess.erroroutput.pipereader.handle;
end;

procedure tterminal.seterrorfd(const avalue: integer);
begin
 fprocess.erroroutput.pipereader.handle:= avalue;
end;

procedure tterminal.writestr(const atext: string);
begin
 if sys_write(outputfd,pointer(atext),length(atext)) <> length(atext) then begin
  syserror(syelasterror);
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
 fprocess.terminate;
end;

procedure tterminal.killprocess;
begin
 fprocess.kill;
end;

function tterminal.getoptionsprocess: processoptionsty;
begin
 result:= fprocess.options;
end;

procedure tterminal.setoptionsprocess(const avalue: processoptionsty);
begin
 fprocess.options:= avalue;
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
end;

end.
