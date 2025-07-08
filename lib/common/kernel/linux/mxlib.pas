unit mxlib;

 {$mode objfpc}{$h+}

interface

uses
  SysUtils,
  ctypes;

{$linklib X11}
{$linklib Xext}

{$ifndef os2}
  {$LinkLib c}

{$PACKRECORDS C}

 {$ifdef darwin}
  {$LinkLib libX11.dylib}
   const
   libX11='libX11.dylib';
   libxext = 'libXext.dylib';
   {$ifdef use_xcb}
   libxcb        = 'libxcb.dylib';
   libX11_xcb    = 'libX11-xcb.dylib';
   {$endif}
   
 {$else}
  {$ifdef openbsd}
   {$LinkLib libX11.so}
   const
   libX11='libX11.so';
   libxext = 'libXext.so';
    {$ifdef use_xcb}
   libxcb        = 'libxcb.so';
   libX11_xcb    = 'libX11-xcb.so';
   {$endif}
   
   {$else}
    {$LinkLib libX11.so.6}
const
  libX11  = 'libX11.so.6';
  libxext = 'libXext.so.6';
   {$ifdef use_xcb}
   libxcb        = 'libxcb.so.1';
   libX11_xcb    = 'libX11-xcb.so.1';
   {$endif}
   {$endif}
   {$endif}
 {$else}
const
  libX11='X11';
  libxext = 'Xext';
  {$ifdef use_xcb}
  libxcb        = 'xcb';
  libX11_xcb    = 'X11-xcb';
  {$endif}
  {$endif}


const
  CapButt       = 1;
  CapRound      = 2;
  CurrentTime   = 0;
  CapProjecting = 3;
  JoinMiter     = 0;
  JoinRound     = 1;
  JoinBevel     = 2;
  GCGraphicsExposures = 1 shl 16;
  GCFillStyle   = 1 shl 8;
  GCFunction    = 1 shl 0;
  GCLineWidth   = 1 shl 4;
  GCLineStyle   = 1 shl 5;
  GCCapStyle    = 1 shl 6;
  GCJoinStyle   = 1 shl 7;
  GCTileStipXOrigin = 1 shl 12;
  GCTileStipYOrigin = 1 shl 13;
  GCTile        = 1 shl 10;
  GCStipple     = 1 shl 11;
  GCClipXOrigin = 1 shl 17;
  GCClipYOrigin = 1 shl 18;
  GCClipMask    = 1 shl 19;
  GCPlaneMask   = 1 shl 1;
  GCSubwindowMode = 1 shl 15;
  GCArcMode     = 1 shl 22;
  Unsorted      = 0;
  YSorted       = 1;
  YXSorted      = 2;
  YXBanded      = 3;
  FillSolid     = 0;
  FillTiled     = 1;
  FillStippled  = 2;
  FillOpaqueStippled = 3;
  LineSolid     = 0;
  LineOnOffDash = 1;
  LineDoubleDash = 2;
  GXand         = $1;
  GXorReverse   = $b;
  GXxor         = $6;
  GXcopyInverted = $c;
  GXorInverted  = $d;
  CoordModeOrigin = 0;
  CoordModePrevious = 1;
  ArcPieSlice   = 1;
  ArcChord      = 0;
  Complex       = 0;
  Nonconvex     = 1;
  Convex        = 2;
  ButtonPressMask = 1 shl 2;
  ButtonReleaseMask = 1 shl 3;
  PointerMotionMask = 1 shl 6;
  Success       = 0;
  AnyPropertyType = 0;
  SelectionNotify = 31;
  SubstructureNotifyMask = 1 shl 19;
  SubstructureRedirectMask = 1 shl 20;
  NoEventMask   = 0;
  Above         = 0;
  Below         = 1;
  CWSibling     = 1 shl 5;
  CWStackMode   = 1 shl 6;
  CWWinGravity  = 1 shl 5;
  CWBitGravity  = 1 shl 4;
  NorthWestGravity = 1;
  CWOverrideRedirect = 1 shl 9;
  GrabModeSync  = 0;
  GrabModeAsync = 1;
  GrabSuccess   = 0;
  XYBitmap      = 0;
  XYPixmap      = 1;
  ZPixmap       = 2;
  LSBFirst      = 0;
  MSBFirst      = 1;
  RevertToParent = 2;
  Button1Mask   = 1 shl 8;
  Button2Mask   = 1 shl 9;
  Button3Mask   = 1 shl 10;
  Button4Mask   = 1 shl 11;
  Button5Mask   = 1 shl 12;
  ShiftMask     = 1 shl 0;
  LockMask      = 1 shl 1;
  ControlMask   = 1 shl 2;
  Mod1Mask      = 1 shl 3;
  Mod2Mask      = 1 shl 4;
  Mod3Mask      = 1 shl 5;
  Mod4Mask      = 1 shl 6;
  Mod5Mask      = 1 shl 7;
  KeymapStateMask = 1 shl 14;
  KeyReleaseMask = 1 shl 1;
  XIMPreserveState = 1 shl 1;
  EnterWindowMask = 1 shl 4;
  LeaveWindowMask = 1 shl 5;
  FocusChangeMask = 1 shl 21;
  PropertyChangeMask = 1 shl 22;
  StructureNotifyMask = 1 shl 17;
  USPosition    = 1 shl 0;
  USSize        = 1 shl 1;
  PPosition     = 1 shl 2;
  PSize         = 1 shl 3;
  StaticGravity = 10;
  PWinGravity   = 1 shl 9;
  CWX           = 1 shl 0;
  CWY           = 1 shl 1;
  CWWidth       = 1 shl 2;
  CWHeight      = 1 shl 3;
  PMinSize      = 1 shl 4;
  PMaxSize      = 1 shl 5;
  UnmapNotify   = 18;
  DestroyNotify = 17;
  KeyRelease    = 3;
  SelectionClear = 29;
  SelectionRequest = 30;
  PropertyNotify = 28;
  MotionNotify  = 6;
  EnterNotify   = 7;
  LeaveNotify   = 8;
  NotifyNormal  = 0;
  XBufferOverflow = -(1);
  XLookupNone   = 1;
  XLookupChars  = 2;
  XLookupKeySymVal = 3;
  ButtonPress   = 4;
  ButtonRelease = 5;
  MappingNotify = 34;
  MapNotify     = 19;
  ReparentNotify = 21;
  FocusIn       = 9;
  FocusOut      = 10;
  NotifyPointer = 5;
  GraphicsExpose = 13;
  ConfigureNotify = 22;
  AllocAll      = 1;
  DoRed         = 1 shl 0;
  DoGreen       = 1 shl 1;
  DoBlue        = 1 shl 2;
  XIMStatusNothing = $0400;
  XIMPreeditNothing = $0008;
  PseudoColor   = 3;
  TrueColor     = 4;
  DirectColor   = 5;
  NoSymbol      = 0;
  AllocNone     = 0;
  PictOpOver    = 3;
  PictStandardA1 = 4;
  PictStandardA8 = 2;
  PictStandardARGB32 = 0;
  PictStandardRGB24 = 1;
  RepeatNormal  = 1;
  CPRepeat      = 1 shl 0;
  CPAlphaMap    = 1 shl 1;
  CPComponentAlpha = 1 shl 12;
  PictOpSrc     = 1;
  PolyEdgeSmooth = 1;
  PolyModePrecise = 0;
  PolyModeImprecise = 1;
  CPPolyEdge    = 1 shl 9;
  CPPolyMode    = 1 shl 10;
  CPClipXOrigin = 1 shl 4;
  CPClipYOrigin = 1 shl 5;
  CPClipMask    = 1 shl 6;
  CPGraphicsExposure = 1 shl 7;

  XNFocusWindow = 'focusWindow';
  XNFilterEvents = 'filterEvents';
  XNResetState  = 'resetState';
  XNInputStyle  = 'inputStyle';
  XNClientWindow = 'clientWindow';
  XNDestroyCallback = 'destroyCallback';

        // xcb
  {$ifdef use_xcb}
  CWBackPixmap = $00000001;
  CWBorderPixmap = $00000004;
  CWBorderPixel = $00000008;
  CWBackingStore = $00000040;
  CWBackingPlanes = $00000080;
  CWBackingPixel = $00000100;
  CWSaveUnder = $00000400;
  CWDontPropagate = $00001000;
  CWCursor = $00004000;
  
  XCB_CW_BACK_PIXMAP = $00000001;
  XCB_CW_BACK_PIXEL = $00000002;
  XCB_CW_BORDER_PIXMAP = $00000004;
  XCB_CW_BORDER_PIXEL = $00000008;
  XCB_CW_BIT_GRAVITY = $00000010;
  XCB_CW_WIN_GRAVITY = $00000020;
  XCB_CW_BACKING_STORE = $00000040;
  XCB_CW_BACKING_PLANES = $00000080;
  XCB_CW_BACKING_PIXEL = $00000100;
  XCB_CW_OVERRIDE_REDIRECT = $00000200;
  XCB_CW_SAVE_UNDER = $00000400;
  XCB_CW_EVENT_MASK = $00000800;
  XCB_CW_DONT_PROPAGATE = $00001000;
  XCB_CW_COLORMAP = $00002000;
  XCB_CW_CURSOR = $00004000;
  XCB_EVENT_MASK_EXPOSURE = (1 shl 15);
  XCB_EVENT_MASK_KEY_PRESS = 1 shl 0;   // $00000001
  XCB_EVENT_MASK_KEY_RELEASE = 1 shl 1; // $00000002
  XCB_EVENT_MASK_BUTTON_PRESS = 1 shl 2; // equals 4
  
  
