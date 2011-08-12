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

{$mode objfpc} {$h+}
{$MACRO ON}
//{$MODE Delphi}
{$IFDEF Windows}
  {$DEFINE extdecl := stdcall}
{$ELSE}
  {$DEFINE extdecl := cdecl}
{$ENDIF}

{$IFDEF MORPHOS}
{$INLINE ON}
{$DEFINE GLU_UNIT}
{$ENDIF}

unit mseglu;

interface

uses
  SysUtils,
  {$IFDEF Windows}
  Windows,
  {$ELSE}
  {$IFDEF MORPHOS}
  TinyGL,
  {$ENDIF}
  {$ENDIF}
  msegl,msestrings;

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
  gluErrorString: function(errCode: GLenum): PChar; extdecl;
  gluErrorUnicodeStringEXT: function(errCode: GLenum): PWideChar; extdecl;
                            //not on linux
  gluGetString: function(name: GLenum): PChar; extdecl;
  gluOrtho2D: procedure(left,right, bottom, top: GLdouble); extdecl;
  gluPerspective: procedure(fovy, aspect, zNear, zFar: GLdouble); extdecl;
  gluPickMatrix: procedure(x, y, width, height: GLdouble; var viewport: TViewPortArray); extdecl;
  gluLookAt: procedure(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: GLdouble); extdecl;
  gluProject: function(objx, objy, objz: GLdouble; var modelMatrix, projMatrix: T16dArray; var viewport: TViewPortArray; winx, winy, winz: PGLdouble): Integer; extdecl;
  gluUnProject: function(winx, winy, winz: GLdouble; var modelMatrix, projMatrix: T16dArray; var viewport: TViewPortArray; objx, objy, objz: PGLdouble): Integer; extdecl;
  gluScaleImage: function(format: GLenum; widthin, heightin: GLint; typein: GLenum; const datain: Pointer; widthout, heightout: GLint; typeout: GLenum; dataout: Pointer): Integer; extdecl;
  gluBuild1DMipmaps: function(target: GLenum; components, width: GLint; format, atype: GLenum; const data: Pointer): Integer; extdecl;
  gluBuild2DMipmaps: function(target: GLenum; components, width, height: GLint; format, atype: GLenum; const data: Pointer): Integer; extdecl;

