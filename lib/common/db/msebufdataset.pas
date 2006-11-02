{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team

    BufDataset implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
 
unit msebufdataset;
 
interface 

uses
 db,classes,variants,msetypes,msearrayprops,mseclasses,mselist;
  
const
 defaultpacketrecords = 10;
 integerindexfields = [ftsmallint,ftinteger,ftword,ftlargeint,ftboolean];
 floatindexfields = [ftfloat];
 currencyindexfields = [ftcurrency,ftbcd];
 stringindexfields = [ftstring,ftfixedchar,ftwidestring,ftmemo];
 indexfieldtypes =  integerindexfields+floatindexfields+currencyindexfields+
                   stringindexfields;
 
type  
 fielddataty = record
  nullmask: array[0..0] of byte; //variable length
                                 //fielddata following
 end;
  
 blobinfoty = record
  field: tfield;
  data: pointer;
  datalength: integer;
  new: boolean;
 end;
 
 pblobinfoty = ^blobinfoty;
 blobinfoarty = array of blobinfoty;
 pblobinfoarty = ^blobinfoarty;

 recheaderty = record
  blobinfo: blobinfoarty;
  fielddata: fielddataty;   
 end;
 precheaderty = ^recheaderty;
   
 intheaderty = record
 end;

 intrecordty = record              
  intheader: intheaderty;
  header: recheaderty;      
 end;
 pintrecordty = ^intrecordty;

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
 intheadersize = sizeof(intrecordty.intheader);
 dsheadersize = sizeof(dsrecordty.dsheader);
     
// structure of internal recordbuffer:
//                 +---------<frecordsize>---------+
// intrecheaderty, |recheaderty,fielddata          |
//                 |moved to tdataset buffer header|
//                 |fieldoffsets are in ffieldbufpositions
//
// structure of dataset recordbuffer:
//                 +---------<frecordsize>---------+
// dsrecheaderty,  |recheaderty,fielddata          |, calcfields
//                 |moved to internal buffer header|
//                 |fieldoffsets are in ffieldbufpositions
//

type
 indexty = record
  ind: pointerarty;
 end;
 pindexty = ^indexty;

 tmsebufdataset = class;
 
  TResolverErrorEvent = procedure(Sender: TObject; DataSet: tmsebufdataset; E: EUpdateError;
    UpdateKind: TUpdateKind; var Response: TResolverResponse) of object;
  
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
   property options: indexfieldoptionsty read foptions write setoptions;
 end;

 localindexoptionty = (lio_desc);
 localindexoptionsty = set of localindexoptionty;

 tlocalindex = class;  
 
 tindexfields = class(townedpersistentarrayprop)
  private
   function getitems(const index: integer): tindexfield;
  public
   constructor create(const aowner: tlocalindex); reintroduce;
   property items[const index: integer]: tindexfield read getitems;
 end;

 intrecordpoaty = array[0..0] of pintrecordty;
 pintrecordpoaty = ^intrecordpoaty;
 indexfieldinfoty = record
  comparefunc: arraysortcomparety;
  recoffset: integer;
  fieldindex: integer;
  desc: boolean;
 end;
 indexfieldinfoarty = array of indexfieldinfoty;
  
 tlocalindex = class(townedpersistent)
  private
   ffields: tindexfields;
   foptions: localindexoptionsty;
   fsortarray: pintrecordpoaty;
   findexfieldinfos: indexfieldinfoarty;
   procedure change;
   procedure setoptions(const avalue: localindexoptionsty);
   procedure setfields(const avalue: tindexfields);
   function compare(l,r: pintrecordty): integer;
   procedure quicksort(l,r: integer);
   procedure sort(var adata: pointerarty);
   function getactive: boolean;
   procedure setactive(const avalue: boolean);
   procedure bindfields;
   function findboundary(const arecord: pintrecordty): integer;
                          //returns index of next bigger
   function findrec(const arecord: pintrecordty): integer;
                         //returns index, -1 if not found
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
  published
   property fields: tindexfields read ffields write setfields;
   property options: localindexoptionsty read foptions write setoptions;
   property active: boolean read getactive write setactive;
 end;
 
 tlocalindexes = class(townedpersistentarrayprop)
  private
   function getitems(const index: integer): tlocalindex;
   procedure bindfields;
  protected
   procedure checkinactive;
   procedure setcount1(acount: integer; doinit: boolean); override;
 public
   constructor create(const aowner: tmsebufdataset); reintroduce;
   procedure move(const curindex,newindex: integer); override;
   property items[const index: integer]: tlocalindex read getitems; default;
 end;
  
type
 
 recupdatebufferty = record
  updatekind: tupdatekind;
  bookmark: bookmarkdataty;
  oldvalues: pintrecordty;
 end;
 precupdatebufferty = ^recupdatebufferty;

 recupdatebufferarty = array of recupdatebufferty;
 
 bufdatasetstatety = (bs_applying,bs_hasindex,bs_fetchall,bs_indexvalid);
 bufdatasetstatesty = set of bufdatasetstatety;
   
 tmsebufdataset = class(TDBDataSet)
  private
   FBRecordCount   : integer;

   FPacketRecords  : integer;
   FRecordSize     : Integer;
   FNullmaskSize   : byte;
   FOpen           : Boolean;
   FUpdateBuffer   : RecUpdateBufferarty;
   FCurrentUpdateBuffer : integer;

   FFieldBufPositions: integerarty;
   ffieldsizes: integerarty;
   
   FAllPacketsFetched : boolean;
   FOnUpdateError  : TResolverErrorEvent;

   femptybuffer: pintrecordty;
   ffilterbuffer: pintrecordty;
   fcurrentrecord: pintrecordty;
   fnewvaluebuffer: pdsrecordty; //buffer for applyupdates
   fbstate: bufdatasetstatesty;
   
   factindexpo: pindexty;    
   findexes: array of indexty;
   findexlocal: tlocalindexes;
   factindex: integer;
   procedure CalcRecordSize;
   function loadbuffer(var buffer: recheaderty): tgetresult;
   function GetFieldSize(FieldDef : TFieldDef) : longint;
   function GetRecordUpdateBuffer : boolean;
   procedure SetPacketRecords(aValue : integer);
   function  intallocrecord: pintrecordty;    
   procedure intfreerecord(var buffer: pintrecordty);

   procedure clearindex;
   procedure checkindexsize;    
   function appendrecord(const arecord: pintrecordty): integer;
             //returns new recno
   function insertrecord(arecno: integer; const arecord: pintrecordty): integer;
             //returns new recno
   procedure deleterecord(const arecno: integer);    
   procedure getnewupdatebuffer;
   procedure setindexlocal(const avalue: tlocalindexes);
   function insertindexrefs(const arecord: pintrecordty): integer;
              //returns new recno of active index
   procedure removeindexrefs(const arecord: pintrecordty);
   procedure internalsetrecno(const avalue: integer);
   procedure setactindex(const avalue: integer);
   procedure checkindex;
  protected
   fapplyindex: integer; //take care about canceled updates while applying
   ffailedcount: integer;
   frecno: integer; //null based
   
   procedure updatestate;
   function getintblobpo: pblobinfoarty; //in currentrecbuf
   procedure internalcancel; override;
   procedure cancelrecupdate(var arec: recupdatebufferty);
   procedure setdatastringvalue(const afield: tfield; const avalue: string);
   
   function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
   procedure internalapplyupdate(const maxerrors: integer;
                const cancelonerror: boolean; var response: tresolverresponse);
   procedure afterapply; virtual;
    procedure freeblob(const ablob: blobinfoty);
    procedure freeblobs(var ablobs: blobinfoarty);
    procedure deleteblob(var ablobs: blobinfoarty; const aindex: integer); overload;
    procedure deleteblob(var ablobs: blobinfoarty; const afield: tfield); overload;
    procedure addblob(const ablob: tblobbuffer);
    
    procedure SetRecNo(Value: Longint); override;
    function  GetRecNo: Longint; override;
    function GetChangeCount: integer; virtual;
    function  AllocRecordBuffer: PChar; override;
    procedure ClearCalcFields(Buffer: PChar); override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure InternalInitRecord(Buffer: PChar); override;
    function  GetCanModify: Boolean; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode;
                                    DoCheck: Boolean): TGetResult; override;
    procedure InternalOpen; override;
    procedure InternalClose; override;
    function getnextpacket : integer;
    function GetRecordSize: Word; override;
    procedure InternalPost; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function GetFieldData(Field: TField; Buffer: Pointer;
                        NativeFormat: Boolean): Boolean; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer;
      NativeFormat: Boolean); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    function IsCursorOpen: Boolean; override;
    function  GetRecordCount: Longint; override;
    procedure ApplyRecUpdate(UpdateKind : TUpdateKind); virtual;
    procedure SetOnUpdateError(const aValue: TResolverErrorEvent);
  {abstracts, must be overidden by descendents}
    function Fetch : boolean; virtual; abstract;
    function LoadField(FieldDef : TFieldDef;buffer : pointer) : boolean; virtual; abstract;
   property actindex: integer read factindex write setactindex;
   function findrec(const arecord: pintrecordty): integer;
                         //returns index, -1 if not found
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure resetindex; //deactivates all indexes
    function createblobbuffer(const afield: tfield): tblobbuffer;
    procedure ApplyUpdates(const maxerrors: integer = 0); virtual; overload;
    procedure ApplyUpdates(const MaxErrors: Integer;
                    const cancelonerror: boolean); virtual; overload;
    procedure applyupdate(const cancelonerror: boolean); virtual; overload;
    procedure applyupdate; virtual; overload;
                    //applies current record
    procedure CancelUpdates; virtual;
    procedure cancelupdate; virtual; //cancels current record