type // xcb

  xcb_atom_t = cardinal;

  Pxcb_intern_atom_reply_t = ^xcb_intern_atom_reply_t;
  xcb_intern_atom_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    atom: xcb_atom_t;
  end;
  
   xcb_intern_atom_cookie_t = record
    sequence: cuint;
  end;
  pxcb_intern_atom_cookie_t = ^xcb_intern_atom_cookie_t;

  Cursor = CULong;
  
  xcb_connection_t = record end;
  PXCBConnection = ^xcb_connection_t;
  
  xcb_map_window_cookie_t = record
    sequence: cunsigned;
  end;
  
  Pxcb_connection_t = Pointer;
   xcb_window_t = cuint32;
  xcb_colormap_t = cuint32;
  xcb_visualid_t = cuint32;
  
   xcb_generic_error_t = record
    response_type: cuint8;
    error_code: cuint8;
    sequence: cuint16;
    resource_id: cuint32;
    minor_code: cuint16;
    major_code: cuint8;
    pad0: cuint8;
    pad: array[0..4] of cuint32;
    full_sequence: cuint32;
  end;
  Pxcb_generic_error_t = ^xcb_generic_error_t;
  PPxcb_generic_error_t = ^pxcb_generic_error_t;
  xcb_screen_t = record
    root: xcb_window_t;
    default_colormap: xcb_colormap_t;
    white_pixel: cuint32;
    black_pixel: cuint32;
    current_input_masks: cuint32;
    width_in_pixels: cuint16;
    height_in_pixels: cuint16;
    width_in_millimeters: cuint16;
    height_in_millimeters: cuint16;
    min_installed_maps: cuint16;
    max_installed_maps: cuint16;
    root_visual: xcb_visualid_t;
    backing_stores: cuint8;
    save_unders: cuint8;
    root_depth: cuint8;
    allowed_depths_len: cuint8;
  end;
  Pxcb_screen_t = ^xcb_screen_t;

   xcb_screen_iterator_t = record
    data: Pxcb_screen_t;
    rem: cint;
    index: cint;
  end;
  Pxcb_screen_iterator_t = ^xcb_screen_iterator_t;
 
  xcb_setup_t = record
    status: cuint8;
    pad0: cuint8;
    protocol_major_version: cuint16;
    protocol_minor_version: cuint16;
    length: cuint16;
    release_number: cuint32;
    resource_id_base: cuint32;
    resource_id_mask: cuint32;
    motion_buffer_size: cuint32;
    vendor_len: cuint16;
    maximum_request_length: cuint16;
    roots_len: cuint8;
    pixmap_formats_len: cuint8;
    image_byte_order: cuint8;
    bitmap_format_bit_order: cuint8;
    bitmap_format_scanline_unit: cuint8;
    bitmap_format_scanline_pad: cuint8;
    min_keycode: cuint8;
    max_keycode: cuint8;
    pad1: array[0..3] of cuint8;
  end;
  Pxcb_setup_t = ^xcb_setup_t;
  
    xcb_get_geometry_cookie_t = record
    sequence: cunsigned;
  end;
  Pxcb_get_geometry_reply_t = ^xcb_get_geometry_reply_t;
  xcb_get_geometry_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    depth: cuint8;
    sequence: cuint16;
    length: cuint32;
    root: xcb_window_t;
    x: cint16;
    y: cint16;
    width: cuint16;
    height: cuint16;
    border_width: cuint16;
    pad0: array[0..1] of cuint8;
  end;
  xcb_get_window_attributes_cookie_t = record
    sequence: cunsigned;
  end;
  Pxcb_get_window_attributes_reply_t = ^xcb_get_window_attributes_reply_t;
  xcb_get_window_attributes_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    backing_store: cuint8;
    sequence: cuint16;
    length: cuint32;
    visual: xcb_visualid_t;
    _class: cuint16;
    bit_gravity: cuint8;
    win_gravity: cuint8;
    backing_planes: cuint32;
    backing_pixel: cuint32;
    save_under: cuint8;
    map_is_installed: cuint8;
    map_state: cuint8;
    override_redirect: cuint8;
    colormap: xcb_colormap_t;
    all_event_masks: cuint32;
    your_event_mask: cuint32;
    do_not_propagate_mask: cuint16;
    pad0: array[0..1] of cuint8;
  end;
 
 xcb_void_cookie_t = record
    sequence: cuint;
  end;
  Pxcb_void_cookie_t = ^xcb_void_cookie_t;
  
  xcb_get_property_cookie_t = record
    sequence: cunsigned;
  end;
  
    xcb_get_property_reply_t = packed record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    format: cuint8;
    sequence: cuint16;
    length: cuint32;
    type_: xcb_atom_t;
    bytes_after: cuint32;
    value_len: cuint32;
    pad0: array[0..11] of cuint8;
  end;
  Pxcb_get_property_reply_t = ^xcb_get_property_reply_t;

{$endif}// end xcb type

