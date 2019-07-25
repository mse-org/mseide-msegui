{ MSEide Copyright (c) 1999-2018 by Martin Schreiber
   
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
unit msedesignparser;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
{$if FPC_FULLVERSION >= 030100} {$define mse_fpc_3_2} {$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 mseglob,msedatalist,mselist,mseparser,msetypes,typinfo,msestrings,
 msearrayutils;
 
type
 idesignparser = interface(inullinterface)
 end;
type

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

 browserlistitemty = record
  index: integer;
 end;
 pbrowserlistitemty = ^browserlistitemty;

 tsourceitemlist = class(torderedrecordlist)
  protected
   function getcomparefunc: sortcomparemethodty; override;
   function compare(const l,r): integer;
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
   start,stop: sourceposty;
  end;
  paraminfoarty = array of paraminfoty;
  
  methodflagty = (mef_virtual,mef_abstract,mef_inherited,mef_override,
                        mef_reintroduce,mef_overload{,mef_inline},
                        mef_brackets,mef_forward);
  methodflagsty = set of methodflagty;

  methodkindty = (mk_none,mk_procedure,mk_procedurefunc,mk_function,
                  mk_method,mk_methodfunc,
                  mk_constructor,mk_destructor,
                  mk_classprocedure,mk_classfunction);
  
  methodparaminfoty = record
   kind: methodkindty;
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
   managed: boolean;
   classproc: boolean;
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
                  var info: methodparaminfoty;
                  const anyparam: boolean = false): pprocedureinfoty;
    function matchmethod(const atype: ptypeinfo;
                                    const amanaged: boolean): integerarty;
    function matchedmethodnames(const atype: ptypeinfo;
                                    const managed: boolean): msestringarty;
    property items[const index: integer]: pprocedureinfoty read getitempo; default;
  end;

  interfaceinfoty = record
   b: browserlistitemty;
   name,uppername: string;
  end;
  pinterfaceinfoty = ^interfaceinfoty;

  tinterfaceinfolist = class(tbrowserlist)
   private
   protected
    procedure finalizerecord(var item); override;
    function getitempo(const index: integer): pinterfaceinfoty;
   public
    constructor create;
    function finditembyname(const aname: string): pinterfaceinfoty;
    function finditembyuppername(const aname: lstringty): pinterfaceinfoty;
    property items[const index: integer]: pinterfaceinfoty read getitempo; default;
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
  classinfopoarty = array of pclassinfoty;

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
  
// c parser

  functionheaderinfoty = record
   b: browserlistitemty;
   name: ansistring;
  end;
  pfunctionheaderinfoty = ^functionheaderinfoty;

  functioninfoty = record
//   b: browserlistitemty;
   name: ansistring;
   start,stop: sourceposty;
  end;
  pfunctioninfoty = ^functioninfoty;

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
                  syk_procdef,syk_procimp,syk_classprocimp,
                  syk_vardef,syk_pardef,
                  syk_constdef,syk_typedef,syk_interfacedef,syk_identuse);
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

  symbolflagty = (syf_global);
  symbolflagsty = set of symbolflagty;
  
  definfoty = record
   name: string;      //'' -> statment
   pos,stop1: sourceposty;
   owner: tdeflist;
   deflist: tdeflist; //can be nil
   symbolflags: symbolflagsty;
   case kind: symbolkindty of
    syk_classdef: (classindex: integer);
    syk_procdef,syk_classprocimp,syk_procimp: (procindex: integer);
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
    fparentident: string;
    fparentunitindex: integer;
    finfocount: integer;
    fstart,fstop: sourceposty;
    fkind: symbolkindty;
    fcasesensitive: boolean;
    function comp(const l,r): integer;
    function compnopars(const l,r): integer;
    function compsubstr(const l,r): integer;
    function getname: string; virtual;
    function getdefinfopo: pdefinfoty;
    function getrootlist: trootdeflist;
    function incinfocount: integer;
    function internalfinditem(const apos: sourceposty; const firstidentuse,last: boolean;
                           out scope: tdeflist): pdefinfoty;
   protected
    finfos: definfoarty;
    fparentscope: tdeflist; //class definition
    procedure finalizerecord(var item); override;
    function getcomparefunc: sortcomparemethodty; override;
    function add(const aname: string; const akind: symbolkindty;
                 const apos,astop: sourceposty): pdefinfoty; overload;
    function add(const akind: symbolkindty; const apos,astop: sourceposty): pdefinfoty; overload;
                     //statment
   public
    constructor create(const akind: symbolkindty; const acasesensitive: boolean);
    procedure clear; override;
    procedure startident(const aparser: tparser); overload;
    procedure startident(const apos: sourceposty; const alen: integer); overload;
    procedure addident(const aparser: tparser); overload;
    procedure addident(const apos: sourceposty; const alen: integer); overload;
    procedure addemptyident(const aparser: tparser);
    procedure endident(const aparser: tparser); overload;
    procedure endident(const aparser: tparser; const endpos: sourceposty); overload;
    function addidentpath(const aparser: tparser;
                                    const aseparator: char): boolean;
    function addidents(const aparser: tparser;
                const aseparator: char; const apathseparator: char): boolean;

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
    function rootnamepath: string;
    property parent: tdeflist read fparent;
    property parentid: nameidty read fparentid;
    property parentscope: tdeflist read fparent;
    property kind: symbolkindty read fkind;
    property name: string read getname;
    property definfopo: pdefinfoty read getdefinfopo;
    property rootlist: trootdeflist read getrootlist;
    property infos: definfoarty read finfos;
    property infocount: integer read finfocount;
  end;
  
  includestatementarty = array of includestatementty;
  
  proglangty = (pl_pascal,pl_c);      

  tfunctionheaders = class;
  tfunctions = class;
  
  cunitinfoty = record
   functionheaders: tfunctionheaders;
   functions: tfunctions;
  end; 

  pascalunitinfoty = record
   procedurelist: tprocedureinfolist;
   interfacelist: tinterfaceinfolist;
   classinfolist: tclassinfolist;
   interfaceuses,implementationuses: tusesinfolist;
   implementationstart: sourceposty;
   implementationbodystart: sourceposty;
   implementationend: sourceposty;
   initializationstart: sourceposty;
   finalizationstart: sourceposty;
  end;

  unitinfoty = record
   interfacecompiled: boolean;
   implementationcompiled: boolean;
   isprogram: boolean;
   itemlist: tsourceitemlist;
   deflist: trootdeflist;
   sourcefilename: filenamety;
   unitname: string; //uppercase
   origunitname: string;
   formfilename: filenamety;
   unitend: sourceposty;
   sourceend: sourceposty;
   sourcefiles: sourcefileinfoarty;
   includestatements: includestatementarty;
   case proglang: proglangty of
    pl_pascal:
     (p: pascalunitinfoty);
    pl_c:
     (c: cunitinfoty);
  end;
  punitinfoty = ^unitinfoty;
  unitinfopoarty = array of punitinfoty;

  trootdeflist = class(tdeflist)
   private
    factnode: tdeflist;
    funitinfopo: punitinfoty;
    flastunitindex: integer;
   protected
    function getname: string; override;
   public
    allreadysearched: boolean;
    constructor create(const aunitinfopo: punitinfoty);
    procedure clear; override;
    procedure endnode(const apos: sourceposty);
    function beginnode(const aname: string; const akind: symbolkindty;
          const apos,astop: sourceposty): pdefinfoty; overload;
    function beginnode(const apos: sourceposty;
                      const aclassinfo: pclassinfoty): tdeflist; overload;
    function add(const aname: string; const akind: symbolkindty;
                      const astart,astop: sourceposty): pdefinfoty; overload;
    function add(const apos,astop: sourceposty; 
                      const aprocinfo: pprocedureinfoty): pdefinfoty; overload;
    function add(const apos,astop: sourceposty; 
                      const afunctioninfo: pfunctioninfoty): pdefinfoty; overload;
    function add(const apos,astop: sourceposty; 
                      const afunctionheaderinfo: pfunctionheaderinfoty): pdefinfoty; overload;
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
    property actnode: tdeflist read factnode;
  end;

  tfunctionheaders = class(tbrowserlist)
   private
    function getitempo(const index: integer): pfunctionheaderinfoty;
   protected
    procedure finalizerecord(var item); override;
   public
    constructor create;
    property items[const index: integer]: pfunctionheaderinfoty
                                                read getitempo; default;
  end;
  
  tfunctions = class(torderedrecordlist)
   private
    function getitempo(const index: integer): pfunctioninfoty;
    function comp(const left,right): integer;
   protected
    procedure finalizerecord(var item); override;
    function getcomparefunc: sortcomparemethodty; override;
   public
    constructor create;
    procedure add(const aname: ansistring; const astart,astop: sourceposty);
    function find(const name: ansistring): pfunctioninfoty;
    property items[const index: integer]: pfunctioninfoty 
                                                 read getitempo; default;
  end;
  
 tunitinfo = class
  public
   info: unitinfoty;
   constructor create;
   destructor destroy; override;
   function infopo: punitinfoty;
 end;
 
 tpascalunitinfo = class(tunitinfo)
  public
   constructor create;
   destructor destroy; override;
 end;

