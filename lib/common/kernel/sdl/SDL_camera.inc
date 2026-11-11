{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
  * # CategoryCamera
  *
  * Video capture for the SDL library.
  *
  * This API lets apps read input from video sources, like webcams. Camera
  * devices can be enumerated, queried, and opened. Once opened, it will
  * provide SDL_Surface objects as new frames of video come in. These surfaces
  * can be uploaded to an SDL_Texture or processed as pixels in memory.
  *
  * Several platforms will alert the user if an app tries to access a camera,
  * and some will present a UI asking the user if your application should be
  * allowed to obtain images at all, which they can deny. A successfully opened
  * camera will not provide images until permission is granted. Applications,
  * after opening a camera device, can see if they were granted access by
  * either polling with the SDL_GetCameraPermissionState() function, or waiting
  * for an SDL_EVENT_CAMERA_DEVICE_APPROVED or SDL_EVENT_CAMERA_DEVICE_DENIED
  * event. Platforms that don't have any user approval process will report
  * approval immediately.
  *
  * Note that SDL cameras only provide video as individual frames; they will
  * not provide full-motion video encoded in a movie file format, although an
  * app is free to encode the acquired frames into any format it likes. It also
  * does not provide audio from the camera hardware through this API; not only
  * do many webcams not have microphones at all, many people--from streamers to
  * people on Zoom calls--will want to use a separate microphone regardless of
  * the camera. In any case, recorded audio will be available through SDL's
  * audio API no matter what hardware provides the microphone.
  *
  * ## Camera gotchas
  *
  * Consumer-level camera hardware tends to take a little while to warm up,
  * once the device has been opened. Generally most camera apps have some sort
  * of UI to take a picture (a button to snap a pic while a preview is showing,
  * some sort of multi-second countdown for the user to pose, like a photo
  * booth), which puts control in the users' hands, or they are intended to
  * stay on for long times (Pokemon Go, etc).
  *
  * It's not uncommon that a newly-opened camera will provide a couple of
  * completely black frames, maybe followed by some under-exposed images. If
  * taking a single frame automatically, or recording video from a camera's
  * input without the user initiating it from a preview, it could be wise to
  * drop the first several frames (if not the first several _seconds_ worth of
  * frames!) before using images from a camera.
  }

{*
 * This is a unique ID for a camera device for the time it is connected to the
 * system, and is never reused for the lifetime of the application.
 *
 * If the device is disconnected and reconnected, it will get a new ID.
 *
 * The value 0 is an invalid ID.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameras
  }
type
  PPSDL_CameraID = ^PSDL_CameraID;
  PSDL_CameraID = ^TSDL_CameraID;
  TSDL_CameraID = cuint32;

