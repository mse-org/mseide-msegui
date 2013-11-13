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

 Modified 2013 by Martin Schreiber

 **********************************************************************}
unit mdb;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 classes,mclasses,sysutils,variants,fmtbcd,maskutils,msetypes,mseifiglob,
 msestrings
   {$ifndef FPC},classes_del{$endif};

const

  dsMaxBufferCount = MAXINT div 8;
  dsMaxStringSize = 8192;

  // Used in AsBoolean for string fields to determine
  // whether it's true or false.
  YesNoChars : Array[Boolean] of char = ('N', 'Y');

  SQLDelimiterCharacters = [';',',',' ','(',')',#13,#10,#9];

type

{LargeInt}
  LargeInt = Int64;
  PLargeInt= ^LargeInt;

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
    Destructor Destroy; override;
    property Context : String read FContext;
    property ErrorCode : integer read FErrorcode;
    property OriginalException : Exception read FOriginalException;
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
    ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd, ftFixedWideChar, ftWideMemo);

{ Part of DBCommon, but temporary defined here (bug 8206) }

 TFieldMap = array[TFieldType] of Byte;

{ TDateTimeRec }

  TDateTimeAlias = type TDateTime;
  PDateTimeRec = ^TdateTimeRec;
  TDateTimeRec = record
    case TFieldType of
      ftDate: (Date: Longint);
      ftTime: (Time: Longint);
      ftDateTime: (DateTime: TDateTimeAlias);
  end;

  TFieldAttribute = (faHiddenCol, faReadonly, faRequired, faLink, faUnNamed, faFixed);
  TFieldAttributes = set of TFieldAttribute;

  { TNamedItem }

  TNamedItem = class(TCollectionItem)
  private
    FName: string;
  protected
    function GetDisplayName: string; override;
    procedure SetDisplayName(const AValue: string); override;
  Public  
    property DisplayName : string read GetDisplayName write SetDisplayName;
  published
    property Name : string read FName write SetDisplayName;
  end;

  { TDefCollection }

  TDefCollection = class(TOwnedCollection)
  private
    FDataset: TDataset;
    FUpdated: boolean;
  protected
    procedure SetItemName(AItem: TCollectionItem); override;
  public
    constructor create(ADataset: TDataset; AOwner: TPersistent; AClass: TCollectionItemClass);
    function Find(const AName: string): TNamedItem;
    procedure GetItemNames(List: TStrings);
    function IndexOf(const AName: string): Longint;
    property Dataset: TDataset read FDataset;
    property Updated: boolean read FUpdated write FUpdated;
  end;

  { TFieldDef }

  TFieldDef = class(TNamedItem)
  Private
    FDataType : TFieldType;
    FInternalCalcField : Boolean;
    FPrecision : Longint;
    FRequired : Boolean;
    FSize : Integer;
    FAttributes : TFieldAttributes;
    Function GetFieldClass : TFieldClass;
    procedure SetAttributes(AValue: TFieldAttributes);
    procedure SetDataType(AValue: TFieldType);
    procedure SetPrecision(const AValue: Longint);
    procedure SetSize(const AValue: Integer);
    procedure SetRequired(const AValue: Boolean);
   protected
    FFieldNo : Longint;
  public
    constructor create(ACollection : TCollection); overload; override;
    constructor Create(AOwner: TFieldDefs; const AName: string;
      ADataType: TFieldType; ASize: Integer; ARequired: Boolean;
                                          AFieldNo: Longint); overload;
    destructor Destroy; override;
    procedure Assign(APersistent: TPersistent); override;
    function CreateField(AOwner: TComponent): TField;
    property FieldClass: TFieldClass read GetFieldClass;
    property FieldNo: Longint read FFieldNo;
    property InternalCalcField: Boolean read FInternalCalcField write FInternalCalcField;
    property Required: Boolean read FRequired write SetRequired;
  Published
    property Attributes: TFieldAttributes read FAttributes write SetAttributes default [];
    property DataType: TFieldType read FDataType write SetDataType;
    property Precision: Longint read FPrecision write SetPrecision;
    property Size: Integer read FSize write SetSize;
  end;

{ TFieldDefs }

  TFieldDefs = class(TDefCollection)
  private
    FHiddenFields : Boolean;
    function GetItem(Index: Longint): TFieldDef;
    procedure SetItem(Index: Longint; const AValue: TFieldDef);
  public
    constructor Create(ADataSet: TDataSet);
//    destructor Destroy; override;
    procedure Add(const AName: string; ADataType: TFieldType; ASize: Word; ARequired: Boolean); overload;
    procedure Add(const AName: string; ADataType: TFieldType; ASize: Word); overload;
    procedure Add(const AName: string; ADataType: TFieldType); overload;
    Function AddFieldDef : TFieldDef;
    procedure Assign(FieldDefs: TFieldDefs); overload;
    function Find(const AName: string): TFieldDef;
//    procedure Clear;
//    procedure Delete(Index: Longint);
    procedure Update; overload;
    Function MakeNameUnique(const AName : String) : string; virtual;
    Property HiddenFields : Boolean Read FHiddenFields Write FHiddenFields;
    property Items[Index: Longint]: TFieldDef read GetItem write SetItem; default;
  end;

{ TField }

  TFieldKind = (fkData, fkCalculated, fkLookup, fkInternalCalc);
  TFieldKinds = Set of TFieldKind;

  TFieldNotifyEvent = procedure(Sender: TField) of object;
  TFieldGetTextEvent = procedure(Sender: TField; var aText: string;
    DisplayText: Boolean) of object;
  TFieldSetTextEvent = procedure(Sender: TField; const aText: string) of object;
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
    FList: TFPList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AKey, AValue: Variant);
    procedure Clear;
    function FirstKeyByValue(const AValue: Variant): Variant;
    function ValueOfKey(const AKey: Variant): Variant;
    procedure ValuesToStrings(AStrings: TStrings);
  end;

  { TField }

  TField = class(TComponent)
  private
    FAlignment : TAlignment;
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
    FEditMask: TEditMask;
    FFieldKind : TFieldKind;
    FFieldName : String;
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
    FOnChange : TFieldNotifyEvent;
    FOnGetText: TFieldGetTextEvent;
    FOnSetText: TFieldSetTextEvent;
    FOnValidate: TFieldNotifyEvent;
    FOrigin : String;
    FReadOnly : Boolean;
    FRequired : Boolean;
    FSize : integer;
    FValidChars : TFieldChars;
    FVisible : Boolean;
    FProviderFlags : TProviderFlags;
    function GetIndex : longint;
    function GetLookup: Boolean;
    procedure SetAlignment(const AValue: TAlignMent);
    procedure SetIndex(const AValue: Integer);
    function GetDisplayText: String;
    function GetEditText: String;
    procedure SetEditText(const AValue: string);
    procedure SetDisplayLabel(const AValue: string);
    procedure SetDisplayWidth(const AValue: Longint);
    function GetDisplayWidth: integer;
    procedure SetLookup(const AValue: Boolean);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);
    function IsDisplayStored : Boolean;
    function GetLookupList: TLookupList;
    procedure CalcLookupValue;
  protected
    FValidating : Boolean;
    FValueBuffer : Pointer;
    FOffset : Word;
    FFieldNo : Longint;
    function AccessError(const TypeName: string): EDatabaseError;
    procedure CheckInactive;
    class procedure CheckTypeSize(AValue: Longint); virtual;
    procedure Change; virtual;
    procedure DataChanged;
    procedure FreeBuffers; virtual;
    function GetAsBCD: TBCD; virtual;
    function GetAsBoolean: Boolean; virtual;
    function GetAsBytes: TBytes; virtual;
    function GetAsCurrency: Currency; virtual;
    function GetAsLargeInt: LargeInt; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function getasdate: tdatetime; virtual;
    function getastime: tdatetime; virtual;
    function GetAsFloat: Double; virtual;
    function GetAsLongint: Longint; virtual;
    function GetAsInteger: Longint; virtual;
    function GetAsVariant: variant; virtual;
    function GetOldValue: variant; virtual;
    function GetAsString: string; virtual;
    function GetAsWideString: WideString; virtual;
    function getasunicodestring: unicodestring; virtual;
    procedure setasunicodestring(const avalue: unicodestring); virtual;
    function GetCanModify: Boolean; virtual;
    function GetClassDesc: String; virtual;
    function GetDataSize: Integer; virtual;
    function GetDefaultWidth: Longint; virtual;
    function GetDisplayName : String;
    function GetCurValue: Variant; virtual;
    function GetNewValue: Variant; virtual;
    function GetIsNull: Boolean; virtual;
    procedure GetText(var AText: string; ADisplayText: Boolean); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PropertyChanged(LayoutAffected: Boolean);
    procedure ReadState(Reader: TReader); override;
    procedure SetAsBCD(const AValue: TBCD); virtual;
    procedure SetAsBoolean(AValue: Boolean); virtual;
    procedure SetAsBytes(const AValue: TBytes); virtual;
    procedure SetAsCurrency(AValue: Currency); virtual;
    procedure SetAsDateTime(AValue: TDateTime); virtual;
    procedure setasdate(avalue: tdatetime); virtual;
    procedure setastime(avalue: tdatetime); virtual;
    procedure SetAsFloat(AValue: Double); virtual;
    procedure SetAsLongint(AValue: Longint); virtual;
    procedure SetAsInteger(AValue: Integer); virtual;
    procedure SetAsLargeint(AValue: Largeint); virtual;
    procedure SetAsVariant(const AValue: variant); virtual;
    procedure SetAsString(const AValue: string); virtual;
    procedure SetAsWideString(const aValue: WideString); virtual;
    procedure SetDataset(AValue : TDataset); virtual;
    procedure SetDataType(AValue: TFieldType);
    procedure SetNewValue(const AValue: Variant);
    procedure SetSize(AValue: Integer); virtual;
    procedure SetParentComponent(AParent: TComponent); override;
    procedure SetText(const AValue: string); virtual;
    procedure SetVarValue(const AValue: Variant); virtual;
    function getasguid: tguid; virtual;
    procedure setasguid(const avalue: tguid); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignValue(const AValue: TVarRec);
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure Clear; virtual;
    procedure FocusControl;
    function GetData(Buffer: Pointer): Boolean; overload;
    function GetData(Buffer: Pointer; NativeFormat : Boolean): Boolean; overload;
    class function IsBlob: Boolean; virtual;
    function IsValidChar(InputChar: Char): Boolean; virtual;
    procedure RefreshLookupList;
    procedure SetData(Buffer: Pointer); overload;
    procedure SetData(Buffer: Pointer; NativeFormat : Boolean); overload;
    procedure SetFieldType(AValue: TFieldType); virtual;
    procedure Validate(Buffer: Pointer);
    property AsBCD: TBCD read GetAsBCD write SetAsBCD;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsBytes: TBytes read GetAsBytes write SetAsBytes;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property asdate: tdatetime read getasdate write setasdate;
    property astime: tdatetime read getastime write setastime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property asguid: tguid read getasguid write setasguid;
    property AsLongint: Longint read GetAsLongint write SetAsLongint;
    property AsLargeInt: LargeInt read GetAsLargeInt write SetAsLargeInt;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsWideString: WideString read GetAsWideString write SetAsWideString;
    property asunicodestring: unicodestring read getasunicodestring 
                                                     write setasunicodestring;
    property asmsestring: msestring read getasunicodestring 
                                                     write setasunicodestring;
    property AsVariant: variant read GetAsVariant write SetAsVariant;
    property AttributeSet: string read FAttributeSet write FAttributeSet;
    property Calculated: Boolean read FCalculated write FCalculated;
    property CanModify: Boolean read GetCanModify;
    property CurValue: Variant read GetCurValue;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property DataSize: Integer read GetDataSize;
    property DataType: TFieldType read FDataType;
    property DisplayName: String Read GetDisplayName;
    property DisplayText: String read GetDisplayText;
    property EditMask: TEditMask read FEditMask write FEditMask;
    property EditMaskPtr: TEditMask read FEditMask;
    property FieldNo: Longint read FFieldNo;
    property IsIndexField: Boolean read FIsIndexField;
    property IsNull: Boolean read GetIsNull;
    property Lookup: Boolean read GetLookup write SetLookup;
    property NewValue: Variant read GetNewValue write SetNewValue;
    property Offset: word read FOffset;
    property Size: Integer read FSize write SetSize;
    property Text: string read GetEditText write SetEditText;
    property ValidChars : TFieldChars read FValidChars write FValidChars;
    property Value: variant read GetAsVariant write SetAsVariant;
    property OldValue: variant read GetOldValue;
    property LookupList: TLookupList read GetLookupList;
  published
    property Alignment : TAlignment read FAlignment write SetAlignment default taLeftJustify;
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
    property KeyFields: string read FKeyFields write FKeyFields;
    property LookupCache: Boolean read FLookupCache write FLookupCache;
    property LookupDataSet: TDataSet read FLookupDataSet write FLookupDataSet;
    property LookupKeyFields: string read FLookupKeyFields write FLookupKeyFields;
    property LookupResultField: string read FLookupResultField write FLookupResultField;
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
    function GetDataSize: Integer; override;
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
    procedure SetFieldType(AValue: TFieldType); override;
    property FixedChar : Boolean read FFixedChar write FFixedChar;
    property Transliterate: Boolean read FTransliterate write FTransliterate;
    property Value: String read GetAsString write SetAsString;
  published
    property EditMask;
    property Size default 20;
  end;

{ TWideStringField }

  TWideStringField = class(TStringField)
  protected
    class procedure CheckTypeSize(aValue: Integer); override;

    function GetValue(var aValue: WideString): Boolean;

    function GetAsString: string; override;
    procedure SetAsString(const aValue: string); override;
    function getasunicodestring: unicodestring; override;
    procedure setasunicodestring(const avalue: unicodestring); override;

    function GetAsVariant: Variant; override;
    procedure SetVarValue(const aValue: Variant); override;

    function GetAsWideString: WideString; override;
    procedure SetAsWideString(const aValue: WideString); override;

    function GetDataSize: Integer; override;
  public
    constructor Create(aOwner: TComponent); override;
    procedure SetFieldType(AValue: TFieldType); override;
    property Value: WideString read GetAsWideString write SetAsWideString;
  end;


{ TNumericField }
  TNumericField = class(TField)
  Private
    FDisplayFormat : String;
    FEditFormat : String;
  protected
    class procedure CheckTypeSize(AValue: Longint); override;
    procedure RangeError(AValue, Min, Max: Double);
    procedure SetDisplayFormat(const AValue: string);
    procedure SetEditFormat(const AValue: string);
    function  GetAsBoolean: Boolean; override;
    Procedure SetAsBoolean(AValue: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Alignment default taRightJustify;
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
    function GetDataSize: Integer; override;
    procedure GetText(var AText: string; ADisplayText: Boolean); override;
    function GetValue(var AValue: Longint): Boolean;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
    function GetAsLargeint: Largeint; override;
    procedure SetAsLargeint(AValue: Largeint); override;
  public
    constructor Create(AOwner: TComponent); override;
    Function CheckRange(AValue : longint) : Boolean;
    property Value: Longint read GetAsLongint write SetAsLongint;
  published
    property MaxValue: Longint read FMaxValue write SetMaxValue default 0;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
  end;
  TIntegerField = Class(TLongintField);

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
    function GetDataSize: Integer; override;
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
    property Value: Largeint read GetAsLargeint write SetAsLargeint;
  published
    property MaxValue: Largeint read FMaxValue write SetMaxValue default 0;
    property MinValue: Largeint read FMinValue write SetMinValue default 0;
  end;

{ TSmallintField }

  TSmallintField = class(TLongintField)
  protected
    function GetDataSize: Integer; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TWordField }

  TWordField = class(TLongintField)
  protected
    function GetDataSize: Integer; override;
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
    FCurrency: Boolean;
    FMaxValue : Double;
    FMinValue : Double;
    FPrecision : Longint;
    procedure SetCurrency(const AValue: Boolean);
    procedure SetPrecision(const AValue: Longint);
  protected
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsVariant: variant; override;
    function GetAsString: string; override;
    function GetDataSize: Integer; override;
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
    property Currency: Boolean read FCurrency write SetCurrency default False;
    property MaxValue: Double read FMaxValue write FMaxValue;
    property MinValue: Double read FMinValue write FMinValue;
    property Precision: Longint read FPrecision write SetPrecision default 15; // min 2 instellen, delphi compat
  end;

{ TCurrencyField }

  TCurrencyField = class(TFloatField)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Currency default True;
  end;

{ TBooleanField }

  TBooleanField = class(TField)
  private
    FDisplayValues : String;
    // First byte indicates uppercase or not.
    FDisplays : Array[Boolean,Boolean] of string;
    Procedure SetDisplayValues(const AValue : String);
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetAsInteger: Longint; override;
    function GetDataSize: Integer; override;
    function GetDefaultWidth: Longint; override;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsInteger(AValue: Integer); override;
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
    function getasdate: tdatetime; override;
    function getastime: tdatetime; override;
    function GetAsFloat: Double; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Integer; override;
    procedure GetText(var theText: string; ADisplayText: Boolean); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure setasdate(avalue: tdatetime); override;
    procedure setastime(avalue: tdatetime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Value: TDateTime read GetAsDateTime write SetAsDateTime;
  published
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property EditMask;
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
    function GetAsBytes: TBytes; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
    procedure SetAsBytes(const AValue: TBytes); override;
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
    function GetDataSize: Integer; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TVarBytesField }

  TVarBytesField = class(TBytesField)
  protected
    function GetDataSize: Integer; override;
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
    function GetDataSize: Integer; override;
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
    property Value: Currency read GetAscurrency write SetAscurrency;
  published
    property Precision: Longint read FPrecision write FPrecision;
    property Currency: Boolean read FCurrency write FCurrency;
    property MaxValue: Currency read FMaxValue write FMaxValue;
    property MinValue: Currency read FMinValue write FMinValue;
    property Size default 4;
  end;

{ TFMTBCDField }

  TFMTBCDField = class(TNumericField)
  private
    FMinValue,
    FMaxValue   : TBCD;
    FPrecision  : Longint;
    FCurrency   : boolean;
    function GetMaxValue: string;
    function GetMinValue: string;
    procedure SetMaxValue(const AValue: string);
    procedure SetMinValue(const AValue: string);
  protected
    class procedure CheckTypeSize(AValue: Longint); override;
    function GetAsBCD: TBCD; override;
    function GetAsCurrency: Currency; override;
    function GetAsFloat: Double; override;
    function GetAsLongint: Longint; override;
    function GetAsString: string; override;
    function GetAsVariant: variant; override;
    function GetDataSize: Integer; override;
    function GetDefaultWidth: Longint; override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
    procedure SetAsBCD(const AValue: TBCD); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsLongint(AValue: Longint); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsCurrency(AValue: Currency); override;
    procedure SetVarValue(const AValue: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;
    function CheckRange(AValue : TBCD) : Boolean;
    property Value: TBCD read GetAsBCD write SetAsBCD;
  published
    property Precision: Longint read FPrecision write FPrecision default 15;
    property Currency: Boolean read FCurrency write FCurrency;
    property MaxValue: string read GetMaxValue write SetMaxValue;
    property MinValue: string read GetMinValue write SetMinValue;
    property Size default 4;
  end;


{ TBlobField }
  TBlobStreamMode = (bmRead, bmWrite, bmReadWrite);
  TBlobType = ftBlob..ftWideMemo;

  TBlobField = class(TField)
  private
    FBlobType : TBlobType;
    FModified : Boolean;
    FTransliterate : Boolean;
    Function GetBlobStream (Mode : TBlobStreamMode) : TStream;
  protected
    procedure FreeBuffers; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetBlobSize: Longint; virtual;
    function GetIsNull: Boolean; override;
    procedure GetText(var TheText: string; ADisplayText: Boolean); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetText(const AValue: string); override;
    procedure SetVarValue(const AValue: Variant); override;
    function GetAsWideString: WideString; override;
    procedure SetAsWideString(const aValue: WideString); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear; override;
    class function IsBlob: Boolean; override;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SetFieldType(AValue: TFieldType); override;
    property BlobSize: Longint read GetBlobSize;
    property Modified: Boolean read FModified write FModified;
    property Value: string read GetAsString write SetAsString;
    property Transliterate: Boolean read FTransliterate write FTransliterate;
  published
    property BlobType: TBlobType read FBlobType write FBlobType;
    property Size default 0;
  end;

{ TMemoField }

  TMemoField = class(TBlobField)
  protected
    function GetAsWideString: WideString; override;
    procedure SetAsWideString(const aValue: WideString); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Transliterate default True;
  end;

{ TWideMemoField }

  TWideMemoField = class(TBlobField)
  protected
    function GetAsVariant: Variant; override;
    procedure SetVarValue(const AValue: Variant); override;

    function GetAsString: string; override;
    procedure SetAsString(const aValue: string); override;
  public
    constructor Create(aOwner: TComponent); override;
    property Value: WideString read GetAsWideString write SetAsWideString;
  published
  end;


{ TGraphicField }

  TGraphicField = class(TBlobField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TVariantField }

  TVariantField = class(TField)
  protected
    class procedure CheckTypeSize(aValue: Integer); override;

    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(aValue: Boolean); override;

    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(aValue: TDateTime); override;

    function GetAsFloat: Double; override;
    procedure SetAsFloat(aValue: Double); override;

    function GetAsInteger: Longint; override;
    procedure SetAsInteger(aValue: Longint); override;

    function GetAsString: string; override;
    procedure SetAsString(const aValue: string); override;

    function GetAsWideString: WideString; override;
    procedure SetAsWideString(const aValue: WideString); override;
    function getasunicodestring: unicodestring; override;
    procedure setasunicodestring(const avalue: unicodestring); override;

    function GetAsVariant: Variant; override;
    procedure SetVarValue(const aValue: Variant); override;

    function GetDefaultWidth: Integer; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TGuidField }

  TGuidField = class(TStringField)
  protected
    class procedure CheckTypeSize(AValue: Longint); override;
    function GetDefaultWidth: Longint; override;

    function GetAsGuid: TGUID; override;
    procedure SetAsGuid(const aValue: TGUID); override;
  public
    constructor Create(AOwner: TComponent); override;
//    property AsGuid: TGUID read GetAsGuid write SetAsGuid;
  end;

{ TIndexDef }

  TIndexDefs = class;

  TIndexOption = (ixPrimary, ixUnique, ixDescending, ixCaseInsensitive,
    ixExpression, ixNonMaintained);
  TIndexOptions = set of TIndexOption;

  TIndexDef = class(TNamedItem)
  Private
    FCaseinsFields: string;
    FDescFields: string;
    FExpression : String;
    FFields : String;
    FOptions : TIndexOptions;
    FSource : String;
  protected
    function GetExpression: string;
    procedure SetCaseInsFields(const AValue: string); virtual;
    procedure SetDescFields(const AValue: string);
    procedure SetExpression(const AValue: string);
  public
    constructor Create(Owner: TIndexDefs; const AName, TheFields: string;
      TheOptions: TIndexOptions); overload;
    procedure Assign(Source: TPersistent); override;
    property Expression: string read GetExpression write SetExpression;
    property Fields: string read FFields write FFields;
    property CaseInsFields: string read FCaseinsFields write SetCaseInsFields;
    property DescFields: string read FDescFields write SetDescFields;
    property Options: TIndexOptions read FOptions write FOptions;
    property Source: string read FSource write FSource;
  end;

{ TIndexDefs }

  TIndexDefs = class(TDefCollection)
  Private
    Function  GetItem(Index: Integer): TIndexDef;
    Procedure SetItem(Index: Integer; Value: TIndexDef);
  public
    constructor Create(ADataSet: TDataSet); overload; virtual;
    procedure Add(const Name, Fields: string; Options: TIndexOptions);
    Function AddIndexDef: TIndexDef;
    function Find(const IndexName: string): TIndexDef;
    function FindIndexForFields(const Fields: string): TIndexDef;
    function GetIndexForFields(const Fields: string;
      CaseInsensitive: Boolean): TIndexDef;
    procedure Update; overload; virtual;
    Property Items[Index: Integer] : TIndexDef read GetItem write SetItem; default;
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

  { TFieldsEnumerator }

  TFieldsEnumerator = class
  private
    FPosition: Integer;
    FFields: TFields;
    function GetCurrent: TField;
  public
    constructor Create(AFields: TFields);
    function MoveNext: Boolean;
    property Current: TField read GetCurrent;
  end;

{ TFields }

  Tfields = Class(TObject)
    Private
      FDataset : TDataset;
      FFieldList : TFpList;
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
      Function GetEnumerator: TFieldsEnumerator;
      Procedure GetFieldNames (Values : TStrings);
      Function IndexOf(Field : TField) : Longint;
      procedure Remove(Value : TField);
      Property Count : Integer Read GetCount;
      Property Dataset : TDataset Read FDataset;
      Property Fields [Index : Integer] : TField Read GetField Write SetField; default;
    end;


  { TParam }

  TBlobData = AnsiString;  // Delphi defines it as alias to TBytes

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
    FParamType: TParamType;
    FSize: Integer;
    Function GetDataSet: TDataSet;
    Function IsParamStored: Boolean;
  protected
    FBound: Boolean;
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
    Function GetAsFMTBCD: TBCD;
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
    Procedure SetAsFMTBCD(const AValue: TBCD);
    Procedure SetDataType(AValue: TFieldType);
    Procedure SetText(const AValue: string);
    function GetAsWideString: WideString;
    procedure SetAsWideString(const aValue: WideString);
    function getasunicodestring: unicodestring;
    procedure setasunicodestring(const avalue: unicodestring);
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
    Property AsFMTBCD: TBCD read GetAsFMTBCD write SetAsFMTBCD;
    Property Bound : Boolean read FBound write FBound;
    Property Dataset : TDataset Read GetDataset;
    Property IsNull : Boolean read GetIsNull;
    Property NativeStr : string read FNativeStr write FNativeStr;
    Property Text : string read GetAsString write SetText;
    Property Value : Variant read GetAsVariant write SetAsVariant stored IsParamStored;
    property AsWideString: WideString read GetAsWideString write SetAsWideString;
    property asunicodestring: unicodestring read getasunicodestring 
                                                       write setasunicodestring;
    property asmsestring: msestring read getasunicodestring 
                                                  write setasunicodestring;
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
    Function  ParseSQL(SQL: String; DoCreate: Boolean): String; overload;
    Function  ParseSQL(SQL: String; DoCreate, EscapeSlash, EscapeRepeat : Boolean; ParameterStyle : TParamStyle): String; overload;
    Function  ParseSQL(SQL: String; DoCreate, EscapeSlash, EscapeRepeat : Boolean; ParameterStyle : TParamStyle; var ParamBinding: TParambinding): String; overload;
    Function  ParseSQL(SQL: String; DoCreate, EscapeSlash, EscapeRepeat : Boolean; ParameterStyle : TParamStyle; var ParamBinding: TParambinding; var ReplaceString : string): String; overload;
    Procedure RemoveParam(Value: TParam);
    Procedure CopyParamValuesFromDataset(ADataset : TDataset; CopyBound : Boolean);
    Property Dataset : TDataset Read GetDataset;
    Property Items[Index: Integer] : TParam read GetItem write SetItem; default;
    Property ParamValues[const ParamName: string] : Variant read GetParamValue write SetParamValue;
  end;

{ TDataSet }

  TBookmark = Pointer;
  TBookmarkStr = string; 

  PBookmarkFlag = ^TBookmarkFlag;
  TBookmarkFlag = (bfCurrent, bfBOF, bfEOF, bfInserted);

{ These types are used by Delphi/Unicode to replace the ambiguous "pchar" buffer types.
  For now, they are just aliases to PAnsiChar, but in Delphi/Unicode it is pbyte. This will
  be changed later (2.8?), to allow a grace period for descendents to catch up.
  
  Testing with TRecordBuffer=PByte will turn up typing problems. TRecordBuffer=pansichar is backwards
  compatible, even if overriden with "pchar" variants.
}
  TRecordBufferBaseType = AnsiChar; // must match TRecordBuffer. 
  TRecordBuffer = PAnsiChar;
  PBufferList = ^TBufferList;
  TBufferList = array[0..dsMaxBufferCount - 1] of TRecordBuffer;  // Dynamic array in Delphi.
  TBufferArray = ^TRecordBuffer;
  bufferaty = array[0..1] of trecordbuffer;
  pbufferaty = ^bufferaty;
  
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

  TFilterOption = (foCaseInsensitive, foNoPartialCompare);
  TFilterOptions = set of TFilterOption;

  TFilterRecordEvent = procedure(DataSet: TDataSet;
    var Accept: Boolean) of object;

  TDatasetClass = Class of TDataset;


