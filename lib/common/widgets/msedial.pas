{ MSEgui Copyright (c) 2009-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedial;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 classes,mclasses,msewidgets,msegraphutils,msegraphics,msegui,msearrayprops,mseclasses,
 msetypes,mseglob,mseguiglob,msestrings,msemenus,mseevent,msestat;

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
  captionunit: msestring;
//  kind: dialdatakindty;
 end;

 dialtickoptionty =  (dto_invisible,dto_opposite,dto_rotatetext,
                      dto_multiplecaptions); 
                      //allow captions of different ticks at same position
                                    
 dialtickoptionsty = set of dialtickoptionty;

 dialtickinfoty = record
  ticks: segmentarty;
  ticksreal: realarty;
  captions: tickcaptionarty;
  intervalco: real;
  interval: real;
  afont: tfont;
  options: dialtickoptionsty;
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
   procedure setcaptionunit(const avalue: msestring);
   procedure setcaptiondist(const avalue: integer);
   procedure setcaptionoffset(const avalue: integer);
   function getfont: tdialpropfont;
   procedure setfont(const avalue: tdialpropfont);
   function isfontstored: boolean;
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
   procedure createfont;
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
   property captionunit: msestring read fli.captionunit write setcaptionunit;
   property captiondist: integer read fli.captiondist write setcaptiondist
                                       default 2;
   property captionoffset: integer read fli.captionoffset write setcaptionoffset
                                       default 0;
   property font: tdialpropfont read getfont write setfont stored isfontstored;
   property escapement: real read fli.escapement write setescapement;
 end;

 dialmarkeroptionty = (dmo_invisible,dmo_opposite,dmo_rotatetext,
                       dmo_hideoverload,dmo_limitoverload,
                       dmo_fix,dmo_ordered,dmo_savevalue); //for tchartedit
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
   procedure setvalue(const avalue: realty);
   procedure setoptions(const avalue: dialmarkeroptionsty);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
  protected
   procedure defineproperties(filer: tfiler); override;
   procedure updatemarker;
  public
   procedure paint(const acanvas: tcanvas);
   property visible: boolean read getvisible write setvisible;
  published
   property value: realty read finfo.value write setvalue {stored false};
   property options: dialmarkeroptionsty read finfo.options 
                          write setoptions default [];
 end;

 tcustomdialcontroller = class;

 tdialmarkers = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tdialmarker;
   procedure changed;
  protected
   fdim: rectextty;
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tcustomdialcontroller); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   procedure paint(const acanvas: tcanvas);
   property items[const index: integer]: tdialmarker read getitems; default;
 end;

 tdialtick = class(tdialprop)
  private
   finfo: dialtickinfoty;
   function getintervalcount: real;
   procedure setintervalcount(const avalue: real);
   procedure setoptions(const avalue: dialtickoptionsty);
   function getinterval: real;
   procedure setinterval(const avalue: real);
   function isintervalcountstored: boolean;
   function isintervalstored: boolean;
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
  protected
  public
   property visible: boolean read getvisible write setvisible;
  published
   property intervalcount: real read getintervalcount write setintervalcount 
                                       stored isintervalcountstored;
                      //0 -> off
   property interval: real read getinterval write setinterval
                                       stored isintervalstored;
                      //0 -> off
   property options: dialtickoptionsty read finfo.options 
                          write setoptions default [];
 end;
 
 tdialticks = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tdialtick;
  protected
   fdim: rectextty;
   procedure changed;
   procedure change(const index: integer); override;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomdialcontroller); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tdialtick read getitems; default;
 end;
 
 dialoptionty = (do_invisible,do_opposite,do_sideline,do_boxline,do_log,
                 do_front,do_scrollwithdata,do_shiftwithdata,
                 do_savestate);
 dialoptionsty = set of dialoptionty;  

 idialcontroller = interface(inullinterface)
  procedure directionchanged(const dir,dirbefore: graphicdirectionty);
  procedure layoutchanged;
  function getwidget: twidget;
  function getdialrect: rectty;
  function getdialsize: sizety;
 end;
 
 tcustomdialcontroller = class(tvirtualpersistent)
  private
   fdirection: graphicdirectionty;
   fstate: dialstatesty;
   fsstart: real;
   fstart: real;
   fshift: real;
   frange: real;
   fmarkers: tdialmarkers;
   fticks: tdialticks;
   foptions: dialoptionsty;
   fintf: idialcontroller;
   ffont: tdialfont;
   fcolor: colorty;
   fwidthmm: real;
   fboxlines: segmentarty;
   fstartang,farcang: real;
   fsidearc: rectty;
   fboxarc: rectty;
   fkind: dialdatakindty;
   fangle: real;
   fa: real;        //0.5 * angle in radiant
   fr: real;        //radius
   fscalep: real;   //periphery scale, 2/size
   foffsr: integer; //radius offset
   foffsp: integer; //periphery shift before/after transform
   fendr: integer;  //radius end for reversed direction
   farcscale: real; //factor diallenght arc / diallenght linear
   findent1: integer;
   findent2: integer;
   ffitdist: integer;
   procedure setstart(const avalue: real);
   procedure setshift(const avalue: real);
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
   procedure readstart(reader: treader);
   procedure setindent1(const avalue: integer);
   procedure setindent2(const avalue: integer);
   function getlog: boolean;
   procedure setlog(const avalue: boolean);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
   function getopposite: boolean;
   procedure setopposite(const avalue: boolean);
   function getsideline: boolean;
   procedure setsideline(const avalue: boolean);
   function getboxline: boolean;
   procedure setboxline(const avalue: boolean);
   function getfront: boolean;
   procedure setfront(const avalue: boolean);
   procedure setfitdist(const avalue: integer);
  protected
   procedure setdirection(const avalue: graphicdirectionty); virtual;
   procedure changed;
   procedure calclineend(const ainfo: diallineinfoty; const aopposite: boolean; 
                   const arect: rectty; out linestart,lineend: integer;
                   out linedirection: graphicdirectionty;
                   out adim: rectextty);
   procedure adjustcaption(const dir: graphicdirectionty;
                const arotatetext: boolean;
                const ainfo: diallineinfoty; const afont: tfont;
                const stringwidth: integer; var pos: pointty);
   procedure checklayout;
   procedure invalidate;
   procedure fontchanged(const sender: tobject);
   procedure transform(var apoint: pointty);
   procedure defineproperties(filer: tfiler); override;
   function getactdialrect(out arect: rectty): boolean;
   procedure paintdial(const acanvas: tcanvas);
  public
   constructor create(const aintf: idialcontroller); reintroduce; virtual;
   destructor destroy; override;
   procedure createfont;
   procedure paint(const acanvas: tcanvas);
   procedure afterpaint(const acanvas: tcanvas);
   property options: dialoptionsty read foptions write setoptions default []; 
                //first!
   property visible: boolean read getvisible write setvisible;
   property opposite: boolean read getopposite write setopposite;
   property sideline: boolean read getsideline write setsideline;
   property boxline: boolean read getboxline write setboxline;
   property log: boolean read getlog write setlog;
   property front: boolean read getfront write setfront;

   property direction: graphicdirectionty read fdirection write setdirection
                                       default gd_right;
   property indent1: integer read findent1 write setindent1 default 0;
   property indent2: integer read findent2 write setindent2 default 0;
   property fitdist: integer read ffitdist write setfitdist default 0;
   property start: real read fstart write setstart;
   property shift: real read fshift write setshift; //added to start
   property range: real read frange write setrange; //default 1.0
   property kind: dialdatakindty read fkind write setkind default dtk_real;
   property markers: tdialmarkers read fmarkers write setmarkers;
   property ticks: tdialticks read fticks write setticks;
   property color: colorty read fcolor write setcolor default defaultdialcolor;
   property widthmm: real read fwidthmm write setwidthmm; 
                //linewidth, default 0.3
   property font: tdialfont read getfont write setfont stored isfontstored;
   property angle: real read fangle write setangle; //0 -linear, 1 -> 360 grad
 end;

 dialcontrollerclassty = class of tcustomdialcontroller;
 
 tcustomdialcontrollers = class(tpersistentarrayprop)
  private
   fstart: real;
   frange: real;
   procedure setstart(const avalue: real);
   procedure setrange(const avalue: real);
  protected
   fintf: idialcontroller;
   function getitemclass: dialcontrollerclassty; virtual;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure changed;
  public
   constructor create(const aintf: idialcontroller);
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
  published
   property start: real read fstart write setstart;
   property range: real read frange write setrange;
 end;
 
