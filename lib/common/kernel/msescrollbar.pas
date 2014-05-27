{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msescrollbar;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface

uses
 mseguiglob,msegraphics,msegraphutils,msetimer,mseevent,mseshapes,
 classes,mclasses,msetypes,msegui,mseclasses,mseglob;

const
 defaultscrollbarwidth = 15;
 defaultpagesizeconst = 0.1;
 defaultpagesize: real = defaultpagesizeconst;
 defaultbuttonminlength = 11;//8;
 repeatdelaytime = 500000; //0.5s
 repeatrepeattime = 100000; //0.1 s

type

 scrollbarareaty = (sbbu_down,sbbu_move,sbbu_up,sba_start,sba_end);
 buttonareaty = (bbu_down,bbu_move,bbu_up);
const
 scrollbarclicked = ord(sba_end) + 1;

type
 scrollbaroptionty = (sbo_thumbtrack,sbo_moveauto,sbo_showauto,sbo_show,
                      sbo_opposite,sbo_valuekeys,sbo_noarrowkeys,sbo_nopagekeys,
                      sbo_noreflectedclick{,
                      sbo_flat,sbo_noanim});
                       //sbo_valuekeys -> pageup = valueincrement
 scrollbaroptionsty = set of scrollbaroptionty;

const
 firstbutton = sbbu_down;
 lastbutton = sbbu_up;
 defaultscrollbaroptions = [sbo_moveauto,sbo_showauto];

type
 tcustomscrollbar = class;

 scrolleventty =  (sbe_none,sbe_valuechanged,sbe_stepup,sbe_stepdown,
                   sbe_pageup,sbe_pagedown,sbe_wheelup,sbe_wheeldown,
                   sbe_thumbposition,sbe_thumbtrack);

 iscrollbar = interface(inullinterface)
  function getwidget: twidget;
  function translatecolor(const acolor: colorty): colorty;
  procedure invalidaterect(const rect: rectty; const org: originty;
                    const noclip: boolean = false);
  procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty);
 end;

 scrollbardrawinfoty = record
  scrollrect: rectty;
  buttonareas: array[buttonareaty] of rectty;
  areas: array[scrollbarareaty] of shapeinfoty;
 end;

 scrollbarstatety = (scs_mousecaptured,scs_streampagesize);
 scrollbarstatesty = set of scrollbarstatety;

 beforescrollbareventty = procedure(const sender: tcustomscrollbar;
              var akind: scrolleventty; var avalue: real) of object;
 scrollbareventty = procedure(const sender: tcustomscrollbar;
              const akind: scrolleventty; const avalue: real) of object;
            //avalue = step or value              
 tcustomscrollbar = class(tnullinterfacedpersistent,iframe)
  private
   forg: originty;
   fdim: rectty;
   fdirection: graphicdirectionty;
   fcolor: colorty;
   fcolorpattern: colorty;
   fvalue: real;
   fbuttonlength: integer;
   fpagesize: real;
   fstepsize: real;
   fclickedarea: scrollbarareaty;
   frepeater: tsimpletimer;
   fpickoffset: integer;
   fpickpos: pointty;
   fscrollrange: integer;
   fbuttonminlength: integer;
   fwidth: integer;
   ffacebutton: tface;
   ffaceendbutton: tface;
   fframebutton: tframe;
   fframeendbutton1: tframe;
   fframeendbutton2: tframe;
   fondimchanged: proceventty;
   fbuttonendlength: integer;
   fpaintedbutton: scrollbarareaty;
   fonbeforeevent: beforescrollbareventty;
   fonafterevent: scrollbareventty;
   fstepctrlfact: real;
   fstepshiftfact: real;
   fwheelsensitivity: real;
   procedure updatedim;
   procedure setdirection(const avalue: graphicdirectionty);
   procedure setcolor(const avalue: colorty);
   procedure setcolorglyph(const avalue: colorty);
   procedure invalidatepos;
   procedure invalidateclickedarea;
   procedure setvalue(Value: real);
   procedure setbuttonlength(const avalue: integer);
   procedure setpagesize(avalue: real);
   function findarea(const point: pointty): scrollbarareaty;
   procedure timer(const sender: tobject);
   function dobuttoncommand: boolean;
   procedure thumbtrack(var pos: pointty);
   procedure setdim(const arect: rectty);
   procedure setbuttonminlength(const avalue: integer);
   procedure setwidth(const avalue: integer);
   procedure setindentstart(const avalue: integer);
   procedure setindentend(const avalue: integer);
   function getstepsize: real;
   procedure dodimchanged;
   function clickedareaisvalid: boolean;
   procedure setcolorpattern(const avalue: colorty);
   function getfacebutton: tface;
   procedure setfacebutton(const avalue: tface);
   function getfaceendbutton: tface;
   procedure setfaceendbutton(const avalue: tface);
   procedure setbuttonendlength(const avalue: integer);
   function getframebutton: tframe;
   procedure setframebutton(const avalue: tframe);
   function getframeendbutton1: tframe;
   procedure setframeendbutton1(const avalue: tframe);
   function getframeendbutton2: tframe;
   procedure setframeendbutton2(const avalue: tframe);
   procedure readstepsize(reader: treader);
   procedure writestepsize(writer: twriter);
   procedure readstepctrlfact(reader: treader);
   procedure writestepctrlfact(writer: twriter);
   procedure readstepshiftfact(reader: treader);
   procedure writestepshiftfact(writer: twriter);
   procedure readpagesize(reader: treader);
   procedure writepagesize(writer: twriter);
   procedure readwheelsensitivity(reader: treader);
   procedure writewheelsensitivity(writer: twriter);
    //iframe
   procedure setframeinstance(instance: tcustomframe);
   procedure setstaticframe(value: boolean);
   function getstaticframe: boolean;
   procedure scrollwidgets(const dist: pointty);
   procedure clientrectchanged;
   function getcomponentstate: tcomponentstate;
   function getmsecomponentstate: msecomponentstatesty;
   procedure invalidatewidget;
   procedure invalidaterect(const rect: rectty; 
             const org: originty = org_client; const noclip: boolean = false);
   function getwidget: twidget;
   function getwidgetrect: rectty;
   function getframestateflags: framestateflagsty;
  protected
   fstate: scrollbarstatesty;
   fintf: iscrollbar;
   foptions: scrollbaroptionsty;
   fdrawinfo: scrollbardrawinfoty;
   findentstart,findentend: integer;
   function getshiftfact(ashiftstate: shiftstatesty; out fact: real): boolean;
                                             //false if not valid
   procedure setoptions(const avalue: scrollbaroptionsty); virtual;
   procedure invalidate;
   procedure dostep(akind: scrolleventty; astep: real);
   procedure dothumbevent(const aevent: scrolleventty);
   function dostepup(const ashiftstate: shiftstatesty): boolean;
   function dostepdown(const ashiftstate: shiftstatesty): boolean;
   procedure defineproperties(filer: tfiler); override;
  public
   tag: integer;
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); reintroduce; virtual;
   destructor destroy; override;
   procedure createfacebutton;
   procedure createfaceendbutton;
   procedure createframebutton;
   procedure createframeendbutton1;
   procedure createframeendbutton2;
   procedure checktemplate(const sender: tobject);
   procedure paint(const canvas: tcanvas; const acolor: colorty = cl_none); virtual;
                       //color <> cl_none -> flat paint for grid cell
   function wantmouseevent(const apos: pointty): boolean;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure mousewheelevent(var info: mousewheeleventinfoty;
                               const pagingreversed: boolean = false);
   procedure keydown(var info: keyeventinfoty);
   procedure enter;
   procedure exit;
   function clicked: boolean;
   procedure activechanged;

   procedure stepup;
   procedure stepdown;
   procedure pageup;
   procedure pagedown;
   procedure wheelup(const shiftstate: shiftstatesty = []);
   procedure wheeldown(const shiftstate: shiftstatesty = []);

   property direction: graphicdirectionty read fdirection write setdirection
                                default gd_right;
   property value: real read fvalue write setvalue;
   property dim: rectty read fdim write setdim;

   property width: integer read fwidth write setwidth default defaultscrollbarwidth;
   property indentstart: integer read findentstart write setindentstart default 0;
   property indentend: integer read findentend write setindentend default 0;
    // 0 default behavior (width ident if horz and vert visible), < 0 no ident
   property options: scrollbaroptionsty read foptions write setoptions
                          default defaultscrollbaroptions;
   property stepsize: real read getstepsize write fstepsize stored false;
                    //default = 0 -> pagesize /10
   property stepctrlfact: real read fstepctrlfact 
                                     write fstepctrlfact stored false;
                    //default = 0 -> no ctrl step
   property stepshiftfact: real read fstepshiftfact 
                                          write fstepshiftfact stored false;
                    //default = 0 -> no shift step
   property pagesize: real read fpagesize write setpagesize stored false;
                    //default = defaultpagesize
   property wheelsensitivity: real read fwheelsensitivity
                                     write fwheelsensitivity stored false;
                    //default = 1
   property buttonlength: integer read fbuttonlength 
                                             write setbuttonlength default 0;
                     //0 -> proportional -1 -> square
   property buttonminlength: integer read fbuttonminlength
                 write setbuttonminlength default defaultbuttonminlength;
   property buttonendlength: integer read fbuttonendlength 
                         write setbuttonendlength default 0;
                     //0 -> square, -1 -> no endbuttons
   property facebutton: tface read getfacebutton write setfacebutton;
   property faceendbutton: tface read getfaceendbutton write setfaceendbutton;
   property framebutton: tframe read getframebutton write setframebutton;
   property frameendbutton1: tframe read getframeendbutton1 
                                 write setframeendbutton1;
   property frameendbutton2: tframe read getframeendbutton2
                                 write setframeendbutton2;
   property color: colorty read fcolor write setcolor default cl_default;
   property colorpattern: colorty read fcolorpattern 
                   write setcolorpattern default cl_white;
                   //cl_none -> no pattern
   property colorglyph: colorty read fdrawinfo.areas[sbbu_down].ca.colorglyph
                   write setcolorglyph default cl_glyph;
                   //cl_none -> no no glyph
   property onbeforeevent: beforescrollbareventty read fonbeforeevent 
                                                        write fonbeforeevent;
   property onafterevent: scrollbareventty read fonafterevent 
                                                        write fonafterevent;
 end;

 tcustomnomoveautoscrollbar = class(tcustomscrollbar)
  protected
   procedure setoptions(const avalue: scrollbaroptionsty); override;
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
   property options default defaultscrollbaroptions-[sbo_moveauto];
 end;


 tnopagesizescrollbar = class(tcustomscrollbar)
  published
   property options;
   property width;
   property indentstart;
   property indentend;
   property stepctrlfact;
   property stepshiftfact;
   property wheelsensitivity;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
   property facebutton;
   property faceendbutton;
   property framebutton;
   property frameendbutton1;
   property frameendbutton2;
   property color;
   property colorpattern;
   property colorglyph;
   property onbeforeevent;
   property onafterevent;
 end;
 
 tscrollbar = class(tnopagesizescrollbar)
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
                               ondimchanged: proceventty = nil); override;
  published
   property pagesize;
   property stepsize;   
 end;
 
 tnomoveautonopagesizescrollbar = class(tcustomnomoveautoscrollbar)
  published
   property options;
   property width;
   property indentstart;
   property indentend;
   property stepctrlfact;
   property stepshiftfact;
   property wheelsensitivity;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
   property facebutton;
   property faceendbutton;
   property framebutton;
   property frameendbutton1;
   property frameendbutton2;
   property color;
   property colorpattern;
   property colorglyph;
   property onbeforeevent;
   property onafterevent;
 end;

 tnomoveautoscrollbar = class(tnomoveautonopagesizescrollbar)
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
  published
   property stepsize;
   property pagesize;
 end;

