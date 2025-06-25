unit mxcb;
 {$mode objfpc}{$h+}

interface

uses
  ctypes; // For culong, cint, cuint, cshort, cchar, cuchar

{$PACKRECORDS C}
const
  libxcb = 'libxcb.so.1';
  libxcb_shape = 'libxcb-shape.so.0';
  libxcb_render = 'libxcb-render.so';
  libxcb_randr = 'libxcb-randr.so';

type
  xcb_connection_t = record end; // Opaque structure
  Pxcb_connection_t = ^xcb_connection_t;
  PDisplay = Pxcb_connection_t; // Alias for XCB connection
  
  type
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
  Pxcb_generic_error_t = ^xcb_generic_error_t;
  PPxcb_generic_error_t = ^Pxcb_generic_error_t;
  
  PBool       = ^TBool;
  TBool       = cint;
  TBoolResult = cint;
  TStatus = cint;
  PStatus = ^TStatus;
  TRegion = Pointer; // Maps to xcb_region_t
  XRectangle = record
    x, y: cshort;
    width, height: cushort;
  end;
  PXRectangle = ^XRectangle;

  Display = Pointer; // Maps to xcb_connection_t*
 // PDisplay = ^Display;
  
 // PDisplay = ^Pointer; // Opaque pointer (simulating Xlib's Display)
 
  Window = cuint; // Maps to xcb_window_t
  TWindow = Window; // For mshape.pas
  Drawable = cuint; // Maps to xcb_drawable_t
  TDrawable = Drawable; // For mseguiintf.pas
  GC = Pointer; // Maps to xcb_gcontext_t
  TGC = GC;
 
 // fred
 // Screen = Pointer; // Maps to xcb_screen_t*
 // PScreen = ^Screen;
 
  Atom = cuint; // Maps to xcb_atom_t
  PAtom = ^Atom;
  VisualID = cuint; // Maps to xcb_visualid_t
  Colormap = cuint; // Maps to xcb_colormap_t
  TColormap = Colormap; // For mseguiintf.pas
  Pixmap = cuint; // Maps to xcb_pixmap_t
  TPixmap = Pixmap; // For mshape.pas
  Font = cuint; // Maps to xcb_font_t
  TKeySym = culong;
  PKeySym = ^TKeySym;
  Pcuchar = ^cuchar;
  PPcuchar = ^Pcuchar;
  Picture = culong; // Maps to xcb_render_picture_t
  TPicture = Picture; // For msex11gdi.pas

  Visual = record
    visualid: VisualID;
    visual_class: cint; // Renamed from class
    red_mask, green_mask, blue_mask: culong;
    bits_per_rgb: cint;
    map_entries: cint;
  end;
  PVisual = ^Visual;

{ fred
  XWindowAttributes = record
    x, y: cint;
    width, height: cint;
    border_width: cint;
    depth: cint;
    visual: PVisual;
    root: Window;
    visual_class: cint; // Renamed from class
    bit_gravity: cint;
    win_gravity: cint;
    backing_store: cint;
    backing_planes: culong;
    backing_pixel: culong;
    save_under: boolean;
    colormap: Colormap;
    map_installed: boolean;
    map_state: cint;
    all_event_masks: clong;
    your_event_mask: clong;
    do_not_propagate_mask: clong;
    override_redirect: boolean;
    screen: PScreen;
  end;
  PXWindowAttributes = ^XWindowAttributes;
}
  XSizeHints = record
    flags: clong;
    x, y: cint;
    width, height: cint;
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

  XrmHashBucketRec = Pointer;
  PXrmHashBucketRec = ^XrmHashBucketRec;

  XExtData = record
    number: cint;
    next: Pointer;
    free_private: procedure(data: Pointer); cdecl;
    private_data: PChar;
  end;
  PXExtData = ^XExtData;

  XWMHints = record
    flags: clong;
    input: boolean;
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
    send_event: boolean;
    display: PDisplay;
    window: Window;
    root: Window;
    subwindow: Window;
    time: culong;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    keycode: cuint;
    same_screen: boolean;
  end;
  PXKeyPressedEvent = ^XKeyEvent;

