unit dbf_fields;

// Modified 2013 by Martin Schreiber

interface

{$I dbf_common.inc}

uses
  classes,mclasses,
  SysUtils,
  mdb,
  dbf_common,
  dbf_str;

type
  PDbfFieldDef = ^TDbfFieldDef;

  TDbfFieldDef = class(TCollectionItem)
  private
    FFieldName: string;
    FFieldType: TFieldType;
    FNativeFieldType: TDbfFieldType;
    FDefaultBuf: PChar;
    FMinBuf: PChar;
    FMaxBuf: PChar;
    FSize: Integer;
    FPrecision: Integer;
    FHasDefault: Boolean;
    FHasMin: Boolean;
    FHasMax: Boolean;
    FAllocSize: Integer;
    FCopyFrom: Integer;
    FOffset: Integer;
    FAutoInc: Cardinal;
    FRequired: Boolean;
    FIsLockField: Boolean;
    FNullPosition: integer;

    function  GetDbfVersion: TXBaseVersion;
    procedure SetNativeFieldType(lFieldType: TDbfFieldType);
    procedure SetFieldType(lFieldType: TFieldType);
    procedure SetSize(lSize: Integer);
    procedure SetPrecision(lPrecision: Integer);
    procedure VCLToNative;
    procedure NativeToVCL;
    procedure FreeBuffers;
  protected
    function  GetDisplayName: string; override;
    procedure AssignTo(Dest: TPersistent); override;

    property DbfVersion: TXBaseVersion read GetDbfVersion;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure AssignDb(DbSource: TFieldDef);

    procedure CheckSizePrecision;
    procedure SetDefaultSize;
    procedure AllocBuffers;
    function  IsBlob: Boolean;

    property DefaultBuf: PChar read FDefaultBuf;
    property MinBuf: PChar read FMinBuf;
    property MaxBuf: PChar read FMaxBuf;
    property HasDefault: Boolean read FHasDefault write FHasDefault;
    property HasMin: Boolean read FHasMin write FHasMin;
    property HasMax: Boolean read FHasMax write FHasMax;
    property Offset: Integer read FOffset write FOffset;
    property AutoInc: Cardinal read FAutoInc write FAutoInc;
    property IsLockField: Boolean read FIsLockField write FIsLockField;
    property CopyFrom: Integer read FCopyFrom write FCopyFrom;
  published
    property FieldName: string     read FFieldName write FFieldName;
    property FieldType: TFieldType read FFieldType write SetFieldType;
    property NativeFieldType: TDbfFieldType read FNativeFieldType write SetNativeFieldType;
    property NullPosition: integer read FNullPosition write FNullPosition;
    property Size: Integer         read FSize      write SetSize;
    property Precision: Integer    read FPrecision write SetPrecision;
    property Required: Boolean     read FRequired  write FRequired;
  end;

  TDbfFieldDefs = class(TCollection)
  private
    FOwner: TPersistent;
    FDbfVersion: TXBaseVersion;

    function GetItem(Idx: Integer): TDbfFieldDef;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(Owner: TPersistent);

{$ifdef SUPPORT_DEFAULT_PARAMS}
    procedure Add(const Name: string; DataType: TFieldType; Size: Integer = 0; Required: Boolean = False);
{$else}
    procedure Add(const Name: string; DataType: TFieldType; Size: Integer; Required: Boolean);
{$endif}
    function AddFieldDef: TDbfFieldDef;

    property Items[Idx: Integer]: TDbfFieldDef read GetItem;
    property DbfVersion: TXBaseVersion read FDbfVersion write FDbfVersion;
  end;

implementation

uses
  dbf_dbffile;      // for dbf header structures

{$I dbf_struct.inc}

// I keep changing that fields...
// Last time has been asked by Venelin Georgiev
// Is he going to be the last ?
const
(*
The theory until now was :
    ftSmallint  16 bits = -32768 to 32767
                          123456 = 6 digit max theorically
                          DIGITS_SMALLINT = 6;
    ftInteger  32 bits = -2147483648 to 2147483647
                         12345678901 = 11 digits max
                         DIGITS_INTEGER = 11;
    ftLargeInt 64 bits = -9223372036854775808 to 9223372036854775807
                         12345678901234567890 = 20 digits max
                         DIGITS_LARGEINT = 20;

But in fact if I accept 6 digits into a ftSmallInt then tDbf will not
being able to handles fields with 999999 (6 digits).

So I now oversize the field type in order to accept anithing coming from the
database.
    ftSmallint  16 bits = -32768 to 32767
                           -999  to  9999
                           4 digits max theorically
                          DIGITS_SMALLINT = 4;
    ftInteger  32 bits = -2147483648 to 2147483647
                           -99999999 to  999999999                                        12345678901 = 11 digits max
                         DIGITS_INTEGER = 9;
    ftLargeInt 64 bits = -9223372036854775808 to 9223372036854775807
                           -99999999999999999 to  999999999999999999
                         DIGITS_LARGEINT = 18;
 *)
  DIGITS_SMALLINT = 4;
  DIGITS_INTEGER = 9;
  DIGITS_LARGEINT = 18;

