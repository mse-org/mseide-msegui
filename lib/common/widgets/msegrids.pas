{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegrids;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 {$ifdef FPC}classes,sysutils{$else}Classes,SysUtils{$endif},mseclasses,msegui,
 msegraphics,msetypes,msestrings,msegraphutils,
 msescrollbar,msearrayprops,mseguiglob,
 msedatalist,msedrawtext,msewidgets,mseevent,mseinplaceedit,mseeditglob,
 mseobjectpicker,msepointer,msetimer,msebits,msestat,msestatfile,msekeyboard,
 msestream,msedrag,msemenus,msepipestream;

type
         //     listvievoptionty from mselistbrowser
         //     lvo_readonly,lvo_mousemoving,lvo_keymoving,lvo_horz,
 coloptionty = (co_readonly, co_nofocus,     co_invisible, co_disabled,
         //     lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
                co_drawfocus,co_mousemovefocus,co_leftbuttonfocusonly,
         //     lvo_focusselect,lvo_mouseselect,lvo_keyselect,
                co_focusselect, co_mouseselect, co_keyselect,
         //     lvo_multiselect,lvo_resetselectonexit
                co_multiselect, co_resetselectonexit, co_rowselect,

                co_fixwidth,co_fixpos,co_fill,co_proportional,co_nohscroll,
                co_savevalue,co_savestate,
                co_rowfont,co_rowcolor,co_zebracolor,
                co_nosort,co_sortdescent,co_norearange,
                co_cancopy,co_canpaste,co_mousescrollrow,co_rowdatachange
                );
 coloptionsty = set of coloptionty;
 fixcoloptionty = (fco_invisible,fco_mousefocus,fco_mouseselect,
                     fco_rowfont,fco_rowcolor,fco_zebracolor);
 fixcoloptionsty = set of fixcoloptionty;
 fixrowoptionty = (fro_invisible,fro_mousefocus,fro_mouseselect);
 fixrowoptionsty = set of fixrowoptionty;
 
const
 fixcoloptionsshift = ord(co_rowfont)-ord(fco_rowfont);
 fixcoloptionsmask:coloptionsty = [co_rowfont,co_rowcolor,co_zebracolor];
 defaultfixcoloptions = [];
 
type
 optiongridty = (og_colsizing,og_colmoving,og_keycolmoving,
                 og_rowsizing,og_rowmoving,og_keyrowmoving,
                 og_rowinserting,og_rowdeleting,og_selectedrowsdeleting,
                 og_focuscellonenter,og_containerfocusbackonesc,
                 og_autofirstrow,og_autoappend,og_appendempty,
                 og_savestate,og_sorted,
                 og_colchangeontabkey,og_rotaterow,
                 og_autopopup,
                 og_mousescrollcol);
 optionsgridty = set of optiongridty;

 pickobjectkindty = (pok_none,pok_fixcolsize,pok_fixcol,pok_datacolsize,pok_datacol,
                   pok_fixrowsize,pok_fixrow,pok_datarowsize,pok_datarow);

 stringcoleditoptionty = (
                    scoe_undoonesc,scoe_forcereturncheckvalue,scoe_eatreturn,

                    //same layout as editoptionty
                    scoe_endonenter,
                    scoe_homeonenter,
                    scoe_autoselect, //selectall bei enter
                    scoe_autoselectonfirstclick,
                    scoe_caretonreadonly,
                    scoe_trimright,
                    scoe_trimleft,
                    scoe_uppercase,
                    scoe_lowercase,
                    
                    scoe_autopost,
                    scoe_hintclippedtext
                          );

 stringcoleditoptionsty = set of stringcoleditoptionty;

const
 stringcoloptionseditmask: optionseditty = [
                    oe_endonenter,
                    oe_autoselect, //selectall bei enter
                    oe_autoselectonfirstclick,
                    oe_caretonreadonly,
                    oe_trimright,
                    oe_trimleft,
                    oe_uppercase,
                    oe_lowercase];
 stringcoloptionseditshift = ord(oe_endonenter) - ord(scoe_endonenter);

 gridvaluevarname = 'values';
 pickobjectstep = integer(high(pickobjectkindty)) + 1;
 layoutchangedcoloptions: coloptionsty = [co_fill,co_proportional,co_invisible,
 co_nohscroll];
 notfixcoloptions = [co_fixwidth,co_fixpos,co_fill,co_proportional,co_nohscroll,
                     co_rowdatachange];
 defaultoptionsgrid = [og_autopopup,og_colchangeontabkey,og_focuscellonenter,
                                   og_mousescrollcol];

 mousescrolldist = 5;
 griddefaultcolwidth = 50;
 griddefaultrowheight = 20;
 defaultcoltextflags = [tf_ycentered,tf_noselect];
 defaultactivecoltextflags = defaultcoltextflags - [tf_noselect];
 defaultgridlinewidth = 1;
 defaultdatalinecolor = cl_dkgray;
 defaultfixlinecolor = cl_black;
 selectedcolmax = 30; //32 bitset, bit31 -> whole row
 wholerowselectedmask = $80000000;
 defaultselectedcellcolor = cl_active;
 defaultdatacoloptions = [{co_selectedcolor,}co_savestate,co_savevalue,
                          co_rowfont,co_rowcolor,co_zebracolor,co_mousescrollrow];
 defaultfixcoltextflags = [tf_ycentered,tf_xcentered];
 defaultstringcoleditoptions = [scoe_undoonesc,scoe_autoselect,
                                  scoe_autoselectonfirstclick,scoe_eatreturn];
 defaultcolheadertextflags = [tf_ycentered,tf_xcentered];


 nullcoord: gridcoordty = (col: 0; row: 0);
 invalidaxis = -bigint;
 invalidcell: gridcoordty = (col: invalidaxis; row: invalidaxis);
 bigcoord: gridcoordty = (col: bigint; row: bigint);
 slowrepeat = 200000; //us
 fastrepeat = 100000; //us

 defaultgridwidgetoptions = defaultoptionswidgetmousewheel + 
                                        [ow_focusbackonesc,ow_fontglyphheight];

type
 tgridexception = class(exception);

 gridstatety = (
      gs_layoutvalid,gs_layoutupdating,gs_updatelocked,{gs_mousefocuslocked,}
      gs_sortvalid,gs_cellentered,gs_cellclicked,gs_emptyrowremoved,
      gs_rowcountinvalid,
      gs_scrollup,gs_scrolldown,gs_scrollleft,gs_scrollright,
      gs_selectionchanged,gs_rowdatachanged,gs_invalidated,{gs_rowappended,}
      gs_mouseentered,gs_childmousecaptured,gs_child,
      gs_mousecellredirected,gs_restorerow,gs_cellexiting,gs_rowremoving,
      gs_needszebraoffset, //has zebrastep or autonumcol
      gs_islist,//contiguous select blocks
      gs_isdb); //do not change rowcount
 gridstatesty = set of gridstatety;
 cellzonety = (cz_none,cz_default,cz_image,cz_caption);
 cellkindty = (ck_invalid,ck_data,ck_fixcol,ck_fixrow,ck_fixcolrow);
 griderrorty = (gre_ok,gre_invaliddatacell,gre_differentrowcount,
                gre_rowindex,gre_colindex,gre_invalidwidget);

 cellpositionty = (cep_nearest,cep_topleft,cep_top,cep_topright,cep_bottomright,
                   cep_bottom,cep_bottomleft,cep_left,
                   cep_rowcentered,cep_rowcenteredif);

 celleventkindty = (cek_none,cek_enter,cek_exit,cek_select,
                    cek_mousemove,cek_mousepark,cek_firstmousepark,
                    cek_buttonpress,cek_buttonrelease,
                    cek_mouseleave,
                    cek_keydown,cek_keyup);
const
 mousecellevents = [cek_mousemove,cek_mousepark,cek_firstmousepark,
                    cek_buttonpress,cek_buttonrelease];
 repeaterstates = [gs_scrollup,gs_scrolldown,gs_scrollleft,gs_scrollright];


type
 focuscellactionty = (fca_none,fca_entergrid,fca_exitgrid,
                      fca_reverse,fca_focusin,fca_focusinforce,
                      fca_focusinshift,fca_focusinrepeater,fca_setfocusedcell,
                      fca_selectstart,fca_selectend);
 tcustomgrid = class;
 celleventinfoty = record
  cell: gridcoordty;
  grid: tcustomgrid;
  case eventkind: celleventkindty of
   cek_exit,cek_enter:
    (cellbefore,newcell: gridcoordty; selectaction: focuscellactionty);
   cek_select:
    (selected: boolean; accept: boolean);
   cek_mousemove,cek_mousepark,cek_firstmousepark,
   cek_buttonpress,cek_buttonrelease:
    (zone: cellzonety; mouseeventinfopo: pmouseeventinfoty; gridmousepos: pointty);
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
  
 cellinfoty = record
  cell: gridcoordty;
  rect: rectty;
  innerrect: rectty; //origin rect.pos
  color: colorty;
  colorline: colorty;
  font: tfont;
  selected: boolean;
  notext: boolean;
  ismousecell: boolean;
  datapo: pointer;
  griddatalink: pointer;
 end;
 pcellinfoty = ^cellinfoty;

 tgridpropfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 tgridprop = class(tindexpersistent,iframe,iface)
  private
   fstart,fend: integer;
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
   procedure createfont;
   procedure setlinewidth(const Value: integer);
   procedure setlinecolor(const Value: colorty);
   procedure setlinecolorfix(const Value: colorty);
   procedure setcolorselect(const Value: colorty);
   procedure setcoloractive(const Value: colorty);
   function islinewidthstored: boolean;
   function islinecolorstored: boolean;
   function islinecolorfixstored: boolean;
   function iscolorselectstored : boolean;
   function iscoloractivestored : boolean;
  protected
   flinepos: integer;
   flinewidth: integer;
   flinecolor: colorty;
   flinecolorfix: colorty;
   fcolor: colorty;
   ffont: tgridpropfont;
   fgrid: tcustomgrid;
   fframe: tcellframe;
   fface: tcellface;
   fcellinfo: cellinfoty;
   foptions: coloptionsty;
   fcolorselect: colorty;
   fcoloractive: colorty;
   procedure updatelayout; virtual;
   procedure changed; virtual;
   procedure updatecellrect(const aframe: tcustomframe);
   function getinnerframe: framety; virtual;
   function step(getscrollable: boolean = true): integer; virtual; abstract;
   procedure createframe;
   procedure createface;
    //iframe
   function getwidget: twidget;
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
   
   //iface
   function translatecolor(const acolor: colorty): colorty;

   procedure fontchanged(const sender: tobject); virtual;
   property font: tgridpropfont read getfont write setfont stored isfontstored;
  public
   constructor create(const agrid: tcustomgrid; 
               const aowner: tgridarrayprop); reintroduce; virtual;
   destructor destroy; override;
   procedure drawcellbackground(const acanvas: tcanvas;
                 const aframe: tcustomframe; const aface: tcustomface);
   property grid: tcustomgrid read fgrid;
  published
   property color: colorty read fcolor write setcolor default cl_default;
   property frame: tcellframe read getframe write setframe;
   property face: tcellface read getface write setface;
   property linewidth: integer read flinewidth write setlinewidth 
                   stored islinewidthstored default defaultgridlinewidth;
   property linecolor: colorty read flinecolor write setlinecolor 
                   stored islinecolorstored;
   property linecolorfix: colorty read flinecolorfix write setlinecolorfix 
                   stored islinecolorfixstored default defaultfixlinecolor;
   property colorselect: colorty read fcolorselect write setcolorselect
                  stored iscolorselectstored default cl_default;
   property coloractive: colorty read fcoloractive write setcoloractive
                  stored iscoloractivestored default cl_none;
   property tag: integer read ftag write ftag;
 end;

 gridpropclassty = class of tgridprop;

 colpaintinfoty = record
  canvas: tcanvas;
  ystart,ystep: integer;
  startrow,endrow: integer;
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

 colstatety = ({cos_hasselection,}cos_selected,cos_noinvalidate,cos_edited);
 colstatesty = set of colstatety;

 tcolselectfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 tcol = class;
 
 celleventty = procedure(const sender: tobject; var info: celleventinfoty) of object;
 drawcelleventty = procedure(const sender: tcol; const canvas: tcanvas;
                          const cellinfo: cellinfoty) of object;
 beforedrawcelleventty = procedure(const sender: tcol; const canvas: tcanvas;
                          var cellinfo: cellinfoty; var handled: boolean) of object;
 tcol = class(tgridprop)
  private
   frowfontoffset: integer;
   frowfontoffsetselect: integer;
   frowcoloroffset: integer;
   fonbeforedrawcell: beforedrawcelleventty;
   frowcoloroffsetselect: integer;
   function getcolindex: integer;
   procedure setfocusrectdist(const avalue: integer);
   procedure updatepropwidth;
   procedure setrowcoloroffset(const avalue: integer);
   procedure setrowcoloroffsetselect(const avalue: integer);
   procedure setrowfontoffset(const avalue: integer);
   procedure setrowfontoffsetselect(const avalue: integer);

   function iswidthstored: boolean;
   function isoptionsstored: boolean;
   function isfocusrectdiststored: boolean;
   function getfontselect: tcolselectfont;
   function isfontselectstored: Boolean;
   procedure setfontselect(const Value: tcolselectfont);

  protected
   fwidth: integer;
   fpropwidth: real;
   fstate: colstatesty;
   ffontselect: tcolselectfont;
   ffocusrectdist: integer;
   procedure createfontselect;
   function getselected(const row: integer): boolean; virtual;
   procedure setwidth(const Value: integer); virtual;
   procedure setoptions(const Value: coloptionsty); virtual;
   procedure updatelayout; override;
   procedure rearange(const list: tintegerdatalist); virtual; abstract;

   function isopaque: boolean; virtual;
   procedure paint(const info: colpaintinfoty); virtual;
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
   property options: coloptionsty read foptions write setoptions
                  stored isoptionsstored default [];
   property focusrectdist: integer read ffocusrectdist write setfocusrectdist
                  stored isfocusrectdiststored default 0;
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
  published
   property width: integer read fwidth write setwidth stored iswidthstored;
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
   property onbeforedrawcell: beforedrawcelleventty read fonbeforedrawcell
                                write fonbeforedrawcell;
 end;

 tdatacol = class;

 showcolhinteventty = procedure(const sender: tdatacol; const arow: integer;
                           var info: hintinfoty) of object;

 tdatacol = class(tcol)
  private
   fwidthmax: integer;
   fwidthmin: integer;
   foncellevent: celleventty;
   fonshowhint: showcolhinteventty;
   fselectedrow: integer; //-1 none, -2 more than one
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
  protected
   fdata: tdatalist;
   fname: string;
   fonchange: notifyeventty;
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
   procedure clientmouseevent(const acell: gridcoordty; var info: mouseeventinfoty); virtual;
   procedure dokeyevent(var info: keyeventinfoty; up: boolean); virtual;
   procedure itemchanged(sender: tdatalist; aindex: integer); virtual;
   procedure updatelayout; override;
   procedure moverow(const fromindex,toindex: integer; const count: integer = 1); override;
   procedure insertrow(const aindex: integer; const count: integer = 1); override;
   procedure deleterow(const aindex: integer; const count: integer = 1); override;
   procedure rearange(const list: tintegerdatalist); override;
   procedure sortcompare(const index1,index2: integer; var result: integer); virtual;
   function isempty(const aindex: integer): boolean; virtual;
   procedure docellevent(var info: celleventinfoty); virtual;
   function getcursor: cursorshapety; virtual;
   function getdatastatname: msestring;
  public
   constructor create(const agrid: tcustomgrid;
                     const aowner: tgridarrayprop); override;
   destructor destroy; override;

   procedure cellchanged(const row: integer); override;
   function canfocus(const abutton: mousebuttonty): boolean; virtual;
   procedure updatecellzone(const pos: pointty; var result: cellzonety); virtual;
   property datalist: tdatalist read fdata;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   property selected[const row: integer]: boolean read getselected write setselected;
             //row < 0 -> whole col
   property cellorigin: pointty read getcellorigin;    //org = grid.paintpos
   property visible: boolean read getvisible write setvisible;
   property enabled: boolean read getenabled write setenabled;
   property readonly: boolean read getreadonly write setreadonly;
  published
   property options; //default defaultdatacoloptions;
   property widthmin: integer read fwidthmin write setwidthmin default 1;
   property widthmax: integer read fwidthmax write setwidthmax default 0;
   property name: string read fname write fname;
   property onchange: notifyeventty read fonchange write fonchange;
   property oncellevent: celleventty read foncellevent write foncellevent;
   property onshowhint: showcolhinteventty read fonshowhint write fonshowhint;
   property linecolor default defaultdatalinecolor;
 end;

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

 tcustomstringcol = class(tdatacol)
  private
   ftextflagsactive: textflagsty;
   foptionsedit: stringcoleditoptionsty;
   fonsetvalue: setstringeventty;
   fondataentered: notifyeventty;
   procedure settextflags(const avalue: textflagsty);
   function getdatalist: tmsestringdatalist;
   procedure setdatalist(const value: tmsestringdatalist);

   function istextflagsstored: boolean;
   function istextflagsactivestored: boolean;
   function isoptionseditstored: boolean;
   function getoptionsedit: optionseditty;
   procedure settextflagsactive(const avalue: textflagsty);
  protected
   ftextinfo: drawtextinfoty;
   function getitems(aindex: integer): msestring; virtual;
   procedure setitems(aindex: integer; const Value: msestring);
   function createdatalist: tdatalist; override;
   function getrowtext(const arow: integer): msestring; virtual;
   procedure drawcell(const canvas: tcanvas); override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure updatelayout; override;
   function getinnerframe: framety; override;
   function getcursor: cursorshapety; override;
   procedure modified; virtual;
  public
   constructor create(const agrid: tcustomgrid; 
                         const aowner: tgridarrayprop); override;
   destructor destroy; override;
   procedure readpipe(const pipe: tpipereader; 
                      const processeditchars: boolean = false); overload;
   procedure readpipe(const text: string; 
                      const processeditchars: boolean = false); overload;
   property items[aindex: integer]: msestring read getitems write setitems; default;
   property textflags: textflagsty read ftextinfo.flags write settextflags
               stored istextflagsstored default defaultcoltextflags;
   property textflagsactive: textflagsty read ftextflagsactive
             write settextflagsactive stored istextflagsactivestored 
                    default defaultactivecoltextflags;
   property optionsedit: stringcoleditoptionsty read foptionsedit write foptionsedit
               stored isoptionseditstored default defaultstringcoleditoptions;
   property font;
   property datalist: tmsestringdatalist read getdatalist write setdatalist;
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property ondataentered: notifyeventty read fondataentered write fondataentered;
 end;

 tstringcol = class(tcustomstringcol)
  published
   property focusrectdist;
   property textflags;
   property textflagsactive;
   property optionsedit;
   property font;
   property datalist;
   property fontselect;
   property onsetvalue;
   property ondataentered;
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
   procedure captionchanged(sender: tdatalist; aindex: integer);
   procedure setoptionsfix(const avalue: fixcoloptionsty);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
  protected
   ftextinfo: drawtextinfoty;
   procedure updatelayout; override;
   procedure setoptions(const Value: coloptionsty); override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure moverow(const fromindex,toindex: integer; const count: integer = 1); override;
   procedure insertrow(const aindex: integer; const count: integer = 1); override;
   procedure deleterow(const aindex: integer; const count: integer = 1); override;
   procedure paint(const info: colpaintinfoty); override;
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

 tcolheader = class(tindexpersistent,iframe,iface)
  private
   fcaption: msestring;
   ftextflags: textflagsty;
   ffont: tcolheaderfont;
   fcolor: colorty;
   fhint: msestring;
   fmergecols: integer;
   fmerged: boolean;
   fmergedcx: integer;
   fmergedx: integer;
   procedure setcaption(const avalue: msestring);
   procedure settextflags(const Value: textflagsty);
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
  protected
   fgrid: tcustomgrid;
   fframe: tfixcellframe;
   fface: tfixcellface;
   procedure changed;
   procedure fontchanged(const sender: tobject);

    //iframe
   function getwidget: twidget;
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

   //iface
   function translatecolor(const acolor: colorty): colorty;
   
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); override;
   destructor destroy; override;   
   property mergedcx: integer read fmergedcx;
   property mergedx: integer read fmergedx;
  published
   property color: colorty read fcolor write setcolor default cl_parent;
   property caption: msestring read fcaption write setcaption;
   property textflags: textflagsty read ftextflags write settextflags default defaultcolheadertextflags;
   property font: tcolheaderfont read getfont write setfont stored isfontstored;
   property frame: tfixcellframe read getframe write setframe;
   property face: tfixcellface read getface write setface;
   property mergecols: integer read fmergecols write setmergecols default 0;
   property hint: msestring read fhint write fhint;
 end;

 tcolheaders = class(tindexpersistentarrayprop)
  private
   fgridprop: tgridprop;
   function getitems(const index: integer): tcolheader;
   procedure setitems(const index: integer; const Value: tcolheader);
  protected
   procedure movecol(const curindex,newindex: integer);
   procedure updatelayout(const cols: tgridarrayprop);
   procedure dosizechanged; override;
  public
   constructor create(const agridprop: tgridprop); reintroduce;
   property items[const index: integer]: tcolheader read getitems
                 write setitems; default;
 end;

 tfixcolheaders = class(tcolheaders)
  private
   function getitems(const index: integer): tcolheader;
   procedure setitems(const index: integer; const Value: tcolheader);
  public
   property items[const index: integer]: tcolheader read getitems
                 write setitems; default;
 end;
 
 tfixrows = class;
 tfixrow = class(tgridprop)
  private
   fheight: integer;
   fnumstart: integer;
   fnumstep: integer;
   fcaptions: tcolheaders;
   fcaptionsfix: tfixcolheaders;
