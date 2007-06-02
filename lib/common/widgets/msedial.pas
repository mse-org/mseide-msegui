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
 
type
 dialstatety = (dis_layoutvalid);
 dialstatesty = set of dialstatety;

 tickcaptionty = record
  caption: msestring;
  pos: pointty;
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
  font: tdialpropfont;
  caption: msestring;
  kind: dialdatakindty;
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
   function getfont: tdialpropfont;
   procedure setfont(const avalue: tdialpropfont);
   function isfontstored: boolean;
   procedure createfont;
   procedure fontchanged(const sender: tobject);
   procedure setkind(const avalue: dialdatakindty);
  protected
   flayoutvalid: boolean;
   procedure changed; virtual;
   function getactcaption(const avalue: real; const aformat: msestring): msestring;
  public
   constructor create(aowner: tobject); override;   
   destructor destroy; override;
  published
   property color: colorty read fli.color write setcolor
                             default cl_glyph;
   property widthmm: real read fli.widthmm write setwidthmm;
                           //default 0.3
   property dashes: string read fli.dashes write setdashes;
   property indent: integer read fli.indent 
                     write setindent default 0;
   property length: integer read fli.length 
                     write setlength default 0;
                      //0 -> whole innerclientrect
   property caption: msestring read fli.caption write setcaption;
   property captiondist: integer read fli.captiondist write setcaptiondist
                                       default 2;
   property font: tdialpropfont read getfont write setfont stored isfontstored;
   property kind: dialdatakindty read fli.kind write setkind default dtk_real;
 end;

 dialmarkeroptionty = (dmo_opposite);
 dialmarkeroptionsty = set of dialmarkeroptionty;
 
 markerinfoty = record
  active: boolean;
  line: segmentty;
  value: realty;
  captionpos: pointty;
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
 
 dialoptionty = (do_opposite);
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
   procedure setoffset(const avalue: real);
   procedure setrange(const avalue: real);
   procedure setmarkers(const avalue: tdialmarkers);
   procedure setoptions(const avalue: dialoptionsty);
   procedure setticks(const avalue: tdialticks);
   function getfont: tdialfont;
   procedure setfont(const avalue: tdialfont);
   function isfontstored: boolean;
  protected
   procedure setdirection(const avalue: graphicdirectionty); virtual;
   procedure changed;
   procedure calclineend(const ainfo: diallineinfoty; const aopposite: boolean; 
                   const arect: rectty; out linestart,lineend: integer;
                   out linedirection: graphicdirectionty);
   procedure checklayout;
   procedure invalidate;
   procedure createfont;
   procedure fontchanged(const sender: tobject);
  public
   constructor create(const aintf: idialcontroller);
   destructor destroy; override;
   procedure paint(const acanvas: tcanvas);
   property direction: graphicdirectionty read fdirection write setdirection
                                       default gd_right;
   property offset: real read foffset write setoffset;//0.0..1.0
   property range: real read frange write setrange; //default 1.0
   property markers: tdialmarkers read fmarkers write setmarkers;
   property ticks: tdialticks read fticks write setticks;
   property options: dialoptionsty read foptions write setoptions default [];
   property font: tdialfont read getfont write setfont stored isfontstored;
 end;

 tdialcontroller = class(tcustomdialcontroller)
  published
   property direction;
   property offset;
   property range;
   property markers;
   property ticks;
   property options;
   property font;
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
 
implementation
uses
 sysutils,msereal,msestreaming,mseformatstr;
type
 tcustomframe1 = class(tcustomframe);
 twidget1 = class(twidget);
 
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
 fli.color:= cl_glyph;
 fli.captiondist:= 2;
 fli.widthmm:= 0.3;
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

procedure tdialprop.setkind(const avalue: dialdatakindty);
begin
 if fli.kind <> avalue then begin
  fli.kind:= avalue;
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

function tdialprop.getactcaption(const avalue: real; const aformat: msestring): msestring;
begin
 if fli.kind = dtk_datetime then begin
  result:= datetimetostring(avalue,aformat);
 end
 else begin
  result:= formatfloatmse(avalue,aformat);
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
   acanvas.linewidthmm:= widthmm;
   if dashes <> '' then begin
    acanvas.dashes:= dashes;
   end;
   acanvas.drawline(line.a,line.b,color);
   if dashes <> '' then begin
    acanvas.dashes:= '';
   end;
   if caption <> '' then begin
    acanvas.drawstring(acaption,captionpos,self.font);
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
  with tcustomdialcontroller(fowner),fticks do begin
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
 int1,int2,int3: integer;