//====================================================================
// DbfFieldDefs
//====================================================================
function TDbfFieldDefs.GetItem(Idx: Integer): TDbfFieldDef;
begin
  Result := TDbfFieldDef(inherited GetItem(Idx));
end;

constructor TDbfFieldDefs.Create(Owner: TPersistent);
begin
  inherited Create(TDbfFieldDef);
  FOwner := Owner;
end;

function TDbfFieldDefs.AddFieldDef: TDbfFieldDef;
begin
  Result := TDbfFieldDef(inherited Add);
end;

function TDbfFieldDefs.GetOwner: TPersistent; {override;}
begin
  Result := FOwner;
end;

procedure TDbfFieldDefs.Add(const Name: string; DataType: TFieldType; Size: Integer; Required: Boolean);
var
  FieldDef: TDbfFieldDef;
begin
  FieldDef := AddFieldDef;
  FieldDef.FieldName := Name;
  FieldDef.FieldType := DataType;
  if Size <> 0 then
    FieldDef.Size := Size;
  FieldDef.Required := Required;
end;

//====================================================================
// DbfFieldDef
//====================================================================
constructor TDbfFieldDef.Create(ACollection: TCollection); {virtual}
begin
  inherited;

  FDefaultBuf := nil;
  FMinBuf := nil;
  FMaxBuf := nil;
  FAllocSize := 0;
  FCopyFrom := -1;
  FPrecision := 0;
  FHasDefault := false;
  FHasMin := false;
  FHasMax := false;
  FNullPosition := -1;
end;

destructor TDbfFieldDef.Destroy; {override}
begin
  FreeBuffers;
  inherited;
end;

procedure TDbfFieldDef.Assign(Source: TPersistent);
var
  DbfSource: TDbfFieldDef;
begin
  if Source is TDbfFieldDef then
  begin
    // copy from another TDbfFieldDef
    DbfSource := TDbfFieldDef(Source);
    FFieldName := DbfSource.FieldName;
    FFieldType := DbfSource.FieldType;
    FNativeFieldType := DbfSource.NativeFieldType;
    FSize := DbfSource.Size;
    FPrecision := DbfSource.Precision;
    FRequired := DbfSource.Required;
    FCopyFrom := DbfSource.Index;
    FIsLockField := DbfSource.IsLockField;
    FNullPosition := DbfSource.NullPosition;
    // copy default,min,max
    AllocBuffers;
    if DbfSource.DefaultBuf <> nil then
      Move(DbfSource.DefaultBuf^, FDefaultBuf^, FAllocSize*3);
    FHasDefault := DbfSource.HasDefault;
    FHasMin := DbfSource.HasMin;
    FHasMax := DbfSource.HasMax;
    // do we need offsets?
    FOffset := DbfSource.Offset;
    FAutoInc := DbfSource.AutoInc;
{$ifdef SUPPORT_FIELDDEF_TPERSISTENT}
  end else if Source is TFieldDef then begin
    AssignDb(TFieldDef(Source));
{$endif}
  end else
    inherited Assign(Source);
end;

procedure TDbfFieldDef.AssignDb(DbSource: TFieldDef);
begin
  // copy from Db.TFieldDef
  FFieldName := DbSource.Name;
  FFieldType := DbSource.DataType;
  FSize := DbSource.Size;
  FPrecision := DbSource.Precision;
  FRequired := DbSource.Required;
{$ifdef SUPPORT_FIELDDEF_INDEX}
  FCopyFrom := DbSource.Index;
{$endif}
  FIsLockField := false;
  // convert VCL fieldtypes to native DBF fieldtypes
  VCLToNative;
  // for integer / float fields try fill in size/precision
  if FSize = 0 then
    SetDefaultSize
  else
    CheckSizePrecision;
  // VCL does not have default value support
  AllocBuffers;
  FHasDefault := false;
  FHasMin := false;
  FHasMax := false;
  FOffset := 0;
  FAutoInc := 0;
end;

