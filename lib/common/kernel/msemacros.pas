{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

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
 tmacrolist = class;
 macrohandlerty = function(const sender: tmacrolist;
                                      const params: msestringarty): msestring;
 macrohandlerarty = array of macrohandlerty;
 
 macroinfoty = record
  name,value: msestring;
  handler: macrohandlerty;
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
   fpredefined: macroinfoarty;
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   function compare(const l,r): integer;
   function getcomparefunc: sortcomparemethodty; override;
   procedure setrec(const index: integer; const avalue: msestring);
   function getrec(const index: integer): msestring;
   procedure resetexpandlevel;
   function getvalue(const aname: msestring; var aexpandlevel: integer;
                                        out found: pmacroinfoty): msestring;
   function callhandler(const aname: msestring;const aparams: msestringarty;
                var aexpandlevel: integer; out found: pmacroinfoty): msestring;
   //istatupdatevalue
   procedure statreadvalue(const aname: msestring; const reader: tstatreader);
   procedure statwritevalue(const aname: msestring; const writer: tstatwriter);
   procedure internalexpandmacros(var avalue: msestring; expandlevel: integer;
                                                     var refindex: integerarty);
  public
   constructor create(const aoptions: macrooptionsty);
   constructor create(const aoptions: macrooptionsty;
                             const apredefined: array of macroinfoty);
   function find(const aname: msestring; out item: pmacroinfoty): boolean;
                //true if found;
   function itempo(const index: integer): pmacroinfoty;
   procedure add(const avalue: tmacrolist); overload;
   procedure add(const avalue: macroinfoty); overload;
   procedure add(const avalue: macroinfoarty); overload;
   procedure add(const names,values: array of msestring;
                            const handler: array of macrohandlerty); overload;

   procedure expandmacros1(var avalue: msestring);
   function expandmacros(const avalue: msestring): msestring;
   procedure expandmacros1(var avalue: msestring;
                            var refindex: integerarty);
   procedure expandmacros1(var avalues: msestringarty);
   function asarray: macroinfoarty;
   function asarray(const addnames: array of msestring;
                         const addvalues: array of msestring): macroinfoarty;
   procedure asarray(out names,values: msestringarty;
                              out handler: macrohandlerarty);
   procedure setasarray(const avalue: macroinfoarty);
   procedure setasarray(const names,values: msestringarty;
                          const handler: macrohandlerarty);
   property options: macrooptionsty read foptions write foptions;
   
   procedure setpredefined(const avalue: array of macroinfoty);
   procedure setpredefined(const avalue: array of macroinfoarty);
   property predefined: macroinfoarty read fpredefined write fpredefined;
                            //appended by setasarray procedures
 end;
 
//function expandmacros(const value: msestring; const macros:macroinfoarty;
//              const caseinsensitive: boolean = true): msestring; overload;
function initmacros(const amacros: array of macroinfoty): macroinfoarty;
function initmacros(const anames,avalues: array of msestring;
                    const ahandler: array of macrohandlerty): macroinfoarty;
function initmacros(const anames,avalues: array of msestringarty;
                    const ahandler: array of macrohandlerarty): macroinfoarty;
function initmacros(const amacros: array of macroinfoarty): macroinfoarty;

function expandmacros(const value: msestring; const macros: macroinfoarty;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring;
function expandmacros(const value: msestring; 
               const anames,avalues: array of msestring;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring;

function expandmacros2(const value: msestring; 
               const anames,avalues: array of msestring;
               const ahandler: array of macrohandlerty;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring;

implementation
uses
 msestream;

function initmacros(const amacros: array of macroinfoty): macroinfoarty;
var
 int1: integer;
begin
 setlength(result,length(amacros));
 for int1:= 0 to high(amacros) do begin
  result[int1]:= amacros[int1];
 end;
end;
 
function initmacros(const anames,avalues: array of msestring;
                    const ahandler: array of macrohandlerty): macroinfoarty;
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
   if int1 <= high(ahandler) then begin
    handler:= ahandler[int1];
   end;
  end;
 end;
end;

function initmacros(const anames,avalues: array of msestringarty;
                 const ahandler: array of macrohandlerarty): macroinfoarty;
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
    if int2 <= high(ahandler[int1]) then begin
     handler:= ahandler[int1,int2];
    end;
   end;
   inc(int3);
  end;
 end;
end;

function initmacros(const amacros: array of macroinfoarty): macroinfoarty;
var
 int1,int2,int3: integer;
begin
 int2:= 0;
 for int1:= 0 to high(amacros) do begin
  int2:= int2 + length(amacros[int1]);
 end;
 setlength(result,int2);
 for int1:= high(amacros) downto 0 do begin
  for int3:= high(amacros[int1]) downto 0 do begin
   dec(int2);
   result[int2]:= amacros[int1][int3];
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
  list.expandmacros1(result);
 finally
  list.free;
 end;
end;

function expandmacros(const value: msestring; 
               const anames,avalues: array of msestring;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring;
begin
 result:= expandmacros(value,initmacros(anames,avalues,[]),options);
end;

function expandmacros2(const value: msestring; 
               const anames,avalues: array of msestring;
               const ahandler: array of macrohandlerty;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring;
begin
 result:= expandmacros(value,initmacros(anames,avalues,ahandler),options);
end;

{
function expandmacrosstr(const value: msestring; 
               const anames,avalues: array of msestring;
   const options: macrooptionsty = [mao_caseinsensitive]): msestring;
begin
 result:= expandmacros(value,initmacros(anames,avalues,[]),options);
end;
}
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

constructor tmacrolist.create(const aoptions: macrooptionsty;
                                 const apredefined: array of macroinfoty);
begin
 create(aoptions);
 predefined:= initmacros(apredefined);
 add(fpredefined);
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
  info.handler:= avalue.handler;
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
 add(avalue.asarray);
end;

procedure tmacrolist.add(const names,values: array of msestring;
                                 const handler: array of macrohandlerty);
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
  if int1 <= high(handler) then begin
   ar1[int1].handler:= handler[int1];
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
                        var aexpandlevel: integer;
                        out found: pmacroinfoty): msestring;
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
  found:= @pmacroinfoaty(fdata)^[int1];
  with found^ do begin
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

function tmacrolist.find(const aname: msestring; 
                                out item: pmacroinfoty): boolean;
                //true if found;
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
 result:= internalfind(info,int1);
 if result then begin
  item:= @pmacroinfoaty(fdata)^[int1];
 end
 else begin
  item:= nil;
 end;
end;

function tmacrolist.callhandler(const aname: msestring; 
           const aparams: msestringarty; var aexpandlevel: integer;
           out found: pmacroinfoty): msestring;

var
// info: macroinfoty;
 int1: integer;

begin
{
 if mao_caseinsensitive in foptions then begin
  info.name:= struppercase(aname);
 end
 else begin
  info.name:= aname;
 end;
 if internalfind(info,int1) then begin
}
 if find(aname,found) then begin
//  found:= @pmacroinfoaty(fdata)^[int1];
  with found^ do begin
   if handler <> nil then begin
    result:= handler(self,aparams);
   end
   else begin
    result:= value;
   end;
   int1:= expandlevel;
   expandlevel:= aexpandlevel;
   aexpandlevel:= int1;
  end;
 end
 else begin
//  found:= nil;
  result:= '';
  aexpandlevel:= bigint+1; //not found
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
 po1,po2,po3,po4,po5: pmsechar;
 str1,str2,str3: msestring;
 ar1: msestringarty;
 found: pmacroinfoty;
 
begin
 if avalue <> '' then begin
  found:= nil;
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
    po2:= po1+1;
    if (po2)^ = '{' then begin
     inc(po2);
     int1:= 0;
     while po2^ <> #0 do begin
      if po2^ = '"' then begin //skip quoted
       inc(po2);
       while po2^ <> #0 do begin
        if po2^ = '"' then begin
         break;
        end;
        inc(po2);
       end;
      end;
      if po2^ = '{' then begin
       inc(int1);
      end;
      if po2^ = '}' then begin
       dec(int1);
       if int1 < 0 then begin
        break;
       end;
      end;
      inc(po2);
     end; 
     if po2^ <> #0 then begin
      po3:= po1+2;
      str2:= stringsegment(po3,po2);
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
     po3:= po1+1;
     str2:= stringsegment(po3,po2);
    end;
    //po1 = macro def start, po2 = macro def end
    if str2 <> '' then begin //macro name
     int1:= expandlevel+1;
     po4:= po2-1;
     if po4^ = '}' then begin
      dec(po4);
      if (po4)^ = ')' then begin
       po5:= po3;
       while (po5 < po4) and (po5^ <> '(') do begin
        inc(po5);
       end;
       if po5 < po4 then begin
        setlength(str2,po5-po3);
        str3:= stringsegment(po5+1,po4);
        ar1:= splitstringquoted(str3,',','"');
        for int2:= 0 to high(ar1) do begin
         internalexpandmacros(ar1[int2],expandlevel+1,integerarty(nil^));
        end;
        int1:= expandlevel+1;
        str3:= callhandler(str2,ar1,int1,found);
       end
       else begin
        int1:= bigint+1; //not found
       end;
      end
      else begin
       str3:= getvalue(str2,int1,found);
      end;
     end
     else begin
      str3:= getvalue(str2,int1,found);
     end;
     if int1 <= expandlevel then begin
      str3:= '!!R*'+str2+'*R!!';
     end
     else begin
      internalexpandmacros(str3,expandlevel+1,integerarty(nil^));
     end;
     if found <> nil then begin
      found^.expandlevel:= bigint; //can be reused
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

procedure tmacrolist.expandmacros1(var avalue: msestring;
                                   var refindex: integerarty);
begin
 internalexpandmacros(avalue,0,refindex);
end;

procedure tmacrolist.expandmacros1(var avalue: msestring);
var
 ar1: integerarty;
begin
 ar1:= nil;
 expandmacros1(avalue,ar1);
end;

function tmacrolist.expandmacros(const avalue: msestring): msestring;
begin
 result:= avalue;
 expandmacros1(result);
end;

procedure tmacrolist.expandmacros1(var avalues: msestringarty);
var
 int1: integer;
begin
 setlength(avalues,length(avalues));
 for int1:= 0 to high(avalues) do begin
  expandmacros1(avalues[int1]);
 end;
end;

procedure tmacrolist.statreadvalue(const aname: msestring;
  const reader: tstatreader);
begin
 clear;
 reader.readrecordarray(aname,@setcount,@setrec);
end;

procedure tmacrolist.statwritevalue(const aname: msestring;
  const writer: tstatwriter);
begin
 writer.writerecordarray(aname,count,@getrec);
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
  handler:= nil;
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

function tmacrolist.asarray(const addnames: array of msestring;
                         const addvalues: array of msestring): macroinfoarty;
var
 int1,int2,int3: integer;
begin
 result:= asarray();
 int1:= length(addnames);
 if int1 > length(addvalues) then begin
  int1:= length(addvalues);
 end;
 int2:= length(result);
 setlength(result,int2+int1);
 int3:= 0;
 for int1:= int2 to high(result) do begin
  result[int1].name:= addnames[int3];
  result[int1].value:= addvalues[int3];
  inc(int3);
 end;
end;

procedure tmacrolist.asarray(out names, values: msestringarty;
                                            out handler: macrohandlerarty);
var
 po1: pmacroinfoaty;
 int1: integer;
begin
 setlength(names,count);
 setlength(values,count);
 setlength(handler,count);
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  names[int1]:= po1^[int1].name;
  values[int1]:= po1^[int1].value;
  handler[int1]:= po1^[int1].handler;
 end;
end;

procedure tmacrolist.setasarray(const avalue: macroinfoarty);
begin
 clear();
 add(fpredefined);
 add(avalue);
end;

procedure tmacrolist.setasarray(const names: msestringarty;
               const values: msestringarty; const handler: macrohandlerarty);
begin
 clear();
 add(fpredefined);
 add(names,values,handler);
end;

procedure tmacrolist.setpredefined(const avalue: array of macroinfoty);
begin
 fpredefined:= initmacros(avalue);
end;

procedure tmacrolist.setpredefined(const avalue: array of macroinfoarty);
begin
 fpredefined:= initmacros(avalue);
end;

end.
