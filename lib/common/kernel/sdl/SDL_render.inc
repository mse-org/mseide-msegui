{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
  * # CategoryRender
  *
  * Header file for SDL 2D rendering functions.
  *
  * This API supports the following features:
  *
  * - single pixel points
  * - single pixel lines
  * - filled rectangles
  * - texture images
  * - 2D polygons
  *
  * The primitives may be drawn in opaque, blended, or additive modes.
  *
  * The texture images may be drawn in opaque, blended, or additive modes. They
  * can have an additional color tint or alpha modulation applied to them, and
  * may also be stretched with linear interpolation.
  *
  * This API is designed to accelerate simple 2D operations. You may want more
  * functionality such as 3D polygons and particle effects, and in that case
  * you should use SDL's OpenGL/Direct3D support, the SDL3 GPU API, or one of
  * the many good 3D engines.
  *
  * These functions must be called from the main thread. See this bug for
  * details: https://github.com/libsdl-org/SDL/issues/986
  }

{*
 * The name of the software renderer.
 *
 * \since This macro is available since SDL 3.2.0.
  }
const
  SDL_SOFTWARE_RENDERER = 'software';

{*
* The name of the GPU renderer.
*
* \since This macro is available since SDL 3.4.0.
  }
const
  SDL_GPU_RENDERER = 'gpu';

{*
 * Vertex structure.
 *
 * \since This struct is available since SDL 3.2.0.
  }
{*< Vertex position, in SDL_Renderer coordinates   }
{*< Vertex color  }
{*< Normalized texture coordinates, if needed  }
type
  PPSDL_Vertex = ^PSDL_Vertex;
  PSDL_Vertex = ^TSDL_Vertex;
  TSDL_Vertex = record
    position: TSDL_FPoint;
    color: TSDL_FColor;
    tex_coord: TSDL_FPoint;
  end;

