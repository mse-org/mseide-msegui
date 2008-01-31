{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegui;

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$INTERFACES CORBA}{$endif}

interface

uses
 {$ifdef FPC}classes{$else}Classes{$endif},sysutils,msegraphics,msetypes,
 msestrings,mseerr,msegraphutils,mseapplication,
 msepointer,mseevent,msekeyboard,mseclasses,mseglob,mseguiglob,mselist,msesys,
 msethread,
 msebitmap,msearrayprops,mseguithread{,msedatamodules};

const
 mseguiversiontext = '1.7 unstable';
 
 defaultwidgetcolor = cl_default;
 defaulttoplevelwidgetcolor = cl_background;
 hintdelaytime = 500000; //us
 defaulthintshowtime = 3000000; //us
 mouseparktime = 500000; //us
 defaultdblclicktime = 400000; //us
 mindragdist = 4;

 mousebuttons = [ss_left,ss_right,ss_middle];

type
 optionwidgetty = (ow_background,ow_top,ow_noautosizing,{ow_nofocusrect,}
                   ow_mousefocus,ow_tabfocus,ow_parenttabfocus,ow_arrowfocus,
                   ow_arrowfocusin,ow_arrowfocusout,
                   ow_subfocus, //reflects focus to children
                   ow_focusbackonesc,
                   ow_nochildshortcut,  //do not propagate shortcuts to parent
                   ow_noparentshortcut, //do not react to shortcuts from parent
                   ow_canclosenil,      //canclose calls canclose(nil)
                   ow_mousetransparent,ow_mousewheel,ow_noscroll,ow_destroywidgets,
                   ow_hinton,ow_hintoff,ow_disabledhint,ow_multiplehint,
                   ow_timedhint,
                   ow_fontglyphheight, 
                   //track font.glyphheight, 
                   //create fonthighdelta and childscaled events
                   ow_fontlineheight, 
                   //track font.linespacing,
                   //create fonthighdelta and childscaled events
                   ow_autoscale, //synchronizes bounds_cy with fontheightdelta
                   ow_autosize,ow_autosizeanright,ow_autosizeanbottom
                                 //used in tbutton and tlabel
                   );
 optionswidgetty = set of optionwidgetty;

 optionskinty = (osk_noskin,osk_container);
 optionsskinty = set of optionskinty;
 
 anchorty = (an_left,an_top,an_right,an_bottom);
 anchorsty = set of anchorty;

 widgetstatety = (ws_visible,ws_enabled,
                  ws_active,ws_entered,ws_entering,ws_exiting,ws_focused,
                  ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,
//                  ws_wantmousewheel,
                  ws_wantmousefocus,ws_iswidget,
                  ws_opaque,ws_nopaint,
                  ws_clicked,ws_mousecaptured,ws_clientmousecaptured,
                  ws_loadlock,ws_loadedproc,ws_showproc,
                  ws_minclientsizevalid,
                  ws_showed,ws_hidden, //used in tcustomeventwidget
                  ws_destroying,
                  ws_staticframe,ws_staticface,
                  ws_isvisible
                 );
 widgetstatesty = set of widgetstatety;
 widgetstate1ty = ({ws1_releasing,}ws1_childscaled,ws1_fontheightlock,
                   ws1_widgetregionvalid,ws1_rootvalid,
                   ws1_anchorsizing,ws1_isstreamed,
                   ws1_scaled, //used in tcustomscalingwidget
                   ws1_noclipchildren,
                   ws1_nodesignvisible,ws1_nodesignframe,ws1_nodesignhandles,
                   ws1_nodesigndelete,ws1_designactive,
                   ws1_fakevisible,ws1_nominsize
                         //used for report size calculations
                   );
 widgetstates1ty = set of widgetstate1ty;

 framestatety = (fs_sbhorzon,fs_sbverton,fs_sbhorzfix,fs_sbvertfix,
                 fs_sbhorztop,fs_sbvertleft,
                 fs_sbleft,fs_sbtop,fs_sbright,fs_sbbottom,
                 fs_nowidget,fs_nosetinstance,fs_disabled,
                 fs_captiondistouter,fs_captionnoclip,
                 fs_drawfocusrect,fs_paintrectfocus,
                 fs_captionfocus,fs_captionhint,fs_rectsvalid,
                 fs_widgetactive,fs_paintposinited);
 framestatesty = set of framestatety;

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
 defaultwidgetstatesinvisible = [ws_enabled,ws_iswidget];
 focusstates = [ws_visible,ws_enabled];
 defaultoptionswidget = [ow_mousefocus,ow_tabfocus,ow_arrowfocus,{ow_mousewheel,}
                         ow_destroywidgets,ow_autoscale];
 defaultoptionswidgetmousewheel = defaultoptionswidget + [ow_mousewheel];
 defaultoptionswidgetnofocus = defaultoptionswidget -
             [ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 defaultoptionsskin = [];
 defaultcontainerskinoptions = defaultoptionsskin + [osk_container];
 
 defaultwidgetwidth = 50;
 defaultwidgetheight = 50;
 defaultanchors = [an_left,an_top];
 defaulthintflags = [];

type

 framelocalpropty = (frl_levelo,frl_leveli,frl_framewidth,{frl_extraspace,}
                     frl_colorframe,frl_colorframeactive,
                     frl_colordkshadow,frl_colorshadow,
                     frl_colorlight,frl_colorhighlight,
                     frl_colordkwidth,frl_colorhlwidth,
                     frl_fileft,frl_fitop,frl_firight,frl_fibottom,
                     frl_frameimagelist,frl_frameimageleft,frl_frameimagetop,
                     frl_frameimageright,frl_frameimagebottom,
                     frl_frameimageoffset,frl_frameimageoffsetmouse,
                     frl_frameimageoffsetclicked,frl_frameimageoffsetactive,
                     frl_frameimageoffsetactivemouse,
                     frl_frameimageoffsetactiveclicked,
                     frl_colorclient,
                     frl_nodisable);
 framelocalpropsty = set of framelocalpropty;

const
 allframelocalprops: framelocalpropsty =
                    [frl_levelo,frl_leveli,frl_framewidth,frl_colorframe,
                     frl_fileft,frl_fitop,frl_firight,frl_fibottom,
                     frl_frameimagelist,frl_frameimageleft,frl_frameimagetop,
                     frl_frameimageright,frl_frameimagebottom,
                     frl_frameimageoffset,frl_frameimageoffsetmouse,
                     frl_frameimageoffsetclicked,frl_frameimageoffsetactive,
                     frl_frameimageoffsetactivemouse,
                     frl_frameimageoffsetactiveclicked,
                     frl_colorclient];
type
 facelocalpropty = (fal_options,fal_fadirection,fal_image,fal_fapos,fal_facolor,
                    fal_fatransparency,fal_frameimagelist,fal_frameimageoffset);
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
  procedure setstaticframe(value: boolean);
  procedure scrollwidgets(const dist: pointty);
  procedure clientrectchanged;
  function getcomponentstate: tcomponentstate;
  procedure invalidate;
  procedure invalidatewidget;
  procedure invalidaterect(const rect: rectty; org: originty = org_client);
  function getwidget: twidget;
  function getwidgetrect: rectty;
  function getframeclicked: boolean;
  function getframemouse: boolean;
  function getframeactive: boolean;
 end;

 icaptionframe = interface(iframe)
  function getcanvas(aorigin: originty = org_client): tcanvas;
  function getframefont: tfont;
  procedure setwidgetrect(const rect: rectty);
 end;

 iscrollframe = interface(icaptionframe)
  function widgetstate: widgetstatesty;
 end;
  
 frameinfoty = record
  levelo: integer;
  leveli: integer;
  framewidth: integer;
//  extraspace: integer;
//  imagedist: integer;
  colorframe: colorty;
  colorframeactive: colorty;
  framecolors:framecolorinfoty;
  colorclient: colorty;
  innerframe: framety;

  frameimage_left: integer;
  frameimage_top: integer;
  frameimage_right: integer;
  frameimage_bottom: integer;
  frameimage_offset: integer;
  frameimage_offsetmouse: integer;
  frameimage_offsetclicked: integer;
  frameimage_offsetactive: integer;
  frameimage_offsetactivemouse: integer;
  frameimage_offsetactiveclicked: integer;

  frameimage_list: timagelist; //last!

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
   procedure setcolorframeactive(const avalue: colorty);
   function iscolorframeactivestored: boolean;
   procedure setcolordkshadow(const avalue: colorty);
   function iscolordkshadowstored: boolean;
   procedure setcolorshadow(const avalue: colorty);
   function iscolorshadowstored: boolean;
   procedure setcolorlight(const avalue: colorty);
   function iscolorlightstored: boolean;
   procedure setcolorhighlight(const avalue: colorty);
   function iscolorhighlightstored: boolean;
   procedure setcolordkwidth(const avalue: integer);
   function iscolordkwidthstored: boolean;
   procedure setcolorhlwidth(const avalue: integer);
   function iscolorhlwidthstored: boolean;
   
   procedure setframei_bottom(const Value: integer);
   function isfibottomstored: boolean;
   procedure setframei_left(const Value: integer);
   function isfileftstored: boolean;
   procedure setframei_right(const Value: integer);
   function isfirightstored: boolean;
   procedure setframei_top(const Value: integer);
   function isfitopstored: boolean;
   
   procedure setframeimage_list(const avalue: timagelist);
   function isframeimage_liststored: boolean;
   procedure setframeimage_left(const avalue: integer);
   function isframeimage_leftstored: boolean;
   procedure setframeimage_top(const avalue: integer);
   function isframeimage_topstored: boolean;
   procedure setframeimage_right(const avalue: integer);
   function isframeimage_rightstored: boolean;
   procedure setframeimage_bottom(const avalue: integer);
   function isframeimage_bottomstored: boolean;
   
   procedure setframeimage_offset(const avalue: integer);
   function isframeimage_offsetstored: boolean;
   procedure setframeimage_offsetmouse(const avalue: integer);
   function isframeimage_offsetmousestored: boolean;
   procedure setframeimage_offsetclicked(const avalue: integer);
   function isframeimage_offsetclickedstored: boolean;
   procedure setframeimage_offsetactive(const avalue: integer);
   function isframeimage_offsetactivestored: boolean;
   procedure setframeimage_offsetactivemouse(const avalue: integer);
   function isframeimage_offsetactivemousestored: boolean;
   procedure setframeimage_offsetactiveclicked(const avalue: integer);
   function isframeimage_offsetactiveclickedstored: boolean;
  
   procedure setcolorclient(const Value: colorty);
   function iscolorclientstored: boolean;
   procedure settemplate(const avalue: tframecomp);
   procedure setlocalprops(const avalue: framelocalpropsty);
  protected
   fintf: iframe;
   fstate: framestatesty;
   fwidth: framety;
   fouterframe: framety;
   fpaintframedelta: framety;
   fpaintframe: framety;
   finnerframe: framety;
   fpaintrect: rectty;
   fclientrect: rectty;          //origin = fpaintrect.pos
   finnerclientrect: rectty;     //origin = fpaintrect.pos
   fpaintposbefore: pointty;
   fi: frameinfoty;
   procedure setdisabled(const value: boolean); virtual;
   procedure updateclientrect; virtual;
   procedure calcrects;
   procedure updaterects; virtual;
   procedure internalupdatestate;
   procedure updatestate; virtual;
   procedure checkstate;
   procedure poschanged; virtual;
   procedure fontcanvaschanged; virtual;
   procedure visiblechanged; virtual;
   procedure getpaintframe(var frame: framety); virtual;
        //additional space, (scrollbars,mainmenu...)
   procedure dokeydown(var info: keyeventinfoty); virtual;
   function checkshortcut(var info: keyeventinfoty): boolean; virtual;
   procedure parentfontchanged; virtual;
   procedure dopaintfocusrect(const canvas: tcanvas; const rect: rectty); virtual;
   procedure updatewidgetstate; virtual;
   procedure updatemousestate(const sender: twidget; const apos: pointty); virtual;
   procedure activechanged; virtual;
   function needsfocuspaint: boolean; virtual;
  public
   constructor create(const intf: iframe); reintroduce;
   destructor destroy; override;
   procedure checktemplate(const sender: tobject); virtual;
   procedure assign(source: tpersistent); override;
   procedure scale(const ascale: real); virtual;

   procedure paintbackground(const canvas: tcanvas; const arect: rectty); virtual;
   procedure paintoverlay(const canvas: tcanvas; const arect: rectty); virtual;

   function outerframewidth: sizety; //widgetsize - framesize
   function frameframewidth: sizety; //widgetsize - (paintsize + paintframe)
   function paintframewidth: sizety; //widgetsize - paintsize
   function innerframewidth: sizety; //widgetsize - innersize
   function outerframe: framety;
   function paintframe: framety;     
   function innerframe: framety;     
   function cellframe: framety; //innerframe without painframedelta
   function pointincaption(const point: pointty): boolean; virtual;
                                     //origin = widgetrect
   procedure initgridframe; virtual;
   procedure changedirection(const oldvalue: graphicdirectionty;
                                            const newvalue: graphicdirectionty);

   property levelo: integer read fi.levelo write setlevelo
                     stored islevelostored default 0;
   property leveli: integer read fi.leveli write setleveli
                     stored islevelistored default 0;
   property framewidth: integer read fi.framewidth write setframewidth
                     stored isframewidthstored default 0;
   property colorframe: colorty read fi.colorframe write setcolorframe
                     stored iscolorframestored default cl_transparent;
   property colorframeactive: colorty read fi.colorframeactive 
                    write setcolorframeactive
                     stored iscolorframeactivestored default cl_default;

   property colordkshadow: colorty read fi.framecolors.shadow.effectcolor
              write setcolordkshadow
                     stored iscolordkshadowstored default cl_default;
   property colorshadow: colorty read fi.framecolors.shadow.color
              write setcolorshadow
                     stored iscolorshadowstored default cl_default;
   property colorlight: colorty read fi.framecolors.light.color
              write setcolorlight
                     stored iscolorlightstored default cl_default;
   property colorhighlight: colorty read fi.framecolors.light.effectcolor
              write setcolorhighlight
                     stored iscolorhighlightstored default cl_default;
   property colordkwidth: integer read fi.framecolors.shadow.effectwidth
              write setcolordkwidth
                     stored iscolordkwidthstored default -1;
   property colorhlwidth: integer read fi.framecolors.light.effectwidth
              write setcolorhlwidth
                     stored iscolorhlwidthstored default -1;
   property framei: framety read fi.innerframe;
   property framei_left: integer read fi.innerframe.left write setframei_left
                     stored isfileftstored default 0;
   property framei_top: integer read fi.innerframe.top  write setframei_top
                     stored isfitopstored default 0;
   property framei_right: integer read fi.innerframe.right write setframei_right
                     stored isfirightstored default 0;
   property framei_bottom: integer read fi.innerframe.bottom write setframei_bottom
                     stored isfibottomstored default 0;

   property frameimage_list: timagelist read fi.frameimage_list 
                    write setframeimage_list stored isframeimage_liststored;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_left: integer read fi.frameimage_left
                    write setframeimage_left stored isframeimage_leftstored;
   property frameimage_top: integer read fi.frameimage_top
                    write setframeimage_top stored isframeimage_topstored;
   property frameimage_right: integer read fi.frameimage_right
                    write setframeimage_right stored isframeimage_rightstored;
   property frameimage_bottom: integer read fi.frameimage_bottom
                    write setframeimage_bottom stored isframeimage_bottomstored;
                    //added to imagelist size.
   property frameimage_offset: integer read fi.frameimage_offset
                    write setframeimage_offset stored isframeimage_offsetstored;
   property frameimage_offsetmouse: integer read fi.frameimage_offsetmouse 
                    write setframeimage_offsetmouse 
                    stored isframeimage_offsetmousestored;
   property frameimage_offsetclicked: integer read fi.frameimage_offsetclicked
                    write setframeimage_offsetclicked 
                    stored isframeimage_offsetclickedstored;
   property frameimage_offsetactive: integer read fi.frameimage_offsetactive
                    write setframeimage_offsetactive
                    stored isframeimage_offsetactivestored;
   property frameimage_offsetactivemouse: integer read fi.frameimage_offsetactivemouse
                    write setframeimage_offsetactivemouse
                    stored isframeimage_offsetactivemousestored;
   property frameimage_offsetactiveclicked: integer read fi.frameimage_offsetactiveclicked
                    write setframeimage_offsetactiveclicked
                    stored isframeimage_offsetactiveclickedstored;

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

   property frameimage_list;
   property frameimage_left;
   property frameimage_right;
   property frameimage_top;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;

   property colorclient;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property localprops; //before template
   property template;
 end;

 tframetemplate = class(tpersistenttemplate)
  private
   procedure setcolorclient(const Value: colorty);
   procedure setcolorframe(const Value: colorty);
   procedure setcolorframeactive(const avalue: colorty);
   procedure setcolordkshadow(const avalue: colorty);
   procedure setcolorshadow(const avalue: colorty);
   procedure setcolorlight(const avalue: colorty);
   procedure setcolorhighlight(const avalue: colorty);
   procedure setcolordkwidth(const avalue: integer);
   procedure setcolorhlwidth(const avalue: integer);

   procedure setframei_bottom(const Value: integer);
   procedure setframei_left(const Value: integer);
   procedure setframei_right(const Value: integer);
   procedure setframei_top(const Value: integer);
   procedure setframewidth(const Value: integer);
   procedure setextraspace(const avalue: integer);
   procedure setimagedist(const avalue: integer);
   procedure setimagedisttop(const avalue: integer);
   procedure setimagedistbottom(const avalue: integer);
   procedure setleveli(const Value: integer);
   procedure setlevelo(const Value: integer);

   procedure setframeimage_list(const avalue: timagelist);
   procedure setframeimage_left(const avalue: integer);
   procedure setframeimage_top(const avalue: integer);
   procedure setframeimage_right(const avalue: integer);
   procedure setframeimage_bottom(const avalue: integer);
   procedure setframeimage_offset(const avalue: integer);
   procedure setframeimage_offsetmouse(const avalue: integer);
   procedure setframeimage_offsetclicked(const avalue: integer);
   procedure setframeimage_offsetactive(const avalue: integer);
   procedure setframeimage_offsetactivemouse(const avalue: integer);
   procedure setframeimage_offsetactiveclicked(const avalue: integer);

  protected
   fi: frameinfoty;
   fextraspace: integer;
   fimagedist: integer;
   fimagedisttop: integer;
   fimagedistbottom: integer;
   procedure doassignto(dest: tpersistent); override;
   function getinfosize: integer; override;
   function getinfoad: pointer; override;
   procedure copyinfo(const source: tpersistenttemplate); override;
  public
   constructor create(const owner: tmsecomponent;
                  const onchange: notifyeventty); override;
   procedure draw3dframe(const acanvas: tcanvas; const arect: rectty);
                                       //arect = paintrect
  published
   property levelo: integer read fi.levelo write setlevelo default 0;
   property leveli: integer read fi.leveli write setleveli default 0;
   property framewidth: integer read fi.framewidth
                     write setframewidth default 0;
   property colorframe: colorty read fi.colorframe 
                     write setcolorframe default cl_transparent;
   property colorframeactive: colorty read fi.colorframeactive 
                     write setcolorframeactive default cl_default;
   property framei_left: integer read fi.innerframe.left 
                     write setframei_left default 0;
   property framei_top: integer read fi.innerframe.top 
                     write setframei_top default 0;
   property framei_right: integer read fi.innerframe.right 
                     write setframei_right default 0;
   property framei_bottom: integer read fi.innerframe.bottom 
                     write setframei_bottom default 0;
                     
   property frameimage_list: timagelist read fi.frameimage_list
                     write setframeimage_list;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_left: integer read fi.frameimage_left
                    write setframeimage_left;
   property frameimage_top: integer read fi.frameimage_top
                    write setframeimage_top;
   property frameimage_right: integer read fi.frameimage_right
                    write setframeimage_right;
   property frameimage_bottom: integer read fi.frameimage_bottom
                    write setframeimage_bottom;
                    //added to imagelist size.
   property frameimage_offset: integer read fi.frameimage_offset
                     write setframeimage_offset;
   property frameimage_offsetmouse: integer read fi.frameimage_offsetmouse 
                     write setframeimage_offsetmouse;
   property frameimage_offsetclicked: integer read fi.frameimage_offsetclicked
                     write setframeimage_offsetclicked;
   property frameimage_offsetactive: integer read fi.frameimage_offsetactive
                     write setframeimage_offsetactive;
   property frameimage_offsetactivemouse: integer 
                     read fi.frameimage_offsetactivemouse
                     write setframeimage_offsetactivemouse;
   property frameimage_offsetactiveclicked: integer 
                     read fi.frameimage_offsetactiveclicked
                     write setframeimage_offsetactiveclicked;

   property extraspace: integer read fextraspace
                        write setextraspace default 0;
   property imagedist: integer read fimagedist
                        write setimagedist default 0;
   property imagedisttop: integer read fimagedisttop
                        write setimagedisttop default 0;
   property imagedistbottom: integer read fimagedistbottom
                        write setimagedistbottom default 0;
   property colorclient: colorty read fi.colorclient write setcolorclient 
                                            default cl_transparent;
   property colordkshadow: colorty read fi.framecolors.shadow.effectcolor
                     write setcolordkshadow default cl_default;
   property colorshadow: colorty read fi.framecolors.shadow.color
                       write setcolorshadow default cl_default;
   property colorlight: colorty read fi.framecolors.light.color
                        write setcolorlight default cl_default;
   property colorhighlight: colorty read fi.framecolors.light.effectcolor
                    write setcolorhighlight default cl_default;
   property colordkwidth: integer read fi.framecolors.shadow.effectwidth
                      write setcolordkwidth default -1;
   property colorhlwidth: integer read fi.framecolors.light.effectwidth
                      write setcolorhlwidth default -1;
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

 tcustomface = class;
 iface = interface(inullinterface)
  function getwidget: twidget;
  function translatecolor(const acolor: colorty): colorty;
 end;

 faceoptionty = (fao_alphafadeimage,fao_alphafadenochildren,fao_alphafadeall);
 faceoptionsty = set of faceoptionty;

 faceinfoty = record
  frameimage_offset: integer;
  options: faceoptionsty;

  frameimage_list: timagelist;
  fade_direction: graphicdirectionty;
  image: tmaskedbitmap;
  fade_pos: trealarrayprop;
  fade_color: tcolorarrayprop;
  fade_transparency: colorty;
 end;

 tfacecomp = class;
 tcustomface = class(toptionalpersistent)
  private
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
   procedure setfade_transparency(avalue: colorty);
   function isfatransparencystored: boolean;
   procedure setframeimage_list(const avalue: timagelist);
   function isframeimage_liststored: boolean;
   procedure setframeimage_offset(const avalue: integer);
   function isframeimage_offsetstored: boolean;
   procedure settemplate(const avalue: tfacecomp);
   procedure setlocalprops(const avalue: facelocalpropsty);
  protected
   fintf: iface;
   fi: faceinfoty;
   procedure dochange(const sender: tarrayprop; const index: integer);
   procedure change;
   procedure imagechanged(const sender: tobject);
   procedure internalcreate; override;
   procedure doalphablend(const canvas: tcanvas);
  public
   constructor create; overload; override;
   constructor create(const owner: twidget); reintroduce; overload;//sets fowner.fframe
   constructor create(const intf: iface); reintroduce; overload;
   destructor destroy; override;
   procedure checktemplate(const sender: tobject);
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

   property frameimage_list: timagelist read fi.frameimage_list 
                     write setframeimage_list stored isframeimage_liststored;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_offset: integer read fi.frameimage_offset
                     write setframeimage_offset stored isframeimage_offsetstored;

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
   property frameimage_list;
   property frameimage_offset;
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
   procedure setfade_transparency(avalue: colorty);
   procedure setimage(const Value: tmaskedbitmap);
   procedure doimagechange(const sender: tobject);
   procedure dochange(const sender: tarrayprop; const index: integer);
   procedure setframeimage_list(const avalue: timagelist);
   procedure setframeimage_offset(const avalue: integer);
  protected
   procedure doassignto(dest: tpersistent); override;
   function getinfosize: integer; override;
   function getinfoad: pointer; override;
   procedure copyinfo(const source: tpersistenttemplate); override;
   procedure internalcreate; override;
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

   property frameimage_list: timagelist read fi.frameimage_list 
                     write setframeimage_list;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_offset: integer read fi.frameimage_offset
                     write setframeimage_offset;
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
 mousewheeleventty = procedure (const sender: twidget; var info: mousewheeleventinfoty) of object;
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

 windowposty = (wp_normal,wp_screencentered,wp_minimized,wp_maximized,wp_default,
                wp_fullscreen);

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
 widgetfontclassty = class of twidgetfont;
 
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
  pos: pointty;           //origin = clientrect.pos
  pickpos: pointty;       //origin = screenorigin
  clientpickpos: pointty; //origin = clientrect.pos
  dragobjectpo: pdragobject;
  accept: boolean;
 end;

 twidgetevent = class(tcomponentevent)
 end;

 widgetalignmodety = (wam_start,wam_center,wam_end);
 widgetclassty = class of twidget;
 
 twidget = class(tactcomponent,iscrollframe,iface)
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

   foptionsskin: optionsskinty;
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

   procedure widgetregioninvalid;
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
   procedure parentfontchanged;
   procedure setanchors(const Value: anchorsty);

   function getzorder: integer;
   procedure setzorder(const value: integer);

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
   procedure setoptionsskin(const avalue: optionsskinty);
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
   class function classskininfo: skininfoty; override;
   function skininfo: skininfoty; override;

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
   function updateopaque(const children: boolean): boolean;
                   //true if widgetregionchanged called

   //idragcontroller
   function getdragrect(const apos: pointty): rectty; virtual;
   //iface
   //iframe
   procedure setframeinstance(instance: tcustomframe); virtual;
   procedure setstaticframe(value: boolean);
   function getwidgetrect: rectty;
   function getcomponentstate: tcomponentstate;
   
   function getframeclicked: boolean; virtual;
   function getframemouse: boolean; virtual;
   function getframeactive: boolean; virtual;
   
   //igridcomp,itabwidget
   function getwidget: twidget;

   function getframe: tcustomframe;
   procedure setframe(const avalue: tcustomframe);
   function getface: tcustomface;
   procedure setface(const avalue: tcustomface);
//   function getinnerstframe: framety; virtual;

   procedure createwindow; virtual;
   procedure objectchanged(const sender: tobject); virtual;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure setchildorder(child: tcomponent; order: integer); override;
   procedure setparentcomponent(value: tcomponent); override;
   function clearparentwidget: twidget;
             //returns old parentwidget
   procedure setparentwidget(const Value: twidget); virtual;
   procedure setlockedparentwidget(const avalue: twidget);
            //sets ws_loadlock before setting, restores afterwards
   procedure updatewindowinfo(var info: windowinfoty); virtual;
   procedure windowcreated; virtual;
   procedure setoptionswidget(const avalue: optionswidgetty); virtual;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;

   function getcaretcliprect: rectty; virtual;  //origin = clientrect.pos
   procedure beginread; override;
   procedure doendread; override;
   procedure loaded; override;

   procedure updatemousestate(const apos: pointty); virtual;
                                   //updates fstate about mouseposition
   procedure setclientclick; //grabs mouse and sets clickflags

   procedure registerchildwidget(const child: twidget); virtual;
   procedure unregisterchildwidget(const child: twidget); virtual;
   function isfontstored: Boolean;
   procedure setfont(const avalue: twidgetfont);
   function getfont: twidgetfont;
   function getfont1: twidgetfont; //no getoptionalobject
   function getframefont: tfont;
   procedure fontchanged; virtual;
   procedure fontcanvaschanged; virtual;

   procedure parentclientrectchanged; virtual;
   procedure parentwidgetregionchanged(const sender: twidget); virtual;
   procedure widgetregionchanged(const sender: twidget); virtual;
   procedure statechanged; virtual; //enabled,active,visible
   procedure enabledchanged; virtual;
   procedure activechanged; virtual;
   procedure visiblepropchanged; virtual;
   procedure visiblechanged; virtual;
   procedure colorchanged; virtual;
   procedure sizechanged; virtual;
   procedure getautopaintsize(var asize: sizety); virtual;
   procedure checkautosize;
   procedure poschanged; virtual;
   procedure clientrectchanged; virtual;
   procedure parentchanged; virtual;
   procedure rootchanged; virtual;
   function getdefaultfocuschild: twidget; virtual;
                                   //returns first focusable widget
   procedure setdefaultfocuschild(const value: twidget); virtual;
   procedure sortzorder;
   procedure clampinview(const arect: rectty; const bottomright: boolean); virtual;
                    //origin paintpos

   function needsdesignframe: boolean; virtual;
   function getactface: tcustomface; virtual;
   procedure dobeforepaint(const canvas: tcanvas); virtual;
   procedure dopaintbackground(const canvas: tcanvas); virtual;
   procedure dopaint(const canvas: tcanvas); virtual;
   procedure dobeforepaintforeground(const canvas: tcanvas); virtual;
   procedure doonpaint(const canvas: tcanvas); virtual;
   procedure dopaintoverlay(const canvas: tcanvas); virtual;
   procedure doafterpaint(const canvas: tcanvas); virtual;

   procedure doscroll(const dist: pointty); virtual;

   procedure doloaded; virtual;
   procedure dohide; virtual;
   procedure doshow; virtual;
   procedure doactivate; virtual;
   procedure dodeactivate; virtual;
   procedure doenter; virtual;
   procedure doexit; virtual;
   procedure dofocus; virtual;
   procedure dodefocus; virtual;
   procedure dochildfocused(const sender: twidget); virtual;
   procedure dofocuschanged(const oldwidget,newwidget: twidget); virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty); virtual;

   procedure reflectmouseevent(var info: mouseeventinfoty);
                                  //posts mousevent to window under mouse
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); virtual;
   procedure childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty); virtual;
   procedure mousewheelevent(var info: mousewheeleventinfoty); virtual;

   procedure dokeydown(var info: keyeventinfoty); virtual;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); virtual;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; virtual;
   procedure dokeydownaftershortcut(var info: keyeventinfoty); virtual;
   procedure dokeyup(var info: keyeventinfoty); virtual;

   procedure dofontchanged(const sender: tobject);
   procedure setfontheight;
   procedure postchildscaled;
   procedure dofontheightdelta(var delta: integer); virtual;
   procedure syncsinglelinefontheight(const lineheight: boolean = false);

   procedure setwidgetrect(const Value: rectty);
   procedure internalsetwidgetrect(Value: rectty; const windowevent: boolean);
   function getclientpos: pointty;              
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

   function getmintopleft: pointty; virtual;
   function calcminscrollsize: sizety; virtual;
   function getcontainer: twidget; virtual;
   function getchildwidgets(const index: integer): twidget; virtual;
   function gettaborderedwidgets: widgetarty;

   function getright: integer;       //if placed in datamodule
   procedure setright(const avalue: integer);
   function getbottom: integer;
   procedure setbottom(const avalue: integer);
   function ownswindow1: boolean;    //does not check winid

   procedure internalcreateframe; virtual;
   procedure internalcreateface; virtual;
   function getfontclass: widgetfontclassty; virtual;
   procedure internalcreatefont; virtual;
   
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure afterconstruction; override;
   procedure initnewcomponent(const ascale: real); override;
                     //called before inserting in parentwidget
   procedure initnewwidget(const ascale: real); virtual;
                     //called after inserting in parentwidget
   procedure createframe;
   procedure createface;
   procedure createfont;

   function isloading: boolean;      //checks ws_loadlock and csdestroing too
   function widgetstate: widgetstatesty;                 //iframe
   property widgetstate1: widgetstates1ty read fwidgetstate1;
   function hasparent: boolean; override;               //tcomponent
   function getparentcomponent: tcomponent; override;   //tcomponent
   function hascaret: boolean;
   function ownswindow: boolean;
                      //true if valid toplevelwindow with assigned winid
   function updaterect: rectty; //invalidated area, origin = clientpos

   function canclose(const newfocus: twidget = nil): boolean; virtual;
   function canparentclose(const newfocus: twidget): boolean; overload;
                   //window.focusedwidget is first checked of it is descendant
   function canparentclose: boolean; overload;
                   //newfocus = window.focusedwidget      
   function canfocus: boolean; virtual;
   function setfocus(aactivate: boolean = true): boolean; virtual;//true if ok
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
   function backgroundcolor: colorty;
   function translatecolor(const acolor: colorty): colorty;

   procedure widgetevent(const event: twidgetevent); virtual;
   procedure sendwidgetevent(const event: twidgetevent);
                              //event will be destroyed

   procedure release; override;
   function show(const modal: boolean = false;
            const transientfor: twindow = nil): modalresultty; virtual;
   procedure hide;
   procedure activate(const abringtofront: boolean = true); virtual;
                             //show and setfocus
   procedure bringtofront;
   procedure sendtoback;
   procedure stackunder(const predecessor: twidget);

   procedure paint(const canvas: tcanvas); virtual;
   procedure update; virtual;
   procedure updatecursorshape(force: boolean = false);
   procedure scrollwidgets(const dist: pointty);
   procedure scrollrect(const dist: pointty; const rect: rectty; scrollcaret: boolean);
                             //origin = paintrect.pos
   procedure scroll(const dist: pointty);
                            //scrolls paintrect and widgets
   procedure getcaret;
   procedure scrollcaret(const dist: pointty);
   function mousecaptured: boolean;
   procedure capturemouse(grab: boolean = true);
   procedure releasemouse;
   procedure capturekeyboard;
   procedure releasekeyboard;
   procedure synctofontheight; virtual;

   procedure dragevent(var info: draginfoty); virtual;
   procedure dochildscaled(const sender: twidget); virtual;

   procedure invalidatewidget;     //invalidates whole widget
   procedure invalidate;           //invalidates clientrect
   procedure invalidaterect(const rect: rectty; org: originty = org_client);
   procedure invalidateframestate;
   procedure invalidateframestaterect(const rect: rectty; 
                                        const org: originty = org_client);   
   function hasoverlappingsiblings(arect: rectty): boolean; //origin = pos