begin
 with tcustomdialcontroller(fowner),fli,finfo,line do begin
  rect1:= fintf.getdialrect;
  calclineend(fli,dmo_opposite in options,rect1,linestart,lineend,dir1);
  case fdirection of
   gd_right: begin
    a.x:= snap(rect1.cx * (value - foffset)/frange);
    b.x:= a.x;
    a.y:= linestart;
    b.y:= lineend;
   end;
   gd_up: begin
    a.y:= snap(rect1.cy - (rect1.cy * (value - foffset)/frange));
    b.y:= a.y;
    a.x:= linestart;
    b.x:= lineend;
   end;
   gd_left: begin
    a.x:= snap(rect1.cx - (rect1.cx * (value - foffset)/frange));
    b.x:= a.x;
    a.y:= linestart;
    b.y:= lineend;
   end;
   gd_down: begin
    a.y:= snap(rect1.cy * (value - foffset)/frange);
    b.y:= a.y;
    a.x:= linestart;
    b.x:= lineend;
   end;
  end;
  if caption <> '' then begin
   afont:= self.font;
   acaption:= getactcaption(value,caption);
   int2:= fintf.getwidget.getcanvas.getstringwidth(acaption,afont);
   int3:= afont.ascent - afont.glyphheight div 2;
   case dir1 of
    gd_left: begin
     int3:= -afont.descent - captiondist;
     captionpos.x:= line.a.x - int2 div 2;
     captionpos.y:= line.a.y + int3 - captiondist;
    end;
    gd_up: begin
     captionpos.x:= line.a.x - int2 - captiondist;
     captionpos.y:= line.a.y + int3;
    end;
    gd_down: begin
     captionpos.x:= line.a.x + captiondist;
     captionpos.y:= line.a.y + int3;
    end;
    else begin //gd_right
     int3:= afont.ascent;
     captionpos.x:= line.a.x - int2 div 2;
     captionpos.y:= line.a.y + int3 + captiondist;
    end;
   end;   
  end;
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
 ar1: integerarty;
 dir1: graphicdirectionty;
 
begin
 if not (dis_layoutvalid in fstate) then begin
  canvas1:= fintf.getwidget.getcanvas;
  rect1:= fintf.getdialrect;
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
//         if fdirection = gd_left then begin
//          dec(a.x);
//         end;
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
//         if fdirection = gd_up then begin
//          dec(a.y);
//         end;
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
       system.setlength(ar1,system.length(ticks));
       for int1:= 0 to high(captions) do begin
        captions[int1].caption:= getactcaption(int1*valstep+first,caption);
        ar1[int1]:= canvas1.getstringwidth(captions[int1].caption,afont);
       end;
       int3:= afont.ascent - afont.glyphheight div 2;
       case dir1 of
        gd_left: begin
         int3:= -afont.descent - captiondist;
         for int1:= 0 to high(captions) do begin
          with captions[int1] do begin
           pos.x:= ticks[int1].a.x - ar1[int1] div 2;
           pos.y:= ticks[int1].a.y + int3 - captiondist;
          end;
         end;
        end;
        gd_up: begin
         for int1:= 0 to high(captions) do begin
          with captions[int1] do begin
           pos.x:= ticks[int1].a.x - ar1[int1] - captiondist;
           pos.y:= ticks[int1].a.y + int3;
          end;
         end;
        end;
        gd_down: begin
         for int1:= 0 to high(captions) do begin
          with captions[int1] do begin
           pos.x:= ticks[int1].a.x + captiondist;
           pos.y:= ticks[int1].a.y + int3;
          end;
         end;
        end;
        else begin //gd_right
         int3:= afont.ascent;
         for int1:= 0 to high(captions) do begin
          with captions[int1] do begin
           pos.x:= ticks[int1].a.x - ar1[int1] div 2;
           pos.y:= ticks[int1].a.y + int3 + captiondist;
          end;
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
    acanvas.linewidthmm:= widthmm;
    if dashes <> '' then begin
     acanvas.dashes:= dashes;
    end;
    acanvas.drawlinesegments(ticks,color);
    if dashes <> '' then begin
     acanvas.dashes:= '';
    end;
   end;
   for int2:= 0 to high(captions) do begin
    with captions[int2] do begin
     acanvas.drawstring(caption,pos,afont);
    end;
   end;
  end;
 end;
 fmarkers.paint(acanvas);
 acanvas.linewidth:= 0;
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
  if avalue = 0 then begin
   raise exception.create('Range can not be 0.0.');
  end;
  frange:= avalue;
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
