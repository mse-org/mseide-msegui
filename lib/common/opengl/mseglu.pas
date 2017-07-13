{

  Adaption of the delphi3d.net OpenGL units to FreePascal
  Sebastian Guenther (sg@freepascal.org) in 2002
  These units are free to use
}
//
// modified 2011 by Martin Schreiber
//
{*++ BUILD Version: 0004    // Increment this if a change has global effects

Copyright (c) 1985-95, Microsoft Corporation

Module Name:

    glu.h

Abstract:

    Procedure declarations, constant definitions and macros for the OpenGL
    Utility Library.

--*}

{*
** Copyright 1991-1993, Silicon Graphics, Inc.
** All Rights Reserved.
**
** This is UNPUBLISHED PROPRIETARY SOURCE CODE of Silicon Graphics, Inc.;
** the contents of this file may not be disclosed to third parties, copied or
** duplicated in any form, in whole or in part, without the prior written
** permission of Silicon Graphics, Inc.
**
** RESTRICTED RIGHTS LEGEND:
** Use, duplication or disclosure by the Government is subject to restrictions
** as set forth in subdivision (c)(1)(ii) of the Rights in Technical Data
** and Computer Software clause at DFARS 252.227-7013, and/or in similar or
** successor clauses in the FAR, DOD or NASA FAR Supplement. Unpublished -
** rights reserved under the Copyright Laws of the United States.
*}

{*
** Return the error string associated with a particular error code.
** This will return 0 for an invalid error code.
**
** The generic function prototype that can be compiled for ANSI or Unicode
** is defined as follows:
**
** LPCTSTR APIENTRY gluErrorStringWIN (GLenum errCode);
*}

