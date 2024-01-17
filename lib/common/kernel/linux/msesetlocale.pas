{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesetlocale;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mselibc,msesys;

function getcodeset(): string;

implementation
uses
{$if defined(openbsd) or defined(darwin)} cwstring {$else} msecwstring {$endif} ,sysutils,msestrings,mseformatstr,msetypes,msesysintf;

function getlocstr(const id: integer; const defaultvalue: string): string;
var
 po1: pchar;
begin
 po1:= nl_langinfo(id);
 if po1 = nil then begin
  result:= defaultvalue;
 end
 else begin
  result:= po1;
 end;
end;

function getcodeset(): string;
begin
 result:= getlocstr(codeset,'');
end;

function convertcformatstring(const source,defaultvalue: string): string;
var
 po1: pchar;
begin
 result:= '';
 po1:= pchar(source);
 while po1^ <> #0 do begin
  if po1^ = '%' then begin
   inc(po1);
   case po1^ of
    '%': result:= result + '%';
    'a': result:= result + 'ddd';
    'A': result:= result + 'dddd';
    'b': result:= result + 'mmm';
    'B': result:= result + 'mmmm';
    'c': result:= result + 'c';
//  'C':
    'd': result:= result + 'dd';
    'D': result:= result + 'mm/dd/yy';
    'e': result:= result + 'd';
//  'E':
    'g': result:= result + 'yy';
    'G': result:= result + 'yyyy';
    'h': result:= result + 'mmm';
    'H': result:= result + 'HH';
    'I': result:= result + 'hh';
//  'j':
    'k': result:= result + 'H';
    'l': result:= result + 'h';
    'm': result:= result + 'mm';
    'M': result:= result + 'nn';
    'n': result:= result + lineend;
//  'O':
    'P','p': result:= result + 'ampm';
    'r': result:= result + convertcformatstring(nl_langinfo(t_fmt_ampm),'');
    'R': result:= result + 'hh:nn';
//  's':
    'S': result:= result + 'ss';
    't': result:= result + c_tab;
    'T': result:= result + 'hh:nn:ss';
//  'u':
//  'U':
//  'V':
//  'w':
//  'W':
    'x': result:= result + convertcformatstring(nl_langinfo(d_fmt),'');
    'X': result:= result + convertcformatstring(nl_langinfo(t_fmt),'');
    'y': result:= result + 'yy';
    'Y': result:= result + 'yyyy';
//  'z':
   end;
  end
  else begin
   result:= result + po1^;
  end;
  inc(po1);
 end;
 result:= trimright(result);
 if result = '' then begin
  result:= defaultvalue;
 end;
end;

procedure findfirstchar(const value,chars: msestring; var result: msechar);
var
 int1: integer;
 po1: pmsechar;
begin
 po1:= pmsechar(value);
 while po1^ <> #0 do begin
  for int1:= 1 to length(chars) do begin
   if po1^ = chars[int1] then begin
    result:= po1^;
    break;
   end;
  end;
  inc(po1);
 end;
end;

procedure initformatsettings;
{$ifdef FPC}
var
 int1: integer;
 ch1,ch2{$ifdef linux},ch3{$endif}: char;
 str1,str2: string;
 mstr1: msestring;
{$ifndef linux}
 bo1: boolean;
{$endif}

 currfo: array[0..1,0..1] of byte = ((1,3),(0,2));
           //[p_cs_precedes,p_sep_by_space]
{$ifdef linux}
 negcurrfo: array[0..1,0..1,0..4] of byte =
                (((4,5,7,6,7),(15,8,10,13,10)),((0,1,3,1,2),(14,9,11,9,12)));
           //[n_cs_precedes,n_sep_by_space,n_sign_posn]
{$endif}
{$endif}
begin
 initdefaultformatsettings;
 //msesys initialization will be called after msesetlocale initialization.
 //FPC bug?

 with defaultformatsettingsmse do begin
 {$ifdef FPC}
  mstr1:= msestring(getlocstr(decimal_point,ansistring(decimalseparator)));
  if mstr1 <> '' then begin
   decimalseparator:= mstr1[1];
  end;
  mstr1:= msestring(getlocstr(thousands_sep,ansistring(thousandseparator)));
  if mstr1 <> '' then begin
   thousandseparator:= mstr1[1];
  end
  else begin
   mstr1:= msestring(getlocstr(mon_decimal_point,ansistring(decimalseparator)));
   if mstr1 <> '' then begin
    decimalseparator:= mstr1[1];
    mstr1:= msestring(getlocstr(mon_thousands_sep,
                                         ansistring(thousandseparator)));
    if mstr1 <> '' then begin
     thousandseparator:= mstr1[1];
    end
    else begin
     thousandseparator:= ' ';
    end;
   end
   else begin
    thousandseparator:= ' ';
   end;
  end;

  for int1:= 1 to 12 do begin
   shortmonthnames[int1]:= msestring(getlocstr(abmon_1 + int1 - 1,
                                ansistring(shortmonthnames[int1])));
   longmonthnames[int1]:= msestring(getlocstr(mon_1 + int1 - 1,
                                ansistring(longmonthnames[int1])));
  end;
  for int1:= 1 to 7 do begin
   shortdaynames[int1]:= msestring(getlocstr(abday_1 + int1 - 1,
                                ansistring(shortdaynames[int1])));
   longdaynames[int1]:= msestring(getlocstr(day_1 + int1 - 1,
                                ansistring(longdaynames[int1])));
  end;
  shortdateformat:= msestring(convertcformatstring(getlocstr(d_fmt,''),
                                   ansistring(shortdateformat)));
  str1:= getlocstr(d_t_fmt,'');
  str2:= getlocstr(t_fmt,'');
  int1:= pos(str2,str1);
  if int1 > 0 then begin
   str1:= trimright(copy(str1,1,int1-1));
  end;
  longdateformat:= msestring(convertcformatstring(str1,
                                          ansistring(longdateformat)));
 // longdateformat:= convertcformatstring(getlocstr(d_t_fmt,''),longdateformat);
  shorttimeformat:= msestring(convertcformatstring(getlocstr(t_fmt,''),
                                          ansistring(shorttimeformat)));
  longtimeformat:= msestring(convertcformatstring(getlocstr(t_fmt_ampm,''),
                                          ansistring(longtimeformat)));
  findfirstchar(shortdateformat,'./-',dateseparator);
  findfirstchar(shorttimeformat,':.',timeseparator);

  timeamstring:= msestring(getlocstr(am_str,ansistring(timeamstring)));
  if timeamstring = '' then begin
   timeamstring:= 'am';
  end;
  timepmstring:= msestring(getlocstr(pm_str,ansistring(timepmstring)));
  if timepmstring = '' then begin
   timepmstring:= 'pm';
  end;
  currencystring:= msestring(getlocstr(currency_symbol,
                                         ansistring(currencystring)));
{$ifdef linux}
 {$ifdef FPC}{$checkpointer off}{$endif}
  ch1:= nl_langinfo(p_cs_precedes)^;
  ch2:= nl_langinfo(p_sep_by_space)^;
  if (ch1 in [#0,#1]) and (ch2 in [#0,#1]) then begin
   currencyformat:= currfo[ord(ch1),ord(ch2)];
   ch3:= nl_langinfo(p_sign_posn)^;
   if ord(ch3) in [0..4] then begin
    negcurrformat:= negcurrfo[ord(ch1),ord(ch2),ord(ch3)];
   end;
  end;
  ch1:= nl_langinfo(frac_digits)^;
  if byte(ch1) < 127 then begin
   currencydecimals:= ord(ch1);
  end;
{$else} //bsd
 if currencystring <> '' then begin
  ch1:= #0;
  ch2:= #0;
  bo1:= true;
  case currencystring[1] of
   '-': ch1:= #1;
   '+': ch1:= #0;
   '.': ch1:= #0; //not suported
   else bo1:= false;
  end;
  if bo1 then begin
   currencystring:= copy(currencystring,2,bigint);
   currencyformat:= currfo[ord(ch1),ord(ch2)];
  end;
 end;
{$endif}
  saveformatsettings;
 {$ifdef FPC}{$checkpointer default}{$endif}
 {$endif}
 end;

 str1:= strlowercase(getcodeset());
 if (str1 = 'utf8') or (str1 = 'utf-8') then begin
  filenameutfoptions:= [uto_storeinvalid];
 end;
end;

initialization
 setlocale(LC_ALL,'');
 initformatsettings;
end.
