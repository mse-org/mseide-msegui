unit msechart;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 classes,msegui,mseclasses,msearrayprops,msetypes,msegraphics,msegraphutils,
 msewidgets,msesimplewidgets,msedial;
 
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
   property direction default gd_up;
   property offset;
   property range;
   property markers;
   property ticks;
   property options;
 end;
 
 tchartdialhorz = class(tcustomdialcontroller)
  protected
   procedure setdirection(const avalue: graphicdirectionty); override;
  published
   property direction default gd_right;
   property offset;
   property range;
   property markers;
   property ticks;
   property options;
 end;
  
 tcustomchart = class(tscrollbox,idialcontroller)
  private
   ftraces: ttraces;
   fdialhorz: tchartdialhorz;
   fdialvert: tchartdialvert;
   procedure settraces(const avalue: ttraces);
   procedure setdialhorz(const avalue: tchartdialhorz);
   procedure setdialvert(const avalue: tchartdialvert);
  protected
   procedure clientrectchanged; override;
   procedure dopaint(const acanvas: tcanvas); override;
          //idialcontroller
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property traces: ttraces read ftraces write settraces;
   property dialhorz: tchartdialhorz read fdialhorz write setdialhorz;
   property dialvert: tchartdialvert read fdialvert write setdialvert;
 end;

 tchart = class(tcustomchart)
  published
   property traces;
   property dialhorz;
   property dialvert;
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
 tcustomchart(fowner).traces.change;
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
  ys:= -tcustomchart(fowner).traces.fscaley / fyscale;
  case fkind of
   trk_xy: begin     
    setlength(fdatapoints,length(fxydata));
    xo:= fxoffset;
    xs:= tcustomchart(fowner).traces.fscalex / fxscale;
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
       rea1:= 1 - high(fdatapoints) / real(int2);
      end;
     end
     else begin
      int2:= high(fdatapoints);
     end;
     xo:= (rea1 + fxoffset) * int2;
     xs:= tcustomchart(fowner).traces.fscalex / (fxscale * int2);
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
  tcustomchart(fowner).traces.change;
 end;
end;

procedure ttrace.setwidthmm(const avalue: real);
begin
 fwidthmm:= avalue;
 tcustomchart(fowner).traces.change;
end;

procedure ttrace.setdashes(const avalue: string);
begin
 fdashes:= avalue;
 tcustomchart(fowner).traces.change;
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

{ tcustomchart }

constructor tcustomchart.create(aowner: tcomponent);
begin
 ftraces:= ttraces.create(self);
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
 ftraces.free;
 fdialvert.free;
 fdialhorz.free;
 inherited;
end;

procedure tcustomchart.settraces(const avalue: ttraces);
begin
 ftraces.assign(avalue);
end;

procedure tcustomchart.clientrectchanged;
begin
 fdialhorz.changed;
 fdialvert.changed;
 ftraces.clientrectchanged;
 inherited;
end;

procedure tcustomchart.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdialhorz.paint(acanvas);
 fdialvert.paint(acanvas);
 acanvas.move(innerclientpos);
 ftraces.paint(acanvas);
 acanvas.remove(innerclientpos);
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

end.
