{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemenuwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,msewidgets,mseshapes,msemenus,msegraphutils,msegraphics,msetypes,
 msegui,mseglob,mseguiglob,mseevent,mseclasses;

const
 defaultpopupmenuwidgetoptions = 
      defaultoptionstoplevelwidget - [ow_tabfocus,ow_arrowfocus,ow_mousefocus];
type
 menucellinfoty = record
  buttoninfo: shapeinfoty;
  dimouter: rectty;
  fontinactive: tfont;
  fontactive: tfont;
 // coloractive: colorty;
 end;
 menucellinfoarty = array of menucellinfoty;

 menulayoutoptionty = (mlo_horz,mlo_keymode,mlo_main,mlo_childreninactive); 
                               //used for popup close by second click
 menulayoutoptionsty = set of menulayoutoptionty;

 menulayoutinfoty = record
  menu: tmenuitem;
  activeitem: integer;
  popupdirection: graphicdirectionty;
  mousepos: pointty;
  options: menulayoutoptionsty;
  sizerect: rectty;
  cells: menucellinfoarty;
//  colorglyph: colorty;
  itemframetemplate: tframetemplate;
  itemface: tcustomface;
  itemframetemplateactive: tframetemplate;
  itemfaceactive: tcustomface;
 end;

 ppopupmenuwidget = ^tpopupmenuwidget;
 tpopupmenuwidget = class(tpopupwidget)
  private
   fnextpopup,fprevpopup: tpopupmenuwidget;
   fposrect: rectty;
   fposition: graphicdirectionty;
   factposition: graphicdirectionty;
   finstancepo: pobject;
   frefpos: pointty;
   fselecteditem: tmenuitem;
   ftemplates: menutemplatety;
   fmenucomp: tcustommenu;
   fclickeditem: integer;
   procedure internalsetactiveitem(const avalue: integer;
           const aclicked: boolean; const force: boolean;
           const nochildreninactive: boolean); virtual;
   procedure setactiveitem(const value: integer);
   procedure applicationactivechanged(const avalue: boolean);
  protected
   flayout: menulayoutinfoty;
   flocalframeandface: boolean;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   function transientforwindoworwindow: twindow;
   function translatetoscreen(const value: pointty): pointty; virtual;
   procedure updatelayout; virtual;
   procedure nextpopupshowing; virtual;
   function isinpopuparea(const apos: pointty): boolean; virtual;
   function checkprevpopuparea(const apos: pointty): boolean; virtual;
   procedure activatemenu(keymode: boolean; aclicked: boolean); virtual;
   procedure deactivatemenu; virtual;
   procedure selectmenu(const keymode: boolean); virtual;
   function rootpopup: tpopupmenuwidget;
   procedure closepopupstack(aselecteditem: tmenuitem;
                               const cancelmodal: boolean = false);
   procedure updatepos; virtual;
   procedure beginkeymode;
   procedure dopaint(const canvas: tcanvas); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure childdeactivated(const sender: tpopupmenuwidget); virtual;
   procedure fontchanged; override;
   procedure internalcreateframe; override;
   function activateoptionset: boolean;
   procedure showhint(var info: hintinfoty); override;   
   function trycancelmodal(const newactive: twindow): boolean; override;
   
   procedure release(const acancelmodal: boolean); overload; virtual;
  public
   constructor create(instance: ppopupmenuwidget;
       const amenu: tmenuitem; const transientfor: twindow;
       const aowner: tcomponent = nil; const menucomp: tcustommenu = nil); overload;
   destructor destroy; override;
   procedure menuchanged(const sender: tmenuitem);
   procedure release; overload; override;
   procedure updatetemplates;
   procedure assigntemplate(const source: menutemplatety); virtual;
   function showmenu(const aposrect: rectty; aposition: graphicdirectionty;
                              aactivate: boolean): tmenuitem;
                    //returns selected item, nil if none
   property activeitem: integer read flayout.activeitem write setactiveitem;
  published
   property optionswidget default defaultpopupmenuwidgetoptions;
 end;

 mainmenuwidgetoptionty = (mwo_vertical);
 mainmenuwidgetoptionsty = set of mainmenuwidgetoptionty;
 mainmenuwidgetstatety = (mws_firstactivated,mws_forced,mws_raised);
 mainmenuwidgetstatesty = set of mainmenuwidgetstatety;

 tcustommainmenuwidget = class(tpopupmenuwidget)
  private
   factivewindowbefore: twindow;
   fstackedoverbefore: twindow;
   fstate: mainmenuwidgetstatesty;
   flayoutcalcing: integer;
   procedure internalsetactiveitem(const Value: integer;
                         const aclicked: boolean; const force: boolean;
                         const nochildreninactive: boolean); override;
   procedure checkactivate(const force: boolean);
  protected
   foptions: mainmenuwidgetoptionsty;
   procedure restorefocus;
   function checkprevpopuparea(const apos: pointty): boolean; override;
   procedure nextpopupshowing; override;
   procedure clientrectchanged; override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure updatelayout; override;
   procedure updatepos; override;
   function isinpopuparea(const apos: pointty): boolean; override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure childdeactivated(const sender: tpopupmenuwidget); override;
   procedure activatemenu(keymode: boolean; aclicked: boolean); override;
   procedure deactivatemenu; override;
   procedure selectmenu(const keymode: boolean); override;
   procedure internalcreateframe; override;
   procedure loaded; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure release(const acancelmodal: boolean); override;
  public
 end;

 tframemenuwidget = class(tcustommainmenuwidget)
  protected
  public
   constructor create(const aparent: twidget;
                                      const amenu: tmenuitem); overload;
   constructor create(const aparent: twidget;
                                      const amenu: tmainmenu); overload;
   procedure loaded; override;
 end;

 tmainmenuwidget = class(tcustommainmenuwidget)
  private
   procedure setmenu(const avalue: twidgetmainmenu);
   function getmenu: twidgetmainmenu;
   procedure setoptions(const avalue: mainmenuwidgetoptionsty);
  protected
//   function checkprevpopuparea(const apos: pointty): boolean; override;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure initnewcomponent(const ascale: real); override;
  published
   property menu: twidgetmainmenu read getmenu write setmenu;   
   property options: mainmenuwidgetoptionsty read foptions write setoptions default [];
   property popupdirection: graphicdirectionty read flayout.popupdirection write 
                                  flayout.popupdirection default gd_down;
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
 mseact,mseguiintf,msestrings,msebitmap,msesysutils;

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
   widget.color:= transientfor.window.owner.actualopaquecolor;
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
        const aoptions: menulayoutoptionsty{; const acolorglyph: colorty});
