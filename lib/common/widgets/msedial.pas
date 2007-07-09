{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedial;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msewidgets,msegraphutils,msegraphics,msegui,msearrayprops,mseclasses,
 msetypes,mseguiglob,msestrings;

const
 defaultdialcolor = cl_dkgray;
  
type
 dialstatety = (dis_layoutvalid,dis_needstransform);
 dialstatesty = set of dialstatety;

 tickcaptionty = record
  caption: msestring;
  pos: pointty;
  angle: real;
 end;
 tickcaptionarty = array of tickcaptionty;
  
 tdialpropfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tdialfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 dialdatakindty = (dtk_real,dtk_datetime);
 
 diallineinfoty = record
  color: colorty;
  widthmm: real;
  dashes: string;
  indent: integer;
  length: integer;
  captiondist: integer;
  captionoffset: integer;
  escapement: real;
  font: tdialpropfont;
  caption: msestring;
//  kind: dialdatakindty;
 end;
  
 dialtickinfoty = record
  ticks: segmentarty;
  ticksreal: realarty;
  captions: tickcaptionarty;
  intervalcount: real;
  afont: tfont;
 end;

 tdialprop = class(townedpersistent)
  private
   fli: diallineinfoty;
   procedure setcolor(const avalue: colorty);
   procedure setwidthmm(const avalue: real);
   procedure setdashes(const avalue: string);
   procedure setindent(const avalue: integer);
   procedure setlength(const avalue: integer);
   procedure setcaption(const avalue: msestring);
   procedure setcaptiondist(const avalue: integer);
   procedure setcaptionoffset(const avalue: integer);
   function getfont: tdialpropfont;
   procedure setfont(const avalue: tdialpropfont);
   function isfontstored: boolean;
   procedure createfont;
   procedure fontchanged(const sender: tobject);
   procedure setescapement(const avalue: real);

  protected
   flayoutvalid: boolean;
   procedure changed; virtual;
   function getactcaption(const avalue: real; const aformat: msestring): msestring;
   function actualcolor: colorty;
   function actualwidthmm: real;
  public
   constructor create(aowner: tobject); override;   
   destructor destroy; override;
  published
   property color: colorty read fli.color write setcolor
                             default cl_default;
   property widthmm: real read fli.widthmm write setwidthmm;
                           //0 -> withmm of dialcontroller
   property dashes: string read fli.dashes write setdashes;
   property indent: integer read fli.indent 
                     write setindent default 0;
   property length: integer read fli.length 
                     write setlength default 0;
                      //0 -> whole innerclientrect
   property caption: msestring read fli.caption write setcaption;
   property captiondist: integer read fli.captiondist write setcaptiondist
                                       default 2;
   property captionoffset: integer read fli.captionoffset write setcaptionoffset
                                       default 0;
   property font: tdialpropfont read getfont write setfont stored isfontstored;
   property escapement: real read fli.escapement write setescapement;
 end;

 dialmarkeroptionty = (dmo_opposite);
 dialmarkeroptionsty = set of dialmarkeroptionty;
 
 markerinfoty = record
  active: boolean;
  line: segmentty;
  value: realty;
  captionpos: pointty;
  aangle: real;
  afont: tfont;
  acaption: msestring;
  options: dialmarkeroptionsty;
 end;

 tdialmarker = class(tdialprop)
  private
   finfo: markerinfoty;
   procedure checklayout;
   procedure readvalue(reader: treader);
   procedure writevalue(writer: twriter);
   procedure setvalue(const avalue: realty);
   procedure setoptions(const avalue: dialmarkeroptionsty);
  protected
   procedure defineproperties(filer: tfiler); override;
   procedure updatemarker;
  public
   procedure paint(const acanvas: tcanvas);
  published
   property value: realty read finfo.value write setvalue stored false;
   property options: dialmarkeroptionsty read finfo.options 
                          write setoptions default [];
 end;

 tcustomdialcontroller = class;

 tdialmarkers = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tdialmarker;
   procedure changed;
  protected
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tcustomdialcontroller); reintroduce;
   procedure paint(const acanvas: tcanvas);
   property items[const index: integer]: tdialmarker read getitems; default;
 end;

 tdialtick = class(tdialprop)
  private
   finfo: dialtickinfoty;
   procedure setintervalcount(const avalue: real);
  protected
