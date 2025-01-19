{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphics;
{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 classes,mclasses,msetypes,msestrings,mseerr,
 msegraphutils,mseguiglob,mseclasses,mseglob,msesys;

const

 linewidthshift = 16;
 linewidthroundvalue = $8000;
 fontsizeshift = 16;
 fontsizeroundvalue = $8000;
 defaultfontalias = 'stf_default';

 invalidgchandle = ptruint(-1);
 
type 
 childbounds = record  // for wo_transparentbackground     
  left: integer;
  top: integer;
  height: integer;
  width: integer;
 end; 
 
var
 mse_formchild : array of childbounds; // for wo_transparentbackground       

type
 gckindty = (gck_screen,gck_pixmap,gck_printer,gck_metafile);

 drawingflagty = (df_canvasispixmap,df_canvasismonochrome,df_highresfont,
                  df_doublebuffer,df_smooth,
                  df_colorconvert,
                  df_opaque,df_monochrome,df_brush,df_dashed,df_last = 31);
 drawingflagsty = set of drawingflagty;

 capstylety = (cs_butt,cs_round,cs_projecting);
 joinstylety = (js_miter,js_round,js_bevel);

 dashesstringty = string[8];

const
 fillmodeinfoflags = [df_opaque,df_monochrome,df_brush];
 da_dot = dashesstringty(#1#1);
 da_dash = dashesstringty(#3#3);
 da_dashdot = dashesstringty(#3#1#1#1);

type
                                       //fontalias option char:
 fontoptionty = (foo_fixed,            // 'p'
                 foo_proportional,     // 'P'
                 foo_helvetica,        // 'H'
                 foo_roman,            // 'R'
                 foo_script,           // 'S'
                 foo_decorative,       // 'D'
                 foo_antialiased,      // 'A'
                 foo_antialiased2,     // 'B' cleartype on windows
                 foo_nonantialiased    // 'a'
//                 foo_xcore,            // 'C'  //seems not to work with xft2
//                 foo_noxcore           // 'c'
                 );
 fontoptionsty = set of fontoptionty;

const
 fontpitchmask = [foo_fixed,foo_proportional];
 fontfamilymask = [foo_helvetica,foo_roman,foo_script,foo_decorative];
 fontantialiasedmask = [foo_antialiased,foo_antialiased2,foo_nonantialiased];
// fontxcoremask = [foo_xcore,foo_noxcore];
 fontaliasoptionchars : array[fontoptionty] of char =
                ('p','P','H','R','S','D','A','B','a'{,'C','c'});
type
 canvasstatety =
  (cs_regioncopy,cs_clipregion,cs_origin,cs_gc,
   cs_acolorbackground,cs_acolorforeground,cs_color,cs_colorbackground,
   cs_dashes,cs_linewidth,cs_capstyle,cs_joinstyle,cs_options,
   cs_fonthandle,cs_font,cs_fontcolor,cs_fontcolorbackground,cs_fonteffect,
   cs_rasterop,cs_brush,cs_brushorigin,
   cs_painted,cs_internaldrawtext,cs_highresdevice,
   cs_inactive,cs_pagestarted,cs_metafile{,cs_monochrome});
 canvasstatesty = set of canvasstatety;
const
 linecanvasstates = [cs_dashes,cs_linewidth,cs_capstyle,cs_joinstyle];

const
 fontstylehandlemask = 3; //[fs_bold,fs_italic]
 fontstylesmamask: fontstylesty =
           [fs_bold,fs_italic,fs_underline,fs_strikeout,fs_selected];

type
 pgdifunctionaty = ^gdifunctionaty;

 fontdatapty = array[0..15] of pointer;

 fonthashdty = record       //hashed by byteshash
  glyph: unicharty;
  gdifuncs: pgdifunctionaty;   //gdi framework
  height: integer;
  width: integer;
  style: fontstylesty;         //fs_bold,fs_italic
  pitchoptions,familyoptions,antialiasedoptions: fontoptionsty;
  rotation: real; //0..1 -> 0deg..360deg CCW
  xscale: real;   //default 1.0
 end;

 fonthashdataty = record
  d: fonthashdty;
  name: string;
  charset: string;
 end;

 fontdataty = record
  h: fonthashdataty;
  realfont: fonthashdataty;

  font: fontty;
  fonthighres: fontty;
  basefont: fontty;
  ascent,descent,linespacing,caretshift,linewidth,realheight: integer;
  platformdata: fontdatapty; //platform dependent
 end;
 pfontdataty = ^fontdataty;

 fontmetricsty = record
  leftbearing: integer; //left undersize, origin of left edge
  width: integer;       //character advance
  rightbearing: integer;//right undersize
  sum: integer;         //with - leftbearing - rightbearing, glyph width
 end;
 pfontmetricsty = ^fontmetricsty;



 rasteropty = (rop_clear,rop_and,rop_andnot,rop_copy,
                 rop_notand,rop_nop,rop_xor,rop_or,
                 rop_nor,rop_notxor,rop_not,rop_ornot,
                 rop_notcopy,rop_notor,rop_nand,rop_set);

 tfont = class;
 tsimplebitmap = class;
 fontchangedeventty = procedure(sender: tfont; changed: canvasstatesty) of object;

 fontstatety = (fsta_infovalid,fsta_none);
 fontstatesty = set of fontstatety;

 fontnumty = longword;

 tcanvas = class;

 fontaliasmodety = (
  fam_nooverwrite,    //do not change if allready registered
  fam_overwrite,      //do change if allready registered not fam_fix
  fam_fix,            //will never be changed
  fam_fixnooverwrite  //do not change if allready registered,
 );                   //fix existing

 basefontinfoty = record
  color: colorty;
  colorbackground: colorty;
  colorselect: colorty;
  colorselectbackground: colorty;
  shadow_color: colorty;
  shadow_shiftx: integer;
  shadow_shifty: integer;
  gloss_color: colorty;
  gloss_shiftx: integer;
  gloss_shifty: integer;
  grayed_color: colorty;
  grayed_colorshadow: colorty;
  grayed_shiftx: integer;
  grayed_shifty: integer;
  style: fontstylesty;
  xscale: real;   //default 1.0

  height: integer;
  width: integer;
  extraspace: integer;
  name: string;
  charset: string;
  options: fontoptionsty;
 end;

 fontlocalpropty = (
  flp_color,flp_colorbackground,flp_colorselect,flp_colorselectbackground,
  flp_shadow_color,flp_shadow_shiftx,flp_shadow_shifty,
  flp_gloss_color,flp_gloss_shiftx,flp_gloss_shifty,
  flp_grayed_color,flp_grayed_colorshadow,flp_grayed_shiftx,flp_grayed_shifty,
  flp_style,flp_xscale,flp_height,flp_width,flp_extraspace,flp_name,flp_charset,
  flp_options
 );
 fontlocalpropsty = set of fontlocalpropty;

 fontinfoty = record
  handles: array[0..fontstylehandlemask] of fontnumty;
  baseinfo: basefontinfoty;
  glyph: unicharty;
  gdifuncs: pgdifunctionaty;
  rotation: real; //0..2*pi -> 0deg..360deg CCW
 end;
 pfontinfoty = ^fontinfoty;

 bitmapkindty = (bmk_mono,bmk_gray,bmk_rgb);

 imagety = record
  kind: bitmapkindty;
  bgr: boolean;
  size: sizety;
  length: integer;     //number of longword
  linelength: integer; //number of longword in row
  linebytes: integer;  //number of bytes in row
  pixels: plongwordaty;
 end;
 pimagety = ^imagety;

 maskedimagety = record
  image: imagety;
  mask: imagety;
 end;

 icanvas = interface(inullinterface)
  procedure gcneeded(const sender: tcanvas);
  function getkind: bitmapkindty;
  function getsize: sizety;
  procedure getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
 end;

 canvasclassty = class of tcanvas;

 gcpty = array[0..63] of pointer;
 gcty = record
  handle: ptruint;//cardinal;
  refgc: ptruint;//cardinal; //for windowsmetafile
  gdifuncs: pgdifunctionaty;
  fontgdifuncs: pgdifunctionaty;
  drawingflags: drawingflagsty;
  kind: bitmapkindty;
  cliporigin: pointty;
  paintdevicesize: sizety;
  ppmm: real;
  platformdata: gcpty; //platform dependent
 end;
 pgcty = ^gcty;

 bufferty = record
  size: integer; //memory size
  buffer: pointer;
  cursize: integer; //used size
 end;

 pdrawinfoty = ^drawinfoty;
 rectinfoty = record         ///
  rect: prectty;              //
 end;                         // same layout!
 arcinfoty = record           //
  rect: prectty;             ///  //rect^.pos = center of ellipse
                                  //rect^.size = dimensions of ellipse
  startang: real;                 //in radiant CCW, 0 = horizontal to the right,
                                  //2*pi = full circle
  extentang: real;                //in radiant CCW, 2*pi = full circle
  pieslice: boolean;
 end;
 posinfoty = record          ///
  pos: ppointty;              //
 end;                         // same layout!
 textposinfoty = record       //
  pos: ppointty;             ///
  text: pchar;
  count: integer;
 end;
 text16posinfoty = record
  pos: ppointty;
  text: pmsechar;
  count: integer;
 end;
 pointsinfoty = record
  points: ppointty;
  count: integer;
  closed: boolean;
 end;
 colorinfoty = record
  color: colorty;
 end;
 getfontinfoty = record
  fontdata: pfontdataty;
  basefont: fontty;
  ok: boolean;
 end;
 gettext16widthinfoty = record
  text: pmsechar;
  count: integer;
  fontdata: pfontdataty;
  result: integer;
 end;
 getchar16widthsinfoty = record
  text: pmsechar;
  count: integer;
  fontdata: pfontdataty;
  resultpo: pinteger;
 end;
 getfontmetricsinfoty = record
  char: ucs4char;
  fontdata: pfontdataty;
  resultpo: pfontmetricsty;
 end;
 copyareainfoty = record
  source: tcanvas{pdrawinfoty};     //can be equal to self
  sourcerect: prectty;
  destrect: prectty;
  tileorigin: ppointty;
  alignment: alignmentsty;
  copymode: rasteropty;
  transparentcolor: pixelty;
  mask: tsimplebitmap;
  maskshiftscaled,maskshift: pointty;
  opacity: rgbtriplety;
 end;
 fonthasglyphinfoty = record
  font: fontty;
  unichar: unicharty;
  hasglyph: boolean;
 end;

 rectsty = array[0..bigint div sizeof(rectty)] of rectty;
 prectsty = ^rectsty;
 regionoperationinfoty = record
  source,dest: regionty;
  rect: rectty;
  rectspo:  prectsty;
  rectscount: integer;
 end;

 createpixmapinfoty = record
  size: sizety;
  kind: bitmapkindty;
  copyfrom: pixmapty;
  pixmap: pixmapty;
 end;

 pixmapimageinfoty = record
  pixmap: pixmapty;
  image: imagety;
  error: gdierrorty;
 end;

 creategcinfoty = record
  paintdevice: paintdevicety;
  kind: gckindty;
  printernamepo: pmsestring;
  contextinfopo: pointer;
  gcpo: pgcty;
  windowrect: prectty;
  parent: winidty;
  createpaintdevice: boolean;
  error: gdierrorty;
 end;

 getimageinfoty = record
  error: gdierrorty;
  image: maskedimagety;
 end;

 getcanvasclassinfoty = record
  canvasclass: canvasclassty;
  kind: bitmapkindty;//monochrome: boolean;
 end;

 moverectinfoty = record
  dist: ppointty;
  rect: prectty;
 end;

 gcvaluemaskty = (gvm_clipregion,gvm_colorbackground,gvm_colorforeground,
                  gvm_dashes,gvm_linewidth,gvm_capstyle,gvm_joinstyle,
                  gvm_options,
                  gvm_font,gvm_brush,gvm_brushorigin,gvm_rasterop,
                  gvm_brushflag);
 gcvaluemasksty = set of gcvaluemaskty;

 lineinfoty = record
  width: integer; //pixel shl linewidthshift
  dashes: dashesstringty;
  capstyle: capstylety;
  joinstyle: joinstylety;
//  options: lineoptionsty;
 end;

 canvasoptionty = (cao_smooth);
 canvasoptionsty = set of canvasoptionty;

 gcvaluesty = record
  mask: gcvaluemasksty;
  clipregion: regionty;
  colorbackground: pixelty;
  colorforeground: pixelty;
  font: fontty;
  fontnum: fontnumty;
  fontdata: pfontdataty;
  brush: tsimplebitmap;
  brushorigin: pointty;
  rasterop: rasteropty;
  lineinfo: lineinfoty;
  options: canvasoptionsty;
 end;
 pgcvaluesty = ^gcvaluesty;

 drawinfoty = record
  buffer: bufferty;
  gc: gcty;
  statestamp: longword;
//  gcident: longword;
  paintdevice: paintdevicety;
  origin: pointty;
  acolorbackground,acolorforeground: colorty;
  gcvalues: pgcvaluesty; //valid in gui_changegc
  case integer of
   0: (rect: rectinfoty);
   1: (arc: arcinfoty);
   2: (pos: posinfoty);
   3: (textpos: textposinfoty);
   4: (text16pos: text16posinfoty);
   5: (points: pointsinfoty);
   6: (color: colorinfoty);
   7: (getfont: getfontinfoty);
//   8: (gettextwidth: gettextwidthinfoty);
   9: (gettext16width: gettext16widthinfoty);
//  10: (getcharwidths: getcharwidthsinfoty);
  11: (getchar16widths: getchar16widthsinfoty);
  12: (getfontmetrics: getfontmetricsinfoty);
  13: (copyarea: copyareainfoty);
  14: (regionoperation: regionoperationinfoty);
  15: (fonthasglyph: fonthasglyphinfoty);
  16: (creategc: creategcinfoty);
  17: (getimage: getimageinfoty);
  18: (getcanvasclass: getcanvasclassinfoty);
  19: (createpixmap: createpixmapinfoty);
  20: (pixmapimage: pixmapimageinfoty);
  21: (moverect: moverectinfoty)
 end;

 tfonttemplate = class(tpersistenttemplate)
  private
   procedure setcolor(const avalue: colorty);
   procedure setcolorbackground(const avalue: colorty);
   procedure setcolorselect(const avalue: colorty);
   procedure setcolorselectbackground(const avalue: colorty);
   procedure setshadow_color(const avalue: colorty);
   procedure setshadow_shiftx(const avalue: integer);
   procedure setshadow_shifty(const avalue: integer);
   procedure setgloss_color(const avalue: colorty);
   procedure setgloss_shiftx(const avalue: integer);
   procedure setgloss_shifty(const avalue: integer);
   procedure setgrayed_color(const avalue: colorty);
   procedure setgrayed_colorshadow(const avalue: colorty);
   procedure setgrayed_shiftx(const avalue: integer);
   procedure setgrayed_shifty(const avalue: integer);
   procedure setstyle(const avalue: fontstylesty);
   procedure setxscale(const avalue: real);
   procedure setheight(const avalue: integer);
   procedure setwidth(const avalue: integer);
   procedure setextraspace(const avalue: integer);
   procedure setname(const avalue: string);
   procedure setcharset(const avalue: string);
   procedure setoptions(const avalue: fontoptionsty);
  protected
   fi: basefontinfoty;
   procedure doassignto(dest: tpersistent); override;
   function getinfosize: integer; override;
   function getinfoad: pointer; override;
  public
   constructor create(const owner: tmsecomponent;
                  const onchange: notifyeventty); override;
  published
   property color: colorty read fi.color write setcolor default cl_default;
                                                              //cl_text
   property colorbackground: colorty read fi.colorbackground
                 write setcolorbackground default cl_default; //cl_transparent
   property colorselect: colorty read fi.colorselect
             write setcolorselect default cl_default;  //cl_selectedtext
   property colorselectbackground: colorty read fi.colorselectbackground
             write setcolorselectbackground default cl_default;
                                               //cl_selectedtextbackground

   property shadow_color: colorty read fi.shadow_color
                 write setshadow_color default cl_none;
   property shadow_shiftx: integer read fi.shadow_shiftx write
                setshadow_shiftx default 1;
   property shadow_shifty: integer read fi.shadow_shifty write
                setshadow_shifty default 1;

   property gloss_color: colorty read fi.gloss_color
                 write setgloss_color default cl_none;
   property gloss_shiftx: integer read fi.gloss_shiftx write
                setgloss_shiftx default -1;
   property gloss_shifty: integer read fi.gloss_shifty write
                setgloss_shifty default -1;

   property grayed_color: colorty read fi.grayed_color
                 write setgrayed_color default cl_default; //cl_grayed
   property grayed_colorshadow: colorty read fi.grayed_colorshadow
                 write setgrayed_colorshadow default cl_default;
                                                           //cl_grayedshadow;
   property grayed_shiftx: integer read fi.grayed_shiftx write
                setgrayed_shiftx default 1;
   property grayed_shifty: integer read fi.grayed_shifty write
                setgrayed_shifty default 1;

   property height: integer read fi.height write setheight default 0;
                  //pixel
   property width: integer read fi.width write setwidth default 0;
                  //avg. character width in 1/10 pixel, 0 = default
   property extraspace: integer read fi.extraspace write setextraspace
                                                                 default 0;
   property style: fontstylesty read fi.style write setstyle default [];
   property name: string read fi.name write setname;
   property charset: string read fi.charset write setcharset;
   property options: fontoptionsty read fi.options write setoptions default [];
   property xscale: real read fi.xscale write setxscale;
                                 //default 1.0

 end;

 tfontcomp = class(ttemplatecontainer)
  private
   function gettemplate: tfonttemplate;
   procedure settemplate(const avalue: tfonttemplate);
  protected
   function gettemplateclass: templateclassty; override;
  public
  published
   property template: tfonttemplate read gettemplate write settemplate;
 end;

 getfontfuncty = function (var drawinfo: drawinfoty): boolean of object;

 tfont = class(tlinkedoptionalpersistent,icanvas)
  private
   finfopo: pfontinfoty;
   fonchange: notifyeventty;
   flocalprops: fontlocalpropsty;
   ftemplate: tfontcomp;
   function getextraspace: integer;
   procedure setextraspace(const avalue: integer);
   procedure setcolorbackground(const Value: colorty);
   function getcolorbackground: colorty;
   procedure setcolorselectbackground(const Value: colorty);
   function getcolorselectbackground: colorty;

   procedure setshadow_color(avalue: colorty);
   function getshadow_color: colorty;
   procedure setshadow_shiftx(const avalue: integer);
   function getshadow_shiftx: integer;
   procedure setshadow_shifty(const avalue: integer);
   function getshadow_shifty: integer;

   procedure setgloss_color(avalue: colorty);
   function getgloss_color: colorty;
   procedure setgloss_shiftx(const avalue: integer);
   function getgloss_shiftx: integer;
   procedure setgloss_shifty(const avalue: integer);
   function getgloss_shifty: integer;

   procedure setcolor(const Value: colorty);
   function getcolor: colorty;
   procedure setcolorselect(const Value: colorty);
   function getcolorselect: colorty;
   procedure setheight(avalue: integer);
   procedure setheightflo(avalue: flo64);
   function getheight: integer;
   function getheightflo: flo64;
   function getwidth: integer;
   procedure setwidth(avalue: integer);
   procedure setstyle(const Value: fontstylesty);
   function getstyle: fontstylesty;
   function getascent: integer;
   function getdescent: integer;
   function getglyphheight: integer;
   function getlineheight: integer;
   function getcaretshift: integer;
   procedure updatehandlepo;
   procedure releasehandles(const nochanged: boolean = false);
   function getcharset: string;
   function getname: string;
   procedure setcharset(const Value: string);
   function getoptions: fontoptionsty;
   procedure setoptions(const avalue: fontoptionsty);
   function getbold: boolean;
   procedure setbold(const avalue: boolean);
   function getitalic: boolean;
   procedure setitalic(const avalue: boolean);
   function getunderline: boolean;
   procedure setunderline(const avalue: boolean);
   function getstrikeout: boolean;
   procedure setstrikeout(const avalue: boolean);
   procedure createhandle(const canvas: tcanvas);
   function getrotation: real;
   procedure setrotation(const avalue: real);
   function getxscale: real;
   procedure setxscale(const avalue: real);

   procedure readcolorshadow(reader: treader);
   function getlinewidth: integer;

    //icanvas
   procedure gcneeded(const sender: tcanvas);
//   function getmonochrome: boolean;
   function getkind: bitmapkindty;
   function getsize: sizety;
   procedure getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
   function getgrayed_color: colorty;
   procedure setgrayed_color(const avalue: colorty);
   function getgrayed_colorshadow: colorty;
   procedure setgrayed_colorshadow(const avalue: colorty);
   function getgrayed_shiftx: integer;
   procedure setgrayed_shiftx(const avalue: integer);
   function getgrayed_shifty: integer;
   procedure setgrayed_shifty(const avalue: integer);
   procedure settemplate(const avalue: tfontcomp);
   function iscolorstored(): boolean;
   function iscolorbackgroundstored(): boolean;
   function iscolorselectstored(): boolean;
   function iscolorselectbackgroundstored(): boolean;
   function isshadow_colorstored(): boolean;
   function isshadow_shiftxstored(): boolean;
   function isshadow_shiftystored(): boolean;
   function isgloss_colorstored(): boolean;
   function isgloss_shiftxstored(): boolean;
   function isgloss_shiftystored(): boolean;
   function isgrayed_colorstored(): boolean;
   function isgrayed_colorshadowstored(): boolean;
   function isgrayed_shiftxstored(): boolean;
   function isgrayed_shiftystored(): boolean;
   function isxscalestored(): boolean;
   function isstylestored(): boolean;
   procedure readdummy(reader: treader);
   procedure setlocalprops(const avalue: fontlocalpropsty);
  protected
   finfo: fontinfoty;
   fhandlepo: ^fontnumty;
   procedure dochanged(const changed: canvasstatesty;
                                    const nochange: boolean); virtual;
   function getfont(var drawinfo: drawinfoty): boolean; virtual;
   procedure setname(const Value: string); virtual;
   function gethandle: fontnumty; virtual;
   function getdatapo: pfontdataty;
   procedure assignproperties(const source: tfont;
                                      const ahandles: boolean); virtual;
   property rotation: real read getrotation write setrotation;
                                 //0..2*pi-> 0degree..360degree CCW
   procedure defineproperties(filer: tfiler); override;
   procedure settemplateinfo(const ainfo: basefontinfoty);
   procedure objectevent(const sender: tobject;
                        const event: objecteventty); override;
   function isheightstored(): boolean;
   function iswidthstored(): boolean;
   function isextraspacestored(): boolean;
   function isnamestored(): boolean;
   function ischarsetstored(): boolean;
   function isoptionsstored(): boolean;
  public
   constructor create; override;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
   procedure scale(const ascale: real); virtual;

   function gethandleforcanvas(const canvas: tcanvas): fontnumty;
   property handle: fontnumty read gethandle;
   property ascent: integer read getascent;
   property descent: integer read getdescent;
   property glyphheight: integer read getglyphheight; //ascent + descent
   property lineheight: integer read getlineheight;
   property linewidth: integer read getlinewidth;
   property caretshift: integer read getcaretshift;
   property onchange: notifyeventty read fonchange write fonchange;

   property bold: boolean read getbold write setbold;
   property italic: boolean read getitalic write setitalic;
   property underline: boolean read getunderline write setunderline;
   property strikeout: boolean read getstrikeout write setstrikeout;
   property heightflo: flo64 read getheightflo write setheightflo;
                  //pixel, 0 = default

  published
   property color: colorty read getcolor write setcolor
                  stored iscolorstored default cl_default;    //cl_text
   property colorbackground: colorty read getcolorbackground
                 write setcolorbackground stored iscolorbackgroundstored
                                          default cl_default; //cl_transparent
   property colorselect: colorty read getcolorselect write setcolorselect
             stored iscolorselectstored default cl_default;    //cl_selectedtext
   property colorselectbackground: colorty read getcolorselectbackground
        write setcolorselectbackground stored iscolorselectbackgroundstored
                               default cl_default; //cl_selectedtextbackground
   property shadow_color: colorty read getshadow_color write setshadow_color
                                    stored isshadow_colorstored default cl_none;
   property shadow_shiftx: integer read getshadow_shiftx write setshadow_shiftx
                                         stored isshadow_shiftxstored default 1;
   property shadow_shifty: integer read getshadow_shifty write setshadow_shifty
                                         stored isshadow_shiftystored default 1;

   property gloss_color: colorty read getgloss_color
                 write setgloss_color
                  stored isgloss_colorstored default cl_none;
   property gloss_shiftx: integer read getgloss_shiftx write setgloss_shiftx
                  stored isgloss_shiftxstored default -1;
   property gloss_shifty: integer read getgloss_shifty write setgloss_shifty
                  stored isgloss_shiftystored default -1;

   property grayed_color: colorty read getgrayed_color
                 write setgrayed_color
                  stored isgrayed_colorstored default cl_default;//cl_grayed
   property grayed_colorshadow: colorty read getgrayed_colorshadow
                 write setgrayed_colorshadow
                  stored isgrayed_colorshadowstored default cl_default;
                                                             //cl_grayedshadow
   property grayed_shiftx: integer read getgrayed_shiftx write
                setgrayed_shiftx
                  stored isgrayed_shiftxstored default 1;
   property grayed_shifty: integer read getgrayed_shifty write
                setgrayed_shifty
                  stored isgrayed_shiftystored default 1;

   property height: integer read getheight write setheight
                                      stored isheightstored default 0;
                  //pixel, 0 = default
   property width: integer read getwidth write setwidth
                                      stored iswidthstored default 0;
                  //avg. character width in 1/10 pixel, 0 = default
   property extraspace: integer read getextraspace write setextraspace
                                     stored isextraspacestored default 0;
   property style: fontstylesty read getstyle write setstyle
                              stored isstylestored default [];
   property name: string read getname write setname stored isnamestored;
   property charset: string read getcharset write setcharset
                                                    stored ischarsetstored;
   property options: fontoptionsty read getoptions write setoptions
                                           stored isoptionsstored default [];
   property xscale: real read getxscale write setxscale stored isxscalestored;
                                 //default 1.0

   property localprops: fontlocalpropsty read flocalprops write setlocalprops;
                //before template!
                //No default, is optional object streaming placeholder
   property template: tfontcomp read ftemplate write settemplate;
 end;
 pfont = ^tfont;
 fontarty = array of tfont;

 toptionalfont = class(tfont)
 end;

 tparentfont = class(tfont)
  public
   class function getinstancepo(owner: tobject): pfont; virtual; abstract;
 end;
 parentfontclassty = class of tparentfont;

 tcanvasfont = class(tfont)
  private
  protected
   fcanvas: tcanvas;
   fgdifuncs: pgdifunctionaty;
   procedure dochanged(const changed: canvasstatesty;
                              const nochange: boolean); override;
   function gethandle: fontnumty; override;
   procedure assignproperties(const source: tfont;
                                      const ahandles: boolean); override;
  public
   constructor create(const acanvas: tcanvas); reintroduce;
 end;

 gdifunctionty = procedure(var drawinfo: drawinfoty);

 gdifuncty = (gdf_creategc,gdf_destroygc,gdf_changegc,gdf_createpixmap,
              gdf_pixmaptoimage,gdf_imagetopixmap,
              gdf_getcanvasclass,gdf_endpaint,gdf_flush,gdf_movewindowrect,
              gdf_drawlines,gdf_drawlinesegments,gdf_drawellipse,gdf_drawarc,
              gdf_fillrect,
              gdf_fillellipse,gdf_fillarc,gdf_fillpolygon,{gdf_drawstring,}
              gdf_drawstring16,
              gdf_setcliporigin,
              gdf_createemptyregion,gdf_createrectregion,gdf_createrectsregion,
              gdf_destroyregion,gdf_copyregion,gdf_moveregion,
              gdf_regionisempty,gdf_regionclipbox,
              gdf_regsubrect,gdf_regsubregion,
              gdf_regaddrect,gdf_regaddregion,gdf_regintersectrect,
              gdf_regintersectregion,
              gdf_copyarea,gdf_getimage,
              gdf_fonthasglyph,
              gdf_getfont,gdf_getfonthighres,gdf_freefontdata,
              gdf_gettext16width,gdf_getchar16widths,gdf_getfontmetrics
             );

 gdifunctionaty = array[gdifuncty] of gdifunctionty;
// pgdifunctionaty = ^gdifunctionaty;

 canvasvaluesty = record
  changed: canvasstatesty;
  origin: pointty;
  brushorigin: pointty;
  clipregion: regionty;
  color: colorty;
  rasterop: rasteropty;
  colorbackground: colorty;
  font: fontinfoty;
  brush: tsimplebitmap;
  lineinfo: lineinfoty;
  options: canvasoptionsty;
 end;

 canvasvaluespoty = ^canvasvaluesty;
 canvasvaluesarty = array of canvasvaluesty;

 canvasvaluestackty = record
  count: integer;
  stack: canvasvaluesarty;
 end;

 edgecolorinfoty = record
  color,effectcolor: colorty;
  effectwidth: integer;
 end;
 edgecolorpairinfoty = record
  light,shadow: edgecolorinfoty;
 end;
 framecolorinfoty = record
  edges: edgecolorpairinfoty;
  frame: colorty;
  hiddenedges: edgesty;
 end;

 edgeinfoty = (kin_dark,kin_reverseend,kin_reversestart);
 edgeinfosty = set of edgeinfoty;

 gdiintffuncty = procedure (func: gdifuncty; var drawinfo: drawinfoty);
 canvasarty = array of tcanvas;

 tcanvas = class(tpersistent)
  private
   fvaluestack: canvasvaluestackty;
   gccolorbackground,gccolorforeground: colorty;
   gcoptions: canvasoptionsty;
   fdefaultfont: fontnumty;
   fcliporigin: pointty;
   fgclinksto: canvasarty;
   fgclinksfrom: canvasarty;
   procedure adjustrectar(po: prectty; count: integer);
   procedure readjustrectar(po: prectty; count: integer);
   procedure error(nr: gdierrorty; const text: msestring);
   procedure intparametererror(value: integer; const text: msestring);
   procedure freevalues(var values: canvasvaluesty);

   function getcolor: colorty;
   procedure setcolor(const value: colorty);
   procedure setclipregion(const Value: regionty);
   function getorigin: pointty;
   procedure setorigin(const Value: pointty);


   function checkforeground(acolor: colorty; lineinfo: boolean): boolean;
   procedure checkcolors;
   procedure setfont(const Value: tfont);
   procedure updatefontinfo;
   function getbrush: tsimplebitmap;
   procedure setbrush(const Value: tsimplebitmap);
   function getbrushorigin: pointty;
   procedure setbrushorigin(const Value: pointty);
   function getrootbrushorigin: pointty;
   procedure setrootbrushorigin(const Value: pointty);
   function getcolorbackground: colorty;
   procedure setcolorbackground(const Value: colorty);
   function getrasterop: rasteropty;
   procedure setrasterop(const Value: rasteropty);
   function getdashes: dashesstringty;
   procedure setdashes(const Value: dashesstringty);
   function getlinewidth: integer;
   procedure setlinewidth(Value: integer);
   function getcapstyle: capstylety;
   function getjoinstyle: joinstylety;
   function getoptions: canvasoptionsty; inline;
   procedure setcapstyle(const Value: capstylety);
   procedure setjoinstyle(const Value: joinstylety);
   procedure setoptions(const avalue: canvasoptionsty);
   procedure initregrect(const adest: regionty; const arect: rectty);
   procedure initregreg(const adest: regionty; const asource: regionty);
   procedure updatecliporigin(const Value: pointty);
   function getlinewidthmm: real;
   procedure setlinewidthmm(const avalue: real);
   function getkind: bitmapkindty;
//   function getmonochrome: boolean;
   procedure readlineoptions(reader: treader);
   function getsmooth: boolean;
   procedure setsmooth(const avalue: boolean);
  protected
   fuser: tobject;
   fintf: pointer; //icanvas;
   fstate: canvasstatesty;
   fvaluepo: canvasvaluespoty;
   fdrawinfo: drawinfoty;
   gcfonthandle1: fontnumty;
   afonthandle1: fontnumty;
   ffont: tfont;

   function getgdifuncs: pgdifunctionaty; virtual;
   procedure registergclink(const dest: tcanvas);
   procedure unregistergclink(const dest: tcanvas);
   procedure gcdestroyed(const sender: tcanvas); virtual;

   procedure setppmm(avalue: real); virtual;
   function getfitrect: rectty; virtual;
   procedure valuechanged(value: canvasstatety); inline;
   procedure valueschanged(values: canvasstatesty); inline;
   procedure initgcvalues; virtual;
   procedure initgcstate; virtual;
   procedure finalizegcstate; virtual;
   procedure checkrect(const rect: rectty);
   procedure checkgcstate(state: canvasstatesty); virtual;
   procedure checkregionstate;  //copies region if necessary
   function defaultcliprect: rectty; virtual;
   function lock: boolean; virtual;
   procedure unlock; virtual;
   procedure doflush;
   procedure gdi(const func: gdifuncty); virtual;
   procedure init;
   procedure beforeread;
   procedure afterread;
   procedure internalcopyarea(asource: tcanvas; const asourcerect: rectty;
              const adestrect: rectty; acopymode: rasteropty;
              atransparentcolor: colorty;
              amask: tsimplebitmap; const amaskpos: pointty;
              aalignment: alignmentsty;
              //only al_stretchx, al_stretchy and al_tiled used
              const atileorigin: pointty;
              const aopacity: colorty); //cl_none -> opaque);

   procedure setcliporigin(const Value: pointty);
               //value not saved!
   function getgchandle: ptruint;
   function getcanvasimage(const abgr: boolean = false): imagety;
   function getimage(const bgr: boolean): maskedimagety;

   procedure fillarc(const def: rectty; const startang,extentang: real;
                              const acolor: colorty; const pieslice: boolean);
   procedure getarcinfo(out startpo,endpo: pointty);
   procedure internaldrawtext(var info); virtual;
                       //info = drawtextinfoty
   function createfont: tcanvasfont; virtual;
   procedure drawfontline(const startpoint,endpoint: pointty);
                           //draws line with font color
   procedure nextpage; virtual; //used by tcustomprintercanvas
   function getcontextinfopo: pointer; virtual;
   procedure updatesize(const asize: sizety); virtual;
   procedure movewindowrect(const adist: pointty; const arect: rectty);
   procedure defineproperties(filer: tfiler); override;
  public
   target: tobject;     //currently assigned widget in twidget.paint()
   drawinfopo: pointer; //used to transport additional drawing information
   constructor create(const user: tobject; const intf: icanvas); virtual;
   destructor destroy; override;
   class function getclassgdifuncs: pgdifunctionaty; virtual;

   procedure updatewindowoptions(var aoptions: internalwindowoptionsty); virtual;
   function creategc(const apaintdevice: paintdevicety; const akind: gckindty;
                var gc: gcty; const aprintername: msestring = ''): gdierrorty;
   procedure linktopaintdevice(apaintdevice: paintdevicety; const gc: gcty;
                                           const cliporigin: pointty); virtual;
         //calls reset, resets cliporigin, canvas owns the gc!
   procedure fitppmm(const asize: sizety);
                     //for printercanvas
   function size: sizety;

   function highresdevice: boolean;
   procedure initflags(const dest: tcanvas); virtual;
   procedure unlink; //frees gc
   procedure initdrawinfo(var adrawinfo: drawinfoty);
   function active: boolean;

   procedure reset; virtual;//clears savestack, origin and clipregion
   function save: integer; //returns current saveindex
   function restore(index: integer = -1): integer; //-1 -> pop from stack
                     //returns current saveindex
   procedure resetpaintedflag;
   procedure endpaint; //opengl swap buffer

   procedure move(const dist: pointty);   //add dist to origin
   procedure remove(const dist: pointty); //sub dist from origin

   procedure copyarea(const asource: tcanvas; const asourcerect: rectty;
              const adestpoint: pointty; const acopymode: rasteropty = rop_copy;
              const atransparentcolor: colorty = cl_default;
              //atransparentcolor used for convert color to monochrome
              //cl_default -> colorbackground
              const aopacity: colorty = cl_none); overload;
   procedure copyarea(const asource: tcanvas; const asourcerect: rectty;
              const adestrect: rectty; const alignment: alignmentsty = [];
              const acopymode: rasteropty = rop_copy;
              const atransparentcolor: colorty = cl_default;
              //atransparentcolor used for convert color to monochrome
              //cl_default -> colorbackground
              const aopacity: colorty = cl_none); overload;

   procedure drawpoint(const point: pointty; const acolor: colorty = cl_default);
   procedure drawpoints(const apoints: array of pointty;
                          const acolor: colorty = cl_default;
                          first: integer = 0; acount: integer = -1); //-1 -> all

   procedure drawline(const startpoint,endpoint: pointty;
                                        const acolor: colorty = cl_default);
   procedure drawline(const startpoint: pointty; const length: sizety;
                                        const acolor: colorty = cl_default);
   procedure drawlinesegments(const apoints: array of segmentty;
                         const acolor: colorty = cl_default);

   procedure drawlines(const apoints: array of pointty;
                       const aclosed: boolean = false;
                       const acolor: colorty = cl_default;
              const first: integer = 0; const acount: integer = -1); overload;
                               //-1 = all
   procedure drawlines(const apoints: array of pointty;
                       const abreaks: array of integer; //ascending order
                       const aclosed: boolean = false;
                       const acolor: colorty = cl_default;
              const first: integer = 0; const acount: integer = -1); overload;

   procedure drawvect(const startpoint: pointty;
                   const direction: graphicdirectionty;
                   const length: integer; const acolor: colorty = cl_default);
                                                           overload;
   procedure drawvect(const startpoint: pointty;
                      const direction: graphicdirectionty;
                      const length: integer; out endpoint: pointty;
                      const acolor: colorty = cl_default); overload;

   procedure drawrect(const arect: rectty; const acolor: colorty = cl_default);
   procedure drawcross(const arect: rectty; const acolor: colorty = cl_default;
                   const alignment: alignmentsty = [al_xcentered,al_ycentered]);

   procedure drawellipse(const def: rectty; const acolor: colorty = cl_default);
                             //def.pos = center, def.cx = width, def.cy = height
   procedure drawellipse1(const def: rectty; const acolor: colorty = cl_default);
                             //def.pos = topleft
   procedure drawcircle(const center: pointty; const radius: integer;
                                               const acolor: colorty = cl_default);
   procedure drawarc(const def: rectty; const startang,extentang: real;
                              const acolor: colorty = cl_default); overload;
                             //def.pos = center, def.cx = width, def.cy = height
                             //startang,extentang in radiant (2*pi = 360deg CCW)
   procedure drawarc1(const def: rectty; const startang,extentang: real;
                              const acolor: colorty = cl_default);
                             //def.pos = topleft
   procedure drawarc(const center: pointty; const radius: integer;
                              const startang,extentang: real;
                              const acolor: colorty = cl_default); overload;

   procedure fillrect(const arect: rectty; const acolor: colorty = cl_default;
                      const linecolor: colorty = cl_none);
   procedure fillellipse(const def: rectty; const acolor: colorty = cl_default;
                        const linecolor: colorty = cl_none);
                             //def.pos = center, def.cx = width, def.cy = height
   procedure fillellipse1(const def: rectty; const acolor: colorty = cl_default;
                        const linecolor: colorty = cl_none);
                             //def.pos = topleft
   procedure fillcircle(const center: pointty; const radius: integer;
                        const acolor: colorty = cl_default;
                        const linecolor: colorty = cl_none);
   procedure fillarcchord(const def: rectty; const startang,extentang: real;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none); overload;
                             //def.pos = center, def.cx = width, def.cy = height
                             //startang,extentang in radiant (2*pi = 360deg CCW)
   procedure fillarcchord1(const def: rectty; const startang,extentang: real;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none);
                             //def.pos = topleft
   procedure fillarcchord(const center: pointty; const radius: integer;
                              const startang,extentang: real;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none); overload;
   procedure fillarcpieslice(const def: rectty; const startang,extentang: real;
                            const acolor: colorty = cl_default;
                            const linecolor: colorty = cl_none); overload;
                             //def.pos = center, def.cx = width, def.cy = height
                             //startang,extentang in radiant (2*pi = 360deg CCW)
   procedure fillarcpieslice1(const def: rectty; const startang,extentang: real;
                            const acolor: colorty = cl_default;
                            const linecolor: colorty = cl_none); overload;
                             //def.pos = topleft
   procedure fillarcpieslice(const center: pointty; const radius: integer;
                            const startang,extentang: real;
                            const acolor: colorty = cl_default;
                            const linecolor: colorty = cl_none); overload;
   procedure fillpolygon(const apoints: array of pointty;
                         const acolor: colorty = cl_default;
                         const linecolor: colorty = cl_none);

   procedure drawframe(const arect: rectty; awidth: integer = -1;
                   const acolor: colorty = cl_default;
                   const hiddenedges: edgesty = []); overload;
                    //no dashes, awidth < 0 -> inside frame,!
   procedure drawframe(const arect: rectty; awidth: framety;
                   const acolor: colorty = cl_default;
                   const hiddenedges: edgesty = []); overload;
   procedure drawxorframe(const arect: rectty; const awidth: integer = -1;
                           const abrush: tsimplebitmap = nil); overload;
   procedure drawxorframe(const po1: pointty; const po2: pointty;
                           const awidth: integer = -1;
                                 const abrush: tsimplebitmap = nil); overload;
   procedure fillxorrect(const arect: rectty;
                        const abrush: tsimplebitmap = nil); overload;
   procedure fillxorrect(const start: pointty; const length: integer;
                      const direction: graphicdirectionty;
                      const awidth: integer = 0;
                      const abrush: tsimplebitmap = nil); overload;
   procedure drawstring(const atext: msestring; const apos: pointty;
                        const afont: tfont = nil; const grayed: boolean = false;
                        const arotation: real = 0); overload;
                         //0..2*pi-> 0degree..360degree CCW
   procedure drawstring(const atext: pmsechar; const acount: integer; const apos: pointty;
                        const afont: tfont = nil; const grayed: boolean = false;
                        const arotation: real = 0); overload;
   function getstringwidth(const atext: msestring;
                                 const afont: tfont = nil): integer; overload;
   function getstringwidth(const atext: pmsechar; const acount: integer;
                                 const afont: tfont = nil): integer; overload;
                  //sum of cellwidths
   function getfontmetrics(const achar: ucs4char;
                                     const afont: tfont = nil): fontmetricsty;
   function getfontmetrics(const achar: msechar;
                                     const afont: tfont = nil): fontmetricsty;

                   //all boundaries of regionrects are clipped to
                   // -$8000..$7fff in device space
   procedure resetclipregion;
   procedure setcliprect(const rect: rectty);
   procedure addcliprect(const rect: rectty);
   procedure addclipframe(const frame: rectty; inflate: integer);
   procedure subcliprect(const rect: rectty);
   procedure subclipframe(const frame: rectty; inflate: integer);
   procedure intersectcliprect(const rect: rectty);
   procedure intersectclipframe(const frame: rectty; inflate: integer);

   procedure addclipregion(const region: regionty);
   procedure subclipregion(const region: regionty);
   procedure intersectclipregion(const region: regionty);

   function copyclipregion: regionty;
                  //returns a copy of the current clipregion

   function clipregionisempty: boolean; //true if no drawing possible
   function clipbox: rectty; //smallest possible rect around clipregion

   function createregion: regionty; overload;
   function createregion(const asource: regionty): regionty; overload;
   function createregion(const arect: rectty): regionty; overload;
   function createregion(const rects: array of rectty): regionty; overload;
   function createregion(frame: rectty; const inflate: integer): regionty; overload;
   procedure destroyregion(region: regionty);

   procedure regmove(const adest: regionty; const dist: pointty);
   procedure regremove(const adest: regionty; const dist: pointty);
   procedure regaddrect(const dest: regionty; const rect: rectty);
   procedure regsubrect(const dest: regionty; const rect: rectty);
   procedure regintersectrect(const dest: regionty; const rect: rectty);
   procedure regaddregion(const dest: regionty; const region: regionty);
   procedure regsubregion(const dest: regionty; const region: regionty);
   procedure regintersectregion(const dest: regionty; const region: regionty);

   function regionisempty(const region: regionty): boolean;
   function regionclipbox(const region: regionty): rectty;
                 //returns nullrect if region = 0

   property origin: pointty read getorigin write setorigin;
   property clipregion: regionty {read getclipregion} write setclipregion;
                  //canvas owns the region!

//   property monochrome: boolean read getmonochrome;
   property kind: bitmapkindty read getkind;
   property color: colorty read getcolor write setcolor default cl_black;
   property colorbackground: colorty read getcolorbackground
              write setcolorbackground default cl_transparent;
   property rasterop: rasteropty read getrasterop write setrasterop default rop_copy;
   property font: tfont read ffont write setfont;
   property brush: tsimplebitmap read getbrush write setbrush;
   property brushorigin: pointty read getbrushorigin write setbrushorigin;
   property rootbrushorigin: pointty read getrootbrushorigin write setrootbrushorigin;
                   //origin = paintdevice top left
   procedure adjustbrushorigin(const arect: rectty;
                                               const alignment: alignmentsty);

   property linewidth: integer read getlinewidth write setlinewidth default 0;
   property linewidthmm: real read getlinewidthmm write setlinewidthmm;

   property dashes: dashesstringty read getdashes write setdashes;
     //todo: dashoffset
   property capstyle: capstylety read getcapstyle write setcapstyle
                default cs_butt;
   property joinstyle: joinstylety read getjoinstyle write setjoinstyle
                default js_miter;
   property smooth: boolean read getsmooth write setsmooth;
   property options: canvasoptionsty read getoptions write setoptions
                default [];

   property paintdevice: paintdevicety read fdrawinfo.paintdevice;
   property gchandle: ptruint read getgchandle;
   property ppmm: real read fdrawinfo.gc.ppmm write setppmm;
                   //used for linewidth mm, value not saved/restored
   property statestamp: longword read fdrawinfo.statestamp;
                 //incremented by drawing operations
 end;

 pixmapstatety = ({pms_monochrome,}pms_ownshandle,pms_maskvalid,pms_nosave,
                  pms_staticcanvas);
 pixmapstatesty = set of pixmapstatety;

 pixmapinfoty = record
  handle: pixmapty;
  size: sizety;
  depth: integer;
 end;

 tsimplebitmap = class(tnullinterfacedpersistent,icanvas)
  private
   function gethandle: pixmapty;
   procedure sethandle(const Value: pixmapty);
   function getcanvas: tcanvas;
   procedure switchtomonochrome;
   procedure setwidth(const avalue: integer);
   procedure setheight(const avalue: integer);
   {
   function getgrayscale: boolean;
   procedure setgrayscale(const avalue: boolean);
   function getmonochrome: boolean;
   procedure setmonochrome(const avalue: boolean);
   }
  protected
   fgdifuncs: pgdifunctionaty;
   fcanvasclass: canvasclassty;
   fcanvas: tcanvas;
   fhandle: pixmapty;
   fsize: sizety;
   fscanlinestep: integer; //bytes
   fscanlinewords: integer;
   fscanhigh: integer;
   fkind: bitmapkindty;
   fstate: pixmapstatesty;
   fcolorbackground: colorty;
   fcolorforeground: colorty;
   fdefaultcliporigin: pointty;
   procedure updatescanline();
   function createcanvas: tcanvas; virtual;
   procedure creategc;
   procedure internaldestroyhandle;
   procedure destroyhandle; virtual;
   procedure createhandle(acopyfrom: pixmapty); virtual;
   procedure setkind(const avalue: bitmapkindty); virtual;
   function getconverttomonochromecolorbackground: colorty; virtual;
   function getmask(out apos: pointty): tsimplebitmap; virtual;
   procedure setsize(const avalue: sizety); virtual;
   function normalizeinitcolor(const acolor: colorty): colorty;
   procedure assign1(const source: tsimplebitmap; const docopy: boolean); virtual;
   function getgdiintf: pgdifunctionaty;
    //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getsize: sizety;
   function getkind: bitmapkindty;
   procedure getcanvasimage(const bgr: boolean;
                                    var aimage: maskedimagety); virtual;
  public
   constructor create(const akind: bitmapkindty;
                    const agdifuncs: pgdifunctionaty = nil); reintroduce;
                                  //nil -> default
   destructor destroy; override;

   procedure copyhandle;
   procedure releasehandle; virtual;
   procedure acquirehandle; virtual;
   property handle: pixmapty read gethandle write sethandle;

   procedure assign(source: tpersistent); override;
   procedure assignnegative(source: tsimplebitmap);
                      //gets negative copy
   procedure clear; virtual;//sets with and height to 0
   procedure init(const acolor: colorty); virtual;
   procedure freecanvas;
   function canvasallocated: boolean;
   procedure copyarea(const asource: tsimplebitmap; const asourcerect: rectty;
              const adestpoint: pointty; const acopymode: rasteropty = rop_copy;
              const masked: boolean = true;
              const acolorforeground: colorty = cl_default;
                    //cl_default -> asource.colorforeground
                    //used for monochrome -> color conversion
              const acolorbackground: colorty = cl_default;
                    //cl_default -> asource.colorbackground
                    //used for monochrome -> color conversion or
                    //colorbackground for color -> monochrome conversion
              const aopacity: colorty = cl_none); overload;
   procedure copyarea(const asource: tsimplebitmap; const asourcerect: rectty;
              const adestrect: rectty; const aalignment: alignmentsty = [];
              const acopymode: rasteropty = rop_copy;
              const masked: boolean = true;
              const acolorforeground: colorty = cl_default;
                    //cl_default -> asource.colorforeground
                    //used for monochrome -> color conversion
              const acolorbackground: colorty = cl_default;
                    //cl_default -> asource.colorbackground
                    //used for monochrome -> color conversion or
                    //colorbackground for color -> monochrome conversion
              const aopacity: colorty = cl_none); overload;

   property kind: bitmapkindty read fkind write setkind;
   {
   property monochrome: boolean read getmonochrome write setmonochrome;
   property grayscale: boolean read getgrayscale write setgrayscale;
   }
   property canvas: tcanvas read getcanvas;
   property size: sizety read fsize write setsize;
         //pixels are not initialized
   property width: integer read fsize.cx write setwidth;
   property height: integer read fsize.cy write setheight;
   function isempty: boolean;
 end;

const
 {$ifdef FPC}
  {$warnings off}
 {$endif}
 nullgc: gcty = (handle: 0);
 {$ifdef FPC}
  {$warnings on}
 {$endif}
 changedmask = [cs_clipregion,cs_origin,cs_rasterop,cs_options,
                cs_acolorbackground,cs_acolorforeground,
                cs_color,cs_colorbackground,
                cs_fonthandle,cs_font,cs_fontcolor,cs_fontcolorbackground,
                cs_fonteffect,
                cs_brush,cs_brushorigin] + linecanvasstates;

type
 editfontcolorinfoty = record
  text: colorty;
  textbackground: colorty;
  selectedtext: colorty;
  selectedtextbackground: colorty;
 end;

var
 defaultframecolors: framecolorinfoty =
  (edges:(light: (color: cl_light; effectcolor: cl_highlight; effectwidth: 1);
           shadow: (color: cl_shadow; effectcolor: cl_dkshadow; effectwidth: 1);
          );
   frame: cl_black;
   hiddenedges: []
  );

 defaulteditfontcolors: editfontcolorinfoty = (
  text: cl_text;
  textbackground: cl_transparent;
  selectedtext: cl_selectedtext;
  selectedtextbackground: cl_selectedtextbackground;
 );

procedure init;
procedure deinit;

procedure initdefaultvalues(var avalue: edgecolorinfoty);
procedure initdefaultvalues(var avalue: edgecolorpairinfoty);
procedure drawinfoinit(var info: drawinfoty);

procedure gdi_lock();
procedure gdi_unlock();
function gdi_locked(): boolean;
function gdi_unlockall(): int32;
procedure gdi_relockall(const acount: int32);

procedure gdi_call(const func: gdifuncty; var drawinfo: drawinfoty;
                                   gdi: pgdifunctionaty = nil);
function getdefaultgdifuncs: pgdifunctionaty;{$ifdef FPC}inline;{$endif}
function registergdi(const agdifuncs: pgdifunctionaty): integer;
                                            //returns unique number
function getgdicanvasclass(const agdi: pgdifunctionaty;
                              const akind: bitmapkindty): canvasclassty;
function creategdicanvas(const agdi: pgdifunctionaty;
                            const akind: bitmapkindty;
                            const user: tobject; const intf: icanvas): tcanvas;

procedure freefontdata(var drawinfo: drawinfoty);

procedure allocbuffer(var buffer: bufferty; size: integer);
procedure extendbuffer(var buffer: bufferty; const extension: integer;
                                                   var reference: pointer);
function replacebuffer(var buffer: bufferty; size: integer): pointer;
procedure freebuffer(var buffer: bufferty);

procedure gdierrorlocked(error: gdierrorty; const text: msestring = ''); overload;
procedure gdierrorlocked(error: gdierrorty; sender: tobject;
                                               text: msestring = ''); overload;

function colortorgb(color: colorty): rgbtriplety;
function colortopixel(color: colorty): pixelty;
function graytopixel(color: colorty): pixelty;
function rgbtocolor(const red,green,blue: integer): colorty;
function blendcolor(const weight: real; const a,b: colorty): colorty;
                       //0..1
function opacitycolor(const opacity: real): colorty;
function invertcolor(const color: colorty): colorty;

procedure setcolormapvalue(index: colorty; const red,green,blue: integer); overload;
                    //RGB values 0..255
procedure setcolormapvalue(const index: colorty; const acolor: colorty); overload;
function isvalidmapcolor(index: colorty): boolean;
function transparencytoopacity(const trans: colorty): colorty;

procedure drawdottedlinesegments(const acanvas: tcanvas; const lines: segmentarty;
             const colorline: colorty);

procedure allocimage(out image: imagety; const asize: sizety;
                                             const akind: bitmapkindty);
procedure freeimage(var image: imagety);
procedure freeimage(var image: maskedimagety);
procedure zeropad(var image: imagety);
procedure checkimagebgr(var aimage: imagety; const bgr: boolean);
procedure movealignment(const source: alignmentsty; var dest: alignmentsty);
procedure setchildbounds(const sender: TObject);

var
 flushgdi: boolean;
{$ifdef mse_debuggdisync}
procedure checkgdilock;
procedure checkgdiunlocked;
{$endif}

implementation
uses
 SysUtils,msegui,mseguiintf,msestreaming,mseformatstr,
 msestockobjects, mseforms, msesimplewidgets, msedispwidgets, mseedit,
 msegrids, mseimage,msegraphedits,
 msearrayutils,mselist,msebits,msewidgets,msesystypes,
 msesysintf1,msesysintf,msesysutils,msefont;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 lineoptionty = (lio_antialias);
 lineoptionsty = set of lineoptionty;

var
 gdilockcount: integer;
 gdilockthread: threadty;
 
procedure setchildbounds(const sender: TObject);
var
// x, y : integer;  // Note: Local variable "y" not used
x : integer;
begin
   
setlength(mse_formchild,0);

if sender is tmseform then
 for x:=0 to tmseform(sender).ChildrenCount-1 do
  if tmseform(sender).Children[x] is tcustombutton then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tcustombutton(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tcustombutton(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tcustombutton(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tcustombutton(tmseform(sender).Children[X]).height;
  end  else
  if tmseform(sender).Children[x] is tcustomstringdisp then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tcustomstringdisp(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tcustomstringdisp(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tcustomstringdisp(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tcustomstringdisp(tmseform(sender).Children[X]).height;
  end else
  if tmseform(sender).Children[x] is tcustomedit then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tcustomedit(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tcustomedit(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tcustomedit(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tcustomedit(tmseform(sender).Children[X]).height;
  end else
  if tmseform(sender).Children[x] is tcustomstringgrid then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tcustomstringgrid(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tcustomstringgrid(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tcustomstringgrid(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tcustomstringgrid(tmseform(sender).Children[X]).height;
  end else
  if tmseform(sender).Children[x] is tscrollbox then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tscrollbox(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tscrollbox(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tscrollbox(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tscrollbox(tmseform(sender).Children[X]).height;
  end else
  if tmseform(sender).Children[x] is tscrollingwidget then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tscrollingwidget(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tscrollingwidget(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tscrollingwidget(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tscrollingwidget(tmseform(sender).Children[X]).height;
  end else
  if tmseform(sender).Children[x] is tcustombooleanedit then
  begin
  setlength(mse_formchild,length(mse_formchild) + 1);
  mse_formchild[length(mse_formchild) - 1].left := tcustombooleanedit(tmseform(sender).Children[X]).left;
  mse_formchild[length(mse_formchild) - 1].top  := tcustombooleanedit(tmseform(sender).Children[X]).top;
  mse_formchild[length(mse_formchild) - 1].width  := tcustombooleanedit(tmseform(sender).Children[X]).width;
  mse_formchild[length(mse_formchild) - 1].height  := tcustombooleanedit(tmseform(sender).Children[X]).height;
  end;
 
 end;

procedure initdefaultvalues(var avalue: edgecolorinfoty);
begin
 avalue.color:= cl_default;
 avalue.effectcolor:= cl_default;
 avalue.effectwidth:= -1;
end;

procedure initdefaultvalues(var avalue: edgecolorpairinfoty);
begin
 initdefaultvalues(avalue.shadow);
 initdefaultvalues(avalue.light);
end;

procedure drawinfoinit(var info: drawinfoty);
begin
 if flushgdi then begin
  fillchar(info.gc.platformdata,sizeof(info.gc.platformdata),0);
 end;
end;

{$ifdef mse_debuggdisync}
procedure gdilockerror(const text: msestring);
var
 str1: string;
begin
 str1:= text+lineend+
      'currentth:'+inttostr(sys_getcurrentthread)+
      ' mainth:'+inttostr(application.mainthread)+
      ' applockth:'+inttostr(application.lockthread)+
      ' applockc:'+inttostr(application.lockcount)+lineend+
      ' gdilockc:'+inttostr(gdilockcount)+lineend+
      'appmutexlockth:'+inttostr(appmutexlockth)+
      ' appmutexunlockth:'+inttostr(appmutexunlockth)+
      ' appmutexlockc:'+inttostr(appmutexlockc)+
      ' appmutexunlockc:'+inttostr(appmutexunlockc)+
      ' appmutexlocks:'+inttostr(appmutexlocks)+
      ' appmutexunlocks:'+inttostr(appmutexunlocks);
 debugwriteln(str1);
 debugwritestack;
end;

procedure checkgdilock;
begin
 if not application.islockedthread then begin
  gdilockerror('GDI lock error.');
 end;
end;

procedure checkgdiunlocked;
begin
 if gdilockcount <> 0 then begin
  gdilockerror('GDI unlock error.');
 end;
end;
{$endif}

function transparencytoopacity(const trans: colorty): colorty;
begin
 result:= trans;
 if trans <= $00ffffff then begin
  result:= result xor $00ffffff;
 end;
end;

procedure movealignment(const source: alignmentsty; var dest: alignmentsty);
begin
 dest:= alignmentsty(setsinglebit(
                longword(source),longword(dest),
                [longword([al_intpol,al_or,al_and]),
                 longword([al_left,al_xcentered,al_right]),
                longword([al_top,al_ycentered,al_bottom]),
                longword([al_fit,al_thumbnail,al_tiled])]));
end;

procedure allocimage(out image: imagety; const asize: sizety;
                                          const akind: bitmapkindty);
begin
 with image do begin
//  monochrome:= amonochrome;
  kind:= akind;
  bgr:= false;
  pixels:= nil;
  size:= asize;
  length:= 0;
  linelength:= 0;
  linebytes:= 0;
  if (size.cx <> 0) and (size.cy <> 0) then begin
   case kind of
    bmk_mono: begin
     linelength:= (size.cx+31) div 32;
    end;
    bmk_gray: begin
     linelength:= (size.cx+3) div 4;
    end;
    else begin
     linelength:= size.cx;
     length:= size.cy * size.cx;
    end;
   end;
   length:= size.cy * linelength;
   linebytes:= linelength * 4;
   pixels:= gui_allocimagemem(length);
  end;
 end;
end;

procedure freeimage(var image: imagety);
begin
 if image.pixels <> nil then begin
  gui_freeimagemem(image.pixels);
  fillchar(image,sizeof(image),0);
 end;
end;

procedure freeimage(var image: maskedimagety);
begin
 freeimage(image.image);
 freeimage(image.mask);
end;

procedure zeropad(var image: imagety);
var
 mask: longword;
 step: integer;
 po1: plongword;
 int1: integer;
begin
 with image do begin         //todo: little/big endian
  case kind of
   bmk_mono: begin
    mask:= bitmask[size.cx and $1f];
   end;
   bmk_gray: begin
    case size.cx and $3 of
     0: begin
      mask:= 0;
     end;
     1: begin
      mask:= $000000ff;
     end;
     2: begin
      mask:= $0000ffff;
     end;
     3: begin
      mask:= $00ffffff;
     end;
    end;
   end
   else begin
    mask:= 0;
   end;
   if mask <> 0 then begin
    step:= linelength;
    po1:= @pixels[step-1];
    for int1:= size.cy - 1 downto 0 do begin
     po1^:= po1^ and mask;   //mask padding
     inc(po1,step);
    end;
   end;
  end;
 end;
end;

procedure checkimagebgr(var aimage: imagety; const bgr: boolean);
var
 by1: byte;
 int1: integer;
 po1: prgbtriplety;
begin
 if (aimage.kind = bmk_rgb) and (aimage.bgr xor bgr) then begin
  po1:= prgbtriplety(aimage.pixels);
  for int1:= aimage.length-1 downto 0 do begin
   by1:= po1^.red;
   po1^.red:= po1^.blue;
   po1^.blue:= by1;
   inc(po1);
  end;
  aimage.bgr:= bgr;
 end;
end;

var
 gdinum: integer;
 gdifuncs: array of pgdifunctionaty;

function getdefaultgdifuncs: pgdifunctionaty; {$ifdef FPC}inline;{$endif}
begin
 if gdifuncs = nil then begin
  gui_registergdi;
 end;
 result:= gdifuncs[0];
end;

function registergdi(const agdifuncs: pgdifunctionaty): integer;
                         //returns unique number
var
 int1: integer;
begin
 for int1:= 0 to high(gdifuncs) do begin
  if gdifuncs[int1] = agdifuncs then begin
   result:= int1;
   exit;
  end;
 end;
 setlength(gdifuncs,gdinum+1); //item 0 = system default
 gdifuncs[gdinum]:= agdifuncs;
 result:= gdinum;
 inc(gdinum);
end;

procedure gdi_lock();
begin
 application.lock();
 gdilockthread:= sys_getcurrentthread();
 if (gdilockcount = 0) and not application.ismainthread then begin
 {$ifndef usesdl} 
  gui_disconnectmaineventqueue();
 {$endif}
 end;
 inc(gdilockcount);
end;

procedure gdi_unlock();
begin
 dec(gdilockcount);
 if gdilockcount = 0 then begin
  gdilockthread:= 0;
  if not application.ismainthread then begin
{$ifndef usesdl} 
  gui_connectmaineventqueue();
 {$endif}
   end;
 end;
 application.unlock();
end;

function gdi_locked(): boolean;
begin
 result:= (gdilockcount > 0) or application.islockedmainthread();
end;

function gdi_unlockall(): int32;
begin
 if gdilockthread = sys_getcurrentthread() then begin
  result:= gdilockcount;
  if result > 1 then begin
   gdilockcount:= 1;
  end;
  if result > 0 then begin
   gdi_unlock();
  end;
 end
 else begin
  result:= 0;
 end;
end;

procedure gdi_relockall(const acount: int32);
begin
 if acount > 0 then begin
  gdi_lock();
  gdilockcount:= gdilockcount + acount - 1;
 end;
end;

procedure gdi_call(const func: gdifuncty; var drawinfo: drawinfoty;
                                 gdi: pgdifunctionaty = nil);

 procedure doflush();
 begin
  gdi^[gdf_flush](drawinfo);
  gui_flushgdi();
 end; //doflush

begin
 if gdi = nil then begin
  gdi:= gdifuncs[0];//gui_getgdifuncs;
 end;
 if not gdi_locked() then begin
  gdi_lock();
  try
   gdi^[func](drawinfo);
   if flushgdi then begin
    doflush()
   end;
  finally
   gdi_unlock();
  end;
 end
 else begin
  gdi^[func](drawinfo);
  if flushgdi then begin
   doflush();
  end;
 end;
end;

procedure drawdottedlinesegments(const acanvas: tcanvas; const lines: segmentarty;
                     const colorline: colorty);
 {$ifdef mswindows}
var
 int1: integer;
// int2: integer;
 {$endif}
begin
 acanvas.save;
 acanvas.color:= colorline;
 acanvas.brush:= stockobjects.bitmaps[stb_dens50];
{$ifdef mswindows}
 {workaround: colors are wrong by negativ x on win2000! bug?}
 {
 int2:= levelshift;
 acanvas.remove(makepoint(int2,0));
 for int1:= 0 to high(lines) do begin
  inc(lines[int1].a.x,int2);
  inc(lines[int1].b.x,int2);
 end;
 }
 if iswin95 then begin //win95 can not draw brushed lines
  for int1:= 0 to high(lines) do begin
   with lines[int1] do begin
    if a.x <> b.x then begin
     acanvas.fillrect(makerect(a.x,a.y,b.x-a.x+1,1),cl_brushcanvas);
    end
    else begin
     acanvas.fillrect(makerect(a.x,a.y,1,b.y-a.y+1),cl_brushcanvas);
    end;
   end;
  end;
 end
 else begin
{$endif}
  acanvas.drawlinesegments(lines,cl_brushcanvas);
{$ifdef mswindows}
 end;
{$endif}
 acanvas.restore;
end;

var
 colormaps: array[colormapsty] of array of pixelty;
 inited: boolean;

function checkfontoptions(const new,old: fontoptionsty): fontoptionsty;
const
 mask1: fontoptionsty = fontpitchmask;
 mask2: fontoptionsty = fontfamilymask;
 mask3: fontoptionsty = fontantialiasedmask;
// mask4: fontoptionsty = fontxcoremask;
var
 value1: fontoptionsty;
 value2: fontoptionsty;
 value3: fontoptionsty;
// value4: fontoptionsty;
begin
  value1:= fontoptionsty(
         setsinglebit({$ifdef FPC}longword{$else}word{$endif}(new),
                      {$ifdef FPC}longword{$else}word{$endif}(old),
                      {$ifdef FPC}longword{$else}word{$endif}(mask1)));
  value2:= fontoptionsty(
         setsinglebit({$ifdef FPC}longword{$else}word{$endif}(new),
                      {$ifdef FPC}longword{$else}word{$endif}(old),
                      {$ifdef FPC}longword{$else}word{$endif}(mask2)));
  value3:= fontoptionsty(
         setsinglebit({$ifdef FPC}longword{$else}word{$endif}(new),
                      {$ifdef FPC}longword{$else}word{$endif}(old),
                      {$ifdef FPC}longword{$else}word{$endif}(mask3)));
(*
  value4:= fontoptionsty(
         setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(new),
                      {$ifdef FPC}longword{$else}byte{$endif}(old),
                      {$ifdef FPC}longword{$else}byte{$endif}(mask4)));
*)
  result:= value1 * mask1 + value2 * mask2 + value3 * mask3 {+ value4 * mask4};
end;

procedure freebuffer(var buffer: bufferty);
begin
 if buffer.buffer <> nil then begin
//  freemem(buffer.buffer,buffer.size);
  freemem(buffer.buffer);
  buffer.size:= 0;
  buffer.buffer:= nil;
 end;
end;

procedure allocbuffer(var buffer: bufferty; size: integer);
begin
 if size > buffer.size then begin
  freebuffer(buffer);
  getmem(buffer.buffer,size);
  buffer.size:= size;
 end;
end;

procedure extendbuffer(var buffer: bufferty; const extension: integer;
                                                   var reference: pointer);
var
 po1: pointer;
begin
 with buffer do begin
  cursize:= cursize + extension;
  if cursize > size then begin
   size:= cursize*2+1024;
   po1:= buffer;
   reallocmem(buffer,size);
   reference:= reference + (buffer-po1);
  end;
 end;
end;

function replacebuffer(var buffer: bufferty; size: integer): pointer;
begin
 result:= buffer.buffer;
 getmem(buffer.buffer,size);
 buffer.size:= size;
end;

procedure gdierrorlocked(error: gdierrorty; const text: msestring = ''); overload;
begin
 gdi_unlock;
 gdierror(error,text);
end;

procedure gdierrorlocked(error: gdierrorty; sender: tobject;
                       text: msestring = ''); overload;
begin
 gdi_unlock;
 gdierror(error,sender,text);
end;

function getdefaultcolorinfo(map: colormapsty; index: integer): pcolorinfoty;
begin
 case map of
  cm_functional: begin
   result:= @defaultfunctional[index];
  end;
  cm_mapped: begin
   result:= @defaultmapped[index];
  end;
  cm_namedrgb: begin
   result:= @defaultnamedrgb[index];
  end;
  cm_user: begin
   result:= @defaultuser[index];
  end;
  else begin
   result:= nil;
  end;
 end;
end;

function colortorgb(color: colorty): rgbtriplety;
var
 map: colormapsty;
begin
 map:= colormapsty((longword(color) shr speccolorshift));
 color:= colorty(longword(color) and not speccolormask);
 if map = cm_rgb then begin
  result:= rgbtriplety(color);
 end
 else begin
  dec(map,7);
  if (map < cm_rgb) or (map > high(map)) or
       (longword(color) >= longword(mapcolorcounts[map])) then begin
   result:= colortorgb(cl_invalid);
{
   gdierror(gde_invalidcolor,
       hextostrmse(longword(color)+longword(map) shl speccolorshift,8));
}
  end
  else begin
   result:= rgbtriplety(gui_pixeltorgb(colormaps[map][longword(color)]));
  end;
 end;
end;

function colortopixel(color: colorty): pixelty;
var
 map: colormapsty;
begin
 map:= colormapsty((longword(color) shr speccolorshift));
 color:= colorty(longword(color) and not speccolormask);
 if map = cm_rgb then begin
  result:= gui_rgbtopixel(color);
 end
 else begin
  dec(map,7);
  if (map < cm_rgb) or (map > high(map)) or
       (longword(color) >= longword(mapcolorcounts[map])) then begin
   result:= colortopixel(cl_invalid);
{
   gdierror(gde_invalidcolor,
       hextostrmse(longword(color)+longword(map) shl speccolorshift,8));
}
  end
  else begin
   result:= colormaps[map][longword(color)];
  end;
 end;
end;

function graytopixel(color: colorty): pixelty;
var
 co1: rgbtriplety;
 by1: byte;
begin
 pixelty(co1):= colortopixel(color);
 by1:= (integer(co1.red)+integer(co1.green)+integer(co1.blue)) div 3;
 result:= by1 or (by1 shl 8) or (by1 shl 16);
end;

function rgbtocolor(const red,green,blue: integer): colorty;
begin
 result:= (blue and $ff) or ((green and $ff) shl 8) or ((red and $ff) shl 16);
end;

function blendcolor(const weight: real; const a,b: colorty): colorty;
var
// by1: byte;
 ca,cb: rgbtriplety;
begin
 ca:= colortorgb(a);
 cb:= colortorgb(b);
 rgbtriplety(result).red:= ca.red + round((cb.red - ca.red)*weight);
 rgbtriplety(result).green:= ca.green + round((cb.green - ca.green)*weight);
 rgbtriplety(result).blue:= ca.blue + round((cb.blue - ca.blue)*weight);
 rgbtriplety(result).res:= 0;
end;

function opacitycolor(const opacity: real): colorty;
begin
 with rgbtriplety(result) do begin
  red:= round(255 * opacity);
  green:= red;
  blue:= red;
  res:= 0;
 end;
end;

function invertcolor(const color: colorty): colorty;
begin
 rgbtriplety(result):= colortorgb(color);
 with rgbtriplety(result) do begin
  red:= 255-red;
  green:= 255-green;
  blue:= 255-blue;
 end;
end;

function initcolormap: boolean;
var
 colormap: colormapsty;
 int1: integer;
begin
 result:= true;
 for colormap:= low(colormapsty) to high(colormapsty) do begin
  setlength(colormaps[colormap],mapcolorcounts[colormap]);
 {$ifdef FPC} {$checkpointer off} {$endif}
  for int1:= 0 to mapcolorcounts[colormap] - 1 do begin
   colormaps[colormap][int1]:= gui_rgbtopixel(
        longword(getdefaultcolorinfo(colormap,int1)^.rgb));
  end;
 {$ifdef FPC} {$checkpointer default} {$endif}
 end;
 colormaps[cm_namedrgb,integer(longword(cl_0)-longword(cl_namedrgb))]:=
                                                              mseguiintf.pixel0;
 colormaps[cm_namedrgb,integer(longword(cl_1)-longword(cl_namedrgb))]:=
                                                              mseguiintf.pixel1;
 gui_initcolormap;
end;

function isvalidmapcolor(index: colorty): boolean;
var
 map: colormapsty;
begin
 application.initialize; //colormap must be valid
 map:= colormapsty((longword(index) shr speccolorshift));
 index:= colorty(longword(index) and not speccolormask);
 dec(map,7);
 result := (map > cm_rgb) and (map <= high(map)) and
     (longword(index) < longword(mapcolorcounts[map]));
end;

procedure setcolormapvalue(index: colorty; const red,green,blue: integer);
var
 map: colormapsty;
begin
 application.initialize; //colormap must be valid
 map:= colormapsty((longword(index) shr speccolorshift));
 index:= colorty(longword(index) and not speccolormask);
 dec(map,7);
 if (map <= cm_rgb) or (map > high(map)) or
       (longword(index) >= longword(mapcolorcounts[map])) then begin
  gdierror(gde_invalidcolor,
       hextostrmse(longword(index)+longword(map) shl speccolorshift,8));
 end;
 colormaps[map][longword(index)]:= gui_rgbtopixel(rgbtocolor(red,green,blue));
end;

procedure setcolormapvalue(const index: colorty; const acolor: colorty);
var
 rgb1: rgbtriplety;
begin
 rgb1:= colortorgb(acolor);
 setcolormapvalue(index,rgb1.red,rgb1.green,rgb1.blue);
end;

function getgdicanvasclass(const agdi: pgdifunctionaty;
                                  const akind: bitmapkindty): canvasclassty;
var
 info1: drawinfoty;
begin
{$warnings off}
 with info1.getcanvasclass do begin
  kind:= akind;
  canvasclass:= tcanvas; //default
  agdi^[gdf_getcanvasclass](info1);
  result:= canvasclass;
 end;
end;
{$warnings on}

function creategdicanvas(const agdi: pgdifunctionaty;
                  const akind: bitmapkindty; const user: tobject;
                                           const intf: icanvas): tcanvas;
begin
 result:= getgdicanvasclass(agdi,akind).create(user,intf);
end;

procedure freefontdata(var drawinfo: drawinfoty);
begin
 drawinfo.getfont.fontdata^.h.d.gdifuncs^[gdf_freefontdata](drawinfo);
end;

procedure init;
var
 icon,mask: pixmapty;
begin
 gdi_lock;
 try
  initcolormap;
  msefont.init;
  msestockobjects.init;
  inited:= true;
  getwindowicon(nil,icon,mask);
  gui_setapplicationicon(icon,mask);
 finally
  gdi_unlock;
 end;
end;

procedure deinit;
begin
 if inited then begin
 msestockobjects.deinit;
 msefont.deinit;
 end;
 inited:= false;
end;


 { tsimplebitmap }

constructor tsimplebitmap.create(const akind: bitmapkindty;
                                           const agdifuncs: pgdifunctionaty = nil);
begin
 fgdifuncs:= agdifuncs;
 if fgdifuncs = nil then begin
  fgdifuncs:= getdefaultgdifuncs;
 end;
 fcanvasclass:= getgdicanvasclass(fgdifuncs,kind);
 fkind:= akind;
// if monochrome then begin
//  include(fstate,pms_monochrome);
// end;
 fcolorbackground:= cl_white;
 fcolorforeground:= cl_black;
end;

destructor tsimplebitmap.destroy;
begin
 inherited;
 destroyhandle;
 freeandnil(fcanvas);
end;

procedure tsimplebitmap.freecanvas;
begin
 if pms_staticcanvas in fstate then begin
  if fcanvas <> nil then begin
   fcanvas.reset;
  end;
 end
 else begin
  freeandnil(fcanvas);
 end;
end;

function tsimplebitmap.canvasallocated: boolean;
begin
 result:= fcanvas <> nil;
end;

procedure tsimplebitmap.clear;
begin
 size:= nullsize;
end;
{
function tsimplebitmap.getmonochrome: boolean;
begin
 result:= fkind = bmk_mono;
// result:= pms_monochrome in fstate;
end;

procedure tsimplebitmap.setmonochrome(const avalue: boolean);
begin
 kind:= bmk_mono;
end;

function tsimplebitmap.getgrayscale: boolean;
begin
 result:= fkind = bmk_gray;
end;

procedure tsimplebitmap.setgrayscale(const avalue: boolean);
begin
 kind:= bmk_gray;
end;
}
function tsimplebitmap.getconverttomonochromecolorbackground: colorty;
begin
 result:= fcolorbackground;
end;
(*
procedure tsimplebitmap.setmonochrome(const avalue: boolean);
var
 bmp: tsimplebitmap;
 ahandle: pixmapty;
begin
 if avalue <> getmonochrome then begin
  if isempty then begin
   if avalue then begin
    fkind:= bmk_mono;
   end
   else begin
    fkind:= bmk_rgb;
   end;
  {
   if avalue then begin
    include(fstate,pms_monochrome);
   end
   else begin
    exclude(fstate,pms_monochrome);
   end
  }
  end
  else begin
   if avalue then begin
    bmp:= tsimplebitmap.create(bmk_mono,fgdifuncs);
    bmp.size:= fsize;
    bmp.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy,
       getconverttomonochromecolorbackground);
   end
   else begin
    bmp:= tsimplebitmap.create(bmk_rgb,fgdifuncs);
    bmp.size:= fsize;
    bmp.canvas.colorbackground:= fcolorbackground;
    bmp.canvas.color:= fcolorforeground;
    bmp.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint);
   end;
   ahandle:= bmp.fhandle;
   bmp.releasehandle;
   bmp.Free;
   handle:= ahandle;
   acquirehandle;
  end;
 end;
end;
*)
procedure tsimplebitmap.setkind(const avalue: bitmapkindty);
var
 bmp: tsimplebitmap;
 ahandle: pixmapty;
begin
 if fkind <> avalue then begin
  if isempty then begin
   destroyhandle();
   fkind:= avalue;
  end
  else begin
   bmp:= tsimplebitmap.create(avalue,fgdifuncs);
   bmp.size:= fsize;
   case avalue of
    bmk_mono: begin
     bmp.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy,
                                         getconverttomonochromecolorbackground);
    end;
    else begin
     bmp.canvas.colorbackground:= fcolorbackground;
     bmp.canvas.color:= fcolorforeground;
     bmp.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint);
    end;
   end;
   ahandle:= bmp.fhandle;
   bmp.releasehandle;
   bmp.Free;
   fkind:= avalue;
   handle:= ahandle;
   acquirehandle;
  end;
 end;
end;


procedure tsimplebitmap.switchtomonochrome;
begin
// include(fstate,pms_monochrome);
 fkind:= bmk_mono;
 if fcanvas <> nil then begin
  fcanvas.init;
 end;
end;

procedure tsimplebitmap.creategc;
var
 gc: gcty;
 err: gdierrorty;
begin
 if fcanvas <> nil then begin
  fillchar(gc,sizeof(gcty),0);
  gc.drawingflags:= [df_canvasispixmap];
  gc.paintdevicesize:= fsize;
//  if pms_monochrome in fstate then begin
  if fkind = bmk_mono then begin
   include(gc.drawingflags,df_canvasismonochrome);
  end;
  gc.kind:= fkind;
  gdi_lock;
  err:= fcanvas.creategc(fhandle,gck_pixmap,gc);
  gdi_unlock;
  gdierror(err,self);
  fcanvas.linktopaintdevice(fhandle,gc,fdefaultcliporigin);
 end;
end;

function tsimplebitmap.createcanvas: tcanvas;
begin
 result:= fcanvasclass.create(self,icanvas(self));
end;

function tsimplebitmap.getcanvas: tcanvas;
begin
 if fcanvas = nil then begin
  fcanvas:= createcanvas;
 end;
 result:= fcanvas;
end;

procedure tsimplebitmap.createhandle(acopyfrom: pixmapty);
      //copyfrom does not work on windows with in dc selected bmp!
var
 info: drawinfoty;
begin
 if (fsize.cx > 0) and (fsize.cy > 0) then begin
  if fhandle = 0 then begin
{$warnings off}
   drawinfoinit(info);
   with info.createpixmap do begin
    size:= fsize;
//    monochrome:= (pms_monochrome in fstate);
    kind:= fkind;
    copyfrom:= acopyfrom;
    handle:= 0;
    gdi_call(gdf_createpixmap,info,getgdiintf);
    fhandle:= pixmap;
   end;
//   gdi_lock;
//   fhandle:= gui_createpixmap(fsize,0,(pms_monochrome in fstate) and
//                  (fcanvasclass = nil,copyfrom);
//   gdi_unlock;
   if fhandle = 0 then begin
    gdierror(gde_pixmap);
   end;
   include(fstate,pms_ownshandle);
  end;
 end;
end;
{$warnings on}

procedure tsimplebitmap.releasehandle;
begin
 if fhandle <> 0 then begin
  if fcanvas <> nil then begin
   fcanvas.unlink;
  end;
//  fhandle:= 0;
  exclude(fstate,pms_ownshandle);
 end;
end;

procedure tsimplebitmap.acquirehandle;
begin
 if fhandle <> 0 then begin
  include(fstate,pms_ownshandle);
 end;
end;

procedure tsimplebitmap.copyhandle;
var
 ahandle: pixmapty;
begin
 releasehandle;
 ahandle:= fhandle;
 fhandle:= 0;
 createhandle(ahandle);
end;

procedure tsimplebitmap.internaldestroyhandle;
var
 bo1: boolean;
begin
 if fhandle <> 0 then begin
  bo1:= pms_ownshandle in fstate;
  releasehandle;
  if bo1 then begin
   gdi_lock;
   gui_freepixmap(fhandle);
   gdi_unlock;
  end;
  fhandle:= 0;
 end;
end;

procedure tsimplebitmap.destroyhandle;
begin
 internaldestroyhandle;
end;

function tsimplebitmap.getsize: sizety;
begin
 result:= fsize;
end;

procedure tsimplebitmap.setsize(const avalue: sizety);
begin
 destroyhandle;
 fsize:= avalue;
 updatescanline();
end;

function tsimplebitmap.getkind(): bitmapkindty;
begin
 result:= fkind;
end;

function tsimplebitmap.isempty(): boolean;
begin
 result:= (fsize.cx = 0) or (fsize.cy = 0);
end;

function tsimplebitmap.gethandle(): pixmapty;
begin
 if fhandle = 0 then begin
  createhandle(0);
 end;
 result:= fhandle;
end;

procedure tsimplebitmap.sethandle(const Value: pixmapty);
var
 info: pixmapinfoty;
begin
 if fhandle <> value then begin
  internaldestroyhandle;
 end;
 if value <> 0 then begin
  info.handle:= value;
//  gdi_lock;
//  try
  gdierror(gui_getpixmapinfo(info));
//  finally
//   gdi_unlock;
//  end;
  fhandle:= value;
  with info do begin
   fsize:= size;
   case depth of
    1: begin
     fkind:= bmk_mono;
    end;
    8: begin
     fkind:= bmk_gray;
    end;
    else begin
     fkind:= bmk_rgb;
    end;
   end;
  {
   if depth = 1 then begin
    include(fstate,pms_monochrome);
   end
   else begin
    exclude(fstate,pms_monochrome);
   end;
  }
   updatescanline();
  end;
 end;
end;

procedure tsimplebitmap.gcneeded(const sender: tcanvas);
begin
 if isempty then begin
  gdierror(gde_pixmap);
 end
 else begin
  if not (pms_ownshandle in fstate) and (fhandle <> 0) then begin
   copyhandle;
  end
  else begin
   createhandle(0);
  end;
  creategc;
 end;
end;

function tsimplebitmap.normalizeinitcolor(const acolor: colorty): colorty;
begin
 if acolor = cl_transparent then begin
  if kind = bmk_mono then begin
   result:= cl_0;
  end
  else begin
   result:= cl_white;
  end;
 end
 else begin
  result:= acolor;
 end;
end;

procedure tsimplebitmap.init(const acolor: colorty);
begin
 with canvas.fvaluepo^.origin do begin
  canvas.fillrect(makerect(-x,-y,fsize.cx,fsize.cy),normalizeinitcolor(acolor));
 end;
end;

procedure tsimplebitmap.assign1(const source: tsimplebitmap; const docopy: boolean);
begin
 clear;
 with tsimplebitmap(source) do begin
  if not isempty then begin
   if docopy then begin
 //   self.handle:= handle; //windows problem: copy handle does not work with bmp selected in dc
 //   self.copyhandle;
    self.clear;
    self.kind:= kind;
    self.size:= size;
    self.copyarea(source,makerect(nullpoint,fsize),nullpoint,rop_copy,false);
   end
   else begin
    self.handle:= handle;
    releasehandle;
    self.acquirehandle;
   end;
  end;
 end;
end;

procedure tsimplebitmap.assign(source: tpersistent);
begin
 if source is tsimplebitmap then begin
  assign1(tsimplebitmap(source),true);
 end
 else begin
  inherited;
 end;
end;

procedure tsimplebitmap.assignnegative(source: tsimplebitmap);
                       //gets negative copy
begin
 clear;
 kind:= source.kind;
 if not source.isempty then begin
  size:= source.size;
  copyarea(source,makerect(nullpoint,fsize),nullpoint,rop_notcopy);
 end;
end;

procedure tsimplebitmap.copyarea(const asource: tsimplebitmap;
              const asourcerect: rectty;
              const adestrect: rectty; const aalignment: alignmentsty = [];
              const acopymode: rasteropty = rop_copy;
              const masked: boolean = true;
              const acolorforeground: colorty = cl_default;
                    //cl_default -> asource.colorforeground
                    //used for monochrome -> color conversion
              const acolorbackground: colorty = cl_default;
                    //cl_default -> asource.colorbackground
                    //used for monochrome -> color conversion or
                    //colorbackground for color -> monochrome conversion
              const aopacity: colorty = cl_none);
var
 bo1,bo2: boolean;
 amask: tsimplebitmap;
 maskpos1: pointty;
begin
 bo1:= canvasallocated;
 bo2:= asource.canvasallocated;
 if bo1 then begin
  canvas.save;
  canvas.clipregion:= 0;
  canvas.origin:= nullpoint;
 end;
 if bo2 then begin
  asource.canvas.save;
  asource.canvas.origin:= nullpoint;
 end;
 if acolorforeground = cl_default then begin
  canvas.color:= asource.fcolorforeground;
 end
 else begin
  canvas.color:= acolorforeground;
 end;
 if acolorbackground = cl_default then begin
  canvas.colorbackground:= asource.fcolorbackground;
 end
 else begin
  canvas.colorbackground:= acolorbackground;
 end;
 if masked then begin
  amask:= asource.getmask(maskpos1);
 end
 else begin
  amask:= nil;
  maskpos1:= nullpoint;
 end;
 canvas.internalcopyarea(asource.canvas,asourcerect,
                calcrectalignment(adestrect,asourcerect,aalignment),acopymode,
                       cl_default,amask,maskpos1,aalignment,nullpoint,aopacity);
 if bo1 then begin
  canvas.restore;
 end
 else begin
  freecanvas;
 end;
 if bo2 then begin
  asource.canvas.restore;
 end
 else begin
  asource.freecanvas;
 end;
end;

procedure tsimplebitmap.copyarea(const asource: tsimplebitmap; const asourcerect: rectty;
              const adestpoint: pointty; const acopymode: rasteropty = rop_copy;
              const masked: boolean = true;
              const acolorforeground: colorty = cl_default; //cl_default -> asource.colorforeground
                    //used if asource is monchrome
              const acolorbackground: colorty = cl_default;//cl_default -> asource.colorbackground
                    //used if asource is monchrome or
                    //colorbackground for color -> monochrome conversion
              const aopacity: colorty = cl_none);
begin
 copyarea(asource,asourcerect,makerect(adestpoint,asourcerect.size),[],acopymode,
                        masked,acolorforeground,acolorbackground,aopacity);
end;

{
procedure tsimplebitmap.stretch(const source: tsimplebitmap; const asize: sizety);
type
 cardarty = array[0..0] of longword;
var
 sim: pimagety;
 simage,dimage: imagety;
 po1: ^cardarty;
 po2: plongword;
 ca1,ca2: longword;
 stepx: longword;
 int1: integer;
begin
 if source.isempty then begin
  gdierror(gde_pixmap,self,'stretch');
 end;
 if source <> self then begin
  clear;
  if source.monochrome <> monochrome then begin
   gdierror(gde_unmatchedmonochrome,self,'stretch');
  end;
  if monochrome then begin
   include(fstate,pms_monochrome);
  end
  else begin
   exclude(fstate,pms_monochrome);
  end;
 end;
 sim:= source.getimagepo;
 if sim = nil then begin
  source.initimage(false,simage);
 end
 else begin
  simage:= sim^;
 end;
 if simage.pixels = nil then begin
  if source.fcanvas <> nil then begin
   gdierror(gui_pixmaptoimage(source.handle,simage,source.fcanvas.fdrawinfo.gc.handle))
  end
  else begin
   gdierror(gui_pixmaptoimage(source.handle,simage,0))
  end;
 end;
 size:= asize;
 initimage(true,dimage);
 if monochrome then begin
 end
 else begin
  po1:= pointer(simage.pixels);
  po2:= pointer(dimage.pixels);
  stepx:= ((($10000*simage.size.cx) + $8000) div dimage.size.cx) shl 15;
  ca2:= 0;
  for int1:= 0 to asize.cx - 1 do begin
   ca1:= po1^[int1];
   repeat
    po2^:= ca1;
    inc(po2);
    inc(ca2,stepx);
   until integer(ca2) < 0;
   dec(ca2,$80000000);
  end;
 end;
end;
}
{
function tsimplebitmap.getmaskhandle(var gchandle: ptruint): pixmapty;
begin
 result:= 0; //dummy
end;
}

function tsimplebitmap.getmask(out apos: pointty): tsimplebitmap;
begin
 result:= nil; //dummy
end;
{
function tsimplebitmap.getimagepo: pimagety;
begin
 result:= nil; //dummy
end;
}
{
procedure tsimplebitmap.initimage(alloc: boolean; out aimage: imagety);
                  //allocates memory, no clear
var
 int1: integer;
begin
 with aimage do begin
  monochrome:= pms_monochrome in fstate;
  pixels:= nil;
  size:= fsize;
  if alloc and (size.cx <> 0) and (size.cy <> 0) then begin
   if monochrome then begin
    int1:= fsize.cy * ((fsize.cx+31) div 32);
   end
   else begin
    int1:= fsize.cy * fsize.cx;
   end;
   allocuninitedarray(int1,sizeof(longword),pixels);
  end;
 end;
end;
}
procedure tsimplebitmap.getcanvasimage(const bgr: boolean;
                                                var aimage: maskedimagety);
begin
 //dummy
end;

function tsimplebitmap.getgdiintf: pgdifunctionaty;
begin
 result:= nil;
 if fcanvas <> nil then begin
  result:= fcanvas.fdrawinfo.gc.gdifuncs;
 end;
 if result = nil then begin
  result:= fcanvasclass.getclassgdifuncs;
 end;
end;

procedure tsimplebitmap.setwidth(const avalue: integer);
begin
 size:= ms(avalue,height);
end;

procedure tsimplebitmap.setheight(const avalue: integer);
begin
 size:= ms(width,avalue);
end;

procedure tsimplebitmap.updatescanline();
begin
 case fkind of
  bmk_mono: begin
   fscanlinewords:= ((fsize.cx + 31) div 32);
  end;
  bmk_gray: begin
   fscanlinewords:= ((fsize.cx + 3) div 4);
  end;
  else begin
   fscanlinewords:= fsize.cx;
  end;
 end;
 fscanlinestep:= fscanlinewords * 4;
 fscanhigh:=  fsize.cx * fsize.cy - 1;
end;


procedure initfontinfo(var ainfo: basefontinfoty);
begin
 with ainfo do begin
  color:= cl_default;              //cl_text
  colorbackground:= cl_default;    //cl_transparent
  colorselect:= cl_default;              //cl_selectedtext
  colorselectbackground:= cl_default;    //cl_selectedtxtbackground
  shadow_color:= cl_none;
  shadow_shiftx:= 1;
  shadow_shifty:= 1;

  gloss_color:= cl_none;
  gloss_shiftx:= -1;
  gloss_shifty:= -1;

  grayed_color:= cl_default;       //cl_grayed;
  grayed_colorshadow:= cl_default; //cl_grayedshadow;
  grayed_shiftx:= 1;
  grayed_shifty:= 1;

  xscale:= 1.0;
 end;
end;

{ tfont }

constructor tfont.create;
begin
 if finfopo = nil then begin
  finfopo:= @finfo;
 end;
 initfontinfo(finfopo^.baseinfo);
 updatehandlepo;
 dochanged([cs_fontcolor,cs_fontcolorbackground,cs_fonteffect],true);
end;

destructor tfont.destroy;
begin
 //handle:= 0;
 releasehandles(true);
 inherited;
end;

function tfont.getfont(var drawinfo: drawinfoty): boolean;
begin
 gdi_lock;
// gdi_getfont(drawinfo);
 drawinfo.gc.gdifuncs^[gdf_getfont](drawinfo);
 result:= drawinfo.getfont.ok;
 if result then begin
  with drawinfo.getfont.fontdata^ do begin
   linewidth:= height div (9 * (1 shl fontsizeshift));
  end;
 end;
 gdi_unlock;
end;

procedure tfont.createhandle(const canvas: tcanvas);
var
 int1: integer;
 templ1: tfontcomp;
 po1: pfontdataty;
 info1: fontinfoty;
 opt1: fontoptionsty;
begin
 if (canvas <> nil) then begin
  canvas.checkgcstate([cs_gc]); //windows needs gc
  if finfopo^.gdifuncs <> nil then begin
   if finfopo^.gdifuncs <> canvas.fdrawinfo.gc.fontgdifuncs then begin
    for int1:= 0 to high(finfopo^.handles) do begin
     releasefont(finfopo^.handles[int1]);
     finfopo^.handles[int1]:= 0;
    end;
   end
   else begin
    releasefont(fhandlepo^);
   end;
  end;
  finfopo^.gdifuncs:= canvas.fdrawinfo.gc.fontgdifuncs;
//  finfopo^.gdifuncs:= gdifuncs[canvas.fgdinum];
  templ1:= nil;
  fhandlepo^:= getfontnum(finfopo^,canvas.fdrawinfo,
                                         {$ifdef FPC}@{$endif}getfont,templ1);
  if fhandlepo^ = 0 then begin
   canvas.error(gde_font,msestring(finfopo^.baseinfo.name));
  end;
  if (templ1 <> nil) and (ftemplate = nil) then begin
   po1:= getfontdata(fhandlepo^);
   settemplateinfo(templ1.template.fi);
   if fhandlepo^ = 0 then begin
    info1:= finfopo^;
    with po1^.realfont do begin
     if (info1.baseinfo.name = '') and (name <> '') then begin
      info1.baseinfo.name:= name;
     end;
     if (info1.baseinfo.height = 0) and (d.height <> 0) then begin
      info1.baseinfo.height:= d.height;
     end;
     if info1.baseinfo.options = [] then begin
      opt1:= d.familyoptions + d.pitchoptions + d.antialiasedoptions;
      if opt1 <> [] then begin
       info1.baseinfo.options:= opt1;
      end;
     end;
     if (info1.baseinfo.width = 0) and (d.width <> 0) then begin
      info1.baseinfo.width:= d.width;
     end;
     if (info1.baseinfo.xscale = 1) and (d.xscale <> 1) then begin
      info1.baseinfo.xscale:= d.xscale;
     end;
    end;
    fhandlepo^:= getfontnum(info1,canvas.fdrawinfo,@getfont,templ1);
   end;
  end;
 end
 else begin
  fhandlepo^:= 0;
  finfopo^.gdifuncs:= nil;
 end;
end;

function tfont.gethandleforcanvas(const canvas: tcanvas): fontnumty;
begin
 if (fhandlepo^ <> 0) and
           (finfopo^.gdifuncs <> canvas.fdrawinfo.gc.gdifuncs) then begin
  releasehandles(true);
 end;
 if fhandlepo^ = 0 then begin
  createhandle(canvas);
 end;
 result:= fhandlepo^;
end;

function tfont.gethandle: fontnumty;
var
 canvas: tcanvas;
begin
 if fhandlepo^ = 0 then begin
  canvas:= creategdicanvas(getdefaultgdifuncs,bmk_rgb,self,icanvas(self));
//  canvas:= tcanvas.create(self,icanvas(self));
  try
   createhandle(canvas);
  finally
   canvas.Free;
  end;
 end;
 result:= fhandlepo^;
end;

function tfont.getdatapo: pfontdataty;
begin
 result:= getfontdata(gethandle);
end;
{
procedure tfont.sethandle(const Value: fontty);
begin
 if fhandlepo^ <> value then begin
  releasefont(fhandlepo^);
  fhandlepo^ := Value;
  dochanged([cs_font]);
 end;
end;
}
procedure tfont.dochanged(const changed: canvasstatesty;
                                           const nochange: boolean);
begin
 if assigned(fonchange) and not nochange then begin
  fonchange(self);
 end;
end;

function tfont.getascent: integer;
begin
 result:= getdatapo^.ascent {+ finfopo^.extraspace};
end;

function tfont.getdescent: integer;
begin
 result:= getdatapo^.descent;
end;

function tfont.getglyphheight: integer;
begin
 with getdatapo^ do begin
  result:= ascent+descent;
 end;
end;

function tfont.getlineheight: integer;
begin
 with getdatapo^ do begin
  result:= ascent + descent;
  if linespacing > result then begin
   result:= linespacing;
  end;
 end;
 result:= result + finfopo^.baseinfo.extraspace;
end;

function tfont.getlinewidth: integer;
begin
 result:= getdatapo^.linewidth;
end;

function tfont.getcaretshift: integer;
begin
 result:= getdatapo^.caretshift;
end;

function tfont.getextraspace: integer;
begin
 result:= finfopo^.baseinfo.extraspace;
end;

procedure tfont.setextraspace(const avalue: integer);
begin
 include(flocalprops,flp_extraspace);
 if finfopo^.baseinfo.extraspace <> avalue then begin
  finfopo^.baseinfo.extraspace := avalue;
  dochanged([cs_font],false);
 end;
end;

procedure tfont.setcolorbackground(const Value: colorty);
begin
 include(flocalprops,flp_colorbackground);
 with finfopo^.baseinfo do begin
  if colorbackground <> value then begin
   colorbackground:= Value;
   dochanged([cs_fontcolorbackground],false);
  end;
 end;
end;

procedure tfont.setcolorselectbackground(const Value: colorty);
begin
 include(flocalprops,flp_colorselectbackground);
 with finfopo^.baseinfo do begin
  if colorselectbackground <> value then begin
   colorselectbackground:= Value;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getcolorbackground: colorty;
begin
 result:= finfopo^.baseinfo.colorbackground;
end;

function tfont.getcolorselectbackground: colorty;
begin
 result:= finfopo^.baseinfo.colorselectbackground;
end;

procedure tfont.setshadow_color(avalue: colorty);
begin
 include(flocalprops,flp_shadow_color);
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 with finfopo^.baseinfo do begin
  if shadow_color <> avalue then begin
   shadow_color:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getshadow_color: colorty;
begin
 result:= finfopo^.baseinfo.shadow_color;
end;

procedure tfont.setshadow_shiftx(const avalue: integer);
begin
 include(flocalprops,flp_shadow_shiftx);
 with finfopo^.baseinfo do begin
  if shadow_shiftx <> avalue then begin
   shadow_shiftx:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getshadow_shiftx: integer;
begin
 result:= finfopo^.baseinfo.shadow_shiftx;
end;

procedure tfont.setshadow_shifty(const avalue: integer);
begin
 include(flocalprops,flp_shadow_shifty);
 with finfopo^.baseinfo do begin
  if shadow_shifty <> avalue then begin
   shadow_shifty:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getshadow_shifty: integer;
begin
 result:= finfopo^.baseinfo.shadow_shifty;
end;

procedure tfont.setgloss_color(avalue: colorty);
begin
 include(flocalprops,flp_gloss_color);
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 with finfopo^.baseinfo do begin
  if gloss_color <> avalue then begin
   gloss_color:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getgloss_color: colorty;
begin
 result:= finfopo^.baseinfo.gloss_color;
end;

procedure tfont.setgloss_shiftx(const avalue: integer);
begin
 include(flocalprops,flp_gloss_shiftx);
 with finfopo^.baseinfo do begin
  if gloss_shiftx <> avalue then begin
   gloss_shiftx:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getgloss_shiftx: integer;
begin
 result:= finfopo^.baseinfo.gloss_shiftx;
end;

procedure tfont.setgloss_shifty(const avalue: integer);
begin
 include(flocalprops,flp_gloss_shifty);
 with finfopo^.baseinfo do begin
  if gloss_shifty <> avalue then begin
   gloss_shifty:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getgloss_shifty: integer;
begin
 result:= finfopo^.baseinfo.gloss_shifty;
end;

function tfont.getgrayed_color: colorty;
begin
 result:= finfopo^.baseinfo.grayed_color;
end;

procedure tfont.setgrayed_color(const avalue: colorty);
begin
 include(flocalprops,flp_grayed_color);
 with finfopo^.baseinfo do begin
  if grayed_color <> avalue then begin
   grayed_color:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getgrayed_colorshadow: colorty;
begin
 result:= finfopo^.baseinfo.grayed_colorshadow;
end;

procedure tfont.setgrayed_colorshadow(const avalue: colorty);
begin
 include(flocalprops,flp_grayed_colorshadow);
 with finfopo^.baseinfo do begin
  if grayed_colorshadow <> avalue then begin
   grayed_colorshadow:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getgrayed_shiftx: integer;
begin
 result:= finfopo^.baseinfo.grayed_shiftx;
end;

procedure tfont.setgrayed_shiftx(const avalue: integer);
begin
 include(flocalprops,flp_grayed_shiftx);
 with finfopo^.baseinfo do begin
  if grayed_shiftx <> avalue then begin
   grayed_shiftx:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

function tfont.getgrayed_shifty: integer;
begin
 result:= finfopo^.baseinfo.grayed_shifty;
end;

procedure tfont.setgrayed_shifty(const avalue: integer);
begin
 include(flocalprops,flp_grayed_shifty);
 with finfopo^.baseinfo do begin
  if grayed_shifty <> avalue then begin
   grayed_shifty:= avalue;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

procedure tfont.setcolor(const Value: colorty);
begin
 include(flocalprops,flp_color);
 with finfopo^.baseinfo do begin
  if color <> value then begin
   color := Value;
   dochanged([cs_fontcolor],false);
  end;
 end;
end;

procedure tfont.setcolorselect(const Value: colorty);
begin
 include(flocalprops,flp_colorselect);
 with finfopo^.baseinfo do begin
  if colorselect <> value then begin
   colorselect := Value;
   dochanged([cs_fonteffect],false);
  end;
 end;
end;

procedure tfont.assignproperties(const source: tfont; const ahandles: boolean);
var
 int1: integer;
 bo1: boolean;
 changed: canvasstatesty;
begin
 changed:= [];
 with source,self.finfopo^ do begin
  if baseinfo.colorbackground <> finfopo^.baseinfo.colorbackground then begin
   baseinfo.colorbackground:= finfopo^.baseinfo.colorbackground;
   include(changed,cs_fontcolorbackground);
  end;
  if baseinfo.colorselectbackground <>
             finfopo^.baseinfo.colorselectbackground then begin
   baseinfo.colorselectbackground:= finfopo^.baseinfo.colorselectbackground;
   include(changed,cs_fonteffect);
  end;

  if baseinfo.shadow_color <> finfopo^.baseinfo.shadow_color then begin
   baseinfo.shadow_color:= finfopo^.baseinfo.shadow_color;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.shadow_shiftx <> finfopo^.baseinfo.shadow_shiftx then begin
   baseinfo.shadow_shiftx:= finfopo^.baseinfo.shadow_shiftx;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.shadow_shifty <> finfopo^.baseinfo.shadow_shifty then begin
   baseinfo.shadow_shifty:= finfopo^.baseinfo.shadow_shifty;
   include(changed,cs_fonteffect);
  end;

  if baseinfo.gloss_color <> finfopo^.baseinfo.gloss_color then begin
   baseinfo.gloss_color:= finfopo^.baseinfo.gloss_color;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.gloss_shiftx <> finfopo^.baseinfo.gloss_shiftx then begin
   baseinfo.gloss_shiftx:= finfopo^.baseinfo.gloss_shiftx;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.gloss_shifty <> finfopo^.baseinfo.gloss_shifty then begin
   baseinfo.gloss_shifty:= finfopo^.baseinfo.gloss_shifty;
   include(changed,cs_fonteffect);
  end;

  if baseinfo.grayed_color <> finfopo^.baseinfo.grayed_color then begin
   baseinfo.grayed_color:= finfopo^.baseinfo.grayed_color;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.grayed_colorshadow <> finfopo^.baseinfo.grayed_colorshadow then begin
   baseinfo.grayed_colorshadow:= finfopo^.baseinfo.grayed_colorshadow;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.grayed_shiftx <> finfopo^.baseinfo.grayed_shiftx then begin
   baseinfo.grayed_shiftx:= finfopo^.baseinfo.grayed_shiftx;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.grayed_shifty <> finfopo^.baseinfo.grayed_shifty then begin
   baseinfo.grayed_shifty:= finfopo^.baseinfo.grayed_shifty;
   include(changed,cs_fonteffect);
  end;

  if baseinfo.color <> finfopo^.baseinfo.color then begin
   baseinfo.color:= finfopo^.baseinfo.color;
   include(changed,cs_fontcolor);
  end;
  if baseinfo.colorselect <> finfopo^.baseinfo.colorselect then begin
   baseinfo.colorselect:= finfopo^.baseinfo.colorselect;
   include(changed,cs_fonteffect);
  end;
  if baseinfo.style <> finfopo^.baseinfo.style then begin
   baseinfo.style:= finfopo^.baseinfo.style;
   self.updatehandlepo;
   include(changed,cs_font);
  end;
  if baseinfo.extraspace <> finfopo^.baseinfo.extraspace then begin
   baseinfo.extraspace:= finfopo^.baseinfo.extraspace;
   include(changed,cs_font);
  end;
  if baseinfo.height <> finfopo^.baseinfo.height then begin
   baseinfo.height:= finfopo^.baseinfo.height;
   include(changed,cs_font);
  end;
  if baseinfo.width <> finfopo^.baseinfo.width then begin
   baseinfo.width:= finfopo^.baseinfo.width;
   include(changed,cs_font);
  end;
  if baseinfo.name <> finfopo^.baseinfo.name then begin
   baseinfo.name:= finfopo^.baseinfo.name;
   include(changed,cs_font);
  end;
  if baseinfo.charset <> finfopo^.baseinfo.charset then begin
   baseinfo.charset:= finfopo^.baseinfo.charset;
   include(changed,cs_font);
  end;
  if baseinfo.options <> finfopo^.baseinfo.options then begin
   baseinfo.options:= finfopo^.baseinfo.options;
   include(changed,cs_font);
  end;
  if baseinfo.xscale <> finfopo^.baseinfo.xscale then begin
   baseinfo.xscale:= finfopo^.baseinfo.xscale;
   include(changed,cs_font);
  end;
  bo1:= false;
  if ahandles then begin
   for int1:= 0 to high(handles) do begin
    if handles[int1] <> finfopo^.handles[int1] then begin
     bo1:= true;
     releasefont(handles[int1]);
     handles[int1]:= finfopo^.handles[int1];
     addreffont(handles[int1]);
    end;
   end;
   gdifuncs:= finfopo^.gdifuncs;
  end
  else begin
   for int1:= 0 to high(handles) do begin
    if handles[int1] <> 0 then begin
     bo1:= true;
     releasefont(handles[int1]);
     handles[int1]:= 0;
    end;
   end;
  end;
  if bo1 then begin
   include(changed,cs_fonthandle);
  end;
 end;
 if changed <> [] then begin
  dochanged(changed,false);
 end;
end;

procedure tfont.readcolorshadow(reader: treader);
begin
 shadow_color:= reader.readinteger;
end;

procedure tfont.readdummy(reader: treader);
begin
 reader.readinteger();
end;

procedure tfont.setlocalprops(const avalue: fontlocalpropsty);
begin
 if flocalprops <> avalue then begin
  flocalprops:= avalue;
  if ftemplate <> nil then begin
   settemplateinfo(ftemplate.template.fi);
  end;
 end;
end;

procedure tfont.defineproperties(filer: tfiler);
begin
// inherited; //no dummy necessary because of localprops
 filer.defineproperty('dummy',@readdummy,nil,false);
 filer.defineproperty('colorshadow',{$ifdef FPC}@{$endif}readcolorshadow,
                                                                  nil,false);
end;

procedure tfont.assign(source: tpersistent);
begin
 if source <> self then begin
  if source is tfont then begin
   assignproperties(tfont(source),true);
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tfont.updatehandlepo;
begin
 fhandlepo:= @finfopo^.handles[
    {$ifdef FPC}longword{$else}byte{$endif}(finfopo^.baseinfo.style) and
                    fontstylehandlemask];
end;

procedure tfont.setstyle(const Value: fontstylesty);
begin
 include(flocalprops,flp_style);
 if finfopo^.baseinfo.style <> value then begin
  finfopo^.baseinfo.style := Value;
  updatehandlepo;
  dochanged([cs_font],false);
 end;
end;

procedure tfont.releasehandles(const nochanged: boolean = false);
var
 int1: integer;
 bo1: boolean;
 fo1: fontnumty;
begin
 bo1:= false;
 for int1:= 0 to high(finfopo^.handles) do begin
  fo1:= finfopo^.handles[int1];
  if fo1 <> 0 then begin
   bo1:= true;
   releasefont(fo1);
  end;
 end;
 if bo1 then begin
  fillchar(finfopo^.handles,sizeof(finfopo^.handles),0);
  dochanged([cs_font,cs_fonthandle],nochanged);
 end
 else begin
  dochanged([cs_font],nochanged);
 end;
end;

function tfont.getcolor: colorty;
begin
 result:= finfopo^.baseinfo.color;
end;

function tfont.getcolorselect: colorty;
begin
 result:= finfopo^.baseinfo.colorselect;
end;

function tfont.getheight: integer;
begin
 result:= (finfopo^.baseinfo.height + fontsizeroundvalue) shr fontsizeshift;
end;

function tfont.getheightflo: flo64;
begin
 result:= finfopo^.baseinfo.height / (1 shl fontsizeshift);
end;

procedure tfont.setheight(avalue: integer);
begin
 include(flocalprops,flp_height);
 if avalue < 0 then begin
  avalue:= 0;
 end;
 if finfopo^.baseinfo.height <> avalue then begin
  finfopo^.baseinfo.height:= avalue shl fontsizeshift;
  releasehandles;
 end;
end;

procedure tfont.setheightflo(avalue: flo64);
begin
 include(flocalprops,flp_height);
 if avalue < 0 then begin
  avalue:= 0;
 end;
// if finfopo^.baseinfo.height <> avalue then begin
  finfopo^.baseinfo.height:= round(avalue * (1 shl fontsizeshift));
  releasehandles;
// end;
end;

function tfont.getwidth: integer;
begin
 result:= (finfopo^.baseinfo.width + fontsizeroundvalue) shr fontsizeshift;
end;

procedure tfont.setwidth(avalue: integer);
begin
 include(flocalprops,flp_width);
 if avalue < 0 then begin
  avalue:= 0;
 end;
 if finfopo^.baseinfo.width <> avalue then begin
  finfopo^.baseinfo.width:= avalue shl fontsizeshift;
  releasehandles;
 end;
end;

function tfont.getstyle: fontstylesty;
begin
 result:= finfopo^.baseinfo.style;
end;

function tfont.getname: string;
begin
 result:= finfopo^.baseinfo.name;
end;

procedure tfont.setname(const Value: string);
begin
 if finfopo^.baseinfo.name <> value then begin
  finfopo^.baseinfo.name := trim(Value);
  releasehandles;
 end;
end;

function tfont.getoptions: fontoptionsty;
begin
 result:= finfopo^.baseinfo.options;
end;

procedure tfont.setoptions(const avalue: fontoptionsty);
begin
 include(flocalprops,flp_options);
 if finfopo^.baseinfo.options <> avalue then begin
  finfopo^.baseinfo.options:=
                           checkfontoptions(avalue,finfopo^.baseinfo.options);
  releasehandles;
 end;
end;

function tfont.getrotation: real;
begin
 result:= finfopo^.rotation;
end;

procedure tfont.setrotation(const avalue: real);
begin
 if finfopo^.rotation <> avalue then begin
  finfopo^.rotation:= avalue;
  releasehandles(true);
 end;
end;

function tfont.getxscale: real;
begin
 result:= finfopo^.baseinfo.xscale;
end;

procedure tfont.setxscale(const avalue: real);
begin
 include(flocalprops,flp_xscale);
 if finfopo^.baseinfo.xscale <> avalue then begin
  finfopo^.baseinfo.xscale:= avalue;
  releasehandles;
 end;
end;

function tfont.getcharset: string;
begin
 result:= finfopo^.baseinfo.charset;
end;

procedure tfont.setcharset(const Value: string);
begin
 if finfopo^.baseinfo.charset <> value then begin
  finfopo^.baseinfo.charset:= trim(Value);
  releasehandles;
 end;
end;

     //icanvas
procedure tfont.gcneeded(const sender: tcanvas);
var
 gc: gcty;
 err: gdierrorty;
begin
 fillchar(gc,sizeof(gcty),0);
 gc.kind:= bmk_rgb; //default
// gdi_lock;
 err:= sender.creategc(0,gck_screen,gc);
// gdi_unlock;
 gdierror(err,self);
 sender.linktopaintdevice(0,gc,{nullsize,}nullpoint);
end;
{
function tfont.getmonochrome: boolean;
begin
 result:= false;
end;
}
function tfont.getkind: bitmapkindty;
begin
 result:= bmk_rgb;
end;

function tfont.getsize: sizety;
begin
 result:= nullsize;
end;

function tfont.getbold: boolean;
begin
 result:= fs_bold in style;
end;

procedure tfont.setbold(const avalue: boolean);
begin
 if avalue then begin
  style:= style + [fs_bold];
 end
 else begin
  style:= style - [fs_bold];
 end;
end;

function tfont.getitalic: boolean;
begin
 result:= fs_italic in style;
end;

procedure tfont.setitalic(const avalue: boolean);
begin
 if avalue then begin
  style:= style + [fs_italic];
 end
 else begin
  style:= style - [fs_italic];
 end;
end;

function tfont.getunderline: boolean;
begin
 result:= fs_underline in style;
end;

procedure tfont.setunderline(const avalue: boolean);
begin
 if avalue then begin
  style:= style + [fs_underline];
 end
 else begin
  style:= style - [fs_underline];
 end;
end;

function tfont.getstrikeout: boolean;
begin
 result:= fs_strikeout in style;
end;

procedure tfont.setstrikeout(const avalue: boolean);
begin
 if avalue then begin
  style:= style + [fs_strikeout];
 end
 else begin
  style:= style - [fs_strikeout];
 end;
end;

procedure tfont.scale(const ascale: real);
begin
 height:= round(height * ascale);
 width:= round(width * ascale);
end;

procedure tfont.getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
begin
 //dummy
end;

procedure tfont.settemplate(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftemplate));
 if (avalue <> nil) and not (csreading in avalue.componentstate) then begin
  assign(avalue);
  dochanged([],false);
 end;
end;

procedure tfont.settemplateinfo(const ainfo: basefontinfoty);
var
 changed1: canvasstatesty = [];
begin
 with finfopo^.baseinfo do begin
  if not (flp_color in flocalprops) then begin
   if color <> ainfo.color then begin
    color:= ainfo.color;
    include(changed1,cs_fontcolor);
   end;
  end;
  if not (flp_colorbackground in flocalprops) then begin
   if colorbackground <> ainfo.colorbackground then begin
    colorbackground:= ainfo.colorbackground;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_colorselect in flocalprops) then begin
   if colorselect <> ainfo.colorselect then begin
    colorselect:= ainfo.colorselect;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_colorselectbackground in flocalprops) then begin
   if colorselectbackground <> ainfo.colorselectbackground then begin
    colorselectbackground:= ainfo.colorselectbackground;
    include(changed1,cs_fontcolorbackground);
   end;
  end;
  if not (flp_shadow_color in flocalprops) then begin
   if shadow_color <> ainfo.shadow_color then begin
    shadow_color:= ainfo.shadow_color;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_shadow_shiftx in flocalprops) then begin
   if shadow_shiftx <> ainfo.shadow_shiftx then begin
    shadow_shiftx:= ainfo.shadow_shiftx;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_shadow_shifty in flocalprops) then begin
   if shadow_shifty <> ainfo.shadow_shifty then begin
    shadow_shifty:= ainfo.shadow_shifty;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_gloss_color in flocalprops) then begin
   if gloss_color <> ainfo.gloss_color then begin
    gloss_color:= ainfo.gloss_color;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_gloss_shiftx in flocalprops) then begin
   if gloss_shiftx <> ainfo.gloss_shiftx then begin
    gloss_shiftx:= ainfo.gloss_shiftx;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_gloss_shifty in flocalprops) then begin
   if gloss_shifty <> ainfo.gloss_shifty then begin
    gloss_shifty:= ainfo.gloss_shifty;
    include(changed1,cs_fonteffect);
   end;
  end;

  if not (flp_grayed_color in flocalprops) then begin
   if grayed_color <> ainfo.grayed_color then begin
    grayed_color:= ainfo.grayed_color;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_grayed_colorshadow in flocalprops) then begin
   if grayed_colorshadow <> ainfo.grayed_colorshadow then begin
    grayed_colorshadow:= ainfo.grayed_colorshadow;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_grayed_shifty in flocalprops) then begin
   if grayed_shiftx <> ainfo.grayed_shiftx then begin
    grayed_shiftx:= ainfo.grayed_shiftx;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_grayed_shifty in flocalprops) then begin
   if grayed_shifty <> ainfo.grayed_shifty then begin
    grayed_shifty:= ainfo.grayed_shifty;
    include(changed1,cs_fonteffect);
   end;
  end;
  if not (flp_xscale in flocalprops) then begin
   if (xscale <> 1) and (xscale <> ainfo.xscale) then begin
    xscale:= ainfo.xscale;
    include(changed1,cs_fonthandle);
   end;
  end;
  if not (flp_style in flocalprops) then begin
   if style <> ainfo.style then begin
    style:= ainfo.style;
    updatehandlepo();
    include(changed1,cs_font);
   end;
  end;

  if not (flp_height in flocalprops) then begin
   if (ainfo.height <> 0) and (height <>
                          (ainfo.height shl fontsizeshift)) then begin
    height:= ainfo.height shl fontsizeshift;
    include(changed1,cs_fonthandle);
   end;
  end;

  if not (flp_width in flocalprops) then begin
   if (ainfo.width <> 0) and (width <>
                             (ainfo.width shl fontsizeshift)) then begin
    width:= ainfo.width shl fontsizeshift;
    include(changed1,cs_fonthandle);
   end;
  end;
  if not (flp_extraspace in flocalprops) then begin
   if extraspace <> ainfo.extraspace then begin
    extraspace:= ainfo.extraspace;
    include(changed1,cs_font);
   end;
  end;
  if not (flp_name in flocalprops) then begin
   if (ainfo.name <> '') and (name <> ainfo.name) then begin
    name:= ainfo.name;
    include(changed1,cs_fonthandle);
   end;
  end;
  if not (flp_charset in flocalprops) then begin
   if charset <> ainfo.charset then begin
    charset:= ainfo.charset;
    include(changed1,cs_fonthandle);
   end;
  end;
  if not (flp_options in flocalprops) then begin
   if (ainfo.options <> []) and (options <> ainfo.options) then begin
    options:= ainfo.options;
    include(changed1,cs_fonthandle);
   end;
  end;

  if changed1 <> [] then begin
   if cs_fonthandle in changed1 then begin
    releasehandles(true);
    include(changed1,cs_font);
   end;
   dochanged(changed1,true);
  end;
 end;
end;

function tfont.iscolorstored: boolean;
begin
 result:= (ftemplate = nil) and (finfopo^.baseinfo.color <> cl_default) or
                                           (flp_color in flocalprops);
end;

function tfont.iscolorbackgroundstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.colorbackground <> cl_default) or
                                         (flp_colorbackground in flocalprops);
end;

function tfont.iscolorselectstored: boolean;
begin
 result:= (ftemplate = nil) and (finfopo^.baseinfo.colorselect <> cl_default) or
                                           (flp_colorselect in flocalprops);
end;

function tfont.iscolorselectbackgroundstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.colorselectbackground <> cl_default) or
                                    (flp_colorselectbackground in flocalprops);
end;

function tfont.isshadow_colorstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.shadow_color <> cl_none) or
                                           (flp_shadow_color in flocalprops);
end;

function tfont.isshadow_shiftxstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.shadow_shiftx <> 1) or
                                           (flp_shadow_shiftx in flocalprops);
end;

function tfont.isshadow_shiftystored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.shadow_shifty <> 1) or
                                           (flp_shadow_shifty in flocalprops);
end;

function tfont.isgloss_colorstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.gloss_color <> cl_none) or
                                           (flp_gloss_color in flocalprops);
end;

function tfont.isgloss_shiftxstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.gloss_shiftx <> -1) or
                                           (flp_gloss_shiftx in flocalprops);