begin
 with info do begin
  cells:= nil;
  fillchar(info,sizeof(info),0);
  tmsecomponent1(aowner).getobjectlinker.setlinkedvar(ievent(aowner),amenu,tlinkedpersistent(menu));
  activeitem:= -1;
  options:= aoptions;
//  colorglyph:= acolorglyph;
 end;
end;

procedure movemenulayout(var layout: menulayoutinfoty; const dist: pointty);
var
 int1: integer;
begin
 with layout do begin
  addpoint1(sizerect.pos,dist);
  for int1:= 0 to high(cells) do begin
   with cells[int1].buttoninfo.ca.dim.pos do begin
    x:= x + dist.x;
    y:= y + dist.y;
   end;
   with cells[int1].dimouter.pos do begin
    x:= x + dist.x;
    y:= y + dist.y;
   end;
  end;
 end;
end;

procedure calcmenulayout(var layout: menulayoutinfoty; const canvas: tcanvas;
                              const maxsize: integer = bigint);
 function gettextrect(const acell: menucellinfoty; 
                                      const atext: richstringty): sizety;
 var
  size1: sizety;
 begin
  with acell do begin
   result:= textrect(canvas,atext,[],fontinactive).size;
   if fontinactive <> fontactive then begin
    size1:= textrect(canvas,atext,[],fontactive).size;
    if size1.cx > result.cx then begin
     result.cx:= size1.cx;
    end;
    if size1.cy > result.cy then begin
     result.cy:= size1.cy;
    end;
   end;
  end;
 end;
 
const
 shortcutdist = 5;
var
 int1,int2: integer;
 ay,ax: integer;
 sizemax1: integer;
 atextsize: sizety;
 maxheight: integer;
 textwidth: integer;
 tabpos1: integer;
 ashortcutwidth,shortcutwidth: integer;
 item1: tmenuitem1;
 hassubmenu: boolean;
 hascheckbox: boolean;
 shift,regioncount: integer;
 amax: integer;
 frame1: framety;
 frame2: framety;
 framewidth,frameheight: integer;
// framehalfwidth: integer;
// framewidth1: integer;
 extrasp: integer;
 imagedi: integer;
 imageditop: integer;
 imagedibottom: integer;
 ar1: richstringarty;
 commonwidth: boolean;
 needsmenuarrow: boolean;
 parentcolor: colorty;
 parentcoloractive: colorty;
 noanim1: boolean;
 nomouseanim1: boolean;
 noclickanim1: boolean;
 nofocusanim1: boolean;
 
begin
 ar1:= nil; //compiler warning
 with layout,tmenuitem1(menu) do begin
  sizerect.pos:= nullpoint;
  commonwidth:= (owner <> nil) and (mo_commonwidth in owner.options) and
                      (mlo_horz in layout.options);
//  framehalfwidth:= 0;
  needsmenuarrow:= not (mlo_horz in layout.options) or (owner <> nil) and 
                        (mo_mainarrow in owner.options);

  if itemframetemplateactive <> nil then begin
   frame2:= itemframetemplateactive.paintframe;
//   with tframetemplate1(itemframetemplateactive) do begin
//    framehalfwidth:= (abs(levelo) + abs(leveli) + framewidth);
//   end;
  end
  else begin
   frame2:= nullframe;
  end;
  if itemframetemplate <> nil then begin
   with tframetemplate1(itemframetemplate) do begin
    frame1:= paintframe;
    if frame1.left > frame2.left then begin
     frame2.left:= frame1.left;
    end;
    if frame1.top > frame2.top then begin
     frame2.top:= frame1.top;
    end;
    if frame1.right > frame2.right then begin
     frame2.right:= frame1.right;
    end;
    if frame1.bottom > frame2.bottom then begin
     frame2.bottom:= frame1.bottom;
    end;
//    int1:= (abs(levelo) + abs(leveli) + framewidth);
//    if int1 > framehalfwidth then begin
//     framehalfwidth:= int1;
//    end;
    frame1:= fi.ba.innerframe;
    extrasp:= fextraspace;
    imagedi:= fimagedist;
    imageditop:= fimagedisttop;
    imagedibottom:= fimagedistbottom;
    noanim1:= fso_noanim in optionsskin;
    nomouseanim1:= fso_nomouseanim in optionsskin;
    noclickanim1:= fso_noclickanim in optionsskin;
    nofocusanim1:= fso_nofocusanim in optionsskin;
   end;
  end
  else begin
   frame1:= nullframe;
   extrasp:= 0;
   imagedi:= 0;
   imageditop:= 0;
   imagedibottom:= 0;
   noanim1:= false;
   nomouseanim1:= false;
   noclickanim1:= false;
   nofocusanim1:= false;
  end; 
  framewidth:= frame2.left + frame2.right + extrasp;
  frameheight:= frame2.top + frame2.bottom + extrasp;
