{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msex11gdi;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 {$ifdef FPC}xlib{$else}Xlib{$endif},mxft,
 {$ifdef FPC}x,xutil,dynlibs,{$endif}
 msegraphics,mseguiglob,msestrings,msegraphutils,mseguiintf,msetypes,
 msectypes,mxrender,msefontconfig,msetriaglob;

procedure init(const adisp: pdisplay; const avisual: msepvisual;
                 const adepth: integer);
function hasxft: boolean;
function fontdatatoxftpat(const fontdata: fontdataty;
                                       const highres: boolean): pfcpattern;
procedure getxftfontdata(po: pxftfont; var drawinfo: drawinfoty);
 
function x11getgdifuncs: pgdifunctionaty;
//function x11getgdinum: integer;

//function x11creategc(paintdevice: paintdevicety; const akind: gckindty;
//     var gc: gcty; const aprintername: msestring): guierrorty;
function x11regiontorects(const aregion: regionty): rectarty;
function x11getdefaultfontnames: defaultfontnamesty;

type
 createcolorpicfuncty = function(const acolor: txrendercolor): tpicture;
var 
 createcolorpic: createcolorpicfuncty;
// pictformats: array[bitmapkindty] of pxrenderpictformat;
 screenrenderpictformat,bitmaprenderpictformat,
                   alpharenderpictformat,
 rgbrenderpictformat,argbrenderpictformat: pxrenderpictformat;

function createalphapicture(const size: sizety;
                               const arepeat: boolean = false): tpicture;
function creatergbpicture(const size: sizety; 
          const arepeat: boolean = false; 
                            const alphamap: tpicture = 0): tpicture;
function createargbpicture(const size: sizety;
                               const arepeat: boolean = false): tpicture;

{$ifdef FPC}
 {$macro on}
 {$define xchar2b:=txchar2b}
 {$define xcharstruct:=txcharstruct}
 {$define xfontstruct:=txfontstruct}
 {$define xfontprop:=txfontprop}
 {$define xpoint:=txpoint}
 {$define xgcvalues:=txgcvalues}
 {$define region:=tregion}
 {$define ximage:=tximage}
 {$define xwindowattributes:=txwindowattributes}
 {$define xclientmessageevent:=txclientmessageevent}
 {$define xtype:=_type}
 {$define xrectangle:=txrectangle}
 {$define keysym:=tkeysym}
 {$define xsetwindowattributes:=txsetwindowattributes}
 {$define xwindowchanges:=txwindowchanges}
 {$define xevent:=txevent}
 {$define xfunction:=_function}
 {$define xwindow:=window}
 {$define xlookupkeysym_:=xlookupkeysymval}
 {$define c_class:= _class}
 {$define xtextproperty:= txtextproperty}
{$endif}
type

 //from region.h
 box = record
  x1,x2,y1,y2: smallint
 end;
 pbox = ^box;
 XRegion = record
    size: clong;
    numRects: clong;
    rects: pbox;
    extents: box;
 end;
 pxregion = ^xregion;

 fontmatrixmodety = (fmm_fix,fmm_linear,fmm_matrix);
 x11fontdatadty = record
  infopo: pxfontstruct;
  matrixmode: fontmatrixmodety;
  defaultwidth: integer;
  xftascent,xftdescent: integer;
  rowlength: word;
  xftdirection: graphicdirectionty;
 end;
 px11fontdatadty = ^x11fontdatadty;
 x11fontdataty = record
  case integer of
   0: (d: x11fontdatadty;);
   1: (_bufferspace: fontdatapty;);
 end;
 

{$ifndef staticxft}
var //xft functions
 XftDrawDestroy: procedure(draw:PXftDraw); cdecl;
 XftDrawSetClipRectangles: function (draw:PXftDraw; xOrigin:longint;
         yOrigin:longint; rects:PXRectangle; n:longint):TFcBool;cdecl;
 XftDrawCreate: function(dpy:PDisplay; drawable:TDrawable; visual:PVisual;
       colormap:TColormap): PXftDraw;cdecl;
 XftDrawSetClip: function(draw:PXftDraw; r:TRegion):TFcBool;cdecl;
 XftTextExtents16: procedure(dpy:PDisplay; pub:PXftFont;
  _string: pwidechar{PFcChar16}; len:longint; extents:PXGlyphInfo);cdecl;
 XftFontOpenName: function(dpy:PDisplay; screen:longint; name:Pchar):PXftFont;cdecl;
 XftFontClose: procedure(dpy:PDisplay; pub:PXftFont);cdecl;
 XftDrawString16: procedure(draw:PXftDraw; color:PXftColor; pub:PXftFont; 
           x:longint; y:longint; _string:pwidechar; len:longint);cdecl;
 XftDefaultHasRender: function(dpy:PDisplay):TFcBool;cdecl;
 XftGetVersion: function():longint;cdecl;
 XftInit: function(config:Pchar):TFcBool;cdecl;
 XftInitFtLibrary: function ():TFcBool;cdecl;

 XftCharExists: function(dpy:PDisplay; pub:PXftFont; ucs4:TFcChar32):TFcBool;cdecl;
 XftNameParse: function(name:Pchar): PFcPattern;cdecl;
 XftFontMatch: function(dpy:PDisplay; screen:longint; pattern:PFcPattern;
                                  result:PFcResult): PFcPattern;cdecl;
 XftFontOpenPattern: function(dpy:PDisplay; pattern:PFcPattern):PXftFont;cdecl;
 XftDefaultSubstitute: procedure(dpy:PDisplay; screen:longint;
                        pattern:PFcPattern);cdecl;
 XftDrawPicture: function(draw: PXftDraw): tpicture; cdecl;
 XftDrawSrcPicture: function(draw: pXftDraw; color: pXftColor): tpicture; cdecl;
{$endif}

var
 XRenderSetPictureClipRectangles: procedure(dpy:PDisplay; picture:TPicture;
            xOrigin:longint; yOrigin:longint; rects:PXRectangle; n:longint);
           cdecl;
 XRenderSetPictureClipRegion: procedure(dpy: pDisplay; picture: TPicture;
                                        r: regionty); cdecl;
 XRenderCreatePicture: function(dpy:PDisplay; drawable:TDrawable;
      format: PXRenderPictFormat; valuemask: culong;
      attributes: PXRenderPictureAttributes): TPicture; cdecl;
 XRenderFillRectangle: procedure(dpy: PDisplay; op: longint; dst: TPicture;
              color: PXRenderColor; x: longint;
              y: longint; width: dword; height: dword);cdecl;
 XRenderSetPictureTransform: procedure(dpy:PDisplay; picture:TPicture;
                                        transform:PXTransform);
          cdecl;
 XRenderSetPictureFilter: procedure(dpy:PDisplay; picture:TPicture;
                      filter: pchar; params: pinteger; nparams: integer);
          cdecl;
 XRenderCreateSolidFill: function(dpy: pDisplay;
                           color: pXRenderColor): TPicture; cdecl;

 XRenderFreePicture: procedure(dpy:PDisplay; picture:TPicture);
                 cdecl;
 XRenderComposite: procedure(dpy:PDisplay; op:longint; src:TPicture;
              mask:TPicture; dst:TPicture;
              src_x:longint; src_y:longint; mask_x:longint; mask_y:longint;
              dst_x:longint;
              dst_y:longint; width:dword; height:dword);cdecl;
 XRenderQueryExtension: function(dpy: PDisplay; event_basep: Pinteger;
                  error_basep: Pinteger): TBool;cdecl;
 XRenderFindVisualFormat: function(dpy: PDisplay;
                            visual: PVisual): PXRenderPictFormat;cdecl;
 XRenderFindStandardFormat:  function(dpy: PDisplay;
                               format: longint): PXRenderPictFormat; cdecl;
 XRenderFindFormat: function(dpy: PDisplay; mask: culong;
         templ: PXRenderPictFormat; count: longint): PXRenderPictFormat; cdecl;

 XRenderCompositeTriangles: procedure(dpy: pDisplay; op: cint; src: tPicture;
                  dst: tPicture; maskFormat: pXRenderPictFormat;
                  xSrc: cint; ySrc: cint; triangles: pXTriangle;
                  ntriangle: cint); cdecl;
 XRenderCompositeTriStrip: procedure(dpy: pdisplay; op: cint; src: tpicture;
               dst: tpicture; maskFormat: PXRenderPictFormat;
               xSrc: cint; ySrc: cint; points: PXPointFixed;
               npoint: cint); cdecl;
 XRenderCompositeTriFan: procedure(dpy: pdisplay; op: cint; src: tpicture;
               dst: tpicture; maskFormat: PXRenderPictFormat;
               xSrc: cint; ySrc: cint; points: PXPointFixed;
               npoint: cint); cdecl;
 XRenderChangePicture: procedure(dpy: pdisplay; picture: tpicture;
             valuemask: culong; attributes: PXRenderPictureAttributes); cdecl;

implementation
uses
 msesys,msesonames,sysutils,msefcfontselect,msedynload,
 msepolytria,mselinetria,mseellipsetria;

//
//todo: optimise tesselation
//

(*
//function fontdatatoxftname(const fontdata: fontdataty): string;
*)
type
 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);

const
// xrenderlineshiftx = 65536 div 2;
// xrenderlineshifty = 65536 div 2;
// xrenderfillshiftx = 0;
// xrenderfillshifty = 0;
 xrenderop = pictopover;
 xrendercolorsourcesize = 1;
 xrendernullcolor: txrendercolor = (red: 0; green: 0; blue: 0; alpha: 0);
 
 capstyles: array[capstylety] of integer = (capbutt,capround,capprojecting);
 joinstyles: array[joinstylety] of integer = (joinmiter,joinround,joinbevel);
 defaultfontnames: defaultfontnamesty =
  //stf_default  stf_empty stf_unicode stf_menu stf_message stf_hint stf_report
   ('Helvetica',   '',        '',       '',       '',          '',    'Arial',    
  //stf_proportional  stf_fixed,
   'Helvetica',       'Courier',
  //stf_helvetica stf_roman          stf_courier
   'Arial',       'Times New Roman', 'Courier New');

 xftdefaultfontnames: defaultfontnamesty =
  //stf_default  stf_empty stf_unicode stf_menu stf_message stf_hint stf_report
      ('sans',       '',       '',         '',   '',           '',      'Arial',
  //stf_proportional  stf_fixed,
   'sans',           'monospace',
  //stf_helvetica stf_roman   stf_courier
   'Arial',       'serif',   'Courier New');
const
 wholecircle = 360*64;

type
 fontpropertiesty = (
     FOUNDRY,FAMILY_NAME,WEIGHT_NAME,SLANT,SETWIDTH_NAME,ADD_STYLE_NAME,
     PIXEL_SIZE,POINT_SIZE,RESOLUTION_X,RESOLUTION_Y,SPACING,AVERAGE_WIDTH,
     CHARSET_REGISTRY,CHARSET_ENCODING,{QUAD_WIDTH,RESOLUTION,}MIN_SPACE,
     NORM_SPACE,MAX_SPACE,END_SPACE,SUPERSCRIPT_X,SUPERSCRIPT_Y,SUBSCRIPT_X,
     SUBSCRIPT_Y,UNDERLINE_POSITION,UNDERLINE_THICKNESS,STRIKEOUT_ASCENT,
     STRIKEOUT_DESCENT,ITALIC_ANGLE,X_HEIGHT,WEIGHT,FACE_NAME,{FULL_NAME,}
     FONT,COPYRIGHT,AVG_CAPITAL_WIDTH,AVG_LOWERCASE_WIDTH,RELATIVE_SETWIDTH,
     RELATIVE_WEIGHT,CAP_HEIGHT,SUPERSCRIPT_SIZE,FIGURE_WIDTH,SUBSCRIPT_SIZE,
     SMALL_CAP_SIZE,NOTICE,DESTINATION,FONT_TYPE,FONT_VERSION,RASTERIZER_NAME,
     RASTERIZER_VERSION,RAW_ASCENT,RAW_DESCENT,AXIS_NAMES,AXIS_LIMITS,
     AXIS_TYPES,fpnone);

 fontpropty = record
  name: string; isstring: boolean;
 end;

 intfontproparty = array[fontpropertiesty] of ptrint;
 strfontproparty = array[fontpropertiesty] of string;

 const
 fontpropertynames: array[fontpropertiesty] of fontpropty = (
     (name: 'FOUNDRY'; isstring: true),
     (name: 'FAMILY_NAME'; isstring: true),
     (name: 'WEIGHT_NAME'; isstring: true),
     (name: 'SLANT'; isstring: true),
     (name: 'SETWIDTH_NAME'; isstring: true),
     (name: 'ADD_STYLE_NAME'; isstring: true),
     (name: 'PIXEL_SIZE'; isstring: false),
     (name: 'POINT_SIZE'; isstring: false),
     (name: 'RESOLUTION_X'; isstring: false),
     (name: 'RESOLUTION_Y'; isstring: false),
     (name: 'SPACING'; isstring: true),
     (name: 'AVERAGE_WIDTH'; isstring: false),
     (name: 'CHARSET_REGISTRY'; isstring: true),
     (name: 'CHARSET_ENCODING'; isstring: true),
     {'QUAD_WIDTH','RESOLUTION',}
     (name: 'MIN_SPACE'; isstring: false),
     (name: 'NORM_SPACE'; isstring: false),
     (name: 'MAX_SPACE'; isstring: false),
     (name: 'END_SPACE'; isstring: false),
     (name: 'SUPERSCRIPT_X'; isstring: false),
     (name: 'SUPERSCRIPT_Y'; isstring: false),
     (name: 'SUBSCRIPT_X'; isstring: false),
     (name: 'SUBSCRIPT_Y'; isstring: false),
     (name: 'UNDERLINE_POSITION'; isstring: false),
     (name: 'UNDERLINE_THICKNESS'; isstring: false),
     (name: 'STRIKEOUT_ASCENT'; isstring: false),
     (name: 'STRIKEOUT_DESCENT'; isstring: false),
     (name: 'ITALIC_ANGLE'; isstring: false),
     (name: 'X_HEIGHT'; isstring: false),
     (name: 'WEIGHT'; isstring: false),
     (name: 'FACE_NAME'; isstring: true),
     {'FULL_NAME',}
     (name: 'FONT'; isstring: true),
     (name: 'COPYRIGHT'; isstring: true),
     (name: 'AVG_CAPITAL_WIDTH'; isstring: false),
     (name: 'AVG_LOWERCASE_WIDTH'; isstring: false),
     (name: 'RELATIVE_SETWIDTH'; isstring: false),
     (name: 'RELATIVE_WEIGHT'; isstring: false),
     (name: 'CAP_HEIGHT'; isstring: false),
     (name: 'SUPERSCRIPT_SIZE'; isstring: false),
     (name: 'FIGURE_WIDTH'; isstring: false),
     (name: 'SUBSCRIPT_SIZE'; isstring: false),
     (name: 'SMALL_CAP_SIZE'; isstring: false),
     (name: 'NOTICE'; isstring: true),
     (name: 'DESTINATION'; isstring: false),
     (name: 'FONT_TYPE'; isstring: true),
     (name: 'FONT_VERSION'; isstring: true),
     (name: 'RASTERIZER_NAME'; isstring: true),
     (name: 'RASTERIZER_VERSION'; isstring: true),
     (name: 'RAW_ASCENT'; isstring: false),
     (name: 'RAW_DESCENT'; isstring: false),
     (name: 'AXIS_NAMES'; isstring: true),
     (name: 'AXIS_LIMITS'; isstring: true),
     (name: 'AXIS_TYPES'; isstring: true),
     (name: ''; isstring: false)
     );

