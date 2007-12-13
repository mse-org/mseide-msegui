unit mseifids;
{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,mseifi,mseclasses,mseglob,mseevent,msedb,msetypes,msebufdataset,
 msestrings;

//single record dataset

const
 defaultifidstimeout = 10000000; //10 second

type
 recheaderty = record
//  blobinfo: blobinfoarty;
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
type
     
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

 ifidsstatety = (ids_openpending,ids_fielddefsreceived,ids_remotedata,ids_append);
 ifidsstatesty = set of ifidsstatety;
 
 tifidataset = class(tdataset,ievent,idscontroller,igetdscontroller)
  private
   fchannel: tcustomiochannel;
   fobjectlinker: tobjectlinker;
   fstrings: integerarty;
   fmsestrings: integerarty;
   fifiname: string;
   fcontroller: tdscontroller;
   fistate: ifidsstatesty;
   fdefaulttimeout: integer;
   fmsestringpositions: integerarty;
   fansistringpositions: integerarty;
   Ffieldinfos: fieldinfoarty;
   frecordsize: integer;
   fcalcrecordsize: integer;
   fnullmasksize: integer;
   fmodifiedfields: string; //same layout as nullmask
   
//   fintbuffer: pintrecordty;
   frecno: integer;
   fbrecordcount: integer; //always 1 if open
   fcurrentbuf: pintrecordty;
   fbufs: pointerarty;
   fopen: boolean;

   fremotedatachange: notifyeventty;
   procedure initmodifiedfields;   
   procedure setchannel(const avalue: tcustomiochannel);
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
       //idscontroller
   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   procedure inheritedpost;
   function inheritedmoveby(const distance: integer): integer;
   procedure inheritedinternalinsert;
   procedure inheritedinternaldelete;
   procedure inheritedinternalopen; virtual;
   procedure inheritedinternalclose;
   function getblobdatasize: integer;
   function getnumboolean: boolean;
   function getfloatdate: boolean;
   function getint64currency: boolean;

   function  intallocrecord: pintrecordty;    
   procedure finalizestrings(var header: recheaderty);
   procedure finalizecalcstrings(var header: recheaderty);
   procedure finalizechangedstrings(const tocompare: recheaderty; 
                                      var tofinalize: recheaderty);
   procedure addrefstrings(var header: recheaderty);
   procedure intfinalizerecord(const buffer: pintrecordty);
   procedure intfreerecord(var buffer: pintrecordty);
   procedure internalsetrecno(const avalue: integer);
   function findrecord(arecordpo: pintrecordty): integer;
                         //returns index, -1 if not found
   function getfiltereditkind: filtereditkindty;
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   
  protected
   ffielddefsequence: sequencety;
   fbindings: integerarty;
   procedure checkrecno(const avalue: integer);
   procedure processdata(const adata: pifirecty);
   procedure requestfielddefsreceived(const asequence: sequencety); virtual;
   procedure requestopendsreceived(const asequence: sequencety); virtual;
   procedure fielddefsdatareceived( const asequence: sequencety; 
                                 const adata: pfielddefsdatadataty); virtual;
   procedure dsdatareceived( const asequence: sequencety; 
                                 const adata: pfielddefsdatadataty); virtual;
   procedure fieldrecdatareceived(const adata: pfieldrecdataty); virtual;
   procedure doremotedatachange;
   procedure waitforanswer(const asequence: sequencety; waitus: integer = 0);
                      //0 -> defaulttimeout
   
   function senddata(const adata: ansistring): sequencety;
                //returns sequence number
   function senddataandwait(const adata: ansistring; out asequence: sequencety;
                                  atimeoutus: integer = 0): boolean;
   procedure inititemheader(out arec: string; const akind: ifireckindty; 
                    const asequence: sequencety; const datasize: integer;
                    out datapo: pchar);
   procedure postrecord(const akind: fieldreckindty);
   function encoderecords: string;
   function encoderecord(const aindex: integer; const recpo: pintrecordty): string;
   procedure decoderecord(var adata: pointer; const dest: pintrecordty);
   function decoderecords(const adata: precdataty; out asize: integer): boolean;
   
   procedure notimplemented(const atext: string);
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;   
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
     //ievent
   procedure receiveevent(const event: tobjectevent); virtual;
   
   procedure bindfields(const bind: boolean);
   function AllocRecordBuffer: PChar; override;
   procedure FreeRecordBuffer(var Buffer: PChar); override;
   procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
   function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
//   function GetDataSource: TDataSource; override;
   function GetRecord(Buffer: PChar; GetMode: TGetMode;
                                DoCheck: Boolean): TGetResult; override;
   function GetRecordSize: Word; override;
   function getrecno: integer; override;
   procedure setrecno(value: longint); override;
   function  GetRecordCount: Longint; override;

   function getfieldbuffer(const afield: tfield;
             out buffer: pointer; out datasize: integer): boolean; overload; 
             //read, true if not null
   function getfieldbuffer(const afield: tfield;
             const isnull: boolean; out datasize: integer): pointer; overload;
             //write
   function getmsestringdata(const sender: tmsestringfield; 
                               out avalue: msestring): boolean;
   procedure setmsestringdata(const sender: tmsestringfield; const avalue: msestring);

   function getfielddata(field: tfield; buffer: pointer;
                       nativeformat: boolean): boolean; override;
   function getfielddata(field: tfield; buffer: pointer): boolean; override;
   procedure setfielddata(field: tfield; buffer: pointer;
                                    nativeformat: boolean); override;
   procedure setfielddata(field: tfield; buffer: pointer); override;
   procedure dataevent(event: tdataevent; info: ptrint); override;

   procedure InternalCancel; override;
   procedure internaledit; override;

   procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;
   procedure InternalClose; override;
   procedure InternalDelete; override;
   procedure InternalFirst; override;
   procedure InternalGotoBookmark(ABookmark: Pointer); override;
//   procedure InternalHandleException; override;
   procedure InternalInitFieldDefs; override;
   procedure InternalInitRecord(Buffer: PChar); override;
   procedure InternalLast; override;
   procedure InternalOpen; override;
   procedure InternalPost; override;
   procedure InternalSetToRecord(Buffer: PChar); override;
   function IsCursorOpen: Boolean; override;
   procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
   procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;

   procedure cancelconnection;
   procedure calcrecordsize;
   
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure openlocal;
   procedure internalinsert; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure Append;
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
   property ifistate: ifidsstatesty read fistate;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
   property channel: tcustomiochannel read fchannel write setchannel;
   property ifiname: string read fifiname write fifiname;
   property timeoutus: integer read fdefaulttimeout write fdefaulttimeout 
                       default defaultifidstimeout;
   property remotedatachange: notifyeventty read fremotedatachange 
                                              write fremotedatachange;
   property BeforeOpen;
   property AfterOpen;
   property BeforeClose;
   property AfterClose;
   property BeforeInsert;
   property AfterInsert;
   property BeforeEdit;
   property AfterEdit;
   property BeforePost;
   property AfterPost;
   property BeforeCancel;
   property AfterCancel;
   property BeforeDelete;
   property AfterDelete;
   property BeforeScroll;
   property AfterScroll;
   property OnCalcFields;
   property OnDeleteError;
   property OnEditError;
   property OnFilterRecord;
   property OnNewRecord;
   property OnPostError;
   property AutoCalcFields;
 end;
 
 trxdataset = class(tifidataset)
  private
   procedure inheritedinternalopen; override;
  protected
   procedure fielddefsdatareceived(const asequence: sequencety; 
                                  const adata: pfielddefsdatadataty); override;
   procedure dsdatareceived(const asequence: sequencety; 
                                  const adata: pfielddefsdatadataty); override;
  published
   property fielddefs;
 end;
 
 ttxdataset = class(tifidataset)
  private
  protected
   procedure requestfielddefsreceived(const asequence: sequencety); override;
   procedure requestopendsreceived(const asequence: sequencety); override;
   procedure inheritedinternalopen; override;
  published
   property fielddefs;
 end;
  
implementation
uses
 sysutils,msedatalist,dbconst;
type
 tmsestringfield1 = class(tmsestringfield);
 
const
{$ifdef mse_FPC_2_2}
 snotineditstate = 
 'Operation not allowed, dataset "%s" is not in an edit or insert state.';
            //name changed in FPC 2_2
{$endif}

 ifidskinds = [ik_requestfielddefs,ik_requestopends,ik_fielddefsdata,
               ik_fieldrec,ik_dsdata];
 openflags = [ids_openpending,ids_fielddefsreceived,ids_append];
 
type
 
 fdefitemty = record
  datatype: tfieldtype;
  name: ifinamety;
 end; 
 pfdefitemty = ^fdefitemty;
 fdefdataty = record
  count: integer;
  items: datarecty; //dummy
 end;
 pfdefdataty = ^fdefdataty;
 
function encodefielddefs(const fielddefs: tfielddefs): string;
var
 int1,int2: integer;
 po1: pchar;
begin
 int2:= 0;
 for int1:= 0 to fielddefs.count - 1 do begin
  int2:= int2 + length(fielddefs[int1].name);
 end;
 setlength(result,sizeof(fdefdataty)+fielddefs.count*sizeof(fdefitemty)+int2*6);
 with pfdefdataty(result)^ do begin
  count:= fielddefs.count;
  po1:= @items;
 end;
 for int1:= 0 to fielddefs.count - 1 do begin
  with fielddefs[int1] do begin
   pfdefitemty(po1)^.datatype:= datatype;
   po1:= @pfdefitemty(po1)^.name;
   inc(po1,stringtoifiname(name,pifinamety(po1)));
  end;
 end;
 setlength(result,pointer(po1)-pointer(result));
end;

function decodefielddefs(const adata: pfdefdataty;
                  const fielddefs: tfielddefs; out asize: integer): boolean;
var
 po1: pchar;
 int1: integer;
 str1: string;
 datatype1: tfieldtype;
begin
 fielddefs.clear;
 po1:= @adata^.items;
 for int1:= 0 to adata^.count - 1 do begin
  datatype1:= pfdefitemty(po1)^.datatype;
  po1:= @pfdefitemty(po1)^.name;
  inc(po1,ifinametostring(pifinamety(po1),str1));
  tfielddef.create(fielddefs,str1,datatype1,0,false,int1+1);
 end;
 asize:= pointer(po1) - pointer(adata);
 result:= true;
end;
 
{ tifidataset }

constructor tifidataset.create(aowner: tcomponent);
begin
 frecno:= -1;
 fdefaulttimeout:= defaultifidstimeout;
 fobjectlinker:= tobjectlinker.create(ievent(self),
                           {$ifdef FPC}@{$endif}objectevent);
// setunidirectional(true);
 inherited;
 bookmarksize := sizeof(bufbookmarkty);
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1,false);
end;

