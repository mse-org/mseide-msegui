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
 msechart,mseclasses,msefft,msewidgets,msegraphics,msegraphutils,msedial,
 msesplitter,msegui,msestat,msestatfile,msestrings,msestockobjects;
 
const
 defaultffttableeditoptions = [ceo_noinsert,ceo_nodelete];
 defaultkeywidth = 8;
 defaultenvsplitteroptions = defaultsplitteroptions+[spo_hmove,spo_hprop];
 
type
 sigeditoptionty = (sieo_exp);
 sigeditoptionsty = set of sigeditoptionty;
 
 tsigslider = class(tslider,isigclient)
  private
   foutput: tdoubleoutputconn;
   fcontroller: tsigcontroller;
   fsigclientinfo: sigclientinfoty;
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
   procedure sigtick; virtual;
   function getinputar: inputconnarty;
   function getoutputar: outputconnarty;
   function gethandler: sighandlerprocty;
   function getzcount: integer;
   procedure clear;
   procedure modelchange;
   function getsigcontroller: tsigcontroller;
   function getsigclientinfopo: psigclientinfoty;
   function getsigoptions: sigclientoptionsty;
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

 tsigkeyboard = class(trealgraphdataedit,isigclient)
  private
   foutput: tdoubleoutputconn;
   fcontroller: tsigcontroller;
   fsigclientinfo: sigclientinfoty;
   fontransformvalue: sigineventty;
   fmin: real;
//   fmax: real;
   foptions: sigeditoptionsty;
   fkeywidth: integer;
   fkey: integer;
   flastkey: integer;
   fkeypressed: boolean;
   ftrigout: tdoubleoutputconn;
   procedure setoutput(const avalue: tdoubleoutputconn);
   procedure setcontroller(const avalue: tsigcontroller);
   procedure setmin(const avalue: real);
//   procedure setmax(const avalue: real);
   procedure setoptions(const avalue: sigeditoptionsty);
   procedure setkeywidth(const avalue: integer);
   procedure settrigout(const avalue: tdoubleoutputconn);
  protected
   fsigvalue: real;
   ftrigvalue: real;
   procedure updatesigvalue;
   procedure dochange; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                        const avalue; const arect: rectty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure doexit; override;

    //isigclient  
   procedure initmodel;
   procedure sigtick; virtual;
   function getinputar: inputconnarty;
   function getoutputar: outputconnarty;
   function gethandler: sighandlerprocty;
   function getzcount: integer;
   procedure clear;
   procedure modelchange;
   function getsigcontroller: tsigcontroller;
   function getsigclientinfopo: psigclientinfoty;
   function getsigoptions: sigclientoptionsty;
  public
   constructor create(aowner: tcomponent); override;
   property output: tdoubleoutputconn read foutput write setoutput;
   property trigout: tdoubleoutputconn read ftrigout write settrigout;
  published
   property keywidth: integer read fkeywidth write setkeywidth default defaultkeywidth;
   property controller: tsigcontroller read fcontroller write setcontroller;
   property ontransformvalue: sigineventty read fontransformvalue 
                                                 write fontransformvalue;
   property min: real read fmin write setmin;
//   property max: real read fmax write setmax;
   property options: sigeditoptionsty read foptions write setoptions default [];
 end;
 
 twavetableedit = class(torderedxychartedit)
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

 optionfuncteditty = (ofe_symmetric,ofe_mirrored);
 optionsfuncteditty = set of optionfuncteditty;
 
 tfuncttableedit = class(torderedxychartedit)
  private
   ffunct: tsigfuncttable;
   foptionsfunct: optionsfuncteditty;
   procedure setfunct(const avalue: tsigfuncttable);
   procedure setoptionsfunct(const avalue: optionsfuncteditty);
  protected
   procedure dochange; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property funct: tsigfuncttable read ffunct write setfunct;
   property optionsfunct: optionsfuncteditty read foptionsfunct 
                                            write setoptionsfunct default [];
 end;
 
 ffteditoptionty = (feo_exp);
 ffteditoptionsty = set of ffteditoptionty;