//   procedure paint(const acanvas: tcanvas);
  public
  published
   property intervalcount: real read finfo.intervalcount write setintervalcount;
                      //0 -> off
 end;
 
 tdialticks = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tdialtick;
  protected
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tcustomdialcontroller); reintroduce;
   property items[const index: integer]: tdialtick read getitems; default;
 end;
 
 dialoptionty = (do_opposite,do_sideline,do_boxline,do_rotatetext);
 dialoptionsty = set of dialoptionty;  

 idialcontroller = interface(inullinterface)
  procedure directionchanged(const dir,dirbefore: graphicdirectionty);
  function getwidget: twidget;
  function getdialrect: rectty;
 end;
 
 tcustomdialcontroller = class(tpersistent)
  private
   fdirection: graphicdirectionty;
   fstate: dialstatesty;
   foffset: real;
   frange: real;
   fmarkers: tdialmarkers;
   fticks: tdialticks;
   foptions: dialoptionsty;
   fintf: idialcontroller;
   ffont: tdialfont;
   fcolor: colorty;
   fwidthmm: real;
   fboxlines: segmentarty;
   fkind: dialdatakindty;
   fangle: real;
   fp: real;
   fr: real;
   fscalex: real;
   foffsx: integer;
   fendy: integer;
   procedure setoffset(const avalue: real);
   procedure setrange(const avalue: real);
   procedure setmarkers(const avalue: tdialmarkers);
   procedure setoptions(const avalue: dialoptionsty);
   procedure setticks(const avalue: tdialticks);
   function getfont: tdialfont;
   procedure setfont(const avalue: tdialfont);
   function isfontstored: boolean;
   procedure setcolor(const avalue: colorty);
   procedure setwidthmm(const avalue: real);
   procedure setkind(const avalue: dialdatakindty);
   procedure setangle(const avalue: real);
  protected
   procedure setdirection(const avalue: graphicdirectionty); virtual;
   procedure changed;
   procedure calclineend(const ainfo: diallineinfoty; const aopposite: boolean; 
                   const arect: rectty; out linestart,lineend: integer;
                   out linedirection: graphicdirectionty);
   procedure adjustcaption(const dir: graphicdirectionty;
                const ainfo: diallineinfoty; const afont: tfont;
                const stringwidth: integer; var pos: pointty);
   procedure checklayout;
   procedure invalidate;
   procedure createfont;
   procedure fontchanged(const sender: tobject);
   procedure transform(var apoint: pointty);
  public
   constructor create(const aintf: idialcontroller);
   destructor destroy; override;
   procedure paint(const acanvas: tcanvas);
   procedure afterpaint(const acanvas: tcanvas);
   property direction: graphicdirectionty read fdirection write setdirection
                                       default gd_right;
   property offset: real read foffset write setoffset;//0.0..1.0
   property range: real read frange write setrange; //default 1.0
   property kind: dialdatakindty read fkind write setkind default dtk_real;
   property markers: tdialmarkers read fmarkers write setmarkers;
   property ticks: tdialticks read fticks write setticks;
   property color: colorty read fcolor write setcolor default defaultdialcolor;
   property widthmm: real read fwidthmm write setwidthmm; 
                //linewidth, default 0.3
   property options: dialoptionsty read foptions write setoptions default [];
   property font: tdialfont read getfont write setfont stored isfontstored;
   property angle: real read fangle write setangle; //0 -linear, 1 -> 360 grad
 end;

 tdialcontroller = class(tcustomdialcontroller)
  published
   property color;
   property widthmm;
   property direction;
   property offset;
   property range;
   property kind;
   property markers;
   property ticks;
   property options;
   property font;
   property angle;
 end;
 
 tcustomdial = class(tpublishedwidget,idialcontroller)
  private
   fdial: tdialcontroller;
   procedure setdial(const avalue: tdialcontroller);
  protected
   procedure dopaint(const acanvas: tcanvas); override;
   procedure clientrectchanged; override;
          //idialcontroller
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property dial: tdialcontroller read fdial write setdial;
  published
   property color default cl_transparent;
 end;
 
 tdial = class(tcustomdial)
  published
   property dial;
   property bounds_cy default 15;
   property bounds_cx default 100;
 end;

