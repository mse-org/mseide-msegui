unit msesqlresult;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}
uses
 classes,db,msqldb,mseclasses,msedb,msedatabase,msearrayprops,msestrings,msereal,
 msetypes,mselookupbuffer,mseglob;
 
type
 tsqlresult = class;
 
 tdbcol = class(tvirtualpersistent)
  private
  protected
   fuppername: ansistring;
   ffieldname: ansistring;
   fsqlresult: tsqlresult;
   fcursor: tsqlcursor;
   fdatatype: tfieldtype;
   ffieldnum: integer;
   futf8: boolean;
   fdatasize: integer;
   function accesserror(const typename: string): edatabaseerror;
   function getvariantvar: variant; virtual;
   function getasvariant: variant; virtual;
   function getasboolean: boolean; virtual;
   function getascurrency: currency; virtual;
   function getaslargeint: largeint; virtual;
   function getasdatetime: tdatetime; virtual;
   function getasfloat: double; virtual;
   function getasinteger: longint; virtual;
   function getasstring: string; virtual;
   function getasmsestring: msestring; virtual;
   function getisnull: boolean; virtual;
   function loadfield(const buffer: pointer; var bufsize: integer): boolean; overload;
                //false if null or inactive
   function loadfield(const buffer: pointer): boolean; overload;
                //false if null or inactive
  public
   constructor create(const asqlresult: tsqlresult;
          const acursor: tsqlcursor; const afielddef: tfielddef); reintroduce;
   property datatype: tfieldtype read fdatatype;
   property fieldname: ansistring read ffieldname;
   property size: integer read fdatasize;

   property asvariant: variant read getasvariant;
              //empty variant returned for null fields
   property asboolean: boolean read getasboolean;
   property ascurrency: currency read getascurrency;
   property aslargeint: largeint read getaslargeint;
   property asdatetime: tdatetime read getasdatetime;
   property asfloat: double read getasfloat;
   property asinteger: longint read getasinteger;
   property asstring: ansistring read getasstring;
   property asmsestring: msestring read getasmsestring;
   property isnull: boolean read getisnull;
   
 end;
 dbcolclassty = class of tdbcol;

 tstringdbcol = class(tdbcol)
  private
  protected
   function getasstring: ansistring; override;
   function getvariantvar: variant; override;
  public
   property value: msestring read getasmsestring;
 end;
 
 tnumericdbcol = class(tdbcol)
  private
  protected
   function getvariantvar: variant; override;
 end;
 
 tlongintdbcol = class(tnumericdbcol)
  protected
   function getasinteger: integer; override;
  public
   property value: integer read getasinteger;
 end;
 
 tlargeintdbcol = class(tnumericdbcol)
  private
  protected
   function getaslargeint: largeint; override;
   function getasinteger: integer; override;
   function getvariantvar: variant; override;
  public
   property value: largeint read getaslargeint;
 end;
 
 tsmallintdbcol = class(tnumericdbcol)
  protected
   function getasinteger: integer; override;
  public
   property value: integer read getasinteger;
 end;
 
 tworddbcol = class(tnumericdbcol)
  protected
   function getasinteger: integer; override;
  public
   property value: integer read getasinteger;
 end;
 
// tautoincdbcol = class(tdbcol);

 tfloatdbcol = class(tdbcol)
  private
  protected
   function getasfloat: double; override;
   function getascurrency: currency; override;
   function getvariantvar: variant; override;
  public
   property value: double read getasfloat;
 end;
 tcurrencydbcol = class(tdbcol)
  private
  protected
   function getascurrency: currency; override;
   function getasfloat: double; override;
   function getvariantvar: variant; override;
  public
   property value: currency read getascurrency;
 end;
 tbooleandbcol = class(tdbcol)
  private
  protected
   function getasboolean: boolean; override;
   function getvariantvar: variant; override;
  public
   property value: boolean read getasboolean;
 end;
 tdatetimedbcol = class(tfloatdbcol)
  private
  protected
   function getasdatetime: tdatetime; override;
   function getvariantvar: variant; override;
  public
   property value: tdatetime read getasdatetime;
 end;
  
// tdatedbcol = class(tdbcol);
// ttimedbcol = class(tdbcol);
// tbinarydbcol = class(tdbcol);
// tbytesdbcol = class(tdbcol);
// tvarbytesdbcol = class(tdbcol);
// tbcddbcol = class(tdbcol);

 tblobdbcol = class(tdbcol)
  private
  protected 
   function getasstring: ansistring; override;
   function getvariantvar: variant; override;
  public
   property value: ansistring read getasstring;
 end;
 
 tmemodbcol = class(tblobdbcol)
  private
  protected
   function getvariantvar: variant; override;
  public
   property value: msestring read getasmsestring;
 end;
 
