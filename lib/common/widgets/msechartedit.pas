{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msechartedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,msechart,mseguiglob,mseevent,mseeditglob,msegraphutils,
 msetypes,
 mseobjectpicker,msepointer,msegraphics,mseclasses,msestat,msestatfile,
 msestrings,msedial,msegui,msemenus,mseglob;
 
const
 defaultsnapdist = 4;
 markersnapdist = 2;
 defaultchartoptionsedit1 = [oe1_checkvalueafterstatread,oe1_savevalue,
                                                             oe1_savestate];
 defaultcharteditoptionswidget = defaultchartoptionswidget + [ow_mousefocus]; 
 
type
 setcomplexareventty = procedure(const sender: tobject;
                var avalue: complexarty; var accept: boolean) of object;
 setrealareventty = procedure(const sender: tobject;
                var avalue: realarty; var accept: boolean) of object;
 charteditoptionty = (ceo_thumbtrack,ceo_noinsert,ceo_nodelete,
                      ceo_tracehint,ceo_markerhint);
 charteditoptionsty = set of charteditoptionty;

 charteditmovestatety = (cems_markermoving,cems_canbottomlimit,cems_cantoplimit,
                         cems_xbottomlimit,cems_ybottomlimit,
                         cems_xtoplimit,cems_ytoplimit);
 charteditmovestatesty = set of charteditmovestatety;

 tcustomchartedit = class; 
 tracehinteventty = procedure(const sender: tcustomchartedit;
          const atrace,aindex: integer; var ahint: hintinfoty) of object;
 markerhinteventty = procedure(const sender: tcustomchartedit;
          const isy: boolean; const adial,aindex: integer;
                                     var ahint: hintinfoty) of object;
 markerseteventty = procedure(const sender: tcustomchartedit;
          const isy: boolean; const adial,aindex: integer;
                                     var avalue: realty) of object;
                                        
 tcustomchartedit = class(tcustomchart,iobjectpicker)
  private
   factivetrace: integer;
   foptionsedit: optionseditty;
   foptionsedit1: optionsedit1ty;
   fobjectpicker: tobjectpicker;
   fsnapdist: integer;
   foffsetmin: pointty;
   foffsetmax: pointty;
   fonchange: notifyeventty;
   fondataentered: notifyeventty;
   foptions: charteditoptionsty;
   fpickref: pointty;
   fmovestate: charteditmovestatesty;
   fontracehint: tracehinteventty;
   fonmarkerhint: markerhinteventty;
   fnodehintindex: integer;
   fnodehinttrace: integer;
   fonsetmarker: markerseteventty;
   fonmarkerentered: notifyeventty;
   procedure setactivetrace(avalue: integer);
   function limitmoveoffset(const aoffset: pointty): pointty;
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   procedure setoptions(const avalue: charteditoptionsty);
   procedure dopickmove(const sender: tobjectpicker);
   procedure setoptionsedit(const avalue: optionseditty);
  protected
   procedure resetnodehint;
   function hasactivetrace: boolean;
   function nodepos(const atrace: integer; const aindex: integer): pointty;
   function nearestnode(const apos: pointty; const all: boolean;
                       out atrace,aindex: integer): boolean;
   function nodesinrect(const arect: rectty): integerarty;
   function encodenodes(const atrace: integer;
                                const aindex: array of integer): integerarty;
   function decodenodes(const aitems: integerarty;
                     out atrace: integer; out aindex: integerarty): boolean;

   function chartcoordxy(const atrace: integer;
                                const avalue: complexty): pointty;
   function tracecoordxy(const atrace: integer;
                                const apos: pointty): complexty;
   function chartcoordxseries(const atrace: integer;
                                const avalue: xseriesdataty): pointty;
   function tracecoordxseries(const atrace: integer;
                                const apos: pointty): xseriesdataty;

   function encodemarker(const isy: boolean;
                                     const adial,aindex: integer): integerarty;
   function decodemarker(const aitems: integerarty; out isy: boolean;
                         out adial: integer; out aindex: integer): boolean;
   function xmarkertochart(const avalue: real; const adial: integer): integer;
   function ymarkertochart(const avalue: real; const adial: integer): integer;
   function xcharttomarker(const apos: integer; const adial: integer): real;
   function ycharttomarker(const apos: integer; const adial: integer): real;
   function getmarker(const apos: pointty; const nolimited: boolean;
                         out isy: boolean; out adial,aindex: integer): boolean; 

   procedure tracehint(const atrace,aindex: integer);
   procedure markerhint(const apos: pointty; const isy: boolean;
                                                const adial,aindex: integer);
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var ainfo: keyeventinfoty); override;
   procedure dobeforepaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const acanvas: tcanvas); override;
   procedure change;
   procedure dochange; virtual;
   procedure domarkerchange; virtual;
   function chartdataxy: complexarty;
   function chartdataxseries: realarty;
   function activetraceitem: ttrace;

   procedure doreadvalue(const reader: tstatreader); virtual; abstract;
   procedure dowritevalue(const writer: tstatwriter); virtual; abstract;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure statread; override;
   procedure loaded; override;
   procedure docheckvalue(var accept: boolean); virtual; abstract;
   procedure doclear; virtual; abstract;
   procedure drawcrosshaircursor(const canvas: tcanvas;
                                         const center: pointty); virtual;
                         
    //iobjectpicker
   function getcursorshape(const sender: tobjectpicker;
                            var shape: cursorshapety): boolean;
   procedure getpickobjects(const sender: tobjectpicker;
                                    var objects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure pickthumbtrack(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure cancelpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const canvas: tcanvas);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; override;
   function checkvalue: boolean;
   property readonly: boolean read getreadonly write setreadonly;
   property activetrace: integer read factivetrace 
                           write setactivetrace default 0;
   property optionsedit: optionseditty read foptionsedit write setoptionsedit 
                                                  default defaultoptionsedit;
   property optionsedit1: optionsedit1ty read foptionsedit1 write foptionsedit1
                                               default defaultchartoptionsedit1;
   property snapdist: integer read fsnapdist write fsnapdist 
                                              default defaultsnapdist;
   property options: charteditoptionsty read foptions
                                                 write setoptions default [];
   property onchange: notifyeventty read fonchange write fonchange;
   property onsetmarker: markerseteventty read fonsetmarker write fonsetmarker;
   property onmarkerentered: notifyeventty read fonmarkerentered
                                                        write fonmarkerentered;
   property ontracehint: tracehinteventty read fontracehint write fontracehint;
   property onmarkerhint: markerhinteventty read fonmarkerhint 
                                                         write fonmarkerhint;
  published
   property optionswidget default defaultcharteditoptionswidget;
 end;

 tcustomxychartedit = class(tcustomchartedit)
  private
   fonsetvalue: setcomplexareventty;
   function getvalue: complexarty;
   procedure setvalue(const avalue: complexarty);
   function getvalueitems(const index: integer): complexty;
   procedure setvalueitems(const index: integer; const avalue: complexty);
   function getreitems(const index: integer): real;
   procedure setreitems(const index: integer; const avalue: real);
   function getimitems(const index: integer): real;
   procedure setimitems(const index: integer; const avalue: real);
  protected
   fvalue: complexarty;
   procedure dochange; override;
   procedure docheckvalue(var accept: boolean); override;
   procedure doreadvalue(const reader: tstatreader); override;
   procedure dowritevalue(const writer: tstatwriter); override;
   class function xordered: boolean; virtual;
   procedure doclear; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: complexarty read getvalue write setvalue;
   property valueitems[const index: integer]: complexty read getvalueitems 
                                                       write setvalueitems;
   property reitems[const index: integer]: real read getreitems write setreitems;
   property imitems[const index: integer]: real read getimitems write setimitems;
   property ondataentered: notifyeventty read fondataentered 
                                                 write fondataentered;
   property onsetvalue: setcomplexareventty read fonsetvalue write fonsetvalue;
 end;

 txychartedit = class(tcustomxychartedit)
  published
   property traces;
   property colorchart;
   property xstart;
   property ystart;
   property xrange;
   property yrange;
   property xdials;
   property ydials;
   property fitframe_left;
   property fitframe_top;
   property fitframe_right;
   property fitframe_bottom;
   property statfile;
   property statvarname;
   property statpriority;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property ondataentered;
   property onsetvalue;
   property activetrace;
   property optionsedit;
   property snapdist;
   property tracehint_captionx;
   property tracehint_captiony;
   property options;
   property optionschart;
   property onchange;
   property onsetmarker;
   property onmarkerentered;
   property ontracehint;
   property onmarkerhint;
 end;
  
 tcustomorderedxychartedit = class(tcustomxychartedit)
  protected
   class function xordered: boolean; override;
  public
 end;
 
 torderedxychartedit = class(tcustomorderedxychartedit)
  published
   property traces;
   property colorchart;
   property xstart;
   property ystart;
   property xrange;
   property yrange;
   property xdials;
   property ydials;
   property fitframe_left;
   property fitframe_top;
   property fitframe_right;
   property fitframe_bottom;
   property statfile;
   property statvarname;
   property statpriority;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property ondataentered;
   property onsetvalue;
   property activetrace;
   property optionsedit;
   property snapdist;
   property tracehint_captionx;
   property tracehint_captiony;
   property options;
   property optionschart;
   property onchange;
   property onsetmarker;
   property onmarkerentered;
   property ontracehint;
   property onmarkerhint;
 end;
 
 tcustomxserieschartedit = class(tcustomchartedit)
  private
   fonsetvalue: setrealareventty;
   function getvalue: realarty;
   procedure setvalue(const avalue: realarty);
   function getvalueitems(const index: integer): real;
   procedure setvalueitems(const index: integer; const avalue: real);
  protected
   fvalue: realarty;
   procedure dochange; override;
   procedure docheckvalue(var accept: boolean); override;
   procedure doreadvalue(const reader: tstatreader); override;
   procedure dowritevalue(const writer: tstatwriter); override;
   procedure doclear; override;
  public
   property value: realarty read getvalue write setvalue;
   property valueitems[const index: integer]: real read getvalueitems 
                                                       write setvalueitems;
  public
   property ondataentered: notifyeventty read fondataentered 
                                                 write fondataentered;
   property onsetvalue: setrealareventty read fonsetvalue write fonsetvalue;
 end;

 txserieschartedit = class(tcustomxserieschartedit)
  published
   property traces;
   property colorchart;
   property xstart;
   property ystart;
   property xrange;
   property yrange;
   property xdials;
   property ydials;
   property fitframe_left;
   property fitframe_top;
   property fitframe_right;
   property fitframe_bottom;
   property statfile;
   property statvarname;
   property statpriority;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property ondataentered;
   property onsetvalue;
   property activetrace;
   property optionsedit;
   property snapdist;
   property tracehint_captionx;
   property tracehint_captiony;
   property options;
   property optionschart;
   property onchange;
   property onsetmarker;
   property onmarkerentered;
   property ontracehint;
   property onmarkerhint;
 end;
   
implementation
uses
 msereal,msekeyboard,msedatalist,sysutils,msearrayutils,mseformatstr;
 
type
 ttraces1 = class(ttraces);
 ttrace1 = class(ttrace);
 tdialmarkers1 = class(tdialmarkers);
 tcustomdialcontroller1 = class(tcustomdialcontroller);
  
{ tcustomchartedit }

constructor tcustomchartedit.create(aowner: tcomponent);
begin
 fsnapdist:= defaultsnapdist;
 foptionsedit:= defaultoptionsedit;
 foptionsedit1:= defaultchartoptionsedit1;
 resetnodehint;
 inherited;
 optionswidget:= defaultcharteditoptionswidget;
 traces.count:= 1;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self));
 fobjectpicker.options:= [opo_mousemoveobjectquery,opo_rectselect,
                          opo_multiselect];
