unit WebPEnc;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:	WEBP port                                                     //
// Version:	0.6                                                           //
// Date:	11-JUN-2026                                                   //
// License:     MIT                                                           //
// Target:	Win64, Free Pascal, Delphi                                    //
// Copyright:	(c) 2026 Xelitan.com.                                         //
//		All rights reserved.                                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

//  Minimal VP8 lossy WebP encoder, ported from libwebp-1.6.0.
//  I16x16-DC intra prediction, UV-DC, single segment, no loop filter,
//  default probability tables, quality 0..100.

function WebPEncodeRGB (const RGB  : PByte; Width, Height, Stride: Integer;
                        Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
function WebPEncodeRGBA(const RGBA : PByte; Width, Height, Stride: Integer;
                        Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
function WebPEncodeBGR (const BGR  : PByte; Width, Height, Stride: Integer;
                        Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
function WebPEncodeBGRA(const BGRA : PByte; Width, Height, Stride: Integer;
                        Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;

// Lossless (VP8L) encoders — produce a byte-exact, losslessly reconstructable WebP.
function WebPEncodeLosslessRGB (const RGB  : PByte; Width, Height, Stride: Integer;
                               out OutData: PByte; out OutSize: Integer): Boolean;
function WebPEncodeLosslessRGBA(const RGBA : PByte; Width, Height, Stride: Integer;
                               out OutData: PByte; out OutSize: Integer): Boolean;
function WebPEncodeLosslessBGR (const BGR  : PByte; Width, Height, Stride: Integer;
                               out OutData: PByte; out OutSize: Integer): Boolean;
function WebPEncodeLosslessBGRA(const BGRA : PByte; Width, Height, Stride: Integer;
                               out OutData: PByte; out OutSize: Integer): Boolean;

implementation

uses Math;

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type
  TInt16x16 = array[0..15] of SmallInt;
  TVP8EncMatrix = record
    q       : array[0..15] of Word;
    iq      : array[0..15] of Cardinal;
    bias    : array[0..15] of Cardinal;
    zthresh : array[0..15] of Integer;
    sharpen : array[0..15] of SmallInt;
  end;
  TNZRow = array[0..8] of Integer;

  TVP8BW = record
    buf    : PByte;
    pos    : Integer;
    alloc  : Integer;
    range  : Cardinal;
    value  : Cardinal;
    run    : Integer;
    nb_bits: Integer;
  end;

  TByteArray = array[0..MaxInt div SizeOf(Byte) - 1] of Byte;
  PByteArray = ^TByteArray;

  TCardinalArray = array[0..MaxInt div SizeOf(Cardinal) - 1] of Cardinal;
  PCardinalArray = ^TCardinalArray;

  TIntegerArray = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;
  PIntegerArray = ^TIntegerArray;


// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const
  QFIX         = 17;
  SHARPEN_BITS = 11;
  MAX_LEVEL    = 2047;
  DSHIFT       = 4;

  kEncZigzag: array[0..15] of Byte = (
    0,1,4,8,5,2,3,6,9,12,13,10,7,11,14,15);

  // maps coefficient position → probability band (entry 16 = sentinel 0)
  kEncBands: array[0..16] of Byte = (
    0,1,2,3,6,4,5,6,6,6,6,6,6,6,6,7,0);

  kBiasMatrices: array[0..2, 0..1] of Byte = (
    (96, 110),   // y1 luma-AC  [DC, AC]
    (96, 108),   // y2 luma-WHT
    (110,115));  // uv chroma

  kFreqSharpening: array[0..15] of Word = (
    0,30,60,90,30,60,90,90,60,90,90,90,90,90,90,90);

  kDcTable: array[0..127] of Byte = (
    4,5,6,7,8,9,10,10,11,12,13,14,15,16,17,17,
    18,19,20,20,21,21,22,22,23,23,24,25,25,26,27,28,
    29,30,31,32,33,34,35,36,37,37,38,39,40,41,42,43,
    44,45,46,46,47,48,49,50,51,52,53,54,55,56,57,58,
    59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,
    75,76,76,77,78,79,80,81,82,83,84,85,86,87,88,89,
    91,93,95,96,98,100,101,102,104,106,108,110,112,114,116,118,
    122,124,126,128,130,132,134,136,138,140,143,145,148,151,154,157);

  kAcTable: array[0..127] of Word = (
    4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
    20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
    36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,
    52,53,54,55,56,57,58,60,62,64,66,68,70,72,74,76,
    78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,
    110,112,114,116,119,122,125,128,131,134,137,140,143,146,149,152,
    155,158,161,164,167,170,173,177,181,185,189,193,197,201,205,209,
    213,217,221,225,229,234,239,245,249,254,259,264,269,274,279,284);

  kAcTable2: array[0..127] of Word = (
    8,8,9,10,12,13,15,17,18,20,21,23,24,26,27,29,
    31,32,34,35,37,38,40,41,43,44,46,48,49,51,52,54,
    55,57,58,60,62,63,65,66,68,69,71,72,74,75,77,79,
    80,82,83,85,86,88,89,93,96,99,102,105,108,111,114,117,
    120,124,127,130,133,136,139,142,145,148,151,155,158,161,164,167,
    170,173,176,179,184,189,193,198,203,207,212,217,221,226,230,235,
    240,244,249,254,258,263,268,274,280,286,292,299,305,311,317,323,
    330,336,342,348,354,362,370,379,385,393,401,409,416,424,432,440);

  // Encoder renorm tables — must match libwebp bit_writer_utils.c exactly.
  kNorm: array[0..127] of Byte = (
    7,6,6,5,5,5,5,4,4,4,4,4,4,4,4,3,
    3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0);

  kNewRange: array[0..127] of Byte = (
    127,127,191,127,159,191,223,127,143,159,175,191,207,223,239,127,
    135,143,151,159,167,175,183,191,199,207,215,223,231,239,247,127,
    131,135,139,143,147,151,155,159,163,167,171,175,179,183,187,191,
    195,199,203,207,211,215,219,223,227,231,235,239,243,247,251,127,
    129,131,133,135,137,139,141,143,145,147,149,151,153,155,157,159,
    161,163,165,167,169,171,173,175,177,179,181,183,185,187,189,191,
    193,195,197,199,201,203,205,207,209,211,213,215,217,219,221,223,
    225,227,229,231,233,235,237,239,241,243,245,247,249,251,253,127);

  kEncCoeffProba: array[0..3, 0..7, 0..2, 0..10] of Byte = (
    (((128,128,128,128,128,128,128,128,128,128,128),
      (128,128,128,128,128,128,128,128,128,128,128),
      (128,128,128,128,128,128,128,128,128,128,128)),
     ((253,136,254,255,228,219,128,128,128,128,128),
      (189,129,242,255,227,213,255,219,128,128,128),
      (106,126,227,252,214,209,255,255,128,128,128)),
     ((1,98,248,255,236,226,255,255,128,128,128),
      (181,133,238,254,221,234,255,154,128,128,128),
      (78,134,202,247,198,180,255,219,128,128,128)),
     ((1,185,249,255,243,255,128,128,128,128,128),
      (184,150,247,255,236,224,128,128,128,128,128),
      (77,110,216,255,236,230,128,128,128,128,128)),
     ((1,101,251,255,241,255,128,128,128,128,128),
      (170,139,241,252,236,209,255,255,128,128,128),
      (37,116,196,243,228,255,255,255,128,128,128)),
     ((1,204,254,255,245,255,128,128,128,128,128),
      (207,160,250,255,238,128,128,128,128,128,128),
      (102,103,231,255,211,171,128,128,128,128,128)),
     ((1,152,252,255,240,255,128,128,128,128,128),
      (177,135,243,255,234,225,128,128,128,128,128),
      (80,129,211,255,194,224,128,128,128,128,128)),
     ((1,1,255,128,128,128,128,128,128,128,128),
      (246,1,255,128,128,128,128,128,128,128,128),
      (255,128,128,128,128,128,128,128,128,128,128))),
    (((198,35,237,223,193,187,162,160,145,155,62),
      (131,45,198,221,172,176,220,157,252,221,1),
      (68,47,146,208,149,167,221,162,255,223,128)),
     ((1,149,241,255,221,224,255,255,128,128,128),
      (184,141,234,253,222,220,255,199,128,128,128),
      (81,99,181,242,176,190,249,202,255,255,128)),
     ((1,129,232,253,214,197,242,196,255,255,128),
      (99,121,210,250,201,198,255,202,128,128,128),
      (23,91,163,242,170,187,247,210,255,255,128)),
     ((1,200,246,255,234,255,128,128,128,128,128),
      (109,178,241,255,231,245,255,255,128,128,128),
      (44,130,201,253,205,192,255,255,128,128,128)),
     ((1,132,239,251,219,209,255,165,128,128,128),
      (94,136,225,251,218,190,255,255,128,128,128),
      (22,100,174,245,186,161,255,199,128,128,128)),
     ((1,182,249,255,232,235,128,128,128,128,128),
      (124,143,241,255,227,234,128,128,128,128,128),
      (35,77,181,251,193,211,255,205,128,128,128)),
     ((1,157,247,255,236,231,255,255,128,128,128),
      (121,141,235,255,225,227,255,255,128,128,128),
      (45,99,188,251,195,217,255,224,128,128,128)),
     ((1,1,251,255,213,255,128,128,128,128,128),
      (203,1,248,255,255,128,128,128,128,128,128),
      (137,1,177,255,224,255,128,128,128,128,128))),
    (((253,9,248,251,207,208,255,192,128,128,128),
      (175,13,224,243,193,185,249,198,255,255,128),
      (73,17,171,221,161,179,236,167,255,234,128)),
     ((1,95,247,253,212,183,255,255,128,128,128),
      (239,90,244,250,211,209,255,255,128,128,128),
      (155,77,195,248,188,195,255,255,128,128,128)),
     ((1,24,239,251,218,219,255,205,128,128,128),
      (201,51,219,255,196,186,128,128,128,128,128),
      (69,46,190,239,201,218,255,228,128,128,128)),
     ((1,191,251,255,255,128,128,128,128,128,128),
      (223,165,249,255,213,255,128,128,128,128,128),
      (141,124,248,255,255,128,128,128,128,128,128)),
     ((1,16,248,255,255,128,128,128,128,128,128),
      (190,36,230,255,236,255,128,128,128,128,128),
      (149,1,255,128,128,128,128,128,128,128,128)),
     ((1,226,255,128,128,128,128,128,128,128,128),
      (247,192,255,128,128,128,128,128,128,128,128),
      (240,128,255,128,128,128,128,128,128,128,128)),
     ((1,134,252,255,255,128,128,128,128,128,128),
      (213,62,250,255,255,128,128,128,128,128,128),
      (55,93,255,128,128,128,128,128,128,128,128)),
     ((128,128,128,128,128,128,128,128,128,128,128),
      (128,128,128,128,128,128,128,128,128,128,128),
      (128,128,128,128,128,128,128,128,128,128,128))),
    (((202,24,213,235,186,191,220,160,240,175,255),
      (126,38,182,232,169,184,228,174,255,187,128),
      (61,46,138,219,151,178,240,170,255,216,128)),
     ((1,112,230,250,199,191,247,159,255,255,128),
      (166,109,228,252,211,215,255,174,128,128,128),
      (39,77,162,232,172,180,245,178,255,255,128)),
     ((1,52,220,246,198,199,249,220,255,255,128),
      (124,74,191,243,183,193,250,221,255,255,128),
      (24,71,130,219,154,170,243,182,255,255,128)),
     ((1,182,225,249,219,240,255,224,128,128,128),
      (149,150,226,252,216,205,255,171,128,128,128),
      (28,108,170,242,183,194,254,223,255,255,128)),
     ((1,81,230,252,204,203,255,192,128,128,128),
      (123,102,209,247,188,196,255,233,128,128,128),
      (20,95,153,243,164,173,255,203,128,128,128)),
     ((1,222,248,255,216,213,128,128,128,128,128),
      (168,175,246,252,235,205,255,255,128,128,128),
      (47,116,215,255,211,212,255,255,128,128,128)),
     ((1,121,236,253,212,214,255,255,128,128,128),
      (141,84,213,252,201,202,255,219,128,128,128),
      (42,80,160,240,162,185,255,205,128,128,128)),
     ((1,1,255,128,128,128,128,128,128,128,128),
      (244,1,255,128,128,128,128,128,128,128,128),
      (238,1,255,128,128,128,128,128,128,128,128))));

  kEncUpdateProba: array[0..3, 0..7, 0..2, 0..10] of Byte = (
    (((255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((176,246,255,255,255,255,255,255,255,255,255),
      (223,241,252,255,255,255,255,255,255,255,255),
      (249,253,253,255,255,255,255,255,255,255,255)),
     ((255,244,252,255,255,255,255,255,255,255,255),
      (234,254,254,255,255,255,255,255,255,255,255),
      (253,255,255,255,255,255,255,255,255,255,255)),
     ((255,246,254,255,255,255,255,255,255,255,255),
      (239,253,254,255,255,255,255,255,255,255,255),
      (254,255,254,255,255,255,255,255,255,255,255)),
     ((255,248,254,255,255,255,255,255,255,255,255),
      (251,255,254,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,253,254,255,255,255,255,255,255,255,255),
      (251,254,254,255,255,255,255,255,255,255,255),
      (254,255,254,255,255,255,255,255,255,255,255)),
     ((255,254,253,255,254,255,255,255,255,255,255),
      (250,255,254,255,254,255,255,255,255,255,255),
      (254,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255))),
    (((217,255,255,255,255,255,255,255,255,255,255),
      (225,252,241,253,255,255,254,255,255,255,255),
      (234,250,241,250,253,255,253,254,255,255,255)),
     ((255,254,255,255,255,255,255,255,255,255,255),
      (223,254,254,255,255,255,255,255,255,255,255),
      (238,253,254,254,255,255,255,255,255,255,255)),
     ((255,248,254,255,255,255,255,255,255,255,255),
      (249,254,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,253,255,255,255,255,255,255,255,255,255),
      (247,254,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,253,254,255,255,255,255,255,255,255,255),
      (252,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,254,254,255,255,255,255,255,255,255,255),
      (253,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,254,253,255,255,255,255,255,255,255,255),
      (250,255,255,255,255,255,255,255,255,255,255),
      (254,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255))),
    (((186,251,250,255,255,255,255,255,255,255,255),
      (234,251,244,254,255,255,255,255,255,255,255),
      (251,251,243,253,254,255,254,255,255,255,255)),
     ((255,253,254,255,255,255,255,255,255,255,255),
      (236,253,254,255,255,255,255,255,255,255,255),
      (251,253,253,254,254,255,255,255,255,255,255)),
     ((255,254,254,255,255,255,255,255,255,255,255),
      (254,254,254,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,254,255,255,255,255,255,255,255,255,255),
      (254,254,255,255,255,255,255,255,255,255,255),
      (254,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (254,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255))),
    (((248,255,255,255,255,255,255,255,255,255,255),
      (250,254,252,254,255,255,255,255,255,255,255),
      (248,254,249,253,255,255,255,255,255,255,255)),
     ((255,253,253,255,255,255,255,255,255,255,255),
      (246,253,253,255,255,255,255,255,255,255,255),
      (252,254,251,254,254,255,255,255,255,255,255)),
     ((255,254,252,255,255,255,255,255,255,255,255),
      (248,254,253,255,255,255,255,255,255,255,255),
      (253,255,254,254,255,255,255,255,255,255,255)),
     ((255,251,254,255,255,255,255,255,255,255,255),
      (245,251,254,255,255,255,255,255,255,255,255),
      (253,253,254,255,255,255,255,255,255,255,255)),
     ((255,251,253,255,255,255,255,255,255,255,255),
      (252,253,254,255,255,255,255,255,255,255,255),
      (255,254,255,255,255,255,255,255,255,255,255)),
     ((255,252,255,255,255,255,255,255,255,255,255),
      (249,255,254,255,255,255,255,255,255,255,255),
      (255,255,254,255,255,255,255,255,255,255,255)),
     ((255,255,253,255,255,255,255,255,255,255,255),
      (250,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255)),
     ((255,255,255,255,255,255,255,255,255,255,255),
      (254,255,255,255,255,255,255,255,255,255,255),
      (255,255,255,255,255,255,255,255,255,255,255))));

  // VP8L code-length code order (for the lossless encoder)
  kEncCLOrder: array[0..18] of Byte = (
    17, 18, 0, 1, 2, 3, 4, 5, 16, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);

  kCat3: array[0..2]  of Byte = (173,148,140);
  kCat4: array[0..3]  of Byte = (176,155,140,135);
  kCat5: array[0..4]  of Byte = (180,157,141,134,130);
  kCat6: array[0..10] of Byte = (254,254,243,230,196,177,153,140,133,130,129);

// ===========================================================================
// Arithmetic right shift
// ===========================================================================

function SarI(v, n: Integer): Integer; inline;
begin
  if v >= 0 then Result := v shr n
  else           Result := not (not v shr n);
end;

// ===========================================================================
// Boolean arithmetic coder (VP8 bit-writer)
// ===========================================================================

const BW_INITIAL_SIZE = 4096;

function BWGrow(var bw: TVP8BW; extra: Integer): Boolean;
var newA: Integer; nb: PByte;
begin
  newA := bw.alloc + extra + BW_INITIAL_SIZE;
  nb   := ReallocMemory(bw.buf, newA);
  if nb = nil then begin Result := False; Exit; end;
  bw.buf   := nb;
  bw.alloc := newA;
  Result   := True;
end;

procedure BWFlush(var bw: TVP8BW);
var s, bits, pos, v: Integer;
begin
  s    := 8 + bw.nb_bits;
  bits := Integer(bw.value shr s);
  bw.value := bw.value - (Cardinal(bits) shl s);
  Dec(bw.nb_bits, 8);
  if (bits and $ff) <> $ff then
  begin
    pos := bw.pos;
    if pos + bw.run + 1 > bw.alloc then
      if not BWGrow(bw, bw.run + 1) then Exit;
    if (bits and $100) <> 0 then begin  // overflow -> propagate carry over pending 0xff's
      if pos > 0 then Inc(bw.buf[pos - 1]);
    end;
    if bw.run > 0 then
    begin
      if (bits and $100) <> 0 then v := $00 else v := $ff;
      while bw.run > 0 do begin bw.buf[pos] := Byte(v); Inc(pos); Dec(bw.run); end;
    end;
    bw.buf[pos] := Byte(bits and $ff);
    Inc(pos);
    bw.pos := pos;
  end else
    Inc(bw.run);
end;

procedure BWInit(var bw: TVP8BW);
begin
  FillChar(bw, SizeOf(bw), 0);
  bw.range   := 254;   // matches libwebp VP8BitWriterInit (255 - 1)
  bw.nb_bits := -8;
  GetMem(bw.buf, BW_INITIAL_SIZE);
  if bw.buf <> nil then bw.alloc := BW_INITIAL_SIZE;
end;

procedure BWPutBit(var bw: TVP8BW; bit, prob: Integer);
var split, shift: Integer;
begin
  split := Integer((bw.range * Cardinal(prob)) shr 8);
  if bit <> 0 then
  begin
    Inc(bw.value, Cardinal(split + 1));
    Dec(bw.range, split + 1);
  end else
    bw.range := split;
  // Renormalize only when range dropped below 127 (matches libwebp VP8PutBit).
  // kNorm/kNewRange are indexed [0..126] in this branch; indexing them for
  // range >= 127 would read out of bounds and corrupt the bitstream.
  if bw.range < 127 then
  begin
    shift := kNorm[bw.range];
    bw.range := kNewRange[bw.range];
    bw.value := bw.value shl shift;
    Inc(bw.nb_bits, shift);
    if bw.nb_bits > 0 then BWFlush(bw);
  end;
end;

procedure BWPutBitUniform(var bw: TVP8BW; bit: Integer);
begin BWPutBit(bw, bit, 128); end;

procedure BWPutBits(var bw: TVP8BW; value: Cardinal; nbits: Integer);
var i: Integer;
begin
  for i := nbits - 1 downto 0 do BWPutBitUniform(bw, (value shr i) and 1);
end;

// Matches libwebp VP8PutSignedBits: a "nonzero?" flag, then (magnitude<<1)|sign
// in nbits+1 bits only when nonzero.
procedure BWPutSignedBits(var bw: TVP8BW; value, nbits: Integer);
begin
  BWPutBitUniform(bw, Ord(value <> 0));
  if value = 0 then Exit;
  if value < 0 then BWPutBits(bw, (Cardinal(-value) shl 1) or 1, nbits + 1)
  else              BWPutBits(bw, Cardinal(value) shl 1, nbits + 1);
end;

function BWFinish(var bw: TVP8BW): Integer;
begin
  // Matches libwebp VP8BitWriterFinish.
  BWPutBits(bw, 0, 9 - bw.nb_bits);
  bw.nb_bits := 0;
  BWFlush(bw);
  Result := bw.pos;
end;

procedure BWFree(var bw: TVP8BW);
begin
  if bw.buf <> nil then
  begin
    FreeMem(bw.buf);
    bw.buf := nil;
    bw.alloc := 0;
  end;
end;

// ===========================================================================
// Quality → base quantizer index
// ===========================================================================

function QualityToBaseQ(Quality: Single): Integer;
var q, lc, c: Double;
begin
  if Quality < 0   then Quality := 0;
  if Quality > 100 then Quality := 100;

  q := Quality / 100.0;
  if q < 0.75 then lc := q * (2.0/3.0) else lc := 2.0*q - 1.0;
  if lc <= 0 then c := 0 else c := Exp(Ln(lc) / 3.0);

  Result := Round(127.0 * (1.0 - c));
  if Result < 0   then Result := 0;
  if Result > 127 then Result := 127;
end;

// ===========================================================================
// RGB → YUV
// ===========================================================================

const YUV_FIX = 16;
      YUV_HALF = 1 shl (YUV_FIX-1);

function RGBToY(r,g,b: Integer): Byte;
var v: Integer;
begin
  v := (16839*r + 33059*g + 6420*b + YUV_HALF + (16 shl YUV_FIX)) shr YUV_FIX;
  if v<0 then v:=0 else if v>255 then v:=255;
  Result := Byte(v);
end;

function ClipUV(uv, rounding: Integer): Byte;
var v: Integer;
begin
  v := (uv + rounding + (128 shl 18)) shr 18;
  if v<0 then v:=0 else if v>255 then v:=255;
  Result := Byte(v);
end;

function RGBToU(r,g,b: Integer): Byte;
begin
  Result := ClipUV(-9719*r - 19081*g + 28800*b, YUV_HALF);
end;

function RGBToV(r,g,b: Integer): Byte;
begin
  Result := ClipUV(28800*r - 24116*g - 4684*b,  YUV_HALF);
end;

// ===========================================================================
// Forward 4×4 DCT  (FTransform_C)
//   inp[row*4+col] = pixel difference (src - pred)
//   out[row*4+col] = DCT coefficient in natural order
// ===========================================================================

procedure FTransform4x4(const inp: array of SmallInt; var out: TInt16x16);
var i,a0,a1,a2,a3: Integer;
    tmp: array[0..15] of Integer;
begin
  for i := 0 to 3 do begin
    a0 := inp[i*4+0] + inp[i*4+3]; a1 := inp[i*4+1] + inp[i*4+2];
    a2 := inp[i*4+1] - inp[i*4+2]; a3 := inp[i*4+0] - inp[i*4+3];
    tmp[i*4+0] := (a0+a1)*8;
    tmp[i*4+1] := SarI(a2*2217 + a3*5352 + 1812, 9);  // arithmetic shift!
    tmp[i*4+2] := (a0-a1)*8;
    tmp[i*4+3] := SarI(a3*2217 - a2*5352 + 937, 9);
  end;
  for i := 0 to 3 do begin
    a0 := tmp[0+i] + tmp[12+i]; a1 := tmp[4+i] + tmp[8+i];
    a2 := tmp[4+i] - tmp[8+i];  a3 := tmp[0+i] - tmp[12+i];
    out[0 +i] := SmallInt(SarI(a0+a1+7, DSHIFT));
    out[4 +i] := SmallInt(SarI(a2*2217 + a3*5352 + 12000, 16) + Ord(a3<>0));
    out[8 +i] := SmallInt(SarI(a0-a1+7, DSHIFT));
    out[12+i] := SmallInt(SarI(a3*2217 - a2*5352 + 51000, 16));
  end;
end;

// ===========================================================================
// Forward WHT on 16 packed DC values  (FTransformWHT_C adapted for flat array)
//   dc[i] = DC coefficient of i-th 4×4 luma sub-block (row-major: i=by*4+bx)
//   out[row*4+col] = WHT coefficient in natural order
// ===========================================================================

procedure FTransformWHT(const dc: array of SmallInt; var out: TInt16x16);
var i,a0,a1,a2,a3: Integer;
    tmp: array[0..15] of Integer;
begin
  for i := 0 to 3 do begin
    a0 := dc[i*4+0] + dc[i*4+2];   // col0+col2
    a1 := dc[i*4+1] + dc[i*4+3];   // col1+col3
    a2 := dc[i*4+1] - dc[i*4+3];   // col1-col3
    a3 := dc[i*4+0] - dc[i*4+2];   // col0-col2
    tmp[i*4+0] := a0+a1;
    tmp[i*4+1] := a3+a2;
    tmp[i*4+2] := a3-a2;
    tmp[i*4+3] := a0-a1;
  end;
  for i := 0 to 3 do begin
    a0 := tmp[0+i] + tmp[8+i];    // row0+row2
    a1 := tmp[4+i] + tmp[12+i];   // row1+row3
    a2 := tmp[4+i] - tmp[12+i];   // row1-row3
    a3 := tmp[0+i] - tmp[8+i];    // row0-row2
    out[0 +i] := SmallInt(SarI(a0+a1, 1));
    out[4 +i] := SmallInt(SarI(a3+a2, 1));
    out[8 +i] := SmallInt(SarI(a3-a2, 1));
    out[12+i] := SmallInt(SarI(a0-a1, 1));
  end;
end;

// ===========================================================================
// Setup quantization matrix
//   mtype: 0=y1(luma-AC), 1=y2(luma-WHT), 2=uv(chroma)
//   q0: DC quantizer, q1: AC quantizer
// ===========================================================================

procedure SetupEncMatrix(var m: TVP8EncMatrix; mtype, q0, q1: Integer);
var i: Integer; dcB, acB: Cardinal;
begin
  dcB := kBiasMatrices[mtype, 0];
  acB := kBiasMatrices[mtype, 1];
  m.q[0]       := q0;
  m.iq[0]      := (1 shl QFIX) div q0;
  m.bias[0]    := dcB shl 9;
  m.zthresh[0] := (Integer(1 shl QFIX) - 1 - Integer(m.bias[0])) div Integer(m.iq[0]);
  m.q[1]       := q1;
  m.iq[1]      := (1 shl QFIX) div q1;
  m.bias[1]    := acB shl 9;
  m.zthresh[1] := (Integer(1 shl QFIX) - 1 - Integer(m.bias[1])) div Integer(m.iq[1]);
  for i := 2 to 15 do begin
    m.q[i]:=m.q[1];
    m.iq[i]:=m.iq[1];
    m.bias[i]:=m.bias[1];
    m.zthresh[i]:=m.zthresh[1];
  end;
  for i := 0 to 15 do begin
    if mtype = 0 then
      m.sharpen[i] := SmallInt((Integer(kFreqSharpening[i]) * Integer(m.q[i])) shr SHARPEN_BITS)
    else
      m.sharpen[i] := 0;
  end;
end;

// ===========================================================================
// Quantize one 4×4 block
//   inp : natural-order transform coefficients (not modified)
//   m   : quantization matrix
//   first: first index to quantize (0=DC included, 1=skip DC)
//   out : zigzag-order quantized levels (output)
// Returns: last non-zero zigzag position, or first-1 if all-zero
// ===========================================================================

function QuantizeOneBlock(const inp: TInt16x16; var m: TVP8EncMatrix;
                          first: Integer; var out: TInt16x16): Integer;
var n, j, sign, v, qv, last: Integer;
begin
  last := -1;
  FillChar(out, SizeOf(out), 0);
  for n := first to 15 do begin
    j := kEncZigzag[n];
    v := inp[j];
    if v < 0 then begin
      sign := 1;
      v := -v;
    end else sign := 0;

    Inc(v, m.sharpen[j]);
    if v > m.zthresh[j] then
    begin
      qv := Integer((Int64(v) * m.iq[j] + m.bias[j]) shr QFIX);
      if qv > MAX_LEVEL then qv := MAX_LEVEL;
      if sign <> 0 then qv := -qv;
      out[n] := SmallInt(qv);
      if qv <> 0 then last := n;
    end;
  end;
  Result := last;
end;

// ===========================================================================
// PutCoeffs — exact port of frame_enc.c PutCoeffs
//   bw        : boolean coder
//   ctx       : 0, 1 or 2 (NZ context)
//   coeffType : 0=i16AC, 1=i16DC, 2=chromaAC, 3=i4AC
//   first     : 0 or 1 (first coefficient index)
//   last      : last non-zero zigzag position, -1 if all-zero
//   coeffs    : zigzag-ordered quantized levels
// Returns: 1 if any non-zero was coded, 0 otherwise
// ===========================================================================

function PutCoeffs(var bw: TVP8BW; ctx, coeffType, first, last: Integer;
                   const coeffs: TInt16x16): Integer;
var
  n, c, sign, v, mask: Integer;
  p: array[0..10] of Byte;
  i: Integer;
begin
  // Load initial probability row
  n := first;
  for i := 0 to 10 do p[i] := kEncCoeffProba[coeffType, n, ctx, i];

  // Code "has any non-zero coeff?"
  BWPutBit(bw, Ord(last >= 0), p[0]);
  if last < 0 then begin Result := 0; Exit; end;

  while n < 16 do begin
    c := coeffs[n]; Inc(n);
    sign := Ord(c < 0);
    if sign <> 0 then v := -c else v := c;

    // Code "this coeff != 0"
    BWPutBit(bw, Ord(v <> 0), p[1]);
    if v = 0 then begin
      // zero: update prob row (ctx=0 after zero), continue
      for i := 0 to 10 do p[i] := kEncCoeffProba[coeffType, kEncBands[n], 0, i];
      Continue;
    end;

    // Code "v > 1"
    BWPutBit(bw, Ord(v > 1), p[2]);
    if v <= 1 then begin
      // v = 1: update with ctx=1
      for i := 0 to 10 do p[i] := kEncCoeffProba[coeffType, kEncBands[n], 1, i];
    end else begin
      // v > 1
      BWPutBit(bw, Ord(v > 4), p[3]);
      if v <= 4 then begin
        // v in 2..4
        BWPutBit(bw, Ord(v <> 2), p[4]);
        if v <> 2 then BWPutBit(bw, Ord(v = 4), p[5]);
      end else begin
        // v > 4
        BWPutBit(bw, Ord(v > 10), p[6]);
        if v <= 10 then begin
          // v in 5..10
          BWPutBit(bw, Ord(v > 6), p[7]);
          if v <= 6 then begin
            BWPutBit(bw, Ord(v = 6), 159);       // cat1: v in 5..6
          end else begin
            BWPutBit(bw, Ord(v >= 9), 165);       // cat2: v in 7..10
            BWPutBit(bw, Ord((v and 1) = 0), 145);
          end;
        end else begin
          // v > 10: cats 3..6
          if v < 3 + (8 shl 1) then begin         // cat3: v in 11..18
            BWPutBit(bw, 0, p[8]);
            BWPutBit(bw, 0, p[9]);
            Dec(v, 3 + (8 shl 0));  // v -= 11
            mask := 1 shl 2;
            for i := 0 to 2 do begin BWPutBit(bw, Ord((v and mask)<>0), kCat3[i]); mask:=mask shr 1; end;
          end else if v < 3 + (8 shl 2) then begin // cat4: v in 19..34
            BWPutBit(bw, 0, p[8]);
            BWPutBit(bw, 1, p[9]);
            Dec(v, 3 + (8 shl 1));  // v -= 19
            mask := 1 shl 3;
            for i := 0 to 3 do begin BWPutBit(bw, Ord((v and mask)<>0), kCat4[i]); mask:=mask shr 1; end;
          end else if v < 3 + (8 shl 3) then begin // cat5: v in 35..66
            BWPutBit(bw, 1, p[8]);
            BWPutBit(bw, 0, p[10]);
            Dec(v, 3 + (8 shl 2));  // v -= 35
            mask := 1 shl 4;
            for i := 0 to 4 do begin BWPutBit(bw, Ord((v and mask)<>0), kCat5[i]); mask:=mask shr 1; end;
          end else begin                            // cat6: v in 67..2047
            BWPutBit(bw, 1, p[8]);
            BWPutBit(bw, 1, p[10]);
            Dec(v, 3 + (8 shl 3));  // v -= 67
            mask := 1 shl 10;
            for i := 0 to 10 do begin BWPutBit(bw, Ord((v and mask)<>0), kCat6[i]); mask:=mask shr 1; end;
          end;
        end;
      end;
      // After value > 1: update with ctx=2
      for i := 0 to 10 do p[i] := kEncCoeffProba[coeffType, kEncBands[n], 2, i];
    end;

    // Code sign bit
    BWPutBitUniform(bw, sign);

    // Code EOB or "more coefficients follow"
    if (n = 16) or (last < n) then begin
      if n < 16 then BWPutBit(bw, 0, p[0]);  // explicit EOB
      Result := 1; Exit;
    end;
    BWPutBit(bw, 1, p[0]);  // has more
  end;
  Result := 1;
end;

// ===========================================================================
// Partition 0: header, quantization, default probabilities, intra modes
// ===========================================================================

procedure WritePartition0(var bw: TVP8BW; baseQ, mbsX, mbsY: Integer);
var t, b, c, pp, mb: Integer;
begin
  // colorspace=0, clamp=0
  BWPutBitUniform(bw, 0);
  BWPutBitUniform(bw, 0);
  // Segment header: num_segments=1 → no segment update (bit=0)
  BWPutBitUniform(bw, 0);
  // Filter header: simple=0, level=0, sharpness=0, no lf_delta
  BWPutBitUniform(bw, 0);  // simple
  BWPutBits(bw, 0, 6);     // level
  BWPutBits(bw, 0, 3);     // sharpness
  BWPutBitUniform(bw, 0);  // use_lf_delta=0
  // log2 number of token partitions (0 = 1 partition)
  BWPutBits(bw, 0, 2);
  // Quantization: baseQ + 5 zero deltas
  BWPutBits(bw, Cardinal(baseQ), 7);
  BWPutSignedBits(bw, 0, 4); BWPutSignedBits(bw, 0, 4);
  BWPutSignedBits(bw, 0, 4); BWPutSignedBits(bw, 0, 4);
  BWPutSignedBits(bw, 0, 4);
  // refresh_proba=0 (use default probabilities, no update)
  BWPutBitUniform(bw, 0);
  // VP8WriteProbas: since we use default probas, all update bits = 0
  for t := 0 to 3 do
    for b := 0 to 7 do
      for c := 0 to 2 do
        for pp := 0 to 10 do
          BWPutBit(bw, 0, kEncUpdateProba[t,b,c,pp]);
  // skip_proba=0
  BWPutBitUniform(bw, 0);
  // Per-MB intra modes (all I16x16 DC + UV DC)
  for mb := 0 to mbsX * mbsY - 1 do begin
    // VP8PutBit(type!=0, 145): type=1 (i16x16) → code 1
    BWPutBit(bw, 1, 145);
    // PutI16Mode(DC_PRED=0):
    //   VP8PutBit(TM||H, 156) → 0
    //   VP8PutBit(V_PRED, 163) → 0
    BWPutBit(bw, 0, 156); BWPutBit(bw, 0, 163);
    // PutUVMode(DC_PRED=0):
    //   VP8PutBit(not DC, 142) → 0
    BWPutBit(bw, 0, 142);
  end;
end;

// ===========================================================================
// Inverse transforms + dequant (for in-encoder reconstruction)
// ===========================================================================

function EncClip8(v: Integer): Byte; inline;
begin
  if v < 0 then Result := 0
  else if v > 255 then Result := 255
  else Result := Byte(v);
end;

function EncMUL1(a: Integer): Integer; inline;
begin
  Result := SarI(a * 20091, 16) + a;
end;

function EncMUL2(a: Integer): Integer; inline;
begin
  Result := SarI(a * 35468, 16);
end;

// Inverse 4x4 DCT of natural-order coeffs 'c', add scalar 'pred', clip, write to dst (stride).
procedure IDCTAdd(const c: TInt16x16; pred: Integer; dst: PByte; stride: Integer);
var i, a, b, c2, d2: Integer; tmp: array[0..15] of Integer;
begin
  for i := 0 to 3 do begin
    a  := c[0+i] + c[8+i];
    b  := c[0+i] - c[8+i];
    c2 := EncMUL2(c[4+i]) - EncMUL1(c[12+i]);
    d2 := EncMUL1(c[4+i]) + EncMUL2(c[12+i]);
    tmp[i*4+0] := a + d2; tmp[i*4+1] := b + c2;
    tmp[i*4+2] := b - c2; tmp[i*4+3] := a - d2;
  end;
  for i := 0 to 3 do begin
    a  := tmp[0+i] + tmp[8+i];
    b  := tmp[0+i] - tmp[8+i];
    c2 := EncMUL2(tmp[4+i]) - EncMUL1(tmp[12+i]);
    d2 := EncMUL1(tmp[4+i]) + EncMUL2(tmp[12+i]);
    (dst + i*stride + 0)^ := EncClip8(pred + SarI(a + d2 + 4, 3));
    (dst + i*stride + 1)^ := EncClip8(pred + SarI(b + c2 + 4, 3));
    (dst + i*stride + 2)^ := EncClip8(pred + SarI(b - c2 + 4, 3));
    (dst + i*stride + 3)^ := EncClip8(pred + SarI(a - d2 + 4, 3));
  end;
end;

// Inverse WHT: 16 natural-order DC coeffs (in) -> 16 block DCs (out, natural order).
procedure IWHT(const inp: TInt16x16; var outDC: TInt16x16);
var i, a0, a1, a2, a3, b0, b1, b2, b3: Integer; tmp: array[0..15] of Integer;
begin
  for i := 0 to 3 do begin
    a0 := inp[0+i] + inp[12+i];
    a1 := inp[4+i] + inp[8+i];
    a2 := inp[4+i] - inp[8+i];
    a3 := inp[0+i] - inp[12+i];
    tmp[0+i]  := a0 + a1;
    tmp[8+i]  := a0 - a1;
    tmp[4+i]  := a3 + a2;
    tmp[12+i] := a3 - a2;
  end;
  for i := 0 to 3 do begin
    b0 := tmp[0+i*4] + tmp[3+i*4];
    b1 := tmp[1+i*4] + tmp[2+i*4];
    b2 := tmp[1+i*4] - tmp[2+i*4];
    b3 := tmp[0+i*4] - tmp[3+i*4];
    outDC[0+i*4] := SmallInt(SarI(b0 + b1 + 3, 3));
    outDC[1+i*4] := SmallInt(SarI(b3 + b2 + 3, 3));
    outDC[2+i*4] := SmallInt(SarI(b0 - b1 + 3, 3));
    outDC[3+i*4] := SmallInt(SarI(b3 - b2 + 3, 3));
  end;
end;

// Dequantize a zigzag-order level block 'lev' into natural-order coeffs 'nat'.
// DC (zigzag pos 0) uses q0; AC uses q1.
procedure DequantBlock(const lev: TInt16x16; q0, q1: Integer; var nat: TInt16x16);
var n: Integer;
begin
  FillChar(nat, SizeOf(nat), 0);
  for n := 0 to 15 do
    if lev[n] <> 0 then
      if n = 0 then nat[kEncZigzag[0]] := SmallInt(lev[0] * q0)
      else          nat[kEncZigzag[n]] := SmallInt(lev[n] * q1);
end;

// ===========================================================================
// DC prediction helpers
// ===========================================================================

function CalcDCPredY16(Y: PByte; yStride, mbx, mby, imgW, imgH: Integer): Integer;
var i, dc: Integer; row, col: PByte;
begin
  dc := 0;
  if (mby > 0) and (mbx > 0) then
  begin
    // top row
    row := Y + (mby*16 - 1) * yStride + mbx*16;
    for i := 0 to 15 do Inc(dc, PByte(row + i)^);
    // left col
    col := Y + mby*16 * yStride + (mbx*16 - 1);
    for i := 0 to 15 do begin Inc(dc, col^); Inc(col, yStride); end;
    Result := (dc + 16) shr 5;
  end else if mby > 0 then
  begin
    row := Y + (mby*16 - 1) * yStride + mbx*16;
    for i := 0 to 15 do Inc(dc, PByte(row + i)^);
    Result := (dc + 8) shr 4;
  end else if mbx > 0 then
  begin
    col := Y + mby*16 * yStride + (mbx*16 - 1);
    for i := 0 to 15 do begin Inc(dc, col^); Inc(col, yStride); end;
    Result := (dc + 8) shr 4;
  end else
    Result := 128;
end;

function CalcDCPredUV8(UV: PByte; uvStride, mbx, mby: Integer): Integer;
var i, dc: Integer; row, col: PByte;
begin
  dc := 0;
  if (mby > 0) and (mbx > 0) then
  begin
    row := UV + (mby*8 - 1) * uvStride + mbx*8;
    for i := 0 to 7 do Inc(dc, PByte(row + i)^);
    col := UV + mby*8 * uvStride + (mbx*8 - 1);
    for i := 0 to 7 do begin Inc(dc, col^); Inc(col, uvStride); end;
    Result := (dc + 8) shr 4;
  end else if mby > 0 then
  begin
    row := UV + (mby*8 - 1) * uvStride + mbx*8;
    for i := 0 to 7 do Inc(dc, PByte(row + i)^);
    Result := (dc + 4) shr 3;
  end else if mbx > 0 then
  begin
    col := UV + mby*8 * uvStride + (mbx*8 - 1);
    for i := 0 to 7 do begin Inc(dc, col^); Inc(col, uvStride); end;
    Result := (dc + 4) shr 3;
  end else
    Result := 128;
end;

// ===========================================================================
// VP8 encoder — internal main function
// Encodes a pre-built YUV420 image.
// ===========================================================================

function VP8EncodeYUV(
  Y: PByte; yStride: Integer;
  U: PByte; uStride: Integer;
  V: PByte; vStride: Integer;
  Width, Height, BaseQ: Integer;
  out OutData: PByte; out OutSize: Integer): Boolean;

var
  mbsX, mbsY, mbx, mby: Integer;
  bx, by, ch: Integer;
  bw0, bw1: TVP8BW;
  p0size, p1size: Integer;
  y1m, y2m, uvm: TVP8EncMatrix;
  q, qUV: Integer;
  diffs  : array[0..15] of SmallInt;
  dctOut : TInt16x16;
  yAcLev : array[0..15] of TInt16x16;
  yDcLev : TInt16x16;
  uvLev  : array[0..7]  of TInt16x16;
  dcsBuf : array[0..15] of SmallInt;
  dctDC  : TInt16x16;
  lastArr: array[0..23] of Integer;  // [0..15]=Y-AC, [16..23]=UV
  lastDC : Integer;
  recNat : TInt16x16;
  recWhtIn, recWhtDC : TInt16x16;
  topNZ  : array of TNZRow;
  leftNZ : TNZRow;
  nz     : Integer;
  yRow, yCol: Integer;
  uvRow, uvCol, uvW, uvH: Integer;
  dcPredY, dcPredU, dcPredV, dcP: Integer;
  planeP : PByte;
  stP    : Integer;
  pixVal : Integer;
  vp8size, riffsize, filesize: Integer;
  vp8chunksize: Integer;
  padByte: Integer;
  out8   : PByte;
  bits32 : Cardinal;
  wptr   : PByte;
  r, c, pr, pc: Integer;
  chNZ   : Integer;
begin
  Result  := False;
  OutData := nil;
  OutSize := 0;

  if (Width <= 0) or (Height <= 0) then Exit;

  mbsX := (Width  + 15) shr 4;
  mbsY := (Height + 15) shr 4;
  uvW  := (Width  + 1)  shr 1;
  uvH  := (Height + 1)  shr 1;

  if BaseQ < 0   then BaseQ := 0;
  if BaseQ > 127 then BaseQ := 127;

  q    := BaseQ;
  qUV  := q; if qUV > 117 then qUV := 117;
  SetupEncMatrix(y1m, 0, kDcTable[q],    kAcTable[q]);
  SetupEncMatrix(y2m, 1, kDcTable[q]*2,  kAcTable2[q]);
  SetupEncMatrix(uvm, 2, kDcTable[qUV],  kAcTable[q]);

  BWInit(bw0); BWInit(bw1);
  if (bw0.buf = nil) or (bw1.buf = nil) then begin BWFree(bw0); BWFree(bw1); Exit; end;

  WritePartition0(bw0, BaseQ, mbsX, mbsY);
  p0size := BWFinish(bw0);

  SetLength(topNZ, mbsX);
  for mbx := 0 to mbsX-1 do FillChar(topNZ[mbx], SizeOf(TNZRow), 0);

  for mby := 0 to mbsY-1 do begin
    FillChar(leftNZ, SizeOf(leftNZ), 0);
    for mbx := 0 to mbsX-1 do begin

      // ----- Y luma blocks -----
      dcPredY := CalcDCPredY16(Y, yStride, mbx, mby, Width, Height);
      FillChar(dcsBuf, SizeOf(dcsBuf), 0);

      for by := 0 to 3 do
        for bx := 0 to 3 do begin
          yRow := mby*16 + by*4;
          yCol := mbx*16 + bx*4;
          for r := 0 to 3 do
            for c := 0 to 3 do begin
              pr := yRow + r; pc := yCol + c;
              if pr >= Height then pr := Height-1;
              if pc >= Width  then pc := Width-1;
              pixVal := PByte(Y + pr*yStride + pc)^ - dcPredY;
              diffs[r*4+c] := SmallInt(pixVal);
            end;
          FTransform4x4(diffs, dctOut);
          dcsBuf[by*4+bx] := dctOut[0];
          dctOut[0] := 0;
          lastArr[by*4+bx] := QuantizeOneBlock(dctOut, y1m, 1, yAcLev[by*4+bx]);
        end;

      FTransformWHT(dcsBuf, dctDC);
      lastDC := QuantizeOneBlock(dctDC, y2m, 0, yDcLev);

      // ----- UV chroma blocks -----
      dcPredU := CalcDCPredUV8(U, uStride, mbx, mby);
      dcPredV := CalcDCPredUV8(V, vStride, mbx, mby);

      for ch := 0 to 1 do begin
        if ch = 0 then begin dcP := dcPredU; planeP := U; stP := uStride; end
        else            begin dcP := dcPredV; planeP := V; stP := vStride; end;
        for by := 0 to 1 do
          for bx := 0 to 1 do begin
            uvRow := mby*8 + by*4;
            uvCol := mbx*8 + bx*4;
            for r := 0 to 3 do
              for c := 0 to 3 do begin
                pr := uvRow+r; pc := uvCol+c;
                if pr >= uvH then pr := uvH-1;
                if pc >= uvW then pc := uvW-1;
                pixVal := PByte(planeP + pr*stP + pc)^ - dcP;
                diffs[r*4+c] := SmallInt(pixVal);
              end;
            FTransform4x4(diffs, dctOut);
            lastArr[16 + ch*4 + by*2+bx] :=
              QuantizeOneBlock(dctOut, uvm, 0, uvLev[ch*4 + by*2+bx]);
          end;
      end;

      // ----- Reconstruct this MB into the YUV planes (so later MBs predict
      //        from reconstructed pixels, exactly like the decoder) -----
      // Y: inverse-WHT the dequantized DC levels, then inverse-DCT each block.
      DequantBlock(yDcLev, y2m.q[0], y2m.q[1], recWhtIn);
      IWHT(recWhtIn, recWhtDC);

      for by := 0 to 3 do
        for bx := 0 to 3 do begin
          DequantBlock(yAcLev[by*4+bx], y1m.q[0], y1m.q[1], recNat);
          recNat[0] := recWhtDC[by*4+bx];
          IDCTAdd(recNat, dcPredY,
                  Y + (mby*16 + by*4)*yStride + (mbx*16 + bx*4), yStride);
        end;
      // U / V
      for ch := 0 to 1 do begin
        if ch = 0 then begin dcP := dcPredU; planeP := U; stP := uStride; end
        else            begin dcP := dcPredV; planeP := V; stP := vStride; end;
        for by := 0 to 1 do
          for bx := 0 to 1 do begin
            DequantBlock(uvLev[ch*4 + by*2+bx], uvm.q[0], uvm.q[1], recNat);
            IDCTAdd(recNat, dcP,
                    planeP + (mby*8 + by*4)*stP + (mbx*8 + bx*4), stP);
          end;
      end;

      // ----- Code residuals -----

      // Y DC (coeffType=1, first=0)
      nz := PutCoeffs(bw1, topNZ[mbx][8]+leftNZ[8], 1, 0, lastDC, yDcLev);
      topNZ[mbx][8] := nz;
      leftNZ[8] := nz;

      // Y AC (coeffType=0, first=1)
      for by := 0 to 3 do
        for bx := 0 to 3 do begin
          nz := PutCoeffs(bw1, topNZ[mbx][bx]+leftNZ[by], 0, 1,
                          lastArr[by*4+bx], yAcLev[by*4+bx]);
          topNZ[mbx][bx] := nz; leftNZ[by] := nz;
        end;

      // UV (coeffType=2, first=0)
      for ch := 0 to 1 do begin
        chNZ := 4 + ch*2;
        for by := 0 to 1 do
          for bx := 0 to 1 do begin
            nz := PutCoeffs(bw1, topNZ[mbx][chNZ+bx]+leftNZ[chNZ+by], 2, 0,
                            lastArr[16 + ch*4 + by*2+bx], uvLev[ch*4 + by*2+bx]);
            topNZ[mbx][chNZ+bx] := nz; leftNZ[chNZ+by] := nz;
          end;
      end;

    end; // mbx
  end; // mby

  p1size := BWFinish(bw1);

  // Assemble RIFF/VP8 output
  vp8size     := 10 + p0size + p1size;
  padByte     := vp8size and 1;
  vp8chunksize:= vp8size + padByte;
  riffsize    := 4 + 8 + vp8chunksize;
  filesize    := 4 + 4 + riffsize;   // 'RIFF' + size_field + riffsize

  GetMem(out8, filesize);
  if out8 = nil then
  begin
    BWFree(bw0);
    BWFree(bw1);
    Exit;
  end;

  wptr := out8;
  // "RIFF" fourcc + riffsize
  wptr[0]:=Ord('R');
  wptr[1]:=Ord('I');
  wptr[2]:=Ord('F');
  wptr[3]:=Ord('F');
  Inc(wptr,4);
  wptr[0]:=riffsize and $ff;
  wptr[1]:=(riffsize shr 8) and $ff;
  wptr[2]:=(riffsize shr 16) and $ff;
  wptr[3]:=(riffsize shr 24) and $ff;
  Inc(wptr,4);
  // "WEBP"
  wptr[0]:=Ord('W');
  wptr[1]:=Ord('E');
  wptr[2]:=Ord('B');
  wptr[3]:=Ord('P');
  Inc(wptr,4);
  // "VP8 " chunk header
  wptr[0]:=Ord('V');
  wptr[1]:=Ord('P');
  wptr[2]:=Ord('8');
  wptr[3]:=Ord(' ');
  Inc(wptr,4);
  wptr[0]:=vp8chunksize and $ff;
  wptr[1]:=(vp8chunksize shr 8) and $ff;
  wptr[2]:=(vp8chunksize shr 16) and $ff;
  wptr[3]:=(vp8chunksize shr 24) and $ff;
  Inc(wptr,4);
  // VP8 frame header (10 bytes)
  bits32 := Cardinal(p0size) shl 5 or (1 shl 4);  // keyframe=0, profile=0, show=1
  wptr[0]:=bits32 and $ff;
  wptr[1]:=(bits32 shr 8) and $ff;
  wptr[2]:=(bits32 shr 16) and $ff;
  Inc(wptr,3);
  wptr[0]:=$9D;
  wptr[1]:=$01;
  wptr[2]:=$2A;
  Inc(wptr,3);
  wptr[0]:=Width  and $ff;
  wptr[1]:=(Width  shr 8) and $ff;
  wptr[2]:=Height and $ff;
  wptr[3]:=(Height shr 8) and $ff;
  Inc(wptr,4);
  // partition 0
  Move(bw0.buf^, wptr^, p0size);
  Inc(wptr, p0size);
  // token partition
  Move(bw1.buf^, wptr^, p1size);
  Inc(wptr, p1size);
  // padding
  if padByte <> 0 then
  begin
    wptr^ := 0;
    Inc(wptr);
  end;

  BWFree(bw0); BWFree(bw1);
  OutData := out8;
  OutSize := filesize;
  Result  := True;
end;

// ===========================================================================
// Internal encode-from-pixels dispatcher
// ===========================================================================

type TPixelOrder = (poRGB, poRGBA, poBGR, poBGRA);

function EncodePixels(Pixels: PByte; Width, Height, Stride: Integer;
                      PixOrder: TPixelOrder; Quality: Single;
                      out OutData: PByte; out OutSize: Integer): Boolean;
var
  bpp, mbsX, mbsY, uvW, uvH: Integer;
  Y, U, V: PByte;
  px, py: Integer;
  r, g, b: Integer;
  psrc: PByte;
  baseQ: Integer;
  cx, cy, dx, dy, sx, sy, sr, sg, sb: Integer;
  ysE, uvsE: Integer;
begin
  Result  := False;
  OutData := nil; OutSize := 0;

  if (Width <= 0) or (Height <= 0) or (Pixels = nil) then Exit;

  case PixOrder of
    poRGB, poBGR:  bpp := 3;
    poRGBA, poBGRA: bpp := 4;
  else bpp := 3;
  end;

  mbsX := (Width  + 15) shr 4;
  mbsY := (Height + 15) shr 4;
  uvW  := (Width  + 1)  shr 1;
  uvH  := (Height + 1)  shr 1;

  // MB-aligned plane dimensions (so reconstruction never overflows).
  ysE := mbsX * 16;    // luma plane stride
  uvsE := mbsX * 8;    // chroma plane stride
  GetMem(Y, ysE * mbsY*16);
  GetMem(U, uvsE * mbsY*8);
  GetMem(V, uvsE * mbsY*8);
  if (Y=nil) or (U=nil) or (V=nil) then begin
    FreeMem(Y); FreeMem(U); FreeMem(V); Exit;
  end;

  // Luma: fill the full MB-aligned plane with edge-replicated source.
  for py := 0 to mbsY*16 - 1 do begin
    sy := py; if sy >= Height then sy := Height-1;
    for px := 0 to ysE - 1 do begin
      sx := px; if sx >= Width then sx := Width-1;
      psrc := Pixels + sy*Stride + sx*bpp;

      case PixOrder of
        poBGR, poBGRA: begin b:=psrc[0]; g:=psrc[1]; r:=psrc[2]; end;
        else           begin r:=psrc[0]; g:=psrc[1]; b:=psrc[2]; end;
      end;
      PByte(Y + py*ysE + px)^ := RGBToY(r,g,b);
    end;
  end;

  // Chroma: each sample = average of the 2x2 source block (clamped). libwebp's
  // ClipUV >>18 already divides by an extra factor 4, so pass the 4-pixel sum.
  for cy := 0 to mbsY*8 - 1 do
    for cx := 0 to uvsE - 1 do
      begin
      sr := 0;
      sg := 0;
      sb := 0;
      for dy := 0 to 1 do
        for dx := 0 to 1 do begin
          sx := cx*2 + dx; if sx >= Width  then sx := Width-1;
          sy := cy*2 + dy; if sy >= Height then sy := Height-1;
          psrc := Pixels + sy*Stride + sx*bpp;

          case PixOrder of
            poBGR, poBGRA: begin Inc(sb,psrc[0]); Inc(sg,psrc[1]); Inc(sr,psrc[2]); end;
            else           begin Inc(sr,psrc[0]); Inc(sg,psrc[1]); Inc(sb,psrc[2]); end;
          end;
        end;
      PByte(U + cy*uvsE + cx)^ := RGBToU(sr, sg, sb);
      PByte(V + cy*uvsE + cx)^ := RGBToV(sr, sg, sb);
    end;

  baseQ := QualityToBaseQ(Quality);

  Result := VP8EncodeYUV(Y, ysE, U, uvsE, V, uvsE,
                         Width, Height, baseQ, OutData, OutSize);

  FreeMem(Y); FreeMem(U); FreeMem(V);
end;

// ===========================================================================
// VP8L (LOSSLESS) ENCODER
//   Minimal but spec-compliant: no transforms, no color cache, single Huffman
//   group, literal pixels only (no backward references). Produces a valid
//   VP8L stream that round-trips losslessly.
// ===========================================================================

type
  TLBW = record           // LSB-first bit writer
    buf:   PByte;
    pos:   Integer;
    alloc: Integer;
    bits:  UInt64;
    nbits: Integer;
  end;

procedure LBWInit(var bw: TLBW);
begin
  FillChar(bw, SizeOf(bw), 0);
  GetMem(bw.buf, 4096); bw.alloc := 4096;
end;

procedure LBWPut(var bw: TLBW; val: Cardinal; n: Integer);
var nb: PByte;
begin
  if n = 0 then Exit;
  bw.bits := bw.bits or (UInt64(val and ((Cardinal(1) shl n) - 1)) shl bw.nbits);
  Inc(bw.nbits, n);

  while bw.nbits >= 8 do begin
    if bw.pos >= bw.alloc then begin
      nb := ReallocMemory(bw.buf, bw.alloc * 2);
      if nb = nil then Exit;
      bw.buf := nb; bw.alloc := bw.alloc * 2;
    end;
    bw.buf[bw.pos] := Byte(bw.bits and $FF); Inc(bw.pos);
    bw.bits := bw.bits shr 8;
    Dec(bw.nbits, 8);
  end;
end;

function LBWFinish(var bw: TLBW): Integer;
var nb: PByte;
begin
  if bw.nbits > 0 then begin
    if bw.pos >= bw.alloc then
    begin
      nb := ReallocMemory(bw.buf, bw.alloc + 16);
      bw.buf := nb;
      bw.alloc := bw.alloc + 16;
    end;
    bw.buf[bw.pos] := Byte(bw.bits and $FF);
    Inc(bw.pos);
    bw.nbits := 0;
    bw.bits := 0;
  end;
  Result := bw.pos;
end;

procedure LBWFree(var bw: TLBW);
begin
  if bw.buf <> nil then
  begin
    FreeMem(bw.buf);
    bw.buf := nil;
    bw.alloc := 0;
  end;
end;

function RevBits(v: Cardinal; n: Integer): Cardinal;
var i: Integer;
begin
  Result := 0;
  for i := 0 to n-1 do Result := (Result shl 1) or ((v shr i) and 1);
end;

// Compute Huffman code lengths from symbol counts, limited to maxLen bits.
procedure HuffLengths(counts: PInteger; n, maxLen: Integer; lengths: PByte);
var
  wt:     array of Int64;
  par:    array of Integer;
  used:   array of Boolean;
  leaf:   array of Integer;
  cnt:    array of Integer;
  m, i, total, a, b, node, d, mx, act: Integer;
  bestA, bestB: Integer;
begin
  for i := 0 to n-1 do lengths[i] := 0;
  SetLength(cnt, n);
  for i := 0 to n-1 do cnt[i] := PIntegerArray(counts)^[i]; //do cnt[i] := counts[i];
  SetLength(wt, 2*n);
  SetLength(par, 2*n);
  SetLength(used, 2*n);
  SetLength(leaf, 2*n);

  while True do begin
    // collect leaves
    m := 0;
    for i := 0 to n-1 do
      if cnt[i] > 0 then
      begin
        wt[m] := cnt[i];
        par[m] := -1;
        used[m] := True;
        leaf[m] := i;
        Inc(m);
      end;
    for i := 0 to n-1 do lengths[i] := 0;
    if m = 0 then Exit;
    if m = 1 then begin lengths[leaf[0]] := 1; Exit; end;
    total := m;
    // build tree by repeated min-merge
    while True do begin
      act := 0;
      for i := 0 to total-1 do if used[i] then Inc(act);
      if act <= 1 then Break;
      bestA := -1;
      bestB := -1;

      for i := 0 to total-1 do
        if used[i] then begin
          if (bestA < 0) or (wt[i] < wt[bestA]) then
          begin
            bestB := bestA;
            bestA := i;
          end
          else if (bestB < 0) or (wt[i] < wt[bestB]) then bestB := i;
        end;
      a := bestA; b := bestB;
      wt[total] := wt[a] + wt[b];
      par[total] := -1;
      used[total] := True;
      par[a] := total;
      used[a] := False;
      par[b] := total;
      used[b] := False;
      Inc(total);
    end;
    // assign lengths = depth
    mx := 0;
    for i := 0 to m-1 do begin
      d := 0; node := i;
      while par[node] >= 0 do
      begin
        node := par[node]; Inc(d);
      end;
      lengths[leaf[i]] := Byte(d);
      if d > mx then mx := d;
    end;
    if mx <= maxLen then Exit;
    // too deep: flatten histogram and retry
    for i := 0 to n-1 do if cnt[i] > 0 then cnt[i] := (cnt[i] + 1) shr 1;
  end;
end;

// Generate canonical codes (bit-reversed for LSB-first writing) from lengths.
procedure GenCodes(lengths: PByte; n: Integer; codes: PCardinal);
var
  blCount: array[0..15] of Integer;
  nextCode: array[0..15] of Cardinal;
  i, len: Integer;
  code: Cardinal;
  L: PByteArray;
  C: PCardinalArray;
begin
  L := PByteArray(lengths);
  C := PCardinalArray(codes);

  FillChar(blCount, SizeOf(blCount), 0);

  for i := 0 to n - 1 do
    Inc(blCount[L^[i]]);

  blCount[0] := 0;
  code := 0;

  FillChar(nextCode, SizeOf(nextCode), 0);

  for len := 1 to 15 do
  begin
    code := (code + Cardinal(blCount[len - 1])) shl 1;
    nextCode[len] := code;
  end;

  for i := 0 to n - 1 do
  begin
    len := L^[i];

    if len <> 0 then
    begin
      C^[i] := RevBits(nextCode[len], len);
      Inc(nextCode[len]);
    end
    else
      C^[i] := 0;
  end;
end;

// Emit a Huffman table to the bitstream and fill writeLen/writeCode for symbols.
procedure WriteHuffTable(var bw: TLBW; counts: PInteger; n: Integer;
  writeLen: PByte; writeCode: PCardinal);
var
  lengths: array of Byte;
  i, m, s1, s2, j, numCodes: Integer;
  clCounts: array[0..18] of Integer;
  clLen: array[0..18] of Byte;
  clCode: array[0..18] of Cardinal;
  WL: PByteArray;
  WC: PCardinalArray;
begin
  WL := PByteArray(writeLen);
  WC := PCardinalArray(writeCode);

  SetLength(lengths, n);
  HuffLengths(counts, n, 15, @lengths[0]);

  // count distinct symbols length > 0
  m := 0;
  s1 := -1;
  s2 := -1;

  for i := 0 to n - 1 do
    if lengths[i] > 0 then
    begin
      Inc(m);
      if s1 < 0 then
        s1 := i
      else if s2 < 0 then
        s2 := i;
    end;

  if m <= 2 then
  begin
    LBWPut(bw, 1, 1);              // is_simple = 1

    if m = 0 then
    begin
      s1 := 0;
      m := 1;
    end;

    LBWPut(bw, Cardinal(m - 1), 1); // num_symbols - 1

    if s1 < 2 then
    begin
      LBWPut(bw, 0, 1);
      LBWPut(bw, Cardinal(s1), 1);
    end
    else
    begin
      LBWPut(bw, 1, 1);
      LBWPut(bw, Cardinal(s1), 8);
    end;

    for i := 0 to n - 1 do
    begin
      WL^[i] := 0;
      WC^[i] := 0;
    end;

    if m = 2 then
    begin
      LBWPut(bw, Cardinal(s2), 8);

      // canonical length-1 codes: smaller symbol -> 0, larger -> 1
      WL^[s1] := 1;
      WC^[s1] := 0;

      WL^[s2] := 1;
      WC^[s2] := 1;
    end;

    // m = 1 -> writeLen stays 0, decoder consumes 0 bits
    Exit;
  end;

  // complex code
  LBWPut(bw, 0, 1);                          // is_simple = 0
  // histogram of code-length values -> CL alphabet
  FillChar(clCounts, SizeOf(clCounts), 0);
  for i := 0 to n-1 do Inc(clCounts[lengths[i]]);
  HuffLengths(@clCounts[0], 19, 7, @clLen[0]);
  GenCodes(@clLen[0], 19, @clCode[0]);
  // number of CL codes to send (>=4)
  numCodes := 19;
  while (numCodes > 4) and (clLen[kEncCLOrder[numCodes-1]] = 0) do Dec(numCodes);
  LBWPut(bw, Cardinal(numCodes - 4), 4);
  for j := 0 to numCodes-1 do LBWPut(bw, clLen[kEncCLOrder[j]], 3);
  LBWPut(bw, 0, 1);                          // use_length = 0 (max_symbol = n)
  // emit each symbol's code length via the CL Huffman
  for i := 0 to n-1 do
    LBWPut(bw, clCode[lengths[i]], clLen[lengths[i]]);
  // main canonical codes for writing pixels
  GenCodes(@lengths[0], n, writeCode);
  for i := 0 to n-1 do writeLen[i] := lengths[i];
end;

function VP8LEncode(argb: PCardinal; w, h: Integer;
  out OutData: PByte; out OutSize: Integer): Boolean;
var
  bw: TLBW;
  npix, i, bsSize, fileSize: Integer;
  histG: array[0..279] of Integer;
  histR, histB, histA: array[0..255] of Integer;
  histD: array[0..39] of Integer;
  lenG: array[0..279] of Byte;
  codeG: array[0..279] of Cardinal;
  lenR, lenB, lenA: array[0..255] of Byte;
  codeR, codeB, codeA: array[0..255] of Cardinal;
  lenD: array[0..39] of Byte;
  codeD: array[0..39] of Cardinal;
  px: Cardinal;
  g, r, b, a: Integer;
  alphaUsed: Integer;
  out8, wptr: PByte;
  riffsize, chunksize, padByte: Integer;
  ARGBArr: PCardinalArray;
  WPtrArr: PByteArray;
begin
  Result := False;
  OutData := nil;
  OutSize := 0;

  if (w <= 0) or (h <= 0) or (w > 16384) or (h > 16384) or (argb = nil) then
    Exit;

  npix := w * h;
  ARGBArr := PCardinalArray(argb);

  FillChar(histG, SizeOf(histG), 0);
  FillChar(histR, SizeOf(histR), 0);
  FillChar(histB, SizeOf(histB), 0);
  FillChar(histA, SizeOf(histA), 0);
  FillChar(histD, SizeOf(histD), 0);

  alphaUsed := 0;

  for i := 0 to npix - 1 do
  begin
    px := ARGBArr^[i];

    Inc(histG[(px shr 8) and $FF]);
    Inc(histR[(px shr 16) and $FF]);
    Inc(histB[px and $FF]);
    Inc(histA[(px shr 24) and $FF]);

    if (px shr 24) <> $FF then
      alphaUsed := 1;
  end;

  histD[0] := 1; // single dummy distance symbol, never emitted

  LBWInit(bw);
  if bw.buf = nil then
    Exit;

  LBWPut(bw, Cardinal(w - 1), 14);
  LBWPut(bw, Cardinal(h - 1), 14);
  LBWPut(bw, Cardinal(alphaUsed), 1);
  LBWPut(bw, 0, 3); // version
  LBWPut(bw, 0, 1); // no transform
  LBWPut(bw, 0, 1); // no color cache
  LBWPut(bw, 0, 1); // no meta-Huffman, single group

  WriteHuffTable(bw, @histG[0], 280, @lenG[0], @codeG[0]);
  WriteHuffTable(bw, @histR[0], 256, @lenR[0], @codeR[0]);
  WriteHuffTable(bw, @histB[0], 256, @lenB[0], @codeB[0]);
  WriteHuffTable(bw, @histA[0], 256, @lenA[0], @codeA[0]);
  WriteHuffTable(bw, @histD[0], 40, @lenD[0], @codeD[0]);

  for i := 0 to npix - 1 do
  begin
    px := ARGBArr^[i];

    g := (px shr 8) and $FF;
    r := (px shr 16) and $FF;
    b := px and $FF;
    a := (px shr 24) and $FF;

    LBWPut(bw, codeG[g], lenG[g]);
    LBWPut(bw, codeR[r], lenR[r]);
    LBWPut(bw, codeB[b], lenB[b]);
    LBWPut(bw, codeA[a], lenA[a]);
  end;

  bsSize := LBWFinish(bw);

  chunksize := 1 + bsSize;
  padByte := chunksize and 1;
  riffsize := 4 + 8 + chunksize + padByte;
  fileSize := 8 + riffsize;

  GetMem(out8, fileSize);
  if out8 = nil then
  begin
    LBWFree(bw);
    Exit;
  end;

  wptr := out8;

  WPtrArr := PByteArray(wptr);
  WPtrArr^[0] := Ord('R');
  WPtrArr^[1] := Ord('I');
  WPtrArr^[2] := Ord('F');
  WPtrArr^[3] := Ord('F');
  Inc(wptr, 4);

  WPtrArr := PByteArray(wptr);
  WPtrArr^[0] := riffsize and $FF;
  WPtrArr^[1] := (riffsize shr 8) and $FF;
  WPtrArr^[2] := (riffsize shr 16) and $FF;
  WPtrArr^[3] := (riffsize shr 24) and $FF;
  Inc(wptr, 4);

  WPtrArr := PByteArray(wptr);
  WPtrArr^[0] := Ord('W');
  WPtrArr^[1] := Ord('E');
  WPtrArr^[2] := Ord('B');
  WPtrArr^[3] := Ord('P');
  Inc(wptr, 4);

  WPtrArr := PByteArray(wptr);
  WPtrArr^[0] := Ord('V');
  WPtrArr^[1] := Ord('P');
  WPtrArr^[2] := Ord('8');
  WPtrArr^[3] := Ord('L');
  Inc(wptr, 4);

  WPtrArr := PByteArray(wptr);
  WPtrArr^[0] := chunksize and $FF;
  WPtrArr^[1] := (chunksize shr 8) and $FF;
  WPtrArr^[2] := (chunksize shr 16) and $FF;
  WPtrArr^[3] := (chunksize shr 24) and $FF;
  Inc(wptr, 4);

  wptr^ := $2F; // VP8L signature
  Inc(wptr);

  Move(bw.buf^, wptr^, bsSize);
  Inc(wptr, bsSize);

  if padByte <> 0 then
  begin
    wptr^ := 0;
    Inc(wptr);
  end;

  LBWFree(bw);

  OutData := out8;
  OutSize := fileSize;
  Result := True;
end;

function EncodeLossless(Pixels: PByte; Width, Height, Stride: Integer;
  PixOrder: TPixelOrder; out OutData: PByte; out OutSize: Integer): Boolean;
var
  bpp, x, y: Integer;
  argb: PCardinal;
  argbArr: PCardinalArray;
  psrc: PByte;
  rr, gg, bb, aa: Cardinal;
begin
  Result := False;
  OutData := nil;
  OutSize := 0;

  if (Width <= 0) or (Height <= 0) or (Pixels = nil) then
    Exit;

  case PixOrder of
    poRGBA, poBGRA: bpp := 4;
  else
    bpp := 3;
  end;

  GetMem(argb, Width * Height * SizeOf(Cardinal));
  if argb = nil then
    Exit;

  argbArr := PCardinalArray(argb);

  try
    for y := 0 to Height - 1 do
      for x := 0 to Width - 1 do
      begin
        psrc := Pixels + y * Stride + x * bpp;

        case PixOrder of
          poBGR:
            begin
              bb := psrc^;
              gg := (psrc + 1)^;
              rr := (psrc + 2)^;
              aa := 255;
            end;

          poBGRA:
            begin
              bb := psrc^;
              gg := (psrc + 1)^;
              rr := (psrc + 2)^;
              aa := (psrc + 3)^;
            end;

          poRGBA:
            begin
              rr := psrc^;
              gg := (psrc + 1)^;
              bb := (psrc + 2)^;
              aa := (psrc + 3)^;
            end;

        else
          begin
            rr := psrc^;
            gg := (psrc + 1)^;
            bb := (psrc + 2)^;
            aa := 255;
          end;
        end;

        argbArr^[y * Width + x] :=
          (aa shl 24) or (rr shl 16) or (gg shl 8) or bb;
      end;

    Result := VP8LEncode(argb, Width, Height, OutData, OutSize);
  finally
    FreeMem(argb);
  end;
end;

// ===========================================================================
// Public API
// ===========================================================================

function WebPEncodeRGB(const RGB: PByte; Width, Height, Stride: Integer;
                       Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodePixels(RGB,  Width, Height, Stride, poRGB,  Quality, OutData, OutSize); end;

function WebPEncodeRGBA(const RGBA: PByte; Width, Height, Stride: Integer;
                        Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodePixels(RGBA, Width, Height, Stride, poRGBA, Quality, OutData, OutSize); end;

function WebPEncodeBGR(const BGR: PByte; Width, Height, Stride: Integer;
                       Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodePixels(BGR,  Width, Height, Stride, poBGR,  Quality, OutData, OutSize); end;

function WebPEncodeBGRA(const BGRA: PByte; Width, Height, Stride: Integer;
                        Quality: Single; out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodePixels(BGRA, Width, Height, Stride, poBGRA, Quality, OutData, OutSize); end;

// ---- Lossless (VP8L) ----
function WebPEncodeLosslessRGB(const RGB: PByte; Width, Height, Stride: Integer;
                              out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodeLossless(RGB,  Width, Height, Stride, poRGB,  OutData, OutSize); end;

function WebPEncodeLosslessRGBA(const RGBA: PByte; Width, Height, Stride: Integer;
                               out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodeLossless(RGBA, Width, Height, Stride, poRGBA, OutData, OutSize); end;

function WebPEncodeLosslessBGR(const BGR: PByte; Width, Height, Stride: Integer;
                              out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodeLossless(BGR,  Width, Height, Stride, poBGR,  OutData, OutSize); end;

function WebPEncodeLosslessBGRA(const BGRA: PByte; Width, Height, Stride: Integer;
                               out OutData: PByte; out OutSize: Integer): Boolean;
begin Result := EncodeLossless(BGRA, Width, Height, Stride, poBGRA, OutData, OutSize); end;

end.