function parametersmatch(const a: ptypeinfo; const b: methodparaminfoty): boolean;
procedure getmethodparaminfo(const atype: ptypeinfo; var info: methodparaminfoty);
function splitidentpath(const atext: string): stringarty;
function mangleprocparams(const aparams: methodparaminfoty): string;
procedure initcompinfo(var info: unitinfoty);
procedure afterparse(const sender: tparser; var unitinfo: unitinfoty;
                        const aimplementationcompiled: boolean);
function addincludefile(var info: unitinfoty; const afilename: filenamety;
          const astatementstart, astatementend: sourceposty): integer;
                       //returns index

var
 updateunitinterface: function(const unitname: string): punitinfoty of object;
 gettype: function (const adef: pdefinfoty): stringarty of object;
 resetunitsearched: procedure of object;
 
implementation
uses
 {sourceupdate,}sysutils,cdesignparser;   
       //todo: remove cdesignparser, extract c+pascaldesignparser code
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
{$ifdef FPC}{$goto on}{$endif}
type
 tparser1 = class(tparser);

function addincludefile(var info: unitinfoty; const afilename: filenamety;
                const astatementstart, astatementend: sourceposty): integer;
begin
 with info do begin
  result:= length(includestatements);
  setlength(includestatements,result+1);
  with includestatements[high(includestatements)] do begin
   filename:= afilename;
   startpos:= astatementstart;
   endpos:= astatementend;
  end;
 end;