{ fred
  XImage = record
    width, height: cint;
    xoffset: cint;
    format: cint;
    data: PChar;
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
    obdata: PChar;
    funcs: record
      create_image: function: Pointer; cdecl;
      destroy_image: function(image: Pointer): cint; cdecl;
      get_pixel: function(image: Pointer; x, y: cint): culong; cdecl;
      put_pixel: function(image: Pointer; x, y: cint; pixel: culong): cint; cdecl;
      sub_image: function(image: Pointer; x, y: cint; width, height: cuint): Pointer; cdecl;
      add_pixel: function(image: Pointer; value: clong): cint; cdecl;
    end;
  end;
  PXImage = ^XImage;

  XEvent = record
    case integer of
      0: (type_: cint);
      2: (xkey: XKeyEvent);
      12: (xexpose: record
            type_: cint;
            serial: culong;
            send_event: boolean;
            display: PDisplay;
            window: Window;
            x, y: cint;
            width, height: cuint;
            count: cint;
          end);
      33: (xclient: record
            type_: cint;
            serial: culong;
            send_event: boolean;
            display: PDisplay;
            window: Window;
            message_type: Atom;
            format: cint;
            data: record
              case integer of
                0: (l: array[0..4] of clong);
                1: (s: array[0..9] of cshort);
                2: (b: array[0..19] of cchar);
            end;
          end);
  end;
  PXEvent = ^XEvent;
  txevent = XEvent;
  }

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

{ fred
  XFontStruct = record
    fid: Font;
    ascent: cint;
    descent: cint;
  end;
  PXFontStruct = ^XFontStruct;

  XTextProperty = record
    value: Pcuchar;
    encoding: Atom;
    format: cint;
    nitems: culong;
  end;
  PXTextProperty = ^XTextProperty;
}
  XModifierKeymap = record
    max_keypermod: cint;
    modifiermap: Pcuchar;
  end;
  PXModifierKeymap = ^XModifierKeymap;

  // XCB-specific types
  xcb_window_t = cuint;
  xcb_drawable_t = cuint;
  xcb_gcontext_t = cuint;
  xcb_void_cookie_t = cuint;
  xcb_visualid_t = cuint;
  xcb_colormap_t = cuint;
  xcb_pixmap_t = cuint;
  xcb_font_t = cuint;
  xcb_atom_t = cuint;
  xcb_region_t = Pointer;
  xcb_setup_roots_iterator_t = record
    iterator: Pointer;
  end;
  xcb_get_atom_name_reply_t = record
    name_len: cuint16;
    name: PChar;
  end;

  // XRender-specific types for msex11gdi.pas and mxft.pas
  xcb_render_color_t = record
    red, green, blue, alpha: cuint16;
  end;
  xcb_render_pictformat_t = cuint32;
  xcb_render_picture_t = cuint32;
  TXRenderColor = record
    red, green, blue, alpha: cushort;
  end;
  PXRenderColor = ^TXRenderColor;
  XRenderColor = TXRenderColor;
  TXGlyph = cuint32;
  PXGlyph = ^TXGlyph;
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
  
// XID type for mxrandr.pas
  txid = culong;
  pxid = ^txid;
  
// fred begin

  TXGlyphInfo = record
    Width: word;
    Height: word;
    x: smallint;
    y: smallint;
    xOff: smallint;
    yOff: smallint;
  end;
  PXGlyphInfo = ^TXGlyphInfo;
  
  PPAtom = ^PAtom;
  TAtom  = culong; 
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
  
 TTime = culong;
  PTime = ^TTime;  
  
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

  
// fred end  

    // XRandR types for mxrandr.pas
  Rotation = cushort;
  SizeID = cushort;
  RRCrtc = txid; // Maps to xcb_randr_crtc_t
  RRMode = txid; // Maps to xcb_randr_mode_t
  XRRScreenSize = record
    width, height: cint;
    mwidth, mheight: cint;
  end;
  PXRRScreenSize = ^XRRScreenSize;
  XRRModeInfo = record
    id: RRMode;
    width, height: cuint;
    dotClock: culong;
    hSyncStart, hSyncEnd, hTotal, hSkew: cuint;
    vSyncStart, vSyncEnd, vTotal: cuint;
    name: PChar;
    nameLength: cuint;
    modeFlags: culong;
  end;
  PXRRModeInfo = ^XRRModeInfo;
  XRRCrtcInfo = record
    timestamp: culong;
    x, y: cint; // Fixed: Removed "Shel x"
    width, height: cuint;
    rotation: Rotation;
    rotations: Rotation;
    mode: RRMode;
    outputs: Pculong;
    noutput: cint;
  end;
  PXRRCrtcInfo = ^XRRCrtcInfo;