{------------------------------------------------------------------------------}
{IProviderSupport interface}

  TPSCommandType = (
    ctUnknown,
    ctQuery,
    ctTable,
    ctStoredProc,
    ctSelect,
    ctInsert,
    ctUpdate,
    ctDelete,
    ctDDL
  );

  IProviderSupport = interface
    procedure PSEndTransaction(ACommit: Boolean);
    procedure PSExecute;
    function PSExecuteStatement(const ASQL: string; AParams: TParams;
                                ResultSet: Pointer = nil): Integer;
    procedure PSGetAttributes(List: TList);
    function PSGetCommandText: string;
    function PSGetCommandType: TPSCommandType;
    function PSGetDefaultOrder: TIndexDef;
    function PSGetIndexDefs(IndexTypes: TIndexOptions = [ixPrimary..ixNonMaintained])
                                : TIndexDefs;
    function PSGetKeyFields: string;
    function PSGetParams: TParams;
    function PSGetQuoteChar: string;
    function PSGetTableName: string;
    function PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError;
    function PSInTransaction: Boolean;
    function PSIsSQLBased: Boolean;
    function PSIsSQLSupported: Boolean;
    procedure PSReset;
    procedure PSSetCommandText(const CommandText: string);
    procedure PSSetParams(AParams: TParams);
    procedure PSStartTransaction;
    function PSUpdateRecord(UpdateKind: TUpdateKind; Delta: TDataSet): Boolean;
  end;
{------------------------------------------------------------------------------}

  TDataSet = class(TComponent)
  Private
    Procedure DoInsertAppend(DoAppend : Boolean);
    Procedure DoInternalOpen;
    Function  GetBuffer (Index : longint) : TRecordBuffer;
    Function  GetField (Index : Longint) : TField;
    Procedure RegisterDataSource(ADatasource : TDataSource);
    Procedure RemoveField (Field : TField);
    procedure SetConstraints(Value: TCheckConstraints);
    Procedure SetField (Index : Longint;Value : TField);
    Procedure ShiftBuffersForward;
    Procedure ShiftBuffersBackward;
    Function  TryDoing (P : TDataOperation; Ev : TDatasetErrorEvent) : Boolean;
    Procedure UnRegisterDataSource(ADatasource : TDatasource);
    Procedure UpdateFieldDefs;
    procedure SetBlockReadSize(AValue: Integer); virtual;
    Procedure SetFieldDefs(AFieldDefs: TFieldDefs);
    procedure DoInsertAppendRecord(const Values: array of const; DoAppend : boolean);
  protected
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
    FBlockReadSize: Integer;
    FBookmarkSize: Longint;
    FBuffers : TBufferArray;
    FBufferCount: Longint;
    FCalcBuffer: TRecordBuffer;
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
    FInternalOpenComplete: Boolean;
    Function GetActive : boolean;
    procedure RecalcBufListSize;
    procedure ActivateBuffers; virtual;
    procedure BindFields(Binding: Boolean);
    procedure BlockReadNext; virtual;
    function  BookmarkAvailable: Boolean;
    procedure CalculateFields(Buffer: TRecordBuffer); virtual;
    procedure CheckActive; virtual;
    procedure CheckInactive; virtual;
    procedure CheckBiDirectional;
    procedure Loaded; override;
    procedure ClearBuffers; virtual;
    procedure ClearCalcFields(Buffer: TRecordBuffer); virtual;
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
    procedure GetCalcFields(Buffer: TRecordBuffer); virtual;
    function  GetCanModify: Boolean; virtual;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function  GetFieldClass(FieldType: TFieldType): TFieldClass; virtual;
    Function  GetfieldCount : Integer;
    function  GetFieldValues(const fieldname : string) : Variant; virtual;
    function  GetIsIndexField(Field: TField): Boolean; virtual;
    function  GetIndexDefs(IndexDefs : TIndexDefs; IndexTypes : TIndexOptions) : TIndexDefs;
    function  GetNextRecords: Longint; virtual;
    function  GetNextRecord: Boolean; virtual;
    function  GetPriorRecords: Longint; virtual;
    function  GetPriorRecord: Boolean; virtual;
    function  GetRecordCount: Longint; virtual;
    function  GetRecNo: Longint; virtual;
    procedure InitFieldDefs; virtual;
    procedure InitFieldDefsFromfields;
    procedure InitRecord(Buffer: TRecordBuffer); virtual;
    procedure InternalCancel; virtual;
    procedure InternalEdit; virtual;
    procedure InternalInsert; virtual;
    procedure InternalRefresh; virtual;
    procedure OpenCursor(InfoQuery: Boolean); virtual;
    procedure OpenCursorcomplete; virtual;
    procedure RefreshInternalCalcFields(Buffer: TRecordBuffer); virtual;
    procedure RestoreState(const Value: TDataSetState);
    Procedure SetActive (Value : Boolean); virtual;
    procedure SetBookmarkStr(const Value: TBookmarkStr); virtual;
    procedure SetBufListSize(Value: Longint); virtual;
    procedure SetChildOrder(Component: TComponent; Order: Longint); override;
    procedure SetCurrentRecord(Index: Longint); virtual;
    procedure SetDefaultFields(const Value: Boolean);
    procedure SetFiltered(Value: Boolean); virtual;
    procedure SetFilterOptions(Value: TFilterOptions); virtual;
    procedure SetFilterText(const Value: string); virtual;
    procedure SetFieldValues(const fieldname: string; Value: Variant); virtual;
    procedure SetFound(const Value: Boolean); virtual;
    procedure SetModified(Value: Boolean);
    procedure SetName(const Value: TComponentName); override;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); virtual;
    procedure SetRecNo(Value: Longint); virtual;
    procedure SetState(Value: TDataSetState);
    function SetTempState(const Value: TDataSetState): TDataSetState;
    Function Tempbuffer: TRecordBuffer;
    procedure UpdateIndexDefs; virtual;
    property ActiveRecord: Longint read FActiveRecord;
    property CurrentRecord: Longint read FCurrentRecord;
    property BlobFieldCount: Longint read FBlobFieldCount;
    property BookmarkSize: Longint read FBookmarkSize write FBookmarkSize;
    property Buffers[Index: Longint]: TRecordBuffer read GetBuffer;
    property BufferCount: Longint read FBufferCount;
    property CalcBuffer: TRecordBuffer read FCalcBuffer;
    property CalcFieldsSize: Longint read FCalcFieldsSize;
    property InternalCalcFields: Boolean read FInternalCalcFields;
    property Constraints: TCheckConstraints read FConstraints write SetConstraints;
    function AllocRecordBuffer: TRecordBuffer; virtual;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); virtual;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); virtual;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; virtual;
    function GetDataSource: TDataSource; virtual;
    function GetRecordSize: Word; virtual;
    procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); virtual;
    procedure InternalDelete; virtual;
    procedure InternalFirst; virtual;
    procedure InternalGotoBookmark(ABookmark: Pointer); virtual;
    procedure InternalHandleException; virtual;
    procedure InternalInitRecord(Buffer: TRecordBuffer); virtual;
    procedure InternalLast; virtual;
    procedure InternalPost; virtual;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); virtual;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); virtual;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); virtual;
    procedure SetUniDirectional(const Value: Boolean);
  protected { abstract methods }
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; virtual; abstract;
    procedure InternalClose; virtual; abstract;
    procedure InternalOpen; virtual; abstract;
    procedure InternalInitFieldDefs; virtual; abstract;
    function IsCursorOpen: Boolean; virtual; abstract;
  protected { IProviderSupport methods }
    procedure PSEndTransaction(Commit: Boolean); virtual;
    procedure PSExecute; virtual;
    function PSExecuteStatement(const ASQL: string; AParams: TParams;
                                ResultSet: Pointer = nil): Integer; virtual;
    procedure PSGetAttributes(List: TList); virtual;
    function PSGetCommandText: string; virtual;
    function PSGetCommandType: TPSCommandType; virtual;
    function PSGetDefaultOrder: TIndexDef; virtual;
    function PSGetIndexDefs(IndexTypes: TIndexOptions = [ixPrimary..ixNonMaintained])
                                : TIndexDefs; virtual;
    function PSGetKeyFields: string; virtual;
    function PSGetParams: TParams; virtual;
    function PSGetQuoteChar: string; virtual;
    function PSGetTableName: string; virtual;
    function PSGetUpdateException(E: Exception; Prev: EUpdateError)
                                : EUpdateError; virtual;
    function PSInTransaction: Boolean; virtual;
    function PSIsSQLBased: Boolean; virtual;
    function PSIsSQLSupported: Boolean; virtual;
    procedure PSReset; virtual;
    procedure PSSetCommandText(const CommandText: string); virtual;
    procedure PSSetParams(AParams: TParams); virtual;
    procedure PSStartTransaction; virtual;
    function PSUpdateRecord(UpdateKind: TUpdateKind; Delta: TDataSet)
                                : Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ActiveBuffer: TRecordBuffer;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; overload; virtual;
    function GetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean): Boolean; overload; virtual;
    procedure SetFieldData(Field: TField; Buffer: Pointer); overload; virtual;
    procedure SetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean); overload; virtual;
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
    procedure DataConvert(aField: TField; aSource, aDest: Pointer; aToNative: Boolean); virtual;
    procedure Delete;
    procedure DisableControls;
    procedure Edit;
    procedure EnableControls;
    function FieldByName(const FieldName: string): TField;
    function FindField(const FieldName: string): TField;
    function FindFirst: Boolean; virtual;
    function FindLast: Boolean; virtual;
    function FindNext: Boolean; virtual;
    function FindPrior: Boolean; virtual;
    procedure First;
    procedure FreeBookmark(ABookmark: TBookmark); virtual;
    function GetBookmark: TBookmark; virtual;
    function GetCurrentRecord(Buffer: TRecordBuffer): Boolean; virtual;
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
    property BlockReadSize: Integer read FBlockReadSize write SetBlockReadSize;
    property BOF: Boolean read FBOF;
    property Bookmark: TBookmarkStr read GetBookmarkStr write SetBookmarkStr;
    property CanModify: Boolean read GetCanModify;
    property DataSource: TDataSource read GetDataSource;
    property DefaultFields: Boolean read FDefaultFields;
    property EOF: Boolean read FEOF;
    property FieldCount: Longint read GetFieldCount;
    property FieldDefs: TFieldDefs read FFieldDefs write SetFieldDefs;
//    property Fields[Index: Longint]: TField read GetField write SetField;
    property Found: Boolean read FFound;
    property Modified: Boolean read FModified;
    property IsUniDirectional: Boolean read FIsUniDirectional default False;
    property RecordCount: Longint read GetRecordCount;
    property RecNo: Longint read GetRecNo write SetRecNo;
    property RecordSize: Word read GetRecordSize;
    property State: TDataSetState read FState;
    property Fields : TFields read FFieldList;
    property FieldValues[const fieldname: string] : Variant read GetFieldValues
                                        write SetFieldValues; default;
    property Filter: string read FFilterText write SetFilterText;
    property Filtered: Boolean read FFiltered write SetFiltered default False;
    property FilterOptions: TFilterOptions read FFilterOptions write SetFilterOptions;
    property Active: Boolean read GetActive write SetActive default False;
    property AutoCalcFields: Boolean read FAutoCalcFields write FAutoCalcFields default true;
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
    FFirstRecord,
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
//    procedure doenter(const aobject: tobject);
//    procedure doexit(const aobject: tobject);
  public
    constructor Create;
    destructor Destroy; override;
    function  Edit: Boolean;
    procedure UpdateRecord;
    function ExecuteAction(Action: TBasicAction): Boolean; virtual;
    function UpdateAction(Action: TBasicAction): Boolean; virtual;
    property Active: Boolean read FActive;
    property ActiveRecord: Integer read GetActiveRecord write SetActiveRecord;
    property BOF: Boolean read GetBOF;
    property BufferCount: Integer read GetBufferCount write SetBufferCount;
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

  ifistatechangedeventty = procedure(const sender: tdatasource;
                   const alink: tdatalink; const aclient: iificlient;
                   const astate: ifiwidgetstatesty) of object;
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
//    fonenter: datasourcelinkobjecteventty;
//    fonexit: datasourcelinkobjecteventty;
   fonifistatechanged: ifistatechangedeventty;
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
    procedure ifistatechanged(const sender: tdatalink;
                            const aclient: iificlient;
                            const astate: ifiwidgetstatesty); virtual;
//    procedure doenter(const alink: tdatalink; const aobject: tobject);
//    procedure doexit(const alink: tdatalink; const aobject: tobject);
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
    property onifistatechanged: ifistatechangedeventty 
                           read fonifistatechanged write fonifistatechanged;
//    property onenter: datasourcelinkobjecteventty read fonenter write fonenter;
//    property onexit: datasourcelinkobjecteventty read fonexit write fonexit;
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

    { TCustomConnection }

  TLoginEvent = procedure(Sender: TObject; Username, Password: string) of object;

  TCustomConnection = class(TComponent)
  private
    FAfterConnect: TNotifyEvent;
    FAfterDisconnect: TNotifyEvent;
    FBeforeConnect: TNotifyEvent;
    FBeforeDisconnect: TNotifyEvent;
    FLoginPrompt: Boolean;
    FOnLogin: TLoginEvent;
    FStreamedConnected: Boolean;
    procedure SetAfterConnect(const AValue: TNotifyEvent);
    procedure SetAfterDisconnect(const AValue: TNotifyEvent);
    procedure SetBeforeConnect(const AValue: TNotifyEvent);
    procedure SetBeforeDisconnect(const AValue: TNotifyEvent);
  protected
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    function GetConnected : boolean; virtual;
    Function GetDataset(Index : longint) : TDataset; virtual;
    Function GetDataSetCount : Longint; virtual;
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
    procedure SetConnected (Value : boolean); virtual;
    property Streamedconnected: Boolean read FStreamedConnected write FStreamedConnected;
  public
    procedure Close;
    destructor Destroy; override;
    procedure Open;
    property DataSetCount: Longint read GetDataSetCount;
    property DataSets[Index: Longint]: TDataSet read GetDataSet;
  published
    property Connected: Boolean read GetConnected write SetConnected;
    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt;

    property AfterConnect : TNotifyEvent read FAfterConnect write SetAfterConnect;
    property AfterDisconnect : TNotifyEvent read FAfterDisconnect write SetAfterDisconnect;
    property BeforeConnect : TNotifyEvent read FBeforeConnect write SetBeforeConnect;
    property BeforeDisconnect : TNotifyEvent read FBeforeDisconnect write SetBeforeDisconnect;
    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
  end;


  { TDatabase }

  TDatabaseClass = Class Of TDatabase;

  TDatabase = class(TCustomConnection)
  private
    FConnected : Boolean;
    FDataBaseName : String;
    FDataSets : TList;
    FTransactions : TList;
    FDirectory : String;
    FKeepConnection : Boolean;
    FParams : TStrings;
    FSQLBased : Boolean;
    FOpenAfterRead : boolean;
    Function GetTransactionCount : Longint;
    Function GetTransaction(Index : longint) : TDBTransaction;
    procedure RegisterDataset (DS : TDBDataset);
    procedure RegisterTransaction (TA : TDBTransaction);
    procedure UnRegisterDataset (DS : TDBDataset);
    procedure UnRegisterTransaction(TA : TDBTransaction);
    procedure RemoveDataSets;
    procedure RemoveTransactions;
    procedure SetParams(AValue: TStrings);
  protected
    Procedure CheckConnected;
    Procedure CheckDisConnected;
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    function GetConnected : boolean; override;
    Function GetDataset(Index : longint) : TDataset; override;
    Function GetDataSetCount : Longint; override;
    Procedure DoInternalConnect; Virtual;Abstract;
    Procedure DoInternalDisConnect; Virtual;Abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseDataSets;
    procedure CloseTransactions;
//    procedure ApplyUpdates;
    procedure StartTransaction; virtual; abstract;
    procedure EndTransaction; virtual; abstract;
    property TransactionCount: Longint read GetTransactionCount;
    property Transactions[Index: Longint]: TDBTransaction read GetTransaction;
    property Directory: string read FDirectory write FDirectory;
    property IsSQLBased: Boolean read FSQLBased;
  published
    property Connected: Boolean read FConnected write SetConnected;
    property DatabaseName: string read FDatabaseName write FDatabaseName;
    property KeepConnection: Boolean read FKeepConnection write FKeepConnection;
    property Params : TStrings read FParams Write SetParams;
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
    varOleStr, varOleStr, varVariant, varUnknown, varDispatch, varOleStr,
    varOleStr, varDouble, varOleStr,varOleStr);


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
      'FMTBcd',
      'FixedWideChar',
      'WideMemo'
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
      { ftWord} TWordField,
      { ftBoolean} TBooleanField,
      { ftFloat} TFloatField,
      { ftCurrency} TCurrencyField,
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
      { ftFmtMemo} TBlobField,
      { ftParadoxOle} TBlobField,
      { ftDBaseOle} TBlobField,
      { ftTypedBinary} TBlobField,
      { ftCursor} Nil,
      { ftFixedChar} TStringField,
      { ftWideString} TWideStringField,
      { ftLargeint} TLargeIntField,
      { ftADT} Nil,
      { ftArray} Nil,
      { ftReference} Nil,
      { ftDataSet} Nil,
      { ftOraBlob} TBlobField,
      { ftOraClob} TMemoField,
      { ftVariant} TVariantField,
      { ftInterface} Nil,
      { ftIDispatch} Nil,
      { ftGuid} TGuidField,
      { ftTimeStamp} Nil,
      { ftFMTBcd} TFMTBCDField,
      { ftFixedWideString} TWideStringField,
      { ftWideMemo} TWideMemoField
    );

  dsEditModes = [dsEdit, dsInsert, dsSetKey];
  dsWriteModes = [dsEdit, dsInsert, dsSetKey, dsCalcFields, dsFilter,
    dsNewValue, dsInternalCalc];

{ Auxiliary functions }

Procedure DatabaseError (Const Msg : String); overload;
Procedure DatabaseError (Const Msg : String; Comp : TComponent); overload;
Procedure DatabaseErrorFmt (Const Fmt : String; Args : Array Of Const); overload;
Procedure DatabaseErrorFmt (Const Fmt : String; Args : Array Of const; Comp : TComponent); overload;
Function ExtractFieldName(Const Fields: String; var Pos: Integer): String;
Function DateTimeRecToDateTime(DT: TFieldType; Data: TDateTimeRec): TDateTime;
Function DateTimeToDateTimeRec(DT: TFieldType; Data: TDateTime): TDateTimeRec;

procedure DisposeMem(var Buffer; Size: Integer);
function BuffersEqual(Buf1, Buf2: Pointer; Size: Integer): Boolean;

function SkipComments(var p: PChar; EscapeSlash, EscapeRepeat : Boolean) : boolean;

implementation

uses
 {$ifdef FPC}dbconst{$else}dbconst_del{$endif},typinfo;
resourcestring
 sassigndate = 'Can not assign a date value to field "%s"';
 sassigntime = 'Can not assign a time value to field "%s"';
 
{ ---------------------------------------------------------------------
    Auxiliary functions
  ---------------------------------------------------------------------}

Procedure DatabaseError (Const Msg : String);

begin
  Raise EDataBaseError.Create(Msg);
end;

Procedure DatabaseError (Const Msg : String; Comp : TComponent);

begin
  if assigned(Comp) and (Comp.Name <> '') then
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

function ExtractFieldName(const Fields: string; var Pos: Integer): string;
var
  i: Integer;
  FieldsLength: Integer;
begin
  i:=Pos;
  FieldsLength:=Length(Fields);
  while (i<=FieldsLength) and (Fields[i]<>';') do Inc(i);
  Result:=Trim(Copy(Fields,Pos,i-Pos));
  if (i<=FieldsLength) and (Fields[i]=';') then Inc(i);
  Pos:=i;
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
  Inherited;
end;

{ TNamedItem }

function TNamedItem.GetDisplayName: string;
begin
  Result := FName;
end;

procedure TNamedItem.SetDisplayName(const AValue: string);
Var TmpInd : Integer;
begin
  if FName=AValue then exit;
  if (AValue <> '') and (Collection is TFieldDefs) then
    begin
    TmpInd :=  (TDefCollection(Collection).IndexOf(AValue));
    if (TmpInd >= 0) and (TmpInd <> Index) then
      DatabaseErrorFmt(SDuplicateName, [AValue, Collection.ClassName]);
    end;
  FName:=AValue;
  inherited SetDisplayName(AValue);
end;

{ TDefCollection }

procedure TDefCollection.SetItemName(AItem: TCollectionItem);
begin
  with AItem as TNamedItem do
    if Name = '' then
      begin
      if assigned(Dataset) then
        Name := Dataset.Name + Copy(ClassName, 2, 5) + IntToStr(ID+1)
      else
        Name := Copy(ClassName, 2, 5) + IntToStr(ID+1);
      end
  else inherited SetItemName(AItem);
end;

constructor TDefCollection.create(ADataset: TDataset; AOwner: TPersistent;
  AClass: TCollectionItemClass);
begin
  inherited Create(AOwner,AClass);
  FDataset := ADataset;
end;

function TDefCollection.Find(const AName: string): TNamedItem;
var i: integer;
begin
  Result := Nil;
  for i := 0 to Count - 1 do if AnsiSameText(TNamedItem(Items[i]).Name, AName) then
    begin
    Result := TNamedItem(Items[i]);
    Break;
    end;
end;

procedure TDefCollection.GetItemNames(List: TStrings);
var i: LongInt;
begin
  for i := 0 to Count - 1 do
    List.Add(TNamedItem(Items[i]).Name);
end;

function TDefCollection.IndexOf(const AName: string): Longint;
var i: LongInt;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if AnsiSameText(TNamedItem(Items[i]).Name, AName) then
    begin
    Result := i;
    Break;
    end;
end;

{ TIndexDef }

procedure TIndexDef.SetDescFields(const AValue: string);
begin
  if FDescFields=AValue then exit;
  if AValue <> '' then FOptions:=FOptions + [ixDescending];
  FDescFields:=AValue;
end;

procedure TIndexDef.Assign(Source: TPersistent);
var idef : TIndexDef;
begin
  idef := nil;
  if Source is TIndexDef then idef := Source as TIndexDef;
  if Assigned(idef) then
     begin
     FName := idef.Name;
     FFields := idef.Fields;
     FOptions := idef.Options;
     FCaseinsFields := idef.CaseInsFields;
     FDescFields := idef.DescFields;
     FSource := idef.Source;
     FExpression := idef.Expression;
     end
  else
    inherited Assign(Source);
end;

function TIndexDef.GetExpression: string;
begin
  Result := FExpression;
end;

procedure TIndexDef.SetExpression(const AValue: string);
begin
  FExpression := AValue;
end;

procedure TIndexDef.SetCaseInsFields(const AValue: string);
begin
  if FCaseinsFields=AValue then exit;
  if AValue <> '' then FOptions:=FOptions + [ixCaseInsensitive];
  FCaseinsFields:=AValue;
end;

constructor TIndexDef.Create(Owner: TIndexDefs; const AName, TheFields: string;
      TheOptions: TIndexOptions);

begin
  FName := aname;
  inherited create(Owner);
  FFields := TheFields;
  FOptions := TheOptions;
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

constructor TIndexDefs.Create(ADataSet: TDataSet);

begin
  inherited create(ADataset, Owner, TIndexDef);
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

function TIndexDefs.Find(const IndexName: string): TIndexDef;
begin
  Result := (inherited Find(IndexName)) as TIndexDef;
  if (Result=Nil) Then
    DatabaseErrorFmt(SIndexNotFound, [IndexName], FDataSet);
end;

function TIndexDefs.FindIndexForFields(const Fields: string): TIndexDef;

begin
 result:= nil;
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

procedure TIndexDefs.Update;

begin
  if (not updated) and assigned(Dataset) then
    begin
    Dataset.UpdateIndexDefs;
    updated := True;
    end;
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
  Result := nil;
end;


Procedure TCheckConstraints.SetItem(index : Longint; Value : TCheckConstraint);

begin
  //!! To be implemented
end;


function TCheckConstraints.GetOwner: TPersistent;

begin
  //!! To be implemented
  Result := nil;
end;


constructor TCheckConstraints.Create(AOwner: TPersistent);

begin
  //!! To be implemented
  inherited Create(TCheckConstraint);
end;


function TCheckConstraints.Add: TCheckConstraint;

begin
  //!! To be implemented
  Result := nil;
end;

{ TLookupList }

constructor TLookupList.Create;

begin
  FList := TFPList.Create;
end;

destructor TLookupList.Destroy;

begin
  Clear;
  FList.Destroy;
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

function TLookupList.FirstKeyByValue(const AValue: Variant): Variant;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    with PLookupListRec(FList[i])^ do
      if Value = AValue then
        begin
        Result := Key;
        exit;
        end;
  Result := Null;
end;

function TLookupList.ValueOfKey(const AKey: Variant): Variant;

  Function VarArraySameValues(VarArray1,VarArray2 : Variant) : Boolean;
  // This only works for one-dimensional vararrays with a lower bound of 0
  // and equal higher bounds wich only contains variants.
  // The vararrays returned by GetFieldValues do apply.
  var i : integer;
  begin
    Result := True;
    if (VarArrayHighBound(VarArray1,1))<> (VarArrayHighBound(VarArray2,1)) then exit;
    for i := 0 to VarArrayHighBound(VarArray1,1) do
    begin
      if VarArray1[i]<>VarArray2[i] then
        begin
        Result := false;
        Exit;
        end;
    end;
  end;

var I: Integer;
begin
  Result := Null;
  if VarIsNull(AKey) then Exit;
  i := FList.Count - 1;
  if VarIsArray(AKey) then
    while (i >= 0) And not VarArraySameValues(PLookupListRec(FList.Items[I])^.Key,AKey) do Dec(i)
  else
    while (i >= 0) And (PLookupListRec(FList.Items[I])^.Key <> AKey) do Dec(i);
  if i >= 0 then Result := PLookupListRec(FList.Items[I])^.Value;
end;

procedure TLookupList.ValuesToStrings(AStrings: TStrings);
var
  i: Integer;
  p: PLookupListRec;
begin
  AStrings.Clear;
  for i := 0 to FList.Count - 1 do
    begin
    p := PLookupListRec(FList[i]);
    AStrings.AddObject(p^.Value, TObject(p));
    end;
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
 {$ifdef FPC}
  Result:= CompareByte(Buf1,Buf2,Size) = 0;
 {$else}
  Result:= Comparemem(Buf1,Buf2,Size);
 {$endif}
end;

{ ---------------------------------------------------------------------
    TDataSet
  ---------------------------------------------------------------------}

Const
  DefaultBufferCount = 10;

constructor TDataSet.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FFieldDefs:=TFieldDefs.Create(Self);
  FFieldList:=TFields.Create(Self);
  FDataSources:=TList.Create;
  FConstraints:=TCheckConstraints.Create(Self);
  
// FBuffer must be allocated on create, to make Activebuffer return nil
  ReAllocMem(FBuffers,SizeOf(TRecordBuffer));
//  pointer(FBuffers^) := nil;
  pbufferaty(FBuffers)^[0] := nil;
  FActiveRecord := 0;
  FBufferCount := -1;
  FEOF := True;
  FBOF := True;
  FIsUniDirectional := False;
  FAutoCalcFields := True;
end;



destructor TDataSet.Destroy;

var
  i: Integer;

begin
  Active:=False;
  FFieldDefs.Free;
  FFieldList.Free;
  With FDatasources do
    begin
    While Count>0 do
      TDatasource(Items[Count - 1]).DataSet:=Nil;
    Free;
    end;
  for i := 0 to FBufferCount do
    FreeRecordBuffer(pbufferaty(FBuffers)^[i]);
  FConstraints.Free;
  FreeMem(FBuffers);
  Inherited Destroy;
end;

// This procedure must be called when the first record is made/read
Procedure TDataset.ActivateBuffers;

begin
  FBOF:=False;
  FEOF:=False;
  FActiveRecord:=0;
end;

Procedure TDataset.UpdateFieldDefs;

begin
  //!! To be implemented
end;

Procedure TDataset.BindFields(Binding: Boolean);

var i, FieldIndex: Integer;
    FieldDef: TFieldDef;
begin
  { FieldNo is set to -1 for calculated/lookup fields, to 0 for unbound field
    and for bound fields it is set to FieldDef.FieldNo }
  FCalcFieldsSize := 0;
  FBlobFieldCount := 0;
  for i := 0 to Fields.Count - 1 do
    with Fields[i] do begin
      if Binding then begin
        if FieldKind in [fkCalculated, fkLookup] then begin
          FFieldNo := -1;
          FOffset := FCalcFieldsSize;
          Inc(FCalcFieldsSize, DataSize + 1);
          if FieldKind in [fkLookup] then begin
            if ((FLookupDataSet = nil) or (FLookupKeyFields = '') or
               (FLookupResultField = '') or (FKeyFields = '')) then
              DatabaseErrorFmt(SLookupInfoError, [DisplayName]);
            FFields.CheckFieldNames(FKeyFields);
            FLookupDataSet.Open;
            FLookupDataSet.Fields.CheckFieldNames(FLookupKeyFields);
            FLookupDataSet.FieldByName(FLookupResultField);
            if FLookupCache then RefreshLookupList;
          end
        end else begin
          FieldDef := nil;
          FieldIndex := FieldDefs.IndexOf(Fields[i].FieldName);
          if FieldIndex <> -1 then begin
            FieldDef := FieldDefs[FieldIndex];
            FFieldNo := FieldDef.FieldNo;
            if FieldDef.InternalCalcField then FInternalCalcFields := True;
            if IsBlob then begin
              FSize := FieldDef.Size;
              FOffset := FBlobFieldCount;
              Inc(FBlobFieldCount);
            end;
          end else FFieldNo := 0;
        end;
      end else FFieldNo := 0;
    end;
end;

Function TDataset.BookmarkAvailable: Boolean;

Const BookmarkStates = [dsBrowse,dsEdit,dsInsert];

begin
  Result:=(Not IsEmpty) and  not FIsUniDirectional and (State in BookmarkStates)
          and (getBookMarkFlag(ActiveBuffer)=bfCurrent);
end;

Procedure TDataset.CalculateFields(Buffer: TRecordBuffer);
var
  i: Integer;
  OldState: TDatasetState;
begin
  FCalcBuffer := Buffer; 
  if not IsUniDirectional and (FState <> dsInternalCalc) then
  begin
    OldState := FState;
    FState := dsCalcFields;
    try
      ClearCalcFields(FCalcBuffer);
      for i := 0 to FFieldList.Count - 1 do
        if FFieldList[i].FieldKind = fkLookup then
          FFieldList[i].CalcLookupValue;
    finally
      DoOnCalcFields;
      FState := OldState;
    end;
  end;
end;

Procedure TDataset.CheckActive;

begin
  If Not Active then
    DataBaseError(SInactiveDataset);
end;

Procedure TDataset.CheckInactive;

begin
  If Active then
    DataBaseError(SActiveDataset);
end;

Procedure TDataset.ClearBuffers;

begin
  FRecordCount:=0;
  FactiveRecord:=0;
  FCurrentRecord:=-1;
  FBOF:=True;
  FEOF:=True;
end;

Procedure TDataset.ClearCalcFields(Buffer: TRecordBuffer);

begin
  // Empty
end;

Procedure TDataset.CloseBlob(Field: TField);

begin
  //!! To be implemented
end;

Procedure TDataset.CloseCursor;

begin
  FreeFieldBuffers;
  ClearBuffers;
  SetBufListSize(0);
  InternalClose;
  FInternalOpenComplete := False;
end;

Procedure TDataset.CreateFields;

Var I : longint;

begin
{$ifdef DSDebug}
  Writeln ('Creating fields');
  Writeln ('Count : ',fielddefs.Count);
  For I:=0 to FieldDefs.Count-1 do
    Writeln('Def ',I,' : ',Fielddefs.items[i].Name,'(',Fielddefs.items[i].FieldNo,')');
{$endif}
  For I:=0 to fielddefs.Count-1 do
    With Fielddefs.Items[I] do
      If DataType<>ftUnknown then
        begin
        {$ifdef DSDebug}
        Writeln('About to create field',FieldDefs.Items[i].Name);
        {$endif}
        CreateField(self);
        end;
