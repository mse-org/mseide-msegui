unit dbf_memo;

interface

{$I dbf_common.inc}

uses
  Classes,
  dbf_pgfile,
  dbf_common;

type

//====================================================================
  TMemoFile = class(TPagedFile)
  protected
    FDbfFile: pointer;
    FDbfVersion: TXBaseVersion;
    FMemoRecordSize: Integer;
    FOpened: Boolean;
    FBuffer: PChar;
  protected
    function  GetBlockLen: Integer; virtual; abstract;
    function  GetMemoSize: Integer; virtual; abstract;
    function  GetNextFreeBlock: Integer; virtual; abstract;
    procedure SetNextFreeBlock(BlockNo: Integer); virtual; abstract;
    procedure SetBlockLen(BlockLen: Integer); virtual; abstract;
  public
    constructor Create(ADbfFile: pointer);
    destructor Destroy; override;

    procedure Open;
    procedure Close;

    procedure ReadMemo(BlockNo: Integer; DestStream: TStream);
    procedure WriteMemo(var BlockNo: Integer; ReadSize: Integer; Src: TStream);

    property DbfVersion: TXBaseVersion read FDbfVersion write FDbfVersion;
    property MemoRecordSize: Integer read FMemoRecordSize write FMemoRecordSize;
  end;

  TFoxProMemoFile = class(TMemoFile)
  protected
    function  GetBlockLen: Integer; override;
    function  GetMemoSize: Integer; override;
    function  GetNextFreeBlock: Integer; override;
    procedure SetNextFreeBlock(BlockNo: Integer); override;
    procedure SetBlockLen(BlockLen: Integer); override;
  end;

  TDbaseMemoFile = class(TMemoFile)
  protected
    function  GetBlockLen: Integer; override;
    function  GetMemoSize: Integer; override;
    function  GetNextFreeBlock: Integer; override;
    procedure SetNextFreeBlock(BlockNo: Integer); override;
    procedure SetBlockLen(BlockLen: Integer); override;
  end;

  { TNullMemoFile, a kind /dev/null memofile ;-) }
  { - inv: FHeaderModified == false!! (otherwise will try to write FStream) }
  { - inv: FHeaderSize == 0 }
  { - inv: FNeedLocks == false }
  { - WriteTo must NOT be used }
  { - WriteChar must NOT be used }

  TNullMemoFile = class(TMemoFile)
  protected
    procedure SetHeaderOffset(NewValue: Integer); override;
    procedure SetRecordSize(NewValue: Integer); override;
    procedure SetHeaderSize(NewValue: Integer); override;

    function  LockSection(const Offset, Length: Cardinal; const Wait: Boolean): Boolean; override;
    function  UnlockSection(const Offset, Length: Cardinal): Boolean; override;

    function  GetBlockLen: Integer; override;
    function  GetMemoSize: Integer; override;
    function  GetNextFreeBlock: Integer; override;
    procedure SetNextFreeBlock(BlockNo: Integer); override;
    procedure SetBlockLen(BlockLen: Integer); override;

  public
    constructor Create(ADbfFile: pointer);

    procedure CloseFile; override;
    procedure OpenFile; override;

    function  ReadRecord(IntRecNum: Integer; Buffer: Pointer): Integer; override;
    procedure WriteRecord(IntRecNum: Integer; Buffer: Pointer); override;
  end;

  PInteger = ^Integer;
  TMemoFileClass = class of TMemoFile;

implementation

uses
  SysUtils, dbf_dbffile;

//====================================================================
//=== Memo and binary fields support
//====================================================================
type

  PDbtHdr = ^rDbtHdr;
  rDbtHdr = record
    NextBlock : dword;
    Dummy     : array [4..7] of Byte;
    DbfFile   : array [0..7] of Byte;   // 8..15
    bVer      : Byte;                   // 16
    Dummy2    : array [17..19] of Byte;
    BlockLen  : Word;                   // 20..21
    Dummy3    : array [22..511] of Byte;
  end;

  PFptHdr = ^rFptHdr;
  rFptHdr = record
    NextBlock : dword;
    Dummy     : array [4..5] of Byte;
    BlockLen  : Word;                   // 20..21
    Dummy3    : array [8..511] of Byte;
  end;

  PBlockHdr = ^rBlockHdr;
  rBlockHdr = record
    MemoType  : Cardinal;
    MemoSize  : Cardinal;
  end;


