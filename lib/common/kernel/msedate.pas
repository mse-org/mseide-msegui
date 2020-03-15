{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedate;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
const
 unidatetimeoffset = -25569;

function nowutc: tdatetime;
function nowlocal: tdatetime;
function maxdays(year: word; month: word): word;
function utctolocaltime(const value: tdatetime): tdatetime;
function localtimetoutc(const value: tdatetime): tdatetime;
function unixtodatetime(const value: longword): tdatetime;

implementation
uses
 msesysintf1,msesysintf;

function nowutc: tdatetime;
begin
 result:= sys_getutctime;
end;

function nowlocal: tdatetime;
begin
 result:= sys_getlocaltime;
end;

function utctolocaltime(const value: tdatetime): tdatetime;
begin
 result:= sys_utctolocaltime(value);
// result:= value + sys_localtimeoffset;
end;

function localtimetoutc(const value: tdatetime): tdatetime;
begin
 result:= sys_localtimetoutc(value);
// result:= value - sys_localtimeoffset;
end;

function unixtodatetime(const value: longword): tdatetime;
begin
 result:= value/(24.0*60*60) - unidatetimeoffset;
end;

function maxdays(year: word; month: word): word;
begin
 if month = 0 then begin
  year:= year - 1;
  month:= 12;
 end;
 if month = 14 then begin
  year:= year + 1;
  month:= 1;
 end;
 if month = 13 then begin
  month:= 12;
 end;
 case  month of
  1,3,5,7,8,10,12:
   result:= 31;
  2: begin
   if (year mod 4 = 0) and (not (year mod 100 = 0) or (year mod 400 = 0)) then
    result:= 29
   else
    result:= 28;
  end;
  else
   result:= 30;
 end;
end;


end.
