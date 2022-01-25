{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

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

type
 buttonoptionty = (bo_executeonclick,bo_executeonkey,bo_executeonshortcut,
                   bo_executedefaultonenterkey,
                   bo_asyncexecute,
                   bo_focusonshortcut,bo_focusonactionshortcut,
                                                        //for tcustombutton
                   bo_updateonidle,
                   bo_shortcutcaption,bo_altshortcut,
                   {bo_flat,bo_noanim,bo_nofocusrect,bo_nodefaultrect,}
                   bo_nodefaultframeactive,
                   bo_coloractive,
                   bo_ellipsemouse, //mouse area is elliptical
                   bo_nocandefocus,bo_candefocuswindow, //check own window only
                   bo_radioitem,  //for tdatabutton
                   bo_radioitemcol,
                   bo_cantoggle, //for tbooleaneditradio
                   bo_resetcheckedonrowexit,
                                 //used in tdatabutton
                   bo_reversed,  //for tbooleanedit
                   bo_noassistivedisabled
                   );
 buttonoptionsty = set of buttonoptionty;

const
 defaultbuttonoptions = [bo_executeonclick,bo_executeonkey,
                         bo_executeonshortcut,bo_executedefaultonenterkey];

 menuarrowwidth = 8;
 menuarrowwidthhorz = 15;
 menucheckboxwidth = 13;
 menucheckboxheight = 13;
 defaultshapecaptiondist = 2;
 defaultshapefocusrectdist = 1;
 defaultcaptiontextflags = [tf_left,tf_xcentered,tf_ycentered];

// styleactionstates: actionstatesty = [as_shortcutcaption,as_radiobutton];
type
 buttonedgety =  (bedg_none,bedg_right,bedg_top,bedg_left,bedg_bottom);

 tagmouseprocty = procedure (const tag: integer;
                                     const info: mouseeventinfoty) of object;

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
  imagedist1: integer; //left or top
  imagedist2: integer; //right or bottom
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
  facetemplate: tfacetemplate;
  imagenrdisabled: integer;       //-2 -> grayed
  imagecheckedoffset: integer;
  face: tcustomface;
  frame: tcustomframe;
  checkboxframe: tframetemplate;
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
procedure draw3dframe(const canvas: tcanvas; const arect: rectty;
                      level: integer; colorinfo: edgecolorpairinfoty;
                      const hiddenedges: edgesty);
procedure drawimageframe(const canvas: tcanvas; const imagelist: timagelist;
                         const imageoffs: int32; const dest: rectty;
                                                const hiddenedges: edgesty);
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
               const rejectstates: shapestatesty =
                                         [shs_disabled,shs_invisible]): integer;
function pointinshape(const pos: pointty; const info: shapeinfoty): boolean;
procedure initshapeinfo(var ainfo: shapeinfoty);

procedure actioninfotoshapeinfo(var actioninfo: actioninfoty;
            var shapeinfo: shapeinfoty); overload;
procedure actioninfotoshapeinfo(const sender: twidget;
                 var actioninfo: actioninfoty; var shapeinfo: shapeinfoty;
                                            const aoptions: buttonoptionsty);
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
function calccaptionsize(const acanvas: tcanvas; const ainfo: captioninfoty;
                                  const captionframe: pframety = nil): sizety;

//var
// animatemouseenter: boolean = true;

implementation
uses
 classes,
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msebits,sysutils,mseassistiveserver;
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
   dest.mouseframe:= aframe.frameo;
  end
  else begin
   dest.mouseframe:= nullframe;
  end;
  if aframe = dest.frame then begin
   addframe1(dest.mouseframe,aframe.paintframe);
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
 if (info.eventkind in [ek_mousemove,ek_mousepark]) and
                     not (csdesigning in awidget.componentstate) then begin
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

procedure actioninfotoshapeinfo(const sender: twidget;
                  var actioninfo: actioninfoty; var shapeinfo: shapeinfoty;
                  const aoptions: buttonoptionsty);