const
 defaultdialcontrolleroptions = [do_opposite];

type 
 tdialcontroller = class(tcustomdialcontroller)
  public
   constructor create(const aintf: idialcontroller); override;
  published
   property options default defaultdialcontrolleroptions; //first!
   property color;
   property widthmm;
   property direction;
   property indent1;
   property indent2;
   property start;
   property range;
   property kind;
   property markers;
   property ticks;
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
   procedure layoutchanged;
   procedure directionchanged(const dir,dirbefore: graphicdirectionty);
   function getdialrect: rectty;
   function getdialsize: sizety;
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
function chartln(const avalue: real): real;
                //big neg value for avalue <= 0
function chartround(const avalue: real): integer; //limit to +-bigint
 
implementation
uses
 sysutils,msereal,msestreaming,mseformatstr,math,msebits;
type
 tcustomframe1 = class(tcustomframe);
 twidget1 = class(twidget);

procedure checknullrange(const avalue: real);
begin
 if avalue = 0 then begin
  raise exception.create('Range can not be 0.0.');
 end;
end;

function chartln(const avalue: real): real;
begin
 if avalue <= 0 then begin
  result:= -100000;
 end
 else begin
  result:= ln(avalue);
 end;
end;

function chartround(const avalue: real): integer; //limit to +-bigint
begin
 if avalue > bigint then begin
  result:= bigint;
 end
 else begin
  if avalue < -bigint then begin
   result:= -bigint;
  end
  else begin
   result:= round(avalue);
  end;
 end;
end;

procedure extenddim(const textwidth,asc,desc: integer; const pos: pointty;
                                                       var dim: rectextty);
var
 int2: integer;
begin
 with dim do begin
  int2:= pos.x + textwidth;
  if pos.x < left then begin
   left:= pos.x;
  end;
  if int2 > right then begin
   right:= int2;
  end;
  if top > pos.y - asc then begin
   top:= pos.y - asc;
  end;
  if bottom < pos.y + desc then begin
   bottom:= pos.y + desc;
  end;
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

procedure tdialprop.setcaptionunit(const avalue: msestring);
begin
 fli.captionunit:= avalue;
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
{$warnings off}
  result:= tdialpropfont(tcustomdialcontroller(fowner).getfont);
{$warnings on}
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
   active:=  not (finfo.value = emptyreal);
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
{
procedure tdialmarker.writevalue(writer: twriter);
begin
 writerealty(writer,finfo.value);
end;
}
procedure tdialmarker.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('val',
             {$ifdef FPC}@{$endif}readvalue,nil,false);
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
 rea1,rea2: real;
 start1,stop1: real;
 size1: sizety;
 pt1: pointty;
 rectext1: rectextty;
 int1: integer;
 
