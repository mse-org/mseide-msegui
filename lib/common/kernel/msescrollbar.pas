{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msescrollbar;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 mseguiglob,msegraphics,msegraphutils,msetimer,mseevent,mseshapes,classes,
 msetypes,msegui,mseclasses;

const
 defaultscrollbarwidth = 15;
 defaultpagesizeconst = 0.1;
 defaultpagesize: real = defaultpagesizeconst;
 defaultbuttonminlength = 8;
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
                      sbo_noreflectedclick,
                      sbo_flat,sbo_noanim);
                       //sbo_valuekeys -> pageup = valueincrement
 scrollbaroptionsty = set of scrollbaroptionty;

const
 firstbutton = sbbu_down;
 lastbutton = sbbu_up;
 defaultscrollbaroptions = [sbo_moveauto,sbo_showauto];

type
 tcustomscrollbar = class;

 scrolleventty =  (sbe_valuechanged,sbe_stepup,sbe_stepdown,sbe_pageup,sbe_pagedown,
                       sbe_thumbposition,sbe_thumbtrack);

 iscrollbar = interface
  function getwidget: twidget;
  function translatecolor(const acolor: colorty): colorty;
  procedure invalidaterect(const rect: rectty; org: originty);
  procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty);
 end;

 scrollbardrawinfoty = record
  scrollrect: rectty;
  buttonareas: array[buttonareaty] of rectty;
  areas: array[scrollbarareaty] of shapeinfoty;
 end;

 scrollbarstatety = (scs_mousecaptured);
 scrollbarstatesty = set of scrollbarstatety;

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
   fondimchanged: objectprocty;
   fbuttonendlength: integer;
   fstate: scrollbarstatesty;
   fpaintedbutton: scrollbarareaty;
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
   function isstepsizestored: Boolean;
   function ispagesizestored: Boolean;
   procedure dodimchanged;
   function clickedareaisvalid: boolean;
   procedure setcolorpattern(const avalue: colorty);
   function getfacebutton: tface;
   procedure setfacebutton(const avalue: tface);
   function getfaceendbutton: tface;
   procedure setfaceendbutton(const avalue: tface);
   procedure createfacebutton;
   procedure createfaceendbutton;
   procedure setbuttonendlength(const avalue: integer);
   procedure createframebutton;
   function getframebutton: tframe;
   procedure setframebutton(const avalue: tframe);
   procedure createframeendbutton1;
   function getframeendbutton1: tframe;
   procedure setframeendbutton1(const avalue: tframe);
   procedure createframeendbutton2;
   function getframeendbutton2: tframe;
   procedure setframeendbutton2(const avalue: tframe);
   //iframe
  procedure setframeinstance(instance: tcustomframe);
  procedure setstaticframe(value: boolean);
  procedure scrollwidgets(const dist: pointty);
  procedure clientrectchanged;
  function getcomponentstate: tcomponentstate;
  procedure invalidatewidget;
  procedure invalidaterect(const rect: rectty; org: originty = org_client);
  function getwidget: twidget;
  function getwidgetrect: rectty;
  function getframeclicked: boolean;
  function getframemouse: boolean;
  function getframeactive: boolean;
  protected
   fintf: iscrollbar;
   foptions: scrollbaroptionsty;
   fdrawinfo: scrollbardrawinfoty;
   findentstart,findentend: integer;
   procedure setoptions(const avalue: scrollbaroptionsty); virtual;
   procedure invalidate;
  public
   tag: integer;
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: objectprocty = nil); reintroduce; virtual;
   destructor destroy; override;
   procedure checktemplate(const sender: tobject);
   procedure paint(const canvas: tcanvas; const acolor: colorty = cl_none); virtual;
                       //color <> cl_none -> flat paint for grid cell
   function wantmouseevent(const apos: pointty): boolean;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure keydown(var info: keyeventinfoty);
   procedure enter;
   procedure exit;
   function clicked: boolean;
   procedure activechanged;

   procedure stepup;
   procedure stepdown;
   procedure pageup;
   procedure pagedown;

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
   property stepsize: real read getstepsize write fstepsize stored isstepsizestored;
                    //default = 0 -> pagesize /10
   property pagesize: real read fpagesize write setpagesize stored ispagesizestored;
                    //default = defaultpagesize
   property buttonlength: integer read fbuttonlength write setbuttonlength default 0;
                     //0 -> proportional -1 -> quadratic
   property buttonminlength: integer read fbuttonminlength
                 write setbuttonminlength default defaultbuttonminlength;
   property buttonendlength: integer read fbuttonendlength 
                         write setbuttonendlength default 0;
                     //0 -> quadratic, -1 -> no endbuttons
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
   property colorglyph: colorty read fdrawinfo.areas[sbbu_down].colorglyph
                   write setcolorglyph default cl_glyph;
                   //cl_none -> no no glyph
 end;

 tcustomnomoveautoscrollbar = class(tcustomscrollbar)
  protected
   procedure setoptions(const avalue: scrollbaroptionsty); override;
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: objectprocty = nil); override;
   property options default defaultscrollbaroptions-[sbo_moveauto];
 end;


 tscrollbar = class(tcustomscrollbar)
  published
   property options;
   property width;
   property indentstart;
   property indentend;
   property stepsize;
   property pagesize;
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
 end;