implementation

uses
 msestockobjects,sysutils,msekeyboard,msebits,msepointer,mseact;
type
 twidget1 = class(twidget);
 
{ tcustomscrollbar }

constructor tcustomscrollbar.create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil);
var
 bu1: scrollbarareaty;
begin
 foptions:= defaultscrollbaroptions;
 fintf:= intf;
 forg:= org;
 fcolor:= cl_default;
 fcolorpattern:= cl_white;
 fdrawinfo.areas[sbbu_down].ca.colorglyph:= cl_glyph;
 fdrawinfo.areas[sbbu_up].ca.colorglyph:= cl_glyph;
 fclickedarea:= scrollbarareaty(-1);
 fbuttonminlength:= defaultbuttonminlength;
 fwidth:= defaultscrollbarwidth;
 fondimchanged:= ondimchanged;
 fpagesize:= defaultpagesize;
 fwheelsensitivity:= 1;
 for bu1:= low(scrollbarareaty) to high(scrollbarareaty) do begin
  fdrawinfo.areas[bu1].color:= cl_parent;
 end;
end;

procedure tcustomscrollbar.updatedim;
var
 width1,scrolllength,buttonlength1: integer;
 bu1: scrollbarareaty;
 endblen: integer;
 minblen: integer;
 quadblen: integer;

 procedure checkscrolllength(const alength: integer);
 var
  int1: integer;
 begin
  scrolllength:= alength - endblen - endblen;
  if (fbuttonlength < 0) then begin
   int1:= scrolllength div 2;
   if int1 < quadblen then begin
    quadblen:= int1;
   end;
  end;
  if scrolllength < 2 * minblen then begin
   endblen:= (alength - 2 * minblen) div 2;
   if endblen < minblen then begin
    endblen:= alength div 4;
    minblen:= endblen;
   end;
   if endblen < quadblen then begin
    quadblen:= endblen;
   end;
   scrolllength:= alength - endblen - endblen;
  end;
 end;
 
