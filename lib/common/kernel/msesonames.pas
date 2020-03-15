{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesonames;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes;
{$ifdef mswindows}
//const
// sqlite3lib: array[0..0] of filenamety = ('sqlite3.dll');
// postgreslib: array[0..0] of filenamety = ('libpq.dll');
// mysqllib: array[0..0] of filenamety = ('libmysql.dll');
// sslnames: array[0..1] of filenamety = ('ssleay32.dll','libssl32.dll');
// sslutilnames: array[0..0] of filenamety = ('libeay32.dll');
// fbembedlib: array[0..0] of filenamety = ('fbembed.dll');
// fbcgdslib: array[0..1] of filenamety = ('fbclient.dll','gds32.dll');
{$else}
const
 xrendernames: array[0..1] of filenamety = ('libXrender.so.1','libXrender.so');
 xrandrnames: array[0..1] of filenamety = ('libXrandr.so.2','libXrandr.so');
 xftnames: array[0..1] of filenamety = ('libXft.so.2','libXft.so');
 icenames: array[0..1] of filenamety = ('libICE.so.6','libICE.so');
 smnames: array[0..1] of filenamety = ('libSM.so.6','libSM.so');

// sqlite3lib: array[0..1] of filenamety = ('libsqlite3.so.0','libsqlite3.so');
// postgreslib: array[0..2] of filenamety = ('libpq.so.5.1','libpq.so.5','libpq.so');
// mysqllib: array[0..2] of filenamety = ('libmysqlclient.so.16',
//         'libmysqlclient.so.15','libmysqlclient.so');
// sslnames: array[0..4] of filenamety = (
//           'libssl.so.1.0.0','libssl.so.0.9.8','libssl.so.0.9.7','libssl.so.0.9.6',
//           'libssl.so');
// sslutilnames: array[0..4] of filenamety = (
//           'libcrypto.so.1.0.0','libcrypto.so.0.9.8','libcrypto.so.0.9.7','libcrypto.so.0.9.6',
//           'libcrypto.so');
// fbembedlib: array[0..2] of filenamety = ('libfbembed.so.2','libfbembed.so.1',
//                                          'libfbembed.so');
// fbcgdslib: array[0..3] of filenamety = ('libfbclient.so.2','libfbclient.so.1',
//                                          'libfbclient.so','libgds.so');
{$endif}

implementation

end.