const
 defaultffteditoptions = [feo_exp];
 
type  
 tffttableedit = class(txserieschartedit)
  private
   fwave: tsigwavetable;
   fsamplecount: integer;
   ffft: tfft;
   ffft_harmonicscount: integer;
   ffft_options: ffteditoptionsty;
   ffft_expmin: real;
   ffft_max: real;
   procedure setwave(const avalue: tsigwavetable);
   procedure setsamplecount(const avalue: integer);
   procedure setfft_harmonicscount(const avalue: integer);
   procedure setfft_options(const avalue: ffteditoptionsty);
   procedure setfft_expmin(const avalue: real);
   procedure setfft_max(const avalue: real);
  protected
   procedure sample;
   procedure dochange; override;
   procedure doclear; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property samplecount: integer read fsamplecount 
                                write setsamplecount default defaultsamplecount;
   property fft_harmonicscount: integer read ffft_harmonicscount 
                      write setfft_harmonicscount default defaultharmonicscount;
   property fft_options: ffteditoptionsty read ffft_options 
               write setfft_options default defaultffteditoptions;
   property fft_expmin: real read ffft_expmin write setfft_expmin;
   property fft_max: real read ffft_max write setfft_max;
   property wave: tsigwavetable read fwave write setwave;
   property options default defaultffttableeditoptions;
 end;
 
 tenvelopeedit = class;
 
 tenvelopechartedit = class(tcustomorderedxychartedit)
  protected
   fenvelope: tenvelopeedit;
   procedure dochange; override;
   procedure domarkerchange; override;
   procedure drawcrosshaircursor(const canvas: tcanvas;
                                         const center: pointty); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property traces;
   property colorchart;
   property xstart;
   property ystart;
   property xrange;
   property yrange;
   property xdials;
   property ydials;
//   property statfile;
//   property statvarname;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property ondataentered;
   property onsetvalue;
   property activetrace;
   property optionsedit;
   property snapdist;
   property options;
   property onchange;
 end;
 
 tenvelopesplitter = class(tcustomsplitter)
  public
   constructor create(aowner: tcomponent); override;
  published
   property options default defaultenvsplitteroptions;
   property shrinkpriority;
//   property linkleft;
//   property linktop;
//   property linkright;
//   property linkbottom;

   property grip;
   property colorgrip;
//   property statfile;
//   property statvarname;
   property onupdatelayout;
 end;
 
 tenvelopeedit = class(tpublishedwidget,istatfile)
  private
   fstatvarname: msestring;
   fstatfile: tstatfile;
   fedtrig: tenvelopechartedit;
   fedaftertrig: tenvelopechartedit;
   fsplitter: tenvelopesplitter;
//   finnerframebefore: framety;
   fenvelope: tsigenvelope;
   fupdating: integer;
   procedure setenvelope(const avalue: tsigenvelope);
   procedure setedtrig(const avalue: tenvelopechartedit);
   procedure setedaftertrig(const avalue: tenvelopechartedit);
   procedure setsplitter(const avalue: tenvelopesplitter);
   procedure setstatfile(const avalue: tstatfile);
    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading; virtual;
   procedure statread; virtual;
   function getstatvarname: msestring;
  protected
   procedure updatelayout;
   procedure clientrectchanged; override;
   procedure dochange;
   procedure updatevalues;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginupdate;
   procedure endupdate;
  published
   property edtrig: tenvelopechartedit read fedtrig write setedtrig;
   property edaftertrig: tenvelopechartedit read fedaftertrig 
                                                         write setedaftertrig;
   property splitter: tenvelopesplitter read fsplitter write setsplitter;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property envelope: tsigenvelope read fenvelope write setenvelope;
   property optionswidget default defaultoptionswidgetmousewheel;
 end;