var
 statebefore: actionstatesty;
begin
 if not (csloading in sender.componentstate) then begin
  with actioninfo do begin
   statebefore:= state;
   if (sender.enabled) <> not (as_disabled in state) then begin
    if not (as_disabled in state) or
      not (as_syncdisabledlocked in state) and
       (not (bo_noassistivedisabled in aoptions) or
         not sender.canassistive() and
           not (csdesigning in sender.componentstate)) then begin
     sender.enabled:= not(as_disabled in state);
    end;
   end;
   if (sender.visible) <> not (as_invisible in state) then begin
    sender.visible:= not(as_invisible in state);
   end;
   state:= statebefore; //restore localflag
   actioninfotoshapeinfo(actioninfo,shapeinfo);
   updatewidgetshapestate(shapeinfo,sender,as_disabled in state,
                                                 twidget1(sender).fframe);
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
 if result and (info.frame <> nil) then begin
  result:= info.frame.pointinmask(pos,info.ca.dim);
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
       if not (shs_disabled in state) or
         (widget <> nil) and (csdesigning in widget.componentstate) then begin
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
        if {(eventkind = ek_buttonrelease) and} (shs_clicked in state) and
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
          twidget1(widget).releasebuttonpressgrab();
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
             (widget <> nil) and (csdesigning in widget.componentstate) and
             not (ws1_nodisabledclick in twidget1(widget).fwidgetstate1))
             and pointinshape(pos,info) then begin
       state:= state + [shs_clicked,shs_moveclick];
       updateshapemoveclick(infoarpo,true);
      end;
     end;
     else;
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
 int1,i2: integer;
begin
 result:= false;
 i2:= focuseditem;
 focuseditem:= -1; //none
 for int1:= 0 to high(infos) do begin
  result:= updatemouseshapestate(infos[int1],mouseevent,widget,
                                                 aframe,@infos) or result;
  if shs_mouse in infos[int1].state then begin
   focuseditem:= int1;
   if i2 <> int1 then begin
   {           necessary?
    if (focuseditem >= 0) and (focuseditem <= high(infos)) then begin
     widget.invalidaterect(infos[focuseditem].ca.dim);
    end;
   }
    if (int1 >= 0) and (assistiveserver <> nil) then begin
     assistiveserver.doitementer(getiassistiveclient(widget),infos,int1);
    end;
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

procedure draw3dframe(const canvas: tcanvas;
                const arect: rectty; level: integer;
                 colorinfo: edgecolorpairinfoty; const hiddenedges: edgesty);
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
   shadow.effectcolor:= defaultframecolors.edges.shadow.effectcolor;
  end;
  if shadow.color = cl_default then begin
   shadow.color:= defaultframecolors.edges.shadow.color;
  end;
  if light.color = cl_default then begin
   light.color:= defaultframecolors.edges.light.color;
  end;
  if light.effectcolor = cl_default then begin
   light.effectcolor:= defaultframecolors.edges.light.effectcolor;
  end;
  if shadow.effectwidth < 0 then begin
   shadow.effectwidth:= defaultframecolors.edges.shadow.effectwidth;
  end;
  if light.effectwidth < 0 then begin
   light.effectwidth:= defaultframecolors.edges.light.effectwidth;
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

procedure drawimageframe(const canvas: tcanvas; const imagelist: timagelist;
                         const imageoffs: int32; const dest: rectty;
                                                const hiddenedges: edgesty);
var
 imagesize1: sizety;
 rect1: rectty;
