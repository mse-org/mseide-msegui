{ MSEgui Copyright (c) 2007-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msechart;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface

uses
 classes,msegui,mseguiglob,mseclasses,msearrayprops,msetypes,msegraphics,
 msegraphutils,mseglob,msereal,
 msewidgets,msesimplewidgets,msedial,msebitmap,msemenus,mseevent,
 msedatalist,msestatfile,msestat,msestrings;

type
 chartstatety = (chs_nocolorchart,chs_hasdialscroll,chs_hasdialshift,
                 chs_started,chs_full,chs_chartvalid); //for tchartrecorder
 chartstatesty = set of chartstatety;
 charttraceoptionty = (cto_invisible,cto_stockglyphs,cto_adddataright,
                       cto_xordered, //optimize for big data quantity
                       cto_logx,cto_logy,cto_seriescentered,
                       cto_savexscale,cto_saveyscale
                       );
 charttraceoptionsty = set of charttraceoptionty;

const
 chartrecorderstatesmask  = [chs_hasdialscroll,chs_hasdialshift,chs_started,
                             chs_full,chs_chartvalid];
 defaultxytraceoptions = [cto_xordered];

type
 tcustomchart = class;
 tracestatety = (trs_datapointsvalid);
 tracestatesty = set of tracestatety;
 tracekindty = (trk_xseries,trk_xy);
 tracechartkindty = (tck_line,tck_bar);
 tracechartkindsty = set of tracechartkindty;

 xseriesdataty = record
  value: real;
  index: integer;
 end;

 datapointty = record
  first,min,max,last: integer;
  used: boolean;
 end;
 datapointarty = array of datapointty;

 barrefty = (br_zero,br_top,br_bottom);
  
 traceinfoty = record
  xdata: realarty;
  ydata: realarty;
  xydata: complexarty;
  xdatalist: trealdatalist;
  ydatalist: trealdatalist;
  state: tracestatesty;
  datapoints: pointarty;
  barlines: segmentarty;
  bottommargin,topmargin: integer;
  color: colorty;
  colorimage: colorty;
  xserrange: real;
  xserstart: real;
  xrange: real;
  xstart: real;
  yrange: real;
  ystart: real;
  kind: tracekindty;
  maxcount: integer;
  widthmm: real;
  dashes: string;
  options: charttraceoptionsty;
  chartkind: tracechartkindty;
  bar_offset: integer;
  bar_width: integer;
  bar_frame: tframe;
  bar_face: tface;
  bar_ref: barrefty;
  start: integer;
  imagenr: imagenrty;
  name: string;
 end;

 ttraces = class;

 tbarframe = class(tframe)
  public
   constructor create(const intf: iframe);
 end;

 ttrace = class(townedeventpersistent,iimagelistinfo,iframe,iface)
  private
   finfo: traceinfoty;
   procedure setxydata(const avalue: complexarty);
   procedure datachange;
   procedure setcolor(const avalue: colorty);
   procedure setcolorimage(const avalue: colorty);
   procedure setxserrange(const avalue: real);
   procedure setxserstart(const avalue: real);
   procedure setxrange(const avalue: real);
   procedure setxstart(const avalue: real);
   procedure setyrange(const avalue: real);
   procedure setystart(const avalue: real);
   procedure scaleerror;
   procedure setxdata(const avalue: realarty);
   procedure setydata(const avalue: realarty);
   procedure setmaxcount(const avalue: integer);
   procedure setwidthmm(const avalue: real);
   procedure setdashes(const avalue: string);
   procedure readxseriescount(reader: treader);
   procedure readxscale(reader: treader);
   procedure readxoffset(reader: treader);
   procedure readyscale(reader: treader);
   procedure readyoffset(reader: treader);
   procedure setstart(const avalue: integer);
   procedure setxdatalist(const avalue: trealdatalist);
   procedure setydatalist(const avalue: trealdatalist);
   procedure setimagenr(const avalue: imagenrty);
   function getimagelist: timagelist;
   function getlogx: boolean;
   procedure setlogx(const avalue: boolean);
   function getlogy: boolean;
   procedure setlogy(const avalue: boolean);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
   function getxdatapo: preal;
   function getydatapo: preal;
   function getxydatapo: pcomplexty;
   function getcount: integer;
   function getxvalue(const index: integer): real;
   procedure setxvalue(const index: integer; const avalue: real);
   function getyvalue(const index: integer): real;
   procedure setyvalue(const index: integer; const avalue: real);
   function getxyvalue(const index: integer): complexty;
   procedure setxyvalue(const index: integer; const avalue: complexty);
   procedure setchartkind(const avalue: tracechartkindty);
   procedure setbar_offset(const avalue: integer);
   procedure setbar_width(const avalue: integer);
   function getbar_frame: tframe;
   procedure setbar_frame(const avalue: tframe);
   function getbar_face: tface;
   procedure setbar_face(const avalue: tface);
   procedure setbar_ref(const avalue: barrefty);
  protected
   ftraces: ttraces;
   procedure setkind(const avalue: tracekindty); virtual;
   procedure setoptions(const avalue: charttraceoptionsty); virtual;
   function getxitempo(const aindex: integer): preal;
   function getyitempo(const aindex: integer): preal;
   procedure getdatapo(out xpo,ypo: preal; //xpo nil for xseries
                   out xcount,ycount,xstep,ystep: integer);
                
   procedure checkgraphic;
   procedure paint(const acanvas: tcanvas);
   procedure paint1(const acanvas: tcanvas; const imagesize: sizety;
                        const imagealignment: alignmentsty);
   procedure defineproperties(filer: tfiler); override;
    //iframe
   procedure setframeinstance(instance: tcustomframe);
   procedure setstaticframe(value: boolean);
   function getstaticframe: boolean;
   procedure scrollwidgets(const dist: pointty);
   procedure clientrectchanged;
   function getcomponentstate: tcomponentstate;
   function getmsecomponentstate: msecomponentstatesty;
   procedure invalidate;
   procedure invalidatewidget;
   procedure invalidaterect(const rect: rectty; 
               const org: originty = org_client; const noclip: boolean = false);
   function getwidget: twidget;
   function getwidgetrect: rectty;
   function getframestateflags: framestateflagsty;
    //iface
   function translatecolor(const acolor: colorty): colorty;
   function getclientrect: rectty;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
               const linkintf: iobjectlink = nil);
   procedure widgetregioninvalid;
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure createbar_frame;
   procedure createbar_face;
   
   procedure clear;
   procedure deletedata(const aindex: integer); overload;
   procedure deletedata(const aindexar: integerarty); overload;
   procedure addxydata(const xy: complexty); overload;
   procedure addxydata(const x: real; const y: real); overload;
   procedure addxseriesdata(const avalue: real);
   procedure insertxseriesdata(const avalue: xseriesdataty);
   procedure assign(source: tpersistent); override;
   procedure minmaxx(out amin,amax: real);
   procedure minmaxy(out amin,amax: real);

   property xdata: realarty read finfo.ydata write setxdata;
   property ydata: realarty read finfo.ydata write setydata;
   property xydata: complexarty read finfo.xydata write setxydata;
   property xdatalist: trealdatalist read finfo.xdatalist write setxdatalist;
   property ydatalist: trealdatalist read finfo.ydatalist write setydatalist;

   property xvalue[const index: integer]: real read getxvalue write setxvalue;
   property yvalue[const index: integer]: real read getyvalue write setyvalue;
   property xyvalue[const index: integer]: complexty read getxyvalue
                                                            write setxyvalue;
   property xdatapo: preal read getxdatapo;
   property ydatapo: preal read getydatapo;
   property xydatapo: pcomplexty read getxydatapo;
   property count: integer read getcount;

   property logx: boolean read getlogx write setlogx;
   property logy: boolean read getlogy write setlogy;
   property visible: boolean read getvisible write setvisible;
   
  published
   property color: colorty read finfo.color write setcolor default cl_black;
   property colorimage: colorty read finfo.colorimage 
                      write setcolorimage default cl_default;
   property widthmm: real read finfo.widthmm write setwidthmm;   //default 0.3
   property dashes: string read finfo.dashes write setdashes;
   property xserrange: real read finfo.xserrange write setxserrange;
                                                                 //default 1.0
   property xserstart: real read finfo.xserstart write setxserstart;
   property xrange: real read finfo.xrange write setxrange;      //default 1.0
   property xstart: real read finfo.xstart write setxstart;
   property yrange: real read finfo.yrange write setyrange;      //default 1.0
   property ystart: real read finfo.ystart write setystart;
   property kind: tracekindty read finfo.kind write setkind default trk_xseries;
   property start: integer read finfo.start write setstart default 0;
   property maxcount: integer read finfo.maxcount write setmaxcount default 0;
                      //0-> data count
   property chartkind: tracechartkindty read finfo.chartkind write setchartkind 
                                                             default tck_line;
   property options: charttraceoptionsty read finfo.options 
                                             write setoptions default [];
   property bar_offset: integer read finfo.bar_offset 
                                  write setbar_offset default 0;
   property bar_width: integer read finfo.bar_width 
                                  write setbar_width default 0; //0 -> bar line
   property bar_frame: tframe read getbar_frame write setbar_frame;
   property bar_face: tface read getbar_face write setbar_face;
   property bar_ref: barrefty read finfo.bar_ref write setbar_ref default br_zero;
   
   property imagenr: imagenrty read finfo.imagenr write setimagenr default -1;
   property name: string read finfo.name write finfo.name;
 end;

 traceaty = array[0..0] of ttrace;
 ptraceaty = ^traceaty;
 
 tracesstatety = (trss_graphicvalid);
 tracesstatesty = set of tracesstatety;
   
 ttraces = class(townedeventpersistentarrayprop)
  private
   ftracestate: tracesstatesty;
   fxserstart: real;
   fxstart: real;
   fystart: real;
   fxserrange: real;
   fxrange: real;
   fyrange: real;
   fmaxcount: integer;
   fimage_list: timagelist;
   fimage_widthmm: real;
   fimage_heightmm: real;
   foptions: charttraceoptionsty;
   fkind: tracekindty;
   fchartkind: tracechartkindty;
   fbar_width: integer;
   fbar_ref: barrefty;
   procedure setitems(const index: integer; const avalue: ttrace);
   function getitems(const index: integer): ttrace;
   procedure setxserstart(const avalue: real);
   procedure setxstart(const avalue: real);
   procedure setystart(const avalue: real);
   procedure setxserrange(const avalue: real);
   procedure setxrange(const avalue: real);
   procedure setyrange(const avalue: real);
   procedure setmaxcount(const avalue: integer);
   procedure setimage_list(const avalue: timagelist);
   procedure setimage_widthmm(const avalue: real);
   procedure setimage_heightmm(const avalue: real);
   function getlogx: boolean;
   procedure setlogx(const avalue: boolean);
   function getlogy: boolean;
   procedure setlogy(const avalue: boolean);
   procedure setchartkind(const avalue: tracechartkindty);
   procedure setbar_width(const avalue: integer);
   procedure setbar_ref(const avalue: barrefty);
  protected
   fsize: sizety;
   fscalex: real;
   fscaley: real;
   procedure setkind(const avalue: tracekindty); virtual;
   procedure setoptions(const avalue: charttraceoptionsty); virtual;
   procedure change; reintroduce;
   procedure clientrectchanged;
   procedure paint(const acanvas: tcanvas);
   procedure checkgraphic;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomchart); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   function itembyname(const aname: string): ttrace;
   function actualimagelist: timagelist;
   procedure assign(source: tpersistent); override;
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure setdata(const adata: realararty); overload;
   procedure setdata(const adata: complexararty); overload;
   property logx: boolean read getlogx write setlogx;
   property logy: boolean read getlogy write setlogy;
   property items[const index: integer]: ttrace read getitems 
                                                   write setitems; default;
  published
   property kind: tracekindty read fkind write setkind default trk_xseries;
   property chartkind: tracechartkindty read fchartkind 
                                     write setchartkind default tck_line;
   property options: charttraceoptionsty read foptions 
                                                write setoptions default [];
   property xserstart: real read fxserstart write setxserstart;
   property xstart: real read fxstart write setxstart;
   property ystart: real read fystart write setystart;
   property xrange: real read fxrange write setxrange;
   property xserrange: real read fxserrange write setxserrange;
   property yrange: real read fyrange write setyrange;
   property maxcount: integer read fmaxcount write setmaxcount default 0;
     //properties not used in asssign below
   property image_list: timagelist read fimage_list write setimage_list;
   property image_widthmm: real read fimage_widthmm write setimage_widthmm;
   property image_heighthmm: real read fimage_heightmm write setimage_heightmm;
   property bar_width: integer read fbar_width 
                                  write setbar_width default 0; //0 -> bar line
   property bar_ref: barrefty read fbar_ref write setbar_ref default br_zero;
 end;

 txytrace = class(ttrace)
  protected
   procedure setkind(const avalue: tracekindty); override;
   procedure setoptions(const avalue: charttraceoptionsty); override;
  public
   constructor create(aowner: tobject); override;
  published
   property kind default trk_xy;
   property options default defaultxytraceoptions;
 end;
 
 txytraces = class(ttraces)
  protected
   fxordered: boolean;
   procedure setkind(const avalue: tracekindty); override;
   procedure setoptions(const avalue: charttraceoptionsty); override;
  public
   constructor create(const aowner: tcustomchart; const axordered: boolean);
   class function getitemclasstype: persistentclassty; override;
  published
   property kind default trk_xy;
   property options default defaultxytraceoptions;
 end;

 ichartdialcontroller = interface(idialcontroller)
  function getxstart: real;
  function getystart: real;
  function getxrange: real;
  function getyrange: real;
 end;
 
 tchartdialvert = class(tcustomdialcontroller)
  protected
   procedure setdirection(const avalue: graphicdirectionty); override;
  public
   constructor create(const aintf: idialcontroller); override;
  published
   property options; //first!
   property color;
   property widthmm;
   property direction default gd_up;
   property indent1;
   property indent2;
   property start;
   property range;
   property kind;
   property markers;
   property ticks;
 end;
 
 tchartdialhorz = class(tcustomdialcontroller)
  protected
   procedure setdirection(const avalue: graphicdirectionty); override;
  public
   constructor create(const aintf: idialcontroller); override;
  published
   property options; //first!
   property color;
   property widthmm;
   property direction default gd_right;
   property indent1;
   property indent2;
   property start;
   property range;
   property kind;
   property markers;
   property ticks;
 end;

 tchartdials = class(tcustomdialcontrollers)
  protected
  public
   constructor create(const aintf: ichartdialcontroller);
   procedure changed;
   procedure paint(const acanvas: tcanvas);
   procedure afterpaint(const acanvas: tcanvas);
 end;
 
 tchartdialshorz = class(tchartdials)
  private
   function getitems(const aindex: integer): tchartdialhorz;
   procedure setitems(const aindex: integer; const avalue: tchartdialhorz);
  protected
   function getitemclass: dialcontrollerclassty; override;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   class function getitemclasstype: persistentclassty; override;
   property items[const aindex: integer]: tchartdialhorz read getitems write setitems; default;
 end;

 tchartdialsvert = class(tchartdials)
  private
   function getitems(const aindex: integer): tchartdialvert;
   procedure setitems(const aindex: integer; const avalue: tchartdialvert);
  protected
   function getitemclass: dialcontrollerclassty; override;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   class function getitemclasstype: persistentclassty; override;
   property items[const aindex: integer]: tchartdialvert read getitems
                                                      write setitems; default;
 end;

 tchartframe = class(tscrollboxframe)
  public
   constructor create(const intf: iscrollframe; const owner: twidget);
  published
   property framei_left default 0;
   property framei_top default 0;
   property framei_right default 1;
   property framei_bottom default 1;
   property colorclient default cl_foreground;
 end;
 
 tcuchart = class(tscrollbox,ichartdialcontroller,istatfile)
  private
   fxdials: tchartdialshorz;
   fydials: tchartdialsvert;
   fxstart: real;
   fystart: real;
   fxrange: real;
   fyrange: real;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setxdials(const avalue: tchartdialshorz);
   procedure setydials(const avalue: tchartdialsvert);
   procedure setcolorchart(const avalue: colorty);
   function getxstart: real;
   procedure setxstart(const avalue: real); virtual;
   function getystart: real;
   procedure setystart(const avalue: real); virtual;
   function getxrange: real;
   procedure setxrange(const avalue: real); virtual;
   function getyrange: real;
   procedure setyrange(const avalue: real); virtual;
   procedure setstatfile(const avalue: tstatfile);
  protected
   fcolorchart: colorty;
   fstate: chartstatesty;
   fshiftsum: int64;
   fscrollsum: integer;
   fsampleco: integer;
   procedure changed; virtual;
   procedure chartchange;
   procedure clientrectchanged; override;
   procedure dopaintcontent(const acanvas: tcanvas); virtual;
   procedure dopaintbackground(const canvas: tcanvas); override;
   procedure dopaint(const acanvas: tcanvas); override;
    //idialcontroller
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
   function getdialsize: sizety;
   procedure internalcreateframe; override;
   procedure defineproperties(filer: tfiler); override;
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading; virtual;
   procedure statread; virtual;
   function getstatvarname: msestring;
   procedure initscrollstate;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property colorchart: colorty read fcolorchart write setcolorchart 
                              default cl_foreground;
   property xstart: real read getxstart write setxstart;
   property ystart: real read getystart write setystart;
   property xrange: real read getxrange write setxrange; //default 1
   property yrange: real read getyrange write setyrange; //default 1
      
   property xdials: tchartdialshorz read fxdials write setxdials;
   property ydials: tchartdialsvert read fydials write setydials;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
 end;

 tcustomchart = class(tcuchart)
  private
   procedure settraces(const avalue: ttraces);
   procedure setxstart(const avalue: real); override;
   procedure setystart(const avalue: real); override;
   procedure setxrange(const avalue: real); override;
   procedure setyrange(const avalue: real); override;
  protected
   ftraces: ttraces;
   procedure clientrectchanged; override;
   procedure dopaintcontent(const acanvas: tcanvas); override;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; virtual;
   procedure autoscalex(const astart: real = 0; const arange: real = 1);
   procedure autoscaley(const astart: real = 0; const arange: real = 1);
   procedure addsample(const asamples: array of real); virtual;
   property traces: ttraces read ftraces write settraces;
 end;

 tchart = class(tcustomchart)
  published
   property traces;
   property colorchart;
   property xstart;
   property ystart;
   property xrange;
   property yrange;
   property xdials;
   property ydials;
   property statfile;
   property statvarname;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
 end;
 
 trecordertrace = class(tvirtualpersistent)
  private
   fybefore: integer;
   fstart: real;
   frange: real;
   fcolor: colorty;
   fwidth: integer;
   procedure setrange(const avalue: real);
  public
   constructor create; override;
  published
   property start: real read fstart write fstart;
   property range: real read frange write setrange;
   property color: colorty read fcolor write fcolor default cl_glyph;
   property width: integer read fwidth write fwidth default 0;
 end;

 trecordertraces = class(tpersistentarrayprop)
  public
   constructor create;
   class function getitemclasstype: persistentclassty; override;
 end;
  
 chartrecorderoptionty = (cro_adddataright);
 chartrecorderoptionsty = set of chartrecorderoptionty;
 
 tchartrecorder = class(tcuchart)
  private
   fchart: tmaskedbitmap;
   fsamplecount: integer;
   fstep: real;
   fstepsum: real;
   fchartrect: rectty;
   fchartclientrect: rectty;
   fchartwindowrect: rectty;
   fxref: integer;
   ftraces: trecordertraces;
