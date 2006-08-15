{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegui;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 Classes,sysutils,msegraphics,msetypes,msestrings,mseerror,msegraphutils,
 msepointer,mseevent,msekeyboard,mseclasses,mseguiglob,mselist,msesys,msethread,
 msebitmap,msearrayprops;

const
 mseguiversiontext = '1.0x';
 
 defaultwidgetcolor = cl_default;
 defaulttoplevelwidgetcolor = cl_background;
 hintdelaytime = 500000; //us
 defaulthintshowtime = 3000000; //us
 mouseparktime = 500000; //us
 defaultdblclicktime = 400000; //us

 mousebuttons = [ss_left,ss_right,ss_middle];

type
 optionwidgetty = (ow_background,ow_top,ow_noautosizing,
                   ow_mousefocus,ow_tabfocus,ow_parenttabfocus,ow_arrowfocus,
                   ow_arrowfocusin,ow_arrowfocusout,
                   ow_subfocus, //reflects focus to children
                   ow_focusbackonesc,
                   ow_mousetransparent,ow_mousewheel,ow_noscroll,ow_destroywidgets,
                   ow_hinton,ow_hintoff,ow_multiplehint,ow_timedhint,
                   ow_fontglyphheight, 
                   //track font.glyphheight, 
                   //create fonthighdelta and childscaled events
                   ow_fontlineheight, 
                   //track font.linespacing,
                   //create fonthighdelta and childscaled events
                   ow_autoscale //synchronizes bounds_cy with fontheightdelta
                   );
 optionswidgetty = set of optionwidgetty;

 anchorty = (an_left,an_top,an_right,an_bottom);
 anchorsty = set of anchorty;

 shortcutty = type word;
 widgetstatety = (ws_visible,ws_enabled,
                  ws_active,ws_entered,ws_focused,
                  ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,
                  ws_wantmousefocus,ws_iswidget,
                  ws_opaque,ws_nopaint,
                  ws_clicked,ws_mousecaptured,ws_clientmousecaptured,
                  ws_loadlock,ws_loadedproc,ws_showproc,
                  ws_minclientsizevalid,
                  ws_showed,ws_hidden, //used in tcustomeventwidget
                  ws_destroying,
                  ws_staticframe,ws_staticface,
                  ws_nodesignvisible,ws_nodesignframe,ws_isvisible
                 );
 widgetstatesty = set of widgetstatety;
 widgetstate1ty = (ws1_releasing,ws1_childscaled,
                   ws1_widgetregionvalid,ws1_rootvalid,{ws1_clientsizing,}
                   ws1_anchorsizing,ws1_isstreamed);
 widgetstates1ty = set of widgetstate1ty;

 framestatety = (fs_sbhorzon,fs_sbverton,fs_sbhorzfix,fs_sbvertfix,
                 fs_sbhorztop,fs_sbvertleft,
                 fs_sbleft,fs_sbtop,fs_sbright,fs_sbbottom,
                 fs_nowidget,fs_disabled,fs_captiondistouter,
                 fs_drawfocusrect,fs_paintrectfocus,
                 fs_captionfocus,fs_rectsvalid);
 framestatesty = set of framestatety;

 modalresultty = (mr_none,mr_canclose,mr_windowclosed,mr_windowdestroyed,
                  mr_exception,
                  mr_cancel,mr_abort,mr_ok,mr_yes,mr_no,mr_all,mr_noall,mr_ignore);
 modalresultsty = set of modalresultty;

 hintflagty = (hfl_show,hfl_custom,{hfl_left,hfl_top,hfl_right,hfl_bottom,}
               hfl_noautohidemove);
 hintflagsty = set of hintflagty;

 hintinfoty = record
  flags: hintflagsty;
  caption: captionty;
  posrect: rectty;
  placement: captionposty;
  showtime: integer;
  mouserefpos: pointty;
 end;

 showhinteventty = procedure(const sender: tobject; var info: hintinfoty) of object;

const
 defaultwidgetstates = [ws_visible,ws_enabled,ws_iswidget,ws_isvisible];
 focusstates = [ws_visible,ws_enabled];
 defaultoptionswidget = [ow_mousefocus,ow_tabfocus,ow_arrowfocus,ow_mousewheel,
                         ow_destroywidgets,ow_autoscale];
 defaultoptionswidgetnofocus = defaultoptionswidget -
             [ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 defaultwidgetwidth = 50;
 defaultwidgetheight = 50;
 defaultanchors = [an_left,an_top];
 defaulthintflags = [];

type

 framelocalpropty = (frl_levelo,frl_leveli,frl_framewidth,frl_colorframe,
                     frl_fileft,frl_fitop,frl_firight,frl_fibottom,frl_colorclient,
                     frl_nodisable);
 framelocalpropsty = set of framelocalpropty;

const
 allframelocalprops: framelocalpropsty =
                    [frl_levelo,frl_leveli,frl_framewidth,frl_colorframe,
                     frl_fileft,frl_fitop,frl_firight,frl_fibottom,frl_colorclient];
type
 facelocalpropty = (fal_options,fal_fadirection,fal_image,fal_fapos,fal_facolor,
                    fal_fatransparency);
 facelocalpropsty = set of facelocalpropty;

const
 allfacelocalprops: facelocalpropsty =
                    [fal_options,fal_fadirection,fal_image,fal_fapos,fal_facolor,
                    fal_fatransparency];
type

 twidget = class;
 tcustomframe = class;

 iframe = interface(inullinterface)
  procedure setframeinstance(instance: tcustomframe);
  function getwidgetrect: rectty;
  procedure setwidgetrect(const rect: rectty);
  procedure setstaticframe(value: boolean);
  function widgetstate: widgetstatesty;
  procedure scrollwidgets(const dist: pointty);
  procedure clientrectchanged;
  function getcomponentstate: tcomponentstate;
  procedure invalidate;
  procedure invalidatewidget;
  procedure invalidaterect(const rect: rectty; org: originty = org_client);
  function getframefont: tfont;
  function getcanvas(aorigin: originty = org_client): tcanvas;
  function canfocus: boolean;
  function setfocus(aactivate: boolean = true): boolean;
  function getwidget: twidget;
 end;

 frameinfoty = record
  levelo: integer;
  leveli: integer;
  framewidth: integer;
  colorframe: colorty;
  innerframe: framety;
  colorclient: colorty;
 end;

 tframecomp = class;

 tcustomframe = class(toptionalpersistent)
  private
   ftemplate: tframecomp;
   flocalprops: framelocalpropsty;
   procedure settemplateinfo(const ainfo: frameinfoty);
   procedure setlevelo(const Value: integer);
   function islevelostored: boolean;
   procedure setleveli(const Value: integer);
   function islevelistored: boolean;
   procedure setframewidth(const Value: integer);
   function isframewidthstored: boolean;
   procedure setcolorframe(const Value: colorty);
   function iscolorframestored: boolean;
   procedure setframei_bottom(const Value: integer);
   function isfibottomstored: boolean;
   procedure setframei_left(const Value: integer);
   function isfileftstored: boolean;
   procedure setframei_right(const Value: integer);
   function isfirightstored: boolean;
   procedure setframei_top(const Value: integer);
   function isfitopstored: boolean;
   procedure setcolorclient(const Value: colorty);
   function iscolorclientstored: boolean;
   procedure settemplate(const avalue: tframecomp);
//   function arepropsstored: boolean;
   procedure setlocalprops(const avalue: framelocalpropsty);
  protected
   fintf: iframe;
   fstate: framestatesty;
   fwidth: framety;
   fouterframe: framety;
   fpaintframedelta: framety;
   fpaintframe: framety;
   fpaintrect: rectty;
   fclientrect: rectty;          //origin = fpaintrect.pos
   finnerclientrect: rectty;     //origin = fpaintrect.pos
   fpaintposbefore: pointty;
   fi: frameinfoty;
   procedure setdisabled(const value: boolean); virtual;
   procedure updateclientrect; virtual;
   procedure updaterects; virtual;
   procedure internalupdatestate;
   procedure updatestate; virtual;
   procedure checkstate;
   procedure poschanged; virtual;
   procedure getpaintframe(var frame: framety); virtual;
        //additional space, (scrollbars,mainmenu...)
   procedure dokeydown(var info: keyeventinfoty); virtual;
   function checkshortcut(var info: keyeventinfoty): boolean; virtual;
   procedure parentfontchanged; virtual;
   procedure dopaintframe(const canvas: tcanvas; const rect: rectty); virtual;
   procedure dopaintfocusrect(const canvas: tcanvas; const rect: rectty); virtual;
   procedure updatewidgetstate; virtual;
   procedure updatemousestate(const sender: twidget; const apos: pointty); virtual;
  public
   constructor create(const intf: iframe); reintroduce; //sets owner.fframe
   destructor destroy; override;
   procedure assign(source: tpersistent); override;

   procedure paint(const canvas: tcanvas; const rect: rectty); virtual;
   function outerframewidth: sizety; //widgetsize - framesize
   function frameframewidth: sizety; //widgetsize - (paintsize + paintframe)
   function paintframewidth: sizety; //widgetsize - paintsize
   function innerframewidth: sizety; //widgetsize - innersize
   function outerframe: framety;
   function paintframe: framety;     //fouterframe + fpaintframe
   function innerframe: framety;     //fouteerframe + fpaintframe + finnerframe
   function pointincaption(const point: pointty): boolean; virtual;
                                     //origin = widgetrect
   procedure initgridframe; virtual;

   property levelo: integer read fi.levelo write setlevelo
                     stored islevelostored default 0;
   property leveli: integer read fi.leveli write setleveli
                     stored islevelistored default 0;
   property framewidth: integer read fi.framewidth write setframewidth
                     stored isframewidthstored default 0;
   property colorframe: colorty read fi.colorframe write setcolorframe
                     stored iscolorframestored default cl_transparent;
   property framei_left: integer read fi.innerframe.left write setframei_left
                     stored isfileftstored default 0;
   property framei_top: integer read fi.innerframe.top  write setframei_top
                     stored isfitopstored default 0;
   property framei_right: integer read fi.innerframe.right write setframei_right
                     stored isfirightstored default 0;
   property framei_bottom: integer read fi.innerframe.bottom write setframei_bottom
                     stored isfibottomstored default 0;

   property colorclient: colorty read fi.colorclient write setcolorclient
                     stored iscolorclientstored default cl_transparent;
   property localprops: framelocalpropsty read flocalprops write setlocalprops default []; 
   property template: tframecomp read ftemplate write settemplate;
 end;

 tframe = class(tcustomframe)
  published
   property levelo;
   property leveli;
   property framewidth;
   property colorframe;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property colorclient;
   property localprops; //before template
   property template;
 end;

 tframetemplate = class(tpersistenttemplate)
  private
   procedure setcolorclient(const Value: colorty);
   procedure setcolorframe(const Value: colorty);
   procedure setframei_bottom(const Value: integer);
   procedure setframei_left(const Value: integer);
   procedure setframei_right(const Value: integer);
   procedure setframei_top(const Value: integer);
   procedure setframewidth(const Value: integer);
   procedure setleveli(const Value: integer);
   procedure setlevelo(const Value: integer);
  protected
   fi: frameinfoty;
   procedure doassignto(dest: tpersistent); override;
   function getinfosize: integer; override;
   function getinfoad: pointer; override;
  public
   constructor create(const owner: tmsecomponent;
                  const onchange: notifyeventty); override;
   procedure draw3dframe(const acanvas: tcanvas; const arect: rectty);
                                       //arect = paintrect
  published
   property levelo: integer read fi.levelo write setlevelo default 0;
   property leveli: integer read fi.leveli write setleveli default 0;
   property framewidth: integer read fi.framewidth write setframewidth default 0;
   property colorframe: colorty read fi.colorframe write setcolorframe default cl_transparent;
   property framei_left: integer read fi.innerframe.left write setframei_left default 0;
   property framei_top: integer read fi.innerframe.top write setframei_top default 0;
   property framei_right: integer read fi.innerframe.right write setframei_right default 0;
   property framei_bottom: integer read fi.innerframe.bottom write setframei_bottom default 0;
   property colorclient: colorty read fi.colorclient write setcolorclient default cl_transparent;
 end;

 tframecomp = class(ttemplatecontainer)
  private
   function gettemplate: tframetemplate;
   procedure settemplate(const Value: tframetemplate);
  protected
   function gettemplateclass: templateclassty; override;
  public
  published
   property template: tframetemplate read gettemplate write settemplate;
 end;

 iface = interface(inullinterface)
  function getwidget: twidget;
  function translatecolor(const acolor: colorty): colorty;
 end;

 faceoptionty = (fao_alphafadeimage,fao_alphafadenochildren,fao_alphafadeall);
 faceoptionsty = set of faceoptionty;

 faceinfoty = record
  options: faceoptionsty;
  fade_direction: graphicdirectionty;
  image: tmaskedbitmap;
  fade_pos: trealarrayprop;
  fade_color: tcolorarrayprop;
  fade_transparency: colorty;
 end;

 tfacecomp = class;
 tcustomface = class(toptionalpersistent)
  private
   fi: faceinfoty;
   flocalprops: facelocalpropsty;
   ftemplate: tfacecomp;
   falphabuffer: tmaskedbitmap;
   falphabufferdest: pointty;
   procedure settemplateinfo(const ainfo: faceinfoty);
   procedure setoptions(const avalue: faceoptionsty);
   function isoptionsstored: boolean;
   procedure setimage(const value: tmaskedbitmap);
   function isimagestored: boolean;
   procedure setfade_color(const Value: tcolorarrayprop);
   function isfacolorstored: boolean;
   procedure setfade_pos(const Value: trealarrayprop);
   function isfaposstored: boolean;
   procedure setfade_direction(const Value: graphicdirectionty);
   function isfadirectionstored: boolean;
   procedure setfade_transparency(const avalue: colorty);
   function isfatransparencystored: boolean;
   procedure settemplate(const avalue: tfacecomp);
//   function arepropsstored: boolean;
   procedure setlocalprops(const avalue: facelocalpropsty);
  protected
   fintf: iface;
   procedure dochange(const sender: tarrayprop; const index: integer);
   procedure change;
   procedure imagechanged(const sender: tobject);
   procedure internalcreate;
   procedure doalphablend(const canvas: tcanvas);
  public
   constructor create(const owner: twidget); reintroduce; overload;//sets fowner.fframe
   constructor create(const intf: iface); reintroduce; overload;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
   procedure paint(const canvas: tcanvas; const rect: rectty); virtual;
   property options: faceoptionsty read fi.options write setoptions
                   stored isoptionsstored default [];
   property image: tmaskedbitmap read fi.image write setimage
                     stored isimagestored;
   property fade_pos: trealarrayprop read fi.fade_pos write setfade_pos
                    stored isfaposstored;
   property fade_color: tcolorarrayprop read fi.fade_color write setfade_color
                    stored isfacolorstored;
   property fade_direction: graphicdirectionty read fi.fade_direction
                write setfade_direction stored isfadirectionstored default gd_right ;
   property fade_transparency: colorty read fi.fade_transparency
              write setfade_transparency stored isfatransparencystored default cl_none;
   property localprops: facelocalpropsty read flocalprops write setlocalprops default []; 
                                   //before template
   property template: tfacecomp read ftemplate write settemplate;
 end;

 tface = class(tcustomface)
  published
   property options;
   property image;
   property fade_pos;
   property fade_color;
   property fade_direction;
   property fade_transparency;
   property localprops;          //before template
   property template;
 end;

 tfacetemplate = class(tpersistenttemplate)
  private
   fi: faceinfoty;
   procedure setoptions(const avalue: faceoptionsty);
   procedure setfade_color(const Value: tcolorarrayprop);
   procedure setfade_direction(const Value: graphicdirectionty);
   procedure setfade_pos(const Value: trealarrayprop);
   procedure setfade_transparency(const avalue: colorty);
   procedure setimage(const Value: tmaskedbitmap);
   procedure doimagechange(const sender: tobject);
   procedure dochange(const sender: tarrayprop; const index: integer);
  protected
   procedure doassignto(dest: tpersistent); override;
   function getinfosize: integer; override;
   function getinfoad: pointer; override;
   procedure copyinfo(const source: tpersistenttemplate); override;
  public
   constructor create(const owner: tmsecomponent; const onchange: notifyeventty); override;
   destructor destroy; override;
  published
   property options: faceoptionsty read fi.options write setoptions default [];
   property image: tmaskedbitmap read fi.image write setimage;
   property fade_pos: trealarrayprop read fi.fade_pos write setfade_pos;
   property fade_color: tcolorarrayprop read fi.fade_color write setfade_color;
   property fade_direction: graphicdirectionty read fi.fade_direction
                write setfade_direction default gd_right;
   property fade_transparency: colorty read fi.fade_transparency
              write setfade_transparency default cl_none;
 end;

 tfacecomp = class(ttemplatecontainer)
  private
   function gettemplate: tfacetemplate;
   procedure settemplate(const Value: tfacetemplate);
  protected
   function gettemplateclass: templateclassty; override;
  public
  published
   property template: tfacetemplate read gettemplate write settemplate;
 end;

 mouseeventty = procedure (const sender: twidget; var info: mouseeventinfoty) of object;
 keyeventty = procedure (const sender: twidget; var info: keyeventinfoty) of object;
 painteventty = procedure (const sender: twidget; const canvas: tcanvas) of object;
 pointeventty = procedure(const sender: twidget; const point: pointty) of object;
 widgeteventty = procedure(const sender: tobject; const awidget: twidget) of object;

 widgetatposinfoty = record
  pos: pointty;
  parentstate,childstate: widgetstatesty
 end;

 widgetarty = array of twidget;

 twindow = class;

 windowoptionty = (wo_popup,wo_message,wo_buttonendmodal,wo_groupleader);
 windowoptionsty = set of windowoptionty;

 windowposty = (wp_normal,wp_screencentered,wp_minimized,wp_maximized,wp_default);

 windowinfoty = record
  options: windowoptionsty;
  initialwindowpos: windowposty;
  transientfor: twindow;
  groupleader: twindow;
  icon,iconmask: pixmapty;
 end;

 naviginfoty = record
  sender: twidget;
  direction: graphicdirectionty;
  startingrect: rectty;
  distance: integer;
  nearest: twidget;
  down: boolean;
 end;

 twidgetfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 pdragobject = ^tdragobject;
 tdragobject = class
  private
   finstancepo: pdragobject;
   fpickpos: pointty;
  protected
   fsender: tobject;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
                          const apickpos: pointty);
   destructor destroy; override;
   function sender: tobject;
   procedure acepted(const apos: pointty); virtual; //screenorigin
   procedure refused(const apos: pointty); virtual;
   property pickpos: pointty read fpickpos;         //screenorigin
 end;

 drageventkindty = (dek_begin,dek_check,dek_drop);

 draginfoty = record
  eventkind: drageventkindty;
  pos: pointty;     //origin = clientrect.pos
  pickpos: pointty; //origin = screenorigin
  dragobject: pdragobject;
  accept: boolean;
 end;

 iactivator = interface(inullinterface)
 end;
 iactivatorclient = interface(inullinterface)
 end;
 
 tactivator = class;

 tguicomponent = class(tmsecomponent,iactivator)
  private
   factivator: tactivator;
   procedure setactivator(const avalue: tactivator);
  protected
   procedure receiveevent(const event: tobjectevent); override;
   procedure doasyncevent(var atag: integer); virtual;
   procedure designchanged; //for designer notify
   procedure loaded; override;
   procedure doactivated; virtual;
   procedure dodeactivated; virtual;
   procedure objectevent(const sender: tobject;
                          const event: objecteventty); override;
  public
   procedure asyncevent(atag: integer = 0);
                          //posts event for doasyncevent to self
   procedure postcomponentevent(const event: tcomponentevent);
   property activator: tactivator read factivator write setactivator;
 end;

 activatoroptionty = (avo_activateonloaded,avo_activatedelayed,
                                    avo_deactivateonterminated);
 activatoroptionsty = set of activatoroptionty;
 
 tactivator = class(tguicomponent)
  private
   foptions: activatoroptionsty;
   fonbeforeactivate: notifyeventty;
   fonafteractivate: notifyeventty;
   fonbeforedeactivate: notifyeventty;
   fonafterdeactivate: notifyeventty;
   factive: boolean;
   procedure readclientnames(reader: treader);
   procedure writeclientnames(writer: twriter);
   function getclients: integer;
   procedure setclients(const avalue: integer);
   procedure setoptions(const avalue: activatoroptionsty);
   procedure setactive(const avalue: boolean);
  protected
   fclientnames: stringarty;
   fclients: pointerarty;
   procedure registerclient(const aclient: iobjectlink);
   procedure unregisterclient(const aclient: iobjectlink);
   procedure updateorder;
   function getclientname(const avalue: tobject; const aindex: integer): string;
   function getclientnames: stringarty;
   procedure defineproperties(filer: tfiler); override;
   procedure doasyncevent(var atag: integer); override;
   procedure loaded; override;
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); override;
   procedure objevent(const sender: iobjectlink;
                         const event: objecteventty); override;
   procedure doterminated(const sender: tobject);   
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   class procedure addclient(const aactivator: tactivator; const aclient: iobjectlink;
                    var dest: tactivator);
   procedure activateclients;
   procedure deactivateclients;
  published
   property clients: integer read getclients write setclients; 
                                  //hook for object inspector
   property options: activatoroptionsty read foptions write setoptions;
   property active: boolean read factive write setactive stored false;
   property onbeforeactivate: notifyeventty read fonbeforeactivate
                           write fonbeforeactivate;
   property onafteractivate: notifyeventty read fonafteractivate 
                           write fonafteractivate;
   property onbeforedeactivate: notifyeventty read fonbeforedeactivate 
                            write fonbeforedeactivate;
   property onafterdeactivate: notifyeventty read fonbeforedeactivate 
                            write fonafterdeactivate;
   property activator;
 end;
 
 twidgetevent = class(tcomponentevent)
 end;

 widgetalignmodety = (wam_start,wam_center,wam_end);
 widgetclassty = class of twidget;
 
 twidget = class(tguicomponent,iframe,iface)
  private
   fwidgetregion: regionty;
   frootpos: pointty;   //position in rootwindow
   fcursor: cursorshapety;
   ftaborder: integer;
   fminsize,fmaxsize: sizety;
   fminclientsize: sizety;
   ffocusedchild,ffocusedchildbefore: twidget;
   ffontheight: integer;
   fsetwidgetrectcount: integer; //for recursive setpos

   procedure invalidateparentminclientsize;
   function minclientsize: sizety;
   function getwidgets(const index: integer): twidget;

   procedure setpos(const Value: pointty);
   procedure setsize(const Value: sizety);
   procedure setbounds_x(const Value: integer);
   procedure setbounds_y(const Value: integer);
   procedure setbounds_cx(const Value: integer);
   procedure setbounds_cy(const Value: integer);
   procedure updatesizerange(value: integer; var dest: integer); overload;
   procedure updatesizerange(const value: sizety; var dest: sizety); overload;
   procedure setbounds_cxmax(const Value: integer);
   procedure setbounds_cymax(const Value: integer);
   procedure setbounds_cxmin(const Value: integer);
   procedure setbounds_cymin(const Value: integer);
   procedure setminsize(const avalue: sizety);
   procedure setmaxsize(const avalue: sizety);

   procedure setcursor(const Value: cursorshapety);
   procedure setcolor(const Value: colorty);
   function getsize: sizety;

   procedure updateopaque(const children: boolean);
   function invalidateneeded: boolean;
   procedure updateroot;
   procedure addopaquechildren(var region: regionty);
   procedure updatewidgetregion;
   function isclientmouseevent(var info: mouseeventinfoty): boolean;
   procedure internaldofocus;
   procedure internaldodefocus;
   procedure internaldoenter;
   procedure internaldoexit;
   procedure internaldoactivate;
   procedure internaldodeactivate;
   procedure internalkeydown(var info: keyeventinfoty);
   function checksubfocus(const aactivate: boolean): boolean;

   function clipcaret: rectty; //origin = pos
   procedure reclipcaret;
   procedure updatetaborder(awidget: twidget);
   procedure settaborder(const Value: integer);
   procedure dofontchanged(const sender: tobject);
   procedure parentfontchanged;
   procedure setanchors(const Value: anchorsty);

   function getzorder: integer;
   procedure setzorder(const value: integer);
   procedure widgetregioninvalid;

   function getparentclientpos: pointty;
   procedure setparentclientpos(const avalue: pointty);

   function getscreenpos: pointty;
   procedure setscreenpos(const avalue: pointty);

   function getclientoffset: pointty;
   function calcframewidth(arect: prectty): sizety;

   procedure readfontheight(reader: treader);
   procedure writefontheight(writer: twriter);
   procedure updatefontheight;

   procedure checkwidgetsize(var size: sizety);
              //check size constraints
  protected
   fwidgets: widgetarty;
   fnoinvalidate: integer;
   foptionswidget: optionswidgetty;
   fparentwidget: twidget;
   fanchors: anchorsty;
   fwidgetstate: widgetstatesty;
   fwidgetstate1: widgetstates1ty;
   fcolor: colorty;
   fwindow: twindow;
   fwidgetrect: rectty;
   fparentclientsize: sizety;
   fframe: tcustomframe;
   fface: tcustomface;
   ffont: twidgetfont;
   fhint: msestring;
   fdefaultfocuschild: twidget;

   procedure defineproperties(filer: tfiler); override;
   function gethelpcontext: msestring; override;

   function navigstartrect: rectty; virtual; //org = clientpos
   function navigrect: rectty; virtual;      //org = clientpos
   procedure navigrequest(var info: naviginfoty);
   function navigdistance(var info: naviginfoty): integer; virtual;

   function gethint: msestring; virtual;
   procedure sethint(const Value: msestring); virtual;
   function ishintstored: boolean; virtual;
   function getshowhint: boolean;
   procedure showhint(var info: hintinfoty); virtual;

   function isgroupleader: boolean; virtual;
   function needsfocuspaint: boolean; virtual;
   function getenabled: boolean;
   procedure setenabled(const Value: boolean); virtual;
   function getvisible: boolean;
   procedure setvisible(const Value: boolean); virtual;
   function isvisible: boolean;      //checks designing
   function parentisvisible: boolean;//checks isvisible flags of ancestors
   function parentvisible: boolean;  //checks visible flags of ancestors

   //iframe
   procedure setframeinstance(instance: tcustomframe); virtual;
   procedure setstaticframe(value: boolean);
   function getwidgetrect: rectty;
   function getcomponentstate: tcomponentstate;

   //igridcomp,itabwidget
   function getwidget: twidget;

   function getframe: tcustomframe;
   procedure setframe(const avalue: tcustomframe);
   function getface: tcustomface;
   procedure setface(const avalue: tcustomface);
   function getinnerstframe: framety; virtual;

   procedure createwindow; virtual;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure setparentcomponent(value: tcomponent); override;
   procedure setparentwidget(const Value: twidget); virtual;
   procedure updatewindowinfo(var info: windowinfoty); virtual;
   procedure windowcreated; virtual;
   procedure setoptionswidget(const avalue: optionswidgetty); virtual;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;

   function getcaretcliprect: rectty; virtual;  //origin = clientrect.pos
   procedure loaded; override;

   procedure updatemousestate(const apos: pointty); virtual;
                                   //updates fstate about mouseposition
   procedure setclientclick; //grabs mouse and sets clickflags

   procedure registerchildwidget(const child: twidget); virtual;
   procedure unregisterchildwidget(const child: twidget); virtual;
   function isfontstored: Boolean;
   procedure setfont(const avalue: twidgetfont);
   function getfont: twidgetfont;
   function getframefont: tfont;
   procedure fontchanged; virtual;

   procedure parentclientrectchanged; virtual;
   procedure widgetregionchanged(const sender: twidget); virtual;
   procedure statechanged; virtual; //enabled,active,visible
   procedure enabledchanged; virtual;
   procedure activechanged; virtual;
   procedure visiblechanged; virtual;
   procedure colorchanged; virtual;
   procedure sizechanged; virtual;
   procedure poschanged; virtual;
   procedure clientrectchanged; virtual;
   procedure rootchanged; virtual;
   function getdefaultfocuschild: twidget; virtual;
                                   //returns first focusable widget
   procedure setdefaultfocuschild(const value: twidget); virtual;
   procedure sortzorder;
   procedure clampinview(const arect: rectty; const bottomright: boolean); virtual;
                    //origin paintpos

   procedure internalpaint(const canvas: tcanvas);
   function needsdesignframe: boolean; virtual;
   procedure dobeforepaint(const canvas: tcanvas); virtual;
   procedure dopaintbackground(const canvas: tcanvas); virtual;
   procedure dopaint(const canvas: tcanvas); virtual;
   procedure dobeforepaintforeground(const canvas: tcanvas); virtual;
   procedure doonpaint(const canvas: tcanvas); virtual;
   procedure doafterpaint(const canvas: tcanvas); virtual;

   procedure doscroll(const dist: pointty); virtual;

   procedure dohide; virtual;
   procedure doshow; virtual;
   procedure doactivate; virtual;
   procedure dodeactivate; virtual;
   procedure doenter; virtual;
   procedure doexit; virtual;
   procedure dofocus; virtual;
   procedure dodefocus; virtual;
   procedure dochildfocused(const sender: twidget); virtual;

   procedure reflectmouseevent(var info: mouseeventinfoty);
                                  //posts mousevent to window under mouse
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); virtual;
   procedure childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty); virtual;

   procedure dokeydown(var info: keyeventinfoty); virtual;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); virtual;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; virtual;
   procedure dokeydownaftershortcut(var info: keyeventinfoty); virtual;
   procedure dokeyup(var info: keyeventinfoty); virtual;

   procedure setfontheight;
   procedure postchildscaled;
   procedure dofontheightdelta(var delta: integer); virtual;
   procedure syncsinglelinefontheight;

   procedure setwidgetrect(const Value: rectty);
   procedure internalsetwidgetrect(Value: rectty; const windowevent: boolean);
   function getclientsize: sizety;
   procedure setclientsize(const asize: sizety); virtual; //used in tscrollingwidget
   function getclientwidth: integer;
   procedure setclientwidth(const avalue: integer);
   function getclientheight: integer;
   procedure setclientheight(const avalue: integer);
   function internalshow(const modal: boolean; transientfor: twindow;
           const windowevent: boolean): modalresultty; virtual;
   procedure internalhide(const windowevent: boolean);
   function getnextfocus: twidget;
   function cantabfocus: boolean;
   function getdisprect: rectty; virtual; 
                //origin pos, clamped in view by activate

   function calcminscrollsize: sizety; virtual;
   function getcontainer: twidget; virtual;
   function getchildwidgets(const index: integer): twidget; virtual;
   function gettaborderedwidgets: widgetarty;

   function getright: integer;       //if placed in datamodule
   procedure setright(const avalue: integer);
   function getbottom: integer;
   procedure setbottom(const avalue: integer);
   function ownswindow1: boolean;    //does not check winid

   procedure createframe1; virtual;
   procedure createface1; virtual;
   procedure createfont1;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure afterconstruction; override;
   procedure initnewcomponent; override;
   procedure createframe;
   procedure createface;
   procedure createfont;
   
   function widgetstate: widgetstatesty;                 //iframe
   property widgetstate1: widgetstates1ty read fwidgetstate1;
   function hasparent: boolean; override;               //tcomponent
   function getparentcomponent: tcomponent; override;   //tcomponent
   function hascaret: boolean;
   function ownswindow: boolean;
                      //true if valid toplevelwindow with assigned winid

   function canclose(const newfocus: twidget): boolean; virtual;
   function canparentclose(const newfocus: twidget): boolean; overload;
                   //window.focusedwidget is first checked of it is descendant
   function canparentclose: boolean; overload;
                   //newfocus = window.focusedwidget      
   function canfocus: boolean; virtual;
   function setfocus(aactivate: boolean = true): boolean; //true if ok
   procedure nextfocus; //sets inputfocus to then next appropriate widget
   function findtabfocus(const ataborder: integer): twidget;
                       //nil if can not focus
   function firsttabfocus: twidget;
   function lasttabfocus: twidget;
   function nexttaborder(const down: boolean = false): twidget;
   function focusback(const aactivate: boolean = true): boolean;
                               //false if focus not changed

   function parentcolor: colorty;
   function actualcolor: colorty; virtual;
   function translatecolor(const acolor: colorty): colorty;

   procedure widgetevent(const event: twidgetevent); virtual;
   procedure sendwidgetevent(const event: twidgetevent);
                              //event will be destroyed

   procedure release; virtual;
   function show(const modal: boolean = false;
            const transientfor: twindow = nil): modalresultty; virtual;
   procedure hide;
   procedure activate(const bringtofront: boolean = true);
                             //show and setfocus
   procedure bringtofront;
   procedure sendtoback;
   procedure stackunder(const predecessor: twidget);

   procedure update; virtual;
   procedure updatecursorshape(force: boolean = false);
   procedure scrollwidgets(const dist: pointty);
   procedure scrollrect(const dist: pointty; const rect: rectty; scrollcaret: boolean);
                             //origin = paintrect.pos
   procedure scroll(const dist: pointty);
                            //scrolls paintrect and widgets
   procedure getcaret;
   procedure scrollcaret(const dist: pointty);
   procedure capturemouse(grab: boolean = true);
   procedure releasemouse;
   procedure synctofontheight; virtual;

   procedure dragevent(var info: draginfoty); virtual;
   procedure dochildscaled(const sender: twidget); virtual;

   procedure invalidatewidget;     //invalidates whole widget
   procedure invalidate;           //invalidates clientrect
   procedure invalidaterect(const rect: rectty; org: originty = org_client);

   function window: twindow;
   function rootwidget: twidget;
   function parentofcontainer: twidget;
            //parentwidget.parentwidget if parentwidget has not ws_iswidget,
            //parentwidget otherwise
   property parentwidget: twidget read fparentwidget write setparentwidget;
   function getrootwidgetpath: widgetarty;
   function widgetcount: integer;
   function parentwidgetindex: integer; //index in parentwidget.widgets, -1 if none
   property widgets[const index: integer]: twidget read getwidgets;
   function widgetatpos(var info: widgetatposinfoty): twidget; overload;
   function widgetatpos(const pos: pointty): twidget; overload;
   function widgetatpos(const pos: pointty; 
                   const state: widgetstatesty): twidget; overload;
   property taborderedwidgets: widgetarty read gettaborderedwidgets;
   function findtagwidget(const atag: integer; const aclass: widgetclassty): twidget;
              //returns first matching descendent

   property container: twidget read getcontainer;
   function childrencount: integer; virtual;
   property children[const index: integer]: twidget read getchildwidgets; default;
   function childatpos(const pos: pointty; 
                   const clientorigin: boolean = true): twidget; virtual;
   function getsortxchildren: widgetarty;
   function getsortychildren: widgetarty;
   property focusedchild: twidget read ffocusedchild;
   property focusedchildbefore: twidget read ffocusedchildbefore;

   function mouseeventwidget(const info: mouseeventinfoty): twidget;
   function checkdescendent(widget: twidget): boolean;
                    //true if widget is descendent or self
   function checkancestor(widget: twidget): boolean;
                    //true if widget is ancestor or self
   function containswidget(awidget: twidget): boolean;

   procedure insertwidget(const awidget: twidget); overload;
   procedure insertwidget(const awidget: twidget; const apos: pointty); overload; virtual;
                 //widget can be child

   function iswidgetclick(const info: mouseeventinfoty; caption: boolean = false): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
   //or in frame.caption if caption = true, origin = pos
   function isclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
   //origin = paintrect.pos
   function isdblclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonpress, button is mb_left, pos in clientrect
   // and timedlay to last buttonpress is short
   function isdblclicked(const info: mouseeventinfoty): boolean;
   //true if eventtype in [et_buttonpress,et_butonrelease], button is mb_left,
   // and timedlay to last same buttonevent is short
   function isleftbuttondown(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonpress, button is mb_left, pos in clientrect
   //origin = paintrect.pos

   function rootpos: pointty;
   property screenpos: pointty read getscreenpos write setscreenpos;
   function clientpostowidgetpos(const apos: pointty): pointty;
   function widgetpostoclientpos(const apos: pointty): pointty;
   function widgetpostopaintpos(const apos: pointty): pointty;
   function paintpostowidgetpos(const apos: pointty): pointty;

   property widgetrect: rectty read getwidgetrect write setwidgetrect;
   property pos: pointty read fwidgetrect.pos write setpos;
   property size: sizety read fwidgetrect.size write setsize;
   property minsize: sizety read fminsize write setminsize;
   property maxsize: sizety read fmaxsize write setmaxsize;
   property bounds_x: integer read fwidgetrect.x write setbounds_x nodefault;
   property bounds_y: integer read fwidgetrect.y write setbounds_y nodefault;
   property bounds_cx: integer read fwidgetrect.cx write setbounds_cx
                  {default defaultwidgetwidth} stored true;
   property bounds_cy: integer read fwidgetrect.cy write setbounds_cy
                  {default defaultwidgetheight} stored true;
   property bounds_cxmin: integer read fminsize.cx write setbounds_cxmin default 0;
   property bounds_cymin: integer read fminsize.cy write setbounds_cymin default 0;
   property bounds_cxmax: integer read fmaxsize.cx write setbounds_cxmax default 0;
   property bounds_cymax: integer read fmaxsize.cy write setbounds_cymax default 0;

   property left: integer read fwidgetrect.x write setbounds_x;
   property right: integer read getright write setright;
                        //widgetrect.x + widgetrect.cx, sets cx;
   property top: integer read fwidgetrect.y write setbounds_y;
   property bottom: integer read getbottom write setbottom;
                        //widgetrect.y + widgetrect.cy, sets cy;
   property width: integer read fwidgetrect.cx write setbounds_cx;
   property height: integer read fwidgetrect.cy write setbounds_cy;

   property anchors: anchorsty read fanchors write setanchors default defaultanchors;
   property defaultfocuschild: twidget read getdefaultfocuschild write setdefaultfocuschild;

   function framewidth: sizety;              //widgetrect.size - paintrect.size
   function clientframewidth: sizety;        //widgetrect.size - clientrect.size
   function innerclientframewidth: sizety;   //widgetrect.size - innerclientrect.size
   function framerect: rectty;               //origin = pos
   function framepos: pointty;               //origin = pos
   function framesize: sizety;
   function paintrect: rectty;               //origin = pos
   function paintpos: pointty;               //origin = pos
   function paintsize: sizety;
   function clipedpaintrect: rectty;         //origin = pos, cliped by all parentpaintrects
   function innerpaintrect: rectty;          //origin = pos

   function clientrect: rectty;              //origin = paintrect.pos
   procedure changeclientsize(const delta: sizety); //asynchronous
   property clientsize: sizety read getclientsize write setclientsize;
   property clientwidth: integer read getclientwidth write setclientwidth;
   property clientheight: integer read getclientheight write setclientheight;
   function clientpos: pointty;              //origin = paintrect.pos;
   function clientwidgetpos: pointty;        //origin = pos
   function clientparentpos: pointty;        //origin = parentwidget.pos
   property parentclientpos: pointty read getparentclientpos write setparentclientpos;
   function paintparentpos: pointty;         //origin = parentwidget.pos
                                             //origin = parentwidget.clientpos
   function innerwidgetrect: rectty;         //origin = pos
   function innerclientrect: rectty;         //origin = clientpos
   function innerclientsize: sizety;
   function innerclientpos: pointty;         //origin = clientpos
   function innerclientwidgetpos: pointty;   //origin = pos


   property frame: tcustomframe read getframe write setframe;
   property face: tcustomface read getface write setface;

   function getcanvas(aorigin: originty = org_client): tcanvas;
   function showing: boolean;
               //true if self and all ancestors visible and window allocated
   function isenabled: boolean;
               //true if self and all ancestors enabled

   function active: boolean;
   function entered: boolean;
   function focused: boolean;
   function clicked: boolean;

   function indexofwidget(const awidget: twidget): integer;

   procedure placexorder(const startx: integer; const dist: array of integer;
                const awidgets: array of twidget;
                const endmargin: integer = minint);
               //origin = clientpos, endmargin by size adjust of widgets 
               //with [an_left,an_right], minit -> no change
   procedure placeyorder(const starty: integer; const dist: array of integer;
                const awidgets: array of twidget;
                const endmargin: integer = minint);
               //origin = clientpos, endmargin by size adjust of widgets 
               //with [an_top,an_bottom], minit -> no change
   function aligny(const mode: widgetalignmodety;
                        const awidgets: array of twidget): integer;
                        //returns reference point
   function alignx(const mode: widgetalignmodety;
                        const awidgets: array of twidget): integer;
                        //returns reference point

   property optionswidget: optionswidgetty read foptionswidget write setoptionswidget
                    default defaultoptionswidget;
   property cursor: cursorshapety read fcursor write setcursor default cr_default;
   property color: colorty read fcolor write setcolor default defaultwidgetcolor;
   property visible: boolean read getvisible write setvisible default true;
   property enabled: boolean read getenabled write setenabled default true;
   property taborder: integer read ftaborder write settaborder default 0;
   property hint: msestring read gethint write sethint stored ishintstored;
   property zorder: integer read getzorder write setzorder;
 end;

 windowstatety = (tws_posvalid,tws_sizevalid,tws_windowvisible,
                  tws_modal,tws_needsdefaultpos,
                  tws_closing,tws_globalshortcuts,tws_localshortcuts,
                  tws_buttonendmodal,tws_grouphidden,tws_groupminimized,
                  tws_grab,tws_painting);
 windowstatesty = set of windowstatety;

 internalwindowoptionsty = record
  options: windowoptionsty;
  pos: windowposty;
  transientfor: winidty;
  setgroup: boolean;
  groupleader: winidty;
  icon,iconmask: pixmapty;
 end;

 pmodalinfoty = ^modalinfoty;
 modalinfoty = record
  modalend: boolean;
  modalwindowbefore: twindow;
 end;

 windowsizety = (wsi_normal,wsi_minimized,wsi_maximized);

 twindow = class(teventobject,icanvas)
  private
   fwinid: winidty;
   fstate: windowstatesty;
   ffocuscount: cardinal; //for recursive setwidgetfocus
   factivecount: cardinal; //for recursive activate,deactivate
   ffocusedwidget: twidget;
   fmodalinfopo: pmodalinfoty;
   foptions: windowoptionsty;
   ftransientfor: twindow;
   ftransientforcount: integer;
   fwindowpos: windowposty;
   fnormalwindowrect: rectty;
   fcaption: msestring;

   procedure setcaption(const avalue: msestring);
   procedure widgetdestroyed(widget: twidget);

   procedure showed;
   procedure hidden;
   procedure activated;
   procedure deactivated;
   procedure wmconfigured(const arect: rectty);
   procedure windowdestroyed;

   function internalupdate: boolean;
           //updates screen representation, false if nothing is painted
   function canactivate: boolean;
     //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
   function getsize: sizety;

   procedure checkrecursivetransientfor(const value: twindow);
   procedure settransientfor(const Value: twindow; const windowevent: boolean);
   procedure sizeconstraintschanged;
   procedure createwindow;
   procedure checkwindow(windowevent: boolean);
   procedure destroywindow;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); virtual;
                                      //nil if from application
   procedure show(windowevent: boolean);
   procedure hide(windowevent: boolean);
   procedure deactivate;
   procedure setfocusedwidget(widget: twidget);
   procedure setmodalresult(const Value: modalresultty);
   function getglobalshortcuts: boolean;
   function getlocalshortcuts: boolean;
   procedure setglobalshortcuts(const Value: boolean);
   procedure setlocalshortcuts(const Value: boolean);
   function getbuttonendmodal: boolean;
   procedure setbuttonendmodal(const value: boolean);
  protected
   fowner: twidget;
   fcanvas: tcanvas;
   fasynccanvas: tcanvas;
   fmodalresult: modalresultty;
   fupdateregion: regionty;
   function getwindowsize: windowsizety;
   procedure setwindowsize(const value: windowsizety);
   function getwindowpos: windowposty;
   procedure setwindowpos(const Value: windowposty);
   procedure invalidaterect(const rect: rectty; const sender: twidget = nil);
                       //clipped by paintrect of sender.parentwidget
   procedure mouseparked;
   procedure movewindowrect(const dist: pointty; const rect: rectty); virtual;
   procedure checkmousewidget(const info: mouseeventinfoty; var capture: twidget);
   procedure dispatchmouseevent(var info: mouseeventinfoty; capture: twidget); virtual;
   procedure dispatchkeyevent(const eventkind: eventkindty; var info: keyeventinfoty); virtual;
   procedure sizechanged; virtual;
   procedure poschanged; virtual;
   procedure internalactivate(const windowevent: boolean;
                                 const force: boolean = false);
   procedure setzorder(const value: integer);
  public
   constructor create(aowner: twidget);
   destructor destroy; override;
   function beginmodal: boolean; //true if window destroyed
   procedure endmodal;
   procedure activate;
   procedure update;
   function candefocus: boolean;
   procedure nofocus;
   function close: boolean; //true if ok
   procedure bringtofront;
   procedure sendtoback;
   procedure stackunder(const predecessor: twindow);
       //stacking is performed in mainloop idle, nil means top
   procedure stackover(const predecessor: twindow);
       //stacking is performed in mainloop idle, nil means bottom
   function stackedunder: twindow; //nil if top
   function stackedover: twindow;  //nil if bottom

   procedure capturemouse;
   procedure releasemouse;

   function winid: winidty;
   function state: windowstatesty;
   function visible: boolean;
   function normalwindowrect: rectty;

   procedure registermovenotification(sender: iobjectlink);
   procedure unregistermovenotification(sender: iobjectlink);

   property options: windowoptionsty read foptions;
   property owner: twidget read fowner;
   property focusedwidget: twidget read ffocusedwidget;
   property transientfor: twindow read ftransientfor;
   property modalresult: modalresultty read fmodalresult write setmodalresult;
   property buttonendmodal: boolean read getbuttonendmodal write setbuttonendmodal;
   property globalshortcuts: boolean read getglobalshortcuts write setglobalshortcuts;
   property localshortcuts: boolean read getlocalshortcuts write setlocalshortcuts;
   property windowpos: windowposty read getwindowpos write setwindowpos;
   property caption: msestring read fcaption write setcaption;
 end;

 windowarty = array of twindow;
 pwindowarty = ^windowarty;
 windowaty = array[0..0] of twindow;
 pwindowaty = ^windowaty;

 activechangeeventty = procedure(const oldwindow,newwindow: twindow) of object;
 windoweventty = procedure(const awindow: twindow) of object;
 booleaneventty = procedure(const avalue: boolean) of object;

 twindowevent = class(tevent)
  private
  public
   fwinid: winidty;
   constructor create(akind: eventkindty; winid: winidty);
 end;

 twindowrectevent = class(twindowevent)
  private
  public
   frect: rectty;
   constructor create(akind: eventkindty; winid: winidty; const rect: rectty);
 end;

 tmouseevent = class(twindowevent)
  private
   ftimestamp: cardinal;
  public
   fpos: pointty;
   fbutton: mousebuttonty;
   fshiftstate: shiftstatesty;
   freflected: boolean;
   property timestamp: cardinal read ftimestamp; //0 -> invalid
   constructor create(winid: winidty; release: boolean; button: mousebuttonty;
                      pos: pointty; shiftstate: shiftstatesty; atimestamp: cardinal;
                      reflected: boolean = false);
                      //button = none for mousemove
 end;

 tkeyevent = class(twindowevent)
  private
  public
   fkey: keyty;
   fkeynomod: keyty;
   fchars: msestring;
   fbutton: mousebuttonty;
   fshiftstate: shiftstatesty;
   constructor create(const winid: winidty; const release: boolean;
                  const key,keynomod: keyty; const shiftstate: shiftstatesty;
                  const chars: msestring);
 end;

 tresizeevent = class(tobjectevent)
  public
   size: sizety;
   constructor create(const dest: ievent; const asize: sizety);
 end;

 applicationstatety = (aps_inited,aps_running,aps_terminated,aps_mousecaptured,
                       aps_invalidated,aps_zordervalid,aps_needsupdatewindowstack,
                       aps_focused,aps_activewindowchecked,aps_exitloop,
                       aps_active,aps_waiting);
 applicationstatesty = set of applicationstatety;

 exceptioneventty = procedure (sender: tobject; e: exception) of object;
 terminatequeryeventty = procedure (var terminate: boolean) of object;
 idleeventty = procedure (var again: boolean) of object;

 tapplication = class(tmsecomponent)
  private
   fwindows: tpointerlist;
   factivewindow: twindow;
   fwantedactivewindow: twindow; //set by twindow.activate if modal
   ffocuslockwindow: twindow;
   ffocuslocktransientfor: twindow;
   fstate: applicationstatesty;
   fmouse: tmouse;
   fcaret: tcaret;
   fmousecapturewidget: twidget;
   fmousewidget: twidget;
   fclientmousewidget: twidget;
   fonexception: exceptioneventty;
   fhintedwidget: twidget;
   fhintinfo: hintinfoty;
   flockthread: threadty;
   flockcount: integer;
   fmainwindow: twindow;
   fapplicationname: filenamety;
   fthread: threadty;
   fdblclicktime: integer;
   fexceptionactive: integer;
   fwaitcount: integer;
   fidlecount: integer;
   fcursorshape: cursorshapety;
   feventlooping: integer;