//    function Locate(const keyfields: string; const keyvalues: Variant; options: TLocateOptions) : boolean; override;
    function UpdateStatus: TUpdateStatus; override;
    property ChangeCount : Integer read GetChangeCount;
  published
    property PacketRecords : Integer read FPacketRecords write setPacketRecords 
                                  default defaultpacketrecords;
    property OnUpdateError: TResolverErrorEvent read FOnUpdateError 
                                  write SetOnUpdateError;
    property indexlocal: tlocalindexes read findexlocal write setindexlocal;
  end;
   
implementation
uses
 dbconst,msedatalist,sysutils;
 
function compinteger(const l,r): integer;
begin
 result:= integer(l) - integer(r);
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
 result:= ansistrcomp(pchar(@l),pchar(@r));
end;

function compstringi(const l,r): integer;
begin
 result:= ansistricomp(pchar(@l),pchar(@r));
end;

type
 fieldcomparekindty = (fct_integer,fct_float,fct_currency,fct_text);
 fieldcompareinfoty = record
  datatypes: set of tfieldtype;
  compfunc: arraysortcomparety;
  compfunci: arraysortcomparety;
 end;
const
 comparefuncs: array[fieldcomparekindty] of fieldcompareinfoty = 
  ((datatypes: integerindexfields; compfunc: @compinteger;
                                   compfunci: @compinteger),
   (datatypes: floatindexfields; compfunc: @compfloat;
                                 compfunci: @compfloat),
   (datatypes: currencyindexfields; compfunc: @compcurrency;
                                    compfunci: @compcurrency),
   (datatypes: stringindexfields; compfunc: @compstring;
                                  compfunci: @compstringi));
    
procedure unSetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) and not (1 shl (x mod 8));
end;

procedure SetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
end;

function GetFieldIsNull(NullMask : pbyte;x : longint) : boolean; //inline;
begin
  result := ord(NullMask[x div 8]) and (1 shl (x mod 8)) > 0
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
begin
 inherited destroy;
 findexlocal.free;