end;

Procedure TDataset.DataEvent(Event: TDataEvent; Info: Ptrint);

  procedure HandleFieldChange(aField: TField);
  begin
    if aField.FieldKind in [fkData, fkInternalCalc] then
      SetModified(True);
      
    if State <> dsSetKey then begin
      if aField.FieldKind = fkData then begin
        if FInternalCalcFields then
          RefreshInternalCalcFields(ActiveBuffer)
        else if FAutoCalcFields and (FCalcFieldsSize <> 0) then
          CalculateFields(ActiveBuffer);
      end;
      
      aField.Change;
    end;
  end;
  
  procedure HandleScrollOrChange;
  begin
    if State <> dsInsert then
      UpdateCursorPos;
  end;

var
  i: Integer;
begin
  case Event of
    deFieldChange   : HandleFieldChange(TField(Info));
    deDataSetChange,
    deDataSetScroll : HandleScrollOrChange;
    deLayoutChange  : FEnableControlsEvent:=deLayoutChange;    
  end;

  if not ControlsDisabled and (FState <> dsBlockRead) then begin
    for i := 0 to FDataSources.Count - 1 do
      TDataSource(FDataSources[i]).ProcessEvent(Event, Info);
  end;
end;

Procedure TDataset.DestroyFields;

begin
  FFieldList.Clear;
end;

Procedure TDataset.DoAfterCancel;

begin
 If assigned(FAfterCancel) then
   FAfterCancel(Self);
end;

Procedure TDataset.DoAfterClose;

begin
 If assigned(FAfterClose) and not (csDestroying in ComponentState) then
   FAfterClose(Self);
end;

Procedure TDataset.DoAfterDelete;

begin
 If assigned(FAfterDelete) then
   FAfterDelete(Self);
end;

Procedure TDataset.DoAfterEdit;

begin
 If assigned(FAfterEdit) then
   FAfterEdit(Self);
end;

Procedure TDataset.DoAfterInsert;

begin
 If assigned(FAfterInsert) then
   FAfterInsert(Self);
end;

Procedure TDataset.DoAfterOpen;

begin
 If assigned(FAfterOpen) then
   FAfterOpen(Self);
end;

Procedure TDataset.DoAfterPost;

begin
 If assigned(FAfterPost) then
   FAfterPost(Self);
end;

Procedure TDataset.DoAfterScroll;

begin
 If assigned(FAfterScroll) then
   FAfterScroll(Self);
end;

Procedure TDataset.DoAfterRefresh;

begin
 If assigned(FAfterRefresh) then
   FAfterRefresh(Self);
end;

Procedure TDataset.DoBeforeCancel;

begin
 If assigned(FBeforeCancel) then
   FBeforeCancel(Self);
end;

Procedure TDataset.DoBeforeClose;

begin
 If assigned(FBeforeClose) and not (csDestroying in ComponentState) then
   FBeforeClose(Self);
end;

Procedure TDataset.DoBeforeDelete;

begin
 If assigned(FBeforeDelete) then
   FBeforeDelete(Self);
end;

Procedure TDataset.DoBeforeEdit;

begin
 If assigned(FBeforeEdit) then
   FBeforeEdit(Self);
end;

Procedure TDataset.DoBeforeInsert;

begin
 If assigned(FBeforeInsert) then
   FBeforeInsert(Self);
end;

Procedure TDataset.DoBeforeOpen;

begin
 If assigned(FBeforeOpen) then
   FBeforeOpen(Self);
end;

Procedure TDataset.DoBeforePost;

begin
 If assigned(FBeforePost) then
   FBeforePost(Self);
end;

Procedure TDataset.DoBeforeScroll;

begin
 If assigned(FBeforeScroll) then
   FBeforeScroll(Self);
end;

Procedure TDataset.DoBeforeRefresh;

begin
 If assigned(FBeforeRefresh) then
   FBeforeRefresh(Self);
end;

Procedure TDataset.DoInternalOpen;

begin
  InternalOpen;
  FInternalOpenComplete := True;
{$ifdef dsdebug}
  Writeln ('Calling internal open');
{$endif}
{$ifdef dsdebug}
  Writeln ('Calling RecalcBufListSize');
{$endif}
  FRecordcount := 0;
  RecalcBufListSize;
  FBOF:=True;
  FEOF := (FRecordcount = 0);
end;

Procedure TDataset.DoOnCalcFields;

begin
 If Assigned(FOnCalcfields) then
   FOnCalcFields(Self);
end;

Procedure TDataset.DoOnNewRecord;

begin
 If assigned(FOnNewRecord) then
   FOnNewRecord(Self);
end;

Function TDataset.FieldByNumber(FieldNo: Longint): TField;

begin
  Result:=FFieldList.FieldByNumber(FieldNo);
end;

Function TDataset.FindRecord(Restart, GoForward: Boolean): Boolean;

begin
 result:= false;
  //!! To be implemented
end;

Procedure TDataset.FreeFieldBuffers;

Var I : longint;

begin
  For I:=0 to FFieldList.Count-1 do
    FFieldList[i].FreeBuffers;
end;

Function TDataset.GetBookmarkStr: TBookmarkStr;

begin
  Result:='';
  If BookMarkAvailable then
    begin
    SetLength(Result,FBookMarkSize);
    GetBookMarkData(ActiveBuffer,Pointer(Result));
    end
end;

Function TDataset.GetBuffer (Index : longint) : TRecordBuffer;

begin
  Result:= pbufferaty(FBuffers)^[Index];
end;

Procedure TDataset.GetCalcFields(Buffer: TRecordBuffer);

begin
  if (FCalcFieldsSize > 0) or FInternalCalcFields then
    CalculateFields(Buffer);
end;

Function TDataset.GetCanModify: Boolean;

begin
  Result:= not FIsUnidirectional;
end;

Procedure TDataset.GetChildren(Proc: TGetChildProc; Root: TComponent);

var
 I: Integer;
 Field: TField;

begin
 for I := 0 to Fields.Count - 1 do begin
   Field := Fields[I];
   if (Field.Owner = Root) then
     Proc(Field);
 end;
end;

Function TDataset.GetDataSource: TDataSource;
begin
  Result:=nil;
end;

function TDataSet.GetRecordSize: Word;
begin
  Result := 0;
end;

procedure TDataSet.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // empty stub
end;

procedure TDataSet.InternalDelete;
begin
  // empty stub
end;

procedure TDataSet.InternalFirst;
begin
  // empty stub
end;

procedure TDataSet.InternalGotoBookmark(ABookmark: Pointer);
begin
  // empty stub
end;

function TDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;

begin
  Result := False;
end;

procedure TDataSet.DataConvert(aField: TField; aSource, aDest: Pointer;
  aToNative: Boolean);

 // There seems to be no WStrCopy defined, this is a copy of
 // the generic StrCopy function, adapted for WideChar.
 Function WStrCopy(Dest, Source:PWideChar): PWideChar;
 var
   counter : SizeInt;
 Begin
   counter := 0;
   while Source[counter] <> #0 do
   begin
//     Dest[counter] := char(Source[counter]);
     Dest[counter] := Source[counter];
     Inc(counter);
   end;
   { terminate the string }
   Dest[counter] := #0;
   WStrCopy := Dest;
 end;

var
  DT : TFieldType;

begin
  DT := aField.DataType;
  if aToNative then
    begin
    case DT of
      ftDate, ftTime, ftDateTime: TDateTimeRec(aDest^) := DateTimeToDateTimeRec(DT, TDateTime(aSource^));
      ftTimeStamp               : TTimeStamp(aDest^) := TTimeStamp(aSource^);
{$ifdef FPC}
      ftBCD                     : TBCD(aDest^) := CurrToBCD(Currency(aSource^));
{$else}
      ftBCD                     : CurrToBCD(Currency(aSource^),TBCD(aDest^));
{$endif}
      ftFMTBCD                  : TBcd(aDest^) := TBcd(aSource^);
  // See notes from mantis bug-report 8204 for more information
  //    ftBytes                   : ;
  //    ftVarBytes                : ;
      ftWideString              : WStrCopy(PWideChar(aDest), PWideChar(aSource));
      end
    end
  else
    begin
    case DT of
      ftDate, ftTime, ftDateTime: TDateTime(aDest^) := DateTimeRecToDateTime(DT, TDateTimeRec(aSource^));
      ftTimeStamp               : TTimeStamp(aDest^) := TTimeStamp(aSource^);
      ftBCD                     : BCDToCurr(TBCD(aSource^),Currency(aDest^));
      ftFMTBCD                  : TBcd(aDest^) := TBcd(aSource^);
  //    ftBytes                   : ;
  //    ftVarBytes                : ;
      ftWideString              : WStrCopy(PWideChar(aDest), PWideChar(aSource));
      end
    end
end;

function TDataSet.GetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean): Boolean;

Var
  AStatBuffer : Array[0..dsMaxStringSize] of Char;
  ADynBuffer : pchar;

begin
  If NativeFormat then
    Result:=GetFieldData(Field, Buffer)
  else
    begin
    if Field.DataSize <= dsMaxStringSize then
      begin
      Result := GetfieldData(Field, @AStatBuffer);
      if Result then DataConvert(Field,@AStatBuffer,Buffer,False);
      end
    else
      begin
      GetMem(ADynBuffer,Field.DataSize);
      try
        Result := GetfieldData(Field, ADynBuffer);
        if Result then DataConvert(Field,ADynBuffer,Buffer,False);
      finally
        FreeMem(ADynBuffer);
        end;
      end;
    end;
end;

Function DateTimeRecToDateTime(DT: TFieldType; Data: TDateTimeRec): TDateTime;

var
  TS: TTimeStamp;

begin
  TS.Date:=0;
  TS.Time:=0;
  case DT of
    ftDate: TS.Date := Data.Date;
    ftTime: With TS do
              begin
              Time := Data.Time;
              Date := DateDelta;
              end;
  else
    try
      TS:=MSecsToTimeStamp(trunc(Data.DateTime));
    except
    end;
  end;
  Result:=TimeStampToDateTime(TS);
end;

Function DateTimeToDateTimeRec(DT: TFieldType; Data: TDateTime): TDateTimeRec;

var
  TS : TTimeStamp;

begin
  TS:=DateTimeToTimeStamp(Data);
  With Result do
    case DT of
      ftDate:
        Date:=TS.Date;
      ftTime:
        Time:=TS.Time;
    else
      DateTime:=TimeStampToMSecs(TS);
    end;
end;

procedure TDataSet.SetFieldData(Field: TField; Buffer: Pointer);

begin
// empty procedure
end;

procedure TDataSet.SetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean);

Var
  AStatBuffer : Array[0..dsMaxStringSize] of Char;
  ADynBuffer : pchar;

begin
  if NativeFormat then
    SetFieldData(Field, Buffer)
  else
    begin
    if Field.DataSize <= dsMaxStringSize then
      begin
      DataConvert(Field,Buffer,@AStatBuffer,True);
      SetfieldData(Field, @AStatBuffer);
      end
    else
      begin
      GetMem(ADynBuffer,Field.DataSize);
      try
        DataConvert(Field,Buffer,@AStatBuffer,True);
        SetfieldData(Field, @AStatBuffer);
      finally
        FreeMem(ADynBuffer);
        end;
      end;
    end;
end;

Function TDataset.GetField (Index : Longint) : TField;

begin
  Result:=FFIeldList[index];
end;

Function TDataset.GetFieldClass(FieldType: TFieldType): TFieldClass;

begin
  Result := DefaultFieldClasses[FieldType];
end;

Function TDataset.GetIsIndexField(Field: TField): Boolean;

begin
  Result:=False;
end;

function TDataSet.GetIndexDefs(IndexDefs: TIndexDefs; IndexTypes: TIndexOptions
  ): TIndexDefs;
  
var i,f : integer;
    IndexFields : TStrings;
    
begin
  IndexDefs.Update;
  Result := TIndexDefs.Create(Self);
  Result.Assign(IndexDefs);
  i := 0;
  IndexFields := TStringList.Create;
  while i < result.Count do
    begin
    if (not ((IndexTypes = []) and (result[i].Options = []))) and
       ((IndexTypes * result[i].Options) = []) then
      begin
      result.Delete(i);
      dec(i);
      end
    else
      begin
      ExtractStrings([';'],[' '],pchar(result[i].Fields),Indexfields);
      for f := 0 to IndexFields.Count-1 do if FindField(Indexfields[f]) = nil then
        begin
        result.Delete(i);
        dec(i);
        break;
        end;
      end;
    inc(i);
    end;
  IndexFields.Free;
end;

Function TDataset.GetNextRecord: Boolean;

  procedure ExchangeBuffers(var buf1,buf2 : trecordbuffer);

  var tempbuf : pointer;

  begin
    tempbuf := buf1;
    buf1 := buf2;
    buf2 := tempbuf;
  end;

begin
{$ifdef dsdebug}
  Writeln ('Getting next record. Internal RecordCount : ',FRecordCount);
{$endif}
  If FRecordCount>0 Then SetCurrentRecord(FRecordCount-1);
  Result:=GetRecord(pbufferaty(FBuffers)^[FBuffercount],gmNext,True)=grOK;

  if result then
    begin
      If FRecordCount=0 then ActivateBuffers;
      if FRecordcount=FBuffercount then
        shiftbuffersbackward
      else
        begin
          inc(FRecordCount);
          FCurrentRecord:=FRecordCount - 1;
          ExchangeBuffers(pbufferaty(FBuffers)^[FCurrentRecord],
                     pbufferaty(FBuffers)^[FBuffercount]);
        end;
    end
  else
    cursorposchanged;
{$ifdef dsdebug}
  Writeln ('Result getting next record : ',Result);
{$endif}
end;

Function TDataset.GetNextRecords: Longint;

begin
  Result:=0;
{$ifdef dsdebug}
  Writeln ('Getting next record(s), need :',FBufferCount);
{$endif}
  While (FRecordCount<FBufferCount) and GetNextRecord do
    Inc(Result);
{$ifdef dsdebug}
  Writeln ('Result Getting next record(S), GOT :',RESULT);
{$endif}
end;

Function TDataset.GetPriorRecord: Boolean;

begin
{$ifdef dsdebug}
  Writeln ('GetPriorRecord: Getting previous record');
{$endif}
  CheckBiDirectional;
  If FRecordCount>0 Then SetCurrentRecord(0);
  Result:=GetRecord(pbufferaty(FBuffers)^[FBuffercount],gmPrior,True)=grOK;
  if result then
    begin
      If FRecordCount=0 then ActivateBuffers;
      shiftbuffersforward;

      if FRecordcount<FBuffercount then
        inc(FRecordCount);
    end
  else
    cursorposchanged;
{$ifdef dsdebug}
  Writeln ('Result getting prior record : ',Result);
{$endif}
end;

Function TDataset.GetPriorRecords: Longint;

begin
  Result:=0;
{$ifdef dsdebug}
  Writeln ('Getting previous record(s), need :',FBufferCount);
{$endif}
  While (FRecordCount<FbufferCount) and GetPriorRecord do
    Inc(Result);
end;

Function TDataset.GetRecNo: Longint;

begin
  Result := -1;
end;

Function TDataset.GetRecordCount: Longint;

begin
  Result := -1;
end;

Procedure TDataset.InitFieldDefs;

begin
  if IsCursorOpen then
    InternalInitFieldDefs
  else
    begin
    try
      OpenCursor(True);
    finally
      CloseCursor;
      end;
    end;
end;

procedure TDataSet.SetBlockReadSize(AValue: Integer);
begin
  // the state is changed even when setting the same BlockReadSize (follows Delphi behavior)
  // e.g., state is dsBrowse and BlockReadSize is 1. Setting BlockReadSize to 1 will change state to dsBlockRead
  FBlockReadSize := AValue;
  if AValue > 0 then
  begin
    CheckActive; 
    SetState(dsBlockRead);
  end	
  else
  begin
    //update state only when in dsBlockRead 
    if FState = dsBlockRead then
      SetState(dsBrowse);
  end;	
end;

Procedure TDataSet.SetFieldDefs(AFieldDefs: TFieldDefs);

begin
  FFieldDefs.Assign(AFieldDefs);
end;

procedure TDataSet.DoInsertAppendRecord(const Values: array of const; DoAppend : boolean);
var i : integer;
    ValuesSize : integer;
begin
  ValuesSize:=Length(Values);
  if ValuesSize>FieldCount then DatabaseError(STooManyFields,self);
  if DoAppend then
    Append
  else
    Insert;

  for i := 0 to ValuesSize-1 do with values[i] do
    fields[i].AssignValue(values[i]);
  Post;

end;

procedure TDataSet.InitFieldDefsFromfields;
var i : integer;
begin
  if FieldDefs.count = 0 then
    begin
    FieldDefs.BeginUpdate;
    try
      for i := 0 to Fields.Count-1 do with fields[i] do
        if not (FieldKind in [fkCalculated,fkLookup]) then // Do not add fielddefs for calculated/lookup fields.
          begin
          with TFieldDef.Create(FieldDefs,FieldName,DataType,Size,Required,FieldDefs.Count+1) do
            begin
            if Required then Attributes := attributes + [faRequired];
            if ReadOnly then Attributes := attributes + [faReadOnly];
            if DataType = ftBCD then precision := (fields[i] as TBCDField).Precision
            else if DataType = ftFMTBcd then precision := (fields[i] as TFMTBCDField).Precision;
            end;
          end;
    finally
      FieldDefs.EndUpdate;
      end;
    end;
end;

Procedure TDataset.InitRecord(Buffer: TRecordBuffer);

begin
  InternalInitRecord(Buffer);
  ClearCalcFields(Buffer);
end;

Procedure TDataset.InternalCancel;

begin
  //!! To be implemented
end;

Procedure TDataset.InternalEdit;

begin
  //!! To be implemented
end;

Procedure TDataset.InternalRefresh;

begin
  //!! To be implemented
end;

Procedure TDataset.OpenCursor(InfoQuery: Boolean);

begin
  if InfoQuery then
    InternalInitfieldDefs
  else if state <> dsOpening then
    DoInternalOpen;
end;

procedure TDataSet.OpenCursorcomplete;
begin
  try
    if FState = dsOpening then DoInternalOpen
  finally
    if FInternalOpenComplete then
      begin
      SetState(dsBrowse);
      DoAfterOpen;
      if not IsEmpty then
        DoAfterScroll;
      end
    else
      begin
      SetState(dsInactive);
      CloseCursor;
      end;
  end;
end;

Procedure TDataset.RefreshInternalCalcFields(Buffer: TRecordBuffer);

begin
  //!! To be implemented
end;

Function TDataset.SetTempState(const Value: TDataSetState): TDataSetState;

begin
  result := FState;
  FState := value;
  inc(FDisableControlsCount);
end;

Procedure TDataset.RestoreState(const Value: TDataSetState);

begin
  FState := value;
  dec(FDisableControlsCount);
end;

function TDataset.GetActive : boolean;

begin
  result := (FState <> dsInactive) and (FState <> dsOpening);
end;

Procedure TDataset.InternalHandleException;

begin
  if assigned(classes.ApplicationHandleException) then
    classes.ApplicationHandleException(self)
  else
    ShowException(ExceptObject,ExceptAddr);
end;

procedure TDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
  // empty stub
end;

procedure TDataSet.InternalLast;
begin
  // empty stub
end;

procedure TDataSet.InternalPost;

  Procedure Checkrequired;

  Var I : longint;

  begin
    For I:=0 to FFieldList.Count-1 do
      With FFieldList[i] do
        // Required fields that are NOT autoinc !! Autoinc cannot be set !!
        if Required and not ReadOnly and
           (FieldKind=fkData) and Not (DataType=ftAutoInc) and IsNull then
          DatabaseErrorFmt(SNeedField,[DisplayName],Self);
  end;

begin
  Checkrequired;
end;

procedure TDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  // empty stub
end;

procedure TDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  // empty stub
end;

procedure TDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  // empty stub
end;

procedure TDataSet.SetUniDirectional(const Value: Boolean);
begin
  FIsUniDirectional := Value;
end;

Procedure TDataset.SetActive (Value : Boolean);

begin
  if value and (Fstate = dsInactive) then
    begin
    if csLoading in ComponentState then
      begin
      FOpenAfterRead := true;
      exit;
      end
    else
      begin
      DoBeforeOpen;
      FEnableControlsEvent:=deLayoutChange;
      FInternalCalcFields:=False;
      try
        FDefaultFields:=FieldCount=0;
        OpenCursor(False);
      finally
        if FState <> dsOpening then OpenCursorComplete;
        end;
      end;
    FModified:=False;
    end
  else if not value and (Fstate <> dsinactive) then
    begin
    DoBeforeClose;
    SetState(dsInactive);
    CloseCursor;
    DoAfterClose;
    FModified:=False;
    end
end;

procedure TDataset.Loaded;

begin
  inherited;
  try
    if FOpenAfterRead then SetActive(true);
  except
    if csDesigning in Componentstate then
      InternalHandleException
    else
      raise;
  end;
end;


procedure TDataSet.RecalcBufListSize;

var
  i, j, ABufferCount: Integer;
  DataLink: TDataLink;

begin
{$ifdef dsdebug}
  Writeln('Recalculating buffer list size - check cursor');
{$endif}
  If Not IsCursorOpen Then
    Exit;
{$ifdef dsdebug}
  Writeln('Recalculating buffer list size');
{$endif}
  ABufferCount := DefaultBufferCount;
  for i := 0 to FDataSources.Count - 1 do
    for j := 0 to TDataSource(FDataSources[i]).DataLinks.Count - 1 do
      begin
      DataLink:=TDataLink(TDataSource(FDataSources[i]).DataLinks[j]);
      if DataLink.BufferCount>ABufferCount then
        ABufferCount:=DataLink.BufferCount;
      end;

  If (FBufferCount=ABufferCount) Then
    exit;

{$ifdef dsdebug}
  Writeln('Setting buffer list size');
{$endif}

  SetBufListSize(ABufferCount);
{$ifdef dsdebug}
  Writeln('Getting next buffers');
{$endif}
  GetNextRecords;
  if (FRecordCount < FBufferCount) and not IsUniDirectional then
    begin
    FActiveRecord := FActiveRecord + GetPriorRecords;
    CursorPosChanged;
    end;
{$Ifdef dsDebug}
  WriteLn(
    'SetBufferCount: FActiveRecord=',FActiveRecord,
    ' FCurrentRecord=',FCurrentRecord,
    ' FBufferCount= ',FBufferCount,
    ' FRecordCount=',FRecordCount);
{$Endif}
end;

Procedure TDataset.SetBookmarkStr(const Value: TBookmarkStr);

begin
  GotoBookMark(Pointer(Value))
end;

Procedure TDataset.SetBufListSize(Value: Longint);

Var I : longint;