begin
 with tcustomdialcontroller(fowner),fli,finfo,line do begin
  getactdialrect(rect1);
  size1:= fintf.getdialsize;
  if (rect1.cx  <= 0) or (rect1.cy <= 0) then begin
   active:= false;
  end
  else begin
   calclineend(fli,dmo_opposite in options,rect1,linestart,lineend,dir1,
                                                                     rectext1);
   if do_log in foptions then begin
    rea2:= chartln(fsstart);
    rea1:= (chartln(frange+fsstart)-rea2);
    if rea1 = 0 then begin
     exit;
    end;
    rea1:= (chartln(value) - rea2)/rea1;
   end
   else begin
    rea1:= (value - fsstart)/frange;
   end;
   case fdirection of
    gd_right: begin
     start1:= -rect1.x / rect1.cx;
     stop1:= (size1.cx - rect1.x - 1) / rect1.cx;
    end;
    gd_up: begin
     start1:= ((rect1.y+rect1.cy)-size1.cy - 1) / rect1.cy;
     stop1:= (rect1.y+rect1.cy) / rect1.cy;
    end;
    gd_left: begin
     start1:= ((rect1.x+rect1.cx)-size1.cx - 1) / rect1.cx;
     stop1:= (rect1.x+rect1.cx) / rect1.cx;
    end;
    gd_down: begin
     start1:= -rect1.y / rect1.cy;
     stop1:= (size1.cy - rect1.y - 1) / rect1.cy;
    end;
   end;
   if dmo_hideoverload in options then begin
    if (rea1 < 0) or (rea1 > 1) then begin
     active:= false;
     exit;
    end;
   end;
   if dmo_limitoverload in options then begin
    if rea1 < start1 then begin
     rea1:= start1;
    end
    else begin
     if rea1 > stop1 then begin
      rea1:= stop1;
     end;
    end;
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
   if dmo_rotatetext in self.finfo.options then begin
    aangle:= -angle * (rea1-0.5) * 2*pi;
   end
   else begin
    aangle:= 0;
   end;
   aangle:= aangle + escapement*2*pi;
   if caption <> '' then begin
    afont:= self.font;
    acaption:= getactcaption(value,caption);
    captionpos:= a;
    int1:= fintf.getwidget.getcanvas.getstringwidth(acaption,afont);
    adjustcaption(dir1,dmo_rotatetext in self.finfo.options,fli,afont,
                                                           int1,captionpos);
    extenddim(int1,afont.ascent,afont.descent,captionpos,fmarkers.fdim);
   end;
   transform(a);
   transform(b);
   if dmo_opposite in options then begin
    pt1:= a;
    a:= b;
    b:= pt1;
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

function tdialmarker.getvisible: boolean;
begin
 result:= not (dmo_invisible in finfo.options);
end;

procedure tdialmarker.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [dmo_invisible];
 end
 else begin
  options:= options + [dmo_invisible];
 end; 
end;

{ tdialmarkers }

constructor tdialmarkers.create(const aowner: tcustomdialcontroller);
begin
 inherited create(aowner,tdialmarker);
end;

class function tdialmarkers.getitemclasstype: persistentclassty;
begin
 result:= tdialmarker;
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
  with tdialmarker(fitems[int1]) do begin
   if visible then begin
    paint(acanvas);
   end;
  end;
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

procedure tdialtick.setoptions(const avalue: dialtickoptionsty);
begin
 if finfo.options <> avalue then begin
  finfo.options:= avalue;
  changed;
 end;
end;

function tdialtick.getintervalcount: real;
begin
 if (finfo.intervalco <> 0) or 
            (do_log in tcustomdialcontroller(fowner).foptions) then begin
  result:= finfo.intervalco;
 end
 else begin
  if finfo.interval <> 0 then begin
   result:= tcustomdialcontroller(fowner).range/finfo.interval;
   if result > 1000 then begin
    result:= 1000;
   end;
  end
  else begin
   result:= 0;
  end;
 end;
end;

procedure tdialtick.setintervalcount(const avalue: real);
begin
 if finfo.intervalco <> avalue then begin
  finfo.intervalco:= avalue;
  if not (do_log in tcustomdialcontroller(fowner).foptions) then begin
   finfo.interval:= 0;
  end;
  changed;
 end;
end;

function tdialtick.getinterval: real;
begin
 if (finfo.interval <> 0) or 
            (do_log in tcustomdialcontroller(fowner).foptions) then begin
  result:= finfo.interval;
 end
 else begin
  if finfo.intervalco <> 0 then begin
   result:= tcustomdialcontroller(fowner).range/finfo.intervalco;
  end
  else begin
   result:= 0;
  end;
 end;
end;

procedure tdialtick.setinterval(const avalue: real);
begin
 if avalue <> finfo.interval then begin
  finfo.interval:= avalue;
  if not (do_log in tcustomdialcontroller(fowner).foptions) then begin
   finfo.intervalco:= 0;
  end;
  changed;
 end;
end;

function tdialtick.isintervalcountstored: boolean;
begin
 result:= (do_log in tcustomdialcontroller(fowner).foptions) or 
                           (finfo.intervalco <> 0);
end;

function tdialtick.isintervalstored: boolean;
begin
 result:= (do_log in tcustomdialcontroller(fowner).foptions) or
                           (finfo.interval <> 0);
end;

function tdialtick.getvisible: boolean;
begin
 result:= not (dto_invisible in finfo.options);
end;

procedure tdialtick.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [dto_invisible];
 end
 else begin
  options:= options + [dto_invisible];
 end; 
end;

{ tdialticks }

constructor tdialticks.create(const aowner: tcustomdialcontroller);
begin
 inherited create(aowner,tdialtick);
end;

