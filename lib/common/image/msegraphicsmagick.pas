{ MSEgui Copyright (c) 2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphicsmagick;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes{msestrings},msectypes,msedynload;
 
const
{$ifdef mswindows}
 graphicsmagiclib: array[0..0] of filenamety = ('CORE_RL_magick_.dll');  
 graphicsmagicwandlib: array[0..0] of filenamety = ('CORE_RL_wand_.dll');  
{$else}
 graphicsmagicwandlib: array[0..1] of filenamety = 
           ('libGraphicsMagickWand.so.2','libGraphicsMagickWand.so'); 
 graphicsmagiclib: array[0..1] of filenamety = 
           ('libGraphicsMagick.so.3','libGraphicsMagick.so'); 
{$endif}

{$packrecords c}

type
 quantumdepthty = (qd_8,qd_16,qd_32);
 
 MagickBool = cuint;
const
 MagickTrue = 1;
 MagickFalse = 0;
type
 MagickPassFail = cuint;
const
 MagickPass = 1;
 MagickFail = 0;

type
 EndianType = (
  UndefinedEndian,
  LSBEndian,            //* "little" endian */
  MSBEndian,            //* "big" endian */
  NativeEndian          //* native endian */
 );
 StorageType = (
  CharPixel,         //* Unsigned 8 bit 'unsigned char' */
  ShortPixel,        //* Unsigned 16 bit 'unsigned short int' */
  IntegerPixel,      //* Unsigned 32 bit 'unsigned int' */
  LongPixel,         //* Unsigned 32 or 64 bit (CPU dependent) 'unsigned long' */
  FloatPixel,        //* Floating point 32-bit 'float' */
  DoublePixel        //* Floating point 64-bit 'double' */
 );

 QuantumType = (
  UndefinedQuantum,  //* Not specified */
  IndexQuantum,      //* Colormap indexes */
  GrayQuantum,       //* Grayscale values (minimum value is black) */
  IndexAlphaQuantum, //* Colormap indexes with transparency */
  GrayAlphaQuantum,  //* Grayscale values with transparency */
  RedQuantum,        //* Red values only (RGBA) */
  CyanQuantum,       //* Cyan values only (CMYKA) */
  GreenQuantum,      //* Green values only (RGBA) */
  YellowQuantum,     //* Yellow values only (CMYKA) */
  BlueQuantum,       //* Blue values only (RGBA) */
  MagentaQuantum,    //* Magenta values only (CMYKA) */
  AlphaQuantum,      //* Transparency values (RGBA or CMYKA) */
  BlackQuantum,      //* Black values only (CMYKA) */
  RGBQuantum,        //* Red, green, and blue values */
  RGBAQuantum,       //* Red, green, blue, and transparency values */
  CMYKQuantum,       //* Cyan, magenta, yellow, and black values */
  CMYKAQuantum,      //* Cyan, magenta, yellow, black, and transparency values */
  CIEYQuantum,       //* CIE Y values, based on CCIR-709 primaries */
  CIEXYZQuantum      //* CIE XYZ values, based on CCIR-709 primaries */
 );

 QuantumSampleType = (
  UndefinedQuantumSampleType, //* Not specified */
  UnsignedQuantumSampleType,  //* Unsigned integral type (1-32 or 64 bits) */
  FloatQuantumSampleType      //* Floating point type (16, 24, 32, or 64 bit) */
 );

 CompressionType = (
  UndefinedCompression,
  NoCompression,
  BZipCompression,
  FaxCompression,
//  Group3Compression = FaxCompression,
  Group4Compression,
  JPEGCompression,
  LosslessJPEGCompression,
  LZWCompression,
  RLECompression,
  ZipCompression,
  LZMACompression,              //* Lempel-Ziv-Markov chain algorithm */
  JPEG2000Compression,          //* ISO/IEC std 15444-1 */
  JBIG1Compression,             //* ISO/IEC std 11544 / ITU-T rec T.82 */
  JBIG2Compression              //* ISO/IEC std 14492 / ITU-T rec T.88 */
 );

 InterlaceType = (
  UndefinedInterlace,
  NoInterlace,
  LineInterlace,
  PlaneInterlace,
  PartitionInterlace
 );

 ResolutionType = (
  UndefinedResolution,
  PixelsPerInchResolution,
  PixelsPerCentimeterResolution
 );

 ColorspaceType = (
  UndefinedColorspace,
  RGBColorspace,         //* Plain old RGB colorspace */
  GRAYColorspace,        //* Plain old full-range grayscale */
  TransparentColorspace, //* RGB but preserve matte channel during quantize */
  OHTAColorspace,
  XYZColorspace,         //* CIE XYZ */
  YCCColorspace,         //* Kodak PhotoCD PhotoYCC */
  YIQColorspace,
  YPbPrColorspace,
  YUVColorspace,
  CMYKColorspace,        //* Cyan, magenta, yellow, black, alpha */
  sRGBColorspace,        //* Kodak PhotoCD sRGB */
  HSLColorspace,         //* Hue, saturation, luminosity */
  HWBColorspace,         //* Hue, whiteness, blackness */
  LABColorspace,         //* LAB colorspace not supported yet other than via lcms */
  CineonLogRGBColorspace,//* RGB data with Cineon Log scaling, 2.048 density range */
  Rec601LumaColorspace,  //* Luma (Y) according to ITU-R 601 */
  Rec601YCbCrColorspace, //* YCbCr according to ITU-R 601 */
  Rec709LumaColorspace,  //* Luma (Y) according to ITU-R 709 */
  Rec709YCbCrColorspace  //* YCbCr according to ITU-R 709 */
 );

 ImageType = (
  UndefinedType,
  BilevelType,
  GrayscaleType,
  GrayscaleMatteType,
  PaletteType,
  PaletteMatteType,
  TrueColorType,
  TrueColorMatteType,
  ColorSeparationType,
  ColorSeparationMatteType,
  OptimizeType
 );

 PreviewType = (
  UndefinedPreview = 0,
  RotatePreview,
  ShearPreview,
  RollPreview,
  HuePreview,
  SaturationPreview,
  BrightnessPreview,
  GammaPreview,
  SpiffPreview,
  DullPreview,
  GrayscalePreview,
  QuantizePreview,
  DespecklePreview,
  ReduceNoisePreview,
  AddNoisePreview,
  SharpenPreview,
  BlurPreview,
  ThresholdPreview,
  EdgeDetectPreview,
  SpreadPreview,
  SolarizePreview,
  ShadePreview,
  RaisePreview,
  SegmentPreview,
  SwirlPreview,
  ImplodePreview,
  WavePreview,
  OilPaintPreview,
  CharcoalDrawingPreview,
  JPEGPreview
 );

 ClassType = (
  UndefinedClass,
  DirectClass,
  PseudoClass
 );

 OrientationType = (       //* Line direction / Frame Direction */
                           //* -------------- / --------------- */
  UndefinedOrientation,    //* Unknown        / Unknown         */
  TopLeftOrientation,      //* Left to right  / Top to bottom   */
  TopRightOrientation,     //* Right to left  / Top to bottom   */
  BottomRightOrientation,  //* Right to left  / Bottom to top   */
  BottomLeftOrientation,   //* Left to right  / Bottom to top   */
  LeftTopOrientation,      //* Top to bottom  / Left to right   */
  RightTopOrientation,     //* Top to bottom  / Right to left   */
  RightBottomOrientation,  //* Bottom to top  / Right to left   */
  LeftBottomOrientation    //* Bottom to top  / Left to right   */
 );

 RenderingIntent = (
  UndefinedIntent,
  SaturationIntent,
  PerceptualIntent,
  AbsoluteIntent,
  RelativeIntent
 );

 FilterTypes = (
  UndefinedFilter,
  PointFilter,
  BoxFilter,
  TriangleFilter,
  HermiteFilter,
  HanningFilter,
  HammingFilter,
  BlackmanFilter,
  GaussianFilter,
  QuadraticFilter,
  CubicFilter,
  CatromFilter,
  MitchellFilter,
  LanczosFilter,
  BesselFilter,
  SincFilter
 );

 GravityType = (
  ForgetGravity,
  NorthWestGravity,
  NorthGravity,
  NorthEastGravity,
  WestGravity,
  CenterGravity,
  EastGravity,
  SouthWestGravity,
  SouthGravity,
  SouthEastGravity,
  StaticGravity
 );

 CompositeOperator = (
  UndefinedCompositeOp = 0,
  OverCompositeOp,
  InCompositeOp,
  OutCompositeOp,
  AtopCompositeOp,
  XorCompositeOp,
  PlusCompositeOp,
  MinusCompositeOp,
  AddCompositeOp,
  SubtractCompositeOp,
  DifferenceCompositeOp,
  MultiplyCompositeOp,
  BumpmapCompositeOp,
  CopyCompositeOp,
  CopyRedCompositeOp,
  CopyGreenCompositeOp,
  CopyBlueCompositeOp,
  CopyOpacityCompositeOp,
  ClearCompositeOp,
  DissolveCompositeOp,
  DisplaceCompositeOp,
  ModulateCompositeOp,
  ThresholdCompositeOp,
  NoCompositeOp,
  DarkenCompositeOp,
  LightenCompositeOp,
  HueCompositeOp,
  SaturateCompositeOp,
  ColorizeCompositeOp,
  LuminizeCompositeOp,
  ScreenCompositeOp,   //* Not yet implemented */
  OverlayCompositeOp,  //* Not yet implemented */
  CopyCyanCompositeOp,
  CopyMagentaCompositeOp,
  CopyYellowCompositeOp,
  CopyBlackCompositeOp,
  DivideCompositeOp
 );

 DisposeType = (
  UndefinedDispose,
  NoneDispose,
  BackgroundDispose,
  PreviousDispose
 );

 TimerState = (
  UndefinedTimerState,
  StoppedTimerState,
  RunningTimerState
 );

 Quantum8 = cuchar;
 Quantum16 = cushort;
 Quantum32 = cuint;
 
 PixelPacket8 = record
 {$ifdef WORDS_BIGENDIAN}
  //* RGBA */
  {$define MAGICK_PIXELS_RGBA}  
  red: Quantum8;
  green: Quantum8;
  blue: Quantum8;
  opacity: Quantum8;
 {$else}
  //* BGRA (as used by Microsoft Windows DIB) */
  {$define MAGICK_PIXELS_BGRA}
  blue: Quantum8;
  green: Quantum8;
  red: Quantum8;
  opacity: Quantum8;
 {$endif}
 end;
 pPixelPacket8 = ^PixelPacket8;

 PixelPacket16 = record
 {$ifdef WORDS_BIGENDIAN}
  //* RGBA */
  {$define MAGICK_PIXELS_RGBA}  
  red: Quantum16;
  green: Quantum16;
  blue: Quantum16;
  opacity: Quantum16;
 {$else}
  //* BGRA (as used by Microsoft Windows DIB) */
  {$define MAGICK_PIXELS_BGRA}
  blue: Quantum16;
  green: Quantum16;
  red: Quantum16;
  opacity: Quantum16;
 {$endif}
 end;
 pPixelPacket16 = ^PixelPacket16;

 PixelPacket32 = record
 {$ifdef WORDS_BIGENDIAN}
  //* RGBA */
  {$define MAGICK_PIXELS_RGBA}  
  red: Quantum32;
  green: Quantum32;
  blue: Quantum32;
  opacity: Quantum32;
 {$else}
  //* BGRA (as used by Microsoft Windows DIB) */
  {$define MAGICK_PIXELS_BGRA}
  blue: Quantum32;
  green: Quantum32;
  red: Quantum32;
  opacity: Quantum32;
 {$endif}
 end;
 pPixelPacket32 = ^PixelPacket32;

 _FILE = record
 end; //todo: link tstream and C-stream
 pFILE = ^_FILE;
 _CacheInfoPtr_ = pointer;
 _BlobInfoPtr_ = pointer;
  
 MaxTextExtent = 0..2052; //???

 const              //ExceptionBaseType
  UndefinedExceptionBase = 0;
  ExceptionBase = 1;
  ResourceBase = 2;
  ResourceLimitBase = 2;
  TypeBase = 5;
  AnnotateBase = 5;
  OptionBase = 10;
  DelegateBase = 15;
  MissingDelegateBase = 20;
  CorruptImageBase = 25;
  FileOpenBase = 30;
  BlobBase = 35;
  StreamBase = 40;
  CacheBase = 45;
  CoderBase = 50;
  ModuleBase = 55;
  DrawBase = 60;
  RenderBase = 60;
  ImageBase = 65;
  WandBase = 67;
  TemporaryFileBase = 70;
  TransformBase = 75;
  XServerBase = 80;
  X11Base = 81;
  UserBase = 82;
  MonitorBase = 85;
  LocaleBase = 86;
  DeprecateBase = 87;
  RegistryBase = 90;
  ConfigureBase = 95;
                        //ExceptionType
  UndefinedException = 0;
  EventException = 100;
  ExceptionEvent = EventException + ExceptionBase;
  ResourceEvent = EventException + ResourceBase;
  ResourceLimitEvent = EventException + ResourceLimitBase;
  TypeEvent = EventException + TypeBase;
  AnnotateEvent = EventException + AnnotateBase;
  OptionEvent = EventException + OptionBase;
  DelegateEvent = EventException + DelegateBase;
  MissingDelegateEvent = EventException + MissingDelegateBase;
  CorruptImageEvent = EventException + CorruptImageBase;
  FileOpenEvent = EventException + FileOpenBase;
  BlobEvent = EventException + BlobBase;
  StreamEvent = EventException + StreamBase;
  CacheEvent = EventException + CacheBase;
  CoderEvent = EventException + CoderBase;
  ModuleEvent = EventException + ModuleBase;
  DrawEvent = EventException + DrawBase;
  RenderEvent = EventException + RenderBase;
  ImageEvent = EventException + ImageBase;
  WandEvent = EventException + WandBase;
  TemporaryFileEvent = EventException + TemporaryFileBase;
  TransformEvent = EventException + TransformBase;
  XServerEvent = EventException + XServerBase;
  X11Event = EventException + X11Base;
  UserEvent = EventException + UserBase;
  MonitorEvent = EventException + MonitorBase;
  LocaleEvent = EventException + LocaleBase;
  DeprecateEvent = EventException + DeprecateBase;
  RegistryEvent = EventException + RegistryBase;
  ConfigureEvent = EventException + ConfigureBase;

  WarningException = 300;
  ExceptionWarning = WarningException + ExceptionBase;
  ResourceWarning = WarningException + ResourceBase;
  ResourceLimitWarning = WarningException + ResourceLimitBase;
  TypeWarning = WarningException + TypeBase;
  AnnotateWarning = WarningException + AnnotateBase;
  OptionWarning = WarningException + OptionBase;
  DelegateWarning = WarningException + DelegateBase;
  MissingDelegateWarning = WarningException + MissingDelegateBase;
  CorruptImageWarning = WarningException + CorruptImageBase;
  FileOpenWarning = WarningException + FileOpenBase;
  BlobWarning = WarningException + BlobBase;
  StreamWarning = WarningException + StreamBase;
  CacheWarning = WarningException + CacheBase;
  CoderWarning = WarningException + CoderBase;
  ModuleWarning = WarningException + ModuleBase;
  DrawWarning = WarningException + DrawBase;
  RenderWarning = WarningException + RenderBase;
  ImageWarning = WarningException + ImageBase;
  WandWarning = WarningException + WandBase;
  TemporaryFileWarning = WarningException + TemporaryFileBase;
  TransformWarning = WarningException + TransformBase;
  XServerWarning = WarningException + XServerBase;
  X11Warning = WarningException + X11Base;
  UserWarning = WarningException + UserBase;
  MonitorWarning = WarningException + MonitorBase;
  LocaleWarning = WarningException + LocaleBase;
  DeprecateWarning = WarningException + DeprecateBase;
  RegistryWarning = WarningException + RegistryBase;
  ConfigureWarning = WarningException + ConfigureBase;

  ErrorException = 400;
  ExceptionError = ErrorException + ExceptionBase;
  ResourceError = ErrorException + ResourceBase;
  ResourceLimitError = ErrorException + ResourceLimitBase;
  TypeError = ErrorException + TypeBase;
  AnnotateError = ErrorException + AnnotateBase;
  OptionError = ErrorException + OptionBase;
  DelegateError = ErrorException + DelegateBase;
  MissingDelegateError = ErrorException + MissingDelegateBase;
  CorruptImageError = ErrorException + CorruptImageBase;
  FileOpenError = ErrorException + FileOpenBase;
  BlobError = ErrorException + BlobBase;
  StreamError = ErrorException + StreamBase;
  CacheError = ErrorException + CacheBase;
  CoderError = ErrorException + CoderBase;
  ModuleError = ErrorException + ModuleBase;
  DrawError = ErrorException + DrawBase;
  RenderError = ErrorException + RenderBase;
  ImageError = ErrorException + ImageBase;
  WandError = ErrorException + WandBase;
  TemporaryFileError = ErrorException + TemporaryFileBase;
  TransformError = ErrorException + TransformBase;
  XServerError = ErrorException + XServerBase;
  X11Error = ErrorException + X11Base;
  UserError = ErrorException + UserBase;
  MonitorError = ErrorException + MonitorBase;
  LocaleError = ErrorException + LocaleBase;
  DeprecateError = ErrorException + DeprecateBase;
  RegistryError = ErrorException + RegistryBase;
  ConfigureError = ErrorException + ConfigureBase;

  FatalErrorException = 700;
  ExceptionFatalError = FatalErrorException + ExceptionBase;
  ResourceFatalError = FatalErrorException + ResourceBase;
  ResourceLimitFatalError = FatalErrorException + ResourceLimitBase;
  TypeFatalError = FatalErrorException + TypeBase;
  AnnotateFatalError = FatalErrorException + AnnotateBase;
  OptionFatalError = FatalErrorException + OptionBase;
  DelegateFatalError = FatalErrorException + DelegateBase;
  MissingDelegateFatalError = FatalErrorException + MissingDelegateBase;
  CorruptImageFatalError = FatalErrorException + CorruptImageBase;
  FileOpenFatalError = FatalErrorException + FileOpenBase;
  BlobFatalError = FatalErrorException + BlobBase;
  StreamFatalError = FatalErrorException + StreamBase;
  CacheFatalError = FatalErrorException + CacheBase;
  CoderFatalError = FatalErrorException + CoderBase;
  ModuleFatalError = FatalErrorException + ModuleBase;
  DrawFatalError = FatalErrorException + DrawBase;
  RenderFatalError = FatalErrorException + RenderBase;
  ImageFatalError = FatalErrorException + ImageBase;
  WandFatalError = FatalErrorException + WandBase;
  TemporaryFileFatalError = FatalErrorException + TemporaryFileBase;
  TransformFatalError = FatalErrorException + TransformBase;
  XServerFatalError = FatalErrorException + XServerBase;
  X11FatalError = FatalErrorException + X11Base;
  UserFatalError = FatalErrorException + UserBase;
  MonitorFatalError = FatalErrorException + MonitorBase;
  LocaleFatalError = FatalErrorException + LocaleBase;
  DeprecateFatalError = FatalErrorException + DeprecateBase;
  RegistryFatalError = FatalErrorException + RegistryBase;
  ConfigureFatalError = FatalErrorException + ConfigureBase;
type
 ExceptionInfo = record
  severity: cint; //* Exception severity, reason, and description */
  reason: pcchar;
  description: pcchar;
  error_number: cint; //* Value of errno (or equivalent) when exception was thrown. */
  module: pcchar; //*Reporting source module, function (if available), and source
                  // module line.  */
  _function: pchar;
  line: culong;
  signature: culong;  //* Structure sanity check
 end;
 pExceptionInfo = ^ExceptionInfo;

 PrimaryInfo = record
  x: cdouble;
  y: cdouble;
  z: cdouble;
 end;

 ChromaticityInfo = record  
  red_primary: PrimaryInfo;
  green_primary: PrimaryInfo;
  blue_primary: PrimaryInfo;
  white_point: PrimaryInfo;
 end;

 RectangleInfo = record
  width: culong;
  height: culong;
  x: clong;
  y: clong;
 end;

 ErrorInfo = record
  mean_error_per_pixel: cdouble; //* Average error per pixel (absolute range) */
  normalized_mean_error: cdouble; //* Average error per pixel (normalized to 1.0) */
  normalized_maximum_error: cdouble; //* Maximum error encountered (normalized to 1.0) */
 end;

 Timer = record
  start: cdouble;
  stop: cdouble;
  total: cdouble;
 end;

 TimerInfo = record
  user: Timer;
  elapsed: Timer;
  state: TimerState;
  signature: culong;
 end;

 _ThreadViewSetPtr_ = pointer;
 _ImageAttributePtr_ = pointer;
 _Ascii85InfoPtr_ = pointer;
 _SemaphoreInfoPtr_ = pointer;
   
 Imagea = record  
  storage_class: ClassType;   //* DirectClass (TrueColor) or PseudoClass (colormapped) */
  colorspace: ColorspaceType; //* Current image colorspace/model */
  compression: CompressionType; //* Compression algorithm to use when encoding image */
  dither: MagickBool; //* True if image is to be dithered */
  matte: MagickBool;  //* True if image has an opacity (alpha) channel */ 
  columns: culong; //* Number of image columns */
  rows: culong;    //* Number of image rows */
  colors: cuint; //* Current number of colors in PseudoClass colormap */
  depth: cuint;  //* Bits of precision to preserve in color quantum */
 end;
 Imageb8 = record
  colormap: pPixelPacket8;          //* Pseudoclass colormap array */
  background_color: PixelPacket8;   //* Background color */
  border_color: PixelPacket8;       //* Border color */
  matte_color: PixelPacket8;        //* Matte (transparent) color */
 end;
 Imageb16 = record
  colormap: pPixelPacket16;          //* Pseudoclass colormap array */
  background_color: PixelPacket16;   //* Background color */
  border_color: PixelPacket16;       //* Border color */
  matte_color: PixelPacket16;        //* Matte (transparent) color */
 end;
 Imageb32 = record
  colormap: pPixelPacket32;          //* Pseudoclass colormap array */
  background_color: PixelPacket32;   //* Background color */
  border_color: PixelPacket32;       //* Border color */
  matte_color: PixelPacket32;        //* Matte (transparent) color */
 end;
 Imagec = record
  gamma: cdouble; //* Image gamma (e.g. 0.45) */
  chromaticity: ChromaticityInfo; //* Red, green, blue, and white chromaticity values */
  orientation: OrientationType; //* Image orientation */
  rendering_intent: RenderingIntent;   //* Rendering intent */
  units: ResolutionType; //* Units of image resolution (density) */
  montage: pcchar; //* Tile size and offset within an image montage */
  directory: pcchar; //* Tile names from within an image montage */
  geometry: pcchar;  //* Composite/Crop options */
  offset: clong; //* Offset to start of image data */
  x_resolution: cdouble; //* Horizontal resolution (also see units) */
  y_resolution: cdouble; //* Vertical resolution (also see units) */
  page: RectangleInfo; //* Offset to apply when placing image */
  tile_info: RectangleInfo; //* Subregion tile dimensions and offset */
  blur: cdouble; //* Amount of blur to apply when zooming image */
  fuzz: cdouble; //* Colors within this distance match target color */
  filter: FilterTypes; //* Filter to use when zooming image */
  interlace: InterlaceType; //* Interlace pattern to use when writing image */
  endian: EndianType; //* Byte order to use when writing image */
  gravity: GravityType; //* Image placement gravity */
  compose: CompositeOperator; //* Image placement composition (default OverCompositeOp) */
  _dispose: DisposeType; //* GIF disposal option */
  scene: culong; //* Animation frame scene number */
  delay: culong; //* Animation frame scene delay */
  iterations: culong; //* Animation iterations */
  total_colors: culong; //* Number of unique colors. See GetNumberColors() */
  start_loop: clong; //* Animation frame number to start looping at */
  error: ErrorInfo; //* Computed image comparison or quantization error */
  timer: TimerInfo; //* Operation micro-timer */
  client_data: pointer; //* User specified opaque data pointer */
//*
//  Output file name.
//  A colon delimited format identifier may be prepended to the file
//  name in order to force a particular output format. Otherwise the
//  file extension is used. If no format prefix or file extension is
//  present, then the output format is determined by the 'magick'
//  field.  */
  filename: array[MaxTextExtent] of char;
//*  Original file name (name of input image file)  */
  magick_filename: array[MaxTextExtent] of cchar;
//*
//  File format of the input file, and the default output format.
//  The precedence when selecting the output format is:
//    1) magick prefix to file name (e.g. "jpeg:foo).
//    2) file name extension. (e.g. "foo.jpg")
//    3) content of this magick field.  */
  magick: array[MaxTextExtent] of cchar;
//* Original image width (before transformations) */
  magick_columns: culong;
//*    Original image height (before transformations) */
  magick_rows: culong;
  exception: ExceptionInfo;          //* Any error associated with this image frame */
  previous: pointer{pImage};          //* Pointer to previous frame */
  next: pointer{pImage};              //* Pointer to next frame */
//*  To be added here for a later release:
//  quality?
//  subsampling
//  video black/white setup levels (ReferenceBlack/ReferenceWhite)
//  sample format (integer/float)  */

//* Only private members appear past this point  */
  profiles: pointer; //* Private, Embedded profiles */
  is_monochrome: cuint; //* Private, True if image is known to be monochrome */
  is_grayscale: cuint; //* Private, True if image is known to be grayscale */
  taint: cuint; //* Private, True if image has not been modifed */
  clip_mask: pointer{pImage}; //* Private, Clipping mask to apply when updating pixels */
  ping: MagickBool; //* Private, if true, pixels are undefined */
  cache: _CacheInfoPtr_; //* Private, image pixel cache */
  default_views: _ThreadViewSetPtr_; //* Private, default cache views */
  attributes: _ImageAttributePtr_; //* Private, Image attribute list */
  ascii85: _Ascii85InfoPtr_;  //* Private, supports huffman encoding */
  blob: _BlobInfoPtr_; //* Private, file I/O object */
  reference_count: clong; //* Private, Image reference count */
  semaphore: _SemaphoreInfoPtr_; //* Private, Per image lock (for reference count) */
  logging: cuint;  //* Private, True if logging is enabled */
  list: pointer{pImage};   //* Private, used only by display */
  signature: culong;  //* Private, Unique code to validate structure */
 end;

 Image8 = record
  a: Imagea;
  b: Imageb8;
  c: Imagec;
 end;
 pImage8 = ^Image8;
 Image16 = record
  a: Imagea;
  b: Imageb16;
  c: Imagec;
 end;
 pImage16 = ^Image16;
 Image32 = record
  a: Imagea;
  b: Imageb32;
  c: Imagec;
 end;
 pImage32 = ^Image32;
 

 ImageInfoa = record
  compression: CompressionType; //* Image compression to use while decoding */
  temporary: MagickBool; //* Remove file "filename" once it has been read. */
  adjoin: MagickBool;    //* If True, join multiple frames into one file */
  antialias: MagickBool; //* If True, antialias while rendering */
  subimage: culong;    //* Starting image scene ID to select */
  subrange: culong;    //* Span of image scene IDs (from starting scene) to select */
  depth: culong;       //* Number of quantum bits to preserve while encoding */
  size: pchar;         //* Desired/known dimensions to use when decoding image */
  tile: pchar;         //* Deprecated, name of image to tile on background */
  page: pchar;         //* Output page size & offset */
  interlace: InterlaceType;  //* Interlace scheme to use when decoding image */
  endian: EndianType;  //* Select MSB/LSB endian output for TIFF format */
  units: ResolutionType; //* Units to apply when evaluating the density option */
  quality: culong;       //* Compression quality factor (format specific) */
  sampling_factor: pchar; //* JPEG, MPEG, and YUV chroma downsample factor */
  server_name: pchar;     //* X11 server display specification */
  font: pchar;            //* Font name to use for text annotations */
  texture: pchar;         //* Name of texture image to use for background fills */
  density: pchar;         //* Image resolution (also see units) */
  pointsize: cdouble;     //* Font pointsize */
  fuzz: cdouble;          //* Colors within this distance are a match */
 end;
 ImageInfob8 = record
  pen: PixelPacket8;      //* Stroke or fill color while drawing */
  background_color: PixelPacket8; //* Background color */
  border_color: PixelPacket8;     //* Border color (color surrounding frame) */
  matte_color: PixelPacket8;      //* Matte color (frame color) */
 end;
 ImageInfob16 = record
  pen: PixelPacket16;      //* Stroke or fill color while drawing */
  background_color: PixelPacket16; //* Background color */
  border_color: PixelPacket16;     //* Border color (color surrounding frame) */
  matte_color: PixelPacket16;      //* Matte color (frame color) */
 end;
 ImageInfob32 = record
  pen: PixelPacket8;      //* Stroke or fill color while drawing */
  background_color: PixelPacket8; //* Background color */
  border_color: PixelPacket8;     //* Border color (color surrounding frame) */
  matte_color: PixelPacket8;      //* Matte color (frame color) */
 end;
 ImageInfoc = record
  dither: MagickBool;            //* If true, dither image while writing */
  monochrome: MagickBool;        //* If true, use monochrome format */
  progress: MagickBool;          //* If true, show progress indication */  
  colorspace: ColorspaceType;    //* Colorspace representations of image pixels */
  _type: ImageType;      //* Desired image type (used while reading or writing) */
  group: clong;          //* X11 window group ID */
  verbose: cuint;                 //* If non-zero, display high-level processing */
  view: pchar;           //* FlashPIX view specification */
  authenticate: pchar;   //* Password used to decrypt file */
  client_data: pointer;  //* User-specified data to pass to coder */
  _file: pFILE;          //* If not null, stdio FILE * to read image from
                         // (fopen mode "rb") or write image to (fopen
                         //       mode "rb+"). */
  magick: array[MaxTextExtent] of cchar;   //* File format to read. Overrides file extension */
  filename: array[MaxTextExtent] of cchar; //* File name to read */

  //  Only private members appear past this point
  
  cache: _CacheInfoPtr_;//* Private. Used to pass image via open cache */
  definitions: pointer; //* Private. Map of coder specific options passed by user.
                        //Use AddDefinitions, RemoveDefinitions, & AccessDefinition
                        //to access and manipulate this data. */
  attributes: pointer{pImage}; //* Private. Image attribute list */
  ping: MagickBool; //* Private, if true, read file header only */
  preview_type: PreviewType; //* Private, used by PreviewImage */
  affirm: MagickBool;  //* Private, when true do not intuit image format */  
  blob: _BlobInfoPtr_;   //* Private, used to pass in open blob */
  length: size_t;   //* Private, used to pass in open blob length */
  unique: array[MaxTextExtent] of cchar;   //* Private, passes temporary filename to TranslateText */
  zero: array[MaxTextExtent] of cchar;     //* Private, passes temporary filename to TranslateText */
  signature: culong;    //* Private, used to validate structure */
 end;
 ImageInfo8 = record
  a: ImageInfoa;
  b: ImageInfob8;
  c:ImageInfoc
 end;
 pImageInfo8 = ^ImageInfo8;
 
 ImageInfo16 = record
  a: ImageInfoa;
  b: ImageInfob16;
  c:ImageInfoc
 end;
 pImageInfo16 = ^ImageInfo16;
 
 ImageInfo32 = record
  a: ImageInfoa;
  b: ImageInfob32;
  c:ImageInfoc
 end;
 pImageInfo32 = ^ImageInfo32;

// pExportPixelAreaOptions = ^ExportPixelAreaOptions;

 ExportPixelAreaOptions = record  
  sample_type: QuantumSampleType; //* Quantum sample type */
  double_minvalue: cdouble;      
     //* Minimum value (default 0.0) for linear floating point samples */
  double_maxvalue: cdouble;      
     //* Maximum value (default 1.0) for linear floating point samples */
  grayscale_miniswhite: MagickBool; 
     //* Grayscale minimum value is white rather than black */
  pad_bytes: culong;            
     //* Number of pad bytes to output after pixel data */
  pad_value: cuchar;            
     //* Value to use when padding end of pixel data */
  endian: EndianType;               
     //* Endian orientation for 16/32/64 bit types (default MSBEndian) */
  signature: culong;
 end;
 pExportPixelAreaOptions = ^ExportPixelAreaOptions;

 ImportPixelAreaOptions = record
  sample_type: QuantumSampleType; //* Quantum sample type */
  double_minvalue: cdouble;      
  //* Minimum value (default 0.0) for linear floating point samples */
  double_maxvalue: cdouble;      
          //* Maximum value (default 1.0) for linear floating point samples */
  grayscale_miniswhite: MagickBool; 
               //* Grayscale minimum value is white rather than black */
  endian: EndianType;    //* Endian orientation for 16/32/64 bit types 
                         //(default MSBEndian) */
  signature: culong;
 end;
 pImportPixelAreaOptions = ^ImportPixelAreaOptions;

 ExportPixelAreaInfo = record
  bytes_exported: size_t;       //* Number of bytes which were exported */
 end;
 pExportPixelAreaInfo = ^ExportPixelAreaInfo;
 
 ImportPixelAreaInfo = record
  bytes_imported: size_t;       //* Number of bytes which were imported */
 end;
 pImportPixelAreaInfo = ^ImportPixelAreaInfo;

 MagickWand = record
 end;
 pMagickWand = ^MagickWand;
 
var
 InitializeMagick: procedure(path: pcchar);
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 DestroyMagick: procedure();
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickMalloc: function(size: size_t): pointer;
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickFree: procedure(memory: pointer);
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 
 MagickGetVersion: function(version: pculong): pcchar;
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickGetQuantumDepth: function(depth: pculong): pchar;
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickQueryFormats: function(pattern: pcchar;
                         number_formats: pculong): ppcchar;
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 GetExceptionInfo: procedure(exception: pExceptionInfo);
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 DestroyExceptionInfo: procedure(exception: pExceptionInfo);
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};

 CloneImageInfo: function(image_info: pointer{pImageInfo}): pointer{pImageInfo};
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 DestroyImageInfo: procedure(image_info: pointer{pImageInfo});
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};

 AllocateImage: function(image_info: pointer{pImageInfo}): pointer{pImage}; 
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 PingImage: function(image_info: pointer{pImageInfo};
                            exception: pExceptionInfo):pointer{pImage};
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ReadImage: function(image_info: pointer{pImageInfo}; 
                           exception: pExceptionInfo): pointer{pImage};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 PingBlob: function(imageinfo: pointer{pImageInfo}; blob: pointer;
                   length: size_t; exception: pExceptionInfo): pointer{pImage};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 BlobToImage: function(image_info: pointer{pImageInfo}; blob: pointer;
                    length: size_t; exception: pExceptionInfo): pointer{pImage};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 WriteImage: function(image_info: pointer{pImageInfo};
                                          image: pointer{pImage}): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ImageToBlob: function(image_info: pointer{pImageInfo};
                             image: pointer{pImage}; length: psize_t;
                            exception: pExceptionInfo): pointer;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 DestroyImage: procedure(image: pointer{pImage});
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};

 DispatchImage: function(image: pointer{pImage8};
                      x_offset: clong; y_offset: clong;
               columns: culong; rows: culong; map: pcchar; _type: StorageType;
                  pixels: pointer; exception: pExceptionInfo): MagickPassFail;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ConstituteImage: function(width: cuint; height: cuint;
                        map: pcchar; _type: StorageType; pixels: pointer;
                        exception: pExceptionInfo): pointer{pImage};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};

 ExportImagePixelArea: function(image: pointer{pImage};
                 quantum_type: QuantumType;
                 quantum_size: cuint; destination: pcuchar;
                 options: pExportPixelAreaOptions;
                 export_info: pExportPixelAreaInfo): MagickPassFail;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ImportImagePixelArea: function(image: pointer{pImage};
                    quantum_type: QuantumType;
                    quantum_size: cuint; source: pcuchar;
                    options: pImportPixelAreaOptions;
                    import_info: pImportPixelAreaInfo): MagickPassFail;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ImportPixelAreaOptionsInit: procedure(options: pImportPixelAreaOptions);
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ExportPixelAreaOptionsInit: procedure(options: pExportPixelAreaOptions); 
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 GetImagePixels: function(image: pointer{pImage}; x: clong; y: clong;
                       columns: culong; rows: culong): pointer{pPixelPacket};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 SetImagePixels: function(image: pointer{pImage}; x: clong; const y: clong;
                       columns: culong; rows: culong): pointer{pPixelPacket};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 SyncImagePixels: function(image: pointer{pImage}): MagickPassFail;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 AllocateImageColormap: function(image: pointer{pImage}; colors: culong): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};

 SampleImage: function(image: pointer{pImage}; columns: culong;
                rows: culong; exception: pExceptionInfo): pointer{pImage}; 
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ScaleImage: function(image: pointer{pImage}; columns: culong;
                   rows: culong; exception: pExceptionInfo): pointer{pImage}; 
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 ResizeImage: function(image: pointer{pImage}; columns: culong; rows: culong;
                    filter: FilterTypes; blur: cdouble;
                    exception: pExceptionInfo): pointer{pImage};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 RotateImage: function(image: pointer{pImage}; degrees: cdouble;
                            exception: pExceptionInfo): pointer{pImage};
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 NewMagickWand: function(): pMagickWand;
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
 DestroyMagickWand: procedure(wand: pMagickWand);
                              {$ifdef wincall}stdcall{$else}cdecl{$endif};
                              
 MagickReadImage: function(wand: pMagickWand; filename: pcchar): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickReadImageBlob: function(wand: pMagickWand; blob: pcuchar;
                                                       length: size_t): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickReadImageFile: function(wand: pMagickWand; _file: pFILE): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};

 MagickWriteImage: function(wand: pMagickWand; filename: pcchar): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickWriteImageFile: function(wand: pMagickWand; _file: pFILE): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickWriteImageBlob: function(wand: pMagickWand; length: psize_t): cuchar;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};
 MagickSetFormat: function(wand: pMagickWand; format: pcchar): cuint;
                             {$ifdef wincall}stdcall{$else}cdecl{$endif};

