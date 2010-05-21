{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesyntaxpainter;

{
COLORS [[[fontcolor [backgroundcolor [statementcolor]]]
                      cl_default for project options settings
}

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$endif}

interface

uses
 Classes,msestrings,mserichstring,msedatalist,
 msestream,msehash,msetimer,msestat,msetypes,mseclasses,mseguiglob,mseevent,
 msegraphutils;

const
 defaultkeywordchars: set of char = ['A'..'Z','a'..'z','0'..'9','_'];
 defaultlinesperslice = 100;

type
 starttokenty = record
  token: msestring;
  fontinfonr: integer;
  scopenr: integer;
  call: boolean;
 end;
 starttokenpoty = ^starttokenty;
 starttokenarty = array of starttokenty;

 endtokenty = record
  token: msestring;
  fontinfonr: integer;
 end;
 endtokenpoty = ^endtokenty;
 endtokenarty = array of endtokenty;

 keywordinfoty = record
  nr: integer;
  fontinfonr: integer;
 end;
 keywordinfoarty = array of keywordinfoty;

 scopeinfoty = record
  keywords: keywordinfoarty;
  starttokens: starttokenarty;
  endtokens: endtokenarty;
  hasendtokens: boolean;
  return: boolean;
  fontinfonr: integer;
 end;
 scopeinfopoty = ^scopeinfoty;
 scopeinfoarty = array of scopeinfoty;
 charsty = set of char;
 charspoty = ^charsty;

 keywordarty = array of thashedmsestrings;

 refreshinfoty = record
  astart,count: integer;
  handle: integer;
//  startscopenr: integer;
 end;
 prefreshinfoty = ^refreshinfoty;

 trefreshinfolist = class(tdatalist)
  private
   function Getitems(index: integer): refreshinfoty;
   procedure Setitems(index: integer; const Value: refreshinfoty); //fifo
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
  public
   constructor create; override;
   procedure push(const value: refreshinfoty);
   function pop: boolean; overload;
   function pop(out value: refreshinfoty): boolean; overload;
   property items[index: integer]: refreshinfoty read Getitems write Setitems; default;
 end;

 scopestackcachety = record
  startscope: integer;
  stack: integerarty;
 end;

 scopestackcachearty = array of scopestackcachety;

 clientinfoty = record
  client: tobject;
  syntaxdefhandle: integer;
  scopestack: integerarty;
  scopestackpo: integer;
  scopestackcache: scopestackcachearty;
  scopestackcachepo: integer;
  list: trichstringdatalist;
  onlinechanged: integerchangedeventty;
  boldchars: gridcoordarty;
 end;
 pclientinfoty = ^clientinfoty;
 clientinfoarty = array of clientinfoty;

 syntaxcolorinfoty = record
  font: colorty;
  background: colorty;
  statement: colorty;
 end;
 
 syntaxdefty = record
  defdefsnr: integer; //-1 -> mit readdeffile geladen
  charstyles: tcharstyledatalist;
  caseinsensitive: boolean;
  scopeinfos: scopeinfoarty;
  aktscopeinfo: integer;
  keywordchars: charsty;
  scopeendchars,scopestartchars: charsty;
  keywordar: keywordarty;
  keywordnames: thashedstrings;
  colors: syntaxcolorinfoty;
 end;

 syntaxdefpoty = ^syntaxdefty;
 syntaxdefarty = array of syntaxdefty;

 tsyntaxpainter = class(tmsecomponent)
  private
   ftimer: tsimpletimer;
   frefreshlist: trefreshinfolist;
   flinesperslice: integer;
   fclients: clientinfoarty;
   fsyntaxdefs: syntaxdefarty;
   fdefdefs: tdoublemsestringdatalist;
   fdefsdir: string;
   fdeftext: tmsestringdatalist;
   fdefaultsyntax: integer;
   procedure dotimer(const sender: tobject);
   procedure syntaxchanged;
   procedure internalpaintsyntax(handle: integer; start,count: integer;
                         var startscopenr: integer);
                               //-1 = letzte in fscopeinfos
   procedure clearsyntaxdef(handle: integer);
   procedure initsyntaxdef(handle: integer);
   procedure setdefdefs(const Value: tdoublemsestringdatalist);
   procedure setlinesperslice(const Value: integer);
   procedure calcrefreshinfo(var info: refreshinfoty; var startscope: integer);
   procedure setdeftext(const avalue: tmsestringdatalist);
   procedure deflistchanged(const sender: tobject);
   function getboldchars(index: integer): gridcoordarty;
   procedure setboldchars(index: integer; const avalue: gridcoordarty);
   function getcolors(index: integer): syntaxcolorinfoty;
  protected

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear;
   procedure paintsyntax(handle: integer; start,count: halfinteger; //startrow,rowcount
                         background: boolean = false);
                               //-1 = letzte in fscopeinfos
   function registerclient(sender: tobject; alist: trichstringdatalist;
                  aonlinechanged: integerchangedeventty = nil;
                  asyntaxdefhandle: integer = 0): integer;
                  //-1 = alles veraendert

   procedure unregisterclient(handle: integer);
               //eintreage mit alist loeschen
   function readdeffile(stream: ttextstream): integer; overload;
   function readdeffile(const afilename: filenamety): integer; overload;
   function readdeffile(const atext: string): integer; overload;
   procedure freedeffile(handle: integer);
   function linkdeffile(const sourcefilename: filenamety): integer;
                 //-1 if syntaxdef not found
   property defaultsyntax: integer read fdefaultsyntax;
   property boldchars[index: integer]: gridcoordarty read getboldchars 
                                    write setboldchars;
   property colors[index: integer]: syntaxcolorinfoty read getcolors;
  published
   property linesperslice: integer read flinesperslice write setlinesperslice
                default defaultlinesperslice;
   property defdefs: tdoublemsestringdatalist read fdefdefs write setdefdefs;
        //a = filemask, b = deffilename,
        // multiple masks quoted
        // examples :      a                b
        //              '*.pp'           'pas.sdef'
        //              '"*.pp" "*.pas"' 'pas.sdef'

   property defsdir: string read fdefsdir write fdefsdir;
   property deftext: tmsestringdatalist read fdeftext write setdeftext;
  end;

implementation
uses
 sysutils,msefileutils,msesys,mseformatstr,msegraphics,mseglob;

procedure markstartchars(const str: msestring; var chars: charsty); overload;
begin
 if length(str) = 0 then begin
  include(chars,#0);
 end
 else begin
  include(chars,char(str[1]));
 end
end;

procedure markstartchars(const strar: msestringarty; var chars: charsty); overload;
var
 int1: integer;
begin
 for int1:= 0 to high(strar) do begin
  markstartchars(strar[int1],chars);
 end;
end;

procedure markstartchars(const starttokens: starttokenarty; var chars: charsty); overload;
var
 int1: integer;
begin
 for int1:= 0 to high(starttokens) do begin
  if length(starttokens[int1].token) = 0 then begin
   include(chars,#0);
  end
  else begin
   include(chars,char(starttokens[int1].token[1]));
  end
 end;
end;

{ trefreshinfolist }

constructor trefreshinfolist.create;
begin
 inherited;
 fsize:= sizeof(refreshinfoty);
end;

function trefreshinfolist.Getitems(index: integer): refreshinfoty;
begin
 getdata(index,result);
end;

procedure trefreshinfolist.Setitems(index: integer;
  const Value: refreshinfoty);
begin
 setdata(index,value);
end;

function trefreshinfolist.pop: boolean;
var
 po1: pbyte;
begin
 po1:= nil;
 {$ifdef FPC}{$checkpointer off}{$endif}
 result:= popbottomdata(po1^);
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

function trefreshinfolist.pop(out value: refreshinfoty): boolean;
begin
 result:= popbottomdata(value);
end;

procedure trefreshinfolist.push(const value: refreshinfoty);
begin
 pushdata(value);
end;

function trefreshinfolist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(trefreshinfolist);
end;

{ tsyntaxpainter }

constructor tsyntaxpainter.create(aowner: tcomponent);
begin
 frefreshlist:= trefreshinfolist.create;
 ftimer:= tsimpletimer.Create(0,{$ifdef FPC}@{$endif}dotimer,false);
 flinesperslice:= defaultlinesperslice;
 fdefdefs:= tdoublemsestringdatalist.create;
 fdefaultsyntax:= -1;
 fdeftext:= tmsestringdatalist.create;
 fdeftext.onchange:= {$ifdef FPC}@{$endif}deflistchanged;
 inherited;
end;

destructor tsyntaxpainter.destroy;
begin
 clear;
 inherited;
 ftimer.Free;
 frefreshlist.Free;
 fdefdefs.free;
 fdeftext.free;
end;

procedure tsyntaxpainter.clear;
var
 int1: integer;
begin
 frefreshlist.clear;
 for int1:= 0 to high(fclients) do begin
  if fclients[int1].client <> nil then begin
   unregisterclient(int1);
  end;
 end;
 for int1:= 0 to high(fsyntaxdefs) do begin
  clearsyntaxdef(int1);
 end;
 sendchangeevent(oe_disconnect); 
end;

procedure tsyntaxpainter.clearsyntaxdef(handle: integer);
var
 int1: integer;
begin
 with fsyntaxdefs[handle] do begin
  freeandnil(charstyles);
  freeandnil(keywordnames);
  for int1:= 0 to high(keywordar) do begin
   keywordar[int1].Free;
  end;
 end;
 finalize(fsyntaxdefs[handle]);
end;

procedure tsyntaxpainter.initsyntaxdef(handle: integer);
begin
 finalize(fsyntaxdefs[handle]);
 fillchar(fsyntaxdefs[handle],sizeof(syntaxdefty),0);
 with fsyntaxdefs[handle] do begin
  defdefsnr:= -1;
  charstyles:= tcharstyledatalist.create;
  charstyles.add; //default
  keywordchars:= defaultkeywordchars;
  keywordnames:= thashedstrings.create;
  with colors do begin
   font:= cl_default;
   background:= cl_default;
   statement:= cl_default;
  end;
 end;
end;

function tsyntaxpainter.registerclient(sender: tobject; alist: trichstringdatalist;
   aonlinechanged: integerchangedeventty = nil; asyntaxdefhandle: integer = 0): integer;

 procedure initclient(var info: clientinfoty);
 begin
  info.client:= sender;
  info.syntaxdefhandle:= asyntaxdefhandle;
  info.list:= alist;
  info.onlinechanged:= aonlinechanged;
 end;

var
 int1: integer;
begin
 for int1:= 0 to high(fclients) do begin
  if fclients[int1].client = nil then begin
   initclient(fclients[int1]);
   result:= int1;
   exit;
  end;
 end;
 setlength(fclients,length(fclients)+1);
 initclient(fclients[high(fclients)]);
 result:= high(fclients);
end;

procedure tsyntaxpainter.unregisterclient(handle: integer);
            //eintreage mit alist loeschen
var
 int1: integer;
begin
 checkarrayindex(fclients,handle);
 int1:= 0;
 while int1 < frefreshlist.count do begin
  if frefreshlist[int1].handle = handle then begin
   frefreshlist.deletedata(int1);
  end
  else begin
   inc(int1);
  end;
 end;
 finalize(fclients[handle]);
 fillchar(fclients[handle],sizeof(clientinfoty),0);
end;

procedure tsyntaxpainter.setlinesperslice(const Value: integer);
var
 int1: integer;
begin
 if flinesperslice <> value then begin
  flinesperslice := Value;
  for int1:= 0 to high(fclients) do begin
   with fclients[int1] do begin
    scopestackcache:= nil; //scopestacks are now invlid
    scopestackcachepo:= 0;
   end;
  end;
 end;
end;

procedure tsyntaxpainter.internalpaintsyntax(handle: integer;
            start,count: integer; var startscopenr: integer);
var
 scopeinfopo: scopeinfopoty;

 procedure popscope;
 begin
  with fclients[handle] do begin
   if scopestackpo > 0 then begin
    dec(scopestackpo);
    startscopenr:= scopestack[scopestackpo];
    scopeinfopo:= @fsyntaxdefs[syntaxdefhandle].scopeinfos[startscopenr];
   end;
  end;
 end;

 procedure pushscope(const starttoken: starttokenty);
 begin
  with starttoken,fclients[handle] do begin
   if call then begin
    inc(scopestackpo);
    if length(scopestack) <= scopestackpo then begin
     setlength(scopestack,scopestackpo+1);
    end;
   end;
   scopestack[scopestackpo]:= scopenr;
   scopeinfopo:= @fsyntaxdefs[syntaxdefhandle].scopeinfos[scopenr];
   startscopenr:= scopenr;
  end;
 end;

var
 str1: msestring;
 lstr1: lmsestringty;
 po1: pointer;
 changed: boolean;
 int1,int2,int3: integer;
 bo1: boolean;
 ristr: prichstringty;
 startpo,wpo1: pmsechar;
 alen,keywordlen: integer;
 ar1: msestringarty;
 stok1: starttokenty;
 format: formatinfoarty;
 firstrow,lastrow: integer;

label
 endlab;
 
begin
 ar1:= nil; //copilerwarning
 format:= nil; //copilerwarning
 firstrow:= start;
 lastrow:= start+count-1;
 with fclients[handle] do begin
  if (syntaxdefhandle < 0) or (syntaxdefhandle > high(fsyntaxdefs)) or
              (fsyntaxdefs[syntaxdefhandle].charstyles = nil) then begin
   goto endlab;
  end;
  with fsyntaxdefs[syntaxdefhandle] do begin
   if startscopenr = -1 then begin
    startscopenr:= high(scopeinfos);
    stok1.scopenr:= startscopenr;
    stok1.call:= true;
    scopestackpo:= -1;
    pushscope(stok1);
   end;
   if (startscopenr >= 0) and (startscopenr < length(scopeinfos)) then begin
    scopeinfopo:= @scopeinfos[startscopenr];
    while count > 0 do begin
     if start >= list.count then begin
      goto endlab;
     end;
     if (flinesperslice <> 0) and (start mod flinesperslice = 0) then begin
      scopestackcachepo:= start div flinesperslice + 1;
      if length(scopestackcache) < scopestackcachepo then begin
       setlength(scopestackcache,scopestackcachepo);
      end;
      scopestackcache[scopestackcachepo-1].stack:= copy(scopestack,0,scopestackpo+1);
      scopestackcache[scopestackcachepo-1].startscope:= startscopenr;
     end;
     changed:= false;
     ristr:= list.richitemspo[start];
     format:= ristr^.format;
     startpo:= pointer(ristr^.text);
     wpo1:= startpo;
     alen:= length(msestring(startpo));
     keywordlen:= 0;
     changed:= setcharstyle(format,
                               0,bigint,charstyles[scopeinfopo^.fontinfonr]) or changed;
     if alen > 0 then begin
      repeat
       if keywordlen <= 0 then begin
        lstr1.po:= wpo1;
        while char(wpo1^) in keywordchars do begin
         inc(wpo1);
        end;
        lstr1.len:= wpo1-lstr1.po;
        if lstr1.len > 0 then begin         //keyword suchen
         if caseinsensitive then begin
          str1:= struppercase(lstr1);
         end;
         po1:= nil;
         for int1:= 0 to high(scopeinfopo^.keywords) do begin
          with keywordar[scopeinfopo^.keywords[int1].nr-1] do begin
           if caseinsensitive then begin
            po1:= find(str1);
           end
           else begin
            po1:= find(lstr1);
           end;
          end;
          if po1 <> nil then begin //wort gefunden
           if scopeinfopo^.keywords[int1].fontinfonr <> 0 then begin
            po1:= pointer(scopeinfopo^.keywords[int1].fontinfonr+1);
           end;            //eigene fontinfonr dominiert
           break;
          end;
         end;
         if po1 <> nil then begin
          changed:= setcharstyle(format,lstr1.po-startpo,lstr1.len,
                                charstyles[integer(po1)-1]) or changed;
          dec(alen,lstr1.len);
          keywordlen:= 0;
         end
         else begin
          keywordlen:= lstr1.len;
          dec(wpo1,lstr1.len); //text zurueckgeben
         end;
        end;
       end;
       bo1:= true;
       if scopeinfopo^.hasendtokens or scopeinfopo^.return then begin
        if (length(scopeinfopo^.endtokens) > 0) then begin
         if (char(wpo1^) in scopeendchars) then begin
                       //endtoken suchen
          for int1:= 0 to high(scopeinfopo^.endtokens) do begin
           with scopeinfopo^.endtokens[int1] do begin
            if msestartsstr(pointer(token),wpo1) then begin
             bo1:= false;
             int2:= length(token);
             changed:= setcharstyle(format,wpo1-startpo,int2,
                      charstyles[scopeinfopo^.endtokens[int1].fontinfonr]) or changed;
             inc(wpo1,int2);
             if int2 = 0 then begin
              int2:= 1; //zeilenende
             end;
             dec(alen,int2);
             dec(keywordlen,int2);
             popscope;
             changed:= setcharstyle(format,wpo1-startpo,bigint,
                                   charstyles[scopeinfopo^.fontinfonr]) or changed;
             break;
            end;
           end;
          end;
         end;
        end
        else begin  //return on any char
         if not scopeinfopo^.return and (wpo1^ <> #0) then begin
          inc(wpo1);
         end;       //else return immediately
//         dec(alen);
//         dec(keywordlen);
         bo1:= false;
         popscope;
         changed:= setcharstyle(format,wpo1-startpo,bigint,
                         charstyles[scopeinfopo^.fontinfonr]) or changed;
        end;
       end;
       if bo1 and (length(scopeinfopo^.starttokens) > 0) and (char(wpo1^) in scopestartchars) then begin
                       //starttoken suchen
        for int1:= 0 to high(scopeinfopo^.starttokens) do begin
         if msestartsstr(pointer(scopeinfopo^.starttokens[int1].token),wpo1) then begin
          bo1:= false;
          int2:= length(scopeinfopo^.starttokens[int1].token);
          if scopeinfopo^.starttokens[int1].fontinfonr <> 0 then begin
           changed:= setcharstyle(format,wpo1-startpo,int2,
                    charstyles[scopeinfopo^.starttokens[int1].fontinfonr]) or changed;
           int3:= int2;
          end
          else begin
           int3:= 0;     //keine sonderbehandlung
          end;
          pushscope(scopeinfopo^.starttokens[int1]);
          changed:= setcharstyle(format,wpo1-startpo+int3,bigint,
                         charstyles[scopeinfopo^.fontinfonr]) or changed;
          inc(wpo1,int2);
          dec(alen,int2);
          dec(keywordlen,int2);
          break;
         end;
        end;
       end;
       if bo1 then begin
        inc(wpo1);
        dec(alen);
        dec(keywordlen);
       end;
      until alen < 0;
      if scopeinfopo^.return then begin
       popscope;
      end;
     end;
     if changed then begin
      if assigned(onlinechanged) then begin
       bo1:= isequalformat(ristr^.format,format);
       if not bo1 then begin
        ristr^.format:= format;
        onlinechanged(self,start);
       end;
      end
      else begin
       ristr^.format:= format;
      end;
     end;
     inc(start);
     dec(count);
    end;
   end;
  end;
endlab:
  for int1:= 0 to high(boldchars) do begin
   with boldchars[int1] do begin
    if (row >= firstrow) and (row <= lastrow) then begin
     if updatefontstyle(list.richitemspo[row]^.format,col,1,fs_bold,true) then begin
      if assigned(onlinechanged) then begin
       onlinechanged(self,row);
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsyntaxpainter.calcrefreshinfo(var info: refreshinfoty; var startscope: integer);
var
 startbefore: integer;
 stackspo: integer;
begin
 with info do begin
  startbefore:= astart;
  if flinesperslice > 0 then begin
   stackspo:= astart div flinesperslice;
  end
  else begin
   stackspo:= -1;
  end;
  with fclients[handle] do begin
   if stackspo >= scopestackcachepo then begin
    stackspo:= scopestackcachepo-1;
   end;
   if stackspo >= 0 then begin
    astart:= stackspo * flinesperslice;
    scopestack:= scopestackcache[stackspo].stack;
    scopestackpo:= high(scopestack);
    startscope:= scopestackcache[stackspo].startscope;
   end
   else begin
    startscope:= -1;
    astart:= 0; //recalc from begining
   end;
   count:= count + astart - startbefore;
  end;
 end;
end;

procedure tsyntaxpainter.paintsyntax(handle: integer;
            start,count: halfinteger; background: boolean = false);


var
 refreshinfo: refreshinfoty;
 int1,int2: integer;
 startscopenr: integer;
 po1: prefreshinfoty;
begin
 checkarrayindex(fclients,handle);
// refreshinfo.startscopenr:= -1;
 refreshinfo.handle:= handle;
 refreshinfo.astart:= start;
 refreshinfo.count:= count;
 if background then begin
  for int1:= 0 to frefreshlist.count - 1 do begin
   po1:= frefreshlist.getitempo(int1);
   if po1^.handle = handle then begin
    int2:= start+count - (po1^.astart + po1^.count); //new endpoint - aendpoint
    if po1^.astart <= start then begin
     if int2 > 0 then begin //new task longer
      inc(po1^.count,int2); //exend end
     end;
    end
    else begin
     if int2 > 0 then begin //new task longer
      po1^.count:= count;
     end
     else begin
      inc(po1^.count,po1^.astart-start);
     end;
     po1^.astart:= start;
    end;
    exit; //task extended
   end;
  end;
  frefreshlist.push(refreshinfo);
  ftimer.Enabled:= true;
  exit;
 end;
 calcrefreshinfo(refreshinfo,startscopenr);
 internalpaintsyntax(handle,refreshinfo.astart,refreshinfo.count,startscopenr);
end;

procedure tsyntaxpainter.dotimer(const sender: tobject);
var
 po1: prefreshinfoty;
 int1: integer;
 startscopenr: integer;
begin
 if frefreshlist.count > 0 then begin
  po1:= prefreshinfoty(frefreshlist.getitempo(0));
  calcrefreshinfo(po1^,startscopenr);
  with po1^ do begin
   if flinesperslice = 0 then begin
    int1:= count;
   end
   else begin
    if count > flinesperslice + 1 then begin
     int1:= flinesperslice + 1;
    end
    else begin
     int1:= count;
    end;
   end;
   internalpaintsyntax(handle,astart,int1,startscopenr);
   dec(count,int1);
   if count <= 0 then begin
    frefreshlist.pop
   end
   else begin
    inc(astart,int1);
    if astart >= fclients[handle].List.count then begin
     frefreshlist.pop;
    end
   end;
  end;
  if frefreshlist.count <> 0 then begin
   ftimer.Enabled:= true;
  end;
 end;
end;

function tsyntaxpainter.readdeffile(stream: ttextstream): integer;
type
 tokennrty = (tn_styles,tn_caseinsensitive,tn_keywordchars,tn_addkeywordchars,
              tn_colors,tn_keyworddefs,
              tn_scope,tn_endtokens,tn_keywords,tn_jumptokens,tn_calltokens,
              tn_return);
const
 tn_canmultiple = [tn_keyworddefs];

 nonetoken = 'NONE';
 tokens: array[tokennrty] of string = (
       'STYLES','CASEINSENSITIVE','KEYWORDCHARS','ADDKEYWORDCHARS',
       'COLORS','KEYWORDDEFS',
       'SCOPE','ENDTOKENS','KEYWORDS','JUMPTOKENS','CALLTOKENS',
       'RETURN');
 tn_localstart = tn_scope;
var
 linenr: integer;
 line: string;
 akttoken: tokennrty;
 syntaxdefpo: syntaxdefpoty;

 procedure addkeywordrule(const keywordsnr: integer; afontinfonr: integer);
 begin
  with syntaxdefpo^ do begin
   setlength(scopeinfos[aktscopeinfo].keywords,
              length(scopeinfos[aktscopeinfo].keywords)+1);
   with scopeinfos[aktscopeinfo].keywords[high(scopeinfos[aktscopeinfo].keywords)] do begin
    nr:= keywordsnr;
    fontinfonr:= afontinfonr;
   end;
  end;
 end;

 procedure updateaktscope;
 var
  int1: integer;
 begin
  with syntaxdefpo^ do begin
   if aktscopeinfo < length(scopeinfos) then begin
    with scopeinfos[aktscopeinfo] do begin
     markstartchars(starttokens,scopestartchars);
     for int1:= 0 to high(endtokens) do begin
      markstartchars(endtokens[int1].token,scopeendchars);
     end;
    end;
   end;
  end;
 end;

 function addscoperule(const astarttokens: starttokenarty;
                  const aendtokens: endtokenarty; ahasendtokens: boolean;
                  areturn: boolean;
                  afontinfonr: integer;
                  const akeywords: keywordinfoarty): integer;

 begin
  with syntaxdefpo^ do begin
   result:= length(scopeinfos);
   aktscopeinfo:= result;
   setlength(scopeinfos,result+1);
   with scopeinfos[result] do begin
    keywords:= akeywords;
    starttokens:= copy(astarttokens);
    endtokens:= copy(aendtokens);
    hasendtokens:= ahasendtokens;
    return:= areturn;
    fontinfonr:= afontinfonr;
   end;
   updateaktscope;
  end;
 end;


 procedure error(text: string);
 begin
  raise exception.Create(text+'!');
 end;

 function lineinfo: string;
 begin
  result:= ' at line '+ inttostr(linenr);
 end;

 procedure invalidtoken;
 begin
  error('Invalid token '''+line+''''+lineinfo);
 end;

 procedure noscope;
 begin
  error('No scope'+lineinfo);
 end;

 procedure invalidstyle;
 begin
  error('Invalid style '''+line+''''+lineinfo);
 end;

 procedure invalidname;
 begin
  error('Invalid name '''+line+''''+lineinfo);
 end;

 procedure nameexists;
 begin
  error('Name exists. '''+line+''''+lineinfo);
 end;

 procedure namenotfound;
 begin
  error('Name not found. '''+line+''''+lineinfo);
 end;

 procedure invalidstring;
 begin
  error('Invalid string. '''+line+''''+lineinfo);
 end;

 procedure invalidcolor;
 begin
  error('Invalid color. '''+line+''''+lineinfo);
 end;

 function getcolor(var aline: lstringty; out acolor: colorty): boolean;
 var
  str1: string;
 begin
  result:= false;
  nextword(aline,str1);
  if str1 <> '' then begin
   try
    acolor:= stringtocolor(str1);
   except
    invalidcolor;
   end;
  end;
  result:= true;
 end;
 
 procedure addname(list: thashedstrings; const name: lstringty; nummer: integer);
 var
  str1: string;
 begin
  str1:= struppercase(name);
  if list.find(str1) <> nil then begin
   nameexists;
  end;
  if (length(str1) = 0) or not ((str1[1] >= 'A') and (str1[1] <= 'Z')) then begin
   invalidname;
  end;
  list.add(str1,pointer(nummer+1));
 end;

 function findname(list: thashedstrings; const name: lstringty): integer;
 begin
  result:= integer(list.findi(name));
  if result = 0 then begin
   namenotfound;
  end;
  dec(result);
 end;

const
 defaultname = 'DEFAULT';
var
 flags: set of tokennrty;
 str1: string;
 keys: thashedstrings;
 scopenames,stylenames: thashedstrings;
 int1,int2,int3: integer;
 lstr1,lstr2,lstr3: lstringty;
 global: boolean;
 wstrar1: msestringarty;
 bo1: boolean;
 aktkeywordfontinfonr: integer;
 

begin
 result:= -1;
 for int1:= 0 to high(fsyntaxdefs) do begin
  if fsyntaxdefs[int1].charstyles = nil then begin
   result:= int1;
   break;
  end;
 end;
 if result = -1 then begin
  result:= length(fsyntaxdefs);
  setlength(fsyntaxdefs,result+1);
 end;
 initsyntaxdef(result);
 syntaxdefpo:= @fsyntaxdefs[result];
 with syntaxdefpo^ do begin
  keys:= thashedstrings.create;
  scopenames:= thashedstrings.create;
  stylenames:= thashedstrings.create;
  keys.add(tokens);
  stylenames.add('',pointer(1)); //default
 // fcharstyles.add; //default
  global:= true;
  linenr:= 0;
  flags:= [];
  akttoken:= tokennrty(-1);
  aktkeywordfontinfonr:= 0;
  try
   repeat
    stream.readln(line);
    inc(linenr);
    if (strlnscan(pointer(line),' ',length(line)) <> nil) and (checkfirstchar(line,'#') = nil) then begin
     stringtolstring(line,lstr1);
     nextword(lstr1,lstr2);
     int1:= integer(keys.findi(lstr2));
     if int1 <> 0 then begin
      akttoken:= tokennrty(int1-1);
      if akttoken in (flags - tn_canmultiple) then begin
       invalidtoken;
      end;
      include(flags,akttoken);
      if akttoken >= tn_localstart then begin
       global:= false;
      end;
      if global then begin
       case akttoken of
        tn_caseinsensitive: caseinsensitive:= true;
        tn_keywordchars: begin
         keywordchars:= [];
        end;
        tn_keyworddefs: begin
         nextword(lstr1,lstr3);
         if lstr3.len = 0 then begin
          invalidtoken;
         end;
         setlength(keywordar,length(keywordar)+1);
         keywordar[high(keywordar)]:= thashedmsestrings.create;
         addname(keywordnames,lstr3,length(keywordar));
        end;
        tn_colors: begin
         if getcolor(lstr1,colors.font) then begin
          if getcolor(lstr1,colors.background) then begin
           if getcolor(lstr1,colors.statement) then begin
           end;
          end;
         end;
        end;
        tn_addkeywordchars,tn_styles: begin
        end;
        else begin
         invalidtoken;
        end;
       end;
      end
      else begin
       case akttoken of
        tn_scope: begin
         nextword(lstr1,lstr2);
         nextword(lstr1,lstr3);
         int1:= findname(stylenames,lstr3);
         updateaktscope;
         addname(scopenames,lstr2,addscoperule(nil,nil,false,false,int1,nil));
         flags:= [];
        end;
        tn_keywords: begin
         if length(scopeinfos) = 0 then begin
          noscope;
         end;
         nextword(lstr1,lstr3);
         aktkeywordfontinfonr:= findname(stylenames,lstr3);
        end;
        tn_return,tn_endtokens,tn_calltokens,tn_jumptokens: begin
         if length(scopeinfos) = 0 then begin
          noscope;
         end
         else begin
          if akttoken = tn_endtokens then begin
           if scopeinfos[aktscopeinfo].return then begin
            invalidtoken;
           end;
           scopeinfos[aktscopeinfo].hasendtokens:= true;
          end
          else begin
           if akttoken = tn_return then begin
            if scopeinfos[aktscopeinfo].hasendtokens then begin
             invalidtoken;
            end;
            scopeinfos[aktscopeinfo].return:= true;
           end;
          end;
         end; 
        end;
        else begin
         invalidtoken;
        end;
       end;
      end;
     end
     else begin
      lstringgoback(lstr1,lstr2);
      case akttoken of
       tn_keyworddefs: begin
        setlength(wstrar1,0);
        repeat
         bo1:= nextquotedstring(lstr1,str1);
         if caseinsensitive then begin
          str1:= struppercase(str1);
         end;
         if bo1 then begin
          setlength(wstrar1,length(wstrar1)+1);
          wstrar1[high(wstrar1)]:= str1;
         end;
        until not bo1;
        nextword(lstr1,lstr3);
        int2:= findname(stylenames,lstr3);
        for int1:= 0 to high(wstrar1) do begin
         keywordar[high(keywordar)].add(wstrar1[int1],pointer(int2+1));
        end;
       end;
       tn_keywordchars,tn_addkeywordchars: begin
        nextquotedstring(lstr1,str1);
        nextword(lstr1,lstr3);
        if lstr3.len <> 0 then begin
         invalidstring;
        end;
        for int1:= 1 to length(str1) do begin
         include(keywordchars,str1[int1]);
        end;
       end;
       tn_styles: begin
        nextword(lstr1,lstr2);
        addname(stylenames,lstr2,charstyles.count);
        try
         charstyles.add(lstringtostring(lstr1));
        except
         invalidstyle;
         error('Invalid style '''+line+''''+lineinfo);
        end;
       end;
       tn_calltokens,tn_jumptokens: begin
        bo1:= nextquotedstring(lstr1,str1);
        if not bo1 then begin
         invalidstring;
        end;
        nextword(lstr1,lstr3);
        int1:= findname(scopenames,lstr3);
        setlength(scopeinfos[aktscopeinfo].starttokens,
                     length(scopeinfos[aktscopeinfo].starttokens)+1);
        nextword(lstr1,lstr3);
        int2:= findname(stylenames,lstr3);
        with scopeinfos[aktscopeinfo].
         starttokens[high(scopeinfos[aktscopeinfo].starttokens)] do begin
         token:= str1;
         fontinfonr:= int2;
         scopenr:= int1;
         call:= akttoken = tn_calltokens;
        end;
       end;
       tn_endtokens: begin
        int3:= length(scopeinfos[aktscopeinfo].endtokens);
        repeat
         bo1:= nextquotedstring(lstr1,str1);
         if bo1 then begin
          setlength(scopeinfos[aktscopeinfo].endtokens,
                       length(scopeinfos[aktscopeinfo].endtokens)+1);
          scopeinfos[aktscopeinfo].endtokens[
                   high(scopeinfos[aktscopeinfo].endtokens)].token:= str1;
         end
        until not bo1;
        nextword(lstr1,lstr3);
        if lstr3.len <> 0 then begin
         int2:= findname(stylenames,lstr3);
        end
        else begin
         int2:= scopeinfos[aktscopeinfo].fontinfonr;
        end;
        for int1:= int3 to high(scopeinfos[aktscopeinfo].endtokens) do begin
         scopeinfos[aktscopeinfo].endtokens[int1].fontinfonr:= int2;
        end;
       end;
       tn_keywords: begin
        repeat
         nextword(lstr1,lstr3);
         if lstr3.len > 0 then begin
          int1:= findname(keywordnames,lstr3);
          addkeywordrule(int1,aktkeywordfontinfonr);
         end;
        until lstr1.len = 0;
       end;
       else begin
        invalidtoken;
       end;
      end;
     end;
    end;
   until stream.eof;
   updateaktscope;
  finally
   keys.Free;
   scopenames.free;
   stylenames.Free;
  end;
 end;
 syntaxchanged;
end;

function tsyntaxpainter.readdeffile(const afilename: filenamety): integer;
var
 stream1: ttextstream;
begin
 stream1:= ttextstream.create(afilename,fm_read);
 try
  result:= readdeffile(stream1);
 finally
  stream1.free;
 end;
end;

procedure tsyntaxpainter.freedeffile(handle: integer);
begin
 checkarrayindex(fsyntaxdefs,handle);
 clearsyntaxdef(handle);
end;

function tsyntaxpainter.readdeffile(const atext: string): integer;
var
 stream1: ttextstream;
begin
 stream1:= ttextstream.create;
 try
  stream1.writedatastring(atext);
  stream1.position:= 0;
  result:= readdeffile(stream1);
 finally
  stream1.free;
 end;
end;

procedure tsyntaxpainter.syntaxchanged;
var
 int1: integer;
begin
 for int1:= 0 to high(fclients) do begin
  with fclients[int1] do begin
   if assigned(onlinechanged) then begin
    onlinechanged(self,-1);
   end;
  end;
 end;
end;
{
procedure tsyntaxpainter.invalidatesyntax(handle, start,count: integer);
var
 int1,end1,end2: integer;
 refreshinfo: refreshinfoty;
begin
 for int1:= 0 to frefreshlist.count - 1 do begin
  if frefreshlist[int1].handle = handle then begin
   refreshinfo:= frefreshlist[int1];
   if (refreshinfo.astart <= start) then begin
    if refreshinfo.count = maxint then begin
     exit; //schon in arbeit
    end;
    end1:= refreshinfo.astart + refreshinfo.count;
    if end1 >= start then begin //kann erweitert werden
     if count = maxint then begin
      refreshinfo.count:= maxint;
      frefreshlist[int1]:= refreshinfo;
      exit;
     end;
     end2:= start + count;
     if end2 > end1 then begin
      refreshinfo.count:= refreshinfo.count + end2-end1;
      frefreshlist[int1]:= refreshinfo;
      exit;
     end;
    end;
   end;
  end;
 end;
 paintsyntax(handle,start,count,true);
end;
}
procedure tsyntaxpainter.setdefdefs(const Value: tdoublemsestringdatalist);
begin
 fdefdefs.assign(Value);
end;

function tsyntaxpainter.linkdeffile(const sourcefilename: filenamety): integer;
var
 int1,int2: integer;
 strar1: msestringarty;
 stream: ttextstream;
 str1: filenamety;

begin
 result:= -1;
 for int1:= 0 to fdefdefs.count - 1 do begin
  strar1:= nil;
  splitstringquoted(defdefs[int1].a,strar1);
  for int2:= 0 to high(strar1) do begin
   if checkfilename(sourcefilename,strar1[int2],true) then begin
    result:= int1;
    break;
   end;
  end;
  if result >= 0 then begin
   break;
  end;
 end;
 if result >= 0 then begin
  int2:= result;
  result:= -1;
  for int1:= 0 to high(fsyntaxdefs) do begin
   with fsyntaxdefs[int1] do begin
    if (charstyles <> nil) and (defdefsnr = int2) then begin
     result:= int1;
     break;
    end;
   end;
  end;
  if result < 0 then begin
   str1:= fdefdefs[int2].b;
   str1:= filepath(fdefsdir,str1);
   stream:= ttextstream.create(str1,fm_read);
   try
    try
     result:= readdeffile(stream);
    except
     on e: exception do begin
      e.message:= 'tsyntaxpaintermse: file ''' +str1 + ''' ' +e.message;
      raise;
     end;
    end;
     fsyntaxdefs[result].defdefsnr:= int2;
   finally
    stream.Free;
   end;
  end;
 end;
end;

procedure tsyntaxpainter.setdeftext(const avalue: tmsestringdatalist);
begin
 fdeftext.assign(avalue);
end;

procedure tsyntaxpainter.deflistchanged(const sender: tobject);
begin
 if not (csdesigning in componentstate) then begin
  if fdefaultsyntax <> - 1 then begin
   freedeffile(fdefaultsyntax);
  end;
  fdefaultsyntax:= readdeffile(fdeftext.dataastextstream);
 end;
end;

function tsyntaxpainter.getboldchars(index: integer): gridcoordarty;
begin
 checkarrayindex(fclients,index);
 result:= fclients[index].boldchars;
end;

procedure tsyntaxpainter.setboldchars(index: integer;
               const avalue: gridcoordarty);
begin
 checkarrayindex(fclients,index);
 fclients[index].boldchars:= avalue;
end;

function tsyntaxpainter.getcolors(index: integer): syntaxcolorinfoty;
begin
 checkarrayindex(fclients,index);
 result:= fsyntaxdefs[fclients[index].syntaxdefhandle].colors;
end;

end.