//   procedure invalidatesiblings(arect: rectty); //origin = pos


   function window: twindow;
   function rootwidget: twidget;
   function parentofcontainer: twidget;
            //parentwidget.parentwidget if parentwidget has not ws_iswidget,
            //parentwidget otherwise
   property parentwidget: twidget read fparentwidget write setparentwidget;
   function getrootwidgetpath: widgetarty; //root widget is last
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
   function containeroffset: pointty;
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

   function iswidgetclick(const info: mouseeventinfoty; const caption: boolean = false): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
   //or in frame.caption if caption = true, origin = pos
   function isclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
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
   procedure scale(const ascale: real); virtual;

   property widgetrect: rectty read getwidgetrect write setwidgetrect;
   property pos: pointty read fwidgetrect.pos write setpos;
   property size: sizety read fwidgetrect.size write setsize;
   property minsize: sizety read fminsize write setminsize;
   property maxsize: sizety read fmaxsize write setmaxsize;
   function maxclientsize: sizety; virtual;
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
   function innerframewidth: sizety;         //clientrect.size - innerclientrect.size  
   function framerect: rectty;               //origin = pos
   function framepos: pointty;               //origin = pos
   function framesize: sizety;
   function paintrect: rectty;               //origin = pos
   function paintpos: pointty;               //origin = pos
   function paintsize: sizety;
   function clippedpaintrect: rectty;        //origin = pos, 
                                             //clipped by all parentpaintrects
   function innerpaintrect: rectty;          //origin = pos

   function widgetsizerect: rectty;          //pos = nullpoint
   function clientrect: rectty;              //origin = paintrect.pos
   procedure changeclientsize(const delta: sizety); //asynchronous
   property clientsize: sizety read getclientsize write setclientsize;
   property clientwidth: integer read getclientwidth write setclientwidth;
   property clientheight: integer read getclientheight write setclientheight;
   property clientpos: pointty read getclientpos; //origin = paintrect.pos;
   function clientwidgetrect: rectty;        //origin = pos
   function clientwidgetpos: pointty;        //origin = pos
   function clientparentpos: pointty;        //origin = parentwidget.pos
   property parentclientpos: pointty read getparentclientpos write setparentclientpos;
                                             //origin = parentwidget.clientpos
   function paintparentpos: pointty;         //origin = parentwidget.pos
   function paintrectparent: rectty;         //origin = paintpos,
                                             //nullrect if parent = nil,
   function clientrectparent: rectty;        //origin = paintpos,
                                             //nullrect if parent = nil,
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
   function activeentered: boolean; 
     //true if entered and window is regularactivewindow or inactivated
   function focused: boolean;
   function clicked: boolean;

   function indexofwidget(const awidget: twidget): integer;

   procedure changedirection(const avalue: graphicdirectionty;
                                            var dest: graphicdirectionty); virtual;
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

   property optionswidget: optionswidgetty read foptionswidget 
                 write setoptionswidget default defaultoptionswidget;
   property optionsskin: optionsskinty read foptionsskin 
                                            write setoptionsskin default [];
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
                  tws_grab,tws_painting,tws_activatelocked,
                  tws_canvasoverride);
 windowstatesty = set of windowstatety;

 internalwindowoptionsty = record
  parent: winidty;
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

 windowsizety = (wsi_normal,wsi_minimized,wsi_maximized,wsi_fullscreen);

 windowty = record
  id: winidty;
  platformdata: array[0..7] of pointer;
 end;
 
 twindow = class(teventobject,icanvas)
  private
   fstate: windowstatesty;
   ffocuscount: cardinal; //for recursive setwidgetfocus
   factivecount: cardinal; //for recursive activate,deactivate
   fmoving: integer;
   ffocusedwidget: twidget;
   fmodalinfopo: pmodalinfoty;
   foptions: windowoptionsty;
   ftransientfor: twindow;
   ftransientforcount: integer;
   fwindowpos: windowposty;
   fnormalwindowrect: rectty;
   fcaption: msestring;
   fscrollnotifylist: tnotifylist;
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
   procedure deactivate;
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
   procedure setfocusedwidget(widget: twidget);
   procedure setmodalresult(const Value: modalresultty);
   function getglobalshortcuts: boolean;
   function getlocalshortcuts: boolean;
   procedure setglobalshortcuts(const Value: boolean);
   procedure setlocalshortcuts(const Value: boolean);
   function getbuttonendmodal: boolean;
   procedure setbuttonendmodal(const value: boolean);
  protected
   fwindow: windowty;
   fowner: twidget;
   fcanvas: tcanvas;
   fasynccanvas: tcanvas;
   fmodalresult: modalresultty;
   fupdateregion: regionty;
   procedure setasynccanvas(const acanvas: tcanvas);
           //used from treport
   procedure releaseasynccanvas;
   
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
   procedure noactivewidget;
   procedure lockactivate;
   procedure unlockactivate;
   procedure setzorder(const value: integer);
  public
   constructor create(aowner: twidget);
   destructor destroy; override;
   procedure registeronscroll(const method: notifyeventty);
   procedure unregisteronscroll(const method: notifyeventty);
   
   function beginmodal: boolean; //true if window destroyed
   procedure endmodal;
   procedure activate;
   function active: boolean;
   function deactivateintermediate: boolean; 
      //true if ok, sets app.finactivewindow
   procedure reactivate; //clears app.finactivewindow
   procedure update;
   function candefocus: boolean;
   procedure nofocus;
   property focuscount: cardinal read ffocuscount;
   function close: boolean; //true if ok
   procedure beginmoving; //lock window rect modification
   procedure endmoving;
   procedure bringtofront;
   procedure sendtoback;
   procedure stackunder(const predecessor: twindow);
       //stacking is performed in mainloop idle, nil means top
   procedure stackover(const predecessor: twindow);
       //stacking is performed in mainloop idle, nil means bottom
   function stackedunder: twindow; //nil if top
   function stackedover: twindow;  //nil if bottom
   function hastransientfor: boolean;

   procedure capturemouse;
   procedure releasemouse;
   procedure postkeyevent(const akey: keyty; 
        const ashiftstate: shiftstatesty = []; const release: boolean = false;
                  const achars: msestring = '');

   function winid: winidty;
   function haswinid: boolean;
   function state: windowstatesty;
   function visible: boolean;
   function normalwindowrect: rectty;
   property updateregion: regionty read fupdateregion;
   function updaterect: rectty;

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
 focuschangeeventty = procedure(const oldwidget,newwidget: twidget) of object;
 windoweventty = procedure(const awindow: twindow) of object;
 winideventty = procedure(const awinid: winidty) of object;
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
   fwheel: mousewheelty;
   fshiftstate: shiftstatesty;
   freflected: boolean;
   property timestamp: cardinal read ftimestamp; //0 -> invalid
   constructor create(const winid: winidty; const release: boolean;
                      const button: mousebuttonty; const wheel: mousewheelty;
                      const pos: pointty; const shiftstate: shiftstatesty;
                      atimestamp: cardinal; const reflected: boolean = false);
                      //button = none for mousemove
 end;

 tmouseenterevent = class(tmouseevent)
  public
   constructor create(const winid: winidty; const pos: pointty;
                      const shiftstate: shiftstatesty; atimestamp: cardinal);
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

 tguiapplication = class(tcustomapplication)
  private
   finiting: integer;
   fwindows: windowarty;
   factivewindow: twindow;
   fwantedactivewindow: twindow; //set by twindow.activate if modal
   finactivewindow: twindow;
   ffocuslockwindow: twindow;
   ffocuslocktransientfor: twindow;
   fmouse: tmouse;
   fcaret: tcaret;
   fmousecapturewidget: twidget;
   fmousewidget: twidget;
   fmousehintwidget: twidget;
   fkeyboardcapturewidget: twidget;
   fclientmousewidget: twidget;
   fhintedwidget: twidget;
   fhintforwidget: twidget;
   fhintinfo: hintinfoty;
   fmainwindow: twindow;
   fdblclicktime: integer;
   fcursorshape: cursorshapety;
//   facursorshape: cursorshapety;
   fbuttonpresswidgetbefore: twidget;
   fbuttonreleasewidgetbefore: twidget;
   factmousewindow: twindow;
   fdelayedmouseshift: pointty;
   fmodalwindowbeforewaitdialog: twindow;
   fonterminatebefore: threadcompeventty;
   fexecuteaction: notifyeventty;
   feventlooping: integer;
   procedure invalidated;
   function grabpointer(const id: winidty): boolean;
   function ungrabpointer: boolean;
   procedure setmousewidget(const widget: twidget);
   procedure setclientmousewidget(const widget: twidget);
   procedure capturemouse(sender: twidget; grab: boolean);
               //sender = nil for release
   procedure activatehint;
   procedure deactivatehint;
   procedure hinttimer(const sender: tobject);
   procedure internalshowhint(const sender: twidget);
   procedure setmainwindow(const Value: twindow);
   procedure setcursorshape(const Value: cursorshapety);
   function getwindows(const index: integer): twindow;
   procedure destroyforms;
   procedure dothreadterminated(const sender: tthreadcomp);
   procedure dowaitidle(var again: boolean);
  protected  
   procedure dopostevent(const aevent: tevent); override;
   procedure eventloop(const once: boolean = false);
                        //used in win32 wm_queryendsession and wm_entersizemove
   procedure exitloop;  //used in win32 cancelshutdown
   procedure receiveevent(const event: tobjectevent); override;
   procedure doafterrun; override;
  public
   procedure langchanged; override;
   procedure settimer(const us: integer); override;
   function findwindow(id: winidty; out window: twindow): boolean;
   procedure checkwindowrect(winid: winidty; var rect: rectty);
               //callback from win32 wm_sizing
   procedure initialize;
   procedure deinitialize;

   procedure createform(instanceclass: widgetclassty; var reference);
   procedure invalidate; //invalidates all registered forms
   
   procedure processmessages; override; //handle with care!
   function idle: boolean; override;
   
   procedure beginwait; override;
   procedure endwait; override;
   function waiting: boolean;
   function waitescaped: boolean; //true if escape pressed while waiting

   procedure resetwaitdialog;   
   function waitdialog(const athread: tthreadcomp = nil; const atext: msestring = '';
                   const caption: msestring = '';
                   const acancelaction: notifyeventty = nil;
                   const aexecuteaction: notifyeventty = nil): boolean; override;
              //true if not canceled
   procedure terminatewait;
   procedure cancelwait;
   function waitstarted: boolean;
   function waitcanceled: boolean;
   function waitterminated: boolean;   

   procedure showexception(e: exception; const leadingtext: string = ''); override;
   procedure showasyncexception(e: exception; const leadingtext: string = '');
                //messege posted in queue
   procedure errormessage(const amessage: msestring); override;
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
   procedure restarthint(const sender: twidget);
   function hintedwidget: twidget; //last hinted widget
   function activehintedwidget: twidget; //nil if no hint active
   
   function activehelpcontext: msestring;
                //returns helpcontext of active widget, '' if none;
   function mousehelpcontext: msestring;
                //returns helpcontext of mouse widget, '' if none;
   function active: boolean;
   function screensize: sizety;
   function workarea(const awindow: twindow = nil): rectty;
                          //nil -> current active window
   function activewindow: twindow;
   function regularactivewindow: twindow;
   function unreleasedactivewindow: twindow;
   function activewidget: twidget;
   function activerootwidget: twidget;
   
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
   function candefocus: boolean;
      //checks candefocus of all windows

   procedure registeronkeypress(const method: keyeventty);
   procedure unregisteronkeypress(const method: keyeventty);
   procedure registeronshortcut(const method: keyeventty);
   procedure unregisteronshortcut(const method: keyeventty);
   procedure registeronactivechanged(const method: activechangeeventty);
   procedure unregisteronactivechanged(const method: activechangeeventty);
   procedure registeronwindowdestroyed(const method: windoweventty);
   procedure unregisteronwindowdestroyed(const method: windoweventty);
   procedure registeronwiniddestroyed(const method: winideventty);
   procedure unregisteronwiniddestroyed(const method: winideventty);
   procedure registeronapplicationactivechanged(const method: booleaneventty);
   procedure unregisteronapplicationactivechanged(const method: booleaneventty);

   procedure terminate(const sender: twindow = nil); 
        //calls canclose of all windows except sender and terminatequery
   function terminating: boolean;
   function deinitializing: boolean;
   property caret: tcaret read fcaret;
   property mouse: tmouse read fmouse;
   procedure mouseparkevent; //simulates mouseparkevent
   procedure delayedmouseshift(const ashift: pointty);
   property cursorshape: cursorshapety read fcursorshape write setcursorshape;
   procedure updatecursorshape; //restores cursorshape of mousewidget
   property mousewidget: twidget read fmousewidget;
   property mousecapturewidget: twidget read fmousecapturewidget;
   property mainwindow: twindow read fmainwindow write setmainwindow;
   property thread: threadty read fthread;

   property buttonpresswidgetbefore: twidget read fbuttonpresswidgetbefore;
   property buttonreleasewidgetbefore: twidget read fbuttonreleasewidgetbefore;
   property dblclicktime: integer read fdblclicktime write fdblclicktime default
                 defaultdblclicktime; //us
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

procedure sortwidgetsxorder(var awidgets: widgetarty; const parent: twidget = nil);
procedure sortwidgetsyorder(var awidgets: widgetarty; const parent: twidget = nil);

procedure syncmaxautosize(const widgets: array of twidget);
procedure syncminframewidth(const awidth: integer; const awidgets: array of twidget);

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

function application: tguiapplication;
function mousebuttontoshiftstate(button: mousebuttonty): shiftstatesty;

procedure beep;
procedure enablewidgets(awidgets: array of twidget);
procedure disablewidgets(awidgets: array of twidget);
procedure showwidgets(awidgets: array of twidget);
procedure hidewidgets(awidgets: array of twidget);
function showmodalwidget(const aclass: widgetclassty): modalresultty;


procedure writewidgetnames(const writer: twriter; const ar: widgetarty);
function needswidgetnamewriting(const ar: widgetarty): boolean;

procedure designeventloop;
procedure freedesigncomponent(const acomponent: tcomponent);

function getprocesswindow(const procid: integer): winidty;
function activateprocesswindow(const procid: integer; 
                    const araise: boolean = true): boolean;
         //true if ok

implementation

uses
 mseguiintf,msesysintf,typinfo,msestreaming,msetimer,msebits,msewidgets,
 mseshapes,msestockobjects,msefileutils,msedatalist,Math,msesysutils,
 {$ifdef FPCc} rtlconst {$else} RtlConsts{$endif},mseformatstr,
 mseprocutils;

const
 faceoptionsmask: faceoptionsty = [fao_alphafadeimage,fao_alphafadenochildren,
                        fao_alphafadeall];