class function tdialticks.getitemclasstype: persistentclassty;
begin
 result:= tdialtick;
end;

function tdialticks.getitems(const aindex: integer): tdialtick;
begin
 result:= tdialtick(inherited items[aindex]);
end;

procedure tdialticks.change(const index: integer);
begin
 inherited;
 if not (aps_destroying in fstate) then begin
  tcustomdialcontroller(fowner).changed;
 end;
end;

procedure tdialticks.createitem(const index: integer; var item: tpersistent);
begin
 inherited;
 if do_log in tcustomdialcontroller(fowner).foptions then begin
  tdialtick(item).interval:= 10;
 end;
end;

procedure tdialticks.changed;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tdialtick(fitems[int1]).flayoutvalid:= false;
 end; 
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
 dir1,dir2: graphicdirectionty;
begin
 if avalue <> fdirection then begin
  dir1:= fdirection;
  fdirection:= avalue;
  if fdirection >= gd_none then begin
   fdirection:= pred(fdirection);
  end;
  dir2:= fdirection;
  changed;
{
  case dir1 of
   gd_up: dir1:= gd_down;
   gd_down: dir1:= gd_up;
  end;
  case dir2 of
   gd_up: dir2:= gd_down;
   gd_down: dir2:= gd_up;
  end;
}
  fintf.directionchanged(dir2,dir1);
 end;
end;

procedure tcustomdialcontroller.changed;
begin
 fintf.layoutchanged;
 fmarkers.changed;
 fticks.changed;
 exclude(fstate,dis_layoutvalid);
{
 with fintf.getwidget do begin
  if not (csloading in componentstate) then begin
   exclude(fstate,dis_layoutvalid);
   invalidate;
   fmarkers.changed;
  end;
 end;
}
end;

procedure tcustomdialcontroller.calclineend(const ainfo: diallineinfoty;
                   const aopposite: boolean;
                   const arect: rectty; out linestart,lineend: integer;
                   out linedirection: graphicdirectionty;
                   out adim: rectextty);
var
// int1: integer;
 bo1: boolean;
begin
 bo1:= (do_opposite in foptions) xor aopposite;
 linedirection:= fdirection;
 if bo1 then begin
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
   gd_up: begin
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
   gd_down: begin
    linestart:= arect.x + indent;
    if length = 0 then begin
     lineend:= linestart + arect.cx - indent;
    end
    else begin
     lineend:= linestart + length;
    end;
   end;
  end;
  if linedirection in [gd_up,gd_down] then begin
   adim.left:= linestart;
   adim.right:= linestart;
   adim.top:= arect.y;
   adim.bottom:= arect.y + arect.cy;
  end
  else begin
   adim.top:= linestart;
   adim.bottom:= linestart;
   adim.left:= arect.x;
   adim.right:= arect.x + arect.cx;
  end;
 end;
end;

procedure tcustomdialcontroller.transform(var apoint: pointty);
 procedure trans(var pxy,ryx: integer);
 var
  r1: real;
  p1: real;
 begin
  r1:= fr - ryx + foffsr;
  p1:= fa*((pxy-foffsp)*fscalep);
  pxy:= round(r1*sin(p1)) + foffsp;
  ryx:= round(r1*(1-cos(p1))) + ryx;
 end; 
begin
 if dis_needstransform in fstate then begin
  case fdirection of
   gd_left: begin
    apoint.y:= fendr - apoint.y;
    trans(apoint.x,apoint.y);
    apoint.y:= fendr - apoint.y
   end;
   gd_down: begin
    apoint.x:= fendr - apoint.x;
    trans(apoint.y,apoint.x);
    apoint.x:= fendr - apoint.x
   end;
   gd_up: begin
    trans(apoint.y,apoint.x);
   end;
   else begin //gd_right
    trans(apoint.x,apoint.y);
   end;
  end;
 end;
end;

procedure tcustomdialcontroller.adjustcaption(const dir: graphicdirectionty;
              const arotatetext: boolean; const ainfo: diallineinfoty;
              const afont: tfont; const stringwidth: integer; var pos: pointty);

 function adjustscale(const avalue: integer): real;
 begin
  if fangle = 0 then begin
   result:= 1;
  end
  else begin
   if fdirection in [gd_left,gd_down] then begin
    result:= fendr - avalue;
   end
   else begin
    result:= avalue;
   end;
   result:= fr - result + foffsr;
   if result = 0 then begin
    result:= 1;
   end
   else begin
    result:= farcscale/result;
   end;
  end;
 end;
 
begin
 with ainfo,pos do begin
  case dir of 
   gd_right: begin
    y:= y + captiondist;
    x:= x + captionoffset;
    if not arotatetext then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     y:= y + afont.ascent;
     x:= x - round((stringwidth div 2)*adjustscale(y));
    end;
   end;
   gd_down: begin
    x:= x - captiondist;
    y:= y + captionoffset;
    if not arotatetext then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     x:= x - stringwidth;
     y:= y + round((afont.ascent - afont.glyphheight div 2)*adjustscale(x));
    end;
   end;
   gd_left: begin
    y:= y - captiondist;
    x:= x + captionoffset;
    if not arotatetext then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     y:= y - afont.descent;
     x:= x - round((stringwidth div 2)*adjustscale(y));
    end;
   end;
   gd_up: begin
    x:= x + captiondist;
    y:= y + captionoffset;
    if not arotatetext then begin
     transform(pos);
    end;
    if escapement = 0 then begin
     y:= y + round((afont.ascent - afont.glyphheight div 2)*adjustscale(x));
    end;
   end;
  end;
 end;
 if arotatetext then begin
  transform(pos);
 end;
end;

procedure tcustomdialcontroller.checklayout;