//   fhints: tmsestringarrayprop;
   foptionsfix: fixrowoptionsty;
   procedure setheight(const Value: integer);
   function getrowindex: integer;
   procedure captionchanged(const sender: tarrayprop; const aindex: integer);
   procedure setnumstart(const Value: integer);
   procedure setnumstep(const Value: integer);
   procedure settextflags(const Value: textflagsty);
   procedure setcaptions(const Value: tcolheaders);
   procedure setcaptionsfix(const Value: tfixcolheaders);
//   procedure sethints(const avalue: tmsestringarrayprop);
   procedure setoptionsfix(const avalue: fixrowoptionsty);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
  protected
   ftextinfo: drawtextinfoty;
   procedure cellchanged(const col: integer); virtual;
   procedure changed; override;
   procedure updatelayout; override;
   function step(getscrollable: boolean = true): integer; override;
   procedure paint(const info: rowpaintinfoty); virtual;
   procedure drawcell(const canvas: tcanvas);{ virtual;}
   procedure movecol(const curindex,newindex: integer);
   procedure orderdatacols(const neworder: integerarty);
   function mergedline(acol: integer): boolean;
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
   property captions: tcolheaders read fcaptions write setcaptions;
   property captionsfix: tfixcolheaders read fcaptionsfix write setcaptionsfix;
//   property hints: tmsestringarrayprop read fhints write sethints;
   property font;
   property linecolor default defaultfixlinecolor;
   property options: fixrowoptionsty read foptionsfix write setoptionsfix;
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
   procedure setlinewidth(const Value: integer);
   procedure setlinecolor(const Value: colorty);
   procedure setlinecolorfix(const Value: colorty);
   procedure setcolorselect(const avalue: colorty);
   procedure setcoloractive(const avalue: colorty);
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
  published
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
end;

 tcols = class(tgridarrayprop)
  private
   fwidth: integer;
   foptions: coloptionsty;
   ffocusrectdist: integer;
   function getcols(const index: integer): tcol;
   procedure setwidth(const value: integer);
   procedure setoptions(const Value: coloptionsty);
   procedure setfocusrectdist(const avalue: integer);
  protected
   function getclientsize: integer; override;
   procedure paint(const info: colpaintinfoty; const scrollables: boolean = true);
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
  public
   constructor create(aowner: tcustomgrid; aclasstype: gridpropclassty);
   procedure move(const curindex,newindex: integer); override;
   property cols[const index: integer]: tcol read getcols; default;
   property focusrectdist: integer read ffocusrectdist write setfocusrectdist default 0;
  published
   property width: integer read fwidth
                write setwidth default griddefaultcolwidth;
 end;

 rowstatety = record
  selected: cardinal; //bitset lsb = col 0, msb-1 = col 30, msb = whole row
                      //adressed by fcreateindex
  color: byte; //index in rowcolors, 0 = none, 1 = rowcolors[0]
  font: byte;  //index in rowfonts, 0 = none, 1 = rowfonts[0]
 end;
 prowstatety = ^rowstatety;
 rowstateaty = array[0..0] of rowstatety;
 prowstateaty  = ^rowstateaty;

 trowstatelist = class(tdatalist)
  private
   function getrowstate(const index: integer): rowstatety;
   procedure setrowstate(const index: integer; const Value: rowstatety);
  public
   constructor create; override;
   function getitempo(const index: integer): prowstatety;
   property items[const index: integer]: rowstatety read getrowstate write setrowstate; default;
 end;

 tdatacols = class(tcols)
  private
   frowstate: trowstatelist;
   fselectedrow: integer; //-1 none, -2 more than one
   fsortcol: integer;
   fnewrowcol: integer;
   function getcols(const index: integer): tdatacol;
   procedure setcols(const index: integer; const Value: tdatacol);
   function getselectedcells: gridcoordarty;
   procedure setselectedcells(const Value: gridcoordarty);
   function getselected(const cell: gridcoordty): boolean;
   procedure setselected(const cell: gridcoordty; const Value: boolean);
   procedure roworderinvalid;
   procedure checkindexrange;
   procedure setsortcol(const avalue: integer);
   procedure setnewrowcol(const avalue: integer);
  protected
   procedure dosizechanged; override;
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
             calldoselectcell: boolean); virtual; //implemented in tcustomlistview
   procedure sortfunc(sender: tcustomgrid;
                       const index1,index2: integer; var result: integer);
   procedure updatedatastate; virtual;

   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;

  public
   constructor create(aowner: tcustomgrid; aclasstype: gridpropclassty);
   destructor destroy; override;
   procedure move(const curindex,newindex: integer); override;
   procedure clearselection;
   function hasselection: boolean;
   function previosvisiblecol(aindex: integer): integer;
                   //invalidaxis if none
   function rowempty(const arow: integer): boolean;
   property cols[const index: integer]: tdatacol read getcols write setcols; default;
   function colbyname(const aname: string): tdatacol;
                  //name is case sensitive
   
   function selectedcellcount: integer;
   property selectedcells: gridcoordarty read getselectedcells write setselectedcells;
   property selected[const cell: gridcoordty]: boolean read Getselected write Setselected;
               //col < 0 and row < 0 -> whole grid, col < 0 -> whole col,
               //row = < 0 -> whole row
   procedure setselectedrange(const rect: gridrectty; const value: boolean;
             const calldoselectcell: boolean = false); overload; virtual;
  published
   property sortcol: integer read fsortcol write setsortcol default -1;
                                      //-1 -> all
   property newrowcol: integer read fnewrowcol write setnewrowcol default -1;
                                      //-1 -> actual
   property width;
   property options default defaultdatacoloptions;
   property linewidth;
   property linecolor default defaultdatalinecolor;
   property linecolorfix;
 end;

 tdrawcols = class(tdatacols)
  private
   function getcols(const index: integer): tdrawcol;
  public
   constructor create(aowner: tcustomgrid);
   property cols[const index: integer]: tdrawcol read getcols; default;
  published
   property focusrectdist;
 end;

 tstringcols = class(tdatacols)
  private
   foptionsedit: stringcoleditoptionsty;
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   function getcols(const index: integer): tstringcol;
   procedure settextflags(avalue: textflagsty);
   procedure settextflagsactive(avalue: textflagsty);
   procedure setoptionsedit(const avalue: stringcoleditoptionsty);
  protected
   function getcolclass: stringcolclassty; virtual;
  public
   constructor create(aowner: tcustomgrid);
   property cols[const index: integer]: tstringcol read getcols; default; //last!
  published
   property focusrectdist;
   property textflags: textflagsty read ftextflags write settextflags default defaultcoltextflags;
   property textflagsactive: textflagsty read ftextflagsactive
             write settextflagsactive default defaultactivecoltextflags;
   property optionsedit: stringcoleditoptionsty read foptionsedit
          write setoptionsedit default defaultstringcoleditoptions;
 end;

 tfixcols = class(tcols)
  private
   function getcols(const index: integer): tfixcol;
   procedure setcols(const index: integer; const Value: tfixcol);
  protected
   procedure updatelayout; override;
   function colatpos(const x: integer): integer; //-cout..-1, 0 if invalid
  public
   constructor create(aowner: tcustomgrid);
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
   function rowatpos(const y: integer): integer; //-count..-1, 0 if invalid
   procedure paint(const info: rowspaintinfoty);
   procedure movecol(const curindex,newindex: integer);
   procedure orderdatacols(const neworder: integerarty);
   procedure dofontheightdelta(var delta: integer);
  public
   constructor create(aowner: tcustomgrid);
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
   constructor create(const intf: iframe; const owner: twidget;
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
   property colorclient default cl_foreground;
   property framei_left default 0;
   property framei_top default 0;
   property framei_right default 0;
   property framei_bottom default 0;
   property sbvert;
   property sbhorz;
   property caption;
   property captionpos;
   property captiondist;
   property captiondistouter;
   property captionoffset;
   property captionnoclip;
   property font;
   property localprops; //before template
   property template;
 end;

 trowfontarrayprop = class(tpersistentarrayprop)
  private
   fgrid: tcustomgrid;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomgrid);
 end;

 cellinnerlevelty = (cil_all,cil_noline,cil_paint,cil_inner);
 cellselectmodety = (csm_select,csm_deselect,csm_reverse);
 selectcellmodety = (scm_cell,scm_row,scm_col);

 gridnotifyeventty = procedure(const sender: tcustomgrid) of object;
 griddataeventty = procedure(const sender: tcustomgrid; const aindex: integer) of object;
 griddatamovedeventty = procedure(const sender: tcustomgrid; const fromindex,toindex,acount: integer) of object;
 gridbeforedatablockeventty = procedure(const sender: tcustomgrid; var aindex,acount: integer) of object;
 griddatablockeventty = procedure(const sender: tcustomgrid; const aindex,acount: integer) of object;
 gridsorteventty = procedure(sender: tcustomgrid;
                       const index1,index2: integer; var aresult: integer) of object;

 rowstatenumty = -1..254;
 
 tcustomgrid = class(tpublishedwidget,iautoscrollframe,iobjectpicker,iscrollbar,
                    idragcontroller,istatfile)
  private
   frepeater: tsimpletimer;
   frepeataction: focuscellactionty;
   fystep: integer;
   ffirstvisiblerow: integer;
   flastvisiblerow: integer;
   fupdating: integer;
   flayoutupdating: integer;
   fnullchecking: integer;
   frowdatachanging: integer;
   fnoshowcaretrect: integer;
   finvalidatedcells: gridcoordarty;

   foncellevent: celleventty;
   fonrowsmoved: griddatamovedeventty;
   fonrowdatachanged: griddataeventty;
   fonrowsdatachanged: griddatablockeventty;
   fonrowsinserting: gridbeforedatablockeventty;
   fonrowsinserted: griddatablockeventty;
   fonrowsdeleting: gridbeforedatablockeventty;
   fonrowsdeleted: griddatablockeventty;
   fonrowcountchanged: gridnotifyeventty;
   fonlayoutchanged: gridnotifyeventty;
   fonsort: gridsorteventty;

   fdatarowlinewidth: integer;
   fdatarowlinecolor: colorty;
   fdatarowlinecolorfix: colorty;

   foncolmoved: griddatamovedeventty;
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

   procedure internalselectionchanged;
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
   function getrowfontstate(index: integer): rowstatenumty;
   procedure setrowfontstate(index: integer; const Value: rowstatenumty);
   procedure appinsrow(index: integer);
   procedure setdragcontroller(const avalue: tdragcontroller);

   procedure setzebra_color(const avalue: colorty);
   procedure setzebra_start(const avalue: integer);
   procedure setzebra_height(const avalue: integer);
   procedure setzebra_step(const avalue: integer);
  protected
   ffocuscount: integer;
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
   ffixcols: tfixcols;
   ffixrows: tfixrows;
   fdatacols: tdatacols;
   fdatarowheight: integer;
   frowcount: integer;
   frowcountmax: integer;
   fscrollrect: rectty;
   finnerdatarect,fdatarect,fdatarectx,fdatarecty: rectty;
          //origin = clientrect.pos
   ffirstnohscroll: integer;
   fdragcontroller: tdragcontroller;
   fobjectpicker: tobjectpicker;
   fpickkind: pickobjectkindty;
   fnumoffset: integer; //for fixcols
   fnonullcheck: integer;
   fnocheckvalue: integer;
   fappendcount: integer;
   procedure setoptionsgrid(const avalue: optionsgridty); virtual;

   procedure doinsertrow(const sender: tobject); virtual;
   procedure doappendrow(const sender: tobject); virtual;
   procedure dodeleterow(const sender: tobject); virtual;
   procedure dodeleteselectedrows(const sender: tobject); virtual;
   procedure dodeleterows(const sender: tobject);

   procedure initeventinfo(const cell: gridcoordty; eventkind: celleventkindty;
                 out info: celleventinfoty);
   procedure invalidate;
   procedure invalidatesinglecell(const cell: gridcoordty);
   function caninvalidate: boolean;
   function docheckcellvalue: boolean;
   procedure removeappendedrow;
   procedure internalupdatelayout;
   procedure updatelayout; virtual;
   function intersectdatarect(var arect: rectty): boolean;
   procedure setdatarowheight(const value: integer);
   function getcaretcliprect: rectty; override;
   procedure checkdatacell(const coord: gridcoordty);
   procedure datacellerror(const coord: gridcoordty);
   procedure error(aerror: griderrorty; text: string = '');
   procedure indexerror(row: boolean; index: integer; text: string = '');

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
   procedure rowchanged(const row: integer); virtual;
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
   procedure dorowsdatachanged(const index,count: integer); virtual;
   procedure dorowcountchanged(const countbefore,newcount: integer); virtual;
   procedure docellevent(var info: celleventinfoty); virtual;
   procedure cellmouseevent(const acell: gridcoordty; var info: mouseeventinfoty;
                                const acellinfopo: pcelleventinfoty = nil);
   procedure dofocusedcellposchanged; virtual;

   function internalsort(sortfunc: gridsorteventty; var refindex: integer): boolean;
            //true if moved

   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure loaded; override;
   procedure doexit; override;
   procedure dofocus; override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure drawfocusedcell(const acanvas: tcanvas); virtual;
   procedure drawcellbackground(const acanvas: tcanvas);

   procedure dopopup(var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty); override;
   function rowatpos(y: integer): integer; //0..rowcount-1, invalidaxis if invalid
   function ystep: integer;
   function nextfocusablecol(acol: integer; const aleft: boolean = false): integer;
   procedure checkcellvalue(var accept: boolean); virtual; 
                   //store edited value to grid
   procedure beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty); virtual;

   //iscrollbar
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); virtual;

   //idragcontroller
   //iobjectpicker
   function getcursorshape(const apos: pointty;  const shiftstate: shiftstatesty;
                                    var shape: cursorshapety): boolean;
   procedure getpickobjects(const rect: rectty;  const shiftstate: shiftstatesty;
                                    var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos,offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);
   function calcshowshift(const rect: rectty; const position: cellpositionty): pointty;

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
   procedure endupdate;
   function calcminscrollsize: sizety; override;
   procedure layoutchanged;
   function cellclicked: boolean;
   procedure rowdatachanged(const index: integer; const count: integer = 1);

   procedure rowup(const action: focuscellactionty = fca_focusin); virtual;
   procedure rowdown(const action: focuscellactionty = fca_focusin); virtual;
   procedure pageup(const action: focuscellactionty = fca_focusin); virtual;
   procedure pagedown(const action: focuscellactionty = fca_focusin); virtual;
   procedure lastrow(const action: focuscellactionty = fca_focusin); virtual;
   procedure firstrow(const action: focuscellactionty = fca_focusin); virtual;

   procedure colstep(const action: focuscellactionty; step: integer;
                          const rowchange: boolean); virtual;
                 //step > 0 -> right, step < 0 left

   function isdatacell(const coord: gridcoordty): boolean;
   function isfixrow(const coord: gridcoordty): boolean;
   function isfixcol(const coord: gridcoordty): boolean;
   function rowvisible(const arow: integer): integer;
                 //0 -> fully visible, < 0 -> below > 0 above
   function rowsperpage: integer;
   function cellatpos(const apos: pointty; out coord: gridcoordty): cellkindty; overload;
                 //origin = paintrect.pos
   function cellatpos(const apos: pointty): gridcoordty; overload;
   function cellrect(const cell: gridcoordty;
                 const innerlevel: cellinnerlevelty = cil_all): rectty;
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
                          const amode: cellselectmodety): boolean;  //true if accepted
   function getselectedrange: gridrectty;
   function getselectedrows: integerarty;

   function focuscell(cell: gridcoordty;
                   selectaction: focuscellactionty = fca_focusin;
                   const selectmode: selectcellmodety = scm_cell): boolean; virtual;
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
   function showcaretrect(const arect: rectty; const aframe: framety): pointty; overload;
   function showcellrect(const rect: rectty;
                   const origin: cellinnerlevelty = cil_paint): pointty;
   procedure showcell(const cell: gridcoordty; 
                      const position: cellpositionty = cep_nearest;
                      const force: boolean = false); 
               //scrolls cell in view, force true -> if scrollbar clicked also
   procedure showlastrow;
   procedure scrollrows(const step: integer);
   procedure scrollleft;
   procedure scrollright;
   procedure scrollpageleft;
   procedure scrollpageright;
   procedure movecol(const curindex,newindex: integer);
   procedure moverow(const curindex,newindex: integer; const count: integer = 1);
   procedure insertrow(index: integer; count: integer = 1); virtual;
   procedure deleterow(index: integer; count: integer = 1); virtual;
   procedure clear; //sets rowcount to 0
   function appendrow: integer; //returns index of new row
   procedure sort;
   function copyselection: boolean; virtual;  //false if no copy
   function pasteselection: boolean; virtual; //false if no paste

   property optionsgrid: optionsgridty read foptionsgrid write setoptionsgrid
                default defaultoptionsgrid;

   property datarowlinewidth: integer read fdatarowlinewidth
                write setdatarowlinewidth default defaultgridlinewidth;
   property datarowlinecolorfix: colorty read fdatarowlinecolorfix
                write setdatarowlinecolorfix default defaultfixlinecolor;
   property datarowlinecolor: colorty read fdatarowlinecolor
                write setdatarowlinecolor default defaultdatalinecolor;
   property datarowheight: integer read fdatarowheight
                write setdatarowheight default griddefaultrowheight;

   property datacols: tdatacols read fdatacols write setdatacols;
   property fixcols: tfixcols read ffixcols write setfixcols;
   property fixrows: tfixrows read ffixrows write setfixrows;
   property rowcount: integer read frowcount write setrowcount;
   function rowhigh: integer; //rowcount - 1
   property rowcountmax: integer read frowcountmax
                         write setrowcountmax default bigint;
   property focusedcell: gridcoordty read ffocusedcell;
                              //col,row = invalidaxis if none
   property col: integer read ffocusedcell.col write setcol;
   property row: integer read ffocusedcell.row write setrow;
   property gridframewidth: integer read fgridframewidth 
                        write setgridframewidth default 0;
   property gridframecolor: colorty read fgridframecolor 
                        write setgridframecolor default cl_black;

   property rowcolors: tcolorarrayprop read frowcolors write setrowcolors;
   property rowcolorstate[index: integer]: rowstatenumty read getrowcolorstate 
                        write setrowcolorstate; //default = -1
   property rowfonts: trowfontarrayprop read frowfonts write setrowfonts;
   property rowfontstate[index: integer]: rowstatenumty read getrowfontstate 
                        write setrowfontstate;  //default = -1
   property zebra_color: colorty read fzebra_color write setzebra_color default cl_infobackground;
   property zebra_start: integer read fzebra_start write setzebra_start default 0;
   property zebra_height: integer read fzebra_height write setzebra_height default 0;
   property zebra_step: integer read fzebra_step write setzebra_step default 2;

   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onlayoutchanged: gridnotifyeventty read fonlayoutchanged
              write fonlayoutchanged;
   property oncolmoved: griddatamovedeventty read foncolmoved
              write foncolmoved;
   property onrowcountchanged: gridnotifyeventty read fonrowcountchanged
              write fonrowcountchanged;
   property onrowsdatachanged: griddatablockeventty read fonrowsdatachanged
              write fonrowsdatachanged;
   property onrowdatachanged: griddataeventty read fonrowdatachanged
              write fonrowdatachanged;
   property onrowsmoved: griddatamovedeventty read fonrowsmoved
              write fonrowsmoved;

   property onrowsinserting: gridbeforedatablockeventty read fonrowsinserting
              write fonrowsinserting;
   property onrowsinserted: griddatablockeventty read fonrowsinserted
              write fonrowsinserted;

   property onrowsdeleting: gridbeforedatablockeventty read fonrowsdeleting
              write fonrowsdeleting;
   property onrowsdeleted: griddatablockeventty read fonrowsdeleted
              write fonrowsdeleted;

   property onsort: gridsorteventty read fonsort write fonsort;

   property oncellevent: celleventty read foncellevent write foncellevent;
   property onselectionchanged: notifyeventty read fonselectionchanged
                  write fonselectionchanged;

   property drag: tdragcontroller read fdragcontroller write setdragcontroller;

  published
   property frame: tgridframe read getframe write setframe;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property onkeydown: keyeventty read fonkeydown write fonkeydown;
 end;

 tcellgrid = class(tcustomgrid)
  protected
   procedure clientmouseevent(var info: mouseeventinfoty); override;
 end;
 
 tdrawgrid = class(tcellgrid)
  private
   function getdatacols: tdrawcols;
   procedure setdatacols(const value: tdrawcols);
  protected
   function createdatacols: tdatacols; override;
  published
   property optionsgrid;
   property datacols: tdrawcols read getdatacols write setdatacols;
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

   property statfile;
   property statvarname;

   property onlayoutchanged;
   property onrowcountchanged;
   property onrowsdatachanged;
   property onrowdatachanged;
   property onrowsmoved;
   property onrowsinserting;
   property onrowsinserted;
   property onrowsdeleting;
   property onrowsdeleted;
   property oncellevent;
   property onselectionchanged;
   property onsort;
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
   procedure setupeditor(const acell: gridcoordty);
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
  //iedit
   function getoptionsedit: optionseditty; virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
   function hasselection: boolean;

   procedure focusedcellchanged; override;
     //interface to inplaceedit
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;

   procedure doselectionchanged; override;
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
//   property datarowlinewidth default 0;
   property caretwidth: integer read getcaretwidth write setcaretwidth default defaultcaretwidth;
 end;

 tstringgrid = class(tcustomstringgrid)
  published