type
  PBool       = ^TBool;
   { We cannot use TBool = LongBool, because Longbool(True)=-1, 
     and that is not handled well by X. So we leave TBool=cint; 
     and make overloaded calls with a boolean parameter. 
     For function results, longbool is OK, since everything <>0 
     is interpreted as true, so we introduce TBoolResult. }
  TBool       = cint;
  TBoolResult = longbool;

  TTime = culong;
  PTime = ^TTime;

  TStatus = cint;     // For XShapeCombineRegion
  PStatus = ^TStatus; // For mseguiintf.pas

  TRegion = Pointer;  // For X11 Region

  XRectangle = record
    x, y: cshort;
    Width, Height: cushort;
  end;
  PXRectangle = ^XRectangle;

  PXICCEncodingStyle = ^TXICCEncodingStyle;
  TXICCEncodingStyle = (XStringStyle, XCompoundTextStyle, XTextStyle,
    XStdICCTextStyle, XUTF8StringStyle);

  XExtData = record
    number: cint;
    Next: Pointer;
    free_private: procedure(Data: Pointer); cdecl;
    private_data: PChar;
  end;
  PXExtData = ^XExtData;

  VisualID = culong;

  Visual = record
    ext_data: PXExtData;  { hook for extension to hang data  }
    visualid: VisualID;   { visual id of this visual  }
    _class: cint;
    red_mask: culong;
    green_mask: culong;
    blue_mask: culong;
    bits_per_rgb: cint;
    map_entries: cint;
  end;
  msepvisual = ^visual;
  pvisual    = ^visual;

  Display  = Pointer;
  PDisplay = ^Display;
  Window   = culong;
  Drawable = culong;
  GC       = Pointer;
  TGC      = GC;
  Atom     = culong;
  PAtom    = ^Atom;
  Colormap = culong;
  Pixmap   = culong;
  Font     = culong;
  Pcuchar  = ^cuchar;
  PPcuchar = ^Pcuchar;

  XChar2b = record
    byte1: cuchar;
    byte2: cuchar;
  end;
  PXChar2b = ^XChar2b;

  XrmHashBucketRec  = Pointer;
  PXrmHashBucketRec = ^XrmHashBucketRec;

  PXCharStruct = ^TXCharStruct;

  TXCharStruct = record
    lbearing: cshort;
    rbearing: cshort;
    Width: cshort;
    ascent: cshort;
    descent: cshort;
    attributes: cushort;
  end;

  PXID = ^TXID;
  TXID = culong;

  PPixmap = ^TPixmap;
  TPixmap = TXID;

  PXSegment = ^TXSegment;

  TXSegment = record
    x1, y1, x2, y2: cshort;
  end;

  PColormap = ^TColormap;
  TColormap = TXID;

  PKeySym = ^TKeySym;
  TKeySym = TXID;

  PPWindow = ^PWindow;
  PWindow  = ^TWindow;
  TWindow  = TXID;

  PXErrorEvent = ^TXErrorEvent;

  TXErrorEvent = record
    _type: cint;
    display: PDisplay;
    resourceid: TXID;
    serial: culong;
    error_code: cuchar;
    request_code: cuchar;
    minor_code: cuchar;
  end;

  PXIM = ^TXIM;
  TXIM = record
  end;

  PXIC = ^TXIC;
  TXIC = record
  end;


  PFont = ^TFont;
  TFont = TXID;

  PPAtom = ^PAtom;
  TAtom  = culong;

  PXFontProp = ^TXFontProp;

  TXFontProp = record
    Name: TAtom;
    card32: culong;
  end;

  PPPXFontStruct = ^PPXFontStruct;
  PPXFontStruct  = ^PXFontStruct;
  PXFontStruct   = ^TXFontStruct;

  TXFontStruct = record
    ext_data: PXExtData;
    fid: TFont;
    direction: cunsigned;
    min_char_or_byte2: cunsigned;
    max_char_or_byte2: cunsigned;
    min_byte1: cunsigned;
    max_byte1: cunsigned;
    all_chars_exist: TBool;
    default_char: cunsigned;
    n_properties: cint;
    properties: PXFontProp;
    min_bounds: TXCharStruct;
    max_bounds: TXCharStruct;
    per_char: PXCharStruct;
    ascent: cint;
    descent: cint;
  end;


  PXGCValues = ^TXGCValues;

  TXGCValues = record
    _function: cint;
    plane_mask: culong;
    foreground: culong;
    background: culong;
    line_width: cint;
    line_style: cint;
    cap_style: cint;
    join_style: cint;
    fill_style: cint;
    fill_rule: cint;
    arc_mode: cint;
    tile: TPixmap;
    stipple: TPixmap;
    ts_x_origin: cint;
    ts_y_origin: cint;
    font: TFont;
    subwindow_mode: cint;
    graphics_exposures: TBool;
    clip_x_origin: cint;
    clip_y_origin: cint;
    clip_mask: TPixmap;
    dash_offset: cint;
    dashes: cchar;
  end;

  PXGC = ^TXGC;
  TXGC = record
  end;

  PXColor = ^TXColor;

  TXColor = record
    pixel: culong;
    red, green, blue: cushort;
    flags: cchar;
    pad: cchar;
  end;

  PCursor = ^TCursor;
  TCursor = TXID;

  XWMHints = record
    flags: clong;
    input: Boolean;
    initial_state: cint;
    icon_pixmap: Pixmap;
    icon_window: Window;
    icon_x, icon_y: cint;
    icon_mask: Pixmap;
    window_group: culong;
  end;
  PXWMHints = ^XWMHints;

  XKeyEvent = record // For mseguiintf.pas
    type_: cint;
    serial: culong;
    send_event: Boolean;
    display: PDisplay;
    window: Window;
    root: Window;
    subwindow: Window;
    time: culong;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    keycode: cuint;
    same_screen: Boolean;
  end;
  PXKeyPressedEvent = ^XKeyEvent; // For mseguiintf.pas

  PDrawable = ^TDrawable;
  TDrawable = TXID;

  PXPointer = ^TXPointer;
  TXPointer = ^char;

  PXDisplay = ^TXDisplay;
  TXDisplay = record
  end;

  PXTextProperty = ^TXTextProperty;

  TXTextProperty = record
    Value: pcuchar;
    encoding: TAtom;
    format: cint;
    nitems: culong;
  end;

  PXImage = ^TXImage;

  TXImage = record
    Width, Height: cint;
    xoffset: cint;
    format: cint;
    Data: PChar;
    byte_order: cint;
    bitmap_unit: cint;
    bitmap_bit_order: cint;
    bitmap_pad: cint;
    depth: cint;
    bytes_per_line: cint;
    bits_per_pixel: cint;
    red_mask: culong;
    green_mask: culong;
    blue_mask: culong;
    obdata: TXPointer;
    f: record
      create_image: function(para1: PXDisplay; para2: PVisual; para3: cuint; para4: cint; para5: cint; para6: PChar; para7: cuint; para8: cuint; para9: cint; para10: cint): PXImage; cdecl;
      destroy_image: function(para1: PXImage): cint; cdecl;
      get_pixel: function(para1: PXImage; para2: cint; para3: cint): culong; cdecl;
      put_pixel: function(para1: PXImage; para2: cint; para3: cint; para4: culong): cint; cdecl;
      sub_image: function(para1: PXImage; para2: cint; para3: cint; para4: cuint; para5: cuint): PXImage; cdecl;
      add_pixel: function(para1: PXImage; para2: clong): cint; cdecl;
    end;
  end;

  PXAnyEvent = ^TXAnyEvent;

  TXAnyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
  end;

  PKeyCode = ^TKeyCode;
  TKeyCode = cuchar;

  PXModifierKeymap = ^TXModifierKeymap;

  TXModifierKeymap = record
    max_keypermod: cint;
    modifiermap: PKeyCode;
  end;

  TXKeyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    keycode: cuint;
    same_screen: TBool;
  end;

  TPicture    = txid;
  PPicture    = ^TPicture;
  TPictFormat = txid;
  PPictFormat = ^TPictFormat;

  TXRenderDirectFormat = record
    red: smallint;
    redMask: smallint;
    green: smallint;
    greenMask: smallint;
    blue: smallint;
    blueMask: smallint;
    alpha: smallint;
    alphaMask: smallint;
  end;
  PXRenderDirectFormat = ^TXRenderDirectFormat;


  TXRenderPictFormat = record
    id: TPictFormat;
    _type: longint;
    depth: longint;
    direct: TXRenderDirectFormat;
    colormap: TColormap;
  end;
  PXRenderPictFormat = ^TXRenderPictFormat;

  TXRenderColor = record
    red: word;
    green: word;
    blue: word;
    alpha: word;
  end;
  PXRenderColor = ^TXRenderColor;

  TXGlyphInfo = record
    Width: word;
    Height: word;
    x: smallint;
    y: smallint;
    xOff: smallint;
    yOff: smallint;
  end;
  PXGlyphInfo = ^TXGlyphInfo;

  TXRenderPictureAttributes = record
    _repeat: TBool;
    alpha_map: TPicture;
    alpha_x_origin: longint;
    alpha_y_origin: longint;
    clip_x_origin: longint;
    clip_y_origin: longint;
    clip_mask: TPixmap;
    graphics_exposures: TBool;
    subwindow_mode: longint;
    poly_edge: longint;
    poly_mode: longint;
    dither: TAtom;
    component_alpha: TBool;
  end;
  PXRenderPictureAttributes = ^TXRenderPictureAttributes;

  TXFixed = integer;
  PXFixed = ^TXFixed;

  TXTransform = array[0..2]             //row
    of array[0..2] of TXFixed;      //col
  //m00,m01,0
  //m10,m11,0     x' = m00 * x + m01 * y + dx
  //dx, dy, 1     y' = m11 * y + m10 * x + dy

  PXTransform = ^TXTransform;

  TXPointFixed = record
    x: TXFixed;
    y: TXFixed;
  end;
  PXPointFixed = ^TXPointFixed;


  TXTriangle = record
    p1: TXPointFixed;
    p2: TXPointFixed;
    p3: TXPointFixed;
  end;
  PXTriangle = ^TXTriangle;


  PXKeyReleasedEvent = ^TXKeyReleasedEvent;
  TXKeyReleasedEvent = TXKeyEvent;

  PXButtonEvent = ^TXButtonEvent;

  TXButtonEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    button: cuint;
    same_screen: TBool;
  end;

  PXButtonPressedEvent = ^TXButtonPressedEvent;
  TXButtonPressedEvent = TXButtonEvent;

  PXButtonReleasedEvent = ^TXButtonReleasedEvent;
  TXButtonReleasedEvent = TXButtonEvent;

  PXMotionEvent = ^TXMotionEvent;

  TXMotionEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    is_hint: cchar;
    same_screen: TBool;
  end;

  PXPointerMovedEvent = ^TXPointerMovedEvent;
  TXPointerMovedEvent = TXMotionEvent;

  PXCrossingEvent = ^TXCrossingEvent;

  TXCrossingEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    mode: cint;
    detail: cint;
    same_screen: TBool;
    focus: TBool;
    state: cuint;
  end;

  PXEnterWindowEvent = ^TXEnterWindowEvent;
  TXEnterWindowEvent = TXCrossingEvent;

  PXLeaveWindowEvent = ^TXLeaveWindowEvent;
  TXLeaveWindowEvent = TXCrossingEvent;

  PXFocusChangeEvent = ^TXFocusChangeEvent;

  TXFocusChangeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    mode: cint;
    detail: cint;
  end;

  PXFocusInEvent = ^TXFocusInEvent;
  TXFocusInEvent = TXFocusChangeEvent;

  PXFocusOutEvent = ^TXFocusOutEvent;
  TXFocusOutEvent = TXFocusChangeEvent;

  PXKeymapEvent = ^TXKeymapEvent;

  TXKeymapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    key_vector: array[0..31] of cchar;
  end;

  PXExposeEvent = ^TXExposeEvent;

  TXExposeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    x, y: cint;
    Width, Height: cint;
    Count: cint;
  end;

  PXGraphicsExposeEvent = ^TXGraphicsExposeEvent;

  TXGraphicsExposeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    drawable: TDrawable;
    x, y: cint;
    Width, Height: cint;
    Count: cint;
    major_code: cint;
    minor_code: cint;
  end;

  PXNoExposeEvent = ^TXNoExposeEvent;

  TXNoExposeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    drawable: TDrawable;
    major_code: cint;
    minor_code: cint;
  end;

  PXVisibilityEvent = ^TXVisibilityEvent;

  TXVisibilityEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    state: cint;
  end;

  PXCreateWindowEvent = ^TXCreateWindowEvent;

  TXCreateWindowEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
    x, y: cint;
    Width, Height: cint;
    border_width: cint;
    override_redirect: TBool;
  end;

  PXDestroyWindowEvent = ^TXDestroyWindowEvent;

  TXDestroyWindowEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
  end;

  PXUnmapEvent = ^TXUnmapEvent;

  TXUnmapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    from_configure: TBool;
  end;

  PXMapEvent = ^TXMapEvent;

  TXMapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    override_redirect: TBool;
  end;

  PXMapRequestEvent = ^TXMapRequestEvent;

  TXMapRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
  end;

  PXReparentEvent = ^TXReparentEvent;

  TXReparentEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    parent: TWindow;
    x, y: cint;
    override_redirect: TBool;
  end;

  PXConfigureEvent = ^TXConfigureEvent;

  TXConfigureEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    x, y: cint;
    Width, Height: cint;
    border_width: cint;
    above: TWindow;
    override_redirect: TBool;
  end;

  PXGravityEvent = ^TXGravityEvent;

  TXGravityEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    x, y: cint;
  end;

  PXResizeRequestEvent = ^TXResizeRequestEvent;

  TXResizeRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    Width, Height: cint;
  end;

  PXConfigureRequestEvent = ^TXConfigureRequestEvent;

  TXConfigureRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
    x, y: cint;
    Width, Height: cint;
    border_width: cint;
    above: TWindow;
    detail: cint;
    value_mask: culong;
  end;

  PXCirculateEvent = ^TXCirculateEvent;

  TXCirculateEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    place: cint;
  end;

  PXCirculateRequestEvent = ^TXCirculateRequestEvent;

  TXCirculateRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
    place: cint;
  end;

  PXPropertyEvent = ^TXPropertyEvent;

  TXPropertyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    atom: TAtom;
    time: TTime;
    state: cint;
  end;

  PXSelectionClearEvent = ^TXSelectionClearEvent;

  TXSelectionClearEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    selection: TAtom;
    time: longword;
  end;

  PXSelectionRequestEvent = ^TXSelectionRequestEvent;

  TXSelectionRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    owner: TWindow;
    requestor: TWindow;
    selection: TAtom;
    target: TAtom;
    _property: TAtom;
    time: TTime;
  end;

  PVisualID = ^TVisualID;
  TVisualID = culong;

  PXVisualInfo = ^TXVisualInfo;

  TXVisualInfo = record
    visual: PVisual;
    visualid: TVisualID;
    screen: cint;
    depth: cint;
    _class: cint;
    red_mask: culong;
    green_mask: culong;
    blue_mask: culong;
    colormap_size: cint;
    bits_per_rgb: cint;
  end;

  PXSelectionEvent = ^TXSelectionEvent;

  TXSelectionEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    requestor: TWindow;
    selection: TAtom;
    target: TAtom;
    _property: TAtom;
    time: TTime;
  end;

  PXColormapEvent = ^TXColormapEvent;

  TXColormapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    colormap: TColormap;
    c_new: TBool;
    state: cint;
  end;

  PXClientMessageEvent = ^TXClientMessageEvent;

  TXClientMessageEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    message_type: TAtom;
    format: cint;
    Data: record
      case longint of
        0: (b: array[0..19] of cchar);
        1: (s: array[0..9] of cshort);
        2: (l: array[0..4] of clong);
    end;
  end;

  PXMappingEvent = ^TXMappingEvent;

  TXMappingEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    request: cint;
    first_keycode: cint;
    Count: cint;
  end;

  PXGenericEvent = ^TXGenericEvent;

  TXGenericEvent = record
    _type: cint;                 { of event. Always GenericEvent }
    serial: culong;              { # of last request processed }
    send_event: TBool;           { true if from SendEvent request }
    display: PDisplay;           { Display the event was read from }
    extension: cint;             { major opcode of extension that caused the event }
    evtype: cint;                { actual event type. }
  end;

  PXGenericEventCookie = ^TXGenericEventCookie;

  TXGenericEventCookie = record
    _type: cint;                 { of event. Always GenericEvent }
    serial: culong;              { # of last request processed }
    send_event: TBool;           { true if from SendEvent request }
    display: PDisplay;           { Display the event was read from }
    extension: cint;             { major opcode of extension that caused the event }
    evtype: cint;                { actual event type. }
    cookie: cuint;
    Data: Pointer;
  end;


  PXEvent = ^TXEvent;
  TXEvent = record
    case longint of
      0: (_type: cint);
      1: (xany: TXAnyEvent);
      2: (xkey: TXKeyEvent);
      3: (xbutton: TXButtonEvent);
      4: (xmotion: TXMotionEvent);
      5: (xcrossing: TXCrossingEvent);
      6: (xfocus: TXFocusChangeEvent);
      7: (xexpose: TXExposeEvent);
      8: (xgraphicsexpose: TXGraphicsExposeEvent);
      9: (xnoexpose: TXNoExposeEvent);
      10: (xvisibility: TXVisibilityEvent);
      11: (xcreatewindow: TXCreateWindowEvent);
      12: (xdestroywindow: TXDestroyWindowEvent);
      13: (xunmap: TXUnmapEvent);
      14: (xmap: TXMapEvent);
      15: (xmaprequest: TXMapRequestEvent);
      16: (xreparent: TXReparentEvent);
      17: (xconfigure: TXConfigureEvent);
      18: (xgravity: TXGravityEvent);
      19: (xresizerequest: TXResizeRequestEvent);
      20: (xconfigurerequest: TXConfigureRequestEvent);
      21: (xcirculate: TXCirculateEvent);
      22: (xcirculaterequest: TXCirculateRequestEvent);
      23: (xproperty: TXPropertyEvent);
      24: (xselectionclear: TXSelectionClearEvent);
      25: (xselectionrequest: TXSelectionRequestEvent);
      26: (xselection: TXSelectionEvent);
      27: (xcolormap: TXColormapEvent);
      28: (xclient: TXClientMessageEvent);
      29: (xmapping: TXMappingEvent);
      30: (xerror: TXErrorEvent);
      31: (xkeymap: TXKeymapEvent);
      32: (xgeneric: TXGenericEvent);
      33: (xcookie: TXGenericEventCookie);
      34: (pad: array[0..23] of clong);
  end;

  PDepth = ^TDepth;

  TDepth = record
    depth: cint;
    nvisuals: cint;
    visuals: PVisual;
  end;

  PScreen = ^TScreen;

  TScreen = record
    ext_data: PXExtData;
    display: PXDisplay;
    root: TWindow;
    Width, Height: cint;
    mwidth, mheight: cint;
    ndepths: cint;
    depths: PDepth;
    root_depth: cint;
    root_visual: PVisual;
    default_gc: TGC;
    cmap: TColormap;
    white_pixel: culong;
    black_pixel: culong;
    max_maps, min_maps: cint;
    backing_store: cint;
    save_unders: TBool;
    root_input_mask: clong;
  end;

  PXPrivate = ^TXPrivate;
  TXPrivate = record
  end;

  PScreenFormat = ^TScreenFormat;

  TScreenFormat = record
    ext_data: PXExtData;
    depth: cint;
    bits_per_pixel: cint;
    scanline_pad: cint;
  end;

  PXPrivDisplay = ^TXPrivDisplay;

  TXPrivDisplay = record
    ext_data: PXExtData;
    private1: PXPrivate;
    fd: cint;
    private2: cint;
    proto_major_version: cint;
    proto_minor_version: cint;
    vendor: PChar;
    private3: TXID;
    private4: TXID;
    private5: TXID;
    private6: cint;
    resource_alloc: function(para1: PXDisplay): TXID; cdecl;
    byte_order: cint;
    bitmap_unit: cint;
    bitmap_pad: cint;
    bitmap_bit_order: cint;
    nformats: cint;
    pixmap_format: PScreenFormat;
    private8: cint;
    Release: cint;
    private9, private10: PXPrivate;
    qlen: cint;
    last_request_read: culong;
    request: culong;
    private11: TXPointer;
    private12: TXPointer;
    private13: TXPointer;
    private14: TXPointer;
    max_request_size: cunsigned;
    db: PXrmHashBucketRec;
    private15: function(para1: PXDisplay): cint; cdecl;
    display_name: PChar;
    default_screen: cint;
    nscreens: cint;
    screens: PScreen;
    motion_buffer: culong;
    private16: culong;
    min_keycode: cint;
    max_keycode: cint;
    private17: TXPointer;
    private18: TXPointer;
    private19: cint;
    xdefaults: PChar;
  end;

  PXWindowAttributes = ^TXWindowAttributes;

  TXWindowAttributes = record
    x, y: cint;
    Width, Height: cint;
    border_width: cint;
    depth: cint;
    visual: PVisual;
    root: TWindow;
    c_class: cint;
    bit_gravity: cint;
    win_gravity: cint;
    backing_store: cint;
    backing_planes: culong;
    backing_pixel: culong;
    save_under: TBool;
    colormap: TColormap;
    map_installed: TBool;
    map_state: cint;
    all_event_masks: clong;
    your_event_mask: clong;
    do_not_propagate_mask: clong;
    override_redirect: TBool;
    screen: PScreen;
  end;

{$ifndef use_xcb}
  XSetWindowAttributes = record
    background_pixel: culong;
    event_mask: clong;
    colormap: Colormap;
  end;
  PXSetWindowAttributes = ^XSetWindowAttributes;

 {$else}// xcb
  XSetWindowAttributes = record
    background_pixmap: Pixmap;
    background_pixel: CULong;
    border_pixmap: Pixmap;
    border_pixel: CULong;
    bit_gravity: CInt;
    win_gravity: CInt;
    backing_store: CInt;
    backing_planes: CULong;
    backing_pixel: CULong;
    save_under: CUChar; // Bool in C, often 1 byte
    event_mask: CULong;
    do_not_propagate_mask: CULong;
    override_redirect: CUChar; // Bool in C
    colormap: Colormap;
    cursor: Cursor;
  end;
  PXSetWindowAttributes = ^XSetWindowAttributes;
 {$endif}


  PXPoint = ^TXPoint;

  TXPoint = record
    x, y: cshort;
  end;

  PXWindowChanges = ^TXWindowChanges;

  TXWindowChanges = record
    x, y: cint;
    Width, Height: cint;
    border_width: cint;
    sibling: TWindow;
    stack_mode: cint;
  end;

  TXSetWindowAttributes = record
    background_pixmap: TPixmap;
    background_pixel: culong;
    border_pixmap: TPixmap;
    border_pixel: culong;
    bit_gravity: cint;
    win_gravity: cint;
    backing_store: cint;
    backing_planes: culong;
    backing_pixel: culong;
    save_under: TBool;
    event_mask: clong;
    do_not_propagate_mask: clong;
    override_redirect: TBool;
    colormap: TColormap;
    cursor: TCursor;
  end;

  PXSizeHints = ^TXSizeHints;

  TXSizeHints = record
    flags: clong;
    x, y: cint;
    Width, Height: cint;
    min_width, min_height: cint;
    max_width, max_height: cint;
    width_inc, height_inc: cint;
    min_aspect, max_aspect: record
      x: cint;
      y: cint;
    end;
    base_width, base_height: cint;
    win_gravity: cint;
  end;

  TXRectangle = record
    x, y: cshort;
    Width, Height: cushort;
  end;

  XFontStruct = record
    fid: Font;
    ascent: cint;
    descent: cint;
  end;

  XTextProperty = record
    Value: Pcuchar;
    encoding: Atom;
    format: cint;
    nitems: culong;
  end;

const
  KeyPressMask   = 1 shl 0;
  ExposureMask   = 1 shl 15;
  KeyPress       = 2;
  Expose         = 12;
  ClientMessage  = 33;
  InputOnly      = 2;
  InputOutput    = 1;
  CopyFromParent = 0;
  CWBackPixel    = 1 shl 1;
  CWEventMask    = 1 shl 11;
  CWColormap     = 1 shl 13;
  GCForeground   = 1 shl 2;
  GCBackground   = 1 shl 3;
  GCFont         = 1 shl 14;
  XA_STRING      = 31;
  XA_WM_HINTS    = 35;
  None           = 0;
  PropModeReplace = 0;
  ShapeBounding  = 0;
  ShapeClip      = 1;
  ShapeSet       = 0;
  Button1        = 1;
  Button2        = 2;
  Button3        = 3;
  Button4        = 4;
  Button5        = 5;

       // libX11_xcb
{$ifdef use_xcb}
function XGetXCBConnection(dpy: PDisplay): PXCBConnection; cdecl; external libX11_xcb;
// xcb
function xcb_get_setup(c: Pxcb_connection_t): Pxcb_setup_t; cdecl; external libxcb;
function xcb_setup_roots_iterator(setup: Pxcb_setup_t): xcb_screen_iterator_t; cdecl; external libxcb;
function xcb_generate_id(c: pxcb_connection_t): cuint32; cdecl; external libxcb;
function xcb_create_window_checked(c: Pxcb_connection_t; depth: cint; wid: xcb_window_t;
  parent: xcb_window_t; x, y: cint; width, height, border_width: cuint; _class: cuint;
  visual: xcb_visualid_t; value_mask: cuint32; value_list: Pcuint32): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_reparent_window(c: PXCBConnection; window: Window; parent: Window;
            x: int16; y: int16): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_request_check(c: Pxcb_connection_t; cookie: xcb_void_cookie_t): Pxcb_generic_error_t; cdecl; external libxcb;
function xcb_map_window(c: Pxcb_connection_t; window: Window): xcb_map_window_cookie_t; cdecl; external libxcb;
function xcb_unmap_window(c: Pxcb_connection_t; window: Window): xcb_map_window_cookie_t; cdecl; external libxcb;
procedure xcb_flush(c: pxcb_connection_t); cdecl; external libxcb;
function xcb_intern_atom(c: Pxcb_connection_t; only_if_exists: cuint8; name_len: cuint16; name: PChar): xcb_intern_atom_cookie_t; cdecl; external libxcb;
function xcb_intern_atom_reply(c: Pxcb_connection_t; cookie: xcb_intern_atom_cookie_t; e: PPxcb_generic_error_t): Pxcb_intern_atom_reply_t; cdecl; external libxcb;
function xcb_get_geometry(c: Pxcb_connection_t; drawable: Drawable): xcb_get_geometry_cookie_t; cdecl; external libxcb;
function xcb_get_geometry_reply(c: Pxcb_connection_t; cookie: xcb_get_geometry_cookie_t; e: PPxcb_generic_error_t): Pxcb_get_geometry_reply_t; cdecl; external libxcb;
function xcb_get_property(c: pxcb_connection_t; Delete: cuint8; window: xcb_window_t; prop: xcb_atom_t; type_: xcb_atom_t; offset, length: cuint32): xcb_get_property_cookie_t; cdecl; external libxcb;
function xcb_get_property_reply(c: pxcb_connection_t; cookie: xcb_get_property_cookie_t; e: Pointer): pxcb_get_property_reply_t; cdecl; external libxcb;
function xcb_get_property_value(reply: Pxcb_get_property_reply_t): Pointer; cdecl; external libxcb;
function xcb_change_property(c: pxcb_connection_t; mode: cuint8; window: xcb_window_t;
        prop: xcb_atom_t; type_: xcb_atom_t; format: cuint8; data_len: cuint32; Data: Pointer): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_get_file_descriptor(c: Pxcb_connection_t): cint; cdecl; external libxcb;

procedure free(ptr: Pointer); cdecl; external 'libc.so';
  
// macro xcb
function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; Width, Height, border_width: cuint;
          depth: cint; window_class: cuint; visual: PVisual; valuemask: culong;
          attributes: PXSetWindowAttributes): Window; cdecl;
procedure XMapWindow(display: PDisplay; w: Window); cdecl;
function XUnmapWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
procedure XFlush(display: PDisplay); cdecl; 
function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;
function XReparentWindow(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint): cint; cdecl;         
function XGetGeometry(display: PDisplay; d: TDrawable; root: PWindow; x, y: PLongInt; 
         width, height, border_width, depth: PLongWord): LongInt; cdecl;
function XChangeProperty(display: PDisplay; w: Window; atom_property: Atom;
         type_: Atom; format: cint; mode: cint; Data: Pcuchar; nelements: cint): cint; cdecl;
function XConnectionNumber(display: PDisplay): cint; cdecl;

{$else}// libX11         
function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; Width, Height, border_width: cuint; depth: cint; window_class: cuint; visual: PVisual; valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl; external libX11;
procedure XMapWindow(display: PDisplay; w: Window); cdecl; external libX11;
procedure XFlush(display: PDisplay); cdecl; external libX11;
function XUnmapWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl; external libX11;
function XInternAtom(para1: PDisplay; para2: PChar; para3: TBool): TAtom; cdecl; external libX11;
function XReparentWindow(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint): cint; cdecl; external libX11;
function XGetGeometry(para1: PDisplay; para2: TDrawable; para3: PWindow; para4: Pcint; para5: Pcint; para6: Pcuint; para7: Pcuint; para8: Pcuint; para9: Pcuint): TStatus; cdecl; external libX11;
function XChangeProperty(para1: PDisplay; para2: TWindow; para3: TAtom; para4: TAtom; para5: cint; para6: cint; para7: Pcuchar; para8: cint): cint; cdecl; external libX11;
function XConnectionNumber(para1: PDisplay): cint; cdecl; external libX11;
{$endif}

function XOpenDisplay(display_name: PChar): PDisplay; cdecl; external libX11;
procedure XCloseDisplay(display: PDisplay); cdecl; external libX11;
function XDefaultScreen(display: PDisplay): cint; cdecl; external libX11;
function XDefaultVisual(display: PDisplay; screen_number: cint): PVisual; cdecl; external libX11;
function XGetWindowProperty(para1: PDisplay; para2: TWindow; para3: TAtom; para4: clong; para5: clong; para6: TBool; para7: TAtom; para8: PAtom; para9: Pcint; para10: Pculong; para11: Pculong; para12: PPcuchar): cint; cdecl; external libX11;
procedure XSelectInput(display: PDisplay; w: Window; event_mask: clong); cdecl; external libX11;
procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl; external libX11;
function XPending(display: PDisplay): cint; cdecl; external libX11;
function XSendEvent(para1: PDisplay; para2: TWindow; para3: TBool; para4: clong; para5: PXEvent): TStatus; cdecl; external libX11;
function XGetAtomName(display: PDisplay; atom: Atom): PChar; cdecl; external libX11;
function XSetWMHints(display: PDisplay; w: Window; wmhints: PXWMHints): cint; cdecl; external libX11;
function XInternAtoms(para1: PDisplay; para2: PPchar; para3: cint; para4: TBool; para5: PAtom): TStatus; cdecl; external libX11;
procedure XFree(Data: Pointer); cdecl; external libX11;
function XCreateGC(display: PDisplay; d: Drawable; valuemask: culong; values: PXGCValues): GC; cdecl; external libX11;
procedure XFreeGC(display: PDisplay; gc: GC); cdecl; external libX11;
procedure XSetForeground(display: PDisplay; gc: GC; foreground: culong); cdecl; external libX11;
procedure XDrawLine(display: PDisplay; d: Drawable; gc: GC; x1, y1, x2, y2: cint); cdecl; external libX11;
function XLoadQueryFont(display: PDisplay; Name: PChar): PXFontStruct; cdecl; external libX11;
procedure XFreeFont(display: PDisplay; font_struct: PXFontStruct); cdecl; external libX11;
procedure XDrawString(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PChar; length: cint); cdecl; external libX11;
procedure XDrawString16(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PXChar2b; length: cint); cdecl; external libX11; // For mseguiintf.pas
procedure XPutImage(display: PDisplay; d: Drawable; gc: GC; image: PXImage; src_x, src_y: cint; dest_x, dest_y: cint; Width, Height: cuint); cdecl; external libX11; // For mseguiintf.pas
function XLookupString(event_struct: PXKeyPressedEvent; buffer_return: PChar; bytes_buffer: cint; keysym_return: Pculong; status_in_out: Pointer): cint; cdecl; external libX11; // For mseguiintf.pas
function XSetClipRectangles(para1: PDisplay; para2: TGC; para3: cint; para4: cint; para5: PXRectangle; para6: cint; para7: cint): cint; cdecl; external libX11;
function XCreatePixmapCursor(ADisplay: PDisplay; ASource: TPixmap; AMask: TPixmap; AForegroundColor: PXColor; ABackgroundColor: PXColor; AX: cuint; AY: cuint): TCursor; cdecl; external libX11;
function XCreatePixmap(ADisplay: PDisplay; ADrawable: TDrawable; AWidth: cuint; AHeight: cuint; ADepth: cuint): TPixmap; cdecl; external libX11;
function XSetDashes(para1: PDisplay; para2: TGC; para3: cint; para4: PChar; para5: cint): cint; cdecl; external libX11;
function XFreePixmap(para1: PDisplay; para2: TPixmap): cint; cdecl; external libX11;
function XChangeGC(para1: PDisplay; para2: TGC; para3: culong; para4: PXGCValues): cint; cdecl; external libX11;
function XGetImage(para1: PDisplay; para2: TDrawable; para3: cint; para4: cint; para5: cuint; para6: cuint; para7: culong; para8: cint): PXImage; cdecl; external libX11;
function XCopyArea(para1: PDisplay; para2: TDrawable; para3: TDrawable; para4: TGC; para5: cint; para6: cint; para7: cuint; para8: cuint; para9: cint; para10: cint): cint; cdecl; external libX11;
function XSetFunction(para1: PDisplay; para2: TGC; para3: cint): cint; cdecl; external libX11;
function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBoolResult; cdecl; external libxext;
function XShapeCombineRegion(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; region: TRegion; op: cint): TStatus; cdecl; external libxext;
procedure XShapeCombineRectangles(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; rectangles: PXRectangle; n_rects: cint; op: cint; ordering: cint); cdecl; external libxext;
function XSetClipMask(para1: PDisplay; para2: TGC; para3: TPixmap): cint; cdecl; external libX11;
function XFreeFontInfo(para1: PPchar; para2: PXFontStruct; para3: cint): cint; cdecl; external libX11;
function XUnloadFont(para1: PDisplay; para2: TFont): cint; cdecl; external libX11;
function XFillRectangle(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint): cint; cdecl; external libX11;
function XCopyPlane(para1: PDisplay; para2: TDrawable; para3: TDrawable; para4: TGC; para5: cint; para6: cint; para7: cuint; para8: cuint; para9: cint; para10: cint; para11: culong): cint; cdecl; external libX11;
function XCopyGC(para1: PDisplay; para2: TGC; para3: culong; para4: TGC): cint; cdecl; external libX11;
function XDrawLines(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXPoint; para5: cint; para6: cint): cint; cdecl; external libX11;
function XDrawSegments(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXSegment; para5: cint): cint; cdecl; external libX11;
function XFillArc(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl; external libX11;
function XDrawArc(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl; external libX11;
function XSetClipOrigin(para1: PDisplay; para2: TGC; para3: cint; para4: cint): cint; cdecl; external libX11;
function XFillPolygon(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXPoint; para5: cint; para6: cint; para7: cint): cint; cdecl; external libX11;
function XCreateRegion: TRegion; cdecl; external libX11;
function XUnionRectWithRegion(para1: PXRectangle; para2: TRegion; para3: TRegion): cint; cdecl; external libX11;
function XDestroyRegion(para1: TRegion): cint; cdecl; external libX11;
function XEmptyRegion(para1: TRegion): cint; cdecl; external libX11;
function XClipBox(para1: TRegion; para2: PXRectangle): cint; cdecl; external libX11;
function XUnionRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl; external libX11;
function XOffsetRegion(para1: TRegion; para2: cint; para3: cint): cint; cdecl; external libX11;
function XSubtractRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl; external libX11;
function XwcTextListToTextProperty(para1: PDisplay; para2: PPWideChar; para3: cint; para4: TXICCEncodingStyle; para5: PXTextProperty): cint; cdecl; external libX11;
function XIntersectRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl; external libX11;
function XSetSelectionOwner(para1: PDisplay; para2: TAtom; para3: TWindow; para4: TTime): cint; cdecl; external libX11;
function XDeleteProperty(para1: PDisplay; para2: TWindow; para3: TAtom): cint; cdecl; external libX11;
function XCheckTypedEvent(para1: PDisplay; para2: cint; para3: PXEvent): TBoolResult; cdecl; external libX11;
function XConvertSelection(para1: PDisplay; para2: TAtom; para3: TAtom; para4: TAtom; para5: TWindow; para6: TTime): cint; cdecl; external libX11;
function XGetSelectionOwner(para1: PDisplay; para2: TAtom): TWindow; cdecl; external libX11;
procedure XFreeStringList(para1: PPchar); cdecl; external libX11;
function XGetWindowAttributes(para1: PDisplay; para2: TWindow; para3: PXWindowAttributes): TStatus; cdecl; external libX11;
function XSync(para1: PDisplay; para2: TBool): cint; cdecl; external libX11;
function XIconifyWindow(para1: PDisplay; para2: TWindow; para3: cint): TStatus; cdecl; external libX11;
procedure XSetWMName(para1: PDisplay; para2: TWindow; para3: PXTextProperty); cdecl; external libX11;
function XGetWMHints(para1: PDisplay; para2: TWindow): PXWMHints; cdecl; external libX11;
function XAllocWMHints: PXWMHints; cdecl; external libX11;
function XQueryTree(para1: PDisplay; para2: TWindow; para3: PWindow; para4: PWindow; para5: PPWindow; para6: Pcuint): TStatus; cdecl; external libX11;
function XRaiseWindow(para1: PDisplay; para2: TWindow): cint; cdecl; external libX11;
function XLowerWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl; external libX11;
function XReconfigureWMWindow(para1: PDisplay; para2: TWindow; para3: cint; para4: cuint; para5: PXWindowChanges): TStatus; cdecl; external libX11;
function XQueryPointer(para1: PDisplay; para2: TWindow; para3: PWindow; para4: PWindow; para5: Pcint; para6: Pcint; para7: Pcint; para8: Pcint; para9: Pcuint): TBoolResult; cdecl; external libX11;
function XWarpPointer(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl; external libX11;
function XUngrabPointer(para1: PDisplay; para2: TTime): cint; cdecl; external libX11;
function XGrabPointer(para1: PDisplay; para2: TWindow; para3: TBool; para4: cuint; para5: cint; para6: cint; para7: TWindow; para8: TCursor; para9: TTime): cint; cdecl; external libX11;
function XSetGraphicsExposures(para1: PDisplay; para2: TGC; para3: TBool): cint; cdecl; external libX11;
function XGetTransientForHint(para1: PDisplay; para2: TWindow; para3: PWindow): TStatus; cdecl; external libX11;
function XSetInputFocus(para1: PDisplay; para2: TWindow; para3: cint; para4: TTime): cint; cdecl; external libX11;
function XCreateBitmapFromData(ADiplay: PDisplay; ADrawable: TDrawable; AData: PChar; AWidth: cuint; AHeight: cuint): TPixmap; cdecl; external libX11;
function XCreateFontCursor(ADisplay: PDisplay; AShape: cuint): TCursor; cdecl; external libX11;
function XDefineCursor(ADisplay: PDisplay; AWindow: TWindow; ACursor: TCursor): cint; cdecl; external libX11;
function XFreeCursor(ADisplay: PDisplay; ACursor: TCursor): cint; cdecl; external libX11;
function XSetTransientForHint(ADisplay: PDisplay; AWindow: TWindow; APropWindow: TWindow): cint; cdecl; external libX11;
function XTranslateCoordinates(ADisplay: PDisplay; ASrcWindow: TWindow; ADestWindow: TWindow; ASrcX: cint; ASrcY: cint; ADestXReturn: Pcint; ADestYReturn: Pcint; AChildReturn: PWindow): TBool; cdecl; external libX11;
function XDrawRectangle(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint): cint; cdecl; external libX11;
function XFreeColormap(para1: PDisplay; para2: TColormap): cint; cdecl; external libX11;
function XSetWMProtocols(para1: PDisplay; para2: TWindow; para3: PAtom; para4: cint): TStatus; cdecl; external libX11;
function XDestroyWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl; external libX11;
function XAllocSizeHints: PXSizeHints; cdecl; external libX11;
function XGetWMNormalHints(para1: PDisplay; para2: TWindow; para3: PXSizeHints; para4: Pclong): TStatus; cdecl; external libX11;
procedure XSetWMNormalHints(ADisplay: PDisplay; AWindow: TWindow; AHints: PXSizeHints); cdecl; external libX11;
function XConfigureWindow(para1: PDisplay; para2: TWindow; para3: cuint; para4: PXWindowChanges): cint; cdecl; external libX11;
function XBell(para1: PDisplay; para2: cint): cint; cdecl; external libX11;
function XScreenNumberOfScreen(para1: PScreen): cint; cdecl; external libX11;
function XCheckTypedWindowEvent(para1: PDisplay; para2: TWindow; para3: cint; para4: PXEvent): TBoolResult; cdecl; external libX11;
function XPeekEvent(ADisplay: PDisplay; AEvent: PXEvent): cint; cdecl; external libX11;
function XFilterEvent(para1: PXEvent; para2: TWindow): TBoolResult; cdecl; external libX11;
function XRefreshKeyboardMapping(para1: PXMappingEvent): cint; cdecl; external libX11;
function XGetErrorText(para1: PDisplay; para2: cint; para3: PChar; para4: cint): cint; cdecl; external libX11;
function XCreateColormap(para1: PDisplay; para2: TWindow; para3: PVisual; para4: cint): TColormap; cdecl; external libX11;
function XStoreColors(para1: PDisplay; para2: TColormap; para3: PXColor; para4: cint): cint; cdecl; external libX11;
function XSupportsLocale: TBool; cdecl; external libX11;
function XDefaultScreenOfDisplay(para1: PDisplay): PScreen; cdecl; external libX11;
function XRootWindowOfScreen(para1: PScreen): TWindow; cdecl; external libX11;
function XDefaultVisualOfScreen(para1: PScreen): PVisual; cdecl; external libX11;
function XDefaultDepthOfScreen(para1: PScreen): cint; cdecl; external libX11;
function XDefaultColormapOfScreen(para1: PScreen): TColormap; cdecl; external libX11;
function XKeysymToKeycode(para1: PDisplay; para2: TKeySym): TKeyCode; cdecl; external libX11;
function XGetModifierMapping(para1: PDisplay): PXModifierKeymap; cdecl; external libX11;
function XFreeModifiermap(para1: PXModifierKeymap): cint; cdecl; external libX11;

type

  TXErrorHandler = function(para1: PDisplay; para2: PXErrorEvent): cint; cdecl;

function XSetErrorHandler(para1: TXErrorHandler): TXErrorHandler; cdecl; external libX11;

// Macros
function XDestroyImage(ximage: PXImage): cint;
function XInternAtoms(para1: PDisplay; para2: PPchar; para3: cint; para4: Boolean; para5: PAtom): TStatus;
function XInternAtom(para1: PDisplay; para2: PChar; para3: Boolean): TAtom;
function XSendEvent(para1: PDisplay; para2: TWindow; para3: Boolean; para4: clong; para5: PXEvent): TStatus;
function XSync(para1: PDisplay; para2: Boolean): cint;
function XGrabPointer(para1: PDisplay; para2: TWindow; para3: Boolean; para4: cuint; para5: cint; para6: cint; para7: TWindow; para8: TCursor; para9: TTime): cint;
function XSetGraphicsExposures(para1: PDisplay; para2: TGC; para3: Boolean): cint;
function WhitePixel(dpy: PDisplay; scr: cint): culong;
function ScreenOfDisplay(dpy: PDisplay; scr: cint): PScreen;
function DefaultScreen(dpy: PDisplay): cint;
function XGetWindowProperty(para1: PDisplay; para2: TWindow; para3: TAtom; para4: clong; para5: clong; para6: Boolean; para7: TAtom; para8: PAtom; para9: Pcint; para10: Pculong; para11: Pculong; para12: PPcuchar): cint;
function DefaultDepthOfScreen(s: PScreen): cint;

var
  g_wm_protocols_atom: Atom = 0;
  g_wm_delete_window_atom: Atom = 0;
  wm_delete_window_atom: Atom = 0;
  mse_client_message_atom: Atom = 0;
  wm_protocols_atom: Atom = 0;

implementation

{$ifdef use_xcb}
function XChangeProperty(display: PDisplay; w: Window; atom_property: Atom; type_: Atom; format: cint; mode: cint; Data: Pcuchar; nelements: cint): cint; cdecl;
begin
  Result := 0;
  xcb_change_property(XGetXCBConnection(display), mode, w, atom_property, type_, format, nelements, Data);
end;

function XConnectionNumber(display: PDisplay): cint; cdecl;
begin
  Result := xcb_get_file_descriptor(Pxcb_connection_t(XGetXCBConnection(display)));
end;

function XGetGeometry(display: PDisplay; d: TDrawable; root: PWindow; x, y: PLongInt;
         width, height, border_width, depth: PLongWord): LongInt; cdecl;
var
  conn: PXCBConnection;
  cookie: xcb_get_geometry_cookie_t;
  reply: Pxcb_get_geometry_reply_t;
begin
  conn := XGetXCBConnection(display);
  cookie := xcb_get_geometry(conn, d);
  reply := xcb_get_geometry_reply(conn, cookie, nil);
   if reply <> nil then begin
    if root <> nil then root^ := reply^.root;
    if x <> nil then x^ := reply^.x;
    if y <> nil then y^ := reply^.y;
    if width <> nil then width^ := reply^.width;
    if height <> nil then height^ := reply^.height;
    if border_width <> nil then border_width^ := reply^.border_width;
    if depth <> nil then depth^ := reply^.depth;
    free(reply);
    Result := 1; // Success
  end else
    Result := 0; // Failure
end;

function XReparentWindow(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint): cint; cdecl;
begin
  xcb_reparent_window(XGetXCBConnection(para1), para2, para3, para4, para5);
end;

function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;
var
  conn: PXCBConnection;
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
  atomculong: culong;
begin
  // writeln(Format('DEBUG: XInternAtom called for atom: "%s", only_if_exists: %d', [atom_name, only_if_exists]));
  Result := 0;
  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    // writeln('ERROR: XInternAtom: Could not get XCB connection.');
    Exit;
  end;
  cookie := xcb_intern_atom(conn, CUChar(only_if_exists), CUShort(StrLen(atom_name)), atom_name);
  reply := xcb_intern_atom_reply(conn, cookie, nil); // nil for error means we don't care about the error structure
  if reply <> nil then
  begin
    atomculong := reply^.atom;
    Result := atomculong;
    // writeln(Format('DEBUG: XInternAtom: Atom "%s" interned successfully with ID: %d', [atom_name, Result]));
    // Update global atoms if they are the ones being interned
    free(reply);
  end
  else
  begin
    // writeln(Format('ERROR: XInternAtom: Failed to intern atom "%s".', [atom_name]));
    Result := 0;
  end;
end;

function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; Width, Height, border_width: cuint;
      depth: cint; window_class: cuint; visual: PVisual; valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl;
var
  wid: xcb_window_t;
  conn: PXCBConnection;
  cookie: xcb_void_cookie_t;
  error: Pxcb_generic_error_t;
  screen: Pxcb_screen_t;
  setup: Pxcb_setup_t;
  iter: xcb_screen_iterator_t;
  default_visual: xcb_visualid_t;
  xcb_value_list_idx: CInt;
  xcb_value_mask: CUInt;
  xcb_value_list_arr: array[0..14] of CUInt; // Max possible attributes
begin
  Result := 0;
  error := nil;
  
  // WriteLn('XCreateWindow: display=', PtrInt(display), ' visual=', PtrInt(visual), ' attributes=', PtrInt(attributes));
  // if display = nil then WriteLn('XCreateWindow: display is null');
  // if attributes = nil then WriteLn('XCreateWindow: attributes is null');
  
  if (display = nil) or (attributes = nil) then
  begin
    // WriteLn('XCreateWindow: Invalid parameters, exiting');
    Exit;
  end;
 
  conn := XGetXCBConnection(display);
 
  // Get default visual if visual is null
  if visual = nil then
  begin
    //  WriteLn('XCreateWindow: visual is null, using default visual');
    setup := xcb_get_setup(conn);
    // WriteLn('xcb_get_setup done');
   
    if setup = nil then
    begin
     // WriteLn('XCreateWindow: Failed to get setup');
      Exit;
    end;
    iter := xcb_setup_roots_iterator(setup);
    screen := iter.data;
    if screen = nil then
    begin
     // WriteLn('XCreateWindow: Failed to get screen');
      Exit;
    end;
    default_visual := screen^.root_visual;
  end
  else
    default_visual := visual^.visualid;

   wid := xcb_generate_id(conn);
  
  // WriteLn('xcb_generate_id ', wid);
   
  xcb_value_list_idx := 0;
  xcb_value_mask := 0;
  
  // Translate Xlib valuemask and attributes to XCB value_mask and value_list
  if (valuemask and CWBackPixmap) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BACK_PIXMAP;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.background_pixmap;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBackPixel) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BACK_PIXEL;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.background_pixel;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBorderPixmap) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BORDER_PIXMAP;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.border_pixmap;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBorderPixel) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BORDER_PIXEL;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.border_pixel;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBitGravity) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BIT_GRAVITY;
    xcb_value_list_arr[xcb_value_list_idx] := CUInt(attributes^.bit_gravity);
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWWinGravity) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_WIN_GRAVITY;
    xcb_value_list_arr[xcb_value_list_idx] := CUInt(attributes^.win_gravity);
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBackingStore) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BACKING_STORE;
    xcb_value_list_arr[xcb_value_list_idx] := CUInt(attributes^.backing_store);
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBackingPlanes) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BACKING_PLANES;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.backing_planes;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWBackingPixel) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_BACKING_PIXEL;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.backing_pixel;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWOverrideRedirect) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_OVERRIDE_REDIRECT;
    xcb_value_list_arr[xcb_value_list_idx] := CUInt(attributes^.override_redirect);
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWSaveUnder) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_SAVE_UNDER;
    xcb_value_list_arr[xcb_value_list_idx] := CUInt(attributes^.save_under);
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWEventMask) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_EVENT_MASK;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.event_mask;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWDontPropagate) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_DONT_PROPAGATE;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.do_not_propagate_mask;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWColormap) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_COLORMAP;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.colormap;
    Inc(xcb_value_list_idx);
  end;
  if (valuemask and CWCursor) <> 0 then
  begin
    xcb_value_mask := xcb_value_mask or XCB_CW_CURSOR;
    xcb_value_list_arr[xcb_value_list_idx] := attributes^.cursor;
    Inc(xcb_value_list_idx);
  end;
  
   // WriteLn('avant xcb_create_window_checked');
    
    cookie := xcb_create_window_checked(conn, depth, wid, parent, x, y, Width, Height, border_width,
                                     window_class, default_visual, xcb_value_mask, @xcb_value_list_arr[0]);
 
  // WriteLn('apres xcb_create_window_checked');
   
   error := xcb_request_check(conn, cookie);
   
   // WriteLn('apres xcb_request_check');
  
  if error <> nil then
  begin
    // WriteLn('Error creating window: ', error^.error_code);
    free(error);
    Result := 0;
  end
  else
  begin
    // WriteLn('window create OK');
    Result := wid;
  end;
