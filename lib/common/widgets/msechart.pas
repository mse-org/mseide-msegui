{ MSEgui Copyright (c) 2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msechart;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 classes,msegui,mseguiglob,mseclasses,msearrayprops,msetypes,msegraphics,msegraphutils,
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
 
 ttrace = class(townedeventpersistent,iimagelistinfo)
  private
   fxdata: realarty;
   fydata: realarty;
   fxydata: complexarty;
   fxdatalist: trealdatalist;
   fydatalist: trealdatalist;
   fstate: tracestatesty;
   fdatapoints: pointarty;
   fcolor: colorty;
   fxrange: real;
   fxstart: real;
   fyrange: real;
   fystart: real;
   fkind: tracekindty;
   fmaxcount: integer;
   fwidthmm: real;
   fdashes: string;
   foptions: charttraceoptionsty;
   fstart: integer;
   fimagelist: timagelist;
   fimagenr: imagenrty;
   fname: string;
   procedure setxydata(const avalue: complexarty);
   procedure datachange;
   procedure setcolor(const avalue: colorty);
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
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenr(const avalue: imagenrty);
   function getimagelist: timagelist;
  protected
   procedure checkgraphic;
   procedure paint(const acanvas: tcanvas);
   procedure paint1(const acanvas: tcanvas);
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tobject); override;
   procedure addxseriesdata(const avalue: real);
   property xdata: realarty read fydata write setxdata;
   property ydata: realarty read fydata write setydata;
   property xydata: complexarty read fxydata write setxydata;
   property xdatalist: trealdatalist read fxdatalist write setxdatalist;
   property ydatalist: trealdatalist read fydatalist write setydatalist;
   
  published
   property color: colorty read fcolor write setcolor default cl_black;
   property widthmm: real read fwidthmm write setwidthmm;   //default 0.3
   property dashes: string read fdashes write setdashes;
   property xrange: real read fxrange write setxrange;      //default 1.0
   property xstart: real read fxstart write setxstart;
   property yrange: real read fyrange write setyrange;      //default 1.0
   property ystart: real read fystart write setystart;
   property kind: tracekindty read fkind write setkind default trk_xseries;
   property start: integer read fstart write setstart default 0;
   property maxcount: integer read fmaxcount write setmaxcount default 0;
                      //0-> data count
   property options: charttraceoptionsty read foptions write setoptions default [];
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagenr: imagenrty read fimagenr write setimagenr default -1;
   property name: string read fname write fname;
 end;

 traceaty = array[0..0] of ttrace;
 ptraceaty = ^traceaty;
 
 tracesstatety = (trss_graphicvalid);
 tracesstatesty = set of tracesstatety;
  
 ttraces = class(townedeventpersistentarrayprop)
  private
   ftracestate: tracesstatesty;
   fxstart: real;
   fystart: real;
   fxrange: real;
   fyrange: real;
   procedure setitems(const index: integer; const avalue: ttrace);
   function getitems(const index: integer): ttrace;
   procedure setxstart(const avalue: real);
   procedure setystart(const avalue: real);
   procedure setxrange(const avalue: real);
   procedure setyrange(const avalue: real);
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
   property items[const index: integer]: ttrace read getitems write setitems; default;
   function itembyname(const aname: string): ttrace;
  published
   property xstart: real read fxstart write setxstart;
   property ystart: real read fystart write setystart;
   property xrange: real read fxrange write setxrange;
   property yrange: real read fyrange write setyrange;
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
   property items[const aindex: integer]: tchartdialvert read getitems write setitems; default;
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
//   fonbeforepaint: painteventty;
//   fonpaintbackground: painteventty;
//   fonpaint: painteventty;
//   fonafterpaint: painteventty;
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
//   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure dopaintbackground(const canvas: tcanvas); override;
//   procedure doonpaint(const canvas: tcanvas); override;
//   procedure doafterpaint(const canvas: tcanvas); override;
   procedure dopaint(const acanvas: tcanvas); override;
          //idialcontroller
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
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
//   property onbeforepaint: painteventty read fonbeforepaint write fonbeforepaint;
//   property onpaintbackground: painteventty read fonpaintbackground
//                                                  write fonpaintbackground;
//   property onpaint: painteventty read fonpaint write fonpaint;
//   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
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
 
