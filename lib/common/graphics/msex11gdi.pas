{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

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
 msectypes,mxrender,msefontconfig;

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
 createcolorpicturefuncty = function(const acolor: colorty): tpicture;
var 
 createcolorpicture: createcolorpicturefuncty;
 screenrenderpictformat,bitmaprenderpictformat,
                             alpharenderpictformat: pxrenderpictformat;

function createalphapicture(const size: sizety): tpicture;

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

 xftstatety = (xfts_clipregionvalid,xfts_smooth,xfts_colorforegroundvalid);
 xftstatesty = set of xftstatety;
 x11gcdty = record
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
  xftcolorforegroundpic: tpicture;
  xftlinewidth: integer;
  xftlinewidthsquare: integer;
  xftdashes: dashesstringty;
 // fontdirection: graphicdirectionty;
 end;
 {$if sizeof(x11gcdty) > sizeof(gcpty)} {$error 'buffer overflow'}{$ifend}
 x11gcty = record
  case integer of
   0: (d: x11gcdty;);
   1: (_bufferspace: gcpty;);
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
 XRenderFindVisualFormat: function(dpy:PDisplay; visual:PVisual):PXRenderPictFormat;cdecl;
 XRenderFindStandardFormat:  function(dpy:PDisplay;
              format:longint):PXRenderPictFormat; cdecl;

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
 msesys,msesonames,sysutils,msefcfontselect,msedynload;

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
 
var
 xftcolorcache: array[0..xftcolorcachemask] of xftcolorcacheinfoty;
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
 
 hasxrender:= hasxrender and (xrenderqueryextension(msedisplay,@int1,@int2) <> 0);
 if hasxrender then begin
  screenrenderpictformat:= xrenderfindvisualformat(appdisp,pvisual(defvisual));
  bitmaprenderpictformat:= xrenderfindstandardformat(appdisp,pictstandarda1);
  alpharenderpictformat:= xrenderfindstandardformat(appdisp,pictstandarda8);
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
  pixmap:= gui_createpixmap(size,0,monochrome,copyfrom);
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
   xsetgraphicsexposures(appdisp,tgc(gcpo^.handle),{$ifdef xboolean}false{$else}0{$endif});
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
 
procedure gdi_destroygc(var drawinfo: drawinfoty); //gdifunc
var
 int1: integer;
begin
 gdi_lock;
 with drawinfo do begin
  with x11gcty(gc.platformdata).d do begin
   if xftdraw <> nil then begin
    xftdrawdestroy(xftdraw);
    for int1:= 0 to high(xftcolorcache) do begin
     with xftcolorcache[int1] do begin
      if picture <> 0 then begin
       xrenderfreepicture(appdisp,picture);
       picture:= 0;
      end;
     end;
    end;
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

function createalphapicture(const size: sizety): tpicture;
var
 attributes: txrenderpictureattributes;
 pixmap: pixmapty;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= xcreatepixmap(appdisp,mserootwindow,size.cx,size.cy,8);
 result:= xrendercreatepicture(appdisp,pixmap,
                                   alpharenderpictformat,0,@attributes);
 xfreepixmap(appdisp,pixmap);
end;

function createcolorpicture1(const acolor: colorty): tpicture;
var
 attributes: txrenderpictureattributes;
 col: txrendercolor;
 pixmap: pixmapty;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 pixmap:= gui_createpixmap(
                   makesize(xrendercolorsourcesize,xrendercolorsourcesize));
 attributes._repeat:= repeatnormal;
 result:= xrendercreatepicture(appdisp,pixmap,screenrenderpictformat,
                                                       cprepeat,@attributes);
 col:= colortorendercolor(acolor);
 xrenderfillrectangle(appdisp,pictopsrc,result,@col,0,0,
                        xrendercolorsourcesize,xrendercolorsourcesize);
 xfreepixmap(appdisp,pixmap);
end;

function createcolorpicture2(const acolor: colorty): tpicture;
var
 col: txrendercolor;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 col:= colortorendercolor(acolor);
 result:= xrendercreatesolidfill(appdisp,@col);
end;
 
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
 attributes._repeat:= 1;
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
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 result:= 0;
 if amask <> nil then begin
  handle1:= tsimplebitmap1(amask).handle;
  if handle1 <> 0 then begin
   if amask.monochrome then begin
    attributes.component_alpha:= 1;
    result:= xrendercreatepicture(appdisp,tsimplebitmap1(amask).handle,
                         bitmaprenderpictformat,cpcomponentalpha,@attributes);
   end
   else begin
    attributes.component_alpha:= 1;
    result:= xrendercreatepicture(appdisp,tsimplebitmap1(amask).handle,
                         screenrenderpictformat,cpcomponentalpha,@attributes);
   end;
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
var
 flags1: xftstatesty;
 lwo1,lwo2: longword;
begin
 with x11gcty(drawinfo.gc.platformdata).d do begin
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
  if xfts_colorforegroundvalid in flags1 then begin
   lwo1:= xftcolor.pixel; 
   lwo2:= lwo1 + (lwo1 shr 7) + (lwo1 shr 14) + (lwo1 shr 21);
   lwo2:= (lwo2 xor (lwo2 shr 4) xor (lwo2 shr 9)) and xftcolorcachemask;
   with xftcolorcache[lwo2] do begin
    if picture <> 0 then begin
     if pixel <> xftcolor.pixel then begin
      xrenderfreepicture(appdisp,picture);
      picture:= createcolorpicture(xftcolor.pixel);
      pixel:= xftcolor.pixel;
     end;
    end
    else begin
     picture:= createcolorpicture(xftcolor.pixel);
     pixel:= xftcolor.pixel;
    end;
    xftcolorforegroundpic:= picture;
   end;
{
   xrenderfillrectangle(appdisp,pictopsrc,xftcolorforegroundpic,
          @xftcolor.color,0,0,xrendercolorsourcesize,xrendercolorsourcesize);
}
   include(xftstate,xfts_colorforegroundvalid);
  end;
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
  if gvm_rasterop in mask then begin
   xmask:= xmask or gcfunction;
   xvalues.xfunction:= integer(rasterop);
   gcrasterop:= rasterop;
  end;
  if gvm_linewidth in mask then begin
   xmask:= xmask or gclinewidth;
   xvalues.line_width:= (lineinfo.width + linewidthroundvalue) shr linewidthshift;
   xftlinewidth:= xvalues.line_width shl 16;
   xftlinewidthsquare:= xvalues.line_width*xvalues.line_width{ shl 16};
   if xftlinewidth = 0 then begin
    xftlinewidth:= 1 shl 16;
    xftlinewidthsquare:= 1{ shl 16};
   end;
  end;
  if gvm_dashes in mask then begin
   with lineinfo do begin
    xftdashes:= dashes;
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
   xvalues.cap_style:= capstyles[lineinfo.capstyle];
   xmask:= xmask or gccapstyle;
  end;
  if gvm_joinstyle in mask then begin
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
   end;
  end;
  if gvm_colorforeground in mask then begin
   xmask:= xmask or gcforeground;
   xvalues.foreground:= colorforeground;
   xvalues.fill_style:= fillsolid;
   if fhasxft then begin
    xftcolor.pixel:= colorforeground;
    xftcolor.color:= colortorendercolor(drawinfo.acolorforeground);
    exclude(xftstate,xfts_colorforegroundvalid);
   end;
  end;
  if gvm_brushorigin in mask then begin
   xmask:= xmask or gctilestipxorigin or gctilestipyorigin;
   xvalues.ts_x_origin:= brushorigin.x;
   xvalues.ts_y_origin:= brushorigin.y;
  end;

  if (drawingflags >< gcdrawingflags)
           * (fillmodeinfoflags+[df_smooth]) <> [] then begin
   xmask:= xmask or gcfillstyle;
   if df_brush in drawingflags then begin
    if df_monochrome in drawingflags then begin
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
  if gvm_brush in mask then begin
   if df_monochrome in drawingflags then begin
//    xvalues.stipple:= brush;
    xvalues.stipple:= tsimplebitmap1(brush).handle;
    xmask:= xmask or gcstipple;
   end
   else begin
    xvalues.tile:= tsimplebitmap1(brush).handle;
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
procedure gdi_copyarea(var drawinfo: drawinfoty); //gdifunc

const
 sourceformats = cpclipmask or cpclipxorigin or cpclipyorigin;
 destformats = cpgraphicsexposure;

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
 transform: txtransform;
 ax,ay: integer;
 aformat: pxrenderpictformat;
// color1: txrendercolor;
 {pixmap1,}pixmap2: pixmapty;
// areg: region;
// arect: xrectangle;
 needstransform: boolean;
 pictop: integer;
 colormask: boolean;
// bo1: boolean;
label
 endlab,endlab2;
  
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
 spd: paintdevicety;
 x1,y1: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,copyarea,sourcerect^,gc,x11gcty(platformdata).d do begin
  needstransform:= (alignment * [al_stretchx,al_stretchy] <> []) and
            ((destrect^.cx <> sourcerect^.cx) or
            (destrect^.cy <> sourcerect^.cy)) and
            (destrect^.cx > 0) and (destrect^.cy > 0);
  colormask:= (mask <> nil) and (not mask.monochrome or needstransform);
  if hasxrender and (needstransform or (longword(opacity) <> maxopacity) or
                                                           colormask) then begin
   if needstransform then begin
//    pictop:= pictopover;
    pictop:= pictopsrc;
    transform:= unitytransform;
    transform[0,0]:= getscale(cx,destrect^.cx,x,ax);
    transform[1,1]:= getscale(cy,destrect^.cy,y,ay);
   end
   else begin
    pictop:= pictopsrc;
    ax:= x;
    ay:= y;
   end;
   if (longword(opacity) <> maxopacity) and not colormask then begin
    maskpic:= createmaskpicture(opacity);
    pictop:= pictopover;
   end
   else begin
    if colormask then begin
     maskpic:= createmaskpicture(mask);
     updatetransform(maskpic);
     pictop:= pictopover;
    end
    else begin
     maskpic:= 0;
     if (df_canvasismonochrome in gc.drawingflags) and (mask = nil) then begin
      pictop:= pictopsrc; 
     end
     else begin
      if mask <> nil then begin
       maskpic:= createmaskpicture(mask);
      end;
      pictop:= pictopover; //pictopsrc is unreliable!?
     end;
    end;
   end;
   with sattributes do begin
//    clip_x_origin:= ax;
//    clip_y_origin:= ay;
    clip_x_origin:= 0;
    clip_y_origin:= 0;
    if (mask <> nil) and not colormask then begin
     clip_mask:= tsimplebitmap1(mask).handle;
    end
    else begin
     clip_mask:= 0;
    end;
   end;
   with dattributes do begin
    graphics_exposures:= 0;
   end;
   if df_colorconvert in gc.drawingflags then begin
    if df_canvasismonochrome in gc.drawingflags then begin
     if maskpic <> 0 then begin
      xrenderfreepicture(appdisp,maskpic);
     end;
     exit; //not supported;         //todo !!!
    end
    else begin //monochrome -> color
     bitmapgc2:= nil;
     bitmap:= 0;
     if (mask <> nil) and mask.monochrome then begin
      bitmap:= gui_createpixmap(size,0,true);
      if bitmap <> 0 then begin
       bitmapgc2:= xcreategc(appdisp,bitmap,0,@xvalues);
       if bitmapgc2 <> nil then begin
        xcopyarea(appdisp,tcanvas1(source).fdrawinfo.paintdevice,
                          bitmap,bitmapgc2,x,y,cx,cy,0,0);
        xvalues.xfunction:= gxand;
        xchangegc(appdisp,bitmapgc2,gcfunction,@xvalues);
        xcopyarea(appdisp,mask.handle,bitmap,bitmapgc2,x,y,cx,cy,0,0);
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
     dpic:= xrendercreatepicture(appdisp,paintdevice,screenrenderpictformat,
                      destformats,@dattributes);
     cpic:= createcolorpicture(acolorforeground);
     if gcclipregion <> 0 then begin
      setregion(gc,region(gcclipregion),dpic);
     end;
     updatetransform(spic);
     if acolorforeground <> cl_transparent then begin
      xrendercomposite(appdisp,pictop,cpic,spic,dpic,0,0,ax,ay,
                           destrect^.x,destrect^.y,destrect^.cx,destrect^.cy);
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
      cpic:= createcolorpicture(acolorbackground);
      xrendercomposite(appdisp,pictop,cpic,spic,dpic,0,0,ax,ay,destrect^.x,destrect^.y,
                         destrect^.cx,destrect^.cy);
      xrenderfreepicture(appdisp,cpic);
      xfillrectangle(appdisp,spd,bitmapgc,x1,y1,cx,cy);
      xfreegc(appdisp,bitmapgc);
     end;
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
    if df_canvasismonochrome in gc.drawingflags then begin
     aformat:= bitmaprenderpictformat;
    end
    else begin
     aformat:= screenrenderpictformat;
    end;
    dpic:= xrendercreatepicture(appdisp,paintdevice,aformat,destformats,
               @dattributes);
    spic:= xrendercreatepicture(appdisp,tcanvas1(source).paintdevice,aformat,
               sourceformats,@sattributes);
    if gcclipregion <> 0 then begin
     setregion(gc,region(gcclipregion),dpic);
    end;
    updatetransform(spic);
    {
    if needstransform then begin
     xrendersetpicturetransform(appdisp,spic,@transform);
    end;
    }
    xrendercomposite(appdisp,pictop,spic,maskpic,dpic,ax,ay,ax,ay,destrect^.x,destrect^.y,
                       destrect^.cx,destrect^.cy);
//    xrendercomposite(appdisp,pictop,spic,maskpic,dpic,ax,ay,0,0,destrect^.x,destrect^.y,
//                       destrect^.cx,destrect^.cy);
   end;
   xrenderfreepicture(appdisp,spic);
   xrenderfreepicture(appdisp,dpic);
   if maskpic <> 0 then begin
    xrenderfreepicture(appdisp,maskpic);
   end;
  end
  else begin
   pixmap2:= 0;
   if copymode <> gcrasterop then begin
    xsetfunction(appdisp,tgc(gc.handle),integer(copymode));
   end;
   if mask <> nil then begin
    amask:= tsimplebitmap1(mask).handle;
    if gcclipregion <> 0 then begin
     pixmap2:= gui_createpixmap(size,0,true);
     maskgc.handle:= ptruint(xcreategc(appdisp,pixmap2,0,@xvalues));
//xsetforeground(appdisp,tgc(maskgc.handle),$1);
//xfillrectangle(appdisp,mask,tgc(maskgc.handle),0,0,100,100);
 //    pixmapgc:= xcreategc(appdisp,pixmap2,0,@xvalues);
     xfillrectangle(appdisp,pixmap2,tgc(maskgc.handle),0,0,cx,cy);
     maskgc.cliporigin:= subpoint(cliporigin,destrect^.pos);
     setregion(maskgc,region(gcclipregion));
 //    xsetregion(appdisp,pixmapgc,region(gcclipregion));    //??? cliporigin gc?
 //    xvalues.clip_x_origin:= -dest^.x+;
 //    xvalues.clip_y_origin:= -dest^.y;
 //    xchangegc(appdisp,pixmapgc,gcclipxorigin or gcclipyorigin,@xvalues);
     xcopyarea(appdisp,amask,pixmap2,tgc(maskgc.handle),x,y,cx,cy,0,0);
//     xsetclipmask(appdisp,tgc(gc.handle),pixmap2);
     xvalues.clip_x_origin:= destrect^.x;
     xvalues.clip_y_origin:= destrect^.y;
     xvalues.clip_mask:= pixmap2;
     xchangegc(appdisp,tgc(gc.handle),gcclipxorigin or gcclipyorigin or
                  gcclipmask,@xvalues);
     xfreegc(appdisp,tgc(maskgc.handle));
//     xflushgc(appdisp,tgc(gc.handle)); //aquire pixmap
//     xfreepixmap(appdisp,pixmap2);
         //xlib assertion error!
    end
    else begin
//     xsetclipmask(appdisp,tgc(gc.handle),mask);
     xvalues.clip_mask:= amask;
     xvalues.clip_x_origin:= destrect^.x - x;
     xvalues.clip_y_origin:= destrect^.y - y;
     xchangegc(appdisp,tgc(gc.handle),gcclipxorigin or gcclipyorigin or
                      gcclipmask,@xvalues);
    end;
   end;
   if df_colorconvert in gc.drawingflags then begin
    xvalues.graphics_exposures:= {$ifdef xboolean}false{$else}0{$endif};
    if df_canvasismonochrome in gc.drawingflags then begin
                        //convert to monochrome
     pixmap:= gui_createpixmap(size);
     if pixmap = 0 then begin
      goto endlab;
     end;
     pixmapgc:= xcreategc(appdisp,pixmap,gcgraphicsexposures,@xvalues);
     if pixmapgc <> nil then begin
      xcopyarea(appdisp,tcanvas1(source).fdrawinfo.paintdevice,pixmap,pixmapgc,x,y,cx,cy,0,0);
      xvalues.foreground:= transparentcolor;
      xvalues.xfunction:= integer(rop_xor);
      xchangegc(appdisp,pixmapgc,gcforeground or gcfunction,@xvalues);
      xfillrectangle(appdisp,pixmap,pixmapgc,0,0,cx,cy);
      bitmap:= gui_createpixmap(size,0,true);
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
        for int1:= 0 to defdepth - 1 do begin
         xcopyplane(appdisp,pixmap,bitmap,bitmapgc,0,0,cx,cy,
                        0,0,1 shl int1);
        end;
        xcopyarea(appdisp,bitmap,paintdevice,tgc(gc.handle),0,0,cx,cy,destrect^.x,destrect^.y);
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
      xcopygc(appdisp,tgc(gc.handle),gcfunction or gcplanemask or gcsubwindowmode or
                gcgraphicsexposures or gcclipxorigin or
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
   end
   else begin
    xcopyarea(appdisp,tcanvas1(source).fdrawinfo.paintdevice,paintdevice,
                    tgc(gc.handle),x,y,cx,cy,destrect^.x,destrect^.y);
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

type
 lineshiftvectorty = record
  shift: pointty;
  d: pointty;  //delta
  c: integer;  //length
 end;
 lineshiftinfoty = record
  dist: integer;
  pointa: ppointty;
  pointb: ppointty;
  linestart: ppointty;
  v: lineshiftvectorty;
  offs: pointty;
  dest: pxpointfixed;
  dashlen: integer;
  dashind: integer;
  dashpos: integer;
  dashref: integer;
 end;
 plineshiftinfoty = ^lineshiftinfoty;
//
//todo: optimize smooth line generation
//
procedure calclineshift(const drawinfo: drawinfoty; var info: lineshiftinfoty);
var
 offsx,offsy: integer;
begin
 with info do begin
  v.d.x:= pointb^.x - pointa^.x;
  v.d.y:= pointb^.y - pointa^.y;
  v.c:= round(sqrt(v.d.x*v.d.x + v.d.y*v.d.y));
  offsx:= 0;
  offsy:= 0;
  if v.c = 0 then begin
   v.shift.x:= 0;
   v.shift.y:= 0;
  end
  else begin
   v.shift.x:= (v.d.y*dist) div v.c;
   v.shift.y:= (v.d.x*dist) div v.c;
   if dist and $10000 <> 0 then begin //odd, shift 0.5 pixel
    offsx:= v.d.y shl 15 div v.c;
    offsy:= v.d.x shl 15 div v.c;
   end;
  end;
  offs.x:= (drawinfo.origin.x shl 16) + v.shift.x div 2 - offsx;
  offs.y:= (drawinfo.origin.y shl 16) - v.shift.y div 2 + offsy;
  linestart:= pointa;
 end;
end;

procedure shiftpoint(var info: lineshiftinfoty);
var
 x1,y1: integer;
begin
 with info do begin
  x1:= (pointa^.x shl 16) + offs.x;
  y1:= (pointa^.y shl 16) + offs.y;
  dest^.x:= x1;
  dest^.y:= y1;
  inc(dest);
  dest^.x:= x1 - v.shift.x;
  dest^.y:= y1 + v.shift.y;
  inc(dest);
  pointa:= pointb;
  inc(pointb);
 end;
end;

type
 intersectinfoty = record
  da,db: pointty;
  p0,p1: pxpointfixed;
  isect: txpointfixed;
  axbx,axby,aybx,ayby: int64;
  q: integer;
 end;

procedure intersect2(var info: intersectinfoty);
begin
 with info do begin
//xa == (dxa*dxb*y0 - dxa*dxb*y1 + dxa*dyb*x1 - dxb*dya*x0)/(dxa*dyb - dxb*dya)
  isect.x:= (axbx*p0^.y - axbx*p1^.y + axby*p1^.x - aybx*p0^.x) div q;
//ya == (dxa*dyb*y0 - dxb*dya*y1 - dya*dyb*x0 + dya*dyb*x1)/(dxa*dyb - dxb*dya)
  isect.y:= (axby*p0^.y - aybx*p1^.y - ayby*p0^.x + ayby*p1^.x) div q;
 end;
end;
 
function intersect(var info: intersectinfoty): boolean;
begin
 result:= false;
 with info do begin
  axby:= da.x*db.y;
  aybx:= da.y*db.x;
  q:= axby - aybx;
  if q <> 0 then begin
   result:= true;
   axbx:= da.x*db.x;
   ayby:= da.y*db.y;
   intersect2(info);
  end;
 end;
end;

procedure dashinit(var drawinfo: drawinfoty; var li: lineshiftinfoty);
var
 int1: integer;
begin
 with drawinfo,x11gcty(gc.platformdata).d do begin
  allocbuffer(buffer,3*sizeof(txpointfixed)); //possible first triangle
  buffer.cursize:= 0;
  li.dest:= buffer.buffer;
  li.dashlen:= 0;
  for int1:= 1 to length(xftdashes) do begin
   li.dashlen:= li.dashlen + ord(xftdashes[int1]);
  end;
 end;
end;

procedure dash(var drawinfo: drawinfoty; var li: lineshiftinfoty;
                  const start: boolean; const endpoint: boolean);
var
 po3: pxpointfixed;
 pt0: txpointfixed;
 dx,dy: integer;
 dashstop,dashpos,dashind: integer;
 x1,y1: integer;
begin
 with drawinfo,x11gcty(gc.platformdata).d do begin
  if start then begin
   dashpos:= ord(xftdashes[1]);
   dashind:= 1;
   li.dashref:= 0;
  end
  else begin
   dashpos:= li.dashpos-li.dashref;
   dashind:= li.dashind;
  end;
  dashstop:= li.v.c;
  extendbuffer(buffer,
        (((dashstop-dashpos) div li.dashlen + 1)*length(xftdashes)+3*2)*
                                        3*sizeof(txpointfixed),li.dest);
                     //+3*2 -> additional memory for ends and vertex
  po3:= li.dest;
  pt0.x:= (li.linestart^.x shl 16) + li.offs.x;
  pt0.y:= (li.linestart^.y shl 16) + li.offs.y;
  dx:= li.v.d.x shl 16 div li.v.c;
  dy:= li.v.d.y shl 16 div li.v.c;
  while dashpos < dashstop do begin
   if odd(dashind) then begin
    x1:= pt0.x + dashpos*dx; 
    y1:= pt0.y + dashpos*dy; 
    po3^.x:= x1; 
    po3^.y:= y1; 
    inc(po3);
    po3^:= (po3-2)^;
    inc(po3);
    po3^.x:= x1; 
    po3^.y:= y1; 
    inc(po3);
    po3^.x:= x1 - li.v.shift.x;
    po3^.y:= y1 + li.v.shift.y;
   end
   else begin
    x1:= pt0.x + dashpos*dx; 
    y1:= pt0.y + dashpos*dy; 
    po3^.x:= x1;
    po3^.y:= y1;
    inc(po3);
    po3^.x:= x1 - li.v.shift.x;
    po3^.y:= y1 + li.v.shift.y;
   end;
   inc(po3);
   inc(dashind);
   if dashind > length(xftdashes) then begin
    dashind:= 1;
   end;
   dashpos:= dashpos + ord(xftdashes[dashind]);
  end;
  if odd(dashind) and endpoint then begin
   x1:= pt0.x + (li.v.d.x shl 16);
   y1:= pt0.y + (li.v.d.y shl 16);
   po3^.x:= x1;
   po3^.y:= y1;
   inc(po3);
   po3^:= (po3-2)^;
   inc(po3);
   po3^.x:= x1;
   po3^.y:= y1;
   inc(po3);
   po3^.x:= x1 - li.v.shift.x;
   po3^.y:= y1 + li.v.shift.y;
   inc(po3);
  end;
  li.dest:= po3;
  li.dashind:= dashind;
  li.dashpos:= dashpos+li.dashref;
  li.dashref:= li.dashref+li.v.c;
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty); //gdifunc
var
 li: lineshiftinfoty;
 pt0,pt1: txpointfixed;

 procedure pushdashend;
 var
  po0: pxpointfixed;
 begin
  po0:= li.dest;
  po0^:= pt0;
  inc(po0);
  po0^:= (po0-2)^;
  inc(po0);
  po0^:= pt0;
  inc(po0);
  po0^:= pt1;
  inc(po0);
  po0^:= pt0;
  inc(po0);
  po0^:= pt1;
  inc(po0);
  li.dest:= po0;
 end; //pushdashend

var
 int1,int2: integer;
 pointcount: integer;
 ints: intersectinfoty;
 pend: ppointty;
 bo1: boolean;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,points,x11gcty(gc.platformdata).d do begin
  if xfts_smooth in xftstate then begin
   checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
   pointcount:= count;
   if closed then begin
    inc(pointcount);
   end;
   pointcount:= pointcount*2;
   li.pointa:= points;
   pend:= points+count;
   li.pointb:= li.pointa+1;
   li.dist:= xftlinewidth;
   if closed then begin
    int2:= count-1;
   end
   else begin
    int2:= count-3;
   end;
   if df_dashed in gc.drawingflags then begin
    dashinit(drawinfo,li);
    calclineshift(drawinfo,li);
    shiftpoint(li);
    bo1:= true; //start dash
    for int1:= 0 to int2 do begin
     if li.pointb = pend then begin
      li.pointb:= points;
     end;
     dash(drawinfo,li,bo1,false);
     bo1:= false;

     ints.da:= li.v.d;
     calclineshift(drawinfo,li);
     shiftpoint(li);
     ints.db:= li.v.d;
     ints.p0:= li.dest-4;
     ints.p1:= li.dest-2;
     if intersect(ints) then begin
      pt0:= ints.isect;
      inc(ints.p0);
      inc(ints.p1);
      intersect2(ints);
      pt1:= ints.isect;
     end
     else begin
      pt0:= (li.dest-2)^;
      pt1:= (li.dest-1)^;
     end;
     dec(li.dest,2);
     if odd(li.dashind) then begin //dash
      pushdashend;
     end;
    end;
    if closed then begin
     (pxpointfixed(buffer.buffer))^:= pt0;
     (pxpointfixed(buffer.buffer)+1)^:= pt1;
    end
    else begin
     dash(drawinfo,li,bo1,false);
     if odd(li.dashind) then begin //dash
      shiftpoint(li);
      pt0:= (li.dest-2)^;
      pt1:= (li.dest-1)^;
      dec(li.dest,2);
      pushdashend;
     end;     
    end;
    xrendercompositetriangles(appdisp,xrenderop,xftcolorforegroundpic,
                     xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,
                     (li.dest-pxpointfixed(buffer.buffer)) div 3);
   end
   else begin
    allocbuffer(buffer,pointcount*sizeof(txpointfixed));
    li.dest:= buffer.buffer;
    calclineshift(drawinfo,li);
    shiftpoint(li);
    for int1:= 0 to int2 do begin
     if li.pointb = pend then begin
      li.pointb:= points;
     end;
     ints.da:= li.v.d;
     calclineshift(drawinfo,li);
     shiftpoint(li);
     ints.db:= li.v.d;
     ints.p0:= li.dest-4;
     ints.p1:= li.dest-2;
     if intersect(ints) then begin
      ints.p1^:= ints.isect;
      inc(ints.p0);
      inc(ints.p1);
      intersect2(ints);
      ints.p1^:= ints.isect;
     end;
    end;
    if closed then begin
     (pxpointfixed(buffer.buffer))^:= (ints.p1-1)^;
     (pxpointfixed(buffer.buffer)+1)^:= ints.p1^;
    end
    else begin
     shiftpoint(li);
    end;
    xrendercompositetristrip(appdisp,xrenderop,xftcolorforegroundpic,
              xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,pointcount);
   end;
  end
  else begin
   transformpoints(drawinfo,closed);
   int1:= count;
   if closed then begin
    inc(int1);
   end;
   xdrawlines(appdisp,paintdevice,tgc(gc.handle),buffer.buffer,int1,
                            coordmodeorigin);
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty); //gdifunc
var
 po1: pxpointfixed;
 int1: integer;
 li: lineshiftinfoty;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.points,x11gcty(gc.platformdata).d do begin
  if xfts_smooth in xftstate then begin
   checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
   with drawinfo,drawinfo.points do begin
    li.pointa:= points;
    li.pointb:= li.pointa+1;
    li.dist:= xftlinewidth;
    if df_dashed in gc.drawingflags then begin
     dashinit(drawinfo,li);
     for int1:= 0 to (count div 2)-1 do begin
      calclineshift(drawinfo,li);
      shiftpoint(li);
      dash(drawinfo,li,true,true);
      li.pointa:= li.pointb;
      inc(li.pointb);
     end;
     xrendercompositetriangles(appdisp,xrenderop,xftcolorforegroundpic,
                     xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,
                     (li.dest-pxpointfixed(buffer.buffer)) div 3);
    end
    else begin
     allocbuffer(buffer,2*count*sizeof(txpointfixed));
     li.dest:= buffer.buffer;
     for int1:= 0 to (count div 2)-1 do begin
      po1:= li.dest;
      calclineshift(drawinfo,li);
      shiftpoint(li);
      shiftpoint(li);
      xrendercompositetristrip(appdisp,xrenderop,xftcolorforegroundpic,
                     xftdrawpic,alpharenderpictformat,0,0,po1,4);
     end;
    end;
   end;
  end
  else begin
   transformpoints(drawinfo,false);
   xdrawsegments(appdisp,paintdevice,tgc(gc.handle),buffer.buffer,count div 2);
  end;
 end;
