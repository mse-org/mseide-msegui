{ MSEgui Copyright (c) 2004-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedb;

{$ifdef FPC}
 {$define mse_hasvtunicodestring}
{$endif}
{$define hasaswidestring}
{$define integergetdatasize}

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface

uses
 classes,mclasses,mdb,mseclasses,mseglob,msestrings,msetypes,msearrayprops,
 mseapplication,mseinterfaces,
 sysutils,msebintree,mseact,msetimer,maskutils,mseifiglob,mseeditglob,
 msevariants{$ifndef FPC},classes_del{$endif};

const
 mse_vtguid = $ff;
 guidbuffersize = 36; //aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee

 de_modified = ord(high(tdataevent))+1;
 de_afterdelete = ord(high(tdataevent))+2;
 de_afterinsert = ord(high(tdataevent))+3;
 de_afterpost = ord(high(tdataevent))+4;
 de_hasactiveedit = ord(high(tdataevent))+5;

 defaultdscontrolleroptions = [{dso_cancelupdateondeleteerror}];
 allfieldkinds = [fkData,fkCalculated,fkLookup,fkInternalCalc];

type
 lookupdatatypety = (ldt_int32,ldt_int64,ldt_string);

 bookmarkty = string;
   //use instead of TBookmarkStr in order to avoid
   // FPC deprecated warning
// guidbufferty = array[0..guidbuffersize-1] of char;
// pguidbufferty = ^guidbufferty;

 fieldtypearty = array of tfieldtype;
 fieldtypesty = set of tfieldtype;
 fieldtypesarty = array of fieldtypesty;
 datasetarty = array of tdataset;

 fielddefty = record
  datatype: tfieldtype;
  size: integer;
  name: string;
 end;
 pfielddefty = ^fielddefty;
 fielddefarty = array of fielddefty;
 
const
 int32fields = [ftsmallint,ftinteger,ftword];
 int64fields = [ftlargeint];
 doublefields = [ftfloat,ftcurrency];
 datetimefields = [ftdate,fttime,ftdatetime];
 charfields = [ftstring,ftfixedchar];

 widecharfields = [ftwidestring,ftfixedwidechar,ftwidememo];
 textfields = [ftstring,ftfixedchar,ftwidestring,ftfixedwidechar,ftmemo,ftguid];
 memofields = textfields+[ftmemo];
 integerfields = [ftsmallint,ftinteger,ftword,ftlargeint,ftbcd];
 booleanfields = [ftboolean,ftstring,ftfixedchar]+integerfields-[ftbcd];
 realfields = [ftfloat,ftcurrency,ftbcd];
 stringfields = textfields + integerfields + booleanfields +
                realfields + datetimefields;
 widestringfields = [ftwidestring,ftfixedwidechar,ftwidememo];
 blobfields = [ftblob,ftmemo,ftgraphic{,ftstring}];
// defaultproviderflags = [pfInInsert,pfInUpdate,pfInWhere];

 varsizefields = [ftstring,ftfixedchar,ftwidestring,ftfixedwidechar,
                  ftbytes,ftvarbytes,ftbcd,ftfmtbcd];
 
 converrorstring = '?';
 
type
 filtereditkindty = (fek_filter,fek_filtermin,fek_filtermax,fek_find);
 locateresultty = (loc_timeout,loc_notfound,loc_ok); 
 recnosearchoptionty = (rso_backward);
 recnosearchoptionsty = set of recnosearchoptionty;

 locatekeyoptionty = (lko_caseinsensitive,lko_partialkey,lko_posinsensitive);
 locatekeyoptionsty = set of locatekeyoptionty;
 locaterecordoptionty = (lro_noforward,lro_nobackward,lro_nocurrent,lro_utf8);
 locaterecordoptionsty = set of locaterecordoptionty;
 
 fieldarty = array of tfield;

 optionmasterlinkty = (mdlo_syncedit,mdlo_syncinsert,mdlo_syncdelete,
                       mdlo_delayeddetailpost,mdlo_syncfields,
                       mdlo_inserttoupdate,mdlo_norefresh); 
 optionsmasterlinkty = set of optionmasterlinkty;

 imasterlink = interface(inullinterface)[miid_imasterlink]
  function refreshing: boolean;
 end;
 
 imselocate = interface(inullinterface)[miid_imselocate]
   function locate(const afields: array of tfield; 
                   const akeys: array of const; const aisnull: array of boolean;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
 end;

 tmsestringfield = class;
 idbdata = interface(inullinterface)[miid_idbdata]
  function getindex(const afield: tfield): integer; //-1 if none
  function gettextindex(const afield: tfield;
                 const acaseinsensitive: boolean): integer; //-1 if none
  function lookuptext(const indexnum: integer; const akey: integer;
         const aisnull: boolean;
          const valuefield: tmsestringfield): msestring; overload;
  function lookuptext(const indexnum: integer; const akey: int64;
          const aisnull: boolean;
         const valuefield: tmsestringfield): msestring; overload;
  function lookuptext(const indexnum: integer; const akey: msestring;
         const aisnull: boolean;
          const valuefield: tmsestringfield): msestring; overload;
  function findtext(const indexnum: integer; const searchtext: msestring;
                    out arecord: integer): boolean;
  function getrowtext(const indexnum: integer; const arecord: integer;
                           const afield: tfield): msestring;
  function getrowinteger(const indexnum: integer; const arecord: integer;
                           const afield: tfield): integer;
  function getrowlargeint(const indexnum: integer; const arecord: integer;
                           const afield: tfield): int64;
 end;
   
 idbeditinfo = interface(inullinterface)[miid_idbeditinfo]
  function getdataset(const aindex: integer): tdataset;
  procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
    //propertynames = nil -> propertyname = 'datafield'
 end;

 ireccontrol = interface(inullinterface)[miid_ireccontrol]
  procedure recchanged;
 end;
 
 ipersistentfieldsinfo = interface(inullinterface)[miid_ipersistentfieldsinfo]
  function getfieldnames: stringarty;
 end;
 
 idatasetsum = interface(inullinterface)[miid_idatasetsum]
  procedure sumfield(const afield: tfield; out asum: integer); overload;
  procedure sumfield(const afield: tfield; out asum: int64); overload;
  procedure sumfield(const afield: tfield; out asum: currency); overload;
  procedure sumfield(const afield: tfield; out asum: double); overload;
 end;
 
 getdatasourcefuncty = function: tdatasource of object;

 tdbfieldnamearrayprop = class(tstringarrayprop,idbeditinfo)
  private
   ffieldtypes: fieldtypesty;
   fgetdatasource: getdatasourcefuncty;
  protected
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset;
   procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
  public
   constructor create(const afieldtypes: fieldtypesty;
                         const agetdatasource: getdatasourcefuncty);
   property fieldtypes: fieldtypesty read ffieldtypes write ffieldtypes;
 end;

 tdscontroller = class;

 ifieldcomponent = interface;

 idsfieldcontroller = interface(inullinterface)
  function getcontroller: tdscontroller;
  procedure fielddestroyed(const sender: ifieldcomponent);
 end;
{
 lookupfieldinfoty = record
 end;
 plookupfieldinfoty = ^lookupfieldinfoty;
}
 ifieldcomponent = interface(inullinterface)[miid_ifieldcomponent]
  procedure setdsintf(const avalue: idsfieldcontroller);
  function getinstance: tfield;
 end;

// providerflag1ty = (pf1_refreshinsert,pf1_refreshupdate,pf1_nocopyrecord);
// providerflags1ty = set of providerflag1ty;
 
 imsefield = interface(inullinterface)[miid_imsefield]
//  function getproviderflags1: providerflags1ty;
//  function getlookupinfo: plookupfieldinfoty;
 end;

 fieldstatety = (fis_changing);
 fieldstatesty = set of fieldstatety;
    
 tmsefield = class(tfield,imsefield)
  private
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
   fstate: fieldstatesty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//m   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader); 
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
//   function getaswidestring: widestring; override;
//   procedure setaswidestring(const avalue: widestring); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false; 
 end;
 
 getmsestringdataty = function(const sender: tmsestringfield;
                     out avalue: msestring): boolean of object; //false if null
 setmsestringdataty = procedure(const sender: tmsestringfield;
                          avalue: msestring) of object;

 tmsestringfield = class(tstringfield,ifieldcomponent,imsefield)
  private
   fstate: fieldstatesty;
   fdsintf: idsfieldcontroller;
   fgetmsestringdata: getmsestringdataty;
   fsetmsestringdata: setmsestringdataty;
   fcharacterlength: integer;
   ftagpo: pointer;
//   fvaluebuffer: msestring;
//   fvalidating: boolean;
   fisftwidestring: boolean;
   fdefaultexpressionstr: msestring;
   fdefaultexpressionbefore: string; 
                  //synchronize with TField.DefaultExpression
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
  //ifieldcomponent
   procedure setdsintf(const avalue: idsfieldcontroller);
   function getinstance: tfield;
   function getdefaultexpression: msestring;
   procedure setdefaultexpression(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
   procedure setasnullmsestring(const avalue: msestring);
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getasunicodestring: unicodestring; override;
   procedure setasunicodestring(const avalue: unicodestring); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   procedure setismsestring(const getter: getmsestringdataty;
                            const setter: setmsestringdataty;
                            const acharacterlength: integer;
                            const aisftwidestring: boolean);
   function GetDataSize: integer; override;
   function GetAsString: string; override;
   function GetAsVariant: variant; override;
   procedure SetAsString(const AValue: string); override;
   procedure SetVarValue(const AValue: Variant); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   destructor destroy; override;
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property asnullmsestring: msestring read getasunicodestring 
                                          write setasnullmsestring;
                        //'' -> NULL
   function oldmsestring(out aisnull: boolean): msestring; overload;
   function oldmsestring: msestring; overload;
   function curmsestring(out aisnull: boolean): msestring; overload;
   function curmsestring: msestring; overload;
//   property value: msestring read getasmsestring write setasmsestring;
   property characterlength: integer read fcharacterlength;
   property tagpo: pointer read ftagpo write ftagpo;
   property isftwidestring: boolean read fisftwidestring;
  published
   property defaultexpression: msestring read getdefaultexpression 
                                                write setdefaultexpression;
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property Transliterate default false;
 end;

 tmseguidfield = class(tmsefield,imsefield)
  private
  protected
   function getasvariant: variant; override;
   procedure setvarvalue(const avalue: variant); override;
   function getasstring: string; override;
   procedure setasstring(const avalue: string); override;
   function getdefaultwidth: longint; override;
   function getdatasize: integer; override;

   function getasguid: tguid; override;
   procedure setasguid(const avalue: tguid); override;
  public
   constructor create(aowner: tcomponent); override;
   property asguid: tguid read getasguid write setasguid;
   property value: tguid read getasguid write setasguid;
  published
 end;

 tmsenumericfield = class(tnumericfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
 end;
 tmselongintfield = class(tlongintfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
   procedure setasenum(const avalue: integer);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;

  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
   procedure setaslargeint(avalue: largeint); override;
   function getaslargeint: largeint; override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
   function asoldid: integer;
   function sum: integer;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
//   property asid: integer read getasid write setasid; //-1 -> NULL
   property asenum: integer read getaslongint write setasenum;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end;
 tmselargeintfield = class(tlargeintfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
   function getasid: int64;
   procedure setasid(const avalue: int64);
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
   function asoldid: int64;
   function sum: int64;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
//   property asid: int64 read getasid write setasid; //-1 -> NULL
   property Value: Largeint read GetAsLargeint write SetAsLargeint;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end;
 tmsesmallintfield = class(tsmallintfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
   function getasid: integer;
   procedure setasid(const avalue: integer);
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
   procedure setaslargeint(avalue: largeint); override;
   function getaslargeint: largeint; override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
   property asid: integer read getasid write setasid; //-1 -> NULL
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end;
 tmsewordfield = class(twordfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasboolean: boolean; override;
   procedure setasboolean(avalue: boolean); override;
   procedure setaslargeint(avalue: largeint); override;
   function getaslargeint: largeint; override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end;
 tmseautoincfield = class(tautoincfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end;
 tmsefloatfield = class(tfloatfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasfloat: double; override;
   function getascurrency: currency; override;
   procedure setasfloat(avalue: double); override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
   function GetAsLongint: Longint; override;
   procedure change; override;
   function GetAsLargeint: Largeint; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
   function sum: double;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end;
 tmsecurrencyfield = class(tmsefloatfield)
  public
   constructor create(aowner: tcomponent); override;
 end;
 tmsebooleanfield = class(tbooleanfield,imsefield)
  private
   fstate: fieldstatesty;
   fdisplayvalues: msestring;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
   procedure setdisplayvalues(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   fdisplays : array[boolean,boolean] of msestring;
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasunicodestring: unicodestring; override;
   procedure setasunicodestring(const avalue: unicodestring); override;
   function GetDataSize: integer; override;
   function GetAsBoolean: Boolean; override;
   procedure SetAsBoolean(AValue: Boolean); override;
   function getasstring: string; override;
   procedure setasstring(const avalue: string); override;
   function GetDefaultWidth: Longint; override;
   function GetAsLongint: Longint; override;
   procedure SetAsLongint(AValue: Longint); override;
   function GetAsVariant: variant; override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   constructor Create(AOwner: TComponent); override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
   function sum: integer; //counts true values
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property displayvalues: msestring read fdisplayvalues write setdisplayvalues;
   property FieldKind default fkData;
   property HasConstraints default false;
//   property Lookup default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
//   property DisplayWidth default 5; variable!
 end;
 
 datetimefieldoptionty = (dtfo_utc,dtfo_local); //DB time format
 datetimefieldoptionsty = set of datetimefieldoptionty;
                       
 tmsedatetimefield = class(tdatetimefield,imsefield)
  private
   fstate: fieldstatesty;
   foptions: datetimefieldoptionsty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
   procedure setoptions(const avalue: datetimefieldoptionsty);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasdatetime: tdatetime; override;
   procedure setasdatetime(avalue: tdatetime); override;
   procedure setasstring(const avalue: string); override;
   function gettext1(const r: tdatetime; const adisplaytext: boolean): msestring;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property options: datetimefieldoptionsty read foptions 
                                           write setoptions default [];
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 10;
 end; 
 tmsedatefield = class(tmsedatetimefield)
  public
   constructor create(aowner: tcomponent); override;
 end;
 tmsetimefield = class(tmsedatetimefield)
  public
   constructor create(aowner: tcomponent); override;
 end;
 
 tmsebinaryfield = class(tbinaryfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasunicodestring: unicodestring; override;
   procedure setasunicodestring(const avalue: unicodestring); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
 end;
 tmsebytesfield = class(tbytesfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasunicodestring: unicodestring; override;
   procedure setasunicodestring(const avalue: unicodestring); override;
   function getasvariant: variant; override;
   function getasstring: string; override;
   procedure setasstring(const avalue: string); override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
 end;
 tmsevarbytesfield = class(tvarbytesfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
//   function getaswidestring: widestring; override;
//   procedure setaswidestring(const avalue: widestring); override;
//   function getasunicodestring: unicodestring; override;
//   procedure setasunicodestring(const avalue: unicodestring); override;
   function getasvariant: variant; override;
   procedure setasstring(const avalue: string); override;
   function getasstring: string; override;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
 end;
 tmsebcdfield = class(tbcdfield,imsefield)
  private
   fstate: fieldstatesty;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   procedure setasfloat(avalue: double); override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
   class procedure checktypesize(avalue: longint); override;
   property tagpo: pointer read ftagpo write ftagpo;
   procedure change; override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function HasParent: Boolean; override;
   procedure Clear; override;
   function assql: msestring;
   function asoldsql: msestring;
   function sum: currency;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   property Value: Currency read GetAsCurrency write SetAsCurrency;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property precision default 15;
//   property displaywidth default 15; variable!
   property currency default false;
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
 
 tmseblobfield = class(tblobfield,imsefield)
  private
   fcache: tblobcache;
   ftagpo: pointer;
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
   procedure setcachekb(const avalue: integer);
   function getcachekb: integer;
    //imsefield
//   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   fgetblobid: getblobidfuncty;
//   function getasmsestring: msestring; virtual;
//   procedure setasmsestring(const avalue: msestring); virtual;
   procedure readlookup(reader: treader);
         //workaround for breaking fix of FPC Mantis 12809
   procedure defineproperties(filer: tfiler); override;
   procedure removecache(const aid: blobidty); overload; virtual;
   procedure removecache; overload;
   function getasvariant: variant; override;
   function getasstring: string; override;
   procedure setasstring(const avalue: string); override;
//   function getaswidestring: widestring; override;
//   procedure setaswidestring(const avalue: widestring); override;
   procedure gettext(var atext: string; adisplaytext: boolean); override;
   procedure SetDataset(AValue : TDataset); override;
  public
   destructor destroy; override;
   function HasParent: Boolean; override;
   procedure Clear; override;
   procedure clearcache; virtual;
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   procedure LoadFromStream(Stream: TStream);
   procedure LoadFromFile(const FileName: filenamety);
   procedure SaveToFile(const FileName: filenamety);
   property tagpo: pointer read ftagpo write ftagpo;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property cachekb: integer read getcachekb write setcachekb default 0;
                //cachesize in kilo bytes, 0 -> no cache
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
 end;
 tmsememofield = class(tmseblobfield,ifieldcomponent)
  private
   fdsintf: idsfieldcontroller;
   //ifieldcomponent
   procedure setdsintf(const avalue: idsfieldcontroller);
   function getinstance: tfield;
  protected
   function getaswidestring: widestring; override;
   procedure setaswidestring(const avalue: widestring); override;
   function getasunicodestring: msestring; override;
   procedure setasunicodestring(const avalue: msestring); override;
   function getasvariant: variant; override;
   procedure setvarvalue(const avalue: variant); override;
   procedure gettext(var thetext: string; adisplaytext: boolean); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure Clear; override;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
   function oldmsestring(out aisnull: boolean): msestring;
   function assql: msestring;
   function asoldsql: msestring;
  published
   property Transliterate default True;
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
 end;

 tmsevariantfield = class;
 setvardataty = procedure(const sender: tmsevariantfield;
                                  avalue: variant) of object;
 getvardataty = function(const sender: tmsevariantfield;
                          out avalue: variant): boolean of object;
 tmsevariantfield = class(tvariantfield,imsefield)
  private
//   fproviderflags1: providerflags1ty;
//   flookupinfo: lookupfieldinfoty;
    //imsefield
//m   function getproviderflags1: providerflags1ty;
//   function getlookupinfo: plookupfieldinfoty;
  protected
   fgetvardata: getvardataty;
   fsetvardata: setvardataty;
   function getdatasize: integer; override;
   function getasvariant: variant; override;
   procedure setvarvalue(const avalue: variant); override;

   function getasboolean: boolean; override;
   function getasinteger: integer; override;
   function getasdatetime: tdatetime; override;
   function getasfloat: double; override;
//   function getasstring: string; override;
//   function getaswidestring: widestring; override;
//   function getasunicodestring: unicodestring; override;
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);

   function getaslongint: longint; override;
   procedure setaslongint(avalue: longint); override;
   function getaslargeint: largeint; override;
   procedure setaslargeint(avalue: largeint); override;
   function getascurrency: currency; override;
   procedure setascurrency(avalue: currency); override;
   procedure SetDataset(AValue : TDataset); override;
  public
   function assql: msestring;
   function asoldsql: msestring;
//   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
//   property providerflags1: providerflags1ty read fproviderflags1 
//                        write fproviderflags1 default [];
   property DataSet stored false;
//   property ProviderFlags default defaultproviderflags;
   property FieldKind default fkData;
   property HasConstraints default false;
   property LookupCache default false;
//   property ReadOnly default false;
//   property Required default false;
   property DisplayWidth default 15;
 end;

 tmsedatalink = class(tdatalink)
  private
   function getrecnozerobased: integer;
   procedure setrecnozerobased(const avalue: integer);
  protected
   fcanclosing: integer;
   fdscontroller: tdscontroller;
   procedure checkcontroller;
   procedure activechanged; override;
   function getdataset: tdataset;
   function getutf8: boolean;
   function getfiltereditkind: filtereditkindty;
   function  GetActiveRecord: Integer; override;
   procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
   procedure disabledstatechange; virtual;
   function canedit: boolean;
   procedure setbuffercount(value: integer); override;
  public
   destructor destroy; override;
   function moveby(distance: integer): integer; override;
   function noedit: boolean;
   function caninsert: boolean;
   function canappend: boolean;
   function candelete: boolean;
   function canupdate: boolean;
   property dataset: tdataset read getdataset;
   property dscontroller: tdscontroller read fdscontroller;
   property utf8: boolean read getutf8;
   property filtereditkind: filtereditkindty read getfiltereditkind;
   function canclose: boolean;
   property recnozerobased: integer read getrecnozerobased 
                                          write setrecnozerobased;
 end;

 fielddatalinkstatety = (fds_ismsestring,fds_islargeint,fds_isstring,
                         fds_editing,fds_modified,fds_filterediting,
                              fds_filtereditdisabled);
 fielddatalinkstatesty = set of fielddatalinkstatety;

 tfieldsdatalink = class(tmsedatalink,iifiserver)
  protected
   procedure activechanged; override;
   procedure layoutchanged; override;
   procedure updatefields; virtual;
   procedure fieldchanged; virtual;
    //iifiserver
   procedure execute(const sender: iificlient); virtual;
   procedure valuechanged(const sender: iificlient); virtual;
   procedure statechanged(const sender: iificlient;
                            const astate: ifiwidgetstatesty); virtual;
   procedure setvalue(const sender: iificlient;
                var avalue; var accept: boolean; const arow: integer); virtual;
   procedure dataentered(const sender: iificlient; 
                                                 const arow: integer); virtual;
   procedure sendmodalresult(const sender: iificlient; 
                             const amodalresult: modalresultty); virtual;
   procedure updateoptionsedit(var avalue: optionseditty); virtual;
 end;
  
 tfielddatalink = class(tfieldsdatalink)
  private
   ffield: tfield;
   ffieldname: string;
   fnullsymbol: msestring;
   procedure setfieldname(const Value: string);
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   function getmsedefaultexpression: msestring;
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
   function getislargeint: boolean;
   function getismsestring: boolean;
   function getisstringfield: boolean;
  protected
   fstate: fielddatalinkstatesty;
   procedure setfield(const value: tfield); virtual;
   procedure updatefields; override;
   function getsortfield: tfield; virtual;
  public
   function assql: msestring;
   function fieldactive: boolean;
   procedure clear;
   property field: tfield read ffield;
   property sortfield: tfield read getsortfield;
   property fieldname: string read ffieldname write setfieldname;
   property state: fielddatalinkstatesty read fstate;
   property islargeint: boolean read getislargeint;
   property ismsestring: boolean read getismsestring;
   property isstringfield: boolean read getisstringfield;
   
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
   property msedefaultexpression: msestring read getmsedefaultexpression;
   function msedisplaytext(const aformat: msestring = '';
                          const aedit: boolean = false): msestring; virtual;
   property nullsymbol: msestring read fnullsymbol write fnullsymbol;
 end;
 
// fieldarrayty = array of tfield;
 
 fieldclassty = class of tfield;
 
 fieldclasstypety = (ft_unknown,ft_string,ft_guid,ft_numeric,
                     ft_longint,ft_largeint,ft_smallint,
                     ft_word,ft_autoinc,ft_float,ft_currency,ft_boolean,
                     ft_datetime,ft_date,ft_time,
                     ft_binary,ft_bytes,ft_varbytes,
                     ft_bcd,ft_blob,ft_memo,ft_graphic,ft_variant);
 fieldclasstypearty = array of fieldclasstypety; 
        
 tmsedatasource = class(tdatasource)
  public
   procedure bringtofront; //called first by dataset
 end;
 
 tpersistentfields = class(tpersistentarrayprop,ipersistentfieldsinfo)
  private
   fdataset: tdataset;
   procedure readfields(reader: treader);
   procedure writefields(writer: twriter);
   procedure setitems(const index: integer; const avalue: tfield);
   function getitems(const index: integer): tfield;
  protected
   finvaliditems: booleanarty;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure defineproperties(filer: tfiler); override;
   function ispropertystored(index: integer): boolean; override;
  public
   constructor create(const adataset: tdataset);
   class function getitemclasstype: persistentclassty; override;
   procedure move(const curindex,newindex: integer); override;
   procedure updateorder;
   function getfieldnames: stringarty;
   property dataset: tdataset read fdataset;
   property items[const index: integer]: tfield read getitems write setitems; default;
 end;

 datasetoptionty = (dso_utf8,dso_stringmemo,dso_numboolean,
                         dso_waitcursor,
                         dso_initinternalcalc,

                            //flags below have been moved to 
                            //tsqlquery.options
                         dso_postsavepoint,dso_deletesavepoint,
                         dso_cancelupdateonerror,dso_cancelupdatesonerror,
                         dso_cancelupdateondeleteerror,
                         dso_editonapplyerror,
                         dso_restoreupdateonsavepointrollback,
                         dso_noapply,dso_autoapply,
                         dso_autocommitret,dso_autocommit,
                         dso_refreshafterapply,dso_recnoapplyrefresh,
                         dso_refreshtransaction,
                         dso_notransactionrefresh,dso_recnotransactionrefresh,
                         dso_noprepare,
                         dso_cacheblobs,
                         dso_offline, //disconnect database after open
                         dso_local,   //do not connect database on open
                        
                         dso_refreshwaitcursor, //deprecated
                         dso_noedit,dso_noinsert,dso_noappend,dso_noupdate,
                         dso_nodelete,
                         dso_canceloncheckbrowsemode
                         {,
                         dso_syncmasteredit,dso_syncmasterinsert, 
                                                     -> optionsmasterlink
                         dso_syncmasterdelete,dso_delayeddetailpost,
                         dso_inserttoupdate,dso_syncinsertfields}); 
 datasetoptionsty = set of datasetoptionty;
const
 deprecatedbdsoptions = [
                         dso_postsavepoint,dso_deletesavepoint,
                         dso_cancelupdateonerror,dso_cancelupdatesonerror,
                         dso_cancelupdateondeleteerror,
                         dso_editonapplyerror,
                         dso_restoreupdateonsavepointrollback,
                         dso_noapply,dso_autoapply,
                         dso_autocommitret,dso_autocommit,
                         dso_refreshafterapply,dso_recnoapplyrefresh,
                         dso_refreshtransaction,
                         dso_notransactionrefresh,dso_recnotransactionrefresh,
                         dso_noprepare,
                         dso_cacheblobs,
                         dso_offline, //disconnect database after open
                         dso_local   //do not connect database on open
                         ];
type
 savepointoptionty = (spo_postsavepoint,spo_deletesavepoint);
 savepointoptionsty = set of savepointoptionty;
 
 idscontroller = interface(iactivatorclient)
  procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
  procedure inheritedcancel;
  procedure inheritedpost;
  procedure inheritedinsert;
  procedure inheriteddelete;
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
  procedure clearfilter;
  procedure begindisplaydata;
  procedure enddisplaydata;
//  procedure doidleapplyupdates;
//  procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
  function getrestorerecno: boolean;
  procedure setrestorerecno(const avalue: boolean);
  property restorerecno: boolean read getrestorerecno write setrestorerecno;
                          //for refresh
  function islastrecord: boolean;
  function updatesortfield(const afield: tfield; const adescend: boolean): boolean;
  function getsavepointoptions(): savepointoptionsty;
 end;

 igetdscontroller = interface(inullinterface)[miid_igetdscontroller]
  function getcontroller: tdscontroller;
 end;

 fieldlinkarty = array of ifieldcomponent;
 dscontrollerstatety = (dscs_posting,dscs_posting1,dscs_canceling,
                        dscs_onidleregistered,
                        dscs_restorerecno);
 dscontrollerstatesty = set of dscontrollerstatety;

 datasetstatechangedeventty = procedure(const sender: tdataset;
                                  const statebefore: tdatasetstate) of object;
 masterdataseteventty = procedure(const sender: tdataset;
                                 const master: tdataset) of object;
 slavedataseteventty = procedure(const sender: tdataset;
                                 const slave: tdataset) of object;
 afterdbopeventty = procedure(const sender: tdataset;
                                         var ok: boolean) of object;
 epostcancel = class(eabort);

 opkindty = (opk_post,opk_delete,opk_insert);
 
 tdscontroller = class(tactivatorcontroller,idsfieldcontroller)
  private
   ffields: tpersistentfields;
//   fintf: idscontroller;
   frecno: integer;
   frecnovalid: boolean;
   fscrollsum: integer;
   factiverecordbefore: integer;
   fbuffercountbefore: integer;
   frecnooffset: integer;
   fmovebylock: boolean;
   fcancelresync: boolean;
   finsertbm: bookmarkty;
   flinkedfields: fieldlinkarty;
   fstate: dscontrollerstatesty;
//   fdelayedapplycount: integer;
   fbmbackup: bookmarkty;
   fupdatecount: integer;
   fstatebefore: tdatasetstate;
   fonstatechanged: datasetstatechangedeventty;
   fonupdatemasteredit: masterdataseteventty;
   fonupdatemasterinsert: masterdataseteventty;
   ftimer: tsimpletimer;
   fonbeforepost: tdatasetnotifyevent;
   fonafterpost: afterdbopeventty;
   fonbeforecopyrecord: tdatasetnotifyevent;
   fonaftercopyrecord: tdatasetnotifyevent;
   fonbeforedelete: tdatasetnotifyevent;
   fonafterdelete: afterdbopeventty;
   procedure setfields(const avalue: tpersistentfields);
   function getcontroller: tdscontroller;
   procedure updatelinkedfields;
   function getrecnozerobased: integer;
   procedure setrecnozerobased(const avalue: integer);
   function getrecno: integer;
   procedure setrecno(const avalue: integer);
//   procedure registeronidle;
//   procedure unregisteronidle;
//   procedure setdelayedapplycount(const avalue: integer);
   function getnoedit: boolean;
   procedure setnoedit(const avalue: boolean);
   procedure nosavepoint;
   function getasmsestring(const afieldname: string): msestring;
   procedure setasmsestring(const afieldname: string; const avalue: msestring);
   function getnoinsert: boolean;
   procedure setnoinsert(const avalue: boolean);
   function getnoappend: boolean;
   procedure setnoappend(const avalue: boolean);
   function getnoupdate: boolean;
   procedure setnoupdate(const avalue: boolean);
   function getnodelete: boolean;
   procedure setnodelete(const avalue: boolean);
   procedure readdelayedapplycount(reader: treader);
  protected
   foptions: datasetoptionsty;
   procedure setoptions(const avalue: datasetoptionsty); virtual;
   procedure setowneractive(const avalue: boolean); override;
   procedure fielddestroyed(const sender: ifieldcomponent);
//   procedure doonidle(var again: boolean);
   procedure dorefresh(const sender: tobject);
   function savepointbegin: integer; virtual;
   procedure savepointrollback(const aindex: integer = -1); virtual;
                           //-1 = toplevel
   procedure savepointrelease; virtual;
   function execoperation(const akind: opkindty;
                              const aafterop: afterdbopeventty): boolean;
   procedure defineproperties(filer: tfiler) override;      
  public
   constructor create(const aowner: tdataset; const aintf: idscontroller;
                      const arecnooffset: integer = -1;
                      const acancelresync: boolean = true);
   destructor destroy; override;
   function isutf8: boolean;
   function getfieldar(const afieldkinds: tfieldkinds = allfieldkinds): fieldarty;
   function filtereditkind: filtereditkindty;
   procedure beginupdate; //calls diablecontrols, stores bookmark
   procedure endupdate;   //restores bookmark, calls enablecontrols
   function locate(const afields: array of tfield;
                   const akeys: array of const; const aisnull: array of boolean;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
   procedure appendrecord(const values: array of const);
   procedure appendrecord1(const values: array of const;
                                       const aisnull: array of boolean);
   procedure appendrecord(const values: array of const;
                                       const afields: array of tfield);
   procedure appendrecord1(const values: array of const;
               const aisnull: array of boolean; const afields: array of tfield);
   procedure appendrecord(const values: variantarty);
   procedure appenddata(const adata: variantararty; 
                                           const afields: array of tfield);
                                                     //[] -> all
   procedure getfieldclass(const fieldtype: tfieldtype; out result: tfieldclass);
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure clearfilter();
   procedure endfilteredit;
   procedure begindisplaydata; {$ifdef FPC}inline;{$endif}
   procedure enddisplaydata; {$ifdef FPC}inline;{$endif}
   function getcanmodify: boolean;
   function updatesortfield(const alink: tfielddatalink;
                              const adescend: boolean): boolean;
                      //true if index active

   procedure modified;
   procedure dataevent(const event: tdataevent; info: ptrint);
   property recno: integer read getrecno write setrecno;
   property recnozerobased: integer read getrecnozerobased
                                       write setrecnozerobased;
   property recnooffset: integer read frecnooffset;
   function findrecno(const arecno: integer; 
                            const options: recnosearchoptionsty = []): integer;
   function findrecnozerobased(const arecno: integer; 
                            const options: recnosearchoptionsty = []): integer;
   
   function moveby(const distance: integer): integer;
   function islastrecord: boolean;
   procedure internalinsert;
   procedure internaldelete;
   procedure internalopen;
   procedure internalclose;
   procedure closequery(var amodalresult: modalresultty); overload;
   function closequery: boolean; overload; //true if ok
   function post(const aafterpost: afterdbopeventty = nil): boolean;
                           //calls post if in edit or insert state,
                           //returns true if ok
//   procedure insert(const aafterinsert: afterdbopeventty = nil);
   function delete(const aafterdelete: afterdbopeventty = nil): boolean;
   function posting: boolean; //true if in inner post procedure
   function posting1: boolean; //true if in outer post procedure
   procedure postcancel; //can be called in BeforePost, calls cancel after abort
   procedure cancel;
   function canceling: boolean;
   function emptyinsert: boolean;
   procedure refresh(const restorerecno: boolean; const delayus: integer = -1);
                           //-1 -> no delay, 0 -> in onidle
   procedure checkrefresh; //makes pending delayed refresh
   procedure copyrecord(const aappend: boolean = false);

   function assql(const avalue: boolean): msestring; overload;
   function assql(const avalue: msestring): msestring; overload;
   function assql(const avalue: integer): msestring; overload;
   function assql(const avalue: int64): msestring; overload;
   function assql(const avalue: currency): msestring; overload;
   function assqlcurrency(const avalue: realty): msestring; overload;
   function assql(const avalue: realty): msestring; overload;
   function assql(const avalue: tdatetime): msestring; overload;
   function assqldate(const avalue: tdatetime): msestring;
   function assqltime(const avalue: tdatetime): msestring;
   
   property noedit: boolean read getnoedit write setnoedit;
   property noinsert: boolean read getnoinsert write setnoinsert;
   property noappend: boolean read getnoappend write setnoappend;
   property noupdate: boolean read getnoupdate write setnoupdate;
   property nodelete: boolean read getnodelete write setnodelete;
   property asmsestring[const afieldname: string]: msestring 
                                     read getasmsestring write setasmsestring;
   
  published
   property fields: tpersistentfields read ffields write setfields;
   property options: datasetoptionsty read foptions write setoptions 
                   default defaultdscontrolleroptions;
//   property delayedapplycount: integer read fdelayedapplycount 
//                                       write setdelayedapplycount default 0;
               //0 -> no autoapply
   property onstatechanged: datasetstatechangedeventty read fonstatechanged 
                                                write fonstatechanged;
   property onupdatemasteredit: masterdataseteventty read fonupdatemasteredit 
                     write fonupdatemasteredit;
   property onupdatemasterinsert: masterdataseteventty 
                   read fonupdatemasterinsert write fonupdatemasterinsert;
   property onbeforepost: tdatasetnotifyevent read fonbeforepost
                                                       write fonbeforepost;
   property onafterpost: afterdbopeventty read fonafterpost write fonafterpost;
                       //always called
   property onbeforedelete: tdatasetnotifyevent read fonbeforedelete
                                                       write fonbeforedelete;
   property onafterdelete: afterdbopeventty read fonafterdelete
                                               write fonafterdelete;
                       //always called
   property onbeforecopyrecord: tdatasetnotifyevent read fonbeforecopyrecord
                                                     write fonbeforecopyrecord;
   property onaftercopyrecord: tdatasetnotifyevent read fonaftercopyrecord
                                                     write fonaftercopyrecord;
 end;
 
 idbcontroller = interface(iactivatorclient)[miid_idbcontroller]
  procedure setinheritedconnected(const avalue: boolean);
  function readsequence(const sequencename: string): msestring;
  function sequencecurrvalue(const sequencename: string): msestring;
  function writesequence(const sequencename: string;
                    const avalue: largeint): msestring;
  function ExecuteDirect(const SQL : mseString;
               const aisutf8: boolean): integer;
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
 
 fieldlinkoptionty = (flo_onlyifnull,flo_notifunmodifiedinsert,flo_utc);
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
   function getdataset(const aindex: integer): tdataset;
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
   function getfieldname: string;
   procedure setfieldname(const avalue: string);
   function getdatasource: tdatasource;
   function getdatasource1(const aindex: integer): tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   procedure readdatafield(reader: treader);
   //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
   function getdataset(const aindex: integer): tdataset;
  protected
   procedure updatedata(const afield: tfield); override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function sourcefield: tfield;
  published
   property fieldname: string read getfieldname 
                             write setfieldname;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
 
 tparamconnector = class;

 tmseparam = class(tparam,idbeditinfo)
  private
   fconnector: tparamconnector;
   fdatalink: tfielddatalink;
   procedure setasvariant(const avalue: variant);
//   function getasid: int64;
//   procedure setasid(const avalue: int64);
//   function getasmsestring: msestring;
//   procedure setasmsestring(const avalue: msestring);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   function getfieldname: string;
   procedure setfieldname(const avalue: string);
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset;
   procedure getfieldtypes(out apropertynames: stringarty;
                           out afieldtypes: fieldtypesarty);
   function isparamstored: boolean;
   procedure setconnector(const avalue: tparamconnector);
  public
   constructor Create(ACollection: TCollection); overload; override;
   destructor destroy; override;
//   property asid: int64 read getasid write setasid; //-1 -> null
//   property asmsestring: msestring read getasmsestring write setasmsestring;
  published
   property connector: tparamconnector read fconnector write setconnector;
   property datasource: tdatasource read getdatasource write setdatasource;
   property fieldname: string read getfieldname write setfieldname;
   property value : variant read getasvariant write setasvariant 
                                                  stored isparamstored;
 end;

 tparamconnector = class(tmsecomponent)
  private
   fparam: tmseparam;
   function getparam: tmseparam;
  public
   destructor destroy; override;
   property param: tmseparam read getparam;
 end;
    
 tmseparams = class(tparams)
  private
   fisutf8: boolean;
   function getitem(const index: integer): tmseparam;
   procedure setitem(const index: integer; const avalue: tmseparam);
   function getvalues: variantarty;
   procedure setvalues(const avalue: variantarty);
  public
   constructor create(aowner: tpersistent); overload;
   constructor create; overload;
   procedure updatevalues;
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
   function bindnames(const anames: msestringarty): integerarty;
                     //returns index in anames for paramnames, -1 if not found
                     //case sensitive
   property isutf8: boolean read fisutf8 write fisutf8;
   property items[const index: integer]: tmseparam read getitem write setitem; default;
   property values: variantarty read getvalues write setvalues;
 end;

const
 fieldtypeclasses: array[fieldclasstypety] of fieldclassty = 
          (tfield,tstringfield,tguidfield,tnumericfield,
           tlongintfield,tlargeintfield,tsmallintfield,
           twordfield,tautoincfield,tfloatfield,tcurrencyfield,
           tbooleanfield,
           tdatetimefield,tdatefield,ttimefield,
           tbinaryfield,tbytesfield,tvarbytesfield,
           tbcdfield,tblobfield,tmemofield,tgraphicfield,
           tvariantfield);

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
      ft_string,ft_largeint,ft_unknown,ft_unknown,ft_unknown,
    //ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface,
      ft_unknown,ft_unknown,ft_unknown,ft_variant,ft_unknown,
    //ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd
      ft_unknown,  ft_guid,ft_unknown,  ft_unknown
    //ftFixedWideChar,ftWideMemo
      ,ft_string,    ft_string
      );

 realfcomp = [ftfloat,ftcurrency];
 datetimefcomp = [ftdate,fttime,ftdatetime];
 blobfcomp = [ftblob,ftgraphic,ftmemo];
 memofcomp = [ftmemo];
 longintfcomp = [ftboolean,ftsmallint,ftinteger,ftword];
 largeintfcomp = longintfcomp + [ftlargeint];
 stringfcomp = [ftstring,ftguid,ftfixedchar,ftwidestring,ftfixedwidechar,
                ftwidememo];
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
     stringfcomp,[ftLargeint],[ftADT],[ftArray],[ftReference],
    //ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface,
      [ftDataSet],[ftOraBlob],[ftOraClob],[ftVariant],[ftInterface],
    //ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd);
      [ftIDispatch],[ftGuid],[ftTimeStamp],[ftFMTBcd]
    //ftFixedWideChar,ftWideMemo
      ,stringfcomp,stringfcomp
      );

function getdsfields(const adataset: tdataset;
                  const afields: array of tfield): fieldarty;
                     //[] -> all
function getfielddefar(const fielddefs: tfielddefs): fielddefarty;

function getmsefieldclass(const afieldtype: tfieldtype): tfieldclass; overload;
function getmsefieldclass(const afieldtype: fieldclasstypety): tfieldclass; overload;
function fieldvariants(const afields: array of tfield): variantarty;
function fieldclasstoclasstyp(const fieldclass: fieldclassty): fieldclasstypety;
function fieldtosql(const field: tfield): msestring;
function fieldtooldsql(const field: tfield): msestring;
function paramtosql(const aparam: tparam): msestring;
function fieldchanged(const field: tfield): boolean;
function curfieldchanged(const field: tfield): boolean;
procedure fieldtoparam(const field: tfield; const param: tparam);
procedure copyfieldvalues(const source: tdataset; const dest: tdataset);
procedure msestringtoparam(const avalue: msestring; const param: tparam);
function getasmsestring(const field: tfield; const utf8: boolean = true): msestring;
procedure setasmsestring(const avalue: msestring;
              const field: tfield; const utf8: boolean = true);
function checkfieldcompatibility(const afield: tfield;
                     const adatatype: tfieldtype): boolean;
           //true if ok
function vartorealty(const avalue: variant): realty;
{
function locaterecord(const adataset: tdataset; const autf8: boolean; 
                         const key: msestring; const field: tfield;
                         const options: locateoptionsty = []): locateresultty;
function locaterecord(const adataset: tdataset; const key: integer;
                       const field: tfield;
                       const options: locateoptionsty = []): locateresultty;
}
function locaterecord(const adataset: tdataset; const fields: array of tfield;
                     const keys: array of const; //nil -> NULL field
                     const isnull: array of boolean;
                     const keyoptions: array of locatekeyoptionsty;
                     const options: locaterecordoptionsty): locateresultty;
                             
function encodesqlstring(const avalue: msestring): msestring;
function encodesqlcstring(const avalue: msestring): msestring;
function encodesqlblob(const avalue: string): msestring;
function encodesqlinteger(const avalue: integer): msestring;
function encodesqllongword(const avalue: longword): msestring;
function encodesqllargeint(const avalue: int64): msestring;
function encodesqlqword(const avalue: qword): msestring;
function encodesqldatetime(const avalue: tdatetime): msestring;
function encodesqldate(const avalue: tdatetime): msestring;
function encodesqltime(const avalue: tdatetime): msestring;
function encodesqlfloat(const avalue: real): msestring;
function encodesqlcurrency(const avalue: currency): msestring;
function encodesqlboolean(const avalue: boolean): msestring;
function encodesqlvariant(const avalue: variant; cstyle: boolean): msestring;

procedure regfieldclass(const atype: fieldclasstypety; const aclass: fieldclassty);

procedure varianttorealty(const value: variant; out dest: realty); overload;
function varianttorealty(const value: variant):realty; overload;
procedure realtytovariant(const value: realty; out dest: variant); overload;
function realtytovariant(const value: realty): variant; overload;
function varianttoid(const value: variant): int64; //null -> -1
function idtovariant(const value: int64): variant; //-1 -> null
function varianttomsestring(const value: variant): msestring; //null -> ''
function msestringtovariant(const value: msestring): variant; //'' -> null

function dbtrystringtoguid(const value: string; out guid: tguid): boolean;
function dbstringtoguid(const value: string): tguid;
function dbguidtostring(const avalue: tguid): string;
function dbcreateguidstring: string;
function guidparam(const value: tguid): varrecarty;

function opentodynarrayft(const items: array of tfieldtype): fieldtypearty;

implementation
uses
 rtlconsts,msefileutils,typinfo,{$ifdef FPC}dbconst{$else}dbconst_del{$endif},
 msearrayutils,mseformatstr,msebits,msefloattostr,msebufdataset,
 msereal,variants,msedate,msesys,sysconst
 {,msedbgraphics}{$ifdef unix},cwstring{$endif};
const
 fieldnamedummy = ';%)(mse';
var
 msefieldtypeclasses: array[fieldclasstypety] of fieldclassty = 
         // ft_unknown, ft_string,   ft_guid,      ft_numeric,
          (tmsefield,tmsestringfield,tmseguidfield,tmsenumericfield,
         //  ft_longint,         ft_largeint,    ft_smallint,
           tmselongintfield,tmselargeintfield,tmsesmallintfield,
         //    ft_word,     ft_autoinc,       ft_float,      ft_currency,
           tmsewordfield,tmseautoincfield,tmsefloatfield,tmsecurrencyfield,
         //   ft_boolean,
           tmsebooleanfield,
         //   ft_datetime,      ft_date,      ft_time,
           tmsedatetimefield,tmsedatefield,tmsetimefield,
         //  ft_binary,       ft_bytes,       ft_varbytes,
           tmsebinaryfield,tmsebytesfield,tmsevarbytesfield,
         //   ft_bcd,     ft_blob,      ft_memo,       ft_graphic,
           tmsebcdfield,tmseblobfield,tmsememofield,nil{tmsegraphicfield},
         //   ft_variant
           tmsevariantfield);
           
type 
 tdataset1 = class(tdataset);
 tfielddef1 = class(tfielddef);
 tcollection1 = class(tcollection);
 tparam1 = class(tparam);
 tdatasource1 = class(tdatasource);
 tmsebufdataset1 = class(tmsebufdataset);

function dbtrystringtoguid(const value: string; out guid: tguid): boolean;
var
 int1: integer;
 po1: pchar;
 
 function readbyte: byte;
 var 
  by1: byte;
 begin
  by1:= hexchars[po1^];
  inc(po1);
  if shortint(by1) < 0 then begin
   dbtrystringtoguid:= false;
  end;
  result:= hexchars[po1^];
  inc(po1);
  if shortint(result) < 0 then begin
   dbtrystringtoguid:= false;
  end;
  result:= result or (by1 shl 4);
 end;

 function checkhyphen: boolean; {$ifdef FPC}inline;{$endif}
 begin
  result:= po1^ = '-';
  inc(po1);
 end;

begin
 po1:= pointer(value);
 result:= length(value) = guidbuffersize;
 if not result and (length(value) = guidbuffersize+2) and (value[1]='{') and
                              (value[guidbuffersize+2]='}') then begin
  inc(po1);
  result:= true;
 end;
 if result then begin
  with {$ifndef FPC}tguid_fpc({$endif}guid{$ifndef FPC}){$endif} do begin
   time_low:= (readbyte shl 24) or (readbyte shl 16) or (readbyte shl 8) or
                                                                     readbyte;
{$warnings off}
   if checkhyphen then begin
    time_mid:= (readbyte shl 8) or readbyte;
    if checkhyphen then begin
     time_hi_and_version:= (readbyte shl 8) or readbyte;
     if checkhyphen then begin
      clock_seq_hi_and_reserved:= readbyte;
      clock_seq_low:= readbyte;
      if checkhyphen then begin
       for int1:= 0 to high(node) do begin
        node[int1]:= readbyte;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;
{$warnings on}

function dbstringtoguid(const value: string): tguid;
begin
 if not dbtrystringtoguid(value,result) then begin
  raise econverterror.createfmt(sinvalidguid, [value]);
 end;
end;

function dbguidtostring(const avalue: tguid): string;
var
 int1: integer;
begin
 with {$ifndef FPC}tguid_fpc({$endif}avalue{$ifndef FPC}){$endif}do begin
  result:= valtohex(time_low)+'-'+valtohex(time_mid)+'-'+
           valtohex(time_hi_and_version)+'-'+
           valtohex(clock_seq_hi_and_reserved)+valtohex(clock_seq_low)+'-';  
  for int1:= 0 to high(node) do begin
   result:= result+valtohex(node[int1]);
  end;
 end;
end;

function dbcreateguidstring: string;
var
 id: tguid;
begin
 createguid(id);
 result:= dbguidtostring(id);
end;

function guidparam(const value: tguid): varrecarty;
begin
 setlength(result,1);
 with result[0] do begin
  vtype:= mse_vtguid;
  vpointer:= @value;
 end;
end;

function opentodynarrayft(const items: array of tfieldtype): fieldtypearty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function getnumdisplaytext(const sender: tnumericfield; const avalue: double;
                           const adisplaytext: boolean; const acurrency: boolean): string;
var
 str1: ansistring;
begin
 with sender do begin
  if adisplaytext then begin
   str1:= sender.displayformat;
   if (str1 = '') and  acurrency then begin
    str1:= 'c';
   end;
  end
  else begin
   str1:= editformat;
  end;
 end;
 result:= ansistring(formatfloatmse(avalue,msestring(str1)));
end;

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
 if value = emptyreal then begin
  dest:= null;
 end
 else begin
  dest:= value;
 end;
end;

function realtytovariant(const value: realty): variant; overload;
begin
 if value = emptyreal then begin
  result:= null;
 end
 else begin
  result:= value;
 end;
end;

function varianttoid(const value: variant): int64;
begin
 if varisnull(value) or varisempty(value) then begin
  result:= -1;
 end
 else begin
  result:= value;
 end;
end;

function idtovariant(const value: int64): variant;
begin
 if value = -1 then begin
  result:= null;
 end
 else begin
  result:= value;
 end;
end;

function varianttomsestring(const value: variant): msestring; //null -> ''
begin
 if varisnull(value) or varisempty(value) then begin
  result:= '';
 end
 else begin
  result:= value;
 end;
end;

function msestringtovariant(const value: msestring): variant; //'' -> null
begin
 if value = '' then begin
  result:= null;
 end
 else begin
  result:= value;
 end;
end;

function getdsfields(const adataset: tdataset;
             const afields: array of tfield): fieldarty;
var
 int1: integer;
begin
 if high(afields) >= 0 then begin
  setlength(result,length(afields));
  for int1:= 0 to high(result) do begin
   result[int1]:= afields[int1];
  end;
 end
 else begin
  with adataset do begin
   setlength(result,fields.count);
   for int1:= 0 to high(result) do begin
    result[int1]:= fields[int1];
   end;
  end;
 end;
end;

function getfielddefar(const fielddefs: tfielddefs): fielddefarty;
var
 po1: pfielddefty;
 int1: integer;
begin
 setlength(result,fielddefs.count);
 for int1:= 0 to high(result) do begin
  po1:= @result[int1];
  with fielddefs[int1] do begin
   po1^.datatype:= datatype;
   po1^.size:= size;
   po1^.name:= name;
  end;
 end;
end;

procedure regfieldclass(const atype: fieldclasstypety;
                                          const aclass: fieldclassty);
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

function fieldvariants(const afields: array of tfield): variantarty;
var
 int1: integer;
begin
 setlength(result,length(afields));
 for int1:= 0 to high(result) do begin
  result[int1]:= afields[int1].asvariant;
 end;
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
function getasmsestring(const field: tfield; const utf8: boolean = true): msestring;
begin
 if field = nil then begin
  result:= '';
 end
 else begin
  if field is tmsestringfield then begin
   result:= tmsestringfield(field).asmsestring;
  end
  else begin
   if field is tmsememofield then begin
    result:= tmsememofield(field).asmsestring;
   end
   else begin
    if utf8 then begin
     result:= utf8tostringansi(field.asstring);
    end
    else begin
     result:= msestring(field.asstring);
    end;
   end;
  end;
 end;
end;

procedure setasmsestring(const avalue: msestring;
              const field: tfield; const utf8: boolean = true);
begin
 if field <> nil then begin
  if field is tmsestringfield then begin
   tmsestringfield(field).asmsestring:= avalue;
  end
  else begin
   if field is tmsememofield then begin
    tmsememofield(field).asmsestring:= avalue;
   end
   else begin
    if utf8 then begin
     field.asstring:= stringtoutf8ansi(avalue);
    end
    else begin
     field.asstring:= ansistring(avalue);
    end;
   end;
  end;
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
     param.asstring:= stringtoutf8ansi(avalue);
     exit;
    end;
   end;
  end;
  param.asstring:= ansistring(avalue);
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

procedure copyfieldvalues(const source: tdataset; const dest: tdataset);
var
 int1: integer;
 df: tfield;
begin
 for int1:= 0 to source.fieldcount-1 do begin
  with source.fields[int1] do begin
   if visible then begin
    df:= dest.findfield(fieldname);
    if (df <> nil) and not df.readonly then begin
     df.value:= value;
    end;
   end;
  end;
 end;
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

function encodesqlcstring(const avalue: msestring): msestring;
var
 po1: pmsechar;
 innum: boolean;
begin
 result:= '"';
 po1:= pmsechar(avalue);
 innum:= false;
 while po1^ <> #0 do begin
  if (po1^ < #$20) {or (po1^ > #$ff)} or (po1^ = #$7f) then begin
   innum:= true;
   if po1^ < #$100 then begin
    result:= result + '\x'+hextostrmse(ord(po1^),2);
   end
   else begin
    result:= result + '\x'+hextostrmse(ord(po1^),4);
   end;
  end
  else begin
   if po1^ = '"' then begin
    result:= result + '\"';
    innum:= false;
   end
   else begin
    if innum then begin
     result:= result + '" "'+po1^;
     innum:= false;
    end
    else begin
     result:= result + po1^;
    end;
   end;
  end;
  inc(po1);
 end;
 result:= result + '"';
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
  po1^:= msechar(byte(charhex[po2^ shr 4]));
  inc(po1);
  po1^:= msechar(byte(charhex[po2^ and $0f]));
  inc(po1);
  inc(po2);
 end;
 po1^:= '''';
end;

function encodesqlinteger(const avalue: integer): msestring;
begin
 result:= inttostrmse(avalue);
end;

function encodesqllongword(const avalue: longword): msestring;
begin
 result:= msestring(wordtostr(avalue));
end;

function encodesqllargeint(const avalue: int64): msestring;
begin
 result:= inttostrmse(avalue);
end;

function encodesqlqword(const avalue: qword): msestring;
begin
 result:= inttostrmse(avalue);
end;

function encodesqldatetime(const avalue: tdatetime): msestring;
begin
 result := '''' + 
          msestring(formatdatetime('yyyy-mm-dd hh:mm:ss',avalue)) + '''';
end;

function encodesqldate(const avalue: tdatetime): msestring;
begin
 result:= '''' + msestring(formatdatetime('yyyy-mm-dd',avalue)) + '''';
end;

function encodesqltime(const avalue: tdatetime): msestring;
begin
 result:= '''' + msestring(formatdatetime('hh:mm:ss',avalue)) + '''';
end;

function encodesqlfloat(const avalue: real): msestring;
begin
// result:= floattostr(avalue,defaultformatsettingsdot);
  result:= doubletostring(avalue);
// result:= replacechar(floattostr(avalue),
//                    defaultformatsettings.decimalseparator,'.');
//( result:= formatfloatmse(avalue,'');
end;

function encodesqlcurrency(const avalue: currency): msestring;
begin
// result:= formatfloat('0.####',avalue,defaultformatsettingsdot);
 result:= formatfloatmse(avalue,'0.####',defaultformatsettingsmse,true);
// result:= replacechar(formatfloat('0.####',avalue),
//                         defaultformatsettings.decimalseparator,'.')
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

function encodesqlvariant(const avalue: variant;
                              cstyle: boolean): msestring;

 function encode(const atype: word; const abase: pointer): msestring;
 begin
  result:= '';
  case atype of
   varnull: result:= 'NULL';
   varsmallint: result:= encodesqlinteger(psmallint(abase)^);
   varinteger: result:= encodesqlinteger(pinteger(abase)^);
{$ifndef FPUNONE}
   varsingle: result:= encodesqlfloat(psingle(abase)^);
   vardouble: result:= encodesqlfloat(pdouble(abase)^);
   vardate: result:= encodesqldatetime(pdatetime(abase)^);
{$endif}
   varcurrency: result:= encodesqlcurrency(pcurrency(abase)^);
   varolestr: begin
    if cstyle then begin 
     result:= encodesqlcstring(pwidestring(abase)^);
    end
    else begin
     result:= encodesqlstring(pwidestring(abase)^);
    end;
   end;
//   vardispatch = 9;
//   varerror = 10;
   varboolean: begin
    if cstyle then begin
     if pboolean(abase)^ then begin
      result:= '"t"';
     end
     else begin
      result:= '"f"';
     end;
    end
    else begin
     result:= encodesqlboolean(pboolean(abase)^);
    end;
   end;
   varvariant: result:= encodesqlvariant(pvariant(abase)^,cstyle);
//   varunknown = 13;
//   vardecimal = 14;
   varshortint: result:= encodesqlinteger(pshortint(abase)^);
   varbyte: result:= encodesqlinteger(pbyte(abase)^);
   varword: result:= encodesqlinteger(pword(abase)^);
   varlongword: result:= encodesqlinteger(plongword(abase)^);
   varint64: result:= encodesqllargeint(pint64(abase)^);
{$ifdef FPC}
   varqword: result:= encodesqlinteger(pinteger(abase)^);
{$endif}
//   varrecord = 36;

//   varstrarg = $48;
   varstring: begin
    if cstyle then begin 
     result:= encodesqlstring(msestring(pansistring(abase)^));
    end
    else begin
     result:= encodesqlcstring(msestring(pansistring(abase)^));
    end;
   end;
  end;
 end; //encode

 procedure handlearray(const bounds: tvararrayboundarray; 
            const boundsindex: integer;
            var data: pointer; const atype: word; const elementsize: integer);
 var
  int1: integer;
 begin
  if cstyle then begin
   result:= result + '{';
  end
  else begin
   result:= result + '[';
  end;
  if boundsindex = 0 then begin
   for int1:= 0 to bounds[boundsindex].elementcount-1 do begin
    if int1 <> 0 then begin
     result:= result+',';
    end;
    result:= result + encode(atype,data);
    inc(pchar(data),elementsize);
   end;
  end
  else begin
   for int1:= 0 to bounds[boundsindex].elementcount-1 do begin
    if int1 <> 0 then begin
     result:= result+',';
    end;
    handlearray(bounds,boundsindex-1,data,atype,elementsize);
   end;
  end;
  if cstyle then begin
   result:= result + '}';
  end
  else begin
   result:= result + ']';
  end;
 end;

var
 po1: pointer; 
begin
 with tvardata(avalue) do begin
  if vtype and vararray <> 0 then begin
   if not cstyle then begin
    result:= 'ARRAY';
   end
   else begin
    result:= '';
   end;
   with varray^ do begin
    po1:= data;
    handlearray(bounds,dimcount-1,po1,vtype and vartypemask,elementsize);
   end;
  end
  else begin
   cstyle:= false;
   result:= encode(vtype,@vsmallint);
  end;
 end;
end;

function fieldtosql(const field: tfield): msestring;
begin
 if (field = nil) or field.isnull then begin
  result:= 'NULL'
 end
 else begin
  case field.datatype of
   ftstring,ftguid: begin
    if not (field is tmsestringfield) {or 
         (tmsestringfield(field).fdsintf = nil)} then begin
     result:= encodesqlstring(msestring(field.asstring));
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
     result:= encodesqlstring(msestring(field.asstring));
    end;
   end;
   ftblob,ftgraphic,ftbytes,ftvarbytes: begin
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
   ftfloat,ftcurrency: begin
    result:= encodesqlfloat(field.asfloat);
   end;
   ftbcd: begin
    result:= encodesqlcurrency(field.ascurrency);
   end;
   ftboolean: begin
    result:= encodesqlboolean(field.asboolean);
   end;
   ftvariant: begin
    result:= encodesqlvariant(field.asvariant,false);
   end;
   else begin
    result := msestring(field.asstring);
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
   {
    ftstring,ftwidestring: begin
     if (aparam.collection is tmseparams) and 
                         tmseparams(aparam.collection).isutf8 then begin
      result:= encodesqlstring(stringtoutf8ansi(aswidestring));
     end
     else begin
      result:= encodesqlstring(asstring);
     end;
    end;
    }
    ftwidestring: begin
     result:= encodesqlstring(aswidestring);
    end;
    ftstring,ftguid: begin
     result:= encodesqlstring(msestring(asstring));
    end;
    ftmemo: begin
     if (aparam.collection is tmseparams) and tmseparams(collection).isutf8 then begin
      result:= encodesqlstring(utf8tostringansi(asstring));
     end
     else begin
      result:= encodesqlstring(msestring(asstring));
     end;
    end;
    ftblob,ftgraphic,ftbytes,ftvarbytes: begin
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
    ftfloat,ftcurrency: begin
     result:= encodesqlfloat(asfloat);
    end;
    ftbcd: begin
     result:= encodesqlcurrency(ascurrency);
    end;
    ftboolean: begin
     result:= encodesqlboolean(asboolean);
    end;
    ftvariant: begin
     result:= encodesqlvariant(value,false);
    end;
    else begin
     result:= msestring(asstring);
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
    ftString,ftFixedChar,ftmemo,ftblob,ftguid: begin
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
    ftFloat,ftcurrency,ftDate,ftTime,ftDateTime,ftTimeStamp,ftFMTBcd: begin
     rea1:= field.asfloat;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (rea1 <> field.asfloat);
    end;
    {ftCurrency,}ftBCD: begin
     cur1:= field.ascurrency;
     ds1.settempstate(astate); 
     result:= (field.isnull xor isnull) or (cur1 <> field.ascurrency);
    end;
 //    ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
 //    ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, 
    ftWideString: begin
 //    wstr1:= field.aswidestring;
     wstr1:= widestring(field.asstring);
     ds1.settempstate(astate); 
 //    result:= (field.isnull xor isnull) or (wstr1 <> field.aswidestring);
     result:= (field.isnull xor isnull) or 
                              (wstr1 <> widestring(field.asstring));
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
  sender.asstring:= stringtoutf8ansi(avalue);
 end
 else begin
  sender.asstring:= ansistring(avalue); //locale conversion
 end; 
end;

function fieldgetmsestring(const sender: tfield;
                      const aintf: idsfieldcontroller): msestring;
begin
 if (aintf <> nil) and (dso_utf8 in aintf.getcontroller.options) then begin
  result:= utf8tostringansi(sender.asstring);
 end
 else begin
  {$ifdef unix}
  try
   result:= msestring(sender.asstring);
  except
   on e: eiconv do begin
    //no crash by iconverror
   end
   else begin
    raise;
   end;
  end;
  {$else}
  result:= msestring(sender.asstring);
  {$endif}
 end;
end;
{
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
   if not (loo_noforward in options) then begin
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

function locaterecord(const adataset: tdataset; const key: int64;
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
   if not (loo_noforward in options) then begin
    while not eof do begin
     if field.aslargeint = key then begin
      result:= loc_ok;
      exit;
     end;
     next;
    end;
   end;
   bookmark:= bm;
   if not (loo_nobackward in options) then begin
    while true do begin
     if field.aslargeint = key then begin
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
  po1,po2: pmsechar;
 begin
  if ismsestringfield then begin
   mstr2:= tmsestringfield(field).asmsestring;
  end
  else begin
   if autf8 then begin
    mstr2:= utf8tostringansi(field.asstring);
   end
   else begin
    mstr2:= field.asstring;
   end;
  end;
  if caseinsensitive then begin
   mstr2:= mseuppercase(mstr2);      //todo: optimize
  end;
  if loo_posinsensitive in options then begin
   result:= pos(mstr1,mstr2) > 0;
  end
  else begin
   result:= true;
   po1:= pmsechar(mstr1);
   po2:= pmsechar(mstr2);
   for int1:= 0 to int2 - 1 do begin
    if po1[int1] <> po2[int1] then begin
     result:= false;
     break;
    end;
    if po1[int1] = #0 then begin
     break;
    end;
   end;
  end;
 end;
 
 function checkcasesensitive: boolean;
 var
  int1: integer;
 begin
  str2:= field.asstring;
  if loo_posinsensitive in options then begin
   result:= pos(str1,str2) > 0;
  end
  else begin
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
    str1:= stringtoutf8ansi(key);
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
   if not (loo_noforward in options) then begin
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
}
type
 locatefuncty = function (const key; const afield: tfield): boolean;

function locatenull(const key; const afield: tfield): boolean;
begin
 result:= afield.isnull;
end;

function locateinteger(const key; const afield: tfield): boolean;
begin
 result:= tvarrec(key).vinteger = afield.asinteger;
end;

function locateint64(const key; const afield: tfield): boolean;
begin
 result:= tvarrec(key).vint64^ = afield.aslargeint;
end;

function locateboolean(const key; const afield: tfield): boolean;
begin
 result:= tvarrec(key).vboolean = afield.asboolean;
end;

function locateextended(const key; const afield: tfield): boolean;
begin
 result:= tvarrec(key).vextended^ = afield.asfloat;
end;

function locatecurrency(const key; const afield: tfield): boolean;
begin
 result:= tvarrec(key).vcurrency^ = afield.ascurrency;
end;

function locatevariant(const key; const afield: tfield): boolean;
begin
 result:= tvarrec(key).vvariant^ = afield.asvariant;
end;

function locateansistring(const key; const afield: tfield): boolean;
begin
 result:= ansistring(tvarrec(key).vansistring) = afield.asstring;
end;

function locatemsestring(const key; const afield: tfield): boolean;
begin
 result:= msestring(tvarrec(key).vwidestring) = 
                                tmsestringfield(afield).asmsestring;
end;

function locateansistringupper(const key; const afield: tfield): boolean;
begin
 result:= ansistring(tvarrec(key).vansistring) = ansiuppercase(afield.asstring);
end;

function locatemsestringupper(const key; const afield: tfield): boolean;
begin
 result:= msestring(tvarrec(key).vwidestring) = 
                                mseuppercase(tmsestringfield(afield).asmsestring);
end;

function locateansistringpartial(const key; const afield: tfield): boolean;
begin
 result:= ansistring(tvarrec(key).vansistring) = copy(afield.asstring,1,
                   length(ansistring(tvarrec(key).vansistring)));
end;

function locatemsestringpartial(const key; const afield: tfield): boolean;
begin
 result:= msestring(tvarrec(key).vwidestring) = 
                     copy(tmsestringfield(afield).asmsestring,1,
                                  length(msestring(tvarrec(key).vwidestring)));
end;

function locateansistringupperpartial(const key; const afield: tfield): boolean;
begin
 result:= ansistring(tvarrec(key).vansistring) = ansiuppercase(copy(afield.asstring,1,
                   length(ansistring(tvarrec(key).vansistring))));
end;

function locatemsestringupperpartial(const key; const afield: tfield): boolean;
begin
 result:= msestring(tvarrec(key).vwidestring) = 
                 mseuppercase(copy(tmsestringfield(afield).asmsestring,1,
                                  length(msestring(tvarrec(key).vwidestring))));
end;
                              
function locateansistringposins(const key; const afield: tfield): boolean;
begin
 result:= pos(ansistring(tvarrec(key).vansistring),afield.asstring) > 0;
end;

function locatemsestringposins(const key; const afield: tfield): boolean;
begin
 result:= pos(msestring(tvarrec(key).vwidestring),
                                tmsestringfield(afield).asmsestring) > 0;
end;

function locateansistringupperposins(const key; const afield: tfield): boolean;
begin
 result:= pos(ansistring(tvarrec(key).vansistring),
                             ansiuppercase(afield.asstring)) > 0;
end;

function locatemsestringupperposins(const key; const afield: tfield): boolean;
begin
 result:= pos(msestring(tvarrec(key).vwidestring),
                       mseuppercase(tmsestringfield(afield).asmsestring)) > 0;
end;

const
 ansistringcomp: array[0..7] of locatefuncty =
          ({$ifdef FPC}@{$endif}locateansistring,
           {$ifdef FPC}@{$endif}locateansistringupper,
           {$ifdef FPC}@{$endif}locateansistringpartial,
           {$ifdef FPC}@{$endif}locateansistringupperpartial,
           {$ifdef FPC}@{$endif}locateansistringposins,
           {$ifdef FPC}@{$endif}locateansistringupperposins,
           {$ifdef FPC}@{$endif}locateansistringposins,
           {$ifdef FPC}@{$endif}locateansistringupperposins);
 msestringcomp: array[0..7] of locatefuncty =
          ({$ifdef FPC}@{$endif}locatemsestring,
           {$ifdef FPC}@{$endif}locatemsestringupper,
           {$ifdef FPC}@{$endif}locatemsestringpartial,
           {$ifdef FPC}@{$endif}locatemsestringupperpartial,
           {$ifdef FPC}@{$endif}locatemsestringposins,
           {$ifdef FPC}@{$endif}locatemsestringupperposins,
           {$ifdef FPC}@{$endif}locatemsestringposins,
           {$ifdef FPC}@{$endif}locatemsestringupperposins);

function locaterecord(const adataset: tdataset;
                      const fields: array of tfield;
                      const keys: array of const; //nil -> NULL field
                      const isnull: array of boolean;
                      const keyoptions: array of locatekeyoptionsty;
                      const options: locaterecordoptionsty): locateresultty;
var
 comparefuncar: array of locatefuncty;
 
 function check: boolean;
 var 
  int1: integer;
 begin
  result:= true;
  for int1:= 0 to high(comparefuncar) do begin
   result:= comparefuncar[int1](keys[int1],fields[int1]);
   if not result then begin
    break;
   end;
  end;
 end;
 
var
 keymsestrings: msestringarty; 
 keyansistrings: stringarty;
 int1: integer;
 bm: bookmarkty;
 opt1: locatekeyoptionsty;
begin
 int1:= high(keys);
 if high(fields) < int1 then begin
  int1:= high(fields);
 end;
 inc(int1);
 setlength(comparefuncar,int1);
 setlength(keymsestrings,int1);
 setlength(keyansistrings,int1);
 
 for int1:= 0 to high(comparefuncar) do begin
  opt1:= [];
  if int1 <= high(keyoptions) then begin
   opt1:= keyoptions[int1];
  end;
  if (int1 <= high(isnull)) and isnull[int1] then begin
   comparefuncar[int1]:= @locatenull;
  end
  else begin
   with tvarrec(keys[int1]) do begin
    case vtype of
     vtpointer: begin
      comparefuncar[int1]:= @locatenull;
     end;
     vtinteger: begin
      comparefuncar[int1]:= @locateinteger;
     end;
     vtint64: begin
      comparefuncar[int1]:= @locateint64;
     end;
     vtboolean: begin
      comparefuncar[int1]:= @locateboolean;
     end;
     vtextended: begin
      if vextended^ = emptyreal then begin
       comparefuncar[int1]:= @locatenull;
      end
      else begin
       comparefuncar[int1]:= @locateextended;
      end;
     end;
     vtcurrency: begin
      comparefuncar[int1]:= @locatecurrency;
     end;
    {$ifdef mse_hasvtunicodestring}
     vtunicodestring,
    {$endif}
     vtwidestring: begin
      if fields[int1] is tmsestringfield then begin
       comparefuncar[int1]:= msestringcomp[{$ifdef FPC}longword{$else}byte{$endif}(opt1)];
       if lko_caseinsensitive in opt1 then begin
    {$ifdef mse_hasvtunicodestring}
        if vtype = vtunicodestring then begin
         keymsestrings[int1]:=
                  mseuppercase(msestring(tvarrec(keys[int1]).vunicodestring));
         pvarrec(@keys[int1])^.vunicodestring:= pointer(keymsestrings[int1]);
        end
        else begin
    {$endif}
         keymsestrings[int1]:= 
                  mseuppercase(msestring(tvarrec(keys[int1]).vwidestring));
         pvarrec(@keys[int1])^.vwidestring:= pointer(keymsestrings[int1]);
    {$ifdef mse_hasvtunicodestring}
        end;
    {$endif}
       end
      end
      else begin
       if lro_utf8 in options then begin
        if lko_caseinsensitive in opt1 then begin
    {$ifdef mse_hasvtunicodestring}
         if vtype = vtunicodestring then begin
          keyansistrings[int1]:= stringtoutf8ansi(mseuppercase(
                               msestring(tvarrec(keys[int1]).vunicodestring)));
         end
         else begin
    {$endif}
          keyansistrings[int1]:= stringtoutf8ansi(mseuppercase(
                                  msestring(tvarrec(keys[int1]).vwidestring)));
    {$ifdef mse_hasvtunicodestring}
         end;
    {$endif}
        end
        else begin
    {$ifdef mse_hasvtunicodestring}
         if vtype = vtunicodestring then begin
          keyansistrings[int1]:= 
           stringtoutf8ansi(msestring(tvarrec(keys[int1]).vunicodestring));
         end
         else begin
    {$endif}
          keyansistrings[int1]:= 
           stringtoutf8ansi(msestring(tvarrec(keys[int1]).vwidestring));
    {$ifdef mse_hasvtunicodestring}
         end;
    {$endif}
        end;
       end
       else begin
        if lko_caseinsensitive in opt1 then begin
    {$ifdef mse_hasvtunicodestring}
         if vtype = vtunicodestring then begin
          keyansistrings[int1]:= ansistring(mseuppercase(
                            msestring(tvarrec(keys[int1]).vunicodestring)));
         end
         else begin
    {$endif}
          keyansistrings[int1]:= ansistring(
                    mseuppercase(msestring(tvarrec(keys[int1]).vwidestring)));
    {$ifdef mse_hasvtunicodestring}
         end;
    {$endif}
        end
        else begin
         keyansistrings[int1]:=
                       ansistring(msestring(tvarrec(keys[int1]).vwidestring));
        end;
       end;
       pvarrec(@keys[int1])^.vansistring:= pointer(keyansistrings[int1]);
       comparefuncar[int1]:=
             ansistringcomp[{$ifdef FPC}longword{$else}byte{$endif}(opt1)];
      end;
     end;
     vtansistring: begin
      if fields[int1] is tmsestringfield then begin
       comparefuncar[int1]:=
               msestringcomp[{$ifdef FPC}longword{$else}byte{$endif}(opt1)];
       if lko_caseinsensitive in opt1 then begin
        keymsestrings[int1]:=
                  mseuppercase(msestring(
                            ansistring(tvarrec(keys[int1]).vansistring)));
       end
       else begin
        keymsestrings[int1]:= msestring(
                               ansistring(tvarrec(keys[int1]).vansistring));
       end;
       pvarrec(@keys[int1])^.vwidestring:= pointer(keymsestrings[int1]);
      end
      else begin
       if lko_caseinsensitive in opt1 then begin
        keyansistrings[int1]:= 
                      ansiuppercase(ansistring(tvarrec(keys[int1]).vansistring));
        pvarrec(@keys[int1])^.vansistring:= pointer(keyansistrings[int1]);
       end
       else begin
        keyansistrings[int1]:= 
                      ansistring(tvarrec(keys[int1]).vansistring);
//        keyansistrings[int1]:= 
//                      msestring(tvarrec(keys[int1]).vwidestring);
       end;
       comparefuncar[int1]:=
               ansistringcomp[{$ifdef FPC}longword{$else}byte{$endif}(opt1)];
      end;
     end;
     vtvariant: begin
      comparefuncar[int1]:= @locatevariant;
     end;
     else begin
      raise exception.create('Invalid locate data type.');
     end;
    end;
   end;
  end;
 end;
 with adataset do begin
  checkbrowsemode;
  result:= loc_notfound;
  bm:= bookmark;
  disablecontrols;
  try
   if not (lro_nocurrent in options) then begin
    if check then begin
     result:= loc_ok;
     exit;
    end;
   end;
   if not (lro_noforward in options) then begin
    next;
    while not eof do begin
     if check then begin
      result:= loc_ok;
      exit;
     end;
     next;
    end;
    bookmark:= bm;
   end;
   if not (lro_nobackward in options) then begin
    prior;
    while not bof do begin
     if check then begin
      result:= loc_ok;
      exit;
     end;
     prior;
    end;
   end;
   {
   if not (lro_nobackward in options) then begin
    while true do begin
     if check then begin
      result:= loc_ok;
      exit;
     end;
     if bof then begin
      break;
     end;
     prior;
    end;
   end;
   }
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
{
procedure tmsefield.setmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsefield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsefield.Clear;
begin
 setdata(nil);
end;


function tmsefield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

function tmsefield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsefield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsefield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
}
procedure tmsefield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsefield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;
{
function tmsefield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsefield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsefield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;

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

function tmsestringfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

function tmsestringfield.getasunicodestring: unicodestring;
begin
 if assigned(fgetmsestringdata) then begin
  fgetmsestringdata(self,result);
 end
 else begin
  result:= fieldgetmsestring(self,fdsintf);
 end;
end;

procedure tmsestringfield.setasnullmsestring(const avalue: msestring);
begin
 if avalue = '' then begin
  clear;
 end
 else begin
  setasunicodestring(avalue);
 end;
end;

procedure tmsestringfield.setasunicodestring(const avalue: msestring);
begin
 if assigned(fsetmsestringdata) then begin
  fsetmsestringdata(self,avalue);
 end
 else begin
  fieldsetmsestring(avalue,self,fdsintf);
 end;
end;

procedure tmsestringfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsestringfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsestringfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsestringfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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
 result:= getasunicodestring;
 tdataset1(dataset).restorestate(statebefore);
end;

function tmsestringfield.oldmsestring: msestring;
var
 bo1: boolean;
begin
 result:= curmsestring(bo1);
end;

function tmsestringfield.curmsestring(out aisnull: boolean): msestring;
var
 statebefore: tdatasetstate;
begin
 statebefore:= tdataset1(dataset).settempstate(dscurvalue);
 aisnull:= not getdata(nil);
 result:= getasunicodestring;
 tdataset1(dataset).restorestate(statebefore);
end;


function tmsestringfield.curmsestring: msestring;
var
 bo1: boolean;
begin
 result:= curmsestring(bo1);
end;

procedure tmsestringfield.setismsestring(const getter: getmsestringdataty;
           const setter: setmsestringdataty; const acharacterlength: integer;
           const aisftwidestring: boolean);
begin
 fcharacterlength:= acharacterlength;
 size:= acharacterlength;
 fgetmsestringdata:= getter;
 fsetmsestringdata:= setter;
 fisftwidestring:= aisftwidestring;
end;

function tmsestringfield.GetDataSize: integer;
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
  result:= ansistring(getasunicodestring);
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
  result:= inherited getasvariant;
 end;
end;

procedure tmsestringfield.SetAsString(const AValue: string);
begin
 if assigned(fsetmsestringdata) then begin
  fsetmsestringdata(self,msestring(avalue));
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

function tmsestringfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

function tmsestringfield.getdefaultexpression: msestring;
begin
 if inherited defaultexpression <> fdefaultexpressionbefore then begin
  fdefaultexpressionbefore:= inherited defaultexpression;
  fdefaultexpressionstr:= msestring(fdefaultexpressionbefore);
 end;
 result:= fdefaultexpressionstr;
end;

procedure tmsestringfield.setdefaultexpression(const avalue: msestring);
begin
 fdefaultexpressionstr:= avalue;
 try
  fdefaultexpressionbefore:= ansistring(avalue);
  inherited defaultexpression:= fdefaultexpressionbefore;
 except        //catch conversion exception
  fdefaultexpressionbefore:= '';
  inherited defaultexpression:= '';
 end;
end;
{
function tmsestringfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsestringfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsestringfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;

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

function tmsememofield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

function tmsememofield.getasunicodestring: msestring;
begin
 result:= fieldgetmsestring(self,fdsintf);
end;

procedure tmsememofield.setasunicodestring(const avalue: msestring);
begin
 fieldsetmsestring(avalue,self,fdsintf);
end;

function tmsememofield.getaswidestring: widestring;
begin
 result:= fieldgetmsestring(self,fdsintf);
end;

procedure tmsememofield.setaswidestring(const avalue: widestring);
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

function tmsememofield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

function tmsememofield.getasvariant: variant;
begin
 if isnull then begin
  result:= NULL;
 end
 else begin
  result:= getasunicodestring;
 end;
end;

procedure tmsememofield.setvarvalue(const avalue: variant);
begin
 setasunicodestring(avalue);
end;

function tmsememofield.oldmsestring(out aisnull: boolean): msestring;
var
 statebefore: tdatasetstate;
begin
 statebefore:= tdataset1(dataset).settempstate(dsoldvalue);
 aisnull:= getdata(nil);
 result:= getasunicodestring;
 tdataset1(dataset).restorestate(statebefore);
end;

procedure tmsememofield.gettext(var thetext: string; adisplaytext: boolean);
begin
 thetext:= asstring;
end;

{ tmseguidfield }

constructor tmseguidfield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftguid);
end;

function tmseguidfield.getasstring: string;
var
 id1: tguid;
begin
 if not getdata(@id1) then begin
  result:= '';
 end
 else begin
  result:= dbguidtostring(id1);
 end;
end;

procedure tmseguidfield.setasstring(const avalue: string);
begin
 if avalue = '' then begin
  clear;
 end
 else begin
  if avalue[1] = '{' then begin
   asguid:= stringtoguid(avalue);
  end
  else begin
   asguid:= dbstringtoguid(avalue);
  end;
 end;
end;

function tmseguidfield.getdefaultwidth: longint;
begin
 result:= guidbuffersize;
end;

function tmseguidfield.getasguid: tguid;
begin
 if not getdata(@result) then begin
  result:= GUID_NULL;
 end;
end;

procedure tmseguidfield.setasguid(const avalue: tguid);
begin
 setdata(@avalue);
end;

function tmseguidfield.getasvariant: variant;
var
 id1: tguid;
begin
 if not getdata(@id1) then begin
  result:= null;
 end
 else begin
  result:= dbguidtostring(id1);
 end;
end;

procedure tmseguidfield.setvarvalue(const avalue: variant);
begin
 asstring:= avalue;
end;

function tmseguidfield.getdatasize: integer;
begin
 result:= sizeof(tguid);
end;

{ tmsenumericfield }

function tmsenumericfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsenumericfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsenumericfield.setasmsestring(const avalue: msestring);
begin
 asstring:= value;
end;

function tmsenumericfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsenumericfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsenumericfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsenumericfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsenumericfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

procedure tmsenumericfield.Clear;
begin
 setdata(nil);
end;

function tmsenumericfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsenumericfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsenumericfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsenumericfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsenumericfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmselongintfield }

function tmselongintfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmselongintfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmselongintfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmselongintfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmselongintfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmselongintfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmselongintfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmselongintfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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

function tmselongintfield.asoldsql: msestring;
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

function tmselongintfield.sum: integer;
var
 bm: bookmarkty;
 int1: integer;
 intf1: idatasetsum;
begin
 result:= 0;
 if (dataset <> nil) and dataset.active then begin
  if (fieldkind in [fkdata,fkinternalcalc]) and 
          getcorbainterface(dataset,typeinfo(idatasetsum),intf1) then begin
   intf1.sumfield(tfield(self),result);
  end
  else begin
   with dataset do begin
    disablecontrols;
    try
     bm:= bookmark;  
     first;
     while not eof do begin
      if getdata(@int1) then begin
       result:= result + int1;
      end;
      next;
     end;
     bookmark:= bm;
    finally
     enablecontrols;
    end;
   end;
  end;
 end;
end;

procedure tmselongintfield.gettext(var thetext: string; adisplaytext: boolean);
var
 int1: integer;
begin
 thetext:='';
 if getdata(@int1) then begin
  thetext:= getnumdisplaytext(self,int1,adisplaytext,false);
 end;
end;
{
function tmselongintfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
{
function tmselongintfield.getasid: integer;
begin
 if isnull then begin
  result:= -1;
 end
 else begin
  result:= asinteger;
 end;
end;

procedure tmselongintfield.setasid(const avalue: integer);
begin
 if avalue = -1 then begin
  clear;
 end
 else begin
  asinteger:= avalue;
 end;
end;
}
procedure tmselongintfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

function tmselongintfield.asoldid: integer;
var
 stat1: tdatasetstate;
begin
 stat1:= tdataset1(dataset).settempstate(dsoldvalue);
 result:= asid;
 tdataset1(dataset).restorestate(stat1);
end;

procedure tmselongintfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmselongintfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmselargeintfield }

function tmselargeintfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmselargeintfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmselargeintfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmselargeintfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmselargeintfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmselargeintfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmselargeintfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmselargeintfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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

function tmselargeintfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

function tmselargeintfield.asoldid: int64;
var
 stat1: tdatasetstate;
begin
 stat1:= tdataset1(dataset).settempstate(dsoldvalue);
 result:= asid;
 tdataset1(dataset).restorestate(stat1);
end;

procedure tmselargeintfield.gettext(var thetext: string; adisplaytext: boolean);
var
 int1: int64;
begin
 thetext:='';
 if getdata(@int1) then begin
  thetext:= getnumdisplaytext(self,int1,adisplaytext,false);
 end;
end;

function tmselargeintfield.sum: int64;
var
 bm: bookmarkty;
 lint1: int64;
 intf1: idatasetsum;
begin
 result:= 0;
 if (dataset <> nil) and dataset.active then begin
  if (fieldkind in [fkdata,fkinternalcalc]) and 
          getcorbainterface(dataset,typeinfo(idatasetsum),intf1) then begin
   intf1.sumfield(tfield(self),result);
  end
  else begin
   with dataset do begin
    disablecontrols;
    try
     bm:= bookmark;  
     first;
     while not eof do begin
      if getdata(@lint1) then begin
       result:= result + lint1;
      end;
      next;
     end;
     bookmark:= bm;
    finally
     enablecontrols;
    end;
   end;
  end;
 end;
end;
{
function tmselargeintfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
function tmselargeintfield.getasid: int64;
begin
 if isnull then begin
  result:= -1;
 end
 else begin
  result:= aslargeint;
 end;
end;

procedure tmselargeintfield.setasid(const avalue: int64);
begin
 if avalue = -1 then begin
  clear;
 end
 else begin
  aslargeint:= avalue;
 end;
end;

procedure tmselargeintfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmselargeintfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmselargeintfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsesmallintfield }

function tmsesmallintfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsesmallintfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsesmallintfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsesmallintfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsesmallintfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsesmallintfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsesmallintfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsesmallintfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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

procedure tmsesmallintfield.setaslargeint(avalue: largeint);
begin
 if (avalue < low(smallint)) or (avalue > high(smallint)) then begin
  rangeerror(avalue,low(smallint),high(smallint));
 end;
 setaslongint(avalue);
end;

function tmsesmallintfield.getaslargeint: largeint;
begin
 result:= getaslongint;
end;

procedure tmsesmallintfield.Clear;
begin
 setdata(nil);
end;

function tmsesmallintfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsesmallintfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsesmallintfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsesmallintfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;

function tmsesmallintfield.getasid: integer;
begin
 if isnull then begin
  result:= -1;
 end
 else begin
  result:= asinteger;
 end;
end;

procedure tmsesmallintfield.setasid(const avalue: integer);
begin
 if avalue = -1 then begin
  clear;
 end
 else begin
  asinteger:= avalue;
 end;
end;
{
function tmsesmallintfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsewordfield }

function tmsewordfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsewordfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsewordfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsewordfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsewordfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsewordfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsewordfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsewordfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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

procedure tmsewordfield.setaslargeint(avalue: largeint);
begin
 if (avalue < low(word)) or (avalue > high(word)) then begin
  rangeerror(avalue,low(word),high(word));
 end;
 setaslongint(avalue);
end;

function tmsewordfield.getaslargeint: largeint;
begin
 result:= getaslongint;
end;

procedure tmsewordfield.Clear;
begin
 setdata(nil);
end;

function tmsewordfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsewordfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsewordfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsewordfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsewordfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmseautoincfield }

function tmseautoincfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmseautoincfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmseautoincfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmseautoincfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmseautoincfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmseautoincfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmseautoincfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmseautoincfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

procedure tmseautoincfield.Clear;
begin
 setdata(nil);
end;

function tmseautoincfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmseautoincfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmseautoincfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmseautoincfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmseautoincfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsefloatfield }

function tmsefloatfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsefloatfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsefloatfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsefloatfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsefloatfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsefloatfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsefloatfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsefloatfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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

function tmsefloatfield.GetAsLongint: Longint;
begin
 result:= round(inherited getasfloat);
end;

function tmsefloatfield.GetAsLargeint: Largeint;
begin
 result:= round(inherited getasfloat);
end;


procedure tmsefloatfield.setasfloat(avalue: double);
begin
 if avalue = emptyreal then begin
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

function tmsefloatfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

procedure tmsefloatfield.gettext(var thetext: string; adisplaytext: boolean);
var
 do1: double;
begin
 thetext:='';
 if getdata(@do1) then begin
  thetext:= getnumdisplaytext(self,do1,adisplaytext,currency);
 end;
end;

function tmsefloatfield.sum: double;
var
 bm: bookmarkty;
 do1: double;
 intf1: idatasetsum;
begin
 result:= 0;
 if (dataset <> nil) and dataset.active then begin
  if (fieldkind in [fkdata,fkinternalcalc]) and 
          getcorbainterface(dataset,typeinfo(idatasetsum),intf1) then begin
   intf1.sumfield(self,result);
  end
  else begin
   with dataset do begin
    disablecontrols;
    try
     bm:= bookmark;  
     first;
     while not eof do begin
      if getdata(@do1) then begin
       result:= result + do1;
      end;
      next;
     end;
     bookmark:= bm;
    finally
     enablecontrols;
    end;
   end;
  end;
 end;
end;
{
function tmsefloatfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsefloatfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsefloatfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsefloatfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsecurrencyfield }

constructor tmsecurrencyfield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftcurrency);
 currency:= true;
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

function tmsebooleanfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

procedure tmsebooleanfield.setasunicodestring(const avalue: msestring);
var
 mstr1: msestring;
begin
 if avalue= '' then begin
  clear;
 end
 else begin
  mstr1:= mseuppercase(avalue);
  if (mstr1 = '0') or (pos(mstr1,fdisplays[true,false]) = 1) then begin
   asboolean:= false;
  end
  else begin
   if (mstr1 = '1') or (pos(mstr1,fdisplays[true,true]) = 1) then begin
    asboolean:= true;
   end
   else begin
    DatabaseErrorFmt(SNotABoolean,[string(AValue)]);
   end;
  end;
 end;
end;

function tmsebooleanfield.getasunicodestring: unicodestring;
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

procedure tmsebooleanfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsebooleanfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsebooleanfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebooleanfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

procedure tmsebooleanfield.Clear;
begin
 setdata(nil);
end;

procedure tmsebooleanfield.setdisplayvalues(const avalue: msestring);
var
 ar1: msestringarty;
begin
 if fdisplayvalues <> avalue then begin
  ar1:= splitstring(avalue,msechar(';'));
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
 result:= ansistring(getasunicodestring());
end;

procedure tmsebooleanfield.setasstring(const avalue: string);
begin
 setasunicodestring(msestring(avalue));
end;

function tmsebooleanfield.GetDefaultWidth: Longint;
begin
 result:= length(fdisplays[false,false]);
 if result < length(fdisplays[false,true]) then begin
  result:= length(fdisplays[false,true]);
 end;
end;

function tmsebooleanfield.asoldsql: msestring;
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

function tmsebooleanfield.GetDataSize: integer;
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

function tmsebooleanfield.sum: integer;
var
 bm: bookmarkty;
// int1: integer;
 intf1: idatasetsum;
 bo1: wordbool;
begin
 result:= 0;
 if (dataset <> nil) and dataset.active then begin
  if (fieldkind in [fkdata,fkinternalcalc]) and 
          getcorbainterface(dataset,typeinfo(idatasetsum),intf1) then begin
   intf1.sumfield(tfield(self),result);
  end
  else begin
   with dataset do begin
    disablecontrols;
    try
     bm:= bookmark;  
     first;
     while not eof do begin
      if getdata(@bo1) and bo1 then begin
       inc(result);
      end;
      next;
     end;
     bookmark:= bm;
    finally
     enablecontrols;
    end;
   end;
  end;
 end;
end;
{
function tmsebooleanfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsebooleanfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsebooleanfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsebooleanfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsedatetimefield }

function tmsedatetimefield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsedatetimefield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsedatetimefield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsedatetimefield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsedatetimefield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsedatetimefield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsedatetimefield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsedatetimefield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

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
 if avalue = emptydatetime then begin
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

function tmsedatetimefield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

procedure tmsedatetimefield.setoptions(const avalue: datetimefieldoptionsty);
const
 mask: datetimefieldoptionsty = [dtfo_utc,dtfo_local];
begin
 foptions:= datetimefieldoptionsty(setsinglebit(
              {$ifdef FPC}longword{$else}byte{$endif}(avalue),
              {$ifdef FPC}longword{$else}byte{$endif}(foptions),
              {$ifdef FPC}longword{$else}byte{$endif}(mask)));
end;

procedure tmsedatetimefield.setasstring(const avalue: string);
begin
 setasdatetime(strtodatetime(avalue));
end;

function tmsedatetimefield.gettext1(const r: tdatetime;
                                  const adisplaytext: boolean): msestring;
var
 f: string;
begin
 if adisplaytext and (length(displayformat) <> 0) then begin
  f:= displayformat;
 end
 else begin
  case datatype of
   fttime: f:= {$ifdef FPC}defaultformatsettings.{$endif}shorttimeformat;
   ftdate: f:= {$ifdef FPC}defaultformatsettings.{$endif}shortdateformat;
   else f:= 'c'
  end;
 end;
 result:= formatdatetimemse(msestring(f),r);
end;

procedure tmsedatetimefield.gettext(var thetext: string; adisplaytext: boolean);
//var
// r: tdatetime;
// f: string;
begin
 if isnull then begin
  thetext:= '';
 end
 else begin
  thetext:= ansistring(gettext1(getasdatetime,adisplaytext));
 end;
end;
{
function tmsedatetimefield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsedatetimefield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsedatetimefield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsedatetimefield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsedatefield }

constructor tmsedatefield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftdate); 
end;

{ tmsetimefield }

constructor tmsetimefield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(fttime); 
end;

{ tmsebinaryfield }

function tmsebinaryfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebinaryfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

procedure tmsebinaryfield.setasunicodestring(const avalue: msestring);
begin
 asstring:= ansistring(avalue);
end;

function tmsebinaryfield.getasunicodestring: msestring;
begin
 result:= msestring(asstring);
end;

procedure tmsebinaryfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsebinaryfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsebinaryfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebinaryfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

procedure tmsebinaryfield.Clear;
begin
 setdata(nil);
end;

function tmsebinaryfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsebinaryfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsebinaryfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsebinaryfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsebinaryfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsebytesfield }

function tmsebytesfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebytesfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

procedure tmsebytesfield.setasunicodestring(const avalue: unicodestring);
begin
 asstring:= ansistring(avalue);
end;

function tmsebytesfield.getasunicodestring: msestring;
begin
 result:= asunicodestring;
end;

procedure tmsebytesfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsebytesfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsebytesfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebytesfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

procedure tmsebytesfield.Clear;
begin
 setdata(nil);
end;

function tmsebytesfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

function tmsebytesfield.getasvariant: variant;
begin
 if isnull then begin
  result:= null;
 end
 else begin
  result:= asstring;
 end;
end;

procedure tmsebytesfield.setasstring(const avalue: string);
var
 int1,int2: integer;
 str1: string;
begin
 int1:= datasize;
 int2:= length(avalue);
 if int2 < int1 then begin
  str1:= avalue;
  setlength(str1,int1);
  fillchar((pchar(pointer(str1))+int2)^,int1-int2,0);
  setdata(pointer(str1));
 end
 else begin
  setdata(pointer(avalue));
 end;
end;

function tmsebytesfield.getasstring: string;
begin
 setlength(result,datasize);
 if not getdata(pointer(result)) then begin
  result:= '';
 end;
end;
{
function tmsebytesfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsebytesfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsebytesfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsebytesfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsevarbytesfield }

function tmsevarbytesfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsevarbytesfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsevarbytesfield.setasunicodestring(const avalue: unicodestring);
begin
 asstring:= avalue;
end;

function tmsevarbytesfield.getasunicodestring: unicodestring;
begin
 result:= asstring;
end;
}
procedure tmsevarbytesfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsevarbytesfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;
{
function tmsevarbytesfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsevarbytesfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;
}
procedure tmsevarbytesfield.Clear;
begin
 setdata(nil);
end;

function tmsevarbytesfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

function tmsevarbytesfield.getasvariant: variant;
begin
 if isnull then begin
  result:= null;
 end
 else begin
  result:= asstring;
 end;
end;

procedure tmsevarbytesfield.setasstring(const avalue: string);
var
 int1,int2: integer;
 str1: string;
begin
 int1:= datasize;
 int2:= length(avalue);
 if int2 > int1 - sizeof(word) then begin
  int2:= int1 - sizeof(word);
 end;
 setlength(str1,int1);
 pword(pointer(str1))^:= int2;
 move((pchar(pointer(avalue)))^,(pchar(pointer(str1))+sizeof(word))^,int2);
 setdata(pointer(str1));
end;

function tmsevarbytesfield.getasstring: string;
var
 wo1: word;
begin
 setlength(result,datasize);
 if not getdata(pointer(result)) then begin
  result:= '';
 end
 else begin
  wo1:= pword(pointer(result))^;
  move((pchar(pointer(result))+2)^,pchar(pointer(result))^,wo1);
  setlength(result,wo1);
 end
end;
{
function tmsevarbytesfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsevarbytesfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsevarbytesfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsevarbytesfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsebcdfield }

function tmsebcdfield.HasParent: Boolean;
begin
 result:= dataset <> nil;
end;

function tmsebcdfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmsebcdfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmsebcdfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
procedure tmsebcdfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmsebcdfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
end;

function tmsebcdfield.getaswidestring: widestring;
begin
 result:= asmsestring;
end;

procedure tmsebcdfield.setaswidestring(const avalue: widestring);
begin
 asmsestring:= avalue;
end;

procedure tmsebcdfield.Clear;
begin
 setdata(nil);
end;

function tmsebcdfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;

procedure tmsebcdfield.setasfloat(avalue: double);
begin
 if avalue = emptyreal then begin
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

procedure tmsebcdfield.gettext(var thetext: string; adisplaytext: boolean);
var
 cu1: system.currency;
begin
 thetext:='';
 if getdata(@cu1) then begin
  thetext:= getnumdisplaytext(self,cu1,adisplaytext,currency);
 end;
end;

function tmsebcdfield.sum: currency;
var
 curr1: system.currency;
 bm: bookmarkty;
 intf1: idatasetsum;
begin
 result:= 0;
 if (dataset <> nil) and dataset.active then begin
  if (fieldkind in [fkdata,fkinternalcalc]) and 
          getcorbainterface(dataset,typeinfo(idatasetsum),intf1) then begin
   intf1.sumfield(tfield(self),result);
  end
  else begin
   with dataset do begin
    disablecontrols;
    try
     bm:= bookmark;  
     first;
     while not eof do begin
      if getdata(@curr1) then begin
       result:= result + curr1;
      end;
      next;
     end;
     bookmark:= bm;
    finally
     enablecontrols;
    end;
   end;
  end;
 end;
end;
{
function tmsebcdfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsebcdfield.change;
begin
 if not (fis_changing in fstate) then begin
  include(fstate,fis_changing);
  try
   inherited;
  finally
   exclude(fstate,fis_changing);
  end;
 end;
end;

procedure tmsebcdfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsebcdfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}

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

function tmseblobfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;
{
procedure tmseblobfield.setasmsestring(const avalue: msestring);
begin
 asstring:= avalue;
end;

function tmseblobfield.getasmsestring: msestring;
begin
 result:= asstring;
end;
}
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
  inherited loadfromfile(ansistring(tosysfilepath(filename)));
 end;
end;

procedure tmseblobfield.SaveToFile(const FileName: filenamety);
begin
 inherited savetofile(ansistring(tosysfilepath(filename)));
end;

function tmseblobfield.asoldsql: msestring;
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

procedure tmseblobfield.readlookup(reader: treader);
begin
 reader.readboolean;
end;

procedure tmseblobfield.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Lookup',{$ifdef FPC}@{$endif}readlookup,nil,false);
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
{
function tmseblobfield.getaswidestring: widestring;
begin
 result:= getasmsestring;
end;

procedure tmseblobfield.setaswidestring(const avalue: widestring);
begin
 setasmsestring(avalue);
end;
}
{
function tmseblobfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmseblobfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmseblobfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tmsevariantfield }

function tmsevariantfield.getdatasize: integer;
begin
 result:= sizeof(variant);
end;

function tmsevariantfield.getasvariant: variant;
begin
 if assigned(fgetvardata) then begin
  fgetvardata(self,result);
 end
 else begin
  result:= null;
 end;
end;

procedure tmsevariantfield.setvarvalue(const avalue: variant);
begin
 if assigned(fsetvardata) then begin
  fsetvardata(self,avalue);
 end;
end;

function tmsevariantfield.getasboolean: boolean;
begin
 if isnull then begin
  result:= false;
 end
 else begin
  result:= getasvariant;
 end;
end;

function tmsevariantfield.getasdatetime: tdatetime;
begin
 if isnull then begin
  result:= emptydatetime;
 end
 else begin
  result:= getasvariant;
 end;
end;

function tmsevariantfield.getasfloat: double;
begin
 if isnull then begin
  result:= emptyreal;
 end
 else begin
  result:= getasvariant;
 end;
end;

function tmsevariantfield.getasinteger: longint;
begin
 if isnull then begin
  result:= 0;
 end
 else begin
  result:= getasvariant;
 end;
end;
{
function tmsevariantfield.getasstring: string;
begin
 if isnull then begin
  result:= '';
 end
 else begin
  result:= getasvariant;
 end;
end;

function tmsevariantfield.getaswidestring: widestring;
begin
 if isnull then begin
  result:= '';
 end
 else begin
  result:= getasvariant;
 end;
end;
}
function tmsevariantfield.getaslongint: longint;
begin
 if isnull then begin
  result:= 0;
 end
 else begin
  result:= getasvariant;
 end;
end;

procedure tmsevariantfield.setaslongint(avalue: longint);
begin
 setvarvalue(avalue);
end;

function tmsevariantfield.getaslargeint: largeint;
begin
 if isnull then begin
  result:= 0;
 end
 else begin
  result:= getasvariant;
 end;
end;

procedure tmsevariantfield.setaslargeint(avalue: largeint);
begin
 setvarvalue(avalue);
end;

function tmsevariantfield.getascurrency: currency;
begin
 if isnull then begin
  result:= 0;
 end
 else begin
  result:= getasvariant;
 end;
end;

procedure tmsevariantfield.setascurrency(avalue: currency);
begin
 setvarvalue(avalue);
end;

function tmsevariantfield.assql: msestring;
begin
 result:= fieldtosql(self);
end;

function tmsevariantfield.asoldsql: msestring;
begin
 result:= fieldtooldsql(self);
end;
{
function tmsevariantfield.getproviderflags1: providerflags1ty;
begin
 result:= fproviderflags1;
end;
}
procedure tmsevariantfield.SetDataset(AValue: TDataset);
begin
 if fieldname = '' then begin
  fieldname:= fieldnamedummy;
  try
   inherited;
  finally
   fieldname:= '';
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tmsevariantfield.getlookupinfo: plookupfieldinfoty;
begin
 result:= @flookupinfo;
end;
}
{ tdbfieldnamearrayprop }

constructor tdbfieldnamearrayprop.create(const afieldtypes: fieldtypesty;
   const agetdatasource: getdatasourcefuncty);
begin
 ffieldtypes:= afieldtypes;
 fgetdatasource:= agetdatasource;
 inherited create;
end;

function tdbfieldnamearrayprop.getdataset(const aindex: integer): tdataset;
var
 dso1: tdatasource;
begin
 result:= nil;
 dso1:= fgetdatasource();
 if dso1 <> nil then begin
  result:= dso1.dataset;
 end;
end;

procedure tdbfieldnamearrayprop.getfieldtypes(out apropertynames: stringarty;
                  out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 setlength(afieldtypes,1);
 afieldtypes[0]:= ffieldtypes;
end;

{ tmsedatalink }

procedure tmsedatalink.checkcontroller;
var
 intf1: igetdscontroller;
begin
 fdscontroller:= nil;
 if dataset <> nil then begin
  if getcorbainterface(dataset,typeinfo(igetdscontroller),intf1) then begin
   fdscontroller:= intf1.getcontroller;
  end;   
 end;
end;

procedure tmsedatalink.activechanged;
//var
// intf1: igetdscontroller;
begin
 checkcontroller;
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
 result:= nil;
 if datasource <> nil then begin
  result:= datasource.dataset;
 end;
end;

function tmsedatalink.moveby(distance: integer): integer;
 
begin
 result:= 0;
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

procedure tmsedatalink.DataEvent(Event: TDataEvent; Info: Ptrint);
begin
 inherited;
 if event = dedisabledstatechange then begin
  disabledstatechange;
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

function tmsedatalink.getrecnozerobased: integer;
var
 ds1: tdataset;
begin
 result:= -1;
 if fdscontroller <> nil then begin
  result:= fdscontroller.recnozerobased;
 end
 else begin
  ds1:= dataset;
  if (ds1 <> nil) and ds1.active then begin
   result:= ds1.recno -1;
  end;
 end;
end;

procedure tmsedatalink.setrecnozerobased(const avalue: integer);
var
 ds1: tdataset;
begin
 if fdscontroller <> nil then begin
  fdscontroller.recnozerobased:= avalue;
 end
 else begin
  ds1:= dataset;
  if (ds1 <> nil) and ds1.active then begin
   ds1.recno:= avalue + 1;
  end;
 end;
end;

function tmsedatalink.noedit: boolean;
begin
 result:= readonly or (dataset <> nil) and not dataset.canmodify;
end;

function tmsedatalink.canedit: boolean;
begin
 result:= active and not noedit;
end;

function tmsedatalink.caninsert: boolean;
begin
 result:= canedit and ((fdscontroller = nil) or not fdscontroller.noinsert);
end;

function tmsedatalink.canappend: boolean;
begin
 result:= canedit and ((fdscontroller = nil) or not fdscontroller.noappend);
end;

function tmsedatalink.candelete: boolean;
begin
 result:= canedit and ((fdscontroller = nil) or not fdscontroller.nodelete);
end;

function tmsedatalink.canupdate: boolean;
begin
 result:= canedit and ((fdscontroller = nil) or not fdscontroller.noupdate);
end;

procedure tmsedatalink.disabledstatechange;
begin
 //dummy
end;

destructor tmsedatalink.destroy;
var
 int1: integer;
 ds1: tdataset1;
begin
 int1:= 0;
{$warnings off}
 ds1:= tdataset1(dataset);
{$warnings on}
 if ds1 <> nil then begin
  int1:= ds1.buffercount;
 end;
 inherited;
 if (ds1 <> nil) and (ds1.buffercount < int1) then begin
  ds1.dataevent(dedatasetchange,0);
 end;
end;

procedure tmsedatalink.setbuffercount(value: integer);
begin
 inherited;
 if active then begin
  dataset.updatecursorpos();
 end;
end;

{ tfieldsdatalink }

procedure tfieldsdatalink.updatefields;
begin
 //dummy
end;

procedure tfieldsdatalink.activechanged;
begin
 inherited;
 updatefields;
end;

procedure tfieldsdatalink.layoutchanged;
begin
 inherited;
 updatefields;
end;

procedure tfieldsdatalink.fieldchanged;
begin
 recordchanged(nil);
end;

procedure tfieldsdatalink.execute(const sender: iificlient);
begin
end;

procedure tfieldsdatalink.valuechanged(const sender: iificlient);
begin
 //dummy
end;

procedure tfieldsdatalink.statechanged(const sender: iificlient;
               const astate: ifiwidgetstatesty);
begin
 if datasource <> nil then begin
  tdatasource1(datasource).ifistatechanged(self,sender,astate);
 end;
end;

procedure tfieldsdatalink.setvalue(const sender: iificlient; var avalue;
               var accept: boolean; const arow: integer);
begin
 //dummy
end;

procedure tfieldsdatalink.dataentered(const sender: iificlient;
               const arow: integer);
begin
 //dummy
end;

procedure tfieldsdatalink.sendmodalresult(const sender: iificlient;
               const amodalresult: modalresultty);
begin
 //dummy
end;

procedure tfieldsdatalink.updateoptionsedit(var avalue: optionseditty);
begin
 //dummy
end;

{ tfielddatalink }

procedure tfielddatalink.setfieldname(const Value: string);
begin
 if ffieldname <> value then begin
  ffieldname :=  value;
  updatefields;
 end;
end; 

procedure tfielddatalink.setfield(const value: tfield);
const
 mask: fielddatalinkstatesty = [fds_ismsestring,fds_islargeint,
                                   fds_isstring];
var
 state1: fielddatalinkstatesty;
begin
 if ffield <> value then begin
  ffield := value;
  state1:= [];
  if (ffield <> nil) then begin
   if ffield is tmsestringfield then begin
    include(state1,fds_ismsestring);
   end;
   if (ffield.datatype = ftlargeint) then begin
    include(state1,fds_islargeint);
   end;
   if (ffield.datatype in textfields) then begin
    include(state1,fds_isstring);
   end;
  end;
  replacebits1({$ifdef FPC}longword{$else}byte{$endif}(fstate),
               {$ifdef FPC}longword{$else}byte{$endif}(state1),
               {$ifdef FPC}longword{$else}byte{$endif}(mask));
  fieldchanged;
  editingchanged; //???
 end;
end;

procedure tfielddatalink.updatefields;
begin
 if (datasource <> nil) and (datasource.dataset <> nil) and 
                 datasource.dataset.active and (ffieldname <> '') then begin
// if active and (ffieldname <> '') then begin
  setfield(datasource.dataset.fieldbyname(ffieldname));
 end
 else begin
  setfield(nil);
 end;
end;

function tfielddatalink.getasmsestring: msestring;
begin
 if fds_ismsestring in fstate then begin
  result:= tmsestringfield(ffield).asmsestring;
 end
 else begin
  try
   if utf8 then begin
    result:= utf8tostringansi(field.asstring);
   end
   else begin
    result:= msestring(field.asstring);
   end;
  except
   result:= converrorstring;
  end;
 end;
end;

function tfielddatalink.getmsedefaultexpression: msestring;
begin
 if fds_ismsestring in fstate then begin
  result:= tmsestringfield(ffield).defaultexpression;
  if result = #0 then begin
   result:= '';
  end;
 end
 else begin
  result:= msestring(ffield.defaultexpression);
 end;
end;

procedure tfielddatalink.setasmsestring(const avalue: msestring);
begin
 if fds_ismsestring in fstate then begin
  tmsestringfield(field).asmsestring:= avalue;
 end
 else begin
  if utf8 then begin
   ffield.asstring:= stringtoutf8ansi(avalue);
  end
  else begin
   ffield.asstring:= ansistring(avalue);
  end;
 end;
end;

function tfielddatalink.msedisplaytext(const aformat: msestring = '';
                           const aedit: boolean = false): msestring;
 function defaulttext: msestring;
 begin
  if utf8 and (ffield.datatype in textfields) then begin
   result:= utf8tostringansi(ffield.displaytext);
  end
  else begin
   if aedit then begin
    result:= msestring(ffield.text);
   end
   else begin
    result:= msestring(ffield.displaytext);
   end;
  end;
 end;
 
begin
 result:= '';
 if ffield <> nil then begin
  if not ffield.isnull then begin
   if fds_ismsestring in fstate then begin
    result:= aformat + tmsestringfield(ffield).asmsestring;
   end
   else begin
    if aformat <> '' then begin
     case ffield.datatype of
      ftsmallint,ftinteger,ftword,ftlargeint,ftbcd,ftfloat,ftcurrency: begin
       result:= formatfloatmse(field.asfloat,aformat);       
      end;
      ftboolean: begin
       result:= formatfloatmse(ord(field.asboolean),aformat);       
      end;
      ftdate,fttime,ftdatetime: begin
       result:= formatdatetimemse(aformat,field.asdatetime);
      end;
      else begin
       result:= aformat + defaulttext;
      end;
     end;
    end
    else begin
     result:= defaulttext;
    end;
   end;
  end
  else begin
   result:= fnullsymbol;
  end;
 end;
end;

function tfielddatalink.assql: msestring;
begin
 result:= fieldtosql(ffield);
end;

procedure tfielddatalink.checkfield;
begin
 if ffield = nil then begin
  raise exception.create('Field is nil.');
 end;
end;

procedure tfielddatalink.clear;
begin
 checkfield;
 field.clear;
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

function tfielddatalink.getislargeint: boolean;
begin
 result:= fds_islargeint in fstate;
end;

function tfielddatalink.getismsestring: boolean;
begin
 result:= fds_ismsestring in fstate;
end;

function tfielddatalink.getisstringfield: boolean;
begin
 result:= fds_isstring in fstate;
end;

function tfielddatalink.getsortfield: tfield;
begin
 if ffield = nil then begin
  updatefields;
 end;
 result:= ffield;
end;

{ tpersistentfields }

constructor tpersistentfields.create(const adataset: tdataset);
begin
 fdataset:= adataset;
 inherited create(nil);
end;

class function tpersistentfields.getitemclasstype: persistentclassty;
begin
 result:= tfield;
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
 wantedclass: fieldclassty;
 str1: string;
begin
 setlength(fieldtypes,count);
 int1:= 0;
 reader.readlistbegin;
 reader.readlistbegin;
 while not reader.endoflist do begin
  if int1 > high(fieldtypes) then begin
   reader.readident;
                //skip
  end
  else begin
   fieldtypes[int1]:= fieldclasstypety(getenumvalue(typeinfo(fieldclasstypety),
                                reader.readident));    
   inc(int1);
  end;
 end;
 reader.readlistend;
 for int1:= 0 to high(fieldtypes) do begin
  wantedclass:= msefieldtypeclasses[fieldtypes[int1]];
  if (fitems[int1] <> nil) and (fieldtypes[int1] <> ft_unknown) and
   not (tfield(fitems[int1]) is wantedclass) then begin
   if (fitems[high(fitems)] = nil) then begin
    moveitem(pointerarty(fitems),high(fitems),int1); //probably inserted field
   end;
   {
   else begin
    for int2:= int1+1 to high(fitems) do begin
     if tfield(fitems[int2]) is wantedclass then begin
      moveitem(pointerarty(fitems),int2,int1); //try to correct invalid order
      break;
     end;
    end;
   end;
   }
  end;
  str1:= '';
  if (fitems[int1] <> nil) and (fieldtypes[int1] <> ft_unknown) and
            not (tfield(fitems[int1]) is wantedclass) then begin
   str1:= tfield(fitems[int1]).fieldname;
   freeandnil(tfield(fitems[int1]));     //there is something wrong
  end;
  if fitems[int1] = nil then begin
   fitems[int1]:= wantedclass.create(nil);
   tfield(fitems[int1]).fieldname:= str1;
  end;
 end;
 for int1:= 0 to high(fitems) do begin
  with tfield(fitems[int1]) do begin
   dataset:= fdataset;
  end;
 end;
 readcollection(reader);
 reader.readlistend;
end;

procedure tpersistentfields.writefields(writer: twriter);
var
 int1: integer;
 class1: fieldclassty; 
begin
 writer.writelistbegin;
 writer.writelistbegin;
 finvaliditems:= nil;
 setlength(finvaliditems,count);
 for int1:= 0 to high(fitems) do begin
  class1:= fieldclassty(fitems[int1].classtype);
  if (writer.ancestor <> nil) and
    not ((writer is twritermse) and twritermse(writer).masterancestor) then begin
   with tpersistentfields(writer.ancestor) do begin
    if (int1 < count) then begin
     if (fitems[int1].classtype <> class1) then begin
      class1:= fieldclassty(fitems[int1].classtype);
                 //do not change inherited field type
      self.finvaliditems[int1]:= true;
     end
     else begin
      class1:= nil;
     end;
    end;
   end;
  end;
  writer.writeident(getenumname(typeinfo(fieldclasstypety),
            ord(fieldclasstoclasstyp(class1))));
 end;
 writer.writelistend;
 writecollection(writer);
 finvaliditems:= nil;
 writer.writelistend;
end;

procedure tpersistentfields.defineproperties(filer: tfiler);
//var
// int1: integer; 
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

function tpersistentfields.ispropertystored(index: integer): boolean;
begin
 result:= inherited ispropertystored(index) and not finvaliditems[index];
end;


{ tdscontroller }

constructor tdscontroller.create(const aowner: tdataset;
                                   const aintf: idscontroller;
                                   const arecnooffset: integer = -1;
                                   const acancelresync: boolean = true);
begin
 ffields:= tpersistentfields.create(aowner); 
// fintf:= aintf;
 frecnooffset:= arecnooffset;
 fcancelresync:= acancelresync;
 foptions:= defaultdscontrolleroptions;
 inherited create(aowner,aintf);
 if aowner is tmsebufdataset then begin
  with tmsebufdataset1(aowner) do begin
   foldopts:= getdefaultoptions * oldbdsoptions;
  end;
 end;
end;

destructor tdscontroller.destroy;
var
 int1: integer;
 field1: tfield;
begin
// unregisteronidle;
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
 freeandnil(ftimer);
 inherited;
end;

procedure tdscontroller.fielddestroyed(const sender: ifieldcomponent);
begin
 removeitem(pointerarty(flinkedfields),pointer(sender));
end;

procedure tdscontroller.setowneractive(const avalue: boolean); 
begin
 tdataset(fowner).active:= avalue;
end;

function tdscontroller.locate(const afields: array of tfield;
                      const akeys: array of const;
                      const aisnull: array of boolean;
                      const akeyoptions: array of locatekeyoptionsty;
                      const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(tdataset(fowner),afields,akeys,aisnull,akeyoptions,aoptions);
end;
{
function tdscontroller.locate(const key: integer; const field: tfield;
                              const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(tdataset(fowner),key,field,options);
end;

function tdscontroller.locate(const key: int64; const field: tfield;
                              const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(tdataset(fowner),key,field,options);
end;

function tdscontroller.locate(const key: msestring; const field: tfield;
                         const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(tdataset(fowner),dso_utf8 in foptions,key,field,options);
end;
}
procedure tdscontroller.appendrecord1(const values: array of const;
                          const aisnull: array of boolean;
                                            const afields: array of tfield);
var
 int1,int2: integer;
 field1: tfield;
begin
 with tdataset(fowner) do begin
  append;
  int2:= high(values);
  if int2 > high(afields) then begin
   int2:= high(afields);
  end;
  for int1:= 0 to int2 do begin
   field1:= afields[int1];
   if (int1 <= high(aisnull)) and aisnull[int1] then begin
    field1.clear();
   end
   else begin
    with values[int1] do begin
     case vtype of
      vtInteger:    field1.asinteger:= VInteger;
      vtInt64:      field1.aslargeint:= VInt64^;
      vtBoolean:    field1.asboolean:= VBoolean;
      vtChar:       field1.asstring:= VChar;
      vtWideChar:   field1.asstring:= ansistring(VWideChar);
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
     {$ifdef mse_hasvtunicodestring}
      vtunicodestring: begin
       if (field1 is tmsestringfield) then begin
        tmsestringfield(field1).asmsestring:= msestring(vunicodestring);
       end
       else begin 
        if (field1 is tmsememofield) then begin
         tmsememofield(field1).asmsestring:= msestring(vunicodestring);
        end
        else begin
         field1.asstring:= ansistring(widestring(vunicodestring));
        end;
       end;
      end;
     {$endif}
      vtWideString: begin
       if (field1 is tmsestringfield) then begin
        tmsestringfield(field1).asmsestring:= msestring(vwidestring);
       end
       else begin 
        if (field1 is tmsememofield) then begin
         tmsememofield(field1).asmsestring:= msestring(vwidestring);
        end
        else begin
         field1.asstring:= ansistring(widestring(vwidestring));
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
end;

procedure tdscontroller.appendrecord(const values: array of const;
                                            const afields: array of tfield);
begin
 appendrecord1(values,[],afields);
end;

procedure tdscontroller.appendrecord1(const values: array of const; 
                                            const aisnull: array of boolean);
var
 ar1: fieldarty;
 int1: integer;
begin
 with tdataset(fowner) do begin
  setlength(ar1,fields.count);
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= fields[int1];
  end;
 end;
 appendrecord1(values,aisnull,ar1);
end;

procedure tdscontroller.appendrecord(const values: array of const);
begin
 appendrecord1(values,[]);
end;

procedure tdscontroller.appendrecord(const values: variantarty);
var
 int1: integer;
begin
 with tdataset(fowner) do begin
  append;
  for int1:= 0 to high(values) do begin
   fields[int1].value:= values[int1];
  end;
 end;
end;

procedure tdscontroller.appenddata(const adata: variantararty; const afields: array of tfield);
                                                     //[] -> all
var
 int1,int2{,int3}: integer;
 ar1: fieldarty;
begin
 ar1:= getdsfields(tdataset(fowner),afields);
 with tdataset(fowner) do begin
  checkbrowsemode;
  for int1:= 0 to high(adata) do begin
   if state = dsinsert then begin
    post;
   end;
   append;
   for int2:= 0 to high(ar1) do begin
    if int2 > high(adata[int1]) then begin
     break;
    end;
    ar1[int2].value:= adata[int1][int2];
   end;
  end;
  if state = dsinsert then begin
   post;
  end
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

function tdscontroller.getrecnozerobased: integer;
begin
 with tdataset1(fowner) do begin
  if bof and eof then begin
   result:= -1;
  end
  else begin
   if not frecnovalid or tdataset(fowner).filtered or 
             (fbuffercountbefore <> tdataset1(fowner).buffercount) then begin
    fbuffercountbefore:= tdataset1(fowner).buffercount;
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
    frecnovalid:= not tdataset(fowner).filtered;
   end
   else begin
    inc(frecno,fscrollsum + activerecord - factiverecordbefore);
   end;
   factiverecordbefore:= activerecord;
   fscrollsum:= 0;
   result:= frecno;
  end;
  if (state = dsinsert) and (getbookmarkflag(activebuffer) = bfeof) then begin
   inc(result); //append mode
  end;
 end;
end;

procedure tdscontroller.setrecnozerobased(const avalue: integer);
begin
 if avalue <> getrecnozerobased then begin
  tdataset1(fowner).recno:= avalue - recnooffset;
  frecno:= avalue;
  factiverecordbefore:= tdataset1(fowner).activerecord;
  fscrollsum:= 0;
  frecnovalid:= not tdataset1(fowner).filtered;
 end;
{
 if not frecnovalid or (avalue <> frecno) then begin
  tdataset1(fowner).recno:= avalue - recnooffset;
  frecno:= avalue;
  factiverecordbefore:= tdataset1(fowner).activerecord;
  fscrollsum:= 0;
  frecnovalid:= true;
 end;
 }
end;

function tdscontroller.getrecno: integer;
begin
 result:= recnozerobased - frecnooffset;
end;

procedure tdscontroller.setrecno(const avalue: integer);
begin
 recnozerobased:= avalue + frecnooffset;
end;

function tdscontroller.findrecno(const arecno: integer;
               const options: recnosearchoptionsty): integer;
begin
 result:= findrecnozerobased(arecno+frecnooffset,options)-frecnooffset;
end;

function tdscontroller.findrecnozerobased(const arecno: integer;
               const options: recnosearchoptionsty = []): integer;
begin
 try
  recnozerobased:= arecno;
 except
  with tdataset(fowner) do begin
   disablecontrols;
   try
    resync([]);
    if (recnozerobased > arecno) and (rso_backward in options) then begin
     prior;
    end;
   finally
    enablecontrols;
   end;
  end;
 end;
 result:= recnozerobased;
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
       (finditem(pointerarty(flinkedfields),pointer(intf1)) < 0) then begin
    additem(pointerarty(flinkedfields),pointer(intf1));
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
// field1: tfield;
 state1,state2: tdatasetstate;
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
  decheckbrowsemode: begin
   if (dso_canceloncheckbrowsemode in foptions) and 
                    ([dscs_posting,dscs_canceling]*fstate = []) then begin
    cancel;
   end;
  end;
 end;
 if not fmovebylock or (event <> dedatasetchange) then begin
  with tdataset(fowner) do begin
   if (event = deupdaterecord) and not modified and (state = dsinsert) then begin
    idscontroller(fintf).inheriteddataevent(event,info); //for second notnull check
   end;
  end;
  idscontroller(fintf).inheriteddataevent(event,info);
 end;
 state1:= tdataset(fowner).state;
 if (state1 <> fstatebefore) then begin
  state2:= fstatebefore;
  fstatebefore:= state1;
  if checkcanevent(fowner,tmethod(fonstatechanged)) then begin
   fonstatechanged(tdataset(fowner),state2);
  end;
 end;
end;

procedure tdscontroller.cancel;
var
 bo1: boolean;
begin
 try
  include(fstate,dscs_canceling);
  with tdataset1(fowner) do begin
   bo1:= state = dsinsert;
   if bo1 then begin
    dobeforescroll;
   end;
   if fcancelresync and (state = dsinsert) and not modified then begin
    idscontroller(fintf).inheritedcancel;
    try
     if finsertbm <> '' then begin
      bookmark:= finsertbm;
     end;  
    except
    end;
    finsertbm:= '';
   end
   else begin
    idscontroller(fintf).inheritedcancel;
   end;
   if bo1 then begin
    doafterscroll;
   end;
  end;
 finally
  exclude(fstate,dscs_canceling);
 end;
end;

function tdscontroller.canceling: boolean;
begin
 result:= dscs_canceling in fstate;
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
    result:= idscontroller(fintf).inheritedmoveby(distance);
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
 idscontroller(fintf).inheritedinternalinsert;
end;

procedure tdscontroller.internaldelete;
begin
 idscontroller(fintf).inheritedinternaldelete;
 modified;
 tdataset1(fowner).dataevent(tdataevent(de_afterdelete),0);
end;

procedure tdscontroller.internalopen;
var
 int1,int2: integer;
 bo1: boolean;
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
{$warnings off}
   with tfielddef1(fielddefs[int1]) do begin
{$warnings on}
    if ffieldno = 0 then begin
     ffieldno:= int1 + 1;
    end;
//    if fdatatype in blobfields then begin
//     fsize:= blobdatasize;
//    end;
   end;
  end;
  updatelinkedfields;
  bo1:= dso_waitcursor in foptions;
  if bo1 then begin
   application.beginwait;
  end;
  try
//   if dso_local in foptions then begin
//    idscontroller(fintf).openlocal;
//   end
//   else begin
    idscontroller(fintf).inheritedinternalopen;
//   end;
  finally
   if bo1 then begin
    application.endwait;
   end;
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
{
 if fdelayedapplycount > 0 then begin
  registeronidle;
 end;
}
end;
{
procedure tdscontroller.doonidle(var again: boolean);
begin
 idscontroller(fintf).doidleapplyupdates;
end;
}
(*
procedure tdscontroller.registeronidle;
begin
 if not(dscs_onidleregistered in fstate) then begin
  application.registeronidle({$ifdef FPC}@{$endif}doonidle);
  include(fstate,dscs_onidleregistered);
 end;
end;

procedure tdscontroller.unregisteronidle;
begin
 if dscs_onidleregistered in fstate then begin
  application.unregisteronidle({$ifdef FPC}@{$endif}doonidle);
  exclude(fstate,dscs_onidleregistered);
 end;
end;
*)
procedure tdscontroller.internalclose;
var
 int1: integer;
 field1: tfield;
begin
// unregisteronidle;
 idscontroller(fintf).inheritedinternalclose;
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

function tdscontroller.assql(const avalue: boolean): msestring;
begin
 if idscontroller(fintf).getnumboolean then begin
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

function tdscontroller.assql(const avalue: msestring): msestring;
begin
 if avalue = '' then begin
  result:= 'NULL';
 end
 else begin
//  if dso_utf8 in foptions then begin
//   result:= encodesqlstring(stringtoutf8ansi(avalue));
//  end
//  else begin
  result:= encodesqlstring(avalue);
//  end;
 end;
end;

function tdscontroller.assql(const avalue: integer): msestring;
begin
 result:= inttostrmse(avalue);
end;

function tdscontroller.assql(const avalue: int64): msestring;
begin
 result:= inttostrmse(avalue);
end;

function tdscontroller.assql(const avalue: realty): msestring;
begin
 if avalue = emptyreal then begin
  result:= 'NULL';
 end
 else begin
  result:= realtostrmse(avalue);
 end;
end;

function tdscontroller.assqlcurrency(const avalue: realty): msestring;
begin
 if avalue = emptyreal then begin
  result:= 'NULL';
 end
 else begin
 {$ifdef FPC}
  result:= assql(currency(avalue));
 {$else}
  if idscontroller(fintf).getint64currency then begin
   result:= inttostr(int64(ar8ty(currency(avalue))));
  end
  else begin
   result:= encodesqlcurrency(avalue);
  end;
 {$endif}
 end;
end;

function tdscontroller.assql(const avalue: currency): msestring;
begin
 if idscontroller(fintf).getint64currency then begin
 {$ifdef FPC}
  result:= inttostrmse(int64(avalue));
 {$else}
  result:= inttostrmse(int64(ar8ty(avalue)));
 {$endif}
 end
 else begin
  result:= encodesqlcurrency(avalue);
 end;
end;

function tdscontroller.assql(const avalue: tdatetime): msestring;
begin
 if avalue = emptydatetime then begin
  result:= 'NULL';
 end
 else begin
  if idscontroller(fintf).getfloatdate then begin
   result:= encodesqlfloat(avalue);
  end
  else begin
   result:= encodesqldatetime(avalue);
  end;
 end;
end;

function tdscontroller.assqldate(const avalue: tdatetime): msestring;
begin
 if avalue = emptydatetime then begin
  result:= 'NULL';
 end
 else begin
  if idscontroller(fintf).getfloatdate then begin
   result:= inttostrmse(trunc(avalue));
  end
  else begin
   result:= encodesqldate(avalue);
  end;
 end;
end;

function tdscontroller.assqltime(const avalue: tdatetime): msestring;
begin
 if avalue = emptydatetime then begin
  result:= 'NULL';
 end
 else begin
  if idscontroller(fintf).getfloatdate then begin
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

function tdscontroller.execoperation(const akind: opkindty;
                          const aafterop: afterdbopeventty): boolean;
var
 bo1,bo2{,bo3}: boolean;
 int1: integer;
 savepointoptions: savepointoptionsty;
begin
// bo3:= dscs_posting1 in fstate;
 if not (dscs_posting1 in fstate) then begin
  include(fstate,dscs_posting1);
  try
   case akind of
    opk_post: begin
     if checkcanevent(tdataset(fowner),tmethod(self.fonbeforepost)) then begin
      fonbeforepost(tdataset(fowner));
     end;
    end;
    opk_delete: begin
     if checkcanevent(tdataset(fowner),tmethod(self.fonbeforedelete)) then begin
      fonbeforedelete(tdataset(fowner));
     end;
    end;
   end;
   try
    savepointoptions:= idscontroller(fintf).getsavepointoptions;
    case akind of
     opk_post: begin
      bo1:= spo_postsavepoint in savepointoptions;
     end;
     opk_delete: begin
      bo1:= spo_deletesavepoint in savepointoptions;
     end;
     else begin
      bo1:= false;
     end;
    end;
    try
     if bo1 then begin
      int1:= savepointbegin;
     end;
     result:= true;
     include(fstate,dscs_posting);
     try    
      try
       case akind of
        opk_post: begin
         idscontroller(fintf).inheritedpost();
        end;
        opk_delete: begin
         idscontroller(fintf).inheriteddelete();
        end;
        opk_insert: begin
         idscontroller(fintf).inheritedinsert();
        end;
       end;
      except
       on epostcancel do begin
        if bo1 then begin
         bo1:= false;
         savepointrollback(int1);
        end;     
        result:= false;
        tdataset(fowner).cancel;
       end
       else begin
        if bo1 then begin
         bo1:= false;
         savepointrollback(int1);
        end;     
        raise;
       end;
      end;      
     finally
      exclude(fstate,dscs_posting);
     end;
     bo2:= result;
     try
      if result and assigned(aafterop) then begin
       aafterop(tdataset(fowner),result);
      end;
      if result then begin
       if akind = opk_post then begin
        tdataset1(fowner).dataevent(tdataevent(de_afterpost),0);
       end;
      end;
     finally
      if bo2 then begin
       self.modified;
      end;
     end;
     if bo1 then begin
      bo1:= false;
      if result then begin
       savepointrelease;
      end
      else begin
       savepointrollback(int1);
      end;
     end;     
    except
     if bo1 then begin
      savepointrollback(int1);
     end;     
     raise;
    end;
   finally
    case akind of
     opk_post: begin
      if checkcanevent(tdataset(fowner),tmethod(self.fonafterpost)) then begin
       fonafterpost(tdataset(fowner),result);
      end;
     end;
     opk_delete: begin
      if checkcanevent(tdataset(fowner),tmethod(self.fonafterdelete)) then begin
       fonafterdelete(tdataset(fowner),result);
      end;
     end;
    end;    
   end;
  finally
//   if not bo3 then begin
   exclude(fstate,dscs_posting1);
//   end;
  end;
 end;
end;

procedure tdscontroller.readdelayedapplycount(reader: treader);
var
 i1: int32;
begin
 i1:= reader.readinteger();
 if fowner is tmsebufdataset then begin
  tmsebufdataset(fowner).delayedapplycount:= i1;
 end;
end;

procedure tdscontroller.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('delayedapplycount',@readdelayedapplycount,nil,false);
end;

function tdscontroller.post(const aafterpost: afterdbopeventty = nil): boolean;
begin
 with tdataset(fowner) do begin
  if state in dseditmodes then begin
   result:= execoperation(opk_post,aafterpost);
  end
  else begin
   result:= false;
  end;
 end;
end;
{
procedure tdscontroller.insert(const aafterinsert: afterdbopeventty = nil);
begin
 execoperation(opk_insert,aafterinsert);
end;
}
function tdscontroller.delete(
                     const aafterdelete: afterdbopeventty = nil): boolean;
begin
 if tdataset(fowner).state = dsinsert then begin
  cancel();
  result:= true;
 end
 else begin
  result:= execoperation(opk_delete,aafterdelete);
 end;
end;

procedure tdscontroller.postcancel;
begin
 raise epostcancel.create('Post canceled');
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

function tdscontroller.posting1: boolean;
begin
 result:= dscs_posting1 in fstate;
end;

procedure tdscontroller.modified;
begin
 tdataset1(fowner).dataevent(tdataevent(de_modified),0);
end;

procedure tdscontroller.setoptions(const avalue: datasetoptionsty);
{$ifndef FPC}
const
 mask1: datasetoptionsty = [dso_autocommitret,dso_autocommit];
 mask2: datasetoptionsty = [dso_editonapplyerror,dso_cancelupdatesonerror,
                      dso_cancelupdateonerror,dso_cancelupdateondeleteerror];
{$endif}
var
 opt,options1{,optionsbefore}: datasetoptionsty;
 bdopt: bufdatasetoptionsty;
begin
 if (csreading in fowner.componentstate) and 
                                      (fowner is tmsebufdataset) then begin
  with tmsebufdataset1(fowner) do begin
   if card32(foldopts) <> card32($ffffffff) then begin //old streaming version
    bdopt:= [];
    if dso_postsavepoint in avalue then include(bdopt,bdo_postsavepoint);
    if dso_postsavepoint in avalue then include(bdopt,bdo_postsavepoint);
    if dso_deletesavepoint in avalue then include(bdopt,bdo_deletesavepoint);
    if dso_cancelupdateonerror in avalue then include(bdopt,bdo_cancelupdateonerror);
    if dso_cancelupdatesonerror in avalue then include(bdopt,bdo_cancelupdatesonerror);
    if dso_cancelupdateondeleteerror in avalue then include(bdopt,bdo_cancelupdateondeleteerror);
    if dso_editonapplyerror in avalue then include(bdopt,bdo_editonapplyerror);
    if dso_restoreupdateonsavepointrollback in avalue then include(bdopt,bdo_restoreupdateonsavepointrollback);
    if dso_noapply in avalue then include(bdopt,bdo_noapply);
    if dso_autoapply in avalue then include(bdopt,bdo_autoapply);
    if dso_autocommitret in avalue then include(bdopt,bdo_autocommitret);
    if dso_autocommit in avalue then include(bdopt,bdo_autocommit);
    if dso_refreshafterapply in avalue then include(bdopt,bdo_refreshafterapply);
    if dso_recnoapplyrefresh in avalue then include(bdopt,bdo_recnoapplyrefresh);
    if dso_refreshtransaction in avalue then include(bdopt,bdo_refreshtransaction);
    if dso_notransactionrefresh in avalue then include(bdopt,bdo_notransactionrefresh);
    if dso_recnotransactionrefresh in avalue then include(bdopt,bdo_recnotransactionrefresh);
    if dso_noprepare in avalue then include(bdopt,bdo_noprepare);
    if dso_cacheblobs in avalue then include(bdopt,bdo_cacheblobs);
    if dso_offline in avalue then include(bdopt,bdo_offline);
    if dso_local in avalue then include(bdopt,bdo_local);
    foldopts:= bdopt;
   end;
  end;
 end;
// optionsbefore:= foptions;
 opt:= avalue - [dso_refreshwaitcursor]-deprecatedbdsoptions;
 if dso_refreshwaitcursor in avalue then begin
  include(opt,dso_waitcursor);
 end;
 options1:= datasetoptionsty(longword(foptions) xor longword(opt));
(*
{$ifdef FPC}
 foptions:= datasetoptionsty(setsinglebit(longword(opt),longword(foptions),
                 [longword([dso_autocommitret,dso_autocommit]),
                  longword([dso_editonapplyerror,dso_cancelupdatesonerror,
                     dso_cancelupdateonerror,dso_cancelupdateondeleteerror])]));
{$else}
 foptions:= datasetoptionsty(setsinglebitar32(longword(opt),longword(foptions),
                                          [longword(mask1),longword(mask2)]));
{$endif}
*)
 if [dso_noedit,dso_noinsert,dso_noappend,dso_noupdate,dso_nodelete] *
                                                    options1 <> [] then begin
  if ([dso_noedit,dso_noupdate] * opt <> []) and 
                                      tdataset(fowner).active then begin
   tdataset(fowner).checkbrowsemode;
  end;
  tdataset1(fowner).dataevent(dedisabledstatechange,0);
 end;
{
 if optionsbefore <> foptions then begin
  idscontroller(fintf).dscontrolleroptionschanged(foptions);
 end;
}
end;

function tdscontroller.isutf8: boolean;
begin
 result:= dso_utf8 in foptions;
end;

function tdscontroller.filtereditkind: filtereditkindty;
begin
 result:= idscontroller(fintf).getfiltereditkind;
end;

procedure tdscontroller.beginupdate; //calls diablecontrols, stores bookmark
begin
 with tdataset(fowner) do begin
  if fupdatecount = 0 then begin
   fbmbackup:= bookmark;
  end;
  inc(fupdatecount);
  disablecontrols;
 end;
end;

procedure tdscontroller.endupdate;   //restores bookmark, calls enablecontrols
begin
 with tdataset(fowner) do begin
  dec(fupdatecount);
  if fupdatecount = 0 then begin
   bookmark:= fbmbackup;
  end;
  enablecontrols;
 end;
end;

procedure tdscontroller.beginfilteredit(const akind: filtereditkindty);
begin
 idscontroller(fintf).beginfilteredit(akind);
end;

procedure tdscontroller.clearfilter;
begin
 idscontroller(fintf).clearfilter;
end;

procedure tdscontroller.endfilteredit;
begin
 idscontroller(fintf).endfilteredit;
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
{
procedure tdscontroller.setdelayedapplycount(const avalue: integer);
begin
 if fdelayedapplycount <> avalue then begin
  if tdataset(fowner).active and not (csloading in fowner.componentstate) then begin
   if fdelayedapplycount > 0 then begin
    fdelayedapplycount:= 1;
    idscontroller(fintf).doidleapplyupdates; //apply pending updates.
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
}
function tdscontroller.getnoedit: boolean;
begin
 result:= dso_noedit in foptions;
end;

procedure tdscontroller.setnoedit(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [dso_noedit];
 end
 else begin
  options:= options - [dso_noedit];
 end;  
end;

function tdscontroller.getnoinsert: boolean;
begin
 result:= dso_noinsert in foptions;
end;

procedure tdscontroller.setnoinsert(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [dso_noinsert];
 end
 else begin
  options:= options - [dso_noinsert];
 end;  
end;

function tdscontroller.getnoappend: boolean;
begin
 result:= dso_noappend in foptions;
end;

procedure tdscontroller.setnoappend(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [dso_noappend];
 end
 else begin
  options:= options - [dso_noappend];
 end;  
end;

function tdscontroller.getnoupdate: boolean;
begin
 result:= dso_noupdate in foptions;
end;

procedure tdscontroller.setnoupdate(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [dso_noupdate];
 end
 else begin
  options:= options - [dso_noupdate];
 end;  
end;

function tdscontroller.getnodelete: boolean;
begin
 result:= dso_nodelete in foptions;
end;

procedure tdscontroller.setnodelete(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [dso_nodelete];
 end
 else begin
  options:= options - [dso_nodelete];
 end;  
end;

function tdscontroller.getcanmodify: boolean;
begin
 result:= not (dso_noedit in foptions);
end;

procedure tdscontroller.dorefresh(const sender: tobject);
var
 bo1,bo2: boolean;
begin
 if (sender = nil) or //not delayed
            (tdataset(fowner).state = dsbrowse) then begin
  bo2:= dso_waitcursor in foptions;
  if bo2 then begin
   application.beginwait;
  end;
  try
   if not tdataset(fowner).active then begin
    tdataset(fowner).open;
   end
   else begin
    if dscs_restorerecno in fstate then begin
     exclude(fstate,dscs_restorerecno);
     bo1:= idscontroller(fintf).restorerecno;
     idscontroller(fintf).restorerecno:= true;
     try
      tdataset(fowner).refresh;
     finally
      if not bo1 then begin
       idscontroller(fintf).restorerecno:= false;
      end;
     end;
    end
    else begin
     tdataset(fowner).refresh;
    end;
   end;
  finally
   if bo2 then begin
    application.endwait;
   end; 
  end;
 end;
end;

procedure tdscontroller.refresh(const restorerecno: boolean;
                                           const delayus: integer = -1);
begin
 if restorerecno then begin
  include(fstate,dscs_restorerecno);
 end;
 if delayus < 0 then begin
  freeandnil(ftimer);
  dorefresh(nil);
 end
 else begin
  if ftimer = nil then begin
   ftimer:= tsimpletimer.create(delayus,{$ifdef FPC}@{$endif}dorefresh,
                                                           true,[to_single]);
  end
  else begin
   ftimer.interval:= delayus; //single shot
   ftimer.enabled:= true;
  end;
 end;
end;

procedure tdscontroller.checkrefresh; //makes pending delayed refresh
begin
 if ftimer <> nil then begin
  ftimer.firependingandstop; //cancel wait
 end;
end;

function tdscontroller.islastrecord: boolean;
begin
 with tdataset1(fowner) do begin
  result:= eof;
  if not result then begin
   if filtered then begin
    settempstate(state);
    try
     next;
     result:= eof;
     if not result then begin
      prior;
     end;
    finally
     restorestate(state);
    end;
   end
   else begin
    result:= idscontroller(fintf).islastrecord;
   end;
  end;
 end;
end;

procedure tdscontroller.nosavepoint;
begin
 raise exception.create('Savepoints not supported.');
end;

function tdscontroller.savepointbegin: integer;
begin
 result:= -1;
 nosavepoint;
end;

procedure tdscontroller.savepointrollback(const aindex: integer);
begin
 nosavepoint;
end;

procedure tdscontroller.savepointrelease;
begin
 nosavepoint;
end;

function tdscontroller.updatesortfield(const alink: tfielddatalink;
               const adescend: boolean): boolean;
var
 field1: tfield;
begin
 field1:= nil;
 if alink <> nil then begin
  field1:= alink.sortfield;
 end;
 result:= idscontroller(fintf).updatesortfield(field1,adescend);
end;

function tdscontroller.getasmsestring(const afieldname: string): msestring;
var
 field1: tfield;
begin
 field1:= tdataset(fowner).fieldbyname(afieldname);
 if field1 is tmsestringfield then begin
  result:= tmsestringfield(field1).asmsestring;
 end
 else begin
  if field1 is tmsememofield then begin
   result:= tmsememofield(field1).asmsestring;
  end
  else begin
   if isutf8 then begin
    result:= utf8tostringansi(field1.asstring);
   end
   else begin
    result:= msestring(field1.asstring);
   end;
  end;
 end;
end;

procedure tdscontroller.setasmsestring(const afieldname: string;
                                                      const avalue: msestring);
var
 field1: tfield;
begin
 field1:= tdataset(fowner).fieldbyname(afieldname);
 if field1 is tmsestringfield then begin
  tmsestringfield(field1).asmsestring:= avalue;
 end
 else begin
  if field1 is tmsememofield then begin
   tmsememofield(field1).asmsestring:= avalue;
  end
  else begin
   if isutf8 then begin
    field1.asstring:= stringtoutf8ansi(avalue);
   end
   else begin
    field1.asstring:= ansistring(avalue);
   end;
  end;
 end;
end;

procedure tdscontroller.begindisplaydata;
begin
 idscontroller(fintf).begindisplaydata;
end;

procedure tdscontroller.enddisplaydata;
begin
 idscontroller(fintf).enddisplaydata;
end;

procedure tdscontroller.copyrecord(const aappend: boolean = false);
var
 ar1: variantarty;
 ar2: booleanarty;
 ar3: booleanarty;
 field1: tfield;
// intf1: imsefield;
 int1: integer;
 bo1: boolean;
begin
 if checkcanevent(tdataset(fowner),tmethod(fonbeforecopyrecord)) then begin
  fonbeforecopyrecord(tdataset(fowner));
 end;
 with tdataset(fowner) do begin
  setlength(ar1,fields.count);
  setlength(ar2,length(ar1));
  setlength(ar3,length(ar1));
  for int1:= 0 to high(ar1) do begin
   field1:= fields[int1];
   bo1:= (field1.fieldkind in [fkdata,fkinternalcalc]) and
               not (of_nocopyrecord in field1.optionsfield);
   if bo1 then begin
    ar2[int1]:= true;
    ar1[int1]:= field1.value;
   end;
   bo1:= (of_initinsert in field1.optionsfield) and bo1;
   if bo1 then begin
    ar3[int1]:= true;
    field1.optionsfield:= field1.optionsfield - [of_initinsert];
   end;
  end;
  try
   if aappend then begin
    append;
   end
   else begin
    insert;
   end;
   for int1:= 0 to high(ar1) do begin
    if ar2[int1] and not varisnull(ar1[int1]) then begin
     field1:= fields[int1];
     if field1.isnull then begin
      field1.value:= ar1[int1];
     end;
    end;
   end;
  finally
   for int1:= 0 to high(ar3) do begin
    if ar3[int1] then begin
     field1.optionsfield:= field1.optionsfield + [of_initinsert];
    end;
   end;
  end;
 end;
 if checkcanevent(tdataset(fowner),tmethod(fonaftercopyrecord)) then begin
  fonaftercopyrecord(tdataset(fowner));
 end;
end;

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

function tfieldlink.getdataset(const aindex: integer): tdataset;
begin
 result:= fdestdatalink.dataset;
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

function tfieldfieldlink.getfieldname: string;
begin
 result:= fsourcedatalink.fieldname;
end;

procedure tfieldfieldlink.setfieldname(const avalue: string);
begin
 fsourcedatalink.fieldname:= avalue;
end;

function tfieldfieldlink.getdatasource: tdatasource;
begin
 result:= fsourcedatalink.datasource;
end;

function tfieldfieldlink.getdatasource1(const aindex: integer): tdatasource;
begin
 if aindex = 0 then begin
  result:= fsourcedatalink.datasource;
 end
 else begin
  result:= fdestdatalink.datasource;
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
 propertynames[0]:= 'fieldname';
 propertynames[1]:= 'destdatafield';
 setlength(fieldtypes,2);
 fieldtypes[0]:= [];
 fieldtypes[1]:= [];
end;

function tfieldfieldlink.getdataset(const aindex: integer): tdataset;
begin
 result:= nil;
 case aindex of
  0: begin
   result:= fsourcedatalink.dataset;
  end;
  1: begin
   result:= fdestdatalink.dataset;
  end;
 end;
end;

procedure tfieldfieldlink.updatedata(const afield: tfield);
begin
 if fsourcedatalink.field <> nil then begin
  field.value:= fsourcedatalink.field.value;
 end;
 inherited;
end;

procedure tfieldfieldlink.readdatafield(reader: treader);
begin
 fieldname:= reader.readstring;
end;

procedure tfieldfieldlink.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
end;

{ ttimestampfieldlink }

procedure ttimestampfieldlink.updatedata(const afield: tfield);
begin
 if flo_utc in foptions then begin
  afield.asdatetime:= nowutc;
 end
 else begin
  afield.asdatetime:= nowlocal;
 end;
 inherited;
end;

{ tmseparams }

constructor tmseparams.create(aowner: tpersistent);
begin
 inherited create(aowner);
{$warnings off}
 tcollection1(self).fitemclass:= tmseparam;
{$warnings on}
end;

constructor tmseparams.create;
begin
 create(tpersistent(nil));
end;

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
 paramname:= '';
 paramnamestart:= nil;
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
         while not ((p^ = #0) or (p^ = '''')) do
         begin
           if p^='\' then Inc(p,2) // make sure we handle \' and \\ correct
           else Inc(p);
         end;
         if p^='''' then Inc(p); // skip final '
       end;
     '"':  // double quote delimited string
       begin
         Inc(p);
         while not ((p^ = #0) or (p^ = '"')) do
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
           until (p^ = #10) or (p^ = #0);
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
             while (p^ > #127) or
              not (char(byte(p^)) in (SQLDelimiterCharacters +
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
             tmpParam := FindParam(ansistring(ParamName));
             // If so, create the parameter and assign the Parameterindex
             if not assigned(tmpParam) then
               ParameterIndex := CreateParam(ftUnknown,
                                      ansistring(ParamName), ptInput).Index
             else  // else only assign the ParameterIndex
               ParameterIndex := tmpParam.Index;
             end
           // else find ParameterIndex
           else
             begin
               if ParamName<>'' then
                 ParameterIndex:=ParamByName(ansistring(ParamName)).Index
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
     ParamName:= IntToStrmse(ParamBinding[i]+1);
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
          const aparamreplacestring: msestring): msestring;
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
  if not (datatype in [ftblob,ftmemo,ftbytes,ftvarbytes]) and isutf8 then begin
   if vartype(value) = varolestr then begin
    result:= stringtoutf8ansi(aswidestring);
   end
   else begin
    result:= stringtoutf8ansi(msestring(asstring));
   end;
  end
  else begin
   result:= asstring;
  end;
 end;
end;

function tmseparams.getitem(const index: integer): tmseparam;
begin
 result:= tmseparam(inherited items[index]);
end;

procedure tmseparams.setitem(const index: integer; const avalue: tmseparam);
begin
 inherited items[index]:= avalue;
end;

function tmseparams.bindnames(const anames: msestringarty): integerarty;
var
 mstr1: msestring;
 int1,int2: integer;
begin
 setlength(result,count);
 for int1:= high(result) downto 0 do begin
  result[int1]:= -1;
  mstr1:= msestring(items[int1].name);
  for int2:= high(anames) downto 0 do begin
   if anames[int2] = mstr1 then begin
    result[int1]:= int2;
    break;
   end;
  end;
 end;
end;

function tmseparams.getvalues: variantarty;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= high(result) downto 0 do begin
  result[int1]:= items[int1].value;
 end;
end;

procedure tmseparams.setvalues(const avalue: variantarty);
var
 int1: integer;
begin
 for int1:= high(avalue) downto 0 do begin
  items[int1].value:= avalue[int1];
 end;
end;

procedure tmseparams.updatevalues;
var
 int1: integer;
begin
 for int1:= 0 to count-1 do begin
  with tmseparam(items[int1]) do begin
   if fdatalink.field <> nil then begin
    if pos('OLD_',name) = 1 then begin
     value:= fdatalink.field.oldvalue;
    end
    else begin
     value:= fdatalink.field.value;
    end;
   end;
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

{ tmseparam }

constructor tmseparam.Create(ACollection: TCollection);
begin
 fdatalink:= tfielddatalink.create;
 inherited;
end;

destructor tmseparam.destroy;
begin
 connector:= nil;
 fdatalink.free;
 inherited;
end;

procedure tmseparam.setconnector(const avalue: tparamconnector);
begin
 if fconnector <> avalue then begin
  if fconnector <> nil then begin
   fconnector.fparam:= nil;
  end;
  fconnector:= avalue;
  if fconnector <> nil then begin
   if fconnector.fparam <> nil then begin
    fconnector.fparam.fconnector:= nil;
   end;
   fconnector.fparam:= self;
  end;
 end;
end;

//{$ifdef mse_withpublishedparamvalue}
procedure tmseparam.setasvariant(const avalue: variant);
begin
 inherited setasvariant(avalue);
{$warnings off}
 tparam1(self).fbound:= not varisclear(avalue);
{$warnings on}
end;
//{$endif mse_withpublishedparamvalue}
{
function tmseparam.getasid: int64;
begin
 if isnull then begin
  result:= -1;
 end
 else begin
  result:= aslargeint;
 end;
end;

procedure tmseparam.setasid(const avalue: int64);
begin
 if avalue = -1 then begin
  clear;
 end
 else begin
  aslargeint:= avalue;
 end;
end;
}
function tmseparam.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tmseparam.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

function tmseparam.getfieldname: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tmseparam.setfieldname(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tmseparam.getdataset(const aindex: integer): tdataset;
begin
 result:= fdatalink.dataset;
end;

procedure tmseparam.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 afieldtypes:= nil;
end;

function tmseparam.isparamstored: boolean;
begin
 result:= bound;
end;
{
function tmseparam.getasmsestring: msestring;
begin
 result:= getaswidestring;
end;

procedure tmseparam.setasmsestring(const avalue: msestring);
begin
 setaswidestring(avalue);
end;
}
{ tparamconnector }

destructor tparamconnector.destroy;
begin
 if fparam <> nil then begin
  fparam.connector:= nil;
 end;
 inherited;
end;

function tparamconnector.getparam: tmseparam;
begin
 if fparam = nil then begin
  raise exception.create(name+': no param source.');
 end;
 result:= fparam;
end;

{ tmsedatasource }

procedure tmsedatasource.bringtofront;
var
 int1: integer;
begin
 if (dataset <> nil) then begin
{$warnings off}
  with tdataset1(dataset) do begin
{$warnings on}
   int1:= fdatasources.indexof(self);
   if int1 >= 0 then begin
    fdatasources.move(int1,0);
   end;
   sortdatasources();
  end;
 end;
end;

end.
