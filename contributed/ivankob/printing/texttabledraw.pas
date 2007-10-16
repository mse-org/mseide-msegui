{ Copyright (c) 2007 by IvankoB

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit texttabledraw;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msetypes, msestrings, sysutils,msedrawtext;

{
 Pseudo-graphic chars to construct table frames
}
const
 u_r = #9484; // +-- 
              // |                 
 
 _h_ = #9472; // --

 h_d = #9516; // --+--
              //   | 

 r_d = #9488; // --+
              //   | 

 _v_ = #9474; // |

 v_r = #9500; // |
              // +-- 
              // |

 d_r = #9492; // |
              // +--

 h_u = #9524; //   |
              // --+--

 r_u = #9496; //   |
              // --+

 v_l = #9508; //   |
              // --+
              //   | 

 h_v = #9532; //   |
              // --+--
              //   | 

type
 line_pos = (fl_upper,fl_middle,fl_bottom); // which frame line to draw

 line_opts = (flo_left,flo_right,flo_vert,flo_top,flo_bottom,flo_vertdouble,flo_horzdouble);
 lineoptsty = set of line_opts;

 text_align = (tak_left,tak_right,tak_centered);
 textalignarty = array of text_align;

{ ==================================================================

 Produces an array[0..n] of msestrings from several columns of msestring data
 
 Example of usage :

  var 
   ar1: msestringarty;

  begin: 
   ar1:= getdataline(
    opentodynarrayi([0,5,10,15]), // note four items here ( one more than of values )
    opentodynarraym(['qwertyuio','dddssssssssssss ','aaaaaaaaaaa ggggggg']),
    opentodynarraybo([true,true,true]),
    mktextalignar([tak_left,tak_left,tak_left])
   );
   
   for i:=0 to high(ar1) do begin
    writeln(ucs2to866(ar1[i]));     
   end 
}

function getdataline(
  tabpos: integerarty; // Zero-based each, the quantity is one plus to the quantity of AVALUES
  avalues: msestringarty; 
  dobreak: booleanarty; // FALSE each by default
  alignment: textalignarty; // tak_left each by default
  lineopts: lineoptsty = [flo_left,flo_right,flo_vert]  
): msestringarty;

{ ==================================================================

 Produces an msestring presenting one line of table frame
 
 Example of usage :
 
   writeln(ucs2to866(getframeline(
    opentodynarrayi([0,5,10,15]),
    l_middle
   )));  
}

function getframeline (
 const tabpos: integerarty; 
 const lpos: line_pos = fl_middle;
 lineopts: lineoptsty = [flo_left,flo_right,flo_vert,flo_top,flo_bottom] 
): msestring;

{
 An workaround for FPC "dynaray <> openarray" on assignment
}
function mktextalignar(const items: array of text_align): textalignarty;


implementation

uses
 strutils;


// ========================================

function getdataline(
  tabpos: integerarty; // на одну больше, чем значений
  avalues: msestringarty; 
  dobreak: booleanarty; 
  alignment: textalignarty;
  lineopts: lineoptsty = [flo_left,flo_right,flo_vert]
 ): msestringarty;
 var
  i,j,i1,tabhigh,valhigh,brkhigh,alhigh,valhigh1: integer;
  value_len,tab_len: integer;
  ar1: msestringararty;
  s1: msestring;
  ar2: integerarty;
  rc, mc,lc: widechar;
 begin

  tabhigh:= high(tabpos);
  valhigh:= high(avalues);
  brkhigh:= high(dobreak);
  alhigh:=  high(alignment);
  valhigh1:= alhigh;

  if tabhigh < 1
   then raise exception.create('TEXTTABLEDRAW.GETDATALINE: There shoulb be at least two tabs specified');

  if (valhigh >= tabhigh) or (alhigh >= tabhigh) or (brkhigh >= tabhigh)
   then raise exception.create('TEXTTABLEDRAW.GETDATALINE: Numbers of AVALUES/DOBREAK/ALIGMNENT should be less than of TABPOS');

  if tabhigh > (valhigh + 1) then begin
   setlength(avalues,tabhigh); // by one less than TABHIGH
   valhigh:= tabhigh -1; 
  end;
  setlength(ar2,tabhigh); // where to store TAB_LEN for each AVALUES[i]
   
  if tabhigh > (brkhigh + 1) then setlength(dobreak,tabhigh);
  if tabhigh > (alhigh  + 1) then setlength(alignment,tabhigh);

  // поочередно по всем табуляторам
  setlength(ar1,length(avalues)); // массив выходных столбцов строк
  i1:= 0;

  for i:= 0 to tabhigh - 1 do begin // кроме последнего табулятора

   tab_len:= tabpos[i+1] - tabpos[i] - 1; // максимальная ширина текста после табулятора
   ar2[i]:= tab_len;

// вписать умолчания для незаданных входных аргументов
   if i > valhigh1 then avalues[i]:=   charstring(#$0020,tab_len);
   if i > brkhigh then dobreak[i]:=   false;
   if i > alhigh  then alignment[i]:= tak_left;   

   if tab_len < 1 
    then raise exception.create('TEXTTABLEDRAW.GETDATALINE: Position of not starting tab should be at least of previous one plus two');

   value_len:= length(avalues[i]); // ширина полученного текста

   if (value_len > tab_len) and dobreak[i] then begin // если текст не помещается в табуляторе и нельзя обрезать
    ar1[i]:= breaklines(avalues[i],tab_len); // разбить его на строки в ширину табулятора
    // заполнить пустоты пробелами
    for j:= 0 to high(ar1[i]) do begin
     s1:= trim(ar1[i][j]);
     case alignment[i] of
      tak_centered: ar1[i][j]:= padcenter(s1,tab_len);
      tak_right:    ar1[i][j]:= padright(s1,tab_len);
      else          ar1[i][j]:= padleft(s1,tab_len);
     end;
    end;
   end else begin // помещается или можно обрезать
    // обрезать текст по ширине табулятора и заполнить пустоты пробелами
    s1:= leftstr(trim(avalues[i]),tab_len);
    setlength(ar1[i],1); // на выходе столбца будет однострочный массив
    case alignment[i] of
     tak_centered: ar1[i][0]:= padcenter(s1,tab_len);
     tak_right:    ar1[i][0]:= padright(s1,tab_len);
     else          ar1[i][0]:= padleft(s1,tab_len);
    end;
   end;

   if high(ar1[i]) > i1 then i1:= high(ar1[i]); // число строк - для определения самого высокого столбца строк
  end;

  rc:= #$0020; mc:= #$0020; lc:= #$0020;
  if flo_left  in lineopts then lc:= _v_;
  if flo_vert  in lineopts then mc:= _v_;
  if flo_right in lineopts then rc:= _v_;

  // настроить результат на максимальное найденное число строк
  setlength(result, i1+1); 
  for i:= 0 to i1 do begin // вниз
   result[i]:= lc; // каждый столбец начинается с верт. линии
   for j:= 0 to valhigh do begin // вправо

    if i > (length(ar1[j])-1) then  // столбец содержит меньше значений, чем максимальное
     s1:= charstring(#$0020,ar2[j])  // дописать эти значения как пустые
    else 
     s1:= ar1[j][i];
     
    if j < valhigh then 
     result[i]:= result[i] + s1 + mc
    else 
     result[i]:= result[i] + s1 + rc
     
   end;
  end;

 end;
 
// ========================================
 
function getframeline (
 const tabpos: integerarty; 
 const lpos: line_pos = fl_middle;
 lineopts: lineoptsty = [flo_left,flo_right,flo_vert,flo_top,flo_bottom]
): msestring; 
var
 rc, mc,lc, hc: widechar;
 i,i1: integer;
 s1: msestring;
begin
 rc:= #$0020; mc:= #$0020; lc:= #$0020; hc:= #$0020;
 
 case lpos of
  fl_upper: begin
  
   if flo_top in lineopts then begin
     hc:= _h_;
     if flo_left  in lineopts then lc:= u_r else lc:= _h_;
     if flo_vert  in lineopts then mc:= h_d else mc:= _h_;
     if flo_right in lineopts then rc:= r_d else rc:= _h_;
    end else begin
     if flo_left  in lineopts then lc:= _v_;
     if flo_vert  in lineopts then mc:= _v_;
     if flo_right in lineopts then rc:= _v_;
    end;
    
  end;
  
  fl_middle: begin
   if (flo_top in lineopts) or (flo_bottom in lineopts) then begin
     hc:= _h_;
     if flo_left  in lineopts then lc:= v_r else lc:= _h_;
     if flo_vert  in lineopts then mc:= h_v else mc:= _h_;
     if flo_right in lineopts then rc:= v_l else rc:= _h_;
    end else begin
     if flo_left  in lineopts then lc:= _v_;
     if flo_vert  in lineopts then mc:= _v_;
     if flo_right in lineopts then rc:= _v_;
    end;

  end;

  fl_bottom: begin
   if flo_bottom in lineopts then begin
     hc:= _h_;
     if flo_left  in lineopts then lc:= d_r else lc:= _h_;
     if flo_vert  in lineopts then mc:= h_u else mc:= _h_;
     if flo_right in lineopts then rc:= r_u else rc:= _h_;
    end else begin
     if flo_left  in lineopts then lc:= _v_;
     if flo_vert  in lineopts then mc:= _v_;
     if flo_right in lineopts then rc:= _v_;
    end;

  end;

 end; 

 result:= '';

 i1:= high(tabpos);
 if i1 < 1 
  then raise exception.create('TEXTTABLEDRAW.GETFRAMELINE: At least 2 tabulators are required !');

 for i:= 0 to i1-1 do begin // до предпоследнего табулятора
  if i = 0 
   then result:= lc; // на первом табуляторе рисуем открывающий символ
    
  result:= result + charstring(_h_, tabpos[i+1]-tabpos[i]-1); 
    
  if i < i1-1 then begin // до-предпоследний табулятор
   result:= result + mc; // рисуем горизон. линию и промежут символ   
  end else begin // предпоследний табулятор
   result:= result + rc; // дописываем завершаюший символ
  end;

 end;

end;
 
//===================================== 
 
function mktextalignar(const items: array of text_align): textalignarty; 
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do result[int1]:= items[int1];
end;
 

end.
