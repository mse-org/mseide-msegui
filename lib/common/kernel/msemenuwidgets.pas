{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemenuwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msewidgets,mseshapes,msemenus,msegraphutils,msegraphics,msetypes,
 msegui,mseguiglob,mseevent,mseclasses;

type
 menucellinfoty = record
  buttoninfo: shapeinfoty;
 end;
 menucellinfoarty = array of menucellinfoty;

 menulayoutoptionty = (mlo_horz,mlo_keymode,mlo_main,mlo_childreninactive);
 menulayoutoptionsty = set of menulayoutoptionty;

 menulayoutinfoty = record
  menu: tmenuitem;
  activeitem: integer;
  popupdirection: graphicdirectionty;
  mousepos: pointty;
  options: menulayoutoptionsty;
  size: sizety;
  cells: menucellinfoarty;
  colorglyph: colorty;
  itemframetemplate: tframetemplate;
  itemface: tcustomface;
 end;

 ppopupmenuwidget = ^tpopupmenuwidget;
 tpopupmenuwidget = class(tpopupwidget)
  private
   flayout: menulayoutinfoty;
   fnextpopup,fprevpopup: tpopupmenuwidget;
   fposrect: rectty;
   fposition: graphicdirectionty;
   factposition: graphicdirectionty;
   finstancepo: pobject;
   frefpos: pointty;
   fselecteditem: tmenuitem;
   ftemplates: menutemplatety;
   fmenucomp: tcustommenu;
   procedure internalsetactiveitem(const avalue: integer;
           const aclicked: boolean; const force: boolean); virtual;
   procedure setactiveitem(const value: integer);
   procedure applicationactivechanged(const avalue: boolean);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   function translatetoscreen(const value: pointty): pointty; virtual;
   procedure updatelayout; virtual;
   procedure nextpopupshowing; virtual;
   function isinpopuparea(const apos: pointty): boolean; virtual;
   function checkprevpopuparea(const apos: pointty): boolean; virtual;
   procedure activatemenu(keymode: boolean; aclicked: boolean); virtual;
   procedure deactivatemenu; virtual;
   procedure selectmenu; virtual;
   function rootpopup: tpopupmenuwidget;
   procedure closepopupstack(aselecteditem: tmenuitem);
   procedure updatepos; virtual;
   procedure beginkeymode;
   procedure dopaint(const canvas: tcanvas); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure childdeactivated(const sender: tpopupmenuwidget); virtual;
   procedure fontchanged; override;
   procedure internalcreateframe; override;
  public
   constructor create(instance: ppopupmenuwidget;
       const amenu: tmenuitem; const transientfor: twindow;
       const aowner: twidget = nil; const menucomp: tcustommenu = nil);
   destructor destroy; override;
   procedure menuchanged(const sender: tmenuitem);
   procedure release; override;
   procedure updatetemplates;
   procedure assigntemplate(const source: menutemplatety); virtual;
   function showmenu(const aposrect: rectty; aposition: graphicdirectionty;
                              aactivate: boolean): tmenuitem;
                    //returns selected item, nil if none
   property activeitem: integer read flayout.activeitem write setactiveitem;
 end;

 tmainmenuwidget = class(tpopupmenuwidget)
  private
   factivewindowbefore: twindow;
   fstackedoverbefore: twindow;
   procedure internalsetactiveitem(const Value: integer;
           const aclicked: boolean; const force: boolean); override;
  protected
   procedure nextpopupshowing; override;
   procedure clientrectchanged; override;
   procedure updatelayout; override;
   procedure updatepos; override;
   function isinpopuparea(const apos: pointty): boolean; override;
   function checkprevpopuparea(const apos: pointty): boolean; override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure childdeactivated(const sender: tpopupmenuwidget); override;
   procedure activatemenu(keymode: boolean; aclicked: boolean); override;
   procedure deactivatemenu; override;
   procedure selectmenu; override;
   procedure internalcreateframe; override;
  public
   procedure loaded; override;
   procedure release; override;
   constructor create(const aowner: twidget; const amenu: tmenuitem); overload;
   constructor create(const aowner: twidget; const amenu: tmainmenu); overload;
 end;

 mainmenupainterstatety = (mmps_layoutvalid);
 mainmenupainterstatesty = set of mainmenupainterstatety;

 setmainmenuinstanceprocty = procedure(const value: tmainmenu) of object;

function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                 const pos: rectty; const dir: graphicdirectionty;
                 const menucomp: tcustommenu = nil): tmenuitem; overload;
function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                  const pos: graphicdirectionty;
                  const menucomp: tcustommenu = nil): tmenuitem; overload;
function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                  const pos: pointty;
                  const menucomp: tcustommenu = nil): tmenuitem; overload;
                                          {
function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                                          var mouseinfo: mouseeventinfoty): tmenuitem; overload;
                                          }