{*
 * The access pattern allowed for a texture.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_TextureAccess = ^PSDL_TextureAccess;
  PSDL_TextureAccess = ^TSDL_TextureAccess;
  TSDL_TextureAccess = Integer;
const
  SDL_TEXTUREACCESS_STATIC = TSDL_TextureAccess(0);           {*< Changes rarely, not lockable  }
  SDL_TEXTUREACCESS_STREAMING = TSDL_TextureAccess(1);        {*< Changes frequently, lockable  }
  SDL_TEXTUREACCESS_TARGET = TSDL_TextureAccess(2);           {*< Texture can be used as a render target  }

{*
 * The addressing mode for a texture when used in SDL_RenderGeometry().
 *
 * This affects how texture coordinates are interpreted outside of [0, 1]
 *
 * Texture wrapping is always supported for power of two texture sizes, and is
 * supported for other texture sizes if
 * SDL_PROP_RENDERER_TEXTURE_WRAPPING_BOOLEAN is set to true.
 *
 * \since This enum is available since SDL 3.4.0.
  }
type
  PPSDL_TextureAddressMode = ^PSDL_TextureAddressMode;
  PSDL_TextureAddressMode = ^TSDL_TextureAddressMode;
  TSDL_TextureAddressMode = type Integer;
const
  SDL_TEXTURE_ADDRESS_INVALID = TSDL_TextureAddressMode(-1);
  SDL_TEXTURE_ADDRESS_AUTO = TSDL_TextureAddressMode(0);       {*< Wrapping is enabled if texture coordinates are outside [0, 1], this is the default  }
  SDL_TEXTURE_ADDRESS_CLAMP = TSDL_TextureAddressMode(1);      {*< Texture coordinates are clamped to the [0, 1] range  }
  SDL_TEXTURE_ADDRESS_WRAP = TSDL_TextureAddressMode(2);       {*< The texture is repeated (tiled)  }

{*
 * How the logical size is mapped to the output.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_RendererLogicalPresentation = ^PSDL_RendererLogicalPresentation;
  PSDL_RendererLogicalPresentation = ^TSDL_RendererLogicalPresentation;
  TSDL_RendererLogicalPresentation = Integer;
const
  SDL_LOGICAL_PRESENTATION_DISABLED = TSDL_RendererLogicalPresentation(0);       {*< There is no logical size in effect  }
  SDL_LOGICAL_PRESENTATION_STRETCH = TSDL_RendererLogicalPresentation(1);        {*< The rendered content is stretched to the output resolution  }
  SDL_LOGICAL_PRESENTATION_LETTERBOX = TSDL_RendererLogicalPresentation(2);      {*< The rendered content is fit to the largest dimension and the other dimension is letterboxed with the clear color  }
  SDL_LOGICAL_PRESENTATION_OVERSCAN = TSDL_RendererLogicalPresentation(3);       {*< The rendered content is fit to the smallest dimension and the other dimension extends beyond the output bounds  }
  SDL_LOGICAL_PRESENTATION_INTEGER_SCALE = TSDL_RendererLogicalPresentation(4);  {*< The rendered content is scaled up by integer multiples to fit the output resolution  }

{$ifndef SDL_INTERNAL}
{*
 * An efficient driver-specific representation of pixel data
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTexture
 * \sa SDL_CreateTextureFromSurface
 * \sa SDL_CreateTextureWithProperties
 * \sa SDL_DestroyTexture
  }
type
  PPSDL_Texture = ^PSDL_Texture;
  PSDL_Texture = ^TSDL_Texture;
  TSDL_Texture = record
      format: TSDL_PixelFormat;    {*< The format of the texture, read-only  }
      w: cint;                     {*< The width of the texture, read-only.  }
      h: cint;                     {*< The height of the texture, read-only.  }
      refcount: cint;              {*< Application reference count, used when freeing texture  }
    end;
{$endif}{ !SDL_INTERNAL  }

{*
 * A structure representing rendering state
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_Renderer = ^PSDL_Renderer;
  PSDL_Renderer = type Pointer;

{ Function prototypes  }

{*
 * Get the number of 2D rendering drivers available for the current display.
 *
 * A render driver is a set of code that handles rendering and texture
 * management on a particular display. Normally there is only one, but some
 * drivers may have several available with different capabilities.
 *
 * There may be none if SDL was compiled without render support.
 *
 * \returns the number of built in render drivers.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateRenderer
 * \sa SDL_GetRenderDriver
  }
function SDL_GetNumRenderDrivers: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumRenderDrivers' {$ENDIF} {$ENDIF};

{*
 * Use this function to get the name of a built in 2D rendering driver.
 *
 * The list of rendering drivers is given in the order that they are normally
 * initialized by default; the drivers that seem more reasonable to choose
 * first (as far as the SDL developers believe) are earlier in the list.
 *
 * The names of drivers are all simple, low-ASCII identifiers, like "opengl",
 * "direct3d12" or "metal". These never have Unicode characters, and are not
 * meant to be proper names.
 *
 * \param index the index of the rendering driver; the value ranges from 0 to
 *              SDL_GetNumRenderDrivers() - 1.
 * \returns the name of the rendering driver at the requested index, or nil
 *          if an invalid index was specified.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumRenderDrivers
  }
function SDL_GetRenderDriver(index: cint): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderDriver' {$ENDIF} {$ENDIF};

{*
 * Create a window and default renderer.
 *
 * \param title the title of the window, in UTF-8 encoding.
 * \param width the width of the window.
 * \param height the height of the window.
 * \param window_flags the flags used to create the window (see
 *                     SDL_CreateWindow()).
 * \param window a pointer filled with the window, or nil on error.
 * \param renderer a pointer filled with the renderer, or nil on error.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateRenderer
 * \sa SDL_CreateWindow
  }
function SDL_CreateWindowAndRenderer(title: PAnsiChar; width: cint; height: cint; window_flags: TSDL_WindowFlags; window: PPSDL_Window; renderer: PPSDL_Renderer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateWindowAndRenderer' {$ENDIF} {$ENDIF};

{*
 * Create a 2D rendering context for a window.
 *
 * If you want a specific renderer, you can specify its name here. A list of
 * available renderers can be obtained by calling SDL_GetRenderDriver()
 * multiple times, with indices from 0 to SDL_GetNumRenderDrivers()-1. If you
 * don't need a specific renderer, specify nil and SDL will attempt to choose
 * the best option for you, based on what is available on the user's system.
 *
 * If `name` is a comma-separated list, SDL will try each name, in the order
 * listed, until one succeeds or all of them fail.
 *
 * By default the rendering size matches the window size in pixels, but you
 * can call SDL_SetRenderLogicalPresentation() to change the content size and
 * scaling options.
 *
 * \param window the window where rendering is displayed.
 * \param name the name of the rendering driver to initialize, or nil to let
 *             SDL choose one.
 * \returns a valid rendering context or nil if there was an error; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateRendererWithProperties
 * \sa SDL_CreateSoftwareRenderer
 * \sa SDL_DestroyRenderer
 * \sa SDL_GetNumRenderDrivers
 * \sa SDL_GetRenderDriver
 * \sa SDL_GetRendererName
  }
function SDL_CreateRenderer(window: PSDL_Window; name: PAnsiChar): PSDL_Renderer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateRenderer' {$ENDIF} {$ENDIF};

{*
 * Create a 2D rendering context for a window, with the specified properties.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_RENDERER_CREATE_NAME_STRING`: the name of the rendering driver
 *   to use, if a specific one is desired
 * - `SDL_PROP_RENDERER_CREATE_WINDOW_POINTER`: the window where rendering is
 *   displayed, required if this isn't a software renderer using a surface
 * - `SDL_PROP_RENDERER_CREATE_SURFACE_POINTER`: the surface where rendering
 *   is displayed, if you want a software renderer without a window
 * - `SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER`: an SDL_ColorSpace
 *   value describing the colorspace for output to the display, defaults to
 *   SDL_COLORSPACE_SRGB. The direct3d11, direct3d12, and metal renderers
 *   support SDL_COLORSPACE_SRGB_LINEAR, which is a linear color space and
 *   supports HDR output. If you select SDL_COLORSPACE_SRGB_LINEAR, drawing
 *   still uses the sRGB colorspace, but values can go beyond 1.0 and float
 *   (linear) format textures can be used for HDR content.
 * - `SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER`: non-zero if you want
 *   present synchronized with the refresh rate. This property can take any
 *   value that is supported by SDL_SetRenderVSync() for the renderer.
 *
 * With the SDL GPU renderer (since SDL 3.4.0):
 *
 * - `SDL_PROP_RENDERER_CREATE_GPU_DEVICE_POINTER`: the device to use with the
 *   renderer, optional.
 * - `SDL_PROP_RENDERER_CREATE_GPU_SHADERS_SPIRV_BOOLEAN`: the app is able to
 *   provide SPIR-V shaders to SDL_GPURenderState, optional.
 * - `SDL_PROP_RENDERER_CREATE_GPU_SHADERS_DXIL_BOOLEAN`: the app is able to
 *   provide DXIL shaders to SDL_GPURenderState, optional.
 * - `SDL_PROP_RENDERER_CREATE_GPU_SHADERS_MSL_BOOLEAN`: the app is able to
 *   provide MSL shaders to SDL_GPURenderState, optional.
 *
 * With the vulkan renderer:
 *
 * - `SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER`: the VkInstance to use
 *   with the renderer, optional.
 * - `SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER`: the VkSurfaceKHR to use
 *   with the renderer, optional.
 * - `SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER`: the
 *   VkPhysicalDevice to use with the renderer, optional.
 * - `SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER`: the VkDevice to use
 *   with the renderer, optional.
 * - `SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER`: the
 *   queue family index used for rendering.
 * - `SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER`: the
 *   queue family index used for presentation.
 *
 * \param props the properties to use.
 * \returns a valid rendering context or nil if there was an error; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProperties
 * \sa SDL_CreateRenderer
 * \sa SDL_CreateSoftwareRenderer
 * \sa SDL_DestroyRenderer
 * \sa SDL_GetRendererName
  }
function SDL_CreateRendererWithProperties(props: TSDL_PropertiesID): PSDL_Renderer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateRendererWithProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_RENDERER_CREATE_NAME_STRING = 'SDL.renderer.create.name';
  SDL_PROP_RENDERER_CREATE_WINDOW_POINTER = 'SDL.renderer.create.window';
  SDL_PROP_RENDERER_CREATE_SURFACE_POINTER = 'SDL.renderer.create.surface';
  SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER = 'SDL.renderer.create.output_colorspace';
  SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER = 'SDL.renderer.create.present_vsync';
  SDL_PROP_RENDERER_CREATE_GPU_DEVICE_POINTER = 'SDL.renderer.create.gpu.device';
  SDL_PROP_RENDERER_CREATE_GPU_SHADERS_SPIRV_BOOLEAN = 'SDL.renderer.create.gpu.shaders_spirv';
  SDL_PROP_RENDERER_CREATE_GPU_SHADERS_DXIL_BOOLEAN = 'SDL.renderer.create.gpu.shaders_dxil';
  SDL_PROP_RENDERER_CREATE_GPU_SHADERS_MSL_BOOLEAN = 'SDL.renderer.create.gpu.shaders_msl';
  SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER = 'SDL.renderer.create.vulkan.instance';
  SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER = 'SDL.renderer.create.vulkan.surface';
  SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER = 'SDL.renderer.create.vulkan.physical_device';
  SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER = 'SDL.renderer.create.vulkan.device';
  SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER = 'SDL.renderer.create.vulkan.graphics_queue_family_index';
  SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER = 'SDL.renderer.create.vulkan.present_queue_family_index';

{*
 * Create a 2D GPU rendering context.
 *
 * The GPU device to use is passed in as a parameter. If this is nil, then a
 * device will be created normally and can be retrieved using
 * SDL_GetGPURendererDevice().
 *
 * The window to use is passed in as a parameter. If this is nil, then this
 * will become an offscreen renderer. In that case, you should call
 * SDL_SetRenderTarget() to setup rendering to a texture, and then call
 * SDL_RenderPresent() normally to complete drawing a frame.
 *
 * \param device the GPU device to use with the renderer, or nil to create a
 *               device.
 * \param window the window where rendering is displayed, or nil to create an
 *               offscreen renderer.
 * \returns a valid rendering context or nil if there was an error; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety If this function is called with a valid GPU device, it should
 *               be called on the thread that created the device. If this
 *               function is called with a valid window, it should be called
 *               on the thread that created the window.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_CreateRendererWithProperties
 * \sa SDL_GetGPURendererDevice
 * \sa SDL_CreateGPUShader
 * \sa SDL_CreateGPURenderState
 * \sa SDL_SetGPURenderState
  }
function SDL_CreateGPURenderer(device: PSDL_GPUDevice; window: PSDL_Window): PSDL_Renderer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPURenderer' {$ENDIF} {$ENDIF};

{*
 * Return the GPU device used by a renderer.
 *
 * \param renderer the rendering context.
 * \returns the GPU device used by the renderer, or nil if the renderer is
 *          not a GPU renderer; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetGPURendererDevice(renderer: PSDL_Renderer): PSDL_GPUDevice; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPURendererDevice' {$ENDIF} {$ENDIF};

{*
 * Create a 2D software rendering context for a surface.
 *
 * Two other API which can be used to create SDL_Renderer:
 * SDL_CreateRenderer() and SDL_CreateWindowAndRenderer(). These can _also_
 * create a software renderer, but they are intended to be used with an
 * SDL_Window as the final destination and not an SDL_Surface.
 *
 * \param surface the SDL_Surface structure representing the surface where
 *                rendering is done.
 * \returns a valid rendering context or nil if there was an error; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroyRenderer
  }
function SDL_CreateSoftwareRenderer(surface: PSDL_Surface): PSDL_Renderer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateSoftwareRenderer' {$ENDIF} {$ENDIF};

{*
 * Get the renderer associated with a window.
 *
 * \param window the window to query.
 * \returns the rendering context on success or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRenderer(window: PSDL_Window): PSDL_Renderer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderer' {$ENDIF} {$ENDIF};

{*
 * Get the window associated with a renderer.
 *
 * \param renderer the renderer to query.
 * \returns the window on success or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRenderWindow(renderer: PSDL_Renderer):PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderWindow' {$ENDIF} {$ENDIF};

{*
 * Get the name of a renderer.
 *
 * \param renderer the rendering context.
 * \returns the name of the selected renderer, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateRenderer
 * \sa SDL_CreateRendererWithProperties
  }
function SDL_GetRendererName(renderer: PSDL_Renderer):PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRendererName' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a renderer.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_RENDERER_NAME_STRING`: the name of the rendering driver
 * - `SDL_PROP_RENDERER_WINDOW_POINTER`: the window where rendering is
 *   displayed, if any
 * - `SDL_PROP_RENDERER_SURFACE_POINTER`: the surface where rendering is
 *   displayed, if this is a software renderer without a window
 * - `SDL_PROP_RENDERER_VSYNC_NUMBER`: the current vsync setting
 * - `SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER`: the maximum texture width
 *   and height
 * - `SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER`: a (const SDL_PixelFormat *)
 *   array of pixel formats, terminated with SDL_PIXELFORMAT_UNKNOWN,
 *   representing the available texture formats for this renderer.
 * - `SDL_PROP_RENDERER_TEXTURE_WRAPPING_BOOLEAN`: true if the renderer
 *   supports SDL_TEXTURE_ADDRESS_WRAP on non-power-of-two textures.
 * - `SDL_PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER`: an SDL_Colorspace value
 *   describing the colorspace for output to the display, defaults to
 *   SDL_COLORSPACE_SRGB.
 * - `SDL_PROP_RENDERER_HDR_ENABLED_BOOLEAN`: true if the output colorspace is
 *   SDL_COLORSPACE_SRGB_LINEAR and the renderer is showing on a display with
 *   HDR enabled. This property can change dynamically when
 *   SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
 * - `SDL_PROP_RENDERER_SDR_WHITE_POINT_FLOAT`: the value of SDR white in the
 *   SDL_COLORSPACE_SRGB_LINEAR colorspace. When HDR is enabled, this value is
 *   automatically multiplied into the color scale. This property can change
 *   dynamically when SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
 * - `SDL_PROP_RENDERER_HDR_HEADROOM_FLOAT`: the additional high dynamic range
 *   that can be displayed, in terms of the SDR white point. When HDR is not
 *   enabled, this will be 1.0. This property can change dynamically when
 *   SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
 *
 * With the direct3d renderer:
 *
 * - `SDL_PROP_RENDERER_D3D9_DEVICE_POINTER`: the IDirect3DDevice9 associated
 *   with the renderer
 *
 * With the direct3d11 renderer:
 *
 * - `SDL_PROP_RENDERER_D3D11_DEVICE_POINTER`: the ID3D11Device associated
 *   with the renderer
 * - `SDL_PROP_RENDERER_D3D11_SWAPCHAIN_POINTER`: the IDXGISwapChain1
 *   associated with the renderer. This may change when the window is resized.
 *
 * With the direct3d12 renderer:
 *
 * - `SDL_PROP_RENDERER_D3D12_DEVICE_POINTER`: the ID3D12Device associated
 *   with the renderer
 * - `SDL_PROP_RENDERER_D3D12_SWAPCHAIN_POINTER`: the IDXGISwapChain4
 *   associated with the renderer.
 * - `SDL_PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER`: the ID3D12CommandQueue
 *   associated with the renderer
 *
 * With the vulkan renderer:
 *
 * - `SDL_PROP_RENDERER_VULKAN_INSTANCE_POINTER`: the VkInstance associated
 *   with the renderer
 * - `SDL_PROP_RENDERER_VULKAN_SURFACE_NUMBER`: the VkSurfaceKHR associated
 *   with the renderer
 * - `SDL_PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER`: the VkPhysicalDevice
 *   associated with the renderer
 * - `SDL_PROP_RENDERER_VULKAN_DEVICE_POINTER`: the VkDevice associated with
 *   the renderer
 * - `SDL_PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER`: the queue
 *   family index used for rendering
 * - `SDL_PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER`: the queue
 *   family index used for presentation
 * - `SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER`: the number of
 *   swapchain images, or potential frames in flight, used by the Vulkan
 *   renderer
 *
 * With the gpu renderer:
 *
 * - `SDL_PROP_RENDERER_GPU_DEVICE_POINTER`: the SDL_GPUDevice associated with
 *   the renderer
 *
 * \param renderer the rendering context.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRendererProperties(renderer: PSDL_Renderer): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRendererProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_RENDERER_NAME_STRING = 'SDL.renderer.name';
  SDL_PROP_RENDERER_WINDOW_POINTER = 'SDL.renderer.window';
  SDL_PROP_RENDERER_SURFACE_POINTER = 'SDL.renderer.surface';
  SDL_PROP_RENDERER_VSYNC_NUMBER = 'SDL.renderer.vsync';
  SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER = 'SDL.renderer.max_texture_size';
  SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER = 'SDL.renderer.texture_formats';
  SDL_PROP_RENDERER_TEXTURE_WRAPPING_BOOLEAN = 'SDL.renderer.texture_wrapping';
  SDL_PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER = 'SDL.renderer.output_colorspace';
  SDL_PROP_RENDERER_HDR_ENABLED_BOOLEAN = 'SDL.renderer.HDR_enabled';
  SDL_PROP_RENDERER_SDR_WHITE_POINT_FLOAT = 'SDL.renderer.SDR_white_point';
  SDL_PROP_RENDERER_HDR_HEADROOM_FLOAT = 'SDL.renderer.HDR_headroom';
  SDL_PROP_RENDERER_D3D9_DEVICE_POINTER = 'SDL.renderer.d3d9.device';
  SDL_PROP_RENDERER_D3D11_DEVICE_POINTER = 'SDL.renderer.d3d11.device';
  SDL_PROP_RENDERER_D3D11_SWAPCHAIN_POINTER = 'SDL.renderer.d3d11.swap_chain';
  SDL_PROP_RENDERER_D3D12_DEVICE_POINTER = 'SDL.renderer.d3d12.device';
  SDL_PROP_RENDERER_D3D12_SWAPCHAIN_POINTER = 'SDL.renderer.d3d12.swap_chain';
  SDL_PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER = 'SDL.renderer.d3d12.command_queue';
  SDL_PROP_RENDERER_VULKAN_INSTANCE_POINTER = 'SDL.renderer.vulkan.instance';
  SDL_PROP_RENDERER_VULKAN_SURFACE_NUMBER = 'SDL.renderer.vulkan.surface';
  SDL_PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER = 'SDL.renderer.vulkan.physical_device';
  SDL_PROP_RENDERER_VULKAN_DEVICE_POINTER = 'SDL.renderer.vulkan.device';
  SDL_PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER = 'SDL.renderer.vulkan.graphics_queue_family_index';
  SDL_PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER = 'SDL.renderer.vulkan.present_queue_family_index';
  SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER = 'SDL.renderer.vulkan.swapchain_image_count';
  SDL_PROP_RENDERER_GPU_DEVICE_POINTER = 'SDL.renderer.gpu.device';

{*
 * Get the output size in pixels of a rendering context.
 *
 * This returns the true output size in pixels, ignoring any render targets or
 * logical size and presentation.
 *
 * For the output size of the current rendering target, with logical size
 * adjustments, use SDL_GetCurrentRenderOutputSize() instead.
 *
 * \param renderer the rendering context.
 * \param w a pointer filled in with the width in pixels.
 * \param h a pointer filled in with the height in pixels.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCurrentRenderOutputSize
  }
function SDL_GetRenderOutputSize(renderer: PSDL_Renderer; w: pcint; h: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderOutputSize' {$ENDIF} {$ENDIF};

{*
 * Get the current output size in pixels of a rendering context.
 *
 * If a rendering target is active, this will return the size of the rendering
 * target in pixels, otherwise return the value of SDL_GetRenderOutputSize().
 *
 * Rendering target or not, the output will be adjusted by the current logical
 * presentation state, dictated by SDL_SetRenderLogicalPresentation().
 *
 * \param renderer the rendering context.
 * \param w a pointer filled in with the current width.
 * \param h a pointer filled in with the current height.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderOutputSize
  }
function SDL_GetCurrentRenderOutputSize(renderer: PSDL_Renderer; w: pcint; h: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentRenderOutputSize' {$ENDIF} {$ENDIF};

{*
  * Create a texture for a rendering context.
  *
  * The contents of a texture when first created are not defined.
  *
  * \param renderer the rendering context.
  * \param format one of the enumerated values in SDL_PixelFormat.
  * \param access one of the enumerated values in SDL_TextureAccess.
  * \param w the width of the texture in pixels.
  * \param h the height of the texture in pixels.
  * \returns the created texture or NULL on failure; call SDL_GetError() for
  *          more information.

  *
  * \threadsafety This function should only be called on the main thread.
  *
  * \since This function is available since SDL 3.2.0.
  *
  * \sa SDL_CreateTextureFromSurface
  * \sa SDL_CreateTextureWithProperties
  * \sa SDL_DestroyTexture
  * \sa SDL_GetTextureSize
  * \sa SDL_UpdateTexture
  }
function SDL_CreateTexture(renderer: PSDL_Renderer; format: TSDL_PixelFormat; access: TSDL_TextureAccess; w: cint; h: cint):PSDL_Texture; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateTexture' {$ENDIF} {$ENDIF};

{*
 * Create a texture from an existing surface.
 *
 * The surface is not modified or freed by this function.
 *
 * The SDL_TextureAccess hint for the created texture is
 * `SDL_TEXTUREACCESS_STATIC`.
 *
 * The pixel format of the created texture may be different from the pixel
 * format of the surface, and can be queried using the
 * SDL_PROP_TEXTURE_FORMAT_NUMBER property.
 *
 * \param renderer the rendering context.
 * \param surface the SDL_Surface structure containing pixel data used to fill
 *                the texture.
 * \returns the created texture or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTexture
 * \sa SDL_CreateTextureWithProperties
 * \sa SDL_DestroyTexture
  }
function SDL_CreateTextureFromSurface(renderer: PSDL_Renderer; surface: PSDL_Surface):PSDL_Texture; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateTextureFromSurface' {$ENDIF} {$ENDIF};

{*
 * Create a texture for a rendering context with the specified properties.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_TEXTURE_CREATE_COLORSPACE_NUMBER`: an SDL_Colorspace value
 *   describing the texture colorspace, defaults to SDL_COLORSPACE_SRGB_LINEAR
 *   for floating point textures, SDL_COLORSPACE_HDR10 for 10-bit textures,
 *   SDL_COLORSPACE_SRGB for other RGB textures and SDL_COLORSPACE_JPEG for
 *   YUV textures.
 * - `SDL_PROP_TEXTURE_CREATE_FORMAT_NUMBER`: one of the enumerated values in
 *   SDL_PixelFormat, defaults to the best RGBA format for the renderer
 * - `SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER`: one of the enumerated values in
 *   SDL_TextureAccess, defaults to SDL_TEXTUREACCESS_STATIC
 * - `SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER`: the width of the texture in
 *   pixels, required
 * - `SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER`: the height of the texture in
 *   pixels, required
 * - `SDL_PROP_TEXTURE_CREATE_PALETTE_POINTER`: an SDL_Palette to use with
 *   palettized texture formats. This can be set later with
 *   SDL_SetTexturePalette()
 * - `SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT`: for HDR10 and floating
 *   point textures, this defines the value of 100% diffuse white, with higher
 *   values being displayed in the High Dynamic Range headroom. This defaults
 *   to 100 for HDR10 textures and 1.0 for floating point textures.
 * - `SDL_PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT`: for HDR10 and floating
 *   point textures, this defines the maximum dynamic range used by the
 *   content, in terms of the SDR white point. This would be equivalent to
 *   maxCLL / SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT for HDR10 content.
 *   If this is defined, any values outside the range supported by the display
 *   will be scaled into the available HDR headroom, otherwise they are
 *   clipped.
 *
 * With the direct3d11 renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER`: the ID3D11Texture2D
 *   associated with the texture, if you want to wrap an existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER`: the ID3D11Texture2D
 *   associated with the U plane of a YUV texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER`: the ID3D11Texture2D
 *   associated with the V plane of a YUV texture, if you want to wrap an
 *   existing texture.
 *
 * With the direct3d12 renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER`: the ID3D12Resource
 *   associated with the texture, if you want to wrap an existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER`: the ID3D12Resource
 *   associated with the U plane of a YUV texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER`: the ID3D12Resource
 *   associated with the V plane of a YUV texture, if you want to wrap an
 *   existing texture.
 *
 * With the metal renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER`: the CVPixelBufferRef
 *   associated with the texture, if you want to create a texture from an
 *   existing pixel buffer.
 *
 * With the opengl renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER`: the GLuint texture
 *   associated with the texture, if you want to wrap an existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER`: the GLuint texture
 *   associated with the UV plane of an NV12 texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER`: the GLuint texture
 *   associated with the U plane of a YUV texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER`: the GLuint texture
 *   associated with the V plane of a YUV texture, if you want to wrap an
 *   existing texture.
 *
 * With the opengles2 renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER`: the GLuint texture
 *   associated with the texture, if you want to wrap an existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_UV_NUMBER`: the GLuint texture
 *   associated with the UV plane of an NV12 texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_U_NUMBER`: the GLuint texture
 *   associated with the U plane of a YUV texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_V_NUMBER`: the GLuint texture
 *   associated with the V plane of a YUV texture, if you want to wrap an
 *   existing texture.
 *
 * With the vulkan renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER`: the VkImage associated
 *   with the texture, if you want to wrap an existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_VULKAN_LAYOUT_NUMBER`: the VkImageLayout for the
 *   VkImage, defaults to VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL.
 *
 * With the GPU renderer:
 *
 * - `SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_POINTER`: the SDL_GPUTexture
 *   associated with the texture, if you want to wrap an existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_UV_NUMBER`: the SDL_GPUTexture
 *   associated with the UV plane of an NV12 texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_U_NUMBER`: the SDL_GPUTexture
 *   associated with the U plane of a YUV texture, if you want to wrap an
 *   existing texture.
 * - `SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_V_NUMBER`: the SDL_GPUTexture
 *   associated with the V plane of a YUV texture, if you want to wrap an
 *   existing texture.
 *
 * \param renderer the rendering context.
 * \param props the properties to use.
 * \returns the created texture or NULL on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProperties
 * \sa SDL_CreateTexture
 * \sa SDL_CreateTextureFromSurface
 * \sa SDL_DestroyTexture
 * \sa SDL_GetTextureSize
 * \sa SDL_UpdateTexture
  }
function SDL_CreateTextureWithProperties(renderer: PSDL_Renderer; props: TSDL_PropertiesID):PSDL_Texture; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateTextureWithProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_TEXTURE_CREATE_COLORSPACE_NUMBER = 'SDL.texture.create.colorspace';
  SDL_PROP_TEXTURE_CREATE_FORMAT_NUMBER = 'SDL.texture.create.format';
  SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER = 'SDL.texture.create.access';
  SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER = 'SDL.texture.create.width';
  SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER = 'SDL.texture.create.height';
  SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT = 'SDL.texture.create.SDR_white_point';
  SDL_PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT = 'SDL.texture.create.HDR_headroom';
  SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER = 'SDL.texture.create.d3d11.texture';
  SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER = 'SDL.texture.create.d3d11.texture_u';
  SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER = 'SDL.texture.create.d3d11.texture_v';
  SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER = 'SDL.texture.create.d3d12.texture';
  SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER = 'SDL.texture.create.d3d12.texture_u';
  SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER = 'SDL.texture.create.d3d12.texture_v';
  SDL_PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER = 'SDL.texture.create.metal.pixelbuffer';
  SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER = 'SDL.texture.create.opengl.texture';
  SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER = 'SDL.texture.create.opengl.texture_uv';
  SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER = 'SDL.texture.create.opengl.texture_u';
  SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER = 'SDL.texture.create.opengl.texture_v';
  SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER = 'SDL.texture.create.opengles2.texture';
  SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_UV_NUMBER = 'SDL.texture.create.opengles2.texture_uv';
  SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_U_NUMBER = 'SDL.texture.create.opengles2.texture_u';
  SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_V_NUMBER = 'SDL.texture.create.opengles2.texture_v';
  SDL_PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER = 'SDL.texture.create.vulkan.texture';
  SDL_PROP_TEXTURE_CREATE_VULKAN_LAYOUT_NUMBER = 'SDL.texture.create.vulkan.layout';
  SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_POINTER = 'SDL.texture.create.gpu.texture';
  SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_UV_POINTER = 'SDL.texture.create.gpu.texture_uv';
  SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_U_POINTER = 'SDL.texture.create.gpu.texture_u';
  SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_V_POINTER = 'SDL.texture.create.gpu.texture_v';

{*
 * Get the properties associated with a texture.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_TEXTURE_COLORSPACE_NUMBER`: an SDL_Colorspace value describing
 *   the texture colorspace.
 * - `SDL_PROP_TEXTURE_FORMAT_NUMBER`: one of the enumerated values in
 *   SDL_PixelFormat.
 * - `SDL_PROP_TEXTURE_ACCESS_NUMBER`: one of the enumerated values in
 *   SDL_TextureAccess.
 * - `SDL_PROP_TEXTURE_WIDTH_NUMBER`: the width of the texture in pixels.
 * - `SDL_PROP_TEXTURE_HEIGHT_NUMBER`: the height of the texture in pixels.
 * - `SDL_PROP_TEXTURE_SDR_WHITE_POINT_FLOAT`: for HDR10 and floating point
 *   textures, this defines the value of 100% diffuse white, with higher
 *   values being displayed in the High Dynamic Range headroom. This defaults
 *   to 100 for HDR10 textures and 1.0 for other textures.
 * - `SDL_PROP_TEXTURE_HDR_HEADROOM_FLOAT`: for HDR10 and floating point
 *   textures, this defines the maximum dynamic range used by the content, in
 *   terms of the SDR white point. If this is defined, any values outside the
 *   range supported by the display will be scaled into the available HDR
 *   headroom, otherwise they are clipped. This defaults to 1.0 for SDR
 *   textures, 4.0 for HDR10 textures, and no default for floating point
 *   textures.
 *
 * With the direct3d11 renderer:
 *
 * - `SDL_PROP_TEXTURE_D3D11_TEXTURE_POINTER`: the ID3D11Texture2D associated
 *   with the texture
 * - `SDL_PROP_TEXTURE_D3D11_TEXTURE_U_POINTER`: the ID3D11Texture2D
 *   associated with the U plane of a YUV texture
 * - `SDL_PROP_TEXTURE_D3D11_TEXTURE_V_POINTER`: the ID3D11Texture2D
 *   associated with the V plane of a YUV texture
 *
 * With the direct3d12 renderer:
 *
 * - `SDL_PROP_TEXTURE_D3D12_TEXTURE_POINTER`: the ID3D12Resource associated
 *   with the texture
 * - `SDL_PROP_TEXTURE_D3D12_TEXTURE_U_POINTER`: the ID3D12Resource associated
 *   with the U plane of a YUV texture
 * - `SDL_PROP_TEXTURE_D3D12_TEXTURE_V_POINTER`: the ID3D12Resource associated
 *   with the V plane of a YUV texture
 *
 * With the vulkan renderer:
 *
 * - `SDL_PROP_TEXTURE_VULKAN_TEXTURE_POINTER`: the VkImage associated with
 *   the texture
 *
 * With the opengl renderer:
 *
 * - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_NUMBER`: the GLuint texture associated
 *   with the texture
 * - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_UV_NUMBER`: the GLuint texture
 *   associated with the UV plane of an NV12 texture
 * - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_U_NUMBER`: the GLuint texture associated
 *   with the U plane of a YUV texture
 * - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_V_NUMBER`: the GLuint texture associated
 *   with the V plane of a YUV texture
 * - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_TARGET_NUMBER`: the GLenum for the
 *   texture target (`GL_TEXTURE_2D`, `GL_TEXTURE_RECTANGLE_ARB`, etc)
 * - `SDL_PROP_TEXTURE_OPENGL_TEX_W_FLOAT`: the texture coordinate width of
 *   the texture (0.0 - 1.0)
 * - `SDL_PROP_TEXTURE_OPENGL_TEX_H_FLOAT`: the texture coordinate height of
 *   the texture (0.0 - 1.0)
 *
 * With the opengles2 renderer:
 *
 * - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_NUMBER`: the GLuint texture
 *   associated with the texture
 * - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_UV_NUMBER`: the GLuint texture
 *   associated with the UV plane of an NV12 texture
 * - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_U_NUMBER`: the GLuint texture
 *   associated with the U plane of a YUV texture
 * - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_V_NUMBER`: the GLuint texture
 *   associated with the V plane of a YUV texture
 * - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_TARGET_NUMBER`: the GLenum for the
 *   texture target (`GL_TEXTURE_2D`, `GL_TEXTURE_EXTERNAL_OES`, etc)
 *
 * With the gpu renderer:
 *
 * - `SDL_PROP_TEXTURE_GPU_TEXTURE_POINTER`: the SDL_GPUTexture associated
 *   with the texture
 * - `SDL_PROP_TEXTURE_GPU_TEXTURE_UV_POINTER`: the SDL_GPUTexture associated
 *   with the UV plane of an NV12 texture
 * - `SDL_PROP_TEXTURE_GPU_TEXTURE_U_POINTER`: the SDL_GPUTexture associated
 *   with the U plane of a YUV texture
 * - `SDL_PROP_TEXTURE_GPU_TEXTURE_V_POINTER`: the SDL_GPUTexture associated
 *   with the V plane of a YUV texture
 *
 * \param texture the texture to query.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }

function SDL_GetTextureProperties(texture: PSDL_Texture): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_TEXTURE_COLORSPACE_NUMBER = 'SDL.texture.colorspace';
  SDL_PROP_TEXTURE_FORMAT_NUMBER = 'SDL.texture.format';
  SDL_PROP_TEXTURE_ACCESS_NUMBER = 'SDL.texture.access';
  SDL_PROP_TEXTURE_WIDTH_NUMBER = 'SDL.texture.width';
  SDL_PROP_TEXTURE_HEIGHT_NUMBER = 'SDL.texture.height';
  SDL_PROP_TEXTURE_SDR_WHITE_POINT_FLOAT = 'SDL.texture.SDR_white_point';
  SDL_PROP_TEXTURE_HDR_HEADROOM_FLOAT = 'SDL.texture.HDR_headroom';
  SDL_PROP_TEXTURE_D3D11_TEXTURE_POINTER = 'SDL.texture.d3d11.texture';
  SDL_PROP_TEXTURE_D3D11_TEXTURE_U_POINTER = 'SDL.texture.d3d11.texture_u';
  SDL_PROP_TEXTURE_D3D11_TEXTURE_V_POINTER = 'SDL.texture.d3d11.texture_v';
  SDL_PROP_TEXTURE_D3D12_TEXTURE_POINTER = 'SDL.texture.d3d12.texture';
  SDL_PROP_TEXTURE_D3D12_TEXTURE_U_POINTER = 'SDL.texture.d3d12.texture_u';
  SDL_PROP_TEXTURE_D3D12_TEXTURE_V_POINTER = 'SDL.texture.d3d12.texture_v';
  SDL_PROP_TEXTURE_OPENGL_TEXTURE_NUMBER = 'SDL.texture.opengl.texture';
  SDL_PROP_TEXTURE_OPENGL_TEXTURE_UV_NUMBER = 'SDL.texture.opengl.texture_uv';
  SDL_PROP_TEXTURE_OPENGL_TEXTURE_U_NUMBER = 'SDL.texture.opengl.texture_u';
  SDL_PROP_TEXTURE_OPENGL_TEXTURE_V_NUMBER = 'SDL.texture.opengl.texture_v';
  SDL_PROP_TEXTURE_OPENGL_TEXTURE_TARGET_NUMBER = 'SDL.texture.opengl.target';
  SDL_PROP_TEXTURE_OPENGL_TEX_W_FLOAT = 'SDL.texture.opengl.tex_w';
  SDL_PROP_TEXTURE_OPENGL_TEX_H_FLOAT = 'SDL.texture.opengl.tex_h';
  SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_NUMBER = 'SDL.texture.opengles2.texture';
  SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_UV_NUMBER = 'SDL.texture.opengles2.texture_uv';
  SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_U_NUMBER = 'SDL.texture.opengles2.texture_u';
  SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_V_NUMBER = 'SDL.texture.opengles2.texture_v';
  SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_TARGET_NUMBER = 'SDL.texture.opengles2.target';
  SDL_PROP_TEXTURE_VULKAN_TEXTURE_NUMBER = 'SDL.texture.vulkan.texture';
  SDL_PROP_TEXTURE_GPU_TEXTURE_POINTER = 'SDL.texture.gpu.texture';
  SDL_PROP_TEXTURE_GPU_TEXTURE_UV_POINTER = 'SDL.texture.gpu.texture_uv';
  SDL_PROP_TEXTURE_GPU_TEXTURE_U_POINTER = 'SDL.texture.gpu.texture_u';
  SDL_PROP_TEXTURE_GPU_TEXTURE_V_POINTER = 'SDL.texture.gpu.texture_v';

{*
 * Get the renderer that created an SDL_Texture.
 *
 * \param texture the texture to query.
 * \returns a pointer to the SDL_Renderer that created the texture, or nil on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }

function SDL_GetRendererFromTexture(texture: PSDL_Texture): PSDL_Renderer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRendererFromTexture' {$ENDIF} {$ENDIF};

{*
 * Get the size of a texture, as floating point values.
 *
 * \param texture the texture to query.
 * \param w a pointer filled in with the width of the texture in pixels. This
 *          argument can be nil if you don't need this information.
 * \param h a pointer filled in with the height of the texture in pixels. This
 *          argument can be nil if you don't need this information.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetTextureSize(texture: PSDL_Texture; w: pcfloat; h: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureSize' {$ENDIF} {$ENDIF};

{*
 * Set the palette used by a texture.
 *
 * Setting the palette keeps an internal reference to the palette, which can
 * be safely destroyed afterwards.
 *
 * A single palette can be shared with many textures.
 *
 * \param texture the texture to update.
 * \param palette the SDL_Palette structure to use.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_CreatePalette
 * \sa SDL_GetTexturePalette
  }
function SDL_SetTexturePalette(texture: PSDL_Texture; palette: PSDL_Palette): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTexturePalette' {$ENDIF} {$ENDIF};

{*
 * Get the palette used by a texture.
 *
 * \param texture the texture to query.
 * \returns a Pointer to the palette used by the texture, or nil if there is
 *          no palette used.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_SetTexturePalette
  }
function SDL_GetTexturePalette(texture: PSDL_Texture): PSDL_Palette; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTexturePalette' {$ENDIF} {$ENDIF};

{*
 * Set an additional color value multiplied into render copy operations.
 *
 * When this texture is rendered, during the copy operation each source color
 * channel is modulated by the appropriate color value according to the
 * following formula:
 *
 * `srcC = srcC * (color / 255)`
 *
 * Color modulation is not always supported by the renderer; it will return
 * false if color modulation is not supported.
 *
 * \param texture the texture to update.
 * \param r the red color value multiplied into copy operations.
 * \param g the green color value multiplied into copy operations.
 * \param b the blue color value multiplied into copy operations.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureColorMod
 * \sa SDL_SetTextureAlphaMod
 * \sa SDL_SetTextureColorModFloat
  }
function SDL_SetTextureColorMod(texture: PSDL_Texture; r: cuint8; g: cuint8; b: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextureColorMod' {$ENDIF} {$ENDIF};

{*
 * Set an additional color value multiplied into render copy operations.
 *
 * When this texture is rendered, during the copy operation each source color
 * channel is modulated by the appropriate color value according to the
 * following formula:
 *
 * `srcC = srcC * color`
 *
 * Color modulation is not always supported by the renderer; it will return
 * false if color modulation is not supported.
 *
 * \param texture the texture to update.
 * \param r the red color value multiplied into copy operations.
 * \param g the green color value multiplied into copy operations.
 * \param b the blue color value multiplied into copy operations.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureColorModFloat
 * \sa SDL_SetTextureAlphaModFloat
 * \sa SDL_SetTextureColorMod
  }
function SDL_SetTextureColorModFloat(texture: PSDL_Texture; r: cfloat; g: cfloat; b: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextureColorModFloat' {$ENDIF} {$ENDIF};

{*
 * Get the additional color value multiplied into render copy operations.
 *
 * \param texture the texture to query.
 * \param r a pointer filled in with the current red color value.
 * \param g a pointer filled in with the current green color value.
 * \param b a pointer filled in with the current blue color value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureAlphaMod
 * \sa SDL_GetTextureColorModFloat
 * \sa SDL_SetTextureColorMod
  }
function SDL_GetTextureColorMod(texture: PSDL_Texture; r: pcuint8; g: pcuint8; b: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureColorMod' {$ENDIF} {$ENDIF};

{*
 * Get the additional color value multiplied into render copy operations.
 *
 * \param texture the texture to query.
 * \param r a pointer filled in with the current red color value.
 * \param g a pointer filled in with the current green color value.
 * \param b a pointer filled in with the current blue color value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureAlphaModFloat
 * \sa SDL_GetTextureColorMod
 * \sa SDL_SetTextureColorModFloat
  }
function SDL_GetTextureColorModFloat(texture: PSDL_Texture; r: pcfloat; g: pcfloat; b: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureColorModFloat' {$ENDIF} {$ENDIF};

{*
 * Set an additional alpha value multiplied into render copy operations.
 *
 * When this texture is rendered, during the copy operation the source alpha
 * value is modulated by this alpha value according to the following formula:
 *
 * `srcA = srcA * (alpha / 255)`
 *
 * Alpha modulation is not always supported by the renderer; it will return
 * false if alpha modulation is not supported.
 *
 * \param texture the texture to update.
 * \param alpha the source alpha value multiplied into copy operations.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureAlphaMod
 * \sa SDL_SetTextureAlphaModFloat
 * \sa SDL_SetTextureColorMod
  }
function SDL_SetTextureAlphaMod(texture: PSDL_Texture; alpha: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextureAlphaMod' {$ENDIF} {$ENDIF};

{*
 * Set an additional alpha value multiplied into render copy operations.
 *
 * When this texture is rendered, during the copy operation the source alpha
 * value is modulated by this alpha value according to the following formula:
 *
 * `srcA = srcA * alpha`
 *
 * Alpha modulation is not always supported by the renderer; it will return
 * false if alpha modulation is not supported.
 *
 * \param texture the texture to update.
 * \param alpha the source alpha value multiplied into copy operations.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureAlphaModFloat
 * \sa SDL_SetTextureAlphaMod
 * \sa SDL_SetTextureColorModFloat
  }
function SDL_SetTextureAlphaModFloat(texture: PSDL_Texture; alpha: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextureAlphaModFloat' {$ENDIF} {$ENDIF};

{*
 * Get the additional alpha value multiplied into render copy operations.
 *
 * \param texture the texture to query.
 * \param alpha a pointer filled in with the current alpha value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureAlphaModFloat
 * \sa SDL_GetTextureColorMod
 * \sa SDL_SetTextureAlphaMod
  }
function SDL_GetTextureAlphaMod(texture: PSDL_Texture; alpha: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureAlphaMod' {$ENDIF} {$ENDIF};

{*
 * Get the additional alpha value multiplied into render copy operations.
 *
 * \param texture the texture to query.
 * \param alpha a pointer filled in with the current alpha value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureAlphaMod
 * \sa SDL_GetTextureColorModFloat
 * \sa SDL_SetTextureAlphaModFloat
  }
function SDL_GetTextureAlphaModFloat(texture: PSDL_Texture; alpha: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureAlphaModFloat' {$ENDIF} {$ENDIF};

{*
 * Set the blend mode for a texture, used by SDL_RenderTexture().
 *
 * If the blend mode is not supported, the closest supported mode is chosen
 * and this function returns false.
 *
 * \param texture the texture to update.
 * \param blendMode the SDL_BlendMode to use for texture blending.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureBlendMode
  }
function SDL_SetTextureBlendMode(texture: PSDL_Texture; blendMode: TSDL_BlendMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextureBlendMode' {$ENDIF} {$ENDIF};

{*
 * Get the blend mode used for texture copy operations.
 *
 * \param texture the texture to query.
 * \param blendMode a pointer filled in with the current SDL_BlendMode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetTextureBlendMode
  }
function SDL_GetTextureBlendMode(texture: PSDL_Texture; blendMode: PSDL_BlendMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureBlendMode' {$ENDIF} {$ENDIF};

{*
 * Set the scale mode used for texture scale operations.
 *
 * The default texture scale mode is SDL_SCALEMODE_LINEAR.
 *
 * If the scale mode is not supported, the closest supported mode is chosen.
 *
 * \param texture the texture to update.
 * \param scaleMode the SDL_ScaleMode to use for texture scaling.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextureScaleMode
  }
function SDL_SetTextureScaleMode(texture: PSDL_Texture; scaleMode: TSDL_ScaleMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextureScaleMode' {$ENDIF} {$ENDIF};

{*
 * Get the scale mode used for texture scale operations.
 *
 * \param texture the texture to query.
 * \param scaleMode a pointer filled in with the current scale mode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetTextureScaleMode
  }
function SDL_GetTextureScaleMode(texture: PSDL_Texture; scaleMode: PSDL_ScaleMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextureScaleMode' {$ENDIF} {$ENDIF};

{*
 * Update the given texture rectangle with new pixel data.
 *
 * The pixel data must be in the pixel format of the texture, which can be
 * queried using the SDL_PROP_TEXTURE_FORMAT_NUMBER property.
 *
 * This is a fairly slow function, intended for use with static textures that
 * do not change often.
 *
 * If the texture is intended to be updated often, it is preferred to create
 * the texture as streaming and use the locking functions referenced below.
 * While this function will work with streaming textures, for optimization
 * reasons you may not get the pixels back if you lock the texture afterward.
 *
 * \param texture the texture to update.
 * \param rect an SDL_Rect structure representing the area to update, or nil
 *             to update the entire texture.
 * \param pixels the raw pixel data in the format of the texture.
 * \param pitch the number of bytes in a row of pixel data, including padding
 *              between lines.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LockTexture
 * \sa SDL_UnlockTexture
 * \sa SDL_UpdateNVTexture
 * \sa SDL_UpdateYUVTexture
  }
function SDL_UpdateTexture(texture: PSDL_Texture; rect: PSDL_Rect; pixels: pointer; pitch: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateTexture' {$ENDIF} {$ENDIF};

{*
 * Update a rectangle within a planar YV12 or IYUV texture with new pixel
 * data.
 *
 * You can use SDL_UpdateTexture() as long as your pixel data is a contiguous
 * block of Y and U/V planes in the proper order, but this function is
 * available if your pixel data is not contiguous.
 *
 * \param texture the texture to update.
 * \param rect a pointer to the rectangle of pixels to update, or nil to
 *             update the entire texture.
 * \param Yplane the raw pixel data for the Y plane.
 * \param Ypitch the number of bytes between rows of pixel data for the Y
 *               plane.
 * \param Uplane the raw pixel data for the U plane.
 * \param Upitch the number of bytes between rows of pixel data for the U
 *               plane.
 * \param Vplane the raw pixel data for the V plane.
 * \param Vpitch the number of bytes between rows of pixel data for the V
 *               plane.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UpdateNVTexture
 * \sa SDL_UpdateTexture
  }
function SDL_UpdateYUVTexture(texture: PSDL_Texture; rect: PSDL_Rect;
           Yplane: pcuint8; Ypitch: cint;
           Uplane: pcuint8; Upitch: cint;
           Vplane: pcuint8; Vpitch: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateYUVTexture' {$ENDIF} {$ENDIF};

{*
 * Update a rectangle within a planar NV12 or NV21 texture with new pixels.
 *
 * You can use SDL_UpdateTexture() as long as your pixel data is a contiguous
 * block of NV12/21 planes in the proper order, but this function is available
 * if your pixel data is not contiguous.
 *
 * \param texture the texture to update.
 * \param rect a pointer to the rectangle of pixels to update, or nil to
 *             update the entire texture.
 * \param Yplane the raw pixel data for the Y plane.
 * \param Ypitch the number of bytes between rows of pixel data for the Y
 *               plane.
 * \param UVplane the raw pixel data for the UV plane.
 * \param UVpitch the number of bytes between rows of pixel data for the UV
 *                plane.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UpdateTexture
 * \sa SDL_UpdateYUVTexture
  }
function SDL_UpdateNVTexture(texture: PSDL_Texture; rect: PSDL_Rect;
           Yplane: pcuint8; Ypitch: cint;
           UVplane: pcuint8; UVpitch: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateNVTexture' {$ENDIF} {$ENDIF};

{*
 * Lock a portion of the texture for **write-only** pixel access.
 *
 * As an optimization, the pixels made available for editing don't necessarily
 * contain the old texture data. This is a write-only operation, and if you
 * need to keep a copy of the texture data you should do that at the
 * application level.
 *
 * You must use SDL_UnlockTexture() to unlock the pixels and apply any
 * changes.
 *
 * \param texture the texture to lock for access, which was created with
 *                `SDL_TEXTUREACCESS_STREAMING`.
 * \param rect an SDL_Rect structure representing the area to lock for access;
 *             nil to lock the entire texture.
 * \param pixels this is filled in with a pointer to the locked pixels,
 *               appropriately offset by the locked area.
 * \param pitch this is filled in with the pitch of the locked pixels; the
 *              pitch is the length of one row in bytes.
 * \returns true on success or false if the texture is not valid or was not
 *          created with `SDL_TEXTUREACCESS_STREAMING`; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LockTextureToSurface
 * \sa SDL_UnlockTexture
  }
function SDL_LockTexture(texture: PSDL_Texture; rect: PSDL_Rect; pixels: PPointer; pitch: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LockTexture' {$ENDIF} {$ENDIF};

{*
 * Lock a portion of the texture for **write-only** pixel access, and expose
 * it as a SDL surface.
 *
 * Besides providing an SDL_Surface instead of raw pixel data, this function
 * operates like SDL_LockTexture.
 *
 * As an optimization, the pixels made available for editing don't necessarily
 * contain the old texture data. This is a write-only operation, and if you
 * need to keep a copy of the texture data you should do that at the
 * application level.
 *
 * You must use SDL_UnlockTexture() to unlock the pixels and apply any
 * changes.
 *
 * The returned surface is freed internally after calling SDL_UnlockTexture()
 * or SDL_DestroyTexture(). The caller should not free it.
 *
 * \param texture the texture to lock for access, which must be created with
 *                `SDL_TEXTUREACCESS_STREAMING`.
 * \param rect a pointer to the rectangle to lock for access. If the rect is
 *             nil, the entire texture will be locked.
 * \param surface a pointer to an SDL surface of size **rect**. Don't assume
 *                any specific pixel content.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LockTexture
 * \sa SDL_UnlockTexture
  }
function SDL_LockTextureToSurface(texture: PSDL_Texture; rect: PSDL_Rect; surface: PPSDL_Surface): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LockTextureToSurface' {$ENDIF} {$ENDIF};

{*
 * Unlock a texture, uploading the changes to video memory, if needed.
 *
 * **Warning**: Please note that SDL_LockTexture() is intended to be
 * write-only; it will not guarantee the previous contents of the texture will
 * be provided. You must fully initialize any area of a texture that you lock
 * before unlocking it, as the pixels might otherwise be uninitialized memory.
 *
 * Which is to say: locking and immediately unlocking a texture can result in
 * corrupted textures, depending on the renderer in use.
 *
 * \param texture a texture locked by SDL_LockTexture().
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LockTexture
  }
procedure SDL_UnlockTexture(texture: PSDL_Texture); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UnlockTexture' {$ENDIF} {$ENDIF};

{*
 * Set a texture as the current rendering target.
 *
 * The default render target is the window for which the renderer was created.
 * To stop rendering to a texture and render to the window again, call this
 * function with a nil `texture`.
 *
 * Viewport, cliprect, scale, and logical presentation are unique to each
 * render target. Get and set functions for these states apply to the current
 * render target set by this function, and those states persist on each target
 * when the current render target changes.
 *
 * \param renderer the rendering context.
 * \param texture the targeted texture, which must be created with the
 *                `SDL_TEXTUREACCESS_TARGET` flag, or nil to render to the
 *                window instead of a texture.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderTarget
  }
function SDL_SetRenderTarget(renderer: PSDL_Renderer; texture: PSDL_Texture): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderTarget' {$ENDIF} {$ENDIF};

{*
 * Get the current render target.
 *
 * The default render target is the window for which the renderer was created,
 * and is reported a nil here.
 *
 * \param renderer the rendering context.
 * \returns the current render target or nil for the default render target.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderTarget
  }
function SDL_GetRenderTarget(renderer: PSDL_Renderer): PSDL_Texture; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderTarget' {$ENDIF} {$ENDIF};

{*
* Set a device-independent resolution and presentation mode for rendering.
*
* This function sets the width and height of the logical rendering output.
* The renderer will act as if the current render target is always the
* requested dimensions, scaling to the actual resolution as necessary.
*
* This can be useful for games that expect a fixed size, but would like to
* scale the output to whatever is available, regardless of how a user resizes
* a window, or if the display is high DPI.
*
* Logical presentation can be used with both render target textures and the
* renderer's window; the state is unique to each render target, and this
* function sets the state for the current render target. It might be useful
* to draw to a texture that matches the window dimensions with logical
* presentation enabled, and then draw that texture across the entire window
* with logical presentation disabled. Be careful not to render both with
* logical presentation enabled, however, as this could produce
* double-letterboxing, etc.
*
* You can disable logical coordinates by setting the mode to
* SDL_LOGICAL_PRESENTATION_DISABLED, and in that case you get the full pixel
* resolution of the render target; it is safe to toggle logical presentation
* during the rendering of a frame: perhaps most of the rendering is done to
* specific dimensions but to make fonts look sharp, the app turns off logical
* presentation while drawing text, for example.
 *
 * You can convert coordinates in an event into rendering coordinates using
 * SDL_ConvertEventToRenderCoordinates().
 *
 * \param renderer the rendering context.
 * \param w the width of the logical resolution.
 * \param h the height of the logical resolution.
 * \param mode the presentation mode used.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ConvertEventToRenderCoordinates
 * \sa SDL_GetRenderLogicalPresentation
 * \sa SDL_GetRenderLogicalPresentationRect
  }
function SDL_SetRenderLogicalPresentation(renderer: PSDL_Renderer; w: cint; h: cint; mode: TSDL_RendererLogicalPresentation): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderLogicalPresentation' {$ENDIF} {$ENDIF};

{*
* Get device independent resolution and presentation mode for rendering.
*
* This function gets the width and height of the logical rendering output, or
* 0 if a logical resolution is not enabled.
*
* Each render target has its own logical presentation state. This function
* gets the state for the current render target.
*
* \param renderer the rendering context.
* \param w an int filled with the logical presentation width.
* \param h an int filled with the logical presentation height.
* \param mode a variable filled with the logical presentation mode being
*             used.
* \returns true on success or false on failure; call SDL_GetError() for more
*          information.
*
* \threadsafety This function should only be called on the main thread.
*
* \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderLogicalPresentation
  }
function SDL_GetRenderLogicalPresentation(renderer: PSDL_Renderer; w: pcint; h: pcint; mode: PSDL_RendererLogicalPresentation): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderLogicalPresentation' {$ENDIF} {$ENDIF};

{*
 * Get the final presentation rectangle for rendering.
 *
 * This function returns the calculated rectangle used for logical
 * presentation, based on the presentation mode and output size. If logical
 * presentation is disabled, it will fill the rectangle with the output size,
 * in pixels.
 *
 * Each render target has its own logical presentation state. This function
 * gets the rectangle for the current render target.
 *
 * \param renderer the rendering context.
 * \param rect a pointer filled in with the final presentation rectangle, may
 *             be NULL.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderLogicalPresentation
  }
function SDL_GetRenderLogicalPresentationRect(renderer: PSDL_Renderer; rect: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderLogicalPresentationRect' {$ENDIF} {$ENDIF};

{*
 * Get a point in render coordinates when given a point in window coordinates.
 *
 * This takes into account several states:
 *
 * - The window dimensions.
 * - The logical presentation settings (SDL_SetRenderLogicalPresentation)
 * - The scale (SDL_SetRenderScale)
 * - The viewport (SDL_SetRenderViewport)
 *
 * \param renderer the rendering context.
 * \param window_x the x coordinate in window coordinates.
 * \param window_y the y coordinate in window coordinates.
 * \param x a pointer filled with the x coordinate in render coordinates.
 * \param y a pointer filled with the y coordinate in render coordinates.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderLogicalPresentation
 * \sa SDL_SetRenderScale
  }
function SDL_RenderCoordinatesFromWindow(renderer: PSDL_Renderer; window_x: cfloat; window_y: cfloat; x: pcfloat; y: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderCoordinatesFromWindow' {$ENDIF} {$ENDIF};

{*
 * Get a point in window coordinates when given a point in render coordinates.
 *
 * This takes into account several states:
 *
 * - The window dimensions.
 * - The logical presentation settings (SDL_SetRenderLogicalPresentation)
 * - The scale (SDL_SetRenderScale)
 * - The viewport (SDL_SetRenderViewport)
 *
 * \param renderer the rendering context.
 * \param x the x coordinate in render coordinates.
 * \param y the y coordinate in render coordinates.
 * \param window_x a pointer filled with the x coordinate in window
 *                 coordinates.
 * \param window_y a pointer filled with the y coordinate in window
 *                 coordinates.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderLogicalPresentation
 * \sa SDL_SetRenderScale
 * \sa SDL_SetRenderViewport
  }
function SDL_RenderCoordinatesToWindow(renderer: PSDL_Renderer; x: cfloat; y: cfloat; window_x: pcfloat; window_y: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderCoordinatesToWindow' {$ENDIF} {$ENDIF};

{*
 * Convert the coordinates in an event to render coordinates.
 *
 * This takes into account several states:
 *
 * - The window dimensions.
 * - The logical presentation settings (SDL_SetRenderLogicalPresentation)
 * - The scale (SDL_SetRenderScale)
 * - The viewport (SDL_SetRenderViewport)
 *
 * Various event types are converted with this function: mouse, touch, pen,
 * etc.
 *
 * Touch coordinates are converted from normalized coordinates in the window
 * to non-normalized rendering coordinates.
 *
 * Relative mouse coordinates (xrel and yrel event fields) are _also_
 * converted. Applications that do not want these fields converted should use
 * SDL_RenderCoordinatesFromWindow() on the specific event fields instead of
 * converting the entire event structure.
 *
 * Once converted, coordinates may be outside the rendering area.
 *
 * \param renderer the rendering context.
 * \param event the event to modify.
 * \returns true if the event is converted or doesn't need conversion, or
 *          false on failure; call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderCoordinatesFromWindow
  }
function SDL_ConvertEventToRenderCoordinates(renderer: PSDL_Renderer; event: PSDL_Event): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ConvertEventToRenderCoordinates' {$ENDIF} {$ENDIF};

{*
 * Set the drawing area for rendering on the current target.
 *
 * Drawing will clip to this area (separately from any clipping done with
 * SDL_SetRenderClipRect), and the top left of the area will become coordinate
 * (0, 0) for future drawing commands.
 *
 * The area's width and height must be >= 0.
 *
 * Each render target has its own viewport. This function sets the viewport
 * for the current render target.
 *
 * \param renderer the rendering context.
 * \param rect the SDL_Rect structure representing the drawing area, or NULL
 *             to set the viewport to the entire target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderViewport
 * \sa SDL_RenderViewportSet
  }
function SDL_SetRenderViewport(renderer: PSDL_Renderer; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderViewport' {$ENDIF} {$ENDIF};

{*
 * Get the drawing area for the current target.
 *
 * Each render target has its own viewport. This function gets the viewport
 * for the current render target.
 *
 * \param renderer the rendering context.
 * \param rect an SDL_Rect structure filled in with the current drawing area.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderViewportSet
 * \sa SDL_SetRenderViewport
  }
function SDL_GetRenderViewport(renderer: PSDL_Renderer; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderViewport' {$ENDIF} {$ENDIF};

{*
 * Return whether an explicit rectangle was set as the viewport.
 *
 * This is useful if you're saving and restoring the viewport and want to know
 * whether you should restore a specific rectangle or NULL.
 *
 * Each render target has its own viewport. This function checks the viewport
 * for the current render target.
 *
 * \param renderer the rendering context.
 * \returns true if the viewport was set to a specific rectangle, or false if
 *          it was set to NULL (the entire target).
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderViewport
 * \sa SDL_SetRenderViewport
  }
function SDL_RenderViewportSet(renderer: PSDL_Renderer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderViewportSet' {$ENDIF} {$ENDIF};

{*
 * Get the safe area for rendering within the current viewport.
 *
 * Some devices have portions of the screen which are partially obscured or
 * not interactive, possibly due to on-screen controls, curved edges, camera
 * notches, TV overscan, etc. This function provides the area of the current
 * viewport which is safe to have interactible content. You should continue
 * rendering into the rest of the render target, but it should not contain
 * visually important or interactible content.
 *
 * \param renderer the rendering context.
 * \param rect a pointer filled in with the area that is safe for interactive
 *             content.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRenderSafeArea(renderer: PSDL_Renderer; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderSafeArea' {$ENDIF} {$ENDIF};

{*
 * Set the clip rectangle for rendering on the specified target.
 *
 * Each render target has its own clip rectangle. This function sets the
 * cliprect for the current render target.
 *
 * \param renderer the rendering context.
 * \param rect an SDL_Rect structure representing the clip area, relative to
 *             the viewport, or NULL to disable clipping.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderClipRect
 * \sa SDL_RenderClipEnabled
  }
function SDL_SetRenderClipRect(renderer: PSDL_Renderer; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderClipRect' {$ENDIF} {$ENDIF};

{*
 * Get the clip rectangle for the current target.
 *
 * Each render target has its own clip rectangle. This function gets the
 * cliprect for the current render target.
 *
 * \param renderer the rendering context.
 * \param rect an SDL_Rect structure filled in with the current clipping area
 *             or an empty rectangle if clipping is disabled.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderClipEnabled
 * \sa SDL_SetRenderClipRect
  }
function SDL_GetRenderClipRect(renderer: PSDL_Renderer; rect: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderClipRect' {$ENDIF} {$ENDIF};

{*
* Get whether clipping is enabled on the given render target.
*
* Each render target has its own clip rectangle. This function checks the
* cliprect for the current render target.
*
* \param renderer the rendering context.
* \returns true if clipping is enabled or false if not; call SDL_GetError()
*          for more information.
*
* \threadsafety This function should only be called on the main thread.
*
* \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderClipRect
 * \sa SDL_SetRenderClipRect
  }
function SDL_RenderClipEnabled(renderer: PSDL_Renderer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderClipEnabled' {$ENDIF} {$ENDIF};

{*
 * Set the drawing scale for rendering on the current target.
 *
 * The drawing coordinates are scaled by the x/y scaling factors before they
 * are used by the renderer. This allows resolution independent drawing with a
 * single coordinate system.
 *
 * If this results in scaling or subpixel drawing by the rendering backend, it
 * will be handled using the appropriate quality hints. For best results use
 * integer scaling factors.
 *
 *
 * Each render target has its own scale. This function sets the scale for the
 * current render target.
 *
 * \param renderer the rendering context.
 * \param scaleX the horizontal scaling factor.
 * \param scaleY the vertical scaling factor.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderScale
  }
function SDL_SetRenderScale(renderer: PSDL_Renderer; scaleX: cfloat; scaleY: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderScale' {$ENDIF} {$ENDIF};

{*
 * Get the drawing scale for the current target.
 *
 * Each render target has its own scale. This function gets the scale for the
 * current render target.
 *
 * \param renderer the rendering context.
 * \param scaleX a pointer filled in with the horizontal scaling factor.
 * \param scaleY a pointer filled in with the vertical scaling factor.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderScale
  }
function SDL_GetRenderScale(renderer: PSDL_Renderer; scaleX: pcfloat; scaleY: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderScale' {$ENDIF} {$ENDIF};

{*
 * Set the color used for drawing operations.
 *
 * Set the color for drawing or filling rectangles, lines, and points, and for
 * SDL_RenderClear().
 *
 * \param renderer the rendering context.
 * \param r the red value used to draw on the rendering target.
 * \param g the green value used to draw on the rendering target.
 * \param b the blue value used to draw on the rendering target.
 * \param a the alpha value used to draw on the rendering target; usually
 *          `SDL_ALPHA_OPAQUE` (255). Use SDL_SetRenderDrawBlendMode to
 *          specify how the alpha channel is used.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderDrawColor
 * \sa SDL_SetRenderDrawColorFloat
  }
function SDL_SetRenderDrawColor(renderer: PSDL_Renderer; r: cuint8; g: cuint8; b: cuint8; a: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderDrawColor' {$ENDIF} {$ENDIF};

{*
 * Set the color used for drawing operations (Rect, Line and Clear).
 *
 * Set the color for drawing or filling rectangles, lines, and points, and for
 * SDL_RenderClear().
 *
 * \param renderer the rendering context.
 * \param r the red value used to draw on the rendering target.
 * \param g the green value used to draw on the rendering target.
 * \param b the blue value used to draw on the rendering target.
 * \param a the alpha value used to draw on the rendering target. Use
 *          SDL_SetRenderDrawBlendMode to specify how the alpha channel is
 *          used.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderDrawColorFloat
 * \sa SDL_SetRenderDrawColor
  }
function SDL_SetRenderDrawColorFloat(renderer: PSDL_Renderer; r: cfloat; g: cfloat; b: cfloat; a: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderDrawColorFloat' {$ENDIF} {$ENDIF};

{*
 * Get the color used for drawing operations (Rect, Line and Clear).
 *
 * \param renderer the rendering context.
 * \param r a pointer filled in with the red value used to draw on the
 *          rendering target.
 * \param g a pointer filled in with the green value used to draw on the
 *          rendering target.
 * \param b a pointer filled in with the blue value used to draw on the
 *          rendering target.
 * \param a a pointer filled in with the alpha value used to draw on the
 *          rendering target; usually `SDL_ALPHA_OPAQUE` (255).
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderDrawColorFloat
 * \sa SDL_SetRenderDrawColor
  }
function SDL_GetRenderDrawColor(renderer: PSDL_Renderer; r: pcuint8; g: pcuint8; b: pcuint8; a: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderDrawColor' {$ENDIF} {$ENDIF};

{*
 * Get the color used for drawing operations (Rect, Line and Clear).
 *
 * \param renderer the rendering context.
 * \param r a pointer filled in with the red value used to draw on the
 *          rendering target.
 * \param g a pointer filled in with the green value used to draw on the
 *          rendering target.
 * \param b a pointer filled in with the blue value used to draw on the
 *          rendering target.
 * \param a a pointer filled in with the alpha value used to draw on the
 *          rendering target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderDrawColorFloat
 * \sa SDL_GetRenderDrawColor
  }
function SDL_GetRenderDrawColorFloat(renderer: PSDL_Renderer; r: pcfloat; g: pcfloat; b: pcfloat; a: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderDrawColorFloat' {$ENDIF} {$ENDIF};

{*
 * Set the color scale used for render operations.
 *
 * The color scale is an additional scale multiplied into the pixel color
 * value while rendering. This can be used to adjust the brightness of colors
 * during HDR rendering, or changing HDR video brightness when playing on an
 * SDR display.
 *
 * The color scale does not affect the alpha channel, only the color
 * brightness.
 *
 * \param renderer the rendering context.
 * \param scale the color scale value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderColorScale
  }
function SDL_SetRenderColorScale(renderer: PSDL_Renderer; scale: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderColorScale' {$ENDIF} {$ENDIF};

{*
 * Get the color scale used for render operations.
 *
 * \param renderer the rendering context.
 * \param scale a pointer filled in with the current color scale value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderColorScale
  }
function SDL_GetRenderColorScale(renderer: PSDL_Renderer; scale: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderColorScale' {$ENDIF} {$ENDIF};

{*
 * Set the blend mode used for drawing operations (Fill and Line).
 *
 * If the blend mode is not supported, the closest supported mode is chosen.
 *
 * \param renderer the rendering context.
 * \param blendMode the SDL_BlendMode to use for blending.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderDrawBlendMode
  }
function SDL_SetRenderDrawBlendMode(renderer: PSDL_Renderer; blendMode: TSDL_BlendMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderDrawBlendMode' {$ENDIF} {$ENDIF};

{*
 * Get the blend mode used for drawing operations.
 *
 * \param renderer the rendering context.
 * \param blendMode a pointer filled in with the current SDL_BlendMode.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderDrawBlendMode
  }
function SDL_GetRenderDrawBlendMode(renderer: PSDL_Renderer; blendMode: PSDL_BlendMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderDrawBlendMode' {$ENDIF} {$ENDIF};

{*
 * Clear the current rendering target with the drawing color.
 *
 * This function clears the entire rendering target, ignoring the viewport and
 * the clip rectangle. Note, that clearing will also set/fill all pixels of
 * the rendering target to current renderer draw color, so make sure to invoke
 * SDL_SetRenderDrawColor() when needed.
 *
 * \param renderer the rendering context.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderDrawColor
  }
function SDL_RenderClear(renderer: PSDL_Renderer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderClear' {$ENDIF} {$ENDIF};

{*
 * Draw a point on the current rendering target at subpixel precision.
 *
 * \param renderer the renderer which should draw a point.
 * \param x the x coordinate of the point.
 * \param y the y coordinate of the point.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderPoints
  }
function SDL_RenderPoint(renderer: PSDL_Renderer; x: cfloat; y: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderPoint' {$ENDIF} {$ENDIF};

{*
 * Draw multiple points on the current rendering target at subpixel precision.
 *
 * \param renderer the renderer which should draw multiple points.
 * \param points the points to draw.
 * \param count the number of points to draw.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderPoint
  }
function SDL_RenderPoints(renderer: PSDL_Renderer; points: PSDL_FPoint; count: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderPoints' {$ENDIF} {$ENDIF};

{*
 * Draw a line on the current rendering target at subpixel precision.
 *
 * \param renderer the renderer which should draw a line.
 * \param x1 the x coordinate of the start point.
 * \param y1 the y coordinate of the start point.
 * \param x2 the x coordinate of the end point.
 * \param y2 the y coordinate of the end point.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderLines
  }
function SDL_RenderLine(renderer: PSDL_Renderer; x1: cfloat; y1: cfloat; x2: cfloat; y2: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderLine' {$ENDIF} {$ENDIF};

{*
 * Draw a series of connected lines on the current rendering target at
 * subpixel precision.
 *
 * \param renderer the renderer which should draw multiple lines.
 * \param points the points along the lines.
 * \param count the number of points, drawing count-1 lines.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderLine
  }
function SDL_RenderLines(renderer: PSDL_Renderer; points: PSDL_FPoint; count: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderLines' {$ENDIF} {$ENDIF};

{*
 * Draw a rectangle on the current rendering target at subpixel precision.
 *
 * \param renderer the renderer which should draw a rectangle.
 * \param rect a pointer to the destination rectangle, or nil to outline the
 *             entire rendering target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderRects
  }
function SDL_RenderRect(renderer: PSDL_Renderer; rect: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderRect' {$ENDIF} {$ENDIF};

{*
 * Draw some number of rectangles on the current rendering target at subpixel
 * precision.
 *
 * \param renderer the renderer which should draw multiple rectangles.
 * \param rects a pointer to an array of destination rectangles.
 * \param count the number of rectangles.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderRect
  }
function SDL_RenderRects(renderer: PSDL_Renderer; rects: PSDL_FRect; count: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderRects' {$ENDIF} {$ENDIF};

{*
 * Fill a rectangle on the current rendering target with the drawing color at
 * subpixel precision.
 *
 * \param renderer the renderer which should fill a rectangle.
 * \param rect a pointer to the destination rectangle, or nil for the entire
 *             rendering target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderFillRects
  }

function SDL_RenderFillRect(renderer: PSDL_Renderer; rect: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderFillRect' {$ENDIF} {$ENDIF};

{*
 * Fill some number of rectangles on the current rendering target with the
 * drawing color at subpixel precision.
 *
 * \param renderer the renderer which should fill multiple rectangles.
 * \param rects a pointer to an array of destination rectangles.
 * \param count the number of rectangles.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderFillRect
  }
function SDL_RenderFillRects(renderer: PSDL_Renderer; rects: PSDL_FRect; count: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderFillRects' {$ENDIF} {$ENDIF};

{*
 * Copy a portion of the texture to the current rendering target at subpixel
 * precision.
 *
 * \param renderer the renderer which should copy parts of a texture.
 * \param texture the source texture.
 * \param srcrect a pointer to the source rectangle, or nil for the entire
 *                texture.
 * \param dstrect a pointer to the destination rectangle, or nil for the
 *                entire rendering target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderTextureRotated
 * \sa SDL_RenderTextureTiled
  }
function SDL_RenderTexture(renderer: PSDL_Renderer; texture: PSDL_Texture; srcrect: PSDL_FRect; dstrect: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderTexture' {$ENDIF} {$ENDIF};

{*
 * Copy a portion of the source texture to the current rendering target, with
 * rotation and flipping, at subpixel precision.
 *
 * \param renderer the renderer which should copy parts of a texture.
 * \param texture the source texture.
 * \param srcrect a pointer to the source rectangle, or nil for the entire
 *                texture.
 * \param dstrect a pointer to the destination rectangle, or nil for the
 *                entire rendering target.
 * \param angle an angle in degrees that indicates the rotation that will be
 *              applied to dstrect, rotating it in a clockwise direction.
 * \param center a pointer to a point indicating the point around which
 *               dstrect will be rotated (if nil, rotation will be done
 *               around dstrect.w/2, dstrect.h/2).
 * \param flip an SDL_FlipMode value stating which flipping actions should be
 *             performed on the texture.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderTexture
  }
function SDL_RenderTextureRotated(renderer: PSDL_Renderer; texture: PSDL_Texture;
           srcrect: PSDL_FRect; dstrect: PSDL_FRect;
           angle: cdouble; center: PSDL_FPoint;
           flip: TSDL_FlipMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderTextureRotated' {$ENDIF} {$ENDIF};

{*
 * Copy a portion of the source texture to the current rendering target, with
 * affine transform, at subpixel precision.
 *
 * \param renderer the renderer which should copy parts of a texture.
 * \param texture the source texture.
 * \param srcrect a Pointer to the source rectangle, or nil for the entire
 *                texture.
 * \param origin a Pointer to a point indicating where the top-left corner of
 *               srcrect should be mapped to, or nil for the rendering
 *               target's origin.
 * \param right a Pointer to a point indicating where the top-right corner of
 *              srcrect should be mapped to, or nil for the rendering
 *              target's top-right corner.
 * \param down a Pointer to a point indicating where the bottom-left corner of
 *             srcrect should be mapped to, or nil for the rendering target's
 *             bottom-left corner.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety You may only call this function from the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderTexture
  }
function SDL_RenderTextureAffine(renderer: PSDL_Renderer; texture: PSDL_Texture;
  srcrect: PSDL_FRect; origin: PSDL_FPoint; right: PSDL_FPoint;
  down: PSDL_FPoint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderTextureAffine' {$ENDIF} {$ENDIF};

{*
 * Tile a portion of the texture to the current rendering target at subpixel
 * precision.
 *
 * The pixels in `srcrect` will be repeated as many times as needed to
 * completely fill `dstrect`.
 *
 * \param renderer the renderer which should copy parts of a texture.
 * \param texture the source texture.
 * \param srcrect a pointer to the source rectangle, or nil for the entire
 *                texture.
 * \param scale the scale used to transform srcrect into the destination
 *              rectangle, e.g. a 32x32 texture with a scale of 2 would fill
 *              64x64 tiles.
 * \param dstrect a pointer to the destination rectangle, or nil for the
 *                entire rendering target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderTexture
  }
function SDL_RenderTextureTiled(renderer: PSDL_Renderer; texture: PSDL_Texture; srcrect: PSDL_FRect; scale: cfloat; dstrect: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderTextureTiled' {$ENDIF} {$ENDIF};

{*
 * Perform a scaled copy using the 9-grid algorithm to the current rendering
 * target at subpixel precision.
 *
 * The pixels in the texture are split into a 3x3 grid, using the different
 * corner sizes for each corner, and the sides and center making up the
 * remaining pixels. The corners are then scaled using `scale` and fit into
 * the corners of the destination rectangle. The sides and center are then
 * stretched into place to cover the remaining destination rectangle.
 *
 * \param renderer the renderer which should copy parts of a texture.
 * \param texture the source texture.
 * \param srcrect the SDL_Rect structure representing the rectangle to be used
 *                for the 9-grid, or nil to use the entire texture.
 * \param left_width the width, in pixels, of the left corners in `srcrect`.
 * \param right_width the width, in pixels, of the right corners in `srcrect`.
 * \param top_height the height, in pixels, of the top corners in `srcrect`.
 * \param bottom_height the height, in pixels, of the bottom corners in
 *                      `srcrect`.
 * \param scale the scale used to transform the corner of `srcrect` into the
 *              corner of `dstrect`, or 0.0f for an unscaled copy.
 * \param dstrect a pointer to the destination rectangle, or nil for the
 *                entire rendering target.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderTexture
 * \sa SDL_RenderTexture9GridTiled
  }
function SDL_RenderTexture9Grid(renderer: PSDL_Renderer; texture: PSDL_Texture; srcrect: PSDL_FRect; left_width: cfloat; right_width: cfloat; top_height: cfloat; bottom_height: cfloat; scale: cfloat; dstrect: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderTexture9Grid' {$ENDIF} {$ENDIF};

{*
 * Perform a scaled copy using the 9-grid algorithm to the current rendering
 * target at subpixel precision.
 *
 * The pixels in the texture are split into a 3x3 grid, using the different
 * corner sizes for each corner, and the sides and center making up the
 * remaining pixels. The corners are then scaled using `scale` and fit into
 * the corners of the destination rectangle. The sides and center are then
 * tiled into place to cover the remaining destination rectangle.
 *
 * \param renderer the renderer which should copy parts of a texture.
 * \param texture the source texture.
 * \param srcrect the SDL_Rect structure representing the rectangle to be used
 *                for the 9-grid, or nil to use the entire texture.
 * \param left_width the width, in pixels, of the left corners in `srcrect`.
 * \param right_width the width, in pixels, of the right corners in `srcrect`.
 * \param top_height the height, in pixels, of the top corners in `srcrect`.
 * \param bottom_height the height, in pixels, of the bottom corners in
 *                      `srcrect`.
 * \param scale the scale used to transform the corner of `srcrect` into the
 *              corner of `dstrect`, or 0.0f for an unscaled copy.
 * \param dstrect a Pointer to the destination rectangle, or nil for the
 *                entire rendering target.
 * \param tileScale the scale used to transform the borders and center of
 *                  `srcrect` into the borders and middle of `dstrect`, or
 *                  1.0f for an unscaled copy.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_RenderTexture
 * \sa SDL_RenderTexture9Grid
  }
function SDL_RenderTexture9GridTiled(renderer: PSDL_Renderer; texture: PSDL_Texture;
  srcrect: PSDL_FRect; left_width: cfloat; right_width: cfloat; top_height: cfloat;
  bottom_height: cfloat; scale: cfloat; dstrect: PSDL_FRect; tileScale: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderTexture9GridTiled' {$ENDIF} {$ENDIF};

{*
 * Render a list of triangles, optionally using a texture and indices into the
 * vertex array Color and alpha modulation is done per vertex
 * (SDL_SetTextureColorMod and SDL_SetTextureAlphaMod are ignored).
 *
 * \param renderer the rendering context.
 * \param texture (optional) The SDL texture to use.
 * \param vertices vertices.
 * \param num_vertices number of vertices.
 * \param indices (optional) An array of integer indices into the 'vertices'
 *                array, if nil all vertices will be rendered in sequential
 *                order.
 * \param num_indices number of indices.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderGeometryRaw
 * \sa SDL_SetRenderTextureAddressMode
  }
function SDL_RenderGeometry(renderer: PSDL_Renderer; texture: PSDL_Texture; vertices: PSDL_Vertex; num_vertices: cint; indices: pcint; num_indices: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderGeometry' {$ENDIF} {$ENDIF};

{*
 * Render a list of triangles, optionally using a texture and indices into the
 * vertex arrays Color and alpha modulation is done per vertex
 * (SDL_SetTextureColorMod and SDL_SetTextureAlphaMod are ignored).
 *
 * \param renderer the rendering context.
 * \param texture (optional) The SDL texture to use.
 * \param xy vertex positions.
 * \param xy_stride byte size to move from one element to the next element.
 * \param color vertex colors (as SDL_FColor).
 * \param color_stride byte size to move from one element to the next element.
 * \param uv vertex normalized texture coordinates.
 * \param uv_stride byte size to move from one element to the next element.
 * \param num_vertices number of vertices.
 * \param indices (optional) An array of indices into the 'vertices' arrays,
 *                if nil all vertices will be rendered in sequential order.
 * \param num_indices number of indices.
 * \param size_indices index size: 1 (byte), 2 (short), 4 (int).
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderGeometry
 * \sa SDL_SetRenderTextureAddressMode
  }
function SDL_RenderGeometryRaw(renderer: PSDL_Renderer; texture: PSDL_Texture;
           xy: pcfloat; xy_stride: cint;
           color: PSDL_FColor; color_stride: cint;
           uv: pcfloat; uv_stride: cint;
           num_vertices: cint;
           indices: pointer; num_indices: cint; size_indices: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderGeometryRaw' {$ENDIF} {$ENDIF};

{*
 * Set the texture addressing mode used in SDL_RenderGeometry().
 *
 * \param renderer the rendering context.
 * \param u_mode the SDL_TextureAddressMode to use for horizontal texture
 *               coordinates in SDL_RenderGeometry().
 * \param v_mode the SDL_TextureAddressMode to use for vertical texture
 *               coordinates in SDL_RenderGeometry().
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_RenderGeometry
 * \sa SDL_RenderGeometryRaw
 * \sa SDL_GetRenderTextureAddressMode
  }
function SDL_SetRenderTextureAddressMode(renderer: PSDL_Renderer;
  u_mode: TSDL_TextureAddressMode; v_mode: TSDL_TextureAddressMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderTextureAddressMode' {$ENDIF} {$ENDIF};

{*
 * Get the texture addressing mode used in SDL_RenderGeometry().
 *
 * \param renderer the rendering context.
 * \param u_mode a Pointer filled in with the SDL_TextureAddressMode to use
 *               for horizontal texture coordinates in SDL_RenderGeometry(),
 *               may be nil.
 * \param v_mode a Pointer filled in with the SDL_TextureAddressMode to use
 *               for vertical texture coordinates in SDL_RenderGeometry(), may
 *               be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_SetRenderTextureAddressMode
  }
function SDL_GetRenderTextureAddressMode(renderer: PSDL_Renderer;
  u_mode: PSDL_TextureAddressMode; v_mode: PSDL_TextureAddressMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderTextureAddressMode' {$ENDIF} {$ENDIF};

{*
* Read pixels from the current rendering target.
*
* The returned surface contains pixels inside the desired area clipped to the
* current viewport, and should be freed with SDL_DestroySurface().
*
* Note that this returns the actual pixels on the screen, so if you are using
* logical presentation you should use SDL_GetRenderLogicalPresentationRect()
* to get the area containing your content.
*
* **WARNING**: This is a very slow operation, and should not be used
* frequently. If you're using this on the main rendering target, it should be
* called after rendering and before SDL_RenderPresent().
*
* \param renderer the rendering context.
* \param rect an SDL_Rect structure representing the area to read, which will
*             be clipped to the current viewport, or NULL for the entire
*             viewport.
* \returns a new SDL_Surface on success or NULL on failure; call
*          SDL_GetError() for more information.
*
* \threadsafety This function should only be called on the main thread.
*
* \since This function is available since SDL 3.2.0.
  }
function SDL_RenderReadPixels(renderer: PSDL_Renderer; rect: PSDL_Rect): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderReadPixels' {$ENDIF} {$ENDIF};

{*
 * Update the screen with any rendering performed since the previous call.
 *
 * SDL's rendering functions operate on a backbuffer; that is, calling a
 * rendering function such as SDL_RenderLine() does not directly put a line on
 * the screen, but rather updates the backbuffer. As such, you compose your
 * entire scene and *present* the composed backbuffer to the screen as a
 * complete picture.
 *
 * Therefore, when using SDL's rendering API, one does all drawing intended
 * for the frame, and then calls this function once per frame to present the
 * final drawing to the user.
 *
 * The backbuffer should be considered invalidated after each present; do not
 * assume that previous contents will exist between frames. You are strongly
 * encouraged to call SDL_RenderClear() to initialize the backbuffer before
 * starting each new frame's drawing, even if you plan to overwrite every
 * pixel.
 *
 * Please note, that in case of rendering to a texture - there is **no need**
 * to call `SDL_RenderPresent` after drawing needed objects to a texture, and
 * should not be done; you are only required to change back the rendering
 * target to default via `SDL_SetRenderTarget(renderer, NULL)` afterwards, as
 * textures by themselves do not have a concept of backbuffers. Calling
 * SDL_RenderPresent while rendering to a texture will fail.
 *
 * \param renderer the rendering context.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateRenderer
 * \sa SDL_RenderClear
 * \sa SDL_RenderFillRect
 * \sa SDL_RenderFillRects
 * \sa SDL_RenderLine
 * \sa SDL_RenderLines
 * \sa SDL_RenderPoint
 * \sa SDL_RenderPoints
 * \sa SDL_RenderRect
 * \sa SDL_RenderRects
 * \sa SDL_SetRenderDrawBlendMode
 * \sa SDL_SetRenderDrawColor
  }
function SDL_RenderPresent(renderer: PSDL_Renderer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderPresent' {$ENDIF} {$ENDIF};

{*
 * Destroy the specified texture.
 *
 * Passing nil or an otherwise invalid texture will set the SDL error message
 * to "Invalid texture".
 *
 * \param texture the texture to destroy.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTexture
 * \sa SDL_CreateTextureFromSurface
  }
procedure SDL_DestroyTexture(texture: PSDL_Texture); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyTexture' {$ENDIF} {$ENDIF};

{*
 * Destroy the rendering context for a window and free all associated
 * textures.
 *
 * This should be called before destroying the associated window.
 *
 * \param renderer the rendering context.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateRenderer
  }
procedure SDL_DestroyRenderer(renderer: PSDL_Renderer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyRenderer' {$ENDIF} {$ENDIF};

{*
 * Force the rendering context to flush any pending commands and state.
 *
 * You do not need to (and in fact, shouldn't) call this function unless you
 * are planning to call into OpenGL/Direct3D/Metal/whatever directly, in
 * addition to using an SDL_Renderer.
 *
 * This is for a very-specific case: if you are using SDL's render API, and
 * you plan to make OpenGL/D3D/whatever calls in addition to SDL render API
 * calls. If this applies, you should call this function between calls to
 * SDL's render API and the low-level API you're using in cooperation.
 *
 * In all other cases, you can ignore this function.
 *
 * This call makes SDL flush any pending rendering work it was queueing up to
 * do later in a single batch, and marks any internal cached state as invalid,
 * so it'll prepare all its state again later, from scratch.
 *
 * This means you do not need to save state in your rendering code to protect
 * the SDL renderer. However, there lots of arbitrary pieces of Direct3D and
 * OpenGL state that can confuse things; you should use your best judgment and
 * be prepared to make changes if specific state needs to be protected.
 *
 * \param renderer the rendering context.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_FlushRenderer(renderer: PSDL_Renderer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FlushRenderer' {$ENDIF} {$ENDIF};

{*
 * Get the CAMetalLayer associated with the given Metal renderer.
 *
 * This function returns `void *`, so SDL doesn't have to include Metal's
 * headers, but it can be safely cast to a `CAMetalLayer *`.
 *
 * \param renderer the renderer to query.
 * \returns a `CAMetalLayer *` on success, or nil if the renderer isn't a
 *          Metal renderer.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderMetalCommandEncoder
  }
function SDL_GetRenderMetalLayer(renderer: PSDL_Renderer): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderMetalLayer' {$ENDIF} {$ENDIF};

{*
 * Get the Metal command encoder for the current frame.
 *
 * This function returns `void *`, so SDL doesn't have to include Metal's
 * headers, but it can be safely cast to an `id<MTLRenderCommandEncoder>`.
 *
 * This will return nil if Metal refuses to give SDL a drawable to render to,
 * which might happen if the window is hidden/minimized/offscreen. This
 * doesn't apply to command encoders for render targets, just the window's
 * backbuffer. Check your return values!
 *
 * \param renderer the renderer to query.
 * \returns an `id<MTLRenderCommandEncoder>` on success, or nil if the
 *          renderer isn't a Metal renderer or there was an error.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderMetalLayer
  }
function SDL_GetRenderMetalCommandEncoder(renderer: PSDL_Renderer): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderMetalCommandEncoder' {$ENDIF} {$ENDIF};

{*
 * Add a set of synchronization semaphores for the current frame.
 *
 * The Vulkan renderer will wait for `wait_semaphore` before submitting
 * rendering commands and signal `signal_semaphore` after rendering commands
 * are complete for this frame.
 *
 * This should be called each frame that you want semaphore synchronization.
 * The Vulkan renderer may have multiple frames in flight on the GPU, so you
 * should have multiple semaphores that are used for synchronization. Querying
 * SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER will give you the
 * maximum number of semaphores you'll need.
 *
 * \param renderer the rendering context.
 * \param wait_stage_mask the VkPipelineStageFlags for the wait.
 * \param wait_semaphore a VkSempahore to wait on before rendering the current
 *                       frame, or 0 if not needed.
 * \param signal_semaphore a VkSempahore that SDL will signal when rendering
 *                         for the current frame is complete, or 0 if not
 *                         needed.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is **NOT** safe to call this function from two threads at
 *               once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_AddVulkanRenderSemaphores(renderer: PSDL_Renderer; wait_stage_mask: cuint32; wait_semaphore: cint64; signal_semaphore: cint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AddVulkanRenderSemaphores' {$ENDIF} {$ENDIF};

{*
 * Toggle VSync of the given renderer.
 *
 * When a renderer is created, vsync defaults to SDL_RENDERER_VSYNC_DISABLED.
 *
 * The `vsync` parameter can be 1 to synchronize present with every vertical
 * refresh, 2 to synchronize present with every second vertical refresh, etc.,
 * SDL_RENDERER_VSYNC_ADAPTIVE for late swap tearing (adaptive vsync), or
 * SDL_RENDERER_VSYNC_DISABLED to disable. Not every value is supported by
 * every driver, so you should check the return value to see whether the
 * requested setting is supported.
 *
 * \param renderer the renderer to toggle.
 * \param vsync the vertical refresh sync interval.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRenderVSync
  }
function SDL_SetRenderVSync(renderer: PSDL_Renderer; vsync: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetRenderVSync' {$ENDIF} {$ENDIF};

const
  SDL_RENDERER_VSYNC_DISABLED = 0;
  SDL_RENDERER_VSYNC_ADAPTIVE = -1;

{*
 * Get VSync of the given renderer.
 *
 * \param renderer the renderer to toggle.
 * \param vsync an int filled with the current vertical refresh sync interval.
 *              See SDL_SetRenderVSync() for the meaning of the value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderVSync
  }
function SDL_GetRenderVSync(renderer: PSDL_Renderer; vsync: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRenderVSync' {$ENDIF} {$ENDIF};

{*
 * The size, in pixels, of a single SDL_RenderDebugText() character.
 *
 * The font is monospaced and square, so this applies to all characters.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_RenderDebugText
  }
const
  SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE = 8;

{*
 * Draw debug text to an SDL_Renderer.
 *
 * This function will render a string of text to an SDL_Renderer. Note that
 * this is a convenience function for debugging, with severe limitations, and
 * not intended to be used for production apps and games.
 *
 * Among these limitations:
 *
 * - It accepts UTF-8 strings, but will only renders ASCII characters.
 * - It has a single, tiny size (8x8 pixels). You can use logical presentation
 *   or SDL_SetRenderScale() to adjust it.
 * - It uses a simple, hardcoded bitmap font. It does not allow different font
 *   selections and it does not support truetype, for proper scaling.
 * - It does no word-wrapping and does not treat newline characters as a line
 *   break. If the text goes out of the window, it's gone.
 *
 * For serious text rendering, there are several good options, such as
 * SDL_ttf, stb_truetype, or other
  external libraries.
 *
 * On first use, this will create an internal texture for rendering glyphs.
 * This texture will live until the renderer is destroyed.
 *
 * The text is drawn in the color specified by SDL_SetRenderDrawColor().
 *
 * \param renderer the renderer which should draw a line of text.
 * \param x the x coordinate where the top-left corner of the text will draw.
 * \param y the y coordinate where the top-left corner of the text will draw.
 * \param str the string to render.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderDebugTextFormat
 * \sa SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE
  }
function SDL_RenderDebugText(renderer: PSDL_Renderer; x: cfloat; y: cfloat; str: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderDebugText' {$ENDIF} {$ENDIF};

{*
 * Draw debug text to an SDL_Renderer.
 *
 * This function will render a printf()-style format string to a renderer.
 * Note that this is a convenience function for debugging, with severe
 * limitations, and is not intended to be used for production apps and games.
 *
 * For the full list of limitations and other useful information, see
 * SDL_RenderDebugText.
 *
 * \param renderer the renderer which should draw the text.
 * \param x the x coordinate where the top-left corner of the text will draw.
 * \param y the y coordinate where the top-left corner of the text will draw.
 * \param fmt the format string to draw.
 * \param ... additional parameters matching % tokens in the `fmt` string, if
 *            any.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RenderDebugText
 * \sa SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE
  }
function SDL_RenderDebugTextFormat(renderer: PSDL_Renderer; x: cfloat; y: cfloat; fmt: PAnsiChar; Args: array of const): Boolean; cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderDebugTextFormat' {$ENDIF} {$ENDIF};
function SDL_RenderDebugTextFormat(renderer: PSDL_Renderer; x: cfloat; y: cfloat; fmt: PAnsiChar): Boolean; cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenderDebugTextFormat' {$ENDIF} {$ENDIF};

{*
 * Set default scale mode for new textures for given renderer.
 *
 * When a renderer is created, scale_mode defaults to SDL_SCALEMODE_LINEAR.
 *
 * \param renderer the renderer to update.
 * \param scale_mode the scale mode to change to for new textures.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_GetDefaultTextureScaleMode
  }
function SDL_SetDefaultTextureScaleMode(renderer: PSDL_Renderer; scale_mode: TSDL_ScaleMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetDefaultTextureScaleMode' {$ENDIF} {$ENDIF};

{*
 * Get default texture scale mode of the given renderer.
 *
 * \param renderer the renderer to get data from.
 * \param scale_mode a SDL_ScaleMode filled with current default scale mode.
 *                   See SDL_SetDefaultTextureScaleMode() for the meaning of
 *                   the value.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_SetDefaultTextureScaleMode
  }
function SDL_GetDefaultTextureScaleMode(renderer: PSDL_Renderer; scale_mode: PSDL_ScaleMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDefaultTextureScaleMode' {$ENDIF} {$ENDIF};

{*
 * A structure specifying the parameters of a GPU render state.
 *
 * \since This struct is available since SDL 3.4.0.
 *
 * \sa SDL_CreateGPURenderState
  }
type
  PPSDL_GPURenderStateCreateInfo = ^PSDL_GPURenderStateCreateInfo;
  PSDL_GPURenderStateCreateInfo = ^TSDL_GPURenderStateCreateInfo;
  TSDL_GPURenderStateCreateInfo = record
      fragment_shader: PSDL_GPUShader;                  {*< The fragment shader to use when this render state is active  }
      num_sampler_bindings: cint32;                     {*< The number of additional fragment samplers to bind when this render state is active  }
      sampler_bindings: PSDL_GPUTextureSamplerBinding;  {*< Additional fragment samplers to bind when this render state is active  }
      num_storage_textures: cint32;                     {*< The number of storage textures to bind when this render state is active  }
      storage_textures: ^PSDL_GPUTexture;               {*< Storage textures to bind when this render state is active  }
      num_storage_buffers: cint32;                      {*< The number of storage buffers to bind when this render state is active  }
      storage_buffers: ^PSDL_GPUBuffer;                 {*< Storage buffers to bind when this render state is active  }
      props: TSDL_PropertiesID;                         {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A custom GPU render state.
 *
 * \since This struct is available since SDL 3.4.0.
 *
 * \sa SDL_CreateGPURenderState
 * \sa SDL_SetGPURenderStateFragmentUniforms
 * \sa SDL_SetGPURenderState
 * \sa SDL_DestroyGPURenderState
  }
type
  PPSDL_GPURenderState = ^PSDL_GPURenderState;
  PSDL_GPURenderState = type Pointer;

{*
 * Create custom GPU render state.
 *
 * \param renderer the renderer to use.
 * \param createinfo a struct describing the GPU render state to create.
 * \returns a custom GPU render state or nil on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety This function should be called on the thread that created the
 *               renderer.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_SetGPURenderStateFragmentUniforms
 * \sa SDL_SetGPURenderState
 * \sa SDL_DestroyGPURenderState
  }
function SDL_CreateGPURenderState(renderer: PSDL_Renderer; createinfo: PSDL_GPURenderStateCreateInfo): PSDL_GPURenderState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPURenderState' {$ENDIF} {$ENDIF};

{*
 * Set fragment shader uniform variables in a custom GPU render state.
 *
 * The data is copied and will be pushed using
 * SDL_PushGPUFragmentUniformData() during draw call execution.
 *
 * \param state the state to modify.
 * \param slot_index the fragment uniform slot to push data to.
 * \param data client data to write.
 * \param length the length of the data to write.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should be called on the thread that created the
 *               renderer.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_SetGPURenderStateFragmentUniforms(state: PSDL_GPURenderState; slot_index: cuint32; data: Pointer; length: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPURenderStateFragmentUniforms' {$ENDIF} {$ENDIF};

{*
 * Set custom GPU render state.
 *
 * This function sets custom GPU render state for subsequent draw calls. This
 * allows using custom shaders with the GPU renderer.
 *
 * \param renderer the renderer to use.
 * \param state the state to to use, or nil to clear custom GPU render state.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should be called on the thread that created the
 *               renderer.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_SetGPURenderState(renderer: PSDL_Renderer; state: PSDL_GPURenderState): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPURenderState' {$ENDIF} {$ENDIF};

{*
 * Destroy custom GPU render state.
 *
 * \param state the state to destroy.
 *
 * \threadsafety This function should be called on the thread that created the
 *               renderer.
 *
 * \since This function is available since SDL 3.4.0.
 *
 * \sa SDL_CreateGPURenderState
  }
procedure SDL_DestroyGPURenderState(state: PSDL_GPURenderState); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyGPURenderState' {$ENDIF} {$ENDIF};