//==========================================================
//============ Dbtfile
//==========================================================
constructor TMemoFile.Create(ADbfFile: pointer);
begin
  // init vars
  FBuffer := nil;
  FOpened := false;

  // call inherited
  inherited Create;

  FDbfFile := ADbfFile;
  FTempMode := TDbfFile(ADbfFile).TempMode;
end;

destructor TMemoFile.Destroy;
begin
  // close file
  Close;

  // call ancestor
  inherited;
end;

procedure TMemoFile.Open;
begin
  if not FOpened then
  begin
    // memo pages count start from begining of file!
    PageOffsetByHeader := false;

    // open physical file
    OpenFile;

    // read header
    HeaderSize := 512;

    // determine version
    if FDbfVersion = xBaseIII then
      PDbtHdr(Header)^.bVer := 3;
    VirtualLocks := false;

    if FileCreated or (HeaderSize = 0) then
    begin
      if (FMemoRecordSize = 0) or (FMemoRecordSize > HeaderSize) then
        SetNextFreeBlock(1)
      else
        SetNextFreeBlock(HeaderSize div FMemoRecordSize);
      SetBlockLen(FMemoRecordSize);
      WriteHeader;
    end;

    RecordSize := GetBlockLen;
    // checking for right blocksize not needed for foxpro?
    // mod 128 <> 0 <-> and 0x7F <> 0
    if (RecordSize = 0) and ((FDbfVersion = xFoxPro) or ((RecordSize and $7F) <> 0)) then
    begin
      SetBlockLen(512);
      RecordSize := 512;
      WriteHeader;
    end;

    // get memory for temporary buffer
    GetMem(FBuffer, RecordSize+2);
    FBuffer[RecordSize] := #0;
    FBuffer[RecordSize+1] := #0;

    // now open
    FOpened := true;
  end;
end;

procedure TMemoFile.Close;
begin
  if FOpened then
  begin
    // close physical file
    CloseFile;

    // free mem
    if FBuffer <> nil then
      FreeMemAndNil(Pointer(FBuffer));

    // now closed
    FOpened := false;
  end;
end;

procedure TMemoFile.ReadMemo(BlockNo: Integer; DestStream: TStream);
var
  bytesLeft,numBytes,dataStart: Integer;
  done: Boolean;
  lastc: char;
  endMemo: PChar;