begin
 with fdim,fdrawinfo do begin
  minblen:= fbuttonminlength;
  areas[sbbu_up].ca.imagelist:= stockobjects.glyphs;
  areas[sbbu_down].ca.imagelist:= stockobjects.glyphs;
  if fdirection in [gd_right,gd_left] then begin
   width1:= cy;
  end
  else begin
   width1:= cx;
  end;
  quadblen:= width1;
  if fbuttonendlength < 0 then begin
   endblen:= 0;
  end
  else begin
   if fbuttonendlength = 0 then begin
    endblen:= width1;
   end
   else begin
    endblen:= fbuttonendlength;
   end;
  end;
  if fdirection in [gd_right,gd_left] then begin
   checkscrolllength(cx);
   scrollrect.x:= x + endblen;
   scrollrect.y:= y;
   scrollrect.cx:= scrolllength;
   scrollrect.cy:= width1;
   for bu1:= low(scrollbarareaty) to high(scrollbarareaty) do begin
    areas[bu1].ca.dim.y:= y;
    areas[bu1].ca.dim.cy:= width1;
   end;
   areas[sbbu_down].ca.dim.cx:= endblen;
   areas[sbbu_up].ca.dim.cx:= endblen;
   if fdirection = gd_right then begin
    areas[sbbu_up].ca.imagenr:= ord(stg_arrowrightsmall);
    areas[sbbu_down].ca.imagenr:= ord(stg_arrowleftsmall);
   end
   else begin
    areas[sbbu_down].ca.imagenr:= ord(stg_arrowrightsmall);
    areas[sbbu_up].ca.imagenr:= ord(stg_arrowleftsmall);
   end;
  end
  else begin
   checkscrolllength(cy);
   scrollrect.x:= x;
   scrollrect.y:= y + endblen;
   scrollrect.cx:= width1;
   scrollrect.cy:= scrolllength;
   for bu1:= low(scrollbarareaty) to high(scrollbarareaty) do begin
    areas[bu1].ca.dim.x:= x;
    areas[bu1].ca.dim.cx:= width1;
   end;
   areas[sbbu_down].ca.dim.cy:= endblen;
   areas[sbbu_up].ca.dim.cy:= endblen;
   if fdirection = gd_down then begin
    areas[sbbu_up].ca.imagenr:= ord(stg_arrowdownsmall);
    areas[sbbu_down].ca.imagenr:= ord(stg_arrowupsmall);
   end
   else begin
    areas[sbbu_down].ca.imagenr:= ord(stg_arrowdownsmall);
    areas[sbbu_up].ca.imagenr:= ord(stg_arrowupsmall);
   end;
  end;
  if fbuttonlength < 0 then begin
   buttonlength1:= quadblen;
  end
  else begin
   if fbuttonlength > 0 then begin
    buttonlength1:= fbuttonlength;
   end
   else begin
    buttonlength1:= round(pagesize * scrolllength);
   end;
  end;
  if buttonlength1 < minblen then begin
   buttonlength1:= minblen;
  end;
  if fdirection in [gd_right,gd_left] then begin
   areas[sbbu_move].ca.dim.cx:= buttonlength1;
  end
  else begin
   areas[sbbu_move].ca.dim.cy:= buttonlength1;
  end;
  fscrollrange:= scrolllength - buttonlength1;
  case fdirection of
   gd_right: begin
    areas[sbbu_down].ca.dim.x:= x;
    areas[sbbu_up].ca.dim.x:= x + cx - endblen;
    areas[sbbu_move].ca.dim.x:= x + endblen + round(fvalue * fscrollrange);
    areas[sba_start].ca.dim.x:= x + endblen;
    areas[sba_start].ca.dim.cx:= areas[sbbu_move].ca.dim.x - 
                                       areas[sba_start].ca.dim.x;
    areas[sba_end].ca.dim.x:= areas[sbbu_move].ca.dim.x +
                                       areas[sbbu_move].ca.dim.cx;
    areas[sba_end].ca.dim.cx:= areas[sbbu_up].ca.dim.x - areas[sba_end].ca.dim.x;
   end;
   gd_left: begin
    areas[sbbu_up].ca.dim.x:= x;
    areas[sbbu_down].ca.dim.x:= x + cx - endblen;
    areas[sbbu_move].ca.dim.x:= x + cx - (endblen + round(fvalue * fscrollrange)) - 
                          buttonlength1;
    areas[sba_start].ca.dim.x:= areas[sbbu_move].ca.dim.x + 
                                      areas[sbbu_move].ca.dim.cx;
    areas[sba_start].ca.dim.cx:= areas[sbbu_down].ca.dim.x -
                                      areas[sba_start].ca.dim.x;
    areas[sba_end].ca.dim.x:= x + endblen;
    areas[sba_end].ca.dim.cx:= areas[sbbu_move].ca.dim.x - 
                                      areas[sba_end].ca.dim.x;
   end;
   gd_down: begin
    areas[sbbu_down].ca.dim.y:= y;
    areas[sbbu_up].ca.dim.y:= y + cy - endblen;
    areas[sbbu_move].ca.dim.y:= y + endblen + round(fvalue * fscrollrange);
    areas[sba_start].ca.dim.y:= y + endblen;
    areas[sba_start].ca.dim.cy:= areas[sbbu_move].ca.dim.y - 
                                                 areas[sba_start].ca.dim.y;
    areas[sba_end].ca.dim.y:= areas[sbbu_move].ca.dim.y + 
                                                 areas[sbbu_move].ca.dim.cy;
    areas[sba_end].ca.dim.cy:= areas[sbbu_up].ca.dim.y - areas[sba_end].ca.dim.y;
   end;
   gd_up: begin
    areas[sbbu_up].ca.dim.y:= y;
    areas[sbbu_down].ca.dim.y:= y + cy - endblen;
    areas[sbbu_move].ca.dim.y:= y + cy - (endblen + round(fvalue * fscrollrange)) - 
                          buttonlength1;
    areas[sba_start].ca.dim.y:= areas[sbbu_move].ca.dim.y + 
                                             areas[sbbu_move].ca.dim.cy;
    areas[sba_start].ca.dim.cy:=  areas[sbbu_down].ca.dim.y - 
                                             areas[sba_start].ca.dim.y;
    areas[sba_end].ca.dim.y:= y + endblen;
    areas[sba_end].ca.dim.cy:= areas[sbbu_move].ca.dim.y - 
                                                    areas[sba_end].ca.dim.y;
   end;
  end;
  with areas[sbbu_down].ca do begin
   buttonareas[bbu_down]:= dim;
   if (fframeendbutton1 <> nil) then begin 
    deflaterect1(dim,fframeendbutton1.paintframe);
    if not (fso_noinnerrect in fframeendbutton1.optionsskin) then begin
     deflaterect1(dim,fframeendbutton1.framei);
    end;
   end;
  end;
  frameskinoptionstoshapestate(fframeendbutton1,areas[sbbu_down]);
  with areas[sbbu_move].ca do begin
   buttonareas[bbu_move]:= dim;
   if (fframebutton <> nil) then begin 
    deflaterect1(dim,fframebutton.paintframe);
    if not (fso_noinnerrect in fframebutton.optionsskin) then begin
     deflaterect1(dim,fframebutton.framei);
    end;
   end;
  end;
  frameskinoptionstoshapestate(fframebutton,areas[sbbu_move]);
  with areas[sbbu_up].ca do begin
   buttonareas[bbu_up]:= dim;
   if (fframeendbutton2 <> nil) then begin
    deflaterect1(dim,fframeendbutton2.paintframe);
    if not (fso_noinnerrect in fframeendbutton2.optionsskin) then begin
     deflaterect1(dim,fframeendbutton2.framei);
    end;
   end;
  end;
  frameskinoptionstoshapestate(fframeendbutton2,areas[sbbu_up]);
 end;
