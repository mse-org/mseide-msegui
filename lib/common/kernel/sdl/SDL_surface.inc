{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategorySurface
 *
 * SDL surfaces are buffers of pixels in system RAM. These are useful for
 * passing around and manipulating images that are not stored in GPU memory.
 *
 * SDL_Surface makes serious efforts to manage images in various formats, and
 * provides a reasonable toolbox for transforming the data, including copying
 * between surfaces, filling rectangles in the image data, etc.
 *
 * There is also a simple .bmp loader, SDL_LoadBMP(), and a simple .png
 * loader, SDL_LoadPNG(). SDL itself does not provide loaders for other file
 * formats, but there are several excellent external libraries that do,
 * including its own satellite library,
 * [SDL_image](https://wiki.libsdl.org/SDL3_image)
 * .
 *
 * In general these functions are thread-safe in that they can be called on
 * different threads with different surfaces. You should not try to modify any
 * surface from two threads simultaneously.
  }

{*
 * The flags on an SDL_Surface.
 *
 * These are generally considered read-only.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_SurfaceFlags = ^PSDL_SurfaceFlags;
  PSDL_SurfaceFlags = ^TSDL_SurfaceFlags;
  TSDL_SurfaceFlags = type cuint32;

const
  SDL_SURFACE_PREALLOCATED  = TSDL_SurfaceFlags($00000001);    {*< Surface uses preallocated pixel memory  }
  SDL_SURFACE_LOCK_NEEDED  = TSDL_SurfaceFlags($00000002);     {*< Surface needs to be locked to access pixels  }
  SDL_SURFACE_LOCKED  = TSDL_SurfaceFlags($00000004);          {*< Surface is currently locked  }
  SDL_SURFACE_SIMD_ALIGNED  = TSDL_SurfaceFlags($00000008);    {*< Surface uses pixel memory allocated with SDL_aligned_alloc()  }

{*
 * The scaling mode.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_ScaleMode = ^PSDL_ScaleMode;
  PSDL_ScaleMode = ^TSDL_ScaleMode;
  TSDL_ScaleMode =  type Integer;
const
  SDL_SCALEMODE_INVALID = TSDL_ScaleMode(-1);
  SDL_SCALEMODE_NEAREST = TSDL_ScaleMode(0);   {*< nearest pixel sampling  }
  SDL_SCALEMODE_LINEAR = TSDL_ScaleMode(1);    {*< linear filtering  }
  SDL_SCALEMODE_PIXELART = TSDL_ScaleMode(2);  {   nearest pixel sampling with improved scaling for pixel art, available since SDL 3.4.0  }

{*
 * The flip mode.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_FlipMode = ^PSDL_FlipMode;
  PSDL_FlipMode = ^TSDL_FlipMode;
  TSDL_FlipMode =  type Integer;
const
  SDL_FLIP_NONE  = TSDL_FlipMode(0);                                              {*< Do not flip  }
  SDL_FLIP_HORIZONTAL  = TSDL_FlipMode(1);                                        {*< flip horizontally  }
  SDL_FLIP_VERTICAL  = TSDL_FlipMode(2);                                          {*< flip vertically  }
  SDL_FLIP_HORIZONTAL_AND_VERTICAL = (SDL_FLIP_HORIZONTAL or SDL_FLIP_VERTICAL);  {  flip horizontally and vertically (not a diagonal flip)  }

{*
 * A collection of pixels used in software blitting.
 *
 * Pixels are arranged in memory in rows, with the top row first. Each row
 * occupies an amount of memory given by the pitch (sometimes known as the row
 * stride in non-SDL APIs).
 *
 * Within each row, pixels are arranged from left to right until the width is
 * reached. Each pixel occupies a number of bits appropriate for its format,
 * with most formats representing each pixel as one or more whole bytes (in
 * some indexed formats, instead multiple pixels are packed into each byte),
 * and a byte order given by the format. After encoding all pixels, any
 * remaining bytes to reach the pitch are used as padding to reach a desired
 * alignment, and have undefined contents.
 *
 * When a surface holds YUV format data, the planes are assumed to be
 * contiguous without padding between them, e.g. a 32x32 surface in NV12
 * format with a pitch of 32 would consist of 32x32 bytes of Y plane followed
 * by 32x16 bytes of UV plane.
 *
 * When a surface holds MJPG format data, pixels points at the compressed JPEG
 * image and pitch is the length of that data.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateSurface
 * \sa SDL_DestroySurface
  }
type
  PPSDL_Surface = ^PSDL_Surface;
  PSDL_Surface = ^TSDL_Surface;
  TSDL_Surface = record
      flags: TSDL_SurfaceFlags;       {*< The flags of the surface, read-only  }
      format: TSDL_PixelFormat;       {*< The format of the surface, read-only  }
      w: cint;                        {*< The width of the surface, read-only.  }
      h: cint;                        {*< The height of the surface, read-only.  }
      pitch: cint;                    {*< The distance in bytes between rows of pixels, read-only  }
      pixels: Pointer;                {*< A Pointer to the pixels of the surface, the pixels are writeable if non-nil  }
      refcount: cint;                 {*< Application reference count, used when freeing surface  }
      reserved: Pointer;              {*< Reserved for internal use  }
    end;

{*
 * Evaluates to true if the surface needs to be locked before access.
 *
 * \since This macro is available since SDL 3.2.0.
  }
function SDL_MUSTLOCK(Const S: PSDL_Surface): Boolean;

{*
 * Allocate a new surface with a specific pixel format.
 *
 * The pixels of the new surface are initialized to zero.
 *
 * \param width the width of the surface.
 * \param height the height of the surface.
 * \param format the SDL_PixelFormat for the new surface's pixel format.
 * \returns the new SDL_Surface structure that is created or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateSurfaceFrom
 * \sa SDL_DestroySurface
  }
function SDL_CreateSurface(width: cint; height: cint; format: TSDL_PixelFormat): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateSurface' {$ENDIF} {$ENDIF};

{*
 * Allocate a new surface with a specific pixel format and existing pixel
 * data.
 *
 * No copy is made of the pixel data. Pixel data is not managed automatically;
 * you must free the surface before you free the pixel data.
 *
 * Pitch is the offset in bytes from one row of pixels to the next, e.g.
 * `width*4` for `SDL_PIXELFORMAT_RGBA8888`.
 *
 * You may pass nil for pixels and 0 for pitch to create a surface that you
 * will fill in with valid values later.
 *
 * \param width the width of the surface.
 * \param height the height of the surface.
 * \param format the SDL_PixelFormat for the new surface's pixel format.
 * \param pixels a Pointer to existing pixel data.
 * \param pitch the number of bytes between each row, including padding.
 * \returns the new SDL_Surface structure that is created or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateSurface
 * \sa SDL_DestroySurface
  }
function SDL_CreateSurfaceFrom(width: cint; height: cint; format: TSDL_PixelFormat; pixels: Pointer; pitch: cint): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateSurfaceFrom' {$ENDIF} {$ENDIF};

{*
 * Free a surface.
 *
 * It is safe to pass nil to this function.
 *
 * \param surface the SDL_Surface to free.
 *
 * \threadsafety No other thread should be using the surface when it is freed.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateSurface
 * \sa SDL_CreateSurfaceFrom
  }
procedure SDL_DestroySurface(surface: PSDL_Surface); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroySurface' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a surface.
 *
 * The following properties are understood by SDL:
 *
 * - `SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT`: for HDR10 and floating point
 *   surfaces, this defines the value of 100% diffuse white, with higher
 *   values being displayed in the High Dynamic Range headroom. This defaults
 *   to 203 for HDR10 surfaces and 1.0 for floating point surfaces.
 * - `SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT`: for HDR10 and floating point
 *   surfaces, this defines the maximum dynamic range used by the content, in
 *   terms of the SDR white point. This defaults to 0.0, which disables tone
 *   mapping.
 * - `SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING`: the tone mapping operator
 *   used when compressing from a surface with high dynamic range to another
 *   with lower dynamic range. Currently this supports "chrome", which uses
 *   the same tone mapping that Chrome uses for HDR content, the form "*=N",
 *   where N is a floating point scale factor applied in linear space, and
 *   "none", which disables tone mapping. This defaults to "chrome".
 * - `SDL_PROP_SURFACE_HOTSPOT_X_NUMBER`: the hotspot pixel offset from the
 *   left edge of the image, if this surface is being used as a cursor.
 * - `SDL_PROP_SURFACE_HOTSPOT_Y_NUMBER`: the hotspot pixel offset from the
 *   top edge of the image, if this surface is being used as a cursor.
 * - `SDL_PROP_SURFACE_ROTATION_FLOAT`: the number of degrees a surface's data
 *   is meant to be rotated clockwise to make the image right-side up. Default
 *   0. This is used by the camera API, if a mobile device is oriented
 *   differently than what its camera provides (i.e. - the camera always
 *   provides portrait images but the phone is being held in landscape
 *   orientation). Since SDL 3.4.0.
 *
 * \param surface the SDL_Surface structure to query.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_GetSurfaceProperties(surface: PSDL_Surface): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT = 'SDL.surface.SDR_white_point';
  SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT = 'SDL.surface.HDR_headroom';
  SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING = 'SDL.surface.tonemap';
  SDL_PROP_SURFACE_HOTSPOT_X_NUMBER = 'SDL.surface.hotspot.x';
  SDL_PROP_SURFACE_HOTSPOT_Y_NUMBER = 'SDL.surface.hotspot.y';
  SDL_PROP_SURFACE_ROTATION_FLOAT = 'SDL.surface.rotation';

{*
 * Set the colorspace used by a surface.
 *
 * Setting the colorspace doesn't change the pixels, only how they are
 * interpreted in color operations.
 *
 * \param surface the SDL_Surface structure to update.
 * \param colorspace an SDL_Colorspace value describing the surface
 *                   colorspace.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceColorspace
  }

function SDL_SetSurfaceColorspace(surface: PSDL_Surface; colorspace: TSDL_Colorspace): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceColorspace' {$ENDIF} {$ENDIF};

{*
 * Get the colorspace used by a surface.
 *
 * The colorspace defaults to SDL_COLORSPACE_SRGB_LINEAR for floating point
 * formats, SDL_COLORSPACE_HDR10 for 10-bit formats, SDL_COLORSPACE_SRGB for
 * other RGB surfaces and SDL_COLORSPACE_BT709_FULL for YUV textures.
 *
 * \param surface the SDL_Surface structure to query.
 * \returns the colorspace used by the surface, or SDL_COLORSPACE_UNKNOWN if
 *          the surface is nil.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfaceColorspace
  }
function SDL_GetSurfaceColorspace(surface: PSDL_Surface): TSDL_Colorspace; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceColorspace' {$ENDIF} {$ENDIF};

{*
 * Create a palette and associate it with a surface.
 *
 * This function creates a palette compatible with the provided surface. The
 * palette is then returned for you to modify, and the surface will
 * automatically use the new palette in future operations. You do not need to
 * destroy the returned palette, it will be freed when the reference count
 * reaches 0, usually when the surface is destroyed.
 *
 * Bitmap surfaces (with format SDL_PIXELFORMAT_INDEX1LSB or
 * SDL_PIXELFORMAT_INDEX1MSB) will have the palette initialized with 0 as
 * white and 1 as black. Other surfaces will get a palette initialized with
 * white in every entry.
 *
 * If this function is called for a surface that already has a palette, a new
 * palette will be created to replace it.
 *
 * \param surface the SDL_Surface structure to update.
 * \returns a new SDL_Palette structure on success or nil on failure (e.g. if
 *          the surface didn't have an index format); call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetPaletteColors
  }
function SDL_CreateSurfacePalette(surface: PSDL_Surface): PSDL_Palette; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateSurfacePalette' {$ENDIF} {$ENDIF};

{*
 * Set the palette used by a surface.
 *
 * Setting the palette keeps an internal reference to the palette, which can
 * be safely destroyed afterwards.
 *
 * A single palette can be shared with many surfaces.
 *
 * \param surface the SDL_Surface structure to update.
 * \param palette the SDL_Palette structure to use.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreatePalette
 * \sa SDL_GetSurfacePalette
  }
function SDL_SetSurfacePalette(surface: PSDL_Surface; palette: PSDL_Palette): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfacePalette' {$ENDIF} {$ENDIF};

{*
 * Get the palette used by a surface.
 *
 * \param surface the SDL_Surface structure to query.
 * \returns a Pointer to the palette used by the surface, or nil if there is
 *          no palette used.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfacePalette
  }
function SDL_GetSurfacePalette(surface: PSDL_Surface): PSDL_Palette; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfacePalette' {$ENDIF} {$ENDIF};

{*
 * Add an alternate version of a surface.
 *
 * This function adds an alternate version of this surface, usually used for
 * content with high DPI representations like cursors or icons. The size,
 * format, and content do not need to match the original surface, and these
 * alternate versions will not be updated when the original surface changes.
 *
 * This function adds a reference to the alternate version, so you should call
 * SDL_DestroySurface() on the image after this call.
 *
 * \param surface the SDL_Surface structure to update.
 * \param image a Pointer to an alternate SDL_Surface to associate with this
 *              surface.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RemoveSurfaceAlternateImages
 * \sa SDL_GetSurfaceImages
 * \sa SDL_SurfaceHasAlternateImages
  }
function SDL_AddSurfaceAlternateImage(surface: PSDL_Surface; image: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AddSurfaceAlternateImage' {$ENDIF} {$ENDIF};

{*
 * Return whether a surface has alternate versions available.
 *
 * \param surface the SDL_Surface structure to query.
 * \returns true if alternate versions are available or false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddSurfaceAlternateImage
 * \sa SDL_RemoveSurfaceAlternateImages
 * \sa SDL_GetSurfaceImages
  }
function SDL_SurfaceHasAlternateImages(surface: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SurfaceHasAlternateImages' {$ENDIF} {$ENDIF};

{*
 * Get an array including all versions of a surface.
 *
 * This returns all versions of a surface, with the surface being queried as
 * the first element in the returned array.
 *
 * Freeing the array of surfaces does not affect the surfaces in the array.
 * They are still referenced by the surface being queried and will be cleaned
 * up normally.
 *
 * \param surface the SDL_Surface structure to query.
 * \param count a Pointer filled in with the number of surface pointers
 *              returned, may be nil.
 * \returns a nil terminated array of SDL_Surface pointers or nil on
 *          failure; call SDL_GetError() for more information. This should be
 *          freed with SDL_free() when it is no longer needed.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddSurfaceAlternateImage
 * \sa SDL_RemoveSurfaceAlternateImages
 * \sa SDL_SurfaceHasAlternateImages
  }
function SDL_GetSurfaceImages(surface: PSDL_Surface; count: pcint): PPSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceImages' {$ENDIF} {$ENDIF};

{*
 * Remove all alternate versions of a surface.
 *
 * This function removes a reference from all the alternative versions,
 * destroying them if this is the last reference to them.
 *
 * \param surface the SDL_Surface structure to update.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddSurfaceAlternateImage
 * \sa SDL_GetSurfaceImages
 * \sa SDL_SurfaceHasAlternateImages
  }
procedure SDL_RemoveSurfaceAlternateImages(surface: PSDL_Surface); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RemoveSurfaceAlternateImages' {$ENDIF} {$ENDIF};

{*
 * Set up a surface for directly accessing the pixels.
 *
 * Between calls to SDL_LockSurface() / SDL_UnlockSurface(), you can write to
 * and read from `surface->pixels`, using the pixel format stored in
 * `surface->format`. Once you are done accessing the surface, you should use
 * SDL_UnlockSurface() to release it.
 *
 * Not all surfaces require locking. If `SDL_MUSTLOCK(surface)` evaluates to
 * 0, then you can read and write to the surface at any time, and the pixel
 * format of the surface will not change.
 *
 * \param surface the SDL_Surface structure to be locked.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces. The locking referred to by this function
 *               is making the pixels available for direct access, not
 *               thread-safe locking.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_MUSTLOCK
 * \sa SDL_UnlockSurface
  }
function SDL_LockSurface(surface: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LockSurface' {$ENDIF} {$ENDIF};

{*
 * Release a surface after directly accessing the pixels.
 *
 * \param surface the SDL_Surface structure to be unlocked.
 *
 * \threadsafety This function is not thread safe. The locking referred to by
 *               this function is making the pixels available for direct
 *               access, not thread-safe locking.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LockSurface
  }
procedure SDL_UnlockSurface(surface: PSDL_Surface); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UnlockSurface' {$ENDIF} {$ENDIF};

{*
 * Load a BMP or PNG image from a seekable SDL data stream.
 *
 * The new surface should be freed with SDL_DestroySurface(). Not doing so
 * will result in a memory leak.
 *
 * \param src the data stream for the surface.
 * \param closeio if true, calls SDL_CloseIO() on `src` before returning, even
 *                in the case of an error.
 * \returns a Pointer to a new SDL_Surface structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_DestroySurface
 * \sa SDL_LoadSurface
  }
function SDL_LoadSurface_IO(src: PSDL_IOStream; closeio: Boolean): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadSurface_IO' {$ENDIF} {$ENDIF};

{*
 * Load a BMP or PNG image from a file.
 *
 * The new surface should be freed with SDL_DestroySurface(). Not doing so
 * will result in a memory leak.
 *
 * \param file the file to load.
 * \returns a Pointer to a new SDL_Surface structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_DestroySurface
 * \sa SDL_LoadSurface_IO
  }
function SDL_LoadSurface(file_: PAnsiChar): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadSurface' {$ENDIF} {$ENDIF};

{*
 * Load a BMP image from a seekable SDL data stream.
 *
 * The new surface should be freed with SDL_DestroySurface(). Not doing so
 * will result in a memory leak.
 *
 * \param src the data stream for the surface.
 * \param closeio if true, calls SDL_CloseIO() on `src` before returning, even
 *                in the case of an error.
 * \returns a Pointer to a new SDL_Surface structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroySurface
 * \sa SDL_LoadBMP
 * \sa SDL_SaveBMP_IO
  }
function SDL_LoadBMP_IO(src: PSDL_IOStream; closeio: Boolean): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadBMP_IO' {$ENDIF} {$ENDIF};

{*
 * Load a BMP image from a file.
 *
 * The new surface should be freed with SDL_DestroySurface(). Not doing so
 * will result in a memory leak.
 *
 * \param file the BMP file to load.
 * \returns a Pointer to a new SDL_Surface structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroySurface
 * \sa SDL_LoadBMP_IO
 * \sa SDL_SaveBMP
  }

function SDL_LoadBMP(file_: PAnsiChar): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadBMP' {$ENDIF} {$ENDIF};

{*
 * Save a surface to a seekable SDL data stream in BMP format.
 *
 * Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
 * BMP directly. Other RGB formats with 8-bit or higher get converted to a
 * 24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
 * surface before they are saved. YUV and paletted 1-bit and 4-bit formats are
 * not supported.
 *
 * \param surface the SDL_Surface structure containing the image to be saved.
 * \param dst a data stream to save to.
 * \param closeio if true, calls SDL_CloseIO() on `dst` before returning, even
 *                in the case of an error.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadBMP_IO
 * \sa SDL_SaveBMP
  }
function SDL_SaveBMP_IO(surface: PSDL_Surface; dst: PSDL_IOStream; closeio: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SaveBMP_IO' {$ENDIF} {$ENDIF};

{*
 * Save a surface to a file in BMP format.
 *
 * Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
 * BMP directly. Other RGB formats with 8-bit or higher get converted to a
 * 24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
 * surface before they are saved. YUV and paletted 1-bit and 4-bit formats are
 * not supported.
 *
 * \param surface the SDL_Surface structure containing the image to be saved.
 * \param file a file to save to.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadBMP
 * \sa SDL_SaveBMP_IO
  }
function SDL_SaveBMP(surface: PSDL_Surface; file_: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SaveBMP' {$ENDIF} {$ENDIF};

{*
 * Load a PNG image from a seekable SDL data stream.
 *
 * This is intended as a convenience function for loading images from trusted
 * sources. If you want to load arbitrary images you should use libpng or
 * another image loading library designed with security in mind.
 *
 * The new surface should be freed with SDL_DestroySurface(). Not doing so
 * will result in a memory leak.
 *
 * \param src the data stream for the surface.
 * \param closeio if true, calls SDL_CloseIO() on `src` before returning, even
 *                in the case of an error.
 * \returns a Pointer to a new SDL_Surface structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_DestroySurface
 * \sa SDL_LoadPNG
 * \sa SDL_SavePNG_IO
  }
function SDL_LoadPNG_IO(src: PSDL_IOStream; closeio: Boolean): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadPNG_IO' {$ENDIF} {$ENDIF};

{*
 * Load a PNG image from a file.
 *
 * This is intended as a convenience function for loading images from trusted
 * sources. If you want to load arbitrary images you should use libpng or
 * another image loading library designed with security in mind.
 *
 * The new surface should be freed with SDL_DestroySurface(). Not doing so
 * will result in a memory leak.
 *
 * \param file the PNG file to load.
 * \returns a Pointer to a new SDL_Surface structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_DestroySurface
 * \sa SDL_LoadPNG_IO
 * \sa SDL_SavePNG
  }
function SDL_LoadPNG(file_: PAnsiChar): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadPNG' {$ENDIF} {$ENDIF};

{*
 * Save a surface to a seekable SDL data stream in PNG format.
 *
 * \param surface the SDL_Surface structure containing the image to be saved.
 * \param dst a data stream to save to.
 * \param closeio if true, calls SDL_CloseIO() on `dst` before returning, even
 *                in the case of an error.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_LoadPNG_IO
 * \sa SDL_SavePNG
  }
function SDL_SavePNG_IO(surface: PSDL_Surface; dst: PSDL_IOStream; closeio: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SavePNG_IO' {$ENDIF} {$ENDIF};

{*
 * Save a surface to a file in PNG format.
 *
 * \param surface the SDL_Surface structure containing the image to be saved.
 * \param file a file to save to.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_LoadPNG
 * \sa SDL_SavePNG_IO
  }

function SDL_SavePNG(surface: PSDL_Surface; file_: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SavePNG' {$ENDIF} {$ENDIF};

{*
 * Set the RLE acceleration hint for a surface.
 *
 * If RLE is enabled, color key and alpha blending blits are much faster, but
 * the surface must be locked before directly accessing the pixels.
 *
 * \param surface the SDL_Surface structure to optimize.
 * \param enabled true to enable RLE acceleration, false to disable it.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurface
 * \sa SDL_LockSurface
 * \sa SDL_UnlockSurface
  }
function SDL_SetSurfaceRLE(surface: PSDL_Surface; enabled: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceRLE' {$ENDIF} {$ENDIF};

{*
 * Returns whether the surface is RLE enabled.
 *
 * It is safe to pass a nil `surface` here; it will return false.
 *
 * \param surface the SDL_Surface structure to query.
 * \returns true if the surface is RLE enabled, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfaceRLE
  }
function SDL_SurfaceHasRLE(surface: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SurfaceHasRLE' {$ENDIF} {$ENDIF};

{*
 * Set the color key (transparent pixel) in a surface.
 *
 * The color key defines a pixel value that will be treated as transparent in
 * a blit. For example, one can use this to specify that cyan pixels should be
 * considered transparent, and therefore not rendered.
 *
 * It is a pixel of the format used by the surface, as generated by
 * SDL_MapRGB().
 *
 * \param surface the SDL_Surface structure to update.
 * \param enabled true to enable color key, false to disable color key.
 * \param key the transparent pixel.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceColorKey
 * \sa SDL_SetSurfaceRLE
 * \sa SDL_SurfaceHasColorKey
  }
function SDL_SetSurfaceColorKey(surface: PSDL_Surface; enabled: Boolean; key: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceColorKey' {$ENDIF} {$ENDIF};

{*
 * Returns whether the surface has a color key.
 *
 * It is safe to pass a nil `surface` here; it will return false.
 *
 * \param surface the SDL_Surface structure to query.
 * \returns true if the surface has a color key, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfaceColorKey
 * \sa SDL_GetSurfaceColorKey
  }
function SDL_SurfaceHasColorKey(surface: PSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SurfaceHasColorKey' {$ENDIF} {$ENDIF};

{*
 * Get the color key (transparent pixel) for a surface.
 *
 * The color key is a pixel of the format used by the surface, as generated by
 * SDL_MapRGB().
 *
 * If the surface doesn't have color key enabled this function returns false.
 *
 * \param surface the SDL_Surface structure to query.
 * \param key a Pointer filled in with the transparent pixel.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfaceColorKey
 * \sa SDL_SurfaceHasColorKey
  }
function SDL_GetSurfaceColorKey(surface: PSDL_Surface; key: pcuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceColorKey' {$ENDIF} {$ENDIF};

{*
 * Set an additional color value multiplied into blit operations.
 *
 * When this surface is blitted, during the blit operation each source color
 * channel is modulated by the appropriate color value according to the
 * following formula:
 *
 * `srcC = srcC * (color / 255)`
 *
 * \param surface the SDL_Surface structure to update.
 * \param r the red color value multiplied into blit operations.
 * \param g the green color value multiplied into blit operations.
 * \param b the blue color value multiplied into blit operations.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceColorMod
 * \sa SDL_SetSurfaceAlphaMod
  }
function SDL_SetSurfaceColorMod(surface: PSDL_Surface; r: cuint8; g: cuint8; b: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceColorMod' {$ENDIF} {$ENDIF};

{*
 * Get the additional color value multiplied into blit operations.
 *
 * \param surface the SDL_Surface structure to query.
 * \param r a Pointer filled in with the current red color value.
 * \param g a Pointer filled in with the current green color value.
 * \param b a Pointer filled in with the current blue color value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceAlphaMod
 * \sa SDL_SetSurfaceColorMod
  }
function SDL_GetSurfaceColorMod(surface: PSDL_Surface; r: pcuint8; g: pcuint8; b: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceColorMod' {$ENDIF} {$ENDIF};

{*
 * Set an additional alpha value used in blit operations.
 *
 * When this surface is blitted, during the blit operation the source alpha
 * value is modulated by this alpha value according to the following formula:
 *
 * `srcA = srcA * (alpha / 255)`
 *
 * \param surface the SDL_Surface structure to update.
 * \param alpha the alpha value multiplied into blit operations.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceAlphaMod
 * \sa SDL_SetSurfaceColorMod
  }
function SDL_SetSurfaceAlphaMod(surface: PSDL_Surface; alpha: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceAlphaMod' {$ENDIF} {$ENDIF};

{*
 * Get the additional alpha value used in blit operations.
 *
 * \param surface the SDL_Surface structure to query.
 * \param alpha a Pointer filled in with the current alpha value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceColorMod
 * \sa SDL_SetSurfaceAlphaMod
  }
function SDL_GetSurfaceAlphaMod(surface: PSDL_Surface; alpha: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceAlphaMod' {$ENDIF} {$ENDIF};

{*
 * Set the blend mode used for blit operations.
 *
 * To copy a surface to another surface (or texture) without blending with the
 * existing data, the blendmode of the SOURCE surface should be set to
 * `SDL_BLENDMODE_NONE`.
 *
 * \param surface the SDL_Surface structure to update.
 * \param blendMode the SDL_BlendMode to use for blit blending.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceBlendMode
  }
function SDL_SetSurfaceBlendMode(surface: PSDL_Surface; blendMode: TSDL_BlendMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceBlendMode' {$ENDIF} {$ENDIF};

{*
 * Get the blend mode used for blit operations.
 *
 * \param surface the SDL_Surface structure to query.
 * \param blendMode a Pointer filled in with the current SDL_BlendMode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfaceBlendMode
  }
function SDL_GetSurfaceBlendMode(surface: PSDL_Surface; blendMode: PSDL_BlendMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceBlendMode' {$ENDIF} {$ENDIF};

{*
 * Set the clipping rectangle for a surface.
 *
 * When `surface` is the destination of a blit, only the area within the clip
 * rectangle is drawn into.
 *
 * Note that blits are automatically clipped to the edges of the source and
 * destination surfaces.
 *
 * \param surface the SDL_Surface structure to be clipped.
 * \param rect the SDL_Rect structure representing the clipping rectangle, or
 *             nil to disable clipping.
 * \returns true if the rectangle intersects the surface, otherwise false and
 *          blits will be completely clipped.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetSurfaceClipRect
  }
function SDL_SetSurfaceClipRect(surface: PSDL_Surface; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetSurfaceClipRect' {$ENDIF} {$ENDIF};

{*
 * Get the clipping rectangle for a surface.
 *
 * When `surface` is the destination of a blit, only the area within the clip
 * rectangle is drawn into.
 *
 * \param surface the SDL_Surface structure representing the surface to be
 *                clipped.
 * \param rect an SDL_Rect structure filled in with the clipping rectangle for
 *             the surface.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetSurfaceClipRect
  }
function SDL_GetSurfaceClipRect(surface: PSDL_Surface; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSurfaceClipRect' {$ENDIF} {$ENDIF};

{*
 * Flip a surface vertically or horizontally.
 *
 * \param surface the surface to flip.
 * \param flip the direction to flip.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_FlipSurface(surface: PSDL_Surface; flip: TSDL_FlipMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FlipSurface' {$ENDIF} {$ENDIF};

{*
 * Return a copy of a surface rotated clockwise a number of degrees.
 *
 * The angle of rotation can be negative for counter-clockwise rotation.
 *
 * When the rotation isn't a multiple of 90 degrees, the resulting surface is
 * larger than the original, with the background filled in with the colorkey,
 * if available, or RGBA 255/255/255/0 if not.
 *
 * If `surface` has the SDL_PROP_SURFACE_ROTATION_FLOAT property set on it,
 * the new copy will have the adjusted value set: if the rotation property is
 * 90 and `angle` was 30, the new surface will have a property value of 60
 * (that is: to be upright vs gravity, this surface needs to rotate 60 more
 * degrees). However, note that further rotations on the new surface in this
 * example will produce unexpected results, since the image will have resized
 * and padded to accommodate the not-90 degree angle.
 *
 * \param surface the surface to rotate.
 * \param angle the rotation angle, in degrees.
 * \returns a rotated copy of the surface or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_RotateSurface(surface: PSDL_Surface; angle: cfloat): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RotateSurface' {$ENDIF} {$ENDIF};

{*
 * Creates a new surface identical to the existing surface.
 *
 * If the original surface has alternate images, the new surface will have a
 * reference to them as well.
 *
 * The returned surface should be freed with SDL_DestroySurface().
 *
 * \param surface the surface to duplicate.
 * \returns a copy of the surface or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroySurface
  }
function SDL_DuplicateSurface(surface: PSDL_Surface): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DuplicateSurface' {$ENDIF} {$ENDIF};

{*
 * Creates a new surface identical to the existing surface, scaled to the
 * desired size.
 *
 * The returned surface should be freed with SDL_DestroySurface().
 *
 * \param surface the surface to duplicate and scale.
 * \param width the width of the new surface.
 * \param height the height of the new surface.
 * \param scaleMode the SDL_ScaleMode to be used.
 * \returns a copy of the surface or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroySurface
  }
function SDL_ScaleSurface(surface: PSDL_Surface; width: cint; height: cint; scaleMode: TSDL_ScaleMode): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ScaleSurface' {$ENDIF} {$ENDIF};

{*
 * Copy an existing surface to a new surface of the specified format.
 *
 * This function is used to optimize images for faster *repeat* blitting. This
 * is accomplished by converting the original and storing the result as a new
 * surface. The new, optimized surface can then be used as the source for
 * future blits, making them faster.
 *
 * If you are converting to an indexed surface and want to map colors to a
 * palette, you can use SDL_ConvertSurfaceAndColorspace() instead.
 *
 * If the original surface has alternate images, the new surface will have a
 * reference to them as well.
 *
 * \param surface the existing SDL_Surface structure to convert.
 * \param format the new pixel format.
 * \returns the new SDL_Surface structure that is created or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ConvertSurfaceAndColorspace
 * \sa SDL_DestroySurface
  }
function SDL_ConvertSurface(surface: PSDL_Surface; format: TSDL_PixelFormat): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ConvertSurface' {$ENDIF} {$ENDIF};

{*
 * Copy an existing surface to a new surface of the specified format and
 * colorspace.
 *
 * This function converts an existing surface to a new format and colorspace
 * and returns the new surface. This will perform any pixel format and
 * colorspace conversion needed.
 *
 * If the original surface has alternate images, the new surface will have a
 * reference to them as well.
 *
 * \param surface the existing SDL_Surface structure to convert.
 * \param format the new pixel format.
 * \param palette an optional palette to use for indexed formats, may be nil.
 * \param colorspace the new colorspace.
 * \param props an SDL_PropertiesID with additional color properties, or 0.
 * \returns the new SDL_Surface structure that is created or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ConvertSurface
 * \sa SDL_DestroySurface
  }
function SDL_ConvertSurfaceAndColorspace(surface: PSDL_Surface; format: TSDL_PixelFormat; palette: PSDL_Palette; colorspace: TSDL_Colorspace; props: TSDL_PropertiesID): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ConvertSurfaceAndColorspace' {$ENDIF} {$ENDIF};

{*
 * Copy a block of pixels of one format to another format.
 *
 * \param width the width of the block to copy, in pixels.
 * \param height the height of the block to copy, in pixels.
 * \param src_format an SDL_PixelFormat value of the `src` pixels format.
 * \param src a Pointer to the source pixels.
 * \param src_pitch the pitch of the source pixels, in bytes.
 * \param dst_format an SDL_PixelFormat value of the `dst` pixels format.
 * \param dst a Pointer to be filled in with new pixel data.
 * \param dst_pitch the pitch of the destination pixels, in bytes.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety The same destination pixels should not be used from two
 *               threads at once. It is safe to use the same source pixels
 *               from multiple threads.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ConvertPixelsAndColorspace
  }
function SDL_ConvertPixels(width: cint; height: cint; src_format: TSDL_PixelFormat; src: Pointer; src_pitch: cint; dst_format: TSDL_PixelFormat; dst: Pointer; dst_pitch: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ConvertPixels' {$ENDIF} {$ENDIF};

{*
 * Copy a block of pixels of one format and colorspace to another format and
 * colorspace.
 *
 * \param width the width of the block to copy, in pixels.
 * \param height the height of the block to copy, in pixels.
 * \param src_format an SDL_PixelFormat value of the `src` pixels format.
 * \param src_colorspace an SDL_Colorspace value describing the colorspace of
 *                       the `src` pixels.
 * \param src_properties an SDL_PropertiesID with additional source color
 *                       properties, or 0.
 * \param src a Pointer to the source pixels.
 * \param src_pitch the pitch of the source pixels, in bytes.
 * \param dst_format an SDL_PixelFormat value of the `dst` pixels format.
 * \param dst_colorspace an SDL_Colorspace value describing the colorspace of
 *                       the `dst` pixels.
 * \param dst_properties an SDL_PropertiesID with additional destination color
 *                       properties, or 0.
 * \param dst a Pointer to be filled in with new pixel data.
 * \param dst_pitch the pitch of the destination pixels, in bytes.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety The same destination pixels should not be used from two
 *               threads at once. It is safe to use the same source pixels
 *               from multiple threads.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ConvertPixels
  }
function SDL_ConvertPixelsAndColorspace(width: cint; height: cint; src_format: TSDL_PixelFormat; src_colorspace: TSDL_Colorspace; src_properties: TSDL_PropertiesID; src: Pointer; src_pitch: cint; dst_format: TSDL_PixelFormat; dst_colorspace: TSDL_Colorspace; dst_properties: TSDL_PropertiesID; dst: Pointer; dst_pitch: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ConvertPixelsAndColorspace' {$ENDIF} {$ENDIF};

{*
 * Premultiply the alpha on a block of pixels.
 *
 * This is safe to use with src == dst, but not for other overlapping areas.
 *
 * \param width the width of the block to convert, in pixels.
 * \param height the height of the block to convert, in pixels.
 * \param src_format an SDL_PixelFormat value of the `src` pixels format.
 * \param src a Pointer to the source pixels.
 * \param src_pitch the pitch of the source pixels, in bytes.
 * \param dst_format an SDL_PixelFormat value of the `dst` pixels format.
 * \param dst a Pointer to be filled in with premultiplied pixel data.
 * \param dst_pitch the pitch of the destination pixels, in bytes.
 * \param linear true to convert from sRGB to linear space for the alpha
 *               multiplication, false to do multiplication in sRGB space.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety The same destination pixels should not be used from two
 *               threads at once. It is safe to use the same source pixels
 *               from multiple threads.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_PremultiplyAlpha(width: cint; height: cint; src_format: TSDL_PixelFormat; src: Pointer; src_pitch: cint; dst_format: TSDL_PixelFormat; dst: Pointer; dst_pitch: cint; linear: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PremultiplyAlpha' {$ENDIF} {$ENDIF};

{*
 * Premultiply the alpha in a surface.
 *
 * This is safe to use with src == dst, but not for other overlapping areas.
 *
 * \param surface the surface to modify.
 * \param linear true to convert from sRGB to linear space for the alpha
 *               multiplication, false to do multiplication in sRGB space.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_PremultiplySurfaceAlpha(surface: PSDL_Surface; linear: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PremultiplySurfaceAlpha' {$ENDIF} {$ENDIF};

{*
 * Clear a surface with a specific color, with floating point precision.
 *
 * This function handles all surface formats, and ignores any clip rectangle.
 *
 * If the surface is YUV, the color is assumed to be in the sRGB colorspace,
 * otherwise the color is assumed to be in the colorspace of the surface.
 *
 * \param surface the SDL_Surface to clear.
 * \param r the red component of the pixel, normally in the range 0-1.
 * \param g the green component of the pixel, normally in the range 0-1.
 * \param b the blue component of the pixel, normally in the range 0-1.
 * \param a the alpha component of the pixel, normally in the range 0-1.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ClearSurface(surface: PSDL_Surface; r: cfloat; g: cfloat; b: cfloat; a: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ClearSurface' {$ENDIF} {$ENDIF};

{*
 * Perform a fast fill of a rectangle with a specific color.
 *
 * `color` should be a pixel of the format used by the surface, and can be
 * generated by SDL_MapRGB() or SDL_MapRGBA(). If the color value contains an
 * alpha component then the destination is simply filled with that alpha
 * information, no blending takes place.
 *
 * If there is a clip rectangle set on the destination (set via
 * SDL_SetSurfaceClipRect()), then this function will fill based on the
 * intersection of the clip rectangle and `rect`.
 *
 * \param dst the SDL_Surface structure that is the drawing target.
 * \param rect the SDL_Rect structure representing the rectangle to fill, or
 *             nil to fill the entire surface.
 * \param color the color to fill with.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_FillSurfaceRects
  }
function SDL_FillSurfaceRect(dst: PSDL_Surface; rect: PSDL_Rect; color: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FillSurfaceRect' {$ENDIF} {$ENDIF};

{*
 * Perform a fast fill of a set of rectangles with a specific color.
 *
 * `color` should be a pixel of the format used by the surface, and can be
 * generated by SDL_MapRGB() or SDL_MapRGBA(). If the color value contains an
 * alpha component then the destination is simply filled with that alpha
 * information, no blending takes place.
 *
 * If there is a clip rectangle set on the destination (set via
 * SDL_SetSurfaceClipRect()), then this function will fill based on the
 * intersection of the clip rectangle and `rect`.
 *
 * \param dst the SDL_Surface structure that is the drawing target.
 * \param rects an array of SDL_Rects representing the rectangles to fill.
 * \param count the number of rectangles in the array.
 * \param color the color to fill with.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_FillSurfaceRect
  }
function SDL_FillSurfaceRects(dst: PSDL_Surface; rects: PSDL_Rect; count: cint; color: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FillSurfaceRects' {$ENDIF} {$ENDIF};

{*
 * Performs a fast blit from the source surface to the destination surface
 * with clipping.
 *
 * If either `srcrect` or `dstrect` are nil, the entire surface (`src` or
 * `dst`) is copied while ensuring clipping to `dst->clip_rect`.
 *
 * The blit function should not be called on a locked surface.
 *
 * The blit semantics for surfaces with and without blending and colorkey are
 * defined as follows:
 *
 * ```
 *    RGBA->RGB:
 *      Source surface blend mode set to SDL_BLENDMODE_BLEND:
 *       alpha-blend (using the source alpha-channel and per-surface alpha)
 *       SDL_SRCCOLORKEY ignored.
 *     Source surface blend mode set to SDL_BLENDMODE_NONE:
 *       copy RGB.
 *       if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
 *       RGB values of the source color key, ignoring alpha in the
 *       comparison.
 *
 *   RGB->RGBA:
 *     Source surface blend mode set to SDL_BLENDMODE_BLEND:
 *       alpha-blend (using the source per-surface alpha)
 *     Source surface blend mode set to SDL_BLENDMODE_NONE:
 *       copy RGB, set destination alpha to source per-surface alpha value.
 *     both:
 *       if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
 *       source color key.
 *
 *   RGBA->RGBA:
 *     Source surface blend mode set to SDL_BLENDMODE_BLEND:
 *       alpha-blend (using the source alpha-channel and per-surface alpha)
 *       SDL_SRCCOLORKEY ignored.
 *     Source surface blend mode set to SDL_BLENDMODE_NONE:
 *       copy all of RGBA to the destination.
 *       if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
 *       RGB values of the source color key, ignoring alpha in the
 *       comparison.
 *
 *   RGB->RGB:
 *     Source surface blend mode set to SDL_BLENDMODE_BLEND:
 *       alpha-blend (using the source per-surface alpha)
 *     Source surface blend mode set to SDL_BLENDMODE_NONE:
 *       copy RGB.
 *     both:
 *       if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
 *       source color key.
 * ```
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be
 *                copied, or nil to copy the entire surface.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the x and y position in
 *                the destination surface, or nil for (0,0). The width and
 *                height are ignored, and are copied from `srcrect`. If you
 *                want a specific width and height, you should use
 *                SDL_BlitSurfaceScaled().
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurfaceScaled
  }
function SDL_BlitSurface(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurface' {$ENDIF} {$ENDIF};

{*
 * Perform low-level surface blitting only.
 *
 * This is a semi-private blit function and it performs low-level surface
 * blitting, assuming the input rectangles have already been clipped.
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be
 *                copied, may not be nil.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the target rectangle in
 *                the destination surface, may not be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurface
  }
function SDL_BlitSurfaceUnchecked(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurfaceUnchecked' {$ENDIF} {$ENDIF};

{*
 * Perform a scaled blit to a destination surface, which may be of a different
 * format.
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be
 *                copied, or nil to copy the entire surface.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the target rectangle in
 *                the destination surface, or nil to fill the entire
 *                destination surface.
 * \param scaleMode the SDL_ScaleMode to be used.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurface
  }
function SDL_BlitSurfaceScaled(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect; scaleMode: TSDL_ScaleMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurfaceScaled' {$ENDIF} {$ENDIF};

{*
 * Perform low-level surface scaled blitting only.
 *
 * This is a semi-private function and it performs low-level surface blitting,
 * assuming the input rectangles have already been clipped.
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be
 *                copied, may not be nil.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the target rectangle in
 *                the destination surface, may not be nil.
 * \param scaleMode the SDL_ScaleMode to be used.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurfaceScaled
  }
function SDL_BlitSurfaceUncheckedScaled(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect; scaleMode: TSDL_ScaleMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurfaceUncheckedScaled' {$ENDIF} {$ENDIF};

{*
 * Perform a tiled blit to a destination surface, which may be of a different
 * format.
 *
 * The pixels in `srcrect` will be repeated as many times as needed to
 * completely fill `dstrect`.
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be
 *                copied, or nil to copy the entire surface.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the target rectangle in
 *                the destination surface, or nil to fill the entire surface.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurface
  }
function SDL_BlitSurfaceTiled(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurfaceTiled' {$ENDIF} {$ENDIF};

{*
 * Perform a scaled and tiled blit to a destination surface, which may be of a
 * different format.
 *
 * The pixels in `srcrect` will be scaled and repeated as many times as needed
 * to completely fill `dstrect`.
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be
 *                copied, or nil to copy the entire surface.
 * \param scale the scale used to transform srcrect into the destination
 *              rectangle, e.g. a 32x32 texture with a scale of 2 would fill
 *              64x64 tiles.
 * \param scaleMode scale algorithm to be used.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the target rectangle in
 *                the destination surface, or nil to fill the entire surface.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurface
  }
function SDL_BlitSurfaceTiledWithScale(src: PSDL_Surface; srcrect: PSDL_Rect; scale: cfloat; scaleMode: TSDL_ScaleMode; dst: PSDL_Surface; dstrect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurfaceTiledWithScale' {$ENDIF} {$ENDIF};

{*
 * Perform a scaled blit using the 9-grid algorithm to a destination surface,
 * which may be of a different format.
 *
 * The pixels in the source surface are split into a 3x3 grid, using the
 * different corner sizes for each corner, and the sides and center making up
 * the remaining pixels. The corners are then scaled using `scale` and fit
 * into the corners of the destination rectangle. The sides and center are
 * then stretched into place to cover the remaining destination rectangle.
 *
 * \param src the SDL_Surface structure to be copied from.
 * \param srcrect the SDL_Rect structure representing the rectangle to be used
 *                for the 9-grid, or nil to use the entire surface.
 * \param left_width the width, in pixels, of the left corners in `srcrect`.
 * \param right_width the width, in pixels, of the right corners in `srcrect`.
 * \param top_height the height, in pixels, of the top corners in `srcrect`.
 * \param bottom_height the height, in pixels, of the bottom corners in
 *                      `srcrect`.
 * \param scale the scale used to transform the corner of `srcrect` into the
 *              corner of `dstrect`, or 0.0f for an unscaled blit.
 * \param scaleMode scale algorithm to be used.
 * \param dst the SDL_Surface structure that is the blit target.
 * \param dstrect the SDL_Rect structure representing the target rectangle in
 *                the destination surface, or nil to fill the entire surface.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Only one thread should be using the `src` and `dst` surfaces
 *               at any given time.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BlitSurface
  }
function SDL_BlitSurface9Grid(src: PSDL_Surface; srcrect: PSDL_Rect; left_width: cint; right_width: cint; top_height: cint; bottom_height: cint; scale: cfloat; scaleMode: TSDL_ScaleMode; dst: PSDL_Surface; dstrect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitSurface9Grid' {$ENDIF} {$ENDIF};

{*
 * Map an RGB triple to an opaque pixel value for a surface.
 *
 * This function maps the RGB color value to the specified pixel format and
 * returns the pixel value best approximating the given RGB color value for
 * the given pixel format.
 *
 * If the surface has a palette, the index of the closest matching color in
 * the palette will be returned.
 *
 * If the surface pixel format has an alpha component it will be returned as
 * all 1 bits (fully opaque).
 *
 * If the pixel format bpp (color depth) is less than 32-bpp then the unused
 * upper bits of the return value can safely be ignored (e.g., with a 16-bpp
 * format the return value can be assigned to a Uint16, and similarly a Uint8
 * for an 8-bpp format).
 *
 * \param surface the surface to use for the pixel format and palette.
 * \param r the red component of the pixel in the range 0-255.
 * \param g the green component of the pixel in the range 0-255.
 * \param b the blue component of the pixel in the range 0-255.
 * \returns a pixel value.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_MapSurfaceRGBA
  }
function SDL_MapSurfaceRGB(surface: PSDL_Surface; r: cuint8; g: cuint8; b: cuint8): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_MapSurfaceRGB' {$ENDIF} {$ENDIF};

{*
 * Map an RGBA quadruple to a pixel value for a surface.
 *
 * This function maps the RGBA color value to the specified pixel format and
 * returns the pixel value best approximating the given RGBA color value for
 * the given pixel format.
 *
 * If the surface pixel format has no alpha component the alpha value will be
 * ignored (as it will be in formats with a palette).
 *
 * If the surface has a palette, the index of the closest matching color in
 * the palette will be returned.
 *
 * If the pixel format bpp (color depth) is less than 32-bpp then the unused
 * upper bits of the return value can safely be ignored (e.g., with a 16-bpp
 * format the return value can be assigned to a Uint16, and similarly a Uint8
 * for an 8-bpp format).
 *
 * \param surface the surface to use for the pixel format and palette.
 * \param r the red component of the pixel in the range 0-255.
 * \param g the green component of the pixel in the range 0-255.
 * \param b the blue component of the pixel in the range 0-255.
 * \param a the alpha component of the pixel in the range 0-255.
 * \returns a pixel value.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_MapSurfaceRGB
  }
function SDL_MapSurfaceRGBA(surface: PSDL_Surface; r: cuint8; g: cuint8; b: cuint8; a: cuint8): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_MapSurfaceRGBA' {$ENDIF} {$ENDIF};

{*
 * Retrieves a single pixel from a surface.
 *
 * This function prioritizes correctness over speed: it is suitable for unit
 * tests, but is not intended for use in a game engine.
 *
 * Like SDL_GetRGBA, this uses the entire 0..255 range when converting color
 * components from pixel formats with less than 8 bits per RGB component.
 *
 * \param surface the surface to read.
 * \param x the horizontal coordinate, 0 <= x < width.
 * \param y the vertical coordinate, 0 <= y < height.
 * \param r a Pointer filled in with the red channel, 0-255, or nil to ignore
 *          this channel.
 * \param g a Pointer filled in with the green channel, 0-255, or nil to
 *          ignore this channel.
 * \param b a Pointer filled in with the blue channel, 0-255, or nil to
 *          ignore this channel.
 * \param a a Pointer filled in with the alpha channel, 0-255, or nil to
 *          ignore this channel.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadSurfacePixel(surface: PSDL_Surface; x: cint; y: cint; r: pcuint8; g: pcuint8; b: pcuint8; a: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadSurfacePixel' {$ENDIF} {$ENDIF};

{*
 * Retrieves a single pixel from a surface.
 *
 * This function prioritizes correctness over speed: it is suitable for unit
 * tests, but is not intended for use in a game engine.
 *
 * \param surface the surface to read.
 * \param x the horizontal coordinate, 0 <= x < width.
 * \param y the vertical coordinate, 0 <= y < height.
 * \param r a Pointer filled in with the red channel, normally in the range
 *          0-1, or nil to ignore this channel.
 * \param g a Pointer filled in with the green channel, normally in the range
 *          0-1, or nil to ignore this channel.
 * \param b a Pointer filled in with the blue channel, normally in the range
 *          0-1, or nil to ignore this channel.
 * \param a a Pointer filled in with the alpha channel, normally in the range
 *          0-1, or nil to ignore this channel.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadSurfacePixelFloat(surface: PSDL_Surface; x: cint; y: cint; r: pcfloat; g: pcfloat; b: pcfloat; a: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadSurfacePixelFloat' {$ENDIF} {$ENDIF};

{*
 * Writes a single pixel to a surface.
 *
 * This function prioritizes correctness over speed: it is suitable for unit
 * tests, but is not intended for use in a game engine.
 *
 * Like SDL_MapRGBA, this uses the entire 0..255 range when converting color
 * components from pixel formats with less than 8 bits per RGB component.
 *
 * \param surface the surface to write.
 * \param x the horizontal coordinate, 0 <= x < width.
 * \param y the vertical coordinate, 0 <= y < height.
 * \param r the red channel value, 0-255.
 * \param g the green channel value, 0-255.
 * \param b the blue channel value, 0-255.
 * \param a the alpha channel value, 0-255.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteSurfacePixel(surface: PSDL_Surface; x: cint; y: cint; r: cuint8; g: cuint8; b: cuint8; a: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteSurfacePixel' {$ENDIF} {$ENDIF};

{*
 * Writes a single pixel to a surface.
 *
 * This function prioritizes correctness over speed: it is suitable for unit
 * tests, but is not intended for use in a game engine.
 *
 * \param surface the surface to write.
 * \param x the horizontal coordinate, 0 <= x < width.
 * \param y the vertical coordinate, 0 <= y < height.
 * \param r the red channel value, normally in the range 0-1.
 * \param g the green channel value, normally in the range 0-1.
 * \param b the blue channel value, normally in the range 0-1.
 * \param a the alpha channel value, normally in the range 0-1.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function can be called on different threads with
 *               different surfaces.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteSurfacePixelFloat(surface: PSDL_Surface; x: cint; y: cint; r: cfloat; g: cfloat; b: cfloat; a: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteSurfacePixelFloat' {$ENDIF} {$ENDIF};