begin
  // clear dest
  DestStream.Position := 0;
  DestStream.Size := 0;
  // no block to read?
  if (BlockNo<=0) or (RecordSize=0) then
    exit;
  // read first block
  numBytes := ReadRecord(BlockNo, @FBuffer[0]);
  if numBytes = 0 then
  begin
    // EOF reached?
    exit;
  end else
  if numBytes < RecordSize then
    FillChar(FBuffer[numBytes], RecordSize-numBytes, #0);

  bytesLeft := GetMemoSize;
  // bytesLeft <> -1 -> memo size is known (FoxPro, dBase4)
  // bytesLeft =  -1 -> memo size unknown (dBase3)
  if bytesLeft <> -1 then
  begin
    dataStart := 8;
    DestStream.Size := bytesLeft;
    while bytesLeft > 0 do
    begin
      // get number of bytes to be read
      numBytes := bytesLeft;
      // too much for this block?
      if numBytes > RecordSize - dataStart then
        numBytes := RecordSize - dataStart;
      // read block to stream
      DestStream.Write(FBuffer[dataStart], numBytes);
      // numBytes done
      dec(bytesLeft, numBytes);
      // still need to read bytes?
      if bytesLeft > 0 then
      begin
        // read next block
        inc(BlockNo);
        dataStart := 0;
        ReadRecord(BlockNo, @FBuffer[0]);
      end;
    end;
  end else begin
    // dbase III memo
    done := false;
    repeat
      // scan for EOF
      endMemo := MemScan(FBuffer, $1A, RecordSize);
      // EOF found?
      if endMemo <> nil then
      begin
        // really EOF?
        if (endMemo-FBuffer < RecordSize - 1) and ((endMemo[1] = #$1A) or (endMemo[1] = #0)) then
        begin
          // yes, EOF found
          done := true;
          numBytes := endMemo - FBuffer;
        end else begin
          // no, fake
          numBytes := RecordSize;
        end;
      end else begin
        numBytes := RecordSize;
      end;
      // write to stream
      DestStream.Write(FBuffer[0], numBytes);
{
      for i := 0 to RecordSize-2 do
      begin
        if (FBuffer[i]=#$1A) and (FBuffer[i+1]=#$1A) then
        begin
          if i>0 then
            DestStream.Write(FBuffer[0], i);
          done := true;
          break;
        end;
      end;
}
      if not done then
      begin
{
        DestStream.Write(FBuffer[0], 512);
}
        lastc := FBuffer[RecordSize-1];
        inc(BlockNo);
        if ReadRecord(BlockNo, @FBuffer[0]) > 0 then
        begin
          // check if immediate terminator at begin of block
          done := (lastc = #$1A) and ((FBuffer[0] = #$1A) or (FBuffer[0] = #0));
          // if so, written one character too much
          if done then
            DestStream.Size := DestStream.Size - 1;
        end else begin
          // error while reading, stop
          done := true;
        end;
      end;
    until done;
  end;
end;

procedure TMemoFile.WriteMemo(var BlockNo: Integer; ReadSize: Integer; Src: TStream);
var
  bytesBefore: Integer;
  bytesAfter: Integer;
  totsize: Integer;
  readBytes: Integer;
  append: Boolean;
  tmpRecNo: Integer;
begin
  // if no data to write, then don't create new block
  if Src.Size = 0 then
  begin
    BlockNo := 0;
  end else begin
    if FDbfVersion >= xBaseIV then      // dBase4 or FoxPro type
    begin
      bytesBefore := SizeOf(rBlockHdr);
      bytesAfter := 0;
    end else begin                      // dBase3 type
      bytesBefore := 0;
      bytesAfter := 2;
    end;
//    if ((bytesBefore + Src.Size + bytesAfter + PDbtHdr(Header).BlockLen-1) div PDbtHdr(Header).BlockLen)
//        <= ((ReadSize + PDbtHdr(Header).BlockLen-1) div PDbtHdr(Header).BlockLen) then
    if ((bytesBefore + Src.Size + bytesAfter + RecordSize-1) div RecordSize)
        <= ((ReadSize + RecordSize-1) div RecordSize) then
    begin
      append := false;
    end else begin
      append := true;
      // modifying header -> lock memo header
      LockPage(0, true);
      BlockNo := GetNextFreeBlock;
      if BlockNo = 0 then
      begin
        SetNextFreeBlock(1);
        BlockNo := 1;
      end;
    end;
    tmpRecNo := BlockNo;
    Src.Position := 0;
    FillChar(FBuffer[0], RecordSize, ' ');
    if bytesBefore=8 then
    begin
      totsize := Src.Size + bytesBefore + bytesAfter;
      if FDbfVersion <> xFoxPro then
      begin
        PBlockHdr(FBuffer)^.MemoType := SwapIntLE($0008FFFF);
        PBlockHdr(FBuffer)^.MemoSize := SwapIntLE(totsize);
      end else begin
        PBlockHdr(FBuffer)^.MemoType := SwapIntLE($01000000);
        PBlockHdr(FBuffer)^.MemoSize := SwapIntBE(Src.Size);
      end;
    end;
    repeat
      // read bytes, don't overwrite header
      readBytes := Src.Read(FBuffer[bytesBefore], RecordSize{PDbtHdr(Header).BlockLen}-bytesBefore);
      // end of input data reached ? check if need to write block terminators
      while (readBytes < RecordSize - bytesBefore) and (bytesAfter > 0) do
      begin
        FBuffer[readBytes] := #$1A;
        Inc(readBytes);
        Dec(bytesAfter);
      end;
      // have we read anything that is to be written?
      if readBytes > 0 then
      begin
        // clear any unused space
        FillChar(FBuffer[bytesBefore+readBytes], RecordSize-readBytes-bytesBefore, ' ');
        // write to disk
        WriteRecord(tmpRecNo, @FBuffer[0]);
        Inc(tmpRecNo);
      end else break;
      // first block read, second block can start at beginning
      bytesBefore := 0;
    until false;

    if append then
    begin
      SetNextFreeBlock(tmpRecNo);
      WriteHeader;
      UnlockPage(0);
    end;
  end;
end;

// ------------------------------------------------------------------
// dBase specific helper routines
// ------------------------------------------------------------------

function  TDbaseMemoFile.GetBlockLen: Integer;
begin
  // Can you tell me why the header of dbase3 memo contains 1024 and is 512 ?
  // answer: it is not a valid field in memo db3 header
  if FDbfVersion = xBaseIII then
    Result := 512
  else
    Result := SwapWordLE(PDbtHdr(Header)^.BlockLen);
end;

function  TDbaseMemoFile.GetMemoSize: Integer;
begin
  // dBase4 memofiles contain small 'header'
  if PInteger(@FBuffer[0])^ = Integer(SwapIntLE($0008FFFF)) then
    Result := SwapIntLE(PBlockHdr(FBuffer)^.MemoSize)-8
  else
    Result := -1;
end;

function  TDbaseMemoFile.GetNextFreeBlock: Integer;
begin
  Result := SwapIntLE(PDbtHdr(Header)^.NextBlock);
end;

procedure TDbaseMemoFile.SetNextFreeBlock(BlockNo: Integer);
begin
  PDbtHdr(Header)^.NextBlock := SwapIntLE(BlockNo);
end;

procedure TDbaseMemoFile.SetBlockLen(BlockLen: Integer);
begin
  PDbtHdr(Header)^.BlockLen := SwapWordLE(BlockLen);
end;

// ------------------------------------------------------------------
// FoxPro specific helper routines
// ------------------------------------------------------------------

function  TFoxProMemoFile.GetBlockLen: Integer;
begin
  Result := SwapWordBE(PFptHdr(Header)^.BlockLen);
end;

function  TFoxProMemoFile.GetMemoSize: Integer;
begin
  Result := SwapIntBE(PBlockHdr(FBuffer)^.MemoSize);
end;

function  TFoxProMemoFile.GetNextFreeBlock: Integer;
begin
  Result := SwapIntBE(PFptHdr(Header)^.NextBlock);
end;

procedure TFoxProMemoFile.SetNextFreeBlock(BlockNo: Integer);
begin
  PFptHdr(Header)^.NextBlock := SwapIntBE(dword(BlockNo));
end;

procedure TFoxProMemoFile.SetBlockLen(BlockLen: Integer);
begin
  PFptHdr(Header)^.BlockLen := SwapWordBE(dword(BlockLen));
end;

// ------------------------------------------------------------------
// NULL file (no file) specific helper routines
// ------------------------------------------------------------------

constructor TNullMemoFile.Create(ADbfFile: pointer);
begin
  inherited;
end;

procedure TNullMemoFile.OpenFile;
begin
end;

procedure TNullMemoFile.CloseFile;
begin
end;

procedure TNullMemoFile.SetHeaderOffset(NewValue: Integer);
begin
  inherited SetHeaderOffset(0);
end;

procedure TNullMemoFile.SetRecordSize(NewValue: Integer);
begin
  inherited SetRecordSize(0);
end;

procedure TNullMemoFile.SetHeaderSize(NewValue: Integer);
begin
  inherited SetHeaderSize(0);
end;

function  TNullMemoFile.LockSection(const Offset, Length: Cardinal; const Wait: Boolean): Boolean;
begin
  Result := true;
end;

function  TNullMemoFile.UnlockSection(const Offset, Length: Cardinal): Boolean;
begin
  Result := true;
end;

function  TNullMemoFile.GetBlockLen: Integer;
begin
  Result := 0;
end;

function  TNullMemoFile.GetMemoSize: Integer;
begin
  Result := 0;
end;

function  TNullMemoFile.GetNextFreeBlock: Integer;
begin
  Result := 0;
end;

procedure TNullMemoFile.SetNextFreeBlock(BlockNo: Integer);
begin
end;

procedure TNullMemoFile.SetBlockLen(BlockLen: Integer);
begin
end;

function  TNullMemoFile.ReadRecord(IntRecNum: Integer; Buffer: Pointer): Integer;
begin
  Result := 0;
end;

procedure TNullMemoFile.WriteRecord(IntRecNum: Integer; Buffer: Pointer);
begin
end;

end.
