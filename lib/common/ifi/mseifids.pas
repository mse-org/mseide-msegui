unit mseifids;
{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,mseifi,mseclasses,mseguiglob,mseevent,msedb,msetypes,msebufdataset,
 msestrings;

//single record dataset

const
 defaultifidstimeout = 10000000; //10 second

type
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

 ifidsstatety = (ids_openpending,ids_fielddefsreceived);
 ifidsstatesty = set of ifidsstatety;
 
 tifidataset = class(tdataset,ievent,idscontroller)
  private
   fchannel: tcustomiochannel;
   fobjectlinker: tobjectlinker;
   fstrings: integerarty;
   fmsestrings: integerarty;
   fifiname: string;
   fcontroller: tdscontroller;
   fstate: ifidsstatesty;
   fdefaulttimeout: integer;
   fmsestringpositions: integerarty;
   fansistringpositions: integerarty;
   Ffieldinfos: fieldinfoarty;
   frecordsize: integer;
   fcalcrecordsize: integer;
   fnullmasksize: integer;
   fmodifiedfields: string; //same layout as nullmask
   
   fintbuffer: pintrecordty;
   frecno: integer;
   fbrecordcount: integer; //always 1 if open
   fcurrentbuf: pintrecordty;

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
   
  protected
   ffielddefsequence: sequencety;
   fbindings: integerarty;
   procedure processdata(const adata: pifirecty);
   procedure requestfielddefsreceived(const asequence: sequencety); virtual;
   procedure fielddefsdatareceived( const asequence: sequencety; 
                                 const adata: pfielddefsdatadataty); virtual;
   procedure fieldrecdatareceived(const adata: pfieldrecdataty); virtual;
   procedure waitforanswer(const asequence: sequencety; waitus: integer = 0);
                      //0 -> defaulttimeout
   
   function senddata(const adata: ansistring): sequencety;
                //returns sequence number
   function senddataandwait(const adata: ansistring; out asequence: sequencety;
                                  atimeoutus: integer = 0): boolean;
   procedure inititemheader(out arec: string; const akind: ifireckindty; 
                    const asequence: sequencety; const datasize: integer;
                    out datapo: pchar);
   procedure postrecord;
   
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
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
   property channel: tcustomiochannel read fchannel write setchannel;
   property ifiname: string read fifiname write fifiname;
   property timeoutus: integer read fdefaulttimeout write fdefaulttimeout 
                       default defaultifidstimeout;
 end;
 
 trxdataset = class(tifidataset)
  private
   procedure inheritedinternalopen; override;
  protected
   procedure fielddefsdatareceived(const asequence: sequencety; 
                                  const adata: pfielddefsdatadataty); override;
 end;
 
 ttxdataset = class(tifidataset)
  private
  protected
   procedure requestfielddefsreceived(const asequence: sequencety); override;
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

 ifidskinds = [ik_requestfielddefs,ik_fielddefsdata,ik_fieldrec];
 openflags = [ids_openpending,ids_fielddefsreceived];
 
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
 setlength(result,sizeof(fdefdataty)+fielddefs.count*sizeof(fdefitemty)+int2);
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
end;

function decodefielddefs(const adata: pfdefdataty;
                  const fielddefs: tfielddefs): boolean;
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
 fcontroller:= tdscontroller.create(self,idscontroller(self));
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
  fcurrentbuf:= fintbuffer;
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
  finalizestrings(fcurrentbuf^.header);
  move(header,fcurrentbuf^.header,frecordsize); //get new field values
  postrecord;
  fillchar(pointer(fmodifiedfields)^,fnullmasksize,0);
 end;
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
begin
 if arecordpo = fintbuffer then begin
  result:= 0;
 end
 else begin
  result:= 1;
 end;
end;

procedure tifidataset.InternalGotoBookmark(ABookmark: Pointer);
var
 int1: integer;
begin
 if abookmark <> nil then begin
  with pbufbookmarkty(abookmark)^.data do begin
   if (recno >= fbrecordcount) or (recno < 0) then begin
    databaseerror('Invalid bookmark recno: '+inttostr(recno)+'.'); 
   end;
   {
   int1:= findrecord(recordpo);
   if int1 < 0 then begin
    databaseerror('Invalid bookmarkdata.');
   end
   else begin
    int1:= recno;
   end;
   }
   internalsetrecno(int1);
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
 result:= fintbuffer <> nil;
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
 fstate:= fstate - openflags;
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

procedure tifidataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
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
 fintbuffer:= intallocrecord;
 fbrecordcount:= 1;
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
 notimplemented('delete');
// inherited internaldelete;
end;

procedure tifidataset.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tifidataset.openlocal;
begin
// inherited internalopen;
 inheritedinternalopen;
end;

procedure tifidataset.inheritedinternalclose;
begin
 cancelconnection;
 intfreerecord(fintbuffer);
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
     ik_fielddefsdata: begin
      fielddefsdatareceived(header.answersequence,pfielddefsdatadataty(po1));
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

procedure tifidataset.fielddefsdatareceived(const asequence: sequencety;
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

procedure tifidataset.postrecord;
 function encodefielddata(const ainfo: fieldinfoty): string;
 begin
  with ainfo do begin
   case fieldtype of
    ftinteger,ftlargeint: begin
     result:= encodeifidata(field.aslargeint,sizeof(fielddataheaderty));
    end;
    ftfloat: begin
     result:= encodeifidata(field.asfloat,sizeof(fielddataheaderty));
    end;
    ftbcd: begin
     result:= encodeifidata(field.ascurrency,sizeof(fielddataheaderty));
    end;
    ftblob,ftgraphic: begin
     result:= encodeifidata(field.asstring,sizeof(fielddataheaderty));
    end;
    ftstring: begin
     if field is tmsestringfield then begin
      result:= encodeifidata(tmsestringfield(field).asmsestring,
                                                   sizeof(fielddataheaderty));
     end
     else begin
      result:= encodeifidata(msestring(field.asstring),sizeof(fielddataheaderty));
     end;
    end;
    else begin
     result:='';
     exit;
    end;
   end;
   with pfielddataty(result)^ do begin
    header.index:= field.fieldno-1;
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
 for int1:= 0 to high(ffieldinfos) do begin
  if not getfieldisnull(pointer(fmodifiedfields),int1) then begin
   ar1[int2]:= encodefielddata(ffieldinfos[int1]);
   if ar1[int2] <> '' then begin
    inc(int2);
   end;
  end;
 end;
 int3:= 0;
 for int1:= 0 to int2 - 1 do begin
  int3:= int3 + length(ar1[int1]);
 end;
 inititemheader(str1,ik_fieldrec,0,int3+sizeof(fieldrecdataty),pchar(po1));
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
 field1: tfield;
 bo1: boolean;
begin
 if active then begin
  po1:= @adata^.data;
  for int1:= 0 to adata^.count - 1 do begin
   index1:= pfielddataty(po1)^.header.index;
   if (index1 >= 0) and (index1 <= high(fbindings)) and 
                                       (fbindings[index1] >= 0) then begin
    if state = dsbrowse then begin
     edit;
    end;
    field1:= fields[fbindings[index1]];
    inc(po1,sizeof(mseifi.fielddataty.header));
    case pifidataty(po1)^.header.kind of
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
 end;
end;

{ trxdataset }

procedure trxdataset.fielddefsdatareceived(const asequence: sequencety; 
                                    const adata: pfielddefsdatadataty);
begin
 if (ids_openpending in fstate) and 
              (asequence = ffielddefsequence) then begin
  if decodefielddefs(@adata^.data,fielddefs) then begin
   exclude(fstate,ids_openpending);
   include(fstate,ids_fielddefsreceived);
//  active:= true;
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
 inititemheader(str1,ik_requestfielddefs,0,0,po1);
 include(fstate,ids_openpending);
 if senddataandwait(str1,ffielddefsequence) and 
            (ids_fielddefsreceived in fstate) then begin
  inherited;
 end
 else begin
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


end.
