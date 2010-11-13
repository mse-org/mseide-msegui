{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
{
/***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering
  Copyright 2006 Pierre Ossman <ossman@cendio.se> for Cendio AB

  PulseAudio is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published
  by the Free Software Foundation; either version 2.1 of the License,
  or (at your option) any later version.

  PulseAudio is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with PulseAudio; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***/
}
{
/** \mainpage
 *
 * \section intro_sec Introduction
 *
 * This document describes the client API for the PulseAudio sound
 * server. The API comes in two flavours to accommodate different styles
 * of applications and different needs in complexity:
 *
 * \li The complete but somewhat complicated to use asynchronous API
 * \li The simplified, easy to use, but limited synchronous API
 *
 * All strings in PulseAudio are in the UTF-8 encoding, regardless of current
 * locale. Some functions will filter invalid sequences from the string, some
 * will simply fail. To ensure reliable behaviour, make sure everything you
 * pass to the API is already in UTF-8.

 * \section simple_sec Simple API
 *
 * Use this if you develop your program in synchronous style and just
 * need a way to play or record data on the sound server. See
 * \subpage simple for more details.
 *
 * \section async_sec Asynchronous API
 *
 * Use this if you develop your programs in asynchronous, event loop
 * based style or if you want to use the advanced features of the
 * PulseAudio API. A guide can be found in \subpage async.
 *
 * By using the built-in threaded main loop, it is possible to acheive a
 * pseudo-synchronous API, which can be useful in synchronous applications
 * where the simple API is insufficient. See the \ref async page for
 * details.
 *
 * \section thread_sec Threads
 *
 * The PulseAudio client libraries are not designed to be directly
 * thread-safe. They are however designed to be reentrant and
 * threads-aware.
 *
 * To use the libraries in a threaded environment, you must assure that
 * all objects are only used in one thread at a time. Normally, this means
 * that all objects belonging to a single context must be accessed from the
 * same thread.
 *
 * The included main loop implementation is also not thread safe. Take care
 * to make sure event objects are not manipulated when any other code is
 * using the main loop.
 *
 * \section pkgconfig pkg-config
 *
 * The PulseAudio libraries provide pkg-config snippets for the different
 * modules:
 *
 * \li libpulse - The asynchronous API and the internal main loop implementation.
 * \li libpulse-mainloop-glib - GLIB 2.x main loop bindings.
 * \li libpulse-simple - The simple PulseAudio API.
 */
}
unit msepulseglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
 {$packrecords c}
const
 PA_CHANNELS_MAX = 32;   //** Maximum number of allowed channels */
 PA_RATE_MAX = (48000*4);//** Maximum allowed sample rate */

type
 uint32_t = longword;
 uint8_t = byte;
 size_t = ptruint;
 pa_usec_t = uint64;
 
//** The direction of a pa_stream object */
 pa_stream_direction_t = (
  PA_STREAM_NODIRECTION,   //**< Invalid direction */
  PA_STREAM_PLAYBACK,      //**< Playback stream */
  PA_STREAM_RECORD,        //**< Record stream */
  PA_STREAM_UPLOAD         //**< Sample upload stream */
 );

//** Sample format */
 pa_sample_format_t = (
    PA_SAMPLE_U8,   //**< Unsigned 8 Bit PCM */
    PA_SAMPLE_ALAW, //**< 8 Bit a-Law */
    PA_SAMPLE_ULAW, //**< 8 Bit mu-Law */
    PA_SAMPLE_S16LE,//**< Signed 16 Bit PCM, little endian (PC) */
    PA_SAMPLE_S16BE,//**< Signed 16 Bit PCM, big endian */
    PA_SAMPLE_FLOAT32LE,//**< 32 Bit IEEE floating point, little endian (PC), range -1.0 to 1.0 */
    PA_SAMPLE_FLOAT32BE,//**< 32 Bit IEEE floating point, big endian, range -1.0 to 1.0 */
    PA_SAMPLE_S32LE,//**< Signed 32 Bit PCM, little endian (PC) */
    PA_SAMPLE_S32BE,//**< Signed 32 Bit PCM, big endian */
    PA_SAMPLE_S24LE,//**< Signed 24 Bit PCM packed, little endian (PC). \since 0.9.15 */
    PA_SAMPLE_S24BE,//**< Signed 24 Bit PCM packed, big endian. \since 0.9.15 */
    PA_SAMPLE_S24_32LE,//**< Signed 24 Bit PCM in LSB of 32 Bit words, little endian (PC). \since 0.9.15 */
    PA_SAMPLE_S24_32BE,//**< Signed 24 Bit PCM in LSB of 32 Bit words, big endian. \since 0.9.15 */
    PA_SAMPLE_MAX,//**< Upper limit of valid sample types */
    PA_SAMPLE_INVALID = -1//**< An invalid value */
 );
 
const
{$ifdef endian_big}
 PA_SAMPLE_S16NE = PA_SAMPLE_S16BE;
 PA_SAMPLE_FLOAT32NE = PA_SAMPLE_FLOAT32BE;
 PA_SAMPLE_S32NE = PA_SAMPLE_S32BE;
 PA_SAMPLE_S24NE = PA_SAMPLE_S24BE;
 PA_SAMPLE_S24_32NE = PA_SAMPLE_S24_32BE;
 PA_SAMPLE_S16RE = PA_SAMPLE_S16LE;
 PA_SAMPLE_FLOAT32RE = PA_SAMPLE_FLOAT32LE;
 PA_SAMPLE_S32RE = PA_SAMPLE_S32LE;
 PA_SAMPLE_S24RE = PA_SAMPLE_S24LE;
 PA_SAMPLE_S24_32RE = PA_SAMPLE_S24_32LE;
{$else}
 PA_SAMPLE_S16NE = PA_SAMPLE_S16LE;
 PA_SAMPLE_FLOAT32NE = PA_SAMPLE_FLOAT32LE;
 PA_SAMPLE_S32NE = PA_SAMPLE_S32LE;
 PA_SAMPLE_S24NE = PA_SAMPLE_S24LE;
 PA_SAMPLE_S24_32NE = PA_SAMPLE_S24_32LE;
 PA_SAMPLE_S16RE = PA_SAMPLE_S16BE;
 PA_SAMPLE_FLOAT32RE = PA_SAMPLE_FLOAT32BE;
 PA_SAMPLE_S32RE = PA_SAMPLE_S32BE;
 PA_SAMPLE_S24RE = PA_SAMPLE_S24BE;
 PA_SAMPLE_S24_32RE = PA_SAMPLE_S24_32BE;
{$endif}

type

//** A sample format and attribute specification */
 pa_sample_spec = record
  format: pa_sample_format_t; //**< The sample format */
  rate: uint32_t;             //**< The sample rate. (e.g. 44100) */
  channels: uint8_t;          //**< Audio channels. (1 for mono, 2 for stereo, ...) */
 end;
 ppa_sample_spec = ^pa_sample_spec;

//** A list of channel mapping definitions for pa_channel_map_init_auto() */
 pa_channel_map_def = (
  PA_CHANNEL_MAP_AIFF, //**< The mapping from RFC3551, which is based on AIFF-C */
  PA_CHANNEL_MAP_ALSA, //**< The default mapping used by ALSA. This mapping is probably
                       //* not too useful since ALSA's default channel mapping depends on
                       //* the device string used. */
  PA_CHANNEL_MAP_AUX,  //**< Only aux channels */
  PA_CHANNEL_MAP_WAVEEX,//**< Microsoft's WAVEFORMATEXTENSIBLE mapping. This mapping works
                        //* as if all LSBs of dwChannelMask are set.  */
  PA_CHANNEL_MAP_OSS,   //**< The default channel mapping used by OSS as defined in the OSS
                        //* 4.0 API specs. This mapping is probably not too useful since
                        //* the OSS API has changed in this respect and no longer knows a
                        //* default channel mapping based on the number of channels. */

                        //**< Upper limit of valid channel mapping definitions */
    PA_CHANNEL_MAP_DEF_MAX
 );
 ppa_channel_map_def = ^pa_channel_map_def;
 
const
 PA_CHANNEL_MAP_DEFAULT = PA_CHANNEL_MAP_AIFF; //**< The default channel map */

type

//** A list of channel labels */
 pa_channel_position_t = (
    PA_CHANNEL_POSITION_MONO = 0,
    PA_CHANNEL_POSITION_FRONT_LEFT,     //* Apple, Dolby call this 'Left' */
    PA_CHANNEL_POSITION_FRONT_RIGHT,    //* Apple, Dolby call this 'Right' */
    PA_CHANNEL_POSITION_FRONT_CENTER,   //* Apple, Dolby call this 'Center' */
    PA_CHANNEL_POSITION_REAR_CENTER,    //* Microsoft calls this 'Back Center', Apple calls this 'Center Surround', Dolby calls this 'Surround Rear Center' */
    PA_CHANNEL_POSITION_REAR_LEFT,      //* Microsoft calls this 'Back Left', Apple calls this 'Left Surround' (!), Dolby calls this 'Surround Rear Left'  */
    PA_CHANNEL_POSITION_REAR_RIGHT,     //* Microsoft calls this 'Back Right', Apple calls this 'Right Surround' (!), Dolby calls this 'Surround Rear Right'  */
    PA_CHANNEL_POSITION_LFE,            //* Microsoft calls this 'Low Frequency', Apple calls this 'LFEScreen' */
    PA_CHANNEL_POSITION_FRONT_LEFT_OF_CENTER,     //* Apple, Dolby call this 'Left Center' */
    PA_CHANNEL_POSITION_FRONT_RIGHT_OF_CENTER,    //* Apple, Dolby call this 'Right Center */
    PA_CHANNEL_POSITION_SIDE_LEFT,                //* Apple calls this 'Left Surround Direct', Dolby calls this 'Surround Left' (!) */
    PA_CHANNEL_POSITION_SIDE_RIGHT,               //* Apple calls this 'Right Surround Direct', Dolby calls this 'Surround Right' (!) */
    PA_CHANNEL_POSITION_AUX0,
    PA_CHANNEL_POSITION_AUX1,
    PA_CHANNEL_POSITION_AUX2,
    PA_CHANNEL_POSITION_AUX3,
    PA_CHANNEL_POSITION_AUX4,
    PA_CHANNEL_POSITION_AUX5,
    PA_CHANNEL_POSITION_AUX6,
    PA_CHANNEL_POSITION_AUX7,
    PA_CHANNEL_POSITION_AUX8,
    PA_CHANNEL_POSITION_AUX9,
    PA_CHANNEL_POSITION_AUX10,
    PA_CHANNEL_POSITION_AUX11,
    PA_CHANNEL_POSITION_AUX12,
    PA_CHANNEL_POSITION_AUX13,
    PA_CHANNEL_POSITION_AUX14,
    PA_CHANNEL_POSITION_AUX15,
    PA_CHANNEL_POSITION_AUX16,
    PA_CHANNEL_POSITION_AUX17,
    PA_CHANNEL_POSITION_AUX18,
    PA_CHANNEL_POSITION_AUX19,
    PA_CHANNEL_POSITION_AUX20,
    PA_CHANNEL_POSITION_AUX21,
    PA_CHANNEL_POSITION_AUX22,
    PA_CHANNEL_POSITION_AUX23,
    PA_CHANNEL_POSITION_AUX24,
    PA_CHANNEL_POSITION_AUX25,
    PA_CHANNEL_POSITION_AUX26,
    PA_CHANNEL_POSITION_AUX27,
    PA_CHANNEL_POSITION_AUX28,
    PA_CHANNEL_POSITION_AUX29,
    PA_CHANNEL_POSITION_AUX30,
    PA_CHANNEL_POSITION_AUX31,
    PA_CHANNEL_POSITION_TOP_CENTER,               //* Apple calls this 'Top Center Surround' */
    PA_CHANNEL_POSITION_TOP_FRONT_LEFT,           //* Apple calls this 'Vertical Height Left' */
    PA_CHANNEL_POSITION_TOP_FRONT_RIGHT,          //* Apple calls this 'Vertical Height Right' */
    PA_CHANNEL_POSITION_TOP_FRONT_CENTER,         //* Apple calls this 'Vertical Height Center' */
    PA_CHANNEL_POSITION_TOP_REAR_LEFT,            //* Microsoft and Apple call this 'Top Back Left' */
    PA_CHANNEL_POSITION_TOP_REAR_RIGHT,           //* Microsoft and Apple call this 'Top Back Right' */
    PA_CHANNEL_POSITION_TOP_REAR_CENTER,          //* Microsoft and Apple call this 'Top Back Center' */
    PA_CHANNEL_POSITION_MAX,
    PA_CHANNEL_POSITION_INVALID = -1
 );

const
 PA_CHANNEL_POSITION_LEFT = PA_CHANNEL_POSITION_FRONT_LEFT;
 PA_CHANNEL_POSITION_RIGHT = PA_CHANNEL_POSITION_FRONT_RIGHT;
 PA_CHANNEL_POSITION_CENTER = PA_CHANNEL_POSITION_FRONT_CENTER;
 PA_CHANNEL_POSITION_SUBWOOFER = PA_CHANNEL_POSITION_LFE;
 
type
 pa_channel_position_aty = array[0..PA_CHANNELS_MAX-1] of pa_channel_position_t;

//** A channel map which can be used to attach labels to specific
// * channels of a stream. These values are relevant for conversion and
// * mixing of streams */
 pa_channel_map = record
    chsnnels: uint8_t;  //**< Number of channels */
    map: pa_channel_position_aty; //**< Channel labels */
 end;
 ppa_channel_map = ^pa_channel_map;

//** Playback and record buffer metrics */
 pa_buffer_attr = record
    maxlength: uint32_t; 
    //**< Maximum length of the buffer. Setting this to (uint32_t) -1
     //* will initialize this to the maximum value supported by server,
     //* which is recommended. */
    tlength: uint32_t;
    //**< Playback only: target length of the buffer. The server tries
     //* to assure that at least tlength bytes are always available in
     //* the per-stream server-side playback buffer. It is recommended
     //* to set this to (uint32_t) -1, which will initialize this to a
     //* value that is deemed sensible by the server. However, this
     //* value will default to something like 2s, i.e. for applications
     //* that have specific latency requirements this value should be
     //* set to the maximum latency that the application can deal
     //* with. When PA_STREAM_ADJUST_LATENCY is not set this value will
     //* influence only the per-stream playback buffer size. When
     //* PA_STREAM_ADJUST_LATENCY is set the overall latency of the sink
     //* plus the playback buffer size is configured to this value. Set
     //* PA_STREAM_ADJUST_LATENCY if you are interested in adjusting the
     //* overall latency. Don't set it if you are interested in
     //* configuring the server-side per-stream playback buffer
     //* size. */
    prebuf: uint32_t;
    //**< Playback only: pre-buffering. The server does not start with
     //* playback before at least prebuf bytes are available in the
     //* buffer. It is recommended to set this to (uint32_t) -1, which
     //* will initialize this to the same value as tlength, whatever
     //* that may be. Initialize to 0 to enable manual start/stop
     //* control of the stream. This means that playback will not stop
     //* on underrun and playback will not start automatically. Instead
     //* pa_stream_corked() needs to be called explicitly. If you set
     //* this value to 0 you should also set PA_STREAM_START_CORKED. */
    minreq: uint32_t;
    //**< Playback only: minimum request. The server does not request
     //* less than minreq bytes from the client, instead waits until the
     //* buffer is free enough to request more bytes at once. It is
     //* recommended to set this to (uint32_t) -1, which will initialize
     //* this to a value that is deemed sensible by the server. This
     //* should be set to a value that gives PulseAudio enough time to
     //* move the data from the per-stream playback buffer into the
     //* hardware playback buffer. */
    fragsize: uint32_t;
    //**< Recording only: fragment size. The server sends data in
     //* blocks of fragsize bytes size. Large values diminish
     //* interactivity with other operations on the connection context
     //* but decrease control overhead. It is recommended to set this to
     //* (uint32_t) -1, which will initialize this to a value that is
     //* deemed sensible by the server. However, this value will default
     //* to something like 2s, i.e. for applications that have specific
     //* latency requirements this value should be set to the maximum
     //* latency that the application can deal with. If
     //* PA_STREAM_ADJUST_LATENCY is set the overall source latency will
     //* be adjusted according to this value. If it is not set the
     //* source latency is left unmodified. */
 end;
 ppa_buffer_attr = ^pa_buffer_attr;

implementation
end.
