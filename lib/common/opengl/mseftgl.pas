{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
{
/*
 * FTGL - OpenGL font library
 *
 * Copyright (c) 2001-2004 Henry Maddocks <ftgl@opengl.geek.nz>
 * Copyright (c) 2008 Sam Hocevar <sam@zoy.org>
 * Copyright (c) 2008 Sean Morrison <learner@brlcad.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 }
unit mseftgl;
//
//under construction
//
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msectypes,msetypes,msestrings;

const
{$ifdef mswindows}
 ftgllib: array[0..0] of filenamety = ('FTGL.dll');
{$else}
 ftgllib: array[0..1] of filenamety = ('libftgl.so.2','libftgl.so');
{$endif}
 
type
 size_t = ptruint;
 FT_Error = cint;
const
 FT_ENCODING_NONE = 0;

 FT_ENCODING_MS_SYMBOL = (ord('s') shl 24) or 
                         (ord('y') shl 16) or 
                         (ord('m') shl 8) or
                          ord('b');
 FT_ENCODING_UNICODE = (ord('u') shl 24) or 
                         (ord('n') shl 16) or 
                         (ord('i') shl 8) or
                          ord('c');
 FT_ENCODING_SJIS = (ord('s') shl 24) or 
                         (ord('j') shl 16) or 
                         (ord('i') shl 8) or
                          ord('s');
 FT_ENCODING_GB2312 = (ord('g') shl 24) or 
                         (ord('b') shl 16) or 
                         (ord(' ') shl 8) or
                          ord(' ');
 FT_ENCODING_BIG5 = (ord('b') shl 24) or 
                         (ord('i') shl 16) or 
                         (ord('g') shl 8) or
                          ord('5');
 FT_ENCODING_WANSUNG = (ord('w') shl 24) or 
                         (ord('a') shl 16) or 
                         (ord('n') shl 8) or
                          ord('s');
 FT_ENCODING_JOHAB = (ord('j') shl 24) or 
                         (ord('o') shl 16) or 
                         (ord('h') shl 8) or
                          ord('a');

//    /* for backwards compatibility */
 FT_ENCODING_MS_SJIS    = FT_ENCODING_SJIS;
 FT_ENCODING_MS_GB2312  = FT_ENCODING_GB2312;
 FT_ENCODING_MS_BIG5    = FT_ENCODING_BIG5;
 FT_ENCODING_MS_WANSUNG = FT_ENCODING_WANSUNG;
 FT_ENCODING_MS_JOHAB   = FT_ENCODING_JOHAB;

 FT_ENCODING_ADOBE_STANDARD = (ord('A') shl 24) or 
                         (ord('D') shl 16) or 
                         (ord('O') shl 8) or
                          ord('B');
 FT_ENCODING_ADOBE_EXPERT = (ord('A') shl 24) or 
                         (ord('D') shl 16) or 
                         (ord('B') shl 8) or
                          ord('E');
 FT_ENCODING_ADOBE_CUSTOM = (ord('A') shl 24) or 
                         (ord('D') shl 16) or 
                         (ord('B') shl 8) or
                          ord('C');
 FT_ENCODING_ADOBE_LATIN_1 = (ord('l') shl 24) or 
                         (ord('a') shl 16) or 
                         (ord('t') shl 8) or
                          ord('1');

 FT_ENCODING_OLD_LATIN_2 = (ord('l') shl 24) or 
                         (ord('a') shl 16) or 
                         (ord('t') shl 8) or
                          ord('2');

 FT_ENCODING_APPLE_ROMAN = (ord('a') shl 24) or 
                         (ord('r') shl 16) or 
                         (ord('m') shl 8) or
                          ord('n');
  
 FTGL_RENDER_FRONT = $0001;
 FTGL_RENDER_BACK  = $0002;
 FTGL_RENDER_SIDE  = $0004;
 FTGL_RENDER_ALL   = $ffff;

 FTGL_ALIGN_LEFT = 0;
 FTGL_ALIGN_CENTER = 1;
 FTGL_ALIGN_RIGHT = 2;
 FTGL_ALIGN_JUSTIFY = 3;


{/** FTFont.h
 * FTGLfont is the public interface for the FTGL library.
 *
 * It is good practice after using these functions to test the error
 * code returned. <code>FT_Error Error()</code>. Check the freetype file
 * fterrdef.h for error definitions.
 */}
type
 FT_GlyphSlotRec = record end;   //opaque
 FT_GlyphSlot = ^FT_GlyphSlotRec;
 FTGLfont = record end;          //opaque
 pFTGLfont = ^FTGLfont;
 FTGLglyph = record end;         //opaque
 pFTGLglyph = ^FTGLglyph;
 
 makeglyphcallbackty = function(par1: FT_GlyphSlot; par2: pointer): pFTGLglyph;
                                                                        cdecl;
// boundsty = array[0..5] of cfloat;
 boundsty = packed record
  lower,left,near,upper,right,far: cfloat;
 end;

var
 
{/**
 * Create a custom FTGL font object.
 *
 * @param fontFilePath  The font file name.
 * @param data  A pointer to private data that will be passed to callbacks.
 * @param makeglyphCallback  A glyph-making callback function.
 * @return  An FTGLfont* object.
 */}
 ftglCreateCustomFont: function(fontFilePath: pchar; data: pointer;
               makeglyphCallback: makeglyphcallbackty): pFTGLfont; cdecl;
{/**
 * Create a specialised FTGLfont object for handling bitmap fonts.
 *
 */}
 ftglCreateBitmapFont: function(_file: pchar): pFTGLfont; cdecl;
{/**
 * Create a specialised FTGLfont object for handling pixmap (grey scale) fonts.
 */}
 ftglCreatePixmapFont: function(_file: pchar): pFTGLfont; cdecl;
{/**
 * Create a specialised FTGLfont object for handling vector outline fonts.
 */}
 ftglCreateOutlineFont: function(_file: pchar): pFTGLfont; cdecl;
{/**
 * Create a specialised FTGLfont object for handling tesselated polygon
 * mesh fonts.
 */}
 ftglCreatePolygonFont: function(_file: pchar): pFTGLfont; cdecl;
{/**
 * Create a specialised FTGLfont object for handling texture-mapped fonts.
 */}
 ftglCreateTextureFont: function(_file: pchar): pFTGLfont; cdecl;
{/**
 * Create a specialised FTGLfont object for handling memory buffer fonts.
 */}
 ftglCreateBufferFont: function(_file: pchar): pFTGLfont; cdecl;


{/**
 * Destroy an FTGL font object.
 *
 * @param font  An FTGLfont* object.
 */}
 ftglDestroyFont: procedure(font: pFTGLfont); cdecl;

{/**
 * Attach auxilliary file to font e.g. font metrics.
 *
 * Note: not all font formats implement this function.
 *
 * @param font  An FTGLfont* object.
 * @param path  Auxilliary font file path.
 * @return  1 if file has been attached successfully.
 */}
 ftglAttachFile: function(font: pFTGLfont; path: pchar): cint; cdecl;

{/**
 * Attach auxilliary data to font, e.g. font metrics, from memory.
 *
 * Note: not all font formats implement this function.
 *
 * @param font  An FTGLfont* object.
 * @param data  The in-memory buffer.
 * @param size  The length of the buffer in bytes.
 * @return  1 if file has been attached successfully.
 */}
 ftglAttachData: function(font: pFTGLfont; data: pbyte;
                                size: size_t): cint; cdecl;

{/**
 * Set the character map for the face.
 *
 * @param font  An FTGLfont* object.
 * @param encoding  Freetype enumerate for char map code.
 * @return  1 if charmap was valid and set correctly.
 */}
 ftglSetFontCharMap: function(font: pFTGLfont;
                                  encoding: cint): cint; cdecl;

{/**
 * Get the number of character maps in this face.
 *
 * @param font  An FTGLfont* object.
 * @return character map count.
 */}
 ftglGetFontCharMapCount: function(font: pFTGLfont): cuint; cdecl;

{/**
 * Get a list of character maps in this face.
 *
 * @param font  An FTGLfont* object.
 * @return pointer to the first encoding.
 */}
 ftglGetFontCharMapList: function(font: pFTGLfont): pcint; cdecl;

{/**
 * Set the char size for the current face.
 *
 * @param font  An FTGLfont* object.
 * @param size  The face size in points (1/72 inch).
 * @param res  The resolution of the target device, or 0 to use the default
 *             value of 72.
 * @return  1 if size was set correctly.
 */}
 ftglSetFontFaceSize: function(font: pFTGLfont; size: cuint;
                                                   res: cuint): cint; cdecl;

{/**
 * Get the current face size in points (1/72 inch).
 *
 * @param font  An FTGLfont* object.
 * @return face size
 */}
 ftglGetFontFaceSize: function(font: pFTGLfont): cuint; cdecl;

{/**
 * Set the extrusion distance for the font. Only implemented by
 * FTExtrudeFont.
 *
 * @param font  An FTGLfont* object.
 * @param depth  The extrusion distance.
 */}
 ftglSetFontDepth: procedure(font: pFTGLfont; depth: cfloat); cdecl;

{/**
 * Set the outset distance for the font. Only FTOutlineFont, FTPolygonFont
 * and FTExtrudeFont implement front outset. Only FTExtrudeFont implements
 * back outset.
 *
 * @param font  An FTGLfont* object.
 * @param front  The front outset distance.
 * @param back  The back outset distance.
 */}
 ftglSetFontOutset: procedure(font: pFTGLfont; front: cfloat;
                                                 back: cfloat); cdecl;

{/**
 * Enable or disable the use of Display Lists inside FTGL.
 *
 * @param font  An FTGLfont* object.
 * @param useList  1 turns ON display lists.
 *                 0 turns OFF display lists.
 */}
 ftglSetFontDisplayList: procedure(font: pFTGLfont; useList: cint); cdecl;

{/**
 * Get the global ascender height for the face.
 *
 * @param font  An FTGLfont* object.
 * @return  Ascender height
 */}
 ftglGetFontAscender: function(font: pFTGLfont): cfloat; cdecl;

{/**
 * Gets the global descender height for the face.
 *
 * @param font  An FTGLfont* object.
 * @return  Descender height
 */}
 ftglGetFontDescender: function(font: pFTGLfont): cfloat; cdecl;

{/**
 * Gets the line spacing for the font.
 *
 * @param font  An FTGLfont* object.
 * @return  Line height
 */}
 ftglGetFontLineHeight: function(font: pFTGLfont): cfloat; cdecl;

{/**
 * Get the bounding box for a string.
 *
 * @param font  An FTGLfont* object.
 * @param string  A char buffer
 * @param len  The length of the string. If < 0 then all characters will be
 *             checked until a null character is encountered (optional).
 * @param bounds  An array of 6 float values where the bounding box's lower
 *                left near and upper right far 3D coordinates will be stored.
 */}
 ftglGetFontBBox: procedure(font: pFTGLfont; _string: pchar;
                           len: cint; out bounds: boundsty); cdecl;

{/**
 * Get the advance width for a string.
 *
 * @param font  An FTGLfont* object.
 * @param string  A char string.
 * @return  Advance width
 */}
 ftglGetFontAdvance: function(font: pFTGLfont; _string: pchar): cfloat; cdecl;

{/**
 * Render a string of characters.
 *
 * @param font  An FTGLfont* object.
 * @param string  Char string to be output.
 * @param mode  Render mode to display.
 */}
 ftglRenderFont: procedure(font: pFTGLfont; _string: pchar; mode: cint); cdecl;

{/**
 * Query a font for errors.
 *
 * @param font  An FTGLfont* object.
 * @return  The current error code.
 */}
 ftglGetFontError: function(font: pFTGLfont): FT_Error; cdecl;

procedure initializeftgl(const sonames: array of filenamety);
procedure releaseftgl;

implementation
uses
 msedynload,msesys,sysutils;
var
 libinfo: dynlibinfoty;

procedure releaseftgl;
begin
 releasedynlib(libinfo);
end;

procedure initializeftgl(const sonames: array of filenamety);
const 
 funcs: array[0..24] of funcinfoty = (
  (n: 'ftglCreateCustomFont'; d: @ftglCreateCustomFont),
  (n: 'ftglCreateBitmapFont'; d: @ftglCreateBitmapFont),
  (n: 'ftglCreatePixmapFont'; d: @ftglCreatePixmapFont),
  (n: 'ftglCreateOutlineFont'; d: @ftglCreateOutlineFont),
  (n: 'ftglCreatePolygonFont'; d: @ftglCreatePolygonFont),
  (n: 'ftglCreateTextureFont'; d: @ftglCreateTextureFont),
  (n: 'ftglCreateBufferFont'; d: @ftglCreateBufferFont),
  (n: 'ftglDestroyFont'; d: @ftglDestroyFont),
  (n: 'ftglAttachFile'; d: @ftglAttachFile),
  (n: 'ftglAttachData'; d: @ftglAttachData),
  (n: 'ftglSetFontCharMap'; d: @ftglSetFontCharMap),
  (n: 'ftglGetFontCharMapCount'; d: @ftglGetFontCharMapCount),
  (n: 'ftglGetFontCharMapList'; d: @ftglGetFontCharMapList),
  (n: 'ftglSetFontFaceSize'; d: @ftglSetFontFaceSize),
  (n: 'ftglGetFontFaceSize'; d: @ftglGetFontFaceSize),
  (n: 'ftglSetFontDepth'; d: @ftglSetFontDepth),
  (n: 'ftglSetFontOutset'; d: @ftglSetFontOutset),
  (n: 'ftglSetFontDisplayList'; d: @ftglSetFontDisplayList),
  (n: 'ftglGetFontAscender'; d: @ftglGetFontAscender),
  (n: 'ftglGetFontDescender'; d: @ftglGetFontDescender),
  (n: 'ftglGetFontLineHeight'; d: @ftglGetFontLineHeight),
  (n: 'ftglGetFontBBox'; d: @ftglGetFontBBox),
  (n: 'ftglGetFontAdvance'; d: @ftglGetFontAdvance),
  (n: 'ftglRenderFont'; d: @ftglRenderFont),
  (n: 'ftglGetFontError'; d: @ftglGetFontError)
 );
 errormessage = 'Can not load FTGL library. ';
 
begin
 initializedynlib(libinfo,sonames,ftgllib,funcs,[],errormessage);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
