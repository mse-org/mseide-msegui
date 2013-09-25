unit mxrender;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 {$ifdef FPC} x,{$endif}Xlib,mselibc,msectypes;

  const
    External_library='libXrender.so';

{$IFDEF FPC}
 {$PACKRECORDS C}
{$ELSE}
 {$ALIGN 4}
 {$MINENUMSIZE 4}
{$ENDIF}


  {
   * $XFree86: xc/lib/Xrender/Xrender.h,v 1.18 2002/11/23 02:34:45 keithp Exp $
   *
   * Copyright ? 2000 SuSE, Inc.
   *
   * Permission to use, copy, modify, distribute, and sell this software and its
   * documentation for any purpose is hereby granted without fee, provided that
   * the above copyright notice appear in all copies and that both that
   * copyright notice and this permission notice appear in supporting
   * documentation, and that the name of SuSE not be used in advertising or
   * publicity pertaining to distribution of the software without specific,
   * written prior permission.  SuSE makes no representations about the
   * suitability of this software for any purpose.  It is provided "as is"
   * without express or implied warranty.
   *
   * SuSE DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
   * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL SuSE
   * BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
   * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
   * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
   *
   * Author:  Keith Packard, SuSE, Inc.
    }
                                       
  type

{$ifndef FPC}
 txid = xid;
{$endif}  
     TBool = integer;
     dword = longword;
     Pdword = ^dword;
     Tdouble = double;
     TXFixed = integer;
     PXFixed = ^TXFixed;
     TGlyph = txid;
     PGlyph = ^TGlyph;
     TGlyphSet = txid;
     PGlyphSet = ^TGlyphSet;
     TPicture = txid;
     PPicture = ^TPicture;
     TPictFormat = txid;
     PPictFormat = ^TPictFormat;
     {$ifdef FPC}
     TRegion = pointer;
     {$else}
     TRegion = Region;
     {$endif}
     PRegion = ^TRegion;

  const                //from render.h
     BadPictFormat = 0;
     BadPicture = 1;
     BadPictOp = 2;
     BadGlyphSet = 3;
     BadGlyph = 4;
     RenderNumberErrors = BadGlyph + 1;
     PictTypeIndexed = 0;
     PictTypeDirect = 1;     
     PictOpMinimum = 0;     
     PictOpClear = 0;     
     PictOpSrc = 1;     
     PictOpDst = 2;     
     PictOpOver = 3;     
     PictOpOverReverse = 4;     
     PictOpIn = 5;     
     PictOpInReverse = 6;     
     PictOpOut = 7;
     PictOpOutReverse = 8;
     PictOpAtop = 9;     
     PictOpAtopReverse = 10;     
     PictOpXor = 11;     
     PictOpAdd = 12;     
     PictOpSaturate = 13;     
     PictOpMaximum = 13;     
  {
   * Operators only available in version 0.2
    }
     PictOpDisjointMinimum = $10;     
     PictOpDisjointClear = $10;     
     PictOpDisjointSrc = $11;
     PictOpDisjointDst = $12;     
     PictOpDisjointOver = $13;     
     PictOpDisjointOverReverse = $14;     
     PictOpDisjointIn = $15;     
     PictOpDisjointInReverse = $16;     
     PictOpDisjointOut = $17;
     PictOpDisjointOutReverse = $18;     
     PictOpDisjointAtop = $19;     
     PictOpDisjointAtopReverse = $1a;     
     PictOpDisjointXor = $1b;     
     PictOpDisjointMaximum = $1b;     
     PictOpConjointMinimum = $20;
     PictOpConjointClear = $20;     
     PictOpConjointSrc = $21;     
     PictOpConjointDst = $22;     
     PictOpConjointOver = $23;     
     PictOpConjointOverReverse = $24;     
     PictOpConjointIn = $25;     
     PictOpConjointInReverse = $26;     
     PictOpConjointOut = $27;     
     PictOpConjointOutReverse = $28;     
     PictOpConjointAtop = $29;     
     PictOpConjointAtopReverse = $2a;     
     PictOpConjointXor = $2b;     
     PictOpConjointMaximum = $2b;     
     PolyEdgeSharp = 0;     
     PolyEdgeSmooth = 1;     
     PolyModePrecise = 0;     
     PolyModeImprecise = 1;
     CPRepeat = 1 shl 0;     
     CPAlphaMap = 1 shl 1;     
     CPAlphaXOrigin = 1 shl 2;     
     CPAlphaYOrigin = 1 shl 3;     
     CPClipXOrigin = 1 shl 4;     
     CPClipYOrigin = 1 shl 5;
     CPClipMask = 1 shl 6;
     CPGraphicsExposure = 1 shl 7;     
     CPSubwindowMode = 1 shl 8;     
     CPPolyEdge = 1 shl 9;     
     CPPolyMode = 1 shl 10;     
     CPDither = 1 shl 11;     
     CPComponentAlpha = 1 shl 12;     
     CPLastBit = 11;     
  { Filters included in 0.6  }
     FilterNearest = 'nearest';     
     FilterBilinear = 'bilinear';
     FilterFast = 'fast';
     FilterGood = 'good';
     FilterBest = 'best';
     FilterAliasNone = -(1);
  { Subpixel orders included in 0.6  }
     SubPixelUnknown = 0;
     SubPixelHorizontalRGB = 1;
     SubPixelHorizontalBGR = 2;
     SubPixelVerticalRGB = 3;
     SubPixelVerticalBGR = 4;
     SubPixelNone = 5;

