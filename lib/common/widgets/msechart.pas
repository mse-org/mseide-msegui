{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

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
 msegraphutils,
 msewidgets,msesimplewidgets,msedial,msebitmap,msemenus,mseevent,
 msedatalist;
 
type
 tcustomchart = class;
 tracestatety = (trs_datapointsvalid);
 tracestatesty = set of tracestatety;
 tracekindty = (trk_xseries,trk_xy);

 charttraceoptionty = (cto_adddataright,
                       cto_xordered //optimize for big data quantity
                       );
 charttraceoptionsty = set of charttraceoptionty;

 datapointty = record
  first,min,max,last: integer;
  used: boolean;
 end;
 datapointarty = array of datapointty;

 traceinfoty = record
  xdata: realarty;
  ydata: realarty;
  xydata: complexarty;
  xdatalist: trealdatalist;
  ydatalist: trealdatalist;
  state: tracestatesty;
  datapoints: pointarty;
  bottommargin,topmargin: integer;
  color: colorty;
  colorimage: colorty;
  xrange: real;
  xstart: real;
  yrange: real;
  ystart: real;
  kind: tracekindty;
  maxcount: integer;
  widthmm: real;
  dashes: string;
  options: charttraceoptionsty;
  start: integer;
  imagenr: imagenrty;
  name: string;
 end;

 ttraces = class;
   
 ttrace = class(townedeventpersistent,iimagelistinfo)
  private
   finfo: traceinfoty;
   procedure setxydata(const avalue: complexarty);
   procedure datachange;
   procedure setcolor(const avalue: colorty);
   procedure setcolorimage(const avalue: colorty);
   procedure setxrange(const avalue: real);
   procedure setxstart(const avalue: real);
   procedure setyrange(const avalue: real);
   procedure setystart(const avalue: real);
   procedure scaleerror;
   procedure setxdata(const avalue: realarty);
   procedure setydata(const avalue: realarty);
   procedure setkind(const avalue: tracekindty);
   procedure setmaxcount(const avalue: integer);
   procedure setwidthmm(const avalue: real);
   procedure setdashes(const avalue: string);
   procedure setoptions(const avalue: charttraceoptionsty);
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
  protected
   ftraces: ttraces;
   procedure checkgraphic;
   procedure paint(const acanvas: tcanvas);
   procedure paint1(const acanvas: tcanvas; const imagesize: sizety;
                        const imagealignment: alignmentsty);
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tobject); override;
   procedure addxseriesdata(const avalue: real);
   procedure assign(source: tpersistent); override;
   property xdata: realarty read finfo.ydata write setxdata;
   property ydata: realarty read finfo.ydata write setydata;
   property xydata: complexarty read finfo.xydata write setxydata;
   property xdatalist: trealdatalist read finfo.xdatalist write setxdatalist;
   property ydatalist: trealdatalist read finfo.ydatalist write setydatalist;
   
  published
   property color: colorty read finfo.color write setcolor default cl_black;
   property colorimage: colorty read finfo.colorimage 
                      write setcolorimage default cl_default;
   property widthmm: real read finfo.widthmm write setwidthmm;   //default 0.3
   property dashes: string read finfo.dashes write setdashes;
   property xrange: real read finfo.xrange write setxrange;      //default 1.0
   property xstart: real read finfo.xstart write setxstart;
   property yrange: real read finfo.yrange write setyrange;      //default 1.0
   property ystart: real read finfo.ystart write setystart;
   property kind: tracekindty read finfo.kind write setkind default trk_xseries;
   property start: integer read finfo.start write setstart default 0;
   property maxcount: integer read finfo.maxcount write setmaxcount default 0;
                      //0-> data count
   property options: charttraceoptionsty read finfo.options write setoptions default [];
   property imagenr: imagenrty read finfo.imagenr write setimagenr default -1;
   property name: string read finfo.name write finfo.name;
 end;

 traceaty = array[0..0] of ttrace;
 ptraceaty = ^traceaty;
 
 tracesstatety = (trss_graphicvalid);
 tracesstatesty = set of tracesstatety;
 tchart = class;
   
 ttraces = class(townedeventpersistentarrayprop)
  private
   ftracestate: tracesstatesty;
   fxstart: real;
   fystart: real;
   fxrange: real;
   fyrange: real;
   fimage_list: timagelist;
   fimage_widthmm: real;
   fimage_heightmm: real;
   procedure setitems(const index: integer; const avalue: ttrace);
   function getitems(const index: integer): ttrace;
   procedure setxstart(const avalue: real);
   procedure setystart(const avalue: real);
   procedure setxrange(const avalue: real);
   procedure setyrange(const avalue: real);
   procedure setimage_list(const avalue: timagelist);
   procedure setimage_widthmm(const avalue: real);
   procedure setimage_heightmm(const avalue: real);
  protected
   fsize: sizety;
   fscalex: real;
   fscaley: real;
   procedure change; reintroduce;
   procedure clientrectchanged;
   procedure paint(const acanvas: tcanvas);
   procedure checkgraphic;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomchart); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   function itembyname(const aname: string): ttrace;
   procedure assign(source: tpersistent); override;
   property items[const index: integer]: ttrace read getitems write setitems; default;
  published
   property xstart: real read fxstart write setxstart;
   property ystart: real read fystart write setystart;
   property xrange: real read fxrange write setxrange;
   property yrange: real read fyrange write setyrange;
     //properties not used in asssign below
   property image_list: timagelist read fimage_list write setimage_list;
   property image_widthmm: real read fimage_widthmm write setimage_widthmm;
   property image_heighthmm: real read fimage_heightmm write setimage_heightmm;
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
   property options;
 end;
 
 tchartdialhorz = class(tcustomdialcontroller)
  protected
   procedure setdirection(const avalue: graphicdirectionty); override;
  public
   constructor create(const aintf: idialcontroller); override;
  published
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
   property options;
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
 
 chartstatety = (chs_nocolorchart);
 chartstatesty = set of chartstatety;
 
 tcustomchart = class(tscrollbox,ichartdialcontroller)
  private
   fxdials: tchartdialshorz;
   fydials: tchartdialsvert;
   fxstart: real;
   fystart: real;
   fxrange: real;
   fyrange: real;
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
  protected
   fcolorchart: colorty;
   fstate: chartstatesty;
   procedure changed; virtual;
   procedure clientrectchanged; override;
   procedure dopaintbackground(const canvas: tcanvas); override;
   procedure dopaint(const acanvas: tcanvas); override;
          //idialcontroller
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
   function getdialsize: sizety;
   procedure internalcreateframe; override;
   procedure defineproperties(filer: tfiler); override;
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
 end;

 tchart = class(tcustomchart)
  private
   ftraces: ttraces;
   procedure settraces(const avalue: ttraces);
   procedure setxstart(const avalue: real); override;
   procedure setystart(const avalue: real); override;
   procedure setxrange(const avalue: real); override;
   procedure setyrange(const avalue: real); override;
  protected
   procedure clientrectchanged; override;
   procedure dopaint(const acanvas: tcanvas); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property traces: ttraces read ftraces write settraces;
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

 trecordertrace = class(tvirtualpersistent)
  private
   fybefore: integer;
   foffset: real;
   frange: real;
   fcolor: colorty;
   fwidth: integer;
   procedure setrange(const avalue: real);
  public
   constructor create; override;
  published
   property offset: real read foffset write foffset;
   property range: real read frange write setrange;
   property color: colorty read fcolor write fcolor default cl_glyph;
   property width: integer read fwidth write fwidth default 0;
 end;

 trecordertraces = class(tpersistentarrayprop)
  public
   constructor create;
   class function getitemclasstype: persistentclassty; override;
 end;
  
 tchartrecorder = class(tcustomchart)
  private
   fchart: tbitmap;
   fsamplecount: integer;
   fstep: real;
   fstepsum: real;
   fchartrect: rectty;
   fchartclientrect: rectty;
   fchartwindowrect: rectty;
   ftraces: trecordertraces;
   fstarted: boolean;
   procedure setsamplecount(const avalue: integer);
   procedure settraces(const avalue: trecordertraces);
  protected
   procedure initchart;
   procedure changed; override;
   procedure clientrectchanged; override;
   procedure dobeforepaintforeground(const canvas: tcanvas); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure addsample(const asamples: array of real);
   procedure clear;
  published
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
                   