end;

destructor tcustomchartedit.destroy;
begin
 fobjectpicker.free;
 inherited;
end;

procedure tcustomchartedit.setactivetrace(avalue: integer);
begin
 if avalue < 0 then begin
  avalue:= -1;
//  raise exception.create('Negative value');
 end;
 factivetrace:= avalue;
// if traces.count <= avalue then begin
//  traces.count:= avalue+1;
// end;
end;

function tcustomchartedit.activetraceitem: ttrace;
begin
 result:= nil;
 if factivetrace >= 0 then begin
  if factivetrace >= traces.count then begin
   traces.count:= factivetrace+1;
  end;
  result:= ttrace(ttraces1(traces).fitems[factivetrace]);
 end;
end;

procedure tcustomchartedit.resetnodehint;
begin
 fnodehintindex:= -1;
 fnodehinttrace:= -1;
end;

function tcustomchartedit.hasactivetrace: boolean;
begin
 result:= (factivetrace >= 0) and (factivetrace < traces.count) and
               traces[factivetrace].visible;
end;

procedure tcustomchartedit.tracehint(const atrace,aindex: integer);
var
 info: hintinfoty;
 x,y: real;
 mstr1,mstr2: msestring;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  with posrect do begin
   pos:= nodepos(atrace,aindex);
   addpoint1(pos,mp(-20,-20));
   cx:= 40;
   cy:= 40;
  end;
  placement:= cp_bottomleft;
 end;
 with ttrace1(traces[atrace]) do begin
  y:= yvalue[aindex];
  if kind = trk_xy then begin
   x:= xvalue[aindex];
  end
  else begin
   x:= aindex;
  end;
  mstr1:= hintx;
  if mstr1 = '' then begin
   mstr1:= 'x: '+formatfloatmse(x,'');
  end
  else begin
   mstr1:= formatfloatmse(x,mstr1);
  end;
  mstr2:= hinty;
  if mstr2 = '' then begin
   mstr2:= 'y: '+formatfloatmse(y,'');
  end
  else begin
   mstr2:= formatfloatmse(y,mstr2);
  end;
  info.caption:= mstr1+lineend+mstr2;
 end;
 if canevent(tmethod(fontracehint)) then begin
  fontracehint(self,atrace,aindex,info);
 end;
 if info.caption <> '' then begin
  application.showhint(self,info);
 end;