begin
 if (imageoffs >= -8) and (imagelist.bitmap.hasimage) then begin
  imagesize1:= imagelist.size;
  if not (edg_left in hiddenedges) then begin
   imagelist.paintlookup(canvas,imageoffs+0,dest.pos); //topleft
   rect1.x:= dest.x;
   rect1.y:= dest.y + imagesize1.cy;
   rect1.cx:= imagesize1.cx;
   rect1.cy:= dest.cy - imagesize1.cy -imagesize1.cy;
   imagelist.paintlookup(canvas,imageoffs+1,rect1,[al_stretchy]); //left
   if edg_bottom in hiddenedges then begin
    imagelist.paintlookup(canvas,imageoffs+2,
                                mp(rect1.x,rect1.y+rect1.cy)); //bottomleft
   end;
  end;
  if not (edg_bottom in hiddenedges) then begin
   rect1.x:= dest.x;
   rect1.y:= dest.y + dest.cy - imagesize1.cy;
   imagelist.paintlookup(canvas,imageoffs+2,rect1.pos); //bottomleft
   rect1.x:= dest.x + imagesize1.cx;
   rect1.cy:= imagesize1.cy;
   rect1.cx:= dest.cx - imagesize1.cx -imagesize1.cx;
   imagelist.paintlookup(canvas,imageoffs+3,rect1,[al_stretchx]); //bottom
   if edg_right in hiddenedges then begin
    imagelist.paintlookup(canvas,imageoffs+4,
                              mp(rect1.x+rect1.cx,rect1.y)); //bottomright
   end;
  end;
  if not (edg_right in hiddenedges) then begin
   rect1.x:= dest.x + dest.cx - imagesize1.cx;
   rect1.y:= dest.y + dest.cy - imagesize1.cy;
   imagelist.paintlookup(canvas,imageoffs+4,rect1.pos); //bottomright
   rect1.y:= dest.y + imagesize1.cy;
   rect1.cx:= imagesize1.cx;
   rect1.cy:= dest.cy - imagesize1.cy - imagesize1.cy;
   imagelist.paintlookup(canvas,imageoffs+5,rect1,[al_stretchy]); //right
   if edg_top in hiddenedges then begin
    imagelist.paintlookup(canvas,imageoffs+6,mp(rect1.x,dest.y));
                                                            //topright
   end;
  end;
  if not (edg_top in hiddenedges) then begin
   rect1.x:= dest.x + dest.cx - imagesize1.cx;
   rect1.y:= dest.y;
   imagelist.paintlookup(canvas,imageoffs+6,rect1.pos); //topright
   rect1.x:= dest.x + imagesize1.cx;
   rect1.cy:= imagesize1.cy;
   rect1.cx:= dest.cx - imagesize1.cx - imagesize1.cx;
   imagelist.paintlookup(canvas,imageoffs+7,rect1,[al_stretchx]); //top
   if edg_left in hiddenedges then begin
    imagelist.paintlookup(canvas,imageoffs+0,mp(dest.x,dest.y));
                                                            //topleft
   end;
  end;
 end;
end;

procedure drawfocusrect(const canvas: tcanvas; const arect: rectty);
begin
 canvas.drawxorframe(arect,-1,stockobjects.bitmaps[stb_block1]);
end;

function drawbuttonframe(const canvas: tcanvas; const info: shapeinfoty;
        out clientrect: rectty;
                     const hiddenedges: edgesty = []): boolean;
                                               //true if clientrect not empty
var
 level: integer;
 col1: colorty;
 rect1: rectty;
begin
 result:= false;
 with canvas,info do begin
  if shs_separator in state then begin
   if not (shs_flat in state) then begin
    draw3dframe(canvas,ca.dim,-1,defaultframecolors.edges,[]);
   end;
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
    if not (aso_nodefaultbutton in assistiveoptions) then begin
                                               //no default button if assisted
     canvas.drawframe(clientrect,-1,cl_buttondefaultrect);
     inflaterect1(clientrect,-1);
    end;
   end;
   rect1:= clientrect;
   if (clientrect.cx > 0) and (clientrect.cy > 0) then begin
    col1:= color;
    if shs_active in state then begin
     col1:= coloractive;
    end;
    if col1 <> cl_transparent then begin
     fillrect(clientrect,col1);
    end;
    if facetemplate <> nil then begin
     facetemplate.paint(canvas,clientrect);
    end
    else begin
     if face <> nil then begin
      face.paint(canvas,clientrect);
     end;
    end;
   end;
   draw3dframe(canvas,rect1,level,defaultframecolors.edges,hiddenedges);
  end;
  inflaterect1(clientrect,-abs(level),hiddenedges);
  result:= (clientrect.cx > 0) and (clientrect.cy > 0);
 end;