//   facursorshape: cursorshapety;
   fbuttonpresswidgetbefore: twidget;
   fbuttonreleasewidgetbefore: twidget;
   factmousewindow: twindow;
   function getterminated: boolean;
   procedure setterminated(const Value: boolean);
   procedure invalidated;
   function grabpointer(const id: winidty): boolean;
   function ungrabpointer: boolean;
   procedure setmousewidget(const widget: twidget);
   procedure setclientmousewidget(const widget: twidget);
   procedure capturemouse(sender: twidget; grab: boolean);
               //sender = nil for release
   function findwindow(id: winidty; out window: twindow): boolean;
   procedure activatehint;
   procedure deactivatehint;
   procedure hinttimer(const sender: tobject);
   procedure internalshowhint(const sender: twidget);
   procedure setmainwindow(const Value: twindow);
   procedure setcursorshape(const Value: cursorshapety);
   function getwindows(const index: integer): twindow;
   function dolock: boolean;
   function internalunlock(count: integer): boolean;
  protected  
   procedure eventloop(const once: boolean = false); 
                        //used in win32 wm_queryendsession and wm_entersizemove
   procedure exitloop;  //used in win32 cancelshutdown
  public
   procedure langchanged;
   procedure checkwindowrect(winid: winidty; var rect: rectty);
               //callback from win32 wm_sizing
   function ismainthread: boolean;
   procedure wakeupguithread;
   procedure initialize;
   procedure deinitialize;
   procedure run;
   procedure createdatamodule(instanceclass: datamoduleclassty; var reference);
   procedure createform(instanceclass: widgetclassty; var reference);
   function trylock: boolean;
   function lock: boolean;
    //synchronizes calling thread with main event loop (mutex),
    //false if calling thread allready holds the mutex
    //mutex is recursive
   function unlock: boolean;
    //release mutex if calling thread holds the mutex,
    //false if no unlock done
   function unlockall: integer;
    //release mutex recursive if calling thread holds the mutex,
    //returns count for relockall
   procedure relockall(count: integer);
   procedure synchronize(proc: objectprocty);
   procedure waitforthread(athread: tmsethread); //does unlock-relock before waiting

   procedure beginwait;
   procedure endwait;
   function waiting: boolean;
   function checkoverload(const asleepus: integer = 100000): boolean;
              //true if never idle since last call,
              // unlocks application and calls sleep if not mainthread and asleepus >= 0

   procedure handleexception(sender: tobject; const leadingtext: string = '');
   procedure showexception(e: exception; const leadingtext: string = '');
   procedure postevent(event: tevent);
   procedure inithintinfo(var info: hintinfoty; const ahintedwidget: twidget);
   procedure showhint(const sender: twidget; const hint: msestring;
              const aposrect: rectty; const aplacement: captionposty = cp_bottomleft;
              const ashowtime: integer = defaulthintshowtime; //0 -> inifinite,
                 // -1 defaultshowtime if ow_timedhint in sender.optionswidget
              const aflags: hintflagsty = defaulthintflags
                      ); overload;
   procedure showhint(const sender: twidget; const hint: msestring;
              const apos: pointty;
              const ashowtime: integer = defaulthintshowtime; //0 -> inifinite,
                 // -1 defaultshowtime if ow_timedhint in sender.optionswidget
              const aflags: hintflagsty = defaulthintflags
                      ); overload;
   procedure showhint(const sender: twidget; const info: hintinfoty); overload;
   procedure hidehint;
   function hintedwidget: twidget; //last hinted widget
   function activehintedwidget: twidget; //nil if no hint active
   
   function helpcontext: msestring;
                //returns helpcontext of active widget, '' if none;
   function mousehelpcontext: msestring;
                //returns helpcontext of mouse widget, '' if none;
   function running: boolean; //true if eventloop entered
   function screensize: sizety;
   function workarea(awindow: twindow): rectty;
   function activewindow: twindow;
   function regularactivewindow: twindow;
   function unreleasedactivewindow: twindow;
   function activewidget: twidget;
   function windowatpos(const pos: pointty): twindow;
   function findwidget(const namepath: string; out awidget: twidget): boolean;
                //false if invalid namepath, '' -> nil and true
   procedure sortzorder;
             //window list is ordered by z, bottom first, top last,
             //invisibles first
   function windowar: windowarty;
   function winidar: winidarty;
   function windowcount: integer;
   property windows[const index: integer]: twindow read getwindows;
   function bottomwindow: twindow;
      //lowest visible window in stackorder, calls sortzorder
   function topwindow: twindow;
      //highest visible window in stackorder, calls sortzorder

   procedure registeronterminated(const method: notifyeventty);
   procedure unregisteronterminated(const method: notifyeventty);
   procedure registeronterminate(const method: terminatequeryeventty);
   procedure unregisteronterminate(const method: terminatequeryeventty);
   procedure registeronidle(const method: idleeventty);
   procedure unregisteronidle(const method: idleeventty);
   procedure registeronkeypress(const method: keyeventty);
   procedure unregisteronkeypress(const method: keyeventty);
   procedure registeronshortcut(const method: keyeventty);
   procedure unregisteronshortcut(const method: keyeventty);
   procedure registeronactivechanged(const method: activechangeeventty);
   procedure unregisteronactivechanged(const method: activechangeeventty);
   procedure registeronwindowdestroyed(const method: windoweventty);
   procedure unregisteronwindowdestroyed(const method: windoweventty);
   procedure registeronapplicationactivechanged(const method: booleaneventty);
   procedure unregisteronapplicationactivechanged(const method: booleaneventty);

   property terminated: boolean read getterminated write setterminated;
   property caret: tcaret read fcaret;
   property mouse: tmouse read fmouse;
   procedure mouseparkevent; //simulates mouseparkevent
   property cursorshape: cursorshapety read fcursorshape write setcursorshape;
   procedure updatecursorshape; //restores cursorshape of mousewidget
   property mousewidget: twidget read fmousewidget;
   property mousecapturewidget: twidget read fmousecapturewidget;
   property mainwindow: twindow read fmainwindow write setmainwindow;
   property applicationname: msestring read fapplicationname write fapplicationname;
   property thread: threadty read fthread;

   property buttonpresswidgetbefore: twidget read fbuttonpresswidgetbefore;
   property buttonreleasewidgetbefore: twidget read fbuttonreleasewidgetbefore;
   property dblclicktime: integer read fdblclicktime write fdblclicktime default
                 defaultdblclicktime; //us
   property onexception: exceptioneventty read fonexception write fonexception;
 end;

function translatewidgetpoint(const point: pointty;
                 const source,dest: twidget): pointty;
procedure translatewidgetpoint1(var point: pointty;
                 const source,dest: twidget);
function translatewidgetrect(const rect: rectty;
                 const source,dest: twidget): rectty;
    //translates from source widget to dest widget, to screen if dest = nil
    //source = nil -> screen
function translatepaintpoint(const point: pointty;
                 const source,dest: twidget): pointty;
procedure translatepaintpoint1(var point: pointty;
                 const source,dest: twidget);
function translatepaintrect(const rect: rectty;
                 const source,dest: twidget): rectty;
    //translates from source widget to dest widget, to screen if dest = nil
    //source = nil -> screen
function translateclientpoint(const point: pointty;
                    const source,dest: twidget): pointty;
procedure translateclientpoint1(var point: pointty;
                    const source,dest: twidget);
function translateclientrect(const rect: rectty;
                 const source,dest: twidget): rectty;
    //translates from source client to dest client, to screen if dest = nil
    //source = nil -> screen


type
 getwidgetintegerty = function(const awidget: twidget): integer;
 setwidgetintegerty = procedure(const awidget: twidget; const avalue: integer);

function wbounds_x(const awidget: twidget): integer;
procedure wsetbounds_x(const awidget: twidget; const avalue: integer);
function wbounds_y(const awidget: twidget): integer;
procedure wsetbounds_y(const awidget: twidget; const avalue: integer);
function wbounds_cx(const awidget: twidget): integer;
procedure wsetbounds_cx(const awidget: twidget; const avalue: integer);
function wbounds_cy(const awidget: twidget): integer;
procedure wsetbounds_cy(const awidget: twidget; const avalue: integer);
function wbounds_cxmin(const awidget: twidget): integer;
procedure wsetbounds_cxmin(const awidget: twidget; const avalue: integer);
function wbounds_cymin(const awidget: twidget): integer;
procedure wsetbounds_cymin(const awidget: twidget; const avalue: integer);
function wbounds_cxmax(const awidget: twidget): integer;
procedure wsetbounds_cxmax(const awidget: twidget; const avalue: integer);
function wbounds_cymax(const awidget: twidget): integer;
procedure wsetbounds_cymax(const awidget: twidget; const avalue: integer);

function application: tapplication;
function applicationallocated: boolean;
function mousebuttontoshiftstate(button: mousebuttonty): shiftstatesty;
procedure beep;

procedure writewidgetnames(const writer: twriter; const ar: widgetarty);
function needswidgetnamewriting(const ar: widgetarty): boolean;

procedure designeventloop;
procedure freedesigncomponent(const acomponent: tcomponent);

var
 ondesignchanged: notifyeventty;
 onfreedesigncomponent: componenteventty;
 
implementation

uses
 mseguiintf,msesysintf,typinfo,msestreaming,msetimer,msebits,msewidgets,
 mseshapes,msestockobjects,msefileutils,msedatalist,Math,msesysutils,
 {$ifdef FPCc} rtlconst {$else} RtlConsts{$endif},mseformatstr;

const
 faceoptionsmask: faceoptionsty = [fao_alphafadeimage,fao_alphafadenochildren,
                        fao_alphafadeall];
type
 tcanvas1 = class(tcanvas);
 tcolorarrayprop1 = class(tcolorarrayprop);
 trealarrayprop1 = class(trealarrayprop);
 tcaret1 = class(tcaret);

 tonterminatedlist = class(tmethodlist)
  protected
   procedure doterminated;
 end;

 tonterminatequerylist = class(tmethodlist)
  protected
   function doterminatequery: boolean;
           //true if accepted
 end;
 
 tonidlelist = class(tmethodlist)
//  private
//   fagain: boolean;
  protected
   function doidle: boolean; //true if again requested
  public
 end;

 tonkeyeventlist = class(tmethodlist)
  protected
   procedure dokeyevent(const sender: twidget; var info: keyeventinfoty);
 end;

 tonactivechangelist = class(tmethodlist)
  protected
   procedure doactivechange(const oldwindow,newwindow: twindow);
 end;

 tonwindoweventlist = class(tmethodlist)
  protected
   procedure doevent(const awindow: twindow);
 end;

 tonapplicationactivechangedlist = class(tmethodlist)
  protected
   procedure doevent(const activated: boolean);
 end;
 
 windowstackinfoty = record
  lower,upper: twindow;
  level: integer;
  recursion: boolean;
 end;
 windowstackinfoarty = array of windowstackinfoty;

 tinternalapplication = class(tapplication,imouse)
         //avoid circular interface references
  private
   feventlist: tobjectqueue;
   fonterminatedlist: tonterminatedlist;
   fonterminatequerylist: tonterminatequerylist;
   fonidlelist: tonidlelist;
   fonkeypresslist: tonkeyeventlist;
   fonshortcutlist: tonkeyeventlist;
   fonactivechangelist: tonactivechangelist;
   fonwindowdestroyedlist: tonwindoweventlist;
   fonapplicationactivechangedlist: tonapplicationactivechangedlist;

   fcaretwidget: twidget;
   fmousewinid: winidty;
   fmutex: mutexty;
   feventlock: mutexty;
   fpostedevents: eventarty;
   fdesigning: boolean;
   fmodalwindow: twindow;
   fhintwidget: thintwidget;
   fhinttimer: tsimpletimer;
   fmouseparktimer: tsimpletimer;
   fmouseparkeventinfo: mouseeventinfoty;
   ftimestampbefore: cardinal;
   flastbuttonpress: mousebuttonty;
   flastbuttonpresstimestamp: cardinal;
   flastbuttonrelease: mousebuttonty;
   flastbuttonreleasetimestamp: cardinal;
   fwindowstack: windowstackinfoarty;
   ftimertick: boolean;

   procedure flusheventbuffer;
   procedure twindowdestroyed(const sender: twindow);
   procedure windowdestroyed(id: winidty);
   procedure setwindowfocus(winid: winidty);
   procedure unsetwindowfocus(winid: winidty);
   procedure registerwindow(window: twindow);
   procedure unregisterwindow(window: twindow);
   procedure widgetdestroyed(const widget: twidget);

   procedure processexposeevent(event: twindowrectevent);
   procedure processconfigureevent(event: twindowrectevent);
   procedure processshowingevent(event: twindowevent);
   procedure processmouseevent(event: tmouseevent);
   procedure processkeyevent(event: tkeyevent);
   procedure processwindowcrossingevent(event: twindowevent);

   function getmousewinid: winidty; //for  tmouse.setshape
   function getevents: integer; //application has to be locked
                  //returns count of queued events
   procedure waitevent;         //application has to be locked
   procedure checkactivewindow;
   procedure checkapplicationactive;
   function eventloop(const amodalwindow: twindow; const once: boolean = false): boolean;
                 //true if actual modalwindow destroyed
   function beginmodal(const sender: twindow): boolean;
                 //true if modalwindow destroyed
   procedure endmodal(const sender: twindow);
   procedure stackunder(const sender: twindow; const predecessor: twindow);
   procedure stackover(const sender: twindow; const predecessor: twindow);
   procedure checkwindowstack;
   procedure updatewindowstack;
                //reorders windowstack by ow_background,ow_top
   procedure checkcursorshape;

   procedure mouseparktimer(const sender: tobject);
  protected
   procedure flushmousemove;
   procedure doterminate;
   procedure doidle;
   procedure checkshortcut(const sender: twindow; const awidget: twidget;
                     var info: keyeventinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
 end;

var
 app: tinternalapplication;

function wbounds_x(const awidget: twidget): integer;
begin
 result:= awidget.fwidgetrect.x;
end;

procedure wsetbounds_x(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_x:= avalue;
end;

function wbounds_cx(const awidget: twidget): integer;
begin
 result:= awidget.fwidgetrect.cx;
end;

procedure wsetbounds_cx(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cx:= avalue;
end;

function wbounds_y(const awidget: twidget): integer;
begin
 result:= awidget.fwidgetrect.y;
end;

procedure wsetbounds_y(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_y:= avalue;
end;

function wbounds_cy(const awidget: twidget): integer;
begin
 result:= awidget.fwidgetrect.cy;
end;

procedure wsetbounds_cy(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cy:= avalue;
end;

function wbounds_cxmin(const awidget: twidget): integer;
begin
 result:= awidget.fminsize.cx;
end;

procedure wsetbounds_cxmin(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cxmin:= avalue;
end;

function wbounds_cymin(const awidget: twidget): integer;
begin
 result:= awidget.fminsize.cy;
end;

procedure wsetbounds_cymin(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cymin:= avalue;
end;

function wbounds_cxmax(const awidget: twidget): integer;
begin
 result:= awidget.fmaxsize.cx;
end;

procedure wsetbounds_cxmax(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cxmax:= avalue;
end;

function wbounds_cymax(const awidget: twidget): integer;
begin
 result:= awidget.fmaxsize.cy;
end;

procedure wsetbounds_cymax(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cymax:= avalue;
end;

procedure translatewidgetpoint1(var point: pointty;
                 const source,dest: twidget);
    //translates from source widget to dest widget, to screen if dest = nil
    //source = nil -> screen

begin
 if source <> nil then begin
  addpoint1(point,source.screenpos);
 end;
 if dest <> nil then begin
  subpoint1(point,dest.screenpos);
 end;
end;

function translatewidgetpoint(const point: pointty;
                 const source,dest: twidget): pointty;
begin
 result:= point;
 translatewidgetpoint1(result,source,dest);
end;

function translatewidgetrect(const rect: rectty;
                 const source,dest: twidget): rectty;
begin
 result:= rect;
 translatewidgetpoint1(result.pos,source,dest);
end;

procedure translatepaintpoint1(var point: pointty;
                 const source,dest: twidget);
    //translates from source widget to dest widget, to screen if dest = nil
    //source = nil -> screen

begin
 if source <> nil then begin
  addpoint1(point,source.screenpos);
  addpoint1(point,source.paintpos);
 end;
 if dest <> nil then begin
  subpoint1(point,dest.screenpos);
  subpoint1(point,source.paintpos);
 end;
end;

function translatepaintpoint(const point: pointty;
                 const source,dest: twidget): pointty;
begin
 result:= point;
 translatepaintpoint1(result,source,dest);
end;

function translatepaintrect(const rect: rectty;
                 const source,dest: twidget): rectty;
begin
 result:= rect;
 translatepaintpoint1(result.pos,source,dest);
end;

procedure translateclientpoint1(var point: pointty;
                    const source,dest: twidget);
    //translates from source client to dest client, to screen if dest = nil
    //source = nil -> screen
begin
 if source <> nil then begin
  addpoint1(point,source.screenpos);
  addpoint1(point,source.clientwidgetpos);
 end;
 if dest <> nil then begin
  subpoint1(point,dest.screenpos);
  subpoint1(point,dest.clientwidgetpos);
 end;
end;

function translateclientpoint(const point: pointty;
                    const source,dest: twidget): pointty;
begin
 result:= point;
 translateclientpoint1(result,source,dest);
end;

function translateclientrect(const rect: rectty;
                 const source,dest: twidget): rectty;
begin
 result:= rect;
 translateclientpoint1(result.pos,source,dest);
end;

procedure beep;
begin
 gui_beep;
end;

procedure designeventloop;
begin
 if app <> nil then begin
  app.fdesigning:= true;
  tinternalapplication(app).eventloop(nil);
 end;
end;

function needswidgetnamewriting(const ar: widgetarty): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(ar) do begin
  if ar[int1] <> nil then begin
   result:= true;
   break;
  end;
 end;
end;

procedure writewidgetnames(const writer: twriter; const ar: widgetarty);
var
 int1: integer;
begin
 writer.writelistbegin;
 for int1:= 0 to high(ar) do begin
  if ar[int1] <> nil then begin
   writer.writestring(ar[int1].name);
  end
  else begin
   writer.writestring('');
  end;
 end;
 writer.writelistend;
end;

procedure freedesigncomponent(const acomponent: tcomponent);
begin
 if assigned(onfreedesigncomponent) then begin
  onfreedesigncomponent(acomponent);
 end
 else begin
  acomponent.free;
 end;
end;

function application: tapplication;
begin
 if app = nil then begin
  app:= tinternalapplication.create(nil);
  app.initialize;
 end;
 result:= app;
end;

function applicationallocated: boolean;
begin
 result:= app <> nil;
end;

function mousebuttontoshiftstate(button: mousebuttonty): shiftstatesty;
begin
 if button = mb_none then begin
  result:= [];
 end
 else begin
  result:= [shiftstatety(cardinal(ss_left) +
                  cardinal(button) - cardinal(mb_left))];
 end;
end;

procedure destroyregion(var region: regionty);
var
 info: drawinfoty;
begin
 if region <> 0 then begin
  info.regionoperation.source:= region;
  gui_getgdifuncs^[gdi_destroyregion](info);
//  gui_gdifunc(gdi_destroyregion,info);
  region:= 0;
 end;
end;

function createregion: regionty; overload;
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  gui_getgdifuncs^[gdi_createemptyregion](info);
//  gui_gdifunc(gdi_createemptyregion,info);
  result:= dest;
 end;
end;

function createregion(const arect: rectty): regionty; overload;
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  rect:= arect;
  gui_getgdifuncs^[gdi_createrectregion](info);
//  gui_gdifunc(gdi_createrectregion,info);
  result:= dest;
 end;
end;

function createregion(const rects: rectarty): regionty; overload;
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  rectscount:= length(rects);
  if rectscount > 0 then begin
   rectspo:= @rects[0];
   gui_getgdifuncs^[gdi_createrectsregion](info);
//   gui_gdifunc(gdi_createrectsregion,info);
   result:= dest;
  end
  else begin
   result:= createregion;
  end;
 end;
end;

procedure regintersectrect(const region: regionty; const arect: rectty);
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  dest:= region;
  rect:= arect;
  gui_getgdifuncs^[gdi_regintersectrect](info);
//  gui_gdifunc(gdi_regintersectrect,info);
 end;
end;

procedure regaddrect(const region: regionty; const arect: rectty);
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  dest:= region;
  rect:= arect;
  gui_getgdifuncs^[gdi_regaddrect](info);
//  gui_gdifunc(gdi_regaddrect,info);
 end;
end;

{ twidgetfont}

class function twidgetfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @twidget(owner).ffont;
end;

{ tguicomponent }

procedure tguicomponent.receiveevent(const event: tobjectevent);
var
 int1: integer;
begin
 case event.kind of
  ek_async: begin
   int1:= tasyncevent(event).tag;
   doasyncevent(int1);
  end;
  ek_component: begin
   sendcomponentevent(event as tcomponentevent);
  end;
 end;
end;

procedure tguicomponent.asyncevent(atag: integer = 0);
begin
 application.postevent(tasyncevent.create(ievent(self),atag));
end;

procedure tguicomponent.doasyncevent(var atag: integer);
begin
 //dummy
end;

procedure tguicomponent.postcomponentevent(const event: tcomponentevent);
begin
 event.create(event.kind,ievent(self));
 application.postevent(event);
end;

procedure tguicomponent.designchanged; //for designer notify
begin
 if assigned(ondesignchanged) then begin
  ondesignchanged(self);
 end;
end;

procedure tguicomponent.setactivator(const avalue: tactivator);
begin
 tactivator.addclient(avalue,ievent(self),factivator);
end;

procedure tguicomponent.loaded;
begin
 inherited;
 if factivator = nil then begin
  doactivated;
 end;
end;

procedure tguicomponent.doactivated;
begin
 //dummy;
end;

procedure tguicomponent.dodeactivated;
begin
 //dummy;
end;

procedure tguicomponent.objectevent(const sender: tobject; const event: objecteventty);
begin
 inherited;
 if (sender = factivator) then begin
  case event of
   oe_activate: begin
    doactivated;
   end;
   oe_deactivate: begin
    dodeactivated;
   end;
  end;
 end;
end;

{ tactivator }

constructor tactivator.create(aowner: tcomponent);
begin
 inherited;
 application.registeronterminated({$ifdef FPC}@{$endif}doterminated);
end;

destructor tactivator.destroy;
begin
 application.unregisteronterminated({$ifdef FPC}@{$endif}doterminated);
 inherited;
end;

class procedure tactivator.addclient(const aactivator: tactivator; 
                    const aclient: iobjectlink; var dest: tactivator);
var
 act1: tactivator;
begin
 if dest <> nil then begin
  dest.unregisterclient(aclient);
 end;
 if aactivator <> nil then begin
  act1:= tactivator(aclient.getinstance);
  if act1 is tactivator then begin
   repeat  
    if act1 = aactivator then begin
     raise exception.create('Circular reference.');
    end;
    act1:= act1.activator;
   until act1 = nil;
  end;
  aclient.link(aclient,ievent(aactivator),@dest);
  aactivator.registerclient(aclient);
 end;
 dest:= aactivator;
end;

procedure tactivator.registerclient(const aclient: iobjectlink);
begin
 additem(fclients,pointer(aclient));
end;

procedure tactivator.unregisterclient(const aclient: iobjectlink);
begin
 removeitem(fclients,pointer(aclient));
end;

procedure tactivator.updateorder;
var
 int1,int2: integer;
 ar1: stringarty;
 ar2,ar3: integerarty;
begin
 ar1:= nil; //compilerwarning
 if fclientnames <> nil then begin
  ar1:= getclientnames;
  setlength(ar2,length(ar1));
  for int1:= 0 to high(fclientnames) do begin
   for int2:= 0 to high(ar1) do begin
    if ar1[int2] = fclientnames[int1] then begin
     ar2[int2]:= int1-bigint; //not found items last
     ar1[int2]:= '';
    end;
   end;
  end;
  sortarray(ar2,ar3);
  orderarray(ar3,fclients);
 end;
end;

procedure tactivator.doasyncevent(var atag: integer);
begin
 activateclients;
end;

procedure tactivator.loaded;
begin
 inherited;
 if avo_activateonloaded in foptions then begin
  if csdesigning in componentstate then begin
   try
    activateclients;
   except
    application.handleexception(self);
   end;
  end
  else begin
   activateclients;
  end;   
 end;
 if avo_activatedelayed in foptions then begin
  asyncevent;
 end;
end;

function tactivator.getclientname(const avalue: tobject;
                   const aindex: integer): string;
begin
 if avalue is tcomponent then begin
  with tcomponent(avalue) do begin
   if owner <> nil then begin
    if not (csdesigning in componentstate) or 
             ((owner.owner <> nil) and (owner.owner.owner = nil)) then begin
     result:= owner.name+'.'+name;
    end
    else begin
     result:= name;
    end;
   end
   else begin
    result:= '';
   end;
  end;
 end
 else begin
  result:= inttostr(aindex)+'<'+avalue.classname+'>';
 end;
end;

function tactivator.getclientnames: stringarty;
var
 int1: integer;
begin
 setlength(result,length(fclients));
 for int1:= 0 to high(result) do begin 
  result[int1]:= getclientname(iobjectlink(fclients[int1]).getinstance,int1);
 end;
end;

procedure tactivator.readclientnames(reader: treader);
begin
 readstringar(reader,fclientnames);
end;

procedure tactivator.writeclientnames(writer: twriter);
begin
 writestringar(writer,getclientnames);
end;

procedure tactivator.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('clientnames',{$ifdef FPC}@{$endif}readclientnames,
            {$ifdef FPC}@{$endif}writeclientnames,high(fclients) >= 0);
end;

procedure tactivator.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 inherited;
 if (event = oe_activate) and (sender.getinstance = activator) then begin
  activateclients;
 end;
end;

procedure tactivator.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 removeitem(fclients,pointer(dest));
 inherited;
end;

function tactivator.getclients: integer;
begin
 result:= length(fclients);
end;

procedure tactivator.setclients(const avalue: integer);
begin
 // dummy;
end;

procedure tactivator.activateclients;
var
 int1: integer;
begin
 factive:= true;
 if canevent(tmethod(fonbeforeactivate)) then begin
  fonbeforeactivate(self);
 end;
 if factive then begin
  for int1:= 0 to high(fclients) do begin
   iobjectlink(fclients[int1]).objevent(ievent(self),oe_activate);
  end;
  if canevent(tmethod(fonafteractivate)) then begin
   fonafteractivate(self);
  end;
 end;
end;

procedure tactivator.deactivateclients;
var
 int1: integer;
begin
 factive:= false;
 if canevent(tmethod(fonbeforedeactivate)) then begin
  fonbeforedeactivate(self);
 end;
 if not active then begin
  for int1:= high(fclients) downto 0 do begin
   iobjectlink(fclients[int1]).objevent(ievent(self),oe_deactivate);
  end;
  if canevent(tmethod(fonafterdeactivate)) then begin
   fonafterdeactivate(self);
  end;
 end;
end;

procedure tactivator.setactive(const avalue: boolean);
begin
 if avalue <> factive then begin
  if avalue then begin
   activateclients;
  end
  else begin
   deactivateclients;
  end;
 end;
end;

procedure tactivator.setoptions(const avalue: activatoroptionsty);
const 
 mask: activatoroptionsty = [avo_activateonloaded,avo_activatedelayed];
begin
 foptions:= activatoroptionsty(setsinglebit(
                         {$ifdef FPC}longword{$else}byte{$endif}(avalue),
                         {$ifdef FPC}longword{$else}byte{$endif}(foptions),
                         {$ifdef FPC}longword{$else}byte{$endif}(mask)));
end;

procedure tactivator.doterminated(const sender: tobject);
begin
 deactivateclients;
end;



{ tresizeevent }

constructor tresizeevent.create(const dest: ievent; const asize: sizety);
begin
 inherited create(ek_resize,dest);
 size:= asize;
end;

{ tcustomframe }

constructor tcustomframe.create(const intf: iframe);
begin
 fintf:= intf;
 fintf.setframeinstance(self);
// owner.fframe:= self;
 fi.colorclient:= cl_transparent;
 fi.colorframe:= cl_transparent;
end;

destructor tcustomframe.destroy;
begin
 if ftemplate <> nil then begin
  fintf.getwidget.setlinkedvar(nil,tmsecomponent(ftemplate));
 end;
 inherited;
end;

{
procedure tcustomframe.excludeopaque(const canvas: tcanvas);
begin
 if fcolorclient <> cl_transparent then begin
  canvas.subcliprect(fpaintrect);
 end;
end;
  }
procedure tcustomframe.updatemousestate(const sender: twidget;
                 const apos: pointty);
begin
 with sender do begin
  if not (ow_mousetransparent in foptionswidget) and
                       pointinrect(apos,fpaintrect) then begin
   fwidgetstate:= fwidgetstate + [ws_mouseinclient,ws_wantmousemove,
                           ws_wantmousebutton,ws_wantmousefocus];
  end
  else begin
   fwidgetstate:= fwidgetstate - [ws_mouseinclient,ws_wantmousemove,
                           ws_wantmousebutton,ws_wantmousefocus];
  end;
 end;
end;

procedure tcustomframe.dopaintframe(const canvas: tcanvas; const rect: rectty);
var
 rect1: rectty;
begin
 rect1:= deflaterect(rect,fouterframe);
 if fi.levelo <> 0 then begin
  draw3dframe(canvas,rect1,fi.levelo,defaultframecolors);
  inflaterect1(rect1,-abs(fi.levelo));
 end;
 if fi.framewidth > 0 then begin
  canvas.drawframe(rect1,-fi.framewidth,fi.colorframe);
  inflaterect1(rect1,-fi.framewidth);
 end;
 if fi.leveli <> 0 then begin
  draw3dframe(canvas,rect1,fi.leveli,defaultframecolors);
 end;
 if fi.colorclient <> cl_transparent then begin
  canvas.fillrect(deflaterect(rect,fpaintframe),fi.colorclient);
 end;
end;

procedure tcustomframe.dopaintfocusrect(const canvas: tcanvas; const rect: rectty);
var
 rect1: rectty;
begin
 if fs_paintrectfocus in fstate then begin
  rect1:= deflaterect(rect,fpaintframe);
//  inflaterect1(rect1,-1);
  drawfocusrect(canvas,rect1);
 end;
end;

procedure tcustomframe.paint(const canvas: tcanvas; const rect: rectty);
begin
 dopaintframe(canvas,rect);
 canvas.intersectcliprect(deflaterect(rect,fpaintframe));
 canvas.move(addpoint(fpaintrect.pos,fclientrect.pos));
end;

function tcustomframe.checkshortcut(var info: keyeventinfoty): boolean;
begin
 result:= false;
end;

procedure tcustomframe.updatewidgetstate;
begin
 //dummy
end;

procedure tcustomframe.updateclientrect;
begin
 fclientrect.size:= fpaintrect.size;
 fclientrect.pos:= nullpoint;
 finnerclientrect:= deflaterect(fclientrect,fi.innerframe);
end;

procedure tcustomframe.updaterects;
begin
 fwidth.left:= abs(fi.levelo) + fi.framewidth + abs(fi.leveli);
 fwidth.top:= fwidth.left;
 fwidth.right:= fwidth.left;
 fwidth.bottom:= fwidth.left;
 fpaintframedelta:= nullframe;
 getpaintframe(fpaintframedelta);
 fpaintframe:= addframe(fpaintframedelta,fouterframe);
 addframe1(fpaintframe,fwidth);
 fpaintrect.pos:= pointty(fpaintframe.topleft);
 fpaintrect.size:= fintf.getwidgetrect.size;
 fpaintrect.cx:= fpaintrect.cx - fpaintframe.left - fpaintframe.right;
 fpaintrect.cy:= fpaintrect.cy - fpaintframe.top - fpaintframe.bottom;
end;

procedure tcustomframe.updatestate;
var
 po1: pointty;
begin
 include(fstate,fs_rectsvalid);   //avoid recursion
 updaterects;
 if not (ws_loadedproc in fintf.widgetstate) and
         not (csloading in fintf.getcomponentstate) and
         not (fs_nowidget in fstate) then begin
  po1:= subpoint(fpaintrect.pos,fpaintposbefore);
  fintf.scrollwidgets(po1);
 end;
// addpoint1(fclientrect.pos,po1);
 fpaintposbefore:= fpaintrect.pos;
 updateclientrect;
 include(fstate,fs_rectsvalid);
 fintf.clientrectchanged;
end;

procedure tcustomframe.internalupdatestate;
begin
 if not ((csloading in fintf.getcomponentstate){ or (fs_nowidget in fstate)}) then begin
  updatestate;
 end
 else begin
  exclude(fstate,fs_rectsvalid);
 end;
end;

procedure tcustomframe.checkstate;
begin
 if not (fs_rectsvalid in fstate) then begin
  updatestate;
 end;
end;

procedure tcustomframe.setlocalprops(const avalue: framelocalpropsty);
var
 widget1: twidget;
begin
 if flocalprops <> avalue then begin
  flocalprops:= avalue;
  if ftemplate <> nil then begin
   settemplateinfo(ftemplate.template.fi);
  end;
  if not (frl_nodisable in flocalprops) then begin
   widget1:= fintf.getwidget;
   if not (csloading in widget1.componentstate) and not widget1.isenabled then begin
    setdisabled(true);
   end
   else begin
    setdisabled(false);
   end;
  end
  else begin
   setdisabled(false);
  end;
 end;
end;

procedure tcustomframe.setlevelo(const Value: integer);
begin
 if fi.levelo <> value then begin
  include(flocalprops,frl_levelo);
  fi.levelo := Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setleveli(const Value: integer);
begin
 if fi.leveli <> value then begin
  include(flocalprops,frl_leveli);
  fi.leveli := Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframewidth(const Value: integer);
begin
 if fi.framewidth <> value then begin
  include(flocalprops,frl_framewidth);
  if value < 0 then begin
   fi.framewidth:= 0;
  end
  else begin
   fi.framewidth := Value;
  end;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_left(const Value: integer);
begin
 if fi.innerframe.left <> value then begin
  include(flocalprops,frl_fileft);
  fi.innerframe.left:= Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_top(const Value: integer);
begin
 if fi.innerframe.top <> value then begin
  include(flocalprops,frl_fitop);
  fi.innerframe.top := Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_right(const Value: integer);
begin
 if fi.innerframe.right <> value then begin
  include(flocalprops,frl_firight);
  fi.innerframe.right:= Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_bottom(const Value: integer);
begin
 if fi.innerframe.bottom <> value then begin
  include(flocalprops,frl_fibottom);
  fi.innerframe.bottom:= Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setcolorclient(const value: colorty);
begin
 if fi.colorclient <> value then begin
  include(flocalprops,frl_colorclient);
  fi.colorclient:= value;
  fintf.invalidate;
 end;
end;

procedure tcustomframe.setcolorframe(const Value: colorty);
begin
 if fi.colorframe <> value then begin
  include(flocalprops,frl_colorframe);
  fi.colorframe:= Value;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.settemplate(const avalue: tframecomp);
begin
 fintf.getwidget.setlinkedvar(avalue,tmsecomponent(ftemplate));
 if avalue <> nil then begin
  assign(avalue);
 end;
end;
{
function tcustomframe.arepropsstored: boolean;
begin
 result:= ftemplate = nil;
end;
}
procedure tcustomframe.settemplateinfo(const ainfo: frameinfoty);
begin
 with fi do begin
  if not (frl_levelo in flocalprops) then begin
   levelo:= ainfo.levelo;
  end;
  if not (frl_leveli in flocalprops) then begin
   leveli:= ainfo.leveli;
  end;
  if not (frl_framewidth in flocalprops) then begin
   framewidth:= ainfo.framewidth;
  end;
  if not (frl_colorframe in flocalprops) then begin
   colorframe:= ainfo.colorframe;
  end;
  if not (frl_fileft in flocalprops) then begin
   innerframe.left:= ainfo.innerframe.left;
  end;
  if not (frl_fitop in flocalprops) then begin
   innerframe.top:= ainfo.innerframe.top;
  end;
  if not (frl_firight in flocalprops) then begin
   innerframe.right:= ainfo.innerframe.right;
  end;
  if not (frl_fibottom in flocalprops) then begin
   innerframe.bottom:= ainfo.innerframe.bottom;
  end;
  if not (frl_colorclient in flocalprops) then begin
   colorclient:= ainfo.colorclient;
  end;
 end;
 internalupdatestate;
end;

procedure tcustomframe.getpaintframe(var frame: framety);
begin
 //dummy
end;

function tcustomframe.outerframewidth: sizety;
begin
 checkstate;
 result.cx:= fouterframe.left + fouterframe.right;
 result.cy:= fouterframe.top + fouterframe.bottom;
end;

function tcustomframe.frameframewidth: sizety;
begin
 checkstate;
 result.cx:= fouterframe.left + fwidth.left + fwidth.right + fouterframe.right;
 result.cy:= fouterframe.top + fwidth.top + fwidth.bottom + fouterframe.bottom;
end;

function tcustomframe.paintframewidth: sizety;
begin
 checkstate;
 result.cx:= fouterframe.left + fpaintframe.left +
       fpaintframe.right + fouterframe.right;
 result.cy:= fouterframe.top + fpaintframe.top +
       fpaintframe.bottom + fouterframe.bottom;
end;

function tcustomframe.innerframewidth: sizety;
begin
 checkstate;
 result.cx:= fouterframe.left + fpaintframe.left + fi.innerframe.left +
       fpaintframe.right + fouterframe.right + fi.innerframe.right;
 result.cy:= fouterframe.top + fpaintframe.top + fi.innerframe.top +
       fpaintframe.bottom + fouterframe.bottom + fi.innerframe.bottom;
end;

function tcustomframe.outerframe: framety;
begin
 checkstate;
 result:= fouterframe;
end;

function tcustomframe.paintframe: framety;
begin
 checkstate;
 result:= addframe(fouterframe,fpaintframe);
end;

function tcustomframe.innerframe: framety;
begin
 checkstate;
 result:= addframe(fouterframe,fpaintframe);
 addframe1(result,fi.innerframe);
end;

procedure tcustomframe.assign(source: tpersistent);
begin
 if source is tcustomframe then begin
  if not (csdesigning in fintf.getcomponentstate) then begin
   flocalprops:= allframelocalprops;
   fi:= tcustomframe(source).fi;
   internalupdatestate;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcustomframe.dokeydown(var info: keyeventinfoty);
begin
 //dummy
end;

procedure tcustomframe.poschanged;
begin
 //dummy
end;

procedure tcustomframe.parentfontchanged;
begin
 //dummy
end;

procedure tcustomframe.setdisabled(const value: boolean);
begin
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),ord(fs_disabled),value);
end;

function tcustomframe.pointincaption(const point: pointty): boolean;
begin
 result:= false; //dummy
end;

procedure tcustomframe.initgridframe;
begin
 leveli:= 0;
 levelo:= 0;
 colorclient:= cl_transparent;
end;

function tcustomframe.islevelostored: boolean;
begin
 result:= (ftemplate = nil) or (frl_levelo in flocalprops);
end;

function tcustomframe.islevelistored: boolean;
begin
 result:= (ftemplate = nil) or (frl_leveli in flocalprops);
end;

function tcustomframe.isframewidthstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_framewidth in flocalprops);
end;

function tcustomframe.iscolorframestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorframe in flocalprops);
end;

function tcustomframe.isfibottomstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_fibottom in flocalprops);
end;

function tcustomframe.isfileftstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_fileft in flocalprops);
end;

function tcustomframe.isfirightstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_firight in flocalprops);
end;

function tcustomframe.isfitopstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_fitop in flocalprops);
end;

function tcustomframe.iscolorclientstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorclient in flocalprops);
end;

