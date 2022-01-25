{ MSEgui Copyright (c) 2011-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesiggui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 classes,mclasses,msegraphedits,msesignal,mseguiglob,mseevent,msechartedit,
 msetypes,
 msechart,mseclasses,msefft,msewidgets,msegraphics,msegraphutils,msedial,
 msesplitter,msegui,msestat,msestatfile,msestrings,
 {$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msemenus,mseact,msedataedits,msereal,mseedit;

type
 sigeditoptionty = (sieo_exp,sieo_expzero);
 sigeditoptionsty = set of sigeditoptionty;

const
 defaultffttableeditoptions = [ceo_noinsert,ceo_nodelete];
 defaultkeywidth = 8;
 defaultenvsplitteroptions = defaultsplitteroptions+[spo_hmove,spo_hprop];
 defaultsigkeyboardoptions = [sieo_exp];

type

 tsigslider = class(tslider,isigclient)
  private
   foutput: tdoubleoutputconn;
   foutputpo: pdouble;
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
   procedure lock;
   procedure unlock;
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

 tsigrealedit = class(trealedit,isigclient)
  private
   foutput: tdoubleoutputconn;
   foutputpo: pdouble;
   fcontroller: tsigcontroller;
   fontransformvalue: sigineventty;
   foptions: sigeditoptionsty;
   fsigclientinfo: sigclientinfoty;
//   foffset: real;
   procedure setoutput(const avalue: tdoubleoutputconn);
   procedure setcontroller(const avalue: tsigcontroller);
   procedure setoptions(const avalue: sigeditoptionsty);
//   procedure setoffset(const avalue: real);
  protected
   fsigvalue: real;
   foutmin: real;
   foutmax: real;
   procedure setoutmin(const avalue: real);
   procedure setoutmax(const avalue: real);
   procedure setvaluemin(const avalue: realty); override;
   procedure setvaluemax(const avalue: realty); override;

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
   procedure lock;
   procedure unlock;
  public
   constructor create(aowner: tcomponent); override;
   property output: tdoubleoutputconn read foutput write setoutput;
  published
   property controller: tsigcontroller read fcontroller write setcontroller;
   property ontransformvalue: sigineventty read fontransformvalue
                                                 write fontransformvalue;
//   property offset: real read foffset write setoffset;
   property outmin: real read foutmin write setoutmin;
   property outmax: real read foutmax write setoutmax;
   property options: sigeditoptionsty read foptions write setoptions default [];
 end;

 sigkeyinfoty = record
  sigvalue: double;
  eventvalue: double;
  key: integer;
  pressed: boolean;
  timestamp: longword;
  outpo: pdouble;
  trigoutpo: pdouble;
 end;
 sigkeyinfoarty = array of sigkeyinfoty;

 tsigkeyboard = class(trealgraphdataedit,isigclient)
  private
   foutput: tdoubleoutconnarrayprop;
   ftrigout: tdoubleoutconnarrayprop;
   fcontroller: tsigcontroller;
   fsigclientinfo: sigclientinfoty;
   fontransformvalue: sigineventty;
   fmin: real;
   foptions: sigeditoptionsty;
   fkeywidth: integer;
   fkey: integer;
   flastkey: integer;
   fkeypressed: boolean;
   foutputcount: integer;
   foutputhigh: integer;
   procedure setoutput(const avalue: tdoubleoutconnarrayprop);
   procedure settrigout(const avalue: tdoubleoutconnarrayprop);
   procedure setcontroller(const avalue: tsigcontroller);
   procedure setmin(const avalue: real);
   procedure setoptions(const avalue: sigeditoptionsty);
   procedure setkeywidth(const avalue: integer);
   procedure setoutputcount(const avalue: integer);
  protected
   fdummy: double;
   fkeyinfos: sigkeyinfoarty;
   procedure updatesigvalue(const akey: integer; const apressed: boolean);
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
   procedure lock;
   procedure unlock;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property output: tdoubleoutconnarrayprop read foutput write setoutput;
   property trigout: tdoubleoutconnarrayprop read ftrigout write settrigout;
                     //1 -> key down, -1 key up, 0 none
  published
   property keywidth: integer read fkeywidth write setkeywidth default defaultkeywidth;
   property controller: tsigcontroller read fcontroller write setcontroller;
   property ontransformvalue: sigineventty read fontransformvalue
                                                 write fontransformvalue;
   property min: real read fmin write setmin;
//   property max: real read fmax write setmax;
   property options: sigeditoptionsty read foptions write setoptions
                                    default defaultsigkeyboardoptions;
   property outputcount: integer read foutputcount write setoutputcount default 1;
 end;

 optionwavetablety = (owt_rotate,owt_mirror,owt_nodc);
 optionswavetablety = set of optionwavetablety;

 twavetableedit = class(torderedxychartedit)
  private
   fwave: tsigwavetable;
   fsamplecount: integer;
   foptionswave: optionswavetablety;
   procedure setwave(const avalue: tsigwavetable);
   procedure setsamplecount(const avalue: integer);
   procedure setoptionswave(const avalue: optionswavetablety);
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
   property optionswave: optionswavetablety read foptionswave
                                            write setoptionswave default [];
 end;

 optionfuncteditty = (ofe_rotate,ofe_mirror);
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
   fattack: tenvelopechartedit;
   fdecay: tenvelopechartedit;
   frelease: tenvelopechartedit;
   fsplitter1: tenvelopesplitter;
   fsplitter2: tenvelopesplitter;
//   finnerframebefore: framety;
   fenvelope: tsigenvelope;
   fupdating: integer;
   factivetrace: integer;
   fmenustart: integer;
   fstatpriority: integer;
   procedure setenvelope(const avalue: tsigenvelope);
   procedure setattack(const avalue: tenvelopechartedit);
   procedure setdecay(const avalue: tenvelopechartedit);
   procedure setrelease(const avalue: tenvelopechartedit);
   procedure setsplitter1(const avalue: tenvelopesplitter);
   procedure setsplitter2(const avalue: tenvelopesplitter);
   procedure setstatfile(const avalue: tstatfile);
    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading; virtual;
   procedure statread; virtual;
   function getstatvarname: msestring;
   function getstatpriority: integer;
   procedure setactivetrace(avalue: integer);
  protected
   procedure updatelayout;
   procedure clientrectchanged; override;
   procedure dochange;
   procedure updatevalues;
   procedure updatepopupmenu(var amenu: tpopupmenu;
                                   var mouseinfo: mouseeventinfoty); override;
   procedure doafterpopupmenu(var amenu: tpopupmenu;
                                   var mouseinfo: mouseeventinfoty); override;

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginupdate;
   procedure endupdate;
  published
   property attack: tenvelopechartedit read fattack write setattack;
   property decay: tenvelopechartedit read fdecay write setdecay;
   property release: tenvelopechartedit read frelease write setrelease;
   property splitter1: tenvelopesplitter read fsplitter1 write setsplitter1;
   property splitter2: tenvelopesplitter read fsplitter2 write setsplitter2;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;
   property envelope: tsigenvelope read fenvelope write setenvelope;
   property optionswidget default defaultoptionswidgetmousewheel;
   property activetrace: integer read factivetrace
                                      write setactivetrace default 0;
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

implementation
uses
 math,msekeyboard,msebits,msesysutils;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tsigcontroller1 = class(tsigcontroller);
 tsigenvelope1 = class(tsigenvelope);
 tdoubleoutputconn1 = class(tdoubleoutputconn);

{ tsigrealedit }

constructor tsigrealedit.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self,isigclient(self),true);
 inherited;
 fvalue:= 0;
 fvaluedefault:= 0;
 fvaluemin:= -bigreal;
 foutmax:= 1;
end;

procedure tsigrealedit.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

procedure tsigrealedit.setcontroller(const avalue: tsigcontroller);
begin
 setsigcontroller(getobjectlinker,isigclient(self),avalue,fcontroller);
end;

procedure tsigrealedit.setoptions(const avalue: sigeditoptionsty);
begin
 if options <> avalue then begin
  foptions:= avalue;
  updatesigvalue;
 end;
end;

procedure tsigrealedit.initmodel;
begin
 foutputpo:= @foutput.value;
end;

function tsigrealedit.getinputar: inputconnarty;
begin
 result:= nil;
end;

function tsigrealedit.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

function tsigrealedit.getzcount: integer;
begin
 result:= 0;
end;

procedure tsigrealedit.clear;
begin
 //dummy
end;

procedure tsigrealedit.modelchange;
begin
 //dummy
end;

function tsigrealedit.getsigcontroller: tsigcontroller;
begin
 result:= fcontroller;
end;

procedure tsigrealedit.updatesigvalue;
var
 do1: double;
begin
 if componentstate * [csdesigning,csloading] = [] then begin
  if (sieo_exp in foptions) and (foutmin > 0) and (foutmax > 0) then begin
   if (sieo_expzero in foptions) and (fvalue <= 0) then begin
    do1:= 0;
   end
   else begin
    do1:= foutmin*exp(fvalue*(ln(foutmax)-ln(foutmin)));
   end;
  end
  else begin
   do1:= fvalue*(foutmax-foutmin)+foutmin;
  end;
  if canevent(tmethod(fontransformvalue)) then begin
   fontransformvalue(self,real(do1));
  end;
  lock;
  try
   fsigvalue:= do1;
   if fcontroller <> nil then begin
    tsigcontroller1(fcontroller).execevent(isigclient(self));
   end;
  finally
   unlock;
  end;
 end;
end;

procedure tsigrealedit.dochange;
begin
 inherited;
 updatesigvalue;
end;

procedure tsigrealedit.sighandler(const ainfo: psighandlerinfoty);
begin
 foutputpo^:= fsigvalue;
end;

function tsigrealedit.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigrealedit.setoutmin(const avalue: real);
begin
 foutmin:= avalue;
 updatesigvalue;
end;

procedure tsigrealedit.setoutmax(const avalue: real);
begin
 foutmax:= avalue;
 updatesigvalue;
end;

function tsigrealedit.getsigclientinfopo: psigclientinfoty;
begin
 result:= @fsigclientinfo;
end;

procedure tsigrealedit.sigtick;
begin
 //dummy
end;

function tsigrealedit.getsigoptions: sigclientoptionsty;
begin
 result:= [];
end;

procedure tsigrealedit.lock;
begin
 if fcontroller <> nil then begin
  fcontroller.lock;
 end;
end;

procedure tsigrealedit.unlock;
begin
 if fcontroller <> nil then begin
  fcontroller.unlock;
 end;
end;
{
procedure tsigrealedit.setoffset(const avalue: real);
begin
 foffset:= avalue;
 updatesigvalue;
end;
}
procedure tsigrealedit.setvaluemin(const avalue: realty);
begin
 inherited;
 updatesigvalue;
end;

procedure tsigrealedit.setvaluemax(const avalue: realty);
begin
 inherited;
 updatesigvalue;
end;

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
 foutputpo:= @tdoubleoutputconn1(foutput).fvalue;
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
 if componentstate * [csdesigning,csloading] = [] then begin
  if (sieo_exp in foptions) and (fmin > 0) and (fmax > 0) then begin
   if (sieo_expzero in foptions) and (fvalue <= 0) then begin
    do1:= 0;
   end
   else begin
    do1:= fmin*exp(fvalue*(ln(fmax)-ln(fmin)));
   end;
  end
  else begin
   do1:= fvalue*(fmax-fmin)+fmin;
  end;
  if canevent(tmethod(fontransformvalue)) then begin
   fontransformvalue(self,real(do1));
  end;
  lock;
  try
   fsigvalue:= do1;
   if fcontroller <> nil then begin
    tsigcontroller1(fcontroller).execevent(isigclient(self));
   end;
  finally
   unlock;
  end;
 end;
end;

procedure tsigslider.dochange;
begin
 inherited;
 updatesigvalue;
end;

procedure tsigslider.sighandler(const ainfo: psighandlerinfoty);
begin
 foutputpo^:= fsigvalue;
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

procedure tsigslider.lock;
begin
 if fcontroller <> nil then begin
  fcontroller.lock;
 end;
end;

procedure tsigslider.unlock;
begin
 if fcontroller <> nil then begin
  fcontroller.unlock;
 end;
end;

{ tsigkeyboard }

constructor tsigkeyboard.create(aowner: tcomponent);
begin
 foptions:= defaultsigkeyboardoptions;
 fkey:= -1;
 ftrigout:= tdoubleoutconnarrayprop.create(self,'trigout',isigclient(self),true);
// ftrigout.name:= 'trigout';
 foutput:= tdoubleoutconnarrayprop.create(self,'output',isigclient(self),true);
 fmin:= 0.001;
// fmax:= 1;
 fkeywidth:= defaultkeywidth;
 inherited;
 outputcount:= 1;
end;

destructor tsigkeyboard.destroy;
begin
 ftrigout.free;
 foutput.free;
 inherited;
end;

procedure tsigkeyboard.setcontroller(const avalue: tsigcontroller);
begin
 setsigcontroller(getobjectlinker,isigclient(self),avalue,fcontroller);
end;

procedure tsigkeyboard.initmodel;
var
 int1: integer;
 ti1: longword;
begin
 ti1:= timestamp;
 for int1:= 0 to foutputhigh do begin
  with fkeyinfos[int1] do begin
   timestamp:= ti1;
   eventvalue:= 0;
   sigvalue:= fmin;
   key:= -1;
   if int1 < output.count then begin
    outpo:= @tdoubleoutputconn1(output[int1]).fvalue;
   end
   else begin
    outpo:= @fdummy;
   end;
   if int1 < trigout.count then begin
    trigoutpo:= @tdoubleoutputconn1(trigout[int1]).fvalue;
   end
   else begin
    trigoutpo:= @fdummy;
   end;
  end;
 end;
end;

function tsigkeyboard.getinputar: inputconnarty;
begin
 result:= nil;
end;

function tsigkeyboard.getoutputar: outputconnarty;
var
 int1,int2: integer;
begin
 setlength(result,foutput.count+ftrigout.count);
 int2:= foutput.count;
 for int1:= 0 to int2-1 do begin
  result[int1]:= foutput[int1];
 end;
 for int1:= 0 to ftrigout.count - 1 do begin
  result[int1+int2]:= ftrigout[int1];
 end;
end;

function tsigkeyboard.getzcount: integer;
begin
 result:= 0;
end;

procedure tsigkeyboard.clear;
begin
 //dummy
end;

procedure tsigkeyboard.setoutput(const avalue: tdoubleoutconnarrayprop);
begin
 foutput.assign(avalue);
end;

procedure tsigkeyboard.settrigout(const avalue: tdoubleoutconnarrayprop);
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

procedure tsigkeyboard.updatesigvalue(const akey: integer;
                                               const apressed: boolean);
var
 do1,do2: double;
 int1,int2: integer;
 ind1,oldest: integer;
 ti1,ti2: longword;
begin
 if foutputcount > 0 then begin
  ind1:= -1;
  ti1:= timestamp;
  ti2:= 0;
  oldest:= 0;
  lock;
  try
   for int1:= 0 to foutputhigh do begin
    with fkeyinfos[int1] do begin
     int2:= ti1 - timestamp;
     if int2 > ti2 then begin
      ti2:= int2;
      oldest:= int1;
     end;
     if key = akey then begin
      ind1:= int1;
     end;
    end;
   end;
   if ind1 < 0 then begin
    ind1:= oldest;
   end;
   with fkeyinfos[ind1] do begin
    key:= akey;
    timestamp:= ti1;
    pressed:= apressed;
    if not apressed then begin
     do1:= sigvalue;
     do2:= -1;
    end
    else begin
     do2:= 1;
     if (sieo_exp in foptions) then begin
      do1:= intpower(2.0,key div 12) * chromaticscale[key mod 12] * fmin;
     end
     else begin
      do1:= fkey/12.0 + fmin;
     end;
    end;
    if canevent(tmethod(fontransformvalue)) then begin
     fontransformvalue(self,real(do1));
    end;
    sigvalue:= do1;
    eventvalue:= do2;
   end;
   if fcontroller <> nil then begin
    tsigcontroller1(fcontroller).execevent(isigclient(self));
   end;
  finally
   unlock;             //todo: single event for current output only
  end;
 end;
end;

procedure tsigkeyboard.dochange;
begin
 inherited;
 updatesigvalue(-1,false);
end;

procedure tsigkeyboard.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 if foutputcount > 0 then begin
//  ainfo^.dest^:= fkeyinfos[0].sigvalue;
  for int1:= 0 to foutputhigh do begin
   with fkeyinfos[int1] do begin
    outpo^:= sigvalue;
    trigoutpo^:= eventvalue;
    eventvalue:= 0;
   end;
  end;
 end;
end;

function tsigkeyboard.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigkeyboard.setmin(const avalue: real);
var
 int1: integer;
begin
 lock;
 fmin:= avalue;
 for int1:= 0 to foutputhigh do begin
  with fkeyinfos[int1] do begin
   if sigvalue < fmin then begin
    sigvalue:= fmin;
   end;
  end;
 end;
 updatesigvalue(-1,false);
 unlock;
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
  lock;
  foptions:= avalue;
  updatesigvalue(-1,false);
  unlock;
 end;
end;

function tsigkeyboard.getsigclientinfopo: psigclientinfoty;
begin
 result:= @fsigclientinfo;
end;

procedure tsigkeyboard.paintglyph(const canvas: tcanvas;
               const acolorglyph: colorty; const avalue; const arect: rectty);
var
// pt1: pointty;
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
  if fkey = -1 then begin
   updatesigvalue(keybefore,false);
  end
  else begin
   if keybefore >= 0 then begin
    updatesigvalue(keybefore,false);
   end;
   updatesigvalue(fkey,true);
  end;
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
  updatesigvalue(fkey,true);
 end
 else begin
  inherited;
 end;
end;

procedure tsigkeyboard.dokeyup(var info: keyeventinfoty);
begin
 if (info.key = key_space) and
           not (ss_repeat in info.shiftstate) and (fkey >= 0) then begin
  include(info.eventstate,es_processed);
  updatesigvalue(fkey,false);
  fkey:= -1;
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

procedure tsigkeyboard.setoutputcount(const avalue: integer);
begin
 foutputcount:= avalue;
 foutputhigh:= avalue-1;
 output.count:= avalue;
 trigout.count:= avalue;
 setlength(fkeyinfos,avalue);
end;

procedure tsigkeyboard.lock;
begin
 if fcontroller <> nil then begin
  fcontroller.lock;
 end;
end;

procedure tsigkeyboard.unlock;
begin
 if fcontroller <> nil then begin
  fcontroller.unlock;
 end;
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
     rea1:= (fvalue[int2].re-ax)/rea1;
    end;
    result:= result + (fvalue[int2-1].im - result) * rea1;
   end;
  end;
 end; //intpol

var
 ar1: doublearty;
 int1,int2,int3: integer;
 sampco,start: integer;
 do1: double;
begin
 if foptionswave * [owt_rotate,owt_mirror] = [] then begin
  sampco:= fsamplecount;
  start:= 0;
 end
 else begin
  sampco:= (fsamplecount+1) div 2;
  start:= fsamplecount div 2;
 end;
 setlength(ar1,fsamplecount);
 if (sampco > 0) and (high(fvalue) >= 0) then begin
  do1:= 1/sampco;
  for int1:= 0 to sampco - 1 do begin
   ar1[int1+start]:= intpol(do1*int1);
  end;
 end;
 int2:= fsamplecount and 1; //odd
 int3:= start+start+int2-1;
 if owt_rotate in foptionswave then begin
  for int1:= start+int2 to int3 do begin
   ar1[int3-int1]:= - ar1[int1];
  end;
 end
 else begin
  if owt_mirror in foptionswave then begin
   for int1:= start+int2 to int3 do begin
    ar1[int3-int1]:= ar1[int1];
   end;
  end;
 end;
 if (owt_nodc in foptionswave) and (ar1 <> nil) then begin
  do1:= 0;
  for int1:= 0 to high(ar1) do begin
   do1:= do1 + ar1[int1];
  end;
  do1:= do1 / length(ar1);
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= ar1[int1] - do1;;
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
  if not (csloading in componentstate) then begin
   dochange;
  end;
 end;
end;

procedure twavetableedit.setoptionswave(const avalue: optionswavetablety);
const
 mask: optionswavetablety = [owt_rotate,owt_mirror];
begin
 if foptionswave <> avalue then begin
  foptionswave:= optionswavetablety(setsinglebit(
  {$ifdef FPC}longword{$else}byte{$endif}(avalue),
  {$ifdef FPC}longword{$else}byte{$endif}(foptionswave),
  {$ifdef FPC}longword{$else}byte{$endif}(mask)));
  if not (csloading in componentstate) then begin
   dochange;
  end;
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
 if ofe_rotate in foptionsfunct then begin
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
  if ofe_mirror in foptionsfunct then begin
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
 mask: optionsfuncteditty = [ofe_rotate,ofe_mirror];
begin
 if foptionsfunct <> avalue then begin
  foptionsfunct:= optionsfuncteditty(setsinglebit(
  {$ifdef FPC}longword{$else}byte{$endif}(avalue),
  {$ifdef FPC}longword{$else}byte{$endif}(foptionsfunct),
  {$ifdef FPC}longword{$else}byte{$endif}(mask)));
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
 fattack:= tenvelopechartedit.create(self,self,false);
 fdecay:= tenvelopechartedit.create(self,self,false);
 frelease:= tenvelopechartedit.create(self,self,false);
 fsplitter1:= tenvelopesplitter.create(self,self,false);
 fsplitter2:= tenvelopesplitter.create(self,self,false);
 width:= 3*30+2*splitterwidth;
 int1:= (fwidgetrect.cx - splitterwidth*2) div 3;
 fattack.bounds_cx:= int1;
 fdecay.bounds_cx:= int1;
 frelease.bounds_cx:= int1;
 fsplitter1.bounds_cx:= splitterwidth;
 fsplitter2.bounds_cx:= splitterwidth;
 fsplitter1.bounds_x:= fattack.bounds_x + fattack.bounds_cx;
 fsplitter2.bounds_x:= fsplitter1.bounds_x + fsplitter1.bounds_cx +
                                                          fdecay.bounds_cx;
 updatelayout;
 fsplitter1.linkleft:= fattack;
 fsplitter1.linkright:= fdecay;
 fsplitter2.linkleft:= fdecay;
 fsplitter2.linkright:= frelease;

 with fdecay do begin
  xdials.count:= 1;
  xdials[0].markers.count:= 1;
  with xdials[0].markers[0] do begin
   value:= 10;
   color:= cl_red;
   options:= [dmo_savevalue];
  end;
 end;
 fattack.xrange:= 0.1;
 fdecay.xrange:= 10;
 frelease.xrange:= 1;
end;

destructor tenvelopeedit.destroy;
begin
 fattack.free;
 fdecay.free;
 frelease.free;
 fenvelope.free;
 inherited;
end;

procedure tenvelopeedit.setattack(const avalue: tenvelopechartedit);
begin
 fattack.assign(avalue);
end;

procedure tenvelopeedit.setdecay(const avalue: tenvelopechartedit);
begin
 fdecay.assign(avalue);
end;

procedure tenvelopeedit.setrelease(const avalue: tenvelopechartedit);
begin
 frelease.assign(avalue);
end;

procedure tenvelopeedit.setsplitter1(const avalue: tenvelopesplitter);
begin
 fsplitter1.assign(avalue);
end;

procedure tenvelopeedit.setsplitter2(const avalue: tenvelopesplitter);
begin
 fsplitter2.assign(avalue);
end;

procedure tenvelopeedit.updatelayout;
var
 rect1: rectty;
 rect2: rectty;
// fr1,fr2: framety;
begin
 rect1:= innerwidgetrect;
 with rect1 do begin
  rect2.pos:= pos;
  rect2.cy:= cy;
  rect2.cx:= fattack.bounds_cx - x + fattack.bounds_x;
  fattack.widgetrect:= rect2;
  rect2.x:= fsplitter1.bounds_x;
  rect2.cx:= fsplitter1.bounds_cx;
  fsplitter1.widgetrect:= rect2;
  rect2.x:= fsplitter2.bounds_x;
  rect2.cx:= fsplitter2.bounds_cx;
  fsplitter2.widgetrect:= rect2;
  rect2.x:= fsplitter1.bounds_x+fsplitter1.bounds_cx;
  rect2.cx:= fdecay.bounds_cx;
  fdecay.widgetrect:= rect2;
  rect2.x:= fsplitter2.bounds_x+fsplitter2.bounds_cx;
  rect2.cx:= cx - rect2.x;
  frelease.widgetrect:= rect2;
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
   fattack.dostatread(reader);
  end;
  if reader.findsection(mstr1+'.1') then begin
   fsplitter1.dostatread(reader);
  end;
  if reader.findsection(mstr1+'.2') then begin
   fdecay.dostatread(reader);
  end;
  if reader.findsection(mstr1+'.3') then begin
   fsplitter2.dostatread(reader);
  end;
  if reader.findsection(mstr1+'.4') then begin
   frelease.dostatread(reader);
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
 fattack.dostatwrite(writer);
 writer.writesection(mstr1+'.1');
 fsplitter1.dostatwrite(writer);
 writer.writesection(mstr1+'.2');
 fdecay.dostatwrite(writer);
 writer.writesection(mstr1+'.3');
 fsplitter2.dostatwrite(writer);
 writer.writesection(mstr1+'.4');
 frelease.dostatwrite(writer);
end;

procedure tenvelopeedit.statreading;
begin
 fattack.statreading;
 fdecay.statreading;
 frelease.statreading;
 fsplitter1.statreading;
 fsplitter2.statreading;
end;

procedure tenvelopeedit.statread;
begin
 fattack.statread;
 fdecay.statread;
 frelease.statread;
 fsplitter1.statread;
 fsplitter2.statread;
end;

function tenvelopeedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tenvelopeedit.updatevalues;

 procedure setva(const aindex: integer);
 begin
  with fenvelope do begin
   attack_values[aindex]:= fattack.traces[aindex].xydata;
   with fdecay do begin
    decay_values[aindex]:= traces[aindex].xydata;
    if xdials.count > 0 then begin
     with xdials[0] do begin
      if markers.count > 0 then begin
       if markers[0].value < start+range then begin
        loopstart[aindex]:= markers[0].value;
       end
       else begin
        loopstart[aindex]:= -1;
       end;
      end
      else begin
       loopstart[aindex]:= -1;
      end;
     end;
    end;
   end;
   release_values[aindex]:= frelease.traces[aindex].xydata;
  end;
 end; //setva()

begin
  fenvelope.beginupdate;
  setva(0);
  setva(1);
  fenvelope.endupdate;
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

procedure tenvelopeedit.setactivetrace(avalue: integer);
begin
 if avalue < 0 then begin
  avalue:= 0;
 end;
 if avalue > 1 then begin
  avalue:= 1;
 end;
 factivetrace:= avalue;
 fattack.activetrace:= avalue;
 fdecay.activetrace:= avalue;
 frelease.activetrace:= avalue;
end;

procedure tenvelopeedit.updatepopupmenu(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
var
 st1: actionstatesarty;
begin
 inherited;
 setlength(st1,2);
 st1[factivetrace]:= [as_checked];
 fmenustart:= tpopupmenu.additems(amenu,self,mouseinfo,['Main Trace','Secondary Trace'],
                           [[mao_radiobutton],[mao_radiobutton]],st1,[]);
end;

procedure tenvelopeedit.doafterpopupmenu(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
begin
 inherited;
 if amenu.menu.submenu[fmenustart].checked then begin
  activetrace:= 0;
 end
 else begin
  activetrace:= 1;
 end;
end;

function tenvelopeedit.getstatpriority: integer;
begin
 result:= fstatpriority;
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
 traces.count:= 2;
 traces.options:= traces.options + [cto_stockglyphs];
// traces.image_list:= stockobjects.glyphs;
 with traces[0] do begin
  imagenr:= ord(stg_circlesmall);
 end;
 with traces[1]do begin
  imagenr:= ord(stg_squaresmall);
  color:= cl_red;
 end;
 with frame do begin
  optionsscroll:= optionsscroll +
               [oscr_zoomheight,oscr_zoomwidth,oscr_drag,oscr_mousewheel];
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
 procedure drawyline(const dest: tenvelopechartedit;
         const sourceoptions,destoptions: sigenveloperangeoptionsty);
 var
  co1: complexty;
  pt1: pointty;
 begin
  co1:= tracecoordxy(0,center);
  if (sero_exp in sourceoptions) xor (sero_exp in destoptions) then begin
   if (sero_exp in sourceoptions) then begin
    tsigenvelope1(fenvelope.fenvelope).exptolin(double(co1.im));
   end
   else begin
    tsigenvelope1(fenvelope.fenvelope).lintoexp(double(co1.im));
   end;
  end;
  pt1:= dest.chartcoordxy(0,co1);
  canvas.drawvect(subpoint(
     makepoint(dest.paintparentpos.x-paintparentpos.x,pt1.y),clientpos),
                                          gd_right,dest.paintsize.cx);
 end; //drawyline

begin
 inherited;
 canvas.save;
 canvas.clipregion:= 0;
 with fenvelope,fenvelope do begin
 if self = fattack then begin
  drawyline(fdecay,attack_options,decay_options);
  drawyline(frelease,attack_options,release_options);
 end
 else begin
  if self = fdecay then begin
   drawyline(fattack,decay_options,attack_options);
   drawyline(frelease,decay_options,release_options);
   end
   else begin //release
    drawyline(fattack,release_options,attack_options);
    drawyline(fdecay,release_options,decay_options);
   end;
  end;
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
    items[int1].ydata:= realarty(buf1[int1]);
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