// tgraphicdbcol = class(tdbcol);
 dbcolarty = array of tdbcol;

 getnamefuncty = function:ansistring of object;
 
 tdbcols = class(tpersistentarrayprop)
  private 
   fgetname: getnamefuncty;
   function getitems(const index: integer): tdbcol;
   procedure initfields(const asqlresult: tsqlresult;
                  const acursor: tsqlcursor; const afielddefs: tfielddefs);
  public
   constructor create(const agetname: getnamefuncty);
   function findcol(const aname: ansistring): tdbcol;   
   function colbyname(const aname: ansistring): tdbcol;
   function colsbyname(const anames: array of ansistring): dbcolarty;
              //invalid after close!
   property items[const index: integer]: tdbcol read getitems; default;
 end;

 tsqlresultfielddefs = class(tfielddefs)
  private
   procedure setitemname(aitem: tcollectionitem); override;
 end;
 
 sqlresultoptionty = (sro_utf8);
 sqlresultoptionsty = set of sqlresultoptionty;

 variantarty = array of variant;
 variantararty = array of variantarty;
  
 tsqlresult = class(tmsecomponent,isqlpropertyeditor,isqlclient,itransactionclient)
  private
   fsql: tsqlstringlist;
   fopenafterread: boolean;
   factive: boolean;
   fdatabase: tcustomsqlconnection;
   ftransaction: tsqltransaction;
   fcursor: tsqlcursor;
   fparams: tmseparams;
   ffielddefs: tsqlresultfielddefs;
   fcols: tdbcols;
   feof: boolean;
   fbof: boolean;
   foptions: sqlresultoptionsty;
   fbeforeopen: tmsesqlscript;
   fafteropen: tmsesqlscript;
   procedure setsql(const avalue: tsqlstringlist);
   function getactive: boolean;
   procedure setactive(avalue: boolean);
   procedure setdatabase1(const avalue: tcustomsqlconnection);
   function getsqltransaction: tsqltransaction;
   procedure setsqltransaction(const avalue: tsqltransaction);
   procedure setparams(const avalue: tmseparams);
   procedure onchangesql(const sender : tobject);
   procedure setbeforeopen(const avalue: tmsesqlscript);
   procedure setafteropen(const avalue: tmsesqlscript);
   procedure changed;
   procedure setfielddefs(const avalue: tsqlresultfielddefs);
  protected
   procedure loaded; override;
   procedure freefldbuffers;
   function isprepared: boolean;
   procedure open;
   procedure close;
   procedure prepare;
   procedure unprepare;
   procedure execute;
   procedure settransaction(const avalue: tmdbtransaction);
   procedure settransactionwrite(const avalue: tmdbtransaction);
   //isqlclient
   procedure setdatabase(const avalue: tmdatabase);
   function getname: ansistring;
   function getsqltransactionwrite: tsqltransaction;
   procedure setsqltransactionwrite(const avalue: tsqltransaction);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function isutf8: boolean;
   procedure next;
   procedure refresh;
   function rowsreturned: integer; //-1 if not supported
//   procedure asvariant(out avalue: variant); overload; //internal compiler error
   function asvariant: variant; 
          //value of first field of first row, empty variant returned for null fields
//   procedure asvariant(out avalue: variantarty); overload; 
   function asvariantar: variantarty;
          //first row, empty variant returned for null fields
//   procedure asvariant(out avalue: variantararty); overload; 
   function asvariantarar: variantararty;
          //whole resultset, empty variant returned for null fields
   property cols: tdbcols read fcols;
   property bof: boolean read fbof;
   property eof: boolean read feof;
  published
   property params : tmseparams read fparams write setparams; //before sql property

   property sql: tsqlstringlist read fsql write setsql;
   property beforeopen: tmsesqlscript read fbeforeopen write setbeforeopen;
   property afteropen: tmsesqlscript read fafteropen write setafteropen;
   property database: tcustomsqlconnection read fdatabase write setdatabase1;
   property transaction: tsqltransaction read getsqltransaction 
                                      write setsqltransaction;
   property active: boolean read getactive write setactive;
   property options: sqlresultoptionsty read foptions write foptions;
   property fielddefs: tsqlresultfielddefs read ffielddefs write setfielddefs;
 end;
 
 idbcolinfo = interface(inullinterface)
                         ['{E246B738-6E4D-4A7D-A5BB-A1A14769C25D}']
  function getsqlresult(const aindex: integer): tsqlresult;
  procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
 end;
 
 getsqlresultfuncty = function(const aindex: integer): tsqlresult of object;
 
 tdbcolnamearrayprop = class(tstringarrayprop,idbcolinfo)
  private
   ffieldtypes: fieldtypesty;
   fgetsqlresult: getsqlresultfuncty;
  protected
   //idbcolinfo
   function getsqlresult(const aindex: integer): tsqlresult;
   procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
  public
   constructor create(const afieldtypes: fieldtypesty;
                         const agetsqlresult: getsqlresultfuncty);
   property fieldtypes: fieldtypesty read ffieldtypes write ffieldtypes;
 end;

 lbsqoptionty = (olbsq_closesqlresult);
 lbsqoptionsty = set of lbsqoptionty;
 
 tsqllookupbuffer = class(tdatalookupbuffer)
  private
   fsource: tsqlresult;
   ftextcols: tdbcolnamearrayprop;
   fintegercols: tdbcolnamearrayprop;
   ffloatcols: tdbcolnamearrayprop;
   foptionsdb: lbsqoptionsty;
   procedure setsource(const avalue: tsqlresult);
   function getsqlresult(const aindex: integer): tsqlresult;
   procedure settextcols(const avalue: tdbcolnamearrayprop);
   procedure setintegercols(const avalue: tdbcolnamearrayprop);
   procedure setfloatcols(const avalue: tdbcolnamearrayprop);
  protected
   function getfieldcounttext: integer; override;
   function getfieldcountinteger: integer; override;
   function getfieldcountfloat: integer; override;
   procedure setfieldcounttext(const avalue: integer); override;
   procedure setfieldcountinteger(const avalue: integer); override;
   procedure setfieldcountfloat(const avalue: integer); override;
   procedure loadbuffer; override;
   procedure objectevent(const sender: tobject;
                       const event: objecteventty); override;
  public 
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clearbuffer; override;
  published
   property source: tsqlresult read fsource write setsource;
   property textcols: tdbcolnamearrayprop read ftextcols write settextcols;
   property integercols: tdbcolnamearrayprop read fintegercols write setintegercols;
   property floatcols: tdbcolnamearrayprop read ffloatcols write setfloatcols;
   property optionsdb: lbsqoptionsty read foptionsdb write foptionsdb default [];
   property onchange;
 end;