implementation
uses
 sysutils;

type
 tcustomdialcontroller1 = class(tcustomdialcontroller);
  
{ ttrace }

constructor ttrace.create(aowner: tobject);
begin
 fcolor:= cl_black;
 fwidthmm:= 0.3;
 fxrange:= 1.0;
 fyrange:= 1.0;
 fimagenr:= -1;
 inherited;
end;

procedure ttrace.datachange;
begin
 exclude(fstate,trs_datapointsvalid);
 tchart(fowner).traces.change;
end;

procedure ttrace.setxydata(const avalue: complexarty);
begin
 fxdatalist:= nil;
 fydatalist:= nil;
 fxdata:= nil;
 fydata:= nil;
 fxydata:= avalue;
 datachange;
end;


procedure ttrace.setxdata(const avalue: realarty);
begin
 fxdatalist:= nil;
 fxydata:= nil;
 fxdata:= avalue;
 datachange;
end;

procedure ttrace.setydata(const avalue: realarty);
begin
 fydatalist:= nil;
 fxydata:= nil;
 fydata:= avalue;
 datachange;
end;

procedure ttrace.setxdatalist(const avalue: trealdatalist);
begin
 fxdata:= nil;
 fxydata:= nil;
 fxdatalist:= avalue;
 datachange;
end;

procedure ttrace.setydatalist(const avalue: trealdatalist);
begin
 fydata:= nil;
 fxydata:= nil;
 fydatalist:= avalue;
 datachange;
end;

procedure ttrace.checkgraphic;
var
 pox,poy: pchar;
 intx,inty: integer;
 
 procedure checkrange(var dpcount: integer);
 var
  int1: integer;
 begin
  int1:= fmaxcount;
  if int1 = 0 then begin
   int1:= dpcount;
  end;
  if fstart + int1 > dpcount then begin
   int1:= dpcount - fstart;
  end;
  if int1 < dpcount then begin
   dpcount:= int1;
  end;
  if dpcount < 0 then begin
   dpcount:= 0;
  end;
  pox:= pox + fstart * intx;
  poy:= poy + fstart * inty;
 end;

var
 int1,int2,int3,int4: integer;
 xo,xs,yo,ys: real;
 rea1: real;
 ar1: datapointarty;
 dpcountx,dpcounty,dpcountxy: integer;
 
begin
 if not (trs_datapointsvalid in fstate) then begin
  dpcountx:= 0;
  dpcounty:= 0;
  if fxydata <> nil then begin
   pox:= @fxydata[0].re;
   poy:= @fxydata[0].im;
   intx:= sizeof(complexty);
   inty:= sizeof(complexty);
   dpcountx:= length(fxydata);
   dpcounty:= dpcountx;
  end
  else begin
   if fxdatalist <> nil then begin
    dpcountx:= fxdatalist.count;
    pox:= fxdatalist.datapo;
    intx:= fxdatalist.size;
   end
   else begin
    pox:= pointer(fxdata);
    intx:= sizeof(real);
    dpcountx:= length(fxdata);
   end;
   if fydatalist <> nil then begin
    dpcounty:= fydatalist.count;
    poy:= fydatalist.datapo;
    inty:= fydatalist.size;
   end
   else begin
    poy:= pointer(fydata);
    inty:= sizeof(real);
    dpcounty:= length(fydata);
   end;
  end;
  dpcountxy:= dpcountx;
  if dpcounty < dpcountxy then begin
   dpcountxy:= dpcounty;
  end;
  