implementation
uses
 sysutils,math;

type
 tcustomdialcontroller1 = class(tcustomdialcontroller);

function autointerval(const arange: real; const aintervalcount: real): real;
                   //returns apropropriate 1/2/5 value
var
 rea1: real;
 rea2: real;
 int1: integer;
 scale: real;
begin
 rea1:= abs(arange/aintervalcount);
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
 ftraces:= tchart(aowner).ftraces;
 finfo.color:= cl_black;
 finfo.colorimage:= cl_default;
 finfo.widthmm:= 0.3;
 finfo.xrange:= 1.0;
 finfo.yrange:= 1.0;
 finfo.imagenr:= -1;
 inherited;
end;

procedure ttrace.datachange;
begin
 exclude(finfo.state,trs_datapointsvalid);
 tchart(fowner).traces.change;
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
  if avalue > $7fff then begin
   result:= $7fff;
  end
  else begin
   if avalue < -$8000 then begin
    result:= -$8000;
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
 xo,xs,yo,ys: real;
 rea1: real;
 ar1: datapointarty;
 dpcountx,dpcounty,dpcountxy: integer;
 xbottom,xtop: integer;
 isxseries: boolean;
 dpcounty1: integer;
 
begin
 if not (trs_datapointsvalid in finfo.state) then begin
  dpcountx:= 0;
  dpcounty:= 0;
  with finfo do begin
   isxseries:= (kind = trk_xseries);
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
  yo:= -finfo.ystart - finfo.yrange;
  ys:= -tchart(fowner).traces.fscaley / finfo.yrange;
  case finfo.kind of
   trk_xy,trk_xseries: begin     
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
     xo:= (rea1 - finfo.xstart) * int2;
     xs:= tchart(fowner).traces.fscalex;
     if int2 > 0 then begin
      xs:= xs / (finfo.xrange * int2);
     end;
     xo:= xo + 1/xs;
    end
    else begin
     xo:= -finfo.xstart;
     xs:= tchart(fowner).traces.fscalex / finfo.xrange;
    end;
    checkrange(dpcountxy);
    if (cto_xordered in finfo.options) or isxseries then begin
     int4:= tchart(fowner).traces.fsize.cx+2;
     setlength(ar1,int4);
     dec(int4);
     xbottom:= minint;
     xtop:= maxint;
     for int1:= 0 to dpcountxy - 1 do begin
      if isxseries then begin
       int2:= round((int1 + xo)* xs);
      end
      else begin
       int2:= pkround((preal(pox)^ + xo)* xs) + 1;
      end;
      int3:= pkround((preal(poy)^ + yo)* ys);
      if int2 < 0 then begin
       if int2 > xbottom then begin
        xbottom:= int2;
       end;
       int2:= 0;
      end;
      if int2 > int4 then begin
       if inty < xtop then begin
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
     with finfo do begin //adjust boundary values 
                         //todo: extend window for image size
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
    else begin
     setlength(finfo.datapoints,dpcountxy);
     for int1:= 0 to high(finfo.datapoints) do begin
      finfo.datapoints[int1].x:= pkround((preal(pox)^ + xo)* xs);
      finfo.datapoints[int1].y:= pkround((preal(poy)^ + yo)* ys);
      inc(pox,intx);
      inc(poy,inty);
     end;
    end;
   end;
