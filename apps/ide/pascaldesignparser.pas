{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit pascaldesignparser;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$GOTO ON}{$endif}

interface
uses
 classes,mseparser,typinfo,msetypes,mselist,msestrings,mseclasses;

type

 browserlistitemty = record
  index: integer;
 end;
 pbrowserlistitemty = ^browserlistitemty;

 tbrowserlist = class(trecordlist)
  public
   function newitem: pointer; override;
 end;

  sourceiteminfoty = record
  end;

  compinfoty = record
   b: browserlistitemty;
   name,uppername: string;
   typename,uppertypename: string;
   insertpos,namepos,nameend,typepos,typeend,endpos: sourceposty;
  end;
  pcompinfoty = ^compinfoty;

  tcomponentinfolist = class(tbrowserlist)
   protected
    function getitempo(const index: integer): pcompinfoty;
    procedure finalizerecord(var item); override;
   public
    constructor create;
    function finditembyname(const aname: string): pcompinfoty;
    property items[const index: integer]: pcompinfoty read getitempo; default;
  end;

  paraminfoty = record
   flags: tparamflags;
   name: string;
   typename: string;
   defaultvalue: string;
  end;
  paraminfoarty = array of paraminfoty;
  
  methodflagty = (mef_virtual,mef_abstract,mef_inherited,mef_override,
                        mef_reintroduce,mef_overload);
  methodflagsty = set of methodflagty;
  
  methodparaminfoty = record
   kind: tmethodkind;
   flags: methodflagsty;
   params: paraminfoarty; //last is functionresult
  end;

  tdeflist = class;

  procedureinfoty = record
   b: browserlistitemty;
   params: methodparaminfoty;
   name,uppername: string;
   intinsertpos,intstartpos,intendpos: sourceposty;
   impheaderstartpos: sourceposty;
   impheaderendpos: sourceposty;
   impendpos: sourceposty;
  end;
  pprocedureinfoty = ^procedureinfoty;
  procedureinfoarty = array of procedureinfoty;
  procedureinfopoarty = array of pprocedureinfoty;

  tprocedureinfolist = class(tbrowserlist)
   private
   protected
    procedure finalizerecord(var item); override;
    function getitempo(const index: integer): pprocedureinfoty;
   public
    constructor create;
    function finditembyname(const aname: string): pprocedureinfoty;
    function finditembyuppername(const aname: lstringty;
                  const info: methodparaminfoty): pprocedureinfoty;
    function matchmethod(const atype: ptypeinfo): integerarty;
    function matchedmethodnames(const atype: ptypeinfo): msestringarty;
    property items[const index: integer]: pprocedureinfoty read getitempo; default;
  end;

  classinfoty = record
   b: browserlistitemty;
   deflist: tdeflist;
   name,uppername: string;
   parentname: string;
   componentlist: tcomponentinfolist;
   procedurelist: tprocedureinfolist;
   headerstop: sourceposty;
   managedstart: sourceposty;
   procedurestart: sourceposty;
    //fileoffset of first line with methods, fileoffset of end of managed
    //section if none
   managedend: sourceposty;
   privatestart: sourceposty; //start of first private segment
   privatefieldend: sourceposty; 
         //before start of first procdef in first private segment
   privateend: sourceposty;   //end of first private segment
   procimpstart,procimpend: sourceposty;
   inimplementation: boolean;
  end;
  pclassinfoty = ^classinfoty;

  tclassinfolist = class(tbrowserlist)
   protected
    procedure finalizerecord(var item); override;
    procedure initializerecord(var item); override;
    function getitempo(const index: integer): pclassinfoty;
   public
    constructor create;
    property items[const index: integer]: pclassinfoty read getitempo; default;
    function finditembyname(const aname: lstringty; const interfaceonly: boolean): pclassinfoty; overload;
    function finditembyname(const aname: string; const interfaceonly: boolean): pclassinfoty; overload;
  end;

 sourceitemkindty = (sik_uses,sik_include{,sik_identuse});
 identuseflagty = (idu_first,idu_last);
 identuseflagsty = set of identuseflagty;

 sourceitemty = record
  filename: nameidty;
  startoffset,endoffset: integer;
  startpos,endpos: gridcoordty;
  case kind: sourceitemkindty of
   sik_uses:
    (imp: boolean);
   sik_include:
    (index: integer);
    {
   sik_identuse:
    (identuseflags: identuseflagsty);
    }
 end;
 psourceitemty = ^sourceitemty;
 sourceiteminfoaty = array[0..0] of sourceitemty;
 psourceiteminfoaty = ^sourceiteminfoaty;

 tsourceitemlist = class(torderedrecordlist)
  protected
   function getcompareproc: compareprocty; override;
   procedure compare(const l,r; out result: integer);
  public
   constructor create;
   function newitem(const astart,aend: sourceposty;
            akind: sourceitemkindty): psourceitemty; reintroduce;
   procedure updateitem(var aitem: sourceitemty; const astart,aend: sourceposty;
            akind: sourceitemkindty);
   function find(const apos: sourceposty): psourceitemty; overload;
   function find(const apos: sourceposty;
                    out aindex: integer): psourceitemty; overload;
 end;

  usesinfoty = record
   b: browserlistitemty;
   name,uppername: string;
  end;
  pusesinfoty = ^usesinfoty;
  usesinfoaty = array[0..0] of usesinfoty;
  pusesinfoaty = ^usesinfoaty;

  trootdeflist = class;

  tusesinfolist = class(tbrowserlist)
   private
    fimplementation: boolean;
    function getunitnames(const index: integer): string;
   protected
    fstartpos,fendpos: sourceposty;
    procedure finalizerecord(var item); override;
    procedure copyrecord(var item); override;
   public
    constructor create(aimplementation: boolean);
    procedure clear; override;
    property startpos: sourceposty read fstartpos;
    property endpos: sourceposty read fendpos;
    procedure add(const units: lstringarty);
    procedure getsourceitems(const alist: tsourceitemlist);
    function find(const aname: string): pusesinfoty;
    function getunitdeflist(const index: integer): trootdeflist; overload;
    function getunitdeflist(const aunitname: string): trootdeflist; overload;
    property unitnames[const index: integer]: string read getunitnames;
  end;

  identuseinfoty = record
   b: browserlistitemty;
   startpos: sourceposty;
   length: integer;
   flags: identuseflagsty;
   scope: tdeflist;
  end;
  pidentuseinfoty = ^identuseinfoty;
  identuseinfoaty = array[0..0] of identuseinfoty;
  pidentuseinfoaty = ^identuseinfoaty;

  sourcefileinfoty = record
   filename: filenamety;
   startline,count,includecount: integer;
  end;
  sourcefileinfoarty = array of sourcefileinfoty;

  includestatementty = record
   startpos,endpos: sourceposty;
   filename: filenamety;
  end;
  symbolkindty = (syk_none,syk_nopars,syk_substr,syk_deleted,syk_root,syk_classdef,
                  syk_procdef,syk_procimp1,syk_classprocimp,
                  syk_vardef,syk_constdef,syk_typedef,syk_identuse);
  defnamety = record
   name: string;
   id: nameidty;
  end;
  pdefnamety = ^defnamety;
  defnameaty = array[0..0] of defnamety;
  pdefnameaty = ^defnameaty;

  identflagty = (if_first,if_last);
  identflagsty = set of identflagty;
  varflagty = (vf_property);
  varflagsty = set of varflagty;
  
  definfoty = record
   name: string;      //'' -> statment
   pos,stop1: sourceposty;
   deflist: tdeflist; //can be nil
   case kind: symbolkindty of
    syk_classdef: (classindex: integer);
    syk_procdef: (procindex: integer);
    syk_identuse: (identlen: integer; identflags: identflagsty);
    syk_vardef: (varflags: varflagsty);
  end;
  pdefinfoty = ^definfoty;
  definfoarty = array of definfoty;
  definfopoarty = array of pdefinfoty;

  defsearchlevelty = (dsl_normal,dsl_qualified,dsl_child,dsl_parent,
              dsl_parentclass,dsl_inclass,dsl_unitsearch);
  deflistarty = array of tdeflist;

  tdeflist = class(torderedrecordlist)
   private
    fparent: tdeflist;
    fparentid: nameidty;
    fparentscope: tdeflist; //class definition
    fparentident: string;
    fparentunitindex: integer;
    finfocount: integer;
    finfos: definfoarty;
    fstart,fstop: sourceposty;
    fkind: symbolkindty;
    procedure comp(const l,r; out result: integer);
    procedure compnopars(const l,r; out result: integer);
    procedure compsubstr(const l,r; out result: integer);
    function getname: string;
    function getdefinfopo: pdefinfoty;
    function getrootlist: trootdeflist;
    function incinfocount: integer;
    function internalfinditem(const apos: sourceposty; const firstidentuse,last: boolean;
                           out scope: tdeflist): pdefinfoty;
   protected
    procedure finalizerecord(var item); override;
    function getcompareproc: compareprocty; override;
    function add(const aname: string; const akind: symbolkindty;
                 const apos,astop: sourceposty): pdefinfoty; overload;
    function add(const akind: symbolkindty; const apos,astop: sourceposty): pdefinfoty; overload;
                     //statment
   public
    constructor create(const akind: symbolkindty);
    procedure clear; override;
    procedure startident(const aparser: tparser);
    procedure addident(const aparser: tparser);
    procedure addemptyident(const aparser: tparser);
    procedure endident(const aparser: tparser); overload;
    procedure endident(const aparser: tparser; const endpos: sourceposty); overload;
    function addidents(const aparser: tparser): boolean;

    function find(const aname: string;
                     const akind: symbolkindty = syk_none): pdefinfoty;
    function getmatchingitems(const aname: string;
                    const akind: symbolkindty = syk_none): definfopoarty;
    function finddef(const anamepath: stringarty; var scopes: deflistarty;
               var defs: definfopoarty;
               const first: boolean; // break if first found
               const level: defsearchlevelty;
               const afindkind: symbolkindty = syk_none;
               const maxcount: integer = bigint): boolean; overload; virtual;
               //true if found
    function finddef(const aname: string; const afindkind: symbolkindty;
               out ascope: tdeflist): pdefinfoty; overload;
    function finditem(const apos: sourceposty; const firstidentuse: boolean;
                           out scope: tdeflist): pdefinfoty;
    property parent: tdeflist read fparent;
    property parentid: nameidty read fparentid;
    property parentscope: tdeflist read fparent;
    property kind: symbolkindty read fkind;
    property name: string read getname;
    property definfopo: pdefinfoty read getdefinfopo;
    property rootlist: trootdeflist read getrootlist;
    property infos: definfoarty read finfos;
  end;

  punitinfoty = ^unitinfoty;

  trootdeflist = class(tdeflist)
   private
    factnode: tdeflist;
    funitinfopo: punitinfoty;
    flastunitindex: integer;
   protected
    function beginnode(const aname: string; const akind: symbolkindty;
                        const apos,astop: sourceposty): pdefinfoty; overload;
   public
    allreadysearched: boolean;
    constructor create(const aunitinfopo: punitinfoty);
    procedure clear; override;
    procedure endnode(const apos: sourceposty);
    function beginnode(const apos: sourceposty;
                      const aclassinfo: pclassinfoty): tdeflist; overload;
    function add(const aname: string; const akind: symbolkindty;
                      const astart,astop: sourceposty): pdefinfoty; overload;
    function add(const apos,astop: sourceposty; 
                      const aprocinfo: pprocedureinfoty): pdefinfoty; overload;
    procedure deletenode;
    function finddef(const anamepath: stringarty; var scopes: deflistarty;
               var defs: definfopoarty;
               const first: boolean; // break on first found
               const level: defsearchlevelty;
               const afindkind: symbolkindty = syk_none;
               const maxcount: integer = bigint): boolean; override;
               //true if found
    function findparentclass(const adescendent: tdeflist;
                  var defs: definfopoarty): boolean;
    
    property unitinfopo: punitinfoty read funitinfopo;
  end;

  includestatementarty = array of includestatementty;

  unitinfoty = record
   interfacecompiled: boolean;
   implementationcompiled: boolean;
   isprogram: boolean;
   itemlist: tsourceitemlist;
   deflist: trootdeflist;

   procedurelist: tprocedureinfolist;
   classinfolist: tclassinfolist;
   interfaceuses,implementationuses: tusesinfolist;
   unitname: string; //uppercase
   origunitname: string;
   formfilename: filenamety;
   sourcefilename: filenamety;
   implementationstart: sourceposty;
   implementationend: sourceposty;
   unitend: sourceposty;
   initializationstart: sourceposty;
   finalizationstart: sourceposty;
   sourceend: sourceposty;
   sourcefiles: sourcefileinfoarty;
   includestatements: includestatementarty;
  end;

  tpascaldesignparser = class(tpascalparser)
   private
    funitinfopo: punitinfoty;
    fimplementation: boolean;
    finterface: boolean;
    finterfaceonly: boolean;
    fnoautoparse: boolean;
   protected
    function skipexpression: boolean;
    procedure parsetype;
    procedure parselabel;
    procedure parseconst;
    procedure parsevar;
    function parseclasstype: boolean;
    function parseinterfacetype: boolean;
    function parserecord: boolean;
    function parseprocparams(const akind: tmethodkind;
                            var params: paraminfoarty): boolean;
    function parseclassprocedureheader(atoken: pascalidentty;
                  classinfopo: pclassinfoty): boolean;
    function skipprocedureparams(atoken: pascalidentty): boolean;
    function skipprocedureheader(atoken: pascalidentty): boolean;
    procedure parseprocedurebody;
    procedure parseimplementation;
   public
    constructor create(unitinfopo: punitinfoty;
               const getincludefile: getincludefileeventty;
                const ainterfaceonly: boolean); overload;
    constructor create(const afilelist: tmseindexednamelist; 
                 const atext: string); overload;
    procedure parse; override;
    function dogetincludefile(const afilename: filenamety;
                     const astatementstart,astatementend: sourceposty): tscanner; override;
    function parseprocedureheader(atoken: pascalidentty;
                   procedureinfopo: pprocedureinfoty): boolean;
  end;

