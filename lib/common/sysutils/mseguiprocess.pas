{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguiprocess;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseprocess,msestrings;

type
 guiprocessoptionty = (prog_waitdialog,
                       prog_cancontinue); //continue button in wait dialog
 guiprocessoptionsty = set of guiprocessoptionty;

 tguiprocess = class(tmseprocess)
  private
   fdialogcaption: msestring;
   fdialoggaption: msestring;
   fdialogtext: msestring;
   foptionsgui: guiprocessoptionsty;
   function getcancontinue: boolean;
   procedure setcancontinue(const avalue: boolean);
  protected
   procedure setactive(const avalue: boolean) override;
   function getdialogcaption: msestring virtual;
   function getdialogtext: msestring virtual;
   procedure cancelev(const sender: tobject);
   procedure continueev(const sender: tobject);
   procedure doprocfinished() override;
  public
   property cancontinue: boolean read getcancontinue write setcancontinue;
  published
   property dialogcaption: msestring read fdialogcaption write fdialoggaption;
   property dialogtext: msestring read fdialogtext write fdialogtext;
   property optionsgui: guiprocessoptionsty read foptionsgui
                                            write foptionsgui default [];
 end;
 
implementation
uses
 msegui;
 
{ tguiprocess }

function tguiprocess.getcancontinue: boolean;
begin
 result:= prog_cancontinue in foptionsgui;
end;

procedure tguiprocess.setcancontinue(const avalue: boolean);
begin
 if avalue then begin
  optionsgui:= optionsgui + [prog_cancontinue];
 end
 else begin
  optionsgui:= optionsgui - [prog_cancontinue];
 end;
end;

procedure tguiprocess.setactive(const avalue: boolean);
begin
 inherited;
 if (prog_waitdialog in foptionsgui) and avalue and active then begin
  if prog_cancontinue in foptionsgui then begin
   application.waitdialog(nil,getdialogtext(),getdialogcaption(),@cancelev,nil,
                                                               nil,@continueev);
  end
  else begin
   application.waitdialog(nil,getdialogtext(),getdialogcaption(),@cancelev);
  end;
 end;
end;

function tguiprocess.getdialogcaption: msestring;
begin
 result:= fdialogcaption;
 if result = '' then begin
  result:= 'Process'
 end;
end;

function tguiprocess.getdialogtext: msestring;
begin
 result:= fdialogtext;
 if result = '' then begin
  result:= 'Running...'
 end;
end;

procedure tguiprocess.cancelev(const sender: tobject);
begin
 kill();
end;

procedure tguiprocess.continueev(const sender: tobject);
begin
 active:= false;
end;

procedure tguiprocess.doprocfinished();
begin
 inherited;
 if (prog_waitdialog in foptionsgui) and application.waitstarted() then begin
  application.terminatewait();
 end;
end;

end.