(*
   else begin //trk_xseries
    checkrange(dpcounty);
    setlength(finfo.datapoints,dpcounty);
    if high(finfo.datapoints) >= 0 then begin
     rea1:= 0;
     if maxcount > 1 then begin
      int2:= maxcount - 1;
      if (int2 > high(finfo.datapoints)) and 
                       (cto_adddataright in finfo.options) then begin
       rea1:= {$ifdef FPC}real({$endif}1.0{$ifdef FPC}){$endif} - 
                                                high(finfo.datapoints) / int2;
      end;
     end
     else begin
      int2:= high(finfo.datapoints);
     end;
     xo:= (rea1 + finfo.xstart) * int2;
     xs:= tchart(fowner).traces.fscalex;
     if int2 > 0 then begin
      xs:= xs / (finfo.xrange * int2);
     end;
     for int1:= 0 to high(finfo.datapoints) do begin
      finfo.datapoints[int1].x:= round((int1 + xo)* xs);
      finfo.datapoints[int1].y:= round((preal(poy)^ + yo)* ys);
      inc(poy,inty);
     end;
    end;
   end;
*)
  end;
  include(finfo.state,trs_datapointsvalid);
 end;
end;

procedure ttrace.paint(const acanvas: tcanvas);
begin
 if finfo.widthmm > 0 then begin
  acanvas.linewidthmm:= finfo.widthmm;
  if finfo.dashes <> '' then begin
   acanvas.dashes:= finfo.dashes;
  end;
  acanvas.capstyle:= cs_round;
  acanvas.joinstyle:= js_round;
  acanvas.drawlines(finfo.datapoints,false,finfo.color);
  acanvas.capstyle:= cs_butt;
  acanvas.joinstyle:= js_miter;
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
 margin: integer;