//   fstarted: boolean;
//   fchartvalid: boolean;
   foptions: chartrecorderoptionsty;
   procedure setsamplecount(const avalue: integer);
   procedure settraces(const avalue: trecordertraces);
  protected
   procedure checkinit;
//   procedure changed; override;
//   procedure chartchange;
//   procedure clientrectchanged; override;
   procedure dopaintcontent(const acanvas: tcanvas); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure addsample(const asamples: array of real);
   procedure clear;
  published
   property options: chartrecorderoptionsty read foptions write foptions 
                                                                   default [];
   property samplecount: integer read fsamplecount write setsamplecount 
                                default 100;
   property traces: trecordertraces read ftraces write settraces;
   
   property colorchart;
   property xstart;
   property ystart;
   property xrange;
   property yrange;
   property xdials;
   property ydials;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
 end;

function autointerval(const arange: real; const aintervalcount: real): real;
                   //returns apropropriate 1/2/5 value
function makexseriesdata(const value: real; const index: integer): xseriesdataty;

implementation
uses
 sysutils,math,msebits,rtlconsts,msestockobjects,msearrayutils;

type
 tcustomdialcontroller1 = class(tcustomdialcontroller);

function makexseriesdata(const value: real; const index: integer): xseriesdataty;
begin
 result.value:= value;
 result.index:= index;
end;

function autointerval(const arange: real; const aintervalcount: real): real;
                   //returns apropropriate 1/2/5 value
var
 rea1: real;
 rea2: real;
 int1: integer;
 scale: real;
begin
 rea1:= abs(arange/aintervalcount);
 if rea1 < 1e-99 then begin
  rea1:= 1e-99;
 end;
 int1:= ceil(log10(rea1));
 scale:= intpower(10,int1-1);
 rea2:= 0.9*rea1/scale; //1..10, 10% overrange
 if rea2 < 1 then begin
  rea2:= 1;
 end
 else begin
  if rea2 < 2 then begin
   rea2:= 2;
  end
  else begin
   if rea2 < 5 then begin
    rea2:= 5;
   end
   else begin
    rea2:= 10;
   end;
  end;
 end;
 result:= rea2 * scale;
 if arange < 0 then begin
  result:= -result;
 end;