implementation
uses
 msedrawtext,mserichstring,msestockobjects,sysutils,msekeyboard,msebits,
 mseactions,classes,mseguiintf;

type
 tmenuitem1 = class(tmenuitem);
 twidget1 = class(twidget);
// tcustomframe1 = class(tcustomframe);
 twindow1 = class(twindow);
 tmsecomponent1 = class(tmsecomponent);
 tframetemplate1 = class(tframetemplate);
 tcustomframe1 = class(tcustomframe);

function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                 const pos: rectty; const dir: graphicdirectionty;
                 const menucomp: tcustommenu = nil): tmenuitem; overload;
var
 widget: tpopupmenuwidget;
begin
 if menu.canshow then begin
//  tmenuitem1(menu).ftransientfor:= transientfor;
  tpopupmenuwidget.create(@widget,menu,transientfor.window,nil,menucomp);
  try
   result:= widget.showmenu(pos,dir,true);
  finally
   widget.Free;
//   tmenuitem1(menu).ftransientfor:= nil;
  end;
 end
 else begin
  result:= nil;
 end;
end;

function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                           const pos: graphicdirectionty;
                           const menucomp: tcustommenu = nil): tmenuitem;
begin
 result:= showpopupmenu(menu,transientfor,
      makerect(transientfor.screenpos,transientfor.size),pos,menucomp);
end;

function showpopupmenu(const menu: tmenuitem; const transientfor: twidget;
                       const pos: pointty;
                       const menucomp: tcustommenu = nil): tmenuitem; overload;
begin
 result:= showpopupmenu(menu,transientfor,
             makerect(translateclientpoint(pos,transientfor,nil),nullsize),
             gd_right,menucomp);
end;

procedure initlayoutinfo(const aowner: tmsecomponent;
        var info: menulayoutinfoty; const amenu: tmenuitem;
        const aoptions: menulayoutoptionsty; const acolorglyph: colorty);
begin
 with info do begin
  cells:= nil;
  fillchar(info,sizeof(info),0);
  tmsecomponent1(aowner).getobjectlinker.setlinkedvar(ievent(aowner),amenu,tlinkedpersistent(menu));
  activeitem:= -1;
  options:= aoptions;
  colorglyph:= acolorglyph;
 end;
end;

procedure movemenulayout(var layout: menulayoutinfoty; const dist: pointty);
var
 int1: integer;
begin
 with layout do begin
  for int1:= 0 to high(cells) do begin
   with cells[int1].buttoninfo.dim.pos do begin
    x:= x + dist.x;
    y:= y + dist.y;
   end;
  end;
 end;
end;

procedure calcmenulayout(var layout: menulayoutinfoty; const canvas: tcanvas;
                              const maxsize: integer = bigint);
var
 int1,int2: integer;
 ay,ax: integer;
 atextsize: sizety;
 maxheight: integer;
 textwidth: integer;
 item1: tmenuitem1;
 hassubmenu: boolean;
 hascheckbox: boolean;
 shift,regioncount: integer;
 amax: integer;
 frame1: framety;
 framehalfwidth: integer;
 framewidth1: integer;
 