begin
 with ftraces do begin
  if (fimage_list <> nil) and (finfo.imagenr >= 0) and 
                                    (finfo.imagenr < fimage_list.count) then begin
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
    bmp1:= tmaskedbitmap.create(fimage_list.monochrome);
    bmp2:= tmaskedbitmap.create(false);
    try
     bmp1.masked:= fimage_list.masked;
     fimage_list.getimage(finfo.imagenr,bmp1);
     bmp1.colorforeground:= co1;
     bmp1.colorbackground:= tcustomchart(fowner).colorchart;
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
     fimage_list.paint(acanvas,finfo.imagenr,rect1,imagealignment,co1);
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
  tchart(fowner).traces.change;
 end;
end;

procedure ttrace.setcolorimage(const avalue: colorty);
begin
 if finfo.colorimage <> avalue then begin
  finfo.colorimage:= avalue;
  tchart(fowner).traces.change;
 end;
end;

procedure ttrace.setwidthmm(const avalue: real);
begin
 finfo.widthmm:= avalue;
 tchart(fowner).traces.change;
end;

procedure ttrace.setdashes(const avalue: string);
begin
 finfo.dashes:= avalue;
 tchart(fowner).traces.change;
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
  finfo.options:= avalue;
  datachange;
 end;
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
 result:= ftraces.fimage_list;
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

{ ttraces }

constructor ttraces.create(const aowner: tcustomchart);
begin
 fxrange:= 1;
 fyrange:= 1;
 inherited create(aowner,ttrace);
end;

class function ttraces.getitemclasstype: persistentclassty;
begin
 result:= ttrace;
end;

procedure ttraces.change;
begin 
 exclude(ftracestate,trss_graphicvalid);
 tcustomchart(fowner).invalidate;
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
begin
 checkgraphic;
 for int1:= 0 to high(fitems) do begin
  ptraceaty(fitems)^[int1].paint(acanvas);
 end;
 align1:= [];
 size1:= nullsize;
 if fimage_list <> nil then begin
  size1:= fimage_list.size;
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

procedure ttraces.setxstart(const avalue: real);
var
 int1: integer;
begin
 fxstart:= avalue;
 if not (csloading in tcustomchart(fowner).componentstate) then begin
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
 if not (csloading in tcustomchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).ystart:= avalue;
  end;
 end;
