{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryVulkan
 *
 * Functions for creating Vulkan surfaces on SDL windows.
 *
 * For the most part, Vulkan operates independent of SDL, but it benefits from
 * a little support during setup.
 *
 * Use SDL_Vulkan_GetInstanceExtensions() to get platform-specific bits for
 * creating a VkInstance, then SDL_Vulkan_GetVkGetInstanceProcAddr() to get
 * the appropriate function for querying Vulkan entry points. Then
 * SDL_Vulkan_CreateSurface() will get you the final pieces you need to
 * prepare for rendering into an SDL_Window with Vulkan.
 *
 * Unlike OpenGL, most of the details of "context" creation and window buffer
 * swapping are handled by the Vulkan API directly, so SDL doesn't provide
 * Vulkan equivalents of SDL_GL_SwapWindow(), etc; they aren't necessary.
  }

{ #note : SDL3-for-Pascal: The following comment includes the original C code. }
{ Avoid including vulkan_core.h, don't define VkInstance if it's already included }
{
  #ifdef VULKAN_CORE_H_
  #define NO_SDL_VULKAN_TYPEDEFS
  #endif
  #ifndef NO_SDL_VULKAN_TYPEDEFS
  #define VK_DEFINE_HANDLE(object) typedef struct object##_T* object;

  #if defined(__LP64__) || defined(_WIN64) || (defined(__x86_64__) && !defined(__ILP32__)) || defined(_M_X64) || defined(__ia64) || defined (_M_IA64) || defined(__aarch64__) || defined(__powerpc64__) || (defined(__riscv) && __riscv_xlen == 64)
  #define VK_DEFINE_NON_DISPATCHABLE_HANDLE(object) typedef struct object##_T *object;
  #else
  #define VK_DEFINE_NON_DISPATCHABLE_HANDLE(object) typedef uint64_t object;
  #endif

  VK_DEFINE_HANDLE(VkInstance)
  VK_DEFINE_HANDLE(VkPhysicalDevice)
  VK_DEFINE_NON_DISPATCHABLE_HANDLE(VkSurfaceKHR)
  struct VkAllocationCallbacks;
}
{ #todo : Is there a common compiler flag in the Vulkan bindings for Pascal?
          Couldn't find any common one. Examine. }
{$IFDEF VULKAN}
  {$DEFINE NO_SDL_VULKAN_TYPEDEFS}
{$ENDIF}
{$IFNDEF NO_SDL_VULKAN_TYPEDEFS}
type
  PVkInstance = ^TVkInstance;
  TVkInstance = ^TVkInstance_T;
  TVkInstance_T = Pointer;
  PVkPhysicalDevice = ^TVkPhysicalDevice;
  TVkPhysicalDevice = ^TVkPhysicalDevice_T;
  TVkPhysicalDevice_T = Pointer;
  PVkSurfaceKHR = ^TVkSurfaceKHR;
  TVkSurfaceKHR = ^TVkSurfaceKHR_T;
  TVkSurfaceKHR_T = Pointer;
{$ENDIF}
type
  PPVkAllocationCallbacks = ^PVkAllocationCallbacks;
  PVkAllocationCallbacks = ^TVkAllocationCallbacks;
  TVkAllocationCallbacks = Pointer;     {undefined structure}

{*
 *  \name Vulkan support functions
  }

{*
 * Dynamically load the Vulkan loader library.
 *
 * This should be called after initializing the video driver, but before
 * creating any Vulkan windows. If no Vulkan loader library is loaded, the
 * default library will be loaded upon creation of the first Vulkan window.
 *
 * SDL keeps a counter of how many times this function has been successfully
 * called, so it is safe to call this function multiple times, so long as it
 * is eventually paired with an equivalent number of calls to
 * SDL_Vulkan_UnloadLibrary. The `path` argument is ignored unless there is no
 * library currently loaded, and and the library isn't actually unloaded until
 * there have been an equivalent number of calls to SDL_Vulkan_UnloadLibrary.
 *
 * It is fairly common for Vulkan applications to link with libvulkan instead
 * of explicitly loading it at run time. This will work with SDL provided the
 * application links to a dynamic library and both it and SDL use the same
 * search path.
 *
 * If you specify a non-nil `path`, an application should retrieve all of the
 * Vulkan functions it uses from the dynamic library using
 * SDL_Vulkan_GetVkGetInstanceProcAddr unless you can guarantee `path` points
 * to the same vulkan loader library the application linked to.
 *
 * On Apple devices, if `path` is nil, SDL will attempt to find the
 * `vkGetInstanceProcAddr` address within all the Mach-O images of the current
 * process. This is because it is fairly common for Vulkan applications to
 * link with libvulkan (and historically MoltenVK was provided as a static
 * library). If it is not found, on macOS, SDL will attempt to load
 * `vulkan.framework/vulkan`, `libvulkan.1.dylib`,
 * `MoltenVK.framework/MoltenVK`, and `libMoltenVK.dylib`, in that order. On
 * iOS, SDL will attempt to load `libMoltenVK.dylib`. Applications using a
 * dynamic framework or .dylib must ensure it is included in its application
 * bundle.
 *
 * On non-Apple devices, application linking with a static libvulkan is not
 * supported. Either do not link to the Vulkan loader or link to a dynamic
 * library version.
 *
 * \param path the platform dependent Vulkan loader library name or nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Vulkan_GetVkGetInstanceProcAddr
 * \sa SDL_Vulkan_UnloadLibrary
  }
function SDL_Vulkan_LoadLibrary(path: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_LoadLibrary' {$ENDIF} {$ENDIF};

{*
 * Get the address of the `vkGetInstanceProcAddr` function.
 *
 * This should be called after either calling SDL_Vulkan_LoadLibrary() or
 * creating an SDL_Window with the `SDL_WINDOW_VULKAN` flag.
 *
 * The actual type of the returned function Pointer is
 * PFN_vkGetInstanceProcAddr, but that isn't available because the Vulkan
 * headers are not included here. You should cast the return value of this
 * function to that type, e.g.
 *
 * `vkGetInstanceProcAddr =
 * (PFN_vkGetInstanceProcAddr)SDL_Vulkan_GetVkGetInstanceProcAddr();`
 *
 * \returns the function Pointer for `vkGetInstanceProcAddr` or nil on
 *          failure; call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_Vulkan_GetVkGetInstanceProcAddr: TSDL_FunctionPointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_GetVkGetInstanceProcAddr' {$ENDIF} {$ENDIF};

{*
 * Unload the Vulkan library previously loaded by SDL_Vulkan_LoadLibrary().
 *
 * SDL keeps a counter of how many times this function has been called, so it
 * is safe to call this function multiple times, so long as it is paired with
 * an equivalent number of calls to SDL_Vulkan_LoadLibrary. The library isn't
 * actually unloaded until there have been an equivalent number of calls to
 * SDL_Vulkan_UnloadLibrary.
 *
 * Once the library has actually been unloaded, if any Vulkan instances
 * remain, they will likely crash the program. Clean up any existing Vulkan
 * resources, and destroy appropriate windows, renderers and GPU devices
 * before calling this function.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Vulkan_LoadLibrary
  }
procedure SDL_Vulkan_UnloadLibrary; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_UnloadLibrary' {$ENDIF} {$ENDIF};

{*
 * Get the Vulkan instance extensions needed for vkCreateInstance.
 *
 * This should be called after either calling SDL_Vulkan_LoadLibrary() or
 * creating an SDL_Window with the `SDL_WINDOW_VULKAN` flag.
 *
 * On return, the variable pointed to by `count` will be set to the number of
 * elements returned, suitable for using with
 * VkInstanceCreateInfo:: enabledExtensionCount, and the returned array can be
 * used with VkInstanceCreateInfo:: ppEnabledExtensionNames, for calling
 * Vulkan's vkCreateInstance API.
 *
 * You should not free the returned array; it is owned by SDL.
 *
 * \param count a Pointer filled in with the number of extensions returned.
 * \returns an array of extension name strings on success, nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Vulkan_CreateSurface
  }
function SDL_Vulkan_GetInstanceExtensions(count: pcuint32):PPAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_GetInstanceExtensions' {$ENDIF} {$ENDIF};

{*
 * Create a Vulkan rendering surface for a window.
 *
 * The `window` must have been created with the `SDL_WINDOW_VULKAN` flag and
 * `instance` must have been created with extensions returned by
 * SDL_Vulkan_GetInstanceExtensions() enabled.
 *
 * If `allocator` is nil, Vulkan will use the system default allocator. This
 * argument is passed directly to Vulkan and isn't used by SDL itself.
 *
 * \param window the window to which to attach the Vulkan surface.
 * \param instance the Vulkan instance handle.
 * \param allocator a VkAllocationCallbacks struct, which lets the app set the
 *                  allocator that creates the surface. Can be nil.
 * \param surface a Pointer to a VkSurfaceKHR handle to output the newly
 *                created surface.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Vulkan_GetInstanceExtensions
 * \sa SDL_Vulkan_DestroySurface
  }
function SDL_Vulkan_CreateSurface(window: PSDL_Window; instance: TVkInstance; allocator: PVkAllocationCallbacks; surface: PVkSurfaceKHR): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_CreateSurface' {$ENDIF} {$ENDIF};

{*
 * Destroy the Vulkan rendering surface of a window.
 *
 * This should be called before SDL_DestroyWindow, if SDL_Vulkan_CreateSurface
 * was called after SDL_CreateWindow.
 *
 * The `instance` must have been created with extensions returned by
 * SDL_Vulkan_GetInstanceExtensions() enabled and `surface` must have been
 * created successfully by an SDL_Vulkan_CreateSurface() call.
 *
 * If `allocator` is nil, Vulkan will use the system default allocator. This
 * argument is passed directly to Vulkan and isn't used by SDL itself.
 *
 * \param instance the Vulkan instance handle.
 * \param surface vkSurfaceKHR handle to destroy.
 * \param allocator a VkAllocationCallbacks struct, which lets the app set the
 *                  allocator that destroys the surface. Can be nil.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Vulkan_GetInstanceExtensions
 * \sa SDL_Vulkan_CreateSurface
  }
procedure SDL_Vulkan_DestroySurface(instance: TVkInstance; surface: TVkSurfaceKHR; allocator: PVkAllocationCallbacks); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_DestroySurface' {$ENDIF} {$ENDIF};

{*
 * Query support for presentation via a given physical device and queue
 * family.
 *
 * The `instance` must have been created with extensions returned by
 * SDL_Vulkan_GetInstanceExtensions() enabled.
 *
 * \param instance the Vulkan instance handle.
 * \param physicalDevice a valid Vulkan physical device handle.
 * \param queueFamilyIndex a valid queue family index for the given physical
 *                         device.
 * \returns true if supported, false if unsupported or an error occurred.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Vulkan_GetInstanceExtensions
  }
function SDL_Vulkan_GetPresentationSupport(instance: TVkInstance; physicalDevice: TVkPhysicalDevice; queueFamilyIndex: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Vulkan_GetPresentationSupport' {$ENDIF} {$ENDIF};