end;
  
procedure initcompinfo(var info: unitinfoty);
begin
 with info do begin
  case proglang of
   pl_pascal: begin
    p.procedurelist.clear;
    p.interfacelist.clear;
    p.classinfolist.clear;
    p.interfaceuses.clear;
    p.implementationuses.clear;
    p.implementationstart.filenum:= 0;
    p.implementationend.filenum:= 0;
    p.initializationstart.filenum:= 0;
    p.finalizationstart.filenum:= 0;
   end;
   pl_c: begin
    c.functionheaders.clear;   
    c.functions.clear;   
   end;
  end;
  interfacecompiled:= false;
  implementationcompiled:= false;
  isprogram:= false;
  freeandnil(itemlist);
  deflist.clear;
  unitname:= '';
  origunitname:= '';
  unitend.filenum:= 0;
  sourceend.filenum:= 0;
  sourcefiles:= nil;
  includestatements:= nil;
 end;
end;

procedure afterparse(const sender: tparser; var unitinfo: unitinfoty;
                        const aimplementationcompiled: boolean);
var
 int1: integer;
begin
 with tparser1(sender),unitinfo do begin
  interfacecompiled:= true;
  implementationcompiled:= aimplementationcompiled;
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

function parametersmatch1(const a,b: methodparaminfoty): boolean;
var
 int1: integer;
