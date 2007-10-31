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
 msetypes, msestrings, sysutils, msestream;

{
 Pseudo-graphic chars to construct table frames
}
const

 pad_char = #0035;
 
 horz_graphoff  = #0045;  // "-" char
 vert_graphoff  = #0124;  // "|" char
 cross_graphoff = #0043;  // "+" char

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

 cond_ratio = 132/80;

 epson_lh_cmd = #0027'3';
 ibm_lh_cmd   = #0027'3';
 lj_lh_cmd    = #0027'3';

 epson_deflh_cmd = #0027'2';
 ibm_deflh_cmd   = #0027'3'#0036;
 lj_deflh_cmd    = #0027'2';

 epson_hs_cmd = #0027'U0'#0027'x0'#0027'F'#0027'H';
 ibm_hs_cmd   = #0027'U0'#0027'I0'#0027'F'#0027'H';
 lj_hs_cmd    = #0027'U0'#0027'x0'#0027'F'#0027'H';

 epson_hq_cmd = #0027'x1';
 ibm_hq_cmd   = #0027'I1';
 lj_hq_cmd    = #0027'x1';
 
 epson_10cpi_cmd = #0018#0027'P';
 ibm_10cpi_cmd   = #0018;
 lj_10cpi_cmd    = #0018#0027'P';
 
 epson_12cpi_cmd = #0018#0027'M';
 ibm_12cpi_cmd   = #0018#0027':';
 lj_12cpi_cmd    = #0018#0027'M';

 epson_cond_cmd = #0015;
 ibm_cond_cmd   = #0015;
 lj_cond_cmd    = #0015;

 epson_reset_cmd = #0017#0027'@';
 ibm_reset_cmd   = #0017#0027'[K';
 lj_reset_cmd    = #0017#0027'@';

 epson_init_cmd = epson_reset_cmd + epson_deflh_cmd + epson_10cpi_cmd + epson_hs_cmd ;
 ibm_init_cmd   = ibm_reset_cmd   + ibm_deflh_cmd   + ibm_10cpi_cmd   + ibm_hs_cmd ;
 lj_init_cmd    = lj_reset_cmd    + lj_deflh_cmd    + lj_10cpi_cmd    + lj_hs_cmd ;

