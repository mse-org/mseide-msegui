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
 msestrings;
 
type
 floatstringmodety = (fsm_default,fsm_fix,fsm_sci,fsm_engfix,fsm_engfloat);
 
function doubletostring(value: double; precision: byte;
      mode: floatstringmodety = fsm_default;
      decimalsep: msechar = '.'; thousandsep: msechar = #0): msestring;
function intexp10(aexp: integer): double;

implementation
uses
 sysutils;
 
const
 binexps: array[0..8] of double = (1e1,1e2,1e4,1e8,1e16,1e32,1e64,1e128,1e256);

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
 do1:= 1;
 if int2 > $1ff then begin
  raise exception.create('Exponent overflow');
 end;
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

function doubletostring(value: double; precision: byte;
      mode: floatstringmodety = fsm_default;
      decimalsep: msechar = '.'; thousandsep: msechar = #0): msestring;
  //format double:
  // 1  11  52
  //|s| e | f | 

type
 doublerecty = packed record       //little endian
  case integer of
   0: (by0,by1,by2,by3,by4,by5,by6,by7: byte);
   1: (wo0,wo1,wo2,wo3: word);
   2: (lwo0,lwo1: longword);
   3: (qwo0: qword);
 end;
 bufferty =  array[0..30] of msechar;
 
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
 expmask = $7ff0;             //for wo3
 halfexp = (1023-1) shl 4;    //value >= 0.5 for wo3
 exp2to10 = ln(2)/ln(10);
 maxdigits = 17;
 defaultprecision = maxdigits-2;
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
 
begin
 with doublerecty(value) do begin
  neg:= by7 and $80 <> 0;
  by7:= by7 and $7f; //remove sign
  exp:= (wo3 and %0111111111110000) shr 4;
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
    if precision >= maxdigits then begin
     precision:= maxdigits;
    end;
    case mode of
     fsm_sci,fsm_engfix,fsm_engfloat: begin
      if precision = 0 then begin
       result:= '0e+000';
       exit;
      end;
      int2:= precision+6;
      setlength(result,int2+1);
      for int1:= 0 to int2 do begin
       pmsecharaty(result)^[int1]:= '0';
      end;
      pmsecharaty(result)^[int2-4]:= 'e';
      pmsecharaty(result)^[int2-3]:= '+';
     end;
     else begin          //fix format
      if (precision = 0) or defaultmode then begin
       result:= '0';
       exit;
      end
      else begin
       int2:= precision+1;
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
    precision:= maxdigits;
    if (value < 1e-6) or (value >= 1e15) then begin
     mode:= fsm_sci;
    end;
   end;
   
   if mode >= fsm_sci then begin                 //exp format
    if intdigits < 0 then begin
     dec(intdigits);      //trunk -> floor
    end;
    int3:= intdigits;
    if (mode = fsm_engfloat) then begin
     do1:= value / intexp10(intdigits);
     if do1 >= exps[1] then begin
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
     if (do1 >= exps[1]) then begin
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
    else begin
     if (do1 >= exps[3]) then begin
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
    if neg then begin
     do1:= -do1;
    end;      
    if mode = fsm_engfloat then begin
     precision:= precision - intdigits + int3;
     if shortint(precision) < 0 then begin
      precision:= 0;
     end;
    end;
    if defaultmode then begin
     mode1:= fsm_default;
    end
    else begin
     mode1:= fsm_fix;
    end;
    result:= doubletostring(do1,precision,mode1,decimalsep);
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
    (po1-2)^:= 'e';
    exit;
   end;                                      //exp format ^^^
      
   lastindex:= intdigits + precision;        //fix format
   int1:= maxdigits;
   if defaultmode then begin
    int1:= defaultprecision;
   end;
   if lastindex > int1 then begin
    precision:= precision - lastindex + int1;
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
//    if do1 < exps[1] then begin          //< 10
//     do1:= do1 * exps[1];                //value 1..10
//     dec(lastindex);
//    end;

   if lastindex >= 1 then begin         //calculate numbers
    for int1:= 1 to lastindex do begin
     int2:= trunc(do1);
     buffer[int1]:= msechar(int2+ord('0'));
     checkcarry(int1,buffer);
     do1:= frac(do1)*10;       
    end;
    do1:= do1 - 5 + exps[lastindex] / system.exp(52*ln(2));
    if (do1 > 0) then begin
     inc(buffer[lastindex]);
     checkcarry(lastindex,buffer);
    end;
    if defaultmode then begin
     int2:= lastindex - precision + 1; //remove trayling zeros
     for int1:= lastindex downto int2 do begin
      if (buffer[int1] <> '0') then begin
       precision:= precision - lastindex + int1;
       lastindex:= int1;
       break;
      end;
      if int1 = int2 then begin
       precision:= 0;
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
   if precision > 0 then begin
    inc(space);                      //add space for decimal separator
   end;

   if exp < 0 then begin             //<1, no int
    space:= space + precision;        
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
    if precision > 0 then begin
     inc(po1,space - precision + 1); //decimal separator
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
     thousandsepcount:= (lastindex-leadingzeros-precision) div 3;
     space:= space + thousandsepcount;
    end;
    space:= space + lastindex - leadingzeros;
    setlength(result,space+1);
    po1:= pmsechar(pointer(result)) + space;
    if precision > 0 then begin
     for int3:= lastindex downto lastindex - precision + 1 do begin
      po1^:= buffer[int3];         //fract
      dec(po1);
     end;
     po1^:= decimalsep;
     dec(po1);
     for int3:= lastindex - precision downto leadingzeros do begin
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
     int4:= space - precision;            //last int char
     if precision > 0 then begin
      dec(int3);                          //thousand separator 
      dec(int4);              
     end;
     po1:= pmsechar(pointer(result)) + int3 - thousandsepcount;
     for int3:= int3 to space - precision - 3 do begin
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

end.
