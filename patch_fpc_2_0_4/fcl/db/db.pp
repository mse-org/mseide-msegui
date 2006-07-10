{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team


    DB header file with interface section.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit db;

{$mode objfpc}
{$h+}

interface

uses Classes,Sysutils,Variants;

const

  dsMaxBufferCount = MAXINT div 8;
  dsMaxStringSize = 8192;

  // Used in AsBoolean for string fields to determine
  // whether it's true or false.
  YesNoChars : Array[Boolean] of char = ('Y','N');

  SQLDelimiterCharacters = [';',',',' ','(',')',#13,#10,#9];

type

{LargeInt}
  LargeInt = Int64;

{ Auxiliary type }
  TStringFieldBuffer = Array[0..dsMaxStringSize] of Char;

{ Misc Dataset types }

  TDataSetState = (dsInactive, dsBrowse, dsEdit, dsInsert, dsSetKey,
    dsCalcFields, dsFilter, dsNewValue, dsOldValue, dsCurValue, dsBlockRead,
    dsInternalCalc, dsOpening);

  TDataEvent = (deFieldChange, deRecordChange, deDataSetChange,
    deDataSetScroll, deLayoutChange, deUpdateRecord, deUpdateState,
    deCheckBrowseMode, dePropertyChange, deFieldListChange, deFocusControl,
    deParentScroll,deConnectChange,deReconcileError,deDisabledStateChange);

  TUpdateStatus = (usUnmodified, usModified, usInserted, usDeleted);
  TUpdateStatusSet = SET OF TUpdateStatus;

  TUpdateMode = (upWhereAll, upWhereChanged, upWhereKeyOnly);
  TResolverResponse = (rrSkip, rrAbort, rrMerge, rrApply, rrIgnore);

  TProviderFlag = (pfInUpdate, pfInWhere, pfInKey, pfHidden);
  TProviderFlags = set of TProviderFlag;

{ Forward declarations }

  TFieldDef = class;
  TFieldDefs = class;
  TField = class;
  TFields = Class;
  TDataSet = class;
  TBufDataSet = class;
  TDataBase = Class;
  TDatasource = Class;
  TDatalink = Class;
  TDBTransaction = Class;

{ Exception classes }

  EDatabaseError = class(Exception);
  EUpdateError   = class(EDatabaseError)
  private
    FContext           : String;
    FErrorCode         : integer;
    FOriginalException : Exception;
    FPreviousError     : Integer;
  public
    constructor Create(NativeError, Context : String;
      ErrCode, PrevError : integer; E: Exception);
    Destructor Destroy;
    property Context : String read FContext;
    property ErrorCode : integer read FErrorcode;
    property OriginalExcaption : Exception read FOriginalException;
    property PreviousError : Integer read FPreviousError;
  end;
  

{ TFieldDef }

  TFieldClass = class of TField;

{
  TFieldType = (ftUnknown, ftString, ftSmallint, ftInteger, ftWord,
    ftBoolean, ftFloat, ftDate, ftTime, ftDateTime,
    ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic,
    ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor);
}

  TFieldType = (ftUnknown, ftString, ftSmallint, ftInteger, ftWord,
    ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate,  ftTime, ftDateTime,
    ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
    ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar,
    ftWideString, ftLargeint, ftADT, ftArray, ftReference,
    ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface,
    ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd);

{ TDateTimeRec }

  TDateTimeAlias = type TDateTime;
  TDateTimeRec = record
    case TFieldType of
      ftDate: (Date: Longint);
      ftTime: (Time: Longint);
      ftDateTime: (DateTime: TDateTimeAlias);
  end;

  TFieldAttribute = (faHiddenCol, faReadonly, faRequired, faLink, faUnNamed, faFixed);
  TFieldAttributes = set of TFieldAttribute;

  { TFieldDef }

  TFieldDef = class(TCollectionItem)
  Private
    FDataType : TFieldType;
    FFieldNo : Longint;
    FInternalCalcField : Boolean;
    FPrecision : Longint;
    FRequired : Boolean;
    FSize : Word;
    FName : String;
    FDisplayName : String;
    FAttributes : TFieldAttributes;
    Function GetFieldClass : TFieldClass;
    procedure SetAttributes(AValue: TFieldAttributes);
    procedure SetDataType(AValue: TFieldType);
    procedure SetPrecision(const AValue: Longint);
    procedure SetSize(const AValue: Word);
    procedure SetRequired(const AValue: Boolean);
  protected
    function GetDisplayName: string; override;
    procedure SetDisplayName(const AValue: string); override;
  public
    constructor Create(AOwner: TFieldDefs; const AName: string;
      ADataType: TFieldType; ASize: Word; ARequired: Boolean; AFieldNo: Longint);
    destructor Destroy; override;
    procedure Assign(APersistent: TPersistent); override;
    function CreateField(AOwner: TComponent): TField;
    property FieldClass: TFieldClass read GetFieldClass;
    property FieldNo: Longint read FFieldNo;
    property InternalCalcField: Boolean read FInternalCalcField write FInternalCalcField;
    property Required: Boolean read FRequired write SetRequired;
  Published
    property Attributes: TFieldAttributes read FAttributes write SetAttributes default [];
    property Name: string read FName write FName; // Must move to TNamedItem
    property DisplayName : string read FDisplayName write FDisplayName; // Must move to TNamedItem
    property DataType: TFieldType read FDataType write SetDataType;
    property Precision: Longint read FPrecision write SetPrecision;
    property Size: Word read FSize write SetSize;
  end;

{ TFieldDefs }

  TFieldDefs = class(TOwnedCollection)
  private
    FUpdated: Boolean;
    FHiddenFields : Boolean;
    function GetItem(Index: Longint): TFieldDef;
    function GetDataset: TDataset;
    procedure SetItem(Index: Longint; const AValue: TFieldDef);
  protected
    procedure SetItemName(AItem: TCollectionItem); override;
  public
    constructor Create(ADataSet: TDataSet);
//    destructor Destroy; override;
    procedure Add(const AName: string; ADataType: TFieldType; ASize: Word; ARequired: Boolean);
    procedure Add(const AName: string; ADataType: TFieldType; ASize: Word);
    procedure Add(const AName: string; ADataType: TFieldType);
    Function AddFieldDef : TFieldDef;
    procedure Assign(FieldDefs: TFieldDefs);
//    procedure Clear;
//    procedure Delete(Index: Longint);
    function Find(const AName: string): TFieldDef;
    function IndexOf(const AName: string): Longint;
    procedure Update;
    Property HiddenFields : Boolean Read FHiddenFields Write FHiddenFields;
    property Items[Index: Longint]: TFieldDef read GetItem write SetItem; default;
    property Dataset: TDataset read GetDataset;
    property Updated: Boolean read FUpdated write FUpdated;
  end;

{ TField }

  TFieldKind = (fkData, fkCalculated, fkLookup, fkInternalCalc);
  TFieldKinds = Set of TFieldKind;

  TFieldNotifyEvent = procedure(Sender: TField) of object;
  TFieldGetTextEvent = procedure(Sender: TField; var Text: string;
    DisplayText: Boolean) of object;
  TFieldSetTextEvent = procedure(Sender: TField; const Text: string) of object;
  TFieldRef = ^TField;
  TFieldChars = set of Char;

  PLookupListRec = ^TLookupListRec;
  TLookupListRec = record
    Key: Variant;
    Value: Variant;
  end;

  { TLookupList }

  TLookupList = class(TObject)
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AKey, AValue: Variant);
    procedure Clear;
    function ValueOfKey(const AKey: Variant): Variant;
  end;

  { TField }

  TField = class(TComponent)
  Private
    FAlignMent : TAlignment;
    FAttributeSet : String;
    FCalculated : Boolean;
    FConstraintErrorMessage : String;
    FCustomConstraint : String;
    FDataSet : TDataSet;
//    FDataSize : Word;
    FDataType : TFieldType;
    FDefaultExpression : String;
    FDisplayLabel : String;
    FDisplayWidth : Longint;
    FFieldKind : TFieldKind;
    FFieldName : String;
    FFieldNo : Longint;
    FFields : TFields;
    FHasConstraints : Boolean;
    FImportedConstraint : String;
    FIsIndexField : Boolean;
    FKeyFields : String;
    FLookupCache : Boolean;
    FLookupDataSet : TDataSet;
    FLookupKeyfields : String;
    FLookupresultField : String;
    FLookupList: TLookupList;
    FOffset : Word;
    FOnChange : TFieldNotifyEvent;
    FOnGetText: TFieldGetTextEvent;
    FOnSetText: TFieldSetTextEvent;
    FOnValidate: TFieldNotifyEvent;
    FOrigin : String;
    FReadOnly : Boolean;
    FRequired : Boolean;
    FSize : Word;
    FValidChars : TFieldChars;
    FValueBuffer : Pointer;
    FValidating : Boolean;
    FVisible : Boolean;
    FProviderFlags : TProviderFlags;
    Function GetIndex : longint;
    procedure SetAlignment(const AValue: TAlignMent);
    procedure SetIndex(AValue: Integer);
    Procedure SetDataset(AValue : TDataset);
    function GetDisplayText: String;
    function GetEditText: String;
    procedure SetEditText(const AValue: string);
    procedure SetDisplayLabel(const AValue: string);
    procedure SetDisplayWidth(const AValue: Longint);
    function GetDisplayWidth: integer;
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);
    function IsDisplayStored : Boolean;
    function GetLookupList: TLookupList;
    procedure CalcLookupValue;
  protected
    function AccessError(const TypeName: string): EDatabaseError;
    procedure CheckInactive;
    class procedure CheckTypeSize(AValue: Longint); virtual;
    procedure Change; virtual;
    procedure DataChanged;
    procedure FreeBuffers; virtual;
    function GetAsBoolean: Boolean; virtual;
    function GetAsCurrency: Currency; virtual;
    function GetAsLargeInt: LargeInt; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsFloat: Double; virtual;
    function GetAsLongint: Longint; virtual;
    function GetAsInteger: Longint; virtual;
    function GetAsVariant: variant; virtual;
    function GetOldValue: variant; virtual;
    function GetAsString: string; virtual;
    function GetCanModify: Boolean; virtual;
    function GetDataSize: Word; virtual;
    function GetDefaultWidth: Longint; virtual;
    function GetDisplayName : String;
    function GetCurValue: Variant; virtual;
    function GetNewValue: Variant; virtual;
    function GetIsNull: Boolean; virtual;
    function GetParentComponent: TComponent; override;
    procedure GetText(var AText: string; ADisplayText: Boolean); virtual;
    function HasParent: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PropertyChanged(LayoutAffected: Boolean);
    procedure ReadState(Reader: TReader); override;
    procedure SetAsBoolean(AValue: Boolean); virtual;
    procedure SetAsCurrency(AValue: Currency); virtual;
    procedure SetAsDateTime(AValue: TDateTime); virtual;
    procedure SetAsFloat(AValue: Double); virtual;
    procedure SetAsLongint(AValue: Longint); virtual;
    procedure SetAsInteger(AValue: Integer); virtual;
    procedure SetAsLargeint(AValue: Largeint); virtual;
    procedure SetAsVariant(AValue: variant); virtual;
    procedure SetAsString(const AValue: string); virtual;
    procedure SetDataType(AValue: TFieldType);
    procedure SetNewValue(const AValue: Variant);
    procedure SetSize(AValue: Word); virtual;
    procedure SetParentComponent(AParent: TComponent); override;
    procedure SetText(const AValue: string); virtual;
    procedure SetVarValue(const AValue: Variant); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignValue(const AValue: TVarRec);
    procedure Clear; virtual;
    procedure FocusControl;
    function GetData(Buffer: Pointer): Boolean;
    function GetData(Buffer: Pointer; NativeFormat : Boolean): Boolean;
    class function IsBlob: Boolean; virtual;
    function IsValidChar(InputChar: Char): Boolean; virtual;
    procedure RefreshLookupList;
    procedure SetData(Buffer: Pointer);
    procedure SetData(Buffer: Pointer; NativeFormat : Boolean);
    procedure SetFieldType(AValue: TFieldType); virtual;
    procedure Validate(Buffer: Pointer);
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsLongint: Longint read GetAsLongint write SetAsLongint;
    property AsLargeInt: LargeInt read GetAsLargeInt write SetAsLargeInt;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsVariant: variant read GetAsVariant write SetAsVariant;
    property AttributeSet: string read FAttributeSet write FAttributeSet;
    property Calculated: Boolean read FCalculated write FCalculated;
    property CanModify: Boolean read GetCanModify;
    property CurValue: Variant read GetCurValue;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property DataSize: Word read GetDataSize;
    property DataType: TFieldType read FDataType;
    property DisplayName: String Read GetDisplayName;
    property DisplayText: String read GetDisplayText;
    property FieldNo: Longint read FFieldNo;
    property IsIndexField: Boolean read FIsIndexField;
    property IsNull: Boolean read GetIsNull;
    property NewValue: Variant read GetNewValue write SetNewValue;
    property Offset: word read FOffset;
    property Size: Word read FSize write FSize;
    property Text: string read GetEditText write SetEditText;
    property ValidChars : TFieldChars Read FValidChars;
    property Value: variant read GetAsVariant write SetAsVariant;
    property OldValue: variant read GetOldValue;
    property LookupList: TLookupList read GetLookupList;
  published
    property AlignMent : TAlignMent Read FAlignMent write SetAlignment default taLeftJustify;
    property CustomConstraint: string read FCustomConstraint write FCustomConstraint;
    property ConstraintErrorMessage: string read FConstraintErrorMessage write FConstraintErrorMessage;
    property DefaultExpression: string read FDefaultExpression write FDefaultExpression;
    property DisplayLabel : string read GetDisplayName write SetDisplayLabel stored IsDisplayStored;
    property DisplayWidth: Longint read GetDisplayWidth write SetDisplayWidth;
    property FieldKind: TFieldKind read FFieldKind write FFieldKind;
    property FieldName: string read FFieldName write FFieldName;
    property HasConstraints: Boolean read FHasConstraints;
    property Index: Longint read GetIndex write SetIndex;
    property ImportedConstraint: string read FImportedConstraint write FImportedConstraint;
    property LookupDataSet: TDataSet read FLookupDataSet write FLookupDataSet;
    property LookupKeyFields: string read FLookupKeyFields write FLookupKeyFields;
    property LookupResultField: string read FLookupResultField write FLookupResultField;
    property KeyFields: string read FKeyFields write FKeyFields;
    property LookupCache: Boolean read FLookupCache write FLookupCache;
    property Origin: string read FOrigin write FOrigin;
    property ProviderFlags : TProviderFlags read FProviderFlags write FProviderFlags;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property Required: Boolean read FRequired write FRequired;
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnChange: TFieldNotifyEvent read FOnChange write FOnChange;
    property OnGetText: TFieldGetTextEvent read FOnGetText write FOnGetText;
    property OnSetText: TFieldSetTextEvent read FOnSetText write FOnSetText;
    property OnValidate: TFieldNotifyEvent read FOnValidate write FOnValidate;
  end;