begin
 result:= (a.kind = b.kind) and (high(a.params) = high(b.params));
 if result then begin
  for int1:= 0 to high(a.params) do begin
   with a.params[int1] do begin
    if (flags*[pfvar,pfconst,pfout,pfarray] <> 
                b.params[int1].flags*[pfvar,pfconst,pfout,pfarray]) or
           (stringicomp(typename,b.params[int1].typename) <> 0) then begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
end;

const
 tmethodkindtomethodkind: array[tmethodkind] of methodkindty = (
  //mkProcedure, mkFunction, mkConstructor, mkDestructor,
    mk_procedure,mk_function,mk_constructor,mk_destructor,
  //mkClassProcedure, mkClassFunction, mkClassConstructor,
    mk_classprocedure,mk_classfunction,mk_none,
  //mkClassDestructor,mkOperatorOverload
    mk_none,          mk_none
 );
 
procedure getmethodparaminfo(const atype: ptypeinfo; 
                                         var info: methodparaminfoty);

  function getshortstring(var po: pchar): string;
  begin
   setlength(result,byte(po^));
   inc(po);
   move(po^,pointer(result)^,length(result));
   inc(po,length(result));
  end;

type
 pparamflags = ^tparamflags;
 paramrecty = record
               Flags : TParamFlags;
//               ParamName : ShortString;
              end;
var
 isfunction: boolean;
 int1: integer;
 po1: pchar;
begin
 with info do begin
  kind:= methodkindty(-1);
  params:= nil;
  if (atype^.Kind = tkmethod) then begin
   with gettypedata(atype)^ do begin
    kind:= tmethodkindtomethodkind[methodkind];
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
       flags:= tparamflags(
         {$ifdef mse_fpc_3_2}wordset{$else}byteset{$endif}(pbyte(po1)^));
       inc(po1,{$ifdef mse_fpc_3_2}2{$else}1{$endif});
//       inc(po1,sizeof(paramrecty));
//       inc(po1,sizeof(tparamflags));
//       inc(po1,sizeof(byteset));
       name:= getshortstring(po1);
       typename:= getshortstring(po1);
       if (typename = 'WideString') or (typename = 'UnicodeString') then begin
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

function parametersmatch(const a: ptypeinfo; const b: methodparaminfoty): boolean;
var
 a1: methodparaminfoty;
 {$if FPC_FULLVERSION > 030200}
 params1: paraminfoarty;
 x : integer;
 {$endif}
begin
 getmethodparaminfo(a,a1); 
 {$if FPC_FULLVERSION > 030200}
 setlength(params1,length(a1.params)-1);
 for x:=0 to length(params1) -1 do
 params1[x] := a1.params[x+1];
 a1.params := params1;
 {$endif}
 result:= parametersmatch1(a1,b);
end;

function splitidentpath(const atext: string): stringarty;
begin
 result:= nil;
 splitstring(atext,result,'.',true);
end;

function mangleprocparams(const aparams: methodparaminfoty): string;
var
 int1: integer;
begin
 with aparams do begin
  result:= '';
  for int1:= 0 to high(params) do begin
   result:= result + '$' + params[int1].typename;
  end;
  if kind in [mk_function,mk_classfunction,
                       mk_procedurefunc,mk_methodfunc] then begin
   result:= result+'$';
  end;
 end;
end;

{ tsourceitemlist }

constructor tsourceitemlist.create;
begin
 inherited create(sizeof(sourceitemty));
end;

