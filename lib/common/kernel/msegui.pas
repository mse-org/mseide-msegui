{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegui;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 classes,mclasses,sysutils,msegraphics,msetypes,
 msestrings,mseerr,msegraphutils,mseapplication,msedragglob,
 msepointer,mseevent,msekeyboard,mseclasses,mseglob,mseguiglob,mselist,
 msesystypes,msethread,mseguiintf,{msesysdnd,}
 msebitmap,msearrayprops,msethreadcomp,mserichstring,msearrayutils
                               {$ifdef mse_with_ifi},mseifiglob{$endif};

const
 mseguiversiontext = '3.5';
 
 defaultwidgetcolor = cl_default;
 defaulttoplevelwidgetcolor = cl_background;
 defaultfadecolor = cl_ltgray;
 defaultfadecolor1 = cl_dkgray;
 defaultfadeopacolor = cl_white;
 hintdelaytime = 500000; //us
 defaulthintshowtime = 3000000; //us
 mouseparktime = 500000; //us
 defaultdblclicktime = 400000; //us
 mindragdist = 4;

 mousebuttons = [ss_left,ss_right,ss_middle];

type

 gdiregionty = record
  gdi: pgdifunctionaty;
  region: regionty;
 end;

 frameskinoptionty = (fso_flat,
                      fso_noanim,fso_nomouseanim,fso_noclickanim,fso_nofocusanim,
                      fso_nofocusrect,fso_nodefaultrect,fso_noinnerrect);
 frameskinoptionsty = set of frameskinoptionty;

 frameskincontrolleroptionty =
                     (fsco_colorclient,  //set colorclient in skincontroller
                      fsco_frameileftsize,fsco_frameirightsize,
                      fsco_frameitopsize,fsco_frameibottomsize); 
                                        //adjust clientsize in skincontroller
 frameskincontrolleroptionsty = set of frameskincontrolleroptionty;
  
 optionwidgetty = (ow_background,ow_top,
                   ow_noautosizing, //don't use, moved to optionswidget1
                   ow_mousefocus,ow_tabfocus,
                   ow_parenttabfocus,ow_arrowfocus,
                   ow_arrowfocusin,ow_arrowfocusout,
                   ow_subfocus,         //reflects focus to children
                   ow_focusbackonesc,                   
                   ow_keyreturntaborder, 
                     //key_return and key_enter work like key_tab
                   ow_nochildshortcut,  //do not propagate shortcuts to parent
                   ow_noparentshortcut, //do not react to shortcuts from parent
                   ow_canclosenil,      // don't use, moved to optionswidget1
                   ow_mousetransparent,ow_mousewheel,
                   ow_noscroll,ow_nochildpaintclip,ow_nochildclipsiblings,
                   ow_destroywidgets,ow_nohidewidgets,
                   ow_hinton,ow_hintoff,ow_disabledhint,ow_multiplehint,
                   ow_timedhint
                   );
 optionswidgetty = set of optionwidgetty;
 optionwidget1ty = (
                    ow1_fontglyphheight,
                          //track font.glyphheight, 
                          //create fonthighdelta and childscaled events
                    ow1_fontlineheight, 
                         //track font.linespacing,
                         //create fonthighdelta and childscaled events
                    ow1_autoscale, //synchronizes bounds_cy or bonds_cx 
                                  //with fontheightdelta
                    ow1_autowidth,ow1_autoheight,
                    ow1_autosizeanright,ow1_noautosizeanright,
                    ow1_autosizeanbottom,ow1_noautosizeanbottom,
                    ow1_noparentwidthextend,ow1_noparentheightextend,
                    ow1_canclosenil, //call canclose(nil) on exit
                    ow1_nocancloseifhidden,
                    ow1_modalcallonactivate,ow1_modalcallondeactivate,
                               //used in tactionwidget
                    ow1_noautosizing //used in tdockcontroller
                    );
                                         
const
 deprecatedoptionswidget= [ow_noautosizing,ow_canclosenil];
 invisibleoptionswidget = [ord(ow_noautosizing),ord(ow_canclosenil)]; 

type
 optionswidget1ty = set of optionwidget1ty;
 
 optionskinty = (osk_skin,osk_noskin,osk_framebuttononly,
                 osk_noframe,osk_noface,osk_nooptions,
                 osk_container,osk_noclientsize,
                 osk_colorcaptionframe, 
                   //use widget_colorcaptionframe independent of caption
                 osk_nocolorcaptionframe, 
                   //don't use widget_colorcaptinframe independent of caption
                 osk_nopropleft,osk_noproptop,     //used by tlayouter
                 osk_nopropwidth,osk_nopropheight, //used by tlayouter
                 osk_nopropfont,                   //used by tlayouter
                 osk_noalignx,osk_noaligny,        //used by tlayouter
                 osk_nolayoutcx,osk_nolayoutcy     //used by syncmaxaoutsize()
                 );
 optionsskinty = set of optionskinty;
 
 anchorty = (an_left,an_top,an_right,an_bottom);
 anchorsty = set of anchorty;

 widgetstatety = (ws_visible,ws_enabled,
                  ws_active,ws_entered,ws_entering,ws_exiting,ws_focused,
                  ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,
                  //valid after call of updatemousestate only
//                  ws_wantmousewheel,
                  ws_wantmousefocus,ws_iswidget,
                  ws_opaque,ws_nopaint,
                  ws_lclicked,ws_mclicked,ws_rclicked,
                  ws_mousecaptured,ws_clientmousecaptured,
                  ws_newmousecapture,
                  ws_loadlock,ws_loadedproc,ws_showproc,
                  ws_minclientsizevalid,
//                  ws_showed,ws_hidden, //used in tcustomeventwidget
                  ws_destroying,
                  ws_staticframe,ws_staticface,
                  ws_isvisible
                 );
 widgetstatesty = set of widgetstatety;
 widgetstate1ty = (ws1_childscaled,ws1_childrectchanged,
                   ws1_scaling,ws1_autoscaling,ws1_autosizing,
                   ws1_painting,ws1_updateopaque,
                   ws1_widgetregionvalid,ws1_rootvalid,
                   ws1_anchorsizing,ws1_anchorsetting,ws1_parentclientsizeinited,
                   ws1_parentupdating, //set while setparentwidget
                   ws1_isstreamed,     //used by ttabwidget
                   ws1_scaled,         //used in tcustomscalingwidget
                   ws1_forceclose,
                   ws1_noclipchildren,ws1_tryshrink,
                   ws1_noframewidgetshift,ws1_framemouse,
                   ws1_nodesignvisible,ws1_nodesignframe,ws1_nodesignhandles,
                   ws1_nodesigndelete,ws1_nodesignmove,
                   ws1_designactive,ws1_designwidget,
                   ws1_fakevisible,ws1_nominsize,
                         //used for report size calculations
                   ws1_onkeydowncalled
                   );
 widgetstates1ty = set of widgetstate1ty;

 framestatety = (fs_sbhorzon,fs_sbverton,fs_sbhorzfix,fs_sbvertfix,
                 fs_sbhorztop,fs_sbvertleft,
                 fs_sbleft,fs_sbtop,fs_sbright,fs_sbbottom,
                 fs_nowidget,fs_nosetinstance,fs_framemouse,
                 fs_disabled,fs_creating,
                 fs_cancaptionsyncx,fs_cancaptionsyncy,
                 fs_drawfocusrect,fs_paintrectfocus,
                 fs_captionfocus,fs_captionhint,fs_rectsvalid,
                 fs_widgetactive,fs_paintposinited,fs_needsmouseinvalidate);
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
                         ow_destroywidgets{,ow_autoscale}];
// defaultoptionswidget1 = [ow1_modalcallondeactivate];
 defaultoptionswidget1 = [ow1_autoscale];
 defaultoptionswidgetmousewheel = defaultoptionswidget + [ow_mousewheel];
 defaultoptionswidgetnofocus = defaultoptionswidget -
             [ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 defaultoptionsskin = [];
 defaultcontainerskinoptions = defaultoptionsskin + 
                                    [osk_container,osk_noclientsize];
 
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
                     frl_hiddenedges,
                     frl_fileft,frl_fitop,frl_firight,frl_fibottom,
                     frl_frameimagelist,frl_frameimageleft,frl_frameimagetop,
                     frl_frameimageright,frl_frameimagebottom,
                     frl_frameimageoffset,frl_frameimageoffset1,
                     frl_frameimageoffsetdisabled,frl_frameimageoffsetmouse,
                     frl_frameimageoffsetclicked,frl_frameimageoffsetactive,
                     frl_frameimageoffsetactivemouse,
                     frl_frameimageoffsetactiveclicked,
                     frl_optionsskin,
                     frl_colorclient,
                     frl_nodisable);
 framelocalpropsty = set of framelocalpropty;

 framelocalprop1ty = (frl1_framefacelist,
                      frl1_framefaceoffset,frl1_framefaceoffset1,
                      frl1_framefaceoffsetdisabled,frl1_framefaceoffsetmouse,
                      frl1_framefaceoffsetclicked,frl1_framefaceoffsetactive,
                      frl1_framefaceoffsetactivemouse,
                      frl1_framefaceoffsetactiveclicked,
                      frl1_font,frl1_captiondist,frl1_captionoffset
                     );
 framelocalprops1ty = set of framelocalprop1ty;

 framestateflagty = (fsf_offset1,fsf_disabled,fsf_active,fsf_mouse,fsf_clicked);
 framestateflagsty = set of framestateflagty;
 
const
 allframelocalprops: framelocalpropsty =
                    [frl_levelo,frl_leveli,frl_framewidth,
                     frl_colorframe,frl_colorframeactive,
                     frl_colordkshadow,frl_colorshadow,
                     frl_colorlight,frl_colorhighlight,
                     frl_colordkwidth,frl_colorhlwidth,
                     frl_hiddenedges,
                     frl_fileft,frl_fitop,frl_firight,frl_fibottom,
                     frl_frameimagelist,frl_frameimageleft,frl_frameimagetop,
                     frl_frameimageright,frl_frameimagebottom,
                     frl_frameimageoffset,frl_frameimageoffset1,
                     frl_frameimageoffsetdisabled,frl_frameimageoffsetmouse,
                     frl_frameimageoffsetclicked,frl_frameimageoffsetactive,
                     frl_frameimageoffsetactivemouse,
                     frl_frameimageoffsetactiveclicked,
                     frl_optionsskin,
                     frl_colorclient,
                     frl_nodisable];
 allframelocalprops1: framelocalprops1ty = [
                      frl1_framefacelist,
                      frl1_framefaceoffset,frl1_framefaceoffset1,
                      frl1_framefaceoffsetdisabled,frl1_framefaceoffsetmouse,
                      frl1_framefaceoffsetclicked,frl1_framefaceoffsetactive,
                      frl1_framefaceoffsetactivemouse,
                      frl1_framefaceoffsetactiveclicked,
                      frl1_font,frl1_captiondist,frl1_captionoffset];
type
 facelocalpropty = (fal_options,fal_fadirection,fal_image,
                    fal_fapos,fal_facolor,fal_faopapos,fal_faopacolor,
                    fal_fatransparency,
                    fal_faopacity,fal_frameimagelist,fal_frameimageoffset);
 facelocalpropsty = set of facelocalpropty;

const
 allfacelocalprops: facelocalpropsty =
                    [fal_options,fal_fadirection,fal_image,
                    fal_fapos,fal_facolor,fal_faopapos,fal_faopacolor,
                    fal_fatransparency,
                    fal_faopacity,fal_frameimagelist,fal_frameimageoffset];
deprecatedfacelocalprops = [fal_fatransparency];
invisiblefacelocalprops = [ord(fal_fatransparency)];

type

 
 twidget = class;
 tcustomframe = class;

 iframe = interface(inullinterface)
  procedure setframeinstance(instance: tcustomframe);
  procedure setstaticframe(value: boolean);
  function getstaticframe: boolean;
  procedure scrollwidgets(const dist: pointty);
  procedure clientrectchanged;
  function getcomponentstate: tcomponentstate;
  function getmsecomponentstate: msecomponentstatesty;
  procedure invalidate;
  procedure invalidatewidget;
  procedure invalidaterect(const rect: rectty; 
              const org: originty = org_client; const noclip: boolean = false);
  function getwidget: twidget;
  function getwidgetrect: rectty;
  function getframestateflags: framestateflagsty;
 end;

 icaptionframe = interface(iframe)
  function getcanvas(aorigin: originty = org_client): tcanvas;
  function getframefont: tfont;
  procedure setwidgetrect(const rect: rectty);
 end;

 iscrollframe = interface(icaptionframe)
  function widgetstate: widgetstatesty;
  function getzoomrefframe: framety;
 end;

 tfacelist = class;

 frameoffsetsty = record
  offset: integer;
  offset1: integer; 
  disabled: integer;
  mouse: integer;
  clicked: integer;
  active: integer;
  activemouse: integer;
  activeclicked: integer;
 end;

 frameimageoffsetsty = record
  offset: imagenrty;
  offset1: imagenrty; 
  disabled: imagenrty;
  mouse: imagenrty;
  clicked: imagenrty;
  active: imagenrty;
  activemouse: imagenrty;
  activeclicked: imagenrty;
 end;

 framefaceoffsetsty = record
  offset: facenrty;
  offset1: facenrty; 
  disabled: facenrty;
  mouse: facenrty;
  clicked: facenrty;
  active: facenrty;
  activemouse: facenrty;
  activeclicked: facenrty;
 end;

 baseframeinfoty = record
  levelo: integer;
  leveli: integer;
  framewidth: integer;
  colorframe: colorty;
  colorframeactive: colorty;
  hiddenedges: edgesty;
  framecolors: framecolorinfoty;
  colorclient: colorty;
  innerframe: framety;

  frameimage_left: integer;
  frameimage_top: integer;
  frameimage_right: integer;
  frameimage_bottom: integer;
  frameimage_offsets: frameimageoffsetsty;
 
  frameface_offsets: framefaceoffsetsty;
  optionsskin: frameskinoptionsty;
  
  frameface_list: tfacelist;   //not copied by move
  frameimage_list: timagelist; //
 end;

 captionframeinfoty = record
  captiondist: integer;
  captionoffset: integer;
  font: toptionalfont;
 end;

 frameinfoty = record
  ba: baseframeinfoty;
  capt: captionframeinfoty
 end;
  
 widgetatposinfoty = record
  pos: pointty;
  mouseeventinfopo: pmouseeventinfoty;
  parentstate,childstate: widgetstatesty
 end;

 tframecomp = class;

 tcustomframe = class(toptionalpersistent,iimagelistinfo)
  private
   flocalprops: framelocalpropsty;
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
   procedure sethiddenedges(const avalue: edgesty);
   function ishiddenedgesstored: boolean;

   procedure setframei(const avalue: framety);   
   procedure setframei_bottom(const Value: integer);
   function isfibottomstored: boolean;
   procedure setframei_left(const Value: integer);
   function isfileftstored: boolean;
   procedure setframei_right(const Value: integer);
   function isfirightstored: boolean;
   procedure setframei_top(const Value: integer);
   function isfitopstored: boolean;

   procedure setframeimage_list(const avalue: timagelist);
   function getimagelist: timagelist;
   function isframeimage_liststored: boolean;
   procedure setframeimage_left(const avalue: integer);
   function isframeimage_leftstored: boolean;
   procedure setframeimage_top(const avalue: integer);
   function isframeimage_topstored: boolean;
   procedure setframeimage_right(const avalue: integer);
   function isframeimage_rightstored: boolean;
   procedure setframeimage_bottom(const avalue: integer);
   function isframeimage_bottomstored: boolean;
   
   procedure setframeimage_offset(const avalue: imagenrty);
   function isframeimage_offsetstored: boolean;
   procedure setframeimage_offset1(const avalue: imagenrty);
   function isframeimage_offset1stored: boolean;
   procedure setframeimage_offsetdisabled(const avalue: imagenrty);
   function isframeimage_offsetdisabledstored: boolean;
   procedure setframeimage_offsetmouse(const avalue: imagenrty);
   function isframeimage_offsetmousestored: boolean;
   procedure setframeimage_offsetclicked(const avalue: imagenrty);
   function isframeimage_offsetclickedstored: boolean;
   procedure setframeimage_offsetactive(const avalue: imagenrty);
   function isframeimage_offsetactivestored: boolean;
   procedure setframeimage_offsetactivemouse(const avalue: imagenrty);
   function isframeimage_offsetactivemousestored: boolean;
   procedure setframeimage_offsetactiveclicked(const avalue: imagenrty);
   function isframeimage_offsetactiveclickedstored: boolean;

   procedure setframeface_list(const avalue: tfacelist);
   function isframeface_liststored: boolean;
   procedure setframeface_offset(const avalue: facenrty);
   function isframeface_offsetstored: boolean;
   procedure setframeface_offset1(const avalue: facenrty);
   function isframeface_offset1stored: boolean;
   procedure setframeface_offsetdisabled(const avalue: facenrty);
   function isframeface_offsetdisabledstored: boolean;
   procedure setframeface_offsetmouse(const avalue: facenrty);
   function isframeface_offsetmousestored: boolean;
   procedure setframeface_offsetclicked(const avalue: facenrty);
   function isframeface_offsetclickedstored: boolean;
   procedure setframeface_offsetactive(const avalue: facenrty);
   function isframeface_offsetactivestored: boolean;
   procedure setframeface_offsetactivemouse(const avalue: facenrty);
   function isframeface_offsetactivemousestored: boolean;
   procedure setframeface_offsetactiveclicked(const avalue: facenrty);
   function isframeface_offsetactiveclickedstored: boolean;

   procedure setoptionsskin(const avalue: frameskinoptionsty);
   function isoptionsskinstored: boolean;
   
   procedure setcolorclient(const Value: colorty);
   function iscolorclientstored: boolean;
   procedure settemplate(const avalue: tframecomp);
   procedure setlocalprops(const avalue: framelocalpropsty);
   procedure setlocalprops1(const avalue: framelocalprops1ty);
  protected
   ftemplate: tframecomp;
   flocalprops1: framelocalprops1ty;
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
   fi: baseframeinfoty;
   function isoptional: boolean; override;
   procedure settemplateinfo(const ainfo: frameinfoty); virtual;
   procedure setdisabled(const value: boolean); virtual;
   procedure updateclientrect; virtual;
   class function calcpaintframe(const afi: baseframeinfoty): framety;
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
   procedure updatemousestate(const sender: twidget;
                                       const info: mouseeventinfoty); virtual;
   function needsactiveinvalidate: boolean;
   function needsmouseinvalidate: boolean;
   function needsclickinvalidate: boolean;
   function needsmouseenterinvalidate: boolean;
   procedure activechanged; virtual;
   function needsfocuspaint: boolean; virtual;
   procedure checkminscrollsize(var asize: sizety); virtual;
   procedure checkminclientsize(var asize: sizety); virtual;
   class procedure drawframe(const canvas: tcanvas; const rect2: rectty; 
           const afi: baseframeinfoty; const astate: framestateflagsty
           {const disabled,active,clicked,mouse: boolean});
  public
   constructor create(const intf: iframe); reintroduce;
   destructor destroy; override;
   procedure checktemplate(const sender: tobject); virtual;
   procedure assign(source: tpersistent); override;
   procedure scale(const ascale: real); virtual;
   procedure checkwidgetsize(var asize: sizety); virtual;
                //extends to minimal size

   procedure paintbackground(const canvas: tcanvas;
             const arect: rectty; const clipandmove: boolean); virtual;
   procedure paintoverlay(const canvas: tcanvas; const arect: rectty); virtual;

   function outerframedim: sizety; //widgetsize - framesize
   function frameframedim: sizety; //widgetsize - (paintsize + paintframe)
   function paintframedim: sizety; //widgetsize - paintsize
   function innerframedim: sizety; //widgetsize - innersize
   function outerframe: framety;
   function paintframe: framety;     
   function innerframe: framety;     
   function cellframe: framety; //innerframe without paintframedelta
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
                     stored iscolorframestored default cl_default;
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
   property hiddenedges: edgesty read fi.hiddenedges 
                        write sethiddenedges default [];
   property framei: framety read fi.innerframe write setframei;
                      //does not set localprops
   property framei_left: integer read fi.innerframe.left write setframei_left
                     stored isfileftstored default 0;
   property framei_top: integer read fi.innerframe.top  write setframei_top
                     stored isfitopstored default 0;
   property framei_right: integer read fi.innerframe.right write setframei_right
                     stored isfirightstored default 0;
   property framei_bottom: integer read fi.innerframe.bottom
                     write setframei_bottom
                     stored isfibottomstored default 0;

   property frameimage_list: timagelist read fi.frameimage_list 
                    write setframeimage_list stored isframeimage_liststored;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_left: integer read fi.frameimage_left
                    write setframeimage_left
                    stored isframeimage_leftstored default 0;
   property frameimage_top: integer read fi.frameimage_top
                    write setframeimage_top
                    stored isframeimage_topstored default 0;
   property frameimage_right: integer read fi.frameimage_right
                    write setframeimage_right
                    stored isframeimage_rightstored default 0;
   property frameimage_bottom: integer read fi.frameimage_bottom
                    write setframeimage_bottom 
                    stored isframeimage_bottomstored default 0;
                    //added to imagelist size.
   property frameimage_offset: imagenrty read fi.frameimage_offsets.offset
                    write setframeimage_offset 
                    stored isframeimage_offsetstored default 0;
   property frameimage_offset1: imagenrty read fi.frameimage_offsets.offset1
                    write setframeimage_offset1 
                    stored isframeimage_offset1stored default 0;
                             //used for default button
   property frameimage_offsetdisabled: imagenrty 
                    read fi.frameimage_offsets.disabled 
                    write setframeimage_offsetdisabled
                    stored isframeimage_offsetdisabledstored default 0;
   property frameimage_offsetmouse: imagenrty 
                    read fi.frameimage_offsets.mouse 
                    write setframeimage_offsetmouse 
                    stored isframeimage_offsetmousestored default 0;
   property frameimage_offsetclicked: imagenrty 
                    read fi.frameimage_offsets.clicked
                    write setframeimage_offsetclicked 
                    stored isframeimage_offsetclickedstored default 0;
   property frameimage_offsetactive: imagenrty
                    read fi.frameimage_offsets.active
                    write setframeimage_offsetactive
                    stored isframeimage_offsetactivestored default 0;
   property frameimage_offsetactivemouse: imagenrty
                    read fi.frameimage_offsets.activemouse
                    write setframeimage_offsetactivemouse
                    stored isframeimage_offsetactivemousestored default 0;
   property frameimage_offsetactiveclicked: imagenrty
                    read fi.frameimage_offsets.activeclicked
                    write setframeimage_offsetactiveclicked
                    stored isframeimage_offsetactiveclickedstored default 0;

   property frameface_list: tfacelist read fi.frameface_list 
                    write setframeface_list stored isframeface_liststored;
   property frameface_offset: facenrty read fi.frameface_offsets.offset
                    write setframeface_offset 
                    stored isframeface_offsetstored default 0;
   property frameface_offset1: facenrty 
                    read fi.frameface_offsets.offset1
                    write setframeface_offset1
                    stored isframeface_offset1stored default 0;
                                   //used for default button
   property frameface_offsetdisabled: facenrty 
                    read fi.frameface_offsets.disabled 
                    write setframeface_offsetdisabled
            stored isframeface_offsetdisabledstored default 0;
   property frameface_offsetmouse: facenrty 
                    read fi.frameface_offsets.mouse 
                    write setframeface_offsetmouse 
                    stored isframeface_offsetmousestored default 0;
   property frameface_offsetclicked: facenrty 
                    read fi.frameface_offsets.clicked
                    write setframeface_offsetclicked 
                    stored isframeface_offsetclickedstored default 0;
   property frameface_offsetactive: facenrty 
                    read fi.frameface_offsets.active
                    write setframeface_offsetactive
                    stored isframeface_offsetactivestored default 0;
   property frameface_offsetactivemouse: facenrty 
                    read fi.frameface_offsets.activemouse
                    write setframeface_offsetactivemouse
                    stored isframeface_offsetactivemousestored default 0;
   property frameface_offsetactiveclicked: facenrty 
                    read fi.frameface_offsets.activeclicked
                    write setframeface_offsetactiveclicked
                    stored isframeface_offsetactiveclickedstored default 0;

   property optionsskin: frameskinoptionsty read fi.optionsskin 
                    write setoptionsskin stored isoptionsskinstored default [];
   property colorclient: colorty read fi.colorclient write setcolorclient
                    stored iscolorclientstored default cl_transparent;
   property localprops: framelocalpropsty read flocalprops 
                    write setlocalprops default []; 
   property localprops1: framelocalprops1ty read flocalprops1 
                    write setlocalprops1 default []; 
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
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;

   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;

   property optionsskin;

   property colorclient;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property localprops; //before template
   property localprops1; //before template
   property template;
 end;

 tframetemplate = class(tpersistenttemplate,iimagelistinfo)
  private
   foptionsskincontroller: frameskincontrolleroptionsty;
   procedure setcolorclient(const Value: colorty);
   procedure setcolorframe(const Value: colorty);
   procedure setcolorframeactive(const avalue: colorty);
   procedure setcolordkshadow(const avalue: colorty);
   procedure setcolorshadow(const avalue: colorty);
   procedure setcolorlight(const avalue: colorty);
   procedure setcolorhighlight(const avalue: colorty);
   procedure setcolordkwidth(const avalue: integer);
   procedure setcolorhlwidth(const avalue: integer);
   procedure sethiddenedges(const avalue: edgesty);

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
   function getimagelist: timagelist;
   procedure setframeimage_left(const avalue: integer);
   procedure setframeimage_top(const avalue: integer);
   procedure setframeimage_right(const avalue: integer);
   procedure setframeimage_bottom(const avalue: integer);
   procedure setframeimage_offset(const avalue: imagenrty);
   procedure setframeimage_offset1(const avalue: imagenrty);
   procedure setframeimage_offsetdisabled(const avalue: imagenrty);
   procedure setframeimage_offsetmouse(const avalue: imagenrty);
   procedure setframeimage_offsetclicked(const avalue: imagenrty);
   procedure setframeimage_offsetactive(const avalue: imagenrty);
   procedure setframeimage_offsetactivemouse(const avalue: imagenrty);
   procedure setframeimage_offsetactiveclicked(const avalue: imagenrty);

   procedure setframeface_list(const avalue: tfacelist);
   procedure setframeface_offset(const avalue: facenrty);
   procedure setframeface_offset1(const avalue: facenrty);
   procedure setframeface_offsetdisabled(const avalue: facenrty);
   procedure setframeface_offsetmouse(const avalue: facenrty);
   procedure setframeface_offsetclicked(const avalue: facenrty);
   procedure setframeface_offsetactive(const avalue: facenrty);
   procedure setframeface_offsetactivemouse(const avalue: facenrty);
   procedure setframeface_offsetactiveclicked(const avalue: facenrty);

   procedure setoptionsskin(const avalue: frameskinoptionsty);
   function getfont: toptionalfont;
   procedure setfont(const avalue: toptionalfont);
   function isfontstored: boolean;
   procedure setcaptiondist(const avalue: integer);
   procedure setcaptionoffset(const avalue: integer);
   procedure fontchanged(const sender: tobject);
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
   destructor destroy; override;
   procedure paintbackground(const acanvas: tcanvas; arect: rectty;
                                 const astate: framestateflagsty = []);
                                       //arect = paintrect
   procedure paintoverlay(const acanvas: tcanvas; const arect: rectty;
                        const astate: framestateflagsty);
                                       //arect = paintrect
   function paintframe: framety;
   procedure createfont;
  published
   property levelo: integer read fi.ba.levelo write setlevelo default 0;
   property leveli: integer read fi.ba.leveli write setleveli default 0;
   property framewidth: integer read fi.ba.framewidth
                     write setframewidth default 0;
   property colorframe: colorty read fi.ba.colorframe 
                     write setcolorframe default cl_default;
   property colorframeactive: colorty read fi.ba.colorframeactive 
                     write setcolorframeactive default cl_default;
   property framei_left: integer read fi.ba.innerframe.left 
                     write setframei_left default 0;
   property framei_top: integer read fi.ba.innerframe.top 
                     write setframei_top default 0;
   property framei_right: integer read fi.ba.innerframe.right 
                     write setframei_right default 0;
   property framei_bottom: integer read fi.ba.innerframe.bottom 
                     write setframei_bottom default 0;
                     
   property frameimage_list: timagelist read fi.ba.frameimage_list
                     write setframeimage_list;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_left: integer read fi.ba.frameimage_left
                    write setframeimage_left default 0;
   property frameimage_top: integer read fi.ba.frameimage_top
                    write setframeimage_top default 0;
   property frameimage_right: integer read fi.ba.frameimage_right
                    write setframeimage_right default 0;
   property frameimage_bottom: integer read fi.ba.frameimage_bottom
                    write setframeimage_bottom default 0;
                    //added to imagelist size.
   property frameimage_offset: imagenrty 
                     read fi.ba.frameimage_offsets.offset
                     write setframeimage_offset default 0;
   property frameimage_offset1: imagenrty 
                     read fi.ba.frameimage_offsets.offset1
                     write setframeimage_offset1 default 0;
   property frameimage_offsetdisabled: imagenrty 
                     read fi.ba.frameimage_offsets.disabled
                     write setframeimage_offsetdisabled default 0;
   property frameimage_offsetmouse: imagenrty 
                     read fi.ba.frameimage_offsets.mouse
                     write setframeimage_offsetmouse default 0;
   property frameimage_offsetclicked: imagenrty 
                     read fi.ba.frameimage_offsets.clicked
                     write setframeimage_offsetclicked default 0;
   property frameimage_offsetactive: imagenrty 
                     read fi.ba.frameimage_offsets.active
                     write setframeimage_offsetactive default 0;
   property frameimage_offsetactivemouse: imagenrty
                     read fi.ba.frameimage_offsets.activemouse
                     write setframeimage_offsetactivemouse default 0;
   property frameimage_offsetactiveclicked: imagenrty
                     read fi.ba.frameimage_offsets.activeclicked
                     write setframeimage_offsetactiveclicked default 0;

   property frameface_list: tfacelist read fi.ba.frameface_list
                     write setframeface_list;
   property frameface_offset: facenrty 
                     read fi.ba.frameface_offsets.offset
                     write setframeface_offset default 0;
   property frameface_offset1: facenrty 
                     read fi.ba.frameface_offsets.offset1
                     write setframeface_offset1 default 0;
   property frameface_offsetdisabled: facenrty 
                     read fi.ba.frameface_offsets.disabled
                     write setframeface_offsetdisabled default 0;
   property frameface_offsetmouse: facenrty 
                     read fi.ba.frameface_offsets.mouse
                     write setframeface_offsetmouse default 0;
   property frameface_offsetclicked: facenrty
                     read fi.ba.frameface_offsets.clicked
                     write setframeface_offsetclicked default 0;
   property frameface_offsetactive: facenrty
                     read fi.ba.frameface_offsets.active
                     write setframeface_offsetactive default 0;
   property frameface_offsetactivemouse: facenrty
                     read fi.ba.frameface_offsets.activemouse
                     write setframeface_offsetactivemouse default 0;
   property frameface_offsetactiveclicked: facenrty
                     read fi.ba.frameface_offsets.activeclicked
                     write setframeface_offsetactiveclicked default 0;
        //for tcaptionframe
   property font: toptionalfont read getfont write setfont stored isfontstored;
             //used in tmenu.itemframetemplate, itemframtemplateactive,
             //tmainmenu.popupitemframetemplate, popupitemframetemplate also
   property captiondist: integer read fi.capt.captiondist 
                 write setcaptiondist default 0;   //not used if font not set
   property captionoffset: integer read fi.capt.captionoffset 
                 write setcaptionoffset default 0; //not used if font not set
   
   property extraspace: integer read fextraspace
                        write setextraspace default 0;
   property imagedist: integer read fimagedist
                        write setimagedist default 0;
   property imagedisttop: integer read fimagedisttop
                        write setimagedisttop default 0;
   property imagedistbottom: integer read fimagedistbottom
                        write setimagedistbottom default 0;
   property colorclient: colorty read fi.ba.colorclient write setcolorclient 
                                            default cl_transparent;
   property colordkshadow: colorty read fi.ba.framecolors.shadow.effectcolor
                      write setcolordkshadow default cl_default;
   property colorshadow: colorty read fi.ba.framecolors.shadow.color
                      write setcolorshadow default cl_default;
   property colorlight: colorty read fi.ba.framecolors.light.color
                      write setcolorlight default cl_default;
   property colorhighlight: colorty read fi.ba.framecolors.light.effectcolor
                      write setcolorhighlight default cl_default;
   property colordkwidth: integer read fi.ba.framecolors.shadow.effectwidth
                      write setcolordkwidth default -1;
   property colorhlwidth: integer read fi.ba.framecolors.light.effectwidth
                      write setcolorhlwidth default -1;
   property hiddenedges: edgesty read fi.ba.hiddenedges write sethiddenedges
                           default [];
   property optionsskin: frameskinoptionsty read fi.ba.optionsskin 
                      write setoptionsskin default [];
   property optionsskincontroller: frameskincontrolleroptionsty 
                      read foptionsskincontroller
                      write foptionsskincontroller default [];
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
  procedure invalidate;
  function translatecolor(const acolor: colorty): colorty;
  function getclientrect: rectty;
  procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil);
  function getcomponentstate: tcomponentstate;
  procedure widgetregioninvalid;
 end;

 faceoptionty = (fao_alphafadeimage,fao_alphafadenochildren,fao_alphafadeall,
                 fao_fadeoverlay,fao_overlay);
 faceoptionsty = set of faceoptionty;

 tfadecolorarrayprop = class(tcolorarrayprop)
  public
   constructor create;
 end;

 tfadeopacolorarrayprop = class(tcolorarrayprop)
  public
   constructor create;
 end;
 
 faceinfoty = record
  frameimage_offset: integer;
  options: faceoptionsty;

  frameimage_list: timagelist;         //not copied by move
  fade_direction: graphicdirectionty;
  image: tmaskedbitmap;
  fade_pos: trealarrayprop;
  fade_color: tfadecolorarrayprop;
  fade_opacity: colorty;
  fade_opapos: trealarrayprop;
  fade_opacolor: tfadeopacolorarrayprop;
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
   procedure setfade_color(const Value: tfadecolorarrayprop);
   function isfacolorstored: boolean;
   procedure setfade_pos(const Value: trealarrayprop);
   function isfaposstored: boolean;
   procedure setfade_direction(const Value: graphicdirectionty);
   function isfadirectionstored: boolean;
   procedure setfade_opacity(avalue: colorty);
   function isfaopacitystored: boolean;
   procedure setfade_opacolor(const Value: tfadeopacolorarrayprop);
   function isfaopacolorstored: boolean;
   procedure setfade_opapos(const Value: trealarrayprop);
   function isfaopaposstored: boolean;
   procedure setframeimage_list(const avalue: timagelist);
   function isframeimage_liststored: boolean;
   procedure setframeimage_offset(const avalue: integer);
   function isframeimage_offsetstored: boolean;
   procedure settemplate(const avalue: tfacecomp);
   procedure setlocalprops(avalue: facelocalpropsty);
   procedure readtransparency(reader: treader);
  protected
   fintf: iface;
   fi: faceinfoty;
   procedure dochange(const sender: tarrayprop; const index: integer);
   procedure change;
   procedure imagechanged(const sender: tobject);
   procedure internalcreate; override;
   procedure doalphablend(const canvas: tcanvas);
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create; overload; override;
   constructor create(const owner: twidget); reintroduce; overload;
                                                     //sets fowner.fframe
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
   property fade_color: tfadecolorarrayprop read fi.fade_color write setfade_color
                    stored isfacolorstored;
   property fade_direction: graphicdirectionty read fi.fade_direction
                    write setfade_direction
                    stored isfadirectionstored default gd_right ;
   property fade_opacity: colorty read fi.fade_opacity
                    write setfade_opacity 
                    stored isfaopacitystored default cl_none;
   property fade_opapos: trealarrayprop read fi.fade_opapos 
                       write setfade_opapos stored isfaopaposstored;
   property fade_opacolor: tfadeopacolorarrayprop read fi.fade_opacolor
                       write setfade_opacolor stored isfaopacolorstored;

   property frameimage_list: timagelist read fi.frameimage_list 
                    write setframeimage_list stored isframeimage_liststored;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_offset: integer read fi.frameimage_offset
                    write setframeimage_offset
                    stored isframeimage_offsetstored default 0;

   property localprops: facelocalpropsty read flocalprops 
                    write setlocalprops default []; 
                                   //before template
   property template: tfacecomp read ftemplate write settemplate;
 end;

 tface = class(tcustomface)
  published
   property options;
   property image;
   property fade_pos;
   property fade_color;
   property fade_opapos;
   property fade_opacolor;
   property fade_direction;
   property fade_opacity;
   property frameimage_list;
   property frameimage_offset;
   property localprops;          //before template
   property template;
 end;

 tfacearrayprop = class(tpersistentarrayprop)
  private
   fintf: iface;
   function getitems(const index: integer): tface;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aintf: iface); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tface read getitems; default;
 end;
 
 tfacelist = class(tmsecomponent,iface)
  private
   flist: tfacearrayprop;
   procedure setlist(const avalue: tfacearrayprop);
   procedure invalidate;
   function translatecolor(const acolor: colorty): colorty;
   function getclientrect: rectty;
   function getcomponentstate: tcomponentstate;
   procedure widgetregioninvalid;
  protected
   procedure objectevent(const sender: tobject;
                             const event: objecteventty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property list: tfacearrayprop read flist write setlist;
 end;
 
 tfacetemplate = class(tpersistenttemplate)
  private
   fi: faceinfoty;
   procedure setoptions(const avalue: faceoptionsty);
   procedure setfade_color(const Value: tfadecolorarrayprop);
   procedure setfade_pos(const Value: trealarrayprop);
   procedure setfade_opacolor(const Value: tfadeopacolorarrayprop);
   procedure setfade_opapos(const Value: trealarrayprop);
   procedure setfade_opacity(avalue: colorty);
   procedure setfade_direction(const Value: graphicdirectionty);
   procedure setimage(const Value: tmaskedbitmap);
   procedure doimagechange(const sender: tobject);
   procedure dochange(const sender: tarrayprop; const index: integer);
   procedure setframeimage_list(const avalue: timagelist);
   procedure setframeimage_offset(const avalue: integer);
   procedure readtransparency(reader: treader);
  protected
   procedure doassignto(dest: tpersistent); override;
   function getinfosize: integer; override;
   function getinfoad: pointer; override;
   procedure copyinfo(const source: tpersistenttemplate); override;
   procedure internalcreate; override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const owner: tmsecomponent; const onchange: notifyeventty); override;
   destructor destroy; override;
  published
   property options: faceoptionsty read fi.options write setoptions default [];
   property image: tmaskedbitmap read fi.image write setimage;
   property fade_pos: trealarrayprop read fi.fade_pos write setfade_pos;
   property fade_color: tfadecolorarrayprop read fi.fade_color 
                                                   write setfade_color;
   property fade_opapos: trealarrayprop read fi.fade_opapos 
                    write setfade_opapos;
   property fade_opacolor: tfadeopacolorarrayprop read fi.fade_opacolor 
                                                   write setfade_opacolor;
   property fade_direction: graphicdirectionty read fi.fade_direction
                write setfade_direction default gd_right;
   property fade_opacity: colorty read fi.fade_opacity
              write setfade_opacity default cl_none;

   property frameimage_list: timagelist read fi.frameimage_list 
                     write setframeimage_list;
     //imagenr 0 = topleft, 1 = left, 2 = bottomleft, 3 = bottom, 4 = bottomright
     //5 = right, 6 = topright, 7 = top
   property frameimage_offset: integer read fi.frameimage_offset
                     write setframeimage_offset default 0;
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

 mouseeventty = procedure (const sender: twidget; 
                                   var ainfo: mouseeventinfoty) of object;
 mousewheeleventty = procedure (const sender: twidget; 
                                   var ainfo: mousewheeleventinfoty) of object;
 keyeventty = procedure (const sender: twidget; 
                                   var ainfo: keyeventinfoty) of object;
 shortcuteventty = procedure (const sender: twidget; var ainfo: keyeventinfoty;
                                              const origin: twidget) of object;
 painteventty = procedure (const sender: twidget; 
                                   const acanvas: tcanvas) of object;
 pointeventty = procedure(const sender: twidget;
                                   const apoint: pointty) of object;
 widgeteventty = procedure(const sender: tobject;
                                   const awidget: twidget) of object;

 widgetarty = array of twidget;

 twindow = class;
 pwindow = ^twindow;

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
  hastarget: boolean;
 end;

 twidgetfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 widgetfontclassty = class of twidgetfont;

 twidgetfontempty = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 widgetfontemptyclassty = class of twidgetfontempty;

 twidgetevent = class(tcomponentevent)
 end;

 modallevelty = (ml_none,ml_application, //call eventloop
                 ml_window);             //reflect window focus
 
 widgetalignmodety = (wam_none,wam_start,wam_center,wam_end);
 widgetclassty = class of twidget;
 navigrequesteventty = procedure(const sender: twidget;
                                var ainfo: naviginfoty) of object; 
 twidget = class(tactcomponent,iscrollframe,iface)
  private
   fwidgetregion: gdiregionty;
   frootpos: pointty;   //position in rootwindow
   fcursor: cursorshapety;
   ftaborder: integer;
   fminsize,fmaxsize: sizety;
   fminclientsize: sizety;
   fminscrollsize: sizety;
   ffocusedchild,ffocusedchildbefore: twidget;
   ffontheight: integer;
   fsetwidgetrectcount: integer; //for recursive setpos
   fautosizelevel: byte;

   foptionsskin: optionsskinty;
   fskingroup: integer;
   fonnavigrequest: navigrequesteventty;
   geframewidth: integer;
   procedure invalidateparentminclientsize;
   function minclientsize: sizety;
   function getwidgets(const index: integer): twidget;
   function dofindwidget(const awidgets: widgetarty; 
                                           aname: ansistring): twidget;

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

   procedure setcursor(const avalue: cursorshapety);
   function getsize: sizety;

   function invalidateneeded: boolean;
   procedure addopaquechildren(var region: gdiregionty);
   procedure updatewidgetregion;
   function isclientmouseevent(var info: mouseeventinfoty): boolean;
   procedure internaldofocus;
   procedure internaldodefocus;
   procedure internaldoenter;
   procedure internaldoexit;
   procedure internaldoactivate;
   procedure internaldodeactivate;
   procedure internalkeydown(var info: keyeventinfoty);

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
   function getpaintsize: sizety;
   procedure setpaintsize(const avalue: sizety);
   function getframesize: sizety;
   procedure setframesize(const avalue: sizety);
   procedure setframewidth(const avalue: integer);
   function getframeheight: integer;
   procedure setframeheight(const avalue: integer);
   function getpaintwidth: integer;
   procedure setpaintwidth(const avalue: integer);
   function getpaintheight: integer;
   procedure setpaintheight(const avalue: integer);
  protected
   fwidgets: widgetarty;
   fnoinvalidate: integer;
   fwidgetupdating: integer;
   foptionswidget: optionswidgetty;
   foptionswidget1: optionswidget1ty;
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
   ffontempty: twidgetfontempty;
   fhint: msestring;
   fdefaultfocuschild: twidget;

   function isdesignwidget(): boolean; virtual;
   procedure designmouseevent(var info: moeventinfoty;
                                             capture: twidget); virtual;
   procedure designkeyevent(const eventkind: eventkindty;
                                            var info: keyeventinfoty); virtual;

   procedure defineproperties(filer: tfiler); override;
   function gethelpcontext: msestring; override;
   class function classskininfo: skininfoty; override;
   function skininfo: skininfoty; override;
   function hasskin: boolean; override;

   function navigstartrect: rectty; virtual; //origin = pos
   function navigrect: rectty; virtual;      //origin = pos
   procedure navigrequest(var info: naviginfoty); virtual;
   function navigdistance(var info: naviginfoty): integer; virtual;

   function getwidgetrects(const awidgets: array of twidget): rectarty;
   procedure setwidgetrects(const awidgets: array of twidget;
                                                 const arects: rectarty);

   procedure updateroot;
   procedure setcolor(const avalue: colorty); virtual;
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
   procedure setvisible(const avalue: boolean); virtual;
   function isvisible: boolean;      //checks designing
   function parentisvisible: boolean;//checks isvisible flags of ancestors
   function parentvisible: boolean;  //checks visible flags of ancestors
   function updateopaque(const children: boolean; 
                               const widgetregioncall: boolean): boolean;
                   //true if widgetregionchanged called
   procedure dragstarted; virtual; //called by tapplication.dragstarted
    //iscrollframe
   function getzoomrefframe: framety; virtual;
    //idragcontroller
   function getdragrect(const apos: pointty): rectty; virtual;
    //iface
   procedure widgetregioninvalid;
    //iframe
   procedure setframeinstance(instance: tcustomframe); virtual;
   procedure setstaticframe(value: boolean);
   function getstaticframe: boolean;
   function getwidgetrect: rectty;
   function getcomponentstate: tcomponentstate;

   function getframestateflags: framestateflagsty; virtual;
    //igridcomp,itabwidget
   function getwidget: twidget;

   function getframe: tcustomframe;
   procedure setframe(const avalue: tcustomframe);
   function getface: tcustomface;
   procedure setface(const avalue: tcustomface);

   function getgdi: pgdifunctionaty; virtual;
   procedure createwindow; virtual;
   procedure objectchanged(const sender: tobject); virtual;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure setchildorder(child: tcomponent; order: integer); overload; override;
   procedure setparentcomponent(value: tcomponent); override;
   function clearparentwidget: twidget;
             //returns old parentwidget
   procedure setparentwidget(const Value: twidget); virtual;
   procedure setlockedparentwidget(const avalue: twidget);
            //sets ws_loadlock before setting, restores afterwards
   procedure updatewindowinfo(var info: windowinfoty); virtual;
   procedure windowcreated; virtual;
   procedure setoptionswidget(const avalue: optionswidgetty); virtual;
   procedure setoptionswidget1(const avalue: optionswidget1ty); virtual;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;

   procedure initparentclientsize;
   function getcaretcliprect: rectty; virtual;  //origin = clientrect.pos
   procedure dobeginread; override;
   procedure doendread; override;
   procedure loaded; override;

   procedure updatemousestate(const info: mouseeventinfoty); virtual;
                                   //updates fstate about mouseposition
   procedure setclientclick; //grabs mouse and sets clickflags

   procedure registerchildwidget(const child: twidget); virtual;
   procedure unregisterchildwidget(const child: twidget); virtual;
   function isfontstored: Boolean;
   procedure setfont(const avalue: twidgetfont);
   function getfont: twidgetfont;
   function getfont1: twidgetfont; //no getoptionalobject
   function isfontemptystored: Boolean;
   procedure setfontempty(const avalue: twidgetfontempty);
   function getfontempty: twidgetfontempty;
   function getfontempty1: twidgetfontempty; //no getoptionalobject
   function getframefont: tfont;
   procedure fontchanged; virtual;
   procedure fontcanvaschanged; virtual;
   procedure updatecursorshape(apos: pointty){(force: boolean = false)};

   procedure parentclientrectchanged; virtual;
   procedure parentwidgetregionchanged(const sender: twidget); virtual;
   procedure widgetregionchanged(const sender: twidget); virtual;
   procedure scalebasechanged(const sender: twidget); virtual; //used by tlayouter
 
 {$ifdef mse_with_ifi}
   procedure ifiwidgetstatechanged;
   function getifiwidgetstate: ifiwidgetstatesty; virtual;
 {$endif}                     
   procedure cursorchanged;
   procedure statechanged; virtual; //enabled,active,visible
   procedure enabledchanged; virtual;
   procedure activechanged; virtual;
   procedure visiblepropchanged; virtual;
   procedure visiblechanged; virtual;
   procedure colorchanged; virtual;
   procedure sizechanged; virtual;
   procedure getautopaintsize(var asize: sizety); virtual;
   procedure getautocellsize(const acanvas: tcanvas;
                                      var asize: sizety); virtual;
   procedure childclientrectchanged(const sender: twidget); virtual;
   procedure childautosizechanged(const sender: twidget); virtual;
   procedure poschanged; virtual;
   procedure clientrectchanged; virtual;
   procedure parentchanged; virtual;
   procedure rootchanged(const awidgetregioninvalid: boolean); virtual;
   function getdefaultfocuschild: twidget; virtual;
                                   //returns first focusable widget
   procedure setdefaultfocuschild(const value: twidget); virtual;
   function trycancelmodal(const newactive: twindow): boolean; virtual;
              //called by twindow.internalactivate, true if accepted
   procedure sortzorder;
   procedure clampinview(const arect: rectty; const bottomright: boolean); virtual;
                    //origin paintpos

   function needsdesignframe: boolean; virtual;
   function getactface: tcustomface; virtual;
   procedure dobeforepaint(const canvas: tcanvas); virtual;
   procedure dopaint(const canvas: tcanvas); virtual;
   procedure dopaintbackground(const canvas: tcanvas); virtual;
   procedure doonpaintbackground(const canvas: tcanvas); virtual;
   procedure dobeforepaintforeground(const canvas: tcanvas); virtual;
   procedure dopaintforeground(const canvas: tcanvas); virtual;
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

   function wantmousefocus(const info: mouseeventinfoty): boolean;
   procedure reflectmouseevent(var info: mouseeventinfoty);
                                  //posts mousevent to window under mouse
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); virtual;
   procedure childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty); virtual;
   procedure mousewheelevent(var info: mousewheeleventinfoty); virtual;

   procedure dokeydown1(var info: keyeventinfoty); //updates flags, calls dokeydown
   procedure dokeydown(var info: keyeventinfoty); virtual;
                                       //do not call dokeydown, call dokeydown1
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); virtual;
                    //called twice, first before dokeydown with es_preview set
   function checkfocusshortcut(var info: keyeventinfoty): boolean; virtual;
   procedure dokeydownaftershortcut(var info: keyeventinfoty); virtual;
   procedure dokeyup(var info: keyeventinfoty); virtual;

   procedure dofontchanged(const sender: tobject);
   procedure setfontheight;
   procedure postchildscaled;
   function verticalfontheightdelta: boolean; virtual;
   procedure dofontheightdelta(var delta: integer); virtual;
   procedure syncsinglelinefontheight(const lineheight: boolean = false;
                                                          const space: integer = 2);

   procedure setwidgetrect(const Value: rectty);
   procedure internalsetwidgetrect(Value: rectty;
                                const windowevent: boolean); virtual;
   function getclientpos: pointty;              
   function getclientsize: sizety;
   procedure setclientsize(const asize: sizety); virtual; //used in tscrollingwidget
   function getclientwidth: integer;
   procedure setclientwidth(const avalue: integer);
   function getclientheight: integer;
   procedure setclientheight(const avalue: integer);
   function internalshow(const modallevel: modallevelty;
           const transientfor: pwindow; //follow linkedvar state
           const windowevent,nomodalforreset: boolean): modalresultty; virtual;
   procedure internalhide(const windowevent: boolean);
   function checksubfocus(const aactivate: boolean): boolean; virtual;
   function getnextfocus: twidget;
   function cantabfocus: boolean;
   function getdisprect: rectty; virtual; 
                //origin pos, clamped in view by activate

   function getshrinkpriority: integer; virtual; //default 0
   procedure tryshrink(const aclientsize: sizety); virtual;
   function calcminscrollsize: sizety; virtual;
   function minscrollsize: sizety; //uses cache
   function getminshrinkpos: pointty; virtual;
   function getminshrinksize: sizety; virtual;
   function getcontainer: twidget; virtual;
   function getchildwidgets(const index: integer): twidget; virtual;

   function getright: integer;       //if placed in datamodule
   procedure setright(const avalue: integer);
   function getbottom: integer;
   procedure setbottom(const avalue: integer);
   function ownswindow1: boolean;    //does not check winid

   procedure internalcreateframe; virtual;
   procedure internalcreateface; virtual;
   function getfontclass: widgetfontclassty; virtual;
   function getfontemptyclass: widgetfontemptyclassty; virtual;
   procedure internalcreatefont; virtual;
   procedure internalcreatefontempty; virtual;

   function getclientrect: rectty;
   function windowpo: pwindowty;
   function canclose1: boolean; 
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(const aowner: tcomponent;
                      const aparentwidget: twidget;
                      const aiswidget: boolean = true); overload;
   constructor createandinit(const aowner: tcomponent; 
                      const aparentwidget: twidget); overload;
   destructor destroy; override;
   procedure afterconstruction; override;   
   procedure initnewcomponent(const ascale: real); override;
                     //called before inserting in parentwidget
   procedure initnewwidget(const ascale: real); virtual;
                     //called after inserting in parentwidget
   procedure createframe;
   procedure createface;
   procedure createfont;
   procedure createfontempty;
   procedure checkautosize;

   function isloading: boolean;      //checks ws_loadlock and csdestroing too
   procedure beginupdate; //sets ws_loadlock and noinvalidate
   procedure endupdate;
   function canmouseinteract: boolean; //checks csdesigning and cssubcomponent
   function widgetstate: widgetstatesty;                 //iframe
   property widgetstate1: widgetstates1ty read fwidgetstate1;
   function hasparent: boolean; override;               //tcomponent
   function getparentcomponent: tcomponent; override;   //tcomponent
   function hascaret: boolean;
   function canwindow: boolean; 
            //true if twindow allocated or not rootwidget destroying
   function windowallocated: boolean;
                //true if winid allocated and not loading and not destroying
   function ownswindow: boolean;
                      //true if valid toplevelwindow with assigned winid
   function updaterect: rectty; //invalidated area, origin = clientpos

   procedure beforeclosequery(var amodalresult: modalresultty); virtual;
                   //called on top level window
   function canclose(const newfocus: twidget = nil): boolean; virtual;
   function canparentclose(const newfocus: twidget): boolean; overload;
                   //window.focusedwidget is first checked if it is descendant
   function forceclose: boolean; //newfocus=nil, sets ws1_forceclose, true if ok
   function canparentclose: boolean; overload;
                   //newfocus = window.focusedwidget      
   function canfocus: boolean; virtual;
   function setfocus(aactivate: boolean = true): boolean; virtual;//true if ok
   procedure parentfocus; //sets focus to self or focusable parent
   procedure nextfocus; //sets inputfocus to then next appropriate widget
   function findtabfocus(const ataborder: integer): twidget;
                       //nil if can not focus
   function firsttabfocus: twidget;
   function lasttabfocus: twidget;
   function nexttaborder(const down: boolean = false): twidget;
   function focusback(const aactivate: boolean = true): boolean; virtual;
                               //false if focus not changed

   function parentcolor: colorty;
   function actualcolor: colorty; virtual;
   function actualopaquecolor: colorty;
   function backgroundcolor: colorty;
   function translatecolor(const acolor: colorty): colorty;

   procedure widgetevent(const event: twidgetevent); virtual;
   procedure sendwidgetevent(const event: twidgetevent);
                              //event will be destroyed

   procedure release(const nomodaldefer: boolean=false); override;
   function show(const modallevel: modallevelty;
            const transientfor: twindow = nil): modalresultty;
                                                    overload; virtual;
   function show(const modallevel: modallevelty;
            const transientfor: twidget): modalresultty; overload;
   function show(const modal: boolean = false;
            const transientfor: twindow = nil): modalresultty; overload;
   procedure endmodal;
   procedure hide;
   procedure activate(const abringtofront: boolean = true;
                      const aforce: boolean = false); virtual;
                             //show and setfocus
   procedure bringtofront;
   procedure sendtoback;
   procedure stackunder(const predecessor: twidget);
   procedure setchildorder(const achildren: widgetarty); overload;
                //last is top, nil items ignored

   procedure paint(const canvas: tcanvas); virtual;
   procedure update; virtual;
   procedure scrollwidgets(const dist: pointty);
   procedure scrollrect(const dist: pointty; const rect: rectty;
                                scrollcaret: boolean); //origin = paintrect.pos
   procedure scroll(const dist: pointty);
                            //scrolls paintrect and widgets
   procedure getcaret;
   procedure scrollcaret(const dist: pointty);
   function mousecaptured: boolean;
   function capturemouse(grab: boolean = true): boolean;
                    //true for new grab
   procedure releasemouse(const grab: boolean = false);
   function capturekeyboard: boolean; //true for new grab
   procedure releasekeyboard;
   procedure synctofontheight; virtual;

   procedure dragevent(var info: draginfoty); virtual;
   procedure dolayout(const sender: twidget); virtual;

   procedure invalidatewidget;     //invalidates whole widget
   procedure invalidate;           //invalidates clientrect
   procedure invalidaterect(const rect: rectty; 
               const org: originty = org_client; const noclip: boolean = false);
   procedure invalidateframestate;
   procedure invalidateframestaterect(const rect: rectty;
               const aframe: tcustomframe; const org: originty = org_client);   
   function hasoverlappingsiblings(arect: rectty): boolean; //origin = pos

   function window: twindow;
   function rootwidget: twidget;
   function parentofcontainer: twidget;
            //parentwidget.parentwidget if parentwidget has not ws_iswidget,
            //parentwidget otherwise
   property parentwidget: twidget read fparentwidget write setparentwidget;
   function getrootwidgetpath: widgetarty; //root widget is last
   function widgetcount: integer;
   function parentwidgetindex: integer; 
                            //index in parentwidget.widgets, -1 if none
   property widgets[const index: integer]: twidget read getwidgets;
   function widgetatpos(var info: widgetatposinfoty): twidget; overload;
   function widgetatpos(const pos: pointty): twidget; overload;
   function widgetatpos(const pos: pointty; 
                   const state: widgetstatesty): twidget; overload;
   function findtagwidget(const atag: integer;
                                const aclass: widgetclassty): twidget;
              //returns first matching descendent
   function findwidget(const aname: ansistring): twidget;
              //searches in container.widgets, case insensitive

   property container: twidget read getcontainer;
   function containeroffset: pointty;
   function childrencount: integer; virtual;
   property children[const index: integer]: twidget read getchildwidgets;
                                                                      default;
   function childatpos(const pos: pointty; 
                   const clientorigin: boolean = true): twidget; virtual;
   function gettaborderedwidgets: widgetarty;
   function getvisiblewidgets: widgetarty;
   function getsortxchildren(const banded: boolean = false): widgetarty;
              //banded -> row,column order
   function getsortychildren(const banded: boolean = false): widgetarty;
              //banded -> column,row order
   function getlogicalchildren: widgetarty; virtual; //children of container
   procedure addlogicalchildren(var achildren: widgetarty);
   function findlogicalchild(const aname: ansistring): twidget;
                  //case insensitive
   
   property focusedchild: twidget read ffocusedchild;
   property focusedchildbefore: twidget read ffocusedchildbefore;

   function mouseeventwidget(const info: mouseeventinfoty): twidget;
   function checkdescendent(awidget: twidget): boolean;
                    //true if widget is descendent or self
   function checkancestor(awidget: twidget): boolean;
                    //true if widget is ancestor or self
   function containswidget(awidget: twidget): boolean;

   procedure insertwidget(const awidget: twidget); overload;
   procedure insertwidget(const awidget: twidget; const apos: pointty); overload; virtual;
                    //widget can be child

   function iswidgetclick(const info: mouseeventinfoty; const caption: boolean = false): boolean;
   //true if eventtype = et_butonrelease, button is mb_left,
   // clicked and pos in clientrect or in frame.caption if caption = true,
   // origin = pos
   function isclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonrelease, button is mb_left,
   // clicked and pos in clientrect
   function isdblclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonpress, button is mb_left, pos in clientrect
   // and timedlay to last buttonpress is short
   function isdblclicked(const info: mouseeventinfoty): boolean;
   //true if eventtype in [et_buttonpress,et_butonrelease], button is mb_left,
   // and timedlay to last same buttonevent is short
   function isleftbuttondown(const info: mouseeventinfoty): boolean; overload;
   //true if eventtype = et_butonpress, button is mb_left, pos in clientrect
   //origin = paintrect.pos
   function isleftbuttondown(const info: mouseeventinfoty;
                      const akeyshiftstate: shiftstatesty): boolean; overload;
{
   function eatwidgetclick(var info: mouseeventinfoty;
                                     const caption: boolean = false): boolean;
   function eatclick(var info: mouseeventinfoty): boolean;
   function eatdblclick(var info: mouseeventinfoty): boolean;
   function eatdblclicked(var info: mouseeventinfoty): boolean;
   function eatleftbuttondown(var info: mouseeventinfoty): boolean; overload;
   function eatleftbuttondown(var info: mouseeventinfoty;
                      const akeyshiftstate: shiftstatesty): boolean; overload;
}
   function widgetmousepos(const ainfo: mouseeventinfoty): pointty; 
                                    //translates to widgetpos if necessary

   function rootpos: pointty;
   property screenpos: pointty read getscreenpos write setscreenpos;
   function clientpostowidgetpos(const apos: pointty): pointty;
   function widgetpostoclientpos(const apos: pointty): pointty;
   function widgetpostopaintpos(const apos: pointty): pointty;
   function paintpostowidgetpos(const apos: pointty): pointty;
   procedure scale(const ascale: real); virtual;

   property widgetrect: rectty read fwidgetrect write setwidgetrect;
   property pos: pointty read fwidgetrect.pos write setpos;
   property size: sizety read fwidgetrect.size write setsize;
   property minsize: sizety read fminsize write setminsize;
   function widgetminsize: sizety; 
           //calls checkwidgetsize and frame.checkwidgetsize
   property maxsize: sizety read fmaxsize write setmaxsize;
   function maxclientsize: sizety; virtual;
   property bounds_x: integer read fwidgetrect.x write setbounds_x;
   property bounds_y: integer read fwidgetrect.y write setbounds_y;
   property bounds_cx: integer read fwidgetrect.cx write setbounds_cx
                  {default defaultwidgetwidth} stored true;
   property bounds_cy: integer read fwidgetrect.cy write setbounds_cy
                  {default defaultwidgetheight} stored true;
   property bounds_cxmin: integer read fminsize.cx 
                                      write setbounds_cxmin default 0;
   property bounds_cymin: integer read fminsize.cy 
                                      write setbounds_cymin default 0;
   property bounds_cxmax: integer read fmaxsize.cx 
                                      write setbounds_cxmax default 0;
   property bounds_cymax: integer read fmaxsize.cy 
                                      write setbounds_cymax default 0;

   property left: integer read fwidgetrect.x write setbounds_x;
   property right: integer read getright write setright;
                //widgetrect.x + widgetrect.cx, sets cx if an_left is set
   property top: integer read fwidgetrect.y write setbounds_y;
   property bottom: integer read getbottom write setbottom;
                //widgetrect.y + widgetrect.cy, sets cy if an_top is set
   property width: integer read fwidgetrect.cx write setbounds_cx;
   property height: integer read fwidgetrect.cy write setbounds_cy;

   procedure setclippedwidgetrect(arect: rectty);
                //clips into parentwidget or workarea if no parentwidget
   
   property anchors: anchorsty read fanchors write setanchors 
                                                      default defaultanchors;
   property defaultfocuschild: twidget read getdefaultfocuschild 
                                                write setdefaultfocuschild;

   function framedim: sizety;                //widgetrect.size - paintrect.size
   function clientframewidth: sizety;        //widgetrect.size - clientrect.size
   function innerclientframewidth: sizety;   
                          //widgetrect.size - innerclientrect.size
   function innerframewidth: sizety;         
                          //clientrect.size - innerclientrect.size  
   function framerect: rectty;               //origin = pos
   function framepos: pointty;               //origin = pos
   property framesize: sizety read getframesize write setframesize;    
                                            //widget size - outer frame
   property framewidth: integer read geframewidth write setframewidth;
   property frameheight: integer read getframeheight write setframeheight;
   function frameinnerrect: rectty;          //origin = pos

   function widgetclientrect: rectty;        //origin = clientrect.pos

   function paintrect: rectty;               //origin = pos
   function paintclientrect: rectty;         //origin = clientrect
   function paintpos: pointty;               //origin = pos
   property paintsize: sizety read getpaintsize write setpaintsize;
   property paintwidth: integer read getpaintwidth write setpaintwidth;
   property paintheight: integer read getpaintheight write setpaintheight;
   function clippedpaintrect: rectty;        //origin = pos, 
                                             //clipped by all parentpaintrects
   function innerpaintrect: rectty;          //origin = pos

   procedure setanchordwidgetsize(const asize: sizety);
                //checks bottom-right anchors
   function widgetsizerect: rectty;          //pos = nullpoint
   function paintsizerect: rectty;           //pos = nullpoint
   function clientsizerect: rectty;          //pos = nullpoint
   function containerclientsizerect: rectty; //pos = nullpoint

   property clientrect: rectty read getclientrect; //origin = paintrect.pos
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
   function parentpaintpos: pointty;         //origin = parentwidget.paintpos
                                             //nullpoint if parent = nil
   function refpos(const aorigin: originty): pointty;
   
   function paintrectparent: rectty;         //origin = paintpos,
                                             //nullrect if parent = nil,
   function clientrectparent: rectty;        //origin = paintpos,
                                             //nullrect if parent = nil,
   function innerwidgetrect: rectty;         //origin = pos
   function innerclientrect: rectty;         //origin = clientpos
   function innerclientsize: sizety;
   function innerclientpos: pointty;         //origin = clientpos
   function innerclientframe: framety;
   function innerclientpaintpos: pointty;    //origin = paintpos
   function innerclientwidgetpos: pointty;   //origin = pos
   procedure innertopaintsize(var asize: sizety);
   procedure painttowidgetsize(var asize: sizety);

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
               //with [an_left,an_right], minint -> no change
   procedure placeyorder(const starty: integer; const dist: array of integer;
                const awidgets: array of twidget;
                const endmargin: integer = minint);
               //origin = clientpos, endmargin by size adjust of widgets 
               //with [an_top,an_bottom], minint -> no change
   function alignx(const mode: widgetalignmodety;
                        const awidgets: array of twidget;
                        const glue: widgetalignmodety = wam_none;
                        const margin: integer = 0): integer;
                        //returns reference point
   function aligny(const mode: widgetalignmodety;
                        const awidgets: array of twidget;
                        const glue: widgetalignmodety = wam_none;
                        const margin: integer = 0): integer;
                        //returns reference point
{
   function alignx(const mode: widgetalignmodety;
                     const awidgets: array of twidget;
                               const margin: integer): integer;
                        //shifts to client border, returns reference point

   function aligny(const mode: widgetalignmodety;
                        const awidgets: array of twidget): integer;
                        //returns reference point
   function aligny(const mode: widgetalignmodety;
                        const awidgets: array of twidget;
                               const margin: integer): integer;
                        //shifts to client border, returns reference point
}
   property optionswidget: optionswidgetty read foptionswidget 
                 write setoptionswidget default defaultoptionswidget;
   property optionswidget1: optionswidget1ty read foptionswidget1 
                 write setoptionswidget1 default defaultoptionswidget1;
   property optionsskin: optionsskinty read foptionsskin 
                                            write setoptionsskin default [];
   function actualcursor(const apos: pointty): cursorshapety; virtual;
                             //origin = pos
   property cursor: cursorshapety read fcursor write setcursor default cr_default;
   property color: colorty read fcolor write setcolor default defaultwidgetcolor;
   property visible: boolean read getvisible write setvisible default true;
   property enabled: boolean read getenabled write setenabled default true;
   property taborder: integer read ftaborder write settaborder default 0;
   property hint: msestring read gethint write sethint stored ishintstored;
   property zorder: integer read getzorder write setzorder;
  published
   property onnavigrequest: navigrequesteventty read fonnavigrequest
                                                   write fonnavigrequest;
   property skingroup: integer read fskingroup write fskingroup default 0;
   property onbeforeupdateskin;
   property onafterupdateskin;
 end;
 pwidget = ^twidget;

 windowstatety = (tws_posvalid,tws_sizevalid,tws_windowvisible,
                  tws_windowshowpending,
                  {tws_modal,}tws_modalfor,tws_modalcalling,
                  tws_needsdefaultpos,
                  tws_closing,tws_painting,tws_activating,
                  tws_globalshortcuts,tws_localshortcuts,
                  tws_buttonendmodal,
                  tws_grouphidden,tws_groupminimized,tws_groupmaximized,
                  tws_transientforminimized,
                  tws_grab,tws_activatelocked,
                  tws_canvasoverride,tws_destroying,
                  tws_raise,tws_lower);
 windowstatesty = set of windowstatety;

 pmodalinfoty = ^modalinfoty;
 modalinfoty = record
  modalend: boolean;
  modalwindowbefore: twindow;
  level: integer;
  parent: pmodalinfoty;
  events: eventarty; //deferred events
 end;
 showinfoty = record
  widget: twidget;
  transientfor: twindow;
  windowevent,nomodalforreset: boolean
 end;
 pshowinfoty = ^showinfoty;
 
 twindowevent = class(tmseevent)
  private
  public
   fwinid: winidty;
   constructor create(akind: eventkindty; winid: winidty);
 end;
 pwindowevent = ^twindowevent;

 twindow = class(teventobject,icanvas)
  private
   ffocuscount: longword; //for recursive setwidgetfocus
   factivecount: longword; //for recursive activate,deactivate
   factivating: integer;
   ffocusing: integer;
   fsizeerrorcount: integer;
   fmoving: integer;
   ffocusedwidget: twidget;
   fenteredwidget: twidget;
   fcaller: twidget; //used in twidget.doshortcut
   fmodalinfopo: pmodalinfoty;
   foptions: windowoptionsty;
   ftransientfor: twindow;
   ftransientforcount: integer;
   fwindowpos: windowposty;
   fwindowposbefore: windowposty;
   fnormalwindowrect: rectty;
   fcaption: msestring;
   fscrollnotifylist: tnotifylist;
   fsyscontainer: syswindowty;
   fmodalwidget: twidget;
   fmodallevel: integer;
   fsysdragobject: tobject; //tsysmimedragobject;
   
   procedure setcaption(const avalue: msestring);
   procedure widgetdestroyed(widget: twidget);

   procedure showed;
   procedure hidden;
   procedure activated;
   procedure deactivated;
   procedure wmconfigured(const arect: rectty; const aorigin: pointty);
   procedure windowdestroyed;

   function internalupdate: boolean;
           //updates screen representation, false if nothing is painted
   procedure deactivate;
   function canactivate: boolean;
     //icanvas
   procedure gcneeded(const sender: tcanvas);
//   function getmonochrome: boolean;
   function getkind: bitmapkindty;
   function getsize: sizety;
   procedure getcanvasimage(const bgr: boolean; var aimage: maskedimagety);

   procedure checkrecursivetransientfor(const value: twindow);
   procedure settransientfor(const Value: twindow; const windowevent: boolean);
   procedure sizeconstraintschanged;
   procedure setsizeconstraints(const amin,amax: sizety);
   procedure createwindow;
   procedure checkwindowid;
   procedure checkwindow(windowevent: boolean);
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); virtual;
                                      //nil if from application
   procedure show(windowevent: boolean);
   procedure hide(windowevent: boolean);
   procedure setfocusedwidget(const widget: twidget);
   procedure setmodalresult(const Value: modalresultty);
   function getglobalshortcuts: boolean;
   function getlocalshortcuts: boolean;
   procedure setglobalshortcuts(const Value: boolean);
   procedure setlocalshortcuts(const Value: boolean);
   function getbuttonendmodal: boolean;
   procedure setbuttonendmodal(const value: boolean);

   function getdecoratedwidgetrect: rectty;
   procedure setdecoratedwidgetrect(const avalue: rectty);
   function getdecoratedpos: pointty;
   procedure setdecoratedpos(const avalue: pointty);
   function getdecoratedsize: sizety;
   procedure setdecoratedsize(const avalue: sizety);
   function getdecoratedbounds_x: integer;
   procedure setdecoratedbounds_x(const avalue: integer);
   function getdecoratedbounds_y: integer;
   procedure setdecoratedbounds_y(const avalue: integer);
   function getdecoratedbounds_cx: integer;
   procedure setdecoratedbounds_cx(const avalue: integer);
   function getdecoratedbounds_cy: integer;
   procedure setdecoratedbounds_cy(const avalue: integer);
   procedure setcontainer(const avalue: winidty);
   procedure containerwindestroyed(const aid: winidty);
   procedure setsyscontainer(const avalue: syswindowty);
   function getscreenpos: pointty;
   procedure setscreenpos(const avalue: pointty);
   function getmodalfor: boolean;
  protected
   fstate: windowstatesty;
   fgdi: pgdifunctionaty;
   fwindow: windowty;
   fcontainer: winidty;
   fownerwidget: twidget;
   fcanvas: tcanvas;
   fasynccanvas: tcanvas;
   fmodalresult: modalresultty;
   fupdateregion: gdiregionty;
   procedure setasynccanvas(const acanvas: tcanvas);
           //used from treport
   procedure releaseasynccanvas;
   procedure processsysdnd(const event: twindowevent); //tsysdndevent
   
   function getwindowsize: windowsizety;
   procedure setwindowsize(const value: windowsizety);
   function getwindowpos: windowposty;
   procedure setwindowpos(const Value: windowposty);
   procedure invalidaterect(const arect: rectty; const sender: twidget = nil);
                       //clipped by paintrect of sender.parentwidget
   procedure mouseparked;
   procedure movewindowrect(const dist: pointty; const rect: rectty); virtual;
   procedure checkmousewidget(const info: mouseeventinfoty;
                                                    var capture: twidget);
   procedure dispatchmouseevent(var info: moeventinfoty;
                                               capture: twidget); virtual;
   procedure dispatchkeyevent(const eventkind: eventkindty;
                                            var info: keyeventinfoty); virtual;
   procedure sizechanged; virtual;
   procedure poschanged; virtual;
   procedure internalactivate(const windowevent: boolean;
                                 const force: boolean = false);
   procedure noactivewidget;
   procedure lockactivate;
   procedure unlockactivate;
   procedure setzorder(const value: integer);
   function topmodaltransientfor: twindow;
   function beginmodal(const showinfo: pshowinfoty): boolean; overload;
        //true if window destroyed
  public
   constructor create(const aowner: twidget; const agdi: pgdifunctionaty = nil);
                                                 //nil = platform default
   destructor destroy; override;
   procedure destroywindow;
   procedure registeronscroll(const method: notifyeventty);
   procedure unregisteronscroll(const method: notifyeventty);
   
   function beginmodal: boolean; overload;//true if window destroyed
   procedure endmodal;
   function modal: boolean;
   function modalwindowbefore: twindow;
   function transientforstackactive: boolean; 
         //true if the window is member of the active transient for stack
   procedure activate(const force: boolean = false);
   function active: boolean;
   function deactivateintermediate: boolean; 
         //true if ok, sets app.finactivewindow
   procedure reactivate(const force: boolean = false); 
                                       //clears app.finactivewindow
   procedure update;
   function candefocus: boolean;
   procedure nofocus;
   property focuscount: longword read ffocuscount;
   function close: boolean; overload; //true if ok
   function close(const amodalresult: modalresultty): boolean; 
                            overload;//true if ok
   procedure beginmoving; //lock window rect modification
   procedure endmoving;
   procedure bringtofront;
   procedure bringtofrontlocal;
   procedure sendtoback;
   procedure sendtobacklocal;
   procedure stackunder(const predecessor: twindow);
       //stacking is performed in mainloop idle, nil means top
   procedure stackover(const predecessor: twindow);
       //stacking is performed in mainloop idle, nil means bottom
   function stackedunder(const avisible: boolean = false): twindow; //nil if top
   function stackedover(const avisible: boolean = false): twindow; 
                                                               //nil if bottom
   function hastransientfor: boolean;
   function istransientfor(const base: twindow): boolean;
                                //base can be nil
   function defaulttransientfor: twindow;

   function capturemouse: boolean; //true for new grab
   procedure releasemouse;
   function mousecaptured: boolean;
   
   procedure postkeyevent(const akey: keyty; 
        const ashiftstate: shiftstatesty = []; const release: boolean = false;
                  const achars: msestring = '');

   function winid: winidty;
   function haswinid: boolean;
   function state: windowstatesty;
   function visible: boolean;
   function activating: boolean; //in internalactivate proc
   function normalwindowrect: rectty;
   property updateregion: regionty read fupdateregion.region;
   function updaterect: rectty;

   procedure registermovenotification(sender: iobjectlink);
   procedure unregistermovenotification(sender: iobjectlink);

   property options: windowoptionsty read foptions;
   function ispopup: boolean; {$ifdef FPC}inline;{$endif}
   property owner: twidget read fownerwidget;
   property focusedwidget: twidget read ffocusedwidget;
   property transientfor: twindow read ftransientfor;
   property modalfor: boolean read getmodalfor;
   property modalresult: modalresultty read fmodalresult write setmodalresult;
   property buttonendmodal: boolean read getbuttonendmodal write setbuttonendmodal;
   property globalshortcuts: boolean read getglobalshortcuts write setglobalshortcuts;
   property localshortcuts: boolean read getlocalshortcuts write setlocalshortcuts;
   property windowpos: windowposty read getwindowpos write setwindowpos;
   property caption: msestring read fcaption write setcaption;
   property container: winidty read fcontainer 
                                    write setcontainer default 0;
   property syscontainer: syswindowty read fsyscontainer 
                                    write setsyscontainer default sywi_none;

   property screenpos: pointty read getscreenpos write setscreenpos;
   property decoratedwidgetrect: rectty read getdecoratedwidgetrect 
                                     write setdecoratedwidgetrect;
   property decoratedpos: pointty read getdecoratedpos
                                     write setdecoratedpos;
   property decoratedsize: sizety read getdecoratedsize
                                     write setdecoratedsize;
   property decoratedbounds_x: integer read getdecoratedbounds_x
                                     write setdecoratedbounds_x;
   property decoratedbounds_y: integer read getdecoratedbounds_y
                                     write setdecoratedbounds_y;
   property decoratedbounds_cx: integer read getdecoratedbounds_cx
                                     write setdecoratedbounds_cx;
   property decoratedbounds_cy: integer read getdecoratedbounds_cy
                                     write setdecoratedbounds_cy;
 end;

 windowarty = array of twindow;
 pwindowarty = ^windowarty;
 windowaty = array[0..0] of twindow;
 pwindowaty = ^windowaty;

 windowchangeeventty = procedure(const oldwindow,newwindow: twindow) of object;
 widgetchangeeventty = procedure(const oldwidget,newwidget: twidget) of object;
 windoweventty = procedure(const awindow: twindow) of object;
 winideventty = procedure(const awinid: winidty) of object;
 booleaneventty = procedure(const avalue: boolean) of object;

 twindowrectevent = class(twindowevent)
  private
  public
   frect: rectty;
   forigin: pointty;
   constructor create(akind: eventkindty; winid: winidty;
                        const rect: rectty; const aorigin: pointty);
 end;

 tmouseevent = class(twindowevent)
  private
   ftimestamp: longword;
  public
   fpos: pointty;
   fbutton: mousebuttonty;
   fwheel: mousewheelty;
   fshiftstate: shiftstatesty;
   freflected: boolean;
   property timestamp: longword read ftimestamp; //usec, 0 -> invalid
   constructor create(const winid: winidty; const release: boolean;
                      const button: mousebuttonty; const wheel: mousewheelty;
                      const pos: pointty; const shiftstate: shiftstatesty;
                      atimestamp: longword; const reflected: boolean = false);
                      //button = none for mousemove
 end;

 tmouseenterevent = class(tmouseevent)
  public
   constructor create(const winid: winidty; const pos: pointty;
                      const shiftstate: shiftstatesty; atimestamp: longword);
 end;
 
 tkeyevent = class(twindowevent)
  private
   ftimestamp: longword;
  public
   fkey: keyty;
   fkeynomod: keyty;
   fchars: msestring;
   fbutton: mousebuttonty;
   fshiftstate: shiftstatesty;
   constructor create(const winid: winidty; const release: boolean;
                  const key,keynomod: keyty; const shiftstate: shiftstatesty;
                  const chars: msestring; const atimestamp: longword);
   property timestamp: longword read ftimestamp; //usec
 end;

 tresizeevent = class(tobjectevent)
  public
   size: sizety;
   constructor create(const dest: ievent; const asize: sizety);
 end;

 tguiapplication = class; 
 waitidleeventty = procedure(const sender: tguiapplication; var again: boolean)
                                      of object; 
 helpeventty = procedure(const sender: tmsecomponent;
                                      var handled: boolean) of object;

 syseventhandlereventty = procedure(const awindow: winidty;
                  var aevent: syseventty; var handled: boolean) of object;

 keyinfoty = record
  key: keyty;
  keynomod: keyty;
  shiftstate: shiftstatesty;
 end;

 guiappoptionty = (gao_forcezorder);
 guiappoptionsty = set of guiappoptionty;
 
 keyinfoarty = array of keyinfoty; 
 tguiapplication = class(tcustomapplication)
  private
   fwindows: windowarty;
   fwindowupdateindex: integer;
   fgroupzorder: windowarty;
   factivewindow: twindow;
   flastactivewindow: twindow;
   fwantedactivewindow: twindow; //set by twindow.activate if modal
   finactivewindow: twindow;
   ffocuslockwindow: twindow;
   ffocuslocktransientfor: twindow;
   fmouse: tmouse;
   fcaret: tcaret;
   fmousecapturewidget: twidget;
   fmousewidget: twidget;
   fmousewidgetpos: pointty; //last mousepos sent to widget
   fmousehintwidget: twidget;
   fkeyboardcapturewidget: twidget;
   fclientmousewidget: twidget;
   fhintedwidget: twidget;
   fhintforwidget: twidget;
   fhintinfo: hintinfoty;
   fmainwindow: twindow;
   fdblclicktime: integer;
   fcursorshape: cursorshapety;
   fwidgetcursorshape: cursorshapety;
   fbuttonpresswidgetbefore: twidget;
   fbuttonreleasewidgetbefore: twidget;
   factmousewindow: twindow;
   fdelayedmouseshift: pointty;
   fmodalwindowbeforewaitdialog: twindow;
   fonterminatebefore: threadcompeventty;
   fexecuteaction: notifyeventty;
   fidleaction: waitidleeventty;
   feventlooping: integer;
   fkeyhistory: keyinfoarty;
   flastshiftstate: shiftstatesty;
   flastkey: keyty;
   flastbutton: mousebuttonty;
   fkeyeventinfo: pkeyeventinfoty;
   fmouseeventinfo: pmouseeventinfoty;
   fmousewheeleventinfo: pmousewheeleventinfoty;

   fmousewheelfrequmin: real;
   fmousewheelfrequmax: real;
   fmousewheeldeltamin: real;
   fmousewheeldeltamax: real;
   fmousewheelaccelerationmax: real;
   flastinputtimestamp: longword;
   flastmousewheeltimestamp: longword;
   flastmousewheeltimestampbefore: longword;
   
   fcurrmodalinfo: pmodalinfoty;
   flooplevel: integer;
   
   procedure invalidated;
   function grabpointer(const aid: winidty): boolean;
   function ungrabpointer: boolean;
   procedure setmousewidget(const widget: twidget);
   procedure setclientmousewidget(const widget: twidget; const apos: pointty);
   procedure capturemouse(const sender: twidget; const grab: boolean);
               //sender = nil for release
   procedure activatehint;
   procedure deactivatehint;
   procedure hinttimer(const sender: tobject);
   procedure internalshowhint(const sender: twidget);
   procedure setmainwindow(const Value: twindow);
   procedure setcursorshape(const avalue: cursorshapety);
   procedure setwidgetcursorshape(const avalue: cursorshapety);
   function getwindows(const index: integer): twindow;
   procedure dothreadterminated(const sender: tthreadcomp);
   procedure dowaitidle(var again: boolean);
   procedure dowaitidle1(var again: boolean);
   function getforcezorder: boolean;
   procedure setforcezorder(const avalue: boolean);
  protected  
   foptionsgui: guiappoptionsty;
   procedure sysevent(const awindow: winidty; var aevent: syseventty;
                                                    var handled: boolean);
   procedure sethighrestimer(const avalue: boolean); override;
   procedure dopostevent(const aevent: tmseevent); override;
   procedure eventloop(const once: boolean = false);
                        //used in win32 wm_queryendsession and wm_entersizemove
   procedure exitloop;  //used in win32 cancelshutdown
   procedure receiveevent(const event: tobjectevent); override;
   procedure doafterrun; override;
   procedure internalinitialize; override;
   procedure internaldeinitialize;  override;
   procedure objecteventdestroyed(const sender: tobjectevent); override;
   procedure dragstarted; //calls dragstarted of all known widgets
   procedure internalpackwindowzorder(); virtual;
  public
   constructor create(aowner: tcomponent); override;
   procedure destroyforms;
   property optionsgui: guiappoptionsty read foptionsgui 
                                                write foptionsgui default [];
   property forcezorder: boolean read getforcezorder write setforcezorder;   
   procedure langchanged; override;
   procedure settimer(const us: integer); override;
   function findwindow(aid: winidty; out window: twindow): boolean;
   procedure checkwindowrect(winid: winidty; var rect: rectty);
                        //callback from win32 wm_sizing

   function createform(instanceclass: widgetclassty; var reference): twidget;
   procedure invalidate; //invalidates all registered forms
   
   procedure processmessages; override; //handle with care!
   function idle: boolean; override;
   function modallevel: integer; override;

   procedure beginnoignorewaitevents;   
   procedure endnoignorewaitevents;   
   procedure beginwait(const aprocessmessages: boolean = false); override;
   procedure endwait; override;
   function waiting: boolean;
   function waitescaped: boolean; override;
                //true if escape pressed while waiting

   procedure resetwaitdialog;   
   function waitdialog(const athread: tthreadcomp = nil; const atext: msestring = '';
                   const caption: msestring = '';
                   const acancelaction: notifyeventty = nil;
                   const aexecuteaction: notifyeventty = nil;
                   const aidleaction: waitidleeventty = nil): boolean;
              //true if not canceled
   procedure terminatewait;
   procedure cancelwait;
   function waitstarted: boolean;
   function waitcanceled: boolean;
   function waitterminated: boolean;   

   procedure showexception(e: exception; const leadingtext: msestring = ''); override;
   procedure showasyncexception(e: exception; const leadingtext: msestring = '');
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
   procedure showhint(const sender: twidget; const hint: msestring); overload;
   procedure hidehint;
   procedure restarthint(const sender: twidget);
   function hintedwidget: twidget; //last hinted widget
   function activehintedwidget: twidget; //nil if no hint active

   procedure help(const sender: tmsecomponent);
   procedure registerhelphandler(const ahandler: helpeventty);
   procedure unregisterhelphandler(const ahandler: helpeventty);
   function activehelpcontext: msestring;
                //returns helpcontext of active widget, '' if none;
   function mousehelpcontext: msestring;
                //returns helpcontext of mouse widget, '' if none;

   function active: boolean;
   procedure activate();
   function screenrect(const awindow: twindow = nil): rectty;
                          //nil -> virtualscreeen
   function workarea(const awindow: twindow = nil): rectty;
                          //nil -> current active window
   property activewindow: twindow read factivewindow;
   property lastactivewindow: twindow read flastactivewindow;
   property inactivewindow: twindow read finactivewindow;
   function normalactivewindow: twindow; 
        //active window or active window after closing modal stack if defined
   function regularactivewindow: twindow; //first no transientfor window
   function unreleasedactivewindow: twindow;
   function activewidget: twidget;
   function activerootwidget: twidget;
   
   function windowatpos(const pos: pointty): twindow;
   function findwidget(const namepath: string; out awidget: twidget): boolean;
             //false if invalid namepath, '' -> nil and true
   procedure sortzorder();
             //window list is ordered by z, bottom first, top last,
             //invisibles first
   procedure packwindowzorder();
   
   function windowar: windowarty;
   function winidar: winidarty;
   function windowcount: integer;
   property windows[const index: integer]: twindow read getwindows;
   function bottomwindow: twindow;
      //lowest visible window in stackorder, calls sortzorder
   function topwindow: twindow;
      //highest visible window in stackorder, calls sortzorder
   function candefocus(const caller: tobject = nil): boolean; override;
      //checks candefocus of all windows expect caller

   procedure registeronkeypress(const method: keyeventty);
   procedure unregisteronkeypress(const method: keyeventty);
   procedure registeronshortcut(const method: keyeventty);
   procedure unregisteronshortcut(const method: keyeventty);
   procedure registeronwidgetactivechanged(const method: widgetchangeeventty);
   procedure unregisteronwidgetactivechanged(const method: widgetchangeeventty);
   procedure registeronwindowactivechanged(const method: windowchangeeventty);
   procedure unregisteronwindowactivechanged(const method: windowchangeeventty);
   procedure registeronwindowdestroyed(const method: windoweventty);
   procedure unregisteronwindowdestroyed(const method: windoweventty);
   procedure registeronwiniddestroyed(const method: winideventty);
   procedure unregisteronwiniddestroyed(const method: winideventty);
   procedure registeronapplicationactivechanged(const method: booleaneventty);
   procedure unregisteronapplicationactivechanged(const method: booleaneventty);
   procedure registersyseventhandler(const method: syseventhandlereventty);
   procedure unregistersyseventhandler(const method: syseventhandlereventty);

   function terminate(const sender: twindow = nil): boolean; 
        //calls canclose of all windows except sender and terminatequery
        //true if terminated
   function terminating: boolean;
   function deinitializing: boolean;
   function shortcutting: boolean; //widget is in doshortcut procedure
   property caret: tcaret read fcaret;
   property mouse: tmouse read fmouse;
   procedure mouseparkevent; //simulates mouseparkevent
   procedure delayedmouseshift(const ashift: pointty);
   procedure calcmousewheeldelta(var info: mousewheeleventinfoty;
               const fmin,fmax,deltamin,deltamax: real);  
   function mousewheelacceleration(const avalue: real): real; overload;
   function mousewheelacceleration(const avalue: integer): integer; overload;
   procedure clearkeyhistory; //called by matching shortcut sequence
   property keyhistory: keyinfoarty read fkeyhistory;   
                        //does not contain modifier keys
   property lastinputtimestamp: longword read flastinputtimestamp;
                        //microseconds
   property lastshiftstate: shiftstatesty read flastshiftstate;
   property lastkey: keyty read flastkey;
   property lastbutton: mousebuttonty read flastbutton;
   property mouseeventinfo: pmouseeventinfoty read fmouseeventinfo;
                   //nil if no mouse event processing
   property mousewheeleventinfo: pmousewheeleventinfoty 
                                             read fmousewheeleventinfo;
                   //nil if no mousewheel event processing
   property keyeventinfo: pkeyeventinfoty read fkeyeventinfo;
                   //nil if no key event processing

   property cursorshape: cursorshapety read fcursorshape write setcursorshape;
                //persistent
   property widgetcursorshape: cursorshapety read fwidgetcursorshape write
                                        setwidgetcursorshape;
                //removed by mouse widget change
   procedure updatecursorshape; //restores cursorshape of mousewidget
   property mousewidget: twidget read fmousewidget;
   property clientmousewidget: twidget read fclientmousewidget;
   property mousecapturewidget: twidget read fmousecapturewidget;
   property mainwindow: twindow read fmainwindow write setmainwindow;
   property thread: threadty read fthread;

   property buttonpresswidgetbefore: twidget read fbuttonpresswidgetbefore;
   property buttonreleasewidgetbefore: twidget read fbuttonreleasewidgetbefore;
   property dblclicktime: integer read fdblclicktime write fdblclicktime default
                 defaultdblclicktime; //us
   property mousewheelfrequmin: real read fmousewheelfrequmin write fmousewheelfrequmin;
   property mousewheelfrequmax: real read fmousewheelfrequmax write fmousewheelfrequmax;
   property mousewheeldeltamin: real read fmousewheeldeltamin write fmousewheeldeltamin;
   property mousewheeldeltamax: real read fmousewheeldeltamax write fmousewheeldeltamax;
   property mousewheelaccelerationmax: real read fmousewheelaccelerationmax 
                                  write fmousewheelaccelerationmax;
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
           //checks osk_nolayoutcx, osk_nolayoutcy
procedure syncpaintwidth(const awidgets: array of twidget;
                               const awidgetwidth: integer = -1);
                               //biggest if < 0
      //synchronizes paintwidth with paintwidth of largest outer framewidth
      //(ex. largest caption)
procedure syncpaintheight(const awidgets: array of twidget;
                               const awidgetheight: integer = -1);
                               //biggest if < 0
      //synchronizes paintheight with paintheight of largest outer framewidth 
      //(ex. largest caption)

function checkshortcut(var info: keyeventinfoty;
          const caption: richstringty; const checkalt: boolean): boolean; overload;
function checkshortcut(var info: keyeventinfoty;
          const key: keyty; const shiftstate: shiftstatesty): boolean; overload;

type
 getwidgetintegerty = function(const awidget: twidget): integer;
 getwidgetbooleanty = function(const awidget: twidget): boolean;
 setwidgetintegerty = procedure(const awidget: twidget; const avalue: integer);
 widgetaccessty = record
  pos,size,stop,min,max,opos,osize,ostop,omin,omax: getwidgetintegerty;
  setpos,setsize,setstop,setmin,setmax,
           setopos,setosize,setostop,setomin,setomax: setwidgetintegerty;
  anchstop,oanchstop: getwidgetbooleanty;
 end;
 pwidgetaccessty = ^widgetaccessty;
 
function wbounds_x(const awidget: twidget): integer;
procedure wsetbounds_x(const awidget: twidget; const avalue: integer);
function wbounds_y(const awidget: twidget): integer;
procedure wsetbounds_y(const awidget: twidget; const avalue: integer);
function wbounds_cx(const awidget: twidget): integer;
procedure wsetbounds_cx(const awidget: twidget; const avalue: integer);
function wbounds_cy(const awidget: twidget): integer;
procedure wsetbounds_cy(const awidget: twidget; const avalue: integer);
function wstopx(const awidget: twidget): integer;
procedure wsetstopx(const awidget: twidget; const avalue: integer);
function wstopy(const awidget: twidget): integer;
procedure wsetstopy(const awidget: twidget; const avalue: integer);
function wanchstopx(const awidget: twidget): boolean;
function wanchstopy(const awidget: twidget): boolean;

function wbounds_cxmin(const awidget: twidget): integer;
procedure wsetbounds_cxmin(const awidget: twidget; const avalue: integer);
function wbounds_cymin(const awidget: twidget): integer;
procedure wsetbounds_cymin(const awidget: twidget; const avalue: integer);
function wbounds_cxmax(const awidget: twidget): integer;
procedure wsetbounds_cxmax(const awidget: twidget; const avalue: integer);
function wbounds_cymax(const awidget: twidget): integer;
procedure wsetbounds_cymax(const awidget: twidget; const avalue: integer);

const
 widgetaccessx: widgetaccessty = (
  pos: {$ifdef FPC}@{$endif}wbounds_x;
  size: {$ifdef FPC}@{$endif}wbounds_cx;
  stop: {$ifdef FPC}@{$endif}wstopx;
  min: {$ifdef FPC}@{$endif}wbounds_cxmin;
  max: {$ifdef FPC}@{$endif}wbounds_cxmax;
  opos: {$ifdef FPC}@{$endif}wbounds_y;
  osize: {$ifdef FPC}@{$endif}wbounds_cy;
  ostop: {$ifdef FPC}@{$endif}wstopy;
  omin: {$ifdef FPC}@{$endif}wbounds_cymin;
  omax: {$ifdef FPC}@{$endif}wbounds_cymax;
  setpos: {$ifdef FPC}@{$endif}wsetbounds_x;
  setsize: {$ifdef FPC}@{$endif}wsetbounds_cx;
  setstop: {$ifdef FPC}@{$endif}wsetstopx;
  setmin: {$ifdef FPC}@{$endif}wsetbounds_cxmin;
  setmax: {$ifdef FPC}@{$endif}wsetbounds_cxmax;
  setopos: {$ifdef FPC}@{$endif}wsetbounds_y;
  setosize: {$ifdef FPC}@{$endif}wsetbounds_cy;
  setostop: {$ifdef FPC}@{$endif}wsetstopy;
  setomin: {$ifdef FPC}@{$endif}wsetbounds_cymin;
  setomax: {$ifdef FPC}@{$endif}wsetbounds_cymax;
  anchstop: {$ifdef FPC}@{$endif}wanchstopx;
  oanchstop: {$ifdef FPC}@{$endif}wanchstopy;
 );
 widgetaccessy: widgetaccessty = (
  pos: {$ifdef FPC}@{$endif}wbounds_y;
  size: {$ifdef FPC}@{$endif}wbounds_cy;
  stop: {$ifdef FPC}@{$endif}wstopy;
  min: {$ifdef FPC}@{$endif}wbounds_cymin;
  max: {$ifdef FPC}@{$endif}wbounds_cymax;
  opos: {$ifdef FPC}@{$endif}wbounds_x;
  osize: {$ifdef FPC}@{$endif}wbounds_cx;
  ostop: {$ifdef FPC}@{$endif}wstopx;
  omin: {$ifdef FPC}@{$endif}wbounds_cxmin;
  omax: {$ifdef FPC}@{$endif}wbounds_cxmax;
  setpos: {$ifdef FPC}@{$endif}wsetbounds_y;
  setsize: {$ifdef FPC}@{$endif}wsetbounds_cy;
  setstop: {$ifdef FPC}@{$endif}wsetstopy;
  setmin: {$ifdef FPC}@{$endif}wsetbounds_cymin;
  setmax: {$ifdef FPC}@{$endif}wsetbounds_cymax;
  setopos: {$ifdef FPC}@{$endif}wsetbounds_x;
  setosize: {$ifdef FPC}@{$endif}wsetbounds_cx;
  setostop: {$ifdef FPC}@{$endif}wsetstopx;
  setomin: {$ifdef FPC}@{$endif}wsetbounds_cxmin;
  setomax: {$ifdef FPC}@{$endif}wsetbounds_cxmax;
  anchstop: {$ifdef FPC}@{$endif}wanchstopy;
  oanchstop: {$ifdef FPC}@{$endif}wanchstopx;
 );
  
function application: tguiapplication;
function mousebuttontoshiftstate(button: mousebuttonty): shiftstatesty;
function isenterkey(const awidget: twidget; const key: keyty): boolean;
function isdblclick(const ainfo: mouseeventinfoty;
                           const abutton: mousebuttonty  = mb_left): boolean;
function eatdblclick(var ainfo: mouseeventinfoty;
                           const abutton: mousebuttonty  = mb_left): boolean;

procedure beep;
procedure guibeep;
procedure enablewidgets(awidgets: array of twidget);
procedure disablewidgets(awidgets: array of twidget);
procedure showwidgets(awidgets: array of twidget);
procedure hidewidgets(awidgets: array of twidget);
function showmodalwidget(const aclass: widgetclassty): modalresultty;


procedure writewidgetnames(const writer: twriter; const ar: widgetarty);
function needswidgetnamewriting(const ar: widgetarty): boolean; overload;
function needswidgetnamewriting(const ar1,ar2: widgetarty): boolean; overload;

procedure designeventloop;

function getprocesswindow(const procid: integer): winidty;
function activateprocesswindow(const procid: integer; 
                    const araise: boolean = true): boolean;
         //true if ok
function combineframestateflags(
            const disabled,active,mouse,clicked: boolean): framestateflagsty;

{$ifdef mse_debug}
procedure debugwindow(const atext: string; const aid: winidty); overload;
procedure debugwindow(const atext: string; const aid1,aid2: winidty); overload;
function checkwindowname(const aid: winidty; const aname: string): boolean;
{$endif}

implementation

uses
 msesysintf,typinfo,msestreaming,msetimer,msebits,msewidgets,
 mseshapes,msestockobjects,msefileutils,msedatalist,Math,msesysutils,
 rtlconsts,{$ifndef FPC}classes_del,{$endif}mseformatstr,
 mseprocutils,msesys,msesysdnd;

const
 faceoptionsmask: faceoptionsty = [fao_alphafadeimage,fao_alphafadenochildren,
                        fao_alphafadeall];
type
 tcanvas1 = class(tcanvas);
 tfadecolorarrayprop1 = class(tfadecolorarrayprop);
 trealarrayprop1 = class(trealarrayprop);
 tcaret1 = class(tcaret);
 tobjectevent1 = class(tobjectevent);
 tsysmimedragobject1 = class(tsysmimedragobject);

const
 cancelwaittag = 823757;
type
 tasyncmessageevent = class(tuserevent)
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
   fmodallevel: modallevelty;
   ftransientfor: twindow;
  protected
   procedure execute; override;
 end;
 
 tcreatewindowevent = class(tsynchronizeevent)
  private
   fsender: twindow;
   frect: rectty;
   foptionspo: pinternalwindowoptionsty;
   fwindowpo: pwindowty;
  protected
   procedure execute; override;
 end;

 tdestroywindowevent = class(tsynchronizeevent)
  private
   fwindowpo: pwindowty;
  protected
   procedure execute; override;
 end;
 
 tonkeyeventlist = class(tmethodlist)
  protected
   procedure dokeyevent(const sender: twidget; var info: keyeventinfoty);
 end;

 tonwidgetchangelist = class(tmethodlist)
  protected
   procedure dowidgetchange(const oldwidget,newwidget: twidget);
 end;

 tonwindowchangelist = class(tmethodlist)
  protected
   procedure dowindowchange(const oldwindow,newwindow: twindow);
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

 tonhelpeventlist = class(tmethodlist)
  protected
   procedure doevent(const sender: tmsecomponent);
 end;
 
 tonsyseventlist = class(tmethodlist)
  protected
   procedure doevent(const awindow: winidty; var aevent: syseventty;
                               var handled: boolean);
 end;
 
 windowstackinfoty = record
  lower,upper: twindow;
  level: integer;
  recursion: boolean;
 end;
 windowstackinfoarty = array of windowstackinfoty;
 
const
 keyhistorylen = 10;
 
type 
 tinternalapplication = class(tguiapplication,imouse)
         //avoid circular interface references
  private
   fonkeypresslist: tonkeyeventlist;
   fonshortcutlist: tonkeyeventlist;
   fonwidgetactivechangelist: tonwidgetchangelist;
   fonwindowactivechangelist: tonwindowchangelist;
   fonwindowdestroyedlist: tonwindoweventlist;
   fonwiniddestroyedlist: tonwinideventlist;
   fonapplicationactivechangedlist: tonapplicationactivechangedlist;
   fonhelp: tonhelpeventlist;
   fonsyseventlist: tonsyseventlist;

   fcaretwidget: twidget;
   fmousewinid: winidty;
   fdesigning: boolean;
   fmodalwindow: twindow;
   flockupdatewindowstack: twindow;
   fhintwidget: thintwidget;
   fhinttimer: tsimpletimer;
   fmouseparktimer: tsimpletimer;
   fmouseparkeventinfo: mouseeventinfoty;
   ftimestampbefore: longword;
   flastbuttonpress: mousebuttonty;
   flastbuttonpresstimestamp: longword;
   flastbuttonrelease: mousebuttonty;
   flastbuttonreleasetimestamp: longword;
   fdoublemousepress,fdoublemouserelease: boolean;
   fwindowstack: windowstackinfoarty;
   ftimertick: boolean;

   procedure twindowdestroyed(const sender: twindow);
   procedure windowdestroyed(aid: winidty);
   procedure setwindowfocus(winid: winidty);
   procedure unsetwindowfocus(winid: winidty);
   procedure registerwindow(window: twindow);
   procedure unregisterwindow(window: twindow);
   procedure widgetdestroyed(const widget: twidget);
   procedure zorderinvalid();

   procedure processexposeevent(event: twindowrectevent);
   procedure processconfigureevent(event: twindowrectevent);
   procedure processshowingevent(event: twindowevent);
   procedure processmouseevent(event: tmouseevent);
   procedure processkeyevent(event: tkeyevent);
   procedure processleavewindow;
   procedure processwindowcrossingevent(event: twindowevent);

   function getmousewinid: winidty; //for  tmouse.setshape
   procedure waitevent;         
    //application must be locked
   procedure checkactivewindow;
   function focusinpending: boolean;
   procedure checkapplicationactive;
   function winiddestroyed(const aid: winidty): boolean;
   procedure eventloop(const once: boolean = false);
   function beginmodal(const sender: twindow;
                               const showinfo: pshowinfoty): boolean;
                 //true if modalwindow destroyed
   procedure endmodal(const sender: twindow);
   procedure stackunder(const sender: twindow; const predecessor: twindow);
   procedure stackover(const sender: twindow; const predecessor: twindow);
   procedure checkwindowstack;
   procedure updatewindowstack;
                //reorders windowstack by ow_background,ow_top
   procedure checkcursorshape;

   procedure mouseparktimer(const sender: tobject);
   procedure removewindowevents(const awindow: winidty; 
                                              const aeventkind: eventkindty);
  protected
   procedure internalpackwindowzorder(); override;
   function getevents: integer; override;
    //application must be locked
    //returns count of queued events
   procedure dopostevent(const aevent: tmseevent); override;
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

function combineframestateflags(
            const disabled,active,mouse,clicked: boolean): framestateflagsty;
begin
 result:= [];
 if disabled then include(result,fsf_disabled);
 if active then include(result,fsf_active);
 if mouse then include(result,fsf_mouse);
 if clicked then include(result,fsf_clicked);
end;

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

function wstopx(const awidget: twidget): integer;
begin
 result:= awidget.bounds_x + awidget.bounds_cx;
end;

procedure wsetstopx(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cx:= avalue - awidget.bounds_x;
end;

function wstopy(const awidget: twidget): integer;
begin
 result:= awidget.bounds_y + awidget.bounds_cy;
end;

procedure wsetstopy(const awidget: twidget; const avalue: integer);
begin
 awidget.bounds_cy:= avalue - awidget.bounds_y;
end;

function wanchstopx(const awidget: twidget): boolean;
begin
 result:= an_right in awidget.anchors;
end;

function wanchstopy(const awidget: twidget): boolean;
begin
 result:= an_bottom in awidget.anchors;
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

function checkshortcut(var info: keyeventinfoty; const caption: richstringty;
                         const checkalt: boolean): boolean;
begin
 with info do begin
  if (eventstate * [es_processed,es_modal,es_preview] = []) and 
    (not checkalt and (shiftstate -[ss_alt] = []) or (shiftstate = [ss_alt])) and
                         (length(info.chars) > 0) then begin
   result:= isshortcut(info.chars[1],caption);
   if result then begin
    include(eventstate,es_processed);
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function checkshortcut(var info: keyeventinfoty;
          const key: keyty; const shiftstate: shiftstatesty): boolean;
begin
 result:= (key = info.key) and (shiftstate = info.shiftstate);
 if result then begin
  include(info.eventstate,es_processed);
 end;
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
 ar1: procidarty;
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
  with widgets[int1] do begin
   size2:= clientsize;   
   getautopaintsize(size2);
   if not (osk_nolayoutcx in optionsskin) then begin
    if size2.cx > size1.cx then begin
     size1.cx:= size2.cx;
    end;
   end;
   if not (osk_nolayoutcy in optionsskin) then begin
    if size2.cy > size1.cy then begin
     size1.cy:= size2.cy;
    end;
   end;
  end;
 end;
 for int1:= 0 to high(widgets) do begin
  with widgets[int1] do begin
   rect1:= fwidgetrect;
   size2:= clientsize;
   if not (osk_nolayoutcx in optionsskin) then begin
    size2.cx:= size1.cx;
   end;
   if not (osk_nolayoutcy in optionsskin) then begin
    size2.cy:= size1.cy;
   end;
   clientsize:= size2;
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

procedure syncpaintwidth(const awidgets: array of twidget;
                            const awidgetwidth: integer = -1);
var
 int1,int2,int3: integer;
 widget1: twidget;
begin
 if high(awidgets) >= 0 then begin
  int2:= -bigint;
  widget1:= awidgets[0]; //compiler warning
  for int1:= 0 to high(awidgets) do begin //first widget first
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
  if awidgetwidth >= 0 then begin
   with widget1 do begin //biggest frame
    if anchors * [an_left,an_right] = [an_right] then begin
     bounds_x:= bounds_x - awidgetwidth + bounds_cx;
    end;
    bounds_cx:= awidgetwidth;
   end;
  end;
  int2:= widget1.bounds_cx - int2; //min frame width
  for int1:= high(awidgets) downto 0 do begin
   with awidgets[int1] do begin
    if fframe = nil then begin
     int3:= 0;
    end
    else begin
     int3:= fframe.fouterframe.left + fframe.fouterframe.right;
    end;
    int3:= int3 + int2;
    if anchors * [an_left,an_right] = [an_right] then begin
     bounds_x:= bounds_x - int3 + bounds_cx;
    end;
    bounds_cx:= int3;
   end;
  end;
 end;
end;

procedure syncpaintheight(const awidgets: array of twidget;
                   const awidgetheight: integer = -1);
var
 int1,int2,int3: integer;
 widget1: twidget;
begin
 if high(awidgets) >= 0 then begin
  int2:= -bigint;
  widget1:= awidgets[0]; //compiler warning
  for int1:= 0 to high(awidgets) do begin //first widget first
   with awidgets[int1] do begin
    if fframe = nil then begin
     int3:= 0;
    end
    else begin
     int3:= fframe.fouterframe.top + fframe.fouterframe.bottom;
    end;
   end;
   if int3 > int2 then begin
    widget1:= awidgets[int1];
    int2:= int3;
   end;
  end;
  if awidgetheight >= 0 then begin
   with widget1 do begin
    if anchors * [an_top,an_bottom] = [an_bottom] then begin
     bounds_y:= bounds_y - awidgetheight + bounds_cy;
    end;
    bounds_cy:= awidgetheight;
   end;
  end;
  int2:= widget1.bounds_cy - int2; //min frame width
  for int1:= high(awidgets) downto 0 do begin
   with awidgets[int1] do begin
    if fframe = nil then begin
     int3:= 0;
    end
    else begin
     int3:= fframe.fouterframe.top + fframe.fouterframe.bottom;
    end;
    int3:= int3 + int2;
    if anchors * [an_top,an_bottom] = [an_bottom] then begin
     bounds_y:= bounds_y - int3 + bounds_cy;
    end;
    bounds_cy:= int3;
   end;
  end;
 end;
end;

procedure beep;
begin
 gui_beep;
end;

procedure guibeep;
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
  tinternalapplication(appinst).eventloop({nil});
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

function needswidgetnamewriting(const ar1,ar2: widgetarty): boolean;
var
 int1: integer;
begin
 result:= high(ar1) <> high(ar2);
 if not result then begin;
  for int1:= 0 to high(ar1) do begin
   if (ar1[int1] = nil) or (ar2[int1] = nil) then begin
    if (ar1[int1] <> ar2[int1]) then begin
     result:= true;
     break;
    end;
   end
   else begin
    if ar1[int1].name <> ar2[int1].name then begin
     result:= true;
     break;
    end;
   end;
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

function application: tguiapplication;
begin
 if appinst = nil then begin
  tinternalapplication.create(nil);
//  appinst.initialize;
 end;
 result:= appinst;
end;

function mousebuttontoshiftstate(button: mousebuttonty): shiftstatesty;
begin
 if button = mb_none then begin
  result:= [];
 end
 else begin
  result:= [shiftstatety(longword(ss_left) +
                  longword(button) - longword(mb_left))];
 end;
end;

function isenterkey(const awidget: twidget; const key: keyty): boolean;
begin
 result:= ((awidget = nil) or not 
              (ow_keyreturntaborder in awidget.optionswidget)) and 
          ({(key = key_enter) or} (key = key_return));
end;

function isdblclick(const ainfo: mouseeventinfoty;
                          const abutton: mousebuttonty = mb_left): boolean;
begin
 with ainfo do begin
  result:= (button = abutton) and (eventkind = ek_buttonpress) and 
                                                (ss_double in shiftstate);
 end;
end;

function eatdblclick(var ainfo: mouseeventinfoty;
                          const abutton: mousebuttonty = mb_left): boolean;
begin
 result:= isdblclick(ainfo,abutton);
 if result then begin
  include(ainfo.eventstate,es_processed);
 end;
end;

procedure destroyregion(var region: gdiregionty);
var
 info: drawinfoty;
begin
 with region do begin
  if region <> 0 then begin
   info.regionoperation.source:= region;
   gdi_call(gdf_destroyregion,info,gdi);
   region:= 0;
  end;
 end;
end;

function createregion(const gdi: pgdifunctionaty): gdiregionty; overload;
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  gdi_call(gdf_createemptyregion,info,gdi);
  result.region:= dest;
  result.gdi:= gdi;
 end;
end;

function createregion(const arect: rectty;
                          const gdi: pgdifunctionaty): gdiregionty; overload;
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  rect:= arect;
  gdi_call(gdf_createrectregion,info,gdi);
  result.region:= dest;
  result.gdi:= gdi;
 end;
end;

function createregion(const rects: rectarty;
                           const gdi: pgdifunctionaty): gdiregionty; overload;
var
 info: drawinfoty;
begin
 with info.regionoperation do begin
  rectscount:= length(rects);
  if rectscount > 0 then begin
   rectspo:= @rects[0];
   gdi_call(gdf_createrectsregion,info,gdi);
   result.region:= dest;
   result.gdi:= gdi;
  end
  else begin
   result:= createregion(gdi);
  end;
 end;
end;

procedure regmove(const region: gdiregionty; const dist: pointty);
var
 info: drawinfoty;
begin
 with region,info.regionoperation do begin
  if region <> 0 then begin
   source:= region;
   rect.pos:= dist;
   gdi_call(gdf_moveregion,info,gdi);
  end;
 end;
end;

function regcliprect(const region: gdiregionty): rectty;
var
 info: drawinfoty;
begin
 with region,info.regionoperation do begin
  if region <> 0 then begin
   source:= region;
   gdi_call(gdf_regionclipbox,info,gdi);
   result:= rect;
  end
  else begin
   result:= nullrect;
  end;
 end;
end;

procedure regintersectrect(const region: gdiregionty; const arect: rectty);
var
 info: drawinfoty;
begin
 with region,info.regionoperation do begin
  dest:= region;
  rect:= arect;
  gdi_call(gdf_regintersectrect,info,gdi);
 end;
end;

procedure regaddrect(const region: gdiregionty; const arect: rectty);
var
 info: drawinfoty;
begin
 with region,info.regionoperation do begin
  dest:= region;
  rect:= arect;
  gdi_call(gdf_regaddrect,info,gdi);
 end;
end;

{ twidgetfont}

class function twidgetfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @twidget(owner).ffont;
end;

{ twidgetfontempty}

class function twidgetfontempty.getinstancepo(owner: tobject): pfont;
begin
 result:= @twidget(owner).ffontempty;
end;

{ tresizeevent }

constructor tresizeevent.create(const dest: ievent; const asize: sizety);
begin
 inherited create(ek_resize,dest);
 size:= asize;
end;

{ tcustomframe }

procedure initframeinfo(var info: baseframeinfoty); overload;
begin
 with info do begin
  colorclient:= cl_transparent;
  colorframe:= cl_default;
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

procedure initframeinfo(var info: captionframeinfoty); overload;
begin
 //dummy
end;

constructor tcustomframe.create(const intf: iframe);
var
 ws1: widgetstates1ty;
begin
 include(fstate,fs_creating);
 fintf:= intf;
 ws1:= fintf.getwidget.fwidgetstate1;
 if ws1_noframewidgetshift in ws1 then begin
  include(fstate,fs_nowidget);
 end;
 if ws1_framemouse in ws1 then begin
  include(fstate,fs_framemouse);
 end;
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

procedure tcustomframe.updatemousestate(const sender: twidget;
                 const info: mouseeventinfoty);
begin
 checkstate;
 with sender do begin
  if not (ow_mousetransparent in foptionswidget) then begin
   if pointinrect(info.pos,fpaintrect) then begin
    fwidgetstate:= fwidgetstate + [ws_mouseinclient,ws_wantmousemove,
                                       ws_wantmousebutton,ws_wantmousefocus];
   end
   else begin
    if (fs_framemouse in fstate) and 
       pointinrect(info.pos,mr(nullpoint,fintf.getwidgetrect.size)) then begin
     fwidgetstate:= fwidgetstate + [ws_wantmousemove,ws_wantmousebutton];
 
    end;
   end;
  end;
 end;
end;

function tcustomframe.needsactiveinvalidate: boolean;
begin
 with fi do begin
  result:=
   (frameimage_list <> nil) and 
    ((frameimage_offsetactive <> 0) or 
     (frameimage_offsetactivemouse <> frameimage_offsetmouse) or
     (frameimage_offsetactiveclicked <> frameimage_offsetclicked)
    ) or
   (frameface_list <> nil) and 
    ((frameface_offsetactive <> 0) or 
    (frameface_offsetactivemouse <> frameface_offsetmouse) or
    (frameface_offsetactiveclicked <> frameface_offsetclicked)
    );
 end;
end;

function tcustomframe.needsmouseinvalidate: boolean;
begin
 with fi do begin
  result:= (fs_needsmouseinvalidate in fstate) or
    (frameimage_list <> nil) and 
     ((frameimage_offsetmouse <> 0) or 
      (frameimage_offsetactivemouse <> 0) or
      (frameimage_offsetactiveclicked <> 0) or
      (frameimage_offsetclicked <> 0)
     ) or
    (frameface_list <> nil) and 
     ((frameface_offsetmouse <> 0) or 
      (frameface_offsetactivemouse <> 0) or
      (frameface_offsetactiveclicked <> 0) or
      (frameface_offsetclicked <> 0)
     );
 end;
end;

function tcustomframe.needsclickinvalidate: boolean;
begin
 with fi do begin
  result:= (frameimage_list <> nil) and 
           ((frameimage_offsets.clicked <> 0) or 
            (frameimage_offsets.activeclicked <> 
                                   frameimage_offsets.active)) or
          (frameface_list <> nil) and 
           ((frameface_offsets.clicked <> 0) or 
            (frameface_offsets.activeclicked <> 
                                   frameface_offsets.active));
 end;
end;

function tcustomframe.needsmouseenterinvalidate: boolean;
begin
 with fi do begin
  result:= ((frameimage_list <> nil) and 
             ((frameimage_offsets.mouse <> 0) or 
              (frameimage_offsets.activemouse <> 
                            frameimage_offsets.active))) or
            ((frameface_list <> nil) and 
               ((frameface_offsets.mouse <> 0) or 
                (frameface_offsets.activemouse <> 
                            frameface_offsets.active)));
 end;
end;
      
procedure tcustomframe.activechanged;
begin
 if needsactiveinvalidate then begin
  fintf.getwidget.invalidatewidget;
 end;
end;

function tcustomframe.needsfocuspaint: boolean;
begin
 result:= fs_drawfocusrect in fstate;
end;

function calcframestateoffs(const astate: framestateflagsty; 
                            const offsets: frameoffsetsty): integer;
begin
 with offsets do begin
  result:= offset;
  if fsf_offset1 in astate then begin
   result:= result + offset1;
  end;
  if fsf_disabled in astate then begin
   result:= result + disabled;
  end
  else begin
   if fsf_active in astate then begin
    if fsf_clicked in astate then begin
     result:= result + activeclicked;
    end
    else begin
     if fsf_mouse in astate then begin
      result:= result + activemouse;
     end
     else begin
      result:= result + active;
     end;
    end;
   end
   else begin
    if fsf_clicked in astate then begin
     result:= result + clicked;
    end
    else begin
     if fsf_mouse in astate then begin
      result:= result + mouse;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomframe.paintbackground(const canvas: tcanvas;
                            const arect: rectty; const clipandmove: boolean);
var
 rect1: rectty;
 faceoffs: integer;
begin
 rect1:= deflaterect(arect,fpaintframe);
 if fi.colorclient <> cl_transparent then begin
  canvas.fillrect(rect1,fi.colorclient);
 end;
 if fi.frameface_list <> nil then begin
  faceoffs:= calcframestateoffs(fintf.getframestateflags,
                                  frameoffsetsty(fi.frameface_offsets));
  if (faceoffs >= 0) and (faceoffs < fi.frameface_list.list.count) then begin
   fi.frameface_list.list[faceoffs].paint(canvas,rect1);
  end;
 end;
 if clipandmove then begin
  canvas.intersectcliprect(rect1);
  canvas.move(addpoint(fpaintrect.pos,fclientrect.pos));
  canvas.brushorigin:= nullpoint;
 end;
end;

class procedure tcustomframe.drawframe(const canvas: tcanvas; 
                         const rect2: rectty; const afi: baseframeinfoty; 
                         const astate: framestateflagsty);
var
 imageoffs: integer;
 rect1: rectty;
 col1: colorty;
begin
 rect1:= rect2;
 if afi.levelo <> 0 then begin
  draw3dframe(canvas,rect1,afi.levelo,afi.framecolors,afi.hiddenedges);
  updateedgerect(rect1,abs(afi.levelo),afi.hiddenedges);
 end;
 if afi.framewidth > 0 then begin
  if (afi.colorframeactive = cl_default) or 
                                   not (fsf_active in astate) then begin
   col1:= afi.colorframe;
  end
  else begin
   col1:= afi.colorframeactive;
  end; 
  if col1 = cl_default then begin
   col1:= defaultframecolors.frame;
  end;
  canvas.drawframe(rect1,-afi.framewidth,col1,afi.hiddenedges);
  updateedgerect(rect1,afi.framewidth,afi.hiddenedges);
 end;
 if afi.leveli <> 0 then begin
  draw3dframe(canvas,rect1,afi.leveli,afi.framecolors,afi.hiddenedges);
 end;
 if afi.frameimage_list <> nil then begin
  imageoffs:= calcframestateoffs(astate,frameoffsetsty(afi.frameimage_offsets));
  if imageoffs >= 0 then begin
   if afi.hiddenedges * [edg_left,edg_top] = [] then begin
    afi.frameimage_list.paint(canvas,imageoffs,rect2.pos); //topleft
   end;
   if not (edg_left in afi.hiddenedges) then begin
    rect1:= rect2;
    if not (edg_top in afi.hiddenedges) then begin
     inc(rect1.y,afi.frameimage_list.height);
     dec(rect1.cy,afi.frameimage_list.height);
    end;
    rect1.cx:= afi.frameimage_list.width;
    if not (edg_bottom in afi.hiddenedges) then begin
     dec(rect1.cy,afi.frameimage_list.height);
    end;    
    afi.frameimage_list.paint(canvas,imageoffs+1,rect1,[al_stretchy]);
                                                          //left
   end;
   if afi.hiddenedges * [edg_bottom,edg_left] = [] then begin
    afi.frameimage_list.paint(canvas,imageoffs+2,rect2,[al_bottom]); 
                                                          //bottomleft
   end;
   if not (edg_bottom in afi.hiddenedges) then begin
    rect1:= rect2;
    if not (edg_left in afi.hiddenedges) then begin
     inc(rect1.x,afi.frameimage_list.width);
     dec(rect1.cx,afi.frameimage_list.width);
    end;
    rect1.y:= rect2.y + rect2.cy - afi.frameimage_list.height;
    rect1.cy:= afi.frameimage_list.width;
    if not (edg_right in afi.hiddenedges) then begin
     dec(rect1.cx,afi.frameimage_list.width);
    end;
    afi.frameimage_list.paint(canvas,imageoffs+3,rect1,[al_stretchx]);
                                                          //bottom
   end;
   if afi.hiddenedges * [edg_bottom,edg_right] = [] then begin
    afi.frameimage_list.paint(canvas,imageoffs+4,rect2,[al_bottom,al_right]); 
                                                          //bottomright
   end;
   if not (edg_right in afi.hiddenedges) then begin
    rect1:= rect2;
    if not (edg_bottom in afi.hiddenedges) then begin
     dec(rect1.cy,afi.frameimage_list.height);
    end;
    rect1.x:= rect2.x + rect2.cx - afi.frameimage_list.width;
    rect1.cx:= afi.frameimage_list.width;
    if not (edg_top in afi.hiddenedges) then begin
     inc(rect1.y,afi.frameimage_list.height);
     dec(rect1.cy,afi.frameimage_list.height);
    end;
    afi.frameimage_list.paint(canvas,imageoffs+5,rect1,[al_stretchy]);
                                                          //right
   end;
   if afi.hiddenedges * [edg_top,edg_right] = [] then begin
    afi.frameimage_list.paint(canvas,imageoffs+6,rect2,[al_right]);
                                                          //topright
   end;
   if not (edg_top in afi.hiddenedges) then begin
    rect1:= rect2;
    if not (edg_right in afi.hiddenedges) then begin
     dec(rect1.cx,afi.frameimage_list.width);
    end;
    rect1.cy:= afi.frameimage_list.height;
    if not (edg_left in afi.hiddenedges) then begin
     inc(rect1.x,afi.frameimage_list.width);
     dec(rect1.cx,afi.frameimage_list.width);
    end;
    afi.frameimage_list.paint(canvas,imageoffs+7,rect1,[al_stretchx]);
                                                         //top
   end;
  end;
 end;
end;

procedure tcustomframe.paintoverlay(const canvas: tcanvas; const arect: rectty);
begin
 drawframe(canvas,deflaterect(arect,fouterframe),fi,fintf.getframestateflags);
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

class function tcustomframe.calcpaintframe(const afi: baseframeinfoty): framety;
var
 int1: integer;
begin
 result:= nullframe;
 with result do begin
  int1:= abs(afi.levelo) + afi.framewidth + abs(afi.leveli);
  if not(edg_left in afi.hiddenedges) then begin
   left:= int1;
  end;
  if not(edg_top in afi.hiddenedges) then begin
   top:= int1;
  end;
  if not(edg_right in afi.hiddenedges) then begin
   right:= int1;
  end;
  if not(edg_bottom in afi.hiddenedges) then begin
   bottom:= int1;
  end;
  if afi.frameimage_list <> nil then begin
   if not (edg_left in afi.hiddenedges) then begin
    int1:= afi.frameimage_list.width + afi.frameimage_left;
    if int1 > left then begin
     left:= int1;
    end;
   end;
   if not (edg_right in afi.hiddenedges) then begin
    int1:= afi.frameimage_list.width + afi.frameimage_right;
    if int1 > right then begin
     right:= int1;
    end;
   end;
   if not (edg_top in afi.hiddenedges) then begin
    int1:= afi.frameimage_list.height + afi.frameimage_top;
    if int1 > top then begin
     top:= int1;
    end;
   end;
   if not (edg_bottom in afi.hiddenedges) then begin
    int1:= afi.frameimage_list.height + afi.frameimage_bottom;
    if int1 > bottom then begin
     bottom:= int1;
    end;
   end;
  end;
 end;
end;

procedure tcustomframe.calcrects;
begin
 fwidth:= calcpaintframe(fi);
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
 if not (csreading in fintf.getcomponentstate) and
         not (fs_nowidget in fstate) then begin
  po1:= subpoint(fpaintrect.pos,fpaintposbefore);
  fintf.scrollwidgets(po1);
 end;
 fpaintposbefore:= fpaintrect.pos;
 updateclientrect;
 include(fstate,fs_rectsvalid);
 fintf.clientrectchanged;
end;

procedure tcustomframe.internalupdatestate;
begin
 if not (csloading in fintf.getcomponentstate) then begin
  updatestate;
 end
 else begin
  exclude(fstate,fs_rectsvalid);
 end;
 exclude(fstate,fs_creating);
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

procedure tcustomframe.setlocalprops1(const avalue: framelocalprops1ty);
begin
 if flocalprops1 <> avalue then begin
  flocalprops1:= avalue;
  if ftemplate <> nil then begin
   settemplateinfo(ftemplate.template.fi);
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

procedure tcustomframe.setframei(const avalue: framety);
begin
 fi.innerframe:= avalue;
 internalupdatestate;
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

function tcustomframe.getimagelist: timagelist;
begin
 result:= fi.frameimage_list;
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

procedure tcustomframe.setframeimage_offset(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffset);
 if fi.frameimage_offsets.offset <> avalue then begin
  fi.frameimage_offsets.offset:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offset1(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffset1);
 if fi.frameimage_offsets.offset1 <> avalue then begin
  fi.frameimage_offsets.offset1:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetdisabled(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffsetdisabled);
 if fi.frameimage_offsets.disabled <> avalue then begin
  fi.frameimage_offsets.disabled:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetmouse(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffsetmouse);
 if fi.frameimage_offsets.mouse <> avalue then begin
  fi.frameimage_offsets.mouse:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetclicked(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffsetclicked);
 if fi.frameimage_offsets.clicked <> avalue then begin
  fi.frameimage_offsets.clicked:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetactive(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffsetactive);
 if fi.frameimage_offsets.active <> avalue then begin
  fi.frameimage_offsets.active:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetactivemouse(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffsetactivemouse);
 if fi.frameimage_offsets.activemouse <> avalue then begin
  fi.frameimage_offsets.activemouse:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeimage_offsetactiveclicked(const avalue: imagenrty);
begin
 include(flocalprops,frl_frameimageoffsetactiveclicked);
 if fi.frameimage_offsets.activeclicked <> avalue then begin
  fi.frameimage_offsets.activeclicked:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_list(const avalue: tfacelist);
begin
 include(flocalprops1,frl1_framefacelist);
 if fi.frameface_list <> avalue then begin
  fintf.getwidget.setlinkedvar(avalue,tmsecomponent(fi.frameface_list));
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offset(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffset);
 if fi.frameface_offsets.offset <> avalue then begin
  fi.frameface_offsets.offset:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offset1(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffset1);
 if fi.frameface_offsets.offset1 <> avalue then begin
  fi.frameface_offsets.offset1:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offsetdisabled(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffsetdisabled);
 if fi.frameface_offsets.disabled <> avalue then begin
  fi.frameface_offsets.disabled:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offsetmouse(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffsetmouse);
 if fi.frameface_offsets.mouse <> avalue then begin
  fi.frameface_offsets.mouse:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offsetclicked(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffsetclicked);
 if fi.frameface_offsets.clicked <> avalue then begin
  fi.frameface_offsets.clicked:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offsetactive(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffsetactive);
 if fi.frameface_offsets.active <> avalue then begin
  fi.frameface_offsets.active:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offsetactivemouse(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffsetactivemouse);
 if fi.frameface_offsets.activemouse <> avalue then begin
  fi.frameface_offsets.activemouse:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setframeface_offsetactiveclicked(const avalue: facenrty);
begin
 include(flocalprops1,frl1_framefaceoffsetactiveclicked);
 if fi.frameface_offsets.activeclicked <> avalue then begin
  fi.frameface_offsets.activeclicked:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomframe.setoptionsskin(const avalue: frameskinoptionsty);
begin
 include(flocalprops,frl_optionsskin);
 if fi.optionsskin <> avalue then begin
  fi.optionsskin:= avalue;
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

procedure tcustomframe.sethiddenedges(const avalue: edgesty);
begin
 include(flocalprops,frl_hiddenedges);
 if fi.hiddenedges <> avalue then begin
  fi.hiddenedges:= avalue;
  internalupdatestate;
//  fintf.invalidatewidget;
 end;
end;

procedure tcustomframe.settemplate(const avalue: tframecomp);
begin
 fintf.getwidget.setlinkedvar(avalue,tmsecomponent(ftemplate));
// if (avalue <> nil) and not (csloading in avalue.componentstate) then begin
 if (avalue <> nil) and not (csreading in avalue.componentstate) then begin
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
   levelo:= ainfo.ba.levelo;
  end;
  if not (frl_leveli in flocalprops) then begin
   leveli:= ainfo.ba.leveli;
  end;
  if not (frl_framewidth in flocalprops) then begin
   framewidth:= ainfo.ba.framewidth;
  end;
//  if not (frl_extraspace in flocalprops) then begin
//   extraspace:= ainfo.extraspace;
//  end;
  if not (frl_colorframe in flocalprops) then begin
   colorframe:= ainfo.ba.colorframe;
  end;
  if not (frl_colorframeactive in flocalprops) then begin
   colorframeactive:= ainfo.ba.colorframeactive;
  end;
  with framecolors do begin
   if not (frl_colordkshadow in flocalprops) then begin
    shadow.effectcolor:= ainfo.ba.framecolors.shadow.effectcolor;
   end;
   if not (frl_colorshadow in flocalprops) then begin
    shadow.color:= ainfo.ba.framecolors.shadow.color;
   end;
   if not (frl_colorlight in flocalprops) then begin
    light.color:= ainfo.ba.framecolors.light.color;
   end;
   if not (frl_colorhighlight in flocalprops) then begin
    light.effectcolor:= ainfo.ba.framecolors.light.effectcolor;
   end;
   if not (frl_colordkwidth in flocalprops) then begin
    shadow.effectwidth:= ainfo.ba.framecolors.shadow.effectwidth;
   end;
   if not (frl_colorhlwidth in flocalprops) then begin
    light.effectwidth:= ainfo.ba.framecolors.light.effectwidth;
   end;
  end;
  if not (frl_hiddenedges in flocalprops) then begin
   hiddenedges:= ainfo.ba.hiddenedges;
  end;
  if not (frl_fileft in flocalprops) then begin
   innerframe.left:= ainfo.ba.innerframe.left;
  end;
  if not (frl_fitop in flocalprops) then begin
   innerframe.top:= ainfo.ba.innerframe.top;
  end;
  if not (frl_firight in flocalprops) then begin
   innerframe.right:= ainfo.ba.innerframe.right;
  end;
  if not (frl_fibottom in flocalprops) then begin
   innerframe.bottom:= ainfo.ba.innerframe.bottom;
  end;

  if not (frl_frameimagelist in flocalprops) then begin
   fintf.getwidget.setlinkedvar(ainfo.ba.frameimage_list,
   tmsecomponent(frameimage_list));
  end;
  if not (frl_frameimageleft in flocalprops) then begin
   frameimage_left:= ainfo.ba.frameimage_left;
  end;
  if not (frl_frameimageright in flocalprops) then begin
   frameimage_right:= ainfo.ba.frameimage_right;
  end;
  if not (frl_frameimagetop in flocalprops) then begin
   frameimage_top:= ainfo.ba.frameimage_top;
  end;
  if not (frl_frameimagebottom in flocalprops) then begin
   frameimage_bottom:= ainfo.ba.frameimage_bottom;
  end;
  with frameimage_offsets do begin
   if not (frl_frameimageoffset in flocalprops) then begin
    offset:= ainfo.ba.frameimage_offsets.offset;
   end;
   if not (frl_frameimageoffsetdisabled in flocalprops) then begin
    disabled:= ainfo.ba.frameimage_offsets.disabled;
   end;
   if not (frl_frameimageoffsetmouse in flocalprops) then begin
    mouse:= ainfo.ba.frameimage_offsets.mouse;
   end;
   if not (frl_frameimageoffsetclicked in flocalprops) then begin
    clicked:= ainfo.ba.frameimage_offsets.clicked;
   end;
   if not (frl_frameimageoffsetactive in flocalprops) then begin
    active:= ainfo.ba.frameimage_offsets.active;
   end;
   if not (frl_frameimageoffsetactivemouse in flocalprops) then begin
    activemouse:= ainfo.ba.frameimage_offsets.activemouse;
   end;
   if not (frl_frameimageoffsetactiveclicked in flocalprops) then begin
    activeclicked:= ainfo.ba.frameimage_offsets.activeclicked;
   end;
  end;
  
  if not (frl1_framefacelist in flocalprops1) then begin
   fintf.getwidget.setlinkedvar(ainfo.ba.frameface_list,
   tmsecomponent(frameface_list));
  end;
  with frameface_offsets do begin
   if not (frl1_framefaceoffset in flocalprops1) then begin
    offset:= ainfo.ba.frameface_offsets.offset;
   end;
   if not (frl1_framefaceoffsetdisabled in flocalprops1) then begin
    disabled:= ainfo.ba.frameface_offsets.disabled;
   end;
   if not (frl1_framefaceoffsetmouse in flocalprops1) then begin
    mouse:= ainfo.ba.frameface_offsets.mouse;
   end;
   if not (frl1_framefaceoffsetclicked in flocalprops1) then begin
    clicked:= ainfo.ba.frameface_offsets.clicked;
   end;
   if not (frl1_framefaceoffsetactive in flocalprops1) then begin
    active:= ainfo.ba.frameface_offsets.active;
   end;
   if not (frl1_framefaceoffsetactivemouse in flocalprops1) then begin
    activemouse:= ainfo.ba.frameface_offsets.activemouse;
   end;
   if not (frl1_framefaceoffsetactiveclicked in flocalprops1) then begin
    activeclicked:= ainfo.ba.frameface_offsets.activeclicked;
   end;
  end;
  
  if not (frl_optionsskin in flocalprops) then begin
   optionsskin:= ainfo.ba.optionsskin;
  end;
  
  if not (frl_colorclient in flocalprops) then begin
   colorclient:= ainfo.ba.colorclient;
  end;
 end;
 internalupdatestate;
end;

procedure tcustomframe.getpaintframe(var frame: framety);
begin
 //dummy
end;

function tcustomframe.outerframedim: sizety;
begin
 checkstate;
 result.cx:= fouterframe.left + fouterframe.right;
 result.cy:= fouterframe.top + fouterframe.bottom;
end;

function tcustomframe.frameframedim: sizety;
begin
 checkstate;
 result.cx:= fouterframe.left + fwidth.left + fwidth.right + fouterframe.right;
 result.cy:= fouterframe.top + fwidth.top + fwidth.bottom + fouterframe.bottom;
end;

function tcustomframe.paintframedim: sizety;
begin
 checkstate;
 result.cx:= fpaintframe.left + fpaintframe.right;
 result.cy:= fpaintframe.top + fpaintframe.bottom;
end;

function tcustomframe.innerframedim: sizety;
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
   flocalprops1:= allframelocalprops1;
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
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
                                                 ord(fs_disabled),value);
 with fi do begin
  if (frameimage_list <> nil) and (frameimage_offsetdisabled <> 0) or
     (frameface_list <> nil) and (frameface_offsetdisabled <> 0) then begin
   fintf.getwidget.invalidatewidget;
  end;
 end; 
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

function tcustomframe.ishiddenedgesstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_hiddenedges in flocalprops);
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
 result:= (ftemplate = nil) and (fi.frameimage_list <> nil) or 
               (frl_frameimagelist in flocalprops);
end;

function tcustomframe.isframeimage_leftstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameimage_left <> 0) or 
               (frl_frameimageleft in flocalprops);
end;

function tcustomframe.isframeimage_rightstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameimage_right <> 0) or 
               (frl_frameimageright in flocalprops);
end;

function tcustomframe.isframeimage_topstored: boolean;
begin
 result:= (ftemplate = nil)  and (fi.frameimage_top <> 0) or 
               (frl_frameimagetop in flocalprops);
end;

function tcustomframe.isframeimage_bottomstored: boolean;
begin
 result:= (ftemplate = nil)  and (fi.frameimage_bottom <> 0) or
               (frl_frameimagebottom in flocalprops);
end;

function tcustomframe.isframeimage_offsetstored: boolean;
begin
 result:= (ftemplate = nil)  and (fi.frameimage_offsets.offset <> 0) or 
               (frl_frameimageoffset in flocalprops);
end;

function tcustomframe.isframeimage_offset1stored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameimage_offsets.offset1 <> 0) or 
               (frl_frameimageoffset1 in flocalprops);
end;

function tcustomframe.isframeimage_offsetdisabledstored: boolean;
begin
 result:= (ftemplate = nil)  and (fi.frameimage_offsets.disabled <> 0) or
               (frl_frameimageoffsetdisabled in flocalprops);
end;

function tcustomframe.isframeimage_offsetmousestored: boolean;
begin
 result:= (ftemplate = nil)  and (fi.frameimage_offsets.mouse <> 0) or
               (frl_frameimageoffsetmouse in flocalprops);
end;

function tcustomframe.isframeimage_offsetclickedstored: boolean;
begin
 result:= (ftemplate = nil)  and (fi.frameimage_offsets.clicked <> 0) or
               (frl_frameimageoffsetclicked in flocalprops);
end;

function tcustomframe.isframeimage_offsetactivestored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameimage_offsets.active <> 0) or 
               (frl_frameimageoffsetactive in flocalprops);
end;

function tcustomframe.isframeimage_offsetactivemousestored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameimage_offsets.activemouse <> 0) or
               (frl_frameimageoffsetactivemouse in flocalprops);
end;

function tcustomframe.isframeimage_offsetactiveclickedstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameimage_offsets.activeclicked <> 0) or
               (frl_frameimageoffsetactiveclicked in flocalprops);
end;

function tcustomframe.isframeface_liststored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_list <> nil) or
               (frl1_framefacelist in flocalprops1);
end;

function tcustomframe.isframeface_offsetstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.offset <> 0) or
               (frl1_framefaceoffset in flocalprops1);
end;

function tcustomframe.isframeface_offset1stored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.offset1 <> 0) or
               (frl1_framefaceoffset1 in flocalprops1);
end;

function tcustomframe.isframeface_offsetdisabledstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.disabled <> 0) or
               (frl1_framefaceoffsetdisabled in flocalprops1);
end;

function tcustomframe.isframeface_offsetmousestored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.mouse <> 0) or
               (frl1_framefaceoffsetmouse in flocalprops1);
end;

function tcustomframe.isframeface_offsetclickedstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.clicked <> 0) or 
               (frl1_framefaceoffsetclicked in flocalprops1);
end;

function tcustomframe.isframeface_offsetactivestored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.active <> 0) or
               (frl1_framefaceoffsetactive in flocalprops1);
end;

function tcustomframe.isframeface_offsetactivemousestored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.activemouse <> 0) or
               (frl1_framefaceoffsetactivemouse in flocalprops1);
end;

function tcustomframe.isframeface_offsetactiveclickedstored: boolean;
begin
 result:= (ftemplate = nil) and (fi.frameface_offsets.activeclicked <> 0) or
               (frl1_framefaceoffsetactiveclicked in flocalprops1);
end;

function tcustomframe.isoptionsskinstored: boolean;
begin
 result:= (ftemplate = nil) or (frl_optionsskin in flocalprops);
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

procedure tcustomframe.checkwidgetsize(var asize: sizety);
begin
 //dummy
end;

procedure tcustomframe.checkminscrollsize(var asize: sizety);
begin
 //dummy
end;

procedure tcustomframe.checkminclientsize(var asize: sizety);
begin
 checkstate;
 if asize.cx < fpaintrect.cx then begin
  asize.cx:= fpaintrect.cx;
 end;
 if asize.cy < fpaintrect.cy then begin
  asize.cy:= fpaintrect.cy;
 end;
end;

function tcustomframe.isoptional: boolean;
begin
 result:= not fintf.getstaticframe;
end;

{ tframetemplate }

constructor tframetemplate.create(const owner: tmsecomponent;
                      const onchange: notifyeventty);
begin
 initframeinfo(fi.ba);
 initframeinfo(fi.capt);
 inherited;
end;

destructor tframetemplate.destroy;
begin
 inherited;
 fi.capt.font.free;
end;

procedure tframetemplate.setcolorclient(const Value: colorty);
begin
 fi.ba.colorclient:= Value;
 changed;
end;

procedure tframetemplate.setcolorframe(const Value: colorty);
begin
 fi.ba.colorframe:= Value;
 changed;
end;

procedure tframetemplate.setcolorframeactive(const avalue: colorty);
begin
 fi.ba.colorframeactive:= avalue;
 changed;
end;

procedure tframetemplate.setcolordkshadow(const avalue: colorty);
begin
 fi.ba.framecolors.shadow.effectcolor:= avalue;
 changed;
end;

procedure tframetemplate.setcolorshadow(const avalue: colorty);
begin
 fi.ba.framecolors.shadow.color:= avalue;
 changed;
end;

procedure tframetemplate.setcolorlight(const avalue: colorty);
begin
 fi.ba.framecolors.light.color:= avalue;
 changed;
end;

procedure tframetemplate.setcolorhighlight(const avalue: colorty);
begin
 fi.ba.framecolors.light.effectcolor:= avalue;
 changed;
end;

procedure tframetemplate.setcolordkwidth(const avalue: integer);
begin
 fi.ba.framecolors.shadow.effectwidth:= avalue;
 changed;
end;

procedure tframetemplate.setcolorhlwidth(const avalue: integer);
begin
 fi.ba.framecolors.light.effectwidth:= avalue;
 changed;
end;

procedure tframetemplate.sethiddenedges(const avalue: edgesty);
begin
 fi.ba.hiddenedges:= avalue;
 changed;
end;

procedure tframetemplate.setframei_bottom(const Value: integer);
begin
 fi.ba.innerframe.bottom := Value;
 changed;
end;

procedure tframetemplate.setframei_left(const Value: integer);
begin
 fi.ba.innerframe.left := Value;
 changed;
end;

procedure tframetemplate.setframei_right(const Value: integer);
begin
 fi.ba.innerframe.right := Value;
 changed;
end;

procedure tframetemplate.setframei_top(const Value: integer);
begin
 fi.ba.innerframe.top := Value;
 changed;
end;

procedure tframetemplate.setframewidth(const Value: integer);
begin
 fi.ba.framewidth := Value;
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
 fi.ba.leveli := Value;
 changed;
end;

procedure tframetemplate.setlevelo(const Value: integer);
begin
 fi.ba.levelo := Value;
 changed;
end;

procedure tframetemplate.setframeimage_list(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fi.ba.frameimage_list));
 changed;
end;

function tframetemplate.getimagelist: timagelist;
begin
 result:= fi.ba.frameimage_list;
end;

procedure tframetemplate.setframeimage_left(const avalue: integer);
begin
 fi.ba.frameimage_left:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_right(const avalue: integer);
begin
 fi.ba.frameimage_right:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_top(const avalue: integer);
begin
 fi.ba.frameimage_top:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_bottom(const avalue: integer);
begin
 fi.ba.frameimage_bottom:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offset(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.offset:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offset1(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.offset1:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetdisabled(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.disabled:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetmouse(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.mouse:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetclicked(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.clicked:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetactive(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.active:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetactivemouse(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.activemouse:= avalue;
 changed;
end;

procedure tframetemplate.setframeimage_offsetactiveclicked(const avalue: imagenrty);
begin
 fi.ba.frameimage_offsets.activeclicked:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_list(const avalue: tfacelist);
begin
 setlinkedvar(avalue,tmsecomponent(fi.ba.frameface_list));
 changed;
end;

procedure tframetemplate.setframeface_offset(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.offset:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offset1(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.offset1:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offsetdisabled(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.disabled:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offsetmouse(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.mouse:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offsetclicked(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.clicked:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offsetactive(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.active:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offsetactivemouse(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.activemouse:= avalue;
 changed;
end;

procedure tframetemplate.setframeface_offsetactiveclicked(const avalue: facenrty);
begin
 fi.ba.frameface_offsets.activeclicked:= avalue;
 changed;
end;

procedure tframetemplate.setoptionsskin(const avalue: frameskinoptionsty);
begin
 fi.ba.optionsskin:= avalue;
 changed;
end;

function tframetemplate.getinfosize: integer;
begin
// result:= sizeof(fi.ba) - sizeof(fi.ba.frameface_list);
 result:= ptruint(@fi.ba.frameface_list) - ptruint(@fi.ba); //copied by move
end;

function tframetemplate.getinfoad: pointer;
begin
 result:= @fi.ba;
end;

procedure tframetemplate.doassignto(dest: tpersistent);
begin
 if dest is tcustomframe then begin
  with tcustomframe(dest) do begin
   if (cs_loadedproc in fowner.msecomponentstate) or 
                 (csloading in fintf.getcomponentstate) then begin
//    if cs_updateskinproc in fintf.getmsecomponentstate then begin
//     updatestate;
//    end
//    else begin
     exclude(fstate,fs_paintposinited);
//    end;
   end;
   settemplateinfo(self.fi);
  end;
//  with tcustomframe(dest) do begin
//   fi:= self.fi;
//   internalupdatestate;
//  end;
 end;
end;

procedure tframetemplate.paintbackground(const acanvas: tcanvas;
            arect: rectty; const astate: framestateflagsty = []);
var
 int1: integer;
 
begin
 inflaterect1(arect,tcustomframe.calcpaintframe(fi.ba));
 if fi.ba.colorclient <> cl_transparent then begin
  acanvas.fillrect(arect,fi.ba.colorclient);
 end;
 if fi.ba.frameface_list <> nil then begin
  int1:= calcframestateoffs(astate,frameoffsetsty(fi.ba.frameface_offsets));
  if (int1 >= 0) and (int1 < fi.ba.frameface_list.list.count) then begin
   fi.ba.frameface_list.list[int1].paint(acanvas,arect);
  end;
 end;
end;

procedure tframetemplate.paintoverlay(const acanvas: tcanvas;
                const arect: rectty; const astate: framestateflagsty = []);
begin
 tcustomframe.drawframe(acanvas,
     inflaterect(arect,tcustomframe.calcpaintframe(fi.ba)),fi.ba,astate);
end;

procedure tframetemplate.copyinfo(const source: tpersistenttemplate);
begin
 with tframetemplate(source) do begin
  setlinkedvar(frameimage_list,tmsecomponent(self.fi.ba.frameimage_list));
  setlinkedvar(frameface_list,tmsecomponent(fi.ba.frameface_list));
  if font <> nil then begin
   self.createfont;
   self.font.assign(font);
  end
  else begin
   freeandnil(fi.capt.font);
  end;
 end;
end;

function tframetemplate.paintframe: framety;
begin
 result:= tcustomframe.calcpaintframe(fi.ba);
end;

function tframetemplate.getfont: toptionalfont;
begin
 fowner.getoptionalobject(fi.capt.font,{$ifdef FPC}@{$endif}createfont);
 result:= fi.capt.font;
end;

procedure tframetemplate.setfont(const avalue: toptionalfont);
begin
 if fi.capt.font <> avalue then begin
  fowner.setoptionalobject(avalue,fi.capt.font,{$ifdef FPC}@{$endif}createfont);
 end;
end;

procedure tframetemplate.setcaptiondist(const avalue: integer);
begin
 fi.capt.captiondist:= avalue;
 changed;
end;

procedure tframetemplate.setcaptionoffset(const avalue: integer);
begin
 fi.capt.captionoffset:= avalue;
 changed;
end;

procedure tframetemplate.createfont;
begin
 if fi.capt.font = nil then begin
  fi.capt.font:= toptionalfont.create;
  fi.capt.font.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

procedure tframetemplate.fontchanged(const sender: tobject);
begin
 changed;
end;

function tframetemplate.isfontstored: boolean;
begin
 result:= fi.capt.font <> nil;
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
 fi.image:= tmaskedbitmap.create(bmk_rgb);
 fi.image.onchange:= {$ifdef fpc}@{$endif}imagechanged;
 fi.fade_pos:= trealarrayprop.create;
 fi.fade_color:= tfadecolorarrayprop.create;
 fi.fade_pos.link([fi.fade_color,fi.fade_pos]);
 fi.fade_opapos:= trealarrayprop.create;
 fi.fade_opacolor:= tfadeopacolorarrayprop.create;
 fi.fade_opapos.link([fi.fade_opacolor,fi.fade_opapos]);
 fi.fade_opacity:= cl_none;
 fi.fade_pos.onchange:= {$ifdef fpc}@{$endif}dochange;
 fi.fade_color.onchange:= {$ifdef fpc}@{$endif}dochange;
 fi.fade_opapos.onchange:= {$ifdef fpc}@{$endif}dochange;
 fi.fade_opacolor.onchange:= {$ifdef fpc}@{$endif}dochange;
end;

constructor tcustomface.create;
begin
 inherited;
// internalcreate;
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
  fintf.setlinkedvar(nil,tmsecomponent(ftemplate));
 end;
 inherited;
 fi.image.Free;
 fi.fade_pos.Free;
 fi.fade_color.free;
 fi.fade_opapos.Free;
 fi.fade_opacolor.free;
 falphabuffer.Free;
end;

procedure tcustomface.change;
begin
 fintf.invalidate;
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
 end
 else begin
  if sender = fi.fade_opapos then begin
   with trealarrayprop1(fi.fade_opapos) do begin
    if high(fitems) >= 0 then begin
     sortarray(trealarrayprop1(fi.fade_opapos).fitems,ar1);
     fitems[0]:= 0;
     if high(fitems) > 0 then begin
      fitems[high(fitems)]:= 1;
     end;
     fi.fade_opacolor.order(ar1);
    end;
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
 if not (csloading in fintf.getcomponentstate) then begin
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
  if not (csdesigning in fintf.getcomponentstate) then begin
   flocalprops:= allfacelocalprops;
   with tcustomface(source) do begin
    self.fade_direction:= fade_direction;
    self.fade_color:= fade_color;
    self.fade_pos:= fade_pos;
    self.fade_opacolor:= fade_opacolor;
    self.fade_opapos:= fade_opapos;
    self.fade_opacity:= fade_opacity;
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

var
 rect1: rectty;

 procedure createalphabuffer(const amasked: boolean);
 begin
  if falphabuffer = nil then begin
   falphabuffer:= tmaskedbitmap.create(bmk_rgb);
  end;
  if amasked then begin
   falphabuffer.options:= [bmo_masked,bmo_colormask];
  end;
  falphabuffer.size:= rect1.size;
  falphabufferdest:= rect1.pos;
  falphabuffer.canvas.copyarea(canvas,rect1,nullpoint);
 end;

var
 pixelscale: real;
 vert: boolean;
 startpix,pixcount: integer;
 
 procedure calcfade(const fadepos: trealarrayprop; 
                    const fadecolor: tcolorarrayprop; const bmp: tbitmap);
 var
  posar: realarty;
  rgbs: array of rgbtriplety;
  int1,int2: integer;
  po1: prgbtriplety;
  pixelstep: real;
  pixinc: integer;
  curpix,nextpix: integer;
  redsum,greensum,bluesum,lengthsum: real;
  curnode,nextnode: integer;
  rea1,rea2: real;
  col1,col2: prgbtriplety;
  
 begin
  posar:= trealarrayprop1(fadepos).fitems;
  with tfadecolorarrayprop(fadecolor) do begin
   setlength(rgbs,length(fitems));
   for int1:= 0 to high(rgbs) do begin
    rgbs[int1]:= colortorgb(fintf.translatecolor(fitems[int1]));
   end;
  end;
  if high(rgbs) > 0 then begin
   po1:= bmp.scanline[0];
   pixelstep:= 1/pixelscale;
   pixinc:= sizeof(rgbtriplety);
   if fi.fade_direction in [gd_up,gd_left] then begin //revert
    if fi.fade_direction = gd_left then begin
     startpix:= rect.x+rect.cx-rect1.x-rect1.cx;
    end
    else begin
     startpix:= rect.y+rect.cy-rect1.y-rect1.cy;
    end;
    inc(po1,pixcount-1);
    pixinc:= -pixinc;
   end;
   curnode:= 0;
   int1:= 0;
   while int1 < pixcount do begin
    rea1:= (int1+startpix)*pixelstep + 0.000001;
    if int1 = 0 then begin
     while posar[curnode] < rea1 do begin
      inc(curnode);
     end;
     dec(curnode);
    end;
    nextnode:= curnode;
    rea1:= rea1 + pixelstep;
    while (posar[nextnode] < rea1) and (nextnode < high(posar)) do begin
     inc(nextnode);
    end;
    if nextnode > curnode+1 then begin //calc average
     redsum:= 0;
     greensum:= 0;
     bluesum:= 0;
     lengthsum:= 0;
     for int2:= curnode to nextnode - 2 do begin //todo: optimize
      rea1:= posar[int2+1] - posar[int2];
      redsum:= redsum + (rgbs[int2].red+rgbs[int2+1].red)*rea1;
      greensum:= greensum + (rgbs[int2].green+rgbs[int2+1].green)*rea1;
      bluesum:= bluesum + (rgbs[int2].blue+rgbs[int2+1].blue)*rea1;
      lengthsum:= lengthsum + rea1;
     end;
     if lengthsum > 0 then begin
      rea1:= 1/(2*lengthsum);
      with po1^ do begin
       red:= round(redsum*rea1);
       green:= round(greensum*rea1);
       blue:= round(bluesum*rea1);
       res:= 0;
      end;
     end
     else begin
      po1^:= rgbs[curnode];
     end;
     dec(nextnode);
    end
    else begin
     nextpix:= trunc(posar[nextnode]*pixelscale)-startpix;
     if int1 = nextpix then begin
      po1^:= rgbs[curnode];
     end
     else begin
      curpix:= trunc(posar[curnode]*pixelscale)-startpix;
      if nextpix = curpix then begin
       rea1:= 1;
      end
      else begin
       rea1:= 1/(nextpix-curpix);
      end;
      if nextpix > pixcount then begin
       nextpix:= pixcount;
      end;
      col1:= @rgbs[curnode];
      col2:= @rgbs[nextnode];
      for int2:= int1-curpix to nextpix-curpix-1 do begin
       rea2:= rea1*int2;
       with po1^ do begin
        res:= 0;
        red:= col1^.red + 
                      round((col2^.red-col1^.red)*rea2);
        green:= col1^.green + 
                      round((col2^.green-col1^.green)*rea2);
        blue:= col1^.blue + 
                      round((col2^.blue-col1^.blue)*rea2);
       end;
       inc(pchar(po1),pixinc);
      end;
      dec(pchar(po1),pixinc);
      int1:= nextpix-1;
     end;         
    end;
    curnode:= nextnode;
    inc(int1);
    inc(pchar(po1),pixinc);
   end;
  end
  else begin //count = 1
   if vert then begin
    bmp.canvas.drawline(nullpoint,makepoint(0,rect1.cy-1),fadecolor[0]);
   end
   else begin
    bmp.canvas.drawline(nullpoint,makepoint(rect1.cx-1,0),fadecolor[0]);
   end;
  end;
 end; //calcfade

var
 bmp: tmaskedbitmap;

 procedure paintimage;
 begin
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

begin
 if intersectrect(rect,canvas.clipbox,rect1) then begin
  if fao_fadeoverlay in options then begin
   paintimage;
  end;
  if fi.fade_color.count > 0 then begin
   if (fi.fade_color.count > 1) or 
     ((fi.fade_opacolor.count > 0) or (fi.fade_opacity <> cl_none)) and 
                               (fi.options * faceoptionsmask = []) then begin
    case fi.fade_direction of
     gd_up,gd_down: begin
      pixelscale:= rect.cy;
      vert:= true;
      startpix:= rect1.y-rect.y;
      pixcount:= rect1.cy;
     end
     else begin //gd_right,gd_left
      pixelscale:= rect.cx;
      vert:= false;
      startpix:= rect1.x-rect.x;
      pixcount:= rect1.cx;
     end;
    end;
    bmp:= tmaskedbitmap.create(bmk_rgb);
    if vert then begin
     bmp.size:= makesize(1,rect1.cy);
    end
    else begin
     bmp.size:= makesize(rect1.cx,1);
    end;
    calcfade(fi.fade_pos,fi.fade_color,bmp);
    if fi.options * faceoptionsmask = [] then begin
     if fi.fade_opapos.count > 0 then begin
      bmp.colormask:= true;
      calcfade(fi.fade_opapos,fi.fade_opacolor,bmp.mask);
     end
     else begin
      bmp.opacity:= fi.fade_opacity;
     end;
     bmp.paint(canvas,rect1,[al_stretchx,al_stretchy]);
    end
    else begin
     createalphabuffer(true);
     bmp.paint(falphabuffer.mask.canvas,makerect(nullpoint,rect1.size),
                     makerect(nullpoint,bmp.size),[al_stretchx,al_stretchy]);
    end;
    bmp.Free;
   end
   else begin //fade_color.count = 1
    if fi.options * faceoptionsmask <> [] then begin
     createalphabuffer(false);
     falphabuffer.opacity:=
       colorty(colortorgb(tfadecolorarrayprop1(fi.fade_color).fitems[0]));
//     falphabuffer.opacity:=
//      (longword(colortorgb(tfadecolorarrayprop1(fi.fade_color).fitems[0])) xor
//                $ffffffff) and $00ffffff;
    end
    else begin
     canvas.fillrect(rect1,tfadecolorarrayprop1(fi.fade_color).fitems[0]);
    end;
   end;
  end
  else begin //fade_color.count = 0
   if fi.options * faceoptionsmask <> [] then begin
    createalphabuffer(false);
    falphabuffer.opacity:= colorty(colortorgb(fi.fade_opacity));
//    falphabuffer.opacity:=
//     (longword(colortorgb(fi.fade_opacity)) xor $ffffffff) and $00ffffff;
   end;
  end;
  if not (fao_fadeoverlay in options) then begin
   paintimage;
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
   fintf.widgetregioninvalid;
  end;
  change;
 end;
end;

procedure tcustomface.setfade_color(const Value: tfadecolorarrayprop);
begin
 include(flocalprops,fal_facolor);
 fi.fade_color.assign(Value);
end;

procedure tcustomface.setfade_pos(const Value: trealarrayprop);
begin
 include(flocalprops,fal_fapos);
 fi.fade_pos.assign(Value);
end;

procedure tcustomface.setfade_opacolor(const Value: tfadeopacolorarrayprop);
begin
 include(flocalprops,fal_faopacolor);
 fi.fade_opacolor.assign(Value);
end;

procedure tcustomface.setfade_opapos(const Value: trealarrayprop);
begin
 include(flocalprops,fal_faopapos);
 fi.fade_opapos.assign(Value);
end;

procedure tcustomface.setfade_direction(const Value: graphicdirectionty);
begin
 include(flocalprops,fal_fadirection);
 if fi.fade_direction <> value then begin
  fi.fade_direction:= Value;
  change;
 end;
end;

procedure tcustomface.setfade_opacity(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 include(flocalprops,fal_faopacity);
 if fi.fade_opacity <> avalue then begin
  fi.fade_opacity:= avalue;
  change;
 end;
end;

procedure tcustomface.setframeimage_list(const avalue: timagelist);
begin
 include(flocalprops,fal_frameimagelist);
 if fi.frameimage_list <> avalue then begin
  fintf.setlinkedvar(avalue,tmsecomponent(fi.frameimage_list));
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
 fintf.setlinkedvar(avalue,tmsecomponent(ftemplate));
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
 if not (fal_faopacolor in flocalprops) then begin
  fade_opacolor:= ainfo.fade_opacolor;
 end;
 if not (fal_faopapos in flocalprops) then begin
  fade_opapos:= ainfo.fade_opapos;
 end;
 if not (fal_image in flocalprops) then begin
  image:= ainfo.image;
 end;
 if not (fal_fadirection in flocalprops) then begin
  fade_direction:= ainfo.fade_direction;
 end;
 if not (fal_faopacity in flocalprops) then begin
  fade_opacity:= ainfo.fade_opacity;
 end;
 if not (fal_frameimagelist in flocalprops) then begin
  fintf.setlinkedvar(ainfo.frameimage_list,
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

procedure tcustomface.setlocalprops(avalue: facelocalpropsty);
begin
 if flocalprops <> avalue then begin
  if fal_fatransparency in avalue then begin
   include(avalue,fal_faopacity);
  end;
  flocalprops:= avalue - deprecatedfacelocalprops;
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

function tcustomface.isfaopacolorstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_faopacolor in flocalprops);
end;

function tcustomface.isfaopaposstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_faopapos in flocalprops);
end;

function tcustomface.isfadirectionstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_fadirection in flocalprops);
end;

function tcustomface.isfaopacitystored: boolean;
begin
 result:= (ftemplate = nil) or (fal_faopacity in flocalprops);
end;

function tcustomface.isframeimage_liststored: boolean;
begin
 result:= (ftemplate = nil) or (fal_frameimagelist in flocalprops);
end;

function tcustomface.isframeimage_offsetstored: boolean;
begin
 result:= (ftemplate = nil) or (fal_frameimageoffset in flocalprops);
end;

procedure tcustomface.readtransparency(reader: treader);
begin
 fade_opacity:= transparencytoopacity(reader.readinteger);
end;

procedure tcustomface.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('fade_transparency',@readtransparency,nil,false);
end;

{ tfacetemplate }

procedure tfacetemplate.internalcreate;
begin
 fi.image:= tmaskedbitmap.create(bmk_rgb);
 fi.fade_pos:= trealarrayprop.Create;
 fi.fade_color:= tfadecolorarrayprop.Create;
 fi.fade_pos.link([fi.fade_color,fi.fade_pos]);
 fi.fade_opapos:= trealarrayprop.Create;
 fi.fade_opacolor:= tfadeopacolorarrayprop.Create;
 fi.fade_opapos.link([fi.fade_opacolor,fi.fade_opapos]);
 fi.fade_opacity:= cl_none;
 fi.image.onchange:= {$ifdef FPC}@{$endif}doimagechange;
 fi.fade_pos.onchange:= {$ifdef FPC}@{$endif}dochange;
 fi.fade_color.onchange:= {$ifdef FPC}@{$endif}dochange;
 fi.fade_opapos.onchange:= {$ifdef FPC}@{$endif}dochange;
 fi.fade_opacolor.onchange:= {$ifdef FPC}@{$endif}dochange;
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
 fi.fade_opapos.Free;
 fi.fade_opacolor.Free;
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

procedure tfacetemplate.setfade_color(const Value: tfadecolorarrayprop);
begin
 fi.fade_color.Assign(Value);
end;

procedure tfacetemplate.setfade_pos(const Value: trealarrayprop);
begin
 fi.fade_pos.Assign(Value);
end;

procedure tfacetemplate.setfade_opacolor(const Value: tfadeopacolorarrayprop);
begin
 fi.fade_opacolor.Assign(Value);
end;

procedure tfacetemplate.setfade_opapos(const Value: trealarrayprop);
begin
 fi.fade_opapos.Assign(Value);
end;

procedure tfacetemplate.setfade_opacity(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 fi.fade_opacity:= avalue;
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

procedure tfacetemplate.readtransparency(reader: treader);
begin
 fade_opacity:= transparencytoopacity(reader.readinteger);
end;

procedure tfacetemplate.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('fade_transparency',@readtransparency,nil,false);
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

{ tfacearrayprop }

constructor tfacearrayprop.create(const aintf: iface);
begin
 fintf:= aintf;
end;

function tfacearrayprop.getitems(const index: integer): tface;
begin
 result:= tface(inherited items[index]);
end;

procedure tfacearrayprop.createitem(const index: integer;
               var item: tpersistent);
begin
 item:= tface.create(fintf);
end;

class function tfacearrayprop.getitemclasstype: persistentclassty;
begin
 result:= tface;
end;

{ tfacelist }

constructor tfacelist.create(aowner: tcomponent);
begin
 flist:= tfacearrayprop.create(iface(self));
 inherited;
end;

destructor tfacelist.destroy;
begin
 inherited;
 flist.free;
end;

procedure tfacelist.setlist(const avalue: tfacearrayprop);
begin
 flist.assign(avalue);
end;

procedure tfacelist.invalidate;
begin
end;

function tfacelist.translatecolor(const acolor: colorty): colorty;
begin
 result:= acolor;
end;

function tfacelist.getclientrect: rectty;
begin
 result:= nullrect;
end;

function tfacelist.getcomponentstate: tcomponentstate;
begin
 result:= componentstate;
end;

procedure tfacelist.widgetregioninvalid;
begin
 //dummy
end;

procedure tfacelist.objectevent(const sender: tobject;
               const event: objecteventty);
var
 int1: integer;
 fa1: tcustomface;
begin
 inherited;
 if (event = oe_changed) and (sender is tfacecomp) then begin
  for int1:= 0 to list.count do begin
   fa1:= tcustomface(flist.fitems[int1]);
   if fa1.template = sender then begin
    fa1.checktemplate(sender);
    break;
   end;
  end;
 end;
end;

{ twidget }

constructor twidget.create(aowner: tcomponent);
begin
 fnoinvalidate:= 1;
 fwidgetstate:= defaultwidgetstates;
 foptionsskin:= defaultoptionsskin;
 fanchors:= defaultanchors;
 foptionswidget:= defaultoptionswidget;
 foptionswidget1:= defaultoptionswidget1;
 fwidgetrect.cx:= defaultwidgetwidth;
 fwidgetrect.cy:= defaultwidgetheight;
 fcolor:= defaultwidgetcolor;
 inherited;
end;

constructor twidget.create(const aowner: tcomponent; 
             const aparentwidget: twidget; const aiswidget: boolean = true);
begin
 create(aowner);
 setlockedparentwidget(aparentwidget);
 if not aiswidget then begin
  exclude(fwidgetstate,ws_iswidget);
 end;
end;

constructor twidget.createandinit(const aowner: tcomponent; 
                      const aparentwidget: twidget);
begin
 create(aowner,aparentwidget);
 initnewcomponent(1);
 initnewwidget(1);
end;

procedure twidget.afterconstruction;
begin
 inherited;
 fnoinvalidate:= 0;
end;

destructor twidget.destroy;
var
 widget1: twidget;
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
      setlength(self.fwidgets,high(self.fwidgets));
     end;
    end;
   end;
  end
  else begin
   while length(fwidgets) > 0 do begin
    widget1:= fwidgets[high(fwidgets)];
    if not (ow_nohidewidgets in foptionswidget) then begin
     widget1.visible:= false;
    end;    
    widget1.parentwidget:= nil;
   end;
  end;
  fwidgets:= nil;
 end;
 hide;
 if fparentwidget <> nil then begin
  clearparentwidget;
 end;
 inherited;
 fwindow.Free;
 ffont.free;
 ffontempty.free;
 fframe.free;
 fface.free;
// inherited;
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

procedure twidget.createfontempty;
begin
 if ffontempty = nil then begin
  internalcreatefontempty;
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
 size1: sizety;
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
   size1.cy:= 0;
   for int1:= 0 to high(awidgets) do begin
    with awidgets[int1] do begin
     bounds_x:= ar1[int1] + int4;
     if anchors * [an_left,an_right] = [an_left,an_right] then begin
      int3:= bounds_cx;      
      size1.cx:= bounds_cx - int2;
      if fframe <> nil then begin
       fframe.checkwidgetsize(size1);
      end;
      bounds_cx:= size1.cx;
      int3:= bounds_cx - int3; //delta
      int2:= int2 + int3;
      int4:= int4 + int3;
     end;
    end;
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
 size1: sizety;
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
   size1.cx:= 0;
   for int1:= 0 to high(awidgets) do begin
    with awidgets[int1] do begin
     bounds_y:= ar1[int1] + int4;
     if anchors * [an_top,an_bottom] = [an_top,an_bottom] then begin
      int3:= bounds_cy;
      size1.cy:= bounds_cy - int2;
      if fframe <> nil then begin
       fframe.checkwidgetsize(size1);
      end;
      bounds_cy:= size1.cy;
      int3:= bounds_cy - int3; //delta
      int2:= int2 + int3;
      int4:= int4 + int3;
     end;
    end;
   end;
  end;
 end;
end;

function twidget.getwidgetrects(const awidgets: array of twidget): rectarty;
var
 int1: integer;
begin
 setlength(result,length(awidgets));
 for int1:= 0 to high(result) do begin
  with awidgets[int1] do begin
   result[int1]:= widgetrect;
   if parentwidget <> self then begin
    translatewidgetpoint1(result[int1].pos,parentwidget,self);
   end;
  end;
 end;
end;

procedure twidget.setwidgetrects(const awidgets: array of twidget;
                                             const arects: rectarty);
var
 int1: integer;
 rect1: rectty;
begin
 for int1:= 0 to high(awidgets) do begin
  with awidgets[int1] do begin
   rect1:= arects[int1];
   if parentwidget <> self then begin
    translatewidgetpoint1(rect1.pos,self,parentwidget);
   end;
   widgetrect:= rect1;
  end;
 end;
end;

function twidget.alignx(const mode: widgetalignmodety;
            const awidgets: array of twidget;
            const glue: widgetalignmodety = wam_none;
                        const margin: integer = 0): integer;

 function getrefpoint(const awidget: twidget): integer;
 begin
  with awidget do begin
   updateroot;
   case mode of
    wam_start: begin
     result:= frootpos.x + framepos.x;
     if fframe <> nil then begin
      with fframe do begin
       checkstate();
       result:= result + fwidth.left;
      end;
     end;
    end;
    wam_center: begin
     result:= frootpos.x + framepos.x + framesize.cx div 2;
    end;
    else begin //wam_end
     result:= frootpos.x + framepos.x + awidget.framesize.cx;
     if fframe <> nil then begin
      with fframe do begin
       checkstate();
       result:= result - fwidth.right;
      end;
     end;
    end;
   end;
  end;
 end; //getrefpoint

 procedure doshift(const awidget: twidget; const amode: widgetalignmodety;
                         const ashift: integer; var arect: rectty);
 begin
  with awidget do begin
   if (amode = wam_start) and (an_right in anchors) then begin
    arect.cx:= arect.cx - ashift;
   end;
   if (amode = wam_end) and (an_left in anchors) then begin
    arect.cx:= arect.cx + ashift;
   end
   else begin
    arect.x:= arect.x + ashift;
   end;
  end;
 end; //doshift

var
 ref,shift,int1,int2,int3: integer;
 ar1: rectarty;

begin
 result:= 0;
 if (high(awidgets) >= 0) then begin
  beginupdate();
  try
   ref:= getrefpoint(awidgets[0]);
   with awidgets[0] do begin
    if fparentwidget <> nil then begin
     result:= ref - fparentwidget.frootpos.x
    end
    else begin
     result:= ref;
    end;
   end;
   ar1:= getwidgetrects(awidgets);
   if (mode <> wam_none) and (high(awidgets) > 0) then begin
    for int1:= 1 to high(awidgets) do begin
     int3:= ref - getrefpoint(awidgets[int1]);
     doshift(awidgets[int1],mode,int3,ar1[int1]);
    end;
   end;
   if (glue <> wam_none) then begin
    shift:= 0;
    case glue of
     wam_start: begin
      int2:= bigint;
      for int1:= 0 to high(awidgets) do begin
       int3:= ar1[int1].x;
       if int3 < int2 then begin
        int2:= int3;
       end;
      end;
      shift:= margin+clientwidgetpos.x-int2;
     end;
     wam_end: begin
      int2:= -bigint;
      for int1:= 0 to high(awidgets) do begin
       with ar1[int1] do begin
        int3:= x+cx;
       end;
       if int3 > int2 then begin
        int2:= int3;
       end;
      end;
      shift:= clientwidgetpos.x+clientwidth - margin - int2;
     end;
     else begin //wam_center
      if length(awidgets) > 0 then begin
       with awidgets[0] do begin
        shift:= margin + ar1[0].x + framepos.x + framesize.cx div 2;
       end;
       shift:= clientwidgetpos.x + clientwidth div 2 - shift;
      end;
     end;
    end;
    if shift <> 0 then begin
     result:= result+shift;
     for int1:= 0 to high(awidgets) do begin
      doshift(awidgets[int1],glue,shift,ar1[int1]);
     end;
    end;
   end;
   setwidgetrects(awidgets,ar1);
  finally
   endupdate();
  end;
 end;
end;

function twidget.aligny(const mode: widgetalignmodety;
            const awidgets: array of twidget;
            const glue: widgetalignmodety = wam_none;
                        const margin: integer = 0): integer;

 function getrefpoint(const awidget: twidget): integer;
 begin
  with awidget do begin
   updateroot;
   case mode of
    wam_start: begin
     result:= frootpos.y + framepos.y;
     if fframe <> nil then begin
      with fframe do begin
       checkstate();
       result:= result + fwidth.top;
      end;
     end;
    end;
    wam_center: begin
     result:= frootpos.y + framepos.y + framesize.cy div 2;
    end;
    else begin //wam_end
     result:= frootpos.y + framepos.y + awidget.framesize.cy;
     if fframe <> nil then begin
      with fframe do begin
       checkstate();
       result:= result - fwidth.bottom;
      end;
     end;
    end;
   end;
  end;
 end; //getrefpoint

 procedure doshift(const awidget: twidget; const amode: widgetalignmodety;
                         const ashift: integer; var arect: rectty);
 begin
  with awidget do begin
   if (amode = wam_start) and (an_bottom in anchors) then begin
    arect.cy:= arect.cy - ashift;
   end;
   if (amode = wam_end) and (an_top in anchors) then begin
    arect.cy:= arect.cy + ashift;
   end
   else begin
    arect.y:= arect.y + ashift;
   end;
  end;
 end; //doshift

var
 ref,shift,int1,int2,int3: integer;
 ar1: rectarty;

begin
 result:= 0;
 if (high(awidgets) >= 0) then begin
  beginupdate();
  try
   ref:= getrefpoint(awidgets[0]);
   with awidgets[0] do begin
    if fparentwidget <> nil then begin
     result:= ref - fparentwidget.frootpos.y
    end
    else begin
     result:= ref;
    end;
   end;
   ar1:= getwidgetrects(awidgets);
   if (mode <> wam_none) and (high(awidgets) > 0) then begin
    for int1:= 1 to high(awidgets) do begin
     int3:= ref - getrefpoint(awidgets[int1]);
     doshift(awidgets[int1],mode,int3,ar1[int1]);
    end;
   end;
   if (glue <> wam_none) then begin
    shift:= 0;
    case glue of
     wam_start: begin
      int2:= bigint;
      for int1:= 0 to high(awidgets) do begin
       int3:= ar1[int1].y;
       if int3 < int2 then begin
        int2:= int3;
       end;
      end;
      shift:= margin+clientwidgetpos.y-int2;
     end;
     wam_end: begin
      int2:= -bigint;
      for int1:= 0 to high(awidgets) do begin
       with ar1[int1] do begin
        int3:= y+cy;
       end;
       if int3 > int2 then begin
        int2:= int3;
       end;
      end;
      shift:= clientwidgetpos.y+clientheight - margin - int2;
     end;
     else begin //wam_center
      if length(awidgets) > 0 then begin
       with awidgets[0] do begin
        shift:= margin + ar1[0].y + framepos.y + framesize.cy div 2;
       end;
       shift:= clientwidgetpos.y + clientheight div 2 - shift;
      end;
     end;
    end;
    if shift <> 0 then begin
     result:= result+shift;
     for int1:= 0 to high(awidgets) do begin
      doshift(awidgets[int1],glue,shift,ar1[int1]);
     end;
    end;
   end;
   setwidgetrects(awidgets,ar1);
  finally
   endupdate();
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
 child.rootchanged(true);
// child.updateopaque(true); //for cl_parent
 if not isloading then begin
  child.updateopaque(true,false); //for cl_parent
  child.ftaborder:= high(fwidgets);
  sortzorder;
  updatetaborder(child);
  if child.visible and not child.isloading then begin
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
 child.rootchanged(true);
 if not isloading then begin
  updatetaborder(nil);
  if child.isvisible then begin
   widgetregionchanged(child);
  end;
 end;
end;

procedure twidget.setcolor(const avalue: colorty);
begin
 if fcolor <> avalue then begin
  fcolor:= avalue;
  if not (csloading in componentstate) then begin
   colorchanged;
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
 updatingbefore: boolean;
begin
 if fparentwidget <> value then begin
  updatingbefore:= ws1_parentupdating in fwidgetstate1;
  include(fwidgetstate1,ws1_parentupdating);
  try
   if entered and (fwindow <> nil) then begin
    window.nofocus;
   end;
   if (value <> nil) then begin
    if value = self then begin
     raise exception.create('Recursive parent.');
    end;
    if (fwindow <> nil) and ownswindow1 then begin
     newpos:= translatewidgetpoint(fwidgetrect.pos,nil,value);
     fwindow.fownerwidget:= nil;
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
    clearparentwidget;
   end;
   if fparentwidget <> nil then begin
    exit;                   //interrupt
   end;
   fparentwidget:= Value;
   fwidgetrect.pos:= newpos;
   if fparentwidget <> nil then begin
    fparentwidget.registerchildwidget(self);
    if not (csloading in componentstate) and 
                        not (ws_loadlock in fwidgetstate) then begin
     fparentclientsize:= fparentwidget.minclientsize;
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
  finally
   if not updatingbefore then begin
    exclude(fwidgetstate1,ws1_parentupdating);
   end;
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
  fminscrollsize:= calcminscrollsize;
  fminclientsize:= fminscrollsize;
  if fframe <> nil then begin
   fframe.checkminclientsize(fminclientsize);
  end
  else begin
   fminclientsize:= fwidgetrect.size;
  end;
  include(fwidgetstate,ws_minclientsizevalid);
 end;
 result:= fminclientsize;
end;

function twidget.minscrollsize: sizety;
begin
 if not (ws_minclientsizevalid in fwidgetstate) then begin
  minclientsize;
 end;
 result:= fminscrollsize;
end;

function twidget.getminshrinksize: sizety;
begin
 result:= fminsize;
end;

procedure twidget.internalsetwidgetrect(value: rectty; 
                                                  const windowevent: boolean);

 procedure checkwidgetregionchanged(var achanged: boolean);
 begin
  if achanged then begin
   achanged:= false;
   if (fparentwidget <> nil) then begin
    fparentwidget.widgetregionchanged(self); //new position
   end;
  end;
 end; //checkwidgetregionchanged

 procedure movewidgetregion(const awidget: twidget; const dist: pointty);
 var
  int1: integer;
 begin
  with awidget do begin
   if (ws1_widgetregionvalid in fwidgetstate1) then begin
    regmove(fwidgetregion,dist);
   end;
   for int1:= 0 to high(fwidgets) do begin
    movewidgetregion(fwidgets[int1],dist);
   end;
  end; 
 end; //movewidgetregion

var
 bo1,bo2,poscha,sizecha: boolean;
 int1,int2,int3: integer;
 setcountbefore: integer;
 size1,size2: sizety;
 ar1: widgetarty;
 ar2,ar3: integerarty;
 autosizecha: boolean;
 autosi: sizety;
 simi,sima: sizety;
begin
 autosizecha:= false;
 if ([ow1_autowidth,ow1_autoheight]*foptionswidget1 <> []) and 
                                 not (csloading in componentstate) then begin
  if not windowevent then begin
   checkwidgetsize(value.size);
  end;
  size1:= value.size;
  if fframe <> nil then begin
   subsize1(size1,fframe.paintframedim);
  end;
  getautopaintsize(size1);
  if fframe <> nil then begin
   addsize1(size1,fframe.paintframedim);
  end;
  subsize1(size1,value.size);
  size2:= value.size;
  if not (ow1_autowidth in foptionswidget1) then begin
   size1.cx:= 0;
  end;
  if not (ow1_autoheight in foptionswidget1) then begin
   size1.cy:= 0;
  end;
  autosizecha:= (size1.cx <> 0) or (size1.cy <> 0);
  inc(value.cx,size1.cx);
  if (ow1_autosizeanright in foptionswidget1) and 
                                        not (an_right in fanchors) then begin
   dec(value.x,size1.cx);
  end;
  inc(value.cy,size1.cy);
  if (ow1_autosizeanbottom in foptionswidget1) and 
                                        not (an_bottom in fanchors) then begin
   dec(value.y,size1.cy);
  end;
  autosi:= value.size;
  if not windowevent then begin
   checkwidgetsize(value.size);
  end;
  if (an_right in fanchors) and not 
                  (ow1_noautosizeanright in foptionswidget1) then begin
   dec(value.x,value.cx-size2.cx);
  end;
  if (an_bottom in fanchors) and not 
                  (ow1_noautosizeanbottom in foptionswidget1) then begin
   dec(value.y,value.cy-size2.cy);
  end;
  if ownswindow and windowevent and not (csloading in componentstate) then begin
   simi:= fminsize;
   sima:= fmaxsize;
   if ow1_autowidth in foptionswidget1 then begin
    simi.cx:= value.cx;
    sima.cx:= value.cx;
   end;
   if ow1_autoheight in foptionswidget1 then begin
    simi.cy:= value.cy;
    sima.cy:= value.cy;
   end;
   fwindow.setsizeconstraints(simi,sima);
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
 bo2:= bo1; //backup because of checkwidgetregionchanged
 if bo1 and (fparentwidget <> nil) then begin
  invalidatewidget; //old position
 end;
 if poscha then begin
  if (fparentwidget <> nil) and ((fwidgetrect.x <> value.x) or 
                                 (fwidgetrect.y <> value.y)) then begin
   include(fparentwidget.fwidgetstate1,ws1_childrectchanged);
  end;
  if fparentwidget <> nil then begin
   movewidgetregion(self,subpoint(value.pos,fwidgetrect.pos));
  end;
  fwidgetrect.x:= value.x;
  fwidgetrect.y:= value.y;
  rootchanged(false);
 end;
 if sizecha then begin
  inc(fsetwidgetrectcount);
  setcountbefore:= fsetwidgetrectcount;
  if (componentstate * [csloading,csdesigning] = []) and 
        ((value.cx < fwidgetrect.cx) or (value.cy < fwidgetrect.cy)) then begin
   int2:= 0;
   setlength(ar1,length(fwidgets));
   for int1:= 0 to high(ar1) do begin
    if ws1_tryshrink in fwidgets[int1].fwidgetstate1 then begin
     ar1[int2]:= fwidgets[int1];
     inc(int2);
    end;
   end;
   if int2 > 0 then begin
    setlength(ar1,int2);
    setlength(ar2,int2);
    for int1:= 0 to int2-1 do begin
     ar2[int1]:= ar1[int1].getshrinkpriority;
    end;
    sortarray(ar2,ar3);
    orderarray(ar3,pointerarty(ar1));
    size1:= value.size;
    if fframe <> nil then begin
     subsize1(size1,fframe.paintframedim);
    end;
    if fframe <> nil then begin
     fframe.checkminscrollsize(size1);
    end;
    size2:= clientsize;
    if (size2.cx > size1.cx) or (size2.cy > size1.cy) then begin
     int3:= 0;
     repeat
      exclude(fwidgetstate1,ws1_childrectchanged);
      for int1:= int2-1 downto 0 do begin
       ar1[int1].tryshrink(size1);
      end;
      inc(int3);
     until not(ws1_childrectchanged in fwidgetstate1) or (int3 >= 4);
                                                        //emergency brake
    end;
   end;
  end;
  if (fparentwidget <> nil) and ((fwidgetrect.cx <> value.cx) or 
                                 (fwidgetrect.cy <> value.cy)) then begin
   include(fparentwidget.fwidgetstate1,ws1_childrectchanged);
  end;
  fwidgetrect.cx:= value.cx;
  fwidgetrect.cy:= value.cy;
  invalidateparentminclientsize;
  exclude(fwidgetstate,ws_minclientsizevalid);
  if not (csloading in componentstate) then begin
   checkwidgetregionchanged(bo1);
   sizechanged;
   if fsetwidgetrectcount <> setcountbefore then begin
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
 checkwidgetregionchanged(bo1);
 if poscha and not (csloading in componentstate) then begin
  poschanged;
 end;
 if ownswindow1 then begin
  if not (windowevent and (fwindow.windowpos in windowmaximizedstates)) then begin
   fwindow.fnormalwindowrect:= fwidgetrect;
  end;
  if bo2 and (tws_windowvisible in fwindow.fstate) then begin
   fwindow.checkwindow(windowevent);
  end;
 end;
 if autosizecha and (fwidgetrect.cx = autosi.cx) and 
           (fwidgetrect.cy = autosi.cy) and (fautosizelevel < 6) then begin
                                //emergency break
  inc(fautosizelevel);
  try
   internalsetwidgetrect(fwidgetrect,windowevent);
  finally
   dec(fautosizelevel);
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
 if an_left in fanchors then begin
  bounds_cx:= avalue - fwidgetrect.x;
 end
 else begin
  bounds_x:= avalue - bounds_cx; 
 end;
end;

function twidget.getbottom: integer;
begin
 result:= fwidgetrect.y + fwidgetrect.cy;
end;

procedure twidget.setbottom(const avalue: integer);
begin
 if an_top in fanchors then begin
  bounds_cy:= avalue - fwidgetrect.y;
 end
 else begin
  bounds_y:= avalue - bounds_cy; 
 end;
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

procedure twidget.dobeginread;
begin
 if fframe <> nil then begin
  exclude(fframe.fstate,fs_paintposinited);
 end;
 exclude(fwidgetstate1,ws1_parentclientsizeinited);
 inherited;
end;

procedure twidget.doendread;
begin
 if fframe <> nil then begin
  fframe.calcrects; //rects must be valid for parentfontchanged
 end;
 inherited;
end;

procedure twidget.initparentclientsize;
var
 int1: integer;
begin
 if not (ws1_parentclientsizeinited in fwidgetstate1) then begin
  include(fwidgetstate1,ws1_parentclientsizeinited);
  if fparentwidget <> nil then begin
   fparentclientsize:= fparentwidget.minclientsize;
  end
  else begin
   fparentclientsize:= fwidgetrect.size;
  end;
  int1:= high(fwidgets);
  while int1 >= 0 do begin //keep track of deleted widgets
   if int1 <= high(fwidgets) then begin
    fwidgets[int1].initparentclientsize;
   end;
   dec(int1);
  end;
  {
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].initparentclientsize;
  end;
  }
 end;
end;

procedure twidget.loaded;
begin
 include(fwidgetstate,ws_loadedproc);
 try
  exclude(fwidgetstate1,ws1_widgetregionvalid);
  initparentclientsize;
  inherited;
  doloaded;
  sortzorder;
  updatetaborder(nil);
  parentfontchanged;
  if ffont <> nil then begin
   fontchanged;
  end;
//  if not (ws1_parentclientsizeinited in fwidgetstate1) then begin
//   initparentclientsize;
//  end;   
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
 updateskin;
 if ws1_childscaled in fwidgetstate1 then begin
  appinst.postevent(tobjectevent.create(ek_childscaled,ievent(self)),[peo_local]);
 end;
end;

function twidget.updateopaque(const children: boolean;
                                  const widgetregioncall: boolean): boolean;
                     //true if widgetregionchanged called
var
 bo1,bo2: boolean;
 int1: integer;
begin
 result:= false;
 bo1:= ws_opaque in fwidgetstate;
 if isvisible then begin
  include(fwidgetstate,ws_isvisible);
  if (fparentwidget = nil) or (fwidgetstate * [ws_nopaint] = [])  and
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
 if (bo1 <> (ws_opaque in fwidgetstate)) and (fparentwidget <> nil) 
                       and not fparentwidget.isloading then begin
  if widgetregioncall then begin
   fparentwidget.widgetregionchanged(self);
  end
  else begin
   bo2:= ws1_updateopaque in fwidgetstate1;
   include(fwidgetstate1,ws1_updateopaque);
   try
    fparentwidget.widgetregionchanged(self);
   finally
    if not bo2 then begin
     exclude(fwidgetstate1,ws1_updateopaque);
    end;
   end;
  end;
  result:= true;
 end;
 if children then begin
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].updateopaque(children,false);
  end;
 end;
end;

procedure twidget.colorchanged;
var
 int1: integer;
begin
 updateopaque(true,false);
 invalidatewidget;
 for int1:= 0 to widgetcount - 1 do begin
  with widgets[int1] do begin
   if fcolor = cl_parent then begin
    colorchanged;
   end;
  end;
 end;
end;

{$ifdef mse_with_ifi}

function twidget.getifiwidgetstate: ifiwidgetstatesty;
begin
 result:= [iws_loaded];
 if acs_releasing in factstate then begin
  include(result,iws_releasing);
 end;
 if csdestroying in componentstate then begin
  include(result,iws_releasing);
  include(result,iws_destroying);
 end;
 if ws_visible in fwidgetstate then begin
  include(result,iws_visible);
 end;
 if ws_enabled in fwidgetstate then begin
  include(result,iws_enabled);
 end;
 if ws_entered in fwidgetstate then begin
  include(result,iws_entered);
 end;
 if ws_focused in fwidgetstate then begin
  include(result,iws_focused);
 end;
 if ws_active in fwidgetstate then begin
  include(result,iws_active);
 end; 
end;

procedure twidget.ifiwidgetstatechanged;
begin
 if fifiserverintf <> nil then begin
  fifiserverintf.statechanged(iificlient(self),getifiwidgetstate);
 end;
end;

{$endif}

procedure twidget.statechanged;
begin
 if fframe <> nil then begin
  fframe.updatewidgetstate;
 end;
{$ifdef mse_with_ifi}
 ifiwidgetstatechanged;
{$endif}
 if (fparentwidget <> nil) and fparentwidget.focused and canfocus then begin
  fparentwidget.checksubfocus(false);
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
 updateopaque(false,false);
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

function twidget.getminshrinkpos: pointty;
begin
 result:= fwidgetrect.pos;
// addpoint1(result,fminshrinkposoffset);
end;

function twidget.getshrinkpriority: integer;
begin
 result:= 0;
end;

procedure twidget.tryshrink(const aclientsize: sizety);
begin
 //dummy
end;

function twidget.calcminscrollsize: sizety;
var
 int1,int2: integer;
 anch: anchorsty;
 indent: framety;
 clientorig: pointty;
 pt1: pointty;
 minsi: sizety;
begin
 result:= nullsize;
 if fframe <> nil then begin
  indent:= fframe.fi.innerframe;
  clientorig.x:= -fframe.fpaintrect.x-fframe.fclientrect.x;
  clientorig.y:= -fframe.fpaintrect.y-fframe.fclientrect.y;
 end
 else begin
  indent:= nullframe;
  clientorig:= nullpoint;
 end;
 for int1:= 0 to high(fwidgets) do begin
  with fwidgets[int1],fwidgetrect do begin
   if visible and not(ws1_nominsize in fwidgetstate1) or 
                                  (csdesigning in componentstate) then begin
    pt1:= getminshrinkpos;
    minsi:= getminshrinksize;
    if not (ow1_noparentwidthextend in foptionswidget1) then begin
     anch:= fanchors * [an_left,an_right];
     if anch = [an_right] then begin
      int2:= fparentclientsize.cx - x + indent.left + clientorig.x;
     end
     else begin
      if anch = [] then begin
       int2:= minsi.cx;
      end
      else begin
       if anch = [an_left,an_right] then begin
        int2:= fparentclientsize.cx - cx + minsi.cx;
       end
       else begin //[an_left]
        int2:= clientorig.x + pt1.x + cx + indent.right;
       end;
      end;
     end;
     if int2 > result.cx then begin
      result.cx:= int2;
     end;
    end;

    if not (ow1_noparentheightextend in foptionswidget1) then begin
     anch:= fanchors * [an_top,an_bottom];
     if anch = [an_bottom] then begin
      int2:= fparentclientsize.cy - y + indent.top + clientorig.y;
     end
     else begin
      if anch = [] then begin
       int2:= minsi.cy;
      end
      else begin
       if anch = [an_top,an_bottom] then begin
        int2:= fparentclientsize.cy - cy + minsi.cy;
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
 if fframe <> nil then begin
  fframe.checkminscrollsize(result);
 end;
end;

procedure twidget.childclientrectchanged(const sender: twidget);
begin
 //dummy
end;

procedure twidget.parentclientrectchanged;
var
 size1,delta: sizety;
 anch: anchorsty;
 rect1: rectty;
 int1: integer;

begin
 if ([csloading,csdestroying]*componentstate = []) and (fparentwidget <> nil) and
        not (ws1_anchorsizing in fwidgetstate1) then begin
  if ws1_scaling in fparentwidget.fwidgetstate1 then begin
   fparentclientsize:= fparentwidget.minclientsize;
  end
  else begin
   int1:= 0; //loopcount
   repeat
    size1:= fparentwidget.minclientsize;
    rect1:= fwidgetrect;
    delta:= subsize(size1,fparentclientsize);
    if ws1_anchorsetting in fwidgetstate1 then begin
     delta:= nullsize;
     exclude(fwidgetstate1,ws1_anchorsetting);
    end;
    anch:= fanchors * [an_left,an_right];
    if anch <> [an_left] then begin
     if (anch = [an_left,an_right]) then begin
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
        end;
       end;
      end;
     end;
    end;
    anch:= fanchors * [an_top,an_bottom];
    if anch <> [an_top] then begin
     if (anch = [an_top,an_bottom]) then begin
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
        end;
       end;
      end;
     end;
    end;
    fparentclientsize:= size1;
    include(fwidgetstate1, ws1_anchorsizing);
    try
     setwidgetrect(rect1);
    finally
     exclude(fwidgetstate1, ws1_anchorsizing);
    end;
    inc(int1);
   until sizeisequal(size1,fparentwidget.minclientsize) or (int1 > 5);
  end;
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
// widgetregioninvalid;
 if isvisible then begin
  invalidatewidget;
  reclipcaret;
 end;
 if (ws_loadedproc in fwidgetstate) then begin
  parentclientrectchanged;
 end
 else begin
  checkautosize;
  for int1:= 0 to high(fwidgets) do begin
   fwidgets[int1].parentclientrectchanged;
  end;
 end;
 if ([csloading,csdestroying] * componentstate = []) and 
                                         (fparentwidget <> nil) then begin
  fparentwidget.childclientrectchanged(self);
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

procedure twidget.release(const nomodaldefer: boolean=false);
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

procedure twidget.dopaintforeground(const canvas: tcanvas);
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
  fframe.paintbackground(canvas,makerect(nullpoint,fwidgetrect.size),true);
  canvas.color:= colorbefore;
 end;
 if not canvas.clipregionisempty then begin
  face1:= getactface;
  if face1 <> nil then begin
   if not (fao_overlay in face1.options) then begin
    if fframe <> nil then begin
     fframe.checkstate();
     canvas.remove(fframe.fclientrect.pos);
     face1.paint(canvas,makerect(nullpoint,fframe.fpaintrect.size));
     canvas.move(fframe.fclientrect.pos);
    end
    else begin
     face1.paint(canvas,makerect(nullpoint,fwidgetrect.size));
    end;
   end;
  end;
  doonpaintbackground(canvas);
 end;
end;

procedure twidget.doonpaintbackground(const canvas: tcanvas);
begin
 //dummy
end;

procedure twidget.dopaint(const canvas: tcanvas);
begin
 dopaintbackground(canvas);
 if not canvas.clipregionisempty then begin
  dobeforepaintforeground(canvas);
  dopaintforeground(canvas);
 end;
end;

procedure twidget.doonpaint(const canvas: tcanvas);
begin
 //dummy
end;

procedure twidget.dopaintoverlay(const canvas: tcanvas);
var
 face1: tcustomface;
begin
 face1:= getactface;
 if face1 <> nil then begin
  if fao_overlay in face1.options then begin
   if fframe <> nil then begin
//    canvas.remove(fframe.fclientrect.pos);
//    face1.paint(canvas,makerect(nullpoint,fframe.fpaintrect.size));
    face1.paint(canvas,fframe.fpaintrect);
//    canvas.move(fframe.fclientrect.pos);
   end
   else begin
    face1.paint(canvas,makerect(nullpoint,fwidgetrect.size));
   end;
  end;
 end;
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
 result:= (fframe <> nil) and fframe.needsfocuspaint;
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
   (owner <> nil) and //no frame for toplevel
   (
     ((fwidgetrect.cx = 0) or (fwidgetrect.cy = 0)) or
     (
       ( 
         (fcolor = cl_transparent) or 
           (fparentwidget <> nil) and 
           (colortopixel(actualopaquecolor) = 
              colortopixel(fparentwidget.actualopaquecolor{backgroundcolor}))
       ) and
       ((fframe = nil) or 
          (fframe.fi.leveli = 0) and (fframe.fi.levelo = 0) and
          ((fframe.fi.framewidth = 0) or (frame.fi.colorframe = cl_transparent))
       )
     )     
   );
end;

procedure twidget.paint(const canvas: tcanvas);
label
 endlab;
var
 int1,int2: integer;
 saveindex: integer;
 actcolor: colorty;
 col1: colorty;
 reg1: gdiregionty;
 rect1: rectty;
 widget1: twidget;
 bo1,bo2: boolean;
 face1: tcustomface;
begin
 bo2:= ws1_painting in fwidgetstate1;
 include(fwidgetstate1,ws1_painting);
 canvas.save;
 rect1.pos:= nullpoint;
 rect1.size:= fwidgetrect.size;
 canvas.intersectcliprect(rect1);
 if canvas.clipregionisempty then begin
  goto endlab;
 end;
 canvas.save;
 if not (ws_nopaint in fwidgetstate) then begin
  canvas.brushorigin:= nullpoint;
  actcolor:= actualcolor;
  saveindex:= canvas.save;
  dobeforepaint(canvas);
  if (high(fwidgets) >= 0) and 
                        not (ws1_noclipchildren in fwidgetstate1) then begin
   updatewidgetregion;
   canvas.subclipregion(fwidgetregion.region);
  end;
  bo1:= not canvas.clipregionisempty;
  if bo1 then begin
   if (ws_opaque in fwidgetstate) or (actcolor <> cl_transparent) then begin
    col1:= actcolor;
    if actcolor = cl_transparent then begin
     col1:= cl_background; //no parent
    end;
    canvas.fillrect(rect1,col1);
   end;
   {$ifdef mse_slowdrawing}
   sleep(500);
   {$endif}
   canvas.font:= getfont;
   canvas.color:= actcolor;
   canvas.drawinfopo:= nil;
   dopaint(canvas);
   if not canvas.clipregionisempty then begin
    doonpaint(canvas);
   end;
  end;
  canvas.restore(saveindex);
  if bo1 then begin
   face1:= getactface;
   if (face1 <> nil) and (fao_alphafadenochildren in face1.fi.options) then begin
    canvas.move(paintpos);
    face1.doalphablend(canvas);
    canvas.remove(paintpos);
   end;
  end;
 end
 else begin
  updatewidgetregion;
 end;
 if (widgetcount > 0) then begin
  if (fframe <> nil) and not (ow_nochildpaintclip in foptionswidget) then begin
   fframe.checkstate;
   canvas.intersectcliprect(fframe.fpaintrect);
  end;
  rect1:= canvas.clipbox;
  for int1:= 0 to widgetcount-1 do begin
   widget1:= twidget(fwidgets[int1]);
   with widget1 do begin
    if isvisible and testintersectrect(rect1,fwidgetrect) then begin
     saveindex:= canvas.save;
     if not (ow_nochildclipsiblings in self.foptionswidget) then begin
      for int2:= int1 + 1 to self.widgetcount - 1 do begin
       with self.fwidgets[int2],tcanvas1(canvas) do begin
        if visible and testintersectrect(widget1.fwidgetrect,fwidgetrect) then begin
             //clip higher level siblings
         if (ws_opaque in fwidgetstate) then begin
          subcliprect(fwidgetrect);
         end
         else begin
          reg1:= msegui.createregion(self.window.fgdi);
          addopaquechildren(reg1);
          subclipregion(reg1.region);
          msegui.destroyregion(reg1);
         end;
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
 if (csdesigning in componentstate) and needsdesignframe then begin
  canvas.dashes:= #2#3;
  canvas.drawrect(makerect(0,0,fwidgetrect.cx-1,fwidgetrect.cy-1),cl_black);
  canvas.dashes:= '';
 end;
 doafterpaint(canvas);
endlab:
 canvas.restore;
 if not bo2 then begin
  exclude(fwidgetstate1,ws1_painting);
 end;
end;

procedure twidget.parentwidgetregionchanged(const sender: twidget);
begin
 //dummy
end;

procedure twidget.widgetregionchanged(const sender: twidget);
var
 int1: integer;
begin
 if not (csdestroying in componentstate) then begin
  widgetregioninvalid;
  if sender = nil then begin
   invalidate;
  end
  else begin
   invalidaterect(sender.fwidgetrect,org_widget);
  end;
  if componentstate * [csloading,csdestroying] = [] then begin
   for int1:= 0 to high(fwidgets) do begin
    fwidgets[int1].parentwidgetregionchanged(sender);
   end;
  end;
 end;
end;

procedure twidget.addopaquechildren(var region: gdiregionty);
var
 int1: integer;
 widget: twidget;
 rect1: rectty;
begin
 if not ((fface <> nil) and (fao_alphafadeall in fface.fi.options)) then begin
  updateroot;
  if ws_isvisible in fwidgetstate then begin
   rect1:= paintrect;
   for int1:= 0 to widgetcount - 1 do begin
    widget:= twidget(fwidgets[int1]);
    if ws_opaque in widget.fwidgetstate then begin
     regaddrect(region,moverect(intersectrect(rect1,widget.fwidgetrect),
                                                                    frootpos));
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
  destroyregion(fwidgetregion);
  if widgetcount > 0 then begin
   fwidgetregion:= createregion(window.fgdi);
   addopaquechildren(fwidgetregion);
{
   if fframe <> nil then begin
    frame.checkstate;
    regintersectrect(fwidgetregion,makerect(fframe.fpaintrect.x+frootpos.x,
                                       fframe.fpaintrect.y+frootpos.y,
                                       fframe.fpaintrect.cx,fframe.fpaintrect.cy));
   end
   else begin
    regintersectrect(fwidgetregion,makerect(frootpos,fwidgetrect.size));
   end;
}
  end;
  include(fwidgetstate1,ws1_widgetregionvalid);
 end;
end;

function twidget.getgdi: pgdifunctionaty;
begin
 result:= getdefaultgdifuncs;
end;

procedure twidget.createwindow;
begin
 twindow.create(self,getgdi); //sets fwindow
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

procedure twidget.rootchanged(const awidgetregioninvalid: boolean);
var
 int1: integer;
begin
 if fparentwidget <> nil then begin
  fwindow:= nil;
 end;
 fwidgetstate1:= fwidgetstate1 - [{ws1_widgetregionvalid,}ws1_rootvalid];
 if awidgetregioninvalid then begin
  exclude(fwidgetstate1,ws1_widgetregionvalid);
 end;
 for int1:= 0 to high(fwidgets) do begin
  fwidgets[int1].rootchanged(awidgetregioninvalid);
 end;
end;

procedure twidget.parentchanged;
var
 int1: integer;
begin
 if not (ws_loadedproc in fwidgetstate) then begin
  updateopaque(false,false);
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
 result:= (fwindow <> nil) and (fwindow.fownerwidget = self);
end;

function twidget.windowallocated: boolean;
begin
 result:= (fwindow <> nil) and fwindow.haswinid and 
         (componentstate * [csloading,csdestroying] = []);
 
end;

function twidget.ownswindow: boolean;
begin
 result:= (fwindow <> nil) and (fwindow.fownerwidget = self) and 
                                                (fwindow.fwindow.id <> 0);
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
 result:= addpoint(frootpos,fwindow.screenpos);
end;

procedure twidget.setscreenpos(const avalue: pointty);
begin
 updateroot;
 fwindow.screenpos:= subpoint(avalue,frootpos);
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
var
 wi1,wi2: twidget;
begin
 wi1:= self;
 repeat
  wi2:= wi1;
  wi1:= wi2.fparentwidget;
 until wi1 = nil;
 result:= wi2;
end;

function twidget.parentofcontainer: twidget;
var
 widget1: twidget;
begin
 result:= fparentwidget;
 if (fparentwidget <> nil) then begin
  widget1:= fparentwidget.fparentwidget;
  if (widget1 <> nil) and not (ws_iswidget in result.fwidgetstate) then begin
   result:= widget1;
  end;
 end;
end;

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

function twidget.framedim: sizety;    
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

function twidget.frameinnerrect: rectty;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result:= inflaterect(fframe.fpaintrect,fframe.fpaintframedelta);
 end
 else begin
  result.pos:= nullpoint;
  result.size:= fwidgetrect.size;
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

function twidget.paintclientrect: rectty;         //origin = clientrect
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result.x:= -fframe.fclientrect.x;
  result.y:= -fframe.fclientrect.y;
  result.size:= fframe.fpaintrect.size;
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

function twidget.paintsizerect: rectty;          //pos = nullpoint
begin
 result.pos:= nullpoint;
 result.size:= paintsize;
end;

function twidget.clientsizerect: rectty;          //pos = nullpoint
begin
 result.pos:= nullpoint;
 result.size:= clientsize;
end;

function twidget.containerclientsizerect: rectty;          //pos = nullpoint
begin
 result.pos:= nullpoint;
 result.size:= container.clientsize;
end;

function twidget.getclientrect: rectty;
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

function twidget.windowpo: pwindowty;
begin
 window.checkwindowid;
 result:= @fwindow.fwindow;
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

procedure twidget.invalidaterect(const rect: rectty;
                const org: originty = org_client; const noclip: boolean = false);
var
 rect1,rect2: rectty;
 po1: prectty;
begin
 if invalidateneeded then begin
  updateroot;
  rect1:= rect;
  rect2.pos:= nullpoint;
  rect2.size:= fwidgetrect.size;
  po1:= @rect2;
  case org of
   org_client: begin
    if fframe <> nil then begin
     inc(rect1.x,fframe.fclientrect.pos.x);
     inc(rect1.x,fframe.fpaintrect.pos.x);
     inc(rect1.y,fframe.fclientrect.pos.y);
     inc(rect1.y,fframe.fpaintrect.pos.y);
     po1:= @fframe.fpaintrect;
    end;
   end;
   org_inner: begin
    if fframe <> nil then begin
     inc(rect1.x,fframe.finnerclientrect.pos.x);
     inc(rect1.y,fframe.finnerclientrect.pos.y);
     inc(rect1.x,fframe.fpaintrect.pos.x);
     inc(rect1.y,fframe.fpaintrect.pos.y);
     po1:= @fframe.fpaintrect;
    end;
   end;
  end;
  if not noclip then begin
   msegraphutils.intersectrect(rect1,po1^,rect1);
  end;
  inc(rect1.x,frootpos.x);
  inc(rect1.y,frootpos.y);
  fwindow.invalidaterect(rect1,self);
 end;
end;

procedure twidget.invalidateframestaterect(const rect: rectty;
      const aframe: tcustomframe; const org: originty = org_client);
begin
 if (fframe = nil) or (fframe.fi.frameimage_list = nil) then begin
  invalidaterect(rect,org,true);
 end
 else begin
  invalidaterect(inflaterect(rect,aframe.innerframe),org,true);
//  invalidatewidget;
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
 ainfo: mouseeventinfoty;
begin
 result:= nil;
 with info do begin
  if (pos.x < 0) or (pos.y < 0) or (pos.x >= fwidgetrect.cx) or
              (pos.y >= fwidgetrect.cy) then begin
   exit;
  end
  else begin
   if info.mouseeventinfopo = nil then begin
    fillchar(ainfo,0,sizeof(ainfo));
    ainfo.pos:= info.pos;
    updatemousestate(ainfo);
   end
   else begin
    updatemousestate(info.mouseeventinfopo^);
   end;
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
  if (frame = nil) or (ow_nochildpaintclip in foptionswidget) or 
                                 pointinrect(pos,fframe.fpaintrect) then begin
   for int1:= widgetcount - 1 downto 0 do begin
    with widgets[int1] do begin
     subpoint1(info.pos,fwidgetrect.pos);
     if info.mouseeventinfopo <> nil then begin
      info.mouseeventinfopo^.pos:= info.pos;
     end;
     result:= widgetatpos(info);
     addpoint1(info.pos,fwidgetrect.pos);
     if info.mouseeventinfopo <> nil then begin
      info.mouseeventinfopo^.pos:= info.pos;
     end;
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

function compxbanded(const l,r): integer;
begin
 result:= (twidget(l).fwidgetrect.y + twidget(l).fwidgetrect.cy) -
                                    twidget(r).fwidgetrect.y - 1;
 if result >= 0 then begin
  result:= -((twidget(r).fwidgetrect.y + twidget(r).fwidgetrect.cy) -
                                    twidget(l).fwidgetrect.y - 1);
  if result <= 0 then begin
   result:= twidget(l).fwidgetrect.x - twidget(r).fwidgetrect.x;
  end;
 end;
end;

function twidget.getsortxchildren(const banded: boolean = false): widgetarty;
//var
// int1: integer;
begin
 result:= copy(container.fwidgets);
 if banded then begin
  sortarray(pointerarty(result),{$ifdef FPC}@{$endif}compxbanded);
 end
 else begin
  sortwidgetsxorder(result);
 end;
end;

function compybanded(const l,r): integer;
begin
 result:= (twidget(l).fwidgetrect.x + twidget(l).fwidgetrect.cx) -
                                    twidget(r).fwidgetrect.x - 1;
 if result >= 0 then begin
  result:= -((twidget(r).fwidgetrect.x + twidget(r).fwidgetrect.cx) -
                                     twidget(l).fwidgetrect.x - 1);
  if result <= 0 then begin
   result:= twidget(l).fwidgetrect.y - twidget(r).fwidgetrect.y;
  end;
 end;
end;

function twidget.getsortychildren(const banded: boolean = false): widgetarty;
begin
 result:= copy(container.fwidgets);
 if banded then begin
  sortarray(pointerarty(result),{$ifdef FPC}@{$endif}compybanded);
 end
 else begin
  sortwidgetsyorder(result);
 end;
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

function twidget.getlogicalchildren: widgetarty; //children of container
var
 int1,int2: integer;
begin
 with container do begin 
  setlength(result,length(fwidgets));
  int2:= 0;
  for int1:= 0 to high(result) do begin
   result[int2]:= fwidgets[int1];
   if ws_iswidget in result[int2].fwidgetstate then begin
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

procedure twidget.addlogicalchildren(var achildren: widgetarty);
begin
 stackarray(pointerarty(getlogicalchildren),pointerarty(achildren));
end;

function twidget.findlogicalchild(const aname: ansistring): twidget;
begin
 result:= dofindwidget(getlogicalchildren,aname);
end;

function twidget.mouseeventwidget(const info: mouseeventinfoty): twidget;
var
 findinfo: widgetatposinfoty;
begin
 fillchar(findinfo,sizeof(findinfo),0);
 with findinfo do begin
  pos:= info.pos;
  mouseeventinfopo:= @info;
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

procedure twidget.updatemousestate(const info: mouseeventinfoty);
begin
 fwidgetstate:= fwidgetstate -
      [ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,ws_wantmousefocus];
 if fframe <> nil then begin
  fframe.updatemousestate(self,info);
 end
 else begin
  if not (ow_mousetransparent in foptionswidget) then begin
   if (info.pos.x >= 0) and (info.pos.x < fwidgetrect.cx) and
            (info.pos.y >= 0) and (info.pos.y < fwidgetrect.cy) then begin
    fwidgetstate:= fwidgetstate +
       [ws_mouseinclient,ws_wantmousebutton,ws_wantmousemove,ws_wantmousefocus];
   end;
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
  if not (es_processed in eventstate) or 
                                 (info.eventkind = ek_mousemove) then begin
   updatemousestate(info);
   if [ws_mouseinclient,ws_clientmousecaptured] * fwidgetstate <> [] then begin
    if (appinst.fclientmousewidget <> self) and not (es_child in eventstate) then begin
                       //call updaterootwidget
     appinst.setclientmousewidget(self,info.pos);
    end;
    result:= true;
    if fframe <> nil then begin
     subpoint1(pos,getclientoffset);
    end;
   end
   else begin
    appinst.setclientmousewidget(nil,nullpoint);
    result:= false;
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function twidget.wantmousefocus(const info: mouseeventinfoty): boolean;
begin
 result:= not (es_nofocus in info.eventstate) and {not focused and}
                      (ws_wantmousefocus in fwidgetstate)and
       (ow_mousefocus in foptionswidget) and canfocus;
{
 if result and focused then begin
  activate;
  result:= false;
 end;
}
end;
       
procedure twidget.mouseevent(var info: mouseeventinfoty);

 procedure doclientmouseevent;
 begin
  include(info.eventstate,es_client);
  try
   clientmouseevent(info);
  finally
   exclude(info.eventstate,es_client);
  end;    
 end; //doclientmouseevent
 
var
 clientoffset: pointty;
 wi1: twidget;
begin
 exclude(fwidgetstate,ws_newmousecapture);
 if info.eventstate * [es_child,es_processed] = [] then begin
  include(info.eventstate,es_child);
  try
   childmouseevent(self,info);
  finally
   exclude(info.eventstate,es_child);
  end;
 end;
 with info do begin
  if not (eventkind in mouseregionevents) then begin
   if not (ss_left in shiftstate) and
      not((eventkind = ek_buttonrelease) and (button = mb_left)) then begin
    exclude(fwidgetstate,ws_lclicked);
   end;
   if not (ss_middle in shiftstate) and
      not((eventkind = ek_buttonrelease) and (button = mb_middle)) then begin
    exclude(fwidgetstate,ws_mclicked);
   end;
   if not (ss_right in shiftstate) and
      not((eventkind = ek_buttonrelease) and (button = mb_right)) then begin
    exclude(fwidgetstate,ws_rclicked);
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   clientoffset:= nullpoint;
   case eventkind of
    ek_mousemove,ek_mousepark: begin
     if isclientmouseevent(info) then begin
      doclientmouseevent;
      clientoffset:= getclientoffset;
     end;
    end;
    ek_mousecaptureend: begin
     if ws_clientmousecaptured in fwidgetstate then begin
      doclientmouseevent;
     end;
    end;
    ek_clientmouseleave: begin
     if (fframe <> nil) and frame.needsmouseenterinvalidate() then begin
      invalidatewidget;
     end;
     if appinst.fmousewidget = self then begin
      if fparentwidget <> nil then begin
       fparentwidget.updatecursorshape(addpoint(appinst.fmousewidgetpos,
                          fparentwidget.fwidgetrect.pos)) {(true)};
      end
      else begin
       appinst.widgetcursorshape:= cr_default;
      end;
     end;
     doclientmouseevent;
    end;
    ek_clientmouseenter: begin
     if (fframe <> nil) and fframe.needsmouseenterinvalidate() then begin
      invalidatewidget;
     end;
     updatecursorshape(info.pos){(true)};
     doclientmouseevent;
    end;
    ek_buttonpress: begin
     if button = mb_left then begin
      include(fwidgetstate,ws_lclicked);
      if (fframe <> nil) and fframe.needsclickinvalidate() then begin
       invalidatewidget;
      end;
     end;
     if button = mb_middle then begin
      include(fwidgetstate,ws_mclicked);
     end;
     if button = mb_right then begin
      include(fwidgetstate,ws_rclicked);
     end;
     if appinst.fmousecapturewidget <> self then begin
      include(fwidgetstate,ws_newmousecapture);
     end;
     appinst.capturemouse(self,true);
     if isclientmouseevent(info) then begin
      include(fwidgetstate,ws_clientmousecaptured);
      doclientmouseevent;
      clientoffset:= getclientoffset;
     end;
     wi1:= self;
     repeat
      with wi1 do begin
       if wantmousefocus(info) then begin
        if focused then begin
         activate;
        end
        else begin
         setfocus;
        end;
        break;
       end;
      end;
      wi1:= wi1.parentwidget;
     until wi1 = nil;
    end;
    ek_buttonrelease: begin
     if (button = mb_left) and (fframe <> nil) and 
                                fframe.needsclickinvalidate() then begin
      invalidatewidget;
     end;
     if isclientmouseevent(info) then begin
      doclientmouseevent;
      clientoffset:= getclientoffset;
     end;
    end;
   end;
   addpoint1(pos,clientoffset);
  end;
  if eventkind = ek_buttonrelease then begin
   if button = mb_left then begin
    exclude(fwidgetstate,ws_lclicked);
   end;
   if button = mb_middle then begin
    exclude(fwidgetstate,ws_mclicked);
   end;
   if button = mb_right then begin
    exclude(fwidgetstate,ws_rclicked);
   end;
   if (appinst <> nil) and ((shiftstate - mousebuttontoshiftstate(button)) *
                            mousebuttons = []) and
                           (appinst.fmousecapturewidget = self) then begin
    if not (ws_mousecaptured in fwidgetstate) then begin
     appinst.capturemouse(nil,false);
    end
    else begin
     fwidgetstate:= fwidgetstate - [ws_clientmousecaptured];
//     appinst.ungrabpointer; ????
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
   if not (es_processed in eventstate) and (fparentwidget <> nil) and
                          (self <> window.fmodalwidget) then begin
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
 fwidgetstate:= fwidgetstate + [ws_lclicked,ws_clientmousecaptured];
end;

procedure twidget.clientmouseevent(var info: mouseeventinfoty);
begin
 //dummy
end;

procedure twidget.childmouseevent(const sender: twidget;
                    var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  if (fparentwidget <> nil) and (self <> window.fmodalwidget) then begin
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

procedure twidget.setanchordwidgetsize(const asize: sizety);
var
 rect1: rectty;
begin
 rect1.pos:= fwidgetrect.pos;
 rect1.size:= asize;
 if fanchors * [an_left,an_right] = [an_right] then begin
  rect1.x:= rect1.x - rect1.cx + fwidgetrect.cx;
 end;
 if fanchors * [an_top,an_bottom] = [an_bottom] then begin
  rect1.y:= rect1.y - rect1.cy + fwidgetrect.cy;
 end;
 widgetrect:= rect1;
end;

procedure twidget.setclientsize(const asize: sizety);
begin
 setanchordwidgetsize(addsize(asize,clientframewidth));
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

function twidget.getpaintsize: sizety;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  result:= fframe.fpaintrect.size;
 end
 else begin
  result:= fwidgetrect.size;
 end;
end;

procedure twidget.setpaintsize(const avalue: sizety);
begin
 setanchordwidgetsize(addsize(avalue,framedim));
end;

function twidget.getframesize: sizety;
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

procedure twidget.setframesize(const avalue: sizety);
var
 si1: sizety;
begin
 si1:= avalue;
 if fframe <> nil then begin
//  fframe.checkstate;
  with fframe.fouterframe do begin
   si1.cx:= si1.cx + left + right;
   si1.cy:= si1.cy + top + bottom;
  end;
 end;
 setanchordwidgetsize(si1);
end;

procedure twidget.setframewidth(const avalue: integer);
begin
 setframesize(ms(avalue,getframesize.cy));
end;

procedure twidget.setframeheight(const avalue: integer);
begin
 setframesize(ms(getframesize.cx,avalue));
end;

procedure twidget.setpaintwidth(const avalue: integer);
begin
 setpaintsize(ms(avalue,getpaintsize.cy));
end;

procedure twidget.setpaintheight(const avalue: integer);
begin
 setpaintsize(ms(getpaintsize.cx,avalue));
end;

function twidget.getframeheight: integer;
begin
 result:= getframesize.cy;
end;

function twidget.getpaintwidth: integer;
begin
 result:= getpaintsize.cx;
end;

function twidget.getpaintheight: integer;
begin
 result:= getpaintsize.cy;
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

function twidget.widgetclientrect: rectty;        //origin = clientrect.pos
begin
 result.size:= fwidgetrect.size;
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result.x:= fpaintrect.x-fclientrect.x;
   result.y:= fpaintrect.y-fclientrect.y;
  end
 end
 else begin
  result.pos:= nullpoint;
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

function twidget.innerclientpaintpos: pointty;    //origin = paintpos
begin
 if fframe <> nil then begin
  with frame do begin
   checkstate;
   result:= fframe.finnerclientrect.pos;
  end;
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

procedure twidget.innertopaintsize(var asize: sizety);
begin
 if fframe <> nil then begin
  with fframe do begin
   asize.cx:= asize.cx + framei_left + framei_right;
   asize.cy:= asize.cy + framei_top + framei_bottom;
  end;
 end; 
end;

procedure twidget.painttowidgetsize(var asize: sizety);
begin
 if fframe <> nil then begin
  with fframe do begin
   checkstate;
   asize.cx:= asize.cx + fpaintframe.left + fpaintframe.right;
   asize.cy:= asize.cy + fpaintframe.top + fpaintframe.bottom;
  end;
 end; 
end;

function twidget.clientparentpos: pointty;
        //origin = parentwidget.pos
begin
 result:= addpoint(fwidgetrect.pos,clientwidgetpos);
end;

function twidget.refpos(const aorigin: originty): pointty;
begin
 case aorigin of
  org_screen: begin
   result:= screenpos;
  end;
  org_widget: begin
   result:= pos;
  end;
  org_client: begin
   result:= parentclientpos;
  end;
  org_inner: begin
   result:= addpoint(parentclientpos,innerclientpos);
  end;
 end;
end;

function twidget.paintparentpos: pointty;       //origin = parentwidget.pos
begin
 result:= addpoint(fwidgetrect.pos,paintpos);
end;

function twidget.parentpaintpos: pointty;    //origin = parentwidget.paintpos
                                             //nullpoint if parent = nil
begin
 if fparentwidget = nil then begin
  result:= nullpoint;
 end
 else begin
  result:= subpoint(fwidgetrect.pos,fparentwidget.paintpos);
 end;
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

function twidget.checkdescendent(awidget: twidget): boolean;
begin
 result:= false;
 while awidget <> nil do begin
  if awidget = self then begin
   result:= true;
   break;
  end;
  awidget:= awidget.fparentwidget;
 end;
end;

function twidget.checkancestor(awidget: twidget): boolean;
                  //true if widget is ancestor or self
var
 widget1: twidget;
begin
 result:= false;
 if awidget <> nil then begin
  widget1:= self;
  while widget1 <> nil do begin
   if widget1 = awidget then begin
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
                not releasing and
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
  if (widget1 <> nil) and widget1.canfocus then begin
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

procedure twidget.parentfocus;
var
 widget1: twidget;
begin
 widget1:= self;
 while widget1 <> nil do begin
  if widget1.canfocus then begin
   widget1.setfocus(false);
   break;
  end;
  widget1:= widget1.fparentwidget;
 end;
end;

function twidget.cantabfocus: boolean;
var
 int1: integer;
begin
 result:= (ow_tabfocus in foptionswidget) and
           (fwidgetstate * focusstates = focusstates);
 if result and (ow_subfocus in foptionswidget) then begin
  for int1:= 0 to high(fwidgets) do begin
   if fwidgets[int1].cantabfocus then begin
    exit; 
   end;
  end;
  result:= false;
 end;
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
 if (fparentwidget <> nil) and 
           not (csdestroying in fparentwidget.componentstate) then begin
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
   if (ow1_canclosenil in foptionswidget1) then begin
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
 {$ifdef mse_with_ifi}
var
 lwo1: longword;
 {$endif}
begin
 if not (ws_focused in fwidgetstate) then begin
  include(fwidgetstate,ws_focused);
 {$ifdef mse_with_ifi}
  lwo1:= window.focuscount;
 {$endif}
  dofocus;
 {$ifdef mse_with_ifi}
  if lwo1 = window.focuscount then begin
   ifiwidgetstatechanged;
  end;
 {$endif}
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
 {$ifdef mse_with_ifi}
var
 lwo1: longword;
 {$endif}
begin
 if ws_focused in fwidgetstate then begin
  exclude(fwidgetstate,ws_focused);
 {$ifdef mse_with_ifi}
  lwo1:= window.focuscount;
 {$endif}
  dodefocus;
 {$ifdef mse_with_ifi}
  if lwo1 = window.focuscount then begin
   ifiwidgetstatechanged;
  end;
 {$endif}
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
   window.invalidaterect(makerect(frootpos,fwidgetrect.size),self);
           //invalidate old position and size
  end;
  exclude(fwidgetstate,ws_visible);
  dohide;
 end
 else begin
  exclude(fwidgetstate,ws_visible);
  bo2:= updateopaque(false,true);
 end;
 if ws_visible in fwidgetstate then begin
  exit; //show called
 end;
 if bo1 then begin
  if not bo2 and (fparentwidget <> nil) and 
                                 not fparentwidget.isloading then begin
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

function twidget.internalshow(const modallevel: modallevelty;
             const transientfor: pwindow; //follow linked var state
             const windowevent,nomodalforreset: boolean): modalresultty;
var
 bo1,bo2: boolean;
 modaltransientfor: twindow;
// w1: twidget;
 info: showinfoty;
begin
 if modallevel = ml_application then begin
  modaltransientfor:= nil;
  info.transientfor:= nil;
  if transientfor^ = nil then begin
   setlinkedvar(fwindow.defaulttransientfor,tlinkedobject(info.transientfor));
   modaltransientfor:= info.transientfor;
//   transientfor:= fwindow.defaulttransientfor;
//   modaltransientfor:= transientfor;
  end
  else begin
   setlinkedvar(transientfor^,tlinkedobject(info.transientfor));
  end;
  info.widget:= nil;
  setlinkedvar(self,tmsecomponent(info.widget));
  try
//   info.transientfor:= transientfor;
   info.windowevent:= windowevent;
   info.nomodalforreset:= nomodalforreset;
   if window.beginmodal(@info) or (info.widget = nil) then begin
    result:= mr_windowdestroyed;
    exit;
   end;
   if modaltransientfor <> nil then begin
    window.settransientfor(nil,false);
   end;
  finally
   if info.widget <> nil then begin //else self is destroyed
    setlinkedvar(nil,tlinkedobject(info.transientfor));
    setlinkedvar(nil,tmsecomponent(info.widget));
   end;
  end;
 end
 else begin
  bo1:= not showing;
  updateroot; //create window
  if fparentwidget <> nil then begin
   if not (csdesigning in componentstate) then begin
    include(fwidgetstate,ws_showproc);
    try
     fparentwidget.show(modallevel,transientfor^);
    finally
     exclude(fwidgetstate,ws_showproc);
    end;
   end;
  end;
  include(fwidgetstate,ws_visible);
  if bo1 then begin
   if not updateopaque(false,true) and (fparentwidget <> nil) then begin
    fparentwidget.widgetregionchanged(self);
   end;
  end;
  if ownswindow1 then begin
   bo2:= transientfor^ = window;
//   if transientfor = window then begin
//    transientfor:= nil;
//   end;
   if not bo2 and (transientfor^ <> nil) and (modallevel = ml_window) then begin
    include(fwindow.fstate,tws_modalfor);
   end
   else begin
    if not nomodalforreset then begin
     exclude(fwindow.fstate,tws_modalfor);
    end;
   end;
   fwindow.show(windowevent);
   if not nomodalforreset and not bo2 then begin
    fwindow.settransientfor(transientfor^,windowevent);
   end;
   if bo1 then begin
    doshow;
   end;
   if (modallevel = ml_window) and (fwindow.modalfor) and
                 fwindow.ftransientfor.active then begin
    fwindow.activate;             
   end;
  end
  else begin
   if bo1 then begin
    doshow;
   end;
  end;
 end; // ml_application
 if fwindow <> nil then begin
  result:= fwindow.fmodalresult;
 end
 else begin
  result:= mr_none;
 end;
end;

function twidget.show(const modallevel: modallevelty;
              const transientfor: twindow = nil): modalresultty;
var
 event: twidgetshowevent;
begin
 if (modallevel = ml_application) and not application.ismainthread then begin
  event:= twidgetshowevent.create(false);
  event.fwidget:= self;
  event.fmodallevel:= modallevel;
//  event.ftransientfor:= transientfor^; dangerouse becouse of lifetime
  try
   synchronizeevent(event);
   result:= event.fmodalresult;
  finally
   event.free;
  end;  
 end
 else begin
  result:= internalshow(modallevel,@transientfor,false,false);
 end;
end;

function twidget.show(const modallevel: modallevelty;
            const transientfor: twidget): modalresultty;
begin
 if transientfor = nil then begin
  result:= show(modallevel,twindow(nil));
 end
 else begin
  result:= show(modallevel,transientfor.window);
 end;
end;

function twidget.show(const modal: boolean = false;
              const transientfor: twindow = nil): modalresultty;
begin
 if modal then begin
  result:= show(ml_application,transientfor);
 end
 else begin
  result:= show(ml_none,transientfor);
 end;
end;

procedure twidget.endmodal;
begin
 if window.fmodalwidget = self then begin
  fwindow.endmodal;
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
 wrapweighting = 1;
 orthoweighting = 30;
var
 dist: integer;
 widget1: twidget;
 srect,drect: rectty;
 send,dend: integer;
 int1: integer;
 
begin
 with info do begin
  drect:= navigrect;
  srect:= startingrect;
  translatewidgetpoint1(srect.pos,nil,self);
  if direction in [gd_right,gd_left] then begin
   send:= srect.y + srect.cy;
   dend:= drect.y + drect.cy;
   result:= (drect.y + dend - srect.y - send) div 2;
   int1:= srect.y + srect.cy div 2;
   if (int1 >= drect.y) and (int1 < drect.y + drect.cy) then begin
    result:= 0;
   end;
   dist:= drect.x - srect.x;
  end
  else begin
   dend:= drect.x + drect.cx;
   result:= drect.x + srect.x;
   if (srect.x >= drect.x) and (srect.x < dend) then begin
    result:= 0;
   end;
   dist:= (drect.y + drect.cy div 2) - (srect.y + srect.cy div 2);   
  end;
  result:= abs(result) * orthoweighting;
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
      dist:= dist + width;
     end
     else begin
      dist:= dist + height;
     end;
    end;
    dist:= dist * wrapweighting;
   end;
  end;
  if dist < 0 then begin
   dist:= bigint div 2;
  end;
  result:= result + dist;
 end;
end;

function twidget.navigrect: rectty;       
begin
 result:= paintrect;
end;

function twidget.navigstartrect: rectty;      
begin
 result:= navigrect;
end;

procedure twidget.navigrequest(var info: naviginfoty);
var
 int1,int2: integer;
 widget1,widget2: twidget;
 bo1: boolean;
begin
 with info do begin
  if not down and (ow_arrowfocusout in foptionswidget) and 
                                      (fparentwidget <> nil) then begin
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
    bo1:= hastarget;
    hastarget:= false;
    if ow_arrowfocusin in widget1.foptionswidget then begin
     widget1.navigrequest(info);
    end;
    if (nearest = widget2) and not hastarget then begin
     hastarget:= true;
     int2:= widget1.navigdistance(info);
     if int2 < distance then begin
      nearest:= widget1;
      distance:= int2;
     end;
    end;
    hastarget:= hastarget or bo1;
   end;
  end;
 end;
 if canevent(tmethod(fonnavigrequest)) then begin
  fonnavigrequest(self,info);
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
    if (fparentwidget <> nil) and 
                        (self <> window.fmodalwidget) then begin
     bo1:= es_child in eventstate;
     include(eventstate,es_child);
     fparentwidget.dokeydown1(info);
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
 shiftstate1: shiftstatesty;
begin
 with info do begin
  shiftstate1:= shiftstate * shiftstatesmask;
  if not (es_processed in eventstate) then begin
   if (ow_keyreturntaborder in foptionswidget) and 
      ({(key = key_enter) or} (key = key_return)) and 
      (shiftstate1 - [ss_shift] =  []) then begin
    include(eventstate,es_processed);
    widget1:= nexttaborder(ss_shift in shiftstate1);
    if widget1 <> nil then begin
     widget1.setfocus;
    end;
   end
   else begin
    if (shiftstate1 = []) or
         (shiftstate1 = [ss_shift]) and (key = key_backtab) then begin
     include(eventstate,es_processed);
     with naviginfo do begin
      direction:= gd_none;
      case key of
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
        exclude(eventstate,es_processed);
       end;
      end;
      if direction <> gd_none then begin
       if fparentwidget <> nil then begin
        distance:= bigint;
        nearest:= nil;
        sender:= self;
        down:= false;
        startingrect:= navigstartrect;
        translatewidgetpoint1(startingrect.pos,self,nil);
        fparentwidget.navigrequest(naviginfo);
        if nearest <> nil then begin
         nearest.setfocus;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) and (fparentwidget <> nil) and
                             (self <> window.fmodalwidget) then begin
   bo1:= es_child in eventstate;
   include(eventstate,es_child);
   fparentwidget.dokeydownaftershortcut(info);
   if not bo1 then begin
    exclude(eventstate,es_child);
   end;
  end;
 end;
end;

procedure twidget.dokeydown1(var info: keyeventinfoty);
begin
 exclude(fwidgetstate1,ws1_onkeydowncalled);
 dokeydown(info);
end;

procedure twidget.internalkeydown(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  include(info.eventstate,es_preview);
  include(appinst.fstate,aps_shortcutting);
  window.fcaller:= nil;
  try
   doshortcut(info,self);
  finally
   exclude(info.eventstate,es_preview);
   exclude(appinst.fstate,aps_shortcutting);
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  dokeydown1(info);
 end;
 if not (es_processed in info.eventstate) then begin
  include(appinst.fstate,aps_shortcutting);
  try
   doshortcut(info,self);
  finally
   exclude(appinst.fstate,aps_shortcutting);
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  dokeydownaftershortcut(info);
 end;
end;

procedure twidget.dokeyup(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) and (fparentwidget <> nil) and
                             (self <> window.fmodalwidget) then begin
  fparentwidget.dokeyup(info);
 end;
end;

procedure twidget.dolayout(const sender: twidget);
begin
 if fparentwidget <> nil then begin
  fparentwidget.dolayout(sender);
 end;
end;

procedure twidget.updatecursorshape(apos: pointty);
var
 widget: twidget;
 cursor1: cursorshapety;
begin
 widget:= self;
 repeat
  cursor1:= widget.fcursor;
  if cursor1 = cr_default then begin
   cursor1:= widget.actualcursor(apos);
  end;
  addpoint1(apos,widget.fwidgetrect.pos);
  widget:= widget.fparentwidget;
 until not (cursor1 in [cr_default,cr_parent]) or (widget = nil);
 if (widget = nil) and (cursor1 in [cr_default,cr_parent]) then begin
  cursor1:= cr_arrow;
 end;
 appinst.fwidgetcursorshape:= cursor1;
end;

procedure twidget.cursorchanged;
begin
 if not (csloading in componentstate) and (appinst <> nil) and 
        checkdescendent(appinst.fclientmousewidget) then begin
  appinst.fclientmousewidget.updatecursorshape(appinst.fmousewidgetpos);
 end;
end;

procedure twidget.setcursor(const avalue: cursorshapety);
begin
 if fcursor <> avalue then begin
  fcursor:= avalue;
  cursorchanged;
 end;
end;

function twidget.actualcursor(const apos: pointty): cursorshapety;
begin
 result:= fcursor;
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
  result:= (button = mb_left) and (ws_lclicked in fwidgetstate) and
           (eventkind = ek_buttonrelease) and
      (pointinrect(pos,paintrect) or
           caption and (fframe <> nil) and fframe.pointincaption(info.pos));
 end;
end;

function twidget.isclick(const info: mouseeventinfoty): boolean;
   //true if eventtype = et_butonrelease, button is mb_left, clicked and pos in clientrect
begin
 with info do begin
  result:= (ws_lclicked in fwidgetstate) and (eventkind = ek_buttonrelease) and
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

function twidget.isleftbuttondown(const info: mouseeventinfoty;
                 const akeyshiftstate: shiftstatesty): boolean;
begin
 with info do begin
  result:= (eventkind = ek_buttonpress) and
              (button = mb_left) and pointinrect(pos,clientrect) and (
              shiftstate*keyshiftstatesmask = akeyshiftstate);
 end;
end;
{
function twidget.eatwidgetclick(var info: mouseeventinfoty;
                                  const caption: boolean = false): boolean;
begin
 result:= iswidgetclick(info,caption);
 if result then begin
  include(info.eventstate,es_processed);
 end;
end;

function twidget.eatclick(var info: mouseeventinfoty): boolean;
begin
 result:= isclick(info);
 if result then begin
  include(info.eventstate,es_processed);
 end;
end;

function twidget.eatdblclick(var info: mouseeventinfoty): boolean;
begin
 result:= isdblclick(info);
 if result then begin
  include(info.eventstate,es_processed);
 end;
end;

function twidget.eatdblclicked(var info: mouseeventinfoty): boolean;
begin
 result:= isdblclicked(info);
 if result then begin
  include(info.eventstate,es_processed);
 end;
end;

function twidget.eatleftbuttondown(var info: mouseeventinfoty): boolean;
begin
 result:= isleftbuttondown(info);
 if result then begin
  include(info.eventstate,es_processed);
 end;
end;

function twidget.eatleftbuttondown(var info: mouseeventinfoty;
                   const akeyshiftstate: shiftstatesty): boolean;
begin
 result:= isleftbuttondown(info,akeyshiftstate);
 if result then begin
  include(info.eventstate,es_processed);
 end;
end;
}
function twidget.widgetmousepos(const ainfo: mouseeventinfoty): pointty;
                                  //transaltes to widgetpos if necessary
begin
 result:= ainfo.pos;
 if es_client in ainfo.eventstate then begin
  addpoint1(result,clientwidgetpos);
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
 caller1: twidget;
begin
 if not (es_processed in info.eventstate) and 
            (fwidgetstate * [ws_visible, ws_enabled] = 
                             [ws_visible,ws_enabled]) then begin
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
   caller1:= window.fcaller;
   for int1:= 0 to widgetcount - 1 do begin
    if widgets[int1] <> caller1 then begin
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
  end;
  if not (es_processed in info.eventstate) and (sender <> nil) then begin
    //parent
   if (fparentwidget <> nil) and not (ow_nochildshortcut in foptionswidget) and 
                    (self <> fwindow.fmodalwidget) then begin
    fwindow.fcaller:= self;
    fparentwidget.doshortcut(info,sender);
   end
   else begin
    window.doshortcut(info,sender)
   end;
  end;
  if not (es_processed in info.eventstate) and canfocus and 
                                         checkfocusshortcut(info)then begin
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
var
 wi1: twidget;
begin
 wi1:= self;
 repeat
  result:= ws_enabled in wi1.fwidgetstate;
  wi1:= wi1.fparentwidget;
 until not result or (wi1 = nil);
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
 result:= ws_lclicked in fwidgetstate;
end;

function twidget.isvisible: boolean;
begin
 result:= ((ws_visible in fwidgetstate) or
           ((csdesigning in componentstate) and 
                    not (ws1_nodesignvisible in fwidgetstate1))) and 
          not (csdestroying in componentstate);
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

procedure twidget.setvisible(const avalue: boolean);
begin
 if (not (csloading in componentstate) or not avalue) and 
                                        (avalue <> getvisible) then begin
  if avalue then begin
   if parentisvisible then begin
    if window.modalfor then begin
     show(ml_window,fwindow.ftransientfor);
    end
    else begin
     show(ml_none,fwindow.ftransientfor);
    end;
   end
   else begin
    include(fwidgetstate,ws_visible);
   end;
  end
  else begin
   hide;
  end;
  if (ws1_fakevisible in fwidgetstate1) then begin
   if not updateopaque(false,true) and (fparentwidget <> nil) then begin
    fparentwidget.widgetregionchanged(self);
   end;
  end;
  visiblepropchanged;
 end
 else begin
  if avalue then begin
   include(fwidgetstate,ws_visible);
  end
  else begin
   exclude(fwidgetstate,ws_visible);
   if not (csloading in componentstate) and ownswindow and 
                    (tws_windowvisible in fwindow.fstate) then begin    
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
//   if window.focusedwidget = self then begin
   if checkdescendent(window.focusedwidget) then begin
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

function twidget.actualopaquecolor: colorty;
begin
 if (fcolor <> cl_parent) and (fcolor <> cl_default) and 
                                       (fcolor <> cl_transparent)then begin
  result:= fcolor;
 end
 else begin
  if fparentwidget <> nil then begin
   result:= fparentwidget.actualopaquecolor;
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
   result:= actualopaquecolor;
  end
  else begin
   if (fcolor <> cl_parent) and (fcolor <> cl_default) and 
                                       (fcolor <> cl_transparent) then begin
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

function twidget.canwindow: boolean; 
begin
 result:= (fwindow <> nil) and 
           not (csdestroying in fwindow.fownerwidget.componentstate) or 
       (fwindow = nil) and not (csdestroying in rootwidget.componentstate);
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
                     
function twidget.capturemouse(grab: boolean = true): boolean;
begin
 result:= false;
 if appinst <> nil then begin
  result:= appinst.fmousecapturewidget <> self;
  appinst.capturemouse(self,grab);
  include(fwidgetstate,ws_mousecaptured);
 end;
end;

procedure twidget.releasemouse(const grab: boolean = false);
begin
 if (appinst <> nil) and (appinst.fmousecapturewidget = self) then begin
  appinst.capturemouse(nil,grab);
  exclude(fwidgetstate,ws_mousecaptured);
 end;
end;

function twidget.capturekeyboard: boolean;
begin
 result:= false;
 if appinst <> nil then begin
  result:= appinst.fkeyboardcapturewidget <> self;
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
  fparentwidget.dragevent(info);
  subpoint1(info.pos,po1);
 end;
end;

procedure twidget.doscroll(const dist: pointty);
begin
 //dummy
end;

procedure twidget.scrollwidgets(const dist: pointty);
 procedure movereg(const awidget: twidget);
 var
  int1: integer;
 begin
  with awidget do begin
   if ws1_widgetregionvalid in fwidgetstate1 then begin
    regmove(fwidgetregion,dist);
   end;
   for int1:= 0 to high(fwidgets) do begin
    movereg(fwidgets[int1]);
   end;
  end;
 end;
var
 int1: integer;
 widget1: twidget;
begin
 if (dist.x <> 0) or (dist.y <> 0) then begin
  if ws1_widgetregionvalid in fwidgetstate1 then begin
   regmove(fwidgetregion,dist);
  end;
  widget1:= self;
  while not (ws_opaque in widget1.fwidgetstate) and 
                                    (widget1.parentwidget <> nil) do begin
   widget1:= widget1.parentwidget;
   exclude(widget1.fwidgetstate1,ws1_widgetregionvalid);
  end;
  for int1:= 0 to widgetcount - 1 do begin
   widget1:= fwidgets[int1];
   movereg(widget1);
   with widget1 do begin
    addpoint1(fwidgetrect.pos,dist);
    addpoint1(frootpos,dist);
    rootchanged(false);
   end;
   if appinst.fcaretwidget = widget1 then begin
    widget1.reclipcaret;
   end;
  end;
//  widgetregioninvalid;
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
  if (ow_noscroll in foptionswidget) and not (csdesigning in componentstate) or
     (tws_painting in fwindow.fstate) or
     (abs(dist.x) >= rect.cx) or (abs(dist.y) > rect1.cy) then begin
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
 if showing then begin
  window.update;
 end;
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

function twidget.getvisiblewidgets: widgetarty;
var
 int1,int2: integer;
begin
 setlength(result,length(fwidgets));
 int2:= 0;
 for int1:= 0 to high(fwidgets) do begin
  if fwidgets[int1].isvisible then begin
   result[int2]:= fwidgets[int1];
   inc(int2);
  end;
 end;
 setlength(result,int2);
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
 if result = nil then begin
//  result:= owner;
 end
 else begin
  if (csdesigning in componentstate) and 
         not(csdesigning in result.componentstate) then begin
   result:= nil; //parentwidget is designer
  end;
 end
end;

function twidget.hasparent: boolean;
begin
 result:= getparentcomponent <> nil;
end;

procedure twidget.setparentcomponent(value: tcomponent);
begin
 if value is twidget then begin
  twidget(value).insertwidget(self,fwidgetrect.pos);
 end
 else begin
//  value.insertcomponent(self);
 end;
end;

procedure twidget.setchildorder(child: tcomponent; order: integer);
//var
// comp1: tcomponent;
begin
 if not fixupsetchildorder(self,child,order) then begin
  with container do begin
   if order > high(fwidgets) then begin
    inherited setchildorder(child,order-length(fwidgets));
   end;
   if removeitem(pointerarty(fwidgets),child) >= 0 then begin
    if order < 0 then begin
     order:= 0;
    end;
    if order > length(fwidgets) then begin
     order:= length(fwidgets);
    end;
    insertitem(pointerarty(fwidgets),order,child);
   end;
  end;
 end;
end;

procedure twidget.getchildren(proc: tgetchildproc; root: tcomponent);
var
 int1: integer;
 widget: twidget;
// ev1: getchildreneventty; 
begin
 for int1:= 0 to high(fwidgets) do begin
  widget:= fwidgets[int1];
  if (ws_iswidget in widget.fwidgetstate) and
     //(
     (widget.owner = root){ or 
         bo1 and (widget.owner <> nil) and 
           (issubcomponent(widget.owner,root) or //common owner
               issubcomponent(root,widget.owner)))} then begin
   proc(widget);
  end;
 end;
end;

function twidget.getcanvas(aorigin: originty = org_client): tcanvas;
begin
 with tcanvas1(window.fcanvas) do begin
  fstate:= fstate - changedmask; //state invalid
 end; 
 result:= fwindow.fasynccanvas;
 with result do begin
  if active then begin
   reset;
   save;
  end;
  font:= getfont;
  origin:= rootpos;
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
  if ow1_fontglyphheight in foptionswidget1 then begin
   ffontheight:= getfont.glyphheight;
  end;
  if ow1_fontlineheight in foptionswidget1 then begin
   ffontheight:= getfont.lineheight;
  end;
 end;
end;

procedure twidget.setoptionswidget(const avalue: optionswidgetty);
{$ifndef FPC}
const
 mask: optionswidgetty = [ow_hinton,ow_hintoff];
{$endif}
var
 value,delta: optionswidgetty;
 opt1: optionswidget1ty;
begin
 if avalue <> foptionswidget then begin
  if csreading in componentstate then begin
   opt1:= optionswidget1;
   if ow_noautosizing in avalue then begin  //don't use deprecated flags
    opt1:= opt1 + [ow1_noautosizing];
   end;
   if ow_canclosenil in avalue then begin
    include(opt1,ow1_canclosenil);
   end;
   optionswidget1:= opt1;
  end;

  value:= optionswidgetty(setsinglebit(longword(avalue),
          longword(foptionswidget),
           {$ifdef FPC}
           longword([ow_hinton,ow_hintoff])));
           {$else}
           longword(mask)));
           {$endif}

  delta:= optionswidgetty(longword(value) xor longword(foptionswidget));
  foptionswidget:= value - deprecatedoptionswidget;
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
  {
  if delta * [ow_fontlineheight,ow_fontglyphheight] <> [] then begin
   updatefontheight;
  end;
  }
 end;
end;

procedure twidget.setoptionswidget1(const avalue: optionswidget1ty);
{$ifndef FPC}
const
 mask1: optionswidget1ty = [ow1_fontglyphheight,ow1_fontlineheight];
 mask2: optionswidget1ty = [ow1_autosizeanright,ow1_noautosizeanright];
 mask3: optionswidget1ty = [ow1_autosizeanbottom,ow1_noautosizeanbottom];
{$endif}
var
 value,delta: optionswidget1ty;
begin
{$ifdef FPC}
 value:= optionswidget1ty(setsinglebit(longword(avalue),longword(foptionswidget1),
               [longword([ow1_fontglyphheight,ow1_fontlineheight]),
                longword([ow1_autosizeanright,ow1_noautosizeanright]),
                longword([ow1_autosizeanbottom,ow1_noautosizeanbottom])]));
{$else}
 value:= optionswidget1ty(setsinglebitar16(word(avalue),word(foptionswidget1),
                                        [word(mask1),word(mask2),word(mask3)]));
{$endif}
 delta:= optionswidget1ty({$ifdef FPC}longword{$else}word{$endif}(value) xor
                    {$ifdef FPC}longword{$else}word{$endif}(foptionswidget1));
 if delta <> [] then begin
  foptionswidget1:= value;
  if delta * [ow1_fontlineheight,ow1_fontglyphheight] <> [] then begin
   updatefontheight;
  end;
  if delta * avalue * [ow1_autowidth,ow1_autoheight] <> [] then begin
   checkautosize;
  end;
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
   window.activate;
  end;
  ek_childscaled: begin
   exclude(fwidgetstate1,ws1_childscaled);
   dolayout(nil);
  end;
  ek_resize: begin
   clientsize:= addsize(clientsize,tresizeevent(event).size);
  end;
 end;
end;

procedure twidget.beforeclosequery(var amodalresult: modalresultty);
                   //called on top level window
begin
 //dummy
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
 try
  if checkdescendent(window.focusedwidget) then begin
   result:= window.focusedwidget.canclose(newfocus);
   if not result then begin
    exit;
   end;
  end;
  result:= canclose(newfocus);
 except
  result:= false;
  application.handleexception;
 end;
end;

function twidget.forceclose: boolean;
var
 bo1: boolean;
begin
 bo1:= ws1_forceclose in fwidgetstate1;
 include(fwidgetstate1,ws1_forceclose);
 try
  result:= canparentclose(nil);
 finally
  if not bo1 then begin
   exclude(fwidgetstate1,ws1_forceclose);
  end;
 end;
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
 if not (ws1_scaling in fwidgetstate1) then begin
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

function twidget.verticalfontheightdelta: boolean;
begin
 result:= false;
end;

procedure twidget.dofontheightdelta(var delta: integer);
var
 bo1: boolean;
begin
 if ow1_autoscale in foptionswidget1 then begin
  bo1:= ws1_autoscaling in fwidgetstate1;
  include(fwidgetstate1,ws1_autoscaling);
  try
   with fwidgetrect do begin
    if verticalfontheightdelta then begin
     if fanchors * [an_left,an_right] = [an_right] then begin
      setwidgetrect(makerect(x-delta,y,cx+delta,cy));
     end
     else begin
      if fanchors * [an_left,an_right] = [an_left] then begin
       bounds_cx:= cx + delta;
      end
     end;
    end
    else begin
     if fanchors * [an_top,an_bottom] = [an_bottom] then begin
      setwidgetrect(makerect(x,y-delta,cx,cy+delta));
     end
     else begin
      if fanchors * [an_top,an_bottom] = [an_top] then begin
       bounds_cy:= cy + delta;
      end;
     end;
    end;
   end;
  finally
   if not bo1 then begin
    exclude(fwidgetstate1,ws1_autoscaling);
   end;
  end;
 end;
end;

procedure twidget.postchildscaled;
begin
 if not (ws1_childscaled in fwidgetstate1) then begin
  include(fwidgetstate1,ws1_childscaled);
  if not (csloading in componentstate) then begin
   appinst.postevent(tobjectevent.create(
                                    ek_childscaled,ievent(self)),[peo_local]);
  end;
 end;
end;

procedure twidget.updatefontheight;
var
 int1: integer;
begin
 if not (csloading in componentstate) and 
      (foptionswidget1 * [ow1_fontglyphheight,ow1_fontlineheight] <> []) then begin
  int1:= ffontheight;
  if ow1_fontglyphheight in foptionswidget1 then begin
   ffontheight:= getfont.glyphheight;
  end
  else begin
   ffontheight:= getfont.lineheight;
  end; 
  if (int1 <> 0) and not (ws1_scaling in fwidgetstate1) then begin
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
  bo1:= foptionswidget1 * [ow1_fontglyphheight,ow1_fontlineheight] <> [];
 end;
 filer.DefineProperty('reffontheight',{$ifdef FPC}@{$endif}readfontheight,
           {$ifdef FPC}@{$endif}writefontheight,bo1);
end;

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
   subpoint1(po1,window1.fownerwidget.fwidgetrect.pos);
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
  if result = nil then begin
   result:= container;
   if result = self then begin
    result:= nil;
   end;
  end;
 end;
end;

procedure twidget.setdefaultfocuschild(const value: twidget);
begin
 fdefaultfocuschild:= value;
end;

function twidget.trycancelmodal(const newactive: twindow): boolean;
              //called by twindow.internalactivate, true if accepted
begin
 result:= false; 
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
 end;
end;

procedure twidget.setanchors(const Value: anchorsty);
begin
 if fanchors <> value then begin
  fanchors:= Value;
  if not (csloading in componentstate) then begin
   invalidateparentminclientsize;
   include(fwidgetstate1,ws1_anchorsetting);
   try
    parentclientrectchanged;
   finally
    exclude(fwidgetstate1,ws1_anchorsetting);
   end;
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

function twidget.getfontemptyclass: widgetfontemptyclassty;
begin
 result:= twidgetfontempty;
end;

procedure twidget.internalcreatefont;
begin
 if ffont = nil then begin
  ffont:= getfontclass.create;
 end;
 ffont.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
end;

procedure twidget.internalcreatefontempty;
begin
 if ffontempty = nil then begin
  ffontempty:= getfontemptyclass.create;
 end;
 ffontempty.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
end;

procedure twidget.syncsinglelinefontheight(const lineheight: boolean = false;
                      const space: integer = 2);
var
 int1: integer;
begin
 if lineheight then begin
  int1:= getfont.lineheight;
 end
 else begin
  int1:= getfont.glyphheight;
 end;
 if verticalfontheightdelta then begin
  if fframe = nil then begin
   bounds_cx:= bounds_cx + int1 + space - paintsize.cx
  end
  else begin
   bounds_cx:= bounds_cx + int1 + fframe.framei_left + 
              fframe.framei_right - paintsize.cx;
  end;
 end
 else begin
  if fframe = nil then begin
   bounds_cy:= bounds_cy + int1 + space - paintsize.cy
  end
  else begin
   bounds_cy:= bounds_cy + int1 + fframe.framei_top + 
              fframe.framei_bottom - paintsize.cy;
  end;
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

function twidget.isfontemptystored: Boolean;
begin
 result:= ffontempty <> nil;
end;

procedure twidget.setfont(const avalue: twidgetfont);
begin
 if avalue <> ffont then begin
  setoptionalobject(avalue,ffont,{$ifdef FPC}@{$endif}internalcreatefont);
  fontchanged;
 end;
end;

function twidget.getfontempty1: twidgetfontempty;
var
 widget1: twidget;
begin
 widget1:= self;
 repeat
  result:= widget1.ffontempty;
  if result <> nil then begin
   exit;
  end;
  widget1:= widget1.fparentwidget;
 until widget1 = nil;
{$warnings off}
 result:= twidgetfontempty(stockobjects.fonts[stf_empty]);
{$warnings on}
end;

function twidget.getfontempty: twidgetfontempty;
begin
 getoptionalobject(ffontempty,{$ifdef FPC}@{$endif}internalcreatefontempty);
 result:= getfontempty1;
end;

procedure twidget.setfontempty(const avalue: twidgetfontempty);
begin
 if avalue <> ffontempty then begin
  setoptionalobject(avalue,ffontempty,
                         {$ifdef FPC}@{$endif}internalcreatefontempty);
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
  if (componentstate*[csloading,csdestroying] = []) then begin
   clientrectchanged;
  end;
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

function twidget.getcomponentstate: tcomponentstate;
begin
 result:= componentstate;
end;

function twidget.getframestateflags: framestateflagsty;
begin
 result:= combineframestateflags(not isenabled,ws_active in fwidgetstate,
             appinst.clientmousewidget = self,ws_lclicked in fwidgetstate);
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

function twidget.getstaticframe: boolean;
begin
 result:= ws_staticframe in fwidgetstate;
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

procedure twidget.activate(const abringtofront: boolean = true;
                           const aforce: boolean = false);
begin
 if abringtofront then begin
  window.bringtofront;
 end;
 if window.modalfor then begin
  show(ml_window,window.transientfor);
 end
 else begin
  show(ml_none,window.transientfor);
 end;
 if aforce then begin
  gui_setwindowfocus(window.winid);
 end;
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

procedure twidget.setchildorder(const achildren: widgetarty); //last is top
var
 int1,int2,int3: integer;
begin
 int2:= high(fwidgets);
 for int1:= high(achildren) downto 0 do begin
  if achildren[int1] <> nil then begin
   for int3:= int2 downto 0 do begin
    if fwidgets[int3] = achildren[int1] then begin
     moveitem(pointerarty(fwidgets),int3,int2);
     dec(int2);
     break;
    end;
   end;    
  end;
 end;
 sortzorder;
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

function twidget.dofindwidget(const awidgets: widgetarty; 
                                           aname: ansistring): twidget;
var
 int1: integer;
begin
 result:= nil;
 aname:= struppercase(aname);
 for int1:= 0 to high(awidgets) do begin
  if stringicompupper(awidgets[int1].name,aname) = 0 then begin
   result:= awidgets[int1];
   break;
  end;
 end;
end;

function twidget.findwidget(const aname: ansistring): twidget;
begin
 result:= dofindwidget(container.fwidgets,aname); 
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

procedure twidget.getautocellsize(const acanvas: tcanvas;
                                      var asize: sizety);
begin
 getautopaintsize(asize);
 painttowidgetsize(asize);
end;

procedure twidget.checkautosize;
begin
 if ([csloading,csdestroying] * componentstate = []) and 
                       not (ws1_autosizing in fwidgetstate1)then begin
  include(fwidgetstate1,ws1_autosizing);
  try
   if ([ow1_autowidth,ow1_autoheight]*foptionswidget1 <> []) then begin
    internalsetwidgetrect(fwidgetrect,false);
   end
   else begin
    if fparentwidget <> nil then begin
     fparentwidget.childautosizechanged(self);
    end;
   end;
  finally
   exclude(fwidgetstate1,ws1_autosizing);
  end;
 end;
end;

procedure twidget.childautosizechanged(const sender: twidget);
begin
 //dummy
end;

procedure twidget.scale(const ascale: real);
var
 int1: integer;
 rect1: rectty;
begin
 include(fwidgetstate1,ws1_scaling);
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
  exclude(fwidgetstate1,ws1_scaling);
 end;
end;

function twidget.widgetminsize: sizety; 
begin
 result:= nullsize;
 checkwidgetsize(result);
 if fframe <> nil then begin
  fframe.checkwidgetsize(result);
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
{$ifndef FPC}
const
 mask1: optionsskinty = [osk_skin,osk_noskin];
 mask2: optionsskinty = [osk_colorcaptionframe,osk_nocolorcaptionframe];
{$endif}
var
 {opt1,opt2,}valuebefore: optionsskinty;
begin
 valuebefore:= foptionsskin;
// opt1:= optionsskinty(setsinglebit(
//                 {$ifdef FPC}longword{$else}word{$endif}(avalue),
//                 {$ifdef FPC}longword{$else}word{$endif}(foptionsskin),
//                 {$ifdef FPC}longword{$else}word{$endif}(mask1)));
// opt2:= optionsskinty(setsinglebit(
//                 {$ifdef FPC}longword{$else}word{$endif}(avalue),
//                 {$ifdef FPC}longword{$else}word{$endif}(foptionsskin),
//                 {$ifdef FPC}longword{$else}word{$endif}(mask2)));
// foptionsskin:= avalue - (mask1+mask2) + opt1*mask1 + opt2*mask2;

{$ifdef FPC}
 foptionsskin:= optionsskinty(setsinglebit(
                longword(avalue),longword(foptionsskin),
                  [longword([osk_skin,osk_noskin]),
                   longword([osk_colorcaptionframe,osk_nocolorcaptionframe])]));
{$else}
 foptionsskin:= optionsskinty(setsinglebitar16(
                  word(avalue),word(foptionsskin),
                  [word(mask1),word(mask2)]));
{$endif}
 if (optionsskinty({$ifdef FPC}longword{$else}word{$endif}(valuebefore) xor
                   {$ifdef FPC}longword{$else}word{$endif}(avalue)) * 
    [osk_nopropwidth,osk_nopropheight] <> []) and (fparentwidget <> nil) then begin
  fparentwidget.scalebasechanged(self); //for tlayouter
 end;
end;

function twidget.skininfo: skininfoty;
var
 widget1: twidget;
begin
 result:= inherited skininfo;
 if osk_container in foptionsskin then begin
  include(result.options,sko_container);
 end;
 widget1:= self;
 repeat
  result.group:= widget1.fskingroup;
  if result.group <> 0 then begin
   break;
  end;
  widget1:= widget1.parentwidget;
 until widget1 = nil;
end;

function twidget.hasskin: boolean;
begin
 result:= true;
 if not (osk_skin in foptionsskin) then begin
  if osk_noskin in foptionsskin then begin
   result:= false;
  end
  else begin
   if fparentwidget <> nil then begin
    result:= fparentwidget.hasskin;
   end;
  end;
 end;
end;

function twidget.innerclientframe: framety;
begin
 if fframe = nil then begin
  result:= nullframe;
 end
 else begin
  result:= fframe.fi.innerframe;
 end;
end;

procedure twidget.scalebasechanged(const sender: twidget);
begin
 //dummy
end;

procedure twidget.setclippedwidgetrect(arect: rectty);
var
 rect1: rectty;
begin
 if parentwidget = nil then begin
  rect1:= application.workarea(window);
  if not rectinrect(inflaterect(arect,2),rect1) then begin 
   clipinrect1(arect,rect1);
   gui_setdecoratedwindowrect(window.winid,arect,rect1);
   widgetrect:= rect1;
  end
  else begin
   widgetrect:= arect;
  end;
 end
 else begin
  clipinrect1(arect,fparentwidget.widgetsizerect);
  widgetrect:= arect;
 end;
end;

procedure twidget.dragstarted;
var
 int1: integer;
begin
 for int1:= 0 to high(fwidgets) do begin
  fwidgets[int1].dragstarted;
 end;
end;

function twidget.canmouseinteract: boolean;
begin
 result:= not (csdesigning in componentstate) or 
                                    (cssubcomponent in componentstyle);
end;

function twidget.canclose1: boolean;
begin
 result:= canclose;
end;

procedure twidget.beginupdate;
begin
 if fwidgetupdating = 0 then begin
  include(fwidgetstate,ws_loadlock);
  inc(fnoinvalidate);
 end;
 inc(fwidgetupdating);
end;

procedure twidget.endupdate;
begin
 dec(fwidgetupdating);
 if fwidgetupdating = 0 then begin
  exclude(fwidgetstate,ws_loadlock);
  dec(fnoinvalidate);
  widgetregionchanged(nil);
 end;
end;

function twidget.getzoomrefframe: framety;
begin
 result:= innerclientframe;
end;

procedure twidget.designmouseevent(var info: moeventinfoty; capture: twidget);
begin
 if fparentwidget <> nil then begin
  fparentwidget.designmouseevent(info,capture);
 end;
end;

procedure twidget.designkeyevent(const eventkind: eventkindty;
               var info: keyeventinfoty);
begin
 if fparentwidget <> nil then begin
  fparentwidget.designkeyevent(eventkind,info);
 end;
end;

function twidget.isdesignwidget: boolean;
begin
 result:= (csdesigning in componentstate) or 
                                    (ws1_designwidget in fwidgetstate1);
end;

{ twindow }

constructor twindow.create(const aowner: twidget; const agdi: pgdifunctionaty);
begin
 fgdi:= agdi;
 if fgdi = nil then begin
  fgdi:= getdefaultgdifuncs;
 end;
 fownerwidget:= aowner;
 fownerwidget.fwindow:= self;
 fcanvas:= creategdicanvas(fgdi,bmk_rgb,self,icanvas(self));
 fasynccanvas:= creategdicanvas(fgdi,bmk_rgb,self,icanvas(self));
 fscrollnotifylist:= tnotifylist.create;
 inherited create;
 fownerwidget.rootchanged(false); //nil all references
end;

destructor twindow.destroy;
begin
 include(fstate,tws_destroying);
 freeandnil(fsysdragobject);
 container:= 0;
 appinst.twindowdestroyed(self);
 if ftransientfor <> nil then begin
  dec(ftransientfor.ftransientforcount);
 end;
 if fownerwidget <> nil then begin
  fownerwidget.rootchanged(false);
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
 fownerwidget.fontcanvaschanged;
end;

procedure twindow.releaseasynccanvas;
begin
 if tws_canvasoverride in fstate then begin
  exclude(fstate,tws_canvasoverride);
  fasynccanvas.initflags(fasynccanvas);
 end;
end;

procedure twindow.setsizeconstraints(const amin,amax: sizety);
begin
 if fwindow.id <> 0 then begin
  guierror(gui_setsizeconstraints(
                    fwindow.id,amin,amax));
 end;
end;

procedure twindow.sizeconstraintschanged;
begin
 setsizeconstraints(fownerwidget.fminsize,fownerwidget.fmaxsize);
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
 event: tcreatewindowevent;
begin
 if fwindow.id = 0 then begin
  fnormalwindowrect:= fownerwidget.fwidgetrect;
  fillchar(aoptions,sizeof(aoptions),0);
  fillchar(aoptions1,sizeof(aoptions1),0);
  aoptions.groupleader:= application.mainwindow;
  aoptions.initialwindowpos:= fwindowpos;
  aoptions.transientfor:= ftransientfor;
  fownerwidget.updatewindowinfo(aoptions);
  foptions:= aoptions.options;
  fwindowpos:= aoptions.initialwindowpos;
  fwindowposbefore:= fwindowpos;
  updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
               ord(tws_needsdefaultpos),fwindowpos = wp_default);
  with aoptions do begin
   buttonendmodal:= wo_buttonendmodal in options;
   aoptions1.options:= options;
   aoptions1.pos:= fwindowpos;
   if transientfor <> ftransientfor then begin
    checkrecursivetransientfor(transientfor);
    setlinkedvar(transientfor,tlinkedobject(ftransientfor));
    if transientfor <> nil then begin
     inc(ftransientfor.ftransientforcount);
     aoptions1.transientfor:= transientfor.winid;
    end;
   end;
   aoptions1.icon:= icon;
   aoptions1.iconmask:= iconmask;
  end;
  if (aoptions.groupleader <> nil) and
          aoptions.groupleader.fownerwidget.isgroupleader then begin
   aoptions1.setgroup:= true;
   if aoptions.groupleader <> self then begin
    aoptions1.groupleader:= aoptions.groupleader.fwindow.id;
                 //do not create winid
   end;
  end;
  if application.ismainthread then begin
   fcanvas.updatewindowoptions(aoptions1);
   guierror(gui_createwindow(fownerwidget.fwidgetrect,aoptions1,fwindow),self);
  end
  else begin //needed for win32
   event:= tcreatewindowevent.create(false);
   with event do begin
    fsender:= self;
    frect:= fownerwidget.widgetrect;
    foptionspo:= @aoptions1;
    fwindowpo:= @self.fwindow;
    synchronizeevent(event);
    free;
   end;
   if fwindow.id = 0 then begin
    abort;
   end;
  end;
  sizeconstraintschanged;
  fstate:= fstate - [tws_posvalid,tws_sizevalid];
  fillchar(gc,sizeof(gcty),0);
  gc.paintdevicesize:= fownerwidget.fwidgetrect.size;
  gc.kind:= bmk_rgb; //todo: what about depht 8?
  gdierror(fcanvas.creategc(fwindow.id,gck_screen,gc),self);
  gc.paintdevicesize:= fownerwidget.fwidgetrect.size;
  fcanvas.linktopaintdevice(fwindow.id,gc{,fowner.fwidgetrect.size},nullpoint);
  gdierror(fasynccanvas.creategc(fwindow.id,gck_screen,gc),self);
  fasynccanvas.linktopaintdevice(fwindow.id,gc,{fowner.fwidgetrect.size,}nullpoint);
  if appinst <> nil then begin
   tinternalapplication(application).registerwindow(self);
  end;
  if fcaption <> '' then begin
   gui_setwindowcaption(fwindow.id,fcaption);
  end;
  fownerwidget.windowcreated;
 end
 else begin
  guierror(gue_illegalstate,self);
 end;
end;

procedure twindow.destroywindow;
begin
 releasemouse;
 if appinst <> nil then begin
  if appinst.caret.islinkedto(fcanvas) then begin
   appinst.caret.hide;
  end;
  appinst.unregisterwindow(self);
 end;
 fcanvas.unlink;
 fasynccanvas.unlink;
 if fwindow.id <> 0 then begin
  appinst.windowdestroyed(fwindow.id);
 end;
// if application.ismainthread then begin
//  if fdestroyevent <> nil then begin
//   tdestroywindowevent(fdestroyevent).fwindowpo:= nil;
//  end;
  gui_destroywindow(fwindow);
// end
// else begin
//  if fdestroyevent = nil then begin
//   fdestroyevent:= tdestroywindowevent.create(false);
//   tdestroywindowevent(fdestroyevent).fwindowpo:= @fwindow;
//   synchronizeevent(tdestroywindowevent(fdestroyevent));
//   freeandnil(fdestroyevent);
//  end;
// end;
 fillchar(fwindow,sizeof(fwindow),0);
 exclude(fstate,tws_windowvisible);
end;

procedure twindow.windowdestroyed;
begin
 fwindow.id:= 0;
 destroywindow;
end;

procedure twindow.checkwindowid;
begin
 checkwindow(false);
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
    if not windowevent and not (tws_needsdefaultpos in fstate) and
        (fmoving <= 0) and (windowpos in [wp_normal,wp_default]) then begin
     fnormalwindowrect:= fownerwidget.fwidgetrect;
    {$ifdef mse_debugconfigure}
     with fnormalwindowrect do begin
      if visible then begin
       debugwindow('*checkwin visible '+
        inttostr(x)+' '+inttostr(y)+' '+inttostr(cx)+' '+inttostr(cy)+' ',
                                                                  fwindow.id);
      end
      else begin
       debugwindow('*checkw. invis.   '+
       inttostr(x)+' '+inttostr(y)+' '+inttostr(cx)+' '+inttostr(cy)+' ',
                                                                 fwindow.id);
      end;
     end;
    {$endif}
     appinst.removewindowevents(fwindow.id,ek_configure);
     guierror(gui_reposwindow(fwindow.id,fnormalwindowrect),self);
     fstate:= fstate + [tws_posvalid,tws_sizevalid];
    end;
   end;
  end;
 end;
end;

function twindow.activating: boolean; //in internalactivate proc
begin
 result:= factivating > 0;
end;

procedure twindow.internalactivate(const windowevent: boolean;
                                                 const force: boolean = false);

 procedure setwinfoc;
 var
  window1: twindow;
  focustransientforbefore: twindow;
 begin
  focustransientforbefore:= appinst.ffocuslocktransientfor;
  if (ftransientfor <> nil) and (force or (appinst.ffocuslockwindow = nil)) and 
                                (wo_popup in foptions) then begin
   appinst.ffocuslockwindow:= self;
   window1:= ftransientfor;
   repeat
    if window1 = appinst.ffocuslocktransientfor then begin
     break;
    end;
    window1:= window1.ftransientfor;
   until window1 = nil;
   if window1 = nil then begin
    if appinst.ffocuslocktransientfor <> ftransientfor then begin
     appinst.ffocuslocktransientfor:= ftransientfor;
     exclude(appinst.fstate,aps_restorelocktransientfor);
    end;
   end;
  end
  else begin
   if not ispopup then begin
    appinst.ffocuslocktransientfor:= nil;
   end;
  end;
  if (appinst.ffocuslockwindow <> nil) and 
                          (appinst.ffocuslocktransientfor <> nil) then begin
   if (focustransientforbefore <> appinst.ffocuslocktransientfor) or
          (aps_restorelocktransientfor in appinst.fstate) then begin
    exclude(appinst.fstate,aps_restorelocktransientfor);
    guierror(gui_setwindowfocus(appinst.ffocuslocktransientfor.winid),self);
   end;
  end
  else begin
   if (appinst.ffocuslockwindow = nil) or 
                         (appinst.ffocuslockwindow = self) then begin
    guierror(gui_setwindowfocus(fwindow.id),self);
   end;
  end;
 end;
 
var
 activecountbefore: longword;
 activewindowbefore: twindow;
 widgetar: widgetarty;
 int1: integer;
 bo1: boolean;
 window1: twindow;
 widget1: twidget;
 
begin
{$ifdef mse_debugwindowfocus}
 debugwindow('*internalactivate ',fwindow.id);
 debugwrite(' modalwindow ');
 if appinst.fmodalwindow = nil then begin
  debugwriteln(' NIL');
 end
 else begin
  debugwriteln(appinst.fmodalwindow.fownerwidget.name);
 end;
{$endif}
 inc(factivating);
 try
  if appinst.finactivewindow = self then begin
   appinst.finactivewindow:= nil;
  end;
  activewindowbefore:= nil;
  setlinkedvar(appinst.factivewindow,tlinkedobject(activewindowbefore));
  show(windowevent);
  widgetar:= nil; //compilerwarning
  if activewindowbefore <> self then begin
   bo1:= force or (appinst.fmodalwindow = nil) or (appinst.fmodalwindow = self) or 
                         (ftransientfor = appinst.fmodalwindow);
   if bo1 then begin
    if hastransientfor then begin
     window1:= topmodaltransientfor;
     if window1 <> nil then begin
      window1.internalactivate(false,force);
      exit;
     end;
    end;
    if (ffocusedwidget = nil) and fownerwidget.canfocus and (ffocusing = 0) then begin
     fownerwidget.setfocus(true);
     if windowevent and force and not active then begin
      internalactivate(true,true); //call by setfocus was without force
     end;
     exit;
    end;
    if activewindowbefore <> nil then begin
     bo1:= tws_activating in activewindowbefore.fstate;
     include(fstate,tws_activating);
     try
      activewindowbefore.deactivate;
     finally
      if not bo1 and (activewindowbefore <> nil) then begin
       exclude(activewindowbefore.fstate,tws_activating);
      end;
     end;
    end;
    if appinst.factivewindow = nil then begin
     if not (ws_active in fownerwidget.fwidgetstate) then begin
      inc(factivecount);
      activecountbefore:= factivecount;
      appinst.factivewindow:= self;
      appinst.flastactivewindow:= self;
      if not (tws_activatelocked in fstate) then begin
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
      gui_setimefocus(fwindow);
      if not windowevent then begin
       setwinfoc;
      end
      else begin
       if appinst.ffocuslockwindow <> self then begin
        appinst.ffocuslockwindow:= nil;
        appinst.ffocuslocktransientfor:= nil;
       end
       else begin
        if appinst.ffocuslocktransientfor <> nil then begin
         guierror(gui_setwindowfocus(appinst.ffocuslocktransientfor.winid),self);
        end;
       end;
      end;
     end;
    end;
    appinst.fonwindowactivechangelist.dowindowchange(activewindowbefore,self);
    if activecountbefore = factivecount then begin
     if activewindowbefore = nil then begin
      widget1:= nil;
     end
     else begin
      widget1:= activewindowbefore.focusedwidget;
     end;
     appinst.fonwidgetactivechangelist.dowidgetchange(widget1,
                                                           self.focusedwidget);
    end;
   end
   else begin
    appinst.fwantedactivewindow:= self;
   end;
  end
  else begin
   setwinfoc;
  end;
 finally
  dec(factivating);
  setlinkedvar(nil,tlinkedobject(activewindowbefore));
 end;
{$ifdef mse_debugwindowfocus}
 debugwindow('-internalactivate ',fwindow.id);
{$endif}
end;

procedure twindow.noactivewidget;
var
 widget: twidget;
 activecountbefore: longword;
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
  fownerwidget.internaldodeactivate;
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
 activecountbefore: longword;
 widget1: twidget;
begin
 if appinst.ffocuslockwindow = self then begin
  appinst.ffocuslockwindow:= nil;
 end;
 if ws_active in fownerwidget.fwidgetstate then begin
  noactivewidget;
  if appinst.factivewindow = self then begin
   inc(factivecount);
   activecountbefore:= factivecount;
   if not (tws_activating in fstate) then begin
    appinst.fonwindowactivechangelist.dowindowchange(appinst.factivewindow,nil);
   end;
   if factivecount = activecountbefore then begin
    widget1:= nil;
    if appinst.factivewindow <> nil then begin
     widget1:= appinst.factivewindow.focusedwidget;
    end;
    try
     if not (tws_activating in fstate) then begin
      appinst.fonwidgetactivechangelist.dowidgetchange(widget1,nil);
     end;
    finally
     if factivecount = activecountbefore then begin
      appinst.factivewindow:= nil;
      gui_unsetimefocus(fwindow);
     end;
    end;
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
 appinst.finactivewindow:= self;
 try
  deactivate;
 finally
  if appinst.factivewindow = self then begin
   if appinst.finactivewindow = self then begin
    appinst.finactivewindow:= nil;
   end;
   result:= false;
  end
  else begin
   result:= true;
  end;
 end;
end;

procedure twindow.reactivate(const force: boolean = false); //clears appinst.finactivewindow
begin
 appinst.finactivewindow:= nil;
 activate(force);
 include(appinst.fstate,aps_needsupdatewindowstack);
end;

procedure twindow.hide(windowevent: boolean);
var
 int1,int2: integer;
 window1: twindow;
 bo1: boolean;
 mini1: boolean;
 mydesktop: integer;
begin
 releasemouse;
 fstate:= fstate - [tws_posvalid,tws_sizevalid,tws_windowshowpending];
{$ifdef mse_debugconfigure}
 if windowevent then begin
  debugwindow('*hide windowevent ',fwindow.id);
 end
 else begin
  debugwindow('*hide no windowevent ',fwindow.id);
 end;
{$endif}
 if not(ws_visible in fownerwidget.fwidgetstate) then begin
  mini1:= windowpos = wp_minimized;
  if not mini1 then begin
   exclude(fstate,tws_modalfor);
  end;
  if fwindow.id <> 0 then begin
   if tws_windowvisible in fstate then begin
    exclude(fstate,tws_transientforminimized);
    if not windowevent or (appinst.factivewindow = self) then begin
     endmodal;
    end;
    if (fsyscontainer <> sywi_none) or (fcontainer <> 0) then begin
     exclude(fstate,tws_windowvisible);
     if not windowevent then begin
      if (fsyscontainer <> sywi_none) then begin
       gui_hidesysdock(fwindow);
      end
      else begin
       gui_hidewindow(fwindow.id);
      end;
     end;
    end
    else begin
     if (application.fmainwindow = self) and not appinst.terminated then begin
      mydesktop:= gui_getwindowdesktop(fwindow.id);
      bo1:= gui_grouphideminimizedwindows;
      application.sortzorder;
      with appinst do begin
       setlength(fgroupzorder,length(fwindows));
       int2:= 0;
       for int1:= 0 to high(fwindows) do begin
        with fwindows[int1] do begin
         if (tws_windowvisible in fstate) and
          (gui_getwindowdesktop(fwindow.id) = mydesktop) then begin
                      //don't touch invisible windows or other desktops
          fgroupzorder[int2]:= fwindows[int1];
          inc(int2);
         end;
        end;
       end;
       if int2 = 1 then begin
        fgroupzorder:= nil; //only me
       end
       else begin
        setlength(fgroupzorder,int2);
       end;
      end;
      
      fstate:= fstate - [tws_windowvisible,tws_groupmaximized];
      include(fstate,tws_grouphidden);
      include(fstate,tws_groupminimized);
      if fwindowposbefore = wp_maximized then begin
       include(fstate,tws_groupmaximized);
      end;
      appinst.flockupdatewindowstack:= self; 
             //lock z-order manipulation until show

      for int1:= 0 to high(appinst.fwindows) do begin
       window1:= appinst.fwindows[int1];
      {$ifdef mse_debugwindowfocus}
       if (window1.fwindow.id <> 0) and ((window1 = self) or
                              gui_windowvisible(window1.fwindow.id)) then begin
        if window1 = self then begin
         debugwrite('* ');
        end;
        debugwindow('groupminimized ',window1.fwindow.id);
       end;
      {$endif}
       if (window1 <> self) and (window1.fwindow.id <> 0) and 
              gui_windowvisible(window1.fwindow.id) and 
              (gui_getwindowdesktop(window1.fwindow.id) = mydesktop) then begin
        with window1 do begin
         include(fstate,tws_grouphidden);
         if tws_windowvisible in fstate then begin
          include(fstate,tws_groupminimized);
         end;
         if windowpos = wp_maximized then begin
          include(fstate,tws_groupmaximized);
         end
         else begin
          exclude(fstate,tws_groupmaximized);
         end;
         gui_setwindowstate(winid,wsi_minimized,false);
         if bo1 or (wo_notaskbar in foptions) then begin
          gui_hidewindow(winid);
         end;
        end;
       end;
      end;
     {$ifdef mse_debugwindowfocus}
      for int1:= 0 to high(appinst.fgroupzorder) do begin
       debugwriteln(' groupzorder '+appinst.fgroupzorder[int1].fownerwidget.name);
      end;
     {$endif}
      if bo1 then begin
       gui_minimizeapplication;
      end;
     end
     else begin
      exclude(fstate,tws_windowvisible);
      if mini1 and (tws_modalfor in fstate) and (ftransientfor <> nil) and
               ftransientfor.visible then begin
       ftransientfor.windowpos:= wp_minimized;
       include(fstate,tws_transientforminimized);
      end;      
     end;
     if not windowevent then begin
      exclude(fstate,tws_grouphidden);
      gui_hidewindow(fwindow.id);
     end;
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
 {bo1,}bo2: boolean;
 mydesktop: integer;
begin
 if windowevent then begin
  {$ifdef mse_debugconfigure}
   debugwindow('*show windowevent ',fwindow.id);
  {$endif}
  exclude(fstate,tws_windowshowpending);
  checkwindowid; //check position
 end;
 if (ws_visible in fownerwidget.fwidgetstate) then begin
  if not visible then begin
   if not windowevent then begin
    include(fstate,tws_windowshowpending);
   end;
   include(fstate,tws_windowvisible);
   checkwindowid;
  {$ifdef mse_debugwindowfocus}
   debugwindow('*show ',fwindow.id);
  {$endif}
   with appinst do begin
    if flockupdatewindowstack = self then begin
     flockupdatewindowstack:= nil; //enable z-order handling
     fwindowstack:= nil; //remove pending    
    end;
   end;
   if (fstate * [tws_transientforminimized,tws_modalfor] = 
            [tws_transientforminimized,tws_modalfor]) and
                                     (ftransientfor <> nil) then begin
//    ftransientfor.fowner.internalshow(ml_none,nil,false,true);
    ftransientfor.fownerwidget.internalshow(ml_none,
                                    @ftransientfor.ftransientfor,false,true);
   end;    
   exclude(fstate,tws_transientforminimized);
   if not (csdesigning in fownerwidget.ComponentState) then begin
    if (fsyscontainer <> sywi_none) or (fcontainer <> 0) then begin
     if not windowevent then begin
      if (fsyscontainer <> sywi_none) then begin
       gui_showsysdock(fwindow);
      end
      else begin
       gui_showwindow(fwindow.id);
      end;
     end;
    end
    else begin
     include(appinst.fstate,aps_needsupdatewindowstack);
     if not windowevent then begin
      case fwindowpos of
       wp_maximized: begin
        size1:= wsi_maximized;
       end;
       wp_fullscreen: begin
        size1:= wsi_fullscreen;
       end;
       wp_fullscreenvirt: begin
        size1:= wsi_fullscreenvirt;
       end
       else begin
        size1:= wsi_normal;
       end;
      end;
      gui_setwindowstate(winid,size1,true);
      if (fwindowpos = wp_normal) and not (tws_needsdefaultpos in fstate) and 
                                not (wo_embedded in foptions) then begin
       gui_reposwindow(fwindow.id,fnormalwindowrect);
      end;
      fstate:= fstate-[tws_posvalid,tws_sizevalid]; 
              //possibly wrong window pos because of KDE bug with staticgravity
     end;
     exclude(fstate,tws_grouphidden);
     exclude(fstate,tws_groupminimized);
//     bo1:= gui_grouphideminimizedwindows;
     mydesktop:= gui_getwindowdesktop(fwindow.id);
     bo2:= false;
     if not ispopup and not (tws_modalfor in fstate) and
                                                  (fmodallevel = 0) then begin
      for int1:= 0 to high(appinst.fwindows) do begin
       window1:= appinst.fwindows[int1];
       if window1 <> self then begin
        with window1 do begin
         if (tws_grouphidden in fstate) and (fwindow.id <> 0) and 
                       (gui_getwindowdesktop(fwindow.id) = mydesktop) then begin
          size1:= wsi_minimized;
          if tws_groupminimized in fstate then begin
           size1:= wsi_normal;
           if tws_groupmaximized in fstate then begin
            size1:= wsi_maximized;
           end;
          end;
        {$ifdef mse_debugwindowfocus}
          debugwindow('groupshow '+
            getenumname(typeinfo(windowsizety),integer(size1))+' ',fwindow.id);
        {$endif}
          if fwindow.id <> 0 then begin
           gui_setwindowstate(fwindow.id,size1,true);
          end;
          bo2:= true;
          exclude(fstate,tws_grouphidden);
          exclude(fstate,tws_groupminimized);
         end;
        end;
       end;
      end;
     end;
     if (fwindowposbefore = wp_maximized) and 
                  (windowpos <> wp_maximized) then begin
                   //necessary for win32 show desktop
      gui_setwindowstate(winid,wsi_maximized,true);
     end;
     if {bo1 and} bo2 then begin
      window1:= nil; //compiler warning
      activate;
      with appinst do begin
       if fgroupzorder <> nil then begin
//        removeitem(pointerarty(fgroupzorder),window1);
//        additem(pointerarty(fgroupzorder),window1);
       {$ifdef mse_debuggrouprestore}
        debugwriteln('*** grouprestorezorder '+fowner.name);
       {$endif}
        flockupdatewindowstack:= nil; //enable z-order handling
        for int1:= 0 to high(fgroupzorder) do begin
         if fgroupzorder[int1] = self then begin
          moveitem(pointerarty(fgroupzorder),int1,high(fgroupzorder));
                        //probably focused, bring to front
          break;
         end;
        end;
        fwindowstack:= nil;
        setlength(fwindowstack,high(fgroupzorder));
        window1:= fgroupzorder[0]; //lowest
        for int1:= 1 to high(fgroupzorder) do begin
         if fgroupzorder[int1] = self then begin
          moveitem(pointerarty(fgroupzorder),int1,high(fgroupzorder));
                        //probably focused, bring to front
         end;
       {$ifdef mse_debuggrouprestore}
         debugwriteln(' '+inttostr(int1)+' '+window1.fowner.name+' '+
                 fgroupzorder[int1].fowner.name);
       {$endif}
         fwindowstack[int1-1].upper:= fgroupzorder[int1];
         fwindowstack[int1-1].lower:= window1;
         window1:= fgroupzorder[int1];
        end;
        include(fstate,aps_needsupdatewindowstack);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function twindow.beginmodal(const showinfo: pshowinfoty): boolean;
var
 pt1: pointty;
 event1: tmouseevent;
 win1: winidty;
 focusedwidgetbefore: twidget;
 window1: twindow;
begin
 fmodalresult:= mr_none;
 with appinst do begin
  deactivatehint;
  if (fmousecapturewidget <> nil) then begin
   fmousecapturewidget.releasemouse;
   releasemouse;
  end;
  if fmodalwindow = nil then begin
   fwantedactivewindow:= nil; //init for lowest level
  end;
  focusedwidgetbefore:= nil;
  setlinkedvar(ffocusedwidget,tmsecomponent(focusedwidgetbefore));
  try
   appinst.cursorshape:= cr_default;
   win1:= fmousewinid;
   processleavewindow;
   fmousewinid:= win1;
   result:= beginmodal(self,showinfo);
   if (fmodalwindow = nil) then begin
    if not (aps_cancelloop in appinst.fstate) then begin
     window1:= fwantedactivewindow;
     if (window1 = self) or (window1 = nil) and 
                      (focusedwidgetbefore <> nil) then begin
      focusedwidgetbefore.parentfocus;
     end;
     if appinst.active then begin
      if fwantedactivewindow <> nil then begin
       fwantedactivewindow:= nil;
       window1.activate;
      end;
     end;
    end;
   end
   else begin
    if fmodalwindow = fwantedactivewindow then begin
     fwantedactivewindow:= nil;
    end;
    if appinst.active and not (aps_cancelloop in appinst.fstate) then begin
     fmodalwindow.activate;
    end;
   end;
  finally
   setlinkedvar(nil,tmsecomponent(focusedwidgetbefore));
  end;
  if appinst.modallevel = 1 then begin
   exclude(appinst.fstate,aps_cancelloop);
  end;
  if (factivewindow <> nil) and not factivewindow.fownerwidget.releasing then begin
   pt1:= mouse.pos;
   if pointinrect(pt1,factivewindow.fownerwidget.fwidgetrect) then begin
    event1:= tmouseevent.create(factivewindow.winid,false,mb_none,mw_none,
        subpoint(pt1,factivewindow.fownerwidget.fwidgetrect.pos),
        appinst.lastshiftstate,0,false);
    try 
     appinst.processmouseevent(event1); //simulate mousemove
    finally
     event1.free1;
    end;
   end;
  end;
 end;
end;

function twindow.beginmodal: boolean; //true if destroyed
begin
 result:= beginmodal(nil);
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
 tcanvas1(fcanvas).updatesize(fownerwidget.fwidgetrect.size);
 tcanvas1(fasynccanvas).updatesize(fownerwidget.fwidgetrect.size);
 if fobjectlinker <> nil then begin
  fobjectlinker.sendevent(oe_changed);
 end;
end;

procedure twindow.wmconfigured(const arect: rectty; const aorigin: pointty);
const
 maxsizeerrorcount = 4;
var
 rect1: rectty;
begin
{$ifdef mse_debugconfigure}
 debugwindow('*wmconfigured     '+
                 inttostr(aorigin.x)+' '+inttostr(aorigin.y)+'|'+
                 inttostr(arect.x)+' '+inttostr(arect.y)+
                 ' '+inttostr(arect.cx)+' '+inttostr(arect.cy)+' ',fwindow.id);

{$endif}
 if (tws_windowshowpending in fstate) and visible and
                gui_windowvisible(fwindow.id) then begin
  exclude(fstate,tws_windowshowpending);
 end;
 rect1:= arect;
 if not (wo_embedded in foptions) then begin
  addpoint1(rect1.pos,aorigin);
 end;
 if not visible or (tws_windowshowpending in fstate) then begin 
                        //do not accept changes by hiding window (kwin bugs)
  if not rectisequal(fownerwidget.fwidgetrect,rect1) then begin
   fstate:= fstate - [tws_posvalid,tws_sizevalid];
  end;
 end
 else begin
  if (fstate*[tws_posvalid,tws_sizevalid] <> [tws_posvalid,tws_sizevalid]) and 
                                     (windowpos <> wp_maximized) then begin
   checkwindow(false);
  end
  else begin
 //  if tws_needsdefaultpos in fstate then begin
 //   fnormalwindowrect:= fowner.fwidgetrect;
 //  end;
   fstate:= (fstate + [tws_posvalid,tws_sizevalid]) - [tws_needsdefaultpos];
   if not rectisequal(rect1,fownerwidget.fwidgetrect) then begin
    if fsizeerrorcount < maxsizeerrorcount then begin
     fownerwidget.checkwidgetsize(rect1.size);
    end;
    fownerwidget.internalsetwidgetrect(rect1,true);
    if pointisequal(rect1.pos,fownerwidget.fwidgetrect.pos) then begin
     include(fstate,tws_posvalid);
    end;
    if sizeisequal(arect.size,fownerwidget.fwidgetrect.size) then begin
     include(fstate,tws_sizevalid);
     fsizeerrorcount:= 0;
    end
    else begin
     if fsizeerrorcount < maxsizeerrorcount then begin
      inc(fsizeerrorcount);
      gui_reposwindow(fwindow.id,rect1);
     end;
    end;
   end;
   fwindowposbefore:= windowpos;
   if not (fwindowposbefore in [wp_minimized]+windowmaximizedstates) then begin
    fnormalwindowrect:= fownerwidget.fwidgetrect;
   end;
  end;
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
 if (ws_visible in fownerwidget.fwidgetstate) and (fupdateregion.region <> 0) then begin
  checkwindow(false); //ev. reposition window
  fcanvas.reset;
  fcanvas.clipregion:= fupdateregion.region; //canvas owns the region
  bo1:= appinst.caret.islinkedto(fcanvas) and
   testintersectrect(fcanvas.clipbox,appinst.caret.rootcliprect);
  if bo1 then begin
   tcaret1(appinst.fcaret).remove;
  end;
  include(fstate,tws_painting);
  if flushgdi then begin
   try
    fupdateregion.region:= 0;
    result:= true;
    fownerwidget.paint(fcanvas);
   finally
    if bo1 then begin
     tcaret1(appinst.fcaret).restore;
    end;
    fcanvas.endpaint;
   end;
  end
  else begin
   bmp:= tbitmap.create(bmk_rgb,fgdi);
   try
    if intersectrect(fcanvas.clipbox,
            makerect(nullpoint,fownerwidget.widgetrect.size),rect1) then begin
     bmp.size:= rect1.size;
     bmp.canvas.clipregion:= bmp.canvas.createregion(fupdateregion.region);
     po1.x:= -rect1.x;
     po1.y:= -rect1.y;
     tcanvas1(bmp.canvas).setcliporigin(po1);
     bmp.canvas.origin:= nullpoint;
     fupdateregion.region:= 0;
     result:= true;
     fownerwidget.paint(bmp.canvas);
     bmp.paint(fcanvas,rect1);
    end
    else begin
     fupdateregion.region:= 0;
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
 info: moeventinfoty;
begin
 info.mouse:= appinst.fmouseparkeventinfo;
 info.mouse.eventkind:= ek_mousepark;
 exclude(info.mouse.eventstate,es_processed);
 dispatchmouseevent(info,appinst.fmousecapturewidget);
end;

procedure twindow.checkmousewidget(const info: mouseeventinfoty;
                                                    var capture: twidget);
begin
 if capture = nil then begin
  capture:= fownerwidget.mouseeventwidget(info);
  if (fmodalwidget <> nil) and 
          not fmodalwidget.checkdescendent(capture) then begin
   capture:= fmodalwidget;
  end;
  if (capture = nil) and (tws_grab in fstate) then begin
   capture:= fmodalwidget;
   if capture = nil then begin
    capture:= fownerwidget;
   end;
  end;
 end;
 appinst.setmousewidget(capture);
end;

procedure twindow.dispatchmouseevent(var info: moeventinfoty;
                   capture: twidget);
var
 posbefore,absposbefore: pointty;
 mousecapturewidgetbefore: twidget;
 int1: integer;
 po1: peventaty;
 self1: tlinkedobject;
begin
 if not (es_designcall in info.mouse.eventstate) then begin 
                       //no "inherited" call from designmouseevent
  if info.mouse.eventkind = ek_mousewheel then begin
   capture:= fownerwidget.mouseeventwidget(info.mouse);
   if (capture = nil) and (ftransientfor <> nil) then begin
    include(info.mouse.eventstate,es_transientfor);
    subpoint1(info.mouse.pos,subpoint(
                             ftransientfor.fownerwidget.pos,fownerwidget.pos));
    ftransientfor.dispatchmouseevent(info,capture);
    exit;
   end;
  end
  else begin
   checkmousewidget(info.mouse,capture);
  end;
 end;
 if capture <> nil then begin
  if not (es_designcall in info.mouse.eventstate) and 
                                    capture.isdesignwidget() then begin
   include(info.mouse.eventstate,es_designcall);
   capture.designmouseevent(info,capture);
   exclude(info.mouse.eventstate,es_designcall);
   if es_processed in info.mouse.eventstate then begin
    exit;
   end;
  end;
  mousecapturewidgetbefore:= appinst.fmousecapturewidget;
  if (info.mouse.eventkind = ek_buttonpress) and 
         (tws_buttonendmodal in fstate) and (fmodalwidget = capture) then begin
   endmodal;
  end
  else begin
   self1:= nil;
   setlinkedvar(self,self1); //for destroy check
   with capture do begin
    absposbefore:= info.mouse.pos;
    subpoint1(info.mouse.pos,rootpos);
    posbefore:= info.mouse.pos;
    appinst.fmousewidgetpos:= posbefore;
    appinst.fdelayedmouseshift:= nullpoint;
    if info.mouse.eventkind = ek_mousewheel then begin
     mousewheelevent(info.wheel);
    end
    else begin
     mouseevent(info.mouse);
     if self1 = nil then begin
      exit;
     end;
     if (info.mouse.eventkind = ek_buttonpress) and ispopup and
      (ow_mousefocus in self.fownerwidget.foptionswidget) then begin
      activate; //possibly not done by windowmanager
     end;
    end;
    if self1 = nil then begin
     exit;
    end;
    posbefore:= subpoint(info.mouse.pos,posbefore);
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
   with info.mouse do begin
    if (eventkind = ek_buttonrelease) and 
      (appinst.fmousecapturewidget = nil) and 
                     (mousecapturewidgetbefore <> nil) then begin
     exclude(eventstate,es_processed);
     eventkind:= ek_mousemove;
     pos:= addpoint(absposbefore,posbefore);
     dispatchmouseevent(info,nil);  //immediate mouseenter
     eventkind:= ek_buttonrelease;
    end;
   end;
   if self1 = nil then begin
    exit;
   end;
   setlinkedvar(nil,self1);
  end;
  {
 end
 else begin
  if (info.mouse.eventkind = ek_buttonpress) and 
                            (tws_buttonendmodal in fstate) then begin
   endmodal;
  end;
  }
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
  if widget1.isdesignwidget() then begin
   widget1.designkeyevent(eventkind,info);
   if es_processed in info.eventstate then begin
    exit;
   end;
  end;
  case eventkind of
   ek_keypress: widget1.internalkeydown(info);
   ek_keyrelease: widget1.dokeyup(info);
  end;
 end
 else begin
  if eventkind = ek_keypress then begin
   include(info.eventstate,es_preview);
   try
    doshortcut(info,fownerwidget);
   finally
    exclude(info.eventstate,es_preview);
   end;
   doshortcut(info,fownerwidget);
  end;
 end;
end;

procedure twindow.setfocusedwidget(const widget: twidget);
var
 focuscountbefore: longword;
 focusedwidgetbefore: twidget;
 widget1: twidget;
 widgetar: widgetarty;
 int1,int2: integer;
 bo1: boolean;
begin
 widgetar:= nil; //compiler warning
 if (ffocusedwidget <> widget) and ((fmodalwidget = nil) or (widget = nil) or
                           fmodalwidget.checkdescendent(widget)) then begin
  if widget <> nil then begin
   inc(ffocusing);
  end;
  try
   inc(ffocuscount);
   focuscountbefore:= ffocuscount;
   focusedwidgetbefore:= nil;
   setlinkedvar(ffocusedwidget,tmsecomponent(focusedwidgetbefore));
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
     fenteredwidget:= widget1.fparentwidget;
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
     widget1:= fenteredwidget;
    end;
   end;
   if (widget <> nil) and not widget.canfocus then begin
    exit;
   end;
   ffocusedwidget:= widget;
   if widget <> nil then begin
    widgetar:= widget.getrootwidgetpath; //new focus
    int2:= length(widgetar);
    if widget1 <> nil then begin
     if widget1.checkancestor(fenteredwidget) then begin
      widget1:= fenteredwidget;
     end;
     for int1:= 0 to high(widgetar) do begin
      if widgetar[int1] = widget1 then begin
       int2:= int1;    //common ancestor
       break;
      end;
     end;
    end;
    bo1:= appinst.factivewindow = self;
    for int1:= int2-1 downto 0 do begin
     fenteredwidget:= widgetar[int1];
     fenteredwidget.internaldoenter;
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
   end
   else begin
    fenteredwidget:= nil;
   end;
   fownerwidget.dofocuschanged(focusedwidgetbefore,ffocusedwidget);
   if (appinst.factivewindow = self) and 
                              (focuscount = focuscountbefore) then begin
    appinst.fonwidgetactivechangelist.dowidgetchange(
                                focusedwidgetbefore,ffocusedwidget);
   end;
  finally
   if widget <> nil then begin
    dec(ffocusing);
   end;
   setlinkedvar(nil,tmsecomponent(focusedwidgetbefore));
  end;
 end;
end;

procedure twindow.invalidaterect(const arect: rectty;
                                         const sender: twidget = nil);
var
 rect1: rectty;
begin
 if (arect.cx > 0) or (arect.cy > 0) then begin
  rect1:= intersectrect(arect,mr(nullpoint,fownerwidget.fwidgetrect.size));
  if (sender <> nil) and (sender.fparentwidget <> nil) then begin
   rect1:= intersectrect(rect1,moverect(sender.fparentwidget.paintrect,
                                        sender.fparentwidget.rootpos));
  end;
  if fupdateregion.region = 0 then begin
   fupdateregion:= createregion(rect1,fgdi);
  end
  else begin
   regaddrect(fupdateregion,rect1);
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
   if fmodallevel > 0 then begin
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
   fcaller:= nil;
   fownerwidget.doshortcut(info,nil);
  end;
 end;
end;

procedure twindow.gcneeded(const sender: tcanvas);
begin
 createwindow;
end;
{
function twindow.getmonochrome: boolean;
begin
 result:= false;
end;
}
function twindow.getkind: bitmapkindty;
begin
 result:= bmk_rgb;
end;

procedure twindow.update;
var
 int1: integer;
 event: twindowrectevent;
begin
 if appinst <> nil then begin
  if appinst.ismainthread() then begin //avoid possible deadlock in getevents()
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
  end;
  internalupdate;
  gui_flushgdi;
 end;
end;

procedure twindow.movewindowrect(const dist: pointty; const rect: rectty);
begin
 tcanvas1(fcanvas).movewindowrect(dist,rect);
// gui_movewindowrect(fwindow.id,dist,rect);
end;

function twindow.getsize: sizety;
begin
 result:= fownerwidget.getsize;
end;

function twindow.close: boolean;
begin
 if fmodalresult = mr_none then begin
  fmodalresult:= mr_windowclosed;
 end;
 fownerwidget.beforeclosequery(fmodalresult);
 result:= (fmodalresult <> mr_none) and fownerwidget.canparentclose(nil);
 if result then begin
  deactivate;
  fownerwidget.hide;
  destroywindow;
 end
 else begin
  fmodalresult:= mr_none;
 end;
end;

procedure twindow.bringtofront();
var
 int1: integer;
begin
{$ifdef mse_debugzorder}
 debugwriteln('****bringtofront**** "'+fownerwidget.name+'"');
{$endif}
 with appinst do begin
  for int1:= high(fwindowstack) downto 0 do begin
   if fwindowstack[int1].lower = self then begin
    deleteitem(fwindowstack,typeinfo(windowstackinfoarty),int1);
   end;
  end;
  gui_raisewindow(winid);
  include(fstate,aps_needsupdatewindowstack);
 end;
end;

procedure twindow.sendtoback();
var
 int1: integer;
begin
{$ifdef mse_debugzorder}
 debugwriteln('****sendtoback**** "'+fownerwidget.name+'"');
{$endif}
 with appinst do begin
  for int1:= high(fwindowstack) downto 0 do begin
   if fwindowstack[int1].upper = self then begin
    deleteitem(fwindowstack,typeinfo(windowstackinfoarty),int1);
   end;
  end;
  gui_lowerwindow(winid);
  include(fstate,aps_needsupdatewindowstack);
 end;
end;

procedure twindow.bringtofrontlocal;
begin
{$ifdef mse_debugzorder}
 debugwriteln('****bringtofrontlocal**** "'+fownerwidget.name+'"');
{$endif}
 include(fstate,tws_raise);
 exclude(fstate,tws_lower);
 include(appinst.fstate,aps_needsupdatewindowstack);
end;

procedure twindow.sendtobacklocal;
begin
{$ifdef mse_debugzorder}
 debugwriteln('****sendtobacklocal**** "'+fownerwidget.name+'"');
{$endif}
 include(fstate,tws_lower);
 exclude(fstate,tws_raise);
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

function twindow.stackedover(const avisible: boolean = false): twindow; //nil if top
var
 ar1: windowarty;
 int1,int2: integer;
begin
 appinst.sortzorder;
 ar1:= appinst.windowar;
 result:= nil;
 int2:= -1;
 for int1:= high(ar1) downto 1 do begin
  if ar1[int1] = self then begin
   int2:= int1-1;
   break;
  end;
 end;
 if int2 >= 0 then begin
  if avisible then begin
   for int1:= int2 downto 0 do begin
    if ar1[int1].visible then begin
     result:= ar1[int1];
     break;
    end;
   end;
  end
  else begin
   result:= ar1[int2];
  end;
 end;
end;

function twindow.stackedunder(const avisible: boolean = false): twindow;
                                            //nil if bottom
var
 ar1: windowarty;
 int1,int2: integer;
begin
 appinst.sortzorder;
 ar1:= appinst.windowar;
 result:= nil;
 int2:= -1;
 for int1:= 0 to high(ar1)-1 do begin
  if ar1[int1] = self then begin
   int2:= int1+1;
   break;
  end;
 end;
 if int2 >= 0 then begin
  if avisible then begin
   for int1:= int2 to high(ar1) do begin
    if ar1[int1].visible then begin
     result:= ar1[int1];
     break;
    end;
   end;
  end
  else begin
   result:= ar1[int2];
  end;
 end;
end;

function twindow.hastransientfor: boolean;
begin
 result:= ftransientforcount > 0;
end;

function twindow.istransientfor(const base: twindow): boolean;
var 
 w1: twindow;
begin
 result:= ftransientfor <> nil;
 if result and (base <> nil) then begin
  w1:= ftransientfor;
  while w1 <> nil do begin
   if w1 = base then begin
    exit;
   end;
   w1:= w1.ftransientfor;
  end;
  result:= false;
 end;
end;

function twindow.capturemouse: boolean;
begin
 result:= not (tws_grab in fstate);
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

function twindow.mousecaptured: boolean;
begin
 result:= tws_grab in fstate;
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

procedure twindow.settransientfor(const Value: twindow;
                                                 const windowevent: boolean);
begin
 if not windowevent then begin
  if value = nil then begin
   exclude(fstate,tws_modalfor);
  end;
  if ftransientfor <> value then begin
   checkrecursivetransientfor(value);
   if ftransientfor <> nil then begin
    dec(ftransientfor.ftransientforcount);
   end;
   setlinkedvar(value,tlinkedobject(ftransientfor));
   if ftransientfor <> nil then begin
    inc(ftransientfor.ftransientforcount);
   end;
   include(appinst.fstate,aps_needsupdatewindowstack);
   if fwindow.id <> 0 then begin
    if value <> nil then begin
     gui_settransientfor(fwindow,value.winid);
    end
    else begin
     gui_settransientfor(fwindow,0);
    end;
   end;
  end;
 end;
end;

function twindow.winid: winidty;
begin
 checkwindowid;
 result:= fwindow.id;
end;

procedure twindow.hidden;
begin
 if tws_windowvisible in fstate then begin
  fownerwidget.internalhide(true);
 end;
end;

procedure twindow.showed;
var
 wi1: twindow;
begin
 exclude(fstate,tws_windowshowpending);
 if not (tws_windowvisible in fstate) then begin
  wi1:= nil;
  fownerwidget.internalshow(ml_none,@wi1,true,true);
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
 result:= (appinst <> nil) and (appinst.fmodalwindow = nil) or 
                                             (appinst.fmodalwindow = self);
end;

procedure twindow.activate(const force: boolean = false);
begin
 if fownerwidget.visible and (force or not active) then begin
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
var
 widget1: twidget;
begin
 if fmodalwidget = widget then begin
  fmodalwidget:= nil;
 end;
 if ffocusedwidget = widget then begin
  widget1:= widget;
  repeat 
   widget1:= widget1.parentwidget;
  until (widget1 = nil) or widget1.canfocus;
  setfocusedwidget(widget1);
 end;
end;

function twindow.state: windowstatesty;
begin
 result:= fstate;
end;

procedure twindow.registermovenotification(sender: iobjectlink);
begin
 getobjectlinker.link(iobjectlink(self),sender);
end;

procedure twindow.unregistermovenotification(sender: iobjectlink);
begin
 if (self <> nil) and (fobjectlinker <> nil) then begin
  fobjectlinker.unlink(iobjectlink(self),sender);
 end;
end;

function twindow.close(const amodalresult: modalresultty): boolean; 
                            //true if ok
begin
 fmodalresult:= amodalresult;
 result:= false;
 if (amodalresult <> mr_none) {and (tws_modal in fstate)} then begin
  result:= close();
 end;
end;

procedure twindow.setmodalresult(const Value: modalresultty);
begin
 fmodalresult:= Value;
 if (value <> mr_none) {and (tws_modal in fstate)} then begin
  close();
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
 updatebit({$ifdef FPC}longword{$else}
              longword{$endif}(fstate),ord(tws_globalshortcuts),value);
end;

function twindow.getlocalshortcuts: boolean;
begin
 result:= tws_globalshortcuts in fstate;
end;

procedure twindow.setlocalshortcuts(const Value: boolean);
begin
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
                        ord(tws_localshortcuts),value);
end;

function twindow.visible: boolean;
begin
 result:= fownerwidget.visible and (tws_windowvisible in fstate) and
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
 if fwindow.id = 0 then begin
  result:= fwindowpos;
 end
 else begin
  inc(fmoving);
  asize:= gui_getwindowsize(winid);
  dec(fmoving);
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
   wsi_fullscreenvirt: begin
    result:= wp_fullscreenvirt;
   end;
   else begin //wsi_normal
    if fwindowpos in 
           [wp_minimized,wp_screencentered]+windowmaximizedstates then begin
     result:= wp_normal;
    end
    else begin
     result:= fwindowpos;
    end;
   end;
  end;
 end;
end;

procedure twindow.setwindowpos(const Value: windowposty);
var
 rect1,rect2: rectty;
 bo1: boolean;
 wpo1: windowposty;
 window1: twindow;
begin
 wpo1:= getwindowpos;
 if wpo1 <> value then begin
  bo1:= (tws_windowvisible in fstate) {or (wpo1 = wp_minimized)};
  window1:= nil;
  if value in [wp_screencentered] then begin
   window1:= transientfor;
   if window1 = nil then begin
    window1:= appinst.activewindow;
    if window1 = nil then begin
     window1:= self;
    end;
   end;
  end;
  case value of
   wp_screencentered,wp_screencenteredvirt: begin
    checkwindowid;
    rect1:= fnormalwindowrect;
    gui_setwindowstate(winid,wsi_normal,bo1);
    if value = wp_screencenteredvirt then begin
     rect2:= appinst.screenrect(nil);
    end
    else begin
     rect2:= appinst.workarea(window1);
    end;
    with fownerwidget do begin
     rect1.x:= rect2.x + (rect2.cx - rect1.cx) div 2;
     rect1.y:= rect2.y + (rect2.cy - rect1.cy) div 2;
     widgetrect:= rect1;
    end;
   end;
   wp_minimized: begin
    gui_setwindowstate(winid,wsi_minimized,bo1);
   end;
   wp_maximized: begin
    gui_setwindowstate(winid,wsi_maximized,bo1);
   end;
   wp_fullscreen: begin
    gui_setwindowstate(winid,wsi_fullscreen,bo1);
   end;
   wp_fullscreenvirt: begin
    gui_setwindowstate(winid,wsi_fullscreenvirt,bo1);
   end
   else begin
    gui_setwindowstate(winid,wsi_normal,bo1);
   end;
  end;
 end;
 fwindowpos:= value;
 fwindowposbefore:= fwindowpos;
 if (wpo1 in [wp_fullscreen,wp_fullscreenvirt]) and 
                                (value = wp_normal) then begin
  gui_reposwindow(fwindow.id,fnormalwindowrect);
       //needed for win32
 end;
end;

function twindow.updaterect: rectty;
begin
 result:= fcanvas.regionclipbox(fupdateregion.region);
end;

function twindow.defaulttransientfor: twindow;
begin
 result:= nil;
 if appinst.fmodalwindow = nil then begin
  if appinst.fwantedactivewindow <> nil then begin
   result:= appinst.fwantedactivewindow;
  end
  else begin
   result:= appinst.factivewindow;
  end;
 end
 else begin
  result:= appinst.fmodalwindow;
 end;
 if result = self then begin
  result:= nil;
 end;
end;

function twindow.ispopup: boolean;
begin
 result:= wo_popup in foptions;
end;

procedure twindow.postkeyevent(const akey: keyty; 
       const ashiftstate: shiftstatesty = []; const release: boolean = false;
       const achars: msestring = '');
begin
 application.postevent(tkeyevent.create(winid,release,akey,akey,
             ashiftstate,achars,timestamp));
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

function twindow.getdecoratedwidgetrect: rectty;
begin
 guierror(gui_getdecoratedwindowrect(winid,result));
end;

procedure twindow.setdecoratedwidgetrect(const avalue: rectty);
var
 rect1: rectty;
begin
 guierror(gui_setdecoratedwindowrect(winid,avalue,rect1));
end;

function twindow.getdecoratedpos: pointty;
begin
 result:= decoratedwidgetrect.pos;
end;

procedure twindow.setdecoratedpos(const avalue: pointty);
var
 rect1: rectty;
begin
 rect1:= decoratedwidgetrect;
 rect1.pos:= avalue;
 decoratedwidgetrect:= rect1;
end;

function twindow.getdecoratedsize: sizety;
begin
 result:= decoratedwidgetrect.size;
end;

procedure twindow.setdecoratedsize(const avalue: sizety);
var
 rect1: rectty;
begin
 rect1:= decoratedwidgetrect;
 rect1.size:= avalue;
 decoratedwidgetrect:= rect1;
end;

function twindow.getdecoratedbounds_x: integer;
begin
 result:= decoratedwidgetrect.x;
end;

procedure twindow.setdecoratedbounds_x(const avalue: integer);
var
 rect1: rectty;
begin
 rect1:= decoratedwidgetrect;
 rect1.x:= avalue;
 decoratedwidgetrect:= rect1;
end;

function twindow.getdecoratedbounds_y: integer;
begin
 result:= decoratedwidgetrect.y;
end;

procedure twindow.setdecoratedbounds_y(const avalue: integer);
var
 rect1: rectty;
begin
 rect1:= decoratedwidgetrect;
 rect1.y:= avalue;
 decoratedwidgetrect:= rect1;
end;

function twindow.getdecoratedbounds_cx: integer;
begin
 result:= decoratedwidgetrect.cx;
end;

procedure twindow.setdecoratedbounds_cx(const avalue: integer);
var
 rect1: rectty;
begin
 rect1:= decoratedwidgetrect;
 rect1.cx:= avalue;
 decoratedwidgetrect:= rect1;
end;

function twindow.getdecoratedbounds_cy: integer;
begin
 result:= decoratedwidgetrect.cy;
end;

procedure twindow.setdecoratedbounds_cy(const avalue: integer);
var
 rect1: rectty;
begin
 rect1:= decoratedwidgetrect;
 rect1.cy:= avalue;
 decoratedwidgetrect:= rect1;
end;

procedure twindow.setcontainer(const avalue: winidty);
begin
 syscontainer:= sywi_none;
 if fcontainer <> 0 then begin
  application.unregisteronwiniddestroyed({$ifdef FPC}@{$endif}containerwindestroyed);
 end;
 fcontainer:= avalue;
 if fcontainer <> 0 then begin
  application.registeronwiniddestroyed({$ifdef FPC}@{$endif}containerwindestroyed);
  try
   include(foptions,wo_embedded);
   guierror(gui_reparentwindow(winid,fcontainer,fownerwidget.pos));
  except
   container:= 0;
   raise;
  end;
 end
 else begin
  exclude(foptions,wo_embedded);
  if (fwindow.id <> 0) and not (tws_destroying in fstate) then begin
   guierror(gui_reparentwindow(winid,0,fownerwidget.pos));
  end;
 end;
end;

procedure twindow.containerwindestroyed(const aid: winidty);
begin
 if aid = fcontainer then begin
  container:= 0;
 end;
end;

procedure twindow.setsyscontainer(const avalue: syswindowty);
begin
 if avalue <> fsyscontainer then begin
  if (fsyscontainer <> sywi_none) and (fwindow.id <> 0) then begin
   gui_docktosyswindow(fwindow,sywi_none);
   fsyscontainer:= sywi_none;
   container:= 0;
  end;
  if avalue <> sywi_none then begin
   if fwindow.id = 0 then begin
    createwindow;
   end;
   include(foptions,wo_embedded); 
   guierror(gui_docktosyswindow(fwindow,avalue));
   fsyscontainer:= avalue;
  end;
 end;
end;

function twindow.getscreenpos: pointty;
var
 rect1: rectty;
begin
 if not (wo_embedded in foptions) then begin
  result:= fownerwidget.pos;
 end
 else begin
  guierror(gui_getwindowrect(winid,rect1));
  result:= rect1.pos;
 end;
end;

procedure twindow.setscreenpos(const avalue: pointty);
var
 pt1: pointty;
begin
 if not (wo_embedded in foptions) then begin
  fownerwidget.pos:= avalue;
 end
 else begin
  pt1:= screenpos;
  pt1.x:= avalue.x - pt1.x + fownerwidget.bounds_x;
  pt1.y:= avalue.y - pt1.y + fownerwidget.bounds_y;
  fownerwidget.pos:= pt1;
 end;
end;

function twindow.modal: boolean;
begin
 result:= fmodallevel > 0;
end;

function twindow.modalwindowbefore: twindow;
begin
 result:= nil;
 if fmodalinfopo <> nil then begin
  result:= fmodalinfopo^.modalwindowbefore;
 end;
end;

function twindow.getmodalfor: boolean;
begin
 result:= tws_modalfor in fstate;
end;

function twindow.topmodaltransientfor: twindow;
var
 int1: integer;
 window1,window2: twindow;
begin
 result:= nil;
 with appinst do begin
  window1:= self;
  while (window1 <> nil) and window1.hastransientfor do begin
   window2:= nil;
   for int1:= 0 to high(fwindows) do begin
    if fwindows[int1].ftransientfor = window1 then begin
     window2:= fwindows[int1];
     if tws_modalfor in window2.fstate then begin
      result:= window2;
     end;
     if window2 = self then begin
      window2:= nil; //recursion
     end;
     break;
    end;
   end;
   window1:= window2;
  end;
 end;
end;

function twindow.transientforstackactive: boolean;
var
 window1,window2: twindow;
begin
 result:= false;
 window1:= appinst.activewindow;
 window2:= window1;
 if (window1 <> nil) and (window1.ftransientfor <> nil) then begin 
  while window1 <> nil do begin
   if window1 = self then begin
    result:= true;
    break;
   end;
   window1:= window1.ftransientfor;
  end;
 end;
 if ftransientfor <> nil then begin
  window1:= self;
  while window1 <> nil do begin
   if window1 = window2 then begin
    result:= true;
    break;
   end;
   window1:= window1.ftransientfor;
  end;
 end;
end;

procedure twindow.getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
begin
 //dummy
end;

procedure twindow.processsysdnd(const event: twindowevent);
var
 wi1: twidget;
// obj1: tsysmimedragobject;
 info: draginfoty;
 bo1: boolean;
begin
 if wo_sysdnd in foptions then begin
  with tsysdndevent(event) do begin
   if fdndkind = dek_leavesysdnd then begin
    freeandnil(fsysdragobject);
   end
   else begin
    subpoint1(fpos,fownerwidget.pos);
    wi1:= fownerwidget.widgetatpos(fpos,[ws_visible,ws_enabled]);
    if (wi1 = nil) and 
         (fownerwidget.fwidgetstate*[ws_visible,ws_enabled] = 
                                        [ws_visible,ws_enabled]) then begin
     wi1:= fownerwidget;
    end;
    if wi1 <> nil then begin
     if fsysdragobject = nil then begin
      tsysmimedragobject.create(nil,tdragobject(fsysdragobject),nullpoint,
                                      fformats,fformatistext,factions);
     end;
     with tsysmimedragobject1(fsysdragobject) do begin
      if (fformats <> tsysdndevent(event).fformats) or
         (fformatistext <> tsysdndevent(event).fformatistext) or
                                (fformatindex > high(fformats)) then begin
                                //missed dek_leave
       fformats:= tsysdndevent(event).fformats;
       fformatistext:= tsysdndevent(event).fformatistext;
       fformatindex:= -1;
      end;
      factions:= tsysdndevent(event).factions;
     end;
     fillchar(info,sizeof(info),0);
     with info do begin
      eventkind:= fdndkind;
      pos:= translateclientpoint(fpos,owner,wi1);
      dragobjectpo:= @fsysdragobject;
     end;
     try
      wi1.dragevent(info);
     finally
      if fdndkind = dek_drop then begin
       gui_sysdnd(sdnda_finished,isysdnd(tsysmimedragobject(fsysdragobject)),
                                                                   nullrect,bo1);      
      end
      else begin
       if info.accept then begin
        gui_sysdnd(sdnda_accept,isysdnd(tsysmimedragobject(fsysdragobject))
                                                                 ,nullrect,bo1);
       end
       else begin
        gui_sysdnd(sdnda_reject,isysdnd(tsysmimedragobject(fsysdragobject)),
                                                                   nullrect,bo1);
       end;
      end;
 //     obj1.free;
     end;
    end;
   end;
  end;
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

{ tonwidgetchangelist}

procedure tonwidgetchangelist.dowidgetchange(const oldwidget,newwidget: twidget);
begin
 factitem:= 0;
 while factitem < fcount do begin
  widgetchangeeventty(getitempo(factitem)^)(oldwidget,newwidget);
  inc(factitem);
 end;
end;

{ tonwindowchangelist}

procedure tonwindowchangelist.dowindowchange(const oldwindow,newwindow: twindow);
begin
 factitem:= 0;
 while factitem < fcount do begin
  windowchangeeventty(getitempo(factitem)^)(oldwindow,newwindow);
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

{ tonhelpeventlist }

procedure tonhelpeventlist.doevent (const sender: tmsecomponent);
var
 bo1: boolean;
begin
 factitem:= 0;
 bo1:= false;
 while (factitem < fcount) and not bo1 do begin
  helpeventty(getitempo(factitem)^)(sender,bo1);
  inc(factitem);
 end;
end;

{ tonsyseventlist }

procedure tonsyseventlist.doevent(const awindow: winidty; 
                               var aevent: syseventty; var handled: boolean);
//var
// bo1: boolean;
begin
 factitem:= 0;
 while (factitem < fcount) and not handled do begin
  syseventhandlereventty(getitempo(factitem)^)(awindow,aevent,handled);
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
  const rect: rectty; const aorigin: pointty);
begin
 inherited create(akind,winid);
 frect:= rect;
 forigin:= aorigin;
end;

{ tmouseevent }

constructor tmouseevent.create(const winid: winidty; const release: boolean;
                      const button: mousebuttonty; const wheel: mousewheelty;
                      const pos: pointty; const shiftstate: shiftstatesty;
                      atimestamp: longword; const reflected: boolean = false);
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
                  const chars: msestring; const atimestamp: longword);
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
 ftimestamp:= atimestamp;
end;

{ tinternalapplication }

constructor tinternalapplication.create(aowner: tcomponent);
begin
 appinst:= self;
// inherited;
 fdblclicktime:= defaultdblclicktime;
// inherited;
 fonkeypresslist:= tonkeyeventlist.create;
 fonshortcutlist:= tonkeyeventlist.create;
 fonwidgetactivechangelist:= tonwidgetchangelist.create;
 fonwindowactivechangelist:= tonwindowchangelist.create;
 fonwindowdestroyedlist:= tonwindoweventlist.create;
 fonwiniddestroyedlist:= tonwinideventlist.create;
 fonapplicationactivechangedlist:= tonapplicationactivechangedlist.create;
 fonhelp:= tonhelpeventlist.create;
 fonsyseventlist:= tonsyseventlist.create;
// fwindows:= tpointerlist.create;
 fcaret:= tcaret.create;
 fmouse:= tmouse.create(imouse(self));
 fhinttimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}hinttimer,
                                                           false,[to_single]);
 fmouseparktimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}mouseparktimer,
                                                             false,[to_single]);
 inherited;
// initialize;
end;

destructor tinternalapplication.destroy;
begin
 destroyforms;
 fmouseparktimer.free;
 fhinttimer.free;
 fhintwidget.free;
 freeandnil(fcaret);
 fmouse.free;
// deinitialize;
 inherited;
// fwindows.free;
 fonkeypresslist.free;
 fonshortcutlist.free;
 fonwidgetactivechangelist.free;
 fonwindowactivechangelist.free;
 fonwindowdestroyedlist.free;
 fonwiniddestroyedlist.free;
 fonapplicationactivechangedlist.free;
 fonhelp.free;
 fonsyseventlist.free;
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
 for int1:= high(fgroupzorder) downto 0 do begin
  if fgroupzorder[int1] = sender then begin
   deleteitem(pointerarty(fgroupzorder),int1);
  end;
 end;
 if factivewindow = sender then begin
  factivewindow:= nil;
 end;
 if flastactivewindow = sender then begin
  flastactivewindow:= nil;
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
 if flockupdatewindowstack = sender then begin
  flockupdatewindowstack:= nil;
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
 parentid: winidty;
 pt1: pointty;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   window.invalidaterect(frect);
  end
  else begin
   if not winiddestroyed(fwinid) then begin
    parentid:= gui_getparentwindow(fwinid); //embedded or destroyed window 
    if parentid <> 0 then begin
     if findwindow(parentid,window) and 
                   (gui_getwindowpos(fwinid,pt1) = gue_ok) then begin
      addpoint1(frect.pos,pt1);
      window.invalidaterect(frect);
     end;
    end;
   end;
  end;
 end;
end;

procedure tinternalapplication.processshowingevent(event: twindowevent);
var
 window: twindow;
begin
 if findwindow(event.fwinid,window) then begin
  if event.kind = ek_show then begin
   window.showed;
  end
  else begin
   window.hidden;
  end;
 end;
end;

procedure tinternalapplication.processconfigureevent(event: twindowrectevent);
var
 window: twindow;
begin
 with event do begin
  if findwindow(fwinid,window) then begin
   window.wmconfigured(frect,forigin);
  end;
 end;
end;

procedure tinternalapplication.processleavewindow;
begin
 fmouseparktimer.enabled:= false;
 factmousewindow:= nil;
 if fmousecapturewidget = nil then begin
  setmousewidget(nil);
  widgetcursorshape:= cr_default;
  fhintedwidget:= nil;
//  cursorshape:= cr_default;
 end
 else begin
  if (fclientmousewidget <> nil) and
     not (ws_clientmousecaptured in fclientmousewidget.fwidgetstate) then begin
   setclientmousewidget(nil,nullpoint);
  end;
 end;
 fmousewinid:= 0;
end;

procedure tinternalapplication.processwindowcrossingevent(event: twindowevent);
var
 window: twindow;
// info: mouseeventinfoty;
begin
 if findwindow(event.fwinid,window) then begin
  if event.kind = ek_leavewindow then begin
   processleavewindow;
  end
  else begin
   fmousewinid:= event.fwinid;
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
 window,window1: twindow;
 info: moeventinfoty;
 shift: shiftstatesty;
 abspos: pointty;
 int1: integer;
 bo1: boolean;
 widget1: twidget;
 pt1: pointty;
begin
 try
  with event do begin
   if findwindow(fwinid,window) then begin
    if window.hastransientfor then begin
     window1:= window.topmodaltransientfor;
     if window1 <> nil then begin
      fpos.x:= fpos.x + window.fownerwidget.bounds_x - 
                                        window1.fownerwidget.bounds_x;
      fpos.y:= fpos.y + window.fownerwidget.bounds_y - 
                                        window1.fownerwidget.bounds_y;
      window:= window1;
     end;
    end;
    fillchar(info,sizeof(info),0);
    with info.mouse do begin
     timestamp:= ftimestamp;
     if freflected then begin
      include(eventstate,es_reflected);
     end;
     if kind = ek_enterwindow then begin
      eventkind:= ek_mousemove;
     end
     else begin
      eventkind:= kind;
     end;
     shift:= [];
     if kind = ek_mousewheel then begin
      fmousewheeleventinfo:= @info;
      info.wheel.wheel:= fwheel;
      calcmousewheeldelta(info.wheel,fmousewheelfrequmin,fmousewheelfrequmax,
                          fmousewheeldeltamin,fmousewheeldeltamax);
      if ftimestamp <> 0 then begin
       flastmousewheeltimestampbefore:= flastmousewheeltimestamp;
       flastmousewheeltimestamp:= ftimestamp;
      end;
     end
     else begin
      fmouseeventinfo:= @info;
      button:= fbutton;
      case button of
       mb_left: shift:= [ss_left];
       mb_middle: shift:= [ss_middle];
       mb_right: shift:= [ss_right];
      end;
     end;
     if eventkind = ek_buttonpress then begin
      shiftstate:= fshiftstate + shift;
     end
     else begin
      shiftstate:= fshiftstate - shift;
     end;
     pos:= fpos;
     abspos:= addpoint(window.fownerwidget.fwidgetrect.pos,pos);
    end;
    
    if (fmodalwindow <> nil) and (window <> fmodalwindow) and 
                          not window.istransientfor(fmodalwindow) then begin
     addpoint1(info.mouse.pos,subpoint(window.fownerwidget.fwidgetrect.pos,
         fmodalwindow.fownerwidget.fwidgetrect.pos));
     window:= fmodalwindow;
    end;
    if (fmousecapturewidget <> nil) and 
                    (fmousecapturewidget.window <> window) then begin
     addpoint1(info.mouse.pos,subpoint(window.fownerwidget.fwidgetrect.pos,
         fmousecapturewidget.fwindow.fownerwidget.fwidgetrect.pos));
     window:= fmousecapturewidget.fwindow;
    end;
    if (fmousecapturewidget = nil) and (aps_mousecaptured in fstate) and
             (event.fshiftstate * mousebuttons = []) then begin
     ungrabpointer;
    end;
    if (fhintwidget <> nil) and
     (fhintinfo.flags*[{hfl_custom,}hfl_noautohidemove] = [{hfl_custom}]) and
       (
       (info.mouse.eventkind = ek_buttonpress) or
       (info.mouse.eventkind = ek_buttonrelease) or
       (info.mouse.eventkind = ek_mousemove) and
          (distance(fhintinfo.mouserefpos,abspos) > 3)
        ) then begin
     bo1:= window = fhintwidget.window;
     deactivatehint;
     if bo1 then begin
      exit; //widow is destroyed
     end;
    end;
    fmouseparkeventinfo:= info.mouse;
    factmousewindow:= window;
    fmouseparktimer.interval:= mouseparktime;
    fmouseparktimer.enabled:= true;
    if ftimestamp <> 0 then begin
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
       include(info.mouse.shiftstate,ss_double);
       if (kind = ek_buttonpress) then begin
        if fdoublemousepress then begin
         include(info.mouse.shiftstate,ss_triple);
        end;
        fdoublemousepress:= true;
       end
       else begin
        if fdoublemouserelease then begin
         include(info.mouse.shiftstate,ss_triple);
        end;
        fdoublemouserelease:= true;
       end;
      end
      else begin
       fdoublemousepress:= false;
       fdoublemouserelease:= false;
      end;
      flastbutton:= fbutton;
     end;
    end;
    flastshiftstate:= info.mouse.shiftstate;
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
      widget1:= widget1.widgetatpos(info.mouse.pos);
              //search diabled child
     end;
     while (widget1 <> nil) and 
       ((ow_mousetransparent in widget1.foptionswidget) or 
         not widget1.isvisible or
         not (widget1.enabled or (ow_disabledhint in widget1.foptionswidget))
       ) do begin
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
     if kind in [ek_buttonpress,ek_buttonrelease] then begin
      deactivatehint; //cancel possible hint
     end;
     if (widget1 <> fhintedwidget) then begin
      if (widget1 <> fhintwidget) and
                (fhintedwidget <> nil) or (fhintwidget = nil) then begin
       deactivatehint;
       fhintedwidget:= widget1;
       if fhintedwidget <> nil then begin
        fhinttimer.interval:= hintdelaytime;
        fhinttimer.enabled:= true;
       end;
      end;
     end
     else begin
      if (fhintedwidget <> nil) and (fhintwidget = nil) and 
                                   (kind = ek_mousemove) then begin
       fhinttimer.interval:= hintdelaytime;
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
 finally
  if event.timestamp <> 0 then begin
   flastinputtimestamp:= event.timestamp;
  end;
  fmouseeventinfo:= nil;
  fmousewheeleventinfo:= nil;
 end;
end;

procedure tinternalapplication.processkeyevent(event: tkeyevent);
var
 window1: twindow;
 widget1: twidget;
 info: keyeventinfoty;
 shift: shiftstatesty;
begin
{$ifdef mse_debugkey}
 debugwriteln('*'+getenumname(typeinfo(eventkindty),ord(event.kind))+
       ' "'+event.fchars+'" '+inttostr(ord(event.fkey)));
{$endif}
 try 
  fkeyeventinfo:= @info;
  exclude(fstate,aps_clearkeyhistory);
  with event do begin
   if findwindow(fwinid,window1) then begin
    fillchar(info,sizeof(info),0);
    with info do begin
     eventkind:= fkind;
     timestamp:= event.timestamp;
     key:= fkey;
     keynomod:= fkeynomod;
     case key of
      key_shift: shift:= [ss_shift];
      key_alt: shift:= [ss_alt];
      key_control: shift:= [ss_ctrl];
      else shift:= [];
     end;
     if (fkey = key_decimal) and (fchars = '.') then begin
      chars:= defaultformatsettingsmse.decimalseparator;
     end
     else begin
      chars:= fchars;
     end;
     if kind = ek_keypress then begin
      shiftstate:= fshiftstate + shift;
     end
     else begin
      shiftstate:= fshiftstate - shift;
     end;
     flastshiftstate:= shiftstate;
     flastkey:= key;
     try
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
          replacebits({$ifdef FPC}longword{$else}word{$endif}(shiftstate),
            {$ifdef FPC}longword{$else}word{$endif}(fmouseparkeventinfo.shiftstate),
            {$ifdef FPC}longword{$else}word{$endif}(keyshiftstatesmask)));
       if kind = ek_keypress then begin
        fonkeypresslist.dokeyevent(widget1,info);
       end;
       if not (es_processed in eventstate) then begin
        window1.dispatchkeyevent(kind,info);
       end;
      end;
     finally
      if (eventkind = ek_keypress) and (key <> key_shift) and
                         (key <> key_control) and (key <> key_alt) then begin
       if length(fkeyhistory) < keyhistorylen then begin
        setlength(fkeyhistory,high(fkeyhistory)+2);
       end;
       if aps_clearkeyhistory in fstate then begin
        fkeyhistory:= nil;
       end
       else begin
        move(fkeyhistory[0],fkeyhistory[1],high(fkeyhistory)*sizeof(keyinfoty));
        with fkeyhistory[0] do begin
         key:= info.key;
         keynomod:= info.keynomod;
         shiftstate:= info.shiftstate;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 finally
  if event.timestamp <> 0 then begin
   flastinputtimestamp:= event.timestamp;
  end;
  exclude(fstate,aps_clearkeyhistory);
  fkeyeventinfo:= nil;
 end;
end;

function tinternalapplication.getevents: integer;
var
 ev1: tmseevent;
begin
 gdi_lock;
 while gui_hasevent do begin
  ev1:= gui_getevent;
  if ev1 <> nil then begin
   eventlist.add(ev1);
  end;
 end;
 result:= eventlist.count;
 gdi_unlock;
end;

procedure tinternalapplication.waitevent;
begin
{$ifdef mse_debuggdisync}
 checkgdiunlocked;
{$endif}
 include(fstate,aps_waiting);
 while gui_hasevent do begin
  eventlist.add(gui_getevent);
 end;
 if eventlist.count = 0 then begin
  incidlecount;
  eventlist.add(gui_getevent);
 end;
 fstate:= fstate - [aps_waiting,aps_woken];
end;

procedure tinternalapplication.flushmousemove;
var
 int1: integer;
 event: tmseevent;
begin
 gui_flushgdi;
 getevents;
 for int1:= 0 to eventlist.count - 1 do begin
  event:= tmseevent(eventlist[int1]);
  if (event <> nil) and (event.kind = ek_mousemove) then begin
   event.free1;
   eventlist[int1]:= nil;
  end;
 end;
end;

procedure tinternalapplication.windowdestroyed(aid: winidty);
var
 int1: integer;
 event : tmseevent;
begin
 fonwiniddestroyedlist.doevent(aid);
 if not terminated then begin
  for int1:= 0 to getevents - 1 do begin
   event:= tmseevent(eventlist[int1]);
   if (event is twindowevent) and (twindowevent(event).fwinid = aid) then begin
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
 fmouse.windowdestroyed(aid);
 if aid = fmousewinid then begin
  fmousewinid:= 0;
 end;
end;

procedure tinternalapplication.setwindowfocus(winid: winidty);
var
 window: twindow;
begin
 if findwindow(winid,window) and (window.fstate*[tws_grouphidden] = []) then begin
  try
{$ifdef mse_debugwindowfocus}
   debugwriteln('setwindowfocus '+window.fownerwidget.name+' '+hextostr(winid,8));
{$endif}
   if (fmodalwindow = nil) or (fmodalwindow = window) then begin
    if wo_noactivate in window.options then begin
     if window.transientfor <> nil then begin
      gui_setwindowfocus(window.transientfor.winid);
     end
     else begin
      if activewindow <> nil then begin
       gui_setwindowfocus(activewindow.winid);
      end;
     end;
    end
    else begin
     window.activated;
    end;
   end
   else begin
    if fmodalwindow.fwindow.id <> 0 then begin
{$ifdef mse_debugwindowfocus}
     debugwriteln('call trycancelmodal '+window.fownerwidget.name+' '+hextostr(winid,8));
{$endif}
{$warnings on}
     if {$ifdef mswindows}false{$else}
         fmodalwindow.fownerwidget.trycancelmodal(window)
         {$endif} then begin
{$warnings off}
 {$ifdef mse_debugwindowfocus}
      debugwriteln('trycancelmodal true '+window.fownerwidget.name+' '+hextostr(winid,8));
 {$endif}
      include(appinst.fstate,aps_cancelloop);
      appinst.ffocuslockwindow:= nil;
      appinst.ffocuslocktransientfor:= nil;
      window.internalactivate(true,true); //force focus
     end
     else begin
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
 end{$ifndef mse_debugwindowfocus};{$endif}
{$ifdef mse_debugwindowfocus}
 else begin
  if not findwindow(winid,window) then begin
   debugwriteln('setwindowfocus '+hextostr(winid,8)+' not found');
  end
  else begin
   debugwriteln('setwindowfocus '+window.fownerwidget.name+' '+
       hextostr(winid,8)+' grouphidden');
  end;
 end;
{$endif}

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
{$ifdef mse_debugwindowfocus}
  debugwriteln('unsetwindowfocus '+window.fownerwidget.name+' '+
                                                            hextostr(winid,8));
{$endif}
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

procedure tinternalapplication.zorderinvalid();
begin
 exclude(fstate,aps_zordervalid);
 if gao_forcezorder in foptionsgui then begin
 {$ifdef mse_debugzorder}
  debugwriteln('*needsupdatewindowstack');
 {$endif}
  include(fstate,aps_needsupdatewindowstack);
 end;
end;

procedure tinternalapplication.registerwindow(window: twindow);
begin
 lock;
 try
  if finditem(pointerarty(fwindows),window) >= 0 then begin
   guierror(gue_alreadyregistered,window.fownerwidget.name);
  end;
  additem(pointerarty(fwindows),window);
  zorderinvalid();
 finally
  unlock;
 end;
end;

procedure tinternalapplication.unregisterwindow(window: twindow);
var
 int1: integer;
begin
 lock;
 try
  int1:= removeitem(pointerarty(fwindows),window);
  if (int1 >= 0) and (int1 <= fwindowupdateindex) then begin
   dec(fwindowupdateindex);
  end;
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
 try
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
 finally
  exclude(info.eventstate,es_broadcast);
 end;
end;

procedure tinternalapplication.checkactivewindow;
var
 int1: integer;
begin
 if factivewindow = nil then begin
  if (fmainwindow <> nil) then begin
   fmainwindow.fownerwidget.activate;
  end
  else begin
   for int1:= 0 to high(fwindows) do begin
    with fwindows[int1].fownerwidget do begin
     if visible then begin
      activate;
      break;
     end;
    end;
   end;
   if (factivewindow = nil) and (high(fwindows) >= 0) then begin
    fwindows[0].fownerwidget.activate;
   end;
  end;
 end;
end;

function tinternalapplication.focusinpending: boolean;
var
 po1: ^tmseevent;
 int1: integer;
begin
 gui_flushgdi(true);
 getevents;
 po1:= pointer(eventlist.datapo);
 result:= false;
 for int1:= 0 to eventlist.count - 1 do begin
  if (po1^ <> nil) and (po1^.kind = ek_focusin) then begin
   result:= true;
   break;
  end;
  inc(po1);
 end;
end;

procedure tinternalapplication.checkapplicationactive;
var
 bo1: boolean;
begin
 bo1:= (activewindow <> nil) or focusinpending;
 if  bo1 xor (aps_active in fstate) then begin
  if bo1 then begin
   include(fstate,aps_active);
  end
  else begin
   exclude(fstate,aps_active);
   hidehint;
  end;
  fonapplicationactivechangedlist.doevent(bo1);
 end;
end;

function tinternalapplication.winiddestroyed(const aid: winidty): boolean;
type
 windoweventaty = array[0..0] of twindowevent;
 pwindoweventaty = ^windoweventaty;
var
 int1: integer;
 po1: pwindoweventaty;
begin
 result:= false;
 getevents;
 po1:= pointer(eventlist.datapo);
 for int1:= 0 to eventlist.count - 1 do begin
  if po1^[int1] <> nil then begin
   with po1^[int1] do begin
    if (kind = ek_destroy) and (fwinid = aid) then begin
     result:= true;
     break;
    end;
   end;
  end;
 end;
end;

{$ifdef mse_debug}
procedure debugwindow(const atext: string; const aid: winidty);
var
 str1: string;
 window1: twindow;
begin
 str1:= atext+hextostr(aid)+' ';
 if appinst.findwindow(aid,window1) then begin
  str1:= str1+window1.owner.name;
 end
 else begin
  str1:= str1+'NIL';
 end;
 debugwriteln(str1);
end;

procedure debugwindow(const atext: string; const aid1,aid2: winidty);
var
 str1: string;
 window1: twindow;
begin
 str1:= atext+hextostr(aid1)+' ';
 if appinst.findwindow(aid1,window1) then begin
  str1:= str1+window1.owner.name;
 end
 else begin
  str1:= str1+'NIL';
 end;
 str1:= str1+','+hextostr(aid2)+' ';
 if appinst.findwindow(aid2,window1) then begin
  str1:= str1+window1.owner.name;
 end
 else begin
  str1:= str1+'NIL';
 end;
 
 debugwriteln(str1);
end;

function checkwindowname(const aid: winidty; const aname: string): boolean;
var
 window1: twindow;
begin
 result:= appinst.findwindow(aid,window1) and
              (window1.fownerwidget.name = aname);
end;

{$endif}

procedure tinternalapplication.removewindowevents(const awindow: winidty;
                    const aeventkind: eventkindty);
var
 po1: pwindowevent;
 int1: integer;
begin
 getevents;
 po1:= pointer(eventlist.datapo);
 for int1:= 0 to eventlist.count - 1 do begin
  if po1^ <> nil then begin
   with po1^ do begin
    if (kind = ek_configure) and (fwinid = awindow) then begin
     po1^.free;
     po1^:= nil;
    end;
   end;
  end;
  inc(po1);
 end;
end;

procedure tinternalapplication.eventloop(const once: boolean = false);
                   
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

 function canuievent: boolean;
 begin
  result:= not once or (fwaitcount = 0) {or (aps_processmessages in fstate)};
  if not result and (fmousewidget <> nil) then begin
   capturemouse(nil,false);
   setmousewidget(nil);
  end;
 end; //canuievent
 
var
 event: tmseevent;
 int1: integer;
 bo1,bo2,bo3: boolean;
 window: twindow;
 id1: winidty;
 po1: ^twindowevent;
 po2: pmodalinfoty;
 waitcountbefore: integer;
 ar1: integerarty;
 ar2: eventarty;
 modalinfo: modalinfoty;
 
begin       //eventloop
 if aps_looplocked in fstate then begin
  exit;
 end;
 if not ismainthread then begin
  raise exception.create('Eventloop must be in main thread.');
 end;

 inc(flooplevel);
 if fcurrmodalinfo = nil then begin
  fillchar(modalinfo,sizeof(modalinfo),0);
  fcurrmodalinfo:= @modalinfo;
 end;
 try
  ftimertick:= false;
  waitcountbefore:= fwaitcount;
  if not once then begin
   fwaitcount:= 0;
  end;
  checkcursorshape;
  while not ((fcurrmodalinfo <> nil) and fcurrmodalinfo^.modalend) and 
       not terminated and (fstate * [aps_exitloop,aps_cancelloop] = []) do begin 
                                                  //main eventloop
   try
    if ((fcurrmodalinfo = nil) or (high(fcurrmodalinfo^.events) < 0)) and 
                                                     (getevents = 0) then begin
     checkwindowstack;
     repeat
      bo1:= false;
      fwindowupdateindex:= 0;
      while fwindowupdateindex <= high(fwindows) do begin
       try
        bo1:= fwindows[fwindowupdateindex].internalupdate or bo1;
       except
        handleexception(self);
       end;
       inc(fwindowupdateindex);
      end;
     until not bo1 and not terminated; //no more to paint
     exclude(fstate,aps_invalidated);
     if terminated or (aps_exitloop in fstate) then begin
      break;
     end;
     if not gui_hasevent then begin
      try
//       if (fcurrmodalinfo{amodalwindow} = nil) and 
       if (fcurrmodalinfo^.level = 0) and 
                          not (aps_activewindowchecked in fstate) then begin
        include(fstate,aps_activewindowchecked);
        checkactivewindow;
       end;
       ftimertick:= false;
       msetimer.tick(self);    //tick called in every idle
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
      if (aps_needsupdatewindowstack in fstate) and 
                                  application.active then begin
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
      if gui_hasevent or not (aps_invalidated in fstate) then begin
       waitevent;
      end;
     end;
    end;
    if terminated then begin
     break;
    end;
    getevents;
    if {(fcurrmodalinfo <> nil) and} (high(fcurrmodalinfo^.events) >= 0) then begin
     event:= fcurrmodalinfo^.events[0];
     tobjectevent1(event).fmodallevel:= -1;
     deleteitem(pointerarty(fcurrmodalinfo^.events),0);
    end
    else begin
     event:= tmseevent(eventlist.getfirst);
    end;
    if event <> nil then begin
     try
      try
       case event.kind of
        ek_timer: begin
         ftimertick:= true;
        end;
        ek_show,ek_hide: begin
        {$ifdef mse_debugwindowfocus}
         if event.kind = ek_show then begin
          debugwindow('ek_show ',twindowevent(event).fwinid);
         end
         else begin
          debugwindow('ek_hide ',twindowevent(event).fwinid);
         end;
        {$endif}
         processshowingevent(twindowevent(event));
        end;
        ek_close: begin
         if findwindow(twindowevent(event).fwinid,window) then begin
          if (fmodalwindow = nil) or (fmodalwindow = window) then begin
           window.close;
          end
          else begin
           fmodalwindow.fownerwidget.canclose(nil);
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
        {$ifdef mse_debugwindowfocus}
         debugwindow('ek_focusin ',twindowevent(event).fwinid);
        {$endif}
         getevents;
         bo1:= true;
         id1:= twindowevent(event).fwinid;
         po1:= pointer(eventlist.datapo);
         bo3:= false;
         for int1:= 0 to eventlist.count - 1 do begin
          if po1^ <> nil then begin //find last focusin
           with po1^ do begin
            case kind of
             ek_focusin: begin
              bo3:= false;
              id1:= fwinid;
             end;
             ek_focusout: begin
              bo3:= true;
              if fwinid = twindowevent(event).fwinid then begin
               id1:= 0;
              end;
             end;
            end; 
           end;
          end;
          inc(po1);
         end;
         bo2:= id1 = twindowevent(event).fwinid; //last focus is current window
         po1:= pointer(eventlist.datapo);
         for int1:= 0 to eventlist.count - 1 do begin
          if po1^ <> nil then begin
           with po1^ do begin
            if (kind = ek_destroy) and 
                            (fwinid = twindowevent(event).fwinid) then begin
             bo1:= false;
            end;
            if bo2 then begin //last focus is current window
             if kind in [ek_focusin,ek_focusout] then begin
             {$ifdef mse_debugwindowfocus}
              debugwindow(' '+getenumname(typeinfo(eventkindty),ord(kind))+
                           ' deleted',twindowevent(event).fwinid);
             {$endif}
              freeandnil(po1^); //ignore
             end;
            end
            else begin
             if (kind = ek_focusout) and 
                               (fwinid = twindowevent(event).fwinid) then begin
             {$ifdef mse_debugwindowfocus}
              debugwindow(' spurious ek_focusout deleted ',twindowevent(event).fwinid);
             {$endif}
              bo1:= false;
              freeandnil(po1^); 
                 //spurious focus, for instance minimize window group on windows
              if bo3 and (factivewindow <> nil) then begin
               unsetwindowfocus(factivewindow.fwindow.id);
               postevent(tmseevent.create(ek_checkapplicationactive));
              end;
              break;
             end;
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
        {$ifdef mse_debugwindowfocus}
         if not bo1 then begin
          debugwriteln(' ek_focusin ignored');
         end;
        {$endif}
        end;
        ek_focusout: begin
        {$ifdef mse_debugwindowfocus}
         debugwindow('ek_focusout ',twindowevent(event).fwinid);
        {$endif}
         getevents;
         po1:= pointer(@eventlist.datapo^[eventlist.count-1]);
         bo1:= true; 
         for int1:= 0 to eventlist.count - 1 do begin
          if po1^ <> nil then begin
           with po1^ do begin
            case kind of
             ek_focusin: begin
             {$ifdef mse_debugwindowfocus}
              debugwindow(' ek_focusout ignored ',twindowevent(event).fwinid);
             {$endif}
              bo1:= false; //ignore the event
              break;
             end;
             ek_focusout: begin
              break;
             end;
            end;
           end;
          end;
          dec(po1);
         end;
         if bo1 then begin
          unsetwindowfocus(twindowevent(event).fwinid);
          postevent(tmseevent.create(ek_checkapplicationactive));
         end
         else begin
          include(fstate,aps_restorelocktransientfor);
         end;
        end;
        ek_checkapplicationactive: begin
         if checkiflast(ek_checkapplicationactive) then begin
          checkapplicationactive;
         end;
        end;
        ek_expose: begin
         zorderinvalid();
         processexposeevent(twindowrectevent(event));
        end;
        ek_configure: begin
         zorderinvalid();
         id1:= twindowrectevent(event).fwinid;
         getevents;
         po1:= pointer(eventlist.datapo);
         for int1:= 0 to eventlist.count - 1 do begin
          if po1^ <> nil then begin   //use last configure event for the window
           with twindowrectevent(po1^) do begin
            if (kind = ek_configure) and (fwinid = id1) then begin
             event.free;
             event:= po1^;
             po1^:= nil;
            end;
           end;
          end;
         end;
         processconfigureevent(twindowrectevent(event));
        end;
        ek_enterwindow: begin
         if fmousewinid <> twindowevent(event).fwinid then begin
                   //there can be an additional enterwindow by mouse click
          processwindowcrossingevent(twindowevent(event));
          if canuievent and (event is tmouseenterevent) then begin
           processmouseevent(tmouseenterevent(event));
          end;
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
         if checkiflast(ek_mousemove) and canuievent then begin
          processmouseevent(tmouseevent(event));
         end;
        end;
        ek_buttonpress,ek_buttonrelease,ek_mousewheel: begin
         if canuievent then begin
          processmouseevent(tmouseevent(event));
         end;
        end;
        ek_keypress,ek_keyrelease: begin
         if canuievent then begin
          processkeyevent(tkeyevent(event));
         end;
        end;
        ek_asyncexec: begin
         texecuteevent(event).deliver;
        end;
        ek_sysdnd: begin
         if findwindow(tsysdndevent(event).fwinid,window) then begin
          window.processsysdnd(tsysdndevent(event));
         end;
        end;
        else begin
         if event is tobjectevent then begin
          with tobjectevent(event) do begin
//           if fcurrmodalinfo = nil then begin
//            int1:= -modallevel;
//           end
//           else begin
            int1:= fcurrmodalinfo^.level-modallevel;
//           end;
           if (int1 > 0) and (modallevel >= 0) then begin
            po2:= fcurrmodalinfo^.parent;
            for int1:= int1 - 2 downto 0 do begin
             po2:= po2^.parent;
            end;
            additem(pointerarty(po2^.events),event);
            event:= nil;
           end
           else begin
            deliver;
           end;
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
  fwaitcount:= waitcountbefore;
  if fwaitcount > 0 then begin
   mouse.shape:= cr_wait;
  end;
  checkcursorshape;
 
  if {(fcurrmodalinfo <> nil) and} (fcurrmodalinfo^.parent <> nil) then begin
   stackarray(pointer(fcurrmodalinfo^.events),
                         pointerarty(fcurrmodalinfo^.parent^.events));
  end
  else begin
//   if fcurrmodalinfo <> nil then begin
    ar2:= fcurrmodalinfo^.events;
    fcurrmodalinfo^.events:= nil;
//   end
//   else begin
//    ar2:= nil;
//   end;
   for int1:= 0 to high(ar2) do begin
    if ar2[int1] is tobjectevent then begin
     with tobjectevent1(ar2[int1]) do begin
      fmodallevel:= -1;
      free1;
     end;
    end
    else begin
     ar2[int1].free;
    end;
   end;
  end;
 finally
  dec(flooplevel);
  if fcurrmodalinfo = @modalinfo then begin
   fcurrmodalinfo:= nil;
  end;
 end;
end;

function tinternalapplication.beginmodal(const sender: twindow;
                                       const showinfo: pshowinfoty): boolean;
                 //true if modalwindow destroyed
var
 window1: twindow;
 bo1: boolean;
 modalwidgetbefore,focusedwidgetbefore: twidget;
 modalinfo: modalinfoty;
 modalinfobefore: pmodalinfoty;
begin
 result:= false;
 exclude(fstate,aps_cancelloop);
 window1:= nil;
 if (factivewindow <> nil) and (factivewindow <> sender) then begin
  setlinkedvar(factivewindow,tlinkedobject(window1));
  bo1:= tws_modalcalling in window1.fstate;
  include(window1.fstate,tws_modalcalling);
 end;
 modalwidgetbefore:= nil;
 focusedwidgetbefore:= nil;
 fillchar(modalinfo,sizeof(modalinfo),0);
 if fcurrmodalinfo <> nil then begin
  modalinfo.parent:= fcurrmodalinfo;
  modalinfo.level:= fcurrmodalinfo^.level+1;
 end
 else begin
  modalinfo.level:= 1;
 end;
 fcurrmodalinfo:= @modalinfo;
 if fmodalwindow <> nil then begin
  setlinkedvar(fmodalwindow,tlinkedobject(modalinfo.modalwindowbefore));
 end;
 modalinfobefore:= sender.fmodalinfopo;
 sender.fmodalinfopo:= @modalinfo;
 setlinkedvar(sender,tlinkedobject(fmodalwindow));

 try
  with sender do begin
   inc(fmodallevel);
  end;
  if showinfo <> nil then begin
   with showinfo^ do begin
    setlinkedvar(widget.window.fmodalwidget,tmsecomponent(modalwidgetbefore));
    if (factivewindow = sender) and (sender.ffocusedwidget <> nil) and 
            not widget.checkdescendent(sender.ffocusedwidget) then begin
     setlinkedvar(sender.ffocusedwidget,
                     tmsecomponent(focusedwidgetbefore));
    end;
    widget.internalshow(ml_none,@transientfor,windowevent,nomodalforreset);
    if fstate * [aps_cancelloop,aps_exitloop] <> [] then begin
     exit;
    end;
    widget.activate;
    setlinkedvar(sender.fmodalwidget,tmsecomponent(modalwidgetbefore));
    sender.fmodalwidget:= widget;
   end;
  end;
  sender.activate;  
  if fstate * [aps_cancelloop,aps_exitloop] = [] then begin
   try
    eventloop;
   finally
    with showinfo^ do begin
     if (widget <> nil) then begin
      widget.window.fmodalwidget:= modalwidgetbefore;
     end;
    end;
    if (window1 <> nil) then begin
     try
      if not (aps_cancelloop in fstate) then begin
       if (focusedwidgetbefore <> nil) then begin
        focusedwidgetbefore.activate(true,false);
       end;
       if appinst.active then begin
        window1.activate;
       end;
      end;
     finally
      if (window1 <> nil) and not bo1 then begin
       exclude(window1.fstate,tws_modalcalling);
      end;
     end;
    end;
   end;
  end;
 finally
  setlinkedvar(nil,tlinkedobject(window1));
  setlinkedvar(nil,tmsecomponent(modalwidgetbefore));
  setlinkedvar(nil,tmsecomponent(focusedwidgetbefore));
  exclude(fstate,aps_exitloop);
  if fmodalwindow <> nil then begin
   fmodalwindow.fmodalinfopo:= modalinfobefore{nil};
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
  fcurrmodalinfo:= modalinfo.parent;
 end;
end;

procedure tinternalapplication.endmodal(const sender: twindow);
begin
 with sender do begin
  if fmodallevel > 0 then begin
   if not appinst.terminated and (fmodalinfopo <> nil) then begin
    fmodalinfopo^.modalend:= true;
   end;
   dec(fmodallevel);
  end;
 end;
end;

{$ifdef mse_debugzorder}
function debugwindowinfo(const awindow: twindow): string;
begin
 if awindow = nil then begin
  result:= 'nil';
 end
 else begin
  result:= '"'+awindow.fownerwidget.name+'"';
 end;
end;

procedure printwindowstackinfo(const ar3: windowarty); overload;
var
 int1: integer;
begin
 for int1:= 0 to high(ar3) do begin
  if ar3[int1].fownerwidget.visible then begin
   debugwrite('+ ');
  end
  else begin
   debugwrite('- ');
  end;
  debugwriteln(debugwindowinfo(ar3[int1])+' '+
                 debugwindowinfo(ar3[int1].ftransientfor));
 end;
end;

procedure printwindowstackinfo(const ar3: windowstackinfoarty); overload;
var
 int1: integer;
begin 
 for int1:= 0 to high(ar3) do begin
  debugwriteln(debugwindowinfo(ar3[int1].lower)+' '+
                    debugwindowinfo(ar3[int1].upper));
 end;
end;

{$endif}

procedure tinternalapplication.stackunder(const sender: twindow; 
                                              const predecessor: twindow);
begin
{$ifdef mse_debugzorder}
 debugwriteln('****stackunder**** '+debugwindowinfo(sender)+' '+
                                          debugwindowinfo(predecessor));
{$endif}
 setlength(fwindowstack,high(fwindowstack)+2);
 with fwindowstack[high(fwindowstack)] do begin
  lower:= sender;
  upper:= predecessor;
 end;
end;

procedure tinternalapplication.stackover(const sender: twindow;
                                             const predecessor: twindow);
begin
{$ifdef mse_debugzorder}
 debugwriteln('****stackover**** '+debugwindowinfo(sender)+' '+
                                          debugwindowinfo(predecessor));
{$endif}
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
 if (fwindowstack <> nil) and (flockupdatewindowstack = nil) then begin
  include(fstate,aps_looplocked); //no windows sizing callbacks
  try
   if not nozorderhandling then begin
  {$ifdef mse_debugzorder}
    debugwriteln('****checkwindowstack**** fwindowstack');
    printwindowstackinfo(fwindowstack);
  {$endif}
    for int1:= 0 to high(fwindowstack) do begin
     findlevel(fwindowstack[int1]);
    end;
    sortarray(fwindowstack,sizeof(windowstackinfoty),
                                    {$ifdef FPC}@{$endif}cmpwindowstack);
   {$ifdef mse_debugzorder}
    debugwriteln('..... after sort');
    printwindowstackinfo(fwindowstack);
   {$endif}
    if gui_canstackunder then begin
     for int1:= 0 to high(fwindowstack) do begin
      with fwindowstack[int1] do begin
       if lower <> nil then begin
        if (upper = nil) then begin
         gui_raisewindow(lower.winid);
        end
        else begin
 //        if int1 = 0 then begin
 //         gui_raisewindow(upper.winid); 
 //        end;
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
    zorderinvalid();
   end;
   fwindowstack:= nil;
  finally
   exclude(fstate,aps_looplocked);
  end;
 end;
end;

function compwindowzorder(const l,r): integer;
const
 raiseweight =              1;
 lowerweight =              1;
 backgroundweight =         1 shl 2;
 topweight =                1 shl 2;
// popupweight =              1 shl 4;
 modalweight =              1 shl 5;
// transientforcountweight =  1 shl 6;
// transientfornotnilweight = 1 shl 7;
 transientforweight =       1 shl 8;
 transientforactiveweight = 1 shl 9;
 invisibleweight =          1 shl 10;
 popupweight =              1 shl 11;
var
 window1: twindow;
{$ifdef mse_debugzorder}
 ch1: char;
{$endif}
begin
 result:= 0;
 if (tws_windowvisible in twindow(l).fstate) then begin
  if not (tws_windowvisible in twindow(r).fstate) then begin
   inc(result,invisibleweight);
  end
 end
 else begin
  if (tws_windowvisible in twindow(r).fstate) then begin
   dec(result,invisibleweight);
  end
  else begin
   exit; //both invisible -> no change in order
  end;
 end;
 if tws_raise in  twindow(l).fstate then begin
  inc(result,raiseweight);
 end;
 if tws_raise in  twindow(r).fstate then begin
  dec(result,raiseweight);
 end;
 if tws_lower in  twindow(l).fstate then begin
  dec(result,lowerweight);
 end;
 if tws_lower in  twindow(r).fstate then begin
  inc(result,lowerweight);
 end;
 if ow_background in twindow(l).fownerwidget.foptionswidget then begin
  dec(result,backgroundweight);
 end;
 if ow_top in twindow(l).fownerwidget.foptionswidget then begin
  inc(result,topweight);
 end;
 if ow_background in twindow(r).fownerwidget.foptionswidget then begin
  inc(result,backgroundweight);
 end;
 if ow_top in twindow(r).fownerwidget.foptionswidget then begin
  dec(result,topweight);
 end;
 if twindow(l).ispopup then begin
  inc(result,popupweight);
 end;
 if twindow(r).ispopup then begin
  dec(result,popupweight);
 end;
 if twindow(l).fmodallevel > 0 then begin
  inc(result,modalweight);
 end;
 if twindow(r).fmodallevel > 0 then begin
  dec(result,modalweight);
 end;
 if twindow(l).transientforstackactive then begin
  inc(result,transientforactiveweight);
 end;
 if twindow(r).transientforstackactive then begin
  dec(result,transientforactiveweight);
 end;
 {
// if twindow(l).transientforstackactive then begin
  if twindow(l).ftransientfor <> nil then begin
   inc(result,transientfornotnilweight);
  end;
  if twindow(l).ftransientforcount > 0 then begin
   inc(result,transientforcountweight);
  end;
// end; 
// if twindow(r).transientforstackactive then begin
  if twindow(r).ftransientfor <> nil then begin
   dec(result,transientfornotnilweight);
  end;
  if twindow(r).ftransientforcount > 0 then begin
   dec(result,transientforcountweight);
  end;
// end;
}
 window1:= twindow(l);
 while window1.ftransientfor <> nil do begin
  if window1.ftransientfor = twindow(r) then begin
   inc(result,transientforweight);
   exit;
  end;
  window1:= window1.ftransientfor;
 end;
 window1:= twindow(r);
 while window1.ftransientfor <> nil do begin
  if window1.ftransientfor = twindow(l) then begin
   dec(result,transientforweight);
   exit;
  end;
  window1:= window1.ftransientfor;
 end;  
{$ifdef mse_debugzorder}
 if result < 0 then begin
  ch1:= '-';
 end
 else begin
  ch1:= ' ';
 end;
 debugwindow('.'+ch1+hextostr(longword(abs(result)),4)+
  ' tract:'+bintostr(ord(twindow(l).transientforstackactive),1)+':'+
              bintostr(ord(twindow(r).transientforstackactive),1)+
  ' trforco:'+inttostr(twindow(l).ftransientforcount)+':'+
                inttostr(twindow(r).ftransientforcount)+
 ' l:',twindow(l).winid,
                                                     twindow(r).winid);
{$endif}
end;

procedure tinternalapplication.updatewindowstack;
var
 ar3,ar4: windowarty;
 int1,int2: integer;
 bo1: boolean;
begin
 if flockupdatewindowstack = nil then begin
  checkwindowstack;
  sortzorder;
  ar3:= windowar; //refcount 1
 {$ifdef mse_debugzorder}
  debugwriteln('*****updatewindowstack***** current order');
  printwindowstackinfo(ar3);
 {$endif}
  ar4:= copy(ar3);
  sortarray(ar3,sizeof(ar3[0]),{$ifdef FPC}@{$endif}compwindowzorder);
  for int1:= 0 to high(ar3) do begin
   with ar3[int1] do begin
    fstate:= fstate - [tws_raise,tws_lower]; 
            //reset bringtofrontlocal/sendtobacklocal
   end;
  end;
  int2:= -1;
 {$ifdef mse_debugzorder}
  debugwriteln('++++ after sort');
  printwindowstackinfo(ar3);
 {$endif}
  for int1:= 0 to high(ar4) do begin
   if ar3[int1] <> ar4[int1] then begin
    int2:= int1; //invalid stackorder
    break;
   end;
  end;
  if int2 >= 0 then begin
   if gui_canstackunder then begin
    bo1:= true;
    for int1:= int2+1 to high(ar3) do begin
     if ar4[int1] <> ar3[int1-1] then begin
      bo1:= false;
      break;
     end;
    end;
    if bo1 then begin //single local raise
     gui_stackoverwindow(ar4[int2].winid,ar4[high(ar4)].winid);
     fwindowstack:= nil;
     exit;
    end;
   end;
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
end;

procedure tinternalapplication.internalpackwindowzorder();
var
 int1: integer;
begin
 updatewindowstack(); //handle pending;
 sortzorder();
 if high(fwindows) > 1 then begin
  setlength(fwindowstack,length(fwindows));
  for int1:= 0 to high(fwindowstack) - 1 do begin
   with fwindowstack[int1] do begin
    lower:= fwindows[int1];
    upper:= fwindows[int1+1];
   end;
  end;
 {
  with fwindowstack[high(fwindowstack)] do begin
   lower:= fwindows[high(fwindowstack)];
   upper:= nil;
  end;
 }
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
  caret.hide;
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

procedure tinternalapplication.checkcursorshape;
begin
 if terminated then begin
  fmouse.shape:= cr_default;
 end
 else begin
  if not waiting then begin
   if fcursorshape = cr_default then begin
    fmouse.shape:= fwidgetcursorshape;
   end
   else begin
    fmouse.shape:= fcursorshape;
   end;
  end
  else begin
   fmouse.shape:= cr_wait;
  end;
 end;
end;

procedure tinternalapplication.dopostevent(const aevent: tmseevent);
begin
 gui_postevent(aevent);
end;

procedure tinternalapplication.doeventloop(const once: boolean);
begin
 eventloop(once);
end;

{ tguiapplication }

constructor tguiapplication.create(aowner: tcomponent);
begin
 fwidgetcursorshape:= cr_default;
 fmousewheelfrequmin:= 1;
 fmousewheelfrequmax:= 100;
 fmousewheeldeltamin:= 0.05;
 fmousewheeldeltamax:= 30;
 fmousewheelaccelerationmax:= 30;
 gui_registergdi;
 inherited;
end;

procedure getmseguiarguments();
var
 ar1: stringarty;
 int1,int2: integer;

 procedure deleteitem();
 begin
  deletecommandlineargument(int1-int2);
  inc(int2);
 end; //deleteitem
 
begin
 ar1:= getcommandlinearguments;
 int2:= 0;
 for int1:= 1 to high(ar1) do begin
  if ar1[int1] = '--TOPLEVELRAISE' then begin
   toplevelraise:= true;
   deleteitem();
   noreconfigurewmwindow:= true;
   norestackwindow:= true;
   continue;
  end;
  if ar1[int1] = '--NOZORDERHANDLING' then begin
   nozorderhandling:= true;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--NORESTACKWINDOW' then begin
   norestackwindow:= true;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--RESTACKWINDOW' then begin
   norestackwindow:= false;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--NORECONFIGUREWMWINDOW' then begin
   noreconfigurewmwindow:= true;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--RECONFIGUREWMWINDOW' then begin
   noreconfigurewmwindow:= false;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--STACKMODEBELOWWORKAROUND' then begin
   stackmodebelowworkaround:= true;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--NOSTACKMODEBELOWWORKAROUND' then begin
   stackmodebelowworkaround:= false;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--NOSTATICGRAVITY' then begin
   nostaticgravity:= true;
   deleteitem();
   continue;
  end;
 {
  if ar1[int1] = '--EXABUG' then begin 
            //workaround for radeon EXA pixmap bug, slows down drawing!
   exabug:= true;
   deleteitem();
   continue;
  end;
 }
 {
  if ar1[int1] = '--NOCREATESTATICGRAVITY' then begin
   nocreatestaticgravity:= true;
   deleteitem();
   continue;
  end;
  if ar1[int1] = '--CREATESTATICGRAVITY' then begin
   nocreatestaticgravity:= false;
   deleteitem();
   continue;
  end;
 }
 end;
end;

procedure tguiapplication.internalinitialize;
begin
 with tinternalapplication(self) do begin
  fdesigning:= false;
  getmseguiarguments();
  guierror(gui_init,self);
  msetimer.init();
  msegraphics.init();
 end;
end;

procedure tguiapplication.internaldeinitialize;
begin
 with tinternalapplication(self) do begin
  if fcaret <> nil then begin
   fcaret.link(nil,nullpoint,nullrect);
  end;
  msegraphics.deinit();
  lock();
  gui_flushgdi();
  flusheventbuffer();
  getevents();
  eventlist.clear();
  unlock();
  gui_deinit();
  msetimer.deinit();
 end;
 inherited;
end;

procedure tguiapplication.destroyforms;
begin
 while componentcount > 0 do begin
  components[componentcount-1].free;  //destroy loaded forms
 end;
 while high(fwindows) >= 0 do begin
  fwindows[high(fwindows)].fownerwidget.free;
 end;
end;

procedure tguiapplication.checkwindowrect(winid: winidty; var rect: rectty);
var
 window: twindow;
begin
 if findwindow(winid,window) then begin
  window.fownerwidget.checkwidgetsize(rect.size);
 end;
end;

procedure tguiapplication.setclientmousewidget(const widget: twidget;
                                                         const apos: pointty);
var
 info: mouseeventinfoty;
begin
 if fclientmousewidget <> widget then begin
  fillchar(info,sizeof(info),0);
  if (fclientmousewidget <> nil) and
             not (csdestroying in fclientmousewidget.componentstate) then begin
//   exclude(fclientmousewidget.fwidgetstate,ws_mouseinclient);
   info.eventkind:= ek_clientmouseleave;
   fclientmousewidget.mouseevent(info);
  end;
  fclientmousewidget:= widget;
  if widget <> nil then begin
   info.eventkind:= ek_clientmouseenter;
   info.pos:= apos;
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
  setclientmousewidget(nil,nullpoint);
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

function tguiapplication.grabpointer(const aid: winidty): boolean;
var
 int1: integer;
begin
 for int1:= 0 to high(fwindows) do begin
  with fwindows[int1] do begin
   if fwindow.id <> aid then begin
    exclude(fstate,tws_grab);
   end;
  end;
 end;
 {$ifdef nograbpointer}
 result:= true;
 {$else}
 result:= gui_grabpointer(aid) = gue_ok;
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

procedure tguiapplication.capturemouse(const sender: twidget;
                                                    const grab: boolean);
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
          [ws_lclicked,ws_mclicked,ws_rclicked,
           ws_mousecaptured,ws_clientmousecaptured];
   if sender <> nil then begin
    fwidgetcursorshape:= cr_default; //give up cursor shape
   end;
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
   if not grab then begin
    ungrabpointer;
   end;
  end;
 end;
end;

function tguiapplication.createform(instanceclass: widgetclassty;
                                               var reference): twidget;
begin
 result:= twidget(mseclasses.createmodule(self,instanceclass,reference));
end;

procedure tguiapplication.eventloop(const once: boolean = false);
             //used in win32 wm_queryendsession and wm_entersizemove
begin
 inc(feventlooping);
 try
  tinternalapplication(self).eventloop(once);
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
 sys_schedyield;
 inherited;
end;

procedure tguiapplication.invalidated;
begin
// if not (aps_invalidated in fstate) then begin
 include(fstate,aps_invalidated);
 wakeupmainthread;
// end;
end;

procedure tguiapplication.showasyncexception(e: exception; 
                                  const leadingtext: msestring = '');
var
 mstr1: msestring;
begin
 mstr1:= leadingtext + e.Message;
 postevent(tasyncmessageevent.create(mstr1,'Exception'));
end;

procedure tguiapplication.showexception(e: exception; 
                                  const leadingtext: msestring = '');
var
 mstr1: msestring;
begin
 if not ismainthread then begin
  showasyncexception(e,leadingtext);
 end
 else begin
  mstr1:= leadingtext + e.Message;
  showmessage(mstr1,sc(sc_exception){$ifdef FPC},0,lineend+
              getexceptiontext(exceptobject,
                            exceptaddr,exceptframecount,exceptframes){$endif});
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

procedure tguiapplication.activate();
begin
 if flastactivewindow <> nil then begin
  flastactivewindow.activate();
 end
 else begin
  if fmainwindow <> nil then begin
   fmainwindow.activate();
  end
  else begin
   if fwindows <> nil then begin
    fwindows[0].activate();
   end;
  end;
 end;
end;

function tguiapplication.findwindow(aid: winidty; out window: twindow): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(fwindows) do begin
  if fwindows[int1].fwindow.id = aid then begin
   window:= fwindows[int1];
   result:= true;
   exit;
  end;
 end;
 window:= nil;
end;

function tguiapplication.screenrect(const awindow: twindow = nil): rectty;
var
 id: winidty;
begin
 id:= 0;
 result:= gui_getscreenrect(id);
end;

function tguiapplication.workarea(const awindow: twindow = nil): rectty;
var
 id: winidty;
begin
 id:= 0;
 if awindow = nil then begin
  if factivewindow <> nil then begin
   id:= factivewindow.winid;   
  end;
 end
 else begin
  id:= awindow.winid;
 end;
 result:= gui_getworkarea(id);
end;

function tguiapplication.normalactivewindow: twindow;
begin
 result:= fwantedactivewindow;
 if result = nil then begin
  result:= factivewindow;
 end;
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
 while (result <> nil) and (result.fownerwidget.releasing or 
                                 not result.fownerwidget.visible) do begin
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
  result:= factivewindow.fownerwidget;
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

function tguiapplication.findwidget(const namepath: string;
                                               out awidget: twidget): boolean;
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

procedure tguiapplication.sortzorder(); //top is last, invisibles first
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
  end;
  include(fstate,aps_zordervalid);
 end;
end;

procedure tguiapplication.packwindowzorder();
begin
 internalpackwindowzorder();
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
  window1:= nil;
  if (sender <> nil) and ((activewindow = nil) or 
              (activewindow = sender.window) and activewindow.modal) then begin
   window1:= sender.window;
  end;
  fhintwidget:= thintwidget.create(nil,window1,fhintinfo);
 {$ifdef mse_debugzorder}
  debugwriteln('** showhint '+tinternalapplication(self).fhintinfo.caption);
 {$endif}
  fhintwidget.show(ml_none,window1);
  if showtime <> 0 then begin
   fhinttimer.interval:= showtime;
   fhinttimer.enabled:= true;
  end;
 end;
end;

procedure tguiapplication.inithintinfo(var info: hintinfoty;
                                                 const ahintedwidget: twidget);
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

procedure tguiapplication.showhint(const sender: twidget;
                                           const info: hintinfoty);
begin
 with info do begin
  if (hfl_show in flags) or (caption <> '') then begin
   showhint(sender,caption,posrect,placement,showtime,flags);
  end;
 end;
end;

procedure tguiapplication.showhint(const sender: twidget;
                                    const hint: msestring);
var
 info: hintinfoty;
begin
 inithintinfo(info,sender);
 info.caption:= hint;
 showhint(sender,info);
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

procedure tguiapplication.help(const sender: tmsecomponent);
begin
 with tinternalapplication(self) do begin
  fonhelp.doevent(sender);
 end;
end;

procedure tguiapplication.registerhelphandler(const ahandler: helpeventty);
begin
 tinternalapplication(self).fonhelp.add(tmethod(ahandler));
end;

procedure tguiapplication.unregisterhelphandler(const ahandler: helpeventty);
begin
 tinternalapplication(self).fonhelp.remove(tmethod(ahandler));
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
  if value.fownerwidget.isgroupleader and value.haswinid then begin
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

procedure tguiapplication.dragstarted; //calls dragstarted of all known widgets
var
 int1: integer;
begin
 for int1:= 0 to high(fwindows) do begin
  fwindows[int1].fownerwidget.dragstarted;
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

procedure tguiapplication.registeronwidgetactivechanged(
                                           const method: widgetchangeeventty);
begin
 tinternalapplication(self).fonwidgetactivechangelist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronwidgetactivechanged(
                                            const method: widgetchangeeventty);
begin
 tinternalapplication(self).fonwidgetactivechangelist.remove(tmethod(method));
end;

procedure tguiapplication.registeronwindowactivechanged(
                                           const method: windowchangeeventty);
begin
 tinternalapplication(self).fonwindowactivechangelist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronwindowactivechanged(
                                            const method: windowchangeeventty);
begin
 tinternalapplication(self).fonwindowactivechangelist.remove(tmethod(method));
end;

procedure tguiapplication.registeronwindowdestroyed(
                                                 const method: windoweventty);
begin
 tinternalapplication(self).fonwindowdestroyedlist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronwindowdestroyed(
                                                 const method: windoweventty);
begin
 tinternalapplication(self).fonwindowdestroyedlist.remove(tmethod(method));
end;

procedure tguiapplication.registeronwiniddestroyed(const method: winideventty);
begin
 tinternalapplication(self).fonwiniddestroyedlist.add(tmethod(method));
end;

procedure tguiapplication.unregisteronwiniddestroyed(
                                                   const method: winideventty);
begin
 tinternalapplication(self).fonwiniddestroyedlist.remove(tmethod(method));
end;

procedure tguiapplication.registeronapplicationactivechanged(
                                                 const method: booleaneventty);
begin
 tinternalapplication(self).fonapplicationactivechangedlist.add(
                                                           tmethod(method));
end;

procedure tguiapplication.unregisteronapplicationactivechanged(
                                                const method: booleaneventty);
begin
 tinternalapplication(self).fonapplicationactivechangedlist.remove(
                                                             tmethod(method));
end;

procedure tguiapplication.registersyseventhandler(
                                      const method: syseventhandlereventty);
begin
 tinternalapplication(self).fonsyseventlist.add(tmethod(method)); 
end;

procedure tguiapplication.unregistersyseventhandler(
                                      const method: syseventhandlereventty);
begin
 tinternalapplication(self).fonsyseventlist.remove(tmethod(method)); 
end;

procedure tguiapplication.updatecursorshape;
                           //restores cursorshape of mousewidget
begin
 if fclientmousewidget <> nil then begin
  fclientmousewidget.updatecursorshape(fmousewidgetpos){(true)};
 end
 else begin
  widgetcursorshape:= cr_default;
 end;
end;

procedure tguiapplication.setcursorshape(const avalue: cursorshapety);
begin
 if fcursorshape <> avalue then begin
  fcursorshape:= avalue; //wanted shape
  if not waiting then begin
   if fthread <> sys_getcurrentthread then begin
    mouse.shape:= fcursorshape; //show new cursor immediately
   end
   else begin
    if avalue = cr_default then begin
     updatecursorshape;
    end;
   end;
  end;
 end;
end;

procedure tguiapplication.setwidgetcursorshape(const avalue: cursorshapety);
begin
 if fwidgetcursorshape <> avalue then begin
  fwidgetcursorshape:= avalue;
  if (avalue = cr_default) and (fclientmousewidget <> nil) then begin
   fclientmousewidget.updatecursorshape(fmousewidgetpos);
  end;
 end;
end;

procedure tguiapplication.beginwait(const aprocessmessages: boolean = false);
begin
 lock;
 try
  if fwaitcount = 0 then begin
   gui_resetescapepressed;
  end;
  inc(fwaitcount);
  mouse.shape:= cr_wait;
  inherited;
 finally
  unlock;
 end;
end;

procedure tguiapplication.endwait;
var
 int1: integer;
 po1: ^tmseevent;
begin
 lock;
 try
  if fwaitcount > 0 then begin
   dec(fwaitcount);
   if (fwaitcount = 0) and (fnoignorewaitevents = 0) then begin
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
 result:= waiting;
 if result then begin
  result:= gui_escapepressed;
  if not result then begin
   tinternalapplication(self).getevents;
   result:= gui_escapepressed;
  end;
 end;
 unlock;
end;

procedure tguiapplication.langchanged;
begin
 inherited;
 invalidate;
end;

function tguiapplication.candefocus(const caller: tobject = nil): boolean;
var
 int1: integer;
begin
 result:= true;
 for int1:= 0 to high(fwindows) do begin
  if (fwindows[int1] <> caller) and not fwindows[int1].candefocus then begin
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

function tguiapplication.terminate(const sender: twindow = nil): boolean;
var
 int1: integer;
begin
 include(fstate,aps_terminating);
 try
  int1:= 0;
  while int1 <= high(fwindows) do begin
   if (fwindows[int1] <> sender) and 
                not fwindows[int1].fownerwidget.canparentclose(nil) then begin
    exit;
   end;
   inc(int1);
  end; 
  tinternalapplication(self).doterminate(false);
 finally
  exclude(fstate,aps_terminating);
 end;
 result:= terminated;
end;

procedure tguiapplication.delayedmouseshift(const ashift: pointty);
begin
 addpoint1(fdelayedmouseshift,ashift);
end;

procedure tguiapplication.calcmousewheeldelta(var info: mousewheeleventinfoty;
               const fmin,fmax,deltamin,deltamax: real);  
var
 frequ: real;
begin
 if (flastmousewheeltimestamp <> 0) and 
                  (flastmousewheeltimestamp <> info.timestamp) then begin
  frequ:= 1000000/(info.timestamp-flastmousewheeltimestamp); //Hz
  if frequ > fmax then begin
   frequ:= fmax;
  end;
  if frequ < fmin then begin
   frequ:= fmin;
  end;
  info.delta:= (frequ*(deltamax-deltamin)+(deltamin*fmax-deltamax*fmin))/
                                   (fmax-fmin);
 end
 else begin
  info.delta:= deltamin;
 end;
 if info.wheel = mw_down then begin
  info.delta:= - info.delta;
 end;
end;

function tguiapplication.mousewheelacceleration(const avalue: real): real;
var
 info: mousewheeleventinfoty;
begin
 info.timestamp:= flastmousewheeltimestamp + flastmousewheeltimestamp -
                     flastmousewheeltimestampbefore;
 info.wheel:= mw_up;
 calcmousewheeldelta(info,fmousewheelfrequmin,fmousewheelfrequmax,1,
                      fmousewheelaccelerationmax);
 result:= avalue * info.delta;
end;

function tguiapplication.mousewheelacceleration(const avalue: integer): integer;
begin
 result:= round(mousewheelacceleration(avalue*1.0));
end;

procedure tguiapplication.clearkeyhistory;
begin
 include(fstate,aps_clearkeyhistory);
end;

procedure tguiapplication.invalidate;
var
 int1: integer;
begin
 for int1:= 0 to high(fwindows) do begin
  fwindows[int1].fownerwidget.invalidate;
 end;
end;

procedure tguiapplication.restarthint(const sender: twidget);
begin
 with tinternalapplication(self) do begin
  if fhintedwidget = sender then begin
   deactivatehint;
   fhinttimer.interval:= hintdelaytime;
   fhinttimer.enabled:= true;
  end;
 end;
end;

procedure tguiapplication.receiveevent(const event: tobjectevent);
begin
 if (event.kind = ek_user) then begin
  with tuserevent(event) do begin
   case tag of
    cancelwaittag: begin
     cancelwait;
    end
    else begin
     if event is tasyncmessageevent then begin
      with tasyncmessageevent(event) do begin
       showmessage(fmessage,fcaption);   
      end;
     end;
    end;
   end;
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

procedure tguiapplication.dowaitidle1(var again: boolean);
begin
 if fstate * [aps_waitok,aps_waitcanceled,aps_waitidlelock] = [] then begin
  include(fstate,aps_waitidlelock);
  fidleaction(self,again);
  if fstate * [aps_waitok,aps_waitcanceled] = [] then begin
   registeronidle({$ifdef FPC}@{$endif}dowaitidle1);
//   again:= true;
   exclude(fstate,aps_waitidlelock);
  end;
 end;
end;

function tguiapplication.waitdialog(const athread: tthreadcomp = nil;
               const atext: msestring = '';
               const caption: msestring = '';
               const acancelaction: notifyeventty = nil;
               const aexecuteaction: notifyeventty = nil;
               const aidleaction: waitidleeventty = nil): boolean;
var
// res1: modalresultty;
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
   fidleaction:= aidleaction;
   if assigned(aexecuteaction) then begin
    registeronidle({$ifdef FPC}@{$endif}dowaitidle);
   end;
   if assigned(aidleaction) then begin
    registeronidle({$ifdef FPC}@{$endif}dowaitidle1);
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
    unregisteronidle({$ifdef FPC}@{$endif}dowaitidle);
    unregisteronidle({$ifdef FPC}@{$endif}dowaitidle1);
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
 if not ismainthread then begin
  postevent(tuserevent.create(ievent(self),cancelwaittag));
 end
 else begin
  with tinternalapplication(self) do begin
   if not waitcanceled and (fmodalwindow <> fmodalwindowbeforewaitdialog) and
              (fmodalwindow <> nil) then begin
    fmodalwindow.modalresult:= mr_cancel;
   end;
  end;
 end;
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
                    aps_waitok,aps_waitidlelock];
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

procedure tguiapplication.sysevent(const awindow: winidty; 
                            var aevent: syseventty; var handled: boolean);
begin
 tinternalapplication(self).fonsyseventlist.doevent(awindow,aevent,handled);
end;

procedure tguiapplication.sethighrestimer(const avalue: boolean);
begin
 guierror(gui_sethighrestimer(avalue));
end;

procedure tguiapplication.dopostevent(const aevent: tmseevent);
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
 if us <= 0 then begin
  inherited;
 end
 else begin
  gui_settimer(us);
 end;
end;

procedure tguiapplication.doafterrun;
begin
 if not (apo_noautodestroymodules in foptions) then begin
  destroyforms(); //zeos lib unloads libraries -> 
               //forms must be destroyed before unit finalization
 end;
end;

function tguiapplication.idle: boolean;
begin
 result:= inherited idle and not gui_hasevent;
end;

function tguiapplication.shortcutting: boolean;
begin
 result:= aps_shortcutting in fstate;
end;

function tguiapplication.modallevel: integer;
begin
 result:= -1;
 if flooplevel > 0 then begin
  result:= 0;
  if fcurrmodalinfo <> nil then begin
   result:= fcurrmodalinfo^.level;
  end;
 end;
end;

procedure tguiapplication.objecteventdestroyed(const sender: tobjectevent);
var
 po1: pmodalinfoty;
 int1: integer;
begin
 if sender.modallevel >= 0 then begin
  lock;
  po1:= fcurrmodalinfo;
  while po1 <> nil do begin
   for int1:= high(po1^.events) downto 0 do begin
    if po1^.events[int1] = sender then begin
     po1^.events[int1]:= nil;
    end;
   end;
   po1:= po1^.parent;
  end; 
  unlock;
 end;
end;

procedure tguiapplication.beginnoignorewaitevents;
begin
 interlockedincrement(fnoignorewaitevents);
end;

procedure tguiapplication.endnoignorewaitevents;
begin
 interlockeddecrement(fnoignorewaitevents);
end;

procedure tguiapplication.internalpackwindowzorder;
begin
 //dummy
end;

function tguiapplication.getforcezorder: boolean;
begin
 result:= gao_forcezorder in foptionsgui;
end;

procedure tguiapplication.setforcezorder(const avalue: boolean);
begin
 if avalue then begin
  optionsgui:= optionsgui + [gao_forcezorder];
 end
 else begin
  optionsgui:= optionsgui - [gao_forcezorder];
 end;
end;

{ tasyncmessageevent }

constructor tasyncmessageevent.create(const amessage: msestring;
                                            const acaption: msestring);
begin
 fmessage:= amessage;
 fcaption:= acaption;
 inherited create(ievent(application),0);
end;

{ tmousenterevent }

constructor tmouseenterevent.create(const winid: winidty; const pos: pointty;
               const shiftstate: shiftstatesty; atimestamp: longword);
begin
 inherited create(winid,false,mb_none,mw_none,pos,shiftstate,atimestamp);
 fkind:= ek_enterwindow;
end;

{ twidgetshowevent }

procedure twidgetshowevent.execute;
begin
 fmodalresult:= fwidget.show(fmodallevel,ftransientfor);
end;

{ tcreatewindowevent }

procedure tcreatewindowevent.execute;
begin
 fsender.fcanvas.updatewindowoptions(foptionspo^);
 guierror(gui_createwindow(frect,foptionspo^,fwindowpo^),fsender);
end;

{ tdestroywindowevent }

procedure tdestroywindowevent.execute;
begin
 if fwindowpo <> nil then begin
  gui_destroywindow(fwindowpo^);
 end;
end;

{ tfadecolorarrayprop }

constructor tfadecolorarrayprop.create;
begin
 inherited;
 fvaluedefault:= defaultfadecolor;
end;

{ tfadeopacolorarrayprop }

constructor tfadeopacolorarrayprop.create;
begin
 inherited;
 fvaluedefault:= defaultfadeopacolor;
end;

initialization
 registerapplicationclass(tinternalapplication);
end.