function findclassinfobyinstance(const ainstance: tmsecomponent; 
                                 const infopo: punitinfoty): pclassinfoty;
procedure getmethodparaminfo(const atype: ptypeinfo; var info: methodparaminfoty);
function isemptysourcepos(const apos: sourceposty): boolean;
function isinrowrange(const apos,startpos,endpos: sourceposty): boolean;
procedure parsedef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);
function splitidentpath(const atext: string): stringarty;

function mangleprocparams(const aparams: methodparaminfoty): string;
function parametersmatch(const a: ptypeinfo; const b: methodparaminfoty): boolean;

implementation
uses
 sysutils,msedatalist,msefileutils,msedesigner,sourceupdate,msestream;

function mangleprocparams(const aparams: methodparaminfoty): string;
var
 int1: integer;
begin
 with aparams do begin
  result:= '';
  for int1:= 0 to high(params) do begin
   result:= result + '$' + params[int1].typename;
  end;
  if kind in [mkfunction,mkclassfunction] then begin
   result:= result+'$';
  end;
 end;
end;

function splitidentpath(const atext: string): stringarty;
begin
 result:= nil;
 splitstring(atext,result,'.',true);
end;

procedure parsedef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);
var
 parser: tpascalparser;
// ident1: integer;
begin
 scope:= tdeflist.create(adef^.kind);
 atext:= sourceupdater.getdefinfotext(adef);
 if atext <> '' then begin
  parser:= tpascalparser.create(designer.designfiles,atext);
  try
   with parser do begin
    if adef^.kind = syk_procdef then begin
     if checknamenoident and checkoperator('(') then begin
      repeat
       while not eof and not checkoperator(':') do begin
        nexttoken;
       end;
       scope.addidents(parser);
       while not eof and not checkoperator(';') do begin
        nexttoken;
       end;
      until eof;
     end;
    end
    else begin
//     ident1:= getident;
     if checknamenoident then begin
      if adef^.kind = syk_vardef then begin
       if checkoperator(':') then begin
        scope.addidents(parser);
       end;
      end
      else begin
       if adef^.kind = syk_classdef then begin
        if checkoperator('=') and checkident(ord(id_class)) and checkoperator('(') then begin
         scope.addidents(parser);
        end;
       end;
      end;
     end;
    end;
   end;
  finally
   parser.Free;
  end;
 end;
end;

function isemptysourcepos(const apos: sourceposty): boolean;
begin
 with apos do begin
  result:= (filenum = 0) {and (pos.col = 0) and (pos.row = 0)};
 end;
end;

function isinrowrange(const apos,startpos,endpos: sourceposty): boolean;
begin
// result:= (apos.filenum = startpos.filenum) and (apos.filenum = endpos.filenum) and
//          (apos.pos.row >= startpos.line) and (apos.pos.row <= endpos.line);
 result:= (apos.line >= startpos.line) and (apos.line <= endpos.line);
end;

function findclassinfobyinstance(const ainstance: tmsecomponent; const infopo: punitinfoty): pclassinfoty;
var
 po1: pmoduleinfoty;
begin
 result:= nil;
 if infopo <> nil then begin
  po1:= designer.modules.findmodule(ainstance);
  if po1 <> nil then begin
   result:= infopo^.classinfolist.finditembyname(po1^.moduleclassname,true);
  end;
 end;
end;

procedure getmethodparaminfo(const atype: ptypeinfo; var info: methodparaminfoty);

  function getshortstring(var po: pchar): string;
  begin
   setlength(result,byte(po^));
   inc(po);
   move(po^,pointer(result)^,length(result));
   inc(po,length(result));
  end;

var
 isfunction: boolean;
 int1: integer;
 po1: pchar;
begin
 with info do begin
  kind:= tmethodkind(-1);
  params:= nil;
  if atype^.Kind = tkmethod then begin
   with gettypedata(atype)^ do begin
    kind:= methodkind;
    int1:= paramcount;
    isfunction:= methodkind = mkfunction;
    if isfunction then begin
     inc(int1);
    end;
    if isfunction or (methodkind = mkprocedure) then begin
     setlength(params,int1);
     po1:= @paramlist;
     for int1:= 0 to paramcount - 1 do begin
      with params[int1] do begin
       flags:= tparamflags({$ifdef FPC}longword({$endif}byte(po1^){$ifdef FPC}){$endif});
       inc(po1,sizeof({$ifdef FPC}byte{$else}tparamflags{$endif}));
       name:= getshortstring(po1);
       typename:= getshortstring(po1);
       if typename = 'WideString' then begin
        typename:= 'msestring';
       end
       else begin
        if typename = 'LongInt' then begin
         typename:= 'Integer';
        end
        else begin
         if typename = 'Double' then begin
          typename:= 'Real';
         end;
        end;
       end;
      end;
     end;
     if isfunction then begin
      params[high(params)].typename:= getshortstring(po1);
     end;
    end;
   end;
  end;
 end;
end;

function parametersmatch1(const a,b: methodparaminfoty): boolean;
var
 int1: integer;
begin
 result:= (a.kind = b.kind) and (high(a.params) = high(b.params));
 if result then begin
  for int1:= 0 to high(a.params) do begin
   with a.params[int1] do begin
    if (flags*[pfvar,pfconst,pfout] <> b.params[int1].flags*[pfvar,pfconst,pfout]) or
           (stringicomp(typename,b.params[int1].typename) <> 0) then begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