{ tframetemplate }

constructor tframetemplate.create(const owner: tmsecomponent;
                      const onchange: notifyeventty);
begin
 fi.colorclient:= cl_transparent;
 fi.colorframe:= cl_transparent;
 inherited;
end;

procedure tframetemplate.setcolorclient(const Value: colorty);
begin
 fi.colorclient := Value;
 changed;
end;

procedure tframetemplate.setcolorframe(const Value: colorty);
begin
 fi.colorframe := Value;
 changed;
end;

procedure tframetemplate.setframei_bottom(const Value: integer);
begin
 fi.innerframe.bottom := Value;
 changed;
end;

procedure tframetemplate.setframei_left(const Value: integer);
begin
 fi.innerframe.left := Value;
 changed;
end;

procedure tframetemplate.setframei_right(const Value: integer);
begin
 fi.innerframe.right := Value;
 changed;
end;

procedure tframetemplate.setframei_top(const Value: integer);
begin
 fi.innerframe.top := Value;
 changed;
end;

procedure tframetemplate.setframewidth(const Value: integer);
begin
 fi.framewidth := Value;
 changed;
end;

procedure tframetemplate.setleveli(const Value: integer);
begin
 fi.leveli := Value;
 changed;
end;

procedure tframetemplate.setlevelo(const Value: integer);
begin
 fi.levelo := Value;
 changed;
end;

function tframetemplate.getinfosize: integer;
begin
 result:= sizeof(fi);
end;

function tframetemplate.getinfoad: pointer;
begin
 result:= @fi;
end;

procedure tframetemplate.doassignto(dest: tpersistent);
begin
 if dest is tcustomframe then begin
  tcustomframe(dest).settemplateinfo(fi);
//  with tcustomframe(dest) do begin
//   fi:= self.fi;
//   internalupdatestate;
//  end;
 end;
end;

procedure tframetemplate.draw3dframe(const acanvas: tcanvas; const arect: rectty);
var
 rect1: rectty;
begin
 if fi.colorclient <> cl_transparent then begin
  acanvas.fillrect(arect,fi.colorclient);
 end;
 rect1:= inflaterect(arect,abs(fi.leveli));
 if fi.leveli <> 0 then begin
  mseshapes.draw3dframe(acanvas,rect1,fi.leveli,defaultframecolors);
 end;
 if fi.framewidth > 0 then begin
  inflaterect1(rect1,fi.framewidth);
  acanvas.drawframe(rect1,-fi.framewidth,fi.colorframe);
 end;
 if fi.levelo <> 0 then begin
  inflaterect1(rect1,abs(fi.levelo));
  mseshapes.draw3dframe(acanvas,rect1,fi.levelo,defaultframecolors);
 end;
end;

{ tframecomp }

function tframecomp.gettemplate: tframetemplate;
begin
 result:= tframetemplate(ftemplate);
end;

function tframecomp.gettemplateclass: templateclassty;
begin
 result:= tframetemplate;
end;

procedure tframecomp.settemplate(const Value: tframetemplate);
begin
 ftemplate.Assign(value);
end;

{ tcustomface }

procedure tcustomface.internalcreate;
begin
 fi.image:= tmaskedbitmap.create(false);
 fi.image.onchange:= {$ifdef FPC}@{$endif}imagechanged;
 fi.fade_pos:= trealarrayprop.Create;
 fi.fade_color:= tcolorarrayprop.Create;
 fi.fade_pos.link([fi.fade_color,fi.fade_pos]);
 fi.fade_transparency:= cl_none;
 fi.fade_pos.onchange:= {$ifdef FPC}@{$endif}dochange;
 fi.fade_color.onchange:= {$ifdef FPC}@{$endif}dochange;
end;

constructor tcustomface.create(const owner: twidget);
begin
 fintf:= iface(owner);
 owner.fface:= self;
 internalcreate;
end;

constructor tcustomface.create(const intf: iface);
begin
 fintf:= intf;
 internalcreate;
end;

destructor tcustomface.destroy;
begin
 if ftemplate <> nil then begin
  fintf.getwidget.setlinkedvar(nil,tmsecomponent(ftemplate));
 end;
 inherited;
 fi.image.Free;
 fi.fade_pos.Free;
 fi.fade_color.free;
 falphabuffer.Free;
end;

procedure tcustomface.change;
begin
 fintf.getwidget.invalidate;
end;

procedure updatefadearray(var fi: faceinfoty; const sender: tarrayprop);
var
 ar1: integerarty;
begin
 if sender = fi.fade_pos then begin
  with trealarrayprop1(fi.fade_pos) do begin
   if high(fitems) >= 0 then begin
    sortarray(trealarrayprop1(fi.fade_pos).fitems,ar1);
    fitems[0]:= 0;
    if high(fitems) > 0 then begin
     fitems[high(fitems)]:= 1;
    end;
    fi.fade_color.order(ar1);
   end;
  end;
 end;
end;

procedure tcustomface.dochange(const sender: tarrayprop; const index: integer);
begin
 updatefadearray(fi,sender);
 change;
end;

procedure tcustomface.imagechanged(const sender: tobject);
begin
 change;
end;

procedure tcustomface.setimage(const value: tmaskedbitmap);
begin
 fi.image.assign(value);
end;

procedure tcustomface.assign(source: tpersistent);
begin
 if source is tcustomface then begin
  if not (csdesigning in fintf.getwidget.componentstate) then begin
   flocalprops:= allfacelocalprops;
   with tcustomface(source) do begin
    self.fade_direction:= fade_direction;
    self.fade_color:= fade_color;
    self.fade_pos:= fade_pos;
    self.fade_transparency:= fade_transparency;
    self.image:= image;
    self.options:= options;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcustomface.paint(const canvas: tcanvas; const rect: rectty);
const
 epsilon = 0.00001;

 function calcscale(x,a,b: real): real;
 var
  rea1: real;
 begin
  rea1:= b-a;
  if rea1 > epsilon then begin
   result:= (x - a) / rea1;
  end
  else begin
   result:= x;
  end;
 end;

 function scalecolor(x: real; const a,b: rgbtriplety): rgbtriplety;
 begin
  with result do begin
   red:= a.red + round((b.red - a.red) * x);
   green:= a.green + round((b.green - a.green) * x);
   blue:= a.blue + round((b.blue - a.blue) * x);
   res:= 0;
  end;
 end;

var
 rect1: rectty;
 bmp: tbitmap;
 ipos,imax: integer;
 rgbs: array of rgbtriplety;
 poss: realarty;
 pixelscale: real;
 vert,reverse: boolean;
 first,last: integer;
 fade: prgbtripleaty;

 procedure interpolate(index: integer);
 var
  int1,int2,int3: integer;
  by1,by2: byte;
  po1,po2: prgbtriplety;
  posstep,colorstep: real;
  pos,color: real;
  rea1,rea2: real;
  co1: rgbtriplety;

 begin
  po1:= @rgbs[index];
  po2:= @rgbs[index+1];
  with po2^ do begin //find bigest difference
   by1:= abs(red - po1^.red);
   by2:= abs(green - po1^.green);
   if by2 > by1 then begin
    by1:= by2;
   end;
   by2:= abs(blue - po1^.blue);
   if by2 > by1 then begin
    by1:= by2;
   end;
  end;
  rea1:= poss[index+1] - poss[index];
  if rea1 > epsilon then begin
   rea2:= 1/(rea1*pixelscale); //step for one pixel
   if by1 = 0 then begin
    by1:= 1;
   end;
   colorstep:= 1 / by1;
   if colorstep < rea2 then begin
    colorstep:= rea2;
    by1:= ceil(1 / colorstep);
   end;
   posstep:= colorstep * pixelscale * rea1; //pixel for step
   if reverse then begin
    posstep:= -posstep;
    pos:= poss[last] - poss[index];
   end
   else begin
    pos:= poss[index];
   end;
   pos:=  pos * pixelscale;
   color:= 0;
   for int1:= 0 to by1 - 1 do begin
    if (ipos < 0) or (ipos >= imax) then begin
     break;
    end;
    pos:= pos + posstep;
    int2:= ipos;
    ipos:= round(pos);
    co1:= scalecolor(color,po1^,po2^);
    if reverse then begin
     for int3:= int2 downto ipos + 1 do begin
      fade^[int3]:= co1;
     end;
    end
    else begin
     for int3:= int2 to ipos - 1 do begin
      fade^[int3]:= co1;
     end;
    end;
    color:= color + colorstep;
   end;
   if (ipos >= 0) and (ipos < imax) then begin
    fade^[ipos]:= co1;
   end;
  end;
 end;

 procedure createalphabuffer;
 begin
  if falphabuffer = nil then begin
   falphabuffer:= tmaskedbitmap.create(false);
  end;
  falphabuffer.options:= [bmo_masked,bmo_colormask];
  falphabuffer.size:= rect1.size;
  falphabufferdest:= rect1.pos;
  falphabuffer.canvas.copyarea(canvas,rect1,nullpoint);
 end;

var
 a,b,rea1: real;
 int1: integer;
 col1,col2: rgbtriplety;

begin
 if intersectrect(rect,canvas.clipbox,rect1) then begin
  if fi.fade_color.count > 1 then begin
   with tcolorarrayprop1(fi.fade_color) do begin
    setlength(rgbs,length(fitems));
    for int1:= 0 to high(rgbs) do begin
     rgbs[int1]:= colortorgb(fintf.translatecolor(fitems[int1]));
    end;
   end;
   case fi.fade_direction of
    gd_up,gd_down: begin
     a:= (rect1.y - rect.y) / rect.cy;
     b:= (rect1.y + rect1.cy - rect.y) / rect.cy;
     pixelscale:= rect.cy;
     vert:= true;
     imax:= rect1.cy;
    end
    else begin //gd_right,gd_left
     a:= (rect1.x - rect.x) / rect.cx;
     b:= (rect1.x + rect1.cx - rect.x) / rect.cx;
     pixelscale:= rect.cx;
     vert:= false;
     imax:= rect1.cx;
    end;
   end;
   if fi.fade_direction in [gd_up,gd_left] then begin
    reverse:= true;
    rea1:= 1 - b;
    b:= 1 - a;
    a:= rea1;
   end
   else begin
    reverse:= false;
   end;
   first:= 0;
   last:= fi.fade_color.count - 1;
   with trealarrayprop1(fi.fade_pos) do begin
    for int1:= 1 to last do begin
     if fitems[int1] < a then begin
      first:= int1;
     end;
     if trealarrayprop1(fi.fade_pos).fitems[int1] >= b then begin
      last:= int1;
      break;
     end;
    end;
    if (first < high(fitems))  then begin
     col1:= scalecolor(calcscale(a,fitems[first],fitems[first+1]),
                           rgbs[first],rgbs[first+1]);
    end
    else begin
     col1:= rgbs[high(fitems)];
    end;
    col2:= scalecolor(calcscale(b,fitems[last-1],fitems[last]),
                           rgbs[last-1],rgbs[last]);
    rgbs[first]:= col1;
    rgbs[last]:= col2;
    poss:= copy(fitems);
    poss[first]:= a;
    poss[last]:= b;
    for int1:= first to last do begin
     poss[int1]:= poss[int1] - a;
    end;
    bmp:= tbitmap.create(false);
    if vert then begin
     bmp.size:= makesize(1,rect1.cy);
    end
    else begin
     bmp.size:= makesize(rect1.cx,1);
    end;
    fade:= bmp.scanline[0];
    if reverse then begin
     if vert then begin
      ipos:= rect1.cy-1;
     end
     else begin
      ipos:= rect1.cx-1;
     end;
    end
    else begin
     reverse:= false;
     ipos:= 0;
    end;
    for int1:= first to last-1 do begin
     interpolate(int1);
    end;
    if fi.options * faceoptionsmask = [] then begin
     bmp.transparency:= fi.fade_transparency;
     bmp.paint(canvas,rect1,[al_stretchx,al_stretchy]);
    end
    else begin
     createalphabuffer;
     bmp.paint(falphabuffer.mask.canvas,makerect(nullpoint,rect1.size),
      makerect(nullpoint,bmp.size),[al_stretchx,al_stretchy]);
    end;
    bmp.Free;
   end;
  end
  else begin
   if fi.fade_color.count > 0 then begin
    if fi.options * faceoptionsmask <> [] then begin
     createalphabuffer;
     falphabuffer.transparency:=
      (cardinal(colortorgb(tcolorarrayprop1(fi.fade_color).fitems[0])) xor
                $ffffffff) and $00ffffff;
    end
    else begin
     canvas.fillrect(rect1,tcolorarrayprop1(fi.fade_color).fitems[0]);
    end;
   end
   else begin
    if fi.options * faceoptionsmask <> [] then begin
     createalphabuffer;
     falphabuffer.transparency:=
      (cardinal(colortorgb(fi.fade_transparency)) xor $ffffffff) and $00ffffff;
    end;
   end;
  end;
  if fi.image.hasimage then begin
   fi.image.paint(canvas,rect);
   if fao_alphafadeimage in fi.options then begin
    doalphablend(canvas);
   end;
  end;
 end;
end;

procedure tcustomface.doalphablend(const canvas: tcanvas);
begin
 if falphabuffer <> nil then begin
  falphabuffer.paint(canvas,falphabufferdest);
  freeandnil(falphabuffer);
 end;
end;

procedure tcustomface.setoptions(const avalue: faceoptionsty);
var
 optionsbefore: faceoptionsty;
begin
 if avalue <> fi.options then begin
  optionsbefore:= fi.options;
  fi.options:= faceoptionsty(
   setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(avalue),
                 {$ifdef FPC}longword{$else}byte{$endif}(fi.options),
                 {$ifdef FPC}longword{$else}byte{$endif}(faceoptionsmask)));
  if fao_alphafadeall in (faceoptionsty(
      {$ifdef FPC}longword{$else}byte{$endif}(optionsbefore) xor 
      {$ifdef FPC}longword{$else}byte{$endif}(fi.options))) then begin
   fintf.getwidget.widgetregioninvalid;
  end;
  change;
 end;
end;

procedure tcustomface.setfade_color(const Value: tcolorarrayprop);
begin
 fi.fade_color.assign(Value);
end;

procedure tcustomface.setfade_pos(const Value: trealarrayprop);
begin
 fi.fade_pos.assign(Value);
end;

procedure tcustomface.setfade_direction(const Value: graphicdirectionty);
begin
 if fi.fade_direction <> value then begin
  fi.fade_direction:= Value;
  change;
 end;
end;

procedure tcustomface.setfade_transparency(const avalue: colorty);
begin
 if fi.fade_transparency <> avalue then begin
  fi.fade_transparency:= avalue;
  change;
 end;
end;

procedure tcustomface.settemplate(const avalue: tfacecomp);
begin
 fintf.getwidget.setlinkedvar(avalue,tmsecomponent(ftemplate));
 if avalue <> nil then begin
  assign(avalue);
 end;
end;

{
function tcustomface.arepropsstored: boolean;
begin
 result:= ftemplate = nil;
end;
}

procedure tcustomface.settemplateinfo(const ainfo: faceinfoty);
begin
 if not (fal_facolor in flocalprops) then begin
  fade_color:= ainfo.fade_color;
 end;
 if not (fal_fapos in flocalprops) then begin
  fade_pos:= ainfo.fade_pos;
 end;
 if not (fal_image in flocalprops) then begin
  image:= ainfo.image;
 end;
 if not (fal_fadirection in flocalprops) then begin
  fade_direction:= ainfo.fade_direction;
 end;
 if not (fal_fatransparency in flocalprops) then begin
  fade_transparency:= ainfo.fade_transparency;
 end;
 if not (fal_options in flocalprops) then begin
  options:= ainfo.options;
 end;
end;

procedure tcustomface.setlocalprops(const avalue: facelocalpropsty);
begin
 if flocalprops <> avalue then begin
  flocalprops:= avalue;
  if ftemplate <> nil then begin
   settemplateinfo(ftemplate.template.fi);
  end;
 end;
end;

function tcustomface.isoptionsstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_options in flocalprops);
end;

function tcustomface.isimagestored: boolean;
begin
 result:= (ftemplate = nil) or (fal_image in flocalprops);
end;

function tcustomface.isfacolorstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_facolor in flocalprops);
end;

function tcustomface.isfaposstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_fapos in flocalprops);
end;

function tcustomface.isfadirectionstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_fadirection in flocalprops);
end;

function tcustomface.isfatransparencystored: boolean;
begin
 result:= (ftemplate = nil) or (fal_fatransparency in flocalprops);
end;

{ tfacetemplate }

constructor tfacetemplate.create(const owner: tmsecomponent;
                       const onchange: notifyeventty);
begin
 fi.image:= tmaskedbitmap.create(false);
 fi.fade_pos:= trealarrayprop.Create;
 fi.fade_color:= tcolorarrayprop.Create;
 fi.fade_pos.link([fi.fade_color,fi.fade_pos]);
 fi.fade_transparency:= cl_none;
 fi.image.onchange:= {$ifdef FPC}@{$endif}doimagechange;
 fi.fade_pos.onchange:= {$ifdef FPC}@{$endif}dochange;
 fi.fade_color.onchange:= {$ifdef FPC}@{$endif}dochange;
 inherited;
end;

destructor tfacetemplate.destroy;
begin
 inherited;
 fi.image.Free;
 fi.fade_pos.Free;
 fi.fade_color.Free;
end;

procedure tfacetemplate.setfade_direction(const Value: graphicdirectionty);
begin
 fi.fade_direction:= Value;
 changed;
end;

procedure tfacetemplate.dochange(const sender: tarrayprop; const index: integer);
begin
 updatefadearray(fi,sender);
 changed;
end;

procedure tfacetemplate.doimagechange(const sender: tobject);
begin
 changed;
end;

procedure tfacetemplate.setoptions(const avalue: faceoptionsty);
begin
 fi.options:= faceoptionsty(setsinglebit(
    {$ifdef FPC}longword{$else}byte{$endif}(avalue),
    {$ifdef FPC}longword{$else}byte{$endif}(fi.options),
    {$ifdef FPC}longword{$else}byte{$endif}(faceoptionsmask)));
 changed;
end;

procedure tfacetemplate.setfade_color(const Value: tcolorarrayprop);
begin
 fi.fade_color.Assign(Value);
end;

procedure tfacetemplate.setfade_pos(const Value: trealarrayprop);
begin
 fi.fade_pos.Assign(Value);
end;

procedure tfacetemplate.setfade_transparency(const avalue: colorty);
begin
 fi.fade_transparency:= avalue;
 changed;
end;

procedure tfacetemplate.setimage(const Value: tmaskedbitmap);
begin
 fi.image.assign(value);
 changed;
end;

procedure tfacetemplate.doassignto(dest: tpersistent);
begin
 if dest is tcustomface then begin
  tcustomface(dest).settemplateinfo(fi);
 end;
end;

procedure tfacetemplate.copyinfo(const source: tpersistenttemplate);
begin
 with tfacetemplate(source) do begin
  self.fi.image.assign(image);
  self.fi.fade_pos.beginupdate;
  self.fi.fade_color.beginupdate;
  self.fi.fade_pos.assign(fade_pos);
  self.fi.fade_color.assign(fade_color);
  self.fi.fade_pos.endupdate(true);
  self.fi.fade_color.endupdate;
 end;
end;

function tfacetemplate.getinfosize: integer;
begin
 result:= sizeof(fi.fade_direction);
end;

function tfacetemplate.getinfoad: pointer;
begin
 result:= @fi.fade_direction;
end;

{ tfacecomp }

function tfacecomp.gettemplate: tfacetemplate;
begin
 result:= tfacetemplate(ftemplate);
end;

procedure tfacecomp.settemplate(const Value: tfacetemplate);
begin
 ftemplate.Assign(value);
end;

function tfacecomp.gettemplateclass: templateclassty;
begin
 result:= tfacetemplate;
end;

{ tdragobject }

constructor tdragobject.create(const asender: tobject; var instance: tdragobject;
                                 const apickpos: pointty);
begin
 fsender:= asender;
 finstancepo:= @instance;
 instance.Free;
 instance:= self;
 fpickpos:= apickpos;
end;

destructor tdragobject.destroy;
begin
 finstancepo^:= nil;
 inherited;
end;

procedure tdragobject.acepted(const apos: pointty);
begin
 //dummy
end;

procedure tdragobject.refused(const apos: pointty);
begin
 //dummy
end;

function tdragobject.sender: tobject;
begin
 result:= fsender;
end;

{ twidget }

constructor twidget.create(aowner: tcomponent);
begin
 fnoinvalidate:= 1;
 fwidgetstate:= defaultwidgetstates;
 fanchors:= defaultanchors;
 foptionswidget:= defaultoptionswidget;
 fwidgetrect.cx:= defaultwidgetwidth;
 fwidgetrect.cy:= defaultwidgetheight;
 fcolor:= defaultwidgetcolor;
 inherited;
{$ifdef FPC}
// fnoinvalidate:= 0;
        //afterconstruction does not work with newinstance
{$endif}
end;

procedure twidget.afterconstruction;
begin
 inherited;
 fnoinvalidate:= 0;
end;

destructor twidget.destroy;
begin
 include(fwidgetstate,ws_destroying);
 if (app <> nil) then begin
  app.widgetdestroyed(self);
 end;
 updateroot;
 if fwindow <> nil then begin
  fwindow.widgetdestroyed(self);
 end;
 if fwidgets <> nil then begin
  if ow_destroywidgets in foptionswidget then begin
   while length(fwidgets) > 0 do begin
    with fwidgets[high(fwidgets)] do begin
     if ws_iswidget in fwidgetstate then begin
      free;
     end
     else begin
      setlength(fwidgets,high(fwidgets));
     end;
    end;
   end;
  end
  else begin
   while length(fwidgets) > 0 do begin
    fwidgets[high(fwidgets)].parentwidget:= nil;
   end;
  end;
  fwidgets:= nil;
 end;
 hide;
 parentwidget:= nil;
 if ownswindow1 then begin
  fwindow.Free;
 end;
 ffont.free;
 fframe.free;
 fface.free;
 inherited;
 destroyregion(fwidgetregion);
end;

procedure twidget.initnewcomponent;
begin
 inherited;
 synctofontheight;
end;

procedure twidget.createframe;
begin
 if fframe = nil then begin
  createframe1;
 end;
end;

procedure twidget.createface;
begin
 if fface = nil then begin
  createface1;
 end;
end;

procedure twidget.createfont;
begin
 if ffont = nil then begin
  createfont1;
 end;
end;

function twidget.widgetcount: integer;
begin
 result:= length(fwidgets);
end;

function twidget.getcontainer: twidget;
begin
 result:= self;
end;

function twidget.childrencount: integer;
begin
 result:= widgetcount;
end;

function twidget.getwidgets(const index: integer): twidget;
begin
 if (index < 0) or (index >= length(fwidgets)) then begin
  tlist.error(slistindexerror,index);
 end;
 result:= fwidgets[index]; //fwidgets can be nil -> exception
end;

function twidget.indexofwidget(const awidget: twidget): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(fwidgets) do begin
  if fwidgets[int1] = awidget then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure twidget.placexorder(const startx: integer; const dist: array of integer;
                const awidgets: array of twidget; const endmargin: integer = minint);
               //origin = clientpos, endmargin by size adjust of widgets 
               //with [an_top,an_bottom], minit -> no change
var
 int1,int2,int3,int4,int5: integer;
 widget1: twidget;
 ar1: integerarty;
begin
 if (high(awidgets) >= 0) then begin
  widget1:= awidgets[0].fparentwidget;
  if widget1 <> nil then begin
   setlength(ar1,length(awidgets));
   int2:= startx + widget1.clientwidgetpos.x;
   for int1:= 0 to high(awidgets) do begin
    ar1[int1]:= int2;
    if int1 <= high(dist) then begin
     int5:= dist[int1];
    end
    else begin
     if high(dist) >= 0 then begin
      int5:= dist[high(dist)];
     end
     else begin
      int5:= 0;
     end;
    end;
    int2:= int2 + int5 + awidgets[int1].fwidgetrect.cx;
   end;
   if endmargin <> minint then begin
    int2:= ar1[high(awidgets)] + awidgets[high(awidgets)].fwidgetrect.cx + 
                    endmargin - (widget1.paintrect.x + widget1.paintrect.cx);
   end
   else begin
    int2:= 0;
   end;
   int4:= 0;
   for int1:= 0 to high(awidgets) do begin
    with awidgets[int1] do begin
     bounds_x:= ar1[int1] + int4;
     if anchors * [an_left,an_right] = [an_left,an_right] then begin
      int3:= bounds_cx;
      bounds_cx:= bounds_cx - int2;
      int3:= bounds_cx - int3; //delta
      int2:= int2 + int3;
      int4:= int4 + int3;
     end;
    end;
   end;
   with awidgets[high(awidgets)] do begin
    bounds_cx:= bounds_cx - int2;
   end;
  end;
 end;
end;

procedure twidget.placeyorder(const starty: integer; const dist: array of integer;
                const awidgets: array of twidget; const endmargin: integer = minint);
               //origin = clientpos, endmargin by size adjust of widgets 
               //with [an_left,an_right], minit -> no change
var
 int1,int2,int3,int4,int5: integer;
 widget1: twidget;
 ar1: integerarty;