end;

procedure adjustellipsecenter(const drawinfo: drawinfoty;
                                        var center: txpointfixed);
begin
 with drawinfo,rect.rect^ do begin
  center.x:= (x+origin.x) shl 16;
  if not odd(cx) then begin
   center.x:= center.x + $8000;
  end
  else begin
   center.x:= center.x + $10000;
  end;
  center.y:= (y+origin.y) shl 16;
  if not odd(cy) then begin
   center.y:= center.y + $8000;
  end
  else begin
   center.y:= center.y + $10000;
  end;
 end;
end;

procedure gdi_fillellipse(var drawinfo: drawinfoty); //gdifunc
//todo: optimize
var
 rea1,sx,sy,f,si,co: real;
 x1,y1: integer;
 q0,q1,q2,q3: pxpointfixed;
 npoints: integer;
 int1: integer;
 center: txpointfixed;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.rect.rect^ do begin
  if xfts_smooth in x11gcty(gc.platformdata).d.xftstate then begin
   int1:= cx;
   if cy > int1 then begin
    int1:= cy;
   end;
   int1:= (int1+1) div 2; //samples per quadrant
   rea1:= pi/(2*int1);
   npoints:= 2+4*int1; //center + endpoint
   allocbuffer(buffer,npoints*sizeof(txpointfixed));
   si:= sin(rea1);
   co:= cos(rea1);
   adjustellipsecenter(drawinfo,center);
   q0:= buffer.buffer;
   q0^:= center;
   inc(q0);
   q1:= q0+int1;
   q2:= q1+int1;
   q3:= q2+int1;
   if cx > cy then begin
    f:= cy/cx;
    sx:= cx*(65536/2);
    sy:= 0;    
    for int1:= int1-1 downto 0 do begin
     y1:= round(sy*f);
     x1:= round(sx);
     q0^.x:= center.x + x1;
     q0^.y:= center.y - y1;
     inc(q0);
     q2^.x:= center.x - x1;
     q2^.y:= center.y + y1;
     inc(q2);
     x1:= round(sx*f);
     y1:= round(sy);
     q1^.x:= center.x - y1;
     q1^.y:= center.y - x1;
     inc(q1);
     q3^.x:= center.x + y1;
     q3^.y:= center.y + x1;
     inc(q3);
     rea1:= sx;
     sx:= co*sx-si*sy;
     sy:= co*sy+si*rea1;
    end;
   end
   else begin
    f:= cx/cy;
    sy:= cy*(65536/2);
    sx:= 0;    
    for int1:= int1-1 downto 0 do begin
     x1:= round(sx*f);
     y1:= round(sy);
     q0^.y:= center.y - y1;
     q0^.x:= center.x + x1;
     inc(q0);
     q2^.y:= center.y + y1;
     q2^.x:= center.x - x1;
     inc(q2);
     y1:= round(sy*f);
     x1:= round(sx);
     q1^.y:= center.y - x1;
     q1^.x:= center.x - y1;
     inc(q1);
     q3^.y:= center.y + x1;
     q3^.x:= center.x + y1;
     inc(q3);
     rea1:= sx;
     sx:= co*sx-si*sy;
     sy:= co*sy+si*rea1;
    end;
   end;
   q3^:= (pxpointfixed(buffer.buffer)+1)^; //endpoint
   with x11gcty(gc.platformdata).d do begin
    checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
    xrendercompositetrifan(appdisp,xrenderop,xftcolorforegroundpic,
                    xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,npoints);
   end;  
  end
  else begin
   xfillarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,0,wholecircle);
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty); //gdifunc
var
 rea1,sx,sy,w,cxw,cyw,cx1,cy1,cx2,cy2,{xdy,ydx,}si,co: real;
 x1,y1,x2,y2: integer;
 q0,q1,q2,q3: pxpointfixed;
 npoints: integer;
 int1,int2: integer;
 center: txpointfixed;
 circle: boolean;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,x11gcty(gc.platformdata).d,rect.rect^ do begin
  if xfts_smooth in xftstate then begin
   circle:= cx = cy;
   int1:= cx;
   if cy > int1 then begin
    int1:= cy;
   end;
   if int1 = 0 then begin
    exit;
   end;
   int1:= (int1+1) div 2; //samples per quadrant
   rea1:= pi/(2*int1);
   npoints:= 8*int1+2; //+ endpoint
   allocbuffer(buffer,npoints*sizeof(txpointfixed));
   si:= sin(rea1);
   co:= cos(rea1);
   adjustellipsecenter(drawinfo,center);
   int2:= int1*2;
   q0:= buffer.buffer;
   q1:= q0+int2;
   q2:= q1+int2;
   q3:= q2+int2;
   cx1:= cx * (65536 div 2);
   cx2:= cx1*cx1;
   cy1:= cy * (65536 div 2);
   cy2:= cy1*cy1;
   w:= xftlinewidth div 2;
   cxw:= cx1*w;
   cyw:= cy1*w;
   sx:= 1;
   sy:= 0;    
   for int1:= int1-1 downto 0 do begin
    x1:= round(cx1*sx);
    y1:= round(cy1*sy);
    rea1:= sqrt(cx2*sy*sy+cy2*sx*sx);
    if rea1 = 0 then begin
     x2:= round(w);
     y2:= 0;
    end
    else begin
     x2:= round(cyw*sx/rea1);
     y2:= round(cxw*sy/rea1);
    end;
    q0^.x:= center.x + x1 + x2;
    q0^.y:= center.y - y1 - y2;
    inc(q0);
    q0^.x:= center.x + x1 - x2;
    q0^.y:= center.y - y1 + y2;
    inc(q0);
    q2^.x:= center.x - x1 - x2;
    q2^.y:= center.y + y1 + y2;
    inc(q2);
    q2^.x:= center.x - x1 + x2;
    q2^.y:= center.y + y1 - y2;
    inc(q2);
    if not circle then begin
     x1:= round(cy1*sx);
     y1:= round(cx1*sy);
     rea1:= sqrt(cy2*sy*sy+cx2*sx*sx);
     if rea1 <> 0 then begin
      x2:= round(cxw*sx/rea1);
      y2:= round(cyw*sy/rea1);
     end;
    end;
    q1^.x:= center.x - y1 - y2;
    q1^.y:= center.y - x1 - x2;
    inc(q1);
    q1^.x:= center.x - y1 + y2;
    q1^.y:= center.y - x1 + x2;
    inc(q1);
    q3^.x:= center.x + y1 + y2;
    q3^.y:= center.y + x1 + x2;
    inc(q3);
    q3^.x:= center.x + y1 - y2;
    q3^.y:= center.y + x1 - x2;
    inc(q3);
    rea1:= sx;
    sx:= co*sx-si*sy;
    sy:= co*sy+si*rea1;
   end;
   q3^:= pxpointfixed(buffer.buffer)^;   //endpoint
   inc(q3);
   q3^:= (pxpointfixed(buffer.buffer)+1)^;
   with x11gcty(gc.platformdata).d do begin
    checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
    xrendercompositetristrip(appdisp,xrenderop,xftcolorforegroundpic,
                    xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,npoints);
   end;  
  end
  else begin
   xdrawarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,0,wholecircle);
  end;
 end;