(*  
 tenvelopeedit1 = class(torderedxychartedit)
  private
   fenvelope: tsigenvelope;
   procedure setenvelope(const avalue: tsigenvelope);
  protected
   procedure updatevalues;
   procedure dochange; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property envelope: tsigenvelope read fenvelope write setenvelope;
 end;
*)
 tsigscope = class;
 tscopesampler = class(tsigsampler)
  private
   fscope: tsigscope;
  protected
   procedure dobufferfull; override;
  public
   constructor create(const aowner: tsigscope); reintroduce;
 end;
 
 tsigscope = class(tchart)
  private
   fsampler: tscopesampler;
   procedure setsampler(const avalue: tscopesampler);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property sampler: tscopesampler read fsampler write setsampler;
 end;
 
const
 semitoneln = ln(2)/12;
 chromaticscale: array[0..12] of double =
    (1.0,exp(1*semitoneln),exp(2*semitoneln),exp(3*semitoneln),exp(4*semitoneln),
     exp(5*semitoneln),exp(6*semitoneln),exp(7*semitoneln),exp(8*semitoneln),
     exp(9*semitoneln),exp(10*semitoneln),exp(11*semitoneln),2.0);

implementation
uses
 math,msekeyboard,msebits;
type
 tsigcontroller1 = class(tsigcontroller);
 
{ tsigslider }

constructor tsigslider.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self,isigclient(self),true);
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
 if (sieo_exp in foptions) and (fmin > 0) and (fmax > 0) then begin
  do1:= fmin*exp(fvalue*(ln(fmax)-ln(fmin)));
 end
 else begin
  do1:= fvalue*(fmax-fmin)+fmin; 
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
  tsigcontroller1(fcontroller).execevent(isigclient(self));
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

function tsigslider.getsigclientinfopo: psigclientinfoty;
begin
 result:= @fsigclientinfo;
end;

procedure tsigslider.sigtick;
begin
 //dummy
end;

function tsigslider.getsigoptions: sigclientoptionsty;
begin
 result:= [];
end;

{ tsigkeyboard }

constructor tsigkeyboard.create(aowner: tcomponent);
begin
 fkey:= -1;
 ftrigout:= tdoubleoutputconn.create(self,isigclient(self),true);
 ftrigout.name:= 'trigout';
 foutput:= tdoubleoutputconn.create(self,isigclient(self),true);
 fmin:= 0.001;
// fmax:= 1;
 fkeywidth:= defaultkeywidth;
 inherited;
end;

procedure tsigkeyboard.setcontroller(const avalue: tsigcontroller);
begin
 setsigcontroller(getobjectlinker,isigclient(self),avalue,fcontroller);
end;

procedure tsigkeyboard.initmodel;
begin
 //dummy
end;

function tsigkeyboard.getinputar: inputconnarty;
begin
 result:= nil;
end;

function tsigkeyboard.getoutputar: outputconnarty;
begin
 setlength(result,2);
 result[0]:= foutput;
 result[1]:= ftrigout;
end;

function tsigkeyboard.getzcount: integer;
begin
 result:= 0;
end;

procedure tsigkeyboard.clear;
begin
 //dummy
end;

procedure tsigkeyboard.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

procedure tsigkeyboard.settrigout(const avalue: tdoubleoutputconn);
begin
 ftrigout.assign(avalue);
end;

procedure tsigkeyboard.modelchange;
begin
 //dummy
end;

function tsigkeyboard.getsigcontroller: tsigcontroller;
begin
 result:= fcontroller;
end;

procedure tsigkeyboard.updatesigvalue;
var
 do1: double;
begin
 if fkey < 0 then begin
  do1:= fsigvalue;
 end
 else begin  
  if (sieo_exp in foptions) then begin
   do1:= intpower(2.0,fkey div 12) * chromaticscale[fkey mod 12] * fmin;
  end
  else begin
   do1:= fkey/12.0 + fmin;
  end;
 end;
 if canevent(tmethod(fontransformvalue)) then begin
  fontransformvalue(self,real(do1));
 end;
 if fcontroller <> nil then begin
  fcontroller.lock;
 end;
 fsigvalue:= do1;
 if fkey < 0 then begin
  ftrigvalue:= 0;
 end
 else begin
  ftrigvalue:= 1;
 end;
 if fcontroller <> nil then begin
  fcontroller.unlock;
  tsigcontroller1(fcontroller).execevent(isigclient(self));
 end;