procedure initializegraphicsmagick(const sonames,
                          sonameswand: array of filenamety);
                                                    //[] = default
procedure releasegraphicsmagick;
function quantumdepth: quantumdepthty;

procedure reggminit(const initproc: dynlibprocty);
procedure reggmdeinit(const deinitproc: dynlibprocty);
procedure reggmwandinit(const initproc: dynlibprocty);
procedure reggmwanddeinit(const deinitproc: dynlibprocty);

implementation
uses
 mseapplication;
 
var
 libinfo: dynlibinfoty;                              
 libinfowand: dynlibinfoty;                              
 qdepth: quantumdepthty;

procedure reggminit(const initproc: dynlibprocty);
begin
 regdynlibinit(libinfo,initproc);
end;

procedure reggmdeinit(const deinitproc: dynlibprocty);
begin
 regdynlibdeinit(libinfo,deinitproc);
end;

procedure reggmwandinit(const initproc: dynlibprocty);
begin
 regdynlibinit(libinfowand,initproc);
end;

procedure reggmwanddeinit(const deinitproc: dynlibprocty);
begin
 regdynlibdeinit(libinfowand,deinitproc);
end;
 
function quantumdepth: quantumdepthty;
begin
 result:= qdepth;
end;
  
procedure init(const data: pointer);
var
 l1: culong;