end;

const
 angscale = 64*360/(2*pi);
 
procedure gdi_drawarc(var drawinfo: drawinfoty); //gdifunc
var
 rea1,sx,sy,w,cxw,cyw,cx1,cy1,cx2,cy2,{xdy,ydx,}si,co: real;
 x1,y1,x2,y2,x3,y3,x4,y4: integer;
 q0: pxpointfixed;
 po1: pxtriangle;
 npoints: integer;
 int1: integer;
 center: txpointfixed;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,x11gcty(gc.platformdata).d,drawinfo.arc,rect^ do begin
  if xfts_smooth in xftstate then begin
   int1:= cx;
   if cy > int1 then begin
    int1:= cy;
   end;
   if int1 = 0 then begin
    exit;
   end;
   checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
   int1:= round(int1*abs(extentang)/pi); //steps
   rea1:= extentang/int1; //step
   si:= sin(rea1);
   co:= cos(rea1);
   adjustellipsecenter(drawinfo,center);
   cx1:= cx * (65536 div 2);
   cx2:= cx1*cx1;
   cy1:= cy * (65536 div 2);
   cy2:= cy1*cy1;
   w:= xftlinewidth div 2;
   cxw:= cx1*w;
   cyw:= cy1*w;
   sx:= cos(startang);
   sy:= sin(startang);
   if df_dashed in gc.drawingflags then begin
    allocbuffer(buffer,(6*int1+12)*sizeof(txpointfixed));
            //+ start dummy + endpoint, max
    q0:= pxpointfixed(buffer.buffer)+2;
    for int1:= int1 downto 0 do begin
     x1:= round(cx1*sx);
     y1:= round(cy1*sy);
     rea1:= sqrt(cx2*sy*sy+cy2*sx*sx);
     if rea1 = 0 then begin
      x2:= round(w);
      y2:= 0;
     end
     else begin
      x2:= round(cyw*sx/rea1);
      y2:= round(cxw*sy/rea1);
     end;
     x3:= center.x + x1 + x2;
     y3:= center.y - y1 - y2;
     x4:= center.x + x1 - x2;
     y4:= center.y - y1 + y2;
     q0^.x:= x3;
     q0^.y:= y3;
     inc(q0);
     q0^:= (q0-2)^;
     inc(q0);
     q0^.x:= x3;
     q0^.y:= y3;
     inc(q0);
     q0^.x:= x4;
     q0^.y:= y4;
     inc(q0);
     q0^.x:= x3;
     q0^.y:= y3;
     inc(q0);
     q0^.x:= x4;
     q0^.y:= y4;
     inc(q0);
     rea1:= sx;
     sx:= co*sx-si*sy;
     sy:= co*sy+si*rea1;
    end;
    po1:= pxtriangle(buffer.buffer)+2;
    xrendercompositetriangles(appdisp,xrenderop,xftcolorforegroundpic,
                 xftdrawpic,alpharenderpictformat,0,0,po1,pxtriangle(q0)-po1);
   end
   else begin
    npoints:= 2*int1+2; //+ endpoint
    allocbuffer(buffer,npoints*sizeof(txpointfixed));
    q0:= buffer.buffer;
    for int1:= int1 downto 0 do begin
     x1:= round(cx1*sx);
     y1:= round(cy1*sy);
     rea1:= sqrt(cx2*sy*sy+cy2*sx*sx);
     if rea1 = 0 then begin
      x2:= round(w);
      y2:= 0;
     end
     else begin
      x2:= round(cyw*sx/rea1);
      y2:= round(cxw*sy/rea1);
     end;
     q0^.x:= center.x + x1 + x2;
     q0^.y:= center.y - y1 - y2;
     inc(q0);
     q0^.x:= center.x + x1 - x2;
     q0^.y:= center.y - y1 + y2;
     inc(q0);
     rea1:= sx;
     sx:= co*sx-si*sy;
     sy:= co*sy+si*rea1;
    end;
    xrendercompositetristrip(appdisp,xrenderop,xftcolorforegroundpic,
                     xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,npoints);
   end;
  end
  else begin
   xdrawarc(appdisp,paintdevice,tgc(gc.handle),
    x+origin.x-cx div 2,y+origin.y - cy div 2,cx,cy,
    round(startang*angscale),round(extentang*angscale));
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
   checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
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

