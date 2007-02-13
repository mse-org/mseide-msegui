unit msedial;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msewidgets,msegraphutils,msegraphics,msegui;
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
 
 tcustomdial = class(tpublishedwidget)
  private
   fdirection: graphicdirectionty;
   fstate: dialstatesty;
   ftick0: dialtickinfoty;
   ftick1: dialtickinfoty;
   ftick2: dialtickinfoty;
   foffset: real;
   fscale: real;
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
   procedure setscale(const avalue: real);
  protected
   procedure checklayout;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure clientrectchanged; override;
  public
   constructor create(aowner: tcomponent); override;
   property direction: graphicdirectionty read fdirection write setdirection
                                       default gd_right;
   property offset: real read foffset write setoffset;//0.0..1.0
   property scale: real read fscale write setscale; //default 1.0
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
  published
   property color default cl_transparent;
 end;
 
 tdial = class(tcustomdial)
  published
   property direction;
   property offset;
   property scale;
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
 end;
 
implementation
type
 tcustomframe1 = class(tcustomframe);
  
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
 fscale:= 1.0;
 inherited;
 size:= makesize(100,15);
 color:= cl_transparent;
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
 exclude(fstate,dis_layoutvalid);
 invalidate;
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
    step:= abs(interval*scale);
    offs:= offset * scale / step;
    offs:= (offs - int(offs)) * step;
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
  if fdirection in [gd_right,gd_left] then begin
   dec(rect1.cx);
  end
  else begin
   dec(rect1.cy);
  end;
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

procedure tcustomdial.setscale(const avalue: real);
begin
 if fscale <> avalue then begin
  fscale:= avalue;
  changed;
 end;
end;

end.
