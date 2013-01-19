unit dbf_pgcfile;

// paged, cached file

interface

{$I dbf_common.inc}

{$ifdef USE_CACHE}

uses
  Classes,
  SysUtils,
  dbf_common,
  dbf_avl,
  dbf_pgfile;

type

  PPageInfo = ^TPageInfo;
  TPageInfo = record
    TimeStamp: Cardinal;
    Modified: Boolean;
    Data: Char;
  end;

  TCachedFile = class(TPagedFile)
  private
    FPageTree: TAvlTree;
    FUseTree: TAvlTree;
    FTimeStamp: Cardinal;
    FPageInfoSize: Integer;
    FCacheSize: Integer;
    FMaxPages: Cardinal;

    function  GetTimeStamp: Cardinal;
    procedure UpdateTimeStamp(RecNo: Integer; Data: PPageInfo);
    procedure PageDeleted(Sender: TAvlTree; Data: PData);
    procedure UpdateMaxPages;
    function  AddToCache(RecNo: Integer; Buffer: Pointer): PPageInfo;
  protected
    procedure SetRecordSize(NewValue: Integer); override;
    procedure SetCacheSize(NewSize: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure CloseFile; override;
    procedure Flush; override;

    function  ReadRecord(RecNo: Integer; Buffer: Pointer): Integer; override;
    procedure WriteRecord(RecNo: Integer; Buffer: Pointer); override;

    property CacheSize: Integer read FCacheSize write SetCacheSize;
  end;

{$endif}

implementation

{$ifdef USE_CACHE}

constructor TCachedFile.Create;
begin
  inherited;

  FPageTree := TAvlTree.Create;
  FPageTree.OnDelete := PageDeleted;
  FUseTree := TAvlTree.Create;
  FPageInfoSize := 0;
  FTimeStamp := 0;
  FCacheSize := 256 * 1024;
end;

destructor TCachedFile.Destroy;
begin
  Flush;

  FPageTree.Free;
  FUseTree.Free;
  FPageTree := nil;
  FUseTree := nil;

  inherited;
end;

procedure TCachedFile.Flush;
begin
  if FPageTree <> nil then
  begin
    FPageTree.Clear;
    FUseTree.Clear;
  end;
  FTimeStamp := 0;
end;

procedure TCachedFile.CloseFile;
begin
  // flush modified pages to disk
  Flush;

  // now we can safely close
  inherited;
end;

procedure TCachedFile.SetRecordSize(NewValue: Integer);
begin
  inherited;

  // first flush all pages, restart caching with new parameters
  Flush;

  // calculate size of extra data of pagetree
  FPageInfoSize := SizeOf(TPageInfo) - SizeOf(Char) + RecordSize;
  UpdateMaxPages;
end;

procedure TCachedFile.SetCacheSize(NewSize: Integer);
begin
  if FCacheSize <> NewSize then
  begin
    FCacheSize := NewSize;
    UpdateMaxPages;
  end;
end;

procedure TCachedFile.UpdateMaxPages;
begin
  if RecordSize = 0 then
    FMaxPages := 0
  else
    FMaxPages := FCacheSize div RecordSize;
end;

function TCachedFile.GetTimeStamp: Cardinal;
begin
  Result := FTimeStamp;
  Inc(FTimeStamp);
end;

procedure TCachedFile.PageDeleted(Sender: TAvlTree; Data: PData);
begin
  // data modified? write to disk
  if PPageInfo(Data^.ExtraData)^.Modified then
    inherited WriteRecord(Data^.ID, @PPageInfo(Data^.ExtraData)^.Data);

  // free cached page mem
  FreeMem(Data^.ExtraData);
end;

function TCachedFile.AddToCache(RecNo: Integer; Buffer: Pointer): PPageInfo;
var
  oldData: PData;
begin
  // make sure there is a free page in the cache
  while FPageTree.Count >= FMaxPages do
  begin
    // no free space, find oldest page
    oldData := FUseTree.Lowest;
    // remove from cache
    FPageTree.Delete(Integer(oldData^.ExtraData));
    FUseTree.Delete(oldData^.ID);
  end;
  // add to cache
  GetMem(Result, FPageInfoSize);
  Result^.TimeStamp := GetTimeStamp;
  Result^.Modified := false;
  Move(Buffer^, Result^.Data, RecordSize);
  FPageTree.Insert(RecNo, Result);
  FUseTree.Insert(Result^.TimeStamp, Pointer(RecNo));
end;

procedure TCachedFile.UpdateTimeStamp(RecNo: Integer; Data: PPageInfo);
begin
  // update time used
  FUseTree.Delete(Data^.TimeStamp);
  Data^.TimeStamp := GetTimeStamp;
  FUseTree.Insert(Data^.TimeStamp, Pointer(RecNo));
end;

function TCachedFile.ReadRecord(RecNo: Integer; Buffer: Pointer): Integer;
var
  Data: PPageInfo;
begin
  // only cache when we do not need locking
  if NeedLocks then
  begin Result := inherited ReadRecord(RecNo, Buffer) end else begin
    // do we have this page in cache?
    Data := PPageInfo(FPageTree.Find(RecNo));
    if Data <> nil then
    begin
      // copy from cache
      Move(Data^.Data, Buffer^, RecordSize);
      UpdateTimeStamp(RecNo, Data);
      Result := RecordSize;
    end else begin
      // not yet in cache
      Result := inherited ReadRecord(RecNo, Buffer);
      // add
      if Result > 0 then
        AddToCache(RecNo, Buffer);
    end;
  end;
end;

procedure TCachedFile.WriteRecord(RecNo: Integer; Buffer: Pointer);
var
  Data: PPageInfo;
begin
  // only cache when we do not need locking
  if NeedLocks then
  begin inherited end else begin
    // do we have this page in cache?
    Data := PPageInfo(FPageTree.Find(RecNo));
    if Data <> nil then
    begin
      // copy to cache
      Move(Buffer^, Data^.Data, RecordSize);
      UpdateTimeStamp(RecNo, Data);
    end else begin
      // add
      Data := AddToCache(RecNo, Buffer);
      // notify we've added a page
      UpdateCachedSize(CalcPageOffset(RecNo+PagesPerRecord));
    end;
    Data^.Modified := true;
  end;
end;

{$endif}  // USE_CACHE

end.
