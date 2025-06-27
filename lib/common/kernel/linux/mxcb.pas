unit mxcb;

 {$mode objfpc}{$h+}

interface

uses
 mseguiglob, ctypes; // For culong, cint, cuint, cshort, cchar, cuchar

{$PACKRECORDS C}
const
  libxcb        = 'libxcb.so.1';
  libxcb_shape  = 'libxcb-shape.so.0';
  libxcb_render = 'libxcb-render.so.0';
  libxcb_randr  = 'libxcb-randr.so.0';

type
  xcb_connection_t  = record
  end; // Opaque structure
  Pxcb_connection_t = ^xcb_connection_t;
  PDisplay          = Pxcb_connection_t; // Alias for XCB connection

  xcb_generic_error_t = record
    response_type: cuint8;
    error_code: cuint8;
    sequence: cuint16;
    resource_id: cuint32;
    minor_code: cuint16;
    major_code: cuint8;
    pad0: cuint8;
    pad: array[0..4] of cuint32;
  end;
  Pxcb_generic_error_t  = ^xcb_generic_error_t;
  PPxcb_generic_error_t = ^Pxcb_generic_error_t;

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

  _XIM = record
  end;
  XIM  = ^_XIM;
  _XIC = record
  end;
  XIC  = ^_XIC;

  // XID type for mxrandr.pas
  txid = culong;
  pxid = ^txid;

  Time  = culong;
  TTime = culong;
  PTime = ^TTime;

  Window   = cuint; // Maps to xcb_window_t
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

  Atom      = cuint;      // Maps to xcb_atom_t
  PAtom     = ^Atom;
  Colormap  = cuint;      // Maps to xcb_colormap_t
  TColormap = Colormap;   // For mseguiintf.pas
  Pixmap    = cuint;      // Maps to xcb_pixmap_t
  TPixmap   = Pixmap;     // For mshape.pas
  Font      = cuint;      // Maps to xcb_font_t
  TKeySym   = culong;
  PKeySym   = ^TKeySym;
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

  XSetWindowAttributes = record
    background_pixel: culong;
    event_mask: clong;
    colormap: Colormap;
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
  xcb_window_t   = cuint;
  xcb_gcontext_t = cuint;
  xcb_visualid_t = cuint;
  xcb_colormap_t = cuint;
  xcb_pixmap_t   = cuint;
  xcb_font_t     = cuint;
  xcb_atom_t     = cuint;
  xcb_region_t   = Pointer;
 
   xcb_get_atom_name_reply_t = record
    name_len: cuint16;
    Name: PChar;
  end;

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
  TAtom   = culong;
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

  PXIM = ^TXIM;
  TXIM = record
  end;

  PXIC = ^TXIC;
  TXIC = record
  end;

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

   Pxcb_screen_t = ^xcb_screen_t;
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
  pXRROutputInfo = ^XRROutputInfo;

  TXErrorHandler = function(para1: PDisplay; para2: PXErrorEvent): cint; cdecl;

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

var
  GlobalXCBConnection: PDisplay;
  g_screen: TScreen; // Global to store screen data
  g_randreventbase: cint = 0;
  g_randrerrorbase: cint = 0;
  //g_errorhandler: XErrorHandler = nil;
  g_errorhandler: pointer = nil;
  g_root_visual: Visual;


function XOpenDisplay(display_name: PChar): PDisplay; cdecl;
procedure XCloseDisplay(display: PDisplay); cdecl;
function XDefaultScreen(display: PDisplay): cint; cdecl;
function XDefaultVisual(display: PDisplay; screen_number: cint): PVisual; cdecl;

function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; Width, Height, 
          border_width: cuint; depth: cint; window_class: cuint; visual: PVisual;
           valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl;

//function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; width, height, 
//border_width: cuint; depth: cint; _class: cuint; visual: PVisual; valuemask: culong; values: Pointer): Window;


procedure XMapWindow(display: PDisplay; w: Window); cdecl;
procedure XSelectInput(display: PDisplay; w: Window; event_mask: clong); cdecl;
procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl;
function XPending(display: PDisplay): cint; cdecl;
function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;