function tsourceitemlist.compare(const l,r): integer;
begin
 result:= sourceitemty(l).startpos.row - sourceitemty(r).startpos.row;
 if result = 0 then begin
  result:= sourceitemty(l).startpos.col - sourceitemty(r).startpos.col;
 end;
end;

function tsourceitemlist.getcomparefunc: sortcomparemethodty;
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
 po2:= {sourceupdater.}updateunitinterface(unitnames[index]);
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
  po2:= {sourceupdater.}updateunitinterface(aunitname);
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
  if stringicompupper(aname,po1^.uppername) = 0 then begin
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
 str1:= struppercase(aname);
 for int1:= 0 to fcount - 1 do begin
  if str1 = po1^.uppername then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

function tprocedureinfolist.finditembyuppername(const aname: lstringty;
                     var info: methodparaminfoty;
                                   const anyparam: boolean): pprocedureinfoty;
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
 if (result = nil) and anyparam then begin
  po1:= datapo;
  for int1:= 0 to fcount - 1 do begin
   if (po1^.params.kind = info.kind) and
                  (lstringcomp(aname,po1^.uppername) = 0) then begin
    result:= po1;
    info:= po1^.params;
    break;
   end;
   inc(po1);
  end;
 end;
end;

function tprocedureinfolist.matchmethod(const atype: ptypeinfo;
                                    const amanaged: boolean): integerarty;
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
   if parametersmatch1(params,info) and (not amanaged or managed) then begin
    additem(result,int1);
   end;
  end;
  inc(po1);
 end;
end;

function tprocedureinfolist.matchedmethodnames(const atype: ptypeinfo;
                                      const managed: boolean): msestringarty;
var
 ar1: integerarty;
 int1: integer;
begin
 ar1:= matchmethod(atype,managed);
 setlength(result,length(ar1));
 for int1:= 0 to high(ar1) do begin
  result[int1]:= msestring(getitempo(ar1[int1])^.name);
 end;
end;

{ tinterfaceinfolist }

constructor tinterfaceinfolist.create;
begin
 inherited create(sizeof(interfaceinfoty),[rels_needsfinalize]);
end;

procedure tinterfaceinfolist.finalizerecord(var item);
begin
 finalize(interfaceinfoty(item));
end;

function tinterfaceinfolist.getitempo(
  const index: integer): pinterfaceinfoty;
begin
 result:= pinterfaceinfoty(inherited getitempo(index));
end;

function tinterfaceinfolist.finditembyname(const aname: string): pinterfaceinfoty;
var
 po1: pinterfaceinfoty;
 int1: integer;
 str1: string;
begin
 result:= nil;
 po1:= datapo;
 str1:= struppercase(aname);
 for int1:= 0 to fcount - 1 do begin
  if str1 = po1^.uppername then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

function tinterfaceinfolist.finditembyuppername(
                                    const aname: lstringty): pinterfaceinfoty;
var
 po1: pinterfaceinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if  lstringcomp(aname,po1^.uppername) = 0 then begin
   result:= po1;
   break;
  end;
  inc(po1);
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
  if lstringicompupper(aname,po1^.uppername) = 0 then begin
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
{ tdeflist }

constructor tdeflist.create(const akind: symbolkindty;
                                              const acasesensitive: boolean);
begin
 fcasesensitive:= acasesensitive;
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
 if fcasesensitive then begin
  po1^.name:= aname;
 end
 else begin
  po1^.name:= struppercase(aname);
 end;
 po1^.id:= incinfocount;
 result:= @finfos[po1^.id];
 with result^ do begin
  owner:= self;
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
  owner:= self;
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

procedure tdeflist.startident(const apos: sourceposty; const alen: integer);
begin
 with add(syk_identuse,apos,emptysourcepos)^ do begin
  identflags:= [if_first];
  identlen:= alen;
  stop1:= pos;
  inc(stop1.pos.col,alen);
 end;
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