end;

function parametersmatch(const a: ptypeinfo; const b: methodparaminfoty): boolean;
var
 a1: methodparaminfoty;
begin
 getmethodparaminfo(a,a1);
 result:= parametersmatch1(a1,b);
end;

{ tsourceitemlist }

constructor tsourceitemlist.create;
begin
 inherited create(sizeof(sourceitemty));
end;

procedure tsourceitemlist.compare(const l,r; out result: integer);
begin
 result:= sourceitemty(l).startpos.row - sourceitemty(r).startpos.row;
 if result = 0 then begin
  result:= sourceitemty(l).startpos.col - sourceitemty(r).startpos.col;
 end;
end;

function tsourceitemlist.getcompareproc: compareprocty;
begin
 result:= {$ifdef FPC}@{$endif}compare;
end;

function tsourceitemlist.find(const apos: sourceposty; out aindex: integer): psourceitemty;
var
 aitem: sourceitemty;
begin
 aitem.startpos.col:= apos.pos.col;
 aitem.startpos.row:= apos.line;
 if not internalfind(aitem,aindex) then begin
  dec(aindex);
 end;
 if aindex >= 0 then begin
  result:= @psourceiteminfoaty(datapo)^[aindex];
  with result^ do begin
   if (endpos.row < apos.line) or
       (endpos.row = apos.line) and (endpos.col <= apos.pos.col) then begin
    result:= nil;
    aindex:= -1;
   end;
  end;
 end
 else begin
  result:= nil;
 end;
end;

function tsourceitemlist.find(const apos: sourceposty): psourceitemty;
var
 int1: integer;
begin
 result:= find(apos,int1);
end;

{
function tsourceitemlist.newitem(const afilename: nameidty;
            const startcol,startrow,endcol,endrow: integer;
            akind: sourceitemkindty): psourceitemty;
begin
 result:= inherited newitem;
 with result^ do begin
  filename:= afilename;
  startpos.col:= startcol;
  startpos.row:= startrow;
  endpos.row:= endrow;
  endpos.col:= endcol;
  kind:= akind;
 end;
end;
}

procedure tsourceitemlist.updateitem(var aitem: sourceitemty;
              const astart,aend: sourceposty; akind: sourceitemkindty);
begin
 with aitem do begin
  filename:= astart.filename;
  startpos.col:= astart.pos.col;
  startpos.row:= astart.line;
  startoffset:= astart.offset;
  endpos.col:= aend.pos.col;
  endpos.row:= aend.line;
  endoffset:= aend.offset;
  kind:= akind;
 end;
end;

function tsourceitemlist.newitem(const astart,aend: sourceposty;
            akind: sourceitemkindty): psourceitemty;
begin
 result:= inherited newitem;
 updateitem(result^,astart,aend,akind);
end;

{ tbrowserlist }

function tbrowserlist.newitem: pointer;
begin
 result:= inherited newitem;
 pbrowserlistitemty(result)^.index:= count - 1;
end;

{ tusesinfolist }

constructor tusesinfolist.create(aimplementation: boolean);
begin
 fimplementation:= aimplementation;
 inherited create(sizeof(usesinfoty),[rels_needsfinalize,rels_needscopy]);
end;

procedure tusesinfolist.clear;
begin
 inherited;
 if not fimplementation then begin
  count:= 1;
  with pusesinfoty(fdata)^ do begin
   name:= 'system';
   uppername:= 'SYSTEM';
  end;
 end;
end;

procedure tusesinfolist.add(const units: lstringarty);
var
 int1: integer;
 po1: pusesinfoty;
begin
 if high(units) >= 0 then begin
  int1:= count;
  count:= count + length(units);
  po1:= getitempo(int1);
  for int1:= 0 to high(units) do begin
   with po1^ do begin
    name:= lstringtostring(units[int1]);
    uppername:= struppercase(name);
   end;
   inc(po1);
  end;
 end;
end;

procedure tusesinfolist.getsourceitems(const alist: tsourceitemlist);
var
 po1: psourceitemty;
begin
 po1:= alist.newitem(fstartpos,fendpos,sik_uses);
 with po1^ do begin
  imp:= fimplementation;
 end;
end;

procedure tusesinfolist.finalizerecord(var item);
begin
 finalize(usesinfoty(item));
end;

procedure tusesinfolist.copyrecord(var item);
begin
 with usesinfoty(item) do begin
  stringaddref(name);
  stringaddref(uppername);
 end;
end;

function tusesinfolist.find(const aname: string): pusesinfoty;
var
 po1: pusesinfoty;
 int1: integer;
 str1: string;
begin
 result:= nil;
 po1:= datapo;
 str1:= struppercase(aname);
 for int1:= 0 to count - 1 do begin
  if str1 = po1^.uppername then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

function tusesinfolist.getunitdeflist(const index: integer): trootdeflist;
var
 po2: punitinfoty;
begin
 po2:= sourceupdater.updateunitinterface(unitnames[index]);
 if po2 <> nil then begin
  result:= po2^.deflist;
 end
 else begin
  result:= nil;
 end;
end;

function tusesinfolist.getunitdeflist(const aunitname: string): trootdeflist;
var
 po1: pusesinfoty;
 po2: punitinfoty;
begin
 result:= nil;
 po1:= find(aunitname);
 if po1 <> nil then begin
  po2:= sourceupdater.updateunitinterface(aunitname);
  if po2 <> nil then begin
   result:= po2^.deflist;
  end;
 end;
end;

function tusesinfolist.getunitnames(const index: integer): string;
begin
 result:= pusesinfoty(getitempo(index))^.name;
end;

{ tcomponentinfolist }

constructor tcomponentinfolist.create;
begin
 inherited create(sizeof(compinfoty),[rels_needsfinalize]);
end;

procedure tcomponentinfolist.finalizerecord(var item);
begin
 finalize(compinfoty(item));
end;

function tcomponentinfolist.getitempo(const index: integer): pcompinfoty;
begin
 result:= pcompinfoty(inherited getitempo(index));
end;

function tcomponentinfolist.finditembyname(const aname: string): pcompinfoty;
var
 po1: pcompinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if stringicomp1(aname,po1^.uppername) = 0 then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

{ tprocedureinfolist }

constructor tprocedureinfolist.create;
begin
 inherited create(sizeof(procedureinfoty),[rels_needsfinalize]);
end;

procedure tprocedureinfolist.finalizerecord(var item);
begin
 finalize(procedureinfoty(item));
end;

function tprocedureinfolist.getitempo(
  const index: integer): pprocedureinfoty;
begin
 result:= pprocedureinfoty(inherited getitempo(index));
end;

function tprocedureinfolist.finditembyname(const aname: string): pprocedureinfoty;
var
 po1: pprocedureinfoty;
 int1: integer;
 str1: string;
begin
 result:= nil;
 po1:= datapo;
 str1:= uppercase(aname);
 for int1:= 0 to fcount - 1 do begin
  if str1 = po1^.uppername then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

function tprocedureinfolist.finditembyuppername(const aname: lstringty;
                  const info: methodparaminfoty): pprocedureinfoty;
var
 po1: pprocedureinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if (po1^.params.kind = info.kind) and
                 (lstringcomp(aname,po1^.uppername) = 0) and 
                 parametersmatch1(info,po1^.params) then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

function tprocedureinfolist.matchmethod(const atype: ptypeinfo): integerarty;
var
 info: methodparaminfoty;
 int1: integer;
 po1: pprocedureinfoty;
begin
 result:= nil;
 getmethodparaminfo(atype,info);
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  with po1^ do begin
   if parametersmatch1(params,info) then begin
    additem(result,int1);
   end;
  end;
  inc(po1);
 end;
end;

function tprocedureinfolist.matchedmethodnames(const atype: ptypeinfo): msestringarty;
var
 ar1: integerarty;
 int1: integer;
begin
 ar1:= matchmethod(atype);
 setlength(result,length(ar1));
 for int1:= 0 to high(ar1) do begin
  result[int1]:= getitempo(ar1[int1])^.name;
 end;
end;

{ tclassinfolist }

constructor tclassinfolist.create;
begin
 inherited create(sizeof(classinfoty),[rels_needsfinalize,rels_needsinitialize]);
end;

procedure tclassinfolist.initializerecord(var item);
begin
 with classinfoty(item) do begin
  componentlist:= tcomponentinfolist.create;
  procedurelist:= tprocedureinfolist.create;
 end;
end;

procedure tclassinfolist.finalizerecord(var item);
begin
 with classinfoty(item) do begin
  componentlist.free;
  procedurelist.free;
 end;
 finalize(classinfoty(item));
end;

function tclassinfolist.getitempo(const index: integer): pclassinfoty;
begin
 result:= pclassinfoty(inherited getitempo(index));
end;

function tclassinfolist.finditembyname(const aname: lstringty; const interfaceonly: boolean): pclassinfoty;
var
 po1: pclassinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if lstringicomp1(aname,po1^.uppername) = 0 then begin
   if not interfaceonly or not po1^.inimplementation then begin
    result:= po1;
   end;
   break;
  end;
  inc(po1);
 end;
end;

function tclassinfolist.finditembyname(const aname: string; const interfaceonly: boolean): pclassinfoty;
begin
 result:= finditembyname(stringtolstring(aname),interfaceonly);
end;

