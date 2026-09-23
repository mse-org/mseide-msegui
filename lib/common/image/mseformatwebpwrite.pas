{ MSEgui WebP writer
  Copyright (c) 2026

  See the file COPYING.MSE, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatwebpwrite;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$R-}{$Q-}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

const
 webplabel = 'webp';

procedure registerformat;

implementation
uses
 classes,mclasses,msebitmap,msegraphicstream,msegraphutils,msestream,
 msewebpbitmap,WebPEnc;

procedure writegraphicwebp(const dest: tstream;
                const source: tobject; const format: string;
                const params: array of const);
   // params: [quality: integer] 0..100, default 75 (only used for lossy)
   //         [lossless: boolean] default true
var
 bmp: tmaskedbitmap;
 owned: boolean;
 buf: PByte;
 w, h: Integer;
 encdata: PByte;
 encsize: Integer;
 quality: Integer;
 lossless: Boolean;
 ok: Boolean;
begin
 bmp:= nil;
 owned:= false;

 if source is tmaskedbitmap then
  bmp:= tmaskedbitmap(source)
 else if source is tbitmap then begin
  bmp:= tmaskedbitmap.create(bmk_rgb);
  owned:= true;
  bmp.assign(tbitmap(source));
 end
 else exit;

 quality  := 75;
 lossless := true;
 if (length(params) > 0) and (tvarrec(params[0]).vtype = vtinteger) then
  quality := tvarrec(params[0]).vinteger;
 if (length(params) > 1) and (tvarrec(params[1]).vtype = vtboolean) then
  lossless := tvarrec(params[1]).vboolean;

 if quality < 0 then quality := 0;
 if quality > 100 then quality := 100;

 try
  buf := MSEBitmapToBGRA(bmp, w, h);
  if buf = nil then exit;
  encdata := nil;
  encsize := 0;
  try
   if lossless then
    ok := WebPEncodeLosslessBGRA(buf, w, h, w * 4, encdata, encsize)
   else
    ok := WebPEncodeBGRA(buf, w, h, w * 4, quality, encdata, encsize);
   if ok and (encdata <> nil) and (encsize > 0) then
   try
    dest.writebuffer(encdata^, encsize);
   finally
    FreeMem(encdata);
   end;
  finally
   FreeMem(buf);
  end;
 finally
  if owned then bmp.free;
 end;
end;

procedure registerformat;
begin
 registergraphicformat(webplabel,nil,{$ifdef FPC}@{$endif}writegraphicwebp,
         'WebP_Image',['*.webp']);
end;

initialization
 registerformat();
end.