type
 tcanvas1 = class(tcanvas);
 tcolorarrayprop1 = class(tcolorarrayprop);
 trealarrayprop1 = class(trealarrayprop);
 tcaret1 = class(tcaret);

 tasyncmessageevent = class(tobjectevent)
  private
   fmessage: msestring;
   fcaption: msestring;
  public
   constructor create(const amessage: msestring; const acaption: msestring);
 end;
 
 twidgetshowevent = class(tsynchronizeevent)
  private
   fwidget: twidget;
   fmodalresult: modalresultty;
   fmodal: boolean;
   ftransientfor: twindow;
  protected
   procedure execute; override;
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

 tonwinideventlist = class(tmethodlist)
  protected
   procedure doevent(const awinid: winidty);
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

 tinternalapplication = class(tguiapplication,imouse)
         //avoid circular interface references
  private
   fonkeypresslist: tonkeyeventlist;
   fonshortcutlist: tonkeyeventlist;
   fonactivechangelist: tonactivechangelist;
   fonwindowdestroyedlist: tonwindoweventlist;
   fonwiniddestroyedlist: tonwinideventlist;
   fonapplicationactivechangedlist: tonapplicationactivechangedlist;

   fcaretwidget: twidget;
   fmousewinid: winidty;
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
   procedure processleavewindow;
   procedure processwindowcrossingevent(event: twindowevent);

   function getmousewinid: winidty; //for  tmouse.setshape
   function getevents: integer; override;
    //application must be locked
    //returns count of queued events
   procedure waitevent;         
    //application must be locked
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
   procedure dopostevent(const aevent: tevent); override;
   procedure flushmousemove;
   procedure doterminate(const shutdown: boolean);
   procedure checkshortcut(const sender: twindow; const awidget: twidget;
                     var info: keyeventinfoty);
   procedure doeventloop(const once: boolean); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
 end;

var
 appinst: tinternalapplication;

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

function getprocesswindow(const procid: integer): winidty;
var
 ar1: integerarty;
begin
 ar1:= getallprocesschildren(procid);
 result:= gui_pidtowinid(ar1);
end;

function activateprocesswindow(const procid: integer; 
                    const araise: boolean = true): boolean;
         //true if ok
var
 winid: winidty;
begin
 result:= false;
 winid:= getprocesswindow(procid);
 if winid <> 0 then begin
  if gui_showwindow(winid) = gue_ok then begin
   if araise and (gui_raisewindow(winid) <> gue_ok) then begin
    exit;
   end;
   if gui_setappfocus(winid) = gue_ok then begin
    result:= true;
   end;
  end;
 end;
end;

function translatewidgetrect(const rect: rectty;
                 const source,dest: twidget): rectty;
begin
 result:= rect;
 translatewidgetpoint1(result.pos,source,dest);
end;

function compx(const l,r): integer;
begin
 result:= twidget(l).fwidgetrect.x - twidget(r).fwidgetrect.x;
 if result = 0 then begin
  result:= twidget(l).fwidgetrect.y - twidget(r).fwidgetrect.y;
 end;
end;

procedure sortwidgetsxorder(var awidgets: widgetarty; const parent: twidget = nil);
var
 int1: integer;
 ar1,ar2: integerarty;
begin
 if parent = nil then begin
  sortarray(pointerarty(awidgets),{$ifdef FPC}@{$endif}compx);
 end
 else begin
  setlength(ar1,length(awidgets));
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= translatewidgetpoint(awidgets[int1].pos,awidgets[int1],parent).x;
  end;
  sortarray(ar1,ar2);
  orderarray(ar2,pointerarty(awidgets));
 end;
end;

function compy(const l,r): integer;
begin
 result:= twidget(l).fwidgetrect.y - twidget(r).fwidgetrect.y;
 if result = 0 then begin
  result:= twidget(l).fwidgetrect.x - twidget(r).fwidgetrect.x;
 end;
end;

procedure sortwidgetsyorder(var awidgets: widgetarty; const parent: twidget = nil);
var
 int1: integer;
 ar1,ar2: integerarty;
begin
 if parent = nil then begin
  sortarray(pointerarty(awidgets),{$ifdef FPC}@{$endif}compy);
 end
 else begin
  setlength(ar1,length(awidgets));
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= translatewidgetpoint(awidgets[int1].pos,awidgets[int1],parent).y;
  end;
  sortarray(ar1,ar2);
  orderarray(ar2,pointerarty(awidgets));
 end;
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

procedure syncmaxautosize(const widgets: array of twidget);
var
 size1,size2: sizety;
 int1: integer;
 rect1: rectty;
 po1: pointty;
begin
 size1:= nullsize;
 for int1:= high(widgets) downto 0 do begin
  widgets[int1].getautopaintsize(size2);
  if size2.cx > size1.cx then begin
   size1.cx:= size2.cx;
  end;
  if size2.cy > size1.cy then begin
   size1.cy:= size2.cy;
  end;
 end;
 for int1:= 0 to high(widgets) do begin
  with widgets[int1] do begin
   rect1:= fwidgetrect;
   clientsize:= size1;
   po1:= pos;
   if an_right in fanchors then begin
    dec(po1.x,fwidgetrect.cx-rect1.cx);
   end;
   if an_bottom in fanchors then begin
    dec(rect1.y,fwidgetrect.cy-rect1.cy);
   end;
   pos:= po1;
  end;
 end;
end;

procedure syncminframewidth(const awidth: integer; const awidgets: array of twidget);
var
 int1,int2,int3: integer;
 widget1: twidget;
begin
 if high(awidgets) >= 0 then begin
  int2:= -bigint;
  widget1:= awidgets[0]; //compiler warning
  for int1:= high(awidgets) downto 0 do begin
   with awidgets[int1] do begin
    if fframe = nil then begin
     int3:= 0;
    end
    else begin
     int3:= fframe.fouterframe.left + fframe.fouterframe.right;
    end;
   end;
   if int3 > int2 then begin
    widget1:= awidgets[int1];
    int2:= int3;
   end;
  end;
  widget1.bounds_cx:= awidth;
  int2:= widget1.bounds_cx - int2; //min frame width
  for int1:= 0 to high(awidgets) do begin
   with awidgets[int1] do begin
    if fframe = nil then begin
     int3:= 0;
    end
    else begin
     int3:= fframe.fouterframe.left + fframe.fouterframe.right;
    end;
    bounds_cx:= int2 + int3;
   end;
  end;
 end;
end;

procedure beep;
begin
 gui_beep;
end;

procedure disablewidgets(awidgets: array of twidget);
var
 int1: integer;
begin
 for int1:= 0 to high(awidgets) do begin
  awidgets[int1].enabled:= false;
 end;
end;

procedure enablewidgets(awidgets: array of twidget);
var
 int1: integer;
begin
 for int1:= 0 to high(awidgets) do begin
  awidgets[int1].enabled:= true;
 end;
end;

procedure showwidgets(awidgets: array of twidget);
var
 int1: integer;
begin
 for int1:= 0 to high(awidgets) do begin
  awidgets[int1].visible:= false;
 end;
end;

procedure hidewidgets(awidgets: array of twidget);
var
 int1: integer;
begin
 for int1:= 0 to high(awidgets) do begin
  awidgets[int1].visible:= false;
 end;
end;

function showmodalwidget(const aclass: widgetclassty): modalresultty;
var
 widget1: twidget;
begin
 widget1:= nil;
 application.setlinkedvar(aclass.create(nil),tmsecomponent(widget1));
 try
  result:= widget1.show(true);
 finally
  widget1.free;
 end;
end;

procedure designeventloop;
begin
 if appinst <> nil then begin
  appinst.fdesigning:= true;
  tinternalapplication(appinst).eventloop(nil);
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

function application: tguiapplication;
begin
 if appinst = nil then begin
  tinternalapplication.create(nil);
  appinst.initialize;
 end;
 result:= appinst;
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

{ tresizeevent }

constructor tresizeevent.create(const dest: ievent; const asize: sizety);
begin
 inherited create(ek_resize,dest);
 size:= asize;
end;

{ tcustomframe }

procedure initframeinfo(var fi: frameinfoty);
begin
 with fi do begin
  colorclient:= cl_transparent;
  colorframe:= cl_transparent;
  colorframeactive:= cl_default;
  with framecolors do begin
   shadow.effectcolor:= cl_default;
   shadow.color:= cl_default;
   shadow.effectwidth:= -1;
   light.color:= cl_default;
   light.effectcolor:= cl_default;
   light.effectwidth:= -1;
  end; 
 end;
end;

constructor tcustomframe.create(const intf: iframe);
begin
 fintf:= intf;
 if not (fs_nosetinstance in fstate) then begin
  fintf.setframeinstance(self);
 end;
 initframeinfo(fi);
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
 checkstate;
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
  {
  if ow_mousewheel in foptionswidget then begin
   include(fwidgetstate,ws_wantmousewheel);
  end
  else begin
   exclude(fwidgetstate,ws_wantmousewheel);
  end;
  }
 end;
end;

procedure tcustomframe.activechanged;
begin
 with fi do begin
  if (frameimage_list <> nil) and 
    ((frameimage_offsetactive <> 0) or 
    (frameimage_offsetactivemouse <> frameimage_offsetmouse) or
    (frameimage_offsetactiveclicked <> frameimage_offsetclicked)) then begin
   fintf.getwidget.invalidatewidget;
  end;
 end;
end;

function tcustomframe.needsfocuspaint: boolean;
begin
 result:= fs_drawfocusrect in fstate;
end;

procedure tcustomframe.paintbackground(const canvas: tcanvas;
                               const arect: rectty);
var
 rect1: rectty;
begin
 rect1:= deflaterect(arect,fpaintframe);
 if fi.colorclient <> cl_transparent then begin
  canvas.fillrect(rect1,fi.colorclient);
 end;
 canvas.intersectcliprect(rect1);
 canvas.move(addpoint(fpaintrect.pos,fclientrect.pos));
end;

procedure tcustomframe.paintoverlay(const canvas: tcanvas; const arect: rectty);
var
 rect1: rectty;
 col1: colorty;
 imageoffs: integer;
 rect2: rectty;
begin
 rect1:= deflaterect(arect,fouterframe);
 rect2:= rect1;
 if fi.levelo <> 0 then begin
  draw3dframe(canvas,rect1,fi.levelo,fi.framecolors);
  inflaterect1(rect1,-abs(fi.levelo));
 end;
 if fi.framewidth > 0 then begin
  if (fi.colorframeactive = cl_default) or not fintf.getwidget.active then begin
   col1:= fi.colorframe;
  end
  else begin
   col1:= fi.colorframeactive;
  end; 
  canvas.drawframe(rect1,-fi.framewidth,col1);
  inflaterect1(rect1,-fi.framewidth);
 end;
 if fi.leveli <> 0 then begin
  draw3dframe(canvas,rect1,fi.leveli,fi.framecolors);
 end;
 if fi.frameimage_list <> nil then begin
  imageoffs:= fi.frameimage_offset;
  with fintf do begin
   if getframeactive then begin
    if getframeclicked then begin
     imageoffs:= imageoffs + fi.frameimage_offsetactiveclicked;
    end
    else begin
     if getframemouse then begin
      imageoffs:= imageoffs + fi.frameimage_offsetactivemouse;
     end
     else begin
      imageoffs:= imageoffs + fi.frameimage_offsetactive;
     end;
    end;
   end
   else begin
    if getframeclicked then begin
     imageoffs:= imageoffs + fi.frameimage_offsetclicked;
    end
    else begin
     if getframemouse then begin
      imageoffs:= imageoffs + fi.frameimage_offsetmouse;
     end;
    end;
   end;
  end;
  if imageoffs >= 0 then begin
   fi.frameimage_list.paint(canvas,imageoffs,rect2.pos);
   fi.frameimage_list.paint(canvas,imageoffs+1,
      makerect(rect2.x,rect2.y+fi.frameimage_list.height,
               fi.frameimage_list.width,rect2.cy-2*fi.frameimage_list.height),
               [al_stretchy]);
   fi.frameimage_list.paint(canvas,imageoffs+2,rect2,[al_bottom]);
   fi.frameimage_list.paint(canvas,imageoffs+3,
      makerect(rect2.x+fi.frameimage_list.width,
               rect2.y+rect2.cy-fi.frameimage_list.height,
               rect2.cx-2*fi.frameimage_list.width,fi.frameimage_list.height),
               [al_stretchx]);
   fi.frameimage_list.paint(canvas,imageoffs+4,rect2,[al_bottom,al_right]);
   fi.frameimage_list.paint(canvas,imageoffs+5,
      makerect(rect2.x+rect2.cx-fi.frameimage_list.width,
               rect2.y+fi.frameimage_list.height,
               fi.frameimage_list.width,rect2.cy-2*fi.frameimage_list.height),
               [al_stretchy]);
   fi.frameimage_list.paint(canvas,imageoffs+6,rect2,[al_right]);
   fi.frameimage_list.paint(canvas,imageoffs+7,
      makerect(rect2.x+fi.frameimage_list.width,rect2.y,
               rect2.cx-2*fi.frameimage_list.width,
               fi.frameimage_list.height),[al_stretchx]);
  end;
 end;
 {
 if fi.colorclient <> cl_transparent then begin
  rect1:= deflaterect(arect,fpaintframe);
  canvas.fillrect(rect1,fi.colorclient);
 end;
 }
end;
{
procedure tcustomframe.paintoverlay(const canvas: tcanvas; const arect: rectty);
var
 imageoffs: integer;
 rect2: rectty;
begin
 if fi.frameimage_list <> nil then begin
  rect2:= deflaterect(arect,fouterframe);
  imageoffs:= fi.frameimage_offset;
  with fintf.getwidget do begin
   if getframeactive then begin
    if getframeclicked then begin
     imageoffs:= imageoffs + fi.frameimage_offsetactiveclicked;
    end
    else begin
     if getframemouse then begin
      imageoffs:= imageoffs + fi.frameimage_offsetactivemouse;
     end
     else begin
      imageoffs:= imageoffs + fi.frameimage_offsetactive;
     end;
    end;
   end
   else begin
    if getframeclicked then begin
     imageoffs:= imageoffs + fi.frameimage_offsetclicked;
    end
    else begin
     if getframemouse then begin
      imageoffs:= imageoffs + fi.frameimage_offsetmouse;
     end;
    end;
   end;
  end;
  if imageoffs >= 0 then begin
   fi.frameimage_list.paint(canvas,imageoffs,rect2.pos);
   fi.frameimage_list.paint(canvas,imageoffs+1,
   makerect(rect2.x,rect2.y+fi.frameimage_list.height,
            fi.frameimage_list.width,rect2.cy-2*fi.frameimage_list.height),
            [al_stretchy]);
   fi.frameimage_list.paint(canvas,imageoffs+2,rect2,[al_bottom]);
   fi.frameimage_list.paint(canvas,imageoffs+3,
   makerect(rect2.x+fi.frameimage_list.width,
            rect2.y+rect2.cy-fi.frameimage_list.height,
            rect2.cx-2*fi.frameimage_list.width,fi.frameimage_list.height),
            [al_stretchx]);
   fi.frameimage_list.paint(canvas,imageoffs+4,rect2,[al_bottom,al_right]);
   fi.frameimage_list.paint(canvas,imageoffs+5,
   makerect(rect2.x+rect2.cx-fi.frameimage_list.width,
            rect2.y+fi.frameimage_list.height,
            fi.frameimage_list.width,rect2.cy-2*fi.frameimage_list.height),
            [al_stretchy]);
   fi.frameimage_list.paint(canvas,imageoffs+6,rect2,[al_right]);
   fi.frameimage_list.paint(canvas,imageoffs+7,
   makerect(rect2.x+fi.frameimage_list.width,rect2.y,
            rect2.cx-2*fi.frameimage_list.width,
            fi.frameimage_list.height),[al_stretchx]);
  end;
 end;
end;
}
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
(*
procedure tcustomframe.paint(const canvas: tcanvas; const rect: rectty);
begin
 dopaintframe(canvas,rect);
 dopaintbackground(canvas,rect);
 {
 canvas.intersectcliprect(deflaterect(rect,fpaintframe));
 canvas.move(addpoint(fpaintrect.pos,fclientrect.pos));
 }
end;
*)
{
procedure tcustomframe.afterpaint(const canvas: tcanvas);
begin
 //dummy
end;
}
function tcustomframe.checkshortcut(var info: keyeventinfoty): boolean;
begin
 result:= false;
end;

procedure tcustomframe.updatewidgetstate;
var
 bo1: boolean;
begin
 if (fi.colorframeactive <> cl_default)  and (fi.framewidth <> 0) then begin
  with fintf.getwidget do begin
   bo1:= active;
   if bo1 xor (fs_widgetactive in fstate) then begin
    fintf.invalidatewidget;
    if bo1 then begin
     include(fstate,fs_widgetactive);
    end
    else begin    
     exclude(fstate,fs_widgetactive);
    end;
   end;
  end;
 end;
end;

procedure tcustomframe.updateclientrect;
begin
 fclientrect.size:= fpaintrect.size;
 fclientrect.pos:= nullpoint;
 finnerclientrect:= deflaterect(fclientrect,fi.innerframe);
end;

procedure tcustomframe.calcrects;
var
 int1: integer;
begin
 fwidth.left:= abs(fi.levelo) + fi.framewidth + abs(fi.leveli);
 fwidth.top:= fwidth.left;
 fwidth.right:= fwidth.left;
 fwidth.bottom:= fwidth.top;
 if fi.frameimage_list <> nil then begin
  int1:= fi.frameimage_list.width + fi.frameimage_left;
  if int1 > fwidth.left then begin
   fwidth.left:= int1;
  end;
  int1:= fi.frameimage_list.width + fi.frameimage_right;
  if int1 > fwidth.right then begin
   fwidth.right:= int1;
  end;
  int1:= fi.frameimage_list.height + fi.frameimage_top;
  if int1 > fwidth.top then begin
   fwidth.top:= int1;
  end;
  int1:= fi.frameimage_list.height + fi.frameimage_bottom;
  if int1 > fwidth.bottom then begin
   fwidth.bottom:= int1;
  end;
 end;
 fpaintframedelta:= nullframe;
 getpaintframe(fpaintframedelta);
 fpaintframe:= addframe(fpaintframedelta,fouterframe);
 addframe1(fpaintframe,fwidth);
 finnerframe:= addframe(fpaintframe,fi.innerframe);
 fpaintrect.pos:= pointty(fpaintframe.topleft);
 fpaintrect.size:= fintf.getwidgetrect.size;
 fpaintrect.cx:= fpaintrect.cx - fpaintframe.left - fpaintframe.right;
 fpaintrect.cy:= fpaintrect.cy - fpaintframe.top - fpaintframe.bottom;
 if not (fs_paintposinited in fstate) then begin
  fpaintposbefore:= fpaintrect.pos;
  include(fstate,fs_paintposinited);
 end;
end;

procedure tcustomframe.updaterects;
begin
 calcrects;
end;

procedure tcustomframe.updatestate;
var
 po1: pointty;
begin
 include(fstate,fs_rectsvalid);   //avoid recursion
 updaterects;
 if {not (ws_loadedproc in fintf.widgetstate) and}
//         not (csloading in fintf.getcomponentstate) and
         not (csreading in fintf.getcomponentstate) and
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
 include(flocalprops,frl_levelo);
 if fi.levelo <> value then begin
  fi.levelo := Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setleveli(const Value: integer);
begin
 include(flocalprops,frl_leveli);
 if fi.leveli <> value then begin
  fi.leveli := Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframewidth(const Value: integer);
begin
 include(flocalprops,frl_framewidth);
 if fi.framewidth <> value then begin
  if value < 0 then begin
   fi.framewidth:= 0;
  end
  else begin
   fi.framewidth := Value;
  end;
  internalupdatestate;
 end;
end;
{
procedure tcustomframe.setextraspace(const avalue: integer);
begin
 if fi.extraspace <> avalue then begin
  include(flocalprops,frl_extraspace);
  fi.extraspace:= avalue;
  internalupdatestate;
 end;
end;
}
procedure tcustomframe.setframei_left(const Value: integer);
begin
 include(flocalprops,frl_fileft);
 if fi.innerframe.left <> value then begin
  fi.innerframe.left:= Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_top(const Value: integer);
begin
 include(flocalprops,frl_fitop);
 if fi.innerframe.top <> value then begin
  fi.innerframe.top := Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_right(const Value: integer);
begin
 include(flocalprops,frl_firight);
 if fi.innerframe.right <> value then begin
  fi.innerframe.right:= Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframei_bottom(const Value: integer);
begin
 include(flocalprops,frl_fibottom);
 if fi.innerframe.bottom <> value then begin
  fi.innerframe.bottom:= Value;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_list(const avalue: timagelist);
begin
 include(flocalprops,frl_frameimagelist);
 if fi.frameimage_list <> avalue then begin
  fintf.getwidget.setlinkedvar(avalue,tmsecomponent(fi.frameimage_list));
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_left(const avalue: integer);
begin
 include(flocalprops,frl_frameimageleft);
 if fi.frameimage_left <> avalue then begin
  fi.frameimage_left:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_right(const avalue: integer);
begin
 include(flocalprops,frl_frameimageright);
 if fi.frameimage_right <> avalue then begin
  fi.frameimage_right:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_top(const avalue: integer);
begin
 include(flocalprops,frl_frameimagetop);
 if fi.frameimage_top <> avalue then begin
  fi.frameimage_top:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_bottom(const avalue: integer);
begin
 include(flocalprops,frl_frameimagebottom);
 if fi.frameimage_bottom <> avalue then begin
  fi.frameimage_bottom:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offset(const avalue: integer);
begin
 include(flocalprops,frl_frameimageoffset);
 if fi.frameimage_offset <> avalue then begin
  fi.frameimage_offset:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetmouse(const avalue: integer);
begin
 include(flocalprops,frl_frameimageoffsetmouse);
 if fi.frameimage_offsetmouse <> avalue then begin
  fi.frameimage_offsetmouse:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetclicked(const avalue: integer);
begin
 include(flocalprops,frl_frameimageoffsetclicked);
 if fi.frameimage_offsetclicked <> avalue then begin
  fi.frameimage_offsetclicked:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetactive(const avalue: integer);
begin
 include(flocalprops,frl_frameimageoffsetactive);
 if fi.frameimage_offsetactive <> avalue then begin
  fi.frameimage_offsetactive:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetactivemouse(const avalue: integer);
begin
 include(flocalprops,frl_frameimageoffsetactivemouse);
 if fi.frameimage_offsetactivemouse <> avalue then begin
  fi.frameimage_offsetactivemouse:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetactiveclicked(const avalue: integer);
begin
 include(flocalprops,frl_frameimageoffsetactiveclicked);
 if fi.frameimage_offsetactiveclicked <> avalue then begin
  fi.frameimage_offsetactiveclicked:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setcolorclient(const value: colorty);
begin
 include(flocalprops,frl_colorclient);
 if fi.colorclient <> value then begin
  fi.colorclient:= value;
  fintf.invalidate;
 end;
end;

procedure tcustomframe.setcolorframe(const Value: colorty);
begin
 include(flocalprops,frl_colorframe);
 if fi.colorframe <> value then begin
  fi.colorframe:= Value;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolorframeactive(const avalue: colorty);
begin
 include(flocalprops,frl_colorframeactive);
 if fi.colorframeactive <> avalue then begin
  fi.colorframeactive:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolordkshadow(const avalue: colorty);
begin
 include(flocalprops,frl_colordkshadow);
 if fi.framecolors.shadow.effectcolor <> avalue then begin
  fi.framecolors.shadow.effectcolor:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolorshadow(const avalue: colorty);
begin
 include(flocalprops,frl_colorshadow);
 if fi.framecolors.shadow.color <> avalue then begin
  fi.framecolors.shadow.color:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolorlight(const avalue: colorty);
begin
 include(flocalprops,frl_colorlight);
 if fi.framecolors.light.color <> avalue then begin
  fi.framecolors.light.color:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolorhighlight(const avalue: colorty);
begin
 include(flocalprops,frl_colorhighlight);
 if fi.framecolors.light.effectcolor <> avalue then begin
  fi.framecolors.light.effectcolor:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolordkwidth(const avalue: integer);
begin
 include(flocalprops,frl_colordkwidth);
 if fi.framecolors.shadow.effectwidth <> avalue then begin
  fi.framecolors.shadow.effectwidth:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.setcolorhlwidth(const avalue: integer);
begin
 include(flocalprops,frl_colorhlwidth);
 if fi.framecolors.light.effectwidth <> avalue then begin
  fi.framecolors.light.effectwidth:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.settemplate(const avalue: tframecomp);
