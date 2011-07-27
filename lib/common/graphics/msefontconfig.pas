{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefontconfig;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,msectypes;
 
const
 fontconfiglib: array[0..1] of filenamety = 
                                     ('libfontconfig.so.1','libfontconfig.so');
 FC_FAMILY =          'family';	//* String */
 FC_STYLE =           'style';		//* String */
 FC_SLANT =           'slant';		//* Int */
 FC_WEIGHT =	       'weight';	//* Int */
 FC_SIZE =	           'size';      //* Double */
 FC_ASPECT =	       'aspect';	//* Double */
 FC_PIXEL_SIZE =      'pixelsize';     //* Double */
 FC_SPACING =	       'spacing';	//* Int */
 FC_FOUNDRY =	       'foundry';	//* String */
 FC_ANTIALIAS =       'antialias';	//* Bool (depends) */
 FC_HINTING =	       'hinting';	//* Bool (true) */
 FC_VERTICAL_LAYOUT = 'verticallayout';//* Bool (false) */
 FC_AUTOHINT =	       'autohint';	//* Bool (false) */
 FC_GLOBAL_ADVANCE =  'globaladvance';	//* Bool (true) */
 FC_FILE =	       'file';		//* String */
 FC_INDEX =	       'index';		//* Int */
 FC_FT_FACE =	       'ftface';	//* FT_Face */
 FC_RASTERIZER =      'rasterizer';	//* String */
 FC_OUTLINE =	       'outline';	//* Bool */
 FC_SCALABLE =	       'scalable';	//* Bool */
 FC_SCALE =	       'scale';		//* double */
 FC_DPI =             'dpi';		//* double */
 FC_RGBA =            'rgba';		//* Int */
 FC_MINSPACE =	       'minspace';	//* Bool use minimum line spacing */
 FC_SOURCE =	       'source';	//* String (X11, freetype) */
 FC_CHARSET =	       'charset';	//* CharSet */
 FC_LANG =            'lang';		//* String RFC 3066 langs */
 FC_FONTVERSION =     'fontversion';	//* Int from 'head' table */

 FC_MATRIX =          'matrix';
 FC_CHAR_WIDTH =      'charwidth';
 
 FC_WEIGHT_BOLD = 200;
 FC_SLANT_ITALIC = 100;
 FC_PROPORTIONAL = 0;
 FC_MONO = 100;


type

       TFcChar8 = byte;           //from fontconfig.h
       PFcChar8 = ^TFcChar8;
       TFcChar16 = word;
       PFcChar16 = ^TFcChar16;
       TFcChar32 = dword;
       PFcChar32 = ^TFcChar32;
       TFcBool = longbool; //integer;
       PFcBool = ^TFcBool;
       TFcEndian = (FcEndianBig, FcEndianLittle);
       TFcResult = (FcResultMatch, FcResultNoMatch, FcResultTypeMismatch, FcResultNoId);
       PFcResult = ^TFcResult;

     TFcType = (FcTypeVoid,FcTypeInteger,FcTypeDouble,
         FcTypeString,FcTypeBool,FcTypeMatrix,
         FcTypeCharSet,FcTypeFTFace,FcTypeLangSet
         );
     TFcMatchKind = (FcMatchPattern,FcMatchFont);
    TFcMatrix = record
     xx: cdouble;
     xy: cdouble;
     yx: cdouble;
     yy: cdouble;
    end;
    PFcMatrix = ^TFcMatrix;

    TFcLangSet = record
     //dummy
    end;
    PFcLangSet = ^TFcLangset;

    TFcCharset =  record
     //dummy
    end;
    PFcCharset = ^TFcCharset;
    PPFcCharset = ^PFcCharset;

    TFcPattern =  record
     //dummy
    end;
    PFcPattern  = ^TFcPattern;
    PPFcPattern = ^PFcPattern;
    pfcpatternpoaty = array[0..0] of PFcPattern;

    TFcValue = record
     _type: TFcType;
     u: record
      case longint of
       0 : ( s : ^TFcChar8 );
       1 : ( i : longint );
       2 : ( b : TFcBool );
       3 : ( d : cdouble );
       4 : ( m : ^TFcMatrix );
       5 : ( c : ^TFcCharSet );
       6 : ( f : pointer );
       7 : ( p : ^TFcPattern );
       8 : ( l : ^TFcLangSet );
     end;
    end;

    TFcObjectSet = record
     nobject: longint;
     sobject: longint;
     objects: ppchar;
    end;
    PFcObjectSet = ^TFcObjectSet;

    TFcConfig = record
     //dummy
    end;
    PFcConfig = ^TFcConfig;

  TFcFontSet =  record
    nfont : integer;
    sfont : integer;
    fonts : PPFcPattern;
  end;
  PFcFontSet = ^TFcFontSet;
  
var
 FcInit: function: tfcbool;cdecl;
 FcFini: procedure;cdecl;
 FcPatternDestroy: procedure(p:PFcPattern);cdecl;
 FcFontSetDestroy: procedure(s:PFcFontSet);cdecl;
 FcObjectSetCreate: function: PFcObjectSet;cdecl;
 FcObjectSetAdd: function(os: PFcObjectSet; aobject:Pchar):TFcBool;cdecl;
 FcObjectSetDestroy: procedure(os: PFcObjectSet);cdecl;
 FcFontList: function(config: PFcConfig; p:PFcPattern; 
                      os:PFcObjectSet): PFcFontSet;cdecl;
 FcCharSetCreate: function: PFcCharSet;cdecl;
 FcCharSetDestroy: procedure(fcs:PFcCharSet);cdecl;
 FcCharSetAddChar: function(fcs:PFcCharSet; ucs4:TFcChar32):TFcBool;cdecl;
 FcPatternAdd: function(p:PFcPattern; aobject:Pchar; value:TFcValue;
                           append:TFcBool):TFcBool;cdecl;
 FcPatternCreate: function: PFcPattern;cdecl;
 FcConfigSubstitute: function(config:PFcConfig; p:PFcPattern;
                   kind:TFcMatchKind):TFcBool;cdecl;
 FcDefaultSubstitute: procedure (pattern:PFcPattern);cdecl;
 FcFontSort: function (config:PFcConfig; p:PFcPattern; trim:TFcBool;
            csp:PPFcCharSet; result:PFcResult): PFcFontSet;cdecl;
 FcCharSetHasChar: function(fcs:PFcCharSet; ucs4:TFcChar32):TFcBool;cdecl;
 FcPatternDuplicate: function (p:PFcPattern): PFcPattern;cdecl;
 FcPatternGetCharSet: function (p:PFcPattern; aobject:Pchar; n:longint;
               c:PPFcCharSet):TFcResult;cdecl;
 FcFontRenderPrepare: function(config:PFcConfig; pat:PFcPattern;
                    font:PFcPattern): PFcPattern;cdecl;
 FcFontMatch: function(config: PFcConfig; p: PFcPattern; 
                                 result: PFcResult): PFcPattern;cdecl;
 FcMatrixRotate: procedure(m:PFcMatrix; c:cdouble; s:cdouble);cdecl;
 FcMatrixScale: procedure(m:PFcMatrix; sx:cdouble; sy:cdouble);cdecl;
 FcPatternAddInteger: function(p:PFcPattern; aobject:Pchar; i:longint):TFcBool; cdecl;
 FcPatternAddDouble: function(p:PFcPattern; aobject:Pchar; d:cdouble):TFcBool; cdecl;
 FcPatternAddString: function(p:PFcPattern; aobject:Pchar; s: pansichar):TFcBool; cdecl;
 FcPatternAddMatrix: function(p:PFcPattern; aobject:Pchar; s:PFcMatrix):TFcBool; cdecl;
 FcPatternAddCharSet: function(p:PFcPattern;
                       aobject:Pchar; c:PFcCharSet):TFcBool;cdecl;
 FcPatternAddBool: function(p:PFcPattern; aobject:Pchar; b:TFcBool):TFcBool; cdecl;
 FcPatternAddLangSet: function(p:PFcPattern; aobject:Pchar; 
                         ls:PFcLangSet):TFcBool;cdecl;
 
 FcPatternGetString: function(p: PFcPattern; aobject: Pchar; n: integer; 
                                s: ppchar): tfcresult; cdecl;
 FcPatternGetInteger: function(p: PFcPattern; aobject: Pchar; n: integer; 
                                i: pinteger): tfcresult; cdecl;
 FcPatternGetDouble: function(p: PFcPattern; aobject: Pchar; n: integer; 
                                i: pcdouble): tfcresult; cdecl;
 FcNameParse: function(name: pchar): PFcPattern; cdecl;
 
procedure FcMatrixInit(var m: TFcMatrix);     

procedure initializefontconfig(const sonames: array of filenamety);
procedure releasefontconfig;

implementation

uses
 msesys,msedynload,sysutils;
var
 libinfo: dynlibinfoty;

procedure FcMatrixInit(var m: TFcMatrix);
begin
 m.xx:= 1;
 m.yy:= 1;
 m.xy:= 0;
 m.yx:= 0;
end;

procedure init;
begin
 fcinit;
end;

procedure deinit;
begin
// fcfini;
end;

procedure initializefontconfig(const sonames: array of filenamety);
const
 funcs: array[0..33] of funcinfoty = (
  (n: 'FcPatternDestroy'; d: @FcPatternDestroy),           //0
  (n: 'FcFontSetDestroy'; d: @FcFontSetDestroy),           //1
  (n: 'FcObjectSetCreate'; d: @FcObjectSetCreate),         //2
  (n: 'FcObjectSetAdd'; d: @FcObjectSetAdd),               //3
  (n: 'FcObjectSetDestroy'; d: @FcObjectSetDestroy),       //4
  (n: 'FcFontList'; d: @FcFontList),                       //5
  (n: 'FcCharSetCreate'; d: @FcCharSetCreate),             //6
  (n: 'FcCharSetDestroy'; d: @FcCharSetDestroy),           //7
  (n: 'FcCharSetAddChar'; d: @FcCharSetAddChar),           //8
  (n: 'FcPatternAdd'; d: @FcPatternAdd),                   //9
  (n: 'FcPatternCreate'; d: @FcPatternCreate),             //10
  (n: 'FcConfigSubstitute'; d: @FcConfigSubstitute),       //11
  (n: 'FcDefaultSubstitute'; d: @FcDefaultSubstitute),     //12
  (n: 'FcFontSort'; d: @FcFontSort),                       //13
  (n: 'FcCharSetHasChar'; d: @FcCharSetHasChar),           //14
  (n: 'FcPatternDuplicate'; d: @FcPatternDuplicate),       //15
  (n: 'FcPatternGetCharSet'; d: @FcPatternGetCharSet),     //16
  (n: 'FcFontRenderPrepare'; d: @FcFontRenderPrepare),     //17
  (n: 'FcMatrixRotate'; d: @FcMatrixRotate),               //18
  (n: 'FcMatrixScale'; d: @FcMatrixScale),                 //19
  (n: 'FcPatternAddInteger'; d: @FcPatternAddInteger),     //20
  (n: 'FcPatternAddDouble'; d: @FcPatternAddDouble),       //21
  (n: 'FcPatternAddString'; d: @FcPatternAddString),       //22
  (n: 'FcPatternAddMatrix'; d: @FcPatternAddMatrix),       //23
  (n: 'FcPatternAddCharSet'; d: @FcPatternAddCharSet),     //24
  (n: 'FcPatternAddBool'; d: @FcPatternAddBool),           //25
  (n: 'FcPatternAddLangSet'; d: @FcPatternAddLangSet),     //26
  (n: 'FcPatternGetString'; d: @FcPatternGetString),       //27
  (n: 'FcInit'; d: @FcInit),                               //28
  (n: 'FcFini'; d: @FcFini),                               //29
  (n: 'FcNameParse'; d: @FcNameParse),                     //30
  (n: 'FcFontMatch'; d: @FcFontMatch),                     //31
  (n: 'FcPatternGetInteger'; d: @FcPatternGetInteger),     //32
  (n: 'FcPatternGetDouble'; d: @FcPatternGetDouble)        //33
 );
 
begin
 try
  if length(sonames) = 0 then begin
   initializedynlib(libinfo,fontconfiglib,funcs,[],@init);
  end
  else begin
   initializedynlib(libinfo,sonames,funcs,[],@init);
  end;
 except
  on e: exception do begin
   e.message:= 'Can not load FontConfig library. '+e.message;
   raise;
  end;  
 end;
end;

procedure releasefontconfig;
begin
 releasedynlib(libinfo,@deinit);
end;


initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