//empty variant returned for null fields
procedure getsqlresult(out avalue: variant; const atransaction: tsqltransaction;
                      const asql: msestring; const aparams: array of variant); overload;
           //first field of first row
procedure getsqlresult(out avalue: variantarty; const atransaction: tsqltransaction;
                      const asql: msestring; const aparams: array of variant); overload;
           //first row
procedure getsqlresult(out avalue: variantararty; const atransaction: tsqltransaction;
                      const asql: msestring; const aparams: array of variant); overload;
           //whole resultset
function getsqlresultvar( const atransaction: tsqltransaction;
                      const asql: msestring; 
                      const aparams: array of variant): variant;
function getsqlresultvarar( const atransaction: tsqltransaction;
                      const asql: msestring; 
                      const aparams: array of variant): variantarty;
function getsqlresultvararar( const atransaction: tsqltransaction;
                      const asql: msestring; 
                      const aparams: array of variant): variantararty;
                      
implementation
uses
 sysutils,dbconst,rtlconsts,mseapplication,variants;
const 
 msedbcoltypeclasses: array[fieldclasstypety] of dbcolclassty = 
//        ft_unknown,ft_string,   ft_numeric,
          (tdbcol,   tstringdbcol,tlongintdbcol,
//         ft_longint,   ft_largeint,   ft_smallint,
           tlongintdbcol,tlargeintdbcol,tsmallintdbcol,
//         ft_word,   ft_autoinc,   ft_float,   ft_currency,   ft_boolean,
           tworddbcol,tlongintdbcol,tfloatdbcol,tcurrencydbcol,tbooleandbcol,
//         ft_datetime,   ft_date,       ft_time,
           tdatetimedbcol,tdatetimedbcol,tdatetimedbcol,
//         ft_binary,ft_bytes,ft_varbytes,
           tdbcol,   tdbcol,  tdbcol,
//         ft_bcd,        ft_blob,   ft_memo,   ft_graphic);
           tcurrencydbcol,tblobdbcol,tmemodbcol,tblobdbcol);
 SBoolean = 'Boolean';
 SDateTime = 'TDateTime';
 SFloat = 'Float';
 SInteger = 'Integer';
 SLargeInt = 'LargeInt';
 SVariant = 'Variant';
 SString = 'String';

function dogetsqlresult(const atransaction: tsqltransaction; const asql: msestring;
                        const aparams: array of variant): tsqlresult;           
var
 int1: integer;
begin
 result:= tsqlresult.create(nil);
 try
  result.database:= atransaction.database;
  result.transaction:= atransaction;
  result.sql.text:= asql;
  result.prepare;
  for int1:= 0 to high(aparams) do begin
   result.params[int1].value:= aparams[int1];
  end;
 except
  result.free;
  raise
 end;
end;
                        
procedure getsqlresult(out avalue: variant; const atransaction: tsqltransaction;
                     const asql: msestring; const aparams: array of variant); overload;
           //first field of first row
var
 sqlresult: tsqlresult;
begin
 sqlresult:= dogetsqlresult(atransaction,asql,aparams);
 try
//  sqlresult.asvariant(avalue); //internal error 2006122804
  avalue:= sqlresult.asvariant;
 finally
  sqlresult.free;
 end;
end;

procedure getsqlresult(out avalue: variantarty; const atransaction: tsqltransaction;
                      const asql: msestring; const aparams: array of variant); overload;
           //first row
var
 sqlresult: tsqlresult;
begin
 sqlresult:= dogetsqlresult(atransaction,asql,aparams);
 try
  avalue:= sqlresult.asvariantar;
 finally
  sqlresult.free;
 end;
end;

procedure getsqlresult(out avalue: variantararty; const atransaction: tsqltransaction;
                      const asql: msestring; const aparams: array of variant); overload;
           //whole resultset