{ TStringField }

  TStringField = class(TField)
  private
    FFixedChar     : boolean;
    FTransliterate : Boolean;
  protected
    class procedure CheckTypeSize(AValue: Longint); override;
    function GetAsBoolean: Boolean; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Word; override;
    function GetDefaultWidth: Longint; override;
    procedure GetText(var AText: string; ADisplayText: Boolean); override;
    function GetValue(var AValue: string): Boolean;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    property FixedChar : Boolean read FFixedChar write FFixedChar;
    property Transliterate: Boolean read FTransliterate write FTransliterate;
  published
    property Size default 20;
  end;

{ TNumericField }
  TNumericField = class(TField)
  Private
    FDisplayFormat : String;
    FEditFormat : String;
  protected
    procedure RangeError(AValue, Min, Max: Double);
    procedure SetDisplayFormat(const AValue: string);
    procedure SetEditFormat(const AValue: string);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property EditFormat: string read FEditFormat write SetEditFormat;
  end;

{ TLongintField }

  TLongintField = class(TNumericField)
  private
    FMinValue,
    FMaxValue,
    FMinRange,
    FMAxRange  : Longint;
    Procedure SetMinValue (AValue : longint);
    Procedure SetMaxValue (AValue : longint);
  protected
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Word; override;
    procedure GetText(var AText: string; ADisplayText: Boolean); override;
    function GetValue(var AValue: Longint): Boolean;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    Function CheckRange(AValue : longint) : Boolean;
    property Value: Longint read GetAsLongint write SetAsLongint;
  published
    property MaxValue: Longint read FMaxValue write SetMaxValue default 0;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
  end;
  TIntegerField = TLongintField;

{ TLargeintField }

  TLargeintField = class(TNumericField)
  private
    FMinValue,
    FMaxValue,
    FMinRange,
    FMAxRange  : Largeint;
    Procedure SetMinValue (AValue : Largeint);
    Procedure SetMaxValue (AValue : Largeint);
  protected
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsLargeint: Largeint; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Word; override;
    procedure GetText(var AText: string; ADisplayText: Boolean); override;
    function GetValue(var AValue: Largeint): Boolean;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsLargeint(AValue: Largeint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    Function CheckRange(AValue : largeint) : Boolean;
    property Value: Longint read GetAsLongint write SetAsLongint;
  published
    property MaxValue: Largeint read FMaxValue write SetMaxValue default 0;
    property MinValue: Largeint read FMinValue write SetMinValue default 0;
  end;

{ TSmallintField }

  TSmallintField = class(TLongintField)
  protected
    function GetDataSize: Word; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TWordField }

  TWordField = class(TLongintField)
  protected
    function GetDataSize: Word; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TAutoIncField }

  TAutoIncField = class(TLongintField)
  Protected
    Procedure SetAsLongInt(AValue : Longint); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TFloatField }

  TFloatField = class(TNumericField)
  private
    FMaxValue : Double;
    FMinValue : Double;
    FPrecision : Longint;
  protected
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsVariant: variant; override;
    function GetAsString: string; override;
    function GetDataSize: Word; override;
    procedure GetText(var theText: string; ADisplayText: Boolean); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    Function CheckRange(AValue : Double) : Boolean;
    property Value: Double read GetAsFloat write SetAsFloat;

  published
    property MaxValue: Double read FMaxValue write FMaxValue;
    property MinValue: Double read FMinValue write FMinValue;
    property Precision: Longint read FPrecision write FPrecision default 15;
  end;

{ TCurrencyField }

  TCurrencyField = class(TFloatField)
  public
    constructor Create(AOwner: TComponent); override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
  end;

