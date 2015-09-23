{ MSEgui Copyright (c) 2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
//under construction
//
unit msejson;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,msestrings,msesystypes,msetypes,sysutils,mseformatstr;
 
type
 ejsonerror = class(exception);
 
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
 end;
 
procedure jsonvaluefree(var avalue: jsonvaluety);
function jsondecode(const adata: string; out avalue:jsonvaluety): boolean;
function jsonencode(const avalue: jsonvaluety;
                                    const adest: tstream): syserrorty; 

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
     pd^:= 'u';
     inc(pd);
     pd^:= charhex[(card16(mch1) and $f000) shl 12];
     inc(pd);
     pd^:= charhex[(card16(mch1) and $0f00) shl 8];
     inc(pd);
     pd^:= charhex[(card16(mch1) and $00f0) shl 4];
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

function jsonencode(const avalue: jsonvaluety; const adest: tstream): syserrorty;
 var
  error: syserrorty;

 procedure put(const atext: string);
 begin
  if error = sye_ok then begin
   error:= adest.trywritebuffer(pointer(atext)^,length(atext));
  end;
 end; //put
 
 procedure putvalue(const avalue: jsonvaluety);
 var
  pi: pjsonitemty;
  pv: pjsonvaluety;
  pe: pointer;
 begin
  case avalue.kind of
   jok_object: begin
    put('{');
    pi:= avalue.obj;
    pe:= pi + dynarraylength(avalue.obj);
    if pe > pi then begin
     while error = sye_ok do begin
      put(stringtojsonstringascii(pi^.name)+':');
      putvalue(pi^.value);
      inc(pi);
      if pi >= pe then begin
       break;
      end;
      put(','+c_linefeed);
     end;
    end;
    put('}'+c_linefeed);
   end;
   jok_array: begin
    put('[');
    pv:= avalue.ar;
    pe:= pv + dynarraylength(avalue.ar);
    if pe > pv then begin
     while error = sye_ok do begin
      putvalue(pv^);
      inc(pv);
      if pv >= pe then begin
       break;
      end;
      put(','+c_linefeed);
     end;
    end;
    put(']'+c_linefeed);
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
 end; //putvalue

begin
 error:= sye_ok;
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
 end; //skipwhitespace

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
    move(pointer(mstr1)^,(pointer(result)+i1)^,length(mstr1)*sizeof(msechar));
   end;
  end; //put

 begin
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
       mch1:= msechar(card16(ca1));
      end;
     end;
    end;
    pchar(pointer(result))[len]:= mch1;
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
 end; //getstring

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
     while not (po2^ in whitechars+[',']) and (po2 < pe) do begin
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
 end; //getvalue
 
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
 end; //getarray
  
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
 end; //getobj
 
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
 end; //nameerror
 
begin
 pv:= @fvalue;
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
  result:= pv;
 end;
end;

function tjsoncontainer.findvaluevalue(
              const names: array of msestring): pjsonvaluety;
begin
 result:= findvalue(names,true);
 if result^.kind <> jok_value then begin
  error('No value');
 end;  
end;

function tjsoncontainer.asstring(const names: array of msestring): msestring;
var
 po1: pjsonvaluety;
begin
 po1:= findvaluevalue(names);
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

function tjsoncontainer.asint32(const names: array of msestring): int32;
var
 po1: pjsonvaluety;
begin
 po1:= findvaluevalue(names);
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

function tjsoncontainer.asint64(const names: array of msestring): int64;
var
 po1: pjsonvaluety;
begin
 po1:= findvaluevalue(names);
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

function tjsoncontainer.asflo64(const names: array of msestring): flo64;
var
 po1: pjsonvaluety;
begin
 po1:= findvaluevalue(names);
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

function tjsoncontainer.asboolean(const names: array of msestring): boolean;
var
 po1: pjsonvaluety;
begin
 po1:= findvaluevalue(names);
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

end.