type
     TXRenderDirectFormat =  record
          red : smallint;
          redMask : smallint;
          green : smallint;
          greenMask : smallint;
          blue : smallint;
          blueMask : smallint;
          alpha : smallint;
          alphaMask : smallint;
       end;
      PXRenderDirectFormat = ^TXRenderDirectFormat;

     TXRenderPictFormat =  record
          id : TPictFormat;
          _type : longint;
          depth : longint;
          direct : TXRenderDirectFormat;
          colormap : TColormap;
       end;
     PXRenderPictFormat = ^TXRenderPictFormat;

  const
     PictFormatID = 1 shl 0;
     PictFormatType = 1 shl 1;
     PictFormatDepth = 1 shl 2;
     PictFormatRed = 1 shl 3;
     PictFormatRedMask = 1 shl 4;
     PictFormatGreen = 1 shl 5;
     PictFormatGreenMask = 1 shl 6;
     PictFormatBlue = 1 shl 7;
     PictFormatBlueMask = 1 shl 8;
     PictFormatAlpha = 1 shl 9;
     PictFormatAlphaMask = 1 shl 10;
     PictFormatColormap = 1 shl 11;
     RepeatNone = 0;
     RepeatNormal = 1;
     RepeatPad = 2;
     RepeatReflect = 2;

  type

     TXRenderPictureAttributes =  record
          _repeat : TBool;
          alpha_map : TPicture;
          alpha_x_origin : longint;
          alpha_y_origin : longint;
          clip_x_origin : longint;
          clip_y_origin : longint;
          clip_mask : TPixmap;
          graphics_exposures : TBool;
          subwindow_mode : longint;
          poly_edge : longint;
          poly_mode : longint;
          dither : TAtom;
          component_alpha : TBool;
       end;
     PXRenderPictureAttributes = ^TXRenderPictureAttributes;

     TXRenderColor = record
          red : word;
          green : word;
          blue : word;
          alpha : word;
       end;
       PXRenderColor = ^TXRenderColor;

     TXGlyphInfo =  record
          width : word;
          height : word;
          x : smallint;
          y : smallint;
          xOff : smallint;
          yOff : smallint;
       end;
  PXGlyphInfo = ^TXGlyphInfo;

     TXGlyphElt8 =  record
          glyphset : TGlyphSet;
          chars : ^char;
          nchars : longint;
          xOff : longint;
          yOff : longint;
       end;
     PXGlyphElt8 = ^TXGlyphElt8;

     TXGlyphElt16 =  record
          glyphset : TGlyphSet;
          chars : ^word;
          nchars : longint;
          xOff : longint;
          yOff : longint;
       end;
     PXGlyphElt16 = TXGlyphElt16;

     TXGlyphElt32 =  record
          glyphset : TGlyphSet;
          chars : ^dword;
          nchars : longint;
          xOff : longint;
          yOff : longint;
       end;
     PXGlyphElt32 = ^TXGlyphElt32;

     TXDouble = Tdouble;

     TXPointDouble =  record
          x : TXDouble;
          y : TXDouble;
       end;
     PXPointDouble = ^TXPointDouble;

     TXPointFixed =  record
          x : TXFixed;
          y : TXFixed;
       end;
     PXPointFixed = ^TXPointFixed;

     TXLineFixed =  record
          p1 : TXPointFixed;
          p2 : TXPointFixed;
       end;
     PXLineFixed = ^TXLineFixed;

     TXTriangle =  record
          p1 : TXPointFixed;
          p2 : TXPointFixed;
          p3 : TXPointFixed;
       end;
     PXTriangle = ^TXTriangle;

     TXTrapezoid =  record
          top : TXFixed;
          bottom : TXFixed;
          left : TXLineFixed;
          right : TXLineFixed;
       end;
     PXTrapezoid = ^TXTrapezoid;

     TXTransform =  array[0..2]             //row
            of array[0..2] of TXFixed;      //col
        //m00,m01,0
        //m10,m11,0     x' = m00 * x + m01 * y + dx
        //dx, dy, 1     y' = m11 * y + m10 * x + dy

     PXTransform = ^TXTransform;

     TXFilters =  record
          nfilter : longint;
          filter : PPchar;
          nalias : longint;
          alias : ^smallint;
       end;
     PXFilters = ^TXFilters;

     TXIndexValue =  record
          pixel : culong;
          red : word;
          green : word;
          blue : word;
          alpha : word;
       end;
     PXIndexValue = ^TXIndexValue;

     TXAnimCursor =  record
          cursor : TCursor;
          delay : culong;
       end;
     PXAnimCursor = ^TXAnimCursor;
     
  const
     PictStandardARGB32 = 0;
     PictStandardRGB24 = 1;
     PictStandardA8 = 2;
     PictStandardA4 = 3;
     PictStandardA1 = 4;
     PictStandardNUM = 5;