begin
  if Value = 0 then Value := -1;
{$ifdef dsdebug}
  Writeln ('SetBufListSize: ',Value);
{$endif}
  If Value=FBufferCount Then
    exit;
  If Value>FBufferCount then
    begin
{$ifdef dsdebug}
    Writeln ('   Reallocating memory :',(Value+1)*SizeOf(TRecordBuffer));
{$endif}
    ReAllocMem(FBuffers,(Value+1)*SizeOf(PChar));
{$ifdef dsdebug}
    Writeln ('   Filling memory :',(Value+1-FBufferCount)*SizeOf(TRecordBuffer));
{$endif}
    inc(FBufferCount); // Cause FBuffers[FBufferCount] is already allocated
    FillChar(pbufferaty(FBuffers)^[FBufferCount],(Value+1-FBufferCount)*SizeOF(TRecordBuffer),#0);
{$ifdef dsdebug}
    Writeln ('   Filled memory :');
{$endif}
    Try
{$ifdef dsdebug}
      Writeln ('   Assigning buffers :',(Value)*SizeOf(TRecordBuffer));
{$endif}
      For I:=FBufferCount to Value do
        pbufferaty(FBuffers)^[i]:=AllocRecordBuffer;
{$ifdef dsdebug}
      Writeln ('   Assigned buffers ',FBufferCount,' :',(Value)*SizeOf(TRecordBuffer));
{$endif}
    except
      I:=FBufferCount;
      While (I<(Value+1)) do
        begin
        FreeRecordBuffer(pbufferaty(FBuffers)^[i]);
        Inc(i);
        end;
      raise;
    end;
    end
  else
    begin
{$ifdef dsdebug}
    Writeln ('   Freeing buffers :',FBufferCount-Value);
{$endif}
    if (value > -1) and (FActiveRecord>Value-1) then
      begin
      for i := 0 to (FActiveRecord-Value) do
        shiftbuffersbackward;
      FActiverecord := Value -1;
      end;

    If Assigned(FBuffers) then
      begin
      For I:=Value+1 to FBufferCount do
        FreeRecordBuffer(pbufferaty(FBuffers)^[i]);
      // FBuffer must stay allocated, to make sure that Activebuffer returns nil
      if Value = -1 then
        begin
        ReAllocMem(FBuffers,SizeOf(TRecordBuffer));
        pbufferaty(FBuffers)^[0] := nil;
        end
      else
        ReAllocMem(FBuffers,(Value+1)*SizeOf(TRecordBuffer));
      end;
    end;
  FBufferCount:=Value;
  If Value=-1 then
    Value:=0;
  if FRecordcount > Value then FRecordcount := Value;
{$ifdef dsdebug}
  Writeln ('   SetBufListSize: Final FBufferCount=',FBufferCount);
{$endif}
end;

Procedure TDataset.SetChildOrder(Component: TComponent; Order: Longint);

var
  Field: TField;
begin
  Field := Component as TField;
  if Fields.IndexOf(Field) >= 0 then
    Field.Index := Order;
end;

Procedure TDataset.SetCurrentRecord(Index: Longint);

begin
  If FCurrentRecord<>Index then
    begin
{$ifdef DSdebug}
    Writeln ('Setting current record to',index);
{$endif}
    if not FIsUniDirectional then Case GetBookMarkFlag(pbufferaty(FBuffers)^[Index]) of
      bfCurrent : InternalSetToRecord(pbufferaty(FBuffers)^[Index]);
      bfBOF : InternalFirst;
      bfEOF : InternalLast;
      end;
    FCurrentRecord:=index;
    end;
end;

procedure TDataSet.SetDefaultFields(const Value: Boolean);
begin
  FDefaultFields := Value;
end;

Procedure TDataset.SetField (Index : Longint;Value : TField);

begin
  //!! To be implemented
end;

Procedure TDataset.CheckBiDirectional;

begin
  if FIsUniDirectional then DataBaseError(SUniDirectional);
end;

Procedure TDataset.SetFilterOptions(Value: TFilterOptions);

begin
  CheckBiDirectional;
  FFilterOptions := Value;
end;

Procedure TDataset.SetFilterText(const Value: string);

begin
  FFilterText := value;
end;

Procedure TDataset.SetFiltered(Value: Boolean);

begin
  if Value then CheckBiDirectional;
  FFiltered := value;
end;

procedure TDataSet.SetFound(const Value: Boolean);
begin
  FFound := Value;
end;

Procedure TDataset.SetModified(Value: Boolean);

begin
  FModified := value;
end;

Procedure TDataset.SetName(const Value: TComponentName);

function CheckName(const FieldName: string): string;
var i,j: integer;
begin
  Result := FieldName;
  i := 0;
  j := 0;
  while (i < Fields.Count) do begin
    if Result = Fields[i].FieldName then begin
      inc(j);
      Result := FieldName + IntToStr(j);
    end else Inc(i);
  end;
end;
var i: integer;
    nm: string;
    old: string;
begin
  if Self.Name = Value then Exit;
  old := Self.Name;
  inherited SetName(Value);
  if (csDesigning in ComponentState) then
    for i := 0 to Fields.Count - 1 do begin
      nm := old + Fields[i].FieldName;
      if Copy(Fields[i].Name, 1, Length(nm)) = nm then
        Fields[i].Name := CheckName(Value + Fields[i].FieldName);
    end;
end;

Procedure TDataset.SetOnFilterRecord(const Value: TFilterRecordEvent);

begin
  CheckBiDirectional;
  FOnFilterRecord := Value;
end;

Procedure TDataset.SetRecNo(Value: Longint);

begin
  //!! To be implemented
end;

Procedure TDataset.SetState(Value: TDataSetState);

begin
  If Value<>FState then
    begin
    FState:=Value;
    if Value=dsBrowse then
      FModified:=false;
    DataEvent(deUpdateState,0);
    end;
end;

Function TDataset.Tempbuffer: TRecordBuffer;

begin
  Result := pbufferaty(FBuffers)^[FRecordCount];
end;

Procedure TDataset.UpdateIndexDefs;

begin
  // Empty Abstract
end;

function TDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := nil;
end;

procedure TDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  // empty stub
end;

procedure TDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  // empty stub
end;

function TDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := bfCurrent;
end;

Function TDataset.ControlsDisabled: Boolean;

begin
  Result := (FDisableControlsCount > 0);
end;

Function TDataset.ActiveBuffer: TRecordBuffer;

begin
{$ifdef dsdebug}
  Writeln ('Active buffer requested. Returning:',ActiveRecord);
{$endif}
  Result:=pbufferaty(FBuffers)^[FActiveRecord];
end;

Procedure TDataset.Append;

begin
  DoInsertAppend(True);
end;

Procedure TDataset.InternalInsert;

begin
  //!! To be implemented
end;

Procedure TDataset.AppendRecord(const Values: array of const);

begin
  DoInsertAppendRecord(Values,True);
end;

Function TDataset.BookmarkValid(ABookmark: TBookmark): Boolean;
{
  Should be overridden by descendant objects.
}
begin
  Result:=False
end;

Procedure TDataset.Cancel;

begin
  If State in [dsEdit,dsInsert] then
    begin
    DataEvent(deCheckBrowseMode,0);
    DoBeforeCancel;
    UpdateCursorPos;
    InternalCancel;
    FreeFieldBuffers;
    if (state = dsInsert) and (FRecordcount = 1) then
      begin
      FEOF := true;
      FBOF := true;
      FRecordcount := 0;
      InitRecord(ActiveBuffer);
      SetState(dsBrowse);
      DataEvent(deDatasetChange,0);
      end
    else
      begin
      SetState(dsBrowse);
      SetCurrentRecord(FActiverecord);
      resync([]);
      end;
    DoAfterCancel;
    end;
end;

Procedure TDataset.CheckBrowseMode;

begin
  CheckActive;
  DataEvent(deCheckBrowseMode,0);
  Case State of
    dsedit,dsinsert: begin
      UpdateRecord;
      If Modified then Post else Cancel;
    end;
    dsSetKey: Post;
  end;
end;

Procedure TDataset.ClearFields;


begin
  DataEvent(deCheckBrowseMode, 0);
  FreeFieldBuffers;
  InternalInitRecord(ActiveBuffer);
  if State <> dsSetKey then GetCalcFields(ActiveBuffer);
  DataEvent(deRecordChange, 0);
end;

Procedure TDataset.Close;

begin
  Active:=False;
end;

Function TDataset.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Longint;

begin
  Result:=0;
end;

Function TDataset.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;


begin
  Result:=Nil;
end;

Procedure TDataset.CursorPosChanged;


begin
  FCurrentRecord:=-1;
end;

Procedure TDataset.Delete;

begin
  If Not CanModify then
    DatabaseError(SDatasetReadOnly,Self);
  If IsEmpty then
    DatabaseError(SDatasetEmpty,Self);
  if State in [dsInsert] then
  begin
    Cancel;
  end else begin
    DataEvent(deCheckBrowseMode,0);
{$ifdef dsdebug}
    writeln ('Delete: checking required fields');
{$endif}
    DoBeforeDelete;
    DoBeforeScroll;
    If Not TryDoing({$ifdef FPC}@{$endif}InternalDelete,OnPostError) then exit;
{$ifdef dsdebug}
    writeln ('Delete: Internaldelete succeeded');
{$endif}
    FreeFieldBuffers;
    SetState(dsBrowse);
{$ifdef dsdebug}
    writeln ('Delete: Browse mode set');
{$endif}
    SetCurrentRecord(FActiverecord);
    Resync([]);
    DoAfterDelete;
    DoAfterScroll;
  end;
end;

Procedure TDataset.DisableControls;


begin
  If FDisableControlsCount=0 then
    begin
    { Save current state,
      needed to detect change of state when enabling controls.
    }
    FDisableControlsState:=FState;
    FEnableControlsEvent:=deDatasetChange;
    end;
  Inc(FDisableControlsCount);
end;

Procedure TDataset.DoInsertAppend(DoAppend : Boolean);


  procedure DoInsert(DoAppend : Boolean);

  Var BookBeforeInsert : TBookmarkStr;
      TempBuf : pointer;

  begin
  // need to scroll up al buffers after current one,
  // but copy current bookmark to insert buffer.
  If FRecordcount > 0 then
    BookBeforeInsert:=Bookmark;

  if not DoAppend then
    begin
    if FRecordCount > 0 then
      begin
      TempBuf := pbufferaty(FBuffers)^[FBuffercount];
      move(pbufferaty(FBuffers)^[FActiveRecord],
            pbufferaty(FBuffers)^[FActiveRecord+1],
            (Fbuffercount-FActiveRecord)*sizeof(pbufferaty(FBuffers)^[0]));
      pbufferaty(FBuffers)^[FActiveRecord]:=TempBuf;
      end;
    end
  else if FRecordcount=FBuffercount then
    shiftbuffersbackward
  else
    begin
    if FRecordCount>0 then
      inc(FActiveRecord);
    end;

  // Active buffer is now edit buffer. Initialize.
  InitRecord(pbufferaty(FBuffers)^[FActiveRecord]);
  cursorposchanged;

  // Put bookmark in edit buffer.
  if FRecordCount=0 then
    SetBookmarkFlag(ActiveBuffer,bfEOF)
  else
    begin
    fBOF := false;
    // 29:01:05, JvdS: Why is this here?!? It can result in records with the same bookmark-data?
    // I would say that the 'internalinsert' should do this. But I don't know how Tdbf handles it

    // 1-apr-06, JvdS: It just sets the bookmark of the newly inserted record to the place
    // where the record should be inserted. So it is ok.
    if FRecordcount > 0 then
      SetBookMarkData(ActiveBuffer,pointer(BookBeforeInsert));
    end;

  InternalInsert;

  // update buffer count.
  If FRecordCount<FBufferCount then
    Inc(FRecordCount);
  end;

begin
  CheckBrowseMode;
  If Not CanModify then
    DatabaseError(SDatasetReadOnly,Self);
  DoBeforeInsert;
  DoBeforeScroll;
  If Not DoAppend then
    begin
{$ifdef dsdebug}
    Writeln ('going to insert mode');
{$endif}
    DoInsert(false);
    end
  else
    begin
{$ifdef dsdebug}
    Writeln ('going to append mode');
{$endif}
    ClearBuffers;
    InternalLast;
    GetPriorRecords;
    if FRecordCount>0 then
      FActiveRecord:=FRecordCount-1;
    DoInsert(True);
    SetBookmarkFlag(ActiveBuffer,bfEOF);
    FBOF :=False;
    FEOF := true;
    end;
  SetState(dsInsert);
  try
    DoOnNewRecord;
  except
    SetCurrentRecord(FActiverecord);
    resync([]);
    raise;
  end;
  // mark as not modified.
  FModified:=False;
  // Final events.
  DataEvent(deDatasetChange,0);
  DoAfterInsert;
  DoAfterScroll;
{$ifdef dsdebug}
  Writeln ('Done with append');
{$endif}
end;

Procedure TDataset.Edit;

begin
  If State in [dsedit,dsinsert] then exit;
  CheckBrowseMode;
  If Not CanModify then
    DatabaseError(SDatasetReadOnly,Self);
  If FRecordCount = 0 then
    begin
    Append;
    Exit;
    end;
  DoBeforeEdit;
  If Not TryDoing({$ifdef FPC}@{$endif}InternalEdit,OnEditError) then exit;
  GetCalcFields(ActiveBuffer);
  SetState(dsedit);
  DataEvent(deRecordChange,0);
  DoAfterEdit;
end;

Procedure TDataset.EnableControls;


begin
  if FDisableControlsCount > 0 then
    Dec(FDisableControlsCount);

  if FDisableControlsCount = 0 then begin
    if FState <> FDisableControlsState then
      DataEvent(deUpdateState, 0);

    if (FState <> dsInactive) and (FDisableControlsState <> dsInactive) then
      DataEvent(FEnableControlsEvent, 0);
  end;
end;

Function TDataset.FieldByName(const FieldName: string): TField;


begin
  Result:=FindField(FieldName);
  If Result=Nil then
    DatabaseErrorFmt(SFieldNotFound,[FieldName],Self);
end;

Function TDataset.FindField(const FieldName: string): TField;


begin
  Result:=FFieldList.FindField(FieldName);
end;

Function TDataset.FindFirst: Boolean;


begin
  Result:=False;
end;

Function TDataset.FindLast: Boolean;


begin
  Result:=False;
end;

Function TDataset.FindNext: Boolean;


begin
  Result:=False;
end;

Function TDataset.FindPrior: Boolean;


begin
  Result:=False;
end;

Procedure TDataset.First;


begin
  CheckBrowseMode;
  DoBeforeScroll;
  if not FIsUniDirectional then
    ClearBuffers
  else if not FBof then
    begin
    Active := False;
    Active := True;
    end;
  try
    InternalFirst;
    if not FIsUniDirectional then GetNextRecords;
  finally
    FBOF:=True;
    DataEvent(deDatasetChange,0);
    DoAfterScroll;
    end;
end;

Procedure TDataset.FreeBookmark(ABookmark: TBookmark);


begin
  FreeMem(ABookMark,FBookMarkSize);
end;

Function TDataset.GetBookmark: TBookmark;


begin
  if BookmarkAvailable then
    begin
    GetMem (Result,FBookMarkSize);
    GetBookMarkdata(ActiveBuffer,Result);
    end
  else
    Result:=Nil;
end;

Function TDataset.GetCurrentRecord(Buffer: TRecordBuffer): Boolean;


begin
  Result:=False;
end;

Procedure TDataset.GetFieldList(List: TList; const FieldNames: string);

var
  F: TField;
  N: String;
  StrPos: Integer;

begin
  if (FieldNames = '') or (List = nil) then
    Exit;
  StrPos := 1;
  repeat
    N := ExtractFieldName(FieldNames, StrPos);
    F := FieldByName(N);
    List.Add(F);
  until StrPos > Length(FieldNames);
end;

Procedure TDataset.GetFieldNames(List: TStrings);


begin
  FFieldList.GetFieldNames(List);
end;

Procedure TDataset.GotoBookmark(ABookmark: TBookmark);


begin
  If Assigned(ABookMark) then
    begin
    CheckBrowseMode;
    DoBeforeScroll;
    InternalGotoBookMark(ABookMark);
    Resync([rmExact,rmCenter]);
    DoAfterScroll;
    end;
end;

Procedure TDataset.Insert;

begin
  DoInsertAppend(False);
end;

Procedure TDataset.InsertRecord(const Values: array of const);

begin
  DoInsertAppendRecord(Values,False);
end;

Function TDataset.IsEmpty: Boolean;

begin
  Result:=(fBof and fEof) and
          (not (state = dsinsert)); // After an insert on an empty dataset, both fBof and fEof are true
end;

Function TDataset.IsLinkedTo(ADataSource: TDataSource): Boolean;

begin
//!! Not tested, I never used nested DS
  if (ADataSource = nil) or (ADataSource.Dataset = nil) then begin
    Result := False
  end else if ADataSource.Dataset = Self then begin
    Result := True;
  end else begin
    Result := ADataSource.Dataset.IsLinkedTo(ADataSource.Dataset.DataSource);
  end;
//!! DataSetField not implemented
end;

Function TDataset.IsSequenced: Boolean;

begin
  Result := True;
end;

Procedure TDataset.Last;

begin
  CheckBiDirectional;
  CheckBrowseMode;
  DoBeforeScroll;
  ClearBuffers;
  try
    InternalLast;
    GetPriorRecords;
    if FRecordCount>0 then
      FActiveRecord:=FRecordCount-1
  finally
    FEOF:=true;
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
    end;
end;

Function TDataset.MoveBy(Distance: Longint): Longint;
Var
  TheResult: Integer;

  Function Scrollforward : Integer;

  begin
    Result:=0;
{$ifdef dsdebug}
    Writeln('Scrolling forward :',Distance);
    Writeln('Active buffer : ',FActiveRecord);
    Writeln('RecordCount   : ',FRecordCount);
    WriteLn('BufferCount   : ',FBufferCount);
{$endif}
    FBOF:=False;
    While (Distance>0) and not FEOF do
      begin
      If FActiveRecord<FRecordCount-1 then
        begin
        Inc(FActiveRecord);
        Dec(Distance);
        Inc(TheResult); //Inc(Result);
        end
      else
        begin
{$ifdef dsdebug}
       Writeln('Moveby : need next record');
{$endif}
        If GetNextRecord then
          begin
          Dec(Distance);
          Dec(Result);
          Inc(TheResult); //Inc(Result);
          end
        else
          FEOF:=true;
        end;
      end
  end;
  Function ScrollBackward : Integer;

  begin
    CheckBiDirectional;
    Result:=0;
{$ifdef dsdebug}
    Writeln('Scrolling backward:',Abs(Distance));
    Writeln('Active buffer : ',FActiveRecord);
    Writeln('RecordCunt    : ',FRecordCount);
    WriteLn('BufferCount   : ',FBufferCount);
{$endif}
    FEOF:=False;
    While (Distance<0) and not FBOF do
      begin
      If FActiveRecord>0 then
        begin
        Dec(FActiveRecord);
        Inc(Distance);
        Dec(TheResult); //Dec(Result);
        end
      else
        begin
       {$ifdef dsdebug}
       Writeln('Moveby : need next record');
       {$endif}
        If GetPriorRecord then
          begin
          Inc(Distance);
          Inc(Result);
          Dec(TheResult); //Dec(Result);
          end
        else
          FBOF:=true;
        end;
      end
  end;

Var
  Scrolled : Integer;

begin
  CheckBrowseMode;
  Result:=0; TheResult:=0;
  DoBeforeScroll;
  If (Distance = 0) or
     ((Distance>0) and FEOF) or
     ((Distance<0) and FBOF) then
    exit;
  Try
    Scrolled := 0;
    If Distance>0 then
      Scrolled:=ScrollForward
    else
      Scrolled:=ScrollBackward;
  finally
{$ifdef dsdebug}
    WriteLn('ActiveRecord=', FActiveRecord,' FEOF=',FEOF,' FBOF=',FBOF);
{$Endif}
    DataEvent(deDatasetScroll,Scrolled);
    DoAfterScroll;
    Result:=TheResult;
  end;
end;

Procedure TDataset.Next;

begin
  if BlockReadSize>0 then
    BlockReadNext
  else
    MoveBy(1);
end;

Procedure TDataset.BlockReadNext;
begin
  MoveBy(1);
end;

Procedure TDataset.Open;

begin
  Active:=True;
end;

Procedure TDataset.Post;

begin
  if State in [dsEdit,dsInsert] then
    begin
    DataEvent(deUpdateRecord,0);
    DataEvent(deCheckBrowseMode,0);
{$ifdef dsdebug}
    writeln ('Post: checking required fields');
{$endif}
    DoBeforePost;
    If Not TryDoing({$ifdef FPC}@{$endif}InternalPost,OnPostError) then exit;
    cursorposchanged;
{$ifdef dsdebug}
    writeln ('Post: Internalpost succeeded');
{$endif}
    FreeFieldBuffers;
// First set the state to dsBrowse, then the Resync, to prevent the calling of
// the deDatasetChange event, while the state is still 'editable', while the db isn't
    SetState(dsBrowse);
    Resync([]);
{$ifdef dsdebug}
    writeln ('Post: Browse mode set');
{$endif}
    DoAfterPost;
    end
  else
    DatabaseErrorFmt(SNotEditing, [Name], Self);
end;

Procedure TDataset.Prior;

begin
  MoveBy(-1);
end;

Procedure TDataset.Refresh;

begin
  CheckbrowseMode;
  DoBeforeRefresh;
  UpdateCursorPos;
  InternalRefresh;
{ SetCurrentRecord is called by UpdateCursorPos already, so as long as
  InternalRefresh doesn't do strange things this should be ok. }
//  SetCurrentRecord(FActiverecord);
  Resync([]);
  DoAfterRefresh;
end;

Procedure TDataset.RegisterDataSource(ADatasource : TDataSource);

begin
  FDatasources.Add(ADataSource);
  RecalcBufListSize;
end;


Procedure TDataset.Resync(Mode: TResyncMode);

var i,count : integer;

begin
  // See if we can find the requested record.
{$ifdef dsdebug}
    Writeln ('Resync called');
{$endif}
  if FIsUnidirectional then Exit;
// place the cursor of the underlying dataset to the active record
//  SetCurrentRecord(FActiverecord);

// Now look if the data on the current cursor of the underlying dataset is still available
  If GetRecord(pbufferaty(FBuffers)^[0],gmcurrent,False)<>grOk Then
// If that fails and rmExact is set, then raise an exception
    If rmExact in Mode then
      DatabaseError(SNoSuchRecord,Self)
// else, if rmexact is not set, try to fetch the next  or prior record in the underlying dataset
    else if (GetRecord(pbufferaty(FBuffers)^[0],gmnext,True)<>grOk) and
            (GetRecord(pbufferaty(FBuffers)^[0],gmprior,True)<>grOk) then
      begin
{$ifdef dsdebug}
      Writeln ('Resync: fuzzy resync');
{$endif}
      // nothing found, invalidate buffer and bail out.
      ClearBuffers;
      // Make sure that the active record is 'empty', ie: that all fields are null
      InternalInitRecord(ActiveBuffer);
      DataEvent(deDatasetChange,0);
      exit;
      end;
  FCurrentRecord := 0;
  FEOF := false;
  FBOF := false;

// If we've arrived here, FBuffer[0] is the current record
  If (rmCenter in Mode) then
    count := (FRecordCount div 2)
  else
    count := FActiveRecord;
  i := 0;
  FRecordcount := 1;
  FActiveRecord := 0;

// Fill the buffers before the active record
  while (i < count) and GetPriorRecord do
    inc(i);
  FActiveRecord := i;
// Fill the rest of the buffer
  getnextrecords;
// If the buffer is not full yet, try to fetch some more prior records
  if FRecordcount < FBuffercount then inc(FActiverecord,getpriorrecords);
// That's all folks!
  DataEvent(deDatasetChange,0);
end;

Procedure TDataset.SetFields(const Values: array of const);

Var I  : longint;
begin
  For I:=0 to high(Values) do
    Fields[I].AssignValue(Values[I]);
end;

Function TDataset.Translate(Src, Dest: PChar; ToOem: Boolean): Integer;

begin
  strcopy(dest,src);
  Result:=StrLen(dest);
end;

Function Tdataset.TryDoing (P : TDataOperation; Ev : TDatasetErrorEvent) : Boolean;

Var Retry : TDataAction;

begin
{$ifdef dsdebug}
  Writeln ('Trying to do');
  If P=Nil then writeln ('Procedure to call is nil !!!');
{$endif dsdebug}
  Result:=True;
  Retry:=daRetry;
  while Retry=daRetry do
    Try
{$ifdef dsdebug}
      Writeln ('Trying : updatecursorpos');
{$endif dsdebug}
      UpdateCursorPos;
{$ifdef dsdebug}
      Writeln ('Trying to do it');
{$endif dsdebug}
      P;
      exit;
    except
      On E : EDatabaseError do
        begin
        retry:=daFail;
        If Assigned(Ev) then
          Ev(Self,E,Retry);
        Case Retry of
          daFail : Raise;
          daAbort : Result:=False;
        end;
        end;
    else
      Raise;
    end;
{$ifdef dsdebug}
  Writeln ('Exit Trying to do');
{$endif dsdebug}
end;

Procedure TDataset.UpdateCursorPos;

begin
  If FRecordCount>0 then
    SetCurrentRecord(FactiveRecord);
end;

Procedure TDataset.UpdateRecord;

begin
  if not (State in dsEditModes) then
    DatabaseErrorFmt(SNotEditing, [Name], Self);
  DataEvent(deUpdateRecord, 0);
end;

Function TDataSet.UpdateStatus: TUpdateStatus;

begin
  Result:=usUnmodified;
end;

Procedure TDataset.RemoveField (Field : TField);

begin
  //!! To be implemented
end;

procedure TDataSet.SetConstraints(Value: TCheckConstraints);
begin
  FConstraints.Assign(Value);
end;

Function TDataset.Getfieldcount : Longint;

begin
  Result:=FFieldList.Count;
end;

Procedure TDataset.ShiftBuffersBackward;

var TempBuf : pointer;

begin
  TempBuf := pbufferaty(FBuffers)^[0];
  move(pbufferaty(FBuffers)^[1],pbufferaty(FBuffers)^[0],
                  (fbuffercount)*sizeof(pbufferaty(FBuffers)^[0]));
  pbufferaty(FBuffers)^[buffercount]:=TempBuf;
end;

Procedure TDataset.ShiftBuffersForward;

var TempBuf : pointer;

begin
  TempBuf := pbufferaty(FBuffers)^[FBufferCount];
  move(pbufferaty(FBuffers)^[0],pbufferaty(FBuffers)^[1],
                               (fbuffercount)*sizeof(pbufferaty(FBuffers)^[0]));
  pbufferaty(FBuffers)^[0]:=TempBuf;
end;

function TDataset.GetFieldValues(const Fieldname: string): Variant;

var i: Integer;
    FieldList: TList;
begin
  FieldList := TList.Create;
  try
    GetFieldList(FieldList, FieldName);
    if FieldList.Count>1 then begin
      Result := VarArrayCreate([0, FieldList.Count - 1], varVariant);
      for i := 0 to FieldList.Count - 1 do
        Result[i] := TField(FieldList[i]).Value;
    end else
      Result := FieldByName(FieldName).Value;
  finally
    FieldList.Free;
  end;
end;

procedure TDataset.SetFieldValues(const Fieldname: string; Value: Variant);

var
  i : Integer;
  FieldList: TList;
begin
  if VarIsArray(Value) then begin
    FieldList := TList.Create;
    try
      GetFieldList(FieldList, FieldName);
      for i := 0 to FieldList.Count -1 do
        TField(FieldList[i]).Value := Value[i];
    finally
      FieldList.Free;
    end;
  end else
    FieldByName(Fieldname).Value := Value;
end;

Function TDataset.Locate(const keyfields: string; const keyvalues: Variant; options: TLocateOptions) : boolean;

begin
  CheckBiDirectional;
  Result := False;
end;

Function TDataset.Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant;

begin
  CheckBiDirectional;
  Result := Null;
end;


Procedure TDataset.UnRegisterDataSource(ADatasource : TDatasource);

begin
  FDataSources.Remove(ADataSource);
end;

{------------------------------------------------------------------------------}
{ IProviderSupport methods}

procedure TDataset.PSEndTransaction(Commit: Boolean);
begin
  DatabaseError('Provider support not available', Self);
end;

procedure TDataset.PSExecute;
begin
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSExecuteStatement(const ASQL: string; AParams: TParams;
  ResultSet: Pointer): Integer;
begin
  Result := 0;
  DatabaseError('Provider support not available', Self);
end;

procedure TDataset.PSGetAttributes(List: TList);
begin
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetCommandText: string;
begin
  Result := '';
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetCommandType: TPSCommandType;
begin
  Result := ctUnknown;
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetDefaultOrder: TIndexDef;
begin
  Result := nil;
  //DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetIndexDefs(IndexTypes: TIndexOptions): TIndexDefs;
begin
  Result := nil;
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetKeyFields: string;
begin
  Result := '';
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetParams: TParams;
begin
  Result := nil;
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetQuoteChar: string;
begin
  Result := '';
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetTableName: string;
begin
  Result := '';
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSGetUpdateException(E: Exception; Prev: EUpdateError
  ): EUpdateError;
begin
  if Prev <> nil then
    Result := EUpdateError.Create(E.Message, '', 0, Prev.ErrorCode, E)
  else
    Result := EUpdateError.Create(E.Message, '', 0, 0, E)
end;

function TDataset.PSInTransaction: Boolean;
begin
  Result := False;
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSIsSQLBased: Boolean;
begin
  Result := False;
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSIsSQLSupported: Boolean;
begin
  Result := False;
  DatabaseError('Provider support not available', Self);
end;

procedure TDataset.PSReset;
begin
  //DatabaseError('Provider support not available', Self);
end;

procedure TDataset.PSSetCommandText(const CommandText: string);
begin
  DatabaseError('Provider support not available', Self);
end;

procedure TDataset.PSSetParams(AParams: TParams);
begin
  DatabaseError('Provider support not available', Self);
end;

procedure TDataset.PSStartTransaction;
begin
  DatabaseError('Provider support not available', Self);
end;

function TDataset.PSUpdateRecord(UpdateKind: TUpdateKind; Delta: TDataSet
  ): Boolean;
begin
  Result := False;
  DatabaseError('Provider support not available', Self);
end;

{------------------------------------------------------------------------------}


{ ---------------------------------------------------------------------
    TFieldDef
  ---------------------------------------------------------------------}

Constructor TFieldDef.Create(ACollection : TCollection);

begin
  Inherited create(ACollection);
  FFieldNo:=Index+1;
end;

Constructor TFieldDef.Create(AOwner: TFieldDefs; const AName: string;
      ADataType: TFieldType; ASize: Integer; ARequired: Boolean; AFieldNo: Longint);

begin
{$ifdef dsdebug }
  Writeln('TFieldDef.Create : ',Aname,'(',AFieldNo,')');
{$endif}
  Inherited Create(AOwner);
  Name:=Aname;
  FDatatype:=ADatatype;
  FSize:=ASize;
  FRequired:=ARequired;
  FPrecision:=-1;
  FFieldNo:=AFieldNo;
end;

Destructor TFieldDef.Destroy;

begin
  Inherited destroy;
end;

procedure TFieldDef.Assign(APersistent: TPersistent);
var fd: TFieldDef;
begin
  fd := nil;
  if APersistent is TFieldDef then
    fd := APersistent as TFieldDef;
  if Assigned(fd) then begin
    Collection.BeginUpdate;
    try
      Name := fd.Name;
      DataType := fd.DataType;
      Size := fd.Size;
      Precision := fd.Precision;
      FRequired := fd.Required;
    finally
      Collection.EndUpdate;
    end;
  end else
  inherited Assign(APersistent);
end;

Function TFieldDef.CreateField(AOwner: TComponent): TField;

Var TheField : TFieldClass;

begin
{$ifdef dsdebug}
  Writeln ('Creating field '+FNAME);
{$endif dsdebug}
  TheField:=GetFieldClass;
  if TheField=Nil then
    DatabaseErrorFmt(SUnknownFieldType,[FName]);
  Result:=Thefield.Create(AOwner);
  Try
    Result.Size:=FSize;
    Result.Required:=FRequired;
    Result.FFieldName:=FName;
    Result.FDisplayLabel:=DisplayName;
    Result.FFieldNo:=Self.FieldNo;
    Result.SetFieldType(DataType);
    Result.FReadOnly:= (faReadOnly in Attributes);
{$ifdef dsdebug}
    Writeln ('TFieldDef.CReateField : Trying to set dataset');
{$endif dsdebug}
{$ifdef dsdebug}
    Writeln ('TFieldDef.CReateField : Result Fieldno : ',Result.FieldNo,' Self : ',FieldNo);
{$endif dsdebug}
    Result.Dataset:=TFieldDefs(Collection).Dataset;
    If (Result is TFloatField) then
      TFloatField(Result).Precision:=FPrecision;
    if (Result is TBCDField) then
      TBCDField(Result).Precision:=FPrecision;
    if (Result is TFmtBCDField) then
      TFmtBCDField(Result).Precision:=FPrecision;
  except
    Result.Free;
    Raise;
  end;

end;

procedure TFieldDef.SetAttributes(AValue: TFieldAttributes);
begin
  FAttributes := AValue;
  Changed(False);
end;

procedure TFieldDef.SetDataType(AValue: TFieldType);
begin
  FDataType := AValue;
  Changed(False);
end;

procedure TFieldDef.SetPrecision(const AValue: Longint);
begin
  FPrecision := AValue;
  Changed(False);
end;

procedure TFieldDef.SetSize(const AValue: Integer);
begin
  FSize := AValue;
  Changed(False);
end;

procedure TFieldDef.SetRequired(const AValue: Boolean);
begin
  FRequired := AValue;
  Changed(False);
end;

Function TFieldDef.GetFieldClass : TFieldClass;

begin
  //!! Should be owner as tdataset but that doesn't work ??

  If Assigned(Collection) And
     (Collection is TFieldDefs) And
     Assigned(TFieldDefs(Collection).Dataset) then
    Result:=TFieldDefs(Collection).Dataset.GetFieldClass(FDataType)
  else
    Result:=Nil;
end;

{ ---------------------------------------------------------------------
    TFieldDefs
  ---------------------------------------------------------------------}

{
destructor TFieldDefs.Destroy;

begin
  FItems.Free;
  // This will destroy all fielddefs since we own them...
  Inherited Destroy;
end;
}

procedure TFieldDefs.Add(const AName: string; ADataType: TFieldType);

begin
  Add(AName,ADatatype,0,False);
end;

procedure TFieldDefs.Add(const AName: string; ADataType: TFieldType; ASize : Word);

begin
  Add(AName,ADatatype,ASize,False);
end;

procedure TFieldDefs.Add(const AName: string; ADataType: TFieldType; ASize: Word;
  ARequired: Boolean);

begin
  If Length(AName)=0 Then
    DatabaseError(SNeedFieldName);
  // the fielddef will register itself here as a owned component.
  // fieldno is 1 based !
  BeginUpdate;
  try
    TFieldDef.Create(Self,AName,ADataType,ASize,Arequired,Count+1);
  finally
    EndUpdate;
  end;
end;

function TFieldDefs.GetItem(Index: Longint): TFieldDef;

begin
  Result := TFieldDef(inherited Items[Index]);
end;

procedure TFieldDefs.SetItem(Index: Longint; const AValue: TFieldDef);
begin
  inherited Items[Index] := AValue;
end;

constructor TFieldDefs.Create(ADataset: TDataset);
begin
  Inherited Create(ADataset, Owner, TFieldDef);
end;

procedure TFieldDefs.Assign(FieldDefs: TFieldDefs);

Var I : longint;

begin
  Clear;
  For i:=0 to FieldDefs.Count-1 do
    With FieldDefs[i] do
      Add(Name,DataType,Size,Required);
end;

function TFieldDefs.Find(const AName: string): TFieldDef;
begin
  Result := (Inherited Find(AName)) as TFieldDef;
  if Result=nil then DatabaseErrorFmt(SFieldNotFound,[AName],FDataset);
end;

{
procedure TFieldDefs.Clear;

Var I : longint;

begin
  For I:=FItems.Count-1 downto 0 do
    TFieldDef(Fitems[i]).Free;
  FItems.Clear;
end;
}

procedure TFieldDefs.Update;

begin
  if not Updated then
    begin
    If Assigned(Dataset) then
      DataSet.InitFieldDefs;
    Updated := True;
    end;
end;

function TFieldDefs.MakeNameUnique(const AName: String): string;
var DblFieldCount : integer;
begin
  DblFieldCount := 0;
  Result := AName;
  while assigned(inherited Find(Result)) do
    begin
    inc(DblFieldCount);
    Result := AName + '_' + IntToStr(DblFieldCount);
    end;
end;

Function TFieldDefs.AddFieldDef : TFieldDef;

begin
  Result:=TFieldDef.Create(Self,'',ftUnknown,0,False,Count+1);
end;

{ ---------------------------------------------------------------------
    TField
  ---------------------------------------------------------------------}

Const
  SBCD = 'BCD';
  SBoolean = 'Boolean';
  SDateTime = 'TDateTime';
  SFloat = 'Float';
  SInteger = 'Integer';
  SLargeInt = 'LargeInt';
  SVariant = 'Variant';
  SString = 'String';
  SBytes = 'Bytes';

constructor TField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FVisible:=True;
  FValidChars:=[#0..#255];

  FProviderFlags := [pfInUpdate,pfInWhere];
end;

destructor TField.Destroy;

begin
  IF Assigned(FDataSet) then
    begin
    FDataSet.Active:=False;
    if Assigned(FFields) then
      FFields.Remove(Self);
    end;
  FLookupList.Free;
  Inherited Destroy;
end;

function TField.AccessError(const TypeName: string): EDatabaseError;

begin
  Result:=EDatabaseError.CreateFmt(SinvalidTypeConversion,[TypeName,FFieldName]);
end;

procedure TField.Assign(Source: TPersistent);

begin
  if Source = nil then Clear
  else if Source is TField then begin
    Value := TField(Source).Value;
  end else
    inherited Assign(Source);
end;

procedure TField.AssignValue(const AValue: TVarRec);
  procedure Error;
  begin
    DatabaseErrorFmt(SFieldValueError, [DisplayName]);
  end;

begin
  with AValue do
    case VType of
      vtInteger:
        AsInteger := VInteger;
      vtBoolean:
        AsBoolean := VBoolean;
      vtChar:
        AsString := VChar;
      vtExtended:
        AsFloat := VExtended^;
      vtString:
        AsString := VString^;
      vtPointer:
        if VPointer <> nil then Error;
      vtPChar:
        AsString := VPChar;
      vtObject:
        if (VObject = nil) or (VObject is TPersistent) then
          Assign(TPersistent(VObject))
        else
          Error;
      vtAnsiString:
        AsString := string(VAnsiString);
      vtCurrency:
        AsCurrency := VCurrency^;
      vtVariant:
        if not VarIsClear(VVariant^) then Self.Value := VVariant^;
      vtWideString:
        AsWideString := WideString(VWideString);
      vtInt64:
        AsLargeInt := VInt64^;
    else
      Error;
    end;
end;

procedure TField.Change;

begin
  If Assigned(FOnChange) Then
    FOnChange(Self);
end;

procedure TField.CheckInactive;

begin
  If Assigned(FDataSet) then
    FDataset.CheckInactive;
end;

procedure TField.Clear;

begin
  if FieldKind in [fkData, fkInternalCalc] then
    SetData(Nil);
end;

procedure TField.DataChanged;

begin
  FDataset.DataEvent(deFieldChange,ptrint(Self));
end;

procedure TField.FocusControl;
var
  Field1: TField;
begin
  Field1 := Self;
  FDataSet.DataEvent(deFocusControl,ptrint(@Field1));
end;

procedure TField.FreeBuffers;

begin
  // Empty. Provided for backward compatibiliy;
  // TDataset manages the buffers.
end;

function TField.GetAsBCD: TBCD;
begin
  raise AccessError(SBCD);
{$ifdef FPC}
  result:= 0; //compiler warning
{$endif}
end;

function TField.GetAsBoolean: Boolean;
begin
  raise AccessError(SBoolean);
  result:= false; //compiler warning
end;

function TField.GetAsBytes: TBytes;
begin
  SetLength(Result, DataSize);
  if assigned(result) and not GetData(@Result[0], False) then
    Result := nil;
end;

function TField.GetAsDateTime: TDateTime;

begin
  raise AccessError(SdateTime);
  result:= 0; //compiler warning
end;

function TField.GetAsFloat: Double;

begin
  raise AccessError(SDateTime);
  result:= 0; //compiler warning
end;

function TField.GetAsLongint: Longint;

begin
  raise AccessError(SInteger);
  result:= 0; //compiler warning
end;

function TField.GetAsVariant: Variant;

begin
  raise AccessError(SVariant);
  result:= 0; //compiler warning
end;


function TField.GetAsInteger: Integer;

begin
  Result:=GetAsLongint;
end;

function TField.GetAsString: string;

begin
  Result := GetClassDesc;
end;

function TField.GetAsWideString: WideString;
begin
  Result := GetAsString;
end;

function TField.GetOldValue: Variant;

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsOldValue);
    Result := GetAsVariant;
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

function TField.GetNewValue: Variant;

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsNewValue);
    Result := GetAsVariant;
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

procedure TField.SetNewValue(const AValue: Variant);

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsNewValue);
    SetAsVariant(AValue);
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