end;

procedure tcustomchartedit.markerhint(const apos: pointty; const isy: boolean;
                                             const adial,aindex: integer);
var
 info: hintinfoty;
 mstr1: msestring;
 marker1: tdialmarker;
 
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  with posrect do begin
   pos:= apos;
   addpoint1(pos,mp(-20,-20));
   cx:= 40;
   cy:= 40;
   placement:= cp_bottomleft;
  end;
  if isy then begin
   marker1:= ydials[adial].markers[aindex];
  end
  else begin
   marker1:= xdials[adial].markers[aindex];
  end;
 end;
 with marker1 do begin
  mstr1:= hintcaption;
  if mstr1 = '' then begin
   mstr1:= markerhintcaption;
  end;
  info.caption:= formatfloatmse(value,mstr1)
 end;
 if canevent(tmethod(fonmarkerhint)) then begin
  fonmarkerhint(self,isy,adial,aindex,info);
 end;
 if info.caption <> '' then begin
  application.showhint(self,info);
 end;
end;

procedure tcustomchartedit.clientmouseevent(var info: mouseeventinfoty);
var
 co1: complexty;
 co2: xseriesdataty;
 trace1: integer;
 ar1: integerarty;
 int1,int2: integer;
 bo1: boolean;
begin
 if not (es_processed in info.eventstate) then begin
  fobjectpicker.mouseevent(info);
  if (not (es_processed in info.eventstate) or 
                             (info.eventkind = ek_mousepark)) and 
                      not (csdesigning in componentstate) then begin
   case info.eventkind of
    ek_mousepark: begin
     if ceo_tracehint in foptions then begin
      if not decodenodes(fobjectpicker.currentobjects,trace1,ar1) then begin
       resetnodehint;
      end
      else begin
       if (ar1[0] <> fnodehintindex) or (trace1 <> fnodehinttrace) then begin
        tracehint(trace1,ar1[0]);
        exit;
//        include(info.eventstate,es_processed);
       end;
      end;
     end;
     if (ceo_markerhint in foptions) and
                               getmarker(info.pos,true,bo1,int1,int2) then begin
      markerhint(info.pos,bo1,int1,int2);
      exit;
//      include(info.eventstate,es_processed);
     end;
    end;
    ek_clientmouseleave: begin
     resetnodehint;
    end;
    ek_buttonpress: begin
     if not (oe_readonly in foptionsedit) and 
              not (ceo_noinsert in foptions) and hasactivetrace and
                (info.shiftstate * shiftstatesmask = [ss_left]) then begin
      if pointinrect(info.pos,getdialrect) then begin
       with activetraceitem do begin
        if kind = trk_xseries then begin
         co2:= tracecoordxseries(factivetrace,info.pos);
         insertxseriesdata(co2);
        end
        else begin
         co1:= tracecoordxy(factivetrace,info.pos);
         addxydata(co1.re,co1.im);
        end;
       end;
       include(info.eventstate,es_processed);
       checkvalue;
      end;   
     end;
    end;
   end;
   if not (es_processed in info.eventstate) then begin
    inherited;
   end;
  end;
 end;
end;

function tcustomchartedit.xmarkertochart(const avalue: real;
                                 const adial: integer): integer;
var
 rect1: rectty;
begin
 rect1:= getdialrect;
{$warnings off}
 with tcustomdialcontroller1(xdials[adial]) do begin
{$warnings on}
  if do_log in options then begin
   result:= rect1.x + 
                   chartround(rect1.cx*(chartln(avalue)-flnsstart)/flnrange);
  end
  else begin
   result:= rect1.x + chartround(((avalue-fsstart)/frange)*rect1.cx);
  end;
 end;
end;

function tcustomchartedit.ymarkertochart(const avalue: real;
                                   const adial: integer): integer;
var
 rect1: rectty;
begin
 rect1:= getdialrect;
{$warnings off}
 with tcustomdialcontroller1(ydials[adial]) do begin
{$warnings on}
  if do_log in options then begin
   result:= rect1.y + rect1.cy -
                   chartround(rect1.cy*(chartln(avalue)-flnsstart)/flnrange);
  end
  else begin
   result:= rect1.y + rect1.cy - chartround(((avalue-fsstart)/frange)*rect1.cy);
  end;
 end;
end;

function tcustomchartedit.xcharttomarker(const apos: integer;
                                            const adial: integer): real;
var
 rect1: rectty;
begin
 rect1:= getdialrect;
{$warnings off}
 with tcustomdialcontroller1(xdials[adial]) do begin
{$warnings on}
  if do_log in options then begin
   result:= exp(((apos - rect1.x) / rect1.cx)*flnrange+flnsstart);
  end
  else begin
   result:= start + ((apos - rect1.x) / rect1.cx)*range;
  end;
 end;
end;

function tcustomchartedit.ycharttomarker(const apos: integer;
                                           const adial: integer): real;
var
 rect1: rectty;
begin
 rect1:= getdialrect;
{$warnings off}
 with tcustomdialcontroller1(ydials[adial]) do begin
{$warnings on}
  if do_log in options then begin
   result:= exp(
             ((rect1.y+rect1.cy-apos) / rect1.cy)*flnrange+flnsstart);
  end
  else begin
   result:= start + ((rect1.y+rect1.cy-apos) / rect1.cy)*range;
  end;
 end;
end;

function tcustomchartedit.tracecoordxy(const atrace: integer;
                                              const apos: pointty): complexty;
var
 rect1: rectty;
begin
 if (atrace >= 0) and (atrace < ftraces.count) then begin
  rect1:= getdialrect;
  with ttrace1(traces[atrace]) do begin
   if rect1.cx <= 0 then begin
    result.re:= xstart;
   end
   else begin
    if cto_logx in options then begin
     result.re:= exp(((apos.x - rect1.x) / rect1.cx)*flnxrange+flnxstart);
    end
    else begin
     result.re:= xstart + ((apos.x - rect1.x) / rect1.cx)*xrange;
    end;
   end;
   if rect1.cy <= 0 then begin
    result.im:= ystart;
   end
   else begin
    if cto_logy in options then begin
     result.im:= exp(
             ((rect1.y+rect1.cy-apos.y) / rect1.cy)*flnyrange+flnystart);     
    end
    else begin
     result.im:= ystart + ((rect1.y+rect1.cy-apos.y) / rect1.cy)*yrange;
    end;
   end;
  end;
 end
 else begin
  result:= nullcomplex;
 end;
end;

function tcustomchartedit.tracecoordxseries(const atrace: integer;
                                           const apos: pointty): xseriesdataty;
var
 rect1: rectty;