const
  KeyPressMask = 1 shl 0;
  ExposureMask = 1 shl 15;
  KeyPress = 2;
  Expose = 12;
  ClientMessage = 33;
  InputOnly = 2;
  InputOutput = 1;
  CopyFromParent = 0;
  CWBackPixel = 1 shl 1;
  CWEventMask = 1 shl 11;
  CWColormap = 1 shl 13;
  GCForeground = 1 shl 2;
  GCBackground = 1 shl 3;
  GCFont = 1 shl 14;
  XA_STRING = 31;
  XA_WM_HINTS = 35;
  None = 0;
  PropModeReplace = 0;
  ShapeBounding = 0;
  ShapeClip = 1;
  ShapeSet = 0;
  ZPixmap = 2;
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
  Button1        = 1;
  Button2        = 2;
  Button3        = 3;
  Button4        = 4;
  Button5        = 5;
  
  XNFocusWindow = 'focusWindow';
  XNFilterEvents = 'filterEvents';
  XNResetState  = 'resetState';
  XNInputStyle  = 'inputStyle';
  XNClientWindow = 'clientWindow';
  XNDestroyCallback = 'destroyCallback';


function XOpenDisplay(display_name: PChar): PDisplay; cdecl;
procedure XCloseDisplay(display: PDisplay); cdecl;
function XDefaultScreen(display: PDisplay): cint; cdecl;
function XDefaultVisual(display: PDisplay; screen_number: cint): PVisual; cdecl;
function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; width, height, border_width: cuint;
                       depth: cint; window_class: cuint; visual: PVisual; valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl;
procedure XMapWindow(display: PDisplay; w: Window); cdecl;
procedure XSelectInput(display: PDisplay; w: Window; event_mask: clong); cdecl;
procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl;
function XPending(display: PDisplay): cint; cdecl;
function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;
function XGetWindowProperty(display: PDisplay; w: Window; atom_property: Atom; long_offset, long_length: culong;
                            delete: TBool; req_type: Atom; actual_type_return: PAtom; actual_format_return: Pcint;
                            nitems_return: Pculong; bytes_after_return: Pculong; prop_return: PPcuchar): cint; cdecl;

function XSendEvent(display: PDisplay; w: Window; propagate: TBool; event_mask: clong;
 event_send: PXEvent): cint; cdecl;

//function XSendEvent(para1: PDisplay; para2: TWindow; para3: TBool;
// para4: clong; para5: PXEvent): TStatus; cdecl; external libX11;

function XChangeProperty(display: PDisplay; w: Window; atom_property:
 Atom; type_: Atom; format: cint; mode: cint; data: Pcuchar; nelements: cint): cint; cdecl;
procedure XFlush(display: PDisplay); cdecl;
function XGetAtomName(display: PDisplay; atom: Atom): PChar; cdecl;
function XSetWMHints(display: PDisplay; w: Window; wmhints: PXWMHints): cint; cdecl;
procedure XFree(data: Pointer); cdecl;
function XCreateGC(display: PDisplay; d: Drawable; valuemask: culong; values: PXGCValues): GC; cdecl;
procedure XFreeGC(display: PDisplay; gc: GC); cdecl;
procedure XSetForeground(display: PDisplay; gc: GC; foreground: culong); cdecl;
procedure XDrawLine(display: PDisplay; d: Drawable; gc: GC; x1, y1, x2, y2: cint); cdecl;
function XLoadQueryFont(display: PDisplay; name: PChar): PXFontStruct; cdecl;
procedure XFreeFont(display: PDisplay; font_struct: PXFontStruct); cdecl;
procedure XDrawString(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PChar; length: cint); cdecl;
procedure XDrawString16(display: PDisplay; d: Drawable; gc: GC; x, y: cint; str: PXChar2b; length: cint); cdecl;
procedure XPutImage(display: PDisplay; d: Drawable; gc: GC; image: PXImage; src_x, src_y: cint; dest_x, dest_y: cint; width, height: cuint32); cdecl;
function XLookupString(event_struct: PXKeyPressedEvent; buffer_return: PChar; bytes_buffer: cint; keysym_return: Pculong; status_in_out: Pointer): cint; cdecl;
function XCreateColormap(display: PDisplay; w: Window; visual: PVisual; alloc: cint): TColormap; cdecl;
procedure XFreeColormap(display: PDisplay; cmap: TColormap); cdecl;
function XCreatePixmap(display: PDisplay; d: Drawable; width, height, depth: cuint): TPixmap; cdecl;
function XRenderCreatePicture(display: PDisplay; d: Drawable; format: PXRenderPictFormat; valuemask: culong; attributes: Pointer): TPicture; cdecl;
procedure XRenderFreePicture(display: PDisplay; picture: TPicture); cdecl;
procedure XRenderComposite(display: PDisplay; op: cint; src: TPicture; mask: TPicture; dst: TPicture; src_x, src_y, mask_x, mask_y, dst_x, dst_y: cint; width, height: cuint); cdecl;

