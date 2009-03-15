{ MSEgui Copyright (c) 1999-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msecalendardatetimeedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msedataedits,msepopupcalendar,msedropdownlist,msetypes,msegraphutils,
 mseguiglob,mseinplaceedit,mseedit,msestrings,msegui,mseevent,msemenus;
 
type
 tcustomcalendardatetimeedit = class(tcustomdatetimeedit,idropdowncalendar)
  private
   fdropdown: tcalendarcontroller;
   procedure setframe(const avalue: tdropdownbuttonframe);
   function getframe: tdropdownbuttonframe;
  protected
   function getcellframe: framety; override;
   procedure internalcreateframe; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure updatereadonlystate; override;
  //idropdownwidget
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
   procedure dobeforedropdown;
   procedure doafterclosedropdown;
   procedure createdropdownwidget(const atext: msestring; out awidget: twidget);
   function getdropdowntext(const awidget: twidget): msestring;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property dropdown: tcalendarcontroller read fdropdown write fdropdown;
  published
   property frame: tdropdownbuttonframe read getframe write setframe;
 end;
  
 tcalendardatetimeedit = class(tcustomcalendardatetimeedit)
  published
   property onsetvalue;
   property value stored false;
   property formatedit;
   property formatdisp;
   property min stored false;
   property max stored false;
   property kind;
   property dropdown;
 end;


implementation
uses
 sysutils,mseformatstr;
 
{ tcustomcalendardatetimeedit }

constructor tcustomcalendardatetimeedit.create(aowner: tcomponent);
begin
 inherited;
 fdropdown:= tcalendarcontroller.create(idropdowncalendar(self));
end;

destructor tcustomcalendardatetimeedit.destroy;
begin
 fdropdown.free;
 inherited;
end;

procedure tcustomcalendardatetimeedit.setframe(const avalue: tdropdownbuttonframe);
begin
 inherited setframe(avalue);
end;

function tcustomcalendardatetimeedit.getframe: tdropdownbuttonframe;
begin
 result:= tdropdownbuttonframe(inherited getframe);
end;

procedure tcustomcalendardatetimeedit.internalcreateframe;
begin
 fdropdown.createframe;
end;

procedure tcustomcalendardatetimeedit.dokeydown(var info: keyeventinfoty);
begin
 fdropdown.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomcalendardatetimeedit.domousewheelevent(
                                  var info: mousewheeleventinfoty);
begin
 fdropdown.domousewheelevent(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomcalendardatetimeedit.mouseevent(var info: mouseeventinfoty);
begin
 tcustombuttonframe(fframe).mouseevent(info);
 inherited;
end;

procedure tcustomcalendardatetimeedit.buttonaction(var action: buttonactionty;
               const buttonindex: integer);
begin
 //dummy
end;

procedure tcustomcalendardatetimeedit.dobeforedropdown;
begin
 //dummy
end;

procedure tcustomcalendardatetimeedit.doafterclosedropdown;
begin
 //dummy
end;

procedure tcustomcalendardatetimeedit.createdropdownwidget(
         const atext: msestring; out awidget: twidget);
var
 dat1: tdatetime;
 mstr1: msestring;
 bo1: boolean;
begin
 bo1:= true;
 mstr1:= atext;
 checktext(mstr1,bo1);
 if not bo1 then begin
  abort;
 end;
 awidget:= tpopupcalendarfo.create(nil,fdropdown);
 dat1:= now;
 if trim(mstr1) <> '' then begin
  try
   dat1:= stringtodatetime(mstr1);
  except
  end;
 end;
 tpopupcalendarfo(awidget).value:= dat1;
end;

function tcustomcalendardatetimeedit.getdropdowntext(const awidget: twidget): msestring;
begin
 result:= text;
end;

procedure tcustomcalendardatetimeedit.editnotification(var info: editnotificationinfoty);
begin
 if fdropdown <> nil then begin
  fdropdown.editnotification(info);
 end;
 inherited;
end;

procedure tcustomcalendardatetimeedit.updatereadonlystate;
begin
 inherited;
 if fdropdown <> nil then begin
  fdropdown.updatereadonlystate;
 end;
end;

function tcustomcalendardatetimeedit.getcellframe: framety;
begin
 result:= fframe.cellframe;
end;

end.
