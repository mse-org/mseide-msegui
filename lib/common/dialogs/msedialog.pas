{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface

uses
 mseclasses,msegui,mseglob,mseguiglob,
 mseforms,msedataedits,mseedit,classes,mseevent,
 msemenus,msestrings,mseeditglob,msetypes;

type
 tdialogform = class(tmseform)
  protected
   procedure updatewindowinfo(var info: windowinfoty); override;
   class function hasresource: boolean; override;
 end;

 tdialog = class(tmsecomponent)
  public
   function execute: modalresultty; virtual; abstract;
 end;

  tellipsebuttonframe = class(tbuttonframe)
  private
   function getbutton: tstockglyphframebutton;
   procedure setbutton(const avalue: tstockglyphframebutton);
  public
   constructor create(const intf: icaptionframe;
                       const buttonintf: ibutton); reintroduce;
  published
   property button: tstockglyphframebutton read getbutton write setbutton;
 end;

 tdataeditcontroller = class(teventpersistent)
 end;
 
 tdialogcontroller = class(tdataeditcontroller,ibutton,idataeditcontroller)
  protected
   fowner: tcustomdataedit;
   procedure internalexecute; virtual; abstract;
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
   function iskeyexecute(const info: keyeventinfoty): boolean; virtual;

    //idataeditcontroller
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty); virtual;
   procedure dokeydown(var info: keyeventinfoty); virtual;
   procedure updatereadonlystate; virtual;
   procedure internalcreateframe; virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
  public
   constructor create(const aowner: tcustomdataedit); reintroduce;
 end;

 stringdialogexeceventty = procedure(const sender: tcustomdataedit;
            var avalue:msestring; var modresult: modalresultty) of object;
                                       //default mr_ok 
 tstringdialogcontroller = class(tdialogcontroller)
  protected
   fonexecute: stringdialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: msestring): boolean; virtual;
   procedure setexecresult(var avalue: msestring); virtual;
  public
   constructor create(const aowner: tcustomstringedit);
   property onexecute: stringdialogexeceventty read fonexecute write fonexecute;
 end;

// ieditcontroller = interface (ibutton)
// end;
   
 tcustomdialogstringed = class(tstringedit{,ibutton})
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
  protected
   fdialogcontroller: tdialogcontroller;
   function createdialogcontroller: tstringdialogcontroller; virtual;
//   fbuttonintf: ibutton;
//   property buttonintf: ibutton read fbuttonintf implements ibutton;
//   property controller: tdialogcontroller read fcontroller 
//                                                       implements ibutton;
                             //crash with FPC

//   procedure internalcreateframe; override;
//   procedure dokeydown(var info: keyeventinfoty); override;
//   procedure mouseevent(var info: mouseeventinfoty); override;
//   procedure updatereadonlystate; override;

    //ibutton
//   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);

//   procedure internalexecute;
//   function execute(var avalue: msestring): boolean; virtual;
//   procedure setexecresult(var avalue: msestring); virtual;
//   function iskeyexecute(const info: keyeventinfoty): boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property frame: tellipsebuttonframe read getframe write setframe;
 end;

 tdialogstringed = class(tcustomdialogstringed)
  published
   property frame;
   property passwordchar;
   property maxlength;
   property value;
   property onsetvalue;
 end;

 tcustomdialogstringedit = class(tcustomdialogstringed)
//  private
//   fonexecute: dialogexeceventty;
  private
   function getonexecute: stringdialogexeceventty;
   procedure setonexecute(const avalue: stringdialogexeceventty);
  protected
