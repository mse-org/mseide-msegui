unit msedial;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msewidgets,msegraphutils,msegraphics,msegui,msearrayprops,mseclasses,
 msetypes;
type
 
 dialstatety = (dis_layoutvalid);
 dialstatesty = set of dialstatety;
 
 dialtickinfoty = record
  ticks: segmentarty;
  interval: real;
  color: colorty;
  width: integer;
  indent: integer;
  length: integer;
 end;

 markerinfoty = record
  active: boolean;
  line: segmentty;
  color: colorty;
  width: integer;
  indent: integer;
  length: integer;
  value: realty;
 end;
 
 tdialmarker = class(townedpersistent)
  private
   finfo: markerinfoty;
   flayoutvalid: boolean;
   procedure changed;
   procedure setcolor(const avalue: colorty);
   procedure setwidth(const avalue: integer);
   procedure setindent(const avalue: integer);
   procedure setlength(const avalue: integer);
   procedure setvalue(const avalue: realty);
   procedure checklayout;
   procedure readvalue(reader: treader);
   procedure writevalue(writer: twriter);
  protected
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tobject); override;
   procedure paint(const acanvas: tcanvas);
  published
   property color: colorty read finfo.color write setcolor default cl_black; 
   property width: integer read finfo.width write setwidth default 0;
   property indent: integer read finfo.indent write setindent default 0;
   property length: integer read finfo.length write setlength default 0;
                   //0 -> whole innerclientrect
   property value: realty read finfo.value write setvalue stored false;
 end;

 tcustomdial = class;
  
 tdialmarkers = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tdialmarker;
   procedure changed;
  public
   constructor create(const aowner: tcustomdial);
   procedure paint(const acanvas: tcanvas);
   property items[const index: integer]: tdialmarker read getitems; default;
 end;
  
 tcustomdial = class(tpublishedwidget)
  private
   fdirection: graphicdirectionty;
   fstate: dialstatesty;
   ftick0: dialtickinfoty;
   ftick1: dialtickinfoty;
   ftick2: dialtickinfoty;
   foffset: real;
   frange: real;
   fmarkers: tdialmarkers;
   procedure setdirection(const avalue: graphicdirectionty);
   procedure changed;
   procedure settick0_interval(const avalue: real);
   procedure settick0_color(const avalue: colorty);
   procedure settick0_width(const avalue: integer);
   procedure settick0_indent(const avalue: integer);
   procedure settick0_length(const avalue: integer);
   procedure settick1_interval(const avalue: real);
   procedure settick1_color(const avalue: colorty);
   procedure settick1_width(const avalue: integer);
   procedure settick1_indent(const avalue: integer);
   procedure settick1_length(const avalue: integer);
   procedure settick2_interval(const avalue: real);
   procedure settick2_color(const avalue: colorty);
   procedure settick2_width(const avalue: integer);
   procedure settick2_indent(const avalue: integer);
   procedure settick2_length(const avalue: integer);
   
   procedure setoffset(const avalue: real);
   procedure setrange(const avalue: real);
   procedure setmarkers(const avalue: tdialmarkers);
  protected
   procedure checklayout;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure clientrectchanged; override;
   procedure loaded; override;
   procedure updatemarker(var ainfo: markerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property direction: graphicdirectionty read fdirection write setdirection
                                       default gd_right;
   property offset: real read foffset write setoffset;//0.0..1.0
   property range: real read frange write setrange; //default 1.0
   property tick0_interval: real read ftick0.interval write settick0_interval;
                      //default 0.1
   property tick0_color: colorty read ftick0.color write settick0_color
                             default cl_glyph;
   property tick0_width: integer read ftick0.width write settick0_width
                             default 0;
   property tick0_indent: integer read ftick0.indent 
                     write settick0_indent default 0;
   property tick0_length: integer read ftick0.length 
                     write settick0_length default 15;
   property tick1_interval: real read ftick1.interval write settick1_interval;
                      //default 0.05
   property tick1_color: colorty read ftick1.color write settick1_color
                             default cl_glyph;
   property tick1_width: integer read ftick1.width write settick1_width
                             default 0;
   property tick1_indent: integer read ftick1.indent 
                     write settick1_indent default 0;
   property tick1_length: integer read ftick1.length 
                     write settick1_length default 10;
   property tick2_interval: real read ftick2.interval write settick2_interval;
                      //default 0.01
   property tick2_color: colorty read ftick2.color write settick2_color
                             default cl_glyph;
   property tick2_width: integer read ftick2.width write settick2_width
                             default 0;
   property tick2_indent: integer read ftick2.indent 
                     write settick2_indent default 0;
   property tick2_length: integer read ftick2.length 
                     write settick2_length default 5;
   property markers: tdialmarkers read fmarkers write setmarkers;
  published
   property color default cl_transparent;
 end;
 
 tdial = class(tcustomdial)
  published
   property direction;
   property offset;
   property range;
   property tick0_interval;
   property tick0_color;
   property tick0_width;
   property tick0_indent;
   property tick0_length; 
   property tick1_interval;
   property tick1_color;
   property tick1_width;
   property tick1_indent;
   property tick1_length; 
   property tick2_interval;
   property tick2_color;
   property tick2_width;
   property tick2_indent;
   property tick2_length; 
   property bounds_cy default 15;
   property bounds_cx default 100;
   property markers;
 end;
 
implementation
uses
 sysutils,msereal,msestreaming;
type
 tcustomframe1 = class(tcustomframe);
  
{ tdialmarker }

constructor tdialmarker.create(aowner: tobject);
begin
 finfo.color:= cl_black;
 inherited;
end;

procedure tdialmarker.changed;
begin
 twidget(fowner).invalidate;
 flayoutvalid:= false;
end;

procedure tdialmarker.setcolor(const avalue: colorty);
begin
 if avalue <> finfo.color then begin
  finfo.color:= avalue;
  changed;
 end;
end;

procedure tdialmarker.setwidth(const avalue: integer);
begin
 if avalue <> finfo.width then begin
  finfo.width:= avalue;
  changed;
 end;
end;

procedure tdialmarker.setindent(const avalue: integer);
begin
 if avalue <> finfo.indent then begin
  finfo.indent:= avalue;
  changed;
 end;
end;

procedure tdialmarker.setlength(const avalue: integer);
begin
 if avalue <> finfo.length then begin
  finfo.length:= avalue;
  changed;
 end;
end;

procedure tdialmarker.setvalue(const avalue: realty);
begin
 if finfo.value <> avalue then begin
  finfo.value:= avalue;
  changed;
 end;
end;

procedure tdialmarker.paint(const acanvas: tcanvas);
begin
 with finfo do begin
  checklayout;
  if active then begin
   acanvas.linewidth:= width;
   acanvas.drawlinesegments([line],color);
  end;
 end;
end;

procedure tdialmarker.checklayout;
begin
 if not flayoutvalid then begin
  with finfo do begin
   active:=  not isemptyreal(finfo.value);
   if active then begin
    tcustomdial(fowner).updatemarker(finfo);
   end;
  end;
  flayoutvalid:= true;
 end;
end;

procedure tdialmarker.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure tdialmarker.writevalue(writer: twriter);
begin
 writerealty(writer,finfo.value);
end;

procedure tdialmarker.defineproperties(filer: tfiler);
var
 bo1: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  with tdialmarker(filer.ancestor) do begin
   bo1:= self.finfo.value <> finfo.value;
  end;
 end
 else begin
  bo1:= finfo.value <> 0;
 end; 
 filer.defineproperty('val',
             {$ifdef FPC}@{$endif}readvalue,
             {$ifdef FPC}@{$endif}writevalue,bo1);
end;

{ tdialmarkers }

constructor tdialmarkers.create(const aowner: tcustomdial);
begin
 inherited create(aowner,tdialmarker);
end;

function tdialmarkers.getitems(const aindex: integer): tdialmarker;
begin
 result:= tdialmarker(inherited items[aindex]);
end;

procedure tdialmarkers.paint(const acanvas: tcanvas);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tdialmarker(fitems[int1]).paint(acanvas);
 end;
end;

procedure tdialmarkers.changed;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tdialmarker(fitems[int1]).flayoutvalid:= false;
 end; 
end;

{ tcustomdial }

constructor tcustomdial.create(aowner: tcomponent);
begin
 ftick0.color:= cl_glyph;
 ftick1:= ftick0;
 ftick2:= ftick0;
 ftick0.interval:= 0.1;
 ftick0.length:= 15;
 ftick1.interval:= 0.05;
 ftick1.length:= 10;
 ftick2.interval:= 0.01;
 ftick2.length:= 5;
 frange:= 1.0;
 fmarkers:= tdialmarkers.create(self);
 inherited;
 size:= makesize(100,15);
 color:= cl_transparent;
end;


destructor tcustomdial.destroy;
begin
 fmarkers.free;
 inherited;
end;

procedure tcustomdial.setdirection(const avalue: graphicdirectionty);
var
 dir1: graphicdirectionty;
begin
 if avalue <> fdirection then begin
  dir1:= fdirection;
  fdirection:= avalue;
  if not (csloading in componentstate) then begin
   changed;
   if fframe <> nil then begin
    rotateframe1(tcustomframe1(fframe).fi.innerframe,dir1,avalue);    
   end;
   widgetrect:= changerectdirection(widgetrect,dir1,avalue);
  end;
 end;
end;

procedure tcustomdial.changed;
begin
 if not (csloading in componentstate) then begin
  exclude(fstate,dis_layoutvalid);
  invalidate;
  fmarkers.changed;
 end;
end;

procedure tcustomdial.updatemarker(var ainfo: markerinfoty);
var
 rect1: rectty;
begin
 rect1:= innerclientrect;
 with ainfo,line do begin
  case fdirection of
   gd_right: begin
    a.y:= rect1.y + rect1.cy - indent;
    if length = 0 then begin
     b.y:= a.y - rect1.cy;
    end
    else begin
     b.y:= a.y - length;
    end;
    a.x:= rect1.x + round(rect1.cx * (value + foffset)/frange);
    b.x:= a.x;
   end;
   gd_up: begin
    a.x:= rect1.x + rect1.cx - indent;
    if length = 0 then begin
     b.x:= a.x - rect1.cx;
    end
    else begin
     b.x:= a.x - length;
    end;
    a.y:= rect1.y + rect1.cy - round(rect1.cy * (value + foffset)/frange);
    b.y:= a.y;
   end;
   gd_left: begin
    a.y:= rect1.y + indent;
    if length = 0 then begin
     b.y:= a.y + rect1.cy;
    end
    else begin
     b.y:= a.y + length;
    end;
    a.x:= rect1.x + rect1.cx - round(rect1.cx * (value + foffset)/frange);
    b.x:= a.x;
   end;
   gd_down: begin
    a.x:= rect1.x + indent;
    if length = 0 then begin
     b.x:= a.x + rect1.cx;
    end
    else begin
     b.x:= b.x + length;
    end;
    a.y:= rect1.y + round(rect1.cy * (value + foffset)/frange);
    b.y:= a.y;
   end;
  end;
 end;
end;

procedure tcustomdial.checklayout;
var
 rect1: rectty;

 procedure calcticks(var ainfo: dialtickinfoty);
 var
  linestart,lineend: integer;
  step: real;
  offs: real;
  int1: integer;
 begin
  with ainfo do begin
   if interval = 0 then begin
    ticks:= nil;
   end
   else begin
    case fdirection of
     gd_right: begin
      linestart:= rect1.y + rect1.cy - indent;
      lineend:= linestart - length;
     end;
     gd_up: begin
      linestart:= rect1.x + rect1.cx - indent;
      lineend:= linestart - length;
     end;
     gd_left: begin
      linestart:= rect1.y + indent;
      lineend:= linestart + length;
     end;
     gd_down: begin
      linestart:= rect1.x + indent;
      lineend:= linestart + length;
     end;
    end;
    step:= abs(interval/frange);
    offs:= offset / (frange * step);
    offs:= (offs - int(offs)) * step;
    if fdirection in [gd_up,gd_left] then begin
     offs:= - offs;
    end;
    setlength(ticks,round(1.0/(step))+1);
    if fdirection in [gd_right,gd_left] then begin
     step:= rect1.cx * step;
     offs:= rect1.cx * offs;
     for int1:= 0 to high(ticks) do begin
      with ticks[int1] do begin
       a.x:= rect1.x + round(int1*step+offs);
       b.x:= a.x;
       a.y:= linestart;
       b.y:= lineend;
      end;
     end;
    end
    else begin
     step:= rect1.cy * step;
     offs:= rect1.cy * offs;
     for int1:= 0 to high(ticks) do begin
      with ticks[int1] do begin
       a.y:= rect1.y + round(int1*step+offs);
       b.y:= a.y;
       a.x:= linestart;
       b.x:= lineend;
      end;
     end;
    end;
   end;  
  end;
 end;
 
begin
 if not (dis_layoutvalid in fstate) then begin
  rect1:= innerclientrect;
  calcticks(ftick0);
  calcticks(ftick1);
  calcticks(ftick2);
  include(fstate,dis_layoutvalid);
 end;
end;

procedure tcustomdial.dopaint(const acanvas: tcanvas);
begin
 inherited;
 checklayout;
 with ftick2 do begin
  acanvas.linewidth:= width;
  acanvas.drawlinesegments(ticks,color);
 end;
 with ftick1 do begin
  acanvas.linewidth:= width;
  acanvas.drawlinesegments(ticks,color);
 end;
 with ftick0 do begin
  acanvas.linewidth:= width;
  acanvas.drawlinesegments(ticks,color);
 end;
 fmarkers.paint(acanvas);
 acanvas.linewidth:= 0;
end;

procedure tcustomdial.clientrectchanged;
begin
 changed;
 inherited;
end;

procedure tcustomdial.settick0_interval(const avalue: real);
begin
 if ftick0.interval <> avalue then begin
  ftick0.interval:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick0_color(const avalue: colorty);
begin
 if ftick0.color <> avalue then begin
  ftick0.color:= avalue;
  invalidate;
 end;
end;

procedure tcustomdial.settick0_width(const avalue: integer);
begin
 if ftick0.width <> avalue then begin
  ftick0.width:= avalue;
  invalidate;
 end;
end;

procedure tcustomdial.settick0_indent(const avalue: integer);
begin
 if ftick0.indent <> avalue then begin
  ftick0.indent:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick0_length(const avalue: integer);
begin
 if ftick0.length <> avalue then begin
  ftick0.length:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick1_interval(const avalue: real);
begin
 if ftick1.interval <> avalue then begin
  ftick1.interval:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick1_color(const avalue: colorty);
begin
 if ftick1.color <> avalue then begin
  ftick1.color:= avalue;
  invalidate;
 end;
end;

procedure tcustomdial.settick1_width(const avalue: integer);
begin
 if ftick1.width <> avalue then begin
  ftick1.width:= avalue;
  invalidate;
 end;
end;

procedure tcustomdial.settick1_indent(const avalue: integer);
begin
 if ftick1.indent <> avalue then begin
  ftick1.indent:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick1_length(const avalue: integer);
begin
 if ftick1.length <> avalue then begin
  ftick1.length:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick2_interval(const avalue: real);
begin
 if ftick2.interval <> avalue then begin
  ftick2.interval:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick2_color(const avalue: colorty);
begin
 if ftick2.color <> avalue then begin
  ftick2.color:= avalue;
  invalidate;
 end;
end;

procedure tcustomdial.settick2_width(const avalue: integer);
begin
 if ftick2.width <> avalue then begin
  ftick2.width:= avalue;
  invalidate;
 end;
end;

procedure tcustomdial.settick2_indent(const avalue: integer);
begin
 if ftick2.indent <> avalue then begin
  ftick2.indent:= avalue;
  changed;
 end;
end;

procedure tcustomdial.settick2_length(const avalue: integer);
begin
 if ftick2.length <> avalue then begin
  ftick2.length:= avalue;
  changed;
 end;
end;

procedure tcustomdial.setoffset(const avalue: real);
begin
 if foffset <> avalue then begin
  foffset:= avalue;
  changed;
 end;
end;

procedure tcustomdial.setrange(const avalue: real);
begin
 if frange <> avalue then begin
  if avalue = 0 then begin
   raise exception.create('Range can not be 0.0.');
  end;
  frange:= avalue;
  changed;
 end;
end;

procedure tcustomdial.setmarkers(const avalue: tdialmarkers);
begin
 fmarkers.assign(avalue);
end;

procedure tcustomdial.loaded;
begin
 inherited;
 changed;
end;

end.