begin
 initializemagick(pcchar(application.applicationname));
 magickgetquantumdepth(@l1);
 case l1 of
  8: begin
   qdepth:= qd_8;
  end;
  16: begin
   qdepth:= qd_16;
  end
  else begin
   qdepth:= qd_32;
  end;
 end;
end;

procedure deinit(const data: pointer);
begin
 destroymagick();
end;

procedure initializegraphicsmagick(const sonames,
                         sonameswand: array of filenamety);
                                                 //[] = default 
const
 funcs: array[0..29] of funcinfoty = (
//    (n: ''; d: {$ifndef FPC}@{$endif}@),
    (n: 'InitializeMagick'; d: {$ifndef FPC}@{$endif}@InitializeMagick),
    (n: 'DestroyMagick'; d: {$ifndef FPC}@{$endif}@DestroyMagick),
    (n: 'MagickMalloc'; d: {$ifndef FPC}@{$endif}@MagickMalloc),
    (n: 'MagickFree'; d: {$ifndef FPC}@{$endif}@MagickFree),
    (n: 'ExportImagePixelArea'; d: {$ifndef FPC}@{$endif}@ExportImagePixelArea),
    (n: 'PingImage'; d: {$ifndef FPC}@{$endif}@PingImage),
    (n: 'ReadImage'; d: {$ifndef FPC}@{$endif}@ReadImage),
    (n: 'CloneImageInfo'; d: {$ifndef FPC}@{$endif}@CloneImageInfo),
    (n: 'GetExceptionInfo'; d: {$ifndef FPC}@{$endif}@GetExceptionInfo),
    (n: 'DestroyExceptionInfo'; d: {$ifndef FPC}@{$endif}@DestroyExceptionInfo),
    (n: 'DestroyImage'; d: {$ifndef FPC}@{$endif}@DestroyImage),
    (n: 'DispatchImage'; d: {$ifndef FPC}@{$endif}@DispatchImage),
    (n: 'PingBlob'; d: {$ifndef FPC}@{$endif}@PingBlob),
    (n: 'BlobToImage'; d: {$ifndef FPC}@{$endif}@BlobToImage),
    (n: 'ConstituteImage'; d: {$ifndef FPC}@{$endif}@ConstituteImage),
    (n: 'ImportImagePixelArea'; d: {$ifndef FPC}@{$endif}@ImportImagePixelArea),
    (n: 'ImportPixelAreaOptionsInit';
                d: {$ifndef FPC}@{$endif}@ImportPixelAreaOptionsInit),
    (n: 'ExportPixelAreaOptionsInit';
                d: {$ifndef FPC}@{$endif}@ExportPixelAreaOptionsInit),
    (n: 'AllocateImage'; d: {$ifndef FPC}@{$endif}@AllocateImage),
    (n: 'GetImagePixels'; d: {$ifndef FPC}@{$endif}@GetImagePixels),
    (n: 'SetImagePixels'; d: {$ifndef FPC}@{$endif}@SetImagePixels),
    (n: 'DestroyImageInfo'; d: {$ifndef FPC}@{$endif}@DestroyImageInfo),
    (n: 'WriteImage'; d: {$ifndef FPC}@{$endif}@WriteImage),
    (n: 'ImageToBlob'; d: {$ifndef FPC}@{$endif}@ImageToBlob),
    (n: 'SyncImagePixels'; d: {$ifndef FPC}@{$endif}@SyncImagePixels),
    (n: 'AllocateImageColormap';
                            d: {$ifndef FPC}@{$endif}@AllocateImageColormap),
    (n: 'ResizeImage'; d: {$ifndef FPC}@{$endif}@ResizeImage),
    (n: 'SampleImage'; d: {$ifndef FPC}@{$endif}@SampleImage),
    (n: 'ScaleImage'; d: {$ifndef FPC}@{$endif}@ScaleImage),
    (n: 'RotateImage'; d: {$ifndef FPC}@{$endif}@RotateImage)
 );
 errormessage = 'Can not load GraphicsMagick library. ';

 funcswand: array[0..11] of funcinfoty = (
    (n: 'NewMagickWand'; d: {$ifndef FPC}@{$endif}@NewMagickWand),
    (n: 'DestroyMagickWand'; d: {$ifndef FPC}@{$endif}@DestroyMagickWand),
    (n: 'MagickGetVersion'; d: {$ifndef FPC}@{$endif}@MagickGetVersion),
    (n: 'MagickGetQuantumDepth';
                     d: {$ifndef FPC}@{$endif}@MagickGetQuantumDepth),
    (n: 'MagickQueryFormats'; d: {$ifndef FPC}@{$endif}@MagickQueryFormats),
    (n: 'MagickReadImage'; d: {$ifndef FPC}@{$endif}@MagickReadImage),
    (n: 'MagickReadImageBlob'; d: {$ifndef FPC}@{$endif}@MagickReadImageBlob),
    (n: 'MagickReadImageFile'; d: {$ifndef FPC}@{$endif}@MagickReadImageFile),
    (n: 'MagickWriteImage'; d: {$ifndef FPC}@{$endif}@MagickWriteImage),
    (n: 'MagickWriteImageFile'; d: {$ifndef FPC}@{$endif}@MagickWriteImageFile),
    (n: 'MagickWriteImageBlob'; d: {$ifndef FPC}@{$endif}@MagickWriteImageBlob),
    (n: 'MagickSetFormat'; d: {$ifndef FPC}@{$endif}@MagickSetFormat)
 );
 errormessagewand = 'Can not load GraphicsMagickWand library. ';
 
begin
 initializedynlib(libinfo,sonames,graphicsmagiclib,funcs,[],errormessage,nil);
 initializedynlib(libinfowand,sonameswand,graphicsmagicwandlib,funcswand,
                                                     [],errormessagewand,@init);
end;

procedure releasegraphicsmagick;
begin
 releasedynlib(libinfowand,@deinit);
 releasedynlib(libinfo,@deinit);
end;

initialization
 initializelibinfo(libinfo);
 initializelibinfo(libinfowand);
finalization
 finalizelibinfo(libinfo);
 finalizelibinfo(libinfowand);
end.