destructor tifidataset.destroy;
begin
 fcontroller.free;
 inherited;
 fobjectlinker.free;
end;

function tifidataset.intallocrecord: pintrecordty;
begin
 result:= allocmem(frecordsize+intheadersize);
 fillchar(result^,frecordsize+intheadersize,0);
end;

procedure tifidataset.finalizestrings(var header: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fmsestringpositions) downto 0 do begin
  pmsestring(pointer(@header)+fmsestringpositions[int1])^:= '';
 end;
 for int1:= high(fansistringpositions) downto 0 do begin
  pansistring(pointer(@header)+fansistringpositions[int1])^:= '';
 end;
end;

procedure tifidataset.finalizecalcstrings(var header: recheaderty);
begin
end;

procedure tifidataset.finalizechangedstrings(const tocompare: recheaderty;
               var tofinalize: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fmsestringpositions) downto 0 do begin
  if ppointer(pointer(@tocompare)+fmsestringpositions[int1])^ <>
     ppointer(pointer(@tofinalize)+fmsestringpositions[int1])^ then begin
   pmsestring(pointer(@tofinalize)+fmsestringpositions[int1])^:= '';
  end;
 end;
 for int1:= high(fansistringpositions) downto 0 do begin
  if ppointer(pointer(@tocompare)+fansistringpositions[int1])^ <>
     ppointer(pointer(@tofinalize)+fansistringpositions[int1])^ then begin
   pansistring(pointer(@tofinalize)+fansistringpositions[int1])^:= '';
  end;
 end;
