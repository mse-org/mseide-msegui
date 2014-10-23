{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team


    BufDataset implementation

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  Rewritten 2006-2014 by Martin Schreiber

 **********************************************************************}

unit msebufdataset;
{$ifdef FPC}
 {$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}
 {$define mse_hasvtunicodestring}
{$endif}

interface

uses
 mdb,classes,mclasses,variants,msetypes,msearrayprops,mseclasses,mselist,
 msestrings,
 msedb,msedatabase,mseglob,msearrayutils,msedatalist,msevariants,
 msestream;
  
const
 defaultpacketrecords = -1;
 integerindexfields = [ftsmallint,ftinteger,ftword,ftboolean];
 largeintindexfields = [ftlargeint];
 floatindexfields = [ftfloat,{ftcurrency,}ftdatetime,ftdate,fttime];
 currencyindexfields = [ftcurrency,ftbcd];
 stringindexfields = [ftstring,ftfixedchar];
 guidindexfields = [ftguid];
 indexfieldtypes =  integerindexfields+largeintindexfields+floatindexfields+
                    currencyindexfields+stringindexfields+guidindexfields;
 dsbuffieldkinds = [fkcalculated,fklookup];
 bufferfieldkinds = [fkdata];
 
 dscheckfilter = ord(high(tdatasetstate)) + 1; 
 
const
 bufstreambuffersize = 4096; 
  
type

 fieldinfo_0ty = record      //version 0
  offset: integer; //data offset in buffer     ////
  size: integer;   //size in buffer              //  checked by save/restore
  fieldtype:  tfieldtype;                        //
  dbfieldsize: integer; //maxsize of dbfield   ////
  field: tfield; //last!
 end;

 fieldinfobasety = record
  offset: integer; //data offset in buffer     ////
  size: integer;   //size in buffer              //  checked by save/restore
  fieldtype:  tfieldtype;                        //
  dbfieldsize: integer; //maxsize of dbfield   ////
 end;
 fieldinfoextty = record
  basetype: tfieldtype;
  field: tfield;
  uppername: string;
 end;
 fieldinfoty = record
  base: fieldinfobasety;
  ext: fieldinfoextty;
 end;
 
 fieldinfoarty = array of fieldinfoty;
 
 fielddataty = record
  nullmask: array[0..0] of byte; //variable length
                                 //fielddata following
 end;
 
 blobcacheinfoty = record
  id: int64;
  data: string;
 end;
 blobcacheinfoarty = array of blobcacheinfoty;
   
 blobinfoty = record
  field: tfield;
  data: pointer;
  datalength: integer;
  new: boolean;
 end;
 
 pblobinfoty = ^blobinfoty;
 blobinfoarty = array of blobinfoty;
 pblobinfoarty = ^blobinfoarty;

 blobstreamfixinfoty = record
  id: int64;
  new: boolean;
  current: boolean;
 end;
 blobstreaminfoty = record
  info: blobstreamfixinfoty;
  data: string;
 end;
 
 recheaderty = record
  blobinfo: blobinfoarty;
  fielddata: fielddataty;   
 end;
 precheaderty = ^recheaderty;
 pprecheaderty = ^precheaderty;
   
 intheaderty = record
 end;

 intrecordty = record              
  intheader: intheaderty;
  header: recheaderty;      
 end;
 pintrecordty = ^intrecordty;
 ppintrecordty = ^pintrecordty;

 bookmarkdataty = record
  recno: integer;
  recordpo: pintrecordty;
 end;
 pbookmarkdataty = ^bookmarkdataty;
 
 bufbookmarkty = record
  data: bookmarkdataty;
  flag : tbookmarkflag;
 end;
 pbufbookmarkty = ^bufbookmarkty;

 dsheaderty = record
  bookmark: bufbookmarkty;
 end;
 dsrecordty = record
  dsheader: dsheaderty;
  header: recheaderty;
 end;
 pdsrecordty = ^dsrecordty;
 
const
 intheadersize = sizeof(intheaderty);
 dsheadersize = sizeof(dsheaderty);
     
// structure of internal recordbuffer:
//                 +---------<frecordsize>---------+
// intrecheaderty, |recheaderty,fielddata          |
//                 |moved to tdataset buffer header|
//                 |fieldoffsets are in ffieldinfos[].offset
//                 |                               |
// structure of dataset recordbuffer:
//                 +----------------------<fcalcrecordsize>----------+
//                 +---------<frecordsize>---------+                 |
// dsrecheaderty,  |recheaderty,fielddata          |calcfields       |
//                 |moved to internal buffer header|                 | 
//                 |<-field offsets are in ffieldinfos[].offset      |
//                 |<-calcfield offsets are in fcalcfieldbufpositions|

type
 indexty = record
  ind: pointerarty;
 end;
 pindexty = ^indexty;

 tmsebufdataset = class;
 
 logflagty = (lf_end,lf_rec,lf_update,lf_cancel,lf_apply);
 reclogheaderty = record
  kind: tupdatekind;
  po: pointer;
 end;
 updatelogheaderty = record
  logging: boolean;
  kind: tupdatekind;
  po: pointer;
  deletedrecord: pintrecordty;
 end;
 logbufferheaderty = record
  case flag: logflagty of
   lf_rec: (
    rec: reclogheaderty;
   );
   lf_update,lf_cancel,lf_apply: (
    update: updatelogheaderty;
   );
 end;
 
 tbufstreamwriter = class
  private
   fstream: tstream;
   fowner: tmsebufdataset;
   fbuffer: array [0..bufstreambuffersize-1] of byte;
   fbufindex: integer;
   procedure flushbuffer;
  public
   constructor create(const aowner: tmsebufdataset; const astream: tstream);
   destructor destroy; override;
   procedure write(const buffer; length: integer);
   procedure writefielddata(const data: precheaderty;
                          const aindex: integer);
   procedure writestring(const avalue: string);
   procedure writemsestring(const avalue: msestring);
   procedure writeinteger(const avalue: integer);
   procedure writepointer(const avalue: pointer);
   procedure writevariant(const avalue: variant);
   
   procedure writefielddef(const afielddef: tfielddef);
   procedure writelogbufferheader(const aheader: logbufferheaderty);
   procedure writeendmarker;
 end;

 tbufstreamreader = class
  private
   fstream: tstream;
   fowner: tmsebufdataset;
   fbuffer: array [0..bufstreambuffersize-1] of byte;
   fbuflen: integer;
   fbufindex: integer;
  public
   constructor create(const aowner: tmsebufdataset; const astream: tstream);
   function read(out buffer; length: integer): integer;
   procedure readbuffer(out buffer; const length: integer);
   procedure readfielddata(const data: precheaderty; const aindex: integer);
   function readstring: string;
   function readmsestring: msestring;
   function readinteger: integer;
   function readpointer: pointer;
   function readvariant: variant;
   procedure readfielddef(const aowner: tfielddefs);
   function readlogbufferheader(out aheader: logbufferheaderty): boolean;
                    //false if eof or lf_end
   procedure readrecord(const arecord: pintrecordty);
 end;

 resolverresponsety = (rr_abort,rr_quiet,rr_revert,rr_again,rr_applied);
 resolverresponsesty = set of resolverresponsety;

 updateerroreventty = procedure(
      const sender: tmsebufdataset;
      var e: edatabaseerror; const updatekind: tupdatekind;
         var response: resolverresponsesty) of object;
  
 tblobbuffer = class(tmemorystream)
  private
   fowner: tmsebufdataset;
   ffield: tfield;
  public
   constructor create(const aowner: tmsebufdataset; const afield: tfield);
   destructor destroy; override;
 end;

 tblobcopy = class(tmemorystream)
  public
   constructor create(const ablob: blobinfoty);
   destructor destroy; override;
 end;

 indexfieldoptionty = (ifo_desc,ifo_caseinsensitive);
 indexfieldoptionsty = set of indexfieldoptionty;
 
 tindexfield = class(townedpersistent)
  private
   ffieldname: string;
   foptions: indexfieldoptionsty;
   procedure change;
   procedure setfieldname(const avalue: string);
   procedure setoptions(const avalue: indexfieldoptionsty);
  published
   property fieldname: string read ffieldname write setfieldname;
   property options: indexfieldoptionsty read foptions 
                                    write setoptions default [];
 end;

 localindexoptionty = (lio_desc,lio_default,
                           lio_quicksort); //default is mergesort
 
 localindexoptionsty = set of localindexoptionty;

 tlocalindex = class;  
 
 tindexfields = class(townedpersistentarrayprop)
  private
   function getitems(const index: integer): tindexfield;
  public
   constructor create(const aowner: tlocalindex); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tindexfield read getitems; default;
  published
   property count default 1;
 end;
 
 intrecordpoaty = array[0..0] of pintrecordty;
 pintrecordpoaty = ^intrecordpoaty;
 indexfieldinfoty = record
  fieldinstance: tfield;
  comparefunc: arraysortcomparety;
  vtype: integer;
  recoffset: integer;
  fieldindex: integer;
  islookup: boolean;
  desc: boolean;
  caseinsensitive: boolean;
  canpartialstring: boolean;
 end;
 indexfieldinfoarty = array of indexfieldinfoty;

 tlocalindex = class(townedpersistent)
  private
   ffields: tindexfields;
   foptions: localindexoptionsty;
   fsortarray: pintrecordpoaty;
   findexfieldinfos: indexfieldinfoarty;
   finvalid: boolean;
   fhaslookup: boolean;
   fname: string;
   procedure setoptions(const avalue: localindexoptionsty);
   procedure setfields(const avalue: tindexfields);
   function dolookupcompare(const l,r: pintrecordty;
                             const ainfo: indexfieldinfoty;
                             const apartialstring: boolean): integer;
   function compare1(l,r: pintrecordty; const alastindex: integer;
                    const apartialstring: boolean): integer;
   function compare2(l,r: pintrecordty): integer;
 {$ifndef FPC}
   function compare3(l,r: pointer): integer;
 {$endif}
   procedure quicksort(l,r: integer);