const
 tolerance = 0.000001;
 
 function getico(const interval: real; const intervalcount: integer): integer;
 begin
  result:= intervalcount - 
         floor((1/interval) * intervalcount * (1 + tolerance)); 
                      //ticks below decade
 end;
 
 function getlogval(const avalue: integer; const interval: real;
                            const intervalcount: integer): real;
 var
  ico: integer;
  int1: integer;
 begin
  ico:= getico(interval,intervalcount);
  if ico = 0 then begin
   result:= 0;
  end
  else begin
   result:= power(interval,avalue div ico);
   int1:= avalue mod ico;
   if int1 <> 0 then begin
    if int1 < 0 then begin
     int1:= int1+ico;
     result:= result * ((int1+intervalcount-ico)/intervalcount);
    end
    else begin
     result:= result * interval * ((int1+intervalcount-ico)/intervalcount);
    end;
   end;
  end;
 end;
 
 function getlogn(const avalue: real; const interval: real;
                            const intervalcount: integer): integer;
 var
  rea1{,rea2}: real;
  ico: integer;
 begin
  if avalue > 0 then begin
   result:= floor(logn(interval,avalue) + tolerance);
   rea1:= intpower(interval,result+1);
   ico:= getico(interval,intervalcount);
   result:= floor(result * ico + (avalue/rea1)*intervalcount+tolerance) -
                                                           intervalcount + ico;
  end
  else begin
   result:= 0;
  end;
 end;

var
 asc,desc: integer;
  
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
 rea1,rea2,rea3: real;
 po1,po2: prectty;
 po3: psegmentty;
 horz1: boolean;
 islog: boolean;
 logstartn,intervalcount1: integer;
 ar1: realarty;
 ar2: booleanarty;
 pt1: pointty;
 rectext1: rectextty;
 