end;

function adjustimagerect(const canvas: tcanvas; const info: captioninfoty;
                         var arect: rectty; out aalign: alignmentsty): rectty;
var
 pos: imageposty;
 i1,i2: integer;
 rect1,rect2: rectty;
begin
 result:= arect;
 with info do begin
  pos:= simpleimagepos[imagepos];
  if pos in (vertimagepos) then begin
//   if result.cx < imagelist.width then begin
    i1:= result.cx - imagelist.width;
    if i1 < 0 then begin
     dec(i1);
    end;
//   end;
   inc(result.x,imagedist1 + (i1 - imagedist1 - imagedist2) div 2);
   result.cx:= imagelist.width;
  end
  else begin
   i1:= result.cy - imagelist.height;
   if i1 < 0 then begin
    dec(i1);
   end;
   inc(result.y,imagedist1 + (i1 - imagedist1 - imagedist2) div 2);
   result.cy:= imagelist.height;
  end;

  case pos of
   ip_right: begin
    aalign:= [al_right];
    case imagepos of
     ip_righttop: begin
      result.y:= arect.y + imagedist1;
     end;
     ip_rightbottom: begin
      result.y:= arect.cy - imagedist2 - imagelist.height;
     end;
     else; // Added to make compiler happy
    end;
    dec(result.cx,imagedist);
   end;
   ip_left: begin
    aalign:= [];
    case imagepos of
     ip_lefttop: begin
      result.y:= arect.y + imagedist1;
     end;
     ip_leftbottom: begin
      result.y:= arect.cy - imagedist2 - imagelist.height;
     end;
     else;
    end;
    inc(result.x,imagedist);
    dec(result.cx,imagedist);
   end;
   ip_bottom: begin
    aalign:= [al_bottom];
    case imagepos of
     ip_bottomleft: begin
      result.x:= arect.x + imagedist1;
     end;
     ip_bottomright: begin
      result.x:= arect.cx - imagedist2 - imagelist.width;
     end;
     else;
    end;
    dec(result.cy,imagedist);
   end;
   ip_top: begin
    aalign:= [];
    case imagepos of
     ip_topleft: begin
      result.x:= arect.x + imagedist1;
     end;
     ip_topright: begin
      result.x:= arect.cx - imagedist2 - imagelist.width;
     end;
     else;
    end;
    inc(result.y,imagedist);
    dec(result.cy,imagedist);
   end;
   ip_center: begin
    aalign:= [al_xcentered,al_ycentered];
    inc(result.x,imagedist);
   end;
   ip_centervert: begin
    aalign:= [al_xcentered,al_ycentered];
    inc(result.y,imagedist);
   end;
   else;
  end;
  i1:= imagelist.width + imagedist;
  i2:= imagelist.height + imagedist;
  case pos of
   ip_right: begin
    dec(arect.cx,i1);
   end;
   ip_left: begin
    inc(arect.x,i1);
    dec(arect.cx,i1);
   end;
   ip_top: begin
    inc(arect.y,i2);
    dec(arect.cy,i2);
   end;
   ip_bottom: begin
    dec(arect.cy,i2);
   end;
   else;
  end;
  if (tf_glueimage in info.textflags) and
                          not (pos in [ip_center,ip_centervert]) then begin
   rect1:= arect;
   if pos in (vertimagepos) then begin
    rect1.cy:= rect1.cy - captiondist;
    rect2:= textrect(canvas,caption,rect1,textflags,font);
    i1:= rect1.cy - rect2.cy;
    if i1 > 0 then begin
     if tf_ycentered in textflags then begin
      i1:= i1 div 2;
      if pos in bottomimagepos then begin
       result.y:= result.y - i1;
      end
      else begin
       result.y:= result.y + i1;
      end;
     end
     else begin
      if tf_bottom in textflags then begin
       if not (pos in bottomimagepos) then begin
        result.y:= result.y + i1 - imagedist;
       end;
      end
      else begin
       if pos in bottomimagepos then begin
        result.y:= result.y - i1 + imagedist;
       end;
      end;
     end;
    end;
   end
   else begin
    rect1.cx:= rect1.cx - captiondist;
    rect2:= textrect(canvas,caption,rect1,textflags,font);
    i1:= rect1.cx - rect2.cx;
    if i1 > 0 then begin
     if tf_xcentered in textflags then begin
      i1:= i1 div 2;
      if pos in rightimagepos then begin
       result.x:= result.x - i1;
      end
      else begin
       result.x:= result.x + i1;
      end;
     end
     else begin
      if tf_right in textflags then begin
       if not (pos in rightimagepos) then begin
        result.x:= result.x + i1 - imagedist;
       end;
      end
      else begin
       if pos in rightimagepos then begin
        result.x:= result.x - i1 + imagedist;
       end;
      end;
     end;
    end;
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
 co1:= 0;
 with canvas,info do begin
  if (ca.imagelist <> nil) then begin
   reg1:= canvas.copyclipregion;
   canvas.intersectcliprect(arect);
   result:= true;
   rect1:= adjustimagerect(canvas,info.ca,arect,align1);
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
   if info.frame <> nil then begin
    deflaterect1(rect1,info.frame.framei);
   end;
   textflags:= ca.textflags + [tf_clipi];
   case pos of
    ip_left,ip_lefttop,ip_leftbottom: begin
     if tf_right in textflags then begin
      dec(rect1.x,ca.captiondist);
     end
     else begin
      inc(rect1.x,ca.captiondist);
      dec(rect1.cx,ca.captiondist);
     end;
     if countchars(ca.caption.text,msechar(c_tab)) = 1 then begin
      tab1:= buttontab;
      tab1[0].pos:= info.tabpos / defaultppmm;
     end;
    end;
    ip_right,ip_righttop,ip_rightbottom: begin
     if textflags * [tf_right,tf_xcentered] = [] then begin
      inc(rect1.x,ca.captiondist);
     end;
     dec(rect1.cx,ca.captiondist);
    end;
    ip_top,ip_topleft,ip_topright: begin
     if tf_bottom in textflags then begin
      dec(rect1.y,ca.captiondist);
     end
     else begin
      inc(rect1.y,ca.captiondist);
      dec(rect1.cy,ca.captiondist);
     end;
    end;
    ip_bottom,ip_bottomleft,ip_bottomright: begin
     if textflags * [tf_bottom,tf_ycentered] = [] then begin
      inc(rect1.y,ca.captiondist);
     end;
     dec(rect1.cy,ca.captiondist);
    end;
    else;
   end;
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
 pos1: imageposty;
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
   pos1:= info.ca.imagepos;
   if info.ca.imagelist = nil then begin
    if tf_right in ca.textflags then begin
     pos1:= ip_right;
    end
    else begin
     if (tf_left in ca.textflags) or
                (info.ca.textflags * [tf_xcentered,tf_xjustify] = []) then begin
      pos1:= ip_left;
     end
     else begin
      if tf_bottom in info.ca.textflags then begin
       pos1:= ip_bottom;
      end
      else begin
       if (tf_top in info.ca.textflags) or
                        (info.ca.textflags * [tf_ycentered] = []) then begin
        pos1:= ip_top;
       end;
      end;
     end;
    end;
   end;
   drawbuttoncaption(canvas,info,rect1,pos1,nil);
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
   rect1:= adjustimagerect(acanvas,ainfo,rect2,align1);
   if colorglyph <> cl_none then begin
    imagelist.paint(acanvas,imagenr,rect1,align1,colorglyph);
   end;
  end;
  case imagepos of
   ip_left{,ip_leftcenter}: begin
    inc(rect2.x,captiondist);
    dec(rect2.cx,captiondist);
   end;
   ip_right{,ip_rightcenter}: begin
    dec(rect2.cx,captiondist);
   end;
   ip_top{,ip_topcenter}: begin
    inc(rect2.y,captiondist);
    dec(rect2.cy,captiondist);
   end;
   ip_bottom{,ip_bottomcenter}: begin
    dec(rect2.cy,captiondist);
   end;
   else; // Added to make compiler happy
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