procedure checknullrange(const avalue: real);
 
implementation
uses
 sysutils,msereal,msestreaming,mseformatstr;
type
 tcustomframe1 = class(tcustomframe);
 twidget1 = class(twidget);

procedure checknullrange(const avalue: real);
begin
 if avalue = 0 then begin
  raise exception.create('Range can not be 0.0.');
 end;
end;

{ tdialpropfont }

class function tdialpropfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tdialprop(owner).fli.font;
end;  

{ tdialfont }

class function tdialfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcustomdialcontroller(owner).ffont;
end;

{ tdialprop }

constructor tdialprop.create(aowner: tobject);
begin
 fli.color:= cl_default;
 fli.captiondist:= 2;
// fli.widthmm:= 0.3;
 inherited;
end;

destructor tdialprop.destroy;
begin
 fli.font.free;
 inherited;
end;

procedure tdialprop.changed;
begin
 flayoutvalid:= false;
 tcustomdialcontroller(fowner).changed;
end;

procedure tdialprop.setcolor(const avalue: colorty);
begin
 if fli.color <> avalue then begin
  fli.color:= avalue;
  tcustomdialcontroller(fowner).invalidate;
 end;
end;

procedure tdialprop.setwidthmm(const avalue: real);
begin
 fli.widthmm:= avalue;
 tcustomdialcontroller(fowner).invalidate;
end;

procedure tdialprop.setdashes(const avalue: string);
begin
 fli.dashes:= avalue;
 tcustomdialcontroller(fowner).invalidate; 
end;

procedure tdialprop.setindent(const avalue: integer);
begin
 if fli.indent <> avalue then begin
  fli.indent:= avalue;
  changed;
 end;
end;

procedure tdialprop.setlength(const avalue: integer);
begin
 if fli.length <> avalue then begin
  fli.length:= avalue;
  changed;
 end;
end;

procedure tdialprop.setcaption(const avalue: msestring);
begin
 fli.caption:= avalue;
 changed;
end;

procedure tdialprop.setcaptiondist(const avalue: integer);
begin
 if fli.captiondist <> avalue then begin
  fli.captiondist:= avalue;
  changed;
 end;
end;

procedure tdialprop.setcaptionoffset(const avalue: integer);
begin
 if fli.captionoffset <> avalue then begin
  fli.captionoffset:= avalue;
  changed;
 end;
end;

procedure tdialprop.fontchanged(const sender: tobject);
begin
 changed;
end;

procedure tdialprop.createfont;
begin
 if fli.font = nil then begin
  fli.font:= tdialpropfont.create;
  fli.font.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function tdialprop.getfont: tdialpropfont;
begin
 getoptionalobject(tcustomdialcontroller(fowner).fintf.getwidget.componentstate,
                               fli.font,{$ifdef FPC}@{$endif}createfont);
 if fli.font <> nil then begin
  result:= fli.font;
 end
 else begin
  result:= tdialpropfont(tcustomdialcontroller(fowner).getfont);
 end;
end;

procedure tdialprop.setfont(const avalue: tdialpropfont);
begin
 if avalue <> fli.font then begin
  setoptionalobject(tcustomdialcontroller(fowner).fintf.getwidget.componentstate,
                   avalue,fli.font,{$ifdef FPC}@{$endif}createfont);
  changed;
 end;
end;

function tdialprop.isfontstored: boolean;
begin
 result:= fli.font <> nil;
end;

procedure tdialprop.setescapement(const avalue: real);
begin
 if avalue <> fli.escapement then begin
  fli.escapement:= avalue;
  changed;
 end;
end;

function tdialprop.getactcaption(const avalue: real; const aformat: msestring): msestring;
begin
 if tcustomdialcontroller(fowner).fkind = dtk_datetime then begin
  result:= datetimetostring(avalue,aformat);
 end
 else begin
  result:= formatfloatmse(avalue,aformat);
 end;
