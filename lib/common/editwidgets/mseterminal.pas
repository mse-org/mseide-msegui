{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseterminal;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegrids,Classes,msestream,mseclasses,msepipestream,mseevent,mseinplaceedit,
 msetextedit,msestrings,msesys,mseeditglob,msemenus,msegui;
const
 defaultterminaleditoptions = (defaulttexteditoptions + [oe_caretonreadonly])-
                            [oe_linebreak];
type
 sendtexteventty = procedure(var atext: msestring; var donotsend: boolean) of object;
 terminaloptionty = (teo_readonly);
 terminaloptionsty = set of terminaloptionty;
 
 tterminal = class(tcustomtextedit)
  private
   foutput: tpipewriter;
   finput: tpipereader;
   ferrorinput: tpipereader;
   fprochandle: integer;
   fexitcode: integer;
   foninputpipebroken: notifyeventty;
   fonerrorpipebroken: notifyeventty;
   finputcolindex: integer;
   fonsendtext: sendtexteventty;
   foptions: terminaloptionsty;
   function getinputfd: integer;
   procedure setinoutfd(const Value: integer);
   procedure setoptions(const avalue: terminaloptionsty);
   function getoutputfd: integer;
   procedure setoutputfd(const avalue: integer);
   function geterrorfd: integer;
   procedure seterrorfd(const avalue: integer);
  protected
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); override;
   procedure updateeditpos;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function execprog(const commandline: string): integer;
     //returns procid
   function prochandle: integer;
   function waitforprocess: integer; //returns exitcode
   function exitcode: integer;
   procedure addchars(const avalue: msestring);
   procedure addline(const avalue: msestring); //thread save
   property inputfd: integer read getinputfd write setinoutfd;
   property outputfd: integer read getoutputfd write setoutputfd;
   property errorfd: integer read geterrorfd write seterrorfd;
  published
   property tabulators;
   property font;
   property oninputpipebroken: notifyeventty read foninputpipebroken 
                                                   write foninputpipebroken;
   property onerrorpipebroken: notifyeventty read fonerrorpipebroken 
                                                   write fonerrorpipebroken;
   property onsendtext: sendtexteventty read fonsendtext write fonsendtext;
   property options: terminaloptionsty read foptions write setoptions default [];
 end;

implementation
uses
 msesysutils,mseprocutils,msewidgets,mseguiglob,msetypes,
 msekeyboard,sysutils;

{ tterminal }

constructor tterminal.create(aowner: tcomponent);
begin
 fprochandle:= invalidprochandle;
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
 foutput.Free;
 finput.Free;
 ferrorinput.Free;
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
       fonsendtext(mstr1,bo1);
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
begin
 application.checkoverload;
 addchars(sender.readdatastring)
end;

procedure tterminal.addchars(const avalue: msestring);			
begin
 if fgridintf <> nil then begin
  if datalist.count > 0 then begin
   datalist[datalist.count-1]:= copy(datalist[datalist.count-1],1,
          finputcolindex);
  end;
  datalist.addchars(avalue);
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
 fprochandle:= invalidprochandle;
 result:= execmse2(commandline,foutput,finput,ferrorinput);
 fprochandle:= result;
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
begin
 result:= mseprocutils.waitforprocess(fprochandle);
 fexitcode:= result;
 fprochandle:= invalidprochandle;
 while not (finput.eof and ferrorinput.eof) do begin
  sleep(100); //wait for last chars
 end;
end;

function tterminal.exitcode: integer;
begin
 result:= fexitcode;
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

end.
