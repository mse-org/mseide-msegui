{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryVideo
 *
 * SDL's video subsystem is largely interested in abstracting window
 * management from the underlying operating system. You can create windows,
 * manage them in various ways, set them fullscreen, and get events when
 * interesting things happen with them, such as the mouse or keyboard
 * interacting with a window.
 *
 * The video subsystem is also interested in abstracting away some
 * platform-specific differences in OpenGL: context creation, swapping
 * buffers, etc. This may be crucial to your app, but also you are not
 * required to use OpenGL at all. In fact, SDL can provide rendering to those
 * windows as well, either with an easy-to-use
 * [2D API](https://wiki.libsdl.org/SDL3/CategoryRender)
 * or with a more-powerful
 * [GPU API](https://wiki.libsdl.org/SDL3/CategoryGPU)
 * . Of course, it can simply get out of your way and give you the window
 * handles you need to use Vulkan, Direct3D, Metal, or whatever else you like
 * directly, too.
 *
 * The video subsystem covers a lot of functionality, out of necessity, so it
 * is worth perusing the list of functions just to see what's available, but
 * most apps can get by with simply creating a window and listening for
 * events, so start with SDL_CreateWindow() and SDL_PollEvent().
  }
{*
 * This is a unique ID for a display for the time it is connected to the
 * system, and is never reused for the lifetime of the application.
 *
 * If the display is disconnected and reconnected, it will get a new ID.
 *
 * The value 0 is an invalid ID.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_DisplayID = ^PSDL_DisplayID;
  PSDL_DisplayID = ^TSDL_DisplayID;
  TSDL_DisplayID = type cuint32;

{*
 * This is a unique ID for a window.
 *
 * The value 0 is an invalid ID.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
  PPSDL_WindowID = ^PSDL_WindowID;
  PSDL_WindowID = ^TSDL_WindowID;
  TSDL_WindowID = type cuint32;

{ Global video properties...  }

{*
 * The pointer to the global `wl_display` object used by the Wayland video
 * backend.
 *
 * Can be set before the video subsystem is initialized to import an
  external
 * `wl_display` object from an application or toolkit for use in SDL, or read
 * after initialization to export the `wl_display` used by the Wayland video
 * backend. Setting this property after the video subsystem has been
 * initialized has no effect, and reading it when the video subsystem is
 * uninitialized will either return the user provided value, if one was set
 * prior to initialization, or nil. See docs/README-wayland.md for more
 * information.
 *
 * \since This macro is available since SDL 3.2.0.
  }
const
  SDL_PROP_GLOBAL_VIDEO_WAYLAND_WL_DISPLAY_POINTER = 'SDL.video.wayland.wl_display';

{*
 * System theme.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_SystemTheme = ^PSDL_SystemTheme;
  PSDL_SystemTheme = ^TSDL_SystemTheme;
  TSDL_SystemTheme = type Integer;
const
  SDL_SYSTEM_THEME_UNKNOWN = TSDL_SystemTheme(0);  {*< Unknown system theme  }
  SDL_SYSTEM_THEME_LIGHT = TSDL_SystemTheme(1);    {*< Light colored system theme  }
  SDL_SYSTEM_THEME_DARK = TSDL_SystemTheme(2);     {*< Dark colored system theme  }

type
  PPSDL_DisplayModeData = ^PSDL_DisplayModeData;
  {**
   * Internal display mode data.
   *
   * This lives as a field in SDL_DisplayMode, as opaque data.
   *
   * \since This struct is available since SDL 3.2.0.
   *
   * \sa SDL_DisplayMode
   *}
  PSDL_DisplayModeData = type Pointer;

{*
 * The structure that defines a display mode.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GetFullscreenDisplayModes
 * \sa SDL_GetDesktopDisplayMode
 * \sa SDL_GetCurrentDisplayMode
 * \sa SDL_SetWindowFullscreenMode
 * \sa SDL_GetWindowFullscreenMode
  }
type
  PPSDL_DisplayMode = ^PSDL_DisplayMode;
  PSDL_DisplayMode = ^TSDL_DisplayMode;
  TSDL_DisplayMode = record
      displayID: TSDL_DisplayID;         {*< the display this mode is associated with  }
      format: TSDL_PixelFormat;          {*< pixel format  }
      w: cint;                           {*< width  }
      h: cint;                           {*< height  }
      pixel_density: cfloat;             {*< scale converting size to pixels (e.g. a 1920x1080 mode with 2.0 scale would have 3840x2160 pixels)  }
      refresh_rate: cfloat;              {*< refresh rate (or 0.0f for unspecified)  }
      refresh_rate_numerator: cint;      {*< precise refresh rate numerator (or 0 for unspecified)  }
      refresh_rate_denominator: cint;    {*< precise refresh rate denominator  }
      internal: PSDL_DisplayModeData;    {*< Private  }
    end;

{*
 * Display orientation values; the way a display is rotated.
 *
 * \since This enum is available since SDL 3.2.0.
  }
  PPSDL_DisplayOrientation = ^PSDL_DisplayOrientation;
  PSDL_DisplayOrientation = ^TSDL_DisplayOrientation;
  TSDL_DisplayOrientation =  type Integer;
const
  SDL_ORIENTATION_UNKNOWN = TSDL_DisplayOrientation(0);              {*< The display orientation can't be determined  }
  SDL_ORIENTATION_LANDSCAPE = TSDL_DisplayOrientation(1);            {*< The display is in landscape mode, with the right side up, relative to portrait mode  }
  SDL_ORIENTATION_LANDSCAPE_FLIPPED = TSDL_DisplayOrientation(2);    {*< The display is in landscape mode, with the left side up, relative to portrait mode  }
  SDL_ORIENTATION_PORTRAIT = TSDL_DisplayOrientation(3);             {*< The display is in portrait mode  }
  SDL_ORIENTATION_PORTRAIT_FLIPPED = TSDL_DisplayOrientation(4);     {*< The display is in portrait mode, upside down  }

{*
 * The struct used as an opaque handle to a window.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateWindow
  }
type
  PPSDL_Window = ^PSDL_Window;
  PSDL_Window = type Pointer;

{*
 * The flags on a window.
 *
 * These cover a lot of true/false, or on/off, window state. Some of it is
 * immutable after being set through SDL_CreateWindow(), some of it can be
 * changed on existing windows by the app, and some of it might be altered by
 * the user or system outside of the app's control.
 *
 * When creating windows with `SDL_WINDOW_RESIZABLE`, SDL will constrain
 * resizable windows to the dimensions recommended by the compositor to fit it
 * within the usable desktop space, although some compositors will do this
 * automatically without intervention as well. Use `SDL_SetWindowResizable`
 * after creation instead if you wish to create a window with a specific size.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFlags
  }
type
  PPSDL_WindowFlags = ^PSDL_WindowFlags;
  PSDL_WindowFlags = ^TSDL_WindowFlags;
  TSDL_WindowFlags = type cuint64;

const
  SDL_WINDOW_FULLSCREEN = TSDL_WindowFlags($0000000000000001);              {*< window is in fullscreen mode  }
  SDL_WINDOW_OPENGL = TSDL_WindowFlags($0000000000000002);                  {*< window usable with OpenGL context  }
  SDL_WINDOW_OCCLUDED = TSDL_WindowFlags($0000000000000004);                {*< window is occluded  }
  SDL_WINDOW_HIDDEN = TSDL_WindowFlags($0000000000000008);                  {*< window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible  }
  SDL_WINDOW_BORDERLESS = TSDL_WindowFlags($0000000000000010);              {*< no window decoration  }
  SDL_WINDOW_RESIZABLE = TSDL_WindowFlags($0000000000000020);               {*< window can be resized  }
  SDL_WINDOW_MINIMIZED = TSDL_WindowFlags($0000000000000040);               {*< window is minimized  }
  SDL_WINDOW_MAXIMIZED = TSDL_WindowFlags($0000000000000080);               {*< window is maximized  }
  SDL_WINDOW_MOUSE_GRABBED = TSDL_WindowFlags($0000000000000100);           {*< window has grabbed mouse input  }
  SDL_WINDOW_INPUT_FOCUS = TSDL_WindowFlags($0000000000000200);             {*< window has input focus  }
  SDL_WINDOW_MOUSE_FOCUS = TSDL_WindowFlags($0000000000000400);             {*< window has mouse focus  }
  SDL_WINDOW_EXTERNAL = TSDL_WindowFlags($0000000000000800);                {*< window not created by SDL  }
  SDL_WINDOW_MODAL = TSDL_WindowFlags($0000000000001000);                   {*< window is modal  }
  SDL_WINDOW_HIGH_PIXEL_DENSITY = TSDL_WindowFlags($0000000000002000);      {*< window uses high pixel density back buffer if possible  }
  SDL_WINDOW_MOUSE_CAPTURE = TSDL_WindowFlags($0000000000004000);           {*< window has mouse captured (unrelated to MOUSE_GRABBED)  }
  SDL_WINDOW_MOUSE_RELATIVE_MODE = TSDL_WindowFlags($0000000000008000);     {*< window has relative mode enabled  }
  SDL_WINDOW_ALWAYS_ON_TOP = TSDL_WindowFlags($0000000000010000);           {*< window should always be above others  }
  SDL_WINDOW_UTILITY = TSDL_WindowFlags($0000000000020000);                 {*< window should be treated as a utility window, not showing in the task bar and window list  }
  SDL_WINDOW_TOOLTIP = TSDL_WindowFlags($0000000000040000);                 {*< window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window  }
  SDL_WINDOW_POPUP_MENU = TSDL_WindowFlags($0000000000080000);              {*< window should be treated as a popup menu, requires a parent window  }
  SDL_WINDOW_KEYBOARD_GRABBED = TSDL_WindowFlags($0000000000100000);        {*< window has grabbed keyboard input  }
  SDL_WINDOW_FILL_DOCUMENT = TSDL_WindowFlags($0000000000200000);           {*< window is in fill-document mode (Emscripten only), since SDL 3.4.0  }
  SDL_WINDOW_VULKAN = TSDL_WindowFlags($0000000010000000);                  {*< window usable for Vulkan surface  }
  SDL_WINDOW_METAL = TSDL_WindowFlags($0000000020000000);                   {*< window usable for Metal view  }
  SDL_WINDOW_TRANSPARENT = TSDL_WindowFlags($0000000040000000);             {*< window with transparent buffer  }
  SDL_WINDOW_NOT_FOCUSABLE = TSDL_WindowFlags($0000000080000000);           {*< window should not be focusable  }

{*
 * A magic value used with SDL_WINDOWPOS_UNDEFINED.
 *
 * Generally this macro isn't used directly, but rather through
 * SDL_WINDOWPOS_UNDEFINED or SDL_WINDOWPOS_UNDEFINED_DISPLAY.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
  }
const SDL_WINDOWPOS_UNDEFINED_MASK = $1FFF0000;

{*
 * Used to indicate that you don't care what the window position is.
 *
 * If you _really_ don't care, SDL_WINDOWPOS_UNDEFINED is the same, but always
 * uses the primary display instead of specifying one.
 *
 * \param X the SDL_DisplayID of the display to use.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
 *}
function SDL_WINDOWPOS_UNDEFINED_DISPLAY(X: Integer): Integer;

{*
 * Used to indicate that you don't care what the window position/display is.
 *
 * This always uses the primary display.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
 *}
const SDL_WINDOWPOS_UNDEFINED = SDL_WINDOWPOS_UNDEFINED_MASK or 0;  // SDL3 for Pascal: No function call SDL_WINDOWPOS_UNDEFINED_DISPLAY(0) for performance

{*
 * A macro to test if the window position is marked as "undefined."
 *
 * \param X the window position value.
 *
 * \since This macro is available since SDL 3.2.0.
  *
 * \sa SDL_SetWindowPosition
 *}
function SDL_WINDOWPOS_ISUNDEFINED(X: Integer): Boolean;

{*
 * A magic value used with SDL_WINDOWPOS_CENTERED.
 *
 * Generally this macro isn't used directly, but rather through
 * SDL_WINDOWPOS_CENTERED or SDL_WINDOWPOS_CENTERED_DISPLAY.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
 *}
const SDL_WINDOWPOS_CENTERED_MASK = $2FFF0000;

{*
 * Used to indicate that the window position should be centered.
 *
 * SDL_WINDOWPOS_CENTERED is the same, but always uses the primary display
 * instead of specifying one.
 *
 * \param X the SDL_DisplayID of the display to use.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
 *}
function SDL_WINDOWPOS_CENTERED_DISPLAY(X: Integer): Integer;

{*
 * Used to indicate that the window position should be centered.
 *
 * This always uses the primary display.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
 *}
const SDL_WINDOWPOS_CENTERED = SDL_WINDOWPOS_CENTERED_MASK or 0;   // SDL3 for Pascal: No function call SDL_WINDOWPOS_CENTERED_DISPLAY(0) for performance

{*
 * A macro to test if the window position is marked as "centered."
 *
 * \param X the window position value.
 *
 * \since This macro is available since SDL 3.2.0.
  *
 * \sa SDL_SetWindowPosition
 *}
function SDL_WINDOWPOS_ISCENTERED(X: Integer): Boolean;

{*
 * Window flash operation.
 *
 * \since This enum is available since SDL 3.2.0.
  }

type
  PPSDL_FlashOperation = ^PSDL_FlashOperation;
  PSDL_FlashOperation = ^TSDL_FlashOperation;
  TSDL_FlashOperation =  type Integer;
  const
    SDL_FLASH_CANCEL = TSDL_FlashOperation(0);              {*< Cancel any window flash state  }
    SDL_FLASH_BRIEFLY = TSDL_FlashOperation(1);             {*< Flash the window briefly to get attention  }
    SDL_FLASH_UNTIL_FOCUSED = TSDL_FlashOperation(2);       {*< Flash the window until it gets focus  }

{*
 * Window progress state
 *
 * \since This enum is available since SDL 3.2.8.
  }
type
  PPSDL_ProgressState = ^PSDL_ProgressState;
  PSDL_ProgressState = ^TSDL_ProgressState;
  TSDL_ProgressState = type Integer;
const
  SDL_PROGRESS_STATE_INVALID = TSDL_ProgressState(-1);       {*< An invalid progress state indicating an error; check SDL_GetError()  }
  SDL_PROGRESS_STATE_NONE = TSDL_ProgressState(0);           {*< No progress bar is shown  }
  SDL_PROGRESS_STATE_INDETERMINATE = TSDL_ProgressState(1);  {*< The progress bar is shown in a indeterminate state  }
  SDL_PROGRESS_STATE_NORMAL = TSDL_ProgressState(2);         {*< The progress bar is shown in a normal state  }
  SDL_PROGRESS_STATE_PAUSED = TSDL_ProgressState(3);        {*< The progress bar is shown in a paused state  }
  SDL_PROGRESS_STATE_ERROR = TSDL_ProgressState(4);         {*< The progress bar is shown in a state indicating the application had an error  }

type
  PPSDL_GLContext = ^PSDL_GLContext;
  PSDL_GLContext = ^TSDL_GLContext;
  {*
   * An opaque handle to an OpenGL context.
   *
   * \since This datatype is available since SDL 3.2.0.
   *
   * \sa SDL_GL_CreateContext
   * \sa SDL_GL_SetAttribute
   * \sa SDL_GL_MakeCurrent
   * \sa SDL_GL_DestroyContext
   *}
  TSDL_GLContext = type Pointer;

  PPSDL_EGLDisplay = ^PSDL_EGLDisplay;
  PSDL_EGLDisplay = ^TSDL_EGLDisplay;
  {*
   * Opaque type for an EGL display.
   *
   * \since This datatype is available since SDL 3.2.0.
   *}
  TSDL_EGLDisplay = type Pointer;

  PPSDL_EGLConfig = ^PSDL_EGLConfig;
  PSDL_EGLConfig = ^TSDL_EGLConfig;
  {*
   * Opaque type for an EGL config.
   *
   * \since This datatype is available since SDL 3.2.0.
   *}
  TSDL_EGLConfig = type Pointer;

  PPSDL_EGLSurface = ^PSDL_EGLSurface;
  PSDL_EGLSurface = ^TSDL_EGLSurface;
  {*
   * Opaque type for an EGL surface.
   *
   * \since This datatype is available since SDL 3.2.0.
   *}
  TSDL_EGLSurface = type Pointer;

  PPSDL_EGLAttrib = ^PSDL_EGLAttrib;
  PSDL_EGLAttrib = ^TSDL_EGLAttrib;
  {*
   * An EGL attribute, used when creating an EGL context.
   *
   * \since This datatype is available since SDL 3.2.0.
   *}
  TSDL_EGLAttrib = type cintptr_t;

  PPSDL_EGLint = ^PSDL_EGLint;
  PSDL_EGLint = ^TSDL_EGLint;
  {*
   * An EGL integer attribute, used when creating an EGL surface.
   *
   * \since This datatype is available since SDL 3.2.0.
   *}
  TSDL_EGLint = type cint;

{*
 * EGL platform attribute initialization callback.
 *
 * This is called when SDL is attempting to create an EGL context, to let the
 * app add extra attributes to its eglGetPlatformDisplay() call.
 *
 * The callback should return a Pointer to an EGL attribute array terminated
 * with `EGL_NONE`. If this function returns nil, the SDL_CreateWindow
 * process will fail gracefully.
 *
 * The returned Pointer should be allocated with SDL_malloc() and will be
 * passed to SDL_free().
 *
 * The arrays returned by each callback will be appended to the existing
 * attribute arrays defined by SDL.
 *
 * \param userdata an app-controlled Pointer that is passed to the callback.
 * \returns a newly-allocated array of attributes, terminated with `EGL_NONE`.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_EGL_SetAttributeCallbacks
  }
type
  PPSDL_EGLAttribArrayCallback = ^PSDL_EGLAttribArrayCallback;
  PSDL_EGLAttribArrayCallback = ^TSDL_EGLAttribArrayCallback;
  TSDL_EGLAttribArrayCallback = function(userdata: Pointer): PSDL_EGLAttrib; cdecl;

{*
 * EGL surface/context attribute initialization callback types.
 *
 * This is called when SDL is attempting to create an EGL surface, to let the
 * app add extra attributes to its eglCreateWindowSurface() or
 * eglCreateContext calls.
 *
 * For convenience, the EGLDisplay and EGLConfig to use are provided to the
 * callback.
 *
 * The callback should return a Pointer to an EGL attribute array terminated
 * with `EGL_NONE`. If this function returns nil, the SDL_CreateWindow
 * process will fail gracefully.
 *
 * The returned Pointer should be allocated with SDL_malloc() and will be
 * passed to SDL_free().
 *
 * The arrays returned by each callback will be appended to the existing
 * attribute arrays defined by SDL.
 *
 * \param userdata an app-controlled Pointer that is passed to the callback.
 * \param display the EGL display to be used.
 * \param config the EGL config to be used.
 * \returns a newly-allocated array of attributes, terminated with `EGL_NONE`.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_EGL_SetAttributeCallbacks
  }
  PPSDL_EGLIntArrayCallback = ^PSDL_EGLIntArrayCallback;
  PSDL_EGLIntArrayCallback = ^TSDL_EGLIntArrayCallback;
  TSDL_EGLIntArrayCallback = function (userdata: Pointer; display: TSDL_EGLDisplay; config: TSDL_EGLConfig): PSDL_EGLint; cdecl;

{*
 * An enumeration of OpenGL configuration attributes.
 *
 * While you can set most OpenGL attributes normally, the attributes listed
 * above must be known before SDL creates the window that will be used with
 * the OpenGL context. These attributes are set and read with
 * SDL_GL_SetAttribute() and SDL_GL_GetAttribute().
 *
 * In some cases, these attributes are minimum requests; the GL does not
 * promise to give you exactly what you asked for. It's possible to ask for a
 * 16-bit depth buffer and get a 24-bit one instead, for example, or to ask
 * for no stencil buffer and still have one available. Context creation should
 * fail if the GL can't provide your requested attributes at a minimum, but
 * you should check to see exactly what you got.
 *
 * \since This enum is available since SDL 3.2.0.
  }
  PPSDL_GLAttr = ^PSDL_GLAttr;
  PSDL_GLAttr = ^TSDL_GLAttr;
  TSDL_GLAttr =  Integer;
const
  SDL_GL_RED_SIZE = TSDL_GLAttr(0);                        {*< the minimum number of bits for the red channel of the color buffer; defaults to 8.  }
  SDL_GL_GREEN_SIZE = TSDL_GLAttr(1);                      {*< the minimum number of bits for the green channel of the color buffer; defaults to 8.  }
  SDL_GL_BLUE_SIZE = TSDL_GLAttr(2);                       {*< the minimum number of bits for the blue channel of the color buffer; defaults to 8.  }
  SDL_GL_ALPHA_SIZE = TSDL_GLAttr(3);                      {*< the minimum number of bits for the alpha channel of the color buffer; defaults to 8.  }
  SDL_GL_BUFFER_SIZE = TSDL_GLAttr(4);                     {*< the minimum number of bits for frame buffer size; defaults to 0.  }
  SDL_GL_DOUBLEBUFFER = TSDL_GLAttr(5);                    {*< whether the output is single or double buffered; defaults to double buffering on.  }
  SDL_GL_DEPTH_SIZE = TSDL_GLAttr(6);                      {*< the minimum number of bits in the depth buffer; defaults to 16.  }
  SDL_GL_STENCIL_SIZE = TSDL_GLAttr(7);                    {*< the minimum number of bits in the stencil buffer; defaults to 0.  }
  SDL_GL_ACCUM_RED_SIZE = TSDL_GLAttr(8);                  {*< the minimum number of bits for the red channel of the accumulation buffer; defaults to 0.  }
  SDL_GL_ACCUM_GREEN_SIZE = TSDL_GLAttr(9);                {*< the minimum number of bits for the green channel of the accumulation buffer; defaults to 0.  }
  SDL_GL_ACCUM_BLUE_SIZE = TSDL_GLAttr(10);                {*< the minimum number of bits for the blue channel of the accumulation buffer; defaults to 0.  }
  SDL_GL_ACCUM_ALPHA_SIZE = TSDL_GLAttr(11);               {*< the minimum number of bits for the alpha channel of the accumulation buffer; defaults to 0.  }
  SDL_GL_STEREO = TSDL_GLAttr(12);                         {*< whether the output is stereo 3D; defaults to off.  }
  SDL_GL_MULTISAMPLEBUFFERS = TSDL_GLAttr(13);             {*< the number of buffers used for multisample anti-aliasing; defaults to 0.  }
  SDL_GL_MULTISAMPLESAMPLES = TSDL_GLAttr(14);             {*< the number of samples used around the current pixel used for multisample anti-aliasing.  }
  SDL_GL_ACCELERATED_VISUAL = TSDL_GLAttr(15);             {*< set to 1 to require hardware acceleration, set to 0 to force software rendering; defaults to allow either.  }
  SDL_GL_RETAINED_BACKING = TSDL_GLAttr(16);               {*< not used (deprecated).  }
  SDL_GL_CONTEXT_MAJOR_VERSION = TSDL_GLAttr(17);          {*< OpenGL context major version.  }
  SDL_GL_CONTEXT_MINOR_VERSION = TSDL_GLAttr(18);          {*< OpenGL context minor version.  }
  SDL_GL_CONTEXT_FLAGS = TSDL_GLAttr(19);                  {*< some combination of 0 or more of elements of the SDL_GLContextFlag enumeration; defaults to 0.  }
  SDL_GL_CONTEXT_PROFILE_MASK = TSDL_GLAttr(20);           {*< type of GL context (Core, Compatibility, ES). See SDL_GLProfile; default value depends on platform.  }
  SDL_GL_SHARE_WITH_CURRENT_CONTEXT = TSDL_GLAttr(21);     {*< OpenGL context sharing; defaults to 0.  }
  SDL_GL_FRAMEBUFFER_SRGB_CAPABLE = TSDL_GLAttr(22);       {*< requests sRGB capable visual; defaults to 0.  }
  SDL_GL_CONTEXT_RELEASE_BEHAVIOR = TSDL_GLAttr(23);       {*< sets context the release behavior. See SDL_GLContextReleaseFlag; defaults to FLUSH.  }
  SDL_GL_CONTEXT_RESET_NOTIFICATION = TSDL_GLAttr(24);     {*< set context reset notification. See SDL_GLContextResetNotification; defaults to NO_NOTIFICATION.  }
  SDL_GL_CONTEXT_NO_ERROR = TSDL_GLAttr(25);
  SDL_GL_FLOATBUFFERS = TSDL_GLAttr(26);
  SDL_GL_EGL_PLATFORM = TSDL_GLAttr(27);

{*
 * Possible values to be set for the SDL_GL_CONTEXT_PROFILE_MASK attribute.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_GLProfile = ^PSDL_GLProfile;
  PSDL_GLProfile = ^TSDL_GLProfile;
  TSDL_GLProfile = cuint32;

const
  SDL_GL_CONTEXT_PROFILE_CORE = TSDL_GLProfile($0001);           {*< OpenGL Core Profile context  }
  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY = TSDL_GLProfile($0002);  {*< OpenGL Compatibility Profile context  }
  SDL_GL_CONTEXT_PROFILE_ES = TSDL_GLProfile($0004);             {*< GLX_CONTEXT_ES2_PROFILE_BIT_EXT  }

{*
 * Possible flags to be set for the SDL_GL_CONTEXT_FLAGS attribute.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_GLContextFlag = ^PSDL_GLContextFlag;
  PSDL_GLContextFlag = ^TSDL_GLContextFlag;
  TSDL_GLContextFlag = cuint32;

const
  SDL_GL_CONTEXT_DEBUG_FLAG = TSDL_GLContextFlag($0001);
  SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = TSDL_GLContextFlag($0002);
  SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG = TSDL_GLContextFlag($0004);
  SDL_GL_CONTEXT_RESET_ISOLATION_FLAG = TSDL_GLContextFlag($0008);
{*
 * Possible values to be set for the SDL_GL_CONTEXT_RELEASE_BEHAVIOR
 * attribute.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_GLContextReleaseFlag = ^PSDL_GLContextReleaseFlag;
  PSDL_GLContextReleaseFlag = ^TSDL_GLContextReleaseFlag;
  TSDL_GLContextReleaseFlag = cuint32;

const
  SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE = TSDL_GLContextReleaseFlag($0000);
  SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = TSDL_GLContextReleaseFlag($0001);

{*
 * Possible values to be set SDL_GL_CONTEXT_RESET_NOTIFICATION attribute.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_GLContextResetNotification = ^PSDL_GLContextResetNotification;
  PSDL_GLContextResetNotification = ^TSDL_GLContextResetNotification;
  TSDL_GLContextResetNotification = cuint32;

const
  SDL_GL_CONTEXT_RESET_NO_NOTIFICATION = TSDL_GLContextResetNotification($0000);
  SDL_GL_CONTEXT_RESET_LOSE_CONTEXT = TSDL_GLContextResetNotification($0001);

{ Function prototypes  }

{*
 * Get the number of video drivers compiled into SDL.
 *
 * \returns the number of built in video drivers.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetVideoDriver
  }
function SDL_GetNumVideoDrivers: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumVideoDrivers' {$ENDIF} {$ENDIF};

{*
 * Get the name of a built in video driver.
 *
 * The video drivers are presented in the order in which they are normally
 * checked during initialization.
 *
 * The names of drivers are all simple, low-ASCII identifiers, like "cocoa",
 * "x11" or "windows". These never have Unicode characters, and are not meant
 * to be proper names.
 *
 * \param index the index of a video driver.
 * \returns the name of the video driver with the given **index**. , or NULL if
 *          index is out of bounds.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumVideoDrivers
  }
function SDL_GetVideoDriver(index: cint): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetVideoDriver' {$ENDIF} {$ENDIF};

{*
 * Get the name of the currently initialized video driver.
 *
 * The names of drivers are all simple, low-ASCII identifiers, like "cocoa",
 * "x11" or "windows". These never have Unicode characters, and are not meant
 * to be proper names.
 *
 * \returns the name of the current video driver or nil if no driver has been
 *          initialized.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumVideoDrivers
 * \sa SDL_GetVideoDriver
  }
function SDL_GetCurrentVideoDriver: PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentVideoDriver' {$ENDIF} {$ENDIF};

{*
 * Get the current system theme.
 *
 * \returns the current system theme, light, dark, or unknown.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSystemTheme: TSDL_SystemTheme; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSystemTheme' {$ENDIF} {$ENDIF};

{*
 * Get a list of currently connected displays.
 *
 * \param count a Pointer filled in with the number of displays returned, may
 *              be nil.
 * \returns a 0 terminated array of display instance IDs or nil on failure;
 *          call SDL_GetError() for more information. This should be freed
 *          with SDL_free() when it is no longer needed.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetDisplays(count: pcint): PSDL_DisplayID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplays' {$ENDIF} {$ENDIF};

{*
 * Return the primary display.
 *
 * \returns the instance ID of the primary display on success or 0 on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplays
  }
function SDL_GetPrimaryDisplay: TSDL_DisplayID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPrimaryDisplay' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a display.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN`: true if the display has HDR
 *   headroom above the SDR white point. This is for informational and
 *   diagnostic purposes only, as not all platforms provide this information
 *   at the display level.
 *
 * On KMS/DRM:
 *
 * - `SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER`: the "panel
 *   orientation" property for the display in degrees of clockwise rotation.
 *   Note that this is provided only as a hint, and the application is
 *   responsible for any coordinate transformations needed to conform to the
 *   requested display orientation.
 *
 * On Wayland:
 *
 * - `SDL_PROP_DISPLAY_WAYLAND_WL_OUTPUT_POINTER`: the wl_output associated
 *   with the display
 *
 * On Windows:
 *
 * - `SDL_PROP_DISPLAY_WINDOWS_HMONITOR_POINTER`: the monitor handle
 *   (HMONITOR) associated with the display
 *
 * \param displayID the instance ID of the display to query.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetDisplayProperties(displayID: TSDL_DisplayID): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN = 'SDL.display.HDR_enabled';
  SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER = 'SDL.display.KMSDRM.panel_orientation';
  SDL_PROP_DISPLAY_WAYLAND_WL_OUTPUT_POINTER = 'SDL.display.wayland.wl_output';
  SDL_PROP_DISPLAY_WINDOWS_HMONITOR_POINTER = 'SDL.display.windows.hmonitor';

{*
 * Get the name of a display in UTF-8 encoding.
 *
 * \param displayID the instance ID of the display to query.
 * \returns the name of a display or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayName(displayID: TSDL_DisplayID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayName' {$ENDIF} {$ENDIF};

{*
 * Get the desktop area represented by a display.
 *
 * The primary display is often located at (0,0), but may be placed at a
 * different location depending on monitor layout.
 *
 * \param displayID the instance ID of the display to query.
 * \param rect the SDL_Rect structure filled in with the display bounds.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplayUsableBounds
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayBounds(displayID: TSDL_DisplayID; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayBounds' {$ENDIF} {$ENDIF};

{*
 * Get the usable desktop area represented by a display, in screen
 * coordinates.
 *
 * This is the same area as SDL_GetDisplayBounds() reports, but with portions
 * reserved by the system removed. For example, on Apple's macOS, this
 * subtracts the area occupied by the menu bar and dock.
 *
 * Setting a window to be fullscreen generally bypasses these unusable areas,
 * so these are good guidelines for the maximum space available to a
 * non-fullscreen window.
 *
 * \param displayID the instance ID of the display to query.
 * \param rect the SDL_Rect structure filled in with the display bounds.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplayBounds
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayUsableBounds(displayID: TSDL_DisplayID; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayUsableBounds' {$ENDIF} {$ENDIF};

{*
 * Get the orientation of a display when it is unrotated.
 *
 * \param displayID the instance ID of the display to query.
 * \returns the SDL_DisplayOrientation enum value of the display, or
 *          `SDL_ORIENTATION_UNKNOWN` if it isn't available.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplays
  }
function SDL_GetNaturalDisplayOrientation(displayID: TSDL_DisplayID): TSDL_DisplayOrientation; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNaturalDisplayOrientation' {$ENDIF} {$ENDIF};

{*
 * Get the orientation of a display.
 *
 * \param displayID the instance ID of the display to query.
 * \returns the SDL_DisplayOrientation enum value of the display, or
 *          `SDL_ORIENTATION_UNKNOWN` if it isn't available.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplays
  }
function SDL_GetCurrentDisplayOrientation(displayID: TSDL_DisplayID): TSDL_DisplayOrientation; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentDisplayOrientation' {$ENDIF} {$ENDIF};

{*
 * Get the content scale of a display.
 *
 * The content scale is the expected scale for content based on the DPI
 * settings of the display. For example, a 4K display might have a 2.0 (200%)
 * display scale, which means that the user expects UI elements to be twice as
 * big on this display, to aid in readability.
 *
 * After window creation, SDL_GetWindowDisplayScale() should be used to query
 * the content scale factor for individual windows instead of querying the
 * display for a window and calling this function, as the per-window content
 * scale factor may differ from the base value of the display it is on,
 * particularly on high-DPI and/or multi-monitor desktop configurations.
 *
 * \param displayID the instance ID of the display to query.
 * \returns the content scale of the display, or 0.0f on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowDisplayScale
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayContentScale(displayID: TSDL_DisplayID): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayContentScale' {$ENDIF} {$ENDIF};

{*
 * Get a list of fullscreen display modes available on a display.
 *
 * The display modes are sorted in this priority:
 *
 * - w -> largest to smallest
 * - h -> largest to smallest
 * - bits per pixel -> more colors to fewer colors
 * - packed pixel layout -> largest to smallest
 * - refresh rate -> highest to lowest
 * - pixel density -> lowest to highest
 *
 * \param displayID the instance ID of the display to query.
 * \param count a Pointer filled in with the number of display modes returned,
 *              may be nil.
 * \returns a nil terminated array of display mode pointers or nil on
 *          failure; call SDL_GetError() for more information. This is a
 *          single allocation that should be freed with SDL_free() when it is
 *          no longer needed.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplays
  }
function SDL_GetFullscreenDisplayModes(displayID: TSDL_DisplayID; count: pcint): PPSDL_DisplayMode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetFullscreenDisplayModes' {$ENDIF} {$ENDIF};

{*
 * Get the closest match to the requested display mode.
 *
 * The available display modes are scanned and `closest` is filled in with the
 * closest mode matching the requested mode and returned. The mode format and
 * refresh rate default to the desktop mode if they are set to 0. The modes
 * are scanned with size being first priority, format being second priority,
 * and finally checking the refresh rate. If all the available modes are too
 * small, then false is returned.
 *
 * \param displayID the instance ID of the display to query.
 * \param w the width in pixels of the desired display mode.
 * \param h the height in pixels of the desired display mode.
 * \param refresh_rate the refresh rate of the desired display mode, or 0.0f
 *                     for the desktop refresh rate.
 * \param include_high_density_modes boolean to include high density modes in
 *                                   the search.
 * \param closest a Pointer filled in with the closest display mode equal to
 *                or larger than the desired mode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplays
 * \sa SDL_GetFullscreenDisplayModes
  }
function SDL_GetClosestFullscreenDisplayMode(displayID: TSDL_DisplayID; w: cint; h: cint; refresh_rate: cfloat; include_high_density_modes: Boolean; closest: PSDL_DisplayMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetClosestFullscreenDisplayMode' {$ENDIF} {$ENDIF};

{*
 * Get information about the desktop's display mode.
 *
 * There's a difference between this function and SDL_GetCurrentDisplayMode()
 * when SDL runs fullscreen and has changed the resolution. In that case this
 * function will return the previous native display mode, and not the current
 * display mode.
 *
 * \param displayID the instance ID of the display to query.
 * \returns a Pointer to the desktop display mode or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCurrentDisplayMode
 * \sa SDL_GetDisplays
  }
function SDL_GetDesktopDisplayMode(displayID: TSDL_DisplayID): PSDL_DisplayMode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDesktopDisplayMode' {$ENDIF} {$ENDIF};

{*
 * Get information about the current display mode.
 *
 * There's a difference between this function and SDL_GetDesktopDisplayMode()
 * when SDL runs fullscreen and has changed the resolution. In that case this
 * function will return the current display mode, and not the previous native
 * display mode.
 *
 * \param displayID the instance ID of the display to query.
 * \returns a Pointer to the desktop display mode or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDesktopDisplayMode
 * \sa SDL_GetDisplays
  }
function SDL_GetCurrentDisplayMode(displayID: TSDL_DisplayID): PSDL_DisplayMode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentDisplayMode' {$ENDIF} {$ENDIF};

{*
 * Get the display containing a point.
 *
 * \param point the point to query.
 * \returns the instance ID of the display containing the point or 0 on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplayBounds
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayForPoint(point: PSDL_Point): TSDL_DisplayID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayForPoint' {$ENDIF} {$ENDIF};

{*
 * Get the display primarily containing a rect.
 *
 * \param rect the rect to query.
 * \returns the instance ID of the display entirely containing the rect or
 *          closest to the center of the rect on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplayBounds
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayForRect(rect: PSDL_Rect): TSDL_DisplayID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayForRect' {$ENDIF} {$ENDIF};

{*
 * Get the display associated with a window.
 *
 * \param window the window to query.
 * \returns the instance ID of the display containing the center of the window
 *          on success or 0 on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDisplayBounds
 * \sa SDL_GetDisplays
  }
function SDL_GetDisplayForWindow(window: PSDL_Window): TSDL_DisplayID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDisplayForWindow' {$ENDIF} {$ENDIF};

{*
 * Get the pixel density of a window.
 *
 * This is a ratio of pixel size to window size. For example, if the window is
 * 1920x1080 and it has a high density back buffer of 3840x2160 pixels, it
 * would have a pixel density of 2.0.
 *
 * \param window the window to query.
 * \returns the pixel density or 0.0f on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowDisplayScale
  }
function SDL_GetWindowPixelDensity(window: PSDL_Window): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowPixelDensity' {$ENDIF} {$ENDIF};

{*
 * Get the content display scale relative to a window's pixel size.
 *
 * This is a combination of the window pixel density and the display content
 * scale, and is the expected scale for displaying content in this window. For
 * example, if a 3840x2160 window had a display scale of 2.0, the user expects
 * the content to take twice as many pixels and be the same physical size as
 * if it were being displayed in a 1920x1080 window with a display scale of
 * 1.0.
 *
 * Conceptually this value corresponds to the scale display setting, and is
 * updated when that setting is changed, or the window moves to a display with
 * a different scale setting.
 *
 * \param window the window to query.
 * \returns the display scale, or 0.0f on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetWindowDisplayScale(window: PSDL_Window): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowDisplayScale' {$ENDIF} {$ENDIF};

{*
 * Set the display mode to use when a window is visible and fullscreen.
 *
 * This only affects the display mode used when the window is fullscreen. To
 * change the window size when the window is not fullscreen, use
 * SDL_SetWindowSize().
 *
 * If the window is currently in the fullscreen state, this request is
 * asynchronous on some windowing systems and the new mode dimensions may not
 * be applied immediately upon the return of this function. If an immediate
 * change is required, call SDL_SyncWindow() to block until the changes have
 * taken effect.
 *
 * When the new mode takes effect, an SDL_EVENT_WINDOW_RESIZED and/or an
 * SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED event will be emitted with the new mode
 * dimensions.
 *
 * \param window the window to affect.
 * \param mode a Pointer to the display mode to use, which can be nil for
 *             borderless fullscreen desktop mode, or one of the fullscreen
 *             modes returned by SDL_GetFullscreenDisplayModes() to set an
 *             exclusive fullscreen mode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFullscreenMode
 * \sa SDL_SetWindowFullscreen
 * \sa SDL_SyncWindow
  }
function SDL_SetWindowFullscreenMode(window: PSDL_Window; mode: PSDL_DisplayMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowFullscreenMode' {$ENDIF} {$ENDIF};

{*
 * Query the display mode to use when a window is visible at fullscreen.
 *
 * \param window the window to query.
 * \returns a Pointer to the exclusive fullscreen mode to use or nil for
 *          borderless fullscreen desktop mode.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowFullscreenMode
 * \sa SDL_SetWindowFullscreen
  }
function SDL_GetWindowFullscreenMode(window: PSDL_Window): PSDL_DisplayMode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowFullscreenMode' {$ENDIF} {$ENDIF};

{*
 * Get the raw ICC profile data for the screen the window is currently on.
 *
 * \param window the window to query.
 * \param size the size of the ICC profile.
 * \returns the raw ICC profile data on success or nil on failure; call
 *          SDL_GetError() for more information. This should be freed with
 *          SDL_free() when it is no longer needed.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetWindowICCProfile(window: PSDL_Window; size: pcsize_t): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowICCProfile' {$ENDIF} {$ENDIF};

{*
 * Get the pixel format associated with the window.
 *
 * \param window the window to query.
 * \returns the pixel format of the window on success or
 *          SDL_PIXELFORMAT_UNKNOWN on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetWindowPixelFormat(window: PSDL_Window): TSDL_PixelFormat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowPixelFormat' {$ENDIF} {$ENDIF};

{*
 * Get a list of valid windows.
 *
 * \param count a Pointer filled in with the number of windows returned, may
 *              be nil.
 * \returns a nil terminated array of SDL_Window pointers or nil on failure;
 *          call SDL_GetError() for more information. This is a single
 *          allocation that should be freed with SDL_free() when it is no
 *          longer needed.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetWindows(count: pcint): PPSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindows' {$ENDIF} {$ENDIF};

{*
 * Create a window with the specified dimensions and flags.
 *
 * The window size is a request and may be different than expected based on
 * the desktop layout and window manager policies. Your application should be
 * prepared to handle a window of any size.
 *
 * `flags` may be any of the following OR'd together:
 *
 * - SDL_WINDOW_FULLSCREEN: fullscreen window at desktop resolution
 * - SDL_WINDOW_OPENGL: window usable with an OpenGL context
 * - SDL_WINDOW_HIDDEN: window is not visible
 * - SDL_WINDOW_BORDERLESS: no window decoration
 * - SDL_WINDOW_RESIZABLE: window can be resized
 * - SDL_WINDOW_MINIMIZED: window is minimized
 * - SDL_WINDOW_MAXIMIZED: window is maximized
 * - SDL_WINDOW_MOUSE_GRABBED: window has grabbed mouse focus
 * - SDL_WINDOW_INPUT_FOCUS: window has input focus
 * - SDL_WINDOW_MOUSE_FOCUS: window has mouse focus
 * - SDL_WINDOW_EXTERNAL: window not created by SDL
 * - SDL_WINDOW_MODAL: window is modal
 * - SDL_WINDOW_HIGH_PIXEL_DENSITY: window uses high pixel density back
 *   buffer if possible
 * - SDL_WINDOW_MOUSE_CAPTURE: window has mouse captured (unrelated to
 *   MOUSE_GRABBED)
 * - SDL_WINDOW_ALWAYS_ON_TOP: window should always be above others
 * - SDL_WINDOW_UTILITY: window should be treated as a utility window, not
 *   showing in the task bar and window list
 * - SDL_WINDOW_TOOLTIP: window should be treated as a tooltip and does not
 *   get mouse or keyboard focus, requires a parent window
 * - SDL_WINDOW_POPUP_MENU: window should be treated as a popup menu,
 *   requires a parent window
 * - SDL_WINDOW_KEYBOARD_GRABBED: window has grabbed keyboard input
 * - SDL_WINDOW_VULKAN: window usable with a Vulkan instance
 * - SDL_WINDOW_METAL: window usable with a Metal instance
 * - SDL_WINDOW_TRANSPARENT: window with transparent buffer
 * - SDL_WINDOW_NOT_FOCUSABLE: window should not be focusable
 *
 * The SDL_Window will be shown if SDL_WINDOW_HIDDEN is not set. If hidden at
 * creation time, SDL_ShowWindow() can be used to show it later.
 *
 * On Apple's macOS, you **must** set the NSHighResolutionCapable Info.plist
 * property to YES, otherwise you will not receive a High-DPI OpenGL canvas.
 *
 * The window pixel size may differ from its window coordinate size if the
 * window is on a high pixel density display. Use SDL_GetWindowSize() to query
 * the client area's size in window coordinates, and
 * SDL_GetWindowSizeInPixels() or SDL_GetRenderOutputSize() to query the
 * drawable size in pixels. Note that the drawable size can vary after the
 * window is created and should be queried again if you get an
 * SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED event.
 *
 * If the window is created with any of the SDL_WINDOW_OPENGL or
 * SDL_WINDOW_VULKAN flags, then the corresponding LoadLibrary function
 * (SDL_GL_LoadLibrary or SDL_Vulkan_LoadLibrary) is called and the
 * corresponding UnloadLibrary function is called by SDL_DestroyWindow().
 *
 * If SDL_WINDOW_VULKAN is specified and there isn't a working Vulkan driver,
 * SDL_CreateWindow() will fail, because SDL_Vulkan_LoadLibrary() will fail.
 *
 * If SDL_WINDOW_METAL is specified on an OS that does not support Metal,
 * SDL_CreateWindow() will fail.
 *
 * If you intend to use this window with an SDL_Renderer, you should use
 * SDL_CreateWindowAndRenderer() instead of this function, to avoid window
 * flicker.
 *
 * On non-Apple devices, SDL requires you to either not link to the Vulkan
 * loader or link to a dynamic library version. This limitation may be removed
 * in a future version of SDL.
 *
 * \param title the title of the window, in UTF-8 encoding.
 * \param w the width of the window.
 * \param h the height of the window.
 * \param flags 0, or one or more SDL_WindowFlags OR'd together.
 * \returns the window that was created or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateWindowAndRenderer
 * \sa SDL_CreatePopupWindow
 * \sa SDL_CreateWindowWithProperties
 * \sa SDL_DestroyWindow
  }
function SDL_CreateWindow(title: PAnsiChar; w: cint; h: cint; flags: TSDL_WindowFlags): PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateWindow' {$ENDIF} {$ENDIF};

{*
 * Create a child popup window of the specified parent window.
 *
 * The window size is a request and may be different than expected based on
 * the desktop layout and window manager policies. Your application should be
 * prepared to handle a window of any size.
 *
 * The flags parameter **must** contain at least one of the following:
 *
 * - `SDL_WINDOW_TOOLTIP`: The popup window is a tooltip and will not pass any
 *   input events.
 * - `SDL_WINDOW_POPUP_MENU`: The popup window is a popup menu. The topmost
 *   popup menu will implicitly gain the keyboard focus.
 *
 * The following flags are not relevant to popup window creation and will be
 * ignored:
 *
 * - `SDL_WINDOW_MINIMIZED`
 * - `SDL_WINDOW_MAXIMIZED`
 * - `SDL_WINDOW_FULLSCREEN`
 * - `SDL_WINDOW_BORDERLESS`
 *
 * The following flags are incompatible with popup window creation and will
 * cause it to fail:
 *
 * - `SDL_WINDOW_UTILITY`
 * - `SDL_WINDOW_MODAL`
 *
 * The parent parameter **must** be non-null and a valid window. The parent of
 * a popup window can be either a regular, toplevel window, or another popup
 * window.
 *
 * Popup windows cannot be minimized, maximized, made fullscreen, raised,
 * flash, be made a modal window, be the parent of a toplevel window, or grab
 * the mouse and/or keyboard. Attempts to do so will fail.
 *
 * Popup windows implicitly do not have a border/decorations and do not appear
 * on the taskbar/dock or in lists of windows such as alt-tab menus.
 *
 * By default, popup window positions will automatically be constrained to
 * keep the entire window within display bounds. This can be overridden with
 * the `SDL_PROP_WINDOW_CREATE_CONSTRAIN_POPUP_BOOLEAN` property.
 *
 * By default, popup menus will automatically grab keyboard focus from the
 * parent when shown. This behavior can be overridden by setting the
 * `SDL_WINDOW_NOT_FOCUSABLE` flag, setting the
 * `SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN` property to false, or toggling
 * it after creation via the `SDL_SetWindowFocusable()` function.
 *
 * If a parent window is hidden or destroyed, any child popup windows will be
 * recursively hidden or destroyed as well. Child popup windows not explicitly
 * hidden will be restored when the parent is shown.
 *
 * \param parent the parent of the window, must not be nil.
 * \param offset_x the x position of the popup window relative to the origin
 *                 of the parent.
 * \param offset_y the y position of the popup window relative to the origin
 *                 of the parent window.
 * \param w the width of the window.
 * \param h the height of the window.
 * \param flags SDL_WINDOW_TOOLTIP or SDL_WINDOW_POPUP_MENU, and zero or more
 *              additional SDL_WindowFlags OR'd together.
 * \returns the window that was created or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateWindow
 * \sa SDL_CreateWindowWithProperties
 * \sa SDL_DestroyWindow
 * \sa SDL_GetWindowParent
  }
function SDL_CreatePopupWindow(parent: PSDL_Window; offset_x: cint; offset_y: cint; w: cint; h: cint; flags: TSDL_WindowFlags): PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreatePopupWindow' {$ENDIF} {$ENDIF};

{*
 * Create a window with the specified properties.
 *
 * The window size is a request and may be different than expected based on
 * the desktop layout and window manager policies. Your application should be
 * prepared to handle a window of any size.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN`: true if the window should
 *   be always on top
 * - `SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN`: true if the window has no
 *   window decoration
 * - `SDL_PROP_WINDOW_CREATE_CONSTRAIN_POPUP_BOOLEAN`: true if the "tooltip"
 *   and "menu" window types should be automatically constrained to be
 *   entirely within display bounds (default), false if no constraints on the
 *   position are desired.
 * - `SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN`: true if the
 *   window will be used with an
  externally managed graphics context.
 * - `SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN`: true if the window should
 *   accept keyboard input (defaults true)
 * - `SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN`: true if the window should
 *   start in fullscreen mode at desktop resolution
 * - `SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER`: the height of the window
 * - `SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN`: true if the window should start
 *   hidden
 * - `SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN`: true if the window
 *   uses a high pixel density buffer if possible
 * - `SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN`: true if the window should
 *   start maximized
 * - `SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN`: true if the window is a popup menu
 * - `SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN`: true if the window will be used
 *   with Metal rendering
 * - `SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN`: true if the window should
 *   start minimized
 * - `SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN`: true if the window is modal to
 *   its parent
 * - `SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN`: true if the window starts
 *   with grabbed mouse focus
 * - `SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN`: true if the window will be used
 *   with OpenGL rendering
 * - `SDL_PROP_WINDOW_CREATE_PARENT_POINTER`: an SDL_Window that will be the
 *   parent of this window, required for windows with the "tooltip", "menu",
 *   and "modal" properties
 * - `SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN`: true if the window should be
 *   resizable
 * - `SDL_PROP_WINDOW_CREATE_TITLE_STRING`: the title of the window, in UTF-8
 *   encoding
 * - `SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN`: true if the window show
 *   transparent in the areas with alpha of 0
 * - `SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN`: true if the window is a tooltip
 * - `SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN`: true if the window is a utility
 *   window, not showing in the task bar and window list
 * - `SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN`: true if the window will be used
 *   with Vulkan rendering
 * - `SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER`: the width of the window
 * - `SDL_PROP_WINDOW_CREATE_X_NUMBER`: the x position of the window, or
 *   `SDL_WINDOWPOS_CENTERED`, defaults to `SDL_WINDOWPOS_UNDEFINED`. This is
 *   relative to the parent for windows with the "tooltip" or "menu" property
 *   set.
 * - `SDL_PROP_WINDOW_CREATE_Y_NUMBER`: the y position of the window, or
 *   `SDL_WINDOWPOS_CENTERED`, defaults to `SDL_WINDOWPOS_UNDEFINED`. This is
 *   relative to the parent for windows with the "tooltip" or "menu" property
 *   set.
 *
 * These are additional supported properties on macOS:
 *
 * - `SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER`: the
 *   `(__unsafe_unretained)` NSWindow associated with the window, if you want
 *   to wrap an existing window.
 * - `SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER`: the `(__unsafe_unretained)`
 *   NSView associated with the window, defaults to `[window contentView]`
 *
 * These are additional supported properties on iOS, tvOS, and visionOS:
 *
 * - `SDL_PROP_WINDOW_CREATE_WINDOWSCENE_POINTER`: the `(__unsafe_unretained)`
 *   UIWindowScene associated with the window, defaults to the active window
 *   scene.
 *
 * These are additional supported properties on Wayland:
 *
 * - `SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN` - true if
 *   the application wants to use the Wayland surface for a custom role and
 *   does not want it attached to an XDG toplevel window. See
 *   [README/wayland](README/wayland) for more information on using custom
 *   surfaces.
 * - `SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN` - true if the
 *   application wants an associated `wl_egl_window` object to be created and
 *   attached to the window, even if the window does not have the OpenGL
 *   property or `SDL_WINDOW_OPENGL` flag set.
 * - `SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER` - the wl_surface
 *   associated with the window, if you want to wrap an existing window. See
 *   [README/wayland](README/wayland) for more information.
 *
 * These are additional supported properties on Windows:
 *
 * - `SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER`: the HWND associated with the
 *   window, if you want to wrap an existing window.
 * - `SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER`: optional,
 *   another window to share pixel format with, useful for OpenGL windows
 *
 * These are additional supported properties with X11:
 *
 * - `SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER`: the X11 Window associated
 *   with the window, if you want to wrap an existing window.
 *
 * The window is implicitly shown if the "hidden" property is not set.
 *
 * These are additional supported properties with Emscripten:
 *
 * - `SDL_PROP_WINDOW_CREATE_EMSCRIPTEN_CANVAS_ID_STRING`: the id given to the
 *   canvas element. This should start with a '#' sign
 * - `SDL_PROP_WINDOW_CREATE_EMSCRIPTEN_KEYBOARD_ELEMENT_STRING`: override the
 *   binding element for keyboard inputs for this canvas. The variable can be
 *   one of:
 * - "#window": the javascript window object (default)
 * - "#document": the javascript document object
 * - "#screen": the javascript window.screen object
 * - "#canvas": the WebGL canvas element
 * - "#none": Don't bind anything at all
 * - any other string without a leading # sign applies to the element on the
 *   page with that ID. Windows with the "tooltip" and "menu" properties are
 *   popup windows and have the behaviors and guidelines outlined in
 *   SDL_CreatePopupWindow().
 *
 * If this window is being created to be used with an SDL_Renderer, you should
 * not add a graphics API specific property
 * (`SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN`, etc), as SDL will handle that
 * internally when it chooses a renderer. However, SDL might need to recreate
 * your window at that point, which may cause the window to appear briefly,
 * and then flicker as it is recreated. The correct approach to this is to
 * create the window with the `SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN` property
 * set to true, then create the renderer, then show the window with
 * SDL_ShowWindow().
 *
 * \param props the properties to use.
 * \returns the window that was created or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProperties
 * \sa SDL_CreateWindow
 * \sa SDL_DestroyWindow
  }
function SDL_CreateWindowWithProperties(props: TSDL_PropertiesID): PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateWindowWithProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN = 'SDL.window.create.always_on_top';
  SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN = 'SDL.window.create.borderless';
  SDL_PROP_WINDOW_CREATE_CONSTRAIN_POPUP_BOOLEAN = 'SDL.window.create.constrain_popup';
  SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN = 'SDL.window.create.focusable';
  SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN = 'SDL.window.create.external_graphics_context';
  SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER = 'SDL.window.create.flags';
  SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN = 'SDL.window.create.fullscreen';
  SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER = 'SDL.window.create.height';
  SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN = 'SDL.window.create.hidden';
  SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN = 'SDL.window.create.high_pixel_density';
  SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN = 'SDL.window.create.maximized';
  SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN = 'SDL.window.create.menu';
  SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN = 'SDL.window.create.metal';
  SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN = 'SDL.window.create.minimized';
  SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN = 'SDL.window.create.modal';
  SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN = 'SDL.window.create.mouse_grabbed';
  SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN = 'SDL.window.create.opengl';
  SDL_PROP_WINDOW_CREATE_PARENT_POINTER = 'SDL.window.create.parent';
  SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN = 'SDL.window.create.resizable';
  SDL_PROP_WINDOW_CREATE_TITLE_STRING = 'SDL.window.create.title';
  SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN = 'SDL.window.create.transparent';
  SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN = 'SDL.window.create.tooltip';
  SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN = 'SDL.window.create.utility';
  SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN = 'SDL.window.create.vulkan';
  SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER = 'SDL.window.create.width';
  SDL_PROP_WINDOW_CREATE_X_NUMBER = 'SDL.window.create.x';
  SDL_PROP_WINDOW_CREATE_Y_NUMBER = 'SDL.window.create.y';
  SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER = 'SDL.window.create.cocoa.window';
  SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER = 'SDL.window.create.cocoa.view';
  SDL_PROP_WINDOW_CREATE_WINDOWSCENE_POINTER = 'SDL.window.create.uikit.windowscene';
  SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN = 'SDL.window.create.wayland.surface_role_custom';
  SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN = 'SDL.window.create.wayland.create_egl_window';
  SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER = 'SDL.window.create.wayland.wl_surface';
  SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER = 'SDL.window.create.win32.hwnd';
  SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER = 'SDL.window.create.win32.pixel_format_hwnd';
  SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER = 'SDL.window.create.x11.window';
  SDL_PROP_WINDOW_CREATE_EMSCRIPTEN_CANVAS_ID_STRING ='SDL.window.create.emscripten.canvas_id';
  SDL_PROP_WINDOW_CREATE_EMSCRIPTEN_KEYBOARD_ELEMENT_STRING = 'SDL.window.create.emscripten.keyboard_element';


{*
 * Get the numeric ID of a window.
 *
 * The numeric ID is what SDL_WindowEvent references, and is necessary to map
 * these events to specific SDL_Window objects.
 *
 * \param window the window to query.
 * \returns the ID of the window on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFromID
  }
function SDL_GetWindowID(window: PSDL_Window): TSDL_WindowID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowID' {$ENDIF} {$ENDIF};

{*
 * Get a window from a stored ID.
 *
 * The numeric ID is what SDL_WindowEvent references, and is necessary to map
 * these events to specific SDL_Window objects.
 *
 * \param id the ID of the window.
 * \returns the window associated with `id` or nil if it doesn't exist; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowID
  }
function SDL_GetWindowFromID(id: TSDL_WindowID): PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowFromID' {$ENDIF} {$ENDIF};

{*
 * Get parent of a window.
 *
 * \param window the window to query.
 * \returns the parent of the window on success or nil if the window has no
 *          parent.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreatePopupWindow
  }
function SDL_GetWindowParent(window: PSDL_Window): PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowParent' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a window.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_WINDOW_SHAPE_POINTER`: the surface associated with a shaped
 *   window
 * - `SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN`: true if the window has HDR
 *   headroom above the SDR white point. This property can change dynamically
 *   when SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
 * - `SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT`: the value of SDR white in the
 *   SDL_COLORSPACE_SRGB_LINEAR colorspace. On Windows this corresponds to the
 *   SDR white level in scRGB colorspace, and on Apple platforms this is
 *   always 1.0 for EDR content. This property can change dynamically when
 *   SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
 * - `SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT`: the additional high dynamic range
 *   that can be displayed, in terms of the SDR white point. When HDR is not
 *   enabled, this will be 1.0. This property can change dynamically when
 *   SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
 *
 * On Android:
 *
 * - `SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER`: the ANativeWindow associated
 *   with the window
 * - `SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER`: the EGLSurface associated with
 *   the window
 *
 * On iOS:
 *
 * - `SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER`: the `(__unsafe_unretained)`
 *   UIWindow associated with the window
 * - `SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER`: the NSInteger tag
 *   associated with metal views on the window
 * - `SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER`: the OpenGL view's
 *   framebuffer object. It must be bound when rendering to the screen using
 *   OpenGL.
 * - `SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER`: the OpenGL view's
 *   renderbuffer object. It must be bound when SDL_GL_SwapWindow is called.
 * - `SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER`: the OpenGL
 *   view's resolve framebuffer, when MSAA is used.
 *
 * On KMS/DRM:
 *
 * - `SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER`: the device index associated
 *   with the window (e.g. the X in /dev/dri/cardX)
 * - `SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER`: the DRM FD associated with the
 *   window
 * - `SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER`: the GBM device associated
 *   with the window
 *
 * On macOS:
 *
 * - `SDL_PROP_WINDOW_COCOA_WINDOW_POINTER`: the `(__unsafe_unretained)`
 *   NSWindow associated with the window
 * - `SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER`: the NSInteger tag
 *   assocated with metal views on the window
 *
 * On OpenVR:
 *
 * - `SDL_PROP_WINDOW_OPENVR_OVERLAY_ID_NUMBER`: the OpenVR Overlay Handle ID for the
 *   associated overlay window.
 *
 * On Vivante:
 *
 * - `SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER`: the EGLNativeDisplayType
 *   associated with the window
 * - `SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER`: the EGLNativeWindowType
 *   associated with the window
 * - `SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER`: the EGLSurface associated with
 *   the window
 *
 * On Windows:
 *
 * - `SDL_PROP_WINDOW_WIN32_HWND_POINTER`: the HWND associated with the window
 * - `SDL_PROP_WINDOW_WIN32_HDC_POINTER`: the HDC associated with the window
 * - `SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER`: the HINSTANCE associated with
 *   the window
 *
 * On Wayland:
 *
 * Note: The `xdg_*` window objects do not internally persist across window
 * show/hide calls. They will be null if the window is hidden and must be
 * queried each time it is shown.
 *
 * - `SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER`: the wl_display associated with
 *   the window
 * - `SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER`: the wl_surface associated with
 *   the window
 * - `SDL_PROP_WINDOW_WAYLAND_VIEWPORT_POINTER`: the wp_viewport associated
 *   with the window
 * - `SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER`: the wl_egl_window
 *   associated with the window
 * - `SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER`: the xdg_surface associated
 *   with the window
 * - `SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER`: the xdg_toplevel role
 *   associated with the window
 * - 'SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING': the export
 *   handle associated with the window
 * - `SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER`: the xdg_popup role
 *   associated with the window
 * - `SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER`: the xdg_positioner
 *   associated with the window, in popup mode
 *
 * On X11:
 *
 * - `SDL_PROP_WINDOW_X11_DISPLAY_POINTER`: the X11 Display associated with
 *   the window
 * - `SDL_PROP_WINDOW_X11_SCREEN_NUMBER`: the screen number associated with
 *   the window
 * - `SDL_PROP_WINDOW_X11_WINDOW_NUMBER`: the X11 Window associated with the
 *   window
 *
 * On Emscripten:
 *
 * - `SDL_PROP_WINDOW_EMSCRIPTEN_CANVAS_ID_STRING`: the id the canvas element
 *   will have
 * - `SDL_PROP_WINDOW_EMSCRIPTEN_KEYBOARD_ELEMENT_STRING`: the keyboard
 *   element that associates keyboard events to this window
 *
 * \param window the window to query.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetWindowProperties(window: PSDL_Window): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_WINDOW_SHAPE_POINTER = 'SDL.window.shape';
  SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN = 'SDL.window.HDR_enabled';
  SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT = 'SDL.window.SDR_white_level';
  SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT = 'SDL.window.HDR_headroom';
  SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER = 'SDL.window.android.window';
  SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER = 'SDL.window.android.surface';
  SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER = 'SDL.window.uikit.window';
  SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER = 'SDL.window.uikit.metal_view_tag';
  SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER = 'SDL.window.uikit.opengl.framebuffer';
  SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER = 'SDL.window.uikit.opengl.renderbuffer';
  SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER = 'SDL.window.uikit.opengl.resolve_framebuffer';
  SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER = 'SDL.window.kmsdrm.dev_index';
  SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER = 'SDL.window.kmsdrm.drm_fd';
  SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER = 'SDL.window.kmsdrm.gbm_dev';
  SDL_PROP_WINDOW_COCOA_WINDOW_POINTER = 'SDL.window.cocoa.window';
  SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER = 'SDL.window.cocoa.metal_view_tag';
  SDL_PROP_WINDOW_OPENVR_OVERLAY_ID_NUMBER = 'SDL.window.openvr.overlay_id';
  SDL_PROP_WINDOW_OPENVR_OVERLAY_ID = 'SDL.window.openvr.overlay_id';
  SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER = 'SDL.window.vivante.display';
  SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER = 'SDL.window.vivante.window';
  SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER = 'SDL.window.vivante.surface';
  SDL_PROP_WINDOW_WIN32_HWND_POINTER = 'SDL.window.win32.hwnd';
  SDL_PROP_WINDOW_WIN32_HDC_POINTER = 'SDL.window.win32.hdc';
  SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER = 'SDL.window.win32.instance';
  SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER = 'SDL.window.wayland.display';
  SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER = 'SDL.window.wayland.surface';
  SDL_PROP_WINDOW_WAYLAND_VIEWPORT_POINTER = 'SDL.window.wayland.viewport';
  SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER = 'SDL.window.wayland.egl_window';
  SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER = 'SDL.window.wayland.xdg_surface';
  SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER = 'SDL.window.wayland.xdg_toplevel';
  SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING = 'SDL.window.wayland.xdg_toplevel_export_handle';
  SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER = 'SDL.window.wayland.xdg_popup';
  SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER = 'SDL.window.wayland.xdg_positioner';
  SDL_PROP_WINDOW_X11_DISPLAY_POINTER = 'SDL.window.x11.display';
  SDL_PROP_WINDOW_X11_SCREEN_NUMBER = 'SDL.window.x11.screen';
  SDL_PROP_WINDOW_X11_WINDOW_NUMBER = 'SDL.window.x11.window';
  SDL_PROP_WINDOW_EMSCRIPTEN_CANVAS_ID_STRING = 'SDL.window.emscripten.canvas_id';
  SDL_PROP_WINDOW_EMSCRIPTEN_KEYBOARD_ELEMENT_STRING = 'SDL.window.emscripten.keyboard_element';

{*
 * Get the window flags.
 *
 * \param window the window to query.
 * \returns a mask of the SDL_WindowFlags associated with `window`.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateWindow
 * \sa SDL_HideWindow
 * \sa SDL_MaximizeWindow
 * \sa SDL_MinimizeWindow
 * \sa SDL_SetWindowFullscreen
 * \sa SDL_SetWindowMouseGrab
 * \sa SDL_SetWindowFillDocument
 * \sa SDL_ShowWindow
  }
function SDL_GetWindowFlags(window: PSDL_Window): TSDL_WindowFlags; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowFlags' {$ENDIF} {$ENDIF};

{*
 * Set the title of a window.
 *
 * This string is expected to be in UTF-8 encoding.
 *
 * \param window the window to change.
 * \param title the desired window title in UTF-8 format.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowTitle
  }
function SDL_SetWindowTitle(window: PSDL_Window; title: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowTitle' {$ENDIF} {$ENDIF};

{*
 * Get the title of a window.
 *
 * \param window the window to query.
 * \returns the title of the window in UTF-8 format or "" if there is no
 *          title.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowTitle
  }
function SDL_GetWindowTitle(window: PSDL_Window): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowTitle' {$ENDIF} {$ENDIF};

{*
 * Set the icon for a window.
 *
 * If this function is passed a surface with alternate representations added
 * using SDL_AddSurfaceAlternateImage(), the surface will be interpreted as
 * the content to be used for 100% display scale, and the alternate
 * representations will be used for high DPI situations. For example, if the
 * original surface is 32x32, then on a 2x macOS display or 200% display scale
 * on Windows, a 64x64 version of the image will be used, if available. If a
 * matching version of the image isn't available, the closest larger size
 * image will be downscaled to the appropriate size and be used instead, if
 * available. Otherwise, the closest smaller image will be upscaled and be
 * used instead.
 *
 * \param window the window to change.
 * \param icon an SDL_Surface structure containing the icon for the window.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddSurfaceAlternateImage
  }
function SDL_SetWindowIcon(window: PSDL_Window; icon: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowIcon' {$ENDIF} {$ENDIF};

{*
 * Request that the window's position be set.
 *
 * If the window is in an exclusive fullscreen or maximized state, this
 * request has no effect.
 *
 * This can be used to reposition fullscreen-desktop windows onto a different
 * display, however, as exclusive fullscreen windows are locked to a specific
 * display, they can only be repositioned programmatically via
 * SDL_SetWindowFullscreenMode().
 *
 * On some windowing systems this request is asynchronous and the new
 * coordinates may not have have been applied immediately upon the return of
 * this function. If an immediate change is required, call SDL_SyncWindow() to
 * block until the changes have taken effect.
 *
 * When the window position changes, an SDL_EVENT_WINDOW_MOVED event will be
 * emitted with the window's new coordinates. Note that the new coordinates
 * may not match the exact coordinates requested, as some windowing systems
 * can restrict the position of the window in certain scenarios (e.g.
 * constraining the position so the window is always within desktop bounds).
 * Additionally, as this is just a request, it can be denied by the windowing
 * system.
 *
 * \param window the window to reposition.
 * \param x the x coordinate of the window, or `SDL_WINDOWPOS_CENTERED` or
 *          `SDL_WINDOWPOS_UNDEFINED`.
 * \param y the y coordinate of the window, or `SDL_WINDOWPOS_CENTERED` or
 *          `SDL_WINDOWPOS_UNDEFINED`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowPosition
 * \sa SDL_SyncWindow
  }
function SDL_SetWindowPosition(window: PSDL_Window; x: cint; y: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowPosition' {$ENDIF} {$ENDIF};

{*
 * Get the position of a window.
 *
 * This is the current position of the window as last reported by the
 * windowing system.
 *
 * If you do not need the value for one of the positions a nil may be passed
 * in the `x` or `y` parameter.
 *
 * \param window the window to query.
 * \param x a Pointer filled in with the x position of the window, may be
 *          nil.
 * \param y a Pointer filled in with the y position of the window, may be
 *          nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowPosition
  }
function SDL_GetWindowPosition(window: PSDL_Window; x: pcint; y: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowPosition' {$ENDIF} {$ENDIF};

{*
 * Request that the size of a window's client area be set.
 *
 * If the window is in a fullscreen or maximized state, this request has no
 * effect.
 *
 * To change the exclusive fullscreen mode of a window, use
 * SDL_SetWindowFullscreenMode().
 *
 * On some windowing systems, this request is asynchronous and the new window
 * size may not have have been applied immediately upon the return of this
 * function. If an immediate change is required, call SDL_SyncWindow() to
 * block until the changes have taken effect.
 *
 * When the window size changes, an SDL_EVENT_WINDOW_RESIZED event will be
 * emitted with the new window dimensions. Note that the new dimensions may
 * not match the exact size requested, as some windowing systems can restrict
 * the window size in certain scenarios (e.g. constraining the size of the
 * content area to remain within the usable desktop bounds). Additionally, as
 * this is just a request, it can be denied by the windowing system.
 *
 * \param window the window to change.
 * \param w the width of the window, must be > 0.
 * \param h the height of the window, must be > 0.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSize
 * \sa SDL_SetWindowFullscreenMode
 * \sa SDL_SyncWindow
  }
function SDL_SetWindowSize(window: PSDL_Window; w: cint; h: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowSize' {$ENDIF} {$ENDIF};

{*
 * Get the size of a window's client area.
 *
 * The window pixel size may differ from its window coordinate size if the
 * window is on a high pixel density display. Use SDL_GetWindowSizeInPixels()
 * or SDL_GetRenderOutputSize() to get the real client area size in pixels.
 *
 * \param window the window to query the width and height from.
 * \param w a Pointer filled in with the width of the window, may be nil.
 * \param h a Pointer filled in with the height of the window, may be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderOutputSize
 * \sa SDL_GetWindowSizeInPixels
 * \sa SDL_SetWindowSize
 * \sa SDL_EVENT_WINDOW_RESIZED
  }
function SDL_GetWindowSize(window: PSDL_Window; w: pcint; h: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowSize' {$ENDIF} {$ENDIF};

{*
 * Get the safe area for this window.
 *
 * Some devices have portions of the screen which are partially obscured or
 * not interactive, possibly due to on-screen controls, curved edges, camera
 * notches, TV overscan, etc. This function provides the area of the window
 * which is safe to have interactable content. You should continue rendering
 * into the rest of the window, but it should not contain visually important
 * or interactible content.
 *
 * \param window the window to query.
 * \param rect a Pointer filled in with the client area that is safe for
 *             interactive content.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetWindowSafeArea(window: PSDL_Window; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowSafeArea' {$ENDIF} {$ENDIF};

{*
 * Request that the aspect ratio of a window's client area be set.
 *
 * The aspect ratio is the ratio of width divided by height, e.g. 2560x1600
 * would be 1.6. Larger aspect ratios are wider and smaller aspect ratios are
 * narrower.
 *
 * If, at the time of this request, the window in a fixed-size state, such as
 * maximized or fullscreen, the request will be deferred until the window
 * exits this state and becomes resizable again.
 *
 * On some windowing systems, this request is asynchronous and the new window
 * aspect ratio may not have have been applied immediately upon the return of
 * this function. If an immediate change is required, call SDL_SyncWindow() to
 * block until the changes have taken effect.
 *
 * When the window size changes, an SDL_EVENT_WINDOW_RESIZED event will be
 * emitted with the new window dimensions. Note that the new dimensions may
 * not match the exact aspect ratio requested, as some windowing systems can
 * restrict the window size in certain scenarios (e.g. constraining the size
 * of the content area to remain within the usable desktop bounds).
 * Additionally, as this is just a request, it can be denied by the windowing
 * system.
 *
 * \param window the window to change.
 * \param min_aspect the minimum aspect ratio of the window, or 0.0f for no
 *                   limit.
 * \param max_aspect the maximum aspect ratio of the window, or 0.0f for no
 *                   limit.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowAspectRatio
 * \sa SDL_SyncWindow
  }
function SDL_SetWindowAspectRatio(window: PSDL_Window; min_aspect: cfloat; max_aspect: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowAspectRatio' {$ENDIF} {$ENDIF};

{*
 * Get the aspect ratio of a window's client area.
 *
 * \param window the window to query the width and height from.
 * \param min_aspect a Pointer filled in with the minimum aspect ratio of the
 *                   window, may be nil.
 * \param max_aspect a Pointer filled in with the maximum aspect ratio of the
 *                   window, may be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowAspectRatio
  }
function SDL_GetWindowAspectRatio(window: PSDL_Window; min_aspect: pcfloat; max_aspect: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowAspectRatio' {$ENDIF} {$ENDIF};

{*
 * Get the size of a window's borders (decorations) around the client area.
 *
 * Note: If this function fails (returns false), the size values will be
 * initialized to 0, 0, 0, 0 (if a non-nil Pointer is provided), as if the
 * window in question was borderless.
 *
 * Note: This function may fail on systems where the window has not yet been
 * decorated by the display server (for example, immediately after calling
 * SDL_CreateWindow). It is recommended that you wait at least until the
 * window has been presented and composited, so that the window system has a
 * chance to decorate the window and provide the border dimensions to SDL.
 *
 * This function also returns false if getting the information is not
 * supported.
 *
 * \param window the window to query the size values of the border
 *               (decorations) from.
 * \param top Pointer to variable for storing the size of the top border; nil
 *            is permitted.
 * \param left Pointer to variable for storing the size of the left border;
 *             nil is permitted.
 * \param bottom Pointer to variable for storing the size of the bottom
 *               border; nil is permitted.
 * \param right Pointer to variable for storing the size of the right border;
 *              nil is permitted.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSize
  }
function SDL_GetWindowBordersSize(window: PSDL_Window; top: pcint; left: pcint; bottom: pcint; right: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowBordersSize' {$ENDIF} {$ENDIF};

{*
 * Get the size of a window's client area, in pixels.
 *
 * \param window the window from which the drawable size should be queried.
 * \param w a Pointer to variable for storing the width in pixels, may be
 *          nil.
 * \param h a Pointer to variable for storing the height in pixels, may be
 *          nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateWindow
 * \sa SDL_GetWindowSize
  }
function SDL_GetWindowSizeInPixels(window: PSDL_Window; w: pcint; h: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowSizeInPixels' {$ENDIF} {$ENDIF};

{*
 * Set the minimum size of a window's client area.
 *
 * \param window the window to change.
 * \param min_w the minimum width of the window, or 0 for no limit.
 * \param min_h the minimum height of the window, or 0 for no limit.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMinimumSize
 * \sa SDL_SetWindowMaximumSize
  }
function SDL_SetWindowMinimumSize(window: PSDL_Window; min_w: cint; min_h: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowMinimumSize' {$ENDIF} {$ENDIF};

{*
 * Get the minimum size of a window's client area.
 *
 * \param window the window to query.
 * \param w a Pointer filled in with the minimum width of the window, may be
 *          nil.
 * \param h a Pointer filled in with the minimum height of the window, may be
 *          nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMaximumSize
 * \sa SDL_SetWindowMinimumSize
  }
function SDL_GetWindowMinimumSize(window: PSDL_Window; w: pcint; h: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowMinimumSize' {$ENDIF} {$ENDIF};

{*
 * Set the maximum size of a window's client area.
 *
 * \param window the window to change.
 * \param max_w the maximum width of the window, or 0 for no limit.
 * \param max_h the maximum height of the window, or 0 for no limit.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMaximumSize
 * \sa SDL_SetWindowMinimumSize
  }
function SDL_SetWindowMaximumSize(window: PSDL_Window; max_w: cint; max_h: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowMaximumSize' {$ENDIF} {$ENDIF};

{*
 * Get the maximum size of a window's client area.
 *
 * \param window the window to query.
 * \param w a Pointer filled in with the maximum width of the window, may be
 *          nil.
 * \param h a Pointer filled in with the maximum height of the window, may be
 *          nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMinimumSize
 * \sa SDL_SetWindowMaximumSize
  }
function SDL_GetWindowMaximumSize(window: PSDL_Window; w: pcint; h: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowMaximumSize' {$ENDIF} {$ENDIF};

{*
 * Set the border state of a window.
 *
 * This will add or remove the window's `SDL_WINDOW_BORDERLESS` flag and add
 * or remove the border from the actual window. This is a no-op if the
 * window's border already matches the requested state.
 *
 * You can't change the border state of a fullscreen window.
 *
 * \param window the window of which to change the border state.
 * \param bordered false to remove border, true to add border.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFlags
  }
function SDL_SetWindowBordered(window: PSDL_Window; bordered: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowBordered' {$ENDIF} {$ENDIF};

{*
 * Set the user-resizable state of a window.
 *
 * This will add or remove the window's `SDL_WINDOW_RESIZABLE` flag and
 * allow/disallow user resizing of the window. This is a no-op if the window's
 * resizable state already matches the requested state.
 *
 * You can't change the resizable state of a fullscreen window.
 *
 * \param window the window of which to change the resizable state.
 * \param resizable true to allow resizing, false to disallow.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFlags
  }
function SDL_SetWindowResizable(window: PSDL_Window; resizable: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowResizable' {$ENDIF} {$ENDIF};

{*
 * Set the window to always be above the others.
 *
 * This will add or remove the window's `SDL_WINDOW_ALWAYS_ON_TOP` flag. This
 * will bring the window to the front and keep the window above the rest.
 *
 * \param window the window of which to change the always on top state.
 * \param on_top true to set the window always on top, false to disable.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFlags
  }
function SDL_SetWindowAlwaysOnTop(window: PSDL_Window; on_top: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowAlwaysOnTop' {$ENDIF} {$ENDIF};

{**
 * Set the window to fill the current document space (Emscripten only).
 *
 * This will add or remove the window's `SDL_WINDOW_FILL_DOCUMENT` flag.
 *
 * Currently this flag only applies to the Emscripten target.
 *
 * When enabled, the canvas element fills the entire document. Resize events
 * will be generated as the browser window is resized, as that will adjust the
 * canvas size as well. The canvas will cover anything else on the page,
 * including any controls provided by Emscripten in its generated HTML file
 * (in fact, any elements on the page that aren't the canvas will be moved
 * into a hidden `div` element).
 *
 * Often times this is desirable for a browser-based game, but it means
 * several things that we expect of an SDL window on other platforms might not
 * work as expected, such as minimum window sizes and aspect ratios.
 *
 * \param window the window of which to change the fill-document state.
 * \param fill true to set the window to fill the document, false to disable.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_GetWindowFlags
 *}
function SDL_SetWindowFillDocument(window: PSDL_Window; fill: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowFillDocument' {$ENDIF} {$ENDIF};

{*
 * Show a window.
 *
 * \param window the window to show.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HideWindow
 * \sa SDL_RaiseWindow
  }
function SDL_ShowWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ShowWindow' {$ENDIF} {$ENDIF};

{*
 * Hide a window.
 *
 * \param window the window to hide.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ShowWindow
 * \sa SDL_WINDOW_HIDDEN
  }
function SDL_HideWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HideWindow' {$ENDIF} {$ENDIF};

{*
 * Request that a window be raised above other windows and gain the input
 * focus.
 *
 * The result of this request is subject to desktop window manager policy,
 * particularly if raising the requested window would result in stealing focus
 * from another application. If the window is successfully raised and gains
 * input focus, an SDL_EVENT_WINDOW_FOCUS_GAINED event will be emitted, and
 * the window will have the SDL_WINDOW_INPUT_FOCUS flag set.
 *
 * \param window the window to raise.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_RaiseWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RaiseWindow' {$ENDIF} {$ENDIF};

{*
 * Request that the window be made as large as possible.
 *
 * Non-resizable windows can't be maximized. The window must have the
 * SDL_WINDOW_RESIZABLE flag set, or this will have no effect.
 *
 * On some windowing systems this request is asynchronous and the new window
 * state may not have have been applied immediately upon the return of this
 * function. If an immediate change is required, call SDL_SyncWindow() to
 * block until the changes have taken effect.
 *
 * When the window state changes, an SDL_EVENT_WINDOW_MAXIMIZED event will be
 * emitted. Note that, as this is just a request, the windowing system can
 * deny the state change.
 *
 * When maximizing a window, whether the constraints set via
 * SDL_SetWindowMaximumSize() are honored depends on the policy of the window
 * manager. Win32 and macOS enforce the constraints when maximizing, while X11
 * and Wayland window managers may vary.
 *
 * \param window the window to maximize.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_MinimizeWindow
 * \sa SDL_RestoreWindow
 * \sa SDL_SyncWindow
  }
function SDL_MaximizeWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_MaximizeWindow' {$ENDIF} {$ENDIF};

{*
 * Request that the window be minimized to an iconic representation.
 *
 * If the window is in a fullscreen state, this request has no direct effect.
 * It may alter the state the window is returned to when leaving fullscreen.
 *
 * On some windowing systems this request is asynchronous and the new window
 * state may not have been applied immediately upon the return of this
 * function. If an immediate change is required, call SDL_SyncWindow() to
 * block until the changes have taken effect.
 *
 * When the window state changes, an SDL_EVENT_WINDOW_MINIMIZED event will be
 * emitted. Note that, as this is just a request, the windowing system can
 * deny the state change.
 *
 * \param window the window to minimize.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_MaximizeWindow
 * \sa SDL_RestoreWindow
 * \sa SDL_SyncWindow
  }
function SDL_MinimizeWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_MinimizeWindow' {$ENDIF} {$ENDIF};

{*
 * Request that the size and position of a minimized or maximized window be
 * restored.
 *
 * If the window is in a fullscreen state, this request has no direct effect.
 * It may alter the state the window is returned to when leaving fullscreen.
 *
 * On some windowing systems this request is asynchronous and the new window
 * state may not have have been applied immediately upon the return of this
 * function. If an immediate change is required, call SDL_SyncWindow() to
 * block until the changes have taken effect.
 *
 * When the window state changes, an SDL_EVENT_WINDOW_RESTORED event will be
 * emitted. Note that, as this is just a request, the windowing system can
 * deny the state change.
 *
 * \param window the window to restore.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_MaximizeWindow
 * \sa SDL_MinimizeWindow
 * \sa SDL_SyncWindow
  }
function SDL_RestoreWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RestoreWindow' {$ENDIF} {$ENDIF};

{*
 * Request that the window's fullscreen state be changed.
 *
 * By default a window in fullscreen state uses borderless fullscreen desktop
 * mode, but a specific exclusive display mode can be set using
 * SDL_SetWindowFullscreenMode().
 *
 * On some windowing systems this request is asynchronous and the new
 * fullscreen state may not have have been applied immediately upon the return
 * of this function. If an immediate change is required, call SDL_SyncWindow()
 * to block until the changes have taken effect.
 *
 * When the window state changes, an SDL_EVENT_WINDOW_ENTER_FULLSCREEN or
 * SDL_EVENT_WINDOW_LEAVE_FULLSCREEN event will be emitted. Note that, as this
 * is just a request, it can be denied by the windowing system.
 *
 * \param window the window to change.
 * \param fullscreen true for fullscreen mode, false for windowed mode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowFullscreenMode
 * \sa SDL_SetWindowFullscreenMode
 * \sa SDL_SyncWindow
 * \sa SDL_WINDOW_FULLSCREEN
  }
function SDL_SetWindowFullscreen(window: PSDL_Window; fullscreen: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowFullscreen' {$ENDIF} {$ENDIF};

{*
 * Block until any pending window state is finalized.
 *
 * On asynchronous windowing systems, this acts as a synchronization barrier
 * for pending window state. It will attempt to wait until any pending window
 * state has been applied and is guaranteed to return within finite time. Note
 * that for how long it can potentially block depends on the underlying window
 * system, as window state changes may involve somewhat lengthy animations
 * that must complete before the window is in its final requested state.
 *
 * On windowing systems where changes are immediate, this does nothing.
 *
 * \param window the window for which to wait for the pending state to be
 *               applied.
 * \returns true on success or false if the operation timed out before the
 *          window was in the requested state.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowSize
 * \sa SDL_SetWindowPosition
 * \sa SDL_SetWindowFullscreen
 * \sa SDL_MinimizeWindow
 * \sa SDL_MaximizeWindow
 * \sa SDL_RestoreWindow
 * \sa SDL_HINT_VIDEO_SYNC_WINDOW_OPERATIONS
  }
function SDL_SyncWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SyncWindow' {$ENDIF} {$ENDIF};

{*
 * Return whether the window has a surface associated with it.
 *
 * \param window the window to query.
 * \returns true if there is a surface associated with the window, or false
 *          otherwise.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSurface
  }
function SDL_WindowHasSurface(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WindowHasSurface' {$ENDIF} {$ENDIF};

{*
 * Get the SDL surface associated with the window.
 *
 * A new surface will be created with the optimal format for the window, if
 * necessary. This surface will be freed when the window is destroyed. Do not
 * free this surface.
 *
 * This surface will be invalidated if the window is resized. After resizing a
 * window this function must be called again to return a valid surface.
 *
 * You may not combine this with 3D or the rendering API on this window.
 *
 * This function is affected by `SDL_HINT_FRAMEBUFFER_ACCELERATION`.
 *
 * \param window the window to query.
 * \returns the surface associated with the window, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroyWindowSurface
 * \sa SDL_WindowHasSurface
 * \sa SDL_UpdateWindowSurface
 * \sa SDL_UpdateWindowSurfaceRects
  }
function SDL_GetWindowSurface(window: PSDL_Window): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowSurface' {$ENDIF} {$ENDIF};

{*
 * Toggle VSync for the window surface.
 *
 * When a window surface is created, vsync defaults to
 * SDL_WINDOW_SURFACE_VSYNC_DISABLED.
 *
 * The `vsync` parameter can be 1 to synchronize present with every vertical
 * refresh, 2 to synchronize present with every second vertical refresh, etc.,
 * SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE for late swap tearing (adaptive vsync),
 * or SDL_WINDOW_SURFACE_VSYNC_DISABLED to disable. Not every value is
 * supported by every driver, so you should check the return value to see
 * whether the requested setting is supported.
 *
 * \param window the window.
 * \param vsync the vertical refresh sync interval.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSurfaceVSync
  }
function SDL_SetWindowSurfaceVSync(window: PSDL_Window; vsync: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowSurfaceVSync' {$ENDIF} {$ENDIF};

  const
  SDL_WINDOW_SURFACE_VSYNC_DISABLED = 0;
  SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE = -(1);

{*
 * Get VSync for the window surface.
 *
 * \param window the window to query.
 * \param vsync an int filled with the current vertical refresh sync interval.
 *              See SDL_SetWindowSurfaceVSync() for the meaning of the value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowSurfaceVSync
  }
function SDL_GetWindowSurfaceVSync(window: PSDL_Window; vsync: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowSurfaceVSync' {$ENDIF} {$ENDIF};

{*
 * Copy the window surface to the screen.
 *
 * This is the function you use to reflect any changes to the surface on the
 * screen.
 *
 * This function is equivalent to the SDL 1.2 API SDL_Flip().
 *
 * \param window the window to update.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSurface
 * \sa SDL_UpdateWindowSurfaceRects
  }
function SDL_UpdateWindowSurface(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateWindowSurface' {$ENDIF} {$ENDIF};

{*
 * Copy areas of the window surface to the screen.
 *
 * This is the function you use to reflect changes to portions of the surface
 * on the screen.
 *
 * This function is equivalent to the SDL 1.2 API SDL_UpdateRects().
 *
 * Note that this function will update _at least_ the rectangles specified,
 * but this is only intended as an optimization; in practice, this might
 * update more of the screen (or all of the screen!), depending on what method
 * SDL uses to send pixels to the system.
 *
 * \param window the window to update.
 * \param rects an array of SDL_Rect structures representing areas of the
 *              surface to copy, in pixels.
 * \param numrects the number of rectangles.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSurface
 * \sa SDL_UpdateWindowSurface
  }
function SDL_UpdateWindowSurfaceRects(window: PSDL_Window; rects: PSDL_Rect; numrects: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateWindowSurfaceRects' {$ENDIF} {$ENDIF};

{*
 * Destroy the surface associated with the window.
 *
 * \param window the window to update.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowSurface
 * \sa SDL_WindowHasSurface
  }
function SDL_DestroyWindowSurface(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyWindowSurface' {$ENDIF} {$ENDIF};

{*
 * Set a window's keyboard grab mode.
 *
 * Keyboard grab enables capture of system keyboard shortcuts like Alt+Tab or
 * the Meta/Super key. Note that not all system keyboard shortcuts can be
 * captured by applications (one example is Ctrl+Alt+Del on Windows).
 *
 * This is primarily intended for specialized applications such as VNC clients
 * or VM frontends. Normal games should not use keyboard grab.
 *
 * When keyboard grab is enabled, SDL will continue to handle Alt+Tab when the
 * window is full-screen to ensure the user is not trapped in your
 * application. If you have a custom keyboard shortcut to exit fullscreen
 * mode, you may suppress this behavior with
 * `SDL_HINT_ALLOW_ALT_TAB_WHILE_GRABBED`.
 *
 * If the caller enables a grab while another window is currently grabbed, the
 * other window loses its grab in favor of the caller's window.
 *
 * \param window the window for which the keyboard grab mode should be set.
 * \param grabbed this is true to grab keyboard, and false to release.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowKeyboardGrab
 * \sa SDL_SetWindowMouseGrab
  }
function SDL_SetWindowKeyboardGrab(window: PSDL_Window; grabbed: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowKeyboardGrab' {$ENDIF} {$ENDIF};

{*
 * Set a window's mouse grab mode.
 *
 * Mouse grab confines the mouse cursor to the window.
 *
 * \param window the window for which the mouse grab mode should be set.
 * \param grabbed this is true to grab mouse, and false to release.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \sa SDL_GetWindowMouseGrab
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMouseRect
 * \sa SDL_SetWindowMouseRect
 * \sa SDL_SetWindowKeyboardGrab
  }
function SDL_SetWindowMouseGrab(window: PSDL_Window; grabbed: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowMouseGrab' {$ENDIF} {$ENDIF};

{*
 * Get a window's keyboard grab mode.
 *
 * \param window the window to query.
 * \returns true if keyboard is grabbed, and false otherwise.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowKeyboardGrab
  }
function SDL_GetWindowKeyboardGrab(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowKeyboardGrab' {$ENDIF} {$ENDIF};

{*
 * Get a window's mouse grab mode.
 *
 * \param window the window to query.
 * \returns true if mouse is grabbed, and false otherwise.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMouseRect
 * \sa SDL_SetWindowMouseRect
 * \sa SDL_SetWindowMouseGrab
 * \sa SDL_SetWindowKeyboardGrab
  }
function SDL_GetWindowMouseGrab(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowMouseGrab' {$ENDIF} {$ENDIF};

{*
 * Get the window that currently has an input grab enabled.
 *
 * \returns the window if input is grabbed or nil otherwise.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowMouseGrab
 * \sa SDL_SetWindowKeyboardGrab
  }
function SDL_GetGrabbedWindow: PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGrabbedWindow' {$ENDIF} {$ENDIF};

{*
 * Confines the cursor to the specified area of a window.
 *
 * Note that this does NOT grab the cursor, it only defines the area a cursor
 * is restricted to when the window has mouse focus.
 *
 * \param window the window that will be associated with the barrier.
 * \param rect a rectangle area in window-relative coordinates. If nil the
 *             barrier for the specified window will be destroyed.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowMouseRect
 * \sa SDL_GetWindowMouseGrab
 * \sa SDL_SetWindowMouseGrab
  }
function SDL_SetWindowMouseRect(window: PSDL_Window; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowMouseRect' {$ENDIF} {$ENDIF};

{*
 * Get the mouse confinement rectangle of a window.
 *
 * \param window the window to query.
 * \returns a Pointer to the mouse confinement rectangle of a window, or nil
 *          if there isn't one.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowMouseRect
 * \sa SDL_GetWindowMouseGrab
 * \sa SDL_SetWindowMouseGrab
  }
function SDL_GetWindowMouseRect(window: PSDL_Window): PSDL_Rect; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowMouseRect' {$ENDIF} {$ENDIF};

{*
 * Set the opacity for a window.
 *
 * The parameter `opacity` will be clamped internally between 0.0f
 * (transparent) and 1.0f (opaque).
 *
 * This function also returns false if setting the opacity isn't supported.
 *
 * \param window the window which will be made transparent or opaque.
 * \param opacity the opacity value (0.0f - transparent, 1.0f - opaque).
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetWindowOpacity
  }
function SDL_SetWindowOpacity(window: PSDL_Window; opacity: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowOpacity' {$ENDIF} {$ENDIF};

{*
 * Get the opacity of a window.
 *
 * If transparency isn't supported on this platform, opacity will be returned
 * as 1.0f without error.
 *
 * \param window the window to get the current opacity value from.
 * \returns the opacity, (0.0f - transparent, 1.0f - opaque), or -1.0f on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowOpacity
  }
function SDL_GetWindowOpacity(window: PSDL_Window): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowOpacity' {$ENDIF} {$ENDIF};

{*
 * Set the window as a child of a parent window.
 *
 * If the window is already the child of an existing window, it will be
 * reparented to the new owner. Setting the parent window to nil unparents
 * the window and removes child window status.
 *
 * If a parent window is hidden or destroyed, the operation will be
 * recursively applied to child windows. Child windows hidden with the parent
 * that did not have their hidden status explicitly set will be restored when
 * the parent is shown.
 *
 * Attempting to set the parent of a window that is currently in the modal
 * state will fail. Use SDL_SetWindowModal() to cancel the modal status before
 * attempting to change the parent.
 *
 * Popup windows cannot change parents and attempts to do so will fail.
 *
 * Setting a parent window that is currently the sibling or descendent of the
 * child window results in undefined behavior.
 *
 * \param window the window that should become the child of a parent.
 * \param parent the new parent window for the child window.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowModal
  }
function SDL_SetWindowParent(window: PSDL_Window; parent: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowParent' {$ENDIF} {$ENDIF};

{*
 * Toggle the state of the window as modal.
 *
 * To enable modal status on a window, the window must currently be the child
 * window of a parent, or toggling modal status on will fail.
 *
 * \param window the window on which to set the modal state.
 * \param modal true to toggle modal status on, false to toggle it off.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetWindowParent
 * \sa SDL_WINDOW_MODAL
  }
function SDL_SetWindowModal(window: PSDL_Window; modal: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowModal' {$ENDIF} {$ENDIF};

{*
 * Set whether the window may have input focus.
 *
 * \param window the window to set focusable state.
 * \param focusable true to allow input focus, false to not allow input focus.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SetWindowFocusable(window: PSDL_Window; focusable: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowFocusable' {$ENDIF} {$ENDIF};

{*
 * Display the system-level window menu.
 *
 * This default window menu is provided by the system and on some platforms
 * provides functionality for setting or changing privileged state on the
 * window, such as moving it between workspaces or displays, or toggling the
 * always-on-top property.
 *
 * On platforms or desktops where this is unsupported, this function does
 * nothing.
 *
 * \param window the window for which the menu will be displayed.
 * \param x the x coordinate of the menu, relative to the origin (top-left) of
 *          the client area.
 * \param y the y coordinate of the menu, relative to the origin (top-left) of
 *          the client area.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ShowWindowSystemMenu(window: PSDL_Window; x: cint; y: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ShowWindowSystemMenu' {$ENDIF} {$ENDIF};

{*
 * Possible return values from the SDL_HitTest callback.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_HitTest
  }
type
  PPSDL_HitTestResult = ^PSDL_HitTestResult;
  PSDL_HitTestResult = ^TSDL_HitTestResult;
  TSDL_HitTestResult =  Integer;
const
  SDL_HITTEST_NORMAL = TSDL_HitTestResult(0);                {*< Region is normal. No special properties.  }
  SDL_HITTEST_DRAGGABLE = TSDL_HitTestResult(1);             {*< Region can drag entire window.  }
  SDL_HITTEST_RESIZE_TOPLEFT = TSDL_HitTestResult(2);        {*< Region is the resizable top-left corner border.  }
  SDL_HITTEST_RESIZE_TOP = TSDL_HitTestResult(3);            {*< Region is the resizable top border.  }
  SDL_HITTEST_RESIZE_TOPRIGHT = TSDL_HitTestResult(4);       {*< Region is the resizable top-right corner border.  }
  SDL_HITTEST_RESIZE_RIGHT = TSDL_HitTestResult(5);          {*< Region is the resizable right border.  }
  SDL_HITTEST_RESIZE_BOTTOMRIGHT = TSDL_HitTestResult(6);    {*< Region is the resizable bottom-right corner border.  }
  SDL_HITTEST_RESIZE_BOTTOM = TSDL_HitTestResult(7);         {*< Region is the resizable bottom border.  }
  SDL_HITTEST_RESIZE_BOTTOMLEFT = TSDL_HitTestResult(8);     {*< Region is the resizable bottom-left corner border.  }
  SDL_HITTEST_RESIZE_LEFT = TSDL_HitTestResult(9);           {*< Region is the resizable left border.  }

{*
 * Callback used for hit-testing.
 *
 * \param win the SDL_Window where hit-testing was set on.
 * \param area an SDL_Point which should be hit-tested.
 * \param data what was passed as `callback_data` to SDL_SetWindowHitTest().
 * \returns an SDL_HitTestResult value.
 *
 * \sa SDL_SetWindowHitTest
  }
type
  TSDL_HitTest = function(win: PSDL_Window; area: PSDL_Point; data: Pointer): TSDL_HitTestResult; cdecl;

{*
 * Provide a callback that decides if a window region has special properties.
 *
 * Normally windows are dragged and resized by decorations provided by the
 * system window manager (a title bar, borders, etc), but for some apps, it
 * makes sense to drag them from somewhere else inside the window itself; for
 * example, one might have a borderless window that wants to be draggable from
 * any part, or simulate its own title bar, etc.
 *
 * This function lets the app provide a callback that designates pieces of a
 * given window as special. This callback is run during event processing if we
 * need to tell the OS to treat a region of the window specially; the use of
 * this callback is known as "hit testing."
 *
 * Mouse input may not be delivered to your application if it is within a
 * special area; the OS will often apply that input to moving the window or
 * resizing the window and not deliver it to the application.
 *
 * Specifying nil for a callback disables hit-testing. Hit-testing is
 * disabled by default.
 *
 * Platforms that don't support this functionality will return false
 * unconditionally, even if you're attempting to disable hit-testing.
 *
 * Your callback may fire at any time, and its firing does not indicate any
 * specific behavior (for example, on Windows, this certainly might fire when
 * the OS is deciding whether to drag your window, but it fires for lots of
 * other reasons, too, some unrelated to anything you probably care about _and
 * when the mouse isn't actually at the location it is testing_). Since this
 * can fire at any time, you should try to keep your callback efficient,
 * devoid of allocations, etc.
 *
 * \param window the window to set hit-testing on.
 * \param callback the function to call when doing a hit-test.
 * \param callback_data an app-defined void Pointer passed to **callback**.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SetWindowHitTest(window: PSDL_Window; callback: TSDL_HitTest; callback_data: Pointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowHitTest' {$ENDIF} {$ENDIF};

{*
 * Set the shape of a transparent window.
 *
 * This sets the alpha channel of a transparent window and any fully
 * transparent areas are also transparent to mouse clicks. If you are using
 * something besides the SDL render API, then you are responsible for drawing
 * the alpha channel of the window to match the shape alpha channel to get
 * consistent cross-platform results.
 *
 * The shape is copied inside this function, so you can free it afterwards. If
 * your shape surface changes, you should call SDL_SetWindowShape() again to
 * update the window. This is an expensive operation, so should be done
 * sparingly.
 *
 * The window must have been created with the SDL_WINDOW_TRANSPARENT flag.
 *
 * \param window the window.
 * \param shape the surface representing the shape of the window, or nil to
 *              remove any current shape.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SetWindowShape(window: PSDL_Window; shape: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowShape' {$ENDIF} {$ENDIF};

{*
 * Request a window to demand attention from the user.
 *
 * \param window the window to be flashed.
 * \param operation the operation to perform.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_FlashWindow(window: PSDL_Window; operation: TSDL_FlashOperation): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FlashWindow' {$ENDIF} {$ENDIF};

{*
 * Sets the state of the progress bar for the given window’s taskbar icon.
 *
 * \param window the window whose progress state is to be modified.
 * \param state the progress state. `SDL_PROGRESS_STATE_NONE` stops displaying
 *              the progress bar.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
  }

function SDL_SetWindowProgressState(window: PSDL_Window; state: TSDL_ProgressState): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowProgressState' {$ENDIF} {$ENDIF};

{*
 * Get the state of the progress bar for the given window’s taskbar icon.
 *
 * \param window the window to get the current progress state from.
 * \returns the progress state, or `SDL_PROGRESS_STATE_INVALID` on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetWindowProgressState(window: PSDL_Window): TSDL_ProgressState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowProgressState' {$ENDIF} {$ENDIF};

{*
 * Sets the value of the progress bar for the given window’s taskbar icon.
 *
 * \param window the window whose progress value is to be modified.
 * \param value the progress value in the range of [0.0f - 1.0f]. If the value
 *              is outside the valid range, it gets clamped.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_SetWindowProgressValue(window: PSDL_Window; value: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetWindowProgressValue' {$ENDIF} {$ENDIF};

{*
 * Get the value of the progress bar for the given window’s taskbar icon.
 *
 * \param window the window to get the current progress value from.
 * \returns the progress value in the range of [0.0f - 1.0f], or -1.0f on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetWindowProgressValue(window: PSDL_Window): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowProgressValue' {$ENDIF} {$ENDIF};

{*
 * Destroy a window.
 *
 * Any child windows owned by the window will be recursively destroyed as
 * well.
 *
 * Note that on some platforms, the visible window may not actually be removed
 * from the screen until the SDL event loop is pumped again, even though the
 * SDL_Window is no longer valid after this call.
 *
 * \param window the window to destroy.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreatePopupWindow
 * \sa SDL_CreateWindow
 * \sa SDL_CreateWindowWithProperties
  }
procedure SDL_DestroyWindow(window: PSDL_Window); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyWindow' {$ENDIF} {$ENDIF};

{*
 * Check whether the screensaver is currently enabled.
 *
 * The screensaver is disabled by default.
 *
 * The default can also be changed using `SDL_HINT_VIDEO_ALLOW_SCREENSAVER`.
 *
 * \returns true if the screensaver is enabled, false if it is disabled.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DisableScreenSaver
 * \sa SDL_EnableScreenSaver
  }
function SDL_ScreenSaverEnabled: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ScreenSaverEnabled' {$ENDIF} {$ENDIF};

{*
 * Allow the screen to be blanked by a screen saver.
 *
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DisableScreenSaver
 * \sa SDL_ScreenSaverEnabled
  }
function SDL_EnableScreenSaver: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EnableScreenSaver' {$ENDIF} {$ENDIF};

{*
 * Prevent the screen from being blanked by a screen saver.
 *
 * If you disable the screensaver, it is automatically re-enabled when SDL
 * quits.
 *
 * The screensaver is disabled by default, but this may by changed by
 * SDL_HINT_VIDEO_ALLOW_SCREENSAVER.
 *
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_EnableScreenSaver
 * \sa SDL_ScreenSaverEnabled
  }
function SDL_DisableScreenSaver: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DisableScreenSaver' {$ENDIF} {$ENDIF};

{*
 *  \name OpenGL support functions
  }
{ @  }
{*
 * Dynamically load an OpenGL library.
 *
 * This should be done after initializing the video driver, but before
 * creating any OpenGL windows. If no OpenGL library is loaded, the default
 * library will be loaded upon creation of the first OpenGL window.
 *
 * If you do this, you need to retrieve all of the GL functions used in your
 * program from the dynamic library using SDL_GL_GetProcAddress().
 *
 * \param path the platform dependent OpenGL library name, or nil to open the
 *             default OpenGL library.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_GetProcAddress
 * \sa SDL_GL_UnloadLibrary
  }
function SDL_GL_LoadLibrary(path: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_LoadLibrary' {$ENDIF} {$ENDIF};

{*
 * Get an OpenGL function by name.
 *
 * If the GL library is loaded at runtime with SDL_GL_LoadLibrary(), then all
 * GL functions must be retrieved this way. Usually this is used to retrieve
 * function pointers to OpenGL extensions.
 *
 * There are some quirks to looking up OpenGL functions that require some
 * extra care from the application. If you code carefully, you can handle
 * these quirks without any platform-specific code, though:
 *
 * - On Windows, function pointers are specific to the current GL context;
 *   this means you need to have created a GL context and made it current
 *   before calling SDL_GL_GetProcAddress(). If you recreate your context or
 *   create a second context, you should assume that any existing function
 *   pointers aren't valid to use with it. This is (currently) a
 *   Windows-specific limitation, and in practice lots of drivers don't suffer
 *   this limitation, but it is still the way the wgl API is documented to
 *   work and you should expect crashes if you don't respect it. Store a copy
 *   of the function pointers that comes and goes with context lifespan.
 * - On X11, function pointers returned by this function are valid for any
 *   context, and can even be looked up before a context is created at all.
 *   This means that, for at least some common OpenGL implementations, if you
 *   look up a function that doesn't exist, you'll get a non-nil result that
 *   is _NOT_ safe to call. You must always make sure the function is actually
 *   available for a given GL context before calling it, by checking for the
 *   existence of the appropriate extension with SDL_GL_ExtensionSupported(),
 *   or verifying that the version of OpenGL you're using offers the function
 *   as core functionality.
 * - Some OpenGL drivers, on all platforms, *will* return nil if a function
 *   isn't supported, but you can't count on this behavior. Check for
 *   extensions you use, and if you get a nil anyway, act as if that
 *   extension wasn't available. This is probably a bug in the driver, but you
 *   can code defensively for this scenario anyhow.
 * - Just because you're on Linux/Unix, don't assume you'll be using X11.
 *   Next-gen display servers are waiting to replace it, and may or may not
 *   make the same promises about function pointers.
 * - OpenGL function pointers must be declared `APIENTRY` as in the example
 *   code. This will ensure the proper calling convention is followed on
 *   platforms where this matters (Win32) thereby avoiding stack corruption.
 *
 * \param proc the name of an OpenGL function.
 * \returns a Pointer to the named OpenGL function. The returned Pointer
 *          should be cast to the appropriate function signature.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_ExtensionSupported
 * \sa SDL_GL_LoadLibrary
 * \sa SDL_GL_UnloadLibrary
  }
function SDL_GL_GetProcAddress(proc: PAnsiChar): TSDL_FunctionPointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_GetProcAddress' {$ENDIF} {$ENDIF};

{*
 * Get an EGL library function by name.
 *
 * If an EGL library is loaded, this function allows applications to get entry
 * points for EGL functions. This is useful to provide to an EGL API and
 * extension loader.
 *
 * \param proc the name of an EGL function.
 * \returns a Pointer to the named EGL function. The returned Pointer should
 *          be cast to the appropriate function signature.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_EGL_GetCurrentDisplay
  }
function SDL_EGL_GetProcAddress(proc: PAnsiChar): TSDL_FunctionPointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EGL_GetProcAddress' {$ENDIF} {$ENDIF};

{*
 * Unload the OpenGL library previously loaded by SDL_GL_LoadLibrary().
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_LoadLibrary
  }
procedure SDL_GL_UnloadLibrary; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_UnloadLibrary' {$ENDIF} {$ENDIF};

{*
 * Check if an OpenGL extension is supported for the current context.
 *
 * This function operates on the current GL context; you must have created a
 * context and it must be current before calling this function. Do not assume
 * that all contexts you create will have the same set of extensions
 * available, or that recreating an existing context will offer the same
 * extensions again.
 *
 * While it's probably not a massive overhead, this function is not an O(1)
 * operation. Check the extensions you care about after creating the GL
 * context and save that information somewhere instead of calling the function
 * every time you need to know.
 *
 * \param extension the name of the extension to check.
 * \returns true if the extension is supported, false otherwise.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GL_ExtensionSupported(extension: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_ExtensionSupported' {$ENDIF} {$ENDIF};

{*
 * Reset all previously set OpenGL context attributes to their default values.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_GetAttribute
 * \sa SDL_GL_SetAttribute
  }
procedure SDL_GL_ResetAttributes; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_ResetAttributes' {$ENDIF} {$ENDIF};

{*
 * Set an OpenGL window attribute before window creation.
 *
 * This function sets the OpenGL attribute `attr` to `value`. The requested
 * attributes should be set before creating an OpenGL window. You should use
 * SDL_GL_GetAttribute() to check the values after creating the OpenGL
 * context, since the values obtained can differ from the requested ones.
 *
 * \param attr an enum value specifying the OpenGL attribute to set.
 * \param value the desired value for the attribute.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_CreateContext
 * \sa SDL_GL_GetAttribute
 * \sa SDL_GL_ResetAttributes
  }
function SDL_GL_SetAttribute(attr: TSDL_GLAttr; value: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_SetAttribute' {$ENDIF} {$ENDIF};

{*
 * Get the actual value for an attribute from the current context.
 *
 * \param attr an SDL_GLAttr enum value specifying the OpenGL attribute to
 *             get.
 * \param value a Pointer filled in with the current value of `attr`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_ResetAttributes
 * \sa SDL_GL_SetAttribute
  }
function SDL_GL_GetAttribute(attr: TSDL_GLAttr; value: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_GetAttribute' {$ENDIF} {$ENDIF};

{*
 * Create an OpenGL context for an OpenGL window, and make it current.
 *
 * The OpenGL context will be created with the current states set through
 * SDL_GL_SetAttribute().
 *
 * The SDL_Window specified must have been created with the SDL_WINDOW_OPENGL
 * flag, or context creation will fail.
 *
 * Windows users new to OpenGL should note that, for historical reasons, GL
 * functions added after OpenGL version 1.1 are not available by default.
 * Those functions must be loaded at run-time, either with an OpenGL
 * extension-handling library or with SDL_GL_GetProcAddress() and its related
 * functions.
 *
 * SDL_GLContext is opaque to the application.
 *
 * \param window the window to associate with the context.
 * \returns the OpenGL context associated with `window` or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_DestroyContext
 * \sa SDL_GL_MakeCurrent
  }
function SDL_GL_CreateContext(window: PSDL_Window): TSDL_GLContext; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_CreateContext' {$ENDIF} {$ENDIF};

{*
 * Set up an OpenGL context for rendering into an OpenGL window.
 *
 * The context must have been created with a compatible window.
 *
 * \param window the window to associate with the context.
 * \param context the OpenGL context to associate with the window.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_CreateContext
  }
function SDL_GL_MakeCurrent(window: PSDL_Window; context: TSDL_GLContext): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_MakeCurrent' {$ENDIF} {$ENDIF};

{*
 * Get the currently active OpenGL window.
 *
 * \returns the currently active OpenGL window on success or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GL_GetCurrentWindow: PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_GetCurrentWindow' {$ENDIF} {$ENDIF};

{*
 * Get the currently active OpenGL context.
 *
 * \returns the currently active OpenGL context or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_MakeCurrent
  }
function SDL_GL_GetCurrentContext: TSDL_GLContext; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_GetCurrentContext' {$ENDIF} {$ENDIF};

{*
 * Get the currently active EGL display.
 *
 * \returns the currently active EGL display or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_EGL_GetCurrentDisplay: TSDL_EGLDisplay; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EGL_GetCurrentDisplay' {$ENDIF} {$ENDIF};

{*
 * Get the currently active EGL config.
 *
 * \returns the currently active EGL config or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_EGL_GetCurrentConfig: TSDL_EGLConfig; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EGL_GetCurrentConfig' {$ENDIF} {$ENDIF};

{*
 * Get the EGL surface associated with the window.
 *
 * \param window the window to query.
 * \returns the EGLSurface Pointer associated with the window, or nil on
 *          failure.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_EGL_GetWindowSurface(window: PSDL_Window): TSDL_EGLSurface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EGL_GetWindowSurface' {$ENDIF} {$ENDIF};

{*
 * Sets the callbacks for defining custom EGLAttrib arrays for EGL
 * initialization.
 *
 * Callbacks that aren't needed can be set to nil.
 *
 * NOTE: These callback pointers will be reset after SDL_GL_ResetAttributes.
 *
 * \param platformAttribCallback callback for attributes to pass to
 *                               eglGetPlatformDisplay. May be nil.
 * \param surfaceAttribCallback callback for attributes to pass to
 *                              eglCreateSurface. May be nil.
 * \param contextAttribCallback callback for attributes to pass to
 *                              eglCreateContext. May be nil.
 * \param userdata a Pointer that is passed to the callbacks.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_EGL_SetAttributeCallbacks(platformAttribCallback: TSDL_EGLAttribArrayCallback; surfaceAttribCallback: TSDL_EGLIntArrayCallback; contextAttribCallback: TSDL_EGLIntArrayCallback; userdata: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EGL_SetAttributeCallbacks' {$ENDIF} {$ENDIF};

{*
 * Set the swap interval for the current OpenGL context.
 *
 * Some systems allow specifying -1 for the interval, to enable adaptive
 * vsync. Adaptive vsync works the same as vsync, but if you've already missed
 * the vertical retrace for a given frame, it swaps buffers immediately, which
 * might be less jarring for the user during occasional framerate drops. If an
 * application requests adaptive vsync and the system does not support it,
 * this function will fail and return false. In such a case, you should
 * probably retry the call with 1 for the interval.
 *
 * Adaptive vsync is implemented for some glX drivers with
 * GLX_EXT_swap_control_tear, and for some Windows drivers with
 * WGL_EXT_swap_control_tear.
 *
 * Read more on the Khronos wiki:
 * https://www.khronos.org/opengl/wiki/Swap_Interval#Adaptive_Vsync
 *
 * \param interval 0 for immediate updates, 1 for updates synchronized with
 *                 the vertical retrace, -1 for adaptive vsync.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_GetSwapInterval
  }
function SDL_GL_SetSwapInterval(interval: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_SetSwapInterval' {$ENDIF} {$ENDIF};

{*
 * Get the swap interval for the current OpenGL context.
 *
 * If the system can't determine the swap interval, or there isn't a valid
 * current context, this function will set *interval to 0 as a safe default.
 *
 * \param interval output interval value. 0 if there is no vertical retrace
 *                 synchronization, 1 if the buffer swap is synchronized with
 *                 the vertical retrace, and -1 if late swaps happen
 *                 immediately instead of waiting for the next retrace.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_SetSwapInterval
  }
function SDL_GL_GetSwapInterval(interval: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_GetSwapInterval' {$ENDIF} {$ENDIF};

{*
 * Update a window with OpenGL rendering.
 *
 * This is used with double-buffered OpenGL contexts, which are the default.
 *
 * On macOS, make sure you bind 0 to the draw framebuffer before swapping the
 * window, otherwise nothing will happen. If you aren't using
 * glBindFramebuffer(), this is the default and you won't have to do anything
 * extra.
 *
 * \param window the window to change.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GL_SwapWindow(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_SwapWindow' {$ENDIF} {$ENDIF};

{*
 * Delete an OpenGL context.
 *
 * \param context the OpenGL context to be deleted.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GL_CreateContext
  }
function SDL_GL_DestroyContext(context: TSDL_GLContext): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GL_DestroyContext' {$ENDIF} {$ENDIF};