begin
 if not (dis_layoutvalid in fstate) then begin
  canvas1:= fintf.getwidget.getcanvas;
  bo1:= getactdialrect(rect1);
  exclude(fstate,dis_needstransform);
  fsidearc:= nullrect;
  fboxarc:= nullrect;
  farcscale:= 1;
  horz1:= fdirection in [gd_right,gd_left];
  if fangle <> 0 then begin
   if bo1 then begin
    int2:= findent1;
   end
   else begin
    int2:= findent2;
   end;
   with rect1 do begin
    fa:= pi*fangle;    //0.5 * angle in radiant
    if fangle < 0.5 then begin
     int1:= round(sin(fa)*int2);
    end
    else begin
     int1:= int2;
    end;
    if horz1 then begin
     x:= x + int1;
     cx:= cx - 2 * int1;
     foffsr:= y;
     int1:= cx;
     foffsp:= int1 div 2 + x;
     if fdirection = gd_left then begin
      fendr:= 2*foffsr + cy;
     end;
    end
    else begin
     y:= y + int1;
     cy:= cy - 2 * int1;
     foffsr:= x;
     int1:= cy;
     foffsp:= int1 div 2 + y;
     if fdirection = gd_down then begin
      fendr:= 2*foffsr + cx;
     end;
    end;
   end;
   if int1 > 0 then begin
    include(fstate,dis_needstransform);
    fscalep:= 2.0/int1;
    fr:= int1/2.0;
    if fangle < 0.5 then begin
     fr:= fr/sin(fa);
    end;
    farcscale:= int1/(fa*2);
   end;    
   int1:= round(abs(fr));   //radius to direction
   if int1 < 30000 then begin
    int2:= round(2*abs(fr)); //diameter
    int3:= 0;             //perpendicular to direction
    if (fangle < 0) xor (direction in [gd_down,gd_left]) then begin
     int3:= -int2; 
    end;
    if (do_opposite in foptions) then begin
     po1:= @fsidearc;
     po2:= @fboxarc;
    end
    else begin
     po1:= @fboxarc;
     po2:= @fsidearc;
    end;
    case direction of
     gd_right: begin
      with po1^ do begin //normal circle
       x:= foffsp - int1;
       cx:= int2;
       y:= foffsr + int3;
       cy:= cx;
      end;
      with po2^ do begin //small/big circle
       if fangle < 0 then begin
        rea1:= 0.5+1;
        x:= foffsp - int1 - rect1.cy;
        cy:= int2 + rect1.cy + rect1.cy;
        y:= foffsr + int3 - rect1.cy;
       end
       else begin
        rea1:= 0.5;
        x:= foffsp - int1 + rect1.cy;
        cy:= int2 - rect1.cy - rect1.cy;
        y:= foffsr + int3 + rect1.cy;
       end;
       cx:= cy;
      end;
     end;
     gd_up: begin
      with po1^ do begin //normal circle
       y:= foffsp - int1;
       cx:= int2;
       x:= foffsr + int3;
       cy:= cx;
      end;
      with po2^ do begin //small/big circle
       if fangle < 0 then begin
        rea1:= 0;
        y:= foffsp - int1 - rect1.cx;
        cx:= int2 + rect1.cx + rect1.cx;
        x:= foffsr + int3 - rect1.cx;
       end
       else begin
        rea1:= 1;
        y:= foffsp - int1 + rect1.cx;
        cx:= int2 - rect1.cx - rect1.cx;
        x:= foffsr + int3 + rect1.cx;
       end;
       cy:= cx;
      end;
     end;
     gd_left: begin
      with po1^ do begin //normal circle
       x:= foffsp - int1;
       cx:= int2;
       y:= foffsr + int3 + rect1.cy;
       cy:= cx;
      end;
      with po2^ do begin //small/big circle
       if fangle < 0 then begin
        rea1:= 0.5;
        x:= foffsp - int1 - rect1.cy;
        cy:= int2 + rect1.cy + rect1.cy;
        y:= foffsr + int3;
       end
       else begin
        rea1:= -0.5;
        x:= foffsp - int1 + rect1.cy;
        cy:= int2 - rect1.cy - rect1.cy;
        y:= foffsr + int3 + rect1.cy + rect1.cy;
       end;
       cx:= cy;
      end;
     end;
     gd_down: begin
      with po1^ do begin //normal circle
       y:= foffsp - int1;
       cy:= int2;
       x:= foffsr + int3 + rect1.cx;
       cx:= cy;
      end;
      with po2^ do begin //small/big circle
       if fangle < 0 then begin
        rea1:= 1;
        y:= foffsp - int1 - rect1.cx;
        cx:= int2 + rect1.cx + rect1.cx;
        x:= foffsr + int3;
       end
       else begin
        rea1:= 0;
        y:= foffsp - int1 + rect1.cx;
        cx:= int2 - rect1.cx - rect1.cx;
        x:= foffsr + int3 + rect1.cx + rect1.cx;
       end;
       cy:= cx;
      end;
     end;
    end;
    fstartang:= pi*(rea1-fangle);
    farcang:= 2*pi*fangle;
   end;
  end;
  
  with rect1 do begin
   if horz1 then begin
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
  islog:= do_log in foptions;
  fticks.fdim:= emptyrectext;
  for int4:= 0 to high(fticks.fitems) do begin
   with tdialtick(fticks.fitems[int4]) do begin
    finfo.afont:= font;
    asc:= font.ascent;
    desc:= font.descent;
    linestart:= 0; //compiler warning
    lineend:= 0; //compiler warning
    with finfo,fli do begin
     if intervalcount <= 0 then begin
      ticks:= nil;
     end
     else begin
      calclineend(fli,dto_opposite in options,rect1,linestart,lineend,
                                                                 dir1,rectext1);
      expandrectext1(fticks.fdim,rectext1);
      if islog then begin
       offs:= -chartln(fsstart);
       rea1:= (chartln(fsstart+frange) + offs);
       if rea1 = 0 then begin
        exit;
       end;
       step:= 1/rea1; //used for scaling
       offs:= offs * step;
       intervalcount1:= round(intervalcount);
       if interval <= 0 then begin
        interval:= 10;
       end;
       logstartn:= getlogn(fsstart,interval,intervalcount1);
       rea1:= getlogval(logstartn,interval,intervalcount1);
       if fsstart <> 0 then begin
        if (fsstart-rea1)/fsstart > tolerance then begin
         inc(logstartn);
        end;
       end;
       rea1:= fsstart + frange;
       int1:= getlogn(rea1,interval,intervalcount1);
       int1:= int1 - logstartn;
      end
      else begin
       step:= 1/intervalcount;
       valstep:= step * frange;
       first:= (fsstart*intervalcount)/range;
       offs:= frac(first)/intervalcount; //scaled to 1.0
       first:= int(first);
       if offs > 0.0001 then begin
        offs:= offs - 1.0/intervalcount;
        first:= first + 1;
       end;
       offs:= -offs;
       int1:= trunc((1.0001-offs)*intervalcount);
       first:= (first * frange) / intervalcount; //real value
      end;
      inc(int1);
      if int1 < 0 then begin
       int1:= 0;
      end;
      system.setlength(ticks,int1);
      system.setlength(ticksreal,int1);
      if islog then begin
       system.setlength(ar1,int1);
      end;
      if horz1 then begin
       step:= rect1.cx * step;
       offs:= rect1.cx * offs;
       if fdirection = gd_left then begin
        step:= - step;
        offs:= rect1.cx - offs{ + 1};
       end;
       for int1:= 0 to high(ticks) do begin
        with ticks[int1] do begin
         if islog then begin
          ar1[int1]:= getlogval(int1 + logstartn,interval,intervalcount1);
          ticksreal[int1]:= chartln(ar1[int1])*step + offs;
         end
         else begin
          ticksreal[int1]:= int1*step + offs;
         end;
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
       if fdirection = gd_up{gd_up} then begin
        step:= - step;
        offs:= rect1.cy - offs {+ 1};
       end;
       for int1:= 0 to high(ticks) do begin
        with ticks[int1] do begin
         if islog then begin
          ar1[int1]:= getlogval(int1 + logstartn,interval,intervalcount1);
          ticksreal[int1]:= chartln(ar1[int1]) * step + offs;
         end
         else begin
          ticksreal[int1]:= int1*step + offs;
         end;
         a.y:= rect1.y + round(ticksreal[int1]);
         b.y:= a.y;
         a.x:= linestart;
         b.x:= lineend;
        end;
       end;
      end;
      ar2:= nil;
      system.setlength(ar2,system.length(ticks));
      bo1:= not (dto_multiplecaptions in options);
      for int1:= 0 to high(ticks) do begin //snap to existing ticks
       po3:= nil;
       rea1:= ticksreal[int1];
       for int2:= int4-1 downto 0 do begin
        with tdialtick(fticks.fitems[int2]).finfo do begin
         for int3:= 0 to high(ticks) do begin
          if abs(rea1-ticksreal[int3]) < 0.1 then begin
           po3:= @ticks[int3];
           ar2[int1]:= bo1 and (captions <> nil);
           break;
          end;
         end;
        end;
        if (po3 <> nil) and (not bo1 or ar2[int1]) then begin 
                                              //else check more captions
         break;
        end;
       end;
       if po3 <> nil then begin
        if horz1 then begin
         with ticks[int1] do begin
          a.x:= po3^.a.x;
          b.x:= a.x;
         end;
        end
        else begin
         with ticks[int1] do begin
          a.y:= po3^.a.y;
          b.y:= a.y;
         end;
        end;
       end;
      end;
      if (caption = '') and (captionunit = '') then begin
       captions:= nil;
      end
      else begin
       system.setlength(captions,system.length(ticks));
       rea3:= 0; //offset
       rea2:= 0; //scale
       if dto_rotatetext in options then begin
        rea3:= angle*pi; //offset
        if horz1 then begin
         if rect1.cx <> 0 then begin
          rea2:= -angle*2*pi/rect1.cx;
          if direction = gd_left then begin
           rea2:= -rea2;
           rea3:= -rea3;
          end;
         end;
        end
        else begin
         if rect1.cy <> 0 then begin
          rea2:= -angle*2*pi/rect1.cy;
          if direction = gd_up then begin
           rea2:= -rea2;
           rea3:= -rea3;
          end;
         end;
        end;
       end;
       rea3:= rea3+escapement * 2 * pi;
       for int1:= 0 to high(captions) do begin
        if islog then begin
         rea1:= ar1[int1];
        end
        else begin
         rea1:= int1*valstep+first;
         if abs(rea1/valstep) < 1e-6 then begin
          rea1:= 0;
         end;
        end;
        if ar2[int1] then begin
         captions[int1].caption:= '';
        end
        else begin
         if (captionunit <> '') and (int1 = high(captions) - 1) and 
                                                        (int1 > 0) then begin
          captions[int1].caption:= captionunit;
         end
         else begin
          captions[int1].caption:= getactcaption(rea1,caption);
         end;
        end;
        with captions[int1] do begin
         pos:= ticks[int1].a;
         int2:= canvas1.getstringwidth(caption,afont);
         adjustcaption(dir1,dto_rotatetext in options,fli,afont,
               int2,pos);
         angle:= ticksreal[int1] * rea2 + rea3;
         extenddim(int2,asc,desc,pos,fticks.fdim);        
        end;
       end;
       //todo: variable unitcaption pos.
      end;
     end;  
    end;
   end;
  end;
  if dis_needstransform in fstate then begin
   for int4:= 0 to high(fticks.fitems) do begin
    with tdialtick(fticks.fitems[int4]).finfo do begin
     for int1:= 0 to high(ticks) do begin
      with ticks[int1] do begin
       transform(a);
       transform(b);
      end;
     end;
    end;
   end;
  end;
  for int4:= 0 to high(fticks.fitems) do begin
   with tdialtick(fticks.fitems[int4]).finfo do begin
    if dto_opposite in options then begin
     for int1:= 0 to high(ticks) do begin
      with ticks[int1] do begin
       pt1:= a;
       a:= b;
       b:= pt1;
      end;
     end;
    end;
   end;
  end;
  with fmarkers do begin
   fdim:= emptyrectext;
   for int1:= 0 to count - 1 do begin
    with tdialmarker(fitems[int1]) do begin
     flayoutvalid:= false;
     checklayout;
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