var
  gluNewQuadric: function: PGLUquadric; extdecl;
  gluDeleteQuadric: procedure(state: PGLUquadric); extdecl;
  gluQuadricNormals: procedure(quadObject: PGLUquadric; normals: GLenum); extdecl;
  gluQuadricTexture: procedure(quadObject: PGLUquadric; textureCoords: GLboolean); extdecl;
  gluQuadricOrientation: procedure(quadObject: PGLUquadric; orientation: GLenum); extdecl;
  gluQuadricDrawStyle: procedure(quadObject: PGLUquadric; drawStyle: GLenum); extdecl;
  gluCylinder: procedure(qobj: PGLUquadric; baseRadius, topRadius, height: GLdouble; slices, stacks: GLint); extdecl;
  gluDisk: procedure(qobj: PGLUquadric; innerRadius, outerRadius: GLdouble; slices, loops: GLint); extdecl;
  gluPartialDisk: procedure(qobj: PGLUquadric; innerRadius, outerRadius: GLdouble; slices, loops: GLint; startAngle, sweepAngle: GLdouble); extdecl;
  gluSphere: procedure(qobj: PGLuquadric; radius: GLdouble; slices, stacks: GLint); extdecl;
  gluQuadricCallback: procedure(qobj: PGLUquadric; which: GLenum; fn: TCallBack); extdecl;
  gluNewTess: function: PGLUtesselator; extdecl;
  gluDeleteTess: procedure(tess: PGLUtesselator); extdecl;
  gluTessBeginPolygon: procedure(tess: PGLUtesselator; polygon_data: Pointer); extdecl;
  gluTessBeginContour: procedure(tess: PGLUtesselator); extdecl;
  gluTessVertex: procedure(tess: PGLUtesselator; var coords: T3dArray; data: Pointer); extdecl;
  gluTessEndContour: procedure(tess: PGLUtesselator); extdecl;
  gluTessEndPolygon: procedure(tess: PGLUtesselator); extdecl;
  gluTessProperty: procedure(tess: PGLUtesselator; which: GLenum; value: GLdouble); extdecl;
  gluTessNormal: procedure(tess: PGLUtesselator; x, y, z: GLdouble); extdecl;
  gluTessCallback: procedure(tess: PGLUtesselator; which: GLenum;fn: TCallBack); extdecl;
  gluGetTessProperty: procedure(tess: PGLUtesselator; which: GLenum; value: PGLdouble); extdecl;
  gluNewNurbsRenderer: function: PGLUnurbs; extdecl;
  gluDeleteNurbsRenderer: procedure(nobj: PGLUnurbs); extdecl;
  gluBeginSurface: procedure(nobj: PGLUnurbs); extdecl;
  gluBeginCurve: procedure(nobj: PGLUnurbs); extdecl;
  gluEndCurve: procedure(nobj: PGLUnurbs); extdecl;
  gluEndSurface: procedure(nobj: PGLUnurbs); extdecl;
  gluBeginTrim: procedure(nobj: PGLUnurbs); extdecl;
  gluEndTrim: procedure(nobj: PGLUnurbs); extdecl;
  gluPwlCurve: procedure(nobj: PGLUnurbs; count: GLint; aarray: PGLfloat; stride: GLint; atype: GLenum); extdecl;
  gluNurbsCurve: procedure(nobj: PGLUnurbs; nknots: GLint; knot: PGLfloat; stride: GLint; ctlarray: PGLfloat; order: GLint; atype: GLenum); extdecl;
  gluNurbsSurface: procedure(nobj: PGLUnurbs; sknot_count: GLint; sknot: PGLfloat; tknot_count: GLint; tknot: PGLfloat; s_stride, t_stride: GLint; ctlarray: PGLfloat; sorder, torder: GLint; atype: GLenum); extdecl;
  gluLoadSamplingMatrices: procedure(nobj: PGLUnurbs; var modelMatrix, projMatrix: T16dArray; var viewport: TViewPortArray); extdecl;
  gluNurbsProperty: procedure(nobj: PGLUnurbs; aproperty: GLenum; value: GLfloat); extdecl;
  gluGetNurbsProperty: procedure(nobj: PGLUnurbs; aproperty: GLenum; value: PGLfloat); extdecl;
  gluNurbsCallback: procedure(nobj: PGLUnurbs; which: GLenum; fn: TCallBack); extdecl;
{$ENDIF MORPHOS}

(**** Callback function prototypes ****)