function TField.GetCurValue: Variant;

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsCurValue);
    Result := GetAsVariant;
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

function TField.GetCanModify: Boolean;

begin
  Result:=Not ReadOnly;
  If Result then
    begin
    Result := FieldKind in [fkData, fkInternalCalc];
    if Result then
      begin
      Result:=Assigned(DataSet) and Dataset.Active;
      If Result then
        Result:= DataSet.CanModify;
      end;
    end;
end;

function TField.GetClassDesc: String;
var ClassN : string;
begin
  ClassN := copy(ClassName,2,pos('Field',ClassName)-2);
  if isNull then
    result := '(' + LowerCase(ClassN) + ')'
   else
    result := '(' + UpperCase(ClassN) + ')';
end;

function TField.GetData(Buffer: Pointer): Boolean;

begin
  Result:=GetData(Buffer,True);
end;

function TField.GetData(Buffer: Pointer; NativeFormat : Boolean): Boolean;

begin
  IF FDataset=Nil then
    DatabaseErrorFmt(SNoDataset,[FieldName]);
  If FVAlidating then
    begin
    result:=assigned(FValueBuffer);
    If Result and assigned(Buffer) then
      Move (FValueBuffer^,Buffer^ ,DataSize);
    end
  else
    Result:=FDataset.GetFieldData(Self,Buffer,NativeFormat);
end;

function TField.GetDataSize: Integer;

begin
  Result:=0;
end;

function TField.GetDefaultWidth: Longint;

begin
  Result:=10;
end;

function TField.GetDisplayName  : String;

begin
  If FDisplayLabel<>'' then
    result:=FDisplayLabel
  else
    Result:=FFieldName;
end;

Function TField.IsDisplayStored : Boolean;

begin
  Result:=(DisplayLabel<>FieldName);
end;

function TField.GetLookupList: TLookupList;
begin
  if not Assigned(FLookupList) then
    FLookupList := TLookupList.Create;
  Result := FLookupList;
end;

procedure TField.CalcLookupValue;
begin
  if FLookupCache then
    Value := LookupList.ValueOfKey(FDataSet.FieldValues[FKeyFields])
  else if Assigned(FLookupDataSet) and FDataSet.Active then
    Value := FLookupDataSet.Lookup(FLookupKeyfields, FDataSet.FieldValues[FKeyFields], FLookupresultField);
end;

function TField.getIndex : longint;

begin
  If Assigned(FDataset) then
    Result:=FDataset.FFieldList.IndexOf(Self)
  else
    Result:=-1;
end;

function TField.GetLookup: Boolean;
begin
  Result := FieldKind = fkLookup;
end;

function TField.GetAsLargeInt: LargeInt;
begin
  Raise AccessError(SLargeInt);
  result:= 0; //compiler warning
end;

function TField.GetAsCurrency: Currency;
begin
  Result := GetAsFloat;
end;

procedure TField.SetAlignment(const AValue: TAlignMent);
begin
  if FAlignment <> AValue then
    begin
    FAlignment := Avalue;
    PropertyChanged(false);
    end;
end;

procedure TField.SetIndex(const AValue: Integer);
begin
  if FFields <> nil then FFields.SetFieldIndex(Self, AValue)
end;

procedure TField.SetAsCurrency(AValue: Currency);
begin
  SetAsFloat(AValue);
end;

function TField.GetIsNull: Boolean;

begin
  Result:=Not(GetData (Nil));
end;

function TField.GetParentComponent: TComponent;

begin
  Result := DataSet;
end;

procedure TField.GetText(var AText: string; ADisplayText: Boolean);

begin
  AText:=GetAsString;
end;

function TField.HasParent: Boolean;

begin
  HasParent:=True;
end;

function TField.IsValidChar(InputChar: Char): Boolean;

begin
  // FValidChars must be set in Create.
  Result:=InputChar in FValidChars;
end;

procedure TField.RefreshLookupList;
var
  tmpActive: Boolean;
begin
  if not Assigned(FLookupDataSet) or (Length(FLookupKeyfields) = 0)
  or (Length(FLookupresultField) = 0) or (Length(FKeyFields) = 0) then
    Exit;
    
  tmpActive := FLookupDataSet.Active;
  try
    FLookupDataSet.Active := True;
    FFields.CheckFieldNames(FKeyFields);
    FLookupDataSet.Fields.CheckFieldNames(FLookupKeyFields);
    FLookupDataset.FieldByName(FLookupResultField); // I presume that if it doesn't exist it throws exception, and that a field with null value is still valid
    LookupList.Clear; // have to be F-less because we might be creating it here with getter!

    FLookupDataSet.DisableControls;
    try
      FLookupDataSet.First;
      while not FLookupDataSet.Eof do
      begin
        FLookupList.Add(FLookupDataSet.FieldValues[FLookupKeyfields], FLookupDataSet.FieldValues[FLookupResultField]);
        FLookupDataSet.Next;
      end;
    finally
      FLookupDataSet.EnableControls;
    end;
  finally
    FLookupDataSet.Active := tmpActive;
  end;
end;

procedure TField.Notification(AComponent: TComponent; Operation: TOperation);

begin
  Inherited Notification(AComponent,Operation);
  if (Operation = opRemove) and (AComponent = FLookupDataSet) then
    FLookupDataSet := nil;
end;

procedure TField.PropertyChanged(LayoutAffected: Boolean);

begin
  If (FDataset<>Nil) and (FDataset.Active) then
    If LayoutAffected then
      FDataset.DataEvent(deLayoutChange,0)
    else
      FDataset.DataEvent(deDatasetchange,0);
end;

procedure TField.ReadState(Reader: TReader);

begin
  inherited ReadState(Reader);
  if Reader.Parent is TDataSet then
    DataSet := TDataSet(Reader.Parent);
end;

procedure TField.SetAsBCD(const AValue: TBCD);
begin
  Raise AccessError(SBCD);
end;

procedure TField.SetAsBytes(const AValue: TBytes);
begin
  raise AccessError(SBytes);
end;

procedure TField.SetAsBoolean(AValue: Boolean);

begin
  Raise AccessError(SBoolean);
end;

procedure TField.SetAsDateTime(AValue: TDateTime);

begin
  Raise AccessError(SDateTime);
end;

function TField.getasdate: tdatetime;
begin
 raise accesserror(sdatetime);
 result:= 0; //compiler warning
end;

function TField.getastime: tdatetime;
begin
 raise accesserror(sdatetime);
 result:= 0; //compiler warning
end;

procedure TField.setasdate(avalue: tdatetime);
begin
 raise accesserror(sdatetime);
end;

procedure TField.setastime(avalue: tdatetime);
begin
 raise accesserror(sdatetime);
end;

procedure TField.SetAsFloat(AValue: Double);

begin
  Raise AccessError(SFloat);
end;

procedure TField.SetAsVariant(const AValue: Variant);

begin
  if VarIsNull(AValue) then
    Clear
  else
    try
      SetVarValue(AValue);
    except
      on EVariantError do DatabaseErrorFmt(SFieldValueError, [DisplayName]);
    end;
end;


procedure TField.SetAsLongint(AValue: Longint);

begin
  Raise AccessError(SInteger);
end;

procedure TField.SetAsInteger(AValue: Integer);

begin
  SetAsLongint(AValue);
end;

procedure TField.SetAsLargeint(AValue: Largeint);
begin
  Raise AccessError(SLargeInt);
end;

procedure TField.SetAsString(const AValue: string);

begin
  Raise AccessError(SString);
end;

procedure TField.SetAsWideString(const aValue: WideString);
begin
  SetAsString(aValue);
end;

function TField.getasguid: tguid;
begin
 result:= stringtoguid(asstring);
end;

procedure TField.setasguid(const avalue: tguid);
begin
 asstring:= guidtostring(avalue);
end;

procedure TField.SetData(Buffer: Pointer);

begin
 SetData(Buffer,True);
end;

procedure TField.SetData(Buffer: Pointer; NativeFormat : Boolean);

begin
  If Not Assigned(FDataset) then
    DatabaseErrorFmt(SNoDataset,[FieldName]);
  FDataSet.SetFieldData(Self,Buffer, NativeFormat);
end;

Procedure TField.SetDataset (AValue : TDataset);

begin
{$ifdef dsdebug}
  Writeln ('Setting dataset');
{$endif}
  If AValue=FDataset then exit;
  If Assigned(FDataset) Then
    begin
    FDataset.CheckInactive;
    FDataset.FFieldList.Remove(Self);
    end;
  If Assigned(AValue) then
    begin
    AValue.CheckInactive;
    AValue.FFieldList.Add(Self);
    end;
  FDataset:=AValue;
end;

procedure TField.SetDataType(AValue: TFieldType);

begin
  FDataType := AValue;
end;

procedure TField.SetFieldType(AValue: TFieldType);

begin
  { empty }
end;

procedure TField.SetParentComponent(AParent: TComponent);

begin
  if not (csLoading in ComponentState) then
    DataSet := AParent as TDataSet;
end;

procedure TField.SetSize(AValue: Integer);

begin
  CheckInactive;
  CheckTypeSize(AValue);
  FSize:=AValue;
end;

procedure TField.SetText(const AValue: string);

begin
  AsString:=AValue;
end;

procedure TField.SetVarValue(const AValue: Variant);
begin
  Raise AccessError(SVariant);
end;

procedure TField.Validate(Buffer: Pointer);

begin
  If assigned(OnValidate) Then
    begin
    FValueBuffer:=Buffer;
    FValidating:=True;
    Try
      OnValidate(Self);
    finally
      FValidating:=False;
    end;
    end;
end;

class function Tfield.IsBlob: Boolean;

begin
  Result:=False;
end;

class procedure TField.CheckTypeSize(AValue: Longint);

begin
  If (AValue<>0) and Not IsBlob Then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

// TField private methods

procedure TField.SetEditText(const AValue: string);
begin
  if Assigned(OnSetText) then
    OnSetText(Self, AValue)
  else
    SetText(AValue);
end;

function TField.GetEditText: String;
begin
  SetLength(Result, 0);
  if Assigned(OnGetText) then
    OnGetText(Self, Result, False)
  else
    GetText(Result, False);
end;

function TField.GetDisplayText: String;
begin
  SetLength(Result, 0);
  if Assigned(OnGetText) then
    OnGetText(Self, Result, True)
  else
    GetText(Result, True);
end;

procedure TField.SetDisplayLabel(const AValue: string);
begin
  if FDisplayLabel<>Avalue then
    begin
    FDisplayLabel:=Avalue;
    PropertyChanged(true);
    end;
end;

procedure TField.SetDisplayWidth(const AValue: Longint);
begin
  if FDisplayWidth<>AValue then
    begin
    FDisplayWidth:=AValue;
    PropertyChanged(True);
    end;
end;

function TField.GetDisplayWidth: integer;
begin
  if FDisplayWidth=0 then
    result:=GetDefaultWidth
  else
    result:=FDisplayWidth;
end;

procedure TField.SetLookup(const AValue: Boolean);
const
  ValueToLookupMap: array[Boolean] of TFieldKind = (fkData, fkLookup);
begin
  FieldKind := ValueToLookupMap[AValue];
end;

procedure TField.SetReadOnly(const AValue: Boolean);
begin
  if (FReadOnly<>Avalue) then
    begin
    FReadOnly:=AValue;
    PropertyChanged(True);
    end;
end;

procedure TField.SetVisible(const AValue: Boolean);
begin
  if FVisible<>Avalue then
    begin
    FVisible:=AValue;
    PropertyChanged(True);
    end;
end;

function TField.getasunicodestring: unicodestring;
begin
 result:= getasstring;
end;

procedure TField.setasunicodestring(const avalue: unicodestring);
begin
 setasstring(avalue);
end;

{ ---------------------------------------------------------------------
    TStringField
  ---------------------------------------------------------------------}


constructor TStringField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftString);
  FFixedChar := False;
  FTransliterate := False;
  FSize:=20;
end;

procedure TStringField.SetFieldType(AValue: TFieldType);
begin
  if avalue in [ftString, ftFixedChar] then
    SetDataType(AValue);
end;

class procedure TStringField.CheckTypeSize(AValue: Longint);

begin
// A size of 0 is allowed, since for example Firebird allows
// a query like: 'select '' as fieldname from table' which
// results in a string with size 0.
  If (AValue<0) Then
    databaseErrorFmt(SInvalidFieldSize,[AValue])
end;

function TStringField.GetAsBoolean: Boolean;

Var S : String;

begin
  S:=GetAsString;
  result := (Length(S)>0) and (Upcase(S[1]) in ['T',YesNoChars[True]]);
end;

function TStringField.GetAsDateTime: TDateTime;

begin
  Result:=StrToDateTime(GetAsString);
end;

function TStringField.GetAsFloat: Double;

begin
  Result:=StrToFloat(GetAsString);
end;

function TStringField.GetAsLongint: Longint;

begin
  Result:=StrToInt(GetAsString);
end;

function TStringField.GetAsString: string;

begin
  If Not GetValue(Result) then
    Result:='';
end;

function TStringField.GetAsVariant: Variant;

Var s : string;

begin
  If GetValue(s) then
    Result:=s
  else
    Result:=Null;
end;


function TStringField.GetDataSize: Integer;

begin
  Result:=Size+1;
end;

function TStringField.GetDefaultWidth: Longint;

begin
  result:=Size;
end;

Procedure TStringField.GetText(var AText: string; ADisplayText: Boolean);

begin
    AText:=GetAsString;
end;

function TStringField.GetValue(var AValue: string): Boolean;

Var Buf, TBuf : TStringFieldBuffer;
    DynBuf, TDynBuf : Array of char;

begin
  if DataSize <= dsMaxStringSize then
    begin
    Result:=GetData(@Buf);
    buf[Size]:=#0;  //limit string to Size
    If Result then
      begin
      if transliterate then
        begin
        DataSet.Translate(Buf,TBuf,False);
        AValue:=TBuf;
        end
      else
        AValue:=Buf
      end
    end
  else
    begin
    SetLength(DynBuf,DataSize);
    Result:=GetData(@DynBuf[0]);
    Dynbuf[Size]:=#0;  //limit string to Size
    If Result then
      begin
      if transliterate then
        begin
        SetLength(TDynBuf,DataSize);
        DataSet.Translate(@DynBuf[0],@TDynBuf[0],False);
        AValue:=pchar(TDynBuf);
        end
      else
        AValue:=pchar(DynBuf);
      end
    end;
end;

procedure TStringField.SetAsBoolean(AValue: Boolean);

begin
  If AValue Then
    SetAsString('T')
  else
    SetAsString('F');
end;

procedure TStringField.SetAsDateTime(AValue: TDateTime);

begin
  SetAsString(DateTimeToStr(AValue));
end;

procedure TStringField.SetAsFloat(AValue: Double);

begin
  SetAsString(FloatToStr(AValue));
end;

procedure TStringField.SetAsLongint(AValue: Longint);

begin
  SetAsString(intToStr(AValue));
end;

procedure TStringField.SetAsString(const AValue: string);

var Buf      : TStringFieldBuffer;

begin
  IF Length(AValue)=0 then
    begin
    Buf := #0;
    SetData(@buf);
    end
  else if FTransliterate then
    begin
    DataSet.Translate(@AValue[1],Buf,True);
    Buf[DataSize-1] := #0;
    SetData(@buf);
    end
  else
    begin
    // The data is copied into the buffer, since some TDataset descendents copy
    // the whole buffer-length in SetData. (See bug 8477)
{$ifdef FPC}
    Buf := AValue;
{$else}
    copycharbuf(avalue,sizeof(buf),buf);
{$endif}
    // If length(AValue) > Datasize the buffer isn't terminated properly
    Buf[DataSize-1] := #0;
    SetData(@Buf);
    end;
end;

procedure TStringField.SetVarValue(const AValue: Variant);
begin
  SetAsString(AValue);
end;

{ ---------------------------------------------------------------------
    TWideStringField
  ---------------------------------------------------------------------}

class procedure TWideStringField.CheckTypeSize(aValue: Integer);
begin
// A size of 0 is allowed, since for example Firebird allows
// a query like: 'select '' as fieldname from table' which
// results in a string with size 0.
  If (AValue<0) Then
    databaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

constructor TWideStringField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftWideString);
end;

procedure TWideStringField.SetFieldType(AValue: TFieldType);
begin
  if avalue in [ftWideString, ftFixedWideChar] then
    SetDataType(AValue);
end;

function TWideStringField.GetValue(var aValue: WideString): Boolean;
var
  FixBuffer : array[0..dsMaxStringSize div 2] of WideChar;
  DynBuffer : array of WideChar;
  Buffer    : PWideChar;
begin
  if DataSize <= dsMaxStringSize then begin
    Result := GetData(@FixBuffer, False);
    FixBuffer[Size]:=#0;     //limit string to Size
    aValue := FixBuffer;
  end else begin
    SetLength(DynBuffer, Succ(Size));
    Buffer := PWideChar(DynBuffer);
    Result := GetData(Buffer, False);
    Buffer[Size]:=#0;     //limit string to Size
    if Result then
      aValue := Buffer;
  end;
end;

function TWideStringField.GetAsString: string;
begin
  Result := GetAsWideString;
end;

procedure TWideStringField.SetAsString(const aValue: string);
begin
  SetAsWideString(aValue);
end;

function twidestringfield.getasunicodestring: unicodestring;
begin
  result:= getaswidestring;
end;

procedure twidestringfield.setasunicodestring(const avalue: unicodestring);
begin
  setaswidestring(avalue);
end;

function TWideStringField.GetAsVariant: Variant;
var
  ws: WideString;
begin
  if GetValue(ws) then
    Result := ws
  else
    Result := Null;
end;

procedure TWideStringField.SetVarValue(const aValue: Variant);
begin
  SetAsWideString(aValue);
end;

function TWideStringField.GetAsWideString: WideString;
begin
  if not GetValue(Result) then
    Result := '';
end;

procedure TWideStringField.SetAsWideString(const aValue: WideString);
const
  NullWideChar : WideChar = #0;
var
  Buffer : PWideChar;
begin
  if Length(aValue)>0 then
    Buffer := PWideChar(@aValue[1])
  else
    Buffer := @NullWideChar;
  SetData(Buffer, False);
end;

function TWideStringField.GetDataSize: Integer;
begin
  Result :=
    (Size + 1) * 2;
end;


{ ---------------------------------------------------------------------
    TNumericField
  ---------------------------------------------------------------------}


constructor TNumericField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  AlignMent:=taRightJustify;
end;

class procedure TNumericField.CheckTypeSize(AValue: Longint);
begin
  // This procedure is only added because some TDataset descendents have the
  // but that they set the Size property as if it is the DataSize property.
  // To avoid problems with those descendents, allow values <= 16.
  If (AValue>16) Then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

procedure TNumericField.RangeError(AValue, Min, Max: Double);

begin
  DatabaseErrorFMT(SRangeError,[AValue,Min,Max,FieldName]);
end;

procedure TNumericField.SetDisplayFormat(const AValue: string);

begin
 If FDisplayFormat<>AValue then
   begin
   FDisplayFormat:=AValue;
   PropertyChanged(True);
   end;
end;

procedure TNumericField.SetEditFormat(const AValue: string);

begin
  If FEDitFormat<>AValue then
    begin
    FEDitFormat:=AVAlue;
    PropertyChanged(True);
    end;
end;

function TNumericField.GetAsBoolean: Boolean;
begin
  Result:=GetAsInteger<>0;
end;

procedure TNumericField.SetAsBoolean(AValue: Boolean);
begin
  if AValue then
    SetAsLongint(1)
  else
    SetAsLongint(0);
end; 

{ ---------------------------------------------------------------------
    TLongintField
  ---------------------------------------------------------------------}


constructor TLongintField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDatatype(ftinteger);
  FMinRange:=Low(LongInt);
  FMaxRange:=High(LongInt);
  FValidchars:=['+','-','0'..'9'];
end;

function TLongintField.GetAsFloat: Double;

begin
  Result:=GetAsLongint;
end;

function TLongintField.GetAsLargeint: Largeint;
begin
  Result:=GetAsLongint;
end;

function TLongintField.GetAsLongint: Longint;

begin
  If Not GetValue(Result) then
    Result:=0;
end;

function TLongintField.GetAsVariant: Variant;

Var L : Longint;

begin
  If GetValue(L) then
    Result:=L
  else
    Result:=Null;
end;

function TLongintField.GetAsString: string;

Var L : Longint;

begin
  If GetValue(L) then
    Result:=IntTostr(L)
  else
    Result:='';
end;

function TLongintField.GetDataSize: Integer;

begin
  Result:=SizeOf(Longint);
end;

procedure TLongintField.GetText(var AText: string; ADisplayText: Boolean);

var l : longint;
    fmt : string;

begin
  Atext:='';
  If Not GetValue(l) then exit;
  If ADisplayText or (FEditFormat='') then
    fmt:=FDisplayFormat
  else
    fmt:=FEditFormat;
  If length(fmt)<>0 then
    AText:=FormatFloat(fmt,L)
  else
    Str(L,AText);
end;

function TLongintField.GetValue(var AValue: Longint): Boolean;

Var L : Longint;
    P : PLongint;

begin
  P:=@L;
  Result:=GetData(P);
  If Result then
    Case Datatype of
      ftInteger,ftautoinc  : AValue:=Plongint(P)^;
      ftword               : Avalue:=Pword(P)^;
      ftsmallint           : AValue:=PSmallint(P)^;
    end;
end;

procedure TLongintField.SetAsLargeint(AValue: Largeint);
begin
  if (AValue>=FMinRange) and (AValue<=FMaxRange) then
    SetAsLongint(AValue)
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

procedure TLongintField.SetAsFloat(AValue: Double);

begin
  SetAsLongint(Round(Avalue));
end;

procedure TLongintField.SetAsLongint(AValue: Longint);

begin
  If CheckRange(AValue) then
    SetData(@AValue)
  else
    RangeError(Avalue,FMinrange,FMaxRange);
end;

procedure TLongintField.SetVarValue(const AValue: Variant);
begin
  SetAsLongint(AValue);
end;

procedure TLongintField.SetAsString(const AValue: string);

Var L,Code : longint;

begin
  If length(AValue)=0 then
    Clear
  else
    begin
    Val(AVAlue,L,Code);
    If Code=0 then
      SetAsLongint(L)
    else
      DatabaseErrorFMT(SNotAnInteger,[Avalue]);
    end;
end;

Function TLongintField.CheckRange(AValue : longint) : Boolean;

begin
  result := true;
  if (FMaxValue=0) then
    begin
    if (AValue>FMaxRange) Then result := false;
    end
  else
    if AValue>FMaxValue then result := false;

  if (FMinValue=0) then
    begin
    if (AValue<FMinRange) Then result := false;
    end
  else
    if AValue<FMinValue then result := false;
end;