begin
 with layout,tmenuitem1(menu) do begin
  if itemframetemplate <> nil then begin
   with tframetemplate1(itemframetemplate) do begin
    framehalfwidth:= (abs(levelo) + abs(leveli) + framewidth);
    framewidth1:= framehalfwidth * 2;
    frame1:= fi.innerframe;
   end;
  end
  else begin
   framehalfwidth:= 0;
   framewidth1:= 0;
   frame1:= nullframe;
  end; 
  setlength(cells,count);
  maxheight:= 0;
  ay:= framehalfwidth;
  ax:= framehalfwidth;
  textwidth:= 0;
  hassubmenu:= false;
  hascheckbox:= false;
  for int1:= 0 to count - 1 do begin
   with cells[int1].buttoninfo do begin
    item1:= tmenuitem1(fsubmenu[int1]);
    imagelist:= item1.finfo.imagelist;
    font:= item1.font;
    atextsize:= textrect(canvas,item1.finfo.caption1,[],font).size;
    atextsize.cx:= atextsize.cx + frame1.left + frame1.right;
    atextsize.cy:= atextsize.cy + frame1.top + frame1.bottom;
    inc(atextsize.cy,2); //for 3D level
    if imagelist <> nil then begin
     atextsize.cx:= atextsize.cx + imagelist.width;
     if atextsize.cy < imagelist.height then begin
      atextsize.cy:= imagelist.height;
     end;
    end;
    if atextsize.cy > maxheight then begin
     maxheight:= atextsize.cy;
    end;
    if atextsize.cx > textwidth then begin
     textwidth:= atextsize.cx;
    end;
    colorglyph:= layout.colorglyph;
    caption:= item1.finfo.caption1;
    imagenr:= item1.finfo.imagenr;
    actionstatestoshapestates(item1.finfo,state);
    color:= cl_transparent;
    include(state,ss_flat);
    if mlo_horz in layout.options then begin
     include(state,ss_horz);
    end
    else begin
     exclude(state,ss_horz);
    end;
    if item1.count > 0 then begin
     include(state,ss_submenu);
    end
    else begin
     exclude(state,ss_submenu);
    end;
    if not (ss_invisible in state) then begin
     hassubmenu:= hassubmenu or (ss_submenu in state);
     hascheckbox:= hascheckbox or (ss_checkbox in state);
     with dim do begin
      if mlo_horz in layout.options then begin
       if ss_separator in state then begin
        cx:= 2;
       end
       else begin
        cx:= atextsize.cx + 4;
       end;
       x:= ax;
       y:= ay;
       inc(ax,cx+framewidth1);
      end
      else begin
       y:= ay;
       if ss_separator in state then begin
        cy:= 2;
       end
       else begin
        cy:= atextsize.cy;
       end;
       inc(ay,cy+framewidth1);
      end;
     end;
    end
    else begin
     dim:= nullrect;
    end;
   end;
  end;
  if not (as_invisible in state) then begin
   shift:= 0;
   regioncount:= 1;
   if mlo_horz in layout.options then begin
    if mao_singleregion in layout.menu.options then begin
     amax:= bigint;
    end
    else begin
     amax:= maxsize;
    end;
    for int1:= 0 to count - 1 do begin
     with cells[int1].buttoninfo do begin
      if not (ss_invisible in state) then begin
       dim.x:= dim.x + shift;
       if dim.x + dim.cx + framewidth1 > amax then begin
        shift:= shift - dim.x + framehalfwidth;
        dim.x:= framehalfwidth;
        inc(regioncount);
       end;
       dim.y:= framehalfwidth + (maxheight+framewidth1) * (regioncount - 1);
       dim.cy:= maxheight;
      end;
     end;
    end;
    size.cx:= ax;
    size.cy:= regioncount * (maxheight + framewidth1);
   end
   else begin
    if mao_singleregion in layout.menu.options then begin
     amax:= bigint;
    end
    else begin
     amax:= maxsize;
    end;
    ax:= framehalfwidth;
    textwidth:= textwidth + 4;
    if hassubmenu then begin
     textwidth:= textwidth + menuarrowwidth;
    end;
    if hascheckbox then begin
     textwidth:= textwidth + menucheckboxwidth;
    end;
    maxheight:= 0;
    for int1:= 0 to count - 1 do begin
     with cells[int1].buttoninfo.dim do begin
      y:= y + shift;
      int2:= y + cy  + framewidth1;
      if int2 > amax then begin
       shift:= shift - y + framehalfwidth;
       y:= framehalfwidth;
       ax:= ax + textwidth + framewidth1;
       inc(regioncount);
      end
      else begin
       if int2 > maxheight then begin
        maxheight:= int2;
       end;
      end;
      x:= ax;
      cx:= textwidth;
     end;
    end;
    size.cx:=  regioncount * (textwidth  + framewidth1);
    size.cy:= maxheight - framehalfwidth;
   end;
  end
  else begin
   size:= nullsize;
  end;
 end;
end;

function getcellatpos(const info: menulayoutinfoty; const pos: pointty): integer;
var
 int1: integer;
begin
 result:= -1;
 with info do begin
  for int1:= 0 to high(cells) do begin
   with cells[int1].buttoninfo do begin
    if (state * [ss_disabled,ss_invisible,ss_separator] = []) and
               pointinrect(pos,dim) then begin
     result:= int1;
     break;
    end;
   end;
  end;
 end;
end;

procedure drawmenu(const canvas: tcanvas; const layout: menulayoutinfoty);
var
 int1: integer;
 po1: pframety;
begin
 with layout do begin
  if itemframetemplate <> nil then begin
   po1:= @tframetemplate1(itemframetemplate).fi.innerframe;
  end
  else begin
   po1:= nil;
  end; 
  for int1:= 0 to high(cells) do begin
   with cells[int1] do begin
    if itemframetemplate <> nil then begin
     itemframetemplate.draw3dframe(canvas,buttoninfo.dim);
    end;
    buttoninfo.face:= itemface;
    drawmenubutton(canvas,buttoninfo,po1);
   end;
  end;
 end;
end;

function prevmenuitem(const info: menulayoutinfoty): integer;
begin
 with info do begin
  result:= activeitem;
  repeat
   dec(result);
   if result < 0 then begin
    result:= menu.count - 1;
   end;
  until menu[result].canactivate or (result = activeitem);
 end;
end;

function nextmenuitem(const info: menulayoutinfoty): integer;
begin
 with info do begin
  if menu.count = 0 then begin
   result:= -1;
  end
  else begin
   result:= activeitem;
   repeat
    inc(result);
    if result >= menu.count then begin
     if activeitem = -1 then begin
      result:= -1;
      break;
     end
     else begin
      result:= 0;
     end;
    end;
   until menu[result].canactivate or (result = activeitem);
  end;
 end;