//  framewidth1:= framehalfwidth * 2;
//  framewidth1:= framewidth1 + extrasp;
  setlength(cells,count);
  maxheight:= 0;
//  ay:= framehalfwidth;
//  ax:= framehalfwidth;
  ay:= frame2.top;
  ax:= frame2.left;
  textwidth:= 0;
  shortcutwidth:= 0;
  hassubmenu:= false;
  hascheckbox:= false;
  parentcolor:= actualcolor;
  parentcoloractive:= actualcoloractive;
  for int1:= 0 to count - 1 do begin
   item1:= tmenuitem1(fsubmenu[int1]);
   with cells[int1] do begin
    fontinactive:= item1.font;
    fontactive:= item1.fontactive;
    with buttoninfo,ca do begin
     captiondist:= defaultshapecaptiondist;
     textflags:= [tf_ycentered];
     imagedist:= imagedi;
     imagelist:= timagelist(item1.finfo.imagelist);
     ar1:= splitrichstring(item1.finfo.caption1,msechar(c_tab));
     atextsize:= gettextrect(cells[int1],ar1[0]);
     atextsize.cx:= atextsize.cx + frame1.left + frame1.right;
     atextsize.cy:= atextsize.cy + frame1.top + frame1.bottom;
     inc(atextsize.cy,2); //for 3D level
     if imagelist <> nil then begin
      tabpos:= -(imagelist.width+imagedi);
      atextsize.cx:= atextsize.cx - tabpos;
      int2:= imagelist.height + imageditop + imagedibottom;
      if atextsize.cy < int2 then begin
       atextsize.cy:= int2;
      end;
     end
     else begin
      tabpos:= 0;
     end;
     if mlo_horz in layout.options then begin
      include(state,shs_horz);
     end
     else begin
      exclude(state,shs_horz);
     end;
     tabpos:= tabpos - frame1.right - frame1.left;
     if high(ar1) > 0 then begin
      ashortcutwidth:= gettextrect(cells[int1],ar1[1]).cx;
     end
     else begin
      ashortcutwidth:= 0;
     end;
     if needsmenuarrow and (item1.count > 0) then begin
      include(state,shs_menuarrow);
      if mlo_horz in layout.options then begin
       if (ashortcutwidth = 0) or commonwidth then begin
        dec(tabpos,menuarrowwidthhorz);
        inc(atextsize.cx,menuarrowwidthhorz);
       end
       else begin
        inc(ashortcutwidth,menuarrowwidthhorz);
       end;       
      end;
     end
     else begin
      exclude(state,shs_menuarrow);
     end;
     if ashortcutwidth > shortcutwidth then begin
      shortcutwidth:= ashortcutwidth;
     end;
     colorglyph:= item1.finfo.colorglyph; //layout.colorglyph;
     caption:= item1.finfo.caption1;
     imagenr:= item1.finfo.imagenr;
     imagenrdisabled:= item1.finfo.imagenrdisabled;
     actionstatestoshapestates(item1.finfo,state);
     if (item1.color = cl_default) or (item1.color = cl_parent) then begin
      color:= parentcolor;
     end
     else begin
      color:= item1.color;
     end;
     if (item1.coloractive = cl_default) or (item1.coloractive = cl_parent) then begin
      coloractive:= parentcoloractive;
     end
     else begin
      if item1.coloractive = cl_normal then begin
       coloractive:= color;
      end
      else begin
       coloractive:= item1.coloractive;
      end;
     end;
     include(state,shs_flat);
     updatebit(longword(state),ord(shs_noanimation),noanim1);
     updatebit(longword(state),ord(shs_nomouseanimation),nomouseanim1);
     updatebit(longword(state),ord(shs_noclickanimation),noclickanim1);
     updatebit(longword(state),ord(shs_nofocusanimation),nofocusanim1);
    
     if not (shs_invisible in state) then begin
      hassubmenu:= hassubmenu or (shs_menuarrow in state);
      hascheckbox:= hascheckbox or ([shs_checkbox,shs_radiobutton] * state <> []);
      with dim do begin
       if mlo_horz in layout.options then begin                //horizonzal
        if shs_separator in state then begin
         cx:= 2;
        end
        else begin
         if [shs_checkbox,shs_radiobutton] * state <> [] then begin
          inc(atextsize.cx,menucheckboxwidth);
          dec(tabpos,menucheckboxwidth);
         end;
         cx:= atextsize.cx + 4;
         if (ashortcutwidth > 0) then begin
          tabpos:= tabpos + atextsize.cx + shortcutdist;
          cx:= cx + shortcutdist + ashortcutwidth;
         end;