//  yo:= fyoffset - fyscale;
  yo:= -fystart - fyrange;
  ys:= -tchart(fowner).traces.fscaley / fyrange;
  case fkind of
   trk_xy: begin     
    xo:= -fxstart;
    xs:= tchart(fowner).traces.fscalex / fxrange;
    checkrange(dpcountxy);
    if (cto_xordered in foptions) {and
                   (dpcount > tchart(fowner).traces.fscalex)} then begin
     int4:= tchart(fowner).traces.fsize.cx+2;
     setlength(ar1,int4);
     dec(int4);
     for int1:= 0 to dpcountxy - 1 do begin
      int2:= round((preal(pox)^ + xo)* xs) + 1;
      int3:= round((preal(poy)^ + yo)* ys);
      if int2 < 0 then begin
       int2:= 0;
      end;
      if int2 > int4 then begin
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
     setlength(fdatapoints,length(ar1)*4);  //first->max->min->last
     int2:= 0;
     for int1:= 0 to high(ar1) do begin
      with ar1[int1] do begin
       if used then begin
        int3:= int1-1;
        fdatapoints[int2].x:= int3;
        fdatapoints[int2].y:= first;
        inc(int2);
        if max > first then begin
         fdatapoints[int2].x:= int3;
         fdatapoints[int2].y:= max;
         inc(int2);
        end;
        if min < max then begin
         fdatapoints[int2].x:= int3;
         fdatapoints[int2].y:= min;
         inc(int2);
        end;
        if last > min then begin
         fdatapoints[int2].x:= int3;
         fdatapoints[int2].y:= last;
         inc(int2);
        end;
       end;
      end;
     end;
     setlength(fdatapoints,int2);
    end
    else begin
     setlength(fdatapoints,dpcountxy);
     for int1:= 0 to high(fdatapoints) do begin
      fdatapoints[int1].x:= round((preal(pox)^ + xo)* xs);
      fdatapoints[int1].y:= round((preal(poy)^ + yo)* ys);
      inc(pox,intx);
      inc(poy,inty);
     end;
    end;
   end;
   else begin //trk_xseries
    checkrange(dpcounty);
    setlength(fdatapoints,dpcounty);
    if high(fdatapoints) >= 0 then begin
     rea1:= 0;
     if maxcount > 1 then begin
      int2:= maxcount - 1;
      if (int2 > high(fdatapoints)) and (cto_adddataright in foptions) then begin
       rea1:= {$ifdef FPC}real({$endif}1.0{$ifdef FPC}){$endif} - high(fdatapoints) / int2;
      end;
     end
     else begin
      int2:= high(fdatapoints);
     end;
     xo:= (rea1 + fxstart) * int2;
     xs:= tchart(fowner).traces.fscalex / (fxrange * int2);
     for int1:= 0 to high(fdatapoints) do begin
      fdatapoints[int1].x:= round((int1 + xo)* xs);
      fdatapoints[int1].y:= round((preal(poy)^ + yo)* ys);
      inc(poy,inty);
     end;
    end;
   end;
  end;
  include(fstate,trs_datapointsvalid);
 end;
end;

procedure ttrace.paint(const acanvas: tcanvas);
begin
 acanvas.linewidthmm:= fwidthmm;
 if fdashes <> '' then begin
  acanvas.dashes:= fdashes;
 end;
 acanvas.drawlines(fdatapoints,false,fcolor);
 if fdashes <> '' then begin
  acanvas.dashes:= '';
 end;
end;

procedure ttrace.paint1(const acanvas: tcanvas);
var
 int1: integer;
 pt1: pointty;
begin
 if (fimagelist <> nil) and (fimagenr >= 0) and 
                                   (fimagenr < fimagelist.count) then begin
  pt1:= pointty(fimagelist.size);
  pt1.x:= pt1.x div 2;
  pt1.y:= pt1.y div 2;
  acanvas.remove(pt1);
  for int1:= 0 to high(fdatapoints) do begin
   fimagelist.paint(acanvas,fimagenr,fdatapoints[int1],fcolor);
  end;
  acanvas.move(pt1);
 end;
end;

