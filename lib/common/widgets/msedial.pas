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
  protected
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tcustomdial); reintroduce;
   procedure paint(const acanvas: tcanvas);
   property items[const index: integer]: tdialmarker read getitems; default;
 end;

 tdialtick = class(townedpersistent)
  private
   finfo: dialtickinfoty;
   procedure changed;
   procedure setinterval(const avalue: real);
   procedure setcolor(const avalue: colorty);
   procedure setwidth(const avalue: integer);
   procedure setindent(const avalue: integer);
   procedure setlength(const avalue: integer);
  protected
//   procedure paint(const acanvas: tcanvas);
  public
   constructor create(aowner: tobject); override;
  published
   property interval: real read finfo.interval write setinterval;
                      //0 -> off
   property color: colorty read finfo.color write setcolor
                             default cl_glyph;
   property width: integer read finfo.width write setwidth
                             default 0;
   property indent: integer read finfo.indent 
                     write setindent default 0;
   property length: integer read finfo.length 
                     write setlength default 0;
                      //0 -> whole innerclientrect
 end;
 
 tdialticks = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tdialtick;
  protected
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tcustomdial); reintroduce;
   property items[const index: integer]: tdialtick read getitems; default;
 end;
 
 dialoptionty = (do_opposite);
 dialoptionsty = set of dialoptionty;  
 
 tcustomdial = class(tpublishedwidget)
  private
   fdirection: graphicdirectionty;
   fstate: dialstatesty;
   foffset: real;
   frange: real;
   fmarkers: tdialmarkers;
   fticks: tdialticks;
   foptions: dialoptionsty;
   procedure setdirection(const avalue: graphicdirectionty);
   procedure changed;
   procedure setoffset(const avalue: real);
   procedure setrange(const avalue: real);
   procedure setmarkers(const avalue: tdialmarkers);
   procedure setoptions(const avalue: dialoptionsty);
   procedure setticks(const avalue: tdialticks);
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
   property markers: tdialmarkers read fmarkers write setmarkers;
   property ticks: tdialticks read fticks write setticks;
   property options: dialoptionsty read foptions write setoptions default [];
  published
   property color default cl_transparent;
 end;
 
 tdial = class(tcustomdial)
  published
   property direction;
   property offset;
   property range;
   property bounds_cy default 15;
   property bounds_cx default 100;
   property markers;
   property ticks;
   property options;
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
 for int1:= high(fitems) downto 0 do begin
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

procedure tdialmarkers.dosizechanged;
begin
 inherited;
 tcustomdial(fowner).changed;
end;

{ tdialtick }

constructor tdialtick.create(aowner: tobject);
begin
 finfo.color:= cl_glyph;
 inherited;
end;

procedure tdialtick.changed;
begin
 tcustomdial(fowner).changed;
end;

procedure tdialtick.setinterval(const avalue: real);
begin
 if finfo.interval <> avalue then begin
  finfo.interval:= avalue;
  changed;
 end;
end;

procedure tdialtick.setcolor(const avalue: colorty);
begin
 if finfo.color <> avalue then begin
  finfo.color:= avalue;
  twidget(fowner).invalidate;
 end;
end;

procedure tdialtick.setwidth(const avalue: integer);
begin
 if finfo.width <> avalue then begin
  finfo.width:= avalue;
  twidget(fowner).invalidate;
 end;
end;

procedure tdialtick.setindent(const avalue: integer);
begin
 if finfo.indent <> avalue then begin
  finfo.indent:= avalue;
  changed;
 end;
end;

procedure tdialtick.setlength(const avalue: integer);
begin
 if finfo.length <> avalue then begin
  finfo.length:= avalue;
  changed;
 end;
end;

{ tdialticks }

constructor tdialticks.create(const aowner: tcustomdial);
begin
 inherited create(aowner,tdialtick);
end;

function tdialticks.getitems(const aindex: integer): tdialtick;
begin
 result:= tdialtick(inherited items[aindex]);
end;

procedure tdialticks.dosizechanged;
begin
 inherited;
 tcustomdial(fowner).changed;
end;

{ tcustomdial }

constructor tcustomdial.create(aowner: tcomponent);
begin
 frange:= 1.0;
 fmarkers:= tdialmarkers.create(self);
 fticks:= tdialticks.create(self);
 inherited;
 size:= makesize(100,15);
 color:= cl_transparent;
end;


destructor tcustomdial.destroy;
begin
 fmarkers.free;
 fticks.free;
 inherited;
end;

procedure tcustomdial.setdirection(const avalue: graphicdirectionty);
var
 dir1: graphicdirectionty;
begin
 if avalue <> fdirection then begin
  dir1:= fdirection;
  fdirection:= avalue;
  if fdirection >= gd_none then begin
   fdirection:= pred(fdirection);
  end;
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
 dir1: graphicdirectionty;