begin
 if (high(awidgets) >= 0) then begin
  widget1:= awidgets[0].fparentwidget;
  if widget1 <> nil then begin
   setlength(ar1,length(awidgets));
   int2:= starty + widget1.clientwidgetpos.y;
   for int1:= 0 to high(awidgets) do begin
    ar1[int1]:= int2;
    if int1 <= high(dist) then begin
     int5:= dist[int1];
    end
    else begin
     if high(dist) >= 0 then begin
      int5:= dist[high(dist)];
     end
     else begin
      int5:= 0;
     end;
    end;
    int2:= int2 + int5 + awidgets[int1].fwidgetrect.cy;
   end;
   if endmargin <> minint then begin
    int2:= ar1[high(awidgets)] + awidgets[high(awidgets)].fwidgetrect.cy + 
                    endmargin - (widget1.paintrect.y + widget1.paintrect.cy);
   end
   else begin
    int2:= 0;
   end;
   int4:= 0;
   for int1:= 0 to high(awidgets) do begin
    with awidgets[int1] do begin
     bounds_y:= ar1[int1] + int4;
     if anchors * [an_top,an_bottom] = [an_top,an_bottom] then begin
      int3:= bounds_cy;
      bounds_cy:= bounds_cy - int2;
      int3:= bounds_cy - int3; //delta
      int2:= int2 + int3;
      int4:= int4 + int3;
     end;
    end;
   end;
   with awidgets[high(awidgets)] do begin
    bounds_cy:= bounds_cy - int2;
   end;
  end;
 end;
end;

function twidget.aligny(const mode: widgetalignmodety;
                const awidgets: array of twidget): integer;

 function getrefpoint(const awidget: twidget): integer;
 begin
  with awidget do begin
   case mode of
    wam_start: begin
     result:= fwidgetrect.y + framepos.y;
    end;
    wam_center: begin
     result:= fwidgetrect.y + framepos.y + framesize.cy div 2;
    end;
    else begin //wam_end
     result:= fwidgetrect.y + framepos.y + awidget.framesize.cy;
    end;
   end;
  end;
 end;

var
 int1,int2,int3: integer;

begin
 if high(awidgets) >= 0 then begin
  result:= getrefpoint(awidgets[0])
 end
 else begin
  result:= 0;
 end;
 if high(awidgets) > 0 then begin
  int2:= result;
  for int1:= 1 to high(awidgets) do begin
   int3:= int2 - getrefpoint(awidgets[int1]);
   with awidgets[int1] do begin
    if (mode = wam_start) and (an_bottom in anchors) then begin
     bounds_cy:= bounds_cy - int3;
    end;
    if (mode = wam_end) and (an_top in anchors) then begin
     bounds_cy:= bounds_cy + int3;
    end
    else begin
     bounds_y:= bounds_y + int3;
    end;
   end; 
  end;
 end;
end;

function twidget.alignx(const mode: widgetalignmodety;
            const awidgets: array of twidget): integer;

 function getrefpoint(const awidget: twidget): integer;
 begin
  with awidget do begin
   case mode of
    wam_start: begin
     result:= fwidgetrect.x + framepos.x;
    end;
    wam_center: begin
     result:= fwidgetrect.x + framepos.x + framesize.cx div 2;
    end;
    else begin //wam_end
     result:= fwidgetrect.x + framepos.x + awidget.framesize.cx;
    end;
   end;
  end;
 end;

var
 int1,int2,int3: integer;

begin
 if high(awidgets) >= 0 then begin
  result:= getrefpoint(awidgets[0])
 end
 else begin
  result:= 0;
 end;
 if high(awidgets) > 0 then begin
  int2:= result;
  for int1:= 1 to high(awidgets) do begin
   int3:= int2 - getrefpoint(awidgets[int1]);
   with awidgets[int1] do begin
    if (mode = wam_start) and (an_right in anchors) then begin
     bounds_cx:= bounds_cx - int3;
    end;
    if (mode = wam_end) and (an_left in anchors) then begin
     bounds_cx:= bounds_cx + int3;
    end
    else begin
     bounds_x:= bounds_x + int3;
    end;
   end;
  end;
 end;
end;

function twidget.getchildwidgets(const index: integer): twidget;
begin
 result:= getwidgets(index);
end;

function compzorder(const l,r): integer;
begin
 result:= 0;
 if ow_background in twidget(l).foptionswidget then dec(result);
 if ow_top in twidget(l).foptionswidget then inc(result);
 if ow_background in twidget(r).foptionswidget then inc(result);
 if ow_top in twidget(r).foptionswidget then dec(result);
end;

procedure twidget.sortzorder;
begin
 if not (csloading in componentstate) and not (ws_loadlock in fwidgetstate) then begin
  sortarray(pointerarty(fwidgets),{$ifdef FPC}@{$endif}compzorder);
  invalidatewidget;
 end;
end;

procedure twidget.registerchildwidget(const child: twidget);
begin
 if indexofwidget(child) >= 0 then begin
  guierror(gue_alreadyregistered,self,':'+child.name);
 end;
 setlength(fwidgets,high(fwidgets)+2);
 fwidgets[high(fwidgets)]:= child;
 child.rootchanged;
 child.updateopaque(true); //for cl_parent
 if not (csloading in componentstate) and not (ws_loadlock in fwidgetstate) then begin
  sortzorder;
  updatetaborder(child);
  if child.visible then begin
   widgetregionchanged(child);
   if focused then begin
    checksubfocus(false);
   end;
  end;
 end;
end;

procedure twidget.unregisterchildwidget(const child: twidget);
begin
 if fwidgets <> nil then begin
  removeitem(pointerarty(fwidgets),child);
 end;
 if ffocusedchild = child then begin
  ffocusedchild:= nil;
 end;
 if ffocusedchildbefore = child then begin
  ffocusedchildbefore:= nil;
 end;
 if fdefaultfocuschild = child then begin
  fdefaultfocuschild:= nil;
 end;
 child.rootchanged;
 if not (csloading in componentstate) and not (ws_loadlock in fwidgetstate) then begin
  updatetaborder(nil);
  if child.isvisible then begin
   widgetregionchanged(child);
  end;
 end;
end;

procedure twidget.setcolor(const Value: colorty);
begin
 if fcolor <> value then begin
  if not (csloading in componentstate) then begin
   fcolor := Value;
   colorchanged;
  end
  else begin
   fcolor := Value;
  end;
 end;
end;

procedure twidget.setparentwidget(const Value: twidget);
var
 newpos: pointty;
 widget1: twidget;
begin
 if fparentwidget <> value then begin
  if entered then begin
   window.nofocus;
  end;
  if (value <> nil) then begin
   if value = self then begin
    raise exception.create('Recursive parent.');
   end;
   if (fwindow <> nil) and ownswindow1 then begin
    newpos:= translatewidgetpoint(fwidgetrect.pos,nil,value);
//    newpos:= subpoint(fwidgetrect.pos,value.rootwidget.fwidgetrect.pos);
    fwindow.fowner:= nil;
    freeandnil(fwindow);
   end
   else begin
    newpos:= fwidgetrect.pos;
   end;
  end
  else begin
   newpos:= addpoint(rootwidget.fwidgetrect.pos,rootpos);
   fcolor:= translatecolor(fcolor);
//   if fcolor = cl_parent then begin
//    fcolor:= actualcolor;
//   end;
  end;

  if fparentwidget <> nil then begin
   widget1:= fparentwidget;
   fparentwidget:= nil;
   fwindow:= nil;
   widget1.unregisterchildwidget(self);
   subpoint1(newpos,widget1.clientwidgetpos);
  end;
  if fparentwidget <> nil then begin
   exit;                   //interrupt
  end;
  fparentwidget:= Value;
//  initparentclientrect;
  fwidgetrect.pos:= newpos;
  if fparentwidget <> nil then begin
//   if not (csloading in componentstate) then begin
//    addpoint1(fwidgetrect.pos,fparentwidget.clientwidgetpos);
//   end;
   fparentwidget.registerchildwidget(self);
   parentclientrectchanged;
  end
  else begin
   if visible and not (ws_destroying in fwidgetstate) then begin
    window.show(false);
   end;
  end;
 end;
end;

procedure twidget.checkwidgetsize(var size: sizety);
begin
 if (fminsize.cx > 0) and (size.cx < fminsize.cx) then begin
  size.cx:= fminsize.cx;
 end;
 if (fminsize.cy > 0) and (size.cy < fminsize.cy) then begin
  size.cy:= fminsize.cy;
 end;
 if (fmaxsize.cx > 0) and (size.cx > fmaxsize.cx) then begin
  size.cx:= fmaxsize.cx;
 end;
 if (fmaxsize.cy > 0) and (size.cy > fmaxsize.cy) then begin
  size.cy:= fmaxsize.cy;
 end;
end;

function twidget.minclientsize: sizety;
begin
 if not (ws_minclientsizevalid in fwidgetstate) then begin
  if fframe <> nil then begin
   with fframe do begin
    checkstate;
    fminclientsize:= calcminscrollsize;
    if fminclientsize.cx < fpaintrect.cx then begin
     fminclientsize.cx:= fpaintrect.cx;
    end;
    if fminclientsize.cy < fpaintrect.cy then begin
     fminclientsize.cy:= fpaintrect.cy;
    end;
   end;
  end
  else begin
   fminclientsize:= fwidgetrect.size;
  end;
  include(fwidgetstate,ws_minclientsizevalid);
 end;
 result:= fminclientsize;
end;

procedure twidget.internalsetwidgetrect(Value: rectty; const windowevent: boolean);
var
 bo1,poscha,sizecha: boolean;
 int1: integer;
begin
 if not windowevent then begin
  checkwidgetsize(value.size);
 end;
 poscha:= (value.x <> fwidgetrect.x) or (value.y <> fwidgetrect.y);
 sizecha:= (value.cx <> fwidgetrect.cx) or (value.cy <> fwidgetrect.cy);
 bo1:= isvisible and (poscha or sizecha);
 if bo1 and (fparentwidget <> nil) then begin
  invalidatewidget; //old position
 end;
 if poscha then begin
  fwidgetrect.x:= value.x;
  fwidgetrect.y:= value.y;
  rootchanged;
 end;
 if sizecha then begin
  inc(fsetwidgetrectcount);
  int1:= fsetwidgetrectcount;
  fwidgetrect.cx:= value.cx;
  fwidgetrect.cy:= value.cy;
  invalidateparentminclientsize;
  exclude(fwidgetstate,ws_minclientsizevalid);
  if not (csloading in componentstate) then begin
   sizechanged;
   if fsetwidgetrectcount <> int1 then begin
    if poscha and not (csloading in componentstate) then begin
     poschanged;
    end;
    exit;
   end;
  end
  else begin
   if fframe <> nil then begin
    exclude(fframe.fstate,fs_rectsvalid);
   end;
  end;
 end;
 if bo1 then begin
  if (fparentwidget <> nil) then begin
   fparentwidget.widgetregionchanged(self); //new position
  end;
  if ownswindow1 and (tws_windowvisible in fwindow.fstate) then begin
   fwindow.checkwindow(windowevent);
  end;
 end;
 if poscha and not (csloading in componentstate) then begin
  poschanged;
 end;
end;

procedure twidget.setwidgetrect(const Value: rectty);
begin
 internalsetwidgetrect(value,false);
end;

function twidget.getwidgetrect: rectty;
begin
 result:= fwidgetrect;
end;

function twidget.getright: integer;
begin
 result:= fwidgetrect.x + fwidgetrect.cx;
end;

procedure twidget.setright(const avalue: integer);
begin
 bounds_cx:= avalue - fwidgetrect.x;
end;

function twidget.getbottom: integer;
begin
 result:= fwidgetrect.y + fwidgetrect.cy;
end;

procedure twidget.setbottom(const avalue: integer);
begin
 bounds_cy:= avalue - fwidgetrect.y;
end;

procedure twidget.setsize(const Value: sizety);
var
 rect1: rectty;
begin
 rect1.pos:= fwidgetrect.pos;
 rect1.size:= value;
 internalsetwidgetrect(rect1,false);
end;

procedure twidget.setpos(const Value: pointty);
var
 rect1: rectty;
begin
 rect1.size:= fwidgetrect.size;
 rect1.pos:= value;
 internalsetwidgetrect(rect1,false);
end;

procedure twidget.setbounds_x(const Value: integer);
var
 rect1: rectty;
begin
 if fwidgetrect.x <> value then begin
  rect1:= fwidgetrect;
  rect1.x:= value;
  internalsetwidgetrect(rect1,false);
 end;
end;

procedure twidget.setbounds_y(const Value: integer);
var
 rect1: rectty;
begin
 if fwidgetrect.y <> value then begin
  rect1:= fwidgetrect;
  rect1.y:= value;
  internalsetwidgetrect(rect1,false);
 end;
end;

procedure twidget.setbounds_cx(const Value: integer);
var
 rect1: rectty;
begin
 if fwidgetrect.cx <> value then begin
  rect1:= fwidgetrect;
  if value < 0 then begin
   rect1.cx:= 0;
  end
  else begin
   rect1.cx:= value;
  end;
  internalsetwidgetrect(rect1,false);
 end;
end;

procedure twidget.setbounds_cy(const Value: integer);
var
 rect1: rectty;
begin
 if fwidgetrect.cy <> value then begin
  rect1:= fwidgetrect;
  if value < 0 then begin
   rect1.cy:= 0;
  end
  else begin
   rect1.cy:= value;
  end;
  internalsetwidgetrect(rect1,false);
 end;
end;

procedure twidget.updatesizerange(value: integer; var dest: integer);
begin
 if dest <> value then begin
  if value < 0 then begin
   value:= 0;
  end;
  dest:= Value;
  if value > 0 then begin
   setwidgetrect(fwidgetrect);
  end;
  if not (csloading in componentstate) and ownswindow1 then begin
   fwindow.sizeconstraintschanged;
  end;
 end;
end;

procedure twidget.updatesizerange(const value: sizety; var dest: sizety);
begin
 updatesizerange(value.cx,dest.cx);
 updatesizerange(value.cy,dest.cy);
end;

procedure twidget.setbounds_cxmin(const Value: integer);
begin
 updatesizerange(value,fminsize.cx);
end;

procedure twidget.setbounds_cymin(const Value: integer);
begin
 updatesizerange(value,fminsize.cy);
end;

procedure twidget.setbounds_cxmax(const Value: integer);
begin
 updatesizerange(value,fmaxsize.cx);
end;

procedure twidget.setbounds_cymax(const Value: integer);
begin
 updatesizerange(value,fmaxsize.cy);
end;

procedure twidget.setminsize(const avalue: sizety);
begin
 updatesizerange(avalue,fminsize);
end;

procedure twidget.setmaxsize(const avalue: sizety);
begin
 updatesizerange(avalue,fmaxsize);
end;

procedure twidget.loaded;
begin
 include(fwidgetstate,ws_loadedproc);
 try
  exclude(fwidgetstate1,ws1_widgetregionvalid);
  inherited;
//  if fparentwidget = nil then begin
//   parentfontchanged;
//  end;
  sortzorder;
  updatetaborder(nil);
//  invalidatewidget;
  if fframe <> nil then begin
   fframe.parentfontchanged;
  end;
  sizechanged;
  poschanged;
  fontchanged;
//  updatefontheight;
  colorchanged;
  enabledchanged; //-> statechanged
  if ownswindow1 and (ws_visible in fwidgetstate) and
                          (componentstate * [csloading,csinline] = []) then begin
   fwindow.show(false);
  end;
 finally
  exclude(fwidgetstate,ws_loadedproc);
 end;
end;

procedure twidget.updateopaque(const children: boolean);
var
 bo1: boolean;
 int1: integer;
begin
 bo1:= ws_opaque in fwidgetstate;
 if isvisible then begin
  include(fwidgetstate,ws_isvisible);
  if not (ws_nopaint in fwidgetstate) and
              (actualcolor <> cl_transparent) then begin
   include(fwidgetstate,ws_opaque);
  end
  else begin
   exclude(fwidgetstate,ws_opaque);
  end;
 end
 else begin
  fwidgetstate:= fwidgetstate - [ws_opaque,ws_isvisible];
 end;
 if (bo1 <> (ws_opaque in fwidgetstate)) and (fparentwidget <> nil) then begin
  fparentwidget.widgetregionchanged(self);
 end;
 if children then begin
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].updateopaque(children);
  end;
 end;
end;

procedure twidget.colorchanged;
var
 int1: integer;
begin
 updateopaque(true);
 invalidatewidget;
 for int1:= 0 to widgetcount - 1 do begin
  with widgets[int1] do begin
   if fcolor = cl_parent then begin
    colorchanged;
   end;
  end;
 end;
end;

procedure twidget.statechanged;
begin
 if fframe <> nil then begin
  fframe.updatewidgetstate;
 end;
end;

procedure twidget.enabledchanged;
var
 int1: integer;
 bo1: boolean;
begin
 if fframe <> nil then begin
  bo1:= isenabled;
  if bo1 or not (frl_nodisable in fframe.flocalprops) then begin
   fframe.setdisabled(not bo1);
  end;
 end;
 for int1:= 0 to widgetcount - 1 do begin
  widgets[int1].enabledchanged;
 end;
 statechanged;
end;

procedure twidget.activechanged;
begin
 statechanged;
 if (ws_focused in fwidgetstate) and needsfocuspaint then begin
  invalidatewidget;
 end;
end;

procedure twidget.visiblechanged;
begin
 updateopaque(false);
 statechanged;
end;

procedure twidget.poschanged;
begin
 if fframe <> nil then begin
  fframe.poschanged;
 end;
 if ownswindow1 then begin
  fwindow.poschanged;
 end;
end;

procedure twidget.sizechanged;
begin
 if fframe <> nil then begin
  fframe.internalupdatestate;
 end
 else begin
  clientrectchanged;
 end;
 if ownswindow1 then begin
  fwindow.sizechanged;
 end;
end;

function twidget.calcminscrollsize: sizety;
var
 int1,int2: integer;
 anch: anchorsty;
 indent: framety;
 clientorig: pointty;
begin
 result.cx:= -bigint;
 result.cy:= -bigint;
 if fframe <> nil then begin
  indent:= fframe.fi.innerframe;
//  clientorig:= subpoint(fframe.fpaintrect.pos,fframe.fclientrect.pos);
  clientorig.x:= -fframe.fpaintrect.x-fframe.fclientrect.x;
  clientorig.y:= -fframe.fpaintrect.y-fframe.fclientrect.y;
 end
 else begin
  indent:= nullframe;
  clientorig:= nullpoint;
 end;
 for int1:= 0 to widgetcount - 1 do begin
  with fwidgets[int1],fwidgetrect do begin
   if visible or (csdesigning in componentstate) then begin
    anch:= fanchors * [an_left,an_right];
    if anch = [an_right] then begin
//     int2:= cx + indent.left;
     int2:= fparentclientsize.cx - fwidgetrect.x + indent.left + clientorig.x;
    end
    else begin
     if anch = [] then begin
      int2:= fminsize.cx{ + indent.left + indent.right};
     end
     else begin
      if anch = [an_left,an_right] then begin
//       int2:= clientorig.x + x + fminsize.cx;
       int2:= fparentclientsize.cx - cx + fminsize.cx;
      end
      else begin //[an_left
       int2:= clientorig.x + x + cx + indent.right;
      end;
     end;
    end;
    if int2 > result.cx then begin
     result.cx:= int2;
    end;

    anch:= fanchors * [an_top,an_bottom];
    if anch = [an_bottom] then begin
//     int2:= cy + indent.top;
     int2:= fparentclientsize.cy - fwidgetrect.y + indent.top + clientorig.y;
    end
    else begin
     if anch = [] then begin
      int2:= fminsize.cy{ + indent.top + indent.bottom};
     end
     else begin
      if anch = [an_top,an_bottom] then begin
//       int2:= clientorig.y + y + fminsize.cy;
       int2:= fparentclientsize.cy - cy + fminsize.cy;
      end
      else begin //[an_top]
       int2:= clientorig.y + y + cy + indent.bottom;
      end;
     end;
    end;
    if int2 > result.cy then begin
     result.cy:= int2;
    end;
   end;
  end;
 end;
end;

procedure twidget.parentclientrectchanged;

 function agetsize: sizety;
 begin
  if ws_loadedproc in fwidgetstate then begin
   result:= fparentclientsize;
  end
  else begin
   if fparentwidget = nil then begin
    result:= fwidgetrect.size;
   end
   else begin
    result:= fparentwidget.minclientsize;
   end;
  end;
 end;

var
 size1,delta: sizety;
 anch: anchorsty;
 rect1: rectty;
 int1: integer;
// bo1: boolean;

begin
 if not (csloading in componentstate) and
  (not (ws1_anchorsizing in fwidgetstate1){ or
               (ws1_clientsizing in fparentwidget.fwidgetstate1)}) then begin
  int1:= 0; //loopcount
  repeat
   size1:= agetsize;
   rect1:= fwidgetrect;
   delta:= subsize(size1,fparentclientsize);
   anch:= fanchors * [an_left,an_right];
   if anch <> [an_left] then begin
    if (anch = [an_left,an_right]){ or (anch = []) and (delta.cx <> 0)} then begin
     inc(rect1.cx,delta.cx);
    end
    else begin
     if anch = [an_right] then begin
      inc(rect1.x,delta.cx);
     end
     else begin
      if anch = [] then begin
       if fparentwidget <> nil then begin
        rect1.x:= fparentwidget.paintpos.x;
        rect1.cx:= fparentwidget.paintsize.cx;
       end;
      end;
     end;
    end;
   end;
   anch:= fanchors * [an_top,an_bottom];
   if anch <> [an_top] then begin
    if (anch = [an_top,an_bottom]){ or (anch = []) and (delta.cy <> 0)} then begin
     inc(rect1.cy,delta.cy);
    end
    else begin
     if anch = [an_bottom] then begin
      inc(rect1.y,delta.cy);
     end
     else begin
      if anch = [] then begin
       if fparentwidget <> nil then begin
        rect1.y:= fparentwidget.paintpos.y;
        rect1.cy:= fparentwidget.paintsize.cy;
       end;
      end;
     end;
    end;
   end;
   fparentclientsize:= size1;
//   bo1:= ws1_anchorsizing in fwidgetstate1;
   include(fwidgetstate1, ws1_anchorsizing);
   try
    setwidgetrect(rect1);
   finally
//    if not bo1 then begin
     exclude(fwidgetstate1, ws1_anchorsizing);
//    end;
   end;
   inc(int1);
  until sizeisequal(size1,agetsize) or (int1 > 5);
 end;
end;

procedure twidget.widgetregioninvalid;
begin
 exclude(fwidgetstate1,ws1_widgetregionvalid);
 if not (ws_opaque in fwidgetstate) and (fparentwidget <> nil) then begin
  fparentwidget.widgetregioninvalid;
 end;
end;

procedure twidget.clientrectchanged;
var
 int1: integer;
begin
 exclude(fwidgetstate,ws_minclientsizevalid);
 widgetregioninvalid;
 if isvisible then begin
  invalidatewidget;
  reclipcaret;
 end;
 if ws_loadedproc in fwidgetstate then begin
//  initparentclientrect;
  if fparentwidget <> nil then begin
   fparentclientsize:= fparentwidget.minclientsize;
  end
  else begin
   fparentclientsize:= fwidgetrect.size;
  end;
  parentclientrectchanged;
 end
 else begin
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].parentclientrectchanged;
  end;
 end;
end;

procedure twidget.widgetevent(const event: twidgetevent);
var
 int1: integer;
begin
 with event do begin
  if ces_callchildren in state then begin
   for int1:= 0 to high(fwidgets) do begin
    if ces_processed in state then begin
     break;
    end;
    fwidgets[int1].widgetevent(event);
   end;
  end;
 end;
end;

procedure twidget.sendwidgetevent(const event: twidgetevent);
                  //event will be destroyed
begin
 try
  widgetevent(event);
 finally
  event.Free;
 end;
end;

procedure twidget.release;
begin
 if ownswindow1 then begin
  window.endmodal;
 end;
 if not (ws1_releasing in fwidgetstate1) then begin
  app.postevent(tobjectevent.create(ek_release,ievent(self)));
  include(fwidgetstate1,ws1_releasing);
 end;
end;

procedure twidget.dobeforepaint(const canvas: tcanvas);
begin
 //dummy
end;

procedure twidget.dobeforepaintforeground(const canvas: tcanvas);
begin
 //dummy
end;

procedure twidget.dopaintbackground(const canvas: tcanvas);
var
 colorbefore: colorty;
begin
 if frame <> nil then begin
  colorbefore:= canvas.color;
  canvas.color:= actualcolor;
  fframe.paint(canvas,makerect(nullpoint,fwidgetrect.size));
  canvas.color:= colorbefore;
 end;
 if fface <> nil then begin
  if fframe <> nil then begin
   canvas.remove(fframe.fclientrect.pos);
   fface.paint(canvas,makerect(nullpoint,fframe.fpaintrect.size));
   canvas.move(fframe.fclientrect.pos);
  end
  else begin
   fface.paint(canvas,makerect(nullpoint,fwidgetrect.size));
  end;
 end;
end;

procedure twidget.dopaint(const canvas: tcanvas);
begin
 dopaintbackground(canvas);
 dobeforepaintforeground(canvas);
end;

procedure twidget.doonpaint(const canvas: tcanvas);
begin
 //dummy
end;

function twidget.isgroupleader: boolean;
begin
 result:= false;
end;

function twidget.needsfocuspaint: boolean;
begin
 result:= (fframe <> nil) and (fs_drawfocusrect in fframe.fstate);
end;

function twidget.getshowhint: boolean;
begin
 result:= (ow_hinton in foptionswidget) or
  not (ow_hintoff in foptionswidget) and
       (fparentwidget = nil) or fparentwidget.getshowhint;
end;

procedure twidget.showhint(var info: hintinfoty);
begin
 if getshowhint and not(csdesigning in componentstate) then begin
  with info do begin
   caption:= hint;
  end;
 end;
end;

procedure twidget.doafterpaint(const canvas: tcanvas);
begin
 if needsfocuspaint and (fwidgetstate * [ws_focused,ws_active] =
               [ws_focused,ws_active]) then begin
  fframe.dopaintfocusrect(canvas,makerect(nullpoint,fwidgetrect.size));
 end;
end;

function twidget.needsdesignframe: boolean;
begin
 result:= (fwidgetstate * [ws_iswidget,ws_nodesignframe] = [ws_iswidget]) and
             ((fcolor = cl_parent) or (fcolor = cl_transparent) or
               (fparentwidget <> nil) and (fparentwidget.fcolor = fcolor)) and
 ((fframe = nil) or (fframe.fi.leveli = 0) and (fframe.fi.levelo = 0) and
       (fframe.fi.framewidth = 0));
end;

procedure twidget.internalpaint(const canvas: tcanvas);
var
 int1,int2: integer;
 saveindex: integer;
 actcolor: colorty;
 reg1: regionty;
 rect1: rectty;
 widget1: twidget;

begin
 canvas.save;
 canvas.intersectcliprect(makerect(nullpoint,fwidgetrect.size));
 if canvas.clipregionisempty then begin
  canvas.restore;
  exit;
 end;
 canvas.save;
 if not (ws_nopaint in fwidgetstate) then begin
  actcolor:= actualcolor;
  saveindex:= canvas.save;
  dobeforepaint(canvas);
  if (widgetcount > 0) then begin
   updatewidgetregion;
   canvas.subclipregion(fwidgetregion);
  end;
  if not canvas.clipregionisempty then begin
   if ws_opaque in fwidgetstate then begin
     canvas.fillrect(makerect(nullpoint,fwidgetrect.size),actcolor);
   end;
   canvas.font:= getfont;
   canvas.color:= actcolor;
   dopaint(canvas);
   doonpaint(canvas);
   if (fface <> nil) and (fao_alphafadenochildren in fface.fi.options) then begin
    fface.doalphablend(canvas);
   end;
  end;
  canvas.restore(saveindex);
  if (csdesigning in componentstate) and needsdesignframe then begin
   canvas.dashes:= #2#3;
   canvas.drawrect(makerect(0,0,fwidgetrect.cx-1,fwidgetrect.cy-1),cl_black);
   canvas.dashes:= '';
  end;
 end
 else begin
  updatewidgetregion;
 end;
 if (widgetcount > 0) then begin
  if fframe <> nil then begin
   fframe.checkstate;
   canvas.intersectcliprect(fframe.fpaintrect);
  end;
  rect1:= canvas.clipbox;
  for int1:= 0 to widgetcount-1 do begin
   widget1:= twidget(fwidgets[int1]);
   with widget1 do begin
    if isvisible and testintersectrect(rect1,fwidgetrect) then begin
     saveindex:= canvas.save;
     for int2:= int1 + 1 to self.widgetcount - 1 do begin
      with self.fwidgets[int2],tcanvas1(canvas) do begin
       if visible and testintersectrect(widget1.fwidgetrect,fwidgetrect) then begin
            //clip higher level siblings
        if (ws_opaque in fwidgetstate) then begin
         subcliprect(fwidgetrect);
        end
        else begin
         reg1:= createregion;
         addopaquechildren(reg1);
         subclipregion(reg1);
        end;
       end;
      end;
     end;
     if not canvas.clipregionisempty then begin
      canvas.move(fwidgetrect.pos);
      internalpaint(canvas);
     end;
     canvas.restore(saveindex);
    end;
   end;
  end;
 end;
 canvas.restore;
 if (fface <> nil) and (fao_alphafadeall in fface.fi.options) then begin
  canvas.move(paintpos);
  fface.doalphablend(canvas);
  canvas.remove(paintpos);
 end;
 doafterpaint(canvas);
 canvas.restore;
end;

procedure twidget.widgetregionchanged(const sender: twidget);
begin
 widgetregioninvalid;
 invalidaterect(sender.fwidgetrect,org_widget);
end;

procedure twidget.addopaquechildren(var region: regionty);
var
 int1: integer;
 widget: twidget;
 rect1: rectty;
begin
 if not ((fface <> nil) and (fao_alphafadeall in fface.fi.options)) then begin
  updateroot;
  if ws_isvisible in fwidgetstate then begin
   rect1.size:= fwidgetrect.size;
   rect1.pos:= nullpoint;
   for int1:= 0 to widgetcount - 1 do begin
    widget:= twidget(fwidgets[int1]);
    if ws_opaque in widget.fwidgetstate then begin
     regaddrect(region,moverect(intersectrect(rect1,widget.fwidgetrect),frootpos));
    end
    else begin
     widget.addopaquechildren(region);
    end;
   end;
  end;
 end;
end;

procedure twidget.updatewidgetregion;
begin
 if not (ws1_widgetregionvalid in fwidgetstate1) then begin
  if fwidgetregion <> 0 then begin
   destroyregion(fwidgetregion);
  end;
  if widgetcount > 0 then begin
   fwidgetregion:= createregion;
   addopaquechildren(fwidgetregion);
   if fframe <> nil then begin
    frame.checkstate;
    regintersectrect(fwidgetregion,makerect(fframe.fpaintrect.x+frootpos.x,
                                       fframe.fpaintrect.y+frootpos.y,
                                       fframe.fpaintrect.cx,fframe.fpaintrect.cy));
   end
   else begin
    regintersectrect(fwidgetregion,makerect(frootpos,fwidgetrect.size));
   end;
  end
  else begin
   fwidgetregion:= 0;
  end;
  include(fwidgetstate1,ws1_widgetregionvalid);
 end;
end;

procedure twidget.createwindow;
begin
 twindow.create(self); //sets fwindow
end;

procedure twidget.updateroot;
begin
 if not (ws1_rootvalid in fwidgetstate1) then begin
  if fparentwidget <> nil then begin
   fwindow:= fparentwidget.window;
   frootpos:= addpoint(fparentwidget.rootpos,fwidgetrect.pos);
  end
  else begin
   frootpos:= nullpoint;
   if (fwindow = nil) and not (ws_destroying in fwidgetstate) then begin
    createwindow;
    invalidatewidget;
    if (ws_visible in fwidgetstate) and
            (componentstate * [csloading,csinline] = []) then begin
     fwindow.show(false);
    end;
   end;
  end;
  include(fwidgetstate1,ws1_rootvalid);
 end;
end;

procedure twidget.rootchanged;
var
 int1: integer;
begin
 if fparentwidget <> nil then begin
  fwindow:= nil;
 end;
 fwidgetstate1:= fwidgetstate1 - [ws1_widgetregionvalid,ws1_rootvalid];
 for int1:= 0 to high(fwidgets) do begin
  fwidgets[int1].rootchanged;
 end;
end;

function twidget.ownswindow1: boolean;
begin
 result:= (fwindow <> nil) and (fwindow.fowner = self);
end;

function twidget.ownswindow: boolean;
begin
 result:= (fwindow <> nil) and (fwindow.fowner = self) and (fwindow.fwinid <> 0);
end;

function twidget.window: twindow;
begin
 updateroot;
 result:= fwindow;
end;

function twidget.rootpos: pointty;
begin
 updateroot;
 result:= frootpos;
end;

function twidget.getscreenpos: pointty;
begin
 updateroot;
 result:= addpoint(frootpos,fwindow.fowner.fwidgetrect.pos);
end;

procedure twidget.setscreenpos(const avalue: pointty);
begin
 updateroot;
 fwindow.fowner.pos:= subpoint(avalue,frootpos);
end;

function twidget.clientpostowidgetpos(const apos: pointty): pointty;
begin
 result:= addpoint(apos,clientwidgetpos);
end;

function twidget.widgetpostoclientpos(const apos: pointty): pointty;
begin
 result:= subpoint(apos,clientwidgetpos);
end;

function twidget.widgetpostopaintpos(const apos: pointty): pointty;
begin
 result:= subpoint(apos,paintpos);
end;

function twidget.paintpostowidgetpos(const apos: pointty): pointty;
begin
 result:= addpoint(apos,paintpos);
end;

function twidget.rootwidget: twidget;
begin
 if fparentwidget = nil then begin
  result:= self;
 end
 else begin
  result:= fparentwidget.rootwidget;
 end;
end;

function twidget.parentofcontainer: twidget;
var
 widget1: twidget;
begin
 result:= fparentwidget;
 if (fparentwidget <> nil) then begin
  widget1:= fparentwidget.fparentwidget;
//  if (widget1 <> nil) and (widget1.container = result) then begin
  if (widget1 <> nil) and not (ws_iswidget in result.fwidgetstate) then begin
   result:= widget1;
  end;
 end;
end;

{
function twidget.canpaint: boolean;
begin
 result:= (app <> nil) and visible and window.fcanvas.active;
end;
}
function twidget.calcframewidth(arect: prectty): sizety;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  with arect^ do begin
   result.cx:= fwidgetrect.cx - cx;
   result.cy:= fwidgetrect.cy - cy;
  end;
 end
 else begin
  result:= nullsize;
 end;
end;

function twidget.framewidth: sizety;    
                             //widgetrect.size - paintrect.size
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 result:= calcframewidth(@fframe.fpaintrect);
 {$ifdef FPC} {$checkpointer default} {$endif}
end;

function twidget.clientframewidth: sizety;  
                             //widgetrect.size - clientrect.size
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 result:= calcframewidth(@fframe.fclientrect);
 {$ifdef FPC} {$checkpointer default} {$endif}
end;

function twidget.innerclientframewidth: sizety;   
                             //widgetrect.size - innerclientrect.size
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 result:= calcframewidth(@fframe.finnerclientrect);
 {$ifdef FPC} {$checkpointer default} {$endif}
end;

function twidget.framerect: rectty;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result.pos:= pointty(fframe.fouterframe.topleft);
  result.size:= framesize;
 end
 else begin
  result.pos:= nullpoint;
  result.size:= fwidgetrect.size;
 end;
end;

function twidget.framepos: pointty;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result:= pointty(fframe.fouterframe.topleft);
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.framesize: sizety;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  with fframe.fouterframe do begin
   result.cx:= fwidgetrect.cx - left - right;
   result.cy:= fwidgetrect.cy - top - bottom;
  end;
 end
 else begin
  result:= fwidgetrect.size;
 end;
end;

function twidget.paintrect: rectty;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result:= fframe.fpaintrect;
 end
 else begin
  result.pos:= nullpoint;
  result.size:= fwidgetrect.size;
 end;
end;

function twidget.clipedpaintrect: rectty;    //origin = pos, cliped by all parentpaintrects
var
 po1: pointty;
 widget1: twidget;
begin
 result:= paintrect;
 po1:= nullpoint;
 widget1:= self;
 while widget1.fparentwidget <> nil do begin
  subpoint1(po1,widget1.fwidgetrect.pos);
  widget1:= widget1.fparentwidget;
  if not intersectrect(result,moverect(widget1.paintrect,po1),result) then begin
   break;
  end;
 end;
end;

function twidget.paintpos: pointty;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result:= fframe.fpaintrect.pos;
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.paintsize: sizety;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result:= fframe.fpaintrect.size;
 end
 else begin
  result:= fwidgetrect.size;
 end;
end;

function twidget.innerpaintrect: rectty;          //origin = pos
begin
 if fframe <> nil then begin
  result:= deflaterect(fframe.fpaintrect,fframe.fi.innerframe);
 end
 else begin
  result.pos:= nullpoint;
  result.size:= fwidgetrect.size;
 end;
end;

function twidget.clientrect: rectty;
begin
 if fframe <> nil then begin
  with fframe do begin
   checkstate;
   result:= fclientrect;
  end;
 end
 else begin
  result.pos:= nullpoint;
  result.size:= fwidgetrect.size;
 end;
end;

function twidget.innerclientpos: pointty;
begin
 if frame <> nil then begin
  with frame do begin
   checkstate;
   result:= pointty(fi.innerframe.topleft);
  end;
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.innerclientsize: sizety;
begin
 if frame <> nil then begin
  with frame do begin
   checkstate;
   result:= finnerclientrect.size;
  end;
 end
 else begin
  result:= fwidgetrect.size;
 end;
end;

function twidget.innerclientrect: rectty;
begin
 if frame <> nil then begin
  with frame do begin
   checkstate;
   result:= makerect(pointty(fi.innerframe.topleft),finnerclientrect.size);
  end;
 end
 else begin
  result:= clientrect;
 end;
end;

function twidget.innerwidgetrect: rectty;
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result.pos:= addpoint(fpaintrect.pos,finnerclientrect.pos);
   result.size:= finnerclientrect.size;
  end;
 end
 else begin
  result:= clientrect;
 end;
end;

procedure twidget.createframe1;
begin
 tframe.create(self);
end;

function twidget.invalidateneeded: boolean;
begin
 result:= showing and (fnoinvalidate = 0) and
                          not (csloading in componentstate);
 if result then begin
  updateroot;
 end;
end;