begin
 if (atrace >= 0) and (atrace < ftraces.count) then begin
  rect1:= getdialrect;
  with traces[atrace] do begin
   result.index:= 0;
   if (count > 0) and (rect1.cx > 0) then begin
    if cto_seriescentered in options then begin
     result.index:= ((apos.x-rect1.x)*count + rect1.cx div 2) div rect1.cx;
    end
    else begin
     result.index:= ((apos.x-rect1.x)*(count-1)) div rect1.cx;
    end;
   end;
   if rect1.cy <= 0 then begin
    result.value:= ystart;
   end
   else begin
    result.value:= ystart + ((rect1.y+rect1.cy-apos.y) / rect1.cy)*yrange;
   end;
  end;
 end
 else begin
  result.value:= 0;
  result.index:= -1;
 end;
end;

function tcustomchartedit.chartcoordxy(const atrace: integer;
                                            const avalue: complexty): pointty;
var
 rect1: rectty;
 x,y: real;
begin
 if (atrace >= 0) and (atrace < ftraces.count) then begin
  rect1:= getdialrect;
  with ttrace1(traces[atrace]) do begin
   if cto_logx in options then begin
    x:= rect1.x + (rect1.cx*(chartln(avalue.re)-flnxstart)/flnxrange);
   end
   else begin
    x:= rect1.x + (((avalue.re-xstart)/xrange)*rect1.cx);
   end;
   if cto_logy in options then begin
    y:= rect1.y + rect1.cy -
      (rect1.cy*(chartln(avalue.im)-flnystart)/flnyrange);
   end
   else begin
    y:= rect1.y + rect1.cy - (((avalue.im-ystart)/yrange)*rect1.cy);
   end;
  end;
  if x > 100000 then begin
   result.x:= 100000;
  end
  else begin
   if x < -100000 then begin
    result.x:= -100000;
   end
   else begin
    result.x:= round(x);
   end;
  end;
  if y > 100000 then begin
   result.y:= 100000;
  end
  else begin
   if y < -100000 then begin
    result.y:= -100000;
   end
   else begin
    result.y:= round(y);
   end;
  end;
 end
 else begin
  result:= nullpoint;
 end;
end;

function tcustomchartedit.chartcoordxseries(const atrace: integer;
                                        const avalue: xseriesdataty): pointty;
var
 rect1: rectty;
 y: real;
begin
 if (atrace >= 0) and (atrace < ftraces.count) then begin
  rect1:= getdialrect;
  with ttrace1(traces[atrace]) do begin
   if (cto_seriescentered in options) or (count = 1) then begin
    result.x:= rect1.x + (avalue.index * rect1.cx+rect1.cx div 2) div count;
   end
   else begin
    result.x:= rect1.x + (avalue.index * rect1.cx) div (count-1);
   end;
   if cto_logy in options then begin
    y:= rect1.y + rect1.cy - 
                          (rect1.cy*(chartln(avalue.value)-flnystart)/flnyrange);
   end
   else begin
    y:= rect1.y + rect1.cy - (((avalue.value-ystart)/yrange)*rect1.cy);
   end;
   if y > 100000 then begin
    result.y:= 100000;
   end
   else begin
    if y < -100000 then begin
     result.y:= -100000;
    end
    else begin
     result.y:= round(y);
    end;
   end;
  end;
 end
 else begin
  result:= nullpoint;
 end; 
end;

function tcustomchartedit.nodepos(const atrace: integer;
                                       const aindex: integer): pointty;
begin
 if (atrace >= 0) and (atrace < ftraces.count) then begin
  with traces[atrace] do begin
   if kind = trk_xseries then begin
    result:= chartcoordxseries(atrace,makexseriesdata(yvalue[aindex],aindex));
   end
   else begin
    result:= chartcoordxy(atrace,xyvalue[aindex]);
   end;
  end;
 end
 else begin
  result:= nullpoint;
 end;
end;

function tcustomchartedit.nearestnode(const apos: pointty; const all: boolean;
                         out atrace,aindex: integer): boolean;   
var
 dist: integer;

 function checkdist(const atrace: integer): integer;
                      //todo: optimze for ordered data
 var
  int1: integer;

  procedure handlepoint(const pt1: pointty);
  var
   int2,int3: integer;
  begin
   int2:= apos.x - pt1.x;
   if abs(int2) > fsnapdist then begin
    exit;
   end;
   int3:= apos.y - pt1.y;
   if abs(int3) > fsnapdist then begin
    exit;
   end;
   int2:= int2*int2;
   int3:= int3*int3;
   int3:= int2+int3;
   if int3 < dist then begin
    dist:= int3;
    result:= int1;
   end;
  end; //handlepoint

 var 
  datahigh: integer;
  px,py: preal;
  pxy: pcomplexty;
 begin
  result:= -1;
  with ftraces[atrace] do begin
   if visible then begin
    datahigh:= count-1;
    if kind = trk_xseries then begin
     py:= ydatapo;
     if py <> nil then begin
      for int1:= 0 to datahigh do begin
       handlepoint(chartcoordxseries(atrace,makexseriesdata(py^,int1)));
       inc(py);
      end;
     end;
    end
    else begin
     pxy:= xydatapo;
     if pxy <> nil then begin
      for int1:= 0 to datahigh do begin
       handlepoint(chartcoordxy(atrace,pxy^));      
       inc(pxy);
      end;
     end
     else begin
      px:= xdatapo;
      py:= ydatapo;
      if (px <> nil) and (py <> nil) then begin
       for int1:= 0 to datahigh do begin
        handlepoint(chartcoordxy(atrace,makecomplex(px^,py^)));
        inc(px);
        inc(py);
       end;
      end;
     end;
    end;
   end;
  end;
 end; //checkdist

var
 int1,int2: integer;
  
begin
 dist:= maxint;
 if hasactivetrace and not all then begin
  atrace:= factivetrace;
  aindex:= checkdist(factivetrace);
 end
 else begin
  if hasactivetrace then begin
   aindex:= checkdist(factivetrace);
   atrace:= factivetrace;
  end;
  for int1:= 0 to traces.count-1 do begin
   int2:= checkdist(int1);
   if int2 >= 0 then begin
    aindex:= int2;
    atrace:= int1;
   end;
  end;    
 end;
 if (dist >= fsnapdist*fsnapdist) then begin
  aindex:= -1;
  atrace:= -1;
 end;
 result:= aindex >= 0;
end;

function tcustomchartedit.nodesinrect(const arect: rectty): integerarty;
var
 px,py: preal;
 pxy: pcomplexty;
 int1,int2: integer;
begin
 result:= nil;
 if hasactivetrace then begin
  with traces[factivetrace] do begin
   int2:= 0;
   setlength(result,count);
   if kind = trk_xseries then begin
    py:= ydatapo;
    if py <> nil then begin
     for int1:= 0 to high(result) do begin
      if pointinrect(chartcoordxseries(factivetrace,
                        makexseriesdata(py^,int1)),arect) then begin
       result[int2]:= int1;
       inc(int2);
      end;
      inc(py);
     end;
    end;
   end
   else begin
    pxy:= xydatapo;
    if pxy <> nil then begin
     for int1:= 0 to high(result) do begin
      if pointinrect(chartcoordxy(factivetrace,pxy^),arect) then begin
       result[int2]:= int1;
       inc(int2);
      end;
      inc(pxy);
     end;
    end
    else begin
     px:= xdatapo;
     py:= ydatapo;
     if (px <> nil) and (py <> nil) then begin
      for int1:= 0 to high(result) do begin
       if pointinrect(chartcoordxy(factivetrace,
                                       makecomplex(px^,py^)),arect) then begin
        result[int2]:= int1;
        inc(int2);
       end;
       inc(px);
       inc(py);
      end;
     end;
    end;
   end;
   setlength(result,int2);
  end;
 end;
