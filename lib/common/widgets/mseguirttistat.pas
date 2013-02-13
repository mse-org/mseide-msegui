{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguirttistat;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}
interface
uses
 msegui,mserttistat,mseglob,mseclasses,msestat,msestatfile;
 
type
 rttistatoption = (rso_autowritestat);
 rttistatoptionsty = set of rttistatoption;
 
 getwidgetclassprocty = procedure (const sender: tobject;
                                  var aclass: widgetclassty) of object;
 tguirttistat = class(trttistat)
  private
   fongetdialogclass: getwidgetclassprocty;
   fdialogclass: widgetclassty;
   foptions: rttistatoptionsty;
   fdialog: twidget;
   fonbeforeedit: notifyeventty;
   fonafteredit: notifyeventty;
   fediting: boolean;
  public
   function edit: modalresultty;
   property dialogclass: widgetclassty read fdialogclass write fdialogclass;
   property dialog: twidget read fdialog;
   property editing: boolean read fediting;
  published
   property options: rttistatoptionsty read foptions write foptions default [];
   property ongetdialogclass: getwidgetclassprocty read fongetdialogclass 
                                                       write fongetdialogclass;
   property onbeforeedit: notifyeventty read fonbeforeedit write fonbeforeedit;
   property onafteredit: notifyeventty read fonafteredit write fonafteredit;
 end;
 
implementation
uses
 sysutils;
 
{ tguirttistat }

function tguirttistat.edit: modalresultty;
var
// dia1: twidget;
 cla1: widgetclassty;
begin
 result:= mr_none;
 cla1:= fdialogclass;
 if canevent(tmethod(fongetdialogclass)) then begin
  fongetdialogclass(self,cla1);
 end;
 if cla1 <> nil then begin
  fdialog:= cla1.create(nil);
  fediting:= true;
  try
 {$ifdef mse_with_ifi}
   objtovalues(fdialog);
 {$endif}
   if canevent(tmethod(fonbeforeedit)) then begin
    fonbeforeedit(self);
   end;
   result:= fdialog.show(ml_application);
   if result = mr_ok then begin
 {$ifdef mse_with_ifi}
    valuestoobj(fdialog);
 {$endif}
    if canevent(tmethod(fonafteredit)) then begin
     fonafteredit(self);
    end;
    if (rso_autowritestat in foptions) and (statfile <> nil) then begin
     statfile.writestat;
    end;
   end;
  finally
   fediting:= false;
   freeandnil(fdialog);
  end;
 end;
end;

end.