end;

procedure tmsebufdataset.setpacketrecords(avalue : integer);
begin
 if (avalue = 0) then begin
  databaseerror(sinvpacketrecordsvalue);
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
 result := allocmem(frecordsize+intheadersize);
 fillchar(result^,sizeof(intrecordty),0);
end;

procedure tmsebufdataset.intfreerecord(var buffer: pintrecordty);
begin
 if buffer <> nil then begin
  freeblobs(buffer^.header.blobinfo);
  freemem(buffer);
  buffer:= nil;
 end;
end;

function tmsebufdataset.allocrecordbuffer: pchar;
begin
 result := allocmem(frecordsize + dsheadersize + calcfieldssize);
 initrecord(result);
end;

procedure tmsebufdataset.clearcalcfields(buffer: pchar);
begin
 with pdsrecordty(buffer)^ do begin
//  fillchar((pointer(@header)+frecordsize)^,calcfieldssize,0);
 end;
end;

procedure tmsebufdataset.freerecordbuffer(var buffer: pchar);
var
 int1: integer;
 bo1: boolean;
begin
 if buffer <> nil then begin
  bo1:= false;
  with pdsrecordty(buffer)^.header do begin
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].new then begin
     freeblob(blobinfo[int1]);
     bo1:= true;
    end;
   end;
   if bo1 then begin
    blobinfo:= nil;
   end;
  end;
  reallocmem(buffer,0);
 end;
end;
{
function tmsebufdataset.getblobpo: pblobinfoarty;
begin
 result:= pointer(activebuffer);
end;
}

function tmsebufdataset.getintblobpo: pblobinfoarty;
begin
 if bs_applying in fbstate then begin
  result:= @fnewvaluebuffer^.header.blobinfo;
 end
 else begin
  result:= @fcurrentrecord^.header.blobinfo;
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

procedure tmsebufdataset.addblob(const ablob: tblobbuffer);
var
 int1,int2: integer;
 bo1: boolean;
 po2: pointer;
begin
 bo1:= false;
 int2:= -1;
 with pdsrecordty(activebuffer)^.header do begin
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
  if not bo1 then begin //copy needed
   po2:= pointer(blobinfo);
   pointer(blobinfo):= nil;
   blobinfo:= copy(blobinfoarty(po2));
  end;
  if int2 >= 0 then begin
   deleteblob(blobinfo,int2);
  end;
  setlength(blobinfo,high(blobinfo)+2);
  with blobinfo[high(blobinfo)],ablob do begin
   data:= memory;
   reallocmem(data,size);
   datalength:= size;
   field:= ffield;
   new:= true;
   if size = 0 then begin
    setfieldisnull(fielddata.nullmask,field.fieldno-1);
   end
   else begin
    unsetfieldisnull(fielddata.nullmask,field.fieldno-1);
   end;
   if not (State in [dsCalcFields, dsFilter, dsNewValue]) then begin
    DataEvent(deFieldChange, Ptrint(Field));
   end;
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

procedure tmsebufdataset.deleteblob(var ablobs: blobinfoarty; const aindex: integer);
begin
 freeblob(ablobs[aindex]);
 deleteitem(ablobs,typeinfo(blobinfoarty),aindex); 
end;

procedure tmsebufdataset.deleteblob(var ablobs: blobinfoarty; const afield: tfield);
var
 int1: integer;
begin
 for int1:= high(ablobs) downto 0 do begin
  if ablobs[int1].field = afield then begin
   freeblob(ablobs[int1]);
   deleteitem(ablobs,typeinfo(blobinfoarty),int1); 
   break;
  end;
 end;
end;

procedure tmsebufdataset.internalopen;

begin
 bindfields(true); //calculate calc fields size
 setlength(findexes,1+findexlocal.count);
 factindexpo:= @findexes[factindex];
 calcrecordsize;
 findexlocal.bindfields;
 femptybuffer:= intallocrecord;
 ffilterbuffer:= intallocrecord;
 fnewvaluebuffer:= pdsrecordty(allocrecordbuffer);
 fallpacketsfetched := false;
 fopen:= true;
end;

procedure tmsebufdataset.internalclose;
var 
 int1: integer;
begin
 fopen:= false;
 frecno:= -1;
 with findexes[0] do begin
  for int1:= 0 to fbrecordcount - 1 do begin
   intfreerecord(ind[int1]);
  end;
 end;
 intfreerecord(femptybuffer);
 intfreerecord(ffilterbuffer);
 pointer(fnewvaluebuffer^.header.blobinfo):= nil;
 freerecordbuffer(pchar(fnewvaluebuffer));
 for int1:= 0 to high(fupdatebuffer) do begin
  with fupdatebuffer[int1] do begin
   if bookmark.recordpo <> nil then begin
    intfreerecord(oldvalues);
   end;
  end;
 end;
 fupdatebuffer:= nil;
 clearindex;
 fbrecordcount:= 0;
 ffieldbufpositions:= nil;
 ffieldsizes:= nil;
 bindfields(false);
end;

procedure tmsebufdataset.internalfirst;
begin
 internalsetrecno(-1);
end;

procedure tmsebufdataset.internallast;
begin
 repeat
 until (getnextpacket < fpacketrecords) or (bs_fetchall in fbstate);
 internalsetrecno(fbrecordcount)
end;

function tmsebufdataset.getrecord(buffer: pchar; getmode: tgetmode;
                                            docheck: boolean): tgetresult;
begin
 result:= grok;
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
   if (frecno < 0) or (frecno >= fbrecordcount) then begin
    result := grerror;
   end;
  end;
  gmnext: begin
   if frecno >= fbrecordcount - 1 then begin
    if getnextpacket = 0 then begin
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
    data.recordpo:= fcurrentrecord;
    flag:= bfcurrent;
   end;
   move(fcurrentrecord^.header,header,frecordsize);
   getcalcfields(buffer);
  end;
 end
 else begin
  if (result = grerror) and docheck then begin
   databaseerror('No record');
  end;
 end;