Procedure TLongintField.SetMaxValue (AValue : longint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMaxValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

Procedure TLongintField.SetMinValue (AValue : longint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMinValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

{ ---------------------------------------------------------------------
    TLargeintField
  ---------------------------------------------------------------------}


constructor TLargeintField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDatatype(ftLargeint);
  FMinRange:=Low(Largeint);
  FMaxRange:=High(Largeint);
  FValidchars:=['+','-','0'..'9'];
end;

function TLargeintField.GetAsFloat: Double;

begin
  Result:=GetAsLargeint;
end;

function TLargeintField.GetAsLargeint: Largeint;

begin
  If Not GetValue(Result) then
    Result:=0;
end;

function TLargeIntField.GetAsVariant: Variant;

Var L : Largeint;

begin
  If GetValue(L) then
    Result:=L
  else
    Result:=Null;
end;

function TLargeintField.GetAsLongint: Longint;

begin
  Result:=GetAsLargeint;
end;

function TLargeintField.GetAsString: string;

Var L : Largeint;

begin
  If GetValue(L) then
    Result:=IntTostr(L)
  else
    Result:='';
end;

function TLargeintField.GetDataSize: Integer;

begin
  Result:=SizeOf(Largeint);
end;

procedure TLargeintField.GetText(var AText: string; ADisplayText: Boolean);

var l : largeint;
    fmt : string;

begin
  Atext:='';
  If Not GetValue(l) then exit;
  If ADisplayText or (FEditFormat='') then
    fmt:=FDisplayFormat
  else
    fmt:=FEditFormat;
  If length(fmt)<>0 then
    AText:=FormatFloat(fmt,L)
  else
    Str(L,AText);
end;

function TLargeintField.GetValue(var AValue: Largeint): Boolean;

type
  PLargeint = ^Largeint;

Var P : PLargeint;

begin
  P:=@AValue;
  Result:=GetData(P);
end;

procedure TLargeintField.SetAsFloat(AValue: Double);

begin
  SetAsLargeint(Round(Avalue));
end;

procedure TLargeintField.SetAsLargeint(AValue: Largeint);

begin
  If CheckRange(AValue) then
    SetData(@AValue)
  else
    RangeError(Avalue,FMinrange,FMaxRange);
end;

procedure TLargeintField.SetAsLongint(AValue: Longint);

begin
  SetAsLargeint(Avalue);
end;

procedure TLargeintField.SetAsString(const AValue: string);

Var L     : largeint;
    code  : longint;

begin
  If length(AValue)=0 then
    Clear
  else
    begin
    Val(AVAlue,L,Code);
    If Code=0 then
      SetAsLargeint(L)
    else
      DatabaseErrorFMT(SNotAnInteger,[Avalue]);
    end;
end;

procedure TLargeintField.SetVarValue(const AValue: Variant);
begin
  SetAsLargeint(AValue);
end;

Function TLargeintField.CheckRange(AValue : largeint) : Boolean;

begin
  result := true;
  if (FMaxValue=0) then
    begin
    if (AValue>FMaxRange) Then result := false;
    end
  else
    if AValue>FMaxValue then result := false;

  if (FMinValue=0) then
    begin
    if (AValue<FMinRange) Then result := false;
    end
  else
    if AValue<FMinValue then result := false;
end;

Procedure TLargeintField.SetMaxValue (AValue : largeint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMaxValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

Procedure TLargeintField.SetMinValue (AValue : largeint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMinValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

{ TSmallintField }

function TSmallintField.GetDataSize: Integer;

begin
  Result:=SizeOf(SmallInt);
end;

constructor TSmallintField.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  SetDataType(ftSmallInt);
  FMinRange:=-32768;
  FMaxRange:=32767;
end;


{ TWordField }

function TWordField.GetDataSize: Integer;

begin
  Result:=SizeOf(Word);
end;

constructor TWordField.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  SetDataType(ftWord);
  FMinRange:=0;
  FMaxRange:=65535;
  FValidchars:=['+','0'..'9'];
end;

{ TAutoIncField }

constructor TAutoIncField.Create(AOwner: TComponent);

begin
  Inherited Create(AOWner);
  SetDataType(ftAutoInc);
  FReadOnly:=True;
  FProviderFlags:=FProviderFlags-[pfInUpdate];
end;

Procedure TAutoIncField.SetAsLongint(AValue : Longint);

begin
  // Some databases allows insertion of explicit values into identity columns
  // (some of them also allows (some not) updating identity columns)
  // So allow it at client side and leave check for server side
  if not(FDataSet.State in [dsFilter,dsSetKey,dsInsert]) then
    DataBaseError(SCantSetAutoIncFields);
  inherited;
end;

{ TFloatField }

procedure TFloatField.SetCurrency(const AValue: Boolean);
begin
  if FCurrency=AValue then exit;
  FCurrency:=AValue;
end;

procedure TFloatField.SetPrecision(const AValue: Longint);
begin
  if (AValue = -1) or (AValue > 1) then
    FPrecision := AValue
  else
    FPrecision := 2;
end;

function TFloatField.GetAsFloat: Double;

begin
  If Not GetData(@Result) Then
    Result:=0.0;
end;

function TFloatField.GetAsVariant: Variant;

Var f : Double;

begin
  If GetData(@f) then
    Result := f
  else
    Result:=Null;
end;

function TFloatField.GetAsLongint: Longint;

begin
  Result:=Round(GetAsFloat);
end;

function TFloatField.GetAsString: string;

Var R : Double;

begin
  If GetData(@R) then
    Result:=FloatToStr(R)
  else
    Result:='';
end;

function TFloatField.GetDataSize: Integer;

begin
  Result:=SizeOf(Double);
end;

procedure TFloatField.GetText(var TheText: string; ADisplayText: Boolean);

Var
    fmt : string;
    E : Double;
    Digits : integer;
    ff: TFloatFormat;

begin
  TheText:='';
  If Not GetData(@E) then exit;
  If ADisplayText or (Length(FEditFormat) = 0) Then
    Fmt:=FDisplayFormat
  else
    Fmt:=FEditFormat;

  Digits := 0;
  if not FCurrency then
    ff := ffGeneral
  else
    begin
    Digits := {$ifdef FPC}defaultformatsettings.{$endif}CurrencyDecimals;
    if ADisplayText then
      ff := ffCurrency
    else
      ff := ffFixed;
    end;


  If fmt<>'' then
    TheText:=FormatFloat(fmt,E)
  else
    TheText:=FloatToStrF(E,ff,FPrecision,Digits);
end;

procedure TFloatField.SetAsFloat(AValue: Double);

begin
  If CheckRange(AValue) then
    SetData(@Avalue)
  else
    RangeError(AValue,FMinValue,FMaxValue);
end;

procedure TFloatField.SetAsLongint(AValue: Longint);

begin
  SetAsFloat(Avalue);
end;

procedure TFloatField.SetAsString(const AValue: string);

Var R : Double;

begin
  If (AValue='') then
    Clear
  else  
    try
      R := StrToFloat(AValue);
      SetAsFloat(R);
    except
      DatabaseErrorFmt(SNotAFloat, [AValue]);
    end;
end;

procedure TFloatField.SetVarValue(const AValue: Variant);
begin
  SetAsFloat(Avalue);
end;

constructor TFloatField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDatatype(ftfloat);
  FPrecision:=15;
  FValidChars := [{$ifdef FPC}defaultformatsettings.{$endif}DecimalSeparator,
                                                  '+', '-', '0'..'9', 'E', 'e'];
end;

Function TFloatField.CheckRange(AValue : Double) : Boolean;

begin
  If (FMinValue<>0) or (FmaxValue<>0) then
    Result:=(AValue>=FMinValue) and (AVAlue<=FMAxValue)
  else
    Result:=True;
end;

{ TCurrencyField }

Constructor TCurrencyField.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  SetDataType(ftCurrency);
  Currency := True;
end;

{ TBooleanField }

function TBooleanField.GetAsBoolean: Boolean;

var b : wordbool;

begin
  If GetData(@b) then
    result := b
  else
    Result:=False;
end;

function TBooleanField.GetAsVariant: Variant;

Var b : wordbool;

begin
  If GetData(@b) then
    Result := b
  else
    Result:=Null;
end;

function TBooleanField.GetAsString: string;

Var B : wordbool;

begin
  If Getdata(@B) then
    Result:=FDisplays[False,B]
  else
    result:='';
end;

function TBooleanField.GetDataSize: Integer;

begin
  Result:=SizeOf(wordBool);
end;

function TBooleanField.GetDefaultWidth: Longint;

begin
  Result:=Length(FDisplays[false,false]);
  If Result<Length(FDisplays[false,True]) then
    Result:=Length(FDisplays[false,True]);
end;

function TBooleanField.GetAsInteger: integer;
begin
   if GetAsBoolean then
    Result:=1
   else
    Result:=0;
end;

procedure TBooleanField.SetAsInteger(AValue: Integer);
begin
  SetAsBoolean(avalue<>0);
end;

procedure TBooleanField.SetAsBoolean(AValue: Boolean);

var b : wordbool;

begin
  b := AValue;
  SetData(@b);
end;

procedure TBooleanField.SetAsString(const AValue: string);

Var Temp : string;

begin
  Temp:=UpperCase(AValue);
  if Temp='' then
    Clear
  else if pos(Temp, FDisplays[True,True])=1 then
    SetAsBoolean(True)
  else if pos(Temp, FDisplays[True,False])=1 then
    SetAsBoolean(False)
  else
    DatabaseErrorFmt(SNotABoolean,[AValue]);
end;

procedure TBooleanField.SetVarValue(const AValue: Variant);
begin
  SetAsBoolean(AValue);
end;

constructor TBooleanField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftBoolean);
  DisplayValues:='True;False';
end;

Procedure TBooleanField.SetDisplayValues(const AValue : String);

Var I : longint;

begin
  If FDisplayValues<>AValue then
    begin
    I:=Pos(';',AValue);
    If (I<2) or (I=Length(AValue)) then
      DatabaseErrorFmt(SInvalidDisplayValues,[AValue]);
    FdisplayValues:=AValue;
    // Store display values and their uppercase equivalents;
    FDisplays[False,True]:=Copy(AValue,1,I-1);
    FDisplays[True,True]:=UpperCase(FDisplays[False,True]);
    FDisplays[False,False]:=Copy(AValue,I+1,Length(AValue)-i);
    FDisplays[True,False]:=UpperCase(FDisplays[False,False]);
    PropertyChanged(True);
    end;
end;

{ TDateTimeField }

procedure TDateTimeField.SetDisplayFormat(const AValue: string);
begin
  if FDisplayFormat<>AValue then begin
    FDisplayFormat:=AValue;
    PropertyChanged(True);
  end;
end;

function TDateTimeField.GetAsDateTime: TDateTime;

begin
  If Not GetData(@Result,False) then
    Result:=0;
end;

procedure TDateTimeField.SetVarValue(const AValue: Variant);
begin
  SetAsDateTime(AValue);
end;

function TDateTimeField.GetAsVariant: Variant;

Var d : tDateTime;

begin
  If Getdata(@d,False) then
    Result := d
  else
    Result:=Null;
end;

function TDateTimeField.GetAsFloat: Double;

begin
  Result:=GetAsdateTime;
end;


function TDateTimeField.GetAsString: string;

begin
  GetText(Result,False);
end;


function TDateTimeField.GetDataSize: Integer;

begin
  Result:=SizeOf(TDateTime);
end;


procedure TDateTimeField.GetText(var TheText: string; ADisplayText: Boolean);

Var R : TDateTime;
    F : String;

begin
  If Not Getdata(@R,False) then
    TheText:=''
  else
    begin
    If (ADisplayText) and (Length(FDisplayFormat)<>0) then
      F:=FDisplayFormat
    else
      Case DataType of
       ftTime : F:= {$ifdef FPC}defaultformatsettings.{$endif}LongTimeFormat;
       ftDate : F:= {$ifdef FPC}defaultformatsettings.{$endif}ShortDateFormat;
      else
       F:='c'
      end;
    TheText:=FormatDateTime(F,R);
    end;
end;


procedure TDateTimeField.SetAsDateTime(AValue: TDateTime);

begin
  SetData(@Avalue,False);
end;


procedure TDateTimeField.SetAsFloat(AValue: Double);

begin
  SetAsDateTime(AValue);
end;


procedure TDateTimeField.SetAsString(const AValue: string);

Var R : TDateTime;

begin
  if AValue<>'' then
    begin
    R:=StrToDateTime(AVAlue);
    SetData(@R,False);
    end
  else
    SetData(Nil);
end;


constructor TDateTimeField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftDateTime);
end;

function TDateTimeField.getasdate: tdatetime;
begin
 result:= int(getasdatetime);
end;

function TDateTimeField.getastime: tdatetime;
begin
 result:= frac(getasdatetime);
end;

procedure TDateTimeField.setasdate(avalue: tdatetime);
begin
 if datatype = fttime then begin
  databaseerrorfmt(sassigndate,[fieldname],dataset);
 end;
 setasdatetime(avalue);
end;

procedure TDateTimeField.setastime(avalue: tdatetime);
begin
 if datatype = ftdate then begin
  databaseerrorfmt(sassigntime,[fieldname],dataset);
 end;
 setasdatetime(avalue);
end;


{ TDateField }

constructor TDateField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftDate);
end;


{ TTimeField }

constructor TTimeField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftTime);
end;

procedure TTimeField.SetAsString(const AValue: string);
Var R : TDateTime;
begin
  if AValue='' then
    Clear    // set to NULL
  else
    begin
    R:=StrToTime(AVAlue);
    SetData(@R,False);
    end;
end;



{ TBinaryField }

class procedure TBinaryField.CheckTypeSize(AValue: Longint);

begin
  // Just check for really invalid stuff; actual size is
  // dependent on the record...
  If AValue<1 then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

function TBinaryField.GetAsBytes: TBytes;
var B: TBytes;
begin
  SetLength(B, DataSize);
  if not assigned(B) or not GetData(Pointer(B), True) then
    SetLength(Result, 0)
  else if DataType = ftVarBytes then
  begin
    SetLength(Result, PWord(B)^);
    Move(B[sizeof(Word)], Result[0], Length(Result));
  end
  else // ftBytes
    Result := B;
end;


function TBinaryField.GetAsString: string;
var
 B: TBytes;
begin
  B := GetAsBytes;
  if length(B) = 0 then
    Result := ''
  else
    SetString(Result, pchar(@B[0]), length(B) div SizeOf(Char));
end;


function TBinaryField.GetAsVariant: Variant;
var B: TBytes;
    P: Pointer;
begin
  B := GetAsBytes;
  Result := VarArrayCreate([0, length(B)-1], varByte);
  P := VarArrayLock(Result);
  try
    Move(B[0], P^, length(B));
  finally
    VarArrayUnlock(Result);
  end;
end;


procedure TBinaryField.GetText(var TheText: string; ADisplayText: Boolean);

begin
  TheText:=GetAsString;
end;


procedure TBinaryField.SetAsBytes(const AValue: TBytes);
var Buf: array[0..dsMaxStringSize] of byte;
    DynBuf: TBytes;
    Len: Word;
    P: PByte;
begin
  Len := Length(AValue);
  if Len >= DataSize then
    P := @AValue[0]
  else begin
    if DataSize <= dsMaxStringSize then
      P := @Buf[0]
    else begin
      SetLength(DynBuf, DataSize);
      P := @DynBuf[0];
    end;

    if DataType = ftVarBytes then begin
      PWord(P)^ := Len;
      Move(AValue[0], pchar(P)[sizeof(Word)], Len);
    end
    else begin // ftBytes
      Move(AValue[0], P^, Len);
      FillChar(pchar(P)[Len], DataSize-Len, 0); // right pad with #0
    end;
  end;
  SetData(P, True)
end;


procedure TBinaryField.SetAsString(const AValue: string);
var B : TBytes;
begin
  If Length(AValue) = DataSize then
    SetData(PChar(AValue))
  else
  begin
    SetLength(B, Length(AValue) * SizeOf(Char));
    Move(AValue[1], B[0], Length(B));
    SetAsBytes(B);
  end;
end;


procedure TBinaryField.SetText(const AValue: string);

begin
  SetAsString(Avalue);
end;

procedure TBinaryField.SetVarValue(const AValue: Variant);
var P: Pointer;
    B: TBytes;
    Len: integer;
begin
  if VarIsArray(AValue) then
  begin
    P := VarArrayLock(AValue);
    try
      Len := VarArrayHighBound(AValue, 1) + 1;
      SetLength(B, Len);
      Move(P^, B[0], Len);
    finally
      VarArrayUnlock(AValue);
    end;
    SetAsBytes(B);
  end
  else
    SetAsString(AValue);
end;


constructor TBinaryField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
end;



{ TBytesField }

function TBytesField.GetDataSize: Integer;

begin
  Result:=Size;
end;


constructor TBytesField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftBytes);
  Size:=16;
end;



{ TVarBytesField }

function TVarBytesField.GetDataSize: Integer;

begin
  Result:=Size+2;
end;


constructor TVarBytesField.Create(AOwner: TComponent);

begin
  INherited Create(AOwner);
  SetDataType(ftvarbytes);
  Size:=16;
end;

{ TBCDField }

class procedure TBCDField.CheckTypeSize(AValue: Longint);

begin
  If not (AValue in [0..4]) then
    DatabaseErrorfmt(SInvalidFieldSize,[Avalue]);
end;

function TBCDField.GetAsCurrency: Currency;

begin
  if not GetData(@Result) then
    result := 0;
end;

function TBCDField.GetAsVariant: Variant;

Var c : system.Currency;

begin
  If GetData(@c) then
    Result := c
  else
    Result:=Null;
end;

function TBCDField.GetAsFloat: Double;

begin
  result := GetAsCurrency;
end;


function TBCDField.GetAsLongint: Longint;

begin
  result := round(GetAsCurrency);
end;


function TBCDField.GetAsString: string;

var c : system.currency;

begin
  If GetData(@C) then
    Result:=CurrToStr(C)
  else
    Result:='';
end;

function TBCDField.GetValue(var AValue: Currency): Boolean;

begin
  Result := GetData(@AValue);
end;

function TBCDField.GetDataSize: Integer;

begin
  result := sizeof(system.currency);
end;

function TBCDField.GetDefaultWidth: Longint;

begin
  if precision > 0 then result := precision
    else result := 10;
end;

procedure TBCDField.GetText(var TheText: string; ADisplayText: Boolean);
var
  c : system.currency;
  fmt: String;
begin
  if GetData(@C) then begin
    if aDisplayText or (FEditFormat='') then
      fmt := FDisplayFormat
    else
      fmt := FEditFormat;
    if fmt<>'' then
      TheText := FormatFloat(fmt,C)
    else if fCurrency then begin
      if aDisplayText then
        TheText := FloatToStrF(C, ffCurrency, FPrecision, 2{digits?})
      else
        TheText := FloatToStrF(C, ffFixed, FPrecision, 2{digits?});
    end else
      TheText := FloatToStrF(C, ffGeneral, FPrecision, 0{digits?});
  end else
    TheText := '';
end;

procedure TBCDField.SetAsCurrency(AValue: Currency);

begin
  If CheckRange(AValue) then
    setdata(@AValue)
  else
    RangeError(AValue,FMinValue,FMaxvalue);
end;

procedure TBCDField.SetVarValue(const AValue: Variant);
begin
  SetAsCurrency(AValue);
end;

Function TBCDField.CheckRange(AValue : Currency) : Boolean;

begin
  If (FMinValue<>0) or (FmaxValue<>0) then
    Result:=(AValue>=FMinValue) and (AVAlue<=FMaxValue)
  else
    Result:=True;
end;

procedure TBCDField.SetAsFloat(AValue: Double);

begin
  SetAsCurrency(AValue);
end;


procedure TBCDField.SetAsLongint(AValue: Longint);

begin
  SetAsCurrency(AValue);
end;


procedure TBCDField.SetAsString(const AValue: string);

begin
  if AValue='' then
    Clear    // set to NULL
  else
    SetAsCurrency(strtocurr(AValue));
end;

constructor TBCDField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FMaxvalue := 0;
  FMinvalue := 0;
  FValidChars := [{$ifdef FPC}defaultformatsettings.{$endif}DecimalSeparator,
                                                            '+', '-', '0'..'9'];
  SetDataType(ftBCD);
  FPrecision := 15;
  Size:=4;
end;


{ TFMTBCDField }

class procedure TFMTBCDField.CheckTypeSize(AValue: Longint);
begin
  If AValue > MAXFMTBcdFractionSize then
    DatabaseErrorfmt(SInvalidFieldSize,[AValue]);
end;

constructor TFMTBCDField.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FMaxValue := nullbcd;
  FMinValue := nullbcd;
  FValidChars := [{$ifdef FPC}defaultformatsettings.{$endif}DecimalSeparator,
                                                            '+', '-', '0'..'9'];
  SetDataType(ftFMTBCD);
// Max.precision for NUMERIC,DECIMAL datatypes supported by some databases:
//  Firebird-18; Oracle,SqlServer-38; MySQL-65; PostgreSQL-1000
  Precision := 15; //default number of digits
  Size:=4; //default number of digits after decimal place
end;

function TFMTBCDField.GetDataSize: Integer;
begin
  Result := sizeof(TBCD);
end;

function TFMTBCDField.GetDefaultWidth: Longint;
begin
  if Precision > 0 then Result := Precision+1
  else Result := inherited GetDefaultWidth;
end;

function TFMTBCDField.GetAsBCD: TBCD;
begin
  if not GetData(@Result) then
    Result := NullBCD;
end;

function TFMTBCDField.GetAsCurrency: Currency;
var bcd: TBCD;
begin
  if GetData(@bcd) then
    BCDToCurr(bcd, Result)
  else
    Result := 0;
end;

function TFMTBCDField.GetAsVariant: Variant;
var bcd: TBCD;
begin
  If GetData(@bcd) then
    Result := VarFMTBcdCreate(bcd)
  else
    Result := Null;
end;

function TFMTBCDField.GetAsFloat: Double;
var bcd: TBCD;
begin
  If GetData(@bcd) then
    Result := BCDToDouble(bcd)
  else
    Result := 0;
end;

function TFMTBCDField.GetAsLongint: Longint;
begin
  Result := round(GetAsFloat);
end;

function TFMTBCDField.GetAsString: string;
var bcd: TBCD;
begin
  If GetData(@bcd) then
    Result:=BCDToStr(bcd)
  else
    Result:='';
end;

procedure TFMTBCDField.GetText(var TheText: string; ADisplayText: Boolean);
var
  bcd: TBCD;
  fmt: String;
begin
  if GetData(@bcd) then begin
    if aDisplayText or (FEditFormat='') then
      fmt := FDisplayFormat
    else
      fmt := FEditFormat;
    if fmt<>'' then
      TheText := BCDToStr(bcd)
      //TheText := FormatBCD(fmt,bcd) //uncomment when formatBCD in fmtbcd.pp will be implemented
    else if fCurrency then begin
      if aDisplayText then
        TheText := BcdToStrF(bcd, ffCurrency, FPrecision, 2)
      else
        TheText := BcdToStrF(bcd, ffFixed, FPrecision, 2);
    end else
      TheText := BcdToStrF(bcd, ffGeneral, FPrecision, FSize);
  end else
    TheText := '';
end;

function TFMTBCDField.GetMaxValue: string;
begin
  Result:=BCDToStr(FMaxValue);
end;

function TFMTBCDField.GetMinValue: string;
begin
  Result:=BCDToStr(FMinValue);
end;

procedure TFMTBCDField.SetMaxValue(const AValue: string);
begin
  FMaxValue:=StrToBCD(AValue);
end;

procedure TFMTBCDField.SetMinValue(const AValue: string);
begin
  FMinValue:=StrToBCD(AValue);
end;

Function TFMTBCDField.CheckRange(AValue: TBCD) : Boolean;
begin
  If (bcdcompare(FMinValue,nullbcd) <> 0) or
                          (bcdcompare(FMaxValue,nullbcd)<> 0) then
    Result:= (bcdcompare(AValue,FMinValue) >= 0) and
             (bcdcompare(AValue,FMaxValue) <= 0)
  else
    Result:=True;
end;

procedure TFMTBCDField.SetAsBCD(const AValue: TBCD);
begin
  if CheckRange(AValue) then
    SetData(@AValue)
  else
    RangeError(bcdtodouble(AValue), BCDToDouble(FMinValue),
                                                BCDToDouble(FMaxValue));
end;

procedure TFMTBCDField.SetAsCurrency(AValue: Currency);
var bcd: TBCD;
begin
  if CurrToBCD(AValue, bcd, 32, Size) then
    SetAsBCD(bcd);
end;

procedure TFMTBCDField.SetVarValue(const AValue: Variant);
begin
  SetAsBCD(VarToBCD(AValue));
end;

procedure TFMTBCDField.SetAsFloat(AValue: Double);
begin
  SetAsBCD(DoubleToBCD(AValue));
end;


procedure TFMTBCDField.SetAsLongint(AValue: Longint);
begin
  SetAsBCD(IntegerToBCD(AValue));
end;


procedure TFMTBCDField.SetAsString(const AValue: string);
begin
  if AValue='' then
    Clear    // set to NULL
  else
    SetAsBCD(StrToBCD(AValue));
end;


{ TBlobField }

Function TBlobField.GetBlobStream(Mode : TBlobStreamMode) : TStream;

begin
  Result:=FDataset.CreateBlobStream(Self,Mode);
end;

procedure TBlobField.FreeBuffers;

begin
end;


function TBlobField.GetAsString: string;
var
  Stream : TStream;
  Len    : Integer;
begin
  Stream := GetBlobStream(bmRead);
  if Stream <> nil then
    With Stream do
      try
        Len := Size;
        SetLength(Result, Len);
        if Len > 0 then
          ReadBuffer(Result[1], Len);
      finally
        Free
      end
  else
    Result := '';
end;

function TBlobField.GetAsWideString: WideString;
var
  Stream : TStream;
  Len    : Integer;
begin
  Stream := GetBlobStream(bmRead);
  if Stream <> nil then
    With Stream do
      try
        Len := Size;
        SetLength(Result,Len div 2);
        if Len > 0 then
          ReadBuffer(Result[1] ,Len);
      finally
        Free
      end
  else
    Result := '';
end;

function TBlobField.GetAsVariant: Variant;

Var s : string;

begin
  if not GetIsNull then
    begin
    s := GetAsString;
    result := s;
    end
  else result := Null;
end;


function TBlobField.GetBlobSize: Longint;
var
  Stream: TStream;
begin
  Stream := GetBlobStream(bmread);
  if Stream <> nil then
    With Stream do
      try
        Result:=Size;
      finally
        Free;
      end
  else
    result := 0;
end;


function TBlobField.GetIsNull: Boolean;

begin
  If Not Modified then
    result:= inherited GetIsnull
  else
    With GetBlobStream(bmread) do
      try
        Result:=(Size=0);
      Finally
        Free;
      end;
end;


procedure TBlobField.GetText(var TheText: string; ADisplayText: Boolean);

begin
  TheText:=inherited GetAsString;
end;


procedure TBlobField.SetAsString(const AValue: string);
var
  Len : Integer;
begin
  With GetBlobStream(bmwrite) do
    try
      Len := Length(Avalue);
      if Len > 0 then
        WriteBuffer(aValue[1], Len);
    finally
      Free;
    end;
end;


procedure TBlobField.SetAsWideString(const AValue: WideString);
var
  Len : Integer;
begin
  With GetBlobStream(bmwrite) do
    try
      Len := Length(Avalue) * 2;
      if Len > 0 then
        WriteBuffer(aValue[1], Len);
    finally
      Free;
    end;
end;


procedure TBlobField.SetText(const AValue: string);

begin
  SetAsString(AValue);
end;

procedure TBlobField.SetVarValue(const AValue: Variant);
begin
  SetAsString(AValue);
end;


constructor TBlobField.Create(AOwner: TComponent);

begin
  Inherited Create(AOWner);
  SetDataType(ftBlob);
end;


procedure TBlobField.Clear;

begin
  GetBlobStream(bmWrite).free;
end;


class function TBlobField.IsBlob: Boolean;

begin
  Result:=True;
end;


procedure TBlobField.LoadFromFile(const FileName: string);

Var S : TFileStream;

begin
  S:=TFileStream.Create(FileName,fmOpenRead);
  try
    LoadFromStream(S);
  finally
    S.Free;
  end;
end;


procedure TBlobField.LoadFromStream(Stream: TStream);

begin
  With GetBlobStream(bmWrite) do
    Try
      CopyFrom(Stream,0);
    finally
      Free;
    end;
end;


procedure TBlobField.SaveToFile(const FileName: string);

Var S : TFileStream;

begin
  S:=TFileStream.Create(FileName,fmCreate);
  try
    SaveToStream(S);
  finally
    S.Free;
  end;
end;


procedure TBlobField.SaveToStream(Stream: TStream);

Var S : TStream;

begin
  S:=GetBlobStream(bmRead);
  Try
    If Assigned(S) then
      Stream.CopyFrom(S,0);
  finally
    S.Free;
  end;
end;

procedure TBlobField.SetFieldType(AValue: TFieldType);

begin
  If AValue in [Low(TBlobType)..High(TBlobType)] then
    SetDatatype(Avalue);
end;

{ TMemoField }

constructor TMemoField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftMemo);
end;

function TMemoField.GetAsWideString: WideString;
begin
  Result := GetAsString;
end;

procedure TMemoField.SetAsWideString(const aValue: WideString);
begin
  SetAsString(aValue);
end;

{ TWideMemoField }

constructor TWideMemoField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftWideMemo);
end;

function TWideMemoField.GetAsString: string;
begin
  Result := GetAsWideString;
end;

procedure TWideMemoField.SetAsString(const aValue: string);
begin
  SetAsWideString(aValue);
end;

function TWideMemoField.GetAsVariant: Variant;

Var s : string;

begin
  if not GetIsNull then
    begin
    s := GetAsWideString;
    result := s;
    end
  else result := Null;
end;

procedure TWideMemoField.SetVarValue(const AValue: Variant);
begin
  SetAsWideString(AValue);
end;

{ TGraphicField }

constructor TGraphicField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftGraphic);
end;

{ TGuidField }

constructor TGuidField.Create(AOwner: TComponent);
begin
  Size := 38;
  inherited Create(AOwner);
  SetDataType(ftGuid);
end;

class procedure TGuidField.CheckTypeSize(AValue: LongInt);
begin
  if aValue <> 38 then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

function TGuidField.GetAsGuid: TGUID;
const
  nullguid: TGUID = '{00000000-0000-0000-0000-000000000000}';
var
  S: string;
begin
  S := GetAsString;
  if S = '' then
    Result := nullguid
  else
    Result := StringToGuid(S);
end;

function TGuidField.GetDefaultWidth: LongInt;
begin
  Result := 38;
end;

procedure TGuidField.SetAsGuid(const aValue: TGUID);
begin
  SetAsString(GuidToString(aValue));
end;

function TVariantField.GetDefaultWidth: Integer;
begin
  Result := 15;
end;

{ TVariantField }

constructor TVariantField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftVariant);
end;

class procedure TVariantField.CheckTypeSize(aValue: Integer);
begin
  { empty }
end;

function TVariantField.GetAsBoolean: Boolean;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsDateTime: TDateTime;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsFloat: Double;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsInteger: Longint;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsString: string;
begin
  Result := VarToStr(GetAsVariant);
end;

function TVariantField.GetAsWideString: WideString;
begin
  Result := VarToWideStr(GetAsVariant);
end;

procedure tvariantfield.setasunicodestring(const avalue: unicodestring);
begin
 setvarvalue(avalue);
end;

function tvariantfield.getasunicodestring: unicodestring;
begin
 Result := VarTounicodeStr(GetAsVariant);
 {
 if isnull then begin
  result:= '';
 end
 else begin
  result:= getasvariant;
 end;
 }
end;


function TVariantField.GetAsVariant: Variant;
begin
  if not GetData(@Result) then
    Result := Null;
end;

procedure TVariantField.SetAsBoolean(aValue: Boolean);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsDateTime(aValue: TDateTime);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsFloat(aValue: Double);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsInteger(aValue: Longint);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsString(const aValue: string);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsWideString(const aValue: WideString);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetVarValue(const aValue: Variant);
begin
  SetData(@aValue);
end;

{ TFieldsEnumerator }

function TFieldsEnumerator.GetCurrent: TField;
begin
  Result := FFields[FPosition];
end;

constructor TFieldsEnumerator.Create(AFields: TFields);
begin
  inherited Create;
  FFields := AFields;
  FPosition := -1;
end;

function TFieldsEnumerator.MoveNext: Boolean;
begin
  inc(FPosition);
  Result := FPosition < FFields.Count;
end;

{ TFields }

Constructor TFields.Create(ADataset : TDataset);

begin
  FDataSet:=ADataset;
  FFieldList:=TFpList.Create;
  FValidFieldKinds:=[fkData..fkInternalcalc];
end;

Destructor TFields.Destroy;

begin
  if Assigned(FFieldList) then
    Clear;
  FreeAndNil(FFieldList);
  inherited Destroy;
end;

Procedure Tfields.Changed;

begin
  if (FDataSet <> nil) and not (csDestroying in FDataSet.ComponentState) and FDataset.Active then
    FDataSet.DataEvent(deFieldListChange, 0);
  If Assigned(FOnChange) then
    FOnChange(Self);
end;

Procedure TFields.CheckfieldKind(Fieldkind : TFieldKind; Field : TField);

begin
  If Not (FieldKind in ValidFieldKinds) Then
    DatabaseErrorFmt(SInvalidFieldKind,[Field.FieldName]);
end;

Function Tfields.GetCount : Longint;

begin
  Result:=FFieldList.Count;
end;


Function TFields.GetField (Index : longint) : TField;

begin
  Result:=Tfield(FFieldList[Index]);
end;

procedure Tfields.SetField(Index: Integer; Value: TField);
begin
  Fields[Index].Assign(Value);
end;

Procedure TFields.SetFieldIndex (Field : TField;Value : Integer);

Var Old : Longint;

begin
  Old := FFieldList.indexOf(Field);
  If Old=-1 then
    Exit;
  // Check value
  If Value<0 Then Value:=0;
  If Value>=Count then Value:=Count-1;
  If Value<>Old then
    begin
    FFieldList.Delete(Old);
    FFieldList.Insert(Value,Field);
    Field.PropertyChanged(True);
    Changed;
    end;
end;

Procedure TFields.Add(Field : TField);

begin
  CheckFieldName(Field.FieldName);
  FFieldList.Add(Field);
  Field.FFields:=Self;
  Changed;
end;

