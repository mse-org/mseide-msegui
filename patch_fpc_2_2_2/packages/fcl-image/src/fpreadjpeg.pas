{ Copyright (C) 2003 Mattias Gaertner

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

  ToDo:
    - grayscale
    - palette
}
unit FPReadJPEG;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FPImage, JPEGLib, JdAPImin, JDataSrc, JdAPIstd, JmoreCfg;

type
  { TFPReaderJPEG }
  { This is a FPImage reader for jpeg images. }

  TFPReaderJPEG = class;

  PFPJPEGProgressManager = ^TFPJPEGProgressManager;
  TFPJPEGProgressManager = record
    pub : jpeg_progress_mgr;
    instance: TObject;
    last_pass: Integer;
    last_pct: Integer;
    last_time: Integer;
    last_scanline: Integer;
  end;

  TJPEGScale = (jsFullSize, jsHalf, jsQuarter, jsEighth);
  TJPEGReadPerformance = (jpBestQuality, jpBestSpeed);

  TFPReaderJPEG = class(TFPCustomImageReader)
  private
    FSmoothing: boolean;
    FWidth: Integer;
    FHeight: Integer;
    FGrayscale: boolean;
    FProgressiveEncoding: boolean;
    FError: jpeg_error_mgr;
    FProgressMgr: TFPJPEGProgressManager;
    FInfo: jpeg_decompress_struct;
    FScale: TJPEGScale;
    FPerformance: TJPEGReadPerformance;
    procedure SetPerformance(const AValue: TJPEGReadPerformance);
    procedure SetSmoothing(const AValue: boolean);
  protected
    procedure InternalRead(Str: TStream; Img: TFPCustomImage); override;
    function  InternalCheck(Str: TStream): boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property GrayScale: boolean read FGrayscale;
    property ProgressiveEncoding: boolean read FProgressiveEncoding;
    property Smoothing: boolean read FSmoothing write SetSmoothing;
    property Performance: TJPEGReadPerformance read FPerformance write SetPerformance;
  end;

implementation

procedure ReadCompleteStreamToStream(SrcStream, DestStream: TStream;
                                     StartSize: integer);
var
  NewLength: Integer;
  ReadLen: Integer;
  Buffer: string;
begin
  if (SrcStream is TMemoryStream) or (SrcStream is TFileStream)
  or (SrcStream is TStringStream)
  then begin
    // read as one block
    DestStream.CopyFrom(SrcStream,SrcStream.Size-SrcStream.Position);
  end else begin
    // read exponential
    if StartSize<=0 then StartSize:=1024;
    SetLength(Buffer,StartSize);
    NewLength:=0;
    repeat
      ReadLen:=SrcStream.Read(Buffer[NewLength+1],length(Buffer)-NewLength);
      inc(NewLength,ReadLen);
      if NewLength<length(Buffer) then break;
      SetLength(Buffer,length(Buffer)*2);
    until false;
    if NewLength>0 then
      DestStream.Write(Buffer[1],NewLength);
  end;
end;

procedure JPEGError(CurInfo: j_common_ptr);
begin
  if CurInfo=nil then exit;
  writeln('JPEGError ',CurInfo^.err^.msg_code,' ');
  raise Exception.CreateFmt('JPEG error',[CurInfo^.err^.msg_code]);
end;

procedure EmitMessage(CurInfo: j_common_ptr; msg_level: Integer);
begin
  if CurInfo=nil then exit;
  if msg_level=0 then ;
end;

procedure OutputMessage(CurInfo: j_common_ptr);
begin
  if CurInfo=nil then exit;
end;

procedure FormatMessage(CurInfo: j_common_ptr; var buffer: string);
begin
  if CurInfo=nil then exit;
  writeln('FormatMessage ',buffer);
end;

procedure ResetErrorMgr(CurInfo: j_common_ptr);
begin
  if CurInfo=nil then exit;
  CurInfo^.err^.num_warnings := 0;
  CurInfo^.err^.msg_code := 0;
end;


var
  jpeg_std_error: jpeg_error_mgr;

procedure ProgressCallback(CurInfo: j_common_ptr);
begin
  if CurInfo=nil then exit;
  // ToDo
end;

{ TFPReaderJPEG }

procedure TFPReaderJPEG.SetSmoothing(const AValue: boolean);
begin
  if FSmoothing=AValue then exit;
  FSmoothing:=AValue;
end;

procedure TFPReaderJPEG.SetPerformance(const AValue: TJPEGReadPerformance);
begin
  if FPerformance=AValue then exit;
  FPerformance:=AValue;
end;