end;

procedure XMapWindow(display: PDisplay; w: Window); cdecl;
begin
 xcb_map_window(XGetXCBConnection(display), w);
end;

function XUnmapWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
begin
  xcb_unmap_window(XGetXCBConnection(ADisplay), AWindow);
end;

procedure XFlush(display: PDisplay); cdecl;
begin
 xcb_flush(XGetXCBConnection(display));
end;

{$endif}

function XDestroyImage(ximage: PXImage): cint;
begin
  XDestroyImage := ximage^.f.destroy_image(ximage);
end;

function XInternAtoms(para1: PDisplay; para2: PPchar; para3: cint; para4: Boolean; para5: PAtom): TStatus;
begin
  Result := XInternAtoms(para1, para2, para3, Ord(para4), para5);
end;

function ScreenOfDisplay(dpy: PDisplay; scr: cint): PScreen;
begin
  ScreenOfDisplay := @(((PXPrivDisplay(dpy))^.screens)[scr]);
end;

function XSendEvent(para1: PDisplay; para2: TWindow; para3: Boolean; para4: clong; para5: PXEvent): TStatus;
begin
  Result := XSendEvent(para1, para2, Ord(Para3), para4, para5);
end;

function XSync(para1: PDisplay; para2: Boolean): cint;
begin
  Result := XSync(Para1, Ord(Para2));