end;

function tfont.isgloss_shiftystored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.gloss_shifty <> -1) or
                                           (flp_gloss_shifty in flocalprops);
end;

function tfont.isgrayed_colorstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.grayed_color <> cl_grayed) or
                                           (flp_grayed_color in flocalprops);
end;

function tfont.isgrayed_colorshadowstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.grayed_colorshadow <> cl_grayedshadow) or
                                      (flp_grayed_colorshadow in flocalprops);
end;

function tfont.isgrayed_shiftxstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.grayed_shifty <> 1) or
                                           (flp_grayed_shifty in flocalprops);
end;

function tfont.isgrayed_shiftystored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.grayed_shifty <> 1) or
                                           (flp_grayed_shifty in flocalprops);
end;

function tfont.isxscalestored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.xscale <> 1) or (flp_xscale in flocalprops);
end;

function tfont.isstylestored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.style <> []) or (flp_style in flocalprops);
end;

function tfont.isheightstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.height <> 0) or (flp_height in flocalprops);
end;

function tfont.iswidthstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.width <> 0) or (flp_width in flocalprops);
end;

function tfont.isextraspacestored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.extraspace <> 0) or
                                    (flp_extraspace in flocalprops);
end;

function tfont.isnamestored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.name <> '') or (flp_name in flocalprops);
end;