{ TBooleanField }

  TBooleanField = class(TField)
  private
    FDisplayValues : String;
    // First byte indicates uppercase or not.
    FDisplays : Array[Boolean,Boolean] of string;
    Procedure SetDisplayValues(AValue : String);
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Word; override;
    function GetDefaultWidth: Longint; override;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Value: Boolean read GetAsBoolean write SetAsBoolean;
  published
    property DisplayValues: string read FDisplayValues write SetDisplayValues;
  end;

{ TDateTimeField }

  TDateTimeField = class(TField)
  private
    FDisplayFormat : String;
    procedure SetDisplayFormat(const AValue: string);
  protected
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Word; override;
    procedure GetText(var theText: string; ADisplayText: Boolean); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Value: TDateTime read GetAsDateTime write SetAsDateTime;
  published
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
  end;

{ TDateField }

  TDateField = class(TDateTimeField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TTimeField }

  TTimeField = class(TDateTimeField)
  protected
    procedure SetAsString(const AValue: string); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TBinaryField }

  TBinaryField = class(TField)
  protected
    class procedure CheckTypeSize(AValue: Longint); override;
    function GetAsString: string; override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetText(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Size default 16;
  end;

{ TBytesField }

  TBytesField = class(TBinaryField)
  protected
    function GetDataSize: Word; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TVarBytesField }

  TVarBytesField = class(TBytesField)
  protected
    function GetDataSize: Word; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TBCDField }

  TBCDField = class(TNumericField)
  private
    FMinValue,
    FMaxValue   : currency;
    FPrecision  : Longint;
    FCurrency   : boolean;
  protected
    class procedure CheckTypeSize(AValue: Longint); override;
    function GetAsCurrency: Currency; override;
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsString: string; override;
    function GetValue(var AValue: Currency): Boolean;
    function GetAsVariant: variant; override;
    function GetDataSize: Word; override;
    function GetDefaultWidth: Longint; override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsCurrency(AValue: Currency); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    Function CheckRange(AValue : Currency) : Boolean;
    property Value: Longint read GetAsLongint write SetAsLongint;
  published
    property Precision: Longint read FPrecision write FPrecision;
    property Currency: Boolean read FCurrency write FCurrency;
    property MaxValue: Currency read FMaxValue write FMaxValue;
    property MinValue: Currency read FMinValue write FMinValue;
    property Size default 4;
  end;

