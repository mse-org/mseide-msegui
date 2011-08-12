{

  Adaption of the delphi3d.net OpenGL units to FreePascal
  Sebastian Guenther (sg@freepascal.org) in 2002
  These units are free to use
}

{ modified 2011 by Martin Schreiber }

(*++ BUILD Version: 0004    // Increment this if a change has global effects

Copyright (c) 1985-96, Microsoft Corporation

Module Name:

    gl.h

Abstract:

    Procedure declarations, constant definitions and macros for the OpenGL
    component.

--*)

{*
** Copyright 1996 Silicon Graphics, Inc.
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

{******************************************************************************}
{ Converted to Delphi by Tom Nuydens (tom@delphi3d.net)                        }
{ For the latest updates, visit Delphi3D: http://www.delphi3d.net              }
{******************************************************************************}

//{$MODE Delphi}
{$mode objfpc} {$h+}
{$macro on}
{$ifdef mswindows}
  {$define extdecl := stdcall}
{$else}
  {$define extdecl := cdecl}
{$endif}

unit msegl;

interface

uses
 SysUtils,msestrings{$ifdef mswindows},windows{$endif},msedynload,
 mseglextglob;

const
{$ifdef mswindows}
 opengllib: array[0..0] of filenamety = ('opengl32.dll');  
{$else}
 opengllib: array[0..1] of filenamety = ('libGL.so.1','libGL.so'); 
{$endif}

type
  GLenum     = Cardinal;      PGLenum     = ^GLenum;
  GLboolean  = Byte;          PGLboolean  = ^GLboolean;
  GLbitfield = Cardinal;      PGLbitfield = ^GLbitfield;
  GLbyte     = ShortInt;      PGLbyte     = ^GLbyte;
  GLshort    = SmallInt;      PGLshort    = ^GLshort;
  GLint      = Integer;       PGLint      = ^GLint;
  GLsizei    = Integer;       PGLsizei    = ^GLsizei;
  GLubyte    = Byte;          PGLubyte    = ^GLubyte;
  GLushort   = Word;          PGLushort   = ^GLushort;
  GLuint     = Cardinal;      PGLuint     = ^GLuint;
  GLfloat    = Single;        PGLfloat    = ^GLfloat;
  GLclampf   = Single;        PGLclampf   = ^GLclampf;
  GLdouble   = Double;        PGLdouble   = ^GLdouble;
  GLclampd   = Double;        PGLclampd   = ^GLclampd;
{ GLvoid     = void; }        PGLvoid     = Pointer;
                              PPGLvoid    = ^PGLvoid;

  TGLenum     = GLenum;
  TGLboolean  = GLboolean;
  TGLbitfield = GLbitfield;
  TGLbyte     = GLbyte;
  TGLshort    = GLshort;
  TGLint      = GLint;
  TGLsizei    = GLsizei;
  TGLubyte    = GLubyte;
  TGLushort   = GLushort;
  TGLuint     = GLuint;
  TGLfloat    = GLfloat;
  TGLclampf   = GLclampf;
  TGLdouble   = GLdouble;
  TGLclampd   = GLclampd;

{******************************************************************************}

const
  // Version
  GL_VERSION_1_1                    = 1;

  // AccumOp
  GL_ACCUM                          = $0100;
  GL_LOAD                           = $0101;
  GL_RETURN                         = $0102;
  GL_MULT                           = $0103;
  GL_ADD                            = $0104;

  // AlphaFunction
  GL_NEVER                          = $0200;
  GL_LESS                           = $0201;
  GL_EQUAL                          = $0202;
  GL_LEQUAL                         = $0203;
  GL_GREATER                        = $0204;
  GL_NOTEQUAL                       = $0205;
  GL_GEQUAL                         = $0206;
  GL_ALWAYS                         = $0207;

  // AttribMask
  GL_CURRENT_BIT                    = $00000001;
  GL_POINT_BIT                      = $00000002;
  GL_LINE_BIT                       = $00000004;
  GL_POLYGON_BIT                    = $00000008;
  GL_POLYGON_STIPPLE_BIT            = $00000010;
  GL_PIXEL_MODE_BIT                 = $00000020;
  GL_LIGHTING_BIT                   = $00000040;
  GL_FOG_BIT                        = $00000080;
  GL_DEPTH_BUFFER_BIT               = $00000100;
  GL_ACCUM_BUFFER_BIT               = $00000200;
  GL_STENCIL_BUFFER_BIT             = $00000400;
  GL_VIEWPORT_BIT                   = $00000800;
  GL_TRANSFORM_BIT                  = $00001000;
  GL_ENABLE_BIT                     = $00002000;
  GL_COLOR_BUFFER_BIT               = $00004000;
  GL_HINT_BIT                       = $00008000;
  GL_EVAL_BIT                       = $00010000;
  GL_LIST_BIT                       = $00020000;
  GL_TEXTURE_BIT                    = $00040000;
  GL_SCISSOR_BIT                    = $00080000;
  GL_ALL_ATTRIB_BITS                = $000FFFFF;

  // BeginMode
  GL_POINTS                         = $0000;
  GL_LINES                          = $0001;
  GL_LINE_LOOP                      = $0002;
  GL_LINE_STRIP                     = $0003;
  GL_TRIANGLES                      = $0004;
  GL_TRIANGLE_STRIP                 = $0005;
  GL_TRIANGLE_FAN                   = $0006;
  GL_QUADS                          = $0007;
  GL_QUAD_STRIP                     = $0008;
  GL_POLYGON                        = $0009;

  // BlendingFactorDest
  GL_ZERO                           = 0;
  GL_ONE                            = 1;
  GL_SRC_COLOR                      = $0300;
  GL_ONE_MINUS_SRC_COLOR            = $0301;
  GL_SRC_ALPHA                      = $0302;
  GL_ONE_MINUS_SRC_ALPHA            = $0303;
  GL_DST_ALPHA                      = $0304;
  GL_ONE_MINUS_DST_ALPHA            = $0305;

  // BlendingFactorSrc
  //      GL_ZERO
  //      GL_ONE
  GL_DST_COLOR                      = $0306;
  GL_ONE_MINUS_DST_COLOR            = $0307;
  GL_SRC_ALPHA_SATURATE             = $0308;
  //      GL_SRC_ALPHA
  //      GL_ONE_MINUS_SRC_ALPHA
  //      GL_DST_ALPHA
  //      GL_ONE_MINUS_DST_ALPHA

  // Boolean
  GL_TRUE                           = 1;
  GL_FALSE                          = 0;

  // ClearBufferMask
  //      GL_COLOR_BUFFER_BIT
  //      GL_ACCUM_BUFFER_BIT
  //      GL_STENCIL_BUFFER_BIT
  //      GL_DEPTH_BUFFER_BIT

  // ClientArrayType
  //      GL_VERTEX_ARRAY
  //      GL_NORMAL_ARRAY
  //      GL_COLOR_ARRAY
  //      GL_INDEX_ARRAY
  //      GL_TEXTURE_COORD_ARRAY
  //      GL_EDGE_FLAG_ARRAY

  // ClipPlaneName
  GL_CLIP_PLANE0                    = $3000;
  GL_CLIP_PLANE1                    = $3001;
  GL_CLIP_PLANE2                    = $3002;
  GL_CLIP_PLANE3                    = $3003;
  GL_CLIP_PLANE4                    = $3004;
  GL_CLIP_PLANE5                    = $3005;

  // ColorMaterialFace
  //      GL_FRONT
  //      GL_BACK
  //      GL_FRONT_AND_BACK

  // ColorMaterialParameter
  //      GL_AMBIENT
  //      GL_DIFFUSE
  //      GL_SPECULAR
  //      GL_EMISSION
  //      GL_AMBIENT_AND_DIFFUSE

  // ColorPointerType
  //      GL_BYTE
  //      GL_UNSIGNED_BYTE
  //      GL_SHORT
  //      GL_UNSIGNED_SHORT
  //      GL_INT
  //      GL_UNSIGNED_INT
  //      GL_FLOAT
  //      GL_DOUBLE

  // CullFaceMode
  //      GL_FRONT
  //      GL_BACK
  //      GL_FRONT_AND_BACK

  // DataType
  GL_BYTE                           = $1400;
  GL_UNSIGNED_BYTE                  = $1401;
  GL_SHORT                          = $1402;
  GL_UNSIGNED_SHORT                 = $1403;
  GL_INT                            = $1404;
  GL_UNSIGNED_INT                   = $1405;
  GL_FLOAT                          = $1406;
  GL_2_BYTES                        = $1407;
  GL_3_BYTES                        = $1408;
  GL_4_BYTES                        = $1409;
  GL_DOUBLE                         = $140A;

  // DepthFunction
  //      GL_NEVER
  //      GL_LESS
  //      GL_EQUAL
  //      GL_LEQUAL
  //      GL_GREATER
  //      GL_NOTEQUAL
  //      GL_GEQUAL
  //      GL_ALWAYS

  // DrawBufferMode
  GL_NONE                           = 0;
  GL_FRONT_LEFT                     = $0400;
  GL_FRONT_RIGHT                    = $0401;
  GL_BACK_LEFT                      = $0402;
  GL_BACK_RIGHT                     = $0403;
  GL_FRONT                          = $0404;
  GL_BACK                           = $0405;
  GL_LEFT                           = $0406;
  GL_RIGHT                          = $0407;
  GL_FRONT_AND_BACK                 = $0408;
  GL_AUX0                           = $0409;
  GL_AUX1                           = $040A;
  GL_AUX2                           = $040B;
  GL_AUX3                           = $040C;

  // Enable
  //      GL_FOG
  //      GL_LIGHTING
  //      GL_TEXTURE_1D
  //      GL_TEXTURE_2D
  //      GL_LINE_STIPPLE
  //      GL_POLYGON_STIPPLE
  //      GL_CULL_FACE
  //      GL_ALPHA_TEST
  //      GL_BLEND
  //      GL_INDEX_LOGIC_OP
  //      GL_COLOR_LOGIC_OP
  //      GL_DITHER
  //      GL_STENCIL_TEST
  //      GL_DEPTH_TEST
  //      GL_CLIP_PLANE0
  //      GL_CLIP_PLANE1
  //      GL_CLIP_PLANE2
  //      GL_CLIP_PLANE3
  //      GL_CLIP_PLANE4
  //      GL_CLIP_PLANE5
  //      GL_LIGHT0
  //      GL_LIGHT1
  //      GL_LIGHT2
  //      GL_LIGHT3
  //      GL_LIGHT4
  //      GL_LIGHT5
  //      GL_LIGHT6
  //      GL_LIGHT7
  //      GL_TEXTURE_GEN_S
  //      GL_TEXTURE_GEN_T
  //      GL_TEXTURE_GEN_R
  //      GL_TEXTURE_GEN_Q
  //      GL_MAP1_VERTEX_3
  //      GL_MAP1_VERTEX_4
  //      GL_MAP1_COLOR_4
  //      GL_MAP1_INDEX
  //      GL_MAP1_NORMAL
  //      GL_MAP1_TEXTURE_COORD_1
  //      GL_MAP1_TEXTURE_COORD_2
  //      GL_MAP1_TEXTURE_COORD_3
  //      GL_MAP1_TEXTURE_COORD_4
  //      GL_MAP2_VERTEX_3
  //      GL_MAP2_VERTEX_4
  //      GL_MAP2_COLOR_4
  //      GL_MAP2_INDEX
  //      GL_MAP2_NORMAL
  //      GL_MAP2_TEXTURE_COORD_1
  //      GL_MAP2_TEXTURE_COORD_2
  //      GL_MAP2_TEXTURE_COORD_3
  //      GL_MAP2_TEXTURE_COORD_4
  //      GL_POINT_SMOOTH
  //      GL_LINE_SMOOTH
  //      GL_POLYGON_SMOOTH
  //      GL_SCISSOR_TEST
  //      GL_COLOR_MATERIAL
  //      GL_NORMALIZE
  //      GL_AUTO_NORMAL
  //      GL_VERTEX_ARRAY
  //      GL_NORMAL_ARRAY
  //      GL_COLOR_ARRAY
  //      GL_INDEX_ARRAY
  //      GL_TEXTURE_COORD_ARRAY
  //      GL_EDGE_FLAG_ARRAY
  //      GL_POLYGON_OFFSET_POINT
  //      GL_POLYGON_OFFSET_LINE
  //      GL_POLYGON_OFFSET_FILL

  // ErrorCode
  GL_NO_ERROR                       = 0;
  GL_INVALID_ENUM                   = $0500;
  GL_INVALID_VALUE                  = $0501;
  GL_INVALID_OPERATION              = $0502;
  GL_STACK_OVERFLOW                 = $0503;
  GL_STACK_UNDERFLOW                = $0504;
  GL_OUT_OF_MEMORY                  = $0505;

  // FeedBackMode
  GL_2D                             = $0600;
  GL_3D                             = $0601;
  GL_3D_COLOR                       = $0602;
  GL_3D_COLOR_TEXTURE               = $0603;
  GL_4D_COLOR_TEXTURE               = $0604;

  // FeedBackToken
  GL_PASS_THROUGH_TOKEN             = $0700;
  GL_POINT_TOKEN                    = $0701;
  GL_LINE_TOKEN                     = $0702;
  GL_POLYGON_TOKEN                  = $0703;
  GL_BITMAP_TOKEN                   = $0704;
  GL_DRAW_PIXEL_TOKEN               = $0705;
  GL_COPY_PIXEL_TOKEN               = $0706;
  GL_LINE_RESET_TOKEN               = $0707;

  // FogMode
  //      GL_LINEAR
  GL_EXP                            = $0800;
  GL_EXP2                           = $0801;

  // FogParameter
  //      GL_FOG_COLOR
  //      GL_FOG_DENSITY
  //      GL_FOG_END
  //      GL_FOG_INDEX
  //      GL_FOG_MODE
  //      GL_FOG_START

  // FrontFaceDirection
  GL_CW                             = $0900;
  GL_CCW                            = $0901;

  // GetMapTarget
  GL_COEFF                          = $0A00;
  GL_ORDER                          = $0A01;
  GL_DOMAIN                         = $0A02;

  // GetPixelMap
  //      GL_PIXEL_MAP_I_TO_I
  //      GL_PIXEL_MAP_S_TO_S
  //      GL_PIXEL_MAP_I_TO_R
  //      GL_PIXEL_MAP_I_TO_G
  //      GL_PIXEL_MAP_I_TO_B
  //      GL_PIXEL_MAP_I_TO_A
  //      GL_PIXEL_MAP_R_TO_R
  //      GL_PIXEL_MAP_G_TO_G
  //      GL_PIXEL_MAP_B_TO_B
  //      GL_PIXEL_MAP_A_TO_A

  // GetPointerTarget
  //      GL_VERTEX_ARRAY_POINTER
  //      GL_NORMAL_ARRAY_POINTER
  //      GL_COLOR_ARRAY_POINTER
  //      GL_INDEX_ARRAY_POINTER
  //      GL_TEXTURE_COORD_ARRAY_POINTER
  //      GL_EDGE_FLAG_ARRAY_POINTER

  // GetTarget
  GL_CURRENT_COLOR                  = $0B00;
  GL_CURRENT_INDEX                  = $0B01;
  GL_CURRENT_NORMAL                 = $0B02;
  GL_CURRENT_TEXTURE_COORDS         = $0B03;
  GL_CURRENT_RASTER_COLOR           = $0B04;
  GL_CURRENT_RASTER_INDEX           = $0B05;
  GL_CURRENT_RASTER_TEXTURE_COORDS  = $0B06;
  GL_CURRENT_RASTER_POSITION        = $0B07;
  GL_CURRENT_RASTER_POSITION_VALID  = $0B08;
  GL_CURRENT_RASTER_DISTANCE        = $0B09;
  GL_POINT_SMOOTH                   = $0B10;
  GL_POINT_SIZE                     = $0B11;
  GL_POINT_SIZE_RANGE               = $0B12;
  GL_POINT_SIZE_GRANULARITY         = $0B13;
  GL_LINE_SMOOTH                    = $0B20;
  GL_LINE_WIDTH                     = $0B21;
  GL_LINE_WIDTH_RANGE               = $0B22;
  GL_LINE_WIDTH_GRANULARITY         = $0B23;
  GL_LINE_STIPPLE                   = $0B24;
  GL_LINE_STIPPLE_PATTERN           = $0B25;
  GL_LINE_STIPPLE_REPEAT            = $0B26;
  GL_LIST_MODE                      = $0B30;
  GL_MAX_LIST_NESTING               = $0B31;
  GL_LIST_BASE                      = $0B32;
  GL_LIST_INDEX                     = $0B33;
  GL_POLYGON_MODE                   = $0B40;
  GL_POLYGON_SMOOTH                 = $0B41;
  GL_POLYGON_STIPPLE                = $0B42;
  GL_EDGE_FLAG                      = $0B43;
  GL_CULL_FACE                      = $0B44;
  GL_CULL_FACE_MODE                 = $0B45;
  GL_FRONT_FACE                     = $0B46;
  GL_LIGHTING                       = $0B50;
  GL_LIGHT_MODEL_LOCAL_VIEWER       = $0B51;
  GL_LIGHT_MODEL_TWO_SIDE           = $0B52;
  GL_LIGHT_MODEL_AMBIENT            = $0B53;
  GL_SHADE_MODEL                    = $0B54;
  GL_COLOR_MATERIAL_FACE            = $0B55;
  GL_COLOR_MATERIAL_PARAMETER       = $0B56;
  GL_COLOR_MATERIAL                 = $0B57;
  GL_FOG                            = $0B60;
  GL_FOG_INDEX                      = $0B61;
  GL_FOG_DENSITY                    = $0B62;
  GL_FOG_START                      = $0B63;
  GL_FOG_END                        = $0B64;
  GL_FOG_MODE                       = $0B65;
  GL_FOG_COLOR                      = $0B66;
  GL_DEPTH_RANGE                    = $0B70;
  GL_DEPTH_TEST                     = $0B71;
  GL_DEPTH_WRITEMASK                = $0B72;
  GL_DEPTH_CLEAR_VALUE              = $0B73;
  GL_DEPTH_FUNC                     = $0B74;
  GL_ACCUM_CLEAR_VALUE              = $0B80;
  GL_STENCIL_TEST                   = $0B90;
  GL_STENCIL_CLEAR_VALUE            = $0B91;
  GL_STENCIL_FUNC                   = $0B92;
  GL_STENCIL_VALUE_MASK             = $0B93;
  GL_STENCIL_FAIL                   = $0B94;
  GL_STENCIL_PASS_DEPTH_FAIL        = $0B95;
  GL_STENCIL_PASS_DEPTH_PASS        = $0B96;
  GL_STENCIL_REF                    = $0B97;
  GL_STENCIL_WRITEMASK              = $0B98;
  GL_MATRIX_MODE                    = $0BA0;
  GL_NORMALIZE                      = $0BA1;
  GL_VIEWPORT                       = $0BA2;
  GL_MODELVIEW_STACK_DEPTH          = $0BA3;
  GL_PROJECTION_STACK_DEPTH         = $0BA4;
  GL_TEXTURE_STACK_DEPTH            = $0BA5;
  GL_MODELVIEW_MATRIX               = $0BA6;
  GL_PROJECTION_MATRIX              = $0BA7;
  GL_TEXTURE_MATRIX                 = $0BA8;
  GL_ATTRIB_STACK_DEPTH             = $0BB0;
  GL_CLIENT_ATTRIB_STACK_DEPTH      = $0BB1;
  GL_ALPHA_TEST                     = $0BC0;
  GL_ALPHA_TEST_FUNC                = $0BC1;
  GL_ALPHA_TEST_REF                 = $0BC2;
  GL_DITHER                         = $0BD0;
  GL_BLEND_DST                      = $0BE0;
  GL_BLEND_SRC                      = $0BE1;
  GL_BLEND                          = $0BE2;
  GL_LOGIC_OP_MODE                  = $0BF0;
  GL_INDEX_LOGIC_OP                 = $0BF1;
  GL_COLOR_LOGIC_OP                 = $0BF2;
  GL_AUX_BUFFERS                    = $0C00;
  GL_DRAW_BUFFER                    = $0C01;
  GL_READ_BUFFER                    = $0C02;
  GL_SCISSOR_BOX                    = $0C10;
  GL_SCISSOR_TEST                   = $0C11;
  GL_INDEX_CLEAR_VALUE              = $0C20;
  GL_INDEX_WRITEMASK                = $0C21;
  GL_COLOR_CLEAR_VALUE              = $0C22;
  GL_COLOR_WRITEMASK                = $0C23;
  GL_INDEX_MODE                     = $0C30;
  GL_RGBA_MODE                      = $0C31;
  GL_DOUBLEBUFFER                   = $0C32;
  GL_STEREO                         = $0C33;
  GL_RENDER_MODE                    = $0C40;
  GL_PERSPECTIVE_CORRECTION_HINT    = $0C50;
  GL_POINT_SMOOTH_HINT              = $0C51;
  GL_LINE_SMOOTH_HINT               = $0C52;
  GL_POLYGON_SMOOTH_HINT            = $0C53;
  GL_FOG_HINT                       = $0C54;
  GL_TEXTURE_GEN_S                  = $0C60;
  GL_TEXTURE_GEN_T                  = $0C61;
  GL_TEXTURE_GEN_R                  = $0C62;
  GL_TEXTURE_GEN_Q                  = $0C63;
  GL_PIXEL_MAP_I_TO_I               = $0C70;
  GL_PIXEL_MAP_S_TO_S               = $0C71;
  GL_PIXEL_MAP_I_TO_R               = $0C72;
  GL_PIXEL_MAP_I_TO_G               = $0C73;
  GL_PIXEL_MAP_I_TO_B               = $0C74;
  GL_PIXEL_MAP_I_TO_A               = $0C75;
  GL_PIXEL_MAP_R_TO_R               = $0C76;
  GL_PIXEL_MAP_G_TO_G               = $0C77;
  GL_PIXEL_MAP_B_TO_B               = $0C78;
  GL_PIXEL_MAP_A_TO_A               = $0C79;
  GL_PIXEL_MAP_I_TO_I_SIZE          = $0CB0;
  GL_PIXEL_MAP_S_TO_S_SIZE          = $0CB1;
  GL_PIXEL_MAP_I_TO_R_SIZE          = $0CB2;
  GL_PIXEL_MAP_I_TO_G_SIZE          = $0CB3;
  GL_PIXEL_MAP_I_TO_B_SIZE          = $0CB4;
  GL_PIXEL_MAP_I_TO_A_SIZE          = $0CB5;
  GL_PIXEL_MAP_R_TO_R_SIZE          = $0CB6;
  GL_PIXEL_MAP_G_TO_G_SIZE          = $0CB7;
  GL_PIXEL_MAP_B_TO_B_SIZE          = $0CB8;
  GL_PIXEL_MAP_A_TO_A_SIZE          = $0CB9;
  GL_UNPACK_SWAP_BYTES              = $0CF0;
  GL_UNPACK_LSB_FIRST               = $0CF1;
  GL_UNPACK_ROW_LENGTH              = $0CF2;
  GL_UNPACK_SKIP_ROWS               = $0CF3;
  GL_UNPACK_SKIP_PIXELS             = $0CF4;
  GL_UNPACK_ALIGNMENT               = $0CF5;
  GL_PACK_SWAP_BYTES                = $0D00;
  GL_PACK_LSB_FIRST                 = $0D01;
  GL_PACK_ROW_LENGTH                = $0D02;
  GL_PACK_SKIP_ROWS                 = $0D03;
  GL_PACK_SKIP_PIXELS               = $0D04;
  GL_PACK_ALIGNMENT                 = $0D05;
  GL_MAP_COLOR                      = $0D10;
  GL_MAP_STENCIL                    = $0D11;
  GL_INDEX_SHIFT                    = $0D12;
  GL_INDEX_OFFSET                   = $0D13;
  GL_RED_SCALE                      = $0D14;
  GL_RED_BIAS                       = $0D15;
  GL_ZOOM_X                         = $0D16;
  GL_ZOOM_Y                         = $0D17;
  GL_GREEN_SCALE                    = $0D18;
  GL_GREEN_BIAS                     = $0D19;
  GL_BLUE_SCALE                     = $0D1A;
  GL_BLUE_BIAS                      = $0D1B;
  GL_ALPHA_SCALE                    = $0D1C;
  GL_ALPHA_BIAS                     = $0D1D;
  GL_DEPTH_SCALE                    = $0D1E;
  GL_DEPTH_BIAS                     = $0D1F;
  GL_MAX_EVAL_ORDER                 = $0D30;
  GL_MAX_LIGHTS                     = $0D31;
  GL_MAX_CLIP_PLANES                = $0D32;
  GL_MAX_TEXTURE_SIZE               = $0D33;
  GL_MAX_PIXEL_MAP_TABLE            = $0D34;
  GL_MAX_ATTRIB_STACK_DEPTH         = $0D35;
  GL_MAX_MODELVIEW_STACK_DEPTH      = $0D36;
  GL_MAX_NAME_STACK_DEPTH           = $0D37;
  GL_MAX_PROJECTION_STACK_DEPTH     = $0D38;
  GL_MAX_TEXTURE_STACK_DEPTH        = $0D39;
  GL_MAX_VIEWPORT_DIMS              = $0D3A;
  GL_MAX_CLIENT_ATTRIB_STACK_DEPTH  = $0D3B;
  GL_SUBPIXEL_BITS                  = $0D50;
  GL_INDEX_BITS                     = $0D51;
  GL_RED_BITS                       = $0D52;
  GL_GREEN_BITS                     = $0D53;
  GL_BLUE_BITS                      = $0D54;
  GL_ALPHA_BITS                     = $0D55;
  GL_DEPTH_BITS                     = $0D56;
  GL_STENCIL_BITS                   = $0D57;
  GL_ACCUM_RED_BITS                 = $0D58;
  GL_ACCUM_GREEN_BITS               = $0D59;
  GL_ACCUM_BLUE_BITS                = $0D5A;
  GL_ACCUM_ALPHA_BITS               = $0D5B;
  GL_NAME_STACK_DEPTH               = $0D70;
  GL_AUTO_NORMAL                    = $0D80;
  GL_MAP1_COLOR_4                   = $0D90;
  GL_MAP1_INDEX                     = $0D91;
  GL_MAP1_NORMAL                    = $0D92;
  GL_MAP1_TEXTURE_COORD_1           = $0D93;
  GL_MAP1_TEXTURE_COORD_2           = $0D94;
  GL_MAP1_TEXTURE_COORD_3           = $0D95;
  GL_MAP1_TEXTURE_COORD_4           = $0D96;
  GL_MAP1_VERTEX_3                  = $0D97;
  GL_MAP1_VERTEX_4                  = $0D98;
  GL_MAP2_COLOR_4                   = $0DB0;
  GL_MAP2_INDEX                     = $0DB1;
  GL_MAP2_NORMAL                    = $0DB2;
  GL_MAP2_TEXTURE_COORD_1           = $0DB3;
  GL_MAP2_TEXTURE_COORD_2           = $0DB4;
  GL_MAP2_TEXTURE_COORD_3           = $0DB5;
  GL_MAP2_TEXTURE_COORD_4           = $0DB6;
  GL_MAP2_VERTEX_3                  = $0DB7;
  GL_MAP2_VERTEX_4                  = $0DB8;
  GL_MAP1_GRID_DOMAIN               = $0DD0;
  GL_MAP1_GRID_SEGMENTS             = $0DD1;
  GL_MAP2_GRID_DOMAIN               = $0DD2;
  GL_MAP2_GRID_SEGMENTS             = $0DD3;
  GL_TEXTURE_1D                     = $0DE0;
  GL_TEXTURE_2D                     = $0DE1;
  GL_FEEDBACK_BUFFER_POINTER        = $0DF0;
  GL_FEEDBACK_BUFFER_SIZE           = $0DF1;
  GL_FEEDBACK_BUFFER_TYPE           = $0DF2;
  GL_SELECTION_BUFFER_POINTER       = $0DF3;
  GL_SELECTION_BUFFER_SIZE          = $0DF4;
  //      GL_TEXTURE_BINDING_1D
  //      GL_TEXTURE_BINDING_2D
  //      GL_VERTEX_ARRAY
  //      GL_NORMAL_ARRAY
  //      GL_COLOR_ARRAY
  //      GL_INDEX_ARRAY
  //      GL_TEXTURE_COORD_ARRAY
  //      GL_EDGE_FLAG_ARRAY
  //      GL_VERTEX_ARRAY_SIZE
  //      GL_VERTEX_ARRAY_TYPE
  //      GL_VERTEX_ARRAY_STRIDE
  //      GL_NORMAL_ARRAY_TYPE
  //      GL_NORMAL_ARRAY_STRIDE
  //      GL_COLOR_ARRAY_SIZE
  //      GL_COLOR_ARRAY_TYPE
  //      GL_COLOR_ARRAY_STRIDE
  //      GL_INDEX_ARRAY_TYPE
  //      GL_INDEX_ARRAY_STRIDE
  //      GL_TEXTURE_COORD_ARRAY_SIZE
  //      GL_TEXTURE_COORD_ARRAY_TYPE
  //      GL_TEXTURE_COORD_ARRAY_STRIDE
  //      GL_EDGE_FLAG_ARRAY_STRIDE
  //      GL_POLYGON_OFFSET_FACTOR
  //      GL_POLYGON_OFFSET_UNITS

  // GetTextureParameter
  //      GL_TEXTURE_MAG_FILTER
  //      GL_TEXTURE_MIN_FILTER
  //      GL_TEXTURE_WRAP_S
  //      GL_TEXTURE_WRAP_T
  GL_TEXTURE_WIDTH                  = $1000;
  GL_TEXTURE_HEIGHT                 = $1001;
  GL_TEXTURE_INTERNAL_FORMAT        = $1003;
  GL_TEXTURE_BORDER_COLOR           = $1004;
  GL_TEXTURE_BORDER                 = $1005;
  //      GL_TEXTURE_RED_SIZE
  //      GL_TEXTURE_GREEN_SIZE
  //      GL_TEXTURE_BLUE_SIZE
  //      GL_TEXTURE_ALPHA_SIZE
  //      GL_TEXTURE_LUMINANCE_SIZE
  //      GL_TEXTURE_INTENSITY_SIZE
  //      GL_TEXTURE_PRIORITY
  //      GL_TEXTURE_RESIDENT

  // HintMode
  GL_DONT_CARE                      = $1100;
  GL_FASTEST                        = $1101;
  GL_NICEST                         = $1102;

  // HintTarget
  //      GL_PERSPECTIVE_CORRECTION_HINT
  //      GL_POINT_SMOOTH_HINT
  //      GL_LINE_SMOOTH_HINT
  //      GL_POLYGON_SMOOTH_HINT
  //      GL_FOG_HINT

  // IndexPointerType
  //      GL_SHORT
  //      GL_INT
  //      GL_FLOAT
  //      GL_DOUBLE

  // LightModelParameter
  //      GL_LIGHT_MODEL_AMBIENT
  //      GL_LIGHT_MODEL_LOCAL_VIEWER
  //      GL_LIGHT_MODEL_TWO_SIDE

  // LightName
  GL_LIGHT0                         = $4000;
  GL_LIGHT1                         = $4001;
  GL_LIGHT2                         = $4002;
  GL_LIGHT3                         = $4003;
  GL_LIGHT4                         = $4004;
  GL_LIGHT5                         = $4005;
  GL_LIGHT6                         = $4006;
  GL_LIGHT7                         = $4007;

  // LightParameter
  GL_AMBIENT                        = $1200;
  GL_DIFFUSE                        = $1201;
  GL_SPECULAR                       = $1202;
  GL_POSITION                       = $1203;
  GL_SPOT_DIRECTION                 = $1204;
  GL_SPOT_EXPONENT                  = $1205;
  GL_SPOT_CUTOFF                    = $1206;
  GL_CONSTANT_ATTENUATION           = $1207;
  GL_LINEAR_ATTENUATION             = $1208;
  GL_QUADRATIC_ATTENUATION          = $1209;

  // InterleavedArrays
  //      GL_V2F
  //      GL_V3F
  //      GL_C4UB_V2F
  //      GL_C4UB_V3F
  //      GL_C3F_V3F
  //      GL_N3F_V3F
  //      GL_C4F_N3F_V3F
  //      GL_T2F_V3F
  //      GL_T4F_V4F
  //      GL_T2F_C4UB_V3F
  //      GL_T2F_C3F_V3F
  //      GL_T2F_N3F_V3F
  //      GL_T2F_C4F_N3F_V3F
  //      GL_T4F_C4F_N3F_V4F

  // ListMode
  GL_COMPILE                        = $1300;
  GL_COMPILE_AND_EXECUTE            = $1301;

  // ListNameType
  //      GL_BYTE
  //      GL_UNSIGNED_BYTE
  //      GL_SHORT
  //      GL_UNSIGNED_SHORT
  //      GL_INT
  //      GL_UNSIGNED_INT
  //      GL_FLOAT
  //      GL_2_BYTES
  //      GL_3_BYTES
  //      GL_4_BYTES

  // LogicOp
  GL_CLEAR                          = $1500;
  GL_AND                            = $1501;
  GL_AND_REVERSE                    = $1502;
  GL_COPY                           = $1503;
  GL_AND_INVERTED                   = $1504;
  GL_NOOP                           = $1505;
  GL_XOR                            = $1506;
  GL_OR                             = $1507;
  GL_NOR                            = $1508;
  GL_EQUIV                          = $1509;
  GL_INVERT                         = $150A;
  GL_OR_REVERSE                     = $150B;
  GL_COPY_INVERTED                  = $150C;
  GL_OR_INVERTED                    = $150D;
  GL_NAND                           = $150E;
  GL_SET                            = $150F;

  // MapTarget
  //      GL_MAP1_COLOR_4
  //      GL_MAP1_INDEX
  //      GL_MAP1_NORMAL
  //      GL_MAP1_TEXTURE_COORD_1
  //      GL_MAP1_TEXTURE_COORD_2
  //      GL_MAP1_TEXTURE_COORD_3
  //      GL_MAP1_TEXTURE_COORD_4
  //      GL_MAP1_VERTEX_3
  //      GL_MAP1_VERTEX_4
  //      GL_MAP2_COLOR_4
  //      GL_MAP2_INDEX
  //      GL_MAP2_NORMAL
  //      GL_MAP2_TEXTURE_COORD_1
  //      GL_MAP2_TEXTURE_COORD_2
  //      GL_MAP2_TEXTURE_COORD_3
  //      GL_MAP2_TEXTURE_COORD_4
  //      GL_MAP2_VERTEX_3
  //      GL_MAP2_VERTEX_4

  // MaterialFace
  //      GL_FRONT
  //      GL_BACK
  //      GL_FRONT_AND_BACK

  // MaterialParameter
  GL_EMISSION                       = $1600;
  GL_SHININESS                      = $1601;
  GL_AMBIENT_AND_DIFFUSE            = $1602;
  GL_COLOR_INDEXES                  = $1603;
  //      GL_AMBIENT
  //      GL_DIFFUSE
  //      GL_SPECULAR

  // MatrixMode
  GL_MODELVIEW                      = $1700;
  GL_PROJECTION                     = $1701;
  GL_TEXTURE                        = $1702;

  // MeshMode1
  //      GL_POINT
  //      GL_LINE

  // MeshMode2
  //      GL_POINT
  //      GL_LINE
  //      GL_FILL

  // NormalPointerType
  //      GL_BYTE
  //      GL_SHORT
  //      GL_INT
  //      GL_FLOAT
  //      GL_DOUBLE

  // PixelCopyType
  GL_COLOR                          = $1800;
  GL_DEPTH                          = $1801;
  GL_STENCIL                        = $1802;

  // PixelFormat
  GL_COLOR_INDEX                    = $1900;
  GL_STENCIL_INDEX                  = $1901;
  GL_DEPTH_COMPONENT                = $1902;
  GL_RED                            = $1903;
  GL_GREEN                          = $1904;
  GL_BLUE                           = $1905;
  GL_ALPHA                          = $1906;
  GL_RGB                            = $1907;
  GL_RGBA                           = $1908;
  GL_LUMINANCE                      = $1909;
  GL_LUMINANCE_ALPHA                = $190A;

  // PixelMap
  //      GL_PIXEL_MAP_I_TO_I
  //      GL_PIXEL_MAP_S_TO_S
  //      GL_PIXEL_MAP_I_TO_R
  //      GL_PIXEL_MAP_I_TO_G
  //      GL_PIXEL_MAP_I_TO_B
  //      GL_PIXEL_MAP_I_TO_A
  //      GL_PIXEL_MAP_R_TO_R
  //      GL_PIXEL_MAP_G_TO_G
  //      GL_PIXEL_MAP_B_TO_B
  //      GL_PIXEL_MAP_A_TO_A

  // PixelStore
  //      GL_UNPACK_SWAP_BYTES
  //      GL_UNPACK_LSB_FIRST
  //      GL_UNPACK_ROW_LENGTH
  //      GL_UNPACK_SKIP_ROWS
  //      GL_UNPACK_SKIP_PIXELS
  //      GL_UNPACK_ALIGNMENT
  //      GL_PACK_SWAP_BYTES
  //      GL_PACK_LSB_FIRST
  //      GL_PACK_ROW_LENGTH
  //      GL_PACK_SKIP_ROWS
  //      GL_PACK_SKIP_PIXELS
  //      GL_PACK_ALIGNMENT

  // PixelTransfer
  //      GL_MAP_COLOR
  //      GL_MAP_STENCIL
  //      GL_INDEX_SHIFT
  //      GL_INDEX_OFFSET
  //      GL_RED_SCALE
  //      GL_RED_BIAS
  //      GL_GREEN_SCALE
  //      GL_GREEN_BIAS
  //      GL_BLUE_SCALE
  //      GL_BLUE_BIAS
  //      GL_ALPHA_SCALE
  //      GL_ALPHA_BIAS
  //      GL_DEPTH_SCALE
  //      GL_DEPTH_BIAS

  // PixelType
  GL_BITMAP                         = $1A00;
  //      GL_BYTE
  //      GL_UNSIGNED_BYTE
  //      GL_SHORT
  //      GL_UNSIGNED_SHORT
  //      GL_INT
  //      GL_UNSIGNED_INT
  //      GL_FLOAT

  // PolygonMode
  GL_POINT                          = $1B00;
  GL_LINE                           = $1B01;
  GL_FILL                           = $1B02;

  // ReadBufferMode
  //      GL_FRONT_LEFT
  //      GL_FRONT_RIGHT
  //      GL_BACK_LEFT
  //      GL_BACK_RIGHT
  //      GL_FRONT
  //      GL_BACK
  //      GL_LEFT
  //      GL_RIGHT
  //      GL_AUX0
  //      GL_AUX1
  //      GL_AUX2
  //      GL_AUX3

  // RenderingMode
  GL_RENDER                         = $1C00;
  GL_FEEDBACK                       = $1C01;
  GL_SELECT                         = $1C02;

  // ShadingModel
  GL_FLAT                           = $1D00;
  GL_SMOOTH                         = $1D01;

  // StencilFunction
  //      GL_NEVER
  //      GL_LESS
  //      GL_EQUAL
  //      GL_LEQUAL
  //      GL_GREATER
  //      GL_NOTEQUAL
  //      GL_GEQUAL
  //      GL_ALWAYS

  // StencilOp
  //      GL_ZERO
  GL_KEEP                           = $1E00;
  GL_REPLACE                        = $1E01;
  GL_INCR                           = $1E02;
  GL_DECR                           = $1E03;
  //      GL_INVERT

  // StringName
  GL_VENDOR                         = $1F00;
  GL_RENDERER                       = $1F01;
  GL_VERSION                        = $1F02;
  GL_EXTENSIONS                     = $1F03;

  // TextureCoordName
  GL_S                              = $2000;
  GL_T                              = $2001;
  GL_R                              = $2002;
  GL_Q                              = $2003;

  // TexCoordPointerType
  //      GL_SHORT
  //      GL_INT
  //      GL_FLOAT
  //      GL_DOUBLE

  // TextureEnvMode
  GL_MODULATE                       = $2100;
  GL_DECAL                          = $2101;
  //      GL_BLEND
  //      GL_REPLACE

  // TextureEnvParameter
  GL_TEXTURE_ENV_MODE               = $2200;
  GL_TEXTURE_ENV_COLOR              = $2201;

  // TextureEnvTarget
  GL_TEXTURE_ENV                    = $2300;

  // TextureGenMode
  GL_EYE_LINEAR                     = $2400;
  GL_OBJECT_LINEAR                  = $2401;
  GL_SPHERE_MAP                     = $2402;

  // TextureGenParameter
  GL_TEXTURE_GEN_MODE               = $2500;
  GL_OBJECT_PLANE                   = $2501;
  GL_EYE_PLANE                      = $2502;

  // TextureMagFilter
  GL_NEAREST                        = $2600;
  GL_LINEAR                         = $2601;

  // TextureMinFilter
  //      GL_NEAREST
  //      GL_LINEAR
  GL_NEAREST_MIPMAP_NEAREST         = $2700;
  GL_LINEAR_MIPMAP_NEAREST          = $2701;
  GL_NEAREST_MIPMAP_LINEAR          = $2702;
  GL_LINEAR_MIPMAP_LINEAR           = $2703;

  // TextureParameterName
  GL_TEXTURE_MAG_FILTER             = $2800;
  GL_TEXTURE_MIN_FILTER             = $2801;
  GL_TEXTURE_WRAP_S                 = $2802;
  GL_TEXTURE_WRAP_T                 = $2803;
  //      GL_TEXTURE_BORDER_COLOR
  //      GL_TEXTURE_PRIORITY

  // TextureTarget
  //      GL_TEXTURE_1D
  //      GL_TEXTURE_2D
  //      GL_PROXY_TEXTURE_1D
  //      GL_PROXY_TEXTURE_2D

  // TextureWrapMode
  GL_CLAMP                          = $2900;
  GL_REPEAT                         = $2901;

  // VertexPointerType
  //      GL_SHORT
  //      GL_INT
  //      GL_FLOAT
  //      GL_DOUBLE

  // ClientAttribMask
  GL_CLIENT_PIXEL_STORE_BIT         = $00000001;
  GL_CLIENT_VERTEX_ARRAY_BIT        = $00000002;
  GL_CLIENT_ALL_ATTRIB_BITS         = $FFFFFFFF;

  // polygon_offset
  GL_POLYGON_OFFSET_FACTOR          = $8038;
  GL_POLYGON_OFFSET_UNITS           = $2A00;
  GL_POLYGON_OFFSET_POINT           = $2A01;
  GL_POLYGON_OFFSET_LINE            = $2A02;
  GL_POLYGON_OFFSET_FILL            = $8037;

  // texture
  GL_ALPHA4                         = $803B;
  GL_ALPHA8                         = $803C;
  GL_ALPHA12                        = $803D;
  GL_ALPHA16                        = $803E;
  GL_LUMINANCE4                     = $803F;
  GL_LUMINANCE8                     = $8040;
  GL_LUMINANCE12                    = $8041;
  GL_LUMINANCE16                    = $8042;
  GL_LUMINANCE4_ALPHA4              = $8043;
  GL_LUMINANCE6_ALPHA2              = $8044;
  GL_LUMINANCE8_ALPHA8              = $8045;
  GL_LUMINANCE12_ALPHA4             = $8046;
  GL_LUMINANCE12_ALPHA12            = $8047;
  GL_LUMINANCE16_ALPHA16            = $8048;
  GL_INTENSITY                      = $8049;
  GL_INTENSITY4                     = $804A;
  GL_INTENSITY8                     = $804B;
  GL_INTENSITY12                    = $804C;
  GL_INTENSITY16                    = $804D;
  GL_R3_G3_B2                       = $2A10;
  GL_RGB4                           = $804F;
  GL_RGB5                           = $8050;
  GL_RGB8                           = $8051;
  GL_RGB10                          = $8052;
  GL_RGB12                          = $8053;
  GL_RGB16                          = $8054;
  GL_RGBA2                          = $8055;
  GL_RGBA4                          = $8056;
  GL_RGB5_A1                        = $8057;
  GL_RGBA8                          = $8058;
  GL_RGB10_A2                       = $8059;
  GL_RGBA12                         = $805A;
  GL_RGBA16                         = $805B;
  GL_TEXTURE_RED_SIZE               = $805C;
  GL_TEXTURE_GREEN_SIZE             = $805D;
  GL_TEXTURE_BLUE_SIZE              = $805E;
  GL_TEXTURE_ALPHA_SIZE             = $805F;
  GL_TEXTURE_LUMINANCE_SIZE         = $8060;
  GL_TEXTURE_INTENSITY_SIZE         = $8061;
  GL_PROXY_TEXTURE_1D               = $8063;
  GL_PROXY_TEXTURE_2D               = $8064;

  // texture_object
  GL_TEXTURE_PRIORITY               = $8066;
  GL_TEXTURE_RESIDENT               = $8067;
  GL_TEXTURE_BINDING_1D             = $8068;
  GL_TEXTURE_BINDING_2D             = $8069;

  // vertex_array
  GL_VERTEX_ARRAY                   = $8074;
  GL_NORMAL_ARRAY                   = $8075;
  GL_COLOR_ARRAY                    = $8076;
  GL_INDEX_ARRAY                    = $8077;
  GL_TEXTURE_COORD_ARRAY            = $8078;
  GL_EDGE_FLAG_ARRAY                = $8079;
  GL_VERTEX_ARRAY_SIZE              = $807A;
  GL_VERTEX_ARRAY_TYPE              = $807B;
  GL_VERTEX_ARRAY_STRIDE            = $807C;
  GL_NORMAL_ARRAY_TYPE              = $807E;
  GL_NORMAL_ARRAY_STRIDE            = $807F;
  GL_COLOR_ARRAY_SIZE               = $8081;
  GL_COLOR_ARRAY_TYPE               = $8082;
  GL_COLOR_ARRAY_STRIDE             = $8083;
  GL_INDEX_ARRAY_TYPE               = $8085;
  GL_INDEX_ARRAY_STRIDE             = $8086;
  GL_TEXTURE_COORD_ARRAY_SIZE       = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE       = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE     = $808A;
  GL_EDGE_FLAG_ARRAY_STRIDE         = $808C;
  GL_VERTEX_ARRAY_POINTER           = $808E;
  GL_NORMAL_ARRAY_POINTER           = $808F;
  GL_COLOR_ARRAY_POINTER            = $8090;
  GL_INDEX_ARRAY_POINTER            = $8091;
  GL_TEXTURE_COORD_ARRAY_POINTER    = $8092;
  GL_EDGE_FLAG_ARRAY_POINTER        = $8093;
  GL_V2F                            = $2A20;
  GL_V3F                            = $2A21;
  GL_C4UB_V2F                       = $2A22;
  GL_C4UB_V3F                       = $2A23;
  GL_C3F_V3F                        = $2A24;
  GL_N3F_V3F                        = $2A25;
  GL_C4F_N3F_V3F                    = $2A26;
  GL_T2F_V3F                        = $2A27;
  GL_T4F_V4F                        = $2A28;
  GL_T2F_C4UB_V3F                   = $2A29;
  GL_T2F_C3F_V3F                    = $2A2A;
  GL_T2F_N3F_V3F                    = $2A2B;
  GL_T2F_C4F_N3F_V3F                = $2A2C;
  GL_T4F_C4F_N3F_V4F                = $2A2D;

  // Extensions
  GL_EXT_vertex_array               = 1;
  GL_WIN_swap_hint                  = 1;
  GL_EXT_bgra                       = 1;
  GL_EXT_paletted_texture           = 1;

  // EXT_vertex_array
  GL_VERTEX_ARRAY_EXT               = $8074;
  GL_NORMAL_ARRAY_EXT               = $8075;
  GL_COLOR_ARRAY_EXT                = $8076;
  GL_INDEX_ARRAY_EXT                = $8077;
  GL_TEXTURE_COORD_ARRAY_EXT        = $8078;
  GL_EDGE_FLAG_ARRAY_EXT            = $8079;
  GL_VERTEX_ARRAY_SIZE_EXT          = $807A;
  GL_VERTEX_ARRAY_TYPE_EXT          = $807B;
  GL_VERTEX_ARRAY_STRIDE_EXT        = $807C;
  GL_VERTEX_ARRAY_COUNT_EXT         = $807D;
  GL_NORMAL_ARRAY_TYPE_EXT          = $807E;
  GL_NORMAL_ARRAY_STRIDE_EXT        = $807F;
  GL_NORMAL_ARRAY_COUNT_EXT         = $8080;
  GL_COLOR_ARRAY_SIZE_EXT           = $8081;
  GL_COLOR_ARRAY_TYPE_EXT           = $8082;
  GL_COLOR_ARRAY_STRIDE_EXT         = $8083;
  GL_COLOR_ARRAY_COUNT_EXT          = $8084;
  GL_INDEX_ARRAY_TYPE_EXT           = $8085;
  GL_INDEX_ARRAY_STRIDE_EXT         = $8086;
  GL_INDEX_ARRAY_COUNT_EXT          = $8087;
  GL_TEXTURE_COORD_ARRAY_SIZE_EXT   = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE_EXT   = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE_EXT = $808A;
  GL_TEXTURE_COORD_ARRAY_COUNT_EXT  = $808B;
  GL_EDGE_FLAG_ARRAY_STRIDE_EXT     = $808C;
  GL_EDGE_FLAG_ARRAY_COUNT_EXT      = $808D;
  GL_VERTEX_ARRAY_POINTER_EXT       = $808E;
  GL_NORMAL_ARRAY_POINTER_EXT       = $808F;
  GL_COLOR_ARRAY_POINTER_EXT        = $8090;
  GL_INDEX_ARRAY_POINTER_EXT        = $8091;
  GL_TEXTURE_COORD_ARRAY_POINTER_EXT = $8092;
  GL_EDGE_FLAG_ARRAY_POINTER_EXT    = $8093;
  GL_DOUBLE_EXT                     = GL_DOUBLE;

  // EXT_bgra
  GL_BGR_EXT                        = $80E0;
  GL_BGRA_EXT                       = $80E1;

  // EXT_paletted_texture

  // These must match the GL_COLOR_TABLE_*_SGI enumerants
  GL_COLOR_TABLE_FORMAT_EXT         = $80D8;
  GL_COLOR_TABLE_WIDTH_EXT          = $80D9;
  GL_COLOR_TABLE_RED_SIZE_EXT       = $80DA;
  GL_COLOR_TABLE_GREEN_SIZE_EXT     = $80DB;
  GL_COLOR_TABLE_BLUE_SIZE_EXT      = $80DC;
  GL_COLOR_TABLE_ALPHA_SIZE_EXT     = $80DD;
  GL_COLOR_TABLE_LUMINANCE_SIZE_EXT = $80DE;
  GL_COLOR_TABLE_INTENSITY_SIZE_EXT = $80DF;

  GL_COLOR_INDEX1_EXT               = $80E2;
  GL_COLOR_INDEX2_EXT               = $80E3;
  GL_COLOR_INDEX4_EXT               = $80E4;
  GL_COLOR_INDEX8_EXT               = $80E5;
  GL_COLOR_INDEX12_EXT              = $80E6;
  GL_COLOR_INDEX16_EXT              = $80E7;

  // For compatibility with OpenGL v1.0
  GL_LOGIC_OP                       = GL_INDEX_LOGIC_OP;
  GL_TEXTURE_COMPONENTS             = GL_TEXTURE_INTERNAL_FORMAT;

{******************************************************************************}

{$IFDEF MORPHOS}

{ MorphOS GL works differently due to different dynamic-library handling on Amiga-like }
{ systems, so its headers are included here. }
{$INCLUDE tinyglh.inc}

{$ELSE MORPHOS}
var
  glAccum: procedure(op: GLenum; value: GLfloat); extdecl;
  glAlphaFunc: procedure(func: GLenum; ref: GLclampf); extdecl;
  glAreTexturesResident: function (n: GLsizei; const textures: PGLuint; residences: PGLboolean): GLboolean; extdecl;
  glArrayElement: procedure(i: GLint); extdecl;
  glBegin: procedure(mode: GLenum); extdecl;
  glBindTexture: procedure(target: GLenum; texture: GLuint); extdecl;
  glBitmap: procedure (width, height: GLsizei; xorig, yorig: GLfloat; xmove, ymove: GLfloat; const bitmap: PGLubyte); extdecl;
  glBlendFunc: procedure(sfactor, dfactor: GLenum); extdecl;
  glCallList: procedure(list: GLuint); extdecl;
  glCallLists: procedure(n: GLsizei; atype: GLenum; const lists: Pointer); extdecl;
  glClear: procedure(mask: GLbitfield); extdecl;
  glClearAccum: procedure(red, green, blue, alpha: GLfloat); extdecl;
  glClearColor: procedure(red, green, blue, alpha: GLclampf); extdecl;
  glClearDepth: procedure(depth: GLclampd); extdecl;
  glClearIndex: procedure(c: GLfloat); extdecl;
  glClearStencil: procedure(s: GLint); extdecl;
  glClipPlane: procedure(plane: GLenum; const equation: PGLdouble); extdecl;
  glColor3b: procedure(red, green, blue: GLbyte); extdecl;
  glColor3bv: procedure(const v: PGLbyte); extdecl;
  glColor3d: procedure(red, green, blue: GLdouble); extdecl;
  glColor3dv: procedure(const v: PGLdouble); extdecl;
  glColor3f: procedure(red, green, blue: GLfloat); extdecl;
  glColor3fv: procedure(const v: PGLfloat); extdecl;
  glColor3i: procedure(red, green, blue: GLint); extdecl;
  glColor3iv: procedure(const v: PGLint); extdecl;
  glColor3s: procedure(red, green, blue: GLshort); extdecl;
  glColor3sv: procedure(const v: PGLshort); extdecl;
  glColor3ub: procedure(red, green, blue: GLubyte); extdecl;
  glColor3ubv: procedure(const v: PGLubyte); extdecl;
  glColor3ui: procedure(red, green, blue: GLuint); extdecl;
  glColor3uiv: procedure(const v: PGLuint); extdecl;
  glColor3us: procedure(red, green, blue: GLushort); extdecl;
  glColor3usv: procedure(const v: PGLushort); extdecl;
  glColor4b: procedure(red, green, blue, alpha: GLbyte); extdecl;
  glColor4bv: procedure(const v: PGLbyte); extdecl;
  glColor4d: procedure(red, green, blue, alpha: GLdouble); extdecl;
  glColor4dv: procedure(const v: PGLdouble); extdecl;
  glColor4f: procedure(red, green, blue, alpha: GLfloat); extdecl;
  glColor4fv: procedure(const v: PGLfloat); extdecl;
  glColor4i: procedure(red, green, blue, alpha: GLint); extdecl;
  glColor4iv: procedure(const v: PGLint); extdecl;
  glColor4s: procedure(red, green, blue, alpha: GLshort); extdecl;
  glColor4sv: procedure(const v: PGLshort); extdecl;
  glColor4ub: procedure(red, green, blue, alpha: GLubyte); extdecl;
  glColor4ubv: procedure(const v: PGLubyte); extdecl;
  glColor4ui: procedure(red, green, blue, alpha: GLuint); extdecl;
  glColor4uiv: procedure(const v: PGLuint); extdecl;
  glColor4us: procedure(red, green, blue, alpha: GLushort); extdecl;
  glColor4usv: procedure(const v: PGLushort); extdecl;
  glColorMask: procedure(red, green, blue, alpha: GLboolean); extdecl;
  glColorMaterial: procedure(face, mode: GLenum); extdecl;
  glColorPointer: procedure(size: GLint; atype: GLenum; stride: GLsizei; const pointer: Pointer); extdecl;
  glCopyPixels: procedure(x, y: GLint; width, height: GLsizei; atype: GLenum); extdecl;
  glCopyTexImage1D: procedure (target: GLenum; level: GLint; internalFormat: GLenum; x, y: GLint; width: GLsizei; border: GLint); extdecl;
  glCopyTexImage2D: procedure(target: GLenum; level: GLint; internalFormat: GLenum; x, y: GLint; width, height: GLsizei; border: GLint); extdecl;
  glCopyTexSubImage1D: procedure(target: GLenum; level, xoffset, x, y: GLint; width: GLsizei); extdecl;
  glCopyTexSubImage2D: procedure(target: GLenum; level, xoffset, yoffset, x, y: GLint; width, height: GLsizei); extdecl;
  glCullFace: procedure(mode: GLenum); extdecl;
  glDeleteLists: procedure(list: GLuint; range: GLsizei); extdecl;
  glDeleteTextures: procedure(n: GLsizei; const textures: PGLuint); extdecl;
  glDepthFunc: procedure(func: GLenum); extdecl;
  glDepthMask: procedure(flag: GLboolean); extdecl;
  glDepthRange: procedure(zNear, zFar: GLclampd); extdecl;
  glDisable: procedure(cap: GLenum); extdecl;
  glDisableClientState: procedure(aarray: GLenum); extdecl;
  glDrawArrays: procedure(mode: GLenum; first: GLint; count: GLsizei); extdecl;
  glDrawBuffer: procedure(mode: GLenum); extdecl;
  glDrawElements: procedure(mode: GLenum; count: GLsizei; atype: GLenum; const indices: Pointer); extdecl;
  glDrawPixels: procedure(width, height: GLsizei; format, atype: GLenum; const pixels: Pointer); extdecl;
  glEdgeFlag: procedure(flag: GLboolean); extdecl;
  glEdgeFlagPointer: procedure(stride: GLsizei; const pointer: Pointer); extdecl;
  glEdgeFlagv: procedure(const flag: PGLboolean); extdecl;
  glEnable: procedure(cap: GLenum); extdecl;
  glEnableClientState: procedure(aarray: GLenum); extdecl;
  glEnd: procedure; extdecl;
  glEndList: procedure; extdecl;
  glEvalCoord1d: procedure(u: GLdouble); extdecl;
  glEvalCoord1dv: procedure(const u: PGLdouble); extdecl;
  glEvalCoord1f: procedure(u: GLfloat); extdecl;
  glEvalCoord1fv: procedure(const u: PGLfloat); extdecl;
  glEvalCoord2d: procedure(u, v: GLdouble); extdecl;
  glEvalCoord2dv: procedure(const u: PGLdouble); extdecl;
  glEvalCoord2f: procedure(u, v: GLfloat); extdecl;
  glEvalCoord2fv: procedure(const u: PGLfloat); extdecl;
  glEvalMesh1: procedure(mode: GLenum; i1, i2: GLint); extdecl;
  glEvalMesh2: procedure(mode: GLenum; i1, i2, j1, j2: GLint); extdecl;
  glEvalPoint1: procedure(i: GLint); extdecl;
  glEvalPoint2: procedure(i, j: GLint); extdecl;
  glFeedbackBuffer: procedure(size: GLsizei; atype: GLenum; buffer: PGLfloat); extdecl;
  glFinish: procedure; extdecl;
  glFlush: procedure; extdecl;
  glFogf: procedure(pname: GLenum; param: GLfloat); extdecl;
  glFogfv: procedure(pname: GLenum; const params: PGLfloat); extdecl;
  glFogi: procedure(pname: GLenum; param: GLint); extdecl;
  glFogiv: procedure(pname: GLenum; const params: PGLint); extdecl;
  glFrontFace: procedure(mode: GLenum); extdecl;
  glFrustum: procedure(left, right, bottom, top, zNear, zFar: GLdouble); extdecl;
  glGenLists: function(range: GLsizei): GLuint; extdecl;
  glGenTextures: procedure(n: GLsizei; textures: PGLuint); extdecl;
  glGetBooleanv: procedure(pname: GLenum; params: PGLboolean); extdecl;
  glGetClipPlane: procedure(plane: GLenum; equation: PGLdouble); extdecl;
  glGetDoublev: procedure(pname: GLenum; params: PGLdouble); extdecl;
  glGetError: function: GLenum; extdecl;
  glGetFloatv: procedure(pname: GLenum; params: PGLfloat); extdecl;
  glGetIntegerv: procedure(pname: GLenum; params: PGLint); extdecl;
  glGetLightfv: procedure(light, pname: GLenum; params: PGLfloat); extdecl;
  glGetLightiv: procedure(light, pname: GLenum; params: PGLint); extdecl;
  glGetMapdv: procedure(target, query: GLenum; v: PGLdouble); extdecl;
  glGetMapfv: procedure(target, query: GLenum; v: PGLfloat); extdecl;
  glGetMapiv: procedure(target, query: GLenum; v: PGLint); extdecl;
  glGetMaterialfv: procedure(face, pname: GLenum; params: PGLfloat); extdecl;
  glGetMaterialiv: procedure(face, pname: GLenum; params: PGLint); extdecl;
  glGetPixelMapfv: procedure(map: GLenum; values: PGLfloat); extdecl;
  glGetPixelMapuiv: procedure(map: GLenum; values: PGLuint); extdecl;
  glGetPixelMapusv: procedure(map: GLenum; values: PGLushort); extdecl;
  glGetPointerv: procedure(pname: GLenum; params: Pointer); extdecl;
  glGetPolygonStipple: procedure(mask: PGLubyte); extdecl;
  glGetString: function(name: GLenum): PChar; extdecl;
  glGetTexEnvfv: procedure(target, pname: GLenum; params: PGLfloat); extdecl;
  glGetTexEnviv: procedure(target, pname: GLenum; params: PGLint); extdecl;
  glGetTexGendv: procedure(coord, pname: GLenum; params: PGLdouble); extdecl;
  glGetTexGenfv: procedure(coord, pname: GLenum; params: PGLfloat); extdecl;
  glGetTexGeniv: procedure(coord, pname: GLenum; params: PGLint); extdecl;
  glGetTexImage: procedure(target: GLenum; level: GLint; format: GLenum; atype: GLenum; pixels: Pointer); extdecl;
  glGetTexLevelParameterfv: procedure(target: GLenum; level: GLint; pname: GLenum; params: Pointer); extdecl;
  glGetTexLevelParameteriv: procedure(target: GLenum; level: GLint; pname: GLenum; params: PGLint); extdecl;
  glGetTexParameterfv: procedure(target, pname: GLenum; params: PGLfloat); extdecl;
  glGetTexParameteriv: procedure(target, pname: GLenum; params: PGLint); extdecl;
  glHint: procedure(target, mode: GLenum); extdecl;
  glIndexMask: procedure(mask: GLuint); extdecl;
  glIndexPointer: procedure(atype: GLenum; stride: GLsizei; const pointer: Pointer); extdecl;
  glIndexd: procedure(c: GLdouble); extdecl;
  glIndexdv: procedure(const c: PGLdouble); extdecl;
  glIndexf: procedure(c: GLfloat); extdecl;
  glIndexfv: procedure(const c: PGLfloat); extdecl;
  glIndexi: procedure(c: GLint); extdecl;
  glIndexiv: procedure(const c: PGLint); extdecl;
  glIndexs: procedure(c: GLshort); extdecl;
  glIndexsv: procedure(const c: PGLshort); extdecl;
  glIndexub: procedure(c: GLubyte); extdecl;
  glIndexubv: procedure(const c: PGLubyte); extdecl;
  glInitNames: procedure; extdecl;
  glInterleavedArrays: procedure(format: GLenum; stride: GLsizei; const pointer: Pointer); extdecl;
  glIsEnabled: function(cap: GLenum): GLboolean; extdecl;
  glIsList: function(list: GLuint): GLboolean; extdecl;
  glIsTexture: function(texture: GLuint): GLboolean; extdecl;
  glLightModelf: procedure(pname: GLenum; param: GLfloat); extdecl;
  glLightModelfv: procedure(pname: GLenum; const params: PGLfloat); extdecl;
  glLightModeli: procedure(pname: GLenum; param: GLint); extdecl;
  glLightModeliv: procedure(pname: GLenum; const params: PGLint); extdecl;
  glLightf: procedure(light, pname: GLenum; param: GLfloat); extdecl;
  glLightfv: procedure(light, pname: GLenum; const params: PGLfloat); extdecl;
  glLighti: procedure(light, pname: GLenum; param: GLint); extdecl;
  glLightiv: procedure(light, pname: GLenum; const params: PGLint); extdecl;
  glLineStipple: procedure(factor: GLint; pattern: GLushort); extdecl;
  glLineWidth: procedure(width: GLfloat); extdecl;
  glListBase: procedure(base: GLuint); extdecl;
  glLoadIdentity: procedure; extdecl;
  glLoadMatrixd: procedure(const m: PGLdouble); extdecl;
  glLoadMatrixf: procedure(const m: PGLfloat); extdecl;
  glLoadName: procedure(name: GLuint); extdecl;
  glLogicOp: procedure(opcode: GLenum); extdecl;
  glMap1d: procedure(target: GLenum; u1, u2: GLdouble; stride, order: GLint; const points: PGLdouble); extdecl;
  glMap1f: procedure(target: GLenum; u1, u2: GLfloat; stride, order: GLint; const points: PGLfloat); extdecl;
  glMap2d: procedure(target: GLenum; u1, u2: GLdouble; ustride, uorder: GLint; v1, v2: GLdouble; vstride, vorder: GLint; const points: PGLdouble); extdecl;
  glMap2f: procedure(target: GLenum; u1, u2: GLfloat; ustride, uorder: GLint; v1, v2: GLfloat; vstride, vorder: GLint; const points: PGLfloat); extdecl;
  glMapGrid1d: procedure(un: GLint; u1, u2: GLdouble); extdecl;
  glMapGrid1f: procedure(un: GLint; u1, u2: GLfloat); extdecl;
  glMapGrid2d: procedure(un: GLint; u1, u2: GLdouble; vn: GLint; v1, v2: GLdouble); extdecl;
  glMapGrid2f: procedure(un: GLint; u1, u2: GLfloat; vn: GLint; v1, v2: GLfloat); extdecl;
  glMaterialf: procedure(face, pname: GLenum; param: GLfloat); extdecl;
  glMaterialfv: procedure(face, pname: GLenum; const params: PGLfloat); extdecl;
  glMateriali: procedure(face, pname: GLenum; param: GLint); extdecl;
  glMaterialiv: procedure(face, pname: GLenum; const params: PGLint); extdecl;
  glMatrixMode: procedure(mode: GLenum); extdecl;
  glMultMatrixd: procedure(const m: PGLdouble); extdecl;
  glMultMatrixf: procedure(const m: PGLfloat); extdecl;
  glNewList: procedure(list: GLuint; mode: GLenum); extdecl;
  glNormal3b: procedure(nx, ny, nz: GLbyte); extdecl;
  glNormal3bv: procedure(const v: PGLbyte); extdecl;
  glNormal3d: procedure(nx, ny, nz: GLdouble); extdecl;
  glNormal3dv: procedure(const v: PGLdouble); extdecl;
  glNormal3f: procedure(nx, ny, nz: GLfloat); extdecl;
  glNormal3fv: procedure(const v: PGLfloat); extdecl;
  glNormal3i: procedure(nx, ny, nz: GLint); extdecl;
  glNormal3iv: procedure(const v: PGLint); extdecl;
  glNormal3s: procedure(nx, ny, nz: GLshort); extdecl;
  glNormal3sv: procedure(const v: PGLshort); extdecl;
  glNormalPointer: procedure(atype: GLenum; stride: GLsizei; const pointer: Pointer); extdecl;
  glOrtho: procedure(left, right, bottom, top, zNear, zFar: GLdouble); extdecl;
  glPassThrough: procedure(token: GLfloat); extdecl;
  glPixelMapfv: procedure(map: GLenum; mapsize: GLsizei; const values: PGLfloat); extdecl;
  glPixelMapuiv: procedure(map: GLenum; mapsize: GLsizei; const values: PGLuint); extdecl;
  glPixelMapusv: procedure(map: GLenum; mapsize: GLsizei; const values: PGLushort); extdecl;
  glPixelStoref: procedure(pname: GLenum; param: GLfloat); extdecl;
  glPixelStorei: procedure(pname: GLenum; param: GLint); extdecl;
  glPixelTransferf: procedure(pname: GLenum; param: GLfloat); extdecl;
  glPixelTransferi: procedure(pname: GLenum; param: GLint); extdecl;
  glPixelZoom: procedure(xfactor, yfactor: GLfloat); extdecl;
  glPointSize: procedure(size: GLfloat); extdecl;
  glPolygonMode: procedure(face, mode: GLenum); extdecl;
  glPolygonOffset: procedure(factor, units: GLfloat); extdecl;
  glPolygonStipple: procedure(const mask: PGLubyte); extdecl;
  glPopAttrib: procedure; extdecl;
  glPopClientAttrib: procedure; extdecl;
  glPopMatrix: procedure; extdecl;
  glPopName: procedure; extdecl;
  glPrioritizeTextures: procedure(n: GLsizei; const textures: PGLuint; const priorities: PGLclampf); extdecl;
  glPushAttrib: procedure(mask: GLbitfield); extdecl;
  glPushClientAttrib: procedure(mask: GLbitfield); extdecl;
  glPushMatrix: procedure; extdecl;
  glPushName: procedure(name: GLuint); extdecl;
  glRasterPos2d: procedure(x, y: GLdouble); extdecl;
  glRasterPos2dv: procedure(const v: PGLdouble); extdecl;
  glRasterPos2f: procedure(x, y: GLfloat); extdecl;
  glRasterPos2fv: procedure(const v: PGLfloat); extdecl;
  glRasterPos2i: procedure(x, y: GLint); extdecl;
  glRasterPos2iv: procedure(const v: PGLint); extdecl;
  glRasterPos2s: procedure(x, y: GLshort); extdecl;
  glRasterPos2sv: procedure(const v: PGLshort); extdecl;
  glRasterPos3d: procedure(x, y, z: GLdouble); extdecl;
  glRasterPos3dv: procedure(const v: PGLdouble); extdecl;
  glRasterPos3f: procedure(x, y, z: GLfloat); extdecl;
  glRasterPos3fv: procedure(const v: PGLfloat); extdecl;
  glRasterPos3i: procedure(x, y, z: GLint); extdecl;
  glRasterPos3iv: procedure(const v: PGLint); extdecl;
  glRasterPos3s: procedure(x, y, z: GLshort); extdecl;
  glRasterPos3sv: procedure(const v: PGLshort); extdecl;
  glRasterPos4d: procedure(x, y, z, w: GLdouble); extdecl;
  glRasterPos4dv: procedure(const v: PGLdouble); extdecl;
  glRasterPos4f: procedure(x, y, z, w: GLfloat); extdecl;
  glRasterPos4fv: procedure(const v: PGLfloat); extdecl;
  glRasterPos4i: procedure(x, y, z, w: GLint); extdecl;
  glRasterPos4iv: procedure(const v: PGLint); extdecl;
  glRasterPos4s: procedure(x, y, z, w: GLshort); extdecl;
  glRasterPos4sv: procedure(const v: PGLshort); extdecl;
  glReadBuffer: procedure(mode: GLenum); extdecl;
  glReadPixels: procedure(x, y: GLint; width, height: GLsizei; format, atype: GLenum; pixels: Pointer); extdecl;
  glRectd: procedure(x1, y1, x2, y2: GLdouble); extdecl;
  glRectdv: procedure(const v1: PGLdouble; const v2: PGLdouble); extdecl;
  glRectf: procedure(x1, y1, x2, y2: GLfloat); extdecl;
  glRectfv: procedure(const v1: PGLfloat; const v2: PGLfloat); extdecl;
  glRecti: procedure(x1, y1, x2, y2: GLint); extdecl;
  glRectiv: procedure(const v1: PGLint; const v2: PGLint); extdecl;
  glRects: procedure(x1, y1, x2, y2: GLshort); extdecl;
  glRectsv: procedure(const v1: PGLshort; const v2: PGLshort); extdecl;
  glRenderMode: function(mode: GLint): GLint; extdecl;
  glRotated: procedure(angle, x, y, z: GLdouble); extdecl;
  glRotatef: procedure(angle, x, y, z: GLfloat); extdecl;
  glScaled: procedure(x, y, z: GLdouble); extdecl;
  glScalef: procedure(x, y, z: GLfloat); extdecl;
  glScissor: procedure(x, y: GLint; width, height: GLsizei); extdecl;
  glSelectBuffer: procedure(size: GLsizei; buffer: PGLuint); extdecl;
  glShadeModel: procedure(mode: GLenum); extdecl;
  glStencilFunc: procedure(func: GLenum; ref: GLint; mask: GLuint); extdecl;
  glStencilMask: procedure(mask: GLuint); extdecl;
  glStencilOp: procedure(fail, zfail, zpass: GLenum); extdecl;
  glTexCoord1d: procedure(s: GLdouble); extdecl;
  glTexCoord1dv: procedure(const v: PGLdouble); extdecl;
  glTexCoord1f: procedure(s: GLfloat); extdecl;
  glTexCoord1fv: procedure(const v: PGLfloat); extdecl;
  glTexCoord1i: procedure(s: GLint); extdecl;
  glTexCoord1iv: procedure(const v: PGLint); extdecl;
  glTexCoord1s: procedure(s: GLshort); extdecl;
  glTexCoord1sv: procedure(const v: PGLshort); extdecl;
  glTexCoord2d: procedure(s, t: GLdouble); extdecl;
  glTexCoord2dv: procedure(const v: PGLdouble); extdecl;
  glTexCoord2f: procedure(s, t: GLfloat); extdecl;
  glTexCoord2fv: procedure(const v: PGLfloat); extdecl;
  glTexCoord2i: procedure(s, t: GLint); extdecl;
  glTexCoord2iv: procedure(const v: PGLint); extdecl;
  glTexCoord2s: procedure(s, t: GLshort); extdecl;
  glTexCoord2sv: procedure(const v: PGLshort); extdecl;
  glTexCoord3d: procedure(s, t, r: GLdouble); extdecl;
  glTexCoord3dv: procedure(const v: PGLdouble); extdecl;
  glTexCoord3f: procedure(s, t, r: GLfloat); extdecl;
  glTexCoord3fv: procedure(const v: PGLfloat); extdecl;
  glTexCoord3i: procedure(s, t, r: GLint); extdecl;
  glTexCoord3iv: procedure(const v: PGLint); extdecl;
  glTexCoord3s: procedure(s, t, r: GLshort); extdecl;
  glTexCoord3sv: procedure(const v: PGLshort); extdecl;
  glTexCoord4d: procedure(s, t, r, q: GLdouble); extdecl;
  glTexCoord4dv: procedure(const v: PGLdouble); extdecl;
  glTexCoord4f: procedure(s, t, r, q: GLfloat); extdecl;
  glTexCoord4fv: procedure(const v: PGLfloat); extdecl;
  glTexCoord4i: procedure(s, t, r, q: GLint); extdecl;
  glTexCoord4iv: procedure(const v: PGLint); extdecl;
  glTexCoord4s: procedure(s, t, r, q: GLshort); extdecl;
  glTexCoord4sv: procedure(const v: PGLshort); extdecl;
  glTexCoordPointer: procedure(size: GLint; atype: GLenum; stride: GLsizei; const pointer: Pointer); extdecl;
  glTexEnvf: procedure(target: GLenum; pname: GLenum; param: GLfloat); extdecl;
  glTexEnvfv: procedure(target: GLenum; pname: GLenum; const params: PGLfloat); extdecl;
  glTexEnvi: procedure(target: GLenum; pname: GLenum; param: GLint); extdecl;
  glTexEnviv: procedure(target: GLenum; pname: GLenum; const params: PGLint); extdecl;
  glTexGend: procedure(coord: GLenum; pname: GLenum; param: GLdouble); extdecl;
  glTexGendv: procedure(coord: GLenum; pname: GLenum; const params: PGLdouble); extdecl;
  glTexGenf: procedure(coord: GLenum; pname: GLenum; param: GLfloat); extdecl;
  glTexGenfv: procedure(coord: GLenum; pname: GLenum; const params: PGLfloat); extdecl;
  glTexGeni: procedure(coord: GLenum; pname: GLenum; param: GLint); extdecl;
  glTexGeniv: procedure(coord: GLenum; pname: GLenum; const params: PGLint); extdecl;
  glTexImage1D: procedure(target: GLenum; level, internalformat: GLint; width: GLsizei; border: GLint; format, atype: GLenum; const pixels: Pointer); extdecl;
  glTexImage2D: procedure(target: GLenum; level, internalformat: GLint; width, height: GLsizei; border: GLint; format, atype: GLenum; const pixels: Pointer); extdecl;
  glTexParameterf: procedure(target: GLenum; pname: GLenum; param: GLfloat); extdecl;
  glTexParameterfv: procedure(target: GLenum; pname: GLenum; const params: PGLfloat); extdecl;
  glTexParameteri: procedure(target: GLenum; pname: GLenum; param: GLint); extdecl;
  glTexParameteriv: procedure(target: GLenum; pname: GLenum; const params: PGLint); extdecl;
  glTexSubImage1D: procedure(target: GLenum; level, xoffset: GLint; width: GLsizei; format, atype: GLenum; const pixels: Pointer); extdecl;
  glTexSubImage2D: procedure(target: GLenum; level, xoffset, yoffset: GLint; width, height: GLsizei; format, atype: GLenum; const pixels: Pointer); extdecl;
  glTranslated: procedure(x, y, z: GLdouble); extdecl;
  glTranslatef: procedure(x, y, z: GLfloat); extdecl;
  glVertex2d: procedure(x, y: GLdouble); extdecl;
  glVertex2dv: procedure(const v: PGLdouble); extdecl;
  glVertex2f: procedure(x, y: GLfloat); extdecl;
  glVertex2fv: procedure(const v: PGLfloat); extdecl;
  glVertex2i: procedure(x, y: GLint); extdecl;
  glVertex2iv: procedure(const v: PGLint); extdecl;
  glVertex2s: procedure(x, y: GLshort); extdecl;
  glVertex2sv: procedure(const v: PGLshort); extdecl;
  glVertex3d: procedure(x, y, z: GLdouble); extdecl;
  glVertex3dv: procedure(const v: PGLdouble); extdecl;
  glVertex3f: procedure(x, y, z: GLfloat); extdecl;
  glVertex3fv: procedure(const v: PGLfloat); extdecl;
  glVertex3i: procedure(x, y, z: GLint); extdecl;
  glVertex3iv: procedure(const v: PGLint); extdecl;
  glVertex3s: procedure(x, y, z: GLshort); extdecl;
  glVertex3sv: procedure(const v: PGLshort); extdecl;
  glVertex4d: procedure(x, y, z, w: GLdouble); extdecl;
  glVertex4dv: procedure(const v: PGLdouble); extdecl;
  glVertex4f: procedure(x, y, z, w: GLfloat); extdecl;
  glVertex4fv: procedure(const v: PGLfloat); extdecl;
  glVertex4i: procedure(x, y, z, w: GLint); extdecl;
  glVertex4iv: procedure(const v: PGLint); extdecl;
  glVertex4s: procedure(x, y, z, w: GLshort); extdecl;
  glVertex4sv: procedure(const v: PGLshort); extdecl;
  glVertexPointer: procedure(size: GLint; atype: GLenum; stride: GLsizei; const pointer: Pointer); extdecl;
  glViewport: procedure(x, y: GLint; width, height: GLsizei); extdecl;
  {$IFDEF Windows}
  ChoosePixelFormat: function(DC: HDC; p2: PPixelFormatDescriptor): Integer; extdecl;
  {$ENDIF}
{$ENDIF MORPHOS}

type
  // EXT_vertex_array
  PFNGLARRAYELEMENTEXTPROC = procedure(i: GLint); extdecl;
  PFNGLDRAWARRAYSEXTPROC = procedure(mode: GLenum; first: GLint; count: GLsizei); extdecl;
  PFNGLVERTEXPOINTEREXTPROC = procedure(size: GLint; atype: GLenum;
                                        stride, count: GLsizei; const pointer: Pointer); extdecl;
  PFNGLNORMALPOINTEREXTPROC = procedure(atype: GLenum; stride, count: GLsizei;
                                        const pointer: Pointer); extdecl;
  PFNGLCOLORPOINTEREXTPROC = procedure(size: GLint; atype: GLenum; stride, count: GLsizei;
                                       const pointer: Pointer); extdecl;
  PFNGLINDEXPOINTEREXTPROC = procedure(atype: GLenum; stride, count: GLsizei;
                                       const pointer: Pointer); extdecl;
  PFNGLTEXCOORDPOINTEREXTPROC = procedure(size: GLint; atype: GLenum;
                                          stride, count: GLsizei; const pointer: Pointer); extdecl;
  PFNGLEDGEFLAGPOINTEREXTPROC = procedure(stride, count: GLsizei;
                                          const pointer: PGLboolean); extdecl;
  PFNGLGETPOINTERVEXTPROC = procedure(pname: GLenum; params: Pointer); extdecl;
  PFNGLARRAYELEMENTARRAYEXTPROC = procedure(mode: GLenum; count: GLsizei;
                                            const pi: Pointer); extdecl;

  // WIN_swap_hint
  PFNGLADDSWAPHINTRECTWINPROC = procedure(x, y: GLint; width, height: GLsizei); extdecl;

  // EXT_paletted_texture
  PFNGLCOLORTABLEEXTPROC = procedure(target, internalFormat: GLenum; width: GLsizei;
                                     format, atype: GLenum; const data: Pointer); extdecl;
  PFNGLCOLORSUBTABLEEXTPROC = procedure(target: GLenum; start, count: GLsizei;
                                        format, atype: GLenum; const data: Pointer); extdecl;
  PFNGLGETCOLORTABLEEXTPROC = procedure(target, format, atype: GLenum; data: Pointer); extdecl;
  PFNGLGETCOLORTABLEPARAMETERIVEXTPROC = procedure(target, pname: GLenum; params: PGLint); extdecl;
  PFNGLGETCOLORTABLEPARAMETERFVEXTPROC = procedure(target, pname: GLenum; params: PGLfloat); extdecl;

//procedure LoadOpenGL(const dll: String);
//procedure FreeOpenGL;

procedure initializeopengl(const sonames: array of filenamety); //[] = default
procedure releaseopengl;
procedure regglinit(const initproc: dynlibprocty);
procedure reggldeinit(const deinitproc: dynlibprocty);
 
implementation
uses
{$if defined(cpui386) or defined(cpux86_64)}
  math,
{$endif}
  msesys,msetypes,msedatalist{$ifdef mswindows}{$else}{$endif};

{$ifdef mswindows}
function WinChoosePixelFormat(DC: HDC; p2: PPixelFormatDescriptor): Integer;
                           extdecl; external 'gdi32' name 'ChoosePixelFormat';
{$endif}

var
 libinfo: dynlibinfoty;

procedure regglinit(const initproc: dynlibprocty);
begin
 regdynlibinit(libinfo,initproc);
end;

procedure reggldeinit(const deinitproc: dynlibprocty);
begin
 regdynlibdeinit(libinfo,deinitproc);
end;
 
procedure init;
begin
  { according to bug 7570, this is necessary on all x86 platforms,
    maybe we've to fix the sse control word as well }
  { Yes, at least for darwin/x86_64 (JM) }
{$if defined(cpui386) or defined(cpux86_64)}
 SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,exOverflow,
                                                    exUnderflow, exPrecision]);
{$endif}
{$ifdef mswindows}
{$else}
 if not mseglloadextensions([gle_glx]) then begin
  raise exception.create('Can not load glx.');
 end;
{$endif}
 mseglloadextensions([gle_gl_version_1_5]);
end;

procedure deinit;
begin
end;

procedure initializeopengl(const sonames: array of filenamety); //[] = default
const
 funcs: array[0..335] of funcinfoty = (
    (n: 'glAccum'; d: @glAccum),
    (n: 'glAlphaFunc'; d: @glAlphaFunc),
    (n: 'glAreTexturesResident'; d: @glAreTexturesResident),
    (n: 'glArrayElement'; d: @glArrayElement),
    (n: 'glBegin'; d: @glBegin),
    (n: 'glBindTexture'; d: @glBindTexture),
    (n: 'glBitmap'; d: @glBitmap),
    (n: 'glBlendFunc'; d: @glBlendFunc),
    (n: 'glCallList'; d: @glCallList),
    (n: 'glCallLists'; d: @glCallLists),
    (n: 'glClear'; d: @glClear),
    (n: 'glClearAccum'; d: @glClearAccum),
    (n: 'glClearColor'; d: @glClearColor),
    (n: 'glClearDepth'; d: @glClearDepth),
    (n: 'glClearIndex'; d: @glClearIndex),
    (n: 'glClearStencil'; d: @glClearStencil),
    (n: 'glClipPlane'; d: @glClipPlane),
    (n: 'glColor3b'; d: @glColor3b),
    (n: 'glColor3bv'; d: @glColor3bv),
    (n: 'glColor3d'; d: @glColor3d),
    (n: 'glColor3dv'; d: @glColor3dv),
    (n: 'glColor3f'; d: @glColor3f),
    (n: 'glColor3fv'; d: @glColor3fv),
    (n: 'glColor3i'; d: @glColor3i),
    (n: 'glColor3iv'; d: @glColor3iv),
    (n: 'glColor3s'; d: @glColor3s),
    (n: 'glColor3sv'; d: @glColor3sv),
    (n: 'glColor3ub'; d: @glColor3ub),
    (n: 'glColor3ubv'; d: @glColor3ubv),
    (n: 'glColor3ui'; d: @glColor3ui),
    (n: 'glColor3uiv'; d: @glColor3uiv),
    (n: 'glColor3us'; d: @glColor3us),
    (n: 'glColor3usv'; d: @glColor3usv),
    (n: 'glColor4b'; d: @glColor4b),
    (n: 'glColor4bv'; d: @glColor4bv),
    (n: 'glColor4d'; d: @glColor4d),
    (n: 'glColor4dv'; d: @glColor4dv),
    (n: 'glColor4f'; d: @glColor4f),
    (n: 'glColor4fv'; d: @glColor4fv),
    (n: 'glColor4i'; d: @glColor4i),
    (n: 'glColor4iv'; d: @glColor4iv),
    (n: 'glColor4s'; d: @glColor4s),
    (n: 'glColor4sv'; d: @glColor4sv),
    (n: 'glColor4ub'; d: @glColor4ub),
    (n: 'glColor4ubv'; d: @glColor4ubv),
    (n: 'glColor4ui'; d: @glColor4ui),
    (n: 'glColor4uiv'; d: @glColor4uiv),
    (n: 'glColor4us'; d: @glColor4us),
    (n: 'glColor4usv'; d: @glColor4usv),
    (n: 'glColorMask'; d: @glColorMask),
    (n: 'glColorMaterial'; d: @glColorMaterial),
    (n: 'glColorPointer'; d: @glColorPointer),
    (n: 'glCopyPixels'; d: @glCopyPixels),
    (n: 'glCopyTexImage1D'; d: @glCopyTexImage1D),
    (n: 'glCopyTexImage2D'; d: @glCopyTexImage2D),
    (n: 'glCopyTexSubImage1D'; d: @glCopyTexSubImage1D),
    (n: 'glCopyTexSubImage2D'; d: @glCopyTexSubImage2D),
    (n: 'glCullFace'; d: @glCullFace),
    (n: 'glDeleteLists'; d: @glDeleteLists),
    (n: 'glDeleteTextures'; d: @glDeleteTextures),
    (n: 'glDepthFunc'; d: @glDepthFunc),
    (n: 'glDepthMask'; d: @glDepthMask),
    (n: 'glDepthRange'; d: @glDepthRange),
    (n: 'glDisable'; d: @glDisable),
    (n: 'glDisableClientState'; d: @glDisableClientState),
    (n: 'glDrawArrays'; d: @glDrawArrays),
    (n: 'glDrawBuffer'; d: @glDrawBuffer),
    (n: 'glDrawElements'; d: @glDrawElements),
    (n: 'glDrawPixels'; d: @glDrawPixels),
    (n: 'glEdgeFlag'; d: @glEdgeFlag),
    (n: 'glEdgeFlagPointer'; d: @glEdgeFlagPointer),
    (n: 'glEdgeFlagv'; d: @glEdgeFlagv),
    (n: 'glEnable'; d: @glEnable),
    (n: 'glEnableClientState'; d: @glEnableClientState),
    (n: 'glEnd'; d: @glEnd),
    (n: 'glEndList'; d: @glEndList),
    (n: 'glEvalCoord1d'; d: @glEvalCoord1d),
    (n: 'glEvalCoord1dv'; d: @glEvalCoord1dv),
    (n: 'glEvalCoord1f'; d: @glEvalCoord1f),
    (n: 'glEvalCoord1fv'; d: @glEvalCoord1fv),
    (n: 'glEvalCoord2d'; d: @glEvalCoord2d),
    (n: 'glEvalCoord2dv'; d: @glEvalCoord2dv),
    (n: 'glEvalCoord2f'; d: @glEvalCoord2f),
    (n: 'glEvalCoord2fv'; d: @glEvalCoord2fv),
    (n: 'glEvalMesh1'; d: @glEvalMesh1),
    (n: 'glEvalMesh2'; d: @glEvalMesh2),
    (n: 'glEvalPoint1'; d: @glEvalPoint1),
    (n: 'glEvalPoint2'; d: @glEvalPoint2),
    (n: 'glFeedbackBuffer'; d: @glFeedbackBuffer),
    (n: 'glFinish'; d: @glFinish),
    (n: 'glFlush'; d: @glFlush),
    (n: 'glFogf'; d: @glFogf),
    (n: 'glFogfv'; d: @glFogfv),
    (n: 'glFogi'; d: @glFogi),
    (n: 'glFogiv'; d: @glFogiv),
    (n: 'glFrontFace'; d: @glFrontFace),
    (n: 'glFrustum'; d: @glFrustum),
    (n: 'glGenLists'; d: @glGenLists),
    (n: 'glGenTextures'; d: @glGenTextures),
    (n: 'glGetBooleanv'; d: @glGetBooleanv),
    (n: 'glGetClipPlane'; d: @glGetClipPlane),
    (n: 'glGetDoublev'; d: @glGetDoublev),
    (n: 'glGetError'; d: @glGetError),
    (n: 'glGetFloatv'; d: @glGetFloatv),
    (n: 'glGetIntegerv'; d: @glGetIntegerv),
    (n: 'glGetLightfv'; d: @glGetLightfv),
    (n: 'glGetLightiv'; d: @glGetLightiv),
    (n: 'glGetMapdv'; d: @glGetMapdv),
    (n: 'glGetMapfv'; d: @glGetMapfv),
    (n: 'glGetMapiv'; d: @glGetMapiv),
    (n: 'glGetMaterialfv'; d: @glGetMaterialfv),
    (n: 'glGetMaterialiv'; d: @glGetMaterialiv),
    (n: 'glGetPixelMapfv'; d: @glGetPixelMapfv),
    (n: 'glGetPixelMapuiv'; d: @glGetPixelMapuiv),
    (n: 'glGetPixelMapusv'; d: @glGetPixelMapusv),
    (n: 'glGetPointerv'; d: @glGetPointerv),
    (n: 'glGetPolygonStipple'; d: @glGetPolygonStipple),
    (n: 'glGetString'; d: @glGetString),
    (n: 'glGetTexEnvfv'; d: @glGetTexEnvfv),
    (n: 'glGetTexEnviv'; d: @glGetTexEnviv),
    (n: 'glGetTexGendv'; d: @glGetTexGendv),
    (n: 'glGetTexGenfv'; d: @glGetTexGenfv),
    (n: 'glGetTexGeniv'; d: @glGetTexGeniv),
    (n: 'glGetTexImage'; d: @glGetTexImage),
    (n: 'glGetTexLevelParameterfv'; d: @glGetTexLevelParameterfv),
    (n: 'glGetTexLevelParameteriv'; d: @glGetTexLevelParameteriv),
    (n: 'glGetTexParameterfv'; d: @glGetTexParameterfv),
    (n: 'glGetTexParameteriv'; d: @glGetTexParameteriv),
    (n: 'glHint'; d: @glHint),
    (n: 'glIndexMask'; d: @glIndexMask),
    (n: 'glIndexPointer'; d: @glIndexPointer),
    (n: 'glIndexd'; d: @glIndexd),
    (n: 'glIndexdv'; d: @glIndexdv),
    (n: 'glIndexf'; d: @glIndexf),
    (n: 'glIndexfv'; d: @glIndexfv),
    (n: 'glIndexi'; d: @glIndexi),
    (n: 'glIndexiv'; d: @glIndexiv),
    (n: 'glIndexs'; d: @glIndexs),
    (n: 'glIndexsv'; d: @glIndexsv),
    (n: 'glIndexub'; d: @glIndexub),
    (n: 'glIndexubv'; d: @glIndexubv),
    (n: 'glInitNames'; d: @glInitNames),
    (n: 'glInterleavedArrays'; d: @glInterleavedArrays),
    (n: 'glIsEnabled'; d: @glIsEnabled),
    (n: 'glIsList'; d: @glIsList),
    (n: 'glIsTexture'; d: @glIsTexture),
    (n: 'glLightModelf'; d: @glLightModelf),
    (n: 'glLightModelfv'; d: @glLightModelfv),
    (n: 'glLightModeli'; d: @glLightModeli),
    (n: 'glLightModeliv'; d: @glLightModeliv),
    (n: 'glLightf'; d: @glLightf),
    (n: 'glLightfv'; d: @glLightfv),
    (n: 'glLighti'; d: @glLighti),
    (n: 'glLightiv'; d: @glLightiv),
    (n: 'glLineStipple'; d: @glLineStipple),
    (n: 'glLineWidth'; d: @glLineWidth),
    (n: 'glListBase'; d: @glListBase),
    (n: 'glLoadIdentity'; d: @glLoadIdentity),
    (n: 'glLoadMatrixd'; d: @glLoadMatrixd),
    (n: 'glLoadMatrixf'; d: @glLoadMatrixf),
    (n: 'glLoadName'; d: @glLoadName),
    (n: 'glLogicOp'; d: @glLogicOp),
    (n: 'glMap1d'; d: @glMap1d),
    (n: 'glMap1f'; d: @glMap1f),
    (n: 'glMap2d'; d: @glMap2d),
    (n: 'glMap2f'; d: @glMap2f),
    (n: 'glMapGrid1d'; d: @glMapGrid1d),
    (n: 'glMapGrid1f'; d: @glMapGrid1f),
    (n: 'glMapGrid2d'; d: @glMapGrid2d),
    (n: 'glMapGrid2f'; d: @glMapGrid2f),
    (n: 'glMaterialf'; d: @glMaterialf),
    (n: 'glMaterialfv'; d: @glMaterialfv),
    (n: 'glMateriali'; d: @glMateriali),
    (n: 'glMaterialiv'; d: @glMaterialiv),
    (n: 'glMatrixMode'; d: @glMatrixMode),
    (n: 'glMultMatrixd'; d: @glMultMatrixd),
    (n: 'glMultMatrixf'; d: @glMultMatrixf),
    (n: 'glNewList'; d: @glNewList),
    (n: 'glNormal3b'; d: @glNormal3b),
    (n: 'glNormal3bv'; d: @glNormal3bv),
    (n: 'glNormal3d'; d: @glNormal3d),
    (n: 'glNormal3dv'; d: @glNormal3dv),
    (n: 'glNormal3f'; d: @glNormal3f),
    (n: 'glNormal3fv'; d: @glNormal3fv),
    (n: 'glNormal3i'; d: @glNormal3i),
    (n: 'glNormal3iv'; d: @glNormal3iv),
    (n: 'glNormal3s'; d: @glNormal3s),
    (n: 'glNormal3sv'; d: @glNormal3sv),
    (n: 'glNormalPointer'; d: @glNormalPointer),
    (n: 'glOrtho'; d: @glOrtho),
    (n: 'glPassThrough'; d: @glPassThrough),
    (n: 'glPixelMapfv'; d: @glPixelMapfv),
    (n: 'glPixelMapuiv'; d: @glPixelMapuiv),
    (n: 'glPixelMapusv'; d: @glPixelMapusv),
    (n: 'glPixelStoref'; d: @glPixelStoref),
    (n: 'glPixelStorei'; d: @glPixelStorei),
    (n: 'glPixelTransferf'; d: @glPixelTransferf),
    (n: 'glPixelTransferi'; d: @glPixelTransferi),
    (n: 'glPixelZoom'; d: @glPixelZoom),
    (n: 'glPointSize'; d: @glPointSize),
    (n: 'glPolygonMode'; d: @glPolygonMode),
    (n: 'glPolygonOffset'; d: @glPolygonOffset),
    (n: 'glPolygonStipple'; d: @glPolygonStipple),
    (n: 'glPopAttrib'; d: @glPopAttrib),
    (n: 'glPopClientAttrib'; d: @glPopClientAttrib),
    (n: 'glPopMatrix'; d: @glPopMatrix),
    (n: 'glPopName'; d: @glPopName),
    (n: 'glPrioritizeTextures'; d: @glPrioritizeTextures),
    (n: 'glPushAttrib'; d: @glPushAttrib),
    (n: 'glPushClientAttrib'; d: @glPushClientAttrib),
    (n: 'glPushMatrix'; d: @glPushMatrix),
    (n: 'glPushName'; d: @glPushName),
    (n: 'glRasterPos2d'; d: @glRasterPos2d),
    (n: 'glRasterPos2dv'; d: @glRasterPos2dv),
    (n: 'glRasterPos2f'; d: @glRasterPos2f),
    (n: 'glRasterPos2fv'; d: @glRasterPos2fv),
    (n: 'glRasterPos2i'; d: @glRasterPos2i),
    (n: 'glRasterPos2iv'; d: @glRasterPos2iv),
    (n: 'glRasterPos2s'; d: @glRasterPos2s),
    (n: 'glRasterPos2sv'; d: @glRasterPos2sv),
    (n: 'glRasterPos3d'; d: @glRasterPos3d),
    (n: 'glRasterPos3dv'; d: @glRasterPos3dv),
    (n: 'glRasterPos3f'; d: @glRasterPos3f),
    (n: 'glRasterPos3fv'; d: @glRasterPos3fv),
    (n: 'glRasterPos3i'; d: @glRasterPos3i),
    (n: 'glRasterPos3iv'; d: @glRasterPos3iv),
    (n: 'glRasterPos3s'; d: @glRasterPos3s),
    (n: 'glRasterPos3sv'; d: @glRasterPos3sv),
    (n: 'glRasterPos4d'; d: @glRasterPos4d),
    (n: 'glRasterPos4dv'; d: @glRasterPos4dv),
    (n: 'glRasterPos4f'; d: @glRasterPos4f),
    (n: 'glRasterPos4fv'; d: @glRasterPos4fv),
    (n: 'glRasterPos4i'; d: @glRasterPos4i),
    (n: 'glRasterPos4iv'; d: @glRasterPos4iv),
    (n: 'glRasterPos4s'; d: @glRasterPos4s),
    (n: 'glRasterPos4sv'; d: @glRasterPos4sv),
    (n: 'glReadBuffer'; d: @glReadBuffer),
    (n: 'glReadPixels'; d: @glReadPixels),
    (n: 'glRectd'; d: @glRectd),
    (n: 'glRectdv'; d: @glRectdv),
    (n: 'glRectf'; d: @glRectf),
    (n: 'glRectfv'; d: @glRectfv),
    (n: 'glRecti'; d: @glRecti),
    (n: 'glRectiv'; d: @glRectiv),
    (n: 'glRects'; d: @glRects),
    (n: 'glRectsv'; d: @glRectsv),
    (n: 'glRenderMode'; d: @glRenderMode),
    (n: 'glRotated'; d: @glRotated),
    (n: 'glRotatef'; d: @glRotatef),
    (n: 'glScaled'; d: @glScaled),
    (n: 'glScalef'; d: @glScalef),
    (n: 'glScissor'; d: @glScissor),
    (n: 'glSelectBuffer'; d: @glSelectBuffer),
    (n: 'glShadeModel'; d: @glShadeModel),
    (n: 'glStencilFunc'; d: @glStencilFunc),
    (n: 'glStencilMask'; d: @glStencilMask),
    (n: 'glStencilOp'; d: @glStencilOp),
    (n: 'glTexCoord1d'; d: @glTexCoord1d),
    (n: 'glTexCoord1dv'; d: @glTexCoord1dv),
    (n: 'glTexCoord1f'; d: @glTexCoord1f),
    (n: 'glTexCoord1fv'; d: @glTexCoord1fv),
    (n: 'glTexCoord1i'; d: @glTexCoord1i),
    (n: 'glTexCoord1iv'; d: @glTexCoord1iv),
    (n: 'glTexCoord1s'; d: @glTexCoord1s),
    (n: 'glTexCoord1sv'; d: @glTexCoord1sv),
    (n: 'glTexCoord2d'; d: @glTexCoord2d),
    (n: 'glTexCoord2dv'; d: @glTexCoord2dv),
    (n: 'glTexCoord2f'; d: @glTexCoord2f),
    (n: 'glTexCoord2fv'; d: @glTexCoord2fv),
    (n: 'glTexCoord2i'; d: @glTexCoord2i),
    (n: 'glTexCoord2iv'; d: @glTexCoord2iv),
    (n: 'glTexCoord2s'; d: @glTexCoord2s),
    (n: 'glTexCoord2sv'; d: @glTexCoord2sv),
    (n: 'glTexCoord3d'; d: @glTexCoord3d),
    (n: 'glTexCoord3dv'; d: @glTexCoord3dv),
    (n: 'glTexCoord3f'; d: @glTexCoord3f),
    (n: 'glTexCoord3fv'; d: @glTexCoord3fv),
    (n: 'glTexCoord3i'; d: @glTexCoord3i),
    (n: 'glTexCoord3iv'; d: @glTexCoord3iv),
    (n: 'glTexCoord3s'; d: @glTexCoord3s),
    (n: 'glTexCoord3sv'; d: @glTexCoord3sv),
    (n: 'glTexCoord4d'; d: @glTexCoord4d),
    (n: 'glTexCoord4dv'; d: @glTexCoord4dv),
    (n: 'glTexCoord4f'; d: @glTexCoord4f),
    (n: 'glTexCoord4fv'; d: @glTexCoord4fv),
    (n: 'glTexCoord4i'; d: @glTexCoord4i),
    (n: 'glTexCoord4iv'; d: @glTexCoord4iv),
    (n: 'glTexCoord4s'; d: @glTexCoord4s),
    (n: 'glTexCoord4sv'; d: @glTexCoord4sv),
    (n: 'glTexCoordPointer'; d: @glTexCoordPointer),
    (n: 'glTexEnvf'; d: @glTexEnvf),
    (n: 'glTexEnvfv'; d: @glTexEnvfv),
    (n: 'glTexEnvi'; d: @glTexEnvi),
    (n: 'glTexEnviv'; d: @glTexEnviv),
    (n: 'glTexGend'; d: @glTexGend),
    (n: 'glTexGendv'; d: @glTexGendv),
    (n: 'glTexGenf'; d: @glTexGenf),
    (n: 'glTexGenfv'; d: @glTexGenfv),
    (n: 'glTexGeni'; d: @glTexGeni),
    (n: 'glTexGeniv'; d: @glTexGeniv),
    (n: 'glTexImage1D'; d: @glTexImage1D),
    (n: 'glTexImage2D'; d: @glTexImage2D),
    (n: 'glTexParameterf'; d: @glTexParameterf),
    (n: 'glTexParameterfv'; d: @glTexParameterfv),
    (n: 'glTexParameteri'; d: @glTexParameteri),
    (n: 'glTexParameteriv'; d: @glTexParameteriv),
    (n: 'glTexSubImage1D'; d: @glTexSubImage1D),
    (n: 'glTexSubImage2D'; d: @glTexSubImage2D),
    (n: 'glTranslated'; d: @glTranslated),
    (n: 'glTranslatef'; d: @glTranslatef),
    (n: 'glVertex2d'; d: @glVertex2d),
    (n: 'glVertex2dv'; d: @glVertex2dv),
    (n: 'glVertex2f'; d: @glVertex2f),
    (n: 'glVertex2fv'; d: @glVertex2fv),
    (n: 'glVertex2i'; d: @glVertex2i),
    (n: 'glVertex2iv'; d: @glVertex2iv),
    (n: 'glVertex2s'; d: @glVertex2s),
    (n: 'glVertex2sv'; d: @glVertex2sv),
    (n: 'glVertex3d'; d: @glVertex3d),
    (n: 'glVertex3dv'; d: @glVertex3dv),
    (n: 'glVertex3f'; d: @glVertex3f),
    (n: 'glVertex3fv'; d: @glVertex3fv),
    (n: 'glVertex3i'; d: @glVertex3i),
    (n: 'glVertex3iv'; d: @glVertex3iv),
    (n: 'glVertex3s'; d: @glVertex3s),
    (n: 'glVertex3sv'; d: @glVertex3sv),
    (n: 'glVertex4d'; d: @glVertex4d),
    (n: 'glVertex4dv'; d: @glVertex4dv),
    (n: 'glVertex4f'; d: @glVertex4f),
    (n: 'glVertex4fv'; d: @glVertex4fv),
    (n: 'glVertex4i'; d: @glVertex4i),
    (n: 'glVertex4iv'; d: @glVertex4iv),
    (n: 'glVertex4s'; d: @glVertex4s),
    (n: 'glVertex4sv'; d: @glVertex4sv),
    (n: 'glVertexPointer'; d: @glVertexPointer),
    (n: 'glViewport'; d: @glViewport)
    );
{$ifdef mswindows}
 funcsopt: array[0..0] of funcinfoty = (
    (n: 'ChoosePixelFormat'; d: @ChoosePixelFormat)
    );
{$endif}
const
 errormessage = 'Can not load OpenGL library. ';
 
begin
 initializedynlib(libinfo,sonames,opengllib,funcs,
            {$ifdef mswindows}funcsopt{$else}[]{$endif},errormessage,@init);
{$ifdef mswindows}
 if ChoosePixelFormat = nil then begin
  ChoosePixelFormat:= @WinChoosePixelFormat;
 end;
{$endif}
end;

procedure releaseopengl;
begin
 releasedynlib(libinfo,@deinit);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