procedure twidget.invalidatewidget; //invalidates the whole widget
begin
 if invalidateneeded then begin
  fwindow.invalidaterect(makerect(frootpos,fwidgetrect.size),self);
 end;
end;

procedure twidget.invalidate;  //invalidates the clientarea
begin
 if invalidateneeded then begin
  if fframe <> nil then begin
   fwindow.invalidaterect(makerect(addpoint(frootpos,fframe.fpaintrect.pos),
         fframe.fpaintrect.size),self);
  end
  else begin
   fwindow.invalidaterect(makerect(frootpos,fwidgetrect.size),self);
  end;
 end;
end;

procedure twidget.invalidaterect(const rect: rectty; org: originty = org_client);
var
 rect1: rectty;
begin
 if invalidateneeded then begin
  updateroot;
  rect1:= rect;
  case org of
   org_client: begin
    if fframe <> nil then begin
     inc(rect1.x,fframe.fclientrect.pos.x);
     inc(rect1.x,fframe.fpaintrect.pos.x);
     inc(rect1.y,fframe.fclientrect.pos.y);
     inc(rect1.y,fframe.fpaintrect.pos.y);
     msegraphutils.intersectrect(rect1,fframe.fpaintrect,rect1);
    end
    else begin
     msegraphutils.intersectrect(rect1,makerect(nullpoint,fwidgetrect.size),rect1);
    end;
   end;
   org_inner: begin
    if fframe <> nil then begin
     inc(rect1.x,fframe.finnerclientrect.pos.x);
     inc(rect1.y,fframe.finnerclientrect.pos.y);
     inc(rect1.x,fframe.fpaintrect.pos.x);
     inc(rect1.y,fframe.fpaintrect.pos.y);
     msegraphutils.intersectrect(rect1,fframe.fpaintrect,rect1);
    end
    else begin
     msegraphutils.intersectrect(rect1,makerect(nullpoint,fwidgetrect.size),rect1);
    end;
   end;
   else begin
    msegraphutils.intersectrect(rect1,makerect(nullpoint,fwidgetrect.size),rect1);
   end;
  end;
  inc(rect1.x,frootpos.x);
  inc(rect1.y,frootpos.y);
  fwindow.invalidaterect(rect1,self);
 end;
end;

procedure twidget.createface1;
begin
 tface.create(self);
end;

function twidget.widgetatpos(var info: widgetatposinfoty): twidget;
var
 int1: integer;
 astate: widgetstatesty;
begin
 result:= nil;
 with info do begin
  if (pos.x < 0) or (pos.y < 0) or (pos.x >= fwidgetrect.cx) or
              (pos.y >= fwidgetrect.cy) then begin
   exit;
  end
  else begin
   updatemousestate(info.pos);
   astate:= fwidgetstate;
   if isvisible then begin
    include(astate,ws_visible);
   end;
   if csdesigning in componentstate then begin
    include(astate,ws_enabled);
   end;
   if parentstate * astate <> parentstate then begin
    exit;
   end;
  end;
  if (frame = nil) or pointinrect(pos,fframe.fpaintrect) then begin
   for int1:= widgetcount - 1 downto 0 do begin
    with widgets[int1] do begin
     subpoint1(info.pos,fwidgetrect.pos);
     result:= widgetatpos(info);
     addpoint1(info.pos,fwidgetrect.pos);
     if result <> nil then begin
      exit;
     end;
    end;
   end;
  end;
  if childstate * astate = childstate then begin
   result:= self;
  end;
 end;
end;

function twidget.widgetatpos(const pos: pointty): twidget;
var
 info: widgetatposinfoty;
begin
 fillchar(info,sizeof(info),0);
 info.pos:= pos;
 result:= widgetatpos(info);
end;

function twidget.childatpos(const pos: pointty; const clientorigin: boolean = true): twidget;
var
 widget1: twidget;
 po1: pointty;
 int1: integer;

begin
 widget1:= container;
 result:= nil;
 po1:= pos;
 if clientorigin then begin
  addpoint1(po1,clientwidgetpos);
 end;
 if widget1 <> self then begin
  translatewidgetpoint1(po1,self,widget1);
 end;
 with widget1 do begin
  for int1:= high(fwidgets) downto 0 do begin
   with fwidgets[int1] do begin
    if isvisible and pointinrect(po1,fwidgetrect) then begin
     result:= widget1.fwidgets[int1];
     break;
    end;
   end;
  end;
 end;
end;

function compx(const l,r): integer;
begin
 result:= twidget(l).fwidgetrect.x - twidget(r).fwidgetrect.x;
 if result = 0 then begin
  result:= twidget(l).fwidgetrect.y - twidget(r).fwidgetrect.y;
 end;
end;

function twidget.getsortxchildren: widgetarty;
begin
 result:= copy(container.fwidgets);
 sortarray(pointerarty(result),{$ifdef FPC}@{$endif}compx);
end;

function compy(const l,r): integer;
begin
 result:= twidget(l).fwidgetrect.y - twidget(r).fwidgetrect.y;
 if result = 0 then begin
  result:= twidget(l).fwidgetrect.x - twidget(r).fwidgetrect.x;
 end;
end;

function twidget.getsortychildren: widgetarty;
begin
 result:= copy(container.fwidgets);
 sortarray(pointerarty(result),{$ifdef FPC}@{$endif}compy);
end;

function twidget.widgetatpos(const pos: pointty; const state: widgetstatesty): twidget;
var
 info: widgetatposinfoty;
begin
 fillchar(info,sizeof(info),0);
 info.pos:= pos;
 info.parentstate:= state;
 info.childstate:= state;
 result:= widgetatpos(info);
end;

function twidget.mouseeventwidget(const info: mouseeventinfoty): twidget;
var
 findinfo: widgetatposinfoty;
begin
 fillchar(findinfo,sizeof(findinfo),0);
 with findinfo do begin
  pos:= info.pos;
  parentstate:= [ws_enabled,ws_isvisible];
  case info.eventkind of
   ek_buttonpress,ek_buttonrelease: begin
    childstate:= [ws_enabled,ws_isvisible,ws_wantmousebutton];
   end;
   ek_mousemove,ek_mousepark: begin
    childstate:= [ws_enabled,ws_isvisible,ws_wantmousemove];
   end;
  end;
 end;
 result:= widgetatpos(findinfo);
end;

procedure twidget.updatemousestate(const apos: pointty);
begin
 if fframe <> nil then begin
  fframe.updatemousestate(self,apos);
 end
 else begin
  if (apos.x >= 0) and (apos.x < fwidgetrect.cx) and
           (apos.y >= 0) and (apos.y < fwidgetrect.cy) and
            not (ow_mousetransparent in foptionswidget) then begin
   fwidgetstate:= fwidgetstate +
          [ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,ws_wantmousefocus];
  end
  else begin
   fwidgetstate:= fwidgetstate -
          [ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,ws_wantmousefocus];
  end;
 end;
end;

procedure twidget.updatecursorshape(force: boolean = false);
var
 widget: twidget;
 cursor1: cursorshapety;
begin
 if (app <> nil) then begin
  if force or (app.fclientmousewidget = self) or
    (app.cursorshape = cr_default) and
      checkdescendent(app.fclientmousewidget) then begin
   widget:= self;
   repeat
    cursor1:= widget.fcursor;
    widget:= widget.fparentwidget;
   until (cursor1 <> cr_default) or (widget = nil);
   if (widget = nil) and (cursor1 = cr_default) then begin
    cursor1:= cr_arrow;
   end;
   app.cursorshape:= cursor1;
  end;
 end;
end;

function twidget.getclientoffset: pointty;
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result:= addpoint(fpaintrect.pos,fclientrect.pos);
  end;
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.isclientmouseevent(var info: mouseeventinfoty): boolean;
begin
 with info do begin
  if not (es_processed in eventstate) or (info.eventkind = ek_mousemove) then begin
   updatemousestate(pos);
   if [ws_mouseinclient,ws_clientmousecaptured] * fwidgetstate <> [] then begin
    if (app.fclientmousewidget <> self) and not (es_child in eventstate) then begin
                       //call updaterootwidget
     app.setclientmousewidget(self);
    end;
    result:= true;
    if fframe <> nil then begin
     subpoint1(pos,getclientoffset);
    end;
   end
   else begin
    app.setclientmousewidget(nil);
    result:= false;
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

procedure twidget.mouseevent(var info: mouseeventinfoty);
var
 clientoffset: pointty;
begin
 if info.eventstate * [es_child,es_processed] = [] then begin
  include(info.eventstate,es_child);
  try
   childmouseevent(self,info);
  finally
   exclude(info.eventstate,es_child);
  end;
 end;
 with info do begin
  if not (eventkind in mouseregionevents) and
      not (ss_left in shiftstate) and
      not((eventkind = ek_buttonrelease) and (button = mb_left)) then begin
   exclude(fwidgetstate,ws_clicked);
  end;
  if not (es_processed in info.eventstate) then begin
   clientoffset:= nullpoint;
   case eventkind of
    ek_mousemove,ek_mousepark: begin
     if isclientmouseevent(info) then begin
      clientmouseevent(info);
      clientoffset:= getclientoffset;
     end;
    end;
    ek_mousecaptureend: begin
     if ws_clientmousecaptured in fwidgetstate then begin
      clientmouseevent(info);
     end;
    end;
    ek_clientmouseleave: begin
     if app.fmousewidget = self then begin
      if fparentwidget <> nil then begin
       fparentwidget.updatecursorshape(true);
      end
      else begin
       app.cursorshape:= cr_default;
      end;
     end;
     clientmouseevent(info);
    end;
    ek_clientmouseenter: begin
     updatecursorshape(true);
     clientmouseevent(info);
    end;
    ek_buttonpress: begin
     if button = mb_left then begin
      include(fwidgetstate,ws_clicked);
     end;
     app.capturemouse(self,true);
     if isclientmouseevent(info) then begin
      include(fwidgetstate,ws_clientmousecaptured);
      clientmouseevent(info);
      clientoffset:= getclientoffset;
     end;
     if not ({es_processed}es_nofocus in info.eventstate) and not focused and
                      (ws_wantmousefocus in fwidgetstate)and
       (ow_mousefocus in foptionswidget) and canfocus then begin
      setfocus;
     end;
    end;
    ek_buttonrelease: begin
     if isclientmouseevent(info) then begin
      clientmouseevent(info);
      clientoffset:= getclientoffset;
     end;
    end;
   end;
   addpoint1(pos,clientoffset);
  end;
  if eventkind = ek_buttonrelease then begin
   if button = mb_left then begin
    exclude(fwidgetstate,ws_clicked);
   end;
   if (app <> nil) and ((shiftstate - mousebuttontoshiftstate(button)) *
                            mousebuttons = []) and
                           (app.fmousecapturewidget = self) then begin
    if not (ws_mousecaptured in fwidgetstate) then begin
     app.capturemouse(nil,false);
    end
    else begin
     fwidgetstate:= fwidgetstate - [ws_clientmousecaptured];
     app.ungrabpointer;
    end;
   end;
  end;
 end;
end;

procedure twidget.setclientclick;
begin
 app.capturemouse(self,true);
 fwidgetstate:= fwidgetstate + [ws_clicked,ws_clientmousecaptured];
end;

procedure twidget.clientmouseevent(var info: mouseeventinfoty);
begin
 //dummy
end;

procedure twidget.childmouseevent(const sender: twidget;
                    var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  if fparentwidget <> nil then begin
   fparentwidget.childmouseevent(sender,info);
  end;
 end;
end;

function twidget.clientpos: pointty;
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result:= fclientrect.pos;
  end
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.getclientsize: sizety;
begin
 if fframe <> nil then begin
  with fframe do begin
   checkstate;
   result:= fclientrect.size;
  end;
 end
 else begin
  result:= fwidgetrect.size;
 end;
end;

procedure twidget.changeclientsize(const delta: sizety); //asynchronouse
begin
 application.postevent(tresizeevent.create(ievent(self),delta));
end;

procedure twidget.setclientsize(const asize: sizety);
begin
// include(fwidgetstate1,ws1_clientsizing);
 size:= addsize(asize,clientframewidth);
// exclude(fwidgetstate1,ws1_clientsizing);
end;

function twidget.getclientwidth: integer;
begin
 result:= getclientsize.cx;
end;

procedure twidget.setclientwidth(const avalue: integer);
begin
 setclientsize(makesize(avalue,getclientsize.cy));
end;

function twidget.getclientheight: integer;
begin
 result:= getclientsize.cy;
end;

procedure twidget.setclientheight(const avalue: integer);
begin
 setclientsize(makesize(getclientsize.cx,avalue));
end;

function twidget.clientwidgetpos: pointty;
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result:= addpoint(fpaintrect.pos,fclientrect.pos);
  end
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.innerclientwidgetpos: pointty;   //origin = pos
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result:= addpoint(fpaintrect.pos,fframe.finnerclientrect.pos);
  end;
 end
 else begin
  result:= nullpoint;
 end;
end;

function twidget.clientparentpos: pointty;
        //origin = parentwidget.pos
begin
 result:= addpoint(fwidgetrect.pos,clientwidgetpos);
end;

function twidget.paintparentpos: pointty;       //origin = parentwidget.pos
begin
 result:= addpoint(fwidgetrect.pos,paintpos);
end;

function twidget.getparentclientpos: pointty;   //origin = parentwidget.clientpos
begin
 result:= fwidgetrect.pos;
 if fparentwidget <> nil then begin
  subpoint1(result,fparentwidget.clientwidgetpos);
 end;
end;

procedure twidget.setparentclientpos(const avalue: pointty);
begin
 if fparentwidget <> nil then begin
  pos:= addpoint(avalue,fparentwidget.clientwidgetpos);
 end
 else begin
  pos:= avalue;
 end;
end;

function twidget.checkdescendent(widget: twidget): boolean;
begin
 result:= false;
 while widget <> nil do begin
  if widget = self then begin
   result:= true;
   break;
  end;
  widget:= widget.fparentwidget;
 end;
end;

function twidget.checkancestor(widget: twidget): boolean;
                  //true if widget is ancestor or self
var
 widget1: twidget;
begin
 result:= false;
 if widget <> nil then begin
  widget1:= self;
  while widget1 <> nil do begin
   if widget1 = widget then begin
    result:= true;
    break;
   end;
   widget1:= widget1.fparentwidget;
  end;
 end;
end;

function twidget.canfocus: boolean;
begin
 result:= (fwidgetstate * focusstates = focusstates) and
                (componentstate*[csdesigning,csdestroying] = []) and
                ((fparentwidget = nil) or fparentwidget.canfocus);
end;

function twidget.checksubfocus(const aactivate: boolean): boolean;
var
 widget1: twidget;
begin
 result:= false;
 if (ow_subfocus in foptionswidget) then begin
  widget1:= ffocusedchild;
  if widget1 = nil then begin
   widget1:= ffocusedchildbefore;
  end;
  if (widget1 = nil) or (not widget1.canfocus) then begin
   widget1:= defaultfocuschild;
  end;
  if widget1 <> nil then begin
   widget1.setfocus(aactivate);
   result:= checkdescendent(window.ffocusedwidget);
  end;
 end;
end;

function twidget.setfocus(aactivate: boolean = true): boolean;
begin
 if not canfocus  then begin
  guierror(gue_cannotfocus,self);
 end;
 result:= checksubfocus(aactivate);
 if not result then begin
  window.setfocusedwidget(self);
    //call updaterootwidget
  if aactivate then begin
//   if window.canactivate then begin
    window.activate;
//   end
//   else begin
//    app.postevent(tobjectevent.create(ek_activate,ievent(self)));
//   end;
  end;
  result:= window.ffocusedwidget = self;
 end;
end;

function twidget.cantabfocus: boolean;
begin
 result:= (ow_tabfocus in foptionswidget) and
           (fwidgetstate * focusstates = focusstates);
end;

function twidget.firsttabfocus: twidget;
var
 ar1: widgetarty;
 int1: integer;
begin
 result:= nil;
 ar1:= gettaborderedwidgets;
 for int1:= 0 to high(ar1) do begin
  if ar1[int1].cantabfocus then begin
   result:= ar1[int1];
   break;
  end;
 end;
end;

function twidget.lasttabfocus: twidget;
var
 ar1: widgetarty;
 int1: integer;
begin
 result:= nil;
 ar1:= gettaborderedwidgets;
 for int1:= high(ar1) downto 0 do begin
  if ar1[int1].cantabfocus then begin
   result:= ar1[int1];
   break;
  end;
 end;
end;

function twidget.findtabfocus(const ataborder: integer): twidget;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fwidgets) do begin
  if (fwidgets[int1].ftaborder = ataborder) then begin
   if fwidgets[int1].cantabfocus then begin
    result:= fwidgets[int1];
   end;
   break;
  end;
 end;
end;

function twidget.nexttaborder(const down: boolean = false): twidget;
label
 doreturn;
var
 int1: integer;
begin
 result:= nil;
 if fparentwidget <> nil then begin
  int1:= ftaborder;
  if down then begin
   repeat
    dec(int1);
    with fparentwidget do begin
     if int1 < 0 then begin
      if (ow_parenttabfocus in foptionswidget) and 
                         (fparentwidget <> nil) then begin
       result:= nexttaborder(down);
       if result <> nil then begin
        goto doreturn;
       end;
      end;
      int1:= high(fwidgets);
     end;
     result:= findtabfocus(int1);
    end;
   until (result <> nil) or (int1 = ftaborder);
  end
  else begin
   repeat
    inc(int1);
    with fparentwidget do begin
     if int1 >= widgetcount then begin
      if (ow_parenttabfocus in foptionswidget) and 
                         (fparentwidget <> nil) then begin
       result:= nexttaborder(down);
       if result <> nil then begin
        goto doreturn;
       end;
      end;
      int1:= 0;
     end;
     result:= findtabfocus(int1);
    end;
   until (result <> nil) or (int1 = ftaborder);
  end;
 end;

doreturn:
 if (result <> nil) and (ow_parenttabfocus in result.foptionswidget) then begin
  if down then begin
   result:= result.container.lasttabfocus;
  end
  else begin
   result:= result.container.firsttabfocus;
  end;
 end;
end;

procedure twidget.doenter;
begin
 //dummy
end;

procedure twidget.internaldoenter;
begin
 if not (ws_entered in fwidgetstate) then begin
  if fparentwidget <> nil then begin
   with fparentwidget do begin
//    if ffocusedchildbefore <> self then begin
     ffocusedchildbefore:= ffocusedchild;
//    end;
    ffocusedchild:= self;
   end;
  end;
  include(fwidgetstate,ws_entered);
  doenter;
  if needsfocuspaint then begin
   invalidatewidget;
  end;
 end;
end;

procedure twidget.doexit;
begin
 //dummy
end;

procedure twidget.internaldoexit;
begin
 if ws_entered in fwidgetstate then begin
  ffocusedchildbefore:= ffocusedchild;
  ffocusedchild:= nil;
  exclude(fwidgetstate,ws_entered);
  doexit;
  if needsfocuspaint then begin
   invalidatewidget;
  end;
 end;
end;

procedure twidget.dofocus;
begin
 //dummy
end;

procedure twidget.internaldofocus;
begin
 if not (ws_focused in fwidgetstate) then begin
  include(fwidgetstate,ws_focused);
  dofocus;
  if fparentwidget <> nil then begin
   fparentwidget.dochildfocused(self);
  end;
 end;
end;

procedure twidget.dodefocus;
begin
 //dummy
end;

procedure twidget.dochildfocused(const sender: twidget);
begin
 //dummy
end;

procedure twidget.internaldodefocus;
begin
 if ws_focused in fwidgetstate then begin
  exclude(fwidgetstate,ws_focused);
  dodefocus;
 end;
end;

function twidget.focusback(const aactivate: boolean = true): boolean;
begin
 if fparentwidget <> nil then begin
  with fparentwidget do begin
   if (ffocusedchildbefore <> nil) and (ffocusedchildbefore <> self) and 
                 (ffocusedchildbefore.canfocus) then begin
    ffocusedchildbefore.setfocus(aactivate);
    result:= true;
   end
   else begin
    result:= focusback(aactivate);
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

procedure twidget.internaldoactivate;
begin
 if not (ws_active in fwidgetstate) then begin
  include(fwidgetstate,ws_active);
  doactivate;
 end;
end;

procedure twidget.internaldodeactivate;
begin
 if ws_active in fwidgetstate then begin
  exclude(fwidgetstate,ws_active);
  dodeactivate;
 end;
end;

procedure twidget.dohide;
var
 int1: integer;
begin
 visiblechanged;
 if app.fmousecapturewidget = self then begin
  releasemouse;
 end;
 if app.fmousewidget = self then begin
  app.setmousewidget(nil);
 end;
 {
 if (window.focusedwidget = self) and 
       (fparentwidget <> nil) and fparentwidget.visible then begin
//       (fwindow.visible or not (ws_visible in fwidgetstate)) then begin
  nextfocus;
 end;
 }
 for int1:= 0 to high(fwidgets) do begin
  with fwidgets[int1] do begin
   if ws_visible in fwidgetstate then begin
    dohide;
   end;
  end;
 end;
end;

procedure twidget.internalhide(const windowevent: boolean);
var
 bo1: boolean;
begin
 bo1:= ws_visible in fwidgetstate;
 if showing then begin
  exclude(fwidgetstate,ws_visible);
  dohide;
 end
 else begin
  exclude(fwidgetstate,ws_visible);
  updateopaque(false);
 end;
 if bo1 then begin
  if fparentwidget <> nil then begin
   fparentwidget.widgetregionchanged(self);
  end;
  if ownswindow1 then begin
   fwindow.hide(windowevent);
  end;
  if (fwindow <> nil) and checkdescendent(fwindow.focusedwidget) then begin
   nextfocus;
  end;
 end;
end;

procedure twidget.hide;
begin
 internalhide(false);
end;

procedure twidget.doshow;
var
 int1: integer;
begin
 visiblechanged;
 for int1:= 0 to widgetcount - 1 do begin
  with widgets[int1] do begin
   if fwidgetstate * [ws_visible,ws_showproc] = [ws_visible] then begin
    doshow;
   end;
  end;
 end;
end;

function twidget.internalshow(const modal: boolean; transientfor: twindow;
             const windowevent: boolean): modalresultty;
var
 bo1: boolean;
begin
 bo1:= not showing;
 updateroot; //create window
 if fparentwidget <> nil then begin
  if not (csdesigning in componentstate) then begin
   include(fwidgetstate,ws_showproc);
   try
    fparentwidget.show;
   finally
    exclude(fwidgetstate,ws_showproc);
   end;
  end;
 end;
 include(fwidgetstate,ws_visible);
 if bo1 then begin
  updateopaque(false);
  if fparentwidget <> nil then begin
   fparentwidget.widgetregionchanged(self);
  end;
 end;
 if ownswindow1 then begin
  if modal and (transientfor = nil) then begin
   if app.fmodalwindow = nil then begin
    if app.fwantedactivewindow <> nil then begin
     transientfor:= app.fwantedactivewindow;
    end
    else begin
     {$ifndef mswindows}  //on win32 winid wil be destroyed on destroying transientfor
      //todo: no ifndef
     transientfor:= app.factivewindow;
     {$endif}
    end;
   end
   else begin
    transientfor:= app.fmodalwindow;
   end;
  end;
  if transientfor = window then begin
   transientfor:= nil;
   end;
  fwindow.show(windowevent);
  fwindow.settransientfor(transientfor,windowevent);
  if bo1 then begin
   doshow;
  end;
  if modal then begin
   if window.beginmodal then begin
    result:= mr_windowdestroyed;
    exit;
   end;
  end;
 end
 else begin
  if bo1 then begin
   doshow;
  end;
 end;
 if fwindow <> nil then begin
  result:= fwindow.fmodalresult;
 end
 else begin
  result:= mr_none;
 end;
end;

function twidget.show(const modal: boolean = false;
              const transientfor: twindow = nil): modalresultty;
begin
 result:= internalshow(modal,transientfor,false);
end;

procedure twidget.clampinview(const arect: rectty; const bottomright: boolean);
begin
 //dummy
end;

procedure twidget.doactivate;
var
 rect1: rectty;
begin
 if fparentwidget <> nil then begin
  rect1:= getdisprect;
  if rect1.x < 0 then begin
   rect1.cx:= rect1.cx + rect1.x;
   rect1.x:= 0;
  end;
  if rect1.x + rect1.cx > fwidgetrect.cx then begin
   rect1.cx:= fwidgetrect.cx - rect1.x;
  end;
  if rect1.y < 0 then begin
   rect1.cy:= rect1.cy + rect1.y;
   rect1.y:= 0;
  end;
  if rect1.y + rect1.cy > fwidgetrect.cy then begin
   rect1.cy:= fwidgetrect.cy - rect1.y;
  end;
  addpoint1(rect1.pos,fwidgetrect.pos);
  subpoint1(rect1.pos,fparentwidget.paintpos);
  fparentwidget.clampinview(rect1,false);
 end;
 activechanged;
end;

procedure twidget.dodeactivate;
begin
 activechanged;
end;

function twidget.navigdistance(var info: naviginfoty): integer;
const
 dirweightings = 20;
 dirweightingg = 30;
var
 rect1,rect2: rectty;
 dist: integer;
 widget1: twidget;
 dwp,dwm: integer;
 int1: integer;
begin
 with info do begin
  rect1:= navigrect;
  rect2:= startingrect;
  translateclientpoint1(rect2.pos,nil,self);
  if direction in [gd_right,gd_down] then begin
   dwp:= dirweightings;
   dwm:= -dirweightingg;
  end
  else begin
   dwp:= dirweightingg;
   dwm:= -dirweightings;
  end;
  if direction in [gd_right,gd_left] then begin
   if (rect2.y >= rect1.y) and (rect2.y < rect1.y + rect1.cy) or
        (rect1.y >= rect2.y) and (rect1.y < rect2.y + rect2.cy) then begin
    result:= 0;
   end
   else begin
    result:= rect1.y + rect1.cy div 2 - (rect2.y + rect2.cy div 2);
   end;
   dist:= (rect1.x + rect1.cx div 2) - (rect2.x + rect2.cx div 2);
  end
  else begin
   if (rect2.x >= rect1.x) and (rect2.x < rect1.x + rect1.cx) or
        (rect1.x >= rect2.x) and (rect1.x < rect2.x + rect2.cx) then begin
    result:= 0;
   end
   else begin
    result:= rect1.x + rect1.cx div 2 - (rect2.x + rect2.cx div 2);
   end;
   dist:= (rect1.y + rect1.cy div 2) - (rect2.y + rect2.cy div 2);
  end;
  if result < 0 then begin
   result:= result * dwm;
  end
  else begin
   result:= result * dwp;
  end;
  if direction in [gd_left,gd_up] then begin
   dist:= -dist;
  end;
  if dist < 0 then begin
   widget1:= sender.fparentwidget;
   while (ow_arrowfocusout in widget1.foptionswidget) and 
                        (widget1.fparentwidget <> nil) do begin
    widget1:= widget1.fparentwidget;
   end;
   if widget1 <> nil then begin
    with widget1 do begin
     if direction in [gd_right,gd_left] then begin
      dist:= dist + clientwidth + framewidth.cx;
     end
     else begin
      dist:= dist + clientheight + framewidth.cy;
     end;
    end;
   end;
  end;
  if dist < 0 then begin
   dist:= bigint div 2;
  end;
  result:= result + dist;
 end;
end;

function twidget.navigrect: rectty;        //org = clientpos
begin
 result:= clientrect;
end;

function twidget.navigstartrect: rectty;        //org = clientpos
begin
 result:= navigrect;
end;

procedure twidget.navigrequest(var info: naviginfoty);
var
 int1,int2: integer;
 widget1,widget2: twidget;
begin
 with info do begin
  if not down and (ow_arrowfocusout in foptionswidget) and (fparentwidget <> nil) then begin
   widget1:= sender;
   sender:= self;
   fparentwidget.navigrequest(info);
   sender:= widget1;
  end;
  down:= true;
  for int1:= 0 to widgetcount - 1 do begin
   widget1:= twidget(fwidgets[int1]);
   if (widget1 <> info.sender) and (ow_arrowfocus in widget1.foptionswidget)
         and widget1.canfocus then begin
    widget2:= nearest;
    if ow_arrowfocusin in widget1.foptionswidget then begin
     widget1.navigrequest(info);
    end;
    if nearest = widget2 then begin
     int2:= widget1.navigdistance(info);
     if int2 < distance then begin
      nearest:= widget1;
      distance:= int2;
     end;
    end;
   end;
  end;
 end;
end;

procedure twidget.dokeydown(var info: keyeventinfoty);
var
 bo1: boolean;
begin
 if fframe <> nil then begin
  fframe.dokeydown(info);
 end;
 with info do begin
  if not (es_processed in eventstate) then begin
   if (key = key_escape) and (shiftstate = []) and
    (ow_focusbackonesc in foptionswidget) then begin
    if focusback then begin
     include(eventstate,es_processed);
    end;
   end;
   if not (es_processed in eventstate) then  begin
    if (fparentwidget <> nil) then begin
     bo1:= es_child in eventstate;
     include(eventstate,es_child);
     fparentwidget.dokeydown(info);
     if not bo1 then begin
      exclude(eventstate,es_child);
     end;
    end;
   end;
  end;
 end;
end;

procedure twidget.dokeydownaftershortcut(var info: keyeventinfoty);
var
 naviginfo: naviginfoty;
 widget1: twidget;
 bo1: boolean;
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   if (shiftstate = []) or
        (shiftstate = [ss_shift]) and (key = key_backtab) then begin
    include(eventstate,es_processed);
    with naviginfo do begin
     direction:= gd_none;
     case info.key of
      key_tab,key_backtab: begin
       widget1:= nexttaborder(key = key_backtab);
       if widget1 <> nil then begin
        widget1.setfocus;
       end;
      end;
      key_right: direction:= gd_right;
      key_up: direction:= gd_up;
      key_left: direction:= gd_left;
      key_down: direction:= gd_down;
      else begin
       exclude(info.eventstate,es_processed);
      end;
     end;
     if direction <> gd_none then begin
      if fparentwidget <> nil then begin
       distance:= bigint;
       nearest:= nil;
       sender:= self;
       down:= false;
       startingrect:= navigstartrect;
       translateclientpoint1(startingrect.pos,self,nil);
       fparentwidget.navigrequest(naviginfo);
       if nearest <> nil then begin
        nearest.setfocus;
       end;
      end;
     end;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) and (fparentwidget <> nil) then begin
   bo1:= es_child in eventstate;
   include(eventstate,es_child);
   fparentwidget.dokeydownaftershortcut(info);
   if not bo1 then begin
    exclude(eventstate,es_child);
   end;
  end;
 end;
end;

procedure twidget.internalkeydown(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  dokeydown(info);
 end;
 if not (es_processed in info.eventstate) then begin
  doshortcut(info,self);
 end;
 if not (es_processed in info.eventstate) then begin
  dokeydownaftershortcut(info);
 end;
end;

procedure twidget.dokeyup(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) and (fparentwidget <> nil) then begin
  fparentwidget.dokeyup(info);
 end;
end;

procedure twidget.dochildscaled(const sender: twidget);
begin
 if fparentwidget <> nil then begin
  fparentwidget.dochildscaled(sender);
 end;
end;

procedure twidget.setcursor(const Value: cursorshapety);
begin
 if fcursor <> value then begin
  fcursor := Value;
  updatecursorshape;
 end;
end;

function twidget.containswidget(awidget: twidget): boolean;
var
 int1: integer;
begin
 result:= false;
 if awidget <> nil then begin
  for int1:= 0 to widgetcount-1 do begin
   if twidget(fwidgets[int1]) = awidget then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

function twidget.isclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
begin
 with info do begin
  result:= (ws_clicked in fwidgetstate) and (eventkind = ek_buttonrelease) and
              (button = mb_left) and pointinrect(pos,clientrect);
 end;
end;

function twidget.isdblclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonpress, button is mb_left, pos in clientrect
   // and timedlay to last buttonpress is short
begin
 with info do begin
  result:= (button = mb_left) and pointinrect(pos,clientrect) and
       (eventkind = ek_buttonpress) and (ss_double in shiftstate) and 
        (app.fbuttonpresswidgetbefore = self);
 end;
end;

function twidget.isdblclicked(const info: mouseeventinfoty): boolean;
   //true if eventtype in [et_buttonpress,et_butonrelease], button is mb_left,
   // and timedlay to last same buttonevent is short
begin
 with info do begin
  result:= (button = mb_left) and (ss_double in shiftstate) and 
    ((eventkind = ek_buttonpress) and (app.fbuttonpresswidgetbefore = self) or
     (eventkind = ek_buttonrelease) and (app.fbuttonreleasewidgetbefore = self));
 end;
end;

function twidget.isleftbuttondown(const info: mouseeventinfoty): boolean;
begin
 with info do begin
  result:= (eventkind = ek_buttonpress) and
              (button = mb_left) and pointinrect(pos,clientrect);
 end;
end;

function twidget.iswidgetclick(const info: mouseeventinfoty;
                     caption: boolean = false): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
   //or in frame.caption if caption = true
begin
 with info do begin
  result:= (button = mb_left) and (ws_clicked in fwidgetstate) and
           (eventkind = ek_buttonrelease) and
      (pointinrect(pos,paintrect) or
           caption and (fframe <> nil) and fframe.pointincaption(info.pos));
 end;
end;

function twidget.getrootwidgetpath: widgetarty;
var
 count: integer;
 widget: twidget;
begin
 result:= nil;
 count:= 0;
 widget:= self;
 while widget <> nil do begin
  if length(result) <= count then begin
   setlength(result,length(result)+32);
  end;
  result[count]:= widget;
  inc(count);
  widget:= widget.fparentwidget;
 end;
 setlength(result,count);
end;

function twidget.checkfocusshortcut(var info: keyeventinfoty): boolean;
begin
 if (fframe <> nil) then begin
  result:= fframe.checkshortcut(info) and canfocus;
 end
 else begin
  result:= false;
 end;
end;

procedure twidget.doshortcut(var info: keyeventinfoty; const sender: twidget);
                 //sender = nil -> broadcast top down
var
 int1,int2: integer;
begin
 if not (es_processed in info.eventstate) then begin
  if (sender <> nil) and (sender.fparentwidget = self) then begin
     //neighbors first
   int2:= IndexOfwidget(sender);
   for int1:= int2 + 1 to widgetcount - 1 do begin
    widgets[int1].doshortcut(info,nil);
    if es_processed in info.eventstate then begin
     break;
    end;
   end;
   if not (es_processed in info.eventstate) then begin
    for int1:= 0 to int2 - 1 do begin
     widgets[int1].doshortcut(info,nil);
     if es_processed in info.eventstate then begin
      break;
     end;
    end;
   end;
  end
  else begin
     //children
   for int1:= 0 to widgetcount - 1 do begin
    widgets[int1].doshortcut(info,nil);
    if (es_processed in info.eventstate) then begin
     break;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) and (sender <> nil) then begin
    //parent
   if fparentwidget <> nil then begin
    fparentwidget.doshortcut(info,sender);
   end
   else begin
    window.doshortcut(info,sender)
   end;
  end;
  if not (es_processed in info.eventstate) and canfocus and checkfocusshortcut(info)then begin
   setfocus;
   include(info.eventstate,es_processed);
  end;
 end;
end;

function twidget.showing: boolean;
begin
 result:= isvisible and
  (
   (fparentwidget = nil) and ((fwindow <> nil) and (tws_windowvisible in fwindow.fstate)) or
   (fparentwidget <> nil) and fparentwidget.showing
  );
end;

function twidget.isenabled: boolean;
begin
 result:= enabled and ((fparentwidget = nil) or fparentwidget.isenabled);
end;

function twidget.active: boolean;
begin
 result:= ws_active in fwidgetstate;
end;

function twidget.entered: boolean;
begin
 result:= ws_entered in fwidgetstate;
end;

function twidget.focused: boolean;
begin
 result:= ws_focused in fwidgetstate;
end;

function twidget.clicked: boolean;
begin
 result:= ws_clicked in fwidgetstate;
end;

function twidget.isvisible: boolean;
begin
 result:= (ws_visible in fwidgetstate) or
  ((csdesigning in componentstate) and not (ws_nodesignvisible in fwidgetstate));
end;

function twidget.parentisvisible: boolean; //checks visible flags of ancestors
var
 widget1: twidget;
begin
 result:= true;
 widget1:= fparentwidget;
 while widget1 <> nil do begin
  if not widget1.isvisible then begin
   result:= false;
   break;
  end;
  widget1:= widget1.fparentwidget;
 end;
end;

function twidget.parentvisible: boolean; //checks visible flags of ancestors
var
 widget1: twidget;
begin
 result:= true;
 widget1:= fparentwidget;
 while widget1 <> nil do begin
  if not (ws_visible in widget1.fwidgetstate) then begin
   result:= false;
   break;
  end;
  widget1:= widget1.fparentwidget;
 end;
end;

function twidget.getvisible: boolean;
begin
 result:= ws_visible in fwidgetstate;
end;

procedure twidget.setvisible(const Value: boolean);
begin
 if not (csloading in componentstate) and (value <> getvisible) then begin
  if value then begin
   if parentisvisible then begin
    show;
   end
   else begin
    include(fwidgetstate,ws_visible);
   end;
  end
  else begin
   hide;
  end;
 end
 else begin
  if value then begin
   include(fwidgetstate,ws_visible);
  end
  else begin
   exclude(fwidgetstate,ws_visible);
  end;
 end;
end;

function twidget.getenabled: boolean;
begin
 result:= ws_enabled in fwidgetstate;
end;

procedure twidget.setenabled(const Value: boolean);
begin
 if value <> getenabled then begin
  if value then begin
   include(fwidgetstate,ws_enabled);
  end
  else begin
   exclude(fwidgetstate,ws_enabled);
   if window.focusedwidget = self then begin
    nextfocus;
   end;
  end;
  if not (csloading in componentstate) then begin
   enabledchanged;
  end;
 end;
end;

function twidget.actualcolor: colorty;
begin
 if (fcolor <> cl_parent) and (fcolor <> cl_default) then begin
  result:= fcolor;
 end
 else begin
  if fparentwidget <> nil then begin
   result:= fparentwidget.actualcolor;
  end
  else begin
   result:= cl_background;
  end;
 end;
