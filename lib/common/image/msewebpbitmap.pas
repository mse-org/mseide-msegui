{ MSEgui WebP adapter
  Copyright (c) 2026

  See the file COPYING.MSE, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewebpbitmap;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$R-}{$Q-}

interface

uses
 classes, sysutils, msetypes, msegraphutils, msegraphics, msebitmap,
 WebPDec, WebPEnc;

procedure LoadBGRAIntoMSEBitmap(const Pixels: PByte; Width, Height: Integer;
  const Dest: tmaskedbitmap);

function MSEBitmapToBGRA(const Source: tmaskedbitmap;
  out Width, Height: Integer): PByte;

function MSEBitmapToBGR(const Source: tmaskedbitmap;
  out Width, Height: Integer): PByte;

implementation

uses
 mseguiintf;

// ---------------------------------------------------------------------------
// BGRA -> tmaskedbitmap
// ---------------------------------------------------------------------------

procedure LoadBGRAIntoMSEBitmap(const Pixels: PByte; Width, Height: Integer;
  const Dest: tmaskedbitmap);
var
  x, y: Integer;
  src: PByte;
  dstline: prgbtriplety;
  hasalpha: Boolean;
  mimg: imagety;
  mline: PByte;
begin
  if (Width <= 0) or (Height <= 0) or (Pixels = nil) then
  begin
    Dest.clear;
    Exit;
  end;

  Dest.beginupdate;
  try
    Dest.masked := False;
    Dest.kind := bmk_rgb;
    Dest.size := makesize(Width, Height);

    // First pass: copy RGB, detect non-opaque alpha
    hasalpha := False;
    src := Pixels;
    for y := 0 to Height - 1 do
    begin
      dstline := Dest.scanline[y];
      for x := 0 to Width - 1 do
      begin
        dstline[x].red   := src[2];
        dstline[x].green := src[1];
        dstline[x].blue  := src[0];
        dstline[x].res   := 0;
        if src[3] <> $ff then hasalpha := True;
        Inc(src, 4);
      end;
    end;

    // Second pass: build a bmk_gray mask from the alpha channel if needed
    if hasalpha then
    begin
      fillchar(mimg, sizeof(mimg), 0);
      allocimage(mimg, makesize(Width, Height), bmk_gray);
      try
        src := Pixels;
        for y := 0 to Height - 1 do
        begin
          mline := @pbyte(mimg.pixels)[NativeUInt(y) * NativeUInt(mimg.linebytes)];
          for x := 0 to Width - 1 do
          begin
            mline[x] := src[3];
            Inc(src, 4);
          end;
        end;
        Dest.graymask := True;
        Dest.masked := True;
        Dest.mask.loadfromimage(mimg);
      finally
        if mimg.pixels <> nil then
          gui_freeimagemem(mimg.pixels);
      end;
    end;
  finally
    Dest.endupdate;
  end;
end;

// ---------------------------------------------------------------------------
// tmaskedbitmap -> BGRA
// ---------------------------------------------------------------------------

function MSEBitmapToBGRA(const Source: tmaskedbitmap;
  out Width, Height: Integer): PByte;
var
  x, y: Integer;
  dst: PByte;
  srcline: prgbtriplety;
  maskline: PByte;
  maskkind: bitmapkindty;
  hasmask: Boolean;
  a: Byte;
  lwo: longword;
begin
  Result := nil;
  Width := 0;
  Height := 0;
  if (Source = nil) or Source.isempty then Exit;

  Width  := Source.size.cx;
  Height := Source.size.cy;
  if (Width <= 0) or (Height <= 0) then Exit;

  // Source.mask triggers checkmask internally; Source.scanline triggers checkimage
  hasmask := Source.masked and (Source.mask <> nil);
  maskkind := bmk_mono;
  if hasmask then
    maskkind := Source.mask.kind;

  GetMem(Result, NativeUInt(Width) * NativeUInt(Height) * 4);
  dst := Result;
  for y := 0 to Height - 1 do
  begin
    srcline := Source.scanline[y];
    if hasmask then
      maskline := Source.mask.scanline[y]
    else
      maskline := nil;
    for x := 0 to Width - 1 do
    begin
      dst[0] := srcline[x].blue;
      dst[1] := srcline[x].green;
      dst[2] := srcline[x].red;
      if not hasmask then
        dst[3] := $ff
      else
      begin
        case maskkind of
          bmk_mono:
          begin
            lwo := plongword(maskline)[x shr 5];
            if (lwo and (longword(1) shl (x and $1f))) <> 0 then
              a := $ff
            else
              a := 0;
          end;
          bmk_gray:
            a := pbyte(maskline)[x];
          bmk_rgb:
            a := (word(pbyte(maskline)[x*4]) +
                  word(pbyte(maskline)[x*4+1]) +
                  word(pbyte(maskline)[x*4+2])) div 3;
          else
            a := $ff;
        end;
        dst[3] := a;
      end;
      Inc(dst, 4);
    end;
  end;
end;

function MSEBitmapToBGR(const Source: tmaskedbitmap;
  out Width, Height: Integer): PByte;
var
  x, y: Integer;
  dst: PByte;
  srcline: prgbtriplety;
begin
  Result := nil;
  Width := 0; Height := 0;
  if (Source = nil) or Source.isempty then Exit;

  Width  := Source.size.cx;
  Height := Source.size.cy;
  if (Width <= 0) or (Height <= 0) then Exit;

  GetMem(Result, NativeUInt(Width) * NativeUInt(Height) * 3);
  dst := Result;
  for y := 0 to Height - 1 do
  begin
    srcline := Source.scanline[y];
    for x := 0 to Width - 1 do
    begin
      dst[0] := srcline[x].blue;
      dst[1] := srcline[x].green;
      dst[2] := srcline[x].red;
      Inc(dst, 3);
    end;
  end;
end;

end.