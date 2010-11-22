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
                
 tchartedit = class(tchart,iobjectpicker)
  private
   factivetrace: integer;
   foptionsedit: optionseditty;
   fobjectpicker: tobjectpicker;
   fsnapdist: integer;
   foffsetmin: pointty;
   foffsetmax: pointty;
   fvalue: complexarty;
   fvaluechecking: integer;
   fonchange: notifyeventty;
   fondataentered: notifyeventty;
   fonsetvalue: setcomplexareventty;
   procedure setactivetrace(const avalue: integer);
   function limitmoveoffset(const aoffset: pointty): pointty;
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   function getvalue: complexarty;
   procedure setvalue(const avalue: complexarty);
   function getvalueitems(const index: integer): complexty;
   procedure setvalueitems(const index: integer; const avalue: complexty);
   function getreitems(const index: integer): real;
   procedure setreitems(const index: integer; const avalue: real);
   function getimitems(const index: integer): real;
   procedure setimitems(const index: integer; const avalue: real);
  protected
   function hasactivetrace: boolean;
   function nodepos(const aindex: integer): pointty;
   function nearestnode(const apos: pointty): integer;   
   function nodesinrect(const arect: rectty): integerarty;
   function chartcoord(const avalue: complexty): pointty;
   function tracecoord(const apos: pointty): complexty;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var ainfo: keyeventinfoty); override;
   procedure dobeforepaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const acanvas: tcanvas); override;
   procedure dochange; virtual;
   function chartdata: complexarty;

   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure statread; override;

    //iobjectpicker
   function getcursorshape(const sender: tobjectpicker;
                            var shape: cursorshapety): boolean;
   procedure getpickobjects(const sender: tobjectpicker;
                                    var objects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const canvas: tcanvas);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
//   procedure changed;
   function checkvalue: boolean; virtual;
   property readonly: boolean read getreadonly write setreadonly;
   property value: complexarty read getvalue write setvalue;
   property valueitems[const index: integer]: complexty read getvalueitems 
                                                       write setvalueitems;
   property reitems[const index: integer]: real read getreitems write setreitems;
   property imitems[const index: integer]: real read getimitems write setimitems;
  published
   property activetrace: integer read factivetrace 
                           write setactivetrace default 0;
   property optionsedit: optionseditty read foptionsedit 
                           write foptionsedit default defaultchartoptionsedit;
   property snapdist: integer read fsnapdist write fsnapdist 
                                              default defaultsnapdist;

   property statfile;
   property statvarname;
   property onchange: notifyeventty read fonchange write fonchange;
   property ondataentered: notifyeventty read fondataentered 
                                                 write fondataentered;
   property onsetvalue: setcomplexareventty read fonsetvalue write fonsetvalue;
 end;
 
implementation
uses
 msereal,msekeyboard,msedatalist,msegui;
 
{ tchartedit }

constructor tchartedit.create(aowner: tcomponent);
begin
 fsnapdist:= defaultsnapdist;
 foptionsedit:= defaultchartoptionsedit;
 inherited;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self));
 fobjectpicker.options:= [opo_mousemoveobjectquery,opo_rectselect,
                          opo_multiselect];
end;

destructor tchartedit.destroy;
begin
 fobjectpicker.free;
 inherited;
end;

procedure tchartedit.setactivetrace(const avalue: integer);
begin
 factivetrace:= avalue;
end;

function tchartedit.hasactivetrace: boolean;
begin
 result:= (factivetrace >= 0) and (factivetrace < traces.count);
end;

procedure tchartedit.clientmouseevent(var info: mouseeventinfoty);
var
 co1: complexty;
begin
 if not (es_processed in info.eventstate) then begin
  fobjectpicker.mouseevent(info);
  if not (es_processed in info.eventstate) and 
     not (csdesigning in componentstate) and 
         not (oe_readonly in foptionsedit) and hasactivetrace then begin
   if (info.eventkind = ek_buttonpress) and 
             (info.shiftstate * shiftstatesmask = [ss_left]) then begin
    if pointinrect(info.pos,innerclientrect) then begin
     co1:= tracecoord(info.pos);
     with traces[factivetrace] do begin
      addxydata(co1.re,co1.im);
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