//         if ss_checkbox in state then begin
//          cx:= cx + menucheckboxwidth;
//         end;
        end;
        x:= ax;
        y:= ay;
        if commonwidth then begin
         atextsize.cx:= cx;
        end;
        inc(ax,cx+framewidth);
       end
       else begin                                              //vertical
        y:= ay;
        if shs_separator in state then begin
         cy:= 2;
        end
        else begin
         cy:= atextsize.cy;
        end;
        inc(ay,cy+frameheight);
       end;
      end;
      if atextsize.cy > maxheight then begin
       maxheight:= atextsize.cy;
      end;
      if atextsize.cx > textwidth then begin
       textwidth:= atextsize.cx;
      end;
     end
     else begin
      dim:= nullrect;
     end;
    end;  //with cells[int1].buttoninfo
   end;   //with cells[int1]
  end;
  if (shortcutwidth > 0) and not commonwidth then begin
   tabpos1:= textwidth + shortcutdist;
   textwidth:= tabpos1 + shortcutwidth;
  end
  else begin
   tabpos1:= 0;
  end;
  if not (as_invisible in state) then begin
   shift:= 0;
   regioncount:= 1;
   if mlo_horz in layout.options then begin                //horizontal
    if mao_singleregion in layout.menu.options then begin
     amax:= bigint;
    end
    else begin
     amax:= maxsize;
    end;
    if commonwidth then begin
     ax:= frame2.left;
    end;
    sizemax1:= 0;
    for int1:= 0 to count - 1 do begin
     with cells[int1].buttoninfo,ca do begin
      if not (shs_invisible in state) then begin
       if commonwidth then begin
        dim.x:= ax;
        if not (shs_separator in state) then begin
         dim.cx:= textwidth;
        end;
        ax:= ax + dim.cx + framewidth;
       end;
       dim.x:= dim.x + shift;
       if (int1 > 0) and 
               (dim.x + dim.cx + frame2.right > amax) then begin
        shift:= shift - dim.x + frame2.left; 
        dim.x:= frame2.left;
        inc(regioncount);
       end;
       int2:= dim.x + dim.cx + shift;
       if int2 > sizemax1 then begin
        sizemax1:= int2;
       end;
       dim.y:= frame2.top + (maxheight+frameheight) * (regioncount - 1);
       dim.cy:= maxheight;
      end;
     end;
    end;
    sizerect.cx:= sizemax1 {- extrasp - frame2.right};
//    sizerect.cx:= ax - extrasp - frame2.right;
    sizerect.cy:= regioncount * (maxheight + frameheight) - extrasp;
   end
   else begin                                              //vertical
    if mao_singleregion in layout.menu.options then begin
     amax:= bigint;
    end
    else begin
     amax:= maxsize;
    end;
    ax:= frame2.left;
    textwidth:= textwidth + 4;
    if hassubmenu then begin
     textwidth:= textwidth + menuarrowwidth;
    end;
    if hascheckbox then begin
     textwidth:= textwidth + menucheckboxwidth;
    end;
    maxheight:= 0;
    for int1:= 0 to count - 1 do begin
     with cells[int1].buttoninfo,ca,dim do begin
      tabpos:= tabpos + tabpos1;
      y:= y + shift;
      int2:= y + cy  + frameheight;
      if (int1 > 0) and (int2 - extrasp > amax) then begin
       shift:= shift - y + frame2.top;
       y:= frame2.top;
       ax:= ax + textwidth + framewidth;
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
    sizerect.cx:=  regioncount * (textwidth  + framewidth) - extrasp;
    sizerect.cy:= maxheight - frame2.bottom - extrasp;
   end;
  end
  else begin
   sizerect.size:= nullsize;
  end;
  for int1:= 0 to count - 1 do begin
   with cells[int1],buttoninfo,ca do begin
    dimouter:= inflaterect(dim,frame2);
    imagedisttop:= imageditop;
    imagedistbottom:= imagedibottom;
   end;
  end;
 end;
end;

function getcellatpos(const info: menulayoutinfoty; const pos: pointty): integer;
var
 int1: integer;
begin
 with info do begin
  if pointinrect(pos,sizerect) then begin
   result:= -2;
   for int1:= 0 to high(cells) do begin
    with cells[int1].buttoninfo do begin
     if (state * [shs_disabled,shs_invisible,shs_separator] = []) and
                pointinrect(pos,ca.dim) then begin
      result:= int1;
      break;
     end;
    end;
   end;
  end
  else begin
   result:= -1;
  end;
 end;
end;

procedure drawmenu(const canvas: tcanvas; const layout: menulayoutinfoty);
var
 int1: integer;
 po1,po2: pframety;
begin
 with layout do begin
  if itemframetemplate <> nil then begin
   po1:= @tframetemplate1(itemframetemplate).fi.ba.innerframe;
  end
  else begin
   po1:= nil;
  end; 
  if itemframetemplateactive <> nil then begin
   po2:= @tframetemplate1(itemframetemplateactive).fi.ba.innerframe;
  end
  else begin
   po2:= nil;
  end; 
  for int1:= 0 to high(cells) do begin
   with cells[int1],buttoninfo do begin
    if int1 = activeitem then begin
     if itemframetemplateactive <> nil then begin
      itemframetemplateactive.paintbackground(canvas,ca.dim);
     end;
     face:= itemfaceactive;
     ca.font:= fontactive;
     state:= state + [shs_focused,shs_active,shs_focusanimation];
     drawmenubutton(canvas,buttoninfo,po2);
     if itemframetemplateactive <> nil then begin
      itemframetemplateactive.paintoverlay(canvas,ca.dim,
            combineframestateflags(false,true,shs_clicked in state,false));
     end;
    end
    else begin
     if itemframetemplate <> nil then begin
      itemframetemplate.paintbackground(canvas,ca.dim);
     end;
     face:= itemface;
     ca.font:= fontinactive;
     state:= state - [shs_focused,shs_active,shs_focusanimation];
     drawmenubutton(canvas,buttoninfo,po1);
     if itemframetemplate <> nil then begin
          itemframetemplate.paintoverlay(canvas,ca.dim,
                 combineframestateflags(shs_disabled in state,false,
                 shs_clicked in state,false));
     end;
    end;
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
    if (state * [shs_disabled,shs_invisible] = []) and
            msegui.checkshortcut(info,ca.caption,false) then begin
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
         const aowner: tcomponent = nil; const menucomp: tcustommenu = nil);
