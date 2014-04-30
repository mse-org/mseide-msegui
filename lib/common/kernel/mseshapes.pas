{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseshapes;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msegraphics,msegraphutils,mseguiglob,msegui,mseevent,mserichstring,msebitmap,
 msetypes,mseact,msestrings,msedrawtext;

const
 menuarrowwidth = 8;
 menuarrowwidthhorz = 15;
 menucheckboxwidth = 13;
 defaultshapecaptiondist = 2;
 defaultshapefocusrectdist = 1;
 defaultcaptiontextflags = [tf_xcentered,tf_ycentered];

// styleactionstates: actionstatesty = [as_shortcutcaption,as_radiobutton];
type
 tagmouseprocty = procedure (const tag: integer; const info: mouseeventinfoty) of object;

 captioninfoty = record
  dim: rectty;
  caption: richstringty;
  font: tfont;
  textflags: textflagsty;
  imagepos: imageposty;
  captiondist: integer;
  imagenr: imagenrty;
  colorglyph: colorty;
  imagelist: timagelist;
  imagedist: integer;
  imagedisttop: integer;
  imagedistbottom: integer;
  captionclipped: boolean;
 end;
 

 shapeinfoty = record
  ca: captioninfoty;
  focusrectdist: integer;
  state: shapestatesty;
  tabpos: integer;
  group: integer;
  color: colorty;
  coloractive: colorty;
  imagenrdisabled: integer;       //-2 -> grayed
  imagecheckedoffset: integer;
  face: tcustomface;
  frame: tcustomframe;
  mouseframe: framety;
  tag: integer;
  doexecute: tagmouseprocty;
 end;
 pshapeinfoty = ^shapeinfoty;

 shapeinfoarty = array of shapeinfoty;
 pshapeinfoarty = ^shapeinfoarty;
 
 getbuttonhintty = function(const aindex: integer): msestring of object;
 getbuttonhintposty = function(const aindex: integer): rectty of object;

procedure updateedgerect(var arect: rectty; const awidth: integer;
                                    const hiddenedges: edgesty);
procedure draw3dframe(const canvas: tcanvas; const arect: rectty; level: integer;
                      colorinfo: framecolorinfoty; const hiddenedges: edgesty);
procedure drawfocusrect(const canvas: tcanvas; const arect: rectty);
procedure drawtoolbutton(const canvas: tcanvas; var info: shapeinfoty);
procedure drawbutton(const canvas: tcanvas; const info: shapeinfoty);
procedure drawmenubutton(const canvas: tcanvas; var info: shapeinfoty;
                           const innerframe: pframety = nil);
procedure drawtab(const canvas: tcanvas; var info: shapeinfoty;
                               const innerframe: pframety = nil);
function updatemouseshapestate(var info: shapeinfoty;
                 const mouseevent: mouseeventinfoty;
                 const widget: twidget; const aframe: tcustomframe;
                 const infoarpo: pshapeinfoarty = nil;
                 const canclick: boolean = true): boolean; overload;
function updatemouseshapestate(var infos: shapeinfoarty;
                 const mouseevent: mouseeventinfoty;
                 const widget: twidget; var focuseditem: integer;
                 const aframe: tcustomframe = nil): boolean; overload;
         //true on change, calls widget.invalidaterect
function getmouseshape(const infos: shapeinfoarty): integer;
         //returns shape index under mouse, -1 if none
function updatewidgetshapestate(var info: shapeinfoty; const widget: twidget;
                    const adisabled: boolean = false;
//                    const ainvisible: boolean = false;
                    const aframe: tcustomframe = nil): boolean;
function findshapeatpos(const infoar: shapeinfoarty; const apos: pointty;
               const rejectstates: shapestatesty = [shs_disabled,shs_invisible]): integer;
function pointinshape(const pos: pointty; const info: shapeinfoty): boolean;
procedure initshapeinfo(var ainfo: shapeinfoty);

procedure actioninfotoshapeinfo(var actioninfo: actioninfoty;
            var shapeinfo: shapeinfoty); overload;
procedure actioninfotoshapeinfo(const sender: twidget; var actioninfo: actioninfoty;
                                    var shapeinfo: shapeinfoty); overload;
procedure frameskinoptionstoshapestate(const aframe: tcustomframe;
                                    var dest: shapeinfoty{shapestatesty});
function shapestatetoframestate(const aindex: integer;
          const ashapes: shapeinfoarty): framestateflagsty;

procedure checkbuttonhint(const awidget: twidget; info: mouseeventinfoty;
    var hintedbutton: integer; const cells: shapeinfoarty;
     const getbuttonhint: getbuttonhintty; 
     const gethintpos: getbuttonhintposty);

procedure drawcaption(const acanvas: tcanvas; var ainfo: captioninfoty);
procedure initcaptioninfo(var ainfo: captioninfoty);

//var
// animatemouseenter: boolean = true;
 
implementation
uses
 classes,msestockobjects,msebits,sysutils;
type
 twidget1 = class(twidget);
 tframe1 = class(tcustomframe);
var
 buttontab: tcustomtabulators;

procedure frameskinoptionstoshapestate(const aframe: tcustomframe;
                                    var dest: shapeinfoty{shapestatesty});
begin
 if aframe <> nil then begin
  updatebit(longword(dest.state),ord(shs_flat),fso_flat in aframe.optionsskin);
  updatebit(longword(dest.state),ord(shs_noanimation),fso_noanim in aframe.optionsskin);
  updatebit(longword(dest.state),ord(shs_nomouseanimation),
                                    fso_nomouseanim in aframe.optionsskin);
  updatebit(longword(dest.state),ord(shs_noclickanimation),
                                    fso_noclickanim in aframe.optionsskin);
  updatebit(longword(dest.state),ord(shs_nofocusanimation),
                                    fso_nofocusanim in aframe.optionsskin);
  updatebit(longword(dest.state),ord(shs_showfocusrect),
                              not(fso_nofocusrect in aframe.optionsskin));
  updatebit(longword(dest.state),ord(shs_showdefaultrect),
                              not (fso_nodefaultrect in aframe.optionsskin));
  updatebit(longword(dest.state),ord(shs_noinnerrect),
                             fso_noinnerrect in aframe.optionsskin);
  if shs_noinnerrect in dest.state then begin
   dest.mouseframe:= aframe.framei;
  end
  else begin
   dest.mouseframe:= nullframe;
  end;
 end
 else begin
  dest.state:= (dest.state - [shs_flat,shs_noanimation,shs_nomouseanimation,
                  shs_noclickanimation,shs_nofocusanimation,
                  shs_noinnerrect]) + 
                  [shs_showfocusrect,shs_showdefaultrect];
  dest.mouseframe:= nullframe;
 end; 
end;

procedure checkbuttonhint(const awidget: twidget; info: mouseeventinfoty;
                   var hintedbutton: integer; const cells: shapeinfoarty;
                   const getbuttonhint: getbuttonhintty; 
                   const gethintpos: getbuttonhintposty);
var
 int1: integer;
 mstr1: msestring;
begin
 if (info.eventkind = ek_clientmouseleave) then begin
  if hintedbutton >= 0 then begin
   application.hidehint;
  end;
  hintedbutton:= -1;
  exit;
 end;
 int1:= getmouseshape(cells);
 if (info.eventkind in [ek_buttonpress,ek_buttonrelease]) then begin
  if hintedbutton >= 0 then begin
   application.hidehint;
   hintedbutton:= -(hintedbutton+3);
  end
  else begin
   if int1 >= 0 then begin
    hintedbutton:= -(int1+3);
   end;
  end;
  exit;
 end;
 if (info.eventkind in [ek_mousemove,ek_mousepark]) then begin
  if (int1 >= 0) then begin
   if (int1 <> hintedbutton) and (-(int1+3) <> hintedbutton) then begin
    if twidget1(awidget).getshowhint and ((info.eventkind = ek_mousepark) or 
               (hintedbutton >= 0))
                {(application.activehintedwidget = awidget)} then begin
     if cells[int1].state * [shs_separator,shs_clicked] = [] then begin
      hintedbutton:= int1;
      mstr1:= getbuttonhint(int1);
      if (mstr1 <> '') and application.active then begin
        application.showhint(awidget,mstr1,gethintpos(int1),
        cp_bottomleft,-1,[hfl_noautohidemove]);
      end
      else begin
       application.hidehint;
      end;
     end;
    end
    else begin
     application.hidehint;
    end;
   end;
  end
  else begin
   if hintedbutton >= 0 then begin
    application.hidehint;
    hintedbutton:= -1;
   end;
  end;
 end;
end;

procedure actioninfotoshapeinfo(var actioninfo: actioninfoty;
            var shapeinfo: shapeinfoty);
begin
 with actioninfo do begin
  actionstatestoshapestates(actioninfo,shapeinfo.state);
  shapeinfo.ca.caption:= caption1;
  shapeinfo.ca.imagelist:= timagelist(imagelist);
  shapeinfo.ca.imagenr:= imagenr;
  shapeinfo.imagenrdisabled:= imagenrdisabled;
  shapeinfo.ca.colorglyph:= colorglyph;
  shapeinfo.color:= color;
  shapeinfo.imagecheckedoffset:= imagecheckedoffset;
  shapeinfo.group:= group;
 end;
end;

procedure actioninfotoshapeinfo(const sender: twidget; var actioninfo: actioninfoty;
                                    var shapeinfo: shapeinfoty);
var
 statebefore: actionstatesty;
begin
 if not (csloading in sender.componentstate) then begin
  with actioninfo do begin
   statebefore:= state;
   if (sender.enabled) <> not (as_disabled in state) then begin
    sender.enabled:= not(as_disabled in state);
   end;
   if (sender.visible) <> not (as_invisible in state) then begin
    sender.visible:= not(as_invisible in state);
   end;
   state:= statebefore; //restore localflag
   actioninfotoshapeinfo(actioninfo,shapeinfo);
   updatewidgetshapestate(shapeinfo,sender,false,twidget1(sender).fframe);
                                   //update shs_disabled by isenabled
   sender.invalidate;
  end;
 end;
end;

procedure initcaptioninfo(var ainfo: captioninfoty);
begin
 with ainfo do begin
  captiondist:= defaultshapecaptiondist;
  textflags:= defaultcaptiontextflags;
//  textflags:= [tf_default];
 end;
end;
 
procedure initshapeinfo(var ainfo: shapeinfoty);
begin
 with ainfo do begin
  initcaptioninfo(ainfo.ca);
  focusrectdist:= defaultshapefocusrectdist;
 end;
end;

procedure setchecked(var info: shapeinfoty; const value: boolean;
                      const widget: twidget);
begin
 with info do begin
  if value xor (shs_checked in state) then begin
   widget.invalidaterect(ca.dim);
   updatebit({$ifdef FPC}longword{$else}longword{$endif}(info.state),
                           ord(shs_checked),value);
  end;
 end;
end;

function updatewidgetshapestate(var info: shapeinfoty; const widget: twidget;
            const adisabled: boolean = false;
            const aframe: tcustomframe = nil): boolean;
var
 statebefore: shapestatesty;
 rect1: rectty;
begin
 with info do begin
  statebefore:= state;
  updatebit(longword(state),ord(shs_disabled),not widget.isenabled or adisabled);
  updatebit(longword(state),ord(shs_focused),widget.active);
  result:= state <> statebefore;
  if result then begin
   rect1:= ca.dim;
   if (aframe <> nil) and tframe1(aframe).needsactiveinvalidate then begin
    inflaterect1(rect1,aframe.innerframe);
   end;
   if shs_widgetorg in state then begin
    widget.invalidaterect(rect1,org_widget);
   end
   else begin
    widget.invalidaterect(rect1);
   end;
  end;
 end;
end;

procedure updateshapemoveclick(const infoarpo: pshapeinfoarty; value: boolean);
var
 int1: integer;
begin
 if infoarpo <> nil then begin
  for int1:= 0 to high(infoarpo^) do begin
   updatebit({$ifdef FPC}longword{$else}longword{$endif}(infoarpo^[int1].state),
        ord(shs_moveclick),value);
  end;
 end;
end;

function pointinshape(const pos: pointty; const info: shapeinfoty): boolean;
begin
 if shs_ellipsemouse in info.state then begin
  result:= pointinellipse(pos,deflaterect(info.ca.dim,info.mouseframe));
 end
 else begin
  result:= pointinrect(pos,deflaterect(info.ca.dim,info.mouseframe));
 end;
end;

function updatemouseshapestate(var info: shapeinfoty;
                 const mouseevent: mouseeventinfoty;
                 const widget: twidget; const aframe: tcustomframe;
                 const infoarpo: pshapeinfoarty = nil;
                 const canclick: boolean = true): boolean;
         //true on change
var
 statebefore: shapestatesty;
 int1: integer;
 po1: pshapeinfoty;
 bo1: boolean;
// rect1: rectty;

begin
 result:= false;
 bo1:= (widget = nil) or widget.isenabled;
 with info,mouseevent do begin
  statebefore:= state;
  if es_drag in eventstate then begin
   state:= state - [shs_mouse,shs_clicked];
   updateshapemoveclick(infoarpo,false);
  end
  else begin
   if not (shs_invisible in state) and bo1 then begin
    case eventkind of
     ek_clientmouseleave,ek_mouseleave: begin
      if (eventkind = ek_mouseleave) or not (shs_widgetorg in state) then begin
       state:= state - [shs_mouse,shs_clicked];
      end;
     end;
     ek_mousemove,ek_mousepark: begin
//      if pointinrect(pos,ca.dim) then begin
      if pointinshape(pos,info) then begin
       state:= state + [shs_mouse];
       if (ss_left in shiftstate) and
         (state * [shs_disabled,shs_moveclick] = [shs_moveclick]) then begin
        state:= state + [shs_clicked];
       end;
      end
      else begin
       state:= state - [shs_mouse,shs_clicked];
      end;
     end;
     ek_buttonrelease: begin
      if button = mb_left then begin
       updateshapemoveclick(infoarpo,false);
       exclude(state,shs_moveclick);
       if not (shs_disabled in state) then begin
        if state * [shs_clicked,shs_checkbox,shs_radiobutton] = 
                                      [shs_clicked,shs_checkbox] then begin
         setchecked(info,not (shs_checked in state),widget);
        end;
        if state * [shs_clicked,shs_radiobutton] = 
                               [shs_clicked,shs_radiobutton] then begin
         if [shs_checked,shs_checkbox] * state = 
                               [shs_checked,shs_checkbox] then begin
          setchecked(info,false,widget);
         end
         else begin
          if (infoarpo <> nil) then begin
           for int1:= 0 to high(infoarpo^) do begin
            po1:= @infoarpo^[int1];
            if (po1 <> @info) and (po1^.group = info.group) and
                           (shs_radiobutton in po1^.state) then begin
             setchecked(po1^,false,widget);
            end;
           end;
           setchecked(info,true,widget);
          end;
         end;
        end;
        if (eventkind = ek_buttonrelease) and (shs_clicked in state) and
             assigned(doexecute) then begin
         state:= state - [shs_clicked];
         result:= true;              //state can be invalid after execute
         if widget <> nil then begin //info can be invalid after execute
          if (aframe <> nil) and tframe1(aframe).needsmouseinvalidate then begin
           widget.invalidaterect(inflaterect(ca.dim,aframe.innerframe));
          end
          else begin
           widget.invalidaterect(ca.dim);
          end;
         end;
         doexecute(tag,mouseevent);
         exit;
        end;
       end;
       state:= state - [shs_clicked];
      end;
     end;
     ek_buttonpress: begin
      if canclick and (button = mb_left) and 
      (not(shs_disabled in state) or 
             (widget <> nil) and (csdesigning in widget.componentstate)) 
             and pointinshape(pos,info) then begin
       state:= state + [shs_clicked,shs_moveclick];
       updateshapemoveclick(infoarpo,true);
      end;
     end;
    end;
   end
   else begin
    state:= state - [shs_mouse,shs_clicked];
   end;
  end;
  result:= result or (state <> statebefore);
  if result and (widget <> nil) then begin
   if (aframe <> nil) and tframe1(aframe).needsmouseinvalidate then begin
    widget.invalidaterect(inflaterect(ca.dim,aframe.innerframe));
   end
   else begin
    widget.invalidaterect(ca.dim);
   end;
  end;
 end;
end;

function updatemouseshapestate(var infos: shapeinfoarty;
                 const mouseevent: mouseeventinfoty;
                 const widget: twidget; var focuseditem: integer;
                 const aframe: tcustomframe = nil): boolean;
var
 int1{,int2}: integer;
begin
 result:= false;
 for int1:= 0 to high(infos) do begin
  result:= updatemouseshapestate(infos[int1],mouseevent,widget,
                                                 aframe,@infos) or result;
  if shs_mouse in infos[int1].state then begin
   if focuseditem <> int1 then begin
    if (focuseditem >= 0) and (focuseditem <= high(infos)) then begin
     widget.invalidaterect(infos[focuseditem].ca.dim);
    end;
    focuseditem:= int1;
   end;
  end;
 end;
end;

function getmouseshape(const infos: shapeinfoarty): integer;
         //returns shape index under mouse, -1 if none
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(infos) do begin
  if shs_mouse in infos[int1].state then begin
   result:= int1;
   break;
  end;
 end;
end;

function findshapeatpos(const infoar: shapeinfoarty; const apos: pointty;
               const rejectstates: shapestatesty = 
                                   [shs_disabled,shs_invisible]): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(infoar) do begin
  with infoar[int1] do begin
   if (state * rejectstates = []) and pointinrect(apos,ca.dim) then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

function shapestatetoframestate(const aindex: integer;
          const ashapes: shapeinfoarty): framestateflagsty;
var
 state1: shapestatesty;
begin
 result:= [];
 if aindex <= high(ashapes) then begin
  state1:= ashapes[aindex].state;
  if shs_disabled in state1 then begin
   include(result,fsf_disabled);
  end;
  if [shs_active{,shs_focused}] * state1 <> [] then begin
   include(result,fsf_active);
  end;
  if shs_mouse in state1 then begin
   include(result,fsf_mouse);
  end;
  if shs_clicked in state1 then begin
   include(result,fsf_clicked);
  end;
 end;
end;

procedure updateedgerect(var arect: rectty; const awidth: integer;
                                    const hiddenedges: edgesty);
begin
 if not (edg_right in hiddenedges) then begin
  dec(arect.cx,awidth);
 end;
 if not (edg_top in hiddenedges) then begin
  inc(arect.y,awidth);
  dec(arect.cy,awidth);
 end;
 if not (edg_left in hiddenedges) then begin
  inc(arect.x,awidth);
  dec(arect.cx,awidth);
 end;
 if not (edg_bottom in hiddenedges) then begin
  dec(arect.cy,awidth);
 end;
end;

procedure draw3dframe(const canvas: tcanvas; const arect: rectty; level: integer;
                       colorinfo: framecolorinfoty; const hiddenedges: edgesty);
//todo: optimize

type
 cornerinfoty = record
  col1,col2: colorty;
  w1,w2: integer;
 end;
 pcornerinfoty = ^cornerinfoty;

var
 poly: array[0..5] of pointty;

 procedure drawcorner(const cornerinfo: cornerinfoty;
                      const firstoff,lastoff,startoff,stopoff: boolean;
                      const topleft: boolean);

  procedure calculatepoly(w: integer);
  begin
   poly[3].x:= poly[2].x - w;
   poly[3].y:= poly[2].y + w;
   poly[4].x:= poly[1].x + w;
   poly[4].y:= poly[3].y;
   poly[5].x:= poly[4].x;
   poly[5].y:= poly[0].y - w;
   if (w = 1) and topleft then begin
    dec(poly[0].y);
    dec(poly[2].x);
   end;
   if startoff then begin
    if topleft then begin
     poly[0].y:= arect.y + arect.cy;
     if w = 1 then begin
      dec(poly[0].y);
     end;
    end
    else begin
     poly[0].y:= arect.y;
    end;
    poly[5].y:= poly[0].y;
   end;
   if stopoff then begin
    if topleft then begin
     poly[2].x:= arect.x + arect.cx;
     if w = 1 then begin
      dec(poly[2].x);
     end;
    end
    else begin
     poly[2].x:= arect.x;
    end;
    poly[3].x:= poly[2].x;
   end;

   if firstoff then begin
    if topleft then begin
     poly[1].x:= arect.x;
     poly[4].x:= poly[1].x;
    end
    else begin
     poly[1].x:= arect.x+arect.cx;
     if w = 1 then begin
      dec(poly[1].x);
     end;
     poly[4].x:= poly[1].x;
    end;
    poly[0]:= poly[1];
    poly[5]:= poly[4];
   end;
   if lastoff then begin
    if topleft then begin
     poly[1].y:= arect.y;
     poly[4].y:= poly[1].y;
    end
    else begin
     poly[4].y:= arect.y+arect.cy;
     if w = 1 then begin
      dec(poly[4].y);
     end;
     poly[1].y:= poly[4].y;
    end;
    poly[2]:= poly[1];
    poly[3]:= poly[4];
   end;
  end; //calculatepoly
 
 begin
  with canvas,cornerinfo do begin
   calculatepoly(w1);
   if w1 > 0 then begin
    if w1 = 1 then begin
     drawlines(poly,false,col1,0,3);
    end
    else begin
     fillpolygon(poly,col1);
    end;
   end;
   if w2 > 0 then begin
    poly[0]:= poly[5];
    poly[1]:= poly[4];
    poly[2]:= poly[3];
    calculatepoly(w2);
    if w2 = 1 then begin
     drawlines(poly,false,col2,0,3);
    end
    else begin
     fillpolygon(poly,col2);
    end;
   end;
  end;
 end;

var
 lightcorner,shadowcorner: cornerinfoty;
 down: boolean;
 int1: integer;
 po1: pcornerinfoty;
begin
 if (level = 0) or (arect.cx = 0) or (arect.cy = 0) then begin
  exit;
 end;
 with colorinfo do begin
  if shadow.effectcolor = cl_default then begin
   shadow.effectcolor:= defaultframecolors.shadow.effectcolor;
  end;
  if shadow.color = cl_default then begin
   shadow.color:= defaultframecolors.shadow.color;
  end;
  if light.color = cl_default then begin
   light.color:= defaultframecolors.light.color;
  end;
  if light.effectcolor = cl_default then begin
   light.effectcolor:= defaultframecolors.light.effectcolor;
  end;
  if shadow.effectwidth < 0 then begin
   shadow.effectwidth:= defaultframecolors.shadow.effectwidth;
  end;
  if light.effectwidth < 0 then begin
   light.effectwidth:= defaultframecolors.light.effectwidth;
  end;
 end;
 if level < 0 then begin
  down:= true;
  level:= -level;
 end
 else begin
  down:= false;
 end;

 with lightcorner,colorinfo.light do begin
  int1:= abs(effectwidth);
  if int1 > level then begin
   col1:= effectcolor;
   w1:= level;
   w2:= 0;
  end
  else begin
   if (effectwidth < 0){ xor down} then begin
    col1:= effectcolor;
    col2:= color;
    w1:= int1;
    w2:= level - int1;
   end
   else begin
    col1:= color;
    col2:= effectcolor;
    w1:= level - int1;
    w2:= int1;
   end;
  end;
 end;
 with shadowcorner,colorinfo.shadow do begin
  int1:= abs(effectwidth);
  if int1 > level then begin
   col1:= color;
   w1:= level;
   w2:= 0;
  end
  else begin
   if level - int1 < 1 then begin //reduce dkshadow
    int1:= level - 1;
   end;
   if (effectwidth < 0){ xor down} then begin
    col1:= effectcolor;
    col2:= color;
    w1:= int1;
    w2:= level-int1;
   end
   else begin
    col1:= color;
    col2:= effectcolor;
    w1:= level-int1;
    w2:= int1;
   end;
  end;
 end;

 with arect do begin
  if hiddenedges * [edg_left,edg_top] <> [edg_left,edg_top] then begin
   poly[0].x:= x;
   poly[0].y:= y + cy;
   poly[1]:= pos;
   poly[2].x:= x + cx;
   poly[2].y:= y;
 
   if down then begin              //topleft
    po1:= @shadowcorner;
   end
   else begin
    po1:= @lightcorner;
    if (level > 2) and (hiddenedges * [edg_left,edg_top] = []) then begin
     canvas.drawline(pos,makepoint(pos.x+level-1,pos.y+level-1),
                  colorinfo.light.effectcolor);
    end;
   end;
   drawcorner(po1^,edg_left in hiddenedges,edg_top in hiddenedges,
                   edg_bottom in hiddenedges,edg_right in hiddenedges,true); 
   if not down and (level > 2) and 
                          (hiddenedges * [edg_left,edg_top] = []) then begin
    canvas.drawline(pos,makepoint(pos.x+level-1,pos.y+level-1),
                 colorinfo.light.effectcolor);
   end;
  end;
  if hiddenedges * [edg_right,edg_bottom] <> [edg_right,edg_bottom] then begin
   poly[0].x:= x + cx - level;
   poly[0].y:= y + level - 1;
   poly[1].x:= poly[0].x;
   poly[1].y:= y + cy - level;
   poly[2].x:= x + level;
   poly[2].y:= poly[1].y;
 
   if down then begin           //bottomright
    po1:= @lightcorner;
   end
   else begin
    po1:= @shadowcorner;
   end;
   drawcorner(po1^,edg_right in hiddenedges,edg_bottom in hiddenedges,
                   edg_top in hiddenedges,edg_left in hiddenedges,false);   
  end;
 end;
end;

procedure drawfocusrect(const canvas: tcanvas; const arect: rectty);
begin
 canvas.drawxorframe(arect,-1,stockobjects.bitmaps[stb_block1]);
end;

function drawbuttonframe(const canvas: tcanvas; const info: shapeinfoty;
        out clientrect: rectty): boolean; //true if clientrect > 0
var
 level: integer;
 col1: colorty;
begin
 result:= false;
 with canvas,info do begin
  if shs_separator in state then begin
   draw3dframe(canvas,ca.dim,-1,defaultframecolors,[]);
  end
  else begin
   if shs_flat in state then begin
    level:= 0;
   end
   else begin
    level:= 1;
   end;
   if not (shs_noanimation in state) then begin
    if not (shs_nomouseanimation in state) and
                     (shs_mouse in state) and not (shs_disabled in state) or
           (state * [shs_nofocusanimation,shs_focused,shs_focusanimation] = 
                                   [shs_focused,shs_focusanimation]) then begin
     inc(level);
    end;
    if not (shs_noclickanimation in state) and (shs_clicked in state) or
         (state * [shs_checked,shs_checkbutton] = 
                                   [shs_checked,shs_checkbutton])  then begin
     level:= -1;
    end;
   end;
   clientrect:= ca.dim;
   if (state * [shs_focused,shs_showdefaultrect] = 
                           [shs_focused,shs_showdefaultrect]) or
          (state * [shs_disabled,shs_default] = [shs_default]) then begin
    canvas.drawframe(clientrect,-1,cl_black);
    inflaterect1(clientrect,-1);
   end;
   draw3dframe(canvas,clientrect,level,defaultframecolors,[]);
   inflaterect1(clientrect,-abs(level));
   if (clientrect.cx > 0) and (clientrect.cy > 0) then begin
    result:= true;
    col1:= color;
    if shs_active in state then begin
     col1:= coloractive;
    end;
    if col1 <> cl_transparent then begin
     fillrect(clientrect,col1);
    end;
    if face <> nil then begin
     face.paint(canvas,clientrect);
    end;
   end;
  end;
 end;
end;

function adjustimagerect(const info: captioninfoty; var arect: rectty;
                              out aalign: alignmentsty): rectty;
var
 pos: imageposty;
 int1,int2: integer; 
begin
 result:= arect;
 with info do begin
  case imagepos of
   ip_left,ip_leftcenter: begin
    pos:= ip_left;
   end;
   ip_right,ip_rightcenter: begin
    pos:= ip_right;
   end;
   ip_bottom,ip_bottomcenter: begin
    pos:= ip_bottom;
   end;
   ip_top,ip_topcenter: begin
    pos:= ip_top;
   end
   else begin
    pos:= ip_center;
   end;
  end;
  if not (pos in [ip_top,ip_bottom]) then begin
   inc(result.y,imagedisttop + 
    (result.cy - imagedisttop - imagedistbottom - imagelist.height) div 2);
   result.cy:= imagelist.height;
  end;
  case pos of
   ip_right: begin
    aalign:= [al_right{,al_ycentered}];
    dec(result.cx,imagedist);
   end;
   ip_left: begin
    aalign:= [{al_ycentered}];
    inc(result.x,imagedist);
    dec(result.cx,imagedist);
   end;
   ip_bottom: begin
    aalign:= [al_xcentered,al_bottom];
    dec(result.cy,imagedist+imagedistbottom);
   end;
   ip_top: begin
    aalign:= [al_xcentered];
    inc(result.y,imagedist+imagedistbottom);
   end;
   else begin
    aalign:= [al_xcentered{,al_ycentered}];
   end;
  end;
  int1:= imagelist.width + imagedist;
  int2:= imagelist.height + imagedist;
  case pos of
   ip_right: begin
    dec(arect.cx,int1);
   end;
   ip_left: begin
    inc(arect.x,int1);
    dec(arect.cx,int1);
   end;
   ip_top: begin
    inc(arect.y,int2);
    dec(arect.cy,int2);
   end;
   ip_bottom: begin
    dec(arect.cy,int2);
   end;
  end;
 end;
end;

function drawbuttonimage(const canvas: tcanvas; const info: shapeinfoty;
              var arect: rectty): boolean;
var
 align1: alignmentsty;
 rect1: rectty;
 int1: integer;
 reg1: regionty;
 co1: colorty;
begin
 with canvas,info do begin
  if (ca.imagelist <> nil) then begin
   reg1:= canvas.copyclipregion;
   canvas.intersectcliprect(arect);
   result:= true;
   rect1:= adjustimagerect(info.ca,arect,align1);
   if shs_disabled in state then begin
    int1:= imagenrdisabled;
    if int1 = -2 then begin
     int1:= ca.imagenr;
     include(align1,al_grayed);
    end;
   end
   else begin
    int1:= ca.imagenr;
   end;
   if (shs_checked in state) and (int1 >= 0) then begin
    inc(int1,imagecheckedoffset);
   end;
   if state*[shs_focuscolor,shs_focused] = 
                [shs_focuscolor,shs_focused] then begin
    canvas.fillrect(rect1,cl_selectedtextbackground);
    co1:= cl_selectedtext;
   end
   else begin
    if ca.colorglyph <> cl_none then begin
     co1:= ca.colorglyph;
     if co1 = cl_default then begin
      co1:= cl_glyph;
     end;
    end;
   end;
   ca.imagelist.paint(canvas,int1,rect1,align1,co1);
   canvas.clipregion:= reg1;
  end
  else begin
   result:= false;
  end;
 end;
end;

procedure drawbuttoncaption(const canvas: tcanvas; const info: shapeinfoty;
        const arect: rectty; const pos: imageposty; const outerrect: prectty);
var
 textflags: textflagsty;
 rect1: rectty;
 tab1: tcustomtabulators;
begin
 with canvas,info do begin
  tab1:= nil;
  if ca.caption.text <> '' then begin
   rect1:= arect;
   case pos of
    ip_left,ip_leftcenter: begin
//     textflags:= [tf_ycentered,tf_clipi];
     inc(rect1.x,ca.captiondist);
     dec(rect1.cx,ca.captiondist);
     if countchars(ca.caption.text,msechar(c_tab)) = 1 then begin
      tab1:= buttontab;
      tab1[0].pos:= info.tabpos / defaultppmm;
     end;
    end;
    ip_right,ip_rightcenter: begin
//     textflags:= [tf_ycentered,tf_right,tf_clipi];
     dec(rect1.cx,ca.captiondist);
    end;
    ip_top,ip_topcenter: begin
//     textflags:= [tf_xcentered,tf_clipi];
     inc(rect1.y,ca.captiondist);
     dec(rect1.cy,ca.captiondist);
    end;
    ip_bottom,ip_bottomcenter: begin
//     textflags:= [tf_xcentered,tf_bottom,tf_clipi];
     dec(rect1.cy,ca.captiondist);
    end;
//    else begin
//     textflags:= [tf_ycentered,tf_xcentered,tf_clipi];
//    end;
   end;
{
   if pos in [ip_leftcenter,ip_rightcenter] then begin
    include(textflags,tf_xcentered);
    exclude(textflags,tf_right);
   end
   else begin
    if pos in [ip_bottomcenter,ip_topcenter] then begin
     include(textflags,tf_ycentered);
     exclude(textflags,tf_bottom);
    end;
   end;
}
//   if tf_forcealignment in ca.textflags then begin
    textflags:= ca.textflags + [tf_clipi];
//   end
//   else begin
//    textflags:= textflags + (ca.textflags - textalignments);
//   end;
   if shs_disabled in state then begin
    include(textflags,tf_grayed);
   end;
   if outerrect <> nil then begin
    exclude(textflags,tf_clipi);
    include(textflags,tf_clipo);
    drawtext(canvas,ca.caption,rect1,outerrect^,textflags,ca.font,tab1);
   end
   else begin
    drawtext(canvas,ca.caption,rect1,arect,textflags,ca.font,tab1);
   end;
  end;
 end;
end;
 
procedure drawbutton(const canvas: tcanvas; const info: shapeinfoty);
var
 rect1,rect2: rectty;
// pos: captionposty;
begin
 if not (shs_invisible in info.state) and 
                        drawbuttonframe(canvas,info,rect1) then begin
  rect2:= rect1;
  drawbuttonimage(canvas,info,rect1);
  with canvas,info do begin
   if state * [shs_focused,shs_showfocusrect] = 
                   [shs_focused,shs_showfocusrect] then begin
    drawfocusrect(canvas,inflaterect(rect2,-focusrectdist));
   end;
   drawbuttoncaption(canvas,info,rect1,info.ca.imagepos
                           {swapcaptionpos[info.ca.captionpos]},nil);
  end;
 end;
end;

procedure drawcaption(const acanvas: tcanvas; var ainfo: captioninfoty);
var
 rect1,rect2: rectty;
 align1: alignmentsty;
 info1: drawtextinfoty;
begin
 with ainfo do begin
  rect2:= ainfo.dim;
  if ainfo.imagelist <> nil then begin
   rect1:= adjustimagerect(ainfo,rect2,align1);
   if colorglyph <> cl_none then begin
    imagelist.paint(acanvas,imagenr,rect1,align1,colorglyph);
   end;
  end;
  case imagepos of
   ip_left,ip_leftcenter: begin
    inc(rect2.x,captiondist);
    dec(rect2.cx,captiondist);
   end;
   ip_right,ip_rightcenter: begin
    dec(rect2.cx,captiondist);
   end;
   ip_top,ip_topcenter: begin
    inc(rect2.y,captiondist);
    dec(rect2.cy,captiondist);
   end;
   ip_bottom,ip_bottomcenter: begin
    dec(rect2.cy,captiondist);
   end;
  end;
  info1.text:= caption;
  info1.dest:= rect2;
  info1.flags:= textflags - [tf_clipo];
  info1.font:= font;
  info1.tabulators:= nil;
  drawtext(acanvas,info1);
  captionclipped:= (info1.res.cx > rect2.cx) or (info1.res.cy > rect2.cy);
  //drawtext(acanvas,caption,rect2,textflags,font);
 end;
end;

procedure drawtoolbutton(const canvas: tcanvas; var info: shapeinfoty);
var
 rect1: rectty;
 frame1: framety;
begin 
 if not (shs_invisible in info.state) then begin
  if info.frame <> nil then begin 
   //todo: optimize, move settings to tcustomstepframe updatestate
//   canvas.save;
   info.frame.paintbackground(canvas,info.ca.dim,false);
//   canvas.restore;
   if not (fso_noinnerrect in info.frame.optionsskin) then begin
    frame1:= info.frame.innerframe;
    deflaterect1(info.ca.dim,frame1);
   end
   else begin
    frame1:= nullframe;
   end;
   frameskinoptionstoshapestate(info.frame,info);
  end; 
  if drawbuttonframe(canvas,info,rect1) then begin
   info.ca.imagepos:= ip_center;
   drawbuttonimage(canvas,info,rect1{,cp_center});
  end;
  if info.frame <> nil then begin
   inflaterect1(info.ca.dim,frame1);
   info.frame.paintoverlay(canvas,info.ca.dim);
  end; 
 end;
end;

function drawbuttoncheckbox(const canvas: tcanvas; const info: shapeinfoty;
              var arect: rectty; const pos: imageposty = ip_left): boolean;
var
 rect1: rectty;
 align1: alignmentsty;
 int1: integer;
begin
 result:= [shs_checkbox,shs_radiobutton] * info.state <> [];
 if result then begin
  rect1:= arect;
  rect1.cx:= menucheckboxwidth;
  if pos <> ip_left then begin
   inc(rect1.x,arect.cx-rect1.cx);
  end;
  draw3dframe(canvas,rect1,-1,defaultframecolors,[]);
  if pos = ip_left then begin
   inc(arect.x,menucheckboxwidth);
  end;
  dec(arect.cx,menucheckboxwidth);
  if shs_checked in info.state then begin
   if shs_disabled in info.state then begin
    align1:= [al_xcentered,al_ycentered,al_grayed];
   end
   else begin
    align1:= [al_xcentered,al_ycentered];
   end;
   if shs_radiobutton in info.state then begin
    int1:= ord(stg_checkedradio);
   end
   else begin
    int1:= ord(stg_checked);
   end;
   stockobjects.glyphs.paint(canvas,int1,rect1,align1,info.ca.colorglyph);
  end;
 end;
end;

procedure drawmenuarrow(const canvas: tcanvas; const info: shapeinfoty;
                          var rect: rectty);
var
 alignment: alignmentsty;
 int1: integer;
 glyph1: stockglyphty;
 rect1: rectty;
begin
 glyph1:= stg_arrowrightsmall;
 if shs_horz in info.state then begin
  glyph1:= stg_arrowdownsmall;
  int1:= menuarrowwidthhorz;
 end
 else begin
  int1:= menuarrowwidth;
 end;
 alignment:= [al_xcentered,al_ycentered];
 if shs_disabled in info.state then begin
  include(alignment,al_grayed);
  inc(int1);
 end;
 with rect1 do begin
  x:= rect.x + rect.cx - int1;
  cx:= int1;
  y:= rect.y;
  cy:= rect.cy;
 end;
 stockobjects.glyphs.paint(canvas,ord(glyph1),rect1,alignment,
                                 info.ca.colorglyph);
 dec(rect.cx,int1);
end;

procedure drawmenubutton(const canvas: tcanvas; var info: shapeinfoty;
                  const innerframe: pframety = nil);
var
 rect1: rectty;
begin
 if not (shs_invisible in info.state) and 
              drawbuttonframe(canvas,info,rect1) then begin
  info.ca.imagepos:= ip_left;
  drawbuttonimage(canvas,info,rect1{,cp_left});
  if (shs_menuarrow in info.state) then begin
//  if (ss_submenu in info.state)  then begin
   drawmenuarrow(canvas,info,rect1);
  end;
  drawbuttoncheckbox(canvas,info,rect1,ip_right);
  if innerframe <> nil then begin
   deflaterect1(rect1,innerframe^);
  end;
  drawbuttoncaption(canvas,info,rect1,ip_left,nil);
 end;
end;

procedure drawtab(const canvas: tcanvas; var info: shapeinfoty; 
                                   const innerframe: pframety = nil);
var
 int1: integer;
 color1: colorty;
 rect1,rect2,rect3: rectty;
 pos1: imageposty;
 frame1: framety;
begin
 with canvas,info do begin
  if not (shs_invisible in state) then begin
   if frame <> nil then begin 
    //todo: optimize, move settings to tcustomstepframe updatestate
    rect3:= ca.dim;
    if not (fso_noinnerrect in frame.optionsskin) then begin
     deflaterect1(ca.dim,frame.framei);
    end;
//    canvas.save;
    frame.paintbackground(canvas,info.ca.dim,false);
//    canvas.restore;   
    frame1:= frame.paintframe;
    deflaterect1(ca.dim,frame1);
    frameskinoptionstoshapestate(frame,info);
   end;     
   if drawbuttonframe(canvas,info,rect1) then begin
    if ca.imagepos = ip_right then begin
     pos1:= ip_right;
    end
    else begin
     pos1:= ip_left;
    end;
    rect2:= rect1;
    drawbuttonimage(canvas,info,rect1);
    drawbuttoncheckbox(canvas,info,rect1,pos1);
    if state * [shs_focused,shs_showfocusrect] = 
                          [shs_focused,shs_showfocusrect] then begin
     drawfocusrect(canvas,inflaterect(rect2,-focusrectdist));
    end;
    rect2:= rect1; //outerframe
    if innerframe <> nil then begin
     deflaterect1(rect1,innerframe^);
    end;
    drawbuttoncaption(canvas,info,rect1,pos1,@rect2);
   end;
   if frame <> nil then begin
    inflaterect1(info.ca.dim,frame1);
    frame.paintoverlay(canvas,info.ca.dim);
    ca.dim:= rect3;
   end; 
  end;
  if not (shs_active in state) then begin
   if shs_opposite in state then begin
    color1:= defaultframecolors.shadow.color;
   end
   else begin
    color1:= defaultframecolors.light.effectcolor;
   end;
   if shs_vert in state then begin
    if shs_opposite in state then begin
     int1:= ca.dim.x;
    end
    else begin
     int1:= ca.dim.x+ca.dim.cx-1;
    end;
    canvas.drawline(makepoint(int1,ca.dim.y),
                        makepoint(int1,ca.dim.y+ca.dim.cy-1),color1);
   end
   else begin
    if shs_opposite in state then begin
     int1:= ca.dim.y;
    end
    else begin
     int1:= ca.dim.y+ca.dim.cy-1;
    end;
    canvas.drawline(makepoint(ca.dim.x,int1),
                         makepoint(ca.dim.x+ca.dim.cx-1,int1),color1);
   end;
  end;
 end;
end;

initialization
 buttontab:= tcustomtabulators.create;
 buttontab.add(0,tak_left);
finalization
 buttontab.free;
end.
