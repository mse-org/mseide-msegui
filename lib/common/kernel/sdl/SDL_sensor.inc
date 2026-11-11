{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategorySensor
 *
 * SDL sensor management.
 *
 * These APIs grant access to gyros and accelerometers on various platforms.
 *
 * In order to use these functions, SDL_Init() must have been called with the
 * SDL_INIT_SENSOR flag. This causes SDL to scan the system for sensors, and
 * load appropriate drivers.
  }

{
* The opaque structure used to identify an opened SDL sensor.
*
* \since This struct is available since SDL 3.2.0.
}
type
  PPSDL_Sensor = ^PSDL_Sensor;
  PSDL_Sensor = type Pointer;

{*
 * This is a unique ID for a sensor for the time it is connected to the
 * system, and is never reused for the lifetime of the application.
 *
 * The value 0 is an invalid ID.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_SensorID = ^PSDL_SensorID;
  PSDL_SensorID = ^TSDL_SensorID;
  TSDL_SensorID = cuint32;

{*
 * A constant to represent standard gravity for accelerometer sensors.
 *
 * The accelerometer returns the current acceleration in SI meters per second
 * squared. This measurement includes the force of gravity, so a device at
 * rest will have an value of SDL_STANDARD_GRAVITY away from the center of the
 * earth, which is a positive Y value.
 *
 * \since This macro is available since SDL 3.2.0.
  }
const
  SDL_STANDARD_GRAVITY = cfloat(9.80665);

{*
 * The different sensors defined by SDL.
 *
 * Additional sensors may be available, using platform dependent semantics.
 *
 * Here are the additional Android sensors:
 *
 * https://developer.android.com/reference/android/hardware/SensorEvent.html#values
 *
 * Accelerometer sensor notes:
 *
 * The accelerometer returns the current acceleration in SI meters per second
 * squared. This measurement includes the force of gravity, so a device at
 * rest will have an value of SDL_STANDARD_GRAVITY away from the center of the
 * earth, which is a positive Y value.
 *
 * - `values[0]`: Acceleration on the x axis
 * - `values[1]`: Acceleration on the y axis
 * - `values[2]`: Acceleration on the z axis
 *
 * For phones and tablets held in natural orientation and game controllers
 * held in front of you, the axes are defined as follows:
 *
 * - -X ... +X: left ... right
 * - -Y ... +Y: bottom ... top
 * - -Z ... +Z: farther ... closer
 *
 * The accelerometer axis data is not changed when the device is rotated.
 *
 * Gyroscope sensor notes:
 *
 * The gyroscope returns the current rate of rotation in radians per second.
 * The rotation is positive in the counter-clockwise direction. That is, an
 * observer looking from a positive location on one of the axes would see
 * positive rotation on that axis when it appeared to be rotating
 * counter-clockwise.
 *
 * - `values[0]`: Angular speed around the x axis (pitch)
 * - `values[1]`: Angular speed around the y axis (yaw)
 * - `values[2]`: Angular speed around the z axis (roll)
 *
 * For phones and tablets held in natural orientation and game controllers
 * held in front of you, the axes are defined as follows:
 *
 * - -X ... +X: left ... right
 * - -Y ... +Y: bottom ... top
 * - -Z ... +Z: farther ... closer
 *
 * The gyroscope axis data is not changed when the device is rotated.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_GetCurrentDisplayOrientation
  }
type
  PPSDL_SensorType = ^PSDL_SensorType;
  PSDL_SensorType = ^TSDL_SensorType;
  TSDL_SensorType = type Integer;
const
  SDL_SENSOR_INVALID = TSDL_SensorType(-1);   {*< Returned for an invalid sensor  }
  SDL_SENSOR_UNKNOWN  = TSDL_SensorType(0);   {*< Unknown sensor type  }
  SDL_SENSOR_ACCEL  = TSDL_SensorType(1);     {*< Accelerometer  }
  SDL_SENSOR_GYRO  = TSDL_SensorType(2);      {*< Gyroscope  }
  SDL_SENSOR_ACCEL_L  = TSDL_SensorType(3);   {*< Accelerometer for left Joy-Con controller and Wii nunchuk  }
  SDL_SENSOR_GYRO_L  = TSDL_SensorType(4);    {*< Gyroscope for left Joy-Con controller  }
  SDL_SENSOR_ACCEL_R  = TSDL_SensorType(5);   {*< Accelerometer for right Joy-Con controller  }
  SDL_SENSOR_GYRO_R  = TSDL_SensorType(6);    {*< Gyroscope for right Joy-Con controller  }
  SDL_SENSOR_COUNT = TSDL_SensorType(7);

{ Function prototypes  }

{*
 * Get a list of currently connected sensors.
 *
 * \param count a Pointer filled in with the number of sensors returned, may
 *              be nil.
 * \returns a 0 terminated array of sensor instance IDs or nil on failure;
 *          call SDL_GetError() for more information. This should be freed
 *          with SDL_free() when it is no longer needed.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensors(count: pcint): PSDL_SensorID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensors' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent name of a sensor.
 *
 * This can be called before any sensors are opened.
 *
 * \param instance_id the sensor instance ID.
 * \returns the sensor name, or nil if `instance_id` is not valid.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorNameForID(instance_id: TSDL_SensorID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorNameForID' {$ENDIF} {$ENDIF};

{*
 * Get the type of a sensor.
 *
 * This can be called before any sensors are opened.
 *
 * \param instance_id the sensor instance ID.
 * \returns the SDL_SensorType, or `SDL_SENSOR_INVALID` if `instance_id` is
 *          not valid.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorTypeForID(instance_id: TSDL_SensorID): TSDL_SensorType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorTypeForID' {$ENDIF} {$ENDIF};

{*
 * Get the platform dependent type of a sensor.
 *
 * This can be called before any sensors are opened.
 *
 * \param instance_id the sensor instance ID.
 * \returns the sensor platform dependent type, or -1 if `instance_id` is not
 *          valid.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorNonPortableTypeForID(instance_id: TSDL_SensorID): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorNonPortableTypeForID' {$ENDIF} {$ENDIF};

{*
 * Open a sensor for use.
 *
 * \param instance_id the sensor instance ID.
 * \returns an SDL_Sensor object or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_OpenSensor(instance_id: TSDL_SensorID): PSDL_Sensor; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenSensor' {$ENDIF} {$ENDIF};

{*
 * Return the SDL_Sensor associated with an instance ID.
 *
 * \param instance_id the sensor instance ID.
 * \returns an SDL_Sensor object or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorFromID(instance_id: TSDL_SensorID): PSDL_Sensor; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorFromID' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a sensor.
 *
 * \param sensor the SDL_Sensor object.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorProperties(sensor: PSDL_Sensor): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorProperties' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent name of a sensor.
 *
 * \param sensor the SDL_Sensor object.
 * \returns the sensor name or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorName(sensor: PSDL_Sensor): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorName' {$ENDIF} {$ENDIF};

{*
 * Get the type of a sensor.
 *
 * \param sensor the SDL_Sensor object to inspect.
 * \returns the SDL_SensorType type, or `SDL_SENSOR_INVALID` if `sensor` is
 *          nil.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorType(sensor: PSDL_Sensor): TSDL_SensorType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorType' {$ENDIF} {$ENDIF};

{*
 * Get the platform dependent type of a sensor.
 *
 * \param sensor the SDL_Sensor object to inspect.
 * \returns the sensor platform dependent type, or -1 if `sensor` is nil.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorNonPortableType(sensor: PSDL_Sensor): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorNonPortableType' {$ENDIF} {$ENDIF};

{*
 * Get the instance ID of a sensor.
 *
 * \param sensor the SDL_Sensor object to inspect.
 * \returns the sensor instance ID, or 0 on failure; call SDL_GetError() for
 *          more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorID(sensor: PSDL_Sensor): TSDL_SensorID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorID' {$ENDIF} {$ENDIF};

{*
 * Get the current state of an opened sensor.
 *
 * The number of values and interpretation of the data is sensor dependent.
 *
 * \param sensor the SDL_Sensor object to query.
 * \param data a Pointer filled with the current sensor state.
 * \param num_values the number of values to write to data.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetSensorData(sensor: PSDL_Sensor; data: pcfloat; num_values: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSensorData' {$ENDIF} {$ENDIF};

{*
 * Close a sensor previously opened with SDL_OpenSensor().
 *
 * \param sensor the SDL_Sensor object to close.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_CloseSensor(sensor: PSDL_Sensor); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CloseSensor' {$ENDIF} {$ENDIF};

{*
 * Update the current state of the open sensors.
 *
 * This is called automatically by the event loop if sensor events are
 * enabled.
 *
 * This needs to be called from the thread that initialized the sensor
 * subsystem.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_UpdateSensors; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateSensors' {$ENDIF} {$ENDIF};

