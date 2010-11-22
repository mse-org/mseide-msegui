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
 classes,msegraphedits,msesignal,mseguiglob,mseevent,msechartedit,msetypes,
 msechart,mseclasses;
const
 defaultwavetraceoptions = [cto_xordered];
 defaultsamplecount = 4096;
 
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
   procedure modelchange;
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

 twavetrace = class(ttrace)
  protected
   procedure setkind(const avalue: tracekindty); override;
   procedure setoptions(const avalue: charttraceoptionsty); override;
  public
   constructor create(aowner: tobject); override;
  published
   property kind default trk_xy;
   property options default defaultwavetraceoptions;
 end;
 
 twavetraces = class(ttraces)
  protected
   procedure setkind(const avalue: tracekindty); override;
   procedure setoptions(const avalue: charttraceoptionsty); override;
  public
   constructor create(const aowner: tcustomchart);
   class function getitemclasstype: persistentclassty; override;
  published
   property kind default trk_xy;
   property options default defaultwavetraceoptions;
 end;

 twavetableedit = class(tchartedit)
  private
   fwave: tsigwavetable;
   fsamplecount: integer;
   procedure setwave(const avalue: tsigwavetable);
   procedure setsamplecount(const avalue: integer);
  protected
   procedure sample;
   procedure dochange; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property samplecount: integer read fsamplecount 
                                 write setsamplecount default defaultsamplecount;
   property wave: tsigwavetable read fwave write setwave;
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

procedure tsigslider.modelchange;
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
  fontransformvalue(self,real(do1));
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
 result:= {$ifdef FPC}@{$endif}sighandler;
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

{ twavetableedit }

constructor twavetableedit.create(aowner: tcomponent);
begin
 fsamplecount:= defaultsamplecount;
 if ftraces = nil then begin
  ftraces:= twavetraces.create(self);
 end;
 inherited;
 fwave:= tsigwavetable.create(self);
 fwave.name:= 'wave';
 fwave.setsubcompref;
end;

destructor twavetableedit.destroy;
begin
 fwave.free;
 inherited;
end;

procedure twavetableedit.setwave(const avalue: tsigwavetable);
begin
 fwave.assign(avalue);
end;

procedure twavetableedit.sample;

 function intpol(const ax: double): double;
 var
  int1,int2: integer;
  rea1: real;
 begin
  int2:= -1;
  for int1:= 0 to high(fvalue) do begin
   if fvalue[int1].re >= ax then begin
    int2:= int1;
    break;
   end;
  end;
  if int2 < 0 then begin
   result:= fvalue[high(fvalue)].im;
  end
  else begin
   result:= fvalue[int2].im;
   if int2 > 0 then begin
    rea1:= fvalue[int2].re-fvalue[int2-1].re;
    if rea1 = 0 then begin
     rea1:= 0.5;
    end
    else begin
     rea1:= (ax-fvalue[int2-1].re)/rea1;
    end;
    result:= result + (fvalue[int2-1].im - result) * rea1;
   end;
  end;
 end; //intpol
 
var
 ar1: doublearty;
 int1: integer;
 rea1: real;
begin
 setlength(ar1,fsamplecount);
 if (fsamplecount >= 0) and (high(fvalue) >= 0) then begin
  rea1:= 1/fsamplecount;
  for int1:= 0 to fsamplecount - 1 do begin
   ar1[int1]:= intpol(rea1*int1);
  end;
 end;
 fwave.table:= ar1;
end;

procedure twavetableedit.dochange;
begin
 sample;
 inherited;
end;

procedure twavetableedit.setsamplecount(const avalue: integer);
begin
 if avalue <> fsamplecount then begin
  fsamplecount:= avalue;
  sample;
 end;
end;

{ twavetrace }

constructor twavetrace.create(aowner: tobject);
begin
 inherited;
end;

procedure twavetrace.setoptions(const avalue: charttraceoptionsty);
begin
 inherited setoptions(avalue + [cto_xordered]);
end;

procedure twavetrace.setkind(const avalue: tracekindty);
begin
 inherited setkind(trk_xy);
end;

{ twavetraces }

constructor twavetraces.create(const aowner: tcustomchart);
begin
 inherited;
 kind:= trk_xy;
 options:= defaultwavetraceoptions;
end;

class function twavetraces.getitemclasstype: persistentclassty;
begin
 result:= twavetrace;
end;

procedure twavetraces.setoptions(const avalue: charttraceoptionsty);
begin
 inherited setoptions(avalue + [cto_xordered]);
end;

procedure twavetraces.setkind(const avalue: tracekindty);
begin
 inherited setkind(trk_xy);
end;

end.