procedure TFPReaderJPEG.InternalRead(Str: TStream; Img: TFPCustomImage);
var
  MemStream: TMemoryStream;

  procedure SetSource;
  begin
    MemStream.Position:=0;
    jpeg_stdio_src(@FInfo, @MemStream);
  end;

  procedure ReadHeader;
  begin
    jpeg_read_header(@FInfo, TRUE);
    FWidth := FInfo.image_width;
    FHeight := FInfo.image_height;
    FGrayscale := FInfo.jpeg_color_space = JCS_GRAYSCALE;
    FProgressiveEncoding := jpeg_has_multiple_scans(@FInfo);
  end;

  procedure InitReadingPixels;
  begin
    FInfo.scale_num := 1;
    FInfo.scale_denom := 1;// shl Byte(FScale);
    FInfo.do_block_smoothing := FSmoothing;

    if FGrayscale then FInfo.out_color_space := JCS_GRAYSCALE;
    if (FInfo.out_color_space = JCS_GRAYSCALE) then begin
      FInfo.quantize_colors := True;
      FInfo.desired_number_of_colors := 236;
    end;

    if FPerformance = jpBestSpeed then begin
      FInfo.dct_method := JDCT_IFAST;
      FInfo.two_pass_quantize := False;
      FInfo.dither_mode := JDITHER_ORDERED;
      // FInfo.do_fancy_upsampling := False;  can create an AV inside jpeglib
    end;

    if FProgressiveEncoding then begin
      FInfo.enable_2pass_quant := FInfo.two_pass_quantize;
      FInfo.buffered_image := True;
    end;
  end;

  function CorrectCMYK(const C: TFPColor): TFPColor;
  var
    MinColor: word;
  begin
    if C.red<C.green then MinColor:=C.red
    else MinColor:= C.green;
    if C.blue<MinColor then MinColor:= C.blue;
    if MinColor+ C.alpha>$FF then MinColor:=$FF-C.alpha;
    Result.red:=(C.red-MinColor) shl 8;
    Result.green:=(C.green-MinColor) shl 8;
    Result.blue:=(C.blue-MinColor) shl 8;
    Result.alpha:=alphaOpaque;
  end;
  procedure ReadPixels;
  var
    Continue: Boolean;
    SampArray: JSAMPARRAY;
    SampRow: JSAMPROW;
    Color: TFPColor;
    LinesRead: Cardinal;
    x: Integer;
    y: Integer;
    c: word;
  begin
    InitReadingPixels;

    Continue:=true;
    Progress(psStarting, 0, False, Rect(0,0,0,0), '', Continue);
    if not Continue then exit;

    jpeg_start_decompress(@FInfo);

    Img.SetSize(FInfo.output_width,FInfo.output_height);

    // read one line per call
    GetMem(SampArray,SizeOf(JSAMPROW));
    GetMem(SampRow,FInfo.output_width*FInfo.output_components);
    SampArray^[0]:=SampRow;
    try
      Color.Alpha:=alphaOpaque;
      y:=0;
      while (FInfo.output_scanline < FInfo.output_height) do begin
        LinesRead := jpeg_read_scanlines(@FInfo, SampArray, 1);
        if LinesRead<1 then break;
        if (FInfo.jpeg_color_space = JCS_CMYK) then
        for x:=0 to FInfo.output_width-1 do begin
          Color.Red:=SampRow^[x*4+0];
          Color.Green:=SampRow^[x*4+1];
          Color.Blue:=SampRow^[x*4+2];
          Color.alpha:=SampRow^[x*4+3];
          Img.Colors[x,y]:=CorrectCMYK(Color);
        end
        else
        if fgrayscale then begin
         for x:=0 to FInfo.output_width-1 do begin
           c:= SampRow^[x] shl 8;
           Color.Red:=c;
           Color.Green:=c;
           Color.Blue:=c;
           Img.Colors[x,y]:=Color;
         end;
        end
        else begin
         for x:=0 to FInfo.output_width-1 do begin
           Color.Red:=SampRow^[x*3+0] shl 8;
           Color.Green:=SampRow^[x*3+1] shl 8;
           Color.Blue:=SampRow^[x*3+2] shl 8;
           Img.Colors[x,y]:=Color;
         end;
        end;
        inc(y);
      end;
    finally
      FreeMem(SampRow);
      FreeMem(SampArray);
    end;

    if FInfo.buffered_image then jpeg_finish_output(@FInfo);
    jpeg_finish_decompress(@FInfo);

    Progress(psEnding, 100, false, Rect(0,0,0,0), '', Continue);
  end;

begin
  FWidth:=0;
  FHeight:=0;
  MemStream:=nil;
  FillChar(FInfo,SizeOf(FInfo),0);
  try
    if Str is TMemoryStream then
      MemStream:=TMemoryStream(Str)
    else begin
      MemStream:=TMemoryStream.Create;
      ReadCompleteStreamToStream(Str,MemStream,1024);
      MemStream.Position:=0;
    end;
    if MemStream.Size > 0 then begin
      FError:=jpeg_std_error;
      FInfo.err := @FError;
      jpeg_CreateDecompress(@FInfo, JPEG_LIB_VERSION, SizeOf(FInfo));
      try
        FProgressMgr.pub.progress_monitor := @ProgressCallback;
        FProgressMgr.instance := Self;
        FInfo.progress := @FProgressMgr.pub;
        SetSource;
        ReadHeader;
        ReadPixels;
      finally
        jpeg_Destroy_Decompress(@FInfo);
      end;
    end;
  finally
    if (MemStream<>nil) and (MemStream<>Str) then
      MemStream.Free;
  end;
end;

function TFPReaderJPEG.InternalCheck(Str: TStream): boolean;
begin
  // ToDo: read header and check
  Result:=false;
  if Str=nil then exit;
  Result:=true;
end;

constructor TFPReaderJPEG.Create;
begin
  FScale:=jsFullSize;
  FPerformance:=jpBestSpeed;
  inherited Create;
end;

destructor TFPReaderJPEG.Destroy;
begin
  inherited Destroy;
end;

initialization
  with jpeg_std_error do begin
    error_exit:=@JPEGError;
    emit_message:=@EmitMessage;
    output_message:=@OutputMessage;
    format_message:=@FormatMessage;
    reset_error_mgr:=@ResetErrorMgr;
  end;
  ImageHandlers.RegisterImageReader ('JPEG Graphics', 'jpg;jpeg', TFPReaderJPEG);
end.
