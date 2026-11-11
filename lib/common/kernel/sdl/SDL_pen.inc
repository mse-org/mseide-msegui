{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryPen
 *
 * SDL pen event handling.
 *
 * SDL provides an API for pressure-sensitive pen (stylus and/or eraser)
 * handling, e.g., for input and drawing tablets or suitably equipped mobile /
 * tablet devices.
 *
 * To get started with pens, simply handle pen events:
 *
 * - SDL_EVENT_PEN_PROXIMITY_IN, SDL_EVENT_PEN_PROXIMITY_OUT
 *   (SDL_PenProximityEvent)
 * - SDL_EVENT_PEN_DOWN, SDL_EVENT_PEN_UP (SDL_PenTouchEvent)
 * - SDL_EVENT_PEN_MOTION (SDL_PenMotionEvent)
 * - SDL_EVENT_PEN_BUTTON_DOWN, SDL_EVENT_PEN_BUTTON_UP (SDL_PenButtonEvent)
 * - SDL_EVENT_PEN_AXIS (SDL_PenAxisEvent)
 *
 * Pens may provide more than simple touch input; they might have other axes,
 * such as pressure, tilt, rotation, etc.
 *
 * When a pen starts providing input, SDL will assign it a unique SDL_PenID,
 * which will remain for the life of the process, as long as the pen stays
 * connected. A pen leaving proximity (being taken far enough away from the
 * digitizer tablet that it no longer reponds) and then coming back should
 * fire proximity events, but the SDL_PenID should remain consistent.
 * Unplugging the digitizer and reconnecting may cause future input to have a
 * new SDL_PenID, as SDL may not know that this is the same hardware.
 *
 * Please note that various platforms vary wildly in how (and how well) they
 * support pen input. If your pen supports some piece of functionality but SDL
 * doesn't seem to, it might actually be the operating system's fault. For
 * example, some platforms can manage multiple devices at the same time, but
 * others will make any connected pens look like a single logical device, much
 * how all USB mice connected to a computer will move the same system cursor.
 * Other platforms might not support pen buttons, or the distance axis, etc.
 * Very few platforms can even report _what_ functionality the pen supports in
 * the first place, so best practices is to either build UI to let the user
 * configure their pens, or be prepared to handle new functionality for a pen
 * the first time an event is reported.
  }