//   procedure mergesort(var adata: pointerarty);
   procedure sort(var adata: pointerarty);
   function getactive: boolean;
   procedure setactive(const avalue: boolean);
   procedure bindfields;
   function findboundary(const arecord: pintrecordty;
                 const alastindex: integer; const abigger: boolean): integer;
                          //returns index of next bigger or lower
   function findrecord(const arecord: pintrecordty): integer;
                         //returns index, -1 if not found
   function getdesc: boolean;
   procedure setdesc(const avalue: boolean);
   function getdefault: boolean;
   procedure setdefault(const avalue: boolean);
  protected
   procedure change;
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
 {$ifndef FPC}
   function findval(const avalues: array of const;
               const aisnull: array of boolean;
               out abookmark: bookmarkdataty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean; overload;
 {$endif}
   function find(const avalues: array of const;
                 //nil -> NULL field
               const aisnull: array of boolean;
                 //itemcount of avalues and aisnull
                 //can be smaller than fields count in index
                 //itemcount of aisnull can be smaller than itemcount of avalues
               out abookmark: bookmarkdataty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean; overload;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
                //string values must be msestring
   function find(const avalues: array of const;
                 //nil -> NULL field
               const aisnull: array of boolean;
                 //itemcount of avalues and aisnull
                 //can be smaller than fields count in index
                 //itemcount of aisnull can be smaller than itemcount of avalues
               out abookmark: bookmarkty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean; overload;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
                //string values must be msestring
   function findvariant(const avalue: array of variant;
               out abookmark: bookmarkty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean; overload;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
                //string values must be msestring
   function find(const avalues: array of tfield;
               out abookmark: bookmarkty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean; overload;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
   function find(const avalues: array of tfield;
               out abookmark: bookmarkdataty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean; overload;
                //true if found else nearest lower or bigger,

   function find(const avalues: array of const;
                 //nil -> NULL field
                const aisnull: array of boolean;
                 //itemcount of avalues and aisnull
                 //can be smaller than fields count in index
                 //itemcount of aisnull can be smaller than itemcount of avalues
                const alast: boolean = false;
                const partialstring: boolean = false;
                const nocheckbrowsemode: boolean = false;
                const exact: boolean = true): boolean; overload;
                //sets dataset cursor if found
   function find(const avalues: array of tfield;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false;
               const exact: boolean = true): boolean; overload;
                //sets dataset cursor if found
   function findvariant(const avalue: array of variant;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false;
               const exact: boolean = true): boolean; overload;
                //sets dataset cursor if found

   function unique(const avalues: array of const): boolean;
   function getbookmark(const arecno: integer): bookmarkty;
   property desc: boolean read getdesc write setdesc;
   property default: boolean read getdefault write setdefault;
  published
   property fields: tindexfields read ffields write setfields;
   property options: localindexoptionsty read foptions 
                              write setoptions default [];
   property active: boolean read getactive write setactive default false;
   property name: string read fname write fname;
                   //case sensitive
 end;

 bufdataseteventty = procedure(const sender: tmsebufdataset) of object;
  
 tlocalindexes = class(townedpersistentarrayprop)
  private
   fonindexchanged: bufdataseteventty;
   function getitems(const index: integer): tlocalindex;
   procedure bindfields;
   function getactiveindex: integer;
   procedure setactiveindex(const avalue: integer);
   function getdefaultindex: integer;
   procedure setdefaultindex(const avalue: integer);
  protected
   procedure checkinactive;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure doindexchanged;
 public
   constructor create(const aowner: tmsebufdataset); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   procedure move(const curindex,newindex: integer); override;
   property items[const index: integer]: tlocalindex read getitems; default;
   function indexbyname(const aname: string): tlocalindex; //case sensitive
   property activeindex: integer read getactiveindex 
                                        write setactiveindex;    //-1 > none
   property defaultindex: integer read getdefaultindex 
                                        write setdefaultindex;   //-1 > none
   function fieldactive(const afield: tfield): boolean;
                   //true if field in active index
   function hasfield(const afield: tfield): boolean;
                   //true if field in any index
   function fieldmodified(const afield: tfield; const delayed: boolean): boolean;
   procedure preparefixup; //clear changed indexes
  published
   property onindexchanged: bufdataseteventty read fonindexchanged
                                                        write fonindexchanged;
 end;

 recupdateflagty = (ruf_applied,ruf_error);
 recupdateflagsty = set of recupdateflagty;

 recupdateinfoty = record
  updatekind: tupdatekind;
  flags: recupdateflagsty;
  bookmark: bookmarkdataty;
 end;
 recupdateinfoarty = array of recupdateinfoty;
 
 recupdatebufferty = record
  info: recupdateinfoty;
  oldvalues: pintrecordty;
 end;
 precupdatebufferty = ^recupdatebufferty;

 recupdatebufferarty = array of recupdatebufferty;
 
 
 bufdatasetstatety = (bs_opening,bs_loading,bs_fetching,
                      bs_displaydata,bs_applying,bs_recapplying,
                      bs_curvaluemodified,
                      bs_curvalueset,{bs_curindexinvalid,}
                      bs_connected,
                      bs_hasindex,bs_fetchall,bs_initinternalcalc,
                      bs_blobsfetched,bs_blobscached,bs_blobssorted,
                      bs_indexvalid,
                      bs_editing,bs_append,bs_internalcalc,bs_startedit,
                      bs_utf8,
                      bs_hasfilter,bs_visiblerecordcountvalid,
                      bs_refreshing,bs_restorerecno,bs_idle,
                      bs_noautoapply,
                      bs_refreshinsert,bs_refreshupdate,
                      bs_refreshinsertindex,bs_refreshupdateindex,
                      bs_inserttoupdate
                                          //used by tsqlquery
                      );
 bufdatasetstatesty = set of bufdatasetstatety;

 bufdatasetstate1ty = (bs1_needsresync,bs1_lookupnotifying,bs1_posting,
                          bs1_deferdeleterecupdatebuffer,bs1_restoreupdate);
 bufdatasetstates1ty = set of bufdatasetstate1ty;
 
 internalcalcfieldseventty = procedure(const sender: tmsebufdataset;
                                              const fetching: boolean) of object;
 iblobchache = interface(inullinterface)
  function blobsarefetched: boolean;
  function getblobcache: blobcacheinfoarty;
  function addblobcache(const adata: pointer;
                    const alength: integer): integer; overload;
  function addblobcache(const aid: int64; const adata: string): integer; overload;
 end;

 ecurrentvalueaccess = class(edatabaseerror)
  public
   constructor create(const adataset: tdataset; const afield: tfield;
                const msg: string);
 end;
 
 eapplyerror = class(edatabaseerror)
  private
   fresponse: resolverresponsesty;
  public
   constructor create(const msg: string = '';
                                   const aresponse: resolverresponsesty = []);
   property response: resolverresponsesty read fresponse write fresponse;
 end;

 lookupdataty = record      //todo: case items?
  po: pointer;
  int: integer;
  lint: int64;
  doub: double;
  cur: currency;
  mstr: msestring;
  boo: longbool;
  vari: variant;
  dt: tdatetime;
  guid: tguid;
 end;
  
 getbmvalueeventty = procedure (const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty) of object;
 lookupfieldinfoty = record
  getvalue: getbmvalueeventty;
  keyfieldar: fieldarty;
  indexnum: integer;
  valuefield: tfield;
  lookupvaluefield: tfield;
  basedatatype: tfieldtype;
  hasindex: boolean;
 end;
 lookupfieldinfoarty = array of lookupfieldinfoty;
  
 filterediteventty = procedure(const sender: tmsebufdataset;
                             const akind: filtereditkindty) of object;
 bufdatasetarty = array of tmsebufdataset;
 
 tmsebufdataset = class(tmdbdataset,iblobchache,idatasetsum,imasterlink,
                        idbdata,iobjectlink)
  private
   fpacketrecords: integer;
   fopen: boolean;
   fupdatebuffer: recupdatebufferarty;
   fcurrentupdatebuffer: integer;
//   fstatebefore: tdatasetstate;
//   fcurrentbufbefore: pintrecordty;

   frecordsize: integer;
   fnullmasksize: integer;
   fcalcfieldcount: integer;
   finternalcalcfieldcount: integer;
   fstringpositions: integerarty;
   fvarpositions: integerarty;
   
   fcalcrecordsize: integer;
   fcalcnullmasksize: integer;
   fcalcfieldbufpositions: integerarty;
   fcalcfieldsizes: integerarty;
   fcalcstringpositions: integerarty;
   fcalcvarpositions: integerarty;
   flookupfieldinfos: lookupfieldinfoarty;
   flookupclients: bufdatasetarty;
   flookupmasters: bufdatasetarty;
   fnotifylookupclientcount: integer;
   
   fbuffercountbefore: integer;
   fonupdateerror: updateerroreventty;

   femptybuffer: pintrecordty;
   ffilterbuffer: array[filtereditkindty] of pdsrecordty;
   fcheckfilterbuffer: pdsrecordty;
   fnewvaluebuffer: pdsrecordty; //buffer for applyupdates
//   flookupbuffer: pdsrecordty;
   flookuppo: pintrecordty;
   flookupresult: lookupdataty;
   fcalcbuffer1: pchar;
   
   findexlocal: tlocalindexes;
   factindex: integer;
   foninternalcalcfields: internalcalcfieldseventty;
   fvisiblerecordcount: integer;
   floadingstream: tstream;
   
   flogfilename: filenamety;
   flogger: tbufstreamwriter;
   fbeforeapplyupdate: tdatasetnotifyevent;
   fafterapplyupdate: tdatasetnotifyevent;
   fbeforebeginfilteredit: filterediteventty;
   fafterbeginfilteredit: filterediteventty;
   fbeforeendfilteredit: filterediteventty;
   fafterendfilteredit: filterediteventty;
   ffiltereditkind: filtereditkindty;
   
   fobjectlinker: tobjectlinker;   
   fcryptohandler: tcustomcryptohandler;
   procedure calcrecordsize;
   function loadbuffer(var buffer: recheaderty): tgetresult;
   function getfieldsize(const datatype: tfieldtype; const varsize: integer;
                         out basetype: tfieldtype) : longint;
   function getrecordupdatebuffer: boolean;
   procedure setpacketrecords(avalue: integer);
   function  intallocrecord: pintrecordty;    
   procedure finalizevalues(var header: recheaderty);
   procedure finalizecalcvalues(var header: recheaderty);
   procedure addrefvalues(var header: recheaderty);
   procedure intfinalizerecord(const buffer: pintrecordty);
   procedure intfreerecord(var buffer: pintrecordty);
   procedure freeblobcache(const arec: precheaderty; const afield: tfield);

   procedure clearindex;
   procedure checkindexsize;    
   function appendrecord(const arecord: pintrecordty): integer;
             //returns new recno
   function insertrecord(arecno: integer; const arecord: pintrecordty): integer;
             //returns new recno
   procedure deleterecord(const arecno: integer); overload;
   procedure deleterecord(const arecord: pintrecordty); overload;
   procedure getnewupdatebuffer;
   procedure setindexlocal(const avalue: tlocalindexes);
   function insertindexrefs(const arecord: pintrecordty): integer;
              //returns new recno of active index
   procedure removeindexrefs(const arecord: pintrecordty);
   function remove0indexref(const arecord: pintrecordty): integer;
                    //returns index
   procedure internalsetrecno(const avalue: integer);
   procedure setactindex(const avalue: integer);
   procedure checkindex(const force: boolean);
   
   function getmsestringdata(const sender: tmsestringfield; 
                               out avalue: msestring): boolean;
   procedure setmsestringdata(const sender: tmsestringfield; avalue: msestring);
   function getvardata(const sender: tmsevariantfield;
                                    out avalue: variant): boolean;
   procedure setvardata(const sender: tmsevariantfield; avalue: variant);
   procedure setoninternalcalcfields(const avalue: internalcalcfieldseventty);
   procedure checkfilterstate;
   procedure checklogfile;
   procedure initsavepoint;
   procedure dointernalopen;
   procedure doloadfromstream;
   procedure dointernalclose;
   procedure logupdatebuffer(const awriter: tbufstreamwriter; 
            const abuffer: recupdatebufferty; const adeletedrecord: pintrecordty;
            const alogging: boolean; const alogmode: logflagty);
   procedure logrecbuffer(const awriter: tbufstreamwriter; 
                         const akind: tupdatekind; const abuffer: pintrecordty);
   function getlogging: boolean;
   procedure checksumfield(const afield: tfield; const fieldtypes: fieldtypesty);
   function getcurrentasfloat(const afield: tfield; aindex: integer): double;
   procedure setcurrentasfloat(const afield: tfield; aindex: integer;
                   const avalue: double);
   function getcurrentisnull(const afield: tfield; aindex: integer): boolean;
   function getcurrentasboolean(const afield: tfield; aindex: integer): boolean;
   procedure setcurrentasboolean(const afield: tfield; aindex: integer;
                   const avalue: boolean);
   function getcurrentasinteger(const afield: tfield; aindex: integer): integer;
   procedure setcurrentasinteger(const afield: tfield; aindex: integer;
                   const avalue: integer);
   function getcurrentaslargeint(const afield: tfield; aindex: integer): int64;
   procedure setcurrentaslargeint(const afield: tfield; aindex: integer;
                   const avalue: int64);
   function getcurrentasdatetime(const afield: tfield; aindex: integer): tdatetime;
   procedure setcurrentasdatetime(const afield: tfield; aindex: integer;
                   const avalue: tdatetime);
   function getcurrentascurrency(const afield: tfield; aindex: integer): currency;
   procedure setcurrentascurrency(const afield: tfield; aindex: integer;
                   const avalue: currency);
   function getcurrentasmsestring(const afield: tfield;
                   aindex: integer): msestring;
   procedure setcurrentasmsestring(const afield: tfield; aindex: integer;
                   const avalue: msestring);
   function getcurrentasguid(const afield: tfield; aindex: integer): tguid;
   procedure setcurrentasguid(const afield: tfield; aindex: integer;
                   const avalue: tguid);
   function getcurrentasid(const afield: tfield; aindex: integer): int64;
   procedure setcurrentasid(const afield: tfield; aindex: integer;
                   const avalue: int64);
   procedure setbookmarkdata1(const avalue: bookmarkdataty);
   function getcurrentbmisnull(const afield: tfield;
                                  const abm: bookmarkdataty): boolean;
   function getcurrentbmasboolean(const afield: tfield;
                                                           const abm: bookmarkdataty): boolean;
   procedure setcurrentbmasboolean(const afield: tfield;
                                                           const abm: bookmarkdataty;
                   const avalue: boolean);
   function getcurrentbmasinteger(const afield: tfield;
                                     const abm: bookmarkdataty): integer;
   procedure setcurrentbmasinteger(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: integer);
   function getcurrentbmaslargeint(const afield: tfield;
                                     const abm: bookmarkdataty): int64;
   procedure setcurrentbmaslargeint(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: int64);
   function getcurrentbmasid(const afield: tfield;
                                     const abm: bookmarkdataty): int64;
   procedure setcurrentbmasid(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: int64);
   function getcurrentbmasfloat(const afield: tfield;
                                     const abm: bookmarkdataty): double;
   procedure setcurrentbmasfloat(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: double);
   function getcurrentbmasdatetime(const afield: tfield;
                                     const abm: bookmarkdataty): tdatetime;
   procedure setcurrentbmasdatetime(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: tdatetime);
   function getcurrentbmascurrency(const afield: tfield;
                                     const abm: bookmarkdataty): currency;
   procedure setcurrentbmascurrency(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: currency);
   function getcurrentbmasmsestring(const afield: tfield;
                                     const abm: bookmarkdataty): msestring;
   procedure setcurrentbmasmsestring(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: msestring);
   function getcurrentbmasguid(const afield: tfield;
                                     const abm: bookmarkdataty): tguid;
   procedure setcurrentbmasguid(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: tguid);
   procedure docurrentassign(const po1: pointer;
                          const abasetype: tfieldtype; const df: tfield);
   procedure lookupdschanged(const sender: tmsebufdataset);
   procedure notifylookupclients;
   function getcurrentasvariant(const afield: tfield; aindex: integer): variant;
   procedure setcurrentasvariant(const afield: tfield; aindex: integer;
                   const avalue: variant);
   function getchangerecords: recupdateinfoarty;
   function getapplyerrorrecords: recupdateinfoarty;
   function getcurrentbmasvariant(const afield: tfield;
                                                           const abm: bookmarkdataty): variant;
   procedure setcurrentbmasvariant(const afield: tfield;
                                                           const abm: bookmarkdataty;
                   const avalue: variant);
   procedure setcryptohandler(const avalue: tcustomcryptohandler);
  protected
   fcontroller: tdscontroller;
   fbrecordcount: integer;
   ffieldinfos: fieldinfoarty;
   ffieldorder: integerarty;
   factindexpo: pindexty;    
   fbstate: bufdatasetstatesty;
   fbstate1: bufdatasetstates1ty;
   fallpacketsfetched : boolean;
   fapplyindex: integer; //take care about canceled updates while applying
   ffailedcount: integer;
   frecno: integer; //null based
   findexes: array of indexty;
   fblobcache: blobcacheinfoarty;
   fblobcount: integer;
   ffreedblobs: integerarty;
   ffreedblobcount: integer;
   fcurrentbuf: pintrecordty;
   fcurrentupdating: integer;
//   flastcurrentrec: pintrecordty;
   flastcurrentindex: integer;
   fsavepointlevel: integer;

   procedure openlocal;
   procedure fixupcurrentset; virtual;
   procedure currentcheckbrowsemode;

   function getrestorerecno: boolean;
   procedure setrestorerecno(const avalue: boolean);

   procedure dogetcoldata(const afield: tfield; const afieldtype: tfieldtype;
                           const step: integer; const data: pointer);
   function getcurrentlookuppo(const afield: tfield;
        const afieldtype: tfieldtype; const arecord: pintrecordty): pointer;
   function getcurrentpo(const afield: tfield;
        const afieldtype: tfieldtype; const arecord: pintrecordty): pointer;
   function beforecurrentget(const afield: tfield;
              const afieldtype: tfieldtype; var aindex: integer): pointer;
   function beforecurrentbmget(const afield: tfield;
              const afieldtype: tfieldtype; const abm: bookmarkdataty): pointer;
   function setcurrentpo(const afield: tfield;
              const afieldtype: tfieldtype; const arecord: precheaderty;
              const aisnull: boolean; out changed: boolean): pointer;
   function beforecurrentset(const afield: tfield;
              const afieldtype: tfieldtype; var aindex: integer;
              const aisnull: boolean; out changed: boolean): pointer;
   procedure aftercurrentset(const afield: tfield); virtual;
   function beforecurrentbmset(const afield: tfield;
              const afieldtype: tfieldtype; const abm: bookmarkdataty;
              const aisnull: boolean; out changed: boolean): pointer;
   procedure getbminteger(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmlargeint(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmcurrency(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmfloat(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmstring(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmboolean(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmdatetime(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmvariant(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   procedure getbmguid(const afield: tfield; const bm: bookmarkdataty;
                                          var adata: lookupdataty);
   
   function getfieldbuffer(const afield: tfield;
             out buffer: pointer; out datasize: integer): boolean; overload; 
             //read, true if not null
   function getfieldbuffer(const afield: tfield;
             const aisnull: boolean; out datasize: integer): pointer;
                                                       overload; virtual;
             //write
   procedure fieldchanged(const field: tfield);
   function getfiltereditkind: filtereditkindty;
   function blobsarefetched: boolean;
   function getblobcache: blobcacheinfoarty;
   function findcachedblob(var info: blobcacheinfoty): boolean; overload;
   function findcachedblob(const id: int64; 
                           out info: blobcacheinfoty): boolean; overload;
   function addblobcache(const adata: pointer;
                    const alength: integer): integer; overload;
   function addblobcache(const aid: int64; const adata: string): integer; overload;
   procedure updatestate;
   function getintblobpo: pblobinfoarty; //in currentrecbuf
   procedure internalcancel; override;
   procedure FreeFieldBuffers; override;
   procedure cancelrecupdate(var arec: recupdatebufferty);
   procedure setdatastringvalue(const afield: tfield; const avalue: string);
   function getdsoptions: datasetoptionsty; virtual;
   procedure resetblobcache;
   procedure sortblobcache;   
   procedure fetchblobs;
   procedure fetchallblobs;
   procedure getofflineblob(const data: precheaderty; const aindex: integer;
                                   out ainfo: blobstreaminfoty);
   procedure setofflineblob(const adata: precheaderty; const aindex: integer;
                                   const ainfo: blobstreaminfoty);
   function getblobrecpo: precheaderty;

   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty); virtual;
   procedure savepointevent(const sender: tmdbtransaction;
                  const akind: savepointeventkindty; const alevel: integer); override;
   procedure packrecupdatebuffer;
   procedure restorerecupdatebuffer;
   procedure postrecupdatebuffer;
   procedure recupdatebufferapplied(const abuf: precupdatebufferty);
   procedure editapplyerror(const arecupdatenum: integer);
   procedure internalapplyupdate(const maxerrors: integer;
               const cancelonerror: boolean;
               const cancelondeleteerror: boolean;
               out response: resolverresponsesty);
   procedure afterapply; virtual;
   procedure freeblob(const ablob: blobinfoty);
   procedure freeblobs(var ablobs: blobinfoarty);
   procedure deleteblob(var ablobs: blobinfoarty; const aindex: integer;
                  const afreeblob: boolean); overload;
   procedure deleteblob(var ablobs: blobinfoarty; const afield: tfield;
                               const adeleteitem: boolean); overload;
   procedure addblob(const ablob: tblobbuffer);
   
   procedure setrecno1(value: longint; const nocheck: boolean);
   procedure setrecno(value: longint); override;
   function  getrecno: longint; override;
   function getchangecount: integer; virtual;
   function getapplyerrorcount: integer; virtual;
   function  allocrecordbuffer: pchar; override;
   procedure internalinitrecord(buffer: pchar); override;
   procedure clearcalcfields(buffer: pchar); override;
   procedure freerecordbuffer(var buffer: pchar); override;
   function  getcanmodify: boolean; override;
   function getrecord(buffer: pchar; getmode: tgetmode;
                                   docheck: boolean): tgetresult; override;
   function  GetNextRecord: Boolean; override;
   function  GetNextRecords: Longint; override;
   function bookmarkdatatobookmark(const abookmark: bookmarkdataty): bookmarkty;
   function bookmarktobookmarkdata(const abookmark: bookmarkty): bookmarkdataty;
   function findbookmarkindex(const abookmark: bookmarkdataty): integer;
   procedure checkrecno(const avalue: integer);
   procedure setonfilterrecord(const value: tfilterrecordevent); override;
   procedure setfiltered(value: boolean); override;
   procedure setactive(value: boolean); override;

   procedure CalculateFields(Buffer: PChar); override;
   procedure loaded; override;                              
   procedure OpenCursor(InfoQuery: Boolean); override;
   procedure internalopen; override;
   procedure internalclose; override;
   procedure clearbuffers; override;
   procedure internalinsert; override;
   procedure internaledit; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure checkconnected;
   procedure startlogger;
   procedure closelogger;
   procedure savestate(const awriter: tbufstreamwriter);
 
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   function getnextpacket(const all: boolean) : integer;
   function getrecordsize: word; override;
   procedure saveindex(const oldbuffer,newbuffer: pintrecordty;
                                           var ar1,ar2,ar3: integerarty);
   procedure relocateindex(const abuffer: pintrecordty;
                                    const ar1,ar2,ar3: integerarty);
   procedure internalpost; override;
   procedure internaldelete; override;
   procedure internalfirst; override;
   procedure internallast; override;
   procedure internalsettorecord(buffer: pchar); override;
   procedure internalgotobookmark(abookmark: pointer); override;
   procedure setbookmarkdata(buffer: pchar; data: pointer); override;
   procedure setbookmarkflag(buffer: pchar; value: tbookmarkflag); override;
   procedure getbookmarkdata(buffer: pchar; data: pointer); override;
   function getbookmarkdata1: bookmarkdataty;
   function getbookmarkflag(buffer: pchar): tbookmarkflag; override;
   function getfieldblobid(const field: tfield; out aid: blobidty): boolean;
                    //false if null
   function iscursoropen: boolean; override;
   function  getrecordcount: longint; override;
   procedure applyrecupdate(updatekind : tupdatekind); virtual;
   procedure setonupdateerror(const avalue: updateerroreventty);
   property actindex: integer read factindex write setactindex;
   function findrecord(arecordpo: pintrecordty): integer; reintroduce;
                         //returns index, -1 if not found
   procedure dofilterrecord(var acceptable: boolean); virtual;
   procedure dobeforeapplyupdate; virtual;
   procedure doafterapplyupdate; virtual;
   
   function islocal: boolean; virtual;
   function updatesortfield(const afield: tfield; const adescend: boolean): boolean;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject;
                                 const event: objecteventty); virtual;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); virtual;
   procedure objevent(const sender: iobjectlink; const event: objecteventty); virtual;
   function getinstance: tobject;
   function getcomponent: tcomponent;
    //idscontroller
   procedure begindisplaydata;
   procedure enddisplaydata;
    //idbdata
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
   
 {abstracts, must be overidden by descendents}
   function fetch : boolean; virtual; abstract;
   function getblobdatasize: integer; virtual; abstract;
   function blobscached: boolean; virtual; abstract;
   function loadfield(const afieldno: integer; const afieldtype: tfieldtype{const afield: tfield}; 
                const buffer: pointer;
                    var bufsize: integer): boolean; virtual; abstract;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
   property nullmasksize: integer read fnullmasksize;
   function islastrecord: boolean;   
   procedure checkfreebuffer(const afield: tfield);
   function callvalidate(const afield: tfield; const avalue: pointer): boolean;
   procedure checkvaluebuffer(const afield: tfield; const asize: integer);
 {$ifndef FPC}
   function refreshrecordvarar(const sourcedatasets: array of tdataset;
              const akeyvalue: array of variant;
              const keyindex: integer;
              const acancelupdate: boolean;
              const restorerecno: boolean;
              const noinsert: boolean): bookmarkdataty;
  {$endif}
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure post; override;
   procedure gotobookmark(const abookmark: bookmarkdataty); overload;
   function findbookmark(const abookmark: bookmarkdataty): boolean;
   
   function createblobstream(field: tfield;
                                     mode: tblobstreammode): tstream; override;
   function getfielddata(field: tfield; buffer: pointer;
                       nativeformat: boolean): boolean; override;
   function getfielddata(field: tfield; buffer: pointer): boolean; override;
   procedure setfielddata(field: tfield; buffer: pointer;
                                    nativeformat: boolean); override;
   procedure setfielddata(field: tfield; buffer: pointer); override;
   procedure Append;
   procedure notifycontrols; //calls enablecontrols/disablecontrols

   //logging works with persistent fields only
   procedure recover;
            //load from logfile, start logging,
   procedure startlogging;
            //close logfile, save state with truncated log, open logfile
   procedure stoplogging; //close logfile
   property logging: boolean read getlogging;
   procedure savetostream(const astream: tstream);
   procedure loadfromstream(const astream: tstream);
   procedure savetofile(const afilename: filenamety;
                      const acryptohandler: tcustomcryptohandler = nil);
   procedure loadfromfile(const afilename: filenamety;
                      const acryptohandler: tcustomcryptohandler = nil);
   function streamloading: boolean;

    //imasterlink
   function refreshing: boolean;

   function refreshrecord(const akeyfield: array of tfield;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty; overload;
   function refreshrecord(const sourcedatasets: array of tdataset;
              const akeyvalue: array of variant;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty; overload;
   function refreshrecord(const asourcefields: array of tfield;
              const akeyfield: array of tfield;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty; overload;
   function refreshrecord(const asourcefields: array of tfield;
              const adestfields: array of tfield;
              const akeyfield: array of tfield;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty; overload;
   function refreshrecord(const asourcefields: array of tfield;
              const adestfields: array of tfield;
              const akeyvalue: array of variant;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty; overload;
   function refreshrecord(const asourcevalues: array of variant;
              const adestfields: array of tfield;
              const akeyvalue: array of variant;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty; overload;
          //keyindex must be unique, copies equally named visible fields,
          //inserts record if key not found.   

   procedure copyfieldvalues(const bm: bookmarkdataty;
                               const dest: tdataset); overload;
                        //copies field values with same name
   procedure copyfieldvalues(const bm: bookmarkdataty;
                const dest: tmsebufdataset;
                       const acancelupdate: boolean); overload;
                        //copies field values with same name

   function isutf8: boolean; virtual;
   procedure bindfields(const bind: boolean);
   function findfields(const anames: string): fieldarty; overload;
   function findfields(const anames: string; out afields: fieldarty): boolean;
                                                         overload;
                           //true if all found
   procedure fieldtoparam(const source: tfield; const dest: tparam);
   procedure oldfieldtoparam(const source: tfield; const dest: tparam);
   procedure stringtoparam(const source: msestring; const dest: tparam);
                  //takes care about utf8 conversion
   function recordisnull(): boolean; //all fields null
   procedure clearrecord();
   procedure clearfilter();
   property filtereditkind: filtereditkindty read ffiltereditkind 
                                                    write ffiltereditkind;
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   function fieldfiltervalue(const afield: tfield;
                     const akind: filtereditkindty = fek_filter): variant;
   function fieldfiltervalueisnull(const afield: tfield;
                     const akind: filtereditkindty = fek_filter): boolean;
   procedure filterchanged;
   function locate(const afields: array of tfield;
       const akeys: array of const; const aisnull: array of boolean;
       const akeyoptions: array of locatekeyoptionsty;
       const aoptions: locaterecordoptionsty = []): locateresultty; reintroduce;
   function locaterecno(const arecno: integer): boolean;
        //moves to next valid recno, //returns true if resulting recno = arecno
   
   function countvisiblerecords: integer;
   procedure fetchall;
   procedure resetindex; //deactivates all indexes
   function createblobbuffer(const afield: tfield): tblobbuffer;

   property changecount: integer read getchangecount;
   property changerecords: recupdateinfoarty read getchangerecords;
   property applyerrorcount: integer read getapplyerrorcount;
   property applyerrorrecords: recupdateinfoarty read getapplyerrorrecords;
   
   procedure applyupdates(const maxerrors: integer = 0); overload; virtual;
   procedure applyupdates(const maxerrors: integer;
                         const cancelonerror: boolean;
                const cancelondeleteerror: boolean = false;
                const editonerror: boolean = false); overload; virtual;
   procedure applyupdate(const cancelonerror: boolean;
                const cancelondeleteerror: boolean = false;
                const editonerror: boolean = false); overload; virtual;
   procedure applyupdate; overload; virtual;
                   //applies current record
   function recapplying: boolean;
   procedure cancelupdates; virtual;
   procedure cancelupdate(const norecordcancel: boolean = false); virtual; 
                   //cancels current record,
                   //if norecordcancel no restoring of old values
   function updatestatus: tupdatestatus; overload; override;
   function updatestatus(out aflags: recupdateflagsty): tupdatestatus; overload;
   
   property bookmarkdata: bookmarkdataty read getbookmarkdata1
                                             write setbookmarkdata1;

   procedure currentbeginupdate; virtual;
   procedure currentendupdate; virtual;
   function currentrecordhigh: integer; //calls checkbrowsemode

       //calls checkbrowsemode, writing for fkInternalCalc only, 
       //aindex = -1 -> current record
   procedure currentclear(const afield: tfield; aindex: integer);
   procedure currentassign(const source: tfield; const dest: tfield;
                              aindex: integer);
   property currentisnull[const afield: tfield; aindex: integer]: boolean read
                 getcurrentisnull;
   property currentasvariant[const afield: tfield; aindex: integer]: variant
                  read getcurrentasvariant write setcurrentasvariant;
   property currentasboolean[const afield: tfield; aindex: integer]: boolean
                  read getcurrentasboolean write setcurrentasboolean;
   property currentasinteger[const afield: tfield; aindex: integer]: integer
                  read getcurrentasinteger write setcurrentasinteger;
   property currentaslargeint[const afield: tfield; aindex: integer]: int64
                  read getcurrentaslargeint write setcurrentaslargeint;
   property currentasid[const afield: tfield; aindex: integer]: int64
                  read getcurrentasid write setcurrentasid; //-1 for null
   property currentasfloat[const afield: tfield; aindex: integer]: double
                  read getcurrentasfloat write setcurrentasfloat;
   property currentasdatetime[const afield: tfield; aindex: integer]: tdatetime
                  read getcurrentasdatetime write setcurrentasdatetime;
   property currentascurrency[const afield: tfield; aindex: integer]: currency
                  read getcurrentascurrency write setcurrentascurrency;
   property currentasmsestring[const afield: tfield; aindex: integer]: msestring
                  read getcurrentasmsestring write setcurrentasmsestring;
   property currentasguid[const afield: tfield; aindex: integer]: tguid
                  read getcurrentasguid write setcurrentasguid;

   procedure currentbmclear(const afield: tfield; const abm: bookmarkdataty);
   procedure currentbmassign(const source: tfield; const dest: tfield;
                              const abm: bookmarkdataty);
   property currentbmisnull[const afield: tfield;
               const abm: bookmarkdataty]: boolean read getcurrentbmisnull;
   property currentbmasvariant[const afield: tfield;
                                        const abm: bookmarkdataty]: variant
                  read getcurrentbmasvariant write setcurrentbmasvariant;
   property currentbmasboolean[const afield: tfield;
                                        const abm: bookmarkdataty]: boolean
                  read getcurrentbmasboolean write setcurrentbmasboolean;
   property currentbmasinteger[const afield: tfield;
                  const abm: bookmarkdataty]: integer
                  read getcurrentbmasinteger write setcurrentbmasinteger;
   property currentbmaslargeint[const afield: tfield;
                  const abm: bookmarkdataty]: int64
                  read getcurrentbmaslargeint write setcurrentbmaslargeint;
   property currentbmasid[const afield: tfield;
                  const abm: bookmarkdataty]: int64
                  read getcurrentbmasid write setcurrentbmasid; //-1 for null
   property currentbmasfloat[const afield: tfield;
                  const abm: bookmarkdataty]: double
                  read getcurrentbmasfloat write setcurrentbmasfloat;
   property currentbmasdatetime[const afield: tfield;
                  const abm: bookmarkdataty]: tdatetime
                  read getcurrentbmasdatetime write setcurrentbmasdatetime;
   property currentbmascurrency[const afield: tfield;
                  const abm: bookmarkdataty]: currency
                  read getcurrentbmascurrency write setcurrentbmascurrency;
   property currentbmasmsestring[const afield: tfield;
                  const abm: bookmarkdataty]: msestring
                  read getcurrentbmasmsestring write setcurrentbmasmsestring;
   property currentbmasguid[const afield: tfield;
                  const abm: bookmarkdataty]: tguid
                  read getcurrentbmasguid write setcurrentbmasguid;

   procedure getcoldata(const afield: tfield; const adatalist: tdatalist);
   procedure asarray(const afield: tfield; out avalue: int64arty); overload;
   procedure asarray(const afield: tfield; out avalue: integerarty); overload;
   procedure asarray(const afield: tfield; out avalue: stringarty); overload;
   procedure asarray(const afield: tfield; out avalue: msestringarty); overload;
   procedure asarray(const afield: tfield; out avalue: currencyarty); overload;
   procedure asarray(const afield: tfield; out avalue: realarty); overload;
   procedure asarray(const afield: tfield; out avalue: datetimearty); overload;
   procedure asarray(const afield: tfield; out avalue: booleanarty); overload;
   
   function getdata(const afields: array of tfield): variantararty;
                             //[] -> all
   procedure sumfield(const afield: tfield; out asum: double); overload;
   procedure sumfield(const afield: tfield; out asum: currency); overload;
   procedure sumfield(const afield: tfield; out asum: integer); overload;
   procedure sumfield(const afield: tfield; out asum: int64); overload;
   function sumfielddouble(const afield: tfield): double;
   function sumfieldcurrency(const afield: tfield): currency;
   function sumfieldinteger(const afield: tfield): integer;
   function sumfieldint64(const afield: tfield): int64;

   
  published
   property logfilename: filenamety read flogfilename write flogfilename;
   property cryptohandler: tcustomcryptohandler read fcryptohandler
                                                  write setcryptohandler;
   property packetrecords : integer read fpacketrecords write setpacketrecords 
                                 default defaultpacketrecords;
   property indexlocal: tlocalindexes read findexlocal write setindexlocal;
   
   property onupdateerror: updateerroreventty read fonupdateerror 
                                 write setonupdateerror;
   property oninternalcalcfields: internalcalcfieldseventty 
                      read foninternalcalcfields write setoninternalcalcfields;
   property beforeapplyupdate: tdatasetnotifyevent read fbeforeapplyupdate
                       write  fbeforeapplyupdate;
   property afterapplyupdate: tdatasetnotifyevent read fafterapplyupdate 
                       write  fafterapplyupdate;
   property beforebeginfilteredit: filterediteventty
                       read fbeforebeginfilteredit write fbeforebeginfilteredit;
   property afterbeginfilteredit: filterediteventty
                       read fafterbeginfilteredit write fafterbeginfilteredit;
   property beforeendfilteredit: filterediteventty
                       read fbeforeendfilteredit write fbeforeendfilteredit;
   property afterendfilteredit: filterediteventty
                       read fafterendfilteredit write fafterendfilteredit;
   property Active default false;
//   property AutocalcFields default false;
  end;
   
function getfieldflag(nullmask: pbyte; const x: integer): boolean;
procedure setfieldflag(nullmask: pbyte; const x: integer);
procedure clearfieldflag(nullmask: pbyte; const x: integer);
procedure alignfieldpos(var avalue: integer);

implementation
uses
 rtlconsts,{$ifdef FPC}dbconst{$else}dbconst_del,classes_del{$endif},sysutils,
 mseformatstr,msereal,msesys,msefileutils,mseapplication,msesysutils;
 
type
 tmsestringfield1 = class(tmsestringfield); 
 tmseblobfield1 = class(tmseblobfield);
 tmsevariantfield1 = class(tmsevariantfield);
 tmsebooleanfield1 = class(tmsebooleanfield);
 tmsedatetimefield1 = class(tmsedatetimefield);
 tfield1 = class(tfield);
 
const
 fielddatacompatibility: array[tfieldtype] of fieldtypesty = (
    //ftUnknown, ftString,    ftSmallint,    ftInteger,     ftWord,
      [ftunknown],stringfcomp,longintfcomp,longintfcomp,longintfcomp,
    //ftBoolean,   ftFloat,                ftCurrency,              ftBCD,
      booleanfcomp,realfcomp+datetimefcomp,realfcomp+datetimefcomp,[ftbcd],
    //ftDate,                      ftTime,                 tDateTime,
      realfcomp+datetimefcomp,realfcomp+datetimefcomp,realfcomp+datetimefcomp,
    //ftBytes,  ftVarBytes,  ftAutoInc,
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
      [ftIDispatch],[ftGuid],[ftTimeStamp],[ftFMTBcd],
    //ftFixedWideChar,ftWideMemo
      stringfcomp,   stringfcomp   
      );

function compblobcache(const a,b): integer;
var
 lint1: int64;
begin
 lint1:= blobcacheinfoty(a).id - blobcacheinfoty(b).id;
 result:= 0;
 if lint1 < 0 then begin
  result:= -1;
 end
 else begin
  if lint1 > 0 then begin
   result:= 1;
  end;
 end;
end;

function compinteger(const l,r): integer;
begin
 result:= integer(l) - integer(r);
end;

function compint64(const l,r): integer;
begin
 if int64(l) > int64(r) then begin
  result:= 1;
 end
 else begin
  if int64(l) = int64(r) then begin
   result:= 0;
  end
  else begin
   result:= -1;
  end;
 end;
end;

function compfloat(const l,r): integer;
begin
 result:= 0;
 if double(l) > double(r) then begin
  inc(result);
 end
 else begin
  if double(l) < double(r) then begin
   dec(result);
  end;
 end;
end;

function compcurrency(const l,r): integer;
begin
 result:= 0;
 if currency(l) > currency(r) then begin
  inc(result);
 end
 else begin
  if currency(l) < currency(r) then begin
   dec(result);
  end;
 end;
end;

function compstring(const l,r): integer;
begin
 result:= msecomparestr(msestring(l),msestring(r));
end;

function compstringi(const l,r): integer;
begin
 result:= msecomparetext(msestring(l),msestring(r));
end;

function compguid(const l,r): integer;
var
 int1: integer;
begin
 for int1:= 0 to (sizeof(tguid) div sizeof(integer)) - 1 do begin
  result:= pintegeraty(@l)^[int1]-pintegeraty(@r)^[int1];
  if result <> 0 then begin
   break;
  end;
 end;
end;

type
 fieldcomparekindty = (fct_integer,fct_largeint,fct_float,fct_currency,fct_text,
                       fct_guid);
 fieldcompareinfoty = record
  datatypes: set of tfieldtype;
  cvtype: integer;
  compfunc: arraysortcomparety;
  compfunci: arraysortcomparety;
 end;
 
const
 comparefuncs: array[fieldcomparekindty] of fieldcompareinfoty = 
  ((datatypes: integerindexfields; cvtype: vtinteger;
                compfunc: {$ifdef FPC}@{$endif}compinteger;
                compfunci: {$ifdef FPC}@{$endif}compinteger),
   (datatypes: largeintindexfields; cvtype: vtint64;
                compfunc: {$ifdef FPC}@{$endif}compint64;
                compfunci: {$ifdef FPC}@{$endif}compint64),
   (datatypes: floatindexfields; cvtype: vtextended;
                compfunc: {$ifdef FPC}@{$endif}compfloat;
                compfunci: {$ifdef FPC}@{$endif}compfloat),
   (datatypes: currencyindexfields; cvtype: vtcurrency;
                compfunc: {$ifdef FPC}@{$endif}compcurrency;
                compfunci: {$ifdef FPC}@{$endif}compcurrency),
   (datatypes: stringindexfields;
          cvtype: {$ifdef mse_hasvtunicodestring}vtunicodestring
                  {$else}vtwidestring{$endif};
                compfunc: {$ifdef FPC}@{$endif}compstring;
                compfunci: {$ifdef FPC}@{$endif}compstringi),
   (datatypes: guidindexfields; cvtype: mse_vtguid;
                compfunc: {$ifdef FPC}@{$endif}compguid;
                compfunci: {$ifdef FPC}@{$endif}compguid)
);

procedure alignfieldpos(var avalue: integer);
const
 step = sizeof(pointer);
begin
 avalue:= (avalue + step - 1) and -step; //align to pointer
end;

const
{$ifdef FPC}
 ormask:  array[0..7] of byte = (%00000001,%00000010,%00000100,%00001000,
                                 %00010000,%00100000,%01000000,%10000000);
 andmask: array[0..7] of byte = (%11111110,%11111101,%11111011,%11110111,
                                 %11101111,%11011111,%10111111,%01111111);
{$else}
 ormask:  array[0..7] of byte = ($01,$02,$04,$08,$10,$20,$40,$80);
 andmask: array[0..7] of byte =
              (byte(not$01),byte(not$02),byte(not$04),byte(not$08),
               byte(not$10),byte(not$20),byte(not$40),byte(not$80));
{$endif}

procedure setfieldflag(nullmask: pbyte; const x: integer);
//var
// int1: integer;
begin
 inc(nullmask,(x shr 3));
 nullmask^:= nullmask^ or ormask[x and 7];
end;

procedure clearfieldflag(nullmask: pbyte; const x: integer);
begin
 inc(nullmask,(x shr 3));
 nullmask^:= nullmask^ and andmask[x and 7];
end;

function getfieldflag(nullmask: pbyte; const x: integer): boolean;
begin
 inc(nullmask,(x shr 3));
 result:= nullmask^ and ormask[x and 7] <> 0;
end;


{ tbufstreamwriter }

constructor tbufstreamwriter.create(const aowner: tmsebufdataset; 
                                            const astream: tstream);
begin
 fowner:= aowner;
 fstream:= astream;
end;

destructor tbufstreamwriter.destroy;
begin
 flushbuffer;
 inherited;
end;

procedure tbufstreamwriter.flushbuffer;
begin
 fstream.writebuffer(fbuffer,fbufindex);
 fbufindex:= 0;
end;

procedure tbufstreamwriter.write(const buffer; length: integer);
var
 po1: pointer;
 int1: integer;
begin
 po1:= @buffer;
 while length > 0 do begin
  int1:= length;
  if int1 + fbufindex > bufstreambuffersize then begin
   int1:= bufstreambuffersize - fbufindex;
  end;
  move(po1^,fbuffer[fbufindex],int1);
  inc(fbufindex,int1);
  if fbufindex >= bufstreambuffersize then begin
   flushbuffer;
  end;
  inc(pchar(po1),int1);
  dec(length,int1);
 end;
end;

procedure tbufstreamwriter.writefielddata(const data: precheaderty; 
                                                    const aindex: integer);
var
 fielddata: pointer;
 blobinfo: blobstreaminfoty;
begin
 with fowner.ffieldinfos[aindex].base do begin
  fielddata:= pchar(pointer(data)) + offset;
  case fieldtype of
   ftstring,ftfixedchar,ftwidestring,ftfixedwidechar: begin
    writemsestring(msestring(fielddata^));
   end;
   ftmemo,ftblob,ftgraphic: begin
    if getfieldflag(@data^.fielddata.nullmask,aindex) then begin
     fowner.getofflineblob(data,aindex,blobinfo);
     write(blobinfo.info,sizeof(blobinfo.info));
     writestring(blobinfo.data);
    end;
   end;
   ftvariant: begin
    writevariant(variant(fielddata^));
   end;
   else begin
    write(fielddata^,size);
   end;
  end;
 end; 
end;

procedure tbufstreamwriter.writestring(const avalue: string);
begin
 writeinteger(length(avalue));
 write(pointer(avalue)^,length(avalue));
end;

procedure tbufstreamwriter.writemsestring(const avalue: msestring);
begin
 writeinteger(length(avalue));
 write(pointer(avalue)^,length(avalue)*sizeof(msechar));
end;

procedure tbufstreamwriter.writeinteger(const avalue: integer);
begin
 write(avalue,sizeof(integer));
end;

procedure tbufstreamwriter.writefielddef(const afielddef: tfielddef);
begin
 with afielddef do begin
  writestring(name);
  writeinteger(ord(datatype));  
  writeinteger(size);
  writeinteger(integer(required));
  writeinteger(fieldno);
  writeinteger(precision);
 end;
end;

procedure tbufstreamwriter.writelogbufferheader(
                                const aheader: logbufferheaderty);
begin
 write(aheader,sizeof(aheader));
end;

procedure tbufstreamwriter.writeendmarker;
var
 abuffer: logbufferheaderty;
begin
 fillchar(abuffer,sizeof(abuffer),0);
 abuffer.flag:= lf_end;
 write(abuffer,sizeof(abuffer));
end;

procedure tbufstreamwriter.writepointer(const avalue: pointer);
begin
 write(avalue,sizeof(pointer));
end;

type
 pointeraty1 = array[0..1] of pointer;
 ppointeraty1 = ^pointeraty1;

procedure tbufstreamwriter.writevariant(const avalue: variant);
var
 int1,int2: integer;
begin
 write(avalue,sizeof(variant));
 with tvardata(avalue) do begin
  case vtype of
   varstring: begin
    writestring(ansistring(vstring));
   end;
   varolestr: begin
    writemsestring(widestring(pointer(volestr)));
   end;
  end;
  if vtype and vararray <> 0 then begin
   write(varray^,sizeof(tvararray));
   with varray^ do begin
    write(ppointeraty1(varray)^[1],(dimcount-1)*sizeof(tvararrayboundarray));
               //additional dims
    int2:= 1;
    for int1:= 0 to dimcount-1 do begin
     int2:= int2 * bounds[int1].elementcount;
    end;
    write(data^,elementsize*int2);
    case vtype and vartypemask of
     varstring: begin
      for int1:= 0 to int2 - 1 do begin
       writestring(pstringaty(data)^[int1]);
      end;
     end;
     varolestr: begin
      for int1:= 0 to int2 - 1 do begin
       writemsestring(pwidestringaty(data)^[int1]);
      end;
     end;
     varvariant: begin
      for int1:= 0 to int2 - 1 do begin
       writevariant(pvariantaty(data)^[int1]);
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ tbufstreamreader }

constructor tbufstreamreader.create(const aowner: tmsebufdataset; 
                                               const astream: tstream);
begin
 fowner:= aowner;
 fstream:= astream;
end;

function tbufstreamreader.read(out buffer; length: integer): integer;
var
 po1: pointer;
 int1: integer;
begin
 po1:= @buffer;
 result:= 0;
 while length > 0 do begin
  int1:= length;
  if int1 + fbufindex >= fbuflen then begin
   int1:= fbuflen - fbufindex;
  end;
  move(fbuffer[fbufindex],po1^,int1);
  inc(pchar(po1),int1);
  inc(result,int1);
  dec(length,int1);
  inc(fbufindex,int1);
  if fbufindex >= fbuflen then begin
   fbufindex:= 0;
   fbuflen:= fstream.read(fbuffer,bufstreambuffersize);
   if fbuflen = 0 then begin
    exit;        //eof
   end;
  end; 
 end;
end;

procedure tbufstreamreader.readbuffer(out buffer; const length: integer);
begin
 if read(buffer,length) < length then begin
  raise ereaderror.create(sreaderror);
 end;
end;

procedure tbufstreamreader.readfielddata(const data: precheaderty; 
                         const aindex: integer);
var
 fielddata: pointer;
 blobinfo: blobstreaminfoty;
begin
 with fowner.ffieldinfos[aindex].base do begin
  fielddata:= pchar(pointer(data)) + offset;
  case fieldtype of
   ftstring,ftfixedchar,ftwidestring,ftfixedwidechar: begin
    msestring(fielddata^):= readmsestring;
   end;
   ftmemo,ftblob,ftgraphic: begin
    if getfieldflag(@data^.fielddata.nullmask,aindex) then begin
     readbuffer(blobinfo.info,sizeof(blobinfo.info));
     blobinfo.data:= readstring;
     fowner.setofflineblob(data,aindex,blobinfo);
    end;
   end;
   ftvariant: begin
    variant(fielddata^):= readvariant;
   end;
   else begin
    readbuffer(fielddata^,size);
   end;
  end;
 end;
end;

function tbufstreamreader.readstring: string;
var
 int1: integer;
begin
 int1:= readinteger;
 setlength(result,int1);
 readbuffer(pointer(result)^,int1);
end;

function tbufstreamreader.readmsestring: msestring;
var
 int1: integer;
begin
 int1:= readinteger;
 setlength(result,int1);
 readbuffer(pointer(result)^,int1*sizeof(msechar));
end;

function tbufstreamreader.readinteger: integer;
begin
 readbuffer(result,sizeof(integer));
end;

procedure tbufstreamreader.readfielddef(const aowner: tfielddefs);
var
 name: string;
 datatype: tfieldtype;
 size: integer;
 required: boolean;
 fieldno: integer;
 precision: integer; 
 def1: tfielddef;
begin
 name:= readstring;
 datatype:= tfieldtype(readinteger);  
 size:= readinteger;
 if datatype in blobfields then begin
//  size:= fowner.getblobdatasize;
  size:= 0;
 end;
 required:= boolean(readinteger);
 fieldno:= readinteger;
 precision:= readinteger;
 def1:= tfielddef.create(aowner,name,datatype,size,required,fieldno);
 def1.precision:= precision;
end;

function tbufstreamreader.readlogbufferheader(
                      out aheader: logbufferheaderty): boolean;
begin
 result:= (read(aheader,sizeof(aheader)) = sizeof(aheader)) and 
          (aheader.flag <> lf_end);
end;

function tbufstreamreader.readpointer: pointer;
begin
 readbuffer(result,sizeof(pointer));
end;

type
 bufdattagty = array[0..15]of char;
 tbsfheaderty = packed record
  tag: bufdattagty;
  byteorder: byte;      //0 -> little endian, 1 - big endian
  version: integer;
  fieldcount: integer;
  fielddefcount: integer;
  recordcount: integer;
 end;
 
procedure tbufstreamreader.readrecord(const arecord: pintrecordty);
var
 int1: integer;
 datapo: precheaderty;
begin
 datapo:= @arecord^.header;
 readbuffer(datapo^.fielddata,fowner.fnullmasksize);
 for int1:= 0 to high(fowner.ffieldinfos) do begin
  readfielddata(datapo,int1);
 end;
end;

function tbufstreamreader.readvariant: variant;
var
 int1,int2: integer;
begin
 readbuffer(result,sizeof(variant));
 with tvardata(result) do begin
  case vtype of
   varstring: begin
    vtype:= 0;
    result:= readstring;
   end;
   varolestr: begin
    vtype:= 0;
    result:= readmsestring;
   end;
  end;
  if vtype and vararray <> 0 then begin
   getmem(pointer(varray),sizeof(tvararray));
   read(varray^,sizeof(tvararray));
   varray^.lockcount:= 0;
   reallocmem(varray,sizeof(tvararray)+
                   (varray^.dimcount-1)*sizeof(tvararrayboundarray));
   with varray^ do begin
    read(ppointeraty1(varray)^[1],(dimcount-1)*sizeof(tvararrayboundarray));
    int2:= 1;
    for int1:= 0 to dimcount-1 do begin
     int2:= int2 * bounds[int1].elementcount;
    end;
    getmem(data,elementsize*int2);
    read(data^,elementsize*int2);
    case vtype and vartypemask of
     varstring: begin
      for int1:= 0 to int2 - 1 do begin
       ppointeraty(data)^[int1]:= nil;
       pansistringaty(data)^[int1]:= readstring;
      end;
     end;
     varolestr: begin
      for int1:= 0 to int2 - 1 do begin
       ppointeraty(data)^[int1]:= nil;
       pwidestringaty(data)^[int1]:= readmsestring;
      end;
     end;
     varvariant: begin
      for int1:= 0 to int2 - 1 do begin
       pvardataaty(data)^[int1].vtype:= 0;
       pvariantaty(data)^[int1]:= readvariant;
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ tblobbuffer }

constructor tblobbuffer.create(const aowner: tmsebufdataset; const afield: tfield);
begin
 fowner:= aowner;
 ffield:= afield;
 inherited create;
end;

destructor tblobbuffer.destroy;
begin
 fowner.addblob(self);
 setpointer(nil,0);
 inherited;
end;

{ tblobcopy }

constructor tblobcopy.create(const ablob: blobinfoty);
begin
 inherited create;
 setpointer(ablob.data,ablob.datalength);
end;

destructor tblobcopy.destroy;
begin
 setpointer(nil,0);
 inherited;
end;

{ eapplyerror }

constructor eapplyerror.create(const msg: string = ''; 
                         const aresponse: resolverresponsesty = []);
begin
 fresponse:= aresponse;
 inherited create(msg);
end;

{ tmsebufdataset }

constructor tmsebufdataset.Create(AOwner : TComponent);
begin
 frecno:= -1;
 findexlocal:= tlocalindexes.create(self);
 packetrecords:= defaultpacketrecords;
 inherited;
 bookmarksize := sizeof(bufbookmarkty);
end;

destructor tmsebufdataset.destroy;
var
 int1: integer;
begin
 inherited destroy;
 for int1:= high(flookupclients) downto 0 do begin
  removeitem(pointerarty(flookupclients[int1].flookupmasters),pointer(self));
 end;
 findexlocal.free;
 closelogger;
 freeandnil(fobjectlinker);
end;

procedure tmsebufdataset.setpacketrecords(avalue : integer);
begin
 if (avalue = 0) then begin
  databaseerror('Packetrecords can not be 0.'{sinvpacketrecordsvalue});
 end;
 fpacketrecords:= avalue;
 updatestate;
end;

Function tmsebufdataset.GetCanModify: Boolean;
begin
 result:= false;
end;

function tmsebufdataset.intallocrecord: pintrecordty;
begin
 result:= allocmem(frecordsize+intheadersize);
 fillchar(result^,frecordsize+intheadersize,0);
 {
 fillchar(result^,sizeof(intrecordty),0);
 for int1:= high(fstringpositions) downto 0 do begin
  pointer(pointer(@result^.header)+fstringpositions[int1])^):= nil;
 end;
 }
end;

procedure freedbvariant(var avalue: variant);
begin
 finalize(avalue);
{
 if avariant <> nil then begin
  finalize(avariant^);
  freemem(avariant);
  avariant:= nil;
 end;
 }
end;

procedure addrefdbvariant(var avalue: variant);
var
 var1: variant;
begin
 move(avalue,var1,sizeof(variant));
 fillchar(avalue,sizeof(variant),0);
 avalue:= var1; //deep copy
 tvardata(var1).vtype:= 0;
{
 po1:= avariant;
 if po1 <> nil then begin
  avariant:= getmem(sizeof(variant));
  tvardata(avariant^).vtype:= 0;
  avariant^:= po1^;
 end;
 }
end;

procedure tmsebufdataset.finalizevalues(var header: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fstringpositions) downto 0 do begin
  pmsestring(pchar(pointer(@header))+fstringpositions[int1])^:= '';
 end;
 for int1:= high(fvarpositions) downto 0 do begin
  freedbvariant(pvariant(pchar(pointer(@header))+fvarpositions[int1])^);
 end;
end;

procedure tmsebufdataset.finalizecalcvalues(var header: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fcalcstringpositions) downto 0 do begin
  pmsestring(pchar(pointer(@header))+fcalcstringpositions[int1])^:= '';
 end;
 for int1:= high(fcalcvarpositions) downto 0 do begin
  freedbvariant(pvariant(pchar(pointer(@header))+fcalcvarpositions[int1])^)
 end;
end;
{
procedure tmsebufdataset.finalizechangedvalues(const tocompare: recheaderty; 
                                      var tofinalize: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fstringpositions) downto 0 do begin
  if ppointer(pointer(@tocompare)+fstringpositions[int1])^ <>
     ppointer(pointer(@tofinalize)+fstringpositions[int1])^ then begin
   pmsestring(pointer(@tofinalize)+fstringpositions[int1])^:= '';
  end;
 end;
 for int1:= high(fvarpositions) downto 0 do begin
  if ppointer(pointer(@tocompare)+fvarpositions[int1])^ <>
     ppointer(pointer(@tofinalize)+fvarpositions[int1])^ then begin
   freedbvariant(ppvariant(pointer(@tofinalize)+fvarpositions[int1])^);
  end;
 end;
end;
}
procedure tmsebufdataset.addrefvalues(var header: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fstringpositions) downto 0 do begin
  stringaddref(pmsestring(pchar(pointer(@header))+fstringpositions[int1])^);
 end;
 for int1:= high(fvarpositions) downto 0 do begin
  addrefdbvariant(pvariant(pchar(pointer(@header))+fvarpositions[int1])^)
 end;
end;

procedure tmsebufdataset.intfinalizerecord(const buffer: pintrecordty);
begin
 freeblobs(buffer^.header.blobinfo);
 finalizevalues(buffer^.header);
end;

procedure tmsebufdataset.intfreerecord(var buffer: pintrecordty);
begin
 if buffer <> nil then begin
  intfinalizerecord(buffer);  
  freemem(buffer);
  buffer:= nil;
 end;
end;

function tmsebufdataset.allocrecordbuffer: pchar;
var
 int1: integer;
begin
 int1:= dsheadersize+fcalcrecordsize;
 result:= allocmem(int1);
 fillchar(result^,int1,0); //init for refcounted calcdata
 initrecord(result);
end;

procedure tmsebufdataset.clearcalcfields(buffer: pchar);
var
 int1: integer;
begin
 with pdsrecordty(buffer)^ do begin
  for int1:= high(fcalcstringpositions) downto 0 do begin
   pmsestring(pchar(pointer(@header))+fcalcstringpositions[int1])^:= '';
  end;
  for int1:= high(fcalcvarpositions) downto 0 do begin
   freedbvariant(pvariant(pchar(pointer(@header))+fcalcvarpositions[int1])^)
  end;
  fillchar((pchar(pointer(@header))+frecordsize)^,fcalcrecordsize-frecordsize,0);
 end;
end;

procedure tmsebufdataset.internalinitrecord(buffer: pchar);
begin
 with pdsrecordty(buffer)^ do begin
  finalizecalcvalues(precheaderty(@header)^);
  fillchar(header,fcalcrecordsize,#0); //zero the whole buffer
 end;
end;
{
procedure tmsebufdataset.internalinitrecord(buffer: pchar);

begin
 freecalcfields(buffer);
// with pdsrecordty(buffer)^ do begin
//  fillchar(header,fcalcrecordsize, #0);
// end;
end;
}
procedure tmsebufdataset.freerecordbuffer(var buffer: pchar);
//var
// int1: integer;
// bo1: boolean;
begin
 if buffer <> nil then begin
  with pdsrecordty(buffer)^,header do begin
{ there can be copies of invalid buffers
   bo1:= false;
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].new then begin
     freeblob(blobinfo[int1]);
     bo1:= true;
    end;
   end;
   if bo1 then begin
    blobinfo:= nil;
   end;
}
   finalizecalcvalues(header);
  end;
  reallocmem(buffer,0);
 end;
end;

function tmsebufdataset.getintblobpo: pblobinfoarty;
begin
 if bs_recapplying in fbstate then begin
  result:= @fnewvaluebuffer^.header.blobinfo;
 end
 else begin
  result:= @fcurrentbuf^.header.blobinfo;
 end;
end;

procedure tmsebufdataset.freeblob(const ablob: blobinfoty);
begin
 with ablob do begin
  if datalength > 0 then begin
   freemem(data);
  end;
 end;
end;

function tmsebufdataset.createblobbuffer(const afield: tfield): tblobbuffer;
begin
 result:= tblobbuffer.create(self,afield);
end;

procedure tmsebufdataset.freeblobcache(const arec: precheaderty;
                                                 const afield: tfield);
var
 fieldindex: integer;
 blobid: integer;
begin
//todo: free offline blobs
 if bs_blobscached in fbstate then begin
  fieldindex:= afield.fieldno-1;
  if getfieldflag(@arec^.fielddata.nullmask,fieldindex) then begin
   blobid:= pinteger(pchar(arec) + ffieldinfos[fieldindex].base.offset)^;
   fblobcache[blobid].data:= '';
   additem(ffreedblobs,blobid,ffreedblobcount{,(high(ffreedblobs)+129)*2});
  end;
 end;
end;

procedure tmsebufdataset.addblob(const ablob: tblobbuffer);
var
 int1,int2: integer;
 bo1: boolean;
 blobfree: boolean;
 po2: pointer;
 po1: precheaderty;
begin
 bo1:= false;
 int2:= -1;
 if bs_recapplying in fbstate then begin
  po1:= @fnewvaluebuffer^.header;
  blobfree:= true;
 end
 else begin
  po1:= @pdsrecordty(activebuffer)^.header;
  blobfree:= false; 
 end;
 with po1^{pdsrecordty(activebuffer)^.header} do begin
  for int1:= high(blobinfo) downto 0 do begin
   with blobinfo[int1] do begin
    if new then begin
     bo1:= true;
    end;
    if field = ablob.ffield then begin
     int2:= int1;
    end;
   end;
  end;
  if not bo1 and not (bs_recapplying in fbstate) then begin //copy needed
   po2:= pointer(blobinfo);
   pointer(blobinfo):= nil;
   blobinfo:= copy(blobinfoarty(po2));
  end;
  if int2 >= 0 then begin
   deleteblob(blobinfo,int2,blobfree);
  end
  else begin
   if blobfree then begin                //else done in post
    freeblobcache(po1,ablob.ffield); 
   end;
  end;
  setlength(blobinfo,high(blobinfo)+2);
  with blobinfo[high(blobinfo)],ablob do begin
   data:= memory;
   reallocmem(data,size);
   datalength:= size;
   field:= ffield;
   if not (bs_recapplying in fbstate) then begin
    new:= true;
   end;
   if size = 0 then begin
    clearfieldflag(@fielddata.nullmask,field.fieldno-1);
   end
   else begin
    setfieldflag(@fielddata.nullmask,field.fieldno-1);
   end;
   fieldchanged(field);
  end;
 end;
end;

procedure tmsebufdataset.freeblobs(var ablobs: blobinfoarty);
var
 int1: integer;
begin
 for int1:= 0 to high(ablobs) do begin
  freeblob(ablobs[int1]);
 end;
 ablobs:= nil;
end;

procedure tmsebufdataset.deleteblob(var ablobs: blobinfoarty;
                    const aindex: integer; const afreeblob: boolean);
begin
 if afreeblob then begin
  freeblob(ablobs[aindex]);
 end;
 deleteitem(ablobs,typeinfo(blobinfoarty),aindex); 
end;

procedure tmsebufdataset.deleteblob(var ablobs: blobinfoarty; 
                     const afield: tfield; const adeleteitem: boolean);
var
 int1: integer;
begin
 for int1:= high(ablobs) downto 0 do begin
  if ablobs[int1].field = afield then begin
   freeblob(ablobs[int1]);
   if adeleteitem then begin
    deleteitem(ablobs,typeinfo(blobinfoarty),int1); 
   end
   else begin
    ablobs[int1].field:= nil;
   end;
   exit;
  end;
 end;
 if not adeleteitem then begin //called from post
  freeblobcache(@fcurrentbuf^.header,afield); 
 end; 
end;

procedure tmsebufdataset.initsavepoint;
begin
 fsavepointlevel:= -1;
 exclude(fbstate1,bs1_deferdeleterecupdatebuffer);
end;

procedure tmsebufdataset.dointernalopen;
var
 int1: integer;
 kind1: filtereditkindty;
begin
 initsavepoint;
 for int1:= 0 to fields.count - 1 do begin
  with fields[int1] do begin
   if (fieldkind = fkdata) and (fielddefs.indexof(fieldname) < 0) then begin
    databaseerrorfmt(sfieldnotfound,[fieldname],self);
   end;
  end;
 end;
 include(fbstate,bs_opening);
 if dso_cacheblobs in getdsoptions then begin
  include(fbstate,bs_blobsfetched);
 end
 else begin 
  exclude(fbstate,bs_blobsfetched);
 end;
 if isutf8 then begin
  include(fbstate,bs_utf8);
 end
 else begin
  exclude(fbstate,bs_utf8);
 end;
 bindfields(true); //calculate calc fields size
 setlength(findexes,1+findexlocal.count);
 factindexpo:= @findexes[factindex];
 calcrecordsize;
 findexlocal.bindfields;
 femptybuffer:= intallocrecord;
 for kind1:= low(filtereditkindty) to high(filtereditkindty) do begin
  ffilterbuffer[kind1]:= pdsrecordty(allocrecordbuffer);
 end;
 fnewvaluebuffer:= pdsrecordty(allocrecordbuffer);
// flookupbuffer:= pdsrecordty(allocrecordbuffer);
 updatestate;
 fallpacketsfetched:= false;
 fopen:= true;
end;

procedure tmsebufdataset.internalopen;
begin
 if blobscached then begin
  include(fbstate,bs_blobscached);
 end
 else begin
  exclude(fbstate,bs_blobscached);
 end;
 if streamloading then begin
  doloadfromstream;
 end
 else begin
  dointernalopen;
 end;
end;

procedure tmsebufdataset.openlocal;
var
 bo1: boolean;
begin
 bo1:= false;
 if defaultfields then begin
  createfields;
 end;
 if (flogfilename <> '') and findfile(flogfilename) then begin
  floadingstream:= tmsefilestream.create(flogfilename,fm_read);
  tmsefilestream(floadingstream).cryptohandler:= fcryptohandler;
  bo1:= true;
 end;
 if floadingstream <> nil then begin
  try
   doloadfromstream;
  finally
   if bo1 then begin
    freeandnil(floadingstream);
   end;
  end;
 end
 else begin
  dointernalopen;
  fallpacketsfetched:= true;
 end;
 if (flogfilename <> '') and not (csdesigning in componentstate) then begin
  startlogger;   
 end;
end;

procedure tmsebufdataset.dointernalclose;
var 
 int1: integer;
 kind1: filtereditkindty;
 po1: precupdatebufferty;
begin
 exclude(fbstate,bs_opening);
 for int1:= 0 to high(fupdatebuffer) do begin
  po1:= @fupdatebuffer[int1];
  with po1^ do begin
   if info.bookmark.recordpo <> nil then begin
    if ruf_applied in info.flags then begin
     recupdatebufferapplied(po1);
    end
    else begin
     intfreerecord(oldvalues);
    end;
   end;
  end;
 end;
 closelogger;
 frecno:= -1;
 resetblobcache;
 if fopen then begin
  fopen:= false;
  with findexes[0] do begin
   for int1:= 0 to fbrecordcount - 1 do begin
    intfreerecord(pintrecordty(ind[int1]));
   end;
  end;
  intfreerecord(femptybuffer);
  for kind1:= low(filtereditkindty) to high(filtereditkindty) do begin
   intfinalizerecord(@ffilterbuffer[kind1]^.header);
   freerecordbuffer(pchar(ffilterbuffer[kind1]));
  end;
  freemem(fnewvaluebuffer); //allways copied by move, needs no finalize
//  for int1:= 0 to high(fupdatebuffer) do begin
//   with fupdatebuffer[int1] do begin
//    if bookmark.recordpo <> nil then begin
//     intfreerecord(oldvalues);
//    end;
//   end;
//  end;
  fupdatebuffer:= nil;
 end;
 clearindex;
 fbrecordcount:= 0;
 
 ffieldinfos:= nil;
 fstringpositions:= nil;
 fvarpositions:= nil;
 fcalcfieldbufpositions:= nil;
 flookupfieldinfos:= nil;
 for int1:= high(flookupmasters) downto 0 do begin
  removeitem(pointerarty(flookupmasters[int1].flookupclients),pointer(self));
 end;
 flookupmasters:= nil;
 fcalcfieldsizes:= nil;
 fcalcstringpositions:= nil;
 fcalcvarpositions:= nil;
 
 bindfields(false);
end;

procedure tmsebufdataset.internalclose;
begin
 dointernalclose;
end;

procedure tmsebufdataset.clearbuffers;
begin
 if bs_editing in fbstate then begin
  internalcancel; //free data
 end;
 inherited;
end;

procedure tmsebufdataset.internalinsert;
begin
 include(fbstate,bs_editing);
 with pdsrecordty(activebuffer)^.dsheader.bookmark.data do begin
  recordpo:= nil;
  recno:= frecno;
 end;
 inherited;
end;

procedure tmsebufdataset.internaledit;
begin
 addrefvalues(pdsrecordty(activebuffer)^.header);
 fbstate:= fbstate + [bs_startedit,bs_editing];
// include(fbstate,bs_editing);
 inherited;
end;

procedure tmsebufdataset.internalfirst;
begin
 internalsetrecno(-1);
end;

procedure tmsebufdataset.internallast;
begin
{
 repeat
 until (getnextpacket < fpacketrecords) or (bs_fetchall in fbstate);
}
 getnextpacket(true);
 internalsetrecno(fbrecordcount)
end;

function tmsebufdataset.getrecord(buffer: pchar; getmode: tgetmode;
                                            docheck: boolean): tgetresult;
var
 acceptable: boolean;
 state1: tdatasetstate; 
begin
 result:= grok;
 acceptable:= true;
 fcheckfilterbuffer:= pointer(buffer);
 repeat
  case getmode of
   gmprior: begin
    if frecno <= 0 then begin
     result := grbof;
    end
    else begin
     internalsetrecno(frecno-1);
    end;
   end;
   gmcurrent: begin
    if (frecno < 0) or (frecno >= fbrecordcount) or 
                                   (fcurrentbuf = nil) then begin
     result := grerror;
    end;
   end;
   gmnext: begin
    if frecno >= fbrecordcount - 1 then begin
     if getnextpacket(bs_fetchall in fbstate) = 0 then begin
      result:= greof;
     end
     else begin
      internalsetrecno(frecno+1);
     end;
    end
    else begin
     internalsetrecno(frecno+1);
    end;
   end;
  end;
  if result = grok then begin
   with pdsrecordty(buffer)^ do begin
    with dsheader.bookmark do  begin
     data.recno:= frecno;
     data.recordpo:= fcurrentbuf;
     flag:= bfcurrent;
    end;
    move(fcurrentbuf^.header,header,frecordsize);
    getcalcfields(buffer); //get lookup fields
    if filtered then begin
     state1:= settempstate(tdatasetstate(dscheckfilter));
     try
      acceptable:= true;
      dofilterrecord(acceptable);
     finally
      restorestate(state1);
     end;
    end;
    if (getmode = gmcurrent) and not acceptable then begin
     result:= grerror;
    end;
   end;
  end;
 until acceptable or (result <> grok);
 if docheck and (result = grerror) then begin
  databaseerror('No record');
 end;
end;

function tmsebufdataset.getrecordupdatebuffer : boolean;
var 
 int1: integer;
begin
 if bs_recapplying in fbstate then begin
  result:= true; //fcurrentupdatebuffer is valid
 end
 else begin
  with pdsrecordty(activebuffer)^.dsheader.bookmark.data do begin
   if (fcurrentupdatebuffer >= length(fupdatebuffer)) or 
        (fupdatebuffer[fcurrentupdatebuffer].info.bookmark.recordpo <> 
                                                         recordpo) then begin
    for int1:= 0 to high(fupdatebuffer) do begin
     with fupdatebuffer[int1] do begin
      if (info.bookmark.recordpo = recordpo) and 
                             not (ruf_applied in info.flags) then begin
       fcurrentupdatebuffer:= int1;
       break;
      end;
     end;
    end;
   end;
   result:= (fcurrentupdatebuffer <= high(fupdatebuffer))  and 
   (fupdatebuffer[fcurrentupdatebuffer].info.bookmark.recordpo = recordpo) and 
          (recordpo <> nil);
  end;
 end;
end;

procedure tmsebufdataset.internalsettorecord(buffer: pchar);
begin
 internalsetrecno(pdsrecordty(buffer)^.dsheader.bookmark.data.recno);
end;

procedure tmsebufdataset.setbookmarkdata(buffer: pchar; data: pointer);
begin
 move(data^,pdsrecordty(buffer)^.dsheader.bookmark,sizeof(bookmarkdataty));
end;

procedure tmsebufdataset.setbookmarkflag(buffer: pchar; value: tbookmarkflag);
begin
 pdsrecordty(buffer)^.dsheader.bookmark.flag := value;
end;

procedure tmsebufdataset.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
 move(pdsrecordty(buffer)^.dsheader.bookmark,data^,sizeof(bookmarkdataty));
end;

function tmsebufdataset.getbookmarkdata1: bookmarkdataty;
begin
 getbookmarkdata(activebuffer,@result);
end;

function tmsebufdataset.getbookmarkflag(buffer: pchar): tbookmarkflag;
begin
 result:= pdsrecordty(buffer)^.dsheader.bookmark.flag;
end;

function tmsebufdataset.findrecord(arecordpo: pintrecordty): integer;
//-1 if not found
var
 int1: integer;
 po1: ppointeraty;
begin
 if factindex = 0 then begin
  result:= -1;
  po1:= pointer(findexes[0].ind);
  for int1:= fbrecordcount - 1 downto 0 do begin
   if po1^[int1] = arecordpo then begin
    result:= int1;
    break;
   end;
  end;
 end
 else begin
  result:= findexlocal[factindex-1].findrecord(arecordpo);
 end;
end;

function tmsebufdataset.findbookmarkindex(const abookmark: bookmarkdataty): integer;
begin
 with abookmark do begin
  if (recno >= fbrecordcount) or (recno < 0) then begin
   databaseerror('Invalid bookmark recno: '+inttostr(recno)+'.'); 
  end;
  checkindex(false);
  if (factindexpo^.ind[recno] <> recordpo) and (recordpo <> nil) then begin
   result:= findrecord(recordpo);
   if result < 0 then begin
    databaseerror('Invalid bookmarkdata.');
   end;
  end
  else begin
   result:= recno;
  end;
 end;
end;

procedure tmsebufdataset.internalgotobookmark(abookmark: pointer);
begin
 if abookmark <> nil then begin
  internalsetrecno(findbookmarkindex(pbufbookmarkty(abookmark)^.data));
 end;
end;

function tmsebufdataset.findbookmark(const abookmark: bookmarkdataty): boolean;
var
 int1: integer;
 bm1: bookmarkdataty;
begin
 result:= false;
 with abookmark do begin
  checkindex(false);
  if (recno < 0) or (recno >= fbrecordcount) or 
          (factindexpo^.ind[recno] <> recordpo) and (recordpo <> nil) then begin
   int1:= findrecord(recordpo);
  end
  else begin
   int1:= recno;
  end;
  if int1 >= 0 then begin
   bm1:= abookmark;
   bm1.recno:= int1;
   gotobookmark(@bm1);
   result:= true;
  end;
 end;
end;

procedure tmsebufdataset.gotobookmark(const abookmark: bookmarkdataty);
begin
 gotobookmark(@abookmark);
end;

function tmsebufdataset.getnextpacket(const all: boolean): integer;
var
 state1: tdatasetstate;
 int1,int2,int3: integer;
 recnobefore: integer;
 bufbefore: pointer;
 bo1,bo2: boolean;
 ar1: fieldarty;
 field1: tfield;
 {$ifdef mse_debugdataset}
 ts: longword;
 {$endif}
 
begin
 result:= 0;
 if fallpacketsfetched then  begin
  exit;
 end;
 int2:= fbrecordcount;
 database.beforeaction;
 try
{$ifdef mse_debugdataset}
  if all then begin
   debugoutstart(ts,self,'getnextpacket all');
  end
  else begin
   debugoutstart(ts,self,'getnextpacket');
  end;
{$endif}
  while ((result < fpacketrecords) or all) and 
                              (loadbuffer(femptybuffer^.header) = grok) do begin
   appendrecord(femptybuffer);
   femptybuffer:= intallocrecord;
   inc(result);
  end;
  bo1:= checkcanevent(self,tmethod(foninternalcalcfields));
  bo2:= (bs_initinternalcalc in fbstate);
  if bo2 then begin
   setlength(ar1,fields.count);
   int3:= 0;
   for int1:= 0 to high(ar1) do begin
    field1:= fields[int1];
    with field1 do begin
     if (fieldkind = fkinternalcalc) and (defaultexpression <> '') then begin
      ar1[int3]:= field1;
      inc(int3);
     end;
    end;
   end;
   setlength(ar1,int3);
  end;
  if bo1 or bo2 then begin
   state1:= settempstate(dsinternalcalc);
   fbstate:= fbstate + [bs_internalcalc,bs_fetching];
   recnobefore:= frecno;
   bufbefore:= fcurrentbuf;
   try
    for int1:= int2 to fbrecordcount-1 do begin
     frecno:= int1;
     fcurrentbuf:= findexes[0].ind[int1];
     if bo2 then begin
      for int3:= 0 to high(ar1) do begin
       with ar1[int3] do begin
        asstring:= defaultexpression;
       end;
      end;
     end;
     if bo1 then begin
      foninternalcalcfields(self,true);
     end;
    end;
   finally
    frecno:= recnobefore;
    fcurrentbuf:= bufbefore;
    fbstate:= fbstate - [bs_internalcalc,bs_opening,bs_fetching];
    restorestate(state1);
   end;
  end;
  exclude(fbstate,bs_opening);
 {$ifdef mse_debugdataset}
  debugoutend(ts,self,'getnextpacket');
 {$endif}
 finally
  database.afteraction;
 end;
end;

function tmsebufdataset.getfieldsize(const datatype: tfieldtype;
            const varsize: integer; out basetype: tfieldtype): longint;
begin
 case datatype of
  ftstring,ftfixedchar,ftwidestring,ftfixedwidechar,ftwidememo: begin
   result:= sizeof(msestring);
   basetype:= ftwidestring;
  end;
  ftbytes: begin
   result:= varsize;
   basetype:= ftbytes;
  end;
  ftvarbytes: begin
   result:= varsize + sizeof(word);
   basetype:= ftvarbytes;
  end;
  ftguid: begin
   result:= sizeof(tguid);
   basetype:= ftguid;
  end;
  ftsmallint,ftinteger,ftword: begin
   result:= sizeof(longint);
   basetype:= ftinteger;
  end;
  ftboolean: begin
   result:= sizeof(longbool);
   basetype:= ftboolean;
  end;
  ftbcd: begin
   result:= sizeof(currency);
   basetype:= ftbcd;
  end;
  ftfloat,ftcurrency: begin
   result:= sizeof(double);
   basetype:= ftfloat;
  end;
  ftlargeint: begin
   result:= sizeof(largeint);
   basetype:= ftlargeint;
  end;
  fttime,ftdate,ftdatetime: begin
   result:= sizeof(tdatetime);
   basetype:= ftdatetime;
  end;
  ftmemo,ftblob: begin
   result:= getblobdatasize;
   basetype:= ftblob;
  end;
  ftvariant: begin
   result:= sizeof(variant);
   basetype:= ftvariant;
  end;
  else begin 
   result:= 0;
   basetype:= ftunknown;
  end;
 end;
end;

function tmsebufdataset.loadbuffer(var buffer: recheaderty): tgetresult;
var
 int1,int2: integer;
 str1: string;
 field1: tfield;
 po2: pmsestring;
 fno: integer;
begin
 if not fetch then  begin
  result := greof;
  fallpacketsfetched := true;
  exit;
 end;
 pointer(buffer.blobinfo):= nil;
 fillchar(buffer.fielddata.nullmask,fnullmasksize,$ff);
 for int1:= 0 to fields.count-1 do begin
  field1:= fields[ffieldorder[int1]]; //ODBC needs ordered loadfield
  fno:= field1.fieldno-1;
  with ffieldinfos[fno].base do begin
   case field1.fieldkind of
    fkdata: begin
     int2:= dbfieldsize;
     if field1.datatype in charfields then begin
      int2:= int2*4+4; //room for multibyte encodings
      setlength(str1,int2); 
      if not loadfield(fno,fieldtype,pointer(str1),int2) then begin
       clearfieldflag(@buffer.fielddata.nullmask,fno);
      end
      else begin
       if int2 < 0 then begin //buffer to small
        int2:= -int2;
        setlength(str1,int2);
        loadfield(fno,fieldtype,pointer(str1),int2);
       end;
       setlength(str1,int2);
       po2:= pointer(pchar(@buffer) + offset);
       if fieldtype in widecharfields then begin
        setlength(po2^,int2 div 2);
        move(pointer(str1)^,pointer(po2^)^,int2);
       end
       else begin
        try
         if bs_utf8 in fbstate then begin
          po2^:= utf8tostring(str1);
         end
         else begin
          po2^:= msestring(str1);
         end;
        except
         po2^:= converrorstring;
        end;
       end;
       if (dbfieldsize <> 0) and (length(po2^) > dbfieldsize)  then begin
        setlength(po2^,dbfieldsize);
       end;
      end;
     end
     else begin
      if not loadfield(fno,fieldtype,pchar(@buffer)+offset,int2) or
                           (int2 < 0)then begin
       clearfieldflag(@buffer.fielddata.nullmask,fno);        //buffer too small
      end;
     end;
    end;
    fkinternalcalc: begin
     clearfieldflag(@buffer.fielddata.nullmask,fno);
    end;
   end;
  end;
 end;
 result:= grok;
end;

function tmsebufdataset.getfieldbuffer(const afield: tfield;
             out buffer: pointer; out datasize: integer): boolean;
              //read buffer
              //true if not null
var
 int1: integer;
 st1: integer;
begin
 result:= false;
 buffer:= nil;
 if not fopen{active} then begin
  exit;
 end;
 int1:= afield.fieldno - 1;
 if (flookuppo <> nil) and (int1 >= 0) then begin
  buffer:= flookuppo;
  result:= getfieldflag(@precheaderty(buffer)^.fielddata.nullmask,int1);
  inc(pchar(buffer),ffieldinfos[int1].base.offset{ffieldbufpositions[int1]});
  datasize:= ffieldinfos[int1].base.size{ffieldsizes[int1]};
  exit;
 end;
 st1:= ord(state);
 if bs_displaydata in fbstate then begin
  st1:= ord(dsbrowse);
 end;
 case st1 of
  ord(dscalcfields): begin
   buffer:= @pdsrecordty(fcalcbuffer1)^.header;
  end;
  dscheckfilter: begin
   buffer:= @fcheckfilterbuffer^.header;
  end;
  ord(dsfilter): begin
   buffer:= @ffilterbuffer[ffiltereditkind]^.header;
  end;
  ord(dscurvalue): begin
   if (buffercount <= 0) or //probably fetchallblobs()
      (pdsrecordty(activebuffer)^.dsheader.bookmark.data.recordpo <>
                                                             nil) then begin
    buffer:= @fcurrentbuf^.header;
   end
   else begin
    buffer:= @pdsrecordty(activebuffer)^.header; //insert
   end;
  end;
  else begin
   if fbstate * [bs_internalcalc,bs_displaydata] = [bs_internalcalc] then begin
    if int1 < 0 then begin//calc field
     buffer:= @pdsrecordty(activebuffer)^.header;
     //values invalid!
    end
    else begin
     buffer:= @fcurrentbuf^.header;
    end;
   end
   else begin
    if fbstate*[bs_recapplying,bs_displaydata] = [bs_recapplying] then begin
     buffer:= @fnewvaluebuffer^.header;
    end
    else begin
     buffer:= @pdsrecordty(activebuffer)^.header;
    end;
   end;
  end;
 end;
 if int1 >= 0 then begin // data field
  result:= false;
  if state = dsoldvalue then begin
   if getrecordupdatebuffer then begin
    buffer:= fupdatebuffer[fcurrentupdatebuffer].oldvalues;
    if buffer <> nil then begin
     buffer:= @pintrecordty(buffer)^.header;
    end;
   end
   else begin //there is no old value available
    if pdsrecordty(activebuffer)^.dsheader.bookmark.data.recordpo <> nil
                                 then begin //dsinsert otherwise
     buffer:= @fcurrentbuf^.header   
    end;
   end;
  end;
  if buffer <> nil then begin
   result:= getfieldflag(@precheaderty(buffer)^.fielddata.nullmask,int1);
   inc(pchar(buffer),ffieldinfos[int1].base.offset{ffieldbufpositions[int1]});
   datasize:= ffieldinfos[int1].base.size{ffieldsizes[int1]};
  end
  else begin
   datasize:= 0;
  end;
 end
 else begin   
  int1:= -2 - int1;
  if int1 >= 0 then begin //calc field
   result:= getfieldflag(pointer(pchar(buffer)+frecordsize),int1);
   inc(pchar(buffer),fcalcfieldbufpositions[int1]);
   datasize:= fcalcfieldsizes[int1];
  end
  else begin
   buffer:= nil;
   datasize:= 0;
  end;
 end;
end;

function tmsebufdataset.getfieldbuffer(const afield: tfield;
                        const aisnull: boolean; out datasize: integer): pointer;
           //write buffer
var
 int1: integer;
 state1: tdatasetstate;
begin 
 if (bs_recapplying in fbstate) and (state = dsbrowse) then begin
  state1:= dsedit; //dummy
  include(fbstate,bs_curvaluemodified);
 end
 else begin
  if not ((state in dswritemodes - [dsinternalcalc,dscalcfields]) or 
        (afield.fieldkind = fkinternalcalc) and 
                                 (state = dsinternalcalc) or
        (afield.fieldkind = fkcalculated) and 
                                 (state = dscalcfields) or
        (afield.fieldkind = fklookup)
                                 {or 
        (bs_curvaluesetting in fbstate) and (state = dscurvalue)}) then begin
   databaseerrorfmt(snotediting,[name],self);
  end;
  state1:= state;
 end;
 int1:= afield.fieldno-1;
 case state1 of
  dscalcfields: begin
   result:= @pdsrecordty(fcalcbuffer1)^.header;
  end;
  dsfilter:  begin 
   result:= @ffilterbuffer[ffiltereditkind]^.header;
  end;
  dscurvalue: begin
   result:= @fcurrentbuf^.header;
  end;
  else begin
   if bs_internalcalc in fbstate then begin
    if int1 < 0 then begin//calc field
     result:= @pdsrecordty(activebuffer)^.header;
     //values invalid!
    end
    else begin
     result:= @fcurrentbuf^.header;
    end;
   end
   else begin
    if bs_recapplying in fbstate then begin
     result:= @fnewvaluebuffer^.header;
    end
    else begin
     result:= @pdsrecordty(activebuffer)^.header;
    end;
   end;
  end;
 end;
 if int1 >= 0 then begin // data field
  if aisnull then begin
   clearfieldflag(@precheaderty(result)^.fielddata.nullmask,int1);
  end
  else begin
   setfieldflag(@precheaderty(result)^.fielddata.nullmask,int1);
  end;
  inc(pchar(result),ffieldinfos[int1].base.offset{ffieldbufpositions[int1]});
  datasize:= ffieldinfos[int1].base.size{ffieldsizes[int1]};
 end
 else begin
  int1:= -2 - int1;
  if int1 >= 0 then begin //calc field
   if aisnull then begin
    clearfieldflag(pbyte(pchar(result)+frecordsize),int1);
   end
   else begin
    setfieldflag(pbyte(pchar(result)+frecordsize),int1);
   end;
   inc(pchar(result),fcalcfieldbufpositions[int1]);
   datasize:= fcalcfieldsizes[int1];
  end
  else begin
   result:= nil;
   datasize:= 0;
  end;
 end;
end;

procedure tmsebufdataset.fieldchanged(const field: tfield);
begin
 if {(field.fieldno > 0) and} not 
       (state in [dscalcfields,dsinternalcalc,{dsfilter,}dsnewvalue]) and
                 not (bs_recapplying in fbstate) then begin
  dataevent(defieldchange, ptrint(field));
 end;
end;

function tmsebufdataset.getfielddata(field: tfield; buffer: pointer): boolean;
var 
 po1: pointer;
 datasize: integer;
begin
 result:= getfieldbuffer(field,po1,datasize);
 if (buffer <> nil) and result then begin 
  move(po1^,buffer^,datasize);
 end;
end;

function tmsebufdataset.getfielddata(field: tfield; buffer: pointer;
                         nativeformat: boolean): boolean;
begin
 result:= getfielddata(field,buffer);
end;

function tmsebufdataset.getmsestringdata(const sender: tmsestringfield;
               out avalue: msestring): boolean;
var
 po1: pointer;
 int1: integer;
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(sender) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  if fvalidating then begin
   result:= (fvaluebuffer <> nil) and (foffset and 1 = 0);
   po1:= fvaluebuffer;
  end
  else begin
   result:= getfieldbuffer(sender,po1,int1);
  end;
 end;
 if result then begin
  avalue:= msestring(po1^);
 end
 else begin
  avalue:= '';
 end;
end;

function tmsebufdataset.getvardata(const sender: tmsevariantfield;
               out avalue: variant): boolean;
var
 po1: pvariant;
 int1: integer;
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(sender) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  if fvalidating then begin
   result:= (fvaluebuffer <> nil) and (foffset and 1 = 0);
   po1:= fvaluebuffer;
  end
  else begin
   result:= getfieldbuffer(sender,pointer(po1),int1);
  end;
 end;
 if result then begin
  avalue:= po1^;
 end
 else begin
  avalue:= null;
 end;
end;

procedure tmsebufdataset.checkfreebuffer(const afield: tfield);
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(afield) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  if foffset and 2 <> 0 then begin
   freemem(fvaluebuffer);
   fvaluebuffer:= nil;
  end;
 end;
end;

function tmsebufdataset.callvalidate(const afield: tfield;
                              const avalue: pointer): boolean;
              //true if not nulled
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(afield) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  foffset:= 0;
  fvaluebuffer:= avalue;
  afield.validate(avalue);
  result:= (avalue <> nil) and (foffset and 1 = 0);
 end;
end;

procedure tmsebufdataset.checkvaluebuffer(const afield: tfield;
                                                   const asize: integer);
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(afield) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  foffset:= foffset and not 1;
  if fvaluebuffer = nil then begin
   getmem(fvaluebuffer,asize);
   fillchar(fvaluebuffer^,asize,0);
   foffset:= foffset or 2;
  end;
 end;
end;

procedure tmsebufdataset.setfielddata(field: tfield; buffer: pointer);

var 
 po1: pointer;
 datasize1: integer;
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(field) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  if fvalidating then begin
   if buffer = nil then begin
    foffset:= foffset or 1;
   end
   else begin
    getfieldbuffer(field,po1,datasize1); //get data size
    checkvaluebuffer(field,datasize1);
    move(buffer^,fvaluebuffer^,datasize1);
   end;
  end
  else begin
   try
    if callvalidate(field,buffer) then begin
     po1:= getfieldbuffer(field,false,datasize1);
     move(fvaluebuffer^,po1^,datasize1);
    end
    else begin
     po1:= getfieldbuffer(field,true,datasize1);
     case field.datatype of
      ftstring: begin
       pmsestring(po1)^:= '';
      end;
      ftvariant: begin
       freedbvariant(pvariant(po1)^);
      end;
      else begin
       fillchar(po1^,datasize1,0);
      end;
     end;
    end;
   finally
    checkfreebuffer(field);
   end;
   fieldchanged(field);
  end;
 end;
end;

procedure tmsebufdataset.setfielddata(field: tfield; buffer: pointer;
                                                  nativeformat: boolean);
begin
 setfielddata(field,buffer);
end;

procedure tmsebufdataset.setmsestringdata(const sender: tmsestringfield;
               avalue: msestring);
var
 po1: pmsestring;
 int1: integer;
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(sender) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  if fvalidating then begin
   checkvaluebuffer(sender,sizeof(msestring));
   pmsestring(fvaluebuffer)^:= avalue;
  end
  else begin
   try
    if callvalidate(sender,@avalue) then begin
     po1:= getfieldbuffer(sender,false,int1);
     po1^:= pmsestring(fvaluebuffer)^;
     if (sender.characterlength > 0) and 
                         (length(avalue) > sender.characterlength) then begin
      setlength(msestring(po1^),sender.characterlength);
     end;
    end
    else begin
     po1:= getfieldbuffer(sender,true,int1);
     po1^:= '';
    end;
   finally
    pmsestring(fvaluebuffer)^:= '';
    checkfreebuffer(sender);    
   end;
   fieldchanged(sender);
  end;
 end;
end;

procedure tmsebufdataset.setvardata(const sender: tmsevariantfield;
               avalue: variant);
var
 po1: pvariant;
 int1: integer;
begin
 {$ifdef FPC}{$warnings off}{$endif}
 with tfield1(sender) do begin
 {$ifdef FPC}{$warnings on}{$endif}
  if fvalidating then begin
   checkvaluebuffer(sender,sizeof(variant));
   pvariant(fvaluebuffer)^:= avalue;
  end
  else begin
   try
    if callvalidate(sender,@avalue) then begin
     po1:= getfieldbuffer(sender,false,int1);
     po1^:= pvariant(fvaluebuffer)^;
    end
    else begin
     po1:= getfieldbuffer(sender,true,int1);
     finalize(po1^);
     fillchar(po1^,sizeof(variant),0);
    end;
   finally
    finalize(pvariant(fvaluebuffer)^);
    checkfreebuffer(sender);    
   end;
   fieldchanged(sender);
  end;
 end;
end;

procedure tmsebufdataset.getnewupdatebuffer;
begin
 setlength(fupdatebuffer,high(fupdatebuffer)+2);
 fcurrentupdatebuffer:= high(fupdatebuffer);
end;

procedure tmsebufdataset.internaldelete;
var
 po1: pintrecordty;
 recnobefore: integer;
begin
 if state = dsedit then begin
  internalcancel;
 end;
 po1:= fcurrentbuf;
 recnobefore:= frecno;
 deleterecord(frecno);
 if not (dso_noapply in fcontroller.options) then begin
  if not getrecordupdatebuffer then begin
   getnewupdatebuffer;
   with fupdatebuffer[fcurrentupdatebuffer] do begin
    info.bookmark.recno:= recnobefore;
    info.bookmark.recordpo:= po1;
    oldvalues:= info.bookmark.recordpo;
   end;
  end
  else begin
   with fupdatebuffer[fcurrentupdatebuffer] do begin
    intfreerecord(info.bookmark.recordpo);
    if info.updatekind = ukmodify then begin
     info.bookmark.recordpo:= oldvalues;
    end
    else begin //ukinsert
     info.bookmark.recordpo := nil;  //this 'disables' the updatebuffer
    end;
   end;
  end;
  fupdatebuffer[fcurrentupdatebuffer].info.updatekind := ukdelete;
  if flogger <> nil then begin
   logupdatebuffer(flogger,fupdatebuffer[fcurrentupdatebuffer],po1,true,lf_update);
   flogger.flushbuffer;
  end;
 end;
end;

procedure tmsebufdataset.applyrecupdate(updatekind : tupdatekind);
begin
 raise edatabaseerror.create(sapplyrecnotsupported);
end;

procedure tmsebufdataset.cancelrecupdate(var arec: recupdatebufferty);
begin
 if (flogger <> nil) and not (bs_loading in fbstate) then begin
  logupdatebuffer(flogger,arec,nil,true,lf_cancel);
  flogger.flushbuffer;
 end;
 with arec do begin
  if info.bookmark.recordpo <> nil then begin
   if info.updatekind = ukmodify then begin
    freeblobs(info.bookmark.recordpo^.header.blobinfo);
    finalizevalues(info.bookmark.recordpo^.header);
    move(oldvalues^.header,info.bookmark.recordpo^.header,frecordsize);
    freemem(oldvalues); //no finalize
   end
   else begin
    if info.updatekind = ukdelete then begin
     insertrecord(info.bookmark.recno,info.bookmark.recordpo);
    end
    else begin
     if info.updatekind = ukinsert then begin
      deleterecord(info.bookmark.recordpo);
      if info.bookmark.recordpo = fcurrentbuf then begin
       fcurrentbuf:= nil;
       if frecno >= 0 then begin
        dec(frecno);
       end;
      end;
      intfreerecord(info.bookmark.recordpo);
     end;
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.cancelupdate(const norecordcancel: boolean = false);
var 
 int1: integer;
begin
 cancel;
 checkbrowsemode;
 if (fupdatebuffer <> nil) and (frecno >= 0) then begin
  for int1:= high(fupdatebuffer) downto 0 do begin
   if fupdatebuffer[int1].info.bookmark.recordpo = fcurrentbuf then begin
    if not norecordcancel then begin
     cancelrecupdate(fupdatebuffer[int1]);
    end
    else begin
     with fupdatebuffer[int1] do begin
      intFreeRecord(OldValues);
      info.bookmark.recordpo:= nil
     end;
    end;
    deleteitem(fupdatebuffer,typeinfo(recupdatebufferarty),int1);
    if int1 <= fapplyindex then begin
     dec(fapplyindex);
    end;
    resync([]);
    break;
   end;
  end;
 end;
end;

procedure tmsebufdataset.cancelupdates;
var
 int1: integer;
begin
 cancel;
 checkbrowsemode;
 if high(fupdatebuffer) >= 0 then begin
  for int1:= high(fupdatebuffer) downto 0 do begin
   cancelrecupdate(fupdatebuffer[int1]);
  end;
  fupdatebuffer:= nil;
  resync([]);
 end;
end;

procedure tmsebufdataset.SetOnUpdateError(const AValue: updateerroreventty);

begin
  FOnUpdateError := AValue;
end;

procedure tmsebufdataset.recupdatebufferapplied(const abuf: precupdatebufferty);
begin
 if flogger <> nil then begin
  logupdatebuffer(flogger,abuf^,nil,true,lf_apply);
  flogger.flushbuffer;
 end;
 intFreeRecord(abuf^.OldValues);
 abuf^.info.bookmark.recordpo:= nil;
end;

procedure tmsebufdataset.packrecupdatebuffer;
var
 int1,int2: integer;
begin
 int2:= 0;
 for int1:= 0 to high(fupdatebuffer) do begin //pack
  with fupdatebuffer[int1] do begin
   if (info.bookmark.recordpo <> nil) or (oldvalues <> nil) then begin
    fupdatebuffer[int2]:= fupdatebuffer[int1];
    inc(int2);
   end;
  end;
 end;
 setlength(fupdatebuffer,int2);
end;

procedure tmsebufdataset.restorerecupdatebuffer;
var
 int1: integer;
begin
 for int1:= high(fupdatebuffer) downto 0 do begin
  exclude(fupdatebuffer[int1].info.flags,ruf_applied);
 end;
end;

procedure tmsebufdataset.postrecupdatebuffer;
var
 po1: precupdatebufferty;
 int1,int2: integer;
begin
 int2:= 0;
 for int1:= high(fupdatebuffer) downto 0 do begin
  po1:= @fupdatebuffer[int1];
  with po1^ do begin
   if (ruf_applied in info.flags) and (info.bookmark.recordpo <> nil) then begin
    inc(int2);
    recupdatebufferapplied(po1);
   end;
  end;
 end;
 if int2 = length(fupdatebuffer) then begin
  fupdatebuffer:= nil;
 end
 else begin
  packrecupdatebuffer;
 end;
end;

procedure tmsebufdataset.internalapplyupdate(const maxerrors: integer;
               const cancelonerror: boolean; 
               const cancelondeleteerror: boolean;
               out response: resolverresponsesty);
               
 procedure checkrevert;
 var
  po1: precupdatebufferty;
 begin
  po1:= @fupdatebuffer[fcurrentupdatebuffer];
  if rr_applied in response then begin
   if bs1_deferdeleterecupdatebuffer in fbstate1 then begin
    include(po1^.info.flags,ruf_applied);
   end
   else begin
    recupdatebufferapplied(po1);
   end;
  end
  else begin
   if (cancelonerror or 
       cancelondeleteerror and (po1^.info.updatekind = ukdelete)) or
                                         (rr_revert in response) then begin
    cancelrecupdate(po1^);
    po1^.info.bookmark.recordpo:= nil;
    exclude(fbstate,bs_curvaluemodified);
   end;
  end;
 end; //checkrevert
 
var
 by1,by2: boolean;
 e1: exception;
 ar1,ar2,ar3: integerarty;
// int1: integer;
 origpo: pintrecordty;
 
begin
 include(fbstate,bs_recapplying);
 by1:= not islocal;
 by2:= false;
 response:= [];
 with fupdatebuffer[fcurrentupdatebuffer] do begin
  origpo:= info.bookmark.recordpo;
  move(origpo^.header,fnewvaluebuffer^.header,frecordsize);
  addrefvalues(fnewvaluebuffer^.header);
  try
   repeat
    exclude(fbstate,bs_curvaluemodified);
    getcalcfields(pchar(fnewvaluebuffer));
    if rr_again in response then begin
     dec(ffailedcount);
     exclude(info.flags,ruf_error);
    end;
    Response:= [rr_applied];
    try
     try
      if by1 then begin
       ApplyRecUpdate(info.UpdateKind);
      end;
     except
      on E: EDatabaseError do begin
       include(info.flags,ruf_error);
       e1:= e;
       Inc(fFailedCount);
       if e is eapplyerror then begin
        response:= eapplyerror(e).response;
       end
       else begin
        if longword(ffailedcount) > longword(MaxErrors) then begin
         Response:= [rr_abort]
        end
        else begin
         Response:= [];
        end;
       end;
       e.message:= 'An error occured while applying the updates in a record: '+
                               e.message;
       if checkcanevent(self,tmethod(OnUpdateError)) then begin
        OnUpdateError(Self,edatabaseerror(e1),info.UpdateKind,Response);
        if rr_applied in response then begin
         dec(ffailedcount);
        end;
       end;
       if rr_abort in response then begin
        checkrevert;
        if not (rr_quiet in response) then begin
         if e = e1 then begin
          raise;
         end
         else begin
          if e1 <> nil then begin
           Raise e1;
          end;
         end;
        end;
       end;
      end
      else begin
       raise;
      end;
     end;
    finally
     if bs_curvaluemodified in fbstate then begin
      by2:= true;
//      if (updatekind = ukmodify) and 
//                          (bs_refreshupdateindex in fbstate) or
//      (updatekind = ukinsert) and 
//                          (bs_refreshinsertindex in fbstate) then begin
//       int1:= factindex;
 //      factindex:= -1; //do not use recno

      saveindex(origpo,@fnewvaluebuffer^.header,ar1,ar2,ar3);
      relocateindex(origpo,ar1,ar2,ar3);
 //      factindex:= int1;
//      end;
     end;
    end;
   until response <> [rr_again];
   checkrevert;
  finally
   exclude(fbstate,bs_recapplying);
   if by2 and (info.updatekind <> ukdelete) then begin
    include(fbstate1,bs1_needsresync);
    finalizevalues(origpo^.header);
    move(fnewvaluebuffer^.header,origpo^.header,frecordsize);
   end
   else begin
    finalizevalues(fnewvaluebuffer^.header);
   end;
   finalizecalcvalues(fnewvaluebuffer^.header);
  end;
 end;
end;

procedure tmsebufdataset.afterapply;
begin
 //dummy
end;

procedure tmsebufdataset.editapplyerror(const arecupdatenum: integer);
var
 po1: pintrecordty;
 info1: recupdatebufferty;
begin
 disablecontrols;
 try
  info1:= fupdatebuffer[arecupdatenum];
  with info1 do begin
   if  (info.updatekind = ukdelete) or findbookmark(info.bookmark) then begin
    po1:= nil;
    if info.updatekind in [ukinsert,ukmodify] then begin
     po1:= intallocrecord;
     move(fcurrentbuf^.header,po1^.header,frecordsize);
     addrefvalues(po1^.header);
    end;
    try
     cancelrecupdate(info1);
     resync([]);
     deleteitem(fupdatebuffer,typeinfo(recupdatebufferarty),arecupdatenum);
     if info.updatekind = ukdelete then begin
      findbookmark(info.bookmark)
     end
     else begin
      if info.updatekind in [ukmodify,ukinsert] then begin
       if info.updatekind = ukmodify then begin
        edit;
       end
       else begin
        insert;
       end;
       finalizevalues(pdsrecordty(activebuffer)^.header);
       finalizecalcvalues(pdsrecordty(activebuffer)^.header);
       move(po1^,pdsrecordty(activebuffer)^.header,frecordsize);
       freemem(po1);
       setmodified(true);
       getcalcfields(activebuffer);
      end; 
     end;
    except
     if po1 <> nil then begin
      intfreerecord(po1);
     end;
     raise;
    end;
   end;
  end;
 finally
  enablecontrols;
 end;
end;

procedure tmsebufdataset.applyupdate(const cancelonerror: boolean;
               const cancelondeleteerror: boolean = false;
                                    const editonerror: boolean = false);
                                               //applies current record
var
 response: resolverresponsesty;
 canedit1: boolean;
 recupdatebuffernum1: integer;
begin
 if not (bs_applying in fbstate) then begin
  include(fbstate,bs_applying);
  try
   canedit1:= false;
   checkbrowsemode;
   dobeforeapplyupdate;
   checkbrowsemode;
   if getrecordupdatebuffer then begin
    canedit1:= editonerror;
    if canedit1 then begin
     recupdatebuffernum1:= fcurrentupdatebuffer;
    end;
    ffailedcount:= 0;
    exclude(fbstate1,bs1_needsresync);
    try
     internalapplyupdate(0,cancelonerror,cancelondeleteerror,response);
     if rr_applied in response then begin
      canedit1:= false;
     end;
    finally
     if (fcurrentupdatebuffer <= high(fupdatebuffer)) and //???
      (FUpdateBuffer[fcurrentupdatebuffer].info.Bookmark.recordpo = nil) then begin
      deleteitem(fupdatebuffer,typeinfo(recupdatebufferarty),fcurrentupdatebuffer);
      canedit1:= false;
     end;
     if bs1_needsresync in fbstate1 then begin
      resync([]);
     end;
    end;
    if rr_applied in response then begin
     afterapply; //possible commit
    end;
   end;
   doafterapplyupdate;
  finally
   exclude(fbstate,bs_applying);
   if canedit1 then begin
    editapplyerror(recupdatebuffernum1);
   end;
  end;
 end;
end;

procedure tmsebufdataset.ApplyUpdates(const MaxErrors: Integer; 
                             const cancelonerror: boolean;
                             const cancelondeleteerror: boolean = false;
                             const editonerror: boolean = false);
var
 recnobefore: integer;
 response: resolverresponsesty;
 bo1: boolean;
 canedit1: boolean;
 recupdatenum1: integer;

begin
 if not (bs_applying in fbstate) then begin
  include(fbstate,bs_applying);
  canedit1:= false;
  try
   CheckBrowseMode;
   dobeforeapplyupdate;
   CheckBrowseMode;
   disablecontrols;
   recnobefore:= frecno;
   try
    fapplyindex := 0;
    fFailedCount := 0;
    bo1:= false;
    response:= [];
    while (fapplyindex <= high(FUpdateBuffer)) and not(rr_abort in response) do begin
     canedit1:= editonerror;
     fcurrentupdatebuffer:= fapplyindex;
     recupdatenum1:= fcurrentupdatebuffer;
     with fupdatebuffer[fcurrentupdatebuffer] do begin
      if (info.bookmark.recordpo <> nil) and not (ruf_applied in info.flags) then begin
       internalapplyupdate(maxerrors,cancelonerror,
                                       cancelondeleteerror,response);
       bo1:= bo1 or not (rr_applied in response);
       if rr_applied in response then begin
        canedit1:= false;
       end;
      end;
     end;
     inc(fapplyindex);
 //     if (bs_idle in fbstate) and not application.idle then begin
 //      break;
 //     end;
                //win98 is not idle after applyupdate ???
    end;
   finally 
    fcurrentupdatebuffer:= bigint; //invalid
    if not (bs1_deferdeleterecupdatebuffer in fbstate1) then begin
     if (ffailedcount = 0) and (fapplyindex > high(fupdatebuffer)) then begin
      fupdatebuffer:= nil;
     end
     else begin
      packrecupdatebuffer;
     end;
    end;
    if active then begin
     internalsetrecno(recnobefore);
     resync([]);
     enablecontrols;
    end
    else begin
     enablecontrols;
    end;
   end;
   if not bo1 then begin
    afterapply; //possible commit
   end;
   doafterapplyupdate;
  finally
   exclude(fbstate,bs_applying);
   if canedit1 then begin
    editapplyerror(recupdatenum1);
   end;
  end;
 end;
end;

procedure tmsebufdataset.ApplyUpdates(const maxerrors: integer = 0);
begin
 applyupdates(maxerrors,false);
end;

procedure tmsebufdataset.applyupdate;
begin
 applyupdate(false);
end;

procedure tmsebufdataset.saveindex(const oldbuffer,newbuffer: pintrecordty;
                                            var ar1,ar2,ar3: integerarty);
var
 int1: integer;
 lastind: integer;
begin
 if (bs_indexvalid in fbstate) then begin
  setlength(ar1,findexlocal.count);
  setlength(ar2,length(ar1));
  setlength(ar3,length(ar1));
  for int1:= high(ar1) downto 0 do begin
   with findexlocal[int1] do begin
    lastind:= high(findexfieldinfos);
    ar2[int1]:= compare1(oldbuffer,newbuffer,lastind,false);
    if ar2[int1] <> 0 then begin
     if int1 = factindex - 1 then begin
      ar1[int1]:= frecno + 1; //for fast find of bufpo
     end
     else begin
      ar1[int1]:= findboundary(oldbuffer,lastind,true); //old boundary
     end;
     ar3[int1]:= findboundary(newbuffer,lastind,true); //new boundary
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.relocateindex(const abuffer: pintrecordty;
                                        const ar1,ar2,ar3: integerarty);
var
 int1,int2,int3: integer;
begin
 if bs_indexvalid in fbstate then begin
//  with pdsrecordty(activebuffer)^ do begin
  for int1:= high(ar1) downto 0 do begin
   if ar2[int1] <> 0 then begin // position changed
    include(fbstate1,bs1_needsresync);
    int2:= ar3[int1];           //new boundary
    with findexes[int1+1] do begin
     for int3:= ar1[int1] - 1 downto 0 do begin
      if ind[int3] = abuffer then begin //update indexes
       move(ind[int3+1],ind[int3],(fbrecordcount-int3-1)*sizeof(pointer));
       if int3 < int2 then begin
        dec(int2);
       end;
       move(ind[int2],ind[int2+1],(fbrecordcount-int2-1)*sizeof(pointer));
       ind[int2]:= abuffer;
       if (int1 = factindex - 1) then begin
        frecno:= int2;
       end;
       break;
      end;
     end;
    end;
   end;
  end;
 end
 else begin
//  if factindex > 0 then begin
//   include(fbstate1,bs1_needsresync);
//  end;
 end;
// end;
end;

procedure tmsebufdataset.internalpost;
var
 po1,po2: pblobinfoarty;
 po3: pointer;
 int1{,int2,int3}: integer;
 bo1: boolean;
 ar1,ar2,ar3: integerarty;
 newupdatebuffer: boolean;
 canapply: boolean;
 
begin
 checkindex(false); //needed for first append
 with pdsrecordty(activebuffer)^ do begin
  bo1:= false;
  if state = dsinsert then begin
   fcurrentbuf:= intallocrecord;
  end;
  canapply:= not (dso_noapply in fcontroller.options);
  if canapply then begin
   newupdatebuffer:= not getrecordupdatebuffer;
   if newupdatebuffer then begin
    getnewupdatebuffer;
    with fupdatebuffer[fcurrentupdatebuffer] do begin
     info.bookmark.recordpo:= fcurrentbuf;
     info.bookmark.recno:= frecno;
     if state = dsedit then begin
      oldvalues:= intallocrecord;
      move(info.bookmark.recordpo^,oldvalues^,frecordsize+intheadersize);
      addrefvalues(oldvalues^.header);
      po1:= getintblobpo;
      if po1^ <> nil then begin
       po2:= @oldvalues^.header.blobinfo;
       pointer(po2^):= nil;
       setlength(po2^,length(po1^));
       for int1:= high(po1^) downto 0 do begin //copy blobs
        po2^[int1]:= po1^[int1];
        with po2^[int1] do begin
         if datalength > 0 then begin
          getmem(po3,datalength);
          move(data^,po3^,datalength);
          data:= po3;
         end
         else begin
          data:= nil;
         end;
        end;
       end;
      end;
      info.updatekind := ukmodify;
     end
     else begin
      info.updatekind := ukinsert;
     end;
    end;
   end;
  end;
  
  with header do begin
   for int1:= high(blobinfo) downto 0 do begin
    with blobinfo[int1] do begin
     if new then begin
      deleteblob(fcurrentbuf^.header.blobinfo,field,false);
                            //no reassign of blobinfo
      new:= false;
      bo1:= true;
     end;
    end;
   end;
  end;

  if (state = dsedit) then begin
   saveindex(fcurrentbuf,@header,ar1,ar2,ar3);
  end;   
  if bo1 then begin
   fcurrentbuf^.header.blobinfo:= nil; //free old array
  end;
  finalizevalues(fcurrentbuf^.header);
  move(header,fcurrentbuf^.header,frecordsize); //get new field values

  if (flogger <> nil) and canapply then begin
   logrecbuffer(flogger,fupdatebuffer[fcurrentupdatebuffer].info.updatekind,
                     fcurrentbuf);
   if newupdatebuffer then begin
    logupdatebuffer(flogger,fupdatebuffer[fcurrentupdatebuffer],nil,true,
                           lf_update);
   end;
   flogger.flushbuffer;
  end;
  
  if state = dsinsert then begin
   with dsheader.bookmark do  begin
    frecno:= insertrecord(frecno,fcurrentbuf);
    fcurrentbuf:= factindexpo^.ind[frecno];
    data.recordpo:= fcurrentbuf;
    data.recno:= frecno;
    flag := bfinserted;
   end;      
  end
  else begin
   if (state = dsedit) then begin
    relocateindex(fcurrentbuf,ar1,ar2,ar3);
    dsheader.bookmark.data.recno:= frecno;
   end;
  end;
 end;
 fbstate:= fbstate - [bs_editing,bs_append];
end;

procedure tmsebufdataset.internalcancel;
var
 int1: integer;
 bo1: boolean;
begin
 with pdsrecordty(activebuffer)^,header do begin
  finalizevalues(header);
  bo1:= false;
  for int1:= high(blobinfo) downto 0 do begin
   if blobinfo[int1].new then begin
    deleteblob(blobinfo,int1,true);
    bo1:= true;
   end;
  end;
  if bo1 then begin
   blobinfo:= nil; //free copy
  end;
 end;
 fbstate:= fbstate - [bs_editing,bs_append];
end;

procedure tmsebufdataset.FreeFieldBuffers;
begin
 //dummy
end;

function comparefieldnum(const l,r): integer;
begin
 result:= tfield(l).fieldno - tfield(r).fieldno;
end;

procedure tmsebufdataset.calcrecordsize;

 procedure addfield(const aindex: integer; const datatype: tfieldtype;
                        const asize: integer; const afield: tfield);
 begin
  with ffieldinfos[aindex] do begin
   base.offset:= frecordsize;
   base.size:= getfieldsize(datatype,asize,ext.basetype);
   if ext.basetype = ftvariant then begin
    additem(fvarpositions,frecordsize);
   end;
   if ext.basetype = ftwidestring then begin
    additem(fstringpositions,frecordsize);
    base.dbfieldsize:= asize;     //max size
   end
   else begin
    base.dbfieldsize:= base.size;
   end;
   base.fieldtype:= datatype;        //used for savetostream;
   ext.field:= afield;
   ext.uppername:= uppercase(afield.fieldname);
   inc(frecordsize,base.size);
   alignfieldpos(frecordsize);
  end;
 end; //addfield

var
 lookuprecursion: integer;
 
 function getbasetype(const afield: tfield): tfieldtype;
 var
  field1: tfield;
 begin
  inc(lookuprecursion);
  if lookuprecursion > 16 then begin
   databaseerror(name+': Recursive lookup field "'+afield.fieldname+'".');
  end;
  result:= ftunknown;
  if afield.dataset is tmsebufdataset then begin
   if (afield.fieldkind = fklookup) and 
                 (afield.lookupdataset <> nil) and 
                          (afield.lookupresultfield <> '') then begin
    field1:= afield.lookupdataset.findfield(afield.lookupresultfield);
    if field1 <> nil then begin
     result:= getbasetype(field1);
    end;
   end
   else begin
    getfieldsize(afield.datatype,0,result);
   end;
  end;
 end; //getbasetype
 
var 
 int1,int2,int3,int4: integer;
 field1: tfield;
 ar1: fieldarty;
 ar2: stringarty;
 bo1: boolean;
begin
 fcalcfieldcount:= 0;
 finternalcalcfieldcount:= 0;
 for int1:= fields.count - 1 downto 0 do begin
  with fields[int1] do begin
   if fieldkind in dsbuffieldkinds then begin
    inc(fcalcfieldcount);
   end;
   if fieldkind = fkinternalcalc then begin
    inc(finternalcalcfieldcount);
   end;
  end;
 end;
 int1:= fielddefs.count+finternalcalcfieldcount;
 frecordsize:= sizeof(blobinfoarty);
 fnullmasksize:= (int1+7) div 8;
 inc(frecordsize,fnullmasksize);
 alignfieldpos(frecordsize);
 
 setlength(ffieldinfos,int1);
 fstringpositions:= nil;
 fvarpositions:= nil;
 for int1:= 0 to fielddefs.count - 1 do begin
  with fielddefs[int1] do begin
   field1:= fields.findfield(name);
   if (field1 <> nil) and (field1.fieldkind = fkdata) then begin
    if fieldno = 0 then begin
{$warnings off}
     tfield1(field1).ffieldno:= int1 + 1; //local mode without connection
{$warnings on}
    end;
    addfield(int1,datatype,size,field1);
   end;
  end;
 end;
 int2:= fielddefs.count;
 for int1:= 0 to fields.count -1 do begin
  field1:= fields[int1];
  with field1 do begin
   if fieldkind = fkinternalcalc then begin
    addfield(int2,datatype,size,field1);
{$warnings off}
    tfield1(field1).ffieldno:= int2 + 1;
{$warnings on}
    inc(int2);
   end;
  end;
 end;
 setlength(fcalcfieldbufpositions,fcalcfieldcount);
 flookupfieldinfos:= nil;
 setlength(flookupfieldinfos,fcalcfieldcount);
 setlength(fcalcfieldsizes,fcalcfieldcount);
 fcalcstringpositions:= nil;
 fcalcvarpositions:= nil;
 fcalcrecordsize:= frecordsize;
 fcalcnullmasksize:= (fcalcfieldcount+7) div 8;
 inc(fcalcrecordsize,fcalcnullmasksize);
 alignfieldpos(fcalcrecordsize);
 int2:= 0;
 setlength(ar1,fields.count);
 for int1:= fields.count - 1 downto 0 do begin
  field1:= fields[int1];
  ar1[int1]:= field1;
  with field1 do begin
   if fieldkind in dsbuffieldkinds then begin
{$warnings off}
    tfield1(field1).ffieldno:= -1 - int2;
{$warnings on}
    fcalcfieldbufpositions[int2]:= fcalcrecordsize;
    if field1 is tmsestringfield then begin
     additem(fcalcstringpositions,fcalcrecordsize);
    end;
    if field1 is tmsevariantfield then begin
     additem(fcalcvarpositions,fcalcrecordsize);
    end;
    fcalcfieldsizes[int2]:= datasize;
    with flookupfieldinfos[int2] do begin
     valuefield:= field1;
     indexnum:= -1;
     if (fieldkind = fklookup) and not lookupcache and 
                             (lookupdataset is tmsebufdataset) then begin
      if findfields(field1.keyfields,keyfieldar) and 
                                      (keyfieldar <> nil) then begin
       with tmsebufdataset(lookupdataset) do begin
        lookupvaluefield:= findfield(field1.lookupresultfield);
        if lookupvaluefield <> nil then begin
         ar2:= splitstring(lookupkeyfields,';',true);
         if high(ar2) = high(keyfieldar) then begin
          for int3:= 0 to indexlocal.count - 1 do begin
           with indexlocal[int3] do begin
            if fields.count > high(keyfieldar) then begin
             bo1:= true;
             for int4:= 0 to high(keyfieldar) do begin
              if not sametext(fields[int4].fieldname,ar2[int4]) then begin
               bo1:= false;
               break;
              end;
             end;
             if bo1 then begin
              indexnum:= int3;
              lookuprecursion:= 0;
              basedatatype:= getbasetype(lookupvaluefield);
              case basedatatype of
               ftwidestring: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmstring;
               end;
               ftguid: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmguid;
               end;
               ftinteger: begin
                getvalue:= {$ifdef FPC}@{$endif}getbminteger;
               end;
               ftboolean: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmboolean;
               end;
               ftbcd: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmcurrency;
               end;
               ftfloat: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmfloat;
               end;
               ftlargeint: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmlargeint;
               end;
               ftdatetime: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmdatetime;
               end;
               ftvariant: begin
                getvalue:= {$ifdef FPC}@{$endif}getbmvariant;
               end;
               else begin
                indexnum:= -1;
               end;
              end;
             end;
             adduniqueitem(pointerarty(flookupclients),pointer(self));
             adduniqueitem(pointerarty(self.flookupmasters),
                                              pointer(lookupdataset));
             break;
            end
           end;
          end;
         end;
        end;
       end;
      end;
      if indexnum < 0 then begin
       databaseerror(self.name+', '+name+': no loookup index for KeyFields "'+
                         keyfields+'" LookupKeyFields "'+lookupkeyfields+'".');
      end;
     end;
    end;
    inc(fcalcrecordsize,fcalcfieldsizes[int2]);
    alignfieldpos(fcalcrecordsize);
    inc(int2);
   end;
  end;
 end; 
 mergesortarray(ar1,sizeof(ar1[0]),length(ar1),@comparefieldnum,
                                                          ffieldorder,false);
   //MS SQL ODBC needs ordered load field
end;

function tmsebufdataset.getrecordsize : word;
begin
 result:= frecordsize;
end;

function tmsebufdataset.getchangecount: integer;
begin
 result:= length(fupdatebuffer);
end;

function tmsebufdataset.getapplyerrorcount: integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(fupdatebuffer) do begin
  if ruf_error in fupdatebuffer[int1].info.flags then begin
   inc(result);
  end;
 end;
end;

procedure tmsebufdataset.setrecno1(value: longint; const nocheck: boolean);
var
 bm: bufbookmarkty;
begin
 checkbrowsemode;
 if value > recordcount then begin
  repeat
  until (getnextpacket(bs_fetchall in fbstate) < fpacketrecords) or 
                       (value <= recordcount) or (bs_fetchall in fbstate);
 end;
 if nocheck then begin
  if value > fbrecordcount then begin
   value:= fbrecordcount;
  end;
  if value < 1 then begin
   exit;
  end;
 end;
 checkrecno(value);
 bm.data.recordpo:= nil;
 bm.data.recno:= value-1;
 if nocheck then begin
  try
   gotobookmark(@bm);
  except        //catch exception by filter
   resync([]); //record not found
  end;
 end
 else begin
  gotobookmark(@bm);
 end;
end;

procedure tmsebufdataset.setrecno(value: longint);
begin
 setrecno1(value,false);
end;

function tmsebufdataset.getrecno: longint;
begin
 if bs_internalcalc in fbstate then begin
  result:= frecno + 1;
 end
 else begin
  result:= 0;
  if activebuffer <> nil then begin
   with pdsrecordty(activebuffer)^.dsheader.bookmark do begin
    if state = dsinsert  then begin
     if (bs_append in fbstate) or (fbrecordcount = 0) then begin
      result:= fbrecordcount + 1;
     end
     else begin
      result:= data.recno + 1;
     end;
    end
    else begin
     if fbrecordcount > 0 then begin
      result:= data.recno + 1;
     end;
    end;
   end;
  end;
 end;
end;

function tmsebufdataset.iscursoropen: boolean;
begin
 result:= fopen;
end;

function tmsebufdataset.getrecordcount: longint;
begin
 result:= fbrecordcount;
end;

function tmsebufdataset.updatestatus(out aflags: recupdateflagsty): tupdatestatus;
begin
 aflags:= [];
 result:= usunmodified;
 if getrecordupdatebuffer then begin
  with fupdatebuffer[fcurrentupdatebuffer] do begin
   aflags:= info.flags;
   case info.updatekind of
    ukmodify : result := usmodified;
    ukinsert : result := usinserted;
    ukdelete : result := usdeleted;
   end;
  end;
 end;
end;

function tmsebufdataset.updatestatus: tupdatestatus;
var
 stat1: recupdateflagsty;
begin
 result:= updatestatus(stat1);
end;

{
Function tmsebufdataset.Locate(const KeyFields: string; const KeyValues: Variant; options: TLocateOptions) : boolean;


  function CompareText0(substr, astr: pchar; len : integer; options: TLocateOptions): integer;

  var
    i : integer; Chr1, Chr2: byte;
  begin
    result := 0;
    i := 0;
    chr1 := 1;
    while (result=0) and (i<len) and (chr1 <> 0) do
      begin
      Chr1 := byte(substr[i]);
      Chr2 := byte(astr[i]);
      inc(i);
      if loCaseInsensitive in options then
        begin
        if Chr1 in [97..122] then
          dec(Chr1,32);
        if Chr2 in [97..122] then
          dec(Chr2,32);
        end;
      result := Chr1 - Chr2;
      end;
    if (result <> 0) and (chr1 = 0) and (loPartialKey in options) then result := 0;
  end;


var keyfield    : TField;     // Field to search in
    ValueBuffer : pchar;      // Pointer to value to search for, in TField' internal format
    VBLength    : integer;

    FieldBufPos : PtrInt;     // Amount to add to the record buffer to get the FieldBuffer
    CurrLinkItem: Pbufreclinkitem1;
    CurrBuff    : pchar;
    bm          : TBufBookmarkty;

    CheckNull   : Boolean;
    SaveState   : TDataSetState;

begin
// For now it is only possible to search in one field at the same time
  result := False;

  if IsEmpty then exit;

  keyfield := FieldByName(keyfields);
  CheckNull := VarIsNull(KeyValues);

  if not CheckNull then
    begin
    SaveState := State;
    SetTempState(dsFilter);
    keyfield.Value := KeyValues;
    RestoreState(SaveState);

    FieldBufPos := FFieldBufPositions[keyfield.FieldNo-1];
    VBLength := keyfield.DataSize;
    ValueBuffer := AllocMem(VBLength);
    currbuff := pointer(FLastRecBuf)+sizeof(Tbufreclinkitem1)+FieldBufPos;
    move(currbuff^,ValueBuffer^,VBLength);
    end;

  CurrLinkItem := FFirstRecBuf;

  if CheckNull then
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(Tbufreclinkitem1);
    if GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      result := True;
      break;
      end;
    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end
  else if keyfield.DataType = ftString then
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(Tbufreclinkitem1);
    if not GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      inc(CurrBuff,FieldBufPos);
      if CompareText0(ValueBuffer,CurrBuff,VBLength,options) = 0 then
        begin
        result := True;
        break;
        end;
      end;
    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end
  else
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(Tbufreclinkitem1);
    if not GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      inc(CurrBuff,FieldBufPos);
      if CompareByte(ValueBuffer^,CurrBuff^,VBLength) = 0 then
        begin
        result := True;
        break;
        end;
      end;

    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end;


  if Result then
    begin
    bm.BookmarkData := CurrLinkItem;
    bm.BookmarkFlag := bfCurrent;
    GotoBookmark(@bm);
    end;

  ReAllocmem(ValueBuffer,0);
end;
}
function tmsebufdataset.getblobrecpo: precheaderty;
begin
 if state = dsoldvalue then begin
  if getrecordupdatebuffer then begin
   result:= pointer(fupdatebuffer[fcurrentupdatebuffer].oldvalues);
   if result <> nil then begin
    result:= @pintrecordty(result)^.header;
   end;
  end
  else begin
   result:= @fcurrentbuf^.header   //there is no old value available
  end;
 end
 else begin
  if state = dscurvalue then begin
   result:= @fcurrentbuf^.header;
  end
  else begin
   if bs_recapplying in fbstate then begin
    result:= @fnewvaluebuffer^.header;
   end
   else begin
    result:= @pdsrecordty(activebuffer)^.header;
   end;
  end;
 end;
end;

function tmsebufdataset.createblobstream(field: tfield;
               mode: tblobstreammode): tstream;
var
 int1: integer;
 buffer: pointer;
begin
 if (mode <> bmread) and not ((state in dseditmodes) or 
                              (bs_recapplying in fbstate)) then begin
  databaseerrorfmt(snotediting,[name],self);
 end;  
 result:= nil;
 if mode = bmread then begin
  buffer:= getblobrecpo;
  with precheaderty(buffer)^ do begin
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].field = field then begin
     result:= tblobcopy.create(blobinfo[int1]);
     break;
    end;
   end;
  end;
 end; 
end;

function tmsebufdataset.getfieldblobid(const field: tfield;
               out aid: blobidty): boolean;
var
 po1: precheaderty;
 po2: pointer;
 int1: integer;
begin
 result:= getfieldbuffer(field,po2,int1);
 if result then begin
  po1:= getblobrecpo;
  with po1^ do begin
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].field = field then begin
     aid.local:= true;
     aid.id:= ptrint(blobinfo[int1].data);
     result:= aid.id <> 0;
     exit;
    end;
   end;   
   aid.local:= false;
   aid.id:= 0;
   move(po2^,aid.id,getblobdatasize);
  end;
 end;
end;

procedure tmsebufdataset.fetchallblobs;
begin
 fetchall;
 fetchblobs;
end;

function tmsebufdataset.blobsarefetched: boolean;
begin
 result:= bs_blobsfetched in fbstate;
end;

function tmsebufdataset.getblobcache: blobcacheinfoarty;
begin
 result:= fblobcache;
end;

function tmsebufdataset.findcachedblob(var info: blobcacheinfoty): boolean;
var
 int1: integer;
begin
 if bs_blobscached in fbstate then begin
  info:= fblobcache[integer(info.id)];
  result:= true;
 end
 else begin
  if not (bs_blobssorted in fbstate) then begin
   sortblobcache;
  end;
  result:= findarrayvalue(info,fblobcache,sizeof(blobcacheinfoty),
                                             fblobcount,@compblobcache,int1);
  if result then begin
   info.data:= fblobcache[int1].data;
  end
  else begin
   info.data:= '';
  end;
 end
end;

procedure tmsebufdataset.sortblobcache;
begin
 setlength(fblobcache,fblobcount);
 sortarray(fblobcache,sizeof(blobcacheinfoty),@compblobcache);
 include(fbstate,bs_blobssorted);
end;

procedure tmsebufdataset.resetblobcache;
begin
 fblobcache:= nil;
 fblobcount:= 0;
 ffreedblobs:= nil;
 ffreedblobcount:= 0;
 exclude(fbstate,bs_blobssorted);
end;

procedure tmsebufdataset.fetchblobs;
var
 datapobefore: pintrecordty;
 statebefore: tdatasetstate;
 int1,int2,int3: integer;
 ind1: pointerarty;
 fieldar1: fieldarty;
 ar1: integerarty;
 stream1: tmemorystream;
// id: int64;
begin
 if not blobscached and not (bs_blobsfetched in fbstate) then begin
  setlength(fieldar1,fields.count);
  int2:= 0;
  for int1:= 0 to high(fieldar1) do begin
   fieldar1[int2]:= fields[int1];
   if fieldar1[int2].isblob then begin
    inc(int2);
   end;
  end;
  if int2 > 0 then begin
   setlength(fieldar1,int2);
   setlength(ar1,int2);
   for int1:= 0 to high(ar1) do begin
    ar1[int1]:= fieldar1[int1].fieldno-1;
   end;
   datapobefore:= fcurrentbuf;
   ind1:= findexes[0].ind;
   statebefore:= settempstate(dscurvalue);
   resetblobcache;
   try
    for int1:= 0 to recordcount - 1 do begin
     fcurrentbuf:= ind1[int1];
     for int2:= 0 to high(fieldar1) do begin
      if getfieldflag(@fcurrentbuf^.header.fielddata.nullmask,
                                                        ar1[int2]) then begin
       stream1:= tmemorystream(createblobstream(fieldar1[int2],bmread));
       int3:= addblobcache(stream1.memory,stream1.size);
       fieldar1[int2].getdata(@fblobcache[int3].id);
       stream1.free;
      end;
     end;
    end;
   finally
    fcurrentbuf:= datapobefore;
    restorestate(statebefore);
   end;
  end;
 end
 else begin
  setlength(fblobcache,fblobcount);
 end;
 include(fbstate,bs_blobsfetched);
end;

function tmsebufdataset.findcachedblob(const id: int64; 
                           out info: blobcacheinfoty): boolean;
begin
 info.id:= id;
 result:= findcachedblob(info);
end;

procedure tmsebufdataset.getofflineblob(const data: precheaderty;
                       const aindex: integer; out ainfo: blobstreaminfoty);
var
 cacheinfo: blobcacheinfoty;
 int1: integer;
begin
 with ffieldinfos[aindex],base,ext do begin
  cacheinfo.id:= 0; //field size can be 32 bit
  move((pchar(data)+offset)^,cacheinfo.id,size);
  with data^ do begin
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].field = field then begin
     with blobinfo[int1] do begin
      ainfo.info.id:= cacheinfo.id;
      ainfo.info.new:= new;
      ainfo.info.current:= true;
      setlength(ainfo.data,datalength);
      move(data^,pointer(ainfo.data)^,datalength);
             //todo: no move
     end;
     exit;
    end;
   end;
  end;
  findcachedblob(cacheinfo);
  with ainfo,info do begin
   id:= cacheinfo.id;
   new:= false;
   current:= false;
   data:= cacheinfo.data;
  end;
 end;
end;

procedure tmsebufdataset.setofflineblob(const adata: precheaderty;
                       const aindex: integer; const ainfo: blobstreaminfoty);
begin
 with ainfo,info do begin
  with ffieldinfos[aindex],base,ext do begin
   move(id,(pchar(adata)+offset)^,size);
   if current then begin
    with adata^ do begin
     setlength(blobinfo,high(blobinfo) + 2);
     with blobinfo[high(blobinfo)] do begin
      field:= ffieldinfos[aindex].ext.field;
      new:= info.new; //??
      datalength:= length(ainfo.data);
      getmem(data,datalength); //todo: no move
      move(pointer(ainfo.data)^,data^,datalength);
     end;
    end;
   end
   else begin
    addblobcache(id,data);
   end;
  end;
 end;
end;

procedure tmsebufdataset.setdatastringvalue(const afield: tfield;
                                                      const avalue: string);
var
 po1: pbyte;
 int1: integer;
begin
 if bs_recapplying in fbstate then begin
//  po1:= pbyte(@fupdatebuffer[fcurrentupdatebuffer].bookmark.recordpo^.header);
  po1:= @fnewvaluebuffer^.header;
  include(fbstate,bs_curvaluemodified);
 end
 else begin
  po1:= pbyte(@fcurrentbuf^.header);
 end;
 int1:= afield.fieldno - 1;
 if avalue <> '' then begin
  move(avalue[1],(pchar(po1)+ffieldinfos[int1].base.offset)^,
                                 length(avalue));
  setfieldflag(@precheaderty(po1)^.fielddata.nullmask,int1);
 end
 else begin
  clearfieldflag(@precheaderty(po1)^.fielddata.nullmask,int1);
 end;
end; 

procedure tmsebufdataset.checkindexsize;
var
 int1,int2: integer;
begin
 if high(factindexpo^.ind) <= fbrecordcount then begin
  int2:= (fbrecordcount+16)*2;
  setlength(findexes[0].ind,int2);
  if bs_indexvalid in fbstate then begin
   for int1:= 1 to high(findexes) do begin
    setlength(findexes[int1].ind,int2);
   end;
  end;
 end;
end;

function tmsebufdataset.insertindexrefs(const arecord: pintrecordty): integer;
var
 int1,int2: integer;
begin
 result:= frecno;
 if bs_indexvalid in fbstate then begin
  for int1:= 1 to high(findexes) do begin
   with findexlocal[int1-1] do begin
    int2:= findboundary(arecord,high(findexfieldinfos),true);
   end;
   with findexes[int1] do begin
    if int2 < fbrecordcount then begin
     move(ind[int2],ind[int2+1],(fbrecordcount-int2)*sizeof(pointer));
    end;
    ind[int2]:= arecord;
    if int1 = factindex then begin
     result:= int2;
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.removeindexrefs(const arecord: pintrecordty);
var
 int1,int2: integer;
begin
 if bs_indexvalid in fbstate then begin
  for int1:= 1 to high(findexes) do begin
   if int1 <> factindex then begin
    int2:= findexlocal[int1-1].findrecord(arecord);
    if int2 < 0 then begin
     databaseerror('Internal error: Indexed record not found.');
    end;
    with findexes[int1] do begin
     move(ind[int2+1],ind[int2],(fbrecordcount-int2-1)*sizeof(pointer));
    end;
   end;
  end;
 end;
end;

function tmsebufdataset.appendrecord(const arecord: pintrecordty): integer;
begin
 checkindexsize;
 findexes[0].ind[fbrecordcount]:= arecord;
 result:= insertindexrefs(arecord);
 if factindex = 0 then begin
  result:= fbrecordcount;
 end;
 inc(fbrecordcount);
end;

function tmsebufdataset.insertrecord(arecno: integer; 
                       const arecord: pintrecordty): integer;
begin
 if arecno < 0 then begin
  arecno:= 0;
 end;
 checkindexsize;
 result:= insertindexrefs(arecord);
 if factindex <> 0 then begin
  findexes[0].ind[fbrecordcount]:= arecord; //append
 end
 else begin
  result:= arecno;
  move(findexes[0].ind[arecno],findexes[0].ind[arecno+1],
             (fbrecordcount-arecno)*sizeof(pointer));
  findexes[0].ind[arecno]:= arecord;           
 end;
 if (frecno > arecno) then begin
  inc(frecno);
 end;
 fcurrentbuf:= arecord;
// fcurrentbuf:= factindexpo^.ind[frecno];
 inc(fbrecordcount);
end;

function tmsebufdataset.remove0indexref(const arecord: pintrecordty): integer;
var
 po1: pintrecordty;
 po2: ppointer;
 int1: integer;
begin  
 result:= -1;
 dec(fbrecordcount);
 po1:= arecord;
 with findexes[0] do begin
  po2:= pointer(pchar(pointer(ind)) + fbrecordcount*sizeof(pointer));
  for int1:= fbrecordcount downto 0 do begin
   if po2^ = po1 then begin
    result:= int1;
    break;
   end;
   dec(po2);
  end;
  if result >= 0 then begin
   move(ind[result+1],ind[result],(fbrecordcount-result)*sizeof(pointer));
  end;
 end;
end;

procedure tmsebufdataset.deleterecord(const arecord: pintrecordty);
var
 int1: integer;
begin
 if bs_indexvalid in fbstate then begin
  int1:= factindex;
  factindex:= 0;
  removeindexrefs(arecord);
  factindex:= int1;
 end;
 remove0indexref(arecord);
end;

procedure tmsebufdataset.deleterecord(const arecno: integer);
var
 po1: pintrecordty;
// int1: integer;
begin
 po1:= factindexpo^.ind[arecno];
 if bs_indexvalid in fbstate then begin
  removeindexrefs(po1);
  if factindex <> 0 then begin
   move(factindexpo^.ind[arecno+1],factindexpo^.ind[arecno],
              (fbrecordcount-arecno-1)*sizeof(pointer));
  end;
 end;
 if factindex = 0 then begin
  dec(fbrecordcount);
  with findexes[0] do begin
   move(ind[arecno+1],ind[arecno],(fbrecordcount-arecno)*sizeof(pointer));
  end;
 end
 else begin
  remove0indexref(po1);
 end;
 if (frecno > arecno) or (frecno >= fbrecordcount) then begin
  dec(frecno);
 end;
 if frecno < 0 then begin
  fcurrentbuf:= nil;
 end
 else begin
  fcurrentbuf:= factindexpo^.ind[frecno];
 end;
end;

procedure tmsebufdataset.checkindex(const force: boolean);
var
 int1,int2{,int3}: integer;
begin
 if (force or (factindex <> 0)) and not (bs_indexvalid in fbstate) then begin
  int2:= length(findexes[0].ind);
  if int2 > 0 then begin
   for int1:= 1 to high(findexes) do begin
    with findexes[int1] do begin
     if ind = nil then begin
      allocuninitedarray(int2,sizeof(pointer),ind);
      if fbrecordcount > 0 then begin
       move(findexes[0].ind[0],ind[0],fbrecordcount*sizeof(pointer));
       findexlocal.items[int1-1].sort(ind);
      end;
     end;
    end;
   end;
  end;
  include(fbstate,bs_indexvalid);
 end;
end;

procedure tmsebufdataset.internalsetrecno(const avalue: integer);
begin
 frecno:= avalue;
 if (avalue < 0) or (avalue >= fbrecordcount)  then begin
  fcurrentbuf:= nil;
 end
 else begin
  checkindex(false);
  fcurrentbuf:= factindexpo^.ind[avalue];
 end;
// tdatasetcracker(self).fbof:= frecno = 0;
end;

procedure tmsebufdataset.clearindex;
begin
 findexes:= nil;
 factindexpo:= nil;
 exclude(fbstate,bs_indexvalid);
end;

procedure tmsebufdataset.setindexlocal(const avalue: tlocalindexes);
begin
 findexlocal.assign(avalue);
end;

procedure tmsebufdataset.updatestate;
begin
 if (fpacketrecords < 0) {or assigned(foninternalcalcfields)} then begin
  include(fbstate,bs_fetchall);
 end
 else begin
  exclude(fbstate,bs_fetchall);
 end;
 if findexlocal.count > 0 then begin
  fbstate:= fbstate + [bs_hasindex,bs_fetchall];
 end
 else begin
  exclude(fbstate,bs_hasindex);
 end;
end;

procedure tmsebufdataset.setactindex(const avalue: integer);
//var
// int1: integer;
begin
 if factindex <> avalue then begin
  if active then begin
   checkbrowsemode;
   factindex:= avalue;
   factindexpo:= @findexes[avalue];
   internalsetrecno(findrecord(fcurrentbuf));
   resync([]);
   findexlocal.doindexchanged;
  end
  else begin
   factindex:= avalue;
   factindexpo:= @findexes[avalue];
  end;
 end;
end;

procedure tmsebufdataset.resetindex;
var
 int1: integer;
begin
 actindex:= 0;
 for int1:= 1 to high(findexes) do begin
  findexes[int1].ind:= nil;
 end;
 exclude(fbstate,bs_indexvalid);
end;

function tmsebufdataset.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
 result:= getmsefieldclass(fieldtype);
end;

procedure tmsebufdataset.fieldtoparam(const source: tfield; const dest: tparam);
var
// int1: integer;
 mstr1: msestring;
begin
 if source is tmsestringfield then begin
  with tmsestringfield(source) do begin
   if source.isnull then begin
    dest.clear;
    if fixedchar then begin
     dest.datatype:= ftfixedchar;
    end
    else begin
     dest.datatype:= ftstring;
    end;
   end
   else begin
    mstr1:= asmsestring;
    if (characterlength <> 0) and (length(mstr1) > characterlength)  then begin
     setlength(mstr1,characterlength);
    end;
    dest.aswidestring:= mstr1;
    if fixedchar then begin
     dest.datatype:= ftfixedwidechar;
    end;
   end;
  end;
 end
 else begin
  dest.assignfieldvalue(source,source.value);
 end;
end;

procedure tmsebufdataset.oldfieldtoparam(const source: tfield;
               const dest: tparam);
var
 bo1:boolean;
 mstr1: msestring;
begin
 if source is tmsestringfield then begin
  mstr1:= tmsestringfield(source).oldmsestring(bo1);
  if bo1 then begin
   dest.clear;
   if tmsestringfield(source).fixedchar then begin
    dest.datatype:= ftfixedchar;
   end
   else begin
    dest.datatype:= ftstring;
   end;
  end
  else begin
  {
   if bs_utf8 in fbstate then begin
    dest.asstring:= stringtoutf8(mstr1);
   end
   else begin
    dest.asstring:= mstr1;
   end;
  }
   dest.aswidestring:= mstr1;
   if tmsestringfield(source).fixedchar then begin
    dest.datatype:= ftfixedwidechar;
   end;
  end;
 end
 else begin
  dest.assignfieldvalue(source,source.oldvalue);
 end;
end;

procedure tmsebufdataset.stringtoparam(const source: msestring;
               const dest: tparam);
begin
 if bs_utf8 in fbstate then begin
  dest.asstring:= stringtoutf8(source);
 end
 else begin
  dest.asstring:= source;
 end;
end;

procedure tmsebufdataset.bindfields(const bind: boolean);
var
 int1: integer;
 field1: tfield;
 int2: integer;
 fielddef1: tfielddef;
begin
 for int1:= fields.count - 1 downto 0 do begin
  field1:= fields[int1];
  if bind then begin
   if field1.fieldkind = fkdata then begin
    fielddef1:= tfielddef(fielddefs.find(field1.fieldname));
                   //needed for FPC 2_2
    if fielddef1 <> nil then begin
     field1.fieldname:= fielddef1.name;
          //get exact name for quoting in update statements
    end;
   end
   else begin
    fielddef1:= nil;
   end;
  end;
  if field1 is tmsestringfield then begin
   int2:= 0;
   if bind then begin
    int2:= field1.size;
    if fielddef1 <> nil then begin
     int2:= fielddef1.size;
    end;
    tmsestringfield1(field1).setismsestring({$ifdef FPC}@{$endif}getmsestringdata,
         {$ifdef FPC}@{$endif}setmsestringdata,int2,(fielddef1 <> nil) and
                        (fielddef1.datatype in widestringfields));
   end
   else begin
    tmsestringfield1(field1).setismsestring(nil,nil,int2,false);
   end;
  end
  else begin
   if field1 is tmseblobfield then begin
    if bind then begin
     tmseblobfield1(field1).fgetblobid:= {$ifdef FPC}@{$endif}getfieldblobid;
    end
    else begin
     tmseblobfield1(field1).fgetblobid:= nil;
    end;
   end
   else begin
    if field1 is tmsevariantfield then begin
     if bind then begin
      tmsevariantfield1(field1).fsetvardata:= {$ifdef FPC}@{$endif}setvardata;
      tmsevariantfield1(field1).fgetvardata:= {$ifdef FPC}@{$endif}getvardata;
     end
     else begin
      tmsevariantfield1(field1).fsetvardata:= nil;
      tmsevariantfield1(field1).fgetvardata:= nil;
     end;
    end;
   end;
  end;
 end;
 inherited bindfields(bind);
end;

function tmsebufdataset.findfields(const anames: string): fieldarty;
var
 ar1: stringarty;
 int1: integer;
begin
 ar1:= splitstring(anames,';',true);
 setlength(result,length(ar1));
 for int1:= 0 to high(result) do begin
  result[int1]:= findfield(ar1[int1]);
 end;
end;

function tmsebufdataset.findfields(const anames: string; out afields: fieldarty): boolean;
                           //true if all found
var
 ar1: stringarty;
 int1: integer;
begin
 ar1:= splitstring(anames,';',true);
 setlength(afields,length(ar1));
 result:= true;
 for int1:= 0 to high(afields) do begin
  afields[int1]:= findfield(ar1[int1]);
  if afields[int1] = nil then begin
   result:= false;
  end;  
 end;
end;

function tmsebufdataset.refreshing: boolean;
begin
 result:= bs_refreshing in fbstate;
end;

function tmsebufdataset.isutf8: boolean;
begin
 result:= false; //default
end;

procedure tmsebufdataset.append;
begin
 include(fbstate,bs_append);
 inherited;
end;

procedure tmsebufdataset.setoninternalcalcfields(
            const avalue: internalcalcfieldseventty);
begin
 foninternalcalcfields:= avalue;
 updatestate;
end;

procedure tmsebufdataset.lookupdschanged(const sender: tmsebufdataset);
var
 int1,int2: integer;
 bo1: boolean;
 bm1: bookmarkdataty;
begin
 if active and not (csdestroying in componentstate) then begin
  int2:= fnotifylookupclientcount;
  bo1:= false;
  bm1:= bookmarkdata;
  for int1:= 0 to high(flookupfieldinfos) do begin
   with flookupfieldinfos[int1] do begin
    if hasindex and (lookupvaluefield.dataset = sender) then begin
     findexlocal.fieldmodified(valuefield,false);
     bo1:= true;
    end; 
   end;
  end;
  if state in [dsedit,dsinsert,dsbrowse] then begin 
            //stop recursion triggered by dscalcfields
   if bo1 then begin
    if state = dsinsert then begin
     checkbrowsemode;
    end
    else begin
     if bm1.recordpo <> nil then begin
      bookmarkdata:= bm1;   
     end;
    end;
   end
   else begin
    checkbrowsemode;
    resync([]);
   end;
   if int2 = fnotifylookupclientcount then begin
                   //already called by post otherwise
    notifylookupclients;
   end;
  end;
 end;
end;

procedure tmsebufdataset.notifylookupclients;
var
 int1: integer;
begin
 if not (bs1_lookupnotifying in fbstate1) then begin
  inc(fnotifylookupclientcount);
  include(fbstate1,bs1_lookupnotifying);
  try
   for int1:= 0 to high(flookupclients) do begin
    flookupclients[int1].lookupdschanged(self);
   end;
  finally
   exclude(fbstate1,bs1_lookupnotifying);
  end;
 end;
end;

procedure tmsebufdataset.dataevent(event: tdataevent; info: ptrint);
var
 int1: integer;
 field1: tfield;
begin
 if (event = decheckbrowsemode) and (state = dsfilter) then begin
  databaseerror('Database is in dsFilter state.',self);
 end;
 if event in [deupdaterecord,dedatasetchange] then begin
  exclude(fbstate,bs_visiblerecordcountvalid);
 end;
 if (event = deupdatestate) and (state = dsbrowse) then begin
  updatecursorpos; //update fcurrentbuf after open
 end;
 if (bs_startedit in fbstate) and (event = derecordchange) and (info = 0) then begin
  exclude(fbstate,bs_startedit);
  for int1:= 0 to fields.count - 1 do begin
   field1:= fields[int1];
   if field1.fieldkind = fkcalculated then begin
    dataevent(defieldchange,ptrint(field1));
   end;
   exit;
  end;
 end;
 if not ((bs_recapplying in fbstate) and (event = dedatasetchange)) then begin
  inherited;
 end;
 case ord(event) of
  ord(deupdaterecord): begin
   if checkcanevent(self,tmethod(foninternalcalcfields)) then begin
    foninternalcalcfields(self,false);
   end;
  end;
  de_modified: begin
   notifylookupclients;
  end;
 end;
end;

function tmsebufdataset.bookmarkdatatobookmark(
                      const abookmark: bookmarkdataty): bookmarkty;
begin
 if abookmark.recordpo = nil then begin
  result:= '';
 end
 else begin
  setlength(result,sizeof(abookmark));
  move(abookmark,pointer(result)^,sizeof(abookmark));
 end;
end;

function tmsebufdataset.bookmarktobookmarkdata(
                              const abookmark: bookmarkty): bookmarkdataty;
begin
 if abookmark = '' then begin
  result.recordpo:= nil;
  result.recno:= -1;
 end
 else begin
  move(pointer(abookmark)^,result,sizeof(result));
 end;
end;

procedure tmsebufdataset.checkrecno(const avalue: integer);
begin
 if (avalue > recordcount) or (avalue < 1) then begin
  databaseerror(snosuchrecord,self);
 end;
end;

procedure tmsebufdataset.setonfilterrecord(const value: tfilterrecordevent);
begin
 inherited;
 if not (csdesigning in componentstate) then begin
  checkfilterstate;
  filterchanged;
 end;
end;

procedure tmsebufdataset.setfiltered(value: boolean);
begin
 inherited;
 filterchanged; 
end;

procedure tmsebufdataset.setactive(value: boolean);
var
 bo1: boolean;
begin
 bo1:= active;
 inherited;
 if bo1 <> active then begin
  notifycontrols;
  notifylookupclients;
 end;
end;

procedure tmsebufdataset.filterchanged;
begin
 exclude(fbstate,bs_visiblerecordcountvalid);
 if not (state in [dsinactive,dsfilter]) then begin
  checkbrowsemode;
  resync([]);
 end;
end;

function tmsebufdataset.locate(const afields: array of tfield;
                   const akeys: array of const; const aisnull: array of boolean;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,afields,akeys,aisnull,akeyoptions,aoptions);
end;
{
function tmsebufdataset.locate(const key: integer; const field: tfield;
                      const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,key,field,options);
end;
                     
function tmsebufdataset.locate(const key: msestring; const field: tfield; 
                      const options: locateoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,isutf8,key,field,options);
end;
}
function tmsebufdataset.locaterecno(const arecno: integer): boolean;
        //moves to next valid recno, //returns true if resulting recno = arecno
var
 int1: integer;
begin
 result:= false;
 int1:= arecno-1;
 if int1 <> frecno then begin
  if int1 < 0 then begin 
   int1:= 0;
  end;
  if int1 >= recordcount then begin
   int1:= fbrecordcount - 1;
  end;
  if int1 >= 0 then begin
   internalsetrecno(int1);
   resync([]);
   result:= int1 = frecno;
  end;
 end
 else begin
  result:= true;
 end;
end;

procedure tmsebufdataset.beginfilteredit(const akind: filtereditkindty);
begin
 if state <> dsfilter then begin
  ffiltereditkind:= akind;
  checkbrowsemode;
  if checkcanevent(self,tmethod(fbeforebeginfilteredit)) then begin
   fbeforebeginfilteredit(self,akind);
  end;
  fbuffercountbefore:= buffercount;
  setbuflistsize(1);
  setstate(dsfilter);
  dataevent(dedatasetchange,0);
  if checkcanevent(self,tmethod(fafterbeginfilteredit)) then begin
   fafterbeginfilteredit(self,akind);
  end;
 end;
end;

procedure tmsebufdataset.endfilteredit;
begin
 if state = dsfilter then begin
  dataevent(deupdaterecord, 0);
  if checkcanevent(self,tmethod(fbeforeendfilteredit)) then begin
   fbeforeendfilteredit(self,ffiltereditkind);
  end;
  setbuflistsize(fbuffercountbefore);
  setstate(dsbrowse);
  resync([]);
  if checkcanevent(self,tmethod(fafterendfilteredit)) then begin
   fafterendfilteredit(self,ffiltereditkind);
  end;
 end;
end;

function tmsebufdataset.fieldfiltervalue(const afield: tfield;
                           const akind: filtereditkindty = fek_filter): variant;
var
 statebefore: tdatasetstate;
 kindbefore: filtereditkindty;
begin
 statebefore:= settempstate(dsfilter);
 kindbefore:= ffiltereditkind;
 ffiltereditkind:= akind;
 result:= afield.asvariant;
 ffiltereditkind:= kindbefore;
 restorestate(statebefore);
end;

function tmsebufdataset.fieldfiltervalueisnull(const afield: tfield;
                           const akind: filtereditkindty = fek_filter): boolean;
var
 statebefore: tdatasetstate;
 kindbefore: filtereditkindty;
begin
 statebefore:= settempstate(dsfilter);
 kindbefore:= ffiltereditkind;
 ffiltereditkind:= akind;
 result:= afield.isnull;
 ffiltereditkind:= kindbefore;
 restorestate(statebefore);
end;

procedure tmsebufdataset.checkfilterstate;
begin
 exclude(fbstate,bs_hasfilter);
 if checkcanevent(self,tmethod(onfilterrecord)) then begin
  include(fbstate,bs_hasfilter);
 end
end;

procedure tmsebufdataset.loaded;
begin
 inherited;
 checkfilterstate;
end;

procedure tmsebufdataset.dofilterrecord(var acceptable: boolean);
begin
 if checkcanevent(self,tmethod(onfilterrecord)) then begin
  onfilterrecord(self,acceptable);
 end;
end;

function tmsebufdataset.recordisnull(): boolean; //all fields null
var
 int1: integer;
begin
 checkactive();
 result:= true;
 for int1:= 0 to fields.count - 1 do begin
  if not fields[int1].isnull then begin
   result:= false;
   break;
  end;
 end;
end;

procedure tmsebufdataset.clearrecord();
var
 int1: integer;
begin
 checkactive;
 try
  disablecontrols;
  for int1:= 0 to fields.count - 1 do begin
   with fields[int1] do begin
    if state = dsfilter then begin
     if not isblob then begin
      clear;
     end;
    end
    else begin
     if not readonly then begin
      clear;
     end;
    end;
   end;
  end;
 finally
  enablecontrols;
 end;
end;

procedure tmsebufdataset.clearfilter;
var
 int1: integer;
 statebefore: tdatasetstate;
 kindbefore,kind1,firstki,lastki: filtereditkindty;
begin
 checkactive;
 try
  disablecontrols;
  statebefore:= settempstate(dsfilter);
  kindbefore:= filtereditkind;
  if statebefore = dsfilter then begin
   firstki:= filtereditkind;
   lastki:= firstki;
  end
  else begin
   firstki:= low(filtereditkindty);
   lastki:= high(filtereditkindty);
  end;
  for kind1:= firstki to lastki do begin
   filtereditkind:= kind1;
   for int1:= 0 to fields.count - 1 do begin
    with fields[int1] do begin
     if not isblob then begin
      clear;
     end;
    end;
   end;
  end;
  if (statebefore <> dsfilter) then begin
   for kind1:= low(filtereditkindty) to high(filtereditkindty) do begin
    if checkcanevent(self,tmethod(fbeforeendfilteredit)) then begin
     fbeforeendfilteredit(self,kind1);
    end;
   end;
   resync([]);
  end;
 finally
  filtereditkind:= kindbefore;
  restorestate(statebefore);
  enablecontrols;
 end;
end;

procedure tmsebufdataset.fetchall;
begin
 getnextpacket(true);
end;

procedure tmsebufdataset.checksumfield(const afield: tfield;
                                         const fieldtypes: fieldtypesty);
begin
 checkbrowsemode;
 if (afield.fieldno <= 0) or (afield.dataset <> self) or
         not (ffieldinfos[afield.fieldno-1].base.fieldtype in 
                                             fieldtypes) then begin
  raise edatabaseerror.create('Invalid sum field '+'"'+afield.fieldname+'".');
 end;
end;

procedure tmsebufdataset.sumfield(const afield: tfield; out asum: double);
var
 int1,int2: integer;
 index1: integer;
 po1: precheaderty;
 po2: pprecheaderty;
 bo1,bo2: boolean;
 state1: tdatasetstate;
begin
 checksumfield(afield,[ftfloat,ftcurrency]);
 index1:= afield.fieldno - 1;
 asum:= 0;
 bo1:= filtered and assigned(onfilterrecord);
 state1:= settempstate(tdatasetstate(dscheckfilter));
 try
  int2:= ffieldinfos[index1].base.offset;
  po2:= pointer(findexes[0]);
  if bo1 then begin
   for int1:= 0 to fbrecordcount - 1 do begin
    fcheckfilterbuffer:= pdsrecordty(pchar(ppointeraty(po2)^[int1])-
                                                           sizeof(dsheaderty));
    bo2:= true;
    onfilterrecord(self,bo2);
    if bo2 and getfieldflag(@fcheckfilterbuffer^.header.fielddata.nullmask,
                                                             index1) then begin
     asum:= asum + pdouble(pchar(@fcheckfilterbuffer^.header)+int2)^;
    end;
   end;
  end
  else begin
   for int1:= 0 to fbrecordcount - 1 do begin
    po1:= ppointeraty(po2)^[int1];
    if getfieldflag(@po1^.fielddata.nullmask,index1) then begin
     asum:= asum + pdouble(pchar(po1)+int2)^;
    end;
   end;
  end;
 finally
  restorestate(state1);
 end; 
end;

procedure tmsebufdataset.sumfield(const afield: tfield; out asum: currency);
var
 int1,int2: integer;
 index1: integer;
 po1: precheaderty;
 po2: pprecheaderty;
 bo1,bo2: boolean;
 state1: tdatasetstate;
begin
 checksumfield(afield,[ftbcd,ftfloat]);
 index1:= afield.fieldno - 1;
 asum:= 0;
 bo1:= filtered and assigned(onfilterrecord);
 state1:= settempstate(tdatasetstate(dscheckfilter));
 try
  int2:= ffieldinfos[index1].base.offset;
  po2:= pointer(findexes[0]);
  case ffieldinfos[afield.fieldno-1].base.fieldtype of
   ftbcd: begin
    if bo1 then begin
     for int1:= 0 to fbrecordcount - 1 do begin
      fcheckfilterbuffer:= pdsrecordty(pchar(ppointeraty(po2)[int1])-
                                                          sizeof(dsheaderty));
      bo2:= true;
      onfilterrecord(self,bo2);
      if bo2 and getfieldflag(
              @fcheckfilterbuffer^.header.fielddata.nullmask,index1) then begin
       asum:= asum + pcurrency(pchar(@fcheckfilterbuffer^.header)+int2)^;
      end;
     end;
    end
    else begin
     for int1:= 0 to fbrecordcount - 1 do begin
      po1:= ppointeraty(po2)^[int1];
      if getfieldflag(@po1^.fielddata.nullmask,index1) then begin
       asum:= asum + pcurrency(pchar(po1)+int2)^;
      end;
     end;
    end;
   end;
   ftfloat: begin
    if bo1 then begin
     for int1:= 0 to fbrecordcount - 1 do begin
      fcheckfilterbuffer:= pdsrecordty(
                           pchar(ppointeraty(po2)^[int1])-sizeof(dsheaderty));
      bo2:= true;
      onfilterrecord(self,bo2);
      if bo2 and getfieldflag(
            @fcheckfilterbuffer^.header.fielddata.nullmask,index1) then begin
       asum:= asum + pdouble(pchar(@fcheckfilterbuffer^.header)+int2)^;
      end;
     end;
    end
    else begin
     for int1:= 0 to fbrecordcount - 1 do begin
      po1:= ppointeraty(po2)^[int1];
      if getfieldflag(@po1^.fielddata.nullmask,index1) then begin
       asum:= asum + pdouble(pchar(po1)+int2)^;
      end;
     end;
    end;
   end;
  end;
 finally
  restorestate(state1);
 end; 
end;

procedure tmsebufdataset.sumfield(const afield: tfield; out asum: int64);
var
 int1,int2: integer;
 index1: integer;
 po1: precheaderty;
 po2: pprecheaderty;
 bo1,bo2: boolean;
 state1: tdatasetstate;
begin
 checksumfield(afield,[ftlargeint,ftinteger,ftsmallint,ftword]);
 index1:= afield.fieldno - 1;
 asum:= 0;
 bo1:= filtered and assigned(onfilterrecord);
 state1:= settempstate(tdatasetstate(dscheckfilter));
 try
  int2:= ffieldinfos[index1].base.offset;
  po2:= pointer(findexes[0]);
  case ffieldinfos[afield.fieldno-1].base.fieldtype of
   ftlargeint: begin
    if bo1 then begin
     for int1:= 0 to fbrecordcount - 1 do begin
      fcheckfilterbuffer:= pdsrecordty(pchar(ppointeraty(po2)^[int1])-
                                                           sizeof(dsheaderty));
      bo2:= true;
      onfilterrecord(self,bo2);
      if bo2 and getfieldflag(
            @fcheckfilterbuffer^.header.fielddata.nullmask,index1) then begin
       asum:= asum + pint64(pchar(@fcheckfilterbuffer^.header)+int2)^;
      end;
     end;
    end
    else begin
     for int1:= 0 to fbrecordcount - 1 do begin
      po1:= ppointeraty(po2)^[int1];
      if getfieldflag(@po1^.fielddata.nullmask,index1) then begin
       asum:= asum + pint64(pchar(po1)+int2)^;
      end;
     end;
    end;
   end;  
   ftinteger,ftsmallint,ftword: begin
    if bo1 then begin
     for int1:= 0 to fbrecordcount - 1 do begin
      fcheckfilterbuffer:= pdsrecordty(pchar(ppointeraty(po2)^[int1])-
                                                        sizeof(dsheaderty));
      bo2:= true;
      onfilterrecord(self,bo2);
      if bo2 and getfieldflag(
              @fcheckfilterbuffer^.header.fielddata.nullmask,index1) then begin
       asum:= asum + pinteger(pchar(@fcheckfilterbuffer^.header)+int2)^;
      end;
     end;
    end
    else begin
     for int1:= 0 to fbrecordcount - 1 do begin
      po1:= ppointeraty(po2)^[int1];
      if getfieldflag(@po1^.fielddata.nullmask,index1) then begin
       asum:= asum + pinteger(pchar(po1)+int2)^;
      end;
     end;
    end;
   end;  
  end;
 finally
  restorestate(state1);
 end; 
end;

procedure tmsebufdataset.sumfield(const afield: tfield; out asum: integer);
var
 int1,int2: integer;
 index1: integer;
 po1: precheaderty;
 po2: pprecheaderty;
 bo1,bo2: boolean;
 state1: tdatasetstate;
begin
 checksumfield(afield,[ftinteger,ftsmallint,ftword,ftboolean]);
 index1:= afield.fieldno - 1;
 asum:= 0;
 bo1:= filtered and assigned(onfilterrecord);
 state1:= settempstate(tdatasetstate(dscheckfilter));
 try
  int2:= ffieldinfos[index1].base.offset;
  po2:= pointer(findexes[0]);
  case ffieldinfos[afield.fieldno-1].base.fieldtype of
   ftinteger,ftsmallint,ftword: begin
    if bo1 then begin
     for int1:= 0 to fbrecordcount - 1 do begin
      fcheckfilterbuffer:= pdsrecordty(pchar(ppointeraty(po2)^[int1])-
                                                         sizeof(dsheaderty));
      bo2:= true;
      onfilterrecord(self,bo2);
      if bo2 and getfieldflag(
             @fcheckfilterbuffer^.header.fielddata.nullmask,index1) then begin
       asum:= asum + pinteger(pchar(@fcheckfilterbuffer^.header)+int2)^;
      end;
     end;
    end
    else begin
     for int1:= 0 to fbrecordcount - 1 do begin
      po1:= ppointeraty(po2)^[int1];
      if getfieldflag(@po1^.fielddata.nullmask,index1) then begin
       asum:= asum + pinteger(pchar(po1)+int2)^;
      end;
     end;
    end;
   end;
   ftboolean: begin
    if bo1 then begin
     for int1:= 0 to fbrecordcount - 1 do begin
      fcheckfilterbuffer:= pdsrecordty(pchar(ppointeraty(po2)^[int1])-
                                                        sizeof(dsheaderty));
      bo2:= true;
      onfilterrecord(self,bo2);
      if bo2 and getfieldflag(
                  @fcheckfilterbuffer^.header.fielddata.nullmask,index1) and
                  pwordbool(pchar(@fcheckfilterbuffer^.header)+int2)^ then begin
       inc(asum);
      end;
     end;
    end
    else begin
     for int1:= 0 to fbrecordcount - 1 do begin
      po1:= ppointeraty(po2)^[int1];
      if getfieldflag(@po1^.fielddata.nullmask,index1) and
                 pwordbool(pchar(po1)+int2)^ then begin
       inc(asum);
      end;
     end;
    end;
   end;
  end;
 finally
  restorestate(state1);
 end;
end;

function tmsebufdataset.sumfielddouble(const afield: tfield): double;
begin
 sumfield(afield,result);
end;

function tmsebufdataset.sumfieldcurrency(const afield: tfield): currency;
begin
 sumfield(afield,result);
end;

function tmsebufdataset.sumfieldinteger(const afield: tfield): integer;
begin
 sumfield(afield,result);
end;

function tmsebufdataset.sumfieldint64(const afield: tfield): int64;
begin
 sumfield(afield,result);
end;

function tmsebufdataset.countvisiblerecords: integer;
var
 int1{,int2}: integer;
// getresult: tgetresult;
begin
 if not (state in [dsinactive,dsfilter]) then begin
  checkbrowsemode;
  if not (bs_visiblerecordcountvalid in fbstate) then begin
   if not filtered then begin
    fetchall;
    fvisiblerecordcount:= fbrecordcount;
   end
   else begin
    int1:= frecno;
    disablecontrols;
    getnextpacket(true);
    try
     fvisiblerecordcount:= 0;
     internalsetrecno(0);
     if (getrecord(activebuffer,gmcurrent,false) = grok) or 
        (getrecord(activebuffer,gmnext,false) = grok) then begin
      repeat
       inc(fvisiblerecordcount);
      until getrecord(activebuffer,gmnext,false) <> grok;
     end;   
    finally
     internalsetrecno(int1);
     getrecord(activebuffer,gmcurrent,false);
     enablecontrols;
    end;
   end;
   include(fbstate,bs_visiblerecordcountvalid);
  end;    
  result:= fvisiblerecordcount;
 end
 else begin
  result:= 0;
 end;
end;

const
 bufdattag: bufdattagty = 'MSEBUFDAT'#0#0#0#0#0#0;
   
// data format:
//
// header: bdsfheaderty
// fielddefs
// currentvalues: recbufferheader,pointer,nullmask,fielddata
// updatebuffer
// updatebufferitem: updatebufferheader,old nullmask,fielddata if not insert
// post log
// endmarker
 
procedure tmsebufdataset.logupdatebuffer(const awriter: tbufstreamwriter; 
                const abuffer: recupdatebufferty; 
                const adeletedrecord: pintrecordty;
                const alogging: boolean; const alogmode: logflagty);
var
 header1: logbufferheaderty;
 datapo: precheaderty;
 int2: integer;
begin
 header1.flag:= alogmode;
 with abuffer,header1.update do begin
  if (info.bookmark.recordpo <> nil) or (deletedrecord <> nil) then begin
   deletedrecord:= adeletedrecord;
   logging:= alogging;
   kind:= info.updatekind;
   po:= info.bookmark.recordpo;
   awriter.writelogbufferheader(header1);
   if (alogmode = lf_update) and 
       ((kind = ukmodify) or 
              not logging and (kind = ukdelete) and (po <> nil)) then begin
    datapo:= @(oldvalues^.header);
    awriter.write(datapo^.fielddata,fnullmasksize);
    for int2:= 0 to high(ffieldinfos) do begin
     awriter.writefielddata(datapo,int2);
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.logrecbuffer(const awriter: tbufstreamwriter;
                       const akind: tupdatekind; const abuffer: pintrecordty);
var
 datapo: precheaderty;
 header1: logbufferheaderty;
 int1: integer;
begin
 header1.flag:= lf_rec;
 with header1.rec do begin
  kind:= akind;
  po:= abuffer;
 end;
 awriter.writelogbufferheader(header1);
 if akind in [ukmodify,ukinsert] then begin
  datapo:= @(abuffer^.header);
  awriter.write(datapo^.fielddata,fnullmasksize);
  for int1:= 0 to high(ffieldinfos) do begin
   awriter.writefielddata(datapo,int1);
  end;
 end;
end;

procedure tmsebufdataset.savestate(const awriter: tbufstreamwriter);
var
 header: tbsfheaderty;
// writer: tbufstreamwriter;
 fieldco: integer;
 int1{,int2}: integer;
begin
 fieldco:= length(ffieldinfos);
 with header do begin
  tag:= bufdattag;
  byteorder:= 0;
  version:= 1;
  fieldcount:= fieldco;
  fielddefcount:= fielddefs.count;
  recordcount:= self.recordcount;
 end;
 if header.fieldcount > 0 then begin
  awriter.write(header,sizeof(header));
  for int1:= 0 to header.fielddefcount - 1 do begin
   awriter.writefielddef(fielddefs[int1]);
  end;
  for int1:= 0 to high(ffieldinfos) do begin
   awriter.write(ffieldinfos[int1],sizeof(fieldinfobasety));
  end;
  with findexes[0] do begin
   for int1:= 0 to recordcount - 1 do begin
    logrecbuffer(awriter,ukinsert,pintrecordty(ind[int1]));
   end;
  end;
  for int1:= 0 to high(fupdatebuffer) do begin
   with fupdatebuffer[int1] do begin
    if info.bookmark.recordpo <> nil then begin
    {
     if updatekind = ukinsert then begin
      logrecbuffer(awriter,updatekind,
                      bookmark.recordpo);
     end;    
    }
     logupdatebuffer(awriter,fupdatebuffer[int1],nil,false,lf_update);
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.savetostream(const astream: tstream);
var
 writer: tbufstreamwriter;
begin
 checkbrowsemode;
 fetchallblobs;
 writer:= tbufstreamwriter.create(self,astream);
 try
  savestate(writer);
  writer.writeendmarker;
 finally
  writer.free;
 end;
end;

procedure tmsebufdataset.doloadfromstream;

 procedure formaterror;
 begin
  databaseerror('Invalid data stream.',self);
 end;
 
var
 header: tbsfheaderty;
 reader: tbufstreamreader;
 fieldco: integer;
 ar2: pointerarty;
 ar3: integerarty;
 appended: pointerarty;
 po1: pointer;
 
 function findrec(const oldpo: pointer; out newpo: pointer;
                                out aindex: integer;
                                const delete: boolean = false): boolean;
           //returns new pointer
 var
  int1: integer;
 begin
  result:= findarrayitem(oldpo,ar2,sizeof(pointer),@comparepointer,int1);
  if result then begin
   aindex:= ar3[int1];
   newpo:= findexes[0].ind[aindex];
   if delete then begin
    dec(header.recordcount);
    dec(fbrecordcount);
    deleteitem(findexes[0].ind,aindex);
    deleteitem(ar3,int1);
    deleteitem(ar2,int1);
   end;
  end
  else begin
   for int1:= 0 to high(appended) do begin
    if appended[int1] = oldpo then begin
     aindex:= header.recordcount+int1;
     newpo:= findexes[0].ind[aindex];
     result:= true;
     if delete then begin
//      appended[int1]:= nil;
      deleteitem(appended,int1);
      dec(fbrecordcount);
     end;
     break;
    end;
   end;
  end;
 end;

var
 actindexbefore: integer; 
 oldupdatepointers: pointerarty;
// bo1: boolean;
 int1,int2,int3: integer;
 header1: logbufferheaderty;
 updabuf: recupdatebufferarty;
 
begin
 initsavepoint;
 updabuf:= nil; //compilerwarning
 actindexbefore:= factindex;
 factindex:= 0;
 factindexpo:= @findexes[0];
 fbstate:= fbstate - [bs_blobscached,bs_indexvalid];
// exclude(fbstate,bs_blobscached);
 reader:= tbufstreamreader.create(self,floadingstream);
 try
  reader.readbuffer(header,sizeof(header));
  if (header.tag <> bufdattag) or (header.fielddefcount > 1000) then begin
   formaterror;
  end;
  try
   fielddefs.beginupdate;
   try
    fielddefs.clear;
    for int1:= 0 to header.fielddefcount - 1 do begin
     reader.readfielddef(fielddefs);
    end;
   finally
    fielddefs.endupdate;
   end;
   dointernalopen;
   fieldco:= length(ffieldinfos);
   if (header.fieldcount <> fieldco) then begin
    formaterror;
   end;
   if fieldco > 0 then begin
    if header.version = 0 then begin
     int1:= sizeof(fieldinfo_0ty);
    end
    else begin
     int1:= sizeof(fieldinfobasety);
    end;    
    getmem(po1,int1*fieldco);
    try
     reader.readbuffer(po1^,int1*fieldco);
     for int2:= 0 to fieldco-1 do begin
      if not comparemem(pchar(po1)+int1*int2,@ffieldinfos[int2],
                                   sizeof(fieldinfobasety)) then begin
       formaterror;
      end;
     end;
    finally
     freemem(po1);
    end;
    setlength(ar2,header.recordcount);
    for int1:= 0 to high(ar2) do begin
     if not reader.readlogbufferheader(header1) or 
                                   (header1.flag <> lf_rec) then begin
      formaterror;
     end;
     ar2[int1]:= header1.rec.po;
     reader.readrecord(femptybuffer);
     appendrecord(femptybuffer);
     femptybuffer:= intallocrecord;
    end;
//    ar1:= nil;
    if header.recordcount > 0 then begin
//     allocuninitedarray(fbrecordcount,sizeof(pointer),ar1);
//     move(pointer(findexes[0])^,pointer(ar1)^,fbrecordcount*sizeof(pointer));
     sortarray(ar2,sizeof(pointer),@comparepointer,ar3);
         //index of old pointers
    end
    else begin
     ar3:= nil;
    end;
    int2:= 0;
    while reader.readlogbufferheader(header1) do begin
     case header1.flag of
      lf_rec: begin
       with header1.rec do begin
        if not findrec(po,po1,int1) then begin
         if kind <> ukinsert then begin
          formaterror;
         end;
         reader.readrecord(femptybuffer);
         appendrecord(femptybuffer);
         femptybuffer:= intallocrecord;
         additem(appended,po);
        end
        else begin
         reader.readrecord(po1);
        end;
       end;        
      end;
      lf_update: begin
       if high(updabuf) < int2 then begin
        setlength(updabuf,2*high(updabuf)+258);
        setlength(oldupdatepointers,length(updabuf));
       end;     
       with updabuf[int2],header1.update do begin
        info.updatekind:= kind;
        oldupdatepointers[int2]:= po;
        int3:= -1;
        if deletedrecord <> nil then begin
         for int1:= 0 to int2 - 1 do begin
          if oldupdatepointers[int1] = deletedrecord then begin
           int3:= int1;
           break;
          end;
         end;
        end;
        if kind = ukdelete then begin 
         if logging and (po <> deletedrecord) then begin
          if (int3 < 0) or 
                           not findrec(deletedrecord,po1,int1,true) then begin
           formaterror;
          end;
          if po = nil then begin
           info.bookmark.recordpo:= nil;   //deleting of inserted record
           intfreerecord(pintrecordty(po1));
          end
          else begin                  //deleting of modified record
           intfreerecord(updabuf[int3].info.bookmark.recordpo);
           info.bookmark.recordpo:= updabuf[int3].oldvalues;
           info.bookmark.recno:= 0;
          end;
          updabuf[int3].info.bookmark.recordpo:= nil; //to be removed
         end
         else begin
          if logging then begin
           if not findrec(deletedrecord,pointer(info.bookmark.recordpo),
                                         info.bookmark.recno,true) then begin
            formaterror;
           end;
          end
          else begin
           info.bookmark.recno:= 0;
           info.bookmark.recordpo:= intallocrecord;
           reader.readrecord(info.bookmark.recordpo);
          end;
         end;
         oldvalues:= info.bookmark.recordpo;
        end
        else begin
         if not findrec(po,pointer(info.bookmark.recordpo),
                                         info.bookmark.recno) then begin
          formaterror;        //old pointer not found
         end;
        end;
        if kind = ukmodify then begin
         oldvalues:= intallocrecord;
         reader.readrecord(oldvalues);
        end;
       end;
       inc(int2);
      end;
      lf_cancel: begin
       with header1.update do begin
        int3:= -1;
        for int1:= 0 to int2 - 1 do begin
         if oldupdatepointers[int1] = po then begin
          int3:= int1;
          break;
         end;
        end;
        if int3 < 0 then begin
         formaterror;
        end;
        case kind of
         ukmodify: begin
          cancelrecupdate(updabuf[int3]);
         end;
         ukdelete: begin
          with updabuf[int3] do begin
           appendrecord(info.bookmark.recordpo);
           additem(appended,oldupdatepointers[int3]);
//           additem(appended,bookmark.recordpo);
          end;
         end;
         ukinsert: begin
          if not findrec(oldupdatepointers[int3],po1,int1,true) then begin
           formaterror;
          end;
          with updabuf[int3] do begin
           intfreerecord(info.bookmark.recordpo);
          end;
         end;
        end;
        updabuf[int3].info.bookmark.recordpo:= nil;
        oldupdatepointers[int3]:= nil;
                    //inactive
       end;
      end;
      lf_apply: begin
       with header1.update do begin
        int3:= -1;
        for int1:= 0 to int2-1 do begin
         if oldupdatepointers[int1] = po then begin
          int3:= int1;
          break;
         end;
        end;
        if int3 < 0 then begin
         formaterror;
        end;
        with updabuf[int3] do begin
         intfreerecord(oldvalues);
         info.bookmark.recordpo:= nil;
         oldupdatepointers[int3]:= nil;
                    //inactive
        end;
       end;
      end;
      else begin
       formaterror;
      end;
     end;
    end; 
    setlength(updabuf,int2);
    setlength(fupdatebuffer,int2);   
    int2:= 0;     //pack updatebuffer
    for int1:= 0 to high(updabuf) do begin
     if updabuf[int1].info.bookmark.recordpo <> nil then begin
      fupdatebuffer[int2]:= updabuf[int1];
      inc(int2);
     end;
    end;
    setlength(fupdatebuffer,int2);
    fallpacketsfetched:= true;
   end;
   include(fbstate,bs_blobsfetched);
   sortblobcache;
  except
   dointernalclose;
   raise;
  end;
 finally
  reader.free;
  factindex:= actindexbefore;
  factindexpo:= @findexes[factindex];
 end;
end;

procedure tmsebufdataset.loadfromstream(const astream: tstream);
begin
 checkinactive;
 floadingstream:= astream;
 include(fbstate,bs_loading);
 try
  active:= true;
 finally
  exclude(fbstate,bs_loading);
 end;
end;

function tmsebufdataset.streamloading: boolean;
begin
 result:= bs_loading in fbstate;
end;

function tmsebufdataset.addblobcache(const adata: pointer;
                         const alength: integer): integer;
begin
 if ffreedblobcount > 0 then begin
  dec(ffreedblobcount);
  result:= ffreedblobs[ffreedblobcount];
  if (ffreedblobcount = 0) and (high(ffreedblobs) > 10000) then begin
   ffreedblobs:= nil;
  end;
 end
 else begin
  result:= fblobcount;
  inc(fblobcount);
  if result > high(fblobcache) then begin
   setlength(fblobcache,2*result+256);
  end;
 end;
 with fblobcache[result] do begin
  id:= result;
  setlength(data,alength);
 {$ifdef FPC} {$checkpointer off} {$endif} //adata can be foreign memory
  move(adata^,pointer(data)^,alength);
 {$ifdef FPC} {$checkpointer default} {$endif}
 end;
 exclude(fbstate,bs_blobssorted);
end;

function tmsebufdataset.addblobcache(const aid: int64;
                                const adata: string): integer;
begin
 result:= fblobcount;
 inc(fblobcount);
 if result > high(fblobcache) then begin
  setlength(fblobcache,2*result+256);
 end;
 with fblobcache[result] do begin
  id:= aid;
  data:= adata;
 end;
 exclude(fbstate,bs_blobssorted);
end;
{
function tmsebufdataset.wantblobfetch: boolean;
begin
 result:= false;
end;
}
function tmsebufdataset.getdsoptions: datasetoptionsty;
begin
 result:= [];
end;

procedure tmsebufdataset.checkconnected;
begin
 if not (bs_connected in fbstate) then begin
  databaseerror('Not connected.',self);
 end;
end;

procedure tmsebufdataset.savetofile(const afilename: filenamety;
                         const acryptohandler: tcustomcryptohandler = nil);
var
 stream1: tmsefilestream;
begin
 stream1:= tmsefilestream.create(afilename,fm_create);
 try
  stream1.cryptohandler:= acryptohandler;
  savetostream(stream1);
 finally
  stream1.free;
 end;
end;

procedure tmsebufdataset.loadfromfile(const afilename: filenamety;
                         const acryptohandler: tcustomcryptohandler = nil);
var
 stream1: tmsefilestream;
begin
 stream1:= tmsefilestream.create(afilename,fm_read);
 try
  stream1.cryptohandler:= acryptohandler;
  loadfromstream(stream1);
 finally
  stream1.free;
 end;
end;

procedure tmsebufdataset.checklogfile;
begin
 if trim(flogfilename) = '' then begin
  databaseerror('No log file name.',self);
 end;
end;

procedure tmsebufdataset.recover;
begin
 checklogfile;
 if islocal then begin
  active:= true;
 end
 else begin
  loadfromfile(flogfilename,fcryptohandler);
  startlogger;
 end;
end;

procedure tmsebufdataset.startlogger;
var
 stream1: tmsefilestream;
begin
 if flogfilename <> '' then begin
  stream1:= tmsefilestream.create(flogfilename,fm_create);
  stream1.cryptohandler:= fcryptohandler;
  flogger:= tbufstreamwriter.create(self,stream1);
  savestate(flogger);
  flogger.flushbuffer;
 end;
end;

procedure tmsebufdataset.closelogger;
var
 stream1: tstream;
begin
 if flogger <> nil then begin
  flogger.writeendmarker;
  stream1:= flogger.fstream;
  freeandnil(flogger);
  stream1.free;
 end;
end;

procedure tmsebufdataset.startlogging; 
  //close logfile, save state with truncated log, open logfile
begin
 checklogfile;
 checkbrowsemode;
 closelogger;
 startlogger;
end;

procedure tmsebufdataset.stoplogging; 
  //close logfile
begin
 closelogger; 
end;

function tmsebufdataset.getlogging: boolean;
begin
 result:= flogger <> nil;
end;

function tmsebufdataset.islocal: boolean;
begin
 result:= false;
end;

procedure tmsebufdataset.dobeforeapplyupdate;
begin
 if checkcanevent(self,tmethod(fbeforeapplyupdate)) then begin
  fbeforeapplyupdate(self);
 end;
end;

procedure tmsebufdataset.doafterapplyupdate;
begin
 if checkcanevent(self,tmethod(fafterapplyupdate)) then begin
  fafterapplyupdate(self);
 end;
end;

procedure tmsebufdataset.notifycontrols;
var
 int1: integer;
begin
 int1:= 0;
 try
  while controlsdisabled do begin
   inc(int1);
   enablecontrols;
  end;
 finally
  while int1 > 0 do begin
   dec(int1);
   disablecontrols;
  end;
 end;
end;

procedure tmsebufdataset.OpenCursor(InfoQuery: Boolean);
begin
 inherited;
// tdatasetcracker(self).fbof:= true;
end;

function tmsebufdataset.GetNextRecord: Boolean;
begin
 result:= inherited getnextrecord;
// if frecno = 0 then begin
//  tdatasetcracker(self).fbof:= true;
// end;
end;

function tmsebufdataset.GetNextRecords: Longint;
begin
 result:= inherited getnextrecords;
// if frecno = 0 then begin
//  tdatasetcracker(self).fbof:= true;
// end;
end;

function tmsebufdataset.getfiltereditkind: filtereditkindty;
begin
 result:= ffiltereditkind;
end;

function tmsebufdataset.getrestorerecno: boolean;
begin
 result:= bs_restorerecno in fbstate;
end;

procedure tmsebufdataset.setrestorerecno(const avalue: boolean);
begin
 if avalue then begin
  include(fbstate,bs_restorerecno);
 end
 else begin
  exclude(fbstate,bs_restorerecno);
 end;
end;

function tmsebufdataset.islastrecord: boolean;
begin
 result:= eof;
 if not result then begin
  fetchall;  
  result:= recno = recordcount;
 end;
end;

procedure tmsebufdataset.currentbeginupdate;
begin
 currentcheckbrowsemode;
 inc(fcurrentupdating);
end;
{
procedure tmsebufdataset.currentdecupdate;
begin
 dec(fcurrentupdating);
 if fcurrentupdating = 0 then begin
  exclude(fbstate,bs_curvalueset);
 end;
end;
}
procedure tmsebufdataset.fixupcurrentset;
begin
 if not (bs_recapplying in fbstate) then begin
  if factindexpo^.ind = nil then begin
   bookmark:= bookmark; //possibly invalid recno
  end
  else begin
   resync([]);
  end;
 end
 else begin
  include(fbstate1,bs1_needsresync);
 end;
end;

procedure tmsebufdataset.currentendupdate;
begin
 dec(fcurrentupdating);
 if fcurrentupdating = 0 then begin
  if bs_curvalueset in fbstate then begin
   exclude(fbstate,bs_curvalueset);
   findexlocal.preparefixup;
   fixupcurrentset;
  end;
 end;
end;

procedure tmsebufdataset.currentcheckbrowsemode;
begin
 if (state <> dsbrowse) and (fcurrentupdating = 0) then begin
  checkbrowsemode;
 end;
end;

function tmsebufdataset.getcurrentpo(const afield: tfield;
        const afieldtype: tfieldtype; const arecord: pintrecordty): pointer;
var
 int1: integer;
begin
 int1:= afield.fieldno-1;
 if not getfieldflag(@arecord^.header.fielddata.nullmask,int1) then begin
  result:= nil;
 end
 else begin
  with ffieldinfos[int1] do begin
   if (afieldtype <> ftunknown) and 
        not (ext.basetype in fielddatacompatibility[afieldtype]) then begin
    raise ecurrentvalueaccess.create(self,afield,'Invalid fieldtype.');  
   end;   
   result:= pchar(pointer(arecord)) + base.offset;
  end;
 end;
end;

function tmsebufdataset.getcurrentlookuppo(const afield: tfield;
        const afieldtype: tfieldtype; const arecord: pintrecordty): pointer;
var
 po1: pointer;
 bm1: bookmarkdataty;
begin
 result:= nil;
 with flookupfieldinfos[-1-afield.fieldno] do begin
  if indexnum < 0 then begin
   raise ecurrentvalueaccess.create(self,afield,'No lookup index.');  
  end;
  if (afieldtype <> ftunknown) and 
       not (basedatatype in fielddatacompatibility[afieldtype]) then begin
   raise ecurrentvalueaccess.create(self,afield,'Invalid fieldtype.');  
  end;   
  po1:= flookuppo;
  flookuppo:= arecord;
  try   
   if afield.lookupdataset.active and 
      tmsebufdataset(afield.lookupdataset).indexlocal[indexnum].find(
                                                    keyfieldar,bm1) then begin
    if lookupvaluefield.fieldno > 0 then begin
     getvalue(lookupvaluefield,bm1,flookupresult);     
     result:= flookupresult.po;
    end
    else begin
     if afield.lookupdataset <> nil then begin
      with tmsebufdataset(afield.lookupdataset) do begin
       currentcheckbrowsemode;
       result:= getcurrentlookuppo(lookupvaluefield,afieldtype,bm1.recordpo);
      end;
     end;
    end;
   end;
  finally
   flookuppo:= po1;
  end;
 end;
end;

function tmsebufdataset.beforecurrentget(const afield: tfield;
              const afieldtype: tfieldtype; var aindex: integer): pointer;
begin
 currentcheckbrowsemode;
 if afield.dataset <> self then begin
  raise ecurrentvalueaccess.create(self,afield,'Wrong dataset.');
 end;
 checkindex(false);
 if aindex < 0 then begin
  aindex:= frecno;
 end;
 if (aindex < 0) or (aindex > high(factindexpo^.ind)) then begin
  raise ecurrentvalueaccess.create(self,afield,
                             'Invalid index '+inttostr(aindex)+'.');  
 end; 
 if afield.fieldkind = fkcalculated then begin
  raise ecurrentvalueaccess.create(self,afield,
               'Field can not be be fkCalculated.');
 end;
 if afield.fieldno < 0 then begin
  result:= getcurrentlookuppo(afield,afieldtype,factindexpo^.ind[aindex]);
 end
 else begin
  result:= getcurrentpo(afield,afieldtype,factindexpo^.ind[aindex]);
 end;
end;

function tmsebufdataset.beforecurrentbmget(const afield: tfield;
              const afieldtype: tfieldtype; const abm: bookmarkdataty): pointer;
begin
 currentcheckbrowsemode;
 if afield.dataset <> self then begin
  raise ecurrentvalueaccess.create(self,afield,'Wrong dataset.');
 end;
 if afield.fieldkind = fkcalculated then begin
  raise ecurrentvalueaccess.create(self,afield,
               'Field can not be be fkCalculated.');
 end;
 result:= nil;
 if abm.recordpo <> nil then begin
  if (afield.fieldno < 0) then begin
   result:= getcurrentlookuppo(afield,afieldtype,abm.recordpo);
  end
  else begin
   result:= getcurrentpo(afield,afieldtype,abm.recordpo);
  end;
 end;
end;

function tmsebufdataset.setcurrentpo(const afield: tfield;
              const afieldtype: tfieldtype; const arecord: precheaderty;
              const aisnull: boolean; out changed: boolean): pointer;
var
 po1: pbyte;
 int1: integer;
begin
// flastcurrentrec:= pointer(arecord) - sizeof(intrecordty.intheader);
 po1:= @arecord^.fielddata.nullmask;
 int1:= afield.fieldno-1;
 with ffieldinfos[int1] do begin
  if (afieldtype <> ftunknown) and 
           not (ext.basetype in fielddatacompatibility[afieldtype]) then begin
   raise ecurrentvalueaccess.create(self,afield,'Invalid fieldtype.');  
  end;   
  changed:= not getfieldflag(po1,int1) xor aisnull;
  if changed then begin
   if aisnull then begin
    clearfieldflag(po1,int1);
   end
   else begin
    setfieldflag(po1,int1);
   end;
  end;
  result:= pchar(pointer(arecord)) + base.offset;
 end;
end;

function tmsebufdataset.beforecurrentset(const afield: tfield;
              const afieldtype: tfieldtype; var aindex: integer;
              const aisnull: boolean; out changed: boolean): pointer;
begin
 currentcheckbrowsemode;
 if afield.dataset <> self then begin
  raise ecurrentvalueaccess.create(self,afield,'Wrong dataset.');
 end;
 if (afield.fieldkind <> fkinternalcalc) then begin
  raise ecurrentvalueaccess.create(self,afield,'Field must be fkInternalCalc.');
 end;
 checkindex(false);
 if aindex < 0 then begin
  aindex:= frecno;
 end;
 if (aindex < 0) or (aindex > high(factindexpo^.ind)) then begin
  raise ecurrentvalueaccess.create(self,afield,
                             'Invalid index '+inttostr(aindex)+'.');  
 end; 
 flastcurrentindex:= aindex;
 result:= setcurrentpo(afield,afieldtype,factindexpo^.ind[aindex],
                                                      aisnull,changed);
end;

function tmsebufdataset.beforecurrentbmset(const afield: tfield;
              const afieldtype: tfieldtype; const abm: bookmarkdataty;
              const aisnull: boolean; out changed: boolean): pointer;
begin
 currentcheckbrowsemode;
 if afield.dataset <> self then begin
  raise ecurrentvalueaccess.create(self,afield,'Wrong dataset.');
 end;
 if (afield.fieldkind <> fkinternalcalc) then begin
  raise ecurrentvalueaccess.create(self,afield,'Field must be fkInternalCalc.');
 end;
 flastcurrentindex:= -1;
 result:= setcurrentpo(afield,afieldtype,@abm.recordpo^.header,aisnull,changed);
end;

procedure tmsebufdataset.aftercurrentset(const afield: tfield);
//var
// int1: integer;
begin
 if fcurrentupdating = 0 then begin
  findexlocal.fieldmodified(afield,false);
  fixupcurrentset;
 end
 else begin
  include(fbstate,bs_curvalueset);
  findexlocal.fieldmodified(afield,true);
 end;
end;

function tmsebufdataset.getcurrentisnull(const afield: tfield;
               aindex: integer): boolean;
begin
 result:= beforecurrentget(afield,ftunknown,aindex) = nil;
end;

function tmsebufdataset.getcurrentbmisnull(const afield: tfield;
               const abm: bookmarkdataty): boolean;
begin
 result:= beforecurrentbmget(afield,ftunknown,abm) = nil;
end;

procedure tmsebufdataset.currentclear(const afield: tfield; aindex: integer);
var
 bo1: boolean;
begin
 beforecurrentset(afield,ftunknown,aindex,true,bo1);
 if bo1 then begin
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.currentbmclear(const afield: tfield;
               const abm: bookmarkdataty);
var
 bo1: boolean;
begin
 beforecurrentbmset(afield,ftunknown,abm,true,bo1);
 if bo1 then begin
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.currentassign(const source: tfield; const dest: tfield;
                              aindex: integer);
var
 po1: pointer;
begin
 po1:= beforecurrentget(source,source.datatype,aindex);
 if (po1 = nil) or (source.fieldno = 0) then begin
  dest.clear;
 end
 else begin
  if source.fieldno > 0 then begin
   docurrentassign(po1,ffieldinfos[source.fieldno-1].ext.basetype,dest);
  end
  else begin
   docurrentassign(po1,flookupfieldinfos[-1-source.fieldno].basedatatype,dest);   
  end;
 end;
end;

procedure tmsebufdataset.currentbmassign(const source: tfield; const dest: tfield;
                              const abm: bookmarkdataty);
var
 po1: pointer;
begin
 po1:= beforecurrentbmget(source,source.datatype,abm);
 if (po1 = nil) or (source.fieldno = 0) then begin
  dest.clear;
 end
 else begin
  if source.fieldno > 0 then begin
   docurrentassign(po1,ffieldinfos[source.fieldno-1].ext.basetype,dest);
  end
  else begin
   docurrentassign(po1,flookupfieldinfos[-1-source.fieldno].basedatatype,dest);   
  end;
 end;
end;

function tmsebufdataset.getcurrentasvariant(const afield: tfield;
               aindex: integer): variant;
begin
 if currentisnull[afield,aindex] then begin
  result:= null;
 end
 else begin
  case afield.datatype of
   ftboolean: begin
    result:= getcurrentasboolean(afield,aindex);
   end;
   ftfloat: begin
    result:= getcurrentasfloat(afield,aindex);
   end;
   ftdatetime,fttime,ftdate: begin
    result:= getcurrentasdatetime(afield,aindex);
   end;
   ftbcd: begin
    result:= getcurrentascurrency(afield,aindex);
   end;
   ftinteger,ftword,ftsmallint: begin
    result:= getcurrentasinteger(afield,aindex);
   end;
   ftlargeint: begin
    result:= getcurrentaslargeint(afield,aindex);
   end;
   ftstring: begin
    result:= getcurrentasmsestring(afield,aindex);
   end;
   else begin
    raise ecurrentvalueaccess.create(self,afield,
                             'Invalid fieldtype field "'+afield.fieldname+'".');  
   end;
  end;
 end; 
end;

procedure tmsebufdataset.setcurrentasvariant(const afield: tfield;
               aindex: integer; const avalue: variant);
begin
 if varisnull(avalue) then begin
  currentclear(afield,aindex)
 end
 else begin
  case afield.datatype of
   ftboolean: begin
    setcurrentasboolean(afield,aindex,avalue);
   end;
   ftfloat: begin
    setcurrentasfloat(afield,aindex,avalue);
   end;
   ftdatetime,fttime,ftdate: begin
    setcurrentasdatetime(afield,aindex,avalue);
   end;
   ftbcd: begin
    setcurrentascurrency(afield,aindex,avalue);
   end;
   ftinteger,ftword,ftsmallint: begin
    setcurrentasinteger(afield,aindex,avalue);
   end;
   ftlargeint: begin
    setcurrentaslargeint(afield,aindex,avalue);
   end;
   ftstring: begin
    setcurrentasmsestring(afield,aindex,avalue);
   end;  
   else begin
    raise ecurrentvalueaccess.create(self,afield,
                             'Invalid fieldtype field "'+afield.fieldname+'".');  
   end;
  end;
 end; 
end;

function tmsebufdataset.getcurrentbmasvariant(const afield: tfield;
               const abm: bookmarkdataty): variant;
begin
 if currentbmisnull[afield,abm] then begin
  result:= null;
 end
 else begin
  case afield.datatype of
   ftboolean: begin
    result:= getcurrentbmasboolean(afield,abm);
   end;
   ftfloat: begin
    result:= getcurrentbmasfloat(afield,abm);
   end;
   ftdatetime,fttime,ftdate: begin
    result:= getcurrentbmasdatetime(afield,abm);
   end;
   ftbcd: begin
    result:= getcurrentbmascurrency(afield,abm);
   end;
   ftinteger,ftword,ftsmallint: begin
    result:= getcurrentbmasinteger(afield,abm);
   end;
   ftlargeint: begin
    result:= getcurrentbmaslargeint(afield,abm);
   end;
   ftstring: begin
    result:= getcurrentbmasmsestring(afield,abm);
   end;
   else begin
    raise ecurrentvalueaccess.create(self,afield,
                             'Invalid fieldtype field "'+afield.fieldname+'".');  
   end;
  end;
 end; 
end;

procedure tmsebufdataset.setcurrentbmasvariant(const afield: tfield;
               const abm: bookmarkdataty; const avalue: variant);
begin
 if varisnull(avalue) then begin
  currentbmclear(afield,abm)
 end
 else begin
  case afield.datatype of
   ftboolean: begin
    setcurrentbmasboolean(afield,abm,avalue);
   end;
   ftfloat: begin
    setcurrentbmasfloat(afield,abm,avalue);
   end;
   ftdatetime,fttime,ftdate: begin
    setcurrentbmasdatetime(afield,abm,avalue);
   end;
   ftbcd: begin
    setcurrentbmascurrency(afield,abm,avalue);
   end;
   ftinteger,ftword,ftsmallint: begin
    setcurrentbmasinteger(afield,abm,avalue);
   end;
   ftlargeint: begin
    setcurrentbmaslargeint(afield,abm,avalue);
   end;
   ftstring: begin
    setcurrentbmasmsestring(afield,abm,avalue);
   end;  
   else begin
    raise ecurrentvalueaccess.create(self,afield,
                             'Invalid fieldtype field "'+afield.fieldname+'".');  
   end;
  end;
 end; 
end;

function tmsebufdataset.getcurrentasguid(const afield: tfield;
                                                 aindex: integer): tguid;
var
 po1: pguid;
begin
 po1:= beforecurrentget(afield,ftfloat,aindex);
 if po1 = nil then begin
  result:= guid_null;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasguid(const afield: tfield; aindex: integer;
                   const avalue: tguid);
var
 po1: pguid;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftfloat,aindex,false,bo1);
 if bo1 or not isequalguid(po1^,avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentasfloat(const afield: tfield;
               aindex: integer): double;
var
 po1: pdouble;
begin
 po1:= beforecurrentget(afield,ftfloat,aindex);
 if po1 = nil then begin
  result:= emptyreal;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasfloat(const afield: tfield;
               const abm: bookmarkdataty): double;
var
 po1: pdouble;
begin
 po1:= beforecurrentbmget(afield,ftfloat,abm);
 if po1 = nil then begin
  result:= emptyreal;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasfloat(const afield: tfield;
              aindex: integer; const avalue: double);
var
 po1: pdouble;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftfloat,aindex,avalue = emptyreal,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasfloat(const afield: tfield;
               const abm: bookmarkdataty; const avalue: double);
var
 po1: pdouble;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftfloat,abm,avalue = emptyreal,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentasboolean(const afield: tfield;
               aindex: integer): boolean;
var
 po1: plongbool;
begin
 po1:= beforecurrentget(afield,ftboolean,aindex);
 if po1 = nil then begin
  result:= false;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasboolean(const afield: tfield;
               const abm: bookmarkdataty): boolean;
var
 po1: plongbool;
begin
 po1:= beforecurrentbmget(afield,ftboolean,abm);
 if po1 = nil then begin
  result:= false;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasboolean(const afield: tfield;
               aindex: integer; const avalue: boolean);
var
 po1: plongbool;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftboolean,aindex,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasboolean(const afield: tfield;
               const abm: bookmarkdataty; const avalue: boolean);
var
 po1: plongbool;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftboolean,abm,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentasinteger(const afield: tfield;
               aindex: integer): integer;
var
 po1: pinteger;
begin
 po1:= beforecurrentget(afield,ftinteger,aindex);
 if po1 = nil then begin
  result:= 0;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasinteger(const afield: tfield;
               const abm: bookmarkdataty): integer;
var
 po1: pinteger;
begin
 po1:= beforecurrentbmget(afield,ftinteger,abm);
 if po1 = nil then begin
  result:= 0;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasinteger(const afield: tfield;
               aindex: integer; const avalue: integer);
var
 po1: pinteger;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftinteger,aindex,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasinteger(const afield: tfield;
               const abm: bookmarkdataty; const avalue: integer);
var
 po1: pinteger;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftinteger,abm,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentaslargeint(const afield: tfield;
               aindex: integer): int64;
var
 po1: pint64;
begin
 po1:= beforecurrentget(afield,ftlargeint,aindex);
 if po1 = nil then begin
  result:= 0;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmaslargeint(const afield: tfield;
               const abm: bookmarkdataty): int64;
var
 po1: pint64;
begin
 po1:= beforecurrentbmget(afield,ftlargeint,abm);
 if po1 = nil then begin
  result:= 0;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentaslargeint(const afield: tfield;
               aindex: integer; const avalue: int64);
var
 po1: pint64;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftlargeint,aindex,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmaslargeint(const afield: tfield;
               const abm: bookmarkdataty; const avalue: int64);
var
 po1: pint64;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftlargeint,abm,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentasid(const afield: tfield;
               aindex: integer): int64;
var
 po1: pint64;
begin
 po1:= beforecurrentget(afield,ftlargeint,aindex);
 if po1 = nil then begin
  result:= -1;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasid(const afield: tfield;
               const abm: bookmarkdataty): int64;
var
 po1: pint64;
begin
 po1:= beforecurrentbmget(afield,ftlargeint,abm);
 if po1 = nil then begin
  result:= -1;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasid(const afield: tfield; aindex: integer;
               const avalue: int64);
var
 po1: pint64;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftlargeint,aindex,avalue = -1,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasid(const afield: tfield;
               const abm: bookmarkdataty; const avalue: int64);
var
 po1: pint64;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftlargeint,abm,avalue = -1,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentasdatetime(const afield: tfield;
               aindex: integer): tdatetime;
var
 po1: pdatetime;
begin
 po1:= beforecurrentget(afield,ftdatetime,aindex);
 if po1 = nil then begin
  result:= emptydatetime;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasdatetime(const afield: tfield;
               const abm: bookmarkdataty): tdatetime;
var
 po1: pdatetime;
begin
 po1:= beforecurrentbmget(afield,ftdatetime,abm);
 if po1 = nil then begin
  result:= emptydatetime;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasdatetime(const afield: tfield;
               aindex: integer; const avalue: tdatetime);
var
 po1: pdouble;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftdatetime,aindex,avalue = emptydatetime,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasdatetime(const afield: tfield;
               const abm: bookmarkdataty; const avalue: tdatetime);
var
 po1: pdouble;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftdatetime,abm,avalue = emptydatetime,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentascurrency(const afield: tfield;
               aindex: integer): currency;
var
 po1: pcurrency;
begin
 po1:= beforecurrentget(afield,ftbcd,aindex);
 if po1 = nil then begin
  result:= 0;
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmascurrency(const afield: tfield;
               const abm: bookmarkdataty): currency;
var
 po1: pcurrency;
begin
 po1:= beforecurrentbmget(afield,ftbcd,abm);
 if po1 = nil then begin
  result:= 0;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentascurrency(const afield: tfield;
               aindex: integer; const avalue: currency);
var
 po1: pcurrency;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftbcd,aindex,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmascurrency(const afield: tfield;
               const abm: bookmarkdataty; const avalue: currency);
var
 po1: pcurrency;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftbcd,abm,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

function tmsebufdataset.getcurrentasmsestring(const afield: tfield;
               aindex: integer): msestring;
var
 po1: pmsestring;
begin
 po1:= beforecurrentget(afield,ftwidestring,aindex);
 if po1 = nil then begin
  result:= '';
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasmsestring(const afield: tfield;
               const abm: bookmarkdataty): msestring;
var
 po1: pmsestring;
begin
 po1:= beforecurrentbmget(afield,ftwidestring,abm);
 if po1 = nil then begin
  result:= '';
 end
 else begin
  result:= po1^;
 end;
end;

function tmsebufdataset.getcurrentbmasguid(const afield: tfield;
                                     const abm: bookmarkdataty): tguid;
var
 po1: pguid;
begin
 po1:= beforecurrentbmget(afield,ftguid,abm);
 if po1 = nil then begin
  result:= guid_null;
 end
 else begin
  result:= po1^;
 end;
end;

procedure tmsebufdataset.setcurrentasmsestring(const afield: tfield;
               aindex: integer; const avalue: msestring);
var
 po1: pmsestring;
 bo1: boolean;
begin
 po1:= beforecurrentset(afield,ftwidestring,aindex,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasmsestring(const afield: tfield;
               const abm: bookmarkdataty; const avalue: msestring);
var
 po1: pmsestring;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftwidestring,abm,false,bo1);
 if bo1 or (po1^ <> avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.setcurrentbmasguid(const afield: tfield;
                                     const abm: bookmarkdataty;
                   const avalue: tguid);
var
 po1: pguid;
 bo1: boolean;
begin
 po1:= beforecurrentbmset(afield,ftguid,abm,false,bo1);
 if bo1 or not isequalguid(po1^,avalue) then begin
  po1^:= avalue;
  aftercurrentset(afield);
 end;
end;

procedure tmsebufdataset.getbminteger(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pinteger;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.int:= po1^;
  adata.po:= @adata.int;
 end;
end;

procedure tmsebufdataset.getbmlargeint(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pint64;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.lint:= po1^;
  adata.po:= @adata.lint;
 end;
end;

procedure tmsebufdataset.getbmcurrency(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pcurrency;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.cur:= po1^;
  adata.po:= @adata.cur;
 end;
end;

procedure tmsebufdataset.getbmfloat(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pdouble;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.doub:= po1^;
  adata.po:= @adata.doub;
 end;
end;

procedure tmsebufdataset.getbmstring(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pmsestring;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.mstr:= po1^;
  adata.po:= @adata.mstr;
 end;
end;

procedure tmsebufdataset.getbmguid(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pguid;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.guid:= po1^;
  adata.po:= @adata.guid;
 end;
end;

procedure tmsebufdataset.getbmboolean(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: plongbool;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.boo:= po1^;
  adata.po:= @adata.boo;
 end;
end;

procedure tmsebufdataset.getbmdatetime(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pdatetime;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.dt:= po1^;
  adata.po:= @adata.dt;
 end;
end;

procedure tmsebufdataset.getbmvariant(const afield: tfield;
               const bm: bookmarkdataty; var adata: lookupdataty);
var
 po1: pvariant;
begin
 po1:= getcurrentpo(afield,ftunknown,@bm.recordpo^.header);
 if po1 <> nil then begin
  adata.vari:= po1^;
  adata.po:= @adata.vari;
 end;
end;

procedure tmsebufdataset.dogetcoldata(const afield: tfield;
                       const afieldtype: tfieldtype; const step: integer;
                                                      const data: pointer);
var
 po2: pointer;
 offs: ptrint;
 indexpo: ppointer;
 int1: integer;
 ft1: tfieldtype;
 
begin
 if afield.dataset <> self then begin
  raise ecurrentvalueaccess.create(self,afield,'Wrong dataset.');
 end;
 if afield.index < 0 then begin
  raise ecurrentvalueaccess.create(self,afield,
                 'Field can not be be fkCalculated or fkLookup.');
 end;
 ft1:= afieldtype;
 if ft1 = ftwidestring then begin 
  ft1:= ftstring
 end;
 checkindex(false);
 int1:= afield.fieldno-1;
 with ffieldinfos[int1] do begin
  if not (ext.basetype in fielddatacompatibility[ft1]) then begin
   raise ecurrentvalueaccess.create(self,afield,'Invalid fieldtype.');  
  end;   
  offs:= base.offset;
 end;
 po2:= data;
 indexpo:= pointer(factindexpo^.ind);
 case afieldtype of
  ftinteger: begin
   for int1:= 0 to fbrecordcount-1 do begin
    pinteger(po2)^:= pinteger(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
  ftlargeint: begin
   for int1:= 0 to fbrecordcount-1 do begin
    pint64(po2)^:= pint64(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
  ftboolean: begin
   for int1:= 0 to fbrecordcount-1 do begin
    pboolean(po2)^:= plongbool(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
  ftcurrency: begin
   for int1:= 0 to fbrecordcount-1 do begin
    pcurrency(po2)^:= pcurrency(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
  ftfloat,ftdatetime: begin
   for int1:= 0 to fbrecordcount-1 do begin
    prealty(po2)^:= pdouble(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
  ftstring: begin
   for int1:= 0 to fbrecordcount-1 do begin
    pansistring(po2)^:= pmsestring(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
  ftwidestring: begin
   for int1:= 0 to fbrecordcount-1 do begin
    pmsestring(po2)^:= pmsestring(pchar(ppointeraty(indexpo)^[int1])+offs)^;
    inc(pchar(po2),step);
   end;
  end;
 end;
end;

procedure tmsebufdataset.getcoldata(const afield: tfield;
               const adatalist: tdatalist);
var
 type1: tfieldtype;
begin
 currentcheckbrowsemode;
 with adatalist do begin
  type1:= ftunknown;
  case adatalist.datatype of
   dl_integer: begin
    type1:= ftinteger;
   end;
   dl_int64: begin
    type1:= ftlargeint;
   end;
   dl_currency: begin
    type1:= ftcurrency;
   end;
   dl_real,dl_realint,dl_realsum,dl_datetime: begin
    type1:= ftfloat;
   end;
   dl_ansistring: begin
    type1:= ftstring;
   end;
   dl_msestring,dl_doublemsestring,dl_msestringint: begin
    type1:= ftwidestring;
   end;
  end;
  if type1 <> ftunknown then begin
   beginupdate;
   try
    clear;
    count:= fbrecordcount;
    dogetcoldata(afield,type1,size,datapo);
   finally
    endupdate;
   end;
  end
  else begin
   raise ecurrentvalueaccess.create(self,afield,
                'Invalid datalist.');
  end;
 end;
end;

procedure tmsebufdataset.asarray(const afield: tfield;
                                      out avalue: int64arty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftlargeint,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield; out avalue: integerarty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftinteger,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield; out avalue: stringarty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftstring,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield;
               out avalue: msestringarty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftwidestring,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield;
               out avalue: currencyarty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftcurrency,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield; out avalue: realarty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftfloat,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield;
                                         out avalue: datetimearty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftdatetime,sizeof(avalue[0]),pointer(avalue)); 
end;

procedure tmsebufdataset.asarray(const afield: tfield;
                                         out avalue: booleanarty);
begin
 currentcheckbrowsemode;
 setlength(avalue,fbrecordcount);
 dogetcoldata(afield,ftboolean,sizeof(avalue[0]),pointer(avalue)); 
end;

function tmsebufdataset.currentrecordhigh: integer;
begin
 currentcheckbrowsemode;
 result:= fbrecordcount - 1;
end;

procedure tmsebufdataset.docurrentassign(const po1: pointer;
                                  const abasetype: tfieldtype;
                                           const df: tfield);
begin
 case abasetype of
  ftwidestring: begin
   if df is tmsestringfield then begin
    tmsestringfield(df).asmsestring:= pmsestring(po1)^;
   end
   else begin
    df.asstring:= pmsestring(po1)^;
   end;
  end;
  ftinteger: begin
   df.asinteger:= pinteger(po1)^;
  end;
  ftboolean: begin
   df.asboolean:= plongbool(po1)^;
  end;
  ftbcd: begin
   df.ascurrency:= pcurrency(po1)^;
  end;
  ftfloat: begin
   df.asfloat:= pdouble(po1)^;
  end;
  ftlargeint: begin
   df.aslargeint:= pint64(po1)^;
  end;
  ftdatetime: begin
   df.asdatetime:= pdatetime(po1)^;
  end;
  ftvariant: begin
   df.asvariant:= pvariant(po1)^;
  end
  else begin
   df.clear;
  end;
 end;
end;

procedure tmsebufdataset.copyfieldvalues(const bm: bookmarkdataty;
                                                    const dest: tdataset);
                        //copies field values with same name
var
 df: tfield;
 int1: integer;
 int2: integer;
 str1: string;
begin
 if not active then begin
  exit;
 end;
 currentcheckbrowsemode;
 for int1:= 0 to dest.fieldcount - 1 do begin
  df:= dest.fields[int1];
  if not df.readonly then begin
   str1:= uppercase(df.fieldname);
   for int2:= 0 to high(ffieldinfos)do begin
    with ffieldinfos[int2] do begin
     if (ext.uppername = str1) and (ext.basetype <> ftblob) and 
                      ext.field.visible and 
                     (ext.field.fieldkind <> fkcalculated) and
                     (ext.field.fieldkind <> fklookup) then begin
      if not getfieldflag(@bm.recordpo^.header.fielddata.nullmask,int2) then begin 
       df.clear;
      end
      else begin
       docurrentassign(pchar(bm.recordpo)+base.offset,
                          ffieldinfos[int2].ext.basetype,df);
{
       case ext.basetype of
        ftwidestring: begin
         if df is tmsestringfield then begin
          tmsestringfield(df).asmsestring:= pmsestring(po1)^;
         end
         else begin
          df.asstring:= pmsestring(po1)^;
         end;
        end;
        ftinteger: begin
         df.asinteger:= pinteger(po1)^;
        end;
        ftboolean: begin
         df.asboolean:= plongbool(po1)^;
        end;
        ftbcd: begin
         df.ascurrency:= pcurrency(po1)^;
        end;
        ftfloat: begin
         df.asfloat:= pdouble(po1)^;
        end;
        ftlargeint: begin
         df.aslargeint:= pint64(po1)^;
        end;
        ftdatetime: begin
         df.asdatetime:= pdatetime(po1)^;
        end;
        ftvariant: begin
         df.asvariant:= pvariant(po1)^;
        end
        else begin
//         databaseerror(name+': Invalid datatype.');
        end;
       end;
}
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.copyfieldvalues(const bm: bookmarkdataty;
               const dest: tmsebufdataset; const acancelupdate: boolean);
var
 bo1: boolean;
begin
 with dest do begin
  if not self.active or not active or fcontroller.posting1 then begin
   exit;
  end;
  bo1:= state = dsbrowse;
  disablecontrols;
  try
   edit;
   self.copyfieldvalues(bm,dest);
   if acancelupdate then begin
    include(fbstate,bs_noautoapply);
    post;
    cancelupdate(true);
   end
   else begin
    if bo1 then begin
     post;
    end;
   end;
  finally
   exclude(fbstate,bs_noautoapply);
   enablecontrols;
   if bo1 or acancelupdate then begin
    dataevent(dedatasetchange,0);
    dataevent(tdataevent(de_modified),0);
   end;
  end;
 end;
end;

function tmsebufdataset.refreshrecord(const asourcevalues: array of variant;
              const adestfields: array of tfield;
              const akeyvalue: array of variant; const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty;
var
 bm1,bm2: string;
 int1: integer;
// bo1: boolean;
begin
 if not active or fcontroller.posting1 then begin
  exit;
 end;
 checkbrowsemode;
 disablecontrols;
 bm2:= bookmark;
 try
  if keyindex < 0 then begin
   edit;
  end
  else begin
   if indexlocal[keyindex].findvariant(akeyvalue,bm1) then begin
    bookmark:= bm1;
    edit;
   end
   else begin
    if noinsert then begin
     result.recno:= -1;
     result.recordpo:= nil;
     exit;
    end;
    insert;
   end;
  end;
  for int1:= 0 to high(asourcevalues) do begin
   if int1 > high(adestfields) then begin
    break;
   end;
   adestfields[int1].value:= asourcevalues[int1];
  end;
  if acancelupdate then begin
   include(fbstate,bs_noautoapply);
   post;
   cancelupdate(true);
  end
  else begin
   post;
  end;
  result.recno:= frecno;
  result.recordpo:= fcurrentbuf;
 finally
  exclude(fbstate,bs_noautoapply);
  if restorerecno and (keyindex >= 0) then begin
   bookmark:= bm2;
  end;
  enablecontrols;
  dataevent(dedatasetchange,0);
  dataevent(tdataevent(de_modified),0);
 end;
end;

function tmsebufdataset.refreshrecord(const asourcefields: array of tfield;
              const adestfields: array of tfield;
              const akeyfield: array of tfield; const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty;
begin
 result:= refreshrecord(fieldvariants(asourcefields),adestfields,
               fieldvariants(akeyfield),keyindex,acancelupdate,restorerecno,
               noinsert);
end;

function tmsebufdataset.refreshrecord(const asourcefields: array of tfield;
              const adestfields: array of tfield;
              const akeyvalue: array of variant; const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty;
begin
 result:= refreshrecord(fieldvariants(asourcefields),adestfields,akeyvalue,keyindex,
                  acancelupdate,restorerecno,noinsert);
end;

function tmsebufdataset.refreshrecord(const asourcefields: array of tfield;
              const akeyfield: array of tfield; const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty;
var
 int1: integer;
 ar1: fieldarty;
begin
 setlength(ar1,length(asourcefields));
 for int1:= 0 to high(asourcefields) do begin
  ar1[int1]:= fieldbyname(asourcefields[int1].fieldname);
 end;
 result:= refreshrecord(asourcefields,ar1,akeyfield,keyindex,
                       acancelupdate,restorerecno,noinsert);
end;
{
procedure tmsebufdataset.refreshrecord(const akeyfield: tfield;
          const keyindex: integer = 0; const acancelupdate: boolean = true);
var
 int1,int2: integer;
 field1,field2: tfield;
 sf,df: fieldarty;
begin
 with akeyfield.dataset do begin
  int2:= 0;
  setlength(sf,fields.count); //max
  setlength(df,fields.count); //max
  for int1:= 0 to high(sf) do begin
   field1:= fields[int1];
   if field1.visible then begin
    field2:= self.findfield(field1.fieldname);
    if (field2 <> nil) and not field2.readonly then begin
     sf[int2]:= field1;
     df[int2]:= field2;
     inc(int2);
    end;
   end;
  end;
 end;
 setlength(sf,int2);
 setlength(df,int2);
 refreshrecord(sf,df,akeyfield,keyindex,acancelupdate);
end;
}
function tmsebufdataset.refreshrecord(const sourcedatasets: array of tdataset;
              const akeyvalue: array of variant;
              const keyindex: integer = 0;
              const acancelupdate: boolean = true;
              const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty;
var
 int1,int2,int3: integer;
 field1,field2: tfield;
 sf,df: fieldarty;
begin
 int2:= 0;
 sf:= nil; //compilerwarning
 for int3:= 0 to high(sourcedatasets) do begin
  with sourcedatasets[int3] do begin
   setlength(sf,length(sf)+fields.count); //max
   setlength(df,length(sf)); //max
   for int1:= 0 to fields.count-1 do begin
    field1:= fields[int1];
    if field1.visible then begin
     field2:= self.findfield(field1.fieldname);
     if (field2 <> nil) and not field2.readonly then begin
      sf[int2]:= field1;
      df[int2]:= field2;
      inc(int2);
     end;
    end;
   end;
  end;
 end;
 setlength(sf,int2);
 setlength(df,int2);
 result:= refreshrecord(sf,df,akeyvalue,keyindex,acancelupdate,restorerecno,
                         noinsert);
end;

{$ifndef FPC}
function tmsebufdataset.refreshrecordvarar(const sourcedatasets: array of tdataset;
              const akeyvalue: array of variant;
              const keyindex: integer;
              const acancelupdate: boolean;
              const restorerecno: boolean;
              const noinsert: boolean): bookmarkdataty;
begin
 result:= refreshrecord(sourcedatasets,akeyvalue,keyindex,acancelupdate,
                          restorerecno,noinsert);
end;
{$endif}

function tmsebufdataset.refreshrecord(const akeyfield: array of tfield;
          const keyindex: integer = 0; const acancelupdate: boolean = true;
          const restorerecno: boolean = true;
              const noinsert: boolean = false): bookmarkdataty;
begin
{$ifdef fpc}
 result:= refreshrecord([akeyfield[0].dataset],fieldvariants(akeyfield),keyindex,
                        acancelupdate,restorerecno,noinsert);
{$else}
 result:= refreshrecordvarar([akeyfield[0].dataset],fieldvariants(akeyfield),keyindex,
                        acancelupdate,restorerecno,noinsert);
{$endif}
end;

function tmsebufdataset.getindex(const afield: tfield): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to findexlocal.count - 1 do begin
  with tlocalindex(findexlocal.fitems[int1]) do begin
   if (fields.count > 0) and (high(findexfieldinfos) >= 0) and
           (findexfieldinfos[0].fieldinstance = afield) then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

function tmsebufdataset.gettextindex(const afield: tfield;
               const acaseinsensitive: boolean): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to findexlocal.count - 1 do begin
  with tlocalindex(findexlocal.fitems[int1]) do begin
   if (fields.count > 0) and (high(findexfieldinfos) >= 0) and
           (findexfieldinfos[0].fieldinstance = afield) and
                     not (findexfieldinfos[0].caseinsensitive xor 
                                         acaseinsensitive) then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

function tmsebufdataset.updatesortfield(const afield: tfield;
               const adescend: boolean): boolean;
var
 int1: integer;
begin
 result:= false;
 if afield <> nil then begin
  for int1:= 0 to findexlocal.count - 1 do begin
   with tlocalindex(findexlocal.fitems[int1]) do begin
    if (fields.count > 0) and (high(findexfieldinfos) >= 0) and
            (findexfieldinfos[0].fieldinstance = afield) then begin
     result:= true;
     desc:= adescend;
     active:= true;
    end;
   end;
  end;
 end;
 if not result then begin
//  findexlocal.activeindex:= -1;
  findexlocal.activeindex:= findexlocal.defaultindex;
 end;
end;

procedure tmsebufdataset.setbookmarkdata1(const avalue: bookmarkdataty);
begin
 gotobookmark(@avalue);
end;

function tmsebufdataset.recapplying: boolean;
begin
 result:= bs_recapplying in fbstate;
end;

function tmsebufdataset.lookuptext(const indexnum: integer; const akey: integer;
          const aisnull: boolean; const valuefield: tmsestringfield): msestring;
var
 bm1: bookmarkdataty;
begin
 result:= '';
{$ifdef FPC}
 if indexlocal[indexnum].find([akey],[aisnull],bm1) then begin
{$else}
 if indexlocal[indexnum].findval([akey],[aisnull],bm1) then begin
{$endif}
  result:= currentbmasmsestring[valuefield,bm1];
 end;
end;

function tmsebufdataset.lookuptext(const indexnum: integer; const akey: int64;
          const aisnull: boolean; const valuefield: tmsestringfield): msestring;
var
 bm1: bookmarkdataty;
begin
 result:= '';
{$ifdef FPC}
 if indexlocal[indexnum].find([akey],[aisnull],bm1) then begin
{$else}
 if indexlocal[indexnum].findval([akey],[aisnull],bm1) then begin
{$endif}
  result:= currentbmasmsestring[valuefield,bm1];
 end;
end;

function tmsebufdataset.lookuptext(const indexnum: integer; const akey: msestring;
          const aisnull: boolean; const valuefield: tmsestringfield): msestring;
var
 bm1: bookmarkdataty;
begin
 result:= '';
{$ifdef FPC}
 if indexlocal[indexnum].find([akey],[aisnull],bm1) then begin
{$else}
 if indexlocal[indexnum].findval([akey],[aisnull],bm1) then begin
{$endif}
  result:= currentbmasmsestring[valuefield,bm1];
 end;
end;

function tmsebufdataset.findtext(const indexnum: integer; const searchtext: msestring;
                    out arecord: integer): boolean;
var
 bm1: bookmarkdataty;
begin
 arecord:= -1;
{$ifdef FPC}
 result:= indexlocal[indexnum].find([searchtext],[false],bm1,false,true);
{$else}
 result:= indexlocal[indexnum].findval([searchtext],[false],bm1,false,true);
{$endif}
 if result then begin
  arecord:= bm1.recno;
 end;
end;

function tmsebufdataset.getrowtext(const indexnum: integer;
                 const arecord: integer; const afield: tfield): msestring;
var
 bm1: bookmarkdataty;
begin
 if indexnum >= 0 then begin
  checkindex(true);
 end;
 bm1.recno:= arecord;
 bm1.recordpo:= findexes[indexnum+1].ind[arecord];
 if afield is tmsestringfield then begin
  result:= currentbmasmsestring[afield,bm1];
 end
 else begin
  case afield.datatype of
   ftboolean: begin
    result:= tmsebooleanfield1(afield).fdisplays[
                         false,currentbmasboolean[afield,bm1]];
   end;
   ftsmallint,ftword,ftinteger: begin
    result:= inttostrmse(currentbmasinteger[afield,bm1]);
   end;
   ftlargeint: begin
    result:= inttostrmse(currentbmasinteger[afield,bm1]);
   end;
   ftfloat: begin
    result:= formatfloatmse(currentbmasfloat[afield,bm1],'');
   end;
   fttime,ftdate,ftdatetime: begin
    result:= tmsedatetimefield1(afield).gettext1(
                                    currentbmasdatetime[afield,bm1],true);
   end;
   ftbcd: begin
    result:= currtostr(currentbmascurrency[afield,bm1]);
   end;
   else begin
    result:= '';
   end;
  end;  
 end;
end;

function tmsebufdataset.getrowinteger(const indexnum: integer;
                      const arecord: integer; const afield: tfield): integer;
var
 bm1: bookmarkdataty;
begin
 if indexnum >= 0 then begin
  checkindex(true);
 end;
 bm1.recno:= arecord;
 bm1.recordpo:= findexes[indexnum+1].ind[arecord];
 result:= currentbmasinteger[afield,bm1];
end;

function tmsebufdataset.getrowlargeint(const indexnum: integer;
                      const arecord: integer; const afield: tfield): int64;
var
 bm1: bookmarkdataty;
begin
 if indexnum >= 0 then begin
  checkindex(true);
 end;
 bm1.recno:= arecord;
 bm1.recordpo:= findexes[indexnum+1].ind[arecord];
 result:= currentbmaslargeint[afield,bm1];
end;

procedure CalcLookupValue(const afield: tfield);
begin
 with afield do begin
  if LookupCache then begin
    Value:= LookupList.ValueOfKey(DataSet.FieldValues[KeyFields])
  end
  else begin
   if Assigned(LookupDataSet) and DataSet.Active then begin
    Value:= LookupDataSet.Lookup(LookupKeyfields,
                 DataSet.FieldValues[KeyFields], LookupresultField);
   end;
  end;  
 end;
end;

procedure tmsebufdataset.CalculateFields(Buffer: PChar);
var
 i: Integer;
 field1: tfield;
 bm1: bookmarkdataty;
 state1: tdatasetstate;
begin
 FCalcBuffer1:= Buffer;  
 if not IsUniDirectional and (State <> dsInternalCalc) then begin
  state1:= settempstate(dscalcfields);
  try
   ClearCalcFields(FCalcBuffer1);
   for i := 0 to Fields.Count - 1 do begin
    field1:= fields[i];
    if (field1.FieldKind = fkLookup) and 
                      (field1.lookupdataset <> nil) then begin
     with flookupfieldinfos[-1-field1.fieldno] do begin
      if indexnum >= 0 then begin
       with tmsebufdataset(field1.lookupdataset) do begin
        if active and indexlocal[indexnum].find(keyfieldar,bm1) then begin
         currentbmassign(lookupvaluefield,field1,bm1); 
        end
        else begin
         field1.clear;
        end;
       end;
      end
      else begin
       CalcLookupValue(field1);
      end;
     end;
    end;
   end;
   DoOnCalcFields;
  finally
   restorestate(state1);
  end;
 end;
end;

procedure tmsebufdataset.begindisplaydata;
begin
 include(fbstate,bs_displaydata);
end;

procedure tmsebufdataset.enddisplaydata;
begin
 exclude(fbstate,bs_displaydata);
end;

function tmsebufdataset.getdata(const afields: array of tfield): variantararty;
var
 ar1: fieldarty;
 int1,int2: integer;
 po1: pvariantaty;
begin
 checkbrowsemode;
 ar1:= getdsfields(self,afields);
 try
  setlength(result,recordcount);
  for int1:= 0 to high(result) do begin
   setlength(result[int1],length(ar1));
   po1:= pointer(result[int1]);
   for int2:= 0 to high(ar1) do begin
    po1^[int2]:= currentasvariant[ar1[int2],int1];
   end;
  end;
 except
  result:= nil;
  raise;
 end;
end;

procedure tmsebufdataset.post;
begin
 if (bs1_posting in fbstate1) and (state in [dsedit,dsinsert]) then begin
  databaseerror('Recursive post.',self);
 end;
 include(fbstate1,bs1_posting);
 try
  inherited;
 finally
  exclude(fbstate1,bs1_posting);
 end;
end;

procedure tmsebufdataset.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 if dso_restoreupdateonsavepointrollback in aoptions then begin
  include(fbstate1,bs1_restoreupdate);
 end
 else begin
  if (bs1_restoreupdate in fbstate1) and active then begin
   postrecupdatebuffer;
  end;
  exclude(fbstate1,bs1_restoreupdate);
 end;
end;

procedure tmsebufdataset.savepointevent(const sender: tmdbtransaction;
               const akind: savepointeventkindty; const alevel: integer);
begin
 if (bs1_restoreupdate in fbstate1) and active and 
               ((sender = ftransactionwrite) or 
                  (ftransactionwrite = nil) and (sender = ftransaction)) then begin
  case akind of
   spek_begin: begin
    if fsavepointlevel < 0 then begin
     fsavepointlevel:= alevel;
     include(fbstate1,bs1_deferdeleterecupdatebuffer);
    end;
   end;
   else begin
    if alevel <= fsavepointlevel then begin
     fsavepointlevel:= -1;
     exclude(fbstate1,bs1_deferdeleterecupdatebuffer);
     if akind in [spek_release,spek_committrans] then begin
      postrecupdatebuffer;
     end
     else begin
      restorerecupdatebuffer;
     end;
    end;
   end;
  end;
 end;
end;

function tmsebufdataset.getchangerecords: recupdateinfoarty;
var
 int1,int2: integer;
begin
 setlength(result,length(fupdatebuffer));
 int2:= 0;
 for int1:= 0 to high(result) do begin
  with fupdatebuffer[int1] do begin
   if (info.bookmark.recordpo <> nil) and 
                     not (ruf_applied in info.flags) then begin
    result[int2]:= info;
    inc(int2);
   end;
  end;
 end;
 setlength(result,int2);
end;

function tmsebufdataset.getapplyerrorrecords: recupdateinfoarty;
var
 int1,int2: integer;
begin
 setlength(result,length(fupdatebuffer));
 int2:= 0;
 for int1:= 0 to high(result) do begin
  with fupdatebuffer[int1] do begin
   if (info.bookmark.recordpo <> nil) and 
              (info.flags*[ruf_applied,ruf_error] = [ruf_error]) then begin
    result[int2]:= info;
    inc(int2);
   end;
  end;
 end;
 setlength(result,int2);
end;

procedure tmsebufdataset.setcryptohandler(const avalue: tcustomcryptohandler);
begin
 getobjectlinker.setlinkedvar(iobjectlink(self),avalue,
                tmsecomponent(fcryptohandler));
end;

procedure tmsebufdataset.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 //dummy
end;

function tmsebufdataset.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(iobjectlink(self),{$ifdef FPC}@{$endif}objectevent,
                                                             fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tmsebufdataset.link(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tmsebufdataset.unlink(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tmsebufdataset.objevent(const sender: iobjectlink;
               const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tmsebufdataset.getinstance: tobject;
begin
 result:= self;
end;

function tmsebufdataset.getcomponent: tcomponent;
begin
 result:= self;
end;

{ tlocalindexes }

constructor tlocalindexes.create(const aowner: tmsebufdataset);
begin
 inherited create(aowner,tlocalindex);
end;

class function tlocalindexes.getitemclasstype: persistentclassty;
begin
 result:= tlocalindex;
end;

function tlocalindexes.getitems(const index: integer): tlocalindex;
begin
 result:= tlocalindex(inherited items[index]);
end;

procedure tlocalindexes.checkinactive;
begin
 if tmsebufdataset(fowner).active then begin
  databaseerror(SActiveDataset,tmsebufdataset(fowner));
 end;
end;

procedure tlocalindexes.setcount1(acount: integer; doinit: boolean);
begin
 checkinactive;
 inherited;
 if not (aps_destroying in fstate) then begin
  tmsebufdataset(fowner).updatestate;
 end;
end;

procedure tlocalindexes.bindfields;
var
 int1: integer;
begin
 for int1:= count - 1 downto 0 do begin
  items[int1].bindfields;
 end;
end;

procedure tlocalindexes.move(const curindex: integer; const newindex: integer);
begin
 checkinactive;
 inherited;
end;

function tlocalindexes.getactiveindex: integer;
begin
 result:= tmsebufdataset(fowner).actindex - 1;
end;

procedure tlocalindexes.setactiveindex(const avalue: integer);
begin
 if avalue < 0 then begin
  tmsebufdataset(fowner).actindex:= 0;
 end
 else begin
  items[avalue].active:= true;
 end;
end;

function tlocalindexes.fieldactive(const afield: tfield): boolean;
var
 int1: integer;
begin
 result:= tmsebufdataset(fowner).factindex > 0;
 if result and (afield <> nil) then begin
  result:= false;
  with items[tmsebufdataset(fowner).factindex-1] do begin
   for int1:= 0 to high(findexfieldinfos) do begin
    if findexfieldinfos[int1].fieldinstance = afield then begin
     result:= true;
     break;
    end;
   end;
  end;
 end;
end;

function tlocalindexes.hasfield(const afield: tfield): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 for int2:= 0 to high(fitems) do begin
  with items[int2] do begin
   for int1:= 0 to high(findexfieldinfos) do begin
    if findexfieldinfos[int1].fieldinstance = afield then begin
     result:= true;
     break;
    end;
   end;
  end;
  if result then begin
   break;
  end;
 end;
end;

function tlocalindexes.fieldmodified(const afield: tfield;
                                    const delayed: boolean): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 for int1:= 0 to count-1 do begin
  with tlocalindex(fitems[int1]) do begin
   for int2:= 0 to high(findexfieldinfos) do begin
    if (afield = nil) or 
           (findexfieldinfos[int2].fieldinstance = afield) then begin
     result:= true;
     if delayed then begin
      finvalid:= true;
     end
     else begin
      with tmsebufdataset(fowner) do begin
       findexes[int1+1].ind:= nil;
       exclude(tmsebufdataset(fowner).fbstate,bs_indexvalid);
      end;
     end;      
    end;
    break;
   end;
  end;
 end;
end;

procedure tlocalindexes.preparefixup;
var
 int1: integer;
begin
 for int1:= 0 to count-1 do begin
  with tlocalindex(fitems[int1]) do begin
   if finvalid then begin
    finvalid:= false;
    with tmsebufdataset(fowner) do begin
     findexes[int1+1].ind:= nil;
     exclude(fbstate,bs_indexvalid);
    end;
   end;
  end;
 end;
end;

procedure tlocalindexes.doindexchanged;
begin
 if checkcanevent(tmsebufdataset(fowner),
                 tmethod(fonindexchanged)) then begin
  fonindexchanged(tmsebufdataset(fowner));
 end;
end;

function tlocalindexes.getdefaultindex: integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= high(fitems) downto 0 do begin
  if lio_default in tlocalindex(fitems[int1]).foptions then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tlocalindexes.setdefaultindex(const avalue: integer);
var
 int1: integer;
begin
 if avalue < 0 then begin
  int1:= defaultindex;
  if int1 >= 0 then begin
   tlocalindex(fitems[int1]).default:= false;
  end
  else begin
   tlocalindex(fitems[avalue]).default:= true;
  end;
 end;
end;

function tlocalindexes.indexbyname(const aname: string): tlocalindex;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fitems) do begin
  if tlocalindex(fitems[int1]).name = aname then begin
   result:= tlocalindex(fitems[int1]);
  end;
 end;
end;

{ tlocalindex }

constructor tlocalindex.create(aowner: tobject);
begin
 ffields:= tindexfields.create(self);
 inherited;
end;

destructor tlocalindex.destroy;
begin
 ffields.free;
 inherited;
end;

procedure tlocalindex.setfields(const avalue: tindexfields);
begin
 ffields.assign(avalue);
end;

procedure tlocalindex.change;
var
 int1: integer;
begin
 with tmsebufdataset(fowner) do begin
  if fopen then begin
   self.bindfields;
   int1:= findexlocal.indexof(self) + 1;
   with findexes[int1] do begin
    if ind <> nil then begin
     if factindex = int1 then begin
      checkbrowsemode;
     end;
     ind:= nil;
     exclude(fbstate,bs_indexvalid);
     if factindex = int1 then begin
      internalsetrecno(findrecord(fcurrentbuf));
      resync([]);
      findexlocal.doindexchanged;
     end;
    end;
   end;
  end;
 end;
end;

procedure tlocalindex.setoptions(const avalue: localindexoptionsty);
var
 bo1: boolean;
 int1: integer;
begin
 if foptions <> avalue then begin
  bo1:= lio_default in foptions;
  foptions:= avalue;
  if not bo1 and (lio_default in foptions) then begin
   with tmsebufdataset(fowner).findexlocal do begin
    for int1:= 0 to high(fitems) do begin
     exclude(tlocalindex(fitems[int1]).foptions,lio_default);
    end;
   end;
   include(foptions,lio_default);
  end;
  change;
 end;
end;

procedure lookup1(const afield: tfield; const apo: pintrecordty;
                                          var adata: lookupdataty);
var
 bm1: bookmarkdataty;
 po1: pintrecordty;
begin
 adata.po:= nil;
 with tmsebufdataset(afield.dataset) do begin
  flookuppo:= apo;
  with flookupfieldinfos[-1-afield.fieldno] do begin
   with tmsebufdataset(afield.lookupdataset) do begin
    if active then begin
     if indexlocal[indexnum].find(keyfieldar,bm1) then begin
      if lookupvaluefield.fieldno > 0 then begin
       getvalue(lookupvaluefield,bm1,adata);
      end
      else begin
       if lookupvaluefield.lookupdataset is tmsebufdataset then begin
        with tmsebufdataset(lookupvaluefield.dataset) do begin
         if active then begin
          po1:= flookuppo;
          try
           lookup1(lookupvaluefield,bm1.recordpo,adata);
          finally
           flookuppo:= po1;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tlocalindex.dolookupcompare(const l,r: pintrecordty;
       const ainfo: indexfieldinfoty; const apartialstring: boolean): integer;

var
 ldata,rdata: lookupdataty;
  
begin
 result:= 0;
 with tmsebufdataset(ainfo.fieldinstance.lookupdataset) do begin
  if active then begin
   try
    lookup1(ainfo.fieldinstance,l,ldata);
    lookup1(ainfo.fieldinstance,r,rdata);
   finally
    tmsebufdataset(self.fowner).flookuppo:= nil;
   end;
   if ldata.po = nil then begin
    if rdata.po = nil then begin
     exit;
    end
    else begin
     dec(result);
    end;
   end
   else begin
    if rdata.po = nil then begin
     inc(result);
    end
    else begin
     result:= ainfo.comparefunc(ldata.po^,rdata.po^);
     if (result <> 0) and apartialstring then begin
      if ainfo.caseinsensitive then begin
       result:=  msepartialcomparetext(ldata.mstr,rdata.mstr);
      end
      else begin
       result:=  msepartialcomparestr(ldata.mstr,rdata.mstr);
      end;
     end;
    end;
   end;    
  end;
 end;
end;

function tlocalindex.compare1(l,r: pintrecordty; const alastindex: integer;
             const apartialstring: boolean): integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to alastindex do begin
  with findexfieldinfos[int1] do begin
   if islookup then begin
    result:= dolookupcompare(l,r,findexfieldinfos[int1],
              apartialstring and canpartialstring and (int1 = alastindex));
    if desc then begin
     result:= -result;
    end;
    if result <> 0 then begin
     break;
    end;
   end
   else begin
    if not getfieldflag(@l^.header.fielddata.nullmask,fieldindex) then begin
     if not getfieldflag(@r^.header.fielddata.nullmask,fieldindex) then begin
      continue;
     end
     else begin
      dec(result);
     end;
    end
    else begin
     if not getfieldflag(@r^.header.fielddata.nullmask,fieldindex) then begin
      inc(result);
     end
     else begin    
      result:= comparefunc((pchar(l)+recoffset)^,(pchar(r)+recoffset)^);
     end;
    end;
    if (result <> 0) then begin
     if apartialstring and canpartialstring and (int1 = alastindex) then begin
      if caseinsensitive then begin
       result:=  msepartialcomparetext(pmsestring(pointer(pchar(l)+recoffset))^,
                 pmsestring(pointer(pchar(r)+recoffset))^);
      end
      else begin
       result:=  msepartialcomparestr(pmsestring(pointer(pchar(l)+recoffset))^,
                 pmsestring(pointer(pchar(r)+recoffset))^);
      end;
     end;
     if desc then begin
      result:= -result;
     end;
     break;
    end;
   end;
  end;
 end;
 if lio_desc in foptions then begin
  result:= -result;
 end;
end;

function tlocalindex.compare2(l,r: pintrecordty): integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(findexfieldinfos) do begin
  with findexfieldinfos[int1] do begin
   if islookup then begin
    result:= dolookupcompare(l,r,findexfieldinfos[int1],false);    
    if desc then begin
     result:= -result;
    end;
    if result <> 0 then begin
     break;
    end;
   end
   else begin
    if not getfieldflag(@l^.header.fielddata.nullmask,fieldindex) then begin
     if not getfieldflag(@r^.header.fielddata.nullmask,fieldindex) then begin
      continue;
     end
     else begin
      dec(result);
     end;
    end
    else begin
     if not getfieldflag(@r^.header.fielddata.nullmask,fieldindex) then begin
      inc(result);
     end
     else begin
      result:= comparefunc((pchar(l)+recoffset)^,(pchar(r)+recoffset)^);
     end;
    end;
    if desc then begin
     result:= -result;
    end;
    if result <> 0 then begin
     break;
    end;
   end;
  end;
 end;
 if lio_desc in foptions then begin
  result:= -result;
 end;
end;

{$ifndef FPC}
function tlocalindex.compare3(l,r: pointer): integer;
begin
 result:= compare2(l,r);
end;
{$endif}

procedure tlocalindex.quicksort(l,r: integer);
var
  i,j: integer;
  p: integer;
//  int1: integer;
  po1: pintrecordty;
begin
 repeat
  i:= l;
  j:= r;
  p:= (l + r) shr 1;
  repeat
   while compare2(fsortarray^[i],fsortarray^[p]) < 0 do begin
    inc(i);
   end;
   while compare2(fsortarray^[j],fsortarray^[p]) > 0 do begin
    dec(j);
   end;
   if i <= j then begin
    po1:= fsortarray^[i];
    fsortarray^[i]:= fsortarray^[j];
    fsortarray^[j]:= po1;
    if p = i then begin
     p:= j
    end
    else begin
     if p = j then begin
      p:= i;
     end;
    end;
    inc(i);
    dec(j);
   end;
  until i > j;
  if l < j then begin
   quicksort(l,j);
  end;
  l:= i;
 until i >= r;
end;
{
procedure tlocalindex.mergesort(var adata: pointerarty);
        //todo: optimize
var
 ar1: pointerarty;
 step: integer;
 acount: integer;
 l,r,d: ppointer;
 stopl,stopr,stops: ppointer;
 source,dest: ppointer;
label
 endstep;
begin
 acount:= tmsebufdataset(fowner).fbrecordcount;
 allocuninitedarray(length(adata),sizeof(pointer),ar1);
 source:= pointer(adata);
 dest:= pointer(ar1);
 step:= 1;
 while step < acount do begin
  d:= dest;
  l:= source;
  r:= @ppointeraty(source)^[step];
  stopl:= r;
  stopr:= @ppointeraty(r)^[step];
  stops:= @ppointeraty(source)^[acount];
  if pchar(stopr) > pchar(stops) then begin
   stopr:= stops;
  end;
  while true do begin //runs
   while true do begin //steps
    while compare2(l^,r^) <= 0 do begin //merge from left
     d^:= l^;
     inc(l);
     inc(d);
     if l = stopl then begin
      while r <> stopr do begin
       d^:= r^;   //copy rest
       inc(d);
       inc(r);
      end;
      goto endstep;
     end;
    end;
    while compare2(l^,r^) > 0 do begin //merge from right;
     d^:= r^;
     inc(r);
     inc(d);
     if r = stopr then begin
      while l <> stopl do begin
       d^:= l^;   //copy rest
       inc(d);
       inc(l);
      end;
      goto endstep;
     end; 
    end;
   end;
endstep:
   if stopr = stops then begin
    break;  //run finished
   end;
   l:= stopr; //next step
   r:= @ppointerarty(l)^[step];
   if pchar(r) >= pchar(stops) then begin
    r:= pointer(pchar(stops)-sizeof(pointer));
   end;
   if r = l then begin
    d^:= l^;
    break;
   end;
   stopl:= r;
   stopr:= @ppointerarty(r)^[step];
   if pchar(stopr) > pchar(stops) then begin
    stopr:= stops;
   end;
  end;
  d:= source;     //swap buffer
  source:= dest;
  dest:= d;
  step:= step*2;
 end;

 if source <> pointer(adata) then begin
  adata:= ar1;
 end;
end;
}

procedure tlocalindex.sort(var adata: pointerarty);
{$ifdef mse_debugdataset}
var
 ts1: longword;
{$endif}
begin
 if adata <> nil then begin
{$ifdef mse_debugdataset}
  ts1:= timestamp;
{$endif}
  if lio_quicksort in foptions then begin
   fsortarray:= @adata[0];
   quicksort(0,tmsebufdataset(fowner).fbrecordcount - 1);
  end
  else begin
   msearrayutils.mergesort(adata,tmsebufdataset(fowner).fbrecordcount,
   {$ifdef FPC}
                 pointercomparemethodty(@compare2));
   {$else}
                 compare3);
   {$endif}
//   mergesort(adata);
  end;
 end;
{$ifdef mse_debugdataset}
  debugoutend(ts1,tmsebufdataset(fowner),'Sort index '+
                inttostr(tmsebufdataset(fowner).findexlocal.indexof(self)));
{$endif}
end;

function tlocalindex.findboundary(const arecord: pintrecordty;
                       const alastindex: integer; const abigger: boolean): integer;
                          //returns index of next bigger
var
 int1: integer;
 lo,up,pivot: integer;
begin
 result:= 0;
 with tmsebufdataset(fowner),findexes[findexlocal.indexof(self) + 1] do begin
  if fbrecordcount > 0 then begin
   int1:= 0;
   checkindex(true);
   lo:= 0;
   up:= fbrecordcount - 1;
   if abigger then begin
    while lo <= up do begin
     pivot:= (up + lo) div 2;
     int1:= compare1(arecord,ind[pivot],alastindex,false);
     if int1 >= 0 then begin //pivot <= rev
      lo:= pivot + 1;
     end
     else begin
      up:= pivot;
      if up = lo then begin
       break;
      end;
     end;
    end;
    result:= lo;
   end
   else begin
    while lo <= up do begin
     pivot:= (up + lo + 1) div 2;
     int1:= compare1(arecord,ind[pivot],alastindex,false);
     if int1 <= 0 then begin //pivot >= rev
      up:= pivot - 1;
     end
     else begin
      lo:= pivot;
      if up = lo then begin
       break;
      end;
     end;
    end;
    result:= up;
   end;
  end;
 end;
end;

function tlocalindex.findrecord(const arecord: pintrecordty): integer;
var
 int1: integer;
 po1: ppointeraty;
begin
 result:= -1;
 int1:= findboundary(arecord,high(findexfieldinfos),true) - 1;
 with tmsebufdataset(fowner) do begin
  po1:= pointer(findexes[findexlocal.indexof(self) + 1].ind);
 end;
 for int1:= int1 downto 0 do begin
  if po1^[int1] = arecord then begin 
   result:= int1;
   break;
  end;
 end;
end;

function tlocalindex.getactive: boolean;
begin
 with tmsebufdataset(fowner) do begin
  result:= actindex = findexlocal.indexof(self) + 1;
 end;
end;

procedure tlocalindex.setactive(const avalue: boolean);
var
 int1: integer;
begin
 with tmsebufdataset(fowner) do begin
  int1:= findexlocal.indexof(self) + 1;
  if avalue then begin
   if actindex <> int1 then begin
    actindex:= int1;
    tmsebufdataset(fowner).findexlocal.doindexchanged;
   end;
  end
  else begin
   if actindex = int1 then begin
    actindex:= 0;
    tmsebufdataset(fowner).findexlocal.doindexchanged;
   end;
  end;
 end;   
end;

procedure tlocalindex.bindfields;
var
 int1: integer;
 field1: tfield;
 kind1: fieldcomparekindty;
begin
 setlength(findexfieldinfos,ffields.count);
 fhaslookup:= false;
 with tmsebufdataset(fowner) do begin
  for int1:= 0 to high(findexfieldinfos) do begin
   with ffields.items[int1],findexfieldinfos[int1] do begin
    field1:= findfield(fieldname);
    if field1 = nil then begin
     databaseerror('Index field "'+fieldname+'" not found.',
                                                   tmsebufdataset(self.fowner));
    end;
    fieldinstance:= field1;
    with field1 do begin
     if not((fieldkind in [fkdata,fkinternalcalc]) or 
            (fieldkind = fklookup) and 
            (flookupfieldinfos[-1-fieldno].indexnum >= 0)) or 
                      not (datatype in indexfieldtypes) then begin
      databaseerror('Invalid index field "'+fieldname+'".',
                                                   tmsebufdataset(self.fowner));
     end;
     islookup:= fieldkind = fklookup;
     fhaslookup:= fhaslookup or islookup;
     for kind1:= low(fieldcomparekindty) to high(fieldcomparekindty) do begin
      with comparefuncs[kind1] do begin
       if datatype in datatypes then begin
        vtype:= cvtype;
        if ifo_caseinsensitive in options then begin
         comparefunc:= compfunci;
        end
        else begin
         comparefunc:= compfunc;
        end;
        break;
       end;
      end;
     end;
     fieldindex:= fieldno - 1;
     if fieldindex >= 0 then begin
      recoffset:= ffieldinfos[fieldindex].base.offset + intheadersize;
     end
     else begin
      recoffset:= offset; //calc field
      flookupfieldinfos[-2-fieldindex].hasindex:= true;
     end;
     desc:= ifo_desc in foptions;
     caseinsensitive:= ifo_caseinsensitive in foptions;
     canpartialstring:= vtype = {$ifdef mse_hasvtunicodestring}vtunicodestring
                  {$else}vtwidestring{$endif};
    end;
   end;
  end;
 end;
end;

procedure paramerror(const amessage: msestring = '');
var
 mstr1: msestring;
begin
 mstr1:= 'Invalid find parameters.';
 if amessage <> '' then begin
  mstr1:= mstr1 + lineend+amessage;
 end;
 databaseerror(mstr1);
end;

function tlocalindex.find(const avalues: array of const;
             const aisnull: array of boolean; out abookmark: bookmarkdataty;
             const abigger: boolean = false;
             const partialstring: boolean = false;
             const nocheckbrowsemode: boolean = false): boolean;
var
 int1: integer;
// v: tvarrec;
 po1: pintrecordty;
 po2: pointer;
 bo1: boolean;
 lastind: integer;
label
 endlab;
begin
 if not nocheckbrowsemode then begin
  tmsebufdataset(fowner).checkbrowsemode;
 end;
 lastind:= high(avalues);
 if lastind > high(findexfieldinfos) then begin
  paramerror;
 end;
 for int1:= lastind downto 0 do begin
  if (avalues[int1].vtype <> vtpointer) and 
              (avalues[int1].vtype <> findexfieldinfos[int1].vtype) then begin
   paramerror(tmsebufdataset(fowner).name+
    'field '+ findexfieldinfos[int1].fieldinstance.fieldname+
    ' wanted vtype: '+ inttostr(findexfieldinfos[int1].vtype)+
    ' actual vtype: '+ inttostr(avalues[int1].vtype));
  end;
 end;
 po1:= tmsebufdataset(fowner).intallocrecord;
 try
  for int1:= lastind downto 0 do begin
   with findexfieldinfos[int1],avalues[int1] do begin
    po2:= pchar(po1) + recoffset;
    bo1:= false;
    case vtype of
     vtinteger: begin
      pinteger(po2)^:= vinteger;
     end;
     {$ifdef mse_hasvtunicodestring}vtunicodestring
                  {$else}vtwidestring{$endif}: begin
      ppointer(po2)^:= {$ifdef mse_hasvtunicodestring}vunicodestring
                  {$else}vwidestring{$endif};
     end;
     vtextended: begin
      pdouble(po2)^:= vextended^;
      bo1:= pdouble(po2)^ = emptyreal;
     end;
     vtcurrency: begin
      pcurrency(po2)^:= vcurrency^;
     end;
     vtboolean: begin
      pwordbool(po2)^:= vboolean;
     end;
     vtint64: begin
      pint64(po2)^:= vint64^;
     end;
     vtpointer: begin
      bo1:= true;
     end;
     mse_vtguid: begin
      pguid(po2)^:= pguid(vpointer)^;
     end;
     else begin
      paramerror;
     end;
    end;
    if int1 <= high(aisnull) then begin
     bo1:= bo1 or aisnull[int1];
    end;
    if not bo1 then begin
     setfieldflag(@po1^.header.fielddata.nullmask,fieldindex);
    end; 
   end;
  end;
  int1:= findboundary(po1,lastind,abigger);
  result:= false;
  abookmark.recordpo:= nil;
  abookmark.recno:= -1;
  with tmsebufdataset(fowner) do begin
   with findexes[findexlocal.indexof(self) + 1] do begin
    if abigger then begin
     if int1 < 0 then begin
      goto endlab;
     end;
     if (int1 > 0) and (compare1(po1,ind[int1-1],lastind,false) = 0) then begin
      result:= true;
      dec(int1);
     end;
    end
    else begin
     if int1 >= fbrecordcount - 1 then begin
      if partialstring and (int1 > 0) and (int1 = fbrecordcount - 1) then begin
       result:= compare1(po1,ind[int1],lastind,true) = 0;
      end;
      if not result then begin
       goto endlab;
      end;
     end;     
     if not result then begin
      if compare1(po1,ind[int1+1],lastind,false) = 0 then begin
       result:= true;
       inc(int1);
      end;
     end;
    end;
    if (int1 >= -1) and (int1 < fbrecordcount) then begin
     if not result then begin
      if partialstring then begin
       if int1 >= 0 then begin
        result:= compare1(po1,ind[int1],lastind,true) = 0;
       end;
       if not result then begin
        inc(int1);
        if (int1 >= fbrecordcount) or 
                       (compare1(po1,ind[int1],lastind,true) <> 0) then begin
         dec(int1,2);         //for reversed order
         if (int1 < 0) or 
                       (compare1(po1,ind[int1],lastind,true) <> 0) then begin
          dec(int1);
          if (int1 < 0) or 
                       (compare1(po1,ind[int1],lastind,true) <> 0) then begin
           inc(int1,2);
          end
          else begin
           result:= true;
          end;
         end
         else begin
          result:= true;
         end;
        end
        else begin
         result:= true;
        end;
       end;         
      end
      else begin
       if int1 < 0 then begin
        goto endlab;
       end;
      end;
     end;
     abookmark.recno:= int1;
     abookmark.recordpo:= ind[int1];
    end;
   end;
  end;
endlab:
 finally
  freemem(po1);
 end;
end;

{$ifndef FPC}
function tlocalindex.findval(const avalues: array of const;
             const aisnull: array of boolean; out abookmark: bookmarkdataty;
             const abigger: boolean = false;
             const partialstring: boolean = false;
             const nocheckbrowsemode: boolean = false): boolean;
begin
 result:= find(avalues,aisnull,abookmark,abigger,partialstring,nocheckbrowsemode);
end;
{$endif}

function tlocalindex.find(const avalues: array of const; const aisnull: array of boolean;
                 //itemcount of avalues can be smaller than fields count in index
               out abookmark: string;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
                //string values must be msestring
var
 bm1: bookmarkdataty;
begin
 result:= find(avalues,aisnull,bm1,abigger,partialstring,nocheckbrowsemode);
 abookmark:=  tmsebufdataset(fowner).bookmarkdatatobookmark(bm1);
end;

function tlocalindex.find(const avalues: array of const;
    const aisnull: array of boolean;
    const alast: boolean = false; const partialstring: boolean = false;
    const nocheckbrowsemode: boolean = false;
    const exact: boolean = true): boolean;
                //sets dataset cursor if found
var
 str1: string;
begin
 result:= find(avalues,aisnull,str1,alast,partialstring,nocheckbrowsemode);
 if result or not exact then begin
  tmsebufdataset(fowner).bookmark:= str1;
 end;
end;

function tlocalindex.find(const avalues: array of tfield;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false;
               const exact: boolean = true): boolean;
                //sets dataset cursor if found
var
 str1: string;
begin
 result:= find(avalues,str1,abigger,partialstring,nocheckbrowsemode);
 if result or not exact then begin
  tmsebufdataset(fowner).bookmark:= str1;
 end;
end;

function tlocalindex.findvariant(const avalue: array of variant;
                 //nil -> NULL field
                 //itemcount of avalues
                 //can be smaller than fields count in index
                 //itemcount of aisnull can be smaller than itemcount of avalues
               out abookmark: string;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
                //string values must be msestring
var
 int1: integer;
 vt1: tvartype;
 ar1: array of tvarrec;
 ar2: msestringarty;
 ar3: array of extended;
begin
 setlength(ar1,length(avalue));
 setlength(ar2,length(avalue));
 setlength(ar3,length(avalue));
 for int1:= 0 to high(avalue) do begin
  with ar1[int1] do begin
   if varisnull(avalue[int1]) then begin
    vtype:= vtpointer;
 //   result:= find([nil],[],abigger,partialstring,nocheckbrowsemode);
   end
   else begin
    vt1:= vartype(avalue[int1]);
    if vt1 in ordinalvartypes then begin
     if vt1 = varint64 then begin
      vtype:= vtint64;
      vint64:= @tvardata(avalue[int1]).vint64;
     end
     else begin
      if vt1 = varboolean then begin
       vtype:= vtboolean;
       vboolean:= avalue[int1];
      end
      else begin
       vtype:= vtinteger;
       vinteger:= avalue[int1];
      end;
     end;
    end
    else begin
     case vt1 of
      varcurrency: begin
       vtype:= vtcurrency;
       vcurrency:= @tvardata(avalue[int1]).vcurrency;
      end;
      varsingle,vardouble,vardate: begin
       vtype:= vtextended;
       ar3[int1]:= avalue[int1];
       vextended:= @ar3[int1];
      end;
      varstring,varolestr: begin
       vtype:= {$ifdef mse_hasvtunicodestring}vtunicodestring
                  {$else}vtwidestring{$endif};
       ar2[int1]:= avalue[int1];
       {$ifdef mse_hasvtunicodestring}vunicodestring
                  {$else}vwidestring{$endif}:= pointer(ar2[int1]);
      end
      else begin
       paramerror;
      end;
     end;
    end;
   end;
  end;
 end;
 result:= find(ar1,[],abigger,partialstring,nocheckbrowsemode);
end;

function tlocalindex.findvariant(const avalue: array of variant;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false;
               const exact: boolean = true): boolean;
                //sets dataset cursor if found
var
 str1: string;
begin
 result:= findvariant(avalue,str1,abigger,partialstring,nocheckbrowsemode);
 if result or not exact then begin
  tmsebufdataset(fowner).bookmark:= str1;
 end;
end;

function tlocalindex.find(const avalues: array of tfield;
               out abookmark: bookmarkdataty;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
var
 mstr1: msestring; 
 str1: string;
 consts1: array of tvarrec;
 isnull1: array of boolean;
 field1: tfield;
 int1: integer;
 rea1: extended;
 cur1: currency;
 lint1: int64;
 id1: tguid;
  
begin
 setlength(consts1,length(avalues));
 setlength(isnull1,length(avalues));
 for int1:= 0 to high(avalues) do begin
  field1:= avalues[int1];
  with field1,consts1[int1] do begin
   if isnull then begin
    isnull1[int1]:= true;
   end;
   if field1 is tmsestringfield then begin
    mstr1:= tmsestringfield(field1).asmsestring;
    vtype:= {$ifdef mse_hasvtunicodestring}vtunicodestring
                  {$else}vtwidestring{$endif};
    {$ifdef mse_hasvtunicodestring}vunicodestring
                  {$else}vwidestring{$endif}:= pointer(mstr1);
   end
   else begin
    case datatype of
     ftString,ftFixedChar,ftmemo,ftblob: begin
      str1:= asstring;
      vtype:= vtansistring;
      vansistring:= pointer(str1);
     end;
     ftSmallint,ftInteger,ftWord: begin
      vtype:= vinteger;
      vinteger:= asinteger;
     end;
     ftBoolean: begin
      vboolean:= asboolean;
      vtype:= vtboolean
     end; 
     ftFloat,ftcurrency,ftDate,ftTime,ftDateTime,ftTimeStamp,ftFMTBcd: begin
      rea1:= asfloat;
      vtype:= vtextended;
      vextended:= @rea1;
     end;
     ftBCD: begin
      cur1:= ascurrency;
      vtype:= vtcurrency;
      vcurrency:= @cur1;
     end;
     ftguid: begin
      id1:= asguid;
      vtype:= mse_vtguid;
      vpointer:= @id1;
     end;
     ftWideString: begin
      mstr1:= aswidestring;
      vtype:= {$ifdef mse_hasvtunicodestring}vtunicodestring
                  {$else}vtwidestring{$endif};
      {$ifdef mse_hasvtunicodestring}vunicodestring
                  {$else}vwidestring{$endif}:= pointer(mstr1);
     end;
     ftLargeint: begin
      lint1:= aslargeint;
      vtype:= vtint64;
      vint64:= @lint1;
     end;
    end;
   end;
  end;
 end; 
 result:= find(consts1,isnull1,abookmark,abigger,
                              partialstring,nocheckbrowsemode);
end;

function tlocalindex.find(const avalues: array of tfield;
               out abookmark: string;
               const abigger: boolean = false;
               const partialstring: boolean = false;
               const nocheckbrowsemode: boolean = false): boolean;
                //true if found else nearest lower or bigger,
                //abookmark = '' if no lower or bigger found
var
 bm: bookmarkdataty;
begin
 result:= find(avalues,bm,abigger,partialstring,nocheckbrowsemode);
 abookmark:= tmsebufdataset(fowner).bookmarkdatatobookmark(bm);
end;

function tlocalindex.unique(const avalues: array of const): boolean;
var
 bm1: bookmarkdataty;
begin
 result:= not find(avalues,[],bm1,false,false,true) or 
      (bm1.recordpo = tmsebufdataset(fowner).bookmarkdata.recordpo);
end;

function tlocalindex.getbookmark(const arecno: integer): bookmarkty;
var
 bm1: bookmarkdataty;
begin
 with tmsebufdataset(fowner) do begin
  checkrecno(arecno);
  checkindex(true);
  bm1.recno:= arecno - 1;
  bm1.recordpo:= findexes[findexlocal.indexof(self) + 1].ind[arecno-1];
  result:= bookmarkdatatobookmark(bm1);
 end;
end;

function tlocalindex.getdesc: boolean;
begin
 result:= lio_desc in foptions;
end;

procedure tlocalindex.setdesc(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [lio_desc];
 end
 else begin
  options:= options - [lio_desc];
 end;
end;

function tlocalindex.getdefault: boolean;
begin
 result:= lio_default in foptions;
end;

procedure tlocalindex.setdefault(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [lio_default];
 end
 else begin
  options:= options - [lio_default];
 end;
end;

{ tindexfields }

constructor tindexfields.create(const aowner: tlocalindex);
begin
 inherited create(aowner,tindexfield);
 count:= 1;
end;

class function tindexfields.getitemclasstype: persistentclassty;
begin
 result:= tindexfield;
end;

function tindexfields.getitems(const index: integer): tindexfield;
begin
 result:= tindexfield(inherited items[index]);
end;

{ tindexfield }

procedure tindexfield.change;
begin
 tlocalindex(fowner).change;
end;

procedure tindexfield.setfieldname(const avalue: string);
begin
 ffieldname:= avalue;
 change;
end;

procedure tindexfield.setoptions(const avalue: indexfieldoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  change;
 end;
end;

{ ecurrentvalueaccess }

constructor ecurrentvalueaccess.create(const adataset: tdataset;
                                    const afield: tfield; const msg: string);
begin
 inherited create('Current value access: '+msg+lineend+
                     'Dataset: '+adataset.name+' Field: '+ afield.fieldname);
end;

end.