end;

function checkshortcut(const layout: menulayoutinfoty; var info: keyeventinfoty;
                                  out multiple: boolean;
           actualindex: integer = -1): integer;

 function getshortcut(actualindex: integer): integer;
 var
  int1: integer;
 begin
  result:= -1;
  inc(actualindex);
  if actualindex >= length(layout.cells) then begin
   actualindex:= 0;
  end;
  int1:= actualindex;
  repeat
   with layout.cells[actualindex].buttoninfo do begin
    if (state * [ss_disabled,ss_invisible] = []) and
            mserichstring.checkshortcut(info,caption,false) then begin
     result:= actualindex;
     include(info.eventstate,es_processed);
     break;
    end;
   end;
   inc(actualindex);
   if actualindex >= length(layout.cells) then begin
    actualindex:= 0;
   end;
  until actualindex = int1;
 end;

begin
 result:= -1;
 multiple:= false;
 if length(layout.cells) > 0 then begin
  result:= getshortcut(actualindex);
  if result >= 0 then begin
   exclude(info.eventstate,es_processed);
   multiple:= getshortcut(result) <> result;
  end;
 end;
end;

{ tpopupmenuwidget }

constructor tpopupmenuwidget.create(instance: ppopupmenuwidget; const amenu: tmenuitem;
         const transientfor: twindow;
         const aowner: twidget = nil; const menucomp: tcustommenu = nil);
begin
 finstancepo:= pobject(instance);
 fmenucomp:= menucomp;
 if finstancepo <> nil then begin
  instance^:= self;
 end;
 initlayoutinfo(self,flayout,amenu,[],cl_black);
 inherited create(aowner,transientfor);
 internalcreateframe;
 if menucomp <> nil then begin
  assigntemplate(menucomp.template);
 end
 else begin
  if (transientfor <> nil) and (transientfor.owner is tpopupmenuwidget) then begin
   assigntemplate(tpopupmenuwidget(transientfor.owner).ftemplates);
  end;
 end;
 application.registeronapplicationactivechanged(
           {$ifdef FPC}@{$endif}applicationactivechanged);
end;

destructor tpopupmenuwidget.destroy;
begin
 application.unregisteronapplicationactivechanged(
           {$ifdef FPC}@{$endif}applicationactivechanged);
 if finstancepo <> nil then begin
  finstancepo^:= nil;
 end;
 if flayout.menu <> nil then begin
  flayout.menu.onchange:= nil;
 end;
 freeandnil(fnextpopup);
 inherited;
 flayout.itemface.free;
end;

procedure tpopupmenuwidget.release;
begin
 if finstancepo <> nil then begin
  finstancepo^:= nil;
 end;
 finstancepo:= nil;
 fprevpopup:= nil;
 inherited;
end;

procedure tpopupmenuwidget.internalcreateframe;
begin
 inherited;
 tcustomframe1(fframe).fi.levelo:= 1; //do not set localprops
end;

procedure tpopupmenuwidget.updatetemplates;
begin
 with ftemplates do begin
  if frame <> nil then begin
   if fframe = nil then begin
    internalcreateframe;
   end;
   fframe.assign(frame);
  end
  else begin
   freeandnil(fframe); //restore original values
   internalcreateframe;
  end;
  if face <> nil then begin
   if fface = nil then begin
    internalcreateface;
   end;
   fface.assign(face);
  end
  else begin
   freeandnil(fface);
  end;
  if itemframe <> nil then begin
   flayout.itemframetemplate:= itemframe.template;
  end
  else begin
   flayout.itemframetemplate:= nil;
  end;
  if itemface <> nil then begin
   if flayout.itemface = nil then begin
    flayout.itemface:= tcustomface.create(iface(self));
   end;
   flayout.itemface.assign(itemface.template);
  end
  else begin
   freeandnil(flayout.itemface);
  end;
  updatelayout;
 end;
end;

procedure tpopupmenuwidget.assigntemplate(const source: menutemplatety);
begin
 setlinkedvar(source.frame,tmsecomponent(ftemplates.frame));
 setlinkedvar(source.face,tmsecomponent(ftemplates.face));
 setlinkedvar(source.itemframe,tmsecomponent(ftemplates.itemframe));
 setlinkedvar(source.itemface,tmsecomponent(ftemplates.itemface));
 updatetemplates; 
end;

function tpopupmenuwidget.translatetoscreen(const value: pointty): pointty;
begin
 result:= translateclientpoint(value,self,nil);
end;

procedure tpopupmenuwidget.updatepos;
var
 rect1: rectty;
 workarea: rectty;
 int1: integer;