end;

procedure tsigkeyboard.dochange;
begin
 inherited;
 updatesigvalue; 
end;

procedure tsigkeyboard.sighandler(const ainfo: psighandlerinfoty);
begin
 ainfo^.dest^:= fsigvalue;
 ftrigout.value:= ftrigvalue;
end;

function tsigkeyboard.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigkeyboard.setmin(const avalue: real);
begin
 fmin:= avalue;
 updatesigvalue;
end;
{
procedure tsigkeyboard.setmax(const avalue: real);
begin
 fmax:= avalue;
 updatesigvalue;
end;
}
procedure tsigkeyboard.setoptions(const avalue: sigeditoptionsty);
begin
 if options <> avalue then begin
  foptions:= avalue;
  updatesigvalue;
 end;
end;

function tsigkeyboard.getsigclientinfopo: psigclientinfoty;
begin
 result:= @fsigclientinfo;
end;

procedure tsigkeyboard.paintglyph(const canvas: tcanvas;
               const acolorglyph: colorty; const avalue; const arect: rectty);
var
 pt1: pointty;
 ar1: segmentarty;
 int1,int2,int3,int4: integer;
 rect1: rectty;
begin
 setlength(ar1,arect.cx div fkeywidth + 1);
 int2:= arect.y + arect.cy;
 int3:= arect.x;
 for int1:= 0 to high(ar1) do begin
  with(ar1[int1]) do begin
   a.x:= int3;
   a.y:= arect.y;
   b.x:= int3;
   b.y:= int2;
  end;
  inc(int3,fkeywidth);
 end;
 canvas.drawlinesegments(ar1,colorglyph);
 int4:= (fkeywidth*2+1) div 3 + 1; //width of black keys
 rect1.x:= arect.x + (fkeywidth - int4 div 2);
 rect1.y:= arect.y;
 rect1.cx:= int4+1;
 rect1.cy:= arect.cy div 2;
 for int1:= 0 to high(ar1) do begin
  int3:= int1 mod 7;
  if (int3 <> 2) and (int3 <> 6) then begin
   canvas.fillrect(rect1,colorglyph);
  end;
  inc(rect1.x,fkeywidth);
 end;
end;

procedure tsigkeyboard.setkeywidth(const avalue: integer);
begin
 if avalue <> fkeywidth then begin
  fkeywidth:= avalue;
  if fkeywidth < 4 then begin
   fkeywidth:= 4;
  end;
  invalidate;
 end;
end;

const
 whitekeys: array[0..6] of integer = (0,2,4,5,7,9,11);
 blackkeys: array[0..6] of integer = (-1,1,3,-1,6,8,10);

procedure tsigkeyboard.clientmouseevent(var info: mouseeventinfoty);
var
 keybefore: integer;
 keynumber,key: integer;
 rect1: rectty;
begin
 keybefore:= fkey;
 if not (csdesigning in componentstate) and 
                        (info.eventkind in mouseposevents) then begin
  if (ss_left in info.shiftstate) or fkeypressed then begin
   rect1:= innerclientrect;
   if pointinrect(info.pos,rect1) then begin
    if info.pos.y >= rect1.y + rect1.cy div 2 then begin //white keys
     keynumber:= (info.pos.x - rect1.x) div fkeywidth;
     key:= whitekeys[keynumber mod 7];
    end
    else begin
     keynumber:= (info.pos.x - rect1.x + fkeywidth div 2) div fkeywidth;
     key:= blackkeys[keynumber mod 7];
     if key < 0 then begin
      keynumber:= (info.pos.x - rect1.x) div fkeywidth;
      key:= whitekeys[keynumber mod 7];
     end;
    end;
    fkey:= (keynumber div 7)*12+key;
    flastkey:= fkey;
   end
   else begin
    if not fkeypressed then begin
     fkey:= -1;
    end;
   end;
  end
  else begin
   if not fkeypressed then begin
    fkey:= -1;
   end;
  end;
 end
 else begin
  if not fkeypressed and 
           (info.eventkind in [ek_mouseleave,ek_clientmouseleave]) then begin
   fkey:= -1;
  end;
 end;
 if keybefore <> fkey then begin
  include(info.eventstate,es_processed);
  updatesigvalue;
 end
 else begin
  inherited;
 end;