end;

function tcustomscrollbar.findarea(const point: pointty): scrollbarareaty;
var
 ar1: scrollbarareaty;
begin
 result:= scrollbarareaty(-1);
 for ar1:= low(scrollbarareaty) to high(scrollbarareaty) do begin
  if pointinshape(point,fdrawinfo.areas[ar1]) then begin
   result:= ar1;
   break;
  end;
 end;
end;

procedure tcustomscrollbar.invalidate;
begin
 updatedim;
 fintf.invalidaterect(fdim,forg);
end;

procedure tcustomscrollbar.invalidatepos;
begin
 updatedim;
 fintf.invalidaterect(fdrawinfo.scrollrect,forg);
end;

function tcustomscrollbar.clickedareaisvalid: boolean;
begin
 result:= (shortint(fclickedarea) >= 0) and
              (shortint(fclickedarea) < scrollbarclicked);
end;

procedure tcustomscrollbar.invalidateclickedarea;
begin
 if clickedareaisvalid then begin
  if fclickedarea <= sbbu_up then begin
   fintf.invalidaterect(fdrawinfo.buttonareas[buttonareaty(fclickedarea)],forg);  
  end
  else begin
   fintf.invalidaterect(fdrawinfo.areas[fclickedarea].ca.dim,forg);
  end;
 end;
end;

procedure tcustomscrollbar.setdim(const arect: rectty);
begin
 fdim:= arect;
 invalidate;
end;

procedure tcustomscrollbar.setbuttonlength(const avalue: integer);
begin
 if fbuttonlength <> avalue then begin
  fbuttonlength := avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.setbuttonendlength(const avalue: integer);
begin
 if avalue <> fbuttonendlength then begin
  fbuttonendlength := avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.setbuttonminlength(const avalue: integer);
begin
 if fbuttonminlength <> avalue then begin
  fbuttonminlength:= avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.setwidth(const avalue: integer);
begin
 if fwidth <> avalue then begin
  fwidth := avalue;
  dodimchanged;
 end;
end;

procedure tcustomscrollbar.setindentstart(const avalue: integer);
begin
 if findentstart <> avalue then begin
  findentstart := avalue;
  dodimchanged;
 end;
end;

procedure tcustomscrollbar.setindentend(const avalue: integer);
begin
 if findentend <> avalue then begin
  findentend := avalue;
  dodimchanged;
 end;
end;

procedure tcustomscrollbar.setdirection(const avalue: graphicdirectionty);
begin
 if fdirection <> avalue then begin
  fdirection := avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.setcolor(const avalue: colorty);
begin
 if fcolor <> avalue then begin
  fcolor := avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.setcolorglyph(const avalue: colorty);
begin
 if fdrawinfo.areas[sbbu_down].ca.colorglyph <> avalue then begin
  fdrawinfo.areas[sbbu_down].ca.colorglyph:= avalue;
  fdrawinfo.areas[sbbu_up].ca.colorglyph:= avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.setcolorpattern(const avalue: colorty);
begin
 if fcolorpattern <> avalue then begin
  fcolorpattern := avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.paint(const canvas: tcanvas; 
                                           const acolor: colorty = cl_none);
var
 col1: colorty;
 statebefore: shapestatesty;