{*
 * The opaque structure used to identify an opened SDL camera.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_Camera = ^PSDL_Camera;
  PSDL_Camera = type Pointer;

{*
 * The details of an output format for a camera device.
 *
 * Cameras often support multiple formats; each one will be encapsulated in
 * this struct.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameraSupportedFormats
 * \sa SDL_GetCameraFormat
  }
type
  PPSDL_CameraSpec = ^PSDL_CameraSpec;
  PSDL_CameraSpec = ^TSDL_CameraSpec;
  TSDL_CameraSpec = record
      format: TSDL_PixelFormat;    {*< Frame format  }
      colorspace: TSDL_Colorspace; {*< Frame colorspace  }
      width: cint;                 {*< Frame width  }
      height: cint;                {*< Frame height  }
      framerate_numerator: cint;   {*< Frame rate numerator ((num / denom) == FPS, (denom / num) == duration in seconds)  }
      framerate_denominator: cint; {*< Frame rate demoninator ((num / denom) == FPS, (denom / num) == duration in seconds)  }
    end;

{*
 * The position of camera in relation to system device.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameraPosition
  }
type
  PPSDL_CameraPosition = ^PSDL_CameraPosition;
  PSDL_CameraPosition = ^TSDL_CameraPosition;
  TSDL_CameraPosition =  Integer;
const
  SDL_CAMERA_POSITION_UNKNOWN  = TSDL_CameraPosition(0);
  SDL_CAMERA_POSITION_FRONT_FACING  = TSDL_CameraPosition(1);
  SDL_CAMERA_POSITION_BACK_FACING  = TSDL_CameraPosition(2);

{*
 * The current state of a request for camera access.
 *
 * \since This enum is available since SDL 3.4.0.
 *
 * \sa SDL_GetCameraPermissionState
  }
type
  PPSDL_CameraPermissionState = ^PSDL_CameraPermissionState;
  PSDL_CameraPermissionState = ^TSDL_CameraPermissionState;
  TSDL_CameraPermissionState = type cint;
const
  SDL_CAMERA_PERMISSION_STATE_DENIED = TSDL_CameraPermissionState(-1);
  SDL_CAMERA_PERMISSION_STATE_PENDING = TSDL_CameraPermissionState(0);
  SDL_CAMERA_PERMISSION_STATE_APPROVED = TSDL_CameraPermissionState(1);

{*
 * Use this function to get the number of built-in camera drivers.
 *
 * This function returns a hardcoded number. This never returns a negative
 * value; if there are no drivers compiled into this build of SDL, this
 * function returns zero. The presence of a driver in this list does not mean
 * it will function, it just means SDL is capable of interacting with that
 * interface. For example, a build of SDL might have v4l2 support, but if
 * there's no kernel support available, SDL's v4l2 driver would fail if used.
 *
 * By default, SDL tries all drivers, in its preferred order, until one is
 * found to be usable.
 *
 * \returns the number of built-in camera drivers.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameraDriver
  }
function SDL_GetNumCameraDrivers: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumCameraDrivers' {$ENDIF} {$ENDIF};

{*
 * Use this function to get the name of a built in camera driver.
 *
 * The list of camera drivers is given in the order that they are normally
 * initialized by default; the drivers that seem more reasonable to choose
 * first (as far as the SDL developers believe) are earlier in the list.
 *
 * The names of drivers are all simple, low-ASCII identifiers, like "v4l2",
 * "coremedia" or "android". These never have Unicode characters, and are not
 * meant to be proper names.
 *
 * \param index the index of the camera driver; the value ranges from 0 to
 *              SDL_GetNumCameraDrivers() - 1.
 * \returns the name of the camera driver at the requested index, or nil if
 *          an invalid index was specified.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumCameraDrivers
  }
function SDL_GetCameraDriver(index: cint): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraDriver' {$ENDIF} {$ENDIF};

{*
 * Get the name of the current camera driver.
 *
 * The names of drivers are all simple, low-ASCII identifiers, like "v4l2",
 * "coremedia" or "android". These never have Unicode characters, and are not
 * meant to be proper names.
 *
 * \returns the name of the current camera driver or nil if no driver has
 *          been initialized.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetCurrentCameraDriver: PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentCameraDriver' {$ENDIF} {$ENDIF};

{*
 * Get a list of currently connected camera devices.
 *
 * \param count a Pointer filled in with the number of cameras returned, may
 *              be nil.
 * \returns a 0 terminated array of camera instance IDs or nil on failure;
 *          call SDL_GetError() for more information. This should be freed
 *          with SDL_free() when it is no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenCamera
  }
function SDL_GetCameras(count: pcint): PSDL_CameraID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameras' {$ENDIF} {$ENDIF};

{*
 * Get the list of native formats/sizes a camera supports.
 *
 * This returns a list of all formats and frame sizes that a specific camera
 * can offer. This is useful if your app can accept a variety of image formats
 * and sizes and so want to find the optimal spec that doesn't require
 * conversion.
 *
 * This function isn't strictly required; if you call SDL_OpenCamera with a
 * nil spec, SDL will choose a native format for you, and if you instead
 * specify a desired format, it will transparently convert to the requested
 * format on your behalf.
 *
 * If `count` is not nil, it will be filled with the number of elements in
 * the returned array.
 *
 * Note that it's legal for a camera to supply an empty list. This is what
 * will happen on Emscripten builds, since that platform won't tell _anything_
 * about available cameras until you've opened one, and won't even tell if
 * there _is_ a camera until the user has given you permission to check
 * through a scary warning popup.
 *
 * \param instance_id the camera device instance ID.
 * \param count a Pointer filled in with the number of elements in the list,
 *              may be nil.
 * \returns a nil terminated array of pointers to SDL_CameraSpec or nil on
 *          failure; call SDL_GetError() for more information. This is a
 *          single allocation that should be freed with SDL_free() when it is
 *          no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameras
 * \sa SDL_OpenCamera
  }
function SDL_GetCameraSupportedFormats(instance_id: TSDL_CameraID; count: pcint):PPSDL_CameraSpec; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraSupportedFormats' {$ENDIF} {$ENDIF};

{*
 * Get the human-readable device name for a camera.
 *
 * \param instance_id the camera device instance ID.
 * \returns a human-readable device name or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameras
  }
function SDL_GetCameraName(instance_id: TSDL_CameraID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraName' {$ENDIF} {$ENDIF};

{*
 * Get the position of the camera in relation to the system.
 *
 * Most platforms will report UNKNOWN, but mobile devices, like phones, can
 * often make a distinction between cameras on the front of the device (that
 * points towards the user, for taking "selfies") and cameras on the back (for
 * filming in the direction the user is facing).
 *
 * \param instance_id the camera device instance ID.
 * \returns the position of the camera on the system hardware.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameras
  }
function SDL_GetCameraPosition(instance_id: TSDL_CameraID): TSDL_CameraPosition; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraPosition' {$ENDIF} {$ENDIF};

{*
 * Open a video recording device (a "camera").
 *
 * You can open the device with any reasonable spec, and if the hardware can't
 * directly support it, it will convert data seamlessly to the requested
 * format. This might incur overhead, including scaling of image data.
 *
 * If you would rather accept whatever format the device offers, you can pass
 * a nil spec here and it will choose one for you (and you can use
 * SDL_Surface's conversion/scaling functions directly if necessary).
 *
 * You can call SDL_GetCameraFormat() to get the actual data format if passing
 * a nil spec here. You can see the exact specs a device can support without
 * conversion with SDL_GetCameraSupportedFormats().
 *
 * SDL will not attempt to emulate framerate; it will try to set the hardware
 * to the rate closest to the requested speed, but it won't attempt to limit
 * or duplicate frames artificially; call SDL_GetCameraFormat() to see the
 * actual framerate of the opened the device, and check your timestamps if
 * this is crucial to your app!
 *
 * Note that the camera is not usable until the user approves its use! On some
 * platforms, the operating system will prompt the user to permit access to
 * the camera, and they can choose Yes or No at that point. Until they do, the
 * camera will not be usable. The app should either wait for an
 * SDL_EVENT_CAMERA_DEVICE_APPROVED (or SDL_EVENT_CAMERA_DEVICE_DENIED) event,
 * or poll SDL_GetCameraPermissionState() occasionally until it returns
 * non-zero. On platforms that don't require explicit user approval (and
 * perhaps in places where the user previously permitted access), the approval
 * event might come immediately, but it might come seconds, minutes, or hours
 * later!
 *
 * \param instance_id the camera device instance ID.
 * \param spec the desired format for data the device will provide. Can be
 *             nil.
 * \returns an SDL_Camera object or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCameras
 * \sa SDL_GetCameraFormat
  }
function SDL_OpenCamera(instance_id: TSDL_CameraID; spec: PSDL_CameraSpec): PSDL_Camera; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenCamera' {$ENDIF} {$ENDIF};

{*
 * Query if camera access has been approved by the user.
 *
 * Cameras will not function between when the device is opened by the app and
 * when the user permits access to the hardware. On some platforms, this
 * presents as a popup dialog where the user has to explicitly approve access;
 * on others the approval might be implicit and not alert the user at all.
 *
 * This function can be used to check the status of that approval. It will
 * return SDL_CAMERA_PERMISSION_STATE_PENDING if waiting for user response,
 * SDL_CAMERA_PERMISSION_STATE_APPROVED if the camera is approved for use, and
 * SDL_CAMERA_PERMISSION_STATE_DENIED if the user denied access.
 *
 * Instead of polling with this function, you can wait for a
 * SDL_EVENT_CAMERA_DEVICE_APPROVED (or SDL_EVENT_CAMERA_DEVICE_DENIED) event
 * in the standard SDL event loop, which is guaranteed to be sent once when
 * permission to use the camera is decided.
 *
 * If a camera is declined, there's nothing to be done but call
 * SDL_CloseCamera() to dispose of it.
 *
 * \param camera the opened camera device to query.
 * \returns an SDL_CameraPermissionState value indicating if access is
 *          granted, or `SDL_CAMERA_PERMISSION_STATE_PENDING` if the decision
 *          is still pending.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenCamera
 * \sa SDL_CloseCamera
  }
function SDL_GetCameraPermissionState(camera: PSDL_Camera): TSDL_CameraPermissionState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraPermissionState' {$ENDIF} {$ENDIF};

{*
 * Get the instance ID of an opened camera.
 *
 * \param camera an SDL_Camera to query.
 * \returns the instance ID of the specified camera on success or 0 on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenCamera
  }
function SDL_GetCameraID(camera: PSDL_Camera): TSDL_CameraID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraID' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with an opened camera.
 *
 * \param camera the SDL_Camera obtained from SDL_OpenCamera().
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetCameraProperties(camera: PSDL_Camera): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraProperties' {$ENDIF} {$ENDIF};

{*
 * Get the spec that a camera is using when generating images.
 *
 * Note that this might not be the native format of the hardware, as SDL might
 * be converting to this format behind the scenes.
 *
 * If the system is waiting for the user to approve access to the camera, as
 * some platforms require, this will return false, but this isn't necessarily
 * a fatal error; you should either wait for an
 * SDL_EVENT_CAMERA_DEVICE_APPROVED (or SDL_EVENT_CAMERA_DEVICE_DENIED) event,
 * or poll SDL_GetCameraPermissionState() occasionally until it returns
 * non-zero.
 *
 * \param camera opened camera device.
 * \param spec the SDL_CameraSpec to be initialized by this function.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenCamera
  }
function SDL_GetCameraFormat(camera: PSDL_Camera; spec: PSDL_CameraSpec): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCameraFormat' {$ENDIF} {$ENDIF};

{*
 * Acquire a frame.
 *
 * The frame is a memory Pointer to the image data, whose size and format are
 * given by the spec requested when opening the device.
 *
 * This is a non blocking API. If there is a frame available, a non-nil
 * surface is returned, and timestampNS will be filled with a non-zero value.
 *
 * Note that an error case can also return nil, but a nil by itself is
 * normal and just signifies that a new frame is not yet available. Note that
 * even if a camera device fails outright (a USB camera is unplugged while in
 * use, etc), SDL will send an event separately to notify the app, but
 * continue to provide blank frames at ongoing intervals until
 * SDL_CloseCamera() is called, so real failure here is almost always an out
 * of memory condition.
 *
 * After use, the frame should be released with SDL_ReleaseCameraFrame(). If
 * you don't do this, the system may stop providing more video!
 *
 * Do not call SDL_DestroySurface() on the returned surface! It must be given
 * back to the camera subsystem with SDL_ReleaseCameraFrame!
 *
 * If the system is waiting for the user to approve access to the camera, as
 * some platforms require, this will return nil (no frames available); you
 * should either wait for an SDL_EVENT_CAMERA_DEVICE_APPROVED (or
 * SDL_EVENT_CAMERA_DEVICE_DENIED) event, or poll
 * SDL_GetCameraPermissionState() occasionally until it returns non-zero.
 *
 * \param camera opened camera device.
 * \param timestampNS a Pointer filled in with the frame's timestamp, or 0 on
 *                    error. Can be nil.
 * \returns a new frame of video on success, nil if none is currently
 *          available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ReleaseCameraFrame
  }
function SDL_AcquireCameraFrame(camera: PSDL_Camera; timestampNS: pcuint64): PSDL_Surface; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AcquireCameraFrame' {$ENDIF} {$ENDIF};

{*
 * Release a frame of video acquired from a camera.
 *
 * Let the back-end re-use the internal buffer for camera.
 *
 * This function _must_ be called only on surface objects returned by
 * SDL_AcquireCameraFrame(). This function should be called as quickly as
 * possible after acquisition, as SDL keeps a small FIFO queue of surfaces for
 * video frames; if surfaces aren't released in a timely manner, SDL may drop
 * upcoming video frames from the camera.
 *
 * If the app needs to keep the surface for a significant time, they should
 * make a copy of it and release the original.
 *
 * The app should not use the surface again after calling this function;
 * assume the surface is freed and the Pointer is invalid.
 *
 * \param camera opened camera device.
 * \param frame the video frame surface to release.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AcquireCameraFrame
  }
procedure SDL_ReleaseCameraFrame(camera: PSDL_Camera; frame: PSDL_Surface); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseCameraFrame' {$ENDIF} {$ENDIF};

{*
 * Use this function to shut down camera processing and close the camera
 * device.
 *
 * \param camera opened camera device.
 *
 * \threadsafety It is safe to call this function from any thread, but no
 *               thread may reference `device` once this function is called.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenCamera
  }
procedure SDL_CloseCamera(camera: PSDL_Camera); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CloseCamera' {$ENDIF} {$ENDIF};

