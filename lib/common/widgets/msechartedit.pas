{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

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
 classes,msechart,mseguiglob,mseevent,mseeditglob,msegraphutils,msetypes,
 mseobjectpicker,msepointer,msegraphics,mseclasses,msestat,msestatfile,
 msestrings;
 
const
 defaultsnapdist = 4;
 defaultchartoptionsedit = [oe_checkvaluepaststatread,oe_savevalue,oe_savestate];
 
type
 setcomplexareventty = procedure(const sender: tobject;
                var avalue: complexarty; var accept: boolean) of object;
 setrealareventty = procedure(const sender: tobject;
                var avalue: realarty; var accept: boolean) of object;
 charteditoptionty = (ceo_noinsert,ceo_thumbtrack);
 charteditoptionsty = set of charteditoptionty;

 tcustomchartedit = class(tchart,iobjectpicker)
  private
   factivetrace: integer;
   foptionsedit: optionseditty;
   fobjectpicker: tobjectpicker;
   fsnapdist: integer;
   foffsetmin: pointty;
   foffsetmax: pointty;
   fvaluechecking: integer;
   fonchange: notifyeventty;
   fondataentered: notifyeventty;
   foptions: charteditoptionsty;
   fpickref: pointty;
   procedure setactivetrace(const avalue: integer);
   function limitmoveoffset(const aoffset: pointty): pointty;
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   procedure setoptions(const avalue: charteditoptionsty);
   procedure dopickmove(const sender: tobjectpicker);
  protected
   function hasactivetrace: boolean;
   function nodepos(const aindex: integer): pointty;
   function nearestnode(const apos: pointty): integer;   
   function nodesinrect(const arect: rectty): integerarty;
   function chartcoordxy(const avalue: complexty): pointty;
   function tracecoordxy(const apos: pointty): complexty;
   function chartcoordxseries(const avalue: xseriesdataty): pointty;
   function tracecoordxseries(const apos: pointty): xseriesdataty;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var ainfo: keyeventinfoty); override;
   procedure dobeforepaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const acanvas: tcanvas); override;
   procedure dochange; virtual;
   function chartdataxy: complexarty;
   function chartdataxseries: realarty;
   function activetraceitem: ttrace;

   procedure doreadvalue(const reader: tstatreader); virtual; abstract;
   procedure dowritevalue(const writer: tstatwriter); virtual; abstract;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure statread; override;
   procedure docheckvalue(var accept: boolean); virtual; abstract;

    //iobjectpicker
   function getcursorshape(const sender: tobjectpicker;
                            var shape: cursorshapety): boolean;
   procedure getpickobjects(const sender: tobjectpicker;
                                    var objects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure pickthumbtrack(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const canvas: tcanvas);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function checkvalue: boolean;
   property readonly: boolean read getreadonly write setreadonly;
   property activetrace: integer read factivetrace 
                           write setactivetrace default 0;
   property optionsedit: optionseditty read foptionsedit 
                           write foptionsedit default defaultchartoptionsedit;
   property snapdist: integer read fsnapdist write fsnapdist 
                                              default defaultsnapdist;
   property options: charteditoptionsty read foptions write setoptions default [];
   property onchange: notifyeventty read fonchange write fonchange;

 end;

 txychartedit = class(tcustomchartedit)
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
  public
   constructor create(aowner: tcomponent); override;
   property value: complexarty read getvalue write setvalue;
   property valueitems[const index: integer]: complexty read getvalueitems 
                                                       write setvalueitems;
   property reitems[const index: integer]: real read getreitems write setreitems;
   property imitems[const index: integer]: real read getimitems write setimitems;
  published
   property statfile;
   property statvarname;
   property ondataentered: notifyeventty read fondataentered 
                                                 write fondataentered;
   property onsetvalue: setcomplexareventty read fonsetvalue write fonsetvalue;
   property activetrace;
   property optionsedit;
   property snapdist;
   property options;
   property onchange;
 end;
 
 torderedxychartedit = class(txychartedit)
  protected
   class function xordered: boolean; override;
  public
 end;
 
 txserieschartedit = class(tcustomchartedit)
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
  public
   property value: realarty read getvalue write setvalue;
   property valueitems[const index: integer]: real read getvalueitems 
                                                       write setvalueitems;
  published
   property statfile;
   property statvarname;
   property ondataentered: notifyeventty read fondataentered 
                                                 write fondataentered;
   property onsetvalue: setrealareventty read fonsetvalue write fonsetvalue;
   property activetrace;
   property optionsedit;
   property snapdist;
   property options;
   property onchange;
 end;
  
implementation
uses
 msereal,msekeyboard,msedatalist,msegui,sysutils;
 
type
 ttraces1 = class(ttraces);
  
{ tcustomchartedit }

constructor tcustomchartedit.create(aowner: tcomponent);
begin
 fsnapdist:= defaultsnapdist;
 foptionsedit:= defaultchartoptionsedit;
 inherited;
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

procedure tcustomchartedit.setactivetrace(const avalue: integer);
begin
 if avalue < 0 then begin
  raise exception.create('Negative value');
 end;
 factivetrace:= avalue;
 if traces.count <= avalue then begin
  traces.count:= avalue+1;
 end;
end;

function tcustomchartedit.activetraceitem: ttrace;
begin
 if factivetrace >= traces.count then begin
  traces.count:= factivetrace+1;
 end;
 result:= ttrace(ttraces1(traces).fitems[factivetrace]);
end;

function tcustomchartedit.hasactivetrace: boolean;
begin
 result:= (factivetrace >= 0) and (factivetrace < traces.count);
end;

procedure tcustomchartedit.clientmouseevent(var info: mouseeventinfoty);
var
 co1: complexty;
 co2: xseriesdataty;
begin
 if not (es_processed in info.eventstate) then begin
  fobjectpicker.mouseevent(info);
  if not (es_processed in info.eventstate) and 
     not (csdesigning in componentstate) and 
     not (oe_readonly in foptionsedit) and  not (ceo_noinsert in foptions) and 
                                                      hasactivetrace then begin
   if (info.eventkind = ek_buttonpress) and 
             (info.shiftstate * shiftstatesmask = [ss_left]) then begin
    if pointinrect(info.pos,innerclientrect) then begin
     with activetraceitem do begin
      if kind = trk_xseries then begin
       co2:= tracecoordxseries(info.pos);
       insertxseriesdata(co2);
      end
      else begin
       co1:= tracecoordxy(info.pos);
       addxydata(co1.re,co1.im);
      end;
     end;
     include(info.eventstate,es_processed);
     checkvalue;
    end;   
   end;
   if not (es_processed in info.eventstate) then begin
    inherited;
   end;
  end;
 end;
end;

function tcustomchartedit.tracecoordxy(const apos: pointty): complexty;
var
 rect1: rectty;
begin
 rect1:= innerclientrect;
 with traces[factivetrace] do begin
  if rect1.cx <= 0 then begin
   result.re:= xstart;
  end
  else begin
   result.re:= xstart + ((apos.x - rect1.x) / rect1.cx)*xrange;
  end;
  if rect1.cy <= 0 then begin
   result.im:= ystart;
  end
  else begin
   result.im:= ystart + ((rect1.y+rect1.cy-apos.y) / rect1.cy)*yrange;
  end;
 end;
end;

function tcustomchartedit.tracecoordxseries(const apos: pointty): xseriesdataty;
var
 rect1: rectty;
begin
 rect1:= innerclientrect;
 with traces[factivetrace] do begin
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
end;

function tcustomchartedit.chartcoordxy(const avalue: complexty): pointty;
var
 rect1: rectty;
begin
 rect1:= innerclientrect;
 with traces[factivetrace] do begin
  result.x:= rect1.x + round(((avalue.re-xstart)/xrange)*rect1.cx);
  result.y:= rect1.y + rect1.cy - round(((avalue.im-ystart)/yrange)*rect1.cy);
 end;
end;

function tcustomchartedit.chartcoordxseries(const avalue: xseriesdataty): pointty;
var
 rect1: rectty;
begin
 rect1:= innerclientrect;
 with traces[factivetrace] do begin
  if (cto_seriescentered in options) or (count = 1) then begin
   result.x:= rect1.x + (avalue.index * rect1.cx+rect1.cx div 2) div count;
  end
  else begin
   result.x:= rect1.x + (avalue.index * rect1.cx) div (count-1);
  end;
  result.y:= rect1.y + rect1.cy - round(((avalue.value-ystart)/yrange)*rect1.cy);
 end;
end;

function tcustomchartedit.nodepos(const aindex: integer): pointty;
begin
 with traces[factivetrace] do begin
  if kind = trk_xseries then begin
   result:= chartcoordxseries(makexseriesdata(yvalue[aindex],aindex));
  end
  else begin
   result:= chartcoordxy(xyvalue[aindex]);
  end;
 end;
end;

function tcustomchartedit.nearestnode(const apos: pointty): integer;   
var
 dist: integer;
 int1: integer;

 procedure handlepoint(const pt1: pointty);
 var
  int2,int3: integer;
 begin
  int2:= apos.x - pt1.x;
  int2:= int2*int2;
  int3:= apos.y - pt1.y;
  int3:= int3*int3;
  int3:= int2+int3;
  if int3 < dist then begin
   dist:= int3;
   result:= int1;
  end;
 end;

var 
 datahigh: integer;
 px,py: preal;
 pxy: pcomplexty;
 pt1: pointty;
begin
 result:= -1;
 if hasactivetrace then begin
  with traces[factivetrace] do begin
   dist:= maxint;
   datahigh:= count-1;
   if kind = trk_xseries then begin
    py:= ydatapo;
    if py <> nil then begin
     for int1:= 0 to datahigh do begin
      handlepoint(chartcoordxseries(makexseriesdata(py^,int1)));
      inc(py);
     end;
    end;
   end
   else begin
    pxy:= xydatapo;
    if pxy <> nil then begin
     for int1:= 0 to datahigh do begin
      handlepoint(chartcoordxy(pxy^));
      
      inc(pxy);
     end;
    end
    else begin
     px:= xdatapo;
     py:= ydatapo;
     if (px <> nil) and (py <> nil) then begin
      for int1:= 0 to datahigh do begin
       handlepoint(chartcoordxy(makecomplex(px^,py^)));
       inc(px);
       inc(py);
      end;
     end;
    end;
   end;
   if (dist >= fsnapdist*fsnapdist) then begin
    result:= -1;
   end;
  end;
 end;
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
      if pointinrect(chartcoordxseries(
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
      if pointinrect(chartcoordxy(pxy^),arect) then begin
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
       if pointinrect(chartcoordxy(makecomplex(px^,py^)),arect) then begin
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
begin
 result:= sender.moving and sender.hascurrentobjects;
 if result then begin
  shape:= cr_none;
 end;
end;

procedure tcustomchartedit.getpickobjects(const sender: tobjectpicker;
                                                    var objects: integerarty);
var
 int1: integer;
 rect: rectty;
begin
 rect:= sender.pickrect;
 if sender.rectselecting then begin
  objects:= nodesinrect(rect);
 end
 else begin
  int1:= nearestnode(rect.pos);
  if int1 >= 0 then begin
   setlength(objects,1);
   objects[0]:= int1;
  end
  else begin
   objects:= nil;
  end;
 end;
end;

function tcustomchartedit.limitmoveoffset(const aoffset: pointty): pointty;
begin
 result:= addpoint(aoffset,fpickref);
 if ops_moving in fobjectpicker.state then begin
  if result.x > foffsetmax.x then begin
   result.x:= foffsetmax.x;
  end;
  if result.y > foffsetmax.y then begin
   result.y:= foffsetmax.y;
  end;
  if result.x < foffsetmin.x then begin
   result.x:= foffsetmin.x;
  end;
  if result.y < foffsetmin.y then begin
   result.y:= foffsetmin.y;
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
begin
 fpickref:= nullpoint;
 rect1:= innerclientrect;
 mi.x:= maxint;
 mi.y:= maxint;
 ma.x:= minint;
 ma.y:= minint;
 objs:= sender.currentobjects;
 setlength(ar1,length(objs));
 for int1:= 0 to high(objs) do begin
  pt1:= nodepos(objs[int1]);
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
 with rect1 do begin
  foffsetmin.x:= x - mi.x;
  foffsetmin.y:= y - mi.y;
  foffsetmax.x:= x + cx - ma.x;
  foffsetmax.y:= y + cy - ma.y;
 end;
 with activetraceitem do begin
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
      pt1:= nodepos(int2-1);
      int3:= pt1.x - ar1[int1].x;
      if int3 > foffsetmin.x then begin
       foffsetmin.x:= int3;
      end;
     end;
     int4:= traces[factivetrace].count - 1;
     if (int2 < int4) and ((int1 = high(ar1)) or 
                           (objs[int1+1] <> int2 + 1)) then begin
      pt1:= nodepos(int2+1);
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

procedure tcustomchartedit.dopickmove(const sender: tobjectpicker);
var
 int1,int2: integer;
 pt1: pointty;
 rea1: real;
 da1: xseriesdataty;
 co1,co2: complexty;
 offs: pointty;
 objs: integerarty;
begin
 offs:= limitmoveoffset(subpoint(sender.pickoffset,fpickref));
 addpoint1(fpickref,offs);
 objs:= sender.currentobjects;
 with activetraceitem do begin
  if kind = trk_xseries then begin
   for int1:= 0 to high(objs) do begin
    int2:= objs[int1];
    pt1:= nodepos(int2);
    rea1:= yvalue[int2];
    da1:= tracecoordxseries(addpoint(pt1,offs));
    if offs.y <> 0 then begin //no rounding if nochange
     rea1:= da1.value;
    end;
    yvalue[int2]:= rea1;
   end;
  end
  else begin
   for int1:= 0 to high(objs) do begin
    int2:= objs[int1];
    pt1:= nodepos(int2);
    co1:= xyvalue[int2];
    co2:= tracecoordxy(addpoint(pt1,offs));
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
end;

procedure tcustomchartedit.pickthumbtrack(const sender: tobjectpicker);
begin
 dopickmove(sender);
end;

procedure tcustomchartedit.endpickmove(const sender: tobjectpicker);
begin
 dopickmove(sender);
 addpoint1(sender.mouseeventinfopo^.pos,subpoint(fpickref,sender.pickoffset));
end;

procedure tcustomchartedit.paintxorpic(const sender: tobjectpicker; 
              const canvas: tcanvas);
var
 ar1: pointarty;
 ar2: segmentarty;
 int1,int2,int3: integer;
 offs: pointty;
 objs: integerarty;
 pt1: pointty;
begin
 with sender do begin
  objs:= currentobjects;
  if objs <> nil then begin
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
    ar1[int1]:= addpoint(nodepos(objs[int1]),offs);
    int3:= objs[int1]-1;
    if int3 >= 0 then begin
     ar2[int2].a:= nodepos(int3);
     ar2[int2].b:= ar1[int1];
     if finditem(objs,int3) >= 0 then begin
      addpoint1(ar2[int2].a,offs);
     end;
     inc(int2);
    end;
    int3:= objs[int1]+1;
    if int3 < traces[factivetrace].count then begin
     ar2[int2].a:= ar1[int1];
     ar2[int2].b:= nodepos(int3);
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
   if (ops_moving in fobjectpicker.state) {and (high(objs) = 0)} then begin
    objs:= sender.mouseoverobjects;
    if objs <> nil then begin
     pt1:= addpoint(nodepos(objs[0]),offs);
     canvas.drawline(makepoint(0,pt1.y),makepoint(clientwidth,pt1.y));
     canvas.drawline(makepoint(pt1.x,0),makepoint(pt1.x,clientheight));
                     //crosshair cursor
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
begin
 if not (es_processed in ainfo.eventstate) then begin
  inherited;
 end;
 if not (es_processed in ainfo.eventstate) then begin
  fobjectpicker.dokeydown(ainfo);
 end;
 if not (es_processed in ainfo.eventstate) and (ainfo.key = key_delete) and
     not readonly and (ainfo.shiftstate*shiftstatesmask = []) and 
                                 fobjectpicker.hascurrentobjects  then begin
  activetraceitem.deletedata(fobjectpicker.currentobjects);
  fobjectpicker.clear;
  include(ainfo.eventstate,es_processed);
  checkvalue;
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
 result:= copy(activetraceitem.xydata);
end;

function tcustomchartedit.chartdataxseries: realarty;
begin
 result:= copy(activetraceitem.ydata);
end;

procedure tcustomchartedit.dochange;
begin
// activetraceitem.xydata:= fvalue;
 if not (ws_loadedproc in fwidgetstate) then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;
{
procedure tcustomchartedit.changed;
begin
 dochange;
end;
}
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
begin
 if oe_savestate in foptionsedit then begin
  inherited;
 end;
 if oe_savevalue in foptionsedit then begin
  doreadvalue(reader);
 end;
end;

procedure tcustomchartedit.dostatwrite(const writer: tstatwriter);
begin
 if oe_savestate in foptionsedit then begin
  inherited;
 end;
 if oe_savevalue in foptionsedit then begin
  dowritevalue(writer);
 end;
end;

procedure tcustomchartedit.statread;
begin
 inherited;
 if oe_checkvaluepaststatread in foptionsedit then begin
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

{ txychartedit }

constructor txychartedit.create(aowner: tcomponent);
begin
 if ftraces = nil then begin
  ftraces:= txytraces.create(self,xordered);
 end;
 inherited;
end;

function txychartedit.getvalue: complexarty;
begin
 result:= fvalue;
// result:= traces[factivetrace].xydata;
end;

procedure txychartedit.setvalue(const avalue: complexarty);
begin
 fvalue:= avalue;
 dochange;
end;

procedure txychartedit.dochange;
begin
 activetraceitem.xydata:= fvalue;
 inherited;
end;

procedure txychartedit.docheckvalue(var accept: boolean);
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

procedure txychartedit.doreadvalue(const reader: tstatreader);
begin
 value:= reader.readarray('value',fvalue);
end;

procedure txychartedit.dowritevalue(const writer: tstatwriter);
begin
 writer.writearray('value',fvalue);
end;

function txychartedit.getvalueitems(const index: integer): complexty;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index];
end;

procedure txychartedit.setvalueitems(const index: integer;
               const avalue: complexty);
begin
 checkarrayindex(fvalue,index);
 fvalue[index]:= avalue;
 dochange;
end;

function txychartedit.getreitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index].re;
end;

procedure txychartedit.setreitems(const index: integer; const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index].re:= avalue;
 dochange;
end;

function txychartedit.getimitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index].im;
end;

procedure txychartedit.setimitems(const index: integer; const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index].im:= avalue;
 dochange;
end;

class function txychartedit.xordered: boolean;
begin
 result:= false;
end;

{ txserieschartedit }

function txserieschartedit.getvalue: realarty;
begin
 result:= fvalue;
// result:= traces[factivetrace].xydata;
end;

procedure txserieschartedit.setvalue(const avalue: realarty);
begin
 fvalue:= avalue;
 dochange;
end;

procedure txserieschartedit.dochange;
begin
 activetraceitem.ydata:= fvalue;
 inherited;
end;

procedure txserieschartedit.docheckvalue(var accept: boolean);
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

procedure txserieschartedit.doreadvalue(const reader: tstatreader);
begin
 value:= reader.readarray('value',fvalue);
end;

procedure txserieschartedit.dowritevalue(const writer: tstatwriter);
begin
 writer.writearray('value',fvalue);
end;

function txserieschartedit.getvalueitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index];
end;

procedure txserieschartedit.setvalueitems(const index: integer;
               const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index]:= avalue;
 dochange;
end;

{ torderedxychartedit }

class function torderedxychartedit.xordered: boolean;
begin
 result:= true;
end;

end.
