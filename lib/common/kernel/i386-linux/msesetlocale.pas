unit msesetlocale;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 libc,cwstring,msesys;
 
implementation
uses
 sysutils,msestrings;
 
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
    'b': result:= result + 'MMM';
    'B': result:= result + 'MMMM';
    'c': result:= result + 'c';
//  'C':
    'd': result:= result + 'dd';
    'D': result:= result + 'MM/dd/yy';
    'e': result:= result + 'd';
//  'E':
    'g': result:= result + 'yy';
    'G': result:= result + 'yyyy';
    'h': result:= result + 'MMM';
    'H': result:= result + 'HH';
    'I': result:= result + 'hh';
//  'j':
    'k': result:= result + 'H';
    'l': result:= result + 'h';
    'm': result:= result + 'MM';
    'M': result:= result + 'nn'; 
    'n': result:= result + lineend;
//  'O':
    'P','p': result:= result + 'AMPM';
    'r': result:= result + convertcformatstring(nl_langinfo(t_fmt_ampm),'');
    'R': result:= result + 'HH:mm';
//  's':
    'S': result:= result + 'ss';
    't': result:= result + c_tab;
    'T': result:= result + 'HH:mm:ss';
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
 ch1,ch2,ch3: char;
 str1,str2: string;
 mstr1: msestring;

 currfo: array[0..1,0..1] of byte = ((1,3),(0,2));
           //[p_cs_precedes,p_sep_by_space]
 negcurrfo: array[0..1,0..1,0..4] of byte =
                (((4,5,7,6,7),(15,8,10,13,10)),((0,1,3,1,2),(14,9,11,9,12)));
           //[n_cs_precedes,n_sep_by_space,n_sign_posn]
{$endif}
begin
 initdefaultformatsettings; 
 //msesys initialization will be called after msesetlocale initialization.
 //FPC bug?
 
 with defaultformatsettingsmse do begin
 {$ifdef FPC}
  mstr1:= getlocstr(decimal_point,decimalseparator);
  if mstr1 <> '' then begin
   decimalseparator:= mstr1[1];
  end;
  mstr1:= getlocstr(thousands_sep,thousandseparator);
  if mstr1 <> '' then begin
   thousandseparator:= mstr1[1];
  end;
  
  for int1:= 1 to 12 do begin
   shortmonthnames[int1]:= getlocstr(abmon_1 + int1 - 1,shortmonthnames[int1]);
   longmonthnames[int1]:= getlocstr(mon_1 + int1 - 1,longmonthnames[int1]);
  end;
  for int1:= 1 to 7 do begin
   shortdaynames[int1]:= getlocstr(abday_1 + int1 - 1,shortdaynames[int1]);
   longdaynames[int1]:= getlocstr(day_1 + int1 - 1,longdaynames[int1]);
  end;
  shortdateformat:= convertcformatstring(getlocstr(d_fmt,''),shortdateformat);
  str1:= getlocstr(d_t_fmt,'');
  str2:= getlocstr(t_fmt,''); 
  int1:= pos(str2,str1);
  if int1 > 0 then begin
   str1:= trimright(copy(str1,1,int1-1));
  end;
  longdateformat:= convertcformatstring(str1,longdateformat);   
 // longdateformat:= convertcformatstring(getlocstr(d_t_fmt,''),longdateformat);   
  shorttimeformat:= convertcformatstring(getlocstr(t_fmt,''),shorttimeformat);
  longtimeformat:= convertcformatstring(getlocstr(t_fmt_ampm,''),longtimeformat);
  findfirstchar(shortdateformat,'./-',dateseparator);
  findfirstchar(shorttimeformat,':.',timeseparator);
  
  timeamstring:= getlocstr(am_str,timeamstring);
  timepmstring:= getlocstr(pm_str,timepmstring);
  currencystring:= getlocstr(currency_symbol,currencystring);
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
 {$ifdef FPC}{$checkpointer default}{$endif}
 {$endif} 
 end;
end;

initialization
 setlocale(LC_ALL,'');
 initformatsettings;
end.