{$ifdef staticxrender}

  function XRenderQueryExtension(dpy: PDisplay; event_basep: Pinteger;
                  error_basep: Pinteger): TBool;
                    cdecl;external External_library name 'XRenderQueryExtension';

  function XRenderQueryVersion(dpy:PDisplay; major_versionp:Plongint;
        minor_versionp:Plongint):TStatus;
        cdecl;external External_library name 'XRenderQueryVersion';

  function XRenderQueryFormats(dpy:PDisplay):TStatus;
        cdecl;external External_library name 'XRenderQueryFormats';

  function XRenderQuerySubpixelOrder(dpy:PDisplay; screen:longint):longint;
        cdecl;external External_library name 'XRenderQuerySubpixelOrder';

  function XRenderSetSubpixelOrder(dpy: PDisplay; screen: longint;
                    subpixel: longint): TBool; cdecl;
                    external External_library name 'XRenderSetSubpixelOrder';

  function XRenderFindVisualFormat(dpy: PDisplay;
                      visual: PVisual): PXRenderPictFormat; cdecl;
                    external External_library name 'XRenderFindVisualFormat';

  function XRenderFindFormat(dpy: PDisplay; mask: culong;
         templ: PXRenderPictFormat; count: longint): PXRenderPictFormat; cdecl;
                            external External_library name 'XRenderFindFormat';


  function XRenderFindStandardFormat(dpy:PDisplay;
              format:longint):PXRenderPictFormat;
              cdecl;external External_library name 'XRenderFindStandardFormat';

function XRenderQueryPictIndexValues(dpy:PDisplay; format:PXRenderPictFormat;
          num:Plongint):PXIndexValue;
          cdecl;external External_library name 'XRenderQueryPictIndexValues';

function XRenderCreatePicture(dpy:PDisplay; drawable:TDrawable;
      format:PXRenderPictFormat; valuemask:culong;
      attributes:PXRenderPictureAttributes):TPicture;
      cdecl;external External_library name 'XRenderCreatePicture';

procedure XRenderFreePicture(dpy:PDisplay; picture:TPicture);
                 cdecl;external External_library name 'XRenderFreePicture';

procedure XRenderChangePicture(dpy:PDisplay; picture:TPicture;
          valuemask:culong; attributes:PXRenderPictureAttributes);
          cdecl;external External_library name 'XRenderChangePicture';

procedure XRenderSetPictureClipRectangles(dpy:PDisplay; picture:TPicture;
            xOrigin:longint; yOrigin:longint; rects:PXRectangle; n:longint);
           cdecl;external External_library name 'XRenderSetPictureClipRectangles';

procedure XRenderSetPictureClipRegion(dpy:PDisplay; picture:TPicture; r:TRegion);
          cdecl;external External_library name 'XRenderSetPictureClipRegion';

procedure XRenderSetPictureTransform(dpy:PDisplay; picture:TPicture; transform:PXTransform);
          cdecl;external External_library name 'XRenderSetPictureTransform';


