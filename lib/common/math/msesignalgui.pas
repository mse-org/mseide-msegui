{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesignalgui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msegraphedits,msesignal;
 
type
 sigeditoptionty = (sieo_exp);
 sigeditoptionsty = set of sigeditoptionty;
 
 tsigslider = class(tslider,isigclient)
  private
   foutput: tdoubleoutputconn;
   fcontroller: tsigcontroller;
   fontransformvalue: sigineventty;
   fmin: real;
   fmax: real;
   foptions: sigeditoptionsty;
   procedure setoutput(const avalue: tdoubleoutputconn);
   procedure setcontroller(const avalue: tsigcontroller);
   procedure setmin(const avalue: real);
   procedure setmax(const avalue: real);
   procedure setoptions(const avalue: sigeditoptionsty);
  protected
   fsigvalue: real;
   procedure updatesigvalue;
   procedure dochange; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
    //isigclient  
   procedure initmodel;
   function getinputar: inputconnarty;
   function getoutputar: outputconnarty;
   function gethandler: sighandlerprocty;
   function getzcount: integer;
   procedure clear;
   procedure connchange;
   function getsigcontroller: tsigcontroller;
  public
   constructor create(aowner: tcomponent); override;
   property output: tdoubleoutputconn read foutput write setoutput;
  published
   property controller: tsigcontroller read fcontroller write setcontroller;
   property ontransformvalue: sigineventty read fontransformvalue 
                                                 write fontransformvalue;
   property min: real read fmin write setmin;
   property max: real read fmax write setmax;
   property options: sigeditoptionsty read foptions write setoptions default [];
 end;
 
implementation

{ tsigslider }

constructor tsigslider.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self,isigclient(self));
 fmax:= 1;
 inherited;
end;

procedure tsigslider.setcontroller(const avalue: tsigcontroller);
begin
 setsigcontroller(getobjectlinker,isigclient(self),avalue,fcontroller);
end;

procedure tsigslider.initmodel;
begin
 //dummy
end;

function tsigslider.getinputar: inputconnarty;
begin
 result:= nil;
end;

function tsigslider.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

function tsigslider.getzcount: integer;
begin
 result:= 0;
end;

procedure tsigslider.clear;
begin
 //dummy
end;

procedure tsigslider.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

procedure tsigslider.connchange;
begin
 //dummy
end;

function tsigslider.getsigcontroller: tsigcontroller;
begin
 result:= fcontroller;
end;

procedure tsigslider.updatesigvalue;
var
 do1: double;
begin
 do1:= fvalue*(fmax-fmin)+fmin; 
 if sieo_exp in foptions then begin
  do1:= exp(do1);
 end;
 if canevent(tmethod(fontransformvalue)) then begin
  fontransformvalue(self,do1);
 end;
 if fcontroller <> nil then begin
  fcontroller.lock;
 end;
 fsigvalue:= do1;
 if fcontroller <> nil then begin
  fcontroller.unlock;
 end;
end;

procedure tsigslider.dochange;
begin
 inherited;
 updatesigvalue; 
end;

procedure tsigslider.sighandler(const ainfo: psighandlerinfoty);
begin
 ainfo^.dest^:= fsigvalue;
end;

function tsigslider.gethandler: sighandlerprocty;
begin
 result:= @sighandler;
end;

procedure tsigslider.setmin(const avalue: real);
begin
 fmin:= avalue;
 updatesigvalue;
end;

procedure tsigslider.setmax(const avalue: real);
begin
 fmax:= avalue;
 updatesigvalue;
end;

procedure tsigslider.setoptions(const avalue: sigeditoptionsty);
begin
 if options <> avalue then begin
  foptions:= avalue;
  updatesigvalue;
 end;
end;

end.
