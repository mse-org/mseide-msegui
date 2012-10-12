{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguirttistat;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegui,mserttistat,mseglob;
 
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
  public
   function edit: modalresultty;
   property dialogclass: widgetclassty read fdialogclass write fdialogclass;
  published
   property options: rttistatoptionsty read foptions write foptions default [];
   property ongetdialogclass: getwidgetclassprocty read fongetdialogclass 
                                                       write fongetdialogclass;
 end;
 
implementation

{ tguirttistat }

function tguirttistat.edit: modalresultty;
var
 dia1: twidget;
 cla1: widgetclassty;
begin
 result:= mr_none;
 cla1:= fdialogclass;
 if canevent(tmethod(fongetdialogclass)) then begin
  fongetdialogclass(self,cla1);
 end;
 if cla1 <> nil then begin
  dia1:= cla1.create(nil);
  try
   objtovalues(dia1);
   result:= dia1.show(ml_application);
   if result = mr_ok then begin
    valuestoobj(dia1);
    if (rso_autowritestat in foptions) and (statfile <> nil) then begin
     statfile.writestat;
    end;
   end;
  finally
   dia1.free;
  end;
 end;
end;

end.