//   property defaultcoloptions; //first!
   property optionsgrid;
   property datacols;
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
   property caretwidth;

   property statfile;
   property statvarname;

   property onlayoutchanged;
   property onrowsmoved;
   property onrowsdatachanged;
   property onrowdatachanged;
   property onrowsinserting;
   property onrowsinserted;
   property onrowsdeleting;
   property onrowsdeleted;
   property onrowcountchanged;
   property oncellevent;
   property onselectionchanged;
   property onsort;
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
function cellkeypress(const info: celleventinfoty): keyty;

implementation
uses
 mseguiintf,mseshapes,msestockobjects;
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
      if (key = key_return) and (shiftstate = []) then begin
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

procedure stringcoltooptionsedit(const source: stringcoleditoptionsty; var dest: optionseditty);
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
               longword({$ifdef FPC}longword{$else}word{$endif}(source)) 
                            shl stringcoloptionseditshift,
               longword(dest),longword(stringcoloptionseditmask)));
 if scoe_autopost in source then begin
  include(dest,oe_autopost);
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

constructor tgridframe.create(const intf: iframe; const owner: twidget;
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
                                 const aowner: tgridarrayprop);
begin
 fgrid:= agrid;
 fcolor:= cl_default;
 fcolorselect:= aowner.fcolorselect;
 fcoloractive:= aowner.fcoloractive;
 flinecolor:= aowner.linecolor;
 flinecolorfix:= aowner.linecolorfix;
 flinewidth:= aowner.linewidth;
 inherited create(agrid,aowner);
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
 tcellframe.create(iframe(self));
end;

procedure tgridprop.createface;
begin
 fface:= tcellface.create(iface(self));
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

function tgridprop.islinewidthstored: Boolean;
begin
 result:= flinewidth <> tcols(prop).flinewidth;
end;

procedure tgridprop.setlinecolor(const Value: colorty);
begin
 if flinecolor <> value then begin
  flinecolor:= Value;
  fgrid.layoutchanged;
 end;
end;

function tgridprop.islinecolorstored: Boolean;
begin
 result:= flinecolor <> tcols(prop).flinecolor;
end;

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

procedure tgridprop.setcoloractive(const Value: colorty);
begin
 if value <> fcoloractive then begin
  fcoloractive := Value;
  changed;
 end;
end;

function tgridprop.islinecolorfixstored: Boolean;
begin
 result:= flinecolorfix <> tgridarrayprop(prop).flinecolorfix;
end;

function tgridprop.iscolorselectstored: boolean;
begin
 result:= fcolorselect <> tgridarrayprop(fowner).fcolorselect;
end;

function tgridprop.iscoloractivestored: boolean;
begin
 result:= fcoloractive <> tgridarrayprop(fowner).fcoloractive;
end;

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

procedure tgridprop.setframeinstance(instance: tcustomframe);
begin
 fframe:= tcellframe(instance);
end;

function tgridprop.getwidgetrect: rectty;
begin
 result:= fcellrect;
end;

procedure tgridprop.setwidgetrect(const rect: rectty);
begin
 twidget1(getwidget).setwidgetrect(rect);
end;

procedure tgridprop.setstaticframe(value: boolean);
begin
 twidget1(getwidget).setstaticframe(value);
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
 result:= twidget1(getwidget).getcomponentstate;
end;

procedure tgridprop.invalidate;
begin
 getwidget.invalidate;
end;

procedure tgridprop.invalidatewidget;
begin
 getwidget.invalidatewidget;
end;

procedure tgridprop.invalidaterect(const rect: rectty; org: originty = org_client);
begin
 getwidget.invalidaterect(rect,org);
end;

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
 if aframe = nil then begin
  acanvas.fillrect(makerect(nullpoint,fcellrect.size),fcellinfo.color);
 end
 else begin
  aframe.paint(acanvas,makerect(nullpoint,fcellrect.size));
  //  fframe.paint(acanvas,fcellrect);
  if tframe1(aframe).fi.colorclient = cl_transparent then begin
   acanvas.fillrect(makerect(nullpoint,fcellinfo.rect.size),fcellinfo.color);
  end;
 end;
 if aface <> nil then begin
  aface.paint(acanvas,makerect(nullpoint,fcellinfo.rect.size));
  {
  if aframe = nil then begin
   aface.paint(acanvas,makerect(nullpoint,fcellinfo.rect.size));
  end
  else begin
   aface.paint(acanvas,deflaterect(makerect(nullpoint,fcellinfo.rect.size),
                   tframe1(aframe).fpaintframe));
  end;
  }
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
 result:= minimalframe;
end;

procedure tgridprop.updatecellrect(const aframe: tcustomframe);
begin
 fcellinfo.rect:= fcellrect;
 if aframe <> nil then begin
  deflaterect1(fcellinfo.rect,tframe1(aframe).fpaintframe);
//  fcellinfo.innerrect:= deflaterect(fcellinfo.rect,fframe.fi.innerframe);
  with tframe1(aframe).fi.innerframe do begin
   fcellinfo.innerrect.pos:= pointty(topleft);
   fcellinfo.innerrect.cx:= fcellinfo.rect.cx - left - right;
   fcellinfo.innerrect.cy:= fcellinfo.rect.cy - top - bottom;
  end;
 end
 else begin
  fcellinfo.innerrect:= deflaterect(makerect(nullpoint,fcellinfo.rect.size),
                                  getinnerframe);
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
  result:= tgridpropfont(fgrid.getfont);
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
 flinewidth:= tcols(aowner).flinewidth;
 flinecolor:= tcols(aowner).flinecolor;
end;

destructor tcol.destroy;
begin
 ffontselect.free;
 inherited;
end;

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
 drawcellbackground(acanvas,fframe,fface);
end;

function tcol.actualcolor: colorty;
begin
 if fcolor <> cl_default then begin
  if fcolor = cl_parent then begin
   result:= fgrid.actualcolor;
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
  if co_rowcolor in foptions then begin
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
  if (aindex = fgrid.ffocusedcell.row) and (result = cl_none) then begin
   result:= fcoloractive;
  end;
  if result = cl_none then begin
   if (co_zebracolor in foptions) then begin
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
  if co_rowfont in foptions then begin
   po1:= fgrid.fdatacols.frowstate.getitempo(aindex);
   by1:= po1^.font;
   if by1 <> 0 then begin
    int1:= by1 + frowfontoffset - 1;
    if bo1 then begin
     int1:= int1 + frowfontoffsetselect;
    end;
    if (int1 >= 0) and (int1 < fgrid.frowfonts.count) then begin
     result:= tfont(fgrid.frowfonts[int1]);
    end;
   end;
  end;
  if bo1 and (result = nil) then begin
   result:= ffontselect;
  end;
 end;
 if result = nil then begin
  result:= actualfont;
 end;
end;


procedure tcol.paint(const info: colpaintinfoty);
var
 int1: integer;
 bo1,bo2: boolean;
 saveindex: integer;
// selectedcolor1: colorty;
 linewidthbefore: integer;
 font1: tfont;
 canbeforedrawcell: boolean;

begin
 if not (co_invisible in foptions) or (csdesigning in fgrid.ComponentState) then begin
  canbeforedrawcell:= fgrid.canevent(tmethod(fonbeforedrawcell));
  with info do begin
   fcellinfo.font:= nil;
   bo1:= (fcellinfo.cell.col = fgrid.ffocusedcell.col) and
       (gs_cellentered in fgrid.fstate);
   canvas.drawinfopo:= @fcellinfo;
   canvas.move(makepoint(fcellrect.x,fcellrect.y + ystep * startrow));
{
   if fcolorselect <> cl_default then begin
    selectedcolor1:= fcolorselect;
   end
   else begin
    selectedcolor1:= defaultselectedcellcolor;
   end;
}
   for int1:= startrow to endrow do begin
    font1:= rowfont(int1);
    if font1 <> fcellinfo.font then begin
     fcellinfo.font:= font1;
     canvas.font:= font1;
    end;
    fcellinfo.cell.row:= int1;
    fcellinfo.selected:= getselected(int1);
    fcellinfo.notext:= false;
    fcellinfo.ismousecell:= (fgrid.fmousecell.col = fcellinfo.cell.col) and 
                              (fgrid.fmousecell.row = int1);
    saveindex:= canvas.save;
    {
    if fcellinfo.selected then begin
     if (selectedcolor1 <> cl_none) then begin
      fcellinfo.color:= selectedcolor1;
     end
     else begin
      fcellinfo.color:= rowcolor(int1);
     end;
     if ffontselect <> nil then begin
      canvas.font:= ffontselect;
     end;
    end
    else begin
     fcellinfo.color:= rowcolor(int1);
    end;
    }
    fcellinfo.color:= rowcolor(int1);
    canvas.intersectcliprect(makerect(nullpoint,fcellrect.size));
    bo2:= false;
    if canbeforedrawcell then begin
     fonbeforedrawcell(self,canvas,fcellinfo,bo2);
    end;
    if not bo2 then begin
     if bo1 and (int1 = fgrid.ffocusedcell.row) then begin
      canvas.save;
      try
       drawfocusedcell(canvas);
       if co_drawfocus in foptions then begin
        drawfocus(canvas);
       end;
      finally
       canvas.restore;
      end;
     end
     else begin
      drawcell(canvas);
     end;
    end;
    canvas.restore(saveindex);
    canvas.move(makepoint(0,ystep));
   end;
   if flinewidth > 0 then begin
    linewidthbefore:= canvas.linewidth;
    if flinewidth = 1 then begin
     canvas.linewidth:= 0;
    end
    else begin
     canvas.linewidth:= flinewidth;
    end;
    int1:= flinepos{-fcellrect.x};
    canvas.drawline(makepoint(int1,-(ystep * (endrow-startrow+1))),
                      makepoint(int1,-1),flinecolor);
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
 if not (csloading in fgrid.componentstate) and not (gs_updatelocked in fgrid.fstate) then begin
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
  fwidth := Value;
  end;
  fgrid.layoutchanged;
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
  result:= (cos_selected in fstate) or
   (fgrid.fdatacols.frowstate.getitempo(row)^.selected and
               wholerowselectedmask <> 0);
 end
 else begin
  result:= cos_selected in fstate;
 end;
end;

procedure tcol.setoptions(const Value: coloptionsty);
var
 valuebefore: coloptionsty;
begin
 if foptions <> value then begin
  valuebefore:= foptions;
  foptions := Value;
  if bitschanged({$ifdef FPC}longword{$else}longword{$endif}(value),
         {$ifdef FPC}longword{$else}longword{$endif}(valuebefore),
         {$ifdef FPC}longword{$else}longword{$endif}(layoutchangedcoloptions)) then begin
   fgrid.layoutchanged;
  end
  else begin
   changed;
  end;
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

function tcol.isoptionsstored: Boolean;
begin
 result:= foptions <> tcols(fowner).foptions;
end;

function tcol.isfocusrectdiststored: boolean;
begin
 result:= ffocusrectdist <> tcols(fowner).ffocusrectdist;
end;

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

function tcol.iswidthstored: boolean;
begin
 result:= fwidth <> tcols(prop).fwidth;
end;