type
  // gluQuadricCallback
  GLUquadricErrorProc = procedure(p: GLenum); extdecl;

  // gluTessCallback
  GLUtessBeginProc = procedure(p: GLenum); extdecl;
  GLUtessEdgeFlagProc = procedure(p: GLboolean); extdecl;
  GLUtessVertexProc = procedure(p: Pointer); extdecl;
  GLUtessEndProc = procedure; extdecl;
  GLUtessErrorProc = procedure(p: GLenum); extdecl;
  GLUtessCombineProc = procedure(var p1: T3dArray; p2: T4pArray; p3: T4fArray; p4: PPointer); extdecl;
  GLUtessBeginDataProc = procedure(p1: GLenum; p2: Pointer); extdecl;
  GLUtessEdgeFlagDataProc = procedure(p1: GLboolean; p2: Pointer); extdecl;
  GLUtessVertexDataProc = procedure(p1, p2: Pointer); extdecl;
  GLUtessEndDataProc = procedure(p: Pointer); extdecl;
  GLUtessErrorDataProc = procedure(p1: GLenum; p2: Pointer); extdecl;
  GLUtessCombineDataProc = procedure(var p1: T3dArray; var p2: T4pArray; var p3: T4fArray;
                                     p4: PPointer; p5: Pointer); extdecl;

  // gluNurbsCallback
  GLUnurbsErrorProc = procedure(p: GLenum); extdecl;


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
  gluBeginPolygon: procedure(tess: PGLUtesselator); extdecl;
  gluNextContour: procedure(tess: PGLUtesselator; atype: GLenum); extdecl;
  gluEndPolygon: procedure(tess: PGLUtesselator); extdecl;

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
    (n: 'gluErrorString'; d: @gluErrorString),
    (n: 'gluGetString'; d: @gluGetString),
    (n: 'gluOrtho2D'; d: @gluOrtho2D),
    (n: 'gluPerspective'; d: @gluPerspective),
    (n: 'gluPickMatrix'; d: @gluPickMatrix),
    (n: 'gluLookAt'; d: @gluLookAt),
    (n: 'gluProject'; d: @gluProject),
    (n: 'gluUnProject'; d: @gluUnProject),
    (n: 'gluScaleImage'; d: @gluScaleImage),
    (n: 'gluBuild1DMipmaps'; d: @gluBuild1DMipmaps),
    (n: 'gluBuild2DMipmaps'; d: @gluBuild2DMipmaps),
    (n: 'gluNewQuadric'; d: @gluNewQuadric),
    (n: 'gluDeleteQuadric'; d: @gluDeleteQuadric),
    (n: 'gluQuadricNormals'; d: @gluQuadricNormals),
    (n: 'gluQuadricTexture'; d: @gluQuadricTexture),
    (n: 'gluQuadricOrientation'; d: @gluQuadricOrientation),
    (n: 'gluQuadricDrawStyle'; d: @gluQuadricDrawStyle),
    (n: 'gluCylinder'; d: @gluCylinder),
    (n: 'gluDisk'; d: @gluDisk),
    (n: 'gluPartialDisk'; d: @gluPartialDisk),
    (n: 'gluSphere'; d: @gluSphere),
    (n: 'gluQuadricCallback'; d: @gluQuadricCallback),
    (n: 'gluNewTess'; d: @gluNewTess),
    (n: 'gluDeleteTess'; d: @gluDeleteTess),
    (n: 'gluTessBeginPolygon'; d: @gluTessBeginPolygon),
    (n: 'gluTessBeginContour'; d: @gluTessBeginContour),
    (n: 'gluTessVertex'; d: @gluTessVertex),
    (n: 'gluTessEndContour'; d: @gluTessEndContour),
    (n: 'gluTessEndPolygon'; d: @gluTessEndPolygon),
    (n: 'gluTessProperty'; d: @gluTessProperty),
    (n: 'gluTessNormal'; d: @gluTessNormal),
    (n: 'gluTessCallback'; d: @gluTessCallback),
    (n: 'gluGetTessProperty'; d: @gluGetTessProperty),
    (n: 'gluNewNurbsRenderer'; d: @gluNewNurbsRenderer),
    (n: 'gluDeleteNurbsRenderer'; d: @gluDeleteNurbsRenderer),
    (n: 'gluBeginSurface'; d: @gluBeginSurface),
    (n: 'gluBeginCurve'; d: @gluBeginCurve),
    (n: 'gluEndCurve'; d: @gluEndCurve),
    (n: 'gluEndSurface'; d: @gluEndSurface),
    (n: 'gluBeginTrim'; d: @gluBeginTrim),
    (n: 'gluEndTrim'; d: @gluEndTrim),
    (n: 'gluPwlCurve'; d: @gluPwlCurve),
    (n: 'gluNurbsCurve'; d: @gluNurbsCurve),
    (n: 'gluNurbsSurface'; d: @gluNurbsSurface),
    (n: 'gluLoadSamplingMatrices'; d: @gluLoadSamplingMatrices),
    (n: 'gluNurbsProperty'; d: @gluNurbsProperty),
    (n: 'gluGetNurbsProperty'; d: @gluGetNurbsProperty),
    (n: 'gluNurbsCallback'; d: @gluNurbsCallback),
    (n: 'gluBeginPolygon'; d: @gluBeginPolygon),
    (n: 'gluNextContour'; d: @gluNextContour),
    (n: 'gluEndPolygon'; d: @gluEndPolygon)
   );
 funcsopt: array[0..0] of funcinfoty = (
    (n: 'gluErrorUnicodeStringEXT'; d: @gluErrorUnicodeStringEXT)
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