end;

procedure tsigkeyboard.dokeydown(var info: keyeventinfoty);
begin
 if (info.key = key_space) and not (ss_repeat in info.shiftstate) and
                                             (flastkey <> fkey) then begin
  fkey:= flastkey;
  include(info.eventstate,es_processed);
  fkeypressed:= true;
  updatesigvalue;
 end
 else begin
  inherited;
 end;
end;

procedure tsigkeyboard.dokeyup(var info: keyeventinfoty);
begin
 if (info.key = key_space) and 
           not (ss_repeat in info.shiftstate) and (fkey >= 0) then begin
  fkey:= -1;
  include(info.eventstate,es_processed);
  updatesigvalue;
  fkeypressed:= false;
 end
 else begin
  inherited;
 end; 
end;

procedure tsigkeyboard.doexit;
begin
 fkeypressed:= false;
 inherited;
end;

procedure tsigkeyboard.sigtick;
begin
 //dummy
end;

function tsigkeyboard.getsigoptions: sigclientoptionsty;
begin
 result:= [];
end;

{ twavetableedit }

constructor twavetableedit.create(aowner: tcomponent);
begin
 fsamplecount:= defaultsamplecount;
 inherited;
 fwave:= tsigwavetable.create(self);
 fwave.name:= 'wave';
 fwave.setsubcomponent(true);
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

{ tfuncttableedit }

constructor tfuncttableedit.create(aowner: tcomponent);
begin
 inherited;
 ffunct:= tsigfuncttable.create(self);
 ffunct.name:= 'funct';
 ffunct.setsubcomponent(true);
end;

destructor tfuncttableedit.destroy;
begin
 ffunct.free;
 inherited;
end;

procedure tfuncttableedit.setfunct(const avalue: tsigfuncttable);
begin
 ffunct.assign(avalue);
end;

procedure tfuncttableedit.dochange;
var
 ar1: complexarty;
 int1,int2: integer;
begin
 if ofe_symmetric in foptionsfunct then begin
  int2:= length(fvalue);
  setlength(ar1,int2*2);
  for int1:= 0 to high(fvalue) do begin
   ar1[int2+int1]:= fvalue[int1];
   with ar1[int2-int1-1] do begin
    re:= -fvalue[int1].re;
    im:= -fvalue[int1].im;
   end;
  end;
  ffunct.table:= ar1;
 end
 else begin
  if ofe_mirrored in foptionsfunct then begin
   int2:= length(fvalue);
   setlength(ar1,int2*2);
   for int1:= 0 to high(fvalue) do begin
    ar1[int2+int1]:= fvalue[int1];
    with ar1[int2-int1-1] do begin
     re:= -fvalue[int1].re;
     im:= fvalue[int1].im;
    end;
   end;
   ffunct.table:= ar1;
  end
  else begin
   ffunct.table:= fvalue;
  end;
 end;
 inherited;
end;

procedure tfuncttableedit.setoptionsfunct(const avalue: optionsfuncteditty);
const
 mask: optionsfuncteditty = [ofe_symmetric,ofe_mirrored];
begin
 if foptionsfunct <> avalue then begin
  foptionsfunct:=
   optionsfuncteditty(setsinglebit(longword(avalue),
                               longword(foptionsfunct),
                               longword(mask)));
  if not (csloading in componentstate) then begin
   dochange;
  end;
 end;
end;

{ tffttableedit }

constructor tffttableedit.create(aowner: tcomponent);
begin
 fsamplecount:= defaultsamplecount;
 ffft_options:= defaultffteditoptions;
 ffft_expmin:= 0.001; //-60dB
 ffft_max:= 1;
 inherited;
 ffft:= tfft.create(nil);
 fwave:= tsigwavetable.create(self);
 fwave.name:= 'wave';
 fwave.setsubcomponent(true);
 fft_harmonicscount:= defaultharmonicscount;
 options:= defaultffttableeditoptions;