function tcol.getfontselect: tcolselectfont;
begin
 getoptionalobject(fgrid.componentstate,ffontselect,{$ifdef FPC}@{$endif}createfontselect);
 if ffontselect <> nil then begin
  result:= ffontselect;
 end
 else begin
  result:= tcolselectfont(getfont);
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

procedure tcol.createfontselect;
begin
 if ffontselect = nil then begin
  ffontselect:= tcolselectfont.create;
  ffontselect.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
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
 ftextflags:= defaultcolheadertextflags;
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
  result:= tcolheaderfont(tcolheaders(fowner).fgridprop.getfont);
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

 //iframe
function tcolheader.getwidget: twidget;
begin
 result:= fgrid;
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

procedure tcolheader.setwidgetrect(const rect: rectty);
begin
// twidget1(getwidget).setwidgetrect(rect);
end;

procedure tcolheader.setstaticframe(value: boolean);
begin
// twidget1(getwidget).setstaticframe(value);
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
 result:= twidget1(getwidget).getcomponentstate;
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

procedure tcolheader.invalidaterect(const rect: rectty; org: originty = org_client);
begin
 changed;
// getwidget.invalidaterect(rect,org);
end;

function tcolheader.getframefont: tfont;
begin
 result:= twidget1(getwidget).getfont;
end;

function tcolheader.getcanvas(aorigin: originty = org_client): tcanvas;
begin
 result:= getwidget.getcanvas(aorigin);
end;

function tcolheader.canfocus: boolean;
begin
 result:= getwidget.canfocus;
end;

function tcolheader.setfocus(aactivate: boolean = true): boolean;
begin
 result:= getwidget.setfocus(aactivate);
end;

//iface
function tcolheader.translatecolor(const acolor: colorty): colorty;
begin
 result:= acolor;
end;

procedure tcolheader.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 changed;
end;

procedure tcolheader.settextflags(const Value: textflagsty);
begin
 if ftextflags <> value then begin
  ftextflags := Value;
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

{ tcolheaders }

constructor tcolheaders.create(const agridprop: tgridprop);
begin
 fgridprop:= agridprop;
 inherited create(self,tcolheader);
end;

function tcolheaders.getitems(const index: integer): tcolheader;
begin
 result:= tcolheader(inherited getitems(index));
end;

procedure tcolheaders.setitems(const index: integer;
  const Value: tcolheader);
begin
 inherited getitems(index).Assign(value);
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

procedure tcolheaders.updatelayout(const cols: tgridarrayprop);
var
 int1,int2,int3,int4: integer;
begin
 int2:= count;
 for int1:= 0 to count - 1 do begin
  with tcolheader(fitems[int1]) do begin
   fmerged:= false;
   int3:= int1 + fmergecols;
   if int3 >= int2 then begin
    int2:= int3 + 1;
   end;
  end;
 end;
 if int2 > count then begin
  count:= int2;
 end;
 for int1:= 0 to count -1 do begin
  with tcolheader(fitems[int1]) do begin
   int3:= int1 + fmergecols;
   if int3 >= count then begin
    int3:= count - 1;
   end;
   if int3 >= cols.count then begin
    int3:= cols.count - 1;
   end;
   if int1 < int3 then begin
    fmergedcx:= tgridprop(cols.fitems[int1]).flinewidth -
                tgridprop(cols.fitems[int3]).flinewidth;
    if cols.freversedorder then begin
     fmergedx:= -fmergedcx;
    end
    else begin
     fmergedx:= 0;
    end;
    for int2:= int1 + 1 to int3 do begin
     tcolheader(fitems[int2]).fmerged:= true;
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
  end;
 end;
end;

procedure tcolheaders.dosizechanged;
begin
 inherited;
 fgridprop.fgrid.layoutchanged;
end;

{ tfixcolheaders }

function tfixcolheaders.getitems(const index: integer): tcolheader;
begin
 result:= tcolheader(inherited getitems(-index-1));
end;

procedure tfixcolheaders.setitems(const index: integer;
  const Value: tcolheader);
begin
 inherited getitems(-index-1).Assign(value);
end;

{ tfixrow }

constructor tfixrow.create(const agrid: tcustomgrid; const aowner: tgridarrayprop);
begin
 ftextinfo.flags:= defaultfixcoltextflags;
 fcaptions:= tcolheaders.create(self);
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
// fhints.free;
end;

procedure tfixrow.movecol(const curindex,newindex: integer);
begin
 if (curindex >= 0) then begin
  fcaptions.movecol(curindex,newindex);
  {
  with fhints do begin
   if (curindex < count) or (newindex < count) then begin
    int1:= curindex;
    if newindex >= count then begin
     count:= newindex + 1;
    end;
    if curindex >= count then begin
     count:= count + 1;
     int1:= count-1;
    end;
    move(int1,newindex);
   end;
  end;
  }
 end
 else begin
  with fcaptionsfix do begin
   movecol(-curindex-1,-newindex-1);
  end;
 end;
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
  height:= font.glyphheight + 2;
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
var
 int1,linewidthbefore: integer;
 frame1: tcustomframe;
 face1: tcustomface;
 headers1: tcolheaders;
 po1: pointty;

begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if cell.col >= 0 then begin
   int1:= cell.col;
   headers1:= fcaptions;
  end
  else begin
   headers1:= fcaptionsfix;
   int1:= -cell.col-1;
//   int1:= headers1.count+cell.col;
  end;
 
  frame1:= fframe;
  face1:= fface;
  po1:= nullpoint;
  if (int1 >= 0) and (int1 < headers1.count) then begin
   with tcolheader(headers1.fitems[int1]) do begin
    if fmerged then begin
     exit;
    end;
    if fcolor <> cl_parent then begin
     fcellinfo.color:= fcolor;
    end;
//    inc(fcellrect.x,fmergedx);
    inc(fcellrect.cx,fmergedcx);
    po1.x:= fmergedx;
    canvas.move(po1);
    if fframe <> nil then begin
     frame1:= fframe;
     tframe1(frame1).checkstate;
    end;
    if fface <> nil then begin
     face1:= fface;
    end;
   end;
  end;
  updatecellrect(frame1);
  ftextinfo.dest:= fcellinfo.innerrect;
  canvas.save;
  canvas.intersectcliprect(makerect(nullpoint,fcellrect.size));
  drawcellbackground(canvas,frame1,face1);
  if fnumstep <> 0 then begin
   ftextinfo.text.text:= inttostr(fnumstart+fnumstep*cell.col);
   drawtext(canvas,ftextinfo);
  end
  else begin
   if (int1 >= 0) and (int1 < headers1.count) then begin
    with tcolheader(headers1.fitems[int1]) do begin
     drawtext(canvas,caption,ftextinfo.dest,textflags,getfont);
    end;
   end;
  end;
  canvas.restore;
  if flinewidth > 0 then begin
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
//   canvas.linewidth:= linewidthbefore;
  end;
  canvas.remove(po1);
 end;
end;

procedure tfixrow.paint(const info: rowpaintinfoty);
var
 po1,po2: pointty;

var
 linewidthbefore: integer;
// linecolor1: colorty;
 color1: colorty;
 
 procedure paintcols(const range: rangety);
 var
  int1,int2,int3: integer;
  bo1: boolean;
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
     if not tcolheader(headers1.fitems[int3]).fmerged then begin
      break;
     end;
    end;
   end;
   for int1:= int2 to range.endindex do begin
    with tcol(cols.fitems[int1]) do begin
     bo1:= (colrange.scrollables xor (co_nohscroll in foptions)) and
        (not (co_invisible in foptions) or (csdesigning in fgrid.componentstate));
     if bo1 then begin
      self.fcellrect.size.cx:= fwidth;
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
                    (cos_selected in fgrid.fdatacols[int1].fstate) then begin
       if fcolorselect <> cl_default then begin
        fcellinfo.color:= fcolorselect;
       end
       else begin
        fcellinfo.color:= defaultselectedcellcolor;
       end;
      end;
     end;
     canvas.origin:= po2;
//     int2:= canvas.save;
     drawcell(canvas);
//     canvas.restore(int2);
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
    color1:= fgrid.actualcolor;
   end;
   po1:= canvas.origin;
   linewidthbefore:= canvas.linewidth;
   if fix then begin
    fcellinfo.colorline:= flinecolorfix;
//    linecolor1:= flinecolorfix;
   end
   else begin
    fcellinfo.colorline:= flinecolor;
//    linecolor1:= flinecolor;
   end;
   po2.y:= po1.y+fcellrect.y;
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
 fcaptionsfix.updatelayout(fgrid.ffixcols);
 fcaptions.updatelayout(fgrid.fdatacols);
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

procedure tfixrow.changed;
begin
 inherited;
 if fgrid.caninvalidate then begin
  fgrid.invalidaterect(fgrid.cellrect(makegridcoord(invalidaxis,getrowindex)));
 end;
end;

procedure tfixrow.setcaptions(const Value: tcolheaders);
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
{
procedure tfixrow.sethints(const avalue: tmsestringarrayprop);
begin
 fhints.assign(avalue);
end;
}
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

function tfixrow.mergedline(acol: integer): boolean;
var
 header1: tcolheaders;
begin
 if acol < 0 then begin
  acol:= -acol-1;
  header1:= fcaptionsfix;
 end
 else begin
  header1:= fcaptions;
 end;
 inc(acol);
 result:= (acol < header1.count) and tcolheader(header1.fitems[acol]).fmerged;
end;

{ tgridarrayprop }

constructor tgridarrayprop.create(aowner: tcustomgrid; aclasstype: gridpropclassty);
begin
 ffirstopposite:= -bigint;
 fgrid:= aowner;
 flinewidth:= defaultgridlinewidth;
 flinecolorfix:= defaultfixlinecolor;
 fcolorselect:= cl_default;
 fcoloractive:= cl_none;
 inherited create(self,aclasstype);
end;

procedure tgridarrayprop.setlinewidth(const Value: integer);
var
 int1: integer;
begin
 if flinewidth <> value then begin
  flinewidth := Value;
  for int1:= 0 to count - 1 do begin
   tgridprop(items[int1]).linewidth:= value;
  end;
 end;
end;

procedure tgridarrayprop.setlinecolor(const Value: colorty);
var
 int1: integer;
begin
 if flinecolor <> value then begin
  flinecolor := Value;
  for int1:= 0 to count - 1 do begin
   tgridprop(items[int1]).linecolor:= value;
  end;
 end;
end;

procedure tgridarrayprop.setlinecolorfix(const Value: colorty);
var
 int1: integer;
begin
 if flinecolorfix <> value then begin
  flinecolorfix := Value;
  for int1:= 0 to count - 1 do begin
   tgridprop(items[int1]).linecolorfix:= value;
  end;
 end;
end;

procedure tgridarrayprop.setcolorselect(const avalue: colorty);
var
 int1: integer;
begin
 if fcolorselect <> avalue then begin
  fcolorselect:= avalue;
  for int1:= 0 to count - 1 do begin
   tgridprop(items[int1]).colorselect:= avalue;
  end;
 end;
end;

procedure tgridarrayprop.setcoloractive(const avalue: colorty);
var
 int1: integer;
begin
 if fcoloractive <> avalue then begin
  fcoloractive:= avalue;
  for int1:= 0 to count - 1 do begin
   tgridprop(items[int1]).coloractive:= avalue;
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
  calcrange(foppositecount,count-1,range1);
  calcrange(0,foppositecount-1,range2);
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
 fdata.Free;
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
begin
 if enter then begin
  fgrid.factiverow:= newcell.row;
  if co_drawfocus in foptions then begin
   cellchanged(newcell.row);
  end;
  fgrid.initeventinfo(newcell,cek_enter,info);
 end
 else begin
  if selectaction <> fca_exitgrid then begin
   fgrid.factiverow:= newcell.row;
  end;
  if co_drawfocus in foptions then begin
   cellchanged(cellbefore.row);
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

procedure tdatacol.updatecellzone(const pos: pointty; var result: cellzonety);
begin
 fgrid.internalupdatelayout;
 if pointinrect(pos,fcellinfo.rect) then begin
  result:= cz_default;
 end
 else begin
  result:= cz_none;
 end;
end;

procedure tcustomgrid.cellmouseevent(const acell: gridcoordty; 
                    var info: mouseeventinfoty; const acellinfopo: pcelleventinfoty = nil);
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
  case info.eventkind of
   ek_mousemove: eventkind:= cek_mousemove;
   ek_mousepark: eventkind:= cek_mousepark;
   ek_buttonpress: eventkind:= cek_buttonpress;
   ek_buttonrelease: eventkind:= cek_buttonrelease;
   ek_clientmouseleave: eventkind:= cek_mouseleave;
  end;
  if (acellinfopo = nil) and (eventkind <> cek_none) then begin
   po1:= cellrect(cellinfo.cell).pos;
   try
    subpoint1(info.pos,po1);
    docellevent(cellinfopo^);
   finally
    addpoint1(info.pos,po1);
   end;
  end;
 end;
end;

procedure tdatacol.clientmouseevent(const acell: gridcoordty; 
                                              var info: mouseeventinfoty);
var
// event: celleventkindty;
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
    updatecellzone(info.pos,cellinfo.zone);
    fgrid.docellevent(cellinfo);
   finally
    addpoint1(info.pos,po1);
   end;
  end;
 end;
  
{
 fillchar(cellinfo,sizeof(cellinfo),0);
 with cellinfo do begin
  mouseeventinfopo:= @info;
  cell:= acell;
  case info.eventkind of
   ek_mousemove: event:= cek_mousemove;
   ek_mousepark: event:= cek_mousepark;
   ek_buttonpress: event:= cek_buttonpress;
   ek_buttonrelease: event:= cek_buttonrelease;
   ek_clientmouseleave: begin
    event:= cek_none;
    eventkind:= cek_mouseleave;
    fgrid.docellevent(cellinfo);
   end
   else event:= cek_none;
  end;
  if event <> cek_none then begin
   cellinfo.eventkind:= event;
   gridmousepos:= info.pos;
   po1:= fgrid.cellrect(cellinfo.cell).pos;
   try
    subpoint1(info.pos,po1);
    cellinfo.zone:= cz_none;
    updatecellzone(info.pos,cellinfo.zone);
    grid:= fgrid;
    fgrid.docellevent(cellinfo);
   finally
    addpoint1(info.pos,po1);
   end;
  end;
 end;
 }
end;

function tdatacol.getselected(const row: integer): boolean;
begin
 if ident <= selectedcolmax then begin
  if row >= 0 then begin
   result:= (cos_selected in fstate) or
    (fgrid.fdatacols.frowstate.getitempo(row)^.selected and
     (bits[ident] or wholerowselectedmask) <> 0);
  end
  else begin
   result:= cos_selected in fstate;
  end;
 end
 else begin
  result:= inherited getselected(row);
 end;
end;

procedure tdatacol.setselected(const row: integer; value: boolean);
var
 po1: prowstatety;
 ca1: cardinal;
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
     cellchanged(row);
     fgrid.internalselectionchanged;
    end;
   end;
  end
  else begin //row < 0
   if value then begin
    if not (cos_selected in fstate) then begin
     include(fstate,cos_selected);
     fselectedrow:= -2;
     changed;
     fgrid.internalselectionchanged;
    end;
   end
   else begin
    exclude(fstate,cos_selected);
    if fselectedrow <> -1 then begin
     po1:= fgrid.fdatacols.frowstate.datapo;
     ca1:= not (bits[ident] {or wholerowselectedmask});
     if fselectedrow >= 0 then begin
      prowstateaty(po1)^[fselectedrow].selected:= 
               prowstateaty(po1)^[fselectedrow].selected and ca1;
      cellchanged(fselectedrow);
     end
     else begin
      for int1:= 0 to fgrid.frowcount - 1 do begin
       po1^.selected:= po1^.selected and ca1;
       inc(po1);
      end;
      changed;
     end;
     fselectedrow:= -1;
     fgrid.internalselectionchanged;
    end;
   end;
  end;
 end;
end;

procedure tdatacol.internaldoentercell(const cellbefore: gridcoordty;
                var newcell: gridcoordty; const action: focuscellactionty);
begin
 if not (gs_cellentered in fgrid.fstate) then begin
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
 end;
end;

procedure tdatacol.itemchanged(sender: tdatalist; aindex: integer);
begin
 if (aindex < 0) and (sender.count <> fgrid.frowcount) then begin
  if fgrid.fupdating = 0 then begin
   fgrid.rowcount:= sender.count;
  end
  else begin
   include(fgrid.fstate,gs_rowcountinvalid)
  end;
 end;
 if not (cos_noinvalidate in fstate) and 
                     not (csloading in fgrid.componentstate) then begin
  if aindex < 0 then begin
   cellchanged(invalidaxis);
  end
  else begin
   cellchanged(aindex);
  end;
 end;
 if not (co_nosort in foptions) then begin
  exclude(fgrid.fstate,gs_sortvalid);
 end;
 if fgrid.canevent(tmethod(fonchange)) then begin
  fonchange(self);
 end;
end;

procedure tdatacol.doactivate;
begin
 //dummy
end;

procedure tdatacol.dodeactivate;
begin
 //dummy
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
 optionsplusdelta:= coloptionsty((longword(optionsbefore) xor longword(foptions)) and 
                                                    longword(value));
 if (co_focusselect in optionsplusdelta) and
   (fgrid.ffocusedcell.col = findex) and (fgrid.ffocusedcell.row >= 0) then begin
    fgrid.selectcell(makegridcoord(findex,fgrid.ffocusedcell.row),csm_select);
 end;
 if (co_disabled in optionsplusdelta) and 
                              (fgrid.ffocusedcell.col = colindex) then begin
  fgrid.colstep(fca_focusin,1,false);
 end;
end;

function tdatacol.canfocus(const abutton: mousebuttonty): boolean;
begin
 result:= (foptions * [co_invisible,co_disabled,co_nofocus] = []) and
          ((abutton = mb_left) or (abutton = mb_none) or
                     not (co_leftbuttonfocusonly in foptions));
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
 with tdatalist1(fdata) do begin
  tdatalist1(fdata).compare((fdatapo+index1*fsize)^,(fdatapo+index2*fsize)^,result);
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

function tdatacol.getcursor: cursorshapety;
begin
 result:= cr_arrow;
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