end;
  
{ ttrace }

constructor ttrace.create(aowner: tobject);
begin
 ftraces:= tcustomchart(aowner).ftraces;
 finfo.color:= cl_black;
 finfo.colorimage:= cl_default;
 finfo.widthmm:= 0.3;
 finfo.xserrange:= 1.0;
 finfo.xrange:= 1.0;
 finfo.yrange:= 1.0;
 finfo.imagenr:= -1;
 inherited;
end;

destructor ttrace.destroy;
begin
 inherited;
 finfo.bar_frame.free;
 finfo.bar_face.free;
end;

procedure ttrace.datachange;
begin
 exclude(finfo.state,trs_datapointsvalid);
 tcustomchart(fowner).traces.change;
end;

procedure ttrace.setxydata(const avalue: complexarty);
begin
 finfo.xdatalist:= nil;
 finfo.ydatalist:= nil;
 finfo.xdata:= nil;
 finfo.ydata:= nil;
 finfo.xydata:= avalue;
 datachange;
end;


procedure ttrace.setxdata(const avalue: realarty);
begin
 finfo.xdatalist:= nil;
 finfo.xydata:= nil;
 finfo.xdata:= avalue;
 datachange;
end;

procedure ttrace.setydata(const avalue: realarty);
begin
 finfo.ydatalist:= nil;
 finfo.xydata:= nil;
 finfo.ydata:= avalue;
 datachange;
end;

procedure ttrace.setxdatalist(const avalue: trealdatalist);
begin
 finfo.xdata:= nil;
 finfo.xydata:= nil;
 finfo.xdatalist:= avalue;
 datachange;
end;

procedure ttrace.setydatalist(const avalue: trealdatalist);
begin
 finfo.ydata:= nil;
 finfo.xydata:= nil;
 finfo.ydatalist:= avalue;
 datachange;
end;

procedure ttrace.checkgraphic;

 function pkround(const avalue: real): integer;
 begin
  if avalue > $3fff then begin //X11 range is 16bit
   result:= $3fff;
  end
  else begin
   if avalue < -$4000 then begin
    result:= -$4000;
   end
   else begin
    result:= round(avalue);
   end;
  end;
 end;
  
var
 pox,poy: pchar;
 intx,inty: integer;

 procedure checkrange(var dpcount: integer);
 var
  int1: integer;
 begin
  int1:= finfo.maxcount;
  if int1 = 0 then begin
   int1:= dpcount;
  end;
  if finfo.start + int1 > dpcount then begin
   int1:= dpcount - finfo.start;
  end;
  if int1 < dpcount then begin
   dpcount:= int1;
  end;
  if dpcount < 0 then begin
   dpcount:= 0;
  end;
  pox:= pox + finfo.start * intx;
  poy:= poy + finfo.start * inty;
 end;

var
 int1,int2,int3,int4: integer;
 xo,xs,yo,ys,lxo,lxs: real;
 rea1: real;
 ar1: datapointarty;
 dpcountx,dpcounty,dpcountxy: integer;
 xbottom,xtop: integer;
 isxseries: boolean;
 dpcounty1: integer;
 islogx,islogy: boolean;
 
begin
 if not (trs_datapointsvalid in finfo.state) and visible then begin
  finfo.datapoints:= nil;
  include(finfo.state,trs_datapointsvalid);
  dpcountx:= 0;
  dpcounty:= 0;
  with finfo do begin
   isxseries:= (kind = trk_xseries);
   islogx:= cto_logx in options;
   islogy:= cto_logy in options;
   bottommargin:= 0;
   topmargin:= 0;
   if xydata <> nil then begin
    pox:= @xydata[0].re;
    poy:= @xydata[0].im;
    intx:= sizeof(complexty);
    inty:= sizeof(complexty);
    dpcountx:= length(xydata);
    dpcounty:= dpcountx;
   end
   else begin
    if xdatalist <> nil then begin
     dpcountx:= xdatalist.count;
     pox:= xdatalist.datapo;
     intx:= finfo.xdatalist.size;
    end
    else begin
     pox:= pointer(xdata);
     intx:= sizeof(real);
     dpcountx:= length(xdata);
    end;
    if ydatalist <> nil then begin
     dpcounty:= ydatalist.count;
     poy:= ydatalist.datapo;
     inty:= ydatalist.size;
    end
    else begin
     poy:= pointer(ydata);
     inty:= sizeof(real);
     dpcounty:= length(ydata);
    end;
   end;
  end;
  dpcountxy:= dpcountx;
  if isxseries or (dpcounty < dpcountxy) then begin
   dpcountxy:= dpcounty;
  end;
  if islogy then begin
   yo:= -(chartln(finfo.ystart + finfo.yrange));
   ys:= -tcustomchart(fowner).traces.fscaley / (-chartln(finfo.ystart) - yo);
  end
  else begin
   yo:= -finfo.ystart - finfo.yrange;
   ys:= -tcustomchart(fowner).traces.fscaley / finfo.yrange;
  end;
  case finfo.kind of
   trk_xy,trk_xseries: begin     
    lxo:= 0;
    lxs:= 1;
    if isxseries then begin
     dpcounty1:= dpcounty-1;
     rea1:= 0;
     if maxcount > 1 then begin
      int2:= maxcount - 1;
      if (int2 > dpcounty1) and 
                       (cto_adddataright in finfo.options) then begin
       rea1:= {$ifdef FPC}real({$endif}1.0{$ifdef FPC}){$endif} - 
                                                dpcounty1 / int2;
      end;
     end
     else begin
      int2:= dpcounty1;
     end;
     if cto_logx in options then begin
      lxo:= int2 * (finfo.xserstart/finfo.xserrange);
      lxs:= finfo.xserrange;
      xo:= -chartln(-(rea1 - finfo.xstart) * int2);
      xs:= tcustomchart(fowner).traces.fscalex;
      if int2 > 0 then begin
       xs:= xs / (chartln((finfo.xstart+finfo.xrange) * int2)+xo);
      end;
      if xs <> 0 then begin
       xo:= xo + 1/xs;
      end;
     end
     else begin
      xo:= (rea1 - finfo.xstart) * int2;
      xs:= tcustomchart(fowner).traces.fscalex;
      if int2 > 0 then begin
       xs:= xs / (finfo.xrange * int2);
      end;
      if xs <> 0 then begin
       xo:= xo + 1/xs;
      end;
      xo:= (finfo.xserstart*int2+xo)/(finfo.xserrange);
      xs:= xs*finfo.xserrange;
     end;
    end
    else begin
     if cto_logx in options then begin
      xo:= -chartln(finfo.xstart);
      xs:= tcustomchart(fowner).traces.fscalex / 
                                     (chartln(finfo.xrange+finfo.xstart)+xo);
     end
     else begin
      xo:= -finfo.xstart;
      xs:= tcustomchart(fowner).traces.fscalex / finfo.xrange;
     end;
    end;
    checkrange(dpcountxy);
    if isxseries and (cto_seriescentered in finfo.options) and 
                                             (dpcounty > 0) then begin
     xs:= xs*(dpcounty1/dpcounty);
     xo:= xo + 0.5;
    end;
    
    if (cto_xordered in finfo.options) or isxseries then begin
     int4:= tcustomchart(fowner).traces.fsize.cx+3;//2; //cx + 1
     setlength(ar1,int4);
     dec(int4);
     xbottom:= minint;
     xtop:= maxint;
     for int1:= 0 to dpcountxy - 1 do begin
      if isxseries then begin
       if islogx then begin
        int2:= round((chartln((int1+lxo)*lxs) + xo) * xs);
       end
       else begin
        int2:= round((int1 + xo) * xs);
       end;
      end
      else begin
       if islogx then begin
        int2:= pkround((chartln(preal(pox)^) + xo) * xs) + 1;
       end
       else begin
        int2:= pkround((preal(pox)^ + xo) * xs) + 1;
       end;
      end;
      if islogy then begin
       int3:= pkround((chartln(preal(poy)^) + yo) * ys);
      end
      else begin
       int3:= pkround((preal(poy)^ + yo) * ys);
      end;
      if int2 < 0 then begin
       if int2 > xbottom then begin
        xbottom:= int2;
       end;
       int2:= 0;
      end;
      if int2 > int4 then begin
       if int2 < xtop then begin
        xtop:= int2;
       end;
       int2:= int4;
      end;
      with ar1[int2] do begin
       if not used then begin
        used:= true;
        first:= int3;
        min:= int3;
        max:= int3;
       end
       else begin
        if int3 < min then begin
         min:= int3;
        end;
        if int3 > max then begin
         max:= int3;
        end;
       end;
       last:= int3;
      end;
      if xtop <> maxint then begin
       break;
      end;
      inc(pox,intx);
      inc(poy,inty);
     end;
     with ar1[0] do begin         //endpoints
      first:= last;
      min:= last;
      max:= last;
     end;
     with ar1[high(ar1)] do begin
      first:= last;
      min:= last;
      max:= last;
     end;
     setlength(finfo.datapoints,length(ar1)*4);  //first->max->min->last
     int2:= 0;
     for int1:= 0 to high(ar1) do begin
      with ar1[int1] do begin
       if used then begin
        int3:= int1-1;
        finfo.datapoints[int2].x:= int3;
        finfo.datapoints[int2].y:= first;
        inc(int2);
        if max > first then begin
         finfo.datapoints[int2].x:= int3;
         finfo.datapoints[int2].y:= max;
         inc(int2);
        end;
        if min < max then begin
         finfo.datapoints[int2].x:= int3;
         finfo.datapoints[int2].y:= min;
         inc(int2);
        end;
        if last > min then begin
         finfo.datapoints[int2].x:= int3;
         finfo.datapoints[int2].y:= last;
         inc(int2);
        end;
       end;
      end;
     end;
     setlength(finfo.datapoints,int2);
     if chartkind = tck_line then begin
      with finfo do begin //adjust boundary values 
                          //todo: extend window for image size
       barlines:= nil;
       if int2 > 1 then begin
        if ar1[0].used then begin
         bottommargin:= 1;
         datapoints[0].y:= pkround(datapoints[0].y + 
               (datapoints[1].y - datapoints[0].y) * 
                 (-1-xbottom)/
                 (datapoints[1].x-xbottom));
        end;
        if ar1[high(ar1)].used then begin
         topmargin:= 1;
         datapoints[int2-1].y:= pkround(datapoints[int2-1].y + 
               (datapoints[int2-2].y - datapoints[int2-1].y) * 
                 (length(ar1)-xtop)/
                 (datapoints[int2-2].x-xtop));
        end;
       end;
      end;
     end
     else begin //tck_barline
      with finfo do begin
       setlength(barlines,length(datapoints));
       case bar_ref of
        br_top: begin
         int2:= -1;
        end;
        br_bottom: begin 
         int2:= tcustomchart(fowner).traces.fsize.cy+1;
        end;
        else begin //br_zero
         int2:= round(yo*ys); //zero position
         if int2 < 0 then begin
          int2:= -1;
         end;
         if int2 > tcustomchart(fowner).traces.fsize.cy+1 then begin
          int2:= tcustomchart(fowner).traces.fsize.cy+1;
         end;
        end;
       end;
       for int1:= 0 to high(barlines) do begin
        with barlines[int1] do begin
         a.x:= datapoints[int1].x + bar_offset;
         a.y:= datapoints[int1].y;
         b.x:= a.x;
         b.y:= int2;
        end;
       end;
      end;
     end;
    end            //xordered
    else begin     //xy
     setlength(finfo.datapoints,dpcountxy);
     for int1:= 0 to high(finfo.datapoints) do begin
      if islogx then begin
       finfo.datapoints[int1].x:= pkround((chartln(preal(pox)^) + xo)* xs);
      end
      else begin
       finfo.datapoints[int1].x:= pkround((preal(pox)^ + xo)* xs);
      end;
      if islogy then begin
       finfo.datapoints[int1].y:= pkround((chartln(preal(poy)^) + yo)* ys);
      end
      else begin
       finfo.datapoints[int1].y:= pkround((preal(poy)^ + yo)* ys);
      end;
      inc(pox,intx);
      inc(poy,inty);
     end;
    end;
   end;
  end;
 end;