end;

procedure tifidataset.addrefstrings(var header: recheaderty);
var
 int1: integer;
begin
 for int1:= high(fmsestringpositions) downto 0 do begin
  stringaddref(pmsestring(pointer(@header)+fmsestringpositions[int1])^);
 end;
 for int1:= high(fansistringpositions) downto 0 do begin
  stringaddref(pansistring(pointer(@header)+fansistringpositions[int1])^);
 end;
end;

procedure tifidataset.intfinalizerecord(const buffer: pintrecordty);
begin
// freeblobs(buffer^.header.blobinfo);
 finalizestrings(buffer^.header);
end;

procedure tifidataset.intfreerecord(var buffer: pintrecordty);
begin
 if buffer <> nil then begin
  intfinalizerecord(buffer);  
  freemem(buffer);
  buffer:= nil;
 end;
end;

function tifidataset.AllocRecordBuffer: PChar;
begin
 result := allocmem(dsheadersize+fcalcrecordsize);
 initrecord(result);
end;

procedure tifidataset.FreeRecordBuffer(var Buffer: PChar);
begin
 if buffer <> nil then begin
  reallocmem(buffer,0);
 end;
end;

procedure tifidataset.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
 move(pdsrecordty(buffer)^.dsheader.bookmark,data^,sizeof(bookmarkdataty));
end;

function tifidataset.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
 result:= pdsrecordty(buffer)^.dsheader.bookmark.flag;
end;
{
function tifidataset.GetDataSource: TDataSource;
begin
end;
}
procedure tifidataset.internalsetrecno(const avalue: integer);
begin
 frecno:= avalue;
 if (avalue < 0) or (avalue >= fbrecordcount)  then begin
  fcurrentbuf:= nil;
 end
 else begin
  fcurrentbuf:= fbufs[avalue];
 end;
end;

function tifidataset.GetRecord(Buffer: PChar; GetMode: TGetMode;
               DoCheck: Boolean): TGetResult;
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
   if (frecno < 0) or (frecno >= fbrecordcount) or (fcurrentbuf = nil) then begin
    result := grerror;
   end;
  end;
  gmnext: begin
   if frecno >= fbrecordcount - 1 then begin
    result:= greof;
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
   {
   getcalcfields(buffer);
   if filtered then begin
    state1:= settempstate(tdatasetstate(dscheckfilter));
    try
     dofilterrecord(acceptable);
    finally
     restorestate(state1);
    end;
   end;
   if (getmode = gmcurrent) and not acceptable then begin
    result:= grerror;
   end;
   }
  end;
 end;
end;

function tifidataset.GetRecordSize: Word;
begin
 result:= frecordsize;
end;

procedure tifidataset.bindfields(const bind: boolean);
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
    tmsestringfield1(field1).setismsestring(@getmsestringdata,
                                                  @setmsestringdata,int2);
   end
   else begin
    tmsestringfield1(field1).setismsestring(nil,nil,int2);
   end;
  end
  else begin
   if field1 is tmseblobfield then begin
   {
    if bind then begin
     tmseblobfield1(field1).fgetblobid:= @getfieldblobid;
    end
    else begin
     tmseblobfield1(field1).fgetblobid:= nil;
    end;
    }
   end;
  end;
 end;
 inherited;
end;

function tifidataset.getfieldbuffer(const afield: tfield; out buffer: pointer;
               out datasize: integer): boolean;
             //read, true if not null
var
 int1: integer;
begin 
 result:= false;
 if not active then begin
  buffer:= nil;
  exit;
 end;
 int1:= afield.fieldno - 1;
 case ord(state) of
  ord(dscalcfields): begin
//   buffer:= @pdsrecordty(calcbuffer)^.header;
  end;
  dscheckfilter: begin
//   buffer:= @fcheckfilterbuffer^.header;
  end;
  ord(dsfilter): begin
//   buffer:= @ffilterbuffer^.header;
  end;
  ord(dscurvalue): begin
//   buffer:= @fcurrentbuf^.header;
  end;
  else begin
    buffer:= @pdsrecordty(activebuffer)^.header;
   {
   if bs_internalcalc in fbstate then begin
    if int1 < 0 then begin//calc field
     buffer:= @pdsrecordty(activebuffer)^.header;
     //values invalid!
    end
    else begin
     buffer:= @fcurrentbuf^.header;
    end;
   end
   else begin
    if bs_recapplying in fbstate then begin
     buffer:= @fnewvaluebuffer^.header;
    end
    else begin
     buffer:= @pdsrecordty(activebuffer)^.header;
    end;
   end;
   }
  end;
 end;
 if int1 >= 0 then begin // data field
  result:= false;
  {
  if state = dsoldvalue then begin
   if getrecordupdatebuffer then begin
    buffer:= fupdatebuffer[fcurrentupdatebuffer].oldvalues;
    if buffer <> nil then begin
     buffer:= @pintrecordty(buffer)^.header;
    end;
   end
   else begin
    buffer:= @fcurrentbuf^.header   //there is no old value available
   end;
  end;
  }
  if buffer <> nil then begin
   result:= not getfieldisnull(precheaderty(buffer)^.fielddata.nullmask,int1);
   inc(buffer,ffieldinfos[int1].offset{ffieldbufpositions[int1]});
   datasize:= ffieldinfos[int1].size{ffieldsizes[int1]};
  end
  else begin
   datasize:= 0;
  end;
 end
 else begin   
  int1:= -2 - int1;
  if int1 >= 0 then begin //calc field
  {
   result:= not getfieldisnull(pbyte(buffer+frecordsize),int1);
   inc(buffer,fcalcfieldbufpositions[int1]);
   datasize:= fcalcfieldsizes[int1];
  }
  end
  else begin
   buffer:= nil;
   datasize:= 0;
  end;
 end;
end;

function tifidataset.getfieldbuffer(const afield: tfield; const isnull: boolean;
               out datasize: integer): pointer;
             //write
var
 int1: integer;
