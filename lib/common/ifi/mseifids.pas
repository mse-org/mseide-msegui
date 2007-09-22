unit mseifids;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,mseifi,mseclasses,mseguiglob,mseevent,msedb,msetypes;

const
 defaultifidstimeout = 10000000; //10 second
type

//single record dataset

 ifidsstatety = (ids_openpending,ids_fielddefsreceived);
 ifidsstatesty = set of ifidsstatety;
 
 tifidataset = class(tdataset,ievent,idscontroller)
  private
   fchannel: tcustomiochannel;
   fobjectlinker: tobjectlinker;
   fstrings: integerarty;
   fmsestrings: integerarty;
   frecbuffer: pointer;
   fifiname: string;
   fcontroller: tdscontroller;
   fstate: ifidsstatesty;
   fdefaulttimeout: integer;
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
  protected
   ffielddefsequence: sequencety;
   procedure processdata(const adata: pifirecty);
   procedure requestfielddefsreceived(const asequence: sequencety); virtual;
   procedure fielddefsdatareceived( const asequence: sequencety; 
                                 const adata: pfielddefsdatadataty); virtual;
   procedure waitforanswer(const asequence: sequencety; waitus: integer = 0);
                      //0 -> defaulttimeout
   
   function senddata(const adata: ansistring): sequencety;
                //returns sequence number
   function senddataandwait(const adata: ansistring; out asequence: sequencety;
                                  atimeoutus: integer = 0): boolean;
   procedure inititemheader(out arec: string; const akind: ifireckindty; 
                    const asequence: sequencety; const datasize: integer;
                    out datapo: pchar);
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
   
   function AllocRecordBuffer: PChar; override;
   procedure FreeRecordBuffer(var Buffer: PChar); override;
   procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
   function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
//   function GetDataSource: TDataSource; override;
   function GetRecord(Buffer: PChar; GetMode: TGetMode;
                                DoCheck: Boolean): TGetResult; override;
   function GetRecordSize: Word; override;
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
  protected
   procedure requestfielddefsreceived(const asequence: sequencety); override;
  published
   property fielddefs;
 end;
  
implementation
uses
 sysutils;
 
const
 ifidskinds = [ik_requestfielddefs,ik_fielddefsdata];
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
 fdefaulttimeout:= defaultifidstimeout;
 fobjectlinker:= tobjectlinker.create(ievent(self),
                           {$ifdef FPC}@{$endif}objectevent);
 setunidirectional(true);
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tifidataset.destroy;
begin
 fcontroller.free;
 inherited;
 fobjectlinker.free;
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
begin
// inherited internalopen;
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

function tifidataset.AllocRecordBuffer: PChar;
begin
end;

procedure tifidataset.FreeRecordBuffer(var Buffer: PChar);
begin
end;

procedure tifidataset.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
end;

function tifidataset.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
end;
{
function tifidataset.GetDataSource: TDataSource;
begin
end;
}
function tifidataset.GetRecord(Buffer: PChar; GetMode: TGetMode;
               DoCheck: Boolean): TGetResult;
begin
end;

function tifidataset.GetRecordSize: Word;
begin
end;

procedure tifidataset.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
end;

procedure tifidataset.InternalFirst;
begin
end;

procedure tifidataset.InternalGotoBookmark(ABookmark: Pointer);
begin
end;
{
procedure tifidataset.InternalHandleException;
begin
end;
}
procedure tifidataset.InternalInitFieldDefs;
begin
end;

procedure tifidataset.InternalInitRecord(Buffer: PChar);
begin
end;

procedure tifidataset.InternalLast;
begin
end;

procedure tifidataset.InternalPost;
begin
end;

procedure tifidataset.InternalSetToRecord(Buffer: PChar);
begin
end;

function tifidataset.IsCursorOpen: Boolean;
begin
 result:= frecbuffer <> nil;
end;

procedure tifidataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
end;

procedure tifidataset.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
end;

procedure tifidataset.notimplemented(const atext: string);
begin
 raise exception.create(name+': '+atext+' not implemented.');
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

procedure tifidataset.calcrecordsize;
begin
// fstringfields:= nil;
// fmsestringfields:= nil;
 
end;

procedure tifidataset.waitforanswer(const asequence: sequencety; 
                                                 waitus: integer = 0);
begin
 if waitus = 0 then begin
  waitus:= fdefaulttimeout;
 end;
 fchannel.waitforanswer(asequence,fdefaulttimeout);
end;

{ trxdataset }

procedure trxdataset.inheritedinternalopen;
var
 str1: ansistring;
 po1: pointer;
begin
 inititemheader(str1,ik_requestfielddefs,0,0,po1);
 include(fstate,ids_openpending);
 if senddataandwait(str1,ffielddefsequence) and 
            (ids_fielddefsreceived in fstate) then begin
  if defaultfields then begin
   createfields;
  end;
  bindfields(true);
  calcrecordsize;
 end;
end;

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

{ ttxdataset }

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