{ TBlobField }
  TBlobStreamMode = (bmRead, bmWrite, bmReadWrite);
  TBlobType = ftBlob..ftTypedBinary;

  TBlobField = class(TField)
  private
    FBlobSize : Longint;
    FBlobType : TBlobType;
    FModified : Boolean;
    FTransliterate : Boolean;
    Function GetBlobStream (Mode : TBlobStreamMode) : TStream;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure FreeBuffers; override;
    function GetAsString: string; override;
    function GetBlobSize: Longint; virtual;
    function GetIsNull: Boolean; override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetText(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    class function IsBlob: Boolean; override;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SetFieldType(AValue: TFieldType); override;
    property BlobSize: Longint read FBlobSize;
    property Modified: Boolean read FModified write FModified;
    property Value: string read GetAsString write SetAsString;
    property Transliterate: Boolean read FTransliterate write FTransliterate;
  published
    property BlobType: TBlobType read FBlobType write FBlobType;
    property Size default 0;
  end;

{ TMemoField }

  TMemoField = class(TBlobField)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Transliterate default True;
  end;

{ TGraphicField }

  TGraphicField = class(TBlobField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TIndexDef }

  TIndexDefs = class;

  TIndexOption = (ixPrimary, ixUnique, ixDescending, ixCaseInsensitive,
    ixExpression, ixNonMaintained);
  TIndexOptions = set of TIndexOption;

  TIndexDef = class(TCollectionItem)
  Private
    FExpression : String;
    FFields : String;
    FName : String;
    FOptions : TIndexOptions;
    FSource : String;
  public
    constructor Create(Owner: TIndexDefs; const AName, TheFields: string;
      TheOptions: TIndexOptions);
    destructor Destroy; override;
    property Expression: string read FExpression;
    property Fields: string read FFields write FFields;
    property Name: string read FName write FName;
    property Options: TIndexOptions read FOptions write FOptions;
    property Source: string read FSource write FSource;
  end;

{ TIndexDefs }

  TIndexDefs = class(TOwnedCollection)
  Private
    FUpDated : Boolean;
    FDataset : Tdataset;
    Function  GetItem(Index: Integer): TIndexDef;
    Procedure SetItem(Index: Integer; Value: TIndexDef);
  public
    constructor Create(DataSet: TDataSet); overload;
    destructor Destroy; override;
    procedure Add(const Name, Fields: string; Options: TIndexOptions);
    Function AddIndexDef: TIndexDef;
    procedure Assign(IndexDefs: TIndexDefs);
//    procedure Clear;
    function Find(const IndexName: string): TIndexDef;
    function FindIndexForFields(const Fields: string): TIndexDef;
    function GetIndexForFields(const Fields: string;
      CaseInsensitive: Boolean): TIndexDef;
    function IndexOf(const Name: string): Longint;
    procedure Update;
//    property Count: Longint read FCount;
    Property Items[Index: Integer] : TIndexDef read GetItem write SetItem; default;
    property Updated: Boolean read FUpdated write FUpdated;
  end;

{ TCheckConstraint }

  TCheckConstraint = class(TCollectionItem)
  Private
    FCustomConstraint : String;
    FErrorMessage : String;
    FFromDictionary : Boolean;
    FImportedConstraint : String;
  public
    procedure Assign(Source: TPersistent); override;
  //  function GetDisplayName: string; override;
  published
    property CustomConstraint: string read FCustomConstraint write FCustomConstraint;
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    property FromDictionary: Boolean read FFromDictionary write FFromDictionary;
    property ImportedConstraint: string read FImportedConstraint write FImportedConstraint;
  end;

{ TCheckConstraints }

  TCheckConstraints = class(TCollection)
  Private
   Function GetItem(Index : Longint) : TCheckConstraint;
   Procedure SetItem(index : Longint; Value : TCheckConstraint);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TCheckConstraint;
    property Items[Index: Longint]: TCheckConstraint read GetItem write SetItem; default;
  end;

{ TFields }

  Tfields = Class(TObject)
    Private
      FDataset : TDataset;
      FFieldList : TList;
      FOnChange : TNotifyEvent;
      FValidFieldKinds : TFieldKinds;
    Protected
      Procedure Changed;
      Procedure CheckfieldKind(Fieldkind : TFieldKind; Field : TField);
      Function GetCount : Longint;
      Function GetField (Index : longint) : TField;
      Procedure SetField(Index: Integer; Value: TField);
      Procedure SetFieldIndex (Field : TField;Value : Integer);
      Property OnChange : TNotifyEvent Read FOnChange Write FOnChange;
      Property ValidFieldKinds : TFieldKinds Read FValidFieldKinds;
    Public
      Constructor Create(ADataset : TDataset);
      Destructor Destroy;override;
      Procedure Add(Field : TField);
      Procedure CheckFieldName (Const Value : String);
      Procedure CheckFieldNames (Const Value : String);
      Procedure Clear;
      Function FindField (Const Value : String) : TField;
      Function FieldByName (Const Value : String) : TField;
      Function FieldByNumber(FieldNo : Integer) : TField;
      Procedure GetFieldNames (Values : TStrings);
      Function IndexOf(Field : TField) : Longint;
      procedure Remove(Value : TField);
      Property Count : Integer Read GetCount;
      Property Dataset : TDataset Read FDataset;
      Property Fields [Index : Integer] : TField Read GetField Write SetField; default;
    end;


{ TDataSet }

  TBookmark = Pointer;
  TBookmarkStr = string;

  PBookmarkFlag = ^TBookmarkFlag;
  TBookmarkFlag = (bfCurrent, bfBOF, bfEOF, bfInserted);

  PBufferList = ^TBufferList;
  TBufferList = array[0..dsMaxBufferCount - 1] of PChar;

  TGetMode = (gmCurrent, gmNext, gmPrior);

  TGetResult = (grOK, grBOF, grEOF, grError);

  TResyncMode = set of (rmExact, rmCenter);

  TDataAction = (daFail, daAbort, daRetry);

  TUpdateAction = (uaFail, uaAbort, uaSkip, uaRetry, uaApplied);

  TUpdateKind = (ukModify, ukInsert, ukDelete);


  TLocateOption = (loCaseInsensitive, loPartialKey);
  TLocateOptions = set of TLocateOption;

  TDataOperation = procedure of object;

  TDataSetNotifyEvent = procedure(DataSet: TDataSet) of object;
  TDataSetErrorEvent = procedure(DataSet: TDataSet; E: EDatabaseError;
    var DataAction: TDataAction) of object;
  TResolverErrorEvent = procedure(Sender: TObject; DataSet: TBufDataset; E: EUpdateError;
    UpdateKind: TUpdateKind; var Response: TResolverResponse) of object;

  TFilterOption = (foCaseInsensitive, foNoPartialCompare);
  TFilterOptions = set of TFilterOption;

  TFilterRecordEvent = procedure(DataSet: TDataSet;
    var Accept: Boolean) of object;

  TDatasetClass = Class of TDataset;
  TBufferArray = ^pchar;

  TDataSet = class(TComponent)
  Private
    FOpenAfterRead : boolean;
    FActiveRecord: Longint;
    FAfterCancel: TDataSetNotifyEvent;
    FAfterClose: TDataSetNotifyEvent;
    FAfterDelete: TDataSetNotifyEvent;
    FAfterEdit: TDataSetNotifyEvent;
    FAfterInsert: TDataSetNotifyEvent;
    FAfterOpen: TDataSetNotifyEvent;
    FAfterPost: TDataSetNotifyEvent;
    FAfterRefresh: TDataSetNotifyEvent;
    FAfterScroll: TDataSetNotifyEvent;
    FAutoCalcFields: Boolean;
    FBOF: Boolean;
    FBeforeCancel: TDataSetNotifyEvent;
    FBeforeClose: TDataSetNotifyEvent;
    FBeforeDelete: TDataSetNotifyEvent;
    FBeforeEdit: TDataSetNotifyEvent;
    FBeforeInsert: TDataSetNotifyEvent;
    FBeforeOpen: TDataSetNotifyEvent;
    FBeforePost: TDataSetNotifyEvent;
    FBeforeRefresh: TDataSetNotifyEvent;
    FBeforeScroll: TDataSetNotifyEvent;
    FBlobFieldCount: Longint;
    FBookmarkSize: Longint;
    FBuffers : TBufferArray;
    FBufferCount: Longint;
    FCalcBuffer: PChar;
    FCalcFieldsSize: Longint;
    FConstraints: TCheckConstraints;
    FDisableControlsCount : Integer;
    FDisableControlsState : TDatasetState;
    FCurrentRecord: Longint;
    FDataSources : TList;
    FDefaultFields: Boolean;
    FEOF: Boolean;
    FEnableControlsEvent : TDataEvent;
    FFieldList : TFields;
    FFieldDefs: TFieldDefs;
    FFilterOptions: TFilterOptions;
    FFilterText: string;
    FFiltered: Boolean;
    FFound: Boolean;
    FInternalCalcFields: Boolean;
    FModified: Boolean;
    FOnCalcFields: TDataSetNotifyEvent;
    FOnDeleteError: TDataSetErrorEvent;
    FOnEditError: TDataSetErrorEvent;
    FOnFilterRecord: TFilterRecordEvent;
    FOnNewRecord: TDataSetNotifyEvent;
    FOnPostError: TDataSetErrorEvent;
    FRecordCount: Longint;
    FIsUniDirectional: Boolean;
    FState : TDataSetState;
    Procedure DoInsertAppend(DoAppend : Boolean);
    Procedure DoInternalOpen;
    Procedure DoInternalClose;
    Function  GetBuffer (Index : longint) : Pchar;
    Function  GetField (Index : Longint) : TField;
    Procedure RegisterDataSource(ADatasource : TDataSource);
    Procedure RemoveField (Field : TField);
    Procedure SetField (Index : Longint;Value : TField);
    Procedure ShiftBuffersForward;
    Procedure ShiftBuffersBackward;
    Function  TryDoing (P : TDataOperation; Ev : TDatasetErrorEvent) : Boolean;
    Function GetActive : boolean;
    Procedure UnRegisterDataSource(ADatasource : TDatasource);
    Procedure UpdateFieldDefs;
  protected
    procedure RecalcBufListSize;
    procedure ActivateBuffers; virtual;
    procedure BindFields(Binding: Boolean);
    function  BookmarkAvailable: Boolean;
    procedure CalculateFields(Buffer: PChar); virtual;
    procedure CheckActive; virtual;
    procedure CheckInactive; virtual;
    procedure CheckBiDirectional;
    procedure Loaded; override;
    procedure ClearBuffers; virtual;
    procedure ClearCalcFields(Buffer: PChar); virtual;
    procedure CloseBlob(Field: TField); virtual;
    procedure CloseCursor; virtual;
    procedure CreateFields; virtual;
    procedure DataEvent(Event: TDataEvent; Info: Ptrint); virtual;
    procedure DestroyFields; virtual;
    procedure DoAfterCancel; virtual;
    procedure DoAfterClose; virtual;
    procedure DoAfterDelete; virtual;
    procedure DoAfterEdit; virtual;
    procedure DoAfterInsert; virtual;
    procedure DoAfterOpen; virtual;
    procedure DoAfterPost; virtual;
    procedure DoAfterScroll; virtual;
    procedure DoAfterRefresh; virtual;
    procedure DoBeforeCancel; virtual;
    procedure DoBeforeClose; virtual;
    procedure DoBeforeDelete; virtual;
    procedure DoBeforeEdit; virtual;
    procedure DoBeforeInsert; virtual;
    procedure DoBeforeOpen; virtual;
    procedure DoBeforePost; virtual;
    procedure DoBeforeScroll; virtual;
    procedure DoBeforeRefresh; virtual;
    procedure DoOnCalcFields; virtual;
    procedure DoOnNewRecord; virtual;
    function  FieldByNumber(FieldNo: Longint): TField;
    function  FindRecord(Restart, GoForward: Boolean): Boolean; virtual;
    procedure FreeFieldBuffers; virtual;
    function  GetBookmarkStr: TBookmarkStr; virtual;
    procedure GetCalcFields(Buffer: PChar); virtual;
    function  GetCanModify: Boolean; virtual;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function  GetFieldClass(FieldType: TFieldType): TFieldClass; virtual;
    Function  GetfieldCount : Integer;
    function  GetFieldValues(fieldname : string) : Variant; virtual;
    function  GetIsIndexField(Field: TField): Boolean; virtual;
    function  GetNextRecords: Longint; virtual;
    function  GetNextRecord: Boolean; virtual;
    function  GetPriorRecords: Longint; virtual;
    function  GetPriorRecord: Boolean; virtual;
    function  GetRecordCount: Longint; virtual;
    function  GetRecNo: Longint; virtual;
    procedure InitFieldDefs; virtual;
    procedure InitRecord(Buffer: PChar); virtual;
    procedure InternalCancel; virtual;
    procedure InternalEdit; virtual;
    procedure InternalInsert; virtual;
    procedure InternalRefresh; virtual;
    procedure OpenCursor(InfoQuery: Boolean); virtual;
    procedure RefreshInternalCalcFields(Buffer: PChar); virtual;
    procedure RestoreState(const Value: TDataSetState);
    Procedure SetActive (Value : Boolean); virtual;
    procedure SetBookmarkStr(const Value: TBookmarkStr); virtual;
    procedure SetBufListSize(Value: Longint);
    procedure SetChildOrder(Component: TComponent; Order: Longint); override;
    procedure SetCurrentRecord(Index: Longint); virtual;
    procedure SetFiltered(Value: Boolean); virtual;
    procedure SetFilterOptions(Value: TFilterOptions); virtual;
    procedure SetFilterText(const Value: string); virtual;
    procedure SetFound(const Value: Boolean);
    procedure SetFieldValues(fieldname: string; Value: Variant); virtual;
    procedure SetModified(Value: Boolean);
    procedure SetName(const Value: TComponentName); override;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); virtual;
    procedure SetRecNo(Value: Longint); virtual;
    procedure SetState(Value: TDataSetState);
    function SetTempState(const Value: TDataSetState): TDataSetState;
    Function Tempbuffer: PChar;
    procedure UpdateIndexDefs; virtual;
    property ActiveRecord: Longint read FActiveRecord;
    property CurrentRecord: Longint read FCurrentRecord;
    property BlobFieldCount: Longint read FBlobFieldCount;
    property BookmarkSize: Longint read FBookmarkSize write FBookmarkSize;
    property Buffers[Index: Longint]: PChar read GetBuffer;
    property BufferCount: Longint read FBufferCount;
    property CalcBuffer: PChar read FCalcBuffer;
    property CalcFieldsSize: Longint read FCalcFieldsSize;
    property InternalCalcFields: Boolean read FInternalCalcFields;
    property Constraints: TCheckConstraints read FConstraints write FConstraints;
  protected { abstract methods }
    function AllocRecordBuffer: PChar; virtual; abstract;
    procedure FreeRecordBuffer(var Buffer: PChar); virtual; abstract;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); virtual; abstract;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; virtual; abstract;
    function GetDataSource: TDataSource; virtual;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; overload; virtual;
    function GetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean): Boolean; overload; virtual;
    function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; virtual; abstract;
    function GetRecordSize: Word; virtual; abstract;
    procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); virtual; abstract;
    procedure InternalClose; virtual; abstract;
    procedure InternalDelete; virtual; abstract;
    procedure InternalFirst; virtual; abstract;
    procedure InternalGotoBookmark(ABookmark: Pointer); virtual; abstract;
    procedure InternalHandleException; virtual;
    procedure InternalInitFieldDefs; virtual; abstract;
    procedure InternalInitRecord(Buffer: PChar); virtual; abstract;
    procedure InternalLast; virtual; abstract;
    procedure InternalOpen; virtual; abstract;
    procedure InternalPost; virtual; abstract;
    procedure InternalSetToRecord(Buffer: PChar); virtual; abstract;
    function IsCursorOpen: Boolean; virtual; abstract;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); virtual; abstract;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); virtual; abstract;
    procedure SetFieldData(Field: TField; Buffer: Pointer); overload; virtual;
    procedure SetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean); overload; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ActiveBuffer: PChar;
    procedure Append;
    procedure AppendRecord(const Values: array of const);
    function BookmarkValid(ABookmark: TBookmark): Boolean; virtual;
    procedure Cancel; virtual;
    procedure CheckBrowseMode;
    procedure ClearFields;
    procedure Close;
    function  ControlsDisabled: Boolean;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Longint; virtual;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; virtual;
    procedure CursorPosChanged;
    procedure Delete;
    procedure DisableControls;
    procedure Edit;
    procedure EnableControls;
    function FieldByName(const FieldName: string): TField;
    function FindField(const FieldName: string): TField;
    function FindFirst: Boolean;
    function FindLast: Boolean;
    function FindNext: Boolean;
    function FindPrior: Boolean;
    procedure First;
    procedure FreeBookmark(ABookmark: TBookmark); virtual;
    function GetBookmark: TBookmark; virtual;
    function GetCurrentRecord(Buffer: PChar): Boolean; virtual;
    procedure GetFieldList(List: TList; const FieldNames: string);
    procedure GetFieldNames(List: TStrings);
    procedure GotoBookmark(ABookmark: TBookmark);
    procedure Insert;
    procedure InsertRecord(const Values: array of const);
    function IsEmpty: Boolean;
    function IsLinkedTo(ADataSource: TDataSource): Boolean;
    function IsSequenced: Boolean; virtual;
    procedure Last;
    function Locate(const keyfields: string; const keyvalues: Variant; options: TLocateOptions) : boolean; virtual;
    function Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant; virtual;
    function MoveBy(Distance: Longint): Longint;
    procedure Next;
    procedure Open;
    procedure Post; virtual;
    procedure Prior;
    procedure Refresh;
    procedure Resync(Mode: TResyncMode); virtual;
    procedure SetFields(const Values: array of const);
    function  Translate(Src, Dest: PChar; ToOem: Boolean): Integer; virtual;
    procedure UpdateCursorPos;
    procedure UpdateRecord;
    function UpdateStatus: TUpdateStatus; virtual;
    property BOF: Boolean read FBOF;
    property Bookmark: TBookmarkStr read GetBookmarkStr write SetBookmarkStr;
    property CanModify: Boolean read GetCanModify;
    property DataSource: TDataSource read GetDataSource;
    property DefaultFields: Boolean read FDefaultFields;
    property EOF: Boolean read FEOF;
    property FieldCount: Longint read GetFieldCount;
    property FieldDefs: TFieldDefs read FFieldDefs write FFieldDefs;