end;

function tcustomchartedit.getcursorshape(const sender: tobjectpicker;
                                           var shape: cursorshapety): boolean;
var
 int1: integer;
 bo1: boolean;
begin
 result:= not (cems_markermoving in fmovestate) and sender.moving and
                                                      sender.hascurrentobjects;
 if result then begin
  shape:= cr_none;
 end
 else begin
  if not sender.hascurrentobjects or (cems_markermoving in fmovestate) then begin
   result:= getmarker(sender.pickrect.pos,false,bo1,int1,int1);
   if result then begin
    if bo1 then begin
     shape:= cr_sizever;
    end
    else begin
     shape:= cr_sizehor;
    end;
   end;
  end;
 end;
end;

function tcustomchartedit.encodenodes(const atrace: integer; 
                              const aindex: array of integer): integerarty;
var
 int1,int2: integer;
begin
 int2:= 0;
 for int1:= 0 to atrace - 1 do begin
  int2:= int2 + ftraces[int1].count;
 end;
 setlength(result,length(aindex));
 for int1:= 0 to high(result) do begin
  result[int1]:= int2 + aindex[int1];
 end;
end;

function tcustomchartedit.decodenodes(const aitems: integerarty;
                       out atrace: integer; out aindex: integerarty): boolean;
var
 int1,int2,int3: integer;
 min,max: integer;
begin
 atrace:= -1;
 setlength(aindex,length(aitems));
 for int1:= 0 to high(aindex) do begin
  int2:= aitems[int1];
  if int2 >= 0 then begin
   if atrace < 0 then begin
    min:= 0;
    max:= 0;
    for int3:= 0 to ftraces.count - 1 do begin
     min:= max;
     max:= max + ttrace(ttraces1(ftraces).fitems[int3]).count;
     atrace:= int3;
     if max > int2 then begin
      break;
     end;
    end;
    max:= max-min;
   end;
   int2:= int2 - min;
   if (int2 < 0) or (int2 >= max) then begin //in other trace, invalid
    aindex:= nil;
    atrace:= -1;
    break;
   end;
  end;
  aindex[int1]:= int2;
 end;
 result:= atrace >= 0;
end;

procedure tcustomchartedit.getpickobjects(const sender: tobjectpicker;
                                                    var objects: integerarty);
var
 int1,int2: integer;
 bo1: boolean; 
 rect: rectty;
begin
 objects:= nil;
 rect:= sender.pickrect;
 if sender.rectselecting then begin
  if not readonly then begin
   objects:= encodenodes(factivetrace,nodesinrect(rect));
  end;
 end
 else begin
  if nearestnode(rect.pos,false,int1,int2) then begin
   objects:= encodenodes(int1,int2);
  end
  else begin
   if sender.picking then begin
    if getmarker(sender.pickpos,false,bo1,int1,int2) then begin
     objects:= encodemarker(bo1,int1,int2);
    end;
   end;
  end;
 end;
end;

function tcustomchartedit.limitmoveoffset(const aoffset: pointty): pointty;
begin
 result:= addpoint(aoffset,fpickref);
 fmovestate:= fmovestate - [cems_xbottomlimit,cems_ybottomlimit,
                            cems_xtoplimit,cems_ytoplimit];
 if ops_moving in fobjectpicker.state then begin
  if result.x > foffsetmax.x then begin
   result.x:= foffsetmax.x;
   include(fmovestate,cems_xtoplimit);
  end;
  if result.y > foffsetmax.y then begin
   result.y:= foffsetmax.y;
   include(fmovestate,cems_ytoplimit);
  end;
  if result.x < foffsetmin.x then begin
   result.x:= foffsetmin.x;
   include(fmovestate,cems_xbottomlimit);
  end;
  if result.y < foffsetmin.y then begin
   result.y:= foffsetmin.y;
   include(fmovestate,cems_ybottomlimit);
  end;
 end;
 subpoint1(result,fpickref);
end;

procedure tcustomchartedit.beginpickmove(const sender: tobjectpicker);
var
 rect1: rectty;
 int1,int2,int3,int4: integer;
 mi,ma: pointty;
 pt1: pointty;
 ar1: pointarty;
 objs: integerarty;
 trace1: integer;
 isy: boolean;
 dial1,index1: integer;
begin
 fpickref:= nullpoint;
 rect1:= getdialrect;
 mi.x:= maxint;
 mi.y:= maxint;
 ma.x:= minint;
 ma.y:= minint;
 if decodemarker(sender.currentobjects,isy,dial1,index1) then begin
  include(fmovestate,cems_markermoving);
  fmovestate:= fmovestate - [cems_canbottomlimit,cems_cantoplimit];
  with rect1 do begin
   if isy then begin
    with ydials[dial1].markers[index1] do begin
     int3:= pos;
     ma.y:= y-int3;
     mi.y:= y+cy-int3;
     if (dmo_ordered in options) then begin
      if index1 < ydials[dial1].markers.count - 1 then begin
       int4:= ydials[dial1].markers[index1+1].pos;
       if int4 > y then begin
        ma.y:= int4-int3;
        include(fmovestate,cems_canbottomlimit);
       end;
      end;
      if index1 > 0 then begin
       int4:= ydials[dial1].markers[index1-1].pos;
       if int4 < y+cy then begin
        mi.y:= int4-int3;
        include(fmovestate,cems_cantoplimit);
       end;
      end;
     end;
    end;
   end
   else begin //x
    with xdials[dial1].markers[index1] do begin
     int3:= pos;
     ma.x:= x-int3;
     mi.x:= x+cx-int3;
     if (dmo_ordered in options) then begin
      if index1 > 0 then begin
       int4:= xdials[dial1].markers[index1-1].pos;
       if int4 > x then begin
        ma.x:= int4-int3;
        include(fmovestate,cems_canbottomlimit);
       end;
      end;
      if index1 < xdials[dial1].markers.count - 1 then begin
       int4:= xdials[dial1].markers[index1+1].pos;
       if int4 < x+cx then begin
        mi.x:= int4-int3;
        include(fmovestate,cems_cantoplimit);
       end;
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  exclude(fmovestate,cems_markermoving);
  if readonly then begin
   sender.clear;
   exit;
  end
  else begin
   if decodenodes(sender.currentobjects,trace1,objs) then begin
    setlength(ar1,length(objs));
    for int1:= 0 to high(objs) do begin
     pt1:= nodepos(trace1,objs[int1]);
     ar1[int1]:= pt1;
     if pt1.x < mi.x then begin
      mi.x:= pt1.x;
     end;
     if pt1.y < mi.y then begin
      mi.y:= pt1.y;
     end;
     if pt1.x > ma.x then begin
      ma.x:= pt1.x;
     end;
     if pt1.y > ma.y then begin
      ma.y:= pt1.y;
     end;
    end;
   end;
  end;
 end;
 if cems_markermoving in fmovestate then begin
  foffsetmin:= ma;
  foffsetmax:= mi;
 end
 else begin
  with rect1 do begin
   foffsetmin.x:= x - mi.x;
   foffsetmin.y:= y - mi.y;
   foffsetmax.x:= x + cx - ma.x;
   foffsetmax.y:= y + cy - ma.y;
  end;
  with ftraces[trace1] do begin
   if kind = trk_xseries then begin
    foffsetmin.x:= 0;
    foffsetmax.x:= 0;   
   end
   else begin
    if cto_xordered in options then begin
               //limit to neighbours
     for int1:= 0 to high(ar1) do begin
      int2:= objs[int1];
      if (int2 > 0) and ((int1 = 0) or (objs[int1-1] <> int2 - 1)) then begin
       pt1:= nodepos(trace1,int2-1);
       int3:= pt1.x - ar1[int1].x;
       if int3 > foffsetmin.x then begin
        foffsetmin.x:= int3;
       end;
      end;
      int4:= ftraces[trace1].count - 1;
      if (int2 < int4) and ((int1 = high(ar1)) or 
                            (objs[int1+1] <> int2 + 1)) then begin
       pt1:= nodepos(trace1,int2+1);
       int3:= pt1.x - ar1[int1].x;
       if int3 < foffsetmax.x then begin
        foffsetmax.x:= int3;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustomchartedit.encodemarker(const isy: boolean;
                         const adial,aindex: integer): integerarty;
