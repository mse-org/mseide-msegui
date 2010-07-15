{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefloattostr;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,msetypes;

const
 expochar = msechar('E');
 
type
 floatstringmodety = (fsm_default,fsm_fix,fsm_sci,fsm_engfix,fsm_engflo,
                      fsm_engsymfix,fsm_engsymflo);
// {$ifndef FPC}
// qword = int64;
// {$endif}
 doublerecty = packed record       //little endian
  case integer of
   0: (by0,by1,by2,by3,by4,by5,by6,by7: byte);
   1: (wo0,wo1,wo2,wo3: word);
   2: (lwo0,lwo1: longword);
   3: (qwo0: qword);
 end;

function doubletostring(value: double; precision: integer;
      mode: floatstringmodety = fsm_default;
      decimalsep: msechar = '.'; thousandsep: msechar = #0): msestring;
               //precision <= 0 -> remove trailing 0
               //precision = 0 in fsm_default mode = maximal precision
               
function intexp10(aexp: integer): double;

implementation
uses
 sysutils;
 
const
 binexps: array[0..8] of double = (1e1,1e2,1e4,1e8,1e16,1e32,1e64,1e128,1e256);

type
 expsymty = 
 //    -8         -7         -6         -5      -4       -3        -2        -1        0
  (exs_yocto=-8,exs_zepto,exs_atto,exs_femto,exs_pico,exs_nano,exs_micro,exs_milli,
//    0
   exs_none,
//    1        2       3        4        5        6       7           8
   exs_kilo,exs_mega,exs_giga,exs_tera,exs_peta,exs_exa,exs_zetta,exs_yotta);
   
const
 expsyms: array[expsymty] of msechar = 
       ('y','z','a','f','p','n','u','m',
        ' ',
        'k','M','G','T','P','E','Z','Y');
        
function intexp10(aexp: integer): double;
var
 do1: double;
 int1,int2,int3: integer;
begin
 int2:= abs(aexp);
 if int2 = 0 then begin
  result:= 1;
  exit;
 end;
 if int2 > $1ff then begin
  raise exception.create('Exponent overflow');
 end;
 do1:= 1;
 int3:= 1;
 for int1:= 0 to 8 do begin
  if int2 and int3 <> 0 then begin
   do1:= do1 * binexps[int1];
  end;
  int3:= int3 shl 1;
 end;
 if aexp < 0 then begin
  result:= 1/do1;
 end
 else begin
  result:= do1;
 end;
end;

function doubletostring1(value: double; out msbcarry: boolean;
      precision: integer; mode: floatstringmodety = fsm_default;
      decimalsep: msechar = '.'; thousandsep: msechar = #0): msestring;
  //format double:
  // 1  11  52
  //|s| e | f | 

const
 maxdigits = 17;
 defaultprecision = maxdigits-2;

type
 bufferty =  array[0..30] of msechar;

 function getfixoverflowvalue: msestring;
 var
  int1: integer;
 begin
//  if precision = 0 then begin
   int1:= defaultprecision-1;
   if precision < 0 then begin
    int1:= -int1;
   end;
//  end
//  else begin
//   int1:= precision;
//  end;
  result:= doubletostring(value,int1,fsm_sci,decimalsep,thousandsep);
 end;
  
 procedure checkcarry(start: byte; var dest: bufferty);
 var
  int1: integer;
 begin
  for int1:= start downto 1 do begin
   if dest[int1] <= '9' then begin
    break;
   end;
   dec(dest[int1],10);
   inc(dest[int1-1]); //carry
  end;
 end;

const
{$ifndef FPC}
 lsbrounding = 2.2517998136852482e015;
{$else}
 lsbrounding = exp(51*ln(2));
{$endif}
 expo0max = 1-1/lsbrounding;
 expo1max = 10-10/lsbrounding;
 expo3max = 1000-1000/lsbrounding;
 expmask = $7ff0;             //for wo3
 halfexp = (1023-1) shl 4;    //value >= 0.5 for wo3
{$ifndef FPC}
 exp2to10 = 0.30102999566398121;
{$else}
 exp2to10 = ln(2)/ln(10);
{$endif}
 exps: array[0..maxdigits] of double =
 (1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17);

var
 buffer: bufferty;
 neg: boolean;
 nan: boolean;
 inf: boolean;
 defaultmode: boolean;
 exp: smallint;
 do1: double;
 int1,int2,int3,int4: integer;
 lastindex,intdigits,leadingzeros,space,thousandsepcount: integer;
 po1: pmsechar;
 mode1: floatstringmodety;
 preci: integer;
 
begin
 msbcarry:= false;
 preci:= abs(precision);
 with doublerecty(value) do begin
  neg:= by7 and $80 <> 0;
  by7:= by7 and $7f; //remove sign
 {$ifndef FPC}
  exp:= (wo3 and $7ff0) shr 4;
 {$else}
  exp:= (wo3 and %0111111111110000) shr 4;
 {$endif}
  nan:= false;
  inf:= false;
  if exp = 2047 then begin
   if (lwo0 <> 0) or (lwo1 and $000fffff <> 0) then begin
    nan:= true;
   end
   else begin
    inf:= true;
   end;
  end;
 end;
 defaultmode:= mode = fsm_default;
 if nan then begin
  result:= 'Nan';
 end
 else begin
  if inf then begin
   if neg then begin
    result:= '-Inf';
   end
   else begin
    result:= '+Inf';
   end;
  end
  else begin
   if exp = 0 then begin                       // value = 0
    if preci >= maxdigits then begin
     preci:= maxdigits;
    end;
    case mode of
     fsm_sci,fsm_engfix,fsm_engflo,fsm_engsymfix,fsm_engsymflo: begin
      if preci = 0 then begin
       if mode in [fsm_engsymfix,fsm_engsymflo] then begin
        result:= '0 ';
       end
       else begin
        result:= '0E+000';
       end;
       exit;
      end;
      if mode in [fsm_engsymfix,fsm_engsymflo] then begin
       int2:= preci+2;
      end
      else begin
       int2:= preci+6;
      end;
      setlength(result,int2+1);
      for int1:= 0 to int2 do begin
       pmsecharaty(result)^[int1]:= '0';
      end;
      if mode in [fsm_engsymfix,fsm_engsymflo] then begin
       pmsecharaty(result)^[int2]:= ' ';
      end
      else begin
       pmsecharaty(result)^[int2-4]:= expochar;
       pmsecharaty(result)^[int2-3]:= '+';
      end;
     end;
     else begin          //fix format
      if (preci = 0) or defaultmode then begin
       result:= '0';
       exit;
      end
      else begin
       int2:= preci+1;
       setlength(result,int2+1);
       for int1:= 0 to int2 do begin
        pmsecharaty(result)^[int1]:= '0';
       end;
      end;
     end;
    end;
    pmsecharaty(result)^[1]:= decimalsep;
    exit;
   end;
   
   exp:= exp - 1023;              //value <> 0
   do1:= exp*exp2to10;
   intdigits:= trunc(do1);
   if defaultmode then begin
    if preci = 0 then begin
     preci:= maxdigits;
    end;
    if (value < 1e-6) or (value >= 1e15) then begin
     mode:= fsm_sci;
    end;
   end;
   
   if mode >= fsm_sci then begin                 //exp format
    if intdigits < 0 then begin
     dec(intdigits);      //trunk -> floor
    end;
    int3:= intdigits;
    if mode in [fsm_engflo,fsm_engsymflo] then begin
     do1:= value / intexp10(intdigits);
     if do1 >= expo1max then begin
      inc(intdigits);     //correct overflow for precision correction
     end;
    end;

    if mode >= fsm_engfix then begin              
     if int3 < 0 then begin
      int3:= int3 + ((-int3) mod 3) - 3;
     end
     else begin
      int3:= int3 - (int3 mod 3);
     end;
    end;
    if int3 < 0 then begin
     do1:= intexp10(-int3);
     do1:= value*do1;
    end
    else begin
     do1:= intexp10(int3);
     do1:= value/do1;
    end;
    if (mode < fsm_engfix) then begin //fsm_sci
     if (do1 >= expo1max) then begin
      do1:= do1 / exps[1];
      inc(int3);
     end
     else begin
      if (do1 < exps[0]) then begin
       do1:= do1 * exps[1];
       dec(int3);
      end
     end;
    end
    else begin              //fsm_engfix,fsm_engflo,fsm_engsyfix,fsm_engsyflo
     if (do1 >= expo3max) then begin
      do1:= do1 / exps[3];
      inc(int3,3);
     end
     else begin
      if (do1 < exps[0]) then begin
       do1:= do1 * exps[3];
       dec(int3,3);
      end
     end;
    end;
//    if neg then begin
//     do1:= -do1;
//    end;      
    if mode in [fsm_engflo,fsm_engsymflo] then begin
     if (intdigits = 0) and (int3 < 0)then begin
      dec(intdigits);   //trunc -> floor
     end;
     preci:= preci - intdigits + int3;
     if preci < 0 then begin
      preci:= 0;
     end;
    end;
    if defaultmode and (precision = 0) then begin
     mode1:= fsm_default;
    end
    else begin
     mode1:= fsm_fix;
    end;
    int1:= preci;
    if (precision < 0) or defaultmode and (precision = 0) then begin
     int1:= -int1;
    end;
    result:= doubletostring1(do1,msbcarry,int1,mode1,decimalsep); //get mantissa digits
    if msbcarry then begin 
     if mode1 = fsm_fix then begin
      if (int1 <= 0) then begin    //999.99-> 1000.00 -> 1000 (trimmed trailing 0) 
       if (mode >= fsm_engfix) then begin
//        int4:= 3;
//        if result[1] = '-' then begin
//         inc(int4);
//        end;
        if length(result) > 3{int4} then begin
         if precision > 0 then begin
          setlength(result,length(result)-3+precision+1);
          result[length(result)-precision]:= decimalsep;
         end
         else begin
          setlength(result,length(result)-3);
         end;
         int3:= int3 + 3; //correct carry, 999.99-> 1000 -> 1
        end;
       end
       else begin
        setlength(result,length(result)-1);
        inc(int3);       //correct carry, 9.9999-> 10 -> 1
       end;
      end
      else begin
       if mode >= fsm_engfix then begin
        if (length(result) >= 5) and (result[5] = decimalsep) then begin
         pmsecharaty(result)^[4]:= result[4];
         pmsecharaty(result)^[3]:= result[3];
         pmsecharaty(result)^[2]:= result[2];
         pmsecharaty(result)^[1]:= decimalsep;
         if (mode = fsm_engfix) or (mode = fsm_engsymfix) then begin
          setlength(result,length(result)-3); //correct carry, 999.999-> 1000.000 -> 1.000
         end
         else begin
          setlength(result,length(result)-1); //correct carry, 999.999-> 1000.000 -> 1.00000
         end;
         int3:= int3+3;   
        end
        else begin
         if (mode = fsm_engflo) or (mode = fsm_engsymflo) then begin
          if length(result) > precision + 2 then begin
           setlength(result,length(result)-1); //correct carry, 99.999-> 100.000 -> 100.00
          end;
         end
        end;
       end
       else begin
        if length(result) > precision + 2 then begin
         pmsecharaty(result)^[2]:= result[2];
         pmsecharaty(result)^[1]:= decimalsep;
         setlength(result,length(result)-1);   //correct carry, 9.999 ->10.000 -> 1.000
         inc(int3);
        end;
       end;
      end;
     end;
    end;
    if neg then begin
     result:= '-'+result;
    end;
    int1:= int3 div 3;
    if (mode >= fsm_engsymfix) and (int1 >= ord(low(expsymty))) and 
                                        (int1 <= ord(high(expsymty))) then begin
     int2:= length(result)+1;
     setlength(result,int2);
     (pmsechar(pointer(result))+int2-1)^:= expsyms[expsymty(int1)]; 
                                                  //exponent symbol
    end
    else begin
     int2:= length(result)+5;
     setlength(result,int2);
     po1:= pmsechar(pointer(result))+int2;
     if int3 < 0 then begin
      (po1-4)^:= '-';
     end
     else begin
      (po1-4)^:= '+';
     end;
     int3:= abs(int3);
     for int1:= 0 to 2 do begin
      dec(po1);
      po1^:= msechar(ord('0')+(int3 mod 10));
      int3:= int3 div 10;
     end;      
     (po1-2)^:= expochar;
    end;
    exit;
   end;                                      //exp format ^^^

   if value > 999999999999999 then begin
    result:= getfixoverflowvalue;
    exit;
   end;
   lastindex:= intdigits + preci;           //fix format
   int1:= maxdigits - 1;
   if defaultmode then begin
    int1:= defaultprecision - 1;
   end;
   if lastindex > int1 then begin
    preci:= preci - lastindex + int1;
    if (preci < 0) then begin
     result:= getfixoverflowvalue;
     exit;
    end;
    lastindex:= int1;
   end;
   inc(lastindex);
   buffer[0]:= '0';    //for carry  
   if intdigits < 0 then begin
    do1:= value*exps[-intdigits];
   end
   else begin
    do1:= value/exps[intdigits];        //value 0.1..10
   end;
   
   if (exp = -1) and (do1 >= expo0max) then begin
    exp:= 0;                            //fix for no int test
   end;

   if lastindex >= 1 then begin         //calculate numbers
    for int1:= 1 to lastindex do begin
     int2:= trunc(do1);
     buffer[int1]:= msechar(int2+ord('0'));
     checkcarry(int1,buffer);
     do1:= frac(do1)*10;       
    end;
    do1:= do1 - 5 + exps[lastindex] / lsbrounding; //round up lsb
    msbcarry:= buffer[0] = '0';
    if (do1 > 0) then begin
     inc(buffer[lastindex]);
     checkcarry(lastindex,buffer);
    end;
    msbcarry:= msbcarry and (buffer[0] <> '0');
    if  (precision < 0) or (defaultmode and (precision = 0)) then begin
     int2:= lastindex - preci + 1; //remove trayling zeros
     for int1:= lastindex downto int2 do begin
      if (buffer[int1] <> '0') then begin
       preci:= preci - lastindex + int1;
       lastindex:= int1;
       break;
      end;
      if int1 = int2 then begin
       preci:= 0;
       lastindex:= int1-1;
      end;
     end;
    end;
   end
   else begin
    lastindex:= 0;                  //single '0'
   end;

   space:= 0;                        //update string
   if neg then begin
    inc(space);                      //add space for sign
   end;
   if preci > 0 then begin
    inc(space);                      //add space for decimal separator
   end;

   if exp < 0 then begin             //<1, no int
    space:= space + preci;        
    setlength(result,space+1);       //add space for leading zero
    po1:= pmsechar(pointer(result))+space;
    if lastindex > space then begin
     lastindex:= space;
    end;
    for int1:= lastindex downto 0 do begin
     po1^:= buffer[int1];
     dec(po1);
    end;
    for int1:= space - lastindex - 1 downto 0 do begin
     po1^:= '0';                    //fill rest with '0'
     dec(po1);
    end;
    if preci > 0 then begin
     inc(po1,space - preci + 1); //decimal separator
     (po1-1)^:= po1^;                //move possible carry
     po1^:= decimalsep;
    end;
   end
   else begin                        //>1 with int
    leadingzeros:= 0;
    while buffer[leadingzeros] = '0' do begin
     inc(leadingzeros);                     //remove leading '0'
    end;
    thousandsepcount:= 0;
    if thousandsep <> #0 then begin
     thousandsepcount:= (lastindex-leadingzeros-preci) div 3;
     space:= space + thousandsepcount;
    end;
    space:= space + lastindex - leadingzeros;
    setlength(result,space+1);
    po1:= pmsechar(pointer(result)) + space;
    if preci > 0 then begin
     for int3:= lastindex downto lastindex - preci + 1 do begin
      po1^:= buffer[int3];         //fract
      dec(po1);
     end;
     po1^:= decimalsep;
     dec(po1);
     for int3:= lastindex - preci downto leadingzeros do begin
      po1^:= buffer[int3];         //int
      dec(po1);
     end;
    end
    else begin
     for int3:= lastindex downto leadingzeros do begin
      po1^:= buffer[int3];         //int
      dec(po1);
     end;
    end;
    if thousandsepcount > 0 then begin
     int3:= space-lastindex+leadingzeros; //first int char
     int4:= space - preci;            //last int char
     if preci > 0 then begin
      dec(int3);                          //thousand separator 
      dec(int4);              
     end;
     po1:= pmsechar(pointer(result)) + int3 - thousandsepcount;
     for int3:= int3 to space - preci - 3 do begin
      po1^:= pmsecharaty(result)^[int3];
      inc(po1);
      if (int3 - int4) mod 3 = 0 then begin
       po1^:= thousandsep;
       inc(po1);
      end;
     end;
    end;
   end;
   if neg then begin
    pmsechar(pointer(result))^:= '-';
   end;
  end;
 end;
end;

function doubletostring(value: double; precision: integer;
      mode: floatstringmodety = fsm_default;
      decimalsep: msechar = '.'; thousandsep: msechar = #0): msestring;
var
 bo1: boolean;
begin
 result:= doubletostring1(value,bo1,precision,mode,decimalsep,thousandsep); 
end;

end.
