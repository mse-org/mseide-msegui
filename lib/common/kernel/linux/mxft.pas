unit mxft;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mxlib,mselibc,msectypes,msefontconfig;

{
  Automatically converted by H2Pas 0.99.16 from Xft.h
  The following command line parameters were used:
    -D
    -l
    xft
    -o
    xft.pas
    -T
    -u
    xft
    Xft.h
}

{$IFDEF FPC}
 {$PACKRECORDS C}
{$ELSE}
 {$ALIGN 4}
 {$MINENUMSIZE 4}
{$ENDIF}

type           //from fontconfig.h, XftCompat.h
 XftType = (
    XftTypeVoid,
    XftTypeInteger,
    XftTypeDouble,
    XftTypeString,
    XftTypeBool,
    XftTypeMatrix,
    XftTypeCharSet,
    XftTypeFTFace,
    XftTypeLangSet
 );

const
 {$ifdef darwin}
 External_library='libXft.dylib';
 {$else}
 External_library='libXft.so';
 {$endif}  
         
//      fclib = 'libfontconfig.so';
    Type

       TFT_FaceRec =  record //from freetype.h
        //dummy
       end;
       TFT_Face = ^TFT_FaceRec;

       TFT_UInt = longword;       //from fttypes.h


//    PDisplay  = ^Display;
    PFT_UInt  = ^TFT_UInt;
    Plongint  = ^longint;
//    PVisual  = ^Visual;

  {
   * $XFree86: xc/lib/Xft/Xft.h,v 1.32 2003/02/25 21:57:53 dawes Exp $
   *
   * Copyright ? 2000 Keith Packard, member of The XFree86 Project, Inc.
   *
   * Permission to use, copy, modify, distribute, and sell this software and its
   * documentation for any purpose is hereby granted without fee, provided that
   * the above copyright notice appear in all copies and that both that
   * copyright notice and this permission notice appear in supporting
   * documentation, and that the name of Keith Packard not be used in
   * advertising or publicity pertaining to distribution of the software without
   * specific, written prior permission.  Keith Packard makes no
   * representations about the suitability of this software for any purpose.  It
   * is provided "as is" without express or implied warranty.
   *
   * KEITH PACKARD DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
   * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
   * EVENT SHALL KEITH PACKARD BE LIABLE FOR ANY SPECIAL, INDIRECT OR
   * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
   * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
   * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
   * PERFORMANCE OF THIS SOFTWARE.
    }
  const
     XFT_MAJOR = 2;
     XFT_MINOR = 1;
     XFT_REVISION = 0;
     XftVersion = ((XFT_MAJOR * 10000) + (XFT_MINOR * 100) + (XFT_REVISION));

    const
       XFT_CORE = 'core';
       XFT_RENDER = 'render';
       XFT_XLFD = 'xlfd';
       XFT_MAX_GLYPH_MEMORY = 'maxglyphmemory';
       XFT_MAX_UNREF_FONTS = 'maxunreffonts';
{
      var
         _XftFTlibrary : TFT_Library;cvar;external;
}
    type

    TXftDraw =  record
     //dummy
    end;
    PXftDraw  = ^TXftDraw;

       TXftFont =  record
            ascent : longint;
            descent : longint;
            height : longint;
            max_advance_width : longint;
            charset : ^TFcCharSet;
            pattern : ^TFcPattern;
         end;
    PXftFont  = ^TXftFont;

    TXftFontinfo =  record
     //dummy
    end;
    PXftFontInfo  = ^TXftFontInfo;

       TXftColor =  record
            pixel : culong;
            color : TXRenderColor;
         end;
    PXftColor  = ^TXftColor;

       TXftCharSpec =  record
            ucs4 : TFcChar32;
            x : smallint;
            y : smallint;
         end;
       PXftCharSpec = ^TXftCharSpec;

       TXftCharFontSpec =  record
            font : ^TXftFont;
            ucs4 : TFcChar32;
            x : smallint;
            y : smallint;
         end;
       PXftCharFontSpec = ^TXftCharFontSpec;

       TXftGlyphSpec =  record
            glyph : TFT_UInt;
            x : smallint;
            y : smallint;
         end;
       PXftGlyphSpec = ^TXftGlyphSpec;

       TXftGlyphFontSpec =  record
            font : ^TXftFont;
            glyph : TFT_UInt;
            x : smallint;
            y : smallint;
         end;
       PXftGlyphFontSpec = ^TXftGlyphFontSpec;


