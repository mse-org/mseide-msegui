{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryStorage
 *
 * The storage API is a high-level API designed to abstract away the
 * portability issues that come up when using something lower-level (in SDL's
 * case, this sits on top of the [Filesystem](CategoryFilesystem) and
 * [IOStream](CategoryIOStream) subsystems). It is significantly more
 * restrictive than a typical filesystem API, for a number of reasons:
 *
 * 1. **What to Access:** A common pitfall with existing filesystem APIs is
 * the assumption that all storage is monolithic. However, many other
 * platforms (game consoles in particular) are more strict about what _type_
 * of filesystem is being accessed; for example, game content and user data
 * are usually two separate storage devices with entirely different
 * characteristics (and possibly different low-level APIs altogether!).
 *
 * 2. **How to Access:** Another common mistake is applications assuming that
 * all storage is universally writeable - again, many platforms treat game
 * content and user data as two separate storage devices, and only user data
 * is writeable while game content is read-only.
 *
 * 3. **When to Access:** The most common portability issue with filesystem
 * access is _timing_ - you cannot always assume that the storage device is
 * always accessible all of the time, nor can you assume that there are no
 * limits to how long you have access to a particular device.
 *
 * Consider the following example:
 *
 * ```c
 * void ReadGameData(void)
 *
 *     extern char** fileNames;
 *     extern size_t numFiles;
 *     for (size_t i = 0; i < numFiles; i += 1)
 *         FILE *data = fopen(fileNames[i], "rwb");
 *         if (data == nil)
 *             // Something bad happened!
 *          else
 *             // A bunch of stuff happens here
 *             fclose(data);
 *
 *
 *
 *
 * void ReadSave(void)
 *
 *     FILE *save = fopen("saves/save0.sav", "rb");
 *     if (save == nil)
 *         // Something bad happened!
 *      else
 *         // A bunch of stuff happens here
 *         fclose(save);
 *
 *
 *
 * void WriteSave(void)
 *
 *     FILE *save = fopen("saves/save0.sav", "wb");
 *     if (save == nil)
 *         // Something bad happened!
 *      else
 *         // A bunch of stuff happens here
 *         fclose(save);
 *
 *
 * ```
 *
 * Going over the bullet points again:
 *
 * 1. **What to Access:** This code accesses a global filesystem; game data
 * and saves are all presumed to be in the current working directory (which
 * may or may not be the game's installation folder!).
 *
 * 2. **How to Access:** This code assumes that content paths are writeable,
 * and that save data is also writeable despite being in the same location as
 * the game data.
 *
 * 3. **When to Access:** This code assumes that they can be called at any
 * time, since the filesystem is always accessible and has no limits on how
 * long the filesystem is being accessed.
 *
 * Due to these assumptions, the filesystem code is not portable and will fail
 * under these common scenarios:
 *
 * - The game is installed on a device that is read-only, both content loading
 *   and game saves will fail or crash outright
 * - Game/User storage is not implicitly mounted, so no files will be found
 *   for either scenario when a platform requires explicitly mounting
 *   filesystems
 * - Save data may not be safe since the I/O is not being flushed or
 *   validated, so an error occurring elsewhere in the program may result in
 *   missing/corrupted save data
 *
 * When using SDL_Storage, these types of problems are virtually impossible to
 * trip over:
 *
 * ```c
 * void ReadGameData(void)
 *
 *     extern char** fileNames;
 *     extern size_t numFiles;
 *
 *     SDL_Storage *title = SDL_OpenTitleStorage(nil, 0);
 *     if (title == nil)
 *         // Something bad happened!
 *
 *     while (!SDL_StorageReady(title))
 *         SDL_Delay(1);
 *
 *
 *     for (size_t i = 0; i < numFiles; i += 1)
 *         void* dst;
 *         Uint64 dstLen = 0;
 *
 *         if (SDL_GetStorageFileSize(title, fileNames[i], &dstLen) && dstLen > 0)
 *             dst = SDL_malloc(dstLen);
 *             if (SDL_ReadStorageFile(title, fileNames[i], dst, dstLen))
 *                 // A bunch of stuff happens here
 *              else
 *                 // Something bad happened!
 *
 *             SDL_free(dst);
 *          else
 *             // Something bad happened!
 *
 *
 *
 *     SDL_CloseStorage(title);
 *
 *
 * void ReadSave(void)
 *
 *     SDL_Storage *user = SDL_OpenUserStorage("libsdl", "Storage Example", 0);
 *     if (user == nil)
 *         // Something bad happened!
 *
 *     while (!SDL_StorageReady(user))
 *         SDL_Delay(1);
 *
 *
 *     Uint64 saveLen = 0;
 *     if (SDL_GetStorageFileSize(user, "save0.sav", &saveLen) && saveLen > 0)
 *         void* dst = SDL_malloc(saveLen);
 *         if (SDL_ReadStorageFile(user, "save0.sav", dst, saveLen))
 *             // A bunch of stuff happens here
 *          else
 *             // Something bad happened!
 *
 *         SDL_free(dst);
 *      else
 *         // Something bad happened!
 *
 *
 *     SDL_CloseStorage(user);
 *
 *
 * void WriteSave(void)
 *
 *     SDL_Storage *user = SDL_OpenUserStorage("libsdl", "Storage Example", 0);
 *     if (user == nil)
 *         // Something bad happened!
 *
 *     while (!SDL_StorageReady(user))
 *         SDL_Delay(1);
 *
 *
 *     extern void *saveData; // A bunch of stuff happened here...
 *     extern Uint64 saveLen;
 *     if (!SDL_WriteStorageFile(user, "save0.sav", saveData, saveLen))
 *         // Something bad happened!
 *
 *
 *     SDL_CloseStorage(user);
 *
 * ```
 *
 * Note the improvements that SDL_Storage makes:
 *
 * 1. **What to Access:** This code explicitly reads from a title or user
 * storage device based on the context of the function.
 *
 * 2. **How to Access:** This code explicitly uses either a read or write
 * function based on the context of the function.
 *
 * 3. **When to Access:** This code explicitly opens the device when it needs
 * to, and closes it when it is finished working with the filesystem.
 *
 * The result is an application that is significantly more robust against the
 * increasing demands of platforms and their filesystems!
 *
 * A publicly available example of an SDL_Storage backend is the
 * [Steam Cloud](https://partner.steamgames.com/doc/features/cloud)
 * backend - you can initialize Steamworks when starting the program, and then
 * SDL will recognize that Steamworks is initialized and automatically use
 * ISteamRemoteStorage when the application opens user storage. More
 * importantly, when you _open_ storage it knows to begin a "batch" of
 * filesystem operations, and when you _close_ storage it knows to end and
 * flush the batch. This is used by Steam to support
 * [Dynamic Cloud Sync](https://steamcommunity.com/groups/steamworks/announcements/detail/3142949576401813670)
 * ; users can save data on one PC, put the device to sleep, and then continue
 * playing on another PC (and vice versa) with the save data fully
 * synchronized across all devices, allowing for a seamless experience without
 * having to do full restarts of the program.
 *
 * ## Notes on valid paths
 *
 * All paths in the Storage API use Unix-style path separators ('/'). Using a
 * different path separator will not work, even if the underlying platform
 * would otherwise accept it. This is to keep code using the Storage API
 * portable between platforms and Storage implementations and simplify app
 * code.
 *
 * Paths with relative directories ("." and "..") are forbidden by the Storage
 * API.
 *
 * All valid UTF-8 strings (discounting the nil terminator character and the
 * '/' path separator) are usable for filenames, however, an underlying
 * Storage implementation may not support particularly strange sequences and
 * refuse to create files with those names, etc.
  }

{*
 * Function interface for SDL_Storage.
 *
 * Apps that want to supply a custom implementation of SDL_Storage will fill
 * in all the functions in this struct, and then pass it to SDL_OpenStorage to
 * create a custom SDL_Storage object.
 *
 * It is not usually necessary to do this; SDL provides standard
 * implementations for many things you might expect to do with an SDL_Storage.
 *
 * This structure should be initialized using SDL_INIT_INTERFACE()
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_INIT_INTERFACE
  }
type
  PPSDL_StorageInterface = ^PSDL_StorageInterface;
  PSDL_StorageInterface = ^TSDL_StorageInterface;
  TSDL_StorageInterface = record
      version: cuint32;                                                                                             { The version of this interface  }
      close: function(userdata: Pointer): Boolean; cdecl;                                                             { Called when the storage is closed  }
      ready: function(userdata: Pointer): Boolean; cdecl;                                                             { Optional, returns whether the storage is currently ready for access  }
      enumerate: function(userdata: Pointer; path: PAnsiChar; callback: TSDL_EnumerateDirectoryCallback;            { Enumerate a directory, optional for write-only storage  }
                          callback_userdata: Pointer): Boolean; cdecl;
      info: function(userdata: Pointer; path: PAnsiChar; info: PSDL_PathInfo): Boolean; cdecl;                        { Get path information, optional for write-only storage  }
      read_file: function(userdata: Pointer; path: PAnsiChar; destination: Pointer; length: cuint64): Boolean; cdecl; { Read a file from storage, optional for write-only storage  }
      write_file: function(userdata: Pointer; path: PAnsiChar; source: Pointer; length: cuint64): Boolean; cdecl;     { Write a file to storage, optional for read-only storage  }
      mkdir: function(userdata: Pointer; path: PAnsiChar): Boolean; cdecl;                                            { Create a directory, optional for read-only storage  }
      remove: function(userdata: Pointer; path: PAnsiChar): Boolean; cdecl;                                           { Remove a file or empty directory, optional for read-only storage  }
      rename: function(userdata: Pointer; oldpath: PAnsiChar; newpath: PAnsiChar): Boolean; cdecl;                    { Rename a path, optional for read-only storage  }
      copy: function(userdata: Pointer; oldpath: PAnsiChar; newpath: PAnsiChar): Boolean; cdecl;                      { Copy a file, optional for read-only storage  }
      space_remaining: function(userdata: Pointer): cuint64; cdecl;                                                 { Get the space remaining, optional for read-only storage  }
    end;

{ Check the size of SDL_StorageInterface
 *
 * If this assert fails, either the compiler is padding to an unexpected size,
 * or the interface has been updated and this should be updated to match and
 * the code using this interface should be updated to handle the old version.
  }
{ #todo : SDL3-for-Pascal: Implement

C:
SDL_COMPILE_TIME_ASSERT(SDL_StorageInterface_SIZE,
    (sizeof(void *) == 4 && sizeof(SDL_StorageInterface) == 48) ||
    (sizeof(void *) == 8 && sizeof(SDL_StorageInterface) == 96)); }

{*
 * An abstract interface for filesystem access.
 *
 * This is an opaque datatype. One can create this object using standard SDL
 * functions like SDL_OpenTitleStorage or SDL_OpenUserStorage, etc, or create
 * an object with a custom implementation using SDL_OpenStorage.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_Storage = ^PSDL_Storage;
  PSDL_Storage = type Pointer;

{*
 * Opens up a read-only container for the application's filesystem.
 *
 * By default, SDL_OpenTitleStorage uses the generic storage implementation.
 * When the path override is not provided, the generic implementation will use
 * the output of SDL_GetBasePath as the base path.
 *
 * \param override a path to override the backend's default title root.
 * \param props a property list that may contain backend-specific information.
 * \returns a title storage container on success or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseStorage
 * \sa SDL_GetStorageFileSize
 * \sa SDL_OpenUserStorage
 * \sa SDL_ReadStorageFile
  }
function SDL_OpenTitleStorage(override: PAnsiChar; props: TSDL_PropertiesID): PSDL_Storage; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenTitleStorage' {$ENDIF} {$ENDIF};

{*
 * Opens up a container for a user's unique read/write filesystem.
 *
 * While title storage can generally be kept open throughout runtime, user
 * storage should only be opened when the client is ready to read/write files.
 * This allows the backend to properly batch file operations and flush them
 * when the container has been closed; ensuring safe and optimal save I/O.
 *
 * \param org the name of your organization.
 * \param app the name of your application.
 * \param props a property list that may contain backend-specific information.
 * \returns a user storage container on success or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseStorage
 * \sa SDL_GetStorageFileSize
 * \sa SDL_GetStorageSpaceRemaining
 * \sa SDL_OpenTitleStorage
 * \sa SDL_ReadStorageFile
 * \sa SDL_StorageReady
 * \sa SDL_WriteStorageFile
  }
function SDL_OpenUserStorage(org: PAnsiChar; app: PAnsiChar; props: TSDL_PropertiesID): PSDL_Storage; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenUserStorage' {$ENDIF} {$ENDIF};

{*
 * Opens up a container for local filesystem storage.
 *
 * This is provided for development and tools. Portable applications should
 * use SDL_OpenTitleStorage() for access to game data and
 * SDL_OpenUserStorage() for access to user data.
 *
 * \param path the base path prepended to all storage paths, or nil for no
 *             base path.
 * \returns a filesystem storage container on success or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseStorage
 * \sa SDL_GetStorageFileSize
 * \sa SDL_GetStorageSpaceRemaining
 * \sa SDL_OpenTitleStorage
 * \sa SDL_OpenUserStorage
 * \sa SDL_ReadStorageFile
 * \sa SDL_WriteStorageFile
  }
function SDL_OpenFileStorage(path: PAnsiChar): PSDL_Storage; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenFileStorage' {$ENDIF} {$ENDIF};

{*
 * Opens up a container using a client-provided storage interface.
 *
 * Applications do not need to use this function unless they are providing
 * their own SDL_Storage implementation. If you just need an SDL_Storage, you
 * should use the built-in implementations in SDL, like SDL_OpenTitleStorage()
 * or SDL_OpenUserStorage().
 *
 * This function makes a copy of `iface` and the caller does not need to keep
 * it around after this call.
 *
 * \param iface the interface that implements this storage, initialized using
 *              SDL_INIT_INTERFACE().
 * \param userdata the Pointer that will be passed to the interface functions.
 * \returns a storage container on success or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseStorage
 * \sa SDL_GetStorageFileSize
 * \sa SDL_GetStorageSpaceRemaining
 * \sa SDL_INIT_INTERFACE
 * \sa SDL_ReadStorageFile
 * \sa SDL_StorageReady
 * \sa SDL_WriteStorageFile
  }
function SDL_OpenStorage(iface: PSDL_StorageInterface; userdata: Pointer): PSDL_Storage; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenStorage' {$ENDIF} {$ENDIF};

{*
 * Closes and frees a storage container.
 *
 * \param storage a storage container to close.
 * \returns true if the container was freed with no errors, false otherwise;
 *          call SDL_GetError() for more information. Even if the function
 *          returns an error, the container data will be freed; the error is
 *          only for informational purposes.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenFileStorage
 * \sa SDL_OpenStorage
 * \sa SDL_OpenTitleStorage
 * \sa SDL_OpenUserStorage
  }
function SDL_CloseStorage(storage: PSDL_Storage): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CloseStorage' {$ENDIF} {$ENDIF};

{*
 * Checks if the storage container is ready to use.
 *
 * This function should be called in regular intervals until it returns true -
 * however, it is not recommended to spinwait on this call, as the backend may
 * depend on a synchronous message loop. You might instead poll this in your
 * game's main loop while processing events and drawing a loading screen.
 *
 * \param storage a storage container to query.
 * \returns true if the container is ready, false otherwise.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_StorageReady(storage: PSDL_Storage): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_StorageReady' {$ENDIF} {$ENDIF};

{*
 * Query the size of a file within a storage container.
 *
 * \param storage a storage container to query.
 * \param path the relative path of the file to query.
 * \param length a Pointer to be filled with the file's length.
 * \returns true if the file could be queried or false on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ReadStorageFile
 * \sa SDL_StorageReady
  }
function SDL_GetStorageFileSize(storage: PSDL_Storage; path: PAnsiChar; length: pcuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetStorageFileSize' {$ENDIF} {$ENDIF};

{*
 * Synchronously read a file from a storage container into a client-provided
 * buffer.
 *
 * The value of `length` must match the length of the file exactly; call
 * SDL_GetStorageFileSize() to get this value. This behavior may be relaxed in
 * a future release.
 *
 * \param storage a storage container to read from.
 * \param path the relative path of the file to read.
 * \param destination a client-provided buffer to read the file into.
 * \param length the length of the destination buffer.
 * \returns true if the file was read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetStorageFileSize
 * \sa SDL_StorageReady
 * \sa SDL_WriteStorageFile
  }
function SDL_ReadStorageFile(storage: PSDL_Storage; path: PAnsiChar; destination: Pointer; length: cuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadStorageFile' {$ENDIF} {$ENDIF};

{*
 * Synchronously write a file from client memory into a storage container.
 *
 * \param storage a storage container to write to.
 * \param path the relative path of the file to write.
 * \param source a client-provided buffer to write from.
 * \param length the length of the source buffer.
 * \returns true if the file was written or false on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetStorageSpaceRemaining
 * \sa SDL_ReadStorageFile
 * \sa SDL_StorageReady
  }
function SDL_WriteStorageFile(storage: PSDL_Storage; path: PAnsiChar; source: Pointer; length: cuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteStorageFile' {$ENDIF} {$ENDIF};

{*
 * Create a directory in a writable storage container.
 *
 * \param storage a storage container.
 * \param path the path of the directory to create.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
  }
function SDL_CreateStorageDirectory(storage: PSDL_Storage; path: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateStorageDirectory' {$ENDIF} {$ENDIF};

{*
 * Enumerate a directory in a storage container through a callback function.
 *
 * This function provides every directory entry through an app-provided
 * callback, called once for each directory entry, until all results have been
 * provided or the callback returns either SDL_ENUM_SUCCESS or
 * SDL_ENUM_FAILURE.
 *
 * This will return false if there was a system problem in general, or if a
 * callback returns SDL_ENUM_FAILURE. A successful return means a callback
 * returned SDL_ENUM_SUCCESS to halt enumeration, or all directory entries
 * were enumerated.
 *
 * If `path` is nil, this is treated as a request to enumerate the root of
 * the storage container's tree. An empty string also works for this.
 *
 * \param storage a storage container.
 * \param path the path of the directory to enumerate, or nil for the root.
 * \param callback a function that is called for each entry in the directory.
 * \param userdata a Pointer that is passed to `callback`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
  }
function SDL_EnumerateStorageDirectory(storage: PSDL_Storage; path: PAnsiChar; callback: TSDL_EnumerateDirectoryCallback; userdata: Pointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EnumerateStorageDirectory' {$ENDIF} {$ENDIF};

{*
 * Remove a file or an empty directory in a writable storage container.
 *
 * \param storage a storage container.
 * \param path the path to remove from the filesystem.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
  }
function SDL_RemoveStoragePath(storage: PSDL_Storage; path: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RemoveStoragePath' {$ENDIF} {$ENDIF};

{*
 * Rename a file or directory in a writable storage container.
 *
 * \param storage a storage container.
 * \param oldpath the old path.
 * \param newpath the new path.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
  }
function SDL_RenameStoragePath(storage: PSDL_Storage; oldpath: PAnsiChar; newpath: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RenameStoragePath' {$ENDIF} {$ENDIF};

{*
 * Copy a file in a writable storage container.
 *
 * \param storage a storage container.
 * \param oldpath the old path.
 * \param newpath the new path.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
  }
function SDL_CopyStorageFile(storage: PSDL_Storage; oldpath: PAnsiChar; newpath: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CopyStorageFile' {$ENDIF} {$ENDIF};

{*
 * Get information about a filesystem path in a storage container.
 *
 * \param storage a storage container.
 * \param path the path to query.
 * \param info a Pointer filled in with information about the path, or nil to
 *             check for the existence of a file.
 * \returns true on success or false if the file doesn't exist, or another
 *          failure; call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
  }
function SDL_GetStoragePathInfo(storage: PSDL_Storage; path: PAnsiChar; info: PSDL_PathInfo): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetStoragePathInfo' {$ENDIF} {$ENDIF};

{*
 * Queries the remaining space in a storage container.
 *
 * \param storage a storage container to query.
 * \returns the amount of remaining space, in bytes.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StorageReady
 * \sa SDL_WriteStorageFile
  }
function SDL_GetStorageSpaceRemaining(storage: PSDL_Storage): cuint64; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetStorageSpaceRemaining' {$ENDIF} {$ENDIF};

{*
 * Enumerate a directory tree, filtered by pattern, and return a list.
 *
 * Files are filtered out if they don't match the string in `pattern`, which
 * may contain wildcard characters `*` (match everything) and `?` (match one
 * character). If pattern is NULL, no filtering is done and all results are
 * returned. Subdirectories are permitted, and are specified with a path
 * separator of '/'. Wildcard characters `*` and `?` never match a path
 * separator.
 *
 * `flags` may be set to SDL_GLOB_CASEINSENSITIVE to make the pattern matching
 * case-insensitive.
 *
 * The returned array is always nil-terminated, for your iterating
 * convenience, but if `count` is non-nil, on return it will contain the
 * number of items in the array, not counting the nil terminator.
 *
 * If `path` is nil, this is treated as a request to enumerate the root of
 * the storage container's tree. An empty string also works for this.
 *
 * \param storage a storage container.
 * \param path the path of the directory to enumerate, or nil for the root.
 * \param pattern the pattern that files in the directory must match. Can be
 *                nil.
 * \param flags `SDL_GLOB_*` bitflags that affect this search.
 * \param count on return, will be set to the number of items in the returned
 *              array. Can be nil.
 * \returns an array of strings on success or nil on failure; call
 *          SDL_GetError() for more information. The caller should pass the
 *          returned Pointer to SDL_free when done with it. This is a single
 *          allocation that should be freed with SDL_free() when it is no
 *          longer needed.
 *
 * \threadsafety It is safe to call this function from any thread, assuming
 *               the `storage` object is thread-safe.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GlobStorageDirectory(storage: PSDL_Storage; path: PAnsiChar; pattern: PAnsiChar; flags: TSDL_GlobFlags; count: pcint):PPAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GlobStorageDirectory' {$ENDIF} {$ENDIF};