//    property Fields[Index: Longint]: TField read GetField write SetField;
    property Found: Boolean read FFound;
    property Modified: Boolean read FModified write SetModified;
    property IsUniDirectional: Boolean read FIsUniDirectional write FIsUniDirectional default False;
    property RecordCount: Longint read GetRecordCount;
    property RecNo: Longint read GetRecNo write SetRecNo;
    property RecordSize: Word read GetRecordSize;
    property State: TDataSetState read FState;
    property Fields : TFields read FFieldList;
    property FieldValues[fieldname : string] : Variant read GetFieldValues write SetFieldValues; default;
    property Filter: string read FFilterText write SetFilterText;
    property Filtered: Boolean read FFiltered write SetFiltered default False;
    property FilterOptions: TFilterOptions read FFilterOptions write SetFilterOptions;
    property Active: Boolean read GetActive write SetActive default False;
    property AutoCalcFields: Boolean read FAutoCalcFields write FAutoCalcFields;
    property BeforeOpen: TDataSetNotifyEvent read FBeforeOpen write FBeforeOpen;
    property AfterOpen: TDataSetNotifyEvent read FAfterOpen write FAfterOpen;
    property BeforeClose: TDataSetNotifyEvent read FBeforeClose write FBeforeClose;
    property AfterClose: TDataSetNotifyEvent read FAfterClose write FAfterClose;
    property BeforeInsert: TDataSetNotifyEvent read FBeforeInsert write FBeforeInsert;
    property AfterInsert: TDataSetNotifyEvent read FAfterInsert write FAfterInsert;
    property BeforeEdit: TDataSetNotifyEvent read FBeforeEdit write FBeforeEdit;
    property AfterEdit: TDataSetNotifyEvent read FAfterEdit write FAfterEdit;
    property BeforePost: TDataSetNotifyEvent read FBeforePost write FBeforePost;
    property AfterPost: TDataSetNotifyEvent read FAfterPost write FAfterPost;
    property BeforeCancel: TDataSetNotifyEvent read FBeforeCancel write FBeforeCancel;
    property AfterCancel: TDataSetNotifyEvent read FAfterCancel write FAfterCancel;
    property BeforeDelete: TDataSetNotifyEvent read FBeforeDelete write FBeforeDelete;
    property AfterDelete: TDataSetNotifyEvent read FAfterDelete write FAfterDelete;
    property BeforeScroll: TDataSetNotifyEvent read FBeforeScroll write FBeforeScroll;
    property AfterScroll: TDataSetNotifyEvent read FAfterScroll write FAfterScroll;
    property BeforeRefresh: TDataSetNotifyEvent read FBeforeRefresh write FBeforeRefresh;
    property AfterRefresh: TDataSetNotifyEvent read FAfterRefresh write FAfterRefresh;
    property OnCalcFields: TDataSetNotifyEvent read FOnCalcFields write FOnCalcFields;
    property OnDeleteError: TDataSetErrorEvent read FOnDeleteError write FOnDeleteError;
    property OnEditError: TDataSetErrorEvent read FOnEditError write FOnEditError;
    property OnFilterRecord: TFilterRecordEvent read FOnFilterRecord write SetOnFilterRecord;
    property OnNewRecord: TDataSetNotifyEvent read FOnNewRecord write FOnNewRecord;
    property OnPostError: TDataSetErrorEvent read FOnPostError write FOnPostError;
  end;

  TDataLink = class(TPersistent)
  private
    FFIrstRecord,
    FBufferCount : Integer;
    FActive,
    FDataSourceFixed,
    FEditing,
    FReadOnly,
    FUpdatingRecord,
    FVisualControl : Boolean;
    FDataSource : TDataSource;
    Function  CalcFirstRecord(Index : Integer) : Integer;
    Procedure CalcRange;
    Procedure CheckActiveAndEditing;
    Function  GetDataset : TDataset;
    procedure SetActive(AActive: Boolean);
    procedure SetDataSource(Value: TDataSource);
    Procedure SetReadOnly(Value : Boolean);
  protected
    procedure ActiveChanged; virtual;
    procedure CheckBrowseMode; virtual;
    procedure DataEvent(Event: TDataEvent; Info: Ptrint); virtual;
    procedure DataSetChanged; virtual;
    procedure DataSetScrolled(Distance: Integer); virtual;
    procedure EditingChanged; virtual;
    procedure FocusControl(Field: TFieldRef); virtual;
    function  GetActiveRecord: Integer; virtual;
    function  GetBOF: Boolean; virtual;
    function  GetBufferCount: Integer; virtual;
    function  GetEOF: Boolean; virtual;
    function  GetRecordCount: Integer; virtual;
    procedure LayoutChanged; virtual;
    function  MoveBy(Distance: Integer): Integer; virtual;
    procedure RecordChanged(Field: TField); virtual;
    procedure SetActiveRecord(Value: Integer); virtual;
    procedure SetBufferCount(Value: Integer); virtual;
    procedure UpdateData; virtual;
    property VisualControl: Boolean read FVisualControl write FVisualControl;
    property FirstRecord: Integer read FFirstRecord write FFirstRecord;
  public
    constructor Create;
    destructor Destroy; override;
    function  Edit: Boolean;
    procedure UpdateRecord;
    property Active: Boolean read FActive;
    property ActiveRecord: Integer read GetActiveRecord write SetActiveRecord;
    property BOF: Boolean read GetBOF;
    property BufferCount: Integer read FBufferCount write SetBufferCount;
    property DataSet: TDataSet read GetDataSet;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property DataSourceFixed: Boolean read FDataSourceFixed write FDataSourceFixed;
    property Editing: Boolean read FEditing;
    property Eof: Boolean read GetEOF;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property RecordCount: Integer read GetRecordCount;
  end;

{ TDetailDataLink }

  TDetailDataLink = class(TDataLink)
  protected
    function GetDetailDataSet: TDataSet; virtual;
  public
    property DetailDataSet: TDataSet read GetDetailDataSet;
  end;

{ TMasterDataLink }

  TMasterDataLink = class(TDetailDataLink)
  private
    FDetailDataSet: TDataSet;
    FFieldNames: string;
    FFields: TList;
    FOnMasterChange: TNotifyEvent;
    FOnMasterDisable: TNotifyEvent;
    procedure SetFieldNames(const Value: string);
  protected
    procedure ActiveChanged; override;
    procedure CheckBrowseMode; override;
    function GetDetailDataSet: TDataSet; override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
    Procedure DoMasterDisable; virtual;
    Procedure DoMasterChange; virtual;
  public
    constructor Create(ADataSet: TDataSet);virtual;
    destructor Destroy; override;
    property FieldNames: string read FFieldNames write SetFieldNames;
    property Fields: TList read FFields;
    property OnMasterChange: TNotifyEvent read FOnMasterChange write FOnMasterChange;
    property OnMasterDisable: TNotifyEvent read FOnMasterDisable write FOnMasterDisable;
  end;

