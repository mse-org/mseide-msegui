{ MSEgui Copyright (c) 2009-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseifidialogcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseificompglob,mseificomp,mseapplication,mseclasses,mseglob,mseact,mserttistat;
 
type

 beforedialogeventty = procedure(const sender: tobject; 
                             const adialog: tactcomponent) of object;
 afterdialogeventty = procedure(const sender: tobject; 
                             const adialog: tactcomponent; 
                             const amodalresult: modalresultty) of object;

 ifidialoginfoty = record
  modalresult: modalresultty;
  dialog: tactcomponent;
 end;
 pifidialoginfoty = ^ifidialoginfoty;
 
 tdialogclientcontroller = class(tcustomificlientcontroller)
  private
   fonbeforedialog: beforedialogeventty;
   fonafterdialog: afterdialogeventty;
   finfopo: pifidialoginfoty;
   faction: tcustomaction;
   frttistat: tcustomrttistat;
   procedure execdialog(const alink: pointer; var handled: boolean); 
   procedure setaction(const avalue: tcustomaction);
   procedure setrttistat(const avalue: tcustomrttistat);
  protected
   procedure beforedialog(const adialog: tactcomponent);
   procedure objectevent(const sender: tobject; 
                                const event: objecteventty); override;
  public
   function execute: modalresultty; reintroduce;
  published
   property onbeforedialog: beforedialogeventty read fonbeforedialog 
                                                      write fonbeforedialog;
   property onafterdialog: afterdialogeventty read fonafterdialog 
                                                      write fonafterdialog;
   property action: tcustomaction read faction write setaction;
   property rttistat: tcustomrttistat read frttistat write setrttistat;
 end;
 
 tifidialoglinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tdialogclientcontroller;
   procedure setcontroller(const avalue: tdialogclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  published
   property controller: tdialogclientcontroller read getcontroller
                                                         write setcontroller;
 end;

implementation
type
 tmsecomponent1 = class(tmsecomponent);
 
{ tdialogclientcontroller }

procedure tdialogclientcontroller.beforedialog(const adialog: tactcomponent);
begin
 if frttistat <> nil then begin
  frttistat.objtovalues(adialog);
 end;
 if fowner.canevent(tmethod(fonbeforedialog)) then begin
  fonbeforedialog(self,adialog);
 end;
end;

procedure tdialogclientcontroller.execdialog(const alink: pointer;
               var handled: boolean);
begin
 handled:= true;
 with finfopo^ do begin
  modalresult:= iifidialoglink(alink).showdialog(dialog);
  if (modalresult = mr_ok) and (frttistat <> nil) then begin
   frttistat.valuestoobj(dialog);
  end;
  if fowner.canevent(tmethod(fonafterdialog)) then begin
   fonafterdialog(self,dialog,modalresult);
  end;
 end;
end;

function tdialogclientcontroller.execute: modalresultty;
var
 info1: ifidialoginfoty;
 po1: pifidialoginfoty;
begin
 po1:= finfopo;
 fillchar(info1,sizeof(info1),0);
 finfopo:= @info1;
 try
  tmsecomponent1(fowner).getobjectlinker.forfirst(
                           {$ifdef FPC}@{$endif}execdialog,self);
   result:= info1.modalresult;
 finally
  info1.dialog.release;
  finfopo:= po1;
 end;
end;

procedure tdialogclientcontroller.setaction(const avalue: tcustomaction);
begin
 setlinkedvar(avalue,tmsecomponent(faction));
end;

procedure tdialogclientcontroller.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_fired) and (sender = faction) then begin
  execute;
 end;
end;

procedure tdialogclientcontroller.setrttistat(const avalue: tcustomrttistat);
begin
 setlinkedvar(avalue,tmsecomponent(frttistat));
end;

{ tifidialoglinkcomp }

function tifidialoglinkcomp.getcontrollerclass: 
                                  customificlientcontrollerclassty;
begin
 result:= tdialogclientcontroller;
end;

function tifidialoglinkcomp.getcontroller: tdialogclientcontroller;
begin
 result:= tdialogclientcontroller(inherited controller);
end;

procedure tifidialoglinkcomp.setcontroller(
                                const avalue: tdialogclientcontroller);
begin
 inherited setcontroller(avalue);
end;

end.