begin 
 if not ((state in dswritemodes - [dsinternalcalc,dscalcfields]) or 
       (afield.fieldkind = fkinternalcalc) and 
                                (state = dsinternalcalc) or
       (afield.fieldkind = fkcalculated) and 
                                (state = dscalcfields)) then begin
  databaseerrorfmt(snotineditstate,[name],self);
 end;
 int1:= afield.fieldno-1;
 case state of
  dscalcfields: begin
//   result:= @pdsrecordty(calcbuffer)^.header;
  end;
  dsfilter:  begin 
//   result:= @ffilterbuffer^.header;
  end;
  else begin
   result:= @pdsrecordty(activebuffer)^.header;
  {
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
   }
  end;
 end;
 if int1 >= 0 then begin // data field
  unsetfieldisnull(pointer(fmodifiedfields),int1);
  if isnull then begin
   setfieldisnull(precheaderty(result)^.fielddata.nullmask,int1);
  end
  else begin
   unsetfieldisnull(precheaderty(result)^.fielddata.nullmask,int1);
  end;
  inc(result,ffieldinfos[int1].offset{ffieldbufpositions[int1]});
  datasize:= ffieldinfos[int1].size{ffieldsizes[int1]};
 end
 else begin
  int1:= -2 - int1;
  result:= nil;
  datasize:= 0;
  {
  if int1 >= 0 then begin //calc field
   if isnull then begin
    setfieldisnull(pbyte(result+frecordsize),int1);
   end
   else begin
    unsetfieldisnull(pbyte(result+frecordsize),int1);
   end;
   inc(result,fcalcfieldbufpositions[int1]);
   datasize:= fcalcfieldsizes[int1];
  end
  else begin
   result:= nil;
   datasize:= 0;
  end;
  }
 end;
end;

function tifidataset.getmsestringdata(const sender: tmsestringfield;
               out avalue: msestring): boolean;
var
 po1: pointer;
 int1: integer;
begin
 result:= getfieldbuffer(sender,po1,int1);
 if result then begin
  avalue:= msestring(po1^);
 end
 else begin
  avalue:= '';
 end;
end;

procedure tifidataset.setmsestringdata(const sender: tmsestringfield;
               const avalue: msestring);
var
 po1: pointer;
 int1: integer;
begin
 po1:= getfieldbuffer(sender,false,int1);
 msestring(po1^):= avalue;
 if (sender.characterlength > 0) and 
                     (length(avalue) > sender.characterlength) then begin
  setlength(msestring(po1^),sender.characterlength);
 end;
 if (sender.fieldno > 0) and not 
                 (state in [dscalcfields,dsinternalcalc,{dsfilter,}dsnewvalue]) then begin
  dataevent(defieldchange,ptrint(sender));
 end;
end;

function tifidataset.getfielddata(field: tfield; buffer: pointer;
               nativeformat: boolean): boolean;
begin
 result:= getfielddata(field,buffer);
end;

function tifidataset.getfielddata(field: tfield; buffer: pointer): boolean;
var 
 po1: pointer;
 datasize: integer;
begin
 result:= getfieldbuffer(field,po1,datasize);
 if (buffer <> nil) and result then begin 
  move(po1^,buffer^,datasize);
 end;
end;

procedure tifidataset.setfielddata(field: tfield; buffer: pointer;
               nativeformat: boolean);
begin
 setfielddata(field,buffer);
end;

procedure tifidataset.setfielddata(field: tfield; buffer: pointer);
var 
 po1: pointer;
 datasize: integer;
begin
 po1:= getfieldbuffer(field,buffer = nil,datasize);
 if buffer <> nil then begin
  move(buffer^,po1^,datasize);
 end;
 if (field.fieldno > 0) and not 
                 (state in [dscalcfields,dsinternalcalc,{dsfilter,}dsnewvalue]) then begin
  dataevent(defieldchange, ptrint(field));
 end;
end;

