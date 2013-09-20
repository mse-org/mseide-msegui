{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegdiplus;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 windows,msestrings,msectypes,sysutils;
 
const
 gdipluslib: array[0..0] of filenamety = ('gdiplus.dll');

type
{$packrecords c}{$packenum 4}

 GpStatus = (
    Ok = 0,
    GenericError = 1,
    InvalidParameter = 2,
    OutOfMemory = 3,
    ObjectBusy = 4,
    InsufficientBuffer = 5,
    NotImplemented = 6,
    Win32Error = 7,
    WrongState = 8,
    Aborted = 9,
    FileNotFound = 10,
    ValueOverflow = 11,
    AccessDenied = 12,
    UnknownImageFormat = 13,
    FontFamilyNotFound = 14,
    FontStyleNotFound = 15,
    NotTrueTypeFont = 16,
    UnsupportedGdiplusVersion = 17,
    GdiplusNotInitialized = 18,
    PropertyNotFound = 19,
    PropertyNotSupported = 20
  );
  
const
 gdipluserrormessages: array[GpStatus] of string = (
    'Ok',
    'GenericError',
    'InvalidParameter',
    'OutOfMemory',
    'ObjectBusy',
    'InsufficientBuffer',
    'NotImplemented',
    'Win32Error',
    'WrongState',
    'Aborted',
    'FileNotFound',
    'ValueOverflow',
    'AccessDenied',
    'UnknownImageFormat',
    'FontFamilyNotFound',
    'FontStyleNotFound',
    'NotTrueTypeFont',
    'UnsupportedGdiplusVersion',
    'GdiplusNotInitialized',
    'PropertyNotFound',
    'PropertyNotSupported'
 );
type
 egdiplus = class(exception)
  public
   constructor create(const aerror: GpStatus);
 end;

  DebugEventLevel = (
   DebugEventLevelFatal,
   DebugEventLevelWarning
  );

 DebugEventProc = procedure(level: DebugEventLevel; 
                                              message: pchar); stdcall;
 GdiplusStartupInput = record
  GdiplusVersion: cUINT32;
  DebugEventCallback: DebugEventProc;
  SuppressBackgroundThread: BOOL;
  SuppressExternalCodecs: BOOL;
 end;
 pGdiplusStartupinput = ^GdiplusStartupinput;
 
 NotificationHookProc = function(token: ppointer): GpStatus; stdcall;
 NotificationUnhookProc = procedure(token: pointer); stdcall;
 
 GdiplusStartupOutput = record
  NotificationHook: NotificationHookProc;
  NotificationUnhook: NotificationUnhookProc;
 end;
 pGdiplusStartupoutput = ^GdiplusStartupoutput;

 GpGraphics = record end;//opaque
 PGpGraphics = ^GpGraphics;
 PPGpGraphics = ^PGpGraphics;

 INT = cint;
 REAL = single;
 GpREAL = REAL;
 pReal = ^REAL;
 ARGB = uint32;
 pARGB = ^ARGB;
 GpPoint = record
  X: INT;
  Y: INT;
 end;
 pGpPoint = ^GpPoint;

 GpImage = record end;
 pGpImage = ^GpImage; 
 GpBitmap = record end;
 pGpBitmap = ^GpBitmap; 
 GpTexture = record end;
 pGpTexture = ^GpTexture;
 GpBrush = record end;
 pGpBrush = ^GpBrush;
 GpSolidFill = record end;
 pGpSolidFill = ^GpSolidFill;
 ppGpSolidFill = ^pGpSolidFill;
 GpPen = record end;
 pGpPen = ^GpPen;
 ppGpPen = ^pGpPen;
 GpPath = record end;
 pGpPath = ^GpPath;
 ppGpPath = ^pGpPath;
 GpRegion = record end;
 pGpRegion = ^GpRegion;
 ppGpRegion = ^pGpRegion;

 QualityMode = (
  QualityModeInvalid   = -1,
  QualityModeDefault   = 0,
  QualityModeLow       = 1, // Best performance
  QualityModeHigh      = 2  // Best rendering quality
 );
 pQualityMode = ^QualityMode;

 SmoothingMode = (
  SmoothingModeInvalid     = ord(QualityModeInvalid),
  SmoothingModeDefault     = ord(QualityModeDefault),
  SmoothingModeHighSpeed   = ord(QualityModeLow),
  SmoothingModeHighQuality = ord(QualityModeHigh),
  SmoothingModeNone,
  SmoothingModeAntiAlias
 );
 pSmoothingMode = ^SmoothingMode;

 GpUnit = (
  UnitWorld,      // 0 -- World coordinate (non-physical unit)
  UnitDisplay,    // 1 -- Variable -- for PageTransform only
  UnitPixel,      // 2 -- Each unit is one device pixel.
  UnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
  UnitInch,       // 4 -- Each unit is 1 inch.
  UnitDocument,   // 5 -- Each unit is 1/300 inch.
  UnitMillimeter  // 6 -- Each unit is 1 millimeter.
 );
 GpMatrixOrder = (
  MatrixOrderPrepend    = 0,
  MatrixOrderAppend     = 1
);

 GpFillMode = (
  FillModeAlternate,        // 0
  FillModeWinding           // 1
 );

 GpPenAlignment = (
  PenAlignmentCenter       = 0,
  PenAlignmentInset        = 1
);
 GpLineCap = (
  LineCapFlat             = 0,
  LineCapSquare           = 1,
  LineCapRound            = 2,
  LineCapTriangle         = 3,

  LineCapNoAnchor         = $10, // corresponds to flat cap
  LineCapSquareAnchor     = $11, // corresponds to square cap
  LineCapRoundAnchor      = $12, // corresponds to round cap
  LineCapDiamondAnchor    = $13, // corresponds to triangle cap
  LineCapArrowAnchor      = $14, // no correspondence

  LineCapCustom           = $ff  // custom cap

//  LineCapAnchorMask       = 0xf0  // mask to check for anchor or not.
 );

 GpDashCap = (
  DashCapFlat             = 0,
  DashCapRound            = 2,
  DashCapTriangle         = 3
 );

 GpDashStyle = (
  DashStyleSolid,          // 0
  DashStyleDash,           // 1
  DashStyleDot,            // 2
  DashStyleDashDot,        // 3
  DashStyleDashDotDot,     // 4
  DashStyleCustom          // 5
);

 GpLineJoin = (
  LineJoinMiter        = 0,
  LineJoinBevel        = 1,
  LineJoinRound        = 2,
  LineJoinMiterClipped = 3
 );

 GpCombineMode = (
  CombineModeReplace,     // 0
  CombineModeIntersect,   // 1
  CombineModeUnion,       // 2
  CombineModeXor,         // 3
  CombineModeExclude,     // 4
  CombineModeComplement   // 5 (Exclude From)
 );

 GpFlushIntention = (
  FlushIntentionFlush = 0,        // Flush all batched rendering operations
  FlushIntentionSync = 1          // Flush all batched rendering operations
                                  // and wait for them to complete
 );
 
 GpPixelOffsetMode = (
  PixelOffsetModeInvalid     = ord(QualityModeInvalid),
  PixelOffsetModeDefault     = ord(QualityModeDefault),
  PixelOffsetModeHighSpeed   = ord(QualityModeLow),
  PixelOffsetModeHighQuality = ord(QualityModeHigh),
  PixelOffsetModeNone,    // No pixel offset
  PixelOffsetModeHalf     // Offset by -0.5, -0.5 for fast anti-alias perf
);
var
 GdiplusStartup: function(token: ppointer; input: pGdiplusStartupInput;
                          output: pGdiplusStartupOutput): GpStatus; stdcall;
 GdiplusShutdown: function(token: pointer): GpStatus; stdcall;

 GdipCreateFromHDC: function(hdc_: HDC;
                 graphics: PPGpGraphics): GpStatus; stdcall;
 GdipCreateFromHDC2: function(hdc_: HDC; hDevice: HANDLE;
                                 graphics: ppGpGraphics): GpStatus; stdcall;
 GdipCreateFromHWND: function(hwnd_: HWND;
                                 graphics: ppGpGraphics): GpStatus; stdcall;
 GdipDeleteGraphics: function(graphics: PGpGraphics): GpStatus; stdcall;
 GdipFlush: function(graphics: pGpGraphics;
          intention: GpFlushIntention): Gpstatus; stdcall;
 GdipTranslateWorldTransform: function(graphics: pGpGraphics;
              dx: REAL; dy: REAL; order: GpMatrixOrder): GpStatus; stdcall;

 GdipSetSmoothingMode: function(graphics: pGpGraphics;
                        smoothingMode_: SmoothingMode): GpStatus; stdcall;
 GdipGetSmoothingMode: function(graphics: pGpGraphics;
                        smoothingMode: pSmoothingMode): GpStatus; stdcall;
 GdipSetPixelOffsetMode: function(graphics: pGpGraphics;
                     pixelOffsetMode: GpPixelOffsetMode): GpStatus; stdcall;
 GdipSetClipRegion: function(graphics: pGpGraphics; region: pGpRegion;
                           combineMode_: GpCombineMode): GpStatus; stdcall;
 GdipResetClip: function(graphics: pGpGraphics): GpStatus; stdcall;

 GdipDeleteBrush: function(brush: pGpBrush): GpStatus; stdcall;
 GdipCreateSolidFill: function(color: ARGB;
                                brush: ppGpSolidFill): GpStatus; stdcall;
 GdipSetSolidFillColor: function(brush: pGpSolidFill;
                                              color: ARGB): GpStatus; stdcall;
 GdipGetSolidFillColor: function(brush: pGpSolidFill;
                                              color: pARGB): GpStatus; stdcall;

 GdipFillRectangleI: function(graphics: pGpGraphics; brush: pGpBrush;
                   x: INT; y: INT; width: INT; height: INT): GpStatus; stdcall;
 GdipFillPolygon2I: function(graphics: pGpGraphics; brush: pGpBrush;
                  points: pGpPoint; count: INT): GpStatus; stdcall;

 GdipCreatePen1: function(color: ARGB; width: REAL; unit_: GpUnit;
                                    pen: ppGpPen): GpStatus; stdcall;
 GdipDeletePen: function(pen: pGpPen): GpStatus; stdcall;
 GdipSetPenMode: function(pen: pGpPen; 
                           penMode: GpPenAlignment): GpStatus; stdcall;
 GdipSetPenWidth: function(pen: pGpPen; width: REAL): GpStatus; stdcall;
 GdipGetPenWidth: function(pen: pGpPen; width: pREAL): GpStatus; stdcall;
 GdipSetPenColor: function(pen: pGpPen; argb_: ARGB): GpStatus; stdcall;
 GdipGetPenColor: function(pen: pGpPen; argb_: pARGB): GpStatus; stdcall;
 GdipSetPenLineCap197819: function(pen: pGpPen; startCap: GpLineCap;
                   endCap: GpLineCap; dashCap: GpDashCap): GpStatus; stdcall;
 GdipSetPenLineJoin: function(pen: pGpPen;
                                    lineJoin: GpLineJoin): GpStatus; stdcall;
 GdipSetPenDashArray: function(pen: pGpPen; dash: pREAL;
                                         count: INT): GpStatus; stdcall;
 GdipSetPenDashOffset: function(pen: pGpPen; offset: REAL): GpStatus; stdcall;
 GdipSetPenDashStyle: function(pen: pGpPen; 
                                  dashstyle: GpDashStyle): GpStatus;  stdcall;

 GdipDrawLinesI: function(graphics: pGpGraphics; pen: pGpPen;
                            points: pGpPoint; count: INT): GpStatus; stdcall;
 GdipDrawPolygonI: function(graphics: pGpGraphics; pen: pGpPen;
                            points: pGpPoint; count: INT): GpStatus; stdcall;
 GdipDrawEllipseI: function(graphics: pGpGraphics; pen: pGpPen; x: INT; y: INT;
                          width: INT;  height: INT): GpStatus; stdcall;
 GdipFillEllipseI: function(graphics: pGpGraphics; brush: pGpBrush;
                 x: INT; y: INT; width: INT; height: INT): GpStatus; stdcall;
 GdipDrawArcI: function(graphics: pGpGraphics; pen: pGpPen; x: INT; y: INT;
                       width: INT; heigh: INT;
                       startAngle: REAL; sweepAngle: REAL): GpStatus; stdcall;
 GdipFillPieI: function(graphics: pGpGraphics; brush: pGpBrush; x: INT; y: INT;
                              width: INT; height: INT; startAngle: REAL;
                                   sweepAngle: REAL): GpStatus; stdcall;
 GdipCreatePath: function(brushMode: GpFillMode; 
                                     path: ppGpPath): GpStatus; stdcall;
 GdipDeletePath: function(path: pGpPath): GpStatus; stdcall;
 GdipStartPathFigure: function(path: pGpPath): GpStatus; stdcall;
 GdipClosePathFigure: function(path: pGpPath): GpStatus; stdcall;
 GdipAddPathArc: function(path: pGpPath; x: REAL; y: REAL;
                        width: REAL; height: REAL;
                        startangle: REAL; sweepangle: REAL): GpStatus; stdcall;
 GdipFillPath: function(graphics: pGpGraphics; brush: pGpBrush;
                                            path: pGpPath): GpStatus; stdcall;
 GdipCreateRegionHrgn: function(hRgn_: HRGN;
                                        region: ppGpRegion): GpStatus; stdcall;
 GdipDeleteRegion: function(region: pGpRegion): GpStatus; stdcall;
 GdipResetWorldTransform: function(graphics: pGpGraphics): GpStatus; stdcall;

 GdipDisposeImage: function(image: pGpImage): GpStatus; stdcall;

function initializegdiplus(const sonames: array of filenamety;
                     const noexception: boolean = false): boolean;
           //false if not available
procedure releasegdiplus;
function gdipcheckerror(const aerror: gpstatus): boolean; //true if ok
 
implementation
uses
 msesys,msedynload;
var
 libinfo: dynlibinfoty;
 instance: pointer;

function gdipcheckerror(const aerror: gpstatus): boolean; //true if ok
begin
 result:= aerror = ok;
 if not result then begin
  raise egdiplus.create(aerror);
 end;
end;

procedure initgdiplus;
var
 startupin: gdiplusstartupinput;
// startupout: gdiplusstartupoutput;
begin
 fillchar(startupin,sizeof(startupin),0);
 startupin.gdiplusversion:= 1;
 instance:= nil;
 gdipcheckerror(gdiplusstartup(@instance,@startupin,nil{@startupout}));
end;

procedure deinitgdiplus;
begin
 if instance <> nil then begin
  gdiplusshutdown(instance);
  instance:= nil;
 end;
end;

function initializegdiplus(const sonames: array of filenamety;
                                const noexception: boolean = false): boolean;
const
 funcs: array[0..46] of funcinfoty = (
  (n: 'GdiplusStartup'; d: @GdiplusStartup),              //0
  (n: 'GdiplusShutdown'; d: @GdiplusShutdown),            //1
  (n: 'GdipCreateFromHDC'; d: @GdipCreateFromHDC),        //2
  (n: 'GdipDeleteGraphics'; d: @GdipDeleteGraphics),      //3
  (n: 'GdipDeleteBrush'; d: @GdipDeleteBrush),            //4
  (n: 'GdipCreateSolidFill'; d: @GdipCreateSolidFill),    //5
  (n: 'GdipSetSolidFillColor'; d: @GdipSetSolidFillColor),//6
  (n: 'GdipGetSolidFillColor'; d: @GdipGetSolidFillColor),//7
  (n: 'GdipFillRectangleI'; d: @GdipFillRectangleI),      //8
  (n: 'GdipFillPolygon2I'; d: @GdipFillPolygon2I),        //9
  (n: 'GdipSetSmoothingMode'; d: @GdipSetSmoothingMode),  //10
  (n: 'GdipGetSmoothingMode'; d: @GdipGetSmoothingMode),  //11
  (n: 'GdipDrawLinesI'; d: @GdipDrawLinesI),              //12
  (n: 'GdipDrawPolygonI'; d: @GdipDrawPolygonI),          //13
  (n: 'GdipCreatePen1'; d: @GdipCreatePen1),              //14
  (n: 'GdipDeletePen'; d: @GdipDeletePen),                //15
  (n: 'GdipSetPenWidth'; d: @GdipSetPenWidth),            //16
  (n: 'GdipGetPenWidth'; d: @GdipGetPenWidth),            //17
  (n: 'GdipSetPenColor'; d: @GdipSetPenColor),            //18
  (n: 'GdipGetPenColor'; d: @GdipGetPenColor),            //19
  (n: 'GdipDrawEllipseI'; d: @GdipDrawEllipseI),          //20
  (n: 'GdipFillEllipseI'; d: @GdipFillEllipseI),          //21
  (n: 'GdipDrawArcI'; d: @GdipDrawArcI),                  //22
  (n: 'GdipFillPieI'; d: @GdipFillPieI),                  //23
  (n: 'GdipCreatePath'; d: @GdipCreatePath),              //24
  (n: 'GdipDeletePath'; d: @GdipDeletePath),              //25
  (n: 'GdipAddPathArc'; d: @GdipAddPathArc),              //26
  (n: 'GdipStartPathFigure'; d: @GdipStartPathFigure),    //27
  (n: 'GdipClosePathFigure'; d: @GdipClosePathFigure),    //28
  (n: 'GdipAddPathArc'; d: @GdipAddPathArc),              //29
  (n: 'GdipFillPath'; d: @GdipFillPath),                  //30
  (n: 'GdipSetPenLineCap197819'; d: @GdipSetPenLineCap197819), //31
  (n: 'GdipSetPenLineJoin'; d: @GdipSetPenLineJoin),      //32
  (n: 'GdipSetPenDashArray'; d: @GdipSetPenDashArray),    //33
  (n: 'GdipSetPenDashOffset'; d: @GdipSetPenDashOffset),  //34
  (n: 'GdipSetPenDashStyle'; d: @GdipSetPenDashStyle),    //35
  (n: 'GdipCreateRegionHrgn'; d: @GdipCreateRegionHrgn),  //36
  (n: 'GdipSetClipRegion'; d: @GdipSetClipRegion),        //37
  (n: 'GdipDeleteRegion'; d: @GdipDeleteRegion),          //38
  (n: 'GdipFlush'; d: @GdipFlush),                        //39
  (n: 'GdipResetClip'; d: @GdipResetClip),                //40
  (n: 'GdipCreateFromHDC2'; d: @GdipCreateFromHDC2),      //41
  (n: 'GdipCreateFromHWND'; d: @GdipCreateFromHWND),      //42
  (n: 'GdipSetPixelOffsetMode'; d: @GdipSetPixelOffsetMode),//43
  (n: 'GdipSetPenMode'; d: @GdipSetPenMode),                //44
  (n: 'GdipTranslateWorldTransform'; d: @GdipTranslateWorldTransform),//45
  (n: 'GdipResetWorldTransform'; d: @GdipResetWorldTransform)//46
 );
const
 errormessage = 'Can not load gdi+ library. ';
begin
 result:= initializedynlib(libinfo,sonames,gdipluslib,funcs,[],errormessage,
                                                @initgdiplus,noexception);
end;

procedure releasegdiplus;
begin
 releasedynlib(libinfo,@deinitgdiplus);
end;

{ egdiplus }

constructor egdiplus.create(const aerror: GpStatus);
var
 str1: string;
begin
 str1:= 'gdi+ error '+inttostr(ord(aerror));
 if aerror <= high(gdipluserrormessages) then begin
  str1:= str1+': '+gdipluserrormessages[aerror];
 end;
 inherited create(str1);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