begin
 fintf.getwidget.setlinkedvar(avalue,tmsecomponent(ftemplate));
 if (avalue <> nil) and not (csloading in avalue.componentstate) then begin
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
//  if not (frl_extraspace in flocalprops) then begin
//   extraspace:= ainfo.extraspace;
//  end;
  if not (frl_colorframe in flocalprops) then begin
   colorframe:= ainfo.colorframe;
  end;
  if not (frl_colorframeactive in flocalprops) then begin
   colorframeactive:= ainfo.colorframeactive;
  end;
  with framecolors do begin
   if not (frl_colordkshadow in flocalprops) then begin
    shadow.effectcolor:= ainfo.framecolors.shadow.effectcolor;
   end;
   if not (frl_colorshadow in flocalprops) then begin
    shadow.color:= ainfo.framecolors.shadow.color;
   end;
   if not (frl_colorlight in flocalprops) then begin
    light.color:= ainfo.framecolors.light.color;
   end;
   if not (frl_colorhighlight in flocalprops) then begin
    light.effectcolor:= ainfo.framecolors.light.effectcolor;
   end;
   if not (frl_colordkwidth in flocalprops) then begin
    shadow.effectwidth:= ainfo.framecolors.shadow.effectwidth;
   end;
   if not (frl_colorhlwidth in flocalprops) then begin
    light.effectwidth:= ainfo.framecolors.light.effectwidth;
   end;
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

  if not (frl_frameimagelist in flocalprops) then begin
   fintf.getwidget.setlinkedvar(ainfo.frameimage_list,
   tmsecomponent(frameimage_list));
  end;
  if not (frl_frameimageleft in flocalprops) then begin
   frameimage_left:= ainfo.frameimage_left;
  end;
  if not (frl_frameimageright in flocalprops) then begin
   frameimage_right:= ainfo.frameimage_right;
  end;
  if not (frl_frameimagetop in flocalprops) then begin
   frameimage_top:= ainfo.frameimage_top;
  end;
  if not (frl_frameimagebottom in flocalprops) then begin
   frameimage_bottom:= ainfo.frameimage_bottom;
  end;
  if not (frl_frameimageoffset in flocalprops) then begin
   frameimage_offset:= ainfo.frameimage_offset;
  end;
  if not (frl_frameimageoffsetmouse in flocalprops) then begin
   frameimage_offsetmouse:= ainfo.frameimage_offsetmouse;
  end;
  if not (frl_frameimageoffsetclicked in flocalprops) then begin
   frameimage_offsetclicked:= ainfo.frameimage_offsetclicked;
  end;
  if not (frl_frameimageoffsetactive in flocalprops) then begin
   frameimage_offsetactive:= ainfo.frameimage_offsetactive;
  end;
  if not (frl_frameimageoffsetactivemouse in flocalprops) then begin
   frameimage_offsetactivemouse:= ainfo.frameimage_offsetactivemouse;
  end;
  if not (frl_frameimageoffsetactiveclicked in flocalprops) then begin
   frameimage_offsetactiveclicked:= ainfo.frameimage_offsetactiveclicked;
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
 result.cx:= fpaintframe.left + fpaintframe.right;
 result.cy:= fpaintframe.top + fpaintframe.bottom;
// result.cx:= fouterframe.left + fpaintframe.left +
//       fpaintframe.right + fouterframe.right;
// result.cy:= fouterframe.top + fpaintframe.top +
//       fpaintframe.bottom + fouterframe.bottom;
end;

function tcustomframe.innerframewidth: sizety;
begin
 checkstate;
 result.cx:= finnerframe.left + finnerframe.right;
 result.cy:= finnerframe.top + finnerframe.bottom;
// result.cx:= fouterframe.left + fpaintframe.left + fi.innerframe.left +
//       fpaintframe.right + fouterframe.right + fi.innerframe.right;
// result.cy:= fouterframe.top + fpaintframe.top + fi.innerframe.top +
//       fpaintframe.bottom + fouterframe.bottom + fi.innerframe.bottom;
end;

function tcustomframe.outerframe: framety;
begin
 checkstate;
 result:= fouterframe;
end;

function tcustomframe.paintframe: framety;
begin
 checkstate;
 result:= fpaintframe;
// result:= addframe(fouterframe,fpaintframe);
end;

function tcustomframe.innerframe: framety;
begin
 checkstate;
 result:= finnerframe;
// result:= addframe(fouterframe,fpaintframe);
// addframe1(result,fi.innerframe);
end;

procedure tcustomframe.checktemplate(const sender: tobject);
begin
 if sender = ftemplate then begin
  assign(tpersistent(sender));
 end;
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

procedure tcustomframe.visiblechanged;
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
{
function tcustomframe.isextraspacestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_extraspace in flocalprops);
end;
}
function tcustomframe.iscolorframestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorframe in flocalprops);
end;

function tcustomframe.iscolorframeactivestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorframeactive in flocalprops);
end;

function tcustomframe.iscolordkshadowstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colordkshadow in flocalprops);
end;

function tcustomframe.iscolorshadowstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorshadow in flocalprops);
end;

function tcustomframe.iscolorlightstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorlight in flocalprops);
end;

function tcustomframe.iscolorhighlightstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorhighlight in flocalprops);
end;

function tcustomframe.iscolordkwidthstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colordkwidth in flocalprops);
end;

function tcustomframe.iscolorhlwidthstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorhlwidth in flocalprops);
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

function tcustomframe.isframeimage_liststored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimagelist in flocalprops);
end;

function tcustomframe.isframeimage_leftstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageleft in flocalprops);
end;

function tcustomframe.isframeimage_rightstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageright in flocalprops);
end;

function tcustomframe.isframeimage_topstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimagetop in flocalprops);
end;

function tcustomframe.isframeimage_bottomstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimagebottom in flocalprops);
end;

function tcustomframe.isframeimage_offsetstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageoffset in flocalprops);
end;

function tcustomframe.isframeimage_offsetmousestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageoffsetmouse in flocalprops);
end;

function tcustomframe.isframeimage_offsetclickedstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageoffsetclicked in flocalprops);
end;

function tcustomframe.isframeimage_offsetactivestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageoffsetactive in flocalprops);
end;

function tcustomframe.isframeimage_offsetactivemousestored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageoffsetactivemouse in flocalprops);
end;

function tcustomframe.isframeimage_offsetactiveclickedstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_frameimageoffsetactiveclicked in flocalprops);
end;

function tcustomframe.iscolorclientstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_colorclient in flocalprops);
end;


procedure tcustomframe.changedirection(const oldvalue: graphicdirectionty;
               const newvalue: graphicdirectionty);
var
 int1,int2: integer;
 fra1: framety;
begin
 int2:= ord(oldvalue)-ord(newvalue);
 for int1:= 0 to 3 do begin
  pintegeraty(@fra1)^[int1]:= 
         pintegeraty(@fi.innerframe)^[(int1+int2) and $3];
 end;
 framei_left:= fra1.left;
 framei_top:= fra1.top;
 framei_right:= fra1.right;
 framei_bottom:= fra1.bottom;
end;

procedure tcustomframe.scale(const ascale: real);
begin
 if ascale <> 1 then begin
  with fi do begin
   leveli:= round(leveli * ascale);
   levelo:= round(levelo * ascale);
   framewidth:= round(framewidth * ascale);
 //  extraspace:= round(extraspace * ascale);
   framecolors.shadow.effectwidth:= round(framecolors.shadow.effectwidth*ascale);
   framecolors.light.effectwidth:= round(framecolors.light.effectwidth*ascale);
   framei_left:= round(framei_left * ascale);
   framei_top:= round(framei_top * ascale);
   framei_right:= round(framei_right * ascale);
   framei_bottom:= round(framei_bottom * ascale);
  end;
 end;
end;

procedure tcustomframe.fontcanvaschanged;
begin
 //dummy
end;

function tcustomframe.cellframe: framety;
begin
 result.left:= finnerframe.left - fpaintframedelta.left;
 result.top:= finnerframe.top - fpaintframedelta.top;
 result.right:= finnerframe.right - fpaintframedelta.right;
 result.bottom:= finnerframe.bottom - fpaintframedelta.bottom;
end;

{ tframetemplate }

constructor tframetemplate.create(const owner: tmsecomponent;
                      const onchange: notifyeventty);
begin
 initframeinfo(fi);
 inherited;
end;

procedure tframetemplate.setcolorclient(const Value: colorty);
begin
 fi.colorclient:= Value;
 changed;
end;

procedure tframetemplate.setcolorframe(const Value: colorty);
begin
 fi.colorframe:= Value;
 changed;
end;

procedure tframetemplate.setcolorframeactive(const avalue: colorty);
begin
 fi.colorframeactive:= avalue;
 changed;
end;

procedure tframetemplate.setcolordkshadow(const avalue: colorty);
begin
 fi.framecolors.shadow.effectcolor:= avalue;
 changed;
end;

procedure tframetemplate.setcolorshadow(const avalue: colorty);
begin
 fi.framecolors.shadow.color:= avalue;
 changed;
end;

procedure tframetemplate.setcolorlight(const avalue: colorty);
begin
 fi.framecolors.light.color:= avalue;
 changed;
end;

procedure tframetemplate.setcolorhighlight(const avalue: colorty);
begin
 fi.framecolors.light.effectcolor:= avalue;
 changed;
end;

procedure tframetemplate.setcolordkwidth(const avalue: integer);
begin
 fi.framecolors.shadow.effectwidth:= avalue;
 changed;
end;

procedure tframetemplate.setcolorhlwidth(const avalue: integer);
begin
 fi.framecolors.light.effectwidth:= avalue;
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

procedure tframetemplate.setextraspace(const avalue: integer);
begin
 fextraspace := avalue;
 changed;
end;

procedure tframetemplate.setimagedist(const avalue: integer);
begin
 fimagedist := avalue;
 changed;
end;

procedure tframetemplate.setimagedisttop(const avalue: integer);
begin
 fimagedisttop := avalue;
 changed;
end;

procedure tframetemplate.setimagedistbottom(const avalue: integer);
begin
 fimagedistbottom := avalue;
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

procedure tframetemplate.setframeimage_list(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fi.frameimage_list));
 changed;
end;

procedure tframetemplate.setframeimage_left(const avalue: integer);
begin
 fi.frameimage_left:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_right(const avalue: integer);
begin
 fi.frameimage_right:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_top(const avalue: integer);
begin
 fi.frameimage_top:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_bottom(const avalue: integer);
begin
 fi.frameimage_bottom:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offset(const avalue: integer);
begin
 fi.frameimage_offset:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetmouse(const avalue: integer);
begin
 fi.frameimage_offsetmouse:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetclicked(const avalue: integer);
begin
 fi.frameimage_offsetclicked:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetactive(const avalue: integer);
begin
 fi.frameimage_offsetactive:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetactivemouse(const avalue: integer);
begin
 fi.frameimage_offsetactivemouse:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetactiveclicked(const avalue: integer);
begin
 fi.frameimage_offsetactiveclicked:= avalue;
 changed;
end;

function tframetemplate.getinfosize: integer;
begin
 result:= sizeof(fi) - sizeof(fi.frameimage_list);
end;

function tframetemplate.getinfoad: pointer;
begin
 result:= @fi;
end;

procedure tframetemplate.doassignto(dest: tpersistent);
begin
 if dest is tcustomframe then begin
  with tcustomframe(dest) do begin
   if (cs_loadedproc in fowner.msecomponentstate) or 
                 (csloading in fintf.getcomponentstate) then begin
    exclude(fstate,fs_paintposinited);
   end;
   settemplateinfo(self.fi);
  end;
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
  mseshapes.draw3dframe(acanvas,rect1,fi.leveli,fi.framecolors);
 end;
 if fi.framewidth > 0 then begin
  inflaterect1(rect1,fi.framewidth);
  acanvas.drawframe(rect1,-fi.framewidth,fi.colorframe);
 end;
 if fi.levelo <> 0 then begin
  inflaterect1(rect1,abs(fi.levelo));
  mseshapes.draw3dframe(acanvas,rect1,fi.levelo,fi.framecolors);
 end;
end;

procedure tframetemplate.copyinfo(const source: tpersistenttemplate);
begin
 setlinkedvar(tframetemplate(source).frameimage_list,
                  tmsecomponent(fi.frameimage_list));
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

constructor tcustomface.create;
begin
 inherited;
 internalcreate;
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
 if not (csloading in fintf.getwidget.componentstate) then begin
  include(flocalprops,fal_image);
 end;
end;

procedure tcustomface.checktemplate(const sender: tobject);
begin
 if sender = ftemplate then begin
  assign(tpersistent(sender));
 end;
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
                              //todo: optimize
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
{$ifdef FPC}{$checkpointer off}{$endif} //scanline is not in heap on win32
    if reverse then begin
     if ipos < 0 then begin
      ipos:= 0;
     end;
     for int3:= int2 downto ipos + 1 do begin
      fade^[int3]:= co1;
     end;
    end
    else begin
     if ipos > imax then begin
      ipos:= imax;
     end;
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
{$ifdef FPC}{$checkpointer default}{$endif}
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
  if fi.frameimage_list <> nil then begin
   fi.frameimage_list.paint(canvas,fi.frameimage_offset,rect.pos);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+1,
   makerect(rect.x,
            rect.y+fi.frameimage_list.height,
            fi.frameimage_list.width,
            rect.cy-2*fi.frameimage_list.height),[al_stretchy]);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+2,rect,[al_bottom]);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+3,
   makerect(rect.x+fi.frameimage_list.width,
            rect.y+rect.cy-fi.frameimage_list.height,
            rect.cx-2*fi.frameimage_list.width,
            fi.frameimage_list.height),[al_stretchx]);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+4,rect,
                                                [al_bottom,al_right]);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+5,
   makerect(rect.x+rect.cx-fi.frameimage_list.width,
            rect.y+fi.frameimage_list.height,
            fi.frameimage_list.width,
            rect.cy-2*fi.frameimage_list.height),[al_stretchy]);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+6,rect,[al_right]);
   fi.frameimage_list.paint(canvas,fi.frameimage_offset+7,
   makerect(rect.x+fi.frameimage_list.width,rect.y,
            rect.cx-2*fi.frameimage_list.width,
            fi.frameimage_list.height),[al_stretchx]);
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

procedure tcustomface.setimage(const value: tmaskedbitmap);
begin
 fi.image.assign(value);
end;

procedure tcustomface.setoptions(const avalue: faceoptionsty);
var
 optionsbefore: faceoptionsty;
begin
 include(flocalprops,fal_options);
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
 include(flocalprops,fal_facolor);
 fi.fade_color.assign(Value);
end;

procedure tcustomface.setfade_pos(const Value: trealarrayprop);
begin
 include(flocalprops,fal_fapos);
 fi.fade_pos.assign(Value);
end;

procedure tcustomface.setfade_direction(const Value: graphicdirectionty);
begin
 include(flocalprops,fal_fadirection);
 if fi.fade_direction <> value then begin
  fi.fade_direction:= Value;
  change;
 end;
end;

procedure tcustomface.setfade_transparency(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 include(flocalprops,fal_fatransparency);
 if fi.fade_transparency <> avalue then begin
  fi.fade_transparency:= avalue;
  change;
 end;
end;

procedure tcustomface.setframeimage_list(const avalue: timagelist);
begin
 include(flocalprops,fal_frameimagelist);
 if fi.frameimage_list <> avalue then begin
  fintf.getwidget.setlinkedvar(avalue,tmsecomponent(fi.frameimage_list));
  change;
 end;
end;

procedure tcustomface.setframeimage_offset(const avalue: integer);
begin
 include(flocalprops,fal_frameimageoffset);
 if fi.frameimage_offset <> avalue then begin
  fi.frameimage_offset:= avalue;
  change;
 end;
end;


procedure tcustomface.settemplate(const avalue: tfacecomp);
begin
 fintf.getwidget.setlinkedvar(avalue,tmsecomponent(ftemplate));
 if (avalue <> nil) and not (csloading in avalue.componentstate) then begin
  assign(avalue);
 end;
end;

procedure tcustomface.settemplateinfo(const ainfo: faceinfoty);
var
 localbefore: facelocalpropsty;
begin
 localbefore:= flocalprops;
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
 if not (fal_frameimagelist in flocalprops) then begin
  fintf.getwidget.setlinkedvar(ainfo.frameimage_list,
                tmsecomponent(fi.frameimage_list));
 end;
 if not (fal_frameimageoffset in flocalprops) then begin
  fi.frameimage_offset:= ainfo.frameimage_offset;
 end;
 if not (fal_options in flocalprops) then begin
  options:= ainfo.options;
 end;
 flocalprops:= localbefore;
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

function tcustomface.isframeimage_liststored: boolean;
begin
 result:= (ftemplate = nil) or (fal_frameimagelist in flocalprops);
end;

function tcustomface.isframeimage_offsetstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_frameimageoffset in flocalprops);
end;

{ tfacetemplate }

procedure tfacetemplate.internalcreate;
begin
 fi.image:= tmaskedbitmap.create(false);
 fi.fade_pos:= trealarrayprop.Create;
 fi.fade_color:= tcolorarrayprop.Create;
 fi.fade_pos.link([fi.fade_color,fi.fade_pos]);
 fi.fade_transparency:= cl_none;
 fi.image.onchange:= {$ifdef FPC}@{$endif}doimagechange;
 fi.fade_pos.onchange:= {$ifdef FPC}@{$endif}dochange;
 fi.fade_color.onchange:= {$ifdef FPC}@{$endif}dochange;
end;

constructor tfacetemplate.create(const owner: tmsecomponent;
                       const onchange: notifyeventty);
begin
 internalcreate;
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

procedure tfacetemplate.setfade_transparency(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 fi.fade_transparency:= avalue;
 changed;
end;

procedure tfacetemplate.setimage(const Value: tmaskedbitmap);
begin
 fi.image.assign(value);
 changed;
end;

procedure tfacetemplate.setframeimage_list(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fi.frameimage_list));
 changed;
end;

procedure tfacetemplate.setframeimage_offset(const avalue: integer);
begin
 fi.frameimage_offset:= avalue;
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
  self.setlinkedvar(frameimage_list,tmsecomponent(self.fi.frameimage_list));
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
 result:= sizeof(integer) + sizeof(fi.fade_direction);
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
 foptionsskin:= defaultoptionsskin;
 fanchors:= defaultanchors;
 foptionswidget:= defaultoptionswidget;
 fwidgetrect.cx:= defaultwidgetwidth;
 fwidgetrect.cy:= defaultwidgetheight;
 fcolor:= defaultwidgetcolor;
 inherited;
 include(fmsecomponentstate,cs_hasskin);
end;

procedure twidget.afterconstruction;
begin
 inherited;
 fnoinvalidate:= 0;
end;

destructor twidget.destroy;
begin
 include(fwidgetstate,ws_destroying);
 if (appinst <> nil) then begin
  appinst.widgetdestroyed(self);
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
 if fparentwidget <> nil then begin
  clearparentwidget;
 end;
// parentwidget:= nil;
// if ownswindow1 then begin
  fwindow.Free;
// end;
 ffont.free;
 fframe.free;
 fface.free;
 inherited;
 destroyregion(fwidgetregion);
end;

procedure twidget.initnewcomponent(const ascale: real);
begin
 inherited;
 scale(ascale);
end;

procedure twidget.initnewwidget(const ascale: real);
begin
 synctofontheight;
end;

procedure twidget.createframe;
begin
 if fframe = nil then begin
  internalcreateframe;
 end;
end;

procedure twidget.createface;
begin
 if fface = nil then begin
  internalcreateface;
 end;
end;

procedure twidget.createfont;
begin
 if ffont = nil then begin
  internalcreatefont;
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

function twidget.containeroffset: pointty;
var
 widget1: twidget;
begin
 widget1:= getcontainer;
 if widget1 = self then begin
  result:= nullpoint;
 end
 else begin
  result:= widget1.fwidgetrect.pos;
 end;
end;

function twidget.childrencount: integer;
begin
 result:= widgetcount;
end;

function twidget.getwidgets(const index: integer): twidget;
begin
 if (index < 0) or (index > high(fwidgets)) then begin
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

procedure twidget.changedirection(const avalue: graphicdirectionty;
                                               var dest: graphicdirectionty);
var
 dir1: graphicdirectionty;
 int1: integer;
begin
 if fface <> nil then begin
  fface.fade_direction:= rotatedirection(fface.fade_direction,avalue,dest);
 end;
 if fframe <> nil then begin
  fframe.changedirection(avalue,dest);
 end;
 dir1:= dest;
 dest := avalue;
 if (componentstate * [csdesigning,csloading] = [csdesigning]) and
    ((dir1 in [gd_right,gd_left]) xor (avalue in [gd_right,gd_left])) then begin
  int1:= bounds_cy;
  bounds_cy:= bounds_cx;
  bounds_cx:= int1;
 end;
end;
 
