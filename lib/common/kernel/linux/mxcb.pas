unit mxcb;

 {$mode objfpc}{$h+}

interface

uses
 mseguiglob, math, Classes, ctypes; // For culong, cint, cuint, cshort, cchar, cuchar

{$PACKRECORDS C}
const
  libxcb        = 'libxcb.so.1';
  libxcb_shape  = 'libxcb-shape.so.0';
  libxcb_render = 'libxcb-render.so.0';
  libxcb_randr  = 'libxcb-randr.so.0';
  libxcb_keysyms = 'libxcb-keysyms.so.1';

type
 
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
  PDisplay          = Pxcb_connection_t; // Alias for XCB connection

  xcb_void_cookie_t = record
    sequence: cuint;
  end;

  Pxcb_void_cookie_t = ^xcb_void_cookie_t;

  PBool       = ^TBool;
  TBool       = cint;
  TBoolResult = longbool;

  TStatus = cint;
  PStatus = ^TStatus;
  TRegion = Pointer; // Maps to xcb_region_t

  XRectangle = record
    x, y: cshort;
    Width, Height: cushort;
  end;
  PXRectangle = ^XRectangle;

  Display = Pointer; // Maps to xcb_connection_t*

  // XID type for mxrandr.pas
  txid = culong;
  pxid = ^txid;

  Time  = culong;
  TTime = culong;
  PTime = ^TTime;

  Window   = culong; // Maps to xcb_window_t
  PPWindow = ^PWindow;
  PWindow  = ^TWindow;
  TWindow  = TXID;

  RROutput    = txid;
  pRROutput   = ^RROutput;
  RRCrtc      = txid;
  pRRCrtc     = ^RRCrtc;
  RRMode      = txid;
  pRRMode     = ^RRMode;
  RRProvider  = txid;
  pRRProvider = ^RRProvider;

  XRRModeFlags = culong;

  XRRModeInfo = record
    id: RRMode;
    Width: cuint;
    Height: cuint;
    dotClock: culong;
    hSyncStart: cuint;
    hSyncEnd: cuint;
    hTotal: cuint;
    hSkew: cuint;
    vSyncStart: cuint;
    vSyncEnd: cuint;
    vTotal: cuint;
    Name: PChar;
    nameLength: cuint;
    modeFlags: XRRModeFlags;
  end;
  pXRRModeInfo = ^XRRModeInfo;

  XRRScreenResources = record
    timestamp: Time;
    configTimestamp: Time;
    ncrtc: cint;
    crtcs: pRRCrtc;
    noutput: cint;
    outputs: pRROutput;
    nmode: cint;
    modes: pXRRModeInfo;
  end;
  pXRRScreenResources = ^XRRScreenResources;

  xcb_drawable_t = cuint32;
  Drawable       = cuint; // Maps to xcb_drawable_t
  TDrawable = Drawable;   // For mseguiintf.pas
 
  GC  = Pointer;          // Maps to xcb_gcontext_t
  TGC = GC;
  
  xcb_atom_t = Cardinal; // Cardinal is guaranteed 32-bit unsigned
  Atom = Cardinal;        // Make sure Atom also uses Cardinal directly
  PAtom = ^Atom;
 
  Colormap  = cuint32;       // Maps to xcb_colormap_t
  TColormap = Colormap;   // For mseguiintf.pas
  Pixmap    = cuint;      // Maps to xcb_pixmap_t
  TPixmap   = Pixmap;     // For mshape.pas
  Font      = cuint;      // Maps to xcb_font_t
  TKeySym   = culong;
  PKeySym   = ^TKeySym;
  Cursor = CULong;
  
  Pcuchar   = ^cuchar;
  PPcuchar  = ^Pcuchar;

  Picture   = culong;  // Maps to xcb_render_picture_t
  TPicture  = Picture; // For msex11gdi.pas

  XSizeHints = record
    flags: clong;
    x, y: cint;
    Width, Height: cint;
    min_width, min_height: cint;
    max_width, max_height: cint;
    width_inc, height_inc: cint;
    min_aspect, max_aspect: record
      x, y: cint;
    end;
    base_width, base_height: cint;
    win_gravity: cint;
  end;
  PXSizeHints = ^XSizeHints;

  XClassHint = record
    res_name: PChar;
    res_class: PChar;
  end;
  PXClassHint = ^XClassHint;

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

  XVisualInfo = record
    visual: PVisual;
    visualid: VisualID;
    screen: cint;
    depth: cint;
    visual_class: cint; // Renamed from class
    red_mask: culong;
    green_mask: culong;
    blue_mask: culong;
    colormap_size: cint;
    bits_per_rgb: cint;
  end;
  PXVisualInfo = ^XVisualInfo;

  XChar2b = record
    byte1: cuchar;
    byte2: cuchar;
  end;
  PXChar2b = ^XChar2b;

  XrmHashBucketRec  = Pointer;
  PXrmHashBucketRec = ^XrmHashBucketRec;

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

  XKeyEvent = record
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
  PXKeyPressedEvent = ^XKeyEvent;

  // XSetWindowAttributes structure from Xlib
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

  XGCValues = record
    foreground: culong;
    background: culong;
    font: Font;
  end;
  PXGCValues = ^XGCValues;

  XModifierKeymap = record
    max_keypermod: cint;
    modifiermap: Pcuchar;
  end;
  PXModifierKeymap = ^XModifierKeymap;

  // XCB-specific types
  xcb_gcontext_t = cuint;
  xcb_pixmap_t   = cuint;
  xcb_font_t     = cuint;
  xcb_region_t   = Pointer;

  // XRender-specific types for msex11gdi.pas and mxft.pas
  xcb_render_color_t = record
    red, green, blue, alpha: cuint16;
  end;
  xcb_render_pictformat_t = cuint32;
  xcb_render_picture_t    = cuint32;

  TXRenderColor = record
    red, green, blue, alpha: cushort;
  end;
  PXRenderColor = ^TXRenderColor;
  XRenderColor  = TXRenderColor;
  TXGlyph       = cuint32;
  PXGlyph       = ^TXGlyph;

  XRenderPictFormat = record
    id: cuint32;
    type_: cint;
    depth: cint;
    direct: record
      red, redMask: cint;
      green, greenMask: cint;
      blue, blueMask: cint;
      alpha, alphaMask: cint;
    end;
    colormap: Colormap;
  end;
  PXRenderPictFormat = ^XRenderPictFormat;

  TXGlyphInfo = record
    Width: word;
    Height: word;
    x: smallint;
    y: smallint;
    xOff: smallint;
    yOff: smallint;
  end;
  PXGlyphInfo = ^TXGlyphInfo;

  PPAtom  = ^PAtom;
  TAtom   = cardinal;
  TXFixed = integer;
  PXFixed = ^TXFixed;

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

  PFont = ^TFont;
  TFont = TXID;

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

  PXPointer = ^TXPointer;
  TXPointer = ^char;

  PXPoint = ^TXPoint;

  TXPoint = record
    x, y: cshort;
  end;

  TXRectangle = record
    x, y: cshort;
    Width, Height: cushort;
  end;

  PXCharStruct = ^TXCharStruct;

  TXCharStruct = record
    lbearing: cshort;
    rbearing: cshort;
    Width: cshort;
    ascent: cshort;
    descent: cshort;
    attributes: cushort;
  end;
  
  // Corrected: Renamed XKeyEvent to TXKeyEvent to match PXKeyEvent = ^TXKeyEvent
  TXKeyEvent = packed record
    event_type: CInt; // type
    serial: CULong;
    send_event: CInt; // Bool in C
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: CULong;
    x, y: CInt;
    x_root, y_root: CInt;
    state: CUInt;
    keycode: CUInt;
    same_screen: CInt; // Bool in C
  end;
  PXKeyEvent = ^TXKeyEvent; // Corrected type to ^TXKeyEvent

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
 
  type
  PXIM = ^TXIM;
  TXIM = record
    connection: Pxcb_connection_t;
    // Opaque data for XIM
  end;
  XIM  = PXIM;
  
  PXIC = ^TXIC;
  TXIC = record
    im: PXIM;
    client_window: xcb_window_t;
    focus_window: xcb_window_t;
    input_style: clong;
    filter_events: clong;
  end;
  XIC  = PXIC;
  XIMStyle = clong;
  PXIMStyles = Pointer;

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

  PXICCEncodingStyle = ^TXICCEncodingStyle;
  TXICCEncodingStyle = (XStringStyle, XCompoundTextStyle, XTextStyle,
    XStdICCTextStyle, XUTF8StringStyle);

  PXTextProperty = ^TXTextProperty;

  TXTextProperty = record
    Value: pcuchar;
    encoding: TAtom;
    format: cint;
    nitems: culong;
  end;

  PXAnyEvent = ^TXAnyEvent;
  TXAnyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
  end;
  
  mXAnyEvent = packed record
    event_type: CInt; // type
    serial: CULong;
    send_event: CInt; // Bool in C
    display: PDisplay;
    window: tWindow;
  end;
  PmXAnyEvent = ^mXAnyEvent;
  
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
  
  Pxcb_client_message_event_t = ^Txcb_client_message_event_t;
  Txcb_client_message_event_t = packed record
    // Byte offsets:
    response_type: Byte;   // Offset 0 (1 byte)
    format: Byte;          // Offset 1 (1 byte)
    sequence: Word;        // Offset 2 (2 bytes)
    window: Cardinal;      // Offset 4 (4 bytes) - The window ID
    type_: Cardinal;       // Offset 8 (4 bytes) - CRITICAL: This is the message_type atom
    // Data union starts at Offset 12 (20 bytes total)
    Data: record
      case Integer of
        0: (data8: array[0..19] of Byte);
        1: (data16: array[0..9] of Word);
        2: (data32: array[0..4] of Cardinal); // 5 Cardinal * 4 bytes = 20 bytes
    end;
  end;


  xcb_client_message_event_t = Txcb_client_message_event_t;
  
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
  
  {
  TXClientMessageEvent = record
    response_type: cint;
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
}


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

  PXKeymapEvent = ^TXKeymapEvent;

  TXKeymapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    key_vector: array[0..31] of cchar;
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

{
PXEvent = ^TXEvent;
  TXEvent = packed record
    case longint of // Anonymous tag field for the union variants
      0: (_type: cint); // _type is here, as part of a variant record's anonymous variant
      1: (xany: TXAnyEvent);
      2: (xkey: TXKeyEvent);
      // Add other MSEgui event types here as needed, following their definition
      // For example, if you have TXButtonEvent, it would be:
      // 3: (xbutton: TXButtonEvent);
      // ...
      28: (xclient: TXClientMessageEvent); // This must match the index in MSEgui
      // ...
      7: (xexpose: TXExposeEvent); // This must match the index in MSEgui
      // ...
      34: (pad: array[0..23] of clong); // Padding to ensure correct size
  end;
}



{
 // MSEgui's main XEvent union (MUST BE PACKED RECORD)
  // CRITICAL CHANGE: _type, serial, send_event, display, window are now DIRECT fields of TXEvent.
  PXEvent = ^TXEvent;
  TXEvent = packed record
    // These are the common fields for ALL X events, now at the top level.
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow; // This 'window' field is the common window ID for the event

    // The rest of the record is a variant part (union) that overlays the memory
    // immediately following the common fields.
    case longint of // Anonymous tag field for the union variants
      // We use a single variant (0) to contain all the specific event structures.
      0: (
        // These are the *variants* that will overlay the same memory space.
        // Their definitions (TXAnyEvent, TXKeyEvent, etc.) MUST now exclude
        // the common header fields (like _type, serial, etc.)
        xany: TXAnyEvent; // This TXAnyEvent is now a stripped-down version
        xkey: TXKeyEvent; // This TXKeyEvent is now a stripped-down version
        xbutton: TXButtonEvent; // Assuming this exists and is stripped down
        xmotion: TXMotionEvent; // Assuming this exists and is stripped down
        xcrossing: TXCrossingEvent; // Assuming this exists and is stripped down
        xfocus: TXFocusChangeEvent; // Assuming this exists and is stripped down
        xexpose: TXExposeEvent; // This TXExposeEvent is now a stripped-down version
        xgraphicsexpose: TXGraphicsExposeEvent; // Assuming this exists and is stripped down
        xnoexpose: TXNoExposeEvent; // Assuming this exists and is stripped down
        xvisibility: TXVisibilityEvent; // Assuming this exists and is stripped down
        xcreatewindow: TXCreateWindowEvent; // Assuming this exists and is stripped down
        xdestroywindow: TXDestroyWindowEvent; // Assuming this exists and is stripped down
        xunmap: TXUnmapEvent; // Assuming this exists and is stripped down
        xmap: TXMapEvent; // Assuming this exists and is stripped down
        xmaprequest: TXMapRequestEvent; // Assuming this exists and is stripped down
        xreparent: TXReparentEvent; // Assuming this exists and is stripped down
        xconfigure: TXConfigureEvent; // Assuming this exists and is stripped down
        xgravity: TXGravityEvent; // Assuming this exists and is stripped down
        xresizerequest: TXResizeRequestEvent; // Assuming this exists and is stripped down
        xconfigurerequest: TXConfigureRequestEvent; // Assuming this exists and is stripped down
        xcirculate: TXCirculateEvent; // Assuming this exists and is stripped down
        xcirculaterequest: TXCirculateRequestEvent; // Assuming this exists and is stripped down
        xproperty: TXPropertyEvent; // Assuming this exists and is stripped down
        xselectionclear: TXSelectionClearEvent; // Assuming this exists and is stripped down
        xselectionrequest: TXSelectionRequestEvent; // Assuming this exists and is stripped down
        xselection: TXSelectionEvent; // Assuming this exists and is stripped down
        xcolormap: TXColormapEvent; // Assuming this exists and is stripped down
        xclient: TXClientMessageEvent; // This TXClientMessageEvent is now a stripped-down version
        xmapping: TXMappingEvent; // Assuming this exists and is stripped down
        xerror: TXErrorEvent; // Assuming this exists and is stripped down
        xkeymap: TXKeymapEvent; // Assuming this exists and is stripped down
        xgeneric: TXGenericEvent; // Assuming this exists and is stripped down
        xcookie: TXGenericEventCookie; // Assuming this exists and is stripped down
        // Padding to ensure correct total size (adjust if needed to match Xlib's XEvent size)
        pad: array[0..23] of clong; // This padding is for the overall TXEvent size
      );
  end;
}


  PXSegment = ^TXSegment;

  TXSegment = record
    x1, y1, x2, y2: cshort;
  end;

  PXDisplay = ^TXDisplay;
  TXDisplay = record
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
    display: Pxcb_connection_t;
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
  
   xcb_setup_roots_iterator_t = record
    data: Pxcb_screen_t;
    rem: cint;
    index: cint;
  end;
  
    Pxcb_visualtype_t = ^xcb_visualtype_t;
    xcb_visualtype_t = record
    visual_id: xcb_visualid_t;
    _class: cuint8;
    bits_per_rgb_value: cuint8;
    colormap_entries: cuint16;
    red_mask: cuint32;
    green_mask: cuint32;
    blue_mask: cuint32;
    pad0: array[0..3] of cuint8;
  end;
  
   Pxcb_depth_t = ^xcb_depth_t;
  xcb_depth_t = record
    depth: cuint8;
    pad0: cuint8;
    visuals_len: cuint16;
    pad1: array[0..3] of cuint8;
  end;

  Pxcb_depth_iterator_t = ^xcb_depth_iterator_t;
  xcb_depth_iterator_t = record
    data: Pxcb_depth_t;
    rem: cint;
    index: cint;
  end;

  Pxcb_visualtype_iterator_t = ^xcb_visualtype_iterator_t;
  xcb_visualtype_iterator_t = record
    data: Pxcb_visualtype_t;
    rem: cint;
    index: cint;
  end;

  XID = type culong;

  PScreenFormat = ^TScreenFormat;
  TScreenFormat = record
    ext_data: PXExtData;
    depth: cint;
    bits_per_pixel: cint;
    scanline_pad: cint;
  end;

  PXPrivate = ^TXPrivate;
  TXPrivate = record
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

  PXWindowChanges = ^TXWindowChanges;

  TXWindowChanges = record
    x, y: cint;
    Width, Height: cint;
    border_width: cint;
    sibling: TWindow;
    stack_mode: cint;
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

  PKeyCode = ^TKeyCode;
  TKeyCode = cuchar;

  // XRandR types for mxrandr.pas
  Rotation = cushort;
  SizeID   = cushort;

  XRRScreenSize = record
    Width, Height: cint;
    mwidth, mheight: cint;
  end;
  PXRRScreenSize = ^XRRScreenSize;
  
  XRRCrtcInfo = record
    timestamp: culong;
    x, y: cint; // Fixed: Removed "Shel x"
    Width, Height: cuint;
    rotation: Rotation;
    rotations: Rotation;
    mode: RRMode;
    outputs: Pculong;
    noutput: cint;
  end;
  PXRRCrtcInfo = ^XRRCrtcInfo;

  Connection    = cushort;
  SubpixelOrder = cushort;

  XRROutputInfo = record
    timestamp: Time;
    crtc: RRCrtc;
    Name: pcchar;
    nameLen: cint;
    mm_width: culong;
    mm_height: culong;
    connection: Connection;
    subpixel_order: SubpixelOrder;
    ncrtc: cint;
    crtcs: pRRCrtc;
    nclone: cint;
    clones: pRROutput;
    nmode: cint;
    npreferred: cint;
    modes: pRRMode;
  end;
  
  MXEvent = record
    data: array[0..191] of Byte; // Max size of XEvent union on 64-bit systems
  end;
  PMXEvent = ^MXEvent;
  
  pXRROutputInfo = ^XRROutputInfo;
  
  TXErrorHandler = function(display: PDisplay; error_event: PXErrorEvent): cint; cdecl;
  
  xcb_connection_t = Pointer; 

  
const
  MWM_HINTS_DECORATIONS = 1 shl 1;
  WindowGroupHint = 1 shl 6;
  KeyPressMask  = 1 shl 0;
  ExposureMask  = 1 shl 15;
  KeyPress      = 2;
  Expose        = 12;
  ClientMessage = 33;
  XCB_IMAGE_FORMAT_XY_BITMAP = 1;
  XCB_IMAGE_FORMAT_XY_PIXMAP = 2;
  XCB_IMAGE_FORMAT_Z_PIXMAP = 2;
  XCB_KEY_PRESS = 2;
  XCB_KEY_RELEASE = 3;
  XCB_EXPOSE    = 12;
  XCB_NONE = 0;
  XCB_EVENT_MASK_KEY_PRESS = 1 shl 0;   // $00000001
  XCB_EVENT_MASK_KEY_RELEASE = 1 shl 1; // $00000002
  InputOnly     = 2;
  InputOutput   = 1;
  CopyFromParent = 0;
  CWBackPixel   = 1 shl 1;
  CWEventMask   = 1 shl 11;
  CWColormap    = 1 shl 13;
  GCForeground  = 1 shl 2;
  GCBackground  = 1 shl 3;
  GCFont        = 1 shl 14;
  XA_STRING     = 31;
  XA_WM_HINTS   = 35;
  None          = 0;
  PropModeReplace = 0;
  ShapeBounding = 0;
  ShapeClip     = 1;
  ShapeSet      = 0;
  ZPixmap       = 2;
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
  Button1       = 1;
  Button2       = 2;
  Button3       = 3;
  Button4       = 4;
  Button5       = 5;
  CWBackPixmap = $00000001;
  CWBorderPixmap = $00000004;
  CWBorderPixel = $00000008;
  CWBackingStore = $00000040;
  CWBackingPlanes = $00000080;
  CWBackingPixel = $00000100;
  CWSaveUnder = $00000400;
  CWDontPropagate = $00001000;
  CWCursor = $00004000;
  g_xcb_conn: xcb_connection_t = nil;
  g_default_screen: Pxcb_screen_t = nil;
  g_default_screen_num: CInt = -1; // -1 indicates not yet initialized
 
  //* Event selection bits */
  RRScreenChangeNotifyMask = 1 shl 0;
  ///* V1.2 additions */
  RRCrtcChangeNotifyMask = 1 shl 1;
  RROutputChangeNotifyMask = 1 shl 2;
  RROutputPropertyNotifyMask = 1 shl 3;
  //* V1.4 additions */
  RRProviderChangeNotifyMask = 1 shl 4;
  RRProviderPropertyNotifyMask = 1 shl 5;
  RRResourceChangeNotifyMask = 1 shl 6;

  //* Event codes */
  RRScreenChangeNotify = 0;
  //* V1.2 additions */
  RRNotify      = 1;
  //* RRNotify Subcodes */
  RRNotify_CrtcChange = 0;
  RRNotify_OutputChange = 0;
  RRNotify_OutputProperty = 2;
  RRNotify_ProviderChange = 3;
  RRNotify_ProviderProperty = 4;
  RRNotify_ResourceChange = 5;
  rrlastnotify  = RRNotify + 5;

  //* used in the rotation field; rotation and reflection in 0.1 proto. */
  RR_Rotate_0   = 1;
  RR_Rotate_90  = 2;
  RR_Rotate_180 = 4;
  RR_Rotate_270 = 8;

  //* new in 1.0 protocol, to allow reflection of screen */
  RR_Reflect_X  = 16;
  RR_Reflect_Y  = 32;

  XNFocusWindow = 'focusWindow';
  XNFilterEvents = 'filterEvents';
  XNResetState  = 'resetState';
  XNInputStyle  = 'inputStyle';
  XNClientWindow = 'clientWindow';
  XNDestroyCallback = 'destroyCallback';
  XNIMPreeditState = 'preeditState';
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

  // Event Masks (bitmasks for xcb_create_window value_mask)
  XCB_EVENT_MASK_EXPOSURE = (1 shl 15);

  // Window Class
  XCB_WINDOW_CLASS_INPUT_OUTPUT = 1;
  
  XCB_PROP_MODE_REPLACE = 0;
  
  SizeOf_Txcb_client_message_event_t = SizeOf(Txcb_client_message_event_t);