end;

procedure ttraces.setxrange(const avalue: real);
var
 int1: integer;
begin
 fxrange:= avalue;
 if not (csloading in tcustomchart(fowner).componentstate) then begin
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
 if not (csloading in tcustomchart(fowner).componentstate) then begin
  for int1:= 0 to high(fitems) do begin
   ttrace(fitems[int1]).yrange:= avalue;
  end;
 end;
end;

procedure ttraces.createitem(const index: integer; var item: tpersistent);
begin
 inherited;
 with ttrace(item) do begin
  xstart:= self.fxstart;
  ystart:= self.fystart;
  xrange:= self.fxrange;
  yrange:= self.fyrange;
 end;
end;

procedure ttraces.assign(source: tpersistent);
begin
 if source is ttraces then begin
  with ttraces(source) do begin
   self.fxstart:= fxstart;
   self.fystart:= fystart;
   self.fxrange:= fxrange;
   self.fyrange:= fyrange;
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

{ tcustomchart }

constructor tcustomchart.create(aowner: tcomponent);
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

destructor tcustomchart.destroy;
begin
 fydials.free;
 fxdials.free;
 inherited;
end;

procedure tcustomchart.clientrectchanged;
begin
 fxdials.changed;
 fydials.changed;
 inherited;
end;
{
procedure tcustomchart.dobeforepaint(const canvas: tcanvas);
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

procedure tcustomchart.dopaintbackground(const canvas: tcanvas);
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
procedure tcustomchart.doonpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,canvas);
 end;
end;

procedure tcustomchart.doafterpaint(const canvas: tcanvas);
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
procedure tcustomchart.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fxdials.paint(acanvas);
 fydials.paint(acanvas);
 fxdials.afterpaint(acanvas);
 fydials.afterpaint(acanvas);
end;

procedure tcustomchart.setcolorchart(const avalue: colorty);
begin
 if fcolorchart <> avalue then begin
  fcolorchart:= avalue;
  changed;
 end;
end;

procedure tcustomchart.setxdials(const avalue: tchartdialshorz);
begin
 fxdials.assign(avalue);
end;

procedure tcustomchart.setydials(const avalue: tchartdialsvert);
begin
 fydials.assign(avalue);
end;

procedure tcustomchart.directionchanged(const dir: graphicdirectionty;
               const dirbefore: graphicdirectionty);
begin
 //dummy
end;

function tcustomchart.getdialrect: rectty;
begin
 result:= innerclientrect;
end;

function tcustomchart.getdialsize: sizety;
begin
 result:= clientsize;
end;

procedure tcustomchart.internalcreateframe;
begin
 tchartframe.create(iscrollframe(self),self);
end;

procedure tcustomchart.changed;
begin
 invalidate;
end;

procedure tcustomchart.defineproperties(filer: tfiler);
begin
 inherited;
end;

function tcustomchart.getxstart: real;
begin
 result:= fxstart;
end;

procedure tcustomchart.setxstart(const avalue: real);
begin
 fxstart:= avalue;
 fxdials.start:= avalue;
end;

function tcustomchart.getystart: real;
begin
 result:= fystart;
end;

procedure tcustomchart.setystart(const avalue: real);
begin
 fystart:= avalue;
 fydials.start:= avalue;
end;

function tcustomchart.getxrange: real;
begin
 result:= fxrange;
end;

procedure tcustomchart.setxrange(const avalue: real);
begin
 fxrange:= avalue;
 fxdials.range:= avalue;
end;

function tcustomchart.getyrange: real;
begin
 result:= fyrange;
end;

procedure tcustomchart.setyrange(const avalue: real);
begin
 fyrange:= avalue;
 fydials.range:= avalue;
end;

{ tchart }

constructor tchart.create(aowner: tcomponent);
begin
 ftraces:= ttraces.create(self);
 inherited;
end;

destructor tchart.destroy;
begin
 ftraces.free;
 inherited;
end;