end;

function tmsebufdataset.getrecordupdatebuffer : boolean;
var 
 int1: integer;
begin
 if bs_applying in fbstate then begin
  result:= true; //fcurrentupdatebuffer is valid
 end
 else begin
  with pdsrecordty(activebuffer)^.dsheader.bookmark.data do begin
   if (fcurrentupdatebuffer >= length(fupdatebuffer)) or 
        (fupdatebuffer[fcurrentupdatebuffer].bookmark.recordpo <> 
                                                         recordpo) then begin
    for int1:= 0 to high(fupdatebuffer) do begin
     if fupdatebuffer[int1].bookmark.recordpo = recordpo then begin
      fcurrentupdatebuffer:= int1;
      break;
     end;
    end;
   end;
   result:= (fcurrentupdatebuffer <= high(fupdatebuffer))  and 
          (fupdatebuffer[fcurrentupdatebuffer].bookmark.recordpo = recordpo);
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

function tmsebufdataset.getbookmarkflag(buffer: pchar): tbookmarkflag;
begin
 result:= pdsrecordty(buffer)^.dsheader.bookmark.flag;
end;

procedure tmsebufdataset.internalgotobookmark(abookmark: pointer);
begin
 with pbufbookmarkty(abookmark)^.data do begin
  if (recno >= fbrecordcount) or (recno < 0) then begin
   databaseerror('Invalid bookmark: '+inttostr(recno)+'+');
  end;
  internalsetrecno(recno);
 end;
end;

function tmsebufdataset.getnextpacket : integer;
begin
 result:= 0;
 if fallpacketsfetched then  begin
  exit;
 end;
 while ((result < fpacketrecords) or (bs_fetchall in fbstate)) and 
                             (loadbuffer(femptybuffer^.header) = grok) do begin
  appendrecord(femptybuffer);
  femptybuffer:= intallocrecord;
  inc(result);
 end;
end;

function tmsebufdataset.getfieldsize(fielddef: tfielddef): longint;
begin
 case fielddef.datatype of
  ftstring,ftfixedchar: result:= fielddef.size + 1;
  ftsmallint,ftinteger,ftword: result:= sizeof(longint);
  ftboolean: result:= sizeof(wordbool);
  ftbcd: result:= sizeof(currency);
  ftfloat: result:= sizeof(double);
  ftlargeint: result:= sizeof(largeint);
  fttime,ftdate,ftdatetime: result:= sizeof(tdatetime);
  ftmemo,ftblob: result:= fielddef.size;
  else result := 10
 end;
end;

function tmsebufdataset.loadbuffer(var buffer: recheaderty): tgetresult;
var
 int1: integer;
begin
 if not fetch then  begin
  result := greof;
  fallpacketsfetched := true;
  exit;
 end;
 pointer(buffer.blobinfo):= nil;
 fillchar(buffer.fielddata.nullmask,fnullmasksize,0);
 for int1:= 0 to fielddefs.count-1 do begin
  if not loadfield(fielddefs[int1],
                        pointer(@buffer)+ffieldbufpositions[int1]) then begin
   setfieldisnull(buffer.fielddata.nullmask,int1);
  end;
 end;
 result := grok;
end;

function tmsebufdataset.getfielddata(field: tfield; buffer: pointer;
  nativeformat: boolean): boolean;
begin
  result := getfielddata(field, buffer);
end;

function tmsebufdataset.getfielddata(field: tfield; buffer: pointer): boolean;
var 
 currbuff : pchar;
 int1: integer;
begin
 result := false;
 if state = dscalcfields then begin
  currbuff:= @pdsrecordty(calcbuffer)^.header;
 end
 else begin
  if bs_applying in fbstate then begin
   currbuff:= @fnewvaluebuffer^.header;
  end
  else begin
   currbuff:= @pdsrecordty(activebuffer)^.header;
  end;
 end;
 int1:= field.fieldno - 1;
 if int1 >= 0 then begin // data field
  if state = dsoldvalue then begin
   if not getrecordupdatebuffer then begin
       // there is no old value available
    exit;
   end;
   currbuff:= @fupdatebuffer[fcurrentupdatebuffer].oldvalues^.header;
  end
  else begin
   if not assigned(currbuff) then begin
    exit;
   end;
  end;
  if getfieldisnull(precheaderty(currbuff)^.fielddata.nullmask,int1) then begin
   exit;
  end;
  inc(currbuff,ffieldbufpositions[int1]);
  if assigned(buffer) then begin
   move(currbuff^,buffer^,ffieldsizes[int1]);
  end;
  result := true;
 end
 else begin //calc or lookup field
  if currbuff <> nil then begin
   currbuff:= currbuff + frecordsize + field.offset;
   if (currbuff + field.datasize)^ <> #0 then begin
    result:= true;
    if buffer <> nil then begin
     move(currbuff^,buffer^,field.datasize);
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.setfielddata(field: tfield; buffer: pointer);

var 
 currbuff: pointer;
 nullmask: pbyte;
 int1: integer;