{ tidentuselist}
{
constructor tidentuselist.create;
begin
 inherited create(sizeof(identuseinfoty));
end;

function tidentuselist.add(const info: identuseinfoty): integer;
begin
 result:= inherited add(info);
end;

procedure tidentuselist.getsourceitems(const alist: tsourceitemlist);
var
 po1: psourceitemty;
 po2: pidentuseinfoty;
 int1: integer;
 pos1: sourceposty;
begin
 po1:= alist.newitems(count);
 po2:= datapo;
 for int1:= 0 to count - 1 do begin
  pos1:= po2^.startpos;
  inc(pos1.offset,po2^.length);
  inc(pos1.pos.col,po2^.length);
  alist.updateitem(po1^,po2^.startpos,pos1,sik_identuse);
  po1^.identuseflags:= po2^.flags;
  inc(po1);
  inc(po2);
 end;
end;
}
{ tpascaldesignparser }

constructor tpascaldesignparser.create(unitinfopo: punitinfoty;
            const getincludefile: getincludefileeventty;
            const ainterfaceonly: boolean);
begin
 finterfaceonly:= ainterfaceonly;
 inherited create(designer.designfiles);
 funitinfopo:= unitinfopo;
 funitinfopo^.interfacecompiled:= false;
 funitinfopo^.implementationcompiled:= false;
 ongetincludefile:= getincludefile;
end;

constructor tpascaldesignparser.create(const afilelist: tmseindexednamelist; 
                 const atext: string);
begin
 fnoautoparse:= true;
 inherited create(afilelist,atext);
end;

function tpascaldesignparser.skipexpression: boolean;
var
 bracketlevel: integer;
 ch1: char;
 str1: string;
begin
 result:= true;
 bracketlevel:= 0;
 repeat
  ch1:= getoperator;
  case ch1 of
   '(','[': inc(bracketlevel);
   ')',']': dec(bracketlevel);
   '*','/','+','-','^',',': begin
   end;
   else begin
    if ch1 <> #0 then begin
     lasttoken; //' for pascalstring
    end;
    if getvaluestring(str1) = vk_none then begin
     if ch1 <> #0 then begin
      break; //error
     end
     else begin
      nexttoken; //was ident
     end;
    end;
   end;
  end;
 until eof or (bracketlevel < 0);
 if bracketlevel < 0 then begin
  lasttoken;
 end;
end;

function tpascaldesignparser.parseprocparams(const akind: tmethodkind;
                            var params: paraminfoarty): boolean;
var
 ar1: stringarty;
 paraflags: tparamflags;
 defaultstr: string;

 procedure putparams(const atypename: string);
 var
  int1,int2: integer;
 begin
  int2:= length(params);
  setlength(params,int2+length(ar1));
  for int1:= 0 to high(ar1) do begin
   with params[int2] do begin
    name:= ar1[int1];
    flags:= paraflags;
    typename:= atypename;
    defaultvalue:= defaultstr;
   end;
   inc(int2);
  end;
 end;

var
 str1: string;
 int1: integer;
 po1: pchar;

begin
 ar1:= nil; //compiler warning
 params:= nil;
 result:= false;
 if checkoperator(';') then begin
  if not (akind in [mkfunction,mkclassfunction]) then begin
   result:= true;   //no params
  end;
 end
 else begin
  if checkoperator('(') then begin
   while not eof do begin
    defaultstr:= '';
    int1:= getident;
    case pascalidentty(int1) of
     id_const: paraflags:= [pfconst];
     id_var: paraflags:= [pfvar];
     id_out: paraflags:= [pfout];
     else paraflags:= [];
    end;
    if (paraflags = []) and (int1 >= 0) then begin
     break;
    end;
    ar1:= lstringartostringar(getorignamelist);
    if not checkoperator(':') then begin
     putparams(''); //untyped
    end
    else begin
     if checkident(ord(id_array)) then begin
      include(paraflags,pfarray);
      checkident(ord(id_of));
      if checkident(ord(id_const)) then begin
       str1:= 'TVarRec';
      end
      else begin
       str1:= getorigname;
      end;
     end
     else begin
      str1:= getorigname;
     end;
     if str1 = '' then begin
      break;
     end;
     if checkoperator('=') then begin
      skipwhitespace;
      po1:= fto^.value.po;
      skipexpression;
      defaultstr:= getorigtext(po1);
     end;
     putparams(str1);
    end;
    if checkoperator(')') then begin
     result:= true;
     break;
    end;
    if not checkoperator(';') then begin
     break;
    end;
   end;
  end
  else begin
   result:= true;
  end;
  if result then begin
   if (akind in [mkfunction,mkclassfunction]) then begin
    if checkoperator(':') then begin
     setlength(params,length(params)+1);
     with params[high(params)] do begin
      typename:= getorigname;
     end;
    end
    else begin
     result:= false;
    end;
   end;
  end;
  if result then begin
   checkoperator(';');
  end;
 end;
end;

function tpascaldesignparser.parseprocedureheader(atoken: pascalidentty;
                   procedureinfopo: pprocedureinfoty): boolean;
begin
// result:= false;
 with procedureinfopo^ do begin
  intinsertpos:= lasttokenpos;
  skipwhitespace;
  intstartpos:= sourcepos;
  case atoken of
   id_function: params.kind:= mkfunction;
   id_constructor: params.kind:= mkconstructor;
   id_destructor: params.kind:= mkdestructor;
   else params.kind:= mkprocedure;
  end;
  name:= getorigname;
  uppername:= uppercase(name);
  result:= parseprocparams(params.kind,params.params);
  if result then begin
   intendpos:= sourcepos;
  end;
 end;
end;

function tpascaldesignparser.parseclassprocedureheader(atoken: pascalidentty;
                   classinfopo: pclassinfoty): boolean;
var
 po1: pprocedureinfoty;
 token1: tokenidty;
 pos1,pos2: sourceposty;

begin
 with classinfopo^ do begin
  po1:= procedurelist.newitem;
  token1:= acttoken;
  result:= parseprocedureheader(atoken,po1);
  pos2:= sourcepos;
  if result then begin
   while true do begin
    case pascalidentty(getclassident) of
     id_abstract: include(po1^.params.flags,mef_abstract);
     id_inherited: include(po1^.params.flags,mef_inherited);
     id_overload: include(po1^.params.flags,mef_overload);
     id_override: include(po1^.params.flags,mef_override);
     id_virtual: include(po1^.params.flags,mef_virtual);
     id_invalid: break;
    else
     lasttoken;
     break;
    end;
    if not checkoperator(';') then begin
     break;
    end;
   end;
   if isemptysourcepos(procedurestart) then begin
    procedurestart:= po1^.intinsertpos;
   end;
   pos1:= getsourcepos(token1);
   dec(pos1.offset,pos1.pos.col);
   pos1.pos.col:= 0;
   funitinfopo^.deflist.add(pos1,pos2,po1);
  end
  else begin
   procedurelist.deletelast;
  end;
 end;
end;

function tpascaldesignparser.skipprocedureparams(atoken: pascalidentty): boolean;
var
 ar1: paraminfoarty;
begin
 case atoken of
  id_procedure: begin
   result:= parseprocparams(mkprocedure,ar1);
  end;
  id_function: begin
   result:= parseprocparams(mkfunction,ar1);
  end
  else begin
   result:= false;
  end;
 end;
end;

function tpascaldesignparser.skipprocedureheader(atoken: pascalidentty): boolean;
var
 lstr1: lstringty;
begin
 if getnamenoident(lstr1) then begin
  result:= skipprocedureparams(atoken);
 end
 else begin
  result:= false;
 end;
end;

function tpascaldesignparser.parseinterfacetype: boolean;
var
 value: lstringty;
 ident1: pascalidentty;
begin
 result:= getorignamenoident(value) and checkoperator('=') and
      checkident(integer(id_interface));
 if result then begin
  while not eof do begin
   ident1:= pascalidentty(getident);
   case ident1 of
    id_end,id_implementation: begin
     break;
    end;
    id_procedure,id_function: begin
     skipprocedureheader(ident1);
    end;
    else begin
     nexttoken;
    end;
   end;
  end;
 end;
end;

function tpascaldesignparser.parseclasstype: boolean;
var
 value: lstringty;
 ar1: lstringarty;
 classinfopo: pclassinfoty;
 pos1: sourceposty;
 ident1: pascalidentty;
 lstr1,lstr2: lstringty;
 pc,pc1: pcompinfoty;
 pd: pdefinfoty;
 bo1: boolean;
 token1: tokenidty;
 first: boolean;
 int1: integer;

begin
 ar1:= nil; //compiler warning
 token1:= acttoken;
 result:= getorignamenoident(value) and checkoperator('=') and 
                  checkident(integer(id_class));
 if result then begin
  if checkoperator(';') then begin
   lasttoken;           //forward declaration
  end
  else begin
   if checkident(integer(id_of)) then begin
    result:= false;     //type of class
    exit;
   end;
   classinfopo:= funitinfopo^.classinfolist.newitem;
   with classinfopo^ do begin
    inimplementation:= fimplementation;
    managedstart:= lasttokenpos;
    name:= lstringtostring(value);
    uppername:= uppercase(name);
    if checkoperator('(') then begin
     ar1:= getnamelist;
     result:= checkoperator(')');
    end
    else begin
     ar1:= nil;
    end;
    headerstop:= getsourcepos(acttoken);
    if ar1 <> nil then begin
     parentname:= lstringtostring(ar1[0]);
    end
    else begin
     parentname:= 'TObject';
    end;
    if result then begin
     deflist:= funitinfopo^.deflist.beginnode(getsourcepos(token1),classinfopo);
     first:= true;
     while not eof do begin
      ident1:= getclassident;
      case ident1 of
       id_end,id_private,id_protected,id_public,id_published,id_automated,
           id_implementation: begin
        if isemptysourcepos(managedend) then begin
         managedend:= lasttokenpos;
        end;
        if isemptysourcepos(procedurestart) then begin
         procedurestart:= managedend;
        end;
        if (ident1 = id_private) then begin
         if isemptysourcepos(privatestart) then begin
          privatestart:= sourcepos;
         end;
        end
        else begin
         if not isemptysourcepos(privatestart) and 
                            isemptysourcepos(privateend) then begin
          privateend:= lasttokenpos;
          if isemptysourcepos(privatefieldend) then begin
           privatefieldend:= privateend;
          end;
         end;
        end;
        if ident1 = id_end then begin
         break;
        end;
       end;
       id_procedure,id_function,id_constructor,id_destructor: begin
        if isemptysourcepos(privatefieldend) and 
                     not isemptysourcepos(privatestart) and 
                     isemptysourcepos(privateend) then begin
         privatefieldend:= lasttokenpos;
        end;
        parseclassprocedureheader(ident1,classinfopo);
       end;
       else begin
        pos1:= sourcepos;
        ar1:= getorignamelist;