end;

function tdialprop.actualcolor: colorty;
begin
 result:= fli.color;
 if fli.color = cl_default then begin
  result:= tcustomdialcontroller(fowner).fcolor;
 end;
end;

function tdialprop.actualwidthmm: real;
begin
 result:= fli.widthmm;
 if result = 0 then begin
  result:= tcustomdialcontroller(fowner).fwidthmm;
 end;
end;

{ tdialmarker }

procedure tdialmarker.setvalue(const avalue: realty);
begin
 if finfo.value <> avalue then begin
  finfo.value:= avalue;
  changed;
 end;
end;

procedure tdialmarker.paint(const acanvas: tcanvas);
begin
 checklayout;
 with finfo,fli do begin
  if active then begin
   acanvas.linewidthmm:= actualwidthmm;
   if dashes <> '' then begin
    acanvas.dashes:= dashes;
   end;
   acanvas.drawline(line.a,line.b,actualcolor);
   if dashes <> '' then begin
    acanvas.dashes:= '';
   end;
   if caption <> '' then begin
    acanvas.drawstring(acaption,captionpos,self.font,false,aangle);
   end;
  end;
 end;
end;

procedure tdialmarker.checklayout;
begin
 if not flayoutvalid then begin
  with finfo do begin
   active:=  not isemptyreal(finfo.value);
   if active then begin
    updatemarker;
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

procedure tdialmarker.updatemarker;
var
 rect1: rectty;
 
 function snap(const avalue: real): integer;
            //snap to ticks
 var
  int1,int2: integer;
 begin
  with tcustomdialcontroller(fowner) do begin
   if not (dis_needstransform in fstate) then begin
    with fticks do begin
     for int1:= 0 to count - 1 do begin
      with tdialtick(fitems[int1]).finfo do begin
       for int2:= 0 to high(ticksreal) do begin
        if abs(avalue-ticksreal[int2]) < 0.1 then begin
         if direction in [gd_right,gd_left] then begin
          result:= ticks[int2].a.x;
         end
         else begin
          result:= ticks[int2].a.y;
         end;
         exit;
        end;
       end;
      end;
     end;
    end;
   end;
   result:= round(avalue);
   if direction in [gd_right,gd_left] then begin
    result:= result + rect1.x;
   end
   else begin
    result:= result + rect1.y;
   end;
  end;
 end;
 
var
 linestart,lineend: integer;
 dir1: graphicdirectionty;
 rea1: real;
begin
 with tcustomdialcontroller(fowner),fli,finfo,line do begin
  rect1:= fintf.getdialrect;
  calclineend(fli,dmo_opposite in options,rect1,linestart,lineend,dir1);
  rea1:= (value - foffset)/frange;
  if do_rotatetext in foptions then begin
   aangle:= angle * (rea1-0.5) * 2*pi;
   if fdirection in [gd_left,gd_right] then begin
    aangle:= -aangle;
   end;
   aangle:= aangle + escapement*2*pi;
  end
  else begin
   aangle:= 0;
  end;
  case fdirection of
   gd_right: begin
    a.x:= snap(rect1.cx * rea1);
    b.x:= a.x;
    a.y:= linestart;
    b.y:= lineend;
   end;
   gd_up: begin
    a.y:= snap(rect1.cy - (rect1.cy * rea1));
    b.y:= a.y;
    a.x:= linestart;
    b.x:= lineend;
   end;
   gd_left: begin
    a.x:= snap(rect1.cx - (rect1.cx * rea1));
    b.x:= a.x;
    a.y:= linestart;
    b.y:= lineend;
   end;
   gd_down: begin
    a.y:= snap(rect1.cy * rea1);
    b.y:= a.y;
    a.x:= linestart;
    b.x:= lineend;
   end;
  end;
  if caption <> '' then begin
   afont:= self.font;
   acaption:= getactcaption(value,caption);
   captionpos:= a;
   adjustcaption(dir1,fli,afont,
     fintf.getwidget.getcanvas.getstringwidth(acaption,afont),captionpos);
  end;
  transform(a);
  transform(b);
 end;