begin
 fclickeditem:= -1;
 finstancepo:= pobject(instance);
 fmenucomp:= menucomp;
 if finstancepo <> nil then begin
  instance^:= self;
 end;
 initlayoutinfo(self,flayout,amenu,[]{,cl_black});
 inherited create(aowner,transientfor);
 optionswidget:= defaultpopupmenuwidgetoptions;
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
 flayout.itemfaceactive.free;
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
  if not flocalframeandface then begin
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
  if itemframeactive <> nil then begin
   flayout.itemframetemplateactive:= itemframeactive.template;
  end
  else begin
   flayout.itemframetemplateactive:= nil;
  end;
  if itemfaceactive <> nil then begin
   if flayout.itemfaceactive = nil then begin
    flayout.itemfaceactive:= tcustomface.create(iface(self));
   end;
   flayout.itemfaceactive.assign(itemfaceactive.template);
  end
  else begin
   freeandnil(flayout.itemfaceactive);
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
 setlinkedvar(source.itemframeactive,tmsecomponent(ftemplates.itemframeactive));
 setlinkedvar(source.itemfaceactive,tmsecomponent(ftemplates.itemfaceactive));
 updatetemplates; 
end;

function tpopupmenuwidget.translatetoscreen(const value: pointty): pointty;
begin
 result:= translateclientpoint(value,self,nil);
end;

function tpopupmenuwidget.transientforwindoworwindow: twindow;
begin
 result:= window.transientfor;
 if result = nil then begin
  result:= self.window;
 end;
end;

procedure tpopupmenuwidget.updatepos;
var
 rect1: rectty;
 workarea: rectty;
 int1: integer;
begin
 rect1.size:= addsize(flayout.sizerect.size,innerclientframewidth);
 workarea:= application.workarea(transientforwindoworwindow);
 factposition:= fposition;
 int1:= 0;
 with fposrect do begin
  repeat
   case factposition of
    gd_none: begin
     inc(int1);
     rect1.x:= x + (cx - rect1.cx) div 2;
     rect1.y:= y + (cy - rect1.cy) div 2;
    end;
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
 calcmenulayout(flayout,getcanvas,
          application.screenrect(transientforwindoworwindow).cy -
          innerclientframewidth.cy);
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
  color:= transientforwindow.owner.actualopaquecolor;
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
 itembefore: integer;
 int1: integer;
 pt1,pt2: pointty;
begin
 with info,flayout do begin
  itembefore:= activeitem;
  pt1:= translatewidgetpoint(info.pos,self,nil);
  if (mlo_keymode in options) and
   (eventkind in [ek_mousemove,ek_buttonpress,
                        ek_buttonrelease,ek_mousepark]) then begin
   if (distance(pt1,mousepos) <= 3) and
      (eventkind in [ek_mousemove,ek_mousepark]) then begin
    exit;
   end
   else begin
    exclude(options,mlo_keymode);
   end;
  end;
  if (eventkind = ek_mousemove) and (fnextpopup <> nil) and
         pointinrect(pt1,fnextpopup.fwidgetrect) and 
                             not (mlo_childreninactive in options) then begin
   invalidaterect(cells[activeitem].dimouter);
   fnextpopup.activatemenu(false,ss_left in info.shiftstate);
   exit;
  end;
  if eventkind in mouseposevents then begin
   if not checkprevpopuparea(pt1) then begin
    if pointinrect(pos,paintrect) then begin
     pt2:= subpoint(pos,paintpos);
     internalsetactiveitem(getcellatpos(flayout,pt2),ss_left in info.shiftstate,
                           false,pointinrect(pt2,sizerect));
     if activeitem >= 0 then begin
      include(cells[activeitem].buttoninfo.state,shs_mouse);
      if (itembefore <> activeitem) and 
                tmenuitem1(menu.items[activeitem]).canshowhint then begin
       application.restarthint(self);
      end;
     end;
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
     if (fnextpopup <> nil) and (activeitem = itembefore) then begin
      fclickeditem:= activeitem; //prepare for close popupup
     end;
     if mlo_childreninactive in options then begin
      exclude(options,mlo_childreninactive);
      activeitem:= -1;
      mouseevent(info);
      if (activeitem >= 0) and 
                     tmenuitem1(menu.items[activeitem]).canshowhint then begin
       application.hidehint;
      end;
      exit;
     end;
     with cells[activeitem],buttoninfo do begin
      include(state,shs_clicked);
      invalidaterect(dimouter);
     end;
    end;
   end;
   ek_buttonrelease: begin
    if (activeitem >= 0) and (button = mb_left) then begin
     with cells[activeitem],buttoninfo do begin
      bo1:= shs_clicked in state;
      exclude(state,shs_clicked);
      invalidaterect(dimouter);
      if bo1 then begin
       include(info.eventstate,es_processed);
       int1:= activeitem;
       selectmenu(false);
       include(state,shs_mouse);
       if (activeitem < 0) and (application.mousecapturewidget = nil) and 
                 (int1 <= high(cells)) then begin
        activeitem:= int1; //restore mouseactivating
       end;
       if (mlo_main in options) and (fclickeditem = activeitem) then begin
        fclickeditem:= -1;
        closepopupstack(nil);
        include(state,shs_mouse);
        exit;
       end;
       fclickeditem:= activeitem;
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
      updatemouseshapestate(cells[activeitem].buttoninfo,info,self,nil);
//      include (cells[activeitem].buttoninfo.state,shs_mouse);
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
          const aclicked: boolean; const force: boolean;
          const nochildreninactive: boolean);
var
 value1: integer;