function calccaptionsize(const acanvas: tcanvas;
         const ainfo: captioninfoty; const captionframe: pframety = nil): sizety;
var
 int1: integer;
 vertdist: boolean;
begin
 with ainfo do begin
  result:= textrect(acanvas,caption,textflags,font).size;
  if captionframe <> nil then begin
   with captionframe^ do begin
    result.cx:= result.cx + left + right;
    result.cy:= result.cy + top + bottom;
   end;
  end;
  vertdist:= imagepos in vertimagepos;
  if vertdist then begin
   inc(result.cy,captiondist);
  end
  else begin
   inc(result.cx,captiondist);
  end;
  if imagelist <> nil then begin
   with imagelist do begin
    if vertdist then begin
     int1:= width  + imagedist1 + imagedist2;
     if int1 > result.cx then begin
      result.cx:= int1;
     end;
     int1:= height + imagedist;
     if imagepos = ip_centervert then begin
      int1:= int1 + imagedist;
      if int1 > result.cx then begin
       result.cy:= int1;
      end;
     end
     else begin
      result.cy:= result.cy + int1;
     end;
    end
    else begin
     int1:= height  + imagedist1 + imagedist2;
     if int1 > result.cy then begin
      result.cy:= int1;
     end;
     int1:= width + imagedist;
     if imagepos = ip_center then begin
      int1:= int1 + imagedist;
      if int1 > result.cx then begin
       result.cx:= int1;
      end;
     end
     else begin
      result.cx:= result.cx + int1;
     end;
    end;
   end;
  end;
 end;