end;

procedure tdialmarker.setoptions(const avalue: dialmarkeroptionsty);
begin
 if finfo.options <> avalue then begin
  finfo.options:= avalue;
  changed;
 end;
end;

{ tdialmarkers }

constructor tdialmarkers.create(const aowner: tcustomdialcontroller);
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
 tcustomdialcontroller(fowner).changed;
end;

{ tdialtick }

procedure tdialtick.setintervalcount(const avalue: real);
begin
 if finfo.intervalcount <> avalue then begin
  finfo.intervalcount:= avalue;
  changed;
 end;
end;

{ tdialticks }

constructor tdialticks.create(const aowner: tcustomdialcontroller);
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
 tcustomdialcontroller(fowner).changed;
end;

{ tcustomdialcontroller }

constructor tcustomdialcontroller.create(const aintf: idialcontroller);
begin
 fintf:= aintf;
 fcolor:= defaultdialcolor;
 fwidthmm:= 0.3;
 frange:= 1.0;
 fmarkers:= tdialmarkers.create(self);
 fticks:= tdialticks.create(self);
end;

destructor tcustomdialcontroller.destroy;
begin
 fmarkers.free;
 fticks.free;
 ffont.free;
 inherited;
end;

procedure tcustomdialcontroller.setdirection(const avalue: graphicdirectionty);
var
 dir1: graphicdirectionty;
begin
 if avalue <> fdirection then begin
  dir1:= fdirection;
  fdirection:= avalue;
  if fdirection >= gd_none then begin
   fdirection:= pred(fdirection);
  end;
  changed;
  fintf.directionchanged(avalue,dir1);
 end;
end;

procedure tcustomdialcontroller.changed;
begin
 with fintf.getwidget do begin
  if not (csloading in componentstate) then begin
   exclude(fstate,dis_layoutvalid);
   invalidate;
   fmarkers.changed;
  end;
 end;
end;

procedure tcustomdialcontroller.calclineend(const ainfo: diallineinfoty;
                   const aopposite: boolean;
                   const arect: rectty; out linestart,lineend: integer;
                   out linedirection: graphicdirectionty);
begin
 linedirection:= fdirection;
 if (do_opposite in foptions) xor aopposite then begin
  linedirection:= graphicdirectionty((ord(fdirection)+2) and $3);
 end;
 with ainfo do begin
  case linedirection of
   gd_right: begin
    linestart:= arect.y + arect.cy - indent {- 1};
    if length = 0 then begin
     lineend:= linestart - arect.cy + indent;
    end
    else begin
     lineend:= linestart - length;
    end;
   end;
   gd_down: begin
    linestart:= arect.x + arect.cx - indent {- 1};
    if length = 0 then begin
     lineend:= linestart - arect.cx + indent;
    end
    else begin
     lineend:= linestart - length;
    end;
   end;
   gd_left: begin
    linestart:= arect.y + indent;
    if length = 0 then begin
     lineend:= linestart + arect.cy - indent;
    end
    else begin
     lineend:= linestart + length;
    end;
   end;
   gd_up: begin
    linestart:= arect.x + indent;
    if length = 0 then begin
     lineend:= linestart + arect.cx - indent;
    end
    else begin
     lineend:= linestart + length;
    end;
   end;
  end;
 end;
end;

procedure tcustomdialcontroller.transform(var apoint: pointty);
 procedure trans(var x,y: integer);
 var
  r1: real;
  x1: real;
 begin
  r1:= fr - y;
  x1:= fp*((x-foffsx)*fscalex);
  x:= round(r1*sin(x1))+foffsx;
  y:= round(r1*(1-cos(x1))) + y;
 end; 
begin
 if dis_needstransform in fstate then begin
  case fdirection of
   gd_left: begin
    apoint.y:= fendy - apoint.y;
    trans(apoint.x,apoint.y);
    apoint.y:= fendy - apoint.y
   end;
   gd_up: begin
    apoint.x:= fendy - apoint.x;
    trans(apoint.y,apoint.x);
    apoint.x:= fendy - apoint.x
   end;
   gd_down: begin
    trans(apoint.y,apoint.x);
   end;
   else begin //gd_right
    trans(apoint.x,apoint.y);
   end;
  end;
 end;