procedure tcustomdialcontroller.paintdial(const acanvas: tcanvas);
var
 int1,int2: integer;
begin
 if visible then begin
  for int1:= high(fticks.fitems) downto 0 do begin
   with tdialtick(fticks.fitems[int1]),finfo do begin
    if visible then begin
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
  end;
 end;
 fmarkers.paint(acanvas);
 acanvas.linewidth:= 0;
end;

procedure tcustomdialcontroller.paint(const acanvas: tcanvas);
begin
 checklayout;
 if not (do_front in foptions) then begin
  paintdial(acanvas);
 end;
end;

procedure tcustomdialcontroller.afterpaint(const acanvas: tcanvas);
begin
 if do_front in foptions then begin
  paintdial(acanvas);
 end;
 if foptions * [do_sideline,do_boxline] <> [] then begin
  acanvas.capstyle:= cs_projecting;
  acanvas.linewidthmm:= fwidthmm;
  if fboxarc.cx <> 0 then begin
   if fangle = 1 then begin
    if do_boxline in foptions then begin
     acanvas.drawellipse1(fboxarc,fcolor);
    end;
    if do_sideline in foptions then begin
     acanvas.drawellipse1(fsidearc,fcolor);
    end;
   end
   else begin
    if do_boxline in foptions then begin
     acanvas.drawarc1(fboxarc,fstartang,farcang,fcolor);
    end;
    if do_sideline in foptions then begin
     acanvas.drawarc1(fsidearc,fstartang,farcang,fcolor);
    end;
   end;
  end
  else begin
   acanvas.drawlinesegments(fboxlines,fcolor);
  end;
  acanvas.capstyle:= cs_butt;
  acanvas.linewidth:= 0;
 end;
end;

procedure tcustomdialcontroller.setstart(const avalue: real);
begin
 if fstart <> avalue then begin
  fstart:= avalue;
  fsstart:= fshift+avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setshift(const avalue: real);
begin
 if fshift <> avalue then begin
  fshift:= avalue;
  fsstart:= fstart+avalue;
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
const
 mask: dialoptionsty = [do_scrollwithdata,do_shiftwithdata];
begin
 if foptions <> avalue then begin
  foptions:= dialoptionsty(
   setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(avalue),
                 {$ifdef FPC}longword{$else}byte{$endif}(foptions),
                 {$ifdef FPC}longword{$else}byte{$endif}(mask)));
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
{$warnings off}
  result:= tdialfont(twidget1(fintf.getwidget).getfont);
{$warnings on}
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

procedure tcustomdialcontroller.setindent1(const avalue: integer);
begin
 if findent1 <> avalue then begin
  findent1:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setindent2(const avalue: integer);
begin
 if findent2 <> avalue then begin
  findent2:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.setfitdist(const avalue: integer);