procedure tdatacol.dostatread(const reader: tstatreader);
begin
 if (fdata <> nil) and (co_savevalue in foptions) and 
            not (gs_isdb in fgrid.fstate) then begin
  reader.readdatalist(getdatastatname,fdata);
 end;
 if co_savestate in foptions then begin
  width:= reader.readinteger('width'+inttostr(ident),fwidth,0);
 end;
end;

procedure tdatacol.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 if (fdata <> nil) and (co_savevalue in foptions) and 
           not (gs_isdb in fgrid.fstate) then begin
  writer.writedatalist(getdatastatname,fdata);
 end;
 if co_savestate in foptions then begin
  writer.writeinteger('width'+inttostr(ident),fwidth);
 end;
end;

procedure tdatacol.cellchanged(const row: integer);
begin
 inherited;
 if (co_rowdatachange in foptions) and (fgrid.frowdatachanging = 0) then begin
                                          //no recursion
  if row < 0 then begin
   fgrid.rowdatachanged(0,fgrid.frowcount);
  end
  else begin
   fgrid.rowdatachanged(row);
  end;
 end;
end;

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

{ tdrawcol }

procedure tdrawcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 if fgrid.canevent(tmethod(fondrawcell)) then begin
  fondrawcell(self,canvas,cellinfoty(canvas.drawinfopo^));
 end;
end;

{ tcustomstringcol }

constructor tcustomstringcol.create(const agrid: tcustomgrid; 
                       const aowner: tgridarrayprop);
begin
 foptionsedit:= tstringcols(aowner).foptionsedit;
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
 result:= tmsestringdatalist.create;
end;

function tcustomstringcol.getinnerframe: framety;
begin
 result.left:= tcustomstringgrid(fgrid).feditor.getinsertcaretwidth(
                 fgrid.getcanvas,fgrid.getfont);
 result.top:= 0;
 result.right:= result.left;
 result.bottom:= 0;
end;

function tcustomstringcol.getcursor: cursorshapety;
begin
 if not (co_readonly in foptions) then begin
  result:= cr_ibeam;
 end
 else begin
  result:= inherited getcursor;
 end;
end;

procedure tcustomstringcol.modified;
begin
 include(fstate,cos_edited);
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

procedure tcustomstringcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 ftextinfo.font:= canvas.font;
 ftextinfo.text.format:= nil;
 with cellinfoty(canvas.drawinfopo^) do begin
  if cell.row < fgrid.rowcount then begin
   ftextinfo.text.text:= getrowtext(cell.row);
   drawtext(canvas,ftextinfo);
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

function tcustomstringcol.getdatalist: tmsestringdatalist;
begin
 result:= tmsestringdatalist(fdata);
end;

procedure tcustomstringcol.setdatalist(const value: tmsestringdatalist);
begin
 fdata.Assign(value);
end;

function tcustomstringcol.istextflagsstored: boolean;
begin
 result:= tstringcols(prop).ftextflags <> ftextinfo.flags;
end;

function tcustomstringcol.istextflagsactivestored: boolean;
begin
 result:= tstringcols(prop).ftextflagsactive <> ftextflagsactive;
end;

function tcustomstringcol.isoptionseditstored: boolean;
begin
 result:= tstringcols(prop).foptionsedit <> foptionsedit;
end;

procedure tcustomstringcol.readpipe(const pipe: tpipereader;
                            const processeditchars: boolean = false);
var
 str1: string;
 bo1: boolean;
 int1: integer;
 mstr1: msestring;
begin
 if processeditchars then begin
  try
   mstr1:= pipe.readdatastring;
  except
  end;
  datalist.addchars(mstr1);
 end
 else begin
  inc(fgrid.fnoshowcaretrect);
  try
   grid.beginupdate;
   try
    if grid.rowcount = 0 then begin
     grid.rowcount:= 1;
    end;
    repeat
     int1:= grid.rowhigh;
     bo1:= pipe.readuln(str1);
     try
      mstr1:= str1;
     except
     end;
     items[int1]:= items[int1]+mstr1;
     if bo1 then begin
      grid.appendrow;
     end;
    until not bo1;
   finally
    grid.endupdate;
   end;
  finally
   dec(fgrid.fnoshowcaretrect);
  end;
 end;
end;

procedure tcustomstringcol.readpipe(const text: string; const processeditchars: boolean = false);
var
 ar1: stringarty;
 int1: integer;
 mstr1: string;
begin
 ar1:= nil; //compiler warning
 if text <> '' then begin
  try
   mstr1:= text;
  except
  end;
  if processeditchars then begin
   datalist.addchars(mstr1);
  end
  else begin
   ar1:= breaklines(mstr1);
   inc(fgrid.fnoshowcaretrect);
   try
    grid.beginupdate;
    try
     if grid.rowcount = 0 then begin
      grid.rowcount:= 1;
     end;
     items[grid.rowhigh]:= items[grid.rowhigh]+ar1[0];
     for int1:= 1 to high(ar1) do begin
      grid.appendrow;
      items[grid.rowhigh]:= ar1[int1];
     end;
    finally
     grid.endupdate;
    end;
   finally
    dec(fgrid.fnoshowcaretrect);
   end;
   {
   grid.beginupdate;
   try
    ar1:= breaklines(text);
    if grid.rowcount = 0 then begin
     int1:= 0;
     grid.rowcount:= length(ar1);
    end
    else begin
     int1:= grid.rowhigh;
     grid.rowcount:= int1 + length(ar1);
    end;
    int1:= grid.rowcount - length(ar1); //adjust for ringbuffer
    if int1 < 0 then begin
     int3:= - int1;
     int1:= 0;
    end
    else begin
     int3:= 0;
    end;
    items[int1]:= items[int1]+ar1[int3];
    for int2:= int3 + 1 to high(ar1) do begin
     items[int1+int2-int3]:= ar1[int2];
    end;
   finally
    grid.endupdate;
   end;
   }
  end;
 end;
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

{ tfixcol }

constructor tfixcol.create(const agrid: tcustomgrid; 
                               const aowner: tgridarrayprop);
begin
 foptionsfix:= defaultfixcoloptions;
 ftextinfo.flags:= defaultfixcoltextflags;
 fcaptions:= tmsestringdatalist.create;
 fcaptions.onitemchange:= {$ifdef FPC}@{$endif}captionchanged;
 inherited;
 fcolor:= cl_parent;
end;

destructor tfixcol.destroy;
begin
 inherited;
 fcaptions.Free;
end;

procedure tfixcol.setoptionsfix(const avalue: fixcoloptionsty);
var
 options1: coloptionsty;
begin
 foptionsfix:= avalue;
 options1:= coloptionsty(
               replacebits(cardinal(
                 {$ifndef FPC}byte({$endif}avalue{$ifndef FPC}){$endif})
                            shl cardinal(fixcoloptionsshift),
                     cardinal(foptions),
                     cardinal(fixcoloptionsmask)));
 if fco_invisible in avalue then begin
  include(options1,co_invisible);
 end
 else begin
  exclude(options1,co_invisible);
 end;
 inherited options:= options1;
end;

procedure tfixcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 with cellinfoty(canvas.drawinfopo^) do begin
  if not notext then begin
   if fnumstep <> 0 then begin
    ftextinfo.text.text:= inttostr(fgrid.fnumoffset+fnumstart+fnumstep*cell.row);
    drawtext(canvas,ftextinfo);
   end
   else begin
    if cell.row < fcaptions.count then begin
     ftextinfo.text.text:= fcaptions[cell.row];
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

procedure tfixcol.updatelayout;
begin
 inherited;
 ftextinfo.dest:= fcellinfo.innerrect;
end;

procedure tfixcol.paint(const info: colpaintinfoty);
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

procedure tfixcol.captionchanged(sender: tdatalist; aindex: integer);
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

{ tcols }

constructor tcols.create(aowner: tcustomgrid; aclasstype: gridpropclassty);
begin
 fwidth:= griddefaultcolwidth;
 inherited;
end;

procedure tcols.paint(const info: colpaintinfoty; const scrollables: boolean = true);
var
 startx,endx: integer;
 po1,po2: pointty;
 int1: integer;
begin
 with info do begin
  po1:= canvas.origin;
  with canvas.clipbox do begin
   startx:= x {+ po1.x};
   endx:= startx + cx;
  end;
  po2:= po1;
  for int1:= 0 to count-1 do begin
   with tcol(fitems[int1]) do begin
    if (scrollables xor (co_nohscroll in foptions)) and 
     not ((startx < fstart) and (endx < fstart) or 
          (startx >= fend) and (endx >= fend)) then begin
     po2.x:= fstart + po1.x;
     canvas.origin:= po2;
     paint(info);
    end;
   end;
  end;
  canvas.origin:= po1;
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
  for int1:= 0 to count - 1 do begin
   tcol(items[int1]).width:= value;
  end;
 end;
end;

procedure tcols.setoptions(const Value: coloptionsty);
var
 int1: integer;
 mask: longword;
begin
 if foptions <> value then begin
  mask:= longword(value) xor longword(foptions);
  foptions := Value;
  for int1:= 0 to count - 1 do begin
   tcol(items[int1]).options:= coloptionsty(replacebits(longword(value),
                  longword(tcol(items[int1]).options),mask));
  end;
 end;
end;

procedure tcols.setfocusrectdist(const avalue: integer);
var
 int1: integer;
begin
 if ffocusrectdist <> avalue then begin
  for int1:= 0 to count - 1 do begin
   tcol(items[int1]).focusrectdist:= avalue;
  end;
 end;
end;

procedure tcols.move(const curindex, newindex: integer);
begin
 inherited;
 fgrid.layoutchanged;
end;

procedure tcols.moverow(const curindex,newindex: integer; const acount: integer);
var
 int1: integer;
begin
 for int1:= 0 to self.count - 1 do begin
  tcol(items[int1]).moverow(curindex,newindex,acount);
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

{ tdatacols }

constructor tdatacols.create(aowner: tcustomgrid; aclasstype: gridpropclassty);
begin
 fselectedrow:= -1;
 fsortcol:= -1;
 fnewrowcol:= -1;
 frowstate:= trowstatelist.create;
 inherited;
 flinecolor:= defaultdatalinecolor;
 foptions:= defaultdatacoloptions;
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
 for int1:= 0 to count - 1 do begin
  with tdatacol(fitems[int1]) do begin
   fcellinfo.cell.col:= int1;
   if foptions * [co_fill,co_invisible,co_nohscroll] = [co_fill] then begin
    int2:= int1;
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
 frowstate.count:= newcount;
 inherited;
end;

procedure tdatacols.setrowcountmax(const value: integer);
var
 int1: integer;
begin
 frowstate.maxcount:= value;
 for int1:= 0 to count - 1 do begin
  with tdatacol(items[int1]) do begin
   if fdata <> nil then begin
    fdata.maxcount:= value;
   end;
  end;
 end;
end;

procedure tdatacols.roworderinvalid;
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
 updatedatastate;
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
 roworderinvalid;
 frowstate.blockmovedata(fromindex,toindex,acount);
 inherited;
end;

procedure tdatacols.insertrow(const index: integer; const acount: integer = 1);
begin
 roworderinvalid;
 frowstate.insertitems(index,acount);
 inherited;
end;

procedure tdatacols.deleterow(const index: integer; const acount: integer = 1);
begin
 roworderinvalid;
 frowstate.deleteitems(index,acount);
 inherited;
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
   result:= (frowstate.getitempo(cell.row)^.selected and wholerowselectedmask <> 0);
  end
  else begin
   result:= true;
   for int1:= 0 to count - 1 do begin
    if not (cos_selected in cols[int1].fstate) then begin
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
 ca1: cardinal;
 bo1: boolean;
begin
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
    if value then begin
     for int1:= 0 to frowstate.count - 1 do begin
      if ca1 <> po1^.selected then begin
       po1^.selected:= ca1;
       fgrid.invalidaterow(int1); //for fixcols
      end;
      inc(po1);
     end;
     fselectedrow:= -2;
    end
    else begin
     if fselectedrow <> -1 then begin
      if fselectedrow >= 0 then begin
       prowstateaty(po1)^[fselectedrow].selected:= ca1;
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
        inc(po1);
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
end;

procedure tdatacols.clearselection;
begin
 setselected(invalidcell,false);
end;

procedure tdatacols.setselectedrange(const rect: gridrectty; const value: boolean;
                        const calldoselectcell: boolean = false);
var
 int1,int2: integer;
 mo1: cellselectmodety;
begin
 if calldoselectcell then begin
  if value then begin
   mo1:= csm_select;
  end
  else begin
   mo1:= csm_deselect;
  end;
  for int1:= rect.col to rect.col + rect.colcount - 1 do begin
   for int2:= rect.row to rect.row + rect.rowcount - 1 do begin
    fgrid.selectcell(makegridcoord(int1,int2),mo1{value,false});
   end;
  end;
 end
 else begin
  for int1:= rect.col to rect.col + rect.colcount - 1 do begin
   for int2:= rect.row to rect.row + rect.rowcount - 1 do begin
    selected[makegridcoord(int1,int2)]:= value;
   end;
  end;
 end;
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

function tdatacols.previosvisiblecol(aindex: integer): integer;
var
 int1: integer;
begin
 result:= invalidaxis;
 if aindex >= count then begin
  aindex:= count - 1;
 end;
 for int1:= aindex - 1 downto 0 do begin
  if not (co_invisible in cols[int1].foptions) or
                  (csdesigning in fgrid.ComponentState) then begin
   result:= int1;
   break;
  end;
 end;
end;

function tdatacols.selectedcellcount: integer;
var
 int1,int2: integer;
begin
 result:= 0;
 if hasselection then begin
  for int1:= 0 to frowstate.count - 1 do begin
   if frowstate.getitempo(int1)^.selected <> 0 then begin
    for int2:= 0 to count - 1 do begin
     if cols[int2].selected[int1] then begin
      inc(result);
     end;
    end;
   end;
  end;
 end;
end;

function tdatacols.getselectedcells: gridcoordarty;
const
 capacitystep = 64;
var
 int1,int2,int3: integer;
 cell: gridcoordty;
begin
 result:= nil;
 if hasselection then begin          //todo: optimize
  int3:= 0;
  for int1:= 0 to frowstate.count - 1 do begin
   if frowstate.getitempo(int1)^.selected <> 0 then begin
    cell.row:= int1;
    for int2:= 0 to count - 1 do begin
     if cols[int2].selected[int1] then begin
      if int3 >= length(result) then begin
       setlength(result,length(result) + capacitystep);
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

procedure tdatacols.setselectedcells(const Value: gridcoordarty);
var
 int1: integer;
begin
 fgrid.beginupdate;
 clearselection;
 for int1:= 0 to high(value) do begin
  setselected(value[int1],true);
 end;
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

procedure tdatacols.updatedatastate;
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
   ar1:= readorder(reader);
   if ar1 <> nil then begin
    fgrid.fixrows.orderdatacols(ar1);
    fgrid.layoutchanged;
   end;
  end;
  for int1:= 0 to count - 1 do begin
   cols[int1].dostatread(reader);
  end;
  if not (gs_isdb in fgrid.fstate) then begin
   int2:= 0;
   for int1:= 0 to count - 1 do begin
    with cols[int1] do begin
     if (fdata <> nil) and (fdata.count > int2) then begin
      int2:= fdata.count;
     end;
    end;
   end;
   for int1:= 0 to count - 1 do begin
    with cols[int1] do begin
     if (fdata <> nil) then begin
      fdata.count:= int2;
     end;
    end;
   end;
   fgrid.rowcount:= int2;
  end;
 finally
  fgrid.endupdate;
 end;
end;

procedure tdatacols.dostatwrite(const writer: tstatwriter);
begin
 inherited;
end;

function tdatacols.rowempty(const arow: integer): boolean;
var
 int1: integer;
begin
 result:= true;
 for int1:= 0 to count - 1 do begin
  if not cols[int1].isempty(arow) then begin
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

{ tdrawcols }

constructor tdrawcols.create(aowner: tcustomgrid);
begin
 inherited create(aowner,tdrawcol);
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
 inherited create(aowner,getcolclass);
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
  mask:= {$ifdef FPC}longword{$else}word{$endif}(avalue) xor
  {$ifdef FPC}longword{$else}word{$endif}(ftextflags);
  ftextflags:= avalue;
  for int1:= 0 to count - 1 do begin
   tstringcol(items[int1]).textflags:=
        textflagsty(replacebits({$ifdef FPC}longword{$else}word{$endif}(avalue),
        {$ifdef FPC}longword{$else}word{$endif}(tstringcol(items[int1]).textflags),mask));
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
  mask:= {$ifdef FPC}longword{$else}word{$endif}(avalue) xor
         {$ifdef FPC}longword{$else}word{$endif}(ftextflagsactive);
  ftextflagsactive := avalue;
  for int1:= 0 to count - 1 do begin
   tstringcol(items[int1]).textflagsactive:=
          textflagsty(replacebits({$ifdef FPC}longword{$else}word{$endif}(avalue),
        {$ifdef FPC}longword{$else}word{$endif}(tstringcol(items[int1]).textflagsactive),mask));
  end;
 end;
end;

procedure tstringcols.setoptionsedit(const avalue: stringcoleditoptionsty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}byte{$endif};
begin
 if foptionsedit <> avalue then begin
  mask:= {$ifdef FPC}longword{$else}word{$endif}(avalue) xor
  {$ifdef FPC}longword{$else}word{$endif}(foptionsedit);
  foptionsedit := avalue;
  for int1:= 0 to count - 1 do begin
   tstringcol(items[int1]).optionsedit:= stringcoleditoptionsty(
                  replacebits({$ifdef FPC}longword{$else}word{$endif}(avalue),
                  {$ifdef FPC}longword{$else}word{$endif}(tstringcol(items[int1]).optionsedit),mask));
  end;
 end;
end;

{ tfixcols }

constructor tfixcols.create(aowner: tcustomgrid);
begin
 freversedorder:= true;
 inherited create(aowner,tfixcol);
 flinecolor:= defaultfixlinecolor;
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

{ tfixrows }

constructor tfixrows.create(aowner: tcustomgrid);
begin
 freversedorder:= true;
 inherited create(aowner,tfixrow);
 flinecolor:= defaultfixlinecolor;
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