procedure twidget.placexorder(const startx: integer; const dist: array of integer;
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
   updateroot;
   case mode of
    wam_start: begin
     result:= frootpos.y + framepos.y;
    end;
    wam_center: begin
     result:= frootpos.y + framepos.y + framesize.cy div 2;
    end;
    else begin //wam_end
     result:= frootpos.y + framepos.y + awidget.framesize.cy;
    end;
   end;
  end;
 end;

var
 ref,int1,int3: integer;

begin
 if high(awidgets) >= 0 then begin
  ref:= getrefpoint(awidgets[0]);
  with awidgets[0] do begin
   if fparentwidget <> nil then begin
    result:= ref - fparentwidget.frootpos.y
   end
   else begin
    result:= ref;
   end;
  end;
  if high(awidgets) > 0 then begin
   for int1:= 1 to high(awidgets) do begin
    int3:= ref - getrefpoint(awidgets[int1]);
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
 end
 else begin
  result:= 0;
 end;
end;

function twidget.alignx(const mode: widgetalignmodety;
            const awidgets: array of twidget): integer;

 function getrefpoint(const awidget: twidget): integer;
 begin
  with awidget do begin
   updateroot;
   case mode of
    wam_start: begin
     result:= frootpos.x + framepos.x;
    end;
    wam_center: begin
     result:= frootpos.x + framepos.x + framesize.cx div 2;
    end;
    else begin //wam_end
     result:= frootpos.x + framepos.x + awidget.framesize.cx;
    end;
   end;
  end;
 end;

var
 ref,int1,int3: integer;

begin
 if high(awidgets) >= 0 then begin
  ref:= getrefpoint(awidgets[0]);
  with awidgets[0] do begin
   if fparentwidget <> nil then begin
    result:= ref - fparentwidget.frootpos.x
   end
   else begin
    result:= ref;
   end;
  end;
  if high(awidgets) > 0 then begin
   for int1:= 1 to high(awidgets) do begin
    int3:= ref - getrefpoint(awidgets[int1]);
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
 end
 else begin
  result:= 0;
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
 if not isloading then begin
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
 if not isloading then begin
  child.ftaborder:= high(fwidgets);
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
 if not isloading then begin
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

function twidget.clearparentwidget: twidget;
             //returns old parentwidget
begin
 result:= fparentwidget;
 fparentwidget:= nil;
 fwindow:= nil;
 result.unregisterchildwidget(self);
end;

procedure twidget.setparentwidget(const Value: twidget);
var
 newpos: pointty;
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
  end;

  if fparentwidget <> nil then begin
   subpoint1(newpos,clearparentwidget.clientwidgetpos);
  end;
  if fparentwidget <> nil then begin
   exit;                   //interrupt
  end;
  fparentwidget:= Value;
  fwidgetrect.pos:= newpos;
  if fparentwidget <> nil then begin
   fparentwidget.registerchildwidget(self);
   if not (ws_loadlock in fwidgetstate) then begin
    parentclientrectchanged;
   end;
  end
  else begin
   if visible and not (ws_destroying in fwidgetstate) and 
             not (csdestroying in componentstate) then begin
    window.show(false);
   end;
  end;
  if not isloading then begin
   fontchanged;
   colorchanged;
   enabledchanged; //-> statechanged
   parentchanged;
  end;
 end;
end;

procedure twidget.setlockedparentwidget(const avalue: twidget);
var
 bo1: boolean;
begin
 bo1:= ws_loadlock in fwidgetstate;
 include(fwidgetstate,ws_loadlock);
 try
  setparentwidget(avalue);
 finally
  if not bo1 then begin
   exclude(fwidgetstate,ws_loadlock);
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
 size1,size2: sizety;
begin
 if (ow_autosize in foptionswidget) and not (csloading in componentstate) then begin
  if not windowevent then begin
   checkwidgetsize(value.size);
  end;
  size1:= value.size;
  if fframe <> nil then begin
   subsize1(size1,fframe.paintframewidth);
  end;
  getautopaintsize(size1);
  if fframe <> nil then begin
   addsize1(size1,fframe.paintframewidth);
  end;
  subsize1(size1,value.size);
  size2:= value.size;
  inc(value.cx,size1.cx);
  if (ow_autosizeanright in foptionswidget) and not (an_right in fanchors) then begin
   dec(value.x,size1.cx);
  end;
  inc(value.cy,size1.cy);
  if (ow_autosizeanbottom in foptionswidget) and not (an_bottom in fanchors) then begin
   dec(value.y,size1.cy);
  end;
  if not windowevent then begin
   checkwidgetsize(value.size);
  end;
  if an_right in fanchors then begin
   dec(value.x,value.cx-size2.cx);
  end;
  if an_bottom in fanchors then begin
   dec(value.y,value.cy-size2.cy);
  end;
 end
 else begin
  if not windowevent then begin
   checkwidgetsize(value.size);
  end;
 end;
 poscha:= (value.x <> fwidgetrect.x) or (value.y <> fwidgetrect.y);
 sizecha:= (value.cx <> fwidgetrect.cx) or (value.cy <> fwidgetrect.cy);
 bo1:= (isvisible or (ws1_fakevisible in fwidgetstate1)) and (poscha or sizecha);
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
 end;
 if poscha and not (csloading in componentstate) then begin
  poschanged;
 end;
 if bo1 then begin
  if ownswindow1 and (tws_windowvisible in fwindow.fstate) then begin
   fwindow.checkwindow(windowevent);
  end;
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

procedure twidget.beginread;
begin
 if fframe <> nil then begin
  exclude(fframe.fstate,fs_paintposinited);
 end;
 inherited;
end;

procedure twidget.doendread;
begin
 if fframe <> nil then begin
  fframe.calcrects; //rects must be valid for parentfontchanged
 end;
 inherited;
end;

procedure twidget.loaded;
begin
 include(fwidgetstate,ws_loadedproc);
 try
  exclude(fwidgetstate1,ws1_widgetregionvalid);
  inherited;
  doloaded;
  sortzorder;
  updatetaborder(nil);
  parentfontchanged;
  if ffont <> nil then begin
   fontchanged;
  end;
  sizechanged;
  poschanged;
  colorchanged;
  enabledchanged; //-> statechanged
  parentchanged; 
  visiblepropchanged;
  if ownswindow1 and (ws_visible in fwidgetstate) and
                          (componentstate * [csloading,csinline] = []) then begin
   fwindow.show(false);
  end;
  if showing then begin
   doshow;
  end;
 finally
  exclude(fwidgetstate,ws_loadedproc);
 end;
end;

function twidget.updateopaque(const children: boolean): boolean;
                     //true if widgetregionchanged called
var
 bo1: boolean;
 int1: integer;
begin
 result:= false;
 bo1:= ws_opaque in fwidgetstate;
 if isvisible then begin
  include(fwidgetstate,ws_isvisible);
  if (fwidgetstate * [ws_nopaint] = [])  and
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
  result:= true;
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
 bo1:= isenabled;
 if not bo1 then begin
  if focused then begin
   window.setfocusedwidget(nil);
  end;
 end;   
 if fframe <> nil then begin
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
 if (frame <> nil) then begin
  fframe.activechanged;
 end;
end;

procedure twidget.visiblepropchanged;
begin
 if fframe <> nil then begin
  fframe.visiblechanged;
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

function twidget.getmintopleft: pointty;
begin
 result:= fwidgetrect.pos;
end;

function twidget.calcminscrollsize: sizety;
var
 int1,int2: integer;
 anch: anchorsty;
 indent: framety;
 clientorig: pointty;
 pt1: pointty;
begin
// result.cx:= -bigint;
// result.cy:= -bigint;
 result:= nullsize;
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
   if visible and not(ws1_nominsize in fwidgetstate1) or 
                                  (csdesigning in componentstate) then begin
    pt1:= getmintopleft;
    anch:= fanchors * [an_left,an_right];
    if anch = [an_right] then begin
     int2:= fparentclientsize.cx - fwidgetrect.x + indent.left + clientorig.x;
    end
    else begin
     if anch = [] then begin
      int2:= fminsize.cx;
     end
     else begin
      if anch = [an_left,an_right] then begin
       int2:= fparentclientsize.cx - cx + fminsize.cx;
      end
      else begin //[an_left]
       int2:= clientorig.x + pt1.x + cx + indent.right;
      end;
     end;
    end;
    if int2 > result.cx then begin
     result.cx:= int2;
    end;

    anch:= fanchors * [an_top,an_bottom];
    if anch = [an_bottom] then begin
     int2:= fparentclientsize.cy - fwidgetrect.y + indent.top + clientorig.y;
    end
    else begin
     if anch = [] then begin
      int2:= fminsize.cy;
     end
     else begin
      if anch = [an_top,an_bottom] then begin
       int2:= fparentclientsize.cy - cy + fminsize.cy;
      end
      else begin //[an_top]
       int2:= clientorig.y + pt1.y + cy + indent.bottom;
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
        rect1.x:= fparentwidget.clientwidgetpos.x;
        rect1.cx:= fparentwidget.clientsize.cx;
//        rect1.x:= fparentwidget.paintpos.x;
//        rect1.cx:= fparentwidget.paintsize.cx;
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
        rect1.y:= fparentwidget.clientwidgetpos.y;
        rect1.cy:= fparentwidget.clientsize.cy;
//        rect1.y:= fparentwidget.paintpos.y;
//        rect1.cy:= fparentwidget.paintsize.cy;
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
  event.Free1;
 end;
end;

procedure twidget.release;
begin
 if ownswindow1 then begin
  window.endmodal;
 end;
 inherited;
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
 face1: tcustomface;
begin
 if frame <> nil then begin
  colorbefore:= canvas.color;
  canvas.color:= actualcolor;
  fframe.paintbackground(canvas,makerect(nullpoint,fwidgetrect.size));
//  fframe.paint(canvas,makerect(nullpoint,fwidgetrect.size));
  canvas.color:= colorbefore;
 end;
 face1:= getactface;
 if face1 <> nil then begin
  if fframe <> nil then begin
   canvas.remove(fframe.fclientrect.pos);
   face1.paint(canvas,makerect(nullpoint,fframe.fpaintrect.size));
   canvas.move(fframe.fclientrect.pos);
  end
  else begin
   face1.paint(canvas,makerect(nullpoint,fwidgetrect.size));
  end;
 end;
 {
 if (fframe <> nil) and (fframe.image_list <> nil) then begin
  fframe.paintoverlay(canvas,makerect(-fframe.fpaintrect.x,
                 -fframe.fpaintrect.y,
                 fwidgetrect.cx,fwidgetrect.cy));
 end
 }
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

procedure twidget.dopaintoverlay(const canvas: tcanvas);
begin
 if fframe <> nil then begin
  fframe.paintoverlay(canvas,makerect(nullpoint,fwidgetrect.size));
 end;
end;

function twidget.isgroupleader: boolean;
begin
 result:= false;
end;

function twidget.needsfocuspaint: boolean;
begin
 result:= {not (ow_nofocusrect in foptionswidget) and} (fframe <> nil) and 
                fframe.needsfocuspaint;
end;

function twidget.getshowhint: boolean;
begin
 result:= (ow_hinton in foptionswidget) or
  not (ow_hintoff in foptionswidget) and
       ((fparentwidget = nil) or fparentwidget.getshowhint);
end;

procedure twidget.showhint(var info: hintinfoty);
var
 mstr1: msestring;
begin
 if getshowhint and not(csdesigning in componentstate) then begin
  mstr1:= hint;
  if mstr1 <> '' then begin
   info.caption:= mstr1;
  end;
 end;
end;

procedure twidget.doafterpaint(const canvas: tcanvas);
begin
 if fframe <> nil then begin
//  fframe.paintoverlay(canvas,makerect(nullpoint,fwidgetrect.size));
//  fframe.afterpaint(canvas);
  if needsfocuspaint and (fwidgetstate * [ws_focused,ws_active] =
                [ws_focused,ws_active]) then begin
   fframe.dopaintfocusrect(canvas,makerect(nullpoint,fwidgetrect.size));
  end;
 end;
end;

function twidget.needsdesignframe: boolean;
begin
 result:= 
 (ws_iswidget in fwidgetstate) and
   not (ws1_nodesignframe in fwidgetstate1) and
   (
     ((fwidgetrect.cx = 0) or (fwidgetrect.cy = 0)) or
     (
       ( 
         (fcolor = cl_transparent) or 
           (fparentwidget <> nil) and 
           (colortopixel(actualcolor) = colortopixel(fparentwidget.backgroundcolor))
       ) and
       ((fframe = nil) or (fframe.fi.leveli = 0) and (fframe.fi.levelo = 0) and
                          (fframe.fi.framewidth = 0)
       )
     )     
   );
end;

procedure twidget.paint(const canvas: tcanvas);
var
 int1,int2: integer;
 saveindex: integer;
 actcolor: colorty;
 reg1: regionty;
 rect1: rectty;
 widget1: twidget;
 bo1: boolean;
 face1: tcustomface;
begin
 canvas.save;
 rect1.pos:= nullpoint;
 rect1.size:= fwidgetrect.size;
 canvas.intersectcliprect(rect1);
 if canvas.clipregionisempty then begin
  canvas.restore;
  exit;
 end;
 canvas.save;
 if not (ws_nopaint in fwidgetstate) then begin
  actcolor:= actualcolor;
  saveindex:= canvas.save;
  dobeforepaint(canvas);
  if (high(fwidgets) >= 0) and not (ws1_noclipchildren in fwidgetstate1) then begin
   updatewidgetregion;
   canvas.subclipregion(fwidgetregion);
  end;
  bo1:= not canvas.clipregionisempty;
  if bo1 then begin
   if ws_opaque in fwidgetstate then begin
    canvas.fillrect(rect1,actcolor);
   end;
   {$ifdef mse_slowdrawing}
   sleep(500);
   {$endif}
   canvas.font:= getfont;
   canvas.color:= actcolor;
   dopaint(canvas);
   doonpaint(canvas);
  end;
  canvas.restore(saveindex);
  if bo1 then begin
   face1:= getactface;
//   dopaintoverlay(canvas);
   if (face1 <> nil) and (fao_alphafadenochildren in face1.fi.options) then begin
    canvas.move(paintpos);
    face1.doalphablend(canvas);
    canvas.remove(paintpos);
   end;
  end;
  if (csdesigning in componentstate) and needsdesignframe then begin
   canvas.dashes:= #2#3;
   canvas.drawrect(makerect(0,0,rect1.cx-1,rect1.cy-1),cl_black);
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
      paint(canvas);
     end;
     canvas.restore(saveindex);
    end;
   end;
  end;
 end;
 canvas.restore;
 face1:= getactface;
 if (face1 <> nil) and (fao_alphafadeall in face1.fi.options) then begin
  canvas.move(paintpos);
  fface.doalphablend(canvas);
  canvas.remove(paintpos);
 end;
 dopaintoverlay(canvas);
 doafterpaint(canvas);
 canvas.restore;
end;

procedure twidget.parentwidgetregionchanged(const sender: twidget);
begin
 //dummy
end;

procedure twidget.widgetregionchanged(const sender: twidget);
var
 int1: integer;
begin
 widgetregioninvalid;
 invalidaterect(sender.fwidgetrect,org_widget);
 if componentstate * [csloading,csdestroying] = [] then begin
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].parentwidgetregionchanged(sender);
  end;
 end;
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
            (componentstate * [csloading,csinline,csdestroying] = []) then begin
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

procedure twidget.parentchanged;
var
 int1: integer;
begin
 if not (ws_loadedproc in fwidgetstate) then begin
  parentfontchanged;
  for int1:= 0 to high(fwidgets) do begin
   with fwidgets[int1] do begin
    parentchanged;
   end;
  end;
 end;
end;

function twidget.ownswindow1: boolean;
begin
 result:= (fwindow <> nil) and (fwindow.fowner = self);
end;

function twidget.ownswindow: boolean;
begin
 result:= (fwindow <> nil) and (fwindow.fowner = self) and (fwindow.fwindow.id <> 0);
end;

function twidget.updaterect: rectty; //invalidated area, origin = clientpos
begin
 result:= window.updaterect;
 translateclientpoint1(result.pos,rootwidget,self);
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

function twidget.innerframewidth: sizety;  
begin
 if frame <> nil then begin
  fframe.checkstate;
  result.cx:= fframe.fclientrect.cx - fframe.finnerclientrect.cx;
  result.cy:= fframe.fclientrect.cy - fframe.finnerclientrect.cy;
 end
 else begin
  result:= nullsize;
 end;
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

function twidget.clippedpaintrect: rectty;    //origin = pos, cliped by all parentpaintrects
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

function twidget.widgetsizerect: rectty;          //pos = nullpoint
begin
 result.pos:= nullpoint;
 result.size:= fwidgetrect.size;
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

procedure twidget.internalcreateframe;
begin
 tframe.create(iscrollframe(self));
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

procedure twidget.invalidateframestaterect(const rect: rectty; 
                                        const org: originty = org_client);
begin
 if (fframe = nil) or (fframe.fi.frameimage_list = nil) then begin
  invalidaterect(rect,org);
 end
 else begin
  invalidatewidget;
 end;
end;

procedure twidget.invalidateframestate;
begin
 if (fframe = nil) or (fframe.fi.frameimage_list = nil) then begin
  invalidate;
 end
 else begin
  invalidatewidget;
 end;
end;

{
procedure twidget.invalidatesiblings(arect: rectty);
var
 rect1: rectty;
 int1: integer;
 bo1: boolean;
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  if not (ws_opaque in fwidgetstate) then begin
   invalidaterect(arect,org_widget);
  end
  else begin
   updateroot;
   addpoint1(arect.pos,fwidgetrect.pos);
   for int1:= high(fparentwidget.fwidgets) downto 0 do begin
    widget1:= fparentwidget.fwidgets[int1];
    if widget1 = self then begin
     break;
    end;
    if intersectrect(widget1.fwidgetrect,arect,rect1) then begin
     inc(rect1.x,fparentwidget.frootpos.x);
     inc(rect1.y,fparentwidget.frootpos.y);
     fwindow.invalidaterect(rect1,self);
    end; 
   end;
   fparentwidget.invalidatesiblings(arect);
  end;
 end;
end;
}
function twidget.hasoverlappingsiblings(arect: rectty): boolean;
var
 int1: integer;
 widget1: twidget;
begin
 result:= false;
 if fparentwidget <> nil then begin
  updateroot;
  addpoint1(arect.pos,fwidgetrect.pos);
  for int1:= high(fparentwidget.fwidgets) downto 0 do begin
   widget1:= fparentwidget.fwidgets[int1];
   if widget1 = self then begin
    break;
   end;
   if intersectrect(widget1.fwidgetrect,arect,arect) then begin
    result:= true;
    exit;
   end; 
  end;
  result:= fparentwidget.hasoverlappingsiblings(arect);
 end;
end;

procedure twidget.internalcreateface;
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

function twidget.getsortxchildren: widgetarty;
begin
 result:= copy(container.fwidgets);
 sortwidgetsxorder(result);
end;

function twidget.getsortychildren: widgetarty;
begin
 result:= copy(container.fwidgets);
 sortwidgetsyorder(result);
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
   ek_mousewheel: begin
    childstate:= [ws_enabled,ws_isvisible{,ws_wantmousewheel}];
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
  {
  if ow_mousewheel in foptionswidget then begin
   include(fwidgetstate,ws_wantmousewheel);
  end
  else begin
   exclude(fwidgetstate,ws_wantmousewheel);
  end;
  }
 end;
end;

procedure twidget.updatecursorshape(force: boolean = false);
var
 widget: twidget;
 cursor1: cursorshapety;
begin
 if (appinst <> nil) then begin
  if force or (appinst.fclientmousewidget = self) or
    (appinst.cursorshape = cr_default) and
      checkdescendent(appinst.fclientmousewidget) then begin
   widget:= self;
   repeat
    cursor1:= widget.fcursor;
    widget:= widget.fparentwidget;
   until (cursor1 <> cr_default) or (widget = nil);
   if (widget = nil) and (cursor1 = cr_default) then begin
    cursor1:= cr_arrow;
   end;
   appinst.cursorshape:= cursor1;
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
    if (appinst.fclientmousewidget <> self) and not (es_child in eventstate) then begin
                       //call updaterootwidget
     appinst.setclientmousewidget(self);
    end;
    result:= true;
    if fframe <> nil then begin
     subpoint1(pos,getclientoffset);
    end;
   end
   else begin
    appinst.setclientmousewidget(nil);
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
     if (fframe <> nil) then begin
      with fframe.fi do begin
       if (frameimage_list <> nil) and 
               ((frameimage_offsetmouse <> 0) or 
                (frameimage_offsetactivemouse <> 0))then begin
        invalidatewidget;
       end;
      end;
     end;
     if appinst.fmousewidget = self then begin
      if fparentwidget <> nil then begin
       fparentwidget.updatecursorshape(true);
      end
      else begin
       appinst.cursorshape:= cr_default;
      end;
     end;
     clientmouseevent(info);
    end;
    ek_clientmouseenter: begin
     if (fframe <> nil) then begin
      with fframe.fi do begin
       if (frameimage_list <> nil) and 
               ((frameimage_offsetmouse <> 0) or 
                (frameimage_offsetactivemouse <> 0))then begin
        invalidatewidget;
       end;
      end;
     end;
     updatecursorshape(true);
     clientmouseevent(info);
    end;
    ek_buttonpress: begin
     if button = mb_left then begin
      include(fwidgetstate,ws_clicked);
      if (fframe <> nil) then begin
       with fframe.fi do begin
        if (frameimage_list <> nil) and 
                ((frameimage_offsetclicked <> 0) or 
                 (frameimage_offsetactiveclicked <> 0))then begin
         invalidatewidget;
        end;
       end;
      end;
     end;
     appinst.capturemouse(self,true);
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
     if (button = mb_left) and (fframe <> nil) then begin
      with fframe.fi do begin
       if (frameimage_list <> nil) and 
               ((frameimage_offsetclicked <> 0) or 
                (frameimage_offsetactiveclicked <> 0))then begin
        invalidatewidget;
       end;
      end;
     end;
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
   if (appinst <> nil) and ((shiftstate - mousebuttontoshiftstate(button)) *
                            mousebuttons = []) and
                           (appinst.fmousecapturewidget = self) then begin
    if not (ws_mousecaptured in fwidgetstate) then begin
     appinst.capturemouse(nil,false);
    end
    else begin
     fwidgetstate:= fwidgetstate - [ws_clientmousecaptured];
     appinst.ungrabpointer;
    end;
   end;
  end;
 end;
end;

procedure twidget.domousewheelevent(var info: mousewheeleventinfoty);
begin
 //dummy
end;

procedure twidget.mousewheelevent(var info: mousewheeleventinfoty);
var
 bo1: boolean;
 pt1: pointty;
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   if ow_mousewheel in foptionswidget then begin
    domousewheelevent(info);
   end;
   if not (es_processed in eventstate) and (fparentwidget <> nil) then begin
    pt1:= self.pos;
    addpoint1(pos,pt1);
    bo1:= es_child in eventstate;
    try
     include(eventstate,es_child);
     fparentwidget.mousewheelevent(info);
    finally
     subpoint1(pos,pt1);
     if not bo1 then begin
      exclude(eventstate,es_child);
     end;
    end;   
   end;
  end;
 end;
end;

procedure twidget.setclientclick;
begin
 appinst.capturemouse(self,true);
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

function twidget.getclientpos: pointty;
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

function twidget.clientwidgetrect: rectty;        //origin = pos
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result:= fclientrect;
   addpoint1(result.pos,fpaintrect.pos);
  end
 end
 else begin
  result.pos:= nullpoint;
  result.size:= fwidgetrect.size;
 end;
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

function twidget.paintrectparent: rectty; //origin = paintpos,
                                         //nullrect if parent = nil,
begin
 if fparentwidget = nil then begin
  result:= nullrect;
 end
 else begin
  result:= fparentwidget.paintrect;
  subpoint1(result.pos,paintparentpos);
 end;
end;

function twidget.clientrectparent: rectty; //origin = paintpos,
                                         //nullrect if parent = nil,
begin
 if fparentwidget = nil then begin
  result:= nullrect;
 end
 else begin
  result:= fparentwidget.clientwidgetrect;
  subpoint1(result.pos,paintparentpos);
 end;
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
   window.activate;
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
  include(fwidgetstate,ws_entering);
  try
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
  finally
   exclude(fwidgetstate,ws_entering);
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
  include(fwidgetstate,ws_exiting);
  try
   ffocusedchildbefore:= ffocusedchild;
   ffocusedchild:= nil;
   exclude(fwidgetstate,ws_entered);
   if needsfocuspaint then begin
    invalidatewidget;
   end;
   if (ow_canclosenil in foptionswidget) then begin
    if not canclose(nil) then begin
     exit;
    end;
   end;
   doexit;
  finally
   exclude(fwidgetstate,ws_exiting);
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

procedure twidget.dofocuschanged(const oldwidget,newwidget: twidget);
var
 int1: integer;
begin
 for int1:= 0 to high(fwidgets) do begin
  fwidgets[int1].dofocuschanged(oldwidget,newwidget);
 end;
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

procedure twidget.doloaded;
begin
 //dummy
end;

procedure twidget.dohide;
var
 int1: integer;
begin
 visiblechanged;
 if appinst.fmousecapturewidget = self then begin
  releasemouse;
 end;
 if appinst.fmousewidget = self then begin
  appinst.setmousewidget(nil);
 end;
 if appinst.fhintforwidget = self then begin
  appinst.hidehint;
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
 bo1,bo2: boolean;
begin
 bo1:= ws_visible in fwidgetstate;
 bo2:= false;
 if showing then begin
  if bo1 and not (csdestroying in componentstate) then begin 
   updateroot;
   window.invalidaterect(makerect(frootpos,fwidgetrect.size));
           //invalidate old position and size
  end;
  exclude(fwidgetstate,ws_visible);
  dohide;
 end
 else begin
  exclude(fwidgetstate,ws_visible);
  bo2:= updateopaque(false);
 end;
 if ws_visible in fwidgetstate then begin
  exit; //show called
 end;
 if bo1 then begin
  if not bo2 and (fparentwidget <> nil) then begin
   fparentwidget.widgetregionchanged(self);
  end;
  if ownswindow1 then begin
   fwindow.hide(windowevent);
  end;
  if (fwindow <> nil) and (fparentwidget<> nil) and 
                            checkdescendent(fwindow.focusedwidget) then begin
   nextfocus;
   if (fwindow <> nil) and checkdescendent(fwindow.focusedwidget) then begin
    show; //defocus was not possible
   end;
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
 if not (ws_loadedproc in fwidgetstate) then begin
  visiblechanged;
  for int1:= 0 to widgetcount - 1 do begin
   with widgets[int1] do begin
    if fwidgetstate * [ws_visible,ws_showproc] = [ws_visible] then begin
     doshow;
    end;
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
    fparentwidget.show(modal,transientfor);
   finally
    exclude(fwidgetstate,ws_showproc);
   end;
  end;
 end;
 include(fwidgetstate,ws_visible);
 if bo1 then begin
  if not updateopaque(false) and (fparentwidget <> nil) then begin
   fparentwidget.widgetregionchanged(self);
  end;
 end;
 if ownswindow1 then begin
  if modal and (transientfor = nil) then begin
   if appinst.fmodalwindow = nil then begin
    if appinst.fwantedactivewindow <> nil then begin
     transientfor:= appinst.fwantedactivewindow;
    end
    else begin
//     {$ifndef mswindows}  //on win32 winid wil be destroyed on destroying transientfor
      //todo: no ifndef
     transientfor:= appinst.factivewindow;
//     {$endif}
    end;
   end
   else begin
    transientfor:= appinst.fmodalwindow;
   end;
  end;
  if transientfor = window then begin
   transientfor:= nil;
   end;
  fwindow.show(windowevent);
  if transientfor <> nil then begin
   fwindow.settransientfor(transientfor,windowevent);
  end;
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
var
 event: twidgetshowevent;
begin
 if not application.ismainthread then begin
  event:= twidgetshowevent.create(false);
  event.fwidget:= self;
  event.fmodal:= modal;
  event.ftransientfor:= transientfor;
  try
   synchronizeevent(event);
   result:= event.fmodalresult;
  finally
   event.free;
  end;  
 end
 else begin
  result:= internalshow(modal,transientfor,false);
 end;
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
// int1: integer;
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

function twidget.iswidgetclick(const info: mouseeventinfoty;
                     const caption: boolean = false): boolean;
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
        (appinst.fbuttonpresswidgetbefore = self);
 end;
end;

function twidget.isdblclicked(const info: mouseeventinfoty): boolean;
   //true if eventtype in [et_buttonpress,et_butonrelease], button is mb_left,
   // and timedlay to last same buttonevent is short
begin
 with info do begin
  result:= (button = mb_left) and (ss_double in shiftstate) and 
    ((eventkind = ek_buttonpress) and (appinst.fbuttonpresswidgetbefore = self) or
     (eventkind = ek_buttonrelease) and (appinst.fbuttonreleasewidgetbefore = self));
 end;
end;