procedure tdeflist.addident(const apos: sourceposty; const alen: integer);
begin
 with add(syk_identuse,apos,emptysourcepos)^ do begin
  identlen:= alen;
  stop1:= pos;
  inc(stop1.pos.col,identlen);
 end;
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

function tdeflist.addidentpath(const aparser: tparser;
                                    const aseparator: char): boolean;
var
 ident1: integer;
begin
 with aparser do begin
  ident1:= getident;
  if (token^.kind = tk_name) and (ident1 < 0) then begin
   startident(aparser);
   while checkoperator(aseparator) do begin
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

function tdeflist.addidents(const aparser: tparser;
                  const aseparator: char; const apathseparator: char): boolean;
//var
// ident1: integer;
begin
 repeat
  result:= addidentpath(aparser,apathseparator);
 until not result or not aparser.checkoperator(aseparator);
{
 result:= true;
 with aparser do begin
  repeat
   ident1:= getident;
   if (token^.kind = tk_name) and (ident1 < 0) then begin
    startident(aparser);
    endident(aparser);
   end
   else begin
    result:= false;
    break;
   end;
  until not checkoperator(aseparator);
 end;
}
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
    if (ar4[int1]^.kind in [syk_vardef,syk_procdef,syk_procimp]) and (high(anamepath) > 0) then begin
     ar1:= {sourceupdater.}gettype(ar4[int1]);
     stackarray(copy(anamepath,1,bigint),ar1);
     {sourceupdater.}resetunitsearched;
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

function isinrange(const apos: sourceposty; const start: sourceposty;
                   const stop: sourceposty): boolean;
begin
 result:= not((apos.pos.row < start.pos.row) or 
              (apos.pos.row > stop.pos.row) or
              (apos.pos.row = start.pos.row) and 
                (apos.pos.col < start.pos.col) or
              (apos.pos.row = stop.pos.row) and 
                (apos.pos.col > stop.pos.col)
             );
end;

function tdeflist.internalfinditem(const apos: sourceposty; 
         const firstidentuse,last: boolean; out scope: tdeflist): pdefinfoty;
var
 int1,int2,lastmatching: integer;
begin
 lastmatching:= -1;
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
     if isinrange(apos,pos,stop1) then begin
      lastmatching:= int1;
     end;
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
      int2:= lastmatching;
     end;
    end;
    syk_identuse: begin
     if (if_last in identflags) and
              ((stop1.line < apos.line) or
                 (stop1.line = apos.line) and
                 (stop1.pos.col <= apos.pos.col)) then begin
      int2:= lastmatching;
     end;
    end;
    else begin
     if (deflist <> nil) and
      ((deflist.fstop.line < apos.line) or (deflist.fstop.line = apos.line) and
                 (deflist.fstop.pos.col <= apos.pos.col)) then begin
      int2:= lastmatching;
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
function tdeflist.comp(const l,r): integer;
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

function tdeflist.compnopars(const l,r): integer;
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

function tdeflist.compsubstr(const l,r): integer;
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

function tdeflist.getcomparefunc: sortcomparemethodty;
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
 if fcasesensitive then begin
  str1:= aname;
 end
 else begin
  str1:= struppercase(aname);
 end;
 sorted:= true;
 if akind = syk_nopars then begin
  fcomparefunc:= {$ifdef FPC}@{$endif}compnopars;
 end
 else begin
  if akind = syk_substr then begin
   fcomparefunc:= {$ifdef FPC}@{$endif}compsubstr;
  end
 end;
 if internalfind(str1,int1) then begin
  if akind > syk_deleted then begin
   while finfos[pdefnameaty(fdata)^[int1].id].kind <> akind do begin
    dec(int1);
    if (int1 < 0) then begin
     goto exit1;
    end;
    int2:= comp(str1,pdefnameaty(fdata)^[int1].name);
    if (int2 <> 0) then begin
     goto exit1;
    end;
   end;
  end;
  result:= @finfos[pdefnameaty(fdata)^[int1].id];
 end;