{$ifdef staticxft}
    { fccharset.c  }
   function FcCharSetCreate: PFcCharSet;cdecl;
             external fclib name 'FcCharSetCreate';
   procedure FcCharSetDestroy(fcs:PFcCharSet);cdecl;
             external fclib name 'FcCharSetDestroy';
   function FcCharSetAddChar(fcs:PFcCharSet; ucs4:TFcChar32):TFcBool;cdecl;
             external fclib name 'FcCharSetAddChar';
   function FcCharSetHasChar(fcs:PFcCharSet; ucs4:TFcChar32):TFcBool;cdecl;
             external External_library name 'FcCharSetHasChar';
    { fcpat.c }
   function FcPatternCreate: PFcPattern;cdecl;
             external fclib name 'FcPatternCreate';
   function FcPatternDuplicate(p:PFcPattern): PFcPattern;cdecl;
             external fclib name 'FcPatternDuplicate';
   function FcPatternAdd(p:PFcPattern; aobject:Pchar; value:TFcValue;
                           append:TFcBool):TFcBool;cdecl;
            external fclib name 'FcPatternAdd';
   procedure FcPatternDestroy(p: PFcPattern);cdecl;
            external fclib name 'FcPatternDestroy';
   function FcPatternGetCharSet(p:PFcPattern; aobject:Pchar; n:longint;
               c:PPFcCharSet):TFcResult;cdecl;
            external fclib name 'FcPatternGetCharSet';
   function FcPatternAddInteger(p:PFcPattern; aobject:Pchar; i:longint):TFcBool;
            cdecl;external fclib name 'FcPatternAddInteger';
   function FcPatternAddDouble(p:PFcPattern; aobject:Pchar; d:Tdouble):TFcBool;
            cdecl;external fclib name 'FcPatternAddDouble';
   function FcPatternAddString(p:PFcPattern; aobject:Pchar; s: pansichar):TFcBool;
            cdecl;external fclib name 'FcPatternAddString';
   function FcPatternAddMatrix(p:PFcPattern; aobject:Pchar; s:PFcMatrix):TFcBool;
            cdecl;external fclib name 'FcPatternAddMatrix';
   function FcPatternAddCharSet(p:PFcPattern;
                       aobject:Pchar; c:PFcCharSet):TFcBool;cdecl;
            external fclib name 'FcPatternAddCharSet';
   function FcPatternAddBool(p:PFcPattern; aobject:Pchar; b:TFcBool):TFcBool;
            cdecl;external fclib name 'FcPatternAddBool';
   function FcPatternAddLangSet(p:PFcPattern; aobject:Pchar;
                         ls:PFcLangSet):TFcBool;cdecl;
            external fclib name 'FcPatternAddLangSet';
    { fclist.c }
   function FcObjectSetCreate: PFcObjectSet;cdecl;
                   external fclib name 'FcObjectSetCreate';
   function FcObjectSetAdd(os: PFcObjectSet; aobject:Pchar):TFcBool;cdecl;
                   external fclib name 'FcObjectSetAdd';
   procedure FcObjectSetDestroy(os: PFcObjectSet);cdecl;
                   external fclib name 'FcObjectSetDestroy';
   function FcFontList(config: PFcConfig; p:PFcPattern;
             os:PFcObjectSet): PFcFontSet;cdecl;
                   external fclib name 'FcFontList';
    { fcmatch.c }
   function FcFontSort(config:PFcConfig; p:PFcPattern; trim:TFcBool;
            csp:PPFcCharSet; result:PFcResult): PFcFontSet;cdecl;
                   external fclib name 'FcFontSort';
   function FcFontRenderPrepare(config:PFcConfig; pat:PFcPattern;
                    font:PFcPattern): PFcPattern;cdecl;
                   external fclib name 'FcFontRenderPrepare';
    { fcfs.c }
   procedure FcFontSetDestroy(s:PFcFontSet);cdecl;
                    external fclib name 'FcFontSetDestroy';

    { fccfg.c }
   function FcConfigSubstitute(config:PFcConfig; p:PFcPattern;
                   kind:TFcMatchKind):TFcBool;cdecl;
                   external fclib name 'FcConfigSubstitute';
    { fcdefault.c  }
   procedure FcDefaultSubstitute(pattern:PFcPattern);cdecl;
                   external fclib name 'FcDefaultSubstitute';
    { fcmatrix-c }
   procedure FcMatrixRotate(m:PFcMatrix; c:Tdouble; s:Tdouble);cdecl;
                   external fclib name 'FcMatrixRotate';

   procedure FcMatrixScale(m:PFcMatrix; sx:Tdouble; sy:Tdouble);cdecl;
                   external fclib name 'FcMatrixScale';
    { xftcolor.c  }

   function XftColorAllocName (dpy: PDisplay; visual: PVisual; cmap: TColormap;
              name: PChar; result: PXftColor): TFcBool;
                            cdecl;external External_library name 'XftColorAllocName';

    function XftColorAllocValue(dpy:PDisplay; visual:PVisual; cmap:TColormap;
             color:PXRenderColor; result:PXftColor):TFcBool;
                         cdecl;external External_library name 'XftColorAllocValue';

    procedure XftColorFree(dpy:PDisplay; visual:PVisual; cmap:TColormap; color:PXftColor);cdecl;external External_library name 'XftColorFree';

    { xftcore.c  }
    { xftdir.c  }
    function XftDirScan(aset:PFcFontSet; dir:Pchar; force:TFcBool):TFcBool;cdecl;external External_library name 'XftDirScan';

    function XftDirSave(aset:PFcFontSet; dir:Pchar):TFcBool;cdecl;external External_library name 'XftDirSave';

    { xftdpy.c  }
    function XftDefaultHasRender(dpy:PDisplay):TFcBool;cdecl;external External_library name 'XftDefaultHasRender';

    function XftDefaultSet(dpy:PDisplay; defaults:PFcPattern):TFcBool;cdecl;external External_library name 'XftDefaultSet';

    procedure XftDefaultSubstitute(dpy:PDisplay; screen:longint; pattern:PFcPattern);cdecl;external External_library name 'XftDefaultSubstitute';

    { xftdraw.c  }
    function XftDrawCreate(dpy:PDisplay; drawable:TDrawable; visual:PVisual; colormap:TColormap): PXftDraw;cdecl;external External_library name 'XftDrawCreate';

    function XftDrawCreateBitmap(dpy:PDisplay; bitmap:TPixmap): PXftDraw;cdecl;external External_library name 'XftDrawCreateBitmap';

    function XftDrawCreateAlpha(dpy:PDisplay; pixmap:TPixmap; depth:longint): PXftDraw;cdecl;external External_library name 'XftDrawCreateAlpha';

    procedure XftDrawChange(draw:PXftDraw; drawable:TDrawable);cdecl;external External_library name 'XftDrawChange';

    function XftDrawDisplay(draw:PXftDraw): PDisplay;cdecl;external External_library name 'XftDrawDisplay';

    function XftDrawDrawable(draw:PXftDraw):TDrawable;cdecl;external External_library name 'XftDrawDrawable';

    function XftDrawColormap(draw:PXftDraw):TColormap;cdecl;external External_library name 'XftDrawColormap';

    function XftDrawVisual(draw:PXftDraw): PVisual;cdecl;external External_library name 'XftDrawVisual';

    procedure XftDrawDestroy(draw:PXftDraw);cdecl;external External_library name 'XftDrawDestroy';

    function XftDrawPicture(draw:PXftDraw):TPicture;cdecl;external External_library name 'XftDrawPicture';

    function XftDrawSrcPicture(draw:PXftDraw; color:PXftColor):TPicture;cdecl;external External_library name 'XftDrawSrcPicture';

    procedure XftDrawGlyphs(draw:PXftDraw; color:PXftColor; pub:PXftFont; x:longint; y:longint;
                glyphs:PFT_UInt; nglyphs:longint);cdecl;external External_library name 'XftDrawGlyphs';

    procedure XftDrawString8(draw:PXftDraw; color:PXftColor; pub:PXftFont; x:longint; y:longint;
                _string:PFcChar8; len:longint);cdecl;external External_library name 'XftDrawString8';

    procedure XftDrawString16(draw:PXftDraw; color:PXftColor; pub:PXftFont; x:longint; y:longint;
                _string:pwidechar; len:longint);cdecl;external External_library name 'XftDrawString16';

    procedure XftDrawString32(draw:PXftDraw; color:PXftColor; pub:PXftFont; x:longint; y:longint;
                _string:PFcChar32; len:longint);cdecl;external External_library name 'XftDrawString32';

    procedure XftDrawStringUtf8(draw:PXftDraw; color:PXftColor; pub:PXftFont; x:longint; y:longint;
                _string:PFcChar8; len:longint);cdecl;external External_library name 'XftDrawStringUtf8';

    procedure XftDrawStringUtf16(draw:PXftDraw; color:PXftColor; pub:PXftFont; x:longint; y:longint;
                _string:PFcChar8; endian:TFcEndian; len:longint);cdecl;external External_library name 'XftDrawStringUtf16';

    procedure XftDrawCharSpec(draw:PXftDraw; color:PXftColor; pub:PXftFont; chars:PXftCharSpec; len:longint);cdecl;external External_library name 'XftDrawCharSpec';

    procedure XftDrawCharFontSpec(draw:PXftDraw; color:PXftColor; chars:PXftCharFontSpec; len:longint);cdecl;external External_library name 'XftDrawCharFontSpec';

    procedure XftDrawGlyphSpec(draw:PXftDraw; color:PXftColor; pub:PXftFont; glyphs:PXftGlyphSpec; len:longint);cdecl;external External_library name 'XftDrawGlyphSpec';

    procedure XftDrawGlyphFontSpec(draw:PXftDraw; color:PXftColor; glyphs:PXftGlyphFontSpec; len:longint);cdecl;external External_library name 'XftDrawGlyphFontSpec';

    procedure XftDrawRect(draw:PXftDraw; color:PXftColor; x:longint; y:longint; width:dword;
                height:dword);cdecl;external External_library name 'XftDrawRect';

    function XftDrawSetClip(draw:PXftDraw; r:TRegion):TFcBool;cdecl;external External_library name 'XftDrawSetClip';

    function XftDrawSetClipRectangles(draw:PXftDraw; xOrigin:longint; yOrigin:longint; rects:PXRectangle; n:longint):TFcBool;cdecl;external External_library name 'XftDrawSetClipRectangles';

    procedure XftDrawSetSubwindowMode(draw:PXftDraw; mode:longint);cdecl;external External_library name 'XftDrawSetSubwindowMode';

    { xftextent.c  }
    procedure XftGlyphExtents(dpy:PDisplay; pub:PXftFont; glyphs:PFT_UInt; nglyphs:longint; extents:PXGlyphInfo);cdecl;external External_library name 'XftGlyphExtents';

    procedure XftTextExtents8(dpy:PDisplay; pub:PXftFont; _string:PFcChar8; len:longint; extents:PXGlyphInfo);cdecl;external External_library name 'XftTextExtents8';

    procedure XftTextExtents16(dpy:PDisplay; pub:PXftFont; _string: pwidechar{PFcChar16}; len:longint; extents:PXGlyphInfo);cdecl;external External_library name 'XftTextExtents16';

    procedure XftTextExtents32(dpy:PDisplay; pub:PXftFont; _string:PFcChar32; len:longint; extents:PXGlyphInfo);cdecl;external External_library name 'XftTextExtents32';

    procedure XftTextExtentsUtf8(dpy:PDisplay; pub:PXftFont; _string:PFcChar8; len:longint; extents:PXGlyphInfo);cdecl;external External_library name 'XftTextExtentsUtf8';

    procedure XftTextExtentsUtf16(dpy:PDisplay; pub:PXftFont; _string:PFcChar8; endian:TFcEndian; len:longint;
                extents:PXGlyphInfo);cdecl;external External_library name 'XftTextExtentsUtf16';

    { xftfont.c  }
    function XftFontMatch(dpy:PDisplay; screen:longint; pattern:PFcPattern; result:PFcResult): PFcPattern;cdecl;external External_library name 'XftFontMatch';

    function XftFontOpen(dpy:PDisplay; screen:longint; args: array of const):PXftFont;cdecl;external External_library name 'XftFontOpen';

    function XftFontOpenName(dpy:PDisplay; screen:longint; name:Pchar):PXftFont;cdecl;external External_library name 'XftFontOpenName';

    function XftFontOpenXlfd(dpy:PDisplay; screen:longint; xlfd:Pchar):PXftFont;cdecl;external External_library name 'XftFontOpenXlfd';

    function XftLockFace(pub:PXftFont):TFT_Face;cdecl;external External_library name 'XftLockFace';

    procedure XftUnlockFace(pub:PXftFont);cdecl;external External_library name 'XftUnlockFace';

    function XftFontInfoCreate(dpy:PDisplay; pattern:PFcPattern):PXftFontInfo;cdecl;external External_library name 'XftFontInfoCreate';

    procedure XftFontInfoDestroy(dpy:PDisplay; fi:PXftFontInfo);cdecl;external External_library name 'XftFontInfoDestroy';

    function XftFontInfoHash(fi:PXftFontInfo):TFcChar32;cdecl;external External_library name 'XftFontInfoHash';

    function XftFontInfoEqual(a:PXftFontInfo; b:PXftFontInfo):TFcBool;cdecl;external External_library name 'XftFontInfoEqual';

    function XftFontOpenInfo(dpy:PDisplay; pattern:PFcPattern; fi:PXftFontInfo): PXftFont;cdecl;external External_library name 'XftFontOpenInfo';

    function XftFontOpenPattern(dpy:PDisplay; pattern:PFcPattern):PXftFont;cdecl;external External_library name 'XftFontOpenPattern';

    function XftFontCopy(dpy:PDisplay; pub:PXftFont):PXftFont;cdecl;external External_library name 'XftFontCopy';

    procedure XftFontClose(dpy:PDisplay; pub:PXftFont);cdecl;external External_library name 'XftFontClose';

    function XftInitFtLibrary:TFcBool;cdecl;external External_library name 'XftInitFtLibrary';

    { xftglyphs.c  }
    procedure XftFontLoadGlyphs(dpy:PDisplay; pub:PXftFont; need_bitmaps:TFcBool; glyphs:PFT_UInt; nglyph:longint);cdecl;external External_library name 'XftFontLoadGlyphs';

    procedure XftFontUnloadGlyphs(dpy:PDisplay; pub:PXftFont; glyphs:PFT_UInt; nglyph:longint);cdecl;external External_library name 'XftFontUnloadGlyphs';


    const
       XFT_NMISSING = 256;

    function XftFontCheckGlyph(dpy:PDisplay; pub:PXftFont; need_bitmaps:TFcBool; glyph:TFT_UInt; missing:PFT_UInt;
               nmissing:Plongint):TFcBool;cdecl;external External_library name 'XftFontCheckGlyph';

    function XftCharExists(dpy:PDisplay; pub:PXftFont; ucs4:TFcChar32):TFcBool;cdecl;external External_library name 'XftCharExists';

    function XftCharIndex(dpy:PDisplay; pub:PXftFont; ucs4:TFcChar32):TFT_UInt;cdecl;external External_library name 'XftCharIndex';

    { xftgram.y  }
    { xftinit.c  }
    function XftInit(config:Pchar):TFcBool;cdecl;external External_library name 'XftInit';

    function XftGetVersion:longint;cdecl;external External_library name 'XftGetVersion';

    { xftlex.l  }
    { xftlist.c  }

    function XftListFonts(dpy:PDisplay; screen:longint;
              args:array of const):PFcFontSet;cdecl;external External_library name 'XftListFonts';

    { xftmatch.c  }
    { xftmatrix.c  }
    { xftname.c  }
    function XftNameParse(name:Pchar): PFcPattern;cdecl;external External_library name 'XftNameParse';

    { xftpat.c  }

    { xftrender.c  }
    procedure XftGlyphRender(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; glyphs:PFT_UInt;
                nglyphs:longint);cdecl;external External_library name 'XftGlyphRender';

    procedure XftGlyphSpecRender(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; glyphs:PXftGlyphSpec; nglyphs:longint);cdecl;external External_library name 'XftGlyphSpecRender';

    procedure XftCharSpecRender(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; chars:PXftCharSpec; len:longint);cdecl;external External_library name 'XftCharSpecRender';

    procedure XftGlyphFontSpecRender(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; srcx:longint;
                srcy:longint; glyphs:PXftGlyphFontSpec; nglyphs:longint);cdecl;external External_library name 'XftGlyphFontSpecRender';

    procedure XftCharFontSpecRender(dpy:PDisplay; op:longint; src:TPicture; dst:TPicture; srcx:longint;
                srcy:longint; chars:PXftCharFontSpec; len:longint);cdecl;external External_library name 'XftCharFontSpecRender';

    procedure XftTextRender8(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                len:longint);cdecl;external External_library name 'XftTextRender8';

    procedure XftTextRender16(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar16;
                len:longint);cdecl;external External_library name 'XftTextRender16';

    procedure XftTextRender16BE(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                len:longint);cdecl;external External_library name 'XftTextRender16BE';

    procedure XftTextRender16LE(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                len:longint);cdecl;external External_library name 'XftTextRender16LE';

    procedure XftTextRender32(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar32;
                len:longint);cdecl;external External_library name 'XftTextRender32';

    procedure XftTextRender32BE(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                len:longint);cdecl;external External_library name 'XftTextRender32BE';

    procedure XftTextRender32LE(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                len:longint);cdecl;external External_library name 'XftTextRender32LE';

    procedure XftTextRenderUtf8(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                len:longint);cdecl;external External_library name 'XftTextRenderUtf8';

    procedure XftTextRenderUtf16(dpy:PDisplay; op:longint; src:TPicture; pub:PXftFont; dst:TPicture;
                srcx:longint; srcy:longint; x:longint; y:longint; _string:PFcChar8;
                endian:TFcEndian; len:longint);cdecl;external External_library name 'XftTextRenderUtf16';

    { xftstr.c  }
    { xftxlfd.c  }
    function XftXlfdParse(xlfd_orig:Pchar; ignore_scalable:TFcBool; complete:TFcBool):PFcPattern;cdecl;external External_library name 'XftXlfdParse';

{$endif staticxft}

implementation


end.