{******************************************************************************}
{ Converted to Delphi by Tom Nuydens (tom@delphi3d.net)                        }
{ For the latest updates, visit Delphi3D: http://www.delphi3d.net              }
{******************************************************************************}

{$ifdef FPC}{$mode objfpc} {$h+}{$MACRO ON}{$endif}
//{$MODE Delphi}
{$IFDEF msWindows}
 {$define wincall}
//  {$DEFINE extdecl := stdcall}
{$ELSE}
//  {$DEFINE extdecl := cdecl}
{$ENDIF}

{$IFDEF MORPHOS}
{$INLINE ON}
{$DEFINE GLU_UNIT}
{$ENDIF}

unit mseglu;

interface

uses
  SysUtils,
  {$IFDEF msWindows}
  Windows,
  {$ELSE}
  {$IFDEF MORPHOS}
  TinyGL,
  {$ENDIF}
  {$ENDIF}
  msegl,msetypes{,msestrings};

const
{$ifdef mswindows}
 glulib: array[0..0] of filenamety = ('glu32.dll');  
{$else}
 glulib: array[0..1] of filenamety = ('libGLU.so.1','libGLU.so.'); 
{$endif}

type
  TViewPortArray = array [0..3] of GLint;
  T16dArray = array [0..15] of GLdouble;
  TCallBack = procedure;
  T3dArray = array [0..2] of GLdouble;
  p3darray = ^t3darray;
  T4pArray = array [0..3] of Pointer;
  T4fArray = array [0..3] of GLfloat;
  PPointer = ^Pointer;

type
  GLUnurbs = record end;                PGLUnurbs = ^GLUnurbs;
  GLUquadric = record end;              PGLUquadric = ^GLUquadric;
  GLUtesselator = record end;           PGLUtesselator = ^GLUtesselator;

  // backwards compatibility:
  GLUnurbsObj = GLUnurbs;               PGLUnurbsObj = PGLUnurbs;
  GLUquadricObj = GLUquadric;           PGLUquadricObj = PGLUquadric;
  GLUtesselatorObj = GLUtesselator;     PGLUtesselatorObj = PGLUtesselator;
  GLUtriangulatorObj = GLUtesselator;   PGLUtriangulatorObj = PGLUtesselator;

  TGLUnurbs = GLUnurbs;
  TGLUquadric = GLUquadric;
  TGLUtesselator = GLUtesselator;

  TGLUnurbsObj = GLUnurbsObj;
  TGLUquadricObj = GLUquadricObj;
  TGLUtesselatorObj = GLUtesselatorObj;
  TGLUtriangulatorObj = GLUtriangulatorObj;

{$IFDEF MORPHOS}

{ MorphOS GL works differently due to different dynamic-library handling on Amiga-like }
{ systems, so its headers are included here. }
{$INCLUDE tinyglh.inc}

{$ELSE MORPHOS}
var
  gluErrorString: function(errCode: GLenum): PChar; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluErrorUnicodeStringEXT: function(errCode: GLenum): PWideChar; {$ifdef wincall}stdcall{$else}cdecl{$endif};
                            //not on linux
  gluGetString: function(name: GLenum): PChar; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluOrtho2D: procedure(left,right, bottom, top: GLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluPerspective: procedure(fovy, aspect, zNear, zFar: GLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluPickMatrix: procedure(x, y, width, height: GLdouble; var viewport: TViewPortArray); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluLookAt: procedure(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: GLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluProject: function(objx, objy, objz: GLdouble; var modelMatrix, projMatrix: T16dArray; var viewport: TViewPortArray; winx, winy, winz: PGLdouble): Integer; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluUnProject: function(winx, winy, winz: GLdouble; var modelMatrix, projMatrix: T16dArray; var viewport: TViewPortArray; objx, objy, objz: PGLdouble): Integer; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluScaleImage: function(format: GLenum; widthin, heightin: GLint; typein: GLenum; const datain: Pointer; widthout, heightout: GLint; typeout: GLenum; dataout: Pointer): Integer; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluBuild1DMipmaps: function(target: GLenum; components, width: GLint; format, atype: GLenum; const data: Pointer): Integer; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluBuild2DMipmaps: function(target: GLenum; components, width, height: GLint; format, atype: GLenum; const data: Pointer): Integer; {$ifdef wincall}stdcall{$else}cdecl{$endif};

var
  gluNewQuadric: function: PGLUquadric; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluDeleteQuadric: procedure(state: PGLUquadric); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluQuadricNormals: procedure(quadObject: PGLUquadric; normals: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluQuadricTexture: procedure(quadObject: PGLUquadric; textureCoords: GLboolean); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluQuadricOrientation: procedure(quadObject: PGLUquadric; orientation: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluQuadricDrawStyle: procedure(quadObject: PGLUquadric; drawStyle: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluCylinder: procedure(qobj: PGLUquadric; baseRadius, topRadius, height: GLdouble; slices, stacks: GLint); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluDisk: procedure(qobj: PGLUquadric; innerRadius, outerRadius: GLdouble; slices, loops: GLint); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluPartialDisk: procedure(qobj: PGLUquadric; innerRadius, outerRadius: GLdouble; slices, loops: GLint; startAngle, sweepAngle: GLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluSphere: procedure(qobj: PGLuquadric; radius: GLdouble; slices, stacks: GLint); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluQuadricCallback: procedure(qobj: PGLUquadric; which: GLenum; fn: TCallBack); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNewTess: function: PGLUtesselator; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluDeleteTess: procedure(tess: PGLUtesselator); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessBeginPolygon: procedure(tess: PGLUtesselator; polygon_data: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessBeginContour: procedure(tess: PGLUtesselator); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessVertex: procedure(tess: PGLUtesselator; var coords: T3dArray; data: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessEndContour: procedure(tess: PGLUtesselator); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessEndPolygon: procedure(tess: PGLUtesselator); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessProperty: procedure(tess: PGLUtesselator; which: GLenum; value: GLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessNormal: procedure(tess: PGLUtesselator; x, y, z: GLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluTessCallback: procedure(tess: PGLUtesselator; which: GLenum;fn: TCallBack); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluGetTessProperty: procedure(tess: PGLUtesselator; which: GLenum; value: PGLdouble); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNewNurbsRenderer: function: PGLUnurbs; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluDeleteNurbsRenderer: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluBeginSurface: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluBeginCurve: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluEndCurve: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluEndSurface: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluBeginTrim: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluEndTrim: procedure(nobj: PGLUnurbs); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluPwlCurve: procedure(nobj: PGLUnurbs; count: GLint; aarray: PGLfloat; stride: GLint; atype: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNurbsCurve: procedure(nobj: PGLUnurbs; nknots: GLint; knot: PGLfloat; stride: GLint; ctlarray: PGLfloat; order: GLint; atype: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNurbsSurface: procedure(nobj: PGLUnurbs; sknot_count: GLint; sknot: PGLfloat; tknot_count: GLint; tknot: PGLfloat; s_stride, t_stride: GLint; ctlarray: PGLfloat; sorder, torder: GLint; atype: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluLoadSamplingMatrices: procedure(nobj: PGLUnurbs; var modelMatrix, projMatrix: T16dArray; var viewport: TViewPortArray); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNurbsProperty: procedure(nobj: PGLUnurbs; aproperty: GLenum; value: GLfloat); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluGetNurbsProperty: procedure(nobj: PGLUnurbs; aproperty: GLenum; value: PGLfloat); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNurbsCallback: procedure(nobj: PGLUnurbs; which: GLenum; fn: TCallBack); {$ifdef wincall}stdcall{$else}cdecl{$endif};
{$ENDIF MORPHOS}

(**** Callback function prototypes ****)

type
  // gluQuadricCallback
  GLUquadricErrorProc = procedure(p: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};

  // gluTessCallback
  GLUtessBeginProc = procedure(p: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessEdgeFlagProc = procedure(p: GLboolean); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessVertexProc = procedure(p: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessEndProc = procedure; {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessErrorProc = procedure(p: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessCombineProc = procedure(var p1: T3dArray; p2: T4pArray; p3: T4fArray; p4: PPointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessBeginDataProc = procedure(p1: GLenum; p2: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessEdgeFlagDataProc = procedure(p1: GLboolean; p2: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessVertexDataProc = procedure(p1, p2: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessEndDataProc = procedure(p: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessErrorDataProc = procedure(p1: GLenum; p2: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  GLUtessCombineDataProc = procedure(var p1: T3dArray; var p2: T4pArray; var p3: T4fArray;
                                     p4: PPointer; p5: Pointer); {$ifdef wincall}stdcall{$else}cdecl{$endif};

  // gluNurbsCallback
  GLUnurbsErrorProc = procedure(p: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};


//***           Generic constants               ****/

const
  // Version
  GLU_VERSION_1_1                 = 1;
  GLU_VERSION_1_2                 = 1;

  // Errors: (return value 0 = no error)
  GLU_INVALID_ENUM                = 100900;
  GLU_INVALID_VALUE               = 100901;
  GLU_OUT_OF_MEMORY               = 100902;
  GLU_INCOMPATIBLE_GL_VERSION     = 100903;

  // StringName
  GLU_VERSION                     = 100800;
  GLU_EXTENSIONS                  = 100801;

  // Boolean
  GLU_TRUE                        = GL_TRUE;
  GLU_FALSE                       = GL_FALSE;


  //***           Quadric constants               ****/

  // QuadricNormal
  GLU_SMOOTH              = 100000;
  GLU_FLAT                = 100001;
  GLU_NONE                = 100002;

  // QuadricDrawStyle
  GLU_POINT               = 100010;
  GLU_LINE                = 100011;
  GLU_FILL                = 100012;
  GLU_SILHOUETTE          = 100013;

  // QuadricOrientation
  GLU_OUTSIDE             = 100020;
  GLU_INSIDE              = 100021;

  // Callback types:
  //      GLU_ERROR       = 100103;


  //***           Tesselation constants           ****/

  GLU_TESS_MAX_COORD              = 1.0e150;

  // TessProperty
  GLU_TESS_WINDING_RULE           = 100140;
  GLU_TESS_BOUNDARY_ONLY          = 100141;
  GLU_TESS_TOLERANCE              = 100142;

  // TessWinding
  GLU_TESS_WINDING_ODD            = 100130;
  GLU_TESS_WINDING_NONZERO        = 100131;
  GLU_TESS_WINDING_POSITIVE       = 100132;
  GLU_TESS_WINDING_NEGATIVE       = 100133;
  GLU_TESS_WINDING_ABS_GEQ_TWO    = 100134;

  // TessCallback
  GLU_TESS_BEGIN          = 100100;    // void (CALLBACK*)(GLenum    type)
  GLU_TESS_VERTEX         = 100101;    // void (CALLBACK*)(void      *data)
  GLU_TESS_END            = 100102;    // void (CALLBACK*)(void)
  GLU_TESS_ERROR          = 100103;    // void (CALLBACK*)(GLenum    errno)
  GLU_TESS_EDGE_FLAG      = 100104;    // void (CALLBACK*)(GLboolean boundaryEdge)
  GLU_TESS_COMBINE        = 100105;    { void (CALLBACK*)(GLdouble  coords[3],
                                                            void      *data[4],
                                                            GLfloat   weight[4],
                                                            void      **dataOut) }
  GLU_TESS_BEGIN_DATA     = 100106;    { void (CALLBACK*)(GLenum    type,
                                                            void      *polygon_data) }
  GLU_TESS_VERTEX_DATA    = 100107;    { void (CALLBACK*)(void      *data,
                                                            void      *polygon_data) }
  GLU_TESS_END_DATA       = 100108;    // void (CALLBACK*)(void      *polygon_data)
  GLU_TESS_ERROR_DATA     = 100109;    { void (CALLBACK*)(GLenum    errno,
                                                            void      *polygon_data) }
  GLU_TESS_EDGE_FLAG_DATA = 100110;    { void (CALLBACK*)(GLboolean boundaryEdge,
                                                            void      *polygon_data) }
  GLU_TESS_COMBINE_DATA   = 100111;    { void (CALLBACK*)(GLdouble  coords[3],
                                                            void      *data[4],
                                                            GLfloat   weight[4],
                                                            void      **dataOut,
                                                            void      *polygon_data) }

  // TessError
  GLU_TESS_ERROR1     = 100151;
  GLU_TESS_ERROR2     = 100152;
  GLU_TESS_ERROR3     = 100153;
  GLU_TESS_ERROR4     = 100154;
  GLU_TESS_ERROR5     = 100155;
  GLU_TESS_ERROR6     = 100156;
  GLU_TESS_ERROR7     = 100157;
  GLU_TESS_ERROR8     = 100158;

  GLU_TESS_MISSING_BEGIN_POLYGON  = GLU_TESS_ERROR1;
  GLU_TESS_MISSING_BEGIN_CONTOUR  = GLU_TESS_ERROR2;
  GLU_TESS_MISSING_END_POLYGON    = GLU_TESS_ERROR3;
  GLU_TESS_MISSING_END_CONTOUR    = GLU_TESS_ERROR4;
  GLU_TESS_COORD_TOO_LARGE        = GLU_TESS_ERROR5;
  GLU_TESS_NEED_COMBINE_CALLBACK  = GLU_TESS_ERROR6;

  //***           NURBS constants                 ****/

  // NurbsProperty
  GLU_AUTO_LOAD_MATRIX            = 100200;
  GLU_CULLING                     = 100201;
  GLU_SAMPLING_TOLERANCE          = 100203;
  GLU_DISPLAY_MODE                = 100204;
  GLU_PARAMETRIC_TOLERANCE        = 100202;
  GLU_SAMPLING_METHOD             = 100205;
  GLU_U_STEP                      = 100206;
  GLU_V_STEP                      = 100207;

  // NurbsSampling
  GLU_PATH_LENGTH                 = 100215;
  GLU_PARAMETRIC_ERROR            = 100216;
  GLU_DOMAIN_DISTANCE             = 100217;


  // NurbsTrim
  GLU_MAP1_TRIM_2                 = 100210;
  GLU_MAP1_TRIM_3                 = 100211;

  // NurbsDisplay
  //      GLU_FILL                = 100012;
  GLU_OUTLINE_POLYGON             = 100240;
  GLU_OUTLINE_PATCH               = 100241;

  // NurbsCallback
  //      GLU_ERROR               = 100103;

  // NurbsErrors
  GLU_NURBS_ERROR1        = 100251;
  GLU_NURBS_ERROR2        = 100252;
  GLU_NURBS_ERROR3        = 100253;
  GLU_NURBS_ERROR4        = 100254;
  GLU_NURBS_ERROR5        = 100255;
  GLU_NURBS_ERROR6        = 100256;
  GLU_NURBS_ERROR7        = 100257;
  GLU_NURBS_ERROR8        = 100258;
  GLU_NURBS_ERROR9        = 100259;
  GLU_NURBS_ERROR10       = 100260;
  GLU_NURBS_ERROR11       = 100261;
  GLU_NURBS_ERROR12       = 100262;
  GLU_NURBS_ERROR13       = 100263;
  GLU_NURBS_ERROR14       = 100264;
  GLU_NURBS_ERROR15       = 100265;
  GLU_NURBS_ERROR16       = 100266;
  GLU_NURBS_ERROR17       = 100267;
  GLU_NURBS_ERROR18       = 100268;
  GLU_NURBS_ERROR19       = 100269;
  GLU_NURBS_ERROR20       = 100270;
  GLU_NURBS_ERROR21       = 100271;
  GLU_NURBS_ERROR22       = 100272;
  GLU_NURBS_ERROR23       = 100273;
  GLU_NURBS_ERROR24       = 100274;
  GLU_NURBS_ERROR25       = 100275;
  GLU_NURBS_ERROR26       = 100276;
  GLU_NURBS_ERROR27       = 100277;
  GLU_NURBS_ERROR28       = 100278;
  GLU_NURBS_ERROR29       = 100279;
  GLU_NURBS_ERROR30       = 100280;
  GLU_NURBS_ERROR31       = 100281;
  GLU_NURBS_ERROR32       = 100282;
  GLU_NURBS_ERROR33       = 100283;
  GLU_NURBS_ERROR34       = 100284;
  GLU_NURBS_ERROR35       = 100285;
  GLU_NURBS_ERROR36       = 100286;
  GLU_NURBS_ERROR37       = 100287;

//***           Backwards compatibility for old tesselator           ****/

var
  gluBeginPolygon: procedure(tess: PGLUtesselator); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluNextContour: procedure(tess: PGLUtesselator; atype: GLenum); {$ifdef wincall}stdcall{$else}cdecl{$endif};
  gluEndPolygon: procedure(tess: PGLUtesselator); {$ifdef wincall}stdcall{$else}cdecl{$endif};

const
  // Contours types -- obsolete!
  GLU_CW          = 100120;
  GLU_CCW         = 100121;
  GLU_INTERIOR    = 100122;
  GLU_EXTERIOR    = 100123;
  GLU_UNKNOWN     = 100124;

  // Names without "TESS_" prefix
  GLU_BEGIN       = GLU_TESS_BEGIN;
  GLU_VERTEX      = GLU_TESS_VERTEX;
  GLU_END         = GLU_TESS_END;
  GLU_ERROR       = GLU_TESS_ERROR;
  GLU_EDGE_FLAG   = GLU_TESS_EDGE_FLAG;

//procedure LoadGLu(const dll: String);
//procedure FreeGLu;

procedure initializeglu(const sonames: array of filenamety); //[] = default
procedure releaseglu;

implementation
uses
 msedynload,msesys;
var
 libinfo: dynlibinfoty;

procedure initializeglu(const sonames: array of filenamety); //[] = default
const
 funcs: array[0..50] of funcinfoty = (
    (n: 'gluErrorString'; d: {$ifndef FPC}@{$endif}@gluErrorString),
    (n: 'gluGetString'; d: {$ifndef FPC}@{$endif}@gluGetString),
    (n: 'gluOrtho2D'; d: {$ifndef FPC}@{$endif}@gluOrtho2D),
    (n: 'gluPerspective'; d: {$ifndef FPC}@{$endif}@gluPerspective),
    (n: 'gluPickMatrix'; d: {$ifndef FPC}@{$endif}@gluPickMatrix),
    (n: 'gluLookAt'; d: {$ifndef FPC}@{$endif}@gluLookAt),
    (n: 'gluProject'; d: {$ifndef FPC}@{$endif}@gluProject),
    (n: 'gluUnProject'; d: {$ifndef FPC}@{$endif}@gluUnProject),
    (n: 'gluScaleImage'; d: {$ifndef FPC}@{$endif}@gluScaleImage),
    (n: 'gluBuild1DMipmaps'; d: {$ifndef FPC}@{$endif}@gluBuild1DMipmaps),
    (n: 'gluBuild2DMipmaps'; d: {$ifndef FPC}@{$endif}@gluBuild2DMipmaps),
    (n: 'gluNewQuadric'; d: {$ifndef FPC}@{$endif}@gluNewQuadric),
    (n: 'gluDeleteQuadric'; d: {$ifndef FPC}@{$endif}@gluDeleteQuadric),
    (n: 'gluQuadricNormals'; d: {$ifndef FPC}@{$endif}@gluQuadricNormals),
    (n: 'gluQuadricTexture'; d: {$ifndef FPC}@{$endif}@gluQuadricTexture),
    (n: 'gluQuadricOrientation'; d: {$ifndef FPC}@{$endif}@gluQuadricOrientation),
    (n: 'gluQuadricDrawStyle'; d: {$ifndef FPC}@{$endif}@gluQuadricDrawStyle),
    (n: 'gluCylinder'; d: {$ifndef FPC}@{$endif}@gluCylinder),
    (n: 'gluDisk'; d: {$ifndef FPC}@{$endif}@gluDisk),
    (n: 'gluPartialDisk'; d: {$ifndef FPC}@{$endif}@gluPartialDisk),
    (n: 'gluSphere'; d: {$ifndef FPC}@{$endif}@gluSphere),
    (n: 'gluQuadricCallback'; d: {$ifndef FPC}@{$endif}@gluQuadricCallback),
    (n: 'gluNewTess'; d: {$ifndef FPC}@{$endif}@gluNewTess),
    (n: 'gluDeleteTess'; d: {$ifndef FPC}@{$endif}@gluDeleteTess),
    (n: 'gluTessBeginPolygon'; d: {$ifndef FPC}@{$endif}@gluTessBeginPolygon),
    (n: 'gluTessBeginContour'; d: {$ifndef FPC}@{$endif}@gluTessBeginContour),
    (n: 'gluTessVertex'; d: {$ifndef FPC}@{$endif}@gluTessVertex),
    (n: 'gluTessEndContour'; d: {$ifndef FPC}@{$endif}@gluTessEndContour),
    (n: 'gluTessEndPolygon'; d: {$ifndef FPC}@{$endif}@gluTessEndPolygon),
    (n: 'gluTessProperty'; d: {$ifndef FPC}@{$endif}@gluTessProperty),
    (n: 'gluTessNormal'; d: {$ifndef FPC}@{$endif}@gluTessNormal),
    (n: 'gluTessCallback'; d: {$ifndef FPC}@{$endif}@gluTessCallback),
    (n: 'gluGetTessProperty'; d: {$ifndef FPC}@{$endif}@gluGetTessProperty),
    (n: 'gluNewNurbsRenderer'; d: {$ifndef FPC}@{$endif}@gluNewNurbsRenderer),
    (n: 'gluDeleteNurbsRenderer'; d: {$ifndef FPC}@{$endif}@gluDeleteNurbsRenderer),
    (n: 'gluBeginSurface'; d: {$ifndef FPC}@{$endif}@gluBeginSurface),
    (n: 'gluBeginCurve'; d: {$ifndef FPC}@{$endif}@gluBeginCurve),
    (n: 'gluEndCurve'; d: {$ifndef FPC}@{$endif}@gluEndCurve),
    (n: 'gluEndSurface'; d: {$ifndef FPC}@{$endif}@gluEndSurface),
    (n: 'gluBeginTrim'; d: {$ifndef FPC}@{$endif}@gluBeginTrim),
    (n: 'gluEndTrim'; d: {$ifndef FPC}@{$endif}@gluEndTrim),
    (n: 'gluPwlCurve'; d: {$ifndef FPC}@{$endif}@gluPwlCurve),
    (n: 'gluNurbsCurve'; d: {$ifndef FPC}@{$endif}@gluNurbsCurve),
    (n: 'gluNurbsSurface'; d: {$ifndef FPC}@{$endif}@gluNurbsSurface),
    (n: 'gluLoadSamplingMatrices'; d: {$ifndef FPC}@{$endif}@gluLoadSamplingMatrices),
    (n: 'gluNurbsProperty'; d: {$ifndef FPC}@{$endif}@gluNurbsProperty),
    (n: 'gluGetNurbsProperty'; d: {$ifndef FPC}@{$endif}@gluGetNurbsProperty),
    (n: 'gluNurbsCallback'; d: {$ifndef FPC}@{$endif}@gluNurbsCallback),
    (n: 'gluBeginPolygon'; d: {$ifndef FPC}@{$endif}@gluBeginPolygon),
    (n: 'gluNextContour'; d: {$ifndef FPC}@{$endif}@gluNextContour),
    (n: 'gluEndPolygon'; d: {$ifndef FPC}@{$endif}@gluEndPolygon)
   );
 funcsopt: array[0..0] of funcinfoty = (
    (n: 'gluErrorUnicodeStringEXT'; d: {$ifndef FPC}@{$endif}@gluErrorUnicodeStringEXT)
   );
 errormessage = 'Can not load glu library';
begin
 initializedynlib(libinfo,sonames,glulib,funcs,funcsopt,errormessage);
end;

procedure releaseglu;
begin
 releasedynlib(libinfo,nil,true);
//used in xclosedisplay?
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