begin
 with canvas,self.fdrawinfo do begin
  save;
  areas[sbbu_up].face:= ffaceendbutton;
  areas[sbbu_down].face:= ffaceendbutton;
  areas[sbbu_move].face:= ffacebutton;
  if acolor = cl_none then begin
   col1:= fcolor;
  end
  else begin
   col1:= acolor;
  end;
  col1:= fintf.translatecolor(col1);
  color:= col1;
  fpaintedbutton:= firstbutton;
  while fpaintedbutton <= lastbutton do begin
   case fpaintedbutton of
    sbbu_down: begin
     if fframeendbutton1 <> nil then begin
      fframeendbutton1.paintbackground(canvas,buttonareas[bbu_down],false);
     end;
    end;
    sbbu_move: begin
     if fframebutton <> nil then begin
      fframebutton.paintbackground(canvas,buttonareas[bbu_move],false);
     end;
    end;
    sbbu_up: begin
     if fframeendbutton2 <> nil then begin
      fframeendbutton2.paintbackground(canvas,buttonareas[bbu_up],false);
     end;
    end;
   end;    
   if acolor <> cl_none then begin
    with areas[fpaintedbutton] do begin
     statebefore:= state;
     state:= state - [shs_mouse,shs_clicked];     
    end; 
   end;
   drawtoolbutton(canvas,areas[fpaintedbutton]);
   if acolor <> cl_none then begin
    areas[fpaintedbutton].state:= statebefore;
   end;
   case fpaintedbutton of
    sbbu_down: begin
     if fframeendbutton1 <> nil then begin
      fframeendbutton1.paintoverlay(canvas,buttonareas[bbu_down]);
     end;
    end;
    sbbu_move: begin
     if fframebutton <> nil then begin
      fframebutton.paintoverlay(canvas,buttonareas[bbu_move]);
     end;
    end;
    sbbu_up: begin
     if fframeendbutton2 <> nil then begin
      fframeendbutton2.paintoverlay(canvas,buttonareas[bbu_up]);
     end;
    end;
   end;    
   inc(fpaintedbutton);
  end;
  if fcolorpattern <> cl_none then begin
   colorbackground:= col1;
   brush:= stockobjects.bitmaps[stb_dens50];
   if fclickedarea = sba_start then begin
    color:= cl_black;
   end
   else begin
    color:= fcolorpattern;
   end;
   fillrect(areas[sba_start].ca.dim,cl_brushcanvas);
   if fclickedarea = sba_end then begin
    color:= cl_black;
   end
   else begin
    color:= fcolorpattern;
   end;
   fillrect(areas[sba_end].ca.dim,cl_brushcanvas);
  end;
  restore;
 end;
end;

procedure tcustomscrollbar.setvalue(Value: real);
begin
 if value < 0 then begin
  value:= 0;
 end
 else begin
  if value > 1 then begin
   value:= 1;
  end;
 end;
 if fvalue <> value then begin
  fvalue := Value;
  invalidatepos;
  fintf.scrollevent(self,sbe_valuechanged);
 end;
end;

procedure tcustomscrollbar.setpagesize(avalue: real);
begin
 if avalue < 0 then begin
  avalue:= 0;
 end;
 if avalue > 1 then begin
  avalue:= 1;
 end;
 if fpagesize <> avalue then begin
  fpagesize:= avalue;
  invalidate;
 end;
end;

procedure tcustomscrollbar.dodimchanged;
begin
 if assigned(fondimchanged) then begin
  fondimchanged;
 end;
 invalidate;
end;

procedure tcustomscrollbar.setoptions(const avalue: scrollbaroptionsty);
var
 aoptions: scrollbaroptionsty;
const
 mask: scrollbaroptionsty = [sbo_showauto,sbo_show];
begin
 aoptions:= scrollbaroptionsty(setsinglebit(
        {$ifdef FPC}longword{$else}word{$endif}(avalue),
        {$ifdef FPC}longword{$else}word{$endif}(foptions),
         {$ifdef FPC}longword{$else}word{$endif}(mask)));
 if aoptions <> foptions then begin
  foptions:= aoptions;
  dodimchanged;
 end;
end;

function tcustomscrollbar.getstepsize: real;
begin
 if fstepsize = 0 then begin
  result:= fpagesize / 10;
 end
 else begin
  result:= fstepsize;
 end;
end;

function tcustomscrollbar.dobuttoncommand: boolean;
begin
 result:= true;
 case fclickedarea of
  sbbu_up: begin
   result:= dostepup(application.lastshiftstate*keyshiftstatesmask);
  end;
  sbbu_down: begin
   dostepdown(application.lastshiftstate*keyshiftstatesmask);
  end;
  sba_start: begin
   pagedown;
  end;
  sba_end: begin
   pageup;
  end;
  else begin
   result:= false;
  end;
 end;
end;

procedure tcustomscrollbar.thumbtrack(var pos: pointty);
var
 apos: integer;
begin
 if fscrollrange <> 0 then begin
  case fdirection of
   gd_right: apos:= pos.x + fpickoffset;
   gd_up: apos:= fpickoffset - pos.y;
   gd_left: apos:= fpickoffset - pos.x;
   else apos:= pos.y + fpickoffset; //gd_down
  end;
  value:= apos / fscrollrange;
 end;
end;

function tcustomscrollbar.wantmouseevent(const apos: pointty): boolean;
begin
 result:= (fclickedarea <> scrollbarareaty(-1)) or
                 (findarea(apos) <> scrollbarareaty(-1));
end;

procedure tcustomscrollbar.mouseevent(var info: mouseeventinfoty);

 procedure releasebutton(const cancel: boolean);
 begin
  if scs_mousecaptured in fstate then begin
   exclude(fstate,scs_mousecaptured);
   fintf.getwidget.releasemouse;
  end;
  freeandnil(frepeater);
  if clickedareaisvalid then begin
   exclude(fdrawinfo.areas[fclickedarea].state,shs_clicked);
   invalidateclickedarea;
  end;
  if (fclickedarea = sbbu_move) and not cancel then begin
   thumbtrack(info.pos);
   fintf.scrollevent(self,sbe_thumbposition);
   dothumbevent(sbe_thumbposition);
  end;
  fclickedarea:= scrollbarareaty(-1);
 end;

 procedure mousemove(ar1: scrollbarareaty);
 var
  ar2: scrollbarareaty;
 begin
  if ord(ar1) >= 0 then begin
   application.widgetcursorshape:= cr_arrow;
  end;
  if clickedareaisvalid then begin
   if (ar1 <> fclickedarea) and (fclickedarea <> sbbu_move) then begin
    releasebutton(false);
    fclickedarea:= scrollbarareaty(scrollbarclicked);
   end;
   if (fclickedarea = sbbu_move) then begin
    ar1:= scrollbarareaty(-1);
    if info.eventkind = ek_mousemove then begin
     thumbtrack(info.pos);
     if sbo_thumbtrack in foptions then begin
      fintf.scrollevent(self,sbe_thumbtrack);
      dothumbevent(sbe_thumbtrack);
     end;
    end;
    include(info.eventstate,es_processed);
   end;
  end;
  for ar2:= firstbutton to lastbutton do begin
   with fdrawinfo,areas[ar2] do begin
    if (ar2 = ar1) then begin
     if not (shs_mouse in state) then begin
      include(state,shs_mouse);
      fintf.invalidaterect(buttonareas[buttonareaty(ar2)],forg);
     end;
    end
    else begin
     if shs_mouse in state then begin
      exclude(state,shs_mouse);
      fintf.invalidaterect(buttonareas[buttonareaty(ar2)],forg);
     end;
    end;
   end;
  end;
 end;

var
 ar1: scrollbarareaty;