exit1:
 fcomparefunc:= {$ifdef FPC}@{$endif}comp;
end;

function tdeflist.getmatchingitems(const aname: string;
                    const akind: symbolkindty = syk_none): definfopoarty;
var
 int1,int2: integer;
 str1: string;
 po1: pdefinfoty;
begin
 result:= nil;
 if fcasesensitive then begin
  str1:= aname;
 end
 else begin
  str1:= struppercase(aname);
 end;
 sorted:= true;
 if akind = syk_nopars then begin
  fcomparefunc:= {$ifdef FPC}@{$endif}compnopars;
 end
 else begin
  if akind = syk_substr then begin
   fcomparefunc:= {$ifdef FPC}@{$endif}compsubstr;
  end
 end;
 if internalfind(str1,int1) then begin
  while (int1 >= 0) do begin
   int2:= fcomparefunc(str1,pdefnameaty(fdata)^[int1]);
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
 fcomparefunc:= {$ifdef FPC}@{$endif}comp;
end;

function tdeflist.rootnamepath: string;
var
 pa: tdeflist;
begin
 result:= name;
 pa:= parentscope;
 while pa <> nil do begin
  result:= pa.name + '.' + result;
  pa:= pa.parentscope;
 end; 
end;

{ trootdeflist}

constructor trootdeflist.create(const aunitinfopo: punitinfoty);
begin
 funitinfopo:= aunitinfopo;
 factnode:= self;
 inherited create(syk_root,funitinfopo^.proglang = pl_c);
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
  deflist:= tdeflist.create(akind,fcasesensitive);
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

function trootdeflist.add(const apos,astop: sourceposty; 
         const afunctioninfo: pfunctioninfoty): pdefinfoty;
begin
 result:= factnode.add(afunctioninfo^.name,syk_procimp,apos,astop);
 result^.procindex:= -1; //functioninfoty is no browseritem
// result^.procindex:= afunctioninfo^.b.index;
end;

function trootdeflist.add(const apos,astop: sourceposty; 
         const afunctionheaderinfo: pfunctionheaderinfoty): pdefinfoty;
begin
 result:= factnode.add(afunctionheaderinfo^.name,syk_procdef,apos,astop);
 result^.procindex:= afunctionheaderinfo^.b.index;
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
 po2: pdefinfoty;
begin
 result:= false;
 if high(anamepath) >= 0 then begin
  alist:= nil;
  if (level in [dsl_normal,dsl_parent]) and (high(anamepath) > 0) then begin
        //check qualified
   if stringicomp(anamepath[0],funitinfopo^.unitname) = 0 then begin
    alist:= self;
   end
   else begin
    if funitinfopo^.proglang = pl_pascal then begin
     alist:= funitinfopo^.p.interfaceuses.getunitdeflist(anamepath[0]);
     if alist = nil then begin
      alist:= funitinfopo^.p.implementationuses.getunitdeflist(anamepath[0]);
     end;
    end;
   end;
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
   case funitinfopo^.proglang of
    pl_pascal: begin
     if (not result or not first) and (level in [dsl_normal,dsl_parent,dsl_parentclass]) then begin
      for int1:= funitinfopo^.p.implementationuses.count - 1 downto 0 do begin
       result:= unitsearch(funitinfopo^.p.implementationuses.getunitdeflist(int1)) or result;
       if result and first then begin
        flastunitindex:= -int1;
        exit;
       end;
      end;
      for int1:= funitinfopo^.p.interfaceuses.count - 1 downto 0 do begin
       result:= unitsearch(funitinfopo^.p.interfaceuses.getunitdeflist(int1)) or result;
       if result and first then begin
        flastunitindex:= int1+1;
        exit;
       end;
      end;
      po1:= {sourceupdater.}updateunitinterface('system');
      if po1 <> nil then begin
       result:= po1^.deflist.finddef(anamepath,scopes,defs,first,
                       dsl_unitsearch,afindkind,maxcount) or result;
      end;
     end;
    end;
    pl_c: begin
     if result and first and (defs[0]^.kind = syk_procdef) then begin
      result:= false;
      scopes:= nil;
      defs:= nil;
     end;
     if (not result {or not first}) and (level in 
                                           [dsl_normal,dsl_parent]) then begin
      po2:= cglobals.finddef(anamepath[high(anamepath)]);
      if po2 <> nil then begin
       result:= true;
       additem(pointerarty(defs),pointer(po2));
      end;
     end;
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
begin
 with adescendent do begin
  setlength(ar1,1);
  ar1[0]:= fparentident;
  result:= false;
  if adescendent.fparentunitindex > 0 then begin
   result:= funitinfopo^.p.interfaceuses.
      getunitdeflist(adescendent.fparentunitindex-1).
         finddef(ar1,ar2,defs,true,dsl_unitsearch,syk_classdef);
  end
  else begin
   if adescendent.fparentunitindex < 0 then begin
    result:= funitinfopo^.p.implementationuses.
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