//   function execute(var avalue: msestring): boolean; override;
  public
   property onexecute: stringdialogexeceventty read getonexecute write setonexecute;
 end;

 tdialogstringedit = class(tcustomdialogstringedit)
  published
   property onexecute;
 end;
 
 realdialogexeceventty = procedure(const sender: tcustomdataedit;
            var avalue: realty; var modresult: modalresultty) of object;
                                       //default mr_ok 
 trealdialogcontroller = class(tdialogcontroller)
  private
  protected
   fonexecute: realdialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: realty): boolean; virtual;
   procedure setexecresult(var avalue: realty); virtual;
  public
   constructor create(const aowner: tcustomrealedit);
   property onexecute: realdialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogrealedit = class(trealedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: realdialogexeceventty;
   procedure setonexecute(const avalue: realdialogexeceventty);
  protected
   fdialogcontroller: trealdialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: realdialogexeceventty read getonexecute 
                                                        write setonexecute;
 end;

 datetimedialogexeceventty = procedure(const sender: tcustomdataedit;
                  var avalue: tdatetime; var modresult: modalresultty) of object;
                                       //default mr_ok 
 tdatetimedialogcontroller = class(tdialogcontroller)
  private
  protected
   fonexecute: datetimedialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: tdatetime): boolean; virtual;
   procedure setexecresult(var avalue: tdatetime); virtual;
  public
   constructor create(const aowner: tcustomdatetimeedit);
   property onexecute: datetimedialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogdatetimeedit = class(tdatetimeedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: datetimedialogexeceventty;
   procedure setonexecute(const avalue: datetimedialogexeceventty);
  protected
   fdialogcontroller: tdatetimedialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: datetimedialogexeceventty read getonexecute 
                                                        write setonexecute;
 end;

 integerdialogexeceventty = procedure(const sender: tcustomdataedit;
            var avalue: integer; var modresult: modalresultty) of object;
                                       //default mr_ok 
 tintegerdialogcontroller = class(tdialogcontroller)
  private
  protected
   fonexecute: integerdialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: integer): boolean; virtual;
   procedure setexecresult(var avalue: integer); virtual;
  public
   constructor create(const aowner: tcustomintegeredit);
   property onexecute: integerdialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogintegeredit = class(tintegeredit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: integerdialogexeceventty;
   procedure setonexecute(const avalue: integerdialogexeceventty);
  protected
   fdialogcontroller: tintegerdialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: integerdialogexeceventty read getonexecute 
                                                        write setonexecute;
 end;

 
implementation
uses
 msestockobjects,msekeyboard,mseformatstr,msereal,sysutils;

type
 tcustomdataedit1 = class(tcustomdataedit);
 tcustomrealedit1 = class(tcustomrealedit);
 tcustomdatetimeedit1 = class(tcustomdatetimeedit);
 tcustomintegeredit1 = class(tcustomintegeredit);
 
{ tdialogform }

procedure tdialogform.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= [wo_message];
end;

class function tdialogform.hasresource: boolean;
begin
 result:= false;
end;

{ tellipsebuttonframe }

constructor tellipsebuttonframe.create(const intf: icaptionframe;
  const buttonintf: ibutton);
begin
 inherited;
 buttons.count:= 1;
 buttons[0].imagelist:= stockobjects.glyphs;
 buttons[0].imagenr:= ord(stg_ellipsesmall);
end;

function tellipsebuttonframe.getbutton: tstockglyphframebutton;
begin
 result:= tstockglyphframebutton(buttons[0]);
end;

procedure tellipsebuttonframe.setbutton(const avalue: tstockglyphframebutton);
begin
 buttons[0].assign(avalue);
end;

{ tdialogcontroller }

constructor tdialogcontroller.create(const aowner: tcustomdataedit);
begin
 fowner:= aowner;
 tcustomdataedit1(fowner).fcontrollerintf:= idataeditcontroller(self);
 internalcreateframe;
end;

procedure tdialogcontroller.buttonaction(var action: buttonactionty;
               const buttonindex: integer);
begin
 with fowner do begin
  if action = ba_click then begin
   if canfocus and not setfocus then begin
    exit;
   end;
   internalexecute;
  end;
 end;
end;

procedure tdialogcontroller.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if iskeyexecute(info) then begin
   include(info.eventstate,es_processed);
   internalexecute;
  end;
 end;
end;

function tdialogcontroller.iskeyexecute(const info: keyeventinfoty): boolean;
begin
 with fowner,info do begin
  result:= not readonly and (oe_keyexecute in optionsedit) and (key = key_down) and 
           (shiftstate = [ss_alt]);
 end;
end;

procedure tdialogcontroller.updatereadonlystate;
begin
 with tcustomdataedit1(fowner) do begin
  if fframe <> nil then begin
   with tcustombuttonframe(fframe) do begin
    if buttons.count > 0 then begin
     buttons[0].enabled:= not (oe_readonly in getoptionsedit);
    end;
   end;
  end;  
 end;
end;

procedure tdialogcontroller.internalcreateframe;
begin
 tellipsebuttonframe.create(iscrollframe(fowner),ibutton(self));
 updatereadonlystate;
end;

procedure tdialogcontroller.mouseevent(var info: mouseeventinfoty);
begin
 with tcustomdataedit1(fowner) do begin
  tcustombuttonframe(fframe).mouseevent(info);
 end;
end;

procedure tdialogcontroller.domousewheelevent(var info: mousewheeleventinfoty);
begin
 //dummy
end;

procedure tdialogcontroller.editnotification(var info: editnotificationinfoty);
begin
 //dummy
end;

{ tstringdialogcontroller }

constructor tstringdialogcontroller.create(const aowner: tcustomstringedit);
begin
 inherited create(aowner);
end;

procedure tstringdialogcontroller.internalexecute;
var
 str1: msestring;
begin
 with tcustomstringedit(fowner) do begin
  str1:= text;
  if execute(str1) then begin
   setexecresult(str1);
   checkvalue;
  end;
 end;
end;

function tstringdialogcontroller.execute(var avalue: msestring): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure tstringdialogcontroller.setexecresult(var avalue: msestring);
begin
 with tcustomstringedit(fowner) do begin
  text:= avalue;
 end;
end;

{ tcustomdialogstringed }

constructor tcustomdialogstringed.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= createdialogcontroller;
 end;
// fbuttonintf:= ibutton(fcontroller);
// inherited;
// internalcreateframe;
end;

destructor tcustomdialogstringed.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tcustomdialogstringed.createdialogcontroller: tstringdialogcontroller;
begin
 result:= tstringdialogcontroller.create(self);
end;
{
procedure tcustomdialogstringed.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 if action = ba_click then begin
  if canfocus and not setfocus then begin
   exit;
  end;
  internalexecute;
 end;
end;
}
{
procedure tcustomdialogstringed.internalcreateframe;
begin
 tellipsebuttonframe.create(iscrollframe(self),ibutton(self));
 updatereadonlystate;
end;
}
{
function tcustomdialogstringed.execute(var avalue: msestring): boolean;
begin
 result:= false;
end;

procedure tcustomdialogstringed.setexecresult(var avalue: msestring);
begin
 text:= avalue;
end;

procedure tcustomdialogstringed.internalexecute;
var
 str1: msestring;
begin
 str1:= text;
 if execute(str1) then begin
  setexecresult(str1);
  checkvalue;
 end;
end;
}
{
procedure tcustomdialogstringed.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 tcustombuttonframe(fframe).mouseevent(info);
end;
}
{
function tcustomdialogstringed.iskeyexecute(const info: keyeventinfoty): boolean;

begin
 with info do begin
  result:= not readonly and (oe_keyexecute in foptionsedit) and (key = key_down) and 
           (shiftstate = [ss_alt]);
 end;
end;
}
(*
procedure tcustomdialogstringed.dokeydown(var info: keyeventinfoty);
begin
{
 with info do begin
  if iskeyexecute(info) then begin
   include(info.eventstate,es_processed);
   internalexecute;
  end
  else begin
   inherited;
  end;
 end;
}
 fcontroller.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
*)
function tcustomdialogstringed.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tcustomdialogstringed.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

{
procedure tcustomdialogstringed.updatereadonlystate;
begin
 inherited;
 if fframe <> nil then begin
  with frame do begin
   if buttons.count > 0 then begin
    frame.buttons[0].enabled:= not (oe_readonly in getoptionsedit);
   end;
  end;
 end;
end;
}
{ tcustomdialogstringedit }
{
function tcustomdialogstringedit.execute(var avalue: msestring): boolean;
var
 mr1: modalresultty;
begin
 if canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(self,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;
}
function tcustomdialogstringedit.getonexecute: stringdialogexeceventty;
begin
 result:= tstringdialogcontroller(fdialogcontroller).onexecute;
end;

procedure tcustomdialogstringedit.setonexecute(const avalue: stringdialogexeceventty);
begin
 tstringdialogcontroller(fdialogcontroller).onexecute:= avalue;
end;

{ trealdialogcontroller }

constructor trealdialogcontroller.create(const aowner: tcustomrealedit);
begin
 inherited create(aowner);
end;

procedure trealdialogcontroller.internalexecute;
var
 rea1: realty;
 bo1: boolean;
begin
 with tcustomrealedit1(fowner) do begin
  bo1:= true;
  rea1:= gettextvalue(bo1,false);
  if bo1 and execute(rea1) then begin
   setexecresult(rea1);
   checkvalue;
  end;
 end;
end;

function trealdialogcontroller.execute(var avalue: realty): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure trealdialogcontroller.setexecresult(var avalue: realty);
begin
 with tcustomrealedit(fowner) do begin
  text:= realtytostrrange(avalue,formatedit,valuerange,valuestart);
 end;
end;

{ tdialogrealedit }

constructor tdialogrealedit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= trealdialogcontroller.create(self);
 end;
end;

destructor tdialogrealedit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdialogrealedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogrealedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdialogrealedit.getonexecute: realdialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdialogrealedit.setonexecute(const avalue: realdialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

{ tdatetimedialogcontroller }

constructor tdatetimedialogcontroller.create(const aowner: tcustomdatetimeedit);
begin
 inherited create(aowner);
end;

procedure tdatetimedialogcontroller.internalexecute;
var
 dat1: tdatetime;
 bo1: boolean;
begin
 with tcustomdatetimeedit1(fowner) do begin
  bo1:= true;
  dat1:= gettextvalue(bo1,false);
  if bo1 and execute(dat1) then begin
   setexecresult(dat1);
   checkvalue;
  end;
 end;
end;

function tdatetimedialogcontroller.execute(var avalue: tdatetime): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure tdatetimedialogcontroller.setexecresult(var avalue: tdatetime);
begin
 with tcustomdatetimeedit(fowner) do begin
  case kind of 
   dtk_time: begin
    text:= mseformatstr.timetostring(avalue,formatedit);
   end;
   dtk_date: begin
    text:= mseformatstr.datetostring(avalue,formatedit);
   end;
   else begin
    text:= mseformatstr.datetimetostring(avalue,formatedit);
   end;
  end;
 end;
end;

{ tdialogdatetimeedit }

constructor tdialogdatetimeedit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= tdatetimedialogcontroller.create(self);
 end;
end;

destructor tdialogdatetimeedit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdialogdatetimeedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogdatetimeedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdialogdatetimeedit.getonexecute: datetimedialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdialogdatetimeedit.setonexecute(const avalue: datetimedialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

{ tintegerdialogcontroller }

constructor tintegerdialogcontroller.create(const aowner: tcustomintegeredit);
begin
 inherited create(aowner);
end;

procedure tintegerdialogcontroller.internalexecute;
var
 int1: integer;
 bo1: boolean;
begin
 with tcustomintegeredit1(fowner) do begin
  bo1:= true;
  int1:= gettextvalue(bo1,false);
  if bo1 and execute(int1) then begin
   setexecresult(int1);
   checkvalue;
  end;
 end;
end;

function tintegerdialogcontroller.execute(var avalue: integer): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure tintegerdialogcontroller.setexecresult(var avalue: integer);
begin
 with tcustomintegeredit(fowner) do begin
  text:= inttostr(avalue);
 end;
end;

{ tdialogintegeredit }

constructor tdialogintegeredit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= tintegerdialogcontroller.create(self);
 end;
end;

destructor tdialogintegeredit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdialogintegeredit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogintegeredit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdialogintegeredit.getonexecute: integerdialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdialogintegeredit.setonexecute(const avalue: integerdialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

end.