begin
 rect1.size:= addsize(flayout.size,innerclientframewidth);
 workarea:= application.workarea(self.window);
 factposition:= fposition;
 int1:= 0;
 with fposrect do begin
  repeat
   case factposition of
    gd_right: begin
     rect1.pos:= makepoint(x + cx, y);
     with rect1 do begin
      if (int1 = 0) and (x + cx > workarea.x + workarea.cx) then begin
       factposition:= gd_left;
      end
      else begin
       inc(int1);
      end;
     end;
    end;
    gd_up: begin
     rect1.pos:= makepoint(x, y-rect1.cy);
     with rect1 do begin
      if (int1 = 0) and (y < workarea.y) then begin
       factposition:= gd_down;
      end
      else begin
       inc(int1);
      end;
     end;
    end;
    gd_left: begin
     rect1.pos:= makepoint(x-rect1.cx,y);
     with rect1 do begin
      if (int1 = 0) and (x < workarea.x) then begin
       factposition:= gd_right;
      end
      else begin
       inc(int1);
      end;
     end;
    end;
    gd_down: begin
     rect1.pos:= makepoint(x,y+cy);
     with rect1 do begin
      if (int1 = 0) and (y + cy > workarea.y + workarea.cy) then begin
       factposition:= gd_up;
      end
      else begin
       inc(int1);
      end;
     end;
    end;
   end;
   inc(int1);
  until int1 >= 2;
 end;
 shiftinrect(rect1,workarea);
 setwidgetrect(rect1);
end;

procedure tpopupmenuwidget.updatelayout;
begin
 flayout.popupdirection:= gd_right;
 calcmenulayout(flayout,getcanvas,application.screensize.cy-innerclientframewidth.cy);
 movemenulayout(flayout,innerclientrect.pos);            
 updatepos;
end;

procedure tpopupmenuwidget.nextpopupshowing;
begin
 //dummy;
end;

function tpopupmenuwidget.showmenu(const aposrect: rectty;
                 aposition: graphicdirectionty; aactivate: boolean): tmenuitem;
var
 transientforwindow: twindow;
begin
 result:= nil;
 flayout.menu.doupdate;
 flayout.menu.onchange:= {$ifdef FPC}@{$endif}menuchanged;
 fposrect:= aposrect;
 fposition:= aposition;
 updatelayout;
 if fprevpopup <> nil then begin
  frefpos:= fprevpopup.screenpos;
  fprevpopup.window.registermovenotification(ievent(self));
 end;
 if fprevpopup <> nil then begin
  transientforwindow:= fprevpopup.window;
 end
 else begin
  transientforwindow:= application.activewindow;
 end;
 if aactivate and (flayout.activeitem < 0) then begin
  setactiveitem(nextmenuitem(flayout));
  if flayout.activeitem < 0 then begin
   exit;
  end;
 end;
 show(aactivate,transientforwindow);
 if aactivate then begin
  result:= fselecteditem;
  if fprevpopup = nil then begin
   flayout.menu.owner.checkexec;
  end;
 end;
end;

procedure tpopupmenuwidget.menuchanged(const sender: tmenuitem);
begin
 updatelayout;
end;

procedure tpopupmenuwidget.dopaint(const canvas: tcanvas);
begin
 inherited;
 canvas.move(clientpos);
 drawmenu(canvas,flayout);
end;

function tpopupmenuwidget.isinpopuparea(const apos: pointty): boolean;
begin
 result:= pointinrect(apos,fwidgetrect);
end;

function tpopupmenuwidget.checkprevpopuparea(const apos: pointty): boolean;
begin
 result:= false;
 if not pointinrect(apos,fwidgetrect) then begin
  if fprevpopup <> nil then begin
   result:= fprevpopup.isinpopuparea(apos);
  end;
  if result then begin
   deactivatemenu;
  end;
 end;
end;

procedure tpopupmenuwidget.mouseevent(var info: mouseeventinfoty);
var
 bo1: boolean;
 po1: pointty;