begin
//  if not (state in [dsedit, dsinsert, dsfilter]) then begin
 if not (state in dswritemodes) then begin
  databaseerrorfmt(snotineditstate,[name],self);
  exit;
 end;
 if state = dscalcfields then begin
  currbuff:= @pdsrecordty(calcbuffer)^.header;
 end
 else begin
  if bs_applying in fbstate then begin
   currbuff:= @fnewvaluebuffer^.header;
  end
  else begin
   currbuff:= @pdsrecordty(activebuffer)^.header;
  end;
 end;
 int1:= field.fieldno - 1;
 if int1 >= 0 then begin // data field
  if state = dsfilter then begin 
   currbuff:= @ffilterbuffer^.header;
  end;
  nullmask:= @precheaderty(currbuff)^.fielddata.nullmask;
  inc(currbuff,ffieldbufpositions[int1]);
  if assigned(buffer) then begin
   move(buffer^,currbuff^,ffieldsizes[int1]);
   unsetfieldisnull(nullmask,int1);
  end
  else begin
   setfieldisnull(nullmask,int1);
  end;     
  if not (state in [dscalcfields,dsfilter,dsnewvalue]) then begin
   dataevent(defieldchange, ptrint(field));
  end;
 end
 else begin //calc or lookup field
  currbuff:= currbuff + frecordsize + field.offset;
  if buffer <> nil then begin
   pchar(currbuff+field.datasize)^:= #1;
   move(buffer^,currbuff^,field.datasize);
  end
  else begin
   pchar(currbuff+field.datasize)^:= #0;
  end;
 end;
end;

procedure tmsebufdataset.setfielddata(field: tfield; buffer: pointer;
  nativeformat: boolean);
begin
 setfielddata(field,buffer);
end;

procedure tmsebufdataset.getnewupdatebuffer;
begin
 setlength(fupdatebuffer,high(fupdatebuffer)+2);
 fcurrentupdatebuffer:= high(fupdatebuffer);
end;

procedure tmsebufdataset.internaldelete;
begin
 if not getrecordupdatebuffer then begin
  getnewupdatebuffer;
  with fupdatebuffer[fcurrentupdatebuffer] do begin
   bookmark.recno:= frecno;
   bookmark.recordpo:= fcurrentrecord;
   oldvalues:= bookmark.recordpo;
  end;
 end
 else begin
  with fupdatebuffer[fcurrentupdatebuffer] do begin
   intfreerecord(bookmark.recordpo);
   if updatekind = ukmodify then begin
    bookmark.recordpo:= oldvalues;
   end
   else begin //ukinsert
    bookmark.recordpo := nil;  //this 'disables' the updatebuffer
   end;
  end;
 end;
 deleterecord(frecno);
//  dec(fbrecordcount);
 fupdatebuffer[fcurrentupdatebuffer].updatekind := ukdelete;
end;

procedure tmsebufdataset.applyrecupdate(updatekind : tupdatekind);
begin
 raise edatabaseerror.create(sapplyrecnotsupported);
end;

procedure tmsebufdataset.cancelrecupdate(var arec: recupdatebufferty);
begin
 with arec do begin
  if bookmark.recordpo <> nil then begin
   if updatekind = ukmodify then begin
    freeblobs(bookmark.recordpo^.header.blobinfo);
    move(oldvalues^.header,bookmark.recordpo^.header,frecordsize);
    pointer(bookmark.recordpo^.header.blobinfo):= nil;
    intfreerecord(oldvalues);
   end
   else begin
    if updatekind = ukdelete then begin
     insertrecord(bookmark.recno,bookmark.recordpo);
    end
    else begin
     if updatekind = ukinsert then begin
      intfreerecord(bookmark.recordpo);
      deleterecord(bookmark.recno);
     end;
    end;
   end;
  end;
 end;
end;

procedure tmsebufdataset.cancelupdate;
var 
 int1: integer;
begin
 cancel;
 checkbrowsemode;
 if (fupdatebuffer <> nil) and (frecno >= 0) then begin
  for int1:= high(fupdatebuffer) downto 0 do begin
   if fupdatebuffer[int1].bookmark.recordpo = fcurrentrecord then begin
    cancelrecupdate(fupdatebuffer[int1]);
    deleteitem(fupdatebuffer,typeinfo(trecordsupdatebuffer),int1);
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

procedure tmsebufdataset.SetOnUpdateError(const AValue: TResolverErrorEvent);

begin
  FOnUpdateError := AValue;
end;

procedure tmsebufdataset.internalapplyupdate(const maxerrors: integer;
               const cancelonerror: boolean; var response: tresolverresponse);
               
 procedure checkcancel;
 begin
  if cancelonerror then begin
   cancelrecupdate(fupdatebuffer[fcurrentupdatebuffer]);
   fupdatebuffer[fcurrentupdatebuffer].bookmark.recordpo:= nil;
   resync([]);
  end;
 end;
 
var
 EUpdErr: EUpdateError;

begin
 include(fbstate,bs_applying);
 try
  with fupdatebuffer[fcurrentupdatebuffer] do begin
   move(bookmark.recordpo^.header,fnewvaluebuffer^.header,frecordsize);
   getcalcfields(pchar(fnewvaluebuffer));
   Response:= rrApply;
   try
    try
     ApplyRecUpdate(UpdateKind);
    finally
     pointer(bookmark.recordpo^.header.blobinfo):= 
         pointer(fnewvaluebuffer^.header.blobinfo); //update deleted blobs
    end;
   except
    on E: EDatabaseError do begin
     Inc(fFailedCount);
     if longword(ffailedcount) > longword(MaxErrors) then begin
      Response:= rrAbort
     end
     else begin
      Response:= rrSkip;
     end;
     EUpdErr:= EUpdateError.Create(SOnUpdateError,E.Message,0,0,E);
     if assigned(OnUpdateError) then begin
      OnUpdateError(Self,Self,EUpdErr,UpdateKind,Response);
     end
     else begin
      if Response = rrAbort then begin
       checkcancel;
       Raise EUpdErr;
      end;
     end;
     eupderr.free;
    end
    else begin
     raise;
    end;
   end;
   if response = rrApply then begin
    intFreeRecord(OldValues);
    Bookmark.recordpo:= nil;
   end
   else begin
    checkcancel;
   end;
  end;
 finally
  exclude(fbstate,bs_applying);
 end;
end;

procedure tmsebufdataset.afterapply;
begin
 //dummy
end;

procedure tmsebufdataset.applyupdate(const cancelonerror: boolean = false); //applies current record
var
 response: tresolverresponse;
 int1: integer;