end;

procedure tcustomdialcontroller.adjustcaption(const dir: graphicdirectionty;
              const ainfo: diallineinfoty;
              const afont: tfont; const stringwidth: integer; var pos: pointty);
begin
 with ainfo,pos do begin
  case dir of 
   gd_right: begin
    y:= y + captiondist;
    x:= x + captionoffset;
    if not(do_rotatetext in foptions) then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     x:= x - stringwidth div 2;
     y:= y + afont.ascent;
    end;
   end;
   gd_up: begin
    x:= x - captiondist;
    y:= y + captionoffset;
    if not(do_rotatetext in foptions) then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     x:= x - stringwidth;
     y:= y + afont.ascent - afont.glyphheight div 2;
    end;
   end;
   gd_left: begin
    y:= y - captiondist;
    x:= x + captionoffset;
    if not(do_rotatetext in foptions) then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     x:= x - stringwidth div 2;
     y:= y - afont.descent;
    end;
   end;
   gd_down: begin
    x:= x + captiondist;
    y:= y + captionoffset;
    if not(do_rotatetext in foptions) then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     y:= y + afont.ascent - afont.glyphheight div 2;
    end;
   end;
  end;
 end;
 if do_rotatetext in foptions then begin
  transform(pos);
 end;
end;

procedure tcustomdialcontroller.checklayout;
var
 rect1: rectty;
 canvas1: tcanvas;
 linestart,lineend: integer;
 step: real;
 offs: real;
 first: real;
 valstep: real;
 int1,int2,int3,int4: integer;
 dir1: graphicdirectionty;
 boxlines: array[0..1] of segmentty;
 bo1: boolean;
 rea1: real;
 
begin
 if not (dis_layoutvalid in fstate) then begin
  canvas1:= fintf.getwidget.getcanvas;
  rect1:= fintf.getdialrect;

  exclude(fstate,dis_needstransform);
  if fangle <> 0 then begin
   if fdirection in [gd_right,gd_left] then begin
    int1:= rect1.cx;
    foffsx:= int1 div 2 + rect1.x;
    if fdirection = gd_left then begin
     fendy:= rect1.y + rect1.cy;
    end;
   end
   else begin
    int1:= rect1.cy;
    foffsx:= int1 div 2 + rect1.y;
    if fdirection = gd_up then begin
     fendy:= rect1.x + rect1.cx;
    end;
   end;
   if int1 > 0 then begin
    fp:= pi*fangle;
    include(fstate,dis_needstransform);
    fscalex:= 2.0/int1;
    fr:= int1/2.0;