function tfont.ischarsetstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.charset <> '') or (flp_charset in flocalprops);
end;

function tfont.isoptionsstored: boolean;
begin
 result:= (ftemplate = nil) and
          (finfopo^.baseinfo.options <> []) or (flp_options in flocalprops);
end;

procedure tfont.objectevent(const sender: tobject; const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (ftemplate <> nil) and
                                     (ftemplate = sender) then begin
  settemplateinfo(tfontcomp(sender).template.fi);
  dochanged([],false);
 end;
end;

{ tcanvasfont }

constructor tcanvasfont.create(const acanvas: tcanvas);
begin
 fcanvas:= acanvas;
 fgdifuncs:= fcanvas.getgdifuncs;
 finfopo:= @fcanvas.fvaluepo^.font;
 inherited create;
end;

procedure tcanvasfont.dochanged(const changed: canvasstatesty;
                                               const nochange: boolean);
begin
// inherited;
 fcanvas.valueschanged(changed);
end;

function tcanvasfont.gethandle: fontnumty;
begin
 if fhandlepo^ = 0 then begin
  createhandle(fcanvas);
 end;
 result:= fhandlepo^;
// result:= gethandleforcanvas(fcanvas);
end;

procedure tcanvasfont.assignproperties(const source: tfont;
               const ahandles: boolean);
begin
 inherited assignproperties(source,ahandles and
                           (source.finfopo^.gdifuncs = fgdifuncs));
end;

{ tcanvas }

constructor tcanvas.create(const user: tobject; const intf: icanvas);
begin
 fdrawinfo.gc.gdifuncs:= getgdifuncs; //default
 fdrawinfo.gc.fontgdifuncs:= fdrawinfo.gc.gdifuncs;
 fuser:= user;
 fintf:= pointer(intf);
 with fvaluestack do begin
  setlength(stack,1);
  count:= 1;
  fvaluepo:= @stack[0];
 end;
 ffont:= createfont;
 initflags(self);
 init;
end;

destructor tcanvas.destroy;
var
 int1: integer;
begin
 inherited;
 unlink; //deinit, unregister defaultfont
 ffont.free;
 freebuffer(fdrawinfo.buffer);
 for int1:= 0 to high(fgclinksto) do begin
  removeitem(pointerarty(tcanvas(fgclinksto[int1]).fgclinksfrom),self);
 end;
 for int1:= 0 to high(fgclinksfrom) do begin
  removeitem(pointerarty(tcanvas(fgclinksfrom[int1]).fgclinksto),self);
 end;
end;

function tcanvas.creategc(const apaintdevice: paintdevicety;
               const akind: gckindty;
               var gc: gcty; const aprintername: msestring = ''): gdierrorty;
begin
 with fdrawinfo.creategc do begin
  paintdevice:= apaintdevice;
  kind:= akind;
  printernamepo:= @aprintername;
  contextinfopo:= getcontextinfopo;
  gcpo:= @gc;
  getgdifuncs^[gdf_creategc](fdrawinfo);
  if gc.fontgdifuncs = nil then begin
   gc.fontgdifuncs:= gc.gdifuncs;
  end;
  result:= error;
 end;
end;

procedure tcanvas.registergclink(const dest: tcanvas);
begin
 adduniqueitem(pointerarty(dest.fgclinksto),self);
 adduniqueitem(pointerarty(fgclinksfrom),dest);
end;

procedure tcanvas.unregistergclink(const dest: tcanvas);
begin
 removeitem(pointerarty(dest.fgclinksto),self);
 removeitem(pointerarty(fgclinksfrom),dest);
end;

procedure tcanvas.gcdestroyed(const sender: tcanvas);
begin
 //dummy
end;

function tcanvas.createfont: tcanvasfont;
begin
 result:= tcanvasfont.create(self);
end;

class function tcanvas.getclassgdifuncs: pgdifunctionaty;
begin
 result:= getdefaultgdifuncs;
end;

function tcanvas.getgdifuncs: pgdifunctionaty;
begin
 result:= getclassgdifuncs;
// result:= gui_getgdifuncs;
end;

procedure tcanvas.error(nr: gdierrorty; const text: msestring);
begin
 gdierror(nr,fuser,text);
end;

function tcanvas.lock: boolean;
begin
 result:= not gdi_locked();
 if result then begin
  gdi_lock();
 end;
{
 with application do begin
  result:= not gdilocked();
  if result then begin
   lockgdi();
  end;
 end;
}
end;

procedure tcanvas.unlock;
begin
 gdi_unlock();
// application.unlockgdi();
end;

procedure tcanvas.doflush;
begin
 fdrawinfo.gc.gdifuncs^[gdf_flush](fdrawinfo);
 gui_flushgdi;
end;

procedure tcanvas.gdi(const func: gdifuncty);
begin
 if lock then begin
  try
   fdrawinfo.gc.gdifuncs^[func](fdrawinfo);
   if flushgdi then begin
    doflush();
   end;
  finally
   unlock;
  end;
 end
 else begin
  fdrawinfo.gc.gdifuncs^[func](fdrawinfo);
  if flushgdi then begin
   doflush();
  end;
 end;
end;

procedure tcanvas.checkrect(const rect: rectty);
begin
 if (rect.cx < 0) or (rect.cy < 0) then begin
  error(gde_invalidrect,'');
 end;
end;


procedure tcanvas.intparametererror(value: integer; const text: msestring);
begin
 error(gde_parameter,text + ' ' + inttostrmse(value));
end;

procedure tcanvas.initgcvalues;
begin
 gccolorbackground:= cl_none;
 gccolorforeground:= cl_none;
 gcoptions:= [];
 gcfonthandle1:= 0;
 fstate:= fstate - changedmask;
end;

procedure tcanvas.initgcstate;
begin
 initgcvalues;
end;

procedure tcanvas.finalizegcstate;
begin
 //dummy
end;

//var
// gcident: longword;

procedure tcanvas.linktopaintdevice(apaintdevice: paintdevicety;
               const gc: gcty; const cliporigin: pointty);
var
 rea1: real;
 int1: integer;
 func1: pgdifunctionaty;
 func2: pgdifunctionaty;
begin
 resetpaintedflag;
 if (fdrawinfo.gc.handle <> 0) then begin
  for int1:= 0 to high(fgclinksto) do begin
   fgclinksto[int1].gcdestroyed(self);
  end;
  gdi(gdf_destroygc);
 end;
 fdrawinfo.paintdevice:= apaintdevice;
 rea1:= fdrawinfo.gc.ppmm;
 func1:= fdrawinfo.gc.gdifuncs;
 func2:= fdrawinfo.gc.fontgdifuncs;
 fdrawinfo.gc:= gc;
 if fdrawinfo.gc.fontgdifuncs = nil then begin
  fdrawinfo.gc.fontgdifuncs:= fdrawinfo.gc.gdifuncs;
 end;
 fdrawinfo.gc.ppmm:= rea1;                //restore
 if fdrawinfo.gc.gdifuncs = nil then begin
  fdrawinfo.gc.gdifuncs:= func1;         //restore in case of unlink
  fdrawinfo.gc.fontgdifuncs:= func2;     //restore in case of unlink
 end;
 updatecliporigin(cliporigin);
 if gc.handle <> 0 then begin
  gdi(gdf_setcliporigin);
 end;
 if fdefaultfont <> 0 then begin
  releasefont(fdefaultfont);
  fdefaultfont:= 0;
 end;
 if gc.handle <> 0 then begin
  initgcstate;
 end
 else begin
  finalizegcstate;
 end;
end;

procedure tcanvas.unlink;
begin
 reset;
 gdi_lock;
 try
  linktopaintdevice(0,nullgc,{nullsize,}nullpoint);
 finally
  gdi_unlock;
 end;
end;

procedure tcanvas.initdrawinfo(var adrawinfo: drawinfoty);
begin
 with fdrawinfo do begin
  adrawinfo.paintdevice:= paintdevice;
  adrawinfo.gc:= gc;
 end;
end;

//
// save stack, properties
//

procedure tcanvas.init;

 procedure initvalues(var values: canvasvaluesty);
 begin
  with values do begin
   if icanvas(fintf).getkind = bmk_mono then begin
    color:= cl_1;
    colorbackground:= cl_0;
    font.baseinfo.color:= cl_1;
    font.baseinfo.colorbackground:= cl_transparent;
   end
   else begin
    color:= cl_black;
    colorbackground:= cl_transparent;
    font.baseinfo.color:= cl_default;
    font.baseinfo.colorbackground:= cl_default;
   end;
   rasterop:= rop_copy;
  end;
 end;

begin
 fdrawinfo.gc.ppmm:= defaultppmm;
 restore(0);
// reset;
 initvalues(fvaluestack.stack[0]);
 initvalues(fvaluestack.stack[1]);
end;

procedure tcanvas.reset;
begin
 restore(0);
 fstate:= fstate - changedmask;
// clipregion:= 0;
// origin:= nullpoint;
end;

function tcanvas.save: integer;
var
 int1,int2: integer;

begin
// if fdrawinfo.gc.handle <> 0 then begin
//  checkgcstate([]); //update pending changes
// end;
 with fvaluestack do begin
  result:= count-1;
  if count >= length(stack) then begin
   setlength(stack,count+1);
  end;
  if count > 0 then begin
   system.move(stack[count-1],stack[count],sizeof(canvasvaluesty));
  end
  else begin
   error(gde_invalidsaveindex,'save 0');
  end;
  fvaluepo:= @stack[count];
  for int1:= 0 to high(fvaluepo^.font.handles) do begin
   int2:= fvaluepo^.font.handles[int1];
   if int2 <> 0 then begin
    addreffont(int2);
   end;
  end;
  stringaddref(fvaluepo^.font.baseinfo.name);
  stringaddref(fvaluepo^.font.baseinfo.charset);
  updatefontinfo;
  fvaluepo^.changed:= []; //reset changes
  inc(count);
 end;
end;

procedure tcanvas.freevalues(var values: canvasvaluesty);
var
 int1,int2: integer;
begin
 with values do begin
  if cs_regioncopy in changed then begin
   destroyregion(clipregion);
  end;
  for int1:= 0 to high(values.font.handles) do begin
   int2:= values.font.handles[int1];
   if int2 <> 0 then begin
    releasefont(int2);
    values.font.handles[int1]:= 0;
   end;
  end;
//  stringrelease({fvaluepo^.}font.name);
//  stringrelease({fvaluepo^.}font.charset);
 end;
 finalize(values);
end;

function tcanvas.restore(index: integer = -1): integer;
var
 int1: integer;
 achanged: canvasstatesty;
begin
 with fvaluestack do begin
  if index >= count then begin
   error(gde_invalidsaveindex,inttostrmse(index));
//index:= count-1;
  end;
  if index < 0 then begin
   if count < 2 then begin
    error(gde_invalidsaveindex,inttostrmse(index));
   end;
   index:= count - 2;
  end;
  achanged:= [];
  for int1:= count-1 downto index + 1 do begin
   achanged:= achanged + stack[int1].changed;
   freevalues(stack[int1]);
  end;
  fstate:= fstate - achanged * changedmask;
  fvaluepo:= @stack[index];
  updatefontinfo;
  count:= index + 1;
  if index = 0 then begin
   result:= save;
  end
  else begin
   result:= index;
  end;
 end;
end;

procedure tcanvas.valuechanged(value: canvasstatety);
begin
 include(fvaluepo^.changed,value);
 exclude(fstate,value);
end;

procedure tcanvas.valueschanged(values: canvasstatesty);
begin
 fvaluepo^.changed:= fvaluepo^.changed + values;
 fstate:= fstate - values;
end;

procedure tcanvas.setfont(const Value: tfont);
begin
 if ffont <> nil then begin
//  if value.fhandlepo^ = 0 then begin
//   value.createhandle(self);
//  end;
  ffont.assignproperties(value,true);
//  ffont.assign(Value);
 end;
end;

procedure tcanvas.updatefontinfo;
begin
 ffont.finfopo:= @fvaluepo^.font;
 ffont.updatehandlepo;
end;

//
// painting
//

function ispaintcolor(acolor: colorty): boolean; {$ifdef FPC}inline;{$endif}
begin
 result:= (acolor <> cl_transparent) and (acolor <> cl_none);
end;

procedure tcanvas.checkgcstate(state: canvasstatesty);
var
 values: gcvaluesty;
 bo1,bo2: boolean;
 po1: pfontdataty;
begin
 if fdrawinfo.gc.handle = 0 then begin
  gdi_lock;
  try
   icanvas(fintf).gcneeded(self);
  finally
   gdi_unlock;
  end;
  if fdrawinfo.gc.handle = 0 then begin
   gdierror(gde_invalidgc,fuser);
  end;
 end;
 if state = [cs_gc] then begin
  exit;
 end;
 include(fstate,cs_painted);
 inc(fdrawinfo.statestamp);
 values.mask:= [];

 if not (cs_clipregion in fstate) then begin
  values.clipregion:= fvaluepo^.clipregion;
  include(values.mask,gvm_clipregion);
  include(fstate,cs_clipregion);
 end;
 if not (cs_origin in fstate) then begin
  fdrawinfo.origin:= fvaluepo^.origin;
  include(fstate,cs_origin);
  exclude(fstate,cs_brushorigin);
 end;
 if not (cs_rasterop in fstate) then begin
  values.rasterop:= fvaluepo^.rasterop;
  include(values.mask,gvm_rasterop);
  include(fstate,cs_rasterop);
 end;
 with fdrawinfo,gc do begin
  if not (cs_options in fstate) and (cs_options in state) then begin
   values.options:= fvaluepo^.options;
   if cao_smooth in values.options then begin
    include(drawingflags,df_smooth);
   end
   else begin
    exclude(drawingflags,df_smooth);
   end;
   include(values.mask,gvm_options);
   include(fstate,cs_options);
  end;
  bo2:= df_brush in drawingflags;
  drawingflags:= drawingflags - fillmodeinfoflags;

  if (cs_acolorforeground in state) then begin
   bo1:= (acolorforeground = cl_brushcanvas);
   if ((acolorforeground = cl_brush) or bo1) and (fvaluepo^.brush <> nil) then begin
    include(drawingflags,df_brush);
   end;
   if (df_brush in drawingflags) xor bo2 then begin
    include(values.mask,gvm_brushflag);
   end;
   if (df_brush in drawingflags) and not (cs_brushorigin in fstate) then begin
    include(fstate,cs_brushorigin);
    include(values.mask,gvm_brushorigin);
    values.brushorigin:= fvaluepo^.brushorigin;
   end;
   if acolorforeground <> gccolorforeground then begin
    if df_brush in drawingflags then begin
     with fvaluepo^.brush do begin
      if not (cs_brush in self.fstate) then begin
       include(values.mask,gvm_brush);
       values.brush:= fvaluepo^.brush;
      end;
      if getkind = bmk_mono then begin
       include(drawingflags,df_monochrome);
       include(state,cs_acolorbackground);
       if bo1 then begin //use canvas colors
        acolorforeground:= fvaluepo^.color;
        acolorbackground:= fvaluepo^.colorbackground;
       end
       else begin       //use brush colors
        acolorforeground:= fcolorforeground;
        acolorbackground:= fcolorbackground;
       end;
      end
      else begin
       exclude(drawingflags,df_monochrome);
      end;
     end;
     include(fstate,cs_brush);
    end;
   end;
   if acolorforeground <> gccolorforeground then begin
    if drawingflags * [df_brush,df_monochrome] <> [df_brush] then begin
     include(values.mask,gvm_colorforeground);
     if kind = bmk_gray then begin
      values.colorforeground:= graytopixel(acolorforeground);
     end
     else begin
      values.colorforeground:= colortopixel(acolorforeground);
     end;
    end;
    gccolorforeground:= acolorforeground;
    include(fstate,cs_acolorforeground);
   end;
  end;
  if (cs_acolorbackground in state) and (acolorbackground <> gccolorbackground) then begin
   include(values.mask,gvm_colorbackground);
   if kind = bmk_gray then begin
    values.colorbackground:= graytopixel(acolorbackground);
   end
   else begin
    values.colorbackground:= colortopixel(acolorbackground);
   end;
   gccolorbackground:= acolorbackground;
  end;
  if ispaintcolor(gccolorbackground) then begin
   include(drawingflags,df_opaque);
  end
  else begin
   exclude(drawingflags,df_opaque);
  end;
  if cs_font in state then begin
   if (afonthandle1 <> gcfonthandle1) then begin
    include(values.mask,gvm_font);
    values.fontnum:= afonthandle1;
    po1:= getfontdata(afonthandle1);
    values.fontdata:= po1;
    with po1^ do begin
     values.font:= font;
     if (df_highresfont in fdrawinfo.gc.drawingflags) then begin
      checkhighresfont(po1,fdrawinfo);
     end;
    end;
    gcfonthandle1:= afonthandle1;
   end;
   include(drawingflags,df_monochrome);
  end;

  state:= (state - fstate) * linecanvasstates; //update lineinfos
  if state <> [] then begin
   values.lineinfo:= fvaluepo^.lineinfo;
   if length(dashes) > 0 then begin
    include(fdrawinfo.gc.drawingflags,df_dashed);
   end
   else begin
    exclude(fdrawinfo.gc.drawingflags,df_dashed);
   end;
   fstate:= fstate + state;
   if cs_linewidth in state then include(values.mask,gvm_linewidth);
   if cs_dashes in state then include(values.mask,gvm_dashes);
   if cs_capstyle in state then include(values.mask,gvm_capstyle);
   if cs_joinstyle in state then include(values.mask,gvm_joinstyle);
   fstate:= fstate + state;
  end;
  if values.mask <> [] then begin
   fdrawinfo.gcvalues:= @values;
   gdi(gdf_changegc);
  end;
 end;
end;

function tcanvas.getgchandle: ptruint;
begin
 checkgcstate([cs_gc]);
 result:= fdrawinfo.gc.handle;
end;

function tcanvas.getimage(const bgr: boolean): maskedimagety;
begin
 fillchar(result,sizeof(result),0);
 icanvas(fintf).getcanvasimage(bgr,result);
end;

function tcanvas.checkforeground(acolor: colorty; lineinfo: boolean): boolean;
begin
 with fdrawinfo do begin
  if (acolor = cl_default) or (acolor = cl_parent) then begin
   acolorforeground:= fvaluepo^.color;
  end
  else begin
   acolorforeground:= acolor;
  end;
  if ispaintcolor(acolorforeground) then begin
   if lineinfo then begin
    if length(dashes) > 0 then begin
     acolorbackground:= fvaluepo^.colorbackground;
     checkgcstate([cs_options,cs_acolorforeground,cs_acolorbackground]+
                                                          linecanvasstates);
    end
    else begin
     checkgcstate([cs_options,cs_acolorforeground]+linecanvasstates);
    end;
   end
   else begin
    checkgcstate([cs_options,cs_acolorforeground]);
   end;
   result:= true;
  end
  else begin
   result:= false;
  end;
 end;
end;

procedure tcanvas.checkcolors;
begin
 with fdrawinfo do begin
  acolorforeground:= fvaluepo^.color;
  acolorbackground:= fvaluepo^.colorbackground;
  checkgcstate([cs_acolorforeground,cs_acolorbackground]);
 end;
end;

procedure tcanvas.internalcopyarea(asource: tcanvas; const asourcerect: rectty;
                           const adestrect: rectty; acopymode: rasteropty;
                           atransparentcolor: colorty;
                           amask: tsimplebitmap;
                           const amaskpos: pointty;
                           aalignment: alignmentsty;
                           const atileorigin: pointty;
                           const aopacity: colorty); //cl_none -> opaque

                           //todo: use serverside tiling
                           //      limit stretched rendering to cliprects
var
 srect,drect,rect1: rectty;
 spoint,dpoint,tileorig: pointty;
 startx: integer;
 endx,endy: integer;
// endcx,endcy: integer;
 stepx,stepy: integer;
 sourcex,sourcey: integer;
 int1{,int2}: integer;
// bo1,bo2: boolean;

 function checkmaskrect(var arect,brect: rectty): boolean;
 var
  rect2: rectty;
 begin
  rect2:= intersectrect(arect,mr(amaskpos,amask.size));
  if (rect2.cx < arect.cx) or (rect2.cy < arect.cy) then begin
                                                 //mask not big enough
   if (rect2.cx <= 0) or (rect2.cy <= 0) then begin
    result:= true;
    exit;
   end;
   brect.x:= brect.x + (rect2.x - arect.x) * brect.cx div arect.cx;
   brect.y:= brect.y + (rect2.y - arect.y) * brect.cy div arect.cy;
   brect.cx:= (brect.cx * rect2.cx) div arect.cx;
   brect.cy:= (brect.cy * rect2.cy) div arect.cy;
   arect:= rect2;
  end;
  result:= false;
 end;

var
 al1: alignmentsty;
begin
 if (asourcerect.cx <= 0) or (asourcerect.cy <= 0) or
    (adestrect.cx <= 0) or (adestrect.cy <= 0) then begin //no div 0
  exit;
 end;
 if (al_thumbnail in aalignment) and ((asourcerect.cx > adestrect.cx) or
          (asourcerect.cy > adestrect.cy)) then begin
  include(aalignment,al_fit);
 end;
 checkgcstate([]);  //gc must be valid
 if asource <> self then begin
  asource.checkgcstate([cs_gc]); //gc must be valid
 end;
 dpoint:= adestrect.pos;
 if aalignment * [al_fit{,al_tiled}] = [] then begin
  if not (al_stretchx in aalignment) then begin
   int1:= adestrect.cx - asourcerect.cx;
   if al_right in aalignment then begin
    dpoint.x:= dpoint.x + int1;
   end
   else begin
    if al_xcentered in aalignment then begin
     if int1 < 0 then begin
      dec(int1);
     end;
     dpoint.x:= dpoint.x + int1 div 2;
    end;
   end;
  end;
  if not (al_stretchy in aalignment) then begin
   int1:= adestrect.cy - asourcerect.cy;
   if al_bottom in aalignment then begin
    dpoint.y:= dpoint.y + int1;
   end
   else begin
    if al_ycentered in aalignment then begin
     if int1 < 0 then begin
      dec(int1);
     end;
     dpoint.y:= dpoint.y + int1 div 2;
    end;
   end;
  end;
 end;
 tileorig:= atileorigin;
 if al_tiled in aalignment then begin
  if aalignment * [al_xcentered,al_right] <> [] then begin
   tileorig.x:= dpoint.x;
  end;
  if aalignment * [al_ycentered,al_bottom] <> [] then begin
   tileorig.y:= dpoint.y;
  end;
  dpoint:= adestrect.pos;
 end;
 dpoint.x:= dpoint.x + fdrawinfo.origin.x;
 dpoint.y:= dpoint.y + fdrawinfo.origin.y;
 tileorig.x:= tileorig.x + fdrawinfo.origin.x;
 tileorig.y:= tileorig.y + fdrawinfo.origin.y;
 with asourcerect,asource.fvaluepo^ do begin
  spoint.x:= x + origin.x;
  spoint.y:= y + origin.y;
 end;
 rect1:= moverect(clipbox,fvaluepo^.origin);
 drect.size:= adestrect.size;
 if not msegraphutils.intersectrect(makerect(spoint,asourcerect.size),
      makerect(makepoint(0,0),icanvas(asource.fintf).getsize),srect) then begin
  exit;
 end;
 al1:= aalignment * [al_stretchx,al_stretchy,al_fit,al_tiled];
 if al1 = [] then begin //clip areas to paintdevice rect
  dpoint.x:= dpoint.x + srect.x - spoint.x;
  dpoint.y:= dpoint.y + srect.y - spoint.y;
  if not msegraphutils.intersectrect(makerect(dpoint,srect.size),
               rect1,drect) then begin
   exit;
  end;
  srect.x:= srect.x + drect.x - dpoint.x;
  srect.cx:= drect.cx;
  srect.y:= srect.y + drect.y - dpoint.y;
  srect.cy:= drect.cy;
 end
 else begin
  srect.pos:= spoint;
  srect.size:= asourcerect.size;
  drect.pos:= dpoint;
  if al1 = [al_stretchx] then begin
   drect.cy:= srect.cy;
  end;
  if al1 = [al_stretchy] then begin
   drect.cx:= srect.cx;
  end;
 end;
 if amask <> nil then begin
  if al_nomaskscale in aalignment then begin
   if checkmaskrect(drect,srect) then begin
    exit;
   end;
  end
  else begin
   if checkmaskrect(srect,drect) then begin
    exit;
   end;
  end;
 end;
 with fdrawinfo,copyarea do begin
  source:= asource;
  sourcerect:= @srect;
  destrect:= @drect;
  alignment:= aalignment;
  copymode:= acopymode;
  mask:= amask;
  if (srect.cx = 0) or (srect.cy = 0) then begin
   exit;
  end;
  if al_fit in aalignment then begin
   alignment:= alignment + [al_stretchx,al_stretchy];
   if srect.cy * drect.cx > srect.cx * drect.cy then begin //fit vert
    drect.cx:= (srect.cx * drect.cy) div srect.cy;
    int1:= adestrect.cx - drect.cx;
    if al_right in aalignment then begin
     drect.x:= drect.x + int1;
    end
    else begin
     if al_xcentered in aalignment then begin
      if int1 < 0 then begin
       dec(int1);
      end;
      drect.x:= drect.x + int1 div 2;
     end;
    end;
   end
   else begin
    drect.cy:= (srect.cy * drect.cx) div srect.cx;
    int1:= adestrect.cy - drect.cy;
    if al_bottom in aalignment then begin
     drect.y:= drect.y + int1;
    end
    else begin
     if al_ycentered in aalignment then begin
      if int1 < 0 then begin
       dec(int1);
      end;
      drect.y:= drect.y + int1 div 2;
     end;
    end;
   end;
  end;
  maskshift.x:=  -amaskpos.x;
  maskshift.y:=  -amaskpos.y;
  maskshiftscaled.x:= (maskshift.x*drect.cx) div srect.cx;
  maskshiftscaled.y:= (maskshift.y*drect.cy) div srect.cy;
  if aopacity = cl_none then begin
   longword(opacity):= maxopacity;
  end
  else begin
   opacity:= colortorgb(aopacity);
  end;

  if gc.kind <> source.fdrawinfo.gc.kind then begin //different colorformat
   include(gc.drawingflags,df_colorconvert);
   with fdrawinfo,gc do begin
    acolorforeground:= fvaluepo^.color;
    if source.fdrawinfo.gc.kind = bmk_mono then begin //monochrome to color or gray
     acolorbackground:= fvaluepo^.colorbackground;
     checkgcstate([cs_acolorforeground,cs_acolorbackground]);
    end
    else begin
     if gc.kind = bmk_mono then begin //color or gray to monochrome
      if atransparentcolor = cl_default then begin
       atransparentcolor:= fvaluepo^.colorbackground;
      end;
      if source.fdrawinfo.gc.kind = bmk_gray then begin
       transparentcolor:= graytopixel(atransparentcolor);
      end
      else begin
       transparentcolor:= colortopixel(atransparentcolor);
      end;
     end;
    end;
   end;
  end
  else begin
   exclude(gc.drawingflags,df_colorconvert);
  end;
 end;
 if al_tiled in aalignment then begin
  if msegraphutils.intersectrect(drect,rect1,rect1) then begin
   if not (al_stretchy in aalignment) then begin
    drect.cy:= srect.cy;
    if drect.y >= tileorig.y then begin
     drect.y:= tileorig.y + ((rect1.y - tileorig.y) div srect.cy) * srect.cy;
    end
    else begin
     drect.y:= tileorig.y - ((tileorig.y - rect1.y + srect.cy) div srect.cy) * srect.cy;
    end;
   end;
   if not (al_stretchx in aalignment) then begin
    drect.cx:= srect.cx;
    if drect.x >= tileorig.x then begin
     startx:= tileorig.x + ((rect1.x - tileorig.x) div srect.cx) * srect.cx;
    end
    else begin
     startx:= tileorig.x - ((tileorig.x - rect1.x + srect.cx) div srect.cx) * srect.cx;
    end;
   end
   else begin
    startx:= drect.x;
   end;
   stepx:= srect.cx;
   stepy:= srect.cy;
   endx:= rect1.x + rect1.cx;
   endy:= rect1.y + rect1.cy;
   sourcex:= srect.x;
   sourcey:= srect.y;
   if not (al_stretchy in aalignment) then begin
    int1:= drect.y - rect1.y;
    if int1 < 0 then begin
     dec(srect.y,int1);
     dec(drect.y,int1);
     inc(srect.cy,int1);
     drect.cy:= srect.cy;
    end;
   end;
   if al_stretchx in aalignment then begin
    int1:= 0;
   end
   else begin
    int1:= startx - rect1.x;
    if int1 > 0 then begin
     int1:= 0;
    end;
   end;
   repeat
    if not (al_stretchy in aalignment) then begin
     if drect.y + srect.cy > endy then begin
      srect.cy:= endy - drect.y;
     end;
     drect.cy:= srect.cy;
    end;
    drect.x:= startx;
    dec(srect.x,int1);
    dec(drect.x,int1);
    inc(srect.cx,int1);
    repeat
     if not (al_stretchx in aalignment) then begin
      if drect.x + srect.cx > endx then begin
       srect.cx:= endx - drect.x;
      end;
      drect.cx:= srect.cx;
     end;
     if (srect.cx > 0) and (srect.cy > 0) then begin
      gdi(gdf_copyarea);
     end;
     inc(drect.x,srect.cx);
     srect.cx:= stepx;
     srect.x:= sourcex;
    until (al_stretchx in aalignment) or (drect.x >= endx);
    inc(drect.y,srect.cy);
    srect.y:= sourcey;
    srect.cy:= stepy;
    drect.cy:= stepy;
   until (al_stretchy in aalignment) or (drect.y >= endy);
  end;
 end
 else begin
  gdi(gdf_copyarea);
 end;
 if amask <> nil then begin
  exclude(fstate,cs_clipregion);
 end;
end;

procedure tcanvas.copyarea(const asource: tcanvas; const asourcerect: rectty;
                           const adestpoint: pointty;
                           const acopymode: rasteropty = rop_copy;
                           const atransparentcolor: colorty = cl_default;
                           const aopacity: colorty = cl_none);
begin
 if cs_inactive in fstate then exit;
 internalcopyarea(asource,asourcerect,makerect(adestpoint,asourcerect.size),
              acopymode,atransparentcolor,nil,nullpoint,[],nullpoint,aopacity);
end;

procedure tcanvas.copyarea(const asource: tcanvas; const asourcerect: rectty;
              const adestrect: rectty; const alignment: alignmentsty = [];
              const acopymode: rasteropty = rop_copy;
              const atransparentcolor: colorty = cl_default;
              //atransparentcolor used for convert color to monochrome
              //cl_default -> colorbackground
              const aopacity: colorty = cl_none);
begin
 if cs_inactive in fstate then exit;
 internalcopyarea(asource,asourcerect,adestrect,
              acopymode,atransparentcolor,nil,nullpoint,alignment,
                                                  nullpoint,aopacity);
end;

procedure tcanvas.drawpoints(const apoints: array of pointty; const acolor: colorty;
                   first, acount: integer);
var
 int1,int2: integer;
 pointar: pointarty;
begin
 if cs_inactive in fstate then exit;
 if length(apoints) > 0 then begin
  if checkforeground(acolor,true) then begin
   with fdrawinfo.points do begin
    int1:= length(apoints) - first;
    if int1 < 0 then begin
     intparametererror(first,'drawpoints first');
    end;
    if acount < 0 then begin
     acount:= int1;
    end
    else begin
     if acount > int1 then begin
      intparametererror(acount,'drawponts acount');
     end;
    end;
    count:= 2*acount;
    setlength(pointar,count);
    int2:= 0;
    for int1:= first to first + acount - 1 do begin
     pointar[int2]:= apoints[int1];
     pointar[int2+1]:= apoints[int1];
     inc(int2,2);
    end;
    points:= @pointar[0];
   end;
   gdi(gdf_drawlinesegments);
  end;
 end;
end;

procedure tcanvas.drawpoint(const point: pointty;
                            const acolor: colorty = cl_default);
begin
 if cs_inactive in fstate then exit;
 drawpoints(point,acolor,0,1);
end;

procedure tcanvas.drawlines(const apoints: array of pointty;
                       const aclosed: boolean = false;
                       const acolor: colorty = cl_default;
                       const first: integer = 0; const acount: integer = -1);
                                                          //-1 -> all
var
 int1: integer;
begin
 if cs_inactive in fstate then exit;
 if length(apoints) > 0 then begin
  if checkforeground(acolor,true) then begin
   with fdrawinfo.points do begin
    int1:= length(apoints) - first;
    if int1 < 0 then begin
     intparametererror(first,'drawlines first');
    end;
    if acount < 0 then begin
     count:= int1;
    end
    else begin
     if acount > int1 then begin
      intparametererror(acount,'drawlines acount');
     end;
     count:= acount;
    end;
    int1:= count - 2;
    if (int1 > 0) and (apoints[int1].x = apoints[int1+1].x) and
                   (apoints[int1].y = apoints[int1+1].y) then begin
                   //coincident endpoints are not drawn on x11
     dec(count);
    end;
    closed:= aclosed;
    points:= @apoints[first];
   end;
   gdi(gdf_drawlines);
  end;
 end;
end;

procedure tcanvas.drawlines(const apoints: array of pointty;
                       const abreaks: array of integer; //ascending order
                       const aclosed: boolean = false;
                       const acolor: colorty = cl_default;
          const first: integer = 0; const acount: integer = -1);
var
 int1: integer;
 s,e: integer;
 e1: integer;
begin
 if cs_inactive in fstate then exit;
 if length(apoints) > 0 then begin
  if checkforeground(acolor,true) then begin
   int1:= length(apoints) - first;
   if int1 < 0 then begin
    intparametererror(first,'drawlines first');
   end;
   if acount < 0 then begin
    e1:= int1;
   end
   else begin
    if acount > int1 then begin
     intparametererror(acount,'drawlines acount');
    end;
    e1:= acount;
   end;

   s:= first;
   e1:= s + e1;
   int1:= 0;
   while int1 <= high(abreaks) do begin
    if abreaks[int1] > s then begin
     break;
    end;
    inc(int1);
   end;
   with fdrawinfo.points do begin
    closed:= false;
    repeat
     e:= e1;
     if (int1 <= high(abreaks)) and (abreaks[int1] < e) then begin
      e:= abreaks[int1];
      inc(int1);
     end;
     points:= @apoints[s];
     count:= e-s;
     if (first = 0) and (e = length(apoints)) then begin
      closed:= aclosed;
     end;
     gdi(gdf_drawlines);
     s:= e;
    until e = e1;
   end;
  end;
 end;
end;

procedure tcanvas.drawrect(const arect: rectty; const acolor: colorty = cl_default);
begin
 if cs_inactive in fstate then exit;
 with arect do begin
  drawlines([pos,makepoint(x+cx,y),makepoint(x+cx,y+cy),makepoint(x,y+cy)],
                          true,acolor);
 end;
end;

procedure tcanvas.drawcross(const arect: rectty; const acolor: colorty = cl_default;
                const alignment: alignmentsty = [al_xcentered,al_ycentered]);
var
 ar1: segmentarty;
begin
 if cs_inactive in fstate then exit;
 if (arect.cx > 0) and (arect.cy > 0) then begin
  setlength(ar1,2);
  with arect do begin
   with ar1[0] do begin
    a:= pos;
    b.x:= x + cx - 1;
    b.y:= y + cy - 1;
   end;
   with ar1[1] do begin
    a.x:= x;
    a.y:= ar1[0].b.y;
    b.x:= ar1[0].b.x;
    b.y:= y;
   end;
   drawlinesegments(ar1,acolor);
  end;
 end;
end;

procedure tcanvas.drawlinesegments(const apoints: array of segmentty;
               const acolor: colorty = cl_default);
begin
 if cs_inactive in fstate then exit;
 if length(apoints) > 0 then begin
  if (high(apoints) >= 0) and checkforeground(acolor,true) then begin
   with fdrawinfo.points do begin
    points:= @apoints[0];
    count:= length(apoints) * 2;
   end;
   gdi(gdf_drawlinesegments);
  end;
 end;
end;

procedure tcanvas.drawline(const startpoint,endpoint: pointty;
          const acolor: colorty = cl_default);
begin
 if cs_inactive in fstate then exit;
 drawlinesegments([segment(startpoint,endpoint)],acolor);
end;

procedure tcanvas.drawline(const startpoint: pointty; const length: sizety;
               const acolor: colorty = cl_default);
var
 seg1: segmentty;
begin
 if cs_inactive in fstate then exit;
 seg1.a:= startpoint;
 seg1.b.x:= seg1.a.x + length.cx;
 seg1.b.y:= seg1.a.y + length.cy;
 drawlinesegments([seg1],acolor);
end;

procedure tcanvas.drawvect(const startpoint: pointty;
                      const direction: graphicdirectionty;
                      const length: integer; out endpoint: pointty;
                      const acolor: colorty = cl_default);
var
 endpoint1: pointty;
begin
 if cs_inactive in fstate then exit;
 endpoint1:= startpoint;
 case direction of
  gd_right: inc(endpoint1.x,length);
  gd_up: dec(endpoint1.y,length);
  gd_left: dec(endpoint1.x,length);
  gd_down: inc(endpoint1.y,length);
  else begin
   endpoint:= endpoint1;
   exit;
  end;
 end;
 drawlinesegments([segment(startpoint,endpoint1)],acolor);
 endpoint:= endpoint1;
end;

procedure tcanvas.drawvect(const startpoint: pointty;
                     const direction: graphicdirectionty;
                     const length: integer; const acolor: colorty = cl_default);
var
 po1: pointty;
begin
 if cs_inactive in fstate then exit;
 drawvect(startpoint,direction,length,po1,acolor);
end;

procedure tcanvas.drawellipse(const def: rectty;
                                      const acolor: colorty = cl_default);
                             //def.pos = center, def.cx = width, def.cy = height
begin
 if cs_inactive in fstate then exit;
 if checkforeground(acolor,true) then begin
  fdrawinfo.rect.rect:= @def;
  gdi(gdf_drawellipse);
 end;
end;

procedure tcanvas.drawcircle(const center: pointty; const radius: integer;
                                          const acolor: colorty = cl_default);
var
 rect1: rectty;
begin
 rect1.pos:= center;
 rect1.cx:= 2*radius;
 rect1.cy:= rect1.cx;
 drawellipse(rect1,acolor);
end;

procedure tcanvas.drawellipse1(const def: rectty;
                                         const acolor: colorty = cl_default);
                          //def.pos = topleft, def.cx = width, def.cy = height
begin
 drawellipse(recenterrect(def),acolor);
end;

procedure tcanvas.drawarc(const def: rectty; const startang,extentang: real;
                              const acolor: colorty = cl_default);
begin
 if cs_inactive in fstate then exit;
 if checkforeground(acolor,true) then begin
  fdrawinfo.arc.rect:= @def;
  fdrawinfo.arc.startang:= startang;
  fdrawinfo.arc.extentang:= extentang;
  gdi(gdf_drawarc);
 end;
end;

procedure tcanvas.drawarc(const center: pointty; const radius: integer;
                              const startang,extentang: real;
                              const acolor: colorty = cl_default);
var
 rect1: rectty;
begin
 rect1.pos:= center;
 rect1.cx:= 2*radius;
 rect1.cy:= rect1.cx;
 drawarc(rect1,startang,extentang,acolor);
end;

procedure tcanvas.drawarc1(const def: rectty; const startang,extentang: real;
                              const acolor: colorty = cl_default);
begin
 drawarc(recenterrect(def),startang,extentang,acolor);
end;

procedure tcanvas.fillrect(const arect: rectty;
                           const acolor: colorty = cl_default;
                           const linecolor: colorty = cl_none);
var
 rect1: rectty;
begin
 if cs_inactive in fstate then exit;
 if checkforeground(acolor,false) then begin
  with fdrawinfo.rect do begin
   rect:= @arect;
   if (arect.cx < 0) then begin
    rect:= @rect1;
    rect1.x:= arect.x + arect.cx + 1;
    rect1.cx:= -arect.cx;
    if arect.cy < 0 then begin
     rect1.y:= arect.y + arect.cy + 1;
     rect1.cy:= -arect.cy;
    end
    else begin
     rect1.y:= arect.y;
     rect1.cy:= arect.cy;
    end;
   end
   else begin
    if arect.cy < 0 then begin
     rect:= @rect1;
     rect1.y:= arect.y + arect.cy + 1;
     rect1.cy:= -arect.cy;
     rect1.x:= arect.x;
     rect1.cx:= arect.cx;
    end;
   end;
  end;
  gdi(gdf_fillrect);
 end;
 if (linecolor <> cl_none) then begin
  drawrect(arect,linecolor);
 end;
end;

procedure tcanvas.fillellipse(const def: rectty;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none);
begin
 if (cs_inactive in fstate) or (def.cx = 0) or (def.cy = 0) then exit;
 if checkforeground(acolor,false) then begin
  with fdrawinfo.rect do begin
   rect:= @def;
  end;
  gdi(gdf_fillellipse);
 end;
 if (linecolor <> cl_none) then begin
  drawellipse(def,linecolor);
 end;
end;

procedure tcanvas.fillcircle(const center: pointty; const radius: integer;
                        const acolor: colorty = cl_default;
                        const linecolor: colorty = cl_none);
var
 rect1: rectty;
begin
 rect1.pos:= center;
 rect1.cx:= 2*radius;
 rect1.cy:= rect1.cx;
 fillellipse(rect1,acolor,linecolor);
end;

procedure tcanvas.fillellipse1(const def: rectty;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none);
begin
 fillellipse(recenterrect(def),acolor,linecolor);
end;

procedure tcanvas.fillarc(const def: rectty; const startang: real;
                          const extentang: real; const acolor: colorty;
                          const pieslice: boolean);
begin
 if cs_inactive in fstate then exit;
 if checkforeground(acolor,false) then begin
  fdrawinfo.arc.rect:= @def;
  fdrawinfo.arc.startang:= startang;
  fdrawinfo.arc.extentang:= extentang;
  fdrawinfo.arc.pieslice:= pieslice;
  gdi(gdf_fillarc);
 end;
end;

procedure tcanvas.getarcinfo(out startpo,endpo: pointty);
var
 stopang: real;
begin
 with fdrawinfo,arc,rect^ do begin
  stopang:= (startang+extentang);
  startpo.x:= (round(cos(startang)*cx) div 2) + x;
  startpo.y:= (round(-sin(startang)*cy) div 2) + y;
  endpo.x:= (round(cos(stopang)*cx) div 2) + x;
  endpo.y:= (round(-sin(stopang)*cy) div 2) + y;
 end;
end;

procedure tcanvas.fillarcchord(const def: rectty; const startang: real;
               const extentang: real; const acolor: colorty = cl_default;
               const linecolor: colorty = cl_none);
var
 startpo,endpo: pointty;
begin
 if cs_inactive in fstate then exit;
 fillarc(def,startang,extentang,acolor,false);
 if (linecolor <> cl_none) then begin
  fdrawinfo.arc.rect:= @def; //necessary for 64 bit
  getarcinfo(startpo,endpo);
  drawline(startpo,endpo,linecolor);
  drawarc(def,startang,extentang,linecolor);
 end;
end;

procedure tcanvas.fillarcchord(const center: pointty; const radius: integer;
                              const startang,extentang: real;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none);
var
 rect1: rectty;
begin
 rect1.pos:= center;
 rect1.cx:= 2*radius;
 rect1.cy:= rect1.cx;
 fillarcchord(rect1,startang,extentang,acolor,linecolor);
end;

procedure tcanvas.fillarcchord1(const def: rectty; const startang: real;
               const extentang: real; const acolor: colorty = cl_default;
               const linecolor: colorty = cl_none);
begin
 fillarcchord(recenterrect(def),startang,extentang,acolor,linecolor);
end;

procedure tcanvas.fillarcpieslice(const def: rectty; const startang: real;
               const extentang: real; const acolor: colorty = cl_default;
                const linecolor: colorty = cl_none);
var
 startpo,endpo: pointty;
begin
 if cs_inactive in fstate then exit;
 fillarc(def,startang,extentang,acolor,true);
 if (linecolor <> cl_none) then begin
  fdrawinfo.arc.rect:= @def; //necessary for 64 bit
  getarcinfo(startpo,endpo);
  drawlines([startpo,def.pos,endpo],false,linecolor);
  drawarc(def,startang,extentang,linecolor);
 end;
end;

procedure tcanvas.fillarcpieslice(const center: pointty; const radius: integer;
                            const startang,extentang: real;
                            const acolor: colorty = cl_default;
                            const linecolor: colorty = cl_none);
var
 rect1: rectty;
begin
 rect1.pos:= center;
 rect1.cx:= 2*radius;
 rect1.cy:= rect1.cx;
 fillarcpieslice(rect1,startang,extentang,acolor,linecolor);
end;

procedure tcanvas.fillarcpieslice1(const def: rectty; const startang: real;
               const extentang: real; const acolor: colorty = cl_default;
               const linecolor: colorty = cl_none);
begin
 fillarcpieslice(recenterrect(def),startang,extentang,acolor,linecolor);
end;

procedure tcanvas.fillpolygon(const apoints: array of pointty;
                              const acolor: colorty = cl_default;
                              const linecolor: colorty = cl_none);
begin
 if cs_inactive in fstate then exit;
 if checkforeground(acolor,false) then begin
  with fdrawinfo.points do begin
   points:= @apoints;
   count:= length(apoints);
  end;
  gdi(gdf_fillpolygon);
 end;
 if (linecolor <> cl_none) then begin
  drawlines(apoints,true,linecolor);
 end;
end;

procedure tcanvas.drawstring(const atext: pmsechar; const acount: integer;
                        const apos: pointty;
                        const afont: tfont = nil; const grayed: boolean = false;
                        const arotation: real = 0);
var
 afontnum: integer;
 po1: pfontinfoty;
 font1: tfont;
// int1: integer;
begin
 if cs_inactive in fstate then exit;
 with fdrawinfo do begin
  if afont <> nil then begin //foreign font
   if fs_blank in afont.style then begin
    exit;
   end;
   font1:= afont;
   with afont do begin
    po1:= finfopo;
    rotation:= arotation;
    afontnum:= gethandleforcanvas(self);
    afonthandle1:= afontnum;
    acolorbackground:= colorbackground;
   end;
  end
  else begin
   if fs_blank in ffont.style then begin
    exit;
   end;
   font1:= ffont;
   ffont.rotation:= arotation;
   afonthandle1:= ffont.gethandle;
   po1:= @fvaluepo^.font;
   with fvaluepo^.font do begin
    acolorbackground:= baseinfo.colorbackground;
   end;
  end;
  with fdrawinfo.text16pos do begin
   pos:= @apos;
   text:= pointer(atext);
   count:= acount;
   if grayed and (po1^.baseinfo.grayed_colorshadow <> cl_none) or
                      (po1^.baseinfo.shadow_color <> cl_none) or
                           (po1^.baseinfo.gloss_color <> cl_none) then begin
    if grayed then begin
     acolorforeground:= po1^.baseinfo.grayed_colorshadow;//cl_white;
     if acolorforeground = cl_default then begin
      acolorforeground:= cl_grayedshadow;
     end;
     inc(pos^.x,po1^.baseinfo.grayed_shiftx);
     inc(pos^.y,po1^.baseinfo.grayed_shifty);
//     inc(pos^.x,po1^.shadow_shiftx);
//     inc(pos^.y,po1^.shadow_shifty);
    end
    else begin
     if po1^.baseinfo.shadow_color <> cl_none then begin
      acolorforeground:= po1^.baseinfo.shadow_color;
      inc(pos^.x,po1^.baseinfo.shadow_shiftx);
      inc(pos^.y,po1^.baseinfo.shadow_shifty);
     end
     else begin
      acolorforeground:= po1^.baseinfo.gloss_color;
      inc(pos^.x,po1^.baseinfo.gloss_shiftx);
      inc(pos^.y,po1^.baseinfo.gloss_shifty);
     end;
    end;
    acolorbackground:= cl_transparent;
    if acolorforeground = cl_default then begin
     acolorforeground:= cl_text;
    end;
    checkgcstate([cs_font,cs_acolorforeground,cs_acolorbackground]);
    gdi(gdf_drawstring16);
    if grayed then begin
     dec(pos^.x,po1^.baseinfo.grayed_shiftx);
     dec(pos^.y,po1^.baseinfo.grayed_shifty);
     acolorforeground:= po1^.baseinfo.grayed_color;//cl_dkgray;
     if acolorforeground = cl_default then begin
      acolorforeground:= cl_grayed;
     end;
    end
    else begin
     if po1^.baseinfo.shadow_color <> cl_none then begin
      dec(pos^.x,po1^.baseinfo.shadow_shiftx);
      dec(pos^.y,po1^.baseinfo.shadow_shifty);
      if po1^.baseinfo.gloss_color <> cl_none then begin
       acolorforeground:= po1^.baseinfo.gloss_color;
       inc(pos^.x,po1^.baseinfo.gloss_shiftx);
       inc(pos^.y,po1^.baseinfo.gloss_shifty);
       checkgcstate([cs_font,cs_acolorforeground,cs_acolorbackground]);
       gdi(gdf_drawstring16);
       dec(pos^.x,po1^.baseinfo.gloss_shiftx);
       dec(pos^.y,po1^.baseinfo.gloss_shifty);
      end;
     end
     else begin
      dec(pos^.x,po1^.baseinfo.gloss_shiftx);
      dec(pos^.y,po1^.baseinfo.gloss_shifty);
     end;
     acolorforeground:= po1^.baseinfo.color;
    end;
    if acolorforeground = cl_default then begin
     acolorforeground:= cl_text;
    end;
    checkgcstate([cs_acolorforeground]);
    gdi(gdf_drawstring16);
   end
   else begin
    if grayed then begin
     acolorforeground:= po1^.baseinfo.grayed_color;
    end
    else begin
     acolorforeground:= po1^.baseinfo.color;
    end;
    if acolorforeground = cl_default then begin
     acolorforeground:= cl_text;
    end;
    if acolorbackground = cl_default then begin
     acolorbackground:= cl_transparent;
    end;
    checkgcstate([cs_font,cs_acolorforeground,cs_acolorbackground]);
    gdi(gdf_drawstring16);
   end;
  end;
  font1.rotation:= 0;
 end;
end;

procedure tcanvas.drawfontline(const startpoint,endpoint: pointty);
                           //draws line with font color
var
 linewidthbefore: integer;
 capstylebefore: capstylety;
 pt1,pt2: pointty;
 co1: colorty;
begin
 linewidthbefore:= linewidth;
 capstylebefore:= capstyle;
 linewidth:= font.linewidth;
 capstyle:= cs_butt;

 with fvaluepo^.font do begin
  if (baseinfo.shadow_color <> cl_none) then begin
   pt1.x:= startpoint.x + baseinfo.shadow_shiftx;
   pt1.y:= startpoint.y + baseinfo.shadow_shifty;
   pt2.x:= endpoint.x + baseinfo.shadow_shiftx;
   pt2.y:= endpoint.y + baseinfo.shadow_shifty;
   drawline(pt1,pt2,baseinfo.shadow_color);
  end;
  if (baseinfo.gloss_color <> cl_none) then begin
   pt1.x:= startpoint.x + baseinfo.gloss_shiftx;
   pt1.y:= startpoint.y + baseinfo.gloss_shifty;
   pt2.x:= endpoint.x + baseinfo.gloss_shiftx;
   pt2.y:= endpoint.y + baseinfo.gloss_shifty;
   drawline(pt1,pt2,baseinfo.gloss_color);
  end;
 end;
 co1:= font.color;
 if co1 = cl_default then begin
  co1:= cl_text;
 end;
 drawline(startpoint,endpoint,co1);
 linewidth:= linewidthbefore;
 capstyle:= capstylebefore;
end;

procedure tcanvas.nextpage; //used by tcustomprintercanvas
begin
 //dummy
end;

procedure tcanvas.drawstring(const atext: msestring; const apos: pointty;
                 const afont: tfont = nil; const grayed: boolean = false;
                 const arotation: real = 0);
begin
 if cs_inactive in fstate then exit;
 drawstring(pointer(atext),length(atext),apos,afont,grayed,arotation);
end;

function tcanvas.getstringwidth(const atext: pmsechar; const acount: integer;
                                 const afont: tfont = nil): integer;
var
 afontnum: integer;
begin
 result:= 0;
 if atext <> '' then begin
  checkgcstate([cs_gc]);
  if afont <> nil then begin //foreign font
   if fs_blank in afont.style then begin
    exit;
   end;
   afontnum:= afont.gethandleforcanvas(self);
  end
  else begin
   if fs_blank in ffont.style then begin
    exit;
   end;
   afontnum:= ffont.handle;
  end;
  with fdrawinfo.gettext16width do begin
   fontdata:= getfontdata(afontnum);
   text:= atext;
   count:= acount;
  end;
  gdi(gdf_gettext16width);
  result:= fdrawinfo.gettext16width.result;
 end;
end;

function tcanvas.getstringwidth(const atext: msestring; const afont: tfont = nil): integer;
begin
 result:= getstringwidth(pmsechar(atext),length(atext),afont);
end;

function tcanvas.getfontmetrics(const achar: ucs4char;
                     const afont: tfont = nil): fontmetricsty;
var
 afontnum: integer;
begin
 if afont <> nil then begin //foreign font
  afontnum:= afont.gethandleforcanvas(self);
 end
 else begin
  afontnum:= ffont.handle;
 end;
 with fdrawinfo.getfontmetrics do begin
  fontdata:= getfontdata(afontnum);
  char:= achar;
  resultpo:= @result;
 end;
 checkgcstate([cs_gc]);
 gdi(gdf_getfontmetrics);
// gdi_lock;
// gdierrorlocked(gui_getfontmetrics(fdrawinfo),self);
 with result do begin
  sum:= width - leftbearing - rightbearing;
 end;
end;

function tcanvas.getfontmetrics(const achar: msechar;
                                  const afont: tfont = nil): fontmetricsty;
begin
 result:= getfontmetrics(ucs4char(card16(achar)),afont);
end;

procedure tcanvas.drawframe(const arect: rectty; awidth: integer;
                         const acolor: colorty; const hiddenedges: edgesty);
var
 rect1,rect2: rectty;
begin
 if cs_inactive in fstate then exit;

 if ispaintcolor(acolor) then begin
  if awidth <> 0 then begin
   if awidth < 0 then begin
    rect2:= arect;
    awidth:= - awidth;
   end
   else begin
    rect2.x:= arect.x - awidth;
    rect2.y:= arect.y - awidth;
    rect2.cx:= arect.cx + awidth + awidth;
    rect2.cy:= arect.cy + awidth + awidth;
   end;
   if checkforeground(acolor,false) then begin
    with fdrawinfo.rect do begin
     rect:= @rect1;
     with rect2 do begin
      rect1.pos:= pos;
      rect1.cx:= cx;
      rect1.cy:= awidth;
      if not (edg_top in hiddenedges) then begin
       gdi(gdf_fillrect); //top
      end;
      rect1.pos.y:= y + cy - awidth;
      if not (edg_bottom in hiddenedges) then begin
       gdi(gdf_fillrect); //bottom
      end;
      rect1.pos.y:= y;
      rect1.cy:= cy;
      if not (edg_top in hiddenedges) then begin
       inc(rect1.pos.y,awidth);
       dec(rect1.cy,awidth);
      end;
      if not (edg_bottom in hiddenedges) then begin
       dec(rect1.cy,awidth);
      end;
      rect1.cx:= awidth;
      if not (edg_left in hiddenedges) then begin
       gdi(gdf_fillrect); //left
      end;
      rect1.pos.x:= x + cx - awidth;
      if not (edg_right in hiddenedges) then begin
       gdi(gdf_fillrect); //right
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcanvas.drawframe(const arect: rectty; awidth: framety;
                   const acolor: colorty = cl_default;
                   const hiddenedges: edgesty = []);
var
 rect1,rect2: rectty;
begin
 if cs_inactive in fstate then exit;
 if ispaintcolor(acolor) then begin
  rect2:= arect;
  if checkforeground(acolor,false) then begin
   with fdrawinfo.rect do begin
    rect:= @rect1;
    with rect2 do begin
     rect1.pos:= pos;
     rect1.cx:= cx;
     rect1.cy:= awidth.top;
     if (rect1.cx > 0) and (rect1.cy > 0) then begin
      gdi(gdf_fillrect); //top
     end;
     rect1.pos.y:= y + cy - awidth.bottom;
     rect1.cy:= awidth.bottom;
     if (rect1.cx > 0) and (rect1.cy > 0) then begin
      gdi(gdf_fillrect); //bottom
     end;
     rect1.pos.y:= y;
     rect1.cy:= cy;
     inc(rect1.pos.y,awidth.top);
     dec(rect1.cy,awidth.top);
     dec(rect1.cy,awidth.bottom);
     rect1.cx:= awidth.left;
     if (rect1.cx > 0) and (rect1.cy > 0) then begin
      gdi(gdf_fillrect); //left
     end;
     rect1.pos.x:= x + cx - awidth.right;
     rect1.cx:= awidth.right;
     if (rect1.cx > 0) and (rect1.cy > 0) then begin
      gdi(gdf_fillrect); //right
     end;
    end;
   end;
  end;
 end;
end;

procedure tcanvas.drawxorframe(const arect: rectty; const awidth: integer = -1;
                           const abrush: tsimplebitmap = nil);
var
 rasteropbefore: rasteropty;
 brushbefore: tsimplebitmap;
 brushoriginbefore: pointty;
 int1: integer;
begin
 if cs_inactive in fstate then exit;
 int1:= -awidth*2;
 if (abs(arect.cx) < int1) or (abs(arect.cy) < int1) then begin
  fillxorrect(arect,abrush); //avoid xor overlap
 end
 else begin
  rasteropbefore:= rasterop;
  rasterop:= rop_xor;
  if abrush = nil then begin
   drawframe(arect,awidth,cl_white);
  end
  else begin
   brushbefore:= brush;
   brushoriginbefore:= brushorigin;
   brushorigin:= nullpoint;
   brush:= abrush;
   drawframe(arect,awidth,cl_brush);
   brush:= brushbefore;
   brushorigin:= brushoriginbefore;
  end;
  rasterop:= rasteropbefore;
 end;
end;

procedure tcanvas.drawxorframe(const po1, po2: pointty; const awidth: integer = -1;
  const abrush: tsimplebitmap = nil);
begin
 if cs_inactive in fstate then exit;
 drawxorframe(makerect(po1,makesize(po2.x-po1.x,po2.y-po1.y)),awidth,abrush);
end;

procedure tcanvas.fillxorrect(const arect: rectty;
                                     const abrush: tsimplebitmap = nil);
var
 rasteropbefore: rasteropty;
 brushbefore: tsimplebitmap;
 brushoriginbefore: pointty;
begin
 if cs_inactive in fstate then exit;
 rasteropbefore:= rasterop;
 rasterop:= rop_xor;
 if abrush = nil then begin
  fillrect(arect,cl_white);
 end
 else begin
  brushbefore:= brush;
  brushoriginbefore:= brushorigin;
  brushorigin:= nullpoint;
  brush:= abrush;
  fillrect(arect,cl_brush);
  brush:= brushbefore;
  brushorigin:= brushoriginbefore;
 end;
 rasterop:= rasteropbefore;
end;

procedure tcanvas.fillxorrect(const start: pointty; const length: integer;
                      const direction: graphicdirectionty;
                      const awidth: integer = 0;
                      const abrush: tsimplebitmap = nil);
var
 rect1: rectty;
begin
 case direction of
  gd_left: begin
   rect1.x:= start.x - length;
   rect1.y:= start.y - awidth div 2;
   rect1.cx:= length;
   rect1.cy:= awidth;
  end;
  gd_down: begin
   rect1.y:= start.y;
   rect1.x:= start.x - awidth div 2;
   rect1.cy:= length;
   rect1.cx:= awidth;
  end;
  gd_up: begin
   rect1.y:= start.y - length;
   rect1.x:= start.x - awidth div 2;
   rect1.cy:= length;
   rect1.cx:= awidth;
  end;
  else begin //gd_right
   rect1.x:= start.x;
   rect1.y:= start.y - awidth div 2;
   rect1.cx:= length;
   rect1.cy:= awidth;
  end;
 end;
 fillxorrect(rect1,abrush);
end;


//
// region helpers
//

function tcanvas.createregion: regionty;
begin
 fdrawinfo.gc.gdifuncs^[gdf_createemptyregion](fdrawinfo);
 result:= fdrawinfo.regionoperation.dest;
end;

function tcanvas.createregion(const asource: regionty): regionty;
begin
 with fdrawinfo.regionoperation do begin
  source:= asource;
  fdrawinfo.gc.gdifuncs^[gdf_copyregion](fdrawinfo);
  result:= dest;
 end;
end;

function tcanvas.createregion(const arect: rectty): regionty;
begin
 with fvaluepo^,fdrawinfo.regionoperation do begin
  rect:= arect;
  inc(rect.x,origin.x);
  inc(rect.y,origin.y);
  fdrawinfo.gc.gdifuncs^[gdf_createrectregion](fdrawinfo);
  result:= dest;
 end;
end;

function tcanvas.createregion(const rects: array of rectty): regionty;
begin
 result:= 0;
 with fdrawinfo.regionoperation do begin
  rectscount:= high(rects) + 1;
  if rectscount > 0 then begin
   rectspo:= @rects[0];
   adjustrectar(@rects[0],rectscount);
   fdrawinfo.gc.gdifuncs^[gdf_createrectsregion](fdrawinfo);
   result:= dest;
   readjustrectar(@rects[0],rectscount);
  end
  else begin
   result:= createregion;
  end;
 end;
end;

function tcanvas.createregion(frame: rectty; const inflate: integer): regionty;
          //frame
var
 reg1: regionty;
begin
 with fvaluepo^ do begin
  inc(frame.x,origin.x);
  inc(frame.y,origin.y);
 end;
 if inflate > 0 then begin
  result:= createregion(inflaterect(frame,inflate));
  reg1:= createregion(frame);
 end
 else begin
  result:= createregion(frame);
  reg1:= createregion(inflaterect(frame,inflate));
 end;
 regsubregion(result,reg1);
 destroyregion(reg1);
end;

procedure tcanvas.destroyregion(region: regionty);
begin
 with fdrawinfo.regionoperation do begin
  source:= region;
  fdrawinfo.gc.gdifuncs^[gdf_destroyregion](fdrawinfo);
 end;
end;

procedure tcanvas.regmove(const adest: regionty; const dist: pointty);
begin
 with fdrawinfo.regionoperation do begin
  dest:= adest;
  rect.pos:= dist;
 end;
 fdrawinfo.gc.gdifuncs^[gdf_moveregion](fdrawinfo);
end;

procedure tcanvas.regremove(const adest: regionty; const dist: pointty);
begin
 regmove(adest,makepoint(-dist.x,-dist.y));
end;

procedure tcanvas.initregrect(const adest: regionty; const arect: rectty);
begin
 with fdrawinfo,regionoperation do begin
  dest:= adest;
  rect:= arect;
  inc(rect.x,fvaluepo^.origin.x);
  dec(rect.x,gc.cliporigin.x);
  inc(rect.y,fvaluepo^.origin.y);
  dec(rect.y,gc.cliporigin.y);
  if rect.x < -$8000 then begin
   rect.x:= -$8000;
  end;
  if rect.x > $7fff then begin
   rect.x:= $7fff;
  end;
  if rect.cx < 0 then begin
   rect.cx:= 0;
  end;
  if rect.cx + rect.x > $7fff then begin
   rect.cx:= $7fff - rect.x
  end;
  if rect.y < -$8000 then begin
   rect.y:= -$8000;
  end;
  if rect.y > $7fff then begin
   rect.y:= $7fff;
  end;
  if rect.cy < 0 then begin
   rect.cy:= 0;
  end;
  if rect.cy + rect.y > $7fff then begin
   rect.cy:= $7fff - rect.y;
  end;
 end;
end;

procedure tcanvas.initregreg(const adest: regionty; const asource: regionty);
begin
 with fdrawinfo,regionoperation do begin
  dest:= adest;
  source:= asource;
 end;
end;

procedure tcanvas.regsubrect(const dest: regionty; const rect: rectty);
begin
 initregrect(dest,rect);
 fdrawinfo.gc.gdifuncs^[gdf_regsubrect](fdrawinfo);
end;

procedure tcanvas.regaddrect(const dest: regionty; const rect: rectty);
begin
 initregrect(dest,rect);
 fdrawinfo.gc.gdifuncs^[gdf_regaddrect](fdrawinfo);
end;

procedure tcanvas.regintersectrect(const dest: regionty; const rect: rectty);
begin
 initregrect(dest,rect);
 fdrawinfo.gc.gdifuncs^[gdf_regintersectrect](fdrawinfo);
end;

procedure tcanvas.regaddregion(const dest: regionty; const region: regionty);
begin
 initregreg(dest,region);
 fdrawinfo.gc.gdifuncs^[gdf_regaddregion](fdrawinfo);
end;

procedure tcanvas.regsubregion(const dest: regionty; const region: regionty);
begin
 initregreg(dest,region);
 fdrawinfo.gc.gdifuncs^[gdf_regsubregion](fdrawinfo);
end;

procedure tcanvas.regintersectregion(const dest: regionty; const region: regionty);
begin
 initregreg(dest,region);
 fdrawinfo.gc.gdifuncs^[gdf_regintersectregion](fdrawinfo);
end;

function tcanvas.regionisempty(const region: regionty): boolean;
begin
 with fdrawinfo.regionoperation do begin
  source:= region;
  fdrawinfo.gc.gdifuncs^[gdf_regionisempty](fdrawinfo);
  result:= dest <> 0;
 end;
end;

function tcanvas.regionclipbox(const region: regionty): rectty;
begin
 if region <> 0 then begin
  with fdrawinfo.regionoperation do begin
   source:= region;
   fdrawinfo.gc.gdifuncs^[gdf_regionclipbox](fdrawinfo);
   result:= rect;
  end;
 end
 else begin
  result:= nullrect;
 end;
end;

//
// clip region functions
//

procedure tcanvas.setclipregion(const Value: regionty);
begin
 with fvaluepo^ do begin
  if cs_regioncopy in changed then begin
   destroyregion(clipregion);
  end;
  include(changed,cs_regioncopy);
  clipregion := Value;
  valuechanged(cs_clipregion);
 end;
end;

procedure tcanvas.subcliprect(const rect: rectty);
begin
 checkregionstate;
 regsubrect(fvaluepo^.clipregion,rect);
end;

procedure tcanvas.subclipframe(const frame: rectty; inflate: integer);
var
 reg1: regionty;
begin
 checkregionstate;
 reg1:= createregion(frame,inflate);
 regsubregion(fvaluepo^.clipregion,reg1);
 destroyregion(reg1);
end;

procedure tcanvas.subclipregion(const region: regionty);
begin
 checkregionstate;
 regsubregion(fvaluepo^.clipregion,region);
end;

procedure tcanvas.addcliprect(const rect: rectty);
begin
 checkregionstate;
 regaddrect(fvaluepo^.clipregion,rect);
end;

procedure tcanvas.setcliprect(const rect: rectty);
begin
 clipregion:= createregion(removerect(rect,fcliporigin));
end;

procedure tcanvas.addclipframe(const frame: rectty; inflate: integer);
var
 reg1: regionty;
begin
 checkregionstate;
 reg1:= createregion(frame,inflate);
 regaddregion(fvaluepo^.clipregion,reg1);
 destroyregion(reg1);
end;

procedure tcanvas.addclipregion(const region: regionty);
begin
 checkregionstate;
 regaddregion(fvaluepo^.clipregion,region);
end;

procedure tcanvas.intersectcliprect(const rect: rectty);
begin
 checkregionstate;
 regintersectrect(fvaluepo^.clipregion,rect);
end;

procedure tcanvas.intersectclipframe(const frame: rectty; inflate: integer);
var
 reg1: regionty;
begin
 checkregionstate;
 reg1:= createregion(frame,inflate);
 regintersectregion(fvaluepo^.clipregion,reg1);
 destroyregion(reg1);
end;

procedure tcanvas.intersectclipregion(const region: regionty);
begin
 checkregionstate;
 regintersectregion(fvaluepo^.clipregion,region);
end;

procedure tcanvas.resetclipregion;
begin
 clipregion:= 0;
end;

function tcanvas.copyclipregion: regionty;
begin
 with fdrawinfo.regionoperation do begin
  source:= fvaluepo^.clipregion;
  fdrawinfo.gc.gdifuncs^[gdf_copyregion](fdrawinfo);
  result:= dest;
 end;
end;

//
//
//

procedure tcanvas.adjustrectar(po: prectty; count: integer);
var
 dx,dy: integer;
begin
 dx:= fvaluepo^.origin.x;
 dy:= fvaluepo^.origin.y;
 if (dx <> 0) or (dy <> 0 ) then begin
  while count > 0 do begin
   inc(po^.x,dx);
   inc(po^.y,dy);
   inc(po);
   dec(count);
  end;
 end;
end;

procedure tcanvas.readjustrectar(po: prectty; count: integer);
var
 dx,dy: integer;
begin
 dx:= fvaluepo^.origin.x;
 dy:= fvaluepo^.origin.y;
 if (dx <> 0) or (dy <> 0 ) then begin
  while count > 0 do begin
   dec(po^.x,dx);
   dec(po^.y,dy);
   inc(po);
   dec(count);
  end;
 end;
end;

function tcanvas.getcolor: colorty;
begin
 result:= fvaluepo^.color;
end;

procedure tcanvas.setcolor(const value: colorty);
begin
 if fvaluepo^.color <> value then begin
  fvaluepo^.color:= value;
  valuechanged(cs_color);
 end;
end;

function tcanvas.getcolorbackground: colorty;
begin
 result:= fvaluepo^.colorbackground;
end;

procedure tcanvas.setcolorbackground(const Value: colorty);
begin
 if fvaluepo^.colorbackground <> value then begin
  fvaluepo^.colorbackground:= value;
  valuechanged(cs_colorbackground);
 end;
end;

function tcanvas.getrasterop: rasteropty;
begin
 result:= fvaluepo^.rasterop;
end;

procedure tcanvas.setrasterop(const Value: rasteropty);
begin
 if fvaluepo^.rasterop <> value then begin
  fvaluepo^.rasterop:= value;
  valuechanged(cs_rasterop);
 end;
end;

function tcanvas.getlinewidth: integer;
begin
 result:= (fvaluepo^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
end;

procedure tcanvas.setlinewidth(Value: integer);
begin
 value:= value shl linewidthshift;
 if fvaluepo^.lineinfo.width <> value then begin
  fvaluepo^.lineinfo.width:= value;
  valuechanged(cs_linewidth);
 end;
end;

function tcanvas.getlinewidthmm: real;
begin
 result:= fvaluepo^.lineinfo.width /
                        (fdrawinfo.gc.ppmm * (1 shl linewidthshift));
end;

procedure tcanvas.setlinewidthmm(const avalue: real);
var
 int1: integer;
begin
 int1:= round(avalue * (1 shl linewidthshift) * fdrawinfo.gc.ppmm);
 if fvaluepo^.lineinfo.width <> int1 then begin
  fvaluepo^.lineinfo.width:= int1;
  valuechanged(cs_linewidth);
 end;
end;

function tcanvas.getdashes: dashesstringty;
begin
 result:= fvaluepo^.lineinfo.dashes;
end;

procedure tcanvas.setdashes(const Value: dashesstringty);
var
 int1: integer;
begin
 with fvaluepo^.lineinfo do begin
  dashes:= value;
  for int1:= 1 to length(dashes) do begin
   if dashes[int1] = #0 then begin
    setlength(dashes,int1-1);
    break;
   end;
  end;
  if odd(length(dashes)) then begin
   setlength(dashes,length(dashes)-1);
  end;
 end;
 valuechanged(cs_dashes);
end;

function tcanvas.getcapstyle: capstylety;
begin
 result:= fvaluepo^.lineinfo.capstyle;
end;

procedure tcanvas.setcapstyle(const Value: capstylety);
begin
 fvaluepo^.lineinfo.capstyle:= value;
 valuechanged(cs_capstyle);
end;

function tcanvas.getjoinstyle: joinstylety;
begin
 result:= fvaluepo^.lineinfo.joinstyle;
end;

function tcanvas.getoptions: canvasoptionsty;
begin
 result:= fvaluepo^.options;
end;

procedure tcanvas.setjoinstyle(const Value: joinstylety);
begin
 fvaluepo^.lineinfo.joinstyle:= value;
 valuechanged(cs_joinstyle);
end;

procedure tcanvas.setoptions(const avalue: canvasoptionsty);
begin
 fvaluepo^.options:= avalue;
 valuechanged(cs_options);
end;

function tcanvas.defaultcliprect: rectty;
begin
 result:= makerect(nullpoint,fdrawinfo.gc.paintdevicesize);
end;

procedure tcanvas.checkregionstate;
begin
 with fvaluepo^ do begin
  if clipregion = 0 then begin
   checkgcstate([cs_gc]); //fsize must be valid
   clipregion:= createregion(defaultcliprect);
  end
  else begin
   if not (cs_regioncopy in changed) then begin
    clipregion:= createregion(clipregion);
   end;
  end;
  include(changed,cs_regioncopy);
  include(changed,cs_clipregion);
 end;
 exclude(fstate,cs_clipregion);
end;

procedure tcanvas.move(const dist: pointty);
begin
 if (dist.x <> 0) or (dist.y <> 0) then begin
  with fvaluepo^ do begin
   inc(origin.x,dist.x);
   inc(origin.y,dist.y);
  end;
  valuechanged(cs_origin);
 end;
end;

procedure tcanvas.remove(const dist: pointty);
begin
 with fvaluepo^ do begin
  dec(origin.x,dist.x);
  dec(origin.y,dist.y);
 end;
 valuechanged(cs_origin);
end;

function tcanvas.getorigin: pointty;
begin
 result:= subpoint(fvaluepo^.origin,fdrawinfo.gc.cliporigin);
end;

procedure tcanvas.setorigin(const Value: pointty);
var
 po1: pointty;
begin
 po1:= addpoint(value,fdrawinfo.gc.cliporigin);
 if not pointisequal(fvaluepo^.origin,po1) then begin
  fvaluepo^.origin:= po1;
  valuechanged(cs_origin);
 end;
end;

function tcanvas.clipregionisempty: boolean;
begin
 with fvaluepo^ do begin
  if clipregion = 0 then begin
   result:= false;
  end
  else begin
   result:= regionisempty(clipregion);
  end;
 end;
end;

function tcanvas.clipbox: rectty;
begin
 with fvaluepo^ do begin
  if clipregion = 0 then begin
   result:= makerect(makepoint(-origin.x,-origin.y),icanvas(fintf).getsize);
  end
  else begin
   result:= regionclipbox(clipregion);
   dec(result.x,origin.x);
   inc(result.x,fdrawinfo.gc.cliporigin.x);
   dec(result.y,origin.y);
   inc(result.y,fdrawinfo.gc.cliporigin.y);
  end;
 end;
end;

{
procedure tcanvas.drawedge(const vector: graphicvectorty; level: integer;
                                const colorinfo: framecolorinfoty);
//procedure paintkante2(painter: qpainterh; const startpoint: tpoint;
//                         length: integer; direction: tgraphicdirection;
//                         width: integer; const color: qcolorh;
//                         glanz: integer = 0; const colorglanz: qcolorh = nil;
//                         infos: kanteninfosty = []);
                          //glanz < 0 -> am schluss bei dark
var
 points: tpointarray;
 breite1,breite2: integer;
 step1a,step2a,step3a: integer;
 step1b,step2b,step3b: integer;
 reverseoffset: integer;

begin
 if length <= 0 then begin
  exit;
 end;
 if not (kin_dark in infos) then begin
  glanz:= -glanz;
 end;
 setlength(points,8);
 points[0]:= startpoint;
 if glanz <= 0 then begin          //glanz am schluss
  breite1:= width+glanz;
  qpainter_setpen(painter,color);
  qpainter_setbrush(painter,color);
 end
 else begin                        //glanz zu beginn
  breite1:= glanz;
  qpainter_setpen(painter,colorglanz);
  qpainter_setbrush(painter,colorglanz);
 end;
 if breite1 > width then begin
  breite1:= width;
 end;
 if breite1 < 0 then begin
  breite1:= 0;
 end;
 reverseoffset:= 2*width;
 dec(length);
 dec(width);
 dec(breite1);
 breite2:= width-breite1-1;
 if kin_reverseend in infos then begin
  step1a:= -breite1;
  step2a:= -1;
  step3a:= -width;
  length:= length-reverseoffset;
 end
 else begin
  step1a:= breite1;
  step2a:= 1;
  step3a:= width;
 end;
 if kin_reversestart in infos then begin
  step1b:= -breite1+reverseoffset;
  step2b:= -1;
  step3b:= -width+reverseoffset;
 end
 else begin
  reverseoffset:= 0;
  step1b:= breite1;
  step2b:= 1;
  step3b:= width;
 end;
 case direction of
  gd_right: begin
   points[0].X:= startpoint.X + reverseoffset;
   points[1].x:= startpoint.X + length;
   points[1].Y:= startpoint.Y;
   points[2].X:= points[1].X - step1a;
   points[2].Y:= startpoint.Y + breite1;
   points[3].x:= startpoint.x + step1b;
   points[3].Y:= points[2].Y;
   if breite2 >= 0 then begin
    points[4].X:= points[3].X + step2b;
    points[4].Y:= points[3].Y + 1;
    points[5].X:= points[2].X - step2a;
    points[5].y:= points[2].y + 1;
    points[6].X:= points[1].X - step3a;
    points[6].Y:= startpoint.Y + width;
    points[7].x:= startpoint.x + step3b;
    points[7].Y:= points[6].Y;
   end;
  end;
  gd_up: begin
   points[0].y:= startpoint.y - reverseoffset;
   points[1].x:= startpoint.X;
   points[1].Y:= startpoint.Y-length;
   points[2].X:= startpoint.X + breite1;
   points[2].Y:= points[1].Y + step1a;
   points[3].x:= points[2].x;
   points[3].Y:= startpoint.Y - step1b;
   if breite2 >= 0 then begin
    points[4].X:= points[3].X + 1;
    points[4].Y:= points[3].Y - step2b;
    points[5].X:= points[2].X + 1;
    points[5].y:= points[2].y + step2a;
    points[6].X:= startpoint.x + width;
    points[6].Y:= points[1].Y + step3a;
    points[7].x:= points[6].x;
    points[7].Y:= startpoint.y - step3b;
   end;
  end;
  gd_left: begin
   points[0].X:= startpoint.X - reverseoffset;
   points[1].x:= startpoint.X - length;
   points[1].Y:= startpoint.Y;
   points[2].X:= points[1].X + step1a;
   points[2].Y:= startpoint.Y - breite1;
   points[3].x:= startpoint.x - step1b;
   points[3].Y:= points[2].Y;
   if breite2 >= 0 then begin
    points[4].X:= points[3].X - step2b;
    points[4].Y:= points[3].Y - 1;
    points[5].X:= points[2].X + step2a;
    points[5].y:= points[2].y - 1;
    points[6].X:= points[1].X + step3a;
    points[6].Y:= startpoint.Y - width;
    points[7].x:= startpoint.x - step3b;
    points[7].Y:= points[6].Y;
   end;
  end;
  gd_down: begin
   points[0].y:= startpoint.y + reverseoffset;
   points[1].x:= startpoint.X;
   points[1].Y:= startpoint.Y+length;
   points[2].X:= startpoint.X - breite1;
   points[2].Y:= points[1].Y - step1a;
   points[3].x:= points[2].x;
   points[3].Y:= startpoint.Y + step1b;
   if breite2 >= 0 then begin
    points[4].X:= points[3].X - 1;
    points[4].Y:= points[3].Y + step2b;
    points[5].X:= points[2].X - 1;
    points[5].y:= points[2].y - step2a;
    points[6].X:= startpoint.x - width;
    points[6].Y:= points[1].Y - step3a;
    points[7].x:= points[6].x;
    points[7].Y:= startpoint.y + step3b;
   end;
  end;
 end;
 if breite1 >= 0 then begin
  if breite1 > 1 then begin
   qpainter_drawpolygon(painter,@points[0],false,0,4);
  end
  else begin
   qpainter_moveto(painter,@points[0]);
   qpainter_lineto(painter,@points[1]);
   if breite1 = 1 then begin
    qpainter_moveto(painter,@points[2]);
    qpainter_lineto(painter,@points[3]);
   end;
  end;
 end;
 if breite2 >= 0 then begin
  if glanz < 0 then begin
   qpainter_setpen(painter,colorglanz);
   qpainter_setbrush(painter,colorglanz);
  end
  else begin
   qpainter_setpen(painter,color);
   qpainter_setbrush(painter,color);
  end;
  if breite2 > 1 then begin
   qpainter_drawpolygon(painter,@points[0],false,4,4);
  end
  else begin
   qpainter_moveto(painter,@points[4]);
   qpainter_lineto(painter,@points[5]);
   if breite2 = 1 then begin
    qpainter_moveto(painter,@points[6]);
    qpainter_lineto(painter,@points[7]);
   end;
  end;
 end;
end;
}
{
procedure tcanvas.drawedge(const vector: graphicvectorty; level: integer;
                                const colorinfo: framecolorinfoty);
var
 poly: pointarty;

 procedure shrink(value: integer);
 begin
  case vector.direction of
   gd_right: begin
    poly[2].x:= poly[1].x - value;
    poly[2].y:= poly[1].y - value;
    poly[3].x:= poly[0].x + value;
    poly[3].y:= poly[0].y - value;
   end;
   gd_up: begin
    poly[2].x:= poly[1].x - value;
    poly[2].y:= poly[1].y + value;
    poly[3].x:= poly[0].x - value;
    poly[3].y:= poly[0].y - value;
   end;
   gd_left: begin
    poly[2].x:= poly[1].x - value;
    poly[2].y:= poly[1].y + value;
    poly[3].x:= poly[0].x + value;
    poly[3].y:= poly[0].y + value;
   end;
   gd_down: begin
    poly[2].x:= poly[1].x + value;
    poly[2].y:= poly[1].y + value;
    poly[3].x:= poly[0].x + value;
    poly[3].y:= poly[0].y - value;
   end;
  end;
 end;

 procedure offset;
 begin
  case vector.direction of
   gd_right: begin
    inc(poly[0].x);
    dec(poly[0].y);
    dec(poly[1].x);
    dec(poly[1].y);
   end;
   gd_up: begin
    dec(poly[0].x);
    dec(poly[0].y);
    dec(poly[1].x);
    inc(poly[1].y);
   end;
   gd_left: begin
    inc(poly[0].x);
    inc(poly[0].y);
    dec(poly[1].x);
    inc(poly[1].y);
   end;
   gd_down: begin
    inc(poly[0].x);
    dec(poly[0].y);
    inc(poly[1].x);
    inc(poly[1].y);
   end;
  end;
 end;

 procedure draw(with1,with2: integer; col1,col2: colorty);
 begin
  if with1 > 0 then begin
   if with1 = 1 then begin
    drawlines(poly,col1,2);
   end
   else begin
    shrink(with1);
    fillpolygon(poly,col1);
    poly[0]:= poly[3];
    poly[1]:= poly[2];
   end;
  end;
  if with2 > 0 then begin
   offset;
   if with2 = 1 then begin
    drawlines(poly,col2,2);
   end
   else begin
    shrink(with2);
    fillpolygon(poly,col2);
   end;
  end;
 end;

var
 topleft,inlight,effectfirst: boolean;
 effcol,normcol: colorty;
 effwidth: integer;

begin
 if level = 0 then begin
  exit;
 end;
 with colorinfo do begin
  topleft:= vector.direction in [gd_left,gd_down];
  inlight:= topleft;
  if level < 0 then begin
   level:= -level;
   inlight:= not inlight;
  end;
  if inlight then begin
   normcol:= collight;
   effcol:= colhighlight;
   effwidth:= highlight;
  end
  else begin
   normcol:= colshadow;
   effcol:= coldkshadow;
   effwidth:= dkshadow;
  end;
  if effwidth < 0 then begin
   effwidth:= -effwidth;
   effectfirst:= topleft;
  end
  else begin
   effectfirst:= false;
  end;
  if effwidth > level then begin
   effwidth:= level;
   level:= 0;
  end
  else begin
   level:= level - effwidth;
  end;
  if not inlight then begin
   if (level = 0) then begin
    level:= effwidth;
    effwidth:= 0;
   end;
  end;
 end;
 setlength(poly,4);
 vectortoline(vector,poly[0],poly[1]);
 poly[0]:= vector.start;
 if effectfirst then begin
  draw(effwidth,level,effcol,normcol);
 end
 else begin
  draw(level,effwidth,normcol,effcol);
 end;
end;
}
function tcanvas.getbrush: tsimplebitmap;
begin
 result:= fvaluepo^.brush;
end;

procedure tcanvas.setbrush(const Value: tsimplebitmap);
begin
 if fvaluepo^.brush <> value then begin
  fvaluepo^.brush:= value;
  valuechanged(cs_brush);
  gccolorforeground:= cl_none; //force reload
 end;
end;

procedure tcanvas.resetpaintedflag;
begin
 exclude(fstate,cs_painted);
end;

function tcanvas.getbrushorigin: pointty;
begin
 result.x:= fvaluepo^.brushorigin.x-fvaluepo^.origin.x;
 result.y:= fvaluepo^.brushorigin.y-fvaluepo^.origin.y;
end;

procedure tcanvas.setbrushorigin(const Value: pointty);
begin
 fvaluepo^.brushorigin.x:= value.x+fvaluepo^.origin.x;
 fvaluepo^.brushorigin.y:= value.y+fvaluepo^.origin.y;
 valuechanged(cs_brushorigin);
end;

function tcanvas.getrootbrushorigin: pointty;
begin
 result.x:= fvaluepo^.brushorigin.x-fcliporigin.x;
 result.y:= fvaluepo^.brushorigin.y-fcliporigin.y;
end;

procedure tcanvas.setrootbrushorigin(const Value: pointty);
begin
 fvaluepo^.brushorigin.x:= value.x+fcliporigin.x;
 fvaluepo^.brushorigin.y:= value.y+fcliporigin.y;
 valuechanged(cs_brushorigin);
end;

procedure tcanvas.adjustbrushorigin(const arect: rectty;
                                            const alignment: alignmentsty);
var
 siz1: sizety;
 pt1: pointty;
begin
 if fvaluepo^.brush <> nil then begin
  siz1:= fvaluepo^.brush.size;
 end
 else begin
  siz1:= nullsize;
 end;
 pt1.x:= -fvaluepo^.origin.x;
 pt1.y:= -fvaluepo^.origin.y;
 if al_left in alignment then begin
  pt1.x:= arect.x;
 end
 else begin
  if al_xcentered in alignment then begin
   pt1.x:= arect.x + (arect.cx - siz1.cx) div 2;
  end
  else begin
   if al_right in alignment then begin
    pt1.x:= arect.x + arect.cx - siz1.cx;
   end;
  end;
 end;
 if al_top in alignment then begin
  pt1.y:= arect.y;
 end
 else begin
  if al_ycentered in alignment then begin
   pt1.y:= arect.y + (arect.cy - siz1.cy) div 2;
  end
  else begin
   if al_bottom in alignment then begin
    pt1.y:= arect.y + arect.cy - siz1.cy;
   end;
  end;
 end;
 brushorigin:= pt1;
end;

function tcanvas.active: boolean;
begin
 result:= fdrawinfo.gc.handle <> 0;
end;

procedure tcanvas.updatecliporigin(const Value: pointty);
var
 delta: pointty;
 int1: integer;
begin
 delta:= subpoint(value,fcliporigin);
 fcliporigin:= value;
 fdrawinfo.gc.cliporigin:= value;
 with fvaluestack do begin
  for int1:= 0 to count-1 do begin
   addpoint1(stack[int1].origin,delta);
  end;
 end;
 addpoint1(fdrawinfo.origin,delta);
end;

procedure tcanvas.setcliporigin(const Value: pointty);
begin
 checkgcstate([cs_gc]);
 updatecliporigin(value);
 gdi(gdf_setcliporigin);
end;

procedure tcanvas.setppmm(avalue: real);
begin
 if avalue < 0.1 then begin
  avalue:= 0.1;
 end;
 fdrawinfo.gc.ppmm:= avalue;
end;

procedure tcanvas.internaldrawtext(var info);
begin
 gdierror(gde_notimplemented);
end;

procedure tcanvas.initflags(const dest: tcanvas);
begin
 with dest do begin
  exclude(fdrawinfo.gc.drawingflags,df_highresfont);
  ffont.releasehandles;
  gcfonthandle1:= 0; //invalid
 end;
end;

function tcanvas.highresdevice: boolean;
begin
 result:= cs_highresdevice in fstate;
end;

function tcanvas.getkind: bitmapkindty;
begin
 result:= icanvas(fintf).getkind;
end;

function tcanvas.getcontextinfopo: pointer;
begin
 result:= nil; //dummy
end;

function tcanvas.getcanvasimage(const abgr: boolean = false): imagety;
 //todo: handle monochrome and mask
var
 int1: integer;
begin
 fillchar(fdrawinfo.getimage,sizeof(fdrawinfo.getimage),0);
 with fdrawinfo,getimage do begin
  if gc.handle <> 0 then begin
   image.image.bgr:= abgr;
   int1:= gc.paintdevicesize.cx * gc.paintdevicesize.cy;
   if int1 > 0 then begin
    allocimage(image.image,gc.paintdevicesize,bmk_rgb);
    with image.image do begin
//     pixels:= gui_allocimagemem(int1);
     if pixels <> nil then begin
//      size:= gc.paintdevicesize;
//      length:= int1;
      error:= gde_notimplemented;
      gdi(gdf_getimage);
     end;
    end;
   end;
  end;
  checkimagebgr(image.image,abgr);
  result:= image.image;
 end;
end;

procedure tcanvas.endpaint;
begin
 if fdrawinfo.gc.handle <> 0 then begin
  gdi(gdf_endpaint);
 end;
end;

procedure tcanvas.updatewindowoptions(var aoptions: internalwindowoptionsty);
begin
 //dummy
end;

procedure tcanvas.updatesize(const asize: sizety);
begin
 fdrawinfo.gc.paintdevicesize:= asize;
end;

procedure tcanvas.movewindowrect(const adist: pointty; const arect: rectty);
begin
 checkgcstate([cs_gc]);
 with fdrawinfo.moverect do begin
  dist:= @adist;
  rect:= @arect;
  gdi(gdf_movewindowrect);
 end;
end;

procedure tcanvas.fitppmm(const asize: sizety);
begin
 with getfitrect do begin
  if (asize.cx <> 0) and (asize.cy <> 0) and
          (size.cx <> 0) and (size.cy <> 0) then begin
   if asize.cx/asize.cy > size.cx/size.cy then begin
    self.ppmm:= ppmm * asize.cx/size.cx;
   end
   else begin
    self.ppmm:= ppmm * asize.cy/size.cy;
   end;
  end;
 end;
end;

function tcanvas.getfitrect: rectty;
begin
 result.pos:= nullpoint;
 checkgcstate([cs_gc]);
 result.size:= fdrawinfo.gc.paintdevicesize;
end;

procedure tcanvas.beforeread;
begin
 reset;
end;

procedure tcanvas.afterread;
begin
 fvaluestack.stack[0]:= fvaluestack.stack[1]; //streamed values are default
 fstate:= fstate - changedmask;
end;

procedure tcanvas.readlineoptions(reader: treader);
var
 liopt1: lineoptionsty;
begin
 liopt1:= lineoptionsty(reader.readset(typeinfo(lineoptionsty)));
 if lio_antialias in liopt1 then begin
  options:= options + [cao_smooth];
 end;
end;

procedure tcanvas.defineproperties(filer: tfiler);
begin
 filer.defineproperty('lineoptions',@readlineoptions,nil,false);
end;

function tcanvas.getsmooth: boolean;
begin
 result:= cao_smooth in fvaluepo^.options;
end;

procedure tcanvas.setsmooth(const avalue: boolean);
begin
 if avalue <> (cao_smooth in fvaluepo^.options) then begin
  if avalue then begin
   options:= fvaluepo^.options + [cao_smooth];
  end
  else begin
   options:= fvaluepo^.options - [cao_smooth];
  end;
 end;
end;

function tcanvas.size: sizety;
begin
 result:= getfitrect().size;
end;

{ tfontcomp }

function tfontcomp.gettemplate: tfonttemplate;
begin
 result:= tfonttemplate(ftemplate);
end;

procedure tfontcomp.settemplate(const avalue: tfonttemplate);
begin
 ftemplate.assign(avalue);
end;

function tfontcomp.gettemplateclass: templateclassty;
begin
 result:= tfonttemplate;
end;

{ tfonttemplate }

constructor tfonttemplate.create(const owner: tmsecomponent;
               const onchange: notifyeventty);
begin
 initfontinfo(fi);
 inherited;
end;

procedure tfonttemplate.setcolor(const avalue: colorty);
begin
 fi.color:= avalue;
 changed();
end;

procedure tfonttemplate.setcolorbackground(const avalue: colorty);
begin
 fi.colorbackground:= avalue;
 changed();
end;

procedure tfonttemplate.setcolorselect(const avalue: colorty);
begin
 fi.colorselect:= avalue;
 changed();
end;

procedure tfonttemplate.setcolorselectbackground(const avalue: colorty);
begin
 fi.colorselectbackground:= avalue;
 changed();
end;

procedure tfonttemplate.setshadow_color(const avalue: colorty);
begin
 fi.shadow_color:= avalue;
 changed();
end;

procedure tfonttemplate.setshadow_shiftx(const avalue: integer);
begin
 fi.shadow_shiftx:= avalue;
 changed();
end;

procedure tfonttemplate.setshadow_shifty(const avalue: integer);
begin
 fi.shadow_shifty:= avalue;
 changed();
end;

procedure tfonttemplate.setgloss_color(const avalue: colorty);
begin
 fi.gloss_color:= avalue;
 changed();
end;

procedure tfonttemplate.setgloss_shiftx(const avalue: integer);
begin
 fi.gloss_shiftx:= avalue;
 changed();
end;

procedure tfonttemplate.setgloss_shifty(const avalue: integer);
begin
 fi.gloss_shifty:= avalue;
 changed();
end;

procedure tfonttemplate.setgrayed_color(const avalue: colorty);
begin
 fi.grayed_color:= avalue;
 changed();
end;

procedure tfonttemplate.setgrayed_colorshadow(const avalue: colorty);
begin
 fi.grayed_colorshadow:= avalue;
 changed();
end;

procedure tfonttemplate.setgrayed_shiftx(const avalue: integer);
begin
 fi.grayed_shiftx:= avalue;
 changed();
end;

procedure tfonttemplate.setgrayed_shifty(const avalue: integer);
begin
 fi.grayed_shifty:= avalue;
 changed();
end;

procedure tfonttemplate.setstyle(const avalue: fontstylesty);
begin
 fi.style:= avalue;
 changed();
end;

procedure tfonttemplate.setxscale(const avalue: real);
begin
 fi.xscale:= avalue;
 changed();
end;

procedure tfonttemplate.doassignto(dest: tpersistent);
begin
 if dest is tfont then begin
  with tfont(dest) do begin
   settemplateinfo(self.fi);
  end;
 end;
end;

function tfonttemplate.getinfosize: integer;
begin
 result:= sizeof(fi);
end;

function tfonttemplate.getinfoad: pointer;
begin
 result:= @fi;
end;

procedure tfonttemplate.setheight(const avalue: integer);
begin
 fi.height:= avalue;
 changed();
end;

procedure tfonttemplate.setwidth(const avalue: integer);
begin
 fi.width:= avalue;
 changed();
end;

procedure tfonttemplate.setextraspace(const avalue: integer);
begin
 fi.extraspace:= avalue;
 changed();
end;

procedure tfonttemplate.setname(const avalue: string);
begin
 fi.name:= avalue;
 changed();
end;

procedure tfonttemplate.setcharset(const avalue: string);
begin
 fi.charset:= avalue;
 changed();
end;

procedure tfonttemplate.setoptions(const avalue: fontoptionsty);
begin
 fi.options:= avalue;
 changed();
end;

initialization
{$ifdef mse_flushgdi}
 flushgdi:= true;
{$endif}
// setlength(gdifuncs,1); //item 0 = system default
// gdifuncs[0]:= gui_getgdifuncs;
finalization
 deinit;
end.