Procedure TFields.CheckFieldName (Const Value : String);

begin
  If FindField(Value)<>Nil then
    DataBaseErrorFmt(SDuplicateFieldName,[Value],FDataset);
end;

Procedure TFields.CheckFieldNames (Const Value : String);


Var I : longint;
    S,T : String;
begin
  T:=Value;
  Repeat
    I:=Pos(';',T);
    If I=0 Then I:=Length(T)+1;
    S:=Copy(T,1,I-1);
    Delete(T,1,I);
    // Will raise an error if no such field...
    FieldByName(S);
  Until (T='');
end;

Procedure TFields.Clear;
var
  AField: TField;
begin
  while FFieldList.Count > 0 do 
    begin
    AField := TField(FFieldList.Last);
    AField.FDataSet := Nil;
    AField.Free;
    FFieldList.Delete(FFieldList.Count - 1);
    end;
  Changed;
end;

Function TFields.FindField (Const Value : String) : TField;

Var S : String;
    I : longint;

begin
  Result:=Nil;
  S:=UpperCase(Value);
  For I:=0 To FFieldList.Count-1 do
    If S=UpperCase(TField(FFieldList[i]).FieldName) Then
      Begin
      {$ifdef dsdebug}
      Writeln ('Found field ',Value);
      {$endif}
      Result:=TField(FFieldList[I]);
      Exit;
      end;
end;

Function TFields.FieldByName (Const Value : String) : TField;

begin
  Result:=FindField(Value);
  If result=Nil then
    DatabaseErrorFmt(SFieldNotFound,[Value],FDataset);
end;

Function TFields.FieldByNumber(FieldNo : Integer) : TField;

Var i : Longint;

begin
  Result:=Nil;
  For I:=0 to FFieldList.Count-1 do
    If FieldNo=TField(FFieldList[I]).FieldNo then
      begin
      Result:=TField(FFieldList[i]);
      Exit;
      end;
end;

Function TFields.GetEnumerator: TFieldsEnumerator;

begin
  Result:=TFieldsEnumerator.Create(Self);
end;

Procedure TFields.GetFieldNames (Values : TStrings);

Var i : longint;

begin
  Values.Clear;
  For I:=0 to FFieldList.Count-1 do
    Values.Add(Tfield(FFieldList[I]).FieldName);
end;

Function TFields.IndexOf(Field : TField) : Longint;

begin
  Result:=FFieldList.IndexOf(Field);
end;

procedure TFields.Remove(Value : TField);

begin
  FFieldList.Remove(Value);
  Value.FFields := nil;
  Changed;
end;


{ ---------------------------------------------------------------------
    TDatalink
  ---------------------------------------------------------------------}

Constructor TDataLink.Create;

begin
  Inherited Create;
  FBufferCount:=1;
  FFirstRecord := 0;
  FDataSource := nil;
  FDatasourceFixed:=False;
end;


Destructor TDataLink.Destroy;

begin
  Factive:=False;
  FEditing:=False;
  FDataSourceFixed:=False;
  DataSource:=Nil;
  Inherited Destroy;
end;


Procedure TDataLink.ActiveChanged;

begin
  FFirstRecord := 0;
end;

Procedure TDataLink.CheckActiveAndEditing;

Var
  B : Boolean;

begin
  B:=Assigned(DataSource) and (DataSource.State<>dsInactive);
  If B<>FActive then
    begin
    FActive:=B;
    ActiveChanged;
    end;
  B:=Assigned(DataSource) and (DataSource.State in dsEditModes) and Not FReadOnly;
  If B<>FEditing Then
    begin
    FEditing:=B;
    EditingChanged;
    end;
end;


Procedure TDataLink.CheckBrowseMode;

begin
end;


Function TDataLink.CalcFirstRecord(Index : Integer) : Integer;
begin
  if DataSource.DataSet.FActiveRecord > FFirstRecord + Index + FBufferCount - 1 then
    Result := DataSource.DataSet.FActiveRecord - (FFirstRecord + Index + FBufferCount - 1)
  else if DataSource.DataSet.FActiveRecord < FFirstRecord + Index then
    Result := DataSource.DataSet.FActiveRecord - (FFirstRecord + Index)
  else Result := 0;
  
  Inc(FFirstRecord, Index + Result);
end;


Procedure TDataLink.CalcRange;
var
    aMax, aMin: integer;
begin
  aMin:= DataSet.FActiveRecord - FBufferCount + 1;
  If aMin < 0 Then aMin:= 0;
  aMax:= Dataset.FBufferCount - FBufferCount;
  If aMax < 0 then aMax:= 0;

  If aMax>DataSet.FActiveRecord Then aMax:=DataSet.FActiveRecord;

  If FFirstRecord < aMin Then FFirstRecord:= aMin;
  If FFirstrecord > aMax Then FFirstRecord:= aMax;

  If (FfirstRecord<>0) And
     (DataSet.FActiveRecord - FFirstRecord < FBufferCount -1) Then
    Dec(FFirstRecord, 1);

end;


Procedure TDataLink.DataEvent(Event: TDataEvent; Info: Ptrint);


begin
  Case Event of
    deFieldChange, deRecordChange:
      If Not FUpdatingRecord then
        RecordChanged(TField(Info));
    deDataSetChange: begin
      SetActive(DataSource.DataSet.Active);
      CalcRange;
      CalcFirstRecord(Info);
      DatasetChanged;
    end;
    deDataSetScroll: DatasetScrolled(CalcFirstRecord(Info));
    deLayoutChange: begin
      CalcFirstRecord(Info);
      LayoutChanged;
    end;
    deUpdateRecord: UpdateRecord;
    deUpdateState: CheckActiveAndEditing;
    deCheckBrowseMode: CheckBrowseMode;
    deFocusControl: FocusControl(TFieldRef(Info));
  end;
end;


Procedure TDataLink.DataSetChanged;

begin
  RecordChanged(Nil);
end;


Procedure TDataLink.DataSetScrolled(Distance: Integer);

begin
  DataSetChanged;
end;


Procedure TDataLink.EditingChanged;

begin
end;


Procedure TDataLink.FocusControl(Field: TFieldRef);

begin
end;


Function TDataLink.GetActiveRecord: Integer;

begin
  Result:=Dataset.FActiveRecord - FFirstRecord;
end;

Function TDatalink.GetDataSet : TDataset;

begin
  If Assigned(Datasource) then
    Result:=DataSource.DataSet
  else
    Result:=Nil;  
end;


Function TDataLink.GetBOF: Boolean;

begin
  Result:=DataSet.BOF
end;


Function TDataLink.GetBufferCount: Integer;

begin
  Result:=FBufferCount;
end;


Function TDataLink.GetEOF: Boolean;

begin
  Result:=DataSet.EOF
end;


Function TDataLink.GetRecordCount: Integer;

begin
  Result:=Dataset.FRecordCount;
  If Result>BufferCount then
    Result:=BufferCount;
end;


Procedure TDataLink.LayoutChanged;

begin
  DataSetChanged;
end;


Function TDataLink.MoveBy(Distance: Integer): Integer;

begin
  Result:=DataSet.MoveBy(Distance);
end;


Procedure TDataLink.RecordChanged(Field: TField);

begin
end;


Procedure TDataLink.SetActiveRecord(Value: Integer);

begin
{$ifdef dsdebug}
  Writeln('Datalink. Setting active record to ',Value,' with firstrecord ',ffirstrecord);
{$endif}
  Dataset.FActiveRecord:=Value + FFirstRecord;
end;


Procedure TDataLink.SetBufferCount(Value: Integer);

begin
  If FBufferCount<>Value then
    begin
      FBufferCount:=Value;
      if Active then begin
        DataSet.RecalcBufListSize;
        CalcRange;
      end;
    end;
end;

procedure TDataLink.SetActive(AActive: Boolean);
begin
  if Active <> AActive then
  begin
    FActive := AActive;
    // !!!: Set internal state
    ActiveChanged;
  end;
end;

Procedure TDataLink.SetDataSource(Value : TDatasource);

begin
  if FDataSource = Value then
    Exit;
  if not FDataSourceFixed then
    begin
    if Assigned(DataSource) then
      Begin
      DataSource.UnregisterDatalink(Self);
      FDataSource := nil;
      CheckActiveAndEditing;
      End;
    FDataSource := Value;
    if Assigned(DataSource) then
      begin
      DataSource.RegisterDatalink(Self);
      CheckActiveAndEditing;
      End;
    end;
end;

Procedure TDatalink.SetReadOnly(Value : Boolean);

begin
  If FReadOnly<>Value then
    begin
    FReadOnly:=Value;
    CheckActiveAndEditing;
    end;
end;

Procedure TDataLink.UpdateData;

begin
end;



Function TDataLink.Edit: Boolean;

begin
  If Not FReadOnly then
    DataSource.Edit;
  // Triggered event will set FEditing
  Result:=FEditing;
end;


Procedure TDataLink.UpdateRecord;

begin
  FUpdatingRecord:=True;
  Try
    UpdateData;
  finally
    FUpdatingRecord:=False;
  end;
end;

function TDataLink.ExecuteAction(Action: TBasicAction): Boolean;
begin
 if Action.HandlesTarget(DataSource) then
 begin
   Action.ExecuteTarget(DataSource);
   Result := True;
 end
 else Result := False;
end;

function TDataLink.UpdateAction(Action: TBasicAction): Boolean;
begin
 if Action.HandlesTarget(DataSource) then
 begin
   Action.UpdateTarget(DataSource);
   Result := True;
 end
 else Result := False;
end;
{
procedure TDataLink.doenter(const aobject: tobject);
begin
 if fdatasource <> nil then begin
  fdatasource.doenter(self,aobject);
 end;
end;

procedure TDataLink.doexit(const aobject: tobject);
begin
 if fdatasource <> nil then begin
  fdatasource.doexit(self,aobject);
 end;
end;
}

{ ---------------------------------------------------------------------
    TDetailDataLink
  ---------------------------------------------------------------------}

Function TDetailDataLink.GetDetailDataSet: TDataSet;

begin
  Result := nil;
end;


{ ---------------------------------------------------------------------
    TMasterDataLink
  ---------------------------------------------------------------------}

constructor TMasterDataLink.Create(ADataSet: TDataSet);

begin
  inherited Create;
  FDetailDataSet:=ADataSet;
  FFields:=TList.Create;
end;


destructor TMasterDataLink.Destroy;

begin
  FFields.Free;
  inherited Destroy;
end;


Procedure TMasterDataLink.ActiveChanged;

begin
  FFields.Clear;
  if Active then
  try
    DataSet.GetFieldList(FFields, FFieldNames);
  except
    FFields.Clear;
    raise;
  end;
  if FDetailDataSet.Active and not (csDestroying in FDetailDataSet.ComponentState) then
    if Active and (FFields.Count > 0) then
      DoMasterChange
    else
      DoMasterDisable;  
end;


Procedure TMasterDataLink.CheckBrowseMode;

begin
  if FDetailDataSet.Active then FDetailDataSet.CheckBrowseMode;
end;


Function TMasterDataLink.GetDetailDataSet: TDataSet;

begin
  Result := FDetailDataSet;
end;


Procedure TMasterDataLink.LayoutChanged;

begin
  ActiveChanged;
end;


Procedure TMasterDataLink.RecordChanged(Field: TField);

begin
  if (DataSource.State <> dsSetKey) and FDetailDataSet.Active and
     (FFields.Count > 0) and ((Field = nil) or
     (FFields.IndexOf(Field) >= 0)) then
    DoMasterChange;  
end;

procedure TMasterDatalink.SetFieldNames(const Value: string);

begin
  if FFieldNames <> Value then
    begin
    FFieldNames := Value;
    ActiveChanged;
    end;
end;

Procedure TMasterDataLink.DoMasterDisable; 

begin
  if Assigned(FOnMasterDisable) then 
    FOnMasterDisable(Self);
end;

Procedure TMasterDataLink.DoMasterChange; 

begin
  If Assigned(FOnMasterChange) then
    FOnMasterChange(Self);
end;

{ ---------------------------------------------------------------------
    TMasterDataLink
  ---------------------------------------------------------------------}

constructor TMasterParamsDataLink.Create(ADataSet: TDataSet);

Var
  P : TParams;

begin
  inherited Create(ADataset);
  If (ADataset<>Nil) then
    begin
    P:=TParams(GetObjectProp(ADataset,'Params',TParams));
    if (P<>Nil) then
      Params:=P;
    end;  
end;


Procedure TMasterParamsDataLink.SetParams(AVAlue : TParams);  

begin
  FParams:=AValue;
  If (AValue<>Nil) then
    RefreshParamNames;
end;

Procedure TMasterParamsDataLink.RefreshParamNames; 

Var
  FN : String;
  DS : TDataset;
  F  : TField;
  I : Integer;

begin
  FN:='';
  DS:=Dataset;
  If Assigned(FParams) then
    begin
    F:=Nil;
    For I:=0 to FParams.Count-1 do
      begin
      If Assigned(DS) then
        F:=DS.FindField(FParams[i].Name);
      If (Not Assigned(DS)) or (not DS.Active) or (F<>Nil) then
        begin
        If (FN<>'') then
          FN:=FN+';';
        FN:=FN+FParams[i].Name; 
        end;
      end;
    end;
  FieldNames:=FN;  
end;

Procedure TMasterParamsDataLink.CopyParamsFromMaster(CopyBound : Boolean);

begin
  if Assigned(FParams) then
    FParams.CopyParamValuesFromDataset(Dataset,CopyBound);
end;

Procedure TMasterParamsDataLink.DoMasterDisable; 

begin
  Inherited;
  If Assigned(DetailDataset) and DetailDataset.Active then
    DetailDataset.Close;
end;

Procedure TMasterParamsDataLink.DoMasterChange; 

begin
  Inherited;
  if Assigned(Params) and Assigned(DetailDataset) and DetailDataset.Active then
    begin
    DetailDataSet.CheckBrowseMode;
    DetailDataset.Close;
    DetailDataset.Open;
    end;
end;

{ ---------------------------------------------------------------------
    TDatasource
  ---------------------------------------------------------------------}

Constructor TDataSource.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FDatalinks := TList.Create;
  FEnabled := True;
  FAutoEdit := True;
end;


Destructor TDataSource.Destroy;

begin
  FOnStateCHange:=Nil;
  Dataset:=Nil;
  With FDataLinks do
    While Count>0 do
      TDatalink(Items[Count - 1]).DataSource:=Nil;
  FDatalinks.Free;
  inherited Destroy;
end;


Procedure TDatasource.Edit;

begin
  If (State=dsBrowse) and AutoEdit Then
    Dataset.Edit;
end;


Function TDataSource.IsLinkedTo(ADataSet: TDataSet): Boolean;

begin
  Result:=False;
end;


procedure TDatasource.DistributeEvent(Event: TDataEvent; Info: Ptrint);


Var
  i : Longint;

begin
  With FDatalinks do
    begin
    For I:=0 to Count-1 do
      With TDatalink(Items[i]) do
        If Not VisualControl Then
          DataEvent(Event,Info);
    For I:=0 to Count-1 do
      With TDatalink(Items[i]) do
        If VisualControl Then
          DataEvent(Event,Info);
    end;
end;

procedure TDatasource.RegisterDataLink(DataLink: TDataLink);

begin
  FDatalinks.Add(DataLink);
  if Assigned(DataSet) then
    DataSet.RecalcBufListSize;
end;


procedure TDatasource.SetDataSet(ADataSet: TDataSet);
begin
  If FDataset<>Nil Then
    Begin
    FDataset.UnRegisterDataSource(Self);
    FDataSet:=nil;
    ProcessEvent(deUpdateState,0);
    End;
  If ADataset<>Nil Then
    begin
    ADataset.RegisterDatasource(Self);
    FDataSet:=ADataset;
    ProcessEvent(deUpdateState,0);
    End;
end;


procedure TDatasource.SetEnabled(Value: Boolean);

begin
  FEnabled:=Value;
end;


Procedure TDatasource.DoDataChange (Info : Pointer);

begin
  If Assigned(OnDataChange) Then
    OnDataChange(Self,TField(Info));
end;

Procedure TDatasource.DoStateChange;

begin
  If Assigned(OnStateChange) Then
    OnStateChange(Self);
end;


Procedure TDatasource.DoUpdateData;

begin
  If Assigned(OnUpdateData) Then
    OnUpdateData(Self);
end;


procedure TDatasource.UnregisterDataLink(DataLink: TDataLink);

begin
  FDatalinks.Remove(Datalink);
  If Dataset<>Nil then
    DataSet.RecalcBufListSize;
  //Dataset.SetBufListSize(DataLink.BufferCount);
end;


procedure TDataSource.ProcessEvent(Event : TDataEvent; Info : Ptrint);

Const
    OnDataChangeEvents = [deRecordChange, deDataSetChange, deDataSetScroll,
                          deLayoutChange,deUpdateState];

Var
  NeedDataChange : Boolean;
  FLastState : TdataSetState;

begin
  // Special UpdateState handling.
  If Event=deUpdateState then
    begin
    NeedDataChange:=(FState=dsInactive);
    FLastState:=FState;
    If Assigned(Dataset) then
      FState:=Dataset.State
    else
      FState:=dsInactive;
    // Don't do events if nothing changed.
    If FState=FlastState then
      exit;
    end
  else
    NeedDataChange:=True;
  DistributeEvent(Event,Info);
  // Extra handlers
  If Not (csDestroying in ComponentState) then
    begin
    If (Event=deUpdateState) then
      DoStateChange;
    If (Event in OnDataChangeEvents) and
       NeedDataChange Then
      DoDataChange(Nil);
    If (Event = deFieldChange) Then
      DoDataCHange(Pointer(Info));
    If (Event=deUpdateRecord) then
      DoUpdateData;
    end;
 end;

procedure TDataSource.ifistatechanged(const sender: tdatalink;
               const aclient: iificlient; const astate: ifiwidgetstatesty);
begin
 if assigned(fonifistatechanged) and 
             (componentstate * [csloading,csdestroying] = []) then begin
  fonifistatechanged(self,sender,aclient,astate);
 end;
end;
{
procedure TDataSource.doenter(const alink: tdatalink; const aobject: tobject);
begin
 if assigned(fonenter) and 
             (componentstate * [csloading,csdestroying] = []) then begin
  fonenter(self,alink,aobject);
 end;
end;

procedure TDataSource.doexit(const alink: tdatalink; const aobject: tobject);
begin
 if assigned(fonexit) and 
             (componentstate * [csloading,csdestroying] = []) then begin
  fonexit(self,alink,aobject);
 end;
end;
}
{ ---------------------------------------------------------------------
    TDatabase
  ---------------------------------------------------------------------}

Procedure TDatabase.CheckConnected;

begin
  If Not Connected Then
    DatabaseError(SNotConnected,Self);
end;


Procedure TDatabase.CheckDisConnected;
begin
  If Connected Then
    DatabaseError(SConnected,Self);
end;

procedure TDatabase.DoConnect;
begin
  DoInternalConnect;
  FConnected := True;
end;

procedure TDatabase.DoDisconnect;
begin
  Closedatasets;
  Closetransactions;
  DoInternalDisConnect;
  if csloading in ComponentState then
    FOpenAfterRead := false;
  FConnected := False;
end;

function TDatabase.GetConnected: boolean;
begin
  Result:= FConnected;
end;

constructor TDatabase.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FParams:=TStringlist.Create;
  FDatasets:=TList.Create;
  FTransactions:=TList.Create;
  FConnected:=False;
end;

destructor TDatabase.Destroy;

begin
  Connected:=False;
  RemoveDatasets;
  RemoveTransactions;
  FDatasets.Free;
  FTransactions.Free;
  FParams.Free;
  Inherited Destroy;
end;

procedure TDatabase.CloseDataSets;

Var I : longint;

begin
  If Assigned(FDatasets) then
    begin
    For I:=FDatasets.Count-1 downto 0 do
      TDataset(FDatasets[i]).Close;
    end;
end;

procedure TDatabase.CloseTransactions;

Var I : longint;

begin
  If Assigned(FTransactions) then
    begin
    For I:=FTransactions.Count-1 downto 0 do
      TDBTransaction(FTransactions[i]).EndTransaction;
    end;
end;

procedure TDatabase.RemoveDataSets;

Var I : longint;

begin
  If Assigned(FDatasets) then
    For I:=FDataSets.Count-1 downto 0 do
      TDBDataset(FDataSets[i]).Database:=Nil;
end;

procedure TDatabase.RemoveTransactions;

Var I : longint;

begin
  If Assigned(FTransactions) then
    For I:=FTransactions.Count-1 downto 0 do
      TDBTransaction(FTransactions[i]).Database:=Nil;
end;

procedure TDatabase.SetParams(AValue: TStrings);
begin
  if AValue<>nil then
    FParams.Assign(AValue);
end;

Function TDatabase.GetDataSetCount : Longint;

begin
  If Assigned(FDatasets) Then
    Result:=FDatasets.Count
  else
    Result:=0;
end;

Function TDatabase.GetTransactionCount : Longint;

begin
  If Assigned(FTransactions) Then
    Result:=FTransactions.Count
  else
    Result:=0;
end;

Function TDatabase.GetDataset(Index : longint) : TDataset;

begin
  If Assigned(FDatasets) then
    Result:=TDataset(FDatasets[Index])
  else
    begin
    result := nil;
    DatabaseError(SNoDatasets);
    end;
end;

Function TDatabase.GetTransaction(Index : longint) : TDBtransaction;

begin
  If Assigned(FTransactions) then
    Result:=TDBTransaction(FTransactions[Index])
  else
    begin
    result := nil;
    DatabaseError(SNoTransactions);
    end;
end;

procedure TDatabase.RegisterDataset (DS : TDBDataset);

Var I : longint;

begin
  I:=FDatasets.IndexOf(DS);
  If I=-1 then
    FDatasets.Add(DS)
  else
    DatabaseErrorFmt(SDatasetRegistered,[DS.Name]);
end;

procedure TDatabase.RegisterTransaction (TA : TDBTransaction);

Var I : longint;

begin
  I:=FTransactions.IndexOf(TA);
  If I=-1 then
    FTransactions.Add(TA)
  else
    DatabaseErrorFmt(STransactionRegistered,[TA.Name]);
end;

procedure TDatabase.UnRegisterDataset (DS : TDBDataset);

Var I : longint;

begin
  I:=FDatasets.IndexOf(DS);
  If I<>-1 then
    FDatasets.Delete(I)
  else
    DatabaseErrorFmt(SNoDatasetRegistered,[DS.Name]);
end;

procedure TDatabase.UnRegisterTransaction (TA : TDBTransaction);

Var I : longint;

begin
  I:=FTransactions.IndexOf(TA);
  If I<>-1 then
    FTransactions.Delete(I)
  else
    DatabaseErrorFmt(SNoTransactionRegistered,[TA.Name]);
end;


{ ---------------------------------------------------------------------
    TDBdataset
  ---------------------------------------------------------------------}

Procedure TDBDataset.SetDatabase (Value : TDatabase);

begin
  If Value<>FDatabase then
    begin
    CheckInactive;
    If Assigned(FDatabase) then
      FDatabase.UnregisterDataset(Self);
    If Value<>Nil Then
      Value.RegisterDataset(Self);
    FDatabase:=Value;
    end;
end;

Procedure TDBDataset.SetTransaction (Value : TDBTransaction);

begin
  CheckInactive;
  If Value<>FTransaction then
    begin
    If Assigned(FTransaction) then
      FTransaction.UnregisterDataset(Self);
    If Value<>Nil Then
      Value.RegisterDataset(Self);
    FTransaction:=Value;
    end;
end;

Procedure TDBDataset.CheckDatabase;

begin
  If (FDatabase=Nil) then
    DatabaseError(SErrNoDatabaseAvailable,Self)
end;

Destructor TDBDataset.Destroy;

begin
  Database:=Nil;
  Transaction:=Nil;
  Inherited;
end;

{ ---------------------------------------------------------------------
    TDBTransaction
  ---------------------------------------------------------------------}
procedure TDBTransaction.SetActive(Value : boolean);
begin
  if FActive and (not Value) then
    EndTransaction
  else if (not FActive) and Value then
    if csLoading in ComponentState then
      begin
      FOpenAfterRead := true;
      exit;
      end
    else
      StartTransaction;
end;

procedure TDBTransaction.Loaded;

begin
  inherited;
  try
    if FOpenAfterRead then SetActive(true);
  except
    if csDesigning in Componentstate then
      InternalHandleException
    else
      raise;
  end;
end;

Procedure TDBTransaction.InternalHandleException;

begin
  if assigned(classes.ApplicationHandleException) then
    classes.ApplicationHandleException(self)
  else
    ShowException(ExceptObject,ExceptAddr);
end;

Procedure TDBTransaction.CheckActive;

begin
  If not FActive Then
    DatabaseError(STransNotActive,Self);
end;

Procedure TDBTransaction.CheckInActive;

begin
  If FActive Then
    DatabaseError(STransActive,Self);
end;

Procedure TDBTransaction.CloseTrans;

begin
  FActive := false;
end;

Procedure TDBTransaction.OpenTrans;

begin
  FActive := true;
end;

Procedure TDBTransaction.SetDatabase (Value : TDatabase);

begin
  If Value<>FDatabase then
    begin
    CheckInactive;
    If Assigned(FDatabase) then
      FDatabase.UnregisterTransaction(Self);
    If Value<>Nil Then
      Value.RegisterTransaction(Self);
    FDatabase:=Value;
    end;
end;

constructor TDBTransaction.create(AOwner : TComponent);

begin
  inherited create(AOwner);
  FDatasets:=TList.Create;
end;

Procedure TDBTransaction.CheckDatabase;

begin
  If (FDatabase=Nil) then
    DatabaseError(SErrNoDatabaseAvailable,Self)
end;

procedure TDBTransaction.CloseDataSets;

Var I : longint;

begin
  If Assigned(FDatasets) then
    begin
    For I:=FDatasets.Count-1 downto 0 do
      TDBDataset(FDatasets[i]).Close;
    end;
end;

Destructor TDBTransaction.Destroy;

begin
  Database:=Nil;
  CloseDataSets;
  RemoveDatasets;
  FDatasets.Free;
  Inherited;
end;

procedure TDBTransaction.RemoveDataSets;

Var I : longint;

begin
  If Assigned(FDatasets) then
    For I:=FDataSets.Count-1 downto 0 do
      TDBDataset(FDataSets[i]).Transaction:=Nil;
end;

Function TDBTransaction.GetDataSetCount : Longint;

begin
  If Assigned(FDatasets) Then
    Result:=FDatasets.Count
  else
    Result:=0;
end;

procedure TDBTransaction.UnRegisterDataset (DS : TDBDataset);

Var I : longint;

begin
  I:=FDatasets.IndexOf(DS);
  If I<>-1 then
    FDatasets.Delete(I)
  else
    DatabaseErrorFmt(SNoDatasetRegistered,[DS.Name]);
end;

procedure TDBTransaction.RegisterDataset (DS : TDBDataset);

Var I : longint;

begin
  I:=FDatasets.IndexOf(DS);
  If I=-1 then
    FDatasets.Add(DS)
  else
    DatabaseErrorFmt(SDatasetRegistered,[DS.Name]);
end;

Function TDBTransaction.GetDataset(Index : longint) : TDBDataset;

begin
  If Assigned(FDatasets) then
    Result:=TDBDataset(FDatasets[Index])
  else
  begin
    result := nil;
    DatabaseError(SNoDatasets);
  end;
end;

{ ---------------------------------------------------------------------
    TCustomConnection
  ---------------------------------------------------------------------}

procedure TCustomConnection.SetAfterConnect(const AValue: TNotifyEvent);
begin
  FAfterConnect:=AValue;
end;

function TCustomConnection.GetDataSet(Index: Longint): TDataSet;
begin
  Result := nil;
end;

function TCustomConnection.GetDataSetCount: Longint;
begin
  Result := 0;
end;

procedure TCustomConnection.InternalHandleException;
begin
  if assigned(classes.ApplicationHandleException) then
    classes.ApplicationHandleException(self)
  else
    ShowException(ExceptObject,ExceptAddr);
end;

procedure TCustomConnection.SetAfterDisconnect(const AValue: TNotifyEvent);
begin
  FAfterDisconnect:=AValue;
end;

procedure TCustomConnection.SetBeforeConnect(const AValue: TNotifyEvent);
begin
  FBeforeConnect:=AValue;
end;

procedure TCustomConnection.SetConnected(Value: boolean);
begin
  If Value<>Connected then
    begin
    If Value then
      begin
      if csReading in ComponentState then
        begin
        FStreamedConnected := true;
        exit;
        end
      else
        begin
        if Assigned(BeforeConnect) then
          BeforeConnect(self);
        if FLoginPrompt then if assigned(FOnLogin) then
          FOnLogin(self,'','');
        DoConnect;
        if Assigned(AfterConnect) then
          AfterConnect(self);
        end;
      end
    else
      begin
      if Assigned(BeforeDisconnect) then
        BeforeDisconnect(self);
      DoDisconnect;
      if Assigned(AfterDisconnect) then
        AfterDisconnect(self);
      end;
    end;
end;

procedure TCustomConnection.SetBeforeDisconnect(const AValue: TNotifyEvent);
begin
  FBeforeDisconnect:=AValue;
end;

procedure TCustomConnection.DoConnect;

begin
  // Do nothing yet
end;

procedure TCustomConnection.DoDisconnect;

begin
  // Do nothing yet
end;

function TCustomConnection.GetConnected: boolean;

begin
  Result := False;
end;

procedure TCustomConnection.Loaded;
begin
  inherited Loaded;
  try
    if FStreamedConnected then
      SetConnected(true);
  except
    if csDesigning in Componentstate then
      InternalHandleException
    else
      raise;
  end;
end;

procedure TCustomConnection.Close;
begin
  Connected := False;
end;

destructor TCustomConnection.Destroy;
begin
  Connected:=False;
  Inherited Destroy;
end;

procedure TCustomConnection.Open;
begin
  Connected := True;
end;