procedure ttrace.setcolor(const avalue: colorty);
begin
 if fcolor <> avalue then begin
  fcolor:= avalue;
  tchart(fowner).traces.change;
 end;
end;

procedure ttrace.setwidthmm(const avalue: real);
begin
 fwidthmm:= avalue;
 tchart(fowner).traces.change;
end;

procedure ttrace.setdashes(const avalue: string);
begin
 fdashes:= avalue;
 tchart(fowner).traces.change;
end;

procedure ttrace.setxrange(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 fxrange:= avalue;
 datachange;
end;

procedure ttrace.setoptions(const avalue: charttraceoptionsty);
begin
 if avalue <> foptions then begin
  foptions:= avalue;
  datachange;
 end;
end;

procedure ttrace.setxstart(const avalue: real);
begin
 fxstart:= avalue;
 datachange;
end;

procedure ttrace.setyrange(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 fyrange:= avalue;
 datachange;
end;

procedure ttrace.setystart(const avalue: real);
begin
 fystart:= avalue;
 datachange;
end;

procedure ttrace.scaleerror;
begin
 raise exception.create('Range can not be 0.');
end;

procedure ttrace.setkind(const avalue: tracekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  datachange;
 end;
end;

procedure ttrace.setstart(const avalue: integer);
begin
 if fstart <> avalue then begin
  fstart:= avalue;
  datachange;
 end;
end;

procedure ttrace.setmaxcount(const avalue: integer);
begin
 if fmaxcount <> avalue then begin
  fmaxcount:= avalue;
  datachange;
 end;
end;

procedure ttrace.addxseriesdata(const avalue: real);
begin
 fydatalist:= nil;
 if (fmaxcount = 0) or (length(fydata) < fmaxcount) then begin
  setlength(fydata,high(fydata) + 2);
 end
 else begin
  move(fydata[1],fydata[0],
          sizeof(fydata[0])*high(fydata));
 end;
 fydata[high(fydata)]:= avalue;
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

procedure ttrace.setimagelist(const avalue: timagelist);
begin
 setlinkedvar(avalue,fimagelist);
 datachange;
end;

procedure ttrace.setimagenr(const avalue: imagenrty);
begin
 if fimagenr <> avalue then begin
  fimagenr:= avalue;
  datachange;
 end;
end;

function ttrace.getimagelist: timagelist;
begin
 result:= fimagelist;
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
  exclude(ptraceaty(fitems)^[int1].fstate,trs_datapointsvalid);
 end;
end;

procedure ttraces.paint(const acanvas: tcanvas);
var
 int1: integer;
begin
 checkgraphic;
 for int1:= 0 to high(fitems) do begin
  ptraceaty(fitems)^[int1].paint(acanvas);
 end;
 for int1:= 0 to high(fitems) do begin
  ptraceaty(fitems)^[int1].paint1(acanvas);
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
 for int1:= 0 to high(fitems) do begin
  ttrace(fitems[int1]).xstart:= avalue;
 end;
end;

procedure ttraces.setystart(const avalue: real);
var
 int1: integer;
begin
 fystart:= avalue;
 for int1:= 0 to high(fitems) do begin
  ttrace(fitems[int1]).ystart:= avalue;
 end;
end;

procedure ttraces.setxrange(const avalue: real);
var
 int1: integer;
begin
 fxrange:= avalue;
 for int1:= 0 to high(fitems) do begin
  ttrace(fitems[int1]).xrange:= avalue;
 end;
end;

procedure ttraces.setyrange(const avalue: real);
var
 int1: integer;
begin
 fyrange:= avalue;
 for int1:= 0 to high(fitems) do begin
  ttrace(fitems[int1]).yrange:= avalue;
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
end;

procedure tchart.setystart(const avalue: real);
begin
 inherited;
 ftraces.xrange:= avalue;
end;

procedure tchart.setxrange(const avalue: real);
begin
 inherited;
 ftraces.ystart:= avalue;
end;

procedure tchart.setyrange(const avalue: real);
begin
 inherited;
 ftraces.yrange:= avalue;
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