var
  GlobalXCBConnection: PDisplay;
  global_error_handler: TXErrorHandler = nil;
  g_screen: TScreen; // Global to store screen data
  g_randreventbase: cint = 0;
  g_randrerrorbase: cint = 0;
  //g_errorhandler: XErrorHandler = nil;
  g_errorhandler: pointer = nil;
  g_root_visual: Visual;
  g_event_queue: TList = nil;
  // Global Atoms for WM_PROTOCOLS and WM_DELETE_WINDOW
  g_wm_protocols_atom: Atom = 0;
  g_wm_delete_window_atom: Atom = 0;
  wm_delete_window_atom: Atom = 0;
  mse_client_message_atom: Atom = 0;
  wm_protocols_atom: Atom = 0;
  current_event_handled_as_close: Boolean = False;



function XOpenDisplay(display_name: PChar): PDisplay; cdecl;
procedure XCloseDisplay(display: PDisplay); cdecl;
function XDefaultScreen(display: PDisplay): cint; cdecl;
function XDefaultVisual(display: PDisplay; screen_number: cint): PVisual; cdecl;

function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; Width, Height, 
          border_width: cuint; depth: cint; window_class: cuint; visual: PVisual;
           valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl;

procedure XMapWindow(display: PDisplay; w: Window); cdecl;
function XSelectInput(para1: PDisplay; para2: TWindow; para3: LongInt): LongInt; cdecl;
//procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl;

//function XNextEvent(display: PDisplay; event_return: PXEvent): CInt; cdecl;

function XNextEvent(display: PDisplay; event_return: PmXEvent): CInt; cdecl;

function XPending(display: PDisplay): cint; cdecl;
function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;

function XInternAtoms(dpy: PDisplay; names: PPChar; n: cint; only_if_exists: tbool; atoms_return: PAtom): TStatus; cdecl;

function XGetWindowProperty(display: PDisplay; w: Window; atom_property: Atom; long_offset, long_length: culong; 
         Delete: TBool; req_type: Atom;  actual_type_return: PAtom; actual_format_return: Pcint;
          nitems_return: Pculong; bytes_after_return: Pculong; prop_return: PPcuchar): cint; cdecl;
          
function XSendEvent(display: PDisplay; w: Window; propagate: TBool; event_mask: clong; event_send: PXEvent): cint; cdecl;
function XChangeProperty(display: PDisplay; w: Window; atom_property: Atom; type_: Atom; format: cint; mode: cint; Data: Pcuchar; nelements: cint): cint; cdecl;
procedure XFlush(display: PDisplay); cdecl;
function XGetAtomName(display: PDisplay; atom: Atom): PChar; cdecl;
function XSetWMHints(display: PDisplay; w: Window; wmhints: PXWMHints): cint; cdecl;
procedure XFree(Data: Pointer); cdecl;
function XCreateGC(display: PDisplay; d: Drawable; valuemask: culong; values: PXGCValues): GC; cdecl;
procedure XFreeGC(display: PDisplay; gc: GC); cdecl;
procedure XSetForeground(display: PDisplay; gc: GC; foreground: culong); cdecl;
procedure XDrawLine(display: PDisplay; d: Drawable; gc: GC; x1, y1, x2, y2: cint); cdecl;
function XLoadQueryFont(display: PDisplay; Name: PChar): PXFontStruct; cdecl;
procedure XFreeFont(display: PDisplay; font_struct: PXFontStruct); cdecl;
procedure XDrawString(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PChar; length: cint); cdecl;
procedure XDrawString16(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PXChar2b; length: cint); cdecl;
procedure XPutImage(display: PDisplay; d: Drawable; gc: GC; image: PXImage; src_x, src_y: cint; dest_x, dest_y: cint; Width, Height: cuint32); cdecl;
function XLookupString(event_struct: PXKeyPressedEvent; buffer_return: PChar; bytes_buffer: cint; keysym_return: Pculong; status_in_out: Pointer): cint; cdecl;
function XCreateColormap(display: PDisplay; w: Window; visual: PVisual; alloc: cint): TColormap; cdecl;
procedure XFreeColormap(display: PDisplay; cmap: TColormap); cdecl;
function XCreatePixmap(display: PDisplay; d: Drawable; Width, Height, depth: cuint): TPixmap; cdecl;

// from XRender
function XRenderCreatePicture(display: PDisplay; d: Drawable; format: PXRenderPictFormat; valuemask: culong; attributes: Pointer): TPicture; cdecl;
procedure XRenderFreePicture(display: PDisplay; picture: TPicture); cdecl;
procedure XRenderComposite(display: PDisplay; op: cint; src: TPicture; mask: TPicture; dst: TPicture; src_x, src_y, mask_x, mask_y, dst_x, dst_y: cint; Width, Height: cuint); cdecl;

procedure XRenderSetPictureClipRectangles(dpy:PDisplay; picture:TPicture;
            xOrigin:longint; yOrigin:longint; rects:PXRectangle; n:longint); cdecl;
procedure XRenderSetPictureClipRegion(dpy: pDisplay; picture: TPicture; r: regionty); cdecl;
procedure XRenderFillRectangle(dpy: PDisplay; op: longint; dst: TPicture; color: PXRenderColor; x: longint;
                           y: longint; width: dword; height: dword);cdecl;
procedure XRenderSetPictureTransform(dpy:PDisplay; picture:TPicture; transform:PXTransform); cdecl;
procedure XRenderSetPictureFilter(dpy:PDisplay; picture:TPicture; filter: pchar; params: pinteger; nparams: integer); cdecl;
function XRenderCreateSolidFill(dpy: pDisplay; color: pXRenderColor): TPicture; cdecl;
function XRenderQueryExtension(dpy: PDisplay; event_basep: Pinteger; error_basep: Pinteger): TBool;cdecl;
function XRenderFindVisualFormat(dpy: PDisplay; visual: PVisual): PXRenderPictFormat;cdecl;
function XRenderFindStandardFormat(dpy: PDisplay; format: longint): PXRenderPictFormat; cdecl;
function XRenderFindFormat(dpy: PDisplay; mask: culong; templ: PXRenderPictFormat; count: longint): PXRenderPictFormat; cdecl;
procedure XRenderCompositeTriangles(dpy: pDisplay; op: cint; src: tPicture; dst: tPicture; maskFormat: pXRenderPictFormat;
                  xSrc: cint; ySrc: cint; triangles: pXTriangle; ntriangle: cint); cdecl;
procedure XRenderCompositeTriStrip(dpy: pdisplay; op: cint; src: tpicture; dst: tpicture; maskFormat: PXRenderPictFormat;
               xSrc: cint; ySrc: cint; points: PXPointFixed; npoint: cint); cdecl;
procedure XRenderCompositeTriFan(dpy: pdisplay; op: cint; src: tpicture; dst: tpicture; maskFormat: PXRenderPictFormat;
               xSrc: cint; ySrc: cint; points: PXPointFixed; npoint: cint); cdecl;
procedure XRenderChangePicture(dpy: pdisplay; picture: tpicture; valuemask: culong; attributes: PXRenderPictureAttributes); cdecl;

// Shape extension for mshape.pas
function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBool; cdecl;
function XShapeCombineRegion(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; region: TRegion; op: cint): TStatus; cdecl;
procedure XShapeCombineRectangles(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; rectangles: PXRectangle; n_rects: cint; op: cint; ordering: cint); cdecl;
procedure XShapeCombineMask(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; mask: TPixmap; op: cint); cdecl;