function tchartedit.tracecoord(const apos: pointty): complexty;
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

function tchartedit.chartcoord(const avalue: complexty): pointty;
var
 rect1: rectty;
begin
 rect1:= innerclientrect;
 with traces[factivetrace] do begin
  result.x:= rect1.x + round(((avalue.re-start)/xrange)*rect1.cx);
  result.y:= rect1.y + rect1.cy - round(((avalue.im-start)/xrange)*rect1.cy);
 end;
end;

function tchartedit.nodepos(const aindex: integer): pointty;
begin
 with traces[factivetrace] do begin
  result:= chartcoord(xyvalue[aindex]);
 end;
end;

function tchartedit.nearestnode(const apos: pointty): integer;   
var
 dist: integer;
 int1,int2,int3: integer;
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
   pxy:= xydatapo;
   if pxy <> nil then begin
    for int1:= 0 to datahigh do begin
     pt1:= chartcoord(pxy^);
     int2:= apos.x - pt1.x;
     int2:= int2*int2;
     int3:= apos.y - pt1.y;
     int3:= int3*int3;
     int3:= int2+int3;
     if int3 < dist then begin
      dist:= int3;
      result:= int1;
     end;
     inc(pxy);
    end;
   end
   else begin
    px:= xdatapo;
    py:= ydatapo;
    if (px <> nil) and (py <> nil) then begin
     for int1:= 0 to datahigh do begin
      pt1:= chartcoord(makecomplex(px^,py^));
      int2:= apos.x - pt1.x;
      int2:= int2*int2;
      int3:= apos.y - pt1.y;
      int3:= int3*int3;
      int3:= int2+int3;
      if int3 < dist then begin
       dist:= int3;
       result:= int1;
      end;
      inc(px);
      inc(py);
     end;
    end;
   end;
   if (dist >= fsnapdist*fsnapdist) then begin
    result:= -1;
   end;
  end;
 end;
end;

function tchartedit.nodesinrect(const arect: rectty): integerarty;
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
   pxy:= xydatapo;
   if pxy <> nil then begin
    for int1:= 0 to high(result) do begin
     if pointinrect(chartcoord(pxy^),arect) then begin
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
      if pointinrect(chartcoord(makecomplex(px^,py^)),arect) then begin
       result[int2]:= int1;
       inc(int2);
      end;
      inc(px);
      inc(py);
     end;
    end;
   end;
   setlength(result,int2);
  end;
 end;
end;

function tchartedit.getcursorshape(const sender: tobjectpicker;
                                           var shape: cursorshapety): boolean;
begin
 result:= sender.moving and sender.hascurrentobjects;
 if result then begin
  shape:= cr_none;
 end;
end;