{ TDataSource }

  TDataChangeEvent = procedure(Sender: TObject; Field: TField) of object;

  TDataSource = class(TComponent)
  private
    FDataSet: TDataSet;
    FDataLinks: TList;
    FEnabled: Boolean;
    FAutoEdit: Boolean;
    FState: TDataSetState;
    FOnStateChange: TNotifyEvent;
    FOnDataChange: TDataChangeEvent;
    FOnUpdateData: TNotifyEvent;
    procedure DistributeEvent(Event: TDataEvent; Info: Ptrint);
    procedure RegisterDataLink(DataLink: TDataLink);
    Procedure ProcessEvent(Event : TDataEvent; Info : Ptrint);
    procedure SetDataSet(ADataSet: TDataSet);
    procedure SetEnabled(Value: Boolean);
    procedure UnregisterDataLink(DataLink: TDataLink);
  protected
    Procedure DoDataChange (Info : Pointer);virtual;
    Procedure DoStateChange; virtual;
    Procedure DoUpdateData;
    property DataLinks: TList read FDataLinks;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Edit;
    function IsLinkedTo(ADataSet: TDataSet): Boolean;
    property State: TDataSetState read FState;
  published
    property AutoEdit: Boolean read FAutoEdit write FAutoEdit default True;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
    property OnDataChange: TDataChangeEvent read FOnDataChange write FOnDataChange;
    property OnUpdateData: TNotifyEvent read FOnUpdateData write FOnUpdateData;
  end;

 { TDBDataset }

  TDBDatasetClass = Class of TDBDataset;
  TDBDataset = Class(TDataset)
    Private
      FDatabase : TDatabase;
      FTransaction : TDBTransaction;
    Protected
      Procedure SetDatabase (Value : TDatabase); virtual;
      Procedure SetTransaction(Value : TDBTransaction); virtual;
      Procedure CheckDatabase;
    Public
      Destructor destroy; override;
      Property DataBase : TDatabase Read FDatabase Write SetDatabase;
      Property Transaction : TDBTransaction Read FTransaction Write SetTransaction;
    end;

 { TDBTransaction }

  TDBTransactionClass = Class of TDBTransaction;
  TDBTransaction = Class(TComponent)
  Private
    FActive        : boolean;
    FDatabase      : TDatabase;
    FDataSets      : TList;
    FOpenAfterRead : boolean;
    Function GetDataSetCount : Longint;
    Function GetDataset(Index : longint) : TDBDataset;
    procedure RegisterDataset (DS : TDBDataset);
    procedure UnRegisterDataset (DS : TDBDataset);
    procedure RemoveDataSets;
    procedure SetActive(Value : boolean);
  Protected
    Procedure SetDatabase (Value : TDatabase); virtual;
    procedure CloseTrans;
    procedure openTrans;
    Procedure CheckDatabase;
    Procedure CheckActive;
    Procedure CheckInactive;
    procedure EndTransaction; virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
  Public
    constructor Create(AOwner: TComponent); override;
    Destructor destroy; override;
    procedure CloseDataSets;
    Property DataBase : TDatabase Read FDatabase Write SetDatabase;
  published
    property Active : boolean read FActive write setactive;
  end;

  { TDatabase }

  TLoginEvent = procedure(Sender: TObject; Username, Password: string) of object;

  TDatabaseClass = Class Of TDatabase;

  TDatabase = class(TComponent)
  private
    FConnected : Boolean;
    FDataBaseName : String;
    FDataSets : TList;
    FTransactions : TList;
    FDirectory : String;
    FKeepConnection : Boolean;
    FLoginPrompt : Boolean;
    FOnLogin : TLoginEvent;
    FParams : TStrings;
    FSQLBased : Boolean;
    FOpenAfterRead : boolean;
    Function GetDataSetCount : Longint;
    Function GetTransactionCount : Longint;
    Function GetDataset(Index : longint) : TDBDataset;
    Function GetTransaction(Index : longint) : TDBTransaction;
    procedure SetConnected (Value : boolean);
    procedure RegisterDataset (DS : TDBDataset);
    procedure RegisterTransaction (TA : TDBTransaction);
    procedure UnRegisterDataset (DS : TDBDataset);
    procedure UnRegisterTransaction(TA : TDBTransaction);
    procedure RemoveDataSets;
    procedure RemoveTransactions;
  protected
    Procedure CheckConnected;
    Procedure CheckDisConnected;
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
    Procedure DoInternalConnect; Virtual;Abstract;
    Procedure DoInternalDisConnect; Virtual;Abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Close;
    procedure Open;
    procedure CloseDataSets;
    procedure CloseTransactions;
