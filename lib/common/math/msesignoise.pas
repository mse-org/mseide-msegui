{ MSEgui Copyright (c) 2010-2013 by Martin Schreiber

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
 msesignal,classes,mclasses;
 
type
 noisekindty = (nk_white,nk_pink,nk_brown);
 
 tsignoise = class(tdoublesigoutcomp)
  private
   famplitudepo: psigvaluety;
   foffsetpo: psigvaluety;
   famplitude: tdoubleinputconn;
   foffset: tdoubleinputconn;
   fw,fz: longword; //random seeds
   fscale: double;
   fsamplehigh: integer;
   fsamplecount: integer;
   fkind: noisekindty;
   fcutofffrequ: real;
   fsum: real;
   fb0,fb1,fb2,fb3,fb4,fb5,fb6: double;
   fsumfact: real;
   procedure setamplitude(const avalue: tdoubleinputconn);
   procedure setoffset(const avalue: tdoubleinputconn);
   procedure setsamplecount(const avalue: integer);
   procedure setkind(const avalue: noisekindty);
   procedure setcutofffrequ(const avalue: real);
  protected
   procedure sighandlerbrown1(const ainfo: psighandlerinfoty);
   procedure sighandlerbrownn(const ainfo: psighandlerinfoty);
   procedure sighandlerpink1(const ainfo: psighandlerinfoty);
   procedure sighandlerpinkn(const ainfo: psighandlerinfoty);
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
   property kind: noisekindty read fkind write setkind default nk_white;
   property cutofffrequ: real read fcutofffrequ write setcutofffrequ;
                                      //nk_pink only, default 0.001
 end;
 
implementation
type
 tdoubleinputconn1 = class(tdoubleinputconn);

{ tsignoise }

constructor tsignoise.create(aowner: tcomponent);
begin
 fcutofffrequ:= 0.001;
 samplecount:= 1;
 inherited;
 famplitude:= tdoubleinputconn.create(self,isigclient(self));
 famplitude.name:= 'amplitude';
 famplitude.value:= 1;
 foffset:= tdoubleinputconn.create(self,isigclient(self));
 foffset.name:= 'offset';
end;

procedure tsignoise.clear;
begin
 fz:= random($ffffffff)+1;
 fw:= random($ffffffff)+1;
 fsum:= 0;
 fb0:= 0;
 fb1:= 0;
 fb2:= 0;
 fb3:= 0;
 fb4:= 0;
 fb5:= 0;
 fb6:= 0;
 inherited;
end;

function tsignoise.gethandler: sighandlerprocty;
begin
 if fsamplecount = 1 then begin
  case fkind of
   nk_pink: begin
    result:= {$ifdef FPC}@{$endif}sighandlerpink1;
   end;
   nk_brown: begin
    result:= {$ifdef FPC}@{$endif}sighandlerbrown1;
   end;
   else begin //nk_white
    result:= {$ifdef FPC}@{$endif}sighandler1;
   end;
  end;
 end
 else begin
  case fkind of
   nk_pink: begin
    result:= {$ifdef FPC}@{$endif}sighandlerpinkn;
   end;
   nk_brown: begin
    result:= {$ifdef FPC}@{$endif}sighandlerbrownn;
   end;
   else begin //nk_white
    result:= {$ifdef FPC}@{$endif}sighandlern;
   end;
  end;
 end;
end;

procedure tsignoise.initmodel;
var
 do1: double;
begin
 do1:= fcutofffrequ*2*pi;
 fsamplehigh:= fsamplecount - 1;
 fscale:= maxint * sqrt(fsamplecount);
 if do1 > 0 then begin
  case fkind of
   nk_pink: begin
    fscale:= fscale*4;
   end;
   nk_brown: begin
    fscale:= fscale/sqrt(do1);
   end;
  end;
 end;
 fsumfact:= exp(-do1);
 famplitudepo:= @tdoubleinputconn1(famplitude).fv;
 foffsetpo:= @tdoubleinputconn1(foffset).fv;
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

procedure tsignoise.sighandler1(const ainfo: psighandlerinfoty);
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 foutputpo^:= (integer((fz shl 16) + fw)/fscale)*famplitudepo^.value+
                                                          foffsetpo^.value;
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
  do1:= do1 + integer((fz shl 16) + fw);
 end;
 foutputpo^:= (do1*famplitudepo^.value)/fscale+foffsetpo^.value;
end;

procedure tsignoise.sighandlerpink1(const ainfo: psighandlerinfoty);
//filter after Paul Kellet
var
 white: double;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 white:= (integer((fz shl 16) + fw)/fscale);
 
 fb0:= 0.99886 * fb0 + white * 0.0555179; 
 fb1:= 0.99332 * fb1 + white * 0.0750759; 
 fb2:= 0.96900 * fb2 + white * 0.1538520; 
 fb3:= 0.86650 * fb3 + white * 0.3104856; 
 fb4:= 0.55000 * fb4 + white * 0.5329522; 
 fb5:= -0.7616 * fb5 - white * 0.0168980; 
 foutputpo^:= (fb0+fb1+fb2+fb3+fb4+fb5+fb6+white*0.5362) *
                             famplitudepo^.value + foffsetpo^.value; 
 fb6:= white * 0.115926;
end;

procedure tsignoise.sighandlerpinkn(const ainfo: psighandlerinfoty);
var
 int1: integer;
 white: double;
begin
 white:= 0;
 for int1:= 0 to fsamplehigh do begin //mwc by george marsaglia
  fz:= 36969 * (fz and $ffff) + (fz shr 16);
  fw:= 18000 * (fw and $ffff) + (fw shr 16);
  white:= white + integer((fz shl 16) + fw);
 end;
//filter after Paul Kellet
 
 fb0:= 0.99886 * fb0 + white * 0.0555179; 
 fb1:= 0.99332 * fb1 + white * 0.0750759; 
 fb2:= 0.96900 * fb2 + white * 0.1538520; 
 fb3:= 0.86650 * fb3 + white * 0.3104856; 
 fb4:= 0.55000 * fb4 + white * 0.5329522; 
 fb5:= -0.7616 * fb5 - white * 0.0168980; 
 foutputpo^:= ((fb0+fb1+fb2+fb3+fb4+fb5+fb6+white*0.5362) *
                             famplitudepo^.value)/fscale + foffsetpo^.value; 
 fb6:= white * 0.115926;
end;

procedure tsignoise.sighandlerbrown1(const ainfo: psighandlerinfoty);
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 fsum:= fsum*fsumfact + integer((fz shl 16) + fw)/fscale;
 foutputpo^:= fsum*famplitudepo^.value+foffsetpo^.value;
end;

procedure tsignoise.sighandlerbrownn(const ainfo: psighandlerinfoty);
var
 int1: integer;
 do1: double;
begin
 do1:= 0;
 for int1:= 0 to fsamplehigh do begin //mwc by george marsaglia
  fz:= 36969 * (fz and $ffff) + (fz shr 16);
  fw:= 18000 * (fw and $ffff) + (fw shr 16);
  do1:= do1 + integer((fz shl 16) + fw);
 end;
 fsum:= fsum*fsumfact+do1;
 foutputpo^:= (fsum*famplitudepo^.value)/fscale+foffsetpo^.value;
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
  modelchange;
  unlock;
 end;
end;

procedure tsignoise.setkind(const avalue: noisekindty);
begin
 if fkind <> avalue then begin
  lock;
  fkind:= avalue;
  modelchange;
  unlock;
 end;
end;

procedure tsignoise.setcutofffrequ(const avalue: real);
begin
 if fcutofffrequ <> avalue then begin
  lock;
  fcutofffrequ:= avalue;
  modelchange;
  unlock;
 end;
end;

end.
