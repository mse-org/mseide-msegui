{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryHIDAPI
 *
 * Header file for SDL HIDAPI functions.
 *
 * This is an adaptation of the original HIDAPI interface by Alan Ott, and
 * includes source code licensed under the following license:
 *
 * ```
 * HIDAPI - Multi-Platform library for
 * communication with HID devices.
 *
 * Copyright 2009, Alan Ott, Signal 11 Software.
 * All Rights Reserved.
 *
 * This software may be used by anyone for any reason so
 * long as the copyright notice in the source files
 * remains intact.
 * ```
 *
 * (Note that this license is the same as item three of SDL's zlib license, so
 * it adds no new requirements on the user.)
 *
 * If you would like a version of SDL without this code, you can build SDL
 * with SDL_HIDAPI_DISABLED defined to 1. You might want to do this for
 * example on iOS or tvOS to avoid a dependency on the CoreBluetooth
 * framework.
  }

{*
 * An opaque handle representing an open HID device.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_hid_device = ^PSDL_hid_device;
  PSDL_hid_device = type Pointer;

{*
 * HID underlying bus types.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_hid_bus_type = ^PSDL_hid_bus_type;
  PSDL_hid_bus_type = ^TSDL_hid_bus_type;
  TSDL_hid_bus_type = type Integer;
const
  SDL_HID_API_BUS_UNKNOWN  = TSDL_hid_bus_type($00);    {* Unknown bus type  }
  SDL_HID_API_BUS_USB  = TSDL_hid_bus_type($01);        {* USB bus
                                                           Specifications:
                                                           https://usb.org/hid  }
  SDL_HID_API_BUS_BLUETOOTH  = TSDL_hid_bus_type($02);  {* Bluetooth or Bluetooth LE bus
                                                           Specifications:
                                                           https://www.bluetooth.com/specifications/specs/human-interface-device-profile-1-1-1/
                                                           https://www.bluetooth.com/specifications/specs/hid-service-1-0/
                                                           https://www.bluetooth.com/specifications/specs/hid-over-gatt-profile-1-0/  }
  SDL_HID_API_BUS_I2C  = TSDL_hid_bus_type($03);        {* I2C bus
                                                           Specifications:
                                                           https://docs.microsoft.com/previous-versions/windows/hardware/design/dn642101(v=vs.85)  }
  SDL_HID_API_BUS_SPI  = TSDL_hid_bus_type($04);        {* SPI bus
                                                           Specifications:
                                                           https://www.microsoft.com/download/details.aspx?id=103325  }

{* hidapi info structure  }

{*
 * Information about a connected HID device
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_hid_device_info = ^PSDL_hid_device_info;
  PSDL_hid_device_info = ^TSDL_hid_device_info;
  TSDL_hid_device_info = record
      path: PAnsiChar;               {* Platform-specific device path  }
      vendor_id: cushort;            {* Device Vendor ID  }
      product_id: cushort;           {* Device Product ID  }
      serial_number: cwchar_t;       {* Serial Number  }
      release_number: cushort;       {* Device Release Number in binary-coded decimal,
                                             also known as Device Version Number  }
      manufacturer_string: cwchar_t; {* Manufacturer String  }
      product_string: cwchar_t;      {* Product string  }
      usage_page: cushort;           {* Usage Page for this Device/Interface
                                             (Windows/Mac/hidraw only)  }
      usage: cushort;                {* Usage for this Device/Interface
                                             (Windows/Mac/hidraw only)  }
      interface_number: cint;        {* The USB interface which this logical device
                                             represents.

                                             Valid only if the device is a USB HID device.
                                             Set to -1 in all other cases.
                                          }
      interface_class: cint;         {* Additional information about the USB interface.
                                             Valid on libusb and Android implementations.  }
      interface_subclass: cint;
      interface_protocol: cint;
      bus_type: TSDL_hid_bus_type;   {* Underlying bus type  }
      next: PSDL_hid_device_info;    {* Pointer to the next device  }
    end;

{*
 * Initialize the HIDAPI library.
 *
 * This function initializes the HIDAPI library. Calling it is not strictly
 * necessary, as it will be called automatically by SDL_hid_enumerate() and
 * any of the SDL_hid_open_*() functions if it is needed. This function should
 * be called at the beginning of execution however, if there is a chance of
 * HIDAPI handles being opened by different threads simultaneously.
 *
 * Each call to this function should have a matching call to SDL_hid_exit()
 *
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_hid_exit
  }
function SDL_hid_init: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_init' {$ENDIF} {$ENDIF};

{*
 * Finalize the HIDAPI library.
 *
 * This function frees all of the static data associated with HIDAPI. It
 * should be called at the end of execution to avoid memory leaks.
 *
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_hid_init
  }
function SDL_hid_exit: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_exit' {$ENDIF} {$ENDIF};

{*
 * Check to see if devices may have been added or removed.
 *
 * Enumerating the HID devices is an expensive operation, so you can call this
 * to see if there have been any system device changes since the last call to
 * this function. A change in the counter returned doesn't necessarily mean
 * that anything has changed, but you can call SDL_hid_enumerate() to get an
 * updated device list.
 *
 * Calling this function for the first time may cause a thread or other system
 * resource to be allocated to track device change notifications.
 *
 * \returns a change counter that is incremented with each potential device
 *          change, or 0 if device change detection isn't available.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_hid_enumerate
  }
function SDL_hid_device_change_count: cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_device_change_count' {$ENDIF} {$ENDIF};

{*
 * Enumerate the HID Devices.
 *
 * This function returns a linked list of all the HID devices attached to the
 * system which match vendor_id and product_id. If `vendor_id` is set to 0
 * then any vendor matches. If `product_id` is set to 0 then any product
 * matches. If `vendor_id` and `product_id` are both set to 0, then all HID
 * devices will be returned.
 *
 * By default SDL will only enumerate controllers, to reduce risk of hanging
 * or crashing on bad drivers, but SDL_HINT_HIDAPI_ENUMERATE_ONLY_CONTROLLERS
 * can be set to "0" to enumerate all HID devices.
 *
 * \param vendor_id the Vendor ID (VID) of the types of device to open, or 0
 *                  to match any vendor.
 * \param product_id the Product ID (PID) of the types of device to open, or 0
 *                   to match any product.
 * \returns a Pointer to a linked list of type SDL_hid_device_info, containing
 *          information about the HID devices attached to the system, or nil
 *          in the case of failure. Free this linked list by calling
 *          SDL_hid_free_enumeration().
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_hid_device_change_count
  }
function SDL_hid_enumerate(vendor_id: cushort; product_id: cushort): PSDL_hid_device_info; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_enumerate' {$ENDIF} {$ENDIF};

{*
 * Free an enumeration linked list.
 *
 * This function frees a linked list created by SDL_hid_enumerate().
 *
 * \param devs Pointer to a list of struct_device returned from
 *             SDL_hid_enumerate().
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_hid_free_enumeration(devs: PSDL_hid_device_info); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_free_enumeration' {$ENDIF} {$ENDIF};

{*
 * Open a HID device using a Vendor ID (VID), Product ID (PID) and optionally
 * a serial number.
 *
 * If `serial_number` is nil, the first device with the specified VID and PID
 * is opened.
 *
 * \param vendor_id the Vendor ID (VID) of the device to open.
 * \param product_id the Product ID (PID) of the device to open.
 * \param serial_number the Serial Number of the device to open (Optionally
 *                      nil).
 * \returns a Pointer to a SDL_hid_device object on success or nil on
 *          failure; call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_open(vendor_id: cushort; product_id: cushort; serial_number: pcwchar_t): PSDL_hid_device; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_open' {$ENDIF} {$ENDIF};

{*
 * Open a HID device by its path name.
 *
 * The path name be determined by calling SDL_hid_enumerate(), or a
 * platform-specific path name can be used (eg: /dev/hidraw0 on Linux).
 *
 * \param path the path name of the device to open.
 * \returns a Pointer to a SDL_hid_device object on success or nil on
 *          failure; call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_open_path(path: PAnsiChar): PSDL_hid_device; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_open_path' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with an SDL_hid_device.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_HIDAPI_LIBUSB_DEVICE_HANDLE_POINTER`: the libusb_device_handle
 *   associated with the device, if it was opened using libusb.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_hid_get_properties(dev: PSDL_hid_device): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_properties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_HIDAPI_LIBUSB_DEVICE_HANDLE_POINTER = 'SDL.hidapi.libusb.device.handle';

{*
 * Write an Output report to a HID device.
 *
 * The first byte of `data` must contain the Report ID. For devices which only
 * support a single report, this must be set to 0x0. The remaining bytes
 * contain the report data. Since the Report ID is mandatory, calls to
 * SDL_hid_write() will always contain one more byte than the report contains.
 * For example, if a hid report is 16 bytes long, 17 bytes must be passed to
 * SDL_hid_write(), the Report ID (or 0x0, for devices with a single report),
 * followed by the report data (16 bytes). In this example, the length passed
 * in would be 17.
 *
 * SDL_hid_write() will send the data on the first OUT endpoint, if one
 * exists. If it does not, it will send the data through the Control Endpoint
 * (Endpoint 0).
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param data the data to send, including the report number as the first
 *             byte.
 * \param length the length in bytes of the data to send.
 * \returns the actual number of bytes written and -1 on on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_write(dev: PSDL_hid_device; data: pcuchar; length: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_write' {$ENDIF} {$ENDIF};

{*
 * Read an Input report from a HID device with timeout.
 *
 * Input reports are returned to the host through the INTERRUPT IN endpoint.
 * The first byte will contain the Report number if the device uses numbered
 * reports.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param data a buffer to put the read data into.
 * \param length the number of bytes to read. For devices with multiple
 *               reports, make sure to read an extra byte for the report
 *               number.
 * \param milliseconds timeout in milliseconds or -1 for blocking wait.
 * \returns the actual number of bytes read and -1 on on failure; call
 *          SDL_GetError() for more information. If no packet was available to
 *          be read within the timeout period, this function returns 0.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_read_timeout(dev: PSDL_hid_device; data: pcuchar; length: csize_t; milliseconds: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_read_timeout' {$ENDIF} {$ENDIF};

{*
 * Read an Input report from a HID device.
 *
 * Input reports are returned to the host through the INTERRUPT IN endpoint.
 * The first byte will contain the Report number if the device uses numbered
 * reports.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param data a buffer to put the read data into.
 * \param length the number of bytes to read. For devices with multiple
 *               reports, make sure to read an extra byte for the report
 *               number.
 * \returns the actual number of bytes read and -1 on failure; call
 *          SDL_GetError() for more information. If no packet was available to
 *          be read and the handle is in non-blocking mode, this function
 *          returns 0.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_read(dev: PSDL_hid_device; data: pcuchar; length: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_read' {$ENDIF} {$ENDIF};

{*
 * Set the device handle to be non-blocking.
 *
 * In non-blocking mode calls to SDL_hid_read() will return immediately with a
 * value of 0 if there is no data to be read. In blocking mode, SDL_hid_read()
 * will wait (block) until there is data to read before returning.
 *
 * Nonblocking can be turned on and off at any time.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param nonblock enable or not the nonblocking reads - 1 to enable
 *                 nonblocking - 0 to disable nonblocking.
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_set_nonblocking(dev: PSDL_hid_device; nonblock: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_set_nonblocking' {$ENDIF} {$ENDIF};

{*
 * Send a Feature report to the device.
 *
 * Feature reports are sent over the Control endpoint as a Set_Report
 * transfer. The first byte of `data` must contain the Report ID. For devices
 * which only support a single report, this must be set to 0x0. The remaining
 * bytes contain the report data. Since the Report ID is mandatory, calls to
 * SDL_hid_send_feature_report() will always contain one more byte than the
 * report contains. For example, if a hid report is 16 bytes long, 17 bytes
 * must be passed to SDL_hid_send_feature_report(): the Report ID (or 0x0, for
 * devices which do not use numbered reports), followed by the report data (16
 * bytes). In this example, the length passed in would be 17.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param data the data to send, including the report number as the first
 *             byte.
 * \param length the length in bytes of the data to send, including the report
 *               number.
 * \returns the actual number of bytes written and -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_send_feature_report(dev: PSDL_hid_device; data: pcuchar; length: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_send_feature_report' {$ENDIF} {$ENDIF};

{*
 * Get a feature report from a HID device.
 *
 * Set the first byte of `data` to the Report ID of the report to be read.
 * Make sure to allow space for this extra byte in `data`. Upon return, the
 * first byte will still contain the Report ID, and the report data will start
 * in data[1].
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param data a buffer to put the read data into, including the Report ID.
 *             Set the first byte of `data` to the Report ID of the report to
 *             be read, or set it to zero if your device does not use numbered
 *             reports.
 * \param length the number of bytes to read, including an extra byte for the
 *               report ID. The buffer can be longer than the actual report.
 * \returns the number of bytes read plus one for the report ID (which is
 *          still in the first byte), or -1 on on failure; call SDL_GetError()
 *          for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_feature_report(dev: PSDL_hid_device; data: pcuchar; length: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_feature_report' {$ENDIF} {$ENDIF};

{*
 * Get an input report from a HID device.
 *
 * Set the first byte of `data` to the Report ID of the report to be read.
 * Make sure to allow space for this extra byte in `data`. Upon return, the
 * first byte will still contain the Report ID, and the report data will start
 * in data[1].
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param data a buffer to put the read data into, including the Report ID.
 *             Set the first byte of `data` to the Report ID of the report to
 *             be read, or set it to zero if your device does not use numbered
 *             reports.
 * \param length the number of bytes to read, including an extra byte for the
 *               report ID. The buffer can be longer than the actual report.
 * \returns the number of bytes read plus one for the report ID (which is
 *          still in the first byte), or -1 on on failure; call SDL_GetError()
 *          for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_input_report(dev: PSDL_hid_device; data: pcuchar; length: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_input_report' {$ENDIF} {$ENDIF};

{*
 * Close a HID device.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_close(dev: PSDL_hid_device): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_close' {$ENDIF} {$ENDIF};

{*
 * Get The Manufacturer String from a HID device.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param string a wide string buffer to put the data into.
 * \param maxlen the length of the buffer in multiples of wchar_t.
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_manufacturer_string(dev: PSDL_hid_device; _string: pcwchar_t; maxlen: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_manufacturer_string' {$ENDIF} {$ENDIF};

{*
 * Get The Product String from a HID device.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param string a wide string buffer to put the data into.
 * \param maxlen the length of the buffer in multiples of wchar_t.
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_product_string(dev: PSDL_hid_device; _string: pcwchar_t; maxlen: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_product_string' {$ENDIF} {$ENDIF};

{*
 * Get The Serial Number String from a HID device.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param string a wide string buffer to put the data into.
 * \param maxlen the length of the buffer in multiples of wchar_t.
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_serial_number_string(dev: PSDL_hid_device; _string: pcwchar_t; maxlen: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_serial_number_string' {$ENDIF} {$ENDIF};

{*
 * Get a string from a HID device, based on its string index.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param string_index the index of the string to get.
 * \param string a wide string buffer to put the data into.
 * \param maxlen the length of the buffer in multiples of wchar_t.
 * \returns 0 on success or a negative error code on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_indexed_string(dev: PSDL_hid_device; string_index: cint; _string: pcwchar_t; maxlen: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_indexed_string' {$ENDIF} {$ENDIF};

{*
 * Get the device info from a HID device.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \returns a Pointer to the SDL_hid_device_info for this hid_device or nil
 *          on failure; call SDL_GetError() for more information. This struct
 *          is valid until the device is closed with SDL_hid_close().
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_device_info(dev: PSDL_hid_device): PSDL_hid_device_info; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_device_info' {$ENDIF} {$ENDIF};

{*
 * Get a report descriptor from a HID device.
 *
 * User has to provide a preallocated buffer where descriptor will be copied
 * to. The recommended size for a preallocated buffer is 4096 bytes.
 *
 * \param dev a device handle returned from SDL_hid_open().
 * \param buf the buffer to copy descriptor into.
 * \param buf_size the size of the buffer in bytes.
 * \returns the number of bytes actually copied or -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_hid_get_report_descriptor(dev: PSDL_hid_device; buf: pcuchar; buf_size: csize_t): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_get_report_descriptor' {$ENDIF} {$ENDIF};

{*
 * Start or stop a BLE scan on iOS and tvOS to pair Steam Controllers.
 *
 * \param active true to start the scan, false to stop the scan.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_hid_ble_scan(active: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_hid_ble_scan' {$ENDIF} {$ENDIF};

