{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefirebird;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 firebird,msestrings,msectypes;

const
{$ifdef mswindows}
 {$define wincall}
 firebirdlib: array[0..0] of filenamety = ('fbclient.dll');
{$else}
 firebirdlib: array[0..2] of filenamety = 
             ('libfbclient.so.3','libfbclient.so.2','libfbclient.so');
{$endif}

const
 SQL_TEXT =          452;
 SQL_VARYING =       448;
 SQL_SHORT =         500;
 SQL_LONG =          496;
 SQL_FLOAT =         482;
 SQL_DOUBLE =        480;
 SQL_D_FLOAT =       530;
 SQL_TIMESTAMP =     510;
 SQL_BLOB =          520;
 SQL_ARRAY =         540;
 SQL_QUAD =          550;
 SQL_TYPE_TIME =     560;
 SQL_TYPE_DATE =     570;
 SQL_INT64 =         580;
 SQL_BOOLEAN =     32764;
 SQL_NULL =        32766;
(*
#define dtype_unknown	0
#define dtype_text		1
#define dtype_cstring	2
#define dtype_varying	3

#define dtype_packed	6
#define dtype_byte		7
#define dtype_short		8
#define dtype_long		9
#define dtype_quad		10
#define dtype_real		11
#define dtype_double	12
#define dtype_d_float	13
#define dtype_sql_date	14
#define dtype_sql_time	15
#define dtype_timestamp	16
#define dtype_blob		17
#define dtype_array		18
#define dtype_int64		19
#define dtype_dbkey		20
#define dtype_boolean	21
#define DTYPE_TYPE_MAX	22

static const USHORT type_alignments[DTYPE_TYPE_MAX] =
{
	0,
	0,							/* dtype_text */
	0,							/* dtype_cstring */
	sizeof(SSHORT),				/* dtype_varying */
	0,							/* unused */
	0,							/* unused */
	sizeof(SCHAR),				/* dtype_packed */
	sizeof(SCHAR),				/* dtype_byte */
	sizeof(SSHORT),				/* dtype_short */
	sizeof(SLONG),				/* dtype_long */
	sizeof(SLONG),				/* dtype_quad */
	sizeof(float),				/* dtype_real */
	FB_DOUBLE_ALIGN,			/* dtype_double */
	FB_DOUBLE_ALIGN,			/* dtype_d_float */
	sizeof(GDS_DATE),			/* dtype_sql_date */
	sizeof(GDS_TIME),			/* dtype_sql_time */
	sizeof(GDS_DATE),			/* dtype_timestamp */
	sizeof(SLONG),				/* dtype_blob */
	sizeof(SLONG),				/* dtype_array */
	sizeof(SINT64),				/* dtype_int64 */
	sizeof(ULONG),				/* dtype_dbkey */
	sizeof(UCHAR)				/* dtype_boolean */
};

static const USHORT type_lengths[DTYPE_TYPE_MAX] =
{
	0,
	0,							/* dtype_text */
	0,							/* dtype_cstring */
	0,							/* dtype_varying */
	0,							/* unused */
	0,							/* unused */
	0,							/* dtype_packed */
	sizeof(SCHAR),				/* dtype_byte */
	sizeof(SSHORT),				/* dtype_short */
	sizeof(SLONG),				/* dtype_long */
	sizeof(ISC_QUAD),			/* dtype_quad */
	sizeof(float),				/* dtype_real */
	sizeof(double),				/* dtype_double */
	sizeof(double),				/* dtype_d_float */
	sizeof(GDS_DATE),			/* dtype_sql_date */
	sizeof(GDS_TIME),			/* dtype_sql_time */
	sizeof(GDS_TIMESTAMP),		/* dtype_timestamp */
	sizeof(ISC_QUAD),			/* dtype_blob */
	sizeof(ISC_QUAD),			/* dtype_array */
	sizeof(SINT64),				/* dtype_int64 */
	sizeof(RecordNumber::Packed), /*dtype_dbkey */
	sizeof(UCHAR)				/* dtype_boolean */
};
*)

type
 ISC_USHORT	= cushort;
 ISC_SHORT = cshort;
 pISC_SHORT = ^ISC_SHORT;

 vary = packed record
  vary_length: ISC_USHORT;
  vary_string: record
  end;
 end;
 pvary = ^vary;
 
procedure initializefirebird(const sonames: array of filenamety;
                                          const onlyonce: boolean = false);
                                     //[] = default
procedure releasefirebird();

function formatstatus(status: istatus): string;
//function getstatus(): istatus;

var
 fb_get_master_interface: function: IMaster
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
implementation
uses
 msedynload,msetypes;
var 
 libinfo: dynlibinfoty;
 master: imaster;
 util: iutil;
 
procedure initfb();
begin
 master:= fb_get_master_interface();
 util:= master.getutilinterface();
end;

procedure releasefb();
begin
 //nothing to do
end;

procedure initializefirebird(const sonames: array of filenamety; //[] = default
                                         const onlyonce: boolean = false);
                                     
const
 funcs: array[0..0] of funcinfoty = (
  (n: 'fb_get_master_interface'; d: @fb_get_master_interface)
 );
 errormessage = 'Can not load Firebird library. ';

begin
 if not onlyonce or (libinfo.refcount = 0) then begin
  initializedynlib(libinfo,sonames,firebirdlib,funcs,[],errormessage,@initfb);
 end;
end;

procedure releasefirebird();
begin
 releasedynlib(libinfo,@releasefb);
end;

function formatstatus(status: istatus): string;
var
 ca1: card32;
begin
 setlength(result,256);
 while true do begin
  ca1:= util.formatstatus(pointer(result),length(result),status);
  if ca1 < length(result) then begin
   break;
  end;
  setlength(result,2*length(result));
 end;
 setlength(result,ca1);
end;
{
function getstatus(): istatus;
begin
 result:= master.getstatus();
end;
}
initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