implementation

uses
 msestockobjects,sysutils,msekeyboard,msebits,msepointer,mseact;

{ tcustomscrollbar }

constructor tcustomscrollbar.create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: objectprocty = nil);
var
 bu1: scrollbarareaty;
begin
 foptions:= defaultscrollbaroptions;
 fintf:= intf;
 forg:= org;
 fcolor:= cl_default;
 fcolorpattern:= cl_white;
 fdrawinfo.areas[sbbu_down].colorglyph:= cl_glyph;
 fdrawinfo.areas[sbbu_up].colorglyph:= cl_glyph;
 fclickedarea:= scrollbarareaty(-1);
 fbuttonminlength:= defaultbuttonminlength;
 fwidth:= defaultscrollbarwidth;
 fondimchanged:= ondimchanged;
 fpagesize:= defaultpagesize;
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
  areas[sbbu_up].imagelist:= stockobjects.glyphs;
  areas[sbbu_down].imagelist:= stockobjects.glyphs;
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
    areas[bu1].dim.y:= y;
    areas[bu1].dim.cy:= width1;
   end;
   areas[sbbu_down].dim.cx:= endblen;
   areas[sbbu_up].dim.cx:= endblen;
   if fdirection = gd_right then begin
    areas[sbbu_up].imagenr:= ord(stg_arrowrightsmall);
    areas[sbbu_down].imagenr:= ord(stg_arrowleftsmall);
   end
   else begin
    areas[sbbu_down].imagenr:= ord(stg_arrowrightsmall);
    areas[sbbu_up].imagenr:= ord(stg_arrowleftsmall);
   end;
  end
  else begin
   checkscrolllength(cy);
   scrollrect.x:= x;
   scrollrect.y:= y + endblen;
   scrollrect.cx:= width1;
   scrollrect.cy:= scrolllength;
   for bu1:= low(scrollbarareaty) to high(scrollbarareaty) do begin
    areas[bu1].dim.x:= x;
    areas[bu1].dim.cx:= width1;
   end;
   areas[sbbu_down].dim.cy:= endblen;
   areas[sbbu_up].dim.cy:= endblen;
   if fdirection = gd_down then begin
    areas[sbbu_up].imagenr:= ord(stg_arrowdownsmall);
    areas[sbbu_down].imagenr:= ord(stg_arrowupsmall);
   end
   else begin
    areas[sbbu_down].imagenr:= ord(stg_arrowdownsmall);
    areas[sbbu_up].imagenr:= ord(stg_arrowupsmall);
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
   areas[sbbu_move].dim.cx:= buttonlength1;
  end
  else begin
   areas[sbbu_move].dim.cy:= buttonlength1;
  end;
  fscrollrange:= scrolllength - buttonlength1;
  case fdirection of
   gd_right: begin
    areas[sbbu_down].dim.x:= x;
    areas[sbbu_up].dim.x:= x + cx - endblen;
    areas[sbbu_move].dim.x:= x + endblen + round(fvalue * fscrollrange);
    areas[sba_start].dim.x:= x + endblen;
    areas[sba_start].dim.cx:= areas[sbbu_move].dim.x - areas[sba_start].dim.x;
    areas[sba_end].dim.x:= areas[sbbu_move].dim.x + areas[sbbu_move].dim.cx;
    areas[sba_end].dim.cx:= areas[sbbu_up].dim.x - areas[sba_end].dim.x;
   end;
   gd_left: begin
    areas[sbbu_up].dim.x:= x;
    areas[sbbu_down].dim.x:= x + cx - endblen;
    areas[sbbu_move].dim.x:= x + cx - (endblen + round(fvalue * fscrollrange)) - 
                          buttonlength1;
    areas[sba_start].dim.x:= areas[sbbu_move].dim.x + areas[sbbu_move].dim.cx;
    areas[sba_start].dim.cx:= areas[sbbu_down].dim.x - areas[sba_start].dim.x;
    areas[sba_end].dim.x:= x + endblen;
    areas[sba_end].dim.cx:= areas[sbbu_move].dim.x - areas[sba_end].dim.x;
   end;
   gd_down: begin
    areas[sbbu_down].dim.y:= y;
    areas[sbbu_up].dim.y:= y + cy - endblen;
    areas[sbbu_move].dim.y:= y + endblen + round(fvalue * fscrollrange);
    areas[sba_start].dim.y:= y + endblen;
    areas[sba_start].dim.cy:= areas[sbbu_move].dim.y - areas[sba_start].dim.y;
    areas[sba_end].dim.y:= areas[sbbu_move].dim.y + areas[sbbu_move].dim.cy;
    areas[sba_end].dim.cy:= areas[sbbu_up].dim.y - areas[sba_end].dim.y;
   end;
   gd_up: begin
    areas[sbbu_up].dim.y:= y;
    areas[sbbu_down].dim.y:= y + cy - endblen;
    areas[sbbu_move].dim.y:= y + cy - (endblen + round(fvalue * fscrollrange)) - 
                          buttonlength1;
    areas[sba_start].dim.y:= areas[sbbu_move].dim.y + areas[sbbu_move].dim.cy;
    areas[sba_start].dim.cy:=  areas[sbbu_down].dim.y - areas[sba_start].dim.y;
    areas[sba_end].dim.y:= y + endblen;
    areas[sba_end].dim.cy:= areas[sbbu_move].dim.y - areas[sba_end].dim.y;
   end;
  end;
  buttonareas[bbu_down]:= areas[sbbu_down].dim;
  if fframeendbutton1 <> nil then begin
   deflaterect1(areas[sbbu_down].dim,fframeendbutton1.innerframe);
  end;
  buttonareas[bbu_move]:= areas[sbbu_move].dim;
  if fframebutton <> nil then begin
   deflaterect1(areas[sbbu_move].dim,fframebutton.innerframe);
  end;
  buttonareas[bbu_up]:= areas[sbbu_up].dim;
  if fframeendbutton2 <> nil then begin
   deflaterect1(areas[sbbu_up].dim,fframeendbutton2.innerframe);
  end;
  for bu1:= firstbutton to lastbutton do begin
   updatebit(longword(areas[bu1].state),ord(ss_flat),sbo_flat in foptions);
   updatebit(longword(areas[bu1].state),ord(ss_noanimation),sbo_noanim in foptions);
  end;
 end;