// Shape extension for mshape.pas
function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBoolResult; cdecl;
function XShapeCombineRegion(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; region: TRegion; op: cint): TStatus; cdecl;
procedure XShapeCombineRectangles(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; rectangles: PXRectangle; n_rects: cint; op: cint; ordering: cint); cdecl;
procedure XShapeCombineMask(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; mask: TPixmap; op: cint); cdecl;

implementation

uses
  sysutils;

// XCB-specific types
type
  xcb_screen_t = record
    root: xcb_window_t;
    default_colormap: xcb_colormap_t;
    white_pixel, black_pixel: cuint;
    current_input_masks: cuint;
    width_in_pixels, height_in_pixels: cuint;
    width_in_millimeters, height_in_millimeters: cuint;
    min_installed_maps, max_installed_maps: cuint;
    root_visual: xcb_visualid_t;
    backing_stores: cchar;
    save_unders: cchar;
    root_depth: cchar;
    allowed_depths_len: cchar;
  end;

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
    width, height: cuint16;
    count: cuint16;
  end;
  pxcb_expose_event_t = ^xcb_expose_event_t;

  xcb_client_message_event_t = record
    response_type: cuint8;
    format: cuint8;
    sequence: cuint16;
    window: xcb_window_t;
    type_: xcb_atom_t;
    data: record
      case integer of
        0: (data8: array[0..19] of cuint8);
        1: (data16: array[0..9] of cuint16);
        2: (data32: array[0..4] of cuint32);
    end;
  end;
  pxcb_client_message_event_t = ^xcb_client_message_event_t;

  xcb_intern_atom_reply_t = record
    response_type: cuint8;
    pad0: cuint8;
    sequence: cuint16;
    length: cuint32;
    atom: xcb_atom_t;
  end;

  xcb_get_property_reply_t = record
    response_type: cuint8;
    format: cuint8;
    sequence: cuint16;
    length: cuint32;
    type_: xcb_atom_t;
    bytes_after: cuint32;
    value_len: cuint32;
    value: array[0..0] of cchar; // Variable length
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

  // XRandR-specific types for mxrandr.pas
  xcb_randr_crtc_t = cuint32;
  xcb_randr_mode_t = cuint32;
  xcb_randr_screen_size_t = record
    width, height: cuint16;
    mwidth, mheight: cuint16;
  end;