begin
 if ffitdist <> avalue then begin
  ffitdist:= avalue;
  changed;
 end;
end;

procedure tcustomdialcontroller.readstart(reader: treader);
begin
 start:= reader.readfloat;
end;

procedure tcustomdialcontroller.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('offset',{$ifdef FPC}@{$endif}readstart,nil,false);
end;

function tcustomdialcontroller.getactdialrect(out arect: rectty): boolean;
var
 int1,int2: integer;
begin
 arect:= fintf.getdialrect;
 result:= (fdirection in [gd_left,gd_down]) xor (do_opposite in foptions);
 if result then begin
  int1:= findent1;
  int2:= findent2;
 end
 else begin
  int2:= findent1;
  int1:= findent2;
 end;
 with arect do begin
  if fdirection in [gd_right,gd_left] then begin
   y:= y + int1;
   cy:= cy - int1 - int2;
  end
  else begin
   x:= x + int1;
   cx:= cx - int1 - int2;
  end;
 end;
end;

function tcustomdialcontroller.getlog: boolean;
begin
 result:= do_log in options;
end;

procedure tcustomdialcontroller.setlog(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [do_log];
 end
 else begin
  options:= options - [do_log];
 end;
end;

function tcustomdialcontroller.getvisible: boolean;
begin
 result:= not (do_invisible in foptions);
end;

procedure tcustomdialcontroller.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [do_invisible];
 end
 else begin
  options:= options + [do_invisible];
 end; 
end;

function tcustomdialcontroller.getopposite: boolean;
begin
 result:= do_opposite in foptions;
end;

procedure tcustomdialcontroller.setopposite(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [do_opposite];
 end
 else begin
  options:= options - [do_opposite];
 end; 
end;

function tcustomdialcontroller.getsideline: boolean;
begin
 result:= do_sideline in foptions;
end;

procedure tcustomdialcontroller.setsideline(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [do_sideline];
 end
 else begin
  options:= options - [do_sideline];
 end; 
end;

function tcustomdialcontroller.getboxline: boolean;
begin
 result:= do_boxline in foptions;
end;

procedure tcustomdialcontroller.setboxline(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [do_boxline];
 end
 else begin
  options:= options - [do_boxline];
 end; 
end;

function tcustomdialcontroller.getfront: boolean;
begin
 result:= do_front in foptions;
end;

procedure tcustomdialcontroller.setfront(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [do_front];
 end
 else begin
  options:= options - [do_front];
 end; 
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

function tcustomdial.getdialsize: sizety;
begin
 result:= clientsize;
end;

procedure tcustomdial.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdial.paint(acanvas);
 fdial.afterpaint(acanvas);
end;

procedure tcustomdial.clientrectchanged;
begin
 fdial.changed;
 inherited;
end;

procedure tcustomdial.layoutchanged;
begin
 invalidate;
end;

{ tcustomdialcontrollers }

constructor tcustomdialcontrollers.create(const aintf: idialcontroller);
begin
 fintf:= aintf;
 frange:= 1;
 inherited create(getitemclass);
end;

procedure tcustomdialcontrollers.createitem(const index: integer;
               var item: tpersistent);
begin
 item:= dialcontrollerclassty(fitemclasstype).create(fintf);
 tcustomdialcontroller(item).start:= fstart;
 tcustomdialcontroller(item).range:= frange;
end;

function tcustomdialcontrollers.getitemclass: dialcontrollerclassty;
begin
 result:= tcustomdialcontroller;
end;

procedure tcustomdialcontrollers.setstart(const avalue: real);
var
 int1: integer;
begin
 fstart:= avalue;
 for int1:= 0 to high(fitems) do begin
  tcustomdialcontroller(fitems[int1]).start:= avalue;
 end;
end;

procedure tcustomdialcontrollers.setrange(const avalue: real);
var
 int1: integer;
begin
 frange:= avalue;
 for int1:= 0 to high(fitems) do begin
  tcustomdialcontroller(fitems[int1]).range:= avalue;
 end;
end;

procedure tcustomdialcontrollers.dostatread(const reader: tstatreader);
var
 int1,int2: integer;
 mstr1: msestring;
begin
 for int1:= 0 to count - 1 do begin
  mstr1:= inttostr(int1);
  with tcustomdialcontroller(fitems[int1]) do begin
   if do_savestate in foptions then begin
    start:= reader.readreal('start'+mstr1,start);
    range:= reader.readreal('range'+mstr1,range);
   end;
   mstr1:= 'marker'+mstr1+'_';
   for int2:= 0 to markers.count - 1 do begin
    with markers[int2] do begin
     if dmo_savevalue in options then begin
      value:= reader.readreal(mstr1+inttostrmse(int2),value);      
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomdialcontrollers.dostatwrite(const writer: tstatwriter);
var
 int1,int2: integer;
 mstr1: msestring;
begin
 for int1:= 0 to count - 1 do begin
  mstr1:= inttostr(int1);
  with tcustomdialcontroller(fitems[int1]) do begin
   if do_savestate in options then begin
    writer.writereal('start'+mstr1,start);
    writer.writereal('range'+mstr1,range);
   end;
   mstr1:= 'marker'+mstr1+'_';
   for int2:= 0 to markers.count - 1 do begin
    with markers[int2] do begin
     if dmo_savevalue in options then begin
      writer.writereal(mstr1+inttostrmse(int2),value);      
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomdialcontrollers.changed;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  with tcustomdialcontroller(fitems[int1]) do begin
   changed;
  end;
 end;
end;

{ tdialcontroller }

constructor tdialcontroller.create(const aintf: idialcontroller);
begin
 inherited;
 options:= defaultdialcontrolleroptions;
end;

end.