end;

procedure ttrace.paint(const acanvas: tcanvas);
var
 int1: integer;
 rect1,rect2: rectty;
begin
 if (finfo.widthmm > 0) and visible then begin
  acanvas.linewidthmm:= finfo.widthmm;
  if finfo.dashes <> '' then begin
   acanvas.dashes:= finfo.dashes;
  end;
  if finfo.chartkind = tck_bar then begin
   if finfo.bar_width = 0 then begin
    acanvas.drawlinesegments(finfo.barlines,finfo.color);
   end
   else begin
    rect1.cx:= finfo.bar_width;
    for int1:= 0 to high(finfo.barlines) do begin
     with finfo.barlines[int1] do begin
      rect1.pos:= a;
      rect1.cy:= b.y - a.y;
      acanvas.fillrect(rect1,finfo.color);
      if finfo.bar_frame <> nil then begin
//       normalizerect1(rect1);
       if rect1.cy < 0 then begin
        rect1.y:= rect1.y + rect1.cy;
        rect1.y:= -rect1.y;
       end;
       acanvas.save;
       finfo.bar_frame.paintbackground(acanvas,rect1);
       if finfo.bar_face <> nil then begin
        rect2:= deflaterect(rect1,finfo.bar_frame.innerframe);
        acanvas.remove(pointty(finfo.bar_frame.paintframe.topleft));
        finfo.bar_face.paint(acanvas,rect2);
       end;
       acanvas.restore;
       finfo.bar_frame.paintoverlay(acanvas,rect1);
      end;
     end;
    end;
   end;
  end
  else begin
   acanvas.capstyle:= cs_round;
   acanvas.joinstyle:= js_round;
   acanvas.drawlines(finfo.datapoints,false,finfo.color);
   acanvas.capstyle:= cs_butt;
   acanvas.joinstyle:= js_miter;
  end;
  if finfo.dashes <> '' then begin
   acanvas.dashes:= '';
  end;
 end;
end;

procedure ttrace.paint1(const acanvas: tcanvas; const imagesize: sizety;
                        const imagealignment: alignmentsty);
var
 int1: integer;
 pt1: pointty;
 rect1: rectty;
 co1: colorty;
 bmp1,bmp2: tmaskedbitmap;
// margin: integer;
 imli1: timagelist;
begin
 if not visible then begin
  exit;
 end;
 with ftraces do begin
  imli1:= actualimagelist;
  if (imli1 <> nil) and (finfo.imagenr >= 0) and 
                                    (finfo.imagenr < imli1.count) then begin
   pt1:= pointty(imagesize);
   pt1.x:= pt1.x div 2;
   pt1.y:= pt1.y div 2;
   acanvas.remove(pt1);
   rect1.size:= imagesize;
   co1:= finfo.colorimage;
   if co1 = cl_default then begin
    co1:= finfo.color;
   end;
   if not acanvas.highresdevice and 
               (imagealignment * [al_stretchx,al_stretchy] <> []) then begin
    bmp1:= tmaskedbitmap.create(imli1.monochrome);
    bmp2:= tmaskedbitmap.create(false);
    try
     bmp1.masked:= imli1.masked;
     imli1.getimage(finfo.imagenr,bmp1);
     bmp1.colorforeground:= co1;
     bmp1.colorbackground:= tcuchart(fowner).colorchart;
     bmp1.monochrome:= false;
     bmp1.colormask:= true;
     bmp2.size:= imagesize;
     bmp1.stretch(bmp2);
     for int1:= finfo.bottommargin to high(finfo.datapoints) - 
                                                finfo.topmargin do begin
      bmp2.paint(acanvas,finfo.datapoints[int1],[],co1);
     end;
    finally
     bmp1.free;
     bmp2.free;
    end;
   end
   else begin
    for int1:= finfo.bottommargin to high(finfo.datapoints) - 
                                                 finfo.topmargin do begin
     rect1.pos:= finfo.datapoints[int1];
     imli1.paint(acanvas,finfo.imagenr,rect1,imagealignment,co1);
    end;
   end;
   acanvas.move(pt1);
  end;
 end;
end;

procedure ttrace.setcolor(const avalue: colorty);
begin
 if finfo.color <> avalue then begin
  finfo.color:= avalue;
  tcustomchart(fowner).traces.change;
 end;
end;

procedure ttrace.setcolorimage(const avalue: colorty);
begin
 if finfo.colorimage <> avalue then begin
  finfo.colorimage:= avalue;
  tcustomchart(fowner).traces.change;
 end;
end;

procedure ttrace.setwidthmm(const avalue: real);
begin
 finfo.widthmm:= avalue;
 tcustomchart(fowner).traces.change;
end;

procedure ttrace.setdashes(const avalue: string);
begin
 finfo.dashes:= avalue;
 tcustomchart(fowner).traces.change;
end;