var
 appdisp: pdisplay;
 defvisual: msepvisual;
 defdepth: integer;
 hasxrender: boolean;
 fhasxft: boolean;
type
 xftcolorcacheinfoty = record
  picture: tpicture;
  pixel: pixelty;
 end;
 
const
 xftcolorcachemask = $1f;
type
 xftstatety = (xfts_clipregionvalid,xfts_smooth,xfts_foregroundvalid,
               xfts_monobrush);
 xftstatesty = set of xftstatety;
 x11gcdty = record
  triainfo: triainfoty; //first!
  gcdrawingflags: drawingflagsty;
  gcrasterop: rasteropty;
  gcclipregion: regionty;
  xftdraw: pxftdraw;
  xftdrawpic: tpicture;
  xftcolor: txftcolor;
  xftcolorbackground: txftcolor;
  xftfont: pxftfont;
  xftfontdata: px11fontdatadty;
  xftstate: xftstatesty;
  xftforegroundpic: tpicture;
//  xftcolorforegroundpicx: xftcolorcacheinfoty;
//  xftcolorbackgroundpicx: xftcolorcacheinfoty;
  xftbrush: pixmapty;
  xftbrushorigin: pointty;
  xftbrushsize: sizety;
  xftbrushpic: tpicture;
  xftbrushalphapic: tpicture;
 end;
 {$if sizeof(x11gcdty) > sizeof(gcpty)} {$error 'buffer overflow'}{$ifend}
 x11gcty = record
  case integer of
   0: (d: x11gcdty;);
   1: (_bufferspace: gcpty;);
 end;
 
var
// xftcolorcache: array[0..xftcolorcachemask] of xftcolorcacheinfoty;
 fontpropertyatoms: array[fontpropertiesty] of atom;
 
procedure init(const adisp: pdisplay; const avisual: msepvisual;
               const adepth: integer);
var
 int1,int2: integer;
 fontpropnames: strfontproparty;
 propnum: fontpropertiesty;
begin
 appdisp:= adisp;
 defvisual:= avisual;
 defdepth:= adepth;
 
 hasxrender:= hasxrender and 
                  (xrenderqueryextension(msedisplay,@int1,@int2) <> 0);
 if hasxrender then begin
//  pictformats[bmk_mono]:= xrenderfindstandardformat(appdisp,pictstandarda1);
//  pictformats[bmk_gray]:= xrenderfindstandardformat(appdisp,pictstandarda8);  
//  pictformats[bmk_rgb]:= xrenderfindvisualformat(appdisp,pvisual(defvisual));
  screenrenderpictformat:= xrenderfindvisualformat(appdisp,pvisual(defvisual));
  bitmaprenderpictformat:= xrenderfindstandardformat(appdisp,pictstandarda1);
  alpharenderpictformat:= xrenderfindstandardformat(appdisp,pictstandarda8);
  rgbrenderpictformat:= xrenderfindstandardformat(appdisp,pictstandardrgb24);
  argbrenderpictformat:= xrenderfindstandardformat(appdisp,pictstandardargb32);
 end;
 if not noxft then begin
  fhasxft:= fhasxft and xftdefaulthasrender(appdisp) and (xftgetversion() >= 20000);
  if fhasxft then begin
   fhasxft:= xftinit(nil);
   if fhasxft then begin
    fhasxft:= xftinitftlibrary();
    if fhasxft and not hasdefaultfontarg then begin
     defaultfontinfo[fn_family_name]:= 'sans';
    end;
   end;
  end;
 end
 else begin
  fhasxft:= false;
 end;
  for propnum:= low(fontpropertiesty) to high(fontpropertiesty) do begin
   fontpropnames[propnum]:= fontpropertynames[propnum].name;
  end;
 
  xinternatoms(appdisp,@fontpropnames[low(fontpropertiesty)],
           integer(high(fontpropertiesty)),{$ifdef xboolean}true{$else}1{$endif},
           @fontpropertyatoms[low(fontpropertiesty)]);
 
end;

function fontinfotoxlfdname(const info: fontinfoty): string;
var
 en1: fontnamety;
begin
 result:= '';
 for en1:= low(fontnamety) to high(fontnamety) do begin
  result:= result + '-' + info[en1];
 end;
end;

procedure getxftfontdata(po: pxftfont; var drawinfo: drawinfoty);
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 if po <> nil then begin
 {$ifdef FPC} {$checkpointer off} {$endif}
  with drawinfo.getfont.fontdata^,x11fontdataty(platformdata) do begin
   font:= ptruint(po);
   ascent:= po^.ascent;
   descent:= po^.descent;
 //   linespacing:= ascent + descent;
   linespacing:= po^.height;
//   realheight:= po^.height;
   caretshift:= 0;
   d.infopo:= nil;
   d.xftascent:= po^.ascent;
   d.xftdescent:= po^.descent;
   d.xftdirection:= gd_right;
  end;
 {$ifdef FPC} {$checkpointer default} {$endif}
 end;
end;

(*
function buildxftname(const fontdata: fontdataty; 
                                      const fontinfo: fontinfoty): ansistring;
var
 str1: ansistring;
 int1: integer;
begin
 with fontdata do begin
  str1:= '';
  if fontinfo[fn_foundry] <> '*' then begin
   str1:= str1+':foundry='+fontinfo[fn_foundry];
  end;
  if (familyoptions = []) then begin
   if (pitchoptions = []) and (fontinfo[fn_family_name] <> '*') then begin
    str1:= str1 + ':family=' + fontinfo[fn_family_name];
   end;
  end
  else begin
   if foo_helvetica in familyoptions then begin
    str1:= str1 + ':family=sans';
   end
   else begin
    if foo_roman in familyoptions then begin
     str1:= str1 + ':family=serif';
    end
    else begin
     if foo_decorative in familyoptions then begin
     end
     else begin
      if foo_script in familyoptions then begin
      end;
     end;
    end;
   end;
  end;
  if fs_bold in style then begin
   str1:= str1 + ':bold';
  end;
  if fs_italic in style then begin
   str1:= str1 + ':italic';
  end;
  if fontinfo[fn_pixel_size] <> '*' then begin
   str1:= str1 + ':pixelsize=' + fontinfo[fn_pixel_size];
  end;
  if fontinfo[fn_average_width] <> '*' then begin
   try
    int1:= (strtoint(fontinfo[fn_average_width]) + 5) div 10;
    str1:= str1 + ':charwidth='+inttostr(int1);
   except
   end;
  end;
  if foo_fixed in pitchoptions then begin
   str1:= str1 + ':mono';
  end;
  if foo_proportional in pitchoptions then begin
   str1:= str1 + ':proportional';
  end;
  if foo_antialiased in antialiasedoptions then begin
   str1:= str1 + ':antialias=1';
  end;
  if foo_nonantialiased in antialiasedoptions then begin
   str1:= str1 + ':antialias=0';
  end;
  {
  if foo_xcore in xcoreoptions then begin
   str1:= str1 + ':core=1';
  end;
  if foo_noxcore in xcoreoptions then begin
   str1:= str1 + ':core=0';
  end;
  }
  if fontinfo[fn_charset_registry] <> '*' then begin
   str1:= str1 + ':encoding=' + fontinfo[fn_charset_registry];
   if fontinfo[fn_encoding] <> '*' then begin
    str1:= str1 +'-'+fontinfo[fn_encoding];
   end;
  end;
 end;
 result:= str1;
end;
*)

{
function fontdatatoxftname(const fontdata: fontdataty): ansistring;
var
 fontinfo: fontinfoty;
begin
 setupfontinfo(fontdata,fontinfo);
 result:= buildxftname(fontdata,fontinfo);
end;
}
function fontdatatoxftpat(const fontdata: fontdataty; const highres: boolean): pfcpattern;
var
 fontinfo: fontinfoty;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 setupfontinfo(fontdata,fontinfo);
 result:= buildxftpat(fontdata,fontinfo,highres);
end;