begin
 checkbrowsemode;
 if getrecordupdatebuffer then begin
  ffailedcount:= 0;
  int1:= fcurrentupdatebuffer;
  internalapplyupdate(0,cancelonerror,response);
  if response = rrapply then begin
   afterapply;
   deleteitem(fupdatebuffer,typeinfo(recupdatebufferarty),int1);
   fcurrentupdatebuffer:= bigint; //invalid
  end;
 end;
end;

procedure tmsebufdataset.ApplyUpdates(const MaxErrors: Integer; 
                                const cancelonerror: boolean = false);
var
 Response: TResolverResponse;
 recnobefore: integer;

begin
 CheckBrowseMode;
 disablecontrols;
 recnobefore:= frecno;
 try
  fapplyindex := 0;
  fFailedCount := 0;
  Response := rrApply;
  while (fapplyindex <= high(FUpdateBuffer)) and (Response <> rrAbort) do begin
   fcurrentupdatebuffer:= fapplyindex;
   if FUpdateBuffer[fcurrentupdatebuffer].Bookmark.recordpo <> nil then begin
    internalapplyupdate(maxerrors,cancelonerror,response);
   end;
   inc(fapplyindex);
  end;
  if ffailedcount = 0 then begin
   fupdatebuffer:= nil;
  end;
 finally 
  if active then begin
   internalsetrecno(recnobefore);
   Resync([]);
   enablecontrols;
  end
  else begin
   enablecontrols;
  end;
 end;
 afterapply;
end;

procedure tmsebufdataset.ApplyUpdates(const maxerrors: integer = 0);
begin
 applyupdates(maxerrors,false);
end;

procedure tmsebufdataset.applyupdate;
begin
 applyupdate(false);
end;

procedure tmsebufdataset.internalpost;
var
// recbuf: pintrecordty;
 po1,po2: pblobinfoarty;
 po3: pointer;
 int1,int2,int3: integer;
 bo1: boolean;
 ar1: integerarty;
begin
 with pdsrecordty(activebuffer)^ do begin
  bo1:= false;
  with header do begin
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].new then begin
     blobinfo[int1].new:= false;
     bo1:= true;
    end;
   end;
  end;
  if state = dsinsert then begin
   fcurrentrecord:= intallocrecord;
  end;
  if not getrecordupdatebuffer then begin
   getnewupdatebuffer;
   with fupdatebuffer[fcurrentupdatebuffer] do begin
    bookmark.recordpo:= fcurrentrecord;
    bookmark.recno:= frecno;
    if state = dsedit then begin
     oldvalues:= intallocrecord;
     move(bookmark.recordpo^,oldvalues^,frecordsize+intheadersize);
     po1:= getintblobpo;
     if po1^ <> nil then begin
      po2:= @oldvalues^.header.blobinfo;
      pointer(po2^):= nil;
      setlength(po2^,length(po1^));
      for int1:= high(po1^) downto 0 do begin
       po2^[int1]:= po1^[int1];
       with po2^[int1] do begin
        if datalength > 0 then begin
         po3:= getmem(datalength);
         move(data^,po3^,datalength);
         data:= po3;
        end
        else begin
         data:= nil;
        end;
       end;
      end;
     end;
     updatekind := ukmodify;
    end
    else begin
     updatekind := ukinsert;
    end;
   end;
  end;
  if (state = dsedit) and (bs_indexvalid in fbstate) then begin
   setlength(ar1,findexlocal.count);
   for int1:= high(ar1) downto 0 do begin
    ar1[int1]:= findexlocal[int1].findboundary(fcurrentrecord);
   end;
  end;   
  if bo1 then begin
   fcurrentrecord^.header.blobinfo:= nil; //free old array
  end;
  move(header,fcurrentrecord^.header,frecordsize); //get new field values
  if state = dsinsert then begin
   frecno:= insertrecord(recno,fcurrentrecord);
   with dsheader.bookmark do  begin
    data.recordpo:= fcurrentrecord;
    data.recno:= frecno;
    flag := bfinserted;
   end;      
  end
  else begin
   if (state = dsedit) and (bs_indexvalid in fbstate) then begin
    for int1:= high(ar1) downto 0 do begin
     int2:= findexlocal[int1].findboundary(fcurrentrecord);
     if int2 <> ar1[int1] then begin
      with findexes[int1+1] do begin
       for int3:= ar1[int1] - 1 downto 0 do begin
        if ind[int3] = fcurrentrecord then begin //update indexes
         move(ind[int3+1],ind[int3],(fbrecordcount-int3-1)*sizeof(pointer));
         if int3 < int2 then begin
          dec(int2);
         end;
         move(ind[int2],ind[int2+1],(fbrecordcount-int2-1)*sizeof(pointer));
         ind[int2]:= fcurrentrecord;
         if int1 = factindex - 1 then begin
          frecno:= int2;
         end;
         break;
        end;
       end;
      end;
     end;
    end;
    dsheader.bookmark.data.recno:= frecno;
   end;
  end;
 end;
end;

procedure tmsebufdataset.calcrecordsize;
var 
 x: longint;
begin
 frecordsize:= sizeof(blobinfoarty);
 fnullmasksize:= 1+((fielddefs.count-1) div 8);
 inc(frecordsize,fnullmasksize);
 setlength(ffieldbufpositions,fielddefs.count);
 setlength(ffieldsizes,length(ffieldbufpositions));
 for x:= 0 to high(ffieldbufpositions) do begin
  ffieldbufpositions[x]:= frecordsize;
  ffieldsizes[x]:= getfieldsize(fielddefs[x]);
  inc(frecordsize,ffieldsizes[x]);
 end;
end;

function tmsebufdataset.GetRecordSize : Word;

begin
  result := FRecordSize;
end;

function tmsebufdataset.GetChangeCount: integer;

begin
  result := length(FUpdateBuffer);
end;


procedure tmsebufdataset.InternalInitRecord(Buffer: PChar);