procedure tchart.settraces(const avalue: ttraces);
begin
 ftraces.assign(avalue);
end;

procedure tchart.clientrectchanged;
begin
 ftraces.clientrectchanged;
 inherited;
end;

procedure tchart.dopaint(const acanvas: tcanvas);
begin
 inherited;
 acanvas.save;
 acanvas.intersectcliprect(innerclientrect);
 acanvas.move(innerclientpos);
 ftraces.paint(acanvas);
 acanvas.restore;
// acanvas.remove(innerclientpos);
end;

procedure tchart.setxstart(const avalue: real);
begin
 inherited;
 ftraces.xstart:= avalue;
 fxdials.start:= avalue;
end;

procedure tchart.setystart(const avalue: real);
begin
 inherited;
 ftraces.ystart:= avalue;
 fydials.start:= avalue;
end;

procedure tchart.setxrange(const avalue: real);
begin
 inherited;
 ftraces.xrange:= avalue;
 fxdials.range:= avalue;
end;

procedure tchart.setyrange(const avalue: real);
begin
 inherited;
 ftraces.yrange:= avalue;
 fydials.range:= avalue;
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
 fchart:= tbitmap.create(false);
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

procedure tchartrecorder.clientrectchanged;
begin
 inherited;
 initchart;
end;

procedure tchartrecorder.initchart;
begin
 if not (csloading in componentstate) then begin
  fstarted:= false;
  with fchart do begin
   fchartclientrect:= innerclientrect;
   fchartwindowrect.size:= fchartclientrect.size;
   fchartrect.cx:= fchartclientrect.cx + 10; //room for linewidth
   fchartrect.cy:= fchartclientrect.cy;
   size:= fchartrect.size; 
   fstep:= {$ifdef FPC}real({$endif}fchartwindowrect.cx{$ifdef FPC}){$endif} / fsamplecount;
   fstepsum:= 0;
   init(fcolorchart);
   canvas.capstyle:= cs_round;
  end;
 end;
end;

procedure tchartrecorder.dobeforepaintforeground(const canvas: tcanvas);
begin
 canvas.copyarea(fchart.canvas,fchartwindowrect,fchartclientrect.pos);
end;

procedure tchartrecorder.setsamplecount(const avalue: integer);
begin
 if fsamplecount <> avalue then begin
  fsamplecount:= avalue;
  if fsamplecount <= 0 then begin
   fsamplecount:=  1;
  end;
  initchart;
 end;  
end;

procedure tchartrecorder.addsample(const asamples: array of real);
var
 int1,int2: integer;
 ax,ay: integer;
 acanvas: tcanvas;
begin
 fstepsum:= fstepsum + fstep;
 int1:= round(fstepsum);
 fstepsum:= fstepsum - int1;
 with fchart do begin
  acanvas:= canvas;
  ax:= fchartwindowrect.cx-int1;
  acanvas.copyarea(canvas,fchartrect,makepoint(-int1,0));
  acanvas.fillrect(makerect(fchartrect.cx-int1,0,int1,fchartrect.cy),fcolorchart);
  for int2:= 0 to high(ftraces.fitems) do begin
   if int2 > high(asamples) then begin
    break;
   end;
   with trecordertrace(ftraces.fitems[int2]) do begin
    ay:= fchartrect.cy - round(fchartrect.cy * ((asamples[int2] - foffset)/frange));
    if fstarted then begin
     acanvas.linewidth:= fwidth;
     acanvas.drawline(makepoint(ax,fybefore),makepoint(fchartwindowrect.cx,ay),fcolor);
    end;
    fybefore:= ay;
   end;
  end;
  invalidaterect(fchartclientrect);
  fstarted:= true;
 end;
end;

procedure tchartrecorder.settraces(const avalue: trecordertraces);
begin
 ftraces.assign(avalue);
end;

procedure tchartrecorder.clear;
begin
 initchart;
end;

procedure tchartrecorder.changed;
begin
 initchart;
end;

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

end.