end;

procedure drawtoolbutton(const canvas: tcanvas; var info: shapeinfoty);
var
 rect1: rectty;
 frame1: framety;
 co0,co1,co2,co3: colorty;
begin
 if not (shs_invisible in info.state) then begin
//  frameskinoptionstoshapestate(info.frame,info);
  if info.frame <> nil then begin
   frameskinoptionstoshapestate(info.frame,info);
   canvas.save();
   co1:= info.color;
   co2:= info.coloractive;
   co3:= tframe1(info.frame).actualcolorclient;
   if shs_active in info.state then begin
    co0:= co2;
    info.coloractive:= cl_transparent;
   end
   else begin
    co0:= co1;
    info.color:= cl_transparent;
   end;
   if co0 <> cl_transparent then begin
    if co3 = cl_transparent then begin
     tframe1(info.frame).fi.colorclient:= co0;
    end;
   end;
   info.frame.paintbackground(canvas,info.ca.dim,true,false);
   frame1:= info.frame.paintframe;
   if not (fso_noinnerrect in info.frame.optionsskin) then begin
    addframe1(frame1,info.frame.frameo);
   end;
   {
   if not (fso_noinnerrect in info.frame.optionsskin) then begin
    frame1:= info.frame.innerframe;
   end
   else begin
    frame1:= info.frame.paintframe;
   end;
   }
   deflaterect1(info.ca.dim,frame1);
  end;
  if drawbuttonframe(canvas,info,rect1) then begin
   info.ca.imagepos:= ip_center;
   drawbuttonimage(canvas,info,rect1{,cp_center});
  end;
  if info.frame <> nil then begin
   canvas.restore();
   inflaterect1(info.ca.dim,frame1);
   info.frame.paintoverlay(canvas,info.ca.dim);
   if co3 = cl_transparent then begin
    info.color:= co1;
    info.coloractive:= co2;
    tframe1(info.frame).fi.colorclient:= co3;
   end;
  end;
 end;
