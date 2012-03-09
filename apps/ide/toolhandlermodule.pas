unit toolhandlermodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseglob,mseapplication,mseclasses,msedatamodules,msepipestream,
 mseprocess,mseprocutils;

type
 ttoolhandlermo = class(tmsedatamodule)
   proc: tmseprocess;
   procedure inputavailexe(const sender: tpipereader);
   procedure procfinishedexe(const sender: TObject);
  public
   constructor create(const aowner: tcomponent; const acommandline: string;
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
               const acommandline: string; const aoptions: execoptionsty);
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