end;

function tcustomscrollbar.findarea(const point: pointty): scrollbarareaty;
var
 ar1: scrollbarareaty;
begin
 result:= scrollbarareaty(-1);
 for ar1:= low(scrollbarareaty) to high(scrollbarareaty) do begin
  if pointinrect(point,fdrawinfo.areas[ar1].dim) then begin
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
   fintf.invalidaterect(fdrawinfo.areas[fclickedarea].dim,forg);
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
 if fdrawinfo.areas[sbbu_down].colorglyph <> avalue then begin
  fdrawinfo.areas[sbbu_down].colorglyph:= avalue;
  fdrawinfo.areas[sbbu_up].colorglyph:= avalue;
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
{
procedure tcustomscrollbar.excludeopaque(const canvas: tcanvas);
begin
 canvas.subcliprect(fdrawinfo.scrollrect); //!!!!todo transparent colors
end;
}
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
      canvas.save;
      fframeendbutton1.paintbackground(canvas,buttonareas[bbu_down]);
      canvas.restore;
     end;
    end;
    sbbu_move: begin
     if fframebutton <> nil then begin
      canvas.save;
      fframebutton.paintbackground(canvas,buttonareas[bbu_move]);
      canvas.restore;
     end;
    end;
    sbbu_up: begin
     if fframeendbutton2 <> nil then begin
      canvas.save;
      fframeendbutton2.paintbackground(canvas,buttonareas[bbu_up]);
      canvas.restore;
     end;
    end;
   end;    
   if acolor <> cl_none then begin
    with areas[fpaintedbutton] do begin
     statebefore:= state;
     state:= state - [ss_mouse,ss_clicked];     
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
   fillrect(areas[sba_start].dim,cl_brushcanvas);
   if fclickedarea = sba_end then begin
    color:= cl_black;
   end
   else begin
    color:= fcolorpattern;
   end;
   fillrect(areas[sba_end].dim,cl_brushcanvas);
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
        {$ifdef FPC}longword{$else}byte{$endif}(avalue),
        {$ifdef FPC}longword{$else}byte{$endif}(foptions),
         {$ifdef FPC}longword{$else}byte{$endif}(mask)));
 if aoptions <> foptions then begin
  foptions:= aoptions;
  dodimchanged;
 end;