procedure ttrace.setxserrange(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 finfo.xserrange:= avalue;
 datachange;
end;

procedure ttrace.setxrange(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 finfo.xrange:= avalue;
 datachange;
end;

procedure ttrace.setoptions(const avalue: charttraceoptionsty);
begin
 if avalue <> finfo.options then begin
  finfo.options:= avalue {- [cto_stockglyphs]};
  datachange;
 end;
end;

procedure ttrace.setchartkind(const avalue: tracechartkindty);
begin
 if finfo.chartkind <> avalue then begin
  finfo.chartkind:= avalue;
  datachange;
 end;
end;

procedure ttrace.setbar_offset(const avalue: integer);
begin
 if finfo.bar_offset <> avalue then begin
  finfo.bar_offset:= avalue;
  datachange;
 end;
end;

procedure ttrace.setbar_width(const avalue: integer);
begin
 if finfo.bar_width <> avalue then begin
  finfo.bar_width:= avalue;
  datachange;
 end;
end;

procedure ttrace.setbar_ref(const avalue: barrefty);
begin
 if finfo.bar_ref <> avalue then begin
  finfo.bar_ref:= avalue;
  datachange;
 end;
end;

procedure ttrace.setxserstart(const avalue: real);
begin
 finfo.xserstart:= avalue;
 datachange;
end;

procedure ttrace.setxstart(const avalue: real);
begin
 finfo.xstart:= avalue;
 datachange;
end;

procedure ttrace.setyrange(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 finfo.yrange:= avalue;
 datachange;
end;

procedure ttrace.setystart(const avalue: real);
begin
 finfo.ystart:= avalue;
 datachange;
end;

procedure ttrace.scaleerror;
begin
 raise exception.create('Range can not be 0.');
end;

procedure ttrace.setkind(const avalue: tracekindty);
begin
 if finfo.kind <> avalue then begin
  finfo.kind:= avalue;
  datachange;
 end;
end;

procedure ttrace.setstart(const avalue: integer);
begin
 if finfo.start <> avalue then begin
  finfo.start:= avalue;
  datachange;
 end;
end;

procedure ttrace.setmaxcount(const avalue: integer);
begin
 if finfo.maxcount <> avalue then begin
  finfo.maxcount:= avalue;
  datachange;
 end;
end;

procedure ttrace.addxseriesdata(const avalue: real);
begin
 finfo.ydatalist:= nil;
 if (finfo.maxcount = 0) or (length(finfo.ydata) < finfo.maxcount) then begin
  setlength(finfo.ydata,high(finfo.ydata) + 2);
 end
 else begin
  move(finfo.ydata[1],finfo.ydata[0],
          sizeof(finfo.ydata[0])*high(finfo.ydata));
 end;
 finfo.ydata[high(finfo.ydata)]:= avalue;
 datachange;
end;

procedure ttrace.insertxseriesdata(const avalue: xseriesdataty);
begin
 finfo.ydatalist:= nil;
 insertitem(finfo.ydata,avalue.index,avalue.value);
 datachange;
end;

procedure ttrace.readxseriescount(reader: treader);
begin
 maxcount:= reader.readinteger;
end;

procedure ttrace.readxscale(reader: treader);
begin
 xrange:= reader.readfloat;
end;

procedure ttrace.readxoffset(reader: treader);
begin
 xstart:= -reader.readfloat;
end;

procedure ttrace.readyscale(reader: treader);
begin
 yrange:= reader.readfloat;
end;

procedure ttrace.readyoffset(reader: treader);
begin
 ystart:= -reader.readfloat;
end;

procedure ttrace.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('xseriescount',{$ifdef FPC}@{$endif}readxseriescount,
                                                         nil,false);
 filer.defineproperty('xoffset',{$ifdef FPC}@{$endif}readxoffset,
                                                         nil,false);
 filer.defineproperty('xscale',{$ifdef FPC}@{$endif}readxscale,
                                                         nil,false);
 filer.defineproperty('yoffset',{$ifdef FPC}@{$endif}readyoffset,
                                                         nil,false);
 filer.defineproperty('yscale',{$ifdef FPC}@{$endif}readyscale,
                                                         nil,false);
end;

procedure ttrace.setimagenr(const avalue: imagenrty);
begin
 if finfo.imagenr <> avalue then begin
  finfo.imagenr:= avalue;
  datachange;
 end;
end;

function ttrace.getimagelist: timagelist;
begin
 result:= ftraces.actualimagelist;
end;

procedure ttrace.assign(source: tpersistent);
begin
 if source is ttrace then begin
  with ttrace(source) do begin
   self.finfo:= finfo;
   datachange;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure ttrace.clear;
begin
 xydata:= nil;
end;

procedure ttrace.addxydata(const x: real; const y: real);
var
 int1,int2: integer;
begin
 with finfo do begin
  xdatalist:= nil;
  ydatalist:= nil;
  if xydata <> nil then begin
   if cto_xordered in options then begin
    int2:= 0;
    for int1:= high(xydata) downto 0 do begin
     if xydata[int1].re <= x then begin
      int2:= int1+1;
      break;
     end;
    end;
    insertitem(xydata,int2,makecomplex(x,y));
   end
   else begin
    setlength(xydata,high(xydata)+2);
    with xydata[high(xydata)] do begin
     re:= x;
     im:= y;
    end;   
   end;
  end
  else begin
   if (xdata <> nil) then begin   
    if cto_xordered in options then begin
     int2:= 0;
     for int1:= high(xdata) downto 0 do begin
      if xdata[int1] <= x then begin
       int2:= int1+1;
       break;
      end;
     end;
     setlength(ydata,length(xdata));
     insertitem(xdata,int2,x);
     insertitem(ydata,int2,y);
    end
    else begin
     setlength(xdata,high(xdata)+2);
     setlength(ydata,length(xdata));
     xdata[high(xdata)]:= x;
     ydata[high(xdata)]:= y;
    end;
   end
   else begin
    if (ydata <> nil) then begin   
     if cto_xordered in options then begin
     end
     else begin
      setlength(ydata,high(ydata)+2);
      setlength(xdata,length(ydata));
      xdata[high(xdata)]:= x;
      ydata[high(xdata)]:= y;
     end;
    end
    else begin
     setlength(xydata,1);
     with xydata[0] do begin
      re:= x;
      im:= y;
     end;
    end;
   end;
  end; 
 end;
 datachange;
end;

function ttrace.getlogx: boolean;
begin
 result:= cto_logx in options;
end;

procedure ttrace.setlogx(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [cto_logx];
 end
 else begin
  options:= options - [cto_logx];
 end;
end;

function ttrace.getlogy: boolean;
begin
 result:= cto_logy in options;
end;

procedure ttrace.setlogy(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [cto_logy];
 end
 else begin
  options:= options - [cto_logy];
 end;
end;

function ttrace.getvisible: boolean;
begin
 result:= not (cto_invisible in finfo.options);
end;

procedure ttrace.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [cto_invisible];
 end
 else begin
  options:= options + [cto_invisible];
 end;
end;

function ttrace.getxdatapo: preal;
begin
 result:= pointer(finfo.xdata);
 if xdatalist <> nil then begin
  result:= xdatalist.datapo;
 end;
end;

function ttrace.getydatapo: preal;
begin
 result:= pointer(finfo.ydata);
 if ydatalist <> nil then begin
  result:= ydatalist.datapo;
 end;
end;

function ttrace.getxydatapo: pcomplexty;
begin
 result:= pointer(finfo.xydata);
end;

function ttrace.getcount: integer;
begin
 result:= 0;
 with finfo do begin
  if ydata <> nil then begin
   result:= length(ydata);
  end;
  if xdata <> nil then begin
   result:= length(xdata);
  end;
  if xydata <> nil then begin
   result:= length(xydata);
  end;
  if ydatalist <> nil then begin
   result:= ydatalist.count;
  end;
  if xdatalist <> nil then begin
   result:= xdatalist.count;
  end;
 end;
end;

function ttrace.getxvalue(const index: integer): real;
begin
 result:= getxitempo(index)^;
end;

procedure ttrace.setxvalue(const index: integer; const avalue: real);
begin
 getxitempo(index)^:= avalue;
 datachange;
end;

function ttrace.getyvalue(const index: integer): real;
begin
 result:= getyitempo(index)^;
end;

procedure ttrace.setyvalue(const index: integer; const avalue: real);
begin
 getyitempo(index)^:= avalue;
 datachange;
end;

function ttrace.getxyvalue(const index: integer): complexty;
begin
 result.re:= getxitempo(index)^;
 result.im:= getyitempo(index)^;
end;

procedure ttrace.setxyvalue(const index: integer; const avalue: complexty);
begin
 getxitempo(index)^:= avalue.re;
 getyitempo(index)^:= avalue.im;
 datachange;
end;

procedure ttrace.addxydata(const xy: complexty);
begin
 addxydata(xy.re,xy.im);
end;

function ttrace.getxitempo(const aindex: integer): preal;
begin
 with finfo do begin
  if xdatalist <> nil then begin
   result:= xdatalist.getitempo(aindex);
  end
  else begin
   if xdata <> nil then begin
    checkarrayindex(xdata,aindex);
    result:= @xdata[aindex];
   end
   else begin
    checkarrayindex(xydata,aindex);
    result:= @xydata[aindex].re;
   end;
  end;
 end;
end;

function ttrace.getyitempo(const aindex: integer): preal;
begin
 with finfo do begin
  if ydatalist <> nil then begin
   result:= ydatalist.getitempo(aindex);
  end
  else begin
   if ydata <> nil then begin
    checkarrayindex(ydata,aindex);
    result:= @ydata[aindex];
   end
   else begin
    checkarrayindex(xydata,aindex);
    result:= @xydata[aindex].im;
   end
  end;
 end;
end;

procedure ttrace.getdatapo(out xpo,ypo: preal; //xpo nil for xseries
                   out xcount,ycount,xstep,ystep: integer);
begin
 ystep:= 1;
 xstep:= 1;
 xpo:= nil;
 ypo:= nil;
 xcount:= 0;
 ycount:= 0;
 with finfo do begin
  if ydatalist <> nil then begin
   ypo:= ydatalist.datapo;
   ycount:= ydatalist.count;
  end
  else begin
   if ydata <> nil then begin
    ypo:= pointer(ydata);
    ycount:= length(ydata);
   end
   else begin
    ypo:= pointer(xydata);
    ycount:= length(xydata);
    ystep:= 2;
    if ypo <> nil then begin
     inc(ypo);
    end;
   end;
  end;
  if kind <> trk_xseries then begin
   if xdatalist <> nil then begin
    xpo:= xdatalist.datapo;
    xcount:= xdatalist.count;
   end
   else begin
    if xdata <> nil then begin
     xpo:= pointer(xdata);
     xcount:= length(xdata);
    end
    else begin
     xpo:= pointer(xydata);
     xcount:= length(xydata);
     ystep:= 2;
    end;
   end;
  end;
 end;
end;

procedure ttrace.deletedata(const aindex: integer);
begin
 if (aindex < 0) or (aindex >= count) then begin
  tlist.error(slistindexerror, aindex);
 end;
 datachange;
 with finfo do begin
  if ydata <> nil then begin
   deleteitem(ydata,aindex);
  end;
  if xdata <> nil then begin
   deleteitem(xdata,aindex);
  end;
  if xydata <> nil then begin
   deleteitem(xydata,aindex);
  end;
  if ydatalist <> nil then begin
   ydatalist.deletedata(aindex);
  end;
  if xdatalist <> nil then begin
   xdatalist.deletedata(aindex);
  end;
 end;
end;

procedure ttrace.deletedata(const aindexar: integerarty);
var
 int1,int2,int3: integer;
 ar1: integerarty;
begin
 ar1:= copy(aindexar);
 for int1:= 0 to high(ar1) do begin
  int2:= ar1[int1];
  deletedata(int2);
  for int3:= int1+1 to high(ar1) do begin
   if ar1[int3] >= int2 then begin
    dec(ar1[int3]);
   end;
  end;
 end;
end;

function ttrace.getbar_frame: tframe;
begin
 tcustomchart(fowner).getoptionalobject(finfo.bar_frame,
                               {$ifdef FPC}@{$endif}createbar_frame);
 result:= finfo.bar_frame;
end;

procedure ttrace.setbar_frame(const avalue: tframe);
begin
 tcustomchart(fowner).setoptionalobject(avalue,finfo.bar_frame,
                                 {$ifdef FPC}@{$endif}createbar_frame);
 datachange;
end;

function ttrace.getbar_face: tface;
begin
 tcustomchart(fowner).getoptionalobject(finfo.bar_face,{$ifdef FPC}@{$endif}createbar_face);
 result:= finfo.bar_face;
end;

procedure ttrace.setbar_face(const avalue: tface);
begin
 tcustomchart(fowner).setoptionalobject(avalue,finfo.bar_face,
                                      {$ifdef FPC}@{$endif}createbar_face);
 datachange;
end;

procedure ttrace.createbar_frame;
begin
 if finfo.bar_frame = nil then begin
  tbarframe.create(iframe(self));
 end;
end;

procedure ttrace.createbar_face;
begin
 if finfo.bar_face = nil then begin
  finfo.bar_face:= tface.create(iface(self));
 end;
end;

procedure ttrace.setframeinstance(instance: tcustomframe);
begin
 finfo.bar_frame:= tframe(instance);
end;

procedure ttrace.setstaticframe(value: boolean);
begin
 //dummy
end;

function ttrace.getstaticframe: boolean;
begin
 result:= false;
end;

procedure ttrace.scrollwidgets(const dist: pointty);
begin
 //dummy
end;

procedure ttrace.clientrectchanged;
begin
 invalidate;
end;

function ttrace.getcomponentstate: tcomponentstate;
begin
 result:= tcustomchart(fowner).componentstate;
end;

function ttrace.getmsecomponentstate: msecomponentstatesty;
begin
 result:= tcustomchart(fowner).msecomponentstate;
end;

procedure ttrace.invalidate;
begin
 tcustomchart(fowner).invalidate;
end;

procedure ttrace.invalidatewidget;
begin
 tcustomchart(fowner).invalidatewidget;
end;

procedure ttrace.invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
begin
 tcustomchart(fowner).invalidaterect(rect,org,noclip);
end;

function ttrace.getwidget: twidget;
begin
 result:= tcustomchart(fowner);
end;

function ttrace.getwidgetrect: rectty;
begin
 result:= tcustomchart(fowner).innerclientrect;
end;

function ttrace.getframestateflags: framestateflagsty;
begin
 result:= [];
end;

function ttrace.translatecolor(const acolor: colorty): colorty;
begin
 result:= acolor;
 if acolor = cl_default then begin
  result:= finfo.color;
 end
 else begin
  result:= acolor;
 end;
end;

function ttrace.getclientrect: rectty;
begin
 result:= tcustomchart(fowner).innerclientrect;
end;

procedure ttrace.setlinkedvar(const source: tmsecomponent;
               var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 tcustomchart(fowner).setlinkedvar(source,dest,linkintf);
end;

procedure ttrace.widgetregioninvalid;
begin
 //dummy
end;

procedure ttrace.minmaxx(out amin: real; out amax: real);
var
 min,max: real;
 int1: integer;
 pox,poy: preal;
 cx,cy,sx,sy: integer;
begin
 if kind = trk_xseries then begin
  min:= xserstart;
  max:= min + xserrange;
 end
 else begin
  getdatapo(pox,poy,cx,cy,sx,sy);
  if cx = 0 then begin
   min:= 0;
   max:= 1;
  end
  else begin
   min:= bigreal;
   max:= -bigreal;
   for int1:= cx-1 downto 0 do begin
    if pox^ > max then begin
     max:= pox^;
    end;
    if pox^ < min then begin
     min:= pox^;
    end;
    inc(pox,sx);
   end;
  end;
 end;
 amin:= min;
 amax:= max;
end;

procedure ttrace.minmaxy(out amin: real; out amax: real);
var
 min,max: real;
 int1: integer;
 pox,poy: preal;
 cx,cy,sx,sy: integer;
begin
 getdatapo(pox,poy,cx,cy,sx,sy);
 if cy = 0 then begin
  min:= 0;
  max:= 1;
 end
 else begin
  min:= bigreal;
  max:= -bigreal;
  for int1:= cy-1 downto 0 do begin
   if poy^ > max then begin
    max:= poy^;
   end;
   if poy^ < min then begin
    min:= poy^;
   end;
   inc(poy,sy);
  end;
 end;
 amin:= min;
 amax:= max;
end;

{ ttraces }

constructor ttraces.create(const aowner: tcustomchart);
begin
 fkind:= trk_xseries;
 fxserrange:= 1;
 fxrange:= 1;
 fyrange:= 1;
 inherited create(aowner,ownedeventpersistentclassty(getitemclasstype));
end;

class function ttraces.getitemclasstype: persistentclassty;
begin
 result:= ttrace;
end;

procedure ttraces.change;
begin 
 exclude(ftracestate,trss_graphicvalid);
 tcuchart(fowner).invalidate;
end;

procedure ttraces.clientrectchanged;
var
 int1: integer;
begin
 exclude(ftracestate,trss_graphicvalid);
 for int1:= 0 to high(fitems) do begin
  exclude(ptraceaty(fitems)^[int1].finfo.state,trs_datapointsvalid);
 end;
end;

procedure ttraces.paint(const acanvas: tcanvas);
var
 int1: integer;
 size1: sizety;
 align1: alignmentsty;
 imli1: timagelist;
begin
 checkgraphic;
 for int1:= 0 to high(fitems) do begin
  ptraceaty(fitems)^[int1].paint(acanvas);
 end;
 align1:= [];
 size1:= nullsize;
 imli1:= actualimagelist;
 if imli1 <> nil then begin
  size1:= imli1.size;
  if fimage_widthmm <> 0 then begin
   size1.cx:= round(fimage_widthmm*acanvas.ppmm);
   align1:= align1 + [al_stretchx,al_intpol];
  end;
  if fimage_heightmm <> 0 then begin
   size1.cy:= round(fimage_heightmm*acanvas.ppmm);
   align1:= align1 + [al_stretchy,al_intpol];
  end;
 end;
 exclude(align1,al_intpol);
 for int1:= 0 to high(fitems) do begin
  ptraceaty(fitems)^[int1].paint1(acanvas,size1,align1);
 end;
 acanvas.linewidth:= 0;
end;

procedure ttraces.checkgraphic;
var
 int1: integer;
begin
 if not (trss_graphicvalid in ftracestate) then begin
  fsize:= twidget(fowner).innerclientsize;
  if fsize.cx < 0 then begin
   fsize.cx:= 0;
  end;
  if fsize.cy < 0 then begin
   fsize.cy:= 0;
  end;
  fscalex:= fsize.cx;
  fscaley:= fsize.cy;
  for int1:= 0 to high(fitems) do begin
   ptraceaty(fitems)^[int1].checkgraphic;
  end;
  include(ftracestate,trss_graphicvalid);
 end;
end;

procedure ttraces.setitems(const index: integer; const avalue: ttrace);
begin
 inherited getitems(index).assign(avalue);
end;

function ttraces.getitems(const index: integer): ttrace;
begin
 result:= ttrace(inherited getitems(index));
end;

function ttraces.itembyname(const aname: string): ttrace;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fitems) do begin
  if ttrace(fitems[int1]).name = aname then begin
   result:= ttrace(fitems[int1]);
   break;
  end;
 end;
end;

procedure ttraces.setxserstart(const avalue: real);
var
 int1: integer;
begin
 fxserstart:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).xserstart:= avalue;
  end;
 end;
end;

procedure ttraces.setxstart(const avalue: real);
var
 int1: integer;
begin
 fxstart:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).xstart:= avalue;
  end;
 end;
end;

procedure ttraces.setystart(const avalue: real);
var
 int1: integer;
begin
 fystart:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).ystart:= avalue;
  end;
 end;
end;

procedure ttraces.setxserrange(const avalue: real);
var
 int1: integer;
begin
 fxserrange:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).xserrange:= avalue;
  end;
 end;
end;

procedure ttraces.setxrange(const avalue: real);
var
 int1: integer;
begin
 fxrange:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).xrange:= avalue;
  end;
 end;