begin
 with flayout do begin
  value1:= avalue;
  if (value1 < 0) or (menu = nil) then begin
   value1:= -1;
  end; 
  if (activeitem <> value1) or force then begin
   fclickeditem:= -1;
   if (activeitem >= 0) and (activeitem < menu.submenu.count) then begin
    if (fnextpopup <> nil) then begin
     fnextpopup.release;
    end;
    with cells[activeitem],buttoninfo do begin
     state:= state - [shs_clicked,shs_mouse,shs_active,shs_focused];
     invalidaterect(dimouter);
    end;
   end;
   activeitem:= value1;
   if activeitem >= 0 then begin
    if not menu[value1].canactivate then begin
     activeitem:= nextmenuitem(flayout);
    end;
    with cells[activeitem],buttoninfo do begin
     state:= state + [shs_focused];
//     state:= state + [shs_mouse];
     if aclicked then begin
      include(state,shs_clicked);
     end;
     invalidaterect(dimouter);
     if not (mlo_childreninactive in options) and
              (tmenuitem1(menu).fsubmenu[activeitem].count > 0) then begin
      tpopupmenuwidget.create(@fnextpopup,tmenuitem1(menu).fsubmenu[activeitem],
                                fwindow);
      fnextpopup.fprevpopup:= self;
      nextpopupshowing;
      fnextpopup.showmenu(makerect(translatetoscreen(ca.dim.pos),ca.dim.size),
               popupdirection,false);
      fnextpopup.beginkeymode;
     end;
    end;
    capturemouse;
   end;
  end
  else begin
   if aclicked and (value1 >= 0) then begin
    with cells[activeitem],buttoninfo do begin
     if not (shs_clicked in state) then begin
      include(state,shs_clicked);
      invalidaterect(dimouter);
     end;
    end;
   end;
  end;
  if (activeitem < 0) and (mlo_main in options) and 
                             not nochildreninactive then begin
   include(options,mlo_childreninactive);
   releasemouse;
  end;
 end;
end;

procedure tpopupmenuwidget.setactiveitem(const value: integer);
begin
 internalsetactiveitem(value,false,false,false);
end;

procedure tpopupmenuwidget.activatemenu(keymode: boolean; aclicked: boolean);
begin
 capturekeyboard;
 capturemouse;
 if keymode then begin
  beginkeymode;
 end
 else begin
  exclude(flayout.options,mlo_keymode);
 end;
 if (flayout.menu.count > 0) and (flayout.activeitem < 0) then begin
  if keymode then begin
   internalsetactiveitem(0,aclicked,true,false);
  end;
  if (show(true,nil) <> mr_windowdestroyed) and (fprevpopup = nil) then begin
//   window.removefocuslock;
   flayout.menu.owner.checkexec;
  end;
 end;
end;

procedure tpopupmenuwidget.childdeactivated(const sender: tpopupmenuwidget);
begin
 capturemouse;
 capturekeyboard;
end;

procedure tpopupmenuwidget.deactivatemenu;
begin
 setactiveitem(-1);
 window.endmodal;
 if fprevpopup <> nil then begin
  fprevpopup.childdeactivated(self);
 end;
end;

procedure tpopupmenuwidget.selectmenu(const keymode: boolean);
var
 int1: integer;
 bo1: boolean;
begin
 with flayout do begin
  if mlo_childreninactive in options then begin
   exclude(options,mlo_childreninactive);
   internalsetactiveitem(activeitem,false,true,false);
  end;
 end;
 if (fnextpopup <> nil) then begin
  if keymode then begin
   fnextpopup.activatemenu(keymode,false);
  end
  else begin
   fnextpopup.window.bringtofront; //win32 workaround
  end;
 end
 else begin
  with flayout do begin
   bo1:= not ((menu.owner <> nil) and (csdesigning in menu.owner.componentstate));
   if activeitem >= 0 then begin
    int1:= activeitem;
    with menu[int1] do begin
     if (mao_asyncexecute in options) then begin
      closepopupstack(menu[int1]);
      if bo1 then begin
       asyncexecute;
      end;
     end
     else begin
      releasemouse;
      if bo1 then begin
       execute;
      end;
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
      selectmenu(true);
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
    key_return,{key_enter,}key_space: begin
     selectmenu(true);
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
       if (fprevpopup <> nil) and 
            (fprevpopup.flayout.options * [mlo_main,mlo_horz] = 
                                            [mlo_main,mlo_horz]) then begin
        exclude(eventstate,es_processed);
       end;
      end
      else begin
       if rootpopup <> self then begin
        with rootpopup do begin
         if mlo_main in flayout.options then begin
          exclude(eventstate,es_processed);
          swapkeys;
          dokeydown(info);
          swapkeys;
          include(eventstate,es_processed);
         end;
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

procedure tpopupmenuwidget.closepopupstack(aselecteditem: tmenuitem;
                            const cancelmodal: boolean = false);
var
 widget1: tpopupmenuwidget;
begin
 widget1:= self;
 while true do begin
  with widget1 do begin
   if not (mlo_main in flayout.options) then begin
    window.endmodal;
   end;
  end;
  if widget1.fprevpopup <> nil then begin
   widget1:= widget1.fprevpopup;
  end
  else begin
   break;
  end;
 end;
 widget1.fselecteditem:= aselecteditem; //return value for procedure showmenu
 widget1.release(cancelmodal);
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

function tpopupmenuwidget.activateoptionset: boolean;
begin
 result:= (fmenucomp <> nil) and (mo_activate in fmenucomp.options);
end;

procedure tpopupmenuwidget.showhint(var info: hintinfoty);
begin
 inherited;
 with flayout do begin
  if (activeitem >= 0) and tmenuitem1(menu.items[activeitem]).canshowhint then begin
   info.caption:= menu.items[activeitem].hint;
  end;
  {
  else begin
   if tmenuitem1(menu).canshowhint then begin
    info.caption:= menu.hint;
   end;
  end;
  }
 end;