{*
 * SDL pen instance IDs.
 *
 * Zero is used to signify an invalid/null device.
 *
 * These show up in pen events when SDL sees input from them. They remain
 * consistent as long as SDL can recognize a tool to be the same pen; but if a
 * pen's digitizer table is physically detached from the computer, it might
 * get a new ID when reconnected, as SDL won't know it's the same device.
 *
 * These IDs are only stable within a single run of a program; the next time a
 * program is run, the pen's ID will likely be different, even if the hardware
 * hasn't been disconnected, etc.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_PenID = ^PSDL_PenID;
  PSDL_PenID = ^TSDL_PenID;
  TSDL_PenID = cuint32;

const
  {*
   * The SDL_MouseID for mouse events simulated with pen input.
   *
   * \since This macro is available since SDL 3.2.0.
   *}
  SDL_PEN_MOUSEID = TSDL_MouseID(-2);

  {*
   * The SDL_TouchID for touch events simulated with pen input.
   *
   * \since This macro is available since SDL 3.2.0.
   *}
  SDL_PEN_TOUCHID = TSDL_TouchID(-2);

{*
 * Pen input flags, as reported by various pen events' `pen_state` field.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_PenInputFlags = ^PSDL_PenInputFlags;
  PSDL_PenInputFlags = ^TSDL_PenInputFlags;
  TSDL_PenInputFlags = cuint32;

const
  SDL_PEN_INPUT_DOWN  = TSDL_PenInputFlags(1 shl 0);        {*< pen is pressed down  }
  SDL_PEN_INPUT_BUTTON_1  = TSDL_PenInputFlags(1 shl 1);    {*< button 1 is pressed  }
  SDL_PEN_INPUT_BUTTON_2  = TSDL_PenInputFlags(1 shl 2);    {*< button 2 is pressed  }
  SDL_PEN_INPUT_BUTTON_3  = TSDL_PenInputFlags(1 shl 3);    {*< button 3 is pressed  }
  SDL_PEN_INPUT_BUTTON_4  = TSDL_PenInputFlags(1 shl 4);    {*< button 4 is pressed  }
  SDL_PEN_INPUT_BUTTON_5  = TSDL_PenInputFlags(1 shl 5);    {*< button 5 is pressed  }
  SDL_PEN_INPUT_ERASER_TIP  = TSDL_PenInputFlags(1 shl 30); {*< eraser tip is used  }
  SDL_PEN_INPUT_IN_PROXIMITY = TSDL_PenInputFlags(1 shl 31); {*< pen is in proximity (since SDL 3.4.0)  }

 {*
 * Pen axis indices.
 *
 * These are the valid values for the `axis` field in SDL_PenAxisEvent. All
 * axes are either normalised to 0..1 or report a (positive or negative) angle
 * in degrees, with 0.0 representing the centre. Not all pens/backends support
 * all axes: unsupported axes are always zero.
 *
 * To convert angles for tilt and rotation into vector representation, use
 * SDL_sinf on the XTILT, YTILT, or ROTATION component, for example:
 *
 * `SDL_sinf(xtilt * SDL_PI_F / 180.0)`.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_PenAxis = ^PSDL_PenAxis;
  PSDL_PenAxis = ^TSDL_PenAxis;
  TSDL_PenAxis = type Integer;
const
  SDL_PEN_AXIS_PRESSURE  = TSDL_PenAxis(0);             {*< Pen pressure.  Unidirectional: 0 to 1.0  }
  SDL_PEN_AXIS_XTILT  = TSDL_PenAxis(1);                {*< Pen horizontal tilt angle.  Bidirectional: -90.0 to 90.0 (left-to-right).  }
  SDL_PEN_AXIS_YTILT  = TSDL_PenAxis(2);                {*< Pen vertical tilt angle.  Bidirectional: -90.0 to 90.0 (top-to-down).  }
  SDL_PEN_AXIS_DISTANCE  = TSDL_PenAxis(3);             {*< Pen distance to drawing surface.  Unidirectional: 0.0 to 1.0  }
  SDL_PEN_AXIS_ROTATION  = TSDL_PenAxis(4);             {*< Pen barrel rotation.  Bidirectional: -180 to 179.9 (clockwise, 0 is facing up, -180.0 is facing down).  }
  SDL_PEN_AXIS_SLIDER  = TSDL_PenAxis(5);               {*< Pen finger wheel or slider (e.g., Airbrush Pen).  Unidirectional: 0 to 1.0  }
  SDL_PEN_AXIS_TANGENTIAL_PRESSURE  = TSDL_PenAxis(6);  {*< Pressure from squeezing the pen ("barrel pressure").  }
  SDL_PEN_AXIS_COUNT  = TSDL_PenAxis(7);                {*< Total known pen axis types in this version of SDL. This number may grow in future releases!  }

{*
  * An enum that describes the type of a pen device.
  *
  * A "direct" device is a pen that touches a graphic display (like an Apple
  * Pencil on an iPad's screen). "Indirect" devices touch an
  external tablet
  * surface that is connected to the machine but is not a display (like a
  * lower-end Wacom tablet connected over USB).
  *
  * Apps may use this information to decide if they should draw a cursor; if
  * the pen is touching the screen directly, a cursor doesn't make sense and
  * can be in the way, but becomes necessary for indirect devices to know where
  * on the display they are interacting.
  *
  * \since This enum is available since SDL 3.4.0.
  }
type
  PPSDL_PenDeviceType = ^PSDL_PenDeviceType;
  PSDL_PenDeviceType = ^TSDL_PenDeviceType;
  TSDL_PenDeviceType = type Integer;
const
  SDL_PEN_DEVICE_TYPE_INVALID = TSDL_PenDeviceType(-1); {*< Not a valid pen device.  }
  SDL_PEN_DEVICE_TYPE_UNKNOWN = TSDL_PenDeviceType(0);  {*< Don't know specifics of this pen.  }
  SDL_PEN_DEVICE_TYPE_DIRECT = TSDL_PenDeviceType(1);   {*< Pen touches display.  }
  SDL_PEN_DEVICE_TYPE_INDIRECT = TSDL_PenDeviceType(2); {*< Pen touches something that isn't the display.  }