//    if fangle < 0.25 then begin
    if fangle < 0.5 then begin
     fr:= fr/sin(fp);
    end;
   end;    
  end;
  
  with rect1 do begin
   if fdirection in [gd_right,gd_left] then begin
    boxlines[0].a.x:= x;         
    boxlines[0].b.x:= x + cx;
    boxlines[1].a.x:= boxlines[0].a.x;
    boxlines[1].b.x:= boxlines[0].b.x;

    boxlines[0].a.y:= y + cy;
    boxlines[0].b.y:= boxlines[0].a.y;
    boxlines[1].a.y:= y;
    boxlines[1].b.y:= y;
   end
   else begin
    boxlines[0].a.y:= y;         
    boxlines[0].b.y:= y + cy;
    boxlines[1].a.y:= boxlines[0].a.y;
    boxlines[1].b.y:= boxlines[0].b.y;

    boxlines[0].a.x:= x + cx;
    boxlines[0].b.x:= boxlines[0].a.x;
    boxlines[1].a.x:= x;
    boxlines[1].b.x:= x;
   end;
  end;
  bo1:= ((fdirection = gd_left) or (fdirection = gd_up)) xor 
                             (do_opposite in foptions);
  if do_sideline in foptions then begin
   setlength(fboxlines,1);
   if bo1 then begin
    fboxlines[0]:= boxlines[1];
   end
   else begin
    fboxlines[0]:= boxlines[0];
   end;
  end
  else begin
   fboxlines:= nil;
  end;
  if do_boxline in foptions then begin
   setlength(fboxlines,high(fboxlines)+2);
   if bo1 then begin
    fboxlines[high(fboxlines)]:= boxlines[0];
   end
   else begin
    fboxlines[high(fboxlines)]:= boxlines[1];
   end;
  end;
  for int4:= 0 to high(fticks.fitems) do begin
   with tdialtick(fticks.fitems[int4]) do begin
    finfo.afont:= font;
    linestart:= 0; //compiler warning
    lineend:= 0; //compiler warning
    with finfo,fli do begin
     if intervalcount <= 0 then begin
      ticks:= nil;
     end
     else begin
      calclineend(fli,false,rect1,linestart,lineend,dir1);
      step:= 1/intervalcount;
      valstep:= step * frange;
      first:= (offset*intervalcount)/range;
      offs:= frac(first)/intervalcount; //scaled to 1.0
      first:= int(first);
      if offs > 0.0001 then begin
       offs:= offs - 1.0/intervalcount;
       first:= first + 1;
      end;
      int1:= round(intervalcount);
      offs:= -offs;
      if int1/intervalcount + offs > 1.0001 then begin
       dec(int1);
      end;
      first:= (first * frange) / intervalcount; //real value
      inc(int1);
      system.setlength(ticks,int1);
      system.setlength(ticksreal,int1);
      if fdirection in [gd_right,gd_left] then begin
       step:= rect1.cx * step;
       offs:= rect1.cx * offs;
       if fdirection = gd_left then begin
        step:= - step;
        offs:= rect1.cx - offs{ + 1};
       end;
       for int1:= 0 to high(ticks) do begin
        with ticks[int1] do begin
         ticksreal[int1]:= int1*step+offs;
         a.x:= rect1.x + round(ticksreal[int1]);
         b.x:= a.x;
         a.y:= linestart;
         b.y:= lineend;
        end;
       end;
      end
      else begin
       step:= rect1.cy * step;
       offs:= rect1.cy * offs;
       if fdirection = gd_up then begin
        step:= - step;
        offs:= rect1.cy - offs {+ 1};
       end;
       for int1:= 0 to high(ticks) do begin
        with ticks[int1] do begin
         ticksreal[int1]:= int1*step+offs;
         a.y:= rect1.y + round(ticksreal[int1]);
         b.y:= a.y;
         a.x:= linestart;
         b.x:= lineend;
        end;
       end;
      end;
      if caption = '' then begin
       captions:= nil;
      end
      else begin
       system.setlength(captions,system.length(ticks));
       int2:= high(captions) * 2; //2* interval count
       rea1:= (angle*2*pi) / int2;
       if fdirection in [gd_left,gd_right] then begin
        rea1:= -rea1;
       end;
       int2:= -int2 div 2;
       for int1:= 0 to high(captions) do begin
        captions[int1].caption:= getactcaption(int1*valstep+first,caption);
        with captions[int1] do begin
         pos:= ticks[int1].a;
         adjustcaption(dir1,fli,afont,
               canvas1.getstringwidth(caption,afont),pos);
         if do_rotatetext in foptions then begin
          angle:= int2 * rea1;
          int2:= int2 + 2;
         end
         else begin
          angle:= 0;
         end;
         angle:= angle + escapement * 2*pi;
        end;
       end;
      end;
      if dis_needstransform in fstate then begin
       for int1:= 0 to high(ticks) do begin
        with ticks[int1] do begin
         transform(a);
         transform(b);
        end;
       end;
      end;
     end;  
    end;
   end;
  end;
 end;
 include(fstate,dis_layoutvalid);
end;

procedure tcustomdialcontroller.invalidate;
begin
 fintf.getwidget.invalidate;
end;

procedure tcustomdialcontroller.paint(const acanvas: tcanvas);
var
 int1,int2: integer;