var
 sqlresult: tsqlresult;
begin
 sqlresult:= dogetsqlresult(atransaction,asql,aparams);
 try
  avalue:= sqlresult.asvariantarar;
 finally
  sqlresult.free;
 end;
end;

function getsqlresultvar( const atransaction: tsqltransaction;
                      const asql: msestring; 
                      const aparams: array of variant): variant;
begin
 getsqlresult(result,atransaction,asql,aparams);
end;

function getsqlresultvarar( const atransaction: tsqltransaction;
                      const asql: msestring; 
                      const aparams: array of variant): variantarty;
begin
 getsqlresult(result,atransaction,asql,aparams);
end;

function getsqlresultvararar( const atransaction: tsqltransaction;
                      const asql: msestring; 
                      const aparams: array of variant): variantararty;
begin
 getsqlresult(result,atransaction,asql,aparams);
end;
                      
                      
{ tdbcol }

constructor tdbcol.create(const asqlresult: tsqlresult;
                     const acursor: tsqlcursor; const afielddef: tfielddef);
begin
 fsqlresult:= asqlresult;
 fcursor:= acursor;
 ffieldname:= afielddef.name;
 fuppername:= uppercase(ffieldname);
 fdatatype:= afielddef.datatype;
 ffieldnum:= afielddef.fieldno-1;
 fdatasize:= afielddef.size; //used for stringcol
 futf8:= asqlresult.isutf8;
 inherited create;
end;

function tdbcol.accesserror(const typename: string): edatabaseerror;
begin
 result:= edatabaseerror.createfmt(sinvalidtypeconversion,[typename,ffieldname]);
end;

function tdbcol.getvariantvar: variant;
begin
 raise accesserror('variant');
end;

function tdbcol.getasvariant: variant;
begin
 if isnull then begin
  result:= unassigned;
 end
 else begin
  result:= getvariantvar;
 end;
end;

function tdbcol.getasboolean: boolean;
begin
 result:= getasinteger <> 0;
end;

function tdbcol.getascurrency: currency;
begin
 result:= getasfloat;
end;

function tdbcol.getaslargeint: largeint;
begin
 result:= getasinteger;
end;

function tdbcol.getasdatetime: tdatetime;
begin
 raise accesserror(sdatetime);
end;

function tdbcol.getasfloat: double;
begin
 result:= getaslargeint;
end;

function tdbcol.getasinteger: longint;
begin
 raise accesserror(sinteger);
end;

function tdbcol.getasstring: string;
begin
 raise accesserror(sstring);
end;

function tdbcol.getasmsestring: msestring;
var
 str1: ansistring;
begin
 str1:= getasstring;
 if futf8 then begin
  result:= utf8tostring(str1);
 end
 else begin
  result:= str1;
 end;
end;

function tdbcol.getisnull: boolean;
var
 int1: integer;
begin
 int1:= 0;
 result:= not fsqlresult.active or 
            not fsqlresult.fdatabase.loadfield(fsqlresult.fcursor,
            fdatatype,ffieldnum,nil,int1)
end;

function tdbcol.loadfield(const buffer: pointer; var bufsize: integer): boolean;
begin
 result:= fsqlresult.active;
 if result then begin
  result:= fsqlresult.fdatabase.loadfield(fsqlresult.fcursor,
             fdatatype,ffieldnum,buffer,bufsize);
 end;
end;

function tdbcol.loadfield(const buffer: pointer): boolean;
var
 int1: integer;
begin
 int1:= 0;
 result:= fsqlresult.active;
 if result then begin
  result:= fsqlresult.fdatabase.loadfield(fsqlresult.fcursor,
             fdatatype,ffieldnum,buffer,int1);
 end;
end;

{ tlongintdbcol }

function tlongintdbcol.getasinteger: integer;
begin
 if not loadfield(@result) then begin
  result:= 0;
 end;
end;

{ tlargeintdbcol }

function tlargeintdbcol.getaslargeint: largeint;
begin
 if not loadfield(@result) then begin
  result:= 0;
 end;
end;

function tlargeintdbcol.getasinteger: integer;
begin
 result:= getaslargeint;
end;

function tlargeintdbcol.getvariantvar: variant;
begin
 result:= aslargeint;
end;

{ tsmallintdbcol }

function tsmallintdbcol.getasinteger: integer;
var
 buf: smallint;
begin
 if not loadfield(@buf) then begin
  result:= 0;
 end
 else begin
  result:= buf;
 end;
end;

{ tworddbcol }

function tworddbcol.getasinteger: integer;
var
 buf: word;
begin
 if not loadfield(@buf) then begin
  result:= 0;
 end
 else begin
  result:= buf;
 end;
end;

{ tfloatdbcol }

function tfloatdbcol.getasfloat: double;
begin
 if not loadfield(@result) then begin
  result:= emptyreal;
 end;
end;

function tfloatdbcol.getascurrency: currency;
var
 do1: double;
begin
 if not loadfield(@do1) then begin
  result:= 0;
 end
 else begin
  result:= do1;
 end;
end;