end;

function XGrabPointer(para1: PDisplay; para2: TWindow; para3: Boolean; para4: cuint; para5: cint; para6: cint; para7: TWindow; para8: TCursor; para9: TTime): cint;
begin
  Result := XGrabPointer(para1, para2, Ord(para3), para4, para5, para6, para7, para8, para9);
end;

function XSetGraphicsExposures(para1: PDisplay; para2: TGC; para3: Boolean): cint;
begin
  Result := XSetGraphicsExposures(Para1, para2, Ord(Para3));
end;

function WhitePixel(dpy: PDisplay; scr: cint): culong;
begin
  WhitePixel := (ScreenOfDisplay(dpy, scr))^.white_pixel;
end;

function DefaultScreen(dpy: PDisplay): cint;
begin
  DefaultScreen := (PXPrivDisplay(dpy))^.default_screen;
end;

function XInternAtom(para1: PDisplay; para2: PChar; para3: Boolean): TAtom;
begin
  Result := XInternAtom(para1, para2, Ord(para3));
end;

function XGetWindowProperty(para1: PDisplay; para2: TWindow; para3: TAtom; para4: clong; para5: clong; para6: Boolean; para7: TAtom; para8: PAtom; para9: Pcint; para10: Pculong; para11: Pculong; para12: PPcuchar): cint;
begin
  Result := XGetWindowProperty(para1, para2, para3, para4, para5, Ord(para6), para7, para8, para9, para10, para11, para12);
end;

function DefaultDepthOfScreen(s: PScreen): cint;
begin
  DefaultDepthOfScreen := s^.root_depth;
end;

end.

