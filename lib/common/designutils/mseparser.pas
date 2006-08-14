{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseparser;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,msetypes,msestrings,msestream,mselist,msehash;

const
 maxincludelevel = 32;

type

 operatorty = (op_unknown);
 tokenkindty = (tk_operator,tk_whitespace,tk_name,tk_number,tk_newline,
                   tk_fileend1,tk_include);

 sourceposty = record
  filenum: integer; //0 -> sourcepos empty
  offset: integer; //byteoffset in file
  filename: nameidty;
  line: integer; //absolute linenr
  pos: gridcoordty;
 end;
 psourceposty = ^sourceposty;

 tsourceposlist = class(trecordlist)
  private
   function getitems(const index: integer): psourceposty;
  protected
//   procedure copyrecord(var item); override;
//   procedure finalizerecord(var item); override;
  public
   constructor create;
   function add(const source: sourceposty): integer;
   property items[const index: integer]: psourceposty read getitems;
 end;

 tokenty = record
  value: lstringty;
  case kind: tokenkindty of
   tk_operator: (op: char);
   tk_newline: (linenr: integer);
   tk_include: (filenr: integer);
 end;
 ptokenty = ^tokenty;
 tokenarty = array of tokenty;
 {
 tokensequencety = record
  token: ptokenty;
  count: integer;
  index: integer;
 end;
 }
 charsetty = set of char;
 tscanner = class
  private
   ftokens: tokenarty;
   ftokencount: integer;
   fsource: ansistring;      //uppercase
   fsourceorig: ansistring;
   fpo: pchar;
   fscto: ptokenty;
   flinenr: integer;
   fescapechar: char;
   fcasesensitive: boolean;
   forigoffset: integer;
   ffilename: filenamety; //for check of recursive includefiles
   ffileid: nameidty;
   fstartline: integer;
   fcount: integer;
   fincludecount: integer;
   procedure updatecase;
   procedure setsource(const Value: ansistring);
   procedure clear;
   procedure scan;
   procedure setcasesensitive(const Value: boolean);
  protected
   procedure scantoken;
   procedure newtoken(akind: tokenkindty);
   procedure endtoken;
  public
   constructor create; overload; virtual;
   constructor create(const afilename: filenamety;
                   const filelist: tmseindexednamelist); overload;
   procedure setfilename(const aname: filenamety;
                   const filelist: tmseindexednamelist);
   property origoffset: integer read forigoffset;
   property filename: filenamety read ffilename;
   property fileid: nameidty read ffileid;
   property startline: integer read fstartline;
   property count: integer read fcount;
   property includecount: integer read fincludecount;
   property source: ansistring read fsource write setsource;
   property escapechar: char read fescapechar write fescapechar;
                  //for newline escape
   property casesensitive: boolean read fcasesensitive write setcasesensitive;
 end;

 tpascalscanner = class(tscanner)
  public
   constructor create; override;
 end;

 tcscanner = class(tscanner)
  public
   constructor create; override;
 end;

const
 identmaxlen = 30;
 {$define nohash}  //first char of ident is hash value
 {$ifdef nohash}
 identbucketcount = 128;
 {$else}
 identbucketcount = 256;
 {$endif}
type
 identstringty = string[identmaxlen+1]; //terminated with #0
 identinfoty = record
  name: identstringty;
  ident: integer;
 end;
 pidentinfoty = ^identinfoty;
 identinfoarty = array of identinfoty;

 valuekindty = (vk_none,vk_integer,vk_real,vk_string);

 tokenidty = record
  scanner: cardinal;
  token: cardinal;
 end;
 tokenidarty = array of tokenidty;

 filestackinfoty = record
  tokenid: tokenidty;
  lineoffset: integer;
 end;
 filestackinfoarty = array of filestackinfoty;

 scannerarty = array of tscanner;

 tparser = class;

 getincludefileeventty = procedure(const sender: tparser;
                  const scanner: tscanner) of object;
 scannerclassty = class of tscanner;

 tparser = class
  private
   fcasesensitive: boolean;
   fscanner: tscanner;
   fownsscanner: boolean;
   fscannernum: cardinal;
   ftokennum: cardinal;
   fidents: array[0..identbucketcount-1] of identinfoarty;
   ffilestack: filestackinfoarty;
   ftokenstack: tokenidarty;
   ftokenstackcount: integer;
   frecursivecomment: boolean;
   flastvalidident: integer;
   fincludefiledirs: filenamearty;
   fongetincludefile: getincludefileeventty;
   feof: boolean;
   ffilelist: tmseindexednamelist;
   function getacttoken: tokenidty;
   procedure setacttokennum(anum: cardinal);
   procedure setacttoken(const atoken: tokenidty);
   procedure enterinclude(anum: cardinal);
   function exitinclude: boolean;
              //false if root
  protected
   fscanners: scannerarty;
   fsyntaxerrorcount: integer;
   fto: ptokenty;
   function getscanner: tscanner;
   procedure setscanner(const Value: tscanner);
   procedure internalerror;
   procedure syntaxerror;
   function getscannerclass: scannerclassty; virtual;

  public
   constructor create(const afilelist: tmseindexednamelist); overload;
   constructor create(const afilelist: tmseindexednamelist; const atext: string); overload;
   destructor destroy; override;

   procedure reset;
   procedure clear; virtual;
   procedure initidents; virtual;
   procedure parse; virtual;
   property token: ptokenty read fto;
   property acttoken: tokenidty read getacttoken write setacttoken;
   procedure nexttoken;
   procedure lasttoken;

   function gettoken: string;
   function getorigtoken: string;   //original case
   function getorigtext(const start: pchar): string;
                    //returns text from start to actual pos
   function getlastorigtext(const start: pchar): string;
                   //returns text from start to lasttoken
   function getident: integer; overload;     //-1 if none
   function getident(var aident: integer): boolean; overload;
                                             //false if none
   function getfirstident: integer; //-1 if none or not first token in line
   function checkident(const ident: integer): boolean; //true if ok
   function checknamenoident: boolean;
   function getname(out value: lstringty): boolean; overload;
   function getorigname(out value: lstringty): boolean; overload;
   function getname: string; overload;           //'' if none
   function getorigname: string; overload;           //'' if none
   function getnamenoident(out value: lstringty): boolean;
   function getorignamenoident(out value: lstringty): boolean;

   function testname(const atoken: tokenty; const aname: string): boolean;
   function testnames(const atoken: tokenty; 
                                     const anames: array of string): integer;

   function getoperator: char;                   //#0 if none
   function testoperator(op: char): boolean;
   function checkoperator(op: char): boolean;
   function checknextoperator(aoperator: char): boolean; //true if ok
   function findoperator(aoperator: char): boolean;   //false if not found
   function getvaluestring(var value: string): valuekindty; virtual;
   function getnamelist: lstringarty; //names separated by ','
   function getorignamelist: lstringarty; //names separated by ','

   function skipcomment: boolean; virtual; //does not skip whitespace
   function checknewline: boolean;
   function nextline: boolean;       //false if fileend
   function skipwhitespace: boolean; //and comments, false if no whitespaces
   function skipwhitespaceonly: boolean;

   property eof: boolean read feof;
   function isfirstnonwhitetoken: boolean;
   {$ifndef nohash}
   function hashident(name: pchar; len: integer): byte; overload;
   function hashident(const name: string): byte; overload;
   {$endif}

   procedure mark; //set mark in tokenstak
   procedure back; //restore tokenstack to last mark
   procedure pop;  //remove mark from tokenstack
   procedure setidents(idents: array of string);

   function sourceoffset: integer;
   function sourcepos: sourceposty;
   function nextsourcepos: sourceposty; //skips whitespace
   function nexttokenornewlinepos: sourceposty;
   function getsourcepos(const atoken: tokenidty): sourceposty;
               //returns row and col in source
   function lasttokenoffset: integer;
   function lasttokenpos: sourceposty;

   function addscanner(const ascanner: tscanner): integer;
   function dogetincludefile(const afilename: filenamety;
              const astatementstart,astatementend: sourceposty): tscanner; virtual;
   function includefile(const filename: filenamety;
              const statementstart,statementend: sourceposty): integer;
     //-1 on error, scanner index otherwise

   property scanner: tscanner read getscanner write setscanner;
   property recursivecomment: boolean read frecursivecomment 
                          write frecursivecomment default false;
   property ongetincludefile: getincludefileeventty read fongetincludefile 
                          write fongetincludefile;
   property includefiledirs: filenamearty read fincludefiledirs 
                          write fincludefiledirs;
 end;

type
 pascalidentty = (id_invalid = -1,
  id_and=0,id_array,id_as,id_asm,id_begin,id_case,id_class,id_const,id_constructor,
  id_destructor,id_dispinterface,id_div,id_do,id_downto,id_else,id_end,id_except,
  id_exports,id_file,id_finalization,id_finally,id_for,id_function,id_goto,id_if,
  id_implementation,id_in,id_initialization,id_inline,id_interface,
  id_is,id_label,id_library,id_mod,id_nil,id_not,id_object,id_of,id_or,id_out,
  id_overload,
  id_packed,id_procedure,id_program,id_property,id_raise,id_record,id_repeat,
  id_resourcestring,id_set,id_shl,id_shr,id_then,id_threadvar,id_to,
  id_try,id_type,id_unit,id_until,id_uses,id_var,id_while,id_with,id_xor,

  id_abstract,id_inherited,id_override,id_reintroduce,id_virtual,
  id_private,id_protected,id_public,id_published,id_automated,
  
  id_read,id_write,id_stored,id_default,id_nodefault);
  
 const
 firstpascalident = id_and;
 lastpascalnormalident = integer(id_xor);
 lastpascalclassident = integer(id_automated);
 lastpascalpropertyident = integer(id_nodefault);
 lastpascalident = id_nodefault;

 pascalidents: array[firstpascalident..lastpascalident] of string = (
  'and','array','as','asm','begin','case','class','const','constructor',
  'destructor','dispinterface','div','do','downto','else','end','except',
  'exports','file','finalization','finally','for','function','goto','if',
  'implementation','in','initialization','inline','interface',
  'is','label','library','mod','nil','not','object','of','or','out',
  'overload',
  'packed','procedure','program','property','raise','record','repeat',
  'resourcestring','set','shl','shr','then','threadvar','to',
  'try','type','unit','until','uses','var','while','with','xor',

  'abstract','inherited','override','reintroduce','virtual',
  'private','protected','public','published','automated',
  
  'read','write','stored','default','nodefault');

type
 tdefineslist = class(thashedstrings);
 defstatety = (def_none,def_skip);
 
 tpascalparser = class(tparser)
  private
   fdefines: tdefineslist;
   fdefstate: defstatety;
   fdefstates: integerarty;
   fdefstatecount: integer;
  protected
   function getscannerclass: scannerclassty; override;

  public
   constructor create(const afilelist: tmseindexednamelist); overload;
   destructor destroy; override;
   procedure initidents; override;
   function getvaluestring(var value: string): valuekindty; override;
   function skipcomment: boolean; override; //does not skip whitespace
//   procedure decodecompilerswitch(const tokens: tokensequencety);
   procedure parsecompilerswitch;
   function getpascalstring(var value: string): boolean; //true if ok
   function concatpascalstring(var value: string): boolean; 
         //concats <pascalstring>+<pascalstring>... true if ok
   function concatpascalname(var value: string): boolean;
               //returns <name>.<name>..., true if ok

   function getclassident: pascalidentty;      //-1 if none
   function checkclassident(const ident: pascalidentty): boolean; //true if ok
   function getpropertyident: pascalidentty;      //-1 if none
   function checkpropertyident(const ident: pascalidentty): boolean; //true if ok
 end;

 tcparser = class(tparser)
  protected
   function getscannerclass: scannerclassty; override;
  public
   constructor create(const afilelist: tmseindexednamelist);
   procedure initidents; override;
   function getvaluestring(var value: string): valuekindty; override;
   function skipcomment: boolean; override; //does not skip whitespace
   function getcstring(var value: string): boolean;
 end;

 constinfoty = record
  name: string;
  valuetype: tvaluetype;
  value: msestring;
  resource: boolean;
  offset,len: integer;
 end;
 pconstinfoty = ^constinfoty;
 constinfoarty = array of constinfoty;

 tconstparser = class(tpascalparser)
  public
   function getconsts(var ar: constinfoarty): string;
    //returns unitname
 end;

 tfpcresstringparser = class(tpascalparser)
  public
   procedure getconsts(var ar: constinfoarty);
 end;

 tresstringlistparser = class(tcparser)
  public
   constructor create(const afilelist: tmseindexednamelist);
   procedure getconsts(var ar: constinfoarty);
 end;
 

function isemptysourcepos(const value: sourceposty): boolean;
function issamesourcepos(const a,b: sourceposty): boolean;
function emptysourcepos: sourceposty;

implementation
uses
 sysutils,mseformatstr,msedatalist,typinfo,msebits,msewidgets,
 msefileutils;

type
 treader1 = class(treader);
 twriter1 = class(twriter);

function isemptysourcepos(const value: sourceposty): boolean;
begin
 result:= value.filenum = 0;
end;

function issamesourcepos(const a,b: sourceposty): boolean;
begin
 result:= (a.filenum <> 0) and (a.filenum = b.filenum) and
                      (a.pos.col = b.pos.col) and (a.pos.row = b.pos.row);
end;

function emptysourcepos: sourceposty;
begin
 finalize(result);
 fillchar(result,sizeof(sourceposty),0);
end;

{ tsourceposlist }

constructor tsourceposlist.create;
begin
 inherited create(sizeof(sourceposty){,[rels_needsfinalize,rels_needscopy]});
end;

function tsourceposlist.add(const source: sourceposty): integer;
begin
 result:= inherited add(source);
end;
{
procedure tsourceposlist.copyrecord(var item);
begin
 with sourceposty(item) do begin
  stringaddref(filename);
 end;
end;

procedure tsourceposlist.finalizerecord(var item);
begin
 finalize(sourceposty(item));
end;
}
function tsourceposlist.getitems(const index: integer): psourceposty;
begin
 result:= getitempo(index);
end;

{ tscanner }

constructor tscanner.create;
begin
 inherited;
end;

constructor tscanner.create(const afilename: filenamety;
             const filelist: tmseindexednamelist);
var
 stream: ttextstream;
begin
 create;
 setfilename(afilename,filelist);
 stream:= ttextstream.create(filename);
 try
  source:= stream.readdatastring;
 finally
  stream.Free;
 end;
end;

procedure tscanner.setfilename(const aname: filenamety;
         const filelist: tmseindexednamelist);
begin
 ffilename:= aname;
 ffileid:= filelist.add(aname);
end;

procedure tscanner.clear;
begin
 ftokencount:= 0;
 ftokens:= nil;
 flinenr:= 0;
end;

procedure tscanner.newtoken(akind: tokenkindty);
begin
 if ftokencount >= high(ftokens) then begin
  setlength(ftokens,(3*length(ftokens)) div 2 + 256);
 end;
 fscto:= @ftokens[ftokencount];
 inc(ftokencount);
 fscto^.kind:= akind;
 fscto^.value.po:= fpo;
 case akind of
  tk_newline: begin
   fscto^.linenr:= flinenr;
   inc(flinenr);
  end;
  tk_operator: begin
   fscto^.op:= fpo^;
  end;
 end;
end;

procedure tscanner.endtoken;
begin
 fscto^.value.len:= fpo - fscto^.value.po;
end;

procedure tscanner.scantoken;
var
 ch1: char;
begin
 ch1:= upcase(fpo^);
 if (ch1 = ' ') or (ch1 = c_tab) then begin
  newtoken(tk_whitespace);
  repeat
   inc(fpo);
  until not ((fpo^ = ' ') or (fpo^ = c_tab));
 end
 else begin
  if (ch1 >= 'A') and (ch1 <= 'Z') or (ch1 = '_') then begin
   newtoken(tk_name);
   repeat
    inc(fpo);
    ch1:= upcase(fpo^);
   until not ((ch1 >= 'A') and (ch1 <= 'Z') or (ch1 = '_') or
                (ch1 >= '0') and (ch1 <= '9'));
  end
  else begin
   if (ch1 >= '0') and (ch1 <= '9') then begin
    newtoken(tk_number);
    repeat
     inc(fpo);
    until (fpo^ < '0') or (fpo^ > '9');
   end
   else begin
    if ch1 = c_return then begin
     newtoken(tk_newline);
     inc(fpo);
     if fpo^ = c_linefeed then begin
      inc(fpo);
     end;
    end
    else begin
     if ch1 = c_linefeed then begin
      newtoken(tk_newline);
      inc(fpo);
      if fpo^ = c_return then begin
       inc(fpo);
      end;
     end
     else begin
      newtoken(tk_operator);
      inc(fpo);
     end;
    end;
   end;
  end;
 end;
end;

procedure tscanner.scan;
begin
 clear;
 fpo:= pointer(fsource);
 if fpo <> nil then begin
  while fpo^ <> #0 do begin
   scantoken;
   endtoken;
   if fescapechar <> #0 then begin
    if (ftokens[ftokencount-1].kind = tk_newline) and
        (ftokencount > 1) and (ftokens[ftokencount-2].kind = tk_operator) and
        (ftokens[ftokencount-2].op = fescapechar) then begin
     dec(ftokencount,2);
     if ftokencount > 0 then begin
      with ftokens[ftokencount-1].value do begin
       len:= len + ftokens[ftokencount].value.len +
                    ftokens[ftokencount+1].value.len;
      end;
     end;
    end;
   end;
  end;
 end;
 newtoken(tk_fileend1);
end;

procedure tscanner.updatecase;
begin
 if fcasesensitive then begin
  fsource:= fsourceorig;
  forigoffset:= 0;
 end
 else begin
  fsource:= uppercase(fsourceorig);
  forigoffset:= pchar(fsourceorig) - pchar(fsource);
 end;
end;

procedure tscanner.setsource(const Value: ansistring);
begin
 fsourceorig:= Value;
 updatecase;
 scan;
end;

procedure tscanner.setcasesensitive(const Value: boolean);
begin
 if fcasesensitive <> value then begin
  fcasesensitive:= Value;
  updatecase;
 end;
end;

{ tpascalscanner }

constructor tpascalscanner.create;
begin
 inherited;
end;

{ tcscanner }

constructor tcscanner.create;
begin
 inherited;
 fcasesensitive:= true;
 fescapechar:= '\';
end;

{ tparser }

constructor tparser.create(const afilelist: tmseindexednamelist);
begin
 ffilelist:= afilelist;
 flastvalidident:= bigint;
 setlength(fincludefiledirs,1);
 fincludefiledirs[0]:= './';
end;

constructor tparser.create(const afilelist: tmseindexednamelist;
                 const atext: string);
var
 ascanner: tscanner;
begin
 create(afilelist);
 fownsscanner:= true;
 ascanner:= getscannerclass.create;
 ascanner.source:= atext;
 scanner:= ascanner;
end;

destructor tparser.destroy;
begin
 reset;
 inherited;
 if fownsscanner then begin
  fscanner.Free;
 end;
end;

procedure tparser.reset;
var
 int1: integer;
begin
 for int1:= 1 to high(fscanners) do begin
  fscanners[int1].Free;
 end;
 fscanners:= nil;
end;

procedure tparser.clear;
begin
 feof:= false;
 ftokennum:= 0;
 ftokenstack:= nil;
 ffilestack:= nil;
 ftokenstackcount:= 0;
 fscannernum:= 0;
 if fscanners <> nil then begin
  fscanner:= fscanners[0];
  fto:= ptokenty(pointer(fscanner.ftokens));
  setlength(ffilestack,1);
 end
 else begin
  fscanner:= nil;
  fto:= nil;
 end;
 fsyntaxerrorcount:= 0;
end;

function tparser.addscanner(const ascanner: tscanner): integer;
begin
 result:= length(fscanners);
 if result = 0 then begin
  fscanner:= ascanner;
 end
 else begin
  ascanner.fstartline:= sourcepos.line;
 end;
 setlength(fscanners,result+1);
 fscanners[result]:= ascanner;
end;

function tparser.dogetincludefile(const afilename: filenamety;
                const astatementstart,astatementend: sourceposty): tscanner;
begin
 result:= tscanner(fscanners[0].newinstance);
 if assigned(fongetincludefile) then begin
  result.create;
  result.setfilename(afilename,ffilelist);
  fongetincludefile(self,result);
 end
 else begin
  result.Create(afilename,ffilelist);
 end;
end;

function tparser.includefile(const filename: filenamety;
                const statementstart,statementend: sourceposty): integer;
var
 str1: filenamety;
 ascanner: tscanner;
 int1: integer;
begin
 result:= -1;
 if high(ffilestack) < maxincludelevel then begin
  if findfile(filename,fincludefiledirs,str1) then begin
   for int1:= 0 to high(ffilestack) do begin
    if issamefilename(str1,fscanners[ffilestack[int1].tokenid.scanner].ffilename) then begin
         //recursive
     syntaxerror;
     exit;
    end;
   end;
   ascanner:= dogetincludefile(str1,statementstart,statementend);
   try
    result:= addscanner(ascanner);
   except
    result:= -1;
    ascanner.Free;
   end;
  end;
 end;
end;

{$ifndef nohash}

function tparser.hashident(name: pchar; len: integer): byte;
var
 sumb: byte;
 xorb: byte;
 by1: byte;
begin
 sumb:= 0;
 xorb:= 0;
// if fcasesensitive then begin
  while len > 0 do begin
   sumb:= sumb + byte(name^);
   xorb:= xorb xor byte(name^);
   inc(name);
   dec(len);
  end;
// end
 {
 else begin
  while len > 0 do begin
   by1:= byte(upcase(name^));
   sumb:= sumb + by1;
   xorb:= xorb xor by1;
   inc(name);
   dec(len);
  end;
 end;
 }
 result:= sumb xor xorb;
end;

function tparser.hashident(const name: string): byte;
begin
 result:= hashident(pchar(name),length(name));
end;

{$endif nohash}

procedure tparser.setidents(idents: array of string);
var
 int1: integer;
 str1: string;
 by1: byte;
begin
 for int1:= 0 to high(idents) do begin
  str1:= copy(idents[int1],1,identmaxlen);
  if not fcasesensitive then begin
   str1:= uppercase(str1);
  end;
  {$ifdef nohash}
  assert((length(str1) > 0) and (ord(str1[1]) < 128),
       'Invalid ident '''+str1+'''');
  by1:= byte(str1[1]);
  str1:= copy(str1,2,bigint);
  {$else}
  assert(length(str1) > 0,'Empty ident');
  by1:= hashident(str1);
  {$endif}
  setlength(fidents[by1],high(fidents[by1])+2);
  with fidents[by1][high(fidents[by1])] do begin
//   if fcasesensitive then begin
    name:= str1;
//   end
//   else begin
//    name:= uppercase(str1);
//   end;
   name[length(str1)+1]:= #0;
   ident:= int1;
  end;
 end;
end;

function tparser.sourceoffset: integer;
begin
 result:= fto^.value.po - pchar(fscanner.fsource);
end;

function tparser.getsourcepos(const atoken: tokenidty): sourceposty;
    //returns row and col in source
var
 int1: integer;
begin
 result.filenum:= fscannernum + 1;
 result.filename:= fscanners[fscannernum].ffileid;
 with result.pos,fscanner do begin
  row:= 0;
  col:= ftokens[atoken.token].value.po -
          pchar(fsource);
  result.offset:= col; //byteoffset in file
  for int1:= atoken.token-1 downto 0 do begin
   with ftokens[int1] do begin
    if (kind = tk_newline) then begin
     row:= linenr + 1;
     col:= col - (ftokens[int1+1].value.po -
             pchar(fsource));
     break;
    end;
   end;
  end;
 end;
 result.line:= result.pos.row;
 if high(ffilestack) >= 0 then begin
  inc(result.line,ffilestack[high(ffilestack)].lineoffset);
 end;
end;

function tparser.sourcepos: sourceposty;
var
 id: tokenidty;
begin
 id.scanner:= fscannernum;
 id.token:= ftokennum;
 result:= getsourcepos(id);
end;

function tparser.nextsourcepos: sourceposty; //skips whitespace
begin
 skipwhitespace;
 result:= sourcepos;
end;

function tparser.nexttokenornewlinepos: sourceposty;
begin
 skipwhitespaceonly;
 if fto^.kind = tk_newline then begin
  nexttoken;
 end;
 result:= sourcepos;
end;

function tparser.lasttokenoffset: integer;
var
 int1: integer;
begin
 result:= 0;
 with fscanner do begin
  for int1:= ftokennum - 2 downto 0 do begin
   if ftokens[int1].kind <> tk_whitespace then begin
    result:= ftokens[int1+1].value.po - pchar(fsource);
    break;
   end;
  end;
 end;
end;

function tparser.lasttokenpos: sourceposty;
begin
 result:= sourcepos;
 result.pos.col:= result.pos.col - sourceoffset + lasttokenoffset;
end;

function tparser.getacttoken: tokenidty;
begin
 result.scanner:= fscannernum;
 result.token:= ftokennum;
end;

procedure tparser.setacttokennum(anum: cardinal);
begin
 with fscanner do begin
  if anum <= cardinal(high(ftokens)) then begin
   ftokennum:= anum;
   fto:= @ftokens[ftokennum];
  end
  else begin
   internalerror;
  end;
 end;
end;

procedure tparser.setacttoken(const atoken: tokenidty);
var
 int1,int2: integer;
begin
 with atoken do begin
  if scanner > cardinal(high(fscanners)) then begin
   internalerror;
  end;
  if ffilestack <> nil then begin
   int2:= high(ffilestack);
   if ffilestack[int2].tokenid.scanner <> scanner then begin
    for int1:= int2 downto 0 do begin
     if ffilestack[int2].tokenid.scanner = scanner then begin
      setlength(ffilestack,int2+1);
     end;
    end;
   end;
  end;
  fscannernum:= scanner;
  fscanner:= fscanners[scanner];
  feof:= false;
  with fscanner do begin
   if token <= cardinal(high(ftokens)) then begin
    ftokennum:= token;
    fto:= @ftokens[ftokennum];
   end
   else begin
    internalerror;
   end;
  end;
 end;
end;

procedure tparser.enterinclude(anum: cardinal);
var
 id1: tokenidty;
 int1: integer;
 aline: integer;
begin
 if anum > cardinal(high(fscanners)) then begin
  internalerror;
 end;
 inc(fscanner.fincludecount);
 aline:= sourcepos.line;
 int1:= high(ffilestack);
 setlength(ffilestack,int1+2);
 ffilestack[int1+1].tokenid:= acttoken;
 ffilestack[int1+1].lineoffset:= aline;
 id1.scanner:= anum;
 id1.token:= 0;
 setacttoken(id1);
end;

function tparser.exitinclude: boolean;
              //false if root
var
 int1,int2: integer;
 acount: integer;
begin
 int1:= sourcepos.line;
 if high(ffilestack) > 0 then begin
  int1:= int1 - fscanner.fstartline;
  if fscanner.fcount <= 0 then begin
   inc(fscanner.fcount,int1);
  end;
  acount:= fscanner.fcount;
  result:= true;
  setacttoken(ffilestack[high(ffilestack)].tokenid);
  if ffilestack <> nil then begin
   for int2:= high(ffilestack) downto 1 do begin
    with fscanners[ffilestack[int2].tokenid.scanner] do begin
     if fcount <= 0 then begin
      dec(fcount,acount);
     end;
    end;
   end;
   setlength(ffilestack,high(ffilestack));
   if ffilestack <> nil then begin
    inc(ffilestack[high(ffilestack)].lineoffset,int1);
   end;
  end;
 end
 else begin
  result:= false;
  feof:= true;
  if fscanners[0].fcount <= 0 then begin
   inc(fscanners[0].fcount,int1);
  end;
 end;
end;

procedure tparser.nexttoken;
begin
 if fto^.kind <> tk_fileend1 then begin
  inc(ftokennum);
  fto:= @fscanner.ftokens[ftokennum];
 end
 else begin
  repeat
  until (fto^.kind <> tk_fileend1) or not exitinclude;
 end;
end;

procedure tparser.lasttoken;
begin
 if ftokennum > 0 then begin
  dec(ftokennum);
  fto:= @fscanner.ftokens[ftokennum];
 end
 else begin
  if not exitinclude then begin
   internalerror;
  end;
 end;
end;

procedure tparser.mark;
begin
 if ftokenstackcount >= high(ftokenstack) then begin
  setlength(ftokenstack,high(ftokenstack)+33);
 end;
 ftokenstack[ftokenstackcount].token:= ftokennum;
 ftokenstack[ftokenstackcount].scanner:= fscannernum;
 inc(ftokenstackcount);
end;

procedure tparser.back;
begin
 if ftokenstackcount = 0 then begin
  internalerror;
 end;
 dec(ftokenstackcount);
 setacttoken(ftokenstack[ftokenstackcount]);
end;

procedure tparser.pop;
begin
 if ftokenstackcount = 0 then begin
  internalerror;
 end;
 dec(ftokenstackcount);
end;

function tparser.gettoken: string;
begin
 setstring(result,fto^.value.po,fto^.value.len);
 nexttoken;
end;

function tparser.getorigtoken: string;
begin
 setstring(result,fto^.value.po+fscanner.forigoffset,fto^.value.len);
 nexttoken;
end;

function tparser.getorigtext(const start: pchar): string;
                    //returns text from start to actual pos
begin
 if fto^.value.po - start > 0 then begin
  setstring(result,start+fscanner.forigoffset,fto^.value.po - start);
 end
 else begin
  result:= '';
 end;
end;

function tparser.getlastorigtext(const start: pchar): string;
                    //returns text from start to actual pos
begin
 lasttoken;
 if fto^.value.po - start > 0 then begin
  setstring(result,start+fscanner.forigoffset,fto^.value.po - start);
 end
 else begin
  result:= '';
 end;
 nexttoken;
end;

function tparser.checknextoperator(aoperator: char): boolean;
begin
 with fscanner.ftokens[ftokennum+1] do begin
  if (kind = tk_operator) and (op = aoperator) then begin
   result:= true;
   nexttoken;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tparser.findoperator(aoperator: char): boolean;
begin
 result:= false;
 while (fto^.kind <> tk_fileend1) do begin
  if (fto^.kind = tk_operator) and (fto^.op = aoperator) then begin
   nexttoken;
   result:= true;
   break;
  end;
  nexttoken;
 end;
end;

function tparser.isfirstnonwhitetoken: boolean;
var
 po1,po2: ptokenty;
begin
 result:= true;
 po1:= fto;
 po2:= @fscanner.ftokens[0];
 while po1 <> po2 do begin
  dec(po1);
  if po1^.kind = tk_newline then begin
   break;
  end
  else begin
   if po1^.kind <> tk_whitespace then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tparser.skipwhitespace: boolean;
begin
 result:= false;
 repeat
  while (fto^.kind = tk_whitespace) or (fto^.kind = tk_newline) do begin
   result:= true;
   nexttoken;
  end;
  while skipcomment do begin
   result:= true;
   if fto^.kind = tk_fileend1 then begin
    break;
   end;
  end;
 until not ((fto^.kind = tk_whitespace) or (fto^.kind = tk_newline));
end;

function tparser.skipwhitespaceonly: boolean;
begin
 result:= false;
 while (fto^.kind = tk_whitespace) do begin
  result:= true;
  nexttoken;
 end;
end;

function tparser.getident: integer;
var
 by1: byte;
 int1,alen: integer;
 po1,po2: pchar;
 po3: pidentinfoty;
begin
 skipwhitespace;
 result:= -1;
 with fto^ do begin
  if kind = tk_name then begin
   {$ifdef nohash}
   by1:= byte(value.po^);
   if by1 >= 128 then begin
    exit;
   end;
   alen:= value.len-1;
   {$else}
   by1:= hashident(value.po,value.len);
   alen:= value.len;
   {$endif}
   for int1:= 0 to high(fidents[by1]) do begin
    po3:= @fidents[by1][int1];
    if length(po3^.name) = alen then begin
     {$ifdef nohash}
     po1:= value.po + 1; //source
     {$else}
     po1:= value.po; //source
     {$endif}
     po2:= @po3^.name[1];
     while (po2^ <> #0) and (po1^ = po2^) do begin
      inc(po1);
      inc(po2);
     end;
     if po2^= #0 then begin
      result:= po3^.ident;
      break;
     end;
    end;
   end;
  end;
 end;
 if result > flastvalidident then begin
  result:= -1;
 end;
 if result >= 0 then begin
  nexttoken;
 end;
end;

function tparser.getident(var aident: integer): boolean;
                                             //false if none
begin
 aident:= getident();
 result:= aident >= 0;
end;

function tparser.getfirstident: integer; //-1 if none or not first token in line
begin
 if (ftokennum = 0) or (fscanner.ftokens[ftokennum-1].kind = tk_newline) then begin
  result:= getident;
 end
 else begin
  skipwhitespace;
  result:= -1;
 end;
end;

function tparser.testname(const atoken: tokenty; const aname: string): boolean;
begin
 result:= (atoken.kind = tk_name) and (lstringcomp(atoken.value,aname) = 0);
end;

function tparser.testnames(const atoken: tokenty;
                                          const anames: array of string): integer;
var
 int1: integer;
begin
 result:= -1;
 if atoken.kind = tk_name then begin
  for int1:= 0 to high(anames) do begin
   if (lstringcomp(atoken.value,anames[int1]) = 0) then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

function tparser.checkident(const ident: integer): boolean;
var
 int1: integer;
begin
 int1:= getident;
 result:= ident = int1;
 if not result and (int1 >= 0) then begin
  lasttoken;
 end;
end;

function tparser.checknamenoident: boolean;
begin
 result:= (getident = -1) and (fto^.kind = tk_name);
 if result then begin
  nexttoken;
 end;
end;

function tparser.getname(out value: lstringty): boolean;
begin
 skipwhitespace;
 result:= fto^.kind = tk_name;
 if result then begin
  value:= fto^.value;
  nexttoken;
 end
 else begin
  value:= emptylstring;
 end;
end;

function tparser.getname: string;
var
 value: lstringty;
begin
 getname(value);
 setstring(result,value.po,value.len);
end;

function tparser.getorigname(out value: lstringty): boolean;
begin
 skipwhitespace;
 result:= fto^.kind = tk_name;
 if result then begin
  value:= fto^.value;
  inc(value.po,fscanner.forigoffset);
  nexttoken;
 end
 else begin
  value:= emptylstring;
 end;
end;

function tparser.getorigname: string;
var
 value: lstringty;
begin
 getorigname(value);
 setstring(result,value.po,value.len);
end;

function tparser.getnamenoident(out value: lstringty): boolean;
begin
 if getident < 0 then begin
  result:= getname(value);
 end
 else begin
  value:= emptylstring;
  result:= false;
  lasttoken;
 end;
end;

function tparser.getorignamenoident(out value: lstringty): boolean;
begin
 if getident < 0 then begin
  result:= getorigname(value);
 end
 else begin
  value:= emptylstring;
  result:= false;
  lasttoken;
 end;
end;
{
function tparser.getorigstring(maxcount: integer = bigint): string;
begin
 result:= '';
 while (maxcount > 0) and not(fto^.kind in [tk_fileend,tk_newline,tk_whitespace]) do begin
  result:= result + getorigtoken;
  dec(maxcount);
 end;
end;
}
function tparser.getoperator: char;
begin
 skipwhitespace;
 if fto^.kind = tk_operator then begin
  result:= fto^.op;
  nexttoken;
 end
 else begin
  result:= #0;
 end;
end;

function tparser.testoperator(op: char): boolean;
begin
 skipwhitespace;
 if fto^.kind = tk_operator then begin
  result:= fto^.op = op;
 end
 else begin
  result:= false;
 end;
end;

function tparser.checkoperator(op: char): boolean;
var
 ch1: char;
begin
 ch1:= getoperator;
 result:= op = ch1;
 if not result and (ch1 <> #0) then begin
  lasttoken;
 end;
end;

function tparser.skipcomment: boolean; //does not skip whitespace
begin
 result:= false; //dummy
end;

function tparser.checknewline: boolean;
begin
 skipwhitespaceonly;
 if fto^.kind = tk_newline then begin
  result:= true;
  nexttoken;
 end
 else begin
  result:= false;
 end;
end;

function tparser.nextline: boolean; //false if fileend
var
 po1: ptokenty;
begin
// result:= false;
 po1:= fto;
 while (fto^.kind <> tk_fileend1) and (fto^.kind <> tk_newline) do begin
  inc(fto);
 end;
 if fto^.kind <> tk_fileend1 then begin
  inc(fto);
  result:= true;
 end
 else begin
  result:= exitinclude;
  exit;
 end;
 inc(ftokennum,(pchar(fto)-pchar(po1)) div sizeof(tokenty));
end;

function tparser.getvaluestring(var value: string): valuekindty;
var
 str1: string;
begin
 skipwhitespace;
 result:= vk_none;
 case fto^.kind of
  tk_number: begin
   mark;
   result:= vk_integer;
   value:= gettoken;
   if (fto^.kind = tk_operator) and (fto^.op = '.') then begin
    result:= vk_real;
    value:= value + '.';
    nexttoken;
    if fto^.kind = tk_number then begin
     str1:= str1 + gettoken;
    end
   end;
   if (fto^.kind = tk_name) and (fto^.value.len = 1) and
                 ((fto^.value.po^ = 'e') or (fto^.value.po^ = 'E')) then begin
    result:= vk_real;
    nexttoken;
    if (fto^.kind = tk_operator) and
        ((fto^.op = '+') or (fto^.op = '-')) then begin
     value:= value+getoperator;
    end;
    if (fto^.kind = tk_number) then begin
     value:= value + gettoken;
    end
    else begin
     result:= vk_none;
    end;
   end;
   if result <> vk_none then begin
    pop;
   end
   else begin
    back;
   end;
  end;
 end;
end;

function tparser.getnamelist: lstringarty; //names separated by ','
var
 count: integer;
begin
 count:= 0;
 setlength(result,1);
 while not eof do begin
  if not getname(result[count]) then begin
   break;
  end;
  inc(count);
  if not checkoperator(',') and (fto^.kind = tk_operator) then begin
   break;
  end;
  if high(result) < count then begin
   setlength(result,high(result)+33);
  end;
 end;
 setlength(result,count);
end;

function tparser.getorignamelist: lstringarty; //names separated by ','
var
 count: integer;
begin
 count:= 0;
 setlength(result,1);
 while not eof do begin
  if not getorigname(result[count]) then begin
   break;
  end;
  inc(count);
  if not checkoperator(',') and (fto^.kind = tk_operator) then begin
   break;
  end;
  if high(result) < count then begin
   setlength(result,high(result)+33);
  end;
 end;
 setlength(result,count);
end;

procedure tparser.internalerror;
begin
 raise exception.Create('Internal error');
end;

procedure tparser.syntaxerror;
begin
 inc(fsyntaxerrorcount)
end;

function tparser.getscannerclass: scannerclassty;
begin
 result:= tscanner;
end;

{
procedure tparser.setcasesensitive(const Value: boolean);
begin
 fcasesensitive := Value;
end;
}
function tparser.getscanner: tscanner;
begin
 if fscanners = nil then begin
  result:= nil;
 end
 else begin
  result:= fscanners[0];
 end;
end;

procedure tparser.setscanner(const Value: tscanner);
begin
 value.casesensitive:= fcasesensitive;
 reset;
 addscanner(value);
 clear;
 parse;
end;

procedure tparser.parse;
begin
 initidents;
end;

procedure tparser.initidents;
begin
 setidents([]);
end;
{
function tparser.noteof: boolean;
begin
 result:= not ((fto^.kind = tk_fileend1) and  (ffilestack = nil));
end;
}
{ tpascalparser }

type
 cskwordty = (cskw_i,cskw_include,cskw_define,cskw_undef,cskw_ifdef,cskw_ifndef,
              cskw_else,cskw_endif);
const
 cskwords: array[cskwordty] of string = 
                  ('I','INCLUDE','DEFINE','UNDEF','IFDEF','IFNDEF',
                   'ELSE','ENDIF');
                  
procedure tpascalparser.parsecompilerswitch;

 procedure skiprest;
 begin
  while (fto^.kind <> tk_fileend1) and
     not((fto^.kind = tk_operator) and (fto^.op = '}')) do begin
   nexttoken;
  end;
  nexttoken; //skip '}'
 end;
 
 procedure skipskip;
 begin
  repeat
   if not skipcomment then begin
    nexttoken;
   end;
  until (fto^.kind = tk_fileend1) or (fdefstate <> def_skip);
 end;
 
var
 int1,int2: integer;
 str1: string;
 filename: filenamety;
 anum: cardinal;
 startpos,endpos: sourceposty;
 lstr1: lstringty;
begin
 anum:= ftokennum;
 int1:= testnames(fto^,cskwords);
 if int1 >= 0 then begin
  if int1 > 1 then begin
   nexttoken;
  end;
  case cskwordty(int1) of
   cskw_ifdef,cskw_ifndef: begin
    additem(fdefstates,integer(fdefstate),fdefstatecount);
    if fdefstate <> def_skip then begin
     if not (getname(lstr1) and 
                       ((fdefines.find(lstr1) <> nil) xor 
                        (cskwordty(int1) = cskw_ifndef))) then begin
      fdefstate:= def_skip;
      skiprest;
      skipskip;
     end
     else begin
      skiprest;
     end;
    end
    else begin
     skiprest;
    end;
   end;
   cskw_else: begin
    skiprest;
    if fdefstate = def_skip then begin
     if (fdefstatecount = 0) or 
             (defstatety(fdefstates[fdefstatecount-1]) <> def_skip) then begin
      fdefstate:= def_none;
     end;
    end
    else begin
     fdefstate:= def_skip;
     skipskip;
    end;
   end;
   cskw_endif: begin
    if fdefstatecount > 0 then begin
     dec(fdefstatecount);
     fdefstate:= defstatety(fdefstates[fdefstatecount]);
    end;
    skiprest;
   end;
   else begin
    if fdefstate <> def_skip then begin 
     case cskwordty(int1) of
      cskw_i,cskw_include: begin
       startpos:= sourcepos;
       nexttoken;
       if checkoperator('''') then begin
        lasttoken;
        if getpascalstring(str1) then begin
         try
          filename:= pascalstringtostring(str1);
         except
         end;
        end;
       end
       else begin
        str1:= '';
        skipwhitespaceonly;
        while not(fto^.kind in [tk_fileend1,tk_newline,tk_whitespace]) and
           not((fto^.kind = tk_operator) and (fto^.op = '}')) do begin
         str1:= str1 + getorigtoken;
        end;
        filename:= str1;
       end;
       if findoperator('}') then begin
        endpos:= lasttokenpos;
       end
       else begin
        endpos:= sourcepos;
       end;
       if filename <> '' then begin
        int2:= includefile(filename,startpos,sourcepos);
        if int2 >= 0 then begin
         for int1:= anum + 1 to ftokennum - 1 do begin
          fscanner.ftokens[int1].kind:= tk_whitespace;
         end;
         with fscanner.ftokens[anum] do begin
          kind:= tk_include;
          filenr:= int2;
         end;
         enterinclude(int2);
        end;
       end;
      end;
      cskw_define: begin
       str1:= getname;
       if str1 <> '' then begin
        fdefines.add(str1);
       end;
      end;
      cskw_undef: begin
       if getname(lstr1) then begin
        fdefines.delete(lstr1);
       end;
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  skiprest;
 end;
end;

function tpascalparser.skipcomment: boolean; //does not skip whitespace
var
 int1: integer;
 first: boolean;
begin
 result:= false;
 if (fto^.kind = tk_operator) and (fto^.op = '/') and checknextoperator('/') then begin
  result:= true;
  while not ((fto^.kind = tk_newline) or (fto^.kind = tk_fileend1)) do begin
   nexttoken;
  end;
 end
 else begin
  if (fto^.kind = tk_operator) and (fto^.op = '{') then begin
   nexttoken;
   result:= true;
   first:= true;
   int1:= 1;
   while (int1 > 0) and (fto^.kind <> tk_fileend1) do begin
    if (fto^.kind = tk_operator) then begin
     if first and (fto^.op = '$') then begin //compiler switch
      nexttoken;
      parsecompilerswitch;
      int1:= 0;
      break;
     end;
     if fto^.op = '}' then begin
      dec(int1);
     end;
     if (fto^.op = '{') and frecursivecomment then begin
      inc(int1);
     end;
    end;
    first:= false;
    nexttoken;
   end;
   if int1 > 0 then begin
    syntaxerror;
   end;
  end;
 end;
end;

function tpascalparser.getpascalstring(var value: string): boolean;
var
 int1: integer;
begin
 skipwhitespace;
 mark;
 value:= '';
 result:= false;
 while (fto^.kind = tk_operator) and (fto^.op = '''') do begin //'
  result:= true;
  int1:= 0;
  while (fto^.kind = tk_operator) and (fto^.op = '''') do begin //','','''..
   value:= value + getorigtoken;
   inc(int1);
  end;
  if odd(int1) then begin
   while (fto^.kind <> tk_fileend1) and (fto^.kind <> tk_newline) and
    not ((fto^.kind = tk_operator) and (fto^.op = '''')) do begin
    value:= value + getorigtoken;
   end;
   if (fto^.kind = tk_fileend1) or (fto^.kind = tk_newline) then begin
    result:= false;
    break;
   end;
   value:= value + getorigtoken;
   while (fto^.kind = tk_operator) and (fto^.op = '#') do begin
    value:= value + getorigtoken;
    if fto^.kind = tk_number then begin
     value:= value + getorigtoken;
    end
    else begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
 if result then begin
  pop;
 end
 else begin
  value:= '';
  back;
 end;
end;

function tpascalparser.concatpascalstring(var value: string): boolean; 
var
 str1: string;
begin
 value:= '';
 repeat
  result:= getpascalstring(str1);
  if not result then begin
   break;
  end;
  value:= value+str1+' ';
 until not checkoperator('+');
end;

function tpascalparser.concatpascalname(var value: string): boolean;
var
 str1: string;
begin
 value:= '';
 result:= false;
 repeat
  str1:= getorigname;
  if str1 <> '' then begin
   value:= value + str1;
   result:= true;
   if not checkoperator('.') then begin
    break;
   end;
   value:= value + '.';
  end;
 until str1 = '';
end;

function tpascalparser.getvaluestring(var value: string): valuekindty;
begin
 result:= inherited getvaluestring(value);
 if result = vk_none then begin
  if getpascalstring(value) then begin
   result:= vk_string;
  end;
 end;
end;

function tpascalparser.getscannerclass: scannerclassty;
begin
 result:= tpascalscanner;
end;

procedure tpascalparser.initidents;
begin
 setidents(pascalidents);
end;

constructor tpascalparser.create(const afilelist: tmseindexednamelist);
begin
 inherited;
 flastvalidident:= lastpascalnormalident;
 fdefines:= tdefineslist.create;
end;

destructor tpascalparser.destroy;
begin
 fdefines.free;
 inherited;
end;

function tpascalparser.checkclassident(const ident: pascalidentty): boolean;
begin
 flastvalidident:= lastpascalclassident;
 result:= checkident(integer(ident));
 flastvalidident:= lastpascalnormalident;
end;

function tpascalparser.getclassident: pascalidentty;
begin
 flastvalidident:= lastpascalclassident;
 result:= pascalidentty(getident);
 flastvalidident:= lastpascalnormalident;
end;

function tpascalparser.checkpropertyident(const ident: pascalidentty): boolean;
begin
 flastvalidident:= lastpascalpropertyident;
 result:= checkident(integer(ident));
 flastvalidident:= lastpascalnormalident;
end;

function tpascalparser.getpropertyident: pascalidentty;
begin
 flastvalidident:= lastpascalpropertyident;
 result:= pascalidentty(getident);
 flastvalidident:= lastpascalnormalident;
end;

{ tcparser }

constructor tcparser.create(const afilelist: tmseindexednamelist);
begin
 inherited;
 fcasesensitive:= true;
end;

function tcparser.getscannerclass: scannerclassty;
begin
 result:= tcscanner;
end;

procedure tcparser.initidents;
begin
 setidents([]);
end;

function tcparser.getcstring(var value: string): boolean;
begin
 skipwhitespace;
 mark;
 value:= '';
 result:= false;
 while (fto^.kind = tk_operator) and (fto^.op = '"') do begin
  result:= true;
  value:= value + getorigtoken; //leading "
  while not ((fto^.kind = tk_operator) and (fto^.op = '"')) do begin
   if (fto^.kind = tk_operator) and (fto^.op = '\') then begin
    value:= value + getorigtoken; //escapechar
    if fto^.kind = tk_newline then begin
     value:= value + getorigtoken;
    end;
   end;
   if (fto^.kind = tk_fileend1) or (fto^.kind = tk_newline) then begin
    result:= false;
    break;
   end;
   value:= value + getorigtoken;
  end;
  if result then begin
   value:= value + getorigtoken; // terminating "
   if fto^.kind = tk_whitespace then begin
    nexttoken;
    if (fto^.kind = tk_operator) and (fto^.op = '"') then begin
     lasttoken;
     value:= value + getorigtoken;
    end;
   end;
  end
  else begin
   break;
  end;
 end;
 if result then begin
  pop;
 end
 else begin
  value:= '';
  back;
 end;
end;

function tcparser.getvaluestring(var value: string): valuekindty;
begin
 result:= inherited getvaluestring(value);
 if result = vk_none then begin
  if getcstring(value) then begin
   result:= vk_string;
  end;
 end;
end;

function tcparser.skipcomment: boolean;
var
 int1: integer;
begin
 result:= false;
 if (fto^.kind = tk_operator) and
         ((fto^.op = '/') and checknextoperator('/') or
          (fto^.op = '#') and isfirstnonwhitetoken) then begin
  result:= true;
  while not ((fto^.kind = tk_newline) or (fto^.kind = tk_fileend1)) do begin
   nexttoken;
  end;
 end
 else begin
  if (fto^.kind = tk_operator) and (fto^.op = '/') and checknextoperator('*') then begin
   result:= true;
   int1:= 1;
   while (int1 > 0) and (fto^.kind <> tk_fileend1) do begin
    if (fto^.kind = tk_operator) then begin
     if fto^.op = '*' then begin
      if checknextoperator('/') then begin
       dec(int1);
      end;
     end
     else begin
      if (fto^.op = '/') and frecursivecomment then begin
       if checknextoperator('*') then begin
        inc(int1);
       end;
      end;
     end;
    end;
    nexttoken;
   end;
   if int1 > 0 then begin
    syntaxerror;
   end;
  end;
 end;
end;

{ tconstparser }

function tconstparser.getconsts(var ar: constinfoarty): string; //returns unitname

var
 count: integer;

 function additem: pconstinfoty;
 begin
  if high(ar) <= count then begin
   setlength(ar,high(ar) + 33);
  end;
  result:= @ar[count];
  inc(count);
 end;

var
 str1,str2: string;
 ch1: char;
 ident: pascalidentty;
 resourceflag: boolean;
 apos: pchar;

begin
 ar:= nil;
 count:= 0;
 result:= '';
 while not eof do begin
  ident:= pascalidentty(getident);
  if (ident = id_unit) or (ident = id_program) then begin
   result:= getname;
  end;
  if (ident = id_const) or (ident = id_resourcestring) then begin
   resourceflag:= ident = id_resourcestring;
   repeat
    mark;
    if getident >= 0 then begin
     pop;
     lasttoken; 
     break;
    end;
    str1:= getname;
    if str1 <> '' then begin
     ch1:= getoperator;
     if ch1 = '=' then begin
      skipwhitespace;
      apos:= fto^.value.po;
      case getvaluestring(str2) of
       vk_string: begin
        with additem^ do begin
         valuetype:= vawstring;
         name:= str1;
         value:= pascalstringtostring(str2);
         resource:= resourceflag;
         offset:= apos-pchar(pointer(fscanner.fsource));
         len:= fto^.value.po-apos;
        end;
       end;
       else begin
        nexttoken;
       end;
      end;
      pop;
     end
     else begin
      back;
     end;
    end
    else begin
     pop;
     nexttoken;
    end;
   until not checkoperator(';');
  end
  else begin
   nexttoken;
  end;
 end;
 setlength(ar,count);
end;
 
{ tfpcresstringparser }

procedure tfpcresstringparser.getconsts(var ar: constinfoarty);
var
 count: integer;
 str1,str2: string;
 apos: pchar;
 
begin
 ar:= nil;
 count:= 0;
 while (fsyntaxerrorcount = 0) and not eof do begin
  if testoperator('#') then begin
   nextline;
  end
  else begin
   if concatpascalname(str1) and checkoperator('=') then begin
    skipwhitespace;
    apos:= fto^.value.po;
    if concatpascalstring(str2) then begin
     additem(ar,typeinfo(constinfoarty),count);
     with ar[count-1] do begin
      valuetype:= vawstring;
      name:= str1;
      value:= pascalstringtostring(str2);
      offset:= apos-pchar(pointer(fscanner.fsource));
      len:= fto^.value.po-apos;
     end;
    end;
   end
   else begin
    nextline;
   end;
  end;
 end;
 setlength(ar,count);
end;

{ tresstringlistparser }

constructor tresstringlistparser.create(const afilelist: tmseindexednamelist);
begin
 inherited;
 fcasesensitive:= true;
end;

procedure tresstringlistparser.getconsts(var ar: constinfoarty);
type
 residentty = (ri_stringtable,ri_begin,ri_end);
const
 residents: array[residentty] of string =
  ('STRINGTABLE','BEGIN','END');

var
 count: integer;

 function additem: pconstinfoty;
 begin
  if high(ar) <= count then begin
   setlength(ar,high(ar) + 33);
  end;
  result:= @ar[count];
  inc(count);
 end;

var
 str1,str2: string;
 ident: residentty;
 apos: pchar;

begin
 setidents(residents);
 ar:= nil;
 count:= 0;
 while (fsyntaxerrorcount = 0) and not eof do begin
  ident:= residentty(getfirstident);
  if (ident = ri_stringtable) then begin
   repeat
   until (residentty(getfirstident) = ri_begin) or eof;
   while (fsyntaxerrorcount = 0) and not eof do begin
    nextline;
    if fto^.kind = tk_whitespace then begin
     str1:= getname;
     if str1 = '' then begin
      syntaxerror;
     end
     else begin
      if checkoperator(',') then begin
       skipwhitespace;
       apos:= fto^.value.po;
       if getvaluestring(str2) = vk_string then begin
        with additem^ do begin
         valuetype:= vawstring;
         name:= str1;
         value:= cstringtostring(str2);
         offset:= apos-pchar(pointer(fscanner.fsource));
         len:= fto^.value.po-apos;
        end;
       end
       else begin
        syntaxerror;
       end;
      end
      else begin
       syntaxerror;
      end;
     end;
    end
    else begin
     if residentty(getident) <> ri_end then begin
      syntaxerror;
     end;
     break;
    end;
   end;
  end
  else begin
   nextline;
  end;
 end;
 setlength(ar,count);
end;


end.