procedure XRenderComposite(dpy:PDisplay; op:longint; src:TPicture; mask:TPicture; dst:TPicture;
              src_x:longint; src_y:longint; mask_x:longint; mask_y:longint; dst_x:longint;
              dst_y:longint; width:dword; height:dword);cdecl;external External_library name 'XRenderComposite';

  function XRenderCreateGlyphSet(dpy:PDisplay; format:PXRenderPictFormat):TGlyphSet;cdecl;external External_library name 'XRenderCreateGlyphSet';

  function XRenderReferenceGlyphSet(dpy:PDisplay; existing:TGlyphSet):TGlyphSet;cdecl;external External_library name 'XRenderReferenceGlyphSet';

  procedure XRenderFreeGlyphSet(dpy:PDisplay; glyphset:TGlyphSet);cdecl;external External_library name 'XRenderFreeGlyphSet';

  procedure XRenderAddGlyphs(dpy:PDisplay; glyphset:TGlyphSet; gids:PGlyph; glyphs:PXGlyphInfo; nglyphs:longint;
              images:Pchar; nbyte_images:longint);cdecl;external External_library name 'XRenderAddGlyphs';

  procedure XRenderFreeGlyphs(dpy:PDisplay; glyphset:TGlyphSet; gids:PGlyph; nglyphs:longint);cdecl;external External_library name 'XRenderFreeGlyphs';

  procedure XRenderCompositeString8(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              glyphset:TGlyphSet; xSrc:longint; ySrc:longint; xDst:longint; yDst:longint;
              _string:Pchar; nchar:longint);cdecl;external External_library name 'XRenderCompositeString8';

  procedure XRenderCompositeString16(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              glyphset:TGlyphSet; xSrc:longint; ySrc:longint; xDst:longint; yDst:longint;
              _string:Pword; nchar:longint);cdecl;external External_library name 'XRenderCompositeString16';

  procedure XRenderCompositeString32(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              glyphset:TGlyphSet; xSrc:longint; ySrc:longint; xDst:longint; yDst:longint;
              _string:Pdword; nchar:longint);cdecl;external External_library name 'XRenderCompositeString32';

  procedure XRenderCompositeText8(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; xDst:longint; yDst:longint; elts:PXGlyphElt8;
              nelt:longint);cdecl;external External_library name 'XRenderCompositeText8';

  procedure XRenderCompositeText16(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; xDst:longint; yDst:longint; elts:PXGlyphElt16;
              nelt:longint);cdecl;external External_library name 'XRenderCompositeText16';

  procedure XRenderCompositeText32(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; xDst:longint; yDst:longint; elts:PXGlyphElt32;
              nelt:longint);cdecl;external External_library name 'XRenderCompositeText32';

  procedure XRenderFillRectangle(dpy:PDisplay; op:longint; dst:TPicture; color:PXRenderColor; x:longint;
              y:longint; width:dword; height:dword);cdecl;external External_library name 'XRenderFillRectangle';

  procedure XRenderFillRectangles(dpy:PDisplay; op:longint; dst:TPicture; color:PXRenderColor; rectangles:PXRectangle;
              n_rects:longint);cdecl;external External_library name 'XRenderFillRectangles';

  procedure XRenderCompositeTrapezoids(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; traps:PXTrapezoid; ntrap:longint);cdecl;external External_library name 'XRenderCompositeTrapezoids';

  procedure XRenderCompositeTriangles(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; triangles:PXTriangle; ntriangle:longint);cdecl;external External_library name 'XRenderCompositeTriangles';

  procedure XRenderCompositeTriStrip(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; points:PXPointFixed; npoint:longint);cdecl;external External_library name 'XRenderCompositeTriStrip';

  procedure XRenderCompositeTriFan(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
              xSrc:longint; ySrc:longint; points:PXPointFixed; npoint:longint);cdecl;external External_library name 'XRenderCompositeTriFan';

//  procedure XRenderCompositeDoublePoly(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; maskFormat:PXRenderPictFormat;
//              xSrc:longint; ySrc:longint; xDst:longint; yDst:longint; fpoints:PXPointDouble;
//              npoints:longint; winding:longint);cdecl;external External_library name 'XRenderCompositeDoublePoly';

  function XRenderParseColor(dpy:PDisplay; spec:Pchar; def:PXRenderColor):TStatus;cdecl;external External_library name 'XRenderParseColor';

  function XRenderCreateCursor(dpy:PDisplay; source:TPicture; x:dword; y:dword):TCursor;cdecl;external External_library name 'XRenderCreateCursor';

  function XRenderQueryFilters(dpy:PDisplay; drawable:TDrawable):PXFilters;cdecl;external External_library name 'XRenderQueryFilters';

  procedure XRenderSetPictureFilter(dpy:PDisplay; picture:TPicture; filter:Pchar; params:PXFixed; nparams:longint);cdecl;external External_library name 'XRenderSetPictureFilter';

  function XRenderCreateAnimCursor(dpy:PDisplay; ncursor:longint; cursors:PXAnimCursor):TCursor;cdecl;external External_library name 'XRenderCreateAnimCursor';
  
{$endif staticxrender}

       //macros

  function XDoubleToFixed(f : TXDouble) : TXFixed;
//#define XDoubleToFixed(f)    ((XFixed) ((f) * 65536))

  function XFixedToDouble(f : TXFixed) : TXDouble;
//#define XFixedToDouble(f)    (((XDouble) (f)) / 65536)

implementation

  function XDoubleToFixed(f : TXDouble) : TXFixed;
    begin
       XDoubleToFixed:= round(f * 65536);
    end;

  function XFixedToDouble(f : TXFixed) : TXDouble;
    begin
       XFixedToDouble:= f / 65536;
    end;


end.