procedure SkipQuotesString(var p : pchar; QuoteChar : char; EscapeSlash, EscapeRepeat : Boolean);
var notRepeatEscaped : boolean;
begin
  Inc(p);
  repeat
    notRepeatEscaped := True;
    while not (p^ in [#0, QuoteChar]) do
    begin
      if EscapeSlash and (p^='\') and (p[1] <> #0) then Inc(p,2) // make sure we handle \' and \\ correct
      else Inc(p);
    end;
    if p^=QuoteChar then
    begin
      Inc(p); // skip final '
      if (p^=QuoteChar) and EscapeRepeat then // Handle escaping by ''
      begin
      notRepeatEscaped := False;
      inc(p);
      end
    end;
  until notRepeatEscaped;
end;

{ TParams }

Function TParams.GetItem(Index: Integer): TParam;
begin
  Result:=(Inherited GetItem(Index)) as TParam;
end;

Function TParams.GetParamValue(const ParamName: string): Variant;
begin
  Result:=ParamByName(ParamName).Value;
end;

Procedure TParams.SetItem(Index: Integer; Value: TParam);
begin
  Inherited SetItem(Index,Value);
end;

Procedure TParams.SetParamValue(const ParamName: string; const Value: Variant);
begin
  ParamByName(ParamName).Value:=Value;
end;

Procedure TParams.AssignTo(Dest: TPersistent);
begin
 if (Dest is TParams) then
   TParams(Dest).Assign(Self)
 else
   inherited AssignTo(Dest);
end;

Function TParams.GetDataSet: TDataSet;
begin
  If (FOwner is TDataset) Then
    Result:=TDataset(FOwner)
  else
    Result:=Nil;
end;

Function TParams.GetOwner: TPersistent;
begin
  Result:=FOwner;
end;


constructor TParams.Create(AOwner: TPersistent);
begin
  Inherited Create(TParam);
  Fowner:=AOwner;
end;

constructor TParams.Create;
begin
  Create(TPersistent(Nil));
end;

Procedure TParams.AddParam(Value: TParam);
begin
  Value.Collection:=Self;
end;

Procedure TParams.AssignValues(Value: TParams);

Var
  I : Integer;
  P,PS : TParam;

begin
  For I:=0 to Value.Count-1 do
    begin
    PS:=Value[i];
    P:=FindParam(PS.Name);
    If Assigned(P) then
      P.Assign(PS);
    end;
end;

Function TParams.CreateParam(FldType: TFieldType; const ParamName: string;
  ParamType: TParamType): TParam;

begin
  Result:=Add as TParam;
  Result.Name:=ParamName;
  Result.DataType:=FldType;
  Result.ParamType:=ParamType;
end;

Function TParams.FindParam(const Value: string): TParam;

Var
  I : Integer;

begin
  Result:=Nil;
  I:=Count-1;
  While (Result=Nil) and (I>=0) do
    If (CompareText(Value,Items[i].Name)=0) then
      Result:=Items[i]
    else
      Dec(i);
end;

Procedure TParams.GetParamList(List: TList; const ParamNames: string);

Var
  P: TParam;
  N: String;
  StrPos: Integer;

begin
  if (ParamNames = '') or (List = nil) then
    Exit;
  StrPos := 1;
  repeat
    N := ExtractFieldName(ParamNames, StrPos);
    P := ParamByName(N);
    List.Add(P);
  until StrPos > Length(ParamNames);
end;

Function TParams.IsEqual(Value: TParams): Boolean;

Var
  I : Integer;

begin
  Result:=(Value.Count=Count);
  I:=Count-1;
  While Result and (I>=0) do
    begin
    Result:=Items[I].IsEqual(Value[i]);
    Dec(I);
    end;
end;

Function TParams.ParamByName(const Value: string): TParam;
begin
  Result:=FindParam(Value);
  If (Result=Nil) then
    DatabaseErrorFmt(SParameterNotFound,[Value],Dataset);
end;

Function TParams.ParseSQL(SQL: String; DoCreate: Boolean): String;

var pb : TParamBinding;
    rs : string;

begin
  Result := ParseSQL(SQL,DoCreate,True,True,psInterbase, pb, rs);
end;

Function TParams.ParseSQL(SQL: String; DoCreate, EscapeSlash, EscapeRepeat : Boolean; ParameterStyle : TParamStyle): String;

var pb : TParamBinding;
    rs : string;

begin
  Result := ParseSQL(SQL,DoCreate,EscapeSlash,EscapeRepeat,ParameterStyle,pb, rs);
end;

Function TParams.ParseSQL(SQL: String; DoCreate, EscapeSlash, EscapeRepeat : Boolean; ParameterStyle : TParamStyle; var ParamBinding: TParambinding): String;

var rs : string;

begin
  Result := ParseSQL(SQL,DoCreate,EscapeSlash, EscapeRepeat, ParameterStyle,ParamBinding, rs);
end;

function SkipComments(var p: PChar; EscapeSlash, EscapeRepeat : Boolean) : Boolean;

begin
  result := false;
  case p^ of
    '''':
      begin
        SkipQuotesString(p,'''',EscapeSlash,EscapeRepeat); // single quote delimited string
        Result := True;
      end;
    '"':
      begin
        SkipQuotesString(p,'"',EscapeSlash,EscapeRepeat);  // double quote delimited string
        Result := True;
      end;
    '-': // possible start of -- comment
      begin
        Inc(p);
        if p^='-' then // -- comment
        begin
          Result := True;
          repeat // skip until at end of line
            Inc(p);
          until p^ in [#10, #0];
        end;
        if p^<>#0 then Inc(p); // newline is part of comment
      end;
    '/': // possible start of /* */ comment
      begin
        Inc(p);
        if p^='*' then // /* */ comment
        begin
          Result := True;
          repeat
            Inc(p);
            if p^='*' then // possible end of comment
            begin
              Inc(p);
              if p^='/' then Break; // end of comment
            end;
          until p^=#0;
          if p^='/' then Inc(p); // skip final /
        end;
      end;
  end; {case}
end;

Function TParams.ParseSQL(SQL: String; DoCreate, EscapeSlash, EscapeRepeat: Boolean; ParameterStyle : TParamStyle; var ParamBinding: TParambinding; var ReplaceString : string): String;

type
  // used for ParamPart
  TStringPart = record
    Start,Stop:integer;
  end;

const
  ParamAllocStepSize = 8;

var
  IgnorePart:boolean;
  p,ParamNameStart,BufStart:PChar;
  ParamName:string;
  QuestionMarkParamCount,ParameterIndex,NewLength:integer;
  ParamCount:integer; // actual number of parameters encountered so far;
                      // always <= Length(ParamPart) = Length(Parambinding)
                      // Parambinding will have length ParamCount in the end
  ParamPart:array of TStringPart; // describe which parts of buf are parameters
  NewQueryLength:integer;
  NewQuery:string;
  NewQueryIndex,BufIndex,CopyLen,i:integer;    // Parambinding will have length ParamCount in the end
  b:integer;
  tmpParam:TParam;

begin
  if DoCreate then Clear;
  // Parse the SQL and build ParamBinding
  ParamCount:=0;
  NewQueryLength:=Length(SQL);
  SetLength(ParamPart,ParamAllocStepSize);
  SetLength(Parambinding,ParamAllocStepSize);
  QuestionMarkParamCount:=0; // number of ? params found in query so far

  ReplaceString := '$';
  if ParameterStyle = psSimulated then
    while pos(ReplaceString,SQL) > 0 do ReplaceString := ReplaceString+'$';

  p:=PChar(SQL);
  BufStart:=p; // used to calculate ParamPart.Start values
  repeat
    SkipComments(p,EscapeSlash,EscapeRepeat);
    case p^ of
      ':','?': // parameter
        begin
          IgnorePart := False;
          if p^=':' then
          begin // find parameter name
            Inc(p);
            if p^ in [':','=',' '] then  // ignore ::, since some databases uses this as a cast (wb 4813)
            begin
              IgnorePart := True;
              Inc(p);
            end
            else
            begin
              if p^='"' then // Check if the parameter-name is between quotes
                begin
                ParamNameStart:=p;
                SkipQuotesString(p,'"',EscapeSlash,EscapeRepeat);
                // Do not include the quotes in ParamName, but they must be included
                // when the parameter is replaced by some place-holder.
                ParamName:=Copy(ParamNameStart+1,1,p-ParamNameStart-2);
                end
              else
                begin
                ParamNameStart:=p;
                while not (p^ in (SQLDelimiterCharacters+[#0,'=','+','-','*','\','/','[',']','|'])) do
                  Inc(p);
                ParamName:=Copy(ParamNameStart,1,p-ParamNameStart);
                end;
            end;
          end
          else
          begin
            Inc(p);
            ParamNameStart:=p;
            ParamName:='';
          end;

          if not IgnorePart then
          begin
            Inc(ParamCount);
            if ParamCount>Length(ParamPart) then
            begin
              NewLength:=Length(ParamPart)+ParamAllocStepSize;
              SetLength(ParamPart,NewLength);
              SetLength(ParamBinding,NewLength);
            end;

            if DoCreate then
              begin
              // Check if this is the first occurance of the parameter
              tmpParam := FindParam(ParamName);
              // If so, create the parameter and assign the Parameterindex
              if not assigned(tmpParam) then
                ParameterIndex := CreateParam(ftUnknown, ParamName, ptInput).Index
              else  // else only assign the ParameterIndex
                ParameterIndex := tmpParam.Index;
              end
            // else find ParameterIndex
            else
              begin
                if ParamName<>'' then
                  ParameterIndex:=ParamByName(ParamName).Index
                else
                begin
                  ParameterIndex:=QuestionMarkParamCount;
                  Inc(QuestionMarkParamCount);
                end;
              end;
            if ParameterStyle in [psPostgreSQL,psSimulated] then
              begin
              i:=ParameterIndex+1;
              repeat
                inc(NewQueryLength);
                i:=i div 10;
              until i=0;
              end;

            // store ParameterIndex in FParamIndex, ParamPart data
            ParamBinding[ParamCount-1]:=ParameterIndex;
            ParamPart[ParamCount-1].Start:=ParamNameStart-BufStart;
            ParamPart[ParamCount-1].Stop:=p-BufStart+1;

            // update NewQueryLength
            Dec(NewQueryLength,p-ParamNameStart);
          end;
        end;
      #0:Break;
    else
      Inc(p);
    end;
  until false;

  SetLength(ParamPart,ParamCount);
  SetLength(ParamBinding,ParamCount);

  if ParamCount>0 then
  begin
    // replace :ParamName by ? for interbase and by $x for postgresql/psSimulated
    // (using ParamPart array and NewQueryLength)
    if (ParameterStyle = psSimulated) and (length(ReplaceString) > 1) then
      inc(NewQueryLength,(paramcount)*(length(ReplaceString)-1));

    SetLength(NewQuery,NewQueryLength);
    NewQueryIndex:=1;
    BufIndex:=1;
    for i:=0 to High(ParamPart) do
    begin
      CopyLen:=ParamPart[i].Start-BufIndex;
      Move(SQL[BufIndex],NewQuery[NewQueryIndex],CopyLen);
      Inc(NewQueryIndex,CopyLen);
      case ParameterStyle of
        psInterbase : begin
                        NewQuery[NewQueryIndex]:='?';
                        Inc(NewQueryIndex);
                      end;
        psPostgreSQL,
        psSimulated : begin
                        ParamName := IntToStr(ParamBinding[i]+1);
                        for b := 1 to length(ReplaceString) do
                          begin
                          NewQuery[NewQueryIndex]:='$';
                          Inc(NewQueryIndex);
                          end;
                        for b := 1 to length(ParamName) do
                          begin
                          NewQuery[NewQueryIndex]:=ParamName[b];
                          Inc(NewQueryIndex);
                          end;
                      end;
      end;
      BufIndex:=ParamPart[i].Stop;
    end;
    CopyLen:=Length(SQL)+1-BufIndex;
    if CopyLen > 0 then
      Move(SQL[BufIndex],NewQuery[NewQueryIndex],CopyLen);
  end
  else
    NewQuery:=SQL;
    
  Result := NewQuery;
end;


Procedure TParams.RemoveParam(Value: TParam);
begin
   Value.Collection:=Nil;
end;

{ TParam }

Function TParam.GetDataSet: TDataSet;
begin
  If Assigned(Collection) and (Collection is TParams) then
    Result:=TParams(Collection).GetDataset
  else
    Result:=Nil;
end;

Function TParam.IsParamStored: Boolean;
begin
  Result:=Bound;
end;

Procedure TParam.AssignParam(Param: TParam);
begin
  if Not Assigned(Param) then
    begin
    Clear;
    FDataType:=ftunknown;
    FParamType:=ptUnknown;
    Name:='';
    Size:=0;
    Precision:=0;
    NumericScale:=0;
    end
  else
    begin
    FDataType:=Param.DataType;
    if Param.IsNull then
      Clear
    else
      FValue:=Param.FValue;
    FBound:=Param.Bound;
    Name:=Param.Name;
    if (ParamType=ptUnknown) then
      ParamType:=Param.ParamType;
    Size:=Param.Size;
    Precision:=Param.Precision;
    NumericScale:=Param.NumericScale;
    end;
end;

Procedure TParam.AssignTo(Dest: TPersistent);
begin
  if (Dest is TField) then
    AssignToField(TField(Dest))
  else
    inherited AssignTo(Dest);
end;

Function TParam.GetAsBoolean: Boolean;
begin
  If IsNull then
    Result:=False
  else
    Result:=FValue;
end;

Function TParam.GetAsCurrency: Currency;
begin
  If IsNull then
    Result:=0.0
  else
    Result:=FValue;
end;

Function TParam.GetAsDateTime: TDateTime;
begin
  If IsNull then
    Result:=0.0
  else
    Result:=FValue;
end;

Function TParam.GetAsFloat: Double;
begin
  If IsNull then
    Result:=0.0
  else
    Result:=FValue;
end;

Function TParam.GetAsInteger: Longint;
begin
  If IsNull then
    Result:=0
  else
    Result:=FValue;
end;

Function TParam.GetAsLargeInt: LargeInt;
begin
  If IsNull then
    Result:=0
  else
    Result:=FValue;
end;


Function TParam.GetAsMemo: string;
begin
  If IsNull then
    Result:=''
  else
    Result:=FValue;
end;

Function TParam.GetAsString: string;
var P: Pointer;
begin
  If IsNull then
    Result:=''
  else if (FDataType in [ftBytes, ftVarBytes]) and VarIsArray(FValue) then
  begin
    SetLength(Result, (VarArrayHighBound(FValue, 1) + 1) div SizeOf(Char));
    P := VarArrayLock(FValue);
    try
      Move(P^, Result[1], Length(Result) * SizeOf(Char));
    finally
      VarArrayUnlock(FValue);
    end;
  end
  else
    Result:=FValue;
end;

function TParam.GetAsWideString: WideString;
begin
  if IsNull then
    Result := ''
  else
    Result := FValue;
end;


Function TParam.GetAsVariant: Variant;
begin
  if IsNull then
    Result:=Null
  else
    Result:=FValue;
end;

function TParam.GetAsFMTBCD: TBCD;
begin
  If IsNull then
    Result:= nullbcd
  else
    Result:=VarToBCD(FValue);
end;

Function TParam.GetDisplayName: string;
begin
  if (FName<>'') then
    Result:=FName
  else
    Result:=inherited GetDisplayName
end;

Function TParam.GetIsNull: Boolean;
begin
  Result:= VarIsNull(FValue) or VarIsClear(FValue);
end;

Function TParam.IsEqual(AValue: TParam): Boolean;
begin
  Result:=(Name=AValue.Name)
          and (IsNull=AValue.IsNull)
          and (Bound=AValue.Bound)
          and (DataType=AValue.DataType)
          and (ParamType=AValue.ParamType)
          and (VarType(FValue)=VarType(AValue.FValue))
          and (FValue=AValue.FValue);
end;

Procedure TParam.SetAsBlob(const AValue: TBlobData);
begin
  FDataType:=ftBlob;
  Value:=AValue;
end;

Procedure TParam.SetAsBoolean(AValue: Boolean);
begin
  FDataType:=ftBoolean;
  Value:=AValue;
end;

Procedure TParam.SetAsCurrency(const AValue: Currency);
begin
  FDataType:=ftCurrency;
  Value:=Avalue;
end;

Procedure TParam.SetAsDate(const AValue: TDateTime);
begin
  FDataType:=ftDate;
  Value:=Avalue;
end;

Procedure TParam.SetAsDateTime(const AValue: TDateTime);
begin
  FDataType:=ftDateTime;
  Value:=AValue;
end;

Procedure TParam.SetAsFloat(const AValue: Double);
begin
  FDataType:=ftFloat;
  Value:=AValue;
end;

Procedure TParam.SetAsInteger(AValue: Longint);
begin
  FDataType:=ftInteger;
  Value:=AValue;
end;

Procedure TParam.SetAsLargeInt(AValue: LargeInt);
begin
  FDataType:=ftLargeint;
  Value:=AValue;
end;

Procedure TParam.SetAsMemo(const AValue: string);
begin
  FDataType:=ftMemo;
  Value:=AValue;
end;


Procedure TParam.SetAsSmallInt(AValue: LongInt);
begin
  FDataType:=ftSmallInt;
  Value:=AValue;
end;

Procedure TParam.SetAsString(const AValue: string);
begin
  if FDataType <> ftFixedChar then
    FDataType := ftString;
  Value:=AValue;
end;

procedure TParam.SetAsWideString(const aValue: WideString);
begin
  if FDataType <> ftFixedWideChar then
    FDataType := ftWideString;
  Value := aValue;
end;

function TParam.getasunicodestring: unicodestring;
begin
  if IsNull then
    Result := ''
  else
    Result := FValue;
end;

procedure TParam.setasunicodestring(const avalue: unicodestring);
begin
  if FDataType <> ftFixedWideChar then
    FDataType := ftWideString;
  Value := aValue;
end;

Procedure TParam.SetAsTime(const AValue: TDateTime);
begin
  FDataType:=ftTime;
  Value:=AValue;
end;

Procedure TParam.SetAsVariant(const AValue: Variant);
begin
  FValue:=AValue;
  FBound:=not VarIsClear(AValue);
  if FDataType = ftUnknown then
    case VarType(Value) of
      varBoolean  : FDataType:=ftBoolean;
      varSmallint,
      varShortInt,
      varByte     : FDataType:=ftSmallInt;
      varWord,
      varInteger  : FDataType:=ftInteger;
      varCurrency : FDataType:=ftCurrency;
      varLongWord,
      varSingle,
      varDouble   : FDataType:=ftFloat;
      varDate     : FDataType:=ftDateTime;
      varString,
      varOleStr   : if (FDataType<>ftFixedChar) then
                      FDataType:=ftString;
      varInt64    : FDataType:=ftLargeInt;
    else
      if VarIsFmtBCD(Value) then
        FDataType:=ftFmtBCD
      else if VarIsArray(AValue) and (VarType(AValue) and varTypeMask = varByte) then
        FDataType:=ftBytes
      else
        FDataType:=ftUnknown;
    end;
end;

Procedure TParam.SetAsWord(AValue: LongInt);
begin
  FDataType:=ftWord;
  Value:=AValue;
end;

procedure TParam.SetAsFMTBCD(const AValue: TBCD);
begin
  FDataType:=ftFMTBcd;
  FValue:=VarFmtBCDCreate(AValue);
end;

Procedure TParam.SetDataType(AValue: TFieldType);

Var
  VT : Integer;

begin
  FDataType:=AValue;
  VT:=FieldTypetoVariantMap[AValue];
  If (VT=varError) then
    clear
  else
    if not VarIsEmpty(FValue) then
      begin
      Try
        FValue:=VarAsType(FValue,VT)
      except
        Clear;
      end { try }
      end;
end;

Procedure TParam.SetText(const AValue: string);
begin
  Value:=AValue;
end;

constructor TParam.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  ParamType:=ptUnknown;
  DataType:=ftUnknown;
  FValue:=Unassigned;
end;

constructor TParam.Create(AParams: TParams; AParamType: TParamType);
begin
  Create(AParams);
  ParamType:=AParamType;
end;

Procedure TParam.Assign(Source: TPersistent);
begin
  if (Source is TParam) then
    AssignParam(TParam(Source))
  else if (Source is TField) then
    AssignField(TField(Source))
  else if (source is TStrings) then
    AsMemo:=TStrings(Source).Text
  else
    inherited Assign(Source);
end;

Procedure TParam.AssignField(Field: TField);
begin
  if Assigned(Field) then
    begin
    // Need TField.Value
    AssignFieldValue(Field,Field.Value);
    Name:=Field.FieldName;
    end
  else
    begin
    Clear;
    Name:='';
    end
end;

procedure TParam.AssignToField(Field : TField);

begin
  if Assigned(Field) then
    case FDataType of
      ftUnknown  : DatabaseErrorFmt(SUnknownParamFieldType,[Name],DataSet);
      // Need TField.AsSmallInt
      ftSmallint : Field.AsInteger:=AsSmallInt;
      // Need TField.AsWord
      ftWord     : Field.AsInteger:=AsWord;
      ftInteger,
      ftAutoInc  : Field.AsInteger:=AsInteger;
      ftCurrency : Field.AsCurrency:=AsCurrency;
      ftFloat    : Field.AsFloat:=AsFloat;
      ftBoolean  : Field.AsBoolean:=AsBoolean;
      ftBlob,
      ftGraphic..ftTypedBinary,
      ftOraBlob,
      ftOraClob,
      ftString,
      ftMemo,
      ftAdt,
      ftFixedChar: Field.AsString:=AsString;
      ftTime,
      ftDate,
      ftDateTime : Field.AsDateTime:=AsDateTime;
      ftBytes,
      ftVarBytes : Field.AsVariant:=Value;
      ftFmtBCD   : Field.AsBCD:=AsFMTBCD;
    else
      If not (DataType in [ftCursor, ftArray, ftDataset,ftReference]) then
        DatabaseErrorFmt(SBadParamFieldType, [Name], DataSet);
    end;
end;

procedure TParam.AssignFromField(Field : TField);

begin
  if Assigned(Field) then
    begin
    FDataType:=Field.DataType;
    case Field.DataType of
      ftUnknown  : DatabaseErrorFmt(SUnknownParamFieldType,[Name],DataSet);
      // Need TField.AsSmallInt
      ftSmallint : AsSmallint:=Field.AsInteger;
      // Need TField.AsWord
      ftWord     : AsWord:=Field.AsInteger;
      ftInteger,
      ftAutoInc  : AsInteger:=Field.AsInteger;
      ftBCD,
      ftCurrency : AsCurrency:=Field.AsCurrency;
      ftFloat    : AsFloat:=Field.AsFloat;
      ftBoolean  : AsBoolean:=Field.AsBoolean;
      ftBlob,
      ftGraphic..ftTypedBinary,
      ftOraBlob,
      ftOraClob,
      ftString,
      ftMemo,
      ftAdt,
      ftFixedChar: AsString:=Field.AsString;
      ftTime,
      ftDate,
      ftDateTime : AsDateTime:=Field.AsDateTime;
      ftBytes,
      ftVarBytes : Value:=Field.AsVariant;
      ftFmtBCD   : AsFMTBCD:=Field.AsBCD;
    else
      If not (DataType in [ftCursor, ftArray, ftDataset,ftReference]) then
        DatabaseErrorFmt(SBadParamFieldType, [Name], DataSet);
    end;
    end;
end;

Procedure TParam.AssignFieldValue(Field: TField; const AValue: Variant);

begin
  If Assigned(Field) then
    begin

    if (Field.DataType = ftString) and TStringField(Field).FixedChar then
      FDataType := ftFixedChar
    else if (Field.DataType = ftMemo) and (Field.Size > 255) then
      FDataType := ftString
    else if (Field.DataType = ftWideString) and TWideStringField(Field).FixedChar then
      FDataType := ftFixedWideChar
    else if (Field.DataType = ftWideMemo) and (Field.Size > 255) then
      FDataType := ftWideString
    else
      FDataType := Field.DataType;

    if VarIsNull(AValue) then
      Clear
    else
      Value:=AValue;

    Size:=Field.DataSize;
    FBound:=True;

    end;
end;

Procedure TParam.Clear;
begin
  FValue:=UnAssigned;
end;

Procedure TParam.GetData(Buffer: Pointer);

Var
  P  : Pointer;
  S  : String;
  ws : WideString;
  l  : Integer;
begin
  case FDataType of
    ftUnknown  : DatabaseErrorFmt(SUnknownParamFieldType,[Name],DataSet);
    ftSmallint : PSmallint(Buffer)^:=AsSmallInt;
    ftWord     : PWord(Buffer)^:=AsWord;
    ftInteger,
    ftAutoInc  : PInteger(Buffer)^:=AsInteger;
    ftCurrency : PDouble(Buffer)^:=AsCurrency;
    ftFloat    : PDouble(Buffer)^:=AsFloat;
    ftBoolean  : PWordBool(Buffer)^:=AsBoolean;
    ftString,
    ftMemo,
    ftAdt,
    ftFixedChar:
      begin
      S:=AsString;
      StrMove(PChar(Buffer),Pchar(S),Length(S)+1);
      end;
    ftWideString,
    ftWideMemo: begin
      ws := GetAsWideString;
      l := Length(ws);
      if l > 0 then
        Move(ws[1], Buffer, Succ(l)*2)
      else
        PWideChar(Buffer)^ := #0
    end;
    ftTime     : PInteger(Buffer)^:=DateTimeToTimeStamp(AsTime).Time;
    ftDate     : PInteger(Buffer)^:=DateTimeToTimeStamp(AsTime).Date;
    ftDateTime : PDouble(Buffer)^:=TimeStampToMSecs(DateTimeToTimeStamp(AsDateTime));
    ftBlob,
    ftGraphic..ftTypedBinary,
    ftOraBlob,
    ftOraClob  :
      begin
      S:=GetAsString;
      Move(PChar(S)^, Buffer^, Length(S));
      end;
    ftBytes, ftVarBytes:
      begin
      if VarIsArray(FValue) then
        begin
        P:=VarArrayLock(FValue);
        try
          Move(P^, Buffer^, VarArrayHighBound(FValue, 1) + 1);
        finally
          VarArrayUnlock(FValue);
        end;
        end;
      end;
    ftFmtBCD   : PBCD(Buffer)^:=AsFMTBCD;
  else
    If not (DataType in [ftCursor, ftArray, ftDataset,ftReference]) then
      DatabaseErrorFmt(SBadParamFieldType, [Name], DataSet);
  end;
end;

Function TParam.GetDataSize: Integer;
begin
  Result:=0;
  case DataType of
    ftUnknown  : DatabaseErrorFmt(SUnknownParamFieldType,[Name],DataSet);
    ftBoolean  : Result:=SizeOf(WordBool);
    ftInteger,
    ftAutoInc  : Result:=SizeOf(Integer);
    ftSmallint : Result:=SizeOf(SmallInt);
    ftWord     : Result:=SizeOf(Word);
    ftTime,
    ftDate     : Result:=SizeOf(Integer);
    ftDateTime,
    ftCurrency,
    ftFloat    : Result:=SizeOf(Double);
    ftString,
    ftFixedChar,
    ftMemo,
    ftADT      : Result:=Length(AsString)+1;
    ftBytes,
    ftVarBytes : if VarIsArray(FValue) then
                   Result:=VarArrayHighBound(FValue,1)+1
                 else
                   Result:=0;
    ftBlob,
    ftGraphic..ftTypedBinary,
    ftOraClob,
    ftOraBlob  : Result:=Length(AsString);
    ftArray,
    ftDataSet,
    ftReference,
    ftCursor   : Result:=0;
    ftFmtBCD   : Result:=SizeOf(TBCD);
  else
    DatabaseErrorFmt(SBadParamFieldType,[Name],DataSet);
  end;


end;

Procedure TParam.LoadFromFile(const FileName: string; BlobType: TBlobType);

Var
  S : TFileStream;

begin
  S:=TFileStream.Create(FileName,fmOpenRead);
  Try
    LoadFromStream(S,BlobType);
  Finally
    FreeAndNil(S);
  end;
end;

Procedure TParam.LoadFromStream(Stream: TStream; BlobType: TBlobType);

Var
  Temp : String;

begin
  FDataType:=BlobType;
  With Stream do
    begin
    Position:=0;
    SetLength(Temp,Size);
    ReadBuffer(Pointer(Temp)^,Size);
    FValue:=Temp;
    end;
end;

Procedure TParam.SetBlobData(Buffer: Pointer; ASize: Integer);

Var
  Temp : String;

begin
  SetLength(Temp,ASize);
  Move(Buffer^,Temp,ASize);
  AsBlob:=Temp;
end;

Procedure TParam.SetData(Buffer: Pointer);

  Function FromTimeStamp(T,D : Integer) : TDateTime;

  Var TS : TTimeStamp;

  begin
    TS.Time:=T;
    TS.Date:=D;
    Result:=TimeStampToDateTime(TS);
  end;

begin
  case FDataType of
    ftUnknown  : DatabaseErrorFmt(SUnknownParamFieldType,[Name],DataSet);
    ftSmallint : AsSmallInt:=PSmallint(Buffer)^;
    ftWord     : AsWord:=PWord(Buffer)^;
    ftInteger,
    ftAutoInc  : AsInteger:=PInteger(Buffer)^;
    ftCurrency : AsCurrency:= PDouble(Buffer)^;
    ftFloat    : AsFloat:=PDouble(Buffer)^;
    ftBoolean  : AsBoolean:=PWordBool(Buffer)^;
    ftString,
    ftFixedChar: AsString:=StrPas(Buffer);
    ftMemo     : AsMemo:=StrPas(Buffer);
    ftTime     : AsTime:=FromTimeStamp(PInteger(Buffer)^,DateDelta);
    ftDate     : Asdate:=FromTimeStamp(0,PInteger(Buffer)^);
    ftDateTime : AsDateTime:=TimeStampToDateTime(MSecsToTimeStamp(trunc(PDouble(Buffer)^)));
    ftCursor   : FValue:=0;
    ftBlob,
    ftGraphic..ftTypedBinary,
    ftOraBlob,
    ftOraClob  : SetBlobData(Buffer, StrLen(PChar(Buffer)));
    ftFmtBCD   : AsFMTBCD:=PBCD(Buffer)^;
  else
    DatabaseErrorFmt(SBadParamFieldType,[Name],DataSet);
  end;
end;

Procedure TParams.CopyParamValuesFromDataset(ADataset : TDataset; CopyBound : Boolean);

Var
  I : Integer;
  P : TParam;
  F : TField;
  
begin
  If (ADataSet<>Nil) then
    For I:=0 to Count-1 do
     begin
     P:=Items[i];
     if CopyBound or (not P.Bound) then
       begin
       F:=ADataset.FieldByName(P.Name);
       P.AssignField(F);
       If Not CopyBound then
         P.Bound:=False;
       end;
    end;
end;

end.
