{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegrids;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}{$goto on}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 {$ifdef FPC}classes,sysutils{$else}Classes,SysUtils{$endif},mseclasses,msegui,
 msegraphics,msetypes,msestrings,msegraphutils,msebitmap,
 msescrollbar,msearrayprops,mseglob,mseguiglob,typinfo,
 msedatalist,msedrawtext,msewidgets,mseevent,mseinplaceedit,mseeditglob,
 mseobjectpicker,msepointer,msetimer,msebits,msestat,msestatfile,msekeyboard,
 msestream,msedrag,msemenus,msepipestream,mseshapes,msegridsglob
 {$ifdef mse_with_ifi} ,mseificomp,mseifiglob,mseificompglob{$endif};

type
         //     listvievoptionty from mselistbrowser
         //     lvo_readonly,lvo_mousemoving,lvo_keymoving,lvo_horz,
 coloptionty = (co_readonly, co_nofocus,     co_invisible, co_disabled,
         //     lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
                co_drawfocus,co_mousemovefocus,co_leftbuttonfocusonly,
         //     lvo_noctrlmousefocus,
                co_noctrlmousefocus,
         //     lvo_focusselect,lvo_mouseselect,lvo_keyselect,
                co_focusselect, co_mouseselect, co_keyselect,
         //     lvo_multiselect,lvo_resetselectonexit{,lvo_noresetselect}
                co_multiselect, co_resetselectonexit,{co_noresetselect,}
                co_rowselect,

                co_fixwidth,co_fixpos,co_fill,co_proportional,co_nohscroll,
//                co_autorowheight,
                co_savevalue,co_savestate,
                co_rowfont,co_rowcolor,co_zebracolor, //deprecated -> co1_
                co_rowcoloractive,                    //deprecated -> co1_

                co_nosort,co_sortdescent,co_norearange,
                co_cancopy,co_canpaste,co_mousescrollrow,co_rowdatachange
                );
 coloptionsty = set of coloptionty;
// celloptionty = (ceo_autorowheight);
// celloptionsty = set of celloptionty;

 coloption1ty = (co1_rowfont,co1_rowcolor,co1_zebracolor,
                 co1_rowcoloractive,co1_rowcolorfocused,
//                 co1_active, //not used
                 co1_autorowheight);
 coloptions1ty = set of coloption1ty;

const
 deprecatedcoloptions = [co_rowfont,co_rowcolor,co_zebracolor,
                         co_rowcoloractive];
 invisiblecoloptions  = [ord(co_rowfont),ord(co_rowcolor),ord(co_zebracolor),
                         ord(co_rowcoloractive)];
// deprecatedcoloptions1 = [co1_active];

type
 fixcoloptionty = (fco_invisible,fco_mousefocus,fco_mouseselect,
                   fco_rowfont,fco_rowcolor,fco_zebracolor{,
                   fco_rowcoloractive,fco_rowcolorfocus}{fco_active});
 fixcoloptionsty = set of fixcoloptionty;
 fixrowoptionty = (fro_invisible,fro_mousefocus,fro_mouseselect);
 fixrowoptionsty = set of fixrowoptionty;

const
 fixcoloptionsshift1 = ord(fco_rowfont)-ord(co1_rowfont);
 fixcoloptionsmask: coloptions1ty =
                 [co1_rowfont,co1_rowcolor,co1_zebracolor{,
                  co1_rowcoloractive,co1_rowcolorfocus}];
  
 defaultfixcoloptions = [];
 defaultgridskinoptions = [osk_framebuttononly];
 sortglyphwidth = 11;
 defaultwheelscrollheight = 0;
 
 rowstatefoldleveltag = 0;
 rowstateissumtag = 1;
  
type
 optiongridty = (og_colsizing,og_colmoving,og_keycolmoving,
                 og_rowsizing,og_rowmoving,og_keyrowmoving,
                 og_rowinserting,og_rowdeleting,og_selectedrowsdeleting,
                 og_focuscellonenter,og_containerfocusbackonesc,
                 og_autofirstrow,og_autoappend,og_appendempty,
                 og_savestate,og_nosaveremoveappendedrow,og_sorted,
                 og_folded,og_colmerged,og_rowheight,
                 og_colchangeontabkey,og_colchangeonreturnkey,
                 og_wraprow,og_wrapcol,
                 og_visiblerowpagestep,
                 og_autopopup,
                 og_mousescrollcol,og_noresetselect);
 optionsgridty = set of optiongridty;

const
 rowstateoptions = [og_colmerged,og_rowheight]; //variable rowstate size
 
type
 pickobjectkindty = (pok_none,pok_fixcolsize,pok_fixcol,pok_datacolsize,pok_datacol,
                   pok_fixrowsize,pok_fixrow,pok_datarowsize,pok_datarow);

 stringcoleditoptionty = (
                    scoe_undoonesc,scoe_forcereturncheckvalue,scoe_eatreturn,
//                    scoe_autorowheight,

                    //same layout as editoptionty
                    scoe_exitoncursor,
                    scoe_nofirstarrownavig,
                    scoe_endonenter,
                    scoe_homeonenter,
                    scoe_autoselect, //selectall bei enter
                    scoe_autoselectonfirstclick,
                    scoe_caretonreadonly,
                    scoe_trimright,
                    scoe_trimleft,
                    scoe_uppercase,
                    scoe_lowercase,                    
                    scoe_hintclippedtext,                    
                    scoe_locate,
                    scoe_casesensitive
                          );

 stringcoleditoptionsty = set of stringcoleditoptionty;

const
 stringcoloptionseditmask: optionseditty = [
                    oe_exitoncursor,
                    oe_nofirstarrownavig,
                    oe_endonenter,
                    oe_homeonenter,
                    oe_autoselect, //selectall bei enter
                    oe_autoselectonfirstclick,
                    oe_caretonreadonly,
                    oe_trimright,
                    oe_trimleft,
                    oe_uppercase,
                    oe_lowercase,
                    oe_hintclippedtext,
                    oe_locate,
                    oe_casesensitive];
 stringcoloptionseditshift = ord(oe_exitoncursor) - 
                            ord(scoe_exitoncursor);

 gridvaluevarname = 'values';
 pickobjectstep = integer(high(pickobjectkindty)) + 1;
 layoutchangedcoloptions: coloptionsty = [co_fill,co_proportional,co_invisible,
                              co_nohscroll{,co_rowcoloractive}];
 layoutchangedcoloptions1: coloptions1ty = [co1_rowcoloractive,co1_rowcolorfocused];
 notfixcoloptions = [co_fixwidth,co_fixpos,co_fill,co_proportional,co_nohscroll,
                     co_rowdatachange];
 defaultoptionsgrid = [og_autopopup,og_colchangeontabkey,og_focuscellonenter,
                                   og_mousescrollcol,og_wrapcol];

 mousescrolldist = 5;
 griddefaultcolwidth = 50;
 griddefaultrowheight = 20;
 defaultcoltextflags = [tf_ycentered,tf_noselect];
 defaultactivecoltextflags = defaultcoltextflags - [tf_noselect];
 defaultgridlinewidth = 1;
 defaultdatalinecolor = cl_dkgray;
 defaultfixlinecolor = cl_black;

 defaultselectedcellcolor = cl_active;
 defaultdatacoloptions = [{co_selectedcolor,}co_savestate,co_savevalue,
                          {co_rowfont,co_rowcolor,co_zebracolor,}co_mousescrollrow];
 defaultdatacoloptions1 = [co1_rowfont,co1_rowcolor,co1_zebracolor];
 defaultfixcoltextflags = [tf_ycentered,tf_xcentered];
 defaultstringcoleditoptions = [scoe_exitoncursor,scoe_undoonesc,scoe_autoselect,
                                  scoe_autoselectonfirstclick,scoe_eatreturn];
// defaultcolheadertextflags = [tf_ycentered,tf_xcentered];


 slowrepeat = 200000; //us
 fastrepeat = 100000; //us

 defaultgridwidgetoptions = defaultoptionswidgetmousewheel + 
                                        [ow_focusbackonesc,ow_fontglyphheight];

type
 tgridexception = class(exception);

 gridstatety = (
      gs_layoutvalid,gs_layoutupdating,gs_updatelocked,gs_changelock,
//      gs_visiblerowsupdating,
      gs_sortvalid,gs_cellentered,gs_cellclicked,gs_emptyrowremoved,
      gs_rowcountinvalid,gs_rowreadonly,
      gs_scrollup,gs_scrolldown,gs_scrollleft,gs_scrollright,
      gs_selectionchanged,gs_rowdatachanged,gs_focusedcellchanged,gs_invalidated,
      gs_mouseentered,gs_childmousecaptured,gs_child,
      gs_mousecellredirected,gs_restorerow,gs_cellexiting,gs_rowremoving,
      gs_appending,
      gs_hasactiverowcolor,
      gs_needszebraoffset, //has zebrastep or autonumcol
      gs_needsrowheight,
      gs_islist,//contiguous select blocks
      gs_isdb); //do not change rowcount
 gridstatesty = set of gridstatety;
 gridstate1ty = (gs1_showcellinvalid);
 gridstates1ty = set of gridstate1ty;

 cellkindty = (ck_invalid,ck_data,ck_fixcol,ck_fixrow,ck_fixcolrow);
 griderrorty = (gre_ok,gre_invaliddatacell,gre_differentrowcount,
                gre_rowindex,gre_colindex,gre_invalidwidget);

 cellpositionty = (cep_nearest,cep_topleft,cep_top,cep_topright,cep_bottomright,
                   cep_bottom,cep_bottomleft,cep_left,
                   cep_rowcentered,cep_rowcenteredif);

const
 mousecellevents = [cek_mousemove,cek_mousepark,cek_firstmousepark,
                    cek_buttonpress,cek_buttonrelease];
 repeaterstates = [gs_scrollup,gs_scrolldown,gs_scrollleft,gs_scrollright];


type
 tcustomgrid = class;

 celleventinfoty = record //same layout as ificelleventinfoty
  cell: gridcoordty;
  grid: tcustomgrid;
  case eventkind: celleventkindty of
   cek_exit,cek_enter,cek_focusedcellchanged:
    (cellbefore,newcell: gridcoordty; selectaction: focuscellactionty);
   cek_select:
    (selected: boolean; accept: boolean);
   cek_mousemove,cek_mousepark,cek_firstmousepark,
   cek_buttonpress,cek_buttonrelease:
    (zone: cellzonety; mouseeventinfopo: pmouseeventinfoty;
                           gridmousepos: pointty);
   cek_keydown,cek_keyup:
    (keyeventinfopo: pkeyeventinfoty);
 end;
 pcelleventinfoty = ^celleventinfoty;

 tgridarrayprop = class;

 tcellframe = class(tframe)
  public
   constructor create(const intf: iframe);
  published
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
 end;

 tfixcellframe = class(tcellframe)
 end;
 
 tcellface = class(tface)
 end;

 tfixcellface = class(tcellface)
 end;

 rowfoldinfoty = record
  foldlevel: byte;
  isvisible: boolean;
  haschildren: boolean;
  isopen: boolean;
  nolines: booleanarty;
 end;
 prowfoldinfoty = ^rowfoldinfoty;
 rowfoldinfoarty = array of rowfoldinfoty;
 rowfoldinfoaty = array[0..0] of rowfoldinfoty;
 prowfoldinfoaty = ^rowfoldinfoaty;
  
 cellinfoty = record
  cell: gridcoordty;
  rect: rectty;
  innerrect: rectty;      //origin rect.pos
  frameinnerrect: rectty; //innerrect of cell frame or rect if nil
  color: colorty;
  colorline: colorty;
  font: tfont;
  selected: boolean;
  readonly: boolean;
  notext: boolean;
  ismousecell: boolean;
  datapo: pointer;
  griddatalink: pointer;
  rowstate: prowstatety;
  foldinfo: prowfoldinfoty;
  calcautocellsize: boolean; // don't paint
  autocellsize: sizety;
 end;
 pcellinfoty = ^cellinfoty;

 tgridpropfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 gridpropstatety = (gps_fix,gps_selected,gps_noinvalidate,gps_edited,
               gps_readonlyupdating,gps_selectionchanged,gps_changelock,
               gps_datalistvalid,gps_needsrowheight);
 gridpropstatesty = set of gridpropstatety;

 tgridprop = class(tindexpersistent,iframe,iface)
  private
   fcellrect: rectty;
   ftag: integer;
   function getframe: tcellframe;
   procedure setframe(const Value: tcellframe);
   function getface: tcellface;
   procedure setface(const Value: tcellface);
   procedure setcolor(const Value: colorty);
   function getfont: tgridpropfont;
   function isfontstored: Boolean;
   procedure setfont(const Value: tgridpropfont);
   procedure setlinewidth(const Value: integer);
   procedure setlinecolor(const Value: colorty);
   procedure setlinecolorfix(const Value: colorty);
   procedure setcolorselect(const Value: colorty);
   procedure setcoloractive(avalue: colorty);
   procedure setcolorfocused(avalue: colorty);
//   procedure setcursor(const avalue: cursorshapety);
  protected
   fstate: gridpropstatesty;
   fstart,fend: integer;
   flinepos: integer;
   flinewidth: integer;
   flinecolor: colorty;
   flinecolorfix: colorty;
   fcolor: colorty;
   fcursor: cursorshapety;
   ffont: tgridpropfont;
   fgrid: tcustomgrid;
   fframe: tcellframe;
   fface: tcellface;
   fcellinfo: cellinfoty;
   foptions: coloptionsty;
   fcolorselect: colorty;
   fcoloractive: colorty;
   fcolorfocused: colorty;
   procedure updatelayout; virtual;
   procedure changed; virtual;
   procedure updatecellrect(const aframe: tcustomframe);
   function getinnerframe: framety; virtual;
   function step(getscrollable: boolean = true): integer; virtual; abstract;

  //iframe
   function getwidget: twidget;
   procedure setframeinstance(instance: tcustomframe);
   function getwidgetrect: rectty;
   procedure setstaticframe(value: boolean);
   function getstaticframe: boolean;
   function widgetstate: widgetstatesty;
   procedure scrollwidgets(const dist: pointty);
   procedure clientrectchanged;
   function getcomponentstate: tcomponentstate;
   function getmsecomponentstate: msecomponentstatesty;
   procedure invalidate;
   procedure invalidatewidget;
   procedure invalidaterect(const rect: rectty; const org: originty = org_client;
                                  const noclip: boolean = false);
   function getframestateflags: framestateflagsty;
   procedure updatecellheight(const canvas: tcanvas; var aheight: integer); virtual;
  //iface
   function getclientrect: rectty;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
               const linkintf: iobjectlink = nil);
   procedure widgetregioninvalid;
   function translatecolor(const acolor: colorty): colorty;

   procedure fontchanged(const sender: tobject); virtual;
   property font: tgridpropfont read getfont write setfont stored isfontstored;
  public
   constructor create(const agrid: tcustomgrid; 
               const aprop: tgridarrayprop); reintroduce; virtual;
   destructor destroy; override;
   procedure createfont;
   procedure createframe;
   procedure createface;
   procedure drawcellbackground(const acanvas: tcanvas;
                 const aframe: tcustomframe; const aface: tcustomface);
   procedure drawcelloverlay(const acanvas: tcanvas; const aframe: tcustomframe);
   property grid: tcustomgrid read fgrid;
   property innerframe: framety read getinnerframe;
  published
   property color: colorty read fcolor write setcolor default cl_default;
   property cursor: cursorshapety read fcursor write fcursor default cr_default;
   property frame: tcellframe read getframe write setframe;
   property face: tcellface read getface write setface;
   property linewidth: integer read flinewidth write setlinewidth 
                                       default defaultgridlinewidth;
   property linecolor: colorty read flinecolor write setlinecolor;
   property linecolorfix: colorty read flinecolorfix write setlinecolorfix 
                                       default defaultfixlinecolor;
   property colorselect: colorty read fcolorselect write setcolorselect
                                       default cl_default;
   property coloractive: colorty read fcoloractive write setcoloractive
                                       default cl_none;
   property colorfocused: colorty read fcolorfocused write setcolorfocused
                                       default cl_none;
   property tag: integer read ftag write ftag default 0;
 end;

 gridpropclassty = class of tgridprop;

 colpaintinfoty = record
  canvas: tcanvas;
  ystart,ystep: integer;
  rows: integerarty;
  foldinfo: rowfoldinfoarty;
  startrow,endrow: integer; //index in rows
  calcautocellsize: boolean;
  autocellsize: sizety;
 end;

 tcols = class;
 rangety = record
  startindex,endindex: integer;
 end;
 cellaxisrangety = record
  scrollables: boolean;
  range1,range2: rangety;
 end;
 rowpaintinfoty = record
  canvas: tcanvas;
  cols: tcols;
  colrange: cellaxisrangety;
  fix: boolean;
 end;
 rowspaintinfoty = record
  rowinfo: rowpaintinfoty;
  rowrange: cellaxisrangety;
 end;

 tcolselectfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 tcol = class;
 
 celleventty = procedure(const sender: tobject; var info: celleventinfoty) of object;
 drawcelleventty = procedure(const sender: tcol; const canvas: tcanvas;
                          const cellinfo: cellinfoty) of object;
 beforedrawcelleventty = procedure(const sender: tcol; const canvas: tcanvas;
                          var cellinfo: cellinfoty; var processed: boolean) of object;
 tcol = class(tgridprop)
  private
   frowfontoffset: integer;
   frowfontoffsetselect: integer;
   frowcoloroffset: integer;
   fonbeforedrawcell: beforedrawcelleventty;
   fonafterdrawcell: drawcelleventty;
   frowcoloroffsetselect: integer;
   ffontactivenum: integer;
   ffontfocusednum: integer;
   function getcolindex: integer;
   procedure setfocusrectdist(const avalue: integer);
   procedure updatepropwidth;
   procedure setrowcoloroffset(const avalue: integer);
   procedure setrowcoloroffsetselect(const avalue: integer);
   procedure setrowfontoffset(const avalue: integer);
   procedure setrowfontoffsetselect(const avalue: integer);
   function getfontselect: tcolselectfont;
   function isfontselectstored: Boolean;
   procedure setfontselect(const Value: tcolselectfont);

   procedure setfontactivenum(const avalue: integer);
   procedure setfontfocusednum(const avalue: integer);
  protected
   foptions1: coloptions1ty;
   fwidth: integer;
   fpropwidth: real;
   ffontselect: tcolselectfont;
   ffocusrectdist: integer;
   procedure createfontselect;
   function getselected(const row: integer): boolean; virtual;
   procedure setwidth(const Value: integer); virtual;
   procedure invalidatelayout;
   procedure setoptions(const Value: coloptionsty); virtual;
   procedure setoptions1(const avalue: coloptions1ty); virtual;
   procedure updatelayout; override;
   procedure rearange(const list: tintegerdatalist); virtual; abstract;

   function checkactivecolor(const aindex: integer): boolean;
         //true if coloractive and fontactivenum active
   function checkfocusedcolor(const aindex: integer): boolean;
         //true if colorfocus and fontfocusnum active
   function isopaque: boolean; virtual;
   function getdatapo(const arow: integer): pointer; virtual;
   procedure clean(const start,stop: integer); virtual;
   procedure paint(var info: colpaintinfoty); virtual;
   class function defaultstep(width: integer): integer; virtual;
   function step(getscrollable: boolean = true): integer; override;
   procedure drawcell(const acanvas: tcanvas); virtual;
   procedure drawfocusedcell(const acanvas: tcanvas); virtual;
   procedure rowcountchanged(const newcount: integer); virtual;
   procedure drawfocus(const acanvas: tcanvas); virtual;
   procedure moverow(const curindex,newindex: integer;
                  const count: integer = 1); virtual; abstract;
   procedure insertrow(const aindex: integer;
                  const count: integer = 1); virtual; abstract;
   procedure deleterow(const aindex: integer;
                  const count: integer = 1); virtual; abstract;
   property options: coloptionsty read foptions write setoptions;
   property options1: coloptions1ty read foptions1 write setoptions1 default [];
   property focusrectdist: integer read ffocusrectdist write setfocusrectdist
                                        default 0;
   function getmerged(const row: integer): boolean; virtual;
   procedure setmerged(const row: integer; const avalue: boolean); virtual;
   property merged[const row: integer]: boolean read getmerged write setmerged;   
  public
   constructor create(const agrid: tcustomgrid; 
                        const aowner: tgridarrayprop); override;
   destructor destroy; override;
   procedure invalidate;
   procedure invalidatecell(const arow: integer);
   function rowcolor(const aindex: integer): colorty;
   function rowfont(const aindex: integer): tfont;
   procedure changed; override;
   procedure cellchanged(const row: integer); virtual;
   function actualcolor: colorty;
   function actualfont: tfont; virtual;
   property colindex: integer read getcolindex;
   function translatetocell(const arow: integer; const apos: pointty): pointty;
  published
   property width: integer read fwidth write setwidth 
                 {stored iswidthstored} default griddefaultcolwidth;
   property rowcoloroffset: integer read frowcoloroffset 
                               write setrowcoloroffset default 0;
   property rowcoloroffsetselect: integer read frowcoloroffsetselect
                               write setrowcoloroffsetselect default 0;
   property rowfontoffset: integer read frowfontoffset write 
                               setrowfontoffset default 0;
   property rowfontoffsetselect: integer read frowfontoffsetselect write 
                               setrowfontoffsetselect default 0;
   property fontselect: tcolselectfont read getfontselect write
                     setfontselect stored isfontselectstored;
   property fontactivenum: integer read ffontactivenum 
                                write setfontactivenum default -1;
             //index in grid.rowfonts
   property fontfocusednum: integer read ffontfocusednum 
                                write setfontfocusednum default -1;
             //index in grid.rowfonts
   property onbeforedrawcell: beforedrawcelleventty read fonbeforedrawcell
                                write fonbeforedrawcell;
   property onafterdrawcell: drawcelleventty read fonafterdrawcell
                                write fonafterdrawcell;
 end;

 tdatacol = class;

 showcolhinteventty = procedure(const sender: tdatacol; const arow: integer;
                           var info: hintinfoty) of object;
 datacoleventty = procedure(const sender: tdatacol) of object;
 datacolchangeeventty = procedure(const sender: tdatacol;
                                      const aindex: integer) of object;

 tdatacol = class(tcol)
  private
   fwidthmax: integer;
   fwidthmin: integer;
   foncellevent: celleventty;
   fonshowhint: showcolhinteventty;
   fselectedrow: integer; //-1 none, -2 more than one
   fonselectionchanged: datacoleventty;
   fselectlock: integer;
   procedure internaldoentercell(const cellbefore: gridcoordty;
                      var newcell: gridcoordty; const action: focuscellactionty);
   procedure internaldoexitcell(const cellbefore: gridcoordty;
                      var newcell: gridcoordty; const selectaction: focuscellactionty);
   procedure setwidthmax(const Value: integer);
   procedure setwidthmin(const Value: integer);
   function getcellorigin: pointty;
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
   function getenabled: boolean;
   procedure setenabled(const avalue: boolean);
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   function getselectedcells: integerarty;
   procedure setselectedcells(const avalue: integerarty);
   function getmerged(const row: integer): boolean; override;
   procedure setmerged(const row: integer; const avalue: boolean); override;
   procedure setdata(const avalue: tdatalist);
  protected
   fdata: tdatalist;
   fname: string;
   fnameb: string;
   fonchange: datacolchangeeventty;
   procedure beginselect;
   procedure endselect;
   function getdatapo(const arow: integer): pointer; override;
   function getrowdatapo: pointer;
   procedure beforedragevent(var ainfo: draginfoty; const arow: integer;
                                     var processed: boolean); virtual;
   procedure afterdragevent(var ainfo: draginfoty; const arow: integer;
                                     var processed: boolean); virtual;
   procedure doselectionchanged;
   procedure setselected(const row: integer; value: boolean); virtual;
   function getselected(const row: integer): boolean; override;
   procedure setoptions(const Value: coloptionsty); override;
   function createdatalist: tdatalist; virtual;
   procedure rowcountchanged(const newcount: integer); override;
   procedure dofocusedcellchanged(enter: boolean;
               const cellbefore: gridcoordty; var newcell: gridcoordty;
               const selectaction: focuscellactionty); virtual;
   procedure doactivate; virtual;
   procedure dodeactivate; virtual;
   procedure clientmouseevent(const acell: gridcoordty; 
                                          var info: mouseeventinfoty); virtual;
   procedure dokeyevent(var info: keyeventinfoty; up: boolean); virtual;
   procedure checkdirtyautorowheight(aindex: integer);
   procedure afterrowcountupdate; virtual;
   procedure itemchanged(const sender: tdatalist; const aindex: integer); virtual;
   procedure updatelayout; override;
   procedure moverow(const fromindex,toindex: integer; const count: integer = 1); override;
   procedure insertrow(const aindex: integer; const count: integer = 1); override;
   procedure deleterow(const aindex: integer; const count: integer = 1); override;
   procedure rearange(const list: tintegerdatalist); override;
   procedure sortcompare(const index1,index2: integer; var result: integer); virtual;
   function isempty(const aindex: integer): boolean; virtual;
   procedure docellevent(var info: celleventinfoty); virtual;
   function getcursor(const arow: integer; 
                        const actcellzone: cellzonety): cursorshapety; virtual;
   function getdatastatname: msestring;
   procedure coloptionstoeditoptions(var dest: optionseditty);
   procedure clean(const start,stop: integer); override;
  public
   constructor create(const agrid: tcustomgrid;
                                     const aowner: tgridarrayprop); override;
   destructor destroy; override;

   function canfocus(const abutton: mousebuttonty;
                     const ashiftstate: shiftstatesty;
                     out canrowfocus: boolean): boolean; virtual;
   function isreadonly: boolean; //col readonly or row readonly
   procedure updatecellzone(const row: integer; const pos: pointty;
                                       var result: cellzonety); virtual;
   property datalist: tdatalist read fdata write setdata;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure clearselection;
   property merged;
   property selected[const row: integer]: boolean read getselected write setselected;
             //row < 0 -> whole col
   property selectedcells: integerarty read getselectedcells 
                                                write setselectedcells;
   function selectedcellcount: integer;
   property cellorigin: pointty read getcellorigin;    //org = grid.paintpos
   property visible: boolean read getvisible write setvisible;
   property enabled: boolean read getenabled write setenabled;
   property readonly: boolean read getreadonly write setreadonly;
  published
   property options default defaultdatacoloptions;
   property options1 default defaultdatacoloptions1;
   property widthmin: integer read fwidthmin write setwidthmin default 1;
   property widthmax: integer read fwidthmax write setwidthmax default 0;
   property name: string read fname write fname;
   property nameb: string read fnameb write fnameb; //ex. sumlevel
   property onchange: datacolchangeeventty read fonchange write fonchange;
   property oncellevent: celleventty read foncellevent write foncellevent;
   property onshowhint: showcolhinteventty read fonshowhint write fonshowhint;
   property onselectionchanged: datacoleventty read fonselectionchanged write
                                          fonselectionchanged;
   property linecolor default defaultdatalinecolor;
 end;

 datacolaty = array[0..0] of tdatacol;
 pdatacolaty = ^datacolaty;
 
 tdrawcol = class(tdatacol)
  private
   fondrawcell: drawcelleventty;
  protected
   procedure drawcell(const canvas: tcanvas); override;
  published
   property focusrectdist;
   property ondrawcell: drawcelleventty read fondrawcell write fondrawcell;
   property font;
 end;

 tstringcoldatalist = class(tmsestringdatalist)
  private
   fgrid: tcustomgrid;
   fnoparagraph: integerarty;
  protected
   procedure afterrowcountupdate;
   function getnoparagraphs(index: integer): boolean; override;
  public
   constructor create(const agrid: tcustomgrid);
   function add(const avalue: msestring; const anoparagraph: boolean): integer; 
                                                              override;
   function getparagraph(const index: integer;
                               const aseparator: msestring = ''): msestring;   
 end;
 
 tcustomstringcol = class(tdatacol)
  private
   ftextflagsactive: textflagsty;
   fonsetvalue: setstringeventty;
   fondataentered: notifyeventty;
   foncopytoclipboard: updatestringeventty;
   fonpastefromclipboard: updatestringeventty;
   procedure settextflags(const avalue: textflagsty);
   function getdatalist: tstringcoldatalist;
   procedure setdatalist(const value: tstringcoldatalist);
   procedure settextflagsactive(const avalue: textflagsty);
  protected
   ftextinfo: drawtextinfoty;
   foptionsedit: stringcoleditoptionsty;
   foptionsedit1: optionsedit1ty;
   procedure setisdb;
   function getoptionsedit: optionseditty;
   function getitems(aindex: integer): msestring; virtual;
   procedure setitems(aindex: integer; const Value: msestring); virtual;
   function createdatalist: tdatalist; override;
   procedure afterrowcountupdate; override;
   procedure updatedisptext(var avalue: msestring); virtual;
   function getrowtext(const arow: integer): msestring; virtual;
   procedure drawcell(const canvas: tcanvas); override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure updatelayout; override;
   function getinnerframe: framety; override;
   function getcursor(const arow: integer;
                        const actcellzone: cellzonety): cursorshapety; override;
   procedure modified; virtual;
  public
   constructor create(const agrid: tcustomgrid; 
                         const aowner: tgridarrayprop); override;
   destructor destroy; override;
   function edited: boolean;
   procedure readpipe(const pipe: tpipereader; 
                      const processeditchars: boolean = false;
                      const maxchars: integer = 0); overload;
   procedure readpipe(const text: string; 
                      const processeditchars: boolean = false;
                      const maxchars: integer = 0); overload;
   property items[aindex: integer]: msestring read getitems write setitems; default;
   property textflags: textflagsty read ftextinfo.flags write settextflags
                          default defaultcoltextflags;
   property textflagsactive: textflagsty read ftextflagsactive
             write settextflagsactive default defaultactivecoltextflags;
   property optionsedit: stringcoleditoptionsty read foptionsedit 
               write foptionsedit default defaultstringcoleditoptions;
   property optionsedit1: optionsedit1ty read foptionsedit1
                             write foptionsedit1 default defaultoptionsedit1;
   property font;
   property datalist: tstringcoldatalist read getdatalist write setdatalist;
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property ondataentered: notifyeventty read fondataentered write fondataentered;
   property oncopytoclipboard: updatestringeventty read foncopytoclipboard 
                  write foncopytoclipboard;
   property onpastefromclipboard: updatestringeventty read fonpastefromclipboard 
                  write fonpastefromclipboard;
       
 end;

 tstringcol = class(tcustomstringcol)
  published
   property focusrectdist;
   property textflags;
   property textflagsactive;
   property optionsedit;
   property optionsedit1;
   property font;
   property datalist;
   property fontselect;
   property onsetvalue;
   property ondataentered;
   property oncopytoclipboard;
   property onpastefromclipboard;
 end;
 
 stringcolclassty = class of tcustomstringcol;
 
 tfixcol = class(tcol)
  private
   fnumstart: integer;
   fnumstep: integer;
   fcaptions: tmsestringdatalist;
   foptionsfix: fixcoloptionsty;
   procedure settextflags(const Value: textflagsty);
   procedure setnumstart(const Value: integer);
   procedure setnumstep(const Value: integer);
   procedure setcaptions(const Value: tmsestringdatalist);
   function getcaptions: tmsestringdatalist;
   function iscaptionsstored: Boolean;
   procedure captionchanged(const sender: tdatalist; const aindex: integer);
   procedure setoptionsfix(const avalue: fixcoloptionsty);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
  protected
   ftextinfo: drawtextinfoty;
   procedure setoptions(const Value: coloptionsty); override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure moverow(const fromindex,toindex: integer; const count: integer = 1); override;
   procedure insertrow(const aindex: integer; const count: integer = 1); override;
   procedure deleterow(const aindex: integer; const count: integer = 1); override;
   procedure paint(var info: colpaintinfoty); override;
   procedure rearange(const list: tintegerdatalist); override;
  public
   constructor create(const agrid: tcustomgrid;
                            const aowner: tgridarrayprop); override;
   destructor destroy; override;
   property visible: boolean read getvisible write setvisible;
  published
   property linewidth;
   property linecolor default defaultfixlinecolor;
   property textflags: textflagsty read ftextinfo.flags write settextflags
                default defaultfixcoltextflags;
   property numstart: integer read fnumstart write setnumstart default 0;
   property numstep: integer read fnumstep write setnumstep default 0;
   property captions: tmsestringdatalist
              read getcaptions write setcaptions stored iscaptionsstored;
   property color default cl_parent;
   property options: fixcoloptionsty read foptionsfix write setoptionsfix 
                       default defaultfixcoloptions;
   property font;
 end;

 tcolheaderfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 cellmergeflagty = (cmf_h,cmf_v,cmf_rline);
 cellmergeflagsty = set of cellmergeflagty;
 
 tcolheader = class(tindexpersistent,iframe,iface,iimagelistinfo)
  private
   finfo: captioninfoty;
   ffont: tcolheaderfont;
   fcolor: colorty;
   fhint: msestring;
   fmergecols: integer;
   fmergerows: integer;
   fmergeflags: cellmergeflagsty;
   fmergedcx: integer;
   fmergedx: integer;
   fmergedcy: integer;
   fmergedy: integer;
   frefcell: gridcoordty;
   procedure setcaption(const avalue: msestring);
   procedure settextflags(const avalue: textflagsty);
   function getfont: tcolheaderfont;
   procedure setfont(const Value: tcolheaderfont);
   function isfontstored: Boolean;
   procedure createfont;
   function getframe: tfixcellframe;
   procedure setframe(const avalue: tfixcellframe);
   function getface: tfixcellface;
   procedure setface(const avalue: tfixcellface);
   procedure createframe;
   procedure createface;
   procedure setcolor(const avalue: colorty);
   procedure setmergecols(const avalue: integer);
   procedure setmergerows(const avalue: integer);
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenr(const avalue: imagenrty);
   procedure setcolorglyph(const avalue: colorty);
   procedure setimagepos(const avalue: imageposty);
   procedure setimagedist(const avalue: integer);
   procedure setcaptiondist(const avalue: integer);
   procedure readcaptionpos(reader: treader);
  protected
   fgrid: tcustomgrid;
   fframe: tfixcellframe;
   fface: tfixcellface;
   procedure defineproperties(filer: tfiler); override;
   procedure changed;
   procedure fontchanged(const sender: tobject);
   procedure drawcell(const acanvas: tcanvas; const adest: rectty); virtual;

    //iframe
   function getwidget: twidget;
   procedure setframeinstance(instance: tcustomframe);
   function getwidgetrect: rectty;
   procedure setstaticframe(value: boolean);
   function getstaticframe: boolean;
   function widgetstate: widgetstatesty;
   procedure scrollwidgets(const dist: pointty);
   procedure clientrectchanged;
   function getcomponentstate: tcomponentstate;
   function getmsecomponentstate: msecomponentstatesty;
   procedure invalidate;
   procedure invalidatewidget;
   procedure invalidaterect(const rect: rectty; const org: originty = org_client;
                              const noclip: boolean = false);
   function getframestateflags: framestateflagsty;
   //iface
   function getclientrect: rectty;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil);
   procedure widgetregioninvalid;
   function translatecolor(const acolor: colorty): colorty;
   //iimagelistinfo
   function getimagelist: timagelist;   
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); override;
   destructor destroy; override;   
   property mergedcx: integer read fmergedcx;
   property mergedx: integer read fmergedx;
   property mergedcy: integer read fmergedcy;
   property mergedy: integer read fmergedy;
  published
   property color: colorty read fcolor write setcolor default cl_parent;
   property caption: msestring read finfo.caption.text write setcaption;
   property textflags: textflagsty read finfo.textflags write settextflags
                                             default defaultcaptiontextflags;
   property font: tcolheaderfont read getfont write setfont stored isfontstored;
   property frame: tfixcellframe read getframe write setframe;
   property face: tfixcellface read getface write setface;
   property mergecols: integer read fmergecols write setmergecols default 0;
   property mergerows: integer read fmergerows write setmergerows default 0;
   property hint: msestring read fhint write fhint;
   property imagelist: timagelist read finfo.imagelist write setimagelist;
   property imagenr: imagenrty read finfo.imagenr write setimagenr default -1;
   property imagedist: integer read finfo.imagedist write setimagedist
                                            default 0;
   property captiondist: integer read finfo.captiondist write setcaptiondist
                                     default defaultshapecaptiondist;
   property imagepos: imageposty read finfo.imagepos write setimagepos 
                                                     default ip_right;
//   property captionpos: captionposty read finfo.captionpos write setcaptionpos 
//                                                     default cp_left;
   property colorglyph: colorty read finfo.colorglyph
                   write setcolorglyph default cl_glyph;
                   //cl_none -> no no glyph
 end;

 datacolheaderoptionty = (dco_colsort);
 datacolheaderoptionsty = set of datacolheaderoptionty;
 
 tdatacolheader = class(tcolheader)
  private
   foptions: datacolheaderoptionsty;
   procedure setoptions(const avalue: datacolheaderoptionsty);
  protected
   procedure drawcell(const acanvas: tcanvas; const adest: rectty); override;
  published
   property options: datacolheaderoptionsty read foptions write setoptions
                            default [];
 end;
 
 tcolheaders = class(tindexpersistentarrayprop)
  private
   fgridprop: tgridprop;
   ffixcol: boolean;
  protected
   procedure movecol(const curindex,newindex: integer);
   procedure colcountchanged(const acount: integer);
   procedure updatelayout(const cols: tgridarrayprop);
   procedure dosizechanged; override;
  public
   constructor create(const agridprop: tgridprop); reintroduce;
 end;

 tfixcolheaders = class(tcolheaders)
  private
   function getitems(const index: integer): tcolheader;
   procedure setitems(const index: integer; const Value: tcolheader);
  public
   constructor create(const agridprop: tgridprop);
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tcolheader read getitems
                 write setitems; default;
 end;

 tdatacolheaders = class(tcolheaders)
  private
   function getitems(const index: integer): tdatacolheader;
   procedure setitems(const index: integer; const Value: tdatacolheader);
  public
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tdatacolheader read getitems
                 write setitems; default;
 end;
 
 tfixrow = class;
 beforefixdrawcelleventty = procedure(const sender: tfixrow; const canvas: tcanvas;
                          var cellinfo: cellinfoty; var processed: boolean) of object;
 drawfixcelleventty = procedure(const sender: tfixrow; const canvas: tcanvas;
                          const cellinfo: cellinfoty) of object;
 
 tfixrows = class;
 tfixrow = class(tgridprop)
  private
   fheight: integer;
   fnumstart: integer;
   fnumstep: integer;
   fcaptions: tdatacolheaders;
   fcaptionsfix: tfixcolheaders;
   foptionsfix: fixrowoptionsty;
   fonbeforedrawcell: beforefixdrawcelleventty;
   fonafterdrawcell: drawfixcelleventty;
   procedure setheight(const Value: integer);
   function getrowindex: integer;
   procedure captionchanged(const sender: tarrayprop; const aindex: integer);
   procedure setnumstart(const Value: integer);
   procedure setnumstep(const Value: integer);
   procedure settextflags(const Value: textflagsty);
   procedure setcaptions(const Value: tdatacolheaders);
   procedure setcaptionsfix(const Value: tfixcolheaders);
   procedure setoptionsfix(const avalue: fixrowoptionsty);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
  protected
   ftextinfo: drawtextinfoty;
   procedure datacolscountchanged(const acount: integer);
   procedure fixcolscountchanged(const acount: integer);
   procedure cellchanged(const col: integer); virtual;
   procedure changed; override;
   procedure updatelayout; override;
   procedure updatemergedcells;
   function step(getscrollable: boolean = true): integer; override;
   procedure paint(const info: rowpaintinfoty); virtual;
   procedure drawcell(const canvas: tcanvas);{ virtual;}
   procedure movecol(const curindex,newindex: integer; const aisfix: boolean);
   procedure orderdatacols(const neworder: integerarty);
   procedure buttoncellevent(var info: celleventinfoty);
  public
   constructor create(const agrid: tcustomgrid; 
                        const aowner: tgridarrayprop); override;
   destructor destroy; override;
   procedure synctofontheight;
   property rowindex: integer read getrowindex;
   property visible: boolean read getvisible write setvisible;
  published
   property height: integer read fheight write setheight;
   property textflags: textflagsty read ftextinfo.flags write settextflags
                default defaultfixcoltextflags;
   property numstart: integer read fnumstart write setnumstart default 0;
   property numstep: integer read fnumstep write setnumstep default 0;
   property captions: tdatacolheaders read fcaptions write setcaptions;
   property captionsfix: tfixcolheaders read fcaptionsfix write setcaptionsfix;
   property font;
   property linecolor default defaultfixlinecolor;
   property options: fixrowoptionsty read foptionsfix 
                       write setoptionsfix default [];
   property onbeforedrawcell: beforefixdrawcelleventty read fonbeforedrawcell
                                write fonbeforedrawcell;
   property onafterdrawcell: drawfixcelleventty read fonafterdrawcell
                                write fonafterdrawcell;
 end;

 tgridarrayprop = class(tindexpersistentarrayprop)
  private
   ffirstsize: integer;
   ftotsize: integer;
   foppositecount: integer;
   ffirstopposite: integer;
   flinewidth: integer;
   flinecolor: colorty;
   flinecolorfix: colorty;
   fcolorselect: colorty;
   fcoloractive: colorty;
   fcolorfocused: colorty;
   finnerframe: framety;
   fcursor: cursorshapety;
   procedure setlinewidth(const Value: integer);
   procedure setlinecolor(const Value: colorty);
   procedure setlinecolorfix(const Value: colorty);
   procedure setcolorselect(const avalue: colorty);
   procedure setcoloractive(avalue: colorty);
   procedure setcolorfocused(avalue: colorty);
   procedure setinnerframe(const avalue: framety);
   procedure setinnerframe_left(const avalue: integer);
   procedure setinnerframe_top(const avalue: integer);
   procedure setinnerframe_right(const avalue: integer);
   procedure setinnerframe_bottom(const avalue: integer);
   procedure setcursor(const avalue: cursorshapety);
  protected
   freversedorder: boolean;
   fgrid: tcustomgrid;
   function geotoindex(const ageoindex: integer): integer;
   function geoitems(const aindex: integer): tgridprop;
   procedure updatelayout; virtual;
   function getclientsize: integer; virtual; abstract;
   procedure setoppositecount(const value: integer);
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure countchanged; virtual;
   function scrollablecount: integer;
   procedure dochange(const aindex: integer); override;
   procedure getindexrange(startpos,length: integer;
                 out range: cellaxisrangety; ascrollables: boolean = true);
   function itematpos(const pos: integer; 
               const getscrollable: boolean = true): integer; //-1 if none
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure fontchanged;
   procedure checktemplate(const sender: tobject);
  public
   constructor create(aowner: tcustomgrid; aclasstype: gridpropclassty); reintroduce;
   function fixindex(const index: integer): integer;
   property oppositecount: integer read foppositecount write setoppositecount default 0;
   property innerframe: framety read finnerframe write setinnerframe;
  published
   property cursor: cursorshapety read fcursor write setcursor default cr_default;
   property linewidth: integer read flinewidth
                write setlinewidth default defaultgridlinewidth;
   property linecolor: colorty read flinecolor
                write setlinecolor;
   property linecolorfix: colorty read flinecolorfix
                write setlinecolorfix default defaultfixlinecolor;
   property colorselect: colorty read fcolorselect write setcolorselect
              default cl_default;
   property coloractive: colorty read fcoloractive write setcoloractive
              default cl_none;
   property colorfocused: colorty read fcolorfocused write setcolorfocused
              default cl_none;
   property innerframe_left: integer read finnerframe.left 
                              write setinnerframe_left default 1;
   property innerframe_top: integer read finnerframe.top 
                              write setinnerframe_top default 1;
   property innerframe_right: integer read finnerframe.right 
                              write setinnerframe_right default 1;
   property innerframe_bottom: integer read finnerframe.bottom 
                              write setinnerframe_bottom default 1;
 end;

 tcolsfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tcols = class(tgridarrayprop)
  private
   fwidth: integer;
   foptions: coloptionsty;
   foptions1: coloptions1ty;
   ffocusrectdist: integer;
   ffontactivenum: integer;
   ffontfocusednum: integer;
   ffontselect: tcolsfont;
   function getcols(const index: integer): tcol;
   procedure setwidth(const value: integer);
   procedure setoptions(const Value: coloptionsty);
   procedure setoptions1(const Value: coloptions1ty);
   procedure setfocusrectdist(const avalue: integer);
   procedure setfontactivenum(const avalue: integer);
   procedure setfontfocusednum(const avalue: integer);
   function getfontselect: tcolsfont;
   function isfontselectstored: Boolean;
   procedure setfontselect(const Value: tcolsfont);
   procedure createfontselect;
   procedure fontselectchanged(const sender: tobject);
  protected
   fdataupdating: integer;
   procedure begindataupdate; virtual;
   procedure enddataupdate; virtual;
   function getclientsize: integer; override;
   procedure paint(var info: colpaintinfoty; const scrollables: boolean = true);
   procedure updaterowheight(const arow: integer; var arowheight: integer);
   function totwidth: integer;
   procedure rowcountchanged(const newcount: integer); virtual;
   procedure updatelayout; override;
   procedure moverow(const curindex,newindex: integer;
                const acount: integer = 1); virtual;
   procedure insertrow(const index: integer; const acount: integer = 1); virtual;
   procedure deleterow(const index: integer; const acount: integer = 1); virtual;
   procedure rearange(const list: tintegerdatalist); virtual;
   property options: coloptionsty read foptions
                write setoptions default [];
   property options1: coloptions1ty read foptions1
                write setoptions1 default [];
  public
   constructor create(aowner: tcustomgrid; aclasstype: gridpropclassty);
   destructor destroy; override;
   procedure move(const curindex,newindex: integer); override;
   function mergedwidth(const acol: integer; const amerged: longword): integer;
                    //returns additional width
   property cols[const index: integer]: tcol read getcols; default;
   property focusrectdist: integer read ffocusrectdist 
                                write setfocusrectdist default 0;
   property fontselect: tcolsfont read getfontselect 
                    write setfontselect stored isfontselectstored;
  published
   property width: integer read fwidth
                write setwidth default griddefaultcolwidth;
   property fontactivenum: integer read ffontactivenum 
                                write setfontactivenum default -1;
             //index in grid.rowfonts
   property fontfocusednum: integer read ffontfocusednum 
                                write setfontfocusednum default -1;
             //index in grid.rowfonts
 end;

 trowstatelist = class(tcustomrowstatelist
                         {$ifdef mse_with_ifi},iifidatalink{$endif})
  private
   fdirtyvisible: integer;
   fdirtyrow: integer;
   fdirtyrowheight: integer;
   fdirtyautorowheight: integer;
   ffolded: boolean;
   fgrid: tcustomgrid;
   fhiddencount: integer;
   fvisiblerows: integerarty;
   fvisiblerowmap: tintegerdatalist;
   ffoldchangedrow: integer;
   ftopypos: integer;
   flinkfoldlevel: listlinkinfoty;
   flinkissum: listlinkinfoty;
   ffoldlevelsourcelock: integer;
   fissumsourcelock: integer;
//  {$ifdef mse_with_ifi}
//   fifilinkfoldlevel: tifiintegerlinkcomp;
//   fifilinkissum: tifibooleanlinkcomp;
//  {$endif}
   procedure cleanfolding(arow: integer; visibleindex: integer);
   function isvisible(const arow: integer): boolean;
   procedure counthidden(var aindex: integer);
   procedure setfoldlevel(const index: integer; avalue: byte);
   procedure setfolded(const avalue: boolean);
   procedure setheight(const index: integer; const avalue: integer);
   procedure setlinewidth(const index: integer; const avalue: integer);
   function getrowypos(const index: integer): integer;
   procedure setsourcefoldlevel1(const avalue: string);
   procedure setsourcefoldlevel(const avalue: string);
   procedure setsourceissum1(const avalue: string);
   procedure setsourceissum(const avalue: string);
   procedure sourcenamechanged(const atag: integer);
  {$ifdef mse_with_ifi}
//   procedure setifilinkfoldlevel1(const avalue: tifiintegerlinkcomp);
//   procedure setifilinkissum1(const avalue: tifibooleanlinkcomp);
//   procedure setifilinkfoldlevel(const avalue: tifiintegerlinkcomp);
//   procedure setifilinkissum(const avalue: tifibooleanlinkcomp);
    //iifilink
   function getifilinkkind: ptypeinfo;
    //iificlient
   procedure setifiserverintf(const aintf: iifiserver);
//   function getifiserverintf: iifiserver;
    //iifidatalink
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   procedure ifisetvalue(var avalue; var accept: boolean);   
   function getgriddata: tdatalist;
   function getvalueprop: ppropinfo;
  {$endif}
  protected
   procedure sethidden(const index: integer; const avalue: boolean); override;
   procedure setfoldissum(const index: integer; const avalue: boolean); override;
   function getlinkdatatypes(const atag: integer): listdatatypesty; override;
   procedure sourcechange(const sender: tdatalist; 
                                         const index: integer); override;
   procedure foldleveltosource(const index: integer; const acount: integer);
   procedure checksyncfoldlevelsource(const index: integer;
                                 const acount: integer);
   procedure foldissumtosource(const index: integer; const acount: integer);
   procedure checksyncfoldissumsource(const index: integer;
                                 const acount: integer);

   function totchildrencount(const aindex: integer;
                                   const acount: integer): integer;
   procedure movegrouptoparent(const aindex: integer; const acount: integer); 
                 //called before deleting of rows
   procedure updatedeletedrows(const index: integer; const acount: integer);
//   procedure setcount(const value: integer); override;
//   procedure clearbuffer; override;   
   procedure internalshow(var aindex: integer);
   procedure internalhide(var aindex: integer);
   procedure show(const aindex: integer);
   procedure hide(const aindex: integer);
   procedure initdirty; override;
   procedure cleanvisible(visibleindex: integer);
   procedure clean(arow: integer);
   procedure cleanrowheight(const aindex: integer);
   procedure checkdirty(const arow: integer); override;
   procedure checkdirtyautorowheight(const arow: integer);
   procedure recalchidden; override;
   function getstatdata(const index: integer): msestring; override;
   procedure setstatdata(const index: integer; const value: msestring);
                                 override;
   function internalheight(const aindex: integer): integer;
                    //no valid checks
   function internalystep(const aindex: integer): integer; overload;
                    //no valid checks
   procedure internalystep(const aindex: integer; out ay: integer;
                                      out acy:integer); overload;
                    //no valid checks
  public
   constructor create(const aowner: tcustomgrid); reintroduce;
   destructor destroy; override;

   function getsourcecount: integer; override;
   function getsourceinfo(const atag: integer): plistlinkinfoty; override;
   procedure linksource(const source: tdatalist; const atag: integer); override;

   procedure clearmemberitem(const subitem: integer; 
                                    const index: integer); override;
   procedure setmemberitem(const subitem: integer; 
                         const index: integer; const avalue: integer); override;

   procedure change(const index: integer); override;
   function cellrow(const arow: integer): integer;
   function visiblerow(const arowindex: integer): integer;
                 //returns count of visible previous rows
   function visiblerowcount: integer;
   function visiblerowtoindex(const avisibleindex: integer): integer;
   function visiblerows1(const astart: integer; const aendy: integer): integerarty;
   procedure updatefoldinfo(const rows: integerarty;
                                           var infos: rowfoldinfoarty);
   function visiblerowstep(const arow: integer; const step: integer;
                            const autoappend: boolean): integer;
   function rowhidden(const arow: integer): boolean;
   function nearestvisiblerow(const arow: integer): integer;
   procedure getfoldstate(const arow: integer; out aisvisible: boolean; 
                out afoldlevel: byte; out ahaschildren,aisopen: boolean);
   procedure hidechildren(const arow: integer);
   procedure showchildren(const arow: integer);
   property folded: boolean read ffolded write setfolded;
   procedure setupfoldinfo(asource: pbyte; const acount: integer);
   property hidden[const index: integer]: boolean read gethidden write sethidden;
   property foldlevel[const index: integer]: byte read getfoldlevel 
                                                  write setfoldlevel; //0..63
   property foldissum[const index: integer]: boolean read getfoldissum 
                                                  write setfoldissum;
   property height[const index: integer]: integer read getheight 
                                                            write setheight;
   property linewidth[const index: integer]: integer read getlinewidth 
                                                            write setlinewidth;
   function currentrowheight(const index: integer): integer;
   property rowypos[const index: integer]: integer read getrowypos;
   function rowindex(const aypos: integer): integer;
   procedure fillfoldlevel(const index: integer; const acount: integer;
                                                            const avalue: byte);
  published
   property sourcefoldlevel: string read flinkfoldlevel.name 
                                            write setsourcefoldlevel;
   property sourceissum: string read flinkissum.name 
                                            write setsourceissum;
  {$ifdef mse_with_ifi}
//   property ifilinkfoldlevel: tifiintegerlinkcomp read fifilinkfoldlevel 
//                                           write setifilinkfoldlevel;
//   property ifilinkissum: tifibooleanlinkcomp read fifilinkissum
//                                           write setifilinkissum;
  {$endif} 
 end;

 tdatacols = class(tcols)
  private
   fselectedrow: integer; //-1 none, -2 more than one
   fsortcol: integer;
   fnewrowcol: integer;
   fchangelock: integer;
   flastvisiblecol: integer;
   function getcols(const index: integer): tdatacol;
   procedure setcols(const index: integer; const Value: tdatacol);
   function getselectedcells: gridcoordarty;
   procedure setselectedcells(const Value: gridcoordarty);
   function getselectedrows: integerarty;
   procedure setselectedrows(const avalue: integerarty);
   function getselected(const cell: gridcoordty): boolean;
   procedure setselected(const cell: gridcoordty; const Value: boolean);
   function roworderinvalid: boolean; //true if accepted
   procedure checkindexrange;
   procedure setsortcol(const avalue: integer);
   procedure setnewrowcol(const avalue: integer);
   function getrowselected(const index: integer): boolean;
   procedure setrowselected(const index: integer; const avalue: boolean);
  protected
   frowstate: trowstatelist;
   procedure beginchangelock;
   procedure endchangelock;
   procedure datasourcechanged; virtual;
   procedure begindataupdate; override;
   procedure enddataupdate; override;
   procedure dosizechanged; override;
   procedure countchanged; override;
   procedure mergechanged(const arow: integer);
   procedure rearange(const list: tintegerdatalist); override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure setrowcountmax(const value: integer);
   procedure rowcountchanged(const newcount: integer); override;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure updatelayout; override;
   function colatpos(const x: integer;
                 const getscrollable: boolean = true): integer;
                //0..count-1, invalidaxis if invalid
   procedure moverow(const fromindex,toindex: integer; const acount: integer = 1); override;
   procedure insertrow(const index: integer; const acount: integer = 1); override;
   procedure deleterow(const index: integer; const acount: integer = 1); override;
   procedure changeselectedrange(const start,oldend,newend: gridcoordty;
             calldoselectcell: boolean); virtual;
   procedure beginselect;
   procedure endselect;
   procedure decselect;
   procedure sortfunc(sender: tcustomgrid;
                       const index1,index2: integer; var result: integer);
   procedure updatedatastate(var accepted: boolean); virtual;

   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   
   function cancopy: boolean;
   function canpaste: boolean;

  public
   constructor create(aowner: tcustomgrid; aclasstype: gridpropclassty);
   destructor destroy; override;
   procedure move(const curindex,newindex: integer); override;
   procedure clearselection;
   function hasselection: boolean;
   function previosvisiblecol(aindex: integer): integer;
                   //invalidaxis if none
   property lastvisiblecol: integer read flastvisiblecol;
   function rowempty(const arow: integer): boolean;
   property cols[const index: integer]: tdatacol read getcols write setcols; default;
   function colbyname(const aname: string): tdatacol;
                  //name is case sensitive
   function datalistbyname(const aname: string): tdatalist; //can be nil
   function colsubdatainfo(const aname: string): subdatainfoty;
   
   function selectedcellcount: integer;
   function hascolselection: boolean;
   property selectedcells: gridcoordarty read getselectedcells 
                                         write setselectedcells;
   property selectedrows: integerarty read getselectedrows 
                                         write setselectedrows;
   property rowselected[const index: integer]: boolean read getrowselected 
                                         write setrowselected;
   property selected[const cell: gridcoordty]: boolean read Getselected write Setselected;
               //col < 0 and row < 0 -> whole grid, col < 0 -> whole col,
               //row = < 0 -> whole row
   procedure setselectedrange(const rect: gridrectty; const value: boolean;
             const calldoselectcell: boolean = false;
             const checkmultiselect: boolean = false); overload;
   procedure setselectedrange(const start,stop: gridcoordty;
                    const value: boolean;
                    const calldoselectcell: boolean = false;
                    const checkmultiselect: boolean = false); overload; virtual;
   procedure mergecols(const arow: integer; const astart: longword = 0; 
                                              const acount: longword = bigint);
   procedure unmergecols(const arow: integer = invalidaxis);
                     //invalidaxis = all
   property rowstate: trowstatelist read frowstate;
  published
   property sortcol: integer read fsortcol write setsortcol default -1;
                                      //-1 -> all
   property newrowcol: integer read fnewrowcol write setnewrowcol default -1;
                                      //-1 -> actual
   property width;
   property options default defaultdatacoloptions;
   property options1 default defaultdatacoloptions1;
   property fontselect;
   property linewidth;
   property linecolor default defaultdatalinecolor;
   property linecolorfix;
 end;

 tdrawcols = class(tdatacols)
  private
   function getcols(const index: integer): tdrawcol;
  public
   constructor create(aowner: tcustomgrid);
   class function getitemclasstype: persistentclassty; override;
   property cols[const index: integer]: tdrawcol read getcols; default;
  published
   property focusrectdist;
 end;

 tstringcols = class(tdatacols)
  private
   foptionsedit: stringcoleditoptionsty;
   foptionsedit1: optionsedit1ty;
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   function getcols(const index: integer): tstringcol;
   procedure settextflags(avalue: textflagsty);
   procedure settextflagsactive(avalue: textflagsty);
   procedure setoptionsedit(avalue: stringcoleditoptionsty);
   procedure setoptionsedit1(avalue: optionsedit1ty);
  protected
   function getcolclass: stringcolclassty; virtual;
   procedure updatedatastate(var accepted: boolean); override;
  public
   constructor create(aowner: tcustomgrid);
   class function getitemclasstype: persistentclassty; override;
   property cols[const index: integer]: tstringcol read getcols; default; //last!
  published
   property focusrectdist;
   property textflags: textflagsty read ftextflags write settextflags 
                                                   default defaultcoltextflags;
   property textflagsactive: textflagsty read ftextflagsactive
             write settextflagsactive default defaultactivecoltextflags;
   property optionsedit: stringcoleditoptionsty read foptionsedit
          write setoptionsedit default defaultstringcoleditoptions;
   property optionsedit1: optionsedit1ty read foptionsedit1
          write setoptionsedit1 default defaultoptionsedit1;
 end;

 tfixcols = class(tcols)
  private
   function getcols(const index: integer): tfixcol;
   procedure setcols(const index: integer; const Value: tfixcol);
  protected
   procedure countchanged; override;
   procedure updatelayout; override;
   function colatpos(const x: integer): integer; //-cout..-1, 0 if invalid
  public
   constructor create(aowner: tcustomgrid);
   class function getitemclasstype: persistentclassty; override;
   property cols[const index: integer]: tfixcol read getcols write setcols; default;
               //index -1..-count
  published
   property width;
   property linewidth;
   property linecolor default defaultfixlinecolor;
   property linecolorfix;
   property oppositecount;
 end;

 tfixrows = class(tgridarrayprop)
  private
   function getrows(const index: integer): tfixrow;
   procedure setrows(const index: integer; const Value: tfixrow);
  protected
   function getclientsize: integer; override;
   procedure updatelayout; override;
   procedure updatemergedcells;
   function rowatpos(const y: integer): integer; //-count..-1, 0 if invalid
   procedure paint(const info: rowspaintinfoty);
   procedure movecol(const curindex,newindex: integer; const isfix: boolean);
   procedure datacolscountchanged;
   procedure fixcolscountchanged;
   procedure orderdatacols(const neworder: integerarty);
   procedure dofontheightdelta(var delta: integer);
  public
   constructor create(aowner: tcustomgrid);
   class function getitemclasstype: persistentclassty; override;
   procedure synctofontheight;
   property rows[const index: integer]: tfixrow read getrows write setrows; default;
               //index -1..-count
  published
   property oppositecount;
   property linewidth;
   property linecolor default defaultfixlinecolor;
   property linecolorfix default defaultfixlinecolor;
 end;

 tgridframe = class(tcustomautoscrollframe)
  protected
   function getscrollbarclass(vert: boolean): framescrollbarclassty; override;
  public
   constructor create(const intf: iscrollframe; const owner: twidget;
                             const autoscrollintf: iautoscrollframe);
  published
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property colorclient default cl_foreground;
   property framei_left default 0;
   property framei_top default 0;
   property framei_right default 0;
   property framei_bottom default 0;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
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

   property sbvert;
   property sbhorz;
   property caption;
   property captionpos;
   property captiondist;
   property captionoffset;
   property font;
   property localprops;  //before template
   property localprops1; //before template
   property template;
 end;

 trowfontarrayprop = class(tpersistentarrayprop)
  private
   fgrid: tcustomgrid;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomgrid);
   class function getitemclasstype: persistentclassty; override;
 end;

 cellinnerlevelty = (cil_all,cil_noline,cil_paint,cil_inner);
 cellselectmodety = (csm_select,csm_deselect,csm_reverse);
 selectcellmodety = (scm_cell,scm_row,scm_col);
 
 optionfoldty = (of_insertsamelevel,of_deletetree,of_shiftdeltoparent,
                 of_shiftchildren,of_validatelevel);
 optionsfoldty = set of optionfoldty;

 gridnotifyeventty = procedure(const sender: tcustomgrid) of object;
 griddataeventty = procedure(const sender: tcustomgrid; 
                             const acell: gridcoordty) of object;
 griddatablockeventty = procedure(const sender: tcustomgrid; 
                  const acell: gridcoordty; const acount: integer) of object;
 gridblockmovedeventty = procedure(const sender: tcustomgrid; 
                  const fromindex,toindex,acount: integer) of object;
 gridbeforeblockeventty = procedure(const sender: tcustomgrid; var aindex,acount: integer) of object;
 gridblockeventty = procedure(const sender: tcustomgrid; 
                  const aindex: integer; const acount: integer) of object;
 gridsorteventty = procedure(sender: tcustomgrid;
                       const index1,index2: integer; var aresult: integer) of object;

 gridscrolleventty = procedure(const sender: tcustomgrid;
                                     var step: integer) of object; 
 tcustomgrid = class(tpublishedwidget,iautoscrollframe,iobjectpicker,iscrollbar,
                    idragcontroller,istatfile
                    {$ifdef mse_with_ifi},iifigridlink{$endif})
  private
   frepeater: tsimpletimer;
   frepeataction: focuscellactionty;
   fystep: integer;
   ffirstvisiblerow: integer;
   flastvisiblerow: integer;
   fvisiblerows: integerarty;
   fvisiblerowfoldinfo: rowfoldinfoarty;
   fvisiblerowsbase: integer; //number of visible rows below scrollwindow
   
   flayoutupdating: integer;
   fvisiblerowsupdating: integer;
   fnullchecking: integer;
   frowdatachanging: integer;
   fnoshowcaretrect: integer;
   finvalidatedcells: gridcoordarty;

   foncellevent: celleventty;
   fonrowsmoved: gridblockmovedeventty;
   fonrowdatachanged: griddataeventty;
   fonrowsdatachanged: griddatablockeventty;
   fonrowsinserting: gridbeforeblockeventty;
   fonrowsinserted: gridblockeventty;
   fonrowsdeleting: gridbeforeblockeventty;
   fonrowsdeleted: gridblockeventty;
   fonrowcountchanged: gridnotifyeventty;
   fonlayoutchanged: gridnotifyeventty;
   fonbeforeupdatelayout: gridnotifyeventty;
   fonsort: gridsorteventty;

   fdatarowlinewidth: integer;
   fdatarowlinecolor: colorty;
   fdatarowlinecolorfix: colorty;

   foncolmoved: gridblockmovedeventty;
   fonselectionchanged: notifyeventty;
   fgridframecolor: colorty;
   fgridframewidth: integer;
   frowcolors: tcolorarrayprop;
   frowfonts: trowfontarrayprop;
   fmouseparkcell: gridcoordty;
   fclickedcell: gridcoordty;
   fclickedcellbefore: gridcoordty;

   fstatfile: tstatfile;
   fstatvarname: msestring;

   fonkeydown: keyeventty;

   fmouserefpos: pointty;

   fwheelscrollheight: integer;
   fonscrollrows: gridscrolleventty;

   fonsortchanged: gridnotifyeventty;
   fdatarowheightmin: integer;
   fdatarowheightmax: integer;
   foptionsfold: optionsfoldty;
{$ifdef mse_with_ifi}
   fifilink: tifigridlinkcomp;
//   procedure ifisetvalue(var avalue; var accept: boolean);
   function getifilinkkind: ptypeinfo;
   procedure setifilink(const avalue: tifigridlinkcomp);
    //iifigridlink
   function getrowstate: tcustomrowstatelist;
{$endif}
   procedure setframe(const avalue: tgridframe);
   function getframe: tgridframe;
   procedure setstatfile(const Value: tstatfile);

   procedure setrowcount(value: integer);
   procedure setrowcountmax(const value: integer);
   procedure setdatacols(const Value: tdatacols);
   procedure setfixcols(const Value: tfixcols);
   procedure setfixrows(const Value: tfixrows);
   procedure setcol(const value: integer);
   procedure setrow(const value: integer);

   procedure killrepeater;
   procedure startrepeater(state: gridstatety; time: integer);
   procedure repeatproc(const sender: tobject);
   
   procedure calcpropcolwidthref;
   procedure updatevisiblerows;
   procedure setdatarowlinewidth(const Value: integer);
   procedure setdatarowlinecolor(const Value: colorty);
   procedure setdatarowlinecolorfix(const Value: colorty);

   procedure decodepickobject(code: integer; out kind: pickobjectkindty;
               out cell: gridcoordty; out col: tcol; out row: tfixrow);
   procedure setgridframecolor(const Value: colorty);
   procedure setgridframewidth(const Value: integer);
   procedure setrowcolors(const Value: tcolorarrayprop);
   procedure setrowfonts(const Value: trowfontarrayprop);
   function getrowcolorstate(index: integer): rowstatenumty;
   procedure setrowcolorstate(index: integer; const Value: rowstatenumty);
   function getrowlinecolorstate(index: integer): rowstatenumty;
   procedure setrowlinecolorstate(index: integer; const Value: rowstatenumty);
   function getrowlinecolorfixstate(index: integer): rowstatenumty;
   procedure setrowlinecolorfixstate(index: integer; const Value: rowstatenumty);
   function getrowfontstate(index: integer): rowstatenumty;
   procedure setrowfontstate(index: integer; const Value: rowstatenumty);
   procedure appinsrow(index: integer);
   procedure setdragcontroller(const avalue: tdragcontroller);
   function getrowreadonlystate(index: integer): boolean;
   procedure setrowreadonlystate(index: integer; const avalue: boolean);
   function getrowhidden(index: integer): boolean;
   procedure setrowhidden(index: integer; const avalue: boolean);
   function getrowfoldlevel(index: integer): byte;
   procedure setrowfoldlevel(index: integer; const avalue: byte);
   function getrowfoldissum(index: integer): boolean;
   procedure setrowfoldissum(index: integer; const avalue: boolean);
   function getrowheight(index: integer): integer;
   procedure setrowheight(index: integer; avalue: integer);

   procedure setzebra_color(const avalue: colorty);
   procedure setzebra_start(const avalue: integer);
   procedure setzebra_height(const avalue: integer);
   procedure setzebra_step(const avalue: integer);
   function getsorted: boolean;
   procedure setsorted(const avalue: boolean);
   function getrowstatelist: trowstatelist;
   procedure setrowstatelist(const avalue: trowstatelist);
   function getrowlinewidth(index: integer): integer;
   procedure setrowlinewidth(index: integer; const avalue: integer);
  protected
   fupdating: integer;
   ffocuscount: integer;
   fcellvaluechecking: integer;
   flastcol: integer;
   fpropcolwidthref: integer;
   fzebra_start: integer;
   fzebra_color: colorty;
   fzebra_height: integer;
   fzebra_step: integer;
   ffocusedcell: gridcoordty;
   fmousecell: gridcoordty;
   fmouseeventcol: integer;
   factiverow: integer;
   fstartanchor,fendanchor: gridcoordty;
   foptionsgrid: optionsgridty;
   fstate: gridstatesty;
   fstate1: gridstates1ty;
   fshowcell: gridcoordty;
   fshowcellmode: cellpositionty;
   ffixcols: tfixcols;
   ffixrows: tfixrows;
   fdatacols: tdatacols;
   fdatarowheight: integer;
   frowcount: integer;
   frowcountmax: integer;
   fscrollrect: rectty;
   finnerdatarect,fdatarect,fdatarectx,fdatarecty: rectty;
          //origin = clientrect.pos
   frootbrushorigin: pointty;
   fbrushorigin: pointty;
          //origin windowpos
   ffirstnohscroll: integer;
   fdragcontroller: tdragcontroller;
   fobjectpicker: tobjectpicker;
   fpickkind: pickobjectkindty;
   fnumoffset: integer; //for fixcols
   fnonullcheck: integer;
   fnocheckvalue: integer;
   fappendcount: integer;
   flastcellzone: cellzonety;
   class function classskininfo: skininfoty; override;
   
   function checkrowindex(var aindex: integer): boolean;
   procedure setselected(const cell: gridcoordty;
                                       const avalue: boolean); virtual;
   procedure internalselectionchanged;
   procedure setoptionsgrid(const avalue: optionsgridty); virtual;
   procedure checkrowreadonlystate; virtual;
   procedure checkneedsrowheight;
   procedure updaterowheight(const arow: integer; var arowheight: integer);

   procedure doinsertrow(const sender: tobject); virtual;
   procedure doappendrow(const sender: tobject); virtual;
   procedure dodeleterow(const sender: tobject); virtual;
   procedure dodeleteselectedrows(const sender: tobject); virtual;
   procedure dodeleterows(const sender: tobject);
   procedure docopycells(const sender: tobject);
   procedure dopastecells(const sender: tobject);

   procedure initeventinfo(const cell: gridcoordty; eventkind: celleventkindty;
                 out info: celleventinfoty);
   procedure invalidate;
   procedure invalidatesinglecell(const cell: gridcoordty);
   function caninvalidate: boolean;
   function docheckcellvalue: boolean;
   procedure dolayoutchanged; virtual;
   procedure internalupdatelayout(const force: boolean = false);
   procedure updatelayout; virtual;
   function intersectdatarect(var arect: rectty): boolean;
   procedure setdatarowheight(const value: integer);
   function getcaretcliprect: rectty; override;
   procedure checkdatacell(const coord: gridcoordty);
   procedure datacellerror(const coord: gridcoordty);
   procedure error(aerror: griderrorty; text: string = '');
   procedure indexerror(row: boolean; index: integer; text: string = '');

   function actualcursor(const apos: pointty): cursorshapety; override;
   function getdisprect: rectty; override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure fontchanged; override;
   procedure clientrectchanged; override;
   procedure internalcreateframe; override;
   function getscrollrect: rectty;
   procedure setscrollrect(const rect: rectty);
   function scrollcaret: boolean; virtual;
   procedure firstcellclick(const cell: gridcoordty;
                                const info: mouseeventinfoty); virtual;
   function getzebrastart: integer; virtual;
   function getnumoffset: integer; virtual;

   function createdatacols: tdatacols; virtual;
   procedure createdatacol(const index: integer; out item: tdatacol); virtual;
   function createfixcols: tfixcols; virtual;
   function createfixrows: tfixrows; virtual;
   procedure initcellinfo(var info: cellinfoty); virtual;

   procedure colchanged(const sender: tcol);
   procedure cellchanged(const sender: tcol; const row: integer);
   procedure focusedcellchanged; virtual;
   procedure rowchanged(const arow: integer); virtual;
   procedure rowstatechanged(const arow: integer); virtual;
   procedure scrolled(const dist: pointty); virtual;
   procedure sortchanged;
   procedure sortinvalid;
   procedure checksort;
   procedure checkinvalidate;
   function startanchor: gridcoordty;
   function endanchor: gridcoordty;

   procedure doselectionchanged; virtual;
   procedure docolmoved(const fromindex,toindex: integer); virtual;
   procedure dorowsmoved(const fromindex,toindex,count: integer); virtual;
   procedure dorowsinserting(var index,count: integer); virtual;
   procedure dorowsinserted(const index,count: integer); virtual;
   procedure dorowsdeleting(var index,count: integer); virtual;
   procedure dorowsdeleted(index,count: integer); virtual;
   procedure dorowsdatachanged(const acell: gridcoordty; 
                                           const acount: integer); virtual;
   procedure dorowcountchanged(const countbefore,newcount: integer); virtual;
   procedure docellevent(var info: celleventinfoty); virtual;
   procedure cellmouseevent(const acell: gridcoordty; var info: mouseeventinfoty;
                                const acellinfopo: pcelleventinfoty = nil;
                                const aeventkind: celleventkindty = cek_none);
   procedure dofocusedcellposchanged; virtual;
   function isfirstrow: boolean; virtual;
   function islastrow: boolean; virtual;

   function internalsort(sortfunc: gridsorteventty; 
                                 var refindex: integer): boolean;
                              //true if moved
   procedure updaterowdata; virtual;
   
   procedure objectevent(const sender: tobject; 
                                 const event: objecteventty); override;
   procedure loaded; override;
   procedure doexit; override;
   procedure dofocus; override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure activechanged; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure drawfocusedcell(const acanvas: tcanvas); virtual;
   procedure drawcellbackground(const acanvas: tcanvas);
   procedure drawcelloverlay(const acanvas: tcanvas);

   procedure updatepopupmenu(var amenu: tpopupmenu; 
                         var mouseinfo: mouseeventinfoty); override;
   function rowatpos(y: integer): integer; //0..rowcount-1, invalidaxis if invalid
   function ystep: integer;
   function mergestart(const acol: integer; const arow: integer): integer;
   function mergeend(const acol: integer; const arow: integer): integer;
   function getmerged(const arow: integer): longword;
   function nextfocusablecol(acol: integer; const aleft: boolean;
                                const arow: integer): integer;
   procedure checkcellvalue(var accept: boolean); virtual; 
                   //store edited value to grid
   procedure beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty); virtual;
   procedure afterfocuscell(const cellbefore: gridcoordty;
                             const selectaction: focuscellactionty); virtual;
   function wheelheight: integer;
   
    //idragcontroller
   function getdragrect(const apos: pointty): rectty; override;
    //iscrollbar
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); virtual;

    //idragcontroller
    //iobjectpicker
   function getcursorshape(const apos: pointty;  const shiftstate: shiftstatesty;
                                    var shape: cursorshapety): boolean;
   procedure getpickobjects(const rect: rectty;  const shiftstate: shiftstatesty;
                                    var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos: pointty; const ashiftstate: shiftstatesty;
                         const offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                                   const objects: integerarty);
   function calcshowshift(const rect: rectty; 
                                   const position: cellpositionty): pointty;
   procedure focusrow(const arow: integer; const action: focuscellactionty;
                        const selectmode: selectcellmodety = scm_cell);

    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   
   procedure beginnullchecking;
   procedure endnullchecking;
   procedure beginnonullcheck;
   procedure endnonullcheck;
   procedure beginnocheckvalue;
   procedure endnocheckvalue;
   function nocheckvalue: boolean;

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure initnewcomponent(const ascale: real); override;
   procedure synctofontheight; override;
   procedure dragevent(var info: draginfoty); override;

   procedure beginupdate;
   procedure endupdate(const nosort: boolean = false);
   function updating: boolean;
   function calcminscrollsize: sizety; override;
   procedure layoutchanged;
   function cellclicked: boolean;
   procedure rowdatachanged(const acell: gridcoordty; const count: integer = 1);
                 //acell.col = invalidaxis -> col unknown

   procedure rowup(const action: focuscellactionty = fca_focusin); virtual;
   procedure rowdown(const action: focuscellactionty = fca_focusin); virtual;
   procedure pageup(const action: focuscellactionty = fca_focusin); virtual;
   procedure pagedown(const action: focuscellactionty = fca_focusin); virtual;
   procedure wheelup(const action: focuscellactionty = fca_focusin); virtual;
   procedure wheeldown(const action: focuscellactionty = fca_focusin); virtual;
   procedure lastrow(const action: focuscellactionty = fca_focusin); virtual;
   procedure firstrow(const action: focuscellactionty = fca_focusin); virtual;

   procedure colstep(action: focuscellactionty; step: integer;
                           const rowchange: boolean;
                           const nocolwrap: boolean); virtual;
                 //step > 0 -> right, step < 0 left

   function isautoappend: boolean; //true if last row is auto appended
   procedure removeappendedrow;
   function checkreautoappend: boolean; //true if row appended

   function gridprop(const coord: gridcoordty): tgridprop;  //nil if none
   function isdatacell(const coord: gridcoordty): boolean;
   function isvalidcell(const coord: gridcoordty): boolean;
   function isfixrow(const coord: gridcoordty): boolean;
   function isfixcol(const coord: gridcoordty): boolean;
   function rowvisible(const arow: integer): integer;
                 //0 -> fully visible, < 0 -> below > 0 above
   function rowsperpage: integer;
   function cellatpos(const apos: pointty; out coord: gridcoordty): cellkindty; overload;
                 //origin = paintrect.pos
   function cellatpos(const apos: pointty): gridcoordty; overload;
   function cellrect(const cell: gridcoordty;
                 const innerlevel: cellinnerlevelty = cil_all;
                 const nomerged: boolean = false): rectty;
                 //origin = paintrect.pos
   function clippedcellrect(const cell: gridcoordty;
                 const innerlevel: cellinnerlevelty = cil_all): rectty;
                 //origin = paintrect.pos, clipped by datarect
   function cellvisible(const acell: gridcoordty): boolean;
       //returns row.visible and col.visible, independent from scrolling
   procedure invalidatecell(const cell: gridcoordty);
   procedure invalidatefocusedcell;
   procedure invalidaterow(const arow: integer);
   function selectcell(const cell: gridcoordty; 
                          const amode: cellselectmodety;
                          const checkmultiselect: boolean = false): boolean; 
                          //true if accepted
   function getselectedrange: gridrectty;
//   function getselectedrows: integerarty;
        //moved to tdatacols.selectedrows

   function focuscell(cell: gridcoordty;
              selectaction: focuscellactionty = fca_focusin;
              const selectmode: selectcellmodety = scm_cell;
              const noshowcell: boolean = false): boolean; virtual;
                                               //true if ok
   procedure focuscolbyname(const aname: string);
                 //case sensitive
   function focusedcellvalid: boolean;
   function scrollingcol: boolean;   //true if focusedcolvalid and no co_nohscroll
   function noscrollingcol: boolean; //true if focusedcolvalid and co_nohscroll

   function defocuscell: boolean;
   function defocusrow: boolean;
   function showrect(const rect: rectty;
                       const position: cellpositionty = cep_nearest;
                       const noxshift: boolean = false): pointty;
                                    //returns shifted amount
   function showcaretrect(const arect: rectty;
                               const aframe: tcustomframe): pointty; overload;
   function showcaretrect(const arect: rectty; 
                       const aframe: framety): pointty; overload;
   function showcellrect(const rect: rectty;
                   const origin: cellinnerlevelty = cil_paint): pointty;
   procedure showcell(const cell: gridcoordty; 
                      const position: cellpositionty = cep_nearest;
                      const force: boolean = false); 
               //scrolls cell in view, force true -> if scrollbar clicked also
   procedure showlastrow;
   procedure scrollrows(step: integer);
   procedure scrollleft;
   procedure scrollright;
   procedure scrollpageleft;
   procedure scrollpageright;
   procedure movecol(const curindex,newindex: integer);
   procedure moverow(const curindex,newindex: integer; const count: integer = 1);
   procedure insertrow(aindex: integer; acount: integer = 1); virtual;
   procedure deleterow(aindex: integer; acount: integer = 1); virtual;
   procedure clear; //sets rowcount to 0
   function appendrow(const checkautoappend: boolean = false): integer; //returns index of new row,
                                //fast, does not call change events
   procedure sort;
   function copyselection: boolean; virtual;  //false if no copy
   function pasteselection: boolean; virtual; //false if no paste

   property optionsgrid: optionsgridty read foptionsgrid write setoptionsgrid
                default defaultoptionsgrid; //first!
   property optionsfold: optionsfoldty read foptionsfold 
                                           write foptionsfold default [];
   property sorted: boolean read getsorted write setsorted;
   
   property datarowlinewidth: integer read fdatarowlinewidth
                write setdatarowlinewidth default defaultgridlinewidth;
   property datarowlinecolorfix: colorty read fdatarowlinecolorfix
                write setdatarowlinecolorfix default defaultfixlinecolor;
   property datarowlinecolor: colorty read fdatarowlinecolor
                write setdatarowlinecolor default defaultdatalinecolor;
   property datarowheight: integer read fdatarowheight
                write setdatarowheight default griddefaultrowheight;
   property datarowheightmin: integer read fdatarowheightmin
                                        write fdatarowheightmin default 1;
   property datarowheightmax: integer read fdatarowheightmax
                                        write fdatarowheightmax default maxint;

   property datacols: tdatacols read fdatacols write setdatacols;
   property fixcols: tfixcols read ffixcols write setfixcols;
   property fixrows: tfixrows read ffixrows write setfixrows;

   property rowcount: integer read frowcount write setrowcount default 0;
   function rowhigh: integer; //rowcount - 1
   property rowcountmax: integer read frowcountmax
                         write setrowcountmax default bigint;
   function visiblerow(const arow: integer): integer;
                 //returns index in visible rows, invaidaxis if not visible
   property firstvisiblerow: integer read ffirstvisiblerow;
   property lastvisiblerow: integer read flastvisiblerow;
   property visiblerows: integerarty read fvisiblerows;
   

   property focusedcell: gridcoordty read ffocusedcell;
                              //col,row = invalidaxis if none
   property col: integer read ffocusedcell.col write setcol;
   property row: integer read ffocusedcell.row write setrow;
   property mousecell: gridcoordty read fmousecell;
   
   property gridframewidth: integer read fgridframewidth 
                        write setgridframewidth default 0;
   property gridframecolor: colorty read fgridframecolor 
                        write setgridframecolor default cl_black;

                      //rowproperties index = -1 -> focused row
   property rowcolors: tcolorarrayprop read frowcolors write setrowcolors;
   property rowcolorstate[index: integer]: rowstatenumty read getrowcolorstate 

                        write setrowcolorstate; //default = -1
   property rowlinecolorstate[index: integer]: rowstatenumty read getrowlinecolorstate 
                        write setrowlinecolorstate; 
                               //default = -1, og_rowheight must be set
   property rowlinecolorfixstate[index: integer]: rowstatenumty 
                        read getrowlinecolorfixstate 
                        write setrowlinecolorfixstate; 
                               //default = -1, og_rowheight must be set
   property rowlinewidth[index: integer]: integer read getrowlinewidth 
                                       write setrowlinewidth;
                               //default = -1, og_rowheight must be set

   property rowfonts: trowfontarrayprop read frowfonts write setrowfonts;
   property rowfontstate[index: integer]: rowstatenumty read getrowfontstate 
                        write setrowfontstate;  //default = -1
   property rowreadonlystate[index: integer]: boolean read getrowreadonlystate
                        write setrowreadonlystate;
   property rowhidden[index: integer]: boolean read getrowhidden
                        write setrowhidden;
   property rowfoldlevel[index: integer]: byte read getrowfoldlevel
                        write setrowfoldlevel;
   property rowfoldissum[index: integer]: boolean read getrowfoldissum
                        write setrowfoldissum;
   function rowfoldinfo: prowfoldinfoty; //nil if focused row not visible
   property rowheight[index: integer]: integer read getrowheight
                                                          write setrowheight;
                                //og_rowheight must be set
   property rowstatelist: trowstatelist read getrowstatelist 
                                               write setrowstatelist;
{$ifdef mse_with_ifi}
   property ifilink: tifigridlinkcomp read fifilink write setifilink;
{$endif}
                        
   property zebra_color: colorty read fzebra_color write setzebra_color default cl_infobackground;
   property zebra_start: integer read fzebra_start write setzebra_start default 0;
   property zebra_height: integer read fzebra_height write setzebra_height default 0;
   property zebra_step: integer read fzebra_step write setzebra_step default 2;

   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onbeforeupdatelayout: gridnotifyeventty 
                read fonbeforeupdatelayout write fonbeforeupdatelayout;
   property onlayoutchanged: gridnotifyeventty read fonlayoutchanged
              write fonlayoutchanged;
   property oncolmoved: gridblockmovedeventty read foncolmoved
              write foncolmoved;
   property onrowcountchanged: gridnotifyeventty read fonrowcountchanged
              write fonrowcountchanged;
   property onrowsdatachanged: griddatablockeventty read fonrowsdatachanged
              write fonrowsdatachanged;
   property onrowdatachanged: griddataeventty read fonrowdatachanged
              write fonrowdatachanged;
   property onrowsmoved: gridblockmovedeventty read fonrowsmoved
              write fonrowsmoved;
   property onscrollrows: gridscrolleventty read fonscrollrows write fonscrollrows;

   property onrowsinserting: gridbeforeblockeventty read fonrowsinserting
              write fonrowsinserting;
   property onrowsinserted: gridblockeventty read fonrowsinserted
              write fonrowsinserted;

   property onrowsdeleting: gridbeforeblockeventty read fonrowsdeleting
              write fonrowsdeleting;
   property onrowsdeleted: gridblockeventty read fonrowsdeleted
              write fonrowsdeleted;

   property onsort: gridsorteventty read fonsort write fonsort;
   property onsortchanged: gridnotifyeventty read fonsortchanged 
                                                   write fonsortchanged;

   property oncellevent: celleventty read foncellevent write foncellevent;
   property onselectionchanged: notifyeventty read fonselectionchanged
                  write fonselectionchanged;

   property drag: tdragcontroller read fdragcontroller write setdragcontroller;

  published
   property frame: tgridframe read getframe write setframe;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property fontempty: twidgetfontempty read getfontempty 
                       write setfontempty stored isfontemptystored;
   property onkeydown: keyeventty read fonkeydown write fonkeydown;
   property wheelscrollheight: integer read fwheelscrollheight write
                    fwheelscrollheight default defaultwheelscrollheight;
   property optionswidget default defaultgridwidgetoptions;
 end;

 tcellgrid = class(tcustomgrid)
  protected
   procedure clientmouseevent(var info: mouseeventinfoty); override;
 end;
 
 tdrawgrid = class(tcellgrid)
  private
   function getdatacols: tdrawcols;
   procedure setdatacols(const value: tdrawcols);
   function getcols(index: integer): tdrawcol;
   procedure setcols(index: integer; const avalue: tdrawcol);
  protected
   function createdatacols: tdatacols; override;
   property cols[index: integer]: tdrawcol read getcols write setcols; default;
  published
   property optionsgrid;
   property optionsfold;
   property datacols: tdrawcols read getdatacols write setdatacols;
   property rowstatelist;
   property fixcols;
   property fixrows;
   property rowcount;
   property rowcountmax;
   property gridframecolor;
   property gridframewidth;
   property rowcolors;
   property rowfonts;
   property zebra_color;
   property zebra_start;
   property zebra_height;
   property zebra_step;

   property datarowlinewidth;
   property datarowlinecolorfix;
   property datarowlinecolor;
   property datarowheight;
   property datarowheightmin;
   property datarowheightmax;

   property statfile;
   property statvarname;

   property onbeforeupdatelayout;
   property onlayoutchanged;
   property onrowcountchanged;
   property onrowsdatachanged;
   property onrowdatachanged;
   property onrowsmoved;
   property onrowsinserting;
   property onrowsinserted;
   property onrowsdeleting;
   property onrowsdeleted;
   property onscrollrows;
   property oncellevent;
   property onselectionchanged;
   property onsort;
   property onsortchanged;
   property drag;

 end;

 tcustomstringgrid = class(tcellgrid,iedit)
  private
   function getdatacols: tstringcols;
   procedure setdatacols(const value: tstringcols);
   function getcols(index: integer): tstringcol;
   procedure setcols(index: integer; const Value: tstringcol);
   function getitems(const cell: gridcoordty): msestring;
   procedure setitems(const cell: gridcoordty; const Value: msestring);
   function getcaretwidth: integer;
   procedure setcaretwidth(const value: integer);
   procedure setupeditor(const acell: gridcoordty; const focusin: boolean);
  protected
   feditor: tinplaceedit;
   function canclose(const newfocus: twidget): boolean; override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure checkcellvalue(var accept: boolean); override;
   procedure rootchanged; override;
   procedure updatelayout; override;
   procedure firstcellclick(const cell: gridcoordty; const info: mouseeventinfoty); override;
   function createdatacols: tdatacols; override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure drawfocusedcell(const canvas: tcanvas); override;
   procedure scrolled(const dist: pointty); override;
   function getcaretcliprect: rectty; override;  //origin = clientrect.pos
   property cols[index: integer]: tstringcol read getcols write setcols; default;
   function currentdatalist: tmsestringdatalist;

  //iedit
   function getoptionsedit: optionseditty; virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
   function hasselection: boolean;
   procedure updatecopytoclipboard(var atext: msestring);
   procedure updatepastefromclipboard(var atext: msestring);
   function locatecount: integer;        //number of locate values
   function locatecurrentindex: integer; //index of current row
   procedure locatesetcurrentindex(const aindex: integer);
   function getkeystring(const aindex: integer): msestring; //locate text
   function edited: boolean;

   procedure rowstatechanged(const arow: integer); override;
   procedure dofocusedcellposchanged; override;
   procedure focusedcellchanged; override;
   procedure checkrowreadonlystate; override;
     //interface to inplaceedit
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;

   procedure doselectionchanged; override;
   procedure updatepopupmenu(var amenu: tpopupmenu; 
                         var mouseinfo: mouseeventinfoty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   function textclipped(const acell: gridcoordty;
                 out acellrect: rectty): boolean; overload;
   function textclipped(const acell: gridcoordty): boolean; overload;
   function appendrow(const value: array of msestring): integer; overload;
   function appendrow(const value: msestringarty): integer; overload;
   function appendrow(const value: msestring): integer; overload;
   function copyselection: boolean; override;
   function pasteselection: boolean; override;
   property items[const cell: gridcoordty]: msestring read getitems write setitems;
   property datacols: tstringcols read getdatacols write setdatacols;
   property caretwidth: integer read getcaretwidth write setcaretwidth 
                                                    default defaultcaretwidth;
 end;

 tstringgrid = class(tcustomstringgrid)
  published
   property optionsgrid;
   property optionsfold;
   property datacols;
   property rowstatelist;
   property fixcols;
   property fixrows;
   property rowcount;
   property rowcountmax;
   property gridframecolor;
   property gridframewidth;
   property rowcolors;
   property rowfonts;
   property zebra_color;
   property zebra_start;
   property zebra_height;
   property zebra_step;

   property datarowlinewidth;
   property datarowlinecolorfix;
   property datarowlinecolor;
   property datarowheight;
   property datarowheightmin;
   property datarowheightmax;
   property caretwidth;

   property statfile;
   property statvarname;

   property onbeforeupdatelayout;
   property onlayoutchanged;
   property onrowsmoved;
   property onrowsdatachanged;
   property onrowdatachanged;
   property onrowsinserting;
   property onrowsinserted;
   property onrowsdeleting;
   property onrowsdeleted;
   property onrowcountchanged;
   property onscrollrows;
   property oncellevent;
   property onselectionchanged;
   property onsort;
   property onsortchanged;
   property drag;
 end;

 cellclickrestrictionty = (ccr_buttonpress,ccr_dblclick,
                           ccr_nodefaultzone,ccr_nokeyreturn);
 cellclickrestrictionsty = set of cellclickrestrictionty;

function gridcoordtotext(const coord: gridcoordty): string;
function isequalgridcoord(const a,b: gridcoordty): boolean;

function iscellkeypress(const info: celleventinfoty;
             const akey: keyty = key_none; //key_none -> all keys
             const shiftstatemustinclude: shiftstatesty = [];
             const shiftstatemustnotinclude: shiftstatesty = []): boolean;

function iscellclick(const info: celleventinfoty;
                        restrictions: cellclickrestrictionsty = []): boolean;
function isrowenter(const info: celleventinfoty): boolean;
function isrowexit(const info: celleventinfoty): boolean;
function isrowchange(const info: celleventinfoty): boolean;
function cellkeypress(const info: celleventinfoty): keyty;

implementation
uses
 mseguiintf,msestockobjects,mseact,mseactions,rtlconsts;
type
 tframe1 = class(tcustomframe);
 tdatalist1 = class(tdatalist);
 twidget1 = class(twidget);
 tinplaceedit1 = class(tinplaceedit);
 tcustomscrollbar1 = class(tcustomscrollbar);

const
 errorstrings: array[griderrorty] of string = (
  '', //ok
  'Ivalid datacell',
  'Rowcounts are different',
  'Invalid row index',
  'Invalid col index',
  'Invalid widget'
 );
 
//var
// coloptionssplitinfo: setsplitinfoty;

function iscellkeypress(const info: celleventinfoty;
             const akey: keyty = key_none; //key_none -> all keys
             const shiftstatemustinclude: shiftstatesty = [];
             const shiftstatemustnotinclude: shiftstatesty = []): boolean;
begin
 result:= false;
 with info do begin
  if (eventkind = cek_keydown) then begin
   with keyeventinfopo^ do begin
    if (key = akey) and
     (shiftstate * shiftstatemustinclude = shiftstatemustinclude) and
     (shiftstate * shiftstatemustnotinclude = []) then begin
     include(eventstate,es_processed);
     result:= true;
    end;
   end;
  end;
 end;
end;

function iscellclick(const info: celleventinfoty;
             restrictions: cellclickrestrictionsty = []): boolean;
begin
 result:= false;
 with info do begin
  case eventkind of
   cek_keydown: begin
    if not (ccr_nokeyreturn in restrictions) then begin
     with info.keyeventinfopo^ do begin
      if isenterkey(nil,key) and (shiftstate = []) then begin
       result:= true;
       include(eventstate,es_processed);
      end;
     end;
    end;
   end;
   cek_buttonpress,cek_buttonrelease: begin
    if (zone <> cz_none) and not
            ((zone = cz_default) and (ccr_nodefaultzone in restrictions)) then begin
     with info.mouseeventinfopo^ do begin
      if button = mb_left then begin
       if ((ccr_buttonpress in restrictions) and (eventkind = ek_buttonpress) or
          not (ccr_buttonpress in restrictions) and (eventkind = ek_buttonrelease)) and
           (info.mouseeventinfopo^.shiftstate * keyshiftstatesmask = []) then begin
        if ccr_dblclick in restrictions then begin
         result:= (ss_double in info.mouseeventinfopo^.shiftstate) and 
                   (grid.fclickedcellbefore.row = cell.row) and 
                   (grid.fclickedcellbefore.col = cell.col);
        end
        else begin
         result:= true;
        end;
        if (eventkind = ek_buttonrelease) and 
              ((grid.fclickedcell.row <> cell.row) or 
               (grid.fclickedcell.col <> cell.col)) then begin
         result:= false;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function isrowenter(const info: celleventinfoty): boolean;
begin
 with info do begin
  result:= (eventkind = cek_enter) and (cellbefore.row <> newcell.row);
 end;
end;

function isrowexit(const info: celleventinfoty): boolean;
begin
 with info do begin
  result:= (eventkind = cek_exit) and (cellbefore.row <> newcell.row);
 end;
end;

function isrowchange(const info: celleventinfoty): boolean;
begin
 with info do begin
  result:= (eventkind = cek_focusedcellchanged) and (cellbefore.row <> newcell.row);
 end;
end;

function cellkeypress(const info: celleventinfoty): keyty;
begin
 if info.eventkind = cek_keydown then begin
  result:= info.keyeventinfopo^.key;
 end
 else begin
  result:= key_none;
 end;
end;

function gridcoordtotext(const coord: gridcoordty): string;
begin
 result:= 'Col: '+inttostr(coord.col) + ' Row: '+inttostr(coord.row);
end;

function isequalgridcoord(const a,b: gridcoordty): boolean;
begin
 result:= (a.col = b.col) and (a.row = b.row);
end;

procedure stringcoltooptionsedit(const source: stringcoleditoptionsty; 
                                    var dest: optionseditty);
begin
 if scoe_undoonesc in source then begin
  include(dest,oe_undoonesc);
 end;
 if scoe_forcereturncheckvalue in source then begin
  include(dest,oe_forcereturncheckvalue);
 end;
 if scoe_eatreturn in source then begin
  include(dest,oe_eatreturn);
 end;
 dest:= optionseditty(replacebits(
               longword({$ifdef FPC}longword{$else}longword{$endif}(source))
                            shl stringcoloptionseditshift,
               longword(dest),longword(stringcoloptionseditmask)));
end;

procedure transferdeprecatedcoloptions(const source: coloptionsty;
                                var dest: coloptions1ty);
begin
 if co_rowfont in source then begin
  include(dest,co1_rowfont);
 end;
 if co_rowcolor in source then begin
  include(dest,co1_rowcolor);
 end;
 if co_zebracolor in source then begin
  include(dest,co1_zebracolor);
 end;
 if co_rowcoloractive in source then begin
  include(dest,co1_rowcoloractive);
 end;
end;

{ tcellframe }

constructor tcellframe.create(const intf: iframe);
begin
 inherited;
 include(fstate,fs_nowidget);
 fi.innerframe.right:= 1;
 fi.innerframe.top:= 1;
 fi.innerframe.left:= 1;
 fi.innerframe.bottom:= 1;
end;

{ tgridframe }

constructor tgridframe.create(const intf: iscrollframe; const owner: twidget;
                           const autoscrollintf: iautoscrollframe);
begin
 inherited;
 fi.innerframe.right:= 0;
 fi.innerframe.top:= 0;
 fi.innerframe.left:= 0;
 fi.innerframe.bottom:= 0;
 internalupdatestate;
 fi.levelo:= -2;
 fi.colorclient:= cl_foreground;
end;

function tgridframe.getscrollbarclass(vert: boolean): framescrollbarclassty;
begin
 result:= tthumbtrackscrollbar;
end;

{ tgridpropfont }

class function tgridpropfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tgridprop(owner).ffont;
end;

{ tgridprop }

constructor tgridprop.create(const agrid: tcustomgrid; 
                                 const aprop: tgridarrayprop);
begin
 fgrid:= agrid;
 fcolor:= cl_default;
 fcursor:= aprop.fcursor;
 fcolorselect:= aprop.fcolorselect;
 fcoloractive:= aprop.fcoloractive;
 fcolorfocused:= aprop.fcolorfocused;
 flinecolor:= aprop.linecolor;
 flinecolorfix:= aprop.linecolorfix;
 flinewidth:= aprop.linewidth;
 inherited create(agrid,aprop);
 agrid.initcellinfo(fcellinfo);
end;

destructor tgridprop.destroy;
begin
 inherited;
 fframe.free;
 fface.free;
 ffont.free;
end;

procedure tgridprop.createframe;
begin
 if fframe = nil then begin
  tcellframe.create(iframe(self));
 end;
end;

procedure tgridprop.createface;
begin
 if fface = nil then begin
  fface:= tcellface.create(iface(self));
 end;
end;

procedure tgridprop.setlinewidth(const Value: integer);
begin
 if flinewidth <> value then begin
  if value < 0 then begin
   flinewidth:= 0;
  end
  else begin
   flinewidth:= Value;
  end;
  fgrid.layoutchanged;
 end;
end;
{
function tgridprop.islinewidthstored: Boolean;
begin
 result:= flinewidth <> tcols(prop).flinewidth;
end;
}
procedure tgridprop.setlinecolor(const Value: colorty);
begin
 if flinecolor <> value then begin
  flinecolor:= Value;
  fgrid.layoutchanged;
 end;
end;
{
function tgridprop.islinecolorstored: Boolean;
begin
 result:= flinecolor <> tcols(prop).flinecolor;
end;
}
procedure tgridprop.setlinecolorfix(const Value: colorty);
begin
 if flinecolorfix <> value then begin
  flinecolorfix:= Value;
  fgrid.layoutchanged;
 end;
end;

procedure tgridprop.setcolorselect(const Value: colorty);
begin
 if value <> fcolorselect then begin
  fcolorselect := Value;
  changed;
 end;
end;

procedure tgridprop.setcoloractive(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 if avalue <> fcoloractive then begin
  fcoloractive:= avalue;
  fgrid.layoutchanged;
  changed;
 end;
end;

procedure tgridprop.setcolorfocused(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 if avalue <> fcolorfocused then begin
  fcolorfocused:= avalue;
  fgrid.layoutchanged;
  changed;
 end;
end;
{
function tgridprop.islinecolorfixstored: Boolean;
begin
 result:= flinecolorfix <> tgridarrayprop(prop).flinecolorfix;
end;

function tgridprop.iscolorselectstored: boolean;
begin
 result:= fcolorselect <> tgridarrayprop(prop).fcolorselect;
end;

function tgridprop.iscoloractivestored: boolean;
begin
 result:= fcoloractive <> tgridarrayprop(prop).fcoloractive;
end;
}
function tgridprop.getframe: tcellframe;
begin
 fgrid.getoptionalobject(fframe,{$ifdef FPC}@{$endif}createframe);
 result:= fframe;
end;

function tgridprop.getface: tcellface;
begin
 fgrid.getoptionalobject(fface,{$ifdef FPC}@{$endif}createface);
 result:= fface;
end;

 //iframe
function tgridprop.getwidget: twidget;
begin
 result:= fgrid;
end;

function tgridprop.getclientrect: rectty;
begin
 result:= fgrid.clientrect;
end;

procedure tgridprop.setlinkedvar(const source: tmsecomponent;
               var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 fgrid.setlinkedvar(source,dest,linkintf);
end;

procedure tgridprop.widgetregioninvalid;
begin
 fgrid.widgetregioninvalid;
end;

procedure tgridprop.setframeinstance(instance: tcustomframe);
begin
 fframe:= tcellframe(instance);
end;

function tgridprop.getwidgetrect: rectty;
begin
 result:= fcellrect;
end;
{
procedure tgridprop.setwidgetrect(const rect: rectty);
begin
 twidget1(getwidget).setwidgetrect(rect);
end;
}
procedure tgridprop.setstaticframe(value: boolean);
begin
 //dummy
end;

function tgridprop.getstaticframe: boolean;
begin
 result:= false;
end;

function tgridprop.widgetstate: widgetstatesty;
begin
 result:= twidget1(getwidget).widgetstate;
end;

procedure tgridprop.scrollwidgets(const dist: pointty);
begin
 twidget1(getwidget).scrollwidgets(dist);
end;

procedure tgridprop.clientrectchanged;
begin
 fgrid.layoutchanged;
end;

function tgridprop.getcomponentstate: tcomponentstate;
begin
 result:= getwidget.componentstate;
end;

function tgridprop.getmsecomponentstate: msecomponentstatesty;
begin
 result:= getwidget.msecomponentstate;
end;

procedure tgridprop.invalidate;
begin
 getwidget.invalidate;
end;

procedure tgridprop.invalidatewidget;
begin
 getwidget.invalidatewidget;
end;

procedure tgridprop.invalidaterect(const rect: rectty; 
               const org: originty = org_client; const noclip: boolean = false);
begin
 getwidget.invalidaterect(rect,org,noclip);
end;
{
function tgridprop.getframefont: tfont;
begin
 result:= twidget1(getwidget).getfont;
end;

function tgridprop.getcanvas(aorigin: originty = org_client): tcanvas;
begin
 result:= getwidget.getcanvas(aorigin);
end;

function tgridprop.canfocus: boolean;
begin
 result:= getwidget.canfocus;
end;

function tgridprop.setfocus(aactivate: boolean = true): boolean;
begin
 result:= getwidget.setfocus(aactivate);
end;
}
procedure tgridprop.setframe(const Value: tcellframe);
begin
 fgrid.setoptionalobject(value,fframe,{$ifdef FPC}@{$endif}createframe);
 clientrectchanged;
end;

procedure tgridprop.setface(const Value: tcellface);
begin
 fgrid.setoptionalobject(value,fface,{$ifdef FPC}@{$endif}createface);
 fgrid.invalidate;
end;

procedure tgridprop.drawcellbackground(const acanvas: tcanvas;
                const aframe: tcustomframe; const aface: tcustomface);
begin
 acanvas.fillrect(fcellrect,fcellinfo.color);
 if aframe <> nil then begin
//  aframe.paintbackground(acanvas,fcellinfo.rect);
  aframe.paintbackground(acanvas,fcellrect);
 end;
 acanvas.rootbrushorigin:= fgrid.fbrushorigin;
 if aface <> nil then begin
//  aface.paint(acanvas,fcellinfo.rect);
  aface.paint(acanvas,makerect(nullpoint,fcellinfo.rect.size));
 end;
end;

procedure tgridprop.drawcelloverlay(const acanvas: tcanvas;
                const aframe: tcustomframe);
begin
 if aframe <> nil then begin
  aframe.paintoverlay(acanvas,makerect(nullpoint,fcellrect.size));
 end;
end;

procedure tgridprop.setcolor(const Value: colorty);
begin
 if color <> value then begin
  fcolor := Value;
  changed;
 end;
end;

procedure tgridprop.changed;
begin
 //dummy
end;

function tgridprop.getinnerframe: framety;
begin
 result:= tgridarrayprop(prop).finnerframe;
end;

procedure tgridprop.updatecellrect(const aframe: tcustomframe);
begin
 fcellinfo.rect:= fcellrect;
 if aframe <> nil then begin
  deflaterect1(fcellinfo.rect,tframe1(aframe).fpaintframe);
  with tframe1(aframe).fi.innerframe do begin
   fcellinfo.innerrect.pos:= pointty(topleft);
   fcellinfo.innerrect.cx:= fcellinfo.rect.cx - left - right;
   fcellinfo.innerrect.cy:= fcellinfo.rect.cy - top - bottom;
   fcellinfo.frameinnerrect:= fcellinfo.innerrect;
  end;
 end
 else begin
  fcellinfo.innerrect:= deflaterect(makerect(nullpoint,fcellinfo.rect.size),
                                  getinnerframe);
  fcellinfo.frameinnerrect:= fcellinfo.rect;
 end;
end;

procedure tgridprop.updatelayout;
begin
 if fframe <> nil then begin
  fframe.updatestate;
 end;
 updatecellrect(fframe);
end;

//iface
function tgridprop.translatecolor(const acolor: colorty): colorty;
begin
 result:= acolor;
end;

procedure tgridprop.fontchanged(const sender: tobject);
begin
 changed;
end;

function tgridprop.getfont: tgridpropfont;
begin
 getoptionalobject(fgrid.componentstate,ffont,{$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= tgridpropfont(pointer(fgrid.getfont));
 end;
end;

procedure tgridprop.setfont(const Value: tgridpropfont);
begin
 if value <> ffont then begin
  setoptionalobject(fgrid.ComponentState,value,ffont,{$ifdef FPC}@{$endif}createfont);
  changed;
 end;
end;

function tgridprop.isfontstored: Boolean;
begin
 result:= ffont <> nil;
end;

procedure tgridprop.createfont;
begin
 if ffont = nil then begin
  ffont:= tgridpropfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function tgridprop.getframestateflags: framestateflagsty;
begin
 result:= [];
end;

procedure tgridprop.updatecellheight(const canvas: tcanvas; var aheight: integer);
begin
 //dummy
end;

{ tcolselectfont }

class function tcolselectfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcol(owner).ffontselect;
end;

{ tcol}

constructor tcol.create(const agrid: tcustomgrid; const aowner: tgridarrayprop);
begin
 inherited create(agrid,aowner);
 ffocusrectdist:= tcols(aowner).ffocusrectdist;
 fwidth:= tcols(aowner).fwidth;
 foptions:= tcols(aowner).foptions;
 foptions1:= tcols(aowner).foptions1;
// foptionscell:= tcols(aowner).foptionscell;
 flinewidth:= tcols(aowner).flinewidth;
 flinecolor:= tcols(aowner).flinecolor;
 ffontactivenum:= tcols(aowner).ffontactivenum;
 ffontfocusednum:= tcols(aowner).ffontfocusednum;
end;

destructor tcol.destroy;
begin
 ffontselect.free;
 inherited;
end;
(*
procedure tcol.readoptions(reader: treader);
var
 set1,set2: tintegerset;
begin
 if readsplitset(reader,coloptionssplitinfo,set1,set2) then begin
  optionscell:= celloptionsty(set2);
 end;
 options:= coloptionsty(set1);
// options:= coloptionsty(readset(reader,typeinfo(coloptionsty)));
end;

procedure tcol.defineproperties(filer: tfiler);
begin
 filer.defineproperty('options',{$ifdef FPC}@{$endif}readoptions,nil,false);
end;
*)
procedure tcol.invalidate;
begin
 fgrid.colchanged(self);
end;

procedure tcol.changed;
begin
 inherited;
 invalidate;
end;

procedure tcol.cellchanged(const row: integer);
begin
 fgrid.cellchanged(self,row);
end;

procedure tcol.invalidatecell(const arow: integer);
begin
 fgrid.invalidatecell(makegridcoord(colindex,arow));
end;

procedure tcol.drawcell(const acanvas: tcanvas);
begin
 if not fcellinfo.calcautocellsize then begin
  drawcellbackground(acanvas,fframe,fface);
 end;
end;

function tcol.actualcolor: colorty;
begin
 if fcolor <> cl_default then begin
  if fcolor = cl_parent then begin
   result:= fgrid.actualopaquecolor;
  end
  else begin
   result:= fcolor;
  end;
 end
 else begin
  result:= fgrid.fframe.colorclient;
 end;
end;

function tcol.isopaque: boolean;
begin
 result:= actualcolor <> cl_transparent;
end;

function tcol.checkactivecolor(const aindex: integer): boolean; 
         //true if coloractive and fontactivenum active
begin
 result:= (fgrid.entered {or (co1_active in foptions1)}) and
          (aindex = fgrid.ffocusedcell.row) and 
          ((gps_fix in fstate) or (co1_rowcoloractive in foptions1) or 
                               (findex = fgrid.ffocusedcell.col))
end;

function tcol.checkfocusedcolor(const aindex: integer): boolean; 
         //true if colorfocus and fontfocusnum active
begin
 result:= //(fgrid.entered {or (co1_active in {tcols(prop).}foptions1)}) and 
          (aindex = fgrid.ffocusedcell.row) and 
          ((gps_fix in fstate) or (co1_rowcolorfocused in foptions1) or 
                               (findex = fgrid.ffocusedcell.col))
end;

function tcol.rowcolor(const aindex: integer): colorty;
var
 po1: prowstatety;
 by1: byte;
 int1: integer;
 bo1: boolean;
begin
 result:= cl_none;
 if aindex >= 0 then begin
  bo1:= getselected(aindex);
  if co1_rowcolor in foptions1 then begin
   po1:= fgrid.fdatacols.frowstate.getitempo(aindex);
   by1:= po1^.color;
//   if by1 <> 0 then begin
    int1:= by1 + frowcoloroffset - 1;
    if bo1 then begin
     int1:= int1 + frowcoloroffsetselect;
    end;
    if (int1 >= 0) and (int1 < fgrid.frowcolors.count) then begin
     result:= fgrid.frowcolors[int1];
    end;
//   end;
  end;
  if bo1 and (result = cl_none) and (fcolorselect <> cl_none) then begin
   if fcolorselect <> cl_default then begin
    result:= fcolorselect;
   end
   else begin
    result:= defaultselectedcellcolor;
   end;
  end;
  if (result = cl_none) and checkactivecolor(aindex) then begin
   result:= fcoloractive;
  end;
  if (result = cl_none) and checkfocusedcolor(aindex) then begin
   result:= fcolorfocused;
  end;
  if result = cl_none then begin
   if (co1_zebracolor in foptions1) then begin
    with fgrid do begin
     if (fzebra_step > 0) then begin
      int1:= (aindex - getzebrastart) mod fzebra_step;
      if int1 < 0 then begin
       if int1  < fzebra_height - fzebra_step then begin
        result:= fzebra_color;
       end;
      end
      else begin
       if int1  < fzebra_height then begin
        result:= fzebra_color;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 if result = cl_none then begin
  result:= actualcolor;
 end;
end;

function tcol.actualfont: tfont;
begin
 if ffont = nil then begin
  result:= fgrid.getfont;
 end
 else begin
  result:= ffont;
 end;
end;

function tcol.rowfont(const aindex: integer): tfont;
var
 po1: prowstatety;
 by1: byte;
 int1: integer;
 bo1: boolean;
begin
 result:= nil;
 if aindex >= 0 then begin
  bo1:= getselected(aindex);
  if co1_rowfont in foptions1 then begin
   po1:= fgrid.fdatacols.frowstate.getitempo(aindex);
   by1:= po1^.font;
   if by1 <> 0 then begin
    int1:= by1 + frowfontoffset - 1;
    if bo1 then begin
     int1:= int1 + frowfontoffsetselect;
    end;
    if (int1 >= 0) and (int1 < fgrid.frowfonts.count) then begin
     result:= tfont(fgrid.frowfonts.fitems[int1]);
    end;
   end;
  end;
  if bo1 and (result = nil) then begin
   result:= ffontselect;
   if result = nil then begin
    result:= tcols(prop).ffontselect;
   end;
  end;
 end;
 if result = nil then begin
  if (ffontactivenum >= 0) and (ffontactivenum < fgrid.frowfonts.count) then begin
   if checkactivecolor(aindex) then begin
    result:= tfont(fgrid.frowfonts.fitems[ffontactivenum]);
   end;
  end;
  if result = nil then begin
   if (ffontfocusednum >= 0) and (ffontfocusednum < fgrid.frowfonts.count) then begin
    if checkfocusedcolor(aindex) then begin
     result:= tfont(fgrid.frowfonts.fitems[ffontfocusednum]);
    end;
   end;
   if result = nil then begin
    result:= actualfont;
   end;
  end;
 end;
end;

function tcol.getdatapo(const arow: integer): pointer;
begin
 result:= nil;
end;

procedure tcol.paint(var info: colpaintinfoty);
var
 int1,int2,int3: integer;
 isfocusedcol: boolean;
 bo1,bo2: boolean;
 saveindex: integer;
 linewidthbefore: integer;
 font1: tfont;
 canbeforedrawcell: boolean;
 canafterdrawcell: boolean;
 row1: integer;
 hiddenlines: integerarty;
 segments1: segmentarty;
 po1: pdatacolaty;
 nextcol: tdatacol;
 widthextend,heightextend: integer;
 checkmerge: boolean;
 hasrowheight: boolean;
 rowstatelist: trowstatelist;
 endy: integer;

begin
 if not (co_invisible in foptions) or (csdesigning in fgrid.ComponentState) then begin
  checkmerge:= og_colmerged in fgrid.foptionsgrid;
  canbeforedrawcell:= fgrid.canevent(tmethod(fonbeforedrawcell));
  canafterdrawcell:= fgrid.canevent(tmethod(fonafterdrawcell));
  hiddenlines:= nil;
  with info do begin
   fcellinfo.calcautocellsize:= calcautocellsize;
   fcellinfo.autocellsize:= autocellsize;
   fgrid.fbrushorigin.x:= fgrid.frootbrushorigin.x;
   if not (co_nohscroll in foptions) then begin
    fgrid.fbrushorigin.x:= fgrid.fbrushorigin.x + fgrid.fscrollrect.x;
   end;
   fcellinfo.font:= nil;
   isfocusedcol:= (fcellinfo.cell.col = fgrid.ffocusedcell.col) and
       (gs_cellentered in fgrid.fstate);
   canvas.drawinfopo:= @fcellinfo;
   canvas.move(makepoint(fcellrect.x,fcellrect.y + ystart));
   fcellinfo.foldinfo:= nil;
   nextcol:= nil;
   po1:= nil;
   if not (gps_fix in fstate) then begin
    po1:= pointer(fgrid.fdatacols.fitems);
    if index <> fgrid.datacols.lastvisiblecol then begin
     nextcol:= po1^[index+1];
    end;
   end;
   clean(startrow,endrow);
   hasrowheight:= og_rowheight in fgrid.optionsgrid;
   rowstatelist:= fgrid.fdatacols.frowstate;
   for int1:= startrow to endrow do begin
    row1:= rows[int1];
    fcellinfo.cell.row:= row1;
    fcellinfo.rowstate:= rowstatelist.getitempo(row1);
    bo1:= false;
    if checkmerge and (nextcol <> nil) and nextcol.merged[row1] then begin
     bo1:= true;                //has merged columns
     additem(hiddenlines,row1); //by merged columns
    end;
    if not checkmerge or not merged[row1] then begin
     heightextend:= 0;
     if hasrowheight then begin
      with fcellinfo do begin
//       int2:= prowstaterowheightty(rowstate)^.rowheight.height;
//       if int2 = 0 then begin
//        int2:= fgrid.fdatarowheight;
//       end;
//       heightextend:= int2 - rect.cy;
       heightextend:= rowstatelist.internalheight(row1) - rect.cy;
       int2:= rowstatelist.linewidth[row1];
       if int2 > 0 then begin
        heightextend:= heightextend - int2 + fgrid.fdatarowlinewidth;
       end;
       inc(fcellrect.cy,heightextend);      
       inc(rect.cy,heightextend);      
       inc(innerrect.cy,heightextend);      
       inc(frameinnerrect.cy,heightextend);
      end;
     end;
     widthextend:= 0;
     if bo1 then begin
      for int2:= index + 1 to fgrid.fdatacols.count - 1 do begin
       with po1^[int2] do begin
        if not (co_invisible in foptions) then begin
         if merged[row1] then begin
          inc(widthextend,step);
         end
         else begin
          break;
         end;
        end;
       end;
      end;
      with fcellinfo do begin
       inc(fcellrect.cx,widthextend);      
       inc(rect.cx,widthextend);      
       inc(innerrect.cx,widthextend);      
       inc(frameinnerrect.cx,widthextend);
      end;
     end;
     try
      font1:= rowfont(row1);
      if font1 <> fcellinfo.font then begin
       fcellinfo.font:= font1;
       canvas.font:= font1;
      end;
      if og_folded in fgrid.foptionsgrid then begin
       fcellinfo.foldinfo:= @foldinfo[int1];
      end;
      fcellinfo.datapo:= getdatapo(row1);
      fcellinfo.selected:= getselected(row1);
      fcellinfo.readonly:= fgrid.getrowreadonlystate(row1);
      fcellinfo.notext:= false;
      fcellinfo.ismousecell:= (fgrid.fmousecell.col = fcellinfo.cell.col) and 
                                (fgrid.fmousecell.row = row1);
      saveindex:= canvas.save;
      fcellinfo.color:= rowcolor(row1);
//      canvas.intersectcliprect(makerect(nullpoint,fcellinfo.rect.size));
      canvas.intersectcliprect(fcellrect);
      bo2:= false;
      if canbeforedrawcell then begin
       fonbeforedrawcell(self,canvas,fcellinfo,bo2);
      end;
      if not bo2 then begin
       if isfocusedcol and (row1 = fgrid.ffocusedcell.row) then begin
        drawfocusedcell(canvas);
       end
       else begin
        drawcell(canvas);
       end;
      end;
      if canafterdrawcell then begin
       fonafterdrawcell(self,canvas,fcellinfo);
      end;
      canvas.restore(saveindex);
      if calcautocellsize then begin
       autocellsize:= fcellinfo.autocellsize;
       exit;
      end;

      if not bo2 then begin
       drawcelloverlay(canvas,fframe);
      end;
      if isfocusedcol and (row1 = fgrid.ffocusedcell.row) and 
                                   (co_drawfocus in foptions) then begin
       if fframe <> nil then begin
        canvas.move(fframe.fpaintrect.pos);
       end;
       drawfocus(canvas);
       if fframe <> nil then begin
        canvas.remove(fframe.fpaintrect.pos);
       end;
      end;
     finally
      if heightextend <> 0 then begin
       with fcellinfo do begin  //restore original values
        dec(fcellrect.cy,heightextend);      
        dec(rect.cy,heightextend);      
        dec(innerrect.cy,heightextend);      
        dec(frameinnerrect.cy,heightextend);
       end;
      end;
      if widthextend <> 0 then begin
       with fcellinfo do begin  //restore original values
        dec(fcellrect.cx,widthextend);      
        dec(rect.cx,widthextend);      
        dec(innerrect.cx,widthextend);      
        dec(frameinnerrect.cx,widthextend);
       end;
      end;
     end;
    end;
    if hasrowheight then begin
//     int2:= prowstaterowheightty(fcellinfo.rowstate)^.rowheight.height;
//     if int2 = 0 then begin
//      int2:= fgrid.fdatarowheight;
//     end;
//     canvas.move(makepoint(0,int2+fgrid.fdatarowlinewidth));
     canvas.move(makepoint(0,rowstatelist.internalystep(row1)));
    end
    else begin
     canvas.move(makepoint(0,ystep));
    end;
   end;
   if flinewidth > 0 then begin
    linewidthbefore:= canvas.linewidth;
    if flinewidth = 1 then begin
     canvas.linewidth:= 0;
    end
    else begin
     canvas.linewidth:= flinewidth;
    end;
    if hasrowheight then begin
     endy:= rowstatelist.getrowypos(rows[endrow]+1)
    end;
    if hiddenlines = nil then begin
     if hasrowheight then begin
      int2:= endy - rowstatelist.getrowypos(rows[0])
     end
     else begin
      int2:= ystep * length(rows);
     end;
     canvas.drawline(makepoint(flinepos,-int2),
                       makepoint(flinepos,-1),flinecolor);
    end
    else begin
     setlength(segments1,endrow-startrow+1); //max
     int2:= 0; //index in hiddenlines
     int3:= 0; //index in segments1
     bo1:= false; //line started
     bo2:= false; //line stopped
     for int1:= startrow to endrow do begin
      if (int2 > high(hiddenlines)) or 
                              (rows[int1] <> hiddenlines[int2]) then begin
       if not bo1 then begin      //start line
        bo1:= true;
        bo2:= false;
        with segments1[int3] do begin
         a.x:= flinepos;
         b.x:= flinepos;
         if hasrowheight then begin
          a.y:= rowstatelist.getrowypos(rows[int1]) - endy;
         end
         else begin
          a.y:= -ystep * (endrow-int1+1);
         end;
        end;
       end;
      end
      else begin
       if not bo2 and bo1 then begin //stop line
        bo2:= true;
        bo1:= false;
        if hasrowheight then begin
         segments1[int3].b.y:= rowstatelist.getrowypos(rows[int1]) - endy - 1;
        end
        else begin
         segments1[int3].b.y:= -ystep * (endrow-int1+1)-1;
        end;
        inc(int3);
       end;
       inc(int2);
      end;
     end;
     if bo1 and not bo2 then begin //finish last line
      segments1[int3].b.y:= -1;
      inc(int3);
     end;
     setlength(segments1,int3);
     canvas.drawlinesegments(segments1,flinecolor);
    end;
    canvas.linewidth:= linewidthbefore;
   end;
  end;
 end;
end;

procedure tcol.rowcountchanged(const newcount: integer);
begin
 //dummy
end;

procedure tcol.updatepropwidth;
var
 int1: integer;
begin
 if not (csloading in fgrid.componentstate) and 
                        not (gs_updatelocked in fgrid.fstate) then begin
//  int1:= tgridframe(fgrid.fframe).fpaintrect.cx;
  int1:= fgrid.fpropcolwidthref;
  if int1 <> 0 then begin
   fpropwidth:= fwidth / int1;
  end;
 end;
end;

procedure tcol.setwidth(const Value: integer);
begin
 if fwidth <> value then begin
  if value < 0 then begin
   fwidth:= 0;
  end
  else begin
   fwidth:= Value;
  end;
  fgrid.layoutchanged;
  if (gps_needsrowheight in fstate) and 
        not (csloading in fgrid.componentstate) then begin
//   updatecellrect(fframe);
   fgrid.updatelayout;
   fgrid.datacols.rowstate.change(-1);
  end;
  updatepropwidth;
 end;
end;

class function tcol.defaultstep(width: integer): integer;
begin
 result:= width + defaultgridlinewidth;
end;

function tcol.step(getscrollable: boolean = true): integer;
begin
 result:= 0;
 if (getscrollable xor (co_nohscroll in foptions)) and
 (not (co_invisible in foptions) or (csdesigning in fgrid.ComponentState)) then begin
  result:= fwidth + flinewidth;
 end;
end;

function tcol.getcolindex: integer;
begin
 fgrid.internalupdatelayout;
 result:= fcellinfo.cell.col;
end;

procedure tcol.drawfocusedcell(const acanvas: tcanvas);
begin
 fgrid.drawfocusedcell(acanvas);
end;

function tcol.getselected(const row: integer): boolean;
begin
 if row >= 0 then begin
  result:= (gps_selected in fstate) or
   (fgrid.fdatacols.frowstate.getitempo(row)^.selected and
               wholerowselectedmask <> 0);
 end
 else begin
  result:= gps_selected in fstate;
 end;
end;

procedure tcol.invalidatelayout;
var
 int1: integer;
begin
 if not (csreading in fgrid.componentstate) then begin
  fgrid.layoutchanged;
  with tgridarrayprop(prop) do begin //grid propewidthref is invalid
   for int1:= 0 to high(fitems) do begin
    tcol(fitems[int1]).fpropwidth:= 0;
   end;
  end;     
 end;
end;

procedure tcol.setoptions(const Value: coloptionsty);
var
 valuebefore: coloptionsty;
begin
 if foptions <> value then begin
  valuebefore:= foptions;
  foptions:= value - deprecatedcoloptions;
  if csreading in fgrid.componentstate then begin
   transferdeprecatedcoloptions(value,foptions1);
  end;
  if bitschanged({$ifdef FPC}longword{$else}longword{$endif}(foptions),
         {$ifdef FPC}longword{$else}longword{$endif}(valuebefore),
         {$ifdef FPC}longword{$else}longword{$endif}(layoutchangedcoloptions)) then begin
   invalidatelayout;
  end
  else begin
   changed;
  end;
 end;
end;

procedure tcol.setoptions1(const avalue: coloptions1ty);
var
 optionsbefore: coloptions1ty;
 opt1: coloptions1ty;
begin
// avalue:= avalue - deprecatedcoloptions1;
 optionsbefore:= foptions1;
 foptions1:= avalue;
 opt1:= coloptions1ty({$ifdef FPC}longword{$else}byte{$endif}(optionsbefore) xor
                      {$ifdef FPC}longword{$else}byte{$endif}(foptions1));
 if co1_autorowheight in opt1 then begin
  if co1_autorowheight in foptions1 then begin
   include(fstate,gps_needsrowheight);
  end
  else begin
   exclude(fstate,gps_needsrowheight);
  end; 
  fgrid.checkneedsrowheight;
 end;
 if opt1 * layoutchangedcoloptions1 <> [] then begin
  invalidatelayout;
 end;
end;


procedure tcol.setfocusrectdist(const avalue: integer);
begin
 if ffocusrectdist <> avalue then begin
  ffocusrectdist:= avalue;
  changed;
 end;
end;

procedure tcol.drawfocus(const acanvas: tcanvas);
begin
 drawfocusrect(acanvas,inflaterect(makerect(nullpoint,fcellinfo.rect.size),
                    -ffocusrectdist));
end;
{
function tcol.isoptionsstored: Boolean;
begin
 result:= foptions <> tcols(prop).foptions;
end;

function tcol.isfocusrectdiststored: boolean;
begin
 result:= ffocusrectdist <> tcols(prop).ffocusrectdist;
end;
}
procedure tcol.updatelayout;
begin
 fcellrect.size.cy:= fgrid.fdatarowheight;
 fcellrect.size.cx:= fwidth;
 fcellrect.y:= 0;
 if fcellinfo.cell.col <= tgridarrayprop(prop).ffirstopposite then begin
  flinepos:= -((flinewidth+1) div 2);
  fcellrect.x:= flinewidth;
 end
 else begin
  flinepos:= fwidth + flinewidth div 2;
  fcellrect.x:= 0;
 end;
 inherited;
end;

procedure tcol.setrowcoloroffset(const avalue: integer);
begin
 if frowcoloroffset <> avalue then begin
  frowcoloroffset:= avalue;
  invalidate;
 end;
end;

procedure tcol.setrowcoloroffsetselect(const avalue: integer);
begin
 if frowcoloroffsetselect <> avalue then begin
  frowcoloroffsetselect:= avalue;
  invalidate;
 end;
end;

procedure tcol.setrowfontoffset(const avalue: integer);
begin
 if frowfontoffset <> avalue then begin
  frowfontoffset:= avalue;
  invalidate;
 end;
end;

procedure tcol.setrowfontoffsetselect(const avalue: integer);
begin
 if frowfontoffsetselect <> avalue then begin
  frowfontoffsetselect:= avalue;
  invalidate;
 end;
end;
{
function tcol.iswidthstored: boolean;
begin
 result:= fwidth <> tcols(prop).fwidth;
end;
}
function tcol.getfontselect: tcolselectfont;
begin
 getoptionalobject(fgrid.componentstate,ffontselect,{$ifdef FPC}@{$endif}createfontselect);
 if ffontselect <> nil then begin
  result:= ffontselect;
 end
 else begin
  result:= tcolselectfont(pointer(getfont));
 end;
end;

procedure tcol.setfontselect(const Value: tcolselectfont);
begin
 if value <> ffontselect then begin
  setoptionalobject(fgrid.ComponentState,value,ffontselect,{$ifdef FPC}@{$endif}createfontselect);
  changed;
 end;
end;

function tcol.isfontselectstored: Boolean;
begin
 result:= ffontselect <> nil;
end;

procedure tcol.setfontactivenum(const avalue: integer);
begin
 if ffontactivenum <> avalue then begin
  ffontactivenum:= avalue;
  invalidate;
 end;
end;

procedure tcol.setfontfocusednum(const avalue: integer);
begin
 if ffontfocusednum <> avalue then begin
  ffontfocusednum:= avalue;
  invalidate;
 end;
end;

procedure tcol.createfontselect;
begin
 if ffontselect = nil then begin
  ffontselect:= tcolselectfont.create;
  ffontselect.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function tcol.translatetocell(const arow: integer;
               const apos: pointty): pointty;
begin
 result:= subpoint(apos,fgrid.cellrect(makegridcoord(colindex,arow)).pos);
end;

function tcol.getmerged(const row: integer): boolean;
begin
 result:= false;
end;

procedure tcol.setmerged(const row: integer; const avalue: boolean);
begin
 //dummy
end;

procedure tcol.clean(const start,stop: integer);
begin
 //dummy
end;

{ tcolheaderfont }

class function tcolheaderfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcolheader(owner).ffont;
end;

{ tcolheader }

constructor tcolheader.create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop);
begin
 initcaptioninfo(finfo);
 with finfo do begin
  imagenr:= -1;
  colorglyph:= cl_glyph;
  imagepos:= ip_right;
 end;
// finfo.textflags:= defaultcolheadertextflags;
 fcolor:= cl_parent;
 inherited;
 fgrid:= tcolheaders(fowner).fgridprop.fgrid;
end;

destructor tcolheader.destroy;
begin
 inherited;
 ffont.free;
 fframe.free;
 fface.free;
end;

procedure tcolheader.readcaptionpos(reader: treader);
begin
 imagepos:= readcaptiontoimagepos(reader);
end;

procedure tcolheader.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('captionpos',{$ifdef FPC}@{$endif}readcaptionpos,nil,false);
end;

procedure tcolheader.changed;
begin
 tcolheaders(fowner).dochange(findex);
end;

function tcolheader.getfont: tcolheaderfont;
begin
 getoptionalobject(fgrid.componentstate,ffont,{$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= tcolheaderfont(pointer(tcolheaders(fowner).fgridprop.getfont));
 end;
end;

procedure tcolheader.setfont(const Value: tcolheaderfont);
begin
 if value <> ffont then begin
  setoptionalobject(tcolheaders(fowner).fgridprop.fgrid.ComponentState,
               value,ffont,{$ifdef FPC}@{$endif}createfont);
  changed;
 end;
end;

function tcolheader.isfontstored: Boolean;
begin
 result:= ffont <> nil;
end;

procedure tcolheader.createfont;
begin
 if ffont = nil then begin
  ffont:= tcolheaderfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

procedure tcolheader.fontchanged(const sender: tobject);
begin
 changed;
end;

procedure tcolheader.drawcell(const acanvas: tcanvas; const adest: rectty);
begin
 with finfo do begin
  font:= getfont;
  dim:= adest;
  drawcaption(acanvas,finfo);
 end;
end;

 //iframe
function tcolheader.getwidget: twidget;
begin
 result:= fgrid;
end;

function tcolheader.getclientrect: rectty;
begin
 result:= fgrid.clientrect;
end;

procedure tcolheader.setlinkedvar(const source: tmsecomponent;
               var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 fgrid.setlinkedvar(source,dest,linkintf);
end;

procedure tcolheader.widgetregioninvalid;
begin
 fgrid.widgetregioninvalid;
end;

procedure tcolheader.setframeinstance(instance: tcustomframe);
begin
 fframe:= tfixcellframe(instance);
end;

function tcolheader.getwidgetrect: rectty;
begin
 result:= nullrect;
// result:= fcellrect;
end;

procedure tcolheader.setstaticframe(value: boolean);
begin
// twidget1(getwidget).setstaticframe(value);
end;

function tcolheader.getstaticframe: boolean;
begin
 result:= false;
end;

function tcolheader.widgetstate: widgetstatesty;
begin
 result:= twidget1(getwidget).widgetstate;
end;

procedure tcolheader.scrollwidgets(const dist: pointty);
begin
// twidget1(getwidget).scrollwidgets(dist);
end;

procedure tcolheader.clientrectchanged;
begin
 changed;
// fgrid.layoutchanged;
end;

function tcolheader.getcomponentstate: tcomponentstate;
begin
 result:= getwidget.componentstate;
end;

function tcolheader.getmsecomponentstate: msecomponentstatesty;
begin
 result:= getwidget.msecomponentstate;
end;

procedure tcolheader.invalidate;
begin
 changed;
// getwidget.invalidate;
end;

procedure tcolheader.invalidatewidget;
begin
 changed;
// getwidget.invalidatewidget;
end;

procedure tcolheader.invalidaterect(const rect: rectty; 
        const org: originty = org_client; const noclip: boolean = false);
begin
 changed;
// getwidget.invalidaterect(rect,org);
end;

//iface
function tcolheader.translatecolor(const acolor: colorty): colorty;
begin
 result:= acolor;
end;

procedure tcolheader.setcaption(const avalue: msestring);
begin
 finfo.caption.text:= avalue;
 changed;
end;

procedure tcolheader.settextflags(const avalue: textflagsty);
begin
 if finfo.textflags <> avalue then begin
  finfo.textflags:= checktextflags(finfo.textflags,avalue);
  changed;
 end;
end;

function tcolheader.getframe: tfixcellframe;
begin
 fgrid.getoptionalobject(fframe,{$ifdef FPC}@{$endif}createframe);
 result:= fframe;
end;

procedure tcolheader.setframe(const avalue: tfixcellframe);
begin
 fgrid.setoptionalobject(avalue,fframe,{$ifdef FPC}@{$endif}createframe);
 clientrectchanged;
end;

function tcolheader.getface: tfixcellface;
begin
 fgrid.getoptionalobject(fface,{$ifdef FPC}@{$endif}createface);
 result:= fface;
end;

procedure tcolheader.setface(const avalue: tfixcellface);
begin
 fgrid.setoptionalobject(avalue,fface,{$ifdef FPC}@{$endif}createface);
 fgrid.invalidate;
end;

procedure tcolheader.createframe;
begin
 tfixcellframe.create(iframe(self));
end;

procedure tcolheader.createface;
begin
 fface:= tfixcellface.create(iface(self));
end;

procedure tcolheader.setcolor(const avalue: colorty);
begin
 if fcolor <> avalue then begin
  fcolor:= avalue;
  changed;
 end;
end;

procedure tcolheader.setmergecols(const avalue: integer);
begin
 if fmergecols <> avalue then begin
  fmergecols:= avalue;
  fgrid.layoutchanged;
  if fgrid.componentstate * [csloading,csdesigning,csdestroying] = 
                            [csdesigning] then begin
   fgrid.updatelayout; //check colheaders.count
  end;
 end;
end;

procedure tcolheader.setmergerows(const avalue: integer);
begin
 if fmergerows <> avalue then begin
  fmergerows:= avalue;
  fgrid.layoutchanged;
  if fgrid.componentstate * [csloading,csdesigning,csdestroying] = 
                            [csdesigning] then begin
   fgrid.updatelayout; //check colheaders.count
  end;
 end;
end;

function tcolheader.getframestateflags: framestateflagsty;
begin
 result:= [];
end;

procedure tcolheader.setimagenr(const avalue: imagenrty);
begin
 if finfo.imagenr <> avalue then begin
  finfo.imagenr:= avalue;
  changed;
 end;
end;

procedure tcolheader.setcolorglyph(const avalue: colorty);
begin
 if finfo.colorglyph <> avalue then begin
  finfo.colorglyph:= avalue;
  changed;
 end;
end;

procedure tcolheader.setimagepos(const avalue: imageposty);
begin
 if finfo.imagepos <> avalue then begin
  finfo.imagepos:= simpleimagepos[avalue];
  changed;
 end;
end;

procedure tcolheader.setimagedist(const avalue: integer);
begin
 if finfo.imagedist <> avalue then begin
  finfo.imagedist:= avalue;
  changed;
 end;
end;

procedure tcolheader.setcaptiondist(const avalue: integer);
begin
 if finfo.captiondist <> avalue then begin
  finfo.captiondist:= avalue;
  changed;
 end;
end;

function tcolheader.getimagelist: timagelist;
begin
 result:= finfo.imagelist;
end;

procedure tcolheader.setimagelist(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(finfo.imagelist));
 changed;
end;

{ tdatacolheader }

procedure tdatacolheader.setoptions(const avalue: datacolheaderoptionsty);
begin
 foptions:= avalue;
end;

procedure tdatacolheader.drawcell(const acanvas: tcanvas; const adest: rectty);
var
 rect1: rectty;
 al1: alignmentsty;
 int1: integer;
begin
 if (dco_colsort in foptions) and (index < fgrid.datacols.count) then begin
  rect1:= adest;
  al1:= [al_right,al_ycentered];
  with tdatacol(fgrid.fdatacols.fitems[index]) do begin
   if (co_nosort in options) or (fgrid.datacols.sortcol >= 0) and 
                                (fgrid.datacols.sortcol <> index) then begin
    include(al1,al_grayed);
   end;
   if co_sortdescent in options then begin
    int1:= ord(stg_arrowupsmall);
   end
   else begin
    int1:= ord(stg_arrowdownsmall);
   end;
  end;
  inc(rect1.cx,(15-sortglyphwidth) div 2);
  stockobjects.glyphs.paint(acanvas,int1,rect1,al1,finfo.colorglyph);
  dec(rect1.cx,15);
  inherited drawcell(acanvas,rect1);
 end
 else begin
  inherited;
 end;
end;

{ tcolheaders }

constructor tcolheaders.create(const agridprop: tgridprop);
begin
 fgridprop:= agridprop;
 inherited create(self,indexpersistentclassty(getitemclasstype));
end;

procedure tcolheaders.movecol(const curindex,newindex: integer);
var
 int1: integer;
begin
 if (curindex <= high(fitems)) or (newindex <= high(fitems)) then begin
  int1:= curindex;
  if newindex > high(fitems) then begin
   count:= newindex + 1;
  end;
  if curindex > high(fitems) then begin
   count:= high(fitems) + 2;
   int1:= high(fitems);
  end;
  move(int1,newindex);
 end;
end;

procedure tcolheaders.colcountchanged(const acount: integer);
begin
end;

procedure tcolheaders.updatelayout(const cols: tgridarrayprop);
var
 int1,int2,int3,int4: integer;
 headers1: tcolheaders;
 header1: tcolheader;
 lastmergedcol: integer;
 lastmergedrow: integer;
 bo1: boolean;
 cell1: gridcoordty;
begin
 int2:= count;
 for int1:= 0 to count - 1 do begin
  with tcolheader(fitems[int1]) do begin
   fmergeflags:= [];
   int3:= int1 + fmergecols;
   if int3 >= int2 then begin
    int2:= int3 + 1;
   end;
  end;
 end;
 if int2 > count then begin
  count:= int2;
 end;
 cell1.row:= -fgridprop.index - 1;
 for int1:= 0 to count -1 do begin
  if ffixcol then begin
   cell1.col:= -int1-1;
  end
  else begin
   cell1.col:= int1;
  end;
  with tcolheader(fitems[int1]) do begin
   lastmergedcol:= int1 + fmergecols;
   if lastmergedcol >= count then begin
    lastmergedcol:= count - 1;
   end;
   if lastmergedcol >= cols.count then begin
    lastmergedcol:= cols.count - 1;
   end;
   if int1 < lastmergedcol then begin
    fmergedcx:= tgridprop(cols.fitems[int1]).flinewidth -
                tgridprop(cols.fitems[lastmergedcol]).flinewidth;
    if cols.freversedorder then begin
     fmergedx:= -fmergedcx;
    end
    else begin
     fmergedx:= 0;
    end;
    for int2:= int1 + 1 to lastmergedcol do begin
     with tcolheader(fitems[int2]) do begin
      include(fmergeflags,cmf_h);
      frefcell:= cell1;
     end;
     int4:= tgridprop(cols.fitems[int2]).step;
     inc(fmergedcx,int4);
     if cols.freversedorder then begin
      dec(fmergedx,int4);
     end;
    end;
   end
   else begin
    fmergedcx:= 0;
    fmergedx:= 0;
   end;
   lastmergedrow:= fgridprop.index + fmergerows;
   if lastmergedrow >= fgrid.fixrows.count then begin
    lastmergedrow:= fgrid.fixrows.count-1;
   end;
   if fgridprop.index < lastmergedrow then begin
    fmergedcy:= fgridprop.flinewidth -
                tfixrow(fgrid.ffixrows.fitems[lastmergedrow]).flinewidth;
    fmergedy:= -fmergedcy;
    if lastmergedcol < int1 then begin
     lastmergedcol:= int1;
    end;
    bo1:= fgridprop.index >= fgrid.ffixrows.count - 
                                          fgrid.ffixrows.foppositecount;
    for int2:= fgridprop.index + 1 to lastmergedrow do begin
     with tfixrow(fgrid.ffixrows.fitems[int2]) do begin
      int4:= step;
      inc(fmergedcy,int4);
      dec(fmergedy,int4);
      if ffixcol then begin
       headers1:= fcaptionsfix;
      end
      else begin
       headers1:= fcaptions;
      end;
     end;
     if headers1.count <= lastmergedcol then begin
      headers1.count:= lastmergedcol + 1;
     end;
     header1:= tcolheader(headers1.fitems[int1]);
     include(header1.fmergeflags,cmf_v);
     header1.frefcell:= cell1;
     if not bo1 then begin
      include(header1.fmergeflags,cmf_rline);
     end;
     for int3:= int1 + 1 to lastmergedcol do begin
      with tcolheader(headers1.fitems[int3]) do begin
       if not bo1 then begin
        fmergeflags:= fmergeflags + [cmf_v,cmf_h,cmf_rline];
       end
       else begin
        fmergeflags:= fmergeflags + [cmf_v,cmf_h];
       end;
       frefcell:= cell1;
      end;
     end;
    end;
    if bo1 then begin
     for int2:= fgridprop.index to lastmergedrow - 1 do begin
      with tfixrow(fgrid.ffixrows.fitems[int2]) do begin
       if ffixcol then begin
        headers1:= fcaptionsfix;
       end
       else begin
        headers1:= fcaptions;
       end;
      end;
      header1:= tcolheader(headers1.fitems[int1]);
      include(header1.fmergeflags,cmf_rline);
      for int3:= int1 + 1 to lastmergedcol do begin
       with tcolheader(headers1.fitems[int3]) do begin
        include(fmergeflags,cmf_rline);
       end;
      end;
     end;
    end;
   end
   else begin
    fmergedcy:= 0;
    fmergedy:= 0;
   end;
  end;
 end;
end;

procedure tcolheaders.dosizechanged;
begin
 inherited;
 fgridprop.fgrid.layoutchanged;
end;

{ tfixcolheaders }

constructor tfixcolheaders.create(const agridprop: tgridprop);
begin
 ffixcol:= true;
 inherited;
end;

class function tfixcolheaders.getitemclasstype: persistentclassty;
begin
 result:= tcolheader;
end;

function tfixcolheaders.getitems(const index: integer): tcolheader;
begin
 result:= tcolheader(inherited getitems(-index-1));
end;

procedure tfixcolheaders.setitems(const index: integer;
  const Value: tcolheader);
begin
 inherited getitems(-index-1).Assign(value);
end;

{ tdatacolheaders }

class function tdatacolheaders.getitemclasstype: persistentclassty;
begin
 result:= tdatacolheader;
end;

function tdatacolheaders.getitems(const index: integer): tdatacolheader;
begin
 result:= tdatacolheader(inherited getitems(index));
end;

procedure tdatacolheaders.setitems(const index: integer;
  const Value: tdatacolheader);
begin
 inherited getitems(index).Assign(value);
end;

{ tfixrow }

constructor tfixrow.create(const agrid: tcustomgrid; 
                                            const aowner: tgridarrayprop);
begin
 ftextinfo.flags:= defaultfixcoltextflags;
 fcaptions:= tdatacolheaders.create(self);
 fcaptions.onchange:= {$ifdef FPC}@{$endif}captionchanged;
 fcaptionsfix:= tfixcolheaders.create(self);
 fcaptionsfix.onchange:= {$ifdef FPC}@{$endif}captionchanged;
// fhints:= tmsestringarrayprop.create;
 inherited create(agrid,aowner);
 fheight:= agrid.fdatarowheight;
end;

destructor tfixrow.destroy;
begin
 inherited;
 fcaptions.free;
 fcaptionsfix.free;
end;

procedure tfixrow.movecol(const curindex,newindex: integer; const aisfix: boolean);
begin
 if aisfix then begin
  fcaptionsfix.movecol(curindex,newindex);
 end
 else begin
  fcaptions.movecol(curindex,newindex);
 end;
end;

procedure tfixrow.datacolscountchanged(const acount: integer);
begin
 fcaptions.colcountchanged(acount);
end;

procedure tfixrow.fixcolscountchanged(const acount: integer);
begin
 fcaptionsfix.colcountchanged(acount);
end;


procedure tfixrow.orderdatacols(const neworder: integerarty);
begin
 fcaptions.reorder(neworder);
end;

procedure tfixrow.synctofontheight;
begin
 if fframe <> nil then begin
  fframe.checkstate;
  height:= {height + }font.glyphheight + fframe.finnerframe.top + 
                                     fframe.finnerframe.bottom;
 end
 else begin
  with tgridarrayprop(prop).finnerframe do begin
   height:= font.glyphheight + top + bottom;
  end;
 end;
end;

function tfixrow.getrowindex: integer;
begin
 fgrid.internalupdatelayout;
 result:= fcellinfo.cell.row;
end;

procedure tfixrow.setheight(const Value: integer);
begin
 if fheight <> value then begin
  if value < 1 then begin
   fheight:= 1;
  end
  else begin
   fheight := Value;
  end;
  fgrid.layoutchanged;
 end;
end;

procedure tfixrow.drawcell(const canvas: tcanvas);
label
 endlab;
var
 int1,linewidthbefore: integer;
 frame1: tcustomframe;
 face1: tcustomface;
 headers1: tcolheaders;
 po1: pointty;
 sizebefore: sizety;
 linemerged: boolean;

begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if cell.col >= 0 then begin
   int1:= cell.col;
   headers1:= fcaptions;
  end
  else begin
   headers1:= fcaptionsfix;
   int1:= -cell.col-1;
  end;
 
  frame1:= fframe;
  face1:= fface;
  po1:= nullpoint;
  sizebefore:= fcellrect.size;
  linemerged:= false;
  if (int1 >= 0) and (int1 < headers1.count) then begin
   with tcolheader(headers1.fitems[int1]) do begin
    linemerged:= cmf_rline in fmergeflags;
    if fmergeflags * [cmf_v,cmf_h] <> [] then begin
     goto endlab;
    end;     
    if fcolor <> cl_parent then begin
     fcellinfo.color:= fcolor;
    end;
    inc(fcellrect.cx,fmergedcx);
    inc(fcellrect.cy,fmergedcy);
    po1.x:= fmergedx;
    po1.y:= fmergedy;
    if fframe <> nil then begin
     frame1:= fframe;
     tframe1(frame1).checkstate;
    end;
    if fface <> nil then begin
     face1:= fface;
    end;
   end;
  end;
  canvas.move(po1);
  updatecellrect(frame1);
  ftextinfo.dest:= fcellinfo.innerrect;
  canvas.save;
  canvas.intersectcliprect(makerect(nullpoint,fcellrect.size));
  drawcellbackground(canvas,frame1,face1);
  if (int1 >= 0) and (int1 < headers1.count) then begin
   tcolheader(headers1.fitems[int1]).drawcell(canvas,ftextinfo.dest);
  end
  else begin
   if (fnumstep <> 0) and (cell.col >= 0) then begin
    ftextinfo.text.text:= inttostr(fnumstart+fnumstep*cell.col);
    drawtext(canvas,ftextinfo);
   end;
  end;
  canvas.restore;
  drawcelloverlay(canvas,frame1);
  canvas.remove(makepoint(0,po1.y));
endlab:
  if (flinewidth > 0) and not linemerged then begin
   linewidthbefore:= canvas.linewidth;
   if flinewidth = 1 then begin
    canvas.linewidth:= 0;
   end
   else begin
    canvas.linewidth:= flinewidth;
   end;
   canvas.drawline(makepoint(fcellrect.x,flinepos),
                     makepoint(fcellrect.x+fcellrect.cx{-1},flinepos),colorline);
   canvas.linewidth:= linewidthbefore;
  end;
  canvas.remove(makepoint(po1.x,0));
  fcellrect.size:= sizebefore;
 end;
end;

procedure tfixrow.paint(const info: rowpaintinfoty);
var
 po1,po2: pointty;

var
 linewidthbefore: integer;
 color1: colorty;
 canbeforedrawcell,canafterdrawcell: boolean;
 
 procedure paintcols(const range: rangety);
 var
  int1,int2,int3: integer;
  bo1,bo2: boolean;
  headers1: tcolheaders;
 begin
  with info do begin
   if fix then begin
    headers1:= fcaptionsfix;
   end
   else begin
    headers1:= fcaptions;
   end;
   int2:= range.startindex;
   if range.startindex < headers1.count then begin
    for int3:= range.startindex downto 0 do begin
     int2:= int3;
     if not (cmf_h in tcolheader(headers1.fitems[int3]).fmergeflags) then begin
      break;
     end;
    end;
   end;
   for int1:= int2 to range.endindex do begin
    with tcol(cols.fitems[int1]) do begin
     bo1:= (colrange.scrollables xor (co_nohscroll in foptions)) and
        (not (co_invisible in foptions) or (csdesigning in fgrid.componentstate));
     if bo1 then begin
      self.fcellrect.cx:= fwidth;
      self.fcellinfo.cell.col:= fcellinfo.cell.col;
      po2.x:= po1.x + fstart + fcellrect.x;
     end;
    end;
    if bo1 then begin
     fcellinfo.color:= color1;
     if fix then begin
      fcellinfo.cell.col:= -int1-1;
     end
     else begin
      fcellinfo.cell.col:= int1;
      if (fcolorselect <> cl_none) and 
                    (gps_selected in fgrid.fdatacols[int1].fstate) then begin
       if fcolorselect <> cl_default then begin
        fcellinfo.color:= fcolorselect;
       end
       else begin
        fcellinfo.color:= defaultselectedcellcolor;
       end;
      end;
     end;
     canvas.origin:= po2;
     bo2:= false;
     if canbeforedrawcell then begin
      fonbeforedrawcell(self,canvas,fcellinfo,bo2);
     end;
     if not bo2 then begin
      drawcell(canvas);
     end;
     if canafterdrawcell then begin
      fonafterdrawcell(self,canvas,fcellinfo);
     end;
    end;
   end;
  end;
 end;

begin
 if not (co_invisible in foptions) or 
                            (csdesigning in fgrid.ComponentState) then begin
  with info do begin
   if ffont = nil then begin
    ftextinfo.font:= fgrid.getfont;
   end
   else begin
    ftextinfo.font:= ffont;
   end;
   canvas.drawinfopo:= @fcellinfo;
   if fcolor <> cl_default then begin
    color1:= fcolor;
   end
   else begin
    color1:= fgrid.actualopaquecolor;
   end;
   po1:= canvas.origin;
   linewidthbefore:= canvas.linewidth;
   if fix then begin
    fcellinfo.colorline:= flinecolorfix;
   end
   else begin
    fcellinfo.colorline:= flinecolor;
   end;
   po2.y:= po1.y+fcellrect.y;
   canbeforedrawcell:= fgrid.canevent(tmethod(fonbeforedrawcell));
   canafterdrawcell:= fgrid.canevent(tmethod(fonafterdrawcell));
   paintcols(colrange.range1);
   paintcols(colrange.range2);
   canvas.origin:= po1;
  end;
 end;
end;

function tfixrow.step(getscrollable: boolean = true): integer;
begin
 if (not (co_invisible in foptions) or 
  (csdesigning in fgrid.ComponentState)) then begin
  result:= fheight+flinewidth;
 end
 else begin
  result:= 0;
 end;
end;

procedure tfixrow.updatelayout;
begin
 fcellrect.size.cy:= fheight;
 if fcellinfo.cell.row <= tgridarrayprop(prop).ffirstopposite then begin
  flinepos:= -((flinewidth+1) div 2);
  fcellrect.y:= flinewidth;
 end
 else begin
  flinepos:= fheight + flinewidth div 2;
  fcellrect.y:= 0;
 end;
 inherited;
end;

procedure tfixrow.updatemergedcells;
begin
 fcaptionsfix.updatelayout(fgrid.ffixcols);
 fcaptions.updatelayout(fgrid.fdatacols);
end;

procedure tfixrow.changed;
begin
 inherited;
 if fgrid.caninvalidate then begin
  fgrid.invalidaterect(fgrid.cellrect(makegridcoord(invalidaxis,getrowindex)));
 end;
end;

procedure tfixrow.setcaptions(const Value: tdatacolheaders);
begin
 fcaptions.assign(Value);
end;

procedure tfixrow.setcaptionsfix(const Value: tfixcolheaders);
begin
 fcaptionsfix.assign(Value);
end;

procedure tfixrow.setnumstart(const Value: integer);
begin
 if fnumstep <> value then begin
  fnumstart := Value;
  changed;
 end;
end;

procedure tfixrow.setnumstep(const Value: integer);
begin
 if fnumstep <> value then begin
  fnumstep := Value;
  changed;
 end;
end;

procedure tfixrow.settextflags(const Value: textflagsty);
var
 int1: integer;
begin
 if ftextinfo.flags <> value then begin
  ftextinfo.flags := Value;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to fcaptions.count - 1 do begin
    fcaptions[int1].textflags:= value;
   end;
  end;
 end;
end;

procedure tfixrow.captionchanged(const sender: tarrayprop; const aindex: integer);
begin
 if aindex < 0 then begin
  changed;
 end
 else begin
  if sender = fcaptionsfix then begin
   cellchanged(aindex-fcaptionsfix.count);
  end
  else begin
   cellchanged(aindex);
  end;
 end;
end;

procedure tfixrow.cellchanged(const col: integer);
begin
 if not (csloading in fgrid.componentstate) then begin
  fgrid.invalidatecell(makegridcoord(col,getrowindex));
 end;
end;

procedure tfixrow.setoptionsfix(const avalue: fixrowoptionsty);
begin
 foptionsfix:= avalue;
 if (fro_invisible in avalue) xor (co_invisible in foptions) then begin
  if fro_invisible in avalue then begin
   foptions:= foptions + [co_invisible];
  end
  else begin
   foptions:= foptions - [co_invisible];
  end;  
  fgrid.layoutchanged;
 end;
end;

function tfixrow.getvisible: boolean;
begin
 result:= not (fro_invisible in options);
end;

procedure tfixrow.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [fro_invisible];
 end
 else begin
  options:= options + [fro_invisible];
 end;
end;

procedure tfixrow.buttoncellevent(var info: celleventinfoty);
begin
 if (info.cell.col >= 0) and (info.cell.col < fcaptions.count) and
          (dco_colsort in fcaptions[info.cell.col].options) and 
          iscellclick(info,[ccr_nokeyreturn]) then begin
  with fgrid.datacols[info.cell.col] do begin
   if (info.mouseeventinfopo^.pos.x > fwidth - 15) and 
       not (co_nosort in foptions) then begin
    if fgrid.datacols.sortcol = info.cell.col then begin
     if co_sortdescent in foptions then begin
      options:= foptions - [co_sortdescent];
     end
     else begin
      options:= foptions + [co_sortdescent];
     end;
    end
    else begin
     fgrid.datacols.sortcol:= info.cell.col;
    end;
    {
    with tdatacolheader(fcaptions.fitems[info.cell.col]) do begin
     if fgrid.canevent(tmethod(fonsortchanged)) then begin
      fonsortchanged(fgrid.datacols[info.cell.col]);
     end;
    end;
    }
   end;
  end;
 end;  
end;

{ tgridarrayprop }

constructor tgridarrayprop.create(aowner: tcustomgrid;
                                                    aclasstype: gridpropclassty);
begin
 ffirstopposite:= -bigint;
 fgrid:= aowner;
 flinewidth:= defaultgridlinewidth;
 flinecolorfix:= defaultfixlinecolor;
 fcolorselect:= cl_default;
 fcoloractive:= cl_none;
 fcolorfocused:= cl_none;
 fcursor:= cr_default;
 finnerframe:= minimalframe;
 inherited create(self,aclasstype);
end;

procedure tgridarrayprop.setcursor(const avalue: cursorshapety);
var
 int1: integer;
begin
 if fcursor <> avalue then begin
  fcursor := avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).cursor:= avalue;
   end;
  end;
 end;
end;

procedure tgridarrayprop.setlinewidth(const Value: integer);
var
 int1: integer;
begin
 if flinewidth <> value then begin
  flinewidth := Value;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).linewidth:= value;
   end;
  end;
 end;
end;

procedure tgridarrayprop.setlinecolor(const Value: colorty);
var
 int1: integer;
begin
 if flinecolor <> value then begin
  flinecolor := Value;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).linecolor:= value;
   end;
  end;
 end;
end;

procedure tgridarrayprop.setlinecolorfix(const Value: colorty);
var
 int1: integer;
begin
 if flinecolorfix <> value then begin
  flinecolorfix := Value;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).linecolorfix:= value;
   end;
  end;
 end;
end;

procedure tgridarrayprop.setcolorselect(const avalue: colorty);
var
 int1: integer;
begin
 if fcolorselect <> avalue then begin
  fcolorselect:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).colorselect:= avalue;
   end;
  end;
 end;
end;

procedure tgridarrayprop.setcoloractive(avalue: colorty);
var
 int1: integer;
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 if fcoloractive <> avalue then begin
  fcoloractive:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).coloractive:= avalue;
   end;
  end;
 end;
end;

procedure tgridarrayprop.setcolorfocused(avalue: colorty);
var
 int1: integer;
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 if fcolorfocused <> avalue then begin
  fcolorfocused:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tgridprop(items[int1]).colorfocused:= avalue;
   end;
  end;
 end;
end;

function tgridarrayprop.fixindex(const index: integer): integer;
begin
 result:= -index-1;
end;

procedure tgridarrayprop.countchanged;
begin
 fgrid.layoutchanged;
end;

procedure tgridarrayprop.dochange(const aindex: integer);
begin
 fgrid.layoutchanged;
 inherited;
end;

procedure tgridarrayprop.createitem(const index: integer; var item: tpersistent);
begin
 item:= gridpropclassty(fitemclasstype).create(fgrid,self);
end;

procedure tgridarrayprop.setcount1(acount: integer; doinit: boolean);
begin
 if acount < foppositecount then begin
  foppositecount:= acount;
 end;
 inherited;
 countchanged;
end;

function tgridarrayprop.geoitems(const aindex: integer): tgridprop;
var
 int1: integer;
begin
 if freversedorder then begin
  int1:= aindex + ffirstopposite + 2;
  if int1 > 0 then begin
   result:= tgridprop(fitems[count-int1]);
  end
  else begin
   result:= tgridprop(fitems[-int1]);
  end;
 end
 else begin
  result:= tgridprop(fitems[aindex]);
 end;
end;

function tgridarrayprop.geotoindex(const ageoindex: integer): integer;
var
 int1: integer;
begin
 if freversedorder then begin
  int1:= count - foppositecount - ageoindex - 1;
  if ageoindex + foppositecount - count >= 0 then begin
   result:= count + int1;
  end
  else begin
   result:= int1;
  end;
 end
 else begin
  result:= ageoindex;
 end;
end;

procedure tgridarrayprop.updatelayout;
var
 int1,int2,int3: integer;
begin
 int2:= 0;
 int3:= getclientsize;
 if freversedorder then begin
  for int1:= count - foppositecount to count - 1 do begin
   with tgridprop(fitems[int1]) do begin
    fend:= int3;
    dec(int3,step);
    inc(int2,step);
    fstart:= int3;
   end;
  end;
  ftotsize:= int2;
  int2:= 0;
  for int1:= count - foppositecount - 1 downto 0 do begin
   with tgridprop(fitems[int1]) do begin
    if not (co_nohscroll in foptions) then begin
     fstart:= int2;
     inc(int2,step);
     fend:= int2;
    end;
   end;
  end;
 end
 else begin
  for int1:= count - 1 downto count - foppositecount do begin
   with tgridprop(fitems[int1]) do begin
    fend:= int3;
    dec(int3,step);
    inc(int2,step);
    fstart:= int3;
   end;
  end;
  ftotsize:= int2;
  int2:= 0;
  for int1:= 0 to count - foppositecount - 1 do begin
   with tgridprop(fitems[int1]) do begin
    if not (co_nohscroll in foptions) then begin
     fstart:= int2;
     inc(int2,step);
     fend:= int2;
    end;
   end;
  end;
 end;
 ffirstsize:= int2;
 ftotsize:= ftotsize + int2;
end;

procedure tgridarrayprop.setoppositecount(const value: integer);
begin
 if value <> foppositecount then begin
  if csloading in fgrid.componentstate then begin
   foppositecount:= value; //count is invalid
  end
  else begin
   if count < value then begin
    foppositecount:= count;
   end
   else begin
    foppositecount := Value;
   end;
   fgrid.layoutchanged;
  end;
 end;
end;

procedure tgridarrayprop.getindexrange(startpos, length: integer;
  out range: cellaxisrangety; ascrollables: boolean = true);

 procedure calcrange(first,last: integer; out range: rangety);
 var
  int1: integer;
 begin                             //todo: optimize
  with range do begin
   endindex:= -1;
   if first > last then begin
    startindex:= 0;
   end
   else begin
    startindex:= -1;
    for int1:= first to last do begin
     with geoitems(int1) do begin
      if ascrollables xor (co_nohscroll in foptions) then begin
       if fstart >= length then begin
        if int1 > first then begin
         endindex:= int1 - 1;
        end;
        break;
       end;
       if (startindex < 0) and (fend > startpos) then begin
        startindex:= int1;
       end;
      end;
     end;
    end;
    if startindex < 0 then begin
     startindex:= 0;
    end
    else begin
     if endindex < 0 then begin
      endindex:= last;
     end;
    end;
    if freversedorder and (endindex >= startindex) then begin
     startindex:= geotoindex(startindex);
     endindex:= geotoindex(endindex);
     if startindex > endindex then begin
      int1:= startindex;
      startindex:= endindex;
      endindex:= int1; 
     end;
    end;
   end;
  end;
 end;

begin
 length:= startpos + length;
 with range do begin
  scrollables:= ascrollables;
//  calcrange(foppositecount,count-1,range1);
//  calcrange(0,foppositecount-1,range2);
  calcrange(count-foppositecount,count-1,range1);
  calcrange(0,count-foppositecount-1,range2);
 end;
end;

function tgridarrayprop.itematpos(const pos: integer;
                   const getscrollable: boolean = true): integer;
var
 int1,int2: integer;
begin
 result:= invalidaxis;
 for int1:= 0 to count - 1 do begin
  with geoitems(int1) do begin
   if (not (co_invisible in foptions) or (csdesigning in fgrid.componentstate)) and
          (getscrollable xor (co_nohscroll in foptions)) then begin
    if (pos >= fstart) and (pos < fend) then begin
     if freversedorder then begin
      int2:= int1 + ffirstopposite + 2;
      if int2 > 0 then begin
       result:= count-int2;
      end
      else begin
       result:= -int2;
      end;
     end
     else begin
      result:= int1;
     end;
     break;
    end;
   end;
  end;
 end;
end;

function tgridarrayprop.scrollablecount: integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to count - 1 do begin
  with tgridprop(items[int1]) do begin
   if (not (co_invisible in foptions) or (csdesigning in fgrid.componentstate)) and
          not(co_nohscroll in foptions) then begin
    inc(result);
   end;
  end;
 end;
end;

procedure tgridarrayprop.fontchanged;
var
 int1: integer;
begin
 for int1:= 0 to count -1 do begin
  tgridprop(items[int1]).fontchanged(fgrid);
 end;
end;

procedure tgridarrayprop.checktemplate(const sender: tobject);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  with tgridprop(fitems[int1]) do begin
   if fframe <> nil then begin
    fframe.checktemplate(sender);
   end;
   if face <> nil then begin
    fface.checktemplate(sender);
   end;
  end;
 end;
end;

procedure tgridarrayprop.setinnerframe(const avalue: framety);
begin
 finnerframe:= avalue;
 fgrid.layoutchanged;
end;

procedure tgridarrayprop.setinnerframe_left(const avalue: integer);
begin
 if finnerframe.left <> avalue then begin
  finnerframe.left:= avalue;
  fgrid.layoutchanged;
 end;
end;

procedure tgridarrayprop.setinnerframe_top(const avalue: integer);
begin
 if finnerframe.top <> avalue then begin
  finnerframe.top:= avalue;
  fgrid.layoutchanged;
 end;
end;

procedure tgridarrayprop.setinnerframe_right(const avalue: integer);
begin
 if finnerframe.right <> avalue then begin
  finnerframe.right:= avalue;
  fgrid.layoutchanged;
 end;
end;

procedure tgridarrayprop.setinnerframe_bottom(const avalue: integer);
begin
 if finnerframe.bottom <> avalue then begin
  finnerframe.bottom:= avalue;
  fgrid.layoutchanged;
 end;
end;

{ tdatacol }

constructor tdatacol.create(const agrid: tcustomgrid; const aowner: tgridarrayprop);
begin
 fwidthmin:= 1;
 fselectedrow:= -1;
 inherited;
 fdata:= createdatalist;
 if fdata <> nil then begin
  fdata.count:= fgrid.rowcount;
  fdata.maxcount:= fgrid.frowcountmax;
  fdata.onitemchange:= {$ifdef FPC}@{$endif}itemchanged;
 end;
end;

destructor tdatacol.destroy;
begin
 if (fdata <> nil) and not (dls_remote in fdata.state) then begin
  fdata.destroy;
 end;
 inherited;
end;

function tdatacol.getcellorigin: pointty;
begin
 fgrid.internalupdatelayout;
 result.x:= fstart + flinewidth + fcellrect.x;
 if not (co_nohscroll in foptions) then begin
  result.x:= result.x + fgrid.fdatarect.x + fgrid.fscrollrect.x;
 end;
 result.y:= fcellrect.y + fgrid.fdatarect.y + fgrid.fscrollrect.y;
end;

function tdatacol.createdatalist: tdatalist;
begin
 result:= nil; //dummy
end;

procedure tdatacol.rowcountchanged(const newcount: integer);
begin
 if fdata <> nil then begin
  fdata.count:= newcount;
 end;
 inherited;
end;

procedure tdatacol.dofocusedcellchanged(enter: boolean;
                  const cellbefore: gridcoordty; var newcell: gridcoordty;
                  const selectaction: focuscellactionty);
var
 info: celleventinfoty;
 bo1: boolean;
begin
 bo1:= (gs_hasactiverowcolor in fgrid.fstate) and (newcell.row <> cellbefore.row);
 if enter then begin
  fgrid.factiverow:= newcell.row;
  if bo1 then begin
   fgrid.invalidaterow(newcell.row);
  end
  else begin
   if (co_drawfocus in foptions) or (fcoloractive <> cl_none) or 
                                       (fcolorfocused <> cl_none) then begin
    invalidatecell(newcell.row);
   end;
  end;
  fgrid.initeventinfo(newcell,cek_enter,info);
 end
 else begin
  if selectaction <> fca_exitgrid then begin
   fgrid.factiverow:= newcell.row;
  end;
  if bo1 then begin
   fgrid.invalidaterow(cellbefore.row);
  end
  else begin
   if (co_drawfocus in foptions) or (fcoloractive <> cl_none) or
                                        (fcolorfocused <> cl_none) then begin
    invalidatecell(cellbefore.row);
   end;
  end;
  fgrid.initeventinfo(cellbefore{newcell},cek_exit,info);
 end;
 info.selectaction:= selectaction;
 info.cellbefore:= cellbefore;
 info.newcell:= newcell;
 fgrid.docellevent(info);
 newcell:= info.newcell;
end;

procedure tdatacol.dokeyevent(var info: keyeventinfoty; up: boolean);
var
 event: celleventkindty;
 cellinfo: celleventinfoty;
begin
 with cellinfo do begin
  if up then begin
   event:= cek_keyup;
  end
  else begin
   event:= cek_keydown;
  end;
  if event <> cek_none then begin
   fgrid.initeventinfo(fgrid.ffocusedcell,event,cellinfo);
   keyeventinfopo:= @info;
   fgrid.docellevent(cellinfo);
  end;
 end;
end;

procedure tdatacol.updatecellzone(const row: integer; const pos: pointty; var result: cellzonety);
begin
 fgrid.internalupdatelayout;
 if pointinrect(pos,fcellinfo.rect) then begin
  result:= cz_default;
 end
 else begin
  result:= cz_none;
 end;
end;

procedure tdatacol.clientmouseevent(const acell: gridcoordty; 
                                              var info: mouseeventinfoty);
var
 cellinfo: celleventinfoty;
 po1: pointty;
begin
 if info.eventkind = ek_clientmouseleave then begin
  fgrid.cellmouseevent(acell,info,nil);
 end
 else begin
  fgrid.cellmouseevent(acell,info,@cellinfo);
  if cellinfo.eventkind <> cek_none then begin
   po1:= fgrid.cellrect(cellinfo.cell).pos;
   try
    subpoint1(info.pos,po1);
    updatecellzone(acell.row,info.pos,cellinfo.zone);
    fgrid.flastcellzone:= cellinfo.zone;
    fgrid.docellevent(cellinfo);
   finally
    addpoint1(info.pos,po1);
   end;
  end;
 end;
end;

function tdatacol.getselected(const row: integer): boolean;
begin
 if ident <= selectedcolmax then begin
  if row >= 0 then begin
   result:= (gps_selected in fstate) or
    (fgrid.fdatacols.frowstate.getitempo(row)^.selected and
     (bits[ident] or wholerowselectedmask) <> 0);
  end
  else begin
   result:= gps_selected in fstate;
  end;
 end
 else begin
  result:= inherited getselected(row);
 end;
end;

procedure tdatacol.setselected(const row: integer; value: boolean);
var
 po1: prowstatety;
 ca1: longword;
 int1: integer;
begin
 if ident <= selectedcolmax then begin
  if row >= 0 then begin
   with fgrid.fdatacols.frowstate.getitempo(row)^ do begin
    ca1:= selected;
    if value then begin
     selected:= selected or bits[ident];
    end
    else begin
     selected:= selected and not (bits[ident] {or wholerowselectedmask});
    end;
    if ca1 <> selected then begin
     if value then begin
      if fselectedrow = -1 then begin
       fselectedrow:= row;
      end
      else begin
       fselectedrow:= -2;
      end;
     end
     else begin
      if fselectedrow = row then begin
       fselectedrow:= -1;
      end;
     end;
     invalidatecell(row);
//     cellchanged(row);
     doselectionchanged;
    end;
   end;
  end
  else begin //row < 0
   if value then begin
    if not (gps_selected in fstate) then begin
     include(fstate,gps_selected);
     fselectedrow:= -2;
     changed;
     doselectionchanged;
    end;
   end
   else begin
    exclude(fstate,gps_selected);
    if fselectedrow <> -1 then begin
     po1:= fgrid.fdatacols.frowstate.datapo;
     ca1:= not (bits[ident] {or wholerowselectedmask});
     if fselectedrow >= 0 then begin
      with prowstatety(pchar(po1)+
             fselectedrow*fgrid.fdatacols.frowstate.fsize)^ do begin
       selected:= selected and ca1;
      end;
      invalidatecell(fselectedrow);
//      cellchanged(fselectedrow);
     end
     else begin
      for int1:= 0 to fgrid.frowcount - 1 do begin
       po1^.selected:= po1^.selected and ca1;
       inc(po1);
      end;
      changed;
     end;
     fselectedrow:= -1;
     doselectionchanged;
    end;
   end;
  end;
 end;
end;

function tdatacol.getmerged(const row: integer): boolean;
begin
 if index = 0 then begin
  result:= false;
 end
 else begin
  if index > mergedcolmax then begin
   result:= fgrid.fdatacols.frowstate.getitempocolmerge(row)^.colmerge.merged = mergedcolall;
  end
  else begin
   result:= fgrid.fdatacols.frowstate.getitempocolmerge(row)^.colmerge.merged and 
                                                          bits[index-1] <> 0;
  end;
 end;
end;

procedure tdatacol.setmerged(const row: integer; const avalue: boolean);
begin
 if (index > 0) and (index <= mergedcolmax) then begin
  if updatebit(fgrid.fdatacols.frowstate.getitempocolmerge(row)^.colmerge.merged,
                              index-1,avalue) then begin
   fgrid.fdatacols.mergechanged(row);
  end;
 end;
end;

function tdatacol.getselectedcells: integerarty;
const
 capacitystep = 64;
var
 int1,int3: integer;
begin
 result:= nil;
 with tdatacols(prop) do begin
  if hasselection then begin          //todo: optimize
   int3:= 0;
   for int1:= 0 to frowstate.count - 1 do begin
    if frowstate.getitempo(int1)^.selected <> 0 then begin
     if self.selected[int1] then begin
      if int3 >= length(result) then begin
       setlength(result,length(result)*2 + capacitystep);
      end;
      result[int3]:= int1;
      inc(int3);
     end;
    end;
   end;
   setlength(result,int3);
  end;
 end;
end;

procedure tdatacol.setselectedcells(const avalue: integerarty);
              //todo: optimize
var
 int1: integer;
begin
 grid.beginupdate;
 try
  beginselect;
  clearselection;
  for int1:= 0 to high(avalue) do begin
   setselected(avalue[int1],true);
  end;
  endselect;
 finally
  grid.endupdate;
 end;
end;

procedure tdatacol.doselectionchanged;
begin
 if (fselectlock = 0) then begin
  if assigned(fonselectionchanged) then begin
   inc(fselectlock); //avoid recursion
   try
    fonselectionchanged(self);
   finally
    dec(fselectlock);
   end;
  end;
 end
 else begin
  include(fstate,gps_selectionchanged);
 end;
 fgrid.internalselectionchanged;
end;

procedure tdatacol.beginselect;
begin
 inc(fselectlock);
end;

procedure tdatacol.endselect;
begin
 dec(fselectlock);
 if fselectlock = 0 then begin
  if gps_selectionchanged in fstate then begin
   exclude(fstate,gps_selectionchanged);
   doselectionchanged;
  end;
 end;
end;

function tdatacol.selectedcellcount: integer;
var
 int1,int2: integer;
begin
 result:= 0;
 if fselectedrow <> -1 then begin
  for int1:= 0 to fgrid.rowhigh do begin
   if selected[int1] then begin
    inc(result);
   end;
  end;
 end;
end;

procedure tdatacol.clearselection;
begin
 setselected(-1,false);
end;

procedure tdatacol.internaldoentercell(const cellbefore: gridcoordty;
                var newcell: gridcoordty; const action: focuscellactionty);
begin
 if not (gs_cellentered in fgrid.fstate) or (action = fca_entergrid) then begin
  include(fgrid.fstate,gs_cellentered);
  dofocusedcellchanged(true,cellbefore,newcell,action);
 end;
end;

procedure tdatacol.internaldoexitcell(const cellbefore: gridcoordty;
                var newcell: gridcoordty; const selectaction: focuscellactionty);
begin
 if gs_cellentered in fgrid.fstate then begin
  exclude(fgrid.fstate,gs_cellentered);
  dofocusedcellchanged(false,cellbefore,newcell,selectaction);
 end
 else begin
  if ((co1_rowcoloractive in foptions1) or (co1_rowcolorfocused in foptions1) or
      (ffontactivenum >= 0) or (ffontfocusednum >= 0)) and 
                                        (cellbefore.row >= 0) then begin
   invalidatecell(cellbefore.row);
  end;
 end;
end;

procedure tdatacol.checkdirtyautorowheight(aindex: integer);
begin
 if gps_needsrowheight in fstate then begin
  tdatacols(prop).rowstate.checkdirtyautorowheight(aindex);
 end;
end;

procedure tdatacol.afterrowcountupdate;
begin
 //dummy
end;

procedure tdatacol.itemchanged(const sender: tdatalist; const aindex: integer);
var
 coord1: gridcoordty;
begin
 if (aindex < 0) and (sender.count <> fgrid.frowcount) then begin
  if fgrid.fupdating = 0 then begin
   fgrid.rowcount:= sender.count;
   afterrowcountupdate;
  end
  else begin
   include(fgrid.fstate,gs_rowcountinvalid)
  end;
 end;
 if not (gps_noinvalidate in fstate) and 
                     not (csloading in fgrid.componentstate) then begin
  checkdirtyautorowheight(aindex);
  if aindex < 0 then begin
   cellchanged(invalidaxis);
  end
  else begin
   cellchanged(aindex);
  end;
  if (co_rowdatachange in foptions) and (fgrid.frowdatachanging = 0) then begin
                                           //no recursion
   coord1.col:= index;
   if aindex < 0 then begin
    coord1.row:= 0;
    fgrid.rowdatachanged(coord1,fgrid.frowcount);
   end
   else begin
    coord1.row:= aindex;
    fgrid.rowdatachanged(coord1);
   end;
  end;
 end;
 if not (co_nosort in foptions) then begin
  fgrid.sortinvalid;
 end;
 if not (gps_changelock in fstate) and 
                                fgrid.canevent(tmethod(fonchange)) then begin
  fonchange(self,aindex);
 end;
end;

procedure tdatacol.doactivate;
begin
 if (co_drawfocus in foptions) and (fgrid.row >= 0) then begin
  invalidatecell(fgrid.row);
 end;
end;

procedure tdatacol.dodeactivate;
begin
 if (co_drawfocus in foptions) and (fgrid.row >= 0) then begin
  invalidatecell(fgrid.row);
 end;
end;

procedure tdatacol.setwidthmax(const Value: integer);
begin
 if fwidthmax <> value then begin
  if value < 0 then begin
   fwidthmax:= 0;
  end
  else begin
   fwidthmax:= Value;
  end;
  fgrid.layoutchanged;
 end;
end;

procedure tdatacol.setwidthmin(const Value: integer);
begin
 if fwidthmin <> value then begin
  if value < 0 then begin
   fwidthmin:= 0;
  end
  else begin
   fwidthmin:= Value;
  end;
  fgrid.layoutchanged;
 end;
end;

procedure tdatacol.updatelayout;
begin
 if fpropwidth = 0 then begin
  updatepropwidth;
 end;
 if (co_proportional in foptions) and (fpropwidth <> 0) then begin
  fwidth:= round(fgrid.fpropcolwidthref * fpropwidth);
//  fwidth:= round(tgridframe(fgrid.fframe).fpaintrect.cx * fpropwidth);
 end;
 if (fwidthmax <> 0) and (fwidth > fwidthmax) then begin
  fwidth:= fwidthmax;
 end;
 if (fwidthmin <> 0) and (fwidth < fwidthmin) then begin
  fwidth:= fwidthmin;
 end;
 inherited;
end;

procedure tdatacol.moverow(const fromindex, toindex: integer;
                  const count: integer);
begin
 if (fdata <> nil) and not (co_norearange in foptions) then begin
  fdata.blockmovedata(fromindex,toindex,count);
 end;
end;

procedure tdatacol.insertrow(const aindex: integer; const count: integer);
begin
 if fdata <> nil then begin
  fdata.insertitems(aindex,count);
 end;
end;

procedure tdatacol.deleterow(const aindex: integer; const count: integer);
begin
 if fdata <> nil then begin
  fdata.deleteitems(aindex,count);
 end;
end;

procedure tdatacol.setoptions(const Value: coloptionsty);
const
 mask: coloptionsty = [co_fill,co_proportional];
var
 optionsbefore: coloptionsty;
 optionsplusdelta: coloptionsty;
begin
 optionsbefore:= foptions;
 inherited setoptions(coloptionsty(setsinglebit(
         {$ifdef FPC}longword{$else}longword{$endif}(value),
         {$ifdef FPC}longword{$else}longword{$endif}(foptions),
         {$ifdef FPC}longword{$else}longword{$endif}(mask))));
 if coloptionsty(longword(optionsbefore) xor longword(foptions)) * 
          [co_nosort,co_sortdescent] <> [] then begin
  fgrid.sortinvalid;
  fgrid.checksort;
 end;
 optionsplusdelta:= coloptionsty((longword(optionsbefore) xor longword(foptions)) and 
                                                    longword(value));
 if (co_focusselect in optionsplusdelta) and
   (fgrid.ffocusedcell.col = findex) and (fgrid.ffocusedcell.row >= 0) then begin
    fgrid.selectcell(makegridcoord(findex,fgrid.ffocusedcell.row),csm_select);
 end;
 if (co_disabled in optionsplusdelta) and 
                              (fgrid.ffocusedcell.col = colindex) then begin
  fgrid.colstep(fca_focusin,1,false,false);
 end;
end;

function tdatacol.canfocus(const abutton: mousebuttonty;
                                     const ashiftstate: shiftstatesty;
                                     out canrowfocus: boolean): boolean;
begin
 canrowfocus:= ((abutton = mb_left) or (abutton = mb_none) or
                     not (co_leftbuttonfocusonly in foptions)) and
               ((ashiftstate*[ss_ctrl] = []) or 
                            not (co_noctrlmousefocus in foptions));
 result:= (foptions * [co_invisible,co_disabled,co_nofocus] = []) and
                           canrowfocus;
end;

procedure tdatacol.rearange(const list: tintegerdatalist);
begin
 if not (co_norearange in foptions) and (fdata <> nil) then begin
  fdata.rearange(list);
  fdata.change(-1);
 end;
end;

procedure tdatacol.sortcompare(const index1, index2: integer;
  var result: integer);
begin
 if fdata <> nil then begin
  with tdatalist1(fdata) do begin
   tdatalist1(fdata).compare((fdatapo+index1*fsize)^,
                                (fdatapo+index2*fsize)^,result);
  end;
 end;
end;

function tdatacol.isempty(const aindex: integer): boolean;
begin
 if fdata <> nil then begin
  result:= (aindex >= fdata.count) or fdata.empty(aindex);
 end
 else begin
  result:= true;
 end;
end;

procedure tdatacol.docellevent(var info: celleventinfoty);
var
 hintinfo: hintinfoty;
begin
 if fgrid.canevent(tmethod(foncellevent)) then begin
  foncellevent(self,info);
 end;
 if (info.eventkind = cek_firstmousepark) and
         fgrid.canevent(tmethod(fonshowhint)) and application.active then begin
  application.inithintinfo(hintinfo,fgrid);
  fonshowhint(self,info.cell.row,hintinfo);
  application.showhint(fgrid,hintinfo);
 end;
end;

function tdatacol.getcursor(const arow: integer;
                          const actcellzone: cellzonety): cursorshapety;
begin
 result:= cursor;
// result:= cr_arrow;
end;

function tdatacol.getdatastatname: msestring;
begin
 if fname <> '' then begin
  result:= fname;
 end
 else begin
  result:= gridvaluevarname + inttostr(ident);
 end;
end;

procedure tdatacol.coloptionstoeditoptions(var dest: optionseditty);
begin
 updatebit(longword(dest),ord(oe_readonly),isreadonly);
 updatebit(longword(dest),ord(oe_savevalue),co_savevalue in foptions);
end;

procedure tdatacol.dostatread(const reader: tstatreader);
var
 bo1: boolean;
 mstr1: msestring;
begin
 if (fdata <> nil) and not (dls_remote in fdata.state) and
                                (co_savevalue in foptions) and 
                                 not (gs_isdb in fgrid.fstate) then begin
  reader.readdatalist(getdatastatname,fdata);
 end;
 if co_savestate in foptions then begin
  mstr1:= inttostr(ident);
  if not (co_fixwidth in foptions) and 
                   (og_colsizing in fgrid.optionsgrid) then begin
   width:= reader.readinteger('width'+mstr1,fwidth,0);
  end;
  bo1:= reader.readboolean('sortdescent'+mstr1,co_sortdescent in foptions);
  if bo1 then begin
   options:= options + [co_sortdescent];
  end
  else begin
   options:= options - [co_sortdescent];
  end;
 end;
end;

procedure tdatacol.dostatwrite(const writer: tstatwriter);
var
 mstr1: msestring;
begin
 inherited;
 if (fdata <> nil) and not (dls_remote in fdata.state) and
                         (co_savevalue in foptions) and 
                         not (gs_isdb in fgrid.fstate) then begin
  writer.writedatalist(getdatastatname,fdata);
 end;
 if co_savestate in foptions then begin
  mstr1:= inttostr(ident);
  if not (co_fixwidth in foptions) and 
                   (og_colsizing in fgrid.optionsgrid) then begin
   writer.writeinteger('width'+mstr1,fwidth);
  end;
  writer.writeboolean('sortdescent'+mstr1,co_sortdescent in foptions);
 end;
end;
{
procedure tdatacol.cellchanged(const row: integer);
var
 coord1: gridcoordty;
begin
 inherited;
 if (co_rowdatachange in foptions) and (fgrid.frowdatachanging = 0) then begin
                                          //no recursion
  coord1.col:= index;
  if row < 0 then begin
   coord1.row:= 0;
   fgrid.rowdatachanged(coord1,fgrid.frowcount);
  end
  else begin
   coord1.row:= row;
   fgrid.rowdatachanged(coord1);
  end;
 end;
end;
}
function tdatacol.getvisible: boolean;
begin
 result:= not (co_invisible in foptions);
end;

procedure tdatacol.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [co_invisible];
 end
 else begin
  options:= options + [co_invisible];
 end;
end;

function tdatacol.getenabled: boolean;
begin
 result:= not (co_disabled in foptions);
end;

procedure tdatacol.setenabled(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [co_disabled];
 end
 else begin
  options:= options + [co_disabled];
 end;
end;

function tdatacol.getreadonly: boolean;
begin
 result:= co_readonly in foptions;
end;

procedure tdatacol.setreadonly(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [co_readonly];
 end
 else begin
  options:= options - [co_readonly];
 end;
end;

function tdatacol.getdatapo(const arow: integer): pointer;
begin
 if (fdata <> nil) then begin
  result:= fdata.getitempo(arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdatacol.getrowdatapo: pointer;
begin
 result:= nil;
 if fgrid.row >= 0 then begin
  result:= getdatapo(fgrid.row);
 end;
end;

{
function tdatacol.ismerged: boolean;
begin
 with fcellinfo.rowstate^ do begin
  result:= merged <> 0;
  if result then begin
   result:= (index <> 0) and  
    ((merged = mergedcolall) or (index < mergedcolmax) and
    (merged and bits[index] <> 0));
  end;
 end;
end;
}
procedure tdatacol.beforedragevent(var ainfo: draginfoty; const arow: integer;
                                           var processed: boolean);
begin
 //dummy
end;

procedure tdatacol.afterdragevent(var ainfo: draginfoty; const arow: integer;
                                           var processed: boolean);
begin
 //dummy
end;

function tdatacol.isreadonly: boolean;
begin
 result:= (gs_rowreadonly in fgrid.fstate) or (co_readonly in foptions);
end;

procedure tdatacol.clean(const start,stop: integer);
begin
 if fdata <> nil then begin
  fdata.clean(start,stop);
 end;
end;

procedure tdatacol.setdata(const avalue: tdatalist);
begin
 fdata.assign(avalue);
end;

{ tdrawcol }

procedure tdrawcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 if fgrid.canevent(tmethod(fondrawcell)) then begin
  fondrawcell(self,canvas,cellinfoty(canvas.drawinfopo^));
 end;
end;

{ tstringcoldatalist }

constructor tstringcoldatalist.create(const agrid: tcustomgrid);
begin
 fgrid:= agrid;
 inherited create;
end;

function tstringcoldatalist.add(const avalue: msestring;
               const anoparagraph: boolean): integer;
begin
 result:= inherited add(avalue,anoparagraph);
 if anoparagraph then begin
  additem(fnoparagraph,result);
 end;
end;

procedure tstringcoldatalist.afterrowcountupdate;
var
 int1: integer;
begin
 with fgrid.fdatacols.frowstate do begin
  for int1:= 0 to high(fnoparagraph) do begin
   if fnoparagraph[int1] < count then begin
    flag1[fnoparagraph[int1]]:= true;
   end;
  end;
 end;
 fnoparagraph:= nil;
end;

function tstringcoldatalist.getparagraph(const index: integer;
               const aseparator: msestring = ''): msestring;
var
 int1: integer;
 start,stop: integer;
begin
 start:= index;
 with fgrid.fdatacols.frowstate do begin
  while start >= 0 do begin
   if not flag1[start] then begin
    break;
   end;
   dec(start);
  end;
  result:= self.items[start];
  for int1:= start+1 to count-1 do begin
   if not flag1[int1] then begin
    break;
   end;
   result:= result + aseparator + self.items[int1]; 
  end;
 end;
end;

function tstringcoldatalist.getnoparagraphs(index: integer): boolean;
begin
 result:= fgrid.fdatacols.frowstate.flag1[index];
end;

{ tcustomstringcol }

constructor tcustomstringcol.create(const agrid: tcustomgrid; 
                       const aowner: tgridarrayprop);
begin
 foptionsedit:= tstringcols(aowner).foptionsedit;
 foptionsedit1:= tstringcols(aowner).foptionsedit1;
 ftextinfo.flags:= tstringcols(aowner).ftextflags;
 ftextflagsactive:= tstringcols(aowner).ftextflagsactive;
 inherited;
end;

destructor tcustomstringcol.destroy;
begin
 inherited;
end;

procedure tcustomstringcol.settextflags(const avalue: textflagsty);	
begin
 if ftextinfo.flags <> avalue then begin
  ftextinfo.flags:= checktextflags(ftextinfo.flags,avalue);
  changed;
 end;
end;

procedure tcustomstringcol.settextflagsactive(const avalue: textflagsty);
begin
 if ftextflagsactive <> avalue then begin
  ftextflagsactive:= checktextflags(ftextflagsactive,avalue);
 end;
 changed;
end;

function tcustomstringcol.createdatalist: tdatalist;
begin
 result:= tstringcoldatalist.create(fgrid);
end;

function tcustomstringcol.getinnerframe: framety;
begin
 result:= inherited getinnerframe;
{
 result.left:= tcustomstringgrid(fgrid).feditor.getinsertcaretwidth(
                 fgrid.getcanvas,fgrid.getfont);
 result.top:= 0;
 result.right:= result.left;
 result.bottom:= 0;
}
end;

function tcustomstringcol.getcursor(const arow: integer;
                        const actcellzone: cellzonety): cursorshapety;
begin
 result:= inherited getcursor(arow,actcellzone);
 if result = cr_default then begin
  if not isreadonly{(co_readonly in foptions)} then begin
   result:= cr_ibeam;
  end;
 end;
end;

procedure tcustomstringcol.modified;
begin
 include(fstate,gps_edited);
 //dummy
end;

procedure tcustomstringcol.updatelayout;
begin
 inherited;
 ftextinfo.clip.pos:= nullpoint;
 ftextinfo.clip.size:= fcellinfo.rect.size;
 ftextinfo.dest:= fcellinfo.innerrect;
end;

function tcustomstringcol.getrowtext(const arow: integer): msestring;
begin
 result:= items[arow];
end;

procedure tcustomstringcol.updatedisptext(var avalue: msestring);
begin
 if scoe_trimleft in foptionsedit then begin
  avalue:= trimleft(avalue);
 end;
 if scoe_trimright in foptionsedit then begin
  avalue:= trimright(avalue);
 end;
 if scoe_uppercase in foptionsedit then begin
  avalue:= mseuppercase(avalue);
 end
 else begin
  if scoe_lowercase in foptionsedit then begin
   avalue:= mselowercase(avalue);
  end;
 end;
end;

procedure tcustomstringcol.drawcell(const canvas: tcanvas);
var
 int1: integer;
begin
 inherited;
 ftextinfo.font:= canvas.font;
 ftextinfo.text.format:= nil;
 with cellinfoty(canvas.drawinfopo^) do begin
  if cell.row < fgrid.rowcount then begin
   ftextinfo.dest.cx:= innerrect.cx;
   ftextinfo.dest.cy:= innerrect.cy;
   ftextinfo.clip.cx:= rect.cx;
   ftextinfo.clip.cy:= rect.cy;
   ftextinfo.text.text:= getrowtext(cell.row);
   updatedisptext(ftextinfo.text.text);
   if calcautocellsize then begin
    textrect(canvas,ftextinfo);
    int1:= rect.cx - innerrect.cx + ftextinfo.res.cx;
    if int1 > autocellsize.cx then begin
     autocellsize.cx:= int1;
    end;
    int1:= rect.cy - innerrect.cy + ftextinfo.res.cy;
    if int1 > autocellsize.cy then begin
     autocellsize.cy:= int1;
    end;
   end
   else begin
    drawtext(canvas,ftextinfo);
   end;
  end;
 end;
end;

function tcustomstringcol.getitems(aindex: integer): msestring;
begin
 result:= tmsestringdatalist(fdata)[aindex];
end;

procedure tcustomstringcol.setitems(aindex: integer; const Value: msestring);
begin
 tmsestringdatalist(fdata)[aindex]:= value;
 cellchanged(aindex); //??? already called?
end;

function tcustomstringcol.getdatalist: tstringcoldatalist;
begin
 result:= tstringcoldatalist(fdata);
end;

procedure tcustomstringcol.setdatalist(const value: tstringcoldatalist);
begin
 fdata.Assign(value);
end;

procedure tcustomstringcol.readpipe(const pipe: tpipereader;
                            const processeditchars: boolean = false;
                            const maxchars: integer = 0);
var
 mstr1: msestring;
begin
 try
  mstr1:= pipe.readdatastring;
 except
 end;
 datalist.addchars(mstr1,processeditchars,maxchars);
end;

procedure tcustomstringcol.readpipe(const text: string;
              const processeditchars: boolean = false;
              const maxchars: integer = 0);
var
 mstr1: msestring;
begin
 mstr1:= text;
 datalist.addchars(mstr1,processeditchars,maxchars);
end;

procedure tcustomstringcol.setisdb;
begin
 //dummy
end;

function tcustomstringcol.getoptionsedit: optionseditty;
begin
 result:= [];
 stringcoltooptionsedit(foptionsedit,result);
end;

procedure tcustomstringcol.docellevent(var info: celleventinfoty);
var
 hintinfo: hintinfoty;
begin
 if (scoe_hintclippedtext in foptionsedit) and 
        (info.eventkind = cek_firstmousepark) and application.active and 
         fgrid.getshowhint and
         tcustomstringgrid(fgrid).textclipped(info.cell) then begin
  application.inithintinfo(hintinfo,fgrid);
  hintinfo.caption:= self[info.cell.row];
  application.showhint(fgrid,hintinfo);
 end;
 inherited;
end;

procedure tcustomstringcol.afterrowcountupdate;
var
 int1: integer;
begin
 inherited;
 if fdata <> nil then begin
  tstringcoldatalist(fdata).afterrowcountupdate;
 end;
end;

function tcustomstringcol.edited: boolean;
begin
 result:= gps_edited in fstate;
end;

{ tfixcol }

constructor tfixcol.create(const agrid: tcustomgrid; 
                               const aowner: tgridarrayprop);
begin
 foptionsfix:= defaultfixcoloptions;
 ftextinfo.flags:= defaultfixcoltextflags;
 fcaptions:= tmsestringdatalist.create;
 fcaptions.onitemchange:= {$ifdef FPC}@{$endif}captionchanged;
 inherited;
 include(fstate,gps_fix);
 fcolor:= cl_parent;
end;

destructor tfixcol.destroy;
begin
 inherited;
 fcaptions.Free;
end;

procedure tfixcol.setoptionsfix(const avalue: fixcoloptionsty);
var
 opt1: coloptions1ty;
begin
 foptionsfix:= avalue;
 opt1:= coloptions1ty(
           {$ifndef FPC}byte({$endif}
               replacebits(
                 longword(
                 {$ifndef FPC}byte({$endif}avalue{$ifndef FPC}){$endif})
                            shr longword(fixcoloptionsshift1),
                     longword(foptions),
                     longword(
                      {$ifndef FPC}byte({$endif}
                       fixcoloptionsmask
                      {$ifndef FPC}){$endif}
                      )
                     )
           {$ifndef FPC}){$endif}
                      );
 inherited options1:= opt1;
 if fco_invisible in avalue then begin
  inherited options:= inherited options + [co_invisible];
 end
 else begin
  inherited options:= inherited options - [co_invisible];
 end;
 {
 if fco_active in avalue then begin
  options1:= options1 + [co1_active];
 end
 else begin
  options1:= options1 - [co1_active];
 end;
 }
end;

procedure tfixcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 with cellinfoty(canvas.drawinfopo^) do begin
  if not notext then begin
   ftextinfo.dest:= innerrect;
   if cell.row < fcaptions.count then begin
    ftextinfo.text.text:= fcaptions[cell.row];
    drawtext(canvas,ftextinfo);
   end
   else begin
    if fnumstep <> 0 then begin
     ftextinfo.text.text:= inttostr(fgrid.fnumoffset+fnumstart+fnumstep*cell.row);
     drawtext(canvas,ftextinfo);
    end;
   end;
  end;
 end;
end;

procedure tfixcol.moverow(const fromindex, toindex: integer;
  const count: integer = 1);
begin

end;

procedure tfixcol.insertrow(const aindex: integer; const count: integer = 1);
begin
 //dummy
end;

procedure tfixcol.deleterow(const aindex: integer; const count: integer = 1);
begin
 //dummy
end;

procedure tfixcol.setoptions(const Value: coloptionsty);
begin
 inherited setoptions(value - notfixcoloptions);
end;

procedure tfixcol.settextflags(const Value: textflagsty);
begin
 if ftextinfo.flags <> value then begin
  ftextinfo.flags := checktextflags(ftextinfo.flags,Value);
  changed;
 end;
end;

procedure tfixcol.setnumstart(const Value: integer);
begin
 if fnumstart <> value then begin
  fnumstart:= Value;
  changed;
 end;
end;

procedure tfixcol.setnumstep(const Value: integer);
begin
 if fnumstep <> value then begin
  fnumstep := Value;
  changed;
 end;
end;

{
procedure tfixcol.updatelayout;
begin
 inherited;
 ftextinfo.dest:= fcellinfo.innerrect;
end;
}

procedure tfixcol.paint(var info: colpaintinfoty);
begin
 if ffont = nil then begin
  ftextinfo.font:= fgrid.getfont;
 end
 else begin
  ftextinfo.font:= ffont;
 end;
 inherited;
end;

procedure tfixcol.setcaptions(const Value: tmsestringdatalist);
begin
 fcaptions.assign(Value);
end;

function tfixcol.getcaptions: tmsestringdatalist;
begin
 result:= fcaptions;
end;

function tfixcol.iscaptionsstored: Boolean;
begin
 result:= fcaptions.count > 0;
end;

procedure tfixcol.captionchanged(const sender: tdatalist; const aindex: integer);
begin
 if aindex < 0 then begin
  changed;
 end
 else begin
  cellchanged(aindex);
 end;
end;

procedure tfixcol.rearange(const list: tintegerdatalist);
begin
 if not (co_norearange in foptions) and (fnumstep = 0) and
       (fcaptions.count = list.count) then begin
  fcaptions.rearange(list);
 end;
end;

function tfixcol.getvisible: boolean;
begin
 result:= not (fco_invisible in options);
end;

procedure tfixcol.setvisible(const avalue: boolean);
begin
 if avalue then begin
  options:= options - [fco_invisible];
 end
 else begin
  options:= options + [fco_invisible];
 end;
end;

{ tcolsfont }

class function tcolsfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcols(owner).ffontselect;
end;

{ tcols }

constructor tcols.create(aowner: tcustomgrid; aclasstype: gridpropclassty);
begin
 fwidth:= griddefaultcolwidth;
 ffontactivenum:= -1;
 ffontfocusednum:= -1;
 inherited;
end;

destructor tcols.destroy;
begin
 inherited;
 ffontselect.free; 
end;

function tcols.mergedwidth(const acol: integer; const amerged: longword): integer;
var
 int1: integer;
begin
 result:= 0;
 if (amerged <> 0) and (acol < mergedcolmax) then begin
  if (acol = 0) or (amerged and bits[acol-1] = 0) then begin
   if amerged = mergedcolall then begin
    for int1:= 1 to count -1 do begin
     with tcol(fitems[int1]) do begin
      if not (co_invisible in foptions) then begin
       result:= result + step;
      end;
     end;
    end;
   end
   else begin
    for int1:= acol to count -1 do begin
     if amerged and bits[int1] <> 0 then begin
      with tcol(fitems[int1]) do begin
       if not (co_invisible in foptions) then begin
        result:= result + step;
       end;
      end;
     end
     else begin
      break;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcols.paint(var info: colpaintinfoty; const scrollables: boolean = true);
var
 startx,endx: integer;
 pt1,pt2: pointty;
 int1,int2,int3,int4: integer;
 ar1: integerarty;
 po1: prowstatety;
begin
 with info do begin
  pt1:= canvas.origin;
  with canvas.clipbox do begin
   startx:= x {+ po1.x};
   endx:= startx + cx;
  end;
  pt2:= pt1;
  setlength(ar1,count);
  if (og_colmerged in fgrid.foptionsgrid) and (self is tdatacols) then begin
   for int1:= 0 to high(ar1) do begin
    with tcol(fitems[int1]) do begin
     int4:= 0;
     if int1 < mergedcolmax then begin
      for int2:= 0 to high(info.rows) do begin
       int3:= mergedwidth(int1,tdatacols(self).frowstate.merged[int2]);
       if int3 > int4 then begin
        int4:= int3;
       end;
      end;
     end;
     ar1[int1]:= fend + int4;
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    ar1[int1]:= tcol(fitems[int1]).fend;
   end;
  end;
  for int1:= 0 to count-1 do begin
   with tcol(fitems[int1]) do begin
    if (scrollables xor (co_nohscroll in foptions)) and 
     not ((startx < fstart) and (endx <= fstart) or 
          (startx >= ar1[int1]) and (endx > ar1[int1])) then begin
     pt2.x:= fstart + pt1.x;
     canvas.origin:= pt2;
     paint(info);
    end;
   end;
  end;
  canvas.origin:= pt1;
 end;
end;

procedure tcols.updaterowheight(const arow: integer; var arowheight: integer);
var
 info: colpaintinfoty;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  calcautocellsize:= true;
  autocellsize.cx:= 0;
  autocellsize.cy:= arowheight;
  canvas:= fgrid.getcanvas;  
  setlength(rows,1);
  rows[0]:= arow; //startrow = endrow = 0
  paint(info,true);
  paint(info,false);
  arowheight:= autocellsize.cy;
 end;
end;

procedure tcols.updatelayout;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  tcol(fitems[int1]).updatelayout;
 end;
 inherited;
end;

procedure tcols.rowcountchanged(const newcount: integer);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  tcol(items[int1]).rowcountchanged(newcount);
 end;
end;

function tcols.totwidth: integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to count-1 do begin
  inc(result,tcol(items[int1]).step);
 end;
end;

function tcols.getclientsize: integer;
begin
 result:= tgridframe(fgrid.fframe).finnerclientrect.cx;
end;

function tcols.getcols(const index: integer): tcol;
begin
 result:= tcol(items[index]);
end;

procedure tcols.setwidth(const Value: integer);
var
 int1: integer;
begin
 if fwidth <> value then begin
  fwidth:= value;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tcol(items[int1]).width:= value;
   end;
  end;
 end;
end;

procedure tcols.setoptions(const Value: coloptionsty);
var
 int1: integer;
 mask: longword;
begin
 if foptions <> value then begin
  mask:= longword(value - deprecatedcoloptions) xor longword(foptions);
  foptions:= Value - deprecatedcoloptions;
  if csreading in fgrid.componentstate then begin
   transferdeprecatedcoloptions(value,foptions1);
  end;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tcol(items[int1]).options:= coloptionsty(replacebits(longword(foptions),
                   longword(tcol(items[int1]).options),mask));
   end;
  end;
 end;
end;

procedure tcols.setoptions1(const value: coloptions1ty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}byte{$endif};
begin
 if foptions1 <> value then begin
  mask:= {$ifdef FPC}longword{$else}byte{$endif}(value) xor
         {$ifdef FPC}longword{$else}byte{$endif}(foptions1);
  foptions1:= Value;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tcol(items[int1]).options1:= coloptions1ty(
            replacebits(
              {$ifdef FPC}longword{$else}byte{$endif}(value),
              {$ifdef FPC}longword{$else}byte{$endif}(tcol(items[int1]).options1),
                 mask));
   end;
  end;
  fgrid.invalidate;
 end;
end;

procedure tcols.setfontactivenum(const avalue: integer);
var
 int1: integer;
begin
 if ffontactivenum <> avalue then begin
  ffontactivenum:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tcol(items[int1]).fontactivenum:= avalue;
   end;
  end;
 end;
end;

procedure tcols.setfontfocusednum(const avalue: integer);
var
 int1: integer;
begin
 if ffontfocusednum <> avalue then begin
  ffontfocusednum:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tcol(items[int1]).fontfocusednum:= avalue;
   end;
  end;
 end;
end;

procedure tcols.setfocusrectdist(const avalue: integer);
var
 int1: integer;
begin
 if ffocusrectdist <> avalue then begin
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tcol(items[int1]).focusrectdist:= avalue;
   end;
  end;
 end;
end;

function tcols.getfontselect: tcolsfont;
begin
 getoptionalobject(fgrid.componentstate,ffontselect,
                                   {$ifdef FPC}@{$endif}createfontselect);
 result:= ffontselect;
end;

procedure tcols.setfontselect(const Value: tcolsfont);
begin
 if value <> ffontselect then begin
  setoptionalobject(fgrid.ComponentState,value,ffontselect,
                               {$ifdef FPC}@{$endif}createfontselect);
  fgrid.invalidate;
 end;
end;

function tcols.isfontselectstored: Boolean;
begin
 result:= ffontselect <> nil;
end;

procedure tcols.createfontselect;
begin
 if ffontselect = nil then begin
  ffontselect:= tcolsfont.create;
  ffontselect.onchange:= {$ifdef FPC}@{$endif}fontselectchanged;
 end;
end;

procedure tcols.fontselectchanged(const sender: tobject);
begin
 fgrid.invalidate;
end;

procedure tcols.move(const curindex, newindex: integer);
begin
 inherited;
 fgrid.ffixrows.movecol(curindex,newindex,freversedorder);
 fgrid.layoutchanged;
end;

procedure tcols.moverow(const curindex,newindex: integer; const acount: integer);
var
 int1: integer;
begin
 begindataupdate;
 try
  for int1:= 0 to self.count - 1 do begin
   tcol(items[int1]).moverow(curindex,newindex,acount);
  end;
 finally
  enddataupdate;
 end;
end;

procedure tcols.insertrow(const index: integer; const acount: integer = 1);
var
 int1: integer;
begin
 for int1:= 0 to self.count - 1 do begin
  tcol(items[int1]).insertrow(index,acount);
 end;
end;

procedure tcols.deleterow(const index: integer; const acount: integer = 1);
var
 int1: integer;
begin
 for int1:= 0 to self.count - 1 do begin
  tcol(items[int1]).deleterow(index,acount);
 end;
end;

procedure tcols.rearange(const list: tintegerdatalist);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  cols[int1].rearange(list);
 end;
end;

procedure tcols.begindataupdate;
begin
 inc(fdataupdating);
end;

procedure tcols.enddataupdate;
begin
 dec(fdataupdating);
end;

{ tdatacols }

constructor tdatacols.create(aowner: tcustomgrid; aclasstype: gridpropclassty);
begin
 fselectedrow:= -1;
 fsortcol:= -1;
 fnewrowcol:= -1;
 flastvisiblecol:= -1;
 frowstate:= trowstatelist.create(aowner);
 inherited;
 flinecolor:= defaultdatalinecolor;
 foptions:= defaultdatacoloptions;
 foptions1:= defaultdatacoloptions1;
end;

destructor tdatacols.destroy;
begin
 inherited;
 frowstate.free;
end;

procedure tdatacols.setcols(const index: integer; const Value: tdatacol);
begin
 tdatacol(items[index]).Assign(value);
end;

function tdatacols.getcols(const index: integer): tdatacol;
begin
 result:= tdatacol(items[index]);
end;

function tdatacols.colatpos(const x: integer; 
             const getscrollable: boolean = true): integer;
begin
 result:= itematpos(x,getscrollable);
end;

procedure tdatacols.updatelayout;
var
 int1,int2: integer;
begin
 int2:= -1;
 flastvisiblecol:= -1;
 for int1:= 0 to count - 1 do begin
  with tdatacol(fitems[int1]) do begin
   fcellinfo.cell.col:= int1;
   if foptions * [co_fill,co_invisible,co_nohscroll] = [co_fill] then begin
    int2:= int1;
   end;
   if not (co_invisible in foptions) then begin
    flastvisiblecol:= int1;
   end;
  end;
 end;
 if int2 >= 0 then begin
  tdatacol(fitems[int2]).fwidth:= 1;
 end;
 inherited;
 if int2 >= 0 then begin
  int1:= totwidth;
  if int1 < fgrid.finnerdatarect.cx then begin
   with tdatacol(fitems[int2]) do begin
    fwidth:= fwidth + fgrid.finnerdatarect.cx - int1{ - (step-fwidth)};
   end;
   inherited;
  end;
 end;
end;

procedure tdatacols.createitem(const index: integer; var item: tpersistent);
begin
 item:= nil;
 fgrid.createdatacol(index,tdatacol(item));
 if item = nil then begin
  inherited;
 end;
end;

procedure tdatacols.rowcountchanged(const newcount: integer);
var
 int1: integer;
begin
 if fselectedrow >= newcount then begin
  fselectedrow:= -1;
 end;
 for int1:= 0 to count - 1 do begin
  with tdatacol(items[int1]) do begin
   if fselectedrow >= newcount then begin
    fselectedrow:= -1;
   end;
  end;
 end;
 with frowstate do begin
  if folded and (newcount < count) then begin
   updatedeletedrows(newcount,count-newcount);   
  end;
  count:= newcount;
 {$ifdef mse_with_ifi}
//  if (fifilinkfoldlevel <> nil) and (flinkfoldlevel.source <> nil) then begin
//   flinkfoldlevel.source.count:= newcount;
//  end;
//  if (fifilinkissum <> nil) and (flinkissum.source <> nil) then begin
//   flinkissum.source.count:= newcount;
//  end;
 {$endif}
  if fvisiblerowmap <> nil then begin
   fvisiblerowmap.count:= newcount;
   checkdirty(newcount);
  end;
 end;
 inherited;
end;

procedure tdatacols.setrowcountmax(const value: integer);
var
 int1: integer;
begin
 with frowstate do begin
  maxcount:= value;
  if fvisiblerowmap <> nil then begin
   fvisiblerowmap.maxcount:= value;
   checkdirty(value);
  end;
 end;
 for int1:= 0 to count - 1 do begin
  with tdatacol(items[int1]) do begin
   if fdata <> nil then begin
    fdata.maxcount:= value;
   end;
  end;
 end;
end;

function tdatacols.roworderinvalid: boolean;
var
 int1: integer;
begin
 if fselectedrow <> -1 then begin
  fselectedrow:= -2;
 end;
 for int1:= 0 to count - 1 do begin
  with tdatacol(items[int1]) do begin
   if fselectedrow <> -1 then begin
    fselectedrow:= -2;
   end;
  end;
 end;
 result:= true;
 updatedatastate(result);
end;

procedure tdatacols.checkindexrange;
begin
 if not (csloading in fgrid.componentstate) then begin
  if fsortcol >= count then begin
   fsortcol:= count - 1;
  end;
  if fnewrowcol >= count then begin
   fnewrowcol:= count - 1;
  end;
 end;
end;

procedure tdatacols.setsortcol(const avalue: integer);
begin
 if fsortcol <> avalue then begin
  fsortcol := avalue;
  checkindexrange;
  fgrid.sortchanged;
 end;
end;

procedure tdatacols.setnewrowcol(const avalue: integer);
begin
 if fnewrowcol <> avalue then begin
  fnewrowcol := avalue;
  checkindexrange;
 end;
end;

procedure tdatacols.moverow(const fromindex, toindex: integer; const acount: integer = 1);
begin
// roworderinvalid;
 with frowstate do begin
  blockmovedata(fromindex,toindex,acount);
 {$ifdef mse_with_ifi}
//  if (fifilinkfoldlevel <> nil) and (flinkfoldlevel.source <> nil) then begin
//   flinkfoldlevel.source.blockmovedata(fromindex,toindex,acount);
//  end;
//  if (fifilinkissum <> nil) and (flinkissum.source <> nil) then begin
//   flinkissum.source.blockmovedata(fromindex,toindex,acount);
//  end;
 {$endif}
  if fvisiblerowmap <> nil then begin
   fvisiblerowmap.blockmovedata(fromindex,toindex,acount);
   checkdirty(fromindex);
   checkdirty(toindex);
  end;
 end;
 inherited;
end;

procedure tdatacols.insertrow(const index: integer; const acount: integer = 1);
begin
// roworderinvalid;
 with frowstate do begin
  insertitems(index,acount);
 {$ifdef mse_with_ifi}
//  if (fifilinkfoldlevel <> nil) and (flinkfoldlevel.source <> nil) then begin
//   flinkfoldlevel.source.insertitems(index,acount);
//  end;
//  if (fifilinkissum <> nil) and (flinkissum.source <> nil) then begin
//   flinkissum.source.insertitems(index,acount);
//  end;
 {$endif}
  if fvisiblerowmap <> nil then begin
   fvisiblerowmap.insertitems(index,acount);
   checkdirty(index);
  end;
 end;
 inherited;
end;


procedure tdatacols.deleterow(const index: integer; const acount: integer = 1);
begin
// roworderinvalid;
 with frowstate do begin
  if fvisiblerowmap <> nil then begin
   updatedeletedrows(index,acount);
   fvisiblerowmap.deleteitems(index,acount);
  {$ifdef mse_with_ifi}
//   if (fifilinkfoldlevel <> nil) and (flinkfoldlevel.source <> nil) then begin
//    flinkfoldlevel.source.deleteitems(index,acount);
//   end;
//   if (fifilinkissum <> nil) and (flinkissum.source <> nil) then begin
//    flinkissum.source.deleteitems(index,acount);
//   end;
  {$endif}
  end;
  deleteitems(index,acount);
 end;
 inherited;
end;

procedure tdatacols.beginchangelock;
var
 int1: integer;
begin
 if fchangelock = 0 then begin
  for int1:= 0 to count-1 do begin
   with tdatacol(fitems[int1]) do begin
    include(fstate,gps_changelock);
   end;
  end;
 end;
 inc(fchangelock);
end;

procedure tdatacols.endchangelock;
var
 int1: integer;
 col1: tdatacol;
begin
 dec(fchangelock);
 if fchangelock = 0 then begin
  for int1:= 0 to count-1 do begin
   with tdatacol(fitems[int1]) do begin
    exclude(fstate,gps_changelock);
   end;
  end;
  if fgrid.componentstate * 
                  [csloading,csdesigning,csdestroying] = [] then begin
   for int1:= 0 to count - 1 do begin
    col1:= tdatacol(fitems[int1]);
    if assigned(col1.fonchange) then begin
     col1.fonchange(col1,-1);
    end;
   end;
  end;
 end;
end;

procedure tdatacols.setcount1(acount: integer; doinit: boolean);
begin
 roworderinvalid;
 if fgrid.ffocusedcell.col >= acount then begin
  if csdestroying in fgrid.componentstate then begin
   fgrid.ffocusedcell:= invalidcell;
  end
  else begin
   fgrid.col:= invalidaxis;
  end;
 end;
 inherited;
end;

function tdatacols.getselected(const cell: gridcoordty): boolean;
var
 int1: integer;
begin
 if cell.col >= 0 then begin
  result:= cols[cell.col].getselected(cell.row);
 end
 else begin
  if cell.row >= 0 then begin
   result:= (frowstate.getitempo(cell.row)^.selected and 
                                              wholerowselectedmask <> 0);
  end
  else begin
   result:= true;
   for int1:= 0 to count - 1 do begin
    if not (gps_selected in cols[int1].fstate) then begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
end;

procedure tdatacols.setselected(const cell: gridcoordty; const Value: boolean);
var
 int1: integer;
 po1: prowstatety;
 ca1: longword;
 bo1: boolean;
 rowstatesize: integer;
 
begin
 fgrid.setselected(cell,value);
// if not (gs_isdb in fgrid.fstate) then begin
  if cell.col >= 0 then begin
   cols[cell.col].setselected(cell.row,value);
  end
  else begin            //select-deselect whole row
   fgrid.beginupdate;
   try
    for int1:= 0 to count - 1 do begin
     cols[int1].setselected(cell.row,value);
    end;
    if value then begin
     ca1:= $ffffffff;
    end
    else begin
     ca1:= 0;
    end;
    bo1:= false;
    if cell.row >= 0 then begin
     po1:= frowstate.getitempo(cell.row);
     if ca1 <> po1^.selected then begin
      if value then begin
       if fselectedrow = -1 then begin
        fselectedrow:= cell.row;
       end
       else begin
        fselectedrow:= -2;
       end;
      end
      else begin
       if fselectedrow = cell.row then begin
        fselectedrow:= -1;
       end;
      end;
      po1^.selected:= ca1;
      fgrid.invalidaterow(cell.row); //for fixcols
      bo1:= true;
     end;
    end
    else begin
     po1:= frowstate.datapo;
     rowstatesize:= frowstate.fsize;
     if value then begin
      for int1:= 0 to frowstate.count - 1 do begin
       if ca1 <> po1^.selected then begin
        po1^.selected:= ca1;
        fgrid.invalidaterow(int1); //for fixcols
       end;
       inc(pchar(po1),rowstatesize);
      end;
      fselectedrow:= -2;
     end
     else begin
      if fselectedrow <> -1 then begin
       if fselectedrow >= 0 then begin
        prowstatety(pchar(po1) + fselectedrow * rowstatesize)^.selected:= ca1;
        fgrid.invalidaterow(fselectedrow); //for fixcols
        bo1:= true;
       end
       else begin
        for int1:= 0 to frowstate.count - 1 do begin
         if ca1 <> po1^.selected then begin
          po1^.selected:= ca1;
          fgrid.invalidaterow(int1); //for fixcols
          bo1:= true;
         end;
         inc(pchar(po1),rowstatesize);
        end;
       end;
       fselectedrow:= -1;
      end;
     end;
    end;
    if bo1 then begin
     fgrid.internalselectionchanged;
    end;
   finally
    fgrid.endupdate;
   end;
  end;
// end;
end;

function tdatacols.Getrowselected(const index: integer): boolean;
begin
 result:= getselected(makegridcoord(invalidaxis,index));
end;

procedure tdatacols.Setrowselected(const index: integer; const avalue: boolean);
begin
 setselected(makegridcoord(invalidaxis,index),avalue);
end;

procedure tdatacols.clearselection;
begin
 setselected(invalidcell,false);
end;

procedure tdatacols.setselectedrange(const start,stop: gridcoordty;
                    const value: boolean;
                    const calldoselectcell: boolean = false;
                    const checkmultiselect: boolean = false);
var
 int1,int2: integer;
 mo1: cellselectmodety;
 rect: gridrectty;
begin
 rect.pos:= start;
 rect.colcount:= stop.col - start.col;
 rect.rowcount:= stop.row - start.row;
 normalizerect1(rectty(rect)); 
 if calldoselectcell then begin
  if value then begin
   mo1:= csm_select;
  end
  else begin
   mo1:= csm_deselect;
  end;
  for int1:= rect.col to rect.col + rect.colcount - 1 do begin
   cols[int1].beginselect;   
   for int2:= rect.row to rect.row + rect.rowcount - 1 do begin
    fgrid.selectcell(makegridcoord(int1,int2),mo1,checkmultiselect);
   end;
  end;
  for int1:= rect.col to rect.col + rect.colcount - 1 do begin
   try
    cols[int1].endselect;
   except
    application.handleexception;
   end;
  end;
 end
 else begin
  for int1:= rect.col to rect.col + rect.colcount - 1 do begin
   with cols[int1] do begin
    beginselect;
    if not value or not checkmultiselect or 
                             (co_multiselect in options) then begin
     for int2:= rect.row to rect.row + rect.rowcount - 1 do begin
      selected[int2]:= value;
     end;
    end;
   end;
  end;
  for int1:= rect.col to rect.col + rect.colcount - 1 do begin
   dec(cols[int1].fselectlock);
  end;
 end;
end;

procedure tdatacols.setselectedrange(const rect: gridrectty; const value: boolean;
                        const calldoselectcell: boolean = false;
                        const checkmultiselect: boolean = false);
begin
 setselectedrange(rect.pos,
      makegridcoord(rect.col+rect.colcount,rect.row+rect.rowcount),
      value,calldoselectcell,checkmultiselect);
end;

procedure tdatacols.changeselectedrange(const start,oldend,newend: gridcoordty;
                                             calldoselectcell: boolean);
begin
//dummy
end;

function tdatacols.hasselection: boolean;
var
 int1: integer;
begin
 result:= fselectedrow <> -1;
 if not result then begin
  for int1:= 0 to count - 1 do begin
   if cols[int1].fselectedrow <> -1 then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

procedure tdatacols.mergecols(const arow: integer; const astart: longword = 0; 
                       const acount: longword = bigint);
begin
 if frowstate.mergecols(arow,astart,acount) then begin
  mergechanged(arow);
 end;
end;

procedure tdatacols.unmergecols(const arow: integer = invalidaxis);
begin
 if frowstate.unmergecols(arow) then begin
  mergechanged(arow);
 end;
end;

function tdatacols.previosvisiblecol(aindex: integer): integer;
var
 int1: integer;
begin
 result:= invalidaxis;
 if aindex >= count then begin
  aindex:= count - 1;
 end;
 for int1:= aindex - 1 downto 0 do begin
  if not (co_invisible in tdatacol(fitems[int1]).foptions) or
                  (csdesigning in fgrid.ComponentState) then begin
   result:= int1;
   break;
  end;
 end;
end;

function tdatacols.selectedcellcount: integer;
var
 int1,int2: integer;
 bo1: boolean;
begin
 result:= 0;
 if hasselection then begin
  bo1:= hascolselection;
  for int1:= 0 to frowstate.count - 1 do begin
   if bo1 or (frowstate.getitempo(int1)^.selected <> 0) then begin
    for int2:= 0 to count - 1 do begin
     if tdatacol(fitems[int2]).selected[int1] then begin
      inc(result);
     end;
    end;
   end;
  end;
 end;
end;

function tdatacols.hascolselection: boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to count - 1 do begin
  if gps_selected in tdatacol(fitems[int1]).fstate then begin
   result:= true;
   exit;
  end;
 end;
end;

function tdatacols.getselectedcells: gridcoordarty;
const
 capacitystep = 64;
var
 int1,int2,int3: integer;
 cell: gridcoordty;
 bo1: boolean;
begin
 result:= nil;
 if hasselection then begin          //todo: optimize
  int3:= 0;
  bo1:= hascolselection;
  for int1:= 0 to frowstate.count - 1 do begin
   if bo1 or (frowstate.getitempo(int1)^.selected <> 0) then begin
    cell.row:= int1;
    for int2:= 0 to count - 1 do begin
     if tdatacol(fitems[int2]).selected[int1] then begin
      if int3 >= length(result) then begin
       setlength(result,length(result)*2 + capacitystep);
      end;
      cell.col:= int2;
      result[int3]:= cell;
      inc(int3);
     end;
    end;
   end;
  end;
  setlength(result,int3);
 end;
end;

procedure tdatacols.beginselect;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tdatacol(fitems[int1]).beginselect;
 end;
end;

procedure tdatacols.endselect;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  try
   tdatacol(fitems[int1]).endselect;
  except
   application.handleexception;
  end;
 end;
end;

procedure tdatacols.decselect;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tdatacol(fitems[int1]) do begin
   dec(fselectlock);
  end;
 end;
end;

procedure tdatacols.setselectedcells(const Value: gridcoordarty);
var
 int1: integer;
begin
 fgrid.beginupdate;
 beginselect;
 clearselection;
 for int1:= 0 to high(value) do begin
  setselected(value[int1],true);
 end;
 endselect;
 fgrid.endupdate;
end;

function tdatacols.getselectedrows: integerarty;
var
 int1,int2: integer;
 po1: prowstatety;
begin
 result:= nil;
 po1:= frowstate.datapo;
 int2:= 0;
 for int1:= 0 to fgrid.frowcount - 1 do begin
  if po1^.selected and wholerowselectedmask <> 0 then begin
   additem(result,int1,int2);
  end;
  inc(po1);
 end;
 setlength(result,int2);
end;

procedure tdatacols.setselectedrows(const avalue: integerarty);
var
 int1: integer;
begin
 fgrid.beginupdate;
 beginselect;
 clearselection;
 for int1:= 0 to high(avalue) do begin
  setselected(makegridcoord(invalidaxis,avalue[int1]),true);
 end;
 endselect;
 fgrid.endupdate;
end;

procedure tdatacols.sortfunc(sender: tcustomgrid; const index1,
  index2: integer; var result: integer);
var
 int1: integer;
begin
 if fsortcol < 0 then begin
  for int1:= 0 to count-1 do begin
   with cols[int1] do begin
    if not(co_nosort in foptions) then begin
     sortcompare(index1,index2,result);
     if result <> 0 then begin
      if co_sortdescent in foptions then begin
       result:= - result;
      end;
      break;
     end;
    end;
   end;
  end;
 end
 else begin
  with cols[fsortcol] do begin
   if not(co_nosort in foptions) then begin
    sortcompare(index1,index2,result);
    if co_sortdescent in foptions then begin
     result:= - result;
    end;
   end;
  end;
 end;
end;

procedure tdatacols.updatedatastate(var accepted: boolean);
begin
//dummy
end;

function compcol(const l,r): integer;
begin
 result:= tdatacol(l).fcellinfo.cell.col - tdatacol(r).fcellinfo.cell.col;
end;

procedure tdatacols.dostatread(const reader: tstatreader);
var
 int1: integer;
 ar1: integerarty;
 int2: integer;
begin
 ar1:= nil; //compiler warning
 fgrid.beginupdate;
 try
  if og_savestate in fgrid.foptionsgrid then begin
   sortcol:= reader.readinteger('sortcol',sortcol,-1,count-1);
   if og_colmoving in fgrid.optionsgrid then begin
    ar1:= readorder(reader);
    if ar1 <> nil then begin
     fgrid.fixrows.orderdatacols(ar1);
     fgrid.layoutchanged;
    end;
   end;
  end;
  for int1:= 0 to count - 1 do begin
   cols[int1].dostatread(reader);
  end;
  if not (gs_isdb in fgrid.fstate) then begin
   int2:= 0;
   if fgrid.foptionsgrid * [og_folded,og_colmerged,og_rowheight] <> [] then begin
    reader.readdatalist('rowstate',frowstate);
    int2:= frowstate.count;
   end;
   for int1:= 0 to count - 1 do begin
    with cols[int1] do begin
     if (fdata <> nil) and (fdata.count > int2) then begin
      int2:= fdata.count;
     end;
    end;
   end;
   frowstate.count:= int2;
   for int1:= 0 to count - 1 do begin
    with cols[int1] do begin
     if (fdata <> nil) then begin
      fdata.count:= int2;
     end;
    end;
   end;
   fgrid.rowcount:= int2;
   if frowstate.folded then begin
    frowstate.recalchidden;
   end;
  end;
 finally
  fgrid.endupdate;
 end;
end;

procedure tdatacols.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 if og_savestate in fgrid.foptionsgrid then begin
  writer.writeinteger('sortcol',sortcol);
 end;
 if fgrid.foptionsgrid * [og_folded,og_colmerged,og_rowheight] <> [] then begin
  writer.writedatalist('rowstate',frowstate);
 end;
end;

function tdatacols.cancopy: boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to count-1 do begin
  with tdatacol(fitems[int1]) do begin
   if co_cancopy in foptions then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

function tdatacols.canpaste: boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to count-1 do begin
  with tdatacol(fitems[int1]) do begin
   if co_canpaste in foptions then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

function tdatacols.rowempty(const arow: integer): boolean;
var
 int1: integer;
begin
 result:= true;
 for int1:= 0 to count - 1 do begin
  if not tdatacol(fitems[int1]).isempty(arow) then begin
   result:= false;
   break;
  end;
 end;
end;

procedure tdatacols.rearange(const list: tintegerdatalist);
begin
 inherited;
 frowstate.rearange(list);
end;

procedure tdatacols.move(const curindex: integer; const newindex: integer);
begin
 inherited;
 with fgrid do begin
  if fnewrowcol = curindex then begin
   fnewrowcol:= newindex;
  end;
  if fsortcol = curindex then begin
   fsortcol:= newindex;
  end;
 end;
end;

procedure tdatacols.dosizechanged;
begin
 checkindexrange;
 inherited;
end;

function tdatacols.colbyname(const aname: string): tdatacol;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to count - 1 do begin
  if tdatacol(fitems[int1]).fname = aname then begin
   result:= tdatacol(fitems[int1]);
   break;
  end;
 end;
end;

function tdatacols.datalistbyname(const aname: string): tdatalist; //can be nil
var
 col1: tdatacol;
begin
 result:= nil;
 col1:= colbyname(aname);
 if col1 <> nil then begin
  result:= col1.datalist;
 end;
end;

function tdatacols.colsubdatainfo(const aname: string): subdatainfoty;
var
 int1: integer;
begin
 result.subindex:= 0;
 result.list:= nil;
 for int1:= 0 to count - 1 do begin
  with tdatacol(fitems[int1]) do begin
   if fname = aname then begin
    result.list:= datalist;
    break;
   end;
   if fnameb = aname then begin
    result.list:= datalist;
    result.subindex:= 1;
    break;
   end;
  end;
 end;
end;

procedure tdatacols.datasourcechanged;
begin
 //dummy
end;

procedure tdatacols.begindataupdate;
var
 int1: integer;
begin
 if fdataupdating = 0 then begin
  for int1:= 0 to count - 1 do begin
   with tdatacol(fitems[int1]) do begin
    if fdata <> nil then begin
     fdata.beginupdate;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tdatacols.enddataupdate;
var
 int1: integer;
begin
 inherited;
 if fdataupdating = 0 then begin
  for int1:= 0 to count - 1 do begin
   try
    with tdatacol(fitems[int1]) do begin
     if fdata <> nil then begin
      fdata.endupdate;
     end;
    end;
   except
    application.handleexception(fgrid);
   end;
  end;
 end;
end;

procedure tdatacols.countchanged;
begin
 if flastvisiblecol >= count then begin
  flastvisiblecol:= count - 1;
 end;
 fgrid.ffixrows.datacolscountchanged;
 inherited;
end;

procedure tdatacols.mergechanged(const arow: integer);
begin
 if (arow < 0) or (arow >= 0) and (arow = fgrid.row) then begin
  fgrid.layoutchanged;
 end
 else begin
  fgrid.invalidaterow(arow);
 end;
 fgrid.rowstatechanged(arow);
end;

{ tdrawcols }

constructor tdrawcols.create(aowner: tcustomgrid);
begin
 inherited create(aowner,tdrawcol);
end;

class function tdrawcols.getitemclasstype: persistentclassty;
begin
 result:= tdrawcol;
end;

function tdrawcols.getcols(const index: integer): tdrawcol;
begin
 result:= tdrawcol(items[index]);
end;

{ tstringcols }

constructor tstringcols.create(aowner: tcustomgrid);
begin
 ftextflags:= defaultcoltextflags;
 ftextflagsactive:= defaultactivecoltextflags;
 foptionsedit:= defaultstringcoleditoptions;
 foptionsedit1:= defaultoptionsedit1;
 inherited create(aowner,getcolclass);
end;

class function tstringcols.getitemclasstype: persistentclassty;
begin
 result:= tstringcol;
end;

function tstringcols.getcolclass: stringcolclassty;
begin
 result:= tstringcol;
end;

function tstringcols.getcols(const index: integer): tstringcol;
begin
 result:= tstringcol(items[index]);
end;

procedure tstringcols.settextflags(avalue: textflagsty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}word{$endif};
begin
 if ftextflags <> avalue then begin
  avalue:= checktextflags(ftextflags,avalue);
  mask:= {$ifdef FPC}longword{$else}longword{$endif}(avalue) xor
  {$ifdef FPC}longword{$else}longword{$endif}(ftextflags);
  ftextflags:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tstringcol(items[int1]).textflags:=
         textflagsty(replacebits({$ifdef FPC}longword{$else}longword{$endif}(avalue),
         {$ifdef FPC}longword{$else}longword{$endif}(tstringcol(items[int1]).textflags),mask));
   end;
  end;
 end;
end;

procedure tstringcols.settextflagsactive(avalue: textflagsty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}word{$endif};
begin
 if ftextflagsactive <> avalue then begin
  avalue:= checktextflags(ftextflagsactive,avalue);
  mask:= {$ifdef FPC}longword{$else}longword{$endif}(avalue) xor
         {$ifdef FPC}longword{$else}longword{$endif}(ftextflagsactive);
  ftextflagsactive := avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tstringcol(items[int1]).textflagsactive:=
           textflagsty(replacebits(
           {$ifdef FPC}longword{$else}longword{$endif}(avalue),
           {$ifdef FPC}longword{$else}longword{$endif}
                    (tstringcol(items[int1]).textflagsactive),mask));
   end;
  end;
 end;
end;

procedure tstringcols.setoptionsedit(avalue: stringcoleditoptionsty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}byte{$endif};
begin
// exclude(avalue,scoe_autopost);
 if foptionsedit <> avalue then begin
  mask:= {$ifdef FPC}longword{$else}longword{$endif}(avalue) xor
  {$ifdef FPC}longword{$else}longword{$endif}(foptionsedit);
  foptionsedit := avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tstringcol(items[int1]).optionsedit:= stringcoleditoptionsty(
                   replacebits({$ifdef FPC}longword{$else}longword{$endif}(avalue),
    {$ifdef FPC}longword{$else}longword{$endif}
                               (tstringcol(items[int1]).optionsedit),mask));
   end;
  end;
 end;
end;

procedure tstringcols.setoptionsedit1(avalue: optionsedit1ty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}byte{$endif};
begin
// exclude(avalue,scoe_autopost);
 if foptionsedit1 <> avalue then begin
  mask:= {$ifdef FPC}longword{$else}byte{$endif}(avalue) xor
  {$ifdef FPC}longword{$else}byte{$endif}(foptionsedit1);
  foptionsedit1:= avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tstringcol(items[int1]).optionsedit1:= optionsedit1ty(
                   replacebits({$ifdef FPC}longword{$else}byte{$endif}(avalue),
    {$ifdef FPC}longword{$else}byte{$endif}
                               (tstringcol(items[int1]).optionsedit1),mask));
   end;
  end;
 end;
end;

procedure tstringcols.updatedatastate(var accepted: boolean);
begin
 fgrid.checkcellvalue(accepted);
 inherited;
end;

{ tfixcols }

constructor tfixcols.create(aowner: tcustomgrid);
begin
 freversedorder:= true;
 inherited create(aowner,tfixcol);
 flinecolor:= defaultfixlinecolor;
end;

class function tfixcols.getitemclasstype: persistentclassty;
begin
 result:= tfixcol;
end;

function tfixcols.getcols(const index: integer): tfixcol;
begin
 result:= tfixcol(items[-index-1]);
end;

procedure tfixcols.setcols(const index: integer; const Value: tfixcol);
begin
 tfixcol(items[-index-1]).assign(value);
end;

function tfixcols.colatpos(const x: integer): integer;
begin
 result:= itematpos(x);
 if result < 0 then begin
  result:= 0;
 end
 else begin
  result:= -result - 1;
 end;
end;

procedure tfixcols.updatelayout;
var
 int1: integer;
begin
 if foppositecount > count then begin
  foppositecount:= count;
 end;
 ffirstopposite:= -(count-foppositecount)-1;
 for int1:= 0 to count - 1 do begin
  tfixcol(fitems[int1]).fcellinfo.cell.col:= -int1-1;
 end;
 inherited;
end;

procedure tfixcols.countchanged;
begin
 fgrid.fixrows.fixcolscountchanged;
 inherited;
end;

{ tfixrows }

constructor tfixrows.create(aowner: tcustomgrid);
begin
 freversedorder:= true;
 inherited create(aowner,tfixrow);
 flinecolor:= defaultfixlinecolor;
end;

class function tfixrows.getitemclasstype: persistentclassty;
begin
 result:= tfixrow;
end;

function tfixrows.getrows(const index: integer): tfixrow;
begin
 result:= tfixrow(items[-index-1]);
end;

procedure tfixrows.setrows(const index: integer; const Value: tfixrow);
begin
 tfixrow(items[-index-1]).Assign(value);
end;

function tfixrows.rowatpos(const y: integer): integer;
begin
 result:= itematpos(y);
 if result < 0 then begin
  result:= 0;
 end
 else begin
  result:= -result - 1;
 end;
end;

procedure tfixrows.updatelayout;
var
 int1: integer;
begin
 if foppositecount > count then begin
  foppositecount:= count;
 end;
 ffirstopposite:= -(count-foppositecount)-1;
 for int1:= 0 to count - 1 do begin
  tfixrow(fitems[int1]).fcellinfo.cell.row:= -int1-1;
 end;
 inherited;
 for int1:= 0 to count - 1 do begin
  tfixrow(items[int1]).updatelayout;
 end;
end;

procedure tfixrows.updatemergedcells;
var
 int1: integer;
begin
 for int1:= count - 1 downto 0 do begin //top down for row merging
  tfixrow(items[int1]).updatemergedcells;
 end;
end;

procedure tfixrows.paint(const info: rowspaintinfoty);
var
 po1,po2: pointty;
 linewidthbefore: integer;

 procedure paintrows(const range: rangety);
 var
  int1: integer;
 begin
  with info do begin
   for int1:= range.startindex to range.endindex do begin
    with tfixrow(fitems[int1]) do begin
     po2.y:= po1.y + fstart;
     with rowinfo do begin
      canvas.origin:= po2;
      paint(rowinfo);
     end;
    end;
   end;
  end;
 end;

var
 int1,int2: integer;
 reg: regionty;

begin
 with info,rowinfo do begin
  if (info.rowinfo.cols.count > 0) and //fpc bug 4130
//  if (cols.count > 0) and
  (rowrange.range1.endindex >= rowrange.range1.startindex) or
         (rowrange.range2.endindex >= rowrange.range2.startindex) then begin
         {
   po1:= canvas.origin;
   po2.x:= po1.x;
   paintrows(rowrange.range1);
   paintrows(rowrange.range2);
   canvas.origin:= po1;
   }
   reg:= canvas.copyclipregion;
   canvas.subcliprect(makerect(0,
             fgrid.finnerdatarect.y-tframe1(fgrid.fframe).fi.innerframe.top,
             bigint{tframe1(fgrid.fframe).fpaintrect.cx)},fgrid.finnerdatarect.cy));
   for int1:= 0 to cols.count - 1 do begin
    with cols[int1] do begin
     if (flinewidth > 0) and (colrange.scrollables xor (co_nohscroll in foptions)) and
         (not(co_invisible in foptions) or (csdesigning in fgrid.ComponentState)) then begin
      linewidthbefore:= canvas.linewidth;
      if flinewidth = 1 then begin
       canvas.linewidth:= 0;
      end
      else begin
       canvas.linewidth:= flinewidth;
      end;
      int2:= fstart + flinepos + fcellrect.x;
      canvas.drawline(makepoint(int2,0),
           makepoint(int2,
                      tframe1(fgrid.fframe).finnerclientrect.cy{ - 1}),
                      flinecolorfix);
      canvas.linewidth:= linewidthbefore;
     end;
    end;
   end;
   canvas.clipregion:= reg;
   po1:= canvas.origin;
   po2.x:= po1.x;
   paintrows(rowrange.range1);
   paintrows(rowrange.range2);
   canvas.origin:= po1;
  end;
 end;
end;

procedure tfixrows.movecol(const curindex,newindex: integer;
                               const isfix: boolean);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tfixrow(fitems[int1]).movecol(curindex,newindex,isfix);
 end;
end;

procedure tfixrows.datacolscountchanged;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tfixrow(fitems[int1]).datacolscountchanged(count);
 end;
end;

procedure tfixrows.fixcolscountchanged;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tfixrow(fitems[int1]).fixcolscountchanged(count);
 end;
end;

procedure tfixrows.orderdatacols(const neworder: integerarty);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tfixrow(fitems[int1]).orderdatacols(neworder);
 end;
end;

procedure tfixrows.dofontheightdelta(var delta: integer);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tfixrow(fitems[int1]) do begin
   if ffont = nil then begin
    height:= height + delta;
   end;
  end;
 end;
end;

procedure tfixrows.synctofontheight;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tfixrow(fitems[int1]).synctofontheight;
 end;
end;

function tfixrows.getclientsize: integer;
begin
 result:= tgridframe(fgrid.fframe).finnerclientrect.cy;
end;

{ tcustomgrid }

constructor tcustomgrid.create(aowner: tcomponent);
begin
 include(fstate,gs_updatelocked);
 fmouseeventcol:= -1;
 fmousecell:= invalidcell;
 fwheelscrollheight:= defaultwheelscrollheight;
 frowcountmax:= bigint;
 frowcolors:= tcolorarrayprop.Create;
 frowfonts:= trowfontarrayprop.Create(self);
 ffocusedcell:= invalidcell;
 fstartanchor:= invalidcell;
 fendanchor:= invalidcell;
 fmouseparkcell:= invalidcell;
 factiverow:= invalidaxis;
 flastcol:= invalidaxis;

 foptionsgrid:= defaultoptionsgrid;
 fdatarowlinewidth:= defaultgridlinewidth;
 fdatarowlinecolorfix:= defaultfixlinecolor;
 fdatarowlinecolor:= defaultdatalinecolor;

 fdatarowheight:= griddefaultrowheight;
 fdatarowheightmin:= 1;
 fdatarowheightmax:= maxint;

 fgridframecolor:= cl_black;

 fdatacols:= createdatacols;
 ffixcols:= createfixcols;
 ffixrows:= createfixrows;

 fdragcontroller:= tdragcontroller.create(idragcontroller(self));
 fzebra_color:= cl_infobackground;
 fzebra_step:= 2;

 inherited;
 internalcreateframe;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self));
// fobjectpicker.options:= fobjectpicker.options + [opo_candoubleclick];
 foptionswidget:= defaultgridwidgetoptions;
 exclude(fstate,gs_updatelocked);
 internalupdatelayout;
end;

destructor tcustomgrid.destroy;
begin
 killrepeater;
 inherited;
 fdragcontroller.Free;
 fobjectpicker.Free;
 fdatacols.Free;
 ffixcols.Free;
 ffixrows.Free;
 frowcolors.Free;
 frowfonts.Free;
end;

procedure tcustomgrid.initeventinfo(const cell: gridcoordty;
      eventkind: celleventkindty; out info: celleventinfoty);
begin
 fillchar(info,sizeof(info),0);
 info.cell:= cell;
 info.eventkind:= eventkind;
end;

procedure tcustomgrid.invalidate;
begin
 if fnoinvalidate = 0 then begin
  finvalidatedcells:= nil;
 end;
 if caninvalidate then begin
  inherited;
  exclude(fstate,gs_invalidated);
 end;
end;

function tcustomgrid.caninvalidate: boolean;
begin
 if fnoinvalidate = 0 then begin
  result:= (fupdating = 0) and not (csloading in componentstate);
  include(fstate,gs_invalidated);
 end
 else begin
  result:= false;
 end;
end;

procedure tcustomgrid.layoutchanged;
begin
 if fstate * [gs_layoutvalid,gs_layoutupdating] = [gs_layoutvalid] then begin
  exclude(fstate,gs_layoutvalid);
  invalidate;
 end;
end;

procedure tcustomgrid.rowdatachanged(const acell: gridcoordty;
                                              const count: integer = 1);
begin
 if not (csloading in componentstate) then begin
  if fupdating = 0 then begin
   exclude(fstate,gs_rowdatachanged);
   inc(frowdatachanging);
   try
    dorowsdatachanged(acell,count);
   finally
    dec(frowdatachanging);
   end;
  end
  else begin
   include(fstate,gs_rowdatachanged);
  end;
 end;
end;

procedure tcustomgrid.setselected(const cell: gridcoordty; const avalue: boolean);
begin
 //dummy
end;

procedure tcustomgrid.internalselectionchanged;
begin
 if fupdating = 0 then begin
  exclude(fstate,gs_selectionchanged);
  doselectionchanged;
 end
 else begin
  include(fstate,gs_selectionchanged);
 end;
end;

procedure tcustomgrid.doselectionchanged;
begin
 if assigned(fonselectionchanged) then begin
  fonselectionchanged(self);
 end;
end;

function tcustomgrid.getscrollrect: rectty;
begin
 internalupdatelayout;
 result:= fscrollrect;
end;

procedure tcustomgrid.setscrollrect(const rect: rectty);
var
 po2,po3: pointty;
begin
 po2:= subpoint(rect.pos,fscrollrect.pos);
 fscrollrect.size:= rect.size;
 if (po2.x <> 0) or (po2.y <> 0) then begin
  po3.x:= 0;
  po3.y:= po2.y;
  scrollrect(po3,fdatarecty,scrollcaret);
  fscrollrect.y:= rect.y;
  updatevisiblerows;
  scrolled(po3);
  po3.x:= po2.x;
  po3.y:= 0;
  scrollrect(po3,fdatarectx,scrollcaret);
  fscrollrect.x:= rect.x;
  scrolled(po3);
 end;
end;

function tcustomgrid.calcminscrollsize: sizety;
begin
 internalupdatelayout;
 if not (gs_updatelocked in fstate) then begin
  result.cx:= fdatacols.ftotsize + ffixcols.ftotsize + ffirstnohscroll +
             tgridframe(fframe).fi.innerframe.left +
             tgridframe(fframe).fi.innerframe.right;
  if og_rowheight in foptionsgrid then begin
   result.cy:= fdatacols.frowstate.rowypos[frowcount];
  end
  else begin
   result.cy:= (frowcount - fdatacols.frowstate.fhiddencount) * fystep;
  end;
  result.cy:= result.cy + ffixrows.ftotsize +
                     tgridframe(fframe).fi.innerframe.top +
                     tgridframe(fframe).fi.innerframe.bottom;
 end
 else begin
  result:= nullsize;
 end;
end;

procedure tcustomgrid.calcpropcolwidthref;
var
 int1,int3: integer;
begin
 with tgridframe(fframe) do begin
  fpropcolwidthref:= self.fwidgetrect.cx -
                     fouterframe.left - fouterframe.right -
                     2*(fi.levelo+fi.framewidth+fi.leveli) -
                     finnerframe.left - finnerframe.right - 
                     2 * gridframewidth;
 end;
 int3:= 0;
 for int1:= 0 to fdatacols.count - 1 do begin
  with fdatacols[int1] do begin
   if not (co_invisible in options) then begin
    if options * [co_proportional,co_fill] = [] then begin
     fpropcolwidthref:= fpropcolwidthref - width;
    end
    else begin
     int3:= int3 + widthmin;
    end;
   end;
  end;
 end;
 for int1:= 0 to ffixcols.count - 1 do begin
  with tfixcol(ffixcols.items[int1]) do begin
   if not (fco_invisible in options) then begin
    fpropcolwidthref:= fpropcolwidthref - width;
   end;
  end;   
 end;
 if fpropcolwidthref < int3 then begin
  fpropcolwidthref:= int3;
 end;
end;

procedure tcustomgrid.updatelayout;
var
 scrollstate: framestatesty;
 int1,int2,int3: integer;
begin
 exclude(fstate,gs_hasactiverowcolor);
 exclude(fstate,gs_needszebraoffset);
 if (zebra_step <> 0) then begin
  include(fstate,gs_needszebraoffset);
 end;
 for int1:= 0 to ffixcols.count -1 do begin
  with tfixcol(ffixcols.items[int1]) do begin
   if numstep <> 0 then begin
    include(self.fstate,gs_needszebraoffset);
   end;
   if (coloractive <> cl_none) or (colorfocused <> cl_none) or 
         (fontactivenum >= 0) or (fontfocusednum >= 0) then begin
    include(self.fstate,gs_hasactiverowcolor);
   end;
  end;
 end;
 if not (gs_hasactiverowcolor in fstate) then begin
  for int1:= 0 to fdatacols.count -1 do begin
   with tdatacol(fdatacols.items[int1]) do begin
    if ((fcoloractive <> cl_none)  or (fontactivenum >= 0)) and 
                            (co1_rowcoloractive in foptions1) or 
       ((fcolorfocused <> cl_none)  or (fontfocusednum >= 0)) and 
                            (co1_rowcolorfocused in foptions1) then begin
     include(self.fstate,gs_hasactiverowcolor);
     break;
    end;
   end;
  end;
 end;
 int2:= 0;
 repeat
  calcpropcolwidthref;
  scrollstate:= frame.state;
  fystep:= fdatarowheight + fdatarowlinewidth;
  ffixcols.updatelayout;
  ffixrows.updatelayout;
  ffirstnohscroll:= fixcols.ffirstsize;
  for int1:= 0 to fdatacols.count - 1 do begin
   with fdatacols[int1] do begin
    if not (co_nohscroll in foptions) then begin
     break;
    end;
    fstart:= ffirstnohscroll;
    inc(ffirstnohscroll,step(false));
    fend:= ffirstnohscroll;
   end;
  end;
  ffirstnohscroll:= ffirstnohscroll - fixcols.ffirstsize;
  with tgridframe(fframe) do begin
   checkstate;
   with fdatarecty,ffixrows do begin
    finnerdatarect.y:= ffirstsize + fi.innerframe.top;
    finnerdatarect.cy:= finnerclientrect.cy - ftotsize;
    if self.fgridframewidth = 0 then begin
     x:= 0;
     cx:= fpaintrect.cx;
    end
    else begin
     x:= fi.innerframe.left;
     cx:= finnerclientrect.cx;
    end;
    y:= 0;
    if foppositecount = count then begin
     if self.fgridframewidth <> 0 then begin
      y:= fi.innerframe.top;
     end;
    end
    else begin
     if (ffirstsize > 0) or (self.fgridframewidth <> 0) then begin
      y:= ffirstsize + fi.innerframe.top;
     end;
    end;
    cy:= fpaintrect.cy - y;
    if (foppositecount > 0) and (ftotsize - ffirstsize > 0) then begin
     cy:= cy - ftotsize + ffirstsize - fi.innerframe.bottom;
    end
    else begin
     if self.fgridframewidth <> 0 then begin
      cy:= cy - fi.innerframe.bottom;
     end;
    end;
    if cx < 0 then begin
     cx:= 0;
    end;
    if cy < 0 then begin
     cy:= 0;
    end;
    if finnerdatarect.cy < 0 then begin
     finnerdatarect.cy:= 0;
    end;
   end;
   with fdatarectx,ffixcols do begin
    finnerdatarect.x:= ffirstsize + fi.innerframe.left + ffirstnohscroll;
    finnerdatarect.cx:= finnerclientrect.cx - ftotsize - ffirstnohscroll;
    if self.fgridframewidth = 0 then begin
     y:= 0;
     cy:= fpaintrect.cy;
    end
    else begin
     y:= fi.innerframe.top;
     cy:= finnerclientrect.cy;
    end;
    x:= ffirstnohscroll;
    if foppositecount = count then begin
     if (x > 0) or (self.fgridframewidth <> 0) then begin
      inc(x,fi.innerframe.left);
     end;
    end
    else begin
     if (ffirstsize > 0) or (self.fgridframewidth <> 0) then begin
      x:= ffirstsize + fi.innerframe.left + ffirstnohscroll;
     end;
    end;
    cx:= fpaintrect.cx - x;
    if (foppositecount > 0) and (ftotsize - ffirstsize > 0) then begin
     cx:= cx - ftotsize + ffirstsize - fi.innerframe.right;
    end
    else begin
     if self.fgridframewidth <> 0 then begin
      cx:= cx - fi.innerframe.right;
     end;
    end;
    if cx < 0 then begin
     cx:= 0;
    end;
    if cy < 0 then begin
     cy:= 0;
    end;
    if finnerdatarect.cx < 0 then begin
     finnerdatarect.cx:= 0;
    end;
   end;
   with fdatarect do begin
    x:= fdatarectx.x;
    cx:= fdatarectx.cx;
    y:= fdatarecty.y;
    cy:= fdatarecty.cy;
   end;
  end;
  fdatacols.updatelayout;
  ffixrows.updatemergedcells;
  updatevisiblerows; //scroll needs valid visiblerows
  tgridframe(fframe).updatestate;
  inc(int2);
 until (frame.state * scrollbarframestates = 
                       scrollstate * scrollbarframestates) or
                                          (int2 > 40);
// if og_folded in foptionsgrid then begin
//  updatevisiblerows;
// end;
end;

procedure tcustomgrid.dolayoutchanged;
begin
 if canevent(tmethod(fonlayoutchanged)) then begin
  fonlayoutchanged(self);
  if not (gs_layoutvalid in fstate) and (flayoutupdating < 16) then begin
   inc(flayoutupdating);
   try
    internalupdatelayout;
   finally
    dec(flayoutupdating);
   end;
  end;
 end;
end;

procedure tcustomgrid.internalupdatelayout(const force: boolean);
var
 bo1: boolean;
begin
 if (fstate * [gs_layoutvalid,gs_updatelocked] = []) and 
             not (csdestroying in componentstate) and 
             (force or (fupdating = 0)) then begin
  bo1:= not (gs_layoutupdating in fstate);
  if bo1 and canevent(tmethod(fonbeforeupdatelayout)) then begin
   fonbeforeupdatelayout(self);
  end;
  try
   fstate:= fstate + [gs_layoutvalid,gs_layoutupdating];
   updatelayout;
  finally
   if bo1 then begin
    exclude(fstate,gs_layoutupdating);
    dolayoutchanged;
   end;
  end;
 end;
end;

function tcustomgrid.intersectdatarect(var arect: rectty): boolean;
begin
 internalupdatelayout;
 result:= intersectrect(fdatarect,arect,arect);
end;

procedure tcustomgrid.dopaint(const acanvas: tcanvas);

var
 rect1: rectty;
 arowinfo: rowspaintinfoty;
 colinfo: colpaintinfoty;
 lines: segmentarty;
 int1,int2,int3,int4,int5: integer;
 adatarect: rectty;
 reg: regionty;
 saveindex: integer;
 linewidthbefore: integer;
 rowheight1: boolean;
 rowstate1: trowstatelist;
 lineinfos: array of record
  lcolor: colorty;
  lcolorfix: colorty;
  lwidth: integer;
 end;

begin
 inherited;
 rowheight1:= og_rowheight in foptionsgrid;
 rowstate1:= fdatacols.frowstate;
 internalupdatelayout(true);
 fnumoffset:= getnumoffset;
 saveindex:= -1;
 if fgridframewidth <> 0 then begin
  saveindex:= acanvas.save;
 end;
 acanvas.move(pointty(tframe1(fframe).fi.innerframe.topleft));
 frootbrushorigin:= clientwidgetpos;
 frootbrushorigin.x:= frootbrushorigin.x + finnerdatarect.x + rootpos.x;
 frootbrushorigin.y:= frootbrushorigin.y + finnerdatarect.y + rootpos.y;
 fbrushorigin.x:= frootbrushorigin.x;
 fbrushorigin.y:= frootbrushorigin.y + fscrollrect.y;
 rect1:= acanvas.clipbox;
 if (rect1.cx > 0) or (rect1.cy > 0) then begin
  with arowinfo do begin
   ffixrows.getindexrange(rect1.y,rect1.cy,rowrange);
   if (rowrange.range1.endindex >= rowrange.range1.endindex) or
      (rowrange.range2.endindex >= rowrange.range2.endindex) then begin
    ffixcols.getindexrange(rect1.x,rect1.cx,rowinfo.colrange);
    with rowinfo do begin
     canvas:= acanvas;
     cols:= ffixcols;
     fix:= true;
    end;
    ffixrows.paint(arowinfo);
    rowinfo.cols:= fdatacols;
    rowinfo.fix:= false;
    fdatacols.getindexrange(rect1.x,rect1.cx,rowinfo.colrange,false);
    ffixrows.paint(arowinfo);
    acanvas.save;
    acanvas.intersectcliprect(makerect(fdatarect.x -
               tframe1(fframe).fi.innerframe.left,0,
               fdatarect.cx,tframe1(fframe).fpaintrect.cy));
    acanvas.move(makepoint(ffixcols.ffirstsize+ffirstnohscroll+fscrollrect.x,0));
    rect1:= acanvas.clipbox;
    if (rect1.cx > 0) and (rect1.cy > 0) then begin
     fdatacols.getindexrange(rect1.x,rect1.cx,rowinfo.colrange);
     fixrows.paint(arowinfo);
    end;
    acanvas.restore;
   end;
  end;

  rect1.x:= -tframe1(fframe).fi.innerframe.left;
  rect1.y:= fdatarecty.y-tframe1(fframe).fi.innerframe.top;
  rect1.cx:= tframe1(fframe).fpaintrect.cx;
  rect1.cy:= fdatarecty.cy;
  acanvas.intersectcliprect(rect1);
  acanvas.move(makepoint(0,fscrollrect.y + ffixrows.ffirstsize));
                       //move to clientorigin
  rect1:= acanvas.clipbox;
  if (rect1.cx > 0) and (rect1.cy > 0) then begin
   if high(fvisiblerows) >= 0 then begin
    with colinfo do begin
     calcautocellsize:= false;
     autocellsize:= nullsize;
     ystep:= self.fystep;
     if rowheight1 then begin
      startrow:= -1;
      for int1:= high(fvisiblerows) downto 0 do begin
       with prowstaterowheightty(rowstate1.getitempo(fvisiblerows[int1]))^ do begin
        if rect1.y >= rowheight.ypos then begin
         startrow:= int1;
         ystart:= rowheight.ypos;
         break;
        end;
       end;
      end;
      if startrow < 0 then begin
       startrow:= 0;
       ystart:= prowstaterowheightty(
                 rowstate1.getitempo(fvisiblerows[0]))^.rowheight.ypos;
      end;
      endrow:= high(fvisiblerows);
      int2:= rect1.y + rect1.cy;
      for int1:= startrow to high(fvisiblerows) do begin
       if prowstaterowheightty(
               rowstate1.getitempo(fvisiblerows[int1]))^.rowheight.ypos >
                      int2 then begin
        endrow:= int1;
        break;
       end;
      end;
     end
     else begin
      startrow:= rect1.y div ystep - fvisiblerowsbase;
      if startrow < 0 then begin
       startrow:= 0;
      end; 
      ystart:= (startrow + fvisiblerowsbase) * ystep;
      endrow:= (rect1.y + rect1.cy - 1) div ystep - fvisiblerowsbase;
     end;
     rows:= fvisiblerows; 
     foldinfo:= fvisiblerowfoldinfo;
     if endrow > high(fvisiblerows) then begin
      endrow:= high(fvisiblerows);
     end;
     if endrow >= startrow then begin
      canvas:= acanvas;
      ffixcols.paint(colinfo);
      fdatacols.paint(colinfo,false);     //draw fix datacols
      if ffirstnohscroll > 0 then begin
       adatarect:= makerect(fdatarect.x-tframe1(fframe).fi.innerframe.left-ffirstnohscroll,
             -fscrollrect.y,fdatarect.cx+ffirstnohscroll,fdatarect.cy);
      end
      else begin
       adatarect:= removerect(fdatarect,
                     makepoint(tframe1(fframe).fi.innerframe.left,
                      tframe1(fframe).fi.innerframe.top+ffixrows.ffirstsize+fscrollrect.y));
      end;
      linewidthbefore:= acanvas.linewidth;
      if (fdatarowlinewidth > 0) or rowheight1 then begin
       acanvas.linewidth:= fdatarowlinewidth;
       int1:= endrow-startrow+1;
       setlength(lines,int1);
       if rowheight1 then begin
        setlength(lineinfos,int1);
        int2:= ystart;
       end
       else begin
        int2:= ystart - (fdatarowlinewidth + 1) div 2;
       end;
       int3:= tframe1(fframe).finnerclientrect.cx{ - 1};
       int5:= rowcolors.count;
       int4:= 0;
       for int1:= 0 to high(lines) do begin
        if rowheight1 then begin
         with rowstate1.getitemporowheight(fvisiblerows[int1+startrow])^.rowheight,
              lineinfos[int1] do begin
          int4:= (linecolor and rowstatemask) - 1;
          if (int4 < 0) or (int4 >= int5) then begin
           lcolor:= fdatarowlinecolor;
          end
          else begin
           lcolor:= rowcolors[int4];
          end;
          int4:= (linecolorfix and rowstatemask) - 1;
          if (int4 < 0) or (int4 >= int5) then begin
           lcolorfix:= fdatarowlinecolorfix;
          end
          else begin
           lcolorfix:= rowcolors[int4];
          end;
          if linewidth = 0 then begin
           lwidth:= fdatarowlinewidth;
          end
          else begin
           lwidth:= linewidth;
          end;
          int4:= (lwidth + 1) div 2;
         end;
         inc(int2,rowstate1.internalystep(fvisiblerows[int1+startrow]));
        end
        else begin
         inc(int2,ystep);
        end;
        with lines[int1] do begin
         a.x:= 0;
         a.y:= int2-int4;
         b.x:= int3;
         b.y:= int2-int4;
        end;
       end;
       if ffixcols.count > 0 then begin   //draw horz lines fixcols
        reg:= acanvas.copyclipregion;
        acanvas.subcliprect(adatarect);
        if not acanvas.clipregionisempty then begin
         if rowheight1 then begin
          for int1:= 0 to high(lines) do begin
           with lines[int1],lineinfos[int1] do begin
            acanvas.linewidth:= lwidth;
            acanvas.drawline(a,b,lcolorfix);
           end;
          end;
         end
         else begin
          acanvas.drawlinesegments(lines,fdatarowlinecolorfix);
         end;
        end;
        acanvas.clipregion:= reg;
       end;
      end;
      acanvas.intersectcliprect(adatarect);
      if not acanvas.clipregionisempty then begin //draw horz lines datacols
       int2:= ffixcols.ffirstsize + datacols.ftotsize +
                      {fscrollrect.x +} ffirstnohscroll{ - 1};
       if ffirstnohscroll > 0 then begin
        int3:= ffixcols.ffirstsize;
       end
       else begin
        int3:= {fscrollrect.x + }ffixcols.ffirstsize;
       end;
       if int2 > paintrect.cx then begin
        int2:= paintrect.cx;
       end;
       if int3 < 0 then begin
        int3:= 0;
       end;
       if length(lines) > 0 then begin //draw horz lines datacols
        for int1:= 0 to high(lines) do begin
         with lines[int1] do begin
          a.x:= int3;
          b.x:= int2;
         end;
        end;
        if rowheight1 then begin
         for int1:= 0 to high(lines) do begin
          with lines[int1],lineinfos[int1] do begin
           acanvas.linewidth:= lwidth;
           acanvas.drawline(a,b,lcolor);
          end;
         end;
        end
        else begin
         acanvas.drawlinesegments(lines,fdatarowlinecolor);
        end;
       end;
       if ffirstnohscroll > 0 then begin
        acanvas.intersectcliprect(
             makerect(ffirstnohscroll+ffixcols.ffirstsize,-fscrollrect.y,
                fscrollrect.size.cx,fscrollrect.size.cy));
       end;
       acanvas.move(makepoint(ffirstnohscroll+ffixcols.ffirstsize+
                        fscrollrect.x,0));
       acanvas.linewidth:= linewidthbefore;
       fdatacols.paint(colinfo,true); //draw normal cols
      end;
      acanvas.linewidth:= linewidthbefore;
     end; //endrow >= startrow
    end; //with colinfo
   end; //fvisiblerows <> nil
  end; //rect1 not empty
 end; //if cliprect not empty

 if saveindex >= 0 then begin
  acanvas.restore(saveindex);
  acanvas.drawframe(innerclientrect,fgridframewidth,fgridframecolor);
 end;
 
end;
 
procedure tcustomgrid.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tcustomgrid.setframe(const avalue: tgridframe);
begin
 inherited setframe(avalue);
end;

function tcustomgrid.getframe: tgridframe;
begin
 result:= tgridframe(inherited getframe);
end;

procedure tcustomgrid.dostatread(const reader: tstatreader);
var
 po1: gridcoordty;
begin
 fpropcolwidthref:= reader.readinteger('propcolwidthref',fpropcolwidthref,0);
 fdatacols.dostatread(reader);
 if og_savestate in foptionsgrid then begin
  po1.col:= reader.readinteger('col',ffocusedcell.col);
  if not (gs_isdb in fstate) then begin
   po1.row:= reader.readinteger('row',ffocusedcell.row);
  end
  else begin
   po1.row:= ffocusedcell.row;
  end;
  if og_rowsizing in foptionsgrid then begin
   datarowheight:= reader.readinteger('rowheight',datarowheight);
  end;
  focuscell(po1);
 end;
end;

procedure tcustomgrid.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
begin
 int1:= row;
 if not (og_nosaveremoveappendedrow in foptionsgrid) then begin
  removeappendedrow; //calls docheckcellvalue
 end
 else begin
  docheckcellvalue;
 end;
 writer.writeinteger('propcolwidthref',fpropcolwidthref);
 fdatacols.dostatwrite(writer);
 row:= int1;
 if og_savestate in foptionsgrid then begin
  writer.writeinteger('col',ffocusedcell.col);
  if not (gs_isdb in fstate) then begin
   writer.writeinteger('row',ffocusedcell.row);
  end;
  writer.writeinteger('rowheight',datarowheight);
 end;
end;

procedure tcustomgrid.statreading;
begin
 //dummy
end;

procedure tcustomgrid.statread;
begin
 //dummy
end;

function tcustomgrid.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

function tcustomgrid.rowhigh: integer;
begin
 result:= frowcount - 1;
end;

procedure tcustomgrid.setrowcount(Value: integer);
var
 int1: integer;
 bo1,bo2: boolean;
begin
 if frowcount <> value then begin
  beginupdate;
  try
   if factiverow >= value then begin
    factiverow:= invalidaxis;
   end;
   if ffocusedcell.row >= value then begin
    int1:= frowcount;
    exclude(fstate,gs_emptyrowremoved);
    include(fstate,gs_rowremoving);
    try
     defocusrow;
    finally
     exclude(fstate,gs_rowremoving);
    end;
    if (gs_emptyrowremoved in fstate) then begin
     dec(int1);
    end;
    if (frowcount <> int1) then begin
     exit;
    end;
    bo2:= frowcount =  value;
    bo1:= true;
   end
   else begin
    bo1:= false;
    bo2:= false;
   end;
   int1:= frowcount;
   if value > frowcountmax then begin
    frowcount:= frowcountmax;
    if ffocusedcell.row >= 0 then begin
     dec(ffocusedcell.row,value-frowcount);
     if ffocusedcell.row < 0 then begin
      ffocusedcell.row:= invalidaxis;
      fstate:= fstate - [gs_cellentered];
     end;
     factiverow:= ffocusedcell.row;
    end;
   end
   else begin
    frowcount := Value;
   end;
   if not bo2 then begin
    dorowcountchanged(int1,value);
   end;
   layoutchanged;
   if not (gs_isdb in fstate) and entered and
            (bo1 and ((og_autoappend in foptionsgrid) and (frowcount <> 0) or
             (frowcount = 0) and (og_autofirstrow in foptionsgrid))) then begin
    row:= frowcount;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure tcustomgrid.setrowcountmax(const Value: integer);
begin
 if (value < frowcount) {and (value <> 0)} then begin
  rowcount:= value;
 end;
 if value <> frowcountmax then begin
  fdatacols.setrowcountmax(value);
  frowcountmax := Value;
 end;
end;

procedure tcustomgrid.setdatarowlinewidth(const Value: integer);
begin
 if fdatarowlinewidth <> value then begin
  if value < 0 then begin
   fdatarowlinewidth:= 0;
  end
  else begin
   fdatarowlinewidth := Value;
  end;
  layoutchanged;
 end;
end;

procedure tcustomgrid.setdatarowlinecolor(const Value: colorty);
begin
 if fdatarowlinecolor <> value then begin
  fdatarowlinecolor := Value;
  invalidate;
 end;
end;

procedure tcustomgrid.setdatarowlinecolorfix(const Value: colorty);
begin
 if fdatarowlinecolorfix <> value then begin
  fdatarowlinecolorfix:= Value;
  invalidate;
 end;
end;

function tcustomgrid.wheelheight: integer;
begin
 if fwheelscrollheight <= 0 then begin
  result:= application.mousewheelacceleration(1);
 end
 else begin
  result:= rowsperpage - 1;
  if fwheelscrollheight < result then begin
   result:= fwheelscrollheight;
  end;
 end;
end;

procedure tcustomgrid.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
begin
 if sender.tag = 1 then begin
  case event of
   sbe_stepup: scrollrows(-1);
   sbe_stepdown: scrollrows(1);
   sbe_pageup: scrollrows(-(rowsperpage-1));
   sbe_pagedown: scrollrows(rowsperpage-1);
   sbe_wheelup: scrollrows(-wheelheight);
   sbe_wheeldown: scrollrows(wheelheight);
  end;
 end
 else begin
  case event of
   sbe_stepup: scrollleft;
   sbe_stepdown: scrollright;
   sbe_pageup,sbe_wheelup: scrollpageleft;
   sbe_pagedown,sbe_wheeldown: scrollpageright;
  end;
 end;
end;

procedure tcustomgrid.updatepopupmenu(var amenu: tpopupmenu; 
                                    var mouseinfo: mouseeventinfoty);
var
 bo1: boolean;
 state1: actionstatesty;
 sepchar: msechar;
begin
 if (og_autopopup in foptionsgrid) then begin
  if popupmenu <> nil then begin
   sepchar:= popupmenu.shortcutseparator;
  end
  else begin
   sepchar:= tcustommenu.getshortcutseparator(amenu);
  end;
  bo1:= false;
  if fdatacols.cancopy then begin
   if fdatacols.hasselection then begin
    state1:= [];
   end
   else begin
    state1:= [as_disabled];
   end;
   tpopupmenu.additems(amenu,self,mouseinfo,[
         stockobjects.captions[sc_copy_cells]+sepchar+
       '('+encodeshortcutname(sysshortcuts[sho_copycells])+')'],
                  [],[state1],[{$ifdef FPC}@{$endif}docopycells],not bo1);
   bo1:= true;
  end;
  if fdatacols.canpaste then begin
   tpopupmenu.additems(amenu,self,mouseinfo,[
        stockobjects.captions[sc_paste_cells]+sepchar+
      '('+encodeshortcutname(sysshortcuts[sho_pastecells])+')'],
                 [],[],[{$ifdef FPC}@{$endif}dopastecells],not bo1);
   bo1:= true;
  end;
  if og_rowinserting in foptionsgrid then begin
   tpopupmenu.additems(amenu,self,mouseinfo,[
              stockobjects.captions[sc_insert_row]+sepchar+
         '('+encodeshortcutname(sysshortcuts[sho_rowinsert])+')',
              stockobjects.captions[sc_append_row]+sepchar+
       '('+encodeshortcutname(sysshortcuts[sho_rowappend])+')'],[],[],
        [{$ifdef FPC}@{$endif}doinsertrow,{$ifdef FPC}@{$endif}doappendrow],
                                                                     not bo1);
   bo1:= true;
  end;
  if og_rowdeleting in foptionsgrid then begin
   if ffocusedcell.row >= 0 then begin
    state1:= [];
   end
   else begin
    state1:= [as_disabled];
   end;
   tpopupmenu.additems(amenu,self,mouseinfo,[
         stockobjects.captions[sc_delete_row]+sepchar+
       '('+encodeshortcutname(sysshortcuts[sho_rowdelete])+')'],
                  [],[state1],[{$ifdef FPC}@{$endif}dodeleterows],not bo1);
   bo1:= true;
  end;
 end;
 inherited;
end;

procedure tcustomgrid.setdatacols(const Value: tdatacols);
begin
 fdatacols.assign(Value);
end;

procedure tcustomgrid.setfixcols(const Value: tfixcols);
begin
 ffixcols.assign(Value);
end;

procedure tcustomgrid.setfixrows(const Value: tfixrows);
begin
 ffixrows.assign(Value);
end;

procedure tcustomgrid.setcol(const value: integer);
begin
 focuscell(makegridcoord(value,ffocusedcell.row));
end;

procedure tcustomgrid.setrow(const value: integer);
begin
 focuscell(makegridcoord(ffocusedcell.col,value));
end;

function tcustomgrid.visiblerow(const arow: integer): integer;
                 //returns index in visible rows, invalidaxis if not visible
begin
 if not (csdesigning in componentstate) then begin
  result:= fdatacols.frowstate.visiblerow(arow);
 end
 else begin
  result:= arow;
  if (arow <= 0) or (arow >= frowcount) then begin
   result:= invalidaxis;
  end;
 end;
end;

function tcustomgrid.createdatacols: tdatacols;
begin
 result:= tdatacols.create(self,tdatacol);
end;

function tcustomgrid.createfixcols: tfixcols;
begin
 result:= tfixcols.create(self);
end;

function tcustomgrid.createfixrows: tfixrows;
begin
 result:= tfixrows.create(self);
end;

procedure tcustomgrid.initcellinfo(var info: cellinfoty);
begin
 //dummy
end;

function tcustomgrid.ystep: integer;
begin
 internalupdatelayout;
 result:= fystep;
end;

procedure tcustomgrid.setdatarowheight(const value: integer);
begin
 if fdatarowheight <> value then begin
  if value < fdatarowheightmin then begin
   fdatarowheight:= fdatarowheightmin;
  end
  else begin
   if value > fdatarowheightmax then begin
    fdatarowheight:= fdatarowheightmax;
   end
   else begin
    fdatarowheight:= value;
   end;
  end;
  layoutchanged;
 end;
end;

procedure tcustomgrid.internalcreateframe;
begin
 tgridframe.create(iscrollframe(self),self,iautoscrollframe(self));
end;

procedure tcustomgrid.dorowcountchanged(const countbefore,newcount: integer);
begin
 layoutchanged;
 ffixcols.rowcountchanged(newcount);
 fdatacols.rowcountchanged(newcount);
 if canevent(tmethod(fonrowcountchanged)) then begin
  fonrowcountchanged(self);
 end;
end;

procedure tcustomgrid.dorowsdatachanged(const acell: gridcoordty; 
                                         const acount: integer);
var
 int1: integer;
 coord1: gridcoordty;
begin
 if canevent(tmethod(fonrowsdatachanged)) then begin
  fonrowsdatachanged(self,acell,acount);
 end;
 if canevent(tmethod(fonrowdatachanged)) then begin
  coord1.col:= acell.col;
  for int1:= acell.row to acell.row + acount-1 do begin
   coord1.row:= int1;
   fonrowdatachanged(self,coord1);
  end;
 end;
end;

procedure tcustomgrid.invalidatecell(const cell: gridcoordty);
begin
 internalupdatelayout;
 if (cell.row < 0) or 
      (cell.row >= ffirstvisiblerow) and (cell.row <= flastvisiblerow) then begin
  invalidaterect(cellrect(cell));
 end;
end;

procedure tcustomgrid.invalidatesinglecell(const cell: gridcoordty);
begin
 if (cell.row <> invalidaxis) and (cell.col <> invalidaxis) then begin
  invalidatecell(cell);
 end;
end;

procedure tcustomgrid.invalidaterow(const arow: integer);
begin
 invalidatecell(makegridcoord(invalidaxis,arow));
end;

procedure tcustomgrid.invalidatefocusedcell;
begin
 if (ffocusedcell.row >= 0) and (ffocusedcell.col >= 0) then begin
  invalidatecell(ffocusedcell);
 end;
end;

procedure tcustomgrid.cellchanged(const sender: tcol; const row: integer);
var
 bo1: boolean;
begin
 bo1:= (ffocusedcell.row >= 0) and (sender.colindex = ffocusedcell.col) and
     ((row < 0) or (row = ffocusedcell.row));
 if fupdating = 0 then begin
  if row >= 0 then begin
   invalidatecell(makegridcoord(sender.colindex,row));
  end
  else begin
   colchanged(sender);
  end;
  if bo1 then begin
   focusedcellchanged;
  end;
 end
 else begin
  if bo1 then begin
   include(fstate,gs_focusedcellchanged);
  end;
  if fnoinvalidate = 0 then begin
   if fstate * [gs_invalidated,gs_layoutvalid] = [gs_layoutvalid] then begin
    if high(finvalidatedcells) > 20 then begin
     include(fstate,gs_invalidated);
     finvalidatedcells:= nil;
    end
    else begin
     incrementarraylength(pointer(finvalidatedcells),typeinfo(gridcoordarty));
     finvalidatedcells[high(finvalidatedcells)]:=
                          makegridcoord(sender.colindex,row);
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.focusedcellchanged;
begin
 exclude(fstate,gs_focusedcellchanged);
end;

procedure tcustomgrid.colchanged(const sender: tcol);
var
 rect1: rectty;
begin
 if not (csloading in componentstate) then begin
  internalupdatelayout;
  rect1:= cellrect(makegridcoord(sender.colindex,0));
  rect1.y:= 0;
  rect1.cy:= tgridframe(fframe).fpaintrect.cy;
  invalidaterect(rect1);
 end;
end;

procedure tcustomgrid.rowchanged(const arow: integer);
var
 rect1: rectty;
begin
 internalupdatelayout;
 rect1:= cellrect(makegridcoord(0,arow));
 rect1.x:= 0;
 rect1.cx:= tgridframe(fframe).fpaintrect.cx;
 invalidaterect(rect1);
end;

procedure tcustomgrid.rowstatechanged(const arow: integer);
begin
 //dummy
end;

function tcustomgrid.cellatpos(const apos: pointty;
                                         out coord: gridcoordty): cellkindty;
var
 po1: pointty;
begin
 result:= ck_invalid;
 coord:= invalidcell;
 internalupdatelayout;
 with tgridframe(fframe) do begin
  if not pointinrect(apos,clientrect) then begin
   exit;
  end;
 end;
 po1.x:= apos.x - tgridframe(fframe).fi.innerframe.left;
 po1.y:= apos.y - tgridframe(fframe).fi.innerframe.top;

 with po1,coord do begin
  row:= ffixrows.rowatpos(y);
  if row < 0 then begin
   col:= ffixcols.colatpos(x);
   if col = 0 then begin
    col:= fdatacols.colatpos(x,false);
    if col < 0 then begin
     dec(x,fscrollrect.x+ffixcols.ffirstsize+ffirstnohscroll);
     col:= fdatacols.colatpos(x);
    end;
   if col >= 0 then begin
     result:= ck_fixrow;
    end;
   end
   else begin
    result:= ck_fixcolrow;
   end;
  end
  else begin //datarows
   dec(y,fscrollrect.y+ffixrows.ffirstsize);
   row:= rowatpos(y);
   col:= ffixcols.colatpos(x);
   if col = 0 then begin
    col:= fdatacols.colatpos(x,false);
    if col < 0 then begin
     dec(x,fscrollrect.x+ffixcols.ffirstsize+ffirstnohscroll);
     col:= fdatacols.colatpos(x);
    end;
    if (col >= 0) and (row >= 0) then begin
     result:= ck_data;
    end;
   end
   else begin
    if row >= 0 then begin
     result:= ck_fixcol;
    end;
   end;
  end;
 end;
end;

function tcustomgrid.cellatpos(const apos: pointty): gridcoordty;
begin
 cellatpos(apos,result);
end;

function tcustomgrid.rowatpos(y: integer): integer;
var
 int1: integer;
begin
 result:= invalidaxis;
 if y >= 0 then begin
  if og_rowheight in foptionsgrid then begin
   result:= fdatacols.frowstate.rowindex(y);
  end
  else begin
   result:= fdatacols.frowstate.visiblerowtoindex(y div fystep);
  end;
 end;
end;

procedure tcustomgrid.firstcellclick(const cell: gridcoordty;
                                              const info: mouseeventinfoty);
begin
 //dummy
end;

function tcustomgrid.getzebrastart: integer;
begin
 result:= fzebra_start;
end;

function tcustomgrid.getnumoffset: integer;
begin
 result:= 0;
end;

procedure tcustomgrid.mouseevent(var info: mouseeventinfoty);
begin
 tgridframe(fframe).mouseevent(info);
 inherited;
end;

function tcustomgrid.actualcursor(const apos: pointty): cursorshapety;
var
 prop1: tgridprop;
begin
 prop1:= gridprop(fmousecell);
 if prop1 <> nil then begin
  result:= prop1.cursor;
  if result <> cr_default then begin
   exit;
  end;
 end;
  
 with fmousecell do begin
  if (row >= 0) and (col >= 0) and (col < datacols.count) then begin
   result:= datacols[fmousecell.col].getcursor(fmousecell.row,flastcellzone);
  end
  else begin
   result:= inherited actualcursor(apos);
  end;
 end;
end;

procedure tcustomgrid.clientmouseevent(var info: mouseeventinfoty);

 procedure mouseleavecol;
 var
  info1: mouseeventinfoty;
 begin
  if fmouseeventcol >= 0 then begin
   if fmouseeventcol < fdatacols.count then begin
    fillchar(info1,sizeof(info1),0);
    info1.eventkind:= ek_clientmouseleave;
    fdatacols[fmouseeventcol].clientmouseevent(makegridcoord(fmouseeventcol,-1),
                       info1);
    fmouseeventcol:= -1;
   end;
  end;
 end;

var
 cellkind: cellkindty;

 procedure checkfocuscell;
 
 function getfocusact(const canselect: boolean): focuscellactionty;
 begin
  result:= fca_focusin;
  if canselect then begin
   if info.shiftstate * keyshiftstatesmask = [ss_shift] then begin
    result:= fca_selectend;
   end
   else begin
    if info.eventkind = ek_buttonpress then begin
     result:= fca_reverse;
    end;
   end;
  end;
 end;
 
 var
  po1: pointty;
  action: focuscellactionty;
  bo1,bo2: boolean;
  cell1: gridcoordty;
  rowfocus: boolean;
 begin      //checkfocuscell
  po1:= fscrollrect.pos;
  action:= fca_focusin;
  case cellkind of
   ck_data: begin
    if not (gs_mousecellredirected in fstate) then begin
     cell1:= fmousecell;
     cell1.col:= mergestart(cell1.col,cell1.row);
     bo2:= fdatacols[cell1.col].canfocus(info.button,info.shiftstate,rowfocus);
     if not bo2 then begin
      cell1.col:= mergestart(ffocusedcell.col,cell1.row); //try to focus mouse row
      if (cell1.col < 0) or (co_nofocus in fdatacols[cell1.col].options) then begin
       cell1.col:= nextfocusablecol(0,false,cell1.row);
      end;
     end;
     if (cell1.col >= 0) and 
                fdatacols[cell1.col].canfocus(info.button,info.shiftstate,bo1) then begin
      bo1:= not gridcoordisequal(cell1,ffocusedcell);
      if (info.shiftstate * [ss_left,ss_middle,ss_right] = [ss_left])
                  {(info.button = mb_left)} and
             (co_mouseselect in fdatacols[cell1.col].foptions) then begin
       if (info.shiftstate * keyshiftstatesmask = [ss_shift]) then begin
        action:= fca_selectend;
       end
       else begin
        if info.shiftstate * keyshiftstatesmask = [ss_ctrl] then begin
         if (info.button = mb_left) or (cell1.col <> ffocusedcell.col) or
                   (cell1.row <> ffocusedcell.row) then begin
          action:= fca_reverse;
         end;
        end;
       end;
      end
      else begin
       if (action = fca_focusin) and (ss_shift in info.shiftstate) then begin
        action:= fca_focusinshift;
       end;
      end;
      focuscell(cell1,action,scm_cell,not bo2);
      if not bo2 then begin
       showcell(fmousecell);
      end
      else begin
       if bo1 then begin
        firstcellclick(cell1,info);
       end;
      end;
     end
     else begin
      if (fmousecell.row >= 0) and rowfocus then begin
       focuscell(makegridcoord(invalidaxis,fmousecell.row));
      end
      else begin
       showcell(fmousecell);
      end;
     end;
    end;
   end;
   ck_fixcol: begin
    with fixcols[fmousecell.col] do begin
     if (fco_mousefocus in options) then begin
      if (fmousecell.row <> ffocusedcell.row) or 
                             (info.eventkind = ek_buttonpress) then begin
       focusrow(fmousecell.row,getfocusact(fco_mouseselect in options),scm_row);
//       focuscell(makegridcoord(nextfocusablecol(col,false,fmousecell.row),
//                               fmousecell.row),
//                getfocusact(fco_mouseselect in options),scm_row);
      end;
     end
     else begin
      if (info.eventkind = ek_buttonpress) and 
           (fco_mouseselect in fixcols[fmousecell.col].options) then begin
       fdatacols.selected[fmousecell]:= not fdatacols.selected[fmousecell];
      end;
      showcell(fmousecell);
     end;
    end;
   end;
   ck_fixrow: begin
    with fixrows[fmousecell.row] do begin
     if (fro_mousefocus in options) then begin
      if (fmousecell.col <> ffocusedcell.col) or 
                   (info.eventkind = ek_buttonpress) then begin
       focuscell(makegridcoord(fmousecell.col,row),
                            getfocusact(fro_mouseselect in options),scm_col);
      end;
     end
     else begin
      if (info.eventkind = ek_buttonpress) and 
         (fro_mouseselect in fixrows[fmousecell.row].options) then begin
       fdatacols.selected[fmousecell]:= not fdatacols.selected[fmousecell];
      end;
      showcell(fmousecell);
     end;
    end;
   end;
   ck_fixcolrow: begin
    if (info.eventkind = ek_buttonpress) and 
         (fro_mouseselect in fixrows[fmousecell.row].options) and
     (fco_mouseselect in fixcols[fmousecell.col].options) then begin
     fdatacols.selected[fmousecell]:= not fdatacols.selected[fmousecell];
    end;
   end;
  end;
  addpoint1(info.pos,subpoint(tgridframe(fframe).scrollpos,po1));
               //shift mouse with grid;
 end;

 procedure checkrepeater(const drag: boolean);
 begin     
  with info do begin
   if gs_cellclicked in fstate then begin
    if drag then begin
     frepeataction:= fca_none;
    end
    else begin
     if ss_shift in shiftstate then begin
      if co_mouseselect in fdatacols[ffocusedcell.col].foptions then begin
       frepeataction:= fca_selectend;
      end
      else begin
       frepeataction:= fca_focusinshift;
      end;
     end
     else begin
      frepeataction:= fca_focusinrepeater;
     end;
    end;
    if pos.y < fdatarect.y - mousescrolldist then begin
     if (ffocusedcell.col >= 0) and 
              (co_mousescrollrow in datacols[ffocusedcell.col].options) then begin
      startrepeater(gs_scrolldown,fastrepeat);
     end;
    end
    else begin
     if pos.y - mousescrolldist >= fdatarect.y + fdatarect.cy then begin
      if (ffocusedcell.col >= 0) and 
              (co_mousescrollrow in datacols[ffocusedcell.col].options) then begin
       startrepeater(gs_scrollup,fastrepeat);
      end;
     end
     else begin
      if pos.x < fdatarect.x - mousescrolldist then begin
       if og_mousescrollcol in foptionsgrid then begin
        startrepeater(gs_scrollleft,slowrepeat);
       end;
      end
      else begin
       if pos.x - mousescrolldist >= fdatarect.x + fdatarect.cx then begin
        if og_mousescrollcol in foptionsgrid then begin
         startrepeater(gs_scrollright,slowrepeat);
        end;
       end
       else begin
        killrepeater;
       end;
      end;
     end;
    end;
   end;
  end;
 end;

var
 coord1: gridcoordty;
 str1: msestring;
 hintinfo: hintinfoty;
 mousewidgetbefore: twidget;
 bo1: boolean;

begin
 inherited;
// fobjectpicker.mouseevent(info);
 if not (es_processed in info.eventstate) then begin
  fobjectpicker.mouseevent(info);
  if (info.eventkind = ek_buttonpress) and 
             not(csdesigning in componentstate) and
            (fobjectpicker.objects <> nil) and
            (pickobjectkindty(fobjectpicker.objects[0] mod pickobjectstep) in 
                                      [pok_datacol,pok_datarow]) then begin
   exclude(info.eventstate,es_processed); //allow mouse row selecting
  end;
  if not (es_processed in info.eventstate) then begin
   fdragcontroller.clientmouseevent(info);
  end;
 end;
 if not(csdesigning in componentstate) then begin
  if es_processed in info.eventstate then begin
   if info.eventkind in [ek_mousemove,ek_mousepark] then begin
    checkrepeater(true);
   end;
  end
  else begin                           
   with info do begin
    if eventkind = ek_buttonpress then begin
     checkreautoappend;
    end;
    if eventkind in mouseposevents then  begin
     coord1:= fmousecell;
     cellkind:= cellatpos(pos,fmousecell);
     if (coord1.col <> fmousecell.col) or 
             (coord1.row <> fmousecell.row) then begin
      if isvalidcell(coord1) then begin
       cellmouseevent(coord1,info,nil,cek_mouseleave);
      end;
      if (fmousecell.row <> invalidaxis) and (fmousecell.col <> invalidaxis) then begin
       cellmouseevent(fmousecell,info,nil,cek_mouseenter);
      end;
     end;
     if (fmousecell.row <> fmouseparkcell.row) or 
                               (fmousecell.col <> fmouseparkcell.col) then begin
      fmouseparkcell:= invalidcell;
     end;
    end
    else begin
     cellkind:= ck_invalid;
    end;
    case eventkind of
     ek_clientmouseenter: begin
      include(fstate,gs_mouseentered);
     end;
     ek_clientmouseleave: begin
      if isvalidcell(fmousecell) then begin
       cellmouseevent(fmousecell,info,nil,cek_mouseleave);
      end;
      fmousecell:= invalidcell;
      fmouseparkcell:= invalidcell;
     end;
     ek_buttonpress: begin
      mousewidgetbefore:= application.mousewidget;
      checkfocuscell;
      if (mousewidgetbefore = application.mousewidget) and 
                       //not interrupted by beginmodal
         (button = mb_left)
                {and isdatacell(ffocusedcell) and 
               gridcoordisequal(fmousecell,ffocusedcell)} then begin
       fclickedcellbefore:= fclickedcell;
       fclickedcell:= fmousecell;
       if isdatacell(fmousecell) then begin
        include(fstate,gs_cellclicked);
       end;
      end;                
     end;
     ek_mousemove,ek_mousepark: begin
      if not (es_child in info.eventstate) then begin
       if cellkind = ck_data then begin
        application.widgetcursorshape:= 
              datacols[fmousecell.col].getcursor(fmousecell.row,flastcellzone);
       end
       else begin
        application.widgetcursorshape:= cr_default{cursor};
        if (eventkind = ek_mousepark) and (cellkind = ck_fixrow) and 
               ((fmousecell.row <> fmouseparkcell.row) or 
                (fmousecell.col <> fmouseparkcell.col)) then begin
         fmouseparkcell:= fmousecell;
         str1:= '';
         with ffixrows[fmouseparkcell.row] do begin
          if fmouseparkcell.col >= 0 then begin
           if fmouseparkcell.col < fcaptions.count then begin
            str1:= fcaptions[fmouseparkcell.col].hint;
           end;
          end
          else begin
           if -fmouseparkcell.row <= fcaptionsfix.count then begin
            str1:= fcaptionsfix[fmouseparkcell.col].hint;
           end;
          end;
         end;
         if (str1 <> '') and application.active then begin
          application.inithintinfo(hintinfo,self);
          hintinfo.caption:= str1;
          application.showhint(self,hintinfo);
         end;
        end;
       end;
       if (info.shiftstate * [ss_left,ss_middle,ss_right] = [ss_left]) and
          (ws_lclicked in fwidgetstate) then begin
        checkfocuscell;
       end
       else begin
        if (shiftstate = []) and (cellkind = ck_data) and
                 (co_mousemovefocus in fdatacols[fmousecell.col].foptions) then begin
         if gs_mouseentered in fstate then begin
          exclude(fstate,gs_mouseentered);
          fmouserefpos:= info.pos;
         end;
         if (distance(fmouserefpos,info.pos) > 3) and active then begin
          fmouserefpos:= info.pos;
          if not fdatacols[fmousecell.col].canfocus(info.button,info.shiftstate,
                                                    bo1) then begin
           showcell(fmousecell);
          end
          else begin
           focuscell(fmousecell);
          end;
         end;
        end;
       end;
      end;
      checkrepeater(false);
     end;
    end;
    if cellkind = ck_data then begin
     if fmousecell.col <> fmouseeventcol then begin
      mouseleavecol;
     end;
     fmouseeventcol:= fmousecell.col;
     if not (es_processed in info.eventstate) and 
               (fmousecell.col >= 0) then begin //ek_clientmouseleave otherwise
      coord1:= ffocusedcell;
      fdatacols[fmousecell.col].clientmouseevent(fmousecell,info);
      if not gridcoordisequal(ffocusedcell,coord1) then begin
       include(fstate,gs_mousecellredirected);
      end;
     end;
    end
    else begin
     mouseleavecol;
     if not (es_processed in info.eventstate) then begin
      cellmouseevent(fmousecell,info);
     end;
    end;
   end;
  end;
 end;
 if info.eventkind = ek_buttonrelease then begin
  if gs_cellclicked in fstate then begin
   killrepeater;
  end;
  fstate:= fstate - [gs_mousecellredirected,gs_cellclicked];
 end;
end;

procedure tcustomgrid.docellevent(var info: celleventinfoty);
begin
 with info do begin
  grid:= self;
  if canevent(tmethod(foncellevent)) then begin
   foncellevent(self,info);
  end;
  if info.cell.col >= 0 then begin
   datacols[info.cell.col].docellevent(info);
  end;
 {$ifdef mse_with_ifi}
  if fifilink <> nil then begin
   fifilink.controller.docellevent(ificelleventinfoty(info));
  end;
 {$endif}
  if eventkind = cek_mousepark then begin
   if (fmouseparkcell.row <> cell.row) or
                     (fmouseparkcell.col <> cell.col) then begin
    fmouseparkcell:= cell;
    if isdatacell(cell) then begin
     eventkind:= cek_firstmousepark;
     docellevent(info);
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.cellmouseevent(const acell: gridcoordty; 
                           var info: mouseeventinfoty;
                           const acellinfopo: pcelleventinfoty = nil;
                           const aeventkind: celleventkindty = cek_none);
var
 cellinfo: celleventinfoty;
 po1: pointty;
 cellinfopo: pcelleventinfoty;
begin
 cellinfopo:= acellinfopo;
 if cellinfopo = nil then begin
  cellinfopo:= @cellinfo;
 end;
 fillchar(cellinfopo^,sizeof(cellinfo),0);
 with cellinfopo^ do begin
  mouseeventinfopo:= @info;
  cell:= acell;
  grid:= self;
  gridmousepos:= info.pos;
  eventkind:= aeventkind;
  if eventkind = cek_none then begin
   case info.eventkind of
    ek_mousemove: eventkind:= cek_mousemove;
    ek_mousepark: eventkind:= cek_mousepark;
    ek_buttonpress: eventkind:= cek_buttonpress;
    ek_buttonrelease: eventkind:= cek_buttonrelease;
   end;
  end;
  if (acellinfopo = nil) and (eventkind <> cek_none) then begin
   if eventkind in mousecellevents then begin
    zone:= cz_default;
   end;
   po1:= cellrect(cellinfo.cell).pos;
   try
    subpoint1(info.pos,po1);
    if (eventkind = cek_buttonrelease) and (cell.row < 0) and 
                                  (cell.row <> invalidaxis) then begin
     docellevent(cellinfopo^);
     if not (es_processed in mouseeventinfopo^.eventstate) then begin
      fixrows[cell.row].buttoncellevent(cellinfopo^);
     end;
    end
    else begin     
     docellevent(cellinfopo^);
    end;
   finally
    addpoint1(info.pos,po1);
   end;
  end;
 end;
end;

procedure tcustomgrid.dofocusedcellposchanged;
begin
 //dummy
end;

function tcustomgrid.isfirstrow: boolean;
begin
 result:= (ffocusedcell.row <= 0);
end;

function tcustomgrid.islastrow: boolean;
begin
 result:= (ffocusedcell.row < 0) or (ffocusedcell.row = rowhigh);
end;

function tcustomgrid.selectcell(const cell: gridcoordty;
                                const amode: cellselectmodety;
                                const checkmultiselect: boolean = false): boolean;
 //calls onselectcell
var
 info: celleventinfoty;
 bo1: boolean;
 int1: integer;
begin
 initeventinfo(cell,cek_select,info);
 info.accept:= true;
 case amode of 
  csm_reverse: begin
   info.selected:= not fdatacols.selected[cell];
  end;
  csm_select: begin
   info.selected:= true;
  end;
  else begin
   info.selected:= false;
  end;
 end;
 if (amode = csm_reverse) or 
               (cell.row = invalidaxis) or (cell.col = invalidaxis) or 
               (info.selected <> fdatacols.selected[cell]) then begin
  bo1:= info.selected;
  docellevent(info);
  result:= info.accept;
  if result then begin
   bo1:= bo1 and checkmultiselect;
   if bo1 then begin
    beginupdate;
   end;
   try
    if bo1 then begin
     for int1:= 0 to fdatacols.count - 1 do begin
      with tdatacol(fdatacols.fitems[int1]) do begin
       if not (co_multiselect in foptions) then begin
        selected[invalidaxis]:= false;
       end;
      end;
     end;
    end;
    if (cell.col >= 0) and (co_rowselect in fdatacols[cell.col].foptions) then begin
     fdatacols.selected[makegridcoord(invalidaxis,cell.row)]:= info.selected;
    end
    else begin
     fdatacols.selected[cell]:= info.selected;
    end;
   finally
    if bo1 then begin
     endupdate;
    end;
   end;
  end;
 end
 else begin
  result:= true;
 end;
end;

procedure tcustomgrid.beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty);
begin
 //dummy
end;

procedure tcustomgrid.afterfocuscell(const cellbefore: gridcoordty;
                             const selectaction: focuscellactionty);
var
 info: celleventinfoty;
begin
 initeventinfo(ffocusedcell,cek_focusedcellchanged,info);
 info.cellbefore:= cellbefore;
 info.newcell:= ffocusedcell;
 info.selectaction:= selectaction;
 docellevent(info);
end;

function tcustomgrid.focuscell(cell: gridcoordty;
          selectaction: focuscellactionty = fca_focusin;
          const selectmode: selectcellmodety = scm_cell;
          const noshowcell: boolean = false): boolean;

 function isappend(const arow: integer): boolean;
 begin
  result:= not (gs_isdb in fstate) and 
      ((og_autoappend in foptionsgrid) and (arow >= frowcount) and 
                                                         (frowcount <> 0) or
       (arow = 0) and (frowcount = 0) and (og_autofirstrow in foptionsgrid));
 end;
 
 procedure doselectaction;

  procedure startanchors;
  begin
   fstartanchor:= cell;
   fendanchor:= invalidcell;
  end;

  procedure changeselectedrange(rows: boolean);
  type
   rectaccessty = record pos: integer; dummy: integer; count: integer end;
  var
   rect1: gridrectty;
   int1: integer;
   po1,po3: pinteger;
   po2: ^rectaccessty;
  begin
   rect1:= self.getselectedrange;
   if rows then begin
    po1:= @cell.row;
    po2:= @rect1.row;
    po3:= @fstartanchor.row;
   end
   else begin
    po1:= @cell.col;
    po2:= @rect1.col;
    po3:= @fstartanchor.col;
   end;
   if po1^ < po2^.pos then begin
    po2^.count:= po2^.pos - po1^;
    po2^.pos:= po1^;
    fdatacols.setselectedrange(rect1,true,true,true);
   end
   else begin
    if po1^ >= po3^ then begin //right side
     int1:= po1^ - po2^.pos - po2^.count;
     if int1 >= 0 then begin
      po2^.pos:= po2^.pos + po2^.count;
      po2^.count:= int1 + 1;
      fdatacols.setselectedrange(rect1,true,true,true);
     end
     else begin
      po2^.pos:= po1^ + 1;
      po2^.count:= -int1 - 1;
      fdatacols.setselectedrange(rect1,false,true,true);
     end;
    end
    else begin //left side
     int1:= po2^.pos - po1^;
     if int1 >= 0 then begin
      po2^.pos:= po1^;
      po2^.count:= int1;
      fdatacols.setselectedrange(rect1,true,true,true);
     end
     else begin
      po2^.count:= -int1;
      fdatacols.setselectedrange(rect1,false,true,true);
     end;
    end;
   end;
  end;
  
  procedure doselectcell(const mode: cellselectmodety);
  begin
   case selectmode of
    scm_row: begin
     selectcell(makegridcoord(invalidaxis,cell.row),mode,true);
    end;
    scm_col: begin
     selectcell(makegridcoord(cell.col,invalidaxis),mode,true);
    end;
    else begin
     selectcell(cell,mode,true);
    end;
   end;      
  end;

var
 cells,celle: gridcoordty;
 rect1: gridrectty;
 int1: integer;
 
 begin //doselectaction
  beginupdate;
  try
   case selectaction of
    fca_entergrid,fca_focusin,fca_focusinshift,fca_focusinrepeater,
               fca_focusinforce,fca_setfocusedcell: begin
     if (selectaction <> fca_entergrid) then begin
      if not (og_noresetselect in foptionsgrid) then begin
       fdatacols.selected[invalidcell]:= false;
      end;
     end;
     startanchors;
     if isdatacell(cell) and (co_focusselect in fdatacols[cell.col].foptions) then begin
      doselectcell(csm_select);
     end;
    end;
    fca_reverse: begin
     doselectcell(csm_reverse);
     startanchors;
    end;
    fca_selectstart: begin
     fdatacols.selected[invalidcell]:= false;
     doselectcell(csm_select);
     startanchors;
    end;
    fca_selectend: begin
     getselectedrange; //ev. adjust startanchor to rowcount
     if fstartanchor.col < 0 then begin
      fstartanchor:= ffocusedcell;
     end;
     if fstartanchor.col >= 0 then begin
      cells:= fstartanchor;
      celle:= cell;
      case selectmode of
       scm_row: begin
        cells.col:= 0;
        celle.col:= fdatacols.count - 1;
       end;
       scm_col: begin
        cells.row:= 0;
        celle.row:= rowhigh;
       end;
      end;
      if fendanchor.col >= 0 then begin
       case selectmode of
        scm_row: begin
         celle.col:= cells.col;
        end;
        scm_col: begin
         celle.row:= cells.row;
        end;
       end;
       if gs_islist in fstate then begin
        fdatacols.changeselectedrange(fstartanchor,fendanchor,cell,true);
       end
       else begin //todo: optimize for selectmode <> scm_cell
        if (selectmode <> scm_cell) or ((cell.col >= fstartanchor.col) xor 
                    (fendanchor.col >= fstartanchor.col)) or
                                     ((cell.row >= fstartanchor.row) xor 
                   (fendanchor.row >= fstartanchor.row)) then begin
         rect1:= makegridrect(celle,cells);
         fdatacols.selected[invalidcell]:= false;
         fdatacols.setselectedrange(rect1,true,true,true);
         case selectmode of
          scm_row: begin
           beginupdate;
           rect1.col:= invalidaxis;
           for int1:= rect1.rowcount - 1 downto 0 do begin
            fdatacols.selected[rect1.pos]:= true;
            inc(rect1.row);
           end;  
           endupdate;
          end;
          scm_col: begin
           beginupdate;
           rect1.row:= invalidaxis;
           for int1:= rect1.colcount - 1 downto 0 do begin
            fdatacols.selected[rect1.pos]:= true;
            inc(rect1.col);
           end;  
           endupdate;
          end;
         end;
        end
        else begin
         changeselectedrange(false);
         fendanchor.col:= cell.col;
         changeselectedrange(true);
        end;
       end;
      end
      else begin
       if celle.col < cells.col then begin
        dec(celle.col);
       end
       else begin
        inc(celle.col);
       end;
       if celle.row < cells.row then begin
        dec(celle.row);
       end
       else begin
        inc(celle.row);
       end;
       fdatacols.setselectedrange(cells,celle,true,true,true);
      end;
     end;
     fendanchor:= cell;
    end;
   end;
  finally
   endupdate(true);
  end;
 end;

var
 focuscount: integer;
 coord1,coord2: gridcoordty;
 bo1: boolean;
 int1: integer;
 rect1: rectty;
 nullchecklocked: boolean;
 cellbefore: gridcoordty;
 
begin     //focuscell
 if selectaction <> fca_exitgrid then begin
  if (cell.row > invalidaxis) and (cell.col > invalidaxis) then begin
   rect1:= cellrect(cell);
   with rect1 do begin
    bo1:= (cell.row >= 0);
    if bo1 then begin
     int1:= fdatarect.x - x;
     bo1:= (int1 > 0) and (int1 < fdatarect.cx);
    end;
    if not bo1 then begin
     bo1:= (cell.col >= 0);
     if bo1 then begin
      int1:= fdatarect.y - y;
      bo1:= (int1 > 0) and (int1 < fdatarect.cy);
     end;
    end;
    if bo1 then begin
     update; //scrolling needed, update pending paintings with old focused cell
    end;
   end;
  end;
 end;
 inc(ffocuscount);
 focuscount:= ffocuscount;
 beforefocuscell(cell,selectaction);
 if focuscount <> ffocuscount then begin
  exit;
 end;
 result:= false;
 exclude(fstate,gs_mousecellredirected);
 nullchecklocked:= false;
 if ffocusedcell.row = cell.row then begin
  nullchecklocked:= true;
  beginnonullcheck;
 end;
 try
  if (fnocheckvalue = 0) and not (gs_rowremoving in fstate) then begin
   int1:= ffocusedcell.row;
   if ((cell.row <> ffocusedcell.row) or (cell.col <> ffocusedcell.col) or 
           (selectaction = fca_focusinforce)) and           
           not docheckcellvalue or (focuscount <> ffocuscount) then begin
    exit;
   end;
   if cell.row = int1 then begin
    cell.row:= ffocusedcell.row;       //follow possible change by sort
   end;
   if ((cell.row <> ffocusedcell.row) or (selectaction = fca_focusinforce)) and 
                     (ffocusedcell.row >= 0) and container.entered and
            not container.canclose(window.focusedwidget) then begin
    exit;        //for not null check in twidgetgrid
   end;
  end;
  if (selectaction in [fca_focusin,fca_focusinrepeater,fca_focusinforce]) and 
      ((cell.col < 0) or  not fdatacols[cell.col].canfocus(mb_none,[],bo1)) then begin
   selectaction:= fca_setfocusedcell;
  end;
  if selectaction = fca_entergrid then begin
   if cell.row < 0 then begin
    cell.row:= 0;
   end;
   if cell.col < 0 then begin
    cell.col:= 0;
   end;
   cell.col:= nextfocusablecol(cell.col,false,cell.row);
   if (gs_hasactiverowcolor in fstate) and (cell.row < frowcount) then begin
    invalidaterow(cell.row);
   end;
  end;
  if cell.row < 0 then begin
   cell.row:= invalidaxis;
  end;
  if cell.col < 0 then begin
   cell.col:= invalidaxis;
  end;
  if (cell.row >= 0) and (cell.col >= 0) then begin
   if cell.col >= fdatacols.count then begin
    cell.col:= fdatacols.count - 1;
    if cell.col < 0 then begin
     exit;
    end;
   end;
   if (cell.row >= frowcount) and not isappend(cell.row) then begin
    cell.row:= frowcount - 1;
    if cell.row < 0 then begin
     if selectaction = fca_entergrid then begin
      cell.row:= invalidaxis;
     end
     else begin
      exit;
     end;
    end;
   end;
   cell.col:= mergestart(cell.col,cell.row);
  end;
  bo1:= ((cell.col <> invalidaxis) or (cell.row <> invalidaxis)) and 
                                not noshowcell;
  if (cell.col <> ffocusedcell.col) or (cell.row <> ffocusedcell.row) or
        (selectaction in [fca_entergrid,fca_focusinforce]) or 
        (gs_restorerow in fstate) then begin
   exclude(fstate,gs_restorerow);
   coord1:= ffocusedcell;
   if (selectaction <> fca_entergrid) and isdatacell(coord1) then begin
    include(fstate,gs_cellexiting);
    fdatacols[coord1.col].internaldoexitcell(coord1,cell,selectaction);
    exclude(fstate,gs_cellexiting);
    if ffocuscount <> focuscount then begin
     exit;
    end;
   end
   else begin
    coord1:= invalidcell;
   end;
 
   int1:= cell.row - ffocusedcell.row;
   if (int1 <> 0) or (selectaction = fca_focusinforce) then begin
    checksort;
    if cell.row >= 0 then begin
     if (cell.row >= 0) and (ffocusedcell.row >= 0) then begin
      cell.row:= ffocusedcell.row + int1;
      if cell.row < 0 then begin
       cell.row:= 0;
      end;
      if cell.row > frowcount then begin
       cell.row:= frowcount;
      end;
     end;
    end;
   end;
    
   if isappend(cell.row) then begin
    if (frowcount = 0) or (og_appendempty in foptionsgrid) or
            not fdatacols.rowempty(frowcount-1) then begin
     cell.row:= frowcount;
     if fdatacols.fnewrowcol >= 0 then begin
      cell.col:= fdatacols.fnewrowcol;
     end;
     insertrow(frowcount);
    end
    else begin
     factiverow:= coord1.row;
     include(fstate,gs_restorerow);
     focuscell(coord1,selectaction); //restore previous row
     exit;
    end;
   end
   else begin
    if cell.row >= frowcount then begin
     cell.row:= frowcount - 1;
     if cell.row < 0 then begin
      cell.row:= invalidaxis;
     end;
    end;
   end;
   cellbefore:= ffocusedcell; 
   if (selectaction = fca_exitgrid) or ((coord1.row >= 0) and
          (coord1.row >= frowcount-1) and (cell.row < coord1.row)) then begin
    int1:= ffocusedcell.row;
    ffocusedcell.row:= invalidaxis;
    removeappendedrow;
    if int1 = frowcount then begin
     dec(int1);
    end;
    if (int1 >= 0) and not ((selectaction = fca_exitgrid) and 
                                 (gs_rowremoving in fstate)) then begin
     ffocusedcell.row:= int1;
    end;
   end;
   if not (selectaction in [fca_exitgrid,fca_entergrid]) then begin
    ffocusedcell:= invalidcell;
   end;
   if selectaction = fca_exitgrid then begin
    factiverow:= ffocusedcell.row;
    for int1:= 0 to fdatacols.count - 1 do begin
     if co_resetselectonexit in fdatacols[int1].foptions then begin
      fdatacols.selected[makegridcoord(int1,-1)]:= false;
     end;
    end;
   end
   else begin
    doselectaction;
   end;
   if selectaction <> fca_exitgrid then begin
    ffocusedcell:= cell;
   end;
   if bo1 then begin
    showcell(cell);
   end;
   if isdatacell(cell) then begin
    checkrowreadonlystate;
    coord2:= cell;
    fdatacols[cell.col].internaldoentercell(coord1,cell,selectaction);
    if ffocuscount <> focuscount then begin
     exit;
    end;
    if ((cell.col <> coord2.col) or (cell.row <> coord2.row)) then begin
     focuscell(cell,selectaction);
     exit;
    end;
   end;
//   else begin
   if (gs_hasactiverowcolor in fstate) and 
            (ffocusedcell.row <> cellbefore.row) then begin
    if cellbefore.row >= 0 then begin
     invalidaterow(cellbefore.row);
    end;
    if ffocusedcell.row >= 0 then begin
     invalidaterow(ffocusedcell.row);
    end;
   end;
//   end;
  end
  else begin
   cellbefore:= ffocusedcell;
   if bo1 then begin
    showcell(cell);
   end;
   if not (selectaction in [fca_focusin,fca_focusinrepeater,
                            fca_setfocusedcell,fca_none]) then begin
    doselectaction;
   end;
  end;
 finally
  if nullchecklocked then begin
   endnonullcheck;
  end;
 end;
 afterfocuscell(cellbefore,selectaction); 
 flastcol:= ffocusedcell.col;
 result:= true;
end;

function tcustomgrid.defocuscell: boolean;
begin
 result:= focuscell(invalidcell{,fca_none});
end;

function tcustomgrid.defocusrow: boolean;
begin
 result:= focuscell(makegridcoord(ffocusedcell.col,invalidaxis){,fca_none});
end;

function tcustomgrid.focusedcellvalid: boolean;
begin
 result:= (ffocusedcell.col >= 0) and (ffocusedcell.row >= 0) and 
            not (gs_cellexiting in fstate);
end;

function tcustomgrid.scrollingcol: boolean;
          //true if focusedcolvalid and no co_nohscroll
begin
 result:= (ffocusedcell.col >= 0) and
           not (co_nohscroll in fdatacols[ffocusedcell.col].foptions);
end;

function tcustomgrid.noscrollingcol: boolean;
          //true if focusedcolvalid and co_nohscroll
begin
 result:= (ffocusedcell.col >= 0) and
            (co_nohscroll in fdatacols[ffocusedcell.col].foptions);
end;

function tcustomgrid.isautoappend: boolean; 
      //true if last row is auto appended
begin
 result:= not (gs_isdb in fstate) and (frowcount > 0) and 
 ((frowcount = 1) and (og_autofirstrow in foptionsgrid) or
      (foptionsgrid * [og_autoappend,og_appendempty] = [og_autoappend])
     ) and fdatacols.rowempty(frowcount - 1);
end;

function tcustomgrid.gridprop(const coord: gridcoordty): tgridprop;  //nil if none
begin
 result:= nil;
 with coord do begin
  if row < 0 then begin
   if row >= - ffixrows.count then begin
    result:= tgridprop(ffixrows.fitems[-1-row]);
    exit;
   end;
  end;
  if {(row = invalidaxis) or} (row >= 0) and (row < frowcount) then begin
   if col < 0 then begin
    if col >= -fixcols.count then begin
     result:= tgridprop(ffixcols.fitems[-1-col]);
     exit;
    end;
   end
   else begin
    if col < fdatacols.count then begin
     result:= tgridprop(fdatacols.fitems[col]);
     exit;
    end;
   end;
  end;
 end;
end;

function tcustomgrid.isdatacell(const coord: gridcoordty): boolean;
begin
 with coord do begin
  result:= (col >= 0) and (row >= 0) and
        (col < fdatacols.count) and (row < frowcount);
 end;
end;

function tcustomgrid.isvalidcell(const coord: gridcoordty): boolean;
begin
 with coord do begin
  result:= (col < fdatacols.count) and (col >= -ffixcols.count) and
           (row < frowcount) and (row >= -ffixrows.count);
 end;
end;

function tcustomgrid.isfixrow(const coord: gridcoordty): boolean;
begin
 with coord do begin
  result:= (row < 0) and (fixrows.count + row >= 0);
 end;
end;

function tcustomgrid.isfixcol(const coord: gridcoordty): boolean;
begin
 with coord do begin
  result:= (col < 0) and (fixcols.count + col >= 0);
 end;
end;

procedure tcustomgrid.checkdatacell(const coord: gridcoordty);
begin
 if not isdatacell(coord) then begin
  datacellerror(coord);
 end;
end;

procedure tcustomgrid.datacellerror(const coord: gridcoordty);
begin
 error(gre_invaliddatacell,gridcoordtotext(coord));
end;

procedure tcustomgrid.error(aerror: griderrorty; text: string);
begin
 if aerror <> gre_ok then begin
  if text <> '' then begin
   raise tgridexception.create(errorstrings[aerror]+' '+text+'.');
  end
  else begin
   raise tgridexception.create(errorstrings[aerror]+'.');
  end;
 end;
end;

procedure tcustomgrid.indexerror(row: boolean; index: integer; text: string);
begin
 if row then begin
  error(gre_colindex,text+' '+inttostr(index));
 end
 else begin
  error(gre_rowindex,text+' '+inttostr(index));
 end;
end;

procedure tcustomgrid.scrollrows(step: integer);
begin
 if canevent(tmethod(fonscrollrows)) then begin
  fonscrollrows(self,step);
 end;
 tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,
       makepoint(0,ystep*step));
end;

procedure tcustomgrid.scrollleft;
var
 int1: integer;
 coord1: gridcoordty;
 rect1: rectty;
begin
 if fdatacols.scrollablecount <= 1 then begin
  tgridframe(fframe).scrollpos:= subpoint(tgridframe(fframe).scrollpos,
                                    makepoint(finnerdatarect.cx div 10 + 1,0));
 end
 else begin
  cellatpos(makepoint(finnerdatarect.x+finnerdatarect.cx-1,finnerdatarect.y),coord1);
  if coord1.col >= 0 then begin
   rect1:= cellrect(coord1);
   if rect1.x + rect1.cx = finnerdatarect.x + finnerdatarect.cx then begin
    if coord1.col < fdatacols.Count - 1 then begin
     rect1:= cellrect(makegridcoord(coord1.col+1,coord1.row));
    end
    else begin
     rect1.x:= finnerdatarect.x + finnerdatarect.cx - rect1.cx;
    end;
   end;
   int1:= finnerdatarect.x + finnerdatarect.cx - rect1.x - rect1.cx;
   tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,
         makepoint(int1,0));
  end;
 end;
end;

procedure tcustomgrid.scrollright;
var
 int1: integer;
 coord1: gridcoordty;
 rect1: rectty;
begin
 if fdatacols.scrollablecount <= 1 then begin
  tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,
                                    makepoint(finnerdatarect.cx div 10 + 1,0));
 end
 else begin
  cellatpos(finnerdatarect.pos,coord1);
  if coord1.col >= 0 then begin
   rect1:= cellrect(coord1);
   if rect1.x = finnerdatarect.x then begin
    if coord1.col > 0 then begin
     rect1:= cellrect(makegridcoord(coord1.col-1,coord1.row));
    end
    else begin
     rect1.x:= finnerdatarect.x;
    end;
   end;
   int1:= finnerdatarect.x - rect1.x;
   tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,
         makepoint(int1,0));
  end;
 end;
end;

procedure tcustomgrid.scrollpageleft;
var
 int1,int2: integer;
 coord1: gridcoordty;
 rect1: rectty;
begin
 if fdatacols.scrollablecount <= 1 then begin
  tgridframe(fframe).scrollpos:= subpoint(tgridframe(fframe).scrollpos,
                                    makepoint(finnerdatarect.cx,0));
 end
 else begin
  cellatpos(finnerdatarect.pos,coord1);
  if coord1.col >= 0 then begin
   rect1:= cellrect(coord1);
   int2:= fdatacols[coord1.col].step;
   for int1:= coord1.col to datacols.count - 1 do begin
    inc(int2,fdatacols[int1].step);
    if int2 > finnerdatarect.cx then begin
     dec(int2,fdatacols[int1].step);
     break;
    end;
   end;
   int2:= int2 + rect1.x;
   tgridframe(fframe).scrollpos:= subpoint(tgridframe(fframe).scrollpos,
        makepoint(int2,0));
  end;
 end;
end;

procedure tcustomgrid.scrollpageright;
var
 int1,int2: integer;
 coord1: gridcoordty;
 rect1: rectty;
begin
 if fdatacols.scrollablecount <= 1 then begin
  tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,
                                    makepoint(finnerdatarect.cx,0));
 end
 else begin
  cellatpos(finnerdatarect.pos,coord1);
  if coord1.col >= 0 then begin
   rect1:= cellrect(coord1);
   int2:= -rect1.x;
   if coord1.col > 0 then begin
    inc(int2,fdatacols[coord1.col-1].step);
   end;
   for int1:= coord1.col - 1 downto 0 do begin
    inc(int2,fdatacols[int1].step);
    if int2 > finnerdatarect.cx then begin
     dec(int2,fdatacols[int1].step);
     break;
    end;
   end;
   tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,
        makepoint(int2,0));
  end;
 end;
end;

function tcustomgrid.calcshowshift(const rect: rectty; const position: cellpositionty): pointty;
var
 po1,po2: pointty;
begin
 po1:= nullpoint; //left, up
 po2:= nullpoint; //right, down
 with rect do begin
  po1.x:= finnerdatarect.x + finnerdatarect.cx - (x + cx); //rangeend-endpos
  po2.x:= finnerdatarect.x - x;             //rangestart-startpos
  case position of
   cep_nearest: begin
    if po1.x >= 0 then begin   //no left shift
     po1.x:= 0;
     if po2.x <= 0 then begin  //no right shift
      po2.x:= 0;
     end;
    end
    else begin                 //left shift
     if po2.x >= 0 then begin  //right shift
      po2.x:= 0;               //no change
      po1.x:= 0;
     end
     else begin
      if po2.x >= 0 then begin //right shift
       po1.x:= 0;              //no left shift
      end
      else begin
       if po1.x - po2.x < 0 then begin //left shift to big
        po1.x:= 0;            //shift to left margin
       end
       else begin
        po2.x:= 0;            //left shift
       end;
      end;
     end;
    end;
   end;
   else begin
    po1.x:= 0;
    po2.x:= 0;
   end;
  end;
  po1.y:= finnerdatarect.y + finnerdatarect.cy - (y + cy); //rangeend-endpos
  case position of
   cep_nearest: begin
    if po1.y > 0 then begin
     po1.y:= 0;
    end;
   end;
  end;
  po2.y:= finnerdatarect.y - y;             //rangestart-startpos
  case position of
   cep_nearest: begin
    if po2.y <= 0 then begin
     po2.y:= 0;
    end
    else begin
     po1.y:= 0;
    end;
   end;
   cep_rowcentered: begin
    po1.y:= -(y - finnerdatarect.y - (finnerdatarect.cy - cy) div 2);
    po2.y:= 0;
   end;
   cep_rowcenteredif: begin
    if (po1.y < 0) or (po2.y > 0) then begin
     result:= calcshowshift(rect,cep_rowcentered);
    end
    else begin
     result:= nullpoint;
    end;
    exit;
   end;
   cep_top: begin
    po1.y:= 0;
   end;
   cep_bottom: begin
    po2.y:= 0;
   end;
   else begin
    po1.y:= 0;
    po2.y:= 0;
   end;
  end;
 end;
 result:= addpoint(po1,po2);
end;

function tcustomgrid.showrect(const rect: rectty;
                      const position: cellpositionty = cep_nearest;
                      const noxshift: boolean = false): pointty;
var
 po1: pointty;
 int1: integer;
begin
 with tgridframe(fframe) do begin
  result:= scrollpos;
  po1:= calcshowshift(rect,position);
  if noxshift then begin
   po1.x:= 0;
  end;
  if (po1.x <> 0) then begin
   int1:= po1.x + result.x + fscrollrect.cx -
        tgridframe(fframe).fpaintrect.x - tgridframe(fframe).fpaintrect.cx;
   if int1 < 0 then begin
    dec(po1.x,int1);
   end;
   int1:= po1.x + fscrollrect.x;
   if int1 > 0 then begin
    dec(po1.x,int1);
   end;
  end;

  scrollpos:= addpoint(result,po1);
  result:= subpoint(scrollpos,result);
 end;
end;

function tcustomgrid.showcaretrect(const arect: rectty;
                                      const aframe: framety): pointty;
var
 rect1: rectty;
begin
 if not window.activating and not (gs_cellexiting in fstate) and 
   (fnoshowcaretrect = 0) and 
   not (frame.sbhorz.clicked or frame.sbvert.clicked) and
   intersectrect(inflaterect(arect,aframe),cellrect(ffocusedcell),rect1) then begin
  result:= showrect(rect1,cep_nearest,noscrollingcol);
 end
 else begin
  result:= nullpoint;
 end;
end;

function tcustomgrid.showcaretrect(const arect: rectty;
                                      const aframe: tcustomframe): pointty;
begin
 if aframe <> nil then begin
  result:= showcaretrect(arect,aframe.innerframe);
 end
 else begin
  result:= showcaretrect(arect,nullframe);
 end;
end;

function tcustomgrid.showcellrect(const rect: rectty;
                       const origin: cellinnerlevelty = cil_paint): pointty;
var
 rect1: rectty;
begin
 if focusedcellvalid then begin
  rect1:= cellrect(ffocusedcell,origin);
  inc(rect1.x,rect.x);
  inc(rect1.y,rect.y);
  rect1.cx:= rect.cx;
  rect1.cy:= rect.cy;
  result:= showrect(rect1,cep_nearest,noscrollingcol);
 end
 else begin
  result:= nullpoint;
 end;
end;

procedure tcustomgrid.showcell(const cell: gridcoordty;
                     const position: cellpositionty = cep_nearest;
                     const force: boolean = false);
var
 coord1: gridcoordty;
 rect1: rectty;
 po1: pointty;
begin
 if (fupdating > 0) then begin
  include(fstate1,gs1_showcellinvalid);
  fshowcell:= cell;
  fshowcellmode:= position;
 end
 else begin
  if force or not (frame.sbhorz.clicked or frame.sbvert.clicked) then begin
   coord1:= cell;
   with coord1 do begin
    if col >= fdatacols.count then begin
     col:= fdatacols.count - 1;
    end;
    if row >= frowcount then begin
     row:= frowcount-1;
    end;
    rect1:= cellrect(coord1); //updatelayout
    po1:= calcshowshift(rect1,position);
    if (col < 0) or (co_nohscroll in fdatacols[col].foptions){noscrollingcol} then begin
     po1.x:= 0;
    end;
    if coord1.row < 0 then begin
     po1.y:= 0;
    end;
    tgridframe(fframe).scrollpos:= addpoint(tgridframe(fframe).scrollpos,po1);
   end;
  end;
 end;
end;

procedure tcustomgrid.showlastrow;
begin
 showcell(makegridcoord(col,rowhigh));
end;

function tcustomgrid.cellrect(const cell: gridcoordty;
              const innerlevel: cellinnerlevelty = cil_all;
              const nomerged: boolean = false): rectty;

 procedure updatex(const aprop: tgridprop);
 begin
  with result,aprop do begin
   case innerlevel of
    cil_paint: begin
     inc(x,fcellinfo.rect.x);
     cx:= fcellinfo.rect.cx;
    end;
    cil_inner: begin
     inc(x,fcellinfo.rect.x);
     inc(x,fcellinfo.innerrect.x);
     cx:= fcellinfo.innerrect.cx;
    end;
   end;
  end;
 end;

 procedure updatey(const aprop: tgridprop);
 begin
  with result,aprop do begin
   case innerlevel of
    cil_paint: begin
     inc(y,fcellinfo.rect.y);
     dec(cy,fdatarowheight-fcellinfo.rect.cy);
//     cy:= fcellinfo.rect.cy;
    end;
    cil_inner: begin
     inc(y,fcellinfo.rect.y);
     inc(y,fcellinfo.innerrect.y);
     dec(cy,fdatarowheight-fcellinfo.innerrect.cy);
//     cy:= fcellinfo.innerrect.cy;
    end;
   end;
  end;
 end;
 
var
 isfixr: boolean;
 int1: integer; 
 po1: prowstatecolmergety;
 
begin  //cellrect
 result:= nullrect;
 if (cell.col >= fdatacols.count) or (cell.row >= frowcount) and
            not(csdesigning in componentstate) then begin
  exit;
 end;
 internalupdatelayout;
 isfixr:= false;
 with result,cell do begin
  if row < 0 then begin
   isfixr:= -row <= ffixrows.count;
   if isfixr then begin
    with ffixrows[row] do begin
     y:= fstart;
     cy:= fend-fstart;
     if innerlevel = cil_noline then begin
      dec(cy,linewidth);
      if -row > ffixrows.count - ffixrows.oppositecount then begin
       inc(y,linewidth);
      end;
     end;
     updatey(ffixrows[row]);
     if fframe <> nil then begin
      with fframe do begin
       if innerlevel >= cil_paint then begin
        checkstate;
        inc(x,fpaintframe.left);
        dec(cx,fpaintframe.left + fpaintframe.right);
       end;
       if innerlevel >= cil_inner then begin
        inc(x,fi.innerframe.left);
        dec(cx,fi.innerframe.left + fi.innerframe.right);
       end;
      end;
     end;
     if not nomerged then begin
      if col >= 0 then begin
       if col < fcaptions.count then begin
        with tcolheader(fcaptions.fitems[col]) do begin
         if fmergeflags * [cmf_v,cmf_h] <> [] then begin
          result:= cellrect(frefcell,innerlevel);
          exit;
         end;
         inc(cx,fmergedcx);
         inc(y,fmergedy);
         inc(cy,fmergedcy);
        end;
       end;
      end
      else begin
       int1:= -col - 1;
       if int1 < fcaptionsfix.count then begin
        with tcolheader(fcaptionsfix.fitems[int1]) do begin
         if fmergeflags * [cmf_v,cmf_h] <> [] then begin
          result:= cellrect(frefcell,innerlevel);
          exit;
         end;
         inc(x,fmergedx);
         inc(cx,fmergedcx);
         inc(y,fmergedy);
         inc(cy,fmergedcy);
        end;
       end;
      end;
     end;
    end;
   end
   else begin //whole height
    y:= 0;
    cy:= tgridframe(fframe).finnerclientrect.cy;
   end;
  end
  else begin //datarows
   int1:= visiblerow(row);
   if (int1 >= 0) or (csdesigning in componentstate) then begin
    if (og_rowheight in foptionsgrid) and (int1 >= 0) then begin
     fdatacols.frowstate.cleanrowheight(row);
     fdatacols.frowstate.internalystep(row,y,cy);
     
//     with prowstaterowheightty(fdatacols.frowstate.getitempo(row))^ do begin
//      if rowheight.height = 0 then begin
//       cy:= fystep;
//      end
//      else begin
//       cy:= rowheight.height + fdatarowlinewidth;
//      end;
//      y:= rowheight.ypos;
//     end;
    end
    else begin
     cy:= fystep;
     y:= int1 * cy;
    end;
    y:= y + ffixrows.ffirstsize + fscrollrect.y;
    if innerlevel > cil_all then begin
     dec(cy,fdatarowlinewidth);
    end;
    if col < 0 then begin
     if -col <= ffixcols.count then begin
      updatey(ffixcols[col]);
     end;
    end
    else begin
     updatey(fdatacols[col]);
    end;
   end;
  end;
  if col < 0 then begin
   if -col <= ffixcols.count then begin
    with ffixcols[col] do begin
     x:= x + fstart;
     cx:= cx + fend - fstart;
     if (innerlevel = cil_noline) or isfixr and (innerlevel >= cil_noline) then begin
      dec(cx,flinewidth);
      if -cell.col > ffixcols.count - ffixcols.oppositecount then begin
        inc(x,flinewidth);
      end;
     end;
     if not isfixr then begin
      updatex(ffixcols[col]);
     end;
    end;
   end
   else begin //whole width
    x:= 0;
    cx:= tgridframe(fframe).finnerclientrect.cx;
   end;
  end
  else begin
   with fdatacols[col] do begin
    cx:= cx + fend-fstart;
    if co_nohscroll in foptions then begin
     x:= x + fstart;
    end
    else begin
     x:= x + fstart + ffixcols.ffirstsize + ffirstnohscroll + fscrollrect.x;
    end;
    if (innerlevel = cil_noline) or 
                            isfixr and (innerlevel >= cil_noline) then begin
     dec(cx,flinewidth);
    end;
    if not isfixr then begin
     updatex(fdatacols[col]);
     if (og_colmerged in foptionsgrid) and not nomerged then begin
      if (row >= 0) and (row < frowcount) and
                           (col < fdatacols.flastvisiblecol) then begin
       po1:= fdatacols.frowstate.getitempocolmerge(row);
       if po1^.colmerge.merged <> 0 then begin //has merged cols
        for int1:= col to fdatacols.flastvisiblecol-1 do begin
         if (po1^.colmerge.merged = mergedcolall) or 
          (int1 < mergedcolmax) and (po1^.colmerge.merged and 
                                                bits[int1] <> 0) then begin
          with tdatacol(fdatacols.fitems[int1+1]) do begin
           if not (co_invisible in foptions) then begin
            inc(result.cx,step);
           end;
          end;
         end
         else begin
          break;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 addpoint1(result.pos,pointty(tgridframe(fframe).fi.innerframe.topleft));
end;   //cellrect

function tcustomgrid.clippedcellrect(const cell: gridcoordty;
                 const innerlevel: cellinnerlevelty = cil_all): rectty;
                 //origin = paintrect.pos, clipped by datarect
begin
 result:= cellrect(cell,innerlevel);
 intersectdatarect(result);
end;

procedure tcustomgrid.clientrectchanged;
begin
 inherited;
 if (componentstate * [csloading,csdestroying] = []) and
      not (gs_updatelocked in fstate) then begin
  layoutchanged;
  updatevisiblerows;
 end;
end;

procedure tcustomgrid.drawcellbackground(const acanvas: tcanvas);
begin
 with fdatacols[ffocusedcell.col] do begin
  drawcellbackground(acanvas,fframe,fface);
 end;
end;

procedure tcustomgrid.drawcelloverlay(const acanvas: tcanvas);
begin
 with fdatacols[ffocusedcell.col] do begin
  drawcelloverlay(acanvas,fframe);
 end;
end;

procedure tcustomgrid.drawfocusedcell(const acanvas: tcanvas);
begin
 fdatacols[ffocusedcell.col].drawcell(acanvas);
end;

function tcustomgrid.getcaretcliprect: rectty;
begin
 internalupdatelayout;
 if noscrollingcol then begin
  result:= fdatarecty;
 end
 else begin
  result:= fdatarect;
 end;
end;

procedure tcustomgrid.scrolled(const dist: pointty);
begin
 //dummy
end;

procedure tcustomgrid.createdatacol(const index: integer;
  out item: tdatacol);
begin
 //dummy
end;

function tcustomgrid.rowvisible(const arow: integer): integer;
var
 rect1: rectty;
begin
 rect1:= cellrect(makegridcoord(0,arow));
 if rect1.y < finnerdatarect.y then begin
  result:= -1;
 end
 else begin
  if rect1.y + rect1.cy > finnerdatarect.y + finnerdatarect.cy then begin
   result:= 1;
  end
  else begin
   result:= 0;
  end;
 end;
end;

function tcustomgrid.rowsperpage: integer;
begin
 internalupdatelayout;
 result:= finnerdatarect.cy div ystep;
end;

procedure tcustomgrid.focusrow(const arow: integer; 
                 const action: focuscellactionty;
                 const selectmode: selectcellmodety = scm_cell);
var
 int1,int2: integer;
begin
// focuscell(makegridcoord(ffocusedcell.col,arow),action);
 int1:= flastcol;
 focuscell(makegridcoord(nextfocusablecol(flastcol,false,arow),arow),action,
               selectmode);
 int2:= mergestart(flastcol,ffocusedcell.row);
 if (int2 <= int1) and (mergeend(flastcol,ffocusedcell.row) > int1) or
       (int2 > 0) and not (co_nofocus in datacols[int2].options) then begin
  flastcol:= int1;
 end;
end;

procedure tcustomgrid.rowup(const action: focuscellactionty = fca_focusin);
begin
 with fdatacols.frowstate do begin
  if visiblerowcount > 0 then begin
   if (ffocusedcell.row > 0) or not (og_wraprow in foptionsgrid) then begin
    focusrow(visiblerowstep(ffocusedcell.row,-1,false),action);
   end
   else begin
    if og_wraprow in foptionsgrid then begin
     focusrow(visiblerowstep(frowcount-1,0,false),action);
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.rowdown(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 with fdatacols.frowstate do begin
  if visiblerowcount > 0 then begin
   if not (og_wraprow in foptionsgrid) or 
                (visiblerow(ffocusedcell.row) < visiblerowcount - 1) then begin
    focusrow(visiblerowstep(ffocusedcell.row,1,og_autoappend in foptionsgrid),
                                                    action);
   end
   else begin
    if og_wraprow in foptionsgrid then begin
     focusrow(visiblerowstep(0,0,false),action);
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.pageup(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 with fdatacols.frowstate do begin
  if visiblerowcount > 0 then begin
   int1:= visiblerowstep(ffocusedcell.row,-rowsperpage+1,false);
   if visiblerow(int1) < visiblerowcount then begin
    scrollrows(rowsperpage - 1);
    focusrow(int1,action);
   end;
  end;
 end;
end;

procedure tcustomgrid.pagedown(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 with fdatacols.frowstate do begin
  if visiblerowcount > 0 then begin
   int1:= visiblerowstep(ffocusedcell.row,rowsperpage-1,false);
   if int1 >= 0 then begin
    scrollrows(-(rowsperpage - 1));
    focusrow(int1,action);
   end;
  end;
 end;
end;

procedure tcustomgrid.wheelup(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 int1:= ffocusedcell.row - wheelheight;
 if int1 < 0 then begin
  int1:= 0;
 end;
 if int1 < frowcount then begin
  scrollrows(wheelheight);
  focusrow(int1,action);
 end;
end;

procedure tcustomgrid.wheeldown(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 int1:= ffocusedcell.row + wheelheight;
 if int1 > frowcount - 1 then begin
  int1:= frowcount -1;
 end;
 if int1 >= 0 then begin
  scrollrows(-wheelheight);
  focusrow(int1,action);
 end;
end;

procedure tcustomgrid.firstrow(const action: focuscellactionty = fca_focusin);
begin
 if frowcount > 0 then begin
  focusrow(0,action);
 end;
end;

procedure tcustomgrid.lastrow(const action: focuscellactionty = fca_focusin);
begin
 if frowcount > 0 then begin
  focusrow(frowcount-1,action);
 end;
end;

procedure tcustomgrid.domousewheelevent(var info: mousewheeleventinfoty);
begin
 if not (es_transientfor in info.eventstate) or
              not (gs_isdb in fstate) then begin
  frame.domousewheelevent(info,fwheelscrollheight = -1);
 end;
 inherited;
end;

function tcustomgrid.checkreautoappend: boolean;
begin
 result:= (rowcount = 0) and 
         (foptionsgrid * [og_autofirstrow,og_focuscellonenter] = 
                     [og_autofirstrow,og_focuscellonenter]);
 if result then begin
  row:= 0;
 end;
end;

procedure tcustomgrid.dokeydown(var info: keyeventinfoty);
var
 action,actioncol: focuscellactionty;
 focusbefore: gridcoordty;
 mo1: cellselectmodety;
 celleventinfo: celleventinfoty;
 cellbefore: gridcoordty;
 bo1: boolean;
 shiftstate: shiftstatesty;

 procedure checkselection; 
 begin
  if (es_processed in info.eventstate) then begin
   if not checkreautoappend and (ffocusedcell.col >= 0) then begin
    if co_keyselect in fdatacols[ffocusedcell.col].foptions then begin
     if ss_shift in shiftstate then begin
      if fstartanchor.col < 0 then begin
       fstartanchor:= focusbefore;
      end;
      action:= fca_selectend;
     end
     else begin
      action:= fca_focusin;
     end;
     focuscell(ffocusedcell,action);
    end;
   end;
  end;
 end;
  
label
 checkwidgetexit;
begin
 if canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,info);
 end;
 if not(es_processed in info.eventstate) then begin
  shiftstate:= info.shiftstate * shiftstatesmask;
  if ffocusedcell.col >= 0 then begin
   fdatacols[ffocusedcell.col].dokeyevent(info,false);
  end
  else begin
   with celleventinfo do begin
    initeventinfo(ffocusedcell,cek_keydown,celleventinfo);
    keyeventinfopo:= @info;
    docellevent(celleventinfo);
   end;
  end;
  cellbefore:= focusedcell;
  bo1:= (ow_arrowfocusout in optionswidget) and (shiftstate = []) and
        not(((info.key = key_up) or (info.key = key_pageup)) and not isfirstrow or
            ((info.key = key_down) or (info.key = key_pagedown)) and not islastrow);
                //test for db rows, exit widget
  if shiftstate - [ss_shift,ss_ctrl] = [] then begin
   if not (es_processed in info.eventstate) then begin
    if ss_shift in shiftstate then begin
     if (ffocusedcell.col >= 0) and
             (co_keyselect in fdatacols[ffocusedcell.col].foptions) then begin
      action:= fca_selectend;
      actioncol:= action;
     end
     else begin
      action:= fca_focusinshift;
      actioncol:= action;
     end;
    end
    else begin
     action:= fca_focusinforce;
     actioncol:= fca_focusin;
    end;
    focusbefore:= ffocusedcell;
    include(info.eventstate,es_processed);
    case info.key of
     key_up: begin
      if shiftstate = [ss_ctrl] then begin
       if og_keyrowmoving in foptionsgrid then begin
        if ffocusedcell.row > 0 then begin
         moverow(ffocusedcell.row,ffocusedcell.row - 1);
         showcell(ffocusedcell);
        end;
       end
       else begin
        scrollrows(1);
       end;
       exit;
      end
      else begin
       rowup(action);
       checkselection;
       goto checkwidgetexit;
      end;
     end;
     key_down: begin
      if shiftstate = [ss_ctrl] then begin
       if og_keyrowmoving in foptionsgrid then begin
        if (ffocusedcell.row >= 0) and (ffocusedcell.row < frowcount-1) then begin
         moverow(ffocusedcell.row,ffocusedcell.row + 1);
         showcell(ffocusedcell);
        end;
       end
       else begin
        scrollrows(-1);
       end;
       exit;
      end
      else begin
       rowdown(action);
       checkselection;
       goto checkwidgetexit;
      end;
     end;
     key_home: begin
      if ss_ctrl in shiftstate then begin
       focuscell(makegridcoord(nextfocusablecol(0,false,0),0),action);
      end
      else begin
       exclude(info.eventstate,es_processed);
      end;
     end;
     key_end: begin
      if ss_ctrl in shiftstate then begin
       focuscell(makegridcoord(nextfocusablecol(datacols.count-1,true,frowcount-1),
                                                       frowcount-1),action);
      end
      else begin
       exclude(info.eventstate,es_processed);
      end;
     end;
     key_pageup: begin
      if ss_ctrl in shiftstate then begin
       if og_visiblerowpagestep in foptionsgrid then begin
        focuscell(makegridcoord(ffocusedcell.col,ffirstvisiblerow),action);
       end
       else begin
        firstrow(action);
       end;
      end
      else begin
       pageup(action);
      end;
     end;
     key_pagedown: begin
      if ss_ctrl in shiftstate then begin
       if og_visiblerowpagestep in foptionsgrid then begin
        focuscell(makegridcoord(ffocusedcell.col,flastvisiblerow),action);
       end
       else begin
        lastrow(action);
       end;
      end
      else begin
       pagedown(action);
      end;
     end;
     else begin
      exclude(info.eventstate,es_processed);
     end;
    end;
   end;
   if not(es_processed in info.eventstate) and 
                                (ffocusedcell.col >= 0) then begin
    include(info.eventstate,es_processed);
    case info.key of
     key_return{,key_enter}: begin
      if (og_colchangeonreturnkey in foptionsgrid) and 
                 (shiftstate = []) then begin
       colstep(fca_focusin,1,true,false);
      end
      else begin
       exclude(info.eventstate,es_processed);
      end;
     end;
     key_tab,key_backtab: begin
      if not (og_colchangeontabkey in foptionsgrid) or (rowcount = 0) then begin
       exclude(info.eventstate,es_processed);
       dokeydownaftershortcut(info);
      end
      else begin
       if shiftstate - [ss_shift] = [] then begin
        if docheckcellvalue then begin
         action:= fca_focusin;
         if shiftstate = [ss_shift] then begin
          colstep(actioncol,-1,true,false);
         end
         else begin
          colstep(actioncol,1,true,false);
         end;
        end;
       end
       else begin
        exclude(info.eventstate,es_processed);
       end;
      end;
     end;
     key_left: begin
      if shiftstate = [ss_ctrl] then begin
       if og_keycolmoving in foptionsgrid then begin
        if ffocusedcell.col > 0 then begin
         movecol(ffocusedcell.col,ffocusedcell.col-1);
        end;
       end
       else begin
        scrollleft;
       end;
       exit;
      end
      else begin
       colstep(actioncol,-1,false,{bo1 or} not (og_wrapcol in foptionsgrid));
       checkselection;
       goto checkwidgetexit;
      end;
     end;
     key_right: begin
      if shiftstate = [ss_ctrl] then begin
       if og_keycolmoving in foptionsgrid then begin
        if (ffocusedcell.col >= 0) and (ffocusedcell.col < fdatacols.count-1) then begin
         moverow(ffocusedcell.col,ffocusedcell.col + 1);
        end;
       end
       else begin
        scrollright;
       end;
       exit;
      end
      else begin
       colstep(actioncol,1,false,{bo1 or} not (og_wrapcol in foptionsgrid));
       checkselection;
       goto checkwidgetexit;
      end;
     end;
     else begin
      exclude(info.eventstate,es_processed);
     end;
    end;
   end;
   checkselection;
   if not (es_processed in info.eventstate) and (ffocusedcell.col >= 0) then begin
    with fdatacols[ffocusedcell.col] do begin
     if (info.key = key_space) and (co_keyselect in foptions) and
//        (foptions * [co_keyselect,co_multiselect] = 
//                                          [co_keyselect,co_multiselect]) and
      ((shiftstate = [ss_shift]) or (shiftstate = [ss_ctrl])) then begin
      if shiftstate = [ss_ctrl] then begin
       mo1:= csm_reverse;
      end
      else begin
       mo1:= csm_select;
      end;
      selectcell(ffocusedcell,mo1,true);
      include(info.eventstate,es_processed);
     end;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   if {issysshortcut(sho_copy,info) or} 
        issysshortcut(sho_copycells,info) and fdatacols.cancopy and
                                                    copyselection then begin
    include(info.eventstate,es_processed);
   end
   else begin
    if issysshortcut(sho_pastecells,info) and fdatacols.canpaste and
                                                    pasteselection then begin
     include(info.eventstate,es_processed);
    end;
   end;    
  end;
  if not (es_processed in info.eventstate) then begin
   if og_rowinserting in foptionsgrid then begin
    if issysshortcut(sho_rowinsert,info) then begin
     doinsertrow(nil);
     include(info.eventstate,es_processed);
    end
    else begin
     if issysshortcut(sho_rowappend,info) then begin
      doappendrow(nil);
      include(info.eventstate,es_processed);
     end;
    end;
   end;
   if not (es_processed in info.eventstate) then begin
    if (og_rowdeleting in foptionsgrid) and 
                         issysshortcut(sho_rowdelete,info) then begin
     dodeleterows(nil);
     include(info.eventstate,es_processed);
    end;
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
 exit;
 
checkwidgetexit:
 if bo1 and  (row = cellbefore.row) and (col = cellbefore.col) then begin
  exclude(info.eventstate,es_processed);
  if es_child in info.eventstate then begin
   dokeydownaftershortcut(info);
  end;
 end;
end;

procedure tcustomgrid.dokeyup(var info: keyeventinfoty);
var
 celleventinfo: celleventinfoty;
begin
 if ffocusedcell.col >= 0 then begin
  fdatacols[ffocusedcell.col].dokeyevent(info,true);
 end
 else begin
  with celleventinfo do begin
   initeventinfo(ffocusedcell,cek_keyup,celleventinfo);
   keyeventinfopo:= @info;
   docellevent(celleventinfo);
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomgrid.updatevisiblerows;
 //todo: optimize
var
 cell: gridcoordty;
 int1: integer;
begin
// if not (gs_visiblerowsupdating in fstate) then begin
//  include(fstate,gs_visiblerowsupdating);
//  try
 inc(fvisiblerowsupdating);
 if frowcount = 0 then begin
  fvisiblerowfoldinfo:= nil;
  fvisiblerows:= nil;
  ffirstvisiblerow:= invalidaxis;
  flastvisiblerow:= invalidaxis;
  fvisiblerowsbase:= invalidaxis;
 end
 else begin
  int1:= fvisiblerowsupdating;
  cellatpos(makepoint(0,fdatarecty.y),cell); //calls updatelayout
  if int1 <> fvisiblerowsupdating then begin
   exit; //recursion
  end;
  int1:= fvisiblerowsupdating;
  ffirstvisiblerow:= cell.row;
  cellatpos(makepoint(0,fdatarecty.y+fdatarecty.cy-1),cell);
  if int1 <> fvisiblerowsupdating then begin
   exit; //recursion
  end;
  flastvisiblerow:= cell.row;
  if ffirstvisiblerow < 0 then begin
   ffirstvisiblerow:= 0;
  end;
  if flastvisiblerow < 0 then begin
   flastvisiblerow:= frowcount - 1;
  end;
  fvisiblerowsbase:= fdatacols.frowstate.visiblerow(ffirstvisiblerow);
  if flastvisiblerow < 0 then begin
   fvisiblerows:= nil;
  end
  else begin
   fvisiblerows:= fdatacols.frowstate.visiblerows1(fvisiblerowsbase,
                       fdatarect.cy - fscrollrect.y{ div fdatarowheight + 2});
   int1:= high(fvisiblerows);
   if int1 >= 0 then begin
    while fvisiblerows[int1] > flastvisiblerow do begin
     dec(int1);
    end;
    setlength(fvisiblerows,int1+1);
   end;
  end;
  if (og_folded in foptionsgrid) then begin
   with fdatacols.frowstate do begin
    updatefoldinfo(self.fvisiblerows,fvisiblerowfoldinfo);
    {
    if (row >= 0) then begin
     int1:= row;
     row:= nearestvisiblerow(row);
     if row = int1 then begin //no focuscell
      if row >= ffoldchangedrow then begin
       dofocusedcellposchanged;
       fdatacols.frowstate.ffoldchangedrow:= bigint;
      end;
     end;
    end;
    }
   end;
  end
  else begin
   fvisiblerowfoldinfo:= nil;
  end;
 end;
//  finally
//   exclude(fstate,gs_visiblerowsupdating);
//  end; 
// end;
end;

function tcustomgrid.getselectedrange: gridrectty;
begin
 if fstartanchor.row >= frowcount then begin //ev. appended row removed
  fstartanchor.row:= frowcount - 1;
  if fstartanchor.row < 0 then begin
   fstartanchor.col:= invalidaxis;
  end;
 end;
 if fendanchor.row >= frowcount then begin //ev. appended row removed
  fendanchor.row:= frowcount - 1;
  if fendanchor.row < 0 then begin
   fendanchor.col:= invalidaxis;
  end;
 end;
 if (fstartanchor.col < 0) or (fendanchor.col < 0) then begin
  result.pos:= invalidcell;
  result.size:= gridsizety(nullsize);
 end
 else begin
  result:= makegridrect(fstartanchor,fendanchor);
 end;
end;

procedure tcustomgrid.dofocus;
begin
 inherited;
 if og_focuscellonenter in foptionsgrid then begin
  focuscell(ffocusedcell,fca_entergrid);
 end;
end;

procedure tcustomgrid.initnewcomponent(const ascale: real);
begin
 ffixrows.count:= 1;
 inherited;
end;

procedure tcustomgrid.loaded;
var
 int1: integer;
 col1: tdatacol;
begin
 inherited;
 checkneedsrowheight;
 fdatacols.checkindexrange;
 fdatacols.frowstate.sourcenamechanged(-1);
 checksort;
 for int1:= 0 to fdatacols.count - 1 do begin
  col1:= tdatacol(fdatacols.fitems[int1]);
  with col1 do begin
   if (fdata <> nil) and canevent(tmethod(fonchange)) then begin
    fonchange(col1,-1);
   end;
  end;
 end;
 dorowsdatachanged(makegridcoord(invalidaxis,0),frowcount);
end;

procedure tcustomgrid.doexit;
begin
 if not (csdestroying in componentstate) then begin
  focuscell(invalidcell,fca_exitgrid);
 end;
 inherited;
end;

procedure tcustomgrid.doactivate;
begin
 if focusedcellvalid then begin
  fdatacols[ffocusedcell.col].doactivate;
 end;
 inherited;
end;

procedure tcustomgrid.dodeactivate;
begin
 exclude(fstate,gs_cellclicked);
 if focusedcellvalid then begin
  fdatacols[ffocusedcell.col].dodeactivate;
 end;
 inherited;
end;

procedure tcustomgrid.activechanged;
begin
 inherited;
 if (ffocusedcell.row >= 0) and (gs_hasactiverowcolor in fstate) then begin
  invalidaterow(ffocusedcell.row);
 end;
end;

procedure tcustomgrid.getpickobjects(const rect: rectty; 
                   const shiftstate: shiftstatesty; var objects: integerarty);
var
 cellkind: cellkindty;
 cell: gridcoordty;
 rect1: rectty;

 function cancolsizing(col: integer): boolean;
 begin
  result:= (col <> invalidaxis) and ((csdesigning in componentstate) or 
    (col >= 0) and
       (og_colsizing in foptionsgrid) and 
       not (co_fixwidth in fdatacols[col].foptions));
 end;

 function cancolmoving: boolean;
 begin
  result:= (csdesigning in componentstate) or
    (og_colmoving in foptionsgrid) and 
                        not (co_fixpos in fdatacols[cell.col].foptions);
 end;

 function canrowsizing: boolean;
 begin
  result:= (csdesigning in componentstate) or (og_rowsizing in foptionsgrid);
 end;

 function canrowmoving: boolean;
 begin
  result:= (csdesigning in componentstate) or (og_rowmoving in foptionsgrid);
 end;

 function checkfixcol(nofixed: boolean = false): boolean;
 begin
  result:= false;
  with rect do begin
   if (cell.row >= 0) and (pos.y <= rect1.y + sizingtol) then begin
    if canrowsizing then begin
     objects[0]:= pickobjectstep * (cell.row-1) + integer(pok_datarowsize);
    end;
   end
   else begin
    if (cell.row >= 0) and (pos.y >= rect1.y + rect1.cy - sizingtol) then begin
     if canrowsizing then begin
      objects[0]:= pickobjectstep * (cell.row) + integer(pok_datarowsize);
     end;
    end
    else begin
     if (csdesigning in componentstate) and not nofixed then begin
      if (pos.x <= rect1.x + sizingtol) and //left line
           (cell.col <> ffixcols.ffirstopposite + 1) then begin
                   //not left col
       if cell.col <= ffixcols.ffirstopposite then begin //right of table
        objects[0]:= -pickobjectstep * (cell.col) + integer(pok_fixcolsize);
       end
       else begin              //left of table
        objects[0]:= -pickobjectstep * (cell.col-1) + integer(pok_fixcolsize);
       end;
      end
      else begin
       if (pos.x >= rect1.x + rect1.cx - sizingtol) then begin //right line
        if (cell.col <> ffixcols.ffirstopposite) then begin //not right col
         if cell.col <= ffixcols.ffirstopposite then begin //right of table
          objects[0]:= -pickobjectstep * (cell.col+1) + integer(pok_fixcolsize);
         end
         else begin
          objects[0]:= -pickobjectstep * (cell.col) + integer(pok_fixcolsize);
         end;
        end;
       end;
      end;
     end
     else begin
      if canrowmoving and not nofixed then begin
       objects[0]:= pickobjectstep * (cell.row) + integer(pok_datarow);
       result:= true;
      end;
     end;
    end;
   end;
  end;
 end;

 function checkfixrow(nofixed: boolean = false): boolean;
 var
  int1: integer;
 begin
  result:= false;
  with rect do begin
   if (pos.x >= rect1.x + rect1.cx - sizingtol) then begin
    if (cell.col >= 0) and cancolsizing(cell.col) then begin
     objects[0]:= pickobjectstep * (cell.col) + integer(pok_datacolsize);
    end;
   end
   else begin
    if (pos.x <= rect1.x + sizingtol) then begin
     int1:= fdatacols.previosvisiblecol(cell.col);
     if (int1 >= 0) and cancolsizing(int1) then begin
      objects[0]:= pickobjectstep * (int1) + integer(pok_datacolsize);
     end;
    end
    else begin
     if (csdesigning in componentstate) and not nofixed then begin
      if (pos.y <= rect1.y + sizingtol) then begin
                //top line
       if cell.row <> ffixrows.ffirstopposite + 1 then begin //not top row
        if cell.row <= ffixrows.ffirstopposite then begin //below the table
         objects[0]:= -pickobjectstep * (cell.row) + integer(pok_fixrowsize);
        end
        else begin //above the table
         objects[0]:= -pickobjectstep * (cell.row-1) + integer(pok_fixrowsize);
        end;
       end;
      end
      else begin
       if (pos.y >= rect1.y + rect1.cy - sizingtol) and
              (cell.row <> ffixrows.ffirstopposite) then begin
              //bottom line, not bottom row
        if cell.row <= ffixrows.ffirstopposite then begin //below the table
         objects[0]:= -pickobjectstep * (cell.row+1) + integer(pok_fixrowsize);
        end
        else begin
         objects[0]:= -pickobjectstep * (cell.row) + integer(pok_fixrowsize);
        end;
       end
       else begin        
        if not (gs_child in fstate) then begin
         objects[0]:= pickobjectstep * cell.col + integer(pok_datacol);
         result:= true;
        end;
       end;
      end;
     end
     else begin
      if cancolmoving and not nofixed  and not (gs_child in fstate) then begin
       with fixrows[cell.row] do begin
        if (cell.col >= fcaptions.count) or 
            not (dco_colsort in fcaptions[cell.col].options) or
            (pos.x < rect1.x + rect1.cx - sortglyphwidth) or 
            (csdesigning in componentstate) then begin
         objects[0]:= pickobjectstep * cell.col + integer(pok_datacol);
         result:= true;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;

begin
 if (shiftstate * shiftstatesmask <> [ss_left]) or 
                                           (gs_child in fstate) then begin
  exit;
 end;
 setlength(objects,1);
 objects[0]:= -1; //none
 with rect do begin
  cellkind:= cellatpos(pos,cell);
  rect1:= cellrect(cell,cil_noline,true);
  case cellkind of
   ck_fixcolrow: begin
    if (csdesigning in componentstate) then begin
     if checkfixcol or (objects[0] < 0) then begin
      if checkfixrow or (objects[0] < 0) then begin
       objects[0]:= -pickobjectstep * (cell.row) + integer(pok_fixrow);
      end;
     end;
    end;
   end;
   ck_fixcol: begin
    checkfixcol;
   end;
   ck_fixrow: begin
    checkfixrow;
   end;
   ck_data: begin
    if ffixcols.count = 0 then begin
     checkfixcol(true);
    end;
    if ffixrows.count = 0 then begin
     checkfixrow(true);
    end;
   end;
  end;
 end;
 if objects[0] < 0 then begin
  objects:= nil;
 end;
end;

function tcustomgrid.getcursorshape(const apos: pointty; const shiftstate: shiftstatesty;
                     var shape: cursorshapety): boolean;
var
 objects: integerarty;
begin
 if shiftstate = [] then begin
  getpickobjects(makerect(apos,nullsize),[ss_left],objects);
 end;
 if length(objects) > 0 then begin
  fpickkind:= pickobjectkindty(objects[0] mod pickobjectstep);
  result:= true;
  case fpickkind of
   pok_datacolsize,pok_fixcolsize: shape:= cr_sizehor;
   pok_datarowsize,pok_fixrowsize: shape:= cr_sizever;
   else begin
    result:= false;
   end;
  end;
 end
 else begin
  result:= false;
  fpickkind:= pok_none;
 end;
end;

procedure tcustomgrid.beginpickmove(const objects: integerarty);
begin
 //dummy
end;

procedure tcustomgrid.decodepickobject(code: integer; out kind: pickobjectkindty;
  out cell: gridcoordty; out col: tcol; out row: tfixrow);
var
 int1: integer;
begin
 kind:= pickobjectkindty(code mod pickobjectstep);
 int1:= code div pickobjectstep;
 if kind in [pok_fixcol,pok_fixcolsize,pok_fixrow,pok_fixrowsize] then begin
  int1:= -int1;
 end;
 if kind in [pok_fixrow,pok_fixrowsize,pok_datarow,pok_datarowsize] then begin
  cell:= makegridcoord(invalidaxis,int1);
 end
 else begin
  cell:= makegridcoord(int1,invalidaxis);
 end;
 if kind in [pok_datacol,pok_datacolsize] then begin
  col:= fdatacols[int1];
 end
 else begin
  if kind in [pok_fixcol,pok_fixcolsize] then begin
   col:= ffixcols[int1];
  end
  else begin
   col:= nil;
   if kind in [pok_fixrow,pok_fixrowsize] then begin
    row:= ffixrows[int1];
   end
   else begin
    row:= nil;
   end;
  end;
 end;
end;

procedure tcustomgrid.endpickmove(const apos: pointty; 
                    const ashiftstate: shiftstatesty; const offset: pointty; 
                    const objects: integerarty);
var
 kind: pickobjectkindty;
 cell,cell1: gridcoordty;
 col1: tcol;
 fixrow: tfixrow;
 cellkind: cellkindty;
 int1,int2: integer;

begin
 killrepeater;
 decodepickobject(objects[0],kind,cell,col1,fixrow);
 case kind of
  pok_datacolsize,pok_fixcolsize: begin
   if (kind = pok_fixcolsize) and (cell.col <= fixcols.ffirstopposite) then begin
    col1.width:= col1.width - offset.x;
   end
   else begin
    int1:= offset.x;
    if co_nohscroll in col1.foptions then begin
     if col1.fend + int1 > fdatarect.x + fdatarect.cx then begin
      int1:= fdatarect.x + fdatarect.cx - col1.fend;
     end;
    end;
    if co_fill in col1.options then begin
     for int2:= col1.index to datacols.count - 1 do begin
      with datacols[int2] do begin
       if options * [co_fixwidth,co_fill,co_invisible] = [] then begin
        width:= width - int1;
        int1:= 0;
        break;
       end;
      end;
     end;
    end;
    col1.width:= col1.width + int1;
   end;
  end;
  pok_fixrowsize: begin
   if cell.row <= fixrows.ffirstopposite then begin
    fixrow.height:= fixrow.height - offset.y;
   end
   else begin
    fixrow.height:= fixrow.height + offset.y;
   end;
  end;
  pok_datarowsize: begin
   if og_rowheight in foptionsgrid then begin
    if ss_double in ashiftstate then begin
     rowheight[cell.row]:= 0;
    end
    else begin
     int1:= fdatacols.frowstate.currentrowheight(cell.row);
     rowheight[cell.row]:= int1 + offset.y;
    end;
   end
   else begin
    datarowheight:= fdatarowheight + offset.y;
   end;
  end;
  pok_datacol: begin
   cellkind:= cellatpos(makepoint(apos.x,fdatarect.y),cell1);
   if cell1.col >= 0 then begin
    movecol(cell.col,cell1.col);
   end
   else begin
   end;
  end;
  pok_datarow: begin
   cellkind:= cellatpos(makepoint(fdatarect.x,apos.y),cell1);
   if cell1.row >= 0 then begin
    moverow(cell.row,cell1.row);
   end
   else begin
   end;
  end;
 end;
 designchanged;
end;

procedure tcustomgrid.paintxorpic(const canvas: tcanvas;
  const apos,offset: pointty; const objects: integerarty);

 procedure drawhorzline(pos: integer);
 begin
  with tframe1(fframe) do begin
   canvas.intersectcliprect(makerect(fdatarecty.x,0,
                       fdatarecty.cx,fpaintrect.cy));
   canvas.drawline(makepoint(finnerclientrect.x,pos),
          makepoint(finnerclientrect.x + finnerclientrect.cx,pos),cl_white);
  end;
 end;

 procedure drawvertline(pos: integer);
 begin
  with tframe1(fframe) do begin
   canvas.intersectcliprect(makerect(0,fdatarectx.y,
                      fpaintrect.cx,fdatarectx.cy));
   canvas.drawline(makepoint(pos,finnerclientrect.y),
           makepoint(pos,finnerclientrect.y + finnerclientrect.cy),cl_white);
  end;
 end;

var
 kind: pickobjectkindty;
 cell,cell1: gridcoordty;
 col1: tcol;
 fixrow: tfixrow;
 int1: integer;
 rect1: rectty;

begin
 decodepickobject(objects[0],kind,cell,col1,fixrow);
 canvas.rasterop:= rop_xor;
 rect1:= cellrect(cell);
 with rect1 do begin
  case kind of
   pok_datacolsize,pok_fixcolsize: begin
    if (kind = pok_fixcolsize) and (cell.col <
                  -(fixcols.count-fixcols.foppositecount)) then begin
     int1:= offset.x+x;
    end
    else begin
     int1:= offset.x+x+cx;
    end;
    drawvertline(int1);
   end;
   pok_datarowsize,pok_fixrowsize: begin
    if (kind = pok_fixrowsize) and (cell.row <
                 -(fixrows.count-fixrows.foppositecount)) then begin
     int1:= offset.y+y;
    end
    else begin
     int1:= offset.y+y+cy;
    end;
    drawhorzline(int1);
   end;
   pok_datarow: begin
    cellatpos(makepoint(fdatarect.x,apos.y),cell1);
//    if cellkind = ck_data then begin
    if cell1.row >= 0 then begin
     rect1:= cellrect(cell1);
     killrepeater;
     if cell1.row > cell.row then begin
      int1:= rect1.y+rect1.cy;
      if int1 > fdatarect.y + fdatarect.cy then begin
       startrepeater(gs_scrolldown,slowrepeat);
      end
      else begin
       drawhorzline(int1);
      end;
     end
     else begin
      if (cell.row > 0) and (rect1.y - fystep < fdatarect.y) then begin
       startrepeater(gs_scrollup,slowrepeat);
      end
      else begin
       drawhorzline(rect1.y);
      end;
     end;
    end
    else begin
     if apos.y < fdatarect.y then begin
      startrepeater(gs_scrollup,fastrepeat);
     end
     else begin
      rect1:= cellrect(makegridcoord(0,frowcount-1));
      drawhorzline(rect1.y+rect1.cy-2);
      startrepeater(gs_scrolldown,fastrepeat);
     end;
    end;
   end;
   pok_datacol: begin
    cellatpos(makepoint(apos.x,fdatarect.y),cell1);
//    if cellkind = ck_data then begin
    if cell1.col >= 0 then begin
     rect1:= cellrect(cell1);
     killrepeater;
     if cell1.col > cell.col then begin
      int1:= rect1.x+rect1.cx;
      if int1 > fdatarect.x + fdatarect.cx then begin
       startrepeater(gs_scrollright,slowrepeat);
      end
      else begin
       drawvertline(int1);
      end;
     end
     else begin
      if (cell.col > 0) and (rect1.x - fdatacols[cell.col-1].step < fdatarect.x) then begin
       startrepeater(gs_scrollleft,slowrepeat);
      end
      else begin
       drawvertline(rect1.x);
      end;
     end;
    end
    else begin
     if apos.x < fdatarect.x then begin
      startrepeater(gs_scrollleft,slowrepeat);
     end
     else begin
      rect1:= cellrect(makegridcoord(fdatacols.count-1,0));
      drawvertline(rect1.x+rect1.cx-2);
      startrepeater(gs_scrollright,slowrepeat);
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.killrepeater;
begin
 freeandnil(frepeater);
 fstate:= fstate - repeaterstates;
end;

procedure tcustomgrid.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 fobjectpicker.restorexorpic(canvas);
end;

procedure tcustomgrid.repeatproc(const sender: tobject);
var
 bo1: boolean;
begin
 bo1:= (gs_cellclicked in fstate) and (frepeataction <> fca_none);
 if gs_scrollup in fstate then begin
  if bo1 then begin
   if row < rowcount - 1 then begin
    rowdown(frepeataction);
   end;
  end
  else begin
   scrollrows(-1);
  end;
 end
 else begin
  if gs_scrolldown in fstate then begin
   if bo1 then begin
    if row > 0 then begin
     rowup(frepeataction);
    end;
   end
   else begin
    scrollrows(1);
   end;
  end
  else begin
   if gs_scrollleft in fstate then begin
    if bo1 then begin
     if ffocusedcell.col > 0 then begin
      colstep(frepeataction,-1,false,false);
     end;
    end
    else begin
     scrollleft;
    end;
   end
   else begin
    if gs_scrollright in fstate then begin
     if bo1 then begin
      if ffocusedcell.col < fdatacols.count - 1 then begin
       colstep(frepeataction,1,false,false);
      end;
     end
     else begin
      scrollright;
     end;
    end
   end;
  end;
 end;
end;

procedure tcustomgrid.startrepeater(state: gridstatety; time: integer);
begin
 if not (state in fstate) then begin
  killrepeater;
  include(fstate,state);
  frepeater:= tsimpletimer.create(time,{$ifdef FPC}@{$endif}repeatproc,true);
 end;
end;

procedure tcustomgrid.movecol(const curindex, newindex: integer);
var
 colbefore: integer;
begin
 colbefore:= ffocusedcell.col;
 beginupdate;
 if curindex >= 0 then begin //datacols
  if (ffocusedcell.col = curindex) then begin
   ffocusedcell.col:= newindex;
  end
  else begin
   if (ffocusedcell.col >= newindex) and (ffocusedcell.col < curindex) then begin
    inc(ffocusedcell.col);
   end
   else begin
    if (ffocusedcell.col <= newindex) and (ffocusedcell.col > curindex) then begin
     dec(ffocusedcell.col);
   end;
   end;
  end;
  fdatacols.move(curindex,newindex);
 end;
 endupdate;
 docolmoved(curindex,newindex);
 if colbefore <> ffocusedcell.col then begin
  dofocusedcellposchanged;
 end;
end;

procedure tcustomgrid.moverow(const curindex, newindex: integer;
                 const count: integer = 1);
var
 int1: integer;
 rowbefore: integer;
begin
 if count > 0 then begin
  if (curindex < 0) or (curindex + count > rowcount) then begin
   tlist.Error(SListIndexError,curindex);
  end;
  if (newindex < 0) or (newindex >= rowcount) then begin
   tlist.Error(SListIndexError,newindex);
  end;

  rowbefore:= ffocusedcell.row;
  beginupdate;
  if curindex >= 0 then begin //datarows
   if not (gs_changelock in fstate) then begin
    include(fstate,gs_changelock);
    fdatacols.beginchangelock;
   end;
   if not fdatacols.roworderinvalid then begin
    exit;
   end;
   fdatacols.moverow(curindex,newindex,count);
   if (ffocusedcell.row >= 0) then begin
    if (ffocusedcell.row >= curindex) and
          (ffocusedcell.row < curindex + count) then begin
                 //focus in moved block
     int1:= newindex;
     if int1 >= curindex + count then begin
      int1:= int1 - count + 1;
     end;
     ffocusedcell.row:= ffocusedcell.row + int1 - curindex;
    end
    else begin
     if (ffocusedcell.row > curindex) and  (ffocusedcell.row < newindex + count) then begin
      dec(ffocusedcell.row,count);
     end
     else begin
      if (ffocusedcell.row < curindex) and  (ffocusedcell.row >= newindex) then begin
       inc(ffocusedcell.row,count);
      end;
     end;
    end;
   end;
   if factiverow >= 0 then begin
    factiverow:= ffocusedcell.row;
   end;
//   if not (gs_changelock in fstate) then begin
//    include(fstate,gs_changelock);
//    fdatacols.beginchangelock;
//   end;
//   fdatacols.moverow(curindex,newindex,count);
   invalidate //for fixcols colorselect
  end;
  endupdate;
  dorowsmoved(curindex,newindex,count);
  if rowbefore <> ffocusedcell.row then begin
   dofocusedcellposchanged;
  end;
 end;
end;

procedure tcustomgrid.insertrow(aindex: integer; acount: integer = 1);
var
 rowbefore: integer;
 int1,int2: integer;
begin
 if acount > 0 then begin
  dorowsinserting(aindex,acount);
  rowbefore:= ffocusedcell.row;
  beginupdate;
  try
   if aindex >= 0 then begin //datarows
    if not (gs_changelock in fstate) then begin
     include(fstate,gs_changelock);
     fdatacols.beginchangelock;
    end;
    if not fdatacols.roworderinvalid then begin
     exit;
    end;
    fdatacols.insertrow(aindex,acount);
    ffixcols.insertrow(aindex,acount);
    if (ffocusedcell.row >= 0) then begin
     if (ffocusedcell.row >= aindex) then begin
      inc(ffocusedcell.row,acount);
      if (factiverow >= 0) then begin
       factiverow:= ffocusedcell.row;
      end;
     end;
    end;
    inc(frowcount,acount);
    if frowcount > frowcountmax then begin
     frowcount:= frowcountmax;
    end;
    if of_insertsamelevel in foptionsfold then begin
     with fdatacols.frowstate do begin
      if folded then begin
       if (gs_appending in self.fstate) or (aindex+acount >= frowcount) then begin
        if (aindex > 0) then begin
         fillfoldlevel(aindex,acount,foldlevel[aindex-1]);
        end;
       end
       else begin
        fillfoldlevel(aindex,acount,foldlevel[aindex+acount]);
       end;
      end;
     end;
    end;
    dorowcountchanged(frowcount-acount,frowcount);
   end;
  finally
   endupdate;
  end;
  dorowsinserted(aindex,acount);
  if rowbefore <> ffocusedcell.row then begin
   dofocusedcellposchanged;
  end;
 end;
end;

procedure tcustomgrid.deleterow(aindex: integer; acount: integer = 1);
var
 cellbefore: gridcoordty;
 countbefore: integer;
 defocused: boolean;
begin
 if acount > 0 then begin
  if (aindex >= 0) and (of_deletetree in foptionsfold) then begin
   acount:= fdatacols.rowstate.totchildrencount(aindex,acount);
  end;
  dorowsdeleting(aindex,acount);
  defocused:= false;
  cellbefore:= ffocusedcell;
  beginupdate;
  try
   if aindex >= 0 then begin //datarows
    if not fdatacols.roworderinvalid then begin
     exit;
    end;
    if (factiverow >= 0) then begin
     if (factiverow >= aindex + acount) then begin
      dec(factiverow,acount);
     end
    end;
    if (ffocusedcell.row >= 0) then begin
     if (ffocusedcell.row >= aindex + acount) then begin
      dec(ffocusedcell.row,acount);
     end
     else begin
      if ffocusedcell.row >= aindex then begin
       countbefore:= frowcount;
       focuscell(makegridcoord(ffocusedcell.col,invalidaxis)); //defocus row
       if ffocusedcell.row <> invalidaxis then begin
        factiverow:= ffocusedcell.row;
        exit;
       end;
       defocused:= true;
       dec(acount,countbefore - frowcount); //correct removed empty last row
      end;
     end;
    end;
    if acount > 0 then begin
     if not (gs_changelock in fstate) then begin
      include(fstate,gs_changelock);
      fdatacols.beginchangelock;
     end;
     if of_shiftdeltoparent in foptionsfold then begin
      fdatacols.frowstate.movegrouptoparent(aindex,acount);
     end;
     fdatacols.deleterow(aindex,acount);
     ffixcols.deleterow(aindex,acount);
     dec(frowcount,acount);
     dorowcountchanged(frowcount+acount,frowcount);
    end;
   end;
  finally
   endupdate;
  end;
  dorowsdeleted(aindex,acount);
  if cellbefore.row <> ffocusedcell.row then begin
   dofocusedcellposchanged;
  end;
  if (og_focuscellonenter in foptionsgrid) and defocused then begin
   cellbefore.row:= aindex;
   focuscell(cellbefore,fca_focusin);
             //ev. auto append row
  end;
 end;
end;

procedure tcustomgrid.clear; //sets rowcount to 0
begin
 rowcount:= 0;
end;

function tcustomgrid.appendrow(const checkautoappend: boolean = false): integer; //returns index of new row
var
 updatingbefore: integer;
 noinvalidatebefore: integer;
 po1: pointty;
 statebefore: framestatesty;
 scrollheightbefore: integer;
 
 procedure updatelayout1;
 begin
  fupdating:= 0;
  internalupdatelayout;
  fupdating:= updatingbefore;
 end;

var
 canscroll: boolean;
  
begin
 if checkautoappend and isautoappend then begin
  result:= rowhigh;
 end
 else begin
  statebefore:= tgridframe(fframe).fstate;
  scrollheightbefore:= 
   tcustomscrollbar1(tgridframe(fframe).fvert).fdrawinfo.areas[sbbu_move].ca.dim.cy;
  noinvalidatebefore:= fnoinvalidate;
  updatingbefore:= fupdating;
  beginupdate;
  try
   if frowcount >= frowcountmax then begin
    canscroll:= showing and (fappendcount < 5);
    inc(fappendcount);
    po1.x:= 0;
    po1.y:= -fystep;
    if canscroll then begin
     updatelayout1;
     checkinvalidate;
     scrollrect(po1,fdatarecty,scrollcaret);
    end
    else begin
     invalidate;
    end;
    inc(fnoinvalidate);
    rowcount:= frowcount+1;
    updatelayout1;
    dec(fnoinvalidate);
    if canscroll then begin
     rowchanged(frowcount-1);
    end;
   end
   else begin
    inc(fnoinvalidate);
    rowcount:= rowcount+1;
    updatelayout1;
    dec(fnoinvalidate);
    rowchanged(frowcount-1);
   end;
   result:= frowcount-1;
   if statebefore * scrollbarframestates <> 
                     tgridframe(fframe).fstate * scrollbarframestates then begin
    invalidatewidget;
   end
   else begin
    if tcustomscrollbar1(tgridframe(fframe).fvert).
              fdrawinfo.areas[sbbu_move].ca.dim.cy <> 
                                         scrollheightbefore then begin
     tcustomscrollbar1(tgridframe(fframe).fvert).invalidate;
    end;
   end;
  finally
   fnoinvalidate:= noinvalidatebefore;
   fupdating:= updatingbefore
  end;
 end;
end;

procedure tcustomgrid.beginupdate;
begin
 if fupdating = 0 then begin
  fappendcount:= 0;
 end;
 inc(fupdating);
end;

procedure tcustomgrid.checkinvalidate;
var
 int1: integer;
begin
 if gs_invalidated in fstate then begin
  invalidate;
 end
 else begin
  if finvalidatedcells <> nil then begin
   for int1:= 0 to high(finvalidatedcells) do begin
    with finvalidatedcells[int1] do begin
     if (row < 0) and (col < 0) then begin
      invalidate;
      break;
     end
     else begin
      invalidatecell(finvalidatedcells[int1]);
     end;
    end;
   end;
   finvalidatedcells:= nil;
  end;
 end;
end;

procedure tcustomgrid.endupdate(const nosort: boolean = false);
var
 int1,int2: integer;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  if gs_rowcountinvalid in fstate then begin
   int2:= bigint;
   for int1:= 0 to datacols.count - 1 do begin
    with datacols[int1] do begin
     if (fdata <> nil) and (fdata.count < int2) then begin
      int2:= fdata.count;
     end;
    end;
   end;
   exclude(fstate,gs_rowcountinvalid);
   if int2 <> bigint then begin
    rowcount:= int2;
   end;
  end;
  if not nosort then begin
   checksort;
  end;
  checkinvalidate;
  if gs_changelock in fstate then begin
   exclude(fstate,gs_changelock);
   fdatacols.endchangelock;
  end;
  if gs_rowdatachanged in fstate then begin
   rowdatachanged(makegridcoord(invalidaxis,0),frowcount);
  end; 
  if gs_selectionchanged in fstate then begin
   internalselectionchanged;
  end;
  if (gs1_showcellinvalid in fstate1) then begin
   showcell(fshowcell,fshowcellmode);
   exclude(fstate1,gs1_showcellinvalid);
  end;
  if (gs_focusedcellchanged in fstate) and 
                 (ffocusedcell.col >= 0) and (ffocusedcell.row >= 0) then begin
   focusedcellchanged;
  end;
 end;
end;

procedure tcustomgrid.docolmoved(const fromindex, toindex: integer);
begin
 if canevent(tmethod(foncolmoved)) then begin
  foncolmoved(self,fromindex,toindex,1);
 end;
end;

procedure tcustomgrid.dorowsmoved(const fromindex, toindex, count: integer);
begin
 if canevent(tmethod(fonrowsmoved)) then begin
  fonrowsmoved(self,fromindex,toindex,count);
 end;
end;

procedure tcustomgrid.dorowsinserting(var index, count: integer);
begin
 if canevent(tmethod(fonrowsinserting)) then begin
  fonrowsinserting(self,index,count);
 end;
end;

procedure tcustomgrid.dorowsinserted(const index, count: integer);
begin
 if canevent(tmethod(fonrowsinserted)) then begin
  fonrowsinserted(self,index,count);
 end;
 dorowsdatachanged(makegridcoord(invalidaxis,index),count);
end;

procedure tcustomgrid.dorowsdeleting(var index, count: integer);
begin
 if canevent(tmethod(fonrowsdeleting)) then begin
  fonrowsdeleting(self,index,count);
 end;
end;

procedure tcustomgrid.dorowsdeleted(index, count: integer);
begin
 if canevent(tmethod(fonrowsdeleted)) then begin
  fonrowsdeleted(self,index,count);
 end;
end;

class function tcustomgrid.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_grid;
end;

procedure tcustomgrid.setoptionsgrid(const avalue: optionsgridty);
const
 mask1: optionsgridty = rowstateoptions;
var
 optionsbefore: optionsgridty;
begin
 if foptionsgrid <> avalue then begin
  optionsbefore:= foptionsgrid;
  foptionsgrid:= avalue;
  if (longword(avalue) xor longword(optionsbefore)) and longword(mask1) <> 0 then begin
   fdatacols.frowstate.free;
   fdatacols.frowstate:= trowstatelist.create(self);
   fdatacols.frowstate.count:= rowcount;
  end;
  fdatacols.frowstate.folded:= og_folded in avalue;
  layoutchanged;
  if (og_sorted in avalue) and not(og_sorted in optionsbefore) then begin
   exclude(fstate,gs_sortvalid);
   checksort;
  end;
 end;
end;

function tcustomgrid.scrollcaret: boolean;
begin
 result:= false;
end;

procedure tcustomgrid.synctofontheight;
begin
 inherited;
 ffixrows.synctofontheight;
end;

procedure tcustomgrid.dragevent(var info: draginfoty);
var
 bo1,bo2: boolean;
 cell1: gridcoordty;
begin
 cell1:= cellatpos(info.pos);
 bo2:= isdatacell(cell1);
 if not fdragcontroller.beforedragevent(info) then begin
  if bo2 then begin
   bo1:= false;
   datacols[cell1.col].beforedragevent(info,cell1.row,bo1);
   if not bo1 then begin
    inherited;
   end;
  end
  else begin
   inherited;
  end;
 end;
 if not fdragcontroller.afterdragevent(info) then begin
  bo1:= false;
  if bo2 then begin
   datacols[cell1.col].afterdragevent(info,cell1.row,bo1);
  end;
 end;
end;

function tcustomgrid.getdisprect: rectty;
begin
 if (ffocusedcell.row = invalidaxis) and (ffocusedcell.col = invalidaxis) then begin
  result:= inherited getdisprect;
 end
 else begin
  result:= cellrect(ffocusedcell);
  addpoint1(result.pos,paintpos);
 end;
end;

procedure tcustomgrid.dofontheightdelta(var delta: integer);
begin
 if ow_autoscale in optionswidget then begin
  ffixrows.dofontheightdelta(delta);
 end;
end;

procedure tcustomgrid.fontchanged;
begin
 inherited;
 fdatacols.fontchanged;
 ffixrows.fontchanged;
 ffixcols.fontchanged;
end;

procedure tcustomgrid.setgridframecolor(const Value: colorty);
begin
 if fgridframecolor <> value then begin
  fgridframecolor := Value;
  invalidate;
 end;
end;

procedure tcustomgrid.setgridframewidth(const Value: integer);
begin
 if fgridframewidth <> value then begin
  if componentstate * [csdesigning,csloading] = [csdesigning] then begin
   with tframe1(fframe),fi.innerframe do begin
    if right = self.fgridframewidth then begin
     right:= value;
    end;
    if top = self.fgridframewidth then begin
     top:= value;
    end;
    if left = self.fgridframewidth then begin
     left:= value;
    end;
    if bottom = self.fgridframewidth then begin
     bottom:= value;
    end;
    self.fgridframewidth := Value;
    self.layoutchanged;
    tframe1(fframe).updatestate;
   end;
  end
  else begin
   fgridframewidth := Value;
   layoutchanged;
  end;
 end;
end;

function tcustomgrid.getmerged(const arow: integer): longword;
begin
 result:= 0;
 if (og_colmerged in foptionsgrid) and (arow >= 0) then begin
  result:= fdatacols.frowstate.getitempocolmerge(arow)^.colmerge.merged;
 end;
end;

function tcustomgrid.mergestart(const acol: integer; const arow: integer): integer;
var
 int1: integer;
 merged1: longword;
begin
 result:= acol;
 if acol >= 0 then begin
  merged1:= getmerged(arow);
  if merged1 <> 0 then begin
   if merged1 = mergedcolall then begin
    result:= 0;
   end
   else begin
    if result < mergedcolmax then begin
     result:= 0;
     for int1:= acol - 1 downto 0 do begin
      if merged1 and bits[int1] = 0 then begin
       result:= int1 + 1;
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustomgrid.mergeend(const acol: integer; const arow: integer): integer;
var
 int1,int2: integer;
 merged1: longword;
begin
 result:= acol;
 if acol >= 0 then begin
  merged1:= getmerged(arow);
  if merged1 <> 0 then begin
   if merged1 = mergedcolall then begin
    result:= fdatacols.count;
   end
   else begin
    if (acol < mergedcolmax) and 
               ((acol = 0) or (merged1 and bits[acol-1] <> 0)) then begin
     result:= fdatacols.count;
     int2:= fdatacols.count - 1;
     if int2 >= mergedcolmax then begin
      int2:= mergedcolmax - 1;
     end;
     for int1:= acol to int2 do begin
      if merged1 and bits[int1] = 0 then begin
       result:= int1 + 1;
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.colstep(action: focuscellactionty; step: integer;
                 const rowchange: boolean; const nocolwrap: boolean);
var
 int1: integer;
 arow: integer;
 bo1: boolean;
 finished: boolean;
begin
 if fdatacols.count > 0 then begin
  arow:= ffocusedcell.row;
  int1:= ffocusedcell.col;
  finished:= true;
  repeat
   if step > 0 then begin
    inc(int1);
    finished:= int1 <= ffocusedcell.col;
    int1:= mergeend(int1,arow);
    finished:= finished and (int1 >= ffocusedcell.col);
    if int1 >= fdatacols.count then begin
     if nocolwrap then begin
      exit;
     end;
     if rowchange then begin
      inc(arow);
      if action = fca_focusin then begin
       action:= fca_focusinforce;
      end;
     end;
     int1:= 0;
     finished:= int1 = ffocusedcell.col;
    end;
    if fdatacols[int1].canfocus(mb_none,[],bo1) then begin
     dec(step);
    end;
   end
   else begin
    dec(int1);
    finished:= int1 >= ffocusedcell.col;
    int1:= mergestart(int1,arow);
    finished:= finished and (int1 <= ffocusedcell.col);
    if int1 < 0 then begin
     if nocolwrap then begin
      exit;
     end;
     if rowchange then begin
      dec(arow);
      if action = fca_focusin then begin
       action:= fca_focusinforce;
      end;
     end;
     int1:=  mergestart(fdatacols.count - 1,arow);
     finished:= int1 <= ffocusedcell.col;
    end;
    if fdatacols[int1].canfocus(mb_none,[],bo1) then begin
     inc(step);
    end;
   end;
   if step = 0 then begin
    if arow < 0 then begin
     arow:= rowcount-1;
    end
    else begin
     if arow >= rowcount then begin
      if not (gs_isdb in fstate) and (og_autoappend in foptionsgrid) then begin
       if fdatacols.rowempty(rowcount - 1) then begin
        arow:= rowcount-1;
       end
       else begin
        arow:= rowcount;
       end;
      end
      else begin
       arow:= 0;
      end;
     end;
    end;
    focuscell(makegridcoord(int1,arow),action);
    break;
   end;
  until finished; //none found
 end;
end;

function tcustomgrid.nextfocusablecol(acol: integer;
  const aleft: boolean; const arow: integer): integer;
var
 int1,int2: integer;
 loopcount: integer;
 bo1: boolean;
// merged1: longword;
begin
 result:= -1;
 if fdatacols.count > 0 then begin
//  merged1:= getmerged(arow);
  if acol > fdatacols.count then begin
   acol:= fdatacols.count;
  end;
  if acol < -1 then begin
   acol:= -1;
  end;
  loopcount:= -1;
  if aleft then begin
   if acol = fdatacols.count then begin
    acol:= fdatacols.count - 1;
   end;
   int1:= acol;
   repeat
    if int1 < 0 then begin
     int1:=  fdatacols.count - 1;
     inc(loopcount);
    end;
    int1:= mergestart(int1,arow);
    if fdatacols[int1].canfocus(mb_none,[],bo1) then begin
     result:= int1;
     break;
    end;
    dec(int1);
   until (int1 = acol) or (loopcount > 0);
   {
   if (merged1 <> 0) and (result > 0) then begin
    int2:= 0;
    if (merged1 <> mergedcolall) then begin
     if result < mergedcolmax then begin
      for int1:= result - 1 downto 0 do begin
       if merged1 and bits[int1] = 0 then begin
        int2:= int1 + 1;
        break;
       end;
      end;
     end
     else begin
      int2:= result;
     end;
    end;
    result:= int2
   end;
   }
  end
  else begin
   if acol < 0 then begin
    acol:= 0;
   end;
   int1:= mergestart(acol,arow);
   repeat
    if int1 >= fdatacols.count then begin
     int1:= 0;
     inc(loopcount);
    end;
    if fdatacols[int1].canfocus(mb_none,[],bo1) then begin
     result:= int1;
     break;
    end;
    inc(int1);
    int1:= mergeend(int1,arow);
   until (int1 = acol) or (loopcount > 0);
  end;
 end;
end;

procedure tcustomgrid.checkcellvalue(var accept: boolean);
begin
 //dummy
end;

function tcustomgrid.docheckcellvalue: boolean;
begin
 result:= true;
 if focusedcellvalid and (fnullchecking = 0) then begin
  inc(fcellvaluechecking);
  try
   checkcellvalue(result);
  finally
   dec(fcellvaluechecking);
  end;
 end;
end;

procedure tcustomgrid.removeappendedrow;
begin
 docheckcellvalue;
 if isautoappend then begin
  if row >= 0 then begin
   if row = 0 then begin
    row:= invalidaxis;
   end
   else begin
    row:= row-1;
   end;
  end
  else begin
   deleterow(frowcount-1);
   include(fstate,gs_emptyrowremoved);
  end;
 end;
end;

function tcustomgrid.internalsort(sortfunc: gridsorteventty;
  var refindex: integer): boolean;
          //true if rows moved, refindex is new indexpos
var
 list: tintegerdatalist;
 bewegt: boolean;

 procedure quicksort(L, R: Integer);
 var
   I, J: Integer;
   P, T: integer;
   int1: integer;
 begin
  if r >= l then begin
   repeat
     I := L;
     J := R;
     P := list.items[(L + R) shr 1];
     repeat
       repeat
        int1:= 0;
        sortfunc(self,List.items[I], P,int1);
        if int1 = 0 then begin
         int1:= list.items[i] - p;
        end;
        if int1 >= 0 then break;
        inc(i);
       until false;
       repeat
        int1:= 0;
        sortfunc(self,List.items[j], P,int1);
        if int1 = 0 then begin
         int1:= list.items[j] - p;
        end;
        if int1 <= 0 then break;
        dec(j);
       until false;
//       while (sortfunc(List.items[I], P,self) < 0) do Inc(I);
//       while (sortfunc(List.items[J], P,self) > 0) do Dec(J);
       if I <= J then
       begin
        if i <> j then begin
         bewegt:= true;
         T := List.items[I];
         List.items[I] := List.items[J];
         List.items[J] := T;
        end;
        Inc(I);
        Dec(J);
       end;
     until I > J;
     if L < J then QuickSort(L, J);
     L := I;
   until I >= R;
  end;
 end;

var
 int1: integer;
 bo1: boolean;

begin
 bewegt:= false;
 int1:= frowcount;
 if int1 > 0 then begin
  bo1:= not (gs_isdb in fstate) and (og_autoappend in foptionsgrid) and 
                    fdatacols.rowempty(int1-1);
  if bo1 then begin
   dec(int1); //do not sort last row
  end;
  list:= tintegerdatalist.create;
  try
   list.count:= int1;
   list.number(0,1);
   quicksort(0,list.count-1);
   if bewegt then begin
    if bo1 then begin
     list.add(int1);
    end;
    for int1:= 0 to fdatacols.count - 1 do begin
     include(tdatacol(fdatacols.fitems[int1]).fstate,gps_noinvalidate);
    end;
    try
     fdatacols.rearange(list);
    finally
     for int1:= 0 to fdatacols.count - 1 do begin
      exclude(tdatacol(fdatacols.fitems[int1]).fstate,gps_noinvalidate);
     end;
    end;
    ffixcols.rearange(list);
    if refindex >= 0 then begin
     for int1:= 0 to list.count-1 do begin   //neue position bestimmen
      if list.items[int1] = refindex then break;
     end;
     refindex:= int1;
    end;
   end;
  finally
   list.free;
  end;
 end;
 result:= bewegt;
end;

procedure tcustomgrid.sort;
var
 int1: integer;
begin
 if gs_isdb in fstate then begin
  include(fstate,gs_sortvalid);
 end
 else begin
  fdatacols.roworderinvalid;
  beginupdate;
  try
   int1:= ffocusedcell.row;
   if assigned(fonsort) then begin
    internalsort(fonsort,int1);
   end
   else begin
    internalsort({$ifdef FPC}@{$endif}fdatacols.sortfunc,int1);
   end;
   if int1 <> ffocusedcell.row then begin
    if factiverow = ffocusedcell.row then begin
     factiverow:= int1;
    end;
    ffocusedcell.row:= int1;
//    updaterowdata; //for twidgetgrid
   end;
   include(fstate,gs_sortvalid);
   layoutchanged;
  finally
   endupdate;
  end;
  if ffocusedcell.row >= 0 then begin
   showcell(makegridcoord(invalidaxis,ffocusedcell.row));
  end;
 end;
end;

function tcustomgrid.copyselection: boolean;
          //false if no copy
begin
 result:= false;
end;

function tcustomgrid.pasteselection: boolean;
          //false if no paste
begin
 result:= false;
end;

procedure tcustomgrid.sortchanged;
begin
 if not(csloading in componentstate) then begin
  if assigned(fonsortchanged) then begin
   fonsortchanged(self);
  end;
  if (og_sorted in foptionsgrid) then begin
   sort;
  end
  else begin
   include(fstate,gs_sortvalid);
   invalidate; //for sort indicator
  end;
 end;
end;

procedure tcustomgrid.sortinvalid;
begin
 exclude(fstate,gs_sortvalid);
end;

procedure tcustomgrid.checksort;
begin
 if not (gs_sortvalid in fstate) and (fupdating = 0) then begin
  sortchanged;
 end;
end;

procedure tcustomgrid.setrowcolors(const Value: tcolorarrayprop);
begin
 frowcolors.assign(Value);
end;

procedure tcustomgrid.setrowfonts(const Value: trowfontarrayprop);
begin
 frowfonts.assign(Value);
end;

function tcustomgrid.checkrowindex(var aindex: integer): boolean;
begin
 if aindex < 0 then begin
  if aindex = -1 then begin
   aindex:= ffocusedcell.row;
  end;
 end;
 result:= aindex >= 0; 
end;

function tcustomgrid.getrowcolorstate(index: integer): rowstatenumty;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.color[index];
 end
 else begin
  result:= -1;
 end;
end;

procedure tcustomgrid.setrowcolorstate(index: integer; const Value: rowstatenumty);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.color[index]:= value;
  rowchanged(index);
  rowstatechanged(index);
 end;
end;

function tcustomgrid.getrowlinecolorstate(index: integer): rowstatenumty;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.linecolor[index];
 end
 else begin
  result:= -1;
 end;
end;

procedure tcustomgrid.setrowlinecolorstate(index: integer; const Value: rowstatenumty);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.linecolor[index]:= value;
  rowchanged(index);
  rowstatechanged(index);
 end;
end;

function tcustomgrid.getrowlinecolorfixstate(index: integer): rowstatenumty;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.linecolorfix[index];
 end
 else begin
  result:= -1;
 end;
end;

procedure tcustomgrid.setrowlinecolorfixstate(index: integer;
                                              const Value: rowstatenumty);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.linecolorfix[index]:= value;
  rowchanged(index);
  rowstatechanged(index);
 end;
end;

function tcustomgrid.getrowlinewidth(index: integer): integer;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.linewidth[index];
 end
 else begin
  result:= fdatarowlinewidth;
 end;
end;

procedure tcustomgrid.setrowlinewidth(index: integer; const avalue: integer);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.linewidth[index]:= avalue;
 end;
end;

function tcustomgrid.getrowfontstate(index: integer): rowstatenumty;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.font[index];
 end
 else begin
  result:= -1;
 end;
end;

procedure tcustomgrid.setrowfontstate(index: integer; const Value: rowstatenumty);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.font[index]:= value;
  rowchanged(index);
  rowstatechanged(index);
 end;
end;

function tcustomgrid.getrowreadonlystate(index: integer): boolean;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.readonly[index];
 end
 else begin
  result:= false;
 end;
end;

procedure tcustomgrid.setrowreadonlystate(index: integer;
               const avalue: boolean);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.readonly[index]:= avalue;
  if index = row then begin
   checkrowreadonlystate;
  end;
  rowstatechanged(index);
 end;
end;


function tcustomgrid.getrowhidden(index: integer): boolean;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.hidden[index];
 end
 else begin
  result:= false;
 end;
end;

procedure tcustomgrid.setrowhidden(index: integer; const avalue: boolean);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.hidden[index]:= avalue;
 end;
end;

function tcustomgrid.getrowfoldlevel(index: integer): byte;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.foldlevel[index];
 end
 else begin
  result:= 0;
 end;
end;

procedure tcustomgrid.setrowfoldlevel(index: integer; const avalue: byte);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.foldlevel[index]:= avalue;
 end;
end;

function tcustomgrid.getrowfoldissum(index: integer): boolean;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.foldissum[index];
 end
 else begin
  result:= false;
 end;
end;

procedure tcustomgrid.setrowfoldissum(index: integer; const avalue: boolean);
begin
 if checkrowindex(index) then begin
  fdatacols.frowstate.foldissum[index]:= avalue;
 end;
end;

function tcustomgrid.getrowheight(index: integer): integer;
begin
 if checkrowindex(index) then begin
  result:= fdatacols.frowstate.height[index];
 end
 else begin
  result:= 0;
 end;
end;

procedure tcustomgrid.setrowheight(index: integer; avalue: integer);
begin
 if checkrowindex(index) then begin
  if (avalue <> 0) and (avalue < fdatarowheightmin) then begin 
   avalue:= fdatarowheightmin;
  end
  else begin
   if avalue > fdatarowheightmax then begin
    avalue:= fdatarowheightmax;
   end;
  end; 
  fdatacols.frowstate.height[index]:= avalue;
 end;
end;

function tcustomgrid.rowfoldinfo: prowfoldinfoty; 
         //nil if focused row not visible
var
 int1: integer;
begin                 //todo: optimize
 result:= nil;
 if row >= 0 then begin
  internalupdatelayout;
  if (fvisiblerowfoldinfo <> nil) and (row >= fvisiblerows[0]) and 
               (row <= fvisiblerows[high(fvisiblerows)]) then begin
   for int1:= 0 to high(fvisiblerows) do begin
    if fvisiblerows[int1] = row then begin
     result:= @fvisiblerowfoldinfo[int1];
     break;
    end;
   end;
  end;
 end;
end;

procedure tcustomgrid.checkrowreadonlystate;
begin
 if (row >= 0) and rowreadonlystate[row] then begin
  include(fstate,gs_rowreadonly);
 end
 else begin
  exclude(fstate,gs_rowreadonly);
 end;
end;

procedure tcustomgrid.checkneedsrowheight;
var
 int1: integer;
 bo1: boolean;
begin
 if not (csloading in componentstate) then begin
  bo1:= gs_needsrowheight in fstate;
  exclude(fstate,gs_needsrowheight);
  with fdatacols do begin
   for int1:= 0 to count -1 do begin
    if gps_needsrowheight in tgridprop(pointerarty(fitems)[int1]).fstate then begin
     include(self.fstate,gs_needsrowheight);
     if not bo1 and (frowcount > 0) then begin
      fdatacols.rowstate.change(-1);
     end;     
     break;
    end;
   end;
  end;   
 end;
end;

procedure tcustomgrid.updaterowheight(const arow: integer;
                                                   var arowheight: integer);
begin
 fdatacols.updaterowheight(arow,arowheight);
// ffixcols.updaterowheight(arow,arowheight); not used up to now
end;

procedure tcustomgrid.setdragcontroller(const avalue: tdragcontroller);
begin
 fdragcontroller.assign(avalue);
end;

procedure tcustomgrid.setzebra_color(const avalue: colorty);
begin
 if fzebra_color <> avalue then begin
  fzebra_color:= avalue;
  invalidate;
 end;
end;

procedure tcustomgrid.setzebra_start(const avalue: integer);
begin
 if fzebra_start <> avalue then begin
  fzebra_start:= avalue;
  invalidate;
 end;
end;

procedure tcustomgrid.setzebra_height(const avalue: integer);
begin
 if fzebra_height <> avalue then begin
  fzebra_height:= avalue;
  invalidate;
 end;
end;

procedure tcustomgrid.setzebra_step(const avalue: integer);
begin
 if fzebra_step <> avalue then begin
  fzebra_step:= avalue;
  invalidate;
 end;
end;

procedure tcustomgrid.appinsrow(index: integer);
var
 int1,int2: integer;
begin
 if index < 0 then begin
  index:= 0;
 end;
 insertrow(index);
 if fdatacols.fnewrowcol < 0 then begin
  int1:= ffocusedcell.col;
 end
 else begin
  int1:= fdatacols.fnewrowcol;
 end;
 focuscell(makegridcoord(int1,index));
end;

procedure tcustomgrid.doinsertrow(const sender: tobject);
var
 int1: integer;
begin
 appinsrow(ffocusedcell.row);
end;

procedure tcustomgrid.doappendrow(const sender: tobject);
var
 bo1: boolean;
begin
 bo1:= gs_appending in fstate;
 include(fstate,gs_appending);
 try
  appinsrow(ffocusedcell.row+1);
 finally
  if not bo1 then begin
   exclude(fstate,gs_appending);
  end;
 end;
end;

procedure tcustomgrid.dodeleterow(const sender: tobject);
begin
 with stockobjects do begin
  if askok(captions[sc_Delete_row_question],captions[sc_Confirmation]) then begin
   deleterow(ffocusedcell.row);
  end;
 end;
end;

procedure tcustomgrid.dodeleteselectedrows(const sender: tobject);
var
 ar1: integerarty;
 int1: integer;
begin
 ar1:= fdatacols.getselectedrows;
 if high(ar1) >= 0 then begin
  if askok(stockobjects.textgenerators[tg_delete_n_selected_rows](
                                       [integer(length(ar1))]),
                            stockobjects.captions[sc_Confirmation]) then begin
   beginupdate;
   try
    for int1:= high(ar1) downto 0 do begin
     deleterow(ar1[int1]);
    end;
   finally
    endupdate;
   end;
  end;
 end;
end;

procedure tcustomgrid.dodeleterows(const sender: tobject);
begin
 if (og_selectedrowsdeleting in foptionsgrid) and 
            (high(fdatacols.getselectedrows) >= 0) then begin
  dodeleteselectedrows(sender);
 end
 else begin
  if (og_rowdeleting in foptionsgrid) and (ffocusedcell.row >= 0) then begin
   dodeleterow(sender);
  end;
 end;
end;

procedure tcustomgrid.docopycells(const sender: tobject);
begin
 copyselection;
end;

procedure tcustomgrid.dopastecells(const sender: tobject);
begin
 pasteselection;
end;

function tcustomgrid.endanchor: gridcoordty;
begin
 result:= fendanchor;
end;

function tcustomgrid.startanchor: gridcoordty;
begin
 result:= fstartanchor;
end;

procedure tcustomgrid.beginnullchecking;
begin
 inc(fnullchecking);
end;

procedure tcustomgrid.endnullchecking;
begin
 dec(fnullchecking);
end;

procedure tcustomgrid.beginnonullcheck;
begin
 inc(fnonullcheck);
end;

procedure tcustomgrid.endnonullcheck;
begin
 dec(fnonullcheck);
end;

procedure tcustomgrid.beginnocheckvalue;
begin
 inc(fnocheckvalue);
end;

procedure tcustomgrid.endnocheckvalue;
begin
 dec(fnocheckvalue);
end;

function tcustomgrid.nocheckvalue: boolean;
begin
 result:= fnocheckvalue > 0;
end;

function tcustomgrid.cellclicked: boolean;
begin
 result:= gs_cellclicked in fstate;
end;

function tcustomgrid.cellvisible(const acell: gridcoordty): boolean;
var
 int1: integer;
begin
 result:= false;
 if acell.col >= 0 then begin
  if acell.col < fdatacols.count then begin
   result:= fdatacols[acell.col].visible;
  end;
 end
 else begin
  int1:= - acell.col - 1;
  if int1 < ffixcols.count then begin
   result:= tfixcol(ffixcols.fitems[int1]).visible;
  end;
 end; 
 if result then begin
  if acell.row < 0 then begin
   int1:= -acell.row - 1;
   if int1 < ffixrows.count then begin
    result:= tfixrow(ffixrows.fitems[int1]).visible;
   end
   else begin
    result:= false;
   end;
  end
  else begin
   result:= acell.row < frowcount;
  end;
 end;
end;

procedure tcustomgrid.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if event = oe_changed then begin //todo: optimize
  fdatacols.checktemplate(sender);
  ffixcols.checktemplate(sender);
  ffixrows.checktemplate(sender);
 end;
end;

procedure tcustomgrid.focuscolbyname(const aname: string);
var
 col1: tdatacol;
begin
 col1:= fdatacols.colbyname(aname);
 if col1 <> nil then begin
  col:= col1.index;
  if not entered then begin
   setfocus;
  end;
 end;
end;

function tcustomgrid.getdragrect(const apos: pointty): rectty;
var
 cell1: gridcoordty;
begin
 cell1:= cellatpos(apos);
 if isdatacell(cell1) then begin
  result:= cellrect(cell1);
 end
 else begin
  result:= inherited getdragrect(apos);
 end;
end;

procedure tcustomgrid.updaterowdata;
begin
 //dummy
end;
function tcustomgrid.getsorted: boolean;
begin
 result:= og_sorted in optionsgrid;
end;

procedure tcustomgrid.setsorted(const avalue: boolean);
begin
 if avalue then begin
  optionsgrid:= optionsgrid + [og_sorted];
 end
 else begin
  optionsgrid:= optionsgrid - [og_sorted];
 end;
end;

function tcustomgrid.getrowstatelist: trowstatelist;
begin
 result:= fdatacols.frowstate;
end;

procedure tcustomgrid.setrowstatelist(const avalue: trowstatelist);
begin
 fdatacols.frowstate.assign(avalue);
end;

{$ifdef mse_with_ifi}
function tcustomgrid.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifigridlink);
end;

function tcustomgrid.getrowstate: tcustomrowstatelist;
begin
 result:= fdatacols.frowstate;
end;

procedure tcustomgrid.setifilink(const avalue: tifigridlinkcomp);
begin
 mseificomp.setifilinkcomp(iifigridlink(self),avalue,tifilinkcomp(fifilink));
end;

function tcustomgrid.updating: boolean;
begin
 result:= fupdating > 0;
end;

{$endif}

{ tdrawgrid }

function tdrawgrid.createdatacols: tdatacols;
begin
 result:= tdrawcols.create(self);
end;

function tdrawgrid.getdatacols: tdrawcols;
begin
 result:= tdrawcols(fdatacols);
end;

procedure tdrawgrid.setdatacols(const value: tdrawcols);
begin
 fdatacols.assign(value);
end;

function tdrawgrid.getcols(index: integer): tdrawcol;
begin
 result:= tdrawcol(fdatacols[index]);
end;

procedure tdrawgrid.setcols(index: integer; const avalue: tdrawcol);
begin
 tdrawcol(fdatacols[index]).assign(avalue);
end;

{ tcellgrid }

procedure tcellgrid.clientmouseevent(var info: mouseeventinfoty);
var
 bo1,bo2: boolean;
begin
 bo1:= es_child in info.eventstate;
 bo2:=  gs_cellclicked in fstate;
 if bo2 and (info.shiftstate * keyshiftstatesmask = []) then begin
  include(info.eventstate,es_child);
 end;
 inherited;
 if not bo1 then begin
  exclude(info.eventstate,es_child);
 end;
end;

{ tcustomstringgrid }

constructor tcustomstringgrid.create(aowner: tcomponent);
begin
 inherited;
 feditor:= tinplaceedit.create(self,iedit(self));
end;

destructor tcustomstringgrid.destroy;
begin
 inherited;
 feditor.free;
end;

function tcustomstringgrid.createdatacols: tdatacols;
begin
 result:= tstringcols.create(self);
end;

function tcustomstringgrid.getcols(index: integer): tstringcol;
begin
 result:= tstringcol(fdatacols[index]);
end;

procedure tcustomstringgrid.setcols(index: integer; const Value: tstringcol);
begin
 fdatacols[index].Assign(value);
end;

function tcustomstringgrid.getdatacols: tstringcols;
begin
 result:= tstringcols(fdatacols);
end;

procedure tcustomstringgrid.setdatacols(const value: tstringcols);
begin
 fdatacols.assign(value);
end;

procedure tcustomstringgrid.drawfocusedcell(const canvas: tcanvas);
var
 po1: pointty;
 rect1: rectty;
 int1: integer;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if calcautocellsize then begin
   rect1:= feditor.textrect;
   int1:= rect.cx - innerrect.cx + rect1.cx;
   if int1 > autocellsize.cx then begin
    autocellsize.cx:= int1;
   end;
   int1:= rect.cy - innerrect.cy + rect1.cy;
   if int1 > autocellsize.cy then begin
    autocellsize.cy:= int1;
   end;
  end
  else begin
   drawcellbackground(canvas);
   po1:= cellrect(ffocusedcell,cil_paint).pos;
   canvas.remove(po1);
   feditor.dopaint(canvas);
   canvas.move(po1);
  end;
 end;
end;

procedure tcustomstringgrid.doselectionchanged;
begin
 if isdatacell(focusedcell) then begin
  feditor.font:= fdatacols[ffocusedcell.col].rowfont(ffocusedcell.row)
 end;
 inherited;
end;

procedure tcustomstringgrid.updatepopupmenu(var amenu: tpopupmenu; 
                         var mouseinfo: mouseeventinfoty);
begin
 if isdatacell(ffocusedcell) then begin
  feditor.updatepopupmenu(amenu,popupmenu,mouseinfo,false{,
                                            fdatacols.hasselection});
 end;
 inherited;
end;

procedure tcustomstringgrid.setupeditor(const acell: gridcoordty;
              const focusin: boolean);
var
 col1: tcustomstringcol;
 mstr1: msestring;
 int1: integer;
begin
 col1:= tcustomstringcol(fdatacols[acell.col]);
 mstr1:= col1[acell.row];
 col1.updatedisptext(mstr1);
 int1:= 0;
 if not focusin then begin
  int1:= feditor.curindex;
 end;
 feditor.optionsedit1:= col1.foptionsedit1;
 feditor.setup(mstr1,int1,not focusin,cellrect(acell,cil_inner),
                    cellrect(acell,cil_paint),nil,nil,
                    fdatacols[acell.col].rowfont(acell.row));
 feditor.textflags:= col1.textflags;
 feditor.textflagsactive:= col1.ftextflagsactive;
 if focusin then begin
  feditor.dofocus;
 end;
 if active then begin
  feditor.doactivate;
 end;
end;

procedure tcustomstringgrid.rowstatechanged(const arow: integer);
begin
 inherited;
 if (arow = ffocusedcell.row) and (ffocusedcell.col >= 0) then begin
  feditor.font:= fdatacols[ffocusedcell.col].rowfont(ffocusedcell.row)
 end;
end;

procedure tcustomstringgrid.dofocusedcellposchanged;
begin
 inherited;
 if ffocusedcell.col >= 0 then begin
  feditor.updatepos(cellrect(ffocusedcell,cil_inner),
                                      cellrect(ffocusedcell,cil_paint));
 end;
end;

procedure tcustomstringgrid.focusedcellchanged;
begin
 inherited;
 setupeditor(ffocusedcell,true);
end;

procedure tcustomstringgrid.checkrowreadonlystate;
begin
 inherited;
 if isdatacell(ffocusedcell) then begin
  feditor.updatecaret;
//  setupeditor(ffocusedcell,false);
 end;
end;

procedure tcustomstringgrid.docellevent(var info: celleventinfoty);
begin
 inherited;
 with info do begin
  case eventkind of
   cek_enter: begin
    setupeditor(newcell,true);
   end;
   cek_exit: begin
    feditor.dodefocus;
   end;
  end;
 end;
end;

procedure tcustomstringgrid.scrolled(const dist: pointty);
var
 po1: pointty;
begin
 inherited;
 if focusedcellvalid then begin
  po1:= dist;
  if not scrollingcol then begin
   po1.x:= 0;
  end;
  feditor.scroll(po1);
 end;
end;

procedure tcustomstringgrid.firstcellclick(const cell: gridcoordty;
                                           const info: mouseeventinfoty);
begin
 inherited;
 feditor.setfirstclick;
end;

procedure tcustomstringgrid.clientmouseevent(var info: mouseeventinfoty);
var
 bo2: boolean;
begin
 bo2:= gs_cellclicked in fstate;
 inherited;
 if not (es_processed in info.eventstate) and focusedcellvalid and
         (info.eventkind in mouseposevents) and
               (gridcoordisequal(ffocusedcell,fmousecell) or bo2) then begin
  feditor.mouseevent(info);
 end;
end;

procedure tcustomstringgrid.doactivate;
begin
 if focusedcellvalid then begin
  feditor.doactivate;
 end;
 inherited;
end;

procedure tcustomstringgrid.dodeactivate;
begin
 if focusedcellvalid then begin
  feditor.dodeactivate;
 end;
 inherited;
end;

procedure tcustomstringgrid.dokeydown(var info: keyeventinfoty);
begin
 if focusedcellvalid then begin
  feditor.dokeydown(info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function tcustomstringgrid.copyselection: boolean;
var
 ar1: gridcoordarty;
 wstr1: msestring;
 int1,int2: integer;
begin
 result:= false;
 ar1:= nil; //compiler waring
// if feditor.sellength = 0 then begin
  ar1:= datacols.selectedcells;
  if ar1 <> nil then begin
   wstr1:= '';
   int2:= ar1[0].row;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1].row <> int2 then begin
     removetabterminator(wstr1);
     wstr1:= wstr1 + lineend;
     int2:= ar1[int1].row;
    end;
    if co_cancopy in datacols[ar1[int1].col].foptions then begin
     wstr1:= wstr1 + self.items[ar1[int1]] + c_tab;
    end;
   end;
   removetabterminator(wstr1);
   wstr1:= wstr1 + lineend; //terminator
   msewidgets.copytoclipboard(wstr1);
   result:= true;
  end;
// end;
end;

function tcustomstringgrid.pasteselection: boolean;
var
 wstr1: msestring;
 int1,int2,int3,int5: integer;
 ar4,ar5: msestringarty;
 {bo1,}bo2: boolean;
begin
 result:= false;
// bo1:= false;
 ar4:= nil; //compiler warning
 ar5:= nil; //compiler warning
{ 
 for int1:= 0 to datacols.count - 1 do begin
  if co_canpaste in datacols[int1].options then begin
   bo1:= true;
   break;
  end;
 end;
 }
 if fdatacols.canpaste{bo1} and pastefromclipboard(wstr1) then begin
  ar4:= breaklines(wstr1);
  if high(ar4) > 0 then begin
   if ar4[high(ar4)] = '' then begin
    setlength(ar4,high(ar4)); //remove terminator
   end;
   int5:= row;
   beginupdate;
   try
    datacols.clearselection;
    int1:= row;
    bo2:= og_rowinserting in optionsgrid;
    if bo2 then begin
     insertrow(row,length(ar4));
    end;
    if high(ar4) >= rowcount - int1 then begin
     setlength(ar4,rowcount-int1);
    end;
    for int2:= int1 to int1 + high(ar4) do begin
    end;
    for int1:= 0 to high(ar4) do begin
     if bo2 then begin
      datacols.selected[makegridcoord(invalidaxis,int5)]:= true;
     end;
     ar5:= splitstring(ar4[int1],c_tab);
     int3:= 0;
     for int2:= 0 to high(ar5) do begin
      while (int3 < datacols.count) and
                 not (co_canpaste in datacols[int3].options) do begin
       inc(int3);
      end;
      if int3 >= datacols.count then begin
       break;
      end;
      if not bo2 then begin
       datacols[int3].selected[int5]:= true;
      end;
      datacols[int3][int5]:= ar5[int2];
      inc(int3);
     end;
     inc(int5);
    end;
   finally
    endupdate;
   end;
   result:= true;
  end;
 end;
end;

procedure tcustomstringgrid.editnotification(var info: editnotificationinfoty);
var
 frame1: framety;
 bo1: boolean;
begin
 if focusedcellvalid then begin
  with tcustomstringcol(fdatacols[ffocusedcell.col]) do begin
   case info.action of
    ea_textedited: begin
     modified;
    end;
    ea_textentered: begin
     bo1:= true;
     if (gps_edited in fstate) or 
           (scoe_forcereturncheckvalue in foptionsedit) then begin
      include(fstate,gps_edited);
      bo1:= docheckcellvalue;
      if scoe_eatreturn in foptionsedit then begin
       info.action:= ea_none;
      end;
     end;
     if bo1 and (og_colchangeonreturnkey in fgrid.optionsgrid) then begin
      info.action:= ea_none;
      fgrid.colstep(fca_focusin,1,true,false);
     end;
    end;
    ea_undo: begin
     exclude(fstate,gps_edited);
    end;
    ea_caretupdating: begin
     frame1:= nullframe;
     if fframe <> nil then begin
      frame1:= fframe.innerframe;
     end
     else begin
      frame1.left:= fcellinfo.innerrect.x;
     end;
     addpoint1(info.caretrect.pos,
          showcaretrect(info.caretrect,frame1));
    end;
    {
    ea_copyselection: begin
     if copyselection then begin
      info.action:= ea_none;
     end;
    end;
    ea_pasteselection: begin
     if pasteselection then begin
      info.action:= ea_none;
     end;
    end;
    }
   end;
  end;
 end;
end;

procedure tcustomstringgrid.dofontheightdelta(var delta: integer);
begin
 inherited;
 if ow_autoscale in foptionswidget then begin
  datarowheight:= datarowheight + delta;
 end; 
end;

procedure tcustomstringgrid.checkcellvalue(var accept: boolean);
var
 mstr1: msestring;
 strcol: tcustomstringcol;
begin
 if  isdatacell(ffocusedcell) 
                  and not (oe_readonly in feditor.optionsedit) then begin
  strcol:= datacols[ffocusedcell.col];
  if gps_edited in strcol.fstate then begin
   mstr1:= feditor.text;
   strcol.updatedisptext(mstr1);
   if canevent(tmethod(strcol.fonsetvalue)) then begin
    strcol.fonsetvalue(strcol,mstr1,accept);
   end;
   if accept then begin                
    items[ffocusedcell]:= mstr1;
    if canevent(tmethod(strcol.fondataentered)) then begin
     strcol.fondataentered(strcol);
    end;
   end;
   exclude(strcol.fstate,gps_edited);
   feditor.dofocus;
  end;
 end;
end;

procedure tcustomstringgrid.rootchanged;
begin
 inherited;
 feditor.poschanged;
end;

procedure tcustomstringgrid.updatelayout;
var
 rect1,rect2: rectty;
begin
// rect1:= cellrect(ffocusedcell,cil_inner);
 inherited;
 if focusedcellvalid then begin
  rect2:= cellrect(ffocusedcell,cil_inner);
//  if (rect2.cx <> rect1.cx) or (rect2.cy <> rect1.cy) then begin
   feditor.updatepos(rect2,rect2);
//  end
//  else begin
//   feditor.scroll(subpoint(rect2.pos,rect1.pos));
//   feditor.updatecaret;
//  end;
 end;
end;

function tcustomstringgrid.getoptionsedit: optionseditty;
begin
 result:= [oe_exitoncursor];
 with tcustomstringcol(fdatacols[ffocusedcell.col]) do begin
  if (ffocusedcell.col < 0) or isreadonly{(co_readonly in foptions)} then begin
   include(result,oe_readonly);
  end;
  stringcoltooptionsedit(foptionsedit,result);
 end;
end;

procedure tcustomstringgrid.updatecopytoclipboard(var atext: msestring);
begin
 with tcustomstringcol(fdatacols[ffocusedcell.col]) do begin
  if canevent(tmethod(foncopytoclipboard)) then begin
   foncopytoclipboard(self,atext);
  end;
 end;
end;

procedure tcustomstringgrid.updatepastefromclipboard(var atext: msestring);
begin
 with tcustomstringcol(fdatacols[ffocusedcell.col]) do begin
  if canevent(tmethod(fonpastefromclipboard)) then begin
   fonpastefromclipboard(self,atext);
  end;
 end;
end;


function tcustomstringgrid.hasselection: boolean;
begin
 result:= false;
end;

function tcustomstringgrid.getitems(const cell: gridcoordty): msestring;
begin
 result:= cols[cell.col][cell.row];
end;

procedure tcustomstringgrid.setitems(const cell: gridcoordty; const Value: msestring);
begin
 cols[cell.col][cell.row]:= value;
end;

function tcustomstringgrid.getcaretwidth: integer;
begin
 result:= feditor.caretwidth;
end;

procedure tcustomstringgrid.setcaretwidth(const value: integer);
begin
 tinplaceedit1(feditor).fcaretwidth:= value;
end;

procedure tcustomstringgrid.synctofontheight;
begin
 inherited;
 if ow_fontlineheight in optionswidget then begin
  datarowheight:= font.lineheight;
 end
 else begin
  with fdatacols.finnerframe do begin
   datarowheight:= font.glyphheight + top + bottom;
  end;
 end;
end;

function tcustomstringgrid.textclipped(const acell: gridcoordty;
                 out acellrect: rectty): boolean;
var
 rect2: rectty;
 canvas1: tcanvas;
begin
 result:= isdatacell(acell);
 if result then begin
  acellrect:= clippedcellrect(acell,cil_inner);
  canvas1:= getcanvas;
  with datacols[acell.col] do begin
   rect2:= textrect(canvas1,items[acell.row],acellrect,textflags,font);
  end;
  result:= not rectinrect(rect2,acellrect);
 end
 else begin
  acellrect:= nullrect;
 end;
end;

function tcustomstringgrid.textclipped(const acell: gridcoordty): boolean;
var
 rect1: rectty;
begin
 result:= textclipped(acell,rect1);
end;

function tcustomstringgrid.appendrow(const value: msestringarty): integer;
var
 int1: integer;
begin
 inherited appendrow;
 result:= frowcount-1;
 for int1:= 0 to high(value) do begin
  datacols[int1][result]:= value[int1];
 end;
end;

function tcustomstringgrid.appendrow(const value: array of msestring): integer;
var
 int1: integer;
begin
 inherited appendrow;
 result:= frowcount-1;
 for int1:= 0 to high(value) do begin
  datacols[int1][result]:= value[int1];
 end;
end;

function tcustomstringgrid.appendrow(const value: msestring): integer;
var
 ar1: msestringarty;
begin
 setlength(ar1,1);
 ar1[0]:= value;
 result:= appendrow(ar1);
end;

function tcustomstringgrid.getcaretcliprect: rectty;
begin
 result:= intersectrect(moverect(fdatarect,clientpos),cellrect(ffocusedcell));
end;

function tcustomstringgrid.canclose(const newfocus: twidget): boolean;
begin
 result:= inherited canclose(newfocus);
 if result then begin
  checkcellvalue(result);
 end;
end;

function tcustomstringgrid.currentdatalist: tmsestringdatalist;
begin
 result:= nil;
 if ffocusedcell.col >= 0 then begin
  result:= tmsestringdatalist(
           tcustomstringcol(fdatacols.fitems[ffocusedcell.col]).fdata);
 end;
end;

function tcustomstringgrid.locatecount: integer;
begin
 result:= rowcount;
 if currentdatalist = nil then begin
  result:= 0;
 end;
end;

function tcustomstringgrid.locatecurrentindex: integer;
begin
 result:= row;
end;

procedure tcustomstringgrid.locatesetcurrentindex(const aindex: integer);
begin
 row:= aindex;
end;

function tcustomstringgrid.getkeystring(const aindex: integer): msestring;
var
 list1: tmsestringdatalist; 
begin
 result:= '';
 list1:= currentdatalist;
 if currentdatalist <> nil then begin
  result:= currentdatalist[aindex];
 end;
end;

function tcustomstringgrid.edited: boolean;
begin
 result:= isdatacell(ffocusedcell) and cols[ffocusedcell.col].edited;
end;

{ trowfontarrayprop }

constructor trowfontarrayprop.create(const aowner: tcustomgrid);
begin
 fgrid:= aowner;
 inherited create(nil);
end;

class function trowfontarrayprop.getitemclasstype: persistentclassty;
begin
 result:= tfont;
end;

procedure trowfontarrayprop.createitem(const index: integer;
                                                      var item: tpersistent);
begin
 item:= tfont.create;
 item.Assign(stockobjects.fonts[stf_default]);
end;

{ trowstatelist }

constructor trowstatelist.create(const aowner: tcustomgrid);
var
 level1: rowinfolevelty;
begin
 fgrid:= aowner;
 level1:= ril_normal;
 if og_colmerged in aowner.optionsgrid then begin
  level1:= ril_colmerge;
 end;
 if og_rowheight in aowner.optionsgrid then begin
  level1:= ril_rowheight;
 end;
 inherited create(level1);
end;

destructor trowstatelist.destroy;
begin
 unlinksource(flinkfoldlevel);
 unlinksource(flinkissum);
 inherited;
 fvisiblerowmap.free;
end;

function trowstatelist.isvisible(const arow: integer): boolean;
var
 po1: pintegeraty;
 po2: prowstatety;
 int1: integer;
 by1: byte;
begin
 if arow < fdirtyrow then begin
  result:= prowstatety(inherited getitempo(arow))^.fold and 
                                         currentfoldhiddenmask = 0;
 end
 else begin
  result:= false;
  po2:= datapo;
  inc(pchar(po2),arow*fsize);
  for int1:= arow downto 0 do begin
   by1:= po2^.fold;
   if by1 = 0 then begin
    result:= true;
    break;
   end;
   if (by1 and foldhiddenmask <> 0) or (by1 and foldlevelmask = 0) then begin
    break;
   end;
   dec(pchar(po2),fsize);
  end;  
 end;
end;

procedure trowstatelist.counthidden(var aindex: integer);
var                    //todo: optimize
 po1: prowstatety;
 level1,level2: byte;
begin
 po1:= datapo;
 inc(pchar(po1),aindex*fsize);
 level1:= po1^.fold and foldlevelmask;
 while (aindex < count) do begin
  level2:= po1^.fold and foldlevelmask;
  if level2 < level1 then begin
   break;
  end;
  if po1^.fold and foldhiddenmask = 0 then begin
   if level2 > level1 then begin
    counthidden(aindex);
   end
   else begin //same level
    inc(fhiddencount);
    inc(aindex);
    inc(pchar(po1),fsize);
   end;
  end
  else begin
   inc(aindex);
   inc(pchar(po1),fsize);
  end;
 end;  
end;

procedure trowstatelist.recalchidden;
var
 int1: integer;
 po1: prowstatety;
 lev1: byte;
 s1: integer;
begin
 checkdirty(0);
 fhiddencount:= 0;
 po1:= datapo;
 int1:= count;
 s1:= size;
 while int1 > 0 do begin
  if po1^.fold and foldhiddenmask <> 0 then begin
   inc(fhiddencount);
   lev1:= po1^.fold and foldlevelmask;
   dec(int1);
   inc(pchar(po1),s1);
   while (int1 > 0) and (po1^.fold and foldlevelmask > lev1) do begin
    inc(fhiddencount);
    dec(int1);
    inc(pchar(po1),s1);
   end;
  end
  else begin
   dec(int1);
   inc(pchar(po1),s1);
  end;
 end;
end;

procedure trowstatelist.setupfoldinfo(asource: pbyte;
               const acount: integer);
var
 po1: prowstatety;
 var int1: integer;
 s1: integer;
begin
 fgrid.rowcount:= acount;
 po1:= datapo;
 s1:= size;
 for int1:= count-1 downto 0 do begin
  po1^.fold:= asource^;
  inc(pchar(po1),s1);
  inc(asource);
 end;
 recalchidden;
end;

procedure trowstatelist.internalshow(var aindex: integer);
var
 int1,int2: integer;
 po1: prowstatety;
begin
 dec(fhiddencount);
 int1:= aindex+1;
 if (int1 < count) then begin
  po1:= datapo;
  inc(pchar(po1),fsize*aindex);
  if (prowstatety(pchar(po1)+fsize)^.fold and foldlevelmask) > 
                            (po1^.fold and foldlevelmask) then begin
   int2:= fhiddencount;
   counthidden(int1);
   fhiddencount:= fhiddencount - 2*(fhiddencount-int2);
  end;
 end;
 aindex:= int1;
end;

procedure trowstatelist.show(const aindex: integer);
var
 int1: integer;
begin
 int1:= aindex;
 internalshow(int1);
 checkdirty(aindex);
end;

procedure trowstatelist.internalhide(var aindex: integer);
var
 int1: integer; 
 po1: prowstatety;
begin
 inc(fhiddencount);
 int1:= aindex+1;
 if (int1 < count) then begin
  po1:= datapo;
  inc(pchar(po1),int1*fsize);
  if (po1^.fold and foldlevelmask) > 
             (prowstatety(pchar(po1)-fsize)^.fold and foldlevelmask) then begin
   counthidden(int1);
  end;
 end;
 aindex:= int1;
end;

procedure trowstatelist.hide(const aindex: integer);
var
 int1: integer;
begin
 int1:= aindex; 
 internalhide(int1);
 checkdirty(aindex);
end;

procedure trowstatelist.hidechildren(const arow: integer);
var
 int1,int2: integer; 
 po0: pchar;
 po1: prowstatety;
 level1,level2: byte;
 bo1: boolean;
 s1: integer;
begin
 checkindexrange(arow);
 po0:= datapo;
 s1:= size;
 po1:= prowstatety(po0+arow*s1);
 level1:= po1^.fold and foldlevelmask;
 int1:= arow+1;
 bo1:= false;
 while int1 < count do begin
  po1:= prowstatety(po0+int1*s1);
  with po1^ do begin
   level2:= fold and foldlevelmask;
   if level2 <= level1 then begin
    break;
   end;
   if fold and foldhiddenmask = 0 then begin
    bo1:= true;
    fold:= fold or foldhiddenmask;
    fgrid.rowstatechanged(int1);
    internalhide(int1);
   end
   else begin
    while (int1 < count) and (po1^.fold and foldhiddenmask >
                                                          level2) do begin
     inc(int1);
     inc(pchar(po1),s1);
    end;
   end;
  end;
 end;
 if bo1 then begin
  checkdirty(arow+1);
  fgrid.layoutchanged;
 end;
end;

procedure trowstatelist.showchildren(const arow: integer);
var
 int1,int2: integer; 
 po0: pchar;
 po1: prowstatety;
 level1,level2: byte;
 bo1: boolean;
 s1: integer;
begin
 checkindexrange(arow);
 po0:= datapo;
 s1:= size;
 po1:= prowstatety(po0+arow*s1);
 level1:= po1^.fold and foldlevelmask;
 int1:= arow+1;
 bo1:= false;
 while int1 < count do begin
  po1:= prowstatety(po0+int1*s1);
  int2:= int1;
  with po1^ do begin
   level2:= fold and foldlevelmask;
   if level2 <= level1 then begin
    break;
   end;
   if fold and foldhiddenmask <> 0 then begin
    bo1:= true;
    fold:= fold and not foldhiddenmask;
    fgrid.rowstatechanged(int1);
    internalshow(int1);
   end
   else begin
    while (int1 < count) and (po1^.fold and foldhiddenmask >
                                                          level2) do begin
     inc(int1);
     inc(pchar(po1),s1);
    end;
   end;
  end;
  if int1 = int2 then begin
   break; //invalid
  end;
 end;
 if bo1 then begin
  checkdirty(arow+1);
  fgrid.layoutchanged;
 end;
end;

procedure trowstatelist.sethidden(const index: integer; const avalue: boolean);
var
 po1: prowstatety;
 bo1: boolean;
begin
 if ffolded then begin
  po1:= getitempo(index);
  bo1:= isvisible(index);
  if updatebit(po1^.fold,foldhiddenbit,avalue) then begin
   if avalue then begin        
    if bo1 then begin
     hide(index);
    end;
   end
   else begin
    if not bo1 then begin
     show(index);
    end;
   end;
   fgrid.layoutchanged;
   fgrid.rowstatechanged(index);
  end;
 end
 else begin
  raise exception.create('Grid not folded.');
 end;
end;

procedure trowstatelist.setfoldlevel(const index: integer; avalue: byte);
var
 po1,po2: prowstatety;
 by1,by2: byte;
 delta: integer;
 int1: integer;
 bo1: boolean;
begin
 bo1:= of_validatelevel in fgrid.foptionsfold;
 if bo1 then begin
  if index = 0 then begin
   if avalue = 0 then begin
    bo1:= false;
   end;
   avalue:= 0;
  end
  else begin
   by1:= (getitempo(index-1)^.fold and foldlevelmask) + 1;
   if avalue > by1 then begin
    avalue:= by1;
   end
   else begin
    bo1:= false;
   end;
  end;
 end;  //bo1 -> avalue modified
 
 if of_shiftchildren in fgrid.foptionsfold then begin
  normalizering;
  po1:= getitempo(index);
  po2:= po1;
  by1:= po1^.fold and foldlevelmask;  
  delta:= integer(avalue) - integer(by1);
  if delta <> 0 then begin
   for int1:= index to fcount-1 do begin
    by2:= po1^.fold and foldlevelmask;
    if (by2 <= by1) and (int1 <> index) then begin
     break;
    end;
    by2:= by2 + delta;
    po1^.fold:= po1^.fold and not foldlevelmask or by2 and foldlevelmask;
    inc(pbyte(po1),fsize);
   end;
   checkdirty(index);
   checksyncfoldlevelsource(index,(pchar(po1)-pchar(po2)) div fsize);
  end
  else begin
   if bo1 then begin
    checksyncfoldlevelsource(index,1);
   end;
  end;
 end
 else begin
  po1:= getitempo(index);
  if replacebits1(byte(po1^.fold),byte(avalue),byte(foldlevelmask)) then begin
   checkdirty(index);
//   change(index);
//   if bo1 then begin
    checksyncfoldlevelsource(index,1);
//   end
//   else begin
//    fgrid.rowstatechanged(index);
//   end;
  end
  else begin
   if bo1 then begin
    checksyncfoldlevelsource(index,1);
   end;
  end;
 end;
end;

procedure trowstatelist.setfoldissum(const index: integer;
               const avalue: boolean);
var
 po1: prowstatety;
 bo1: boolean;
begin
 po1:= getitempo(index);
 bo1:= po1^.flags and foldissummask <> 0;
 if bo1 xor avalue then begin
  if avalue then begin
   po1^.flags:= po1^.flags or foldissummask;
  end
  else begin
   po1^.flags:= po1^.flags and not foldissummask;
  end;
  checkdirty(index);
  checksyncfoldissumsource(index,1);
//  change(index);
//  fgrid.rowstatechanged(index);
 end;
end;

procedure trowstatelist.foldleveltosource(const index: integer;
                                                    const acount: integer);
var
 po1: prowstatety;
 po2: pinteger;
 int1: integer;
begin
 inc(ffoldlevelsourcelock);
 try
  with flinkfoldlevel.source do begin
   if acount > 1 then begin
    self.normalizering;
    normalizering;
   end;
   po1:= self.getitempo(index);
   po2:= getitempo(index);
   for int1:= 0 to acount-1 do begin
    po2^:= po1^.fold and foldlevelmask;
    inc(pchar(po1),self.size);
    inc(pchar(po2),size);
   end;
   if acount = 1 then begin
    change(index);
   end
   else begin
    change(-1);
   end;
  end;
  if acount = 1 then begin
   change(index);
   fgrid.rowstatechanged(index);
  end
  else begin
   change(-1);
   fgrid.rowstatechanged(-1);
  end;
 finally
  dec(ffoldlevelsourcelock);
 end;
end;

procedure trowstatelist.foldissumtosource(const index: integer;
                                                    const acount: integer);
var
 po1: prowstatety;
 po2: pinteger;
 int1: integer;
begin
 inc(fissumsourcelock);
 try
  with flinkissum.source do begin
   if acount > 1 then begin
    self.normalizering;
    normalizering;
   end;
   po1:= self.getitempo(index);
   po2:= getitempo(index);
   for int1:= 0 to acount-1 do begin
    if po1^.flags and foldissummask <> 0 then begin
     po2^:= longint(longbool(true));
    end
    else begin
     po2^:= 0;
    end;
    inc(pchar(po1),self.size);
    inc(pchar(po2),size);
   end;
   if acount = 1 then begin
    change(index);
   end
   else begin
    change(-1);
   end;
  end;
  if acount = 1 then begin
   change(index);
   fgrid.rowstatechanged(index);
  end
  else begin
   change(-1);
   fgrid.rowstatechanged(-1);
  end;
 finally
  dec(fissumsourcelock);
 end;
end;

procedure trowstatelist.fillfoldlevel(const index: integer; 
                             const acount: integer; const avalue: byte);
var
 po1: prowstatety;
 int1: integer;
 bo1: boolean;
begin
 if acount > 0 then begin
  checkindexrange(index,acount);
  normalizering;
  po1:= getitempo(index);
  checkdirty(index);
  bo1:= false;
  for int1:= 0 to acount-1 do begin
   bo1:= bo1 or replacebits1(byte(po1^.fold),byte(avalue),byte(foldlevelmask));
   inc(pbyte(po1),fsize);
  end;
  if bo1 then begin
   checksyncfoldlevelsource(index,acount);
  end;
 end;
end;

procedure trowstatelist.setfolded(const avalue: boolean);
begin
 if avalue <> ffolded then begin
  ffolded:= avalue;
  if avalue then begin
   setlength(fvisiblerows,count);
   fvisiblerowmap:= tintegerdatalist.create;
   fvisiblerowmap.count:= count;
   fdirtyvisible:= 0;
   fdirtyrow:= 0;
  end
  else begin
   fvisiblerows:= nil;
   freeandnil(fvisiblerowmap);
   fhiddencount:= 0;
  end;
  checkdirty(0); 
 end;
end;

function trowstatelist.cellrow(const arow: integer): integer;
begin
 result:= arow;
 if ffolded and (arow >= 0) then begin
  clean(arow);
  result:= fvisiblerowmap[arow];
 end;
end;

procedure trowstatelist.checkdirty(const arow: integer);
begin
 if ffolded then begin
  if arow < fdirtyrowheight then begin
   fdirtyrowheight:= arow;
  end;
  if arow < fdirtyrow then begin
   fdirtyrow:= arow;
   fdirtyvisible:= 0;
   if arow > 0 then begin
    fdirtyvisible:= fvisiblerowmap[arow-1];
   end;
   fgrid.layoutchanged;
  end;
  if arow < ffoldchangedrow then begin
   ffoldchangedrow:= arow;
  end;
 end;
end;

procedure trowstatelist.checkdirtyautorowheight(const arow: integer);
begin
 if arow < 0 then begin
  fdirtyrowheight:= 0;
  fdirtyautorowheight:= 0;
 end
 else begin
  if finfolevel >= ril_rowheight then begin
   with prowstaterowheightty(getitempo(arow))^ do begin
    if rowheight.height <= 0 then begin
     rowheight.height:= 0;
    end
    else begin
     exit;
    end;
   end;
  end;
  if arow < fdirtyrowheight then begin
   fdirtyrowheight:= arow;
  end
  else begin
   exit;
  end;
 end;   
 fgrid.layoutchanged;
end;

procedure trowstatelist.change(const index: integer);
begin
 if (finfolevel >= ril_rowheight) and (index < 0) then begin
  fdirtyrowheight:= 0;
  fdirtyautorowheight:= 0;
  inherited;
  fgrid.layoutchanged;
 end
 else begin
  inherited;
 end;
end;

procedure copyfoldlevel(const source,dest: pointer);
begin
 prowstatety(dest)^.fold:= prowstatety(dest)^.fold and not foldlevelmask
                          or pinteger(source)^ and foldlevelmask;
end;

procedure copyissum(const source,dest: pointer);
begin
 if pinteger(source)^ <> 0 then begin
  prowstatety(dest)^.flags:= prowstatety(dest)^.flags or foldissummask;
 end
 else begin
  prowstatety(dest)^.flags:= prowstatety(dest)^.flags and not foldissummask;
 end;
end;

procedure trowstatelist.cleanfolding(arow: integer; visibleindex: integer);
var
 int1,int2: integer;
 rowstat1: prowstatety;
 visirow1: pinteger;
 level1: byte;
begin                  //todo: optimize
 checksourcecopy(flinkfoldlevel,@copyfoldlevel);
 checksourcecopy(flinkissum,@copyissum);
 int2:= 0;
 if fdirtyvisible > 0 then begin
  int2:= fvisiblerows[fdirtyvisible-1]+1;  //first row to check
 end;
 rowstat1:= prowstatety(pchar(datapo)+int2*fsize);
 visirow1:= @pintegeraty(fvisiblerowmap.datapo)^[int2];
 int1:= fdirtyvisible-1; //visible row index
 while int1 < visibleindex do begin
  while (rowstat1^.fold and foldhiddenmask <> 0) and (int2 <= arow) do begin
   rowstat1^.fold:= rowstat1^.fold or currentfoldhiddenmask;
   level1:= rowstat1^.fold and foldlevelmask;
   visirow1^:= int1;
   inc(pchar(rowstat1),fsize);
   inc(visirow1);
   inc(int2);
   while (int2 <= arow) and 
                     (rowstat1^.fold and foldlevelmask > level1) do begin
    visirow1^:= int1;
    rowstat1^.fold:= rowstat1^.fold or currentfoldhiddenmask;
    inc(pchar(rowstat1),fsize);
    inc(visirow1);
    inc(int2);
   end;
  end;
  if int2 <= arow then begin
   inc(int1);
   visirow1^:= int1;
   if int1 > high(fvisiblerows) then begin //?????
    setlength(fvisiblerows,high(fvisiblerows)+2);
   end;
   fvisiblerows[int1]:= int2;
   rowstat1^.fold:= rowstat1^.fold and not currentfoldhiddenmask;
   inc(int2);
   inc(pchar(rowstat1),fsize);
   inc(visirow1);
  end
  else begin
   break;
  end;
 end;
 fdirtyvisible:= int1 + 1;
 fdirtyrow:= int2;
end;

procedure trowstatelist.cleanvisible(visibleindex: integer);
var
 int1: integer;
begin
 if ffolded then begin
  int1:= visiblerowcount;
  if visibleindex >= int1 then begin
   visibleindex:= int1 - 1;
  end;
  if (visibleindex >= fdirtyvisible) then begin
   cleanfolding(count-1,visibleindex);
  end;
 end;
end;

procedure trowstatelist.clean(arow: integer);
var
 int1: integer;
begin
 if ffolded then begin
  int1:= count;
  if arow >= int1 then begin
   arow:= int1 -1;
  end;
  if  arow >= fdirtyrow then begin
   cleanfolding(arow,bigint);
  end;
 end;
end;

procedure trowstatelist.cleanrowheight(const aindex: integer);

//todo: optimize cleaning with co1_autorowheight 

var
 int1,int2,int3,int4,int5: integer;
 po1: prowstaterowheightty;
 po2: pintegeraty;
 needsrowheightupdate: boolean;
begin
 if aindex >= fdirtyrowheight then begin
  ftopypos:= 0;
  if count > 0 then begin
   needsrowheightupdate:= gs_needsrowheight in fgrid.fstate;  
   po1:= dataporowheight;
   inc(pchar(po1),fdirtyrowheight*fsize);
   int3:= po1^.rowheight.ypos;
   if ffolded then begin
    cleanvisible(aindex);
    po2:= fvisiblerowmap.datapo;
   end;
   for int1:= fdirtyrowheight to aindex do begin
    if po1^.rowheight.linewidth = 0 then begin
     int4:= fgrid.fdatarowlinewidth;
    end
    else begin
     int4:= po1^.rowheight.linewidth;
    end;
    int2:= fgrid.fdatarowheight + int4;
    po1^.rowheight.ypos:= int3;
    if not folded or (po1^.normal.fold and currentfoldhiddenmask = 0) then begin
     if po1^.rowheight.height <= 0 then begin
      if needsrowheightupdate then begin
       int5:= fgrid.fdatarowheight;
       if (po1^.rowheight.height = 0) or (int1 >= fdirtyautorowheight) then begin
        fgrid.updaterowheight(int1,int5);
        po1^.rowheight.height:= -int5;
       end
       else begin
        int5:= -po1^.rowheight.height;
       end;
       int3:= int3 + int5 + int4;
      end
      else begin
       int3:= int3 + int2;
      end;
     end
     else begin
      int3:= int3 + po1^.rowheight.height + int4;
     end;
    end;
    inc(pchar(po1),fsize);
   end; 
   if aindex >= count-1 then begin
    ftopypos:= int3;
   end
   else begin
    po1^.rowheight.ypos:= int3;
   end;
   fdirtyrowheight:= aindex+1;
   if fdirtyrowheight > fdirtyautorowheight then begin
    fdirtyautorowheight:= fdirtyrowheight;
   end;
  end;
 end;
end;


function trowstatelist.visiblerows1(const astart: integer;
               const aendy: integer): integerarty;
var
 int1,int2: integer;
 acount: integer;
begin                         //todo: optimize
 result:= nil;
 if count > 0 then begin
  if og_rowheight in fgrid.foptionsgrid then begin
   int1:= rowindex(aendy);
   if int1 < 0 then begin
    acount:= cellrow(count-1);
   end
   else begin
    acount:= cellrow(int1);
   end;
  end
  else begin
   acount:= aendy div fgrid.fdatarowheight;
  end;
  acount:= acount - astart + 2;
  if ffolded then begin
   cleanvisible(astart+acount);
   int1:= visiblerowcount;
   if astart + acount > int1 then begin
    acount:= int1 - astart;
   end;
   if acount > 0 then begin
    result:= copy(fvisiblerows,astart,acount);
   end
   else begin
    result:= nil;
   end;
  end
  else begin
   int1:= count - astart;
   if acount > int1 then begin
    acount:= int1;
   end;
   setlength(result,acount);
   int2:= astart;
   for int1:= 0 to high(result) do begin
    result[int1]:= int2;
    inc(int2);
   end;
  end;
 end;
end;

procedure trowstatelist.updatefoldinfo(const rows: integerarty;
                                           var infos: rowfoldinfoarty);
var
 int1,int2: integer;
 po1: prowstatety;
 po2: prowstatety;
 po3: prowfoldinfoty;
 level1,level2: byte;
 lastrow: integer;
 visible1: boolean;
 ar1: booleanarty;
begin
 setlength(infos,length(rows));
 if high(rows) >= 0 then begin
  for int1:= high(rows) downto 0 do begin
   with infos[int1] do begin
    getfoldstate(rows[int1],isvisible,foldlevel,haschildren,isopen);
    setlength(nolines,foldlevel);
    fillchar(nolines[0],(foldlevel)*sizeof(boolean),0);
   end;
  end;
  po1:= datapo;
  lastrow:= rows[high(rows)];
  po2:= prowstatety(pchar(po1)+lastrow*fsize);
  level1:= po2^.fold and foldlevelmask; //level of last row
  setlength(ar1,level1+1);
  for int1:= lastrow+1 to count-1 do begin  //mark linecontinuations
   inc(pchar(po2),fsize);
   with po2^ do begin
    if fold and foldhiddenmask = 0 then begin
     level2:= fold and foldlevelmask;
     if (level2 = 0) then begin
      break;
     end;
     if level2 <= level1 then begin
      ar1[level2]:= true;              //line continuation found
      level1:= level2;
     end;
    end;
   end;
  end;
  po3:= @infos[high(infos)];
  for int1:= high(ar1) downto 1 do begin
   po3^.nolines[int1-1]:= not ar1[int1]; //set missing continuations
  end;
  for int1:= high(infos) - 1 downto 0 do begin
   with infos[int1] do begin
    for int2:= 0 to high(nolines) do begin
     nolines[int2]:= (int2 > high(po3^.nolines)) or 
           (int2 < high(po3^.nolines)) and po3^.nolines[int2];
    end;
   end;
   dec(po3);
  end;
 end;
end;

function trowstatelist.visiblerowstep(const arow: integer; const step: integer;
                                  const autoappend: boolean): integer;
begin
 if not folded then begin
  result:= arow + step;
  if result < 0 then begin
   result:= 0;
  end;
  if result >= fgrid.frowcount then begin
   if autoappend then begin
    result:= fgrid.frowcount;
   end
   else begin
    result:= fgrid.frowcount - 1;
   end;
  end;
 end
 else begin
  result:= visiblerowtoindex(visiblerow(arow)+step);
  if result < 0 then begin
   if step < 0 then begin
    result:= visiblerowtoindex(0);
   end
   else begin
    if autoappend then begin
     result:= fgrid.frowcount;
    end
    else begin
     if visiblerowcount > 0 then begin
      result:= visiblerowtoindex(visiblerowcount - 1);
     end;
    end;
   end;
  end;
 end;
end;

function trowstatelist.visiblerow(const arowindex: integer): integer;
begin
 result:= invalidaxis;
 if (arowindex >= 0) and (arowindex < count) then begin
  if not ffolded then begin
   result:= arowindex;
  end
  else begin
   if not hidden[arowindex] then begin
    clean(arowindex);
    result:= fvisiblerowmap[arowindex];
   end;
  end;
 end;
end;

function trowstatelist.visiblerowcount: integer;
begin
 result:= count - fhiddencount;
end;

function trowstatelist.visiblerowtoindex(const avisibleindex: integer): integer;
begin
 result:= invalidaxis;
 if (avisibleindex >= 0) then begin
  if not ffolded then begin
   if avisibleindex < count then begin
    result:= avisibleindex;
   end;
  end
  else begin
   if avisibleindex < visiblerowcount then begin
    cleanvisible(avisibleindex);
    result:= fvisiblerows[avisibleindex];
   end;
  end;
 end;
end;
{
procedure trowstatelist.setcount(const value: integer);
var
 bo1: boolean;
begin
 if ffolded then begin
  bo1:= value < fcount;
  setlength(fvisiblerows,count); //?????
  inherited;
  if bo1 then begin
   setlength(fvisiblerows,count); //?????
  end;
 end
 else begin
  inherited;
 end;
end;

procedure trowstatelist.clearbuffer;
begin
 fvisiblerows:= nil;
 inherited;
end;
}
procedure trowstatelist.updatedeletedrows(const index: integer;
                                                  const acount: integer);
var
 int1: integer;
 int2: integer;
 po1: pinteger;
begin
 if acount >= count then begin
  fhiddencount:= 0;
 end
 else begin
  clean(index+acount-1);
  po1:= @pintegeraty(fvisiblerowmap.datapo)[index];
  dec(po1);
  if index = 0 then begin
   int2:= -1;
  end
  else begin
   int2:= po1^;
  end;
  for int1:= acount-1 downto 0 do begin
   inc(po1);
   if (po1^ = int2) then begin
    dec(fhiddencount);
   end;
   int2:= po1^;
  end;
 end;
 checkdirty(index);
end;

function trowstatelist.rowhidden(const arow: integer): boolean;
begin
 result:= ffolded;
 if result then begin
  result:= hidden[arow];
 end;
end;

function trowstatelist.nearestvisiblerow(const arow: integer): integer;
var
 po1: prowstatety;
 int1: integer;
begin
 result:= arow;
 if rowhidden(arow) then begin
  po1:= datapo;
  inc(pbyte(po1),arow*fsize);
  for int1:= arow to count -1 do begin
   if po1^.fold and foldhiddenmask = 0 then begin
    result:= int1;
    exit;
   end;
   inc(pbyte(po1),fsize);
  end;
  result:= invalidaxis;
  po1:= datapo;
  inc(pbyte(po1),(arow-1)*fsize);
  for int1:= arow - 1 downto 0 do begin
   if po1^.fold and foldhiddenmask = 0 then begin
    result:= int1;
    exit;
   end;
   dec(pbyte(po1),fsize);
  end;
 end;
end;

procedure trowstatelist.getfoldstate(const arow: integer; 
                       out aisvisible: boolean; out afoldlevel: byte;
                       out ahaschildren,aisopen: boolean);
var
 po1: prowstatety;
 nextfoldlevel: byte;
 by1: byte;
 bo1: boolean;
begin
 checkindexrange(arow);
 po1:= datapo;
 inc(pchar(po1),arow*fsize);
 with po1^ do begin
  afoldlevel:= fold and foldlevelmask;
  aisvisible:= fold and foldhiddenmask = 0;
  bo1:= arow < count-1;
  if bo1 then begin
   by1:= prowstatety(pchar(po1)+fsize)^.fold;
   nextfoldlevel:= by1 and foldlevelmask;
  end;
  ahaschildren:= bo1 and (nextfoldlevel > afoldlevel);
  aisopen:= ahaschildren and (by1 and foldhiddenmask = 0);
 end;
end;

function trowstatelist.getstatdata(const index: integer): msestring;
var
 int1: integer;
begin
 with prowstaterowheightty(inherited getitempo(index))^ do begin
  result:= inttostr(normal.fold + normal.flags shl 8);
  if finfolevel >= ril_colmerge then begin
   result:= result + ' ' + inttostr(colmerge.merged);
  end;
  if (finfolevel >= ril_rowheight) and 
                      (og_savestate in fgrid.foptionsgrid) then begin
   int1:= rowheight.height;
   if int1 < 0 then begin
    int1:= 0;     //auto height
   end;
   result:= result + ' ' + inttostr(int1);
  end;
 end;
end;

procedure trowstatelist.setstatdata(const index: integer;
               const value: msestring);
var
 ar1: msestringarty;
 int1: integer;
begin
 splitstring(value,ar1,msechar(' '));
 if high(ar1) >= 0 then begin
  with prowstaterowheightty(inherited getitempo(index))^ do begin
   int1:= strtoint(ar1[0]);
   normal.fold:= int1 and $ff;
   normal.flags:= (int1 shr 8) and $ff;
   if (finfolevel >= ril_colmerge) and (high(ar1) > 0) then begin
    colmerge.merged:= strtoint(ar1[1]);
   end;
   if (og_savestate in fgrid.foptionsgrid) and (finfolevel >= ril_rowheight) and (high(ar1) > 1) then begin
    rowheight.height:= strtoint(ar1[2]);
    if (rowheight.height < 0) then begin
     rowheight.height:= 0;
    end;
    if (rowheight.height > 0) and 
                      (rowheight.height < fgrid.fdatarowheightmin) then begin
     rowheight.height:= fgrid.fdatarowheightmin;
    end;
    if rowheight.height > fgrid.fdatarowheightmax then begin
     rowheight.height:= fgrid.fdatarowheightmax;
    end;
   end;
  end;
 end;
end;

procedure trowstatelist.setheight(const index: integer;
               const avalue: integer);
begin
 with getitemporowheight(index)^ do begin
  if avalue <> rowheight.height then begin
   rowheight.height:= avalue;
   if index < fdirtyrowheight then begin
    fdirtyrowheight:= index;
    fgrid.layoutchanged;
   end;
  end;
 end;
end;

procedure trowstatelist.setlinewidth(const index: integer;
               const avalue: integer);
begin
 with getitemporowheight(index)^ do begin
  if avalue <> rowheight.linewidth then begin
   rowheight.linewidth:= avalue;
   if index < fdirtyrowheight then begin
    fdirtyrowheight:= index;
    fgrid.layoutchanged;
   end;
  end;
 end;
end;

function trowstatelist.getrowypos(const index: integer): integer;
begin
 result:= 0;
 if index >= count then begin
  if index > 0 then begin
   cleanrowheight(count-1);
   result:= ftopypos;
  end;
 end
 else begin
  cleanrowheight(index);
  result:= getitemporowheight(index)^.rowheight.ypos;
 end;
end;

function trowstatelist.internalystep(const aindex: integer): integer;
begin
 with prowstaterowheightty(getitempo(aindex))^ do begin
  if aindex >= count - 1 then begin
   result:= ftopypos - rowheight.ypos;
  end
  else begin
   result:= prowstaterowheightty(getitempo(aindex+1))^.rowheight.ypos - rowheight.ypos;
  end;
 end;
end;

procedure trowstatelist.internalystep(const aindex: integer; out ay: integer;
                                   out acy: integer);
begin
 with prowstaterowheightty(getitempo(aindex))^ do begin
  ay:= rowheight.ypos;
  if aindex >= count - 1 then begin
   acy:= ftopypos - ay;
  end
  else begin
   acy:= prowstaterowheightty(getitempo(aindex+1))^.rowheight.ypos - ay;
  end;
 end;
end;

function trowstatelist.internalheight(const aindex: integer): integer;
begin
 with prowstaterowheightty(getitempo(aindex))^ do begin
  if aindex >= count - 1 then begin
   result:= ftopypos - rowheight.ypos;
  end
  else begin
   result:= prowstaterowheightty(getitempo(aindex+1))^.rowheight.ypos - rowheight.ypos;
  end;
 end;
 result:= result - fgrid.fdatarowlinewidth;
end;

function trowstatelist.currentrowheight(const index: integer): integer;
begin
 cleanrowheight(index);
 result:= internalheight(index);
end;

function comprowypos(const l,r): integer;
begin
 result:= integer(l) - rowstaterowheightty(r).rowheight.ypos;
end;

function trowstatelist.rowindex(const aypos: integer): integer;
var
 po1: prowstaterowheightty;
 int1,int2: integer;
 bo1: boolean;
begin
 cleanrowheight(count-1);
 po1:= dataporowheight;
 bo1:= findarrayvalue(aypos,po1,count,@comprowypos,fsize,result);
 if not bo1 then begin
  dec(result);
  if (result = count-1) then begin
   with prowstaterowheightaty(po1)^[result] do begin
    if aypos >= ftopypos then begin
     result:= invalidaxis;
    end;
   end;
  end;
  if (result >= 0) and ffolded then begin
   cleanvisible(result);
   int2:= invalidaxis;
   inc(pbyte(po1),result*fsize);
   for int1:= result downto 0 do begin
    if po1^.normal.fold and currentfoldhiddenmask = 0 then begin
     int2:= int1;
     break;
    end;
    dec(pbyte(po1),fsize);
   end;
   result:= int2;
  end;
 end;
end;

procedure trowstatelist.initdirty;
begin
 fdirtyvisible:= 0;
 fdirtyrow:= 0;
 fdirtyrowheight:= 0;
 fdirtyautorowheight:= 0;
end;

procedure trowstatelist.clearmemberitem(const subitem: integer;
               const index: integer);
begin
 case rowstatememberty(subitem-1) of
  rsm_select: begin
   selected[index]:= 0;
   fgrid.invalidaterow(index); //todo: update selectstate
  end;
  rsm_color: begin
   fgrid.rowcolorstate[index]:= -1;
  end;
  rsm_font: begin
   fgrid.rowfontstate[index]:= -1;
  end;
  rsm_readonly: begin
   fgrid.rowreadonlystate[index]:= false;
  end;
  rsm_foldlevel: begin
   fgrid.rowfoldlevel[index]:= 0;
  end;
  rsm_foldissum: begin
   fgrid.rowfoldissum[index]:= false;
  end;
  rsm_hidden: begin
   if folded then begin
    fgrid.rowhidden[index]:= false;
   end;
  end;
  rsm_merged: begin
   if finfolevel >= ril_colmerge then begin
    merged[index]:= 0;
    fgrid.datacols.mergechanged(index);
   end;
  end;
  rsm_height: begin
   if finfolevel >= ril_rowheight then begin
    fgrid.rowheight[index]:= 0;
   end;
  end;
 end;
end;

procedure trowstatelist.setmemberitem(const subitem: integer;
               const index: integer; const avalue: integer);
begin
 case rowstatememberty(subitem-1) of
  rsm_select: begin
   selected[index]:= avalue;
   fgrid.invalidaterow(index); //todo: update selectstate
  end;
  rsm_color: begin
   fgrid.rowcolorstate[index]:= avalue;
  end;
  rsm_font: begin
   fgrid.rowfontstate[index]:= avalue;
  end;
  rsm_readonly: begin
   fgrid.rowreadonlystate[index]:= avalue <> 0;
  end;
  rsm_foldlevel: begin
   fgrid.rowfoldlevel[index]:= avalue;
  end;
  rsm_foldissum: begin
   fgrid.rowfoldissum[index]:= avalue <> 0;
  end;
  rsm_hidden: begin
   if folded then begin
    fgrid.rowhidden[index]:= avalue <> 0;
   end;
  end;
  rsm_merged: begin
   if finfolevel >= ril_colmerge then begin
    merged[index]:= avalue;
    fgrid.datacols.mergechanged(index);
   end;
  end;
  rsm_height: begin
   if finfolevel >= ril_rowheight then begin
    fgrid.rowheight[index]:= avalue;
   end;
  end;
 end;
end;

function trowstatelist.totchildrencount(const aindex: integer;
               const acount: integer): integer;
var
 lev1,lev2: byte;
 ind1: integer;
 int1: integer;
 po1: prowstatety;
begin
 checkindexrange(aindex,acount);
 normalizering;
 po1:= getitempo(aindex);
 lev1:= po1^.fold and foldlevelmask;
 ind1:= aindex;
 for int1:= acount - 1 downto 0 do begin
  lev2:= po1^.fold and foldlevelmask;
  if lev2 < lev1 then begin
   lev1:= lev2;
   ind1:= aindex - int1 + acount-1
  end;
  inc(pbyte(po1),fsize);
 end; 
 po1:= getitempo(ind1);
 for int1:= ind1+1 to fcount-1 do begin
  inc(pbyte(po1),fsize);
  if po1^.fold and foldlevelmask <= lev2 then begin
   break;
  end;
 end;
 result:= int1 - aindex;
end;

procedure trowstatelist.checksyncfoldlevelsource(const index: integer;
                                 const acount: integer);
var
 int1: integer;
begin
 if flinkfoldlevel.source <> nil then begin
  foldleveltosource(index,acount);
 end
 else begin
  for int1:= index to index + acount - 1 do begin
   change(int1);
   fgrid.rowstatechanged(int1);
  end;
 end;
end;

procedure trowstatelist.checksyncfoldissumsource(const index: integer;
                                 const acount: integer);
begin
 if flinkissum.source <> nil then begin
  foldissumtosource(index,acount);
 end
 else begin
  if acount = 1 then begin
   change(index);
   fgrid.rowstatechanged(index);
  end
  else begin
   change(-1);
   fgrid.rowstatechanged(-1);
  end;
 end;
end;

procedure trowstatelist.movegrouptoparent(const aindex: integer;
                                                const acount: integer);
var
 po1,po2,po3,po4: prowstatety;
 lev1,lev2: integer;
 int1,int2: integer;
 by1: byte;
begin
 if acount > 0 then begin
  checkindexrange(aindex,acount);
  normalizering;
  int1:= aindex+acount-1;
  po1:= getitempo(int1);
  po3:= po1;
  po4:= nil;
  lev1:= 0;
  for int1:= int1 downto aindex do begin
   lev2:= po1^.fold and foldlevelmask;
   po2:= po1;
   for int2:= int1+1 to fcount -1 do begin
    inc(pbyte(po2),fsize);
    by1:= po2^.fold and foldlevelmask;
    if by1 <= lev2 then begin
     break;
    end;    
    replacebits1(byte(po2^.fold),by1-1,byte(foldlevelmask));
    po3:= po2;
    if po4 = nil then begin
     po4:= po2;
    end;
   end;
   if lev2 < lev1 then begin
    break;
   end;
   inc(pbyte(po1),fsize);
  end;
  if po4 <> nil then begin
   checksyncfoldlevelsource((pchar(po4)-pchar(datapo)) div fsize,
                        (pchar(po3)-pchar(getitempo(aindex))) div fsize);
  end;
 end;
end;

procedure trowstatelist.sourcenamechanged(const atag: integer);
var
 datalist1: tdatalist;
 str1: string;
 int1: integer;
begin
 if not (csloading in fgrid.componentstate) then begin
  if atag >= 0 then begin
   str1:= getsourcename(atag);
   datalist1:= nil;
   if str1 <> '' then begin
    datalist1:= fgrid.datacols.datalistbyname(str1);
   end;
   linksource(datalist1,atag);
  end
  else begin
   for int1:= 0 to getsourcecount-1 do begin
    str1:= getsourcename(int1);  //link all source lists
  {$ifdef mse_with_ifi}
//    if str1 = '' then begin
//     case int1 of
//      rowstatefoldleveltag: begin
//       if fifilinkfoldlevel <> nil then begin
//        continue;
//       end;
//      end;
//      rowstateissumtag: begin
//       if fifilinkissum <> nil then begin
//        continue;
//       end;
//      end;
//     end;
//    end;
  {$endif}
    datalist1:= nil;
    if str1 <> '' then begin
     datalist1:= fgrid.datacols.datalistbyname(str1);
    end;
    linksource(datalist1,int1);
   end;
  end;
 end;
end;

procedure trowstatelist.setsourcefoldlevel1(const avalue: string);
begin
 flinkfoldlevel.name:= avalue;
 sourcenamechanged(rowstatefoldleveltag);
end;

procedure trowstatelist.setsourcefoldlevel(const avalue: string);
begin
 {$ifdef mse_with_ifi}
// setifilinkfoldlevel1(nil);
 {$endif}
 setsourcefoldlevel1(avalue);
end;

procedure trowstatelist.setsourceissum1(const avalue: string);
begin
 flinkissum.name:= avalue;
 sourcenamechanged(rowstateissumtag);
end;

procedure trowstatelist.setsourceissum(const avalue: string);
begin
 {$ifdef mse_with_ifi}
// setifilinkissum1(nil);
 {$endif}
 setsourceissum1(avalue);
end;

procedure trowstatelist.sourcechange(const sender: tdatalist;
               const index: integer);
begin
 inherited;
 if sender <> nil then begin
  if (sender = flinkfoldlevel.source) and (ffoldlevelsourcelock = 0) then begin
   if checksourcechange(flinkfoldlevel,sender,index) then begin
    if (of_shiftchildren in fgrid.optionsfold) and (index >= 0) then begin
     foldlevel[index]:= pinteger(flinkfoldlevel.source.getitempo(index))^;
    end
    else begin
     checkdirty(index);
     change(index);
     fgrid.rowstatechanged(index);
    end;
   end;
  end
  else begin
   if (sender = flinkissum.source) and (fissumsourcelock = 0) then begin
    if checksourcechange(flinkissum,sender,index) then begin
     checkdirty(index);
     change(index);
     fgrid.rowstatechanged(index);
    end;
   end;
  end;
 end;
end;

function trowstatelist.getsourcecount: integer;
begin
 result:= 2;
end;

function trowstatelist.getsourceinfo(const atag: integer): plistlinkinfoty;
begin
 case atag of
  rowstatefoldleveltag: begin
   result:= @flinkfoldlevel;
  end;
  rowstateissumtag: begin
   result:= @flinkissum;
  end;
  else begin
   result:= nil;
  end;
 end;
end;

procedure trowstatelist.linksource(const source: tdatalist;
               const atag: integer);
begin
 case atag of
  rowstatefoldleveltag: begin
   internallinksource(source,atag,flinkfoldlevel.source);
  end;
  rowstateissumtag: begin
   internallinksource(source,atag,flinkissum.source);
  end;
 end;
end;

function trowstatelist.getlinkdatatypes(const atag: integer): listdatatypesty;
begin
 case atag of
  rowstatefoldleveltag,rowstateissumtag: begin
   result:= [dl_integer];
  end;
 end;
end;

{$ifdef mse_with_ifi}
{
procedure trowstatelist.setifilinkfoldlevel1(const avalue: tifiintegerlinkcomp);
begin
 mseificomp.setifilinkcomp(iifidatalink(self),avalue,fifilinkfoldlevel);
end;

procedure trowstatelist.setifilinkfoldlevel(const avalue: tifiintegerlinkcomp);
begin
 setsourcefoldlevel1(''); 
 setifilinkfoldlevel1(avalue);
end;

procedure trowstatelist.setifilinkissum1(const avalue: tifibooleanlinkcomp);
begin
 mseificomp.setifilinkcomp(iifidatalink(self),avalue,fifilinkissum);
end;

procedure trowstatelist.setifilinkissum(const avalue: tifibooleanlinkcomp);
begin
 setsourceissum1(''); 
 setifilinkissum1(avalue);
end;
}
function trowstatelist.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

procedure trowstatelist.setifiserverintf(const aintf: iifiserver);
begin
 //dummy
end;
{
function trowstatelist.getifiserverintf: iifiserver;
begin
 result:= nil;
end;
}
procedure trowstatelist.updateifigriddata(const sender: tobject;
               const alist: tdatalist);
begin
 //dummy
// if sender = fifilinkfoldlevel then begin
//  linksource(alist,rowstatefoldleveltag);
// end;
// if sender = fifilinkissum then begin
//  linksource(alist,rowstateissumtag);
// end;
end;

procedure trowstatelist.ifisetvalue(var avalue; var accept: boolean);
begin
 //dummy
end;

function trowstatelist.getgriddata: tdatalist;
begin
 result:= self;
end;

function trowstatelist.getvalueprop: ppropinfo;
begin
 result:= nil;
end;

{$endif}

end.