begin
 if info.eventkind in mouseposevents then begin
  ar1:= findarea(info.pos);
  if (ar1 = scrollbarareaty(-1)) and clickedareaisvalid then begin
   ar1:= scrollbarareaty(scrollbarclicked);
  end;
 end
 else begin
  ar1:= scrollbarareaty(-1);
 end;
 if ar1 <> scrollbarareaty(-1) then begin
  include(info.eventstate,es_processed);
 end;
 if (info.eventkind = ek_clientmouseleave) and (forg = org_client) or
    (info.eventkind = ek_mouseleave) and (forg = org_widget) then begin
  releasebutton(true);
  mousemove(scrollbarareaty(-1));
 end
 else begin
  case info.eventkind of
   ek_mousemove,ek_mousepark: begin
    mousemove(ar1);
    if fclickedarea = scrollbarareaty(-1) then begin
     exclude(info.eventstate,es_processed);
    end;
   end;
   ek_buttonpress: begin
    if (info.button = mb_left) and 
     (not(sbo_noreflectedclick in foptions) or 
                          not (es_reflected in info.eventstate)) then begin
     fclickedarea:= ar1;
     if clickedareaisvalid then begin
      include(fdrawinfo.areas[fclickedarea].state,shs_clicked);
      with fintf.getwidget do begin
       if not mousecaptured then begin
        capturemouse(true);
        include(fstate,scs_mousecaptured);
       end;
      end;
     end;
     invalidateclickedarea;
     if dobuttoncommand then begin
      frepeater:= tsimpletimer.create(repeatdelaytime,
                    {$ifdef FPC}@{$endif}timer,true,[to_single]);
     end
     else begin
      if fclickedarea = sbbu_move then begin
       fpickpos:= info.pos;
       with fdrawinfo.buttonareas[bbu_move] do begin
        case fdirection of
         gd_right: fpickoffset:= x - info.pos.x - 
                               fdrawinfo.areas[sba_start].ca.dim.x;
         gd_up: fpickoffset:= fdrawinfo.areas[sba_start].ca.dim.cy + info.pos.y;
         gd_left: fpickoffset:= fdrawinfo.areas[sba_start].ca.dim.cx + 
                                                         info.pos.x;
         gd_down: fpickoffset:= y - info.pos.y - 
                                        fdrawinfo.areas[sba_start].ca.dim.y;
        end;
       end;
      end;
     end;
    end;
   end;
   ek_buttonrelease: begin
    if info.button = mb_left then begin
     releasebutton(false);
    end;
   end;
  end;
 end;
end;

procedure tcustomscrollbar.mousewheelevent(var info: mousewheeleventinfoty;
                                       const pagingreversed: boolean = false); 
begin
 with info do begin
  include(eventstate,es_processed);
  if (wheel = mw_down) xor (fdirection in [gd_left,gd_down]) then begin
   if (fstepctrlfact <> 0) or (fstepshiftfact <> 0) then begin
    wheeldown(shiftstate);
   end
   else begin
    if (ss_ctrl in shiftstate) xor pagingreversed then begin
     pagedown;
    end
    else begin
     wheeldown;
    end;
   end;
  end
  else begin
   if (fstepctrlfact <> 0) or (fstepshiftfact <> 0) then begin
    wheelup(shiftstate);
   end
   else begin
    if (ss_ctrl in shiftstate) xor pagingreversed then begin
     pageup;
    end
    else begin
     wheelup;
    end;
   end;
  end;
 end;
end;

function tcustomscrollbar.getshiftfact(ashiftstate: shiftstatesty;
                             out fact: real): boolean;
                             //false if not valid
begin
 fact:= 1;
 ashiftstate:= ashiftstate * shiftstatesmask;
 result:= ashiftstate = [];
 if not result then begin
  if (ashiftstate = [ss_ctrl]) and (fstepctrlfact <> 0) then begin
   fact:= fstepctrlfact;
   result:= true;
  end
  else begin
   if (ashiftstate = [ss_shift]) and (fstepshiftfact <> 0) then begin
    fact:= fstepshiftfact;
    result:= true;
   end
  end;
 end;
end;

function tcustomscrollbar.dostepup(const ashiftstate: shiftstatesty): boolean;
var
 fact1: real;
begin
 result:= getshiftfact(ashiftstate,fact1);
 if result then begin
  dostep(sbe_stepup,stepsize*fact1);
 end;  
end; //dostepup

function tcustomscrollbar.dostepdown(const ashiftstate: shiftstatesty): boolean;
var
 fact1: real;
begin
 result:= getshiftfact(ashiftstate,fact1);
 if result then begin
  dostep(sbe_stepdown,-stepsize*fact1);
 end;  
end;
  
procedure tcustomscrollbar.keydown(var info: keyeventinfoty);

 procedure dopageup;
 begin
  if info.shiftstate * shiftstatesmask = [ss_ctrl] then begin
   value:= 1;
  end
  else begin
   pageup;
  end;
 end; //dopageup
 
 procedure dopagedown;
 begin
  if info.shiftstate * shiftstatesmask = [ss_ctrl] then begin
   value:= 0;
  end
  else begin
   pagedown;
  end;
 end; //dopagedown

var
 bo1: boolean;

begin
 with info do begin
  if not (es_processed in eventstate) then begin
   if (not (sbo_noarrowkeys in foptions) or 
        (key <> key_left) and (key <> key_right) and
        (key <> key_up) and (key <> key_down)) and
      (not (sbo_nopagekeys in foptions) or
        (key <> key_pageup) and (key <> key_pagedown)) then begin
    bo1:= true;
    if sbo_valuekeys in foptions then begin
     case info.key of
      key_pageup: dopageup;
      key_pagedown: dopagedown;
      key_up: bo1:= dostepup(info.shiftstate);
      key_down: bo1:= dostepdown(info.shiftstate);
      else begin
       bo1:= false;
      end;
     end; 
    end
    else begin
     case fdirection of
      gd_right: begin
       case info.key of
        key_right: bo1:= dostepup(info.shiftstate);
        key_left: bo1:= dostepdown(info.shiftstate);
        key_pageup: dopageup;
        key_pagedown: dopagedown;
        else begin
         bo1:= false;
        end;
       end;
      end;
      gd_up: begin
       case info.key of
        key_up: bo1:= dostepdown(info.shiftstate);
        key_down: bo1:= dostepup(info.shiftstate);
        key_pageup: dopageup;
        key_pagedown: dopagedown;
        else begin
         bo1:= false;
        end;
       end;
      end;
      gd_left: begin
       case info.key of
        key_right: bo1:= dostepdown(info.shiftstate);
        key_left: bo1:= dostepup(info.shiftstate);
        key_pageup: dopageup;
        key_pagedown: dopagedown;
        else begin
         bo1:= false;
        end;
       end;
      end;
      gd_down: begin
       case info.key of
        key_down: bo1:= dostepup(info.shiftstate);
        key_up: bo1:= dostepdown(info.shiftstate);
        key_pageup: dopagedown;
        key_pagedown: dopageup;
        else begin
         bo1:= false;
        end;
       end;
      end;
     end;
    end;
    if bo1 then begin
     include(eventstate,es_processed);
    end;
   end;
  end;
 end;