procedure gdi_createpixmap(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.createpixmap do begin
  pixmap:= gui_createpixmap(size,0,kind,copyfrom);
 end;
end;

procedure gdi_pixmaptoimage(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.pixmapimage do begin
  gui_pixmaptoimage(pixmap,image,drawinfo.gc.handle);
 end;
end;

procedure gdi_imagetopixmap(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.pixmapimage do begin
  error:= gui_imagetopixmap(image,pixmap,drawinfo.gc.handle);
 end;
end;

//function x11creategc(paintdevice: paintdevicety; const akind: gckindty;
//     var gc: gcty; const aprintername: msestring): guierrorty;
procedure gdi_creategc(var drawinfo: drawinfoty); //gdifunc
begin
// gdi_lock;
 with drawinfo.creategc do begin
//  gcpo^.gdifuncs:= getdefaultgdifuncs;
  gcpo^.gdifuncs:= x11getgdifuncs;
  if paintdevice = 0 then begin
   paintdevice:= mserootwindow;
  end;
  gcpo^.handle:= ptruint(xcreategc(appdisp,paintdevice,0,nil));
  if gcpo^.handle = 0 then begin
   error:= gde_creategc;
  end
  else begin
   xsetgraphicsexposures(appdisp,tgc(gcpo^.handle),
                             {$ifdef xboolean}false{$else}0{$endif});
   with x11gcty(gcpo^.platformdata) do begin
    //nothing to do, gc is nulled
   end;
   error:= gde_ok;
  end;
 end;
// gdi_unlock;
end;

procedure transformpoints(var drawinfo: drawinfoty; const aclose: boolean);
var
 po1: ppointty;
 po2: pxpoint;
 int1: integer;
begin
 with drawinfo,drawinfo.points do begin
  int1:= count;
  if aclose then begin
   inc(int1);
  end;
  allocbuffer(buffer,int1*sizeof(xpoint));
  int1:= count;
  po1:= points;
  po2:= buffer.buffer;
  with origin do begin
   while int1 > 0 do begin
    po2^.x:= po1^.x + x;
    po2^.y:= po1^.y + y;
    inc(po1);
    inc(po2);
    dec(int1);
   end;
  end;
  if aclose then begin
   move(buffer.buffer^,(pchar(buffer.buffer)+count*sizeof(xpoint))^,sizeof(xpoint));
  end;
 end;
end;

procedure transformpos(var drawinfo: drawinfoty);
begin
 with drawinfo,drawinfo.pos do begin
  allocbuffer(buffer,sizeof(xpoint));
  with pxpoint(buffer.buffer)^ do begin
   x:= pos^.x + origin.x;
   y:= pos^.y + origin.y;
  end;
 end;
end;

function transformtext16pos(var drawinfo: drawinfoty): pxchar2b;
var
 po1: pword;
 po2: pword;
 int1: integer;
begin
 with drawinfo,drawinfo.text16pos do begin
  allocbuffer(buffer,sizeof(xpoint)+count*2);
  with pxpoint(buffer.buffer)^ do begin
   x:= pos^.x + origin.x;
   y:= pos^.y + origin.y;
  end;
  po1:= pword(text);
  result:= pxchar2b(pchar(buffer.buffer) + sizeof(xpoint));
  po2:= pword(result);
  for int1:= count-1 downto 0 do begin
   po2^:= (po1^ shl 8) or (po1^ shr 8); //simply swap bytes
   inc(po1);
   inc(po2);
  end;
 end;
end;

function x11regiontorects(const aregion: regionty): rectarty;
var
 int1: integer;
 boxpo: pbox;
begin
 gdi_lock;
 if aregion = 0 then begin
  result:= nil;
 end
 else begin
  with pxregion(aregion)^ do begin
   setlength(result,numrects);
   boxpo:= rects;
   for int1:= 0 to numrects-1 do begin
    with boxpo^,result[int1] do begin
     x:= x1;
     y:= y1;
     cx:= x2 - x1;
     cy:= y2 - y1;
    end;
    inc(boxpo);
   end;
  end;
 end;
 gdi_unlock;
end;

function x11getdefaultfontnames: defaultfontnamesty;
begin
 if fhasxft then begin
  result:= xftdefaultfontnames;
 end
 else begin
  result:= defaultfontnames;
 end;
end;
 
procedure freexftbrush(var drawinfo: drawinfoty);
begin
 with x11gcty(drawinfo.gc.platformdata).d do begin
  if xftbrushpic <> 0 then begin
   xrenderfreepicture(appdisp,xftbrushpic);
   xftbrushpic:= 0;
  end;
  if xftbrushalphapic <> 0 then begin
   xrenderfreepicture(appdisp,xftbrushalphapic);
   xftbrushalphapic:= 0;
  end;
 end;
end;

procedure gdi_destroygc(var drawinfo: drawinfoty); //gdifunc
begin
 gdi_lock;
 with drawinfo do begin
  with x11gcty(gc.platformdata).d do begin
   if xftdraw <> nil then begin
    freexftbrush(drawinfo);
    xftdrawdestroy(xftdraw);
   end;
  end;
  xfreegc(appdisp,tgc(gc.handle));
 end;
 gdi_unlock;
end;

function colortorendercolor(const avalue: rgbtriplety): txrendercolor; overload;
begin
 with result do begin
  red:= (avalue.red shl 8) or avalue.red;
  green:= (avalue.green shl 8) or avalue.green;
  blue:= (avalue.blue shl 8) or avalue.blue;
  alpha:= $ffff;
 end;
end;

function colortorendercolor(const avalue: colorty): txrendercolor; overload;
begin
 result:= colortorendercolor(colortorgb(avalue));
end;

function alphatorendercolor(const avalue: rgbtriplety): txrendercolor; overload;
var
 wo1: word;
begin
 with result do begin
  wo1:= (integer(avalue.red)+integer(avalue.green)+integer(avalue.blue)) div 3;
  wo1:= wo1 or (wo1 shl 8);
  red:= 0;
  green:= 0;
  blue:= 0;
  alpha:= wo1;
 end;
end;

function alphatorendercolor(const avalue: colorty): txrendercolor; overload;
begin
 result:= alphatorendercolor(colortorgb(avalue));
end;

function graytorendercolor(const avalue: rgbtriplety): txrendercolor; overload;
var
 wo1: word;
begin
 with result do begin
  wo1:= (integer(avalue.red)+integer(avalue.green)+integer(avalue.blue)) div 3;
  wo1:= wo1 or (wo1 shl 8);
  red:= wo1;
  green:= wo1;
  blue:= wo1;
  alpha:= $ffff;
 end;
end;

function graytorendercolor(const avalue: colorty): txrendercolor; overload;
begin
 result:= graytorendercolor(colortorgb(avalue));
end;

procedure setregion(var gc: gcty; const aregion: region;
                 const pic: tpicture = 0; const draw: pxftdraw = nil);
var
 po1,rectspo: pxrectangle;
 boxpo: pbox;
 int1: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 {$ifdef FPC} {$checkpointer off} {$endif}
 with pxregion(aregion)^ do begin
  if numrects > 0 then begin
   boxpo:= rects;
   getmem(rectspo,numrects*sizeof(xrectangle));
   po1:= rectspo;
   for int1:= numrects - 1 downto 0 do begin
    rectspo^.x:= boxpo^.x1;
    rectspo^.y:= boxpo^.y1;
    rectspo^.width:= boxpo^.x2-boxpo^.x1;
    rectspo^.height:= boxpo^.y2-boxpo^.y1;
    inc(boxpo);
    inc(rectspo);
   end;
   if pic <> 0 then begin
    xrendersetpicturecliprectangles(appdisp,pic,gc.cliporigin.x,
                            gc.cliporigin.y,po1,numrects);
   end
   else begin
    if draw <> nil then begin
     xftdrawsetcliprectangles(draw,gc.cliporigin.x,gc.cliporigin.y,po1,numrects);
    end
    else begin
     xsetcliprectangles(appdisp,tgc(gc.handle),gc.cliporigin.x,gc.cliporigin.y,po1,numrects,yxbanded);
    end;
   end;
   freemem(po1);
  end
  else begin
   if pic <> 0 then begin
    xrendersetpicturecliprectangles(appdisp,pic,gc.cliporigin.x,gc.cliporigin.y,nil,0);
   end
   else begin
    if draw <> nil then begin
     xftdrawsetcliprectangles(draw,gc.cliporigin.x,gc.cliporigin.y,nil,0);
    end
    else begin
     xsetcliprectangles(appdisp,tgc(gc.handle),gc.cliporigin.x,gc.cliporigin.y,nil,0,yxbanded);
    end;
   end;
  end;
 end;
 {$ifdef FPC} {$checkpointer default} {$endif}
end;

const
 unitytransform: txtransform = ((65536,0,0),
                                (0,65536,0),
                                (0,0,65536));

function creatergbpicture(const size: sizety; 
          const arepeat: boolean = false; 
                            const alphamap: tpicture = 0): tpicture;
var
 attributes: txrenderpictureattributes;
 pixmap: pixmapty;
 int1: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= xcreatepixmap(appdisp,mserootwindow,size.cx,size.cy,24);
 attributes._repeat:= repeatnormal;
 attributes.alpha_map:= alphamap;
 int1:= 0;
 if arepeat then begin
  int1:= cprepeat;
 end;
 if alphamap <> 0 then begin
  int1:= int1 or cpalphamap;
 end;
 result:= xrendercreatepicture(appdisp,pixmap,
                                   rgbrenderpictformat,int1,@attributes);
 xfreepixmap(appdisp,pixmap);
end;

function createalphapicture(const size: sizety; 
                                const arepeat: boolean = false): tpicture;
var
 attributes: txrenderpictureattributes;
 pixmap: pixmapty;
 int1: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= xcreatepixmap(appdisp,mserootwindow,size.cx,size.cy,8);
 attributes._repeat:= repeatnormal;
 int1:= cpcomponentalpha;
 if arepeat then begin
  int1:= cprepeat;
 end;
 result:= xrendercreatepicture(appdisp,pixmap,
                alpharenderpictformat,int1,@attributes);
 xfreepixmap(appdisp,pixmap);
end;

function createargbpicture(const size: sizety;
                              const arepeat: boolean = false): tpicture;
var
 attributes: txrenderpictureattributes;
 pixmap: pixmapty;
 int1: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= xcreatepixmap(appdisp,mserootwindow,size.cx,size.cy,32);
 attributes._repeat:= repeatnormal;
 int1:= 0;
 if arepeat then begin
  int1:= cprepeat;
 end;
 result:= xrendercreatepicture(appdisp,pixmap,
                                   argbrenderpictformat,int1,@attributes);
 xfreepixmap(appdisp,pixmap);
end;

function createcolorpi(const acolor: txrendercolor;
                              const aformat: pxrenderpictformat): tpicture;
var
 attributes: txrenderpictureattributes;
// col: txrendercolor;
 pixmap: pixmapty;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= gui_createpixmap(
                   makesize(xrendercolorsourcesize,xrendercolorsourcesize));
 attributes._repeat:= repeatnormal;
 result:= xrendercreatepicture(appdisp,pixmap,
                               screenrenderpictformat,cprepeat,@attributes);
// col:= colortorendercolor(acolor);
 xrenderfillrectangle(appdisp,pictopsrc,result,@acolor,0,0,
                        xrendercolorsourcesize,xrendercolorsourcesize);
 xfreepixmap(appdisp,pixmap);
end;

function createcolorpic1(const acolor: txrendercolor): tpicture;
begin
 result:= createcolorpi(acolor,screenrenderpictformat);
end;

function createcolorpic2(const acolor: txrendercolor): tpicture;
//var
// col: txrendercolor;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
// col:= colortorendercolor(acolor);
 result:= xrendercreatesolidfill(appdisp,@acolor);
end;

function createcolorpicture(const acolor: colorty): tpicture;
begin
 result:= createcolorpic(colortorendercolor(acolor));
end;

function creategraycolorpicture(const acolor: colorty): tpicture;
begin
 result:= createcolorpic(graytorendercolor(acolor));
end;
{
function creategraypicture(const acolor: colorty): tpicture;
begin
 result:= createcolorpi(alphatorendercolor(acolor),alpharenderpictformat);
end;
}
function createmaskpicture(const acolor: rgbtriplety): tpicture; overload;
var
 attributes: txrenderpictureattributes;
 col: txrendercolor;
 pixmap: pixmapty;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= gui_createpixmap(makesize(1,1));
 attributes._repeat:= repeatnormal;
 attributes.component_alpha:= 1;
 result:= xrendercreatepicture(appdisp,pixmap,screenrenderpictformat,
                                    cprepeat or cpcomponentalpha,@attributes);
 col:= colortorendercolor(acolor);
 xrenderfillrectangle(appdisp,pictopsrc,result,@col,0,0,1,1);
 gui_freepixmap(pixmap);
end;

function createmaskpicture(const amask: tsimplebitmap): tpicture; overload;
var
 attributes: txrenderpictureattributes;
 handle1: pixmapty;
 format1: pxrenderpictformat;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 result:= 0;
 if amask <> nil then begin
  handle1:= tsimplebitmap1(amask).handle;
  if handle1 <> 0 then begin
   case amask.kind of
    bmk_mono: begin
     format1:= bitmaprenderpictformat;
    end;
    bmk_gray: begin
     format1:= alpharenderpictformat;
    end;
    else begin
     format1:= screenrenderpictformat;
    end;
   end;
   attributes.component_alpha:= 1;
   result:= xrendercreatepicture(appdisp,tsimplebitmap1(amask).handle,
                                          format1,cpcomponentalpha,@attributes);
  end;
 end;
end;

procedure checkxftdraw(var drawinfo: drawinfoty);
var
 attr: txrenderpictureattributes;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with x11gcty(drawinfo.gc.platformdata).d do begin
  if xftdraw = nil then begin
   xftdraw:= xftdrawcreate(appdisp,drawinfo.paintdevice,
                                                 xlib.pvisual(defvisual),0);
   xftdrawpic:= xftdrawpicture(xftdraw);
   attr.poly_edge:= polyedgesmooth;
   attr.poly_mode:= polymodeprecise;
//   attr.poly_mode:= polymodeimprecise;
   xrenderchangepicture(appdisp,xftdrawpic,cppolyedge or cppolymode,@attr);
//   xftcolorforegroundpic:= createcolorpicture(cl_black);
  end;
  if not (xfts_clipregionvalid in xftstate) then begin
   if gcclipregion = 0 then begin
    xftdrawsetclip(xftdraw,nil);
   end
   else begin
    setregion(drawinfo.gc,region(gcclipregion),0,xftdraw);
   end;
   include(xftstate,xfts_clipregionvalid);
  end;
 end;
end;

procedure checkxftstate(var drawinfo: drawinfoty; const aflags: xftstatesty);
 procedure updatemonocolor;
 var
  co1: txrendercolor;
 begin
  with drawinfo.gc,x11gcty(platformdata).d do begin
   if df_opaque in drawingflags then begin
    co1:= xftcolorbackground.color;
   end
   else begin
    co1:= xrendernullcolor;
   end;
   xrenderfillrectangle(appdisp,pictopsrc,xftbrushpic,
                          @co1,0,0,xftbrushsize.cx,xftbrushsize.cy);
   xrendercomposite(appdisp,pictopover,xftdrawsrcpicture(xftdraw,@xftcolor),
                   xftbrushalphapic,xftbrushpic,0,0,0,0,
                               0,0,xftbrushsize.cx,xftbrushsize.cy);
  end;
 end; //updatemonocolor
 
var
 flags1: xftstatesty;
 attributes: txrenderpictureattributes;
//todo: fix xftbrushorigin, seems to be unreliable
begin
 with drawinfo.gc,x11gcty(platformdata).d do begin
  if not (xfts_clipregionvalid in xftstate) then begin
   if gcclipregion = 0 then begin
    xftdrawsetclip(xftdraw,nil);
   end
   else begin
    setregion(drawinfo.gc,region(gcclipregion),0,xftdraw);
   end;
   include(xftstate,xfts_clipregionvalid);
  end;
  flags1:= (xftstate >< aflags) * aflags;
  if xfts_foregroundvalid in flags1 then begin
   if df_brush in drawinfo.gc.drawingflags then begin
    if (xftbrush <> 0) then begin
     if (xftbrushpic = 0) then begin
      attributes._repeat:= repeatnormal;
      if xfts_monobrush in xftstate then begin
       xftbrushalphapic:= xrendercreatepicture(appdisp,xftbrush,
                            bitmaprenderpictformat,cprepeat,@attributes);
       xftbrushpic:= createargbpicture(xftbrushsize,true);
       updatemonocolor;
      end
      else begin
       xftbrushpic:= xrendercreatepicture(appdisp,xftbrush,
                            screenrenderpictformat,cprepeat,@attributes);
      end;
     end
     else begin
      if xfts_monobrush in xftstate then begin
       updatemonocolor;
      end;
     end;
    end;
    xftforegroundpic:= xftbrushpic;
   end
   else begin
    xftforegroundpic:= xftdrawsrcpicture(xftdraw,@xftcolor);
   end;
   include(xftstate,xfts_foregroundvalid);
  end;
 end;
end;
const
 posroundval = $0;//7fff;
 
procedure compositetriangles(var drawinfo: drawinfoty;
                    const triangles: ptrianglety; const trianglecount: integer);
begin
 checkxftstate(drawinfo,[xfts_foregroundvalid]);
 with x11gcty(drawinfo.gc.platformdata).d do begin
  xrendercompositetriangles(appdisp,xrenderop,xftforegroundpic,
           xftdrawpic,alpharenderpictformat,
           xftbrushorigin.x+(ppointty(triangles)^.x+posroundval) div 65536,
           xftbrushorigin.y+(ppointty(triangles)^.y+posroundval) div 65536,
           pxtriangle(triangles),trianglecount);
 end;
end;

procedure compositetristrip(var drawinfo: drawinfoty;
                    const points: ppointty; const pointcount: integer);
begin
 checkxftstate(drawinfo,[xfts_foregroundvalid]);
 with x11gcty(drawinfo.gc.platformdata).d do begin
  xrendercompositetristrip(appdisp,xrenderop,xftforegroundpic,
        xftdrawpic,alpharenderpictformat,
        xftbrushorigin.x+(points^.x+posroundval) div 65536,
        xftbrushorigin.y+(points^.y+posroundval) div 65536,
        pxpointfixed(points),pointcount);
 end;
end;

procedure compositetrifan(var drawinfo: drawinfoty;
                    const points: ppointty; const pointcount: integer);
begin
 checkxftstate(drawinfo,[xfts_foregroundvalid]);
 with x11gcty(drawinfo.gc.platformdata).d do begin
  xrendercompositetrifan(appdisp,xrenderop,xftforegroundpic,
        xftdrawpic,alpharenderpictformat,
        xftbrushorigin.x+(points^.x+posroundval) div 65536,
        xftbrushorigin.y+(points^.y+posroundval) div 65536,
        pxpointfixed(points),pointcount);
 end;
end;

procedure gdi_changegc(var drawinfo: drawinfoty); //gdifunc
var
 xmask: longword;
 xvalues: xgcvalues;
 agc: tgc;
 int1: integer;

begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 xmask:= 0;
 with drawinfo.gcvalues^,drawinfo.gc,x11gcty(platformdata).d do begin
  agc:= tgc(handle);
  if gvm_colorforeground in mask then begin
   xmask:= xmask or gcforeground;
   xvalues.foreground:= colorforeground;
   xvalues.fill_style:= fillsolid;
   if fhasxft then begin
    xftcolor.pixel:= colorforeground;
    xftcolor.color:= colortorendercolor(drawinfo.acolorforeground);
    exclude(xftstate,xfts_foregroundvalid);
   end;
  end;
  if (drawingflags >< gcdrawingflags)
           * (fillmodeinfoflags+[df_smooth]) <> [] then begin
   xmask:= xmask or gcfillstyle;
   if df_brush in drawingflags then begin
    if df_monochrome in drawingflags then begin
     include(xftstate,xfts_monobrush);
     if df_opaque in drawingflags then begin
      xvalues.fill_style:= fillopaquestippled;
     end
     else begin
      xvalues.fill_style:= fillstippled;
     end;
    end
    else begin
     xvalues.fill_style:= filltiled;
    end;
   end
   else begin
    exclude(xftstate,xfts_monobrush);
    xvalues.fill_style:= fillsolid;
   end;
   if (df_smooth in drawingflags) and fhasxft then begin
    checkxftdraw(drawinfo);
    include(xftstate,xfts_smooth);
   end
   else begin
    exclude(xftstate,xfts_smooth);
   end;
  end;
  gcdrawingflags:= drawingflags;

  if gvm_rasterop in mask then begin
   xmask:= xmask or gcfunction;
   xvalues.xfunction:= integer(rasterop);
   gcrasterop:= rasterop;
  end;
  if gvm_linewidth in mask then begin
   xmask:= xmask or gclinewidth;
   xvalues.line_width:= 
                   (lineinfo.width + linewidthroundvalue) shr linewidthshift;
   triainfo.linewidth:= xvalues.line_width;
   if triainfo.linewidth = 0 then begin
    triainfo.linewidth1:= 1;
   end
   else begin
    triainfo.linewidth1:= triainfo.linewidth;
   end;
   triainfo.linewidth16:= triainfo.linewidth1 shl 16;
  end;
  if gvm_dashes in mask then begin
   with lineinfo do begin
    triainfo.xftdashes:= dashes;
    int1:= length(dashes);
    if int1 <> 0 then begin
     if df_opaque in drawingflags then begin
      xvalues.line_style:= linedoubledash;
     end
     else begin
      xvalues.line_style:= lineonoffdash;
     end;
     xsetdashes(appdisp,agc,0,@lineinfo.dashes[1],int1);
    end
    else begin
     xvalues.line_style:= linesolid;
    end;
   end;
   xmask:= xmask or gclinestyle;
  end;
  if gvm_capstyle in mask then begin
//   triainfo.capstyle:= lineinfo.capstyle;
   triainfo.triaflags:= triainfo.triaflags - triacapmask + 
                       triacapflags[lineinfo.capstyle];
   xvalues.cap_style:= capstyles[lineinfo.capstyle];
   xmask:= xmask or gccapstyle;
  end;
  if gvm_joinstyle in mask then begin
//   triainfo.joinstyle:= lineinfo.joinstyle;
   triainfo.triaflags:= triainfo.triaflags - triajoinmask + 
                       triajoinflags[lineinfo.joinstyle];
   xvalues.join_style:= joinstyles[lineinfo.joinstyle];
   xmask:= xmask or gcjoinstyle;
  end;
  if gvm_font in mask then begin
//   fontdirection:= x11fontdataty(fontdata^.platformdata).d.direction;
   if fhasxft then begin
    xftfont:= pxftfont(font);
    xftfontdata:= @x11fontdataty(fontdata^.platformdata).d;
   end
   else begin
    xmask:= xmask or gcfont;
    xvalues.font:= font;
   end;
  end;
  if gvm_colorbackground in mask then begin
   xmask:= xmask or gcbackground;
   xvalues.background:= colorbackground;
   if df_dashed in drawingflags then begin
    if df_opaque in drawingflags then begin
     xvalues.line_style:= linedoubledash;
    end
    else begin
     xvalues.line_style:= lineonoffdash;
    end;
    xmask:= xmask or gclinestyle;
   end;
   if fhasxft then begin
    xftcolorbackground.pixel:= colorbackground;
    xftcolorbackground.color:= colortorendercolor(drawinfo.acolorbackground);
    if xfts_monobrush in xftstate then begin
     exclude(xftstate,xfts_foregroundvalid);
    end;
   end;
  end;
  if gvm_brushorigin in mask then begin
   xmask:= xmask or gctilestipxorigin or gctilestipyorigin;
   xvalues.ts_x_origin:= brushorigin.x;
   xvalues.ts_y_origin:= brushorigin.y;
   xftbrushorigin.x:= -brushorigin.x;//-drawinfo.origin.x;
   xftbrushorigin.y:= -brushorigin.y;//-drawinfo.origin.y;
  end;

  if gvm_brush in mask then begin
   exclude(xftstate,xfts_foregroundvalid);
   with tsimplebitmap1(brush) do begin
    xftbrush:= handle;
    xftbrushsize:= size;
   end;
   freexftbrush(drawinfo);
   if df_monochrome in drawingflags then begin
    xvalues.stipple:= xftbrush;
    xmask:= xmask or gcstipple;
   end
   else begin
    xvalues.tile:= xftbrush;
    xmask:= xmask or gctile;
   end;
  end;
  if xmask <> 0 then begin
   xchangegc(appdisp,agc,xmask,@xvalues);
  end;
  if gvm_clipregion in mask then begin
   exclude(xftstate,xfts_clipregionvalid);
   gcclipregion:= clipregion;
   if clipregion = 0 then begin
    xsetclipmask(appdisp,agc,none);
   end
   else begin
    setregion(drawinfo.gc,region(clipregion));
//    xsetregion(appdisp,agc,region(clipregion));
   end;
  end;
 end;
end;

procedure gdi_getcanvasclass(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_endpaint(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_flush(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_movewindowrect(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.moverect do begin
  gui_movewindowrect(drawinfo.paintdevice,dist^,rect^);  
 end;
end;

function getmatrixcharstruct(char: msechar; const fontdata: x11fontdataty): pxcharstruct;
type
 xchar2b = record
  byte2: byte; //lsb
  byte1: byte; //msb
 end;

begin
{$ifdef FPC} {$checkpointer off} {$endif}
 with fontdata,d.infopo^ do begin
  if (xchar2b(char).byte1 >= min_byte1) and (xchar2b(char).byte1 <= max_byte1) and
   (xchar2b(char).byte2 >= min_char_or_byte2) and
   (xchar2b(char).byte2 <= max_char_or_byte2) then begin
   result:= pxcharstruct(pchar(per_char) +
             ((xchar2b(char).byte1 - min_byte1) * d.rowlength +
              (xchar2b(char).byte2 - min_char_or_byte2)
             ) * sizeof(xcharstruct));
  end
  else begin
   result:= nil;
  end;
 end;
{$ifdef FPC} {$checkpointer default} {$endif}
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
var
 int1,int2: integer;
 char: word;
 po1: pmsechar;
 po2: pinteger;
 charstructpo: pxcharstruct;
 glyphinfo: txglyphinfo;
 bo1: boolean;
 po3: pxftfont;

begin
 gdi_lock;
 with drawinfo.getchar16widths do begin
  po1:= text;
  po2:= resultpo;
{$ifdef FPC} {$checkpointer off} {$endif}
  with fontdata^,x11fontdataty(platformdata),d.infopo^ do begin
   if fhasxft then begin
    bo1:= (df_highresfont in drawinfo.gc.drawingflags) and 
           (fonthighres <> 0);
    if bo1 then begin
     po3:= pxftfont(fonthighres);
    end
    else begin
     po3:= pxftfont(font);
    end; 
    for int1:= 0 to count - 1 do begin //todo: optimize
     xfttextextents16(appdisp,po3,po1,1,@glyphinfo);
     po2^:= glyphinfo.xoff;
     inc(po1);
     inc(po2);
    end;
    if bo1 then begin
     po2:= resultpo;
     int2:= highresfontfakt div 2; //round up
     for int1:= 0 to count - 1 do begin
      int2:= int2 + po2^;
      po2^:= int2 shr highresfontshift;
      int2:= int2 and highresfontmask;
      inc(po2);
     end;
    end;
   end
   else begin
    case d.matrixmode of
     fmm_linear: begin
      for int1:= 0 to count - 1 do begin
       char:= word(po1^);
       if (char >= min_char_or_byte2) and (char <= max_char_or_byte2) then begin
        po2^:= pxcharstruct(pchar(per_char) +
                   (char - min_char_or_byte2)*sizeof(xcharstruct))^.width;
       end
       else begin
        po2^:= d.defaultwidth;
       end;
       inc(po1);
       inc(po2);
      end;
     end;
     fmm_matrix: begin
      for int1:= 0 to count -1 do begin
       charstructpo:= getmatrixcharstruct(po1^,
                             x11fontdataty(fontdata^.platformdata));
       if charstructpo <> nil then begin
        po2^:= charstructpo^.width;
        if po2^ = 0 then begin
         po2^:= d.defaultwidth;
        end;
       end
       else begin
        po2^:= d.defaultwidth;
       end;
       inc(po1);
       inc(po2);
      end;
     end;
     else begin //fm_fix
      int2:= max_bounds.width;
      for int1:= 0 to count - 1 do begin
       po2^:= int2;
       inc(po2);
      end;
     end;
    end;
   end;
  end;
{$ifdef FPC} {$checkpointer default} {$endif}
 end;
// result:= gde_ok;
 gdi_unlock;
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
var
 po1: pxcharstruct;
 glyphinfo: txglyphinfo;
begin
 gdi_lock;
 with drawinfo.getfontmetrics do begin
{$ifdef FPC} {$checkpointer off} {$endif}
  with fontdata^,x11fontdataty(platformdata),d.infopo^ do begin
   if fhasxft then begin
    xfttextextents16(appdisp,pxftfont(font),@char,1,@glyphinfo);
    with resultpo^ do begin
     width:= glyphinfo.xoff;
     leftbearing:= glyphinfo.x;
     rightbearing:= glyphinfo.xoff-glyphinfo.width+glyphinfo.x;
    end;
   end
   else begin
    case d.matrixmode of
     fmm_linear: begin
      if (word(char) >= min_char_or_byte2) and (word(char) <= max_char_or_byte2) then begin
       po1:= pxcharstruct(pchar(per_char) +
                  (word(char) - min_char_or_byte2)*sizeof(xcharstruct));
      end
      else begin
       po1:= pxcharstruct(pchar(per_char) +
                  (default_char - min_char_or_byte2)*sizeof(xcharstruct));
      end;
     end;
     fmm_matrix: begin
      po1:= getmatrixcharstruct(char,x11fontdataty(fontdata^.platformdata));
      if po1 = nil then begin
       po1:= getmatrixcharstruct(msechar(default_char),
                                x11fontdataty(fontdata^.platformdata));
       if po1 = nil then begin
        with resultpo^ do begin
         width:= 0;
         leftbearing:= 0;
         rightbearing:= 0;
        end;
       end;
      end;
     end;
     else begin //fm_fix
      po1:= @max_bounds;
     end;
    end;
    with resultpo^ do begin
     width:= po1^.width;
     leftbearing:= po1^.lbearing;
     rightbearing:= width - po1^.rbearing;
    end;
   end;
  end;
 end;
{$ifdef FPC} {$checkpointer default} {$endif}
// result:= gde_ok;
 gdi_unlock;
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
var
 int1: integer;
 char: word;
 charstructpo: pxcharstruct;
 glyphinfo: txglyphinfo;
begin
 gdi_lock;
{$ifdef FPC} {$checkpointer off} {$endif}
 with drawinfo.gettext16width do begin
  result:= 0;
  with fontdata^,x11fontdataty(platformdata),d.infopo^ do begin
   if fhasxft then begin
    xfttextextents16(appdisp,pxftfont(font),text,count,@glyphinfo);
    result:= glyphinfo.xoff;
   end
   else begin
    case d.matrixmode of
     fmm_linear: begin
      for int1:= 0 to count - 1 do begin
       char:= word(text[int1]);
       if (char >= min_char_or_byte2) and (char <= max_char_or_byte2) then begin
        inc(result,pxcharstruct(pchar(per_char) +
                   (char - min_char_or_byte2)*sizeof(xcharstruct))^.width);
       end
       else begin
        inc(result,d.defaultwidth);
       end;
      end;
     end;
     fmm_matrix: begin
      for int1:= 0 to count - 1 do begin
       charstructpo:= getmatrixcharstruct(text[int1],
                             x11fontdataty(fontdata^.platformdata));
       if charstructpo <> nil then begin
        inc(result,charstructpo^.width);
       end
       else begin
        inc(result,d.defaultwidth);
       end;
      end;
     end;
     else begin //fm_fix
      result:= max_bounds.width * count;
     end;
    end;
   end;
  end;
 end;
{$ifdef FPC} {$checkpointer default} {$endif}
 gdi_unlock;
end;

function getcharstruct(const fontdata: fontdataty; char: msechar): pxcharstruct;
begin
{$ifdef FPC} {$checkpointer off} {$endif}
 result:= nil;
 with fontdata,x11fontdataty(platformdata),d.infopo^ do begin
  case d.matrixmode of
   fmm_linear: begin
    if (word(char) >= min_char_or_byte2) and (word(char) <= max_char_or_byte2) then begin
     result:= pxcharstruct(pchar(per_char) +
                 (word(char) - min_char_or_byte2)*sizeof(xcharstruct));
    end;
   end;
   fmm_matrix: begin
    result:= getmatrixcharstruct(char,x11fontdataty(fontdata.platformdata));
   end;
   else begin //fmm_fix
    result:= @d.infopo^.max_bounds;
   end;
  end;
 end;
{$ifdef FPC} {$checkpointer default} {$endif}
end;


type
 fontpropinfoty = record
  foundry: string;
  family_name: string;
  weight_name: string;
  slant: string;
  setwidth_name: string;
  add_style_name: string;
  pixel_size: ptrint;
  point_size: ptrint;
  resolution_x: ptrint;
  resolution_y: ptrint;
  spacing: string;
  average_width: ptrint;
  charset_registry: string;
  charset_encodeing: string;
  min_space: ptrint;
  norm_space: ptrint;
  max_space: ptrint;
  end_space: ptrint;
  superscript_x: ptrint;
  superscript_y: ptrint;
  subscript_x: ptrint;
  subscript_y: ptrint;
  underline_position: ptrint;
  underline_thickness: ptrint;
  strikeout_ascent: ptrint;
  strikeout_descent: ptrint;
  italic_angle: ptrint;
  x_height: ptrint;
  weight: ptrint;
  face_name: string;
  font: string;
  copyright: string;
  avg_capital_width: ptrint;
  avg_lowercase_width: ptrint;
  relative_setwidth: ptrint;
  relative_weight: ptrint;
  cap_height: ptrint;
  superscript_size: ptrint;
  figure_width: ptrint;
  subscript_size: ptrint;
  small_cap_size: ptrint;
  notice: string;
  destination: ptrint;
  font_type: string;
  font_version: string;
  rasterizer_name: string;
  rasterizer_version: string;
  raw_ascent: ptrint;
  raw_descent: ptrint;
  axis_names: string;
  axis_limits: string;
  axis_types: string;
  dummy: ptrint;
 end;

procedure getfontproperties(var fontstruct: xfontstruct; var propinfo: fontpropinfoty);

 procedure setproperty(const prop: xfontprop);

 var
  propnum: fontpropertiesty;
  po: pchar;

 begin //setproperty
   with prop do begin
    for propnum:= low(fontpropertiesty) to high(fontpropertiesty) do begin
     if name = fontpropertyatoms[propnum] then begin
      break;
     end;
    end;
    if propnum < fpnone then begin
     if fontpropertynames[propnum].isstring then begin
      if prop.card32 = 0 then begin
       strfontproparty(propinfo)[propnum]:= '';
      end
      else begin
       po:= xgetatomname(appdisp,prop.card32);
       strfontproparty(propinfo)[propnum]:= po;
       xfree(po);
      end;
     end
     else begin
      intfontproparty(propinfo)[propnum]:= prop.card32;
     end;
    end;
   end;
  end;
var
 int1: integer;
 po: pxfontprop;

begin //getfontproperties
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with fontstruct do begin
  po:= properties;
  for int1:= 0 to n_properties - 1 do begin
   setproperty(po^);
   inc(po);
  end;
 end;
end;


procedure gdi_getfonthighres(var drawinfo: drawinfoty);
var
 pat1,pat2: pfcpattern;
 res1: tfcresult;
// po1: pxftfont;
begin
 gdi_lock;
 if fhasxft then begin
  with drawinfo.getfont do begin
   pat1:= fontdatatoxftpat(fontdata^,true);
   pat2:= xftfontmatch(appdisp,xdefaultscreen(appdisp),pat1,@res1);
   if pat2 <> nil then begin
    fontdata^.fonthighres:= ptruint(xftfontopenpattern(appdisp,pat2));
   end;
   fcpatterndestroy(pat1);
  end;
 end;
 gdi_unlock;
end;

procedure gdi_getfont(var drawinfo: drawinfoty);

 procedure getfontdata(po: pxfontstruct);
 var
  charstructpo: pxcharstruct;
 begin
{$ifdef FPC} {$checkpointer off} {$endif}
  with drawinfo.getfont,fontdata^,x11fontdataty(platformdata) do begin
   font:= po^.fid;
   ascent:= po^.ascent;
   descent:= po^.descent;
   linespacing:= ascent + descent;
   realheight:= linespacing;
   caretshift:= 0;
   d.infopo:= po;
   with po^ do begin
    if per_char = nil then begin
     d.matrixmode:= fmm_fix;
    end
    else begin
     if (min_byte1 = 0) and (max_byte1 = 0) then begin
      d.matrixmode:= fmm_linear;
     end
     else begin
      d.matrixmode:= fmm_matrix;
      d.rowlength:= max_char_or_byte2 - min_char_or_byte2 + 1;
     end;
    end;
    charstructpo:= getcharstruct(fontdata^,msechar(default_char));
    if charstructpo <> nil then begin
     d.defaultwidth:= charstructpo^.width;
    end; //0 otherwise
   end;
{$ifdef FPC} {$checkpointer default} {$endif}
  end;
 end;

var
 po1: pxfontstruct;
 po2: pxftfont;
 fontinfo: fontinfoty;
 int1: integer;
 po3,po4: pfcpattern;
 res1: tfcresult;
 rea1: real;
 {$ifdef mse_debugxft}
 po5: pchar;
 {$endif}
begin
 gdi_lock;
 setupfontinfo(drawinfo.getfont.fontdata^,fontinfo);
{$ifdef FPC} {$checkpointer off} {$endif}
 with drawinfo.getfont.fontdata^ do begin
  if fhasxft then begin
   drawinfo.getfont.ok:= false;
   po3:= buildxftpat(drawinfo.getfont.fontdata^,fontinfo,false);
   po4:= xftfontmatch(appdisp,xdefaultscreen(appdisp),po3,@res1);
   if po4 <> nil then begin
   {$ifdef mse_debugxft}
    if fcpatterngetstring(po4,fc_file,0,@po5) = fcresultmatch then begin
     writeln('Font found. Name: "'+name+'" Height: '+inttostr(height)+' File:');
     writeln('"'+string(po5)+'"');
    end;     
   {$endif}
    if fcpatterngetinteger(po4,fc_pixel_size,0,@int1) = fcresultmatch then begin
     realheight:= int1;
    end;
    po2:= xftfontopenpattern(appdisp,po4); //font owns the pattern
    if po2 <> nil then begin
     drawinfo.getfont.ok:= true;
     getxftfontdata(po2,drawinfo);
     if h.d.rotation <> 0 then begin //ascent and descent are 0 for rotated fonts
      fcpatterndestroy(po3);
      rea1:= h.d.rotation;
      if rea1 <> 0 then begin
       int1:= round(rea1/(pi/2)) mod 4;
       if int1 < 0 then begin
        int1:= int1 + 4;
       end;
       x11fontdataty(platformdata).d.xftdirection:= graphicdirectionty(int1); 
                                          //for xft colorbackground
      end;
      h.d.rotation:= 0;
      po3:= buildxftpat(drawinfo.getfont.fontdata^,fontinfo,false);
      po4:= xftfontmatch(appdisp,xdefaultscreen(appdisp),po3,@res1);
      if po4 <> nil then begin
       po2:= xftfontopenpattern(appdisp,po4);
       if po2 <> nil then begin
        ascent:= po2^.ascent;
        descent:= po2^.descent;
        x11fontdataty(platformdata).d.xftascent:= po2^.ascent;
        x11fontdataty(platformdata).d.xftdescent:= po2^.descent;
        xftfontclose(appdisp,po2);
       end;
      end;
      h.d.rotation:= rea1;
     end;
    end;
   end;
   fcpatterndestroy(po3);
  end
  else begin
   po1:=  xloadqueryfont(appdisp,pchar(fontinfotoxlfdname(fontinfo)));
   if po1 = nil then begin
    if fs_italic in h.d.style then begin
     fontinfo[fn_slant]:= 'o';
     po1:=  xloadqueryfont(appdisp,pchar(fontinfotoxlfdname(fontinfo)));
     fontinfo[fn_slant]:= 'i';
    end;
    if po1 = nil then begin
     if (h.name <> '') and (h.d.style * [fs_italic,fs_bold] = []) and 
                               (h.charset <> '') and (h.d.height = 0) then begin
      po1:= xloadqueryfont(appdisp,pchar(h.name));
     end;
     if po1 = nil then begin
      if simpledefaultfont then begin
       po1:= xloadqueryfont(appdisp,pchar(fontinfo[fn_family_name]));
      end;
      if po1 = nil then begin
       fontinfo[fn_family_name]:= 'fixed';
       po1:=  xloadqueryfont(appdisp,pchar(fontinfotoxlfdname(fontinfo)));
       if po1 = nil then begin
        po1:= xloadqueryfont(appdisp,'fixed');
       end;
      end;
     end;
    end;
   end;
   if po1 <> nil then begin
    getfontdata(po1);
    drawinfo.getfont.ok:= true;
   end
   else begin
    drawinfo.getfont.ok:= false;
   end;
  end;
 end;
  {$ifdef FPC} {$checkpointer default} {$endif}
 gdi_unlock;
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
 gdi_lock;
 with drawinfo.getfont.fontdata^ do begin
  if fhasxft then begin
   xftfontclose(appdisp,pxftfont(font));
   if fonthighres <> 0 then begin
    xftfontclose(appdisp,pxftfont(fonthighres));
   end;
  end
  else begin
   with x11fontdataty(platformdata) do begin
    xfreefontinfo(nil,d.infopo,1);
    xunloadfont(appdisp,font);
   end;
  end;
 end;
 gdi_unlock;
end;

{
const
 rgbwhite: rgbtriplety = (blue: $ff; green: $ff; red: $ff; res: $00);
}
procedure graytorgb(const sdev: paintdevicety; const srect: rectty;
               const ddev: paintdevicety; const dpos: pointty; const gc: pgcty);
var
 putpixelfunc: function (para1:PXImage; para2:cint;
                                para3:cint; para4:culong):cint; cdecl; 
 dimage,simage: pximage;
 ps,ps1,pse,pd,pd1,pde: pointer;
 int1,int2: integer;
 gc1: tgc;
begin
 with srect do begin
  simage:= xgetimage(appdisp,sdev,x,y,cx,cy,$ff,zpixmap);
  if simage <> nil then begin
   dimage:= xcreateimage(appdisp,defvisual,defdepth,zpixmap,0,nil,
                                                              cx,cy,32,0);                              
   if dimage <> nil then begin
    try
     int1:= cy*dimage^.bytes_per_line;
     getmem(dimage^.data,int1);
     ps:= simage^.data;
     pd:= dimage^.data;
     pde:= pd+int1;
     if dimage^.bits_per_pixel = 32 then begin
      repeat
       ps1:= ps;
       pse:= ps+cx;
       pd1:= pd;
       repeat
        pbyte(pd1)^:= pbyte(ps1)^;
        inc(pd1);
        pbyte(pd1)^:= pbyte(ps1)^;
        inc(pd1);
        pbyte(pd1)^:= pbyte(ps1)^;
        inc(pd1,2);
        inc(ps1);
       until ps1 = pse;
       ps:= ps+simage^.bytes_per_line;
       pd:= pd+dimage^.bytes_per_line;
      until pd = pde;
     end
     else begin
      putpixelfunc:= dimage^.f.put_pixel;
      for int1:= 0 to cy - 1 do begin
       ps1:= ps;
       for int2:= 0 to cx - 1 do begin
        putpixelfunc(dimage,int2,int1,gui_graytopixel(pbyte(ps1)[int2]));
       end;
       ps:= ps+simage^.bytes_per_line;
      end;
     end;
    except
    end;
    if gc <> nil then begin
     gc1:= tgc(gc^.handle);
    end
    else begin
     gc1:= xcreategc(appdisp,ddev,0,nil);
    end;     
    xputimage(appdisp,ddev,gc1,dimage,0,0,dpos.x,dpos.y,cx,cy);
    if gc = nil then begin
     xfreegc(appdisp,gc1);
    end;
    if dimage^.data <> nil then begin
     freemem(dimage^.data);       
     dimage^.data:= nil;
    end;
    xdestroyimage(dimage);
   end;
   xdestroyimage(simage);
  end;
 end;
end;

procedure rgbtogray(const sdev: paintdevicety; const srect: rectty;
               const ddev: paintdevicety; const dpos: pointty; const gc: pgcty);
var
 getpixelfunc: function (para1:PXImage; para2:cint; para3:cint):culong; cdecl;
 dimage,simage: pximage;
 ps,ps1,pse,pd,pd1,pde: pointer;
 int1,int2: integer;
 wo1: word;
 lwo1: word;
 gc1: tgc;
begin
 with srect do begin
  simage:= xgetimage(appdisp,sdev,x,y,cx,cy,$ffffff,zpixmap);
  if simage <> nil then begin
   dimage:= xcreateimage(appdisp,defvisual,8,zpixmap,0,nil,cx,cy,32,0);                              
   if dimage <> nil then begin
    try
     int1:= cy*dimage^.bytes_per_line;
     getmem(dimage^.data,int1);
     ps:= simage^.data;
     pd:= dimage^.data;
     pde:= pd+int1;
     if simage^.bits_per_pixel = 32 then begin
      repeat
       ps1:= ps;
       pse:= ps+cx*4;
       pd1:= pd;
       repeat
        wo1:= pbyte(ps1)^;
        inc(ps1);
        wo1:= wo1 + pbyte(ps1)^;
        inc(ps1);
        pbyte(pd1)^:= (wo1 + pbyte(ps1)^) div 3;
        inc(ps1,2);
        inc(pd1);
       until ps1 = pse;
       ps:= ps+simage^.bytes_per_line;
       pd:= pd+dimage^.bytes_per_line;
      until pd = pde;
     end
     else begin
      getpixelfunc:= simage^.f.get_pixel;
      for int1:= 0 to cy - 1 do begin
       pd1:= pd;
       for int2:= 0 to cx - 1 do begin
        lwo1:= getpixelfunc(simage,int2,int1);
        pbyte(pd1)[int2]:= (lwo1 and $ff + ((lwo1 and $ff00) shr 8) +
                                       ((lwo1 and $ff0000) shr 16)) div 3;
 
       end;
       pd:= pd+dimage^.bytes_per_line;
      end;
     end;
    except
    end;
    if gc <> nil then begin
     gc1:= tgc(gc^.handle);
    end
    else begin
     gc1:= xcreategc(appdisp,ddev,0,nil);
    end;
    xputimage(appdisp,ddev,gc1,dimage,0,0,dpos.x,dpos.y,cx,cy);
    if gc = nil then begin
     xfreegc(appdisp,gc1);
    end;
    if dimage^.data <> nil then begin
     freemem(dimage^.data);       
     dimage^.data:= nil;
    end;
    xdestroyimage(dimage);
   end;
   xdestroyimage(simage);
  end;
 end;
end;

procedure gdi_copyarea(var drawinfo: drawinfoty); //gdifunc
var
 needstransform: boolean;
 transform: txtransform;
  
 procedure updatetransform(const apic: tpicture);
 begin
  if needstransform then begin
   xrendersetpicturetransform(appdisp,apic,@transform);
   if al_intpol in drawinfo.copyarea.alignment then begin
    xrendersetpicturefilter(appdisp,apic,'good',nil,0);
   end;
  end
 end;

 function getscale(const sourcesize,destsize,sourcepos: integer;
                                    out destpos: integer): txfixed;
// var
//  int1: integer;
 begin
  if (sourcesize > 0) and (sourcesize <> destsize) then begin
   result:= (sourcesize * $10000) div destsize;
    //pixel end to pixel end
   if result > 0 then begin
    if sourcesize * $10000 div result < destsize then begin
     dec(result);
    end;
    destpos:= (sourcepos * $10000 + result div 2) div result; 
   end
   else begin
    destpos:= sourcepos * $10000; //very big
   end;
  end
  else begin
   result:= $10000;
   destpos:= sourcepos;
  end;
 end;

var
 amask: pixmapty;
 xvalues: xgcvalues;
 pixmap: pixmapty;
 pixmapgc: tgc;
 maskgc: gcty;
 bitmap: pixmapty;
 bitmapgc,bitmapgc2: tgc;
 int1: integer;
 spic,dpic,cpic,maskpic: tpicture;
 sattributes: txrenderpictureattributes;
 dattributes: txrenderpictureattributes;
 pixmap2: pixmapty;
 pictop: integer;
 sourceformats: culong  = cpclipmask or cpclipxorigin or cpclipyorigin;
 destformats: culong = cpgraphicsexposure;
 monomask: boolean;
 spd: paintdevicety;
 skind,dkind: bitmapkindty;
 x1,y1: integer;
 int2: integer;
 format1: pxrenderpictformat;
 ax,ay,sx,sy,dx,dy: integer;
 sdev: paintdevicety;
 ddev: paintdevicety;

 procedure checkddevcopy();
 begin
  with drawinfo,copyarea do begin
   if ddev <> paintdevice then begin
    sdev:= gui_createpixmap(destrect^.size,0,bmk_gray);
    rgbtogray(ddev,mr(nullpoint,destrect^.size),sdev,nullpoint,nil);
    with destrect^ do begin
     xcopyarea(appdisp,sdev,paintdevice,tgc(gc.handle),0,0,cx,cy,x,y);
    end;
    xfreepixmap(appdisp,sdev);
    xfreepixmap(appdisp,ddev);
   end;
  end;
 end;

label
 endlab,endlab2;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,copyarea,sourcerect^,gc,x11gcty(platformdata).d do begin
  dkind:= kind;
  skind:= tcanvas1(source).fdrawinfo.gc.kind;
  needstransform:= (alignment * [al_stretchx,al_stretchy] <> []) and
            ((destrect^.cx <> sourcerect^.cx) or
            (destrect^.cy <> sourcerect^.cy)) and
            (destrect^.cx > 0) and (destrect^.cy > 0);
  monomask:= (mask = nil) or (mask.kind = bmk_mono);
  if hasxrender and (needstransform or (longword(opacity) <> maxopacity) or
                                                      not monomask) then begin
   if needstransform then begin
    if mask <> nil then begin
     monomask:= false;     //xrender ignores clip_mask for transformations
    end;
    transform:= unitytransform;
    transform[0,0]:= getscale(cx,destrect^.cx,x,ax);
    transform[1,1]:= getscale(cy,destrect^.cy,y,ay);
   end
   else begin
    ax:= x;
    ay:= y;
   end;
   pictop:= pictopsrc;
   maskpic:= 0;
   if (longword(opacity) <> maxopacity) and (mask = nil){monomask} then begin
    maskpic:= createmaskpicture(opacity); 
              //clip_mask ignored by xrender
    pictop:= pictopover;
   end
   else begin
    if not monomask then begin
     maskpic:= createmaskpicture(mask);
     updatetransform(maskpic);
     pictop:= pictopover;
    end;
   end;
   with sattributes do begin
    clip_x_origin:= 0;
    clip_y_origin:= 0;
    if (mask <> nil) and monomask then begin
     clip_mask:= tsimplebitmap1(mask).handle;
    end
    else begin
     clip_mask:= 0;
    end;
   end;
   with dattributes do begin
    graphics_exposures:= 0;
//    clip_mask:= sattributes.clip_mask;
   end;
   if (dkind <> skind) and ((dkind = bmk_mono) or (skind = bmk_mono)) then begin
    if dkind = bmk_mono then begin //color to mono
     if maskpic <> 0 then begin
      xrenderfreepicture(appdisp,maskpic);
     end;
     exit; //not supported;         //todo !!!
    end
    else begin //monochrome -> color
     bitmapgc2:= nil;
     bitmap:= 0;
     if (mask <> nil) and (mask.kind = bmk_mono) then begin
      bitmap:= gui_createpixmap(size,0,bmk_mono);
      if bitmap <> 0 then begin
       bitmapgc2:= xcreategc(appdisp,bitmap,0,@xvalues);
       if bitmapgc2 <> nil then begin
        xcopyarea(appdisp,tcanvas1(source).fdrawinfo.paintdevice,
                          bitmap,bitmapgc2,x,y,cx,cy,0,0);
        xvalues.xfunction:= gxand;
        xchangegc(appdisp,bitmapgc2,gcfunction,@xvalues);
        xcopyarea(appdisp,mask.handle,bitmap,bitmapgc2,x,y,cx,cy,0,0);
                       //new source = source and mask
        ax:= 0;
        ay:= 0;
        x1:= 0;
        y1:= 0;
        with sattributes do begin
         clip_x_origin:= 0;
         clip_y_origin:= 0;
        end;
       end
       else begin
        goto endlab2;
       end;
      end
      else begin
       goto endlab2;
      end;
      spd:= bitmap;
     end
     else begin
      spd:= tcanvas1(source).fdrawinfo.paintdevice;
      x1:= x;
      y1:= y;
     end;
     spic:= xrendercreatepicture(appdisp,spd,bitmaprenderpictformat,
                      sourceformats,@sattributes);
     format1:= screenrenderpictformat;
     dx:= destrect^.x;
     dy:= destrect^.y;
     ddev:= paintdevice;
     if dkind = bmk_gray then begin
      dx:= 0;
      dy:= 0;
      ddev:= gui_createpixmap(destrect^.size,0,bmk_rgb);
      graytorgb(paintdevice,destrect^,ddev,nullpoint,nil);
     end;
     dpic:= xrendercreatepicture(appdisp,ddev,format1,
                      destformats,@dattributes);
     pictop:= pictopover;
     if dkind = bmk_gray then begin
      cpic:= creategraycolorpicture(acolorforeground);
     end
     else begin
      cpic:= createcolorpicture(acolorforeground);
     end;
     if (gcclipregion <> 0) and (ddev = paintdevice) then begin
      setregion(gc,region(gcclipregion),dpic);
     end;
     updatetransform(spic);
     if acolorforeground <> cl_transparent then begin
      xrendercomposite(appdisp,pictop,cpic,spic,dpic,0,0,ax,ay,
                           dx,dy,destrect^.cx,destrect^.cy);
     end;
     xrenderfreepicture(appdisp,cpic);
     if df_opaque in gc.drawingflags then begin
      if bitmap <> 0 then begin
       xvalues.xfunction:= gxorinverted;
       xchangegc(appdisp,bitmapgc2,gcfunction,@xvalues);
       xcopyarea(appdisp,mask.handle,bitmap,bitmapgc2,x,y,cx,cy,0,0);
      end;
      xvalues.xfunction:= gxxor;
      xvalues.foreground:= $ffffffff;
      bitmapgc:= xcreategc(appdisp,spd,gcforeground or gcfunction,@xvalues);
      xfillrectangle(appdisp,spd,bitmapgc,x1,y1,cx,cy);
      if dkind = bmk_gray then begin
       cpic:= creategraycolorpicture(acolorbackground);
      end
      else begin
       cpic:= createcolorpicture(acolorbackground);
      end;
      xrendercomposite(appdisp,pictop,cpic,spic,dpic,0,0,ax,ay,
                          dx,dy,destrect^.cx,destrect^.cy);
      xrenderfreepicture(appdisp,cpic);
      xfillrectangle(appdisp,spd,bitmapgc,x1,y1,cx,cy);
      xfreegc(appdisp,bitmapgc);
     end;
     checkddevcopy();
endlab2:
     if bitmapgc2 <> nil then begin 
      xfreegc(appdisp,bitmapgc2);
     end;
     if bitmap <> 0 then begin
      xfreepixmap(appdisp,bitmap);
     end;
    end;
   end
   else begin 
    sx:= ax;
    sy:= ay;
    dx:= destrect^.x;
    dy:= destrect^.y;
    format1:= screenrenderpictformat;
    sdev:= tcanvas1(source).paintdevice;
    ddev:= paintdevice;
    if skind = bmk_gray then begin
     sx:= 0;
     sy:= 0;
     sdev:= gui_createpixmap(sourcerect^.size,0,bmk_rgb);
     graytorgb(tcanvas1(source).paintdevice,sourcerect^,sdev,nullpoint,nil);
    end;
    if dkind = bmk_gray then begin
     dx:= 0;
     dy:= 0;
     ddev:= gui_createpixmap(destrect^.size,0,bmk_rgb);
     graytorgb(paintdevice,destrect^,ddev,nullpoint,nil);
    end;
    spic:= xrendercreatepicture(appdisp,sdev,format1,
                                            sourceformats,@sattributes);
    dpic:= xrendercreatepicture(appdisp,ddev,format1,
                                              destformats,@dattributes);
    if (gcclipregion <> 0) and (ddev = paintdevice) then begin
     setregion(gc,region(gcclipregion),dpic);
    end;
    updatetransform(spic);
    xrendercomposite(appdisp,pictop,spic,maskpic,dpic,sx,sy,ax,ay,
                         dx,dy,destrect^.cx,destrect^.cy);
    xrenderfreepicture(appdisp,spic);
    xrenderfreepicture(appdisp,dpic);
    if sdev <> tcanvas1(source).paintdevice then begin
     xfreepixmap(appdisp,sdev);
    end;
    checkddevcopy();
    if maskpic <> 0 then begin
     xrenderfreepicture(appdisp,maskpic);
    end;
   end;
  end
  else begin //direct x11
   pixmap2:= 0;
   if copymode <> gcrasterop then begin
    xsetfunction(appdisp,tgc(gc.handle),integer(copymode));
   end;
   if mask <> nil then begin
    amask:= tsimplebitmap1(mask).handle;
    if gcclipregion <> 0 then begin
     pixmap2:= gui_createpixmap(size,0,bmk_mono);
     maskgc.handle:= ptruint(xcreategc(appdisp,pixmap2,0,@xvalues));
     xfillrectangle(appdisp,pixmap2,tgc(maskgc.handle),0,0,cx,cy);
     maskgc.cliporigin:= subpoint(cliporigin,destrect^.pos);
     setregion(maskgc,region(gcclipregion));
     xcopyarea(appdisp,amask,pixmap2,tgc(maskgc.handle),x,y,cx,cy,0,0);
     xvalues.clip_x_origin:= destrect^.x;
     xvalues.clip_y_origin:= destrect^.y;
     xvalues.clip_mask:= pixmap2;
     xchangegc(appdisp,tgc(gc.handle),gcclipxorigin or gcclipyorigin or
                  gcclipmask,@xvalues);
     xfreegc(appdisp,tgc(maskgc.handle));
    end
    else begin
     xvalues.clip_mask:= amask;
     xvalues.clip_x_origin:= destrect^.x - x;
     xvalues.clip_y_origin:= destrect^.y - y;
     xchangegc(appdisp,tgc(gc.handle),gcclipxorigin or gcclipyorigin or
                      gcclipmask,@xvalues);
    end;
   end;
   if skind = dkind then begin     
    xcopyarea(appdisp,tcanvas1(source).fdrawinfo.paintdevice,paintdevice,
                   tgc(gc.handle),x,y,cx,cy,destrect^.x,destrect^.y);
   end
   else begin
    xvalues.graphics_exposures:= {$ifdef xboolean}false{$else}0{$endif};
    if (skind = bmk_gray) and (dkind = bmk_rgb) then begin
     graytorgb(tcanvas1(source).fdrawinfo.paintdevice,sourcerect^,
               paintdevice,destrect^.pos,@gc);
    end
    else begin
     if (skind = bmk_rgb) and (dkind = bmk_gray) then begin
      rgbtogray(tcanvas1(source).fdrawinfo.paintdevice,sourcerect^,
               paintdevice,destrect^.pos,@gc);
     end
     else begin  
      if dkind = bmk_mono then begin //convert to monochrome
       pixmap:= gui_createpixmap(size,0,skind);
       if pixmap = 0 then begin
        goto endlab;
       end;
       pixmapgc:= xcreategc(appdisp,pixmap,gcgraphicsexposures,@xvalues);
       if pixmapgc <> nil then begin
        xcopyarea(appdisp,tcanvas1(source).fdrawinfo.paintdevice,pixmap,
                                                        pixmapgc,x,y,cx,cy,0,0);
        xvalues.foreground:= transparentcolor;
        xvalues.xfunction:= integer(rop_xor);
        xchangegc(appdisp,pixmapgc,gcforeground or gcfunction,@xvalues);
        xfillrectangle(appdisp,pixmap,pixmapgc,0,0,cx,cy);
        bitmap:= gui_createpixmap(size,0,bmk_mono);
        if bitmap <> 0 then begin
         xvalues.foreground:= pixel0;
         bitmapgc:= xcreategc(appdisp,bitmap,
                           gcforeground or gcgraphicsexposures,@xvalues);
         if bitmapgc <> nil then begin
          xfillrectangle(appdisp,bitmap,bitmapgc,0,0,cx,cy);
          xvalues.xfunction:= integer(rop_or);
          xvalues.background:= pixel0;
          xvalues.foreground:= pixel1;
          xchangegc(appdisp,bitmapgc,gcfunction or gcforeground or
                  gcbackground,@xvalues);
          if skind = bmk_gray then begin
           int2:= 8;
          end
          else begin
           int2:= defdepth;
          end;
          for int1:= 0 to int2-1 do begin
           xcopyplane(appdisp,pixmap,bitmap,bitmapgc,0,0,cx,cy,
                          0,0,1 shl int1);
          end;
          xcopyarea(appdisp,bitmap,paintdevice,tgc(gc.handle),0,0,cx,cy,
                                                       destrect^.x,destrect^.y);
          xfreegc(appdisp,bitmapgc);
         end;
         xfreepixmap(appdisp,bitmap)
        end;
        xfreegc(appdisp,pixmapgc);
       end;
       xfreepixmap(appdisp,pixmap);
      end
      else begin
              //convert from monochrome
       pixmapgc:= xcreategc(appdisp,paintdevice,0,nil);
       if pixmapgc <> nil then begin
        xcopygc(appdisp,tgc(gc.handle),gcfunction or gcplanemask or
           gcsubwindowmode or gcgraphicsexposures or gcclipxorigin or
           gcclipyorigin or gcclipmask or gcforeground or gcbackground,pixmapgc);
        with xvalues do begin
         stipple:= tcanvas1(source).fdrawinfo.paintdevice;
         ts_x_origin:= destrect^.x-x;
         ts_y_origin:= destrect^.y-y;
         if df_opaque in gc.drawingflags then begin
          fill_style:= fillopaquestippled;
         end
         else begin
          fill_style:= fillstippled;
         end;
        end;
        xchangegc(appdisp,pixmapgc,gcfillstyle or gcstipple or
                         gctilestipxorigin or gctilestipyorigin,@xvalues);
        xfillrectangle(appdisp,paintdevice,pixmapgc,destrect^.x,destrect^.y,cx,cy);
        xfreegc(appdisp,pixmapgc);
       end;
      end;
     end;
    end;
   end;
   if mask <> nil then begin
    xvalues.clip_x_origin:= 0;
    xvalues.clip_y_origin:= 0;
    xchangegc(appdisp,tgc(gc.handle),gcclipxorigin or gcclipyorigin,@xvalues);
   end;
   if copymode <> gcrasterop then begin
    xsetfunction(appdisp,tgc(gc.handle),integer(gcrasterop));
   end;
endlab:
   if pixmap2 <> 0 then begin
    xfreepixmap(appdisp,pixmap2);
   end;
  end;
 end;
end;

procedure gdi_getimage(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_fonthasglyph(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,fonthasglyph do begin
  if fhasxft then begin
   hasglyph:= xftcharexists(appdisp,pxftfont(font),unichar);
  end
  else begin
   hasglyph:= true;
  end;
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty); //gdifunc
var
 po1: ppointty;
 pointcount: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,points,x11gcty(gc.platformdata).d do begin
  if xfts_smooth in xftstate then begin
   if linestria(drawinfo,po1,pointcount) then begin
    compositetriangles(drawinfo,ptrianglety(po1),pointcount div 3);
   end
   else begin
    compositetristrip(drawinfo,po1,pointcount);
   end;      
  end
  else begin
   transformpoints(drawinfo,closed);
   pointcount:= count;
   if closed then begin
    inc(pointcount);
   end;
   xdrawlines(appdisp,paintdevice,tgc(gc.handle),buffer.buffer,pointcount,
                            coordmodeorigin);
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty); //gdifunc
var
 triacount: integer;
 po1: ptrianglety;

begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.points,x11gcty(gc.platformdata).d do begin
  if xfts_smooth in xftstate then begin
   linesegmentstria(drawinfo,po1,triacount);
   compositetriangles(drawinfo,po1,triacount);
  end
  else begin
   transformpoints(drawinfo,false);
   xdrawsegments(appdisp,paintdevice,tgc(gc.handle),buffer.buffer,count div 2);
  end;
 end;
end;

procedure gdi_fillellipse(var drawinfo: drawinfoty); //gdifunc
var
 po1: ppointty;
 pointcount: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.rect.rect^ do begin
  if xfts_smooth in x11gcty(gc.platformdata).d.xftstate then begin
   fillellipsetria(drawinfo,po1,pointcount);
   with x11gcty(gc.platformdata).d do begin
    compositetrifan(drawinfo,po1,pointcount);
   end;  
  end
  else begin
   xfillarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,0,wholecircle);
  end;
 end;
end;

const
 angscale = 64*360/(2*pi);
 
procedure gdi_fillarc(var drawinfo: drawinfoty); //gdifunc
var
 xvalues: xgcvalues;
 po1: ppointty;
 pointcount: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,x11gcty(gc.platformdata).d,drawinfo.arc,rect^ do begin
  if xfts_smooth in xftstate then begin
   fillarctria(drawinfo,po1,pointcount);
   compositetrifan(drawinfo,po1,pointcount);
  end
  else begin
   if pieslice then begin
    xvalues.arc_mode:= arcpieslice;
   end
   else begin
    xvalues.arc_mode:= arcchord;
   end;
   xchangegc(appdisp,tgc(gc.handle),gcarcmode,@xvalues);
   xfillarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,
    round(startang*angscale),round(extentang*angscale));
  end;
 end;
end;

procedure gdi_drawarc(var drawinfo: drawinfoty); //gdifunc
var
 po1: ppointty;
 pointcount: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,x11gcty(gc.platformdata).d,drawinfo.arc,rect^,
                                     triagcty(gc.platformdata).d do begin
  if xfts_smooth in xftstate then begin
   if arctria(drawinfo,po1,pointcount) then begin
    compositetriangles(drawinfo,ptrianglety(po1),pointcount div 3);
   end
   else begin
    compositetristrip(drawinfo,po1,pointcount);
   end;      
  end
  else begin
   xdrawarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,
    round(startang*angscale),round(extentang*angscale));
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty); //gdifunc
var
 po1: ppointty;
 pointcount: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,x11gcty(gc.platformdata).d,rect.rect^ do begin
  if xfts_smooth in xftstate then begin
   with x11gcty(gc.platformdata).d do begin
    if ellipsetria(drawinfo,po1,pointcount) then begin
     compositetriangles(drawinfo,ptrianglety(po1),pointcount div 3);
    end
    else begin
     compositetristrip(drawinfo,po1,pointcount);
    end;
   end;  
  end
  else begin
   xdrawarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,0,wholecircle);
  end;
 end;
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty); //gdifunc
var
 po1: pxchar2b;
 xvalues: xgcvalues;
 glyphinfo: txglyphinfo;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.text16pos do begin
  if fhasxft then begin
 {$ifdef FPC}{$checkpointer off}{$endif}
   checkxftdraw(drawinfo);
   checkxftstate(drawinfo,[]);
   transformpos(drawinfo);
   with pxpoint(buffer.buffer)^ do begin
    with x11gcty(gc.platformdata).d do begin
     if df_opaque in gc.drawingflags then begin
      xfttextextents16(appdisp,xftfont,text,count,@glyphinfo);
//      xftdrawrect(xftdraw,@xftcolorbackground,x-glyphinfo.x,y-xftfont^.ascent,
//              glyphinfo.width,xftfont^.ascent+xftfont^.descent);
                   //unreliable!?
      xvalues.foreground:= xftcolorbackground.pixel;
      xchangegc(appdisp,tgc(gc.handle),gcforeground,@xvalues);
      with x11gcty(gc.platformdata).d.xftfontdata^ do begin
       case xftdirection of
        gd_right: begin      
         xfillrectangle(appdisp,paintdevice,tgc(gc.handle),
                                           x{-glyphinfo.x},y-xftascent,
                glyphinfo.xoff,xftascent+xftdescent);
        end;
        gd_up: begin
         xfillrectangle(appdisp,paintdevice,tgc(gc.handle),
                      x-xftascent,y+glyphinfo.yoff,
                xftascent+xftdescent,-glyphinfo.yoff);
        end;
        gd_left: begin
         xfillrectangle(appdisp,paintdevice,tgc(gc.handle),
                      x+glyphinfo.xoff{-glyphinfo.x},y-xftdescent,
                -glyphinfo.xoff,xftascent+xftdescent);
        end;
        gd_down: begin
         xfillrectangle(appdisp,paintdevice,tgc(gc.handle),
                                           x-xftdescent,y,
                xftascent+xftdescent,glyphinfo.yoff);
        end;
       end;
      end;
      xvalues.foreground:= xftcolor.pixel;
      xchangegc(appdisp,tgc(gc.handle),gcforeground,@xvalues);
     end;
     xftdrawstring16(xftdraw,@xftcolor,xftfont,x,y,text,count);
    end;
   end
{$ifdef FPC}{$checkpointer default}{$endif}
  end
  else begin
   po1:= transformtext16pos(drawinfo); //swap bytes
   with pxpoint(buffer.buffer)^ do begin
    if df_opaque in gc.drawingflags then begin
     xdrawimagestring16(appdisp,paintdevice,tgc(gc.handle),x,y,po1,count);
    end
    else begin
     xdrawstring16(appdisp,paintdevice,tgc(gc.handle),x,y,po1,count);
    end;
   end;
  end;
 end;
end;

procedure gdi_setcliporigin(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,gc do begin
  xsetcliporigin(appdisp,tgc(handle),cliporigin.x,cliporigin.y);
 end;
end;

procedure gdi_fillrect(var drawinfo: drawinfoty); //gdifunc
var
 points1: array[0..3] of xpoint;
 x1,y1: smallint;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.rect.rect^ do begin
  x1:= x+origin.x;
  y1:= y+origin.y;
  points1[0].x:= x1;
  points1[0].y:= y1;
  points1[1].y:= y1;
  points1[3].x:= x1;
  inc(x1,cx);
  inc(y1,cy);
  points1[1].x:= x1;
  points1[2].x:= x1;
  points1[2].y:= y1;
  points1[3].y:= y1;
  
  xfillpolygon(appdisp,paintdevice,tgc(gc.handle),@points1[0],4,
                                                     complex,coordmodeorigin);
 end;
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty); //gdifunc
var
 int1: integer;
 po1,po2: pxpointfixed;
 po3: ppointty;
// offsx,offsy: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif}
 with drawinfo do begin
  if xfts_smooth in x11gcty(gc.platformdata).d.xftstate then begin
   if points.count > 2 then begin
    polytria(drawinfo,ptrianglety(po3),int1);
    if int1 > 0 then begin
     po1:= pointer(po3);
     po2:= pointer(ptrianglety(po3)+int1);
     repeat
      po1^.x:= po1^.x << 16;
      po1^.y:= po1^.y << 16;
      inc(po1);
     until po1 = po2;
     compositetriangles(drawinfo,ptrianglety(po3),int1);
    end;
   end;
  end
  else begin
   transformpoints(drawinfo,false);
   with points do begin
    xfillpolygon(appdisp,paintdevice,tgc(gc.handle),buffer.buffer,
           count,complex,coordmodeorigin);
   end;
  end;
 end;
end;


function createregion: regionty; overload;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 result:= regionty(xcreateregion());
end;

function recttoxrect(const rect: rectty): xrectangle;
begin
 with rect do begin
  result.x:= x;
  result.y:= y;
  result.width:= cx;
  result.height:= cy;
 end;
end;

function createregion(const rect: rectty): regionty; overload;
var
 rect1: xrectangle;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 result:= regionty(xcreateregion);
 rect1:= recttoxrect(rect);
 xunionrectwithregion(@rect1,region(result),region(result));
end;

procedure gdi_createemptyregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  dest:= createregion;
 end;
end;

procedure gdi_createrectregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  dest:= createregion(rect);
 end;
end;

procedure gdi_createrectsregion(var drawinfo: drawinfoty); //gdifunc
var
 int1: integer;
 rect1: xrectangle;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  dest:= createregion;
  for int1:= 0 to rectscount - 1 do begin
   rect1:= recttoxrect(rectspo^[int1]);
   xunionrectwithregion(@rect1,region(dest),region(dest));
  end;
 end;
end;                           

procedure gdi_destroyregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  if source <> 0 then begin
   xdestroyregion(region(source));
  end;
 end;
end;

procedure gdi_regionisempty(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  dest:= xemptyregion(region(source));
  if dest <> 0 then begin
   dest:= 1;
  end;
 end;
end;

procedure gdi_regionclipbox(var drawinfo: drawinfoty); //gdifunc
var
 rect1: xrectangle;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  xclipbox(region(source),@rect1);
  rect.x:= rect1.x;
  rect.y:= rect1.y;
  rect.cx:= rect1.width;
  rect.cy:= rect1.height;
 end;
end;

procedure gdi_copyregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  if source = 0 then begin
   dest:= 0;
  end
  else begin
   dest:= ptruint(xcreateregion);
   xunionregion(region(dest),region(source),region(dest));
  end;
 end;
end;

procedure gdi_moveregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  xoffsetregion(region(source),rect.x,rect.y);
 end;
end;

procedure gdi_regsubrect(var drawinfo: drawinfoty); //gdifunc
var
 reg1: region;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  reg1:= region(createregion(rect));
  xsubtractregion(region(dest),reg1,region(dest));
  xdestroyregion(reg1);
 end;
end;

procedure gdi_regintersectrect(var drawinfo: drawinfoty); //gdifunc
var
 reg1: region;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  reg1:= region(createregion(rect));
  xintersectregion(region(dest),reg1,region(dest));
  xdestroyregion(reg1);
 end;
end;

procedure gdi_regintersectregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  xintersectregion(region(dest),region(source),region(dest));
 end;
end;

procedure gdi_regaddrect(var drawinfo: drawinfoty); //gdifunc
var
 rect1: xrectangle;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  rect1:= recttoxrect(rect);
  xunionrectwithregion(@rect1,region(dest),region(dest));
 end;
end;

procedure gdi_regaddregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  xunionregion(region(dest),region(source),region(dest));
 end;
end;

procedure gdi_regsubregion(var drawinfo: drawinfoty); //gdifunc
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo.regionoperation do begin
  xsubtractregion(region(dest),region(source),region(dest));
 end;
end;

function hasxft: boolean;
begin
 result:= fhasxft;
end;

var
 fhasfontconfig: boolean;
 
function getxftlib: boolean;
const
 funcs: array[0..18] of funcinfoty = (
  (n: 'XftDrawDestroy'; d: {$ifndef FPC}@{$endif}@XftDrawDestroy),
  (n: 'XftDrawSetClipRectangles'; d: {$ifndef FPC}@{$endif}@XftDrawSetClipRectangles),
  (n: 'XftDrawCreate'; d: {$ifndef FPC}@{$endif}@XftDrawCreate),
  (n: 'XftDrawSetClip'; d: {$ifndef FPC}@{$endif}@XftDrawSetClip),
  (n: 'XftTextExtents16'; d: {$ifndef FPC}@{$endif}@XftTextExtents16),
  (n: 'XftFontOpenName'; d: {$ifndef FPC}@{$endif}@XftFontOpenName),
  (n: 'XftFontClose'; d: {$ifndef FPC}@{$endif}@XftFontClose),
  (n: 'XftDrawString16'; d: {$ifndef FPC}@{$endif}@XftDrawString16),
  (n: 'XftDefaultHasRender'; d: {$ifndef FPC}@{$endif}@XftDefaultHasRender),
  (n: 'XftGetVersion'; d: {$ifndef FPC}@{$endif}@XftGetVersion),
  (n: 'XftInit'; d: {$ifndef FPC}@{$endif}@XftInit),
  (n: 'XftInitFtLibrary'; d: {$ifndef FPC}@{$endif}@XftInitFtLibrary),
  (n: 'XftCharExists'; d: {$ifndef FPC}@{$endif}@XftCharExists),
  (n: 'XftNameParse'; d: {$ifndef FPC}@{$endif}@XftNameParse),
  (n: 'XftFontMatch'; d: {$ifndef FPC}@{$endif}@XftFontMatch),
  (n: 'XftFontOpenPattern'; d: {$ifndef FPC}@{$endif}@XftFontOpenPattern),
  (n: 'XftDefaultSubstitute'; d: {$ifndef FPC}@{$endif}@XftDefaultSubstitute),
  (n: 'XftDrawPicture'; d: {$ifndef FPC}@{$endif}@XftDrawPicture),
  (n: 'XftDrawSrcPicture'; d: {$ifndef FPC}@{$endif}@XftDrawSrcPicture)
  );
begin
{$ifndef staticxft}
 result:= false;
 try
  initializefontconfig([]);
  fhasfontconfig:= true;
  getprocaddresses(xftnames,funcs);
 except
  exit;
 end;

{$endif} //not staticxft
 result:= true;
end;

function getxrenderlib: boolean;
const
 funcs: array[0..14] of funcinfoty = (
  (n: 'XRenderSetPictureClipRectangles'; 
                   d: {$ifndef FPC}@{$endif}@XRenderSetPictureClipRectangles),
  (n: 'XRenderCreatePicture'; d: {$ifndef FPC}@{$endif}@XRenderCreatePicture),
  (n: 'XRenderFillRectangle'; d: {$ifndef FPC}@{$endif}@XRenderFillRectangle),
  (n: 'XRenderSetPictureTransform'; 
                         d: {$ifndef FPC}@{$endif}@XRenderSetPictureTransform),
  (n: 'XRenderSetPictureFilter';
                            d: {$ifndef FPC}@{$endif}@XRenderSetPictureFilter),
  (n: 'XRenderFreePicture'; d: {$ifndef FPC}@{$endif}@XRenderFreePicture),
  (n: 'XRenderComposite'; d: {$ifndef FPC}@{$endif}@XRenderComposite),
  (n: 'XRenderQueryExtension'; 
                              d: {$ifndef FPC}@{$endif}@XRenderQueryExtension),
  (n: 'XRenderFindVisualFormat'; 
                            d: {$ifndef FPC}@{$endif}@XRenderFindVisualFormat),
  (n: 'XRenderFindStandardFormat'; 
                           d: {$ifndef FPC}@{$endif}@XRenderFindStandardFormat),
  (n: 'XRenderCompositeTriStrip'; 
                           d: {$ifndef FPC}@{$endif}@XRenderCompositeTriStrip),
  (n: 'XRenderCompositeTriFan'; 
                           d: {$ifndef FPC}@{$endif}@XRenderCompositeTriFan),
  (n: 'XRenderCompositeTriangles'; 
                           d: {$ifndef FPC}@{$endif}@XRenderCompositeTriangles),
  (n: 'XRenderChangePicture'; 
                           d: {$ifndef FPC}@{$endif}@XRenderChangePicture),
  (n: 'XRenderFindFormat'; 
                           d: {$ifndef FPC}@{$endif}@XRenderFindFormat)
  );
  
 funcsopt: array[0..1] of funcinfoty = (
  (n: 'XRenderCreateSolidFill'; 
                     d: {$ifndef FPC}@{$endif}@XRenderCreateSolidFill),
  (n: 'XRenderSetPictureClipRegion'; 
                     d: {$ifndef FPC}@{$endif}@XRenderSetPictureClipRegion)
  );

var
 handle: tlibhandle;
begin
 handle:= getprocaddresses(xrendernames,funcs,true);
 result:= handle <> 0;
 if result then begin
  getprocaddresses(handle,funcsopt,true);
  if xrendercreatesolidfill <> nil then begin
   createcolorpic:= @createcolorpic2;
  end
  else begin
   createcolorpic:= @createcolorpic1;
  end;
 end;
end;

const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gdi_creategc,
   {$ifdef FPC}@{$endif}gdi_destroygc,
   {$ifdef FPC}@{$endif}gdi_changegc,
   {$ifdef FPC}@{$endif}gdi_createpixmap,
   {$ifdef FPC}@{$endif}gdi_pixmaptoimage,
   {$ifdef FPC}@{$endif}gdi_imagetopixmap,
   {$ifdef FPC}@{$endif}gdi_getcanvasclass,
   {$ifdef FPC}@{$endif}gdi_endpaint,
   {$ifdef FPC}@{$endif}gdi_flush,
   {$ifdef FPC}@{$endif}gdi_movewindowrect,
   {$ifdef FPC}@{$endif}gdi_drawlines,
   {$ifdef FPC}@{$endif}gdi_drawlinesegments,
   {$ifdef FPC}@{$endif}gdi_drawellipse,
   {$ifdef FPC}@{$endif}gdi_drawarc,
   {$ifdef FPC}@{$endif}gdi_fillrect,
   {$ifdef FPC}@{$endif}gdi_fillellipse,
   {$ifdef FPC}@{$endif}gdi_fillarc,
   {$ifdef FPC}@{$endif}gdi_fillpolygon,
   {$ifdef FPC}@{$endif}gdi_drawstring16,
   {$ifdef FPC}@{$endif}gdi_setcliporigin,
   {$ifdef FPC}@{$endif}gdi_createemptyregion,
   {$ifdef FPC}@{$endif}gdi_createrectregion,
   {$ifdef FPC}@{$endif}gdi_createrectsregion,
   {$ifdef FPC}@{$endif}gdi_destroyregion,
   {$ifdef FPC}@{$endif}gdi_copyregion,
   {$ifdef FPC}@{$endif}gdi_moveregion,
   {$ifdef FPC}@{$endif}gdi_regionisempty,
   {$ifdef FPC}@{$endif}gdi_regionclipbox,
   {$ifdef FPC}@{$endif}gdi_regsubrect,
   {$ifdef FPC}@{$endif}gdi_regsubregion,
   {$ifdef FPC}@{$endif}gdi_regaddrect,
   {$ifdef FPC}@{$endif}gdi_regaddregion,
   {$ifdef FPC}@{$endif}gdi_regintersectrect,
   {$ifdef FPC}@{$endif}gdi_regintersectregion,
   {$ifdef FPC}@{$endif}gdi_copyarea,
   {$ifdef FPC}@{$endif}gdi_getimage,
   {$ifdef FPC}@{$endif}gdi_fonthasglyph,
   {$ifdef FPC}@{$endif}gdi_getfont,
   {$ifdef FPC}@{$endif}gdi_getfonthighres,
   {$ifdef FPC}@{$endif}gdi_freefontdata,
   {$ifdef FPC}@{$endif}gdi_gettext16width,
   {$ifdef FPC}@{$endif}gdi_getchar16widths,
   {$ifdef FPC}@{$endif}gdi_getfontmetrics
);

//var
// gdinumber: integer;

function x11getgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;
{
function x11getgdinum: integer;
begin
 result:= gdinumber;
end;
}
initialization
 fhasxft:= getxftlib;
 hasxrender:= getxrenderlib;
// gdinumber:= registergdi(x11getgdifuncs);
finalization
 if fhasfontconfig then begin
  releasefontconfig;
 end;
end.