begin
 with info,flayout do begin
  po1:= translatetoscreen(pos);
  if (mlo_keymode in options) and
   (eventkind in [ek_mousemove,ek_buttonpress,ek_buttonrelease,ek_mousepark]) then begin
   if (distance(po1,mousepos) <= 3) and
      (eventkind in [ek_mousemove,ek_mousepark]) then begin
    exit;
   end
   else begin
    exclude(options,mlo_keymode);
   end;
  end;
  if (eventkind = ek_mousemove) and (fnextpopup <> nil) and
         pointinrect(po1,fnextpopup.fwidgetrect) and 
                             not (mlo_childreninactive in options) then begin
   fnextpopup.activatemenu(false,ss_left in info.shiftstate);
   exit;
  end;
  if eventkind in mouseposevents then begin
   if not checkprevpopuparea(translatetoscreen(pos)) then begin
    if pointinrect(pos,paintrect) then begin
     internalsetactiveitem(getcellatpos(flayout,
      subpoint(pos,paintrect.pos)),
                       ss_left in info.shiftstate,false);
    end
    else begin
     if eventkind = ek_buttonpress then begin
      closepopupstack(nil);
      exit;
     end;
    end;
   end;
  end;
  case eventkind of
   ek_buttonpress: begin
    if (activeitem >= 0) and (button = mb_left) then begin
     if mlo_childreninactive in options then begin
      exclude(options,mlo_childreninactive);
      activeitem:= -1;
      mouseevent(info);
      exit;
     end;
     with cells[activeitem].buttoninfo do begin
      include(state,ss_clicked);
      invalidaterect(dim);
     end;
    end;
   end;
   ek_buttonrelease: begin
    if (activeitem >= 0) and (button = mb_left) then begin
     with cells[activeitem].buttoninfo do begin
      bo1:= ss_clicked in state;
      exclude(state,ss_clicked);
      invalidaterect(dim);
      if bo1 then begin
       selectmenu;
      end;
     end;
    end;
   end;
   ek_clientmouseleave: begin
    if (fnextpopup = nil) then begin
     setactiveitem(-1);
    end
    else begin
     if activeitem >= 0 then begin
      subpoint1(info.pos,clientpos);
      updatemouseshapestate(cells[activeitem].buttoninfo,info,self);
      include (cells[activeitem].buttoninfo.state,ss_mouse);
     end;
    end;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tpopupmenuwidget.internalsetactiveitem(const avalue: integer;
          const aclicked: boolean; const force: boolean);
//var
// bo1: boolean;
begin
 with flayout do begin
  if (activeitem <> avalue) or force then begin
//   bo1:= activeitem >= 0;
   if activeitem >= 0 then begin
    if (fnextpopup <> nil) then begin
     fnextpopup.release;
    end;
    with cells[activeitem].buttoninfo do begin
     state:= state - [ss_clicked,ss_mouse];
     invalidaterect(dim);
    end;
   end;
   activeitem:= avalue;
   if activeitem >= 0 then begin
    if not menu[avalue].canactivate then begin
     activeitem:= nextmenuitem(flayout);
    end;
    with cells[activeitem].buttoninfo do begin
     state:= state + [ss_mouse];
     if aclicked then begin
      include(state,ss_clicked);
     end;
     invalidaterect(dim);
     if not (mlo_childreninactive in options) and
              (tmenuitem1(menu).fsubmenu[activeitem].count > 0) then begin
      tpopupmenuwidget.create(@fnextpopup,tmenuitem1(menu).fsubmenu[activeitem],
                                fwindow);
      fnextpopup.fprevpopup:= self;
      nextpopupshowing;
      fnextpopup.showmenu(makerect(translatetoscreen(dim.pos),dim.size),
               popupdirection,false);
      fnextpopup.beginkeymode;
     end;
    end;
    capturemouse;
//    if not bo1 then begin
     if not (not canfocus or setfocus(application.activewindow <> nil) or 
                      not(mlo_main in options)) then begin
      closepopupstack(nil);
     end;
//    end;
   end
   else begin
    if mlo_main in options then begin
     include(options,mlo_childreninactive);
     releasemouse;
    end;
   end;
  end;
 end;
end;

procedure tpopupmenuwidget.setactiveitem(const value: integer);
begin
 internalsetactiveitem(value,false,false);
end;

procedure tpopupmenuwidget.activatemenu(keymode: boolean; aclicked: boolean);
begin
 if keymode then begin
  beginkeymode;
 end
 else begin
  exclude(flayout.options,mlo_keymode);
 end;
 if (flayout.menu.count > 0) and (flayout.activeitem < 0) then begin
  internalsetactiveitem(0,aclicked,true);
  if (show(true,nil) <> mr_windowdestroyed) and (fprevpopup = nil) then begin
   flayout.menu.owner.checkexec;
  end;
 end;
end;

procedure tpopupmenuwidget.childdeactivated(const sender: tpopupmenuwidget);
begin
 capturemouse;
end;

procedure tpopupmenuwidget.deactivatemenu;
begin
 setactiveitem(-1);
 window.endmodal;
 if fprevpopup <> nil then begin
  fprevpopup.childdeactivated(self);
 end;
end;

procedure tpopupmenuwidget.selectmenu;
var
 int1: integer;
begin
 with flayout do begin
  if mlo_childreninactive in options then begin
   exclude(options,mlo_childreninactive);
   internalsetactiveitem(activeitem,false,true);
  end;
 end;
 if fnextpopup <> nil then begin
  fnextpopup.activatemenu(true,false);
 end
 else begin
  with flayout do begin
   if activeitem >= 0 then begin
    int1:= activeitem;
    with menu[int1] do begin
     if (mao_asyncexecute in options) then begin
      closepopupstack(menu[int1]);
      asyncexecute;
     end
     else begin
      releasemouse;
      execute;
      closepopupstack(menu[int1]);
     end;
    end;
   end;
  end;
 end;
end;

