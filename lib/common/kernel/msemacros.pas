{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemacros;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,mselist,msearrayutils,msetypes,msestat;
 
type
 macroinfoty = record
  name,value: msestring;
  expandlevel: integer;
 end;
 pmacroinfoty = ^macroinfoty;
 macroinfoarty = array of macroinfoty;
 macroinfoaty = array[0..0] of macroinfoty;
 pmacroinfoaty = ^macroinfoaty;

 macrooptionty = (mao_caseinsensitive,mao_curlybraceonly,mao_removeunknown);
 macrooptionsty = set of macrooptionty;
 
 tmacrolist = class(torderedrecordlist,istatupdatevalue)
  private
   foptions: macrooptionsty;
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   function compare(const l,r): integer;
   function getcomparefunc: sortcomparemethodty; override;
   procedure setrec(const index: integer; const avalue: msestring);
   function getrec(const index: integer): msestring;
   //istatupdatevalue
   procedure statreadvalue(const aname: msestring; const reader: tstatreader);
   procedure statwritevalue(const aname: msestring; const writer: tstatwriter);
   procedure internalexpandmacros(var avalue: msestring; expandlevel: integer;
                                                     var refindex: integerarty);
  public
   constructor create(const aoptions: macrooptionsty);
   function itempo(const index: integer): pmacroinfoty;
   procedure add(const avalue: tmacrolist); overload;
   procedure add(const avalue: macroinfoty); overload;
   procedure add(const avalue: macroinfoarty); overload;
   procedure add(const names,values: array of msestring); overload;
   procedure resetexpandlevel;
   function getvalue(const aname: msestring;
                                      var aexpandlevel: integer): msestring;
   procedure expandmacros(var avalue: msestring); overload;
   procedure expandmacros(var avalue: msestring; var refindex: integerarty); overload;
   procedure expandmacros(var avalues: msestringarty); overload;
   function asarray: macroinfoarty; overload;
   procedure asarray(out names,values: msestringarty); overload;
   property options: macrooptionsty read foptions write foptions;
 end;
 
//function expandmacros(const value: msestring; const macros:macroinfoarty;
//              const caseinsensitive: boolean = true): msestring; overload;
function initmacros(const anames,avalues: array of msestring
                                                ): macroinfoarty; overload;
function initmacros(const anames,avalues: array of msestringarty
                                                ): macroinfoarty; overload;
function expandmacros(const value: msestring; const macros: macroinfoarty;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring; overload;
function expandmacros(const value: msestring; 
               const anames,avalues: array of msestring;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring; overload;

implementation
uses
 msestream;
 
function initmacros(const anames,avalues: array of msestring): macroinfoarty;
var
 int1: integer;
begin
 setlength(result,length(anames));
 for int1:= 0 to high(result) do begin
  with result[int1] do begin
   name:= anames[int1];
   if int1 <= high(avalues) then begin
    value:= avalues[int1];
   end;
  end;
 end;
end;

function initmacros(const anames,avalues: array of msestringarty): macroinfoarty;
var
 int1,int2,int3: integer;
begin
 int3:= 0;
 for int1:= 0 to high(anames) do begin
  int3:= int3 + length(anames[int1]);
 end;
 setlength(result,int3);
 int3:= 0;
 for int1:= 0 to high(anames) do begin
  for int2:= 0 to high(anames[int1]) do begin
   with result[int3] do begin
    name:= anames[int1,int2];
    if int2 <= high(avalues[int1]) then begin
     value:= avalues[int1,int2];
    end;
   end;
   inc(int3);
  end;
 end;
end;

function expandmacros(const value: msestring; const macros:macroinfoarty;
              const options: macrooptionsty = [mao_caseinsensitive]): msestring;
var
 list: tmacrolist;
begin
 list:= tmacrolist.create(options);
 try
  list.add(macros);
  result:= value;
  list.expandmacros(result);
 finally
  list.free;
 end;
end;

function expandmacros(const value: msestring; 
               const anames,avalues: array of msestring;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring; overload;
begin
 result:= expandmacros(value,initmacros(anames,avalues),options);
end;

{ 
function expandmacros(const value: msestring; const macros:macroinfoarty;
                 const caseinsensitive: boolean = true): msestring;
var
 list: tmacrolist;
begin
 list:= tmacrolist.create([mao_caseinsensitive]);
 try
  list.add(macros);
  result:= value;
  list.expandmacros(result);
 finally
  list.free;
 end;
end;
}
{ tmacrolist }

constructor tmacrolist.create(const aoptions: macrooptionsty);
begin
 foptions:= aoptions;
 inherited create(sizeof(macroinfoty),[rels_needsfinalize,rels_needscopy]);
end;

function tmacrolist.itempo(const index: integer): pmacroinfoty;
begin
 result:= pmacroinfoty(getitempo(index));
end;

procedure tmacrolist.add(const avalue: macroinfoty);
var
 info: macroinfoty;
begin
 if mao_caseinsensitive in foptions then begin
  info.name:= struppercase(avalue.name);
  info.value:= avalue.value;
  inherited add(info);
 end
 else begin
  inherited add(avalue);
 end;
end;

procedure tmacrolist.add(const avalue: macroinfoarty);
var
 int1: integer;
begin
 sorted:= false;
 for int1:= 0 to high(avalue) do begin
  add(avalue[int1]);
 end;
end;

procedure tmacrolist.add(const avalue: tmacrolist);
begin
 add(asarray);
end;

procedure tmacrolist.add(const names,values: array of msestring);
var
 int1: integer;
 ar1: macroinfoarty;
begin
 setlength(ar1,length(names));
 for int1:= 0 to high(names) do begin
  ar1[int1].name:= names[int1];
  if int1 <= high(values) then begin
   ar1[int1].value:= values[int1];
  end;
 end;
 add(ar1);
end;

procedure tmacrolist.resetexpandlevel;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  pmacroinfoaty(fdata)^[int1].expandlevel:= bigint;
 end;
end;

function tmacrolist.getvalue(const aname: msestring; 
                       var aexpandlevel: integer): msestring;
var
 info: macroinfoty;
 int1: integer;
begin
 if mao_caseinsensitive in foptions then begin
  info.name:= struppercase(aname);
 end
 else begin
  info.name:= aname;
 end;
 if internalfind(info,int1) then begin
  with pmacroinfoaty(fdata)^[int1] do begin
   result:= value;
   int1:= expandlevel;
   expandlevel:= aexpandlevel;
   aexpandlevel:= int1;
  end;
 end
 else begin
  result:= '';
  aexpandlevel:= bigint+1;
 end;
end;

function tmacrolist.compare(const l, r): integer;
begin
 result:= msestrcomp(pmsechar(macroinfoty(l).name),
                   pmsechar(macroinfoty(r).name));
end;

function tmacrolist.getcomparefunc: sortcomparemethodty;
begin
 result:= {$ifdef FPC}@{$endif}compare;
end;

procedure tmacrolist.copyrecord(var item);
begin
 with macroinfoty(item) do begin
  stringaddref(name);
  stringaddref(value);
 end;
end;

procedure tmacrolist.finalizerecord(var item);
begin
 finalize(macroinfoty(item));
end;
 
procedure tmacrolist.internalexpandmacros(var avalue: msestring; 
                     expandlevel: integer; var refindex: integerarty);

var
 start: pmsechar;
                      
 function checkmacrostart(po: pmsechar): pmsechar;
 begin
  if mao_curlybraceonly in foptions then begin
   repeat
    result:= msestrscan(po,msechar('{'));
    if result <> nil then begin
     if (result = start) then begin
      result:= nil;
     end
     else begin
      dec(result);
      if result^ = '$' then begin
       break;
      end;
      inc(po); //next curlybrace
     end;
    end;
   until result = nil;
  end
  else begin
   result:= msestrscan(po,msechar('$'))
  end;
 end; //checkmacrostart
 
var
 int1,int2,int3,int4: integer;
 po1,po2: pmsechar;
 str1,str2,str3: msestring;
 
begin
 if avalue <> '' then begin
  str1:= avalue; //copy
  po2:= pmsechar(str1);
  start:= po2;
  po1:= checkmacrostart(po2);
  if po1 <> nil then begin
   avalue:= '';
   while true do begin
    if expandlevel = 0 then begin
     resetexpandlevel;
    end;
    addstringsegment(avalue,po2,po1);
    if (po1+1)^ = '{' then begin
     po2:= msestrscan(po1,msechar('}'));
     if po2 <> nil then begin
      str2:= stringsegment(po1+2,po2);
      inc(po2)
     end
     else begin
      addstringsegment(avalue,po1,pmsechar(str1)+length(str1));
             //append the rest for missing }
      exit;
     end;
    end
    else begin
     po2:= po1;
     repeat
      inc(po2);
     until not ((po2^ = '_') or
               (po2^ >= 'a') and (po2^ <= 'z') or
               (po2^ >= 'A') and (po2^ <= 'Z') or
               (po2^ >= '0') and (po2^ <= '9'));
     str2:= stringsegment(po1+1,po2);
    end;
    //po1 = macro def start, po2 = macro def end
    if str2 <> '' then begin //macro name
     int1:= expandlevel+1;
     str3:= getvalue(str2,int1);
     if int1 <= expandlevel then begin
      str3:= '***'+str2+'***';
     end
     else begin
      internalexpandmacros(str3,expandlevel+1,integerarty(nil^));
     end;
     if @refindex <> nil then begin
      int4:= (po2-po1);
      int3:= length(str3) - int4;
      int4:= length(avalue) + int4;
      for int2:= high(refindex) downto 0 do begin
       if refindex[int2] >= int4 then begin
        refindex[int2]:= refindex[int2] + int3;
       end;
      end;
     end;
     avalue:= avalue + str3;
    end
    else begin
     int1:= bigint+1;
    end;
    if (int1 > bigint) and not (mao_removeunknown in foptions) then begin
     avalue:= avalue + stringsegment(po1,po2);
    end;
    if po2^ = #0 then begin
     break;
    end;
    po1:= checkmacrostart(po2);
    if po1 = nil then begin
     addstringsegment(avalue,po2,pmsechar(str1)+length(str1));
                                //locks str1
     break;
    end;
   end;
  end;
 end;
end;

procedure tmacrolist.expandmacros(var avalue: msestring; var refindex: integerarty);
begin
 internalexpandmacros(avalue,0,refindex);
end;

procedure tmacrolist.expandmacros(var avalue: msestring);
var
 ar1: integerarty;
begin
 ar1:= nil;
 expandmacros(avalue,ar1);
end;

procedure tmacrolist.expandmacros(var avalues: msestringarty);
var
 int1: integer;
begin
 setlength(avalues,length(avalues));
 for int1:= 0 to high(avalues) do begin
  expandmacros(avalues[int1]);
 end;
end;

procedure tmacrolist.statreadvalue(const aname: msestring;
  const reader: tstatreader);
begin
 clear;
 reader.readrecordarray(aname,{$ifdef FPC}@{$endif}setcount,
                 {$ifdef FPC}@{$endif}setrec);
end;

procedure tmacrolist.statwritevalue(const aname: msestring;
  const writer: tstatwriter);
begin
 writer.writerecordarray(aname,count,{$ifdef FPC}@{$endif}getrec);
end;

function tmacrolist.getrec(const index: integer): msestring;
begin
 with itempo(index)^ do begin
  result:= encoderecord([name,value]);
 end;
end;

procedure tmacrolist.setrec(const index: integer; const avalue: msestring);
begin
 with itempo(index)^ do begin
  decoderecord(avalue,[@name,@value],'SS');
 end;
end;

function tmacrolist.asarray: macroinfoarty;
var
 po1: pmacroinfoaty;
 int1: integer;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  result[int1]:= po1^[int1];
 end;
end;

procedure tmacrolist.asarray(out names, values: msestringarty);
var
 po1: pmacroinfoaty;
 int1: integer;
begin
 setlength(names,count);
 setlength(values,count);
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  names[int1]:= po1^[int1].name;
  values[int1]:= po1^[int1].value;
 end;
end;

end.