procedure tfixrows.movecol(const curindex,newindex: integer);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tfixrow(fitems[int1]).movecol(curindex,newindex);
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
 frowcountmax:= bigint;
 frowcolors:= tcolorarrayprop.Create;
 frowfonts:= trowfontarrayprop.Create(self);
 ffocusedcell:= invalidcell;
 fstartanchor:= invalidcell;
 fendanchor:= invalidcell;
 fmouseparkcell:= invalidcell;
 factiverow:= invalidaxis;

 foptionsgrid:= defaultoptionsgrid;
 fdatarowlinewidth:= defaultgridlinewidth;
 fdatarowlinecolorfix:= defaultfixlinecolor;
 fdatarowlinecolor:= defaultdatalinecolor;

 fdatarowheight:= griddefaultrowheight;

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

procedure tcustomgrid.rowdatachanged(const index: integer;
                const count: integer = 1);
begin
 if not (csloading in componentstate) then begin
  if fupdating = 0 then begin
   exclude(fstate,gs_rowdatachanged);
   inc(frowdatachanging);
   try
    dorowsdatachanged(index,count);
   finally
    dec(frowdatachanging);
   end;
  end
  else begin
   include(fstate,gs_rowdatachanged);
  end;
 end;
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
  result.cy:= frowcount * fystep+ ffixrows.ftotsize +
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
 if (zebra_step <> 0) then begin
  include(fstate,gs_needszebraoffset);
 end
 else begin
  exclude(fstate,gs_needszebraoffset);
  for int1:= 0 to fixcols.count -1 do begin
   if tfixcol(fixcols.items[int1]).numstep <> 0 then begin
    include(fstate,gs_needszebraoffset);
    break;
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
  tgridframe(fframe).updatestate;
  inc(int2);
 until (frame.state * scrollbarframestates = scrollstate * scrollbarframestates) or
         (int2 > 40);
end;

procedure tcustomgrid.internalupdatelayout;
begin
 if (fstate * [gs_layoutvalid,gs_updatelocked] = []) and 
             not (csdestroying in componentstate) and (fupdating = 0) then begin
  fstate:= fstate + [gs_layoutvalid,gs_layoutupdating];
  updatelayout;
  exclude(fstate,gs_layoutupdating);
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
 int1,int2,int3: integer;
 adatarect: rectty;
 reg: regionty;
 saveindex: integer;
 linewidthbefore: integer;

begin
 inherited;
 internalupdatelayout;
 fnumoffset:= getnumoffset;
 saveindex:= -1;
 if fgridframewidth <> 0 then begin
  saveindex:= acanvas.save;
 end;
 acanvas.move(pointty(tframe1(fframe).fi.innerframe.topleft));
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
  rect1:= acanvas.clipbox;
  if (rect1.cx > 0) and (rect1.cy > 0) then begin
   with colinfo do begin
    ystep:= self.fystep;
    startrow:= rect1.y div ystep;
    if startrow < 0 then begin
     startrow:= 0;
    end;
    ystart:= startrow * ystep;
    endrow:= (rect1.y + rect1.cy) div ystep;
    if endrow >= frowcount then begin
     endrow:= frowcount - 1;
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
     if fdatarowlinewidth > 0 then begin
      if fdatarowlinewidth > 0 then begin
       acanvas.linewidth:= fdatarowlinewidth;
      end;
      setlength(lines,endrow-startrow+1);
      int2:= startrow * ystep - (fdatarowlinewidth + 1) div 2;
      int3:= tframe1(fframe).finnerclientrect.cx{ - 1};
      for int1:= 0 to high(lines) do begin
       inc(int2,ystep);
       with lines[int1] do begin
        a.x:= 0;
        a.y:= int2;
        b.x:= int3;
        b.y:= int2;
       end;
      end;
      if ffixcols.count > 0 then begin   //draw horz lines fixcols
       reg:= acanvas.copyclipregion;
       acanvas.subcliprect(adatarect);
       if not acanvas.clipregionisempty then begin
        acanvas.drawlinesegments(lines,fdatarowlinecolorfix);
       end;
       acanvas.clipregion:= reg;
      end;
     end;
     acanvas.intersectcliprect(adatarect);
     if not acanvas.clipregionisempty then begin //draw horz lines datacols
      int2:= ffixcols.ffirstsize + datacols.ftotsize +
                     fscrollrect.x + ffirstnohscroll{ - 1};
      if ffirstnohscroll > 0 then begin
       int3:= ffixcols.ffirstsize;
      end
      else begin
       int3:= fscrollrect.x + ffixcols.ffirstsize;
      end;
      if length(lines) > 0 then begin //draw horz lines datacols
       for int1:= 0 to high(lines) do begin
        with lines[int1] do begin
         a.x:= int3;
         b.x:= int2;
        end;
       end;
       acanvas.drawlinesegments(lines,fdatarowlinecolor);
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
    end;
   end;
  end;
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
 fdatacols.dostatread(reader);
 if og_savestate in foptionsgrid then begin
  po1.col:= reader.readinteger('col',ffocusedcell.col);
  po1.row:= reader.readinteger('row',ffocusedcell.row);
  focuscell(po1);
 end;
end;

