{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msesignoise;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesignal,classes;
 
type
 tsignoise = class(tdoublesigoutcomp)
  private
   famplitudepo: pdouble;
   foffsetpo: pdouble;
   famplitude: tdoubleinputconn;
   foffset: tdoubleinputconn;
   fw,fz: longword; //random seeds
   fscale: double;
   fsamplehigh: integer;
   fsamplecount: integer;
   procedure setamplitude(const avalue: tdoubleinputconn);
   procedure setoffset(const avalue: tdoubleinputconn);
   procedure setsamplecount(const avalue: integer);
  protected
   procedure sighandler1(const ainfo: psighandlerinfoty);
   procedure sighandlern(const ainfo: psighandlerinfoty);
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure initmodel; override;
   function getinputar: inputconnarty; override;
   function getzcount: integer; override;   
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
  published
   property amplitude: tdoubleinputconn read famplitude write setamplitude;
   property offset: tdoubleinputconn read foffset write setoffset;
   property samplecount: integer read fsamplecount 
                                     write setsamplecount default 1;
                      //1 -> uniform distribution
 end;
 
implementation
type
 tdoubleinputconn1 = class(tdoubleinputconn);

{ tsignoise }

constructor tsignoise.create(aowner: tcomponent);
begin
 samplecount:= 1;
 inherited;
 famplitude:= tdoubleinputconn.create(self,isigclient(self));
 famplitude.name:= 'amplitude';
 foffset:= tdoubleinputconn.create(self,isigclient(self));
 foffset.name:= 'offset';
end;

procedure tsignoise.clear;
begin
 fz:= random($ffffffff)+1;
 fw:= random($ffffffff)+1;
 inherited;
end;

function tsignoise.gethandler: sighandlerprocty;
begin
 if fsamplecount = 1 then begin
  result:= @sighandler1;
 end
 else begin
  result:= @sighandlern;
 end;
end;

procedure tsignoise.initmodel;
begin
 famplitudepo:= @tdoubleinputconn1(famplitude).fvalue;
 foffsetpo:= @tdoubleinputconn1(foffset).fvalue;
 inherited;
end;

function tsignoise.getinputar: inputconnarty;
begin
 setlength(result,2);
 result[0]:= famplitude;
 result[1]:= foffset;
end;

function tsignoise.getzcount: integer;
begin
 result:= 1;
end;

procedure tsignoise.sighandlern(const ainfo: psighandlerinfoty);
var
 int1: integer;
 do1: double;
begin
 do1:= 0;
 for int1:= 0 to fsamplehigh do begin //mwc by george marsaglia
  fz:= 36969 * (fz and $ffff) + (fz shr 16);
  fw:= 18000 * (fw and $ffff) + (fw shr 16);
  do1:= do1 + integer((fz shl 16) + fw)/fscale;
 end;
 ainfo^.dest^:= do1;
end;

procedure tsignoise.sighandler1(const ainfo: psighandlerinfoty);
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 ainfo^.dest^:= integer((fz shl 16) + fw)/fscale;
end;

procedure tsignoise.setamplitude(const avalue: tdoubleinputconn);
begin
 famplitude.assign(avalue);
end;

procedure tsignoise.setoffset(const avalue: tdoubleinputconn);
begin
 foffset.assign(avalue);
end;

procedure tsignoise.setsamplecount(const avalue: integer);
begin
 if fsamplecount <> avalue then begin
  lock;
  fsamplecount:= avalue;
  if fsamplecount <= 0 then begin
   fsamplecount:= 1;
  end;
  fsamplehigh:= fsamplecount - 1;
  fscale:= maxint * sqrt(fsamplecount);
  modelchange;
  unlock;
 end;
end;

end.
