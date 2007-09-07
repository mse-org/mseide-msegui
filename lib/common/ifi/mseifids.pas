unit mseifids;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,mseifi,mseclasses,mseguiglob,mseevent;
 
type

 tifidataset = class(tdataset,ievent)
  private
   fchannel: tcustomiochannel;
   fobjectlinker: tobjectlinker;
   procedure setchannel(const avalue: tcustomiochannel);
  protected
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
   function GetDataSource: TDataSource; override;
   function GetRecord(Buffer: PChar; GetMode: TGetMode;
                                DoCheck: Boolean): TGetResult; override;
   function GetRecordSize: Word; override;
   procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;
   procedure InternalClose; override;
   procedure InternalDelete; override;
   procedure InternalFirst; override;
   procedure InternalGotoBookmark(ABookmark: Pointer); override;
   procedure InternalHandleException; override;
   procedure InternalInitFieldDefs; override;
   procedure InternalInitRecord(Buffer: PChar); override;
   procedure InternalLast; override;
   procedure InternalOpen; override;
   procedure InternalPost; override;
   procedure InternalSetToRecord(Buffer: PChar); override;
   function IsCursorOpen: Boolean; override;
   procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
   procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property channel: tcustomiochannel read fchannel write setchannel;
 end;
 
 trxdataset = class(tifidataset)
 end;
 ttxdataset = class(tifidataset)
 end;
  
implementation

{ tifidataset }

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

constructor tifidataset.create(aowner: tcomponent);
begin
 fobjectlinker:= tobjectlinker.create(ievent(self),
                           {$ifdef FPC}@{$endif}objectevent);
 inherited;
end;

destructor tifidataset.destroy;
begin
 inherited;
 fobjectlinker.free;
end;

procedure tifidataset.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 //dummy
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

function tifidataset.GetDataSource: TDataSource;
begin
end;

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

procedure tifidataset.InternalClose;
begin
end;

procedure tifidataset.InternalDelete;
begin
end;

procedure tifidataset.InternalFirst;
begin
end;

procedure tifidataset.InternalGotoBookmark(ABookmark: Pointer);
begin
end;

procedure tifidataset.InternalHandleException;
begin
end;

procedure tifidataset.InternalInitFieldDefs;
begin
end;

procedure tifidataset.InternalInitRecord(Buffer: PChar);
begin
end;

procedure tifidataset.InternalLast;
begin
end;

procedure tifidataset.InternalOpen;
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
end;

procedure tifidataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
end;

procedure tifidataset.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
end;

end.