//        if getorigname(lstr1) then begin
        if high(ar1) >= 0 then begin
         if isemptysourcepos(managedend) and (ident1 <> id_property) then begin
          pc:= componentlist.newitem; //managed component
          bo1:= false;
          with pc^ do begin
           insertpos:= lasttokenpos;
           namepos:= pos1;
           nameend:= sourcepos;
           if checkoperator(':') then begin
            skipwhitespace;
            typepos:= sourcepos;
            if getorigname(lstr2) then begin
             typeend:= sourcepos;
             name:= lstringtostring(ar1[0]);
             uppername:= uppercase(name);
             typename:= lstringtostring(lstr2);
             uppertypename:= uppercase(typename);
             checkoperator(';');
             checknewline;
             endpos:= sourcepos;
             bo1:= true;
             funitinfopo^.deflist.add(name,syk_vardef,namepos,endpos);
            end;
           end;
          end;
          if not bo1 then begin
           componentlist.deletelast;
           nexttoken;
          end
          else begin
           for int1:= 1 to high(ar1) do begin
            pc1:= componentlist.newitem; //managed component
            pc1^:= pc^;
            pc1^.name:= lstringtostring(ar1[int1]);
            pc1^.uppername:= uppercase(pc1^.name);
           end;
          end;         
         end
         else begin
          if ident1 = id_property then begin
           if checkoperator('[') then begin
            while not eof and not checkoperator(']') do begin
             nexttoken;
            end;
           end;
          end;
          if checkoperator(':') then begin
           while not eof and not checkoperator(';') do begin
            nexttoken;
           end;
           pd:= funitinfopo^.deflist.add(lstringtostring(ar1[0]),
                      syk_vardef,pos1,sourcepos);
           if ident1 = id_property then begin
            pd^.varflags:= [vf_property];
           end;
           for int1:= 1 to high(ar1) do begin
            funitinfopo^.deflist.add(lstringtostring(ar1[int1]),
                      syk_vardef,pos1,sourcepos)            
           end;
          end;
         end;
        end
        else begin
         if first and (getoperator = ';') then begin
          break; //xxx = class(tclassxx);
         end;
         nexttoken;
        end;
       end;
      end;
      first:= false;
     end;
     if result then begin
      funitinfopo^.deflist.endnode(sourcepos);
     end
     else begin
      funitinfopo^.deflist.deletenode;
     end;
    end;
   end;
   if not result then begin
    funitinfopo^.classinfolist.deletelast;
   end;
  end;
 end;
end;

function tpascaldesignparser.parserecord: boolean;
                //todo: parse subitems
var
 ident1: pascalidentty;
 blocklevel: integer;
begin
 result:= true;
 blocklevel:= 1;
 while not eof and (blocklevel > 0) do begin
  ident1:= pascalidentty(getident);
  case ident1 of
   id_end: begin
    dec(blocklevel)
   end;
   id_begin,id_record: begin
    inc(blocklevel)
   end;
  end;
  nexttoken;
 end;
end;

procedure tpascaldesignparser.parselabel;
var
 ident1: pascalidentty;
begin
 while not eof do begin
  skipwhitespace;
  ident1:= pascalidentty(getident);
  case ident1 of
   id_type,id_const,id_var,id_implementation,id_function,id_procedure,
                    id_constructor,id_destructor,id_begin: begin
    lasttoken;
    break;
   end;
   id_label: begin
   end;
   else begin
    nexttoken;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parsetype;
var
 statementstart: tokenidty;
 ident1: pascalidentty;
 lstr1: lstringty;
begin
 while not eof do begin
  skipwhitespace;
  statementstart:= acttoken;
  ident1:= pascalidentty(getident);
  case ident1 of
   id_label,id_const,id_var,id_implementation,id_function,id_procedure,
                    id_constructor,id_destructor,id_begin: begin
    lasttoken;
    break;
   end;
   id_type: begin
   end;
   else begin
    if (ident1 = id_invalid) and getorigname(lstr1) and checkoperator('=') then begin
     ident1:= pascalidentty(getident);
     case ident1 of
      id_interface: begin
       mark;
       acttoken:= statementstart;
       if parseinterfacetype then begin
        pop;
       end
       else begin
        back;
       end;
      end;
      id_class: begin
       mark;
       acttoken:= statementstart;
       if parseclasstype then begin
        pop;
       end
       else begin
        back;
       end;
      end;
      id_record: begin
       parserecord;
       funitinfopo^.deflist.add(lstringtostring(lstr1),syk_typedef,
                  getsourcepos(statementstart),sourcepos);
      end;
      id_procedure,id_function: begin
       skipprocedureparams(ident1);
      end;
      else begin
       while not eof and not checkoperator(';') do begin
        nexttoken;
       end;
       funitinfopo^.deflist.add(lstringtostring(lstr1),syk_typedef,
                  getsourcepos(statementstart),sourcepos);
      end;
     end;
    end
    else begin
     nexttoken; //invalid
    end;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parseconst;
var
 ident1: integer;
 apos: sourceposty;
 str1: string;

begin
 while not eof do begin
  ident1:= getident;
  if ident1 >= 0 then begin
   lasttoken;
   break;
  end;
  if (fto^.kind = tk_name) then begin
   apos:= sourcepos;
   str1:= self.getorigtoken;
   if checkoperator('=') then begin
            //todo: parse typed constants
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
    funitinfopo^.deflist.add(str1,syk_constdef,apos,sourcepos);
   end
   else begin
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
   end;
  end
  else begin
   nexttoken;
  end;
 end;
end;

procedure tpascaldesignparser.parsevar;
var
 ident1: integer;
 apos: sourceposty;
 ar1: lstringarty;
 int1: integer;

begin
 while not eof do begin
  ident1:= getident;
  if (ident1 >= 0) and (ident1 <> ord(id_threadvar)) then begin
   lasttoken;
   break;
  end;
  if fto^.kind = tk_name then begin
   apos:= sourcepos;
   ar1:= getorignamelist;
   if checkoperator(':') then begin
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
    for int1:= 0 to high(ar1) do begin
     funitinfopo^.deflist.add(lstringtostring(ar1[int1]),syk_vardef,
                                     apos,sourcepos);
    end;
   end
   else begin
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
   end;
  end
  else begin
   nexttoken;
  end;
 end;
end;

procedure tpascaldesignparser.parseprocedurebody;

 procedure getidentinfo;
 var
  bracketlevel: integer;
  pos1: sourceposty;
 begin
  funitinfopo^.deflist.factnode.startident(self);
  while checkoperator('.') do begin
   skipwhitespace;
   if fto^.kind = tk_name then begin
    funitinfopo^.deflist.factnode.addident(self);
   end
   else begin
    funitinfopo^.deflist.factnode.addemptyident(self);
   end; 
  end;
  if checkoperator('(') then begin
   mark;
   bracketlevel:= 0;
   while not eof and (bracketlevel >= 0) do begin
    if checkoperator('(') then begin
     inc(bracketlevel);
    end
    else begin
     if checkoperator(')') then begin
      dec(bracketlevel);
     end
     else begin
      nexttoken;
     end;
    end;
   end;
   pos1:= sourcepos;
   back;
   funitinfopo^.deflist.factnode.endident(self,pos1);
  end
  else begin
   skipwhitespace;
   funitinfopo^.deflist.factnode.endident(self);
  end;
 end;

var
 blocklevel: integer;
 aident: integer;
 str1: string;

