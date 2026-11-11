{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryIOStream
 *
 * SDL provides an abstract interface for reading and writing data streams. It
 * offers implementations for files, memory, etc, and the app can provide
 * their own implementations, too.
 *
 * SDL_IOStream is not related to the standard C++ iostream class, other than
 * both are abstract interfaces to read/write data.
  }

{*
 * SDL_IOStream status, set by a read or write operation.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_IOStatus = ^PSDL_IOStatus;
  PSDL_IOStatus = ^TSDL_IOStatus;
  TSDL_IOStatus = type Integer;
const
  SDL_IO_STATUS_READY  = TSDL_IOStatus(0);     {*< Everything is ready (no errors and not EOF).  }
  SDL_IO_STATUS_ERROR  = TSDL_IOStatus(1);     {*< Read or write I/O error  }
  SDL_IO_STATUS_EOF  = TSDL_IOStatus(2);       {*< End of file  }
  SDL_IO_STATUS_NOT_READY  = TSDL_IOStatus(3); {*< Non blocking I/O, not ready  }
  SDL_IO_STATUS_READONLY  = TSDL_IOStatus(4);  {*< Tried to write a read-only buffer  }
  SDL_IO_STATUS_WRITEONLY  = TSDL_IOStatus(5); {*< Tried to read a write-only buffer  }

{*
 * Possible `whence` values for SDL_IOStream seeking.
 *
 * These map to the same "whence" concept that `fseek` or `lseek` use in the
 * standard C runtime.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_IOWhence = ^PSDL_IOWhence;
  PSDL_IOWhence = ^TSDL_IOWhence;
  TSDL_IOWhence = type Integer;
const
  SDL_IO_SEEK_SET  = TSDL_IOWhence(0); {*< Seek from the beginning of data  }
  SDL_IO_SEEK_CUR  = TSDL_IOWhence(1); {*< Seek relative to current read point  }
  SDL_IO_SEEK_END  = TSDL_IOWhence(2); {*< Seek relative to the end of data  }

{*
 * The function pointers that drive an SDL_IOStream.
 *
 * Applications can provide this struct to SDL_OpenIO() to create their own
 * implementation of SDL_IOStream. This is not necessarily required, as SDL
 * already offers several common types of I/O streams, via functions like
 * SDL_IOFromFile() and SDL_IOFromMem().
 *
 * This structure should be initialized using SDL_INIT_INTERFACE()
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_INIT_INTERFACE
  }
type
  PPSDL_IOStreamInterface = ^PSDL_IOStreamInterface;
  PSDL_IOStreamInterface = ^TSDL_IOStreamInterface;
  TSDL_IOStreamInterface = record
    { The version of this interface  }
    version: cuint32;

      {*
       *  Return the number of bytes in this SDL_IOStream
       *
       *  \return the total size of the data stream, or -1 on error.
        }
      size: function (userdata: Pointer): cint64; cdecl;

      {*
       *  Seek to `offset` relative to `whence`, one of stdio's whence values:
       *  SDL_IO_SEEK_SET, SDL_IO_SEEK_CUR, SDL_IO_SEEK_END
       *
       *  \return the final offset in the data stream, or -1 on error.
        }
      seek: function (userdata: Pointer; offset: cint64; whence: TSDL_IOWhence): cint64; cdecl;

      {*
       *  Read up to `size` bytes from the data stream to the area pointed
       *  at by `ptr`. `size` will always be > 0.
       *
       *  On an incomplete read, you should set `*status` to a value from the
       *  SDL_IOStatus enum. You do not have to explicitly set this on
       *  a complete, successful read.
       *
       *  \return the number of bytes read
        }
      read: function (userdata: Pointer; ptr: Pointer; size: csize_t; status: PSDL_IOStatus): csize_t; cdecl;

      {*
       *  Write exactly `size` bytes from the area pointed at by `ptr`
       *  to data stream. `size` will always be > 0.
       *
       *  On an incomplete write, you should set `*status` to a value from the
       *  SDL_IOStatus enum. You do not have to explicitly set this on
       *  a complete, successful write.
       *
       *  \return the number of bytes written
        }
      write: function (userdata: Pointer; ptr: Pointer; size: csize_t; status: PSDL_IOStatus): csize_t; cdecl;

      {*
       *  If the stream is buffering, make sure the data is written out.
       *
       *  On failure, you should set `*status` to a value from the
       *  SDL_IOStatus enum. You do not have to explicitly set this on
       *  a successful flush.
       *
       *  \return true if successful or false on write error when flushing data.
        }
      flush: function (userdata: Pointer; status: PSDL_IOStatus): Boolean; cdecl;

      {*
       *  Close and free any allocated resources.
       *
       *  This does not guarantee file writes will sync to physical media; they
       *  can be in the system's file cache, waiting to go to disk.
       *
       *  The SDL_IOStream is still destroyed even if this fails, so clean up anything
       *  even if flushing buffers, etc, returns an error.
       *
       *  \return true if successful or false on write error when flushing data.
        }
      close: function (userdata: Pointer): Boolean; cdecl;
    end;

{ Check the size of SDL_IOStreamInterface
 *
 * If this assert fails, either the compiler is padding to an unexpected size,
 * or the interface has been updated and this should be updated to match and
 * the code using this interface should be updated to handle the old version.
  }
{
#todo : SDL3-for-Pascal: Implement macro:
SDL_COMPILE_TIME_ASSERT(SDL_IOStreamInterface_SIZE, ... }

{*
 * The read/write operation structure.
 *
 * This operates as an opaque handle. There are several APIs to create various
 * types of I/O streams, or an app can supply an SDL_IOStreamInterface to
 * SDL_OpenIO() to provide their own stream implementation behind this
 * struct's abstract interface.
 *
 * \since This struct is available since SDL 3.1.3.
  }
type
  PPSDL_IOStream = ^PSDL_IOStream;
  PSDL_IOStream = type Pointer;

{*
 *  \name IOFrom functions
 *
 *  Functions to create SDL_IOStream structures from various data streams.
  }

{*
 * Use this function to create a new SDL_IOStream structure for reading from
 * and/or writing to a named file.
 *
 * The `mode` string is treated roughly the same as in a call to the C
 * library's fopen(), even if SDL doesn't happen to use fopen() behind the
 * scenes.
 *
 * Available `mode` strings:
 *
 * - "r": Open a file for reading. The file must exist.
 * - "w": Create an empty file for writing. If a file with the same name
 *   already exists its content is erased and the file is treated as a new
 *   empty file.
 * - "wx": Create an empty file for writing. If a file with the same name
 *   already exists, the call fails.
 * - "a": Append to a file. Writing operations append data at the end of the
 *   file. The file is created if it does not exist.
 * - "r+": Open a file for update both reading and writing. The file must
 *   exist.
 * - "w+": Create an empty file for both reading and writing. If a file with
 *   the same name already exists its content is erased and the file is
 *   treated as a new empty file.
 * - "w+x": Create an empty file for both reading and writing. If a file with
 *   the same name already exists, the call fails.
 * - "a+": Open a file for reading and appending. All writing operations are
 *   performed at the end of the file, protecting the previous content to be
 *   overwritten. You can reposition (fseek, rewind) the internal Pointer to
 *   anywhere in the file for reading, but writing operations will move it
 *   back to the end of file. The file is created if it does not exist.
 *
 * **NOTE**: In order to open a file as a binary file, a "b" character has to
 * be included in the `mode` string. This additional "b" character can either
 * be appended at the end of the string (thus making the following compound
 * modes: "rb", "wb", "ab", "r+b", "w+b", "a+b") or be inserted between the
 * letter and the "+" sign for the mixed modes ("rb+", "wb+", "ab+").
 * Additional characters may follow the sequence, although they should have no
 * effect. For example, "t" is sometimes appended to make explicit the file is
 * a text file.
 *
 * This function supports Unicode filenames, but they must be encoded in UTF-8
 * format, regardless of the underlying operating system.
 *
 * In Android, SDL_IOFromFile() can be used to open content:// URIs. As a
 * fallback, SDL_IOFromFile() will transparently open a matching filename in
 * the app's `assets`.
 *
 * Closing the SDL_IOStream will close SDL's internal file handle.
 *
 * The following properties may be set at creation time by SDL:
 *
 * - `SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER`: a Pointer, that can be cast
 *   to a win32 `HANDLE`, that this SDL_IOStream is using to access the
 *   filesystem. If the program isn't running on Windows, or SDL used some
 *   other method to access the filesystem, this property will not be set.
 * - `SDL_PROP_IOSTREAM_STDIO_FILE_POINTER`: a Pointer, that can be cast to a
 *   stdio `FILE *`, that this SDL_IOStream is using to access the filesystem.
 *   If SDL used some other method to access the filesystem, this property
 *   will not be set. PLEASE NOTE that if SDL is using a different C runtime
 *   than your app, trying to use this Pointer will almost certainly result in
 *   a crash! This is mostly a problem on Windows; make sure you build SDL and
 *   your app with the same compiler and settings to avoid it.
 * - `SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER`: a file descriptor that this
 *   SDL_IOStream is using to access the filesystem.
 * - `SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER`: a Pointer, that can be cast
 *   to an Android NDK `AAsset *`, that this SDL_IOStream is using to access
 *   the filesystem. If SDL used some other method to access the filesystem,
 *   this property will not be set.
 *
 * \param file a UTF-8 string representing the filename to open.
 * \param mode an ASCII string representing the mode to be used for opening
 *             the file.
 * \returns a Pointer to the SDL_IOStream structure that is created or nil on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseIO
 * \sa SDL_FlushIO
 * \sa SDL_ReadIO
 * \sa SDL_SeekIO
 * \sa SDL_TellIO
 * \sa SDL_WriteIO
  }
function SDL_IOFromFile(file_: PAnsiChar; mode: PAnsiChar): PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IOFromFile' {$ENDIF} {$ENDIF};

  const
  SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER = 'SDL.iostream.windows.handle';
  SDL_PROP_IOSTREAM_STDIO_FILE_POINTER = 'SDL.iostream.stdio.file';
  SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER = 'SDL.iostream.file_descriptor';
  SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER = 'SDL.iostream.android.aasset';

{*
 * Use this function to prepare a read-write memory buffer for use with
 * SDL_IOStream.
 *
 * This function sets up an SDL_IOStream struct based on a memory area of a
 * certain size, for both read and write access.
 *
 * This memory buffer is not copied by the SDL_IOStream; the pointer you
 * provide must remain valid until you close the stream.
 *
 * If you need to make sure the SDL_IOStream never writes to the memory
 * buffer, you should use SDL_IOFromConstMem() with a read-only buffer of
 * memory instead.
 *
 * The following properties will be set at creation time by SDL:
 *
 * - `SDL_PROP_IOSTREAM_MEMORY_POINTER`: this will be the `mem` parameter that
 *   was passed to this function.
 * - `SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER`: this will be the `size` parameter
 *   that was passed to this function.
 *
 * Additionally, the following properties are recognized:
 *
 * - `SDL_PROP_IOSTREAM_MEMORY_FREE_FUNC_POINTER`: if this property is set to
 *   a non-NULL value it will be interpreted as a function of SDL_free_func
 *   type and called with the passed `mem` pointer when closing the stream. By
 *   default it is unset, i.e., the memory will not be freed.
 *
 * \param mem a Pointer to a buffer to feed an SDL_IOStream stream.
 * \param size the buffer size, in bytes.
 * \returns a Pointer to a new SDL_IOStream structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_IOFromConstMem
 * \sa SDL_CloseIO
 * \sa SDL_FlushIO
 * \sa SDL_ReadIO
 * \sa SDL_SeekIO
 * \sa SDL_TellIO
 * \sa SDL_WriteIO
  }
function SDL_IOFromMem(mem: Pointer; size: csize_t): PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IOFromMem' {$ENDIF} {$ENDIF};

const
  SDL_PROP_IOSTREAM_MEMORY_POINTER = 'SDL.iostream.memory.base';
  SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER = 'SDL.iostream.memory.size';
  SDL_PROP_IOSTREAM_MEMORY_FREE_FUNC_POINTER = 'SDL.iostream.memory.free';

{*
 * Use this function to prepare a read-only memory buffer for use with
 * SDL_IOStream.
 *
 * This function sets up an SDL_IOStream struct based on a memory area of a
 * certain size. It assumes the memory area is not writable.
 *
 * Attempting to write to this SDL_IOStream stream will report an error
 * without writing to the memory buffer.
 *
 * This memory buffer is not copied by the SDL_IOStream; the pointer you
 * provide must remain valid until you close the stream.
 *
 * If you need to write to a memory buffer, you should use SDL_IOFromMem()
 * with a writable buffer of memory instead.
 *
 * The following properties will be set at creation time by SDL:
 *
 * - `SDL_PROP_IOSTREAM_MEMORY_POINTER`: this will be the `mem` parameter that
 *   was passed to this function.
 * - `SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER`: this will be the `size` parameter
 *   that was passed to this function.
 *
 * Additionally, the following properties are recognized:
 *
 * - `SDL_PROP_IOSTREAM_MEMORY_FREE_FUNC_POINTER`: if this property is set to
 *   a non-NULL value it will be interpreted as a function of SDL_free_func
 *   type and called with the passed `mem` pointer when closing the stream. By
 *   default it is unset, i.e., the memory will not be freed.
 *
 * \param mem a Pointer to a read-only buffer to feed an SDL_IOStream stream.
 * \param size the buffer size, in bytes.
 * \returns a Pointer to a new SDL_IOStream structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_IOFromMem
 * \sa SDL_CloseIO
 * \sa SDL_ReadIO
 * \sa SDL_SeekIO
 * \sa SDL_TellIO
  }
function SDL_IOFromConstMem(mem: Pointer; size: csize_t): PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IOFromConstMem' {$ENDIF} {$ENDIF};

{*
 * Use this function to create an SDL_IOStream that is backed by dynamically
 * allocated memory.
 *
 * This supports the following properties to provide access to the memory and
 * control over allocations:
 *
 * - `SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER`: a Pointer to the internal
 *   memory of the stream. This can be set to nil to transfer ownership of
 *   the memory to the application, which should free the memory with
 *   SDL_free(). If this is done, the next operation on the stream must be
 *   SDL_CloseIO().
 * - `SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER`: memory will be allocated in
 *   multiples of this size, defaulting to 1024.
 *
 * \returns a Pointer to a new SDL_IOStream structure or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseIO
 * \sa SDL_ReadIO
 * \sa SDL_SeekIO
 * \sa SDL_TellIO
 * \sa SDL_WriteIO
  }
function SDL_IOFromDynamicMem: PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IOFromDynamicMem' {$ENDIF} {$ENDIF};

const
  SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER = 'SDL.iostream.dynamic.memory';
  SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER = 'SDL.iostream.dynamic.chunksize';

{ IOFrom functions  }

{*
 * Create a custom SDL_IOStream.
 *
 * Applications do not need to use this function unless they are providing
 * their own SDL_IOStream implementation. If you just need an SDL_IOStream to
 * read/write a common data source, you should use the built-in
 * implementations in SDL, like SDL_IOFromFile() or SDL_IOFromMem(), etc.
 *
 * This function makes a copy of `iface` and the caller does not need to keep
 * it around after this call.
 *
 * \param iface the interface that implements this SDL_IOStream, initialized
 *              using SDL_INIT_INTERFACE().
 * \param userdata the Pointer that will be passed to the interface functions.
 * \returns a Pointer to the allocated memory on success or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseIO
 * \sa SDL_INIT_INTERFACE
 * \sa SDL_IOFromConstMem
 * \sa SDL_IOFromFile
 * \sa SDL_IOFromMem
  }
function SDL_OpenIO(iface: PSDL_IOStreamInterface; userdata: Pointer): PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenIO' {$ENDIF} {$ENDIF};

{*
 * Close and free an allocated SDL_IOStream structure.
 *
 * SDL_CloseIO() closes and cleans up the SDL_IOStream stream. It releases any
 * resources used by the stream and frees the SDL_IOStream itself. This
 * returns true on success, or false if the stream failed to flush to its
 * output (e.g. to disk).
 *
 * Note that if this fails to flush the stream for any reason, this function
 * reports an error, but the SDL_IOStream is still invalid once this function
 * returns.
 *
 * This call flushes any buffered writes to the operating system, but there
 * are no guarantees that those writes have gone to physical media; they might
 * be in the OS's file cache, waiting to go to disk later. If it's absolutely
 * crucial that writes go to disk immediately, so they are definitely stored
 * even if the power fails before the file cache would have caught up, one
 * should call SDL_FlushIO() before closing. Note that flushing takes time and
 * makes the system and your app operate less efficiently, so do so sparingly.
 *
 * \param context SDL_IOStream structure to close.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenIO
  }
function SDL_CloseIO(context: PSDL_IOStream): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CloseIO' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with an SDL_IOStream.
 *
 * \param context a Pointer to an SDL_IOStream structure.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetIOProperties(context: PSDL_IOStream): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetIOProperties' {$ENDIF} {$ENDIF};

{*
 * Query the stream status of an SDL_IOStream.
 *
 * This information can be useful to decide if a short read or write was due
 * to an error, an EOF, or a non-blocking operation that isn't yet ready to
 * complete.
 *
 * An SDL_IOStream's status is only expected to change after a SDL_ReadIO or
 * SDL_WriteIO call; don't expect it to change if you just call this query
 * function in a tight loop.
 *
 * \param context the SDL_IOStream to query.
 * \returns an SDL_IOStatus enum with the current state.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetIOStatus(context: PSDL_IOStream): TSDL_IOStatus; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetIOStatus' {$ENDIF} {$ENDIF};

{*
 * Use this function to get the size of the data stream in an SDL_IOStream.
 *
 * \param context the SDL_IOStream to get the size of the data stream from.
 * \returns the size of the data stream in the SDL_IOStream on success or a
 *          negative error code on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetIOSize(context: PSDL_IOStream): cint64; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetIOSize' {$ENDIF} {$ENDIF};

{*
 * Seek within an SDL_IOStream data stream.
 *
 * This function seeks to byte `offset`, relative to `whence`.
 *
 * `whence` may be any of the following values:
 *
 * - `SDL_IO_SEEK_SET`: seek from the beginning of data
 * - `SDL_IO_SEEK_CUR`: seek relative to current read point
 * - `SDL_IO_SEEK_END`: seek relative to the end of data
 *
 * If this stream can not seek, it will return -1.
 *
 * \param context a Pointer to an SDL_IOStream structure.
 * \param offset an offset in bytes, relative to `whence` location; can be
 *               negative.
 * \param whence any of `SDL_IO_SEEK_SET`, `SDL_IO_SEEK_CUR`,
 *               `SDL_IO_SEEK_END`.
 * \returns the final offset in the data stream after the seek or -1 on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_TellIO
  }
function SDL_SeekIO(context: PSDL_IOStream; offset: cint64; whence: TSDL_IOWhence): cint64; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SeekIO' {$ENDIF} {$ENDIF};

{*
 * Determine the current read/write offset in an SDL_IOStream data stream.
 *
 * SDL_TellIO is actually a wrapper function that calls the SDL_IOStream's
 * `seek` method, with an offset of 0 bytes from `SDL_IO_SEEK_CUR`, to
 * simplify application development.
 *
 * \param context an SDL_IOStream data stream object from which to get the
 *                current offset.
 * \returns the current offset in the stream, or -1 if the information can not
 *          be determined.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SeekIO
  }
function SDL_TellIO(context: PSDL_IOStream): cint64; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_TellIO' {$ENDIF} {$ENDIF};

{*
 * Read from a data source.
 *
 * This function reads up `size` bytes from the data source to the area
 * pointed at by `ptr`. This function may read less bytes than requested.
 *
 * This function will return zero when the data stream is completely read, and
 * SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If zero is returned and
 * the stream is not at EOF, SDL_GetIOStatus() will return a different error
 * value and SDL_GetError() will offer a human-readable message.
 *
 * A request for zero bytes on a valid stream will return zero immediately
 * without accessing the stream, so the stream status (EOF, err, etc) will not
 * change.
 *
 * \param context a Pointer to an SDL_IOStream structure.
 * \param ptr a Pointer to a buffer to read data into.
 * \param size the number of bytes to read from the data source.
 * \returns the number of bytes read, or 0 on end of file or other failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_WriteIO
 * \sa SDL_GetIOStatus
  }
function SDL_ReadIO(context: PSDL_IOStream; ptr: Pointer; size: csize_t): csize_t; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadIO' {$ENDIF} {$ENDIF};

{*
 * Write to an SDL_IOStream data stream.
 *
 * This function writes exactly `size` bytes from the area pointed at by `ptr`
 * to the stream. If this fails for any reason, it'll return less than `size`
 * to demonstrate how far the write progressed. On success, it returns `size`.
 *
 * On error, this function still attempts to write as much as possible, so it
 * might return a positive value less than the requested write size.
 *
 * The caller can use SDL_GetIOStatus() to determine if the problem is
 * recoverable, such as a non-blocking write that can simply be retried later,
 * or a fatal error.
 *
 * A request for zero bytes on a valid stream will return zero immediately
 * without accessing the stream, so the stream status (EOF, err, etc) will not
 * change.
 *
 * \param context a Pointer to an SDL_IOStream structure.
 * \param ptr a Pointer to a buffer containing data to write.
 * \param size the number of bytes to write.
 * \returns the number of bytes written, which will be less than `size` on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_IOprintf
 * \sa SDL_ReadIO
 * \sa SDL_SeekIO
 * \sa SDL_FlushIO
 * \sa SDL_GetIOStatus
  }
function SDL_WriteIO(context: PSDL_IOStream; ptr: Pointer; size: csize_t): csize_t; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteIO' {$ENDIF} {$ENDIF};

{*
 * Print to an SDL_IOStream data stream.
 *
 * This function does formatted printing to the stream.
 *
 * \param context a Pointer to an SDL_IOStream structure.
 * \param fmt a printf() style format string.
 * \param ... additional parameters matching % tokens in the `fmt` string, if
 *            any.
 * \returns the number of bytes written or 0 on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_IOvprintf
 * \sa SDL_WriteIO
  }
function SDL_IOprintf(context: PSDL_IOStream; fmt: PAnsiChar; Args: array of const): csize_t; cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IOprintf' {$ENDIF} {$ENDIF};
function SDL_IOprintf(context: PSDL_IOStream; fmt: PAnsiChar): csize_t; cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IOprintf' {$ENDIF} {$ENDIF};

{*
 * Print to an SDL_IOStream data stream.
 *
 * This function does formatted printing to the stream.
 *
 * \param context a Pointer to an SDL_IOStream structure.
 * \param fmt a printf() style format string.
 * \param ap a variable argument list.
 * \returns the number of bytes written or 0 on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_IOprintf
 * \sa SDL_WriteIO
  }
{ #todo : SDL3-for-Pascal: Implement SDL_IOvprintf / va_list }

{*
 * Flush any buffered data in the stream.
 *
 * This function makes sure that any buffered data is written to the stream.
 * Normally this isn't necessary but if the stream is a pipe or socket it
 * guarantees that any pending data is sent.
 *
 * \param context SDL_IOStream structure to flush.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenIO
 * \sa SDL_WriteIO
  }
function SDL_FlushIO(context: PSDL_IOStream): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FlushIO' {$ENDIF} {$ENDIF};

{*
 * Load all the data from an SDL data stream.
 *
 * The data is allocated with a zero byte at the end (null terminated) for
 * convenience. This extra byte is not included in the value reported via
 * `datasize`.
 *
 * The data should be freed with SDL_free().
 *
 * \param src the SDL_IOStream to read all available data from.
 * \param datasize a Pointer filled in with the number of bytes read, may be
 *                 nil.
 * \param closeio if true, calls SDL_CloseIO() on `src` before returning, even
 *                in the case of an error.
 * \returns the data or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadFile
 * \sa SDL_SaveFile_IO
  }
function SDL_LoadFile_IO(src: PSDL_IOStream; datasize: pcsize_t; closeio: Boolean): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadFile_IO' {$ENDIF} {$ENDIF};

{*
 * Load all the data from a file path.
 *
 * The data is allocated with a zero byte at the end (null terminated) for
 * convenience. This extra byte is not included in the value reported via
 * `datasize`.
 *
 * The data should be freed with SDL_free().
 *
 * \param file the path to read all available data from.
 * \param datasize if not nil, will store the number of bytes read.
 * \returns the data or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadFile_IO
 * \sa SDL_SaveFile
  }
function SDL_LoadFile(file_: PAnsiChar; datasize: pcsize_t): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadFile' {$ENDIF} {$ENDIF};

{*
 * Save all the data into an SDL data stream.
 *
 * \param src the SDL_IOStream to write all data to.
 * \param data the data to be written. If datasize is 0, may be nil or a
 *             invalid Pointer.
 * \param datasize the number of bytes to be written.
 * \param closeio if true, calls SDL_CloseIO() on `src` before returning, even
 *                in the case of an error.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SaveFile
 * \sa SDL_LoadFile_IO
  }
function SDL_SaveFile_IO(src: PSDL_IOStream; data: Pointer; datasize: csize_t; closeio: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SaveFile_IO' {$ENDIF} {$ENDIF};

{*
 * Save all the data into a file path.
 *
 * \param file the path to write all available data into.
 * \param data the data to be written. If datasize is 0, may be nil or a
 *             invalid Pointer.
 * \param datasize the number of bytes to be written.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SaveFile_IO
 * \sa SDL_LoadFile
  }
function SDL_SaveFile(file_: PAnsiChar; data: Pointer; datasize: csize_t): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SaveFile' {$ENDIF} {$ENDIF};

{*
 *  \name Read endian functions
 *
 *  Read an item of the specified endianness and return in native format.
  }

{*
 * Use this function to read a byte from an SDL_IOStream.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the SDL_IOStream to read from.
 * \param value a Pointer filled in with the data read.
 * \returns true on success or false on failure or EOF; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU8(src: PSDL_IOStream; value: pcuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU8' {$ENDIF} {$ENDIF};

{*
 * Use this function to read a signed byte from an SDL_IOStream.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the SDL_IOStream to read from.
 * \param value a Pointer filled in with the data read.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS8(src: PSDL_IOStream; value: pcint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS8' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 16 bits of little-endian data from an
 * SDL_IOStream and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU16LE(src: PSDL_IOStream; value: pcuint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU16LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 16 bits of little-endian data from an
 * SDL_IOStream and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS16LE(src: PSDL_IOStream; value: pcint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS16LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 16 bits of big-endian data from an SDL_IOStream
 * and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU16BE(src: PSDL_IOStream; value: pcuint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU16BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 16 bits of big-endian data from an SDL_IOStream
 * and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS16BE(src: PSDL_IOStream; value: pcint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS16BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 32 bits of little-endian data from an
 * SDL_IOStream and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU32LE(src: PSDL_IOStream; value: pcuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU32LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 32 bits of little-endian data from an
 * SDL_IOStream and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS32LE(src: PSDL_IOStream; value: pcint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS32LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 32 bits of big-endian data from an SDL_IOStream
 * and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU32BE(src: PSDL_IOStream; value: pcuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU32BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 32 bits of big-endian data from an SDL_IOStream
 * and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS32BE(src: PSDL_IOStream; value: pcint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS32BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 64 bits of little-endian data from an
 * SDL_IOStream and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU64LE(src: PSDL_IOStream; value: pcuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU64LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 64 bits of little-endian data from an
 * SDL_IOStream and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS64LE(src: PSDL_IOStream; value: pcint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS64LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 64 bits of big-endian data from an SDL_IOStream
 * and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadU64BE(src: PSDL_IOStream; value: pcuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadU64BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to read 64 bits of big-endian data from an SDL_IOStream
 * and return in native format.
 *
 * SDL byteswaps the data only if necessary, so the data returned will be in
 * the native byte order.
 *
 * This function will return false when the data stream is completely read,
 * and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
 * and the stream is not at EOF, SDL_GetIOStatus() will return a different
 * error value and SDL_GetError() will offer a human-readable message.
 *
 * \param src the stream from which to read data.
 * \param value a Pointer filled in with the data read.
 * \returns true on successful read or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReadS64BE(src: PSDL_IOStream; value: pcint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadS64BE' {$ENDIF} {$ENDIF};

{ Read endian functions  }

{*
 *  \name Write endian functions
 *
 *  Write an item of native format to the specified endianness.
  }

{*
 * Use this function to write a byte to an SDL_IOStream.
 *
 * \param dst the SDL_IOStream to write to.
 * \param value the byte value to write.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU8(dst: PSDL_IOStream; value: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU8' {$ENDIF} {$ENDIF};

{*
 * Use this function to write a signed byte to an SDL_IOStream.
 *
 * \param dst the SDL_IOStream to write to.
 * \param value the byte value to write.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS8(dst: PSDL_IOStream; value: cint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS8' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 16 bits in native format to an SDL_IOStream as
 * little-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in little-endian
 * format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU16LE(dst: PSDL_IOStream; value: cuint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU16LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 16 bits in native format to an SDL_IOStream as
 * little-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in little-endian
 * format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS16LE(dst: PSDL_IOStream; value: cint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS16LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 16 bits in native format to an SDL_IOStream as
 * big-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in big-endian format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU16BE(dst: PSDL_IOStream; value: cuint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU16BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 16 bits in native format to an SDL_IOStream as
 * big-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in big-endian format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS16BE(dst: PSDL_IOStream; value: cint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS16BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 32 bits in native format to an SDL_IOStream as
 * little-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in little-endian
 * format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU32LE(dst: PSDL_IOStream; value: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU32LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 32 bits in native format to an SDL_IOStream as
 * little-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in little-endian
 * format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS32LE(dst: PSDL_IOStream; value: cint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS32LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 32 bits in native format to an SDL_IOStream as
 * big-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in big-endian format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU32BE(dst: PSDL_IOStream; value: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU32BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 32 bits in native format to an SDL_IOStream as
 * big-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in big-endian format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS32BE(dst: PSDL_IOStream; value: cint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS32BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 64 bits in native format to an SDL_IOStream as
 * little-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in little-endian
 * format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU64LE(dst: PSDL_IOStream; value: cuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU64LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 64 bits in native format to an SDL_IOStream as
 * little-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in little-endian
 * format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS64LE(dst: PSDL_IOStream; value: cint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS64LE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 64 bits in native format to an SDL_IOStream as
 * big-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in big-endian format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteU64BE(dst: PSDL_IOStream; value: cuint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteU64BE' {$ENDIF} {$ENDIF};

{*
 * Use this function to write 64 bits in native format to an SDL_IOStream as
 * big-endian data.
 *
 * SDL byteswaps the data only if necessary, so the application always
 * specifies native format, and the data written will be in big-endian format.
 *
 * \param dst the stream to which data will be written.
 * \param value the data to be written, in native format.
 * \returns true on successful write or false on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety Do not use the same SDL_IOStream from two threads at once.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_WriteS64BE(dst: PSDL_IOStream; value: cint64): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WriteS64BE' {$ENDIF} {$ENDIF};