begin
 rect1:= innerclientrect;
 dir1:= fdirection;
 if do_opposite in foptions then begin
  dir1:= graphicdirectionty((ord(fdirection)+2) and $3);
 end;
 with ainfo,line do begin
  case dir1 of
   gd_right: begin
    a.y:= rect1.y + rect1.cy - indent - 1;
    if length = 0 then begin
     b.y:= a.y - rect1.cy;
    end
    else begin
     b.y:= a.y - length;
    end;
   end;
   gd_up: begin
    a.x:= rect1.x + rect1.cx - indent - 1;
    if length = 0 then begin
     b.x:= a.x - rect1.cx;
    end
    else begin
     b.x:= a.x - length;
    end;
   end;
   gd_left: begin
    a.y:= rect1.y + indent;
    if length = 0 then begin
     b.y:= a.y + rect1.cy;
    end
    else begin
     b.y:= a.y + length;
    end;
   end;
   gd_down: begin
    a.x:= rect1.x + indent;
    if length = 0 then begin
     b.x:= a.x + rect1.cx;
    end
    else begin
     b.x:= a.x + length;
    end;
   end;
  end;
  case fdirection of
   gd_right: begin
    a.x:= rect1.x + round(rect1.cx * (value + foffset)/frange);
    b.x:= a.x;
   end;
   gd_up: begin
    a.y:= rect1.y + rect1.cy - round(rect1.cy * (value + foffset)/frange) - 1;
    b.y:= a.y;
   end;
   gd_left: begin
    a.x:= rect1.x + rect1.cx - round(rect1.cx * (value + foffset)/frange) - 1;
    b.x:= a.x;
   end;
   gd_down: begin
    a.y:= rect1.y + round(rect1.cy * (value + foffset)/frange);
    b.y:= a.y;
   end;
  end;
 end;
end;

procedure tcustomdial.checklayout;
var
 rect1: rectty;
 dir1: graphicdirectionty;

 procedure calcticks(var ainfo: dialtickinfoty);
 var
  linestart,lineend: integer;
  step: real;
  offs: real;
  int1: integer;
 begin
  linestart:= 0; //compiler warning
  lineend:= 0; //compiler warning
  with ainfo do begin
   if interval = 0 then begin
    ticks:= nil;
   end
   else begin
    case dir1 of
     gd_right: begin
      linestart:= rect1.y + rect1.cy - indent - 1;
      if length = 0 then begin
       lineend:= linestart - rect1.cy;
      end
      else begin
       lineend:= linestart - length;
      end;
     end;
     gd_up: begin
      linestart:= rect1.x + rect1.cx - indent - 1;
      if length = 0 then begin
       lineend:= linestart - rect1.cx;
      end
      else begin
       lineend:= linestart - length;
      end;
     end;
     gd_left: begin
      linestart:= rect1.y + indent;
      if length = 0 then begin
       lineend:= linestart + rect1.cy;
      end
      else begin
       lineend:= linestart + length;
      end;
     end;
     gd_down: begin
      linestart:= rect1.x + indent;
      if length = 0 then begin
       lineend:= linestart + rect1.cx
      end
      else begin
       lineend:= linestart + length;
      end;
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
       if fdirection = gd_left then begin
        dec(a.x);
       end;
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
       if fdirection = gd_up then begin
        dec(a.y);
       end;
       b.y:= a.y;
       a.x:= linestart;
       b.x:= lineend;
      end;
     end;
    end;
   end;  
  end;
 end;
 
var
 int1: integer; 
 
begin
 if not (dis_layoutvalid in fstate) then begin
  rect1:= innerclientrect;
  dir1:= fdirection;
  if do_opposite in foptions then begin
   dir1:= graphicdirectionty((ord(fdirection)+2) and $3);
  end;
  for int1:= 0 to high(fticks.fitems) do begin
   calcticks(tdialtick(fticks.fitems[int1]).finfo);
  end;
  include(fstate,dis_layoutvalid);
 end;
end;

procedure tcustomdial.dopaint(const acanvas: tcanvas);
var
 int1: integer;
begin
 inherited;
 checklayout;
 for int1:= high(fticks.fitems) downto 0 do begin
  with tdialtick(fticks.fitems[int1]).finfo do begin
   if ticks <> nil then begin
    acanvas.linewidth:= width;
    acanvas.drawlinesegments(ticks,color);
   end;
  end;
 end;
 fmarkers.paint(acanvas);
 acanvas.linewidth:= 0;
end;

procedure tcustomdial.clientrectchanged;
begin
 changed;
 inherited;
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

procedure tcustomdial.setoptions(const avalue: dialoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  changed;
 end;
end;

procedure tcustomdial.setticks(const avalue: tdialticks);
begin
 fticks.assign(avalue);
end;

end.