begin
 setlength(result,1);
 result[0]:= (-2*(aindex+1)) and ((not adial shl 24) or $80fffffe);
 if isy then begin
  inc(result[0]);
 end;
end;

function tcustomchartedit.decodemarker(const aitems: integerarty;
                     out isy: boolean; out adial,aindex: integer): boolean;
begin
 result:= (high(aitems) = 0) and (aitems[0] < 0);
 if result then begin
  aindex:= aitems[0];
  isy:= odd(aindex);
  adial:= (not aindex and $7f000000) shr 24;
  aindex:= integer(-((aindex or $7f000000) and $fffffffe)) div 2 - 1;
// end
// else begin
//  aindex:= -1;
//  adial:= -1;
//  isy:= false;
 end;
end;

procedure tcustomchartedit.dopickmove(const sender: tobjectpicker);
var
 int1,int2: integer;
 pt1: pointty;
 rea1: real;
 da1: xseriesdataty;
 co1,co2: complexty;
 offs: pointty;
 objs: integerarty;
 marker1: tdialmarker;
 trace1,tracebefore: integer;
 dialindex: integer;
 bo1: boolean;
 
begin
 offs:= limitmoveoffset(subpoint(sender.pickoffset,fpickref));
 if cems_markermoving in fmovestate then begin
  decodemarker(sender.currentobjects,bo1,dialindex,int1);
  if bo1 then begin
   marker1:= ydials[dialindex].markers[int1];
   if fmovestate * [cems_cantoplimit,cems_ytoplimit] = 
                           [cems_cantoplimit,cems_ytoplimit] then begin
    marker1.value:= ydials[dialindex].markers[int1-1].value; 
                                             //y is screen reversed
   end
   else begin
    if fmovestate * [cems_canbottomlimit,cems_ybottomlimit] = 
                           [cems_canbottomlimit,cems_ybottomlimit] then begin
     marker1.value:= ydials[dialindex].markers[int1+1].value; 
                                            //y is screen reversed
    end
    else begin
     if offs.y <> 0 then begin
      rea1:= ycharttomarker(marker1.pos+offs.y,dialindex);
      if canevent(tmethod(fonsetmarker)) then begin
       fonsetmarker(self,true,dialindex,int1,realty(rea1));
      end;
      marker1.value:= rea1;
      domarkerchange;
      if canevent(tmethod(fonmarkerentered)) then begin
       fonmarkerentered(self);
      end;
     end;
    end;
   end;
  end
  else begin
   marker1:= xdials[dialindex].markers[int1];
   if fmovestate * [cems_cantoplimit,cems_xtoplimit] = 
                           [cems_cantoplimit,cems_xtoplimit] then begin
    marker1.value:= xdials[dialindex].markers[int1+1].value;
   end
   else begin
    if fmovestate * [cems_canbottomlimit,cems_xbottomlimit] = 
                           [cems_canbottomlimit,cems_xbottomlimit] then begin
     marker1.value:= xdials[dialindex].markers[int1-1].value;
    end
    else begin
     if offs.x <> 0 then begin
      rea1:= xcharttomarker(marker1.pos + offs.x,dialindex);
      if canevent(tmethod(fonsetmarker)) then begin
       fonsetmarker(self,false,dialindex,int1,realty(rea1));
      end;
      marker1.value:= rea1;
      domarkerchange;
      if canevent(tmethod(fonmarkerentered)) then begin
       fonmarkerentered(self);
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  addpoint1(fpickref,offs);
  if decodenodes(sender.currentobjects,trace1,objs) then begin
   tracebefore:= activetrace;
   activetrace:= trace1;
   try
    with activetraceitem do begin
     if kind = trk_xseries then begin
      for int1:= 0 to high(objs) do begin
       int2:= objs[int1];
       pt1:= nodepos(trace1,int2);
       rea1:= yvalue[int2];
       da1:= tracecoordxseries(trace1,addpoint(pt1,offs));
       if offs.y <> 0 then begin //no rounding if nochange
        rea1:= da1.value;
       end;
       yvalue[int2]:= rea1;
      end;
     end
     else begin
      for int1:= 0 to high(objs) do begin
       int2:= objs[int1];
       pt1:= nodepos(trace1,int2);
       co1:= xyvalue[int2];
       co2:= tracecoordxy(trace1,addpoint(pt1,offs));
       if offs.x <> 0 then begin //no rounding if nochange
        co1.re:= co2.re;
       end;
       if offs.y <> 0 then begin //no rounding if nochange
        co1.im:= co2.im;
       end;
       xyvalue[int2]:= co1;
      end;
     end;
    end;
    checkvalue;
   finally
    activetrace:= tracebefore;
   end;
  end;
 end;
end;

procedure tcustomchartedit.pickthumbtrack(const sender: tobjectpicker);
begin
 if not (cems_markermoving in fmovestate) then begin
  dopickmove(sender);
 end;
end;

procedure tcustomchartedit.endpickmove(const sender: tobjectpicker);
begin
 dopickmove(sender);
 if not (cems_markermoving in fmovestate) and not readonly then begin
  addpoint1(sender.mouseeventinfopo^.pos,subpoint(fpickref,sender.pickoffset));
 end;
 exclude(fmovestate,cems_markermoving);