procedure gdi_fillarc(var drawinfo: drawinfoty); //gdifunc
var
 xvalues: xgcvalues;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with drawinfo,drawinfo.arc,rect^ do begin
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

procedure gdi_fillpolygon(var drawinfo: drawinfoty); //gdifunc
var
// int1: integer;
 po1,po2: ppointty;
 po3: pxpointfixed;
 offsx,offsy: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif}

 with drawinfo do begin
  if xfts_smooth in x11gcty(gc.platformdata).d.xftstate then begin
  
//todo: implement concave figures

   if points.count > 2 then begin
    allocbuffer(buffer,points.count*sizeof(txpointfixed));
    po1:= points.points;
    po2:= points.points+points.count-1;
    po3:= buffer.buffer;
    offsx:= (origin.x shl 16);
    offsy:= (origin.y shl 16);
    while po1 < po2 do begin
     po3^.x:= (po1^.x shl 16) + offsx;
     po3^.y:= (po1^.y shl 16) + offsy;
     inc(po3);
     po3^.x:= (po2^.x shl 16) + offsx;
     po3^.y:= (po2^.y shl 16) + offsy;
     inc(po3);
     inc(po1);
     dec(po2);
    end;
    if po1 = po2 then begin
     po3^.x:= (po1^.x+origin.x) shl 16;
     po3^.y:= (po1^.y+origin.y) shl 16;
    end;
    checkxftstate(drawinfo,[xfts_colorforegroundvalid]);
    with x11gcty(gc.platformdata).d do begin
     xrendercompositetristrip(appdisp,xrenderop,xftcolorforegroundpic,
             xftdrawpic,alpharenderpictformat,0,0,buffer.buffer,points.count);
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
 funcs: array[0..17] of funcinfoty = (
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
  (n: 'XftDrawPicture'; d: {$ifndef FPC}@{$endif}@XftDrawPicture)
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
 funcs: array[0..13] of funcinfoty = (
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
                           d: {$ifndef FPC}@{$endif}@XRenderChangePicture)
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
   createcolorpicture:= @createcolorpicture2;
  end
  else begin
   createcolorpicture:= @createcolorpicture1;
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
