{ MSEgui WebP reader
  Copyright (c) 2026

  See the file COPYING.MSE, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatwebpread;
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
 classes,mclasses,sysutils,msegraphics,msebitmap,msegraphicstream,
 msegraphutils,msewebpbitmap,WebPDec;

function decodewebptobitmap(const adata: PByte; asize: NativeUInt;
  const adest: tbitmap): boolean;
var
 pixels: PByte;
 w, h: Integer;
 tmp: tmaskedbitmap;
begin
 result:= false;
 if adest is tmaskedbitmap then begin
  pixels:= WebPDecodeBGRA(adata, asize, w, h);
  if pixels = nil then exit;
  try
   LoadBGRAIntoMSEBitmap(pixels, w, h, tmaskedbitmap(adest));
   tmaskedbitmap(adest).change;
   result:= true;
  finally
   FreeMem(pixels);
  end;
 end
 else begin
  pixels:= WebPDecodeBGRA(adata, asize, w, h);
  if pixels = nil then exit;
  tmp:= tmaskedbitmap.create(bmk_rgb);
  try
   try
    LoadBGRAIntoMSEBitmap(pixels, w, h, tmp);
    adest.assign(tmp);
    adest.change;
    result:= true;
   finally
    FreeMem(pixels);
   end;
  finally
   tmp.free;
  end;
 end;
end;

function readgraphicwebp(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
var
 data: array of byte;
 datasize: NativeUInt;
begin
 result:= false;
 if not (dest is tbitmap) then exit;
 datasize:= source.size - source.position;
 if datasize <= 0 then exit;
 setlength(data, datasize);
 source.readbuffer(data[0], datasize);
 result:= decodewebptobitmap(@data[0], datasize, tbitmap(dest));
end;

procedure registerformat;
begin
 registergraphicformat(webplabel,{$ifdef FPC}@{$endif}readgraphicwebp,nil,
         'WebP_Image',['*.webp']);
end;

initialization
 registerformat();
end.