end;

function tpopupmenuwidget.trycancelmodal(const newactive: twindow): boolean;
var
 widget2: tpopupmenuwidget;
 window1: twindow;
 int1: integer;
begin
 result:= false;
 if newactive <> nil then begin
  widget2:= self;
  int1:= 0;
  while (widget2 <> nil) do begin
   if widget2.window = newactive then begin
    exit;
   end;
   if widget2.window.modal then begin
    inc(int1);
   end;
   widget2:= widget2.fprevpopup;
  end;
  if application.modallevel = int1 then begin
   result:= true; //no lower modal window, accept new active window
{$ifdef mse_debugwindowfocus}
   debugwriteln('closepopupstack '+inttostr(int1));
{$endif}
   closepopupstack(nil,true);
  end;
 end; 
end;

procedure tpopupmenuwidget.release(const acancelmodal: boolean);
begin
 release;
end;

{ tcustommainmenuwidget }

procedure tcustommainmenuwidget.internalcreateframe;
begin
 inherited;
 tcustomframe1(fframe).fi.levelo:= 0; //do not set localprops
end;

procedure tcustommainmenuwidget.loaded;
begin
 inherited;
 updatelayout;
end;

procedure tcustommainmenuwidget.updatepos;
begin
 //dummy
end;

procedure tcustommainmenuwidget.getautopaintsize(var asize: sizety);
begin
 asize:= addsize(flayout.sizerect.size,innerframewidth);
end;

procedure tcustommainmenuwidget.updatelayout;
var
 rect1: rectty;
 size1: sizety;
begin
 if flayoutcalcing = 0 then begin
  inc(flayoutcalcing);
  try
   size1:= innerclientrect.size;
   if ow1_autowidth in foptionswidget1 then begin
    size1.cx:= bigint;
   end;
   if ow1_autoheight in foptionswidget1 then begin
    size1.cy:= bigint;
   end;
   if mlo_horz in flayout.options then begin
    calcmenulayout(flayout,getcanvas,size1.cx);
   end
   else begin
    calcmenulayout(flayout,getcanvas,size1.cy);
   end;
   movemenulayout(flayout,innerclientrect.pos);
   rect1:= fwidgetrect;
   if mlo_horz in flayout.options then begin
    rect1.cy:= flayout.sizerect.size.cy + innerclientframewidth.cy;
    if an_bottom in fanchors then begin
     rect1.y:= rect1.y + fwidgetrect.cy - rect1.cy;
    end;
   end
   else begin
    rect1.cx:= flayout.sizerect.size.cx + innerclientframewidth.cx;
    if an_right in fanchors then begin
     rect1.x:= rect1.x + fwidgetrect.cx - rect1.cx;
    end;
   end;
   widgetrect:= rect1;
  finally
   dec(flayoutcalcing);
  end;
 end;
end;

procedure tcustommainmenuwidget.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure tcustommainmenuwidget.nextpopupshowing;
begin
 inherited;
 if fmenucomp <> nil then begin
  fnextpopup.assigntemplate(tmainmenu(fmenucomp).popuptemplate);
 end;
end;

procedure tcustommainmenuwidget.release(const acancelmodal: boolean);
begin
 if acancelmodal then begin
  setlinkedvar(nil,tlinkedobject(factivewindowbefore));
             //do not restore active window
 end;  
 setactiveitem(-1);
 releasemouse;
// activeitem:= int1;
end;

function tcustommainmenuwidget.isinpopuparea(const apos: pointty): boolean;
begin
 result:= pointinrect(translatewidgetpoint(apos,nil,parentwidget),fwidgetrect);
end;

procedure tcustommainmenuwidget.doshortcut(var info: keyeventinfoty;
  const sender: twidget);
begin
 inherited;
 if not (csdesigning in componentstate) then begin
  if not (es_processed in info.eventstate) and (info.shiftstate = [ss_alt]) and
                   not (es_modal in info.eventstate) then begin
   dokeydown(info);
  end;
  if not (es_processed in info.eventstate) and (fmenucomp <> nil) then begin
   fmenucomp.menu.doshortcut(info);
  end;
 end;
end;

procedure tcustommainmenuwidget.childdeactivated(const sender: tpopupmenuwidget);
begin
 inherited;
 if mlo_keymode in sender.flayout.options then begin
  deactivatemenu;
 end;
end;

procedure tcustommainmenuwidget.restorefocus;
var
 ar1: winidarty;
 ar2: integerarty;
begin
 twindow1(window).unlockactivate;
 releasekeyboard;
 if mws_firstactivated in fstate then begin
  if factivewindowbefore <> fwindow then begin
   if mws_raised in fstate then begin
    if (fstackedoverbefore <> nil) then begin 
     if fstackedoverbefore.visible then begin
      setlength(ar1,2);
      ar1[0]:= fstackedoverbefore.winid;
      ar1[1]:= fwindow.winid;
      gui_getzorder(ar1,ar2);
      if ar2[1] > ar2[0] then begin
       gui_stackoverwindow(fwindow.winid,fstackedoverbefore.winid);
      end;
     end;
    end
    else begin
//     if activateoptionset then begin
      window.stackover(nil);
//     end;
    end;
   end;
  end;
  if application.active and not ((fmenucomp = nil) or 
                 (csdesigning in fmenucomp.componentstate)) and 
       (factivewindowbefore <> nil) and factivewindowbefore.visible then begin
   factivewindowbefore.reactivate;
  end;
  setlinkedvar(nil,tlinkedobject(factivewindowbefore));
  setlinkedvar(nil,tlinkedobject(fstackedoverbefore));
 end;
