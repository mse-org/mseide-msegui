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
unit toolhandlermodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseglob,mseapplication,mseclasses,msedatamodules,msepipestream,
 mseprocess,mseprocutils,msetypes,msestrings;

type
 ttoolhandlermo = class(tmsedatamodule)
   proc: tmseprocess;
   procedure inputavailexe(const sender: tpipereader);
   procedure procfinishedexe(const sender: TObject);
  public
   constructor create(const aowner: tcomponent; const acommandline: msestring;
                const aoptions: execoptionsty); reintroduce;
 end;

implementation
uses
 toolhandlermodule_mfm,make,messageform;

procedure ttoolhandlermo.inputavailexe(const sender: tpipereader);
begin
 addmessagetext(sender,nil);
end;

procedure ttoolhandlermo.procfinishedexe(const sender: TObject);
begin
 release;
end;

constructor ttoolhandlermo.create(const aowner: tcomponent;
               const acommandline: msestring; const aoptions: execoptionsty);
var
 opt1: processoptionsty;
begin
 inherited create(aowner);
 name:= '';
 proc.commandline:= acommandline;
 opt1:= [pro_tty,pro_output,pro_errorouttoout];
 if exo_inactive in aoptions then begin
  include(opt1,pro_inactive);
 end;
 proc.options:= opt1;
 messagefo.messages.clear;
 proc.active:= true;
 messagefo.activate;
end;

end.