end;

function tcustomscrollbar.ispagesizestored: Boolean;
begin
 result:= fpagesize <> defaultpagesize;
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

function tcustomscrollbar.isstepsizestored: Boolean;
begin
 result:= fstepsize <> 0;
end;

function tcustomscrollbar.dobuttoncommand: boolean;
begin
 result:= true;
 case fclickedarea of
  sbbu_up: begin
   stepup;
  end;
  sbbu_down: begin
   stepdown;
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

 procedure releasebutton;
 begin
  if scs_mousecaptured in fstate then begin
   exclude(fstate,scs_mousecaptured);
   fintf.getwidget.releasemouse;
  end;
  freeandnil(frepeater);
  if clickedareaisvalid then begin
   exclude(fdrawinfo.areas[fclickedarea].state,ss_clicked);
   invalidateclickedarea;
  end;
  if fclickedarea = sbbu_move then begin
   thumbtrack(info.pos);
   fintf.scrollevent(self,sbe_thumbposition);
  end;
  fclickedarea:= scrollbarareaty(-1);
 end;

 procedure mousemove(ar1: scrollbarareaty);
 var
  ar2: scrollbarareaty;
 begin
  application.cursorshape:= cr_arrow;
  if clickedareaisvalid then begin
   if (ar1 <> fclickedarea) and (fclickedarea <> sbbu_move) then begin
    releasebutton;
    fclickedarea:= scrollbarareaty(scrollbarclicked);
   end;
   if (fclickedarea = sbbu_move) then begin
    ar1:= scrollbarareaty(-1);
    if info.eventkind = ek_mousemove then begin
     thumbtrack(info.pos);
     if sbo_thumbtrack in foptions then begin
      fintf.scrollevent(self,sbe_thumbtrack);
     end;
    end;
    include(info.eventstate,es_processed);
   end;
  end;
  for ar2:= firstbutton to lastbutton do begin
   with fdrawinfo,areas[ar2] do begin
    if (ar2 = ar1) then begin
     if not (ss_mouse in state) then begin
      include(state,ss_mouse);
      fintf.invalidaterect(buttonareas[buttonareaty(ar2)],forg);
     end;
    end
    else begin
     if ss_mouse in state then begin
      exclude(state,ss_mouse);
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
      include(fdrawinfo.areas[fclickedarea].state,ss_clicked);
      with fintf.getwidget do begin
       if not mousecaptured then begin
        capturemouse(true);
        include(fstate,scs_mousecaptured);
       end;
      end;
     end;
     invalidateclickedarea;
     if dobuttoncommand then begin
      frepeater:= tsimpletimer.create(-repeatdelaytime,
                    {$ifdef FPC}@{$endif}timer,true);
     end
     else begin
      if fclickedarea = sbbu_move then begin
       fpickpos:= info.pos;
       with fdrawinfo.buttonareas[bbu_move] do begin
        case fdirection of
         gd_right: fpickoffset:= x - info.pos.x - fdrawinfo.areas[sba_start].dim.x;
         gd_up: fpickoffset:= fdrawinfo.areas[sba_start].dim.cy + info.pos.y;
         gd_left: fpickoffset:= fdrawinfo.areas[sba_start].dim.cx + info.pos.x;
         gd_down: fpickoffset:= y - info.pos.y - fdrawinfo.areas[sba_start].dim.y;
{        
         gd_right: fpickoffset:= x - info.pos.x - fdrawinfo.areas[sba_start].dim.x;
         gd_up: fpickoffset:= fdrawinfo.areas[sba_start].dim.cy + info.pos.y;
         gd_left: fpickoffset:= fdrawinfo.areas[sba_start].dim.cx + info.pos.x;
         gd_down: fpickoffset:= y - info.pos.y - fdrawinfo.areas[sba_start].dim.y;
}
        end;
       end;
      end;
     end;
    end;
   end;
   ek_buttonrelease: begin
    if info.button = mb_left then begin
     releasebutton;
    end;
   end;
  end;
 end;