procedure tcustomgrid.dostatwrite(const writer: tstatwriter);
begin
 removeappendedrow;
 fdatacols.dostatwrite(writer);
 if og_savestate in foptionsgrid then begin
  writer.writeinteger('col',ffocusedcell.col);
  writer.writeinteger('row',ffocusedcell.row);
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
            (bo1 and ((og_autoappend in foptionsgrid) or
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

procedure tcustomgrid.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
begin
 if sender.tag = 1 then begin
  case event of
   sbe_stepup: scrollrows(-1);
   sbe_stepdown: scrollrows(1);
   sbe_pageup: scrollrows(-(rowsperpage-1));
   sbe_pagedown: scrollrows(rowsperpage-1);
  end;
 end
 else begin
  case event of
   sbe_stepup: scrollleft;
   sbe_stepdown: scrollright;
   sbe_pageup: scrollpageleft;
   sbe_pagedown: scrollpageright;
  end;
 end;
end;

procedure tcustomgrid.dopopup(var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty);
var
 bo1: boolean;
 state1: actionstatesty;
begin
 if (og_autopopup in foptionsgrid) then begin
  bo1:= og_rowinserting in foptionsgrid;
  if bo1 then begin
   tpopupmenu.additems(amenu,self,mouseinfo,['&Insert Row (Shift+Ctrl+Insert)',
       '&Append Row (Ctrl+Insert)'],[],[],
        [{$ifdef FPC}@{$endif}doinsertrow,{$ifdef FPC}@{$endif}doappendrow]);
  end;
  if og_rowdeleting in foptionsgrid then begin
   if ffocusedcell.row >= 0 then begin
    state1:= [];
   end
   else begin
    state1:= [as_disabled];
   end;
   tpopupmenu.additems(amenu,self,mouseinfo,['&Delete Row (Ctrl+Delete)'],
                  [],[state1],[{$ifdef FPC}@{$endif}dodeleterows],not bo1);
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
  if value < 1 then begin
   fdatarowheight:= 1;
  end
  else begin
   fdatarowheight:= value;
  end;
  layoutchanged;
 end;
end;

procedure tcustomgrid.internalcreateframe;
begin
 tgridframe.create(iframe(self),self,iautoscrollframe(self));
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

procedure tcustomgrid.dorowsdatachanged(const index,count: integer);
var
 int1: integer;
begin
 if canevent(tmethod(fonrowsdatachanged)) then begin
  fonrowsdatachanged(self,index,count);
 end;
 if canevent(tmethod(fonrowdatachanged)) then begin
  for int1:= index to index + count-1 do begin
   fonrowdatachanged(self,int1);
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
begin
 if fupdating = 0 then begin
  if row >= 0 then begin
   invalidatecell(makegridcoord(sender.colindex,row));
  end
  else begin
   colchanged(sender);
  end;
  if (ffocusedcell.row >= 0) and (sender.colindex = ffocusedcell.col) and
     ((row < 0) or (row = ffocusedcell.row)) then begin
   focusedcellchanged;
  end;
 end
 else begin
  if fnoinvalidate = 0 then begin
   if not (gs_invalidated in fstate) then begin
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
 //dummy
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

procedure tcustomgrid.rowchanged(const row: integer);
var
 rect1: rectty;
begin
 internalupdatelayout;
 rect1:= cellrect(makegridcoord(0,row));
 rect1.x:= 0;
 rect1.cx:= tgridframe(fframe).fpaintrect.cx;
 invalidaterect(rect1);
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
  else begin
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
  int1:= y div fystep;
  if int1 < frowcount then begin
   result:= int1;
  end;
 end;
end;

procedure tcustomgrid.firstcellclick(const cell: gridcoordty; const info: mouseeventinfoty);
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
   {
   else begin
    if info.shiftstate * keyshiftstatesmask = [ss_ctrl] then begin
     result:= fca_reverse;
    end;
   end;
   }
  end;
 end;
 
 var
  po1: pointty;
  action: focuscellactionty;
  bo1: boolean;
 begin      //checkfocuscell
  po1:= fscrollrect.pos;
  action:= fca_focusin;
  case cellkind of
   ck_data: begin
    if not (gs_mousecellredirected in fstate) then begin
     if not fdatacols[fmousecell.col].canfocus(info.button) then begin
      showcell(fmousecell);
     end
     else begin
      bo1:= not gridcoordisequal(fmousecell,ffocusedcell);
      if (info.shiftstate * [ss_left,ss_middle,ss_right] = [ss_left])
                  {(info.button = mb_left)} and
             (co_mouseselect in fdatacols[fmousecell.col].foptions) then begin
       if (info.shiftstate * keyshiftstatesmask = [ss_shift]) then begin
        action:= fca_selectend;
       end
       else begin
        if info.shiftstate * keyshiftstatesmask = [ss_ctrl] then begin
         if (info.button = mb_left) or (fmousecell.col <> ffocusedcell.col) or
                   (fmousecell.row <> ffocusedcell.row) then begin
          action:= fca_reverse;
         end;
        end
        else begin
         if info.button = mb_left then begin
//          action:= fca_focusinforce;
         end;
        end;
       end;
      end
      else begin
       if (action = fca_focusin) and (ss_shift in info.shiftstate) then begin
        action:= fca_focusinshift;
       end;
 
//       if (info.shiftstate * [ss_left,ss_middle,ss_right] = [ss_left]){info.button = mb_left} then begin
//        if ss_shift in info.shiftstate then begin
//         action:= fca_focusinshift;
//        end;
//       end
//       else begin
//        action:= fca_none;
//       end;
      end;
      focuscell(fmousecell,action);
      if bo1 then begin
 //      if not (action in [fca_focusin,fca_focusinforce,fca_none]) then begin
 //       include(info.eventstate,es_processed);
 //      end;
       firstcellclick(fmousecell,info);
      end;
     end;
    end;
   end;
   ck_fixcol: begin
    with fixcols[fmousecell.col] do begin
     if (fco_mousefocus in options) then begin
      if (fmousecell.row <> ffocusedcell.row) or 
                             (info.eventkind = ek_buttonpress) then begin
       focuscell(makegridcoord(col,fmousecell.row),
                getfocusact(fco_mouseselect in options),scm_row);
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

var
 coord1: gridcoordty;
 str1: msestring;
 hintinfo: hintinfoty;
// int1: integer;
 mousewidgetbefore: twidget;

begin
 inherited;
 fobjectpicker.mouseevent(info);
 if not (es_processed in info.eventstate) then begin
  fdragcontroller.clientmouseevent(info);
 end;
 if not (es_processed in info.eventstate) and
                           not(csdesigning in componentstate) then begin
  with info do begin
   if eventkind in mouseposevents then  begin
    coord1:= fmousecell;
    cellkind:= cellatpos(pos,fmousecell);
    if (coord1.col <> fmousecell.col) or 
            (coord1.row <> fmousecell.row) then begin
     invalidatesinglecell(coord1);
     invalidatesinglecell(fmousecell);
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
     invalidatesinglecell(fmousecell);
     fmousecell:= invalidcell;
     fmouseparkcell:= invalidcell;
    end;
    ek_buttonpress: begin
     mousewidgetbefore:= application.mousewidget;
     checkfocuscell;
     if (mousewidgetbefore = application.mousewidget) and 
                      //not interrupted by beginmodal
        (button = mb_left) and isdatacell(fmousecell)
               {and isdatacell(ffocusedcell) and 
              gridcoordisequal(fmousecell,ffocusedcell)} then begin
      include(fstate,gs_cellclicked);
      fclickedcellbefore:= fclickedcell;
      fclickedcell:= fmousecell;
     end;                
    end;
    ek_mousemove,ek_mousepark: begin
     if not (es_child in info.eventstate) then begin
      if cellkind = ck_data then begin
       application.cursorshape:= datacols[fmousecell.col].getcursor;
      end
      else begin
       application.cursorshape:= cursor;
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
         (ws_clicked in fwidgetstate) then begin
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
         if not fdatacols[fmousecell.col].canfocus(info.button) then begin
          showcell(fmousecell);
         end
         else begin
          focuscell(fmousecell);
//          include(info.eventstate,es_processed);
         end;
        end;
       end;
      end;
     end;
     if gs_cellclicked in fstate then begin
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
//      int1:= pos.y - clientpos.y;
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
 {
  case eventkind of
   cek_enter: begin
    if selectaction <> fca_none then begin
     showcell(newcell);
    end;
   end;
  end;
  }
  if canevent(tmethod(foncellevent)) then begin
   foncellevent(self,info);
  end;
  if info.cell.col >= 0 then begin
   datacols[info.cell.col].docellevent(info);
  end;
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

procedure tcustomgrid.dofocusedcellposchanged;
begin
 //dummy
end;

function tcustomgrid.selectcell(const cell: gridcoordty; const amode: cellselectmodety
                                        {avalue: boolean; flip: boolean}): boolean;
 //calls onselectcell
var
 info: celleventinfoty;
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
 if (amode = csm_reverse) or (info.selected <> fdatacols.selected[cell]) then begin
  docellevent(info);
  result:= info.accept;
  if result then begin
   if (cell.col >= 0) and (co_rowselect in fdatacols[cell.col].foptions) then begin
    fdatacols.selected[makegridcoord(invalidaxis,cell.row)]:= info.selected;
   end
   else begin
    fdatacols.selected[cell]:= info.selected;
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

function tcustomgrid.focuscell(cell: gridcoordty;
          selectaction: focuscellactionty = fca_focusin;
          const selectmode: selectcellmodety = scm_cell): boolean;

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
    fdatacols.setselectedrange(rect1,true,true);
   end
   else begin
    if po1^ >= po3^ then begin //right side
     int1:= po1^ - po2^.pos - po2^.count;
     if int1 >= 0 then begin
      po2^.pos:= po2^.pos + po2^.count;
      po2^.count:= int1 + 1;
      fdatacols.setselectedrange(rect1,true,true);
     end
     else begin
      po2^.pos:= po1^ + 1;
      po2^.count:= -int1 - 1;
      fdatacols.setselectedrange(rect1,false,true);
     end;
    end
    else begin //left side
     int1:= po2^.pos - po1^;
     if int1 >= 0 then begin
      po2^.pos:= po1^;
      po2^.count:= int1;
      fdatacols.setselectedrange(rect1,true,true);
     end
     else begin
      po2^.count:= -int1;
      fdatacols.setselectedrange(rect1,false,true);
     end;
    end;
   end;
  end;
  
  procedure doselectcell(const mode: cellselectmodety);
  begin
   case selectmode of
    scm_row: begin
     selectcell(makegridcoord(invalidaxis,cell.row),mode);
    end;
    scm_col: begin
     selectcell(makegridcoord(cell.col,invalidaxis),mode);
    end;
    else begin
     selectcell(cell,mode);
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
    fca_entergrid,fca_focusin,fca_focusinrepeater,fca_focusinforce,fca_setfocusedcell: begin
     if (selectaction <> fca_entergrid) then begin
      fdatacols.selected[invalidcell]:= false;
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
         fdatacols.setselectedrange(rect1,true,true);
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
       fdatacols.setselectedrange(makegridrect(cells,celle),true,true);
      end;
     end;
     fendanchor:= cell;
    end;
   end;
  finally
   endupdate;
  end;
 end;

 function isappend(const arow: integer): boolean;
 begin
  result:= not (gs_isdb in fstate) and 
      ((og_autoappend in foptionsgrid) and (arow >= frowcount) or
       (arow = 0) and (frowcount = 0) and (og_autofirstrow in foptionsgrid));
 end;

var
 focuscount: integer;
 coord1,coord2: gridcoordty;
 bo1: boolean;
 int1: integer;
 rect1: rectty;
 nullchecklocked: boolean;
 
begin     //focuscell
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
   if ((cell.row <> ffocusedcell.row) or (cell.col <> ffocusedcell.col)) and           
           not docheckcellvalue or (focuscount <> ffocuscount) then begin
    exit;
   end;
   if (cell.row <> ffocusedcell.row) and (ffocusedcell.row >= 0) and 
            container.entered and
            not container.canclose(window.focusedwidget) then begin
    exit;        //for not null check in twidgetgrid
   end;
  end;
  if (selectaction in [fca_focusin,fca_focusinrepeater,fca_focusinforce]) and 
      ((cell.col < 0) or  not fdatacols[cell.col].canfocus(mb_none)) then begin
   selectaction:= fca_setfocusedcell;
  end;
  if selectaction = fca_entergrid then begin
   if cell.row < 0 then begin
    cell.row:= 0;
   end;
   if cell.col < 0 then begin
    cell.col:= 0;
   end;
   cell.col:= nextfocusablecol(cell.col,false);
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
  end;
  bo1:= (cell.col <> invalidaxis) or (cell.row <> invalidaxis);
  if (cell.col <> ffocusedcell.col) or (cell.row <> ffocusedcell.row) or
        (selectaction in [fca_entergrid,fca_focusinforce]) or 
        (gs_restorerow in fstate) then begin
   exclude(fstate,gs_restorerow);
//   inc(ffocuscount);
//   focuscount:= ffocuscount;
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
 
   if cell.row >= 0 then begin
    int1:= cell.row - ffocusedcell.row;
    if int1 <> 0 then begin
     checksort;
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
     rowcount:= frowcount + 1;
    end
    else begin
     factiverow:= coord1.row;
     include(fstate,gs_restorerow);
     focuscell(coord1,selectaction); //restore previous row
     exit;
    end;
   end;
 
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
    if (cell.row > invalidaxis) and (cell.col > invalidaxis) then begin
     rect1:= cellrect(cell);
     with rect1 do begin
      if (cell.row >= 0) and 
           ((x < fdatarect.x) or (x + cx > fdatarect.x + fdatarect.cx)) or
         (cell.col >= 0) and 
           ((y < fdatarect.y) or (y + cy > fdatarect.y + fdatarect.cy)) then begin
       update; //scrolling needed, update pending paintings with old focused cell
      end;
     end;
    end;
    ffocusedcell:= cell;
   end;
   if bo1 then begin
    showcell(cell);
   end;
   if isdatacell(cell) then begin
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
//    if bo1 then begin
//     showcell(cell);
//    end;
//   end;
  end
  else begin
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

function tcustomgrid.isdatacell(const coord: gridcoordty): boolean;
begin
 with coord do begin
  result:= (col >= 0) and (row >= 0) and
        (col < fdatacols.count) and (row < frowcount);
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

procedure tcustomgrid.scrollrows(const step: integer);
begin
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
 if not (gs_cellexiting in fstate) and (fnoshowcaretrect = 0) and
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
 if force or not (frame.sbvert.clicked or frame.sbvert.clicked) then begin
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

procedure tcustomgrid.showlastrow;
begin
 showcell(makegridcoord(col,rowhigh));
end;

function tcustomgrid.cellrect(const cell: gridcoordty;
              const innerlevel: cellinnerlevelty = cil_all): rectty;

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
     cy:= fcellinfo.rect.cy;
    end;
    cil_inner: begin
     inc(y,fcellinfo.rect.y);
     inc(y,fcellinfo.innerrect.y);
     cy:= fcellinfo.innerrect.cy;
    end;
   end;
  end;
 end;
 
var
 isfixr: boolean;
 int1: integer; 
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
     if col >= 0 then begin
      if col < fcaptions.count then begin
       inc(cx,tcolheader(fcaptions.fitems[col]).fmergedcx);
      end;
     end
     else begin
      int1:= -col - 1;
      if int1 < fcaptionsfix.count then begin
       with tcolheader(fcaptionsfix.fitems[int1]) do begin
        inc(x,fmergedx);
        inc(cx,fmergedcx);
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
  else begin
   if (row < frowcount) or (csdesigning in componentstate) then begin
    cy:= fystep;
    y:= row * cy + ffixrows.ffirstsize + fscrollrect.y;
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

procedure tcustomgrid.rowup(const action: focuscellactionty = fca_focusin);
begin
 if ffocusedcell.row > 0 then begin
  focuscell(makegridcoord(ffocusedcell.col,ffocusedcell.row - 1),action);
 end
 else begin
  if og_rotaterow in foptionsgrid then begin
   focuscell(makegridcoord(ffocusedcell.col,frowcount - 1),action);
  end;
 end;
end;

procedure tcustomgrid.rowdown(const action: focuscellactionty = fca_focusin);
begin
 if (ffocusedcell.row < frowcount - 1) or 
               not (og_rotaterow in foptionsgrid) then begin
  focuscell(makegridcoord(ffocusedcell.col,ffocusedcell.row + 1),action);
 end
 else begin
  if og_rotaterow in foptionsgrid then begin
   focuscell(makegridcoord(ffocusedcell.col,0),action);
  end;
 end;
end;

procedure tcustomgrid.pageup(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 int1:= ffocusedcell.row - rowsperpage + 1;
 if int1 < 0 then begin
  int1:= 0;
 end;
 if int1 < frowcount then begin
  scrollrows(rowsperpage - 1);
  focuscell(makegridcoord(ffocusedcell.col,int1),action);
 end;
end;

procedure tcustomgrid.pagedown(const action: focuscellactionty = fca_focusin);
var
 int1: integer;
begin
 int1:= ffocusedcell.row + rowsperpage - 1;
 if int1 > frowcount - 1 then begin
  int1:= frowcount -1;
 end;
 if int1 >= 0 then begin
  scrollrows(-(rowsperpage - 1));
  focuscell(makegridcoord(ffocusedcell.col,int1),action);
 end;
end;

procedure tcustomgrid.firstrow(const action: focuscellactionty = fca_focusin);
begin
 if frowcount > 0 then begin
  focuscell(makegridcoord(ffocusedcell.col,0),action);
 end;
end;

procedure tcustomgrid.lastrow(const action: focuscellactionty = fca_focusin);
begin
 if frowcount > 0 then begin
  focuscell(makegridcoord(ffocusedcell.col,frowcount-1),action);
 end;
end;

procedure tcustomgrid.colstep(const action: focuscellactionty; step: integer;
                 const rowchange: boolean);
var
 int1: integer;
 arow: integer;
begin
 if fdatacols.count > 0 then begin
  arow:= ffocusedcell.row;
  int1:= ffocusedcell.col;
  repeat
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
   if step > 0 then begin
    inc(int1);
    if int1 >= fdatacols.count then begin
     int1:= 0;
     if rowchange then begin
      inc(arow);
     end;
    end;
    if fdatacols[int1].canfocus(mb_none) then begin
     dec(step);
    end;
   end
   else begin
    dec(int1);
    if int1 < 0 then begin
     int1:=  fdatacols.count - 1;
     if rowchange then begin
      dec(arow);
     end;
    end;
    if fdatacols[int1].canfocus(mb_none) then begin
     inc(step);
    end;
   end;
  until int1 = ffocusedcell.col; //none found
 end;
end;
{
procedure tcustomgrid.colleft(action: focuscellactionty);
var
 int1: integer;
begin
 if ffocusedcell.col > 0 then begin
  int1:= ffocusedcell.col - 1;
 end
 else begin
  int1:= fdatacols.count - 1;
 end;
 if int1 >= 0 then begin
  focuscell(makegridcoord(int1,ffocusedcell.row),action);
 end;
end;

procedure tcustomgrid.colright(action: focuscellactionty);
var
 int1: integer;
begin
 if ffocusedcell.col < fdatacols.count - 1 then begin
  int1:= ffocusedcell.col + 1;
 end
 else begin
  int1:= 0;
 end;
 if int1 < fdatacols.count then begin
  focuscell(makegridcoord(int1,ffocusedcell.row),action);
 end;
end;
}
procedure tcustomgrid.domousewheelevent(var info: mousewheeleventinfoty);
begin
 frame.domousewheelevent(info);
 inherited;
end;

{
procedure tcustomgrid.domousewheelevent(var info: mousewheeleventinfoty);
var
 action: focuscellactionty;
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   if ss_shift in shiftstate then begin
    action:= fca_focusinshift;
   end
   else begin
    action:= fca_focusin;
   end;
   include(eventstate,es_processed);
   case wheel of
    mw_up: begin
     if gs_isdb in fstate then begin
      pageup(action);
     end
     else begin
      scrollrows(rowsperpage-1);
     end;
    end;
    mw_down: begin
     if gs_isdb in fstate then begin
      pagedown(action);
     end
     else begin
      scrollrows(-rowsperpage+1);
     end;
    end;
   end;
  end;
 end;
end;
}
procedure tcustomgrid.dokeydown(var info: keyeventinfoty);
var
 action: focuscellactionty;
 focusbefore: gridcoordty;
 mo1: cellselectmodety;
begin
 if canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,info);
 end;
 if not(es_processed in info.eventstate) then begin
  if ffocusedcell.col >= 0 then begin
   fdatacols[ffocusedcell.col].dokeyevent(info,false);
   if not (es_processed in info.eventstate) and
       (info.shiftstate - [ss_shift,ss_ctrl] = []){ and
       (info.shiftstate <> [ss_shift,ss_ctrl])} then begin
    include(info.eventstate,es_processed);
    if ss_shift in info.shiftstate then begin
     action:= fca_focusinshift;
    end
    else begin
     action:= fca_focusin;
    end;
    focusbefore:= ffocusedcell;
    case info.key of
     key_up: begin
      if info.shiftstate = [ss_ctrl] then begin
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
      end;
     end;
     key_down: begin
      if info.shiftstate = [ss_ctrl] then begin
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
      end;
     end;
     key_pageup: begin
      if ss_ctrl in info.shiftstate then begin
       firstrow(action);
      end
      else begin
       pageup(action);
      end;
     end;
     key_pagedown: begin
      if ss_ctrl in info.shiftstate then begin
       lastrow(action);
      end
      else begin
       pagedown(action);
      end;
     end;
     key_tab,key_backtab: begin
      if not (og_colchangeontabkey in foptionsgrid) then begin
       exclude(info.eventstate,es_processed);
       dokeydownaftershortcut(info);
      end
      else begin
       if info.shiftstate - [ss_shift] = [] then begin
        if docheckcellvalue then begin
         action:= fca_focusin;
         if info.shiftstate = [ss_shift] then begin
          colstep(action,-1,true);
         end
         else begin
          colstep(action,1,true);
         end;
        end;
       end
       else begin
        exclude(info.eventstate,es_processed);
       end;
      end;
     end;
     key_left: begin
      if info.shiftstate = [ss_ctrl] then begin
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
       colstep(action,-1,false);
      end;
     end;
     key_right: begin
      if info.shiftstate = [ss_ctrl] then begin
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
       colstep(action,1,false);
      end;
     end;
     else begin
      exclude(info.eventstate,es_processed);
     end;
    end;
    if (es_processed in info.eventstate) and (ffocusedcell.col >= 0) then begin
     if co_keyselect in fdatacols[ffocusedcell.col].foptions then begin
      if ss_shift in info.shiftstate then begin
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
   if not (es_processed in info.eventstate) then begin
    with fdatacols[ffocusedcell.col] do begin
     if (info.key = key_space) and
          (foptions * [co_keyselect,co_multiselect] = [co_keyselect,co_multiselect]) and
      ((info.shiftstate = [ss_shift]) or (info.shiftstate = [ss_ctrl])) then begin
      if info.shiftstate = [ss_ctrl] then begin
       mo1:= csm_reverse;
      end
      else begin
       mo1:= csm_select;
      end;
      selectcell(ffocusedcell,mo1{true,(info.shiftstate = [ss_ctrl])});
      include(info.eventstate,es_processed);
     end;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) and (info.shiftstate = [ss_ctrl]) or
                       (info.shiftstate = [ss_ctrl,ss_shift])then begin
   include(info.eventstate,es_processed);
   case info.key of
    key_insert: begin
     if og_rowinserting in foptionsgrid then begin
      if (ss_shift in info.shiftstate) then begin
       doinsertrow(nil);
      end
      else begin
       doappendrow(nil);
      end;
     end
     else begin
      exclude(info.eventstate,es_processed);
     end;
    end;
    key_delete: begin
     if og_rowdeleting in foptionsgrid then begin
      if (info.shiftstate = [ss_ctrl]) then begin
       dodeleterows(nil);
      end;
     end
     else begin
      exclude(info.eventstate,es_processed);
     end;
    end;
    else begin
     exclude(info.eventstate,es_processed);
    end;
   end;
  end;
  if not (es_processed in info.eventstate) and (info.shiftstate = [ss_ctrl]) then begin
   case info.key of
    key_c: begin
     if copyselection then begin
      include(info.eventstate,es_processed);
     end;
    end;
    key_v: begin
     if pasteselection then begin
      include(info.eventstate,es_processed);
     end;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomgrid.dokeyup(var info: keyeventinfoty);
begin
 if ffocusedcell.col >= 0 then begin
  fdatacols[ffocusedcell.col].dokeyevent(info,true);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomgrid.updatevisiblerows;
var
 cell: gridcoordty;
begin
 cellatpos(makepoint(0,fdatarecty.y),cell);
 ffirstvisiblerow:= cell.row;
 cellatpos(makepoint(0,fdatarecty.y+fdatarecty.cy-1),cell);
 flastvisiblerow:= cell.row;
 if ffirstvisiblerow < 0 then begin
  ffirstvisiblerow:= 0;
 end;
 if flastvisiblerow < 0 then begin
  flastvisiblerow:= frowcount - 1;
 end;
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

function tcustomgrid.getselectedrows: integerarty;
var
 int1,count: integer;
 po1: prowstatety;
begin
 result:= nil;
 po1:= fdatacols.frowstate.datapo;
 count:= 0;
 for int1:= 0 to frowcount - 1 do begin
  if po1^.selected and wholerowselectedmask <> 0 then begin
   additem(result,int1,count);
  end;
  inc(po1);
 end;
 setlength(result,count);
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
begin
 inherited;
 fdatacols.checkindexrange;
 dorowsdatachanged(0,frowcount);
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
    (og_colmoving in foptionsgrid) and not (co_fixpos in fdatacols[cell.col].foptions);
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
   if (pos.y <= rect1.y + sizingtol) then begin
    if canrowsizing then begin
     objects[0]:= pickobjectstep * (cell.row-1) + integer(pok_datarowsize);
    end;
   end
   else begin
    if (pos.y >= rect1.y + rect1.cy - sizingtol) then begin
     if canrowsizing then begin
      objects[0]:= pickobjectstep * (cell.row) + integer(pok_datarowsize);
     end;
    end
    else begin
     if (csdesigning in componentstate) and not nofixed then begin
      if (pos.x <= rect1.x + sizingtol) and
           (cell.col <> ffixcols.ffirstopposite + 1) then begin
       if cell.col <= ffixcols.ffirstopposite then begin
        objects[0]:= -pickobjectstep * (cell.col) + integer(pok_fixcolsize);
       end
       else begin
        objects[0]:= -pickobjectstep * (cell.col-1) + integer(pok_fixcolsize);
       end;
      end
      else begin
       if (pos.x >= rect1.x + rect1.cx - sizingtol) then begin
        if (cell.col <> ffixcols.ffirstopposite) then begin
         objects[0]:= -pickobjectstep * (cell.col) + integer(pok_fixcolsize);
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
    if cancolsizing(cell.col) and 
          (nofixed or not ffixrows[cell.row].mergedline(cell.col)) then begin
     objects[0]:= pickobjectstep * (cell.col) + integer(pok_datacolsize);
    end;
   end
   else begin
    if (pos.x <= rect1.x + sizingtol) then begin
     int1:= fdatacols.previosvisiblecol(cell.col);
     if cancolsizing(int1) and 
          (nofixed or not ffixrows[cell.row].mergedline(int1)) then begin
      objects[0]:= pickobjectstep * (int1) + integer(pok_datacolsize);
     end;
    end
    else begin
     if (csdesigning in componentstate) and not nofixed then begin
      if (pos.y <= rect1.y + sizingtol) then begin
       if cell.row <> ffixrows.ffirstopposite + 1 then begin
        if cell.row <= ffixrows.ffirstopposite then begin
         objects[0]:= -pickobjectstep * (cell.row) + integer(pok_fixrowsize);
        end
        else begin
         objects[0]:= -pickobjectstep * (cell.row-1) + integer(pok_fixrowsize);
        end;
       end;
      end
      else begin
       if (pos.y >= rect1.y + rect1.cy - sizingtol) and
              (cell.row <> ffixrows.ffirstopposite) then begin
        objects[0]:= -pickobjectstep * (cell.row) + integer(pok_fixrowsize);
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
       objects[0]:= pickobjectstep * cell.col + integer(pok_datacol);
       result:= true;
      end;
     end;
    end;
   end;
  end;
 end;

begin
 if shiftstate <> [ss_left] then begin
  exit;
 end;
 setlength(objects,1);
 objects[0]:= -1; //none
 with rect do begin
  cellkind:= cellatpos(pos,cell);
  rect1:= cellrect(cell,cil_noline);
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

procedure tcustomgrid.endpickmove(const apos,offset: pointty;
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
   datarowheight:= fdatarowheight + offset.y;
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
begin
 if gs_scrollup in fstate then begin
  if gs_cellclicked in fstate then begin
   if row < rowcount - 1 then begin
    rowdown(frepeataction);
   end;
  end
  else begin
   scrollrows(1);
  end;
 end
 else begin
  if gs_scrolldown in fstate then begin
   if gs_cellclicked in fstate then begin
    if row > 0 then begin
     rowup(frepeataction);
    end;
   end
   else begin
    scrollrows(-1);
   end;
  end
  else begin
   if gs_scrollleft in fstate then begin
    if gs_cellclicked in fstate then begin
     if ffocusedcell.col > 0 then begin
      colstep(frepeataction,-1,false);
     end;
    end
    else begin
     scrollright;
    end;
   end
   else begin
    if gs_scrollright in fstate then begin
     if gs_cellclicked in fstate then begin
      if ffocusedcell.col < fdatacols.count - 1 then begin
       colstep(frepeataction,1,false);
      end;
     end
     else begin
      scrollleft;
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
  ffixrows.movecol(curindex,newindex);
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
 rowbefore:= ffocusedcell.row;
 beginupdate;
 if curindex >= 0 then begin //datarows
  if (ffocusedcell.row >= 0) then begin
   if (ffocusedcell.row >= curindex) and
         (ffocusedcell.row < curindex + count) then begin
    int1:= newindex;
    if int1 + count > frowcount then begin
     int1:= frowcount - count;
    end;
    ffocusedcell.row:= int1 + ffocusedcell.row - curindex;
   end
   else begin
    if (ffocusedcell.row > curindex) and  (ffocusedcell.row <= newindex) then begin
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
  fdatacols.moverow(curindex,newindex,count);
  invalidate //for fixcols colorselect
 end;
 endupdate;
 dorowsmoved(curindex,newindex,count);
 if rowbefore <> ffocusedcell.row then begin
  dofocusedcellposchanged;
 end;
end;

procedure tcustomgrid.insertrow(index: integer; count: integer = 1);
var
 rowbefore: integer;
begin
 if count > 0 then begin
  dorowsinserting(index,count);
  rowbefore:= ffocusedcell.row;
  beginupdate;
  if index >= 0 then begin //datarows
   fdatacols.insertrow(index,count);
   ffixcols.insertrow(index,count);
   if (ffocusedcell.row >= 0) then begin
    if (ffocusedcell.row >= index) then begin
     inc(ffocusedcell.row,count);
     if (factiverow >= 0) then begin
      factiverow:= ffocusedcell.row;
     end;
    end;
   end;
//   fdatacols.insertrow(index,count);
//   ffixcols.insertrow(index,count);
   inc(frowcount,count);
   if frowcount > frowcountmax then begin
    frowcount:= frowcountmax;
   end;
   dorowcountchanged(frowcount-count,frowcount);
  end;
  endupdate;
  dorowsinserted(index,count);
  if rowbefore <> ffocusedcell.row then begin
   dofocusedcellposchanged;
  end;
 end;
end;

procedure tcustomgrid.deleterow(index: integer; count: integer = 1);
var
 cellbefore: gridcoordty;
 countbefore: integer;
 defocused: boolean;
begin
 if count > 0 then begin
  dorowsdeleting(index,count);
  defocused:= false;
  cellbefore:= ffocusedcell;
  beginupdate;
  if index >= 0 then begin //datarows
   if (factiverow >= 0) then begin
    if (factiverow >= index + count) then begin
     dec(factiverow,count);
    end
   end;
   if (ffocusedcell.row >= 0) then begin
    if (ffocusedcell.row >= index + count) then begin
     dec(ffocusedcell.row,count);
    end
    else begin
     if ffocusedcell.row >= index then begin
      countbefore:= frowcount;
      focuscell(makegridcoord(ffocusedcell.col,invalidaxis)); //defocus row
      if ffocusedcell.row <> invalidaxis then begin
       factiverow:= ffocusedcell.row;
       exit;
      end;
      defocused:= true;
      dec(count,countbefore - frowcount); //correct removed empty last row
     {
      if index < frowcount - count then begin
       ffocusedcell.row:= index;
      end
      else begin
       int1:= frowcount-count-1;
       if int1 < 0 then begin
        countbefore:= frowcount;
        focuscell(makegridcoord(ffocusedcell.col,invalidaxis)); //defocus row
        if ffocusedcell.row <> invalidaxis then begin
         factiverow:= ffocusedcell.row;
         exit;
        end;
        defocused:= true;
        dec(count,countbefore - frowcount); //correct removed empty last row
       end
       else begin
        ffocusedcell.row:= int1;
       end;
      end;
      }
     end;
    end;
//    factiverow:= ffocusedcell.row;
   end;
   if count > 0 then begin
    fdatacols.deleterow(index,count);
    ffixcols.deleterow(index,count);
    dec(frowcount,count);
    dorowcountchanged(frowcount+count,frowcount);
   end;
  end;
  endupdate;
  dorowsdeleted(index,count);
  if cellbefore.row <> ffocusedcell.row then begin
   dofocusedcellposchanged;
  end;
  if (og_focuscellonenter in foptionsgrid) and defocused then begin
   cellbefore.row:= index;
   focuscell(cellbefore,fca_focusin{fca_entergrid});
             //ev. auto append row
  end;
 end;
end;

procedure tcustomgrid.clear; //sets rowcount to 0
begin
 rowcount:= 0;
end;
(*
function tcustomgrid.appendrow: integer; //returns index of new row
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
 rect1: rectty; 
begin
 statebefore:= tgridframe(fframe).fstate;
 scrollheightbefore:= 
  tcustomscrollbar1(tgridframe(fframe).fvert).fdrawinfo.areas[sbbu_move].dim.cy;
 noinvalidatebefore:= fnoinvalidate;
 updatingbefore:= fupdating;
 beginupdate;
 inc(fnoinvalidate);
 try
  if frowcount >= frowcountmax then begin
   po1.x:= 0;
   po1.y:= -fystep;
   updatelayout1;
   dec(fnoinvalidate);
   checkinvalidate1;
   inc(fnoinvalidate);
   scrollrect(po1,fdatarecty,scrollcaret);
   rowcount:= frowcount+1;
   updatelayout1;
//   scrollrect(po1,fdatarecty,scrollcaret);
   dec(fnoinvalidate);
//invalidaterect(clientrect);
   rowchanged(frowcount-1);
  end
  else begin
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
   if tcustomscrollbar1(tgridframe(fframe).fvert).fdrawinfo.areas[sbbu_move].dim.cy <> 
                    scrollheightbefore then begin
    tcustomscrollbar1(tgridframe(fframe).fvert).invalidate;
   end;
  end;
 finally
  fnoinvalidate:= noinvalidatebefore;
  fupdating:= updatingbefore
 end;
end;
*)

function tcustomgrid.appendrow: integer; //returns index of new row
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
 statebefore:= tgridframe(fframe).fstate;
 scrollheightbefore:= 
  tcustomscrollbar1(tgridframe(fframe).fvert).fdrawinfo.areas[sbbu_move].dim.cy;
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
   if tcustomscrollbar1(tgridframe(fframe).fvert).fdrawinfo.areas[sbbu_move].dim.cy <> 
                    scrollheightbefore then begin
    tcustomscrollbar1(tgridframe(fframe).fvert).invalidate;
   end;
  end;
 finally
  fnoinvalidate:= noinvalidatebefore;
  fupdating:= updatingbefore
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
  finvalidatedcells:= nil;
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

procedure tcustomgrid.endupdate;
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
  checksort;
  checkinvalidate;
  if gs_rowdatachanged in fstate then begin
   rowdatachanged(0,frowcount);
  end; 
  if gs_selectionchanged in fstate then begin
   internalselectionchanged;
  end;
  if (ffocusedcell.col >= 0) and (ffocusedcell.row >= 0) then begin
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
 dorowsdatachanged(index,count);
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

procedure tcustomgrid.setoptionsgrid(const avalue: optionsgridty);
begin
 if foptionsgrid <> avalue then begin
  foptionsgrid := avalue;
  layoutchanged;
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
begin
 if not fdragcontroller.beforedragevent(info) then begin
  inherited;
 end;
 fdragcontroller.afterdragevent(info);
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

function tcustomgrid.nextfocusablecol(acol: integer;
  const aleft: boolean): integer;
var
 int1: integer;
 loopcount: integer;
begin
 result:= -1;
 if fdatacols.count > 0 then begin
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
    if fdatacols[int1].canfocus(mb_none) then begin
     result:= int1;
     break;
    end;
    dec(int1);
   until (int1 = acol) or (loopcount > 0);
  end
  else begin
   if acol < 0 then begin
    acol:= 0;
   end;
   int1:= acol;
   repeat
    if int1 >= fdatacols.count then begin
     int1:= 0;
     inc(loopcount);
    end;
    if fdatacols[int1].canfocus(mb_none) then begin
     result:= int1;
     break;
    end;
    inc(int1);
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
  checkcellvalue(result);
 end;
end;

procedure tcustomgrid.removeappendedrow;
begin
 docheckcellvalue;
 if not (gs_isdb in fstate) and (frowcount > 0) and 
 ({(gs_rowappended in fstate) and}
          (frowcount = 1) and (og_autofirstrow in foptionsgrid) or
      (foptionsgrid * [og_autoappend,og_appendempty] = [og_autoappend])
     ) and fdatacols.rowempty(frowcount - 1) then begin
  rowcount:= rowcount - 1;
  include(fstate,gs_emptyrowremoved);
 end;
// exclude(fstate,gs_rowappended);
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
    fdatacols.rearange(list);
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
 int1:= ffocusedcell.row;
 if assigned(fonsort) then begin
  internalsort(fonsort,int1);
 end
 else begin
  internalsort({$ifdef FPC}@{$endif}fdatacols.sortfunc,int1);
 end;
 ffocusedcell.row:= int1;
 include(fstate,gs_sortvalid);
 layoutchanged;
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
 if og_sorted in foptionsgrid then begin
  sort;
 end;
end;

procedure tcustomgrid.sortinvalid;
begin
 exclude(fstate,gs_sortvalid);
end;

procedure tcustomgrid.checksort;
begin
 if not (gs_sortvalid in fstate) then begin
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

function tcustomgrid.getrowcolorstate(index: integer): rowstatenumty;
begin
 result:= fdatacols.frowstate.getitempo(index)^.color - 1;
end;

procedure tcustomgrid.setrowcolorstate(index: integer; const Value: rowstatenumty);
begin
 fdatacols.frowstate.getitempo(index)^.color:= value + 1;
 rowchanged(index);
end;

function tcustomgrid.getrowfontstate(index: integer): rowstatenumty;
begin
 result:= fdatacols.frowstate.getitempo(index)^.font - 1;
end;

procedure tcustomgrid.setrowfontstate(index: integer; const Value: rowstatenumty);
begin
 fdatacols.frowstate.getitempo(index)^.font:= value + 1;
 rowchanged(index);
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
 int1: integer;
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
begin
 appinsrow(ffocusedcell.row);
end;

procedure tcustomgrid.doappendrow(const sender: tobject);
begin
 appinsrow(ffocusedcell.row+1);
end;

procedure tcustomgrid.dodeleterow(const sender: tobject);
begin
 if askok('Delete row?','Confirmation') then begin
  deleterow(ffocusedcell.row);
 end;
end;

procedure tcustomgrid.dodeleteselectedrows(const sender: tobject);
var
 ar1: integerarty;
 int1: integer;
begin
 ar1:= getselectedrows;
 if high(ar1) >= 0 then begin
  if askok('Delete '+inttostr(length(ar1))+
                ' selected rows?','Confirmation') then begin
   for int1:= high(ar1) downto 0 do begin
    deleterow(ar1[int1]);
   end;
  end;
 end;
end;

procedure tcustomgrid.dodeleterows(const sender: tobject);
begin
 if (og_selectedrowsdeleting in foptionsgrid) and (high(getselectedrows) >= 0) then begin
  dodeleteselectedrows(sender);
 end
 else begin
  if (og_rowdeleting in foptionsgrid) and (ffocusedcell.row >= 0) then begin
   dodeleterow(sender);
  end;
 end;
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
// datarowlinewidth:= 0;
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
begin
 drawcellbackground(canvas);
 po1:= cellrect(ffocusedcell,cil_paint).pos;
 canvas.remove(po1);
 feditor.dopaint(canvas);
 canvas.move(po1);
end;

procedure tcustomstringgrid.doselectionchanged;
begin
 if isdatacell(focusedcell) then begin
  feditor.font:= fdatacols[ffocusedcell.col].rowfont(ffocusedcell.row)
 end;
 inherited;
end;

procedure tcustomstringgrid.setupeditor(const acell: gridcoordty);
begin
 feditor.setup(items[acell],0,false,cellrect(acell,cil_inner),
                    cellrect(acell,cil_paint),nil,nil,fdatacols[acell.col].rowfont(acell.row));
 feditor.textflags:= tstringcol(fdatacols[acell.col]).textflags;
 feditor.textflagsactive:= tstringcol(fdatacols[acell.col]).ftextflagsactive;
 feditor.dofocus;
 if active then begin
  feditor.doactivate;
 end;
end;

procedure tcustomstringgrid.focusedcellchanged;
begin
 setupeditor(ffocusedcell);
end;

procedure tcustomstringgrid.docellevent(var info: celleventinfoty);
begin
 inherited;
 with info do begin
  case eventkind of
   cek_enter: begin
    setupeditor(newcell);
   end;
   cek_exit: begin
   {
    if (sco_edited in fdatacols[cellbefore.col]) and not (oe_readonly in feditor.optionsedit) then begin
     items[cellbefore]:= feditor.text;
    end;
   }
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

procedure tcustomstringgrid.firstcellclick(const cell: gridcoordty; const info: mouseeventinfoty);
begin
 inherited;
 feditor.setfirstclick;
end;

procedure tcustomstringgrid.clientmouseevent(var info: mouseeventinfoty);
var
 bo2: boolean;
begin
 bo2:=  gs_cellclicked in fstate;
 inherited;
 if not (es_processed in info.eventstate) and focusedcellvalid and
         (info.eventkind in mouseposevents) and
               (gridcoordisequal(ffocusedcell,fmousecell) or bo2) then begin
  feditor.mouseevent(info);
 end;
{
 po1:= addpoint(info.pos,clientpos);
 bo1:= (gs_cellclicked in fstate);
 if bo1 and (info.eventkind in [ek_mousemove,ek_mousepark]) then begin
  bo1:= (not ((ffocusedcell.col >= 0) and 
                (co_mousescrollrow in datacols[ffocusedcell.col].options)) or 
            (po1.y + mousescrolldist >= fdatarect.y) and 
            (po1.y - mousescrolldist < fdatarect.y + fdatarect.cy)) and
        (not (og_mousescrollcol in foptionsgrid) or 
            (po1.x + mousescrolldist >= fdatarect.x) and 
            (po1.x - mousescrolldist < fdatarect.x + fdatarect.cx));
 end;            
 if not bo1 then begin
  inherited;
 end
 else begin
  if (info.eventkind = ek_buttonrelease) and (gs_cellclicked in fstate) then begin
   killrepeater;
   exclude(fstate, gs_cellclicked);
  end;
 end;
 if not (es_processed in info.eventstate) and focusedcellvalid and
         (info.eventkind in mouseposevents) and
         gridcoordisequal(ffocusedcell,fmousecell) then begin
  feditor.mouseevent(info);
 end
 else begin
  if bo1 then begin
   inherited;
  end;
 end;
 }
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
 if feditor.sellength = 0 then begin
  ar1:= datacols.selectedcells;
  if ar1 <> nil then begin
   wstr1:= '';
   int2:= ar1[0].row;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1].row <> int2 then begin
     wstr1:= wstr1 + lineend;
     int2:= ar1[int1].row;
    end;
    if co_cancopy in datacols[ar1[int1].col].foptions then begin
     wstr1:= wstr1 + self.items[ar1[int1]] + c_tab;
    end;
   end;
   msewidgets.copytoclipboard(wstr1);
   result:= true;
  end;
 end;
end;

function tcustomstringgrid.pasteselection: boolean;
var
 wstr1: msestring;
 int1,int2,int3,{int4,}int5: integer;
 ar4,ar5: msestringarty;
 bo1: boolean;
// acol: integer;
begin
 result:= false;
 bo1:= false;
 ar4:= nil; //compiler warning
 ar5:= nil; //compiler warning
 for int1:= 0 to datacols.count - 1 do begin
  if co_canpaste in datacols[int1].options then begin
   bo1:= true;
   break;
  end;
 end;
 if bo1 and pastefromclipboard(wstr1) then begin
  ar4:= breaklines(wstr1);
  if high(ar4) >= 0 then begin
   ar5:= splitstring(ar4[0],c_tab);
   if (og_rowinserting in optionsgrid) and
        ((high(ar4) > 0) or (high(ar5) > 0)) then begin
    int5:= row;
//    if (col < 0) or (co_rowselect in datacols[col].options) then begin
//      acol:= 0;
//    end
//    else begin
//     acol:= col;
//    end;
    beginupdate;
    try
     datacols.clearselection;
     int1:= row;
     insertrow(row,length(ar4));
     for int2:= int1 to int1 + high(ar4) do begin
      datacols.selected[makegridcoord(invalidaxis,int2)]:= true;
     end;
//     int4:= datacols.count - acol -1;
     for int1:= 0 to high(ar4) do begin
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
  end
 end;
end;

procedure tcustomstringgrid.editnotification(var info: editnotificationinfoty);
var
 frame1: framety;
begin
 if focusedcellvalid then begin
  with tcustomstringcol(fdatacols[ffocusedcell.col]) do begin
   case info.action of
    ea_textedited: begin
     modified;
    end;
    ea_textentered: begin
     if (cos_edited in fstate) or 
           (scoe_forcereturncheckvalue in foptionsedit) then begin
      include(fstate,cos_edited);
      docheckcellvalue;
      if scoe_eatreturn in foptionsedit then begin
       info.action:= ea_none;
      end;
     end;
    end;
    ea_undo: begin
     exclude(fstate,cos_edited);
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
 if  isdatacell(ffocusedcell) and not (oe_readonly in feditor.optionsedit) then begin
  strcol:= datacols[ffocusedcell.col];
  if cos_edited in strcol.fstate then begin
   mstr1:= feditor.text;
   if canevent(tmethod(strcol.fonsetvalue)) then begin
    strcol.fonsetvalue(strcol,mstr1,accept);
   end;
   if accept then begin                
    items[ffocusedcell]:= mstr1;
    if canevent(tmethod(strcol.fondataentered)) then begin
     strcol.fondataentered(strcol);
    end;
   end;
   exclude(strcol.fstate,cos_edited);
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
 rect1:= cellrect(ffocusedcell,cil_inner);
 inherited;
 if focusedcellvalid then begin
  rect2:= cellrect(ffocusedcell,cil_inner);
  if (rect2.cx <> rect1.cx) or (rect2.cy <> rect1.cy) then begin
   feditor.updatepos(rect2,rect2);
  end
  else begin
   feditor.scroll(subpoint(rect2.pos,rect1.pos));
   feditor.updatecaret;
  end;
 end;
end;

function tcustomstringgrid.getoptionsedit: optionseditty;
begin
 result:= [oe_exitoncursor];
 with tstringcol(fdatacols[ffocusedcell.col]) do begin
  if (ffocusedcell.col < 0) or (co_readonly in foptions) then begin
   include(result,oe_readonly);
  end;
  stringcoltooptionsedit(foptionsedit,result);
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
  datarowheight:= font.glyphheight + 2;
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

{ trowfontarrayprop }

constructor trowfontarrayprop.create(const aowner: tcustomgrid);
begin
 fgrid:= aowner;
 inherited create(nil);
end;

procedure trowfontarrayprop.createitem(const index: integer; var item: tpersistent);
begin
 item:= tfont.create;
 item.Assign(stockobjects.fonts[stf_default]);
end;

{ trowstatelist }

constructor trowstatelist.create;
begin
 inherited;
 fsize:= sizeof(rowstatety);
end;

function trowstatelist.getitempo(const index: integer): prowstatety;
begin
 result:= prowstatety(inherited getitempo(index));
end;

function trowstatelist.getrowstate(const index: integer): rowstatety;
begin
 getdata(index,result);
end;

procedure trowstatelist.setrowstate(const index: integer;
  const Value: rowstatety);
begin
 setdata(index,value);
end;

initialization
 registerclass(tdrawgrid);
 registerclass(tstringgrid);
end.

