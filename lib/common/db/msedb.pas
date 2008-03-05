{ MSEgui Copyright (c) 2004-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedb;

{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$define hasaswidestring} {$endif}
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 classes,db,mseclasses,mseglob,msestrings,msetypes,msearrayprops,mseapplication,
 sysutils,msebintree,mseact;
 
type
 fieldtypearty = array of tfieldtype;
 fieldtypesty = set of tfieldtype;
 fieldtypesarty = array of fieldtypesty;
 datasetarty = array of tdataset;
const
 charfields = [ftstring,ftfixedchar];
 textfields = [ftstring,ftfixedchar,ftwidestring,ftmemo];
 memofields = textfields+[ftmemo];
 integerfields = [ftsmallint,ftinteger,ftword,ftlargeint,ftbcd];
 booleanfields = [ftboolean,ftstring,ftfixedchar]+integerfields-[ftbcd];
 realfields = [ftfloat,ftcurrency,ftbcd];
 datetimefields = [ftdate,fttime,ftdatetime];
 stringfields = textfields + integerfields + booleanfields +
                realfields + datetimefields;
 blobfields = [ftblob,ftmemo,ftgraphic{,ftstring}];
 defaultproviderflags = [pfInUpdate,pfInWhere];

 varsizefields = [ftstring,ftbytes,ftvarbytes,ftwidestring];
 
 converrorstring = '?';
 
type
 isqlpropertyeditor = interface(inullinterface)
                            ['{001C24B7-548C-4A4D-A42D-6FBAFBAA7A57}']
  procedure setactive(avalue: boolean);
  function getactive: boolean;
  function isutf8: boolean;
 end; 

 filtereditkindty = (fek_filter,fek_filtermin,fek_filtermax,fek_find);
 locateresultty = (loc_timeout,loc_notfound,loc_ok); 
 locateoptionty = (loo_caseinsensitive,loo_partialkey,
                        loo_noforeward,loo_nobackward);
 locateoptionsty = set of locateoptionty;
 fieldarty = array of tfield;

 imselocate = interface(inullinterface)['{2680958F-F954-DA11-9015-00C0CA1308FF}']
   function locate(const key: integer; const field: tfield;
                     const options: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield;
                 const options: locateoptionsty = []): locateresultty;
 end;
  
 idbeditinfo = interface(inullinterface)['{E63A9950-BFAE-DA11-83DF-00C0CA1308FF}']
  function getdatasource(const aindex: integer): tdatasource;
  procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
    //propertynames = nil -> propertyname = 'datafield'
 end;

 ireccontrol = interface(inullinterface)['{E24D8F6A-0A01-4BAB-B778-300775A15CF6}']
  procedure recchanged;
 end;
 
 ipersistentfieldsinfo = interface(inullinterface)
                   ['{A8493C65-34BB-DA11-9DCA-00C0CA1308FF}'] 
  function getfieldnames: stringarty;
 end;
 
  
 getdatasourcefuncty = function: tdatasource of object;
 
 tdbfieldnamearrayprop = class(tstringarrayprop,idbeditinfo)
  private
   ffieldtypes: fieldtypesty;
   fgetdatasource: getdatasourcefuncty;
  protected
   //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource;
   procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
  public
   constructor create(const afieldtypes: fieldtypesty;
                         const agetdatasource: getdatasourcefuncty);
   property fieldtypes: fieldtypesty read ffieldtypes write ffieldtypes;
 end;

type
 tdscontroller = class;

 ifieldcomponent = interface;
  
 idsfieldcontroller = interface(inullinterface)
  function getcontroller: tdscontroller;
  procedure fielddestroyed(const sender: ifieldcomponent);
 end;
 
 ifieldcomponent = interface(inullinterface)['{81BB6312-74BA-4B50-963D-F1DB908F7FB7}']
  procedure setdsintf(const avalue: idsfieldcontroller);
  function getinstance: tfield;
 end;
  
 tmsefield = class(tfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
   function HasParent: Boolean; override;
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
  public
   procedure Clear; override;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 
 tmsestringfield = class;
 
 getmsestringdataty = function(const sender: tmsestringfield;
                     out avalue: msestring): boolean of object; //false if null
 setmsestringdataty = procedure(const sender: tmsestringfield;
                          const avalue: msestring) of object;
 
 tmsestringfield = class(tstringfield,ifieldcomponent)
  private
   fdsintf: idsfieldcontroller;
   fgetmsestringdata: getmsestringdataty;
   fsetmsestringdata: setmsestringdataty;
   fcharacterlength: integer;
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   //ifieldcomponent
   procedure setdsintf(const avalue: idsfieldcontroller);
   function getinstance: tfield;
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   procedure setismsestring(const getter: getmsestringdataty;
                                             const setter: setmsestringdataty;
                                             const acharacterlength: integer);
   function HasParent: Boolean; override;
   function GetDataSize: Word; override;
   function GetAsString: string; override;
   function GetAsVariant: variant; override;
   procedure SetAsString(const AValue: string); override;
   procedure SetVarValue(const AValue: Variant); override;
  public
   destructor destroy; override;
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   function oldmsestring(out aisnull: boolean): msestring;
   property characterlength: integer read fcharacterlength;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;

 tmsenumericfield = class(tnumericfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmselongintfield = class(tlongintfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   procedure setasenum(const avalue: integer);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
   procedure setaslargeint(avalue: largeint); override;
   function getaslargeint: largeint; override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   property asenum: integer read getaslongint write setasenum;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmselargeintfield = class(tlargeintfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   property Value: Largeint read GetAsLargeint write SetAsLargeint;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsesmallintfield = class(tsmallintfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsewordfield = class(twordfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmseautoincfield = class(tautoincfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsefloatfield = class(tfloatfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function getasfloat: double; override;
   function getascurrency: currency; override;
   procedure setasfloat(avalue: double); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsecurrencyfield = class(tcurrencyfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   procedure setasfloat(avalue: double); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsebooleanfield = class(tbooleanfield)
  private
   fdisplayvalues: msestring;
   fdisplays : array[boolean,boolean] of msestring;
   procedure setdisplayvalues(const avalue: msestring);
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function GetDataSize: Word; override;
   function GetAsBoolean: Boolean; override;
   procedure SetAsBoolean(AValue: Boolean); override;
   function getasstring: string; override;
   procedure setasstring(const avalue: string); override;
   function GetDefaultWidth: Longint; override;
   function GetAsLongint: Longint; override;
   procedure SetAsLongint(AValue: Longint); override;
   function GetAsVariant: variant; override;
  public
   constructor Create(AOwner: TComponent); override;
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
   property displayvalues: msestring read fdisplayvalues write setdisplayvalues;
 end;
 
 datetimefieldoptionty = (dtfo_utc,dtfo_local); //DB time format
 datetimefieldoptionsty = set of datetimefieldoptionty;
                       
 tmsedatetimefield = class(tdatetimefield)
  private
   foptions: datetimefieldoptionsty;
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   procedure setoptions(const avalue: datetimefieldoptionsty);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   function getasdatetime: tdatetime; override;
   procedure setasdatetime(avalue: tdatetime); override;
   procedure setasstring(const avalue: string); override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
   property options: datetimefieldoptionsty read foptions write setoptions;
 end; 
 tmsedatefield = class(tmsedatetimefield)
  public
   constructor create(aowner: tcomponent); override;
 end;
 tmsetimefield = class(tmsedatetimefield)
  public
   constructor create(aowner: tcomponent); override;
 end;
 
 tmsebinaryfield = class(tbinaryfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsebytesfield = class(tbytesfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsevarbytesfield = class(tvarbytesfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 tmsebcdfield = class(tbcdfield)
  private
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
  protected
  {$ifdef hasaswidestring}
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
  {$endif}
   function HasParent: Boolean; override;
   procedure setasfloat(avalue: double); override;
   class procedure checktypesize(avalue: longint); override;
  public
   procedure Clear; override;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   property Value: Currency read GetAsCurrency write SetAsCurrency;
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 
 blobidty = record
             id: int64;
             local: boolean;
            end;
            
 getblobidfuncty = function(const afield: tfield; out aid: blobidty): boolean
                                                of object;

 tblobcachenode = class(tstringcachenode)
  private
   flocal: boolean;
  public
   constructor create(const akey: blobidty; const adata: string); overload;
 end;
 
 tblobcache = class(tstringcacheavltree)
  private
   ffindnode: tblobcachenode;
  public
   constructor create;
   destructor destroy; override;
   function addnode(const akey: blobidty; 
                           const adata: string): tblobcachenode; overload;
   function find(const akey: blobidty; 
                           out anode: tblobcachenode): boolean; overload;
 end;
 
 tmseblobfield = class(tblobfield)
  private
   fcache: tblobcache;
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   procedure setcachekb(const avalue: integer);
   function getcachekb: integer;
  protected
   fgetblobid: getblobidfuncty;
   procedure removecache(const aid: blobidty); virtual; overload;
   procedure removecache; overload;
   function HasParent: Boolean; override;
   function getasvariant: variant; override;
   function getasstring: string; override;
   procedure setasstring(const avalue: string); override;
   procedure gettext(var atext: string; adisplaytext: boolean); override;
  public
   destructor destroy; override;
   procedure Clear; override;
   procedure clearcache; virtual;
   function assql: string;
   function asoldsql: string;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   procedure LoadFromStream(Stream: TStream);
   procedure LoadFromFile(const FileName: filenamety);
   procedure SaveToFile(const FileName: filenamety);
  published
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
   property cachekb: integer read getcachekb write setcachekb;
                //cachesize in kilo bytes, 0 -> no cache
 end;
 tmsememofield = class(tmseblobfield,ifieldcomponent)
  private
   fdsintf: idsfieldcontroller;
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   //ifieldcomponent
   procedure setdsintf(const avalue: idsfieldcontroller);
   function getinstance: tfield;
  protected
   function getasvariant: variant; override;
   procedure setvarvalue(const avalue: variant); override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure Clear; override;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   function oldmsestring(out aisnull: boolean): msestring;
   function assql: string;
   function asoldsql: string;
  published
   property Transliterate default True;
   property DataSet stored false;
   property ProviderFlags default defaultproviderflags;
 end;
 
 tmsedatalink = class(tdatalink)
  private
   function getrecnonullbased: integer;
   procedure setrecnonullbased(const avalue: integer);
  protected
   fcanclosing: integer;
   fdscontroller: tdscontroller;
   procedure activechanged; override;
   function getdataset: tdataset;
   function getutf8: boolean;
   function getfiltereditkind: filtereditkindty;
   function  GetActiveRecord: Integer; override;
  public
   function moveby(distance: integer): integer; override;
   property dataset: tdataset read getdataset;
   property dscontroller: tdscontroller read fdscontroller;
   property utf8: boolean read getutf8;
   property filtereditkind: filtereditkindty read getfiltereditkind;
   function canclose: boolean;
   property recnonullbased: integer read getrecnonullbased 
                                          write setrecnonullbased;
 end;

 tfielddatalink = class(tmsedatalink)
  private
   ffield: tfield;
   ffieldname: string;
   fismsestring: boolean;
   procedure setfieldname(const Value: string);
   procedure updatefield;
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   procedure checkfield;
   function GetAsBoolean: Boolean;
   procedure SetAsBoolean(const avalue: Boolean);
   function GetAsCurrency: Currency;
   procedure SetAsCurrency(const avalue: Currency);
   function GetAsDateTime: TDateTime;
   procedure SetAsDateTime(const avalue: TDateTime);
   function GetAsFloat: Double;
   procedure SetAsFloat(const avalue: Double);
   function GetAsLongint: Longint;
   procedure SetAsLongint(const avalue: Longint);
   function GetAsLargeInt: LargeInt;
   procedure SetAsLargeInt(const avalue: LargeInt);
   function GetAsInteger: Integer;
   procedure SetAsInteger(const avalue: Integer);
   function GetAsString: string;
   procedure SetAsString(const avalue: string);
   function GetAsVariant: variant;
   procedure SetAsVariant(const avalue: variant);
  protected
   procedure setfield(const value: tfield); virtual;
   procedure activechanged; override;
   procedure layoutchanged; override;
  public
   function assql: string;
   function fieldactive: boolean;
   property field: tfield read ffield;
   property fieldname: string read ffieldname write setfieldname;
   
   property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
   property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
   property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
   property AsFloat: Double read GetAsFloat write SetAsFloat;
   property AsLongint: Longint read GetAsLongint write SetAsLongint;
   property AsLargeInt: LargeInt read GetAsLargeInt write SetAsLargeInt;
   property AsInteger: Integer read GetAsInteger write SetAsInteger;
   property AsString: string read GetAsString write SetAsString;
   property AsVariant: variant read GetAsVariant write SetAsVariant;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   function msedisplaytext(const aformat: msestring = ''): msestring;
 end;
 
 fieldarrayty = array of tfield;
 
 fieldclassty = class of tfield;
 
 fieldclasstypety = (ft_unknown,ft_string,ft_numeric,
                     ft_longint,ft_largeint,ft_smallint,
                     ft_word,ft_autoinc,ft_float,ft_currency,ft_boolean,
                     ft_datetime,ft_date,ft_time,
                     ft_binary,ft_bytes,ft_varbytes,
                     ft_bcd,ft_blob,ft_memo,ft_graphic);
 fieldclasstypearty = array of fieldclasstypety; 
        
 tmsedatasource = class(tdatasource)
 end;
 
 tpersistentfields = class(tpersistentarrayprop,ipersistentfieldsinfo)
  private
   fdataset: tdataset;
   procedure readfields(reader: treader);
   procedure writefields(writer: twriter);
   procedure setitems(const index: integer; const avalue: tfield);
   function getitems(const index: integer): tfield;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const adataset: tdataset);
   procedure move(const curindex,newindex: integer); override;
   procedure updateorder;
   function getfieldnames: stringarty;
   property dataset: tdataset read fdataset;
   property items[const index: integer]: tfield read getitems write setitems; default;
 end;

 datasetoptionty = (dso_utf8,dso_numboolean,dso_initinternalcalc,
                         dso_refreshtransaction,
                         dso_cancelupdateonerror,dso_cancelupdatesonerror,                         
                         dso_autoapply,{dso_applyonidle,}
                         dso_autocommitret,dso_autocommit,
                         dso_refreshafterapply,
                         dso_cacheblobs,
                         dso_offline, //disconnect database after open
                         dso_local);  //do not connect database on open
 datasetoptionsty = set of datasetoptionty;

 idscontroller = interface(inullinterface)
  procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
  procedure inheritedcancel;
  procedure inheritedpost;
  function inheritedmoveby(const distance: integer): integer;
  procedure inheritedinternalinsert;
  procedure inheritedinternalopen;
  procedure inheritedinternalclose;
  procedure openlocal;
  procedure inheritedinternaldelete;
  function getblobdatasize: integer;
  function getnumboolean: boolean;
  function getfloatdate: boolean;
  function getint64currency: boolean;
  function getfiltereditkind: filtereditkindty;
  procedure beginfilteredit(const akind:filtereditkindty);
  procedure endfilteredit;
  procedure doidleapplyupdates;
 end;

 igetdscontroller = interface(inullinterface)
             ['{0BF9F81D-D420-44FB-AE1C-0343C823CB95}']
  function getcontroller: tdscontroller;
 end;

const
 defaultdscontrolleroptions = [];
 de_modified = ord(high(tdataevent))+1;
 allfieldkinds = [fkData,fkCalculated,fkLookup,fkInternalCalc];
  
type
 fieldlinkarty = array of ifieldcomponent;
 dscontrollerstatety = (dscs_posting,dscs_onidleregistered);
 dscontrollerstatesty = set of dscontrollerstatety;
 
 tdscontroller = class(tactivatorcontroller,idsfieldcontroller)
  private
   ffields: tpersistentfields;
   fintf: idscontroller;
   fneedsrefresh: integer;
   frecno: integer;
   frecnovalid: boolean;
   fscrollsum: integer;
   factiverecordbefore: integer;
   frecnooffset: integer;
   fmovebylock: boolean;
   fcancelresync: boolean;
   finsertbm: string;
   flinkedfields: fieldlinkarty;
   foptions: datasetoptionsty;
   fstate: dscontrollerstatesty;
   fdelayedapplycount: integer;
   procedure setfields(const avalue: tpersistentfields);
   function getcontroller: tdscontroller;
   procedure updatelinkedfields;
   function getrecnonullbased: integer;
   procedure setrecnonullbased(const avalue: integer);
   function getrecno: integer;
   procedure setrecno(const avalue: integer);
   procedure registeronidle;
   procedure unregisteronidle;
   procedure setdelayedapplycount(const avalue: integer);
  protected
   procedure setoptions(const avalue: datasetoptionsty); virtual;
   procedure modified;
   procedure setowneractive(const avalue: boolean); override;
   procedure fielddestroyed(const sender: ifieldcomponent);
   procedure doonidle(var again: boolean);
  public
   constructor create(const aowner: tdataset; const aintf: idscontroller;
                      const arecnooffset: integer = 0;
                      const acancelresync: boolean = true);
   destructor destroy; override;
   function isutf8: boolean;
   function getfieldar(const afieldkinds: tfieldkinds = allfieldkinds): fieldarty;
   function filtereditkind: filtereditkindty;
   function locate(const key: integer; const field: tfield;
                       const options: locateoptionsty = []): locateresultty;
                       overload;
   function locate(const key: msestring; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty; overload;
   procedure appendrecord(const values: array of const);
   procedure getfieldclass(const fieldtype: tfieldtype; out result: tfieldclass);
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   
   procedure dataevent(const event: tdataevent; info: ptrint);
   procedure cancel;
   property recno: integer read getrecno write setrecno;
   property recnonullbased: integer read getrecnonullbased 
                                       write setrecnonullbased;
   property recnooffset: integer read frecnooffset;
   function moveby(const distance: integer): integer;
   procedure internalinsert;
   procedure internaldelete;
   procedure internalopen;
   procedure internalclose;
   procedure closequery(var amodalresult: modalresultty);
   function closequery: boolean; //true if ok
   function post: boolean; //calls post if in edit or insert state,
                           //returns false if nothing done
   function posting: boolean; //true if in post procedure
   function emptyinsert: boolean;
   function assql(const avalue: boolean): string; overload;
   function assql(const avalue: msestring): string; overload;
   function assql(const avalue: integer): string; overload;
   function assql(const avalue: int64): string; overload;
   function assql(const avalue: currency): string; overload;
   function assqlcurrency(const avalue: realty): string; overload;
   function assql(const avalue: realty): string; overload;
   function assql(const avalue: tdatetime): string; overload;
   function assqldate(const avalue: tdatetime): string;
   function assqltime(const avalue: tdatetime): string;
  published
   property fields: tpersistentfields read ffields write setfields;
   property options: datasetoptionsty read foptions write setoptions 
                   default defaultdscontrolleroptions;
   property delayedapplycount: integer read fdelayedapplycount 
                                       write setdelayedapplycount;
               //0 -> no autoapply
 end;
 
 idbcontroller = interface(inullinterface)
          ['{B26D004A-7FEE-44F2-9919-3B8612BDD598}']
  procedure setinheritedconnected(const avalue: boolean);
  function readsequence(const sequencename: string): string;
  function writesequence(const sequencename: string;
                    const avalue: largeint): string;
  function ExecuteDirect(const SQL : mseString): integer;
  procedure updateutf8(var autf8: boolean);
 end;
   
 tfieldlink = class;
 
 tfieldlinkdatalink = class(tfielddatalink)
  private
   fdatasource: tdatasource;
   fowner: tfieldlink;
  protected
   procedure updatedata; override;
  public
   constructor create(const aowner: tfieldlink);
   destructor destroy; override;
 end;

 fieldeventty = procedure(const afield: tfield) of object;
 
 fieldlinkoptionty = (flo_onlyifnull,flo_notifunmodifiedinsert);
 fieldlinkoptionsty = set of fieldlinkoptionty;
  
 tfieldlink = class(tmsecomponent,idbeditinfo)
  private
   fdestdatalink: tfieldlinkdatalink;
   fonupdatedata: fieldeventty;
   foptions: fieldlinkoptionsty;
   function getdestdataset: tdataset;
   procedure setdestdataset(const avalue: tdataset);
   function getdestdatafield: string;
   procedure setdestdatafield(const avalue: string);
   //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
   function getdatasource(const aindex: integer): tdatasource;
  protected
   procedure updatedata(const afield: tfield); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function field: tfield;
  published
   property destdataset: tdataset read getdestdataset write setdestdataset;
   property destdatafield: string read getdestdatafield write setdestdatafield;
   property options: fieldlinkoptionsty read foptions write foptions default [];
   property onupdatedata: fieldeventty read fonupdatedata write fonupdatedata;
 end;
 
 ttimestampfieldlink = class(tfieldlink)
  protected
   procedure updatedata(const afield: tfield); override;
 end;
   
 tfieldfieldlink = class(tfieldlink,idbeditinfo)
  private
   fsourcedatalink: tfielddatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource; overload;
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
  protected
   procedure updatedata(const afield: tfield); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function sourcefield: tfield;
  published
   property datafield: string read getdatafield 
                             write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
 
 tmseparams = class(tparams)
  private
   fisutf8: boolean;
  public
   Function  ParseSQL(const SQL: mseString; const DoCreate: Boolean): mseString; overload;
   Function  ParseSQL(const SQL: mseString;
                      const DoCreate,EscapeSlash,EscapeRepeat: Boolean;
                      const ParameterStyle : TParamStyle): mseString; overload;
   Function  ParseSQL(const SQL: mseString;
                      const DoCreate,EscapeSlash,EscapeRepeat: Boolean;
                      const ParameterStyle : TParamStyle;
                      var ParamBinding: TParambinding): mseString; overload;
   Function  ParseSQL(const SQL: mseString;
               const DoCreate,EscapeSlash,EscapeRepeat: Boolean;
               const ParameterStyle : TParamStyle; var ParamBinding: TParambinding;
               var ReplaceString : msestring): mseString; overload;
   function expandvalues(sql: msestring; const aparambindings: tparambinding;
                         const aparamreplacestring: msestring): msestring; overload;
                                //sql parsed with psSimulated
   function expandvalues(const sql: msestring): msestring; overload;
   function asdbstring(const index: integer): string;
   property isutf8: boolean read fisutf8 write fisutf8;
 end;
 
const
 fieldtypeclasses: array[fieldclasstypety] of fieldclassty = 
          (tfield,tstringfield,tnumericfield,
           tlongintfield,tlargeintfield,tsmallintfield,
           twordfield,tautoincfield,tfloatfield,tcurrencyfield,
           tbooleanfield,
           tdatetimefield,tdatefield,ttimefield,
           tbinaryfield,tbytesfield,tvarbytesfield,
           tbcdfield,tblobfield,tmemofield,tgraphicfield);

 tfieldtypetotypety: array[tfieldtype] of fieldclasstypety = (
    //ftUnknown, ftString, ftSmallint, ftInteger, ftWord,
      ft_unknown,ft_string,ft_smallint,ft_longint,ft_word,
    //ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate,  ftTime, ftDateTime,
      ft_boolean,ft_float,ft_currency,ft_bcd,ft_date,ft_time,ft_datetime,
    //ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
      ft_bytes,ft_varbytes,ft_autoinc,ft_blob,ft_memo,ft_graphic,ft_memo,
    //ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar,
      ft_unknown,ft_unknown,ft_unknown,ft_unknown,ft_string,
    //ftWideString, ftLargeint, ftADT, ftArray, ftReference,
      ft_unknown,ft_largeint,ft_unknown,ft_unknown,ft_unknown,
    //ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface,
      ft_unknown,ft_unknown,ft_unknown,ft_unknown,ft_unknown,
    //ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd
      ft_unknown,ft_unknown,ft_unknown,ft_unknown
      {$ifdef mse_FPC_2_2}
    //ftFixedWideChar,ftWideMemo
      ,ft_unknown,    ft_unknown 
      {$endif}
      );

 realfcomp = [ftfloat,ftcurrency];
 datetimefcomp = [ftdate,fttime,ftdatetime];
 blobfcomp = [ftblob,ftgraphic,ftmemo];
 memofcomp = [ftmemo];
 longintfcomp = [ftboolean,ftsmallint,ftinteger,ftword];
 stringfcomp = [ftstring,ftfixedchar];
 booleanfcomp = [ftboolean,ftsmallint,ftinteger,ftword];
      
 fieldcompatibility: array[tfieldtype] of fieldtypesty = (
    //ftUnknown, ftString,    ftSmallint,    ftInteger,     ftWord,
      [ftunknown],stringfcomp,longintfcomp,longintfcomp,longintfcomp,
    //ftBoolean,   ftFloat, ftCurrency, ftBCD,
      booleanfcomp,realfcomp,realfcomp,[ftbcd],
    //ftDate,        ftTime,       tDateTime,
      datetimefcomp,datetimefcomp,datetimefcomp,
    //ftBytes, ftVarBytes, ftAutoInc,
      [ftbytes],[ftvarbytes],[ftautoinc],
    // ftBlob, ftMemo, ftGraphic, ftFmtMemo,
      blobfcomp,memofcomp,blobfcomp,memofcomp,
    //ftParadoxOle, ftDBaseOle, ftTypedBinary,     ftCursor, tFixedChar,
      [ftParadoxOle],[ftDBaseOle],[ftTypedBinary],[ftCursor],stringfcomp,
    //ftWideString, ftLargeint, ftADT, ftArray, ftReference,
     [ftWideString],[ftLargeint],[ftADT],[ftArray],[ftReference],
    //ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface,
      [ftDataSet],[ftOraBlob],[ftOraClob],[ftVariant],[ftInterface],
    //ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd);
      [ftIDispatch],[ftGuid],[ftTimeStamp],[ftFMTBcd]
    {$ifdef mse_FPC_2_2}
    //ftFixedWideChar,ftWideMemo
      ,[ftfixedwidechar],[ftwidememo]   
    {$endif}
      );

function getmsefieldclass(const afieldtype: tfieldtype): tfieldclass; overload;
function getmsefieldclass(const afieldtype: fieldclasstypety): tfieldclass; overload;
function fieldclasstoclasstyp(const fieldclass: fieldclassty): fieldclasstypety;
function fieldtosql(const field: tfield): msestring;
function fieldtooldsql(const field: tfield): msestring;
function paramtosql(const aparam: tparam): msestring;
function fieldchanged(const field: tfield): boolean;
function curfieldchanged(const field: tfield): boolean;
procedure fieldtoparam(const field: tfield; const param: tparam);
procedure msestringtoparam(const avalue: msestring; const param: tparam);
//function getasmsestring(const field: tfield): msestring;
function getasmsestring(const field: tfield; const utf8: boolean): msestring;
function checkfieldcompatibility(const afield: tfield;
                     const adatatype: tfieldtype): boolean;
           //true if ok
function vartorealty(const avalue: variant): realty;
function locaterecord(const adataset: tdataset; const autf8: boolean; 
                         const key: msestring; const field: tfield;
                         const options: locateoptionsty = []): locateresultty;
function locaterecord(const adataset: tdataset; const key: integer;
                       const field: tfield;
                       const options: locateoptionsty = []): locateresultty;

function encodesqlstring(const avalue: msestring): msestring;
function encodesqlblob(const avalue: string): msestring;
function encodesqldatetime(const avalue: tdatetime): msestring;
function encodesqldate(const avalue: tdatetime): msestring;
function encodesqltime(const avalue: tdatetime): msestring;
function encodesqlfloat(const avalue: real): msestring;
function encodesqlcurrency(const avalue: currency): msestring;
function encodesqlboolean(const avalue: boolean): msestring;

procedure regfieldclass(const atype: fieldclasstypety; const aclass: fieldclassty);

procedure varianttorealty(const value: variant; out dest: realty); overload;
function varianttorealty(const value: variant):realty; overload;
procedure realtytovariant(const value: realty; out dest: variant); overload;
function realtytovariant(const value: realty): variant; overload;

implementation
uses
 rtlconsts,msefileutils,typinfo,dbconst,msedatalist,mseformatstr,
 msereal,variants,msebits,msedate{,msedbgraphics}{$ifdef unix},cwstring{$endif};

var
 msefieldtypeclasses: array[fieldclasstypety] of fieldclassty = 
          (tmsefield,tmsestringfield,tmsenumericfield,
           tmselongintfield,tmselargeintfield,tmsesmallintfield,
           tmsewordfield,tmseautoincfield,tmsefloatfield,tmsecurrencyfield,
           tmsebooleanfield,
           tmsedatetimefield,tmsedatefield,tmsetimefield,
           tmsebinaryfield,tmsebytesfield,tmsevarbytesfield,
           tmsebcdfield,tmseblobfield,tmsememofield,nil{tmsegraphicfield});
           
type
 {$ifdef mse_FPC_2_2}
 TFieldDefcracker = class(TNamedItem)
 {$else}
 TFieldDefcracker = class(TCollectionItem)
 {$endif}
  Private
    FDataType : TFieldType;
    FFieldNo : Longint;
    FInternalCalcField : Boolean;
    FPrecision : Longint;
    FRequired : Boolean;
    FSize : Word;
 end;
 tdataset1 = class(tdataset);

procedure varianttorealty(const value: variant; out dest: realty);
begin
 if varisnull(value) then begin
  dest:= emptyreal;
 end
 else begin
  real(dest):= value;
 end;
end;

function varianttorealty(const value: variant): realty; overload;
begin
 if varisnull(value) then begin
  result:= emptyreal;
 end
 else begin
  real(result):= value;
 end;
end;

procedure realtytovariant(const value: realty; out dest: variant);
begin
 if isemptyreal(value) then begin
  dest:= null;
 end
 else begin
  dest:= value;
 end;
end;

function realtytovariant(const value: realty): variant; overload;
begin
 if isemptyreal(value) then begin
  result:= null;
 end
 else begin
  result:= value;
 end;
end;

procedure regfieldclass(const atype: fieldclasstypety; const aclass: fieldclassty);
begin
 msefieldtypeclasses[atype]:= aclass;
end;
 
function getmsefieldclass(const afieldtype: tfieldtype): tfieldclass;
begin
 result:= msefieldtypeclasses[tfieldtypetotypety[afieldtype]];
end;

function getmsefieldclass(const afieldtype: fieldclasstypety): tfieldclass;
begin
 result:= msefieldtypeclasses[afieldtype];
end;

{
function getasmsestring(const field: tfield): msestring;
begin
 if field is tmsestringfield then begin
  result:= tmsestringfield(field).asmsestring;
 end
 else begin
  if field is tmsememofield then begin
   result:= tmsememofield(field).asmsestring;
  end
  else begin
   result:= field.asstring;
  end;
 end;
end;
}
function getasmsestring(const field: tfield; const utf8: boolean): msestring;
begin
 if utf8 then begin
  result:= utf8tostring(field.asstring);
 end
 else begin
  result:= field.asstring;
 end;
end;

procedure msestringtoparam(const avalue: msestring; const param: tparam);
var
 intf1: igetdscontroller;
begin
 with param do begin
  if dataset <> nil then begin
   if getcorbainterface(dataset,typeinfo(igetdscontroller),intf1) then begin
    if dso_utf8 in intf1.getcontroller.options then begin
     param.asstring:= stringtoutf8(avalue);
     exit;
    end;
   end;
  end;
  param.asstring:= avalue;
 end;
end;

procedure fieldtoparam(const field: tfield; const param: tparam);
begin
 param.value:= field.value; //paramvalue is variant anyway
 {
 with param do begin
  case field.datatype of
   ftUnknown:  DatabaseErrorFmt(SUnknownParamFieldType,[Name],DataSet);
      // Need TField.AsSmallInt
   ftSmallint: AsSmallInt:= Field.AsInteger;
      // Need TField.AsWord
   ftWord:     AsWord:= Field.AsInteger;
   ftInteger,
   ftAutoInc:  AsInteger:= Field.AsInteger;
      // Need TField.AsCurrency
   ftCurrency: AsCurrency:= Field.asFloat;
   ftFloat:    AsFloat:= Field.asFloat;
   ftBoolean:  AsBoolean:= Field.AsBoolean;
   ftBlob,
   ftGraphic..ftTypedBinary,
   ftOraBlob,
   ftOraClob,
   ftString,
   ftMemo,
   ftAdt,
   ftFixedChar: AsString:= Field.AsString;
   ftTime,
   ftDate,
   ftDateTime: AsDateTime:= Field.AsDateTime;
   ftBytes,
   ftVarBytes: ; // Todo.
   else begin
    if not (DataType in [ftCursor, ftArray, ftDataset,ftReference]) then begin
        DatabaseErrorFmt(SBadParamFieldType, [Name], DataSet);
    end;
   end;
  end;
 end;
 }
end;

function encodesqlstring(const avalue: msestring): msestring;
var
 int1: integer;
 str1: msestring;
 po1: pmsechar;
begin
 str1:= avalue;
 setlength(result,length(str1)*2 + 2); //max
 po1:= pmsechar(result);
 po1^:= '''';
 inc(po1);
 for int1:= 1 to length(str1) do begin
  po1^:= str1[int1];
  if po1^ = '''' then begin
   inc(po1);
   po1^:= '''';
  end;
  inc(po1);
 end;
 po1^:= '''';
 setlength(result,po1-pmsechar(result)+1);
end;

function encodesqlblob(const avalue: string): msestring;
var
 int1: integer;
 po1: pmsechar;
 po2: pbyte;

begin
 setlength(result,length(avalue)*2+3);
 po1:= pmsechar(result);
 po1^:= 'x';
 inc(po1);
 po1^:= '''';
 inc(po1);
 po2:= pointer(avalue);
 for int1:= 0 to length(avalue) - 1 do begin
  po1^:= charhex[po2^ shr 4];
  inc(po1);
  po1^:= charhex[po2^ and $0f];
  inc(po1);
  inc(po2);
 end;
 po1^:= '''';
end;

function encodesqldatetime(const avalue: tdatetime): msestring;
begin
 result := '''' + formatdatetime('yyyy-mm-dd hh:mm:ss',avalue) + '''';
end;

function encodesqldate(const avalue: tdatetime): msestring;
begin
 result:= '''' + formatdatetime('yyyy-mm-dd',avalue) + '''';
end;

function encodesqltime(const avalue: tdatetime): msestring;
begin
 result:= '''' + formatdatetime('hh:mm:ss',avalue) + '''';
end;

function encodesqlfloat(const avalue: real): msestring;
begin
 result:= replacechar(floattostr(avalue),decimalseparator,'.');
//( result:= formatfloatmse(avalue,'');
end;

function encodesqlcurrency(const avalue: currency): msestring;
begin
 result:= replacechar(formatfloat('0.####',avalue),decimalseparator,'.')
// result:= formatfloatmse(avalue,'0.####');
end;

function encodesqlboolean(const avalue: boolean): msestring;
begin
 if avalue then begin
  result:= '''t''';
 end
 else begin
  result:= '''f''';
 end;
end;

function fieldtosql(const field: tfield): msestring;
begin
 if (field = nil) or field.isnull then begin
  result:= 'NULL'
 end
 else begin
  case field.datatype of
   ftstring: begin
    if not (field is tmsestringfield) {or 
         (tmsestringfield(field).fdsintf = nil)} then begin
     result:= encodesqlstring(field.asstring);
//     result:= tmsestringfield(field).assql;
    end
    else begin
     with tmsestringfield(field) do begin
      result:= encodesqlstring(asmsestring);
//      result:= fdsintf.getcontroller.assql(asmsestring);     
     end;
    end;
   end;
   ftmemo: begin
    if field is tmsememofield then begin
     result:= encodesqlstring(tmsememofield(field).asmsestring);
    end
    else begin
     result:= encodesqlstring(field.asstring);
    end;
   end;
   ftblob,ftgraphic: begin
    result:= encodesqlblob(field.asstring);
   end;
   ftdate: begin
    result := encodesqldate(field.asdatetime)
   end;
   fttime: begin
    result := encodesqltime(field.asdatetime)
   end;
   ftdatetime: begin
    result:= encodesqldatetime(field.asdatetime);
   end;
   ftfloat: begin
    result:= encodesqlfloat(field.asfloat);
   end;
   ftbcd: begin
    result:= encodesqlcurrency(field.ascurrency);
   end;
   ftboolean: begin
    result:= encodesqlboolean(field.asboolean);
   end;
   else begin
    result := field.asstring;
   end;
  end;
 end;
end;

function fieldtooldsql(const field: tfield): msestring;
var
 statebefore: tdatasetstate;
begin
 statebefore:= field.dataset.state;
 tdataset1(field.dataset).settempstate(dsoldvalue);
 result:= fieldtosql(field);
 tdataset1(field.dataset).restorestate(statebefore);
end;
 
function paramtosql(const aparam: tparam): msestring;
begin
 with aparam do begin
  if (aparam = nil) or isnull then begin
   result:= 'NULL'
  end
  else begin
   case datatype of
    ftstring,ftwidestring: begin
     if (aparam.collection is tmseparams) and 
                         tmseparams(aparam.collection).isutf8 then begin
      result:= encodesqlstring(stringtoutf8(aswidestring));
     end
     else begin
      result:= encodesqlstring(asstring);
     end;
    end;
    ftmemo: begin
     result:= encodesqlstring(asstring);
    end;
    ftblob,ftgraphic: begin
     result:= encodesqlblob(asstring);
    end;
    ftdate: begin
     result := encodesqldate(asdatetime)
    end;
    fttime: begin
     result := encodesqltime(asdatetime)
    end;
    ftdatetime: begin
     result:= encodesqldatetime(asdatetime);
    end;
    ftfloat: begin
     result:= encodesqlfloat(asfloat);
    end;
    ftbcd: begin
     result:= encodesqlcurrency(ascurrency);
    end;
    ftboolean: begin
     result:= encodesqlboolean(asboolean);
    end;
    else begin
     result := asstring;
    end;
   end;
  end;
 end;
end;

function dofieldchanged(const field: tfield; const astate: tdatasetstate): boolean;
      //todo: fast compare in tbufdataset
var
 statebefore: tdatasetstate;
 isnull: boolean;
 ds1: tdataset1;
 int1: integer;
 bo1: boolean;
 str1: string;
 wstr1: widestring;
 mstr1: msestring;
 rea1: real;
 int641: int64;
 cur1: currency;
begin
 result:= false;
 if field.fieldno > 0 then begin
  ds1:= tdataset1(field.dataset);
  statebefore:= ds1.state;
  isnull:= field.isnull;
  if field is tmsestringfield then begin
   mstr1:= tmsestringfield(field).asmsestring;
   ds1.settempstate(astate); 
   result:= (field.isnull xor isnull) or 
                 (mstr1 <> tmsestringfield(field).asmsestring);
  end
  else begin
   case field.datatype of
    ftString,ftFixedChar,ftmemo,ftblob: begin
     str1:= field.asstring;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (str1 <> field.asstring);
    end;
    ftSmallint,ftInteger,ftWord: begin
     int1:= field.asinteger;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (int1 <> field.asinteger);
    end;
    ftBoolean: begin
     bo1:= field.asboolean;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (bo1 <> field.asboolean);
    end; 
    ftFloat,ftDate,ftTime,ftDateTime,ftTimeStamp,ftFMTBcd: begin
     rea1:= field.asfloat;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (rea1 <> field.asfloat);
    end;
    ftCurrency,ftBCD: begin
     cur1:= field.ascurrency;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (cur1 <> field.ascurrency);
    end;
 //    ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
 //    ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, 
    ftWideString: begin
 //    wstr1:= field.aswidestring;
     wstr1:= field.asstring;
     ds1.settempstate(astate); 
 //    result:= (field.isnull xor isnull) or (wstr1 <> field.aswidestring);
     result:= (field.isnull xor isnull) or (wstr1 <> field.asstring);
    end;
    ftLargeint: begin
     int641:= tlargeintfield(field).aslargeint;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or 
                 (int641 <> tlargeintfield(field).aslargeint);
    end;
 //    ftADT, ftArray, ftReference,
 //    ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface,
 //    ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd);
 
   end;
  end;
  ds1.restorestate(statebefore); 
 end;
end;

function fieldchanged(const field: tfield): boolean;
begin
 result:= dofieldchanged(field,dsoldvalue);
end;

function curfieldchanged(const field: tfield): boolean;
begin
 result:= dofieldchanged(field,dscurvalue);
end;

function fieldclasstoclasstyp(const fieldclass: fieldclassty): fieldclasstypety;
var
 type1: fieldclasstypety;
begin
 result:= fieldclasstypety(-1);
 for type1:= low(fieldclasstypety) to high(fieldclasstypety) do begin
  if fieldclass = fieldtypeclasses[type1]  then begin
   result:= type1;
   break;
  end;
 end;
 if ord(result) = -1 then begin
  result:= ft_unknown;
  for type1:= low(fieldclasstypety) to high(fieldclasstypety) do begin
   if fieldclass = msefieldtypeclasses[type1]  then begin
    result:= type1;
    break;
   end;
  end;
 end;
end;

function checkfieldcompatibility(const afield: tfield;
                     const adatatype: tfieldtype): boolean;
           //true if ok
begin
 result:= (afield.datatype in fieldcompatibility[adatatype]){ or 
                            (adatatype = ftunknown)};
end;

function vartorealty(const avalue: variant): realty;
begin
 if varisnull(avalue) then begin
  result:= emptyreal;
 end
 else begin
  real(result):= avalue;
 end;
end;

procedure fieldsetmsestring(const avalue: msestring; const sender: tfield;
                                   const aintf: idsfieldcontroller);
begin
 if (aintf <> nil) and (dso_utf8 in aintf.getcontroller.options) then begin
  sender.asstring:= stringtoutf8(avalue);
 end
 else begin
  sender.asstring:= avalue; //locale conversion
 end; 
end;

function fieldgetmsestring(const sender: tfield;
                      const aintf: idsfieldcontroller): msestring;
begin
 if (aintf <> nil) and (dso_utf8 in aintf.getcontroller.options) then begin
  result:= utf8tostring(sender.asstring);
 end
 else begin
  {$ifdef unix}
  try
   result:= sender.asstring;
  except
   on e: eiconv do begin
    //no crash by iconverror
   end
   else begin
    raise;
   end;
  end;
  {$else}
  result:= sender.asstring;
  {$endif}
 end;
end;

function locaterecord(const adataset: tdataset; const key: integer;
                       const field: tfield;
                       const options: locateoptionsty = []): locateresultty;
var
 bm: string;
begin
 with adataset do begin
  checkbrowsemode;
  result:= loc_notfound;
  bm:= bookmark;
  disablecontrols;
  try
   if not (loo_noforeward in options) then begin
    while not eof do begin
     if field.asinteger = key then begin
      result:= loc_ok;
      exit;
     end;
     next;
    end;
   end;
   bookmark:= bm;
   if not (loo_nobackward in options) then begin
    while true do begin
     if field.asinteger = key then begin
      result:= loc_ok;
      exit;
     end;
     if bof then begin
      break;
     end;
     prior;
    end;
   end;
  finally
   try
    if result <> loc_ok then begin
     bookmark:= bm;
    end;
   finally
    enablecontrols;
   end;
  end;
 end;
end;

function locaterecord(const adataset: tdataset; const autf8: boolean; 
                         const key: msestring; const field: tfield;
                         const options: locateoptionsty = []): locateresultty;
var
 int2: integer;
 str1,str2,bm: string;
 mstr1,mstr2: msestring;
 caseinsensitive: boolean;
 ismsestringfield: boolean;
 
 function checkmsestring: boolean;
 var
  int1: integer;
 begin
  if ismsestringfield then begin
   mstr2:= tmsestringfield(field).asmsestring;
  end
  else begin
   if autf8 then begin
    mstr2:= utf8tostring(field.asstring);
   end
   else begin
    mstr2:= field.asstring;
   end;
  end;
  if caseinsensitive then begin
   mstr2:= mseuppercase(mstr2);      //todo: optimize
  end;
  result:= true;
  for int1:= 0 to int2 - 1 do begin
   if pmsechar(mstr1)[int1] <> pmsechar(mstr2)[int1] then begin
    result:= false;
    break;
   end;
   if pmsechar(mstr1)[int1] = #0 then begin
    break;
   end;
  end;
 end;
 
 function checkcasesensitive: boolean;
 var
  int1: integer;
 begin
  str2:= field.asstring;
  result:= true;
  for int1:= 0 to int2 - 1 do begin
   if pchar(str1)[int1] <> pchar(str2)[int1] then begin
    result:= false;
    break;
   end;
   if pchar(str1)[int1] = #0 then begin
    break;
   end;
  end;
 end;
 
begin
 ismsestringfield:= field is tmsestringfield;
 with adataset do begin
  checkbrowsemode;
  result:= loc_notfound;
  bm:= bookmark;
  caseinsensitive:= loo_caseinsensitive in options;
  if caseinsensitive or ismsestringfield then begin 
   if caseinsensitive then begin
    mstr1:= mseuppercase(key);
   end
   else begin
    mstr1:= key;
   end;     
   if loo_partialkey in options then begin
    int2:= length(mstr1);
   end
   else begin
    int2:= bigint;
   end;
  end
  else begin
   if autf8 then begin
    str1:= stringtoutf8(key);
   end
   else begin
    str1:= key;
   end;
   if loo_partialkey in options then begin
    int2:= length(str1);
   end
   else begin
    int2:= bigint;
   end;
  end;
  disablecontrols;
  try
   if not (loo_noforeward in options) then begin
    if caseinsensitive or ismsestringfield then begin
     while not eof do begin
      if checkmsestring then begin
       result:= loc_ok;
       exit;
      end;
      next;
     end;
    end
    else begin
     while not eof do begin
      if checkcasesensitive then begin
       result:= loc_ok;
       exit;
      end;
      next;
     end;
    end;
    bookmark:= bm;
   end;
   if not (loo_nobackward in options) then begin
    if caseinsensitive or ismsestringfield then begin
     while true do begin
      if checkmsestring then begin
       result:= loc_ok;
       exit;
      end;
      if bof then begin
       break;
      end;
      prior;
     end;
    end
    else begin
     while true do begin
      if checkcasesensitive then begin
       result:= loc_ok;
       exit;
      end;
      if bof then begin
       break;
      end;
      prior;
     end;
    end;
   end;
  finally
   try
    if result <> loc_ok then begin
     bookmark:= bm;
    end;
   finally
    enablecontrols;
   end;
  end;
 end;
end;

{ tmsefield }

function tmsefield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

procedure tmsefield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsefield.getasmsestring: msestring;
begin
 result:= asstring;
end;

procedure tmsefield.Clear;
begin
 setdata(nil);
end;

{$ifdef hasaswidestring}
function tmsefield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsefield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

{ tmsestringfield }

destructor tmsestringfield.destroy;
begin
 if fdsintf <> nil then begin
  fdsintf.fielddestroyed(ifieldcomponent(self));
 end;
 inherited;
end;

function tmsestringfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsestringfield.assql: string;
begin
 result:= fieldtosql(self);
end;

function tmsestringfield.getasmsestring: msestring;
begin
 if assigned(fgetmsestringdata) then begin
  fgetmsestringdata(self,result);
 end
 else begin
  result:= fieldgetmsestring(self,fdsintf);
 end;
end;

procedure tmsestringfield.setasmsestring(const avalue: msestring);
begin
 if assigned(fsetmsestringdata) then begin
  fsetmsestringdata(self,avalue);
 end
 else begin
  fieldsetmsestring(avalue,self,fdsintf);
 end;
end;

{$ifdef hasaswidestring}
function tmsestringfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsestringfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsestringfield.setdsintf(const avalue: idsfieldcontroller);
begin
 fdsintf:= avalue;
end;

function tmsestringfield.getinstance: tfield;
begin
 result:= self;
end;

procedure tmsestringfield.Clear;
begin
 setdata(nil);
end;

function tmsestringfield.oldmsestring(out aisnull: boolean): msestring;
var
 statebefore: tdatasetstate;
begin
 statebefore:= tdataset1(dataset).settempstate(dsoldvalue);
 aisnull:= not getdata(nil);
 result:= getasmsestring;
 tdataset1(dataset).restorestate(statebefore);
end;
{
function tmsestringfield.oldmsestring(out aisnull: boolean): msestring;
var
 statebefore: tdatasetstate;
 str1: string;
begin
 statebefore:= tdataset1(dataset).settempstate(dsoldvalue);
 aisnull:= getvalue(str1);
 result:= str1;
 tdataset1(dataset).restorestate(statebefore);
end;
}
procedure tmsestringfield.setismsestring(const getter: getmsestringdataty;
           const setter: setmsestringdataty; const acharacterlength: integer);
begin
 fcharacterlength:= acharacterlength;
 size:= acharacterlength;
 fgetmsestringdata:= getter;
 fsetmsestringdata:= setter;
end;

function tmsestringfield.GetDataSize: Word;
begin
 if assigned(fgetmsestringdata) then begin
  result:= sizeof(msestring);
 end
 else begin
  result:= inherited getdatasize;
 end;
end;

function tmsestringfield.GetAsString: string;
begin
 if assigned(fgetmsestringdata) then begin
  result:= getasmsestring;
 end
 else begin
  result:= inherited getasstring;
 end;
end;

function tmsestringfield.GetAsVariant: variant;
var
 mstr1: msestring;
begin
 if assigned(fgetmsestringdata) then begin
  if fgetmsestringdata(self,mstr1) then begin
   result:= mstr1;
  end
  else begin
   result:= null;
  end;
 end
 else begin
  inherited getasvariant;
 end;
end;

procedure tmsestringfield.SetAsString(const AValue: string);
begin
 if assigned(fsetmsestringdata) then begin
  fsetmsestringdata(self,avalue);
 end
 else begin
  inherited;
 end;
end;

procedure tmsestringfield.SetVarValue(const AValue: Variant);
begin
 if assigned(fsetmsestringdata) then begin
  fsetmsestringdata(self,avalue);
 end
 else begin
  inherited;
 end;
end;

function tmsestringfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsestringfield.getmsevalue(out avalue: msestring): boolean;
begin
 result:= fgetmsestringdata(self,avalue);
end;

procedure tmsestringfield.setmsevalue(const avalue: msestring);
begin
 fsetmsestringdata(self,avalue);
end;
}
{ tmsememofield }

constructor tmsememofield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftmemo);
end;

destructor tmsememofield.destroy;
begin
 if fdsintf <> nil then begin
  fdsintf.fielddestroyed(ifieldcomponent(self));
 end;
 inherited;
end;
{
function tmsememofield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;
}
function tmsememofield.assql: string;
begin
 result:= fieldtosql(self);
end;

function tmsememofield.getasmsestring: msestring;
begin
 result:= fieldgetmsestring(self,fdsintf);
end;

procedure tmsememofield.setasmsestring(const avalue: msestring);
begin
 fieldsetmsestring(avalue,self,fdsintf);
end;

procedure tmsememofield.setdsintf(const avalue: idsfieldcontroller);
begin
 fdsintf:= avalue;
end;

function tmsememofield.getinstance: tfield;
begin
 result:= self;
end;

procedure tmsememofield.Clear;
begin
 setdata(nil);
end;

function tmsememofield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

function tmsememofield.getasvariant: variant;
begin
 if isnull then begin
  result:= NULL;
 end
 else begin
  result:= getasmsestring;
 end;
end;

procedure tmsememofield.setvarvalue(const avalue: variant);
begin
 setasmsestring(avalue);
end;

function tmsememofield.oldmsestring(out aisnull: boolean): msestring;
var
 statebefore: tdatasetstate;
begin
 statebefore:= tdataset1(dataset).settempstate(dsoldvalue);
 aisnull:= getdata(nil);
 result:= getasmsestring;
 tdataset1(dataset).restorestate(statebefore);
end;

procedure tmsememofield.gettext(var thetext: string; adisplaytext: boolean);
begin
 thetext:= asstring;
end;

{ tmsenumericfield }

function tmsenumericfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsenumericfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsenumericfield.setasmsestring(const avalue: msestring);
begin
 asstring:= value;
end;

function tmsenumericfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsenumericfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsenumericfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsenumericfield.Clear;
begin
 setdata(nil);
end;

function tmsenumericfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmselongintfield }

function tmselongintfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmselongintfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmselongintfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmselongintfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmselongintfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmselongintfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

function tmselongintfield.getasboolean: boolean;
begin
 result:= asinteger <> 0;
end;

procedure tmselongintfield.setasboolean(avalue: boolean);
begin
 if avalue then begin
  asinteger:= 1;
 end
 else begin
  asinteger:= 0;
 end;
end;

procedure tmselongintfield.Clear;
begin
 setdata(nil);
end;

procedure tmselongintfield.setasenum(const avalue: integer);
begin
 if avalue = -1 then begin
  clear;
 end
 else begin
  asinteger:= avalue;
 end;
end;

function tmselongintfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

procedure tmselongintfield.setaslargeint(avalue: largeint);
begin
 if (avalue < minint) or (avalue > maxint) then begin
  rangeerror(avalue,minint,maxint);
 end;
 setaslongint(avalue);
end;

function tmselongintfield.getaslargeint: largeint;
begin
 result:= getaslongint;
end;

{ tmselargeintfield }

function tmselargeintfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmselargeintfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmselargeintfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmselargeintfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmselargeintfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmselargeintfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

function tmselargeintfield.getasboolean: boolean;
begin
 result:= asinteger <> 0;
end;

procedure tmselargeintfield.setasboolean(avalue: boolean);
begin
 if avalue then begin
  asinteger:= 1;
 end
 else begin
  asinteger:= 0;
 end;
end;

procedure tmselargeintfield.Clear;
begin
 setdata(nil);
end;

function tmselargeintfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsesmallintfield }

function tmsesmallintfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsesmallintfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsesmallintfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsesmallintfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsesmallintfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsesmallintfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

function tmsesmallintfield.getasboolean: boolean;
begin
 result:= asinteger <> 0;
end;

procedure tmsesmallintfield.setasboolean(avalue: boolean);
begin
 if avalue then begin
  asinteger:= 1;
 end
 else begin
  asinteger:= 0;
 end;
end;

procedure tmsesmallintfield.Clear;
begin
 setdata(nil);
end;

function tmsesmallintfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsewordfield }

function tmsewordfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsewordfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsewordfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsewordfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsewordfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsewordfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

function tmsewordfield.getasboolean: boolean;
begin
 result:= asinteger <> 0;
end;

procedure tmsewordfield.setasboolean(avalue: boolean);
begin
 if avalue then begin
  asinteger:= 1;
 end
 else begin
  asinteger:= 0;
 end;
end;

procedure tmsewordfield.Clear;
begin
 setdata(nil);
end;

function tmsewordfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmseautoincfield }

function tmseautoincfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmseautoincfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmseautoincfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmseautoincfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmseautoincfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmseautoincfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmseautoincfield.Clear;
begin
 setdata(nil);
end;

function tmseautoincfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsefloatfield }

function tmsefloatfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsefloatfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsefloatfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsefloatfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsefloatfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsefloatfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

function tmsefloatfield.getasfloat: double;
begin
 if not getdata(@result) then begin
  result:= emptyreal;
 end;
end;

function tmsefloatfield.getascurrency: currency;
begin
 result:= inherited getasfloat;
end;

procedure tmsefloatfield.setasfloat(avalue: double);
begin
 if isemptyreal(avalue) then begin
  clear;
 end
 else begin
  inherited;
 end;
end;

procedure tmsefloatfield.Clear;
begin
 setdata(nil);
end;

function tmsefloatfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsecurrencyfield }

function tmsecurrencyfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsecurrencyfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsecurrencyfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsecurrencyfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsecurrencyfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsecurrencyfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsecurrencyfield.Clear;
begin
 setdata(nil);
end;

function tmsecurrencyfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

procedure tmsecurrencyfield.setasfloat(avalue: double);
begin
 if isemptyreal(avalue) then begin
  clear;
 end
 else begin
  inherited;
 end;
end;

{ tmsebooleanfield }

constructor tmsebooleanfield.Create(AOwner: TComponent);
begin
 inherited;
 displayvalues:= 'True;False';
end;

function tmsebooleanfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebooleanfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsebooleanfield.setasmsestring(const avalue: msestring);
var
 mstr1: msestring;
begin
 if avalue= '' then begin
  clear;
 end
 else begin
  mstr1:= mseuppercase(avalue);
  if pos(mstr1,fdisplays[true,false]) = 1 then begin
   asboolean:= false;
  end
  else begin
   if pos(mstr1,fdisplays[true,true]) = 1 then begin
    asboolean:= true;
   end
   else begin
    DatabaseErrorFmt(SNotABoolean,[string(AValue)]);
   end;
  end;
 end;
end;

function tmsebooleanfield.getasmsestring: msestring;
var 
 int1: integer;
begin
 int1:= 0;
 if getdata(@int1) then begin
  result:= fdisplays[false,int1 <> 0]
 end
 else begin
  result:='';
 end;
end;

{$ifdef hasaswidestring}
function tmsebooleanfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebooleanfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsebooleanfield.Clear;
begin
 setdata(nil);
end;

procedure tmsebooleanfield.setdisplayvalues(const avalue: msestring);
var
 ar1: msestringarty;
begin
 if fdisplayvalues <> avalue then begin
  ar1:= splitstring(avalue,';');
  if (high(ar1) <> 1) or (ar1[0] = ar1[1]) then begin
   databaseerrorfmt(SInvalidDisplayValues,[string(avalue)]);
  end;
  fdisplayvalues:= avalue;
    // Store display values and their uppercase equivalents;
  fdisplays[false,true]:= ar1[0];
  fdisplays[true,true]:= mseUpperCase(ar1[0]);
  fdisplays[false,false]:= ar1[1];
  fdisplays[true,false]:= mseuppercase(ar1[1]);
  propertychanged(true);
 end;
end;

function tmsebooleanfield.getasstring: string;
begin
 result:= getasmsestring;
end;

procedure tmsebooleanfield.setasstring(const avalue: string);
begin
 setasmsestring(avalue);
end;

function tmsebooleanfield.GetDefaultWidth: Longint;
begin
 result:= length(fdisplays[false,false]);
 if result < length(fdisplays[false,true]) then begin
  result:= length(fdisplays[false,true]);
 end;
end;

function tmsebooleanfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

function tmsebooleanfield.GetAsLongint: Longint;
begin
 if getasboolean then begin
//  result:= -1;
  result:= 1;
 end
 else begin
  result:= 0;
 end;
end;

procedure tmsebooleanfield.SetAsLongint(AValue: Longint);
begin
 if avalue = 0 then begin
  setasboolean(false);
 end
 else begin
  setasboolean(true);
 end;
end;

function tmsebooleanfield.GetDataSize: Word;
begin
 result:= sizeof(longbool);
end;

function tmsebooleanfield.GetAsBoolean: Boolean;
var
 int1: integer;
begin
 int1:= 0;
 if getdata(@int1) then begin
  result:= int1 <> 0;
 end
 else begin
  result:= false;
 end;
end;

procedure tmsebooleanfield.SetAsBoolean(AValue: Boolean);
var
 int1: integer;
begin
 if avalue then begin
//  int1:= -1;
  int1:= 1;
 end
 else begin
  int1:= 0;
 end;
 setdata(@int1);
end;

function tmsebooleanfield.GetAsVariant: variant;
var
 int1: integer;
begin
 int1:= 0;
 if getdata(@int1) then begin
  result:= int1 <>  0;
 end
 else begin
  result:= null;
 end;
end;

{ tmsedatetimefield }

function tmsedatetimefield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsedatetimefield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsedatetimefield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsedatetimefield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsedatetimefield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsedatetimefield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

function tmsedatetimefield.getasdatetime: tdatetime;
begin
 if not getdata(@result,false) then begin
  result:= emptydatetime;
 end
 else begin
  if dtfo_utc in foptions then begin
   result:= utctolocaltime(result);
  end;
  if dtfo_local in foptions then begin
   result:= localtimetoutc(result);
  end;
 end;
end;

procedure tmsedatetimefield.setasdatetime(avalue: tdatetime);
begin
 if isemptydatetime(avalue) then begin
  clear;
 end
 else begin
  if dtfo_utc in foptions then begin
   avalue:= localtimetoutc(avalue);
  end;
  if dtfo_local in foptions then begin
   avalue:= utctolocaltime(avalue);
  end;
  inherited;
 end;
end;

procedure tmsedatetimefield.Clear;
begin
 setdata(nil);
end;

function tmsedatetimefield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

procedure tmsedatetimefield.setoptions(const avalue: datetimefieldoptionsty);
const
 mask: datetimefieldoptionsty = [dtfo_utc,dtfo_local];
begin
 foptions:= datetimefieldoptionsty(setsinglebit(longword(avalue),
                                        longword(foptions),longword(mask)));
end;

procedure tmsedatetimefield.setasstring(const avalue: string);
begin
 setasdatetime(strtodatetime(avalue));
end;

procedure tmsedatetimefield.gettext(var thetext: string; adisplaytext: boolean);
var
 r: tdatetime;
 f: string;
begin
 if isnull then begin
  thetext:=''
 end
 else begin
  r:= getasdatetime;
  if adisplaytext and (length(displayformat) <> 0) then begin
   f:= displayformat;
  end
  else begin
   case datatype of
    fttime: f:= shorttimeformat;
    ftdate: f:= shortdateformat;
    else f:= 'c'
   end;
  end;
  thetext:= formatdatetime(f,r);
 end;
end;

{ tmsedatefield }

constructor tmsedatefield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftdate); 
end;

{
function tmsedatefield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsedatefield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsedatefield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsedatefield.getasmsestring: msestring;
begin
 result:= asstring;
end;

function tmsedatefield.getasdatetime: tdatetime;
begin
 if isnull then begin
  result:= emptydatetime;
 end
 else begin
  result:= inherited getasdatetime;
 end;
end;

procedure tmsedatefield.setasdatetime(avalue: tdatetime);
begin
 if isemptydatetime(avalue) then begin
  clear;
 end
 else begin
  inherited;
 end;
end;

procedure tmsedatefield.Clear;
begin
 setdata(nil);
end;

function tmsedatefield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;
}

{ tmsetimefield }

constructor tmsetimefield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(fttime); 
end;

{
function tmsetimefield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsetimefield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsetimefield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsetimefield.getasmsestring: msestring;
begin
 result:= asstring;
end;

function tmsetimefield.getasdatetime: tdatetime;
begin
 if isnull then begin
  result:= emptydatetime;
 end
 else begin
  result:= inherited getasdatetime;
 end;
end;

procedure tmsetimefield.setasdatetime(avalue: tdatetime);
begin
 if isemptydatetime(avalue) then begin
  clear;
 end
 else begin
  inherited;
 end;
end;

procedure tmsetimefield.Clear;
begin
 setdata(nil);
end;

function tmsetimefield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;
}

{ tmsebinaryfield }

function tmsebinaryfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebinaryfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsebinaryfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsebinaryfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsebinaryfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebinaryfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsebinaryfield.Clear;
begin
 setdata(nil);
end;

function tmsebinaryfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsebytesfield }

function tmsebytesfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebytesfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsebytesfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsebytesfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsebytesfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebytesfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsebytesfield.Clear;
begin
 setdata(nil);
end;

function tmsebytesfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsevarbytesfield }

function tmsevarbytesfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsevarbytesfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsevarbytesfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsevarbytesfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsevarbytesfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsevarbytesfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsevarbytesfield.Clear;
begin
 setdata(nil);
end;

function tmsevarbytesfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

{ tmsebcdfield }

function tmsebcdfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebcdfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmsebcdfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsebcdfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

{$ifdef hasaswidestring}
function tmsebcdfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebcdfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
{$endif}

procedure tmsebcdfield.Clear;
begin
 setdata(nil);
end;

function tmsebcdfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

procedure tmsebcdfield.setasfloat(avalue: double);
begin
 if isemptyreal(avalue) then begin
  clear;
 end
 else begin
  inherited;
 end;
end;

class procedure tmsebcdfield.checktypesize(avalue: longint);
begin
 if (avalue < 0) or (avalue > 8) then begin
  databaseerrorfmt(sinvalidfieldsize,[avalue]);
 end; 
end;

{ tmseblobfield }

destructor tmseblobfield.destroy;
begin
 freeandnil(fcache);
 inherited;
end;

function tmseblobfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmseblobfield.assql: string;
begin
 result:= fieldtosql(self);
end;

procedure tmseblobfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmseblobfield.getasmsestring: msestring;
begin
 result:= asstring;
end;

procedure tmseblobfield.LoadFromStream(Stream: TStream);
begin
 removecache;
 inherited;
end;

procedure tmseblobfield.LoadFromFile(const FileName: filenamety);
begin
 if filename = '' then begin
  clear;
 end
 else begin
  removecache;
  inherited loadfromfile(tosysfilepath(filename));
 end;
end;

procedure tmseblobfield.SaveToFile(const FileName: filenamety);
begin
 inherited savetofile(tosysfilepath(filename));
end;

function tmseblobfield.asoldsql: string;
begin
 result:= fieldtooldsql(self);
end;

function tmseblobfield.getasvariant: variant;
begin
 if isnull then begin
  result:= NULL;
 end
 else begin
  result:= getasstring;
 end;
end;

procedure tmseblobfield.setcachekb(const avalue: integer);
begin
 if cachekb <> avalue then begin
  if avalue > 0 then begin
   if fcache = nil then begin
    fcache:= tblobcache.create;
   end;
   fcache.maxsize:= avalue * 1024;
  end
  else begin
   freeandnil(fcache);
  end;
 end;
end;

function tmseblobfield.getcachekb: integer;
begin
 result:= 0;
 if fcache <> nil then begin
  result:= fcache.maxsize div 1024;
 end;
end;
(*
function tmseblobfield.getblobid(out aid: blobidty): boolean;
begin
 result:= assigned(fgetblobid);
 if result then begin
  fgetblobid(aid);
 end;
 {
 aid:= 0;
 case size of
  4,8: begin
   result:= getdata(@aid);
  end;  
  else begin
   if size > 0 then begin
    databaseerror('Invalid cache field: '''+fieldname+'''.',self);
   end;
  end;
 end;
 }
end;
*)
function tmseblobfield.getasstring: string;
var
 id1: blobidty;
 n1: tblobcachenode; 
begin
 if (fcache <> nil) and assigned(fgetblobid) then begin
  result:= '';
  if fgetblobid(self,id1) then begin
   if fcache.find(id1,n1) then begin
    result:= n1.data;
   end
   else begin
    result:= inherited getasstring;
    fcache.addnode(id1,result);
   end;
  end;
 end
 else begin
  result:= inherited getasstring;
 end;
end;

procedure tmseblobfield.removecache(const aid: blobidty);
var
 n1: tblobcachenode; 
begin
 if fcache <> nil then begin
  if fcache.find(aid,n1) then begin
   fcache.removenode(n1);
   n1.free;
  end;
 end;
end;

procedure tmseblobfield.removecache;
var
 id1: blobidty;
begin
 if assigned(fgetblobid) and fgetblobid(self,id1) then begin
  removecache(id1);
 end;
end;

procedure tmseblobfield.setasstring(const avalue: string);
begin
 removecache;
 inherited;
end;

procedure tmseblobfield.Clear;
begin
 removecache;
 inherited;
end;

procedure tmseblobfield.clearcache;
begin
 if fcache <> nil then begin
  fcache.clear;
 end;
end;

procedure tmseblobfield.gettext(var atext: string; adisplaytext: boolean);
begin
 if isnull then begin
  atext:= '(blob)';
 end
 else begin
  atext:= '(BLOB)';
 end;
end;

{ tdbfieldnamearrayprop }

constructor tdbfieldnamearrayprop.create(const afieldtypes: fieldtypesty;
   const agetdatasource: getdatasourcefuncty);
begin
 ffieldtypes:= afieldtypes;
 fgetdatasource:= agetdatasource;
 inherited create;
end;

function tdbfieldnamearrayprop.getdatasource(const aindex: integer): tdatasource;
begin
 result:= fgetdatasource();
end;

procedure tdbfieldnamearrayprop.getfieldtypes(out apropertynames: stringarty;
                  out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 setlength(afieldtypes,1);
 afieldtypes[0]:= ffieldtypes;
end;

{ tmsedatalink }

procedure tmsedatalink.activechanged;
var
 intf1: igetdscontroller;
begin
 fdscontroller:= nil;
 if dataset <> nil then begin
  if getcorbainterface(dataset,typeinfo(igetdscontroller),intf1) then begin
   fdscontroller:= intf1.getcontroller;
  end;   
 end;
 inherited;
end;

function tmsedatalink.getutf8: boolean;
begin
 result:= (fdscontroller <> nil) and (dso_utf8 in fdscontroller.foptions);
end;

function tmsedatalink.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
 if fdscontroller <> nil then begin
  result:= fdscontroller.filtereditkind;
 end;
end;

function tmsedatalink.getdataset: tdataset;
begin
 if datasource <> nil then begin
  result:= datasource.dataset;
 end
 else begin
  result:= nil;
 end;
end;

function tmsedatalink.moveby(distance: integer): integer;
 
begin
 if (distance <> 0) and active then begin
  if fdscontroller <> nil then begin
   result:= fdscontroller.moveby(distance);
  end
  else begin
   result:= inherited moveby(distance);
  end;
 end;
end;

function tmsedatalink.GetActiveRecord: Integer;
begin
 if (dataset = nil) or (csdestroying in dataset.componentstate) then begin
  result:= -1;
 end
 else begin
  result:= inherited getactiverecord;
 end;
end;

function tmsedatalink.canclose: boolean;
begin
 result:= (fcanclosing > 0) or not active;
 if not result then begin
  inc(fcanclosing);
  try
   dataset.checkbrowsemode;
   result:= true;
  except
   application.handleexception(nil);
  end;
  dec(fcanclosing);
 end;
end;

function tmsedatalink.getrecnonullbased: integer;
var
 ds1: tdataset;
begin
 result:= -1;
 if fdscontroller <> nil then begin
  result:= fdscontroller.recnonullbased;
 end
 else begin
  ds1:= dataset;
  if (ds1 <> nil) and ds1.active then begin
   result:= ds1.recno -1;
  end;
 end;
end;

procedure tmsedatalink.setrecnonullbased(const avalue: integer);
var
 ds1: tdataset;
begin
 if fdscontroller <> nil then begin
  fdscontroller.recnonullbased:= avalue;
 end
 else begin
  ds1:= dataset;
  if (ds1 <> nil) and ds1.active then begin
   ds1.recno:= avalue + 1;
  end;
 end;
end;

{ tfielddatalink }

procedure tfielddatalink.setfieldname(const Value: string);
begin
 if ffieldname <> value then begin
  ffieldname :=  value;
  updatefield;
 end;
end; 

procedure tfielddatalink.setfield(const value: tfield);
begin
 if ffield <> value then begin
  ffield := value;
  fismsestring:= (ffield <> nil) and (ffield is tmsestringfield);
  editingchanged;
  recordchanged(nil);
 end;
end;

procedure tfielddatalink.updatefield;
begin
 if active and (ffieldname <> '') then begin
  setfield(datasource.dataset.fieldbyname(ffieldname));
 end
 else begin
  setfield(nil);
 end;
end;

procedure tfielddatalink.activechanged;
begin
 inherited;
 updatefield;
end;

procedure tfielddatalink.layoutchanged;
begin
 inherited;
 updatefield;
end;

function tfielddatalink.getasmsestring: msestring;
begin
 if fismsestring then begin
  result:= tmsestringfield(ffield).asmsestring;
 end
 else begin
  try
   if utf8 then begin
    result:= utf8tostring(field.asstring);
   end
   else begin
    result:= field.asstring;
   end;
  except
   result:= converrorstring;
  end;
 end;
end;

procedure tfielddatalink.setasmsestring(const avalue: msestring);
begin
 if fismsestring then begin
  tmsestringfield(field).asmsestring:= avalue;
 end
 else begin
  if utf8 then begin
   ffield.asstring:= stringtoutf8(avalue);
  end
  else begin
   ffield.asstring:= avalue;
  end;
 end;
end;

function tfielddatalink.msedisplaytext(const aformat: msestring = ''): msestring;
 procedure defaulttext;
 begin
  if utf8 then begin
   result:= utf8tostring(ffield.displaytext);
  end
  else begin
   result:= ffield.displaytext;
  end;
 end;
begin
 result:= '';
 if ffield <> nil then begin
  if fismsestring then begin
   result:= tmsestringfield(ffield).asmsestring;
  end
  else begin
   if not ffield.isnull then begin
    if aformat <> '' then begin
     case ffield.datatype of
      ftsmallint,ftinteger,ftword,ftlargeint,ftbcd,ftfloat,ftcurrency: begin
       result:= formatfloatmse(field.asfloat,aformat);       
      end;
      ftboolean: begin
       result:= formatfloatmse(ord(field.asboolean),aformat);       
      end;
      ftdate,fttime,ftdatetime: begin
       result:= formatdatetime(aformat,field.asdatetime);
      end;
      else begin
       defaulttext;
      end;
     end;
    end
    else begin
     defaulttext;
    end;
   end;
  end;
 end;
end;

function tfielddatalink.assql: string;
begin
 result:= fieldtosql(ffield);
end;

procedure tfielddatalink.checkfield;
begin
 if ffield = nil then begin
  raise exception.create('Field is nil.');
 end;
end;

function tfielddatalink.GetAsBoolean: Boolean;
begin
 checkfield;
 result:= field.asboolean;
end;

procedure tfielddatalink.SetAsBoolean(const avalue: Boolean);
begin
 checkfield;
 field.asboolean:= avalue;
end;

function tfielddatalink.GetAsCurrency: Currency;
begin
 checkfield;
 result:= field.ascurrency;
end;

procedure tfielddatalink.SetAsCurrency(const avalue: Currency);
begin
 checkfield;
 field.ascurrency:= avalue;
end;

function tfielddatalink.GetAsDateTime: TDateTime;
begin
 checkfield;
 result:= field.asdatetime;
end;

procedure tfielddatalink.SetAsDateTime(const avalue: TDateTime);
begin
 checkfield;
 field.asdatetime:= avalue;
end;

function tfielddatalink.GetAsFloat: Double;
begin
 checkfield;
 result:= field.asfloat;
end;

procedure tfielddatalink.SetAsFloat(const avalue: Double);
begin
 checkfield;
 field.asfloat:= avalue;
end;

function tfielddatalink.GetAsLongint: Longint;
begin
 checkfield;
 result:= field.aslongint;
end;

procedure tfielddatalink.SetAsLongint(const avalue: Longint);
begin
 checkfield;
 field.aslongint:= avalue;
end;

function tfielddatalink.GetAsLargeInt: LargeInt;
begin
 checkfield;
 result:= field.aslargeint;
end;

procedure tfielddatalink.SetAsLargeInt(const avalue: LargeInt);
begin
 checkfield;
 field.aslargeint:= avalue;
end;

function tfielddatalink.GetAsInteger: Integer;
begin
 checkfield;
 result:= field.asinteger;
end;

procedure tfielddatalink.SetAsInteger(const avalue: Integer);
begin
 checkfield;
 field.asinteger:= avalue;
end;

function tfielddatalink.GetAsString: string;
begin
 checkfield;
 result:= field.asstring;
end;

procedure tfielddatalink.SetAsString(const avalue: string);
begin
 checkfield;
 field.asstring:= avalue;
end;

function tfielddatalink.GetAsVariant: variant;
begin
 checkfield;
 result:= field.asvariant;
end;

procedure tfielddatalink.SetAsVariant(const avalue: variant);
begin
 checkfield;
 field.asvariant:= avalue;
end;

function tfielddatalink.fieldactive: boolean;
begin
 result:= (ffield <> nil) and (dataset <> nil) and (dataset.state <> dsinactive);
// result:= active and (ffield <> nil); //unreliable
end;

{ tpersistentfields }

constructor tpersistentfields.create(const adataset: tdataset);
begin
 fdataset:= adataset;
 inherited create(nil);
end;

procedure tpersistentfields.createitem(const index: integer; 
                                                     var item: tpersistent);
begin
 if csloading in fdataset.componentstate then begin
  item:= nil;
 end
 else begin
  item:= tfield.create(nil);
  tfield(item).dataset:= fdataset;
 end;
end;

procedure tpersistentfields.readfields(reader: treader);
var
 int1: integer; 
 fieldtypes: fieldclasstypearty;
begin
 setlength(fieldtypes,count);
 int1:= 0;
 reader.readlistbegin;
 reader.readlistbegin;
 while not reader.endoflist do begin
  if int1 <= high(fieldtypes) then begin
   fieldtypes[int1]:= fieldclasstypety(getenumvalue(typeinfo(fieldclasstypety),
                               reader.readident));    
  end;
  inc(int1);
 end;
 reader.readlistend;
 for int1:= 0 to high(fieldtypes) do begin
  if fitems[int1] = nil then begin
   fitems[int1]:= msefieldtypeclasses[fieldtypes[int1]].create(nil);
  end;
 end;
 readcollection(reader);
 for int1:= 0 to high(fitems) do begin
  tfield(fitems[int1]).dataset:= fdataset;
 end;
 reader.readlistend;
end;

procedure tpersistentfields.writefields(writer: twriter);
var
 int1: integer;
begin
 writer.writelistbegin;
 writer.writelistbegin;
 for int1:= 0 to high(fitems) do begin
  writer.writeident(getenumname(typeinfo(fieldclasstypety),
            ord(fieldclasstoclasstyp(fieldclassty(fitems[int1].classtype)))));
 end;
 writer.writelistend;
 writecollection(writer);
 writer.writelistend;
end;

procedure tpersistentfields.defineproperties(filer: tfiler);
var
 int1: integer; 
begin
 filer.defineproperty('fields',{$ifdef FPC}@{$endif}readfields,
                                   {$ifdef FPC}@{$endif}writefields,count > 0);
end;

procedure tpersistentfields.setitems(const index: integer; const avalue: tfield);
begin
 items[index].assign(avalue);
end;

function tpersistentfields.getitems(const index: integer): tfield;
begin
 result:= tfield(inherited getitems(index));
end;

procedure tpersistentfields.updateorder;
var
 int1: integer;
 bo1: boolean;
begin
 bo1:= fdataset.active;
 fdataset.active:= false;
 for int1:= 0 to count - 1 do begin
  items[int1].index:= int1;
 end;
 fdataset.active:= bo1;
end;

procedure tpersistentfields.move(const curindex: integer; const newindex: integer);
begin
 inherited;
 updateorder;
end;

function tpersistentfields.getfieldnames: stringarty;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= 0 to high(result) do begin
  result[int1]:= tfield(fitems[int1]).fieldname;
 end;
end;


{ tdscontroller }

constructor tdscontroller.create(const aowner: tdataset; const aintf: idscontroller;
                                   const arecnooffset: integer = 0;
                                   const acancelresync: boolean = true);
begin
 ffields:= tpersistentfields.create(aowner); 
 fintf:= aintf;
 frecnooffset:= arecnooffset;
 fcancelresync:= acancelresync;
 inherited create(aowner);
end;

destructor tdscontroller.destroy;
var
 int1: integer;
 field1: tfield;
begin
 unregisteronidle;
 tdataset(fowner).active:= false; //avoid later calls from fowner
 for int1:= 0 to high(flinkedfields) do begin
  flinkedfields[int1].setdsintf(nil);
 end;
 flinkedfields:= nil;
 with tdataset(fowner).fields do begin
  for int1:= count-1 downto 0 do begin
   field1:= fields[int1];
   if (field1.owner <> nil) and not 
         (csdestroying in field1.componentstate) then begin
    field1.dataset:= nil;
   end;
  end;
 end;
 ffields.free;
 inherited;
end;

procedure tdscontroller.fielddestroyed(const sender: ifieldcomponent);
begin
 removeitem(pointerarty(flinkedfields),sender);
end;

procedure tdscontroller.setowneractive(const avalue: boolean); 
begin
 tdataset(fowner).active:= avalue;
end;

function tdscontroller.locate(const key: integer; const field: tfield;
                              const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(tdataset(fowner),key,field,options);
end;

function tdscontroller.locate(const key: msestring; const field: tfield;
                         const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(tdataset(fowner),dso_utf8 in foptions,key,field,options);
end;

procedure tdscontroller.appendrecord(const values: array of const);
var
 int1: integer;
 field1: tfield;
begin
 with tdataset(fowner) do begin
  append;
  for int1:= 0 to high(values) do begin
   field1:= fields[int1];
   with values[int1] do begin
    case vtype of
     vtInteger:    field1.asinteger:= VInteger;
     vtBoolean:    field1.asboolean:= VBoolean;
     vtChar:       field1.asstring:= VChar;
     vtWideChar:   field1.asstring:= VWideChar;
     vtExtended:   field1.asfloat:= VExtended^;
     vtString:     field1.asstring:= VString^;
 //  vtPointer:
     vtPChar:      field1.asstring:= VPChar;
 //  vtObject:
 //  vtClass:
     vtPWideChar:  field1.asstring:= VPWideChar;
     vtAnsiString: field1.asstring:= ansistring(VAnsiString);
     vtCurrency:   field1.ascurrency:= VCurrency^;
     vtVariant:    field1.asvariant:= VVariant^;
 //    vtInterface:
     vtWideString: begin
      if (field1 is tmsestringfield) then begin
       tmsestringfield(field1).asmsestring:= widestring(vwidestring);
      end
      else begin 
       if (field1 is tmsememofield) then begin
        tmsememofield(field1).asmsestring:= widestring(vwidestring);
       end
       else begin
        field1.asstring:= widestring(vwidestring);
       end;
      end;
     end;
 //  vtInt64:
 //  vtQWord:
    end;
   end;
  end; 
 end;
end;

procedure tdscontroller.setfields(const avalue: tpersistentfields);
begin
 ffields.assign(avalue);
end;

procedure tdscontroller.getfieldclass(const fieldtype: tfieldtype; out result: tfieldclass);
begin
 result:= msefieldtypeclasses[tfieldtypetotypety[fieldtype]];
end;

function tdscontroller.getrecnonullbased: integer;
begin
 with tdataset1(fowner) do begin
  if bof and eof then begin
   result:= -1;
  end
  else begin
   if not frecnovalid then begin
    if bof then begin
     frecno:= 0;
    end
    else begin
     if eof then begin
      frecno:= recordcount - 1;
     end
     else begin
      frecno:= recno + frecnooffset;
     end;
    end;
    frecnovalid:= true;
   end
   else begin
    inc(frecno,fscrollsum + activerecord - factiverecordbefore);
   end;
   factiverecordbefore:= activerecord;
   fscrollsum:= 0;
   result:= frecno;
   if (state = dsinsert) and (getbookmarkflag(activebuffer) = bfeof) then begin
    inc(result); //append mode
   end;
  end;
 end;
end;

procedure tdscontroller.setrecnonullbased(const avalue: integer);
begin
 if not frecnovalid or (avalue <> frecno) then begin
  tdataset1(fowner).recno:= avalue - recnooffset;
  frecno:= avalue;
  factiverecordbefore:= tdataset1(fowner).activerecord;
  fscrollsum:= 0;
  frecnovalid:= true;
 end;
end;

function tdscontroller.getrecno: integer;
begin
 result:= recnonullbased - frecnooffset;
end;

procedure tdscontroller.setrecno(const avalue: integer);
begin
 recnonullbased:= avalue + frecnooffset;
end;

procedure tdscontroller.updatelinkedfields;
var
 int1: integer;
 intf1: ifieldcomponent;
 field1: tfield;
begin
 with tdataset(fowner) do begin
  for int1:= 0 to fields.count - 1 do begin
   field1:= fields[int1];
   if getcorbainterface(field1,typeinfo(ifieldcomponent),intf1) and 
       (finditem(pointerarty(flinkedfields),intf1) < 0) then begin
    additem(pointerarty(flinkedfields),intf1);
    intf1.setdsintf(idsfieldcontroller(self));
   end;
  end;
  for int1:= high(flinkedfields) downto 0 do begin
   if fields.indexof(flinkedfields[int1].getinstance) < 0 then begin
    flinkedfields[int1].setdsintf(nil);
    deleteitem(pointerarty(flinkedfields),int1);
   end;
  end;       
 end;
end;

procedure tdscontroller.dataevent(const event: tdataevent; info: ptrint);
var
 field1: tfield;
begin
 case event of
  dedatasetscroll: begin
   fmovebylock:= false;
   dec(fscrollsum,info);
  end;
  dedatasetchange,deupdatestate: begin
   frecnovalid:= false;
  end;
  defieldlistchange: begin
   updatelinkedfields;
  end;
  defocuscontrol: begin
   field1:= tfield(info); //workaround for fpc bug 
   info:= ptrint(@field1);
  end;
 end;
 if not fmovebylock or (event <> dedatasetchange) then begin
  fintf.inheriteddataevent(event,info);
 end;
end;

procedure tdscontroller.cancel;
var
 bo1: boolean;
begin
 with tdataset1(fowner) do begin
  bo1:= state = dsinsert;
  if bo1 then begin
   dobeforescroll;
  end;
  if fcancelresync and (state = dsinsert) and not modified then begin
   fintf.inheritedcancel;
   try
    if finsertbm <> '' then begin
     bookmark:= finsertbm;
    end;  
   except
   end;
   finsertbm:= '';
  end
  else begin
   fintf.inheritedcancel;
  end;
  if bo1 then begin
   doafterscroll;
  end;
 end;
end;

function tdscontroller.moveby(const distance: integer): integer;
begin
 with tdataset1(fowner) do begin
  if (abs(distance) = 1) and (state = dsinsert) and not modified then begin
   checkbrowsemode;
  end
  else begin
   if state = dsbrowse then begin
    fmovebylock:= true;
   end;
   try
    result:= fintf.inheritedmoveby(distance);
    if fmovebylock then begin
     fmovebylock:= false;
     dataevent(dedatasetscroll,0);
    end;
   finally
    fmovebylock:= false;
   end;
  end;
 end;
end;

procedure tdscontroller.internalinsert;
begin
 finsertbm:= tdataset(fowner).bookmark;
 fintf.inheritedinternalinsert;
end;

procedure tdscontroller.internaldelete;
begin
 fintf.inheritedinternaldelete;
 modified;
end;

procedure tdscontroller.internalopen;
var
 int1,int2: integer;
// blobdatasize: integer;
begin
// blobdatasize:= fintf.getblobdatasize;
 with tdataset(fowner) do begin
 {
  for int1:= 0 to fields.count - 1 do begin
   with fields[int1] do begin
    if datatype in blobfields then begin
     size:= blobdatasize;
    end;
   end;
  end;
  }
  for int1:= 0 to fielddefs.count - 1 do begin
   with tfielddefcracker(fielddefs[int1]) do begin
    if ffieldno = 0 then begin
     ffieldno:= int1 + 1;
    end;
//    if fdatatype in blobfields then begin
//     fsize:= blobdatasize;
//    end;
   end;
  end;
  updatelinkedfields;
  if dso_local in foptions then begin
   fintf.openlocal;
  end
  else begin
   fintf.inheritedinternalopen;
  end;
  for int1:= 0 to fields.count - 1 do begin
   with fields[int1] do begin
    int2:= fielddefs.indexof(fieldname);
    if (int2 >= 0) and not checkfieldcompatibility(fields[int1],
                          fielddefs[int2].datatype) then begin
     databaseerror('Datatype mismatch dataset '''+fowner.name+''' field '''+
      fieldname+''''+lineend+
        'expected: '''+getenumname(typeinfo(tfieldtype),
         ord(fielddefs[int2].datatype))+''' actual: '''+
         getenumname(typeinfo(tfieldtype),ord(datatype))+'''.');
    end;
   end;
  end;
  updatelinkedfields; //second check
 end;
 if fdelayedapplycount > 0 then begin
  registeronidle;
 end;
end;

procedure tdscontroller.doonidle(var again: boolean);
begin
 fintf.doidleapplyupdates;
end;

procedure tdscontroller.registeronidle;
begin
 if not(dscs_onidleregistered in fstate) then begin
  application.registeronidle(@doonidle);
  include(fstate,dscs_onidleregistered);
 end;
end;

procedure tdscontroller.unregisteronidle;
begin
 if dscs_onidleregistered in fstate then begin
  application.unregisteronidle(@doonidle);
  exclude(fstate,dscs_onidleregistered);
 end;
end;

procedure tdscontroller.internalclose;
var
 int1: integer;
 field1: tfield;
begin
 unregisteronidle;
 fintf.inheritedinternalclose;
 with tdataset(fowner) do begin
  for int1:= 0 to fields.count - 1 do begin
   field1:= fields[int1];
   if field1 is tmseblobfield then begin
    tmseblobfield(field1).clearcache;
   end;
  end;
 end;
end;

function tdscontroller.getcontroller: tdscontroller;
begin
 result:= self;
end;

function tdscontroller.assql(const avalue: boolean): string;
begin
 if fintf.getnumboolean then begin
  if avalue then begin
   result:= '1';
  end
  else begin
   result:= '0';
  end;
 end
 else begin   
  result:= encodesqlboolean(avalue);
 end;
end;

function tdscontroller.assql(const avalue: msestring): string;
begin
 if avalue = '' then begin
  result:= 'NULL';
 end
 else begin
  if dso_utf8 in foptions then begin
   result:= encodesqlstring(stringtoutf8(avalue));
  end
  else begin
   result:= encodesqlstring(avalue);
  end;
 end;
end;

function tdscontroller.assql(const avalue: integer): string;
begin
 result:= inttostr(avalue);
end;

function tdscontroller.assql(const avalue: int64): string;
begin
 result:= inttostr(avalue);
end;

function tdscontroller.assql(const avalue: realty): string;
begin
 if isemptyreal(avalue) then begin
  result:= 'NULL';
 end
 else begin
  result:= realtostr(avalue);
 end;
end;

function tdscontroller.assqlcurrency(const avalue: realty): string;
begin
 if isemptyreal(avalue) then begin
  result:= 'NULL';
 end
 else begin
  result:= assql(currency(avalue));
 end;
end;

function tdscontroller.assql(const avalue: currency): string;
begin
 if fintf.getint64currency then begin
  result:= inttostr(int64(avalue));
 end
 else begin
  result:= encodesqlcurrency(avalue);
 end;
end;

function tdscontroller.assql(const avalue: tdatetime): string;
begin
 if isemptydatetime(avalue) then begin
  result:= 'NULL';
 end
 else begin
  if fintf.getfloatdate then begin
   result:= encodesqlfloat(avalue);
  end
  else begin
   result:= encodesqldatetime(avalue);
  end;
 end;
end;

function tdscontroller.assqldate(const avalue: tdatetime): string;
begin
 if isemptydatetime(avalue) then begin
  result:= 'NULL';
 end
 else begin
  if fintf.getfloatdate then begin
   result:= inttostr(trunc(avalue));
  end
  else begin
   result:= encodesqldate(avalue);
  end;
 end;
end;

function tdscontroller.assqltime(const avalue: tdatetime): string;
begin
 if isemptydatetime(avalue) then begin
  result:= 'NULL';
 end
 else begin
  if fintf.getfloatdate then begin
   result:= encodesqlfloat(frac(avalue));
  end
  else begin
   result:= encodesqltime(avalue);
  end;
 end;
end;

procedure tdscontroller.closequery(var amodalresult: modalresultty);
begin
 try
  with tdataset(fowner) do begin;
   if state in dseditmodes then begin
    checkbrowsemode;
   end;
  end;
 except
  amodalresult:= mr_exception;
  application.handleexception(nil);
 end;
end;

function tdscontroller.closequery: boolean; //true if ok
var
 modres1: modalresultty;
begin
 modres1:= mr_canclose;
 closequery(modres1);
 result:= modres1 = mr_canclose;
end;

function tdscontroller.post: boolean;
begin
 with tdataset(fowner) do begin;
  if state in dseditmodes then begin
   result:= true;
   include(fstate,dscs_posting);
   try    
    fintf.inheritedpost;
   finally
    exclude(fstate,dscs_posting);
   end;
   self.modified;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tdscontroller.emptyinsert: boolean;
begin
 result:= false;
 if not posting then begin
  with tdataset1(fowner) do begin
   if state = dsinsert then begin
    DataEvent(deUpdateRecord,0);
    result:= not modified;
   end;
  end;
 end;
end;

function tdscontroller.posting: boolean;
begin
 result:= dscs_posting in fstate;
end;

procedure tdscontroller.modified;
begin
 tdataset1(fowner).dataevent(tdataevent(de_modified),0);
end;

procedure tdscontroller.setoptions(const avalue: datasetoptionsty);
const
 mask: datasetoptionsty = [dso_autocommitret,dso_autocommit];
begin
 foptions:= datasetoptionsty(setsinglebit(longword(avalue),longword(foptions),
                    longword(mask)));
end;

function tdscontroller.isutf8: boolean;
begin
 result:= dso_utf8 in foptions;
end;

function tdscontroller.filtereditkind: filtereditkindty;
begin
 result:= fintf.getfiltereditkind;
end;

procedure tdscontroller.beginfilteredit(const akind: filtereditkindty);
begin
 fintf.beginfilteredit(akind);
end;

procedure tdscontroller.endfilteredit;
begin
 fintf.endfilteredit;
end;

function tdscontroller.getfieldar(
                   const afieldkinds: tfieldkinds = allfieldkinds): fieldarty;
var
 int1,int2: integer;
begin
 with tdataset(fowner).fields do begin
  setlength(result,count);
  int2:= 0;
  for int1:= 0 to high(result) do begin
   result[int2]:= fields[int1];
   if result[int2].fieldkind in afieldkinds then begin
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

procedure tdscontroller.setdelayedapplycount(const avalue: integer);
begin
 if fdelayedapplycount <> avalue then begin
  if tdataset(fowner).active and not (csloading in fowner.componentstate) then begin
   if fdelayedapplycount > 0 then begin
    fdelayedapplycount:= 1;
    fintf.doidleapplyupdates; //apply pending updates.
   end;
   fdelayedapplycount:= avalue;
   if avalue > 0 then begin
    registeronidle;
   end
   else begin
    unregisteronidle;
   end;
  end
  else begin
   fdelayedapplycount:= avalue;
  end;
 end;   
end;

{ tmsedatasource }

{ tfieldlinkdatalink }

constructor tfieldlinkdatalink.create(const aowner: tfieldlink);
begin
 fowner:= aowner;
 inherited create;
 fdatasource:= tdatasource.create(nil);
 datasource:= fdatasource;
end;

destructor tfieldlinkdatalink.destroy;
begin
 fdatasource.free;
 inherited;
end;

procedure tfieldlinkdatalink.updatedata;
begin
 if field <> nil then begin
  if (not (flo_onlyifnull in fowner.foptions) or (field.isnull)) and 
     (not (flo_notifunmodifiedinsert in fowner.foptions) or 
                       (datasource.dataset.modified)) then begin
   fowner.updatedata(field);
  end;
 end;
end;

{ tfieldlink }

constructor tfieldlink.create(aowner: tcomponent);
begin
 inherited;
 fdestdatalink:= tfieldlinkdatalink.create(self);
end;

destructor tfieldlink.destroy;
begin
 fdestdatalink.free;
 inherited;
end;

procedure tfieldlink.setdestdataset(const avalue: tdataset);
begin
 fdestdatalink.fdatasource.dataset:= avalue;
end;

function tfieldlink.getdestdataset: tdataset;
begin
 result:= fdestdatalink.dataset;
end;

function tfieldlink.getdestdatafield: string;
begin
 result:= fdestdatalink.fieldname;
end;

procedure tfieldlink.setdestdatafield(const avalue: string);
begin
 fdestdatalink.fieldname:= avalue;
end;

function tfieldlink.field: tfield;
begin
 result:= fdestdatalink.field;
end;

procedure tfieldlink.getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 fieldtypes:= nil;
end;

function tfieldlink.getdatasource(const aindex: integer): tdatasource;
begin
 result:= fdestdatalink.datasource;
end;

procedure tfieldlink.updatedata(const afield: tfield);
begin
 if canevent(tmethod(fonupdatedata)) then begin
  fonupdatedata(afield);
 end;
end;

{ tfieldfieldlink }

constructor tfieldfieldlink.create(aowner: tcomponent);
begin
 inherited;
 fsourcedatalink:= tfielddatalink.create;
end;

destructor tfieldfieldlink.destroy;
begin
 fsourcedatalink.free;
 inherited;
end;

function tfieldfieldlink.getdatafield: string;
begin
 result:= fsourcedatalink.fieldname;
end;

procedure tfieldfieldlink.setdatafield(const avalue: string);
begin
 fsourcedatalink.fieldname:= avalue;
end;

function tfieldfieldlink.getdatasource: tdatasource;
begin
 result:= fsourcedatalink.datasource;
end;

function tfieldfieldlink.getdatasource(const aindex: integer): tdatasource;
begin
 if aindex = 0 then begin
  result:= fdestdatalink.datasource;
 end
 else begin
  result:= fsourcedatalink.datasource;
 end;  
end;

procedure tfieldfieldlink.setdatasource(const avalue: tdatasource);
begin
 fsourcedatalink.datasource:= avalue;
end;

function tfieldfieldlink.sourcefield: tfield;
begin
 result:= fsourcedatalink.field;
end;

procedure tfieldfieldlink.getfieldtypes(out propertynames: stringarty;
               out fieldtypes: fieldtypesarty);
begin
 setlength(propertynames,2);
 propertynames[0]:= 'datafield';
 propertynames[1]:= 'destdatafield';
 setlength(fieldtypes,2);
 fieldtypes[0]:= [];
 fieldtypes[1]:= [];
end;

procedure tfieldfieldlink.updatedata(const afield: tfield);
begin
 if fsourcedatalink.field <> nil then begin
  field.value:= fsourcedatalink.field.value;
 end;
 inherited;
end;

{ ttimestampfieldlink }

procedure ttimestampfieldlink.updatedata(const afield: tfield);
begin
 afield.asdatetime:= now;
 inherited;
end;

{ tmseparams }

function tmseparams.parsesql(const sql: msestring;
               const docreate,EscapeSlash,EscapeRepeat: boolean;
               const parameterstyle: tparamstyle;
               var parambinding: tparambinding;
               var replacestring: msestring): msestring;

type
  // used for ParamPart
  TStringPart = record
    Start,Stop:integer;
  end;

const
  ParamAllocStepSize = 8;

var
  IgnorePart:boolean;
  p,ParamNameStart,BufStart: PmseChar;
  ParamName: msestring;
  QuestionMarkParamCount,ParameterIndex,NewLength:integer;
  ParamCount:integer; // actual number of parameters encountered so far;
                      // always <= Length(ParamPart) = Length(Parambinding)
                      // Parambinding will have length ParamCount in the end
  ParamPart:array of TStringPart; // describe which parts of buf are parameters
//  NewQueryLength:integer;
  NewQuery: msestring;
  NewQueryIndex,BufIndex,CopyLen,i:integer;    // Parambinding will have length ParamCount in the end
  b:integer;
  tmpParam:TParam;

begin
//  if DoCreate then Clear;        //2006-11-23 mse

  // Parse the SQL and build ParamBinding
 ParamCount:=0;
// NewQueryLength:=Length(SQL);
 SetLength(ParamPart,ParamAllocStepSize);
 SetLength(Parambinding,ParamAllocStepSize);
 QuestionMarkParamCount:=0; // number of ? params found in query so far

 ReplaceString := '$';
 if ParameterStyle = psSimulated then
   while pos(ReplaceString,SQL) > 0 do ReplaceString := ReplaceString+'$';

 p:= PmseChar(SQL);
 BufStart:=p; // used to calculate ParamPart.Start values
 repeat
   case p^ of
     '''': // single quote delimited string
       begin
         Inc(p);
         while not (p^ in [#0, '''']) do
         begin
           if p^='\' then Inc(p,2) // make sure we handle \' and \\ correct
           else Inc(p);
         end;
         if p^='''' then Inc(p); // skip final '
       end;
     '"':  // double quote delimited string
       begin
         Inc(p);
         while not (p^ in [#0, '"']) do
         begin
           if p^='\'  then Inc(p,2) // make sure we handle \" and \\ correct
           else Inc(p);
         end;
         if p^='"' then Inc(p); // skip final "
       end;
     '-': // possible start of -- comment
       begin
         Inc(p);
         if p^='-' then // -- comment
         begin
           repeat // skip until at end of line
             Inc(p);
           until p^ in [#10, #0];
         end
       end;
     '/': // possible start of /* */ comment
       begin
         Inc(p);
         if p^='*' then // /* */ comment
         begin
           repeat
             Inc(p);
             if p^='*' then // possible end of comment
             begin
               Inc(p);
               if p^='/' then Break; // end of comment
             end;
           until p^=#0;
           if p^='/' then Inc(p); // skip final /
         end;
       end;
     ':','?': // parameter
       begin
         IgnorePart := False;
         if p^=':' then
         begin // find parameter name
           Inc(p);
           if p^=':' then  // ignore ::, since some databases uses this as a cast (wb 4813)
           begin
             IgnorePart := True;
             Inc(p);
           end
           else
           begin
             ParamNameStart:=p;
             while not (p^ in (SQLDelimiterCharacters+
                 [#0,'=','+','-','*','\','[',']'])) do
               Inc(p);
             ParamName:=Copy(ParamNameStart,1,p-ParamNameStart);
           end;
         end
         else
         begin
           Inc(p);
           ParamNameStart:=p;
           ParamName:='';
         end;

         if not IgnorePart then
         begin
           Inc(ParamCount);
           if ParamCount>Length(ParamPart) then
           begin
             NewLength:=Length(ParamPart)+ParamAllocStepSize;
             SetLength(ParamPart,NewLength);
             SetLength(ParamBinding,NewLength);
           end;

           if DoCreate then
             begin
             // Check if this is the first occurance of the parameter
             tmpParam := FindParam(ParamName);
             // If so, create the parameter and assign the Parameterindex
             if not assigned(tmpParam) then
               ParameterIndex := CreateParam(ftUnknown, ParamName, ptInput).Index
             else  // else only assign the ParameterIndex
               ParameterIndex := tmpParam.Index;
             end
           // else find ParameterIndex
           else
             begin
               if ParamName<>'' then
                 ParameterIndex:=ParamByName(ParamName).Index
               else
               begin
                 ParameterIndex:=QuestionMarkParamCount;
                 Inc(QuestionMarkParamCount);
               end;
             end;
             {
           if ParameterStyle in [psPostgreSQL,psSimulated] then
             begin
             if ParameterIndex > 8 then
               inc(NewQueryLength,2)
             else
               inc(NewQueryLength,1)
             end;
           }
           // store ParameterIndex in FParamIndex, ParamPart data
           ParamBinding[ParamCount-1]:=ParameterIndex;
           ParamPart[ParamCount-1].Start:=ParamNameStart-BufStart;
           ParamPart[ParamCount-1].Stop:=p-BufStart+1;

           // update NewQueryLength
//           Dec(NewQueryLength,p-ParamNameStart);
         end;
       end;
     #0:Break;
   else
     Inc(p);
   end;
 until false;

 SetLength(ParamPart,ParamCount);
 SetLength(ParamBinding,ParamCount);

 if ParamCount>0 then begin
  //replace :ParamName by '?' for interbase, 
  //by '$x ' for postgresql and psSimulated
  //(using ParamPart array and NewQueryLength)
  SetLength(NewQuery,length(sql)+paramcount*(length(ReplaceString)+8));
                           //reserve '$1234567 '
  NewQueryIndex:=1;
  BufIndex:=1;
  for i:=0 to High(ParamPart) do begin
   CopyLen:=ParamPart[i].Start-BufIndex;
   Move(SQL[BufIndex],NewQuery[NewQueryIndex],CopyLen*sizeof(msechar));
   Inc(NewQueryIndex,CopyLen);
   case ParameterStyle of
    psInterbase : NewQuery[NewQueryIndex]:='?';
    psPostgreSQL,
    psSimulated : begin
     ParamName:= IntToStr(ParamBinding[i]+1);
     for b:= 1 to length(ReplaceString) do begin
      NewQuery[NewQueryIndex]:='$';
      Inc(NewQueryIndex);
     end;
     for b:= 1 to length(paramname) do begin
      NewQuery[NewQueryIndex]:= paramname[b];
      Inc(NewQueryIndex);
     end;
     newquery[newqueryindex]:= ' ';
    end;
   end;
   Inc(NewQueryIndex);
   BufIndex:=ParamPart[i].Stop;
  end;
  CopyLen:=Length(SQL)+1-BufIndex;
  Move(SQL[BufIndex],NewQuery[NewQueryIndex],CopyLen*sizeof(msechar));
  setlength(newquery,newqueryindex+copylen-1);
 end
 else begin
  NewQuery:=SQL;
 end;    
 Result:= NewQuery;
end;

function  tmseparams.parsesql(const sql: msestring;
        const docreate,EscapeSlash,EscapeRepeat: boolean;
        const parameterstyle : tparamstyle; var parambinding: tparambinding): msestring;
var
 rs: msestring;
begin
 result := parsesql(sql,docreate,escapeslash,escaperepeat,parameterstyle,
                      parambinding,rs);
end;

function tmseparams.parsesql(const sql: msestring;
               const docreate,EscapeSlash,EscapeRepeat: boolean;
               const parameterstyle: tparamstyle): msestring;
var
 pb: tparambinding;
 rs: msestring;
begin
 result:= parsesql(sql,docreate,escapeslash,escaperepeat,parameterstyle,pb,rs);
end;

function tmseparams.parsesql(const sql: msestring; const docreate: boolean): msestring;
var
 pb: TParamBinding;
 rs: msestring;
begin
 result:= parsesql(sql,docreate,false,false,psinterbase,pb,rs);
end;

function tmseparams.expandvalues(sql: msestring;
          const aparambindings: tparambinding;
          const aparamreplacestring: msestring): msestring; overload;
var
 int1,int2,int3,int4: integer;
 po1: pmsechar;
begin
 if high(aparambindings) >= 0 then begin
  int3:= 1;
  result:= '';
  uniquestring(sql);
  po1:= pmsechar(sql)-1;
  for int1:= 0 to high(aparambindings) do begin
   int2:= pos(aparamreplacestring,sql);
   for int4:= int2 to int2+length(aparamreplacestring)-1 do begin
    (po1+int4)^:= ' '; //remove marker
   end;
   result:= result + copy(sql,int3,int2-int3) + 
                          paramtosql(items[aparambindings[int1]]);
   int3:= int2 + length(aparamreplacestring);
   while (sql[int3] >= '0') and (sql[int3] <= '9') do begin
    inc(int3);
   end;
  end;
  result:= result + copy(sql,int3,bigint); //tail
 end
 else begin
  result:= sql;   
 end;
end;

function tmseparams.expandvalues(const sql: msestring): msestring;
var
 pb: tparambinding;
 str1,str2: msestring;
begin
 str2:= parsesql(sql,false,false,false,pssimulated,pb,str1);
 result:= expandvalues(str2,pb,str1);
end;

function tmseparams.asdbstring(const index: integer): string;
begin
 with items[index] do begin
  if isutf8 then begin
   if vartype(value) = varolestr then begin
    result:= stringtoutf8(aswidestring);
   end
   else begin
    result:= stringtoutf8(asstring);
   end;
  end
  else begin
   result:= asstring;
  end;
 end;
end;

{ tblobcachenode }

constructor tblobcachenode.create(const akey: blobidty; const adata: string);
begin
 flocal:= akey.local;
 inherited create(akey.id,adata);
end;

{ tblobcache }

function compareblobid(const left,right: tavlnode): integer;
var
 lint1: int64;
begin
 result:= integer(tblobcachenode(left).flocal) - 
                 integer(tblobcachenode(right).flocal);
 if result = 0 then begin
  lint1:= tblobcachenode(left).fkey - tblobcachenode(right).fkey;
  if lint1 > 0 then begin
   result:= 1;
  end
  else begin
   if lint1 < 0 then begin
    result:= -1;
   end;
  end;
 end;
end;

constructor tblobcache.create;
begin
 ffindnode:= tblobcachenode.create;
 inherited;
 fcompare:= {$ifdef FPC}@{$endif}compareblobid;
end;

destructor tblobcache.destroy;
begin
 inherited;
 ffindnode.free;
end;

function tblobcache.addnode(const akey: blobidty;
               const adata: string): tblobcachenode;
begin
 result:= tblobcachenode.create(akey,adata);
 addnode(result);
end;

function tblobcache.find(const akey: blobidty;
               out anode: tblobcachenode): boolean;
begin
 ffindnode.fkey:= akey.id;
 ffindnode.flocal:= akey.local;
 result:= find(ffindnode,tavlnode(anode));
end;

end.