procedure TDbfFieldDef.AssignTo(Dest: TPersistent);
{$ifdef SUPPORT_FIELDDEF_TPERSISTENT}
 {$ifdef SUPPORT_FIELDDEF_ATTRIBUTES}
var
  DbDest: TFieldDef;
 {$endif}
{$endif}
begin
{$ifdef SUPPORT_FIELDDEF_TPERSISTENT}
  // copy to VCL fielddef?
  if Dest is TFieldDef then
  begin
    // VCL TFieldDef does not know how to handle TDbfFieldDef!
    // what a shame :-)
{$ifdef SUPPORT_FIELDDEF_ATTRIBUTES}
    DbDest := TFieldDef(Dest);
    DbDest.Attributes := [];
    DbDest.ChildDefs.Clear;
    DbDest.DataType := FFieldType;
    DbDest.Required := FRequired;
    DbDest.Size := FSize;
    DbDest.Name := FFieldName;
{$endif}
  end else
{$endif}
    inherited AssignTo(Dest);
end;

function TDbfFieldDef.GetDbfVersion: TXBaseVersion;
begin
  Result := TDbfFieldDefs(Collection).DbfVersion;
end;

procedure TDbfFieldDef.SetFieldType(lFieldType: tFieldType);
begin
  FFieldType := lFieldType;
  VCLToNative;
  SetDefaultSize;
end;

procedure TDbfFieldDef.SetNativeFieldType(lFieldType: tDbfFieldType);
begin
  // get uppercase field type
  if (lFieldType >= 'a') and (lFieldType <= 'z') then
    lFieldType := Chr(Ord(lFieldType)-32);
  FNativeFieldType := lFieldType;
  NativeToVCL;
  CheckSizePrecision;
end;

procedure TDbfFieldDef.SetSize(lSize: Integer);
begin
  FSize := lSize;
  CheckSizePrecision;
end;

procedure TDbfFieldDef.SetPrecision(lPrecision: Integer);
begin
  FPrecision := lPrecision;
  CheckSizePrecision;
end;

procedure TDbfFieldDef.NativeToVCL;
begin
  case FNativeFieldType of
// OH 2000-11-15 dBase7 support.
// Add the new fieldtypes
    '+' : 
      if DbfVersion = xBaseVII then
        FFieldType := ftAutoInc;
    'I' : FFieldType := ftInteger;
    'O' : FFieldType := ftFloat;
    '@', 'T':
          FFieldType := ftDateTime;
    'C',
    #$91  {Russian 'C'}
        : FFieldType := ftString;
    'L' : FFieldType := ftBoolean;
    'F', 'N':
      begin
        if (FPrecision = 0) then
        begin
          if FSize <= DIGITS_SMALLINT then
            FFieldType := ftSmallInt
          else
          if FSize <= DIGITS_INTEGER then
            FFieldType := ftInteger
          else
{$ifdef SUPPORT_INT64}
            FFieldType := ftLargeInt;
{$else}
            FFieldType := ftFloat;
{$endif}
        end else begin
          FFieldType := ftFloat;
        end;
      end;
    'D' : FFieldType := ftDate;
    'M' : FFieldType := ftMemo;
    'B' : 
      if DbfVersion = xFoxPro then
        FFieldType := ftFloat
      else
        FFieldType := ftBlob;
    'G' : FFieldType := ftDBaseOle;
    'Y' :
      if DbfGlobals.CurrencyAsBCD then
        FFieldType := ftBCD
      else
        FFieldType := ftCurrency;
    '0' : FFieldType := ftBytes;	{ Visual FoxPro ``_NullFlags'' }
  else
    FNativeFieldType := #0;
    FFieldType := ftUnknown;
  end; //case
end;

procedure TDbfFieldDef.VCLToNative;
begin
  FNativeFieldType := #0;
  case FFieldType of
    ftAutoInc  : FNativeFieldType  := '+';
    ftDateTime :
      if DbfVersion = xBaseVII then
        FNativeFieldType := '@'
      else
      if DbfVersion = xFoxPro then
        FNativeFieldType := 'T'
      else
        FNativeFieldType := 'D';
{$ifdef SUPPORT_FIELDTYPES_V4}
    ftFixedChar,
    ftWideString,
{$endif}
    ftString   : FNativeFieldType  := 'C';
    ftBoolean  : FNativeFieldType  := 'L';
    ftFloat, ftSmallInt, ftWord
{$ifdef SUPPORT_INT64}
      , ftLargeInt
{$endif}
               : FNativeFieldType := 'N';
    ftDate     : FNativeFieldType := 'D';
    ftMemo     : FNativeFieldType := 'M';
    ftBlob     : FNativeFieldType := 'B';
    ftDBaseOle : FNativeFieldType := 'G';
    ftInteger  :
      if DbfVersion = xBaseVII then
        FNativeFieldType := 'I'
      else
        FNativeFieldType := 'N';
    ftBCD, ftCurrency: 
      if DbfVersion = xFoxPro then
        FNativeFieldType := 'Y';
  end;
  if FNativeFieldType = #0 then
    raise EDbfError.CreateFmt(STRING_INVALID_VCL_FIELD_TYPE, [GetDisplayName, Ord(FFieldType)]);