function tfloatdbcol.getvariantvar: variant;
begin
 result:= asfloat;
end;

{ tcurrencydbcol }

function tcurrencydbcol.getascurrency: currency;
begin
 if not loadfield(@result) then begin
  result:= 0;
 end;
end;

function tcurrencydbcol.getasfloat: double;
begin
 result:= getascurrency;
end;

function tcurrencydbcol.getvariantvar: variant;
begin
 result:= ascurrency;
end;

{ tbooleandbcol }

function tbooleandbcol.getasboolean: boolean;
var
 buf: wordbool;
begin
 if not loadfield(@buf) then begin
  result:= false;
 end
 else begin
  result:= buf;
 end;
end;

function tbooleandbcol.getvariantvar: variant;
begin
 result:= asboolean;
end;

{ tdatetimedbcol }

function tdatetimedbcol.getasdatetime: tdatetime;
begin
 if not loadfield(@result) then begin
  result:= emptydatetime;
 end
end;

function tdatetimedbcol.getvariantvar: variant;
begin
 result:= asdatetime;
end;

{ tstringdbcol }

function tstringdbcol.getasstring: ansistring;
var
 int1: integer;
begin
 int1:= fdatasize*4+4; //room for multibyte encodings
 setlength(result,int1);
 if not loadfield(pointer(result),int1) then begin
  result:= '';
 end
 else begin
  if int1 < 0 then begin //too small
   int1:= -int1;
   setlength(result,int1);
   loadfield(pointer(result),int1);
  end;
  setlength(result,int1);
 end;
end;

function tstringdbcol.getvariantvar: variant;
begin
 result:= asmsestring;
end;

{ tblobdbcol }

function tblobdbcol.getasstring: ansistring;
begin
 with fsqlresult do begin
  if active then begin
   result:= fdatabase.fetchblob(fcursor,ffieldnum);
  end
  else begin
   result:= '';
  end;
 end;
end;

function tblobdbcol.getvariantvar: variant;
begin
 result:= asstring;
end;

{ tdbcols }

constructor tdbcols.create(const agetname: getnamefuncty);
begin
 fgetname:= agetname;
 inherited create(tdbcol);
end;

function tdbcols.getitems(const index: integer): tdbcol;
begin
 result:= tdbcol (inherited getitems(index));
end;

procedure tdbcols.initfields(const asqlresult: tsqlresult;
                   const acursor: tsqlcursor; const afielddefs: tfielddefs);
var
 int1: integer;
 fdef1: tfielddef;
begin
 for int1:= 0 to afielddefs.count - 1 do begin
  fdef1:= afielddefs[int1];
  add(msedbcoltypeclasses[tfieldtypetotypety[fdef1.datatype]].
                                 create(asqlresult,acursor,fdef1));
 end;
end;

function tdbcols.findcol(const aname: ansistring): tdbcol;
var
 str1: ansistring;
 int1: integer;
begin
 str1:= uppercase(aname);
 for int1:= 0 to high(fitems) do begin
  result:= tdbcol(fitems[int1]);
  if result.fuppername = str1 then begin
   exit;
  end;
 end;
 result:= nil;
end;

function tdbcols.colbyname(const aname: ansistring): tdbcol;
begin
 result:= findcol(aname);
 if result = nil then begin
  raise edatabaseerror.create(fgetname()+': col "'+aname+'" not found.');
 end;
end;

function tdbcols.colsbyname(const anames: array of ansistring): dbcolarty;
var
 int1: integer;
begin
 setlength(result,high(anames)+1);
 for int1:= 0 to high(result) do begin
  result[int1]:= colbyname(anames[int1]);
 end;
end;

{ tsqlresult }

constructor tsqlresult.create(aowner: tcomponent);
begin
 fbof:= true;
 feof:= true;
 fparams:= tmseparams.create(self);
 ffielddefs:= tsqlresultfielddefs.create(nil);
 fsql:= tsqlstringlist.create;
 fsql.onchange:= @onchangesql;
 fcols:= tdbcols.create(@getname);
 inherited;
end;

destructor tsqlresult.destroy;
begin
 active:= false;
 database:= nil;
 transaction:= nil;
 inherited;
 fsql.free;
 fparams.free;
 ffielddefs.free;
 fcols.free;
end;

procedure tsqlresult.setsql(const avalue: tsqlstringlist);
begin
 fsql.assign(avalue);
end;

function tsqlresult.getactive: boolean;
begin
 result:= factive;
end;

procedure tsqlresult.setactive(avalue: boolean);
begin
 if csreading in componentstate then begin
  fopenafterread:= avalue;
 end
 else begin
  if factive <> avalue then begin
   if avalue then begin
    open;
   end
   else begin
    fopenafterread:= false;
    close;
   end;
  end;
 end;
end;

function tsqlresult.isutf8: boolean;
begin
 result:= (sro_utf8 in foptions);
 if fdatabase <> nil then begin
  fdatabase.updateutf8(result);
 end;
end;

procedure tsqlresult.setdatabase1(const avalue: tcustomsqlconnection);
begin
 setdatabase(avalue);