end;

destructor tffttableedit.destroy;
begin
 fwave.free;
 ffft.free;
 inherited;
end;

procedure tffttableedit.setwave(const avalue: tsigwavetable);
begin
 fwave.assign(avalue);
end;

procedure tffttableedit.sample;
const
 scale1 = 1/2;
var
 ar1: complexarty; 
 int1,int2: integer;
 rea1,rea2,rea3: real;
begin
 setlength(ar1,fsamplecount div 2 + 1);
 int2:= high(fvalue);
 if int2 >= high(ar1) then begin
  int2:= high(ar1)-1;
 end;
 rea3:= ffft_max*scale1;
 if (feo_exp in ffft_options) and (ffft_expmin > 0) and (ffft_max > 0) then begin
  rea1:= ln(ffft_max) - ln(ffft_expmin);
  for int1:= 0 to int2 do begin
   rea2:= fvalue[int1];
   if rea2 > 0 then begin
    ar1[int1+1].im:= exp((rea2-1)*rea1)*rea3;
   end;
  end;  
 end
 else begin
  for int1:= 1 to int2 do begin
   ar1[int1].im:= fvalue[int1-1]*rea3;
  end;
 end;
 ffft.inpcomplex:= ar1;
 fwave.table:= doublearty(ffft.outreal);
end;

procedure tffttableedit.dochange;
begin
 sample;
 inherited;
end;

procedure tffttableedit.setsamplecount(const avalue: integer);
begin
 if avalue <> fsamplecount then begin
  fsamplecount:= avalue;
  sample;
 end;
end;

procedure tffttableedit.setfft_harmonicscount(const avalue: integer);
begin
 ffft_harmonicscount:= avalue;
 setlength(fvalue,avalue);
 change;
end;

procedure tffttableedit.doclear;
begin
 fvalue:= nil;
 setlength(fvalue,ffft_harmonicscount);
end;

procedure tffttableedit.setfft_options(const avalue: ffteditoptionsty);
begin
 if ffft_options <> avalue then begin
  ffft_options:= avalue;
  change;
 end;
end;

procedure tffttableedit.setfft_expmin(const avalue: real);
begin
 if avalue <> ffft_expmin then begin
  ffft_expmin:= avalue;
  change;
 end;
end;

procedure tffttableedit.setfft_max(const avalue: real);
begin
 if avalue <> ffft_max then begin
  ffft_max:= avalue;
  change;
 end;
end;

{ tenvelopeedit1 }
(*
constructor tenvelopeedit1.create(aowner: tcomponent);
begin
 inherited;
 xdials.count:= 1;
 with xdials[0] do begin
  markers.count:= 2;
  with markers[0] do begin  //loop start
   value:= 0;
   color:= cl_red;
   options:= [dmo_ordered,dmo_savevalue];
  end;
  with markers[1] do begin  //decay
   value:= 1;
   color:= cl_green;
   options:= [dmo_ordered,dmo_savevalue];
  end;
 end;
 fenvelope:= tsigenvelope.create(self);
 fenvelope.name:= 'envelope';
 fenvelope.setsubcomponent(true);
end;

destructor tenvelopeedit1.destroy;
begin
 fenvelope.free;
 inherited;
end;

procedure tenvelopeedit1.setenvelope(const avalue: tsigenvelope);
begin
 fenvelope.assign(avalue);
end;

procedure tenvelopeedit1.dochange;
begin
 inherited;
 updatevalues;
end;

procedure tenvelopeedit1.updatevalues;
begin
 with fenvelope do begin
  beginupdate;
  values:= activetraceitem.xydata;
  if xdials.count > 0 then begin
   with xdials[0] do begin
    if markers.count > 0 then begin
     loopstart:= markers[0].value;
    end
    else begin
     loopstart:= 0;
    end;
    if markers.count > 1 then begin
     decaystart:= markers[1].value;
    end
    else begin
     decaystart:= 1;
    end
   end;
  end;    
  endupdate;
 end;
end;
*)
{ tenvelopeedit }

constructor tenvelopeedit.create(aowner: tcomponent);
const
 splitterwidth = 4;