end;

procedure ttraces.setyrange(const avalue: real);
var
 int1: integer;
begin
 fyrange:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).yrange:= avalue;
  end;
 end;
end;

procedure ttraces.setmaxcount(const avalue: integer);
var
 int1: integer;
begin
 fmaxcount:= avalue;
 if not (csloading in tcuchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).maxcount:= avalue;
  end;
 end;
end;

procedure ttraces.setkind(const avalue: tracekindty);
var
 int1: integer;
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  if not (csloading in tcuchart(fowner).componentstate) then begin
   for int1:= 0 to count - 1 do begin
    ttrace(fitems[int1]).kind:= avalue;
   end;
  end;
 end;
end;

procedure ttraces.setchartkind(const avalue: tracechartkindty);
var
 int1: integer;
begin
 if fchartkind <> avalue then begin
  fchartkind:= avalue;
  if not (csloading in tcuchart(fowner).componentstate) then begin
   for int1:= 0 to count - 1 do begin
    ttrace(fitems[int1]).chartkind:= avalue;
   end;
  end;
 end;
end;

procedure ttraces.setbar_width(const avalue: integer);
var
 int1: integer;
begin
 if fbar_width <> avalue then begin
  fbar_width:= avalue;
  if not (csloading in tcuchart(fowner).componentstate) then begin
   for int1:= 0 to count - 1 do begin
    ttrace(fitems[int1]).bar_width:= avalue;
   end;
  end;
 end;
end;

procedure ttraces.setbar_ref(const avalue: barrefty);
var
 int1: integer;
begin
 if fbar_ref <> avalue then begin
  fbar_ref:= avalue;
  if not (csloading in tcuchart(fowner).componentstate) then begin
   for int1:= 0 to count - 1 do begin
    ttrace(fitems[int1]).bar_ref:= avalue;
   end;
  end;
 end;
end;

procedure ttraces.setoptions(const avalue: charttraceoptionsty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}byte{$endif};
begin
 if foptions <> avalue then begin
  mask:= {$ifdef FPC}longword{$else}word{$endif}(avalue) xor
                 {$ifdef FPC}longword{$else}word{$endif}(foptions);
  foptions:= avalue;
  if not (csloading in tcuchart(fowner).componentstate) then begin
   for int1:= 0 to count - 1 do begin
    ttrace(fitems[int1]).options:= charttraceoptionsty(replacebits(
               {$ifdef FPC}longword{$else}word{$endif}(foptions),
               {$ifdef FPC}longword{$else}word{$endif}(
                                   ttrace(fitems[int1]).options),mask));
   end;
  end;
 end;
end;

procedure ttraces.createitem(const index: integer; var item: tpersistent);
begin
 inherited;
 with ttrace(item) do begin
  kind:= self.fkind;
  chartkind:= self.fchartkind;
  bar_width:= self.fbar_width;
  bar_ref:= self.fbar_ref;
  options:= self.foptions;
  xserstart:= self.fxserstart;
  xstart:= self.fxstart;
  ystart:= self.fystart;
  xserrange:= self.fxserrange;
  xrange:= self.fxrange;
  yrange:= self.fyrange;
  maxcount:= self.fmaxcount;
 end;
end;

procedure ttraces.assign(source: tpersistent);
begin
 if source is ttraces then begin
  with ttraces(source) do begin
   self.fxserstart:= fxserstart;
   self.fxstart:= fxstart;
   self.fystart:= fystart;
   self.fxserrange:= fxserrange;
   self.fxrange:= fxrange;
   self.fyrange:= fyrange;
   self.maxcount:= fmaxcount;
  end;
 end;
 inherited;
end;

procedure ttraces.setimage_list(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fimage_list));
 change;
end;

procedure ttraces.setimage_widthmm(const avalue: real);
begin
 fimage_widthmm:= avalue;
 change;
end;

procedure ttraces.setimage_heightmm(const avalue: real);
begin
 fimage_heightmm:= avalue;
 change;
end;

procedure ttraces.dostatread(const reader: tstatreader);
var
 int1: integer;
 mstr1: msestring;
begin
 for int1:= 0 to count - 1 do begin
  mstr1:= inttostr(int1);
  with ttrace(fitems[int1]) do begin
   if cto_savexscale in foptions then begin
    xstart:= reader.readreal('xstart'+mstr1,xstart);
    xrange:= reader.readreal('xrange'+mstr1,xrange);
   end;
   if cto_saveyscale in foptions then begin
    ystart:= reader.readreal('ystart'+mstr1,ystart);
    yrange:= reader.readreal('yrange'+mstr1,yrange);
   end;
  end;
 end;
end;

procedure ttraces.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
 mstr1: msestring;
begin
 for int1:= 0 to count - 1 do begin
  mstr1:= inttostr(int1);
  with ttrace(fitems[int1]) do begin
   if cto_savexscale in foptions then begin
    writer.writereal('xstart'+mstr1,xstart);
    writer.writereal('xrange'+mstr1,xrange);
   end;
   if cto_saveyscale in foptions then begin
    writer.writereal('ystart'+mstr1,ystart);
    writer.writereal('yrange'+mstr1,yrange);
   end;
  end;
 end;
end;

function ttraces.getlogx: boolean;
begin
 result:= cto_logx in options;
end;