end;

procedure tcustomscrollbar.dostep(akind: scrolleventty; astep: real);
begin
 if assigned(fonbeforeevent) then begin
  fonbeforeevent(self,akind,astep);
 end;
 if akind <> sbe_none then begin
  if sbo_moveauto in foptions then begin
   value:= fvalue + astep;
  end;
  fintf.scrollevent(self,akind);
  if assigned(fonafterevent) then begin
   fonafterevent(self,akind,astep);
  end;
 end;
end;

procedure tcustomscrollbar.dothumbevent(const aevent: scrolleventty);
begin
 if assigned(fonafterevent) then begin
  fonafterevent(self,aevent,value);
 end;
end;

procedure tcustomscrollbar.pagedown;
begin
 dostep(sbe_pagedown,-pagesize);
end;

procedure tcustomscrollbar.pageup;
begin
 dostep(sbe_pageup,pagesize);
end;

procedure tcustomscrollbar.wheeldown(const shiftstate: shiftstatesty = []);
var
 fact1: real;
begin
 getshiftfact(shiftstate,fact1);
 dostep(sbe_wheeldown,
            -application.mousewheelacceleration(stepsize)*
                                        fwheelsensitivity*fact1);
end;

procedure tcustomscrollbar.wheelup(const shiftstate: shiftstatesty = []);
var
 fact1: real;
begin
 getshiftfact(shiftstate,fact1);
 dostep(sbe_wheelup,
             application.mousewheelacceleration(stepsize)*
                                        fwheelsensitivity*fact1);
end;

procedure tcustomscrollbar.stepdown;
begin
 dostep(sbe_stepdown,-stepsize);
end;

procedure tcustomscrollbar.stepup;
begin
 dostep(sbe_stepup,stepsize);
end;

destructor tcustomscrollbar.destroy;
begin
 freeandnil(frepeater);
 inherited;
 ffacebutton.free;
 ffaceendbutton.free;
 fframebutton.free;
 fframeendbutton1.free;
 fframeendbutton2.free;
end;

procedure tcustomscrollbar.timer(const sender: tobject);
begin
 dobuttoncommand;
 with tsimpletimer(sender) do begin
  if singleshot then begin
   singleshot:= false;
   interval:= repeatrepeattime;
   enabled:= true;
  end;
 end;
end;

procedure tcustomscrollbar.enter;
begin
 with fdrawinfo,areas[sbbu_move] do begin
  include(state,shs_focused);
  fintf.invalidaterect(buttonareas[bbu_move],forg);
 end;
end;

procedure tcustomscrollbar.exit;
begin
 with fdrawinfo,areas[sbbu_move] do begin
  exclude(fdrawinfo.areas[sbbu_move].state,shs_focused);
  fintf.invalidaterect(buttonareas[bbu_move],forg);
 end;
end;

procedure tcustomscrollbar.createfacebutton;
begin
 if ffacebutton = nil then begin
  ffacebutton:= tface.create(iface(fintf.getwidget));
 end;
end;

function tcustomscrollbar.getfacebutton: tface;
begin
 fintf.getwidget.getoptionalobject(ffacebutton,
                               {$ifdef FPC}@{$endif}createfacebutton);
 result:= ffacebutton;
end;

procedure tcustomscrollbar.setfacebutton(const avalue: tface);
begin
 fintf.getwidget.setoptionalobject(avalue,ffacebutton,
                               {$ifdef FPC}@{$endif}createfacebutton);
 invalidate;
end;

procedure tcustomscrollbar.createfaceendbutton;
begin
 if ffaceendbutton = nil then begin
  ffaceendbutton:= tface.create(iface(fintf.getwidget));
 end;
end;

function tcustomscrollbar.getfaceendbutton: tface;
begin
 fintf.getwidget.getoptionalobject(ffaceendbutton,
                               {$ifdef FPC}@{$endif}createfaceendbutton);
 result:= ffaceendbutton;
end;

procedure tcustomscrollbar.setfaceendbutton(const avalue: tface);
begin
 fintf.getwidget.setoptionalobject(avalue,ffaceendbutton,
                               {$ifdef FPC}@{$endif}createfaceendbutton);
 invalidate;
end;

procedure tcustomscrollbar.createframebutton;
begin
 if fframebutton = nil then begin
  fframebutton:= tframe.create(iframe(self));
 end;
end;

function tcustomscrollbar.getframebutton: tframe;
begin
 fintf.getwidget.getoptionalobject(fframebutton,
                               {$ifdef FPC}@{$endif}createframebutton);
 result:= fframebutton;
end;

procedure tcustomscrollbar.setframebutton(const avalue: tframe);
begin
 fintf.getwidget.setoptionalobject(avalue,fframebutton,
                               {$ifdef FPC}@{$endif}createframebutton);
 invalidate;
end;

procedure tcustomscrollbar.createframeendbutton1;
begin
 if fframeendbutton1 = nil then begin
  fframeendbutton1:= tframe.create(iframe(self));
 end;
end;

function tcustomscrollbar.getframeendbutton1: tframe;
begin
 fintf.getwidget.getoptionalobject(fframeendbutton1,
                               {$ifdef FPC}@{$endif}createframeendbutton1);
 result:= fframeendbutton1;
end;

procedure tcustomscrollbar.setframeendbutton1(const avalue: tframe);
begin
 fintf.getwidget.setoptionalobject(avalue,fframeendbutton1,
                               {$ifdef FPC}@{$endif}createframeendbutton1);
 invalidate;
end;

procedure tcustomscrollbar.createframeendbutton2;
begin
 if fframeendbutton2 = nil then begin
  fframeendbutton2:= tframe.create(iframe(self));
 end;
end;

function tcustomscrollbar.getframeendbutton2: tframe;
begin
 fintf.getwidget.getoptionalobject(fframeendbutton2,
                               {$ifdef FPC}@{$endif}createframeendbutton2);
 result:= fframeendbutton2;