end;

function twidget.parentcolor: colorty;
begin
 if (fcolor <> cl_parent) and (fcolor <> cl_default) then begin
  result:= fcolor;
 end
 else begin
  if fparentwidget <> nil then begin
   result:= fparentwidget.parentcolor;
  end
  else begin
   result:= cl_background;
  end;
 end;
end;

function twidget.translatecolor(const acolor: colorty): colorty;
begin
 if acolor = cl_default then begin
  result:= actualcolor;
 end
 else begin
  if acolor = cl_parent then begin
   result:= parentcolor;
  end
  else begin
   result:= acolor;
  end;
 end;
end;

function twidget.getsize: sizety;
begin
 result:= fwidgetrect.size;
end;

function twidget.clipcaret: rectty;
             //origin = pos
var
 widget1: twidget;
 po1: pointty;
begin
 result:= moverect(getcaretcliprect,clientwidgetpos);
 widget1:= self;
 po1:= nullpoint;
 while widget1 <> nil do begin
  msegraphutils.intersectrect(result,removerect(widget1.paintrect,po1),result);
  addpoint1(po1,widget1.fwidgetrect.pos);
  widget1:= widget1.fparentwidget;
 end;
end;

procedure twidget.reclipcaret;
begin
 if hascaret then begin
  with app,fcaret,fcaretwidget do begin
   cliprect:= moverect(clipcaret,subpoint(fcaretwidget.frootpos,origin));
  end;
 end;
end;

function twidget.hascaret: boolean;
begin
 result:= (app <> nil) and checkdescendent(app.fcaretwidget)
end;

procedure twidget.getcaret;
begin
 if (app <> nil) then begin
  app.caret.link(window.fcanvas,addpoint(frootpos,clientwidgetpos),
                 removerect(clipcaret,clientwidgetpos));
  app.fcaretwidget:= self;
 end;
end;
                     
procedure twidget.capturemouse(grab: boolean = true);
begin
 if app <> nil then begin
  app.capturemouse(self,grab);
  include(fwidgetstate,ws_mousecaptured);
 end;
end;

procedure twidget.releasemouse;
begin
 if (app <> nil) and (app.fmousecapturewidget = self) then begin
  app.capturemouse(nil,false);
  exclude(fwidgetstate,ws_mousecaptured);
 end;
end;
{
procedure twidget.mousecaptureend;
begin
 fwidgetstate:= fwidgetstate -
          [ws_clicked,ws_mousecaptured,ws_clientmousecaptured];
end;
}
procedure twidget.dragevent(var info: draginfoty);
var
 po1: pointty;
begin
 if fparentwidget <> nil then begin
  po1:= subpoint(clientparentpos,fparentwidget.clientwidgetpos);
  addpoint1(info.pos,po1);
//  addpoint1(info.pos,clientparentpos);
  fparentwidget.dragevent(info);
//  subpoint1(info.pos,clientparentpos);
  subpoint1(info.pos,po1);
 end;
end;

procedure twidget.doscroll(const dist: pointty);
begin
 //dummy
end;

procedure twidget.scrollwidgets(const dist: pointty);
var
 int1: integer;
 widget1: twidget;
begin
 if (dist.x <> 0) or (dist.y <> 0) then begin
  for int1:= 0 to widgetcount - 1 do begin
   widget1:= fwidgets[int1];
   with widget1 do begin
    addpoint1(fwidgetrect.pos,dist);
    addpoint1(frootpos,dist);
    rootchanged;
   end;
   if app.fcaretwidget = widget1 then begin
    widget1.reclipcaret;
   end;
  end;
  widgetregioninvalid;
 end;
end;

procedure twidget.scrollcaret(const dist: pointty);
begin
 if hascaret then begin
  tcaret1(app.fcaret).scroll(dist,app.fcaretwidget <> self);
  reclipcaret;
 end;
end;

procedure twidget.scrollrect(const dist: pointty; const rect: rectty;
                scrollcaret: boolean);
           //origin = paintrect.pos
var
 rect1,rect2: rectty;
 ahascaret: boolean;

 procedure doinvalidate;
 begin
  fwindow.invalidaterect(intersectrect(rect1,rect2));
 end;

begin
 if (dist.x = 0) and (dist.y = 0) or not showing then begin
  exit;
 end;
 if (fwindow <> nil) {and canpaint} then begin
  ahascaret:= hascaret;
  if ahascaret then begin
   tcaret1(app.fcaret).remove;
  end;
  if (ow_noscroll in foptionswidget) or (tws_painting in fwindow.fstate) then begin
   invalidaterect(rect);
  end
  else begin
   update;
   rect1:= rect;
   if fframe <> nil then begin
    inc(rect1.x,fframe.fpaintrect.x);
    inc(rect1.y,fframe.fpaintrect.y); //widget origin
   end;
   msegraphutils.intersectrect(rect1,clipedpaintrect,rect1);
   rect2:= rect1; //backup for invalidate
   addpoint1(rect2.pos,frootpos);
   msegraphutils.intersectrect(rect1,removerect(rect1,dist),rect1);
   addpoint1(rect1.pos,frootpos);
   fwindow.movewindowrect(dist,rect1);
   rect1.y:= rect2.y;
   rect1.cy:= rect2.cy;
   if dist.x < 0 then begin
    rect1.cx:= -dist.x;
    rect1.x:= rect2.x + rect2.cx - rect1.cx;
    doinvalidate;
   end
   else begin
    if dist.x > 0 then begin
     rect1.x:= rect2.x;
     rect1.cx:= dist.x;
     doinvalidate;
    end;
   end;
   rect1.x:= rect2.x;
   rect1.cx:= rect2.cx;
   if dist.y < 0 then begin
    rect1.cy:= -dist.y;
    rect1.y:= rect2.y + rect2.cy - rect1.cy;
    doinvalidate;
   end
   else begin
    if dist.y > 0 then begin
     rect1.y:= rect2.y;
     rect1.cy:= dist.y;
     doinvalidate;
    end;
   end;
  end;
  if ahascaret then begin
   if scrollcaret then begin
    tcaret1(app.fcaret).scroll(dist,app.fcaretwidget <> self);
    reclipcaret;
   end;
   tcaret1(app.fcaret).restore;
  end;
  if (app.factmousewindow = fwindow) then begin
   with app.fmouseparkeventinfo do begin
    if pointinrect(pos,
         makerect(addpoint(addpoint(rootpos,paintpos),rect.pos),rect.size)) then begin
          //replay last mousepos
     app.feventlist.insert(0,tmouseevent.create(fwindow.winid,false,
                    mb_none,pos,shiftstate,0));
    end;
   end;
  end;
 end;
end;

procedure twidget.scroll(const dist: pointty);
var
 rect1: rectty;
begin
 if (dist.x = 0) and (dist.y = 0) then begin
  exit;
 end;
 doscroll(dist);
 rect1.pos:= nullpoint;
 if fframe <> nil then begin
  rect1.size:= fframe.fpaintrect.size;
 end
 else begin
  rect1.size:= fwidgetrect.size;
 end;
 scrollrect(dist,rect1,true);
 scrollwidgets(dist);
end;

procedure twidget.update;
begin
 window.update;
end;

procedure twidget.settaborder(const Value: integer);
begin
 if ftaborder <> value then begin
  ftaborder := Value;
  if (fparentwidget <> nil) then begin
   fparentwidget.updatetaborder(self);
  end;
 end;
end;

function comparetaborder(const l,r): Integer;
begin
 result:= twidget(l).ftaborder - twidget(r).ftaborder;
end;

function twidget.gettaborderedwidgets: widgetarty;
begin
 result:= copy(fwidgets);
 sortarray(pointerarty(result),{$ifdef FPC}@{$endif}comparetaborder);
end;

procedure twidget.updatetaborder(awidget: twidget);
var
 int1: integer;
 sortlist: widgetarty;

begin
 sortlist:= nil; //compiler warning
 if not (csloading in componentstate) and not (ws_loadlock in fwidgetstate) and
       not (ws_destroying in fwidgetstate) then begin
  if awidget <> nil then begin
   for int1:= 0 to widgetcount - 1 do begin
    if twidget(fwidgets[int1]) <> awidget then begin
     with twidget(fwidgets[int1]) do begin
      if ftaborder >= awidget.ftaborder then begin
       inc(ftaborder);
      end;
     end;
    end;
   end;
  end;
  sortlist:= gettaborderedwidgets;

  for int1:= 0 to high(sortlist) do begin
   twidget(sortlist[int1]).ftaborder:= int1;
  end;
 end;
end;

function twidget.getparentcomponent: tcomponent;
begin
 if (fparentwidget <> nil) and (csdesigning in componentstate) and 
         not(csdesigning in fparentwidget.componentstate) then begin
  result:= nil; //parentwidget is designer
 end
 else begin
  result:= fparentwidget;
 end;
end;

function twidget.hasparent: boolean;
begin
 result:= fparentwidget <> nil;
end;

procedure twidget.setparentcomponent(value: tcomponent);
begin
 if value is twidget then begin
  twidget(value).insertwidget(self,fwidgetrect.pos);
//  parentwidget:= twidget(value);
 end;
end;

procedure twidget.getchildren(proc: tgetchildproc; root: tcomponent);
var
  int1: integer;
  widget: twidget;
begin
 for int1:= 0 to widgetcount - 1 do begin
  widget:= fwidgets[int1];
  if ((widget.owner = root) or (csinline in root.componentstate) and
      not (csancestor in widget.componentstate) and
       issubcomponent(widget.owner,root)) and (ws_iswidget in widget.fwidgetstate) then begin
   proc(widget);
  end;
 end;
end;

function twidget.getcanvas(aorigin: originty = org_client): tcanvas;
begin
 result:= window.fasynccanvas;
 with result do begin
  if active then begin
   reset;
   save;
  end;
  font:= getfont;
  origin:= frootpos;
  case aorigin of
   org_widget,org_screen: begin
    clipregion:= createregion(makerect(nullpoint,fwidgetrect.size));
    if aorigin = org_screen then begin
     remove(screenpos);
    end;
   end
   else begin //org_client,org_inner
    clipregion:= createregion(paintrect);
    if aorigin = org_client then begin
     move(clientwidgetpos);
    end
    else begin
     move(innerclientwidgetpos);
    end;
   end;
  end;
 end;
end;

procedure twidget.updatewindowinfo(var info: windowinfoty);
begin
 //dummy
end;

procedure twidget.windowcreated;
begin
 //dummy
end;

procedure twidget.setfontheight;
begin
 if not (csloading in componentstate) then begin
  if ow_fontglyphheight in foptionswidget then begin
   ffontheight:= getfont.glyphheight;
  end;
  if ow_fontlineheight in foptionswidget then begin
   ffontheight:= getfont.lineheight;
  end;
 end;
end;

procedure twidget.setoptionswidget(const avalue: optionswidgetty);
const
 mask1: optionswidgetty = [ow_fontglyphheight,ow_fontlineheight];
var
 value,delta: optionswidgetty;
begin
 if avalue <> foptionswidget then begin
  value:= optionswidgetty(setsinglebit(longword(avalue),
          longword(foptionswidget),longword(mask1)));
  delta:= optionswidgetty(longword(value) xor longword(foptionswidget));
  foptionswidget:= value;
  if (delta * [ow_background,ow_top] <> []) then begin
   if fparentwidget <> nil  then begin
    fparentwidget.sortzorder;
   end
   else begin
    if ownswindow then begin
     app.updatewindowstack;
    end;
   end;
  end;
  if delta * [ow_fontlineheight,ow_fontglyphheight] <> [] then begin
   updatefontheight;
  end;
 end;
end;

procedure twidget.objectevent(const sender: tobject; const event: objecteventty);
begin
 if (event = oe_changed) then begin
  if (fface <> nil) and (sender = fface.ftemplate) then begin
   fface.assign(tpersistent(sender));
  end
  else begin
   if (fframe <> nil) and (sender = frame.ftemplate) then begin
    fframe.assign(tpersistent(sender));
   end
  end;
 end;
end;

procedure twidget.receiveevent(const event: tobjectevent);
begin
 inherited;
 case event.kind of
  ek_release: begin
   free;
  end;
  ek_activate: begin
//   window.internalactivate(false);
   window.activate;
  end;
  ek_childscaled: begin
   exclude(fwidgetstate1,ws1_childscaled);
   dochildscaled(nil);
  end;
  ek_resize: begin
   clientsize:= addsize(clientsize,tresizeevent(event).size);
  end;
 end;
end;

function twidget.canclose(const newfocus: twidget): boolean;
var
 int1: integer;
begin
 result:= true;
 for int1:= 0 to widgetcount - 1 do begin
  result:= widgets[int1].canclose(newfocus);
  if not result then begin
   break;
  end;
 end;
end;

function twidget.canparentclose(const newfocus: twidget): boolean;
                   //window.focusedwidget is first checked
begin
 if checkdescendent(window.focusedwidget) then begin
  result:= window.focusedwidget.canclose(newfocus);
  if not result then begin
   exit;
  end;
 end;
 result:= canclose(newfocus);
end;

function twidget.canparentclose: boolean;
begin
 result:= canparentclose(window.focusedwidget);
end;

function twidget.getcaretcliprect: rectty;
 //origin = clientrect.pos
begin
 result:= makerect(nullpoint,clientsize);
end;

procedure twidget.dofontchanged(const sender: tobject);
begin
 fontchanged;
end;

procedure twidget.fontchanged;
var
 int1: integer;
begin
 if componentstate * [csdestroying,csloading] = [] then begin
  invalidate;
  if not (ws_loadedproc in fwidgetstate) then begin
   for int1:= 0 to widgetcount - 1 do begin
    widgets[int1].parentfontchanged;
   end;
  end;
  updatefontheight;
 end;
end;

procedure twidget.dofontheightdelta(var delta: integer);
begin
 if ow_autoscale in foptionswidget then begin
  with fwidgetrect do begin
   if fanchors * [an_top,an_bottom] = [an_bottom] then begin
    setwidgetrect(makerect(x,y-delta,cx,cy+delta));
   end
   else begin
    bounds_cy:= fwidgetrect.cy + delta;
   end;
  end;
 end;
end;

procedure twidget.postchildscaled;
begin
 if not (ws1_childscaled in fwidgetstate1) then begin
  include(fwidgetstate1,ws1_childscaled);
  app.postevent(tobjectevent.create(ek_childscaled,ievent(self)));
 end;
end;

procedure twidget.updatefontheight;
var
 int1: integer;
begin
 if not (csloading in componentstate) and 
      (foptionswidget * [ow_fontglyphheight,ow_fontlineheight] <> []) then begin
  int1:= ffontheight;
  if ow_fontglyphheight in foptionswidget then begin
   ffontheight:= getfont.glyphheight;
  end
  else begin
   ffontheight:= getfont.lineheight;
  end; 
  if int1 <> 0 then begin
   int1:= ffontheight - int1;
   if int1 <> 0 then begin
    dofontheightdelta(int1);
    if (int1 <> 0) and (fparentwidget <> nil) then begin
     fparentwidget.postchildscaled;
    end;
   end;
  end;
 end;
end;

procedure twidget.readfontheight(reader: treader);
begin
 ffontheight:= reader.ReadInteger;
end;

procedure twidget.writefontheight(writer: twriter);
begin
 writer.writeinteger(ffontheight);
end;

procedure twidget.defineproperties(filer: tfiler);
var
 bo1: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  bo1:= twidget(filer.ancestor).ffontheight <> ffontheight;
 end
 else begin
  bo1:= foptionswidget * [ow_fontglyphheight,ow_fontlineheight] <> [];
 end;
 filer.DefineProperty('reffontheight',{$ifdef FPC}@{$endif}readfontheight,
           {$ifdef FPC}@{$endif}writefontheight,bo1);
end;
{
procedure twidget.writestate(writer: twriter);
var
 face1: tcustomface;
begin
 face1:= fface;
 if (fface <> nil) and (fface.ftemplate <> nil) then begin
//  fface:= nil;
 end;
 try
  inherited;
 finally
  fface:= face1;
 end;
end;
}
procedure twidget.parentfontchanged;
begin
 if fframe <> nil then begin
  fframe.parentfontchanged;
 end;
 if ffont = nil then begin
  fontchanged;
 end;
end;

procedure twidget.reflectmouseevent(var info: mouseeventinfoty);
var
 id: winidty;
 po1: pointty;
 window1: twindow;
begin
 with info do begin
  if not (eventkind in mouseregionevents) then begin
   po1:= translatewidgetpoint(pos,self,nil);
   id:= gui_windowatpos(po1);
   if (id = 0) or not app.findwindow(id,window1) then begin
    window1:= fwindow;
   end;
   subpoint1(po1,window1.fowner.fwidgetrect.pos);
   app.feventlist.insert(0,tmouseevent.create(window1.winid,
     eventkind = ek_buttonrelease,button,po1,shiftstate,info.timestamp,true));
  end;
 end;
end;

function twidget.getnextfocus: twidget;
var
 widget1: twidget;
 int1,int2: integer;
begin
 result:= nexttaborder;
 if (result = self) or (result  = nil) then begin
  result:= nil;
  if fparentwidget <> nil then begin
   int2:= parentwidgetindex;
   for int1:= int2+1 to fparentwidget.widgetcount - 1 do begin
    widget1:= twidget(fparentwidget.fwidgets[int1]);
    if widget1.canfocus and (ws_iswidget in widget1.fwidgetstate) then begin
     result:= widget1;
     break;
    end;
   end;
   if result = nil then begin
    for int1:= int2 - 1 downto 0 do begin
     widget1:= twidget(fparentwidget.fwidgets[int1]);
     if widget1.canfocus  and (ws_iswidget in widget1.fwidgetstate) then begin
      result:= widget1;
      break;
     end;
    end;
    if result = nil then begin
     if fparentwidget.canfocus then begin
      result:= fparentwidget;
     end
     else begin
      result:= fparentwidget.getnextfocus;
     end;
     exit;
    end;
   end;
  end;
 end;
end;

procedure twidget.nextfocus;
begin
 window.setfocusedwidget(getnextfocus);
end;

function twidget.getdisprect: rectty;     //origin parentwidget.pos, 
                                          //clamped in view by activate
begin
 result.pos:= nullpoint;
 result.size:= fwidgetrect.size;
end;

function twidget.getdefaultfocuschild: twidget; //returns first focusable widget
var
 tabord: integer;
 int1: integer;
 widget1: twidget;
begin
 if (fdefaultfocuschild <> nil) and fdefaultfocuschild.canfocus then begin
  result:= fdefaultfocuschild;
 end
 else begin
  result:= nil;
 end;
 if result = nil then begin
  tabord:= bigint;
  with container do begin
   for int1:= 0 to widgetcount - 1 do begin
    widget1:= twidget(fwidgets[int1]);
    with widget1 do begin
     if (ftaborder < tabord) and (ow_tabfocus in foptionswidget) and canfocus then begin
      result:= widget1;
      tabord:= ftaborder;
     end;
    end;
   end;
  end;
 end;
end;

procedure twidget.setdefaultfocuschild(const value: twidget);
begin
 fdefaultfocuschild:= value;
end;

function twidget.parentwidgetindex: integer;
begin
 if fparentwidget = nil then begin
  result:= -1;
 end
 else begin
  result:= fparentwidget.IndexOfwidget(self);
 end;
end;

procedure twidget.invalidateparentminclientsize;
begin
 if fparentwidget <> nil then begin
  exclude(fparentwidget.fwidgetstate,ws_minclientsizevalid);
//  fparentwidget.invalidateparentminclientsize;
 end;
end;

procedure twidget.setanchors(const Value: anchorsty);
begin
 if fanchors <> value then begin
  fanchors := Value;
  if not (csloading in componentstate) then begin
   invalidateparentminclientsize;
//  initparentclientrect;
   parentclientrectchanged;
  end;
 end;
end;

function twidget.getzorder: integer;
begin
 result:= 0; //!!!!todo
end;

procedure twidget.setzorder(const value: integer);
begin       //!!!!todo
 if ownswindow1 then begin
  window.setzorder(value);
 end;
end;

procedure twidget.createfont1;
begin
 if ffont = nil then begin
  ffont:= twidgetfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
 end;
end;

procedure twidget.syncsinglelinefontheight;
begin
 if fframe = nil then begin
  bounds_cy:= bounds_cy + getfont.glyphheight + 2 - paintsize.cy
 end
 else begin
  bounds_cy:= bounds_cy + getfont.glyphheight + fframe.framei_top + 
             fframe.framei_bottom - paintsize.cy;
 end;
end;

procedure twidget.synctofontheight;
begin
 setfontheight;
end;

function twidget.getfont: twidgetfont;
begin
 getoptionalobject(ffont,{$ifdef FPC}@{$endif}createfont1);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  if fparentwidget <> nil then begin
   result:= fparentwidget.getfont;
  end
  else begin
   result:= stockobjects.fonts[stf_default];
  end;
 end;
end;

function twidget.getframefont: tfont;
begin
 if fparentwidget <> nil then begin
  result:= fparentwidget.getfont;
 end
 else begin
  result:= stockobjects.fonts[stf_default];
 end;
end;

function twidget.isfontstored: Boolean;
begin
 result:= ffont <> nil;
end;

procedure twidget.setfont(const avalue: twidgetfont);
begin
 if avalue <> ffont then begin
  setoptionalobject(avalue,ffont,{$ifdef FPC}@{$endif}createfont1);
  fontchanged;
 end;
end;

function twidget.getframe: tcustomframe;
begin
 getoptionalobject(fframe,{$ifdef FPC}@{$endif}createframe1);
 result:= fframe;
end;

procedure twidget.setframe(const avalue: tcustomframe);
begin
 if (ws_staticframe in fwidgetstate) then begin
  if avalue <> nil then begin
   fframe.assign(avalue);
  end;
 end
 else begin
  setoptionalobject(avalue,fframe,{$ifdef FPC}@{$endif}createframe1);
 end;
end;

function twidget.getface: tcustomface;
begin
 getoptionalobject(fface,{$ifdef FPC}@{$endif}createface1);
 result:= fface;
end;

procedure twidget.setface(const avalue: tcustomface);
begin
 if (ws_staticface in fwidgetstate) then begin
  if avalue <> nil then begin
   fface.assign(avalue);
  end;
 end
 else begin
  setoptionalobject(avalue,fface,{$ifdef FPC}@{$endif}createface1);
 end;
 invalidate;
end;

function twidget.getinnerstframe: framety;
begin
 if fframe <> nil then begin
  with fframe do begin
   result.left:= fouterframe.left + fpaintframe.left + fi.innerframe.left;
   result.top:= fouterframe.top + fpaintframe.top + fi.innerframe.top;
   result.right:= fouterframe.right + fpaintframe.right + fi.innerframe.right;
   result.bottom:= fouterframe.bottom + fpaintframe.bottom + fi.innerframe.bottom;
  end;
 end
 else begin
  result:= nullframe;
 end;
end;

function twidget.getcomponentstate: tcomponentstate;
begin
 result:= componentstate;
end;

procedure twidget.setframeinstance(instance: tcustomframe);
begin
 fframe:= instance;
end;

procedure twidget.setstaticframe(value: boolean);
begin
 if value then begin
  include(fwidgetstate,ws_staticframe);
 end
 else begin
  exclude(fwidgetstate,ws_staticframe);
 end;
end;

function twidget.widgetstate: widgetstatesty;
begin
 result:= fwidgetstate;
end;

procedure twidget.insertwidget(const awidget: twidget; const apos: pointty);
begin
 if (awidget.fparentwidget <> nil) and (awidget.fparentwidget <> self) then begin
  awidget.fparentwidget.unregisterchildwidget(awidget);
  awidget.fparentwidget:= nil;
 end;
 if not (csloading in componentstate) then begin
  awidget.fparentclientsize:= clientsize;
 end;
 if awidget.ownswindow1 then begin
  awidget.fwidgetrect.pos:= addpoint(screenpos,apos);
 end
 else begin
  awidget.fwidgetrect.pos:= apos;
 end;
 awidget.parentwidget:= self;
end;

procedure twidget.insertwidget(const awidget: twidget);
begin
 insertwidget(awidget,awidget.fwidgetrect.pos);
end;

function twidget.getwidget: twidget;
begin
 result:= self;
end;

procedure twidget.activate(const bringtofront: boolean = true);
begin
 if bringtofront then begin
  window.bringtofront;
 end;
 show;
 if not checkdescendent(window.ffocusedwidget) then begin
  setfocus;
 end
 else begin
  fwindow.ffocusedwidget.setfocus; //activate
 end;
end;

procedure twidget.bringtofront;
begin
 if fparentwidget <> nil then begin
  with fparentwidget do begin
   removeitem(pointerarty(fwidgets),self);
   additem(pointerarty(fwidgets),self);
   sortzorder;
  end;
//  invalidate;
 end
 else begin
  window.bringtofront;
 end;
end;

procedure twidget.sendtoback;
begin
 if fparentwidget <> nil then begin
  with fparentwidget do begin
   removeitem(pointerarty(fwidgets),self);
   insertitem(pointerarty(fwidgets),0,pointer(self));
   sortzorder;
  end;
//  invalidate;
 end
 else begin
  window.sendtoback;
 end;
end;

procedure twidget.stackunder(const predecessor: twidget);
var
 int1: integer;
begin
 if fparentwidget <> nil then begin
  with fparentwidget do begin
   removeitem(pointerarty(fwidgets),self);
   int1:= indexofwidget(predecessor);
   if int1 >0 then begin
    int1:= 0;
   end;
   insertitem(pointerarty(fwidgets),int1,pointer(self));
  end;
  invalidate;
 end
 else begin
  window.stackunder(predecessor.window);
 end;
end;

function twidget.gethint: msestring;
begin
 result:= fhint;
end;

procedure twidget.sethint(const Value: msestring);
begin
 fhint:= value;
end;

function twidget.ishintstored: boolean;
begin
 result:= fhint <> '';
end;

function twidget.findtagwidget(const atag: integer;
               const aclass: widgetclassty): twidget;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fwidgets) do begin
  if (fwidgets[int1].tag = atag) and 
         ((aclass = nil) or (fwidgets[int1] is aclass)) then begin
   result:= fwidgets[int1];
   exit;
  end;
 end;
 if result = nil then begin
  for int1:= 0 to high(fwidgets) do begin
   result:= fwidgets[int1].findtagwidget(atag,aclass);
   if result <> nil then begin
    exit;
   end;
  end;
 end;
end;

function twidget.gethelpcontext: msestring;
var
 widget1: twidget;
begin
 result:= fhelpcontext;
 if result = '' then begin
  if componentstate * [csloading,cswriting,csdesigning] = [] then begin
   widget1:= fparentwidget;
   while widget1 <> nil do begin
    result:= widget1.fhelpcontext;
    if result <> '' then begin
     break;
    end;
    widget1:= widget1.fparentwidget;
   end;
  end;
 end;
end;

{ twindow }

constructor twindow.create(aowner: twidget);
begin
 fowner:= aowner;
 fowner.fwindow:= self;
 fcanvas:= tcanvas.create(self,icanvas(self));
 fasynccanvas:= tcanvas.create(self,icanvas(self));
 inherited create;
 fowner.rootchanged; //nil all references
end;

destructor twindow.destroy;
begin
 app.twindowdestroyed(self);
 if ftransientfor <> nil then begin
  dec(ftransientfor.ftransientforcount);
 end;
 if fowner <> nil then begin
  fowner.rootchanged;
 end;
 destroywindow;
 fcanvas.free;
 fasynccanvas.free;
 inherited;
 destroyregion(fupdateregion);
end;

procedure twindow.sizeconstraintschanged;
begin
 if fwinid <> 0 then begin
  guierror(gui_setsizeconstraints(fwinid,fowner.fminsize,fowner.fmaxsize));
 end;
end;

procedure twindow.createwindow;
var
 gc: gcty;
 aoptions: windowinfoty;
 aoptions1: internalwindowoptionsty;
begin
 if fwinid = 0 then begin
  fillchar(aoptions,sizeof(aoptions),0);
  fillchar(aoptions1,sizeof(aoptions1),0);
  aoptions.groupleader:= application.mainwindow;
  aoptions.initialwindowpos:= fwindowpos;
  aoptions.transientfor:= ftransientfor;
  fowner.updatewindowinfo(aoptions);
  foptions:= aoptions.options;
  fwindowpos:= aoptions.initialwindowpos;
  updatebit({$ifdef FPC}longword{$else}word{$endif}(fstate),
               ord(tws_needsdefaultpos),fwindowpos = wp_default);
  with aoptions do begin
   buttonendmodal:= wo_buttonendmodal in options;
   aoptions1.options:= options;
   aoptions1.pos:= fwindowpos;
   if transientfor <> nil then begin
    checkrecursivetransientfor(transientfor);
    ftransientfor:= aoptions.transientfor;
    aoptions1.transientfor:= transientfor.winid;
   end
   else begin
    aoptions1.transientfor:= 0;
    ftransientfor:= nil;
   end;
   aoptions1.icon:= icon;
   aoptions1.iconmask:= iconmask;
  end;
  if (aoptions1.transientfor = 0) and (ftransientfor <> nil) then begin
   inc(ftransientfor.ftransientforcount);
   aoptions1.transientfor:= ftransientfor.winid;
  end;

  if (aoptions.groupleader <> nil) and
          aoptions.groupleader.fowner.isgroupleader then begin
   aoptions1.setgroup:= true;
   if aoptions.groupleader <> self then begin
    aoptions1.groupleader:= aoptions.groupleader.winid;
   end;
  end;

  guierror(gui_createwindow(fowner.fwidgetrect,aoptions1,fwinid),self);
  sizeconstraintschanged;
  fstate:= fstate - [tws_posvalid,tws_sizevalid];
  fillchar(gc,sizeof(gcty),0);
  guierror(gui_creategc(fwinid,false,gc),self);
  fcanvas.linktopaintdevice(fwinid,gc,fowner.fwidgetrect.size,nullpoint);
  finalize(gc);
  fillchar(gc,sizeof(gcty),0);
  guierror(gui_creategc(fwinid,false,gc),self);
  fasynccanvas.linktopaintdevice(fwinid,gc,fowner.fwidgetrect.size,nullpoint);
  if app <> nil then begin
   tinternalapplication(application).registerwindow(self);
  end;
  if fcaption <> '' then begin
   gui_setwindowcaption(fwinid,fcaption);
  end;
  fowner.windowcreated;
 end
 else begin
  guierror(gue_illegalstate,self);
 end;
end;

procedure twindow.destroywindow;
begin
 releasemouse;
// endmodal;
 if app <> nil then begin
  if app.caret.islinkedto(fcanvas) then begin
   app.caret.hide;
//   tcaret1(app.fcaret).remove;
  end;
  app.unregisterwindow(self);
 end;
 fcanvas.unlink;
 fasynccanvas.unlink;
 if fwinid <> 0 then begin
  gui_destroywindow(fwinid);
  app.windowdestroyed(fwinid);
  fwinid:= 0;
 end;
 exclude(fstate,tws_windowvisible);
end;

procedure twindow.windowdestroyed;
begin
 fwinid:= 0;
 destroywindow;
end;

procedure twindow.checkwindow(windowevent: boolean);
begin
 if (app <> nil) and (aps_inited in app.fstate) then begin
  if fwinid = 0 then begin
   createwindow;
  end
  else begin
   if fstate * [tws_posvalid,tws_sizevalid] <>
           [tws_posvalid,tws_sizevalid] then begin
    if visible and not windowevent and not (tws_needsdefaultpos in fstate) then begin
     guierror(gui_reposwindow(fwinid,fowner.fwidgetrect),self);
     fstate:= fstate + [tws_posvalid,tws_sizevalid];
    end;
   end;
  end;
 end;
end;

procedure twindow.internalactivate(const windowevent: boolean;
                         const force: boolean = false);

 procedure setwinfoc;
 begin
  if (ftransientfor <> nil) and (force or (app.ffocuslockwindow = nil)) and 
                                (wo_popup in foptions) then begin
   app.ffocuslockwindow:= self;
   app.ffocuslocktransientfor:= ftransientfor;
  end;
  if app.ffocuslockwindow = nil then begin
   guierror(gui_setwindowfocus(fwinid),self);
  end;
 end;
 
var
 activecountbefore: cardinal;
 activewindowbefore: twindow;
 widgetar: widgetarty;
 int1: integer;
begin
 activewindowbefore:= app.factivewindow;
 show(windowevent);
 widgetar:= nil; //compilerwarning
 if  activewindowbefore <> self then begin
  if force or (app.fmodalwindow = nil) or (app.fmodalwindow = self) or 
                        (ftransientfor = app.fmodalwindow) then begin
   if (ffocusedwidget = nil) and fowner.canfocus then begin
    fowner.setfocus;
    exit;
   end;
   if activewindowbefore <> nil then begin
    activewindowbefore.deactivate;
   end;
   if app.factivewindow = nil then begin
    if not (ws_active in fowner.fwidgetstate) then begin
     inc(factivecount);
     activecountbefore:= factivecount;
     if ffocusedwidget <> nil then begin
      widgetar:= ffocusedwidget.getrootwidgetpath;
      for int1:= high(widgetar) downto 0 do begin
       widgetar[int1].internaldoactivate;
       if factivecount <> activecountbefore then begin
        exit;
       end;
      end;
     end;
     app.factivewindow:= self;
     if factivecount <> activecountbefore then begin
      exit;
     end;
     if not windowevent then begin
      setwinfoc;
     end
     else begin
      app.ffocuslockwindow:= nil;
     end;
    end;
   end;
   app.fonactivechangelist.doactivechange(activewindowbefore,self);
  end
  else begin
   app.fwantedactivewindow:= self;
  end;
 end
 else begin
  setwinfoc;
 end;
end;

procedure twindow.deactivate;
var
 widget: twidget;
 activecountbefore: cardinal;
begin
 if app.ffocuslockwindow = self then begin
  app.ffocuslockwindow:= nil;
 end;
 if ws_active in fowner.fwidgetstate then begin
  if ffocusedwidget <> nil then begin
   inc(factivecount);
   activecountbefore:= factivecount;
   widget:= ffocusedwidget;
   while widget <> nil do begin
    widget.internaldodeactivate;
    if factivecount <> activecountbefore then begin
     exit;
    end;
    widget:= widget.fparentwidget;
   end;
  end
  else begin
   fowner.internaldodeactivate;
  end;
  if app.factivewindow = self then begin
   inc(factivecount);
   activecountbefore:= factivecount;
   app.fonactivechangelist.doactivechange(app.factivewindow,nil);
   if factivecount = activecountbefore then begin
    app.factivewindow:= nil;
   end;
  end;
 end
 else begin
  if app.factivewindow = self then begin
   app.factivewindow:= nil; //should never happen
  end;
 end;
end;

procedure twindow.hide(windowevent: boolean);
var
 int1: integer;
 window1: twindow;
begin
 releasemouse;
 if not(ws_visible in fowner.fwidgetstate) then begin
  if fwinid <> 0 then begin
   if tws_windowvisible in fstate then begin
    if not windowevent or (app.factivewindow = self) then begin
     endmodal;
    end;
    if (application.fmainwindow = self) and not app.terminated then begin
     gui_flushgdi;
     sleep(0);     //give windowmanager time to unmap all windows
     app.sortzorder;
     exclude(fstate,tws_windowvisible);
     include(fstate,tws_grouphidden);
     include(fstate,tws_groupminimized);
     for int1:= 0 to app.fwindows.count - 1 do begin
      window1:= twindow(app.fwindows[int1]);
      if (window1 <> self) and (window1.fwinid <> 0) and 
                        gui_windowvisible(window1.fwinid) then begin
       with window1 do begin
        include(fstate,tws_grouphidden);
        if tws_windowvisible in fstate then begin
         include(fstate,tws_groupminimized);
        end;
        gui_setwindowstate(winid,wsi_minimized,false);
       end;
      end;
     end;
    end
    else begin
     exclude(fstate,tws_windowvisible);
    end;
    if not windowevent then begin
     exclude(fstate,tws_grouphidden);
     gui_hidewindow(fwinid);
    end;
   end;
  end;
 end;
end;

procedure twindow.show(windowevent: boolean);
var
 int1: integer;
 window1: twindow;
 size1: windowsizety;
begin
 if (ws_visible in fowner.fwidgetstate) then begin
  if not visible then begin
   include(fstate,tws_windowvisible);
   if not (csdesigning in fowner.ComponentState) then begin
    if not windowevent then begin
     gui_showwindow(winid);
     if not (tws_needsdefaultpos in fstate) then begin
      gui_reposwindow(fwinid,fowner.fwidgetrect);
     end;
    end;
    exclude(fstate,tws_grouphidden);
    exclude(fstate,tws_groupminimized);
    for int1:= 0 to app.fwindows.count - 1 do begin
     window1:= twindow(app.fwindows[int1]);
     if window1 <> self then begin
      with window1 do begin
       if tws_grouphidden in fstate then begin
        if tws_groupminimized in fstate then begin
         size1:= wsi_normal;
        end
        else begin
         size1:= wsi_minimized;
        end;
        gui_setwindowstate(winid,size1,true);
       end;
       exclude(fstate,tws_grouphidden);
       exclude(fstate,tws_groupminimized);
      end;
     end;
    end;
   end;
  end;
 end;
end;

function twindow.beginmodal: boolean; //true if destroyed
begin
 fmodalresult:= mr_none;
 with app do begin
  if (fmousecapturewidget <> nil) and
         not fowner.checkdescendent(fmousecapturewidget) then begin
   fmousecapturewidget.releasemouse;
  end;
  if fmodalwindow = nil then begin
   fwantedactivewindow:= nil; //init for lowest level
  end;
  result:= beginmodal(self);
  if (fmodalwindow = nil) then begin
   if fwantedactivewindow <> nil then begin
    fwantedactivewindow.activate;
   end;
  end
  else begin
   fmodalwindow.activate;
//   if ftransientfor <> nil then begin
//    ftransientfor.activate;
//   end;
  end;
 end;
end;

procedure twindow.endmodal;
begin
 app.endmodal(self);
end;

procedure twindow.poschanged;
begin
 exclude(fstate,tws_posvalid);
 if fobjectlinker <> nil then begin
  fobjectlinker.sendevent(oe_changed);
 end;
end;