end;

procedure TDbfFieldDef.SetDefaultSize;
begin
  // choose default values for variable size fields
  case FFieldType of
    ftFloat:
      begin
        FSize := 18;
        FPrecision := 8;
      end;
    ftCurrency, ftBCD:
      begin
        FSize := 8;
        FPrecision := 4;
      end;
    ftSmallInt, ftWord:
      begin
        FSize := DIGITS_SMALLINT;
        FPrecision := 0;
      end;
    ftInteger, ftAutoInc:
      begin
        if DbfVersion = xBaseVII then
          FSize := 4
        else
          FSize := DIGITS_INTEGER;
        FPrecision := 0;
      end;
{$ifdef SUPPORT_INT64}
    ftLargeInt:
      begin
        FSize := DIGITS_LARGEINT;
        FPrecision := 0;
      end;
{$endif}
    ftString {$ifdef SUPPORT_FIELDTYPES_V4}, ftFixedChar, ftWideString{$endif}:
      begin
        FSize := 30;
        FPrecision := 0;
      end;
  end; // case fieldtype

  // set sizes for fields that are restricted to single size/precision
  CheckSizePrecision;
end;

procedure TDbfFieldDef.CheckSizePrecision;
begin
  case FNativeFieldType of
    'C':
      begin
        if FSize < 0 then 
          FSize := 0;
        if DbfVersion = xFoxPro then
        begin
          if FSize >= $FFFF then 
            FSize := $FFFF;
        end else begin
          if FSize >= $FF then 
            FSize := $FF;
        end;
        FPrecision := 0;
      end;
    'L':
      begin
        FSize := 1;
        FPrecision := 0;
      end;
    'N','F':
      begin
        // floating point
        if FSize < 1   then FSize := 1;
        if FSize >= 20 then FSize := 20;
        if FPrecision > FSize-2 then FPrecision := FSize-2;
        if FPrecision < 0       then FPrecision := 0;
      end;
    'D':
      begin
        FSize := 8;
        FPrecision := 0;
      end;
    'B':
      begin
        if DbfVersion <> xFoxPro then
        begin
          FSize := 10;
          FPrecision := 0;
        end;
      end;
    'M','G':
      begin
        if DbfVersion = xFoxPro then
        begin
          if (FSize <> 4) and (FSize <> 10) then
            FSize := 4;
        end else
          FSize := 10;
        FPrecision := 0;
      end;
    '+','I':
      begin
        FSize := 4;
        FPrecision := 0;
      end;
    '@', 'O':
      begin
        FSize := 8;
        FPrecision := 0;
      end;
    'T':
      begin
        if DbfVersion = xFoxPro then
          FSize := 8
        else
          FSize := 14;
        FPrecision := 0;
      end;
    'Y':
      begin
        FSize := 8;
        FPrecision := 4;
      end;
  else
    // Nothing
  end; // case
end;

function TDbfFieldDef.GetDisplayName: string; {override;}
begin
  Result := FieldName;
end;

function TDbfFieldDef.IsBlob: Boolean; {override;}
begin
  Result := FNativeFieldType in ['M','G','B'];
end;

procedure TDbfFieldDef.FreeBuffers;
begin
  if FDefaultBuf <> nil then
  begin
    // one buffer for all
    FreeMemAndNil(Pointer(FDefaultBuf));
    FMinBuf := nil;
    FMaxBuf := nil;
  end;
  FAllocSize := 0;
end;

procedure TDbfFieldDef.AllocBuffers;
begin
  // size changed?
  if FAllocSize <> FSize then
  begin
    // free old buffers
    FreeBuffers;
    // alloc new
    GetMem(FDefaultBuf, FSize*3);
    FMinBuf := FDefaultBuf + FSize;
    FMaxBuf := FMinBuf + FSize;
    // store allocated size
    FAllocSize := FSize;
  end;
end;

end.