function twidget.isleftbuttondown(const info: mouseeventinfoty): boolean;
begin
 with info do begin
  result:= (eventkind = ek_buttonpress) and
              (button = mb_left) and pointinrect(pos,clientrect);
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
   int2:= indexofwidget(sender);
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
    with widgets[int1] do begin
     if not (ow_noparentshortcut in foptionswidget) then begin
      doshortcut(info,nil);
     end;
    end;
    if (es_processed in info.eventstate) then begin
     break;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) and (sender <> nil) then begin
    //parent
   if (fparentwidget <> nil) and 
                    not (ow_nochildshortcut in foptionswidget) then begin
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
   (fparentwidget = nil) and ((fwindow <> nil) and 
                                   (tws_windowvisible in fwindow.fstate)) or
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

function twidget.activeentered: boolean;
begin
 result:= entered and ((appinst.regularactivewindow = window) or 
                (appinst.finactivewindow = window));
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
         ((csdesigning in componentstate) and 
                    not (ws1_nodesignvisible in fwidgetstate1));
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
    show(false,window.ftransientfor);
   end
   else begin
    include(fwidgetstate,ws_visible);
   end;
  end
  else begin
   hide;
  end;
  if (ws1_fakevisible in fwidgetstate1) then begin
   if not updateopaque(false) and (fparentwidget <> nil) then begin
    fparentwidget.widgetregionchanged(self);
   end;
  end;
  visiblepropchanged;
 end
 else begin
  if value then begin
   include(fwidgetstate,ws_visible);
  end
  else begin
   exclude(fwidgetstate,ws_visible);
   if not (csloading in componentstate) and ownswindow then begin
    gui_hidewindow(fwindow.fwindow.id);
   end;
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

function twidget.backgroundcolor: colorty;
begin
 if (fframe = nil) or (fframe.fi.colorclient = cl_transparent) then begin
  if fparentwidget = nil then begin
   result:= actualcolor;
  end
  else begin
   if (fcolor <> cl_parent) and (fcolor <> cl_default) then begin
    result:= fcolor;
   end
   else begin
    result:= fparentwidget.backgroundcolor;
   end;
  end;
 end
 else begin
  result:= fframe.fi.colorclient;
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
  with appinst,fcaret,fcaretwidget do begin
   cliprect:= moverect(clipcaret,subpoint(fcaretwidget.frootpos,origin));
  end;
 end;
end;

function twidget.hascaret: boolean;
begin
 result:= (appinst <> nil) and checkdescendent(appinst.fcaretwidget)
end;

procedure twidget.getcaret;
begin
 if (appinst <> nil) then begin
  appinst.caret.link(window.fcanvas,addpoint(frootpos,clientwidgetpos),
                 removerect(clipcaret,clientwidgetpos));
  appinst.fcaretwidget:= self;
 end;
end;

function twidget.mousecaptured: boolean;
begin
 result:= application.mousecapturewidget = self;
end;
                     
procedure twidget.capturemouse(grab: boolean = true);
begin
 if appinst <> nil then begin
  appinst.capturemouse(self,grab);
  include(fwidgetstate,ws_mousecaptured);
 end;
end;

procedure twidget.releasemouse;
begin
 if (appinst <> nil) and (appinst.fmousecapturewidget = self) then begin
  appinst.capturemouse(nil,false);
  exclude(fwidgetstate,ws_mousecaptured);
 end;
end;

procedure twidget.capturekeyboard;
begin
 if appinst <> nil then begin
  appinst.fkeyboardcapturewidget:= self;
 end;
end;

procedure twidget.releasekeyboard;
begin
 if (appinst <> nil) and (appinst.fkeyboardcapturewidget = self) then begin
  appinst.fkeyboardcapturewidget:= nil;
 end;
end;

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
   if appinst.fcaretwidget = widget1 then begin
    widget1.reclipcaret;
   end;
  end;
  widgetregioninvalid;
  if fwindow <> nil then begin
   fwindow.fscrollnotifylist.notify(self);
  end;
 end;
end;

procedure twidget.scrollcaret(const dist: pointty);
begin
 if hascaret then begin
  tcaret1(appinst.fcaret).scroll(dist,appinst.fcaretwidget <> self);
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
   tcaret1(appinst.fcaret).remove;
  end;
  rect1:= rect;
  if fframe <> nil then begin
   inc(rect1.x,fframe.fpaintrect.x);
   inc(rect1.y,fframe.fpaintrect.y); //widget origin
  end;
  if (ow_noscroll in foptionswidget) {or not (ws_opaque in fwidgetstate)} or
                                  (tws_painting in fwindow.fstate) then begin
   invalidaterect(rect1,org_widget);
  end
  else begin
   update;
   msegraphutils.intersectrect(rect1,clippedpaintrect,rect1);
   if hasoverlappingsiblings(rect1) then begin
    invalidaterect(rect1,org_widget);
   end
   else begin
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
  end;
  if ahascaret then begin
   if scrollcaret then begin
    tcaret1(appinst.fcaret).scroll(dist,appinst.fcaretwidget <> self);
    reclipcaret;
   end;
   tcaret1(appinst.fcaret).restore;
  end;
  if (appinst.factmousewindow = fwindow) then begin
   with appinst.fmouseparkeventinfo do begin
    if pointinrect(pos,
         makerect(addpoint(addpoint(rootpos,paintpos),rect.pos),rect.size)) then begin
          //replay last mousepos
     appinst.eventlist.insert(0,tmouseevent.create(fwindow.winid,false,
                    mb_none,mw_none,pos,shiftstate,0));
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
 if not isloading then begin
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
 result:= parentofcontainer;
 if (result <> nil) and (csdesigning in componentstate) and 
         not(csdesigning in result.componentstate) then begin
  result:= nil; //parentwidget is designer
 end
end;

function twidget.hasparent: boolean;
begin
 result:= getparentcomponent <> nil;
// result:= fparentwidget <> nil;
end;

procedure twidget.setparentcomponent(value: tcomponent);
begin
 if value is twidget then begin
  twidget(value).insertwidget(self,fwidgetrect.pos);
//  parentwidget:= twidget(value);
 end;
end;

procedure twidget.setchildorder(child: tcomponent; order: integer);
begin
 with container do begin
  if order < 0 then begin
   order:= 0;
  end;
  if order > high(fwidgets) then begin
   order:= high(fwidgets);
  end;
  if removeitem(pointerarty(fwidgets),child) >= 0 then begin
   insertitem(pointerarty(fwidgets),order,child);
  end;
 end;
end;

procedure twidget.getchildren(proc: tgetchildproc; root: tcomponent);
var
 int1: integer;
 widget: twidget;
begin
 for int1:= 0 to high(fwidgets) do begin
  widget:= fwidgets[int1];
  if (ws_iswidget in widget.fwidgetstate) and
     ((widget.owner = root) or 
        (widget.owner<> nil) and (csinline in root.componentstate) and
           (issubcomponent(widget.owner,root) or //common owner
               issubcomponent(root,widget.owner))) then begin
  {
  if ((widget.owner = root) or (csinline in root.componentstate) and
      not (csancestor in widget.componentstate) and
       issubcomponent(widget.owner,root)) and (ws_iswidget in widget.fwidgetstate) then begin
       }
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
 mask2: optionswidgetty = [ow_hinton,ow_hintoff];
var
 value,value1,value2,delta: optionswidgetty;
begin
 if avalue <> foptionswidget then begin
  value1:= optionswidgetty(setsinglebit(longword(avalue),
          longword(foptionswidget),longword(mask1)));
  value2:= optionswidgetty(setsinglebit(longword(avalue),
          longword(foptionswidget),longword(mask2)));
  value:= value1 * mask1 + value2 * mask2 + (avalue - (mask1 + mask2));
  delta:= optionswidgetty(longword(value) xor longword(foptionswidget));
  foptionswidget:= value;
  if (delta * [ow_background,ow_top] <> []) then begin
   if fparentwidget <> nil  then begin
    fparentwidget.sortzorder;
   end
   else begin
    if ownswindow then begin
     appinst.updatewindowstack;
    end;
   end;
  end;
  if delta * [ow_fontlineheight,ow_fontglyphheight] <> [] then begin
   updatefontheight;
  end;
  if (ow_autosize in delta) and (ow_autosize in avalue) then begin
   checkautosize;
  end;
  {
  if ow_nofocusrect in delta then begin
   invalidate;
  end;
  }
 end;
end;

procedure twidget.objectchanged(const sender: tobject);
begin
 if fface <> nil then begin
  fface.checktemplate(sender);
 end;
 if fframe <> nil then begin
  fframe.checktemplate(sender);
 end;
end;

procedure twidget.objectevent(const sender: tobject; const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) then begin
  objectchanged(sender);
 end;
end;

procedure twidget.receiveevent(const event: tobjectevent);
begin
 inherited;
 case event.kind of
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

function twidget.canclose(const newfocus: twidget = nil): boolean;
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
 if not (ws1_fontheightlock in fwidgetstate1) then begin
  fontchanged;
 end;
end;

procedure twidget.fontchanged;
var
 int1: integer;
begin
 if componentstate * [csdestroying,csloading] = [] then begin
  invalidate;
  if not (ws_loadedproc in fwidgetstate) then begin
   for int1:= 0 to high(fwidgets) do begin
    fwidgets[int1].parentfontchanged;
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
  appinst.postevent(tobjectevent.create(ek_childscaled,ievent(self)));
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
  if (int1 <> 0) and not (ws1_fontheightlock in fwidgetstate1) then begin
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
   if (id = 0) or not appinst.findwindow(id,window1) then begin
    window1:= fwindow;
   end;
   subpoint1(po1,window1.fowner.fwidgetrect.pos);
   appinst.eventlist.insert(0,tmouseevent.create(window1.winid,
     eventkind = ek_buttonrelease,button,mw_none,po1,shiftstate,info.timestamp,
     true));
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

function twidget.getfontclass: widgetfontclassty;
begin
 result:= twidgetfont;
end;

procedure twidget.internalcreatefont;
begin
 if ffont = nil then begin
  ffont:= getfontclass.create;
 end;
 ffont.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
end;

procedure twidget.syncsinglelinefontheight(const lineheight: boolean = false);
var
 int1: integer;
begin
 if lineheight then begin
  int1:= getfont.lineheight;
 end
 else begin
  int1:= getfont.glyphheight;
 end;
 if fframe = nil then begin
  bounds_cy:= bounds_cy + int1 + 2 - paintsize.cy
 end
 else begin
  bounds_cy:= bounds_cy + int1 + fframe.framei_top + 
             fframe.framei_bottom - paintsize.cy;
 end;
end;

procedure twidget.synctofontheight;
begin
 setfontheight;
end;

function twidget.getfont1: twidgetfont;
var
 widget1: twidget;
begin
 widget1:= self;
 repeat
  result:= widget1.ffont;
  if result <> nil then begin
   exit;
  end;
  widget1:= widget1.fparentwidget;
 until widget1 = nil;
 result:= stockobjects.fonts[stf_default];
end;

function twidget.getfont: twidgetfont;
begin
 getoptionalobject(ffont,{$ifdef FPC}@{$endif}internalcreatefont);
 result:= getfont1;
end;

function twidget.getframefont: tfont;
begin
 if fparentwidget <> nil then begin
  result:= fparentwidget.getfont1;
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
  setoptionalobject(avalue,ffont,{$ifdef FPC}@{$endif}internalcreatefont);
  fontchanged;
 end;
end;

function twidget.getframe: tcustomframe;
begin
 getoptionalobject(fframe,{$ifdef FPC}@{$endif}internalcreateframe);
 result:= fframe;
end;

procedure twidget.setframe(const avalue: tcustomframe);
begin
 if (ws_staticframe in fwidgetstate) then begin
  if (avalue <> nil) and (pointer(avalue) <> pointer(1)) then begin
   fframe.assign(avalue);
  end;
 end
 else begin
  setoptionalobject(avalue,fframe,{$ifdef FPC}@{$endif}internalcreateframe);
 end;
end;

function twidget.getface: tcustomface;
begin
 getoptionalobject(fface,{$ifdef FPC}@{$endif}internalcreateface);
 result:= fface;
end;

procedure twidget.setface(const avalue: tcustomface);
begin
 if (ws_staticface in fwidgetstate) then begin
  if (avalue <> nil) and (pointer(avalue) <> pointer(1)) then begin
   fface.assign(avalue);
  end;
 end
 else begin
  setoptionalobject(avalue,fface,{$ifdef FPC}@{$endif}internalcreateface);
 end;
 invalidate;
end;
{
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
}
function twidget.getcomponentstate: tcomponentstate;
begin
 result:= componentstate;
end;

function twidget.getframeclicked: boolean;
begin
 result:= ws_clicked in widgetstate;
end;

function twidget.getframemouse: boolean;
begin
 result:= ws_mouseinclient in widgetstate;
end;

function twidget.getframeactive: boolean;
begin
 result:= ws_active in fwidgetstate;
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

function twidget.isloading: boolean;
begin
 result:= ([csloading,csdestroying] * componentstate <> []) or 
                               (ws_loadlock in fwidgetstate);
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

procedure twidget.activate(const abringtofront: boolean = true);
begin
 if abringtofront then begin
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
   if fwidgets[high(fwidgets)] <> self then begin
    removeitem(pointerarty(fwidgets),self);
    additem(pointerarty(fwidgets),self);
    sortzorder;
   end;
  end;
 end
 else begin
  window.bringtofront;
 end;
end;

procedure twidget.sendtoback;
begin
 if fparentwidget <> nil then begin
  with fparentwidget do begin
   if fwidgets[0] <> self then begin
    removeitem(pointerarty(fwidgets),self);
    insertitem(pointerarty(fwidgets),0,pointer(self));
    sortzorder;
   end;
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

class function twidget.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_widget;
end;

procedure twidget.getautopaintsize(var asize: sizety);
begin
 //default
end;

procedure twidget.checkautosize;
begin
 if (ow_autosize in foptionswidget) and 
         ([csloading,csdestroying] * componentstate = []) then begin
  internalsetwidgetrect(fwidgetrect,false);
 end;
end;

procedure twidget.scale(const ascale: real);
var
 int1: integer;
 rect1: rectty;
begin
 include(fwidgetstate1,ws1_fontheightlock);
 try
  rect1:= fwidgetrect;
  if fframe <> nil then begin
   fframe.scale(ascale);
  end;
  if ffont <> nil then begin
   ffont.scale(ascale);
  end;
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].scale(ascale);
  end;
  with rect1 do begin
   x:= round(x*ascale);
   y:= round(y*ascale);
   cx:= round(cx*ascale);
   cy:= round(cy*ascale);
  end;  
  with fminsize do begin
   cx:= round(cx*ascale);
   cy:= round(cy*ascale);
  end;
  with fmaxsize do begin
   cx:= round(cx*ascale);
   cy:= round(cy*ascale);
  end;
  widgetrect:= rect1;
 finally
  exclude(fwidgetstate1,ws1_fontheightlock);
 end;
end;

function twidget.maxclientsize: sizety;
begin
 result:= clientsize;
end;

procedure twidget.fontcanvaschanged;
var
 int1: integer;
begin
 for int1:= 0 to high(fwidgets) do begin
  fwidgets[int1].fontcanvaschanged;
 end;
 if frame <> nil then begin
  fframe.fontcanvaschanged;
 end;
 checkautosize;
end;

function twidget.getactface: tcustomface;
begin
 result:= fface;
end;

function twidget.getdragrect(const apos: pointty): rectty;
begin
 with result do begin
  x:= apos.x - mindragdist;
  y:= apos.y - mindragdist;
  cx:= 2 * mindragdist;
  cy:= 2 * mindragdist;
 end;
end;

procedure twidget.setoptionsskin(const avalue: optionsskinty);
begin
 foptionsskin:= avalue;
 if osk_noskin in avalue then begin
  include(fmsecomponentstate,cs_noskin);
 end
 else begin
  exclude(fmsecomponentstate,cs_noskin);
 end;
end;

function twidget.skininfo: skininfoty;
begin
 result:= inherited skininfo;
 if osk_container in foptionsskin then begin
  include(result.options,sko_container);
 end;
end;

{ twindow }

constructor twindow.create(aowner: twidget);
begin
 fowner:= aowner;
 fowner.fwindow:= self;
 fcanvas:= tcanvas.create(self,icanvas(self));
 fasynccanvas:= tcanvas.create(self,icanvas(self));
 fscrollnotifylist:= tnotifylist.create;
 inherited create;
 fowner.rootchanged; //nil all references
end;

destructor twindow.destroy;
begin
 appinst.twindowdestroyed(self);
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
 fscrollnotifylist.free;
end;

procedure twindow.setasynccanvas(const acanvas: tcanvas);
begin
 include(fstate,tws_canvasoverride);
 acanvas.initflags(fasynccanvas);
 fowner.fontcanvaschanged;
end;

procedure twindow.releaseasynccanvas;
begin
 if tws_canvasoverride in fstate then begin
  exclude(fstate,tws_canvasoverride);
  fasynccanvas.initflags(fasynccanvas);
 end;
end;

procedure twindow.sizeconstraintschanged;
begin
 if fwindow.id <> 0 then begin
  guierror(gui_setsizeconstraints(fwindow.id,fowner.fminsize,fowner.fmaxsize));
 end;
end;

function twindow.haswinid: boolean;
begin
 result:= fwindow.id <> 0;
end;

procedure twindow.createwindow;
var
 gc: gcty;
 aoptions: windowinfoty;
 aoptions1: internalwindowoptionsty;
begin
 if fwindow.id = 0 then begin
  fnormalwindowrect:= fowner.fwidgetrect;
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
   if transientfor <> ftransientfor then begin
    checkrecursivetransientfor(transientfor);
    setlinkedvar(transientfor,tlinkedobject(ftransientfor));
    if transientfor <> nil then begin
     aoptions1.transientfor:= transientfor.winid;
    end
    else begin
     aoptions1.transientfor:= 0;
    end;
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

  guierror(gui_createwindow(fowner.fwidgetrect,aoptions1,fwindow),self);
  sizeconstraintschanged;
  fstate:= fstate - [tws_posvalid,tws_sizevalid];
  fillchar(gc,sizeof(gcty),0);
  guierror(gui_creategc(fwindow.id,gck_screen,gc),self);
  fcanvas.linktopaintdevice(fwindow.id,gc,fowner.fwidgetrect.size,nullpoint);
  finalize(gc);
  fillchar(gc,sizeof(gcty),0);
  guierror(gui_creategc(fwindow.id,gck_screen,gc),self);
  fasynccanvas.linktopaintdevice(fwindow.id,gc,fowner.fwidgetrect.size,nullpoint);
  if appinst <> nil then begin
   tinternalapplication(application).registerwindow(self);
  end;
  if fcaption <> '' then begin
   gui_setwindowcaption(fwindow.id,fcaption);
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
 if appinst <> nil then begin
  if appinst.caret.islinkedto(fcanvas) then begin
   appinst.caret.hide;
//   tcaret1(app.fcaret).remove;
  end;
  appinst.unregisterwindow(self);
 end;
 fcanvas.unlink;
 fasynccanvas.unlink;
 if fwindow.id <> 0 then begin
  appinst.windowdestroyed(fwindow.id);
 end;
 gui_destroywindow(fwindow);
 fillchar(fwindow,sizeof(fwindow),0);
 exclude(fstate,tws_windowvisible);
end;

procedure twindow.windowdestroyed;
begin
 fwindow.id:= 0;
 destroywindow;
end;

procedure twindow.checkwindow(windowevent: boolean);
begin
 if (appinst <> nil) and (aps_inited in appinst.fstate) then begin
  if fwindow.id = 0 then begin
   createwindow;
  end
  else begin
   if fstate * [tws_posvalid,tws_sizevalid] <>
           [tws_posvalid,tws_sizevalid] then begin
    if visible and not windowevent and not (tws_needsdefaultpos in fstate) and
        (fmoving <= 0) then begin
     fnormalwindowrect:= fowner.fwidgetrect;
     guierror(gui_reposwindow(fwindow.id,fnormalwindowrect),self);
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
  if (ftransientfor <> nil) and (force or (appinst.ffocuslockwindow = nil)) and 
                                (wo_popup in foptions) then begin
   appinst.ffocuslockwindow:= self;
   appinst.ffocuslocktransientfor:= ftransientfor;
  end;
  if appinst.ffocuslockwindow = nil then begin
   guierror(gui_setwindowfocus(fwindow.id),self);
  end;
 end;
 
var
 activecountbefore: cardinal;
 activewindowbefore: twindow;
 widgetar: widgetarty;
 int1: integer;
begin
 if appinst.finactivewindow = self then begin
  appinst.finactivewindow:= nil;
 end;
 activewindowbefore:= appinst.factivewindow;
 show(windowevent);
 widgetar:= nil; //compilerwarning
 if  activewindowbefore <> self then begin
  if force or (appinst.fmodalwindow = nil) or (appinst.fmodalwindow = self) or 
                        (ftransientfor = appinst.fmodalwindow) then begin
   if (ffocusedwidget = nil) and fowner.canfocus then begin
    fowner.setfocus(true);
    exit;
   end;
   if activewindowbefore <> nil then begin
    activewindowbefore.deactivate;
   end;
   if appinst.factivewindow = nil then begin
    if not (ws_active in fowner.fwidgetstate) then begin
     if not (tws_activatelocked in fstate) then begin
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
     end;
     appinst.factivewindow:= self;
//     if factivecount <> activecountbefore then begin
//      exit;
//     end;
     gui_setimefocus(fwindow);
     if not windowevent then begin
      setwinfoc;
     end
     else begin
      appinst.ffocuslockwindow:= nil;
     end;
    end;
   end;
   appinst.fonactivechangelist.doactivechange(activewindowbefore,self);
  end
  else begin
   appinst.fwantedactivewindow:= self;
  end;
 end
 else begin
  setwinfoc;
 end;
end;

procedure twindow.noactivewidget;
var
 widget: twidget;
 activecountbefore: cardinal;
begin
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
end;

procedure twindow.lockactivate;
begin
 noactivewidget;
 include(fstate,tws_activatelocked);
end;

procedure twindow.unlockactivate;
begin
 exclude(fstate,tws_activatelocked);
end;

procedure twindow.deactivate;
var
 activecountbefore: cardinal;
begin
 if appinst.ffocuslockwindow = self then begin
  appinst.ffocuslockwindow:= nil;
 end;
 if ws_active in fowner.fwidgetstate then begin
  noactivewidget;
  if appinst.factivewindow = self then begin
   inc(factivecount);
   activecountbefore:= factivecount;
   appinst.fonactivechangelist.doactivechange(appinst.factivewindow,nil);
   if factivecount = activecountbefore then begin
    appinst.factivewindow:= nil;
    gui_unsetimefocus(fwindow);
   end;
  end;
 end
 else begin
  if appinst.factivewindow = self then begin
   appinst.factivewindow:= nil; //should never happen
  end;
 end;
end;

function twindow.deactivateintermediate: boolean;
begin
 deactivate;
 if appinst.factivewindow = nil then begin
  result:= true;
  appinst.finactivewindow:= self;
 end
 else begin
  result:= false;
 end;
end;

procedure twindow.reactivate; //clears appinst.finactivewindow
begin
 appinst.finactivewindow:= nil;
 activate;
end;

procedure twindow.hide(windowevent: boolean);
var
 int1: integer;
 window1: twindow;
begin
 releasemouse;
 if not(ws_visible in fowner.fwidgetstate) then begin
  if fwindow.id <> 0 then begin
   if tws_windowvisible in fstate then begin
    if not windowevent or (appinst.factivewindow = self) then begin
     endmodal;
    end;
    if (application.fmainwindow = self) and not appinst.terminated then begin
     gui_flushgdi;
     sys_sched_yield;
//     sleep(0);     //give windowmanager time to unmap all windows
     appinst.sortzorder;
     exclude(fstate,tws_windowvisible);
     include(fstate,tws_grouphidden);
     include(fstate,tws_groupminimized);
     for int1:= 0 to high(appinst.fwindows) do begin
      window1:= appinst.fwindows[int1];
      if (window1 <> self) and (window1.fwindow.id <> 0) and 
                        gui_windowvisible(window1.fwindow.id) then begin
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
     gui_hidewindow(fwindow.id);
    end;
   end;
  end;
  settransientfor(nil,windowevent);
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
   include(appinst.fstate,aps_needsupdatewindowstack);
   if not (csdesigning in fowner.ComponentState) then begin
    if not windowevent then begin
//     if fwindowpos <> wp_minimized then begin
      case fwindowpos of
       wp_maximized: begin
        size1:= wsi_maximized;
       end;
       wp_fullscreen: begin
        size1:= wsi_fullscreen;
       end
       else begin
        size1:= wsi_normal;
       end;
      end;
      gui_setwindowstate(winid,size1,true);
