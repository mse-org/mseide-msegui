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