end;

procedure tcustommainmenuwidget.checkactivate(const force: boolean);
begin
 if force then begin
  include(fstate,mws_forced);
 end;
 if not (mws_firstactivated in fstate) or force then begin
  if not (mws_firstactivated in fstate) then begin
   include(fstate,mws_firstactivated);
   setlinkedvar(fwindow.stackedover,tlinkedobject(fstackedoverbefore));
  end;
  if (force or activateoptionset) then begin
   capturekeyboard;
   if (factivewindowbefore = nil) then begin
    setlinkedvar(application.activewindow,tlinkedobject(factivewindowbefore));
   end;
  end;
  if force or activateoptionset then begin
   if application.active and (fmenucomp <> nil) then begin
    window.bringtofront;
    include(fstate,mws_raised);
   end;
  end;
 end;
 if mws_forced in fstate then begin
  twindow1(window).lockactivate;
  capturekeyboard;
 end;
 if factivewindowbefore <> nil then begin
  factivewindowbefore.deactivateintermediate;
 end;
end;

procedure tcustommainmenuwidget.internalsetactiveitem(const Value: integer;
           const aclicked: boolean; const force: boolean;
           const nochildreninactive: boolean);
begin
 if (value >= 0) and not (csdesigning in componentstate) then begin
  checkactivate(false);
 end;
 inherited;
 if value = -1 then begin
  restorefocus;
  fstate:= [];
 end;
end;

procedure tcustommainmenuwidget.activatemenu(keymode: boolean; aclicked: boolean);
begin
 inherited;
 flayout.menu.owner.checkexec;
end;

procedure tcustommainmenuwidget.selectmenu(const keymode: boolean);
begin
 checkactivate(true);
 inherited;
 flayout.menu.owner.checkexec;
end;

procedure tcustommainmenuwidget.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if (activeitem >= 0) and (info.eventkind = ek_buttonpress) then begin
  if factivewindowbefore <> nil then begin
   twindow1(window).lockactivate;
   capturekeyboard;
//   factivewindowbefore.deactivateintermediate;
  end;
 end;
end;

procedure tcustommainmenuwidget.deactivatemenu;
begin
 inherited;
 releasemouse;
end;

function tcustommainmenuwidget.checkprevpopuparea(const apos: pointty): boolean;
var
 po1: pointty;
begin
 po1:= translatewidgetpoint(apos,nil,parentwidget);
 result:= not pointinrect(po1,fwidgetrect) and
         pointinrect(apos,rootwidget.widgetrect);
 if result then begin
  capturemouse;
  release(false);
 end;
end;

{ tframemenuwidget }

constructor tframemenuwidget.create(const aparent: twidget; 
                                           const amenu: tmenuitem);
begin
 inherited create(nil,amenu,nil,nil,fmenucomp);
 foptionswidget:= foptionswidget-[ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 fwidgetstate:= fwidgetstate - [ws_iswidget];
 setlockedparentwidget(aparent);
 flayout.options:= [mlo_horz,mlo_main,mlo_childreninactive];
 flayout.popupdirection:= gd_down;
 if not (csloading in aparent.ComponentState) and not (csloading in componentstate) then begin
  updatelayout;
  visible:= true;
 end;
end;

constructor tframemenuwidget.create(const aparent: twidget; const amenu: tmainmenu);
begin
 fmenucomp:= amenu;
 create(aparent,amenu.menu);
end;

procedure tframemenuwidget.loaded;
begin
 include(fwidgetstate,ws_visible);
 inherited;
end;

{ tmainmenuwidget }

constructor tmainmenuwidget.create(aowner: tcomponent);
begin
 flocalframeandface:= true;
 setlinkedvar(twidgetmainmenu.create(self),tmsecomponent(fmenucomp));
 fmenucomp.setsubcomponent(true);
 inherited create(nil,fmenucomp.menu,nil,aowner,fmenucomp);
 if csdesigning in componentstate then begin
  tmsecomponent1(fmenucomp).setdesigning(true);
 end;
 freeandnil(fframe);
 flayout.options:= [mlo_horz,mlo_main,mlo_childreninactive];
 flayout.popupdirection:= gd_down;
 if not (csloading in componentstate) then begin
  updatelayout;
 end;
 visible:= true;
end;

destructor tmainmenuwidget.destroy;
begin
 fmenucomp.free;
 inherited;
end;

procedure tmainmenuwidget.initnewcomponent(const ascale: real);
begin
 inherited;
 with fmenucomp.menu.submenu do begin
  if count = 0 then begin
   insert(0,['Item0'],[],[],[]);
  end;
 end;
 bounds_cx:= 100;
end;

procedure tmainmenuwidget.setmenu(const avalue: twidgetmainmenu);
begin
 fmenucomp.assign(avalue);
end;

function tmainmenuwidget.getmenu: twidgetmainmenu;
begin
 result:= twidgetmainmenu(fmenucomp);
end;

procedure tmainmenuwidget.setoptions(const avalue: mainmenuwidgetoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  if mwo_vertical in foptions then begin
   exclude(flayout.options,mlo_horz);   
  end
  else begin
   include(flayout.options,mlo_horz);     
  end;
  if not (csloading in componentstate) then begin
   updatelayout;
  end;
 end;
end;

procedure tmainmenuwidget.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = fmenucomp) and
                                  not (csloading in componentstate) then begin
  assigntemplate(fmenucomp.template);
  invalidate;                            
 end; 
end;

procedure tmainmenuwidget.loaded;
begin
 inherited;
 assigntemplate(fmenucomp.template);
end;

end.