var
 int1: integer;
begin
 include(fwidgetstate1,ws1_noframewidgetshift);
 inherited;
 optionswidget:= defaultoptionswidgetmousewheel;
 fenvelope:= tsigenvelope.create(self);
 fenvelope.setsubcomponent(true);
 fenvelope.name:= 'envelope';
 fedtrig:= tenvelopechartedit.create(self,self,false);
 fedaftertrig:= tenvelopechartedit.create(self,self,false);
 fsplitter:= tenvelopesplitter.create(self,self,false);
 int1:= (fwidgetrect.cx - splitterwidth) div 2;
 fedtrig.bounds_cx:= int1;
 fedaftertrig.bounds_cx:= int1;
 fsplitter.bounds_cx:= splitterwidth;
 fsplitter.bounds_x:= fedtrig.bounds_x + fedtrig.bounds_cx;
 updatelayout;
 fsplitter.linkleft:= fedtrig;
 fsplitter.linkright:= fedaftertrig;
 with fedtrig do begin
  xdials.count:= 1;
  xdials[0].markers.count:= 1;
  with xdials[0].markers[0] do begin
   value:= 1;
   color:= cl_red;
   options:= [dmo_savevalue];
  end;
 end;
end;

destructor tenvelopeedit.destroy;
begin
 fedtrig.free;
 fedaftertrig.free;
 fsplitter.free;
 fenvelope.free;
 inherited;
end;

procedure tenvelopeedit.setedtrig(const avalue: tenvelopechartedit);
begin
 fedtrig.assign(avalue);
end;

procedure tenvelopeedit.setedaftertrig(const avalue: tenvelopechartedit);
begin
 fedaftertrig.assign(avalue);
end;

procedure tenvelopeedit.setsplitter(const avalue: tenvelopesplitter);
begin
 fsplitter.assign(avalue);
end;

procedure tenvelopeedit.updatelayout;
var
 rect1: rectty;
 rect2: rectty;
 fr1,fr2: framety;
begin
 rect1:= innerwidgetrect;
 with rect1 do begin
  rect2.pos:= pos;
  rect2.cy:= cy;
  rect2.cx:= fedtrig.bounds_cx - x + fedtrig.bounds_x;
  fedtrig.widgetrect:= rect2;
  rect2.x:= fsplitter.bounds_x;
  rect2.cx:= fsplitter.bounds_cx;
  fsplitter.widgetrect:= rect2;
  rect2.x:= fedaftertrig.bounds_x;
  rect2.cx:= cx - rect2.x; 
  fedaftertrig.widgetrect:= rect2;
 end;
end;

procedure tenvelopeedit.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure tenvelopeedit.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tenvelopeedit.dostatread(const reader: tstatreader);
var
 mstr1: msestring;
begin
 mstr1:= reader.varname(istatfile(self));
 beginupdate;
 try
  if reader.findsection(mstr1+'.0') then begin
   fedtrig.dostatread(reader);  
  end;
  if reader.findsection(mstr1+'.1') then begin
   fedaftertrig.dostatread(reader);  
  end;
  if reader.findsection(mstr1+'.2') then begin
   fsplitter.dostatread(reader);  
  end;
 finally
  endupdate;
 end; 
end;

procedure tenvelopeedit.dostatwrite(const writer: tstatwriter);
var
 mstr1: msestring;
begin
 mstr1:= writer.varname(istatfile(self));
 writer.writesection(mstr1+'.0');
 fedtrig.dostatwrite(writer);  
 writer.writesection(mstr1+'.1');
 fedaftertrig.dostatwrite(writer);  
 writer.writesection(mstr1+'.2');
 fsplitter.dostatwrite(writer);  
end;

procedure tenvelopeedit.statreading;
begin
 fedtrig.statreading;
 fedaftertrig.statreading;
 fsplitter.statreading;
end;

procedure tenvelopeedit.statread;
begin
 fedtrig.statread;
 fedaftertrig.statread;
 fsplitter.statread;
end;

function tenvelopeedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tenvelopeedit.updatevalues;
begin
 with fenvelope do begin
  beginupdate;
  with fedtrig do begin
   valuestrig:= activetraceitem.xydata;
   if xdials.count > 0 then begin
    with xdials[0] do begin
     if markers.count > 0 then begin
      loopstart:= markers[0].value;
     end
     else begin
      loopstart:= 1;
     end;
     {
     if markers.count > 1 then begin
      decaystart:= markers[1].value;
     end
     else begin
      decaystart:= 1;
     end
     }
    end;
   end;    
  end;
  with fedaftertrig do begin
   valuesaftertrig:= activetraceitem.xydata;
  end;
  endupdate;
 end;
end;

procedure tenvelopeedit.dochange;
begin
 if fupdating >= 0 then begin
  updatevalues;
 end;
end;

procedure tenvelopeedit.setenvelope(const avalue: tsigenvelope);
begin
 fenvelope.assign(avalue);
end;

procedure tenvelopeedit.beginupdate;
begin
 inc(fupdating);
end;

procedure tenvelopeedit.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  dochange;
 end;
end;

{ tenvelopechartedit }

constructor tenvelopechartedit.create(aowner: tcomponent);
begin
 fenvelope:= tenvelopeedit(aowner);
 if csdesigning in aowner.componentstate then begin
  setdesigning(true);
 end;
 inherited create(nil);
 setsubcomponent(true);
 traces.count:= 1;
 traces.options:= traces.options + [cto_stockglyphs];
// traces.image_list:= stockobjects.glyphs;
 traces[0].imagenr:= ord(stg_circlesmall);
 with frame do begin
  optionsscroll:= optionsscroll + [oscr_zoom,oscr_drag,oscr_mousewheel];
  zoomwidthstep:= 1.5;
 end;
end;

procedure tenvelopechartedit.dochange;
begin
 inherited;
 fenvelope.dochange;
end;

procedure tenvelopechartedit.domarkerchange;
begin
 inherited;
 fenvelope.dochange;
end;

procedure tenvelopechartedit.drawcrosshaircursor(const canvas: tcanvas;
               const center: pointty);
begin
 inherited;
 canvas.save;
 canvas.clipregion:= 0;
 if self = fenvelope.fedtrig then begin
  canvas.drawvect(makepoint(
   fenvelope.fedaftertrig.paintparentpos.x-paintparentpos.x,
                                                     center.y),gd_right,
                                         fenvelope.fedaftertrig.paintsize.cx);
 end
 else begin
  canvas.drawvect(makepoint(
   fenvelope.fedtrig.paintparentpos.x-paintparentpos.x,
                                                     center.y),gd_right,
                                         fenvelope.fedtrig.paintsize.cx);
 end;
 canvas.restore;
end;

{ tenvelopesplitter }

constructor tenvelopesplitter.create(aowner: tcomponent);
begin
 if csdesigning in aowner.componentstate then begin
  setdesigning(true);
 end;
 inherited; //owner needed because of csreading and csloading
// inherited create(nil);
 options:= defaultenvsplitteroptions;
 setsubcomponent(true);
end;

{ tscopesampler }

constructor tscopesampler.create(const aowner: tsigscope);
begin
 fscope:= aowner;
 inherited create(aowner);
 setsubcomponent(true);
 name:= 'sampler';
end;

procedure tscopesampler.dobufferfull;
var
 buf1: samplerbufferty;
 int1: integer;
begin
 inherited;
 buf1:= copy(fsigbuffer);
 lockapplication;
 try
  with fscope.traces do begin
   for int1:= 0 to high(buf1) do begin
    if int1 >= count then begin
     break;
    end;
    items[int1].ydata:= buf1[int1];
   end;
  end;
 finally
  unlockapplication;
 end;
end;

{ tsigscope }

constructor tsigscope.create(aowner: tcomponent);
begin
 fsampler:= tscopesampler.create(self);
 inherited;
end;

destructor tsigscope.destroy;
begin
 fsampler.free;
 inherited;
end;

procedure tsigscope.setsampler(const avalue: tscopesampler);
begin
 fsampler.assign(avalue);
end;

end.