procedure ttraces.setlogx(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [cto_logx];
 end
 else begin
  options:= options - [cto_logx];
 end;
end;

function ttraces.getlogy: boolean;
begin
 result:= cto_logy in options;
end;

procedure ttraces.setlogy(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [cto_logy];
 end
 else begin
  options:= options - [cto_logy];
 end;
end;

function ttraces.actualimagelist: timagelist;
begin
 result:= fimage_list;
 if (result = nil) and (cto_stockglyphs in foptions) then begin
  result:= stockobjects.glyphs;
 end;
end;

procedure ttraces.setdata(const adata: realararty);
var
 int1: integer;
begin
 for int1:= 0 to high(adata) do begin
  if int1 > high(fitems) then begin
   break;
  end;
  ttrace(fitems[int1]).ydata:= adata[int1];
 end;
end;

procedure ttraces.setdata(const adata: complexararty);
var
 int1: integer;
begin
 for int1:= 0 to high(adata) do begin
  if int1 > high(fitems) then begin
   break;
  end;
  ttrace(fitems[int1]).xydata:= adata[int1];
 end;
end;

{ tchartdialvert }

constructor tchartdialvert.create(const aintf: idialcontroller);
begin
 inherited create(aintf);
 direction:= gd_up;
end;

procedure tchartdialvert.setdirection(const avalue: graphicdirectionty);
begin
 if avalue in [gd_up,gd_down] then begin
  inherited;
 end;
end;

{ tchartdialhorz }

constructor tchartdialhorz.create(const aintf: idialcontroller);
begin
 inherited;
 direction:= gd_right;
end;

procedure tchartdialhorz.setdirection(const avalue: graphicdirectionty);
begin
 if avalue in [gd_right,gd_left] then begin
  inherited;
 end;
end;

{ tchartframe }

constructor tchartframe.create(const intf: iscrollframe; const owner: twidget);
begin
 inherited;
 fi.innerframe.left:= 0;
 fi.innerframe.top:= 0;
 fi.innerframe.right:= 1;
 fi.innerframe.bottom:= 1;
 fi.colorclient:= cl_foreground;
end;

{ tcuchart }

constructor tcuchart.create(aowner: tcomponent);
begin
 fcolorchart:= cl_foreground;
 fxrange:= 1;
 fyrange:= 1;
 fydials:= tchartdialsvert.create(ichartdialcontroller(self));
 fxdials:= tchartdialshorz.create(ichartdialcontroller(self));
{
 with fdialvert do begin
  direction:= gd_up;
  ticks.count:= 1;
  with ticks[0] do begin
   intervalcount:= 10;
   color:= cl_dkgray;
  end;
 end;
 with fdialhorz do begin
  direction:= gd_right;
  ticks.count:= 1;
  with ticks[0] do begin
   intervalcount:= 10;
   color:= cl_dkgray;
  end;
 end;
}
 inherited;
end;

destructor tcuchart.destroy;
begin
 fydials.free;
 fxdials.free;
 inherited;
end;

procedure tcuchart.clientrectchanged;
begin
 fxdials.changed;
 fydials.changed;
 chartchange;
 inherited;
end;
{
procedure tcuchart.dobeforepaint(const canvas: tcanvas);
var
 pt1: pointty;
begin
 inherited;
 if canevent(tmethod(fonbeforepaint)) then begin
  pt1:= clientwidgetpos;
  canvas.move(pt1);
  fonbeforepaint(self,canvas);
  canvas.remove(pt1);
 end;
end;
}

procedure tcuchart.dopaintcontent(const acanvas: tcanvas);
begin
 //dummy
end;

procedure tcuchart.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if not (chs_nocolorchart in fstate) and 
                 not (fcolorchart = container.frame.colorclient) then begin
  canvas.fillrect(innerclientrect,fcolorchart);
 end;
// if canevent(tmethod(fonpaintbackground)) then begin
//  fonpaintbackground(self,canvas);
// end;
end;
{
procedure tcuchart.doonpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,canvas);
 end;
end;

procedure tcuchart.doafterpaint(const canvas: tcanvas);
var
 pt1: pointty;
begin
 inherited;
 if canevent(tmethod(fonafterpaint)) then begin
  pt1:= clientwidgetpos;
  canvas.move(pt1);
  fonafterpaint(self,canvas);
  canvas.remove(pt1);
 end;
end;
}
procedure tcuchart.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fxdials.paint(acanvas);
 fydials.paint(acanvas);
 dopaintcontent(acanvas);
 fxdials.afterpaint(acanvas);
 fydials.afterpaint(acanvas);
end;

procedure tcuchart.setcolorchart(const avalue: colorty);
begin
 if fcolorchart <> avalue then begin
  fcolorchart:= avalue;
  changed;
 end;
end;

procedure tcuchart.setxdials(const avalue: tchartdialshorz);
begin
 fxdials.assign(avalue);
end;

procedure tcuchart.setydials(const avalue: tchartdialsvert);
begin
 fydials.assign(avalue);
end;

procedure tcuchart.directionchanged(const dir: graphicdirectionty;
               const dirbefore: graphicdirectionty);
begin
 //dummy
end;

function tcuchart.getdialrect: rectty;
begin
 result:= innerclientrect;
end;

function tcuchart.getdialsize: sizety;
begin
 result:= clientsize;
end;

procedure tcuchart.internalcreateframe;
begin
 tchartframe.create(iscrollframe(self),self);
end;

procedure tcuchart.changed;
begin
 invalidate;
end;

procedure tcuchart.defineproperties(filer: tfiler);
begin
 inherited;
end;

function tcuchart.getxstart: real;
begin
 result:= fxstart;
end;

procedure tcuchart.setxstart(const avalue: real);
begin
 fxstart:= avalue;
 fxdials.start:= avalue;
end;

function tcuchart.getystart: real;
begin
 result:= fystart;
end;

procedure tcuchart.setystart(const avalue: real);
begin
 fystart:= avalue;
 fydials.start:= avalue;
end;

function tcuchart.getxrange: real;
begin
 result:= fxrange;
end;

procedure tcuchart.setxrange(const avalue: real);
begin
 fxrange:= avalue;
 fxdials.range:= avalue;
end;

function tcuchart.getyrange: real;
begin
 result:= fyrange;
end;

procedure tcuchart.setyrange(const avalue: real);
begin
 fyrange:= avalue;
 fydials.range:= avalue;
end;

procedure tcuchart.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tcuchart.dostatread(const reader: tstatreader);
begin
 fxdials.dostatread(reader);
 fydials.dostatread(reader);
end;

procedure tcuchart.dostatwrite(const writer: tstatwriter);
begin
 fxdials.dostatwrite(writer);
 fydials.dostatwrite(writer);
end;

procedure tcuchart.statreading;
begin
 //dummy
end;

procedure tcuchart.statread;
begin
 //dummy
end;

function tcuchart.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcuchart.initscrollstate;
var
 int1: integer;
begin
 fshiftsum:= 0;
 fscrollsum:= 0;
 fsampleco:= 0;
 fstate:= fstate - [chs_hasdialscroll,chs_hasdialshift];
 for int1:= 0 to fxdials.count -1 do begin
  with fxdials[int1] do begin
   if do_scrollwithdata in options then begin
    include(self.fstate,chs_hasdialscroll);
   end;
   if do_shiftwithdata in options then begin
    self.fstate:= self.fstate + [chs_hasdialscroll,chs_hasdialshift];
   end;
   shift:= 0;
  end;
 end;
end;

procedure tcuchart.chartchange;
begin
 exclude(fstate,chs_chartvalid);
 invalidate;
end;

{ tcustomchart }

constructor tcustomchart.create(aowner: tcomponent);
begin
 if ftraces = nil then begin
  ftraces:= ttraces.create(self);
 end;
 inherited;
end;

destructor tcustomchart.destroy;
begin
 ftraces.free;
 inherited;
end;

procedure tcustomchart.clear;
var
 int1: integer;
begin
 initscrollstate;
 include(fstate,chs_chartvalid);
 for int1:= 0 to ftraces.count - 1 do begin
  ftraces[int1].clear;
 end;
end;

procedure tcustomchart.addsample(const asamples: array of real);
var
 int1: integer;
 rea1,rea2: real;
begin
 if not (chs_chartvalid in fstate) then begin
  initscrollstate;
  include(fstate,chs_chartvalid);
 end;
 int1:= high(asamples);
 if int1 >= ftraces.count then begin
  int1:= ftraces.count-1;
 end;
 for int1:= 0 to int1 do begin
  ttrace(ftraces.fitems[int1]).addxseriesdata(asamples[int1]);
 end;
 if chs_hasdialscroll in fstate then begin
  inc(fsampleco);
  if cto_adddataright in ftraces.options then begin
   int1:= 1;
  end
  else begin
   int1:= 0;
   if fsampleco >= ftraces.maxcount then begin
    int1:= fsampleco-ftraces.maxcount;
    fsampleco:= fsampleco - int1;
   end;
  end;
  if (int1 <> 0) and (ftraces.maxcount > 0) then begin
   fscrollsum:= fscrollsum + int1;
   fshiftsum:= fshiftsum + int1;
   rea1:= (fshiftsum)/ftraces.maxcount;
   if fscrollsum > ftraces.maxcount then begin
    fscrollsum:= fscrollsum - ftraces.maxcount;
   end;
   rea2:= (fscrollsum)/ftraces.maxcount;
   for int1:= 0 to fxdials.count - 1 do begin
    with fxdials[int1] do begin
     if do_shiftwithdata in options then begin
      shift:= rea1*range;
     end
     else begin
      shift:= rea2*range;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomchart.settraces(const avalue: ttraces);
begin
 ftraces.assign(avalue);
end;

procedure tcustomchart.clientrectchanged;
begin
 ftraces.clientrectchanged;
 inherited;
end;

procedure tcustomchart.dopaintcontent(const acanvas: tcanvas);
var
 rect1: rectty;
begin
 inherited;
 acanvas.save;
 rect1:= innerclientrect;
 inc(rect1.cx);
 inc(rect1.cy);
 acanvas.intersectcliprect(rect1);
 acanvas.move(innerclientpos);
 ftraces.paint(acanvas);
 acanvas.restore;
// acanvas.remove(innerclientpos);
end;

procedure tcustomchart.setxstart(const avalue: real);
begin
 inherited;
 ftraces.xstart:= avalue;
 fxdials.start:= avalue;
end;

procedure tcustomchart.setystart(const avalue: real);
begin
 inherited;
 ftraces.ystart:= avalue;
 fydials.start:= avalue;
end;

procedure tcustomchart.setxrange(const avalue: real);
begin
 inherited;
 ftraces.xrange:= avalue;
 fxdials.range:= avalue;
end;

procedure tcustomchart.setyrange(const avalue: real);
begin
 inherited;
 ftraces.yrange:= avalue;
 fydials.range:= avalue;
end;

procedure tcustomchart.dostatread(const reader: tstatreader);
begin
 inherited;
 ftraces.dostatread(reader);
end;

procedure tcustomchart.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 ftraces.dostatwrite(writer);
end;

function calcrange(var min: real; const max: real): real;
begin
 result:= max-min;
 if result = 0 then begin
  result:= min;
  if result = 0 then begin
   result:= 1;
  end;
  min:= min - result / 2;
 end;
end;

procedure tcustomchart.autoscalex(const astart: real = 0;
                                                      const arange: real = 1);
var
 rea1,rea2: real;
 min,max,ra: real; 
 int1: integer;
begin
 min:= bigreal;
 max:= -bigreal;
 for int1:= 0 to traces.count - 1 do begin
  with traces[int1] do begin
   minmaxx(rea1,rea2);
   if rea1 < min then begin
    min:= rea1;
   end;
   if rea2 > max then begin
    max:= rea2;
   end;
  end;
 end;
 ra:= calcrange(min,max);
 xstart:= min;
 xrange:= ra;
end;

procedure tcustomchart.autoscaley(const astart: real = 0;
                                                      const arange: real = 1);
var
 rea1,rea2: real;
 min,max,ra: real; 
 int1: integer;
begin
 min:= bigreal;
 max:= -bigreal;
 for int1:= 0 to traces.count - 1 do begin
  with traces[int1] do begin
   minmaxy(rea1,rea2);
   if rea1 < min then begin
    min:= rea1;
   end;
   if rea2 > max then begin
    max:= rea2;
   end;
  end;
 end;
 ra:= calcrange(min,max);
 ystart:= min;
 yrange:= ra;
end;

{ trecordertraces }

constructor trecordertraces.create;
begin
 inherited create(trecordertrace);
end;

class function trecordertraces.getitemclasstype: persistentclassty;
begin
 result:= trecordertrace;
end;

{ trecordertrace }

constructor trecordertrace.create;
begin
 frange:= 1;
 fcolor:= cl_glyph;
 inherited;
end;

procedure trecordertrace.setrange(const avalue: real);
begin
 checknullrange(avalue);
 frange:= avalue;
end;

{ tchartrecorder }

constructor tchartrecorder.create(aowner: tcomponent);
begin
 fsamplecount:= 100;
 fchart:= tmaskedbitmap.create(false);
 ftraces:= trecordertraces.create;
 inherited;
 include(fstate,chs_nocolorchart);
end;

destructor tchartrecorder.destroy;
begin
 fchart.free;
 ftraces.free;
 inherited;
end;
{
procedure tchartrecorder.clientrectchanged;
begin
 chartchange;
 inherited;
end;
}
procedure tchartrecorder.checkinit;
var
 int1: integer;
 bo1: boolean;
begin
 if not (csloading in componentstate) and not (chs_chartvalid in fstate) then begin
  fstate:= fstate - chartrecorderstatesmask;
//  fstarted:= false;
  bo1:= false;
  initscrollstate;
  for int1:= 0 to fxdials.count -1 do begin
   with fxdials[int1] do begin
    if not (do_front in options) then begin
     bo1:= true;
    end;
   end;
  end;
  if not bo1 then begin
   for int1:= 0 to fydials.count -1 do begin
    if not (do_front in fydials[int1].options) then begin
     bo1:= true;
     break;
    end;
   end;
  end;
  with fchart do begin
   masked:= bo1;
   fchartclientrect:= innerclientrect;
   fchartwindowrect.size:= fchartclientrect.size;
   fchartrect.cx:= fchartclientrect.cx + 10; //room for linewidth
   fchartrect.cy:= fchartclientrect.cy;
   size:= fchartrect.size; 
   fstep:= {$ifdef FPC}real({$endif}fchartwindowrect.cx{$ifdef FPC}){$endif} / 
                                                                  fsamplecount;
   fstepsum:= 0;
   fxref:= fchartwindowrect.x;
   if cro_adddataright in foptions then begin
    include(fstate,chs_full);
   end;
   init(fcolorchart);
   canvas.capstyle:= cs_round;
   if masked then begin
    mask.init(cl_0);
    mask.canvas.capstyle:= cs_round;
   end;
  end;
  include(fstate,chs_chartvalid);
 end;
end;

procedure tchartrecorder.dopaintcontent(const acanvas: tcanvas);
begin
 checkinit;
 fchart.paint(acanvas,fchartclientrect.pos);
// canvas.copyarea(fchart.canvas,fchartwindowrect,fchartclientrect.pos);
end;

procedure tchartrecorder.setsamplecount(const avalue: integer);
begin
 if fsamplecount <> avalue then begin
  fsamplecount:= avalue;
  if fsamplecount <= 0 then begin
   fsamplecount:=  1;
  end;
  chartchange;
 end;  
end;

procedure tchartrecorder.addsample(const asamples: array of real);
var
 acanvas,mcanvas: tcanvas;
 amasked: boolean;
 
  procedure shift(const adist: integer);
  begin
   fshiftsum:= fshiftsum+adist;
   fscrollsum:= fscrollsum+adist;
   acanvas.copyarea(acanvas,fchartrect,makepoint(-adist,0));
   acanvas.fillrect(makerect(fchartrect.cx-adist,0,adist,fchartrect.cy),fcolorchart);
   if amasked then begin
    mcanvas.copyarea(mcanvas,fchartrect,makepoint(-adist,0));
    mcanvas.fillrect(makerect(fchartrect.cx-adist,0,adist,fchartrect.cy),cl_0);
   end;
  end; //shift

var
 int1,int2: integer;
 startx,endx,y: integer;
 rea1,rea2: real;
begin
 if (chs_hasdialshift in fstate) and (fshiftsum < 0) then begin
  exclude(fstate,chs_chartvalid);
 end;
 checkinit;
 fstepsum:= fstepsum + fstep;
 int1:= round(fstepsum);
 fstepsum:= fstepsum - int1;
 with fchart do begin
  acanvas:= canvas;
  amasked:= masked;
  if amasked then begin
   mcanvas:= mask.canvas;
  end;
 end;
 if chs_full in fstate then begin
  startx:= fchartwindowrect.cx-int1;
  endx:= fchartwindowrect.cx;
  shift(int1);
 end
 else begin
  startx:= fxref;
  fxref:= fxref+int1;
  endx:= fxref;
  int1:= endx-fchartwindowrect.cx;
  if int1 >= 0 then begin
   if int1 <> 0 then begin //should not happen
    shift(int1);
    startx:= startx-int1;
    endx:= endx-int1;
   end;
   include(fstate,chs_full);
  end;
 end;
 if (chs_hasdialscroll in fstate) and (fchartwindowrect.cx > 0) then begin
  rea1:= fshiftsum/fchartwindowrect.cx;
  if fscrollsum > fchartwindowrect.cx then begin
   fscrollsum:= fscrollsum - fchartwindowrect.cx;
  end;
  rea2:= fscrollsum/fchartwindowrect.cx;
  for int1:= 0 to fxdials.count -1 do begin
   with fxdials[int1] do begin
    if do_shiftwithdata in options then begin
     shift:= rea1*range;
    end
    else begin
     shift:= rea2*range;
    end;
   end;
  end;
 end;
 int1:= high(asamples);
 if int1 > high(ftraces.fitems) then begin
  int1:= high(ftraces.fitems);
 end;
 for int2:= 0 to int1 do begin
  with trecordertrace(ftraces.fitems[int2]) do begin
   y:= fchartrect.cy - round(fchartrect.cy * ((asamples[int2] - fstart)/frange));
   if chs_started in fstate then begin
    acanvas.linewidth:= fwidth;
    acanvas.drawline(makepoint(startx,fybefore),makepoint(endx,y),fcolor);
    if amasked then begin
     mcanvas.linewidth:= fwidth;
     mcanvas.drawline(makepoint(startx,fybefore),makepoint(endx,y),cl_1);
    end;
   end;
   fybefore:= y;
  end;
 end;
 invalidaterect(fchartclientrect);
 include(fstate,chs_started);
end;

procedure tchartrecorder.settraces(const avalue: trecordertraces);
begin
 ftraces.assign(avalue);
end;

procedure tchartrecorder.clear;
begin
 exclude(fstate,chs_chartvalid);
 invalidate;
end;
{
procedure tchartrecorder.changed;
begin
 fchartvalid:= false;
 inherited;
end;
}
{ tchartdialshorz }

function tchartdialshorz.getitemclass: dialcontrollerclassty;
begin
 result:= tchartdialhorz;
end;

procedure tchartdialshorz.setitems(const aindex: integer;
               const avalue: tchartdialhorz);
begin
 getitems(aindex).assign(avalue);
end;

function tchartdialshorz.getitems(const aindex: integer): tchartdialhorz;
begin
 result:= tchartdialhorz(inherited getitems(aindex));
end;

procedure tchartdialshorz.createitem(const index: integer;
               var item: tpersistent);
begin
 inherited;
 with tchartdialhorz(item) do begin
  start:= ichartdialcontroller(fintf).getxstart;
  range:= ichartdialcontroller(fintf).getxrange;
 end;
end;

class function tchartdialshorz.getitemclasstype: persistentclassty;
begin
 result:= tchartdialhorz;
end;

{ tchartdialsvert }

function tchartdialsvert.getitemclass: dialcontrollerclassty;
begin
 result:= tchartdialvert;
end;

procedure tchartdialsvert.setitems(const aindex: integer;
               const avalue: tchartdialvert);
begin
 getitems(aindex).assign(avalue);
end;

function tchartdialsvert.getitems(const aindex: integer): tchartdialvert;
begin
 result:= tchartdialvert(inherited getitems(aindex));
end;

procedure tchartdialsvert.createitem(const index: integer;
               var item: tpersistent);
begin
 inherited;
 with tchartdialvert(item) do begin
  start:= ichartdialcontroller(fintf).getystart;
  range:= ichartdialcontroller(fintf).getyrange;
 end;
end;

class function tchartdialsvert.getitemclasstype: persistentclassty;
begin
 result:= tchartdialvert;
end;

{ tchartdials }

procedure tchartdials.changed;
var
 int1: integer;
begin
 for int1:= high(fitems) downto 0 do begin
  tcustomdialcontroller1(fitems[int1]).changed;
 end;
end;

procedure tchartdials.paint(const acanvas: tcanvas);
var
 int1: integer;
begin
 for int1:= high(fitems) downto 0 do begin
  tcustomdialcontroller(fitems[int1]).paint(acanvas);
 end;
end;

procedure tchartdials.afterpaint(const acanvas: tcanvas);
var
 int1: integer;
begin
 for int1:= high(fitems) downto 0 do begin
  tcustomdialcontroller(fitems[int1]).afterpaint(acanvas);
 end;
end;

constructor tchartdials.create(const aintf: ichartdialcontroller);
begin
 inherited create(aintf);
end;

{ txytrace }

constructor txytrace.create(aowner: tobject);
begin
 inherited;
end;

procedure txytrace.setoptions(const avalue: charttraceoptionsty);
begin
 if txytraces(ftraces).fxordered then begin
  inherited setoptions(avalue + [cto_xordered]);
 end
 else begin
  inherited;
 end;
end;

procedure txytrace.setkind(const avalue: tracekindty);
begin
 inherited setkind(trk_xy);
end;

{ txytraces }

constructor txytraces.create(const aowner: tcustomchart; const axordered: boolean);
begin
 fxordered:= axordered;
 inherited create(aowner);
 kind:= trk_xy;
 options:= defaultxytraceoptions;
end;

class function txytraces.getitemclasstype: persistentclassty;
begin
 result:= txytrace;
end;

procedure txytraces.setoptions(const avalue: charttraceoptionsty);
begin
 if fxordered then begin
  inherited setoptions(avalue + [cto_xordered]);
 end
 else begin
  inherited;
 end;
end;

procedure txytraces.setkind(const avalue: tracekindty);
begin
 inherited setkind(trk_xy);
end;

{ tbarframe }

constructor tbarframe.create(const intf: iframe);
begin
 inherited;
 include(fstate,fs_nowidget);
end;

end.