//    procedure ApplyUpdates;
    procedure StartTransaction; virtual; abstract;
    procedure EndTransaction; virtual; abstract;
    property DataSetCount: Longint read GetDataSetCount;
    property DataSets[Index: Longint]: TDBDataSet read GetDataSet;
    property TransactionCount: Longint read GetTransactionCount;
    property Transactions[Index: Longint]: TDBTransaction read GetTransaction;
    property Directory: string read FDirectory write FDirectory;
    property IsSQLBased: Boolean read FSQLBased;
  published
    property Connected: Boolean read FConnected write SetConnected;
    property DatabaseName: string read FDatabaseName write FDatabaseName;
    property KeepConnection: Boolean read FKeepConnection write FKeepConnection;
    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt;
    property Params : TStrings read FParams Write FParams;
    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
  end;

    { TCustomConnection }

  TCustomConnection = class(TDatabase)
  private
    FAfterConnect: TNotifyEvent;
    FAfterDisconnect: TNotifyEvent;
    FBeforeConnect: TNotifyEvent;
    FBeforeDisconnect: TNotifyEvent;
    procedure SetAfterConnect(const AValue: TNotifyEvent);
    procedure SetAfterDisconnect(const AValue: TNotifyEvent);
    procedure SetBeforeConnect(const AValue: TNotifyEvent);
    procedure SetBeforeDisconnect(const AValue: TNotifyEvent);
  protected
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    function GetConnected : boolean; virtual;
    procedure StartTransaction; override;
    procedure EndTransaction; override;
  published
    property AfterConnect : TNotifyEvent read FAfterConnect write SetAfterConnect;
    property BeforeConnect : TNotifyEvent read FBeforeConnect write SetBeforeConnect;
    property AfterDisconnect : TNotifyEvent read FAfterDisconnect write SetAfterDisconnect;
    property BeforeDisconnect : TNotifyEvent read FBeforeDisconnect write SetBeforeDisconnect;
  end;


  { TBufDataset }

  PBufRecLinkItem = ^TBufRecLinkItem;
  TBufRecLinkItem = record
    prior   : PBufRecLinkItem;
    next    : PBufRecLinkItem;
  end;

  PBufBookmark = ^TBufBookmark;
  TBufBookmark = record
    BookmarkData : PBufRecLinkItem;
    BookmarkFlag : TBookmarkFlag;
  end;

  PRecUpdateBuffer = ^TRecUpdateBuffer;
  TRecUpdateBuffer = record
    UpdateKind         : TUpdateKind;
    BookmarkData       : pointer;
    OldValuesBuffer    : pchar;
  end;

  TRecordsUpdateBuffer = array of TRecUpdateBuffer;

  TBufDataset = class(TDBDataSet)
  private
    FCurrentRecBuf  : PBufRecLinkItem;
    FLastRecBuf     : PBufRecLinkItem;
    FFirstRecBuf    : PBufRecLinkItem;
    FBRecordCount   : integer;

    FPacketRecords  : integer;
    FRecordSize     : Integer;
    FNullmaskSize   : byte;
    FOpen           : Boolean;
    FUpdateBuffer   : TRecordsUpdateBuffer;
    FCurrentUpdateBuffer : integer;

    FFieldBufPositions : array of longint;
    
    FAllPacketsFetched : boolean;
    FOnUpdateError  : TResolverErrorEvent;
    procedure CalcRecordSize;
    function LoadBuffer(Buffer : PChar): TGetResult;
    function GetFieldSize(FieldDef : TFieldDef) : longint;
    function GetRecordUpdateBuffer : boolean;
    procedure SetPacketRecords(aValue : integer);
    function  IntAllocRecordBuffer: PChar;
  protected
    procedure SetRecNo(Value: Longint); override;
    function  GetRecNo: Longint; override;
    function GetChangeCount: integer; virtual;
    function  AllocRecordBuffer: PChar; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure InternalInitRecord(Buffer: PChar); override;
    function  GetCanModify: Boolean; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
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
  public
    constructor Create(AOwner: TComponent); override;
    procedure ApplyUpdates; virtual; overload;
    procedure ApplyUpdates(MaxErrors: Integer); virtual; overload;
    procedure CancelUpdates; virtual;
    destructor Destroy; override;
    function Locate(const keyfields: string; const keyvalues: Variant; options: TLocateOptions) : boolean; override;
    function UpdateStatus: TUpdateStatus; override;
    property ChangeCount : Integer read GetChangeCount;
  published
    property PacketRecords : Integer read FPacketRecords write FPacketRecords default 10;
    property OnUpdateError: TResolverErrorEvent read FOnUpdateError write SetOnUpdateError;
  end;

  { TParam }

  TBlobData = string;

  TParamBinding = array of integer;

  TParamType = (ptUnknown, ptInput, ptOutput, ptInputOutput, ptResult);
  TParamTypes = set of TParamType;

  TParamStyle = (psInterbase,psPostgreSQL,psSimulated);

  TParams = class;

  TParam = class(TCollectionItem)
  private
    FNativeStr: string;
    FValue: Variant;
    FPrecision: Integer;
    FNumericScale: Integer;
    FName: string;
    FDataType: TFieldType;
    FBound: Boolean;
    FParamType: TParamType;
    FSize: Integer;
    Function GetDataSet: TDataSet;
    Function IsParamStored: Boolean;
  protected
    Procedure AssignParam(Param: TParam);
    Procedure AssignTo(Dest: TPersistent); override;
    Function GetAsBoolean: Boolean;
    Function GetAsCurrency: Currency;
    Function GetAsDateTime: TDateTime;
    Function GetAsFloat: Double;
    Function GetAsInteger: Longint;
    Function GetAsLargeInt: LargeInt;
    Function GetAsMemo: string;
    Function GetAsString: string;
    Function GetAsVariant: Variant;
    Function GetDisplayName: string; override;
    Function GetIsNull: Boolean;
    Function IsEqual(AValue: TParam): Boolean;
    Procedure SetAsBlob(const AValue: TBlobData);
    Procedure SetAsBoolean(AValue: Boolean);
    Procedure SetAsCurrency(const AValue: Currency);
    Procedure SetAsDate(const AValue: TDateTime);
    Procedure SetAsDateTime(const AValue: TDateTime);
    Procedure SetAsFloat(const AValue: Double);
    Procedure SetAsInteger(AValue: Longint);
    Procedure SetAsLargeInt(AValue: LargeInt);
    Procedure SetAsMemo(const AValue: string);
    Procedure SetAsSmallInt(AValue: LongInt);
    Procedure SetAsString(const AValue: string);
    Procedure SetAsTime(const AValue: TDateTime);
    Procedure SetAsVariant(const AValue: Variant);
    Procedure SetAsWord(AValue: LongInt);
    Procedure SetDataType(AValue: TFieldType);
    Procedure SetText(const AValue: string);
  public
    constructor Create(ACollection: TCollection); overload; override;
    constructor Create(AParams: TParams; AParamType: TParamType); reintroduce; overload;
    Procedure Assign(Source: TPersistent); override;
    Procedure AssignField(Field: TField);
    Procedure AssignToField(Field: TField);
    Procedure AssignFieldValue(Field: TField; const AValue: Variant);
    procedure AssignFromField(Field : TField);
    Procedure Clear;
    Procedure GetData(Buffer: Pointer);
    Function  GetDataSize: Integer;
    Procedure LoadFromFile(const FileName: string; BlobType: TBlobType);
    Procedure LoadFromStream(Stream: TStream; BlobType: TBlobType);
    Procedure SetBlobData(Buffer: Pointer; ASize: Integer);
    Procedure SetData(Buffer: Pointer);
    Property AsBlob : TBlobData read GetAsString write SetAsBlob;
    Property AsBoolean : Boolean read GetAsBoolean write SetAsBoolean;
    Property AsCurrency : Currency read GetAsCurrency write SetAsCurrency;
    Property AsDate : TDateTime read GetAsDateTime write SetAsDate;
    Property AsDateTime : TDateTime read GetAsDateTime write SetAsDateTime;
    Property AsFloat : Double read GetAsFloat write SetAsFloat;
    Property AsInteger : LongInt read GetAsInteger write SetAsInteger;
    Property AsLargeInt : LargeInt read GetAsLargeInt write SetAsLargeInt;
    Property AsMemo : string read GetAsMemo write SetAsMemo;
    Property AsSmallInt : LongInt read GetAsInteger write SetAsSmallInt;
    Property AsString : string read GetAsString write SetAsString;
    Property AsTime : TDateTime read GetAsDateTime write SetAsTime;
    Property AsWord : LongInt read GetAsInteger write SetAsWord;
    Property Bound : Boolean read FBound write FBound;
    Property Dataset : TDataset Read GetDataset;
    Property IsNull : Boolean read GetIsNull;
    Property NativeStr : string read FNativeStr write FNativeStr;
    Property Text : string read GetAsString write SetText;
    Property Value : Variant read GetAsVariant write SetAsVariant stored IsParamStored;
  published
    Property DataType : TFieldType read FDataType write SetDataType;
    Property Name : string read FName write FName;
    Property NumericScale : Integer read FNumericScale write FNumericScale default 0;
    Property ParamType : TParamType read FParamType write FParamType;
    Property Precision : Integer read FPrecision write FPrecision default 0;
    Property Size : Integer read FSize write FSize default 0;
  end;


  { TParams }

  TParams = class(TCollection)
  private
    FOwner: TPersistent;
    Function  GetItem(Index: Integer): TParam;
    Function  GetParamValue(const ParamName: string): Variant;
    Procedure SetItem(Index: Integer; Value: TParam);
    Procedure SetParamValue(const ParamName: string; const Value: Variant);
  protected
    Procedure AssignTo(Dest: TPersistent); override;
    Function  GetDataSet: TDataSet;
    Function  GetOwner: TPersistent; override;
  public
    Constructor Create(AOwner: TPersistent); overload;
    Constructor Create; overload;
    Procedure AddParam(Value: TParam);
    Procedure AssignValues(Value: TParams);
    Function  CreateParam(FldType: TFieldType; const ParamName: string; ParamType: TParamType): TParam;
    Function  FindParam(const Value: string): TParam;
    Procedure GetParamList(List: TList; const ParamNames: string);
    Function  IsEqual(Value: TParams): Boolean;
    Function  ParamByName(const Value: string): TParam;
    Function  ParseSQL(SQL: String; DoCreate: Boolean): String;
    Function  ParseSQL(SQL: String; DoCreate: Boolean; ParameterStyle : TParamStyle): String; overload;
    Function  ParseSQL(SQL: String; DoCreate: Boolean; ParameterStyle : TParamStyle; var ParamBinding: TParambinding): String; overload;
    Function  ParseSQL(SQL: String; DoCreate: Boolean; ParameterStyle : TParamStyle; var ParamBinding: TParambinding; var ReplaceString : string): String;
    Procedure RemoveParam(Value: TParam);
    Procedure CopyParamValuesFromDataset(ADataset : TDataset; CopyBound : Boolean);
    Property Dataset : TDataset Read GetDataset;
    Property Items[Index: Integer] : TParam read GetItem write SetItem; default;
    Property ParamValues[const ParamName: string] : Variant read GetParamValue write SetParamValue;
  end;

  TMasterParamsDataLink = Class(TMasterDataLink)
  Private
    FParams : TParams;
    Procedure SetParams(AVAlue : TParams);  
  Protected  
    Procedure DoMasterDisable; override;
    Procedure DoMasterChange; override;
  Public
    constructor Create(ADataSet: TDataSet); override;
    Procedure RefreshParamNames; virtual;
    Procedure CopyParamsFromMaster(CopyBound : Boolean); virtual;
    Property Params : TParams Read FParams Write SetParams;  
  end;

const
  FieldTypetoVariantMap : array[TFieldType] of Integer = (varError, varOleStr, varSmallint,
    varInteger, varSmallint, varBoolean, varDouble, varCurrency, varCurrency,
    varDate, varDate, varDate, varOleStr, varOleStr, varInteger, varOleStr,
    varOleStr, varOleStr, varOleStr, varOleStr, varOleStr, varOleStr, varError,
    varOleStr, varOleStr, varError, varError, varError, varError, varError,
    varOleStr, varOleStr, varVariant, varUnknown, varDispatch, varOleStr, varOleStr,varOleStr);


Const
  Fieldtypenames : Array [TFieldType] of String[15] =
    (
      'Unknown',
      'String',
      'Smallint',
      'Integer',
      'Word',
      'Boolean',
      'Float',
      'Currency',
      'BCD',
      'Date',
      'Time',
      'DateTime',
      'Bytes',
      'VarBytes',
      'AutoInc',
      'Blob',
      'Memo',
      'Graphic',
      'FmtMemo',
      'ParadoxOle',
      'DBaseOle',
      'TypedBinary',
      'Cursor',
      'FixedChar',
      'WideString',
      'Largeint',
      'ADT',
      'Array',
      'Reference',
      'DataSet',
      'OraBlob',
      'OraClob',
      'Variant',
      'Interface',
      'IDispatch',
      'Guid',
      'TimeStamp',
      'FMTBcd'
    );
    { 'Unknown',
      'String',
      'Smallint',
      'Integer',
      'Word',
      'Boolean',
      'Float',
      'Date',
      'Time',
      'DateTime',
      'Bytes',
      'VarBytes',
      'AutoInc',
      'Blob',
      'Memo',
      'Graphic',
      'FmtMemo',
      'ParadoxOle',
      'DBaseOle',
      'TypedBinary',
      'Cursor'
    );}