function tpopupmenuwidget.rootpopup: tpopupmenuwidget;
begin
 result:= self;
 while result.fprevpopup <> nil do begin
  result:= result.fprevpopup;
 end;
end;

procedure tpopupmenuwidget.beginkeymode;
begin
 include(flayout.options,mlo_keymode);
 flayout.mousepos:= application.mouse.pos;
end;

procedure tpopupmenuwidget.dokeydown(var info: keyeventinfoty);

 procedure checkshortcut(widget: tpopupmenuwidget);
 var
  int1: integer;
  bo1: boolean;
 begin
  if widget <> nil then begin
   with widget do begin
    int1:= msemenuwidgets.checkshortcut(flayout,info,bo1,flayout.activeitem);
    if int1 >= 0 then begin
     setactiveitem(int1);
     beginkeymode;
     if not bo1 then begin
      selectmenu;
     end;
    end;
   end;
  end;
 end;

 procedure swapkeys;
 begin
  if mlo_horz in flayout.options then begin
   with info do begin
    case key of
     key_right: key:= key_down;
     key_up: key:= key_left;
     key_left: key:= key_up;
     key_down: key:= key_right;
    end;
   end;
  end;
 end;

 function isup(position: graphicdirectionty): boolean;
 begin
  if mlo_horz in flayout.options then begin
   result:= (position = gd_up) xor (info.key = key_right);
  end
  else begin
   result:= (position = gd_left) xor (info.key = key_right);
  end;
 end;

begin
 with info,flayout do begin
  if (shiftstate = []) then begin
   swapkeys;
   include(eventstate,es_processed);
   beginkeymode;
   case key of
    key_return,key_space: begin
     selectmenu;
    end;
    key_up: begin
     setactiveitem(prevmenuitem(flayout));
    end;
    key_down: begin
     setactiveitem(nextmenuitem(flayout));
    end;
    key_left,key_right: begin
     if (fnextpopup <> nil) and isup(fnextpopup.factposition) then begin
      fnextpopup.activatemenu(true,false);
     end
     else begin
      exclude(options,mlo_keymode);
      if not isup(factposition) then begin
       deactivatemenu;
       if (fprevpopup <> nil) and (mlo_main in fprevpopup.flayout.options) then begin
        exclude(eventstate,es_processed);
       end;
      end
      else begin
       with rootpopup do begin
        if mlo_main in flayout.options then begin
         exclude(eventstate,es_processed);
         dokeydown(info);
         include(eventstate,es_processed);
        end;
       end;
      end;
     end;
    end;
    key_escape: begin
     beginkeymode;
     deactivatemenu;
    end
    else begin
     exclude(eventstate,es_processed);
     exclude(flayout.options,mlo_keymode);
     checkshortcut(self);                //actual popup first
     if not (es_processed in eventstate) then begin
      checkshortcut(fnextpopup);
     end;
    end;
   end;
   swapkeys;
  end
  else begin
   if shiftstate = [ss_alt] then begin //check nextpopup first
    checkshortcut(fnextpopup);
    if not (es_processed in eventstate) then begin
     checkshortcut(self);
    end;
   end;
  end;
  if not (es_processed in eventstate) and (fprevpopup <> nil) then begin
   fprevpopup.dokeydown(info);
  end;
 end;
end;

procedure tpopupmenuwidget.closepopupstack(aselecteditem: tmenuitem);
var
 widget1: tpopupmenuwidget;
begin
 widget1:= self;
 while true do begin
  widget1.window.endmodal;
  if widget1.fprevpopup <> nil then begin
   widget1:= widget1.fprevpopup;
  end
  else begin
   break;
  end;
 end;
 widget1.fselecteditem:= aselecteditem; //return value for procedure showmenu
 widget1.release;
end;

procedure tpopupmenuwidget.objectevent(const sender: tobject;
  const event: objecteventty);
var
 po1: pointty;
begin
 inherited;
 if (event = oe_changed) then begin
  if (fprevpopup <> nil) and (sender = fprevpopup.window) then begin
   po1:= fprevpopup.screenpos;
   addpoint1(fposrect.pos,subpoint(po1,frefpos));
   frefpos:= po1;
   updatepos;
  end;
  if (sender <> nil) and ((sender = ftemplates.frame) or 
                          (sender = ftemplates.face) or
                          (sender = ftemplates.itemframe) or 
                          (sender = ftemplates.itemface)) then begin
   updatetemplates; //refresh
   if not (csloading in componentstate) then begin
    updatelayout;
   end;
  end;
 end;
end;

procedure tpopupmenuwidget.fontchanged;
begin
 updatelayout;
 if fparentwidget <> nil then begin
  fparentwidget.dochildscaled(self);
 end;
end;

procedure tpopupmenuwidget.applicationactivechanged(const avalue: boolean);
begin
 if not avalue and not (mlo_main in flayout.options) and visible then begin
  closepopupstack(nil);
 end;