procedure tifidataset.initmodifiedfields;
begin
 setlength(fmodifiedfields,fnullmasksize);
 fillchar(pointer(fmodifiedfields)^,fnullmasksize,#0);
end;

procedure tifidataset.InternalCancel;
begin
 with pdsrecordty(activebuffer)^,header do begin
  finalizestrings(header);
 end;
 exclude(fistate,ids_append);
end;

procedure tifidataset.internaledit;
begin
 initmodifiedfields;
 addrefstrings(pdsrecordty(activebuffer)^.header);
 inherited;
end;

procedure tifidataset.InternalPost;
begin
 with pdsrecordty(activebuffer)^ do begin
  if state = dsinsert then begin
   fcurrentbuf:= intallocrecord;
   dsheader.bookmark.data.recordpo:= fcurrentbuf;
   dsheader.bookmark.data.recno:= frecno;
   if fbrecordcount >= high(fbufs) then begin
    setlength(fbufs,(high(fbufs)+7)*2);
   end;
   move(fbufs[frecno],fbufs[frecno+1],(fbrecordcount-frecno)*sizeof(pointer));
   fbufs[frecno]:= fcurrentbuf;
   inc(fbrecordcount);
  end
  else begin
   finalizestrings(fcurrentbuf^.header);
  end;

  move(header,fcurrentbuf^.header,frecordsize); //get new field values
  if not (ids_remotedata in fistate) then begin
   if state = dsinsert then begin
    postrecord(frk_insert);
   end
   else begin
    postrecord(frk_edit);
   end;
  end;
  fillchar(pointer(fmodifiedfields)^,fnullmasksize,0);
 end;
 exclude(fistate,ids_append);
end;

procedure tifidataset.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
 notimplemented('Add record');
end;

procedure tifidataset.InternalFirst;
begin
 internalsetrecno(-1);
end;

function tifidataset.findrecord(arecordpo: pintrecordty): integer;
var
 int1: integer;
begin
 if arecordpo = fcurrentbuf then begin
  result:= frecno;
 end
 else begin
  for int1:= frecno to fbrecordcount - 1 do begin
   if fbufs[int1] = arecordpo then begin
    result:= int1;
    exit;
   end;
  end;
  for int1:= frecno downto 0 do begin
   if fbufs[int1] = arecordpo then begin
    result:= int1;
    exit;
   end;
  end;
  result:= -1;
 end;
end;

procedure tifidataset.InternalGotoBookmark(ABookmark: Pointer);
var
 int1: integer;
 int2: integer;
begin
 if abookmark <> nil then begin
  with pbufbookmarkty(abookmark)^.data do begin
   if (recno >= fbrecordcount) or (recno < 0) then begin
    databaseerror('Invalid bookmark recno: '+inttostr(recno)+'.'); 
   end;
   int1:= recno;
   if recordpo <> nil then begin
    int2:= -1;
    for int1:= frecno to high(fbufs) do begin
     if fbufs[int1] = recordpo then begin
      int2:= int1;
      break;
     end;
    end;
    for int1:= frecno downto 0 do begin
     if fbufs[int1] = recordpo then begin
      int2:= int1;
      break;
     end;
    end;
    if int2 < 0 then begin
     databaseerror('Invalid bookmarkdata.');
    end;
   end
   else begin
    int2:= recno;
   end;
   internalsetrecno(int2);
  end;
 end;
end;
{
procedure tifidataset.InternalHandleException;
begin
end;
}
procedure tifidataset.InternalInitFieldDefs;
begin
 //dummy
end;

procedure tifidataset.InternalInitRecord(Buffer: PChar);
begin
 with pdsrecordty(buffer)^ do begin
  fillchar(header,fcalcrecordsize, #0);
 end;
end;

procedure tifidataset.InternalLast;
begin
 internalsetrecno(fbrecordcount)
end;

procedure tifidataset.InternalSetToRecord(Buffer: PChar);
begin
 internalsetrecno(pdsrecordty(buffer)^.dsheader.bookmark.data.recno);
end;

function tifidataset.IsCursorOpen: Boolean;
begin
 result:= fopen;
end;

procedure tifidataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
 pdsrecordty(buffer)^.dsheader.bookmark.flag:= value;
end;

procedure tifidataset.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
 move(data^,pdsrecordty(buffer)^.dsheader.bookmark,sizeof(bookmarkdataty));
end;

procedure tifidataset.notimplemented(const atext: string);
begin
 raise exception.create(name+': '+atext+' not implemented.');
end;

procedure tifidataset.calcrecordsize;
var
 int1,int2,int3: integer;
 field1: tfield;
begin
 fmsestringpositions:= nil;
 fansistringpositions:= nil;
 int1:= fielddefs.count;
 frecordsize:= 0;
 fnullmasksize:= (int1+7) div 8;
 inc(frecordsize,fnullmasksize);
 alignfieldpos(frecordsize);
 setlength(ffieldinfos,int1);
 for int2:= 0 to int1 - 1 do begin
  with fielddefs[int2] do begin
   field1:= fields.findfield(name);
   if (field1 <> nil) and (field1.fieldkind = fkdata) then begin
    case datatype of
     ftstring,ftfixedchar: begin
      additem(fmsestringpositions,frecordsize);
      int3:= sizeof(msestring);
     end;
     ftsmallint,ftinteger,ftword: begin
      int3:= sizeof(longint);
     end;
     ftboolean: begin
      int3:= sizeof(wordbool);
     end;
     ftbcd: begin
      int3:= sizeof(currency);
     end;
     ftfloat,ftcurrency: begin
      int3:= sizeof(double);
     end;
     ftlargeint: begin
      int3:= sizeof(largeint);
     end;
     fttime,ftdate,ftdatetime: begin
      int3:= sizeof(tdatetime);
     end;
     ftmemo,ftblob: begin
      additem(fansistringpositions,frecordsize);
      int3:= sizeof(string);
     end;
     else begin
      int3:= 0;
     end;
    end;
   end;
   with ffieldinfos[int2] do begin
    offset:= frecordsize;
    inc(frecordsize,int3);
    alignfieldpos(frecordsize);
    size:= int3;
    fieldtype:= datatype;
    field:= field1;
   end;
  end;
 end;
 fcalcrecordsize:= frecordsize; //no calcfields
end;

function tifidataset.locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tifidataset.locate(const key: string;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tifidataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tifidataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tifidataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tifidataset.cancelconnection;
begin
 fistate:= fistate - openflags;
end;

procedure tifidataset.setactive(value: boolean);
begin
 if not value then begin
  cancelconnection;
 end;
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tifidataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tifidataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tifidataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tifidataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tifidataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tifidataset.cancel;
begin
 fcontroller.cancel;
end;

function tifidataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tifidataset.inheritedinternalinsert;
begin
 initmodifiedfields;
 with pdsrecordty(activebuffer)^.dsheader.bookmark.data do begin
  recordpo:= nil;
  recno:= frecno;
 end;
 inherited internalinsert;
end;

procedure tifidataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tifidataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tifidataset.inheritedinternalopen;
var
 int1: integer;
 field1: tfield;
begin
 if defaultfields then begin
  createfields;
 end;
 bindfields(true);
 calcrecordsize;
 setlength(fbindings,fielddefs.count);
 for int1:= 0 to high(fbindings) do begin
  field1:= findfield(fielddefs[int1].name);
  if field1 <> nil then begin
   fbindings[int1]:= field1.index;
  end
  else begin
   fbindings[int1]:= -1;
  end;
 end;
 fopen:= true;
// fintbuffer:= intallocrecord;
// fbrecordcount:= 1;
end;

procedure tifidataset.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tifidataset.inheritedpost;
begin
 inherited post;
end;

procedure tifidataset.post;
begin
 fcontroller.post;
end;

procedure tifidataset.inheritedinternaldelete;
begin
 if state = dsedit then begin
  internalcancel;
 end;
 intfreerecord(fcurrentbuf);
 dec(fbrecordcount);
 move(fbufs[frecno+1],fbufs[frecno],(fbrecordcount-frecno)*sizeof(pointer));
 if not (ids_remotedata in fistate) then begin
  postrecord(frk_delete);
 end;
end;

procedure tifidataset.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tifidataset.openlocal;
begin
 inheritedinternalopen;
end;

procedure tifidataset.inheritedinternalclose;
var
 int1: integer;
begin
 cancelconnection;
 fopen:= false;
 bindfields(false);
 if defaultfields then begin
  destroyfields;
 end;
 for int1:= 0 to fbrecordcount - 1 do begin
  intfreerecord(fbufs[int1]);
 end;
 frecno:= -1;
 fcurrentbuf:= nil;
 fbrecordcount:= 0;
// inherited internalclose;
end;

procedure tifidataset.internalclose;
begin
 fcontroller.internalclose;
end;

function tifidataset.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

function tifidataset.getnumboolean: boolean;
begin
 result:= true;
end;

function tifidataset.getfloatdate: boolean;
begin
 result:= false;
end;

function tifidataset.getint64currency: boolean;
begin
 result:= false;
end;

procedure tifidataset.setchannel(const avalue: tcustomiochannel);
begin
 fobjectlinker.setlinkedvar(ievent(self),avalue,fchannel);
end;

procedure tifidataset.link(const source: iobjectlink; const dest: iobjectlink;
               valuepo: pointer = nil; ainterfacetype: pointer = nil;
               once: boolean = false);
begin
 fobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tifidataset.unlink(const source: iobjectlink; const dest: iobjectlink;
               valuepo: pointer = nil);
begin
 fobjectlinker.unlink(source,dest,valuepo);
end;

procedure tifidataset.objevent(const sender: iobjectlink;
               const event: objecteventty);
begin
 fobjectlinker.objevent(sender,event);
end;

function tifidataset.getinstance: tobject;
begin
 result:= self;
end;

procedure tifidataset.objectevent(const sender: tobject;
               const event: objecteventty);
var
 po1: pifirecty;
begin
 if (event = oe_dataready) and (sender = fchannel) then begin
  if (length(fchannel.rxdata) >= sizeof(ifiheaderty)) then begin
   with fchannel do begin
    po1:= pifirecty(rxdata);
    with po1^.header do begin
     if size = length(rxdata) then begin
      processdata(po1);
     end;
    end;
   end;
  end;
 end;
end;

procedure tifidataset.receiveevent(const event: tobjectevent);
begin
 //dummy
end;

procedure tifidataset.inititemheader(out arec: string;
               const akind: ifireckindty; const asequence: sequencety; 
                const datasize: integer; out datapo: pchar);
begin
 mseifi.inititemheader(tag,fifiname,arec,akind,asequence,datasize,datapo);
end;

function tifidataset.senddata(const adata: ansistring): sequencety;
begin
 if fchannel = nil then begin
  raise exception.create(name+': No IO channel assigned.');
 end;
 result:= fchannel.sequence;
 with pifirecty(adata)^.header do begin
  sequence:= result;
 end;
 fchannel.senddata(adata);
end;

function tifidataset.senddataandwait(const adata: ansistring;
                    out asequence: sequencety; atimeoutus: integer): boolean;
begin
 asequence:= senddata(adata);
 if atimeoutus = 0 then begin
  atimeoutus:= timeoutus;
 end;
 result:= fchannel.waitforanswer(asequence,atimeoutus);
end;

procedure tifidataset.processdata(const adata: pifirecty);
var 
 tag1: integer;
 str1: string;
 po1: pchar;
begin
 with adata^ do begin
  if header.kind in ifidskinds then begin
   with itemheader do begin 
    tag1:= tag;
    po1:= @name;
   end;
   inc(po1,ifinametostring(pifinamety(po1),str1));
   if str1 = fifiname then begin
    case header.kind of
     ik_requestfielddefs: begin
      requestfielddefsreceived(header.sequence);
     end;
     ik_requestopends: begin
      requestopendsreceived(header.sequence);
     end;
     ik_fielddefsdata: begin
      fielddefsdatareceived(header.answersequence,pfielddefsdatadataty(po1));
     end;
     ik_dsdata: begin
      dsdatareceived(header.answersequence,pfielddefsdatadataty(po1));
     end;
     ik_fieldrec: begin
      fieldrecdatareceived(pfieldrecdataty(po1));
     end;
    end;
   end;
  end;
 end;
end;

procedure tifidataset.requestfielddefsreceived(const asequence: sequencety);
begin
 //dummy
end;

procedure tifidataset.requestopendsreceived(const asequence: sequencety);
begin
 //dummy
end;

procedure tifidataset.fielddefsdatareceived(const asequence: sequencety;
               const adata: pfielddefsdatadataty);
begin
 //dummy
end;

procedure tifidataset.dsdatareceived(const asequence: sequencety;
               const adata: pfielddefsdatadataty);
begin
 //dummy
end;

procedure tifidataset.waitforanswer(const asequence: sequencety; 
                                                 waitus: integer = 0);
begin
 if waitus = 0 then begin
  waitus:= fdefaulttimeout;
 end;
 fchannel.waitforanswer(asequence,fdefaulttimeout);
end;

function encodefielddata(const ainfo: fieldinfoty; const headersize: integer): string;
begin
 with ainfo do begin
  if field.isnull then begin
   result:= encodeifinull;
  end
  else begin
   case fieldtype of
    ftlargeint,ftinteger: begin
     result:= encodeifidata(field.aslargeint,headersize);
    end;
    ftfloat: begin
     result:= encodeifidata(field.asfloat,headersize);
    end;
    ftbcd: begin
     result:= encodeifidata(field.ascurrency,headersize);
    end;
    ftblob,ftgraphic: begin
     result:= encodeifidata(field.asstring,headersize);
    end;
    ftstring: begin
     if field is tmsestringfield then begin
      result:= encodeifidata(tmsestringfield(field).asmsestring,headersize);
     end
     else begin
      result:= encodeifidata(msestring(field.asstring),headersize);
     end;
    end;
    else begin
     result:='';
     exit;
    end;
   end;
  end;
 end;
end;

function tifidataset.encoderecord(const aindex: integer; const recpo: pintrecordty): string;
begin
 if getfieldisnull(pbyte(@recpo^.header.fielddata.nullmask),aindex) then begin
  result:= encodeifinull;
 end
 else begin
  with ffieldinfos[aindex] do begin
   case fieldtype of
    ftinteger: begin
     result:= encodeifidata(pinteger(pointer(recpo)+offset)^);
    end;
    ftlargeint: begin
     result:= encodeifidata(plargeint(pointer(recpo)+offset)^);
    end;
    ftfloat: begin
     result:= encodeifidata(pdouble(pointer(recpo)+offset)^);
    end;
    ftbcd: begin
     result:= encodeifidata(pcurrency(pointer(recpo)+offset)^);
    end;
    ftblob,ftgraphic: begin
     result:= encodeifidata(pstring(pointer(recpo)+offset)^);
    end;
    ftstring: begin
     result:= encodeifidata(pmsestring(pointer(recpo)+offset)^);
    end;
    else begin
     result:='';
     exit;
    end;
   end;
  end;
 end;
end;

procedure tifidataset.postrecord(const akind: fieldreckindty);

 function encodefdat(const ainfo: fieldinfoty): string;
 begin
  result:= encodefielddata(ainfo,sizeof(fielddataheaderty));
  if result <> '' then begin
   with pfielddataty(result)^ do begin
    header.index:= ainfo.field.fieldno-1;
   end;
  end;   
 end;
 
var
 int1,int2,int3: integer;
 str1: string;
 ar1: stringarty;
 po1: pfieldrecdataty;
 po2: pchar;
 
begin                 //postrecord
 setlength(ar1,length(ffieldinfos)); //max
 int2:= 0;
 int3:= 0;
 if akind <> frk_delete then begin
  for int1:= 0 to high(ffieldinfos) do begin
   if not getfieldisnull(pointer(fmodifiedfields),int1) then begin
    ar1[int2]:= encodefdat(ffieldinfos[int1]);
    if ar1[int2] <> '' then begin
     inc(int2);
    end;
   end;
  end;
  for int1:= 0 to int2 - 1 do begin
   int3:= int3 + length(ar1[int1]);
  end;
 end;
 inititemheader(str1,ik_fieldrec,0,int3+sizeof(fieldrecdataty),pchar(po1));
 po1^.kind:= akind;
 po1^.recno:= recno;
 po1^.count:= int2;
 po2:= @po1^.data;
 for int1:= 0 to int2 - 1 do begin
  int3:= length(ar1[int1]);
  move(ar1[int1][1],po2^,int3);
  inc(po2,int3);
 end;
 senddata(str1);
end;

procedure tifidataset.fieldrecdatareceived(const adata: pfieldrecdataty);
var
 int1: integer;
 index1: integer;
 po1: pchar;
 mstr1: msestring;
 int641: int64;
 rea1: real;
 cu1: currency;
 str1: string; 
 field1: tfield;
 bo1: boolean;
 bm: string;
 
begin
 if active then begin
  checkbrowsemode;
  disablecontrols;
  include(fistate,ids_remotedata);
  bm:= bookmark;
  try
   if adata^.kind = frk_delete then begin
    recno:= adata^.recno;
    delete;
   end
   else begin
    bo1:= adata^.kind = frk_insert;
    if bo1 then begin
     if adata^.recno >= recordcount then begin
      append;
     end
     else begin
      recno:= adata^.recno;
      insert;
     end;
    end
    else begin
     recno:= adata^.recno;
     edit;
    end;
    po1:= @adata^.data;
    for int1:= 0 to adata^.count - 1 do begin
     index1:= pfielddataty(po1)^.header.index;
     if (index1 >= 0) and (index1 <= high(fbindings)) and 
                                         (fbindings[index1] >= 0) then begin
      field1:= fields[fbindings[index1]];
      inc(po1,sizeof(mseifi.fielddataty.header));
      case pifidataty(po1)^.header.kind of
       idk_null: begin
        field1.clear;
        inc(po1,sizeof(ifidataty));
       end;
       idk_int64: begin
        inc(po1,decodeifidata(pifidataty(po1),int641));
        field1.aslargeint:= int641;
       end;
       idk_real: begin
        inc(po1,decodeifidata(pifidataty(po1),rea1));
        field1.asfloat:= rea1;
       end;
       idk_currency: begin
        inc(po1,decodeifidata(pifidataty(po1),cu1));
        field1.ascurrency:= cu1;
       end;
       idk_bytes: begin
        inc(po1,decodeifidata(pifidataty(po1),str1));
        field1.asstring:= str1;
       end;
       idk_msestring: begin
        inc(po1,decodeifidata(pifidataty(po1),mstr1));
        if field1 is tmsestringfield then begin
         tmsestringfield(field1).asmsestring:= mstr1;
        end
        else begin
         field1.asstring:= mstr1;
        end;
       end;
      end;
     end;
     setfieldisnull(pointer(fmodifiedfields),index1); //reset changeflag
    end;
    post;
   end;
   doremotedatachange;
   try
    bookmark:= bm;
   except
   end;
  finally
   exclude(fistate,ids_remotedata);  
   enablecontrols;
  end;
 end;
end;

procedure tifidataset.doremotedatachange;
begin
 if checkcanevent(self,tmethod(fremotedatachange)) then begin
  fremotedatachange(self);
 end;
end;

procedure tifidataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 if (event = defieldchange) and not (ids_remotedata in fistate) then begin
  if TField(Info).FieldKind in [fkData,fkInternalCalc] then begin
   SetModified(True);
  end;
  exit;
 end;
 inherited dataevent(event,info);
end;

procedure tifidataset.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

procedure tifidataset.Append;
begin
 include(fistate,ids_append);
 inherited;
end;

procedure tifidataset.checkrecno(const avalue: integer);
begin
 if (avalue > recordcount) or (avalue < 1) then begin
  databaseerror(snosuchrecord,self);
 end;
end;

function tifidataset.getrecno: integer;
begin
// if bs_internalcalc in fbstate then begin
//  result:= frecno + 1;
// end
// else begin
  result:= 0;
  if activebuffer <> nil then begin
   with pdsrecordty(activebuffer)^.dsheader.bookmark do begin
    if state = dsinsert  then begin
     if (ids_append in fistate) or (fbrecordcount = 0) then begin
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
// end;
end;

procedure tifidataset.setrecno(value: longint);
var
 bm: bufbookmarkty;
begin
 checkbrowsemode;
 checkrecno(value);
 bm.data.recordpo:= nil;
 bm.data.recno:= value-1;
 gotobookmark(@bm);
end;

function tifidataset.GetRecordCount: Longint;
begin
 result:= fbrecordcount;
end;

function tifidataset.encoderecords: string;
            //todo: optimize
var
 ind1: integer;

 procedure put(const avalue: string; const alength: integer);
 begin
  if ind1 + alength > length(result) then begin
   setlength(result,length(result)*2);
  end;
  move(avalue,result[ind1],alength);
  inc(ind1,alength);
 end;
 
var
 int1,int2: integer;
 str1: string;
  
begin
 setlength(result,16);
 ind1:= 1;
 move(fbrecordcount,result[1],sizeof(fbrecordcount));
 inc(ind1,sizeof(fbrecordcount));
 for int1:= 0 to fbrecordcount - 1 do begin
  for int2:= 0 to high(fbindings) do begin
   if fbindings[int2] >= 0 then begin
    str1:= encoderecord(int2,fbufs[int1]);
    if ind1 + length(str1) > length(result) then begin
     setlength(result,length(result)*2+length(str1));
    end;
    move(str1[1],result[ind1],length(str1));
    inc(ind1,length(str1));
   end;
  end;
 end;
 setlength(result,ind1 - 1);
end;

procedure tifidataset.decoderecord(var adata: pointer; const dest: pintrecordty);
var
 int641: int64;
 double1: double;
 cur1: currency;
 mstr1: msestring;
 str1: string; 
 int1: integer;
begin
 for int1:= 0 to high(fbindings) do begin
  if fbindings[int1] >= 0 then begin
   if pifidataty(adata)^.header.kind <> idk_null then begin
    unsetfieldisnull(pbyte(@dest^.header.fielddata.nullmask),fbindings[int1]);
    with ffieldinfos[fbindings[int1]] do begin
     case fieldtype of 
      ftinteger: begin
       inc(adata,decodeifidata(pifidataty(adata),int641));
       pinteger(pointer(dest)+offset)^:= int641;
      end;
      ftlargeint: begin
       inc(adata,decodeifidata(pifidataty(adata),int641));
       plargeint(pointer(dest)+offset)^:= int641;
      end;
      ftfloat: begin
       inc(adata,decodeifidata(pifidataty(adata),double1));
       pdouble(pointer(dest)+offset)^:= double1;
      end;
      ftbcd: begin
       inc(adata,decodeifidata(pifidataty(adata),cur1));
       pcurrency(pointer(dest)+offset)^:= cur1;
      end;
      ftblob,ftgraphic: begin
       inc(adata,decodeifidata(pifidataty(adata),str1));
       pstring(pointer(dest)+offset)^:= str1;
      end;
      ftstring: begin
       inc(adata,decodeifidata(pifidataty(adata),mstr1));
       pmsestring(pointer(dest)+offset)^:= mstr1;
      end;
     end;
    end;
   end;
  end
  else begin
   inc(adata,skipifidata(pifidataty(adata)));
  end;
 end;
end;

function tifidataset.decoderecords(const adata: precdataty;
               out asize: integer): boolean;
var
 int1: integer;
 po1: pointer;
begin
 result:= true;
 fbrecordcount:= adata^.count;
 setlength(fbufs,fbrecordcount);
 po1:= @adata^.data;
 for int1:= 0 to high(fbufs) do begin
  fbufs[int1]:= intallocrecord;  
  decoderecord(po1,fbufs[int1]);
 end;
 asize:= po1 -  pointer(adata);
end;

function tifidataset.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tifidataset.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tifidataset.endfilteredit;
begin
 //dummy
end;

{ trxdataset }

procedure trxdataset.fielddefsdatareceived(const asequence: sequencety; 
                                    const adata: pfielddefsdatadataty);
var
 int1: integer;
begin
 if (ids_openpending in fistate) and 
              (asequence = ffielddefsequence) then begin
  if decodefielddefs(@adata^.data,fielddefs,int1) then begin
   exclude(fistate,ids_openpending);
   include(fistate,ids_fielddefsreceived);
//  active:= true;
  end
  else begin
   cancelconnection;
  end;
 end; 
end;

procedure trxdataset.dsdatareceived(const asequence: sequencety; 
                                    const adata: pfielddefsdatadataty);
var
 int1,int2: integer;
begin
 if (ids_openpending in fistate) and 
              (asequence = ffielddefsequence) then begin
  if decodefielddefs(@adata^.data,fielddefs,int1) then begin
   inherited inheritedinternalopen;
   if decoderecords(@adata^.data+int1,int2) then begin
    exclude(fistate,ids_openpending);
    include(fistate,ids_fielddefsreceived);
   end;
  end
  else begin
   cancelconnection;
  end;
 end; 
end;

procedure trxdataset.inheritedinternalopen;
var
 str1: ansistring;
 po1: pointer;
begin
 inititemheader(str1,ik_requestopends,0,0,po1);
 include(fistate,ids_openpending);
 if senddataandwait(str1,ffielddefsequence) and 
            (ids_fielddefsreceived in fistate) then begin
//  inherited;
 end
 else begin
  sysutils.abort;
  //error
 end;
end;

{ ttxdataset }

procedure ttxdataset.inheritedinternalopen;
begin
 inherited;
end;

procedure ttxdataset.requestfielddefsreceived(const asequence: sequencety);
var
 str1,str2: ansistring;
 po1: pchar;
begin
 str2:= encodefielddefs(fielddefs);
 inititemheader(str1,ik_fielddefsdata,asequence,length(str2),po1); 
 with pfielddefsdatadataty(po1)^ do begin
//  sequence:= asequence;
  move(str2[1],data,length(str2));
 end;
 senddata(str1);
end;

procedure ttxdataset.requestopendsreceived(const asequence: sequencety);
var
 str1,str2,str3: ansistring;
 po1: pchar;
begin
 str2:= encodefielddefs(fielddefs);
 str3:= encoderecords;
 inititemheader(str1,ik_dsdata,asequence,length(str2)+length(str3),po1); 
 with pfielddefsdatadataty(po1)^ do begin
//  sequence:= asequence;
  move(str2[1],data,length(str2));
  move(str3[1],(@data+length(str2))^,length(str3));
 end;
 senddata(str1);
end;

end.