//     end;
//     gui_showwindow(winid);
     if (fwindowpos = wp_normal) and 
                               not (tws_needsdefaultpos in fstate) then begin
//      gui_reposwindow(fwinid,fowner.fwidgetrect);
      gui_reposwindow(fwindow.id,fnormalwindowrect);
     end;
    end;
    exclude(fstate,tws_grouphidden);
    exclude(fstate,tws_groupminimized);
    for int1:= 0 to high(appinst.fwindows) do begin
     window1:= appinst.fwindows[int1];
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
var
 pt1: pointty;
 event1: tmouseevent;
 win1: winidty;
begin
 fmodalresult:= mr_none;
 with appinst do begin
  deactivatehint;
  if (fmousecapturewidget <> nil) and
         not fowner.checkdescendent(fmousecapturewidget) then begin
   fmousecapturewidget.releasemouse;
  end;
  if fmodalwindow = nil then begin
   fwantedactivewindow:= nil; //init for lowest level
  end;
  appinst.cursorshape:= cr_default;
  win1:= fmousewinid;
  processleavewindow;
  fmousewinid:= win1;
  result:= beginmodal(self);
  if (fmodalwindow = nil) then begin
   if fwantedactivewindow <> nil then begin
    fwantedactivewindow.activate;
    fwantedactivewindow:= nil;
   end;
  end
  else begin
   if fmodalwindow = fwantedactivewindow then begin
    fwantedactivewindow:= nil;
   end;
   fmodalwindow.activate;
  end;
  if (factivewindow <> nil) and not factivewindow.fowner.releasing then begin
   pt1:= mouse.pos;
   if pointinrect(pt1,factivewindow.fowner.fwidgetrect) then begin
    event1:= tmouseevent.create(factivewindow.winid,false,mb_none,mw_none,
        subpoint(pt1,factivewindow.fowner.fwidgetrect.pos),[],0,false);
    try 
     appinst.processmouseevent(event1); //simulate mousemove
    finally
     event1.free1;
    end;
   end;
  end;
 end;
end;

procedure twindow.endmodal;
begin
 appinst.endmodal(self);
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
 if not (windowpos in [wp_minimized,wp_maximized,wp_fullscreen]) then begin
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
  bo1:= appinst.caret.islinkedto(fcanvas) and
   testintersectrect(fcanvas.clipbox,appinst.caret.rootcliprect);
  if bo1 then begin
   tcaret1(appinst.fcaret).remove;
  end;
  include(fstate,tws_painting);
  if flushgdi then begin
   try
    fupdateregion:= 0;
    result:= true;
    fowner.paint(fcanvas);
   finally
    if bo1 then begin
     tcaret1(appinst.fcaret).restore;
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
     fowner.paint(bmp.canvas);
     bmp.paint(fcanvas,rect1);
    end
    else begin
     fupdateregion:= 0;
    end;
   finally
    bmp.Free;
    if bo1 then begin
     tcaret1(appinst.fcaret).restore;
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
 info:= appinst.fmouseparkeventinfo;
 info.eventkind:= ek_mousepark;
 exclude(info.eventstate,es_processed);
 dispatchmouseevent(info,appinst.fmousecapturewidget);
end;

procedure twindow.checkmousewidget(const info: mouseeventinfoty; var capture: twidget);
begin
 if capture = nil then begin
  capture:= fowner.mouseeventwidget(info);
  if (capture = nil) and (tws_grab in fstate) then begin
   capture:= fowner;
  end;
 end;
 appinst.setmousewidget(capture);
end;

procedure twindow.dispatchmouseevent(var info: mouseeventinfoty;
                           capture: twidget);
var
 posbefore: pointty;
 int1: integer;
 po1: peventaty;
begin
{
 if info.eventkind in [ek_mouseenter,ek_mouseleave] then begin
  exit;
 end;
 }
 if info.eventkind = ek_mousewheel then begin
  capture:= fowner.mouseeventwidget(info);
 end
 else begin
  checkmousewidget(info,capture);
 end;
 if capture <> nil then begin
  with capture do begin
   subpoint1(info.pos,rootpos);
   posbefore:= info.pos;
   appinst.fdelayedmouseshift:= nullpoint;
   if info.eventkind = ek_mousewheel then begin
    mousewheelevent(mousewheeleventinfoty(info));
   end
   else begin
    mouseevent(info);
   end;
   posbefore:= subpoint(info.pos,posbefore);
   addpoint1(posbefore,appinst.fdelayedmouseshift);
   if (posbefore.x <> 0) or (posbefore.y <> 0) then begin
    gui_flushgdi;
    with appinst do begin
     getevents;
     po1:= peventaty(eventlist.datapo);
     for int1:= 0 to eventlist.count -1 do begin
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
var
 widget1: twidget;
begin
 if appinst.fkeyboardcapturewidget <> nil then begin
  widget1:= appinst.fkeyboardcapturewidget;
 end
 else begin
  widget1:= ffocusedwidget;
 end;
 if widget1 <> nil then begin
  case eventkind of
   ek_keypress: widget1.internalkeydown(info);
   ek_keyrelease: widget1.dokeyup(info);
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
 focusedwidgetbefore: twidget;
 widget1: twidget;
 widgetar: widgetarty;
 int1,int2: integer;
 bo1: boolean;
begin
 widgetar:= nil; //compiler warning
 if ffocusedwidget <> widget then begin
  inc(ffocuscount);
  focuscountbefore:= ffocuscount;
  focusedwidgetbefore:= ffocusedwidget;
  widget1:= ffocusedwidget;
  if widget1 <> nil then begin
   if not (csdestroying in widget1.componentstate) then begin
    if not widget1.canclose(widget) then begin
     exit;
    end;
    if (ffocuscount <> focuscountbefore) then begin
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
  if (widget <> nil) and not widget.canfocus then begin
   exit;
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
   bo1:= appinst.factivewindow = self;
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
  fowner.dofocuschanged(focusedwidgetbefore,ffocusedwidget);
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
  if appinst <> nil then begin
   appinst.invalidated;
  end;
 end;
end;

procedure twindow.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if not (es_broadcast in info.eventstate) then begin
  if not (es_processed in info.eventstate) then begin
   if tws_modal in fstate then begin
    include(info.eventstate,es_modal);
   end;
   try
    include(info.eventstate,es_local);
    try
     appinst.fonshortcutlist.dokeyevent(sender,info);
    finally
     exclude(info.eventstate,es_local);
    end;
    if not (es_processed in info.eventstate) and 
                                not (tws_localshortcuts in fstate) then begin
     appinst.checkshortcut(self,sender,info);
    end;
   finally
    exclude(info.eventstate,es_modal);
   end;
  end;
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
 if appinst <> nil then begin
  gui_flushgdi;
  appinst.getevents;
  for int1:= 0 to appinst.eventlist.count - 1 do begin
   event:= twindowrectevent(appinst.eventlist[int1]);
   if (event <> nil) and (event.kind = ek_expose) and
             (event.fwinid = fwindow.id) then begin
    invalidaterect(event.frect);
    appinst.eventlist[int1]:= nil;
    event.free1;
   end;
  end;
  internalupdate;
  gui_flushgdi;
 end;
end;

procedure twindow.movewindowrect(const dist: pointty;
  const rect: rectty);
begin
 gui_movewindowrect(fwindow.id,dist,rect);
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
 include(appinst.fstate,aps_needsupdatewindowstack);
end;

procedure twindow.sendtoback;
begin
 gui_lowerwindow(winid);
 include(appinst.fstate,aps_needsupdatewindowstack);
end;

procedure twindow.stackunder(const predecessor: twindow);
begin
 if (predecessor <> self) then begin
  appinst.stackunder(self,predecessor);
  include(appinst.fstate,aps_needsupdatewindowstack);
 end;
end;

procedure twindow.stackover(const predecessor: twindow);
var
 ar1: windowarty;
begin
 ar1:= nil; //compiler warning
 if predecessor = nil then begin
  appinst.sortzorder;
  ar1:= appinst.windowar;
  if high(ar1) >= 0 then begin
   stackunder(ar1[0]);
  end;
 end
 else begin
  if (predecessor <> self) and (predecessor <> nil) then begin
   appinst.stackover(self,predecessor);
   include(appinst.fstate,aps_needsupdatewindowstack);
  end;
 end;
end;

function twindow.stackedover: twindow; //nil if top
var
 ar1: windowarty;
 int1: integer;

begin
 appinst.sortzorder;
 ar1:= appinst.windowar;
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
 appinst.sortzorder;
 ar1:= appinst.windowar;
 result:= nil;
 for int1:= 0 to high(ar1)-1 do begin
  if ar1[int1] = self then begin
   result:= ar1[int1+1];
   break;
  end;
 end;
end;

function twindow.hastransientfor: boolean;
begin
 result:= ftransientforcount > 0;
end;

procedure twindow.capturemouse;
begin
 if appinst.grabpointer(winid) then begin
  include(fstate,tws_grab);
 end;
end;

procedure twindow.releasemouse;
begin
 if tws_grab in fstate then begin
  exclude(fstate,tws_grab);
  appinst.ungrabpointer;
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
   if fwindow.id <> 0 then begin
    if value <> nil then begin
     gui_settransientfor(fwindow.id,value.winid);
    end
    else begin
     gui_settransientfor(fwindow.id,0);
    end;
   end;
  end;
 end;
end;

function twindow.winid: winidty;
begin
 checkwindow(false);
 result:= fwindow.id;
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
 result:= (appinst <> nil) and (appinst.fmodalwindow = nil) or (appinst.fmodalwindow = self);
end;

procedure twindow.activate;
begin
 if fowner.visible then begin
  internalactivate(false);
 end;
end;

function twindow.active: boolean;
begin
 result:= appinst.factivewindow = self;
end;

procedure twindow.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 if fwindow.id <> 0 then begin
  gui_setwindowcaption(fwindow.id,fcaption);
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
      (fwindow.id <> 0) and (gui_getwindowsize(fwindow.id) <> wsi_minimized);
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
  wsi_fullscreen: begin
   result:= wp_fullscreen;
  end;
  else begin //wsi_normal
   if fwindowpos in [wp_minimized,wp_maximized,wp_fullscreen,wp_screencentered] then begin
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
 bo1: boolean;
 wpo1: windowposty;
begin
 wpo1:= getwindowpos;
 if wpo1 <> value then begin
  bo1:= (tws_windowvisible in fstate) {or (wpo1 = wp_minimized)};
  case value of
   wp_screencentered: begin
    gui_setwindowstate(winid,wsi_normal,bo1{tws_windowvisible in fstate});
    rect2:= appinst.workarea(self);
    with fowner do begin
     rect1:= widgetrect;
     rect1.x:= rect2.x + (rect2.cx - rect1.cx) div 2;
     rect1.y:= rect2.y + (rect2.cy - rect1.cy) div 2;
     widgetrect:= rect1;
    end;
   end;
   wp_minimized: begin
    gui_setwindowstate(winid,wsi_minimized,bo1{tws_windowvisible in fstate});
   end;
   wp_maximized: begin
    gui_setwindowstate(winid,wsi_maximized,bo1);
   end;
   wp_fullscreen: begin
    gui_setwindowstate(winid,wsi_fullscreen,bo1);
   end
   else begin
    gui_setwindowstate(winid,wsi_normal,bo1{tws_windowvisible in fstate});
   end;
  end;
 end;
 fwindowpos := Value;
 if (wpo1 = wp_fullscreen) and (value = wp_normal) then begin
  gui_reposwindow(fwindow.id,fnormalwindowrect);
       //needed for win32
 end;
end;

function twindow.updaterect: rectty;
begin
 result:= fcanvas.regionclipbox(fupdateregion);
end;

procedure twindow.postkeyevent(const akey: keyty; 
       const ashiftstate: shiftstatesty = []; const release: boolean = false;
       const achars: msestring = '');
begin
 application.postevent(tkeyevent.create(winid,release,akey,akey,
             ashiftstate,achars));
end;

procedure twindow.beginmoving;
begin
 inc(fmoving);
end;

procedure twindow.endmoving;
begin
 dec(fmoving);
 if fmoving = 0 then begin
  checkwindow(false);
 end;
end;

procedure twindow.registeronscroll(const method: notifyeventty);
begin
 fscrollnotifylist.add(tmethod(method));
end;

procedure twindow.unregisteronscroll(const method: notifyeventty);
begin
 fscrollnotifylist.remove(tmethod(method));
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

 {tonwinideventlist}

procedure tonwinideventlist.doevent(const awinid: winidty);
begin
 factitem:= 0;
 while factitem < fcount do begin
  winideventty(getitempo(factitem)^)(awinid);
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

constructor tmouseevent.create(const winid: winidty; const release: boolean;
                      const button: mousebuttonty; const wheel: mousewheelty;
                      const pos: pointty; const shiftstate: shiftstatesty;
                      atimestamp: cardinal; const reflected: boolean = false);
var
 eventkind1: eventkindty;
begin
 if (atimestamp = 0) and (button <> mb_none) then begin
  inc(atimestamp);
 end;
 ftimestamp:= atimestamp;
 if wheel = mw_none then begin
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
 end
 else begin
  eventkind1:= ek_mousewheel;
 end;
 inherited create(eventkind1,winid);
 fbutton:= button;
 fwheel:= wheel;
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
 appinst:= self;
 inherited;
 fdblclicktime:= defaultdblclicktime;
// inherited;
 fonkeypresslist:= tonkeyeventlist.create;
 fonshortcutlist:= tonkeyeventlist.create;
 fonactivechangelist:= tonactivechangelist.create;
 fonwindowdestroyedlist:= tonwindoweventlist.create;
 fonwiniddestroyedlist:= tonwinideventlist.create;
 fonapplicationactivechangedlist:= tonapplicationactivechangedlist.create;
// fwindows:= tpointerlist.create;
 fcaret:= tcaret.create;
 fmouse:= tmouse.create(imouse(self));
 fhinttimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}hinttimer,false);
 fmouseparktimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}mouseparktimer,false);
end;

destructor tinternalapplication.destroy;
begin
 destroyforms;
 fmouseparktimer.free;
 fhinttimer.free;
 fhintwidget.free;
 freeandnil(fcaret);
 fmouse.free;
 deinitialize;
 inherited;
// fwindows.free;
 fonkeypresslist.free;
 fonshortcutlist.free;
 fonactivechangelist.free;
 fonwindowdestroyedlist.free;
 fonwiniddestroyedlist.free;
 fonapplicationactivechangedlist.free;
end;

procedure tinternalapplication.twindowdestroyed(const sender: twindow);
var
 int1: integer;
begin
 fonwindowdestroyedlist.doevent(sender);
 for int1:= high(fwindowstack) downto 0 do begin
  with fwindowstack[int1] do begin
   if (lower = sender) or (upper = sender) then begin
    deleteitem(fwindowstack,typeinfo(windowstackinfoarty),int1);
//    lower:= nil;
   end;
  end;
 end;
 if factivewindow = sender then begin
  factivewindow:= nil;
 end;
 if finactivewindow = sender then begin
  finactivewindow:= nil;
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

procedure tinternalapplication.processleavewindow;
begin
 fmouseparktimer.enabled:= false;
 {
 if factmousewindow <> nil then begin
  fillchar(info,sizeof(info),0);
  info.eventkind:= ek_mouseleave;
  factmousewindow.dispatchmouseevent(info,nil);
 end;
 }
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
end;

procedure tinternalapplication.processwindowcrossingevent(event: twindowevent);
var
 window: twindow;
 info: mouseeventinfoty;
begin
 if findwindow(event.fwinid,window) then begin
  if event.kind = ek_leavewindow then begin
   processleavewindow;
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
 if (factmousewindow <> nil) and ((fmodalwindow = nil) or 
                            (fmodalwindow = factmousewindow)) then begin
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
 widget1: twidget;
 pt1: pointty;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   fillchar(info,sizeof(info),0);
   with info do begin
    if freflected then begin
     include(eventstate,es_reflected);
    end;
    if kind = ek_enterwindow then begin
     info.eventkind:= ek_mousemove;
    end
    else begin
     info.eventkind:= kind;
    end;
    if kind = ek_mousewheel then begin
     mousewheeleventinfoty(info).wheel:= fwheel;
    end
    else begin
     button:= fbutton;
    end;
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
   {
   if factmousewindow <> window then begin
    ek1:= info.eventkind;
    info.eventkind:= ek_mouseenter;
    window.dispatchmouseevent(info,nil);
    info.eventkind:= ek1;
   end;
   }
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
    widget1:= fmousewidget;
//    widget1:= fmousehintwidget;
    if widget1 <> nil then begin
     widget1:= widget1.widgetatpos(info.pos);
             //search diabled child
    end;
    while (widget1 <> nil) and not (widget1.enabled or 
                (ow_disabledhint in widget1.foptionswidget)) do begin
     widget1:= widget1.parentwidget;
    end;
    if widget1 <> nil then begin
     if widget1.fframe <> nil then begin
      with widget1.fframe do begin
       checkstate;
       pt1:= translatewidgetpoint(abspos,nil,widget1);
       if not (pointinrect(pt1,fpaintrect) or 
           (fs_captionhint in fstate) and pointincaption(pt1)) then begin
        widget1:= nil;
       end;
      end;
     end;
    end;
    if (widget1 <> fhintedwidget) then begin
     if (widget1 <> fhintwidget) and
               (fhintedwidget <> nil) or (fhintwidget = nil) then begin
      deactivatehint;
      fhintedwidget:= widget1;
      if fhintedwidget <> nil then begin
       fhinttimer.interval:= -hintdelaytime;
       fhinttimer.enabled:= true;
      end;
     end;
    end
    else begin
     if (fhintedwidget <> nil) and (fhintwidget = nil) and 
                                  (kind = ek_mousemove) then begin
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
 window1: twindow;
 widget1: twidget;
 info: keyeventinfoty;
 shift: shiftstatesty;
begin
 with event do begin
  if findwindow(fwinid,window1) then begin
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
    if fkeyboardcapturewidget <> nil then begin
     window1:= fkeyboardcapturewidget.window;
     widget1:= fkeyboardcapturewidget;
    end
    else begin
     window1:= factivewindow;
     if window1 <> nil then begin
      widget1:= factivewindow.ffocusedwidget;
     end
     else begin
      widget1:= nil; //compiler warning
     end;
    end;
    if window1 <> nil then begin
     fmouseparkeventinfo.shiftstate:= shiftstatesty(
        replacebits({$ifdef FPC}longword{$else}byte{$endif}(shiftstate),
          {$ifdef FPC}longword{$else}byte{$endif}(fmouseparkeventinfo.shiftstate),
          {$ifdef FPC}longword{$else}byte{$endif}(keyshiftstatesmask)));
     if kind = ek_keypress then begin
      fonkeypresslist.dokeyevent(widget1,info);
     end;
     if not (es_processed in eventstate) then begin
      window1.dispatchkeyevent(kind,info);
     end;
    end;
   end;
  end;
 end;
end;

function tinternalapplication.getevents: integer;
begin
 while gui_hasevent do begin
  eventlist.add(gui_getevent);
 end;
 result:= eventlist.count;
end;

procedure tinternalapplication.waitevent;
begin
 while gui_hasevent do begin
  eventlist.add(gui_getevent);
 end;
 if eventlist.count = 0 then begin
  incidlecount;
  include(fstate,aps_waiting);
  eventlist.add(gui_getevent);
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
 for int1:= 0 to eventlist.count - 1 do begin
  event:= tevent(eventlist[int1]);
  if (event <> nil) and (event.kind = ek_mousemove) then begin
   event.free1;
   eventlist[int1]:= nil;
  end;
 end;
end;

procedure tinternalapplication.windowdestroyed(id: winidty);
var
 int1: integer;
 event : tevent;
begin
 fonwiniddestroyedlist.doevent(id);
 if not terminated then begin
  for int1:= 0 to getevents - 1 do begin
   event:= tevent(eventlist[int1]);
   if (event is twindowevent) and (twindowevent(event).fwinid = id) then begin
   {
    case event.kind of
     ek_focusin: tcaret1(fcaret).restore;
     ek_focusout: tcaret1(fcaret).remove;
    end;
    }
    event.Free1;
    eventlist[int1]:= nil;
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
    if fmodalwindow.fwindow.id <> 0 then begin
     if not fmodalwindow.visible then begin
      gui_showwindow(fmodalwindow.fwindow.id);
     end;
     if ffocuslockwindow <> nil then begin //reactivate modal window
      if ffocuslocktransientfor <> nil then begin
       gui_setwindowfocus(ffocuslocktransientfor.winid);
      end;
     end
     else begin
      gui_setwindowfocus(fmodalwindow.fwindow.id);
     end;
     gui_raisewindow(fmodalwindow.fwindow.id);
    end;
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
  if finditem(pointerarty(fwindows),window) >= 0 then begin
   guierror(gue_alreadyregistered,window.fowner.name);
  end;
  additem(pointerarty(fwindows),window);
  exclude(fstate,aps_zordervalid);
 finally
  unlock;
 end;
end;

procedure tinternalapplication.unregisterwindow(window: twindow);
begin
 lock;
 try
  removeitem(pointerarty(fwindows),window);
  if window.fwindow.id = fmousewinid then begin
   fmousewinid:= 0;
  end;
 finally
  unlock;
 end;
end;

procedure tinternalapplication.doterminate(const shutdown: boolean);
begin
 if fonterminatequerylist.doterminatequery then begin
  if shutdown then begin
   include(fstate,aps_terminated);
  end
  else begin
   terminated:= true;
  end;
 end
 else begin
  if shutdown then begin
   gui_cancelshutdown;
  end;
 end;
end;

procedure tinternalapplication.checkshortcut(const sender: twindow;
               const awidget: twidget; var info: keyeventinfoty);
var
 int1: integer;
begin
 include(info.eventstate,es_broadcast);
 for int1:= high(fwindows) downto 0 do begin
  if fwindows[int1] <> sender then begin
   fwindows[int1].doshortcut(info,awidget);
   if (es_processed in info.eventstate) then begin
    break;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  appinst.fonshortcutlist.dokeyevent(awidget,info);
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
   for int1:= 0 to high(fwindows) do begin
    with fwindows[int1].fowner do begin
     if visible then begin
      activate;
      break;
     end;
    end;
   end;
   if (factivewindow = nil) and (high(fwindows) >= 0) then begin
    fwindows[0].fowner.activate;
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
   hidehint;
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
  po1:= pointer(eventlist.datapo);
  for int1:= 0 to eventlist.count - 1 do begin
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
 po1{,po2}: ^twindowevent;
 waitcountbefore: integer;
 ar1: integerarty;
 
begin       //eventloop
 lock;
 try
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
   amodalwindow.internalactivate(false,true);
  end;
 
  if not ismainthread then begin
   raise exception.create('Eventloop must be in main thread.');
  end;
 
  while not modalinfo.modalend and not terminated and 
                 not (aps_exitloop in fstate) do begin //main eventloop
   try
    if getevents = 0 then begin
     checkwindowstack;
     repeat
      bo1:= false;
      exclude(fstate,aps_invalidated);
      for int1:= 0 to high(fwindows) do begin
       exclude(fstate,aps_invalidated);
       try
        bo1:= fwindows[int1].internalupdate or bo1;
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
    event:= tevent(eventlist.getfirst);
    if event <> nil then begin
//writeln('event ',getenumname(typeinfo(eventkindty),ord(event.kind)));
//flush(output);
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
         doterminate(true);
        end;
        ek_focusin: begin
         getevents;
         po1:= pointer(eventlist.datapo);
         bo1:= true;
 
         for int1:= 0 to eventlist.count - 1 do begin
          if po1^ <> nil then begin
           with po1^ do begin
            if (kind = ek_destroy) and 
                            (fwinid = twindowevent(event).fwinid) then begin
             bo1:= false;
            end;
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
         include(fstate,aps_needsupdatewindowstack);
         if bo1 then begin
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
         processwindowcrossingevent(twindowevent(event));
         if event is tmouseenterevent then begin
          processmouseevent(tmouseenterevent(event));
         end;
        end;
        ek_leavewindow: begin
         getevents;
         ar1:= nil;
         po1:= pointer(eventlist.datapo);
         bo1:= true;
         for int1:= 0 to eventlist.count - 1 do begin
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
          po1:= pointer(eventlist.datapo);
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
        ek_buttonpress,ek_buttonrelease,ek_mousewheel: begin
         processmouseevent(tmouseevent(event));
        end;
        ek_keypress,ek_keyrelease: begin
         processkeyevent(tkeyevent(event));
        end;
        ek_synchronize: begin
         tsynchronizeevent(event).deliver;
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
       event.free1;
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
 finally
  unlock;
 end;
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
 end;
 bo1:= ismainthread and unlock;
 try
  result:= eventloop(sender);
 finally
  if bo1 then begin
   lock;
  end;
  if (window1 <> nil) then begin
   window1.activate;
   setlinkedvar(nil,tlinkedobject(window1));
  end;
 end;
