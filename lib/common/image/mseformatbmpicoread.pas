{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatbmpicoread;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
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
 bmplabel = 'bmp';
 icolabel = 'ico';
procedure registerformat;

//param for ico: [index: integer]

implementation
uses
 classes,mclasses,msebitmap,msebits,msegraphutils,mseguiintf,msegraphicstream,
 msegraphics;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tbitmap1 = class(tbitmap);

const
 RT_BITMAP = PChar(2);

type
 DWORD = longword;
 BITMAPFILEHEADERty = packed record
   bfType: Word;
   bfSize: DWORD;
   bfReserved1: Word;
   bfReserved2: Word;
   bfOffBits: DWORD;
 end;
 BITMAPINFOHEADERty = packed record
   biSize: DWORD;
   biWidth: Longint;
   biHeight: Longint;
   biPlanes: Word;
   biBitCount: Word;
   biCompression: DWORD;
   biSizeImage: DWORD;
   biXPelsPerMeter: Longint;
   biYPelsPerMeter: Longint;
   biClrUsed: DWORD;
   biClrImportant: DWORD;
 end;
 RGBQUADty = packed record
  rgbBlue: Byte;
  rgbGreen: Byte;
  rgbRed: Byte;
  rgbReserved: Byte;
 end;
 ICONHEADERty = packed record
  idReserved: WORD;   // Reserved (must be 0)
  idType: WORD;       // Resource Type (1 for icons)
  idCount: WORD;      // How many images?
  //ICONDIRENTRY   idEntries[1]; // An entry for each image (idCount of 'em)
 end;
 ICONDIRENTRYty = packed record
  bWidth: BYTE;          // Width, in pixels, of the image
  bHeight: BYTE;         // Height, in pixels, of the image
  bColorCount: BYTE;     // Number of colors in image (0 if >=8bpp)
  bReserved: BYTE;       // Reserved ( must be 0)
  wPlanes: WORD;         // Color Planes
  wBitCount: WORD;       // Bits per pixel
  dwBytesInRes: DWORD;    // How many bytes in this resource?
  dwImageOffset: DWORD;   // Where in the file is this image?
 end;
 ICONIMAGEty = packed record
  icHeader: BITMAPINFOHEADERty;      // DIB header
//   RGBQUAD         icColors[1];   // Color table
//   BYTE            icXOR[1];      // DIB bits for XOR mask
//   BYTE            icAND[1];      // DIB bits for AND mask
 end;


const
 BM = $4d42;
 BI_RGB = 0;
 BI_RLE8 = 1;
 BI_RLE4 = 2;
 BI_BITFIELDS = 3;

function readbmp(stream: tformatstream; bfoffbits: integer; dest: tbitmap;
                          icomode: boolean = false): boolean;
                       //bfoffbits <= 0 -> image at colormapend - bfoffbits
                       //true if biheight < 0
var
 infoheader: bitmapinfoheaderty;
 palette: array of longword;
 pixdata: array of byte;
 rowbytelength,paddingcount: integer;
 int1,int2: integer;
 start,stop,step: integer;
 po1: pbyte;
 po2: plongword;
 wo1: word;

begin
 stream.read(infoheader,sizeof(infoheader));
 with infoheader do begin
  if icomode then begin
   biheight:= biheight div 2;
  end;
  result:= biheight < 0;
  if result then begin
   biheight:= -biheight;
   start:= 0;
   stop:= biheight;
   step:= 1;
  end
  else begin
   start:= biheight-1;
   stop:= -1;
   step:= -1;
  end;
  if bicompression <> bi_rgb then begin
   stream.formaterror;
  end;
  if bisize > sizeof(infoheader) then begin
   stream.seek(infoheader.bisize-sizeof(infoheader));
  end;
  if (bibitcount > 32) or (biclrused > bits[bibitcount]) then begin
   stream.formaterror;
  end;
  if (biclrused = 0) and (bibitcount <= 8) then begin
   biclrused:= bits[bibitcount];
  end;
  if bfoffbits <= 0 then begin
   bfoffbits:= stream.pos + integer(biclrused) * sizeof(longword) - bfoffbits;
  end;
  paddingcount:= ((biwidth * bibitcount+7) div 8); //bytecount
  rowbytelength:= ((paddingcount+3) div 4) * 4; //4 byte boundaries
  paddingcount:= rowbytelength - paddingcount;
  setlength(pixdata,rowbytelength*biheight);
  dest.clear;
  if bibitcount = 1 then begin
   dest.kind:= bmk_mono;
  end
  else begin
   dest.kind:= bmk_rgb;
  end;
  dest.size:= makesize(biwidth,biheight);
  int1:= start;
  po1:= @pixdata[0];
  case bibitcount of
   16: begin
    stream.pos:= bfoffbits;
    stream.read(pixdata[0],length(pixdata));
    while int1 <> stop do begin
     po2:= dest.scanline[int1];
     for int2:= 0 to biwidth - 1 do begin
      wo1:= pword(po1)^;
      pbyte(po2)^:= (wo1 and $7c00) shr 7; //red
      inc(pbyte(po2));
      pbyte(po2)^:= (wo1 and $3e0) shr 2;  //green
      inc(pbyte(po2));
      pbyte(po2)^:= (wo1 and $1f) shl 3;   //blue
      inc(pbyte(po2));
      pbyte(po2)^:= 0;
      inc(po1,2);
     end;
     inc(po1,paddingcount);
     inc(int1,step);
    end;
   end;
   32: begin
    stream.Pos:= bfoffbits;
    while int1 <> stop do begin
     stream.read(dest.scanline[int1]^,biwidth*4);
     inc(int1,step);
    end;
   end;
   24: begin
    stream.pos:= bfoffbits;
    stream.read(pixdata[0],length(pixdata));
    while int1 <> stop do begin
     po2:= dest.scanline[int1];
     for int2:= 0 to biwidth - 1 do begin
      po2^:= plongword(po1)^ and $ffffff;
      inc(po1,3);
      inc(po2)
     end;
     inc(po1,paddingcount);
     inc(int1,step);
    end;
   end;
   1: begin
    stream.pos:= bfoffbits;
    stream.read(pixdata[0],length(pixdata));
    while int1 <> stop do begin
     po2:= dest.scanline[int1];
     for int2:= 0 to rowbytelength - 1 do begin
      pbyte(po2)^:= not bitreverse[po1^];
      inc(pbyte(po2));
      inc(po1);
     end;
     inc(int1,step);
    end;
   end;
   4,8: begin
    setlength(palette,bits[bibitcount]);
    stream.read(palette[0],biclrused*sizeof(longword));
//    for int2:= 0 to biclrused - 1 do begin
//     swaprgb1(palette[int2]);
//    end;
    stream.pos:= bfoffbits;
    stream.read(pixdata[0],length(pixdata));
    if bibitcount = 4 then begin
     if odd(biwidth) then begin
      inc(paddingcount);
     end;
     while int1 <> stop do begin
      po2:= dest.scanline[int1];
      for int2:= 0 to biwidth - 1 do begin
       if not odd(int2) then begin
        po2^:= palette[po1^ shr 4];
       end
       else begin
        po2^:= palette[po1^ and $0f];
        inc(po1);
       end;
       inc(po2);
      end;
      inc(po1,paddingcount);
      inc(int1,step);
     end;
    end
    else begin
     while int1 <> stop do begin
      po2:= dest.scanline[int1];
      for int2:= 0 to biwidth - 1 do begin
       po2^:= palette[po1^];
       inc(po2);
       inc(po1);
      end;
      inc(po1,paddingcount);
      inc(int1,step);
     end;
    end;
   end;
   else begin
    stream.formaterror;
   end;
  end;
 end;
end;

function readimagebmp(source: tstream; dest: tbitmap): boolean;
var
 stream: tformatstream;
 fileheader: bitmapfileheaderty;

begin
 result:= false;
 stream:= tformatstream.create(source,'bmp');
 try
  stream.read(fileheader,sizeof(fileheader));
  if (fileheader.bftype <> BM) then begin
   exit;
//   stream.formaterror;
  end;
  dest.clear;
  if dest is tmaskedbitmap then begin
   tmaskedbitmap(dest).masked:= false;
  end;
  dest.kind:= bmk_rgb;
//  dest.monochrome:= false;
  readbmp(stream,fileheader.bfoffbits,dest);
 finally
  stream.free;
 end;
 result:= true;
end;

function readimageico1(source: tstream; dest1: tmaskedbitmap;
                              dest2: timagelist; index: integer): boolean;
var
 stream: tformatstream;
 iconheader: iconheaderty;
 icondir: array of icondirentryty;

 procedure readicobmp(index: integer; dest: tmaskedbitmap);
 var
  bo1: boolean;
  po1: pbyte;
  po2: plongword;
  int1,int3,int4: integer;
 begin
  dest.clear;
//  dest.monochrome:= false;
  dest.kind:= bmk_rgb;
  with icondir[index] do begin
   stream.Pos:= dwimageoffset;
   bo1:= readbmp(stream,0,dest,true);
   int3:= ((bwidth+31) div 32)*4;
   int4:=int3*bheight;
   getmem(po1,int4);
   stream.read(po1^,int4);
   po2:= pointer(po1);
   for int1:= 0 to int4 div 4 - 1 do begin
    po2^:= not po2^;
    inc(po2);
   end;
   tbitmap1(dest.mask).handle:= gui_createbitmapfromdata(makesize(bwidth,bheight),
          po1,true,true,not bo1);
   freemem(po1);
  end;
 end;

var
 size1: sizety;
 mono: boolean;
 int1: integer;
 buffer: tmaskedbitmap;

begin
 result:= false;
 stream:= tformatstream.create(source,'ico');
 try
  stream.Read(iconheader,sizeof(iconheader));
  with iconheader do begin
   if (idtype <> 1) or (idcount <= index) then begin
    exit;
//    stream.formaterror;
   end;
   setlength(icondir,idcount);
   stream.Read(icondir[0],length(icondir)*sizeof(icondirentryty));
   if dest1 <> nil then begin
    readicobmp(index,dest1);
   end
   else begin
    if dest2 <> nil then begin
     size1:= nullsize;
     mono:= true;
     for int1:= 0 to idcount - 1 do begin
      with icondir[int1] do begin
       if bwidth > size1.cx then begin
        size1.cx:= bwidth;
       end;
       if bheight > size1.cy then begin
        size1.cy:= bheight;
       end;
       if bcolorcount <> 1 then begin
        mono:= false;
       end;
      end;
     end;
     with dest2 do begin
      size:= size1;
      if mono then begin
       kind:= bmk_mono;
      end
      else begin
       kind:= bmk_rgb;
      end;
//      monochrome:= mono;
      masked:= true;
      count:= idcount;
     end;
     if mono then begin
      buffer:= tmaskedbitmap.create(bmk_mono);
     end
     else begin
      buffer:= tmaskedbitmap.create(bmk_rgb);
     end;
     try
      for int1:= 0 to idcount - 1 do begin
       readicobmp(int1,buffer);
       dest2.setimage(int1,buffer);
      end;
     finally
      buffer.free;
     end;
    end;
   end;
  end;
 finally
  stream.free;
 end;
 result:= true;
end;

procedure readimageico(source: tstream; dest: tmaskedbitmap; index: integer = 0);
                   overload;
begin
 readimageico1(source,dest,nil,index);
end;

procedure readimageico(source: tstream; dest: timagelist); overload;
begin
 readimageico1(source,nil,dest,0);
end;

procedure readimage(source: tstream; dest: tmaskedbitmap);
var
 posbefore: integer;
begin
 posbefore:= source.Position;
 try
  readimagebmp(source,dest);
  dest.masked:= false;
 except
  on egraphicformat do begin
   source.Position:= posbefore;
   readimageico(source,dest);
  end;
  else raise;
 end;
end;

function readgraphicbmp(const asource: tstream;
                             const dest: tobject; var format: string;
                const params: array of const): boolean;
begin
 result:= false;
 if dest is tbitmap then begin
  result:= readimagebmp(asource,tbitmap(dest));
  if result then begin
   tbitmap(dest).change;
  end;
 end
 else begin
  if dest is timagelist then begin
   result:= readimagebmp(asource,timagelist(dest).bitmap);
   if result then begin
    timagelist(dest).bitmap.change;
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function readgraphicico(const asource: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
var
 int1: integer;
begin
 result:= false;
 if dest is tmaskedbitmap then begin
  with tmaskedbitmap(dest) do begin
   int1:= -1;
   if (high(params) >= 0) then begin
    with tvarrec(params[0]) do begin
     if vtype = vtinteger then begin
      int1:= vinteger;
     end;
    end;
   end;
   if int1 < 0 then begin
    int1:= 0;
   end;
   result:= readimageico1(asource,tmaskedbitmap(dest),nil,int1);
   if result then begin
    change;
   end;
  end;
 end
 else begin
  if dest is timagelist then begin
   result:= readimageico1(asource,nil,timagelist(dest),0);
  end
  else begin
   result:= false;
  end;
 end;
end;

procedure registerformat;
begin
{
 registergraphicformat(bmplabel,{$ifdef FPC}@{$endif}readgraphicbmp,nil,
                        lang_stockcaption[ord(sc_MS_Bitmap)],['*.bmp']);
 registergraphicformat(icolabel,{$ifdef FPC}@{$endif}readgraphicico,nil,
                        lang_stockcaption[ord(sc_MS_Icon)],['*.ico']);
 }

registergraphicformat(bmplabel,{$ifdef FPC}@{$endif}readgraphicbmp,nil,
                        'MS_Bitmap',['*.bmp']);
 registergraphicformat(icolabel,{$ifdef FPC}@{$endif}readgraphicico,nil,
                        'MS_Icon',['*.ico']);
end;

initialization
 registerformat();
end.