function XInternAtoms(para1: PDisplay; para2: PPchar; para3: cint; para4: TBool; para5: PAtom): TStatus; cdecl;
function XGetWindowProperty(display: PDisplay; w: Window; atom_property: Atom; long_offset, long_length: culong; Delete: TBool; req_type: Atom; actual_type_return: PAtom; actual_format_return: Pcint;
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
//function XRenderCreatePicture(dpy:PDisplay; drawable:TDrawable; format: PXRenderPictFormat; valuemask: culong;
//            attributes: PXRenderPictureAttributes): TPicture; cdecl;
procedure XRenderFillRectangle(dpy: PDisplay; op: longint; dst: TPicture; color: PXRenderColor; x: longint;
                           y: longint; width: dword; height: dword);cdecl;
procedure XRenderSetPictureTransform(dpy:PDisplay; picture:TPicture; transform:PXTransform); cdecl;
procedure XRenderSetPictureFilter(dpy:PDisplay; picture:TPicture; filter: pchar; params: pinteger; nparams: integer); cdecl;
function XRenderCreateSolidFill(dpy: pDisplay; color: pXRenderColor): TPicture; cdecl;

//procedure XRenderFreePicture(dpy:PDisplay; picture:TPicture);  cdecl;
//procedure XRenderComposite(dpy:PDisplay; op:longint; src:TPicture;  mask:TPicture; dst:TPicture; src_x:longint; src_y:longint;
//          mask_x:longint; mask_y:longint; dst_x:longint; dst_y:longint; width:dword; height:dword);cdecl;
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
function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBoolResult; cdecl;
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
function XGetWindowAttributes(para1: PDisplay; para2: TWindow; para3: PXWindowAttributes): TStatus; cdecl;
function XGetGeometry(para1: PDisplay; para2: TDrawable; para3: PWindow; para4: Pcint; para5: Pcint; para6: Pcuint; para7: Pcuint; para8: Pcuint; para9: Pcuint): TStatus; cdecl;
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
function XCopyArea(para1: PDisplay; para2: TDrawable; para3: TDrawable; para4: TGC; para5: cint; para6: cint; para7: cuint; para8: cuint; para9: cint; para10: cint): cint; cdecl;
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
function XSetWMProtocols(para1: PDisplay; para2: TWindow; para3: PAtom; para4: cint): TStatus; cdecl;
function XDestroyWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
function XAllocSizeHints: PXSizeHints; cdecl;
function XGetWMNormalHints(para1: PDisplay; para2: TWindow; para3: PXSizeHints; para4: Pclong): TStatus; cdecl;
procedure XSetWMNormalHints(ADisplay: PDisplay; AWindow: TWindow; AHints: PXSizeHints); cdecl;
function XConfigureWindow(para1: PDisplay; para2: TWindow; para3: cuint; para4: PXWindowChanges): cint; cdecl;
function XUnmapWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
function XReparentWindow(para1: PDisplay; para2: TWindow; para3: TWindow; para4: cint; para5: cint): cint; cdecl;
function XBell(para1: PDisplay; para2: cint): cint; cdecl;
function XScreenNumberOfScreen(para1: PScreen): cint; cdecl;
function XCheckTypedWindowEvent(para1: PDisplay; para2: TWindow; para3: cint; para4: PXEvent): TBoolResult; cdecl;
function XPeekEvent(ADisplay: PDisplay; AEvent: PXEvent): cint; cdecl;
function XFilterEvent(para1: PXEvent; para2: TWindow): TBoolResult; cdecl;
function XRefreshKeyboardMapping(para1: PXMappingEvent): cint; cdecl;
function XGetErrorText(para1: PDisplay; para2: cint; para3: PChar; para4: cint): cint; cdecl;
function XCreateColormap(para1: PDisplay; para2: TWindow; para3: PVisual; para4: cint): TColormap; cdecl;
function XStoreColors(para1: PDisplay; para2: TColormap; para3: PXColor; para4: cint): cint; cdecl;
function XSupportsLocale: TBool; cdecl;
function XDefaultScreenOfDisplay(display: PDisplay): PScreen; cdecl;
function XRootWindowOfScreen(screen: PScreen): Window; cdecl;
function XDefaultVisualOfScreen(screen: PScreen): PVisual; cdecl;
function XDefaultDepthOfScreen(para1: PScreen): cint; cdecl;
function XDefaultColormapOfScreen(para1: PScreen): TColormap; cdecl;
function XKeysymToKeycode(para1: PDisplay; para2: TKeySym): TKeyCode; cdecl;
function XGetModifierMapping(para1: PDisplay): PXModifierKeymap; cdecl;
function XFreeModifiermap(para1: PXModifierKeymap): cint; cdecl;
function XConnectionNumber(para1: PDisplay): cint; cdecl;
function XSetErrorHandler(para1: TXErrorHandler): TXErrorHandler; cdecl;
function XSetClipRectangles(para1: PDisplay; para2: TGC; para3: cint; para4: cint; para5: PXRectangle; para6: cint; para7: cint): cint; cdecl;
function XSetDashes(para1: PDisplay; para2: TGC; para3: cint; para4: PChar; para5: cint): cint; cdecl;
function XChangeGC(para1: PDisplay; para2: TGC; para3: culong; para4: PXGCValues): cint; cdecl;
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
function XCreateImage(Display: PDisplay; Visual: msePVisual; Depth: longword; Format: longint; Offset: longint; Data: PChar; Width, Height: longword; BitmapPad: longint; BytesPerLine: longint): PXImage; cdecl;

// Todo from libX11 and mseguiintf
function XSetWMHints(Display: PDisplay; W: xid; WMHints: PXWMHints): cint; cdecl;
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
function XDestroyImage(ximage: PXImage): cint;
function getxrandrlib: Boolean;

implementation

uses
  SysUtils;

// XCB-specific types
type
 xcb_setup_t = record end;
  Pxcb_setup_t = ^xcb_setup_t;
 
  xcb_generic_event_t = record
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    pad: array[0..6] of cuint32;
    full_sequence: cuint32;
  end;
  pxcb_generic_event_t = ^xcb_generic_event_t;
  
  
  xcb_key_press_event_t = record
    response_type: cuint8;
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
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    window: xcb_window_t;
    x, y: cuint16;
    Width, Height: cuint16;
    Count: cuint16;
  end;
  pxcb_expose_event_t = ^xcb_expose_event_t;

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
  Pxcb_intern_atom_reply_t = ^xcb_intern_atom_reply_t;
  xcb_intern_atom_reply_t = record
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    atom: xcb_atom_t;
  end;
  
  xcb_intern_atom_cookie_t = record
    sequence: cuint;
  end;

   xcb_query_font_reply_t = record
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    ascent: cint;
    descent: cint;
  end;

  xcb_shape_query_extension_reply_t = record
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    present: cuint8;
    major_version, minor_version: cuint8;
    event_base, error_base: cuint8;
  end;
  
 
  
   xcb_get_property_reply_t = record
    response_type: cuint8;
    format: cuint8;
    sequence: cuint16;
    length: cuint32;
    type_: xcb_atom_t;
    bytes_after: cuint32;
    value_len: cuint32;
    Value: array[0..0] of char; // Variable length
  end;


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
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    present: cuint8;
    major_opcode: cuint8;
    first_event: cuint8;
    first_error: cuint8;
  end;
  Pxcb_query_extension_reply_t = ^xcb_query_extension_reply_t;

  Pxcb_screen_iterator_t = ^xcb_screen_iterator_t;
  xcb_screen_iterator_t = record
    data: Pxcb_screen_t;
    rem: cint;
    index: cint;
  end;
  
  xcb_get_property_cookie_t = record
    sequence: Cardinal;  // Cardinal is equivalent to c_uint (unsigned 32-bit)
  end;
  Pxcb_get_property_cookie_t = ^xcb_get_property_cookie_t;


function xcb_get_setup(c: Pxcb_connection_t): Pxcb_setup_t; cdecl; external 'libxcb';
function xcb_setup_roots_iterator(setup: Pxcb_setup_t): xcb_setup_roots_iterator_t; cdecl; external 'libxcb';

// XCB functions
function xcb_randr_query_version(c: Pxcb_connection_t; major_version, minor_version: cuint32): xcb_void_cookie_t; cdecl; external 'libxcb-randr';
function xcb_randr_query_version_reply(c: Pxcb_connection_t; cookie: xcb_void_cookie_t; e: PPxcb_generic_error_t): Pointer; cdecl; external 'libxcb-randr';
function xcb_query_extension(c: Pxcb_connection_t; name_len: cuint; name: PChar): xcb_query_extension_cookie_t; cdecl; external libxcb;
function xcb_query_extension_reply(c: Pxcb_connection_t; cookie: xcb_query_extension_cookie_t; e: PPxcb_generic_error_t): Pxcb_query_extension_reply_t; cdecl; external libxcb;
function xcb_generate_id(c: pxcb_connection_t): cuint32; cdecl; external libxcb;
function xcb_connect(displayname: PChar; screenp: Pcint): pxcb_connection_t; cdecl; external libxcb;
procedure xcb_disconnect(c: pxcb_connection_t); cdecl; external libxcb;
// function xcb_get_setup(c: pxcb_connection_t): Pointer; cdecl; external libxcb;
function xcb_setup_roots_iterator(setup: Pointer): xcb_setup_roots_iterator_t; cdecl; external libxcb;
function xcb_create_window(c: pxcb_connection_t; depth: cuint8; wid: xcb_window_t; parent: xcb_window_t; x, y: cint16; Width, Height, border_width: cuint16; _class: cuint16; visual: xcb_visualid_t;
  value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_map_window(c: pxcb_connection_t; window: xcb_window_t): Pointer; cdecl; external libxcb;
function xcb_change_window_attributes(c: pxcb_connection_t; window: xcb_window_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_get_input_focus(c: pxcb_connection_t): Pointer; cdecl; external libxcb;
function xcb_get_input_focus_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): Pointer; cdecl; external libxcb;

//function xcb_intern_atom(c: pxcb_connection_t; only_if_exists: cuint8; length: cuint16; Name: PChar): Pointer; cdecl; external libxcb;
//function xcb_intern_atom_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_intern_atom_reply_t; cdecl; external libxcb;

function xcb_intern_atom(c: Pxcb_connection_t; only_if_exists: cuint8; name_len: cuint16; name: PChar): xcb_intern_atom_cookie_t; cdecl; external libxcb;
function xcb_intern_atom_reply(c: Pxcb_connection_t; cookie: xcb_intern_atom_cookie_t; e: PPxcb_generic_error_t): Pxcb_intern_atom_reply_t; cdecl; external libxcb;

function xcb_get_property(c: pxcb_connection_t; Delete: cuint8; window: xcb_window_t; prop: xcb_atom_t; type_: xcb_atom_t; offset, length: cuint32): xcb_get_property_cookie_t; cdecl; external libxcb;
function xcb_get_property_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_get_property_reply_t; cdecl; external libxcb;
function xcb_change_property(c: pxcb_connection_t; mode: cuint8; window: xcb_window_t; prop: xcb_atom_t; type_: xcb_atom_t; format: cuint8; data_len: cuint32; Data: Pointer): Pointer; cdecl; external libxcb;
function xcb_send_event(c: pxcb_connection_t; propagate: cuint8; destination: xcb_window_t; event_mask: cuint32; event: Pointer): Pointer; cdecl; external libxcb;
procedure xcb_flush(c: pxcb_connection_t); cdecl; external libxcb;
function xcb_get_atom_name(c: pxcb_connection_t; atom: xcb_atom_t): Pointer; cdecl; external libxcb;
function xcb_get_atom_name_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_get_atom_name_reply_t; cdecl; external libxcb;
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
// function xcb_get_setup(c: Pxcb_connection_t): Pxcb_setup_t; cdecl; external libxcb;
//function xcb_setup_roots_iterator(setup: Pxcb_setup_t): xcb_screen_iterator_t; cdecl; external libxcb;
// function xcb_get_setup(c: Pxcb_connection_t): Pxcb_setup_t; cdecl; external 'libxcb';
function xcb_setup_roots_iterator(setup: Pxcb_setup_t): xcb_screen_iterator_t; cdecl; external libxcb;
function xcb_screen_allowed_depths_iterator(screen: Pxcb_screen_t): xcb_depth_iterator_t; cdecl; external libxcb;
function xcb_depth_visuals_iterator(depth: Pxcb_depth_t): xcb_visualtype_iterator_t; cdecl; external libxcb;
function xcb_visualtype_next(iterator: Pxcb_visualtype_iterator_t): Pxcb_visualtype_iterator_t; cdecl; external libxcb;
procedure xcb_depth_next(iterator: Pxcb_depth_iterator_t); cdecl; external libxcb;
procedure xcb_screen_next(iterator: Pxcb_screen_iterator_t); cdecl; external libxcb;

// Implementation
function XOpenDisplay(display_name: PChar): PDisplay; cdecl;
begin
  Result := xcb_connect(display_name, nil);
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
  iter: xcb_setup_roots_iterator_t;
  default_visual: xcb_visualid_t;
begin
  Result := 0;
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

  cookie := xcb_create_window_checked(display, depth, wid, parent, x, y, Width, Height, border_width,
                                     window_class, default_visual, valuemask, Pcuint32(attributes));
  error := xcb_request_check(display, cookie);
  if error <> nil then
  begin
    WriteLn('Error creating window: ', error^.error_code);
    freeandnil(error);
    Result := 0;
  end
  else
  begin
    WriteLn('windo OK');
    Result := wid;
  end;
end;

procedure XMapWindow(display: PDisplay; w: Window); cdecl;
begin
  xcb_map_window(display, w);
end;

procedure XSelectInput(display: PDisplay; w: Window; event_mask: clong); cdecl;
var
  value_list: array[0..0] of cuint32;
begin
  value_list[0] := event_mask;
  xcb_change_window_attributes(display, w, CWEventMask, @value_list);
end;


function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;
var
  cookie: xcb_intern_atom_cookie_t;
  reply: Pxcb_intern_atom_reply_t;
  error: Pxcb_generic_error_t;
begin
  Result := 0;
  if (display = nil) or (atom_name = nil) then
  begin
    WriteLn('XInternAtom: display or atom_name is null');
    Exit;
  end;

  WriteLn('XInternAtom: atom_name=', atom_name);
  cookie := xcb_intern_atom(display, Ord(only_if_exists), Length(atom_name), atom_name);
  if cookie.sequence = 0 then
    WriteLn('XInternAtom: cookie = nil')
  else
    WriteLn('XInternAtom: cookie.sequence=', cookie.sequence);

  reply := xcb_intern_atom_reply(display, cookie, @error);
  if error <> nil then
  begin
    WriteLn('XInternAtom: error code=', error^.error_code);
    FreeAndNil(error);
    Exit;
  end;
  if reply = nil then
  begin
    WriteLn('XInternAtom: reply is null');
    Exit;
  end;
 
  WriteLn('XInternAtom: response_type=', reply^.response_type);
  WriteLn('XInternAtom: sequence=', reply^.sequence);
  WriteLn('XInternAtom: length=', reply^.length);
  WriteLn('XInternAtom: atom=', reply^.atom);
  WriteLn();
  
  Result := reply^.atom;
  // FreeAndNil(reply);
end;

function XGetWindowProperty(display: PDisplay; w: Window; atom_property: Atom; long_offset, long_length: culong; Delete: TBool; req_type: Atom; actual_type_return: PAtom; actual_format_return: Pcint;
  nitems_return: Pculong; bytes_after_return: Pculong; prop_return: PPcuchar): cint; cdecl;
var
  cookie: xcb_get_property_cookie_t;
  reply: xcb_get_property_reply_t;
  i : integer;
begin
  writeln('xgetwindowproperty 0 ');
  cookie := xcb_get_property(display, Ord(Delete), w, atom_property, req_type, long_offset, long_length);
  reply  := xcb_get_property_reply(display, @cookie, nil);
  writeln('xgetwindowproperty 2 ');

  actual_type_return^ := reply.type_;
  actual_format_return^ := reply.format;
  nitems_return^ := reply.value_len;
  bytes_after_return^ := reply.bytes_after;
  prop_return^   := @reply.Value;
  Result         := 0; // Success
 
  writeln('reply.type_ ', reply.type_);
  writeln('reply.format ', reply.format);
  writeln('reply.value_len ', reply.value_len);
  writeln('reply.bytes_after ', reply.bytes_after);
  writeln('result ', result);
  
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
  cookie: Pointer;
  reply: xcb_get_atom_name_reply_t;
begin
  cookie := xcb_get_atom_name(display, atom);
  reply  := xcb_get_atom_name_reply(display, cookie, nil);
  Result := StrNew(reply.Name);
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
  FreeMem(Data);
end;

function XCreateGC(display: PDisplay; d: Drawable; valuemask: culong; values: PXGCValues): GC; cdecl;
var
  cid: xcb_gcontext_t;
  value_list: array[0..2] of cuint32;
begin
  cid           := xcb_generate_id(display);
  value_list[0] := values^.foreground;
  value_list[1] := values^.background;
  value_list[2] := values^.font;
  xcb_create_gc(display, cid, d, valuemask, @value_list);
  Result        := Pointer(cid);
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
  if err <> nil then
    Freemem(err);// Optionally log error

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
    freeandnil(error);
    Result := 0;
  end
  else if reply <> nil then
  begin
    Result := 1; // Assume RandR is present
    event_base_return^ := 0; // Placeholder, may affect RandR events
    error_base_return^ := 0;
    g_randreventbase := 0;
    g_randrerrorbase := 0;
    freeandnil(reply);
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
  iterator: xcb_setup_roots_iterator_t;
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
    WriteLn('Warning: Could not find visual type for root visual');
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
  screen_iter: xcb_setup_roots_iterator_t;
  depth_iter: xcb_depth_iterator_t;
  visual_iter: xcb_visualtype_iterator_t;
  visual_type: Pxcb_visualtype_t;
  visual: PVisual;
begin
   WriteLn('XDefaultVisualOfScreen: init');
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
            WriteLn('XDefaultVisualOfScreen: visualid=', visual^.visualid);
            Exit;
          end;
          xcb_visualtype_next(@visual_iter);
        end;
        xcb_depth_next(@depth_iter);
      end;
    end;
    xcb_screen_next(@screen_iter);
  end;
  WriteLn('XDefaultVisualOfScreen: No matching visual found');
  Dispose(visual);
end;

function XDefaultDepthOfScreen(para1: PScreen): cint; cdecl;
begin
Result := para1^.root_depth;
end;

// Todo
function XLookupString(event_struct: PXKeyPressedEvent; buffer_return: PChar; bytes_buffer: cint; keysym_return: Pculong; status_in_out: Pointer): cint; cdecl;
begin

end;

procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl;
begin

end;

function XPending(display: PDisplay): cint; cdecl;
begin

end;

function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBoolResult; cdecl;
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

function XGetWindowAttributes(para1: PDisplay; para2: TWindow; para3: PXWindowAttributes): TStatus; cdecl;
begin

end;

function XGetGeometry(para1: PDisplay; para2: TDrawable; para3: PWindow; para4: Pcint; para5: Pcint; para6: Pcuint; para7: Pcuint; para8: Pcuint; para9: Pcuint): TStatus; cdecl;
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

function XCopyArea(para1: PDisplay; para2: TDrawable; para3: TDrawable; para4: TGC; para5: cint; para6: cint; para7: cuint; para8: cuint; para9: cint; para10: cint): cint; cdecl;
begin

end;

function XFreePixmap(para1: PDisplay; para2: TPixmap): cint; cdecl;
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

function XSetWMProtocols(para1: PDisplay; para2: TWindow; para3: PAtom; para4: cint): TStatus; cdecl;
begin

end;

function XDestroyWindow(ADisplay: PDisplay; AWindow: TWindow): cint; cdecl;
begin

end;

function XAllocSizeHints: PXSizeHints; cdecl;
begin

end;

function XGetWMNormalHints(para1: PDisplay; para2: TWindow; para3: PXSizeHints; para4: Pclong): TStatus; cdecl;
begin

end;

procedure XSetWMNormalHints(ADisplay: PDisplay; AWindow: TWindow; AHints: PXSizeHints); cdecl;
begin

end;

function XConfigureWindow(para1: PDisplay; para2: TWindow; para3: cuint; para4: PXWindowChanges): cint; cdecl;
begin

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
begin

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

function XCreateColormap(para1: PDisplay; para2: TWindow; para3: PVisual; para4: cint): TColormap; cdecl;
begin

end;

function XStoreColors(para1: PDisplay; para2: TColormap; para3: PXColor; para4: cint): cint; cdecl;
begin

end;

function XSupportsLocale: TBool; cdecl;
begin

end;

function XDefaultColormapOfScreen(para1: PScreen): TColormap; cdecl;
begin

end;

function XKeysymToKeycode(para1: PDisplay; para2: TKeySym): TKeyCode; cdecl;
begin

end;

function XGetModifierMapping(para1: PDisplay): PXModifierKeymap; cdecl;
begin

end;

function XFreeModifiermap(para1: PXModifierKeymap): cint; cdecl;
begin

end;

function XConnectionNumber(para1: PDisplay): cint; cdecl;
begin

end;

function XInternAtoms(para1: PDisplay; para2: PPchar; para3: cint; para4: TBool; para5: PAtom): TStatus; cdecl;
begin
result := 0;
end;

function XSetErrorHandler(para1: TXErrorHandler): TXErrorHandler; cdecl;
begin

end;

function XSetClipRectangles(para1: PDisplay; para2: TGC; para3: cint; para4: cint; para5: PXRectangle; para6: cint; para7: cint): cint; cdecl;
begin

end;

function XSetDashes(para1: PDisplay; para2: TGC; para3: cint; para4: PChar; para5: cint): cint; cdecl;
begin

end;

function XChangeGC(para1: PDisplay; para2: TGC; para3: culong; para4: PXGCValues): cint; cdecl;
begin

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

function XCreateImage(Display: PDisplay; Visual: msePVisual; Depth: longword; Format: longint; Offset: longint; Data: PChar; Width, Height: longword; BitmapPad: longint; BytesPerLine: longint): PXImage; cdecl;
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

function XSetWMHints(Display: PDisplay; W: xid; WMHints: PXWMHints): cint; cdecl;
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

function XOpenIM(Display: PDisplay; rdb: PXrmHashBucketRec; res_name: PChar; res_class: PChar): XIM; cdecl;
begin

end;

function XCloseIM(IM: XIM): TStatus; cdecl;
begin

end;

function XCreateIC(IM: XIM; inputstyle: PChar; status: longint; pt: Pointer): XIC; cdecl;
begin

end;

procedure XDestroyIC(IC: XIC); cdecl;
begin

end;

function XSetLocaleModifiers(modifier_list: PChar): PChar; cdecl;
begin

end;

function XSetICValues(IC: XIC; focusw: PChar; id: longint; pnt: Pointer): PChar; cdecl;
begin

end;

function XSetICValues(IC: XIC; nreset: PChar; impreserv: PChar; pnt: Pointer): PChar; cdecl;
begin

end;

function XSetIMValues(IC: XIM; destroycb: PChar; ximcb: Pointer; pt: Pointer): PChar; cdecl;
begin

end;

function XGetICValues(IC: XIC; filterev: PChar; icmask: Pointer; pnt: Pointer): PChar; cdecl;
begin

end;

procedure XSetICFocus(IC: XIC); cdecl;
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

function XDestroyImage(ximage: PXImage): cint;
begin
  XDestroyImage := ximage^.f.destroy_image(ximage);
end;

function getxrandrlib: Boolean;
begin
  Result := True;
end;

end.