end;

function drawbuttoncheckbox(const canvas: tcanvas; const info: shapeinfoty;
              var arect: rectty; const pos: imageposty = ip_left): boolean;
var
 rect1,rect2: rectty;
 align1: alignmentsty;
 int1: integer;
 co1: colorty;
 framestates: framestateflagsty;
 size1: sizety;
 widthextend: int32;
begin
 framestates:= [];
 result:= [shs_checkbox,shs_radiobutton] * info.state <> [];
 if result then begin
  rect1:= arect;
  int1:= menucheckboxheight;
  widthextend:= menucheckboxwidth;
  if info.checkboxframe <> nil then begin
   with info.checkboxframe do begin
    if fso_flat in optionsskin then begin
     dec(int1,2);
     dec(widthextend,2);
    end;
    size1:= innerframedim;
    widthextend:= widthextend + frameo_left + frameo_right + size1.cx;
    int1:= int1 + size1.cy + frameo_top + frameo_bottom;
   end;
  end;
  rect1.cx:= widthextend;
  if int1 < arect.cy then begin
   rect1.cy:= int1;
   rect1.y:= rect1.y + (arect.cy - int1) div 2;
  end;
  if pos <> ip_left then begin
   inc(rect1.x,arect.cx-rect1.cx);
  end;
  if info.checkboxframe <> nil then begin
   framestates:= combineframestateflags(info.state);
   deflaterect1(rect1,info.checkboxframe.frameo);
   info.checkboxframe.paintbackgroundframe(canvas,rect1,framestates);
   rect2:= deflaterect(rect1,info.checkboxframe.innerframe);
  end
  else begin
   rect2:= rect1;
  end;
  if (info.checkboxframe = nil) or
               not (fso_flat in info.checkboxframe.optionsskin) then begin
   draw3dframe(canvas,rect2,-1,defaultframecolors.edges,[]);
  end;
  if pos = ip_left then begin
   inc(arect.x,widthextend);
  end;
  dec(arect.cx,widthextend);
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
   co1:= info.ca.colorglyph;
   if (info.checkboxframe <> nil) and
           (info.checkboxframe.colorglyph <> cl_default) then begin
    co1:= info.checkboxframe.colorglyph;
   end;
   stockobjects.glyphs.paint(canvas,int1,rect2,align1,co1);
  end;
  if info.checkboxframe <> nil then begin
   info.checkboxframe.paintoverlayframe(canvas,rect1,framestates);
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
 rect1,rect2,rect3: rectty;
 pos1: imageposty;
 frame1: framety;
 edges1: edgesty;

begin
 with canvas,info do begin
  if not (shs_invisible in state) then begin
   if frame <> nil then begin
    //todo: optimize, move settings to tcustomstepframe updatestate
    rect3:= ca.dim;
    if not (fso_noinnerrect in frame.optionsskin) then begin
     deflaterect1(ca.dim,frame.frameo);
    end;
    canvas.save;
    frame.paintbackground(canvas,info.ca.dim,true,false);
    frame1:= frame.paintframe;
    deflaterect1(ca.dim,frame1);
    frameskinoptionstoshapestate(frame,info);
   end;
   if shs_opposite in state then begin
    if shs_vert in state then begin
     edges1:= [edg_left];
    end
    else begin
     edges1:= [edg_top];
    end;
   end
   else begin
    if shs_vert in state then begin
     edges1:= [edg_right];
    end
    else begin
     edges1:= [edg_bottom];
    end;
   end;
   if drawbuttonframe(canvas,info,rect1,edges1) then begin
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
    canvas.restore();
    inflaterect1(info.ca.dim,frame1);
    frame.paintoverlay(canvas,info.ca.dim);
    ca.dim:= rect3;
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