procedure twindow.sizechanged;
begin
 exclude(fstate,tws_sizevalid);
 if fobjectlinker <> nil then begin
  fobjectlinker.sendevent(oe_changed);
 end;
end;

procedure twindow.wmconfigured(const arect: rectty);
var
 rect1: rectty;
begin
 exclude(fstate,tws_needsdefaultpos);
 if not rectisequal(arect,fowner.fwidgetrect) then begin
  rect1:= arect;
  fowner.internalsetwidgetrect(rect1,true);
  if pointisequal(arect.pos,fowner.fwidgetrect.pos) then begin
   include(fstate,tws_posvalid);
  end;
  if sizeisequal(arect.size,fowner.fwidgetrect.size) then begin
   include(fstate,tws_sizevalid);
  end;
 end;
 if not (windowpos in [wp_minimized,wp_maximized]) then begin
  fnormalwindowrect:= fowner.fwidgetrect;
 end;
end;

function twindow.internalupdate: boolean; //false if nothing is painted
var
 bo1: boolean;
 bmp: tbitmap;
 rect1: rectty;
 po1: pointty;
begin
 result:= false;
 if (ws_visible in fowner.fwidgetstate) and (fupdateregion <> 0) then begin
  checkwindow(false); //ev. reposition window
  fcanvas.reset;
  fcanvas.clipregion:= fupdateregion;
  bo1:= app.caret.islinkedto(fcanvas) and
   testintersectrect(fcanvas.clipbox,app.caret.rootcliprect);
  if bo1 then begin
   tcaret1(app.fcaret).remove;
  end;
  include(fstate,tws_painting);
  if flushgdi then begin
   try
    fupdateregion:= 0;
    result:= true;
    fowner.internalpaint(fcanvas);
   finally
    if bo1 then begin
     tcaret1(app.fcaret).restore;
    end;
   end;
  end
  else begin
   bmp:= tbitmap.create(false);
   try
    if intersectrect(fcanvas.clipbox,
            makerect(nullpoint,fowner.widgetrect.size),rect1) then begin
     bmp.size:= rect1.size;

     bmp.canvas.clipregion:= bmp.canvas.createregion(fupdateregion);
     po1.x:= -rect1.x;
     po1.y:= -rect1.y;
     tcanvas1(bmp.canvas).setcliporigin(po1);
     bmp.canvas.origin:= nullpoint;
     fupdateregion:= 0;
     result:= true;
     fowner.internalpaint(bmp.canvas);
     bmp.paint(fcanvas,rect1);
    end
    else begin
     fupdateregion:= 0;
    end;
   finally
    bmp.Free;
    if bo1 then begin
     tcaret1(app.fcaret).restore;
    end;
   end;
  end;
  exclude(fstate,tws_painting);
 end;
end;

procedure twindow.mouseparked;
var
 info: mouseeventinfoty;
begin
 info:= app.fmouseparkeventinfo;
 info.eventkind:= ek_mousepark;
 exclude(info.eventstate,es_processed);
 dispatchmouseevent(info,app.fmousecapturewidget);
end;

procedure twindow.checkmousewidget(const info: mouseeventinfoty; var capture: twidget);
begin
 if capture = nil then begin
  capture:= fowner.mouseeventwidget(info);
  if (capture = nil) and (tws_grab in fstate) then begin
   capture:= fowner;
  end;
 end;
 app.setmousewidget(capture);
end;

procedure twindow.dispatchmouseevent(var info: mouseeventinfoty;
                           capture: twidget);
var
 posbefore: pointty;
 int1: integer;
 po1: peventaty;
begin
 if info.eventkind in [ek_mouseenter,ek_mouseleave] then begin
  exit;
 end;
 checkmousewidget(info,capture);
 if capture <> nil then begin
  with capture do begin
   subpoint1(info.pos,rootpos);
   posbefore:= info.pos;
   mouseevent(info);
   posbefore:= subpoint(info.pos,posbefore);
   if (posbefore.x <> 0) or (posbefore.y <> 0) then begin
    gui_flushgdi;
    with app do begin
     getevents;
     po1:= peventaty(feventlist.datapo);
     for int1:= 0 to feventlist.count -1 do begin
      if (po1^[int1] <> nil) and (po1^[int1].kind = ek_mousemove) then begin
       freeandnil(po1^[int1]); //remove invalid events
      end;
     end;
     mouse.move(posbefore);
    end;
   end;
  end;
 end
 else begin
  if (info.eventkind = ek_buttonpress) and (tws_buttonendmodal in fstate) then begin
   endmodal;
  end;
 end;
end;

procedure twindow.dispatchkeyevent(const eventkind: eventkindty;
                                       var info: keyeventinfoty);
begin
 if ffocusedwidget <> nil then begin
  case eventkind of
   ek_keypress: ffocusedwidget.internalkeydown(info);
   ek_keyrelease: ffocusedwidget.dokeyup(info);
  end;
 end
 else begin
  if eventkind = ek_keypress then begin
   doshortcut(info,fowner);
  end;
 end;
end;

procedure twindow.setfocusedwidget(widget: twidget);
var
 focuscountbefore: cardinal;
 widget1: twidget;
 widgetar: widgetarty;
 int1,int2: integer;
 bo1: boolean;
begin
 widgetar:= nil; //compiler warning
 if ffocusedwidget <> widget then begin
  inc(ffocuscount);
  focuscountbefore:= ffocuscount;
  widget1:= ffocusedwidget;
  if widget1 <> nil then begin
   if not (csdestroying in widget1.componentstate) then begin
    if not widget1.canclose(widget) then begin
     exit;
    end;
    ffocusedwidget:= nil;
    widget1.internaldodefocus;
    if ffocuscount <> focuscountbefore then begin
     exit;
    end;
   end
   else begin
    ffocusedwidget:= nil;
   end;
   while (widget1 <> nil) and (widget1 <> widget) and 
               not widget1.checkdescendent(widget) do begin
    if not (csdestroying in widget1.componentstate) then begin
     widget1.internaldodeactivate;
     if ffocuscount <> focuscountbefore then begin
      exit;
     end;
     widget1.internaldoexit;
     if ffocuscount <> focuscountbefore then begin
      exit;
     end;
    end;
    widget1:= widget1.fparentwidget;
   end;
  end;
  ffocusedwidget:= widget;
  if widget <> nil then begin
   widgetar:= widget.getrootwidgetpath;
   int2:= length(widgetar);
   if widget1 <> nil then begin
    for int1:= 0 to high(widgetar) do begin
     if widgetar[int1] = widget1 then begin
      int2:= int1;    //common ancestor
      break;
     end;
    end;
   end;
//   bo1:= ws_active in fowner.fwidgetstate;
   bo1:= app.factivewindow = self;
   for int1:= int2-1 downto 0 do begin
    widgetar[int1].internaldoenter;
    if ffocuscount <> focuscountbefore then begin
     exit;
    end;
    if bo1 then begin
     widgetar[int1].internaldoactivate;
    end;
    if ffocuscount <> focuscountbefore then begin
     exit;
    end;
   end;
   ffocusedwidget.internaldofocus;
  end;
 end;
end;

procedure twindow.invalidaterect(const rect: rectty; const sender: twidget = nil);
var
 arect: rectty;
begin
 if (rect.cx > 0) or (rect.cy > 0) then begin
  arect:= intersectrect(rect,makerect(nullpoint,fowner.fwidgetrect.size));
  if (sender <> nil) and (sender.fparentwidget <> nil) then begin
   arect:= intersectrect(arect,moverect(sender.fparentwidget.paintrect,
                                        sender.fparentwidget.rootpos));
  end;
  if fupdateregion = 0 then begin
   fupdateregion:= createregion(arect);
  end
  else begin
   regaddrect(fupdateregion,arect);
  end;
  if app <> nil then begin
   app.invalidated;
  end;
 end;
end;

procedure twindow.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if not (es_broadcast in info.eventstate) then begin
  if not (es_processed in info.eventstate) and not (tws_localshortcuts in fstate){ and
                        not (tws_modal in fstate)} then begin
   if tws_modal in fstate then begin
    include(info.eventstate,es_modal);
   end;
   try
    app.checkshortcut(self,sender,info);
   finally
    exclude(info.eventstate,es_modal);
   end;
  end
 end
 else begin
  if tws_globalshortcuts in fstate then begin
   fowner.doshortcut(info,nil);
  end;
 end;
end;

procedure twindow.gcneeded(const sender: tcanvas);
begin
 createwindow;
end;

function twindow.getmonochrome: boolean;
begin
 result:= false;
end;

procedure twindow.update;
var
 int1: integer;
 event: twindowrectevent;
begin
 if app <> nil then begin
  gui_flushgdi;
  app.getevents;
  for int1:= 0 to app.feventlist.count - 1 do begin
   event:= twindowrectevent(app.feventlist[int1]);
   if (event <> nil) and (event.kind = ek_expose) and
             (event.fwinid = fwinid) then begin
    invalidaterect(event.frect);
    app.feventlist[int1]:= nil;
    event.free;
   end;
  end;
  internalupdate;
  gui_flushgdi;
 end;
end;

procedure twindow.movewindowrect(const dist: pointty;
  const rect: rectty);
begin
 gui_movewindowrect(fwinid,dist,rect);
end;

function twindow.getsize: sizety;
begin
 result:= fowner.getsize;
end;

function twindow.close: boolean;
begin
 if fmodalresult = mr_none then begin
  fmodalresult:= mr_windowclosed;
 end;
 result:= fowner.canparentclose(nil);
 if result then begin
  deactivate;
  fowner.hide;
  destroywindow;
 end
 else begin
  fmodalresult:= mr_none;
 end;
end;

procedure twindow.bringtofront;
begin
 gui_raisewindow(winid);
end;

procedure twindow.sendtoback;
begin
 gui_lowerwindow(winid);
end;

procedure twindow.stackunder(const predecessor: twindow);
begin
 if (predecessor <> self) then begin
  app.stackunder(self,predecessor);
 end;
end;

procedure twindow.stackover(const predecessor: twindow);
begin
 if (predecessor <> self) then begin
  app.stackover(self,predecessor);
 end;
end;

function twindow.stackedover: twindow; //nil if top
var
 ar1: windowarty;
 int1: integer;

begin
 app.sortzorder;
 ar1:= app.windowar;
 result:= nil;
 for int1:= high(ar1) downto 1 do begin
  if ar1[int1] = self then begin
   result:= ar1[int1-1];
   break;
  end;
 end;
end;

function twindow.stackedunder: twindow;  //nil if bottom
var
 ar1: windowarty;
 int1: integer;

begin
 app.sortzorder;
 ar1:= app.windowar;
 result:= nil;
 for int1:= 0 to high(ar1)-1 do begin
  if ar1[int1] = self then begin
   result:= ar1[int1+1];
   break;
  end;
 end;
end;

procedure twindow.capturemouse;
begin
 if app.grabpointer(winid) then begin
  include(fstate,tws_grab);
 end;
end;

procedure twindow.releasemouse;
begin
 if tws_grab in fstate then begin
  exclude(fstate,tws_grab);
  app.ungrabpointer;
 end;
end;

procedure twindow.checkrecursivetransientfor(const value: twindow);
var
 window1: twindow;
begin
 window1:= value;
 while window1 <> nil do begin
  if window1 = self then begin
   guierror(gue_recursivetransientfor);
  end;
  window1:= window1.ftransientfor;
 end;
end;

procedure twindow.settransientfor(const Value: twindow; const windowevent: boolean);
begin
 if not windowevent then begin
  if ftransientfor <> value then begin
   checkrecursivetransientfor(value);
   if ftransientfor <> nil then begin
    dec(ftransientfor.ftransientforcount);
   end;
   setlinkedvar(value,tlinkedobject(ftransientfor));
   if ftransientfor <> nil then begin
    inc(ftransientfor.ftransientforcount);
   end;
//   getobjectlinker.setlinkedvar(iobjectlink(self),value,tlinkedobject(ftransientfor));
   if fwinid <> 0 then begin
    if value <> nil then begin
     gui_settransientfor(fwinid,value.winid);
    end
    else begin
     gui_settransientfor(fwinid,0);
    end;
   end;
  end;
 end;
end;

function twindow.winid: winidty;
begin
 checkwindow(false);
 result:= fwinid;
end;

procedure twindow.hidden;
begin
 if tws_windowvisible in fstate then begin
  fowner.internalhide(true);
 end;
end;

procedure twindow.showed;
begin
 if not (tws_windowvisible in fstate) then begin
  fowner.internalshow(false,nil,true);
 end;
end;

procedure twindow.activated;
begin
 internalactivate(true);
end;

procedure twindow.deactivated;
begin
 deactivate;
end;

function twindow.canactivate: boolean;
begin
 result:= (app <> nil) and (app.fmodalwindow = nil) or (app.fmodalwindow = self);
end;

procedure twindow.activate;
begin
 internalactivate(false);
end;

procedure twindow.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 if fwinid <> 0 then begin
  gui_setwindowcaption(fwinid,fcaption);
 end;
end;

procedure twindow.widgetdestroyed(widget: twidget);
begin
 if ffocusedwidget = widget then begin
  setfocusedwidget(nil);
 end;
end;

function twindow.state: windowstatesty;
begin
 result:= fstate;
end;

procedure twindow.registermovenotification(sender: iobjectlink);
begin
// getobjectlinker.link(sender,iobjectlink(self));
 getobjectlinker.link(iobjectlink(self),sender);
// movenotificationlist.add(widget);
end;

procedure twindow.unregistermovenotification(sender: iobjectlink);
begin
 if (self <> nil) and (fobjectlinker <> nil) then begin
//  fobjectlinker.unlink(sender,iobjectlink(self));
  fobjectlinker.unlink(iobjectlink(self),sender);
 end;
// if fmovenotificationlist <> nil then begin
//  fmovenotificationlist.remove(widget);
// end;
end;

procedure twindow.setmodalresult(const Value: modalresultty);
begin
 fmodalresult := Value;
 if (value <> mr_none) {and (tws_modal in fstate)} then begin
  close;
 end;
end;

function twindow.candefocus: boolean;
begin
 result:= (ffocusedwidget = nil) or ffocusedwidget.canclose(nil);
end;

procedure twindow.nofocus;
begin
 setfocusedwidget(nil);
end;

function twindow.getglobalshortcuts: boolean;
begin
 result:= tws_globalshortcuts in fstate;
end;

procedure twindow.setglobalshortcuts(const Value: boolean);
begin
 updatebit({$ifdef FPC}longword{$else}word{$endif}(fstate),ord(tws_globalshortcuts),value);
end;

function twindow.getlocalshortcuts: boolean;
begin
 result:= tws_globalshortcuts in fstate;
end;

procedure twindow.setlocalshortcuts(const Value: boolean);
begin
 updatebit({$ifdef FPC}longword{$else}word{$endif}(fstate),ord(tws_localshortcuts),value);
end;

function twindow.visible: boolean;
begin
 result:= fowner.visible and (tws_windowvisible in fstate) and
      (fwinid <> 0) and (gui_getwindowsize(fwinid) <> wsi_minimized);
end;

function twindow.normalwindowrect: rectty;
begin
 result:= fnormalwindowrect;
end;

function twindow.getbuttonendmodal: boolean;
begin
 result:= tws_buttonendmodal in fstate;
end;

procedure twindow.setbuttonendmodal(const value: boolean);
begin
 if value then begin
  include(fstate,tws_buttonendmodal);
 end
 else begin
  exclude(fstate,tws_buttonendmodal);
 end;
end;

procedure twindow.setzorder(const value: integer);
begin
 if value = 0 then begin   //!!!!todo
  gui_lowerwindow(winid);
 end
 else begin
  gui_raisewindow(winid);
 end;
end;

function twindow.getwindowsize: windowsizety;
begin
 result:= gui_getwindowsize(winid);
end;

procedure twindow.setwindowsize(const value: windowsizety);
begin
 gui_setwindowstate(winid,value,true);
end;

function twindow.getwindowpos: windowposty;
var
 asize: windowsizety;
begin
 asize:= gui_getwindowsize(winid);
 case asize of
  wsi_minimized: begin
   result:= wp_minimized;
  end;
  wsi_maximized: begin
   result:= wp_maximized;
  end;
  else begin //wsi_normal
   if fwindowpos in [wp_minimized,wp_maximized,wp_screencentered] then begin
    result:= wp_normal;
   end
   else begin
    result:= fwindowpos;
   end;
  end;
 end;
end;

procedure twindow.setwindowpos(const Value: windowposty);
var
 rect1,rect2: rectty;
begin
 if getwindowpos <> value then begin
  case value of
   wp_screencentered: begin
    rect2:= app.workarea(self);
    with fowner do begin
     rect1:= widgetrect;
     rect1.x:= rect2.x + (rect2.cx - rect1.cx) div 2;
     rect1.y:= rect2.y + (rect2.cy - rect1.cy) div 2;
     widgetrect:= rect1;
    end;
   end;
   wp_minimized: begin
    gui_setwindowstate(winid,wsi_minimized,tws_windowvisible in fstate);
   end;
   wp_maximized: begin
    gui_setwindowstate(winid,wsi_maximized,tws_windowvisible in fstate);
   end
   else begin
    gui_setwindowstate(winid,wsi_normal,tws_windowvisible in fstate);
   end;
  end;
 end;
 fwindowpos := Value;
end;

{ tonterminatedlist }

procedure tonterminatedlist.doterminated;
begin
 factitem:= 0;
 while (factitem < fcount) do begin
  notifyeventty(getitempo(factitem)^)(application);
  inc(factitem);
 end;
end;

{ tonterminatequerylist }

function tonterminatequerylist.doterminatequery: boolean;
begin
 factitem:= 0;
 result:= true;
 while (factitem < fcount) and result do begin
  terminatequeryeventty(getitempo(factitem)^)(result);
  inc(factitem);
 end;
end;

{ tonidlelist}

function tonidlelist.doidle: boolean;
var
 bo1: boolean;
begin
 result:= false;
 factitem:= 0;
 while factitem < fcount do begin
  bo1:= false;
  idleeventty(getitempo(factitem)^)(bo1);
  result:= result or bo1;
  inc(factitem);
 end;
end;

{ tonkeyeventlist}

procedure tonkeyeventlist.dokeyevent(const sender: twidget; var info: keyeventinfoty);
begin
 factitem:= 0;
 while factitem < fcount do begin
  if es_processed in info.eventstate then begin
   break;
  end;
  keyeventty(getitempo(factitem)^)(sender,info);
  inc(factitem);
 end;
end;

{ tonactivechangelist}

procedure tonactivechangelist.doactivechange(const oldwindow,newwindow: twindow);
begin
 factitem:= 0;
 while factitem < fcount do begin
  activechangeeventty(getitempo(factitem)^)(oldwindow,newwindow);
  inc(factitem);
 end;
end;

 {tonwindoweventlist}

procedure tonwindoweventlist.doevent(const awindow: twindow);
begin
 factitem:= 0;
 while factitem < fcount do begin
  windoweventty(getitempo(factitem)^)(awindow);
  inc(factitem);
 end;
end;

{ tonapplicationactivechangedlist }


procedure tonapplicationactivechangedlist.doevent(const activated: boolean);
begin
 factitem:= 0;
 while factitem < fcount do begin
  booleaneventty(getitempo(factitem)^)(activated);
  inc(factitem);
 end;
end;

{ twindowevent }

constructor twindowevent.create(akind: eventkindty; winid: winidty);
begin
 inherited create(akind);
 fwinid:= winid;
end;

{ twindowrectevent }

constructor twindowrectevent.create(akind: eventkindty; winid: winidty;
  const rect: rectty);
begin
 inherited create(akind,winid);
 frect:= rect;
end;

{ tmouseevent }

constructor tmouseevent.create(winid: winidty; release: boolean; button: mousebuttonty;
                pos: pointty; shiftstate: shiftstatesty; atimestamp: cardinal;
                reflected: boolean = false);
var
 eventkind1: eventkindty;
begin
 if (atimestamp = 0) and (button <> mb_none) then begin
  inc(atimestamp);
 end;
 ftimestamp:= atimestamp;
 if button = mb_none then begin
  eventkind1:= ek_mousemove;
 end
 else begin
  if release then begin
   eventkind1:= ek_buttonrelease;
  end
  else begin
   eventkind1:= ek_buttonpress;
  end;
 end;
 inherited create(eventkind1,winid);
 fbutton:= button;
 fpos:= pos;
 fshiftstate:= shiftstate;
 freflected:= reflected;
end;

{ tkeyevent }

constructor tkeyevent.create(const winid: winidty; const release: boolean;
                  const key,keynomod: keyty; const shiftstate: shiftstatesty;
                  const chars: msestring);
var
 eventkind1: eventkindty;
begin
 if release then begin
  eventkind1:= ek_keyrelease;
 end
 else begin
  eventkind1:= ek_keypress;
 end;
 inherited create(eventkind1,winid);
 fkeynomod:= keynomod;
 fkey:= key;
 fchars:= chars;
 fshiftstate:= shiftstate;
end;

{ tinternalapplication }

constructor tinternalapplication.create(aowner: tcomponent);
begin
 fdblclicktime:= defaultdblclicktime;
 fapplicationname:= filename(sys_getapplicationpath);
 fthread:= sys_getcurrentthread;
 inherited;
 fonterminatedlist:= tonterminatedlist.create;
 fonterminatequerylist:= tonterminatequerylist.create;
 fonidlelist:= tonidlelist.create;
 fonkeypresslist:= tonkeyeventlist.create;
 fonshortcutlist:= tonkeyeventlist.create;
 fonactivechangelist:= tonactivechangelist.create;
 fonwindowdestroyedlist:= tonwindoweventlist.create;
 fonapplicationactivechangedlist:= tonapplicationactivechangedlist.create;
 fwindows:= tpointerlist.create;
 feventlist:= tobjectqueue.create(true);
 fcaret:= tcaret.create;
 fmouse:= tmouse.create(imouse(self));
 fhinttimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}hinttimer,false);
 fmouseparktimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}mouseparktimer,false);
 sys_mutexcreate(fmutex);
 sys_mutexcreate(feventlock);
end;

destructor tinternalapplication.destroy;
begin
 while componentcount > 0 do begin
  components[0].free;  //destroy loaded forms
 end;
 while fwindows.Count > 0 do begin
  twindow(fwindows[0]).fowner.free;
 end;
 inherited;
 fmouseparktimer.free;
 fhinttimer.free;
 fhintwidget.free;
 freeandnil(fcaret);
 deinitialize;
 fmouse.free;
 fwindows.free;
 feventlist.free;
 fonidlelist.free;
 fonterminatedlist.free;
 fonterminatequerylist.free;
 fonkeypresslist.free;
 fonshortcutlist.free;
 fonactivechangelist.free;
 fonwindowdestroyedlist.free;
 fonapplicationactivechangedlist.free;
 sys_mutexdestroy(fmutex);
 sys_mutexdestroy(feventlock);
end;

procedure tinternalapplication.flusheventbuffer;
var
 int1: integer;
begin
 sys_mutexlock(feventlock);
 for int1:= 0 to high(fpostedevents) do begin
  if feventlooping = 0 then begin
   gui_postevent(fpostedevents[int1]);
  end
  else begin
   feventlist.add(fpostedevents[int1]);
  end;
 end;
 fpostedevents:= nil;
 sys_mutexunlock(feventlock);
end;

procedure tinternalapplication.twindowdestroyed(const sender: twindow);
var
 int1: integer;
begin
 fonwindowdestroyedlist.doevent(sender);
 for int1:= 0 to high(fwindowstack) do begin
  with fwindowstack[int1] do begin
   if (lower = sender) or (upper = sender) then begin
    lower:= nil;
   end;
  end;
 end;
 if factivewindow = sender then begin
  factivewindow:= nil;
 end;
 if fwantedactivewindow = sender then begin
  fwantedactivewindow:= nil;
 end;
 if factmousewindow = sender then begin
  factmousewindow:= nil;
 end;
 if fmainwindow = sender then begin
  fmainwindow:= nil;
 end;
 if ffocuslockwindow = sender then begin
  ffocuslockwindow:= nil;
 end;
 if ffocuslocktransientfor = sender then begin
  ffocuslockwindow:= nil;
 end;
end;

function tinternalapplication.getmousewinid: winidty;
begin
 result:= fmousewinid;
 if (result = 0) and (fmousecapturewidget <> nil) then begin
  result:= fmousecapturewidget.window.winid;
 end;
end;

procedure tinternalapplication.processexposeevent(event: twindowrectevent);
var
 window: twindow;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   window.invalidaterect(frect);
  end;
 end;
end;

procedure tinternalapplication.processshowingevent(event: twindowevent);
var
 window: twindow;
begin
 with window,event do begin
  if findwindow(fwinid,window) then begin
   if event.kind = ek_show then begin
    showed;
   end
   else begin
    hidden;
   end;
  end;
 end;
end;

procedure tinternalapplication.processconfigureevent(event: twindowrectevent);
var
 window: twindow;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   window.wmconfigured(frect);
  end;
 end;
end;

procedure tinternalapplication.processwindowcrossingevent(event: twindowevent);
var
 window: twindow;
 info: mouseeventinfoty;
begin
 if findwindow(event.fwinid,window) then begin
  if event.kind = ek_leavewindow then begin
   fmouseparktimer.enabled:= false;
   if factmousewindow <> nil then begin
    fillchar(info,sizeof(info),0);
    info.eventkind:= ek_mouseleave;
    factmousewindow.dispatchmouseevent(info,nil);
   end;
   factmousewindow:= nil;
   if fmousecapturewidget = nil then begin
    setmousewidget(nil);
//    deactivatehint;
//    fhintedwidget:= nil;
   end
   else begin
    if (fclientmousewidget <> nil) and
       not (ws_clientmousecaptured in fclientmousewidget.fwidgetstate) then begin
     setclientmousewidget(nil);
    end;
   end;
   fmousewinid:= 0;
  end
  else begin
   fmousewinid:= event.fwinid;
//   if window.owner <> fhintwidget then begin
//    deactivatehint;
//   end;
  end;
 end;
end;

procedure tinternalapplication.mouseparktimer(const sender: tobject);
begin
 if factmousewindow <> nil then begin
  factmousewindow.mouseparked;
 end;
end;

procedure tinternalapplication.processmouseevent(event: tmouseevent);
var
 window: twindow;
 info: mouseeventinfoty;
 shift: shiftstatesty;
 abspos: pointty;
 int1: integer;
 bo1: boolean;
 ek1: eventkindty;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   fillchar(info,sizeof(info),0);
   with info do begin
    if freflected then begin
     include(eventstate,es_reflected);
    end;
    info.eventkind:= kind;
    button:= fbutton;
    pos:= fpos;
    abspos:= addpoint(window.fowner.fwidgetrect.pos,pos);
    case info.button of
     mb_left: shift:= [ss_left];
     mb_middle: shift:= [ss_middle];
     mb_right: shift:= [ss_right];
     else shift:= [];
    end;
    if eventkind = ek_buttonpress then begin
     shiftstate:= fshiftstate + shift;
    end
    else begin
     shiftstate:= fshiftstate - shift;
    end;
   end;
   if (fmodalwindow <> nil) and (window <> fmodalwindow) then begin
    addpoint1(info.pos,subpoint(window.fowner.fwidgetrect.pos,
        fmodalwindow.fowner.fwidgetrect.pos));
    window:= fmodalwindow;
   end;
   if (fmousecapturewidget <> nil) and 
                   (fmousecapturewidget.window <> window) then begin
    addpoint1(info.pos,subpoint(window.fowner.fwidgetrect.pos,
        fmousecapturewidget.fwindow.fowner.fwidgetrect.pos));
    window:= fmousecapturewidget.fwindow;
   end;
   if (aps_mousecaptured in fstate) and
            (event.fshiftstate * mousebuttons = []) then begin
    ungrabpointer;
   end;
   if (fhintwidget <> nil) and
    (fhintinfo.flags*[{hfl_custom,}hfl_noautohidemove] = [{hfl_custom}]) and
      (
      (info.eventkind = ek_buttonpress) or
      (info.eventkind = ek_buttonrelease) or
      (info.eventkind = ek_mousemove) and
         (distance(fhintinfo.mouserefpos,abspos) > 3)
       ) then begin
    bo1:= window = fhintwidget.window;
    deactivatehint;
    if bo1 then begin
     exit; //widow is destroyed
    end;
   end;
   fmouseparkeventinfo:= info;
   if factmousewindow <> window then begin
    ek1:= info.eventkind;
    info.eventkind:= ek_mouseenter;
    window.dispatchmouseevent(info,nil);
    info.eventkind:= ek1;
   end;
   factmousewindow:= window;
   fmouseparktimer.interval:= -mouseparktime;
   fmouseparktimer.enabled:= true;
   if ftimestamp <> 0 then begin
    info.timestamp:= ftimestamp;
    if (fbutton <> mb_none) then begin
                //test reflected event
     if kind = ek_buttonpress then begin
      if flastbuttonpresstimestamp = ftimestamp then begin
       flastbuttonpresstimestamp:= ftimestampbefore;
      end;
     end
     else begin
      if kind = ek_buttonrelease then begin
       if flastbuttonreleasetimestamp = ftimestamp then begin
        flastbuttonreleasetimestamp:= ftimestampbefore;
       end;
      end;
     end;
    end;
    if kind in [ek_buttonpress,ek_buttonrelease] then begin
     int1:= bigint;
     if (kind = ek_buttonpress) then begin
      if (flastbuttonpresstimestamp <> 0) and (fbutton = flastbuttonpress) then begin
       int1:= ftimestamp - flastbuttonpresstimestamp;
      end;
     end
     else begin
      if (flastbuttonreleasetimestamp <> 0) and
           (fbutton = flastbuttonrelease) then begin
       int1:= ftimestamp - flastbuttonreleasetimestamp;
      end;
     end;
     if (int1 >= 0) and (int1 < fdblclicktime) then begin
      include(info.shiftstate,ss_double);
     end;
    end;
   end;
   window.dispatchmouseevent(info,fmousecapturewidget);
   if (ftimestamp <> 0) and (fbutton <> mb_none) then begin
    if kind = ek_buttonpress then begin
     fbuttonpresswidgetbefore:= fmousewidget;
     ftimestampbefore:= flastbuttonpresstimestamp;
     flastbuttonpress:= fbutton;
     flastbuttonpresstimestamp:= ftimestamp;
    end
    else begin
     if kind = ek_buttonrelease then begin
      fbuttonreleasewidgetbefore:= fmousewidget;
      ftimestampbefore:= flastbuttonreleasetimestamp;
      flastbuttonrelease:= fbutton;
      flastbuttonreleasetimestamp:= ftimestamp;
     end;
    end;
   end;
   if not (hfl_custom in fhintinfo.flags) then begin
    if (fclientmousewidget <> fhintedwidget) then begin
     if (fclientmousewidget <> fhintwidget) and
               (fhintedwidget <> nil) or (fhintwidget = nil) then begin
      deactivatehint;
      fhintedwidget:= fclientmousewidget;
      if fhintedwidget <> nil then begin
       fhinttimer.interval:= -hintdelaytime;
       fhinttimer.enabled:= true;
      end;
     end;
    end
    else begin
     if (fhintedwidget <> nil) and (fhintwidget = nil) and (kind = ek_mousemove) then begin
      fhinttimer.interval:= -hintdelaytime;
      if (ow_multiplehint in fhintedwidget.foptionswidget) and
        (distance(fhintinfo.mouserefpos,abspos) > 3) then begin
       fhinttimer.enabled:= true;
      end;
     end;
    end;
   end;
  end
  else begin
   ungrabpointer;
  end;
 end;
end;

procedure tinternalapplication.processkeyevent(event: tkeyevent);
var
 window: twindow;
 info: keyeventinfoty;
 shift: shiftstatesty;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   fillchar(info,sizeof(info),0);
   with info do begin
    key:= fkey;
    keynomod:= fkeynomod;
    case key of
     key_shift: shift:= [ss_shift];
     key_alt: shift:= [ss_alt];
     key_control: shift:= [ss_ctrl];
     else shift:= [];
    end;
    chars:= fchars;
    if kind = ek_keypress then begin
     shiftstate:= fshiftstate + shift;
    end
    else begin
     shiftstate:= fshiftstate - shift;
    end;
    if factivewindow <> nil then begin
     fmouseparkeventinfo.shiftstate:= shiftstatesty(
        replacebits({$ifdef FPC}longword{$else}byte{$endif}(shiftstate),
          {$ifdef FPC}longword{$else}byte{$endif}(fmouseparkeventinfo.shiftstate),
          {$ifdef FPC}longword{$else}byte{$endif}(keyshiftstatesmask)));
     if kind = ek_keypress then begin
      fonkeypresslist.dokeyevent(factivewindow.ffocusedwidget,info);
     end;
     if not (es_processed in eventstate) then begin
      factivewindow.dispatchkeyevent(kind,info);
     end;
    end;
   end;
  end;
 end;
end;

function tinternalapplication.getevents: integer;
begin
 while gui_hasevent do begin
  feventlist.add(gui_getevent);
 end;
 result:= feventlist.count;
end;

procedure tinternalapplication.waitevent;
begin
 if feventlist.count = 0 then begin
  include(fstate,aps_waiting);
  feventlist.add(gui_getevent);
  exclude(fstate,aps_waiting);
 end
end;

procedure tinternalapplication.flushmousemove;
var
 int1: integer;
 event: tevent;
begin
 gui_flushgdi;
 getevents;
 for int1:= 0 to feventlist.count - 1 do begin
  event:= tevent(feventlist[int1]);
  if (event <> nil) and (event.kind = ek_mousemove) then begin
   event.free;
   feventlist[int1]:= nil;
  end;
 end;
end;

procedure tinternalapplication.windowdestroyed(id: winidty);
var
 int1: integer;
 event : tevent;
begin
 if not terminated then begin
  for int1:= 0 to getevents - 1 do begin
   event:= tevent(feventlist[int1]);
   if (event is twindowevent) and (twindowevent(event).fwinid = id) then begin
   {
    case event.kind of
     ek_focusin: tcaret1(fcaret).restore;
     ek_focusout: tcaret1(fcaret).remove;
    end;
    }
    event.Free;
    feventlist[int1]:= nil;
   end;
  end;
 end;
 fmouse.windowdestroyed(id);
 if id = fmousewinid then begin
  fmousewinid:= 0;
 end;
end;

procedure tinternalapplication.setwindowfocus(winid: winidty);
var
 window: twindow;
begin
 try
  if findwindow(winid,window) then begin
   if (fmodalwindow = nil) or (fmodalwindow = window) then begin
    window.activated;
   end
   else begin
    if not fmodalwindow.visible then begin
     gui_showwindow(fmodalwindow.fwinid);
    end;
    if ffocuslockwindow <> nil then begin //reactivate modal window
     if ffocuslocktransientfor <> nil then begin
      gui_setwindowfocus(ffocuslocktransientfor.winid);
     end;
    end
    else begin
     gui_setwindowfocus(fmodalwindow.fwinid);
    end;
    gui_raisewindow(fmodalwindow.fwinid);
   end;
  end;
 finally
  if not (aps_focused in fstate) then begin
   include(fstate,aps_focused);
   tcaret1(fcaret).restore;
  end;
 end;
end;

procedure tinternalapplication.unsetwindowfocus(winid: winidty);
var
 window: twindow;
begin
 if aps_focused in fstate then begin
  exclude(fstate,aps_focused);
  tcaret1(fcaret).remove;
 end;
 if findwindow(winid,window) then begin
  if (ffocuslockwindow <> nil) and (factivewindow <> nil) and 
         (window = ffocuslocktransientfor) then begin
   ffocuslockwindow:= nil;
   factivewindow.deactivated;
  end
  else begin
   window.deactivated;
  end;
 end;
end;

procedure tinternalapplication.registerwindow(window: twindow);
begin
 lock;
 try
  if fwindows.indexof(window) >= 0 then begin
   guierror(gue_alreadyregistered,window.fowner.name);
  end;
//  window.checkwindow(false); //create window
  fwindows.add(window);
  exclude(fstate,aps_zordervalid);
 finally
  unlock;
 end;
end;

procedure tinternalapplication.unregisterwindow(window: twindow);
begin
 lock;
 try
  fwindows.extract(window);
  if window.fwinid = fmousewinid then begin
   fmousewinid:= 0;
  end;
 finally
  unlock;
 end;
end;

procedure tinternalapplication.doterminate;
begin
 if fonterminatequerylist.doterminatequery then begin
  include(fstate,aps_terminated);
 end
 else begin
  gui_cancelshutdown;
 end;
end;

procedure tinternalapplication.doidle;
var
 int1: integer;
begin
 while true do begin
  if not fonidlelist.doidle then begin
   break;
  end;
  int1:= getevents;
  if int1 <> 0 then begin
   break;
  end;
 end;
end;

procedure tinternalapplication.checkshortcut(const sender: twindow;
               const awidget: twidget; var info: keyeventinfoty);
var
 int1: integer;
begin
 include(info.eventstate,es_broadcast);
 for int1:= fwindows.count - 1 downto 0 do begin
  if fwindows[int1] <> pointer(sender) then begin
   twindow(fwindows[int1]).doshortcut(info,awidget);
   if (es_processed in info.eventstate) then begin
    break;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  app.fonshortcutlist.dokeyevent(awidget,info);
 end;
end;

procedure tinternalapplication.checkactivewindow;
var
 int1: integer;
begin
 if factivewindow = nil then begin
  if (fmainwindow <> nil) then begin
   fmainwindow.fowner.activate;
  end
  else begin
   for int1:= 0 to fwindows.Count - 1 do begin
    with twindow(fwindows[int1]).fowner do begin
     if visible then begin
      activate;
      break;
     end;
    end;
   end;
   if (factivewindow = nil) and (fwindows.Count > 0) then begin
    twindow(fwindows[0]).fowner.activate;
   end;
  end;
 end;
end;

procedure tinternalapplication.checkapplicationactive;
var
 bo1: boolean;
begin
 bo1:= (activewindow <> nil);
 if  bo1 xor (aps_active in fstate) then begin
  fonapplicationactivechangedlist.doevent(bo1);
  if bo1 then begin
   include(fstate,aps_active);
  end
  else begin
   exclude(fstate,aps_active);
  end;
 end;
end;