end;

procedure tsqlresult.setdatabase(const avalue: tmdatabase);
begin
 dosetsqldatabase(isqlclient(self),avalue,fcursor,fdatabase);
end;

function tsqlresult.getname: ansistring;
begin
 result:= name;
end;

function tsqlresult.getsqltransaction: tsqltransaction;
begin
 result:= ftransaction;
end;

procedure tsqlresult.setsqltransaction(const avalue: tsqltransaction);
begin
 settransaction(avalue);
end;

procedure tsqlresult.settransaction(const avalue: tmdbtransaction);
begin
 dosettransaction(itransactionclient(self),avalue,ftransaction,false);
end;

procedure tsqlresult.settransactionwrite(const avalue: tmdbtransaction);
begin
 //dummy
end;

procedure tsqlresult.open;
begin
 if fbeforeopen <> nil then begin
  fbeforeopen.execute;
 end;
 prepare;
 execute;
// ffielddefs.clear;
 fdatabase.addfielddefs(fcursor,ffielddefs);
 fcols.initfields(self,fcursor,ffielddefs);
 factive:= true;
 feof:= false;
 next;
 fbof:= true;
 if fafteropen <> nil then begin
  fafteropen.execute;
 end;
 changed;
end;

procedure tsqlresult.close;
begin
 factive:= false;
 feof:= true;
 fbof:= true;
 freefldbuffers;
 unprepare;
// ffielddefs.clear; //is now published
 fcols.clear;
 changed;
end;

procedure tsqlresult.freefldbuffers;
begin
 if fcursor <> nil then begin
  tcustomsqlconnection(database).FreeFldBuffers(FCursor);
 end;
end;

procedure tsqlresult.unprepare;
begin
 CheckInactive(active,name);
 if IsPrepared  then begin
  with tcustomsqlconnection(Database) do begin
   UnPrepareStatement(FCursor);
  end;
 end;
end;

procedure tsqlresult.prepare;
var
 db: tcustomsqlconnection;
 trans: tsqltransaction;
 str1: msestring;
 bo1: boolean;
begin
 if not isprepared then begin
  checkdatabase(name,fdatabase);
  bo1:= sro_utf8 in foptions;
  fdatabase.updateutf8(bo1);
  if bo1 then begin
   foptions:= foptions + [sro_utf8];
  end
  else begin
   foptions:= foptions - [sro_utf8];
  end;  
  checktransaction(name,ftransaction);
  str1:= trimright(fsql.text);
  if str1 = '' then begin
   raise edatabaseerror.create(name+': Empty query.');
  end;
  db:= tcustomsqlconnection(fdatabase);
  trans:= tsqltransaction(ftransaction);
  db.connected:= true;
  trans.active:= true;
  if not assigned(fcursor) then begin
   fcursor:= db.allocatecursorhandle(nil,name);
  end;
  fcursor.ftrans:= trans.handle;
  fcursor.fstatementtype:= stselect;
   
  Db.PrepareStatement(Fcursor,trans,str1,FParams);
  FCursor.FInitFieldDef:= True;
 end;
end;

procedure tsqlresult.setparams(const avalue: tmseparams);
begin
 fparams.assign(avalue);
end;

function tsqlresult.isprepared: boolean;
begin
 result:= (fcursor <> nil) and fcursor.fprepared;
end;

procedure tsqlresult.execute;
begin
 doexecute(fparams,ftransaction,fcursor,fdatabase,isutf8);
end;

procedure tsqlresult.loaded;
begin
 inherited;
 try
  active:= fopenafterread;
 except
  if csdesigning in componentstate then begin
   application.handleexception(self);
  end
  else begin
   raise;
  end;
 end;
end;

procedure tsqlresult.onchangesql(const sender: tobject);
var
 bo1: boolean;
begin
 bo1:= (csdesigning in componentstate) and active;
 if bo1 then begin
  active:= false;
 end;
 unprepare;
 fparams.parsesql(fsql.text,true);
 if bo1 then begin
  active:= true;
 end;
end;

procedure tsqlresult.next;
begin
 checkactive(active,name);
 fbof:= false;
 if feof then begin
  raise edatabaseerror.create(name+': EOF.');
 end;
 feof:= not fdatabase.fetch(fcursor);
end;

procedure tsqlresult.refresh;
begin
 if not active then begin
  active:= true;
 end
 else begin
  fcursor.close;
  feof:= false;
  execute; 
  next;
  fbof:= true;
  changed;
 end;
end;

procedure tsqlresult.setbeforeopen(const avalue: tmsesqlscript);
begin
 setlinkedvar(avalue,fbeforeopen);
end;

procedure tsqlresult.setafteropen(const avalue: tmsesqlscript);
begin
 setlinkedvar(avalue,fafteropen);
end;

procedure tsqlresult.changed;
begin
 sendchangeevent;
end;

procedure tsqlresult.setfielddefs(const avalue: tsqlresultfielddefs);
begin
 ffielddefs.assign(avalue);
end;

function tsqlresult.getsqltransactionwrite: tsqltransaction;
begin
 result:= nil;
end;