end;

procedure tcustomscrollbar.keydown(var info: keyeventinfoty);
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
      key_pageup: pageup;
      key_pagedown: pagedown;
      key_up: stepup;
      key_down: stepdown;
      else begin
       bo1:= false;
      end;
     end; 
    end
    else begin
     case fdirection of
      gd_right: begin
       case info.key of
        key_right: stepup;
        key_left: stepdown;
        key_pageup: pagedown;
        key_pagedown: pageup;
        else begin
         bo1:= false;
        end;
       end;
      end;
      gd_up: begin
       case info.key of
        key_up: stepdown;
        key_down: stepup;
        key_pageup: pageup;
        key_pagedown: pagedown;
        else begin
         bo1:= false;
        end;
       end;
      end;
      gd_left: begin
       case info.key of
        key_right: stepdown;
        key_left: stepup;
        key_pageup: pageup;
        key_pagedown: pagedown;
        else begin
         bo1:= false;
        end;
       end;
      end;
      gd_down: begin
       case info.key of
        key_down: stepup;
        key_up: stepdown;
        key_pageup: pagedown;
        key_pagedown: pageup;
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

procedure tcustomscrollbar.pagedown;
begin
 if sbo_moveauto in foptions then begin
  value:= fvalue - pagesize;
 end;
 fintf.scrollevent(self,sbe_pagedown);
end;

procedure tcustomscrollbar.pageup;
begin
 if sbo_moveauto in foptions then begin
  value:= fvalue + pagesize;
 end;
 fintf.scrollevent(self,sbe_pageup);
end;

procedure tcustomscrollbar.stepdown;
begin
 if sbo_moveauto in foptions then begin
  value:= fvalue - stepsize;
 end;
 fintf.scrollevent(self,sbe_stepdown);
end;

procedure tcustomscrollbar.stepup;
begin
 if sbo_moveauto in foptions then begin
  value:= fvalue + stepsize;
 end;
 fintf.scrollevent(self,sbe_stepup);
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
  if interval < 0 then begin
   interval:= repeatrepeattime;
   enabled:= true;
  end;
 end;
end;

procedure tcustomscrollbar.enter;
begin
 with fdrawinfo,areas[sbbu_move] do begin
  include(state,ss_focused);
  fintf.invalidaterect(buttonareas[bbu_move],forg);
 end;
end;

procedure tcustomscrollbar.exit;
begin
 with fdrawinfo,areas[sbbu_move] do begin
  exclude(fdrawinfo.areas[sbbu_move].state,ss_focused);
  fintf.invalidaterect(buttonareas[bbu_move],forg);
 end;
end;

procedure tcustomscrollbar.createfacebutton;
begin
 ffacebutton:= tface.create(iface(fintf.getwidget));
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
 ffaceendbutton:= tface.create(iface(fintf.getwidget));
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
 fframebutton:= tframe.create(iframe(self));
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
 fframeendbutton1:= tframe.create(iframe(self));
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
 fframeendbutton2:= tframe.create(iframe(self));
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

procedure tcustomscrollbar.invalidatewidget;
begin
 invalidate;
end;

procedure tcustomscrollbar.invalidaterect(const rect: rectty;
               org: originty = org_client);
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

function tcustomscrollbar.getframeclicked: boolean;
begin
 result:= ss_clicked in fdrawinfo.areas[fpaintedbutton].state; 
end;

function tcustomscrollbar.getframemouse: boolean;
begin
 result:= ss_mouse in fdrawinfo.areas[fpaintedbutton].state;
end;

function tcustomscrollbar.getframeactive: boolean;
begin
 result:= fintf.getwidget.active;
end;

procedure tcustomscrollbar.activechanged;
begin
 if (fframeendbutton1 <> nil) or (fframebutton <> nil) or 
                 (fframeendbutton2 <> nil) then begin
  invalidate;
 end;
end;

{ tcustomnomoveautoscrollbar }

constructor tcustomnomoveautoscrollbar.create(intf: iscrollbar;
  org: originty; ondimchanged: objectprocty);
begin
 inherited;
 foptions:= defaultscrollbaroptions-[sbo_moveauto];
end;

procedure tcustomnomoveautoscrollbar.setoptions(
  const avalue: scrollbaroptionsty);
begin
 inherited setoptions(avalue - [sbo_moveauto]);
end;

end.