end;

{ tmainmenuwidget }

constructor tmainmenuwidget.create(const aowner: twidget; const amenu: tmenuitem);
begin
 inherited create(nil,amenu,nil,nil,fmenucomp);
 foptionswidget:= foptionswidget-[ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 fwidgetstate:= fwidgetstate - [ws_iswidget];
 parentwidget:= aowner;
 flayout.options:= [mlo_horz,mlo_main,mlo_childreninactive];
 flayout.popupdirection:= gd_down;
 if not (csloading in aowner.ComponentState) and not (csloading in componentstate) then begin
  updatelayout;
  visible:= true;
 end;
end;

constructor tmainmenuwidget.create(const aowner: twidget; const amenu: tmainmenu);
begin
 fmenucomp:= amenu;
 create(aowner,amenu.menu);
end;

procedure tmainmenuwidget.internalcreateframe;
begin
 inherited;
 tcustomframe1(fframe).fi.levelo:= 0; //do not set localprops
end;

procedure tmainmenuwidget.loaded;
begin
 include(fwidgetstate,ws_visible);
 inherited;
 updatelayout;
end;

procedure tmainmenuwidget.updatepos;
begin
 //dummy
end;

procedure tmainmenuwidget.updatelayout;
begin
 flayout.popupdirection:= gd_down;
 calcmenulayout(flayout,getcanvas,innerclientrect.cx);
 movemenulayout(flayout,innerclientrect.pos);
 bounds_cy:= flayout.size.cy + innerclientframewidth.cy;
end;

procedure tmainmenuwidget.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure tmainmenuwidget.nextpopupshowing;
begin
 inherited;
 if fmenucomp <> nil then begin
  fnextpopup.assigntemplate(tmainmenu(fmenucomp).popuptemplate);
 end;
end;

procedure tmainmenuwidget.release;
begin
 setactiveitem(-1);
end;

function tmainmenuwidget.isinpopuparea(const apos: pointty): boolean;
begin
 result:= pointinrect(translatewidgetpoint(apos,nil,self),fwidgetrect);
end;

function tmainmenuwidget.checkprevpopuparea(const apos: pointty): boolean;
var
 po1: pointty;
begin
 po1:= translatewidgetpoint(apos,nil,self);
 result:= inherited checkprevpopuparea(po1);
 if not result then begin
  result:= not pointinrect(po1,fwidgetrect) and
         pointinrect(po1,rootwidget.widgetrect);
  if result then begin
   capturemouse;
   release;
  end;
 end;
end;

procedure tmainmenuwidget.doshortcut(var info: keyeventinfoty;
  const sender: twidget);
begin
 inherited;
 if not (es_processed in info.eventstate) and (info.shiftstate = [ss_alt]) and
                  not(csdesigning in componentstate) and 
                  not (es_modal in info. eventstate) then begin
  dokeydown(info);
 end;
end;

procedure tmainmenuwidget.childdeactivated(const sender: tpopupmenuwidget);
begin
 inherited;
 if mlo_keymode in sender.flayout.options then begin
  deactivatemenu;
 end;
end;

procedure tmainmenuwidget.internalsetactiveitem(const Value: integer;
           const aclicked: boolean; const force: boolean);
var
 ar1: winidarty;
 ar2: integerarty;
 window1: twindow;
begin
 window1:= factivewindowbefore;
 if factivewindowbefore = nil then begin
  setlinkedvar(application.activewindow,tlinkedobject(factivewindowbefore));
 end;
 if fstackedoverbefore = nil then begin
  setlinkedvar(fwindow.stackedover,tlinkedobject(fstackedoverbefore));
 end;
 inherited;
 if value < 0 then begin
  focusback(factivewindowbefore <> nil);
  if factivewindowbefore <> fwindow then begin
   if (fstackedoverbefore <> nil) and fstackedoverbefore.visible then begin
    setlength(ar1,2);
    ar1[0]:= fstackedoverbefore.winid;
    ar1[1]:= fwindow.winid;
    gui_getzorder(ar1,ar2);
    if ar2[1] > ar2[0] then begin
     gui_stackoverwindow(fwindow.winid,fstackedoverbefore.winid);
    end;
   end;
   if (factivewindowbefore <> nil) and factivewindowbefore.visible then begin
    factivewindowbefore.activate;
   end;
  end;
  setlinkedvar(nil,tlinkedobject(factivewindowbefore));
  setlinkedvar(nil,tlinkedobject(fstackedoverbefore));
 end;
end;

procedure tmainmenuwidget.activatemenu(keymode: boolean; aclicked: boolean);
begin
 inherited;
 flayout.menu.owner.checkexec;
end;

procedure tmainmenuwidget.selectmenu;
begin
 inherited;
 flayout.menu.owner.checkexec;
end;

procedure tmainmenuwidget.deactivatemenu;
begin
 inherited;
 releasemouse;
end;

end.