procedure tchartedit.getpickobjects(const sender: tobjectpicker;
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

function tchartedit.limitmoveoffset(const aoffset: pointty): pointty;
begin
 result:= aoffset;
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
end;

procedure tchartedit.beginpickmove(const sender: tobjectpicker);
var
 rect1: rectty;
 int1,int2,int3,int4: integer;
 mi,ma: pointty;
 pt1: pointty;
 ar1: pointarty;
 objs: integerarty;
begin
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
 if cto_xordered in traces[factivetrace].options then begin
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

procedure tchartedit.endpickmove(const sender: tobjectpicker);
var
 int1,int2: integer;
 pt1: pointty;
 co1,co2: complexty;
 offs: pointty;
 objs: integerarty;
begin
 offs:= limitmoveoffset(sender.pickoffset);
 objs:= sender.currentobjects;
 for int1:= 0 to high(objs) do begin
  int2:= objs[int1];
  pt1:= nodepos(int2);
  co1:= traces[factivetrace].xyvalue[int2];
  co2:= tracecoord(addpoint(pt1,offs));
  if sender.pickoffset.x <> 0 then begin //no rounding if nochange
   co1.re:= co2.re;
  end;
  if sender.pickoffset.y <> 0 then begin //no rounding if nochange
   co1.im:= co2.im;
  end;
  traces[factivetrace].xyvalue[int2]:= co1;
 end;
 checkvalue;
end;

procedure tchartedit.paintxorpic(const sender: tobjectpicker; 
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
   offs:= limitmoveoffset(pickoffset);
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

function tchartedit.getreadonly: boolean;
begin
 result:= oe_readonly in foptionsedit;
end;

procedure tchartedit.setreadonly(const avalue: boolean);
begin
 if avalue then begin
  optionsedit:= optionsedit + [oe_readonly];
 end
 else begin
  optionsedit:= optionsedit - [oe_readonly];
 end;
end;

procedure tchartedit.dokeydown(var ainfo: keyeventinfoty);
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
  traces[factivetrace].deletedata(fobjectpicker.currentobjects);
  fobjectpicker.clear;
  include(ainfo.eventstate,es_processed);
  checkvalue;
 end;
end;

procedure tchartedit.dobeforepaint(const acanvas: tcanvas);
begin
 fobjectpicker.dobeforepaint(acanvas);
 inherited;
end;

procedure tchartedit.doafterpaint(const acanvas: tcanvas);
begin
 inherited;
 fobjectpicker.doafterpaint(acanvas);
end;

function tchartedit.getvalue: complexarty;
begin
 result:= fvalue;
// result:= traces[factivetrace].xydata;
end;

function tchartedit.chartdata: complexarty;
begin
 result:= copy(traces[factivetrace].xydata);
end;

procedure tchartedit.setvalue(const avalue: complexarty);
begin
 fvalue:= avalue;
 dochange;
end;

procedure tchartedit.dochange;
begin
 traces[factivetrace].xydata:= fvalue;
 if not (ws_loadedproc in fwidgetstate) then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;
{
procedure tchartedit.changed;
begin
 dochange;
end;
}
function tchartedit.checkvalue: boolean;
var
 ar1: complexarty;
begin
 result:= true;
 ar1:= chartdata;
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,ar1,result);
 end;
 if result then begin
  value:= ar1;
  if canevent(tmethod(fondataentered)) then begin
   fondataentered(self);
  end;
 end;
end;

procedure tchartedit.dostatread(const reader: tstatreader);
begin
 if oe_savestate in foptionsedit then begin
  inherited;
 end;
 if oe_savevalue in foptionsedit then begin
  value:= reader.readarray('value',fvalue);
 end;
end;

procedure tchartedit.dostatwrite(const writer: tstatwriter);
begin
 if oe_savestate in foptionsedit then begin
  inherited;
 end;
 if oe_savevalue in foptionsedit then begin
  writer.writearray('value',fvalue);
 end;
end;

procedure tchartedit.statread;
begin
 inherited;
 if oe_checkvaluepaststatread in foptionsedit then begin
  checkvalue;
 end;
end;

function tchartedit.getvalueitems(const index: integer): complexty;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index];
end;

procedure tchartedit.setvalueitems(const index: integer;
               const avalue: complexty);
begin
 checkarrayindex(fvalue,index);
 fvalue[index]:= avalue;
 dochange;
end;

function tchartedit.getreitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index].re;
end;

procedure tchartedit.setreitems(const index: integer; const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index].re:= avalue;
 dochange;
end;

function tchartedit.getimitems(const index: integer): real;
begin
 checkarrayindex(fvalue,index);
 result:= fvalue[index].im;
end;

procedure tchartedit.setimitems(const index: integer; const avalue: real);
begin
 checkarrayindex(fvalue,index);
 fvalue[index].im:= avalue;
 dochange;
end;

end.