type

 prn_quality = (pq_fast,pq_nlq);
 prn_density = (pd_10cpi,pd_12cpi,pd_cond);

 line_pos = (fl_upper,fl_middle,fl_bottom); // which frame line to draw

 line_opts = (flo_left,flo_right,flo_vert,flo_top,flo_bottom,flo_vertdouble,flo_horzdouble);
 lineoptsty = set of line_opts;

 textalignarty = array of stringposty;

 clip_opts =  (clo_break,clo_trunc,clo_pad);
 clipoptarty = array of clip_opts;

 prn_type = (prn_epson, prn_ibm, prn_lj);
 output_encoding = (enc_latin1, enc_ru866);

 ttextprinter = class
 private
  ftype: prn_type;
  fgraphoff: boolean;
  freset_cmd: shortstring;
  finit_cmd: shortstring;
  fdeflh_cmd: shortstring;
  fhs_cmd: shortstring;
  fhq_cmd: shortstring;
  flh_cmd: shortstring;
  fdpi_coeff: integer;
  fcpi10_cmd: shortstring;
  fcpi12_cmd: shortstring;
  fcond_cmd: shortstring; 
  fdebugfilename: msestring;
  fdebugstream: ttextstream;
  fdebugprint: boolean;
  fautoprint: boolean;
  fisprinting: boolean;
  foutputencoding: output_encoding;
  
  procedure internalchecklst;
  procedure internalendprint;
  
 protected
  { Initializes the printer settings for a choosen type }   
  procedure settype(const atype: prn_type);
  procedure setdebugprint(const avalue: boolean);  
 
 public
  constructor Create(const atype: prn_type = prn_epson);
  destructor Destroy;  
  property printer_type: prn_type read ftype write settype;
  property outputencoding: output_encoding read foutputencoding write foutputencoding;
  property graphoff : boolean read fgraphoff write fgraphoff;

  property debugprint : boolean read fdebugprint write setdebugprint;  
  property debugfilename: msestring read fdebugfilename write fdebugfilename;  
  property isprinting: boolean read fisprinting;  
  
  { Causes the printer to print GETDATALINE/GETFRAMELINE return automatically }
  property autoprint: boolean read fautoprint write fautoprint;  

  { Returns the printer command of reset }
  property reset_cmd: shortstring read freset_cmd;

  { Returns the printer command of init to some relevant defaults }
  property init_cmd: shortstring  read finit_cmd;

  { Returns printer command of line interval, "avalue" in mm }
  function lh_cmd(const avalue: real): shortstring;

  { Returns printer command of default line interval}
  property deflh_cmd: shortstring read fdeflh_cmd;

  { Returns the printer command of setting print quality acc to the suplied switch }
  function qual_cmd(const avalue: prn_quality): shortstring;

  { Returns the printer command of setting char horizontal density acc to the suplied switch }
  function dens_cmd(const avalue: prn_density): shortstring;

  procedure writelnp(const avalue: msestring);
  procedure writep(const avalue: msestring);
  
  procedure beginprint;
  procedure endprint;
  
 //==========================
  

 { ==================================================================

  Produces an array[0..n] of msestrings from several columns of msestring data
 
   Example of usage :

   var 
    ar1: msestringarty;

    begin:

     ar1:= getdataline(
      mktabar([0,4,34,44,54,67]),
      mkvaluear([
       inttostr(curr_num),
       fieldbyname('edition_name').asstring,
       fldAmount.asstring,
       floattostrf(fldPrice.ascurrency,ffFixed,0,2),
       floattostrf(fldSumma.ascurrency,ffFixed,0,2)
      ]),
      mkclipoptar([clo_pad,clo_break,clo_pad,clo_pad,clo_pad]),
      mktextalignar([sp_center,sp_left,sp_center,sp_right,sp_right])
     );
     for i:=0 to high(ar1) do writelnp(ucs2to866(ar1[i]));
  }

  function getdataline(
   tabpos: integerarty; // Zero-based each, the quantity is one plus to the quantity of AVALUES
   avalues: msestringarty; // input string data to format
   clipopts: clipoptarty; // "clo_trunc" each by default
   alignment: textalignarty; // tak_left each by default
   lineopts: lineoptsty = [flo_left,flo_right,flo_vert]  // which frame lines to draw
  ): msestringarty;

  { ==================================================================

  Produces an msestring presenting one line of table frame
 
  Example of usage :

    writelnp(ucs2to866(getframeline(
     mktabar([0,4,34,44,54,67]),
     fl_bottom,
     mktabar([0,4,5]
   )));;

  }

  function getframeline (
   const tabpos: integerarty; // Zero-based each, the quantity is one plus to the quantity of AVALUES
   const lpos: line_pos = fl_middle; // which part of table this line presents
   juttabs: integerarty = []; // zero-based, numbers of tabs which also expand outward (really applicable for fl_top & fl_bottom)
   lineopts: lineoptsty = [flo_left,flo_right,flo_vert,flo_top,flo_bottom] // which frame lines to draw
  ): msestring;

  
 end;

{ ================================================================== }

{ An workaround for FPC "dynaray <> openarray" on assignment }
function mktextalignar(const items: array of stringposty): textalignarty; 

{ Returns empty string if AVALUE can be considered as a string presentaion of "0" value}
function zero2emptystr(const avalue: msestring): msestring; 

function mkclipoptar(const items: array of clip_opts): clipoptarty; 
function mktabar(const items: array of integer): integerarty; 
function mkvaluear(const items: array of msestring): msestringarty; 


implementation

uses
 strutils,
 msedatalist,
 printer,
 msesys,
 mseucs2toru;


// ==================== GENERIC TEXT PROCESSING FUNCTIONS ====================

function ttextprinter.getdataline(
  tabpos: integerarty; // на одну больше, чем значений
  avalues: msestringarty; 
  clipopts: clipoptarty; 
  alignment: textalignarty;
  lineopts: lineoptsty = [flo_left,flo_right,flo_vert]
 ): msestringarty;
 var
  i,j,i1,tabhigh,valhigh,brkhigh,alhigh,valhigh1: integer;
  value_len,tab_len: integer;
  ar1: msestringararty;
  s1,s2: msestring;
  ar2: integerarty;
  rc, mc,lc: widechar;
  ipadchar: widechar;
 begin

  tabhigh:= high(tabpos);
  valhigh:= high(avalues);
  brkhigh:= high(clipopts);
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
   
  if tabhigh > (brkhigh + 1) then setlength(clipopts,tabhigh);
  if tabhigh > (alhigh  + 1) then setlength(alignment,tabhigh);

  // поочередно по всем табуляторам
  setlength(ar1,length(avalues)); // массив выходных столбцов строк
  i1:= 0;
  
  // определение левого отступа, если табуляторы начинаются не с начала строки
  if tabpos[0] > 0 then
   s2:= charstring(#$0020, tabpos[0])
  else
   s2:= '';

  for i:= 0 to tabhigh - 1 do begin // кроме последнего табулятора

   tab_len:= tabpos[i+1] - tabpos[i] - 1; // максимальная ширина текста после табулятора
   ar2[i]:= tab_len;

// вписать умолчания для незаданных входных аргументов
   if i > valhigh1 then avalues[i]:=   charstring(#$0020,tab_len);
   if i > brkhigh then clipopts[i]:=   clo_trunc;
   if i > alhigh  then alignment[i]:=  sp_left;   

   if tab_len < 1 
    then raise exception.create('TEXTTABLEDRAW.GETDATALINE: Position of not starting tab should be at least of previous one plus two');

   value_len:= length(avalues[i]); // ширина полученного текста

   if (value_len < tab_len)  then begin 

    s1:= avalues[i]; 
    setlength(ar1[i],1); // на выходе столбца будет однострочный массив
    ar1[i][0]:=  fitstring(s1,tab_len,alignment[i]);
   
   end else if (value_len = tab_len)  then begin 
   
    setlength(ar1[i],1); // на выходе столбца будет однострочный массив   
    ar1[i][0]:= avalues[i];
    
   end else begin 
   
    // не помещается
    s1:= leftstr(trim(avalues[i]),tab_len);
    
    case clipopts[i] of
    
     clo_trunc: begin
      setlength(ar1[i],1); // на выходе столбца будет однострочный массив
      ar1[i][0]:= s1;
     end;
     
     clo_break: begin

      ar1[i]:= breaklines(avalues[i],tab_len); // разбить его на строки в ширину табулятора
      // заполнить пустоты пробелами
      for j:= 0 to high(ar1[i]) do begin
       s1:= trim(ar1[i][j]);
       ar1[i][j]:= fitstring(s1,tab_len,alignment[i]);
      end;   

     end;
     
     clo_pad: begin
      setlength(ar1[i],1); // на выходе столбца будет однострочный массив
      ar1[i][0]:= charstring(pad_char,tab_len);
     end;
     
    end; // case
    
   end; // if
    
   if high(ar1[i]) > i1 then i1:= high(ar1[i]); // число строк - для определения самого высокого столбца строк
  
  end; // for

  rc:= #$0020; mc:= #$0020; lc:= #$0020;
  if flo_left  in lineopts then 
   if fgraphoff then lc:= vert_graphoff else lc:= _v_;

  if flo_vert  in lineopts then 
   if fgraphoff then mc:= vert_graphoff else mc:= _v_;

  if flo_right in lineopts then 
   if fgraphoff then rc:= vert_graphoff else rc:= _v_;


  // настроить результат на максимальное найденное число строк
  setlength(result, i1+1); 
  for i:= 0 to i1 do begin // вниз

   // каждый столбец начинается с верт. линии,  
   // с учетом поправки на самый левый табулятор > 0      
   result[i]:= s2 + lc; 

   for j:= 0 to valhigh do begin // вправо

    if i > (length(ar1[j])-1) then  // столбец содержит меньше значений, чем максимальное
     s1:= charstring(#$0020, ar2[j])  // дописать эти значения как пустые
    else 
     s1:= ar1[j][i];
     
    if j < valhigh then 
     result[i]:= result[i] + s1 + mc
    else 
     result[i]:= result[i] + s1 + rc;

   end;
  end;
  
  if fautoprint then begin // распечатать  сразу, как готовы вызодные данные

   for i:=0 to high(result) 
    do writelnp(result[i]);

   setlength(result,0);  // со сбросом результата в конце
  end;

 end;
 
// ========================================
 
function ttextprinter.getframeline (
 const tabpos: integerarty; 
 const lpos: line_pos = fl_middle;
 juttabs: integerarty = [];
 lineopts: lineoptsty = [flo_left,flo_right,flo_vert,flo_top,flo_bottom]
): msestring; 
var
 c1,rcs,mcs,lcs, rcl,mcl,lcl, hc: widechar;
 i,j,i1: integer;
 s1,s2: msestring;
 b1: boolean;
begin
 rcs:= #$0020; mcs:= #$0020; lcs:= #$0020; 
 rcl:= #$0020; mcl:= #$0020; lcl:= #$0020; 
 hc:= #$0020;
 
 case lpos of
  fl_upper: begin
  
   if flo_top in lineopts then begin
   
    if fgraphoff then hc:= horz_graphoff else hc:= _h_;

    if flo_left  in lineopts then begin
     if fgraphoff then lcs:= cross_graphoff else lcs:= u_r;
     if fgraphoff then lcl:= cross_graphoff else lcl:= v_r;
    end else begin 
     if fgraphoff then lcs:= horz_graphoff else lcs:= _h_;
     if fgraphoff then lcl:= horz_graphoff else lcl:= _h_;
    end;
    
    if flo_vert  in lineopts then begin 
     if fgraphoff then mcs:= cross_graphoff else mcs:= h_d; 
     if fgraphoff then mcl:= cross_graphoff else mcl:= h_v; 
    end else begin 
     if fgraphoff then mcs:= horz_graphoff else mcs:= _h_; 
     if fgraphoff then mcl:= horz_graphoff else mcl:= _h_; 
    end;
    
    if flo_right in lineopts then begin 
     if fgraphoff then rcs:= cross_graphoff else rcs:= r_d; 
     if fgraphoff then rcl:= cross_graphoff else rcl:= v_l; 
    end else begin 
     if fgraphoff then rcs:= horz_graphoff else rcs:= _h_; 
     if fgraphoff then rcl:= horz_graphoff else rcl:= _h_; 
    end;
    
   end else begin
   
    if flo_left  in lineopts then begin 
     if fgraphoff then lcs:= vert_graphoff else lcs:= _v_; 
     if fgraphoff then lcl:= vert_graphoff else lcl:= _v_; 
    end;
    if flo_vert  in lineopts then begin 
     if fgraphoff then mcs:= vert_graphoff else mcs:= _v_; 
     if fgraphoff then mcl:= vert_graphoff else mcl:= _v_; 
    end;
    if flo_right in lineopts then begin 
     if fgraphoff then rcs:= vert_graphoff else rcs:= _v_; 
     if fgraphoff then rcl:= vert_graphoff else rcl:= _v_; 
    end;

   end;
    
  end;
  
  fl_middle: begin
   if (flo_top in lineopts) or (flo_bottom in lineopts) then begin
   
    if fgraphoff then hc:= horz_graphoff else hc:= _h_;

    if flo_left  in lineopts then begin 
     if fgraphoff then lcs:= cross_graphoff else lcs:= v_r; 
     if fgraphoff then lcl:= cross_graphoff else lcl:= v_r; 
    end else begin
     if fgraphoff then lcs:= horz_graphoff else lcs:= _h_; 
     if fgraphoff then lcl:= horz_graphoff else lcl:= _h_; 
    end;
    if flo_vert  in lineopts then begin 
     if fgraphoff then mcs:= cross_graphoff else mcs:= h_v; 
     if fgraphoff then mcl:= cross_graphoff else mcl:= h_v; 
    end else begin 
     if fgraphoff then mcs:= horz_graphoff else mcs:= _h_; 
     if fgraphoff then mcl:= horz_graphoff else mcl:= _h_;
    end;
    if flo_right in lineopts then begin 
     if fgraphoff then rcs:= cross_graphoff else rcs:= v_l; 
     if fgraphoff then rcl:= cross_graphoff else rcl:= v_l; 
    end else begin 
     if fgraphoff then rcs:= horz_graphoff else rcs:= _h_; 
     if fgraphoff then rcl:= horz_graphoff else rcl:= _h_;
    end;
    
   end else begin

    if flo_left  in lineopts then begin 
     if fgraphoff then lcs:= vert_graphoff else lcs:= _v_;
     if fgraphoff then lcl:= vert_graphoff else lcl:= _v_;
    end;
    if flo_vert  in lineopts then begin 
     if fgraphoff then mcs:= vert_graphoff else mcs:= _v_; 
     if fgraphoff then mcl:= vert_graphoff else mcl:= _v_; 
    end;
    if flo_right in lineopts then begin 
     if fgraphoff then rcs:= vert_graphoff else rcs:= _v_; 
     if fgraphoff then rcl:= vert_graphoff else rcl:= _v_; 
    end;

   end;

  end;

  fl_bottom: begin
   if flo_bottom in lineopts then begin
   
    if fgraphoff then hc:= horz_graphoff else hc:= _h_;
    
    if flo_left  in lineopts then begin 
     if fgraphoff then lcs:= cross_graphoff else lcs:= d_r; 
     if fgraphoff then lcl:= cross_graphoff else lcl:= v_r; 
    end else begin 
     if fgraphoff then lcs:= horz_graphoff else lcs:= _h_;
     if fgraphoff then lcl:= horz_graphoff else lcl:= _h_;
    end;
    if flo_vert  in lineopts then begin 
     if fgraphoff then mcs:= cross_graphoff else mcs:= h_u;
     if fgraphoff then mcl:= cross_graphoff else mcl:= h_v;
    end else begin 
     if fgraphoff then mcs:= horz_graphoff else mcs:= _h_; 
     if fgraphoff then mcl:= horz_graphoff else mcl:= _h_; 
    end;
    if flo_right in lineopts then begin 
     if fgraphoff then rcs:= cross_graphoff else rcs:= r_u; 
     if fgraphoff then rcl:= cross_graphoff else rcl:= v_l; 
    end else begin 
     if fgraphoff then rcs:= horz_graphoff else rcs:= _h_; 
     if fgraphoff then rcl:= horz_graphoff else rcl:= _h_; 
    end;
    
   end else begin

    if flo_left  in lineopts then begin 
     if fgraphoff then lcs:= vert_graphoff else lcs:= _v_; 
     if fgraphoff then lcl:= vert_graphoff else lcl:= _v_; 
    end;
    if flo_vert  in lineopts then begin 
     if fgraphoff then mcs:= vert_graphoff else mcs:= _v_; 
     if fgraphoff then mcl:= vert_graphoff else mcl:= _v_; 
    end;
    if flo_right in lineopts then begin 
     if fgraphoff then rcs:= vert_graphoff else rcs:= _v_; 
     if fgraphoff then rcl:= vert_graphoff else rcl:= _v_; 
    end;
    
   end;

  end;

 end; 

 result:= '';

 i1:= high(tabpos);
 if i1 < 1 
  then raise exception.create('TEXTTABLEDRAW.GETFRAMELINE: At least 2 tabulators are required !');

 // определение левого отступа, если табуляторы начинаются не с начала строки
 if tabpos[0] > 0 then
  s2:= charstring(#$0020, tabpos[0])
 else
  s2:= '';

 for i:= 0 to i1 do begin // for-begin

  b1:= false;
  for j:= 0 to high(juttabs) do begin
   if juttabs[j] = i then begin
    b1:= true;
    break;
   end;
  end;

  if i = 0 then begin // на первом табуляторе предварительно рисуем открывающий символ
   if b1 
    then result:= lcl 
    else result:= lcs;
    
  end else if (i > 0) then begin // от второго 

   if fgraphoff then c1:= horz_graphoff else c1:= _h_;
   result:= result + charstring(c1, tabpos[i]-tabpos[i-1]-1);
   
   if (i < i1) then begin // до предпоследнего табулятора
    if b1 // дописываем промежуточный символ
     then result:= result + mcl // рисуем горизон. линию и промежут символ   
     else result:= result + mcs;
   end else begin // на последнем табуляторе
    if b1 // дописываем завершаюший символ
     then result:= result + rcl 
     else result:= result + rcs;
   end;  
   
  end;
 
 end; // end-for
 
 // поправка на самый левый табулятор > 0
 result:=  s2 + result;
 
 if fautoprint then begin // распечатать  сразу, как готовы вызодные данные
  writelnp(result); 
  setlength(result,0); // со сбросом результата в конце
 end;

end;
 
//===================================== 
 
function mktextalignar(const items: array of stringposty): textalignarty;  
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do result[int1]:= items[int1];
end;

//---------------------------------

function mkclipoptar(const items: array of clip_opts): clipoptarty; 
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do result[int1]:= items[int1];
end;
 
//---------------------------------

function mktabar(const items: array of integer): integerarty; 
begin
 result:= opentodynarrayi(items); 
end;

//---------------------------------

function mkvaluear(const items: array of msestring): msestringarty; 
begin
 result:= opentodynarraym(items); 
end;

//---------------------------------

function zero2emptystr(const avalue: msestring): msestring; 
var
 c1: currency;
begin
 result:= avalue;
 try
  c1:= strtofloat(avalue);
  if c1 = 0 then result:= '';
 except on EConvertError do end;
end;

//============== TTEXTPRINTER ==================

function ttextprinter.lh_cmd(const avalue: real): shortstring;
begin
 result:= flh_cmd + chr(round(avalue*fdpi_coeff/25.4));
end;

//---------------------------------

function ttextprinter.qual_cmd(const avalue: prn_quality): shortstring;
begin
 if avalue = pq_nlq then 
  result:= fhq_cmd
 else
  result:= fhs_cmd;
end;

//---------------------------------

procedure ttextprinter.settype(const atype: prn_type);
begin
  ftype:= atype;
  
  case atype of 
   prn_ibm: begin
    fdeflh_cmd:= ibm_deflh_cmd;
    flh_cmd:= ibm_lh_cmd;
    fhs_cmd:= ibm_hs_cmd;
    fhq_cmd:= ibm_hq_cmd;
    freset_cmd:= ibm_reset_cmd;
    finit_cmd:= ibm_init_cmd;
    fdpi_coeff:= 216;
    fcpi10_cmd:= ibm_10cpi_cmd;
    fcpi12_cmd:= ibm_12cpi_cmd;
    fcond_cmd:=  ibm_cond_cmd;
   end;
   prn_lj: begin
    fdeflh_cmd:= lj_deflh_cmd;
    flh_cmd:= lj_lh_cmd;
    fhs_cmd:= lj_hs_cmd;
    fhq_cmd:= lj_hq_cmd;
    freset_cmd:= lj_reset_cmd;
    finit_cmd:= lj_init_cmd;    
    fdpi_coeff:= 180;
    fcpi10_cmd:= lj_10cpi_cmd;
    fcpi12_cmd:= lj_12cpi_cmd;
    fcond_cmd:=  lj_cond_cmd;
   end;
   else begin
    fdeflh_cmd:= epson_deflh_cmd;
    flh_cmd:= epson_lh_cmd;
    fhs_cmd:= epson_hs_cmd;
    fhq_cmd:= epson_hq_cmd;
    freset_cmd:= epson_init_cmd;
    finit_cmd:= epson_init_cmd;    
    fdpi_coeff:= 216;
    fcpi10_cmd:= epson_10cpi_cmd;
    fcpi12_cmd:= epson_12cpi_cmd;
    fcond_cmd:=  epson_cond_cmd;
   end;
  end;
end;

//---------------------------------

function ttextprinter.dens_cmd(const avalue: prn_density): shortstring;
begin
  case avalue of
   pd_10cpi: result:= fcpi10_cmd;
   pd_12cpi: result:= fcpi10_cmd;
   pd_cond : result:= fcpi10_cmd;
  end; 
end;

//---------------------------------

constructor ttextprinter.Create(const atype: prn_type = prn_epson);
begin
 ftype:= atype;
 settype(ftype);
 fgraphoff:= false; // to use pseudographics by default
 fdebugfilename:= gettempfilename(gettempdir ,'textprinterdbg');
 fdebugprint:= false;
 fautoprint:= false;
 fdebugstream:= nil;
 fisprinting:= false;
 foutputencoding:= enc_latin1;
end;

//---------------------------------

procedure ttextprinter.internalchecklst;
begin
 if not islstavailable then begin
  raise exception.create('TTEXTTABLEDRAW.TTEXTPRINTER: the RAW text printer (LST) is not available!'); 
 end;
end;


procedure ttextprinter.internalendprint;
begin
 if fdebugprint then begin // отладка печати
  if (fdebugstream <> nil) then begin
   if fdebugstream.isopen then fdebugstream.close;
   freeandnil(fdebugstream);
  end;
 end else begin // реальная печать
  internalchecklst;
  system.close(lst);
 end;
end;

//---------------------------------

destructor ttextprinter.Destroy;
begin
 internalendprint;
end;

//---------------------------------

procedure ttextprinter.setdebugprint(const avalue: boolean);
var
 s1: msestring;
begin
 if fisprinting then
  raise exception.create('TTEXTTABLEDRAW.TTEXTPRINTER.SETPRINTERDEBUG: operation is only allowed before BEGINPRINT!');
 fdebugprint:= avalue;
end;

//---------------------------------

procedure ttextprinter.writelnp(const avalue: msestring);
var
 s1: ansistring;
begin
 if not fisprinting then
  raise exception.create('TTEXTTABLEDRAW.TTEXTPRINTER.WRITELNP: operation is only allowed between BEGINPRINT and ENDPRINT!');

 case foutputencoding of
  enc_ru866: s1:= ucs2to866(avalue);
  else
  s1:= stringtolatin1(avalue);
 end;

 if fdebugprint then // отладка печати
  fdebugstream.writeln(s1)
 else begin
  system.writeln(lst,s1);  
 end;
end;

//---------------------------------
procedure ttextprinter.writep(const avalue: msestring);
var
 s1: ansistring;
begin
 if not fisprinting then
  raise exception.create('TTEXTTABLEDRAW.TTEXTPRINTER.WRITEP: operation is only allowed between BEGINPRINT and ENDPRINT!'); 

 case foutputencoding of
  enc_ru866: s1:= ucs2to866(avalue);
  else
  s1:= stringtolatin1(avalue);
 end;

 if fdebugprint then // отладка печати
  fdebugstream.write(s1)  
 else begin
  system.write(lst,s1);  
 end;
end;
//---------------------------------

procedure ttextprinter.beginprint;
var
 s1: msestring;
begin
 if fdebugprint then begin // отладка печати

  if trim(fdebugfilename) = '' then
   fdebugfilename:= gettempfilename(gettempdir ,'textprinterdbg');
   
  if fdebugstream = nil then
   fdebugstream:= ttextstream.create(fdebugfilename,fm_create); 
   
 end else begin // реальная печать
  internalchecklst;
  system.append(lst); // переоткрыть принтер
 end;
 fisprinting:= true;  
 writep(finit_cmd); // на всякий случай сбросить принтер
end;

//---------------------------------
procedure ttextprinter.endprint;
begin
 if not fisprinting then
  raise exception.create('TTEXTTABLEDRAW.TTEXTPRINTER.ENDPRINT: operation is only allowed after BEGINPRINT!');

 writep(finit_cmd); // cбросить принтер, чтобы не влиять на последующие задания 
 fisprinting:= false;
 internalendprint;
end;
//---------------------------------

end.
