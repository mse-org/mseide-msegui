{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryProperties
 *
 * A property is a variable that can be created and retrieved by name at
 * runtime.
 *
 * All properties are part of a property group (SDL_PropertiesID). A property
 * group can be created with the SDL_CreateProperties function and destroyed
 * with the SDL_DestroyProperties function.
 *
 * Properties can be added to and retrieved from a property group through the
 * following functions:
 *
 * - SDL_SetPointerProperty and SDL_GetPointerProperty operate on `void*`
 *   Pointer types.
 * - SDL_SetStringProperty and SDL_GetStringProperty operate on string types.
 * - SDL_SetNumberProperty and SDL_GetNumberProperty operate on signed 64-bit
 *   integer types.
 * - SDL_SetFloatProperty and SDL_GetFloatProperty operate on floating point
 *   types.
 * - SDL_SetBooleanProperty and SDL_GetBooleanProperty operate on boolean
 *   types.
 *
 * Properties can be removed from a group by using SDL_ClearProperty.
  }

{*
 * An ID that represents a properties set.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_PropertiesID = ^PSDL_PropertiesID;
  PSDL_PropertiesID = ^TSDL_PropertiesID;
  TSDL_PropertiesID = cuint32;

{*
 * SDL property type
 *
 * \since This enum is available since SDL 3.2.0.
  }

PPSDL_PropertyType = ^PSDL_PropertyType;
PSDL_PropertyType = ^TSDL_PropertyType;
TSDL_PropertyType =  Integer;
const
  SDL_PROPERTY_TYPE_INVALID = TSDL_PropertyType(0);
  SDL_PROPERTY_TYPE_POINTER = TSDL_PropertyType(1);
  SDL_PROPERTY_TYPE_STRING = TSDL_PropertyType(2);
  SDL_PROPERTY_TYPE_NUMBER = TSDL_PropertyType(3);
  SDL_PROPERTY_TYPE_FLOAT = TSDL_PropertyType(4);
  SDL_PROPERTY_TYPE_BOOLEAN = TSDL_PropertyType(5);

{**
 * A generic property for naming things.
 *
 * This property is intended to be added to any SDL_PropertiesID that needs a
 * generic name associated with the property set. It is not guaranteed that
 * any property set will include this key, but it is convenient to have a
 * standard key that any piece of code could reasonably agree to use.
 *
 * For example, the properties associated with an SDL_Texture might have a
 * name string of "player sprites", or an SDL_AudioStream might have
 * "background music", etc. This might also be useful for an SDL_IOStream to
 * list the path to its asset.
 *
 * There is no format for the value set with this key; it is expected to be
 * human-readable and informational in nature, possibly for logging or
 * debugging purposes.
 *
 * SDL does not currently set this property on any objects it creates, but
 * this may change in later versions; it is currently expected that apps and
 * external libraries will take advantage of it, when appropriate.
 *
 * \since This macro is available since SDL 3.4.0.
   *}
const
  SDL_PROP_NAME_STRING = 'SDL.name';

{*
 * Get the global SDL properties.
 *
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGlobalProperties: TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGlobalProperties' {$ENDIF} {$ENDIF};

{*
 * Create a group of properties.
 *
 * All properties are automatically destroyed when SDL_Quit() is called.
 *
 * \returns an ID for a new group of properties, or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DestroyProperties
  }
function SDL_CreateProperties: TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateProperties' {$ENDIF} {$ENDIF};

{*
 * Copy a group of properties.
 *
 * Copy all the properties from one group of properties to another, with the
 * exception of properties requiring cleanup (set using
 * SDL_SetPointerPropertyWithCleanup()), which will not be copied. Any
 * property that already exists on `dst` will be overwritten.
 *
 * \param src the properties to copy.
 * \param dst the destination properties.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread. This
 *               function acquires simultaneous mutex locks on both the source
 *               and destination property sets.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_CopyProperties(src: TSDL_PropertiesID; dst: TSDL_PropertiesID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CopyProperties' {$ENDIF} {$ENDIF};

{*
 * Lock a group of properties.
 *
 * Obtain a multi-threaded lock for these properties. Other threads will wait
 * while trying to lock these properties until they are unlocked. Properties
 * must be unlocked before they are destroyed.
 *
 * The lock is automatically taken when setting individual properties, this
 * function is only needed when you want to set several properties atomically
 * or want to guarantee that properties being queried aren't freed in another
 * thread.
 *
 * \param props the properties to lock.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UnlockProperties
  }
function SDL_LockProperties(props: TSDL_PropertiesID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LockProperties' {$ENDIF} {$ENDIF};

{*
 * Unlock a group of properties.
 *
 * \param props the properties to unlock.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LockProperties
  }
procedure SDL_UnlockProperties(props: TSDL_PropertiesID); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UnlockProperties' {$ENDIF} {$ENDIF};

{*
 * A callback used to free resources when a property is deleted.
 *
 * This should release any resources associated with `value` that are no
 * longer needed.
 *
 * This callback is set per-property. Different properties in the same group
 * can have different cleanup callbacks.
 *
 * This callback will be called _during_ SDL_SetPointerPropertyWithCleanup if
 * the function fails for any reason.
 *
 * \param userdata an app-defined Pointer passed to the callback.
 * \param value the Pointer assigned to the property to clean up.
 *
 * \threadsafety This callback may fire without any locks held; if this is a
 *               concern, the app should provide its own locking.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_SetPointerPropertyWithCleanup
  }
type
  TSDL_CleanupPropertyCallback = procedure (userdata: Pointer; value: Pointer); cdecl;

{*
 * Set a Pointer property in a group of properties with a cleanup function
 * that is called when the property is deleted.
 *
 * The cleanup function is also called if setting the property fails for any
 * reason.
 *
 * For simply setting basic data types, like numbers, bools, or strings, use
 * SDL_SetNumberProperty, SDL_SetBooleanProperty, or SDL_SetStringProperty
 * instead, as those functions will handle cleanup on your behalf. This
 * function is only for more complex, custom data.
 *
 * \param props the properties to modify.
 * \param name the name of the property to modify.
 * \param value the new value of the property, or nil to delete the property.
 * \param cleanup the function to call when this property is deleted, or nil
 *                if no cleanup is necessary.
 * \param userdata a Pointer that is passed to the cleanup function.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPointerProperty
 * \sa SDL_SetPointerProperty
 * \sa SDL_CleanupPropertyCallback
  }
function SDL_SetPointerPropertyWithCleanup(props: TSDL_PropertiesID; name: PAnsiChar; value: Pointer; cleanup: TSDL_CleanupPropertyCallback; userdata: Pointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetPointerPropertyWithCleanup' {$ENDIF} {$ENDIF};

{*
 * Set a Pointer property in a group of properties.
 *
 * \param props the properties to modify.
 * \param name the name of the property to modify.
 * \param value the new value of the property, or nil to delete the property.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPointerProperty
 * \sa SDL_HasProperty
 * \sa SDL_SetBooleanProperty
 * \sa SDL_SetFloatProperty
 * \sa SDL_SetNumberProperty
 * \sa SDL_SetPointerPropertyWithCleanup
 * \sa SDL_SetStringProperty
  }
function SDL_SetPointerProperty(props: TSDL_PropertiesID; name: PAnsiChar; value: Pointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetPointerProperty' {$ENDIF} {$ENDIF};

{*
 * Set a string property in a group of properties.
 *
 * This function makes a copy of the string; the caller does not have to
 * preserve the data after this call completes.
 *
 * \param props the properties to modify.
 * \param name the name of the property to modify.
 * \param value the new value of the property, or nil to delete the property.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetStringProperty
  }
function SDL_SetStringProperty(props: TSDL_PropertiesID; name: PAnsiChar; value: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetStringProperty' {$ENDIF} {$ENDIF};

{*
 * Set an integer property in a group of properties.
 *
 * \param props the properties to modify.
 * \param name the name of the property to modify.
 * \param value the new value of the property.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumberProperty
  }
function SDL_SetNumberProperty(props: TSDL_PropertiesID; name: PAnsiChar; value: cint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetNumberProperty' {$ENDIF} {$ENDIF};

{*
 * Set a floating point property in a group of properties.
 *
 * \param props the properties to modify.
 * \param name the name of the property to modify.
 * \param value the new value of the property.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetFloatProperty
  }
function SDL_SetFloatProperty(props: TSDL_PropertiesID; name: PAnsiChar; value: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetFloatProperty' {$ENDIF} {$ENDIF};

{*
 * Set a boolean property in a group of properties.
 *
 * \param props the properties to modify.
 * \param name the name of the property to modify.
 * \param value the new value of the property.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetBooleanProperty
  }
function SDL_SetBooleanProperty(props: TSDL_PropertiesID; name: PAnsiChar; value: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetBooleanProperty' {$ENDIF} {$ENDIF};

{*
 * Return whether a property exists in a group of properties.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \returns true if the property exists, or false if it doesn't.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPropertyType
  }
function SDL_HasProperty(props: TSDL_PropertiesID; name: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasProperty' {$ENDIF} {$ENDIF};

{*
 * Get the type of a property in a group of properties.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \returns the type of the property, or SDL_PROPERTY_TYPE_INVALID if it is
 *          not set.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasProperty
  }
function SDL_GetPropertyType(props: TSDL_PropertiesID; name: PAnsiChar): TSDL_PropertyType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPropertyType' {$ENDIF} {$ENDIF};

{*
 * Get a Pointer property from a group of properties.
 *
 * By convention, the names of properties that SDL exposes on objects will
 * start with "SDL.", and properties that SDL uses internally will start with
 * "SDL.internal.". These should be considered read-only and should not be
 * modified by applications.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \param default_value the default value of the property.
 * \returns the value of the property, or `default_value` if it is not set or
 *          not a Pointer property.
 *
 * \threadsafety It is safe to call this function from any thread, although
 *               the data returned is not protected and could potentially be
 *               freed if you call SDL_SetPointerProperty() or
 *               SDL_ClearProperty() on these properties from another thread.
 *               If you need to avoid this, use SDL_LockProperties() and
 *               SDL_UnlockProperties().
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetBooleanProperty
 * \sa SDL_GetFloatProperty
 * \sa SDL_GetNumberProperty
 * \sa SDL_GetPropertyType
 * \sa SDL_GetStringProperty
 * \sa SDL_HasProperty
 * \sa SDL_SetPointerProperty
  }
function SDL_GetPointerProperty(props: TSDL_PropertiesID; name: PAnsiChar; default_value: Pointer): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPointerProperty' {$ENDIF} {$ENDIF};

{*
 * Get a string property from a group of properties.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \param default_value the default value of the property.
 * \returns the value of the property, or `default_value` if it is not set or
 *          not a string property.
 *
 * \threadsafety It is safe to call this function from any thread, although
 *               the data returned is not protected and could potentially be
 *               freed if you call SDL_SetStringProperty() or
 *               SDL_ClearProperty() on these properties from another thread.
 *               If you need to avoid this, use SDL_LockProperties() and
 *               SDL_UnlockProperties().
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPropertyType
 * \sa SDL_HasProperty
 * \sa SDL_SetStringProperty
  }
function SDL_GetStringProperty(props: TSDL_PropertiesID; name: PAnsiChar; default_value: PAnsiChar): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetStringProperty' {$ENDIF} {$ENDIF};

{*
 * Get a number property from a group of properties.
 *
 * You can use SDL_GetPropertyType() to query whether the property exists and
 * is a number property.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \param default_value the default value of the property.
 * \returns the value of the property, or `default_value` if it is not set or
 *          not a number property.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPropertyType
 * \sa SDL_HasProperty
 * \sa SDL_SetNumberProperty
  }
function SDL_GetNumberProperty(props: TSDL_PropertiesID; name: PAnsiChar; default_value: cint64): cint64; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumberProperty' {$ENDIF} {$ENDIF};

{*
 * Get a floating point property from a group of properties.
 *
 * You can use SDL_GetPropertyType() to query whether the property exists and
 * is a floating point property.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \param default_value the default value of the property.
 * \returns the value of the property, or `default_value` if it is not set or
 *          not a float property.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPropertyType
 * \sa SDL_HasProperty
 * \sa SDL_SetFloatProperty
  }
function SDL_GetFloatProperty(props: TSDL_PropertiesID; name: PAnsiChar; default_value: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetFloatProperty' {$ENDIF} {$ENDIF};

{*
 * Get a boolean property from a group of properties.
 *
 * You can use SDL_GetPropertyType() to query whether the property exists and
 * is a boolean property.
 *
 * \param props the properties to query.
 * \param name the name of the property to query.
 * \param default_value the default value of the property.
 * \returns the value of the property, or `default_value` if it is not set or
 *          not a boolean property.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPropertyType
 * \sa SDL_HasProperty
 * \sa SDL_SetBooleanProperty
  }
function SDL_GetBooleanProperty(props: TSDL_PropertiesID; name: PAnsiChar; default_value: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetBooleanProperty' {$ENDIF} {$ENDIF};

{*
 * Clear a property from a group of properties.
 *
 * \param props the properties to modify.
 * \param name the name of the property to clear.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ClearProperty(props: TSDL_PropertiesID; name: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ClearProperty' {$ENDIF} {$ENDIF};

{*
 * A callback used to enumerate all the properties in a group of properties.
 *
 * This callback is called from SDL_EnumerateProperties(), and is called once
 * per property in the set.
 *
 * \param userdata an app-defined Pointer passed to the callback.
 * \param props the SDL_PropertiesID that is being enumerated.
 * \param name the next property name in the enumeration.
 *
 * \threadsafety SDL_EnumerateProperties holds a lock on `props` during this
 *               callback.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_EnumerateProperties
  }
type
  TSDL_EnumeratePropertiesCallback = procedure (userdata: Pointer; props: TSDL_PropertiesID; name: PAnsiChar); cdecl;

{*
 * Enumerate the properties contained in a group of properties.
 *
 * The callback function is called for each property in the group of
 * properties. The properties are locked during enumeration.
 *
 * \param props the properties to query.
 * \param callback the function to call for each property.
 * \param userdata a Pointer that is passed to `callback`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_EnumerateProperties(props: TSDL_PropertiesID; callback: TSDL_EnumeratePropertiesCallback; userdata: Pointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EnumerateProperties' {$ENDIF} {$ENDIF};

{*
 * Destroy a group of properties.
 *
 * All properties are deleted and their cleanup functions will be called, if
 * any.
 *
 * \param props the properties to destroy.
 *
 * \threadsafety This function should not be called while these properties are
 *               locked or other threads might be setting or getting values
 *               from these properties.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProperties
  }
procedure SDL_DestroyProperties(props: TSDL_PropertiesID); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyProperties' {$ENDIF} {$ENDIF};