function tinternalapplication.eventloop(const amodalwindow: twindow;
                                    const once: boolean = false): boolean;
                   //true if actual modalwindow destroyed
                   
 function checkiflast(const akind: eventkindty): boolean;
 var
  po1,po2: ^twindowevent;
  int1: integer;
 begin
  po2:= nil;
  po1:= pointer(feventlist.datapo);
  for int1:= 0 to feventlist.count - 1 do begin
           //check if last
   if po1^ <> nil then begin
    with po1^ do begin
     if (kind = akind) then begin
      if po2 <> nil then begin
       freeandnil(po2^);
      end;
      po2:= po1;
     end;
    end;
   end;
   inc(po1);
  end;
  result:= po2 = nil;
 end;
 
var
 modalinfo: modalinfoty;
 event: tevent;
 int1: integer;
 bo1: boolean;
 window: twindow;
 po1,po2: ^twindowevent;
 waitcountbefore: integer;
 ar1: integerarty;
 
begin       //eventloop
 ftimertick:= false;
 fillchar(modalinfo,sizeof(modalinfo),0);
 waitcountbefore:= fwaitcount;
 fwaitcount:= 0;
 mouse.shape:= fcursorshape;
 if amodalwindow <> nil then begin
  if fmodalwindow <> nil then begin
   setlinkedvar(fmodalwindow,tlinkedobject(modalinfo.modalwindowbefore));
  end;
  amodalwindow.fmodalinfopo:= @modalinfo;
  setlinkedvar(amodalwindow,tlinkedobject(fmodalwindow));
 end;

 lock;

 while not modalinfo.modalend and not terminated and 
                not (aps_exitloop in fstate) do begin //main eventloop
  try
   if getevents = 0 then begin
    checkwindowstack;
    repeat
     bo1:= false;
     exclude(fstate,aps_invalidated);
     for int1:= 0 to fwindows.Count - 1 do begin
      exclude(fstate,aps_invalidated);
      try
       bo1:= twindow(fwindows[int1]).internalupdate or bo1;
      except
       handleexception(self);
      end;
     end;
    until not bo1 and not terminated; //no more to paint
    if terminated or (aps_exitloop in fstate) then begin
     break;
    end;
    if not gui_hasevent then begin
     try
      if (amodalwindow = nil) and 
                         not (aps_activewindowchecked in fstate) then begin
       include(fstate,aps_activewindowchecked);
       checkactivewindow;
      end;
      if ftimertick then begin
       ftimertick:= false;
       msetimer.tick(self);
      end;
     except
      handleexception(self);
     end;
     if not gui_hasevent then begin
      try
       doidle;
      except
       handleexception(self);
      end;
     end;
     if terminated then begin
      break;
     end;
     if aps_needsupdatewindowstack in fstate then begin
      updatewindowstack;
      exclude(fstate,aps_needsupdatewindowstack);
     end
     else begin
      checkwindowstack;
     end;
     checkcursorshape;
     inc(fidlecount);
     if once then begin
      break;
     end;
     waitevent;
     exclude(fstate,aps_invalidated);
    end;
   end;
   if terminated then begin
    break;
   end;
   getevents;
   event:= tevent(feventlist.getfirst);
   if event <> nil then begin
    try
     try
      case event.kind of
       ek_timer: begin
        ftimertick:= true;
       end;
       ek_show,ek_hide: begin
        processshowingevent(twindowevent(event));
       end;
       ek_close: begin
        if findwindow(twindowevent(event).fwinid,window) then begin
         if (fmodalwindow = nil) or (fmodalwindow = window) then begin
          window.close;
         end
         else begin
          fmodalwindow.fowner.canclose(nil);
         end;
        end;
       end;
       ek_destroy: begin
        if findwindow(twindowevent(event).fwinid,window) then begin
         window.windowdestroyed;
        end;
        windowdestroyed(twindowevent(event).fwinid);
       end;
       ek_terminate: begin
        doterminate;
       end;
       ek_focusin: begin
        getevents;
        po1:= pointer(feventlist.datapo);
        bo1:= true;

        for int1:= 0 to feventlist.count - 1 do begin
         if po1^ <> nil then begin
          with po1^ do begin
           if (kind = ek_focusout) and (fwinid = twindowevent(event).fwinid) then begin
            bo1:= false;
            freeandnil(po1^); 
               //spurious focus, for instance minimize window group on windows
            break;
           end;
          end;
         end;
         inc(po1);
        end;

        if bo1 then begin
         include(fstate,aps_needsupdatewindowstack);
         setwindowfocus(twindowevent(event).fwinid);
         checkapplicationactive;
        end;
       end;
       ek_focusout: begin
        unsetwindowfocus(twindowevent(event).fwinid);
        postevent(tevent.create(ek_checkapplicationactive));
       end;
       ek_checkapplicationactive: begin
        if checkiflast(ek_checkapplicationactive) then begin
         checkapplicationactive;
        end;
       end;
       ek_expose: begin
        exclude(fstate,aps_zordervalid);
        processexposeevent(twindowrectevent(event));
       end;
       ek_configure: begin
        exclude(fstate,aps_zordervalid);
        processconfigureevent(twindowrectevent(event));
       end;
       ek_enterwindow: begin
        processwindowcrossingevent(twindowevent(event))
       end;
       ek_leavewindow: begin
        getevents;
        ar1:= nil;
        po1:= pointer(feventlist.datapo);
        bo1:= true;
        for int1:= 0 to feventlist.count - 1 do begin
         if po1^ <> nil then begin
          with po1^ do begin
           if kind in [ek_enterwindow,ek_leavewindow] then begin
            additem(ar1,int1);
           end;
           if (kind = ek_enterwindow) and (fwinid = twindowevent(event).fwinid) then begin
            bo1:= false;
               //spurious leavewindow
            break;
           end;
          end;
         end;
         inc(po1);
        end;
        if bo1 then begin
         processwindowcrossingevent(twindowevent(event))
        end
        else begin
         po1:= pointer(feventlist.datapo);
         for int1:= 0 to high(ar1) do begin
          freeandnil(pobjectaty(po1)^[ar1[int1]]);
         end;
        end;
       end;
       ek_mousemove: begin
        if checkiflast(ek_mousemove) then begin
         processmouseevent(tmouseevent(event));
        end;
       end;
       ek_buttonpress,ek_buttonrelease: begin
        processmouseevent(tmouseevent(event));
       end;
       ek_keypress,ek_keyrelease: begin
        processkeyevent(tkeyevent(event));
       end;
       else begin
        if event is tobjectevent then begin
         with tobjectevent(event) do begin
          deliver;
         end;
        end;
       end;
      end;
     finally
      event.free;
     end;
    except
     handleexception(self);
    end;
    checkcursorshape;
   end;
  except
  end;
 end;
 exclude(fstate,aps_exitloop);
 result:= false;
 if amodalwindow <> nil then begin
  if fmodalwindow <> nil then begin
   fmodalwindow.fmodalinfopo:= nil;
  end
  else begin
   result:= true;
  end; 
  if modalinfo.modalwindowbefore <> nil then begin
   setlinkedvar(modalinfo.modalwindowbefore,tlinkedobject(fmodalwindow));
   setlinkedvar(nil,tlinkedobject(modalinfo.modalwindowbefore));
  end
  else begin
   if fmodalwindow <> nil then begin
    setlinkedvar(nil,tlinkedobject(fmodalwindow));
    //no lower modalwindow alive
   end;
  end;
 end;
 fwaitcount:= waitcountbefore;
 if fwaitcount > 0 then begin
  mouse.shape:= cr_wait;
 end;
 checkcursorshape;

 unlock;

end;

function tinternalapplication.beginmodal(const sender: twindow): boolean;
                 //true if modalwindow destroyed
var
 bo1: boolean;
 window1: twindow;
begin
 window1:= nil;
 if (factivewindow <> nil) and (factivewindow <> sender) then begin
  setlinkedvar(factivewindow,tlinkedobject(window1));
 end;
 with sender do begin
  if tws_modal in fstate then begin
   guierror(gue_recursivemodal,self,fowner.name);
  end;
  include(fstate,tws_modal);
  sender.internalactivate(false,true);
 end;
 bo1:= unlock;
 try
  result:= eventloop(sender);
 finally
  if bo1 then begin
   lock;
  end;
  if window1 <> nil then begin
   window1.activate;
   setlinkedvar(nil,tlinkedobject(window1));
  end;
 end;
end;

procedure tinternalapplication.endmodal(const sender: twindow);
begin
 with sender do begin
  if tws_modal in fstate then begin
   if not app.terminated then begin
    fmodalinfopo^.modalend:= true;
   end;
   exclude(fstate,tws_modal);
  end;
 end;
end;

procedure tinternalapplication.stackunder(const sender: twindow; const predecessor: twindow);
begin
 setlength(fwindowstack,high(fwindowstack)+2);
 with fwindowstack[high(fwindowstack)] do begin
  lower:= sender;
  upper:= predecessor;
 end;
end;

procedure tinternalapplication.stackover(const sender: twindow; const predecessor: twindow);
begin
 setlength(fwindowstack,high(fwindowstack)+2);
 with fwindowstack[high(fwindowstack)] do begin
  lower:= predecessor;
  upper:= sender;
 end;
end;

function cmpwindowstack(const l,r): integer;
begin
 result:= windowstackinfoty(l).level - windowstackinfoty(r).level;
end;

procedure tinternalapplication.checkwindowstack;

 function findlevel(var item: windowstackinfoty): integer;
 var
  int1: integer;
 begin
  with item do begin
   if (level = 0) and (lower <> nil) and not recursion then begin
    if upper = nil then begin
     result:= -bigint;
    end
    else begin
     result:= 1; //not found upper
     recursion:= true;
     for int1:= 0 to high(fwindowstack) do begin
      with fwindowstack[int1] do begin
       if lower = item.upper then begin
        result:= findlevel(fwindowstack[int1]) + 1;
        break;
       end;
      end;
     end;
     recursion:= false;
    end;
   end
   else begin
    result:= level;
   end;
   level:= result;
  end;
 end;

var
 int1: integer;
begin
 if fwindowstack <> nil then begin
  for int1:= 0 to high(fwindowstack) do begin
   findlevel(fwindowstack[int1]);
  end;
  sortarray(fwindowstack,{$ifdef FPC}@{$endif}cmpwindowstack,sizeof(windowstackinfoty));
  if gui_canstackunder then begin
   for int1:= 0 to high(fwindowstack) do begin
    with fwindowstack[int1] do begin
     if lower <> nil then begin
      if upper = nil then begin
       gui_raisewindow(lower.winid);
      end
      else begin
       gui_stackunderwindow(lower.winid,upper.winid);
      end;
     end;
    end;
   end;
  end
  else begin
   for int1:= high(fwindowstack) downto 0 do begin
    with fwindowstack[int1] do begin
     if lower <> nil then begin
      gui_raisewindow(fwindowstack[int1].lower.winid);
     end;
    end;
   end;
   for int1:= 0 to high(fwindowstack) do begin //raise top level window
    with fwindowstack[int1] do begin
     if lower <> nil then begin
      if upper <> nil then begin
       gui_raisewindow(fwindowstack[int1].upper.winid);
      end;
      break;
     end;
    end;
   end;
  end;
  fwindowstack:= nil;
  exclude(fstate,aps_zordervalid);
 end;
end;

function compwindowzorder(const l,r): integer;
begin
 result:= 0;
 if (tws_windowvisible in twindow(l).fstate) then begin
  if not (tws_windowvisible in twindow(r).fstate) then begin
   inc(result,8);
  end
 end
 else begin
  if (tws_windowvisible in twindow(r).fstate) then begin
   dec(result,8);
  end
  else begin
   exit; //both invisible -> no change in order
  end;
 end;
 if ow_background in twindow(l).fowner.foptionswidget then dec(result);
 if ow_top in twindow(l).fowner.foptionswidget then inc(result);
 if ow_background in twindow(r).fowner.foptionswidget then inc(result);
 if ow_top in twindow(r).fowner.foptionswidget then dec(result);
 if (tws_modal in twindow(l).fstate) or (twindow(l).ftransientfor <> nil)
           or (twindow(l).ftransientforcount > 0)
            then begin
  inc(result,4);
 end;
 if (tws_modal in twindow(r).fstate) or (twindow(r).ftransientfor <> nil) or
               (twindow(r).ftransientforcount > 0) then begin
  dec(result,4);
 end;
end;

procedure tinternalapplication.updatewindowstack;
var
 ar3,ar4: windowarty;
 int1,int2: integer;
begin
 checkwindowstack;
 sortzorder;
 ar3:= windowar; //refcount 1
 ar4:= copy(ar3);
 sortarray(ar3,{$ifdef FPC}@{$endif}compwindowzorder,sizeof(ar3[0]));
 int2:= -1;
 for int1:= 0 to high(ar4) do begin
  if ar3[int1] <> ar4[int1] then begin
   int2:= int1; //invalid stackorder
   break;
  end;
 end;
 if int2 >= 0 then begin
  inc(int2);
  for int1:= high(ar3) downto int2 do begin
   if not (tws_windowvisible in ar3[int1-1].fstate) then begin
    break;
   end;
   stackunder(ar3[int1-1],ar3[int1]);
  end;
  checkwindowstack;
 end;
end;

procedure tinternalapplication.widgetdestroyed(const widget: twidget);
begin
 if fmousecapturewidget = widget then begin
  capturemouse(nil,false);
 end;
 if fcaretwidget = widget then begin
  fcaretwidget:= nil;
 end;
 if fmousewidget = widget then begin
  setmousewidget(nil);
 end;
 if fhintedwidget = widget then begin
  deactivatehint;
  fhintedwidget:= nil;
 end;
 if fclientmousewidget = widget then begin
  fclientmousewidget:= nil;
 end;
 if fbuttonpresswidgetbefore = widget then begin
  fbuttonpresswidgetbefore:= nil;
 end;
 if fbuttonreleasewidgetbefore = widget then begin
  fbuttonreleasewidgetbefore:= nil;
 end;
end;

{ tapplication }

procedure tapplication.initialize;
begin
 with tinternalapplication(self) do begin
  if not (aps_inited in fstate) then begin
   fdesigning:= false;
   fstate:= [];
   guierror(gui_init,self);
   msetimer.init;
   msegraphics.init;
   include(fstate,aps_inited);
  end;
 end;
end;

procedure tapplication.deinitialize;
begin
 with tinternalapplication(self) do begin
  if aps_inited in fstate then begin
   if fcaret <> nil then begin
    fcaret.link(nil,nullpoint,nullrect);
   end;
   msegraphics.deinit;
   lock;
   gui_flushgdi;
   flusheventbuffer;
   getevents;
   feventlist.clear;
   unlock;
   gui_deinit;
   msetimer.deinit;
   exclude(fstate,aps_inited);
  end;
 end;
end;

procedure tapplication.run;
var
 threadbefore: threadty;
begin
 with tinternalapplication(self) do begin
  threadbefore:= fthread;
  fthread:= sys_getcurrentthread;
  include(fstate,aps_running);
  try
   eventloop(nil);
   fonterminatedlist.doterminated;
  finally
   fthread:= threadbefore;
   exclude(fstate,aps_running);
  end;
 end;
end;

function tapplication.getterminated: boolean;
begin
 result:= aps_terminated in fstate;
end;

procedure tapplication.setterminated(const Value: boolean);
begin
 if value then begin
  lock;
  include(fstate,aps_terminated);
  if not ismainthread then begin
   wakeupguithread;
  end;
  unlock;
 end;
end;

procedure tapplication.postevent(event: tevent);
begin
 if csdestroying in componentstate then begin
  event.free;
 end
 else begin
  if trylock then begin
   try
    tinternalapplication(self).flusheventbuffer;
    if feventlooping = 0 then begin
     guierror(gui_postevent(event),self);
    end
    else begin
     tinternalapplication(self).feventlist.add(event);
    end;
   except
    event.free;
    unlock;
    raise;
   end;
   unlock;
  end
  else begin
   with tinternalapplication(self) do begin
    sys_mutexlock(feventlock);
    setlength(fpostedevents,high(fpostedevents) + 2);
    fpostedevents[high(fpostedevents)]:= event;
    sys_mutexunlock(feventlock);
   end;
  end;
 end;
end;

procedure tapplication.wakeupguithread;
begin
 if aps_running in fstate then begin
  postevent(tevent.create(ek_wakeup));
 end;
end;

procedure tapplication.checkwindowrect(winid: winidty; var rect: rectty);
var
 window: twindow;
begin
 if findwindow(winid,window) then begin
  window.fowner.checkwidgetsize(rect.size);
 end;
end;

procedure tapplication.setclientmousewidget(const widget: twidget);
var
 info: mouseeventinfoty;
begin
 if fclientmousewidget <> widget then begin
  fillchar(info,sizeof(info),0);
  if (fclientmousewidget <> nil) and
             not (csdestroying in fclientmousewidget.componentstate) then begin
   info.eventkind:= ek_clientmouseleave;
   fclientmousewidget.mouseevent(info);
  end;
  fclientmousewidget:= widget;
  if widget <> nil then begin
   info.eventkind:= ek_clientmouseenter;
   widget.mouseevent(info);
  end;
 end;
end;

procedure tapplication.setmousewidget(const widget: twidget);
var
 info: mouseeventinfoty;
 widget1: twidget;
begin
 widget1:= fmousewidget;
 fmousewidget:= widget;
 if (fclientmousewidget <> nil) and (fclientmousewidget <> widget) then begin
  setclientmousewidget(nil);
 end;
 if widget1 <> widget then begin
  if (widget1 <> nil) and
              not (csdestroying in widget1.componentstate) then begin
   fillchar(info,sizeof(info),0);
   info.eventkind:= ek_mouseleave;
   widget1.mouseevent(info);
  end;
  if widget <> nil then begin
   finalize(info);
   fillchar(info,sizeof(info),0);
   info.eventkind:= ek_mouseenter;
   widget.mouseevent(info);
  end;
 end;
end;

function tapplication.grabpointer(const id: winidty): boolean;
var
 int1: integer;
 po1: pwindowaty;
begin
 po1:= pwindowaty(fwindows.datapo);
 for int1:= 0 to fwindows.count - 1 do begin
  with po1^[int1] do begin
   if fwinid <> id then begin
    exclude(fstate,tws_grab);
   end;
  end;
 end;
 {$ifdef nograbpointer}
 result:= true;
 {$else}
 result:= gui_grabpointer(id) = gue_ok;
 {$endif}
 if result then begin
  include(fstate,aps_mousecaptured);
 end
 else begin
  exclude(fstate,aps_mousecaptured);
 end;
end;

function tapplication.ungrabpointer: boolean;
var
 int1: integer;
 po1: pwindowaty;
begin
 result:= false;
 po1:= pwindowaty(fwindows.datapo);
 for int1:= 0 to fwindows.count - 1 do begin
  if tws_grab in po1^[int1].fstate then begin
   exit;
  end;
 end;
 gui_ungrabpointer;
 exclude(fstate,aps_mousecaptured);
 result:= true;
end;

procedure tapplication.capturemouse(sender: twidget; grab: boolean);
var
 widget: twidget;
 info: mouseeventinfoty;
begin
 if fmousecapturewidget <> sender then begin
  if fmousecapturewidget <> nil then begin
   widget:= fmousecapturewidget;
   fmousecapturewidget:= sender;
   fillchar(info,sizeof(info),0);
   info.eventkind:= ek_mousecaptureend;
   widget.mouseevent(info);
   if fmousecapturewidget <> sender then begin
    exit;
   end;
   widget.fwidgetstate:= widget.fwidgetstate -
          [ws_clicked,ws_mousecaptured,ws_clientmousecaptured];
  end
  else begin
   fmousecapturewidget:= sender;
  end;
  if fmousecapturewidget <> nil then begin
   if grab then begin
    grabpointer(fmousecapturewidget.window.winid);
   end;
   setmousewidget(fmousecapturewidget);
  end
  else begin
   ungrabpointer;
  end;
 end;
end;

procedure tapplication.createdatamodule(instanceclass: datamoduleclassty; var reference);
begin
 mseclasses.createmodule(self,instanceclass,reference);
end;

procedure tapplication.createform(instanceclass: widgetclassty; var reference);
begin
 mseclasses.createmodule(self,instanceclass,reference);
end;

function tapplication.dolock: boolean;
var
 athread: threadty;
begin
 inc(flockcount);
 athread:= sys_getcurrentthread;
 if not sys_issamethread(flockthread,athread) then begin
  result:= true;
  flockthread:= athread;
 end
 else begin
  result:= false;
 end;
end;

function tapplication.lock: boolean;
begin
 with tinternalapplication(self) do begin
  syserror(sys_mutexlock(fmutex));
 end;
 result:= dolock;
end;

function tapplication.trylock: boolean;
begin
 with tinternalapplication(self) do begin
  result:= sys_mutextrylock(fmutex) = sye_ok;
 end;
 if result then begin
  dolock;
 end;
end;

function tapplication.internalunlock(count: integer): boolean;
begin
 with tinternalapplication(self) do begin
  result:= sys_issamethread(flockthread,sys_getcurrentthread);
  if result then begin
   flusheventbuffer;
   while count > 0 do begin
    dec(count);
    dec(flockcount);
    if flockcount = 0 then begin
     flockthread:= 0;
    end;
    sys_mutexunlock(fmutex);
   end;
  end;
 end;
end;

function tapplication.unlock: boolean;
begin
 result:= internalunlock(1);
end;

function tapplication.unlockall: integer;
begin
 with tinternalapplication(self) do begin
  result:= flockcount;
  if not internalunlock(flockcount) then begin
   result:= 0;
  end;
 end;
end;

procedure tapplication.relockall(count: integer);
begin
 if count > 0 then begin
  lock;
  dec(count);
  while count > 0 do begin
   sys_mutexlock(tinternalapplication(self).fmutex);
  end;
 end;
end;

procedure tapplication.eventloop(const once: boolean = false);
             //used in win32 wm_queryendsession and wm_entersizemove
begin
 inc(feventlooping);
 try
  tinternalapplication(self).eventloop(nil,once);
 finally
  dec(feventlooping);
 end;
end;

procedure tapplication.exitloop;  //used in win32 cancelshutdown
begin
 include(fstate,aps_exitloop);
end;

procedure tapplication.synchronize(proc: objectprocty);
begin
 lock;
 try
  proc;
 finally
  unlock;
 end;
end;

procedure tapplication.waitforthread(athread: tmsethread);
         //does unlock-relock before waiting
var
 int1: integer;
begin
 int1:= unlockall;
 try
  athread.waitfor;
 finally
  relockall(int1);
 end;
end;

function tapplication.checkoverload(const asleepus: integer = 100000): boolean;
              //true if never idle since last call,
              // unlocks application and calls sleep if not mainthread and asleepus >= 0
var
 int1: integer;
begin
 result:= not (aps_waiting in fstate) and (fidlecount = 0);
 if result then begin
  fidlecount:= 0;
  if result and (asleepus >= 0) and not ismainthread then begin
   int1:= unlockall;
   repeat
    sleepus(asleepus);
   until fidlecount > 0;
   relockall(int1);
  end;
 end;
end;

procedure tapplication.invalidated;
begin
 if not (aps_invalidated in fstate) then begin
  wakeupguithread;
 end;
 include(fstate,aps_invalidated);
end;

procedure tapplication.showexception(e: exception; const leadingtext: string = '');
begin
 showmessage(leadingtext + e.Message,'Exception');
end;

procedure tapplication.handleexception(sender: tobject; const leadingtext: string = '');
begin
 if fexceptionactive = 0 then begin //do not handle subsequent exceptions
  if exceptobject is exception then begin
   inc(fexceptionactive);
   try
    if not (exceptobject is eabort) then begin
     if assigned(fonexception) then begin
      fonexception(sender, exception(exceptobject))
     end
     else begin
      showexception(exception(exceptobject),leadingtext);
     end;
    end
    else begin
     sysutils.showexception(exceptobject, exceptaddr);
    end;
   finally
    dec(fexceptionactive);
   end;
  end;
 end;
end;

function tapplication.ismainthread: boolean;
begin
 result:= sys_getcurrentthread = fthread;
end;

function tapplication.running: boolean;
begin
 result:= aps_running in fstate;
end;

function tapplication.findwindow(id: winidty; out window: twindow): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to fwindows.count - 1 do begin
  window:= twindow(fwindows[int1]);
  if window.fwinid = id then begin
   result:= true;
   exit;
  end;
 end;
 window:= nil;
end;

function tapplication.screensize: sizety;
begin
 result:= gui_getscreensize;
end;

function tapplication.workarea(awindow: twindow): rectty;
var
 id: winidty;
begin
 id:= 0;
 if awindow = nil then begin
  if factivewindow <> nil then begin
   id:= factivewindow.fwinid;
  end;
 end
 else begin
  id:= awindow.fwinid;
 end;
 result:= gui_getworkarea(id);
end;

function tapplication.activewindow: twindow;
begin
 result:= factivewindow;
end;

function tapplication.regularactivewindow: twindow;
begin
 result:= factivewindow;
 while (result <> nil) and (result.ftransientfor <> nil) do begin
  result:= result.ftransientfor;
 end;
end;

function tapplication.unreleasedactivewindow: twindow;
begin
 result:= factivewindow;
 while (result <> nil) and (ws1_releasing in result.fowner.fwidgetstate1) do begin
  result:= result.ftransientfor;
 end;
end;

function tapplication.activewidget: twidget;
begin
 if factivewindow <> nil then begin
  result:= factivewindow.ffocusedwidget;
 end
 else begin
  result:= nil;
 end;
end;

function tapplication.windowatpos(const pos: pointty): twindow;
var
 id: winidty;
begin
 id:= gui_windowatpos(pos);
 if id <> 0 then begin
  findwindow(id,result);
 end
 else begin
  result:= nil;
 end;
end;

function tapplication.findwidget(const namepath: string; out awidget: twidget): boolean;
                //false if invalid namepath, '' -> nil and true
                //last name = '' -> widget.container
var
 str1: string;
 bo1: boolean;
begin
 result:= true;
 awidget:= nil;
 if namepath <> '' then begin
  bo1:= namepath[length(namepath)] = '.';
  if bo1 then begin
   str1:= copy(namepath,1,length(namepath)-1);
  end
  else begin
   str1:= namepath;
  end;
  awidget:= twidget(findcomponentbynamepath(str1));
  if not (awidget is twidget) then begin
   result:= false;
   awidget:= nil;
  end
  else begin
   if bo1 then begin
    awidget:= awidget.container;
   end;
  end;
 end;
end;

function tapplication.windowar: windowarty;
begin
 if fwindows.count > 0 then begin
  setlength(result,fwindows.count);
  move(fwindows.datapo^,result[0],length(result)*sizeof(pointer));
 end
 else begin
  result:= nil;
 end;
end;

function tapplication.winidar: winidarty;
var
 ar1: windowarty;
 int1: integer;
begin
 ar1:= windowar;
 setlength(result,length(ar1));
 for int1:= 0 to high(ar1) do begin
  result[int1]:= ar1[int1].winid;
 end;
end;

function tapplication.getwindows(const index: integer): twindow;
begin
 result:= twindow(fwindows[index]);
end;

function tapplication.windowcount: integer;
begin
 result:= fwindows.count;
end;

function cmpwindowvisibility(const l,r): integer;
begin
 if tws_windowvisible in twindow(l).fstate then begin
  if tws_windowvisible in twindow(r).fstate then begin
   result:= 0;
  end
  else begin
   result:= 1;
  end;
 end
 else begin
  if tws_windowvisible in twindow(r).fstate then begin
   result:= -1;
  end
  else begin
   result:= 0;
  end
 end;
end;

procedure tapplication.sortzorder; //top is last, invisibles first
var
 ar1: winidarty;
 ar2,ar3: integerarty;
begin
 ar1:= nil; //compiler warning
 if not (aps_zordervalid in fstate) then begin
  ar1:= winidar;
  if high(ar1) >= 0 then begin
   gui_getzorder(ar1,ar2);
   sortarray(ar2,ar3);
   fwindows.order(ar3);
   fwindows.sort({$ifdef FPC}@{$endif}cmpwindowvisibility);
  end;
  include(fstate,aps_zordervalid);
 end;
end;

function tapplication.bottomwindow: twindow;
    //lowest visible window in stackorder, calls sortzorder
var
 int1: integer;
begin
 sortzorder;
 result:= nil;
 for int1:= 0 to windowcount-1 do begin
  if windows[int1].visible then begin
   result:= windows[int1];
   break;
  end;
 end;
end;

function tapplication.topwindow: twindow;
   //highest visible window in stackorder, calls sortzorder
var
 int1: integer;
begin
 sortzorder;
 result:= nil;
 for int1:= windowcount-1 downto 0 do begin
  if windows[int1].visible then begin
   result:= windows[int1];
   break;
  end;
 end;
end;

procedure tapplication.internalshowhint(const sender: twidget);
var
 window1: twindow;
begin
 with tinternalapplication(self),fhintinfo do begin
  if sender <> nil then begin
   window1:= sender.window;
  end
  else begin
   window1:= activewindow;
  end;
  fhintwidget:= thintwidget.create(nil,window1,fhintinfo);
  fhintwidget.show;
  if showtime <> 0 then begin
   fhinttimer.interval:= -showtime;
   fhinttimer.enabled:= true;
  end;
 end;
end;

procedure tapplication.inithintinfo(var info: hintinfoty; const ahintedwidget: twidget);
begin
 finalize(info);
 fillchar(info,sizeof(info),0);
 with info do begin
  flags:= defaulthintflags;
  if ow_timedhint in ahintedwidget.foptionswidget then begin
   showtime:= defaulthintshowtime;
  end
  else begin
   showtime:= 0;
  end;
  mouserefpos:= fmouse.pos;
  posrect.pos:= translateclientpoint(mouserefpos,nil,ahintedwidget);
  posrect.cx:= 24;
  posrect.cy:= 24;
  placement:= cp_bottomleft;
 end;
end;

procedure tapplication.showhint(const sender: twidget; const hint: msestring;
              const aposrect: rectty; const aplacement: captionposty = cp_bottomleft;
              const ashowtime: integer = defaulthintshowtime; //0 -> inifinite,
                 // -1 defaultshowtime if ow_timedhint in sender.optionswidget
              const aflags: hintflagsty = defaulthintflags
                      );
begin
 deactivatehint;
 if (sender = nil) or not sender.focused then begin
  fhintedwidget:= nil;
 end
 else begin
  fhintedwidget:= sender;
 end;
 with fhintinfo do begin
  mouserefpos:= fmouse.pos;
  flags:= {[hfl_custom] +} aflags;
  caption:= hint;
  if ashowtime < 0 then begin
   if ow_timedhint in sender.foptionswidget then begin
    showtime:= defaulthintshowtime;
   end
   else begin
    showtime:= 0;
   end;
  end
  else begin
   showtime:= ashowtime;
  end;
  posrect:= aposrect;
  if sender <> nil then begin
   translateclientpoint1(posrect.pos,sender,nil);
  end;
  placement:= aplacement;
 end;
 internalshowhint(sender);
end;

procedure tapplication.showhint(const sender: twidget; const hint: msestring;
              const apos: pointty;
              const ashowtime: integer = defaulthintshowtime; //0 -> inifinite,
                 // -1 defaultshowtime if ow_timedhint in sender.optionswidget
              const aflags: hintflagsty = defaulthintflags
                      );
begin
 showhint(sender,hint,makerect(apos,nullsize),cp_bottomleft,ashowtime,aflags);
end;

procedure tapplication.showhint(const sender: twidget; const info: hintinfoty);
begin
 with info do begin
  if (hfl_show in flags) or (caption <> '') then begin
   showhint(sender,caption,posrect,placement,showtime,flags);
  end;
 end;
end;

procedure tapplication.hidehint;
begin
 deactivatehint;
end;

function tapplication.hintedwidget: twidget;
begin
 result:= fhintedwidget;
end;

function tapplication.activehintedwidget: twidget;
begin
 if tinternalapplication(self).fhintwidget = nil then begin
  result:= nil;
 end
 else begin
  result:= fhintedwidget;
 end;
end;

function tapplication.helpcontext: msestring;
begin
 if activewidget = nil then begin
  result:= '';
 end
 else begin
  result:= activewidget.helpcontext;
 end;
end;

function tapplication.mousehelpcontext: msestring;
begin
 if mousewidget = nil then begin
  result:= '';
 end
 else begin
  result:= mousewidget.helpcontext;
 end;
end;

procedure tapplication.activatehint;
begin
 deactivatehint;
 if (fhintedwidget <> nil) and (factivewindow <> nil) then begin
  inithintinfo(fhintinfo,fhintedwidget);
  fhintedwidget.showhint(fhintinfo);
  with fhintinfo do begin
   if (hfl_show in flags) or (caption <> '') then begin
    translateclientpoint1(posrect.pos,fhintedwidget,nil);
    internalshowhint(fhintedwidget);
   end;
  end;
 end;
end;

procedure tapplication.deactivatehint;
begin
 with tinternalapplication(self) do begin
  freeandnil(fhintwidget);
  fhinttimer.enabled:= false;
  finalize(fhintinfo);
  fhintinfo.flags:= [];
 end;
end;

procedure tapplication.hinttimer(const sender: tobject);
begin
 with tinternalapplication(self) do begin
  if fhintwidget = nil then begin
   activatehint;
  end
  else begin
   deactivatehint;
  end;
 end;
end;

procedure tapplication.setmainwindow(const Value: twindow);
var
 int1: integer;
 id: winidty;
begin
 fmainwindow:= value;
 if value <> nil then begin
  if value.fowner.isgroupleader then begin
   id:= value.winid;
   for int1:= 0 to fwindows.count - 1 do begin
    with twindow(fwindows[int1]) do begin
     if fwinid <> 0 then begin
      gui_setwindowgroup(fwinid,id);
     end;
    end;
   end;
  end;
 end;
end;

procedure tapplication.mouseparkevent; //simulates mouseparkevent
begin
 if fmousewidget <> nil then begin
  fmousewidget.window.mouseparked;
 end;
end;

procedure tapplication.registeronterminated(const method: notifyeventty);
begin
 tinternalapplication(self).fonterminatedlist.add(tmethod(method));
end;

procedure tapplication.unregisteronterminated(const method: notifyeventty);
begin
 tinternalapplication(self).fonterminatedlist.remove(tmethod(method));
end;

procedure tapplication.registeronterminate(const method: terminatequeryeventty);
begin
 tinternalapplication(self).fonterminatequerylist.add(tmethod(method));
end;

procedure tapplication.unregisteronterminate(const method: terminatequeryeventty);
begin
 tinternalapplication(self).fonterminatequerylist.remove(tmethod(method));
end;

procedure tapplication.registeronidle(const method: idleeventty);
begin
 tinternalapplication(self).fonidlelist.add(tmethod(method));
end;

procedure tapplication.unregisteronidle(const method: idleeventty);
begin
 tinternalapplication(self).fonidlelist.remove(tmethod(method));
end;

procedure tapplication.registeronkeypress(const method: keyeventty);
begin
 tinternalapplication(self).fonkeypresslist.add(tmethod(method));
end;

procedure tapplication.unregisteronkeypress(const method: keyeventty);
begin
 tinternalapplication(self).fonkeypresslist.remove(tmethod(method));
end;

procedure tapplication.registeronshortcut(const method: keyeventty);
begin
 tinternalapplication(self).fonshortcutlist.add(tmethod(method));
end;

procedure tapplication.unregisteronshortcut(const method: keyeventty);
begin
 tinternalapplication(self).fonshortcutlist.remove(tmethod(method));
end;

procedure tapplication.registeronactivechanged(const method: activechangeeventty);
begin
 tinternalapplication(self).fonactivechangelist.add(tmethod(method));
end;

procedure tapplication.unregisteronactivechanged(const method: activechangeeventty);
begin
 tinternalapplication(self).fonactivechangelist.remove(tmethod(method));
end;

procedure tapplication.registeronwindowdestroyed(const method: windoweventty);
begin
 tinternalapplication(self).fonwindowdestroyedlist.add(tmethod(method));
end;

procedure tapplication.unregisteronwindowdestroyed(const method: windoweventty);
begin
 tinternalapplication(self).fonwindowdestroyedlist.remove(tmethod(method));
end;

procedure tapplication.registeronapplicationactivechanged(const method: booleaneventty);
begin
 tinternalapplication(self).fonapplicationactivechangedlist.add(tmethod(method));
end;

procedure tapplication.unregisteronapplicationactivechanged(const method: booleaneventty);
begin
 tinternalapplication(self).fonapplicationactivechangedlist.remove(tmethod(method));
end;

procedure tapplication.updatecursorshape; //restores cursorshape of mousewidget
begin
 if fclientmousewidget <> nil then begin
  fclientmousewidget.updatecursorshape(true);
 end
 else begin
  cursorshape:= cr_default;
 end;
end;

procedure tapplication.setcursorshape(const Value: cursorshapety);
begin
 fcursorshape:= Value; //wanted shape
 if not waiting then begin
  if fthread <> sys_getcurrentthread then begin
//   fcursorshape:= value;
   mouse.shape:= fcursorshape;
   //show new cursor immediately
  end;
 end;
// else begin
//  fcursorshape:= value;
   //show new cursor in  eventloop
// end;
end;

procedure tinternalapplication.checkcursorshape;
begin
// if facursorshape <> fcursorshape then begin
//  fcursorshape:= facursorshape;
  if not waiting then begin
   fmouse.shape:= fcursorshape;
  end;
// end;
end;

procedure tapplication.beginwait;
begin
 lock;
 try
  inc(fwaitcount);
  mouse.shape:= cr_wait;
 finally
  unlock;
 end;
end;

procedure tapplication.endwait;
begin
 lock;
 try
  if fwaitcount > 0 then begin
   dec(fwaitcount);
   if fwaitcount = 0 then begin
    tinternalapplication(self).checkcursorshape;
//    facursorshape:= fcursorshape;
//    mouse.shape:= fcursorshape;
   end;
  end;
 finally
  unlock;
 end;
end;

function tapplication.waiting: boolean;
begin
 result:= fwaitcount > 0;
end;

procedure tapplication.langchanged;
begin
 //todo: refresh widgets
end;

initialization
// app:= tapplication.create;
finalization
 app.Free;
 app:= nil;
end.
