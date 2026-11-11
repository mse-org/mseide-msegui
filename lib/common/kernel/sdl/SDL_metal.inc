{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryMetal
 *
 * Functions to creating Metal layers and views on SDL windows.
 *
 * This provides some platform-specific glue for Apple platforms. Most macOS
 * and iOS apps can use SDL without these functions, but this API they can be
 * useful for specific OS-level integration tasks.
  }

{*
 * A handle to a CAMetalLayer-backed NSView (macOS) or UIView (iOS/tvOS).
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_MetalView = ^PSDL_MetalView;
  PSDL_MetalView = ^TSDL_MetalView;
  TSDL_MetalView = Pointer;

{*
 *  \name Metal support functions
  }

{*
 * Create a CAMetalLayer-backed NSView/UIView and attach it to the specified
 * window.
 *
 * On macOS, this does *not* associate a MTLDevice with the CAMetalLayer on
 * its own. It is up to user code to do that.
 *
 * The returned handle can be casted directly to a NSView or UIView. To access
 * the backing CAMetalLayer, call SDL_Metal_GetLayer().
 *
 * \param window the window.
 * \returns handle NSView or UIView.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Metal_DestroyView
 * \sa SDL_Metal_GetLayer
  }
function SDL_Metal_CreateView(window: PSDL_Window): TSDL_MetalView; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Metal_CreateView' {$ENDIF} {$ENDIF};

{*
 * Destroy an existing SDL_MetalView object.
 *
 * This should be called before SDL_DestroyWindow, if SDL_Metal_CreateView was
 * called after SDL_CreateWindow.
 *
 * \param view the SDL_MetalView object.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Metal_CreateView
  }
procedure SDL_Metal_DestroyView(view: TSDL_MetalView); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Metal_DestroyView' {$ENDIF} {$ENDIF};

{*
 * Get a Pointer to the backing CAMetalLayer for the given view.
 *
 * \param view the SDL_MetalView object.
 * \returns a Pointer.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_Metal_GetLayer(view: TSDL_MetalView): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Metal_GetLayer' {$ENDIF} {$ENDIF};