end;

procedure tcustomchartedit.cancelpickmove(const sender: tobjectpicker);
begin
 exclude(fmovestate,cems_markermoving);
end;

procedure tcustomchartedit.drawcrosshaircursor(const canvas: tcanvas; 
                                                         const center: pointty);
begin
 with center do begin
  canvas.drawline(makepoint(0,y),makepoint(clientwidth,y));
  canvas.drawline(makepoint(x,0),makepoint(x,clientheight));
 end;
end;

procedure tcustomchartedit.paintxorpic(const sender: tobjectpicker; 
              const canvas: tcanvas);
var
 ar1: pointarty;
 ar2: segmentarty;
 int1,int2,int3: integer;
 dialindex: integer;
 offs: pointty;
 objs: integerarty;
 trace1: integer;
 rect1: rectty;
 bo1: boolean;
begin
 with sender do begin
  if cems_markermoving in fmovestate then begin
   offs:= limitmoveoffset(pickoffset);
//   rect1:= getdialrect;
   rect1:= innerclientrect;
   decodemarker(sender.currentobjects,bo1,dialindex,int1);
   with rect1 do begin
    if bo1 then begin
     int2:= ydials[dialindex].markers[int1].pos + offs.y;
     canvas.drawline(makepoint(x,int2),makepoint(x+cx,int2));
    end
    else begin
     int2:= xdials[dialindex].markers[int1].pos + offs.x;
     canvas.drawline(makepoint(int2,y),makepoint(int2,y+cy));
    end;
   end;
  end
  else begin
   if decodenodes(currentobjects,trace1,objs) then begin
    if ceo_thumbtrack in foptions then begin
     offs:= nullpoint;
    end
    else begin
     offs:= limitmoveoffset(pickoffset);
    end;
    setlength(ar1,length(objs));
    setlength(ar2,length(objs)*2); //max
    int2:= 0;
    for int1:= 0 to high(objs) do begin
     ar1[int1]:= addpoint(nodepos(trace1,objs[int1]),offs);
     int3:= objs[int1]-1;
     if int3 >= 0 then begin
      ar2[int2].a:= nodepos(trace1,int3);
      ar2[int2].b:= ar1[int1];
      if finditem(objs,int3) >= 0 then begin
       addpoint1(ar2[int2].a,offs);
      end;
      inc(int2);
     end;
     int3:= objs[int1]+1;
     if int3 < traces[trace1].count then begin
      ar2[int2].a:= ar1[int1];
      ar2[int2].b:= nodepos(trace1,int3);
      if finditem(objs,int3) < 0 then begin
       inc(int2);
      end;
     end;
    end;
    setlength(ar2,int2);
    canvas.drawlinesegments(ar2);
    for int1:= 0 to high(ar1) do begin
     canvas.drawellipse(makerect(ar1[int1],makesize(6,6)));
    end;
    if (ops_moving in fobjectpicker.state) then begin
     if decodenodes(sender.mouseoverobjects,trace1,objs) then begin
      drawcrosshaircursor(canvas,addpoint(nodepos(trace1,objs[0]),offs));
     end;
    end;
   end;
  end;
 end;
end;

function tcustomchartedit.getreadonly: boolean;
begin
 result:= oe_readonly in foptionsedit;
end;

procedure tcustomchartedit.setreadonly(const avalue: boolean);
begin
 if avalue then begin
  optionsedit:= optionsedit + [oe_readonly];
 end
 else begin
  optionsedit:= optionsedit - [oe_readonly];
 end;
end;

procedure tcustomchartedit.dokeydown(var ainfo: keyeventinfoty);
var
 trace1,tracebefore: integer;
 ar1: integerarty;
begin
 if not (es_processed in ainfo.eventstate) then begin
  inherited;
 end;
 if not (es_processed in ainfo.eventstate) then begin
  fobjectpicker.dokeydown(ainfo);
 end;
 if not (es_processed in ainfo.eventstate) and (ainfo.key = key_delete) and
     not readonly and not (ceo_nodelete in foptions) and
     (ainfo.shiftstate*shiftstatesmask = []) and 
                                 fobjectpicker.hascurrentobjects  then begin
  if decodenodes(fobjectpicker.currentobjects,trace1,ar1) then begin
   tracebefore:= activetrace;
   activetrace:= trace1;
   try
    activetraceitem.deletedata(ar1);
    fobjectpicker.clear;
    include(ainfo.eventstate,es_processed);
    checkvalue;
   finally
    activetrace:= tracebefore;
   end;
  end;
 end;
end;

procedure tcustomchartedit.dobeforepaint(const acanvas: tcanvas);
begin
 fobjectpicker.dobeforepaint(acanvas);
 inherited;
end;

procedure tcustomchartedit.doafterpaint(const acanvas: tcanvas);
begin
 inherited;
 fobjectpicker.doafterpaint(acanvas);
end;

function tcustomchartedit.chartdataxy: complexarty;
begin
 with ttrace1(activetraceitem) do begin
  forcexyarray;
  result:= copy(xydata);
 end;
end;

function tcustomchartedit.chartdataxseries: realarty;
begin
 result:= copy(activetraceitem.ydata);
end;

procedure tcustomchartedit.dochange;
begin
 resetnodehint;
 if not (ws_loadedproc in fwidgetstate) then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;

procedure tcustomchartedit.domarkerchange;
begin
 if not (ws_loadedproc in fwidgetstate) then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;

procedure tcustomchartedit.change;
begin
 if not (csloading in componentstate) then begin
  dochange;
 end;
end;

function tcustomchartedit.checkvalue: boolean;
begin
 result:= true;
 docheckvalue(result);
 if result then begin  
  if canevent(tmethod(fondataentered)) then begin
   fondataentered(self);
  end;
 end;
end;

procedure tcustomchartedit.dostatread(const reader: tstatreader);
var
 co1: complexty;
 pt1: pointty;
begin
 if canstatstate(optionsedit1,reader) then begin
  inherited;
  with frame do begin
   co1:= zoom;
   co1.re:= reader.readreal('zoomx',co1.re,1,1000);
   co1.im:= reader.readreal('zoomy',co1.im,1,1000);
   zoom:= co1;
   pt1:= scrollpos;
   pt1.x:= reader.readinteger('scrollx',pt1.x,-bigint,0);
   pt1.y:= reader.readinteger('scrolly',pt1.y,-bigint,0);
   scrollpos:= pt1;
  end;
  activetrace:= reader.readinteger('activetrace',activetrace,0,ftraces.count-1);
 end;
 if canstatvalue(optionsedit1,reader) then begin
  doreadvalue(reader);
 end;
end;

procedure tcustomchartedit.dostatwrite(const writer: tstatwriter);
var
 co1: complexty;
 pt1: pointty;
begin
 if canstatstate(optionsedit1,writer) then begin
  inherited;
  with frame do begin
   co1:= zoom;
   writer.writereal('zoomx',co1.re);
   writer.writereal('zoomy',co1.im);
   pt1:= scrollpos;
   writer.writeinteger('scrollx',pt1.x);
   writer.writeinteger('scrolly',pt1.y);
  end;
  writer.writeinteger('activetrace',activetrace);
 end;
 if canstatvalue(optionsedit1,writer) then begin
  dowritevalue(writer);
 end;