begin
 with pdsrecordty(buffer)^ do begin
  FillChar(header, FRecordSize, #0);
  fillchar(header.fielddata.nullmask,FNullmaskSize,255);
 end;
end;

procedure tmsebufdataset.SetRecNo(Value: Longint);
var
 bm: bufbookmarkty;
begin
 checkbrowsemode;
 if value > RecordCount then begin
  repeat
  until (getnextpacket < FPacketRecords) or (value <= RecordCount) or
                        (bs_fetchall in fbstate);
 end;
 if (value > RecordCount) or (value < 1) then begin
  DatabaseError(SNoSuchRecord,self);
 end;
 bm.data.recordpo:= nil;
 bm.data.recno:= value-1;
 GotoBookmark(@bm);
end;

function tmsebufdataset.GetRecNo: Longint;
begin
 if activebuffer <> nil then begin
  with pdsrecordty(activebuffer)^.dsheader.bookmark do begin
   result:= data.recno + 1;
   if (state = dsinsert) and (flag = bfeof) then begin
    inc(result); //append mode
   end;
  end;
 end
 else begin
  result:= 0;
 end;
end;

function tmsebufdataset.IsCursorOpen: Boolean;

begin
 Result:= FOpen;
end;

Function tmsebufdataset.GetRecordCount: Longint;

begin
 Result:= FBRecordCount;
end;

Function tmsebufdataset.UpdateStatus: TUpdateStatus;

begin
 Result:= usUnmodified;
  if GetRecordUpdateBuffer then
    case FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind of
      ukModify : Result := usModified;
      ukInsert : Result := usInserted;
      ukDelete : Result := usDeleted;
    end;
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
procedure tmsebufdataset.internalcancel;
var
 int1: integer;
begin
 with pdsrecordty(activebuffer)^.header do begin
  for int1:= high(blobinfo) downto 0 do begin
   if blobinfo[int1].new then begin
    deleteblob(blobinfo,int1);
   end;
  end;
 end;
end;

function tmsebufdataset.CreateBlobStream(Field: TField;
               Mode: TBlobStreamMode): TStream;
var
 int1: integer;
begin
 if (mode <> bmread) and not (state in dseditmodes) then begin
  DatabaseErrorFmt(SNotInEditState,[NAme],self);
 end;  
 result:= nil;
 if mode = bmread then begin
  with pdsrecordty(activebuffer)^.header do begin
   for int1:= high(blobinfo) downto 0 do begin
    if blobinfo[int1].field = field then begin
     result:= tblobcopy.create(blobinfo[int1]);
     break;
    end;
   end;
  end;
 end; 
end;

procedure tmsebufdataset.setdatastringvalue(const afield: tfield; const avalue: string);
var
 po1: pbyte;
 int1: integer;
begin
 if bs_applying in fbstate then begin
  po1:= pbyte(@fupdatebuffer[fcurrentupdatebuffer].bookmark.recordpo^.header);
 end
 else begin
  po1:= pbyte(@fcurrentrecord^.header);
 end;
 int1:= afield.fieldno - 1;
 if avalue <> '' then begin
  move(avalue[1],(po1+ffieldbufpositions[int1])^,length(avalue));
  unsetfieldisnull(precheaderty(po1)^.fielddata.nullmask,int1);
 end
 else begin
  setfieldisnull(precheaderty(po1)^.fielddata.nullmask,int1);
 end;
end; 

procedure tmsebufdataset.checkindexsize;
var
 int1,int2: integer;
begin
 if high(factindexpo^.ind) <= fbrecordcount - 1 then begin
  int2:= (high(factindexpo^.ind)+17)*2;
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
   int2:= findexlocal[int1-1].findboundary(arecord);
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
    int2:= findexlocal[int1-1].findrec(arecord);
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
 inc(fbrecordcount);
 if frecno > arecno then begin
  inc(frecno);
  fcurrentrecord:= factindexpo^.ind[frecno];
 end;
end;

procedure tmsebufdataset.deleterecord(const arecno: integer);
var
 po1: pintrecordty;
 int1: integer;
begin
 if bs_indexvalid in fbstate then begin
  removeindexrefs(pintrecordty(factindexpo^.ind[arecno]));
 end;
 dec(fbrecordcount);
 with findexes[0] do begin
  if factindex = 0 then begin
   int1:= arecno;
  end
  else begin
   po1:= factindexpo^.ind[arecno];
   for int1:= fbrecordcount downto 0 do begin
    if ind[int1] = po1 then begin
     break;
    end;
   end;
  end;
  move(ind[int1+1],ind[int1],(fbrecordcount-int1)*sizeof(pointer));
 end;
 if factindex <> 0 then begin
  with factindexpo^ do begin
   move(ind[arecno+1],ind[arecno],(fbrecordcount-arecno)*sizeof(pointer));
  end;
 end;
 if frecno > arecno then begin
  dec(frecno);
 end;
 if frecno < 0 then begin
  fcurrentrecord:= nil;
 end
 else begin
  fcurrentrecord:= factindexpo^.ind[frecno];
 end;
end;

procedure tmsebufdataset.checkindex;
var
 int1,int2: integer;
begin
 if (factindex <> 0) and not (bs_indexvalid in fbstate) then begin
  int2:= length(findexes[0].ind);
  for int1:= 1 to high(findexes) do begin
   with findexes[int1] do begin
    allocuninitedarray(int2,sizeof(pointer),ind);
    move(findexes[0].ind[0],ind[0],fbrecordcount*sizeof(pointer));
    findexlocal.items[int1-1].sort(ind);
   end;
  end;
  include(fbstate,bs_indexvalid);
 end;
end;

procedure tmsebufdataset.internalsetrecno(const avalue: integer);
begin
 frecno:= avalue;
 if (avalue < 0) or (avalue >= fbrecordcount)  then begin
  fcurrentrecord:= nil;
 end
 else begin
  checkindex;
  fcurrentrecord:= factindexpo^.ind[avalue];
 end;
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
 if fpacketrecords < 0 then begin
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
  if fpacketrecords >= 0 then begin
   exclude(fbstate,bs_fetchall);
  end;
 end;
end;

procedure tmsebufdataset.setactindex(const avalue: integer);
var
 int1: integer;
begin
 if factindex <> avalue then begin
  if active then begin
   checkbrowsemode;
   factindex:= avalue;
   factindexpo:= @findexes[avalue];
   internalsetrecno(findrec(fcurrentrecord));
   resync([]);
  end
  else begin
   factindex:= avalue;
   factindexpo:= @findexes[avalue];
  end;
 end;
end;

function tmsebufdataset.findrec(const arecord: pintrecordty): integer;
var
 int1: integer;
begin
 if factindex = 0 then begin
  result:= -1;
  with findexes[0] do begin
   for int1:= fbrecordcount - 1 downto 0 do begin
    if ind[int1] = arecord then begin
     result:= int1;
     break;
    end;
   end;
  end;  
 end
 else begin
  result:= findexlocal[factindex-1].findrec(arecord);
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

{ tlocalindexes }

constructor tlocalindexes.create(const aowner: tmsebufdataset);
begin
 inherited create(aowner,tlocalindex);
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
 tmsebufdataset(fowner).updatestate;
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
begin
end;

procedure tlocalindex.setoptions(const avalue: localindexoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  change;
 end;
end;

function tlocalindex.compare(l,r: pintrecordty): integer;
label
 next;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(findexfieldinfos) do begin
  with findexfieldinfos[int1] do begin
   if getfieldisnull(@l^.header.fielddata.nullmask,fieldindex) then begin
    if getfieldisnull(@r^.header.fielddata.nullmask,fieldindex) then begin
     goto next;
    end
    else begin
     dec(result);
    end;
   end
   else begin
    if getfieldisnull(@r^.header.fielddata.nullmask,fieldindex) then begin
     inc(result);
    end
    else begin    
     result:= comparefunc((pointer(l)+recoffset)^,(pointer(r)+recoffset)^);
    end;
   end;
   if desc then begin
    result:= -result;
   end;
  end;
  if result <> 0 then begin
   break;
  end;
next:
 end;
 if lio_desc in foptions then begin
  result:= -result;
 end;
end;

procedure tlocalindex.quicksort(l,r: integer);
var
  i,j: integer;
  p: integer;
  int: integer;
  po1: pintrecordty;
begin
 repeat
  i:= l;
  j:= r;
  p:= (l + r) shr 1;
  repeat
   while compare(fsortarray^[i],fsortarray^[p]) < 0 do begin
    inc(i);
   end;
   while compare(fsortarray^[j],fsortarray^[p]) > 0 do begin
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

function tlocalindex.findboundary(const arecord: pintrecordty): integer;
                          //returns index of next bigger
var
 int1: integer;
 lower,upper,pivot: integer;
begin
 result:= -1;
 with tmsebufdataset(fowner),findexes[findexlocal.indexof(self) + 1] do begin
  if fbrecordcount > 0 then begin
   int1:= 0;
   checkindex;
   lower:= 0;
   upper:= fbrecordcount - 1;
   while true do begin
    pivot:= (upper + lower) div 2;
    int1:= compare(arecord,ind[pivot]);
    if upper = lower then begin
     result:= lower;
     break;
    end;
    if int1 >= 0 then begin //pivot <= rev
     if lower = pivot then begin
      inc(lower)
     end
     else begin
      lower:= pivot;
     end;
    end
    else begin
     upper:= pivot;
    end;
   end;
  end;
  if int1 >= 0 then begin
   inc(result);
  end;
 end;
end;

function tlocalindex.findrec(const arecord: pintrecordty): integer;
var
 int1: integer;
begin
 result:= -1;
 int1:= findboundary(arecord) - 1;
 with tmsebufdataset(fowner),findexes[findexlocal.indexof(self) + 1] do begin
  for int1:= int1 downto 0 do begin
   if ind[int1] = arecord then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

procedure tlocalindex.sort(var adata: pointerarty);
begin
 if adata <> nil then begin
  fsortarray:= @adata[0];
  quicksort(0,tmsebufdataset(fowner).fbrecordcount - 1);
 end;
end;

function tlocalindex.getactive: boolean;
begin
 with tmsebufdataset(fowner) do begin
  result:= actindex = findexlocal.indexof(self) + 1;
 end;
end;

procedure tlocalindex.setactive(const avalue: boolean);
begin
 with tmsebufdataset(fowner) do begin
  if avalue then begin
   actindex:= findexlocal.indexof(self) + 1;
  end
  else begin
   if active then begin
    actindex:= 0;
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
 with tmsebufdataset(fowner) do begin
  for int1:= 0 to high(findexfieldinfos) do begin
   with ffields.items[int1],findexfieldinfos[int1] do begin
    field1:= findfield(fieldname);
    if field1 = nil then begin
     databaseerror('Index field "'+fieldname+'" not found.',tmsebufdataset(fowner));
    end;
    with field1 do begin
     if (fieldkind <> fkdata) or not (datatype in indexfieldtypes) then begin
      databaseerror('Invalid index field "'+fieldname+'".',tmsebufdataset(fowner));
     end;
     for kind1:= low(fieldcomparekindty) to high(fieldcomparekindty) do begin
      with comparefuncs[kind1] do begin
       if datatype in datatypes then begin
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
      recoffset:= ffieldbufpositions[fieldindex]+intheadersize;
     end
     else begin
      recoffset:= offset; //calc field
     end;
     desc:= ifo_desc in foptions;
    end;
   end;
  end;
 end;
end;

{ tindexfields }

constructor tindexfields.create(const aowner: tlocalindex);
begin
 inherited create(aowner,tindexfield);
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

end.