const
  DefaultFieldClasses : Array [TFieldType] of TFieldClass =
    ( { ftUnknown} Tfield,
      { ftString} TStringField,
      { ftSmallint} TSmallIntField,
      { ftInteger} TLongintField,
      { ftWord} TLongintField,
      { ftBoolean} TBooleanField,
      { ftFloat} TFloatField,
      { ftCurrency} Nil,
      { ftBCD} TBCDField,
      { ftDate} TDateField,
      { ftTime} TTimeField,
      { ftDateTime} TDateTimeField,
      { ftBytes} TBytesField,
      { ftVarBytes} TVarBytesField,
      { ftAutoInc} TAutoIncField,
      { ftBlob} TBlobField,
      { ftMemo} TMemoField,
      { ftGraphic} TGraphicField,
      { ftFmtMemo} TMemoField,
      { ftParadoxOle} Nil,
      { ftDBaseOle} Nil,
      { ftTypedBinary} Nil,
      { ftCursor} Nil,
      { ftFixedChar} TStringField,
      { ftWideString} Nil,
      { ftLargeint} TLargeIntField,
      { ftADT} Nil,
      { ftArray} Nil,
      { ftReference} Nil,
      { ftDataSet} Nil,
      { ftOraBlob} TBlobField,
      { ftOraClob} TMemoField,
      { ftVariant} Nil,
      { ftInterface} Nil,
      { ftIDispatch} Nil,
      { ftGuid} Nil,
      { ftTimeStamp} Nil,
      { ftFMTBcd} Nil
    );

  dsEditModes = [dsEdit, dsInsert, dsSetKey];
  dsWriteModes = [dsEdit, dsInsert, dsSetKey, dsCalcFields, dsFilter,
    dsNewValue, dsInternalCalc];

{ Auxiliary functions }

Procedure DatabaseError (Const Msg : String);
Procedure DatabaseError (Const Msg : String; Comp : TComponent);
Procedure DatabaseErrorFmt (Const Fmt : String; Args : Array Of Const);
Procedure DatabaseErrorFmt (Const Fmt : String; Args : Array Of const;
                            Comp : TComponent);
Function ExtractFieldName(Const Fields: String; var Pos: Integer): String;
Function DateTimeRecToDateTime(DT: TFieldType; Data: TDateTimeRec): TDateTime;
Function DateTimeToDateTimeRec(DT: TFieldType; Data: TDateTime): TDateTimeRec;

procedure DisposeMem(var Buffer; Size: Integer);
function BuffersEqual(Buf1, Buf2: Pointer; Size: Integer): Boolean;

implementation

uses dbconst,typinfo;

{ ---------------------------------------------------------------------
    Auxiliary functions
  ---------------------------------------------------------------------}



Procedure DatabaseError (Const Msg : String);

begin
  Raise EDataBaseError.Create(Msg);
end;

Procedure DatabaseError (Const Msg : String; Comp : TComponent);

begin
  if assigned(Comp) then
    Raise EDatabaseError.CreateFmt('%s : %s',[Comp.Name,Msg])
  else
    DatabaseError(Msg);
end;

Procedure DatabaseErrorFmt (Const Fmt : String; Args : Array Of Const);

begin
  Raise EDatabaseError.CreateFmt(Fmt,Args);
end;

Procedure DatabaseErrorFmt (Const Fmt : String; Args : Array Of const;
                            Comp : TComponent);
begin
  if assigned(comp) then
    Raise EDatabaseError.CreateFmt(Format('%s : %s',[Comp.Name,Fmt]),Args)
  else
    DatabaseErrorFmt(Fmt, Args);
end;

Function ExtractFieldName(Const Fields: String; var Pos: Integer): String;

var
  i: integer;
begin
  for i := Pos to Length(Fields) do begin
    if Fields[i] = ';' then begin
      Result := Copy(Fields, Pos, i - Pos);
      Pos := i + 1;
      Exit;
    end;
  end;
  Result := Copy(Fields, Pos, Length(Fields));
  Pos := Length(Fields) + 1;
end;

{ EUpdateError }
constructor EUpdateError.Create(NativeError, Context : String;
                                ErrCode, PrevError : integer; E: Exception);
                                
begin
  Inherited CreateFmt(NativeError,[Context]);
  FContext := Context;
  FErrorCode := ErrCode;
  FPreviousError := PrevError;
  FOriginalException := E;
end;

Destructor EUpdateError.Destroy;

begin
  FOriginalException.Free;
end;

{ TIndexDef }

constructor TIndexDef.Create(Owner: TIndexDefs; const AName, TheFields: string;
      TheOptions: TIndexOptions);

begin
  inherited create(Owner);
  FName := aname;
  FFields := TheFields;
  FOptions := TheOptions;
end;


destructor TIndexDef.Destroy;

begin
  inherited Destroy;
end;


{ TIndexDefs }

Function TIndexDefs.GetItem (Index : integer) : TIndexDef;

begin
  Result:=(Inherited GetItem(Index)) as TIndexDef;
end;

Procedure TIndexDefs.SetItem(Index: Integer; Value: TIndexDef);
begin
  Inherited SetItem(Index,Value);
end;

constructor TIndexDefs.Create(DataSet: TDataSet);

begin
  FDataset := Dataset;
  inherited create(Dataset, TIndexDef);
end;


destructor TIndexDefs.Destroy;

begin
  inherited Destroy;
end;

Function TIndexDefs.AddIndexDef: TIndexDef;

begin
//  Result := inherited add as TIndexDef;
  Result:=TIndexDef.Create(Self,'','',[]);
end;

procedure TIndexDefs.Add(const Name, Fields: string; Options: TIndexOptions);

begin
  TIndexDef.Create(Self,Name,Fields,Options);
end;


procedure TIndexDefs.Assign(IndexDefs: TIndexDefs);

begin
  //!! To be implemented
end;

{procedure TIndexDefs.Clear;

begin
  //!! To be implemented
end;}

function TIndexDefs.Find(const IndexName: string): TIndexDef;
var i: integer;
begin
  Result := Nil;
  for i := 0 to Count - 1 do
    if AnsiSameText(Items[i].Name, IndexName) then begin
      Result := Items[i];
      Break;
    end;
  if (Result=Nil) Then
    DatabaseErrorFmt(SIndexNotFound, [IndexName], FDataSet);
end;

function TIndexDefs.FindIndexForFields(const Fields: string): TIndexDef;

begin
  //!! To be implemented
end;


function TIndexDefs.GetIndexForFields(const Fields: string;
  CaseInsensitive: Boolean): TIndexDef;

var
  i, FieldsLen: integer;
  Last: TIndexDef;
begin
  Last := nil;
  FieldsLen := Length(Fields);
  for i := 0 to Count - 1 do
  begin
    Result := Items[I];
    if (Result.Options * [ixDescending, ixExpression] = []) and
       (not CaseInsensitive or (ixCaseInsensitive in Result.Options)) and
       AnsiSameText(Fields, Result.Fields) then
    begin
      Exit;
    end else
    if AnsiSameText(Fields, Copy(Result.Fields, 1, FieldsLen)) and
       ((Length(Result.Fields) = FieldsLen) or
       (Result.Fields[FieldsLen + 1] = ';')) then
    begin
      if (Last = nil) or
         ((Last <> nil) And (Length(Last.Fields) > Length(Result.Fields))) then
           Last := Result;
    end;
  end;
  Result := Last;
end;


function TIndexDefs.IndexOf(const Name: string): Longint;

var i: LongInt;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if AnsiSameText(Items[i].Name, Name) then
    begin
      Result := i;
      Break;
    end;
end;


procedure TIndexDefs.Update;

begin
  if assigned(Fdataset) then
    Fdataset.UpdateIndexDefs;
end;

{ TCheckConstraint }

procedure TCheckConstraint.Assign(Source: TPersistent);

begin
  //!! To be implemented
end;



{ TCheckConstraints }

Function TCheckConstraints.GetItem(Index : Longint) : TCheckConstraint;

begin
  //!! To be implemented
end;


Procedure TCheckConstraints.SetItem(index : Longint; Value : TCheckConstraint);

begin
  //!! To be implemented
end;


function TCheckConstraints.GetOwner: TPersistent;

begin
  //!! To be implemented
end;


constructor TCheckConstraints.Create(AOwner: TPersistent);

begin
  //!! To be implemented
end;


function TCheckConstraints.Add: TCheckConstraint;

begin
  //!! To be implemented
end;

{ TLookupList }

constructor TLookupList.Create;

begin
  FList := TList.Create;
end;

destructor TLookupList.Destroy;

begin
  if FList <> nil then Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TLookupList.Add(const AKey, AValue: Variant);

var LookupRec: PLookupListRec;
begin
  New(LookupRec);
  LookupRec^.Key := AKey;
  LookupRec^.Value := AValue;
  FList.Add(LookupRec);
end;

procedure TLookupList.Clear;
var i: integer;
begin
  for i := 0 to FList.Count - 1 do Dispose(PLookupListRec(FList[i]));
  FList.Clear;
end;

function TLookupList.ValueOfKey(const AKey: Variant): Variant;

var I: Integer;
begin
  Result := Null;
  if VarIsNull(AKey) then Exit;
  i := FList.Count - 1;
  while (i > 0) And (PLookupListRec(FList.Items[I])^.Key <> AKey) do Dec(i);
  if i >= 0 then Result := PLookupListRec(FList.Items[I])^.Value;
end;

procedure DisposeMem(var Buffer; Size: Integer);
begin
  if Pointer(Buffer) <> nil then
    begin
    FreeMem(Pointer(Buffer), Size);
    Pointer(Buffer) := nil;
    end;
end;

function BuffersEqual(Buf1, Buf2: Pointer; Size: Integer): Boolean; 

begin
  Result:=CompareByte(Buf1,Buf2,Size)=0
end;

{$i dataset.inc}
{$i fields.inc}
{$i datasource.inc}
{$i database.inc}
{$i bufdataset.inc}
{$i dsparams.inc}

end.