function trootdeflist.getname: string;
begin
 result:= funitinfopo^.unitname;
end;

{ tfunctionheaders }

constructor tfunctionheaders.create;
begin
 inherited create(sizeof(functionheaderinfoty),[rels_needsfinalize]);
end;

function tfunctionheaders.getitempo(const index: integer): pfunctionheaderinfoty;
begin
 result:= pfunctionheaderinfoty(inherited getitempo(index));
end;

procedure tfunctionheaders.finalizerecord(var item);
begin
 finalize(functionheaderinfoty(item));
end;

{ tfunctions }

constructor tfunctions.create;
begin
 inherited create(sizeof(functioninfoty),[rels_needsfinalize]);
end;

function tfunctions.getitempo(const index: integer): pfunctioninfoty;
begin
 result:= pfunctioninfoty(inherited getitempo(index));
end;

procedure tfunctions.finalizerecord(var item);
begin
 finalize(functioninfoty(item));
end;

procedure tfunctions.add(const aname: ansistring; const astart,astop: sourceposty);
begin
 with pfunctioninfoty(newitem)^ do begin
  name:= aname;
  start:= astart;
  stop:= astop;
 end;
end;

function tfunctions.comp(const left,right): integer;
begin
 result:= stringcomp(ansistring(left),ansistring(right));
end;

function tfunctions.getcomparefunc: sortcomparemethodty;
begin
 result:= {$ifdef FPC}@{$endif}comp;
end;

function tfunctions.find(const name: ansistring): pfunctioninfoty;
var
 info: functioninfoty;
 int1: integer;
begin
 result:= nil;
 info.name:= name;
 if internalfind(info,int1) then begin
  result:= items[int1];
 end;
end;

{ tunitinfo }

function tunitinfo.infopo: punitinfoty;
begin
 result:= @info;
end;

constructor tunitinfo.create;
begin
 with info do begin
  if deflist = nil then begin
   deflist:= trootdeflist.create(@info);
  end;
 end;
end;

destructor tunitinfo.destroy;
begin
 with info do begin
  itemlist.free;
  deflist.Free;
 end;
 inherited;
end;

{ tpascalunitinfo }

constructor tpascalunitinfo.create;
begin
 inherited;
 with info do begin
  proglang:= pl_pascal;
  p.procedurelist:= tprocedureinfolist.create;
  p.interfacelist:= tinterfaceinfolist.create;
  p.classinfolist:= tclassinfolist.create;
  p.interfaceuses:= tusesinfolist.create(false);
  p.implementationuses:= tusesinfolist.create(true);
 end;
end;

destructor tpascalunitinfo.destroy;
begin
 with info do begin
  p.procedurelist.Free;
  p.interfacelist.Free;
  p.classinfolist.Free;
  p.interfaceuses.Free;
  p.implementationuses.Free;
 end;
 inherited;
end;

end.