// Todo from libX11
function XwcTextListToTextProperty(para1: PDisplay; para2: PPWideChar; para3: cint; para4: TXICCEncodingStyle; para5: PXTextProperty): cint; cdecl;
function XSetSelectionOwner(para1: PDisplay; para2: TAtom; para3: TWindow; para4: TTime): cint; cdecl;
function XDeleteProperty(para1: PDisplay; para2: TWindow; para3: TAtom): cint; cdecl;
function XCheckTypedEvent(para1: PDisplay; para2: cint; para3: PXEvent): TBoolResult; cdecl;
function XConvertSelection(para1: PDisplay; para2: TAtom; para3: TAtom; para4: TAtom; para5: TWindow; para6: TTime): cint; cdecl;
function XGetSelectionOwner(para1: PDisplay; para2: TAtom): TWindow; cdecl;
procedure XFreeStringList(para1: PPchar); cdecl;
function XGetWindowAttributes(display: PDisplay; w: TWindow; window_attributes: PXWindowAttributes): LongInt; cdecl;
function XGetGeometry(display: PDisplay; d: TDrawable; root: PWindow; x, y: PLongInt; width, height, border_width, depth: PLongWord): LongInt; cdecl;
function XSync(para1: PDisplay; para2: TBool): cint; cdecl;
function XIconifyWindow(para1: PDisplay; para2: TWindow; para3: cint): TStatus; cdecl;
procedure XSetWMName(para1: PDisplay; para2: TWindow; para3: PXTextProperty); cdecl;
function XGetWMHints(para1: PDisplay; para2: TWindow): PXWMHints; cdecl;
function XAllocWMHints: PXWMHints; cdecl;
function XQueryTree(para1: PDisplay; para2: TWindow; para3: PWindow; para4: PWindow; para5: PPWindow; para6: Pcuint): TStatus; cdecl;
function XRaiseWindow(para1: PDisplay; para2: TWindow): cint; cdecl;
function XLowerWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
function XReconfigureWMWindow(para1: PDisplay; para2: TWindow; para3: cint; para4: cuint; para5: PXWindowChanges): TStatus; cdecl;
function XQueryPointer(para1: PDisplay; para2: TWindow; para3: PWindow; para4: PWindow; para5: Pcint; para6: Pcint; para7: Pcint; para8: Pcint; para9: Pcuint): TBoolResult; cdecl;
function XWarpPointer(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl;
function XUngrabPointer(para1: PDisplay; para2: TTime): cint; cdecl;
function XGrabPointer(para1: PDisplay; para2: TWindow; para3: TBool; para4: cuint; para5: cint; para6: cint; para7: TWindow; para8: TCursor; para9: TTime): cint; cdecl;
function XGetImage(para1: PDisplay; para2: TDrawable; para3: cint; para4: cint; para5: cuint; para6: cuint; para7: culong; para8: cint): PXImage; cdecl;
function XSetGraphicsExposures(para1: PDisplay; para2: TGC; para3: TBool): cint; cdecl;
function XCopyArea(display: PDisplay; src, dest: TDrawable; gc: TGC; src_x, src_y, width, height: LongInt; dest_x, dest_y: LongInt): LongInt; cdecl;
function XFreePixmap(para1: PDisplay; para2: TPixmap): cint; cdecl;
function XGetTransientForHint(para1: PDisplay; para2: TWindow; para3: PWindow): TStatus; cdecl;
function XSetInputFocus(para1: PDisplay; para2: TWindow; para3: cint; para4: TTime): cint; cdecl;
function XCreateBitmapFromData(ADiplay: PDisplay; ADrawable: TDrawable; AData: PChar; AWidth: cuint; AHeight: cuint): TPixmap; cdecl;
function XCreateFontCursor(ADisplay: PDisplay; AShape: cuint): TCursor; cdecl;
function XDefineCursor(ADisplay: PDisplay; AWindow: TWindow; ACursor: TCursor): cint; cdecl;
function XFreeCursor(ADisplay: PDisplay; ACursor: TCursor): cint; cdecl;
function XSetTransientForHint(ADisplay: PDisplay; AWindow: TWindow; APropWindow: TWindow): cint; cdecl;
function XTranslateCoordinates(ADisplay: PDisplay; ASrcWindow: TWindow; ADestWindow: TWindow; ASrcX: cint; ASrcY: cint; ADestXReturn: Pcint; ADestYReturn: Pcint; AChildReturn: PWindow): TBool; cdecl;
function XDrawRectangle(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint): cint; cdecl;
function XFreeColormap(para1: PDisplay; para2: TColormap): cint; cdecl;
function XCreatePixmapCursor(ADisplay: PDisplay; ASource: TPixmap; AMask: TPixmap; AForegroundColor: PXColor; ABackgroundColor: PXColor; AX: cuint; AY: cuint): TCursor; cdecl;
function XFillRectangle(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint): cint; cdecl;
function XFillArc(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl;
function XDrawArc(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl;
function XSetWMProtocols(display: PDisplay; w: TWindow; protocols: PAtom; count: cint): LongInt; cdecl;
function XDestroyWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
function XAllocSizeHints: PXSizeHints; cdecl;
function XGetWMNormalHints(display: PDisplay; w: TWindow; hints_return: PXSizeHints; supplied_return: PLongInt): LongInt; cdecl;
function XSetWMNormalHints(display: PDisplay; w: TWindow; hints: PXSizeHints): LongInt; cdecl;
function XConfigureWindow(display: PDisplay; w: TWindow; value_mask: LongWord; values: Pointer): LongInt; cdecl;
function XUnmapWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
function XReparentWindow(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint): cint; cdecl;
function XBell(para1: PDisplay; para2: cint): cint; cdecl;
function XScreenNumberOfScreen(para1: PScreen): cint; cdecl;
function XCheckTypedWindowEvent(para1: PDisplay; para2: TWindow; para3: cint; para4: PXEvent): TBoolResult; cdecl;
function XPeekEvent(ADisplay: PDisplay; AEvent: PXEvent): cint; cdecl;
function XFilterEvent(para1: PXEvent; para2: TWindow): TBoolResult; cdecl;
function XRefreshKeyboardMapping(para1: PXMappingEvent): cint; cdecl;
function XGetErrorText(para1: PDisplay; para2: cint; para3: PChar; para4: cint): cint; cdecl;

// function XCreateColormap(para1: PDisplay; para2: TWindow; para3: PVisual; para4: cint): TColormap; cdecl;

function XStoreColors(para1: PDisplay; para2: TColormap; para3: PXColor; para4: cint): cint; cdecl;
function XSupportsLocale: TBool; cdecl;
function XDefaultScreenOfDisplay(display: PDisplay): PScreen; cdecl;
function XRootWindowOfScreen(screen: PScreen): Window; cdecl;
function XDefaultVisualOfScreen(screen: PScreen): PVisual; cdecl;
function XDefaultDepthOfScreen(para1: PScreen): cint; cdecl;
function XDefaultColormapOfScreen(para1: PScreen): TColormap; cdecl;
function XKeysymToKeycode(display: PDisplay; keysym: TKeySym): TKeyCode; cdecl;
function XGetModifierMapping(display: PDisplay): PXModifierKeymap; cdecl;

function XFreeModifiermap(para1: PXModifierKeymap): cint; cdecl;
function XConnectionNumber(display: PDisplay): cint; cdecl;
function XSetErrorHandler(para1: TXErrorHandler): TXErrorHandler; cdecl;
function XSetClipRectangles(para1: PDisplay; para2: TGC; para3: cint; para4: cint; para5: PXRectangle; para6: cint; para7: cint): cint; cdecl;
function XSetDashes(para1: PDisplay; para2: TGC; para3: cint; para4: PChar; para5: cint): cint; cdecl;
function XChangeGC(display: PDisplay; gc: TGC; valuemask: LongWord; values: Pointer): LongInt; cdecl;
function XSetClipMask(para1: PDisplay; para2: TGC; para3: TPixmap): cint; cdecl;
function XFreeFontInfo(para1: PPchar; para2: PXFontStruct; para3: cint): cint; cdecl;
function XUnloadFont(para1: PDisplay; para2: TFont): cint; cdecl;
function XSetFunction(para1: PDisplay; para2: TGC; para3: cint): cint; cdecl;
function XCopyPlane(para1: PDisplay; para2: TDrawable; para3: TDrawable; para4: TGC; para5: cint; para6: cint; para7: cuint; para8: cuint; para9: cint; para10: cint; para11: culong): cint; cdecl;
function XCopyGC(para1: PDisplay; para2: TGC; para3: culong; para4: TGC): cint; cdecl;
function XDrawLines(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXPoint; para5: cint; para6: cint): cint; cdecl;
function XDrawSegments(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXSegment; para5: cint): cint; cdecl;
function XSetClipOrigin(para1: PDisplay; para2: TGC; para3: cint; para4: cint): cint; cdecl;
function XFillPolygon(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXPoint; para5: cint; para6: cint; para7: cint): cint; cdecl;
function XCreateRegion: TRegion; cdecl;
function XUnionRectWithRegion(para1: PXRectangle; para2: TRegion; para3: TRegion): cint; cdecl;
function XDestroyRegion(para1: TRegion): cint; cdecl;
function XEmptyRegion(para1: TRegion): cint; cdecl;
function XClipBox(para1: TRegion; para2: PXRectangle): cint; cdecl;
function XUnionRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl;
function XOffsetRegion(para1: TRegion; para2: cint; para3: cint): cint; cdecl;
function XSubtractRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl;
function XIntersectRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl;

function XCreateImage(Display: PDisplay; Visual: msePVisual; Depth: longword;
  Format: Longint; Offset: Longint; Data: PChar; Width, Height: longword;
  bitmap_pad: Longint; bytes_per_line: Longint): PXImage; cdecl;

// Todo from libX11 and mseguiintf
//function XSetWMHints(Display: PDisplay; W: xid; WMHints: PXWMHints): cint; cdecl;
function XSetForeground(Display: PDisplay; GC: TGC; Foreground: culong): cint; cdecl;
procedure XDrawImageString(Display: PDisplay; D: TDrawable; GC: TGC; X, Y: integer; S: PChar; Len: integer); cdecl;
procedure XDrawImageString16(Display: PDisplay; D: TDrawable; GC: TGC; X, Y: integer; S: Pxchar2b; Len: integer); cdecl;
function XOpenIM(Display: PDisplay; rdb: PXrmHashBucketRec; res_name: PChar; res_class: PChar): XIM; cdecl;
function XCloseIM(IM: XIM): TStatus; cdecl;
function XCreateIC(IM: XIM; inputstyle: PChar; status: longint; pt: Pointer): XIC; cdecl;
procedure XDestroyIC(IC: XIC); cdecl;
function XSetLocaleModifiers(modifier_list: PChar): PChar; cdecl;

function XSetICValues(IC: XIC; focusw: PChar; id: longint; pnt: Pointer): PChar; cdecl;
function XSetICValues(IC: XIC; nreset: PChar; impreserv: PChar; pnt: Pointer): PChar; cdecl;
function XSetIMValues(IC: XIM; destroycb: PChar; ximcb: Pointer; pt: Pointer): PChar; cdecl;
function XGetICValues(IC: XIC; filterev: PChar; icmask: Pointer; pnt: Pointer): PChar; cdecl;

procedure XSetICFocus(IC: XIC); cdecl;
procedure XUnsetICFocus(IC: XIC); cdecl;
function Xutf8LookupString(IC: XIC; Event: PXKeyPressedEvent; BufferReturn: PChar; CharsBuffer: longint; KeySymReturn: PKeySym; StatusReturn: PStatus): longint; cdecl;
function Xutf8TextListToTextProperty(para1: PDisplay; para2: PPchar; para3: integer; para4: integer{TXICCEncodingStyle}; para5: PXTextProperty): integer; cdecl;
function Xutf8TextPropertyToTextList(para1: PDisplay; para2: PXTextProperty; para3: PPPchar; para4: pinteger): integer; cdecl;

// Todo from libXrandr
function XRRQueryExtension(dpy: pDisplay; event_base_return: pcint; error_base_return: pcint): tBool; cdecl;
function XRRGetScreenResources(dpy: pDisplay; window: Window): pXRRScreenResources; cdecl;
procedure XRRFreeScreenResources(resources: pXRRScreenResources); cdecl;
function XRRGetCrtcInfo(dpy: pDisplay; resources: pXRRScreenResources; crtc: RRCrtc): pXRRCrtcInfo; cdecl;
procedure XRRFreeCrtcInfo(crtcInfo: pXRRCrtcInfo); cdecl;
function XRRGetOutputInfo(dpy: pDisplay; resources: pXRRScreenResources; output: RROutput): pXRROutputInfo; cdecl;
procedure XRRFreeOutputInfo(outputInfo: pXRROutputInfo); cdecl;
procedure XRRSelectInput(dpy: pDisplay; window: Window; mask: cint); cdecl;
function XRRUpdateConfiguration(event: pXEvent): cint; cdecl;

// Macros
function WhitePixel(dpy: PDisplay; scr: cint): culong;
function DefaultScreen(dpy: PDisplay): cint;
function XSync(para1: PDisplay; para2: Boolean): cint;
function XSendEvent(para1: PDisplay; para2: TWindow; para3: Boolean; para4: clong; para5: PXEvent): TStatus;
function DefaultDepthOfScreen(s: PScreen): cint;
function XDestroyImage(ximage: PXImage): cint; cdecl;
function getxrandrlib: Boolean;

function XImage_create_image(para1: PDisplay; para2: PVisual; para3: CUInt; para4: CInt; para5: CInt; para6: PChar; para7: CUInt; para8: CUInt; para9: CInt; para10: CInt): PXImage; cdecl;
function XImage_destroy_image(para1: PXImage): CInt; cdecl;
function XImage_get_pixel(para1: PXImage; para2: CInt; para3: CInt): CULong; cdecl;
function XImage_put_pixel(para1: PXImage; para2: CInt; para3: CInt; para4: CULong): CInt; cdecl;
function XImage_sub_image(para1: PXImage; para2: CInt; para3: CInt; para4: CUInt; para5: CUInt): PXImage; cdecl;
function XImage_add_pixel(para1: PXImage; para2: CLong): CInt; cdecl;

function XGetXCBConnection(display: PDisplay): xcb_connection_t;

function CalculateBitsPerPixel(AFormat: CInt; ADepth: CInt): CInt;
function CalculateBytesPerLine(AWidth: CUInt; ABitsPerPixel: CInt; ABitmapPad: CInt): CInt;

implementation

uses
  SysUtils;

// XCB-specific types
type
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
  
  xcb_generic_event_t = packed record
    response_type: Byte;
    extension: Byte;
    sequence: Word;
    length: LongWord;
    event_type: Word;
    pad0: array[0..21] of Byte;  // 22 bytes
    full_sequence: LongWord;
  end;
  pxcb_generic_event_t = ^xcb_generic_event_t;
  
  mxcb_generic_event_t = record
    response_type: CUChar;
    pad0: CUChar;
    sequence: CUShort;
    pad: array[0..6] of CUInt; // 7 elements (0 to 6) for 28 bytes, total 32 bytes for the event
  end;
  Pmxcb_generic_event_t = ^mxcb_generic_event_t;

  
  
  xcb_key_press_event_t = record
   {$ifdef use_xcb}
   _type: Byte;
   {$else}
   response_type: Byte;
   {$endif}
    detail: cuint8;
    sequence: cuint16;
    time: cuint32;
    root: xcb_window_t;
    event: xcb_window_t;
    child: xcb_window_t;
    root_x, root_y: cint16;
    event_x, event_y: cint16;
    state: cuint16;
    same_screen: cuint8;
    pad0: cuint8;
  end;
  pxcb_key_press_event_t = ^xcb_key_press_event_t;

  xcb_expose_event_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
     pad0: cuint8;
    sequence: cuint16;
    window: xcb_window_t;
    x, y: cuint16;
    Width, Height: cuint16;
    Count: cuint16;
  end;
  pxcb_expose_event_t = ^xcb_expose_event_t;

{
  xcb_client_message_event_t = record
    response_type: cuint8;
    format: cuint8;
    sequence: cuint16;
    window: xcb_window_t;
    type_: xcb_atom_t;
    Data: record
      case integer of
        0: (data8: array[0..19] of cuint8);
        1: (data16: array[0..9] of cuint16);
        2: (data32: array[0..4] of cuint32);
    end;
  end;
  pxcb_client_message_event_t = ^xcb_client_message_event_t;
 }
 
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


   xcb_query_font_reply_t = record
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    ascent: cint;
    descent: cint;
  end;

  xcb_shape_query_extension_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    present: cuint8;
    major_version, minor_version: cuint8;
    event_base, error_base: cuint8;
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

  // XRandR-specific types for mxrandr.pas
  xcb_randr_crtc_t = cuint32;
  xcb_randr_mode_t = cuint32;

  xcb_randr_screen_size_t = record
    Width, Height: cuint16;
    mwidth, mheight: cuint16;
  end;
  
   xcb_query_extension_cookie_t = record
    sequence: cuint;
  end;
  Pxcb_query_extension_cookie_t = ^xcb_query_extension_cookie_t;

  xcb_query_extension_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    present: cuint8;
    major_opcode: cuint8;
    first_event: cuint8;
    first_error: cuint8;
  end;
  Pxcb_query_extension_reply_t = ^xcb_query_extension_reply_t;

  
  xcb_screen_iterator_t = record
    data: Pxcb_screen_t;
    rem: cint;
    index: cint;
  end;
  Pxcb_screen_iterator_t = ^xcb_screen_iterator_t;
    
   xcb_get_atom_name_cookie_t = record
    sequence: cunsigned;
  end;
  
  xcb_get_atom_name_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    name_len: cuint16;
    name: array[0..21] of cuint8;
  end;
  Pxcb_get_atom_name_reply_t = ^xcb_get_atom_name_reply_t;

  xcb_get_property_cookie_t = record
    sequence: cunsigned;
  end;
  
  Pxcb_get_property_cookie_t = ^xcb_get_property_cookie_t;
  
  Pxcb_key_symbols_t = ^xcb_key_symbols_t;
  xcb_key_symbols_t = record end; // Opaque structure
  Pxcb_keycode_t = ^xcb_keycode_t;
  xcb_keycode_t = cuchar; // Matches Xlib's KeyCode (unsigned char)
  KeySym = culong; // Matches Xlib's KeySym (unsigned long)
  KeyCode = cuchar; // Matches Xlib's KeyCode
 
  Pxcb_get_modifier_mapping_reply_t = ^xcb_get_modifier_mapping_reply_t;
  xcb_get_modifier_mapping_reply_t = record
   {$ifdef use_xcb}
   _type: cuint8;
   {$else}
   response_type: cuint8;
   {$endif}
    extension: cuint8;
    sequence: cuint16;
    length: cuint32;
    keycodes_per_modifier: cuint8;
    pad0: array[0..23] of cuint8; // Padding to match XCB structure
  end;
  
  xcb_get_modifier_mapping_cookie_t = record
    sequence: cuint;
  end;

 xcb_format_t = record
    depth: cuint8;
    bits_per_pixel: cuint8;
    scanline_pad: cuint8;
    pad0: array[0..4] of cuint8;
  end;
  Pxcb_format_t = ^xcb_format_t;
  xcb_create_pixmap_cookie_t = record
    sequence: cunsigned;
  end;
  xcb_create_gc_cookie_t = record
    sequence: cunsigned;
  end;
  xcb_copy_area_cookie_t = record
    sequence: cunsigned;
  end;
  xcb_put_image_cookie_t = record
    sequence: cunsigned;
  end;
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
  xcb_map_window_cookie_t = record
    sequence: cunsigned;
  end;
  
  xcb_ge_event_t = record
     response_type: CUChar; // 1 byte (offset 0) - Should be 0 for generic events
    detail: CUChar;        // 1 byte (offset 1)
    sequence: CUShort;     // 2 bytes (offset 2)
    length: CUInt;         // 4 bytes (offset 4)
    event_type: CUInt;     // 4 bytes (offset 8) - The actual event type for generic events
    event_extension: CUInt; // 4 bytes (offset 12)
    pad: array[0..3] of CUInt; // 4 * 4 bytes = 16 bytes (offset 16). Total size: 1+1+2+4+4+4+16 = 32 bytes.
  end;
  Pxcb_ge_event_t = ^xcb_ge_event_t;



procedure free(ptr: Pointer); cdecl; external 'libc.so';
 
// XCB function declarations
function xcb_poll_for_event(c: xcb_connection_t): Pxcb_generic_event_t; cdecl; external libxcb;
function xcb_create_pixmap(c: Pxcb_connection_t; depth: cuint8; pid: Pixmap; drawable: Drawable; width: cuint16; height: cuint16): xcb_create_pixmap_cookie_t; cdecl; external libxcb;
function xcb_create_pixmap_reply(c: Pxcb_connection_t; cookie: xcb_create_pixmap_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external libxcb;
function xcb_create_gc(c: Pxcb_connection_t; cid: GC; drawable: Drawable; value_mask: cuint32; value_list: Pointer): xcb_create_gc_cookie_t; cdecl; external libxcb;
function xcb_create_gc_reply(c: Pxcb_connection_t; cookie: xcb_create_gc_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external libxcb;
function xcb_copy_area(c: Pxcb_connection_t; src_drawable: Drawable; dst_drawable: Drawable; gc: GC; src_x: cint16; src_y: cint16; dst_x: cint16; dst_y: cint16; width: cuint16; height: cuint16): xcb_copy_area_cookie_t; cdecl; external libxcb;
function xcb_copy_area_reply(c: Pxcb_connection_t; cookie: xcb_copy_area_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external libxcb;
function xcb_put_image(c: Pxcb_connection_t; format: cuint8; drawable: Drawable; gc: GC; width: cuint16; height: cuint16; dst_x: cint16; dst_y: cint16; left_pad: cuint8; depth: cuint8; data_len: cuint32; data: PChar): xcb_put_image_cookie_t; cdecl; external libxcb;
function xcb_put_image_reply(c: Pxcb_connection_t; cookie: xcb_put_image_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external libxcb;
function xcb_get_geometry(c: Pxcb_connection_t; drawable: Drawable): xcb_get_geometry_cookie_t; cdecl; external libxcb;
function xcb_get_geometry_reply(c: Pxcb_connection_t; cookie: xcb_get_geometry_cookie_t; e: PPxcb_generic_error_t): Pxcb_get_geometry_reply_t; cdecl; external libxcb;
function xcb_get_window_attributes(c: Pxcb_connection_t; window: Window): xcb_get_window_attributes_cookie_t; cdecl; external libxcb;
function xcb_get_window_attributes_reply(c: Pxcb_connection_t; cookie: xcb_get_window_attributes_cookie_t; e: PPxcb_generic_error_t): Pxcb_get_window_attributes_reply_t; cdecl; external libxcb;
function xcb_map_window(c: Pxcb_connection_t; window: Window): xcb_map_window_cookie_t; cdecl; external libxcb;
function xcb_map_window_reply(c: Pxcb_connection_t; cookie: xcb_map_window_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external libxcb;
function xcb_free_pixmap(c: Pxcb_connection_t; pixmap: Pixmap): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_get_property_reply(c: Pxcb_connection_t; cookie: xcb_get_property_cookie_t; e: PPxcb_generic_error_t): Pxcb_get_property_reply_t; cdecl; external libxcb;
function xcb_get_property_value(reply: Pxcb_get_property_reply_t): Pointer; cdecl; external libxcb;
function xcb_get_file_descriptor(c: Pxcb_connection_t): cint; cdecl; external libxcb;
function xcb_get_modifier_mapping(c: Pxcb_connection_t): xcb_get_modifier_mapping_cookie_t; cdecl; external libxcb;
function xcb_get_modifier_mapping_reply(c: Pxcb_connection_t; cookie: xcb_get_modifier_mapping_cookie_t; e: PPxcb_generic_error_t): Pxcb_get_modifier_mapping_reply_t; cdecl; external libxcb;
function xcb_get_modifier_mapping_keycodes(reply: Pxcb_get_modifier_mapping_reply_t): PKeyCode; cdecl; external libxcb;
function xcb_key_symbols_alloc(c: Pxcb_connection_t): Pxcb_key_symbols_t; cdecl; external libxcb_keysyms;
function xcb_key_symbols_get_keycode(syms: Pxcb_key_symbols_t; keysym: KeySym): Pxcb_keycode_t; cdecl; external libxcb_keysyms;
procedure xcb_key_symbols_free(syms: Pxcb_key_symbols_t); cdecl; external libxcb_keysyms;  
function xcb_get_setup(c: Pxcb_connection_t): Pxcb_setup_t; cdecl; external libxcb;
function xcb_setup_roots_iterator(setup: Pxcb_setup_t): xcb_screen_iterator_t; cdecl; external libxcb;

// xcb_randr functions
function xcb_randr_query_version(c: Pxcb_connection_t; major_version, minor_version: cuint32): xcb_void_cookie_t; cdecl; external 'libxcb-randr';
function xcb_randr_query_version_reply(c: Pxcb_connection_t; cookie: xcb_void_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external 'libxcb-randr';

function xcb_query_extension(c: Pxcb_connection_t; name_len: cuint; name: PChar): xcb_query_extension_cookie_t; cdecl; external libxcb;
function xcb_query_extension_reply(c: Pxcb_connection_t; cookie: xcb_query_extension_cookie_t; e: PPxcb_generic_error_t): Pxcb_query_extension_reply_t; cdecl; external libxcb;
function xcb_generate_id(c: pxcb_connection_t): cuint32; cdecl; external libxcb;
function xcb_connect(displayname: PChar; screenp: Pcint): pxcb_connection_t; cdecl; external libxcb;
procedure xcb_disconnect(c: pxcb_connection_t); cdecl; external libxcb;
function xcb_setup_roots_iterator(setup: Pointer): xcb_setup_roots_iterator_t; cdecl; external libxcb;

function xcb_create_window(
  c: xcb_connection_t; depth: CUChar; wid: xcb_window_t; parent: xcb_window_t;
  x: CShort; y: CShort; width: CUShort; height: CUShort; border_width: CUShort;
  _class: CUShort; visual: CUInt; value_mask: CUInt; value_list: PCUInt
): xcb_void_cookie_t; cdecl; external libxcb;

function xcb_map_window(c: pxcb_connection_t; window: xcb_window_t): Pointer; cdecl; external libxcb;
function xcb_change_window_attributes(c: pxcb_connection_t; window: xcb_window_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_get_input_focus(c: pxcb_connection_t): Pointer; cdecl; external libxcb;
function xcb_get_input_focus_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): Pointer; cdecl; external libxcb;
function xcb_intern_atom(c: Pxcb_connection_t; only_if_exists: cuint8; name_len: cuint16; name: PChar): xcb_intern_atom_cookie_t; cdecl; external libxcb;
function xcb_intern_atom_reply(c: Pxcb_connection_t; cookie: xcb_intern_atom_cookie_t; e: PPxcb_generic_error_t): Pxcb_intern_atom_reply_t; cdecl; external libxcb;
function xcb_get_property(c: pxcb_connection_t; Delete: cuint8; window: xcb_window_t; prop: xcb_atom_t; type_: xcb_atom_t; offset, length: cuint32): xcb_get_property_cookie_t; cdecl; external libxcb;
function xcb_get_property_reply(c: pxcb_connection_t; cookie: xcb_get_property_cookie_t; e: Pointer): pxcb_get_property_reply_t; cdecl; external libxcb;

function xcb_change_property(c: pxcb_connection_t; mode: cuint8; window: xcb_window_t;
 prop: xcb_atom_t; type_: xcb_atom_t; format: cuint8; data_len: cuint32; Data: Pointer): xcb_void_cookie_t; cdecl; external libxcb;

function xcb_send_event(c: pxcb_connection_t; propagate: cuint8; destination: xcb_window_t; event_mask: cuint32; event: Pointer): Pointer; cdecl; external libxcb;
procedure xcb_flush(c: pxcb_connection_t); cdecl; external libxcb;
function xcb_get_atom_name(c: Pxcb_connection_t; atom: xcb_atom_t): xcb_get_atom_name_cookie_t; cdecl; external libxcb;function xcb_get_atom_name_reply(c: Pxcb_connection_t; cookie: xcb_get_atom_name_cookie_t; e: PPxcb_generic_error_t): Pxcb_get_atom_name_reply_t; cdecl; external libxcb;
function xcb_create_gc(c: pxcb_connection_t; cid: xcb_gcontext_t; drawable: xcb_drawable_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_free_gc(c: pxcb_connection_t; gc: xcb_gcontext_t): Pointer; cdecl; external libxcb;
function xcb_change_gc(c: pxcb_connection_t; gc: xcb_gcontext_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_poly_line(c: pxcb_connection_t; coordinate_mode: cuint8; drawable: xcb_drawable_t; gc: xcb_gcontext_t; points_len: cuint32; points: Pointer): Pointer; cdecl; external libxcb;
function xcb_open_font(c: pxcb_connection_t; fid: xcb_font_t; name_len: cuint32; Name: PChar): Pointer; cdecl; external libxcb;
function xcb_query_font(c: pxcb_connection_t; font: xcb_font_t): Pointer; cdecl; external libxcb;
function xcb_query_font_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_query_font_reply_t; cdecl; external libxcb;
function xcb_close_font(c: pxcb_connection_t; font: xcb_font_t): Pointer; cdecl; external libxcb;
function xcb_poly_text_8(c: pxcb_connection_t; drawable: xcb_drawable_t; gc: xcb_gcontext_t; x, y: cint16; items_len: cuint32; items: PChar): Pointer; cdecl; external libxcb;
function xcb_poly_text_16(c: pxcb_connection_t; drawable: xcb_drawable_t; gc: xcb_gcontext_t; x, y: cint16; items_len: cuint32; items: PXChar2b): Pointer; cdecl; external libxcb;
function xcb_put_image(c: pxcb_connection_t; format: cuint8; drawable: xcb_drawable_t; gc: xcb_gcontext_t; Width, Height: cuint16; dst_x, dst_y: cint16; left_pad: cuint8; depth: cuint8;
  data_len: cuint32; Data: PByte): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_request_check(c: Pxcb_connection_t; cookie: xcb_void_cookie_t): Pxcb_generic_error_t; cdecl; external libxcb;
function xcb_create_colormap(c: pxcb_connection_t; alloc: cuint8; mid: xcb_colormap_t; window: xcb_window_t; visual: xcb_visualid_t): Pointer; cdecl; external libxcb;
function xcb_free_colormap(c: pxcb_connection_t; cmap: xcb_colormap_t): Pointer; cdecl; external libxcb;
function xcb_create_pixmap(c: pxcb_connection_t; depth: cuint8; pid: xcb_pixmap_t; drawable: xcb_drawable_t; Width, Height: cuint16): Pointer; cdecl; external libxcb;
function xcb_render_create_picture(c: pxcb_connection_t; pid: xcb_render_picture_t; drawable: xcb_drawable_t; format: xcb_render_pictformat_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb_render;
function xcb_render_free_picture(c: pxcb_connection_t; picture: xcb_render_picture_t): Pointer; cdecl; external libxcb_render;
function xcb_render_composite(c: pxcb_connection_t; op: cuint8; src: xcb_render_picture_t; mask: xcb_render_picture_t; dst: xcb_render_picture_t; src_x, src_y, mask_x, mask_y, dst_x, dst_y: cint16;
  Width, Height: cuint16): Pointer; cdecl; external libxcb_render;
function xcb_shape_combine(c: pxcb_connection_t; operation: cuint8; destination_kind: cuint8; destination: xcb_window_t; x, y: cint16; Source: xcb_window_t; source_kind: cuint8): Pointer; cdecl; external libxcb_shape;
function xcb_shape_rectangles(c: pxcb_connection_t; operation: cuint8; destination_kind: cuint8; ordering: cuint8; destination: xcb_window_t; x, y: cint16; rectangles_len: cuint32; rectangles: PXRectangle): Pointer; cdecl; external libxcb_shape;
function xcb_shape_mask(c: pxcb_connection_t; operation: cuint8; destination_kind: cuint8; destination: xcb_window_t; x, y: cint16; mask: xcb_pixmap_t): Pointer; cdecl; external libxcb_shape;
function xcb_create_window_checked(c: Pxcb_connection_t; depth: cint; wid: xcb_window_t;
  parent: xcb_window_t; x, y: cint; width, height, border_width: cuint; _class: cuint;
  visual: xcb_visualid_t; value_mask: cuint32; value_list: Pcuint32): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_screen_allowed_depths_iterator(screen: Pxcb_screen_t): xcb_depth_iterator_t; cdecl; external libxcb;
function xcb_depth_visuals_iterator(depth: Pxcb_depth_t): xcb_visualtype_iterator_t; cdecl; external libxcb;
function xcb_visualtype_next(iterator: Pxcb_visualtype_iterator_t): Pxcb_visualtype_iterator_t; cdecl; external libxcb;
procedure xcb_depth_next(iterator: Pxcb_depth_iterator_t); cdecl; external libxcb;
procedure xcb_screen_next(iterator: Pxcb_screen_iterator_t); cdecl; external libxcb;
function xcb_get_atom_name_name(reply: Pxcb_get_atom_name_reply_t): PChar; cdecl; external libxcb;
// function xcb_wait_for_event(c: Pxcb_connection_t): Pxcb_generic_event_t; cdecl; external libxcb;
function xcb_wait_for_event(c: Pxcb_connection_t): Pxcb_generic_event_t; cdecl; external libxcb;
function xcb_configure_window(c: Pxcb_connection_t; window: xcb_window_t; value_mask: cuint16; 
         value_list: Pointer): xcb_void_cookie_t; cdecl; external libxcb;
function xcb_destroy_window(c: xcb_connection_t; window: xcb_window_t): xcb_void_cookie_t; cdecl; external libxcb;

         
         
// Implementation
function XOpenDisplay(display_name: PChar): PDisplay; cdecl;
begin
if g_event_queue = nil then
    g_event_queue := TList.Create;
  Result := xcb_connect(display_name, nil);
  g_xcb_conn := result;
end;

procedure XCloseDisplay(display: PDisplay); cdecl;
begin
  xcb_disconnect(display);
end;

function XDefaultScreen(display: PDisplay): cint; cdecl;
var
  setup: Pointer;
  iter: xcb_setup_roots_iterator_t;
begin
  setup  := xcb_get_setup(display);
  iter   := xcb_setup_roots_iterator(setup);
  Result := 0; // First screen
end;

function XDefaultVisual(display: PDisplay; screen_number: cint): PVisual; cdecl;
var
  setup: Pointer;
  iter: xcb_setup_roots_iterator_t;
  screen: ^xcb_screen_t;
  vis: PVisual;
begin
  setup         := xcb_get_setup(display);
  iter          := xcb_setup_roots_iterator(setup);
  screen        := iter.data;
  New(vis);
  vis^.visualid := screen^.root_visual;
  Result        := vis;
end;

function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; Width, Height, border_width: cuint;
      depth: cint; window_class: cuint; visual: PVisual; valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl;
var
  wid: xcb_window_t;
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
  WriteLn('XCreateWindow: display=', PtrInt(display), ' visual=', PtrInt(visual), ' attributes=', PtrInt(attributes));
  
   if display = nil then
    WriteLn('XCreateWindow: display is null');
  if attributes = nil then
    WriteLn('XCreateWindow: attributes is null');
  if (display = nil) or (attributes = nil) then
  begin
    WriteLn('XCreateWindow: Invalid parameters, exiting');
    Exit;
  end;
    
  // Get default visual if visual is null
  if visual = nil then
  begin
    WriteLn('XCreateWindow: visual is null, using default visual');
    setup := xcb_get_setup(display);
    if setup = nil then
    begin
     WriteLn('XCreateWindow: Failed to get setup');
      Exit;
    end;
    iter := xcb_setup_roots_iterator(setup);
    screen := iter.data;
    if screen = nil then
    begin
      WriteLn('XCreateWindow: Failed to get screen');
      Exit;
    end;
    default_visual := screen^.root_visual;
  end
  else
    default_visual := visual^.visualid;

  wid := xcb_generate_id(display);
 
   WriteLn('wind ', wid);
   
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

 
   cookie := xcb_create_window_checked(display, depth, wid, parent, x, y, Width, Height, border_width,
                                     window_class, default_visual, xcb_value_mask, @xcb_value_list_arr[0]);
 
   {
  cookie := xcb_create_window(
    display,
    CUChar(depth),
    wid,
    CUInt(parent), // Parent is XWindow (QWord), cast to CUInt for xcb_create_window
    CShort(x),
    CShort(y),
    CUShort(Width),
    CUShort(Height),
    CUShort(border_width),
    CUShort(window_class),
    default_visual, // VisualID is QWord, cast to CUInt
    xcb_value_mask,
    @xcb_value_list_arr[0]
  );
  }
 
  error := xcb_request_check(display, cookie);
 
  if error <> nil then
  begin
     WriteLn('Error creating window: ', error^.error_code);
    free(error);
    Result := 0;
  end
  else
  begin
     WriteLn('window create OK');
    Result := wid;
  end;
end;

procedure XMapWindow(display: PDisplay; w: Window); cdecl;
begin
  xcb_map_window(display, w);
end;


function XSelectInput(para1: PDisplay; para2: TWindow; para3: LongInt): LongInt; cdecl;
begin
  writeln('XSelectInput: event_mask = ', para3);
  xcb_change_window_attributes(para1, para2, XCB_CW_EVENT_MASK, @para3);
  Result := 0;
end;

{
function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: TBool): Atom; cdecl;
var
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
begin
  cookie := xcb_intern_atom(Pxcb_connection_t(display), only_if_exists, strlen(atom_name), atom_name);
  reply := xcb_intern_atom_reply(Pxcb_connection_t(display), cookie, nil);
  if reply = nil then
   begin
    writeln('XInternAtom: Failed for ', atom_name, ' (only_if_exists=', ord(only_if_exists), ')');
    Result := 0;
    end
  else begin
   // writeln('XInternAtom: ', atom_name, ' = ', reply^.atom); // Debug
    Result := reply^.atom;
     free(reply);
  end;
end;
}

function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;
var
  conn: xcb_connection_t;
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
begin
  writeln(Format('DEBUG: XInternAtom called for atom: "%s", only_if_exists: %d', [atom_name, only_if_exists]));
  Result := 0;

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XInternAtom: Could not get XCB connection.');
    Exit;
  end;

  cookie := xcb_intern_atom(conn, CUChar(only_if_exists), CUShort(StrLen(atom_name)), atom_name);
  reply := xcb_intern_atom_reply(conn, cookie, nil); // nil for error means we don't care about the error structure
  if reply <> nil then
  begin
    Result := reply^.atom;
    writeln(Format('DEBUG: XInternAtom: Atom "%s" interned successfully with ID: %d', [atom_name, Result]));
    // Update global atoms if they are the ones being interned
    if AnsiCompareText(atom_name, 'WM_PROTOCOLS') = 0 then
    begin
      g_wm_protocols_atom := Result;
      writeln(Format('DEBUG: XInternAtom: g_wm_protocols_atom set to: %d', [g_wm_protocols_atom]));
    end
    else if AnsiCompareText(atom_name, 'WM_DELETE_WINDOW') = 0 then
    begin
      g_wm_delete_window_atom := Result;
      writeln(Format('DEBUG: XInternAtom: g_wm_delete_window_atom set to: %d', [g_wm_delete_window_atom]));
    end;
    free(reply);
  end
  else
  begin
    writeln(Format('ERROR: XInternAtom: Failed to intern atom "%s".', [atom_name]));
    Result := 0;
  end;
end;


function XSendEvent(display: PDisplay; w: Window; propagate: tbool; event_mask: clong; event_send: PXEvent): cint; cdecl;
var
  ev: xcb_client_message_event_t;
begin
  FillChar(ev, SizeOf(ev), 0);
  ev.response_type := ClientMessage;
  ev.window        := w;
  ev.type_         := event_send^.xclient.message_type;
  ev.format        := event_send^.xclient.format;
  case ev.format of
    8: Move(event_send^.xclient.Data.b, ev.Data.data8, 20);
    16: Move(event_send^.xclient.Data.s, ev.Data.data16, 10);
    32: Move(event_send^.xclient.Data.l, ev.Data.data32, 5);
  end;
  xcb_send_event(display, Ord(propagate), w, event_mask, @ev);
  Result := 1; // Success
end;

function XChangeProperty(display: PDisplay; w: Window; atom_property: Atom; type_: Atom; format: cint; mode: cint; Data: Pcuchar; nelements: cint): cint; cdecl;
begin
  Result := 0;
  xcb_change_property(display, mode, w, atom_property, type_, format, nelements, Data);
end;

procedure XFlush(display: PDisplay); cdecl;
begin
  xcb_flush(display);
end;

function XGetAtomName(display: PDisplay; atom: Atom): PChar; cdecl;
var
  cookie: xcb_get_atom_name_cookie_t;
  reply: Pxcb_get_atom_name_reply_t;
 begin
  cookie := xcb_get_atom_name(display, atom);
  reply  := xcb_get_atom_name_reply(display, cookie, nil);
  result := xcb_get_atom_name_name(reply);
  writeln('Atom name: ', result);
end;
 
function XSetWMHints(display: PDisplay; w: Window; wmhints: PXWMHints): cint; cdecl;
var
  Data: array[0..8] of cuint32;
begin
  Data[0] := wmhints^.flags;
  Data[1] := Ord(wmhints^.input);
  Data[2] := wmhints^.initial_state;
  Data[3] := wmhints^.icon_pixmap;
  Data[4] := wmhints^.icon_window;
  Data[5] := wmhints^.icon_x;
  Data[6] := wmhints^.icon_y;
  Data[7] := wmhints^.icon_mask;
  Data[8] := wmhints^.window_group;
  xcb_change_property(display, PropModeReplace, w, XA_WM_HINTS, XA_WM_HINTS, 32, 9, @Data);
  Result  := 1; // Success
end;

procedure XFree(Data: Pointer); cdecl;
begin
// done by xcb
end;

function XCreateGC(display: PDisplay; d: Drawable; valuemask: culong; values: PXGCValues): GC; cdecl;
var
  gc_id: xcb_gcontext_t;
  gc_ptr: GC;
begin
  gc_id := xcb_generate_id(display);
  writeln('XCreateGC: gc_id = ', gc_id, ', drawable = ', d, ', valuemask = ', valuemask);
  if values <> nil then
    writeln('XCreateGC: values.foreground = ', values^.foreground, ', values.background = ', values^.background);
  xcb_create_gc(display, gc_id, d, valuemask, values);
  GetMem(gc_ptr, SizeOf(cuint));
  PLongWord(gc_ptr)^ := gc_id;
  Result := gc_ptr;
end;

procedure XFreeGC(display: PDisplay; gc: GC); cdecl;
begin
  xcb_free_gc(display, xcb_gcontext_t(gc));
end;

procedure XSetForeground(display: PDisplay; gc: GC; foreground: culong); cdecl;
var
  value_list: array[0..0] of cuint32;
begin
  value_list[0] := foreground;
  xcb_change_gc(display, xcb_gcontext_t(gc), GCForeground, @value_list);
end;

procedure XDrawLine(display: PDisplay; d: Drawable; gc: GC; x1, y1, x2, y2: cint); cdecl;
var
  points: array[0..1] of record
    x, y: cint16;
  end;
begin
  points[0].x := x1;
  points[0].y := y1;
  points[1].x := x2;
  points[1].y := y2;
  xcb_poly_line(display, 0, d, xcb_gcontext_t(gc), 2, @points);
end;

function XLoadQueryFont(display: PDisplay; Name: PChar): PXFontStruct; cdecl;
var
  font: xcb_font_t;
  cookie: Pointer;
  reply: xcb_query_font_reply_t;
  fs: PXFontStruct;
begin
  font        := xcb_generate_id(display);
  xcb_open_font(display, font, Length(Name), Name);
  cookie      := xcb_query_font(display, font);
  reply       := xcb_query_font_reply(display, cookie, nil);
  New(fs);
  fs^.fid     := font;
  fs^.ascent  := reply.ascent;
  fs^.descent := reply.descent;
  Result      := fs;
end;

procedure XFreeFont(display: PDisplay; font_struct: PXFontStruct); cdecl;
begin
  xcb_close_font(display, font_struct^.fid);
  Dispose(font_struct);
end;

procedure XDrawString(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PChar; length: cint); cdecl;
begin
  xcb_poly_text_8(display, d, xcb_gcontext_t(gc), x, y, length, str);
end;

procedure XDrawString16(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PXChar2b; length: cint); cdecl;
begin
  xcb_poly_text_16(display, d, xcb_gcontext_t(gc), x, y, length * 2, str);
end;

procedure XPutImage(display: PDisplay; d: Drawable; gc: GC; image: PXImage; src_x, src_y: cint; dest_x, dest_y: cint; Width, Height: cuint32); cdecl;
var
  c: Pxcb_connection_t;
  cookie: xcb_void_cookie_t;
  err: Pxcb_generic_error_t;
  format: cuint8;
  depth: cuint8;
  data_len: cuint32;
  left_pad: cuint8;
  gc_xcb: xcb_gcontext_t;
begin
  // Use global XCB connection
  c := GlobalXCBConnection;
  if (c = nil) or (image = nil) then
    Exit;

  // Convert Xlib GC to XCB gcontext_t (adjust as needed)
  gc_xcb := xcb_gcontext_t(gc); // Placeholder; replace with proper conversion
  // Example: gc_xcb := Xlib_to_XCBGC(display, gc); // If you have a helper

  // Map Xlib XImage format to XCB format
  case image^.format of
    XYBitmap: format := XCB_IMAGE_FORMAT_XY_BITMAP;
    XYPixmap: format := XCB_IMAGE_FORMAT_XY_PIXMAP;
    ZPixmap: format  := XCB_IMAGE_FORMAT_Z_PIXMAP;
    else
      Exit; // Invalid format
  end;
            // Get depth and data from XImage
  depth    := image^.depth;
  data_len := image^.bytes_per_line * image^.Height;
  left_pad := src_x; // Use src_x as left_pad for XY formats; 0 for ZPixmap
  if format = XCB_IMAGE_FORMAT_Z_PIXMAP then
    left_pad := 0;

  // Ensure width and height fit within cuint16
  if (Width > High(cuint16)) or (Height > High(cuint16)) then
    Exit;

  // Send the put image request
  cookie := xcb_put_image(c, format, d, gc_xcb, Width, Height, dest_x, dest_y, left_pad, depth, data_len, PByte(image^.Data));

  // Check for errors
  err := xcb_request_check(c, cookie);
 // if err <> nil then
   // Freemem(err);// Optionally log error

end;

function XCreateColormap(display: PDisplay; w: Window; visual: PVisual; alloc: cint): TColormap; cdecl;
var
  cmap: xcb_colormap_t;
begin
  cmap   := xcb_generate_id(display);
  xcb_create_colormap(display, alloc, cmap, w, visual^.visualid);
  Result := cmap;
end;

procedure XFreeColormap(display: PDisplay; cmap: TColormap); cdecl;
begin
  xcb_free_colormap(display, cmap);
end;

function XCreatePixmap(display: PDisplay; d: Drawable; Width, Height, depth: cuint): TPixmap; cdecl;
var
  pid: xcb_pixmap_t;
begin
  pid    := xcb_generate_id(display);
  xcb_create_pixmap(display, depth, pid, d, Width, Height);
  Result := pid;
end;

function XRenderCreatePicture(display: PDisplay; d: Drawable; format: PXRenderPictFormat; valuemask: culong; attributes: Pointer): TPicture; cdecl;
var
  pid: xcb_render_picture_t;
begin
  pid    := xcb_generate_id(display);
  xcb_render_create_picture(display, pid, d, format^.id, valuemask, attributes);
  Result := pid;
end;

procedure XRenderFreePicture(display: PDisplay; picture: TPicture); cdecl;
begin
  xcb_render_free_picture(display, picture);
end;

procedure XRenderComposite(display: PDisplay; op: cint; src: TPicture; mask: TPicture; dst: TPicture; src_x, src_y, mask_x, mask_y, dst_x, dst_y: cint; Width, Height: cuint); cdecl;
begin
  xcb_render_composite(display, op, src, mask, dst, src_x, src_y, mask_x, mask_y, dst_x, dst_y, Width, Height);
end;

procedure XShapeCombineRectangles(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; rectangles: PXRectangle; n_rects: cint; op: cint; ordering: cint); cdecl;
begin
  xcb_shape_rectangles(display, op, dest_kind, ordering, dest, x, y, n_rects, rectangles);
end;

function XRRQueryExtension(dpy: pDisplay; event_base_return: pcint; error_base_return: pcint): tBool; cdecl;
var
  cookie: xcb_void_cookie_t;
  reply: Pointer;
  error: Pxcb_generic_error_t;
begin
  cookie := xcb_randr_query_version(dpy, 1, 2); // Query RandR version 1.2
  reply := xcb_randr_query_version_reply(dpy, cookie, @error);
  if error <> nil then
  begin
    free(error);
    Result := 0;
  end
  else if reply <> nil then
  begin
    Result := 1; // Assume RandR is present
    event_base_return^ := 0; // Placeholder, may affect RandR events
    error_base_return^ := 0;
    g_randreventbase := 0;
    g_randrerrorbase := 0;
    free(reply);
  end
  else
    Result := 0;
end;

procedure XShapeCombineMask(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; mask: TPixmap; op: cint); cdecl;
begin
  xcb_shape_mask(display, op, dest_kind, dest, x, y, mask);
end;

function find_visual_type(screen: Pxcb_screen_t; visual_id: xcb_visualid_t): Pxcb_visualtype_t;
var
  depth_iter: xcb_depth_iterator_t;
  visual_iter: xcb_visualtype_iterator_t;
begin
  Result := nil;
  // Optional: Add a nil check for safety
  if screen = nil then
  begin
    WriteLn('Error: screen is nil in find_visual_type');
    Exit;
  end;
  depth_iter := xcb_screen_allowed_depths_iterator(screen);
  while depth_iter.rem > 0 do
  begin
    visual_iter := xcb_depth_visuals_iterator(depth_iter.data);
    while visual_iter.rem > 0 do
    begin
      if visual_iter.data^.visual_id = visual_id then
      begin
        Result := visual_iter.data;
        Exit;
      end;
      xcb_visualtype_next(@visual_iter);
    end;
    xcb_depth_next(@depth_iter);
  end;
end;

function XDefaultScreenOfDisplay(display: PDisplay): PScreen; cdecl;
var
  setup: Pxcb_setup_t;
  iterator: xcb_screen_iterator_t;
  visual_type: Pxcb_visualtype_t;
begin
  // Get setup from XCB connection
  setup := xcb_get_setup(display);
  if setup = nil then
  begin
    WriteLn('Error: Failed to get setup from display');
    Exit(nil);
  end;

  // Get iterator for screens
  iterator := xcb_setup_roots_iterator(setup);
  if iterator.data = nil then
  begin
    WriteLn('Error: No screens found in setup');
    Exit(nil);
  end;

  // Populate g_screen
  g_screen.ext_data := nil;           // Not used in this context
  g_screen.display := display;        // Associate with display
  g_screen.root := iterator.data^.root;
  g_screen.width := iterator.data^.width_in_pixels;
  g_screen.height := iterator.data^.height_in_pixels;
  g_screen.mwidth := iterator.data^.width_in_millimeters;
  g_screen.mheight := iterator.data^.height_in_millimeters;
  g_screen.ndepths := 0;              // Simplified, adjust if needed
  g_screen.depths := nil;             // Simplified, adjust if needed
  g_screen.root_depth := iterator.data^.root_depth;

  // Find and populate root visual
  visual_type := find_visual_type(iterator.data, iterator.data^.root_visual);
  if visual_type <> nil then
  begin
    g_root_visual.visualid := visual_type^.visual_id;
    g_root_visual._class := visual_type^._class;
    g_root_visual.red_mask := visual_type^.red_mask;
    g_root_visual.green_mask := visual_type^.green_mask;
    g_root_visual.blue_mask := visual_type^.blue_mask;
    g_root_visual.bits_per_rgb := visual_type^.bits_per_rgb_value;
    g_root_visual.map_entries := visual_type^.colormap_entries;
    g_screen.root_visual := @g_root_visual;
  end
  else
  begin
    // WriteLn('Warning: Could not find visual type for root visual');
    g_screen.root_visual := nil;    // Handle gracefully if required
  end;

  g_screen.default_gc := nil;         // Adjust if MSEgui needs it
  g_screen.cmap := iterator.data^.default_colormap;
  g_screen.white_pixel := iterator.data^.white_pixel;
  g_screen.black_pixel := iterator.data^.black_pixel;
  g_screen.max_maps := iterator.data^.max_installed_maps;
  g_screen.min_maps := iterator.data^.min_installed_maps;
  g_screen.backing_store := iterator.data^.backing_stores;
  g_screen.save_unders := iterator.data^.save_unders;
  g_screen.root_input_mask := 0;      // Adjust if needed

  Result := @g_screen;
end;

function XRootWindowOfScreen(screen: PScreen): Window; cdecl;
begin
  Result := screen^.root;
end;

function XDefaultVisualOfScreen(screen: PScreen): PVisual; cdecl;
var
  setup: Pxcb_setup_t;
  screen_iter: xcb_screen_iterator_t;
  depth_iter: xcb_depth_iterator_t;
  visual_iter: xcb_visualtype_iterator_t;
  visual_type: Pxcb_visualtype_t;
  visual: PVisual;
begin
   //WriteLn('XDefaultVisualOfScreen: init');
   if screen = nil then
  begin
    WriteLn('XDefaultVisualOfScreen: screen is null');
    Exit;
  end;

  // Allocate Visual structure
  New(visual);
  FillChar(visual^, SizeOf(Visual), 0);

  // Get setup and screen
  setup := xcb_get_setup(Pxcb_connection_t(screen^.display));
 
  if setup = nil then
  begin
    WriteLn('XDefaultVisualOfScreen: Failed to get setup');
    Dispose(visual);
    Exit;
  end;

  screen_iter := xcb_setup_roots_iterator(setup);
  while screen_iter.rem > 0 do
  begin
    if screen_iter.data^.root = screen^.root then
    begin
      // Iterate through depths and visuals
      depth_iter := xcb_screen_allowed_depths_iterator(screen_iter.data);
      while depth_iter.rem > 0 do
      begin
        visual_iter := xcb_depth_visuals_iterator(depth_iter.data);
        while visual_iter.rem > 0 do
        begin
          visual_type := visual_iter.data;
          if visual_type^.visual_id = screen^.root_visual^.visualid then
          begin
            visual^.visualid := visual_type^.visual_id;
            visual^._class := visual_type^._class;
            visual^.red_mask := visual_type^.red_mask;
            visual^.green_mask := visual_type^.green_mask;
            visual^.blue_mask := visual_type^.blue_mask;
            visual^.bits_per_rgb := visual_type^.bits_per_rgb_value;
            visual^.map_entries := visual_type^.colormap_entries;
            Result := visual;
            // WriteLn('XDefaultVisualOfScreen: visualid=', visual^.visualid);
            Exit;
          end;
          xcb_visualtype_next(@visual_iter);
        end;
        xcb_depth_next(@depth_iter);
      end;
    end;
    xcb_screen_next(@screen_iter);
  end;
  // WriteLn('XDefaultVisualOfScreen: No matching visual found');
  Dispose(visual);
end;

function XDefaultDepthOfScreen(para1: PScreen): cint; cdecl;
begin
Result := para1^.root_depth;
end;

function XSetICValues(IC: XIC; focusw: PChar; id: longint; pnt: Pointer): PChar; cdecl;
var
  pic: PXIC;
begin
  Result := nil;
  if IC = nil then
  begin
    WriteLn('XSetICValues: Invalid input context');
    Result := PChar('Invalid IC');
    Exit;
  end;

  pic := PXIC(IC);
  if focusw = XNClientWindow then
  begin
    pic^.client_window := id;
    //WriteLn('XSetICValues: client_window=', id);
  end
  else if focusw = XNFocusWindow then
  begin
    pic^.focus_window := id;
    // WriteLn('XSetICValues: focus_window=', id);
  end
  else
  begin
   // WriteLn('XSetICValues: Unknown property ', focusw);
    Result := PChar('Unknown property');
  end;

 // WriteLn('XSetICValues: Success');
end;

function XSetICValues(IC: XIC; nreset: PChar; impreserv: PChar; pnt: Pointer): PChar; cdecl;
begin
  Result := nil;
  if IC = nil then
  begin
    WriteLn('XSetICValues: Invalid input context');
    Result := PChar('Invalid IC');
    Exit;
  end;

  if nreset = XNResetState then
    //WriteLn('XSetICValues: reset_state=', impreserv)
  else if nreset = XNIMPreeditState then
    //WriteLn('XSetICValues: preedit_state=', impreserv)
  else
  begin
    //WriteLn('XSetICValues: Unknown property ', nreset);
    Result := PChar('Unknown property');
  end;

  // WriteLn('XSetICValues: Success');
end;

function XSetIMValues(IC: XIM; destroycb: PChar; ximcb: Pointer; pt: Pointer): PChar; cdecl;
begin
  Result := nil;
  if IC = nil then
  begin
    // WriteLn('XSetIMValues: Invalid input method');
    Result := PChar('Invalid IM');
    Exit;
  end;

  if destroycb = XNDestroyCallback then
    // WriteLn('XSetIMValues: destroy_callback=', PtrInt(ximcb))
  else
  begin
    // WriteLn('XSetIMValues: Unknown property ', destroycb);
    Result := PChar('Unknown property');
  end;

  // WriteLn('XSetIMValues: Success');
end;

function XGetICValues(IC: XIC; filterev: PChar; icmask: Pointer; pnt: Pointer): PChar; cdecl;
var
  pic: PXIC;
begin
  Result := nil;
  if IC = nil then
  begin
    WriteLn('XGetICValues: Invalid input context');
    Result := PChar('Invalid IC');
    Exit;
  end;

  pic := PXIC(IC);
  if filterev = XNFilterEvents then
  begin
    PLongint(icmask)^ := XCB_EVENT_MASK_KEY_PRESS or XCB_EVENT_MASK_KEY_RELEASE;
   // WriteLn('XGetICValues: filter_events=', PLongint(icmask)^);
  end
  else
  begin
   // WriteLn('XGetICValues: Unknown property ', filterev);
    Result := PChar('Unknown property');
  end;

 // WriteLn('XGetICValues: Success');
end;

function XDefaultColormapOfScreen(para1: PScreen): Colormap; cdecl;
begin
  Result := 0;
  if para1 = nil then
  begin
    WriteLn('XDefaultColormapOfScreen: para1 is nil');
    Exit;
  end;

  // WriteLn('XDefaultColormapOfScreen: colormap=', para1^.cmap);
  Result := para1^.cmap;
end;

function XCreateIC(IM: XIM; inputstyle: PChar; status: longint; pt: Pointer): XIC; cdecl;
var
  ic: PXIC;
begin
  Result := nil;
  if (IM = nil) or (inputstyle = nil) then
  begin
    WriteLn('XCreateIC: Invalid parameters: IM=', PtrInt(IM), ' inputstyle=', inputstyle);
    Exit;
  end;

  New(ic);
  ic^.im := PXIM(IM);
  ic^.client_window := 0;
  ic^.focus_window := 0;
  ic^.input_style := status; // Store XIMPreeditNothing | XIMStatusNothing
  ic^.filter_events := 0;

  // WriteLn('XCreateIC: Created input context, style=', status);
  Result := XIC(ic);
end;

{
function XInternAtom(display: PDisplay; atom_name: PAnsiChar; only_if_exists: CInt): Atom; cdecl;
var
  conn: xcb_connection_t;
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
begin
  writeln(Format('DEBUG: XInternAtom called for atom: "%s", only_if_exists: %d', [atom_name, only_if_exists]));
  Result := 0;

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XInternAtom: Could not get XCB connection.');
    Exit;
  end;

  cookie := xcb_intern_atom(conn, CUChar(only_if_exists), CUShort(StrLen(atom_name)), atom_name);
  reply := xcb_intern_atom_reply(conn, cookie, nil); // nil for error means we don't care about the error structure
  if reply <> nil then
  begin
    Result := reply^.atom;
    writeln(Format('DEBUG: XInternAtom: Atom "%s" interned successfully with ID: %d', [atom_name, Result]));
    // Update global atoms if they are the ones being interned
    if AnsiCompareText(atom_name, 'WM_PROTOCOLS') = 0 then
    begin
      g_wm_protocols_atom := Result;
      writeln(Format('DEBUG: XInternAtom: g_wm_protocols_atom set to: %d', [g_wm_protocols_atom]));
    end
    else if AnsiCompareText(atom_name, 'WM_DELETE_WINDOW') = 0 then
    begin
      g_wm_delete_window_atom := Result;
      writeln(Format('DEBUG: XInternAtom: g_wm_delete_window_atom set to: %d', [g_wm_delete_window_atom]));
    end;
    free(reply);
  end
  else
  begin
    writeln(Format('ERROR: XInternAtom: Failed to intern atom "%s".', [atom_name]));
    Result := 0;
  end;
end;
}

function XInternAtoms(dpy: PDisplay; names: PPChar; n: cint; only_if_exists: tbool; atoms_return: PAtom): TStatus; cdecl;
var
  i: cint;
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
begin
  Result := 1;
  for i := 0 to n - 1 do begin
    cookie := xcb_intern_atom(Pxcb_connection_t(dpy), only_if_exists, strlen(names[i]), names[i]);
    reply := xcb_intern_atom_reply(Pxcb_connection_t(dpy), cookie, nil);
    if reply = nil then begin
      atoms_return[i] := 0;
      Result := 0;
    end else begin
     // writeln('XInternAtoms: ', names[i], ' = ', reply^.atom); // Debug
      atoms_return[i] := reply^.atom;
      free(reply);
    end;
  end;
end;


function XOpenIM(Display: PDisplay; rdb: PXrmHashBucketRec; res_name: PChar; res_class: PChar): XIM; cdecl;
var
  im: PXIM;
begin
  Result := nil;
  if Display = nil then
  begin
    WriteLn('XOpenIM: Invalid display');
    Exit;
  end;

  New(im);
  im^.connection := Display;
  // WriteLn('XOpenIM: Created input method, connection=', PtrInt(display));
  Result := im;
end;

function XFreeModifierMap(para1: PXModifierKeymap): cint; cdecl;
begin
    // modifiermap is managed by XCB reply, already freed in XGetModifierMapping
    Result := 1; // Success
end;

function XConnectionNumber(display: PDisplay): cint; cdecl;
begin
  Result := xcb_get_file_descriptor(Pxcb_connection_t(display));
end;
 
function XSetErrorHandler(para1: TXErrorHandler): TXErrorHandler; cdecl;
begin
  // Store the handler globally (requires global variable in mxcb.pas)
  global_error_handler := para1;
  Result := nil; // Xlib returns previous handler, but we don’t store it yet
end;

function XKeysymToKeycode(display: PDisplay; keysym: KeySym): TKeyCode; cdecl;
var
  syms: Pxcb_key_symbols_t;
  keycodes: Pxcb_keycode_t;
  result_keycode: KeyCode;
begin
  syms := xcb_key_symbols_alloc(display); // Remove cast if PDisplay = Pxcb_connection_t
  if syms = nil then begin
    writeln('XKeysymToKeycode: Failed to allocate key symbols');
    Result := 0;
    Exit;
  end;
  keycodes := xcb_key_symbols_get_keycode(syms, keysym);
  if keycodes = nil then begin
    writeln('XKeysymToKeycode: No keycode for keysym ', keysym);
    result_keycode := 0;
  end else begin
    result_keycode := keycodes^;
    // writeln('XKeysymToKeycode: keysym ', keysym, ' -> keycode ', result_keycode);
    free(keycodes);
  end;
  xcb_key_symbols_free(syms);
  Result := result_keycode;
end;

function XGetModifierMapping(display: PDisplay): PXModifierKeymap; cdecl;
var
  reply: Pxcb_get_modifier_mapping_reply_t;
  modmap: PXModifierKeymap;
  cookie: xcb_get_modifier_mapping_cookie_t;
begin

  cookie := xcb_get_modifier_mapping(display);
  reply := xcb_get_modifier_mapping_reply(display, cookie, nil);
  if reply = nil then begin
    writeln('XGetModifierMapping: Failed to get reply');
    Result := nil;
    Exit;
  end;
  GetMem(modmap, SizeOf(XModifierKeymap));
  if modmap = nil then begin
    writeln('XGetModifierMapping: Failed to allocate modmap');
    free(reply);
    Result := nil;
    Exit;
  end;
  modmap^.max_keypermod := reply^.keycodes_per_modifier;
  modmap^.modifiermap := PKeyCode(xcb_get_modifier_mapping_keycodes(reply));
  // writeln('XGetModifierMapping: max_keypermod = ', modmap^.max_keypermod);
  Result := modmap;
  free(reply);
end;

function XGetWindowProperty(display: PDisplay; w: Window; atom_property: Atom; long_offset, long_length: culong;
           Delete: TBool; req_type: Atom;  actual_type_return: PAtom; actual_format_return: Pcint;
           nitems_return: Pculong; bytes_after_return: Pculong; prop_return: PPcuchar): cint; cdecl;
var
  cookie: xcb_get_property_cookie_t;
  reply: pxcb_get_property_reply_t;
  value_ptr: Pcuchar; // Pointer to the raw value data within the reply
  value_len_bytes: Cardinal; // Length of the value in bytes
  allocated_mem: PByte; // For memory we explicitly allocate to mimic Xlib's behavior
  i : integer;
begin
   cookie := xcb_get_property(display, Ord(Delete), w, atom_property, req_type, long_offset, long_length);
 
  reply := xcb_get_property_reply(display, cookie, nil);
 // writeln('XGetWindowProperty 1');
  if reply = nil then begin
    writeln('xgetwindowproperty reply = nil for property: ', atom_property); // Add property info for better debugging
    actual_type_return^ := 0; // Indicate no type
    actual_format_return^ := 0; // Indicate no format
    nitems_return^ := 0;
    bytes_after_return^ := 0;
    prop_return^ := nil; // IMPORTANT: Ensure the pointer is nil if no data
    Result := 0;
    Exit;
  end;

  actual_type_return^ := reply^.type_;
  actual_format_return^ := reply^.format;
  bytes_after_return^ := reply^.bytes_after;

  // Get a pointer to the value data within the reply structure
  value_ptr := xcb_get_property_value(reply);
  // Get the length of the value data in bytes

  // value_len_bytes := xcb_get_property_value_length(reply); // Commented out as it's not defined
  value_len_bytes := reply^.length * 4; // Correctly using reply^.length for total bytes

  // Calculate nitems_return based on format and byte length
  // Format is 8, 16, or 32 bits per item.
  case actual_format_return^ of
    8: nitems_return^ := value_len_bytes; // 8-bit items, so length in bytes is number of items
    16: nitems_return^ := value_len_bytes div 2; // 16-bit items, 2 bytes per item
    32: nitems_return^ := value_len_bytes div 4; // 32-bit items, 4 bytes per item
    else nitems_return^ := 0; // Unknown format, or invalid
  end;

   if value_len_bytes > 0 then begin
    GetMem(allocated_mem, value_len_bytes); // Allocate memory
    Move(value_ptr^, allocated_mem^, value_len_bytes); // Copy data from xcb reply to allocated memory
    prop_return^ := allocated_mem; // Assign the pointer to the newly allocated memory

   end else begin
    prop_return^ := nil; // No data, return nil
    // Ensure debug pointers are nil if no data
  end;
  // fred
 // xcb_aux_release(reply); 
end;

{
function XCreateImage(Display: PDisplay; Visual: msePVisual; Depth: longword;
  Format: Longint; Offset: Longint; Data: PChar; Width, Height: longword;
  bitmap_pad: Longint; bytes_per_line: Longint): PXImage; cdecl;
var
  image: PXImage;
  setup: Pxcb_setup_t;
  screen_iter: xcb_screen_iterator_t;
  format_iter: Pxcb_format_t;
  i: integer;
  formats: Pointer;
begin
  New(image);
  if image = nil then begin
    writeln('XCreateImage: Failed to allocate image');
    Result := nil;
    Exit;
  end;
  FillChar(image^, SizeOf(TXImage), 0); // Initialize all fields
  image^.Width := width;
  image^.Height := height;
  image^.depth := depth;
  image^.format := format;
  image^.Data := data;
  image^.xoffset := offset;
  image^.bitmap_pad := bitmap_pad;
  if bytes_per_line = 0 then begin
    setup := xcb_get_setup(display); // PDisplay = Pxcb_connection_t
    if setup = nil then begin
      writeln('XCreateImage: Failed to get setup');
      Dispose(image);
      Result := nil;
      Exit;
    end;
    screen_iter := xcb_setup_roots_iterator(setup);
    if screen_iter.data = nil then begin
      writeln('XCreateImage: No screens found in setup');
      Dispose(image);
      Result := nil;
      Exit;
    end;
    // Access pixmap formats
    formats := PChar(setup) + SizeOf(xcb_setup_t);
    format_iter := Pxcb_format_t(formats);
    for i := 0 to setup^.pixmap_formats_len - 1 do begin
      if format_iter^.depth = depth then begin
        image^.bits_per_pixel := format_iter^.bits_per_pixel;
        image^.bytes_per_line := (width * format_iter^.bits_per_pixel + 7) div 8;
        image^.bytes_per_line := ((image^.bytes_per_line + format_iter^.scanline_pad - 1) div format_iter^.scanline_pad) * format_iter^.scanline_pad;
        Break;
      end;
      Inc(format_iter);
    end;
    if image^.bytes_per_line = 0 then begin
      writeln('XCreateImage: No matching pixmap format for depth=', depth);
      Dispose(image);
      Result := nil;
      Exit;
    end;
  end else image^.bytes_per_line := bytes_per_line;
  
  image^.bitmap_unit := 32; // Matches Xlib default
  image^.bitmap_bit_order := setup^.bitmap_format_bit_order;
  image^.byte_order := setup^.image_byte_order;
  image^.red_mask := visual^.red_mask;
  image^.green_mask := visual^.green_mask;
  image^.blue_mask := visual^.blue_mask;
  image^.obdata := nil;
  // Set function pointers
  image^.f.create_image :=  nil;
  image^.f.destroy_image := @XDestroyImage;
  image^.f.destroy_image := nil;
  image^.f.get_pixel := nil;
  image^.f.put_pixel := nil;
  image^.f.sub_image := nil;
  image^.f.add_pixel := nil;
  writeln('XCreateImage: depth = ', depth, ', format = ', XCB_IMAGE_FORMAT_Z_PIXMAP);
  Result := image;
end;
}

// --- XCreateImage Implementation (moved after helper functions) ---
function XCreateImage(Display: PDisplay; Visual: msePVisual; Depth: longword;
  Format: Longint; Offset: Longint; Data: PChar; Width, Height: longword;
  bitmap_pad: Longint; bytes_per_line: Longint): PXImage; cdecl;
var
  new_image: TXImage;
  image_data_size: CInt;
  actual_bytes_per_line: CInt;
  bits_per_pixel_val: CInt;
  setup: Pxcb_setup_t;
begin
  Result := nil; // Default to nil

  // Basic validation
  if (Width = 0) or (Height = 0) then Exit;
  if (Format <> XYBitmap) and (Format <> ZPixmap) then Exit; // Only support these two formats for now

  // Allocate the TXImage record
  New(Result);
  if Result = nil then Exit;

  // Initialize all fields to zero first
  FillChar(new_image, SizeOf(TXImage), 0);

  // Populate basic fields
  new_image.Width := CInt(Width);
  new_image.Height := CInt(Height);
  new_image.xoffset := Offset;
  new_image.format := Format;
  new_image.depth := CInt(Depth);
  new_image.bitmap_pad := bitmap_pad;

  // Determine bits_per_pixel
  bits_per_pixel_val := CalculateBitsPerPixel(Format, CInt(Depth));
  if bits_per_pixel_val = 0 then
  begin
    Dispose(Result);
    Exit;
  end;
  new_image.bits_per_pixel := bits_per_pixel_val;

  // Get system byte order and bitmap bit order from XCB setup
  setup := xcb_get_setup(g_xcb_conn);
  if setup <> nil then
  begin
    // Xlib constants LSBFirst/MSBFirst usually correspond to XCB_IMAGE_ORDER_LSB_FIRST/MSB_FIRST
    new_image.byte_order := CInt(setup^.image_byte_order);
    new_image.bitmap_bit_order := CInt(setup^.bitmap_format_bit_order);
    new_image.bitmap_unit := CInt(setup^.bitmap_format_scanline_unit);
  end
  else
  begin
    // Fallback to common defaults if setup info is not available
    new_image.byte_order := LSBFirst; // Assume common little-endian
    new_image.bitmap_bit_order := LSBFirst; // Assume common little-endian
    new_image.bitmap_unit := 8; // Assume 8-bit unit
  end;


  // Calculate bytes_per_line if not provided (bytes_per_line = 0)
  if bytes_per_line = 0 then
  begin
    actual_bytes_per_line := CalculateBytesPerLine(Width, new_image.bits_per_pixel, bitmap_pad);
  end
  else
  begin
    actual_bytes_per_line := bytes_per_line;
  end;
  new_image.bytes_per_line := actual_bytes_per_line;

  // Calculate total data size
  image_data_size := new_image.bytes_per_line * CInt(Height);
  if image_data_size <= 0 then // Prevent zero or negative allocation
  begin
    Dispose(Result);
    Exit;
  end;

  // Handle Data pointer: allocate if nil, otherwise use provided
  if Data = nil then
  begin
    GetMem(new_image.Data, image_data_size);
    if new_image.Data = nil then
    begin
      Dispose(Result);
      Exit;
    end;
    FillChar(new_image.Data^, image_data_size, 0); // Initialize allocated memory to 0
    new_image.obdata := Pointer(new_image.Data); // Mark that we allocated this memory
  end
  else
  begin
    new_image.Data := Data;
    new_image.obdata := nil; // User provided data, we don't own it
  end;

  // Populate visual masks from the provided Visual structure
  if Visual <> nil then
  begin
    new_image.red_mask := Visual^.red_mask;
    new_image.green_mask := Visual^.green_mask;
    new_image.blue_mask := Visual^.blue_mask;
  end
  else
  begin
    // Fallback masks if no visual provided or visual is nil
    // These are common for 24-bit TrueColor
    if new_image.depth >= 24 then
    begin
      new_image.red_mask := $FF0000;
      new_image.green_mask := $00FF00;
      new_image.blue_mask := $0000FF;
    end;
  end;

  // Assign function pointers
 // new_image.f.create_image := @XImage_create_image;
  new_image.f.destroy_image := @XImage_destroy_image;
  new_image.f.get_pixel := @XImage_get_pixel;
  new_image.f.put_pixel := @XImage_put_pixel;
  new_image.f.sub_image := @XImage_sub_image;
  new_image.f.add_pixel := @XImage_add_pixel;

  // Copy the populated new_image record to the Result pointer
  Result^ := new_image;
end;



function XGetGeometry(display: PDisplay; d: TDrawable; root: PWindow; x, y: PLongInt; width, height, border_width, depth: PLongWord): LongInt; cdecl;
var
  cookie: xcb_get_geometry_cookie_t;
  reply: Pxcb_get_geometry_reply_t;
begin
  cookie := xcb_get_geometry(display, d);
  reply := xcb_get_geometry_reply(display, cookie, nil);
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

function XCopyArea(display: PDisplay; src, dest: TDrawable; gc: TGC; src_x, src_y, width, height: LongInt; dest_x, dest_y: LongInt): LongInt; cdecl;
begin
 xcb_copy_area(display, src, dest, gc, src_x, src_y, dest_x, dest_y, width, height);
end;

function XFreePixmap(para1: PDisplay; para2: TPixmap): cint; cdecl;
begin
 xcb_free_pixmap(para1, para2);
end;

function XPending(display: PDisplay): cint; cdecl;
var
  generic_event: Pxcb_generic_event_t;
  conn: xcb_connection_t;
begin
 // writeln('DEBUG: XPending called.');
  Result := 0; // Default to 0 pending events

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XPending: Could not get XCB connection.');
    Exit;
  end;

  // Poll for all currently available events and add them to the internal queue
  repeat
    generic_event := xcb_poll_for_event(conn);
    if generic_event <> nil then
    begin
      g_event_queue.Add(generic_event); // Add event to queue, DO NOT FREE HERE
      writeln(Format('DEBUG: XPending: Polled event %p, queue size: %d', [generic_event, g_event_queue.Count]));
    end;
  until generic_event = nil;

  Result := g_event_queue.Count; // Return the count of events in the internal queue
 // writeln(Format('DEBUG: XPending: Found %d pending events in queue.', [Result]));
end;


function XConfigureWindow(display: PDisplay; w: TWindow; value_mask: LongWord; values: Pointer): LongInt; cdecl;
var
  changes: PXWindowChanges;
begin
  if values = nil then begin
    writeln('XConfigureWindow: values is nil');
    Result := 0;
    Exit;
  end;
  changes := PXWindowChanges(values);
  writeln('XConfigureWindow: x = ', changes^.x, ', y = ', changes^.y, ', width = ', changes^.width, ', height = ', changes^.height, ', mask = ', value_mask);
  xcb_configure_window(display, w, value_mask, values);
  Result := 0;
end;

function XSetWMNormalHints(display: PDisplay; w: TWindow; hints: PXSizeHints): LongInt; cdecl;
var
  wm_normal_hints: xcb_atom_t;
  atom_cookie: xcb_intern_atom_cookie_t;
  atom_reply: Pxcb_intern_atom_reply_t;
begin
  if hints = nil then begin
    writeln('XSetWMNormalHints: hints is nil');
    Result := 0;
    Exit;
  end;
  atom_cookie := xcb_intern_atom(display, 0, Length('WM_NORMAL_HINTS'), 'WM_NORMAL_HINTS');
  atom_reply := xcb_intern_atom_reply(display, atom_cookie, nil);
  if atom_reply = nil then begin
    writeln('XSetWMNormalHints: atom_reply is nil');
    Result := 0;
    Exit;
  end;
  wm_normal_hints := atom_reply^.atom;
  free(atom_reply);
  writeln('XSetWMNormalHints: flags = ', hints^.flags);
  xcb_change_property(display, XCB_PROP_MODE_REPLACE, w, wm_normal_hints, wm_normal_hints, 32, 18, hints);
  Result := 1;
end;

function XAllocSizeHints: PXSizeHints; cdecl;
begin
  New(Result);
  FillChar(Result^, SizeOf(XSizeHints), 0);
  writeln('XAllocSizeHints: sizehints = ', PtrInt(Result));
end;

function XGetWindowAttributes(display: PDisplay; w: TWindow; window_attributes: PXWindowAttributes): LongInt; cdecl;
var
  cookie: xcb_get_window_attributes_cookie_t;
  reply: Pxcb_get_window_attributes_reply_t;
begin
  if window_attributes = nil then begin
    writeln('XGetWindowAttributes: window_attributes is nil');
    Result := 0;
    Exit;
  end;
  cookie := xcb_get_window_attributes(display, w);
  reply := xcb_get_window_attributes_reply(display, cookie, nil);
  if reply <> nil then begin
    FillChar(window_attributes^, SizeOf(TXWindowAttributes), 0);
    window_attributes^.visual := PVisual(reply^.visual);
    window_attributes^.c_class := reply^._class;
    window_attributes^.bit_gravity := reply^.bit_gravity;
    window_attributes^.win_gravity := reply^.win_gravity;
    window_attributes^.backing_store := reply^.backing_store;
    window_attributes^.backing_planes := reply^.backing_planes;
    window_attributes^.backing_pixel := reply^.backing_pixel;
    window_attributes^.save_under := reply^.save_under;
    window_attributes^.colormap := reply^.colormap;
    window_attributes^.map_installed := reply^.map_is_installed;
    window_attributes^.map_state := reply^.map_state;
    window_attributes^.all_event_masks := reply^.all_event_masks;
    window_attributes^.your_event_mask := reply^.your_event_mask;
    window_attributes^.do_not_propagate_mask := reply^.do_not_propagate_mask;
    window_attributes^.override_redirect := reply^.override_redirect;
    writeln('XGetWindowAttributes: override_redirect = ', window_attributes^.override_redirect, ', reply = ', PtrInt(reply));
    free(reply); // Use libc's free
    Result := 1;
  end else begin
    FillChar(window_attributes^, SizeOf(TXWindowAttributes), 0);
    writeln('XGetWindowAttributes: reply is nil');
    Result := 0;
  end;
end;

{
procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl;
var
  xcb_event: Pxcb_generic_event_t;
begin
  xcb_event := xcb_wait_for_event(display);
  if xcb_event <> nil then begin
  writeln('event_return^._type = ',event_return^._type);
    event_return^._type := xcb_event^._type and $7F; // Mask high bit for Xlib type
    // Copy event data (assumes TXEvent is large enough)
    move(xcb_event^, event_return^, sizeof(xcb_generic_event_t));
    free(xcb_event);
  end else
    FillChar(event_return^, sizeof(TXEvent), 0); // Clear on failure
end;
}


//last
// Implementation for XNextEvent
{
function XNextEvent(display: PDisplay; event_return: PXEvent): CInt; cdecl;
var
  generic_event: Pxcb_generic_event_t;
  ge_event: Pxcb_ge_event_t; // For generic events (response_type = 0)
  conn: xcb_connection_t;
  xcb_client_msg: Pxcb_client_message_event_t;
  xcb_key_press_msg: Pxcb_key_press_event_t;
  xcb_expose_msg: Pxcb_expose_event_t;
  raw_bytes: array[0..31] of CUChar; // For raw byte inspection
  j: CInt;
  temp_event_type_bytes: array[0..3] of CUChar; // For manual extraction
  manual_event_type: CUInt; // For manual extraction
begin
  Result := 0; // Default to failure

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XNextEvent: Could not get XCB connection.');
    Exit;
  end;

  // First, try to get an event from the internal queue (filled by XPending)
  if g_event_queue.Count > 0 then
  begin
    generic_event := Pxcb_generic_event_t(g_event_queue.Items[0]);
    g_event_queue.Delete(0); // Remove from queue
  end
  else
  begin
    // If queue is empty, wait for a new event (this will block)
    generic_event := xcb_wait_for_event(conn);
  end;


  if generic_event <> nil then
  begin
    FillChar(event_return^, SizeOf(TXEvent), 0);

    // Determine the actual event type, handling generic events (response_type = 0)
    if (generic_event^._type and $7F) = 0 then // If it's a generic event
    begin
      ge_event := Pxcb_ge_event_t(generic_event); // Cast to generic event structure

      // --- Manual extraction of event_type for debugging (only for GE) ---
      Move(generic_event^, raw_bytes[0], SizeOf(xcb_generic_event_t));
      Move(raw_bytes[8], temp_event_type_bytes[0], 4); // Copy the 4 bytes at offset 8
      // Reconstruct CUInt from bytes (assuming little-endian for now, common on x86)
      manual_event_type := CUInt(temp_event_type_bytes[0]) or
                           (CUInt(temp_event_type_bytes[1]) shl 8) or
                           (CUInt(temp_event_type_bytes[2]) shl 16) or
                           (CUInt(temp_event_type_bytes[3]) shl 24);
      // --- End manual extraction ---

      event_return^._type := CInt(ge_event^.event_type); // Keep original assignment for comparison
      // Only print if it's an unexpected generic event type
      if (event_return^._type <> KeyPress) and (event_return^._type <> ClientMessage) and (event_return^._type <> Expose) then
      begin
        writeln(Format('DEBUG: XNextEvent: Detected XCB_GE_GENERIC. Raw response_type: %d. Manual event_type: %d (0x%x). Actual event_type: %d (from ge_event^.event_type)',
          [generic_event^._type, manual_event_type, manual_event_type, event_return^._type]));
        write('DEBUG: XNextEvent: Raw event bytes (first 16): ');
        for j := 0 to 15 do
          write(Format('%02x ', [raw_bytes[j]]));
        writeln('');
      end;
    end
    else
    begin
      // For standard X events, response_type holds the event type
      event_return^._type := (generic_event^._type and $7F);
      // Only print if it's an unexpected standard event type
      if (event_return^._type <> KeyPress) and (event_return^._type <> ClientMessage) and (event_return^._type <> Expose) then
      begin
        writeln(Format('DEBUG: XNextEvent: Detected standard X event. Raw response_type: %d. Type: %d (from generic_event^.response_type)',
          [generic_event^._type, event_return^._type]));
      end;
    end;

    // Corrected access to common fields via xany
    event_return^.xany.serial := generic_event^.sequence;
    event_return^.xany.send_event := CInt( (generic_event^._type and $80) <> 0 );
    event_return^.xany.display := display;
    // The 'window' field is common, set it in each specific event type case below.
    // For general events (like XAnyEvent), we can set it here if generic_event has a window field.
    // Since generic_event doesn't have a direct 'window' field, it's safer to set it in specific event handlers.


    case event_return^._type of // Use the determined _type field for dispatch
      ClientMessage:
      begin
        xcb_client_msg := Pxcb_client_message_event_t(generic_event);
        writeln('DEBUG: XNextEvent: Detected ClientMessage event.');
        writeln(Format('DEBUG: ClientMessage: Raw response_type: %d, Sequence: %d, Window: %d',
          [xcb_client_msg^._type, xcb_client_msg^.sequence, xcb_client_msg^.window]));

        event_return^.xclient.message_type := xcb_client_msg^.type_;
        event_return^.xclient.format := CInt(xcb_client_msg^.format);
        event_return^.xany.window := TWindow(xcb_client_msg^.window); // Corrected: Set via xany

        // Copy the 20 bytes of data from XCB event to the specific data union within xclient
        Move(xcb_client_msg^.Data, event_return^.xclient.Data.b[0], SizeOf(xcb_client_msg^.Data));

        writeln(Format('DEBUG: ClientMessage: message_type: %d (expected WM_PROTOCOLS: %d)',
          [event_return^.xclient.message_type, g_wm_protocols_atom]));
        writeln(Format('DEBUG: ClientMessage: data.l[0]: %d (expected WM_DELETE_WINDOW: %d)',
          [event_return^.xclient.Data.l[0], g_wm_delete_window_atom]));

        // Check for WM_DELETE_WINDOW protocol message
        if (event_return^.xclient.message_type = g_wm_protocols_atom) and
           (event_return^.xclient.Data.l[0] = g_wm_delete_window_atom) then
        begin
          writeln('DEBUG: ClientMessage: WM_DELETE_WINDOW protocol message received. Signalling exit...');
          // In a real app, this would signal the main loop to exit
        end;

        Result := 1;
      end;

      KeyPress:
      begin
        xcb_key_press_msg := Pxcb_key_press_event_t(generic_event);
        writeln('DEBUG: XNextEvent: Detected KeyPress event.');
        writeln(Format('DEBUG: KeyPress: Raw response_type: %d, Sequence: %d, Window: %d',
          [xcb_key_press_msg^._type, xcb_key_press_msg^.sequence, xcb_key_press_msg^.event]));

        event_return^.xany.window := TWindow(xcb_key_press_msg^.event); // Corrected: Set via xany

        event_return^.xkey.root := xcb_key_press_msg^.root;
        event_return^.xkey.subwindow := xcb_key_press_msg^.child;
        event_return^.xkey.time := xcb_key_press_msg^.time;
        event_return^.xkey.x := xcb_key_press_msg^.event_x;
        event_return^.xkey.y := xcb_key_press_msg^.event_y;
        event_return^.xkey.x_root := xcb_key_press_msg^.root_x;
        event_return^.xkey.y_root := xcb_key_press_msg^.root_y;
        event_return^.xkey.state := xcb_key_press_msg^.state;
        event_return^.xkey.keycode := xcb_key_press_msg^.detail;
        event_return^.xkey.same_screen := CInt(xcb_key_press_msg^.same_screen);

        writeln(Format('DEBUG: KeyPress: Keycode: %d', [event_return^.xkey.keycode]));
        Result := 1;
      end;

      Expose:
      begin
        xcb_expose_msg := Pxcb_expose_event_t(generic_event);
        writeln('DEBUG: XNextEvent: Detected Expose event.');
        writeln(Format('DEBUG: Expose: Raw response_type: %d, Sequence: %d, Window: %d',
          [xcb_expose_msg^._type, xcb_expose_msg^.sequence, xcb_expose_msg^.window]));

        event_return^.xany.window := TWindow(xcb_expose_msg^.window); // Corrected: Set via xany

        event_return^.xexpose.x := xcb_expose_msg^.x;
        event_return^.xexpose.y := xcb_expose_msg^.y;
        event_return^.xexpose.width := xcb_expose_msg^.width;
        event_return^.xexpose.height := xcb_expose_msg^.height;
        event_return^.xexpose.count := xcb_expose_msg^.count;

        writeln(Format('DEBUG: Expose: Window: %d, X: %d, Y: %d, W: %d, H: %d',
          [event_return^.xany.window, event_return^.xexpose.x, event_return^.xexpose.y,
           event_return^.xexpose.width, event_return^.xexpose.height]));
        Result := 1;
      end;

      else // For any other event type not explicitly handled
      begin
        writeln(Format('DEBUG: XNextEvent: Detected unhandled event type: %d', [event_return^._type]));
        // Removed raw bytes dump for unhandled events to reduce clutter
        Result := 1;
      end;
    end;

    free(generic_event); // Always free the XCB-allocated event after processing
  end
  else
  begin
    // Suppress this debug message for nil events
  end;
end;
}

function XNextEvent(display: PDisplay; event_return: PmXEvent): CInt; cdecl;
var
  generic_event: Pxcb_generic_event_t;
  conn: xcb_connection_t;
  // Specific event pointers for casting the generic_event
  xcb_client_msg: Pxcb_client_message_event_t;
  xcb_key_press_msg: Pxcb_key_press_event_t;
  xcb_expose_msg: Pxcb_expose_event_t;
  // Pointers to the Xlib-mimic event structures within event_return^.data
  xany: PmXAnyEvent;
  xclient: Pxcb_client_message_event_t;
  xkey: PXKeyEvent;
  xexpose: Pointer; // For XExposeEvent, if you had a specific type for it
begin
  Result := 0; // Default to failure

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    Exit;
  end;

  // Blocks until an event occurs
  generic_event := xcb_wait_for_event(conn);

  if generic_event <> nil then
  begin
    // Clear the XEvent buffer to avoid old data
    FillChar(event_return^, SizeOf(MXEvent), 0);

    // Get common header pointer for easier access
    xany := PmXAnyEvent(@event_return^.data);

    // Populate common Xlib event header fields
    xany^.display := display;
    // The highest bit (0x80) in response_type indicates if event was sent by client
    xany^.send_event := CInt( (generic_event^.response_type and $80) <> 0 );
    xany^.serial := generic_event^.sequence; // XCB sequence maps to Xlib serial

    case (generic_event^.response_type and $7F) of // Mask out the send_event bit
      ClientMessage:
      begin
        xcb_client_msg := Pxcb_client_message_event_t(generic_event);
        xclient := Pxcb_client_message_event_t(@event_return^.data);

        xany^.event_type := ClientMessage;
        xany^.window := xcb_client_msg^.window;

        xclient^.response_type := xcb_client_msg^.response_type;
        xclient^.format := CInt(xcb_client_msg^.format);

        // Copy the 20 bytes of data from XCB event to Xlib mimic event's data union
        Move(xcb_client_msg^.data, xclient^.data.data32[0], SizeOf(xcb_client_msg^.data));

        Result := 1;
      end;
      KeyPress:
      begin
        xcb_key_press_msg := Pxcb_key_press_event_t(generic_event);
        xkey := PXKeyEvent(@event_return^.data);

        xany^.event_type := KeyPress;
        xany^.window := xcb_key_press_msg^.event; // The window the event occurred in
        xkey^.root := xcb_key_press_msg^.root;
        xkey^.subwindow := xcb_key_press_msg^.child; // Xlib subwindow is XCB child
        xkey^.time := xcb_key_press_msg^.time;
        xkey^.x := xcb_key_press_msg^.event_x;
        xkey^.y := xcb_key_press_msg^.event_y;
        xkey^.x_root := xcb_key_press_msg^.root_x;
        xkey^.y_root := xcb_key_press_msg^.root_y;
        xkey^.state := xcb_key_press_msg^.state;
        xkey^.keycode := xcb_key_press_msg^.detail;
        xkey^.same_screen := xcb_key_press_msg^.same_screen;

        Result := 1;
      end;
      Expose:
      begin
        xcb_expose_msg := Pxcb_expose_event_t(generic_event);
        // If you had a specific XExposeEvent type, you'd cast to it here
        // For now, we'll just set common fields and the window.
        xany^.event_type := Expose;
        xany^.window := xcb_expose_msg^.window;
        // You might want to map x, y, width, height, count from xcb_expose_msg here
        Result := 1;
      end;
      else // For any other event type not explicitly handled, just set the type
      begin
        xany^.event_type := (generic_event^.response_type and $7F);
        // For unhandled types, we can still copy the initial generic header
        // This ensures at least basic info is available if needed.
        Move(generic_event^, event_return^.data[0], SizeOf(xcb_generic_event_t));
        Result := 1;
      end;
    end;

    free(generic_event); // Always free the XCB-allocated event
  end;
end;

{
function XInternAtom(display: PDisplay; atom_name: PAnsiChar; only_if_exists: CInt): Atom; cdecl;
var
  conn: xcb_connection_t;
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
begin
  writeln(Format('DEBUG: XInternAtom called for atom: %s, only_if_exists: %d', [atom_name, only_if_exists]));
  Result := 0;

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XInternAtom: Could not get XCB connection.');
    Exit;
  end;

  cookie := xcb_intern_atom(conn, CUChar(only_if_exists), CUShort(StrLen(atom_name)), atom_name);
  writeln('DEBUG: XInternAtom: xcb_intern_atom called.');
  reply := xcb_intern_atom_reply(conn, cookie, nil); // nil for error means we don't care about the error structure
  if reply <> nil then
  begin
    Result := reply^.atom;
    writeln(Format('DEBUG: XInternAtom: Atom "%s" interned successfully with ID: %d', [atom_name, Result]));
    free(reply);
  end
  else
  begin
    writeln(Format('ERROR: XInternAtom: Failed to intern atom "%s".', [atom_name]));
    Result := 0;
  end;
end;
}
{
function XInternAtom(display: PDisplay; atom_name: PAnsiChar; only_if_exists: CInt): Atom; cdecl;
var
  conn: xcb_connection_t;
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
begin
  writeln(Format('DEBUG: XInternAtom called for atom: "%s", only_if_exists: %d', [atom_name, only_if_exists]));
  Result := 0;

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XInternAtom: Could not get XCB connection.');
    Exit;
  end;

  cookie := xcb_intern_atom(conn, CUChar(only_if_exists), CUShort(StrLen(atom_name)), atom_name);
  // No need to print xcb_intern_atom called, it's implicit.
  reply := xcb_intern_atom_reply(conn, cookie, nil); // nil for error means we don't care about the error structure
  if reply <> nil then
  begin
    Result := reply^.atom;
    writeln(Format('DEBUG: XInternAtom: Atom "%s" interned successfully with ID: %d', [atom_name, Result]));
    // Update global atoms if they are the ones being interned
    if AnsiCompareText(atom_name, 'WM_PROTOCOLS') = 0 then
    begin
      g_wm_protocols_atom := Result;
      writeln(Format('DEBUG: XInternAtom: g_wm_protocols_atom set to: %d', [g_wm_protocols_atom]));
    end
    else if AnsiCompareText(atom_name, 'WM_DELETE_WINDOW') = 0 then
    begin
      g_wm_delete_window_atom := Result;
      writeln(Format('DEBUG: XInternAtom: g_wm_delete_window_atom set to: %d', [g_wm_delete_window_atom]));
    end;
    free(reply);
  end
  else
  begin
    writeln(Format('ERROR: XInternAtom: Failed to intern atom "%s".', [atom_name]));
    Result := 0;
  end;
end;
}

{
// Implementation for XNextEvent
function XNextEvent(display: PDisplay; event_return: PXEvent): CInt; cdecl;
var
  generic_event: Pxcb_generic_event_t;
  ge_event: Pxcb_ge_event_t; // For generic events (response_type = 0)
  conn: xcb_connection_t;
  xcb_client_msg: Pxcb_client_message_event_t;
  xcb_key_press_msg: Pxcb_key_press_event_t;
  xcb_expose_msg: Pxcb_expose_event_t;
  raw_bytes: array[0..31] of CUChar; // For raw byte inspection
  j: CInt;
begin
   writeln('DEBUG: XNextEvent called.');
  Result := 0; // Default to failure

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XNextEvent: Could not get XCB connection.');
    Exit;
  end;

  // First, try to get an event from the internal queue (filled by XPending)
  if g_event_queue.Count > 0 then
  begin
    generic_event := Pxcb_generic_event_t(g_event_queue.Items[0]);
    g_event_queue.Delete(0); // Remove from queue
    writeln(Format('DEBUG: XNextEvent: Retrieved event %p from internal queue. Remaining: %d', [generic_event, g_event_queue.Count]));
  end
  else
  begin
    // If queue is empty, wait for a new event (this will block)
   // writeln('DEBUG: XNextEvent: Internal queue empty. Waiting for event from XCB...');
    generic_event := xcb_wait_for_event(conn);
    writeln(Format('DEBUG: XNextEvent: Received XCB generic event: %p (blocking call)', [generic_event]));
  end;


  if generic_event <> nil then
  begin
    // Dump raw bytes for debugging
      Move(generic_event^, raw_bytes[0], SizeOf(xcb_generic_event_t)); // This copies 32 bytes
write('DEBUG: XNextEvent: Raw event bytes (first 16): '); // Adjusted label
for j := 0 to 15 do // Dump more bytes!
  write(Format('%02x ', [raw_bytes[j]]));
writeln('');
  
   {
    write('DEBUG: XNextEvent: Raw event bytes (first 8): ');
    for j := 0 to 7 do
      write(Format('%02x ', [raw_bytes[j]]));
    writeln('');
    writeln(Format('DEBUG: XNextEvent: Raw generic_event^.response_type: %d', [generic_event^._type]));
    }

    FillChar(event_return^, SizeOf(TXEvent), 0);

    // Determine the actual event type, handling generic events (response_type = 0)
    if (generic_event^._type and $7F) = 0 then // If it's a generic event
    begin
      ge_event := Pxcb_ge_event_t(generic_event); // Cast to generic event structure
      event_return^._type := CInt(ge_event^.event_type); // Use the event_type field
      writeln(Format('DEBUG: XNextEvent: Detected XCB_GE_GENERIC. Actual event_type: %d', [event_return^._type]));
    end
    else
    begin
      // For standard X events, response_type holds the event type
      event_return^._type := (generic_event^._type and $7F);
    end;

    event_return^.serial := generic_event^.sequence;
    event_return^.send_event := CInt( (generic_event^._type and $80) <> 0 );
    event_return^.display := display;
    // The 'window' field is common, but its source depends on the specific event type.
    // We'll set it within the specific event cases.

    writeln(Format('DEBUG: XNextEvent: Processed generic event. Type: %d, Serial: %d, SendEvent: %d',
      [event_return^._type, event_return^.serial, event_return^.send_event]));

    case event_return^._type of // Use the determined _type field for dispatch
      ClientMessage:
      begin
        xcb_client_msg := Pxcb_client_message_event_t(generic_event);
        writeln('DEBUG: XNextEvent: Detected ClientMessage event.');

        event_return^.xclient.message_type := xcb_client_msg^.type_;
        event_return^.xclient.format := CInt(xcb_client_msg^.format);
        event_return^.window := TWindow(xcb_client_msg^.window); // Set common window field

        // Copy the 20 bytes of data from XCB event to the specific data union within xclient
        Move(xcb_client_msg^.Data, event_return^.xclient.Data.b[0], SizeOf(xcb_client_msg^.Data));
       
       {
        writeln(Format('DEBUG: ClientMessage: message_type: %d (expected WM_PROTOCOLS: %d)',
          [event_return^.xclient.message_type, g_wm_protocols_atom]));
        writeln(Format('DEBUG: ClientMessage: data.l[0]: %d (expected WM_DELETE_WINDOW: %d)',
          [event_return^.xclient.Data.l[0], g_wm_delete_window_atom]));

        // Check for WM_DELETE_WINDOW protocol message
        if (event_return^.xclient.message_type = g_wm_protocols_atom) and
           (event_return^.xclient.Data.l[0] = g_wm_delete_window_atom) then
        begin
          writeln('DEBUG: ClientMessage: WM_DELETE_WINDOW protocol message received. Breaking loop...');
          // In a real app, this would signal the main loop to exit
        end;
        }

        Result := 1;
      end;

      KeyPress:
      begin
        xcb_key_press_msg := Pxcb_key_press_event_t(generic_event);
        writeln('DEBUG: XNextEvent: Detected KeyPress event.');

        event_return^.window := TWindow(xcb_key_press_msg^.event); // Set common window field

        event_return^.xkey.root := xcb_key_press_msg^.root;
        event_return^.xkey.subwindow := xcb_key_press_msg^.child;
        event_return^.xkey.time := xcb_key_press_msg^.time;
        event_return^.xkey.x := xcb_key_press_msg^.event_x;
        event_return^.xkey.y := xcb_key_press_msg^.event_y;
        event_return^.xkey.x_root := xcb_key_press_msg^.root_x;
        event_return^.xkey.y_root := xcb_key_press_msg^.root_y;
        event_return^.xkey.state := xcb_key_press_msg^.state;
        event_return^.xkey.keycode := xcb_key_press_msg^.detail;
        event_return^.xkey.same_screen := CInt(xcb_key_press_msg^.same_screen);

        writeln(Format('DEBUG: KeyPress: Keycode: %d', [event_return^.xkey.keycode]));
        Result := 1;
      end;

      Expose:
      begin
        xcb_expose_msg := Pxcb_expose_event_t(generic_event);
        writeln('DEBUG: XNextEvent: Detected Expose event.');

        event_return^.window := TWindow(xcb_expose_msg^.window); // Set common window field

        event_return^.xexpose.x := xcb_expose_msg^.x;
        event_return^.xexpose.y := xcb_expose_msg^.y;
        event_return^.xexpose.width := xcb_expose_msg^.width;
        event_return^.xexpose.height := xcb_expose_msg^.height;
        event_return^.xexpose.count := xcb_expose_msg^.count;

        writeln(Format('DEBUG: Expose: Window: %d, X: %d, Y: %d, W: %d, H: %d',
          [event_return^.window, event_return^.xexpose.x, event_return^.xexpose.y,
           event_return^.xexpose.width, event_return^.xexpose.height]));
        Result := 1;
      end;

      else // For any other event type not explicitly handled
      begin
      //  writeln(Format('DEBUG: XNextEvent: Detected unhandled event type: %d', [event_return^._type]));
        Result := 1;
      end;
    end;

    free(generic_event); // Always free the XCB-allocated event after processing
  end
  else
  begin
    writeln('DEBUG: XNextEvent: generic_event was nil after polling/waiting.');
  end;
end;
}


function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBool; cdecl;
var
  cookie: xcb_query_extension_cookie_t;
  reply: Pxcb_query_extension_reply_t;
begin
  cookie := xcb_query_extension(display, 5, 'SHAPE');
  reply := xcb_query_extension_reply(display, cookie, nil);
  if reply <> nil then begin
    if reply^.present <> 0 then begin
      if event_base <> nil then event_base^ := reply^.first_event;
      if error_base <> nil then error_base^ := reply^.first_error;
      Result := 1; // True, extension is available
    end else
      Result := 0; // False, extension not available
       free(reply);
  end else
    Result := 0; // False, no reply
end;

// Todo
function XLookupString(event_struct: PXKeyPressedEvent; buffer_return: PChar; bytes_buffer: cint; keysym_return: Pculong; status_in_out: Pointer): cint; cdecl;
begin

end;

function XShapeCombineRegion(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; region: TRegion; op: cint): TStatus; cdecl;
begin

end;

function XwcTextListToTextProperty(para1: PDisplay; para2: PPWideChar; para3: cint; para4: TXICCEncodingStyle; para5: PXTextProperty): cint; cdecl;
begin

end;

function XSetSelectionOwner(para1: PDisplay; para2: TAtom; para3: TWindow; para4: TTime): cint; cdecl;
begin

end;

function XDeleteProperty(para1: PDisplay; para2: TWindow; para3: TAtom): cint; cdecl;
begin

end;

function XCheckTypedEvent(para1: PDisplay; para2: cint; para3: PXEvent): TBoolResult; cdecl;
begin

end;

function XConvertSelection(para1: PDisplay; para2: TAtom; para3: TAtom; para4: TAtom; para5: TWindow; para6: TTime): cint; cdecl;
begin

end;

function XGetSelectionOwner(para1: PDisplay; para2: TAtom): TWindow; cdecl;
begin

end;

procedure XFreeStringList(para1: PPchar); cdecl;
begin

end;

function XSync(para1: PDisplay; para2: TBool): cint; cdecl;
begin

end;

function XIconifyWindow(para1: PDisplay; para2: TWindow; para3: cint): TStatus; cdecl;
begin

end;

procedure XSetWMName(para1: PDisplay; para2: TWindow; para3: PXTextProperty); cdecl;
begin

end;

function XGetWMHints(para1: PDisplay; para2: TWindow): PXWMHints; cdecl;
begin

end;

function XAllocWMHints: PXWMHints; cdecl;
begin

end;

function XQueryTree(para1: PDisplay; para2: TWindow; para3: PWindow; para4: PWindow; para5: PPWindow; para6: Pcuint): TStatus; cdecl;
begin

end;

function XRaiseWindow(para1: PDisplay; para2: TWindow): cint; cdecl;
begin

end;

function XLowerWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
begin

end;

function XReconfigureWMWindow(para1: PDisplay; para2: TWindow; para3: cint; para4: cuint; para5: PXWindowChanges): TStatus; cdecl;
begin

end;

function XQueryPointer(para1: PDisplay; para2: TWindow; para3: PWindow; para4: PWindow; para5: Pcint; para6: Pcint; para7: Pcint; para8: Pcint; para9: Pcuint): TBoolResult; cdecl;
begin

end;

function XWarpPointer(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl;
begin

end;

function XUngrabPointer(para1: PDisplay; para2: TTime): cint; cdecl;
begin

end;

function XGrabPointer(para1: PDisplay; para2: TWindow; para3: TBool; para4: cuint; para5: cint; para6: cint; para7: TWindow; para8: TCursor; para9: TTime): cint; cdecl;
begin

end;

function XGetImage(para1: PDisplay; para2: TDrawable; para3: cint; para4: cint; para5: cuint; para6: cuint; para7: culong; para8: cint): PXImage; cdecl;
begin

end;

function XSetGraphicsExposures(para1: PDisplay; para2: TGC; para3: TBool): cint; cdecl;
begin

end;

function XCreateBitmapFromData(ADiplay: PDisplay; ADrawable: TDrawable; AData: PChar; AWidth: cuint; AHeight: cuint): TPixmap; cdecl;
begin

end;

function XCreateFontCursor(ADisplay: PDisplay; AShape: cuint): TCursor; cdecl;
begin

end;

function XDefineCursor(ADisplay: PDisplay; AWindow: TWindow; ACursor: TCursor): cint; cdecl;
begin

end;

function XFreeCursor(ADisplay: PDisplay; ACursor: TCursor): cint; cdecl;
begin

end;

function XSetTransientForHint(ADisplay: PDisplay; AWindow: TWindow; APropWindow: TWindow): cint; cdecl;
begin

end;

function XTranslateCoordinates(ADisplay: PDisplay; ASrcWindow: TWindow; ADestWindow: TWindow; ASrcX: cint; ASrcY: cint; ADestXReturn: Pcint; ADestYReturn: Pcint; AChildReturn: PWindow): TBool; cdecl;
begin

end;

function XDrawRectangle(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint): cint; cdecl;
begin

end;

function XFreeColormap(para1: PDisplay; para2: TColormap): cint; cdecl;
begin

end;

function XGetTransientForHint(para1: PDisplay; para2: TWindow; para3: PWindow): TStatus; cdecl;
begin

end;

function XSetInputFocus(para1: PDisplay; para2: TWindow; para3: cint; para4: TTime): cint; cdecl;
begin

end;

function XCreatePixmapCursor(ADisplay: PDisplay; ASource: TPixmap; AMask: TPixmap; AForegroundColor: PXColor; ABackgroundColor: PXColor; AX: cuint; AY: cuint): TCursor; cdecl;
begin

end;

function XFillRectangle(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint): cint; cdecl;
begin

end;

function XFillArc(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl;
begin

end;

function XDrawArc(para1: PDisplay; para2: TDrawable; para3: TGC; para4: cint; para5: cint; para6: cuint; para7: cuint; para8: cint; para9: cint): cint; cdecl;
begin

end;

{
function XSetWMProtocols(display: PDisplay; w: TWindow; protocols: PAtom; count: cint): LongInt; cdecl;
//function XSetWMProtocols(display: PDisplay; w: XWindow; protocols: PAtom; count: CInt): CInt; cdecl;
var
  cookie: xcb_void_cookie_t;
  error_ptr: Pointer;
begin
  Result := 0; // Default to failure

  if g_xcb_conn = nil then Exit;

  // Use xcb_change_property to set the WM_PROTOCOLS property.
  // Property: WM_PROTOCOLS (atom obtained via XInternAtom)
  // Type: XA_ATOM (standard atom for atom type)
  // Format: 32 (atoms are 32-bit values on XCB)
  // Data: protocols (array of Atom IDs)
  // Data_len: count (number of atoms in the array)
  cookie := xcb_change_property(
    g_xcb_conn,
    PropModeReplace, // Always replace existing protocols
    CUInt(w),        // Window ID
    CUInt(XInternAtom(display, 'WM_PROTOCOLS', 0)), // Property atom
    4,         // Type of data (Atom)
    32,              // Format (32-bit values)
    CUInt(count),    // Number of items
    protocols        // Pointer to the array of Atom IDs
  );

  error_ptr := xcb_request_check(g_xcb_conn, cookie);
  if error_ptr <> nil then
  begin
    free(error_ptr);
    Result := 0; // Failure
  end
  else
  begin
    Result := 1; // Success
  end;
end;
}
{
function XSetWMProtocols(display: PDisplay; w: TWindow; protocols: PAtom; count: cint): LongInt; cdecl;
var
  cookie: xcb_void_cookie_t;
  error_ptr: Pointer;
  i: CInt;
begin
  Result := 0; // Default to failure
   writeln(SysUtils.Format('DEBUG: XSetWMProtocols: Setting protocols for window %x (count: %d)', [w, count]));

  if g_xcb_conn = nil then
  begin
     writeln('DEBUG: XSetWMProtocols: g_xcb_conn is NIL. Cannot set protocols.');
    Exit;
  end;

  // Debugging protocol list
  for i := 0 to count - 1 do
  begin
   //  writeln(SysUtils.Format('DEBUG: XSetWMProtocols: Protocol[%d]: %d', [i, protocols^[i]]));
  
  end;

  // Use xcb_change_property to set the WM_PROTOCOLS property.
  // Property: WM_PROTOCOLS (atom obtained via XInternAtom)
  // Type: XA_ATOM (standard atom for atom type)
  // Format: 32 (atoms are 32-bit values on XCB)
  // Data: protocols (array of Atom IDs)
  // Data_len: count (number of items)
  cookie := xcb_change_property(
    g_xcb_conn,
    PropModeReplace, // Always replace existing protocols
    CUInt(w),        // Window ID
    CUInt(XInternAtom(display, 'WM_PROTOCOLS', 0)), // Property atom (used 0 for False)
    4,         // Type of data (Atom)
    32,              // Format (32-bit values)
    CUInt(count),    // Number of items
    protocols        // Pointer to the array of Atom IDs
  );

  error_ptr := xcb_request_check(g_xcb_conn, cookie);
  if error_ptr <> nil then
  begin
   writeln('DEBUG: XSetWMProtocols: FAILED to set WM_PROTOCOLS property.');
    free(error_ptr);
    Result := 0; // Failure
  end
  else
  begin
     writeln('DEBUG: XSetWMProtocols: Successfully set WM_PROTOCOLS property.');
    Result := 1; // Success
  end;
end;
}

function XSetWMProtocols(display: PDisplay; w: TWindow; protocols: PAtom; count: cint): LongInt; cdecl;
var
  conn: xcb_connection_t;
  cookie: xcb_void_cookie_t;
  error_ptr: Pointer;
  i: CInt;
begin
  writeln(Format('DEBUG: XSetWMProtocols called for window ID: %d, count: %d', [w, count]));
  Result := 0;

  conn := XGetXCBConnection(display);
  if conn = nil then
  begin
    writeln('ERROR: XSetWMProtocols: Could not get XCB connection.');
    Exit;
  end;

  // Intern WM_PROTOCOLS if not already done (it's a property atom)
  if g_wm_protocols_atom = 0 then
  begin
    writeln('DEBUG: XSetWMProtocols: WM_PROTOCOLS atom not yet interned, interning now.');
    g_wm_protocols_atom := XInternAtom(display, 'WM_PROTOCOLS', 0);
  end;

  // Store the WM_DELETE_WINDOW atom (which is passed in protocols[0])
  if (count > 0) and (protocols <> nil) then
  begin
    g_wm_delete_window_atom := protocols^; // Corrected: Use protocols^ to dereference the PAtom
    writeln(Format('DEBUG: XSetWMProtocols: Value of protocols^ (WM_DELETE_WINDOW being set): %d', [protocols^])); // Added debug
  end;

  writeln(Format('DEBUG: XSetWMProtocols: Using WM_PROTOCOLS_ATOM: %d, WM_DELETE_WINDOW_ATOM: %d for property setting',
    [g_wm_protocols_atom, g_wm_delete_window_atom]));


  // Call xcb_change_property to set the WM_PROTOCOLS property on the window
  cookie := xcb_change_property(
    conn,
    XCB_PROP_MODE_REPLACE, // Replace any existing property
    CUInt(w),              // Window ID
    g_wm_protocols_atom,   // The property atom (WM_PROTOCOLS)
    4,                     // The type of the property value (ATOM) 4
    32,                    // Format: 32-bit data
    CUInt(count),          // Number of atoms in the data array
    protocols              // Pointer to the array of atoms (e.g., WM_DELETE_WINDOW)
  );
  writeln('DEBUG: XSetWMProtocols: xcb_change_property called.');

  error_ptr := xcb_request_check(conn, cookie);
  if error_ptr <> nil then
  begin
    writeln('ERROR: XSetWMProtocols: xcb_change_property failed.');
    free(error_ptr);
    Result := 0;
  end
  else
  begin
    writeln('DEBUG: XSetWMProtocols: WM_PROTOCOLS property set successfully.');
    Result := 1;
  end;
end;


function XDestroyWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
var
  cookie: xcb_void_cookie_t;
  error_ptr: Pointer;
begin
  Result := 0; // Default to failure

  if g_xcb_conn = nil then Exit;

  cookie := xcb_destroy_window(g_xcb_conn, CUInt(AWindow));
  error_ptr := xcb_request_check(g_xcb_conn, cookie);
  if error_ptr <> nil then
  begin
    free(error_ptr);
    Result := 0; // Failure
  end
  else
  begin
    Result := 1; // Success
  end;
end;

function XGetWMNormalHints(display: PDisplay; w: TWindow; hints_return: PXSizeHints; supplied_return: PLongInt): LongInt; cdecl;
var
  wm_normal_hints: xcb_atom_t;
  cookie: xcb_get_property_cookie_t;
  reply: Pxcb_get_property_reply_t;
  atom_cookie: xcb_intern_atom_cookie_t;
  atom_reply: Pxcb_intern_atom_reply_t;
begin
  if hints_return = nil then begin
    writeln('XGetWMNormalHints: hints_return is nil');
    Result := 0;
    Exit;
  end;
  writeln('XGetWMNormalHints: hints_return = ', PtrInt(hints_return));
  atom_cookie := xcb_intern_atom(display, 0, Length('WM_NORMAL_HINTS'), 'WM_NORMAL_HINTS');
  atom_reply := xcb_intern_atom_reply(display, atom_cookie, nil);
  if atom_reply = nil then begin
    writeln('XGetWMNormalHints: atom_reply is nil');
    Result := 0;
    Exit;
  end;
  wm_normal_hints := atom_reply^.atom;
  writeln('XGetWMNormalHints: wm_normal_hints = ', wm_normal_hints);
  free(atom_reply);
  cookie := xcb_get_property(display, 0, w, wm_normal_hints, wm_normal_hints, 0, 18);
  reply := xcb_get_property_reply(display, cookie, nil);
  if (reply <> nil) and (reply^.value_len > 0) then begin
    Move(xcb_get_property_value(reply)^, hints_return^, SizeOf(XSizeHints));
    if supplied_return <> nil then
      supplied_return^ := hints_return^.flags;
    writeln('XGetWMNormalHints: flags = ', hints_return^.flags, ', reply = ', PtrInt(reply), ', value_len = ', reply^.value_len);
    free(reply);
    Result := 1;
  end else begin
    free(reply);
    FillChar(hints_return^, SizeOf(XSizeHints), 0);
    if supplied_return <> nil then
      supplied_return^ := 0;
    writeln('XGetWMNormalHints: reply is nil or empty');
    Result := 0;
  end;
end;

function XUnmapWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
begin

end;

function XReparentWindow(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint): cint; cdecl;
begin

end;

function XBell(para1: PDisplay; para2: cint): cint; cdecl;
begin

end;

function XScreenNumberOfScreen(para1: PScreen): cint; cdecl;
begin

end;

function XCheckTypedWindowEvent(para1: PDisplay; para2: TWindow; para3: cint; para4: PXEvent): TBoolResult; cdecl;
var
  event: Pxcb_generic_event_t;
begin
  event := xcb_poll_for_event(para1);
  if event = nil then begin
    writeln('XCheckTypedWindowEvent: no event');
    Result := false;
    Exit;
  end;
  if (event^.response_type and $7F) = para3 then begin
    Move(event^, para4^, SizeOf(TXEvent));
    writeln('XCheckTypedWindowEvent: event_type = ', para3);
    free(event);
    Result := true;
  end else begin
    free(event);
    Result := false;
  end;
end;

function XPeekEvent(ADisplay: PDisplay; AEvent: PXEvent): cint; cdecl;
begin

end;

function XFilterEvent(para1: PXEvent; para2: TWindow): TBoolResult; cdecl;
begin

end;

function XRefreshKeyboardMapping(para1: PXMappingEvent): cint; cdecl;
begin

end;

function XGetErrorText(para1: PDisplay; para2: cint; para3: PChar; para4: cint): cint; cdecl;
begin

end;

function XStoreColors(para1: PDisplay; para2: TColormap; para3: PXColor; para4: cint): cint; cdecl;
begin

end;

function XSupportsLocale: TBool; cdecl;
begin

end;

function XSetClipRectangles(para1: PDisplay; para2: TGC; para3: cint; para4: cint; para5: PXRectangle; para6: cint; para7: cint): cint; cdecl;
begin

end;

function XSetDashes(para1: PDisplay; para2: TGC; para3: cint; para4: PChar; para5: cint): cint; cdecl;
begin

end;

function XChangeGC(display: PDisplay; gc: TGC; valuemask: LongWord; values: Pointer): LongInt; cdecl;
var
  gc_id: LongWord;
begin
  if gc = nil then begin
    writeln('XChangeGC: gc is nil');
    Result := 0;
    Exit;
  end;
  if values = nil then begin
    writeln('XChangeGC: values is nil');
    Result := 0;
    Exit;
  end;
  try
    gc_id := PLongWord(gc)^;
    writeln('XChangeGC: gc_id = ', gc_id, ', valuemask = ', valuemask, ', values = ', PtrInt(values));
    xcb_change_gc(display, gc_id, valuemask, values);
  except
    writeln('XChangeGC: failed, gc = ', PtrInt(gc), ', values = ', PtrInt(values));
    Result := 0;
    Exit;
  end;
  Result := 0;
end;

function XSetClipMask(para1: PDisplay; para2: TGC; para3: TPixmap): cint; cdecl;
begin

end;

function XFreeFontInfo(para1: PPchar; para2: PXFontStruct; para3: cint): cint; cdecl;
begin

end;

function XUnloadFont(para1: PDisplay; para2: TFont): cint; cdecl;
begin

end;

function XSetFunction(para1: PDisplay; para2: TGC; para3: cint): cint; cdecl;
begin

end;

function XCopyPlane(para1: PDisplay; para2: TDrawable; para3: TDrawable; para4: TGC; para5: cint; para6: cint; para7: cuint; para8: cuint; para9: cint; para10: cint; para11: culong): cint; cdecl;
begin

end;

function XCopyGC(para1: PDisplay; para2: TGC; para3: culong; para4: TGC): cint; cdecl;
begin

end;

function XDrawLines(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXPoint; para5: cint; para6: cint): cint; cdecl;
begin

end;

function XDrawSegments(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXSegment; para5: cint): cint; cdecl;
begin

end;

function XSetClipOrigin(para1: PDisplay; para2: TGC; para3: cint; para4: cint): cint; cdecl;
begin

end;

function XFillPolygon(para1: PDisplay; para2: TDrawable; para3: TGC; para4: PXPoint; para5: cint; para6: cint; para7: cint): cint; cdecl;
begin

end;

function XCreateRegion: TRegion; cdecl;
begin

end;

function XUnionRectWithRegion(para1: PXRectangle; para2: TRegion; para3: TRegion): cint; cdecl;
begin

end;

function XDestroyRegion(para1: TRegion): cint; cdecl;
begin

end;

function XEmptyRegion(para1: TRegion): cint; cdecl;
begin

end;

function XClipBox(para1: TRegion; para2: PXRectangle): cint; cdecl;
begin

end;

function XUnionRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl;
begin

end;

function XOffsetRegion(para1: TRegion; para2: cint; para3: cint): cint; cdecl;
begin

end;

function XSubtractRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl;
begin

end;

function XIntersectRegion(para1: TRegion; para2: TRegion; para3: TRegion): cint; cdecl;
begin

end;

// Todo from Xrandr

function XRRGetScreenResources(dpy: pDisplay; window: Window): pXRRScreenResources; cdecl;
begin

end;

procedure XRRFreeScreenResources(resources: pXRRScreenResources); cdecl;
begin

end;

function XRRGetCrtcInfo(dpy: pDisplay; resources: pXRRScreenResources; crtc: RRCrtc): pXRRCrtcInfo; cdecl;
begin

end;

procedure XRRFreeCrtcInfo(crtcInfo: pXRRCrtcInfo); cdecl;
begin

end;

function XRRGetOutputInfo(dpy: pDisplay; resources: pXRRScreenResources; output: RROutput): pXRROutputInfo; cdecl;
begin

end;

procedure XRRFreeOutputInfo(outputInfo: pXRROutputInfo); cdecl;
begin

end;

procedure XRRSelectInput(dpy: pDisplay; window: Window; mask: cint); cdecl;
begin

end;

function XRRUpdateConfiguration(event: pXEvent): cint; cdecl;
begin

end;

function XSetForeground(Display: PDisplay; GC: TGC; Foreground: culong): cint; cdecl;
begin

end;

procedure XDrawImageString(Display: PDisplay; D: TDrawable; GC: TGC; X, Y: integer; S: PChar; Len: integer); cdecl;
begin

end;

procedure XDrawImageString16(Display: PDisplay; D: TDrawable; GC: TGC; X, Y: integer; S: Pxchar2b; Len: integer); cdecl;
begin

end;

function XCloseIM(IM: XIM): TStatus; cdecl;
begin

end;

procedure XDestroyIC(IC: XIC); cdecl;
begin

end;

function XSetLocaleModifiers(modifier_list: PChar): PChar; cdecl;
begin

end;

procedure XUnsetICFocus(IC: XIC); cdecl;
begin

end;

function Xutf8LookupString(IC: XIC; Event: PXKeyPressedEvent; BufferReturn: PChar; CharsBuffer: longint; KeySymReturn: PKeySym; StatusReturn: PStatus): longint; cdecl;
begin

end;

function Xutf8TextListToTextProperty(para1: PDisplay; para2: PPchar; para3: integer; para4: integer{TXICCEncodingStyle}; para5: PXTextProperty): integer; cdecl;
begin

end;

function Xutf8TextPropertyToTextList(para1: PDisplay; para2: PXTextProperty; para3: PPPchar; para4: pinteger): integer; cdecl;
begin

end;

procedure XRenderSetPictureClipRectangles(dpy:PDisplay; picture:TPicture;
            xOrigin:longint; yOrigin:longint; rects:PXRectangle; n:longint); cdecl;
begin

end;

procedure XRenderSetPictureClipRegion(dpy: pDisplay; picture: TPicture; r: regionty); cdecl;
begin

end;

procedure XRenderFillRectangle(dpy: PDisplay; op: longint; dst: TPicture; color: PXRenderColor; x: longint;
                           y: longint; width: dword; height: dword);cdecl;
begin

end;
                           
procedure XRenderSetPictureTransform(dpy:PDisplay; picture:TPicture; transform:PXTransform); cdecl;
begin

end;

procedure XRenderSetPictureFilter(dpy:PDisplay; picture:TPicture; filter: pchar; params: pinteger; nparams: integer); cdecl;
begin

end;

function XRenderCreateSolidFill(dpy: pDisplay; color: pXRenderColor): TPicture; cdecl;
begin

end;

function XRenderQueryExtension(dpy: PDisplay; event_basep: Pinteger; error_basep: Pinteger): TBool;cdecl;
begin
result := 0;
end;

function XRenderFindVisualFormat(dpy: PDisplay; visual: PVisual): PXRenderPictFormat;cdecl;
begin

end;

function XRenderFindStandardFormat(dpy: PDisplay; format: longint): PXRenderPictFormat; cdecl;
begin

end;

function XRenderFindFormat(dpy: PDisplay; mask: culong; templ: PXRenderPictFormat; count: longint): PXRenderPictFormat; cdecl;
begin

end;

procedure XRenderCompositeTriangles(dpy: pDisplay; op: cint; src: tPicture; dst: tPicture; maskFormat: pXRenderPictFormat;
                  xSrc: cint; ySrc: cint; triangles: pXTriangle; ntriangle: cint); cdecl;
begin

end;

procedure XRenderCompositeTriStrip(dpy: pdisplay; op: cint; src: tpicture; dst: tpicture; maskFormat: PXRenderPictFormat;
               xSrc: cint; ySrc: cint; points: PXPointFixed; npoint: cint); cdecl;
begin

end;

procedure XRenderCompositeTriFan(dpy: pdisplay; op: cint; src: tpicture; dst: tpicture; maskFormat: PXRenderPictFormat;
               xSrc: cint; ySrc: cint; points: PXPointFixed; npoint: cint); cdecl;
begin

end;

procedure XRenderChangePicture(dpy: pdisplay; picture: tpicture; valuemask: culong; attributes: PXRenderPictureAttributes); cdecl;
begin

end;

procedure XSetICFocus(IC: XIC); cdecl;
begin

end;

// Macros

function ScreenOfDisplay(dpy: PDisplay; scr: cint): PScreen;
begin
  ScreenOfDisplay := @(((PXPrivDisplay(dpy))^.screens)[scr]);
end;

function WhitePixel(dpy: PDisplay; scr: cint): culong;
begin
  WhitePixel := (ScreenOfDisplay(dpy, scr))^.white_pixel;
end;

function DefaultScreen(dpy: PDisplay): cint;
begin
  DefaultScreen := (PXPrivDisplay(dpy))^.default_screen;
end;

function XSync(para1: PDisplay; para2: Boolean): cint;
begin
  Result := XSync(Para1, (Para2));
end;

function XSendEvent(para1: PDisplay; para2: TWindow; para3: Boolean; para4: clong; para5: PXEvent): TStatus;
begin
  Result := XSendEvent(para1, para2, (Para3), para4, para5);
end;

function DefaultDepthOfScreen(s: PScreen): cint;
begin
  DefaultDepthOfScreen := s^.root_depth;
end;

function XDestroyImage(ximage: PXImage): Longint; cdecl;
begin
  XDestroyImage := ximage^.f.destroy_image(ximage);
end;

function getxrandrlib: Boolean;
begin
  Result := True;
end;

// Helper to calculate bits per pixel based on format and depth
function CalculateBitsPerPixel(AFormat: CInt; ADepth: CInt): CInt;
begin
  case AFormat of
    XYBitmap: Result := 1;
    ZPixmap: Result := ADepth; // For ZPixmap, bits per pixel is typically the depth
    else Result := 0; // Unknown or unsupported format
  end;
end;

// Helper to calculate bytes per line if not provided
function CalculateBytesPerLine(AWidth: CUInt; ABitsPerPixel: CInt; ABitmapPad: CInt): CInt;
var
  bits_per_line: CInt;
begin
  bits_per_line := AWidth * ABitsPerPixel;
  // Pad to the next multiple of bitmap_pad
  Result := (bits_per_line + ABitmapPad - 1) div ABitmapPad * (ABitmapPad div 8);
end;

// --- Implementations for TXImage.f functions (moved above XCreateImage) ---

function XImage_create_image(para1: PDisplay; para2: PVisual; para3: CUInt; para4: CInt; para5: CInt; para6: PChar; para7: CUInt; para8: CUInt; para9: CInt; para10: CInt): PXImage; cdecl;
begin
  // This function pointer should point back to the main XCreateImage function.
  // This allows Xlib's XImage functions to create new XImages consistently.
  Result := XCreateImage(para1, para2, para3, para4, para5, para6, para7, para8, para9, para10);
end;

function XImage_destroy_image(para1: PXImage): CInt; cdecl;
begin
  Result := 0; // Indicate failure by default

  if para1 = nil then Exit;

  // If the Data was allocated by XCreateImage (i.e., obdata points to Data), free it.
  // In our current XCreateImage, if Data is nil on input, we allocate it and obdata points to it.
  // If Data was provided by the user, we should NOT free it.
  // A simple way to track this is to set obdata to Data if allocated internally, else nil.
  if (para1^.obdata <> nil) and (para1^.obdata = Pointer(para1^.Data)) then
  begin
    FreeMem(para1^.Data);
    para1^.Data := nil;
  end;

  // Dispose of the TXImage record itself
  Dispose(para1);
  Result := 1; // Indicate success
end;

function XImage_get_pixel(para1: PXImage; para2: CInt; para3: CInt): CULong; cdecl;
var
  byte_offset: CInt;
  bit_offset_in_byte: CInt;
  pixel_value: CULong;
  byte_data: CUChar;
  mask_size: CInt;
  shift: CInt;
  byte_idx: CInt;
begin
  Result := 0; // Default to 0

  if (para1 = nil) or (para1^.Data = nil) then Exit;
  if (para2 < 0) or (para2 >= para1^.Width) or (para3 < 0) or (para3 >= para1^.Height) then Exit;

  // Calculate the starting bit position of the pixel
  // xoffset is usually 0 for ZPixmap, but can be non-zero for XYPixmap
  // We are assuming ZPixmap for simplicity in pixel packing.
  // For XYBitmap, bits_per_pixel is 1.

  case para1^.format of
    ZPixmap:
      begin
        // Calculate byte offset to the start of the pixel's data
        byte_offset := para3 * para1^.bytes_per_line + (para2 * para1^.bits_per_pixel div 8);
        bit_offset_in_byte := (para2 * para1^.bits_per_pixel) mod 8;

        if byte_offset + (para1^.bits_per_pixel div 8) > para1^.bytes_per_line * para1^.Height then Exit; // Bounds check

        pixel_value := 0;
        mask_size := para1^.bits_per_pixel;

        // Read bytes based on bits_per_pixel and byte_order
        case para1^.bits_per_pixel of
          1..8: // 1 byte
            begin
              byte_data := CUChar(para1^.Data[byte_offset]);
              if para1^.bitmap_bit_order = LSBFirst then
                shift := bit_offset_in_byte
              else // MSBFirst
                shift := 8 - (bit_offset_in_byte + mask_size); // Adjust for MSB first within byte

              pixel_value := (byte_data shr shift) and ((1 shl mask_size) - 1);
            end;
          9..16: // 2 bytes
            begin
              if para1^.byte_order = LSBFirst then
                pixel_value := CULong(Word(para1^.Data[byte_offset+1]) shl 8) or CULong(Word(para1^.Data[byte_offset]))
              else // MSBFirst
                pixel_value := CULong(Word(para1^.Data[byte_offset]) shl 8) or CULong(Word(para1^.Data[byte_offset+1]));
            end;
          17..24: // 3 bytes (common for 24-bit, often padded to 32)
            begin
              // Read 3 bytes, handle byte order
              if para1^.byte_order = LSBFirst then
                pixel_value := (CULong(para1^.Data[byte_offset+2]) shl 16) or
                               (CULong(para1^.Data[byte_offset+1]) shl 8) or
                                CULong(para1^.Data[byte_offset])
              else // MSBFirst
                pixel_value := (CULong(para1^.Data[byte_offset]) shl 16) or
                               (CULong(para1^.Data[byte_offset+1]) shl 8) or
                                CULong(para1^.Data[byte_offset+2]);
            end;
          25..32: // 4 bytes
            begin
              if para1^.byte_order = LSBFirst then
                pixel_value := (CULong(para1^.Data[byte_offset+3]) shl 24) or
                               (CULong(para1^.Data[byte_offset+2]) shl 16) or
                               (CULong(para1^.Data[byte_offset+1]) shl 8) or
                                CULong(para1^.Data[byte_offset])
              else // MSBFirst
                pixel_value := (CULong(para1^.Data[byte_offset]) shl 24) or
                               (CULong(para1^.Data[byte_offset+1]) shl 16) or
                               (CULong(para1^.Data[byte_offset+2]) shl 8) or
                                CULong(para1^.Data[byte_offset+3]);
            end;
          else // Handle other bit depths or error
            Exit;
        end;

        // Apply masks if visual is TrueColor and masks are provided
        if (para1^.red_mask <> 0) or (para1^.green_mask <> 0) or (para1^.blue_mask <> 0) then
        begin
          // This is a simplified approach. Proper mask application involves
          // shifting and combining based on mask positions.
          // For now, assume pixel_value already contains the combined RGB.
          // If the image is 24-bit RGB (0xRRGGBB), the masks help extract components.
          // For a direct pixel value, we might just return it.
        end;

        Result := pixel_value;
      end;
    XYBitmap: // 1 bit per pixel, packed
      begin
        byte_offset := para3 * para1^.bytes_per_line + (para2 div 8);
        bit_offset_in_byte := para2 mod 8;

        if byte_offset >= para1^.bytes_per_line * para1^.Height then Exit; // Bounds check

        byte_data := CUChar(para1^.Data[byte_offset]);

        if para1^.bitmap_bit_order = LSBFirst then
          shift := bit_offset_in_byte
        else // MSBFirst
          shift := 7 - bit_offset_in_byte;

        Result := (byte_data shr shift) and 1; // Get the single bit
      end;
    else
      // Unsupported format or error
      Result := 0;
  end;
end;

function XImage_put_pixel(para1: PXImage; para2: CInt; para3: CInt; para4: CULong): CInt; cdecl;
var
  byte_offset: CInt;
  bit_offset_in_byte: CInt;
  byte_data: CUChar;
  mask_size: CInt;
  shift: CInt;
  pixel_val_to_write: CULong;
begin
  Result := 0; // Default to failure

  if (para1 = nil) or (para1^.Data = nil) then Exit;
  if (para2 < 0) or (para2 >= para1^.Width) or (para3 < 0) or (para3 >= para1^.Height) then Exit;

  case para1^.format of
    ZPixmap:
      begin
        byte_offset := para3 * para1^.bytes_per_line + (para2 * para1^.bits_per_pixel div 8);
        bit_offset_in_byte := (para2 * para1^.bits_per_pixel) mod 8;

        if byte_offset + (para1^.bits_per_pixel div 8) > para1^.bytes_per_line * para1^.Height then Exit; // Bounds check

        pixel_val_to_write := para4;
        mask_size := para1^.bits_per_pixel;

        case para1^.bits_per_pixel of
          1..8: // 1 byte
            begin
              byte_data := CUChar(para1^.Data[byte_offset]);
              if para1^.bitmap_bit_order = LSBFirst then
                shift := bit_offset_in_byte
              else // MSBFirst
                shift := 8 - (bit_offset_in_byte + mask_size);

              // Clear bits at position, then set new bits
              byte_data := byte_data and not (CUChar((1 shl mask_size) - 1) shl shift);
              byte_data := byte_data or (CUChar(pixel_val_to_write and ((1 shl mask_size) - 1)) shl shift);
              para1^.Data[byte_offset] := Char(byte_data);
            end;
          9..16: // 2 bytes
            begin
              if para1^.byte_order = LSBFirst then
              begin
                para1^.Data[byte_offset] := Char(pixel_val_to_write and $FF);
                para1^.Data[byte_offset+1] := Char((pixel_val_to_write shr 8) and $FF);
              end
              else // MSBFirst
              begin
                para1^.Data[byte_offset] := Char((pixel_val_to_write shr 8) and $FF);
                para1^.Data[byte_offset+1] := Char(pixel_val_to_write and $FF);
              end;
            end;
          17..24: // 3 bytes
            begin
              if para1^.byte_order = LSBFirst then
              begin
                para1^.Data[byte_offset] := Char(pixel_val_to_write and $FF);
                para1^.Data[byte_offset+1] := Char((pixel_val_to_write shr 8) and $FF);
                para1^.Data[byte_offset+2] := Char((pixel_val_to_write shr 16) and $FF);
              end
              else // MSBFirst
              begin
                para1^.Data[byte_offset] := Char((pixel_val_to_write shr 16) and $FF);
                para1^.Data[byte_offset+1] := Char((pixel_val_to_write shr 8) and $FF);
                para1^.Data[byte_offset+2] := Char(pixel_val_to_write and $FF);
              end;
            end;
          25..32: // 4 bytes
            begin
              if para1^.byte_order = LSBFirst then
              begin
                para1^.Data[byte_offset] := Char(pixel_val_to_write and $FF);
                para1^.Data[byte_offset+1] := Char((pixel_val_to_write shr 8) and $FF);
                para1^.Data[byte_offset+2] := Char((pixel_val_to_write shr 16) and $FF);
                para1^.Data[byte_offset+3] := Char((pixel_val_to_write shr 24) and $FF);
              end
              else // MSBFirst
              begin
                para1^.Data[byte_offset] := Char((pixel_val_to_write shr 24) and $FF);
                para1^.Data[byte_offset+1] := Char((pixel_val_to_write shr 16) and $FF);
                para1^.Data[byte_offset+2] := Char((pixel_val_to_write shr 8) and $FF);
                para1^.Data[byte_offset+3] := Char(pixel_val_to_write and $FF);
              end;
            end;
          else // Handle other bit depths or error
            Exit;
        end;
        Result := 1; // Success
      end;
    XYBitmap: // 1 bit per pixel, packed
      begin
        byte_offset := para3 * para1^.bytes_per_line + (para2 div 8);
        bit_offset_in_byte := para2 mod 8;

        if byte_offset >= para1^.bytes_per_line * para1^.Height then Exit; // Bounds check

        byte_data := CUChar(para1^.Data[byte_offset]);

        if para1^.bitmap_bit_order = LSBFirst then
          shift := bit_offset_in_byte
        else // MSBFirst
          shift := 7 - bit_offset_in_byte;

        if (para4 and 1) = 1 then // If pixel value is 1, set the bit
          byte_data := byte_data or (1 shl shift)
        else // If pixel value is 0, clear the bit
          byte_data := byte_data and not (1 shl shift);

        para1^.Data[byte_offset] := Char(byte_data);
        Result := 1; // Success
      end;
    else
      // Unsupported format or error
      Result := 0;
  end;
end;

function XImage_sub_image(para1: PXImage; para2: CInt; para3: CInt; para4: CUInt; para5: CUInt): PXImage; cdecl;
var
  new_image: PXImage;
  src_x, src_y, dest_x, dest_y: CInt;
  pixel_value: CULong;
begin
  Result := nil; // Default to nil

  if (para1 = nil) or (para1^.Data = nil) then Exit;
  // Check if sub-image region is within bounds of the original image
  if (para2 < 0) or (para3 < 0) or
     (para2 + para4 > para1^.Width) or (para3 + para5 > para1^.Height) then
  begin
    Exit; // Sub-image out of bounds
  end;

  // Create a new XImage for the sub-image.
  // We pass nil for Data, so XCreateImage will allocate new memory.
  new_image := XCreateImage(
    nil, // Display is not strictly needed for client-side image creation, pass nil
    PVisual(para1^.obdata), // Re-use the visual pointer if stored in obdata, or pass nil
    para1^.depth,
    para1^.format,
    0, // xoffset for sub-image is typically 0
    nil, // XCreateImage will allocate data for us
    para4, para5, // New width and height
    para1^.bitmap_pad,
    0 // Let XCreateImage calculate bytes_per_line
  );

  if new_image = nil then Exit;

  // Copy pixel data from the original image to the new sub-image
  for dest_y := 0 to CInt(para5) - 1 do
  begin
    for dest_x := 0 to CInt(para4) - 1 do
    begin
      src_x := para2 + dest_x;
      src_y := para3 + dest_y;

      pixel_value := XImage_get_pixel(para1, src_x, src_y);
      XImage_put_pixel(new_image, dest_x, dest_y, pixel_value);
    end;
  end;

  Result := new_image;
end;

function XImage_add_pixel(para1: PXImage; para2: CLong): CInt; cdecl;
var
  x, y: CInt;
  current_pixel: CULong;
begin
  Result := 0; // Default to failure

  if (para1 = nil) or (para1^.Data = nil) then Exit;

  // Iterate through all pixels and add the value
  for y := 0 to para1^.Height - 1 do
  begin
    for x := 0 to para1^.Width - 1 do
    begin
      current_pixel := XImage_get_pixel(para1, x, y);
      // Add the value. Be careful with overflow/underflow for signed CLong.
      // For simplicity, we'll just add it directly.
      XImage_put_pixel(para1, x, y, current_pixel + CULong(para2));
    end;
  end;

  Result := 1; // Success
end;

function XGetXCBConnection(display: PDisplay): xcb_connection_t;
begin
  // Since PDisplay is just a Pointer to our xcb_connection_t,
  // we can simply cast it back.
  Result := xcb_connection_t(display);
end;

end.