end;

procedure tcustomchartedit.statread;
begin
 inherited;
 if (oe1_checkvalueafterstatread in foptionsedit1) and hasactivetrace then begin
  checkvalue;
 end;
end;

procedure tcustomchartedit.setoptions(const avalue: charteditoptionsty);
begin
 if avalue <> foptions then begin
  foptions:= avalue;
  with fobjectpicker do begin
   if ceo_thumbtrack in avalue then begin
    options:= options + [opo_thumbtrack];
   end
   else begin
    options:= options - [opo_thumbtrack];
   end;
  end;
 end; 
end;

procedure tcustomchartedit.loaded;
begin
 inherited;
 include(fwidgetstate,ws_loadedproc);
 try
  change;
 finally
  exclude(fwidgetstate,ws_loadedproc);
 end;
end;

procedure tcustomchartedit.clear;
begin
 inherited;
 doclear;
 change;
end;

function tcustomchartedit.getmarker(const apos: pointty;
       const nolimited: boolean; out isy: boolean;
                                         out adial,aindex: integer): boolean; 
var
 int1,int3: integer;
 marker1: tdialmarker;
begin
 result:= false;
 for int3:= 0 to xdials.count -1 do begin
{$warnings off}
  with tcustomdialcontroller1(xdials[int3]) do begin
{$warnings on}
   checklayout;
   for int1:= 0 to high(tdialmarkers1(markers).fitems) do begin
    marker1:= tdialmarker(tdialmarkers1(markers).fitems[int1]);
    if not (dmo_fix in marker1.options) and 
        (not nolimited or not marker1.limited) and marker1.active and
                 (abs(apos.x-marker1.pos) <= markersnapdist) then begin
     result:= true;
     isy:= false;
     adial:= int3;
     aindex:= int1;
     exit;
    end;
   end;
  end;
 end;
 for int3:= 0 to ydials.count -1 do begin
{$warnings off}
  with tcustomdialcontroller1(ydials[int3]) do begin
{$warnings on}
   checklayout;
   for int1:= 0 to high(tdialmarkers1(markers).fitems) do begin
    marker1:= tdialmarker(tdialmarkers1(markers).fitems[int1]);
    if not (dmo_fix in marker1.options) and 
        (not nolimited or not marker1.limited) and marker1.active and
                    (abs(apos.y-marker1.pos) <= markersnapdist) then begin
     result:= true;
     isy:= true;
     adial:= int3;
     aindex:= int1;
     exit;
    end;
   end;
  end;
 end;
end;

procedure tcustomchartedit.setoptionsedit(const avalue: optionseditty);
begin
 if foptionsedit <> avalue then begin
  transferoptionsedit(self,avalue,foptionsedit,foptionsedit1);
  if oe_readonly in foptionsedit then begin
   fobjectpicker.options:= fobjectpicker.options - [opo_rectselect];
  end
  else begin
   fobjectpicker.options:= fobjectpicker.options + [opo_rectselect];
  end;
  
 end;
end;

{ tcustomxychartedit }

constructor tcustomxychartedit.create(aowner: tcomponent);
begin
 if ftraces = nil then begin
  ftraces:= txytraces.create(self,xordered);
 end;
 inherited;
end;

function tcustomxychartedit.getvalue: complexarty;
begin
 result:= fvalue;
end;

procedure tcustomxychartedit.setvalue(const avalue: complexarty);
begin
 fvalue:= avalue;
 change;
end;

procedure tcustomxychartedit.dochange;
begin
 if hasactivetrace then begin
  activetraceitem.xydata:= fvalue;
 end;
 inherited;
end;

procedure tcustomxychartedit.docheckvalue(var accept: boolean);
var
 ar1: complexarty;
begin
 ar1:= chartdataxy;
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,ar1,accept);
 end;
 if accept then begin
  value:= ar1;
 end;
end;

procedure tcustomxychartedit.doreadvalue(const reader: tstatreader);
var
 int1: integer;
begin
 for int1:= 0 to ftraces.count - 1 do begin
  ftraces[int1].xydata:= reader.readarray('value'+inttostrmse(int1),
                    ftraces[int1].xydata);
 end;
 if hasactivetrace then begin
  value:= activetraceitem.xydata;
 end;
// value:= reader.readarray('value',fvalue);
end;

procedure tcustomxychartedit.dowritevalue(const writer: tstatwriter);
var
 int1: integer;
begin
 for int1:= 0 to ftraces.count - 1 do begin
  writer.writearray('value'+inttostrmse(int1),ftraces[int1].xydata);
 end;
// writer.writearray('value',fvalue);
end;

function tcustomxychartedit.getvalueitems(const index: integer): complexty;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index];
end;

procedure tcustomxychartedit.setvalueitems(const index: integer;
               const avalue: complexty);
begin
 checkarrayindex(fvalue,index);
 fvalue[index]:= avalue;
 change;
end;

function tcustomxychartedit.getreitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index].re;
end;

procedure tcustomxychartedit.setreitems(const index: integer; const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index].re:= avalue;
 change;
end;

function tcustomxychartedit.getimitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index].im;
end;

procedure tcustomxychartedit.setimitems(const index: integer; const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index].im:= avalue;
 change;
end;

class function tcustomxychartedit.xordered: boolean;
begin
 result:= false;
end;

procedure tcustomxychartedit.doclear;
begin
 fvalue:= nil;
end;

{ tcustomxserieschartedit }

function tcustomxserieschartedit.getvalue: realarty;
begin
 result:= fvalue;
// result:= traces[factivetrace].xydata;
end;

procedure tcustomxserieschartedit.setvalue(const avalue: realarty);
begin
 fvalue:= avalue;
 change;
end;

procedure tcustomxserieschartedit.dochange;
begin
 if hasactivetrace then begin
  activetraceitem.ydata:= fvalue;
 end;
 inherited;
end;

procedure tcustomxserieschartedit.docheckvalue(var accept: boolean);
var
 ar1: realarty;
begin
 ar1:= chartdataxseries;
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,ar1,accept);
 end;
 if accept then begin
  value:= ar1;
 end;
end;

procedure tcustomxserieschartedit.doreadvalue(const reader: tstatreader);
begin
 value:= reader.readarray('value',fvalue);
end;

procedure tcustomxserieschartedit.dowritevalue(const writer: tstatwriter);
begin
 writer.writearray('value',fvalue);
end;

function tcustomxserieschartedit.getvalueitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index];
end;

procedure tcustomxserieschartedit.setvalueitems(const index: integer;
               const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index]:= avalue;
 change;
end;

procedure tcustomxserieschartedit.doclear;
begin
 fvalue:= nil;
end;

{ tcustomorderedxychartedit }

class function tcustomorderedxychartedit.xordered: boolean;
begin
 result:= true;
end;

end.