procedure tsqlresult.setsqltransactionwrite(const avalue: tsqltransaction);
begin
 //dummy
end;
{
function tsqlresult.asvariant: variant;
var
 int1,int2: integer;
 var1: variant;
begin
 refresh;
 if eof or (cols.count = 0) then begin
  result:= null;
 end
 else begin
  var1:= vararraycreate([0,cols.count-1],varvariant);
  for int1:= 0 to cols.count - 1 do begin
   var1[int1]:= cols[int1].asvariant;
  end;
  next;
  if eof then begin
   result:= var1;
  end
  else begin
   result:= vararraycreate([0,cols.count-1,0,1],varvariant);
   for int1:= 0 to cols.count - 1 do begin
    result[int1,0]:= var1[int1];
   end;
   int2:= 1;
   while true do begin
    for int1:= 0 to cols.count - 1 do begin
     result[int1,int2]:= cols[int1].asvariant;
    end;
    next;
    if eof then begin
     break;
    end;
    inc(int2);
    vararrayredim(result,int2);
   end;
  end;
 end;
end;
}

function tsqlresult.asvariant: variant;
begin
 refresh;
 if eof or (cols.count = 0) then begin
  result:= unassigned;
 end
 else begin
  result:= cols[0].asvariant;
 end;
 while not eof do begin
  next; //eat the rest;
 end;
end;

function tsqlresult.asvariantar: variantarty;
var
 int1: integer;
begin
 refresh;
 if eof or (cols.count = 0) then begin
  result:= unassigned;
 end
 else begin
  setlength(result,cols.count);
  for int1:= 0 to high(result) do begin
   result[int1]:= cols[int1].asvariant;
  end;
 end;
 while not eof do begin
  next; //eat the rest;
 end;
end;

function tsqlresult.asvariantarar: variantararty;
var
 int1,int2: integer;
begin
 refresh;
 if eof or (cols.count = 0) then begin
  result:= unassigned;
  while not eof do begin
   next; //eat the rest;
  end;
 end
 else begin
  setlength(result,256);
  int2:= 0;
  while not eof do begin
   if int2 > high(result) then begin
    setlength(result,high(result)*2);
   end;
   setlength(result[int2],cols.count);
   for int1:= 0 to cols.count - 1 do begin
    result[int2][int1]:= tdbcol(fcols.fitems[int1]).asvariant;
   end;
   inc(int2);
   next;
  end;
  setlength(result,int2);
 end;
end;

function tsqlresult.rowsreturned: integer;
begin
 if active then begin
  result:= fcursor.frowsreturned;
 end
 else begin
  result:= -1
 end;
end;

{ tdbcolnamearrayprop }

constructor tdbcolnamearrayprop.create(const afieldtypes: fieldtypesty;
               const agetsqlresult: getsqlresultfuncty);
begin
 ffieldtypes:= afieldtypes;
 fgetsqlresult:= agetsqlresult;
 inherited create;
end;

function tdbcolnamearrayprop.getsqlresult(const aindex: integer): tsqlresult;
begin
 result:= fgetsqlresult(aindex);
end;

procedure tdbcolnamearrayprop.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 setlength(afieldtypes,1);
 afieldtypes[0]:= ffieldtypes;
end;

{ tsqllookupbuffer }

constructor tsqllookupbuffer.create(aowner: tcomponent);
begin
 fintegercols:= tdbcolnamearrayprop.create(
                   msedb.integerfields+[ftboolean],
                      {$ifdef FPC}@{$endif}getsqlresult);
 ftextcols:= tdbcolnamearrayprop.create(
                   msedb.textfields+[ftboolean],
                  {$ifdef FPC}@{$endif}getsqlresult);
 ffloatcols:= tdbcolnamearrayprop.create(msedb.realfields + msedb.datetimefields,
                      {$ifdef FPC}@{$endif}getsqlresult);
 fintegercols.onchange:= @fieldschanged;
 ftextcols.onchange:= @fieldschanged;
 ffloatcols.onchange:= @fieldschanged;
 inherited;
end;

destructor tsqllookupbuffer.destroy;
begin
 fintegercols.free;
 ftextcols.free;
 ffloatcols.free;
 inherited;
end;

procedure tsqllookupbuffer.setsource(const avalue: tsqlresult);
begin
 setlinkedvar(avalue,fsource);
 invalidatebuffer;
end;

procedure tsqllookupbuffer.settextcols(const avalue: tdbcolnamearrayprop);
begin
 ftextcols.assign(avalue);
end;

procedure tsqllookupbuffer.setintegercols(const avalue: tdbcolnamearrayprop);
begin
 fintegercols.assign(avalue);
end;

procedure tsqllookupbuffer.setfloatcols(const avalue: tdbcolnamearrayprop);
begin
 ffloatcols.assign(avalue);
end;

function tsqllookupbuffer.getsqlresult(const aindex: integer): tsqlresult;
begin
 result:= fsource;
end;

procedure tsqllookupbuffer.clearbuffer;
begin
 setlength(fintegerdata,fintegercols.count);
 setlength(ftextdata,ftextcols.count);
 setlength(ffloatdata,ffloatcols.count);
 inherited;
