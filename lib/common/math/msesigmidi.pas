{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesigmidi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesignal,classes,msemidi;
type
 tsigmidiconnector = class(tsigeventconnector)
  private
   ffrequout: tdoubleoutputconn;
   ftrigout: tdoubleoutputconn;
   ffrequmin: double;
   procedure setfrequout(const avalue: tdoubleoutputconn);
   procedure settrigout(const avalue: tdoubleoutputconn);
  protected
   ftrigvalue: double;
   procedure sighandler(const ainfo: psighandlerinfoty);
   function getoutputar: outputconnarty; override;
   function gethandler: sighandlerprocty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure midievent(const ainfo: midieventinfoty);
   property frequout: tdoubleoutputconn read ffrequout write setfrequout;
   property trigout: tdoubleoutputconn read ftrigout write settrigout;
  published
   property frequmin: double read ffrequmin write ffrequmin;
 end;
 
implementation
uses
 math;
type
 tsigcontroller1 = class(tsigcontroller);
 tdoubleoutputconn1 = class(tdoubleoutputconn);
 
{ tsigmidiconnector }

constructor tsigmidiconnector.create(aowner: tcomponent);
begin
 ffrequmin:= 0.001;
 ffrequout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ffrequout.name:= 'frequout';
 ftrigout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ftrigout.name:= 'triguout';
 inherited;
end;

destructor tsigmidiconnector.destroy;
begin
 inherited;
end;

procedure tsigmidiconnector.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 ainfo^.dest^:= ftrigvalue;
end;

function tsigmidiconnector.getoutputar: outputconnarty;
begin
 setlength(result,2);
 result[0]:= ftrigout;
 result[1]:= ffrequout;
end;

function tsigmidiconnector.gethandler: sighandlerprocty;
begin
 result:= @sighandler;
end;

procedure tsigmidiconnector.setfrequout(const avalue: tdoubleoutputconn);
begin
 ffrequout.assign(avalue);
end;

procedure tsigmidiconnector.settrigout(const avalue: tdoubleoutputconn);
begin
 ftrigout.assign(avalue);
end;

procedure tsigmidiconnector.midievent(const ainfo: midieventinfoty);
begin
 lock;
 try
  with ainfo do begin
   case kind of
    mmk_noteon: begin
     tdoubleoutputconn1(ffrequout).fvalue:= intpower(2.0,par1 div 12) * 
                          chromaticscale[par1 mod 12] * ffrequmin;
     if par2 = 0 then begin
      ftrigvalue:= -1;
     end
     else begin
      ftrigvalue:= 1;
     end;
    end;
    mmk_noteoff: begin
     ftrigvalue:= -1;
    end;
   end;
  end;
  if fcontroller <> nil then begin
   tsigcontroller1(fcontroller).execevent(isigclient(self));
  end;
 finally
  unlock;
 end;
end;

end.
