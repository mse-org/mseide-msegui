unit mxrandr;
{/*
 * Copyright © 2000 Compaq Computer Corporation, Inc.
 * Copyright © 2002 Hewlett-Packard Company, Inc.
 * Copyright © 2006 Intel Corporation
 * Copyright © 2008 Red Hat, Inc.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that copyright
 * notice and this permission notice appear in supporting documentation, and
 * that the name of the copyright holders not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  The copyright holders make no representations
 * about the suitability of this software for any purpose.  It is provided "as
 * is" without express or implied warranty.
 *
 * THE COPYRIGHT HOLDERS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 * EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
 * OF THIS SOFTWARE.
 *
 * Author:  Jim Gettys, HP Labs, Hewlett-Packard, Inc.
 *	    Keith Packard, Intel Corporation
 */}
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msectypes,mx,mxlib;

{$packrecords c}

const
//* Event selection bits */
 RRScreenChangeNotifyMask = 1 shl 0;
///* V1.2 additions */
 RRCrtcChangeNotifyMask = 1 shl 1;
 RROutputChangeNotifyMask = 1 shl 2;
 RROutputPropertyNotifyMask = 1 shl 3;
//* V1.4 additions */
 RRProviderChangeNotifyMask = 1 shl 4;
 RRProviderPropertyNotifyMask = 1 shl 5;
 RRResourceChangeNotifyMask = 1 shl 6;

//* Event codes */
 RRScreenChangeNotify = 0;
//* V1.2 additions */
 RRNotify = 1;
//* RRNotify Subcodes */
 RRNotify_CrtcChange = 0;
 RRNotify_OutputChange = 0;
 RRNotify_OutputProperty = 2;
 RRNotify_ProviderChange = 3;
 RRNotify_ProviderProperty = 4;
 RRNotify_ResourceChange = 5;
 rrlastnotify = RRNotify + 5;

//* used in the rotation field; rotation and reflection in 0.1 proto. */
 RR_Rotate_0 = 1;
 RR_Rotate_90 = 2;
 RR_Rotate_180 = 4;
 RR_Rotate_270 = 8;

//* new in 1.0 protocol, to allow reflection of screen */

 RR_Reflect_X = 16;
 RR_Reflect_Y = 32;

type
 Window = txid;
 Rotation = cushort;
 Connection = cushort;
 SubpixelOrder = cushort;
 SizeID = cushort;

 RROutput = txid;
 pRROutput = ^RROutput;
 RRCrtc = txid;
 pRRCrtc = ^RRCrtc;
 RRMode = txid;
 pRRMode = ^RRMode;
 RRProvider = txid;
 pRRProvider = ^RRProvider;

 Time = culong;
 pTime = pculong;

 XRRModeFlags = culong;

 XRRModeInfo = record
  id: RRMode;
  width: cuint;
  height: cuint;
  dotClock: culong;
  hSyncStart: cuint;
  hSyncEnd: cuint;
  hTotal: cuint;
  hSkew: cuint;
  vSyncStart: cuint;
  vSyncEnd: cuint;
  vTotal: cuint;
  name: pchar;
  nameLength: cuint;
  modeFlags: XRRModeFlags;
 end;
 pXRRModeInfo = ^XRRModeInfo;

 XRRScreenResources = record
  timestamp: Time;
  configTimestamp:Time;
  ncrtc: cint;
  crtcs: pRRCrtc;
  noutput: cint;
  outputs:  pRROutput;
  nmode:  cint;
  modes:  pXRRModeInfo;
 end;
 pXRRScreenResources = ^XRRScreenResources;

 XRROutputInfo = record
  timestamp: Time;
  crtc: RRCrtc;
  name: pcchar;
  nameLen: cint;
  mm_width: culong;
  mm_height: culong;
  connection: Connection;
  subpixel_order: SubpixelOrder;
  ncrtc: cint ;
  crtcs: pRRCrtc;
  nclone: cint;
  clones: pRROutput;
  nmode: cint;
  npreferred: cint;
  modes: pRRMode;
 end;
 pXRROutputInfo = ^XRROutputInfo;

 XRRCrtcInfo = record
  timestamp: Time;
  x,y: cint;
  width,height:  cuint;
  mode: RRMode;
  rotation: Rotation;
  noutput: cint;
  outputs: pRROutput;
  rotations: Rotation;
  npossible: cint;
  possible: pRROutput;
 end;
 pXRRCrtcInfo = ^XRRCrtcInfo;

 XRRScreenChangeNotifyEvent = record
  _type: cint ;           //* event base */
  serial: culong;         //* # of last request processed by server */
  send_event: cBool;       //* true if this came from a SendEvent request */
  display: pDisplay;      //* Display the event was read from */
  window: Window;         //* window which selected for this event */
  root: Window;           //* Root window for changed screen */
  timestamp: Time ;       //* when the screen change occurred */
  config_timestamp: Time; //* when the last configuration change */
  size_index: SizeID;
  subpixel_order: SubpixelOrder;
  rotation: Rotation;
  width: cint;
  height: cint;
  mwidth: cint;
  mheight: cint;
 end;

var
 XRRQueryExtension: function (dpy: pDisplay; event_base_return: pcint;
                                      error_base_return: pcint): cBool cdecl;
 XRRGetScreenResources: function(dpy: pDisplay;
                                 window: Window): pXRRScreenResources cdecl;
 XRRFreeScreenResources: procedure(resources: pXRRScreenResources) cdecl;
 XRRGetCrtcInfo: function(dpy: pDisplay; resources: pXRRScreenResources;
                                 crtc: RRCrtc): pXRRCrtcInfo cdecl;
 XRRFreeCrtcInfo: procedure(crtcInfo: pXRRCrtcInfo) cdecl;
 XRRGetOutputInfo: function(dpy: pDisplay; resources: pXRRScreenResources;
                                     output: RROutput): pXRROutputInfo cdecl;
 XRRFreeOutputInfo: procedure(outputInfo: pXRROutputInfo) cdecl;

 XRRSelectInput: procedure(dpy: pDisplay; window: Window; mask: cint) cdecl;
 XRRUpdateConfiguration: function(event: pXEvent): cint cdecl;

function getxrandrlib: boolean;

implementation
uses
 msesys,msesonames,msedynload;

function getxrandrlib: boolean;
const
//  (n: ''; d: @)
 funcs: array[0..8] of funcinfoty = (
  (n: 'XRRQueryExtension'; d: @XRRQueryExtension),
  (n: 'XRRGetScreenResources'; d: @XRRGetScreenResources),
  (n: 'XRRFreeScreenResources'; d: @XRRFreeScreenResources),
  (n: 'XRRGetCrtcInfo'; d: @XRRGetCrtcInfo),
  (n: 'XRRFreeCrtcInfo'; d: @XRRFreeCrtcInfo),
  (n: 'XRRGetOutputInfo'; d: @XRRGetOutputInfo),
  (n: 'XRRFreeOutputInfo'; d: @XRRFreeOutputInfo),
  (n: 'XRRSelectInput'; d: @XRRSelectInput),
  (n: 'XRRUpdateConfiguration'; d: @XRRUpdateConfiguration)
 );

begin
 result:= checkprocaddresses(xrandrnames,funcs);
end;

end.