begin
 checklayout;
 for int1:= high(fticks.fitems) downto 0 do begin
  with tdialtick(fticks.fitems[int1]),finfo do begin
   if ticks <> nil then begin
    acanvas.linewidthmm:= actualwidthmm;
    if dashes <> '' then begin
     acanvas.dashes:= dashes;
    end;
    acanvas.drawlinesegments(ticks,actualcolor);
    if dashes <> '' then begin
     acanvas.dashes:= '';
    end;
   end;
   for int2:= 0 to high(captions) do begin
    with captions[int2] do begin
     acanvas.drawstring(caption,pos,afont,false,angle);
    end;
   end;
  end;
 end;
 fmarkers.paint(acanvas);
 acanvas.linewidth:= 0;
end;

procedure tcustomdialcontroller.afterpaint(const acanvas: tcanvas);
begin
 if foptions * [do_sideline,do_boxline] <> [] then begin
  acanvas.capstyle:= cs_projecting;
  acanvas.linewidthmm:= fwidthmm;
  acanvas.drawlinesegments(fboxlines,fcolor);
  acanvas.capstyle:= cs_butt;
  acanvas.linewidth:= 0;
 end;
end;

procedure tcustomdialcontroller.setoffset(const avalue: real);
begin
 if foffset <> avalue then begin
  foffset:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setrange(const avalue: real);
begin
 if frange <> avalue then begin
  checknullrange(avalue);
  frange:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setkind(const avalue: dialdatakindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setmarkers(const avalue: tdialmarkers);
begin
 fmarkers.assign(avalue);
end;

procedure tcustomdialcontroller.setoptions(const avalue: dialoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setticks(const avalue: tdialticks);
begin
 fticks.assign(avalue);
end;

function tcustomdialcontroller.getfont: tdialfont;
begin
 getoptionalobject(fintf.getwidget.componentstate,
                               ffont,{$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= tdialfont(twidget1(fintf.getwidget).getfont);
 end;
end;

procedure tcustomdialcontroller.setfont(const avalue: tdialfont);
begin
 if avalue <> ffont then begin
  setoptionalobject(fintf.getwidget.componentstate,
                   avalue,ffont,{$ifdef FPC}@{$endif}createfont);
  changed;
 end;
end;

function tcustomdialcontroller.isfontstored: boolean;
begin
 result:= ffont <> nil;
end;

procedure tcustomdialcontroller.createfont;
begin
 if ffont = nil then begin
  ffont:= tdialfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

procedure tcustomdialcontroller.fontchanged(const sender: tobject);
begin
 changed;
end;

procedure tcustomdialcontroller.setcolor(const avalue: colorty);
begin
 if avalue <> fcolor then begin
  fcolor:= avalue;
  fintf.getwidget.invalidate;
 end;
end;

procedure tcustomdialcontroller.setwidthmm(const avalue: real);
begin
 fwidthmm:= avalue;
 fintf.getwidget.invalidate;
end;

procedure tcustomdialcontroller.setangle(const avalue: real);
begin
 fangle:= avalue;
 changed;
end;

{ tcustomdial }

constructor tcustomdial.create(aowner: tcomponent);
begin
 fdial:= tdialcontroller.create(idialcontroller(self));
 inherited;
 size:= makesize(100,15);
 color:= cl_transparent;
end;

destructor tcustomdial.destroy;
begin
 fdial.free;
 inherited;
end;

procedure tcustomdial.setdial(const avalue: tdialcontroller);
begin
 fdial.assign(avalue);
end;

procedure tcustomdial.directionchanged(const dir,dirbefore: graphicdirectionty);
begin
 if not (csloading in componentstate) then begin
  if fframe <> nil then begin
   rotateframe1(tcustomframe1(fframe).fi.innerframe,dirbefore,dir);    
  end;
  widgetrect:= changerectdirection(widgetrect,dirbefore,dir);
 end;
end;

function tcustomdial.getdialrect: rectty;
begin
 result:= innerclientrect;
end;

procedure tcustomdial.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdial.paint(acanvas);
end;

procedure tcustomdial.clientrectchanged;
begin
 fdial.changed;
 inherited;
end;

end.