end;

procedure tinternalapplication.endmodal(const sender: twindow);
begin
 with sender do begin
  if tws_modal in fstate then begin
   if not appinst.terminated then begin
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
     if (lower <> nil) then begin
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
var
 window1: twindow;
begin
 result:= 0;
 if (tws_windowvisible in twindow(l).fstate) then begin
  if not (tws_windowvisible in twindow(r).fstate) then begin
   inc(result,64);
  end
 end
 else begin
  if (tws_windowvisible in twindow(r).fstate) then begin
   dec(result,64);
  end
  else begin
   exit; //both invisible -> no change in order
  end;
 end;
 if ow_background in twindow(l).fowner.foptionswidget then dec(result);
 if ow_top in twindow(l).fowner.foptionswidget then inc(result);
 if ow_background in twindow(r).fowner.foptionswidget then inc(result);
 if ow_top in twindow(r).fowner.foptionswidget then dec(result);
 if twindow(l).ftransientfor <> nil then begin
  inc(result,8);
 end;
 if twindow(r).ftransientfor <> nil then begin
  dec(result,8);
 end;
 if twindow(l).ftransientforcount > 0 then begin
  inc(result,4);
 end;
 if twindow(r).ftransientforcount > 0 then begin
  dec(result,4);
 end;
 {
 if twindow(l).ftransientforcount > 0 then begin
  inc(result,4);
 end;
 if (tws_modal in twindow(l).fstate) or (twindow(l).ftransientfor <> nil)
            then begin
  inc(result,16);
  if twindow(l).ftransientforcount > 0 then begin
   dec(result,8);
  end;
 end;
 if twindow(r).ftransientforcount > 0 then begin
  dec(result,4);
 end;
 if (tws_modal in twindow(r).fstate) or (twindow(r).ftransientfor <> nil)
            then begin
  dec(result,16);
  if twindow(r).ftransientforcount > 0 then begin
   inc(result,8);
  end;
 end;
 }
 window1:= twindow(l);
 while window1.ftransientfor <> nil do begin
  if window1.ftransientfor = twindow(r) then begin
   inc(result,32);
{
writeln('+ ',twindow(r).owner.name+' '+window1.owner.name);
window1:= twindow(r);
while window1.ftransientfor <> nil do begin
 if window1.ftransientfor = twindow(l) then begin
  dec(result,32);
  exit;
 end;
 window1:= window1.ftransientfor;
end;  
}
   exit;
  end;
  window1:= window1.ftransientfor;
 end;
 window1:= twindow(r);
 while window1.ftransientfor <> nil do begin
  if window1.ftransientfor = twindow(l) then begin
//writeln('- ',twindow(l).owner.name+' '+window1.owner.name);
   dec(result,32);
   exit;
  end;
  window1:= window1.ftransientfor;
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
{$ifdef mse_debugzorder}
 writeln('*********');
 for int1:= 0 to high(ar3) do begin
  write(ar3[int1].fowner.name,' ');
  if ar3[int1].ftransientfor = nil then begin
   writeln('nil');
  end
  else begin
   writeln(ar3[int1].ftransientfor.fowner.name);
  end;
 end;
{$endif}
 ar4:= copy(ar3);
 sortarray(ar3,{$ifdef FPC}@{$endif}compwindowzorder,sizeof(ar3[0]));
 int2:= -1;
{$ifdef mse_debugzorder}
 writeln('+++');
 for int1:= 0 to high(ar3) do begin
  write(ar3[int1].fowner.name,' ');
  if ar3[int1].ftransientfor = nil then begin
   writeln('nil');
  end
  else begin
   writeln(ar3[int1].ftransientfor.fowner.name);
  end;
 end;
{$endif}
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
 if fkeyboardcapturewidget = widget then begin
  fkeyboardcapturewidget:= nil; 
 end;
 if fcaretwidget = widget then begin
  fcaretwidget:= nil;
 end;
 if fmousewidget = widget then begin
  setmousewidget(nil);
 end;
 if fmousehintwidget = widget then begin
  fmousehintwidget:= nil;
 end;
 if fhintforwidget = widget then begin
  deactivatehint;
 end;
 if fhintedwidget = widget then begin
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

{ tguiapplication }

procedure tguiapplication.initialize;
begin
 with tinternalapplication(self) do begin
  if not (aps_inited in fstate) and (finiting = 0) then begin
   inc(finiting);
   try
    fdesigning:= false;
    fstate:= [];
    guierror(gui_init,self);
    msetimer.init;
    msegraphics.init;
    include(fstate,aps_inited);
   finally
    dec(finiting);
   end;
  end;
 end;
end;

procedure tguiapplication.deinitialize;
begin
 with tinternalapplication(self) do begin
  if aps_inited in fstate then begin
   include(fstate,aps_deinitializing);
   try
    if fcaret <> nil then begin
     fcaret.link(nil,nullpoint,nullrect);
    end;
    msegraphics.deinit;
    lock;
    gui_flushgdi;
    flusheventbuffer;
    getevents;
    eventlist.clear;
    unlock;
    gui_deinit;
    msetimer.deinit;
    exclude(fstate,aps_inited);
   finally
    exclude(fstate,aps_deinitializing);
   end;
  end;
 end;
end;

procedure tguiapplication.destroyforms;
begin
 while componentcount > 0 do begin
  components[0].free;  //destroy loaded forms
 end;
 while high(fwindows) >= 0 do begin
  fwindows[0].fowner.free;
 end;
end;

procedure tguiapplication.checkwindowrect(winid: winidty; var rect: rectty);
var
 window: twindow;
begin
 if findwindow(winid,window) then begin
  window.fowner.checkwidgetsize(rect.size);
 end;
end;

procedure tguiapplication.setclientmousewidget(const widget: twidget);
var
 info: mouseeventinfoty;
begin
 if fclientmousewidget <> widget then begin
  fillchar(info,sizeof(info),0);
  if (fclientmousewidget <> nil) and
             not (csdestroying in fclientmousewidget.componentstate) then begin
   exclude(fclientmousewidget.fwidgetstate,ws_mouseinclient);
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

procedure tguiapplication.setmousewidget(const widget: twidget);
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

function tguiapplication.grabpointer(const id: winidty): boolean;
var
 int1: integer;
begin
 for int1:= 0 to high(fwindows) do begin
  with fwindows[int1] do begin
   if fwindow.id <> id then begin
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

function tguiapplication.ungrabpointer: boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(fwindows) do begin
  if tws_grab in fwindows[int1].fstate then begin
   exit;
  end;
 end;
 gui_ungrabpointer;
 exclude(fstate,aps_mousecaptured);
 result:= true;
end;

procedure tguiapplication.capturemouse(sender: twidget; grab: boolean);
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

procedure tguiapplication.createform(instanceclass: widgetclassty; var reference);
begin
 mseclasses.createmodule(self,instanceclass,reference);
end;

procedure tguiapplication.eventloop(const once: boolean = false);
             //used in win32 wm_queryendsession and wm_entersizemove
begin
 inc(feventlooping);
 try
  tinternalapplication(self).eventloop(nil,once);
 finally
  dec(feventlooping);
 end;
end;

procedure tguiapplication.exitloop;  //used in win32 cancelshutdown
begin
 include(fstate,aps_exitloop);
end;

procedure tguiapplication.processmessages;
begin
 gui_flushgdi;
 sys_sched_yield;
 inherited;
end;

procedure tguiapplication.invalidated;
begin
 if not (aps_invalidated in fstate) then begin
  include(fstate,aps_invalidated);
  wakeupmainthread;
 end;
end;

procedure tguiapplication.showasyncexception(e: exception; 
                                  const leadingtext: string = '');
var
 str1: ansistring;
begin
 str1:= leadingtext + e.Message;
 postevent(tasyncmessageevent.create(str1,'Exception'));
end;

procedure tguiapplication.showexception(e: exception; 
                                  const leadingtext: string = '');
var
 str1: ansistring;
begin
 if not ismainthread then begin
  showasyncexception(e,leadingtext);
 end
 else begin
  str1:= leadingtext + e.Message;
  showmessage(str1,'Exception');
 end;
end;

procedure tguiapplication.errormessage(const amessage: msestring);
begin
 showerror(amessage);
end;

function tguiapplication.active: boolean;
begin
 result:= aps_active in fstate;
end;

function tguiapplication.findwindow(id: winidty; out window: twindow): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(fwindows) do begin
  if fwindows[int1].fwindow.id = id then begin
   window:= fwindows[int1];
   result:= true;
   exit;
  end;
 end;
 window:= nil;
end;

function tguiapplication.screensize: sizety;
begin
 result:= gui_getscreensize;
end;

function tguiapplication.workarea(const awindow: twindow = nil): rectty;
var
 id: winidty;
begin
 id:= 0;
 if awindow = nil then begin
  if factivewindow <> nil then begin
   id:= factivewindow.fwindow.id;
  end;
 end
 else begin
  id:= awindow.fwindow.id;
 end;
 result:= gui_getworkarea(id);
end;

function tguiapplication.activewindow: twindow;
begin
 result:= factivewindow;
end;

function tguiapplication.regularactivewindow: twindow;
begin
 result:= factivewindow;
 while (result <> nil) and (result.ftransientfor <> nil) do begin
  result:= result.ftransientfor;
 end;
end;

function tguiapplication.unreleasedactivewindow: twindow;
begin
 result:= factivewindow;
 while (result <> nil) and result.fowner.releasing do begin
  result:= result.ftransientfor;
 end;
end;

function tguiapplication.activewidget: twidget;
begin
 if factivewindow <> nil then begin
  result:= factivewindow.ffocusedwidget;
 end
 else begin
  result:= nil;
 end;
end;

function tguiapplication.activerootwidget: twidget;
begin
 if factivewindow <> nil then begin
  result:= factivewindow.fowner;
 end
 else begin
  result:= nil;
 end;
end;

function tguiapplication.windowatpos(const pos: pointty): twindow;
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

function tguiapplication.findwidget(const namepath: string; out awidget: twidget): boolean;
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

function tguiapplication.windowar: windowarty;
begin
 setlength(result,length(fwindows));
 if result <> nil then begin
  move(fwindows[0],result[0],length(result)*sizeof(pointer));
 end;
end;

function tguiapplication.winidar: winidarty;
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

function tguiapplication.getwindows(const index: integer): twindow;
begin
 checkarrayindex(fwindows,index);
 result:= fwindows[index];
end;

function tguiapplication.windowcount: integer;
begin
 result:= length(fwindows);
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

procedure tguiapplication.sortzorder; //top is last, invisibles first
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
   orderarray(ar3,pointerarty(fwindows));
   sortarray(pointerarty(fwindows),{$ifdef FPC}@{$endif}cmpwindowvisibility);
//   fwindows.order(ar3);
//   fwindows.sort({$ifdef FPC}@{$endif}cmpwindowvisibility);
  end;
  include(fstate,aps_zordervalid);
 end;
end;

function tguiapplication.bottomwindow: twindow;
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

function tguiapplication.topwindow: twindow;
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

procedure tguiapplication.internalshowhint(const sender: twidget);
var
 window1: twindow;
begin
 fhintforwidget:= sender;
 with tinternalapplication(self),fhintinfo do begin
//  if sender <> nil then begin
//   window1:= sender.window;
//  end
//  else begin
   window1:= activewindow;
//  end;
  fhintwidget:= thintwidget.create(nil,window1,fhintinfo);
  fhintwidget.show;
  if showtime <> 0 then begin
   fhinttimer.interval:= -showtime;
   fhinttimer.enabled:= true;
  end;
 end;
end;

procedure tguiapplication.inithintinfo(var info: hintinfoty; const ahintedwidget: twidget);
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

procedure tguiapplication.showhint(const sender: twidget; const hint: msestring;
              const aposrect: rectty; const aplacement: captionposty = cp_bottomleft;
              const ashowtime: integer = defaulthintshowtime; //0 -> inifinite,
                 // -1 defaultshowtime if ow_timedhint in sender.optionswidget
              const aflags: hintflagsty = defaulthintflags
                      );
begin
 deactivatehint;
 fhintedwidget:= sender;
 with fhintinfo do begin
  mouserefpos:= fmouse.pos;
  flags:= aflags;
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

procedure tguiapplication.showhint(const sender: twidget; const hint: msestring;
              const apos: pointty;
              const ashowtime: integer = defaulthintshowtime; //0 -> inifinite,
                 // -1 defaultshowtime if ow_timedhint in sender.optionswidget
              const aflags: hintflagsty = defaulthintflags
                      );
begin
 showhint(sender,hint,makerect(apos,nullsize),cp_bottomleft,ashowtime,aflags);
end;

procedure tguiapplication.showhint(const sender: twidget; const info: hintinfoty);
begin
 with info do begin
  if (hfl_show in flags) or (caption <> '') then begin
   showhint(sender,caption,posrect,placement,showtime,flags);
  end;
 end;
end;

procedure tguiapplication.hidehint;
begin
 deactivatehint;
end;

function tguiapplication.hintedwidget: twidget;
begin
 result:= fhintedwidget;
end;

function tguiapplication.activehintedwidget: twidget;
begin
 if tinternalapplication(self).fhintwidget = nil then begin
  result:= nil;
 end
 else begin
  result:= fhintedwidget;
 end;
end;

function tguiapplication.activehelpcontext: msestring;
begin
 if activewidget = nil then begin
  result:= '';
 end
 else begin
  result:= activewidget.helpcontext;
 end;
end;

function tguiapplication.mousehelpcontext: msestring;
begin
 if mousewidget = nil then begin
  result:= '';
 end
 else begin
  result:= mousewidget.helpcontext;
 end;
end;

procedure tguiapplication.activatehint;
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

procedure tguiapplication.deactivatehint;
begin
 with tinternalapplication(self) do begin
  freeandnil(fhintwidget);
  fhinttimer.enabled:= false;
  finalize(fhintinfo);
  fhintinfo.flags:= [];
  fhintforwidget:= nil;
 end;
end;

procedure tguiapplication.hinttimer(const sender: tobject);
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

procedure tguiapplication.setmainwindow(const Value: twindow);
var
 int1: integer;
 id: winidty;
begin
 fmainwindow:= value;
 if value <> nil then begin
  if value.fowner.isgroupleader then begin
   id:= value.winid;
   for int1:= 0 to high(fwindows) do begin
    with fwindows[int1] do begin
     if fwindow.id <> 0 then begin
      gui_setwindowgroup(fwindow.id,id);
     end;
    end;
   end;
  end;
 end;
end;

procedure tguiapplication.mouseparkevent; //simulates mouseparkevent
begin
 if fmousewidget <> nil then begin
  fmousewidget.window.mouseparked;
 end;
end;

procedure tguiapplication.registeronkeypress(const method: keyeventty);
begin
 tinternalapplication(self).fonkeypresslist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronkeypress(const method: keyeventty);
begin
 tinternalapplication(self).fonkeypresslist.remove(tmethod(method));
end;

procedure tguiapplication.registeronshortcut(const method: keyeventty);
begin
 tinternalapplication(self).fonshortcutlist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronshortcut(const method: keyeventty);
begin
 tinternalapplication(self).fonshortcutlist.remove(tmethod(method));
end;

procedure tguiapplication.registeronactivechanged(const method: activechangeeventty);
begin
 tinternalapplication(self).fonactivechangelist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronactivechanged(const method: activechangeeventty);
begin
 tinternalapplication(self).fonactivechangelist.remove(tmethod(method));
end;

procedure tguiapplication.registeronwindowdestroyed(const method: windoweventty);
begin
 tinternalapplication(self).fonwindowdestroyedlist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronwindowdestroyed(const method: windoweventty);
begin
 tinternalapplication(self).fonwindowdestroyedlist.remove(tmethod(method));
end;

procedure tguiapplication.registeronwiniddestroyed(const method: winideventty);
begin
 tinternalapplication(self).fonwiniddestroyedlist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronwiniddestroyed(const method: winideventty);
begin
 tinternalapplication(self).fonwiniddestroyedlist.remove(tmethod(method));
end;

procedure tguiapplication.registeronapplicationactivechanged(const method: booleaneventty);
begin
 tinternalapplication(self).fonapplicationactivechangedlist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronapplicationactivechanged(const method: booleaneventty);
begin
 tinternalapplication(self).fonapplicationactivechangedlist.remove(tmethod(method));
end;

procedure tguiapplication.updatecursorshape; //restores cursorshape of mousewidget
begin
 if fclientmousewidget <> nil then begin
  fclientmousewidget.updatecursorshape(true);
 end
 else begin
  cursorshape:= cr_default;
 end;
end;

procedure tguiapplication.setcursorshape(const Value: cursorshapety);
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

procedure tinternalapplication.dopostevent(const aevent: tevent);
begin
 gui_postevent(aevent);
end;

procedure tinternalapplication.doeventloop(const once: boolean);
begin
 eventloop(nil,once);
end;

procedure tguiapplication.beginwait;
begin
 lock;
 try
  if fwaitcount = 0 then begin
   gui_resetescapepressed;
  end;
  inc(fwaitcount);
  mouse.shape:= cr_wait;
 finally
  unlock;
 end;
end;

procedure tguiapplication.endwait;
var
 int1: integer;
 po1: ^tevent;
begin
 lock;
 try
  if fwaitcount > 0 then begin
   dec(fwaitcount);
   if fwaitcount = 0 then begin
    with tinternalapplication(self) do begin
     getevents;
     po1:= pointer(eventlist.datapo);
     for int1:= 0 to eventlist.count - 1 do begin
      if (po1^ <> nil) and (po1^.kind in waitignoreevents) then begin
       freeandnil(po1^);
      end;
      inc(po1);
     end;
     checkcursorshape;
    end;
   end;
  end;
 finally
  unlock;
 end;
end;

function tguiapplication.waiting: boolean;
begin
 result:= fwaitcount > 0;
end;

function tguiapplication.waitescaped: boolean;
begin
 lock;
 result:= waiting and gui_escapepressed;
 if not result then begin
  tinternalapplication(self).getevents;
  result:= gui_escapepressed;
 end;
 unlock;
end;

procedure tguiapplication.langchanged;
begin
 inherited;
 invalidate;
end;

function tguiapplication.candefocus: boolean;
var
 int1: integer;
begin
 result:= true;
 for int1:= 0 to high(fwindows) do begin
  if not fwindows[int1].candefocus then begin
   result:= false;
   break;
  end;
 end;
end;

function tguiapplication.terminating: boolean;
begin
 result:= aps_terminating in fstate;
end;

function tguiapplication.deinitializing: boolean;
begin
 result:= aps_deinitializing in fstate;
end;

procedure tguiapplication.terminate(const sender: twindow = nil);
var
 int1: integer;
begin
 include(fstate,aps_terminating);
 try
  int1:= 0;
  while int1 <= high(fwindows) do begin
   if (fwindows[int1] <> sender) and 
                not fwindows[int1].fowner.canparentclose(nil) then begin
    exit;
   end;
   inc(int1);
  end; 
  tinternalapplication(self).doterminate(false);
 finally
  exclude(fstate,aps_terminating);
 end;
end;

procedure tguiapplication.delayedmouseshift(const ashift: pointty);
begin
 addpoint1(fdelayedmouseshift,ashift);
end;

procedure tguiapplication.invalidate;
var
 int1: integer;
begin
 for int1:= 0 to high(fwindows) do begin
  fwindows[int1].fowner.invalidate;
 end;
end;

procedure tguiapplication.restarthint(const sender: twidget);
begin
 with tinternalapplication(self) do begin
  if fhintedwidget = sender then begin
   deactivatehint;
   fhinttimer.interval:= -hintdelaytime;
   fhinttimer.enabled:= true;
  end;
 end;
end;

procedure tguiapplication.receiveevent(const event: tobjectevent);
begin
 if (event.kind = ek_user) and (event is tasyncmessageevent) then begin
  with tasyncmessageevent(event) do begin
   showmessage(fmessage,fcaption);   
  end;
 end;
 inherited;
end;

procedure tguiapplication.dowaitidle(var again: boolean);
begin
 unregisteronidle({$ifdef FPC}@{$endif}dowaitidle);
 processmessages;
 fexecuteaction(self);
end;

function tguiapplication.waitdialog(const athread: tthreadcomp = nil;
               const atext: msestring = '';
               const caption: msestring = '';
               const acancelaction: notifyeventty = nil;
               const aexecuteaction: notifyeventty = nil): boolean;
var
 res1: modalresultty;
 wo1: longword;
begin
 if not ismainthread then begin
  raise exception.create('Waitdialog must be called from main thread.');
 end;
 result:= false;
 wo1:= exceptioncount;
 if not (aps_waitstarted in fstate) then begin
  with tinternalapplication(self) do begin
   fmodalwindowbeforewaitdialog:= fmodalwindow;
   resetwaitdialog;
   include(fstate,aps_waitstarted);
   fexecuteaction:= aexecuteaction;
   if assigned(aexecuteaction) then begin
    registeronidle({$ifdef FPC}@{$endif}dowaitidle);
   end;
   try
    if athread <> nil then begin
     fonterminatebefore:= athread.onterminate;
     athread.onterminate:= {$ifdef FPC}@{$endif}dothreadterminated;
     athread.run;
    end;
    repeat
    until showmessage(atext,caption,[mr_cancel],mr_cancel,[],0,
                                              [acancelaction]) = mr_cancel;
    if wo1 <> exceptioncount then begin
     sysutils.abort;
    end;
    result:= aps_waitok in fstate;
    if not result then begin
     include(fstate,aps_waitcanceled);
    end
    else begin
     include(fstate,aps_waitterminated);
    end;
    if athread <> nil then begin
     athread.terminate;
     athread.waitfor;
    end;
   finally
    exclude(fstate,aps_waitstarted);
    if athread <> nil then begin
     athread.onterminate:= fonterminatebefore;
    end;
   end;
  end;
 end;
end;

procedure tguiapplication.cancelwait;
begin
 lock;
 with tinternalapplication(self) do begin
  if not waitcanceled and (fmodalwindow <> fmodalwindowbeforewaitdialog) and
             (fmodalwindow <> nil) then begin
   fmodalwindow.modalresult:= mr_cancel;
  end;
 end;
 unlock;
end;

procedure tguiapplication.terminatewait;
begin
 lock;
 include(fstate,aps_waitok);
 cancelwait;
 unlock;
end;

procedure tguiapplication.resetwaitdialog;
begin
 lock;
 fstate:= fstate - [aps_waitstarted,aps_waitcanceled,aps_waitterminated,
                                          aps_waitok];
 unlock;
end;

function tguiapplication.waitstarted: boolean;
begin
 lock;
 result:= aps_waitstarted in fstate;
 unlock;
end;

function tguiapplication.waitcanceled: boolean;
begin
 lock;
 result:= aps_waitcanceled in fstate;
 unlock;
end;

function tguiapplication.waitterminated: boolean;
begin
 lock;
 result:= aps_waitterminated in fstate;
 unlock;
end;

procedure tguiapplication.dothreadterminated(const sender: tthreadcomp);
begin
 if not waitcanceled then begin
  terminatewait;
 end;
 if assigned(fonterminatebefore) then begin
  fonterminatebefore(sender);
 end;
end;

procedure tguiapplication.dopostevent(const aevent: tevent);
begin
 if feventlooping = 0 then begin
  gui_postevent(aevent);
 end
 else begin
  eventlist.add(aevent);
 end;
end;

procedure tguiapplication.settimer(const us: integer);
begin
 gui_settimer(us);
end;

procedure tguiapplication.doafterrun;
begin
 destroyforms; //zeos lib unloads libraries -> 
               //forms must be destroyed before unit finalization
end;

function tguiapplication.idle: boolean;
begin
 result:= inherited idle and not gui_hasevent;
end;

{ tasyncmessageevent }

constructor tasyncmessageevent.create(const amessage: msestring;
                                            const acaption: msestring);
begin
 fmessage:= amessage;
 fcaption:= acaption;
 inherited create(ek_user,ievent(application));
end;

{ tmousenterevent }

constructor tmouseenterevent.create(const winid: winidty; const pos: pointty;
               const shiftstate: shiftstatesty; atimestamp: cardinal);
begin
 inherited create(winid,false,mb_none,mw_none,pos,shiftstate,atimestamp);
 fkind:= ek_enterwindow;
end;

{ twidgetshowevent }

procedure twidgetshowevent.execute;
begin
 fmodalresult:= fwidget.show(fmodal,ftransientfor);
end;

initialization
 registerapplicationclass(tinternalapplication);
end.