begin
 blocklevel:= 0;
 while not eof and (blocklevel >= 0) do begin
  if getident(aident) then begin
   case pascalidentty(aident) of
    id_begin,id_try,id_case: begin
     inc(blocklevel);
    end;
    id_end: begin
     dec(blocklevel);
    end;
   end;
  end
  else begin
   if (fto^.kind = tk_name) then begin
    getidentinfo;
   end
   else begin
    if (fto^.kind = tk_operator) and (fto^.op = '''') and
             getpascalstring(str1) then begin

    end
    else begin
     nexttoken;
    end;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parseimplementation;

var
 procnestinglevel: integer;
 
 procedure parseprocedure(const akind: tmethodkind);
 var
  classname,procname: lstringty;
  pos1: sourceposty;
  po1: pclassinfoty;
  po2: pprocedureinfoty;
  po3: pdefinfoty;
  methodinfo: methodparaminfoty;
  aident: integer;
  deflist1: tdeflist;
  
   procedure setprocinfo(const ainfo: pprocedureinfoty);
   var
    lstr1: lstringty;
   begin
    with ainfo^ do begin
     params:= methodinfo;
     lstr1:= procname;
     inc(lstr1.po,scanner.origoffset);
     name:= lstringtostring(lstr1);
     uppername:= lstringtostring(procname);
    end;
   end;

 begin
  if procnestinglevel < 32 then begin
   inc(procnestinglevel);
   lasttoken;
   pos1:= sourcepos;
   nexttoken;
   if getname(procname) then begin
    if checkoperator('.') then begin
     classname:= procname;
     getname(procname);
     po1:= funitinfopo^.classinfolist.finditembyname(classname,false);
     if (po1 <> nil) and isemptysourcepos(po1^.procimpstart) then begin
      po1^.procimpstart:= pos1;
     end;
    end
    else begin
     po1:= nil;
    end;
    methodinfo.kind:= akind;
    if parseprocparams(akind,methodinfo.params) then begin
     if po1 <> nil then begin
      po3:= funitinfopo^.deflist.beginnode(
                lstringtostring(classname)+'.'+lstringtostring(procname)+
                     mangleprocparams(methodinfo),
                            syk_classprocimp,pos1,sourcepos);
      deflist1:= po3^.deflist;
      po2:= po1^.procedurelist.finditembyuppername(procname,methodinfo);
      if po2 = nil then begin
       po2:= po1^.procedurelist.newitem;
       setprocinfo(po2);
      end;
      if po2 <> nil then begin
       po2^.impheaderstartpos:= pos1;
       po2^.impheaderendpos:= sourcepos;
      end;
      po3^.procindex:= po2^.b.index;
      deflist1.fparentscope:= po1^.deflist;
     end
     else begin
      po2:= funitinfopo^.procedurelist.finditembyuppername(procname,methodinfo);
      if po2 = nil then begin
       po2:= funitinfopo^.procedurelist.newitem;
       setprocinfo(po2)
      end;
      po3:= funitinfopo^.deflist.beginnode(
                lstringtostring(procname)+mangleprocparams(methodinfo),
                syk_procimp1,pos1,sourcepos);
      deflist1:= po3^.deflist;
      po3^.procindex:= po2^.b.index;
      po2:= nil;
     end;
     while not eof do begin
      if getident(aident) then begin
       case pascalidentty(aident) of
        id_var: begin
         parsevar;
        end;
        id_const: begin
         parseconst;
        end;
        id_type: begin
         parsetype;
        end;
        id_label: begin
         parselabel;
        end;
        id_procedure: begin
         parseprocedure(mkprocedure);
        end;
        id_function: begin
         parseprocedure(mkfunction);
        end;
        id_begin: begin
         parseprocedurebody;
         break;
        end;
        else begin
         break;
        end;
       end;
      end
      else begin
       nexttoken;
      end;
     end;
     checkoperator(';');
     checknewline;
     pos1:= sourcepos;
     funitinfopo^.deflist.endnode(pos1);
     if po1 <> nil then begin
      po1^.procimpend:= pos1;
      if po2 <> nil then begin
       po2^.impendpos:= po1^.procimpend;
      end;
     end;
    end;
   end;
   dec(procnestinglevel);
  end;
 end;

  procedure checkend;
  begin
   if isemptysourcepos(funitinfopo^.implementationend) then begin
    lasttoken;
    funitinfopo^.implementationend:= sourcepos;
    nexttoken;
   end;
  end;

var
 aident: integer;
 pos1: sourceposty;
 
begin
 finterface:= false;
 fimplementation:= true;
 funitinfopo^.implementationstart:= sourcepos;
 procnestinglevel:= 0;
 while not eof do begin
  if getident(aident) then begin;
   case pascalidentty(aident) of
    id_procedure: begin
     parseprocedure(mkprocedure);
    end;
    id_function: begin
     parseprocedure(mkfunction);
    end;
    id_constructor: begin
     parseprocedure(mkconstructor);
    end;
    id_destructor: begin
     parseprocedure(mkdestructor);
    end;
    id_type: begin
     parsetype;
    end;
    id_var: begin
     parsevar;
    end;
    id_uses: begin
     with funitinfopo^.implementationuses do begin
      fstartpos:= sourcepos;
      add(getorignamelist);
      fendpos:= sourcepos;
     end;
    end;
    id_begin: begin
     if funitinfopo^.isprogram then begin
      parseprocedurebody;
     end;
    end;
    id_initialization: begin
     checkend;
     funitinfopo^.initializationstart:= nexttokenornewlinepos;
    end;
    id_finalization: begin
     checkend;
     funitinfopo^.finalizationstart:= nexttokenornewlinepos;
    end;
    id_end: begin
     if checkoperator('.') then begin
      lasttoken;
      checkend;
      nexttoken;
      break;
     end;
    end;
   end;
  end
  else begin
   nexttoken;
  end;
 end;
 funitinfopo^.unitend:= sourcepos;
end;

procedure tpascaldesignparser.parse;
var
 int1: integer;
 po1: pprocedureinfoty;
 pos1: sourceposty;
begin
 inherited parse;
 if fnoautoparse then begin
  exit;
 end;
 with funitinfopo^ do begin
  interfacecompiled:= false;
  implementationcompiled:= false;
  isprogram:= false;
  freeandnil(itemlist);
  deflist.clear;
  procedurelist.clear;
  classinfolist.clear;
  interfaceuses.clear;
  implementationuses.clear;
  unitname:= '';
  origunitname:= '';
//  formfilename: filenamety;
//   sourcefilename: filenamety;
  implementationstart.filenum:= 0;
  implementationend.filenum:= 0;
  unitend.filenum:= 0;
  initializationstart.filenum:= 0;
  finalizationstart.filenum:= 0;
  sourceend.filenum:= 0;
  sourcefiles:= nil;
  includestatements:= nil;

  int1:= getident;
  isprogram:= pascalidentty(int1) = id_program;
  if isprogram or (pascalidentty(int1) = id_unit) then begin
   origunitname:= getorigname;
   unitname:= uppercase(origunitname);
  end;
  if isprogram then begin
   parseimplementation;
  end
  else begin
   while not eof do begin
    int1:= getident;
    case pascalidentty(int1) of
     id_type: begin
      parsetype;
     end;
     id_const: begin
      parseconst;
     end;
     id_var: begin
      parsevar;
     end;
     id_procedure,id_function: begin
      po1:= procedurelist.newitem;
      pos1:= lasttokenpos;
      if parseprocedureheader(pascalidentty(int1),po1) then begin
       deflist.add(pos1,sourcepos,po1);
      end
      else begin
       procedurelist.deletelast;
      end;
     end;
     id_interface: begin
      finterface:= true;
     end;
     id_uses: begin
      with funitinfopo^.interfaceuses do begin
       fstartpos:= sourcepos;
       add(getorignamelist);
       fendpos:= sourcepos;
      end;
     end;
     id_implementation: begin
      if not finterfaceonly then begin
       parseimplementation;
      end;
      break;
     end;
     else begin
      nexttoken;
     end;
    end;
   end;
  end;
  interfacecompiled:= true;
  if isprogram or not finterfaceonly then begin
   implementationcompiled:= true;
  end;
  sourceend:= sourcepos;
  setlength(sourcefiles,length(fscanners));
  for int1:= 0 to high(fscanners) do begin
   sourcefiles[int1].filename:= fscanners[int1].filename;
   sourcefiles[int1].startline:= fscanners[int1].startline;
   sourcefiles[int1].count:= fscanners[int1].count;
   sourcefiles[int1].includecount:= fscanners[int1].includecount;
  end;
 end;
end;

function tpascaldesignparser.dogetincludefile(const afilename: filenamety;
  const astatementstart, astatementend: sourceposty): tscanner;
begin
 result:= inherited dogetincludefile(afilename,astatementstart,astatementend);
 if result <> nil then begin
  with funitinfopo^ do begin
   setlength(includestatements,high(includestatements)+2);
   with includestatements[high(includestatements)] do begin
    filename:= afilename;
    startpos:= astatementstart;
    endpos:= astatementend;
   end;
  end;
 end;
end;

{ tdeflist }

constructor tdeflist.create(const akind: symbolkindty);
begin
 fkind:= akind;
 inherited create(sizeof(defnamety),[rels_needsfinalize]);
end;

procedure tdeflist.clear;
begin
 inherited;
 finfocount:= 0;
 finfos:= nil;
end;

function tdeflist.incinfocount: integer;
begin
 result:= finfocount;
 inc(finfocount);
 if length(finfos) < finfocount then begin
  setlength(finfos,finfocount + 4 + finfocount div 4);
 end;
end;

function tdeflist.add(const aname: string; const akind: symbolkindty;
                          const apos,astop: sourceposty): pdefinfoty;
var
 po1: pdefnamety;
begin
 po1:= newitem;
 po1^.name:= struppercase(aname);
 po1^.id:= incinfocount;
 result:= @finfos[po1^.id];
 with result^ do begin
  name:= aname;
  kind:= akind;
  pos:= apos;
  stop1:= astop;
 end;
end;

function tdeflist.add(const akind: symbolkindty; const apos,astop: sourceposty): pdefinfoty;
                     //statment
var
 int1: integer;
begin
 int1:= incinfocount;
 result:= @finfos[int1];
 with result^ do begin
  kind:= akind;
  pos:= apos;
  stop1:= astop;
 end;
end;

procedure tdeflist.startident(const aparser: tparser);
begin
 with add(syk_identuse,aparser.sourcepos,emptysourcepos)^ do begin
  identflags:= [if_first];
  identlen:= aparser.token^.value.len;
  stop1:= pos;
  inc(stop1.pos.col,identlen);
 end;
 aparser.nexttoken;
end;

procedure tdeflist.addident(const aparser: tparser);
begin
 with add(syk_identuse,aparser.sourcepos,emptysourcepos)^ do begin
  identlen:= aparser.token^.value.len;
  stop1:= pos;
  inc(stop1.pos.col,identlen);
 end;
 aparser.nexttoken
end;

procedure tdeflist.addemptyident(const aparser: tparser);
begin
 aparser.lasttoken;
 with add(syk_identuse,aparser.sourcepos,emptysourcepos)^ do begin
  aparser.nexttoken;
  stop1:= aparser.sourcepos;
 end;
end;

procedure tdeflist.endident(const aparser: tparser);
begin
 with finfos[finfocount-1] do begin
  include(finfos[finfocount-1].identflags,if_last);
  stop1:= aparser.sourcepos;
 end;
end;

procedure tdeflist.endident(const aparser: tparser; const endpos: sourceposty);
begin
 with finfos[finfocount-1] do begin
  include(identflags,if_last);
  stop1:= endpos;
 end;
end;

function tdeflist.addidents(const aparser: tparser): boolean;
var
 ident1: integer;
begin
 with aparser do begin
  ident1:= getident;
  if (token^.kind = tk_name) and (ident1 < 0) then begin
   startident(aparser);
   while checkoperator('.') do begin
    ident1:= getident;
    if (token^.kind = tk_name) and (ident1 < 0) then begin
     addident(aparser);
    end
    else begin
     break;
    end;
   end;
   endident(aparser);
   result:= true;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tdeflist.finddef(const anamepath: stringarty; var scopes: deflistarty;
               var defs: definfopoarty;
               const first: boolean; // break on first found
               const level: defsearchlevelty;
               const afindkind: symbolkindty = syk_none;
               const maxcount: integer = bigint): boolean;
               //true if found
var
 ar1: stringarty;
 ar2: deflistarty;
 ar3: definfopoarty;
 findkind1: symbolkindty;
// po1: pdefinfoty;
 ar4: definfopoarty;
 int1: integer;

begin
 result:= false;
 if first then begin
  scopes:= nil;
  defs:= nil;
 end;
 if high(anamepath) >= 0 then begin
  setlength(ar4,1);
  if high(anamepath) > 0 then begin
   findkind1:= syk_none;
   ar4[0]:= find(anamepath[0],findkind1);
   if ar4[0] = nil then begin
    ar4[0]:= find(anamepath[0],syk_nopars);
   end;
  end
  else begin
   findkind1:= afindkind;
   if first then begin
    ar4[0]:= find(anamepath[0],findkind1);
   end
   else begin
    ar4:= getmatchingitems(anamepath[0],findkind1);
    additem(pointerarty(ar4),nil);
   end;
  end;
  for int1:= 0 to high(ar4) do begin
   if (ar4[int1] = nil) and (fkind = syk_classdef) and
                               (name <> 'TOBJECT') then begin
           //search parent class
//    setlength(ar1,1);
//    ar1[0]:= fparentident;
//    if rootlist.finddef(ar1,ar2,ar3,true,dsl_parentclass,syk_classdef) and
//                       (ar3[0]^.kind = syk_classdef) then begin
    if rootlist.findparentclass(self,ar3) and (ar3[0]^.kind = syk_classdef) then begin
     if ar3[0]^.deflist.finddef(anamepath,scopes,defs,first,dsl_inclass,
                  afindkind,maxcount) then begin
      result:= true;
      if first then begin
       continue;
      end;
     end;
    end;
   end;
   if ar4[int1] = nil then begin
    if (level in [dsl_normal,dsl_parent]) and (fparentscope <> nil) then begin
     result:= fparentscope.finddef(anamepath,scopes,defs,first,dsl_parent,
                 afindkind,maxcount) or result;
    end;
//    if (not result or not first) and (level = dsl_normal) and
//            (fkind in [syk_procimp1,syk_classprocimp]) then begin
//     result:= rootlist.finddef(anamepath,scopes,defs,first,level,afindkind) or result;
//    end;
    if first then begin
     continue;
    end;
   end
   else begin
    if (ar4[int1]^.kind in [syk_vardef,syk_procdef,syk_procimp1]) and (high(anamepath) > 0) then begin
     ar1:= sourceupdater.gettype(ar4[int1]);
     stackarray(copy(anamepath,1,bigint),ar1);
     sourceupdater.resetunitsearched;
     result:= finddef(ar1,scopes,defs,first,dsl_normal,afindkind,maxcount) or result;
     continue;
    end
    else begin
     if high(anamepath) > 0 then begin
      if ar4[int1]^.deflist <> nil then begin
       result:= ar4[int1]^.deflist.finddef(copy(anamepath,1,bigint),
                scopes,defs,first,dsl_child,afindkind,maxcount) or result;
      end;
     end
     else begin
      result:= true;
      if high(defs) <= maxcount then begin
       additem(pointerarty(scopes),self);
       additem(pointerarty(defs),ar4[int1]);
      end
      else begin
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tdeflist.finddef(const aname: string; const afindkind: symbolkindty;
               out ascope: tdeflist): pdefinfoty;
var
 scopes: deflistarty;
 defs: definfopoarty;
begin
 if finddef(splitidentpath(aname),scopes,defs,true,
                                    dsl_normal,afindkind) then begin
  ascope:= scopes[0];
  result:= defs[0];
 end
 else begin
  result:= nil;
 end;
end;

function tdeflist.internalfinditem(const apos: sourceposty; 
         const firstidentuse,last: boolean; out scope: tdeflist): pdefinfoty;
var
 int1,int2: integer;
begin
 if firstidentuse and last then begin
  int2:= -1;
  for int1:= 0 to finfocount - 1 do begin
   with finfos[int1] do begin
    if (kind = syk_identuse) and ((stop1.line > apos.line) or
       (stop1.line = apos.line) and (stop1.pos.col > apos.pos.col)) then begin
     int2:= int1;
     break;
    end;
   end;
  end;
 end
 else begin
  int2:= finfocount;
  for int1:= 0 to finfocount - 1 do begin
   with finfos[int1] do begin
    if (kind > syk_deleted) then begin
     if (pos.line > apos.line) or
       ((pos.line = apos.line) and (pos.pos.col > apos.pos.col)) then begin
      int2:= int1;
      if (kind = syk_identuse) and not (if_first in identflags) then begin
       with finfos[int1-1] do begin
        if (apos.line > pos.line) or (apos.pos.col > pos.pos.col + identlen) then begin
         inc(int2); //before next word
        end;
       end;
      end;
      break;
     end;
    end;
   end;
  end;
  dec(int2);
  while (int2 >= 0) and (finfos[int2].kind <= syk_deleted) do begin
   dec(int2);
  end;
 end;
 if int2 >= 0 then begin
  with finfos[int2] do begin
   case kind of
    syk_vardef,syk_constdef: begin
     if (stop1.line < apos.line) or (stop1.line = apos.line) and
                 (stop1.pos.col <= apos.pos.col) then begin
      int2:= -1;
     end;
    end;
    syk_identuse: begin
     if (if_last in identflags) and
              ((stop1.line < apos.line) or
                 (stop1.line = apos.line) and
                 (stop1.pos.col <= apos.pos.col)) then begin
      int2:= -1;
     end;
    end;
    else begin
     if (deflist <> nil) and
      ((deflist.fstop.line < apos.line) or (deflist.fstop.line = apos.line) and
                 (deflist.fstop.pos.col <= apos.pos.col)) then begin
      int2:= -1;
     end;
    end;
   end;
  end;
 end;
 if int2 >= 0 then begin
  if finfos[int2].deflist <> nil then begin
   result:= finfos[int2].deflist.internalfinditem(apos,firstidentuse,false,scope);
  end
  else begin
   if firstidentuse and not last then begin
    result:= internalfinditem(apos,firstidentuse,true,scope);
   end
   else begin
    scope:= self;
    result:= @finfos[int2];
   end;
  end;
 end
 else begin
  if fparent <> nil then begin
   scope:= fparentscope;
   result:= @fparent.finfos[fparentid];
  end
  else begin
   scope:= self;
   result:= nil;
  end;
 end;
end;

function tdeflist.finditem(const apos: sourceposty; 
         const firstidentuse: boolean; out scope: tdeflist): pdefinfoty;
begin
 result:= internalfinditem(apos,firstidentuse,false,scope);
end;

procedure tdeflist.finalizerecord(var item);
begin
 freeandnil(finfos[defnamety(item).id].deflist);
 finalize(defnamety(item));
end;
{
procedure tdeflist.comp(const l,r; out result: integer);
var
 int1: integer;
begin
 result:= (length(defnamety(l).name) -
             length(defnamety(r).name)) shl 16;
 if result = 0 then begin
  for int1:= length(defnamety(l).name) - 1 downto 0 do begin
   result:= integer(pcharaty(defnamety(l).name)^[int1]) -
            integer(pcharaty(defnamety(r).name)^[int1]);
   if result <> 0 then begin
    break;
   end;
  end;
 end;
end;
}
procedure tdeflist.comp(const l,r; out result: integer);
var
 po1,po2: pchar;
 ch1: shortint;
begin
 po1:= pchar(defnamety(l).name); //searchvalue
 po2:= pchar(defnamety(r).name); //tableitems
 repeat
  ch1:= shortint(po1^) - shortint(po2^);
  if (ch1 <> 0) or (po1^ = #0) then begin
   break;
  end;
  inc(po2);
  inc(po1);
 until false;
 result:= ch1;
end;

procedure tdeflist.compnopars(const l,r; out result: integer);
var
 po1,po2: pchar;
 ch1: shortint;
begin
 po1:= pchar(defnamety(l).name); //searchvalue
 po2:= pchar(defnamety(r).name); //tableitems
 repeat
  ch1:= shortint(po1^) - shortint(po2^);
  if (ch1 <> 0) or (po1^ = #0) then begin
   break;
  end;
  inc(po2);
  inc(po1);
  if po2^ = '$' then begin
   if (po1^ = #0) or (po1^ = '$') then begin
    break;
   end;
  end;
 until false;
 result:= ch1;
end;

procedure tdeflist.compsubstr(const l,r; out result: integer);
var
 po1,po2: pchar;
 ch1: shortint;
begin
 po1:= pchar(defnamety(l).name); //searchvalue
 po2:= pchar(defnamety(r).name); //tableitems
 ch1:= 0;
 repeat
  if (po1^ = #0) then begin
   break;
  end;
  ch1:= shortint(po1^) - shortint(po2^);
  if (ch1 <> 0) then begin
   break;
  end;
  inc(po2);
  inc(po1);
 until false;
 result:= ch1;
end;

function tdeflist.getcompareproc: compareprocty;
begin
 result:= {$ifdef FPC}@{$endif}comp;
end;

function tdeflist.getname: string;
begin
 if fparent = nil then begin
  result:= '';
 end
 else begin
  result:= fparent.finfos[fparentid].name;
 end;
end;

function tdeflist.getdefinfopo: pdefinfoty;
begin
 if fparent = nil then begin
  result:= nil;
 end
 else begin
  result:= @fparent.finfos[fparentid];
 end;
end;

function tdeflist.getrootlist: trootdeflist;
begin
 result:= trootdeflist(self);
 while result.fparent <> nil do begin
  result:= trootdeflist(result.fparent);
 end;
end;

function tdeflist.find(const aname: string;
                    const akind: symbolkindty = syk_none): pdefinfoty;
var
 int1,int2: integer;
 str1: string;
label
 exit1;
begin
 result:= nil;
 str1:= struppercase(aname);
 sorted:= true;
 if akind = syk_nopars then begin
  fcompareproc:= {$ifdef FPC}@{$endif}compnopars;
 end
 else begin
  if akind = syk_substr then begin
   fcompareproc:= {$ifdef FPC}@{$endif}compsubstr;
  end
 end;
 if internalfind(str1,int1) then begin
  if akind > syk_deleted then begin
   while finfos[pdefnameaty(fdata)^[int1].id].kind <> akind do begin
    dec(int1);
    if (int1 < 0) then begin
     goto exit1;
    end;
    comp(str1,pdefnameaty(fdata)^[int1].name,int2);
    if (int2 <> 0) then begin
     goto exit1;
    end;
   end;
  end;
  result:= @finfos[pdefnameaty(fdata)^[int1].id];
 end;
exit1:
 fcompareproc:= {$ifdef FPC}@{$endif}comp;
end;

function tdeflist.getmatchingitems(const aname: string;
                    const akind: symbolkindty = syk_none): definfopoarty;
var
 int1,int2: integer;
 str1: string;
 po1: pdefinfoty;
begin
 result:= nil;
 str1:= struppercase(aname);
 sorted:= true;
 if akind = syk_nopars then begin
  fcompareproc:= {$ifdef FPC}@{$endif}compnopars;
 end
 else begin
  if akind = syk_substr then begin
   fcompareproc:= {$ifdef FPC}@{$endif}compsubstr;
  end
 end;
 if internalfind(str1,int1) then begin
  while (int1 >= 0) do begin
   fcompareproc(str1,pdefnameaty(fdata)^[int1],int2);
   if int2 <> 0 then begin
    break;
   end;
   po1:= @finfos[pdefnameaty(fdata)^[int1].id];
   if po1^.kind <> syk_deleted then begin
    additem(pointerarty(result),po1);
   end;
   dec(int1);
  end;
 end;
 fcompareproc:= {$ifdef FPC}@{$endif}comp;
end;

{ trootdeflist}

constructor trootdeflist.create(const aunitinfopo: punitinfoty);
begin
 funitinfopo:= aunitinfopo;
 factnode:= self;
 inherited create(syk_root);
end;

procedure trootdeflist.clear;
begin
 inherited;
 factnode:= self;
end;

function trootdeflist.beginnode(const aname: string; const akind: symbolkindty;
                        const apos,astop: sourceposty): pdefinfoty;
begin
 result:= factnode.add(aname,akind,apos,astop);
 with result^ do begin
  deflist:= tdeflist.create(akind);
  deflist.fparent:= factnode;
  deflist.fparentid:= factnode.count - 1;
  deflist.fparentscope:= factnode;
  deflist.fstart:= apos;
  factnode:= deflist;
 end;
end;

procedure trootdeflist.endnode(const apos: sourceposty);
begin
 factnode.fstop:= apos;
 factnode:= factnode.fparent;
end;

procedure trootdeflist.deletenode;
begin
 with finfos[high(finfos)] do begin
  freeandnil(deflist);
  kind:= syk_deleted;
 end;
end;

function trootdeflist.beginnode(const apos: sourceposty;
         const aclassinfo: pclassinfoty): tdeflist;
begin
 with beginnode(aclassinfo^.uppername,syk_classdef,apos,aclassinfo^.headerstop)^ do begin
  classindex:= aclassinfo^.b.index;
  deflist.fparentident:= aclassinfo^.parentname;
  result:= deflist;
 end;
end;
{
procedure trootdeflist.selectnode(const anode: tdeflist);
begin
 factnode:= anode;
end;

procedure trootdeflist.popnode;
begin
 factnode:= factnode.fparent;
 if factnode = nil then begin
  factnode:= self;
 end;
end;
}
function trootdeflist.add(const aname: string; const akind: symbolkindty;
                    const astart,astop: sourceposty): pdefinfoty;
begin
 result:= factnode.add(aname,akind,astart,astop);
end;

function trootdeflist.add(const apos,astop: sourceposty; 
         const aprocinfo: pprocedureinfoty): pdefinfoty;
begin
 result:= factnode.add(aprocinfo^.name+mangleprocparams(aprocinfo^.params),
                 syk_procdef,apos,astop);
 result^.procindex:= aprocinfo^.b.index;
end;

function trootdeflist.finddef(const anamepath: stringarty; var scopes: deflistarty;
               var defs: definfopoarty;
               const first: boolean; // break if first found
               const level: defsearchlevelty;
               const afindkind: symbolkindty = syk_none;
               const maxcount: integer = bigint): boolean;
               //true if found

 function unitsearch(alist: trootdeflist): boolean;
 begin
  if (alist <> nil) and not (alist.allreadysearched and
                  (level in [dsl_normal,dsl_parent])) then begin
   if level in [dsl_normal,dsl_parent] then begin
    trootdeflist(alist).allreadysearched:= true;
   end;
   result:= alist.finddef(anamepath,scopes,defs,first,dsl_unitsearch,afindkind,maxcount);
  end
  else begin
   result:= false;
  end;
 end;

var
 int1: integer;
 alist: trootdeflist;
 po1: punitinfoty;
begin
 result:= false;
 if high(anamepath) >= 0 then begin
  if (level in [dsl_normal,dsl_parent]) and (high(anamepath) > 0) then begin
        //check qualified
   if stringicomp(anamepath[0],funitinfopo^.unitname) = 0 then begin
    alist:= self;
   end
   else begin
    alist:= funitinfopo^.interfaceuses.getunitdeflist(anamepath[0]);
    if alist = nil then begin
     alist:= funitinfopo^.implementationuses.getunitdeflist(anamepath[0]);
    end;
   end;
  end
  else begin
   alist:= nil;
  end;
  if alist <> nil then begin
   result:= alist.finddef(copy(anamepath,1,bigint),scopes,defs,first,
   dsl_qualified,afindkind,maxcount);
  end
  else begin
   flastunitindex:= 0;
   if level in [dsl_normal,dsl_parent] then begin
    allreadysearched:= true;
   end;
   result:= inherited finddef(anamepath,scopes,defs,first,level,afindkind,maxcount);
   if (not result or not first) and (level in [dsl_normal,dsl_parent,dsl_parentclass]) then begin
    for int1:= funitinfopo^.implementationuses.count - 1 downto 0 do begin
     result:= unitsearch(funitinfopo^.implementationuses.getunitdeflist(int1)) or result;
     if result and first then begin
      flastunitindex:= -int1;
      exit;
     end;
    end;
    for int1:= funitinfopo^.interfaceuses.count - 1 downto 0 do begin
     result:= unitsearch(funitinfopo^.interfaceuses.getunitdeflist(int1)) or result;
     if result and first then begin
      flastunitindex:= int1+1;
      exit;
     end;
    end;
    po1:= sourceupdater.updateunitinterface('system');
    if po1 <> nil then begin
     result:= po1^.deflist.finddef(anamepath,scopes,defs,first,
                     dsl_unitsearch,afindkind,maxcount) or result;
    end;
   end;
  end;
 end;
end;

function trootdeflist.findparentclass(const adescendent: tdeflist; 
                                         var defs: definfopoarty): boolean;
var
 ar1: stringarty;
 ar2: deflistarty;
 list1: trootdeflist;
 po1: pmoduleinfoty;
begin
 with adescendent do begin
  setlength(ar1,1);
  ar1[0]:= fparentident;
  result:= false;
  if adescendent.fparentunitindex > 0 then begin
   result:= funitinfopo^.interfaceuses.
      getunitdeflist(adescendent.fparentunitindex-1).
         finddef(ar1,ar2,defs,true,dsl_unitsearch,syk_classdef);
  end
  else begin
   if adescendent.fparentunitindex < 0 then begin
    result:= funitinfopo^.implementationuses.
       getunitdeflist(-adescendent.fparentunitindex).
          finddef(ar1,ar2,defs,true,dsl_unitsearch,syk_classdef);
   end;
  end;
  if not result then begin
   result:= self.finddef(ar1,ar2,defs,true,dsl_parentclass,syk_classdef);
   if result then begin
    adescendent.fparentunitindex:= flastunitindex;
   end;
  end;
 end;
end;

end.