end;

function tsqllookupbuffer.getfieldcounttext: integer;
begin
 result:= ftextcols.count;
end;

function tsqllookupbuffer.getfieldcountinteger: integer;
begin
 result:= fintegercols.count;
end;

function tsqllookupbuffer.getfieldcountfloat: integer;
begin
 result:= ffloatcols.count;
end;

procedure tsqllookupbuffer.setfieldcounttext(const avalue: integer);
begin
 readonlyprop;
end;

procedure tsqllookupbuffer.setfieldcountinteger(const avalue: integer);
begin
 readonlyprop;
end;

procedure tsqllookupbuffer.setfieldcountfloat(const avalue: integer);
begin
 readonlyprop;
end;

procedure tsqllookupbuffer.loadbuffer;
var
 int1,int3,int4: integer;
 textf: array of tdbcol;
 integerf: array of tdbcol;
 realf: array of tdbcol;
 ar1: stringarty;
 bo1: boolean;
begin
 application.beginwait;
 beginupdate;
 try
  clearbuffer;
  include(fstate,lbs_buffervalid);
  with fsource do begin
   if (fsource <> nil) and (active or (olbsq_closesqlresult in foptionsdb) {and
               not (csloading in componentstate)}) then begin
    try
     bo1:= active;
     if not bof then begin
      refresh;
     end;
     try
      setlength(ar1,ftextcols.count);
      for int1:= 0 to high(ar1) do begin
       ar1[int1]:= ftextcols[int1];
      end;
      textf:= cols.colsbyname(ar1);
      setlength(ar1,fintegercols.count);
      for int1:= 0 to high(ar1) do begin
       ar1[int1]:= fintegercols[int1];
      end;
      integerf:= cols.colsbyname(ar1);
      setlength(ar1,floatcols.count);
      for int1:= 0 to high(ar1) do begin
       ar1[int1]:= ffloatcols[int1];
      end;
      realf:= cols.colsbyname(ar1);
      int3:= 0;
      int1:= 0;
      try
       while not fsource.eof do begin
        if int3 <= int1 then begin
         int3:= (int3 * 3) div 2 + 100;
         for int4:= 0 to high(ftextdata) do begin
          setlength(ftextdata[int4].data,int3);
         end;
         for int4:= 0 to high(fintegerdata) do begin
          setlength(fintegerdata[int4].data,int3);
         end;
         for int4:= 0 to high(ffloatdata) do begin
          setlength(ffloatdata[int4].data,int3);
         end;
        end;
        for int4:= 0 to high(integerf) do begin
         if integerf[int4] <> nil then begin
          fintegerdata[int4].data[int1]:= integerf[int4].asinteger;
         end;
        end;
        for int4:= 0 to high(realf) do begin
         if realf[int4] <> nil then begin
          if realf[int4].isnull then begin
           ffloatdata[int4].data[int1]:= emptyreal;
          end
          else begin
           ffloatdata[int4].data[int1]:= realf[int4].asfloat;
          end;
         end;
        end;
        for int4:= 0 to high(textf) do begin
         if textf[int4] <> nil then begin
          ftextdata[int4].data[int1]:= textf[int4].asmsestring;
         end;
        end;
        inc(int1);
        fsource.next;
       end;
      finally
       for int4:= 0 to high(fintegerdata) do begin
        setlength(fintegerdata[int4].data,int1);
       end;
       for int4:= 0 to high(ftextdata) do begin
        setlength(ftextdata[int4].data,int1);
       end;
       for int4:= 0 to high(ffloatdata) do begin
        setlength(ffloatdata[int4].data,int1);
       end;
       fcount:= int1;
      end;
     finally
      if not bo1 and (olbsq_closesqlresult in foptionsdb) then begin
       fsource.active:= false;
      end;
     end;
    except
     if csdesigning in componentstate then begin
      application.handleexception(self);
     end
     else begin
      raise;
     end;        
    end;
   end;   
  end;
 finally
  application.endwait;
  endupdate;
 end;
end;

procedure tsqllookupbuffer.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (sender = fsource) and (event = oe_changed) and (fupdating = 0) and
     (fsource <> nil) and
     (fsource.active or not (olbsq_closesqlresult in foptionsdb)) then begin
  invalidatebuffer;
  changed;
 end;
end;

{ tsqlresultfielddefs }

procedure tsqlresultfielddefs.setitemname(aitem: tcollectionitem);
begin
 {$ifdef mse_FPC_2_2}
 if aitem is tnameditem then begin
  with tnameditem(aitem) do begin
  {$else}
 if aitem is tfielddef then begin
  with tfielddef(aitem) do begin
  {$endif}
   if name = '' then begin
    name:= 'fielddef' + inttostr(id+1);
   end
   else begin
    inherited;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

{ tnumericdbcol }

function tnumericdbcol.getvariantvar: variant;
begin
 result:= asinteger;
end;

{ tmemodbcol }

function tmemodbcol.getvariantvar: variant;
begin
 result:= asmsestring;
end;

end.