// XCB functions
function xcb_generate_id(c: pxcb_connection_t): cuint32; cdecl; external libxcb;
function xcb_connect(displayname: PChar; screenp: Pcint): pxcb_connection_t; cdecl; external libxcb;
procedure xcb_disconnect(c: pxcb_connection_t); cdecl; external libxcb;
function xcb_get_setup(c: pxcb_connection_t): Pointer; cdecl; external libxcb;
function xcb_setup_roots_iterator(setup: Pointer): xcb_setup_roots_iterator_t; cdecl; external libxcb;
function xcb_create_window(c: pxcb_connection_t; depth: cuint8; wid: xcb_window_t; parent: xcb_window_t;
                          x, y: cint16; width, height, border_width: cuint16; _class: cuint16; visual: xcb_visualid_t;
                          value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_map_window(c: pxcb_connection_t; window: xcb_window_t): Pointer; cdecl; external libxcb;
function xcb_change_window_attributes(c: pxcb_connection_t; window: xcb_window_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_get_input_focus(c: pxcb_connection_t): Pointer; cdecl; external libxcb;
function xcb_get_input_focus_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): Pointer; cdecl; external libxcb;
function xcb_intern_atom(c: pxcb_connection_t; only_if_exists: cuint8; length: cuint16; name: PChar): Pointer; cdecl; external libxcb;
function xcb_intern_atom_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_intern_atom_reply_t; cdecl; external libxcb;
function xcb_get_property(c: pxcb_connection_t; delete: cuint8; window: xcb_window_t; prop: xcb_atom_t; type_: xcb_atom_t; offset, length: cuint32): Pointer; cdecl; external libxcb;
function xcb_get_property_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_get_property_reply_t; cdecl; external libxcb;
function xcb_change_property(c: pxcb_connection_t; mode: cuint8; window: xcb_window_t; prop: xcb_atom_t; type_: xcb_atom_t; format: cuint8; data_len: cuint32; data: Pointer): Pointer; cdecl; external libxcb;
function xcb_send_event(c: pxcb_connection_t; propagate: cuint8; destination: xcb_window_t; event_mask: cuint32; event: Pointer): Pointer; cdecl; external libxcb;
procedure xcb_flush(c: pxcb_connection_t); cdecl; external libxcb;
function xcb_get_atom_name(c: pxcb_connection_t; atom: xcb_atom_t): Pointer; cdecl; external libxcb;
function xcb_get_atom_name_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_get_atom_name_reply_t; cdecl; external libxcb;
function xcb_create_gc(c: pxcb_connection_t; cid: xcb_gcontext_t; drawable: xcb_drawable_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_free_gc(c: pxcb_connection_t; gc: xcb_gcontext_t): Pointer; cdecl; external libxcb;
function xcb_change_gc(c: pxcb_connection_t; gc: xcb_gcontext_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb;
function xcb_poly_line(c: pxcb_connection_t; coordinate_mode: cuint8; drawable: xcb_drawable_t; gc: xcb_gcontext_t; points_len: cuint32; points: Pointer): Pointer; cdecl; external libxcb;
function xcb_open_font(c: pxcb_connection_t; fid: xcb_font_t; name_len: cuint32; name: PChar): Pointer; cdecl; external libxcb;
function xcb_query_font(c: pxcb_connection_t; font: xcb_font_t): Pointer; cdecl; external libxcb;
function xcb_query_font_reply(c: pxcb_connection_t; cookie: Pointer; e: Pointer): xcb_query_font_reply_t; cdecl; external libxcb;
function xcb_close_font(c: pxcb_connection_t; font: xcb_font_t): Pointer; cdecl; external libxcb;
function xcb_poly_text_8(c: pxcb_connection_t; drawable: xcb_drawable_t; gc: xcb_gcontext_t; x, y: cint16; items_len: cuint32; items: PChar): Pointer; cdecl; external libxcb;
function xcb_poly_text_16(c: pxcb_connection_t; drawable: xcb_drawable_t; gc: xcb_gcontext_t; x, y: cint16; items_len: cuint32; items: PXChar2b): Pointer; cdecl; external libxcb;

// fred

function xcb_put_image(c: xcb_connection_t; format: cuint8; drawable: xcb_drawable_t;
    gc: xcb_gcontext_t; width, height: cuint16; dst_x, dst_y: cint16; left_pad: cuint8;
    depth: cuint8; data_len: cuint32; data: PByte): xcb_void_cookie_t; cdecl; external libxcb;

// function xcb_put_image(c: xcb_connection_t; drawable: xcb_drawable_t; gc: xcb_gcontext_t; image: Pointer; x, y: cint16; width, height: cuint16): Pointer; cdecl; external libxcb;
// function xcb_get_next_event(c: xcb_connection_t): pxcb_generic_event_t; cdecl; external libxcb;
// function xcb_events_queued(c: xcb_connection_t; mode: cint): cint; cdecl; external libxcb;
// function xcb_shape_query_extension(c: xcb_connection_t): Pointer; cdecl; external libxcb_shape;
// function xcb_shape_query_extension_reply(c: xcb_connection_t; cookie: Pointer; e: Pointer): xcb_shape_query_extension_reply_t; cdecl; external libxcb_shape;
// function xcb_shape_combine_region(c: xcb_connection_t; operation: cuint8; destination_kind: cuint8; destination: xcb_window_t; x, y: cint16; region: xcb_region_t): Pointer; cdecl; external libxcb_shape;

function xcb_create_colormap(c: xcb_connection_t; alloc: cuint8; mid: xcb_colormap_t; window: xcb_window_t; visual: xcb_visualid_t): Pointer; cdecl; external libxcb;
function xcb_free_colormap(c: xcb_connection_t; cmap: xcb_colormap_t): Pointer; cdecl; external libxcb;
function xcb_create_pixmap(c: xcb_connection_t; depth: cuint8; pid: xcb_pixmap_t; drawable: xcb_drawable_t; width, height: cuint16): Pointer; cdecl; external libxcb;
function xcb_render_create_picture(c: xcb_connection_t; pid: xcb_render_picture_t; drawable: xcb_drawable_t; format: xcb_render_pictformat_t; value_mask: cuint32; value_list: Pointer): Pointer; cdecl; external libxcb_render;
function xcb_render_free_picture(c: xcb_connection_t; picture: xcb_render_picture_t): Pointer; cdecl; external libxcb_render;
function xcb_render_composite(c: xcb_connection_t; op: cuint8; src: xcb_render_picture_t; mask: xcb_render_picture_t; dst: xcb_render_picture_t; src_x, src_y, mask_x, mask_y, dst_x, dst_y: cint16; width, height: cuint16): Pointer; cdecl; external libxcb_render;

function xcb_shape_combine(c: xcb_connection_t; operation: cuint8; destination_kind: cuint8; destination: xcb_window_t; x, y: cint16; source: xcb_window_t; source_kind: cuint8): Pointer; cdecl; external libxcb_shape;

function xcb_shape_rectangles(c: xcb_connection_t; operation: cuint8; destination_kind: cuint8; ordering: cuint8; destination: xcb_window_t; x, y: cint16; rectangles_len: cuint32; rectangles: PXRectangle): Pointer; cdecl; external libxcb_shape;
function xcb_shape_mask(c: xcb_connection_t; operation: cuint8; destination_kind: cuint8; destination: xcb_window_t; x, y: cint16; mask: xcb_pixmap_t): Pointer; cdecl; external libxcb_shape;

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
  setup := xcb_get_setup(display);
  iter := xcb_setup_roots_iterator(setup);
  Result := 0; // First screen
end;

function XDefaultVisual(display: PDisplay; screen_number: cint): PVisual; cdecl;
var
  setup: Pointer;
  iter: xcb_setup_roots_iterator_t;
  screen: ^xcb_screen_t;
  vis: PVisual;
begin
  setup := xcb_get_setup(display);
  iter := xcb_setup_roots_iterator(setup);
  screen := iter.iterator;
  New(vis);
  vis^.visualid := screen^.root_visual;
  Result := vis;
end;

function XCreateWindow(display: PDisplay; parent: Window; x, y: cint; width, height, border_width: cuint;
                       depth: cint; window_class: cuint; visual: PVisual; valuemask: culong; attributes: PXSetWindowAttributes): Window; cdecl;
var
  wid: xcb_window_t;
  value_list: array[0..3] of cuint32;
begin
  wid := cuint(xcb_generate_id(display));
  value_list[0] := attributes^.background_pixel;
  value_list[1] := attributes^.event_mask;
  value_list[2] := attributes^.colormap;
  xcb_create_window(display, depth, wid, parent, x, y, width, height, border_width, window_class, visual^.visualid, valuemask, @value_list);
  Result := wid;
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

procedure XNextEvent(display: PDisplay; event_return: PXEvent); cdecl;
var
  ev: pxcb_generic_event_t;
  key_ev: pxcb_key_press_event_t;
  expose_ev: pxcb_expose_event_t;
  client_ev: pxcb_client_message_event_t;
begin
  // fred
  // ev := xcb_get_next_event(display);
  if ev <> nil then
  begin
    case ev^.response_type and $7F of
      2: // KeyPress
      begin
        event_return^._type := KeyPress;
        key_ev := pxcb_key_press_event_t(ev);
        event_return^.xkey._type := key_ev^.response_type;
        event_return^.xkey.serial := key_ev^.sequence;
        event_return^.xkey.send_event := (key_ev^.response_type and $80) ;
        event_return^.xkey.display := display;
        event_return^.xkey.window := key_ev^.event;
        event_return^.xkey.root := key_ev^.root;
        event_return^.xkey.subwindow := key_ev^.child;
        event_return^.xkey.time := key_ev^.time;
        event_return^.xkey.x := key_ev^.event_x;
        event_return^.xkey.y := key_ev^.event_y;
        event_return^.xkey.x_root := key_ev^.root_x;
        event_return^.xkey.y_root := key_ev^.root_y;
        event_return^.xkey.state := key_ev^.state;
        event_return^.xkey.keycode := key_ev^.detail;
        event_return^.xkey.same_screen := key_ev^.same_screen ;
      end;
      12: // Expose
      begin
        event_return^._type := Expose;
        expose_ev := pxcb_expose_event_t(ev);
        event_return^.xexpose._type := expose_ev^.response_type;
        event_return^.xexpose.serial := expose_ev^.sequence;
        event_return^.xexpose.send_event := (expose_ev^.response_type and $80) ;
        event_return^.xexpose.display := display;
        event_return^.xexpose.window := expose_ev^.window;
        event_return^.xexpose.x := expose_ev^.x;
        event_return^.xexpose.y := expose_ev^.y;
        event_return^.xexpose.width := expose_ev^.width;
        event_return^.xexpose.height := expose_ev^.height;
        event_return^.xexpose.count := expose_ev^.count;
      end;
      33: // ClientMessage
      begin
        event_return^._type := ClientMessage;
        client_ev := pxcb_client_message_event_t(ev);
        event_return^.xclient._type := client_ev^.response_type;
        event_return^.xclient.serial := client_ev^.sequence;
        event_return^.xclient.send_event := (client_ev^.response_type and $80) ;
        event_return^.xclient.display := display;
        event_return^.xclient.window := client_ev^.window;
        event_return^.xclient.message_type := client_ev^.type_;
        event_return^.xclient.format := client_ev^.format;
        case client_ev^.format of
          8: Move(client_ev^.data.data8, event_return^.xclient.data.b, 20);
          16: Move(client_ev^.data.data16, event_return^.xclient.data.s, 10);
          32: Move(client_ev^.data.data32, event_return^.xclient.data.l, 5);
        end;
      end;
    end;
    FreeMem(ev);
  end;
end;

function XPending(display: PDisplay): cint; cdecl;
begin
 // fred Result := xcb_events_queued(display, 0);
end;

function XInternAtom(display: PDisplay; atom_name: PChar; only_if_exists: tbool): Atom; cdecl;
var
  cookie: Pointer;
  reply: xcb_intern_atom_reply_t;
begin
  cookie := xcb_intern_atom(display, ord(only_if_exists), Length(atom_name), atom_name);
  reply := xcb_intern_atom_reply(display, cookie, nil);
  Result := reply.atom;
end;

function XGetWindowProperty(display: PDisplay; w: Window; atom_property: Atom; long_offset, long_length: culong;
                            delete: TBool; req_type: Atom; actual_type_return: PAtom; actual_format_return: Pcint;
                            nitems_return: Pculong; bytes_after_return: Pculong; prop_return: PPcuchar): cint; cdecl;
var
  cookie: Pointer;
  reply: xcb_get_property_reply_t;
begin
  cookie := xcb_get_property(display, ord(delete), w, atom_property, req_type, long_offset, long_length);
  reply := xcb_get_property_reply(display, cookie, nil);
  actual_type_return^ := reply.type_;
  actual_format_return^ := reply.format;
  nitems_return^ := reply.value_len;
  bytes_after_return^ := reply.bytes_after;
  prop_return^ := @reply.value;
  Result := 0; // Success
end;

function XSendEvent(display: PDisplay; w: Window; propagate: tbool; event_mask: clong; event_send: PXEvent): cint; cdecl;
var
  ev: xcb_client_message_event_t;
begin
  FillChar(ev, SizeOf(ev), 0);
  ev.response_type := ClientMessage;
  ev.window := w;
  ev.type_ := event_send^.xclient.message_type;
  ev.format := event_send^.xclient.format;
  case ev.format of
    8: Move(event_send^.xclient.data.b, ev.data.data8, 20);
    16: Move(event_send^.xclient.data.s, ev.data.data16, 10);
    32: Move(event_send^.xclient.data.l, ev.data.data32, 5);
  end;
  xcb_send_event(display, ord(propagate), w, event_mask, @ev);
  Result := 1; // Success
end;

function XChangeProperty(display: PDisplay; w: Window; atom_property: 
         Atom; type_: Atom; format: cint; mode: cint; data: Pcuchar; nelements: cint): cint; cdecl;
begin
result := 0;
  xcb_change_property(display, mode, w, atom_property, type_, format, nelements, data);
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
  reply := xcb_get_atom_name_reply(display, cookie, nil);
  Result := StrNew(reply.name);
end;

function XSetWMHints(display: PDisplay; w: Window; wmhints: PXWMHints): cint; cdecl;
var
  data: array[0..8] of cuint32;
begin
  data[0] := wmhints^.flags;
  data[1] := ord(wmhints^.input);
  data[2] := wmhints^.initial_state;
  data[3] := wmhints^.icon_pixmap;
  data[4] := wmhints^.icon_window;
  data[5] := wmhints^.icon_x;
  data[6] := wmhints^.icon_y;
  data[7] := wmhints^.icon_mask;
  data[8] := wmhints^.window_group;
  xcb_change_property(display, PropModeReplace, w, XA_WM_HINTS, XA_WM_HINTS, 32, 9, @data);
  Result := 1; // Success
end;

procedure XFree(data: Pointer); cdecl;
begin
  FreeMem(data);
end;

function XCreateGC(display: PDisplay; d: Drawable; valuemask: culong; values: PXGCValues): GC; cdecl;
var
  cid: xcb_gcontext_t;
  value_list: array[0..2] of cuint32;
begin
  cid := xcb_generate_id(display);
  value_list[0] := values^.foreground;
  value_list[1] := values^.background;
  value_list[2] := values^.font;
  xcb_create_gc(display, cid, d, valuemask, @value_list);
  Result := Pointer(cid);
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
  points: array[0..1] of record x, y: cint16; end;
begin
  points[0].x := x1;
  points[0].y := y1;
  points[1].x := x2;
  points[1].y := y2;
  xcb_poly_line(display, 0, d, xcb_gcontext_t(gc), 2, @points);
end;

function XLoadQueryFont(display: PDisplay; name: PChar): PXFontStruct; cdecl;
var
  font: xcb_font_t;
  cookie: Pointer;
  reply: xcb_query_font_reply_t;
  fs: PXFontStruct;
begin
  font := xcb_generate_id(display);
  xcb_open_font(display, font, Length(name), name);
  cookie := xcb_query_font(display, font);
  reply := xcb_query_font_reply(display, cookie, nil);
  New(fs);
  fs^.fid := font;
  fs^.ascent := reply.ascent;
  fs^.descent := reply.descent;
  Result := fs;
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

procedure XPutImage(display: PDisplay; d: Drawable; gc: GC; image: PXImage; src_x, src_y: cint; dest_x, dest_y: cint; width, height: cuint32); cdecl;
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
    ZPixmap: format := XCB_IMAGE_FORMAT_Z_PIXMAP;
    else
      Exit; // Invalid format
  end;

  // Get depth and data from XImage
  depth := image^.depth;
  data_len := image^.bytes_per_line * image^.height;
  left_pad := src_x; // Use src_x as left_pad for XY formats; 0 for ZPixmap
  if format = XCB_IMAGE_FORMAT_Z_PIXMAP then
    left_pad := 0;

  // Ensure width and height fit within cuint16
  if (width > High(cuint16)) or (height > High(cuint16)) then
    Exit;

  // Send the put image request
  cookie := xcb_put_image(c, format, d, gc_xcb, width, height, dest_x, dest_y, left_pad, depth, data_len, PByte(image^.data));

  // Check for errors
  err := xcb_request_check(c, cookie);
  if err <> nil then
  begin
    Freemem(err);
    // Optionally log error
  end;
end;

function XLookupString(event_struct: PXKeyPressedEvent; buffer_return: PChar; bytes_buffer: cint; keysym_return: Pculong; status_in_out: Pointer): cint; cdecl;
begin
  // XCB does not provide direct equivalent; requires XKBlib or manual key mapping
  Result := 0; // Placeholder
end;

function XCreateColormap(display: PDisplay; w: Window; visual: PVisual; alloc: cint): TColormap; cdecl;
var
  cmap: xcb_colormap_t;
begin
  cmap := xcb_generate_id(display);
  xcb_create_colormap(display, alloc, cmap, w, visual^.visualid);
  Result := cmap;
end;

procedure XFreeColormap(display: PDisplay; cmap: TColormap); cdecl;
begin
  xcb_free_colormap(display, cmap);
end;

function XCreatePixmap(display: PDisplay; d: Drawable; width, height, depth: cuint): TPixmap; cdecl;
var
  pid: xcb_pixmap_t;
begin
  pid := xcb_generate_id(display);
  xcb_create_pixmap(display, depth, pid, d, width, height);
  Result := pid;
end;

function XRenderCreatePicture(display: PDisplay; d: Drawable; format: PXRenderPictFormat; valuemask: culong; attributes: Pointer): TPicture; cdecl;
var
  pid: xcb_render_picture_t;
begin
  pid := xcb_generate_id(display);
  xcb_render_create_picture(display, pid, d, format^.id, valuemask, attributes);
  Result := pid;
end;

procedure XRenderFreePicture(display: PDisplay; picture: TPicture); cdecl;
begin
  xcb_render_free_picture(display, picture);
end;

procedure XRenderComposite(display: PDisplay; op: cint; src: TPicture; mask: TPicture; dst: TPicture; src_x, src_y, mask_x, mask_y, dst_x, dst_y: cint; width, height: cuint); cdecl;
begin
  xcb_render_composite(display, op, src, mask, dst, src_x, src_y, mask_x, mask_y, dst_x, dst_y, width, height);
end;

function XShapeQueryExtension(display: PDisplay; event_base, error_base: Pcint): TBoolResult; cdecl;
var
  cookie: Pointer;
  reply: xcb_shape_query_extension_reply_t;
begin
  // fred
  // cookie := xcb_shape_query_extension(display);
  // reply := xcb_shape_query_extension_reply(display, cookie, nil);
  event_base^ := reply.event_base;
  error_base^ := reply.error_base;
  Result := reply.present;
end;

function XShapeCombineRegion(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; region: TRegion; op: cint): TStatus; cdecl;
begin
  // xcb_shape_combine_region(display, op, dest_kind, dest, x, y, region);
  Result := 0; // Success
end;

procedure XShapeCombineRectangles(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; rectangles: PXRectangle; n_rects: cint; op: cint; ordering: cint); cdecl;
begin
  xcb_shape_rectangles(display, op, dest_kind, ordering, dest, x, y, n_rects, rectangles);
end;

procedure XShapeCombineMask(display: PDisplay; dest: Window; dest_kind: cint; x, y: cint; mask: TPixmap; op: cint); cdecl;
begin
  xcb_shape_mask(display, op, dest_kind, dest, x, y, mask);
end;

end.