end;

procedure tcustomscrollbar.setframeendbutton2(const avalue: tframe);
begin
 fintf.getwidget.setoptionalobject(avalue,fframeendbutton2,
                               {$ifdef FPC}@{$endif}createframeendbutton2);
 invalidate;
end;

function tcustomscrollbar.clicked: boolean;
begin
 result:= fclickedarea <> scrollbarareaty(-1);
end;

procedure tcustomscrollbar.checktemplate(const sender: tobject);
begin
 if ffacebutton <> nil then begin
  ffacebutton.checktemplate(sender);
 end;
 if ffaceendbutton <> nil then begin
  ffaceendbutton.checktemplate(sender);
 end;
 if fframebutton <> nil then begin
  fframebutton.checktemplate(sender);
 end;
 if fframeendbutton1 <> nil then begin
  fframeendbutton1.checktemplate(sender);
 end;
 if fframeendbutton2 <> nil then begin
  fframeendbutton2.checktemplate(sender);
 end;
end;

procedure tcustomscrollbar.setframeinstance(instance: tcustomframe);
begin
 //dummy
end;

procedure tcustomscrollbar.setstaticframe(value: boolean);
begin
 //dummy
end;

function tcustomscrollbar.getstaticframe: boolean;
begin
 result:= false;
end;

procedure tcustomscrollbar.scrollwidgets(const dist: pointty);
begin
 //dumy
end;

procedure tcustomscrollbar.clientrectchanged;
begin
 invalidate;
end;

function tcustomscrollbar.getcomponentstate: tcomponentstate;
begin
 result:= fintf.getwidget.componentstate;
end;

function tcustomscrollbar.getmsecomponentstate: msecomponentstatesty;
begin
 result:= fintf.getwidget.msecomponentstate;
end;

procedure tcustomscrollbar.invalidatewidget;
begin
 invalidate;
end;

procedure tcustomscrollbar.invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
begin
 invalidate;
end;

function tcustomscrollbar.getwidget: twidget;
begin
 result:= fintf.getwidget;
end;

function tcustomscrollbar.getwidgetrect: rectty;
begin
 result:= fdim;
end;

function tcustomscrollbar.getframestateflags: framestateflagsty;
begin
 with fdrawinfo.areas[fpaintedbutton],fintf.getwidget do begin
  result:= combineframestateflags(not isenabled,active,
       shs_mouse in state, shs_clicked in state); 
 end;
end;

procedure tcustomscrollbar.activechanged;
begin
 if (fframeendbutton1 <> nil) or (fframebutton <> nil) or 
                 (fframeendbutton2 <> nil) then begin
  invalidate;
 end;
end;

procedure tcustomscrollbar.readstepsize(reader: treader);
begin
 stepsize:= reader.readfloat;
end;

procedure tcustomscrollbar.writestepsize(writer: twriter);
begin
 writer.writefloat(stepsize);
end;

procedure tcustomscrollbar.readstepctrlfact(reader: treader);
begin
 stepctrlfact:= reader.readfloat;
end;

procedure tcustomscrollbar.writestepctrlfact(writer: twriter);
begin
 writer.writefloat(stepctrlfact);
end;

procedure tcustomscrollbar.readstepshiftfact(reader: treader);
begin
 stepshiftfact:= reader.readfloat;
end;

procedure tcustomscrollbar.writestepshiftfact(writer: twriter);
begin
 writer.writefloat(stepshiftfact);
end;

procedure tcustomscrollbar.readpagesize(reader: treader);
begin
 pagesize:= reader.readfloat;
end;

procedure tcustomscrollbar.writepagesize(writer: twriter);
begin
 writer.writefloat(pagesize);
end;

procedure tcustomscrollbar.readwheelsensitivity(reader: treader);
begin
 wheelsensitivity:= reader.readfloat;
end;

procedure tcustomscrollbar.writewheelsensitivity(writer: twriter);
begin
 writer.writefloat(wheelsensitivity);
end;

procedure tcustomscrollbar.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('stepsize',@readstepsize,@writestepsize,
                      (scs_streampagesize in fstate) and 
                      ((filer.ancestor = nil) and (fstepsize <> 0) or
                                              (filer.ancestor <> nil) and 
      (tcustomscrollbar(filer.ancestor).fstepsize <> fstepsize)));
 filer.defineproperty('stepctrlfact',@readstepctrlfact,@writestepctrlfact,
                      (filer.ancestor = nil) and (fstepctrlfact <> 0) or
   (filer.ancestor <> nil) and 
      (tcustomscrollbar(filer.ancestor).fstepctrlfact <> fstepctrlfact));
 filer.defineproperty('stepshiftfact',@readstepshiftfact,@writestepshiftfact,
                      (filer.ancestor = nil) and (fstepshiftfact <> 0) or
   (filer.ancestor <> nil) and 
      (tcustomscrollbar(filer.ancestor).fstepshiftfact <> fstepshiftfact));
 filer.defineproperty('pagesize',@readpagesize,@writepagesize,
                      (scs_streampagesize in fstate) and 
                  ((filer.ancestor = nil) and (fpagesize <> defaultpagesize) or
       (filer.ancestor <> nil) and 
      (tcustomscrollbar(filer.ancestor).fpagesize <> fpagesize)));
 filer.defineproperty('wheelsensitivity',@readwheelsensitivity,@writewheelsensitivity,
                      (filer.ancestor = nil) and (fwheelsensitivity <> 1) or
   (filer.ancestor <> nil) and 
      (tcustomscrollbar(filer.ancestor).fwheelsensitivity <> fwheelsensitivity));
end;

{ tcustomnomoveautoscrollbar }

constructor tcustomnomoveautoscrollbar.create(intf: iscrollbar;
  org: originty; ondimchanged: proceventty);
begin
 inherited;
 foptions:= defaultscrollbaroptions-[sbo_moveauto];
end;

procedure tcustomnomoveautoscrollbar.setoptions(
  const avalue: scrollbaroptionsty);
begin
 inherited setoptions(avalue - [sbo_moveauto]);
end;

{ tscrollbar }

constructor tscrollbar.create(intf: iscrollbar; org: originty = org_client;
               ondimchanged: proceventty = nil);
begin
 inherited;
 include(fstate,scs_streampagesize);
end;

{ tnomoveautoscrollbar }

constructor tnomoveautoscrollbar.create(intf: iscrollbar;
               org: originty = org_client; ondimchanged: proceventty = nil);
begin
 inherited;
 include(fstate,scs_streampagesize);
end;

end.
