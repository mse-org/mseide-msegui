{ MSEgui Copyright (c) 2015-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msejson;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,msestrings,msesystypes,msetypes,sysutils,mseformatstr;
 
type
 ejsonerror = class(exception);

 jsonencodeoptionty = (jseo_tabindent);
 jsonencodeoptionsty = set of jsonencodeoptionty;
  
 jsondatatypty = (jot_null,jot_string,jot_boolean,jot_int32,jot_int64,
                  jot_flo64); //zero init -> null
 jsondataty = record
  case typ: jsondatatypty of
   jot_null:    (vnull: record end);
   jot_string:  (vstring: pointer); //msestring
   jot_boolean: (vboolean: boolean);
   jot_int32:   (vint32: int32);
   jot_int64:   (vint64: int64);
   jot_flo64:   (vflo64: double);
 end;
   
 jsonkindty = (jok_empty,jok_error,jok_value,jok_object,jok_array);
          //zero init -> empty
 jsonvaluety = record
  case kind: jsonkindty of
   jok_empty,jok_error: (err: record end);
   jok_object:(obj: pointer);        //jsonitemarty
   jok_array: (ar: pointer);         //jsonvaluearty   
   jok_value: (val: jsondataty);
 end;
 pjsonvaluety = ^jsonvaluety;
 jsonvaluearty = array of jsonvaluety;

 jsonitemty = record
  name: msestring;
  value: jsonvaluety;
 end;
 pjsonitemty = ^jsonitemty;
 jsonitemarty = array of jsonitemty;

 arraystartmethodty = procedure(var adata;
                                   const acount: int32) of object;
 arrayitemmethodty = procedure(var adata; 
                      const aindex: int32; const aitem: jsonvaluety) of object;

 arraystartprocty = procedure(var adata;
                                   const acount: int32);
 arrayitemprocty = procedure(var adata; 
                      const aindex: int32; const aitem: jsonvaluety);

 tjsoncontainer = class
  private
  protected
   fvalue: jsonvaluety;
   function findvaluevalue(const names: array of msestring): pjsonvaluety;
  public
   constructor create(const avalue: jsonvaluety); //owns the value
   constructor create(const adata: string);
   class function trycreate(out ainstance: tjsoncontainer;
                                             const adata: string): boolean;
   destructor destroy(); override;
   property value: jsonvaluety read fvalue;
   function findvalue(const names: array of msestring;
                         const raiseexception: boolean = false): pjsonvaluety;
                       //nil if not found
   function asstring(const names: array of msestring): msestring;
   function asboolean(const names: array of msestring): boolean;
   function asint32(const names: array of msestring): int32;
   function asint64(const names: array of msestring): int64;
   function asflo64(const names: array of msestring): flo64;
   procedure iteratearray(const names: array of msestring; var adata;
                    const startproc: arraystartmethodty;
                                           const itemproc: arrayitemmethodty);
   procedure iteratearray(const names: array of msestring; var adata;
                    const startproc: arraystartprocty;
                                           const itemproc: arrayitemprocty);
 end;
 
procedure jsonvalueinit(var avalue: jsonvaluety); //inits to null value
procedure jsonvaluefree(var avalue: jsonvaluety); 

function jsonfindvalue(const avalue: jsonvaluety;
                          const names: array of msestring; 
                         const raiseexception: boolean = false): pjsonvaluety;
function jsonasstring(const avalue: jsonvaluety;
                                 const names: array of msestring): msestring;
function jsonasint32(const avalue: jsonvaluety;
                                    const names: array of msestring): int32;
function jsonasint64(const avalue: jsonvaluety;
                                      const names: array of msestring): int64;
function jsonasflo64(const avalue: jsonvaluety;
                                    const names: array of msestring): flo64;
function jsonasboolean(const avalue: jsonvaluety;
                                     const names: array of msestring): boolean;
procedure jsoniteratearray(const avalue: jsonvaluety;
               const names: array of msestring;
               var adata; const startproc: arraystartprocty;
               const itemproc: arrayitemprocty);
procedure jsoniteratearray(const avalue: jsonvaluety;
               const names: array of msestring;
               var adata; const startproc: arraystartmethodty;
               const itemproc: arrayitemmethodty);
function jsonadditems(var jvalue: jsonvaluety; const anames: array of msestring;
                                   const avalues: array of const): pjsonvaluety;
             //if jvalue is a null value it will be converted to object
             //[nil] -> null, returns the last added item or @jvalue
function jsonaddvalues(var jvalue: jsonvaluety;
                                   const avalues: array of const): pjsonvaluety;
             //if jvalue is a null value it will be converted to array
             //[nil] -> null, returns the last added item or @jvalue

function jsondecode(const adata: string; out avalue:jsonvaluety): boolean;
function jsonencode(const avalue: jsonvaluety; const adest: tstream;
                       const aoptions: jsonencodeoptionsty = []): syserrorty; 

implementation
uses
 msearrayutils,msefloattostr;

procedure error(const atext: msestring);
begin
 raise ejsonerror.create('json error: '+ansistring(atext));
end;

procedure nameserror(const names: array of msestring);
begin
 error('"'+concatstrings(opentodynarraym(names),'.')+'" not found');
end;

procedure conversionerror(const names: array of msestring);
begin
 error('"'+concatstrings(opentodynarraym(names),'.')+'" conversion error');
end;

{$implicitexceptions off}

procedure jsonvalueinit(var avalue: jsonvaluety);
begin
 avalue.kind:= jok_value;
 avalue.val.typ:= jot_null;
end;

procedure jsonitemfree(var aitem: jsonitemty); forward;

procedure jsonvaluefree(var avalue: jsonvaluety);
var
 po1: pjsonitemty;
 po2: pjsonvaluety;
 pe: pointer;
begin
 case avalue.kind of
  jok_value: begin
   if avalue.val.typ = jot_string then begin
    msestring(avalue.val.vstring):= '';
   end;
  end;
  jok_array: begin
   po2:= avalue.ar;
   if po2 <> nil then begin
    pe:= po2 + high(jsonvaluearty(po2));
    while po2 <= pe do begin
     jsonvaluefree(po2^);
     inc(po2);
    end;
    freeuninitedarray(avalue.ar);
   end;
  end;
  jok_object: begin
   po1:= avalue.obj;
   if po1 <> nil then begin
    pe:= po1 + high(jsonitemarty(po1));
    while po1 <= pe do begin
     jsonitemfree(po1^);
     inc(po1);
    end;
    freeuninitedarray(avalue.obj);
   end;
  end;
 end;
 avalue.kind:= jok_value;
 avalue.val.typ:= jot_null;
end;

procedure jsonitemfree(var aitem: jsonitemty);
begin
 aitem.name:= '';
 jsonvaluefree(aitem.value);
end;

function stringtojsonstringascii(const avalue: msestring): ansistring;
var
 ps,pe: pmsechar;
 pd: pchar;
 ch1: char;
 mch1: msechar;
begin
 setlength(result,length(avalue)*6+2); //max;
 ps:= pointer(avalue);
 pe:= ps + length(avalue);
 pd:= pointer(result);
 pd^:= '"';
 inc(pd);
 while ps < pe do begin
  ch1:= char(byte(ps^));
  pd^:= '\';
  case ps^ of
   '"','\','/': begin
    inc(pd);
   end;
   c_backspace: begin
    inc(pd);
    ch1:= 'b';
   end;
   c_formfeed: begin
    inc(pd);
    ch1:= 'f';
   end;
   c_linefeed: begin
    inc(pd);
    ch1:= 'r';
   end;
   c_return: begin
    inc(pd);
    ch1:= 'r';
   end;
   c_tab: begin
    inc(pd);
    ch1:= 't';
   end;
   else begin
    mch1:= ps^;
    if (mch1 < #$20) or (mch1 > #$7f) then begin
     inc(pd);
     pd^:= 'u';
     inc(pd);
     pd^:= charhex[(card16(mch1) and $f000) shr 12];
     inc(pd);
     pd^:= charhex[(card16(mch1) and $0f00) shr 8];
     inc(pd);
     pd^:= charhex[(card16(mch1) and $00f0) shr 4];
     inc(pd);
     ch1:= charhex[(card16(mch1) and $000f)];
    end;
   end;
  end;
  pd^:= ch1;
  inc(pd);
  inc(ps);
 end;
 pd^:= '"';
 inc(pd);
 setlength(result,pd-pchar(pointer(result)));
end;

const
 maxindent = 32;
 indents: array[0..maxindent] of char8 = (
  c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab, //8
  c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab, //16
  c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab, //24
  c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab,c_tab, //32
  c_tab);
  
function jsonencode(const avalue: jsonvaluety; const adest: tstream;
                       const aoptions: jsonencodeoptionsty = []): syserrorty;
var
 error: syserrorty;
 indentlevel,indentcount: int32;
 hasindent: boolean;

 procedure incindent();
 begin
  if hasindent then begin
   inc(indentlevel);
   if indentlevel <= maxindent then begin
    indentcount:= indentlevel;
   end;
  end;
 end;

 procedure decindent();
 begin
  if hasindent then begin
   dec(indentlevel);
   if indentlevel <= maxindent then begin
    indentcount:= indentlevel;
   end;
  end;
 end;
   
 procedure putindent();
 begin
  if (indentcount > 0) and (error = sye_ok) then begin
   error:= adest.trywritebuffer(indents,indentcount);
  end;
 end;//putindent

 procedure put(const atext: string);
 begin
  if error = sye_ok then begin
   error:= adest.trywritebuffer(pointer(atext)^,length(atext));
  end;
 end;//put
 
 procedure putvalue(const avalue: jsonvaluety);
 var
  pi: pjsonitemty;
  pv: pjsonvaluety;
  pe: pointer;
 begin
  case avalue.kind of
   jok_object: begin
    put('{'+c_linefeed);
    incindent();
    pi:= avalue.obj;
    pe:= pi + dynarraylength(avalue.obj);
    if pe > pi then begin
     while error = sye_ok do begin
      putindent();
      put(stringtojsonstringascii(pi^.name)+':');
      putvalue(pi^.value);
      inc(pi);
      if pi >= pe then begin
       break;
      end;
      put(','+c_linefeed);
     end;
    end
    else begin
//     decindent(); //same indent as '{'
     putindent();
//     incindent()
    end;
    put('}');
    decindent();
   end;
   jok_array: begin
    put('['+c_linefeed);
    incindent();
    pv:= avalue.ar;
    pe:= pv + dynarraylength(avalue.ar);
    if pe > pv then begin
     while error = sye_ok do begin
      putindent();
      putvalue(pv^);
      inc(pv);
      if pv >= pe then begin
       break;
      end;
      put(','+c_linefeed);
     end;
    end
    else begin
     putindent();
    end;
    put(']');
    decindent();
   end;
   jok_value: begin
    case avalue.val.typ of
     jot_null: begin
      put('null');
     end;
     jot_string: begin
      put(stringtojsonstringascii(msestring(avalue.val.vstring)));
     end;
     jot_boolean: begin
      if avalue.val.vboolean then begin
       put('true');
      end
      else begin
       put('false');
      end;
     end;
     jot_int32: begin
      put(inttostr(avalue.val.vint32));
     end;
     jot_int64: begin
      put(inttostr(avalue.val.vint64));
     end;
     jot_flo64: begin
      put(ansistring(doubletostring(avalue.val.vflo64,0,fsm_default,'.')));
     end;
    end;
   end;
  end;
 end;//putvalue

begin
 error:= sye_ok;
 indentlevel:= 0;
 indentcount:= 0;
 hasindent:= jseo_tabindent in aoptions;
 putvalue(avalue);
 result:= error;
end;

function jsondecode(const adata: string; out avalue: jsonvaluety): boolean;
const
 whitechars = [' ',c_tab,c_linefeed,c_return];
var
 pc,pe: pchar;
 error: boolean;

 procedure skipwhitespace(); inline;
 begin
  if pc < pe then begin
   inc(pc);
   while (pc^ in whitechars) and (pc < pe) do begin
    inc(pc);
   end;
  end;
 end;//skipwhitespace

 function getstring: msestring;
 var
  po1,po2,pe1: pchar;
  len,capacity: int32;
  i1: int32;
  mstr1: msestring;
  mch1: msechar;
  ca1: card32;

  procedure put(); inline;
  begin
   if po1 <> po2 then begin
    mstr1:= utf8tostring(po2,po1-po2);
    i1:= len;
    len:= len + length(mstr1);
    if len >= capacity then begin //at least one character reserve
     capacity:= 2*len+32;
     setlength(result,capacity);
    end;
    move(pointer(mstr1)^,(pmsechar(pointer(result))+i1)^,
                                           length(mstr1)*sizeof(msechar));
   end
   else begin
    if len >= capacity then begin //at least one character reserve
     capacity:= 2*len+32;
     setlength(result,capacity);
    end;
   end;
  end;//put

 begin//getstring
  po1:= pc;
  pe1:= pe;
  result:= '';
  len:= 0;
  capacity:= 0;
  inc(po1); //leading "
  po2:= po1;
  while (po1^ <> '"') and (po1 < pe1) do begin
   if po1^ = '\' then begin
    put();
    inc(po1);  // '\'
    case po1^ of
     '"': mch1:= '"';
     '\': mch1:= '\';
     '/': mch1:= '/';
     'b': mch1:= c_backspace;
     'f': mch1:= c_formfeed;
     'n': mch1:= c_linefeed;
     'r': mch1:= c_return;
     't': mch1:= c_tab;
     'u': begin
      inc(po1);
      if pe1-po1 > 4 then begin
       if not trystrtohex(po1,4,ca1) then begin
        error:= true;
        break;
       end;
       inc(po1,3);
       mch1:= msechar(card16(ca1));
      end;
     end;
    end;
    pmsechar(pointer(result))[len]:= mch1;
    inc(len);
    po2:= po1 + 1; //new start
   end;
   inc(po1);
  end;
  put();
  pc:= po1;
  if po1^ <> '"' then begin
   error:= true;
  end;
  setlength(result,len);
 end;//getstring

 procedure getobj(var avalue: jsonvaluety); forward;
 procedure getarray(var avalue: jsonvaluety); forward;

 procedure getvalue(var avalue: jsonvaluety);
 var
  mstr1: msestring;
  po1,po2,po3: pchar;
  i1: int32;
  lstr1: lstringty;
 begin
  skipwhitespace();
  if pc < pe then begin
   avalue.kind:= jok_value; //default
   case pc^ of
    '{': begin
     getobj(avalue);
    end;
    '[': begin
     getarray(avalue);
    end;
    '"': begin
     avalue.val.typ:= jot_string;
     mstr1:= getstring;
     stringaddref(mstr1);
     avalue.val.vstring:= pointer(mstr1);
    end;
    else begin
     po1:= pc;
     po2:= po1;
     while not (po2^ in whitechars+[',',']','}']) and (po2 < pe) do begin
      inc(po2);
     end;
     pc:= po2-1;
     i1:= po2-po1;
     if i1 = 4 then begin
      if (po1^ = 't') and ((po1+1)^ = 'r') and ((po1+2)^ = 'u') and 
                                                    ((po1+3)^ = 'e') then begin
       avalue.val.typ:= jot_boolean;
       avalue.val.vboolean:= true;
       exit;
      end;
      if (po1^ = 'n') and ((po1+1)^ = 'u') and ((po1+2)^ = 'l') and 
                                                    ((po1+3)^ = 'l') then begin
       avalue.val.typ:= jot_null;
       exit;
      end;
     end
     else begin
      if (i1 = 5) and (po1^ = 'f') and ((po1+1)^ = 'a') and ((po1+2)^ = 'l') and 
                                ((po1+3)^ = 's') and ((po1+4)^ = 'e') then begin
       avalue.val.typ:= jot_boolean;
       avalue.val.vboolean:= true;
       exit;
      end
      else begin
       po3:= po1;
       lstr1.po:= po1;
       lstr1.len:= i1;
       while po3 < po2 do begin
        if po3^ in ['.','e','E'] then begin
         if trystrtodouble(lstr1,avalue.val.vflo64,'.') then begin
          avalue.val.typ:= jot_flo64;
         end
         else begin
          error:= true;
         end;
         exit;
        end;
        inc(po3);
       end;
       if trystrtoint(lstr1,avalue.val.vint32) then begin
        avalue.val.typ:= jot_int32;
       end
       else begin
        if trystrtoint64(lstr1,avalue.val.vint64) then begin
         avalue.val.typ:= jot_int64;
        end
        else begin
         error:= true;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;//getvalue
 
 procedure getarray(var avalue: jsonvaluety);
 var
  ar1: jsonvaluearty;
  count: int32;
  value: pjsonvaluety;
 begin
  ar1:= nil;
  avalue.kind:= jok_array;
  count:= 0;
  skipwhitespace();
  if pc^ <> ']' then begin //else empty
   dec(pc); //restore leading char
   repeat
    additem(ar1,typeinfo(ar1),count);
    value:= @ar1[count-1];
    getvalue(value^); //calls skipwhitespace()
    skipwhitespace();
    if pc^ <> ',' then begin
     if pc^ <> ']' then begin
      error:= true;
     end;
     break;
    end;
   until error;
  end;
  setlength(ar1,count);
  arrayaddref(ar1);
  avalue.ar:= pointer(ar1);
 end;//getarray
  
 procedure getobj(var avalue: jsonvaluety);
 var
  ar1: jsonitemarty;
  count: int32;
  item: pjsonitemty;
 begin
  ar1:= nil;
  avalue.kind:= jok_object;
  count:= 0;
  repeat
   additem(ar1,typeinfo(ar1),count);
   item:= @ar1[count-1];
   skipwhitespace();        //leading '{' or ','
   if pc^ <> '"' then begin
    error:= true;
    break;
   end;
   item^.name:= getstring();
   skipwhitespace();
   if pc^ = ':' then begin
    getvalue(item^.value); //calls skipwhitespace()
   end
   else begin
    error:= true;
   end;
   skipwhitespace();
   if pc^ <> ',' then begin
    if pc^ <> '}' then begin
     error:= true;
    end;
    break;
   end;
  until error;
  setlength(ar1,count);
  arrayaddref(ar1);
  avalue.obj:= pointer(ar1);
 end;//getobj
 
begin
 error:= false;
 if adata <> '' then begin
  pc:= pointer(adata);
  pe:= pc+length(adata);
  dec(pc);
  getvalue(avalue);
  if error then begin
   jsonvaluefree(avalue);
   avalue.kind:= jok_error;
  end;
 end
 else begin
  avalue.kind:= jok_value;
  avalue.val.typ:= jot_null;
 end;
 result:= not error;
end;

function jsonfindvalue(const avalue: jsonvaluety;
                          const names: array of msestring; 
                         const raiseexception: boolean = false): pjsonvaluety;
           //todo: use hash cache
var
 pv: pjsonvaluety;
 pi: pjsonitemty;
 pe: pointer;
 i1: int32;
 mstr1: msestring;
 
 procedure nameerror();
 begin
  pv:= nil;
  if raiseexception then begin
   nameserror(copy(opentodynarraym(names),0,i1+1));
  end;
 end;//nameerror
 
begin
 pv:= @avalue;
 if high(names) >= 0 then begin
  for i1:= 0 to high(names) do begin
   if pv^.kind <> jok_object then begin
    nameerror();
    break;
   end;
   mstr1:= names[i1];
   pi:= pv^.obj;
   pe:= pi + dynarraylength(pi);
   while (pi < pe) and (pi^.name <> mstr1) do begin
    inc(pi);
   end;
   if pi < pe then begin
    pv:= @pi^.value;
   end
   else begin
    nameerror();
    break;
   end;
  end;
 end;
 result:= pv;
end;

function jsonfindvaluevalue(const avalue: jsonvaluety;
              const names: array of msestring): pjsonvaluety;
begin
 result:= jsonfindvalue(avalue,names,true);
 if result^.kind <> jok_value then begin
  error('No value');
 end;  
end;

function jsonasstring(const avalue: jsonvaluety;
                                 const names: array of msestring): msestring;
var
 po1: pjsonvaluety;
begin
 po1:= jsonfindvaluevalue(avalue,names);
 case po1^.val.typ of
  jot_null: begin
   result:= '';
  end;
  jot_string: begin
   result:= msestring(po1^.val.vstring);
  end;
  jot_boolean: begin
   if po1^.val.vboolean then begin
    result:= 'true';
   end
   else begin
    result:= 'false';
   end;
  end;
  jot_int32: begin 
   result:= inttostrmse(po1^.val.vint32);
  end;
  jot_int64: begin 
   result:= inttostrmse(po1^.val.vint64);
  end;
  jot_flo64: begin
   result:= realtostrmse(po1^.val.vflo64);
  end;
 end;   
end;

function jsonasint32(const avalue: jsonvaluety;
                                    const names: array of msestring): int32;
var
 po1: pjsonvaluety;
begin
 po1:= jsonfindvaluevalue(avalue,names);
 case po1^.val.typ of
  jot_int32: begin
   result:= po1^.val.vint32;
  end;
  jot_int64: begin
   result:= po1^.val.vint64;
  end;
  jot_flo64: begin
   result:= round(po1^.val.vflo64);
  end;
  jot_boolean: begin
   if po1^.val.vboolean then begin
    result:= 1;
   end
   else begin
    result:= 0;
   end;
  end;
  jot_null: begin
   result:= 0;
  end;
  jot_string: begin
   if not trystrtoint(msestring(po1^.val.vstring),result) then begin
    conversionerror(names);
   end;
  end;
 end;
end;

function jsonasint64(const avalue: jsonvaluety;
                                      const names: array of msestring): int64;
var
 po1: pjsonvaluety;
begin
 po1:= jsonfindvaluevalue(avalue,names);
 case po1^.val.typ of
  jot_int64: begin
   result:= po1^.val.vint64;
  end;
  jot_int32: begin
   result:= po1^.val.vint32;
  end;
  jot_flo64: begin
   result:= round(po1^.val.vflo64);
  end;
  jot_boolean: begin
   if po1^.val.vboolean then begin
    result:= 1;
   end
   else begin
    result:= 0;
   end;
  end;
  jot_null: begin
   result:= 0;
  end;
  jot_string: begin
   if not trystrtoint64(msestring(po1^.val.vstring),result) then begin
    conversionerror(names);
   end;
  end;
 end;
end;

function jsonasflo64(const avalue: jsonvaluety;
                                    const names: array of msestring): flo64;
var
 po1: pjsonvaluety;
begin
 po1:= jsonfindvaluevalue(avalue,names);
 case po1^.val.typ of
  jot_flo64: begin
   result:= po1^.val.vflo64;
  end;
  jot_int32: begin
   result:= po1^.val.vint32;
  end;
  jot_int64: begin
   result:= po1^.val.vint64;
  end;
  jot_boolean: begin
   if po1^.val.vboolean then begin
    result:= 1;
   end
   else begin
    result:= 0;
   end;
  end;
  jot_null: begin
   result:= 0;
  end;
  jot_string: begin
   if not trystrtodouble(msestring(po1^.val.vstring),result,'.') then begin
    conversionerror(names);
   end;
  end;
 end;
end;

function jsonasboolean(const avalue: jsonvaluety;
                                     const names: array of msestring): boolean;
var
 po1: pjsonvaluety;
begin
 po1:= jsonfindvaluevalue(avalue,names);
 case po1^.val.typ of
  jot_boolean: begin
   result:= po1^.val.vboolean;
  end;
  jot_int32: begin
   result:= po1^.val.vint32 <> 0;
  end;
  jot_int64: begin
   result:= po1^.val.vint64 <> 0;
  end;
  jot_flo64: begin
   result:= round(po1^.val.vflo64) <> 0;
  end;
  jot_null: begin
   result:= false;
  end;
  jot_string: begin
   result:= msestring(po1^.val.vstring) = 'true';
   if not result and (msestring(po1^.val.vstring) <> 'false') then begin
    conversionerror(names);
   end;
  end;
 end;
end;

procedure jsoniteratearray(const avalue: jsonvaluety;
               const names: array of msestring;
               var adata; const startproc: arraystartprocty;
               const itemproc: arrayitemprocty);
var
 po1: pjsonvaluety;
 i1: int32;
 pv,pe: pjsonvaluety;
begin
 po1:= jsonfindvalue(avalue,names,true);
 if po1^.kind <> jok_array then begin
  error('No array');
 end;
 pv:= po1^.ar;
 i1:= dynarraylength(pv);
 if startproc <> nil then begin
  startproc(adata,i1);
 end;
 if itemproc <> nil then begin
  pe:= pv + i1;
  i1:= 0;
  while pv < pe do begin
   itemproc(adata,i1,pv^);
   inc(pv);
   inc(i1);
  end;
 end;
end;

procedure jsoniteratearray(const avalue: jsonvaluety;
               const names: array of msestring;
               var adata; const startproc: arraystartmethodty;
               const itemproc: arrayitemmethodty);
var
 po1: pjsonvaluety;
 i1: int32;
 pv,pe: pjsonvaluety;
begin
 po1:= jsonfindvalue(avalue,names,true);
 if po1^.kind <> jok_array then begin
  error('No array');
 end;
 pv:= po1^.ar;
 i1:= dynarraylength(pv);
 if startproc <> nil then begin
  startproc(adata,i1);
 end;
 if itemproc <> nil then begin
  pe:= pv + i1;
  i1:= 0;
  while pv < pe do begin
   itemproc(adata,i1,pv^);
   inc(pv);
   inc(i1);
  end;
 end;
end;

procedure setvalue(var jvalue: jsonvaluety; const avalue: tvarrec);
begin
 with jvalue,avalue do begin //todo: vtvariant
  kind:= jok_value;
  case avalue.vtype of
   vtinteger: begin
    val.typ:= jot_int32;
    val.vint32:= vinteger;
   end;
   vtunicodestring: begin
    val.typ:= jot_string;
    msestring(val.vstring):= unicodestring(vunicodestring);
   end;
   vtwidestring: begin
    val.typ:= jot_string;
    msestring(val.vstring):= widestring(vunicodestring);
   end;
   vtansistring: begin
    val.typ:= jot_string;
    msestring(val.vstring):= widestring(vansistring);
   end;
   vtchar: begin
    val.typ:= jot_string;
    msestring(val.vstring):= msestring(vchar);
   end;
   vtwidechar: begin
    val.typ:= jot_string;
    msestring(val.vstring):= vwidechar;
   end;
   vtstring: begin
    val.typ:= jot_string;
    msestring(val.vstring):= msestring(vstring^);
   end;
   vtpchar: begin
    val.typ:= jot_string;
    msestring(val.vstring):= msestring(string(vpchar));
   end;
   vtpwidechar: begin
    val.typ:= jot_string;
    msestring(val.vstring):= msestring(vpwidechar);
   end;
   vtextended: begin
    val.typ:= jot_flo64;
    val.vflo64:= vextended^;
   end;
   vtcurrency: begin
    val.typ:= jot_flo64;
    val.vflo64:= vcurrency^;
   end;
   vtboolean: begin
    val.typ:= jot_boolean;
    val.vboolean:= vboolean;
   end;
   vtint64: begin
    val.typ:= jot_int64;
    val.vint64:= vint64^;
   end;
   else begin
    val.typ:= jot_null;
   end;
  end;
 end;
end;

function jsonadditems(var jvalue: jsonvaluety; const anames: array of msestring;
                                   const avalues: array of const): pjsonvaluety;
             //if jvalue is a null value it will be converted to object
             //[nil] -> null, returns the last added item or @jvalue
var
 i1,i2: int32;
 pi: pjsonitemty;
begin
 if high(anames) <> high(avalues) then begin
  error('jsonadditems(): Name count <> value count');
 end;
 if (jvalue.kind = jok_value) and (jvalue.val.typ = jot_null) then begin
  jvalue.kind:= jok_object;
  jvalue.obj:= nil;
 end;
 if jvalue.kind <> jok_object then begin
  error('jsonadditems(): jvalue must be jok_object or null value');
 end;
 i2:= high(avalues);
 if i2 >= 0 then begin
  i1:= high(jsonitemarty(jvalue.ar));
  setlength(jsonitemarty(jvalue.ar),i1+i2+2);
  pi:= @jsonitemarty(jvalue.ar)[i1+1];
  for i1:= 0 to i2 do begin
   pi^.name:= anames[i1];
   setvalue(pi^.value,avalues[i1]);
   inc(pi);
  end;
  result:= @((pi-1)^.value);
 end
 else begin
  result:= @jvalue;
 end;
end;

function jsonaddvalues(var jvalue: jsonvaluety;
                                   const avalues: array of const): pjsonvaluety;
             //if jvalue is a null value it will be converted to array
             //[nil] -> null, returns the last added item or @jvalue
var
 i1,i2: int32;
 pv: pjsonvaluety;
begin
 if (jvalue.kind = jok_value) and (jvalue.val.typ = jot_null) then begin
  jvalue.kind:= jok_array;
  jvalue.ar:= nil;
 end;
 if jvalue.kind <> jok_array then begin
  error('jsonaddvalues(): jvalue must be jok_object or null value');
 end;
 i2:= high(avalues);
 if i2 >= 0 then begin
  i1:= high(jsonvaluearty(jvalue.ar));
  setlength(jsonvaluearty(jvalue.ar),i1+i2+2);
  pv:= @jsonvaluearty(jvalue.ar)[i1+1];
  for i1:= 0 to i2 do begin
   setvalue(pv^,avalues[i1]);
   inc(pv);
  end;
  result:= pv-1;
 end
 else begin
  result:= @jvalue;
 end;
end;

{$implicitexceptions on}

{ tjsoncontainer }

constructor tjsoncontainer.create(const avalue: jsonvaluety);
begin
 fvalue:= avalue;
end;

class function tjsoncontainer.trycreate(out ainstance: tjsoncontainer;
                                                  const adata: string): boolean;
var
 val1: jsonvaluety;
begin
 result:= jsondecode(adata,val1);
 if result then begin
  ainstance:= tjsoncontainer.create(val1);
  ainstance.fvalue:= val1;
 end;
end;

constructor tjsoncontainer.create(const adata: string);
begin
 if not jsondecode(adata,fvalue) then begin
  error('Invalid json data');
 end;
end;

destructor tjsoncontainer.destroy;
begin
 jsonvaluefree(fvalue);
end;

function tjsoncontainer.findvalue(const names: array of msestring; 
                         const raiseexception: boolean = false): pjsonvaluety;
           //todo: use hash cache
begin
 result:= jsonfindvalue(fvalue,names,raiseexception);
end;

function tjsoncontainer.findvaluevalue(
              const names: array of msestring): pjsonvaluety;
begin
 result:= jsonfindvaluevalue(fvalue,names);
end;

function tjsoncontainer.asstring(const names: array of msestring): msestring;
begin
 result:= jsonasstring(fvalue,names);
end;

function tjsoncontainer.asint32(const names: array of msestring): int32;
begin
 result:= jsonasint32(fvalue,names);
end;

function tjsoncontainer.asint64(const names: array of msestring): int64;
begin
 result:= jsonasint64(fvalue,names);
end;

function tjsoncontainer.asflo64(const names: array of msestring): flo64;
begin
 result:= jsonasflo64(fvalue,names);
end;

function tjsoncontainer.asboolean(const names: array of msestring): boolean;
begin
 result:= jsonasboolean(fvalue,names);
end;

procedure tjsoncontainer.iteratearray(const names: array of msestring;
               var adata; const startproc: arraystartprocty;
               const itemproc: arrayitemprocty);
begin
 jsoniteratearray(fvalue,names,adata,startproc,itemproc);
end;

procedure tjsoncontainer.iteratearray(const names: array of msestring;
               var adata; const startproc: arraystartmethodty;
               const itemproc: arrayitemmethodty);
begin
 jsoniteratearray(fvalue,names,adata,startproc,itemproc);
end;

end.

