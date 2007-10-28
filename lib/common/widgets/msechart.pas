{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msechart;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 classes,msegui,mseclasses,msearrayprops,msetypes,msegraphics,msegraphutils,
 msewidgets,msesimplewidgets,msedial,msebitmap,msemenus,mseevent;
 
type
 tcustomchart = class;
 tracestatety = (trs_datapointsvalid);
 tracestatesty = set of tracestatety;
 tracekindty = (trk_xseries,trk_xy);

 charttraceoptionty = (cto_adddataright);
 charttraceoptionsty = set of charttraceoptionty;
  
 ttrace = class(townedpersistent)
  private
   fxydata: complexarty;
   fstate: tracestatesty;
   fdatapoints: pointarty;
   fcolor: colorty;
   fxscale: real;
   fxoffset: real;
   fyscale: real;
   fyoffset: real;
   fxseriesdata: realarty;
   fkind: tracekindty;
   fxseriescount: integer;
   fwidthmm: real;
   fdashes: string;
   foptions: charttraceoptionsty;
   procedure setxydata(const avalue: complexarty);
   procedure datachange;
   procedure setcolor(const avalue: colorty);
   procedure setxscale(const avalue: real);
   procedure setxoffset(const avalue: real);
   procedure setyscale(const avalue: real);
   procedure setyoffset(const avalue: real);
   procedure scaleerror;
   procedure setxseriesdata(const avalue: realarty);
   procedure setkind(const avalue: tracekindty);
   procedure setxseriescount(const avalue: integer);
   procedure setwidthmm(const avalue: real);
   procedure setdashes(const avalue: string);
   procedure setoptions(const avalue: charttraceoptionsty);
  protected
   procedure checkgraphic;
   procedure paint(const acanvas: tcanvas);
  public
   constructor create(aowner: tobject); override;
   procedure addxseriesdata(const avalue: real);
   property xseriesdata: realarty read fxseriesdata write setxseriesdata;
   property xydata: complexarty read fxydata write setxydata;
  published
   property color: colorty read fcolor write setcolor default cl_black;
   property widthmm: real read fwidthmm write setwidthmm;   //default 0.3
   property dashes: string read fdashes write setdashes;
   property xscale: real read fxscale write setxscale;      //default 1.0
   property xoffset: real read fxoffset write setxoffset;
   property yscale: real read fyscale write setyscale;      //default 1.0
   property yoffset: real read fyoffset write setyoffset;
   property kind: tracekindty read fkind write setkind default trk_xseries;
   property xseriescount: integer read fxseriescount write setxseriescount default 0;
                      //0-> xseriesdata count
   property options: charttraceoptionsty read foptions write setoptions;
 end;

 traceaty = array[0..0] of ttrace;
 ptraceaty = ^traceaty;
 
 tracesstatety = (trss_graphicvalid);
 tracesstatesty = set of tracesstatety;
  
 ttraces = class(townedpersistentarrayprop)
  private
   ftracestate: tracesstatesty;
   procedure setitems(const index: integer; const avalue: ttrace);
   function getitems(const index: integer): ttrace;
  protected
   fscalex: real;
   fscaley: real;
   procedure change; reintroduce;
   procedure clientrectchanged;
   procedure paint(const acanvas: tcanvas);
   procedure checkgraphic;
  public
   constructor create(const aowner: tcustomchart); reintroduce;
   property items[const index: integer]: ttrace read getitems write setitems; default;
  published
 end;

 tchartdialvert = class(tcustomdialcontroller)
  protected
   procedure setdirection(const avalue: graphicdirectionty); override;
  published
   property color;
   property widthmm;
   property direction default gd_up;
   property offset;
   property range;
   property kind;
   property markers;
   property ticks;
   property options;
 end;
 
 tchartdialhorz = class(tcustomdialcontroller)
  protected
   procedure setdirection(const avalue: graphicdirectionty); override;
  published
   property color;
   property widthmm;
   property direction default gd_right;
   property offset;
   property range;
   property kind;
   property markers;
   property ticks;
   property options;
 end;

 tchartframe = class(tscrollboxframe)
  public
   constructor create(const intf: iframe; const owner: twidget);
  published
   property framei_left default 0;
   property framei_top default 0;
   property framei_right default 1;
   property framei_bottom default 1;
   property colorclient default cl_foreground;
 end;
 
 chartstatety = (chs_nocolorchart);
 chartstatesty = set of chartstatety;
 
 tcustomchart = class(tscrollbox,idialcontroller)
  private
   fdialhorz: tchartdialhorz;
   fdialvert: tchartdialvert;
   fonbeforepaint: painteventty;
   fonpaintbackground: painteventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
   procedure setdialhorz(const avalue: tchartdialhorz);
   procedure setdialvert(const avalue: tchartdialvert);
   procedure setcolorchart(const avalue: colorty);
  protected
   fcolorchart: colorty;
   fstate: chartstatesty;
   procedure changed; virtual;
   procedure clientrectchanged; override;
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure dopaintbackground(const canvas: tcanvas); override;
   procedure doonpaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure dopaint(const acanvas: tcanvas); override;
          //idialcontroller
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
   procedure internalcreateframe; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property colorchart: colorty read fcolorchart write setcolorchart 
                              default cl_foreground;
   property dialhorz: tchartdialhorz read fdialhorz write setdialhorz;
   property dialvert: tchartdialvert read fdialvert write setdialvert;
   property onbeforepaint: painteventty read fonbeforepaint write fonbeforepaint;
   property onpaintbackground: painteventty read fonpaintbackground 
                                                  write fonpaintbackground;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
 end;

 tchart = class(tcustomchart)
  private
   ftraces: ttraces;
   procedure settraces(const avalue: ttraces);
  protected
   procedure clientrectchanged; override;
   procedure dopaint(const acanvas: tcanvas); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property traces: ttraces read ftraces write settraces;
   property colorchart;
   property dialhorz;
   property dialvert;
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
   property dialhorz;
   property dialvert;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
 end;
 
implementation
uses
 sysutils;
 
{ ttrace }

constructor ttrace.create(aowner: tobject);
begin
 fcolor:= cl_black;
 fwidthmm:= 0.3;
 fxscale:= 1.0;
 fyscale:= 1.0;
 inherited;
end;

procedure ttrace.datachange;
begin
 exclude(fstate,trs_datapointsvalid);
 tchart(fowner).traces.change;
end;

procedure ttrace.setxydata(const avalue: complexarty);
begin
 fxydata:= avalue;
 datachange;
end;

procedure ttrace.setxseriesdata(const avalue: realarty);
begin
 fxseriesdata:= avalue;
 datachange;
end;

procedure ttrace.checkgraphic;
var
 int1,int2: integer;
 xo,xs,yo,ys: real;
 rea1: real;
begin
 if not (trs_datapointsvalid in fstate) then begin
  yo:= fyoffset - fyscale;
  ys:= -tchart(fowner).traces.fscaley / fyscale;
  case fkind of
   trk_xy: begin     
    setlength(fdatapoints,length(fxydata));
    xo:= fxoffset;
    xs:= tchart(fowner).traces.fscalex / fxscale;
    for int1:= 0 to high(fdatapoints) do begin
     fdatapoints[int1].x:= round((fxydata[int1].re + xo)* xs);
     fdatapoints[int1].y:= round((fxydata[int1].im + yo)* ys);
    end;
   end;
   else begin //trk_xseries
    setlength(fdatapoints,length(fxseriesdata));
    if high(fdatapoints) >= 0 then begin
     rea1:= 0;
     if xseriescount > 1 then begin
      int2:= xseriescount - 1;
      if (int2 > high(fdatapoints)) and (cto_adddataright in foptions) then begin
       rea1:= {$ifdef FPC}real({$endif}1.0{$ifdef FPC}){$endif} - high(fdatapoints) / int2;
      end;
     end
     else begin
      int2:= high(fdatapoints);
     end;
     xo:= (rea1 + fxoffset) * int2;
     xs:= tchart(fowner).traces.fscalex / (fxscale * int2);
     for int1:= 0 to high(fdatapoints) do begin
      fdatapoints[int1].x:= round((int1 + xo)* xs);
      fdatapoints[int1].y:= round((fxseriesdata[int1] + yo)* ys);
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

procedure ttrace.setxscale(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 fxscale:= avalue;
 datachange;
end;

procedure ttrace.setoptions(const avalue: charttraceoptionsty);
begin
 if avalue <> foptions then begin
  foptions:= avalue;
  datachange;
 end;
end;

procedure ttrace.setxoffset(const avalue: real);
begin
 fxoffset:= avalue;
 datachange;
end;

procedure ttrace.setyscale(const avalue: real);
begin
 if avalue = 0 then begin
  scaleerror;
 end;
 fyscale:= avalue;
 datachange;
end;

procedure ttrace.setyoffset(const avalue: real);
begin
 fyoffset:= avalue;
 datachange;
end;

procedure ttrace.scaleerror;
begin
 raise exception.create('Scale can not be 0.');
end;

procedure ttrace.setkind(const avalue: tracekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  datachange;
 end;
end;

procedure ttrace.setxseriescount(const avalue: integer);
begin
 if fxseriescount <> avalue then begin
  fxseriescount:= avalue;
  datachange;
 end;
end;

procedure ttrace.addxseriesdata(const avalue: real);
begin
 if (fxseriescount = 0) or (length(fxseriesdata) < fxseriescount) then begin
  setlength(fxseriesdata,high(fxseriesdata) + 2);
 end
 else begin
  move(fxseriesdata[1],fxseriesdata[0],
          sizeof(fxseriesdata[0])*high(fxseriesdata));
 end;
 fxseriesdata[high(fxseriesdata)]:= avalue;
 datachange;
end;

{ ttraces }

constructor ttraces.create(const aowner: tcustomchart);
begin
 inherited create(aowner,ttrace);
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
 acanvas.linewidth:= 0;
end;

procedure ttraces.checkgraphic;
var
 int1: integer;
 size1: sizety;
begin
 if not (trss_graphicvalid in ftracestate) then begin
  size1:= twidget(fowner).innerclientsize;
  fscalex:= size1.cx;
  fscaley:= size1.cy;
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

{ tchartdialvert }

procedure tchartdialvert.setdirection(const avalue: graphicdirectionty);
begin
 if avalue in [gd_up,gd_down] then begin
  inherited;
 end;
end;

{ tchartdialhorz }

procedure tchartdialhorz.setdirection(const avalue: graphicdirectionty);
begin
 if avalue in [gd_right,gd_left] then begin
  inherited;
 end;
end;

{ tchartframe }

constructor tchartframe.create(const intf: iframe; const owner: twidget);
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
 fdialvert:= tchartdialvert.create(idialcontroller(self));
 fdialhorz:= tchartdialhorz.create(idialcontroller(self));
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
 inherited;
end;

destructor tcustomchart.destroy;
begin
 fdialvert.free;
 fdialhorz.free;
 inherited;
end;

procedure tcustomchart.clientrectchanged;
begin
 fdialhorz.changed;
 fdialvert.changed;
 inherited;
end;

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

procedure tcustomchart.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if not (chs_nocolorchart in fstate) and 
                 not (fcolorchart = container.frame.colorclient) then begin
  canvas.fillrect(innerclientrect,fcolorchart);
 end;
 if canevent(tmethod(fonpaintbackground)) then begin
  fonpaintbackground(self,canvas);
 end;
end;

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

procedure tcustomchart.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdialhorz.paint(acanvas);
 fdialvert.paint(acanvas);
 fdialhorz.afterpaint(acanvas);
 fdialvert.afterpaint(acanvas);
end;

procedure tcustomchart.setcolorchart(const avalue: colorty);
begin
 if fcolorchart <> avalue then begin
  fcolorchart:= avalue;
  changed;
 end;
end;

procedure tcustomchart.setdialhorz(const avalue: tchartdialhorz);
begin
 fdialhorz.assign(avalue);
end;

procedure tcustomchart.setdialvert(const avalue: tchartdialvert);
begin
 fdialvert.assign(avalue);
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
 tchartframe.create(iframe(self),self);
end;

procedure tcustomchart.changed;
begin
 invalidate;
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

{ trecordertraces }

constructor trecordertraces.create;
begin
 inherited create(trecordertrace);
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

end.
