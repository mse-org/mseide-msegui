unit mclasses;
{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 1999-2000 by Michael Van Canneyt and Florian Klaempfl

    Classes unit for linux

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 Modified 2013 by Martin Schreiber

 **********************************************************************}

{$mode objfpc}
{$h+}
{ determine the type of the resource/form file }
{$define Win16Res}
{$define classesinline}

{$INLINE ON}
interface

uses
 classes,typinfo,sysutils;

type

 tstrings = class;
 tstringlist = class;
 tfiler = class;
 treader = class;
 twriter = class;
 tcomponent = class;
 tstream = class;
 tfilestream = class;
 tmemorystream = class;


  TReaderProc = procedure(Reader: treader) of object;
  TWriterProc = procedure(Writer: twriter) of object;
  TStreamProc = procedure(Stream: TStream) of object;

{$M+}

  tpersistent = class(TObject{,IFPObserved})
  private
//    FObservers : TFPList;
    procedure AssignError(Source: tpersistent);
  protected
    procedure AssignTo(Dest: tpersistent); virtual;
    procedure DefineProperties(Filer: tfiler); virtual;
    function  GetOwner: tpersistent; dynamic;
//    Procedure FPOAttachObserver(AObserver : TObject);
//    Procedure FPODetachObserver(AObserver : TObject);
//    Procedure FPONotifyObservers(ASender : TObject; AOperation : TFPObservedOperation; Data : Pointer);
  public
    Destructor Destroy; override;
    procedure Assign(Source: tpersistent); virtual;
    function  GetNamePath: string; virtual; {dynamic;}
  end;

{$M-}

  TPersistentClass = class of TPersistent;

  TGetChildProc = procedure (Child: TComponent) of object;

  tcomponent = class(tpersistent{,IUnknown,IInterfaceComponentReference})
  private
    FOwner: tcomponent;
    FName: TComponentName;
    FTag: Ptrint;
    FComponents: TFpList;
    FFreeNotifies: TFpList;
    FDesignInfo: Longint;
    FVCLComObject: Pointer;
    FComponentState: TComponentState;
    function GetComObject: IUnknown;
    function GetComponent(AIndex: Integer): tcomponent;
    function GetComponentCount: Integer;
    function GetComponentIndex: Integer;
    procedure Insert(AComponent: tcomponent);
    procedure ReadLeft(Reader: treader);
    procedure ReadTop(Reader: treader);
    procedure Remove(AComponent: tcomponent);
    procedure RemoveNotification(AComponent: tcomponent);
    procedure SetComponentIndex(Value: Integer);
    procedure SetReference(Enable: Boolean);
    procedure WriteLeft(Writer: twriter);
    procedure WriteTop(Writer: twriter);
  protected
    FComponentStyle: TComponentStyle;
    procedure ChangeName(const NewName: TComponentName);
    procedure DefineProperties(Filer: tfiler); override;
    procedure GetChildren(Proc: TGetChildProc; Root: tcomponent); dynamic;
    function GetChildOwner: tcomponent; dynamic;
    function GetChildParent: tcomponent; dynamic;
    function GetOwner: tpersistent; override;
    procedure Loaded; virtual;
    procedure Loading; virtual;
    procedure Notification(AComponent: tcomponent;
      Operation: TOperation); virtual;
    procedure PaletteCreated; dynamic;
    procedure ReadState(Reader: treader); virtual;
    procedure SetAncestor(Value: Boolean);
    procedure SetDesigning(Value: Boolean; SetChildren : Boolean = True);
    procedure SetDesignInstance(Value: Boolean);
    procedure SetInline(Value: Boolean);
    procedure SetName(const NewName: TComponentName); virtual;
    procedure SetChildOrder(Child: tcomponent; Order: Integer); dynamic;
    procedure SetParentComponent(Value: tcomponent); dynamic;
    procedure Updating; dynamic;
    procedure Updated; dynamic;
    class procedure UpdateRegistry(Register: Boolean; const ClassID, ProgID: string); dynamic;
    procedure ValidateRename(AComponent: tcomponent;
      const CurName, NewName: string); virtual;
    procedure ValidateContainer(AComponent: tcomponent); dynamic;
    procedure ValidateInsert(AComponent: tcomponent); dynamic;
    { IUnknown }
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID: TGUID; out Obj): Hresult; virtual; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef: Integer; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release: Integer; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function iicrGetComponent: tcomponent;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    //!! Moved temporary
    // fpdoc doesn't handle this yet :(
{$ifndef fpdocsystem}
//    function IInterfaceComponentReference.GetComponent=iicrgetcomponent;
{$endif}
    procedure WriteState(Writer: twriter); virtual;
    constructor Create(AOwner: tcomponent); virtual;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    procedure DestroyComponents;
    procedure Destroying;
    function ExecuteAction(Action: TBasicAction): Boolean; dynamic;
    function FindComponent(const AName: string): tcomponent;
    procedure FreeNotification(AComponent: tcomponent);
    procedure RemoveFreeNotification(AComponent: tcomponent);
    procedure FreeOnRelease;
    function GetEnumerator: TComponentEnumerator;
    function GetNamePath: string; override;
    function GetParentComponent: tcomponent; dynamic;
    function HasParent: Boolean; dynamic;
    procedure InsertComponent(AComponent: tcomponent);
    procedure RemoveComponent(AComponent: tcomponent);
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;
    procedure SetSubComponent(ASubComponent: Boolean);
    function UpdateAction(Action: TBasicAction): Boolean; dynamic;
    property ComObject: IUnknown read GetComObject;
    function IsImplementorOf (const Intf:IInterface):boolean;
    procedure ReferenceInterface(const intf:IInterface;op:TOperation);
    property Components[Index: Integer]: tcomponent read GetComponent;
    property ComponentCount: Integer read GetComponentCount;
    property ComponentIndex: Integer read GetComponentIndex write SetComponentIndex;
    property ComponentState: TComponentState read FComponentState;
    property ComponentStyle: TComponentStyle read FComponentStyle;
    property DesignInfo: Longint read FDesignInfo write FDesignInfo;
    property Owner: tcomponent read FOwner;
    property VCLComObject: Pointer read FVCLComObject write FVCLComObject;
  published
    property Name: TComponentName read FName write SetName stored False;
    property Tag: PtrInt read FTag write FTag default 0;
  end;

  TComponentClass = class of TComponent;

  tcollection = class;
  
  TCollectionItem = class(TPersistent)
  private
    FCollection: TCollection;
    FID: Integer;
    FUpdateCount: Integer;
    function GetIndex: Integer;
  protected
    procedure SetCollection(Value: TCollection);virtual;
    procedure Changed(AllItems: Boolean);
    function GetOwner: TPersistent; override;
    function GetDisplayName: string; virtual;
    procedure SetIndex(Value: Integer); virtual;
    procedure SetDisplayName(const Value: string); virtual;
    property UpdateCount: Integer read FUpdateCount;
  public
    constructor Create(ACollection: TCollection); virtual;
    destructor Destroy; override;
    function GetNamePath: string; override;
    property Collection: TCollection read FCollection write SetCollection;
    property ID: Integer read FID;
    property Index: Integer read GetIndex write SetIndex;
    property DisplayName: string read GetDisplayName write SetDisplayName;
  end;

  TCollectionItemClass = class of TCollectionItem;
  TCollectionSortCompare = function (Item1, Item2: TCollectionItem): Integer;

  TCollection = class(TPersistent)
  private
    FItemClass: TCollectionItemClass;
    FItems: TFpList;
    FUpdateCount: Integer;
    FNextID: Integer;
    FPropName: string;
    function GetCount: Integer;
    function GetPropName: string;
    procedure InsertItem(Item: TCollectionItem);
    procedure RemoveItem(Item: TCollectionItem);
    procedure DoClear;
  protected
    { Design-time editor support }
    function GetAttrCount: Integer; dynamic;
    function GetAttr(Index: Integer): string; dynamic;
    function GetItemAttr(Index, ItemIndex: Integer): string; dynamic;
    procedure Changed;
    function GetItem(Index: Integer): TCollectionItem;
    procedure SetItem(Index: Integer; Value: TCollectionItem);
    procedure SetItemName(Item: TCollectionItem); virtual;
    procedure SetPropName; virtual;
    procedure Update(Item: TCollectionItem); virtual;
    procedure Notify(Item: TCollectionItem;Action: TCollectionNotification); virtual;
    property PropName: string read GetPropName write FPropName;
    property UpdateCount: Integer read FUpdateCount;
  public
    constructor Create(AItemClass: TCollectionItemClass);
    destructor Destroy; override;
    function Owner: TPersistent;
    function Add: TCollectionItem;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate; virtual;
    procedure Clear;
    procedure EndUpdate; virtual;
    procedure Delete(Index: Integer);
    function GetEnumerator: TCollectionEnumerator;
    function GetNamePath: string; override;
    function Insert(Index: Integer): TCollectionItem;
    function FindItemID(ID: Integer): TCollectionItem;
    procedure Exchange(Const Index1, index2: integer);
    procedure Sort(Const Compare : TCollectionSortCompare);
    property Count: Integer read GetCount;
    property ItemClass: TCollectionItemClass read FItemClass;
    property Items[Index: Integer]: TCollectionItem read GetItem write SetItem;
  end;

  TOwnedCollection = class(TCollection)
  private
    FOwner: TPersistent;
  protected
    Function GetOwner: TPersistent; override;
  public
    Constructor Create(AOwner: TPersistent;AItemClass: TCollectionItemClass);
  end;


  TFindMethodEvent = procedure(Reader: TReader; const MethodName: string;
    var Address: Pointer; var Error: Boolean) of object;
  TSetMethodPropertyEvent = procedure(Reader: TReader; Instance: TPersistent;
    PropInfo: PPropInfo; const TheMethodName: string;
    var Handled: boolean) of object;
  TSetNameEvent = procedure(Reader: TReader; Component: TComponent;
    var Name: string) of object;
  TReferenceNameEvent = procedure(Reader: TReader; var Name: string) of object;
  TAncestorNotFoundEvent = procedure(Reader: TReader; const ComponentName: string;
    ComponentClass: TPersistentClass; var Component: TComponent) of object;
  TReadComponentsProc = procedure(Component: TComponent) of object;
  TReaderError = procedure(Reader: TReader; const Message: string;
    var Handled: Boolean) of object;
  TPropertyNotFoundEvent = procedure(Reader: TReader; Instance: TPersistent;
    var PropName: string; IsPath: boolean; var Handled, Skip: Boolean) of object;
  TFindComponentClassEvent = procedure(Reader: TReader; const ClassName: string;
    var ComponentClass: TComponentClass) of object;
  TCreateComponentEvent = procedure(Reader: TReader;
    ComponentClass: TComponentClass; var Component: TComponent) of object;

  TReadWriteStringPropertyEvent = procedure(Sender:TObject;
    const Instance: TPersistent; PropInfo: PPropInfo;
    var Content:string) of object;


  TFindAncestorEvent = procedure (Writer: TWriter; Component: TComponent;
    const Name: string; var Ancestor, RootAncestor: TComponent) of object;
  TWriteMethodPropertyEvent = procedure (Writer: TWriter; Instance: TPersistent;
    PropInfo: PPropInfo;
    const MethodValue, DefMethodValue: TMethod;
    var Handled: boolean) of object;

  tfiler = class(TObject)
  private
    FRoot: tcomponent;
    FLookupRoot: tcomponent;
    FAncestor: tpersistent;
    FIgnoreChildren: Boolean;
  protected
    procedure SetRoot(ARoot: tcomponent); virtual;
  public
    procedure DefineProperty(const Name: string;
      ReadData: TReaderProc; WriteData: TWriterProc;
      HasData: Boolean); virtual; abstract;
    procedure DefineBinaryProperty(const Name: string;
      ReadData, WriteData: TStreamProc;
      HasData: Boolean); virtual; abstract;
    property Root: tcomponent read FRoot write SetRoot;
    property LookupRoot: tcomponent read FLookupRoot;
    property Ancestor: tpersistent read FAncestor write FAncestor;
    property IgnoreChildren: Boolean read FIgnoreChildren write FIgnoreChildren;
  end;

  TAbstractObjectReader = class
  public
    function NextValue: TValueType; virtual; abstract;
    function ReadValue: TValueType; virtual; abstract;
    procedure BeginRootComponent; virtual; abstract;
    procedure BeginComponent(var Flags: TFilerFlags; var AChildPos: Integer;
      var CompClassName, CompName: String); virtual; abstract;
    function BeginProperty: String; virtual; abstract;

    //Please don't use read, better use ReadBinary whenever possible
    procedure Read(var Buf; Count: LongInt); virtual; abstract;
    { All ReadXXX methods are called _after_ the value type has been read! }
    procedure ReadBinary(const DestData: TMemoryStream); virtual; abstract;
{$ifndef FPUNONE}
    function ReadFloat: Extended; virtual; abstract;
    function ReadSingle: Single; virtual; abstract;
    function ReadDate: TDateTime; virtual; abstract;
{$endif}
    function ReadCurrency: Currency; virtual; abstract;
    function ReadIdent(ValueType: TValueType): String; virtual; abstract;
    function ReadInt8: ShortInt; virtual; abstract;
    function ReadInt16: SmallInt; virtual; abstract;
    function ReadInt32: LongInt; virtual; abstract;
    function ReadInt64: Int64; virtual; abstract;
    function ReadSet(EnumType: Pointer): Integer; virtual; abstract;
    function ReadStr: String; virtual; abstract;
    function ReadString(StringType: TValueType): String; virtual; abstract;
    function ReadWideString: WideString;virtual;abstract;
    function ReadUnicodeString: UnicodeString;virtual;abstract;
    procedure SkipComponent(SkipComponentInfos: Boolean); virtual; abstract;
    procedure SkipValue; virtual; abstract;
  end;

  TBinaryObjectReader = class(TAbstractObjectReader)
  protected
    FStream: TStream;
    FBuffer: Pointer;
    FBufSize: Integer;
    FBufPos: Integer;
    FBufEnd: Integer;

    function ReadWord : word; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
    function ReadDWord : longword; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
    function ReadQWord : qword; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$ifndef FPUNONE}
    function ReadExtended : extended; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$endif}
    procedure SkipProperty;
    procedure SkipSetBody;
  public
    constructor Create(Stream: TStream; BufSize: Integer);
    destructor Destroy; override;

    function NextValue: TValueType; override;
    function ReadValue: TValueType; override;
    procedure BeginRootComponent; override;
    procedure BeginComponent(var Flags: TFilerFlags; var AChildPos: Integer;
      var CompClassName, CompName: String); override;
    function BeginProperty: String; override;

    //Please don't use read, better use ReadBinary whenever possible
    procedure Read(var Buf; Count: LongInt); override;
    procedure ReadBinary(const DestData: TMemoryStream); override;
{$ifndef FPUNONE}
    function ReadFloat: Extended; override;
    function ReadSingle: Single; override;
    function ReadDate: TDateTime; override;
{$endif}
    function ReadCurrency: Currency; override;
    function ReadIdent(ValueType: TValueType): String; override;
    function ReadInt8: ShortInt; override;
    function ReadInt16: SmallInt; override;
    function ReadInt32: LongInt; override;
    function ReadInt64: Int64; override;
    function ReadSet(EnumType: Pointer): Integer; override;
    function ReadStr: String; override;
    function ReadString(StringType: TValueType): String; override;
    function ReadWideString: WideString;override;
    function ReadUnicodeString: UnicodeString;override;
    procedure SkipComponent(SkipComponentInfos: Boolean); override;
    procedure SkipValue; override;
  end;

  treader = class(tfiler)
  private
    FDriver: TAbstractObjectReader;
    FOwner: tcomponent;
    FParent: tcomponent;
    FFixups: TObject;
    FLoaded: TFpList;
    FOnFindMethod: TFindMethodEvent;
    FOnSetMethodProperty: TSetMethodPropertyEvent;
    FOnSetName: TSetNameEvent;
    FOnReferenceName: TReferenceNameEvent;
    FOnAncestorNotFound: TAncestorNotFoundEvent;
    FOnError: TReaderError;
    FOnPropertyNotFound: TPropertyNotFoundEvent;
    FOnFindComponentClass: TFindComponentClassEvent;
    FOnCreateComponent: TCreateComponentEvent;
    FPropName: string;
    FCanHandleExcepts: Boolean;
    FOnReadStringProperty:TReadWriteStringPropertyEvent;
    procedure DoFixupReferences;
    function FindComponentClass(const AClassName: string): TComponentClass;
  protected
    function Error(const Message: string): Boolean; virtual;
    function FindMethod(ARoot: tcomponent; const AMethodName: string): Pointer; virtual;
    procedure ReadProperty(AInstance: tpersistent);
    procedure ReadPropValue(Instance: tpersistent; PropInfo: Pointer);
    procedure PropertyError;
    procedure ReadData(Instance: tcomponent);
    property PropName: string read FPropName;
    property CanHandleExceptions: Boolean read FCanHandleExcepts;
    function CreateDriver(Stream: TStream; BufSize: Integer): TAbstractObjectReader; virtual;
  public
    constructor Create(Stream: TStream; BufSize: Integer);
    destructor Destroy; override;
    procedure BeginReferences;
    procedure CheckValue(Value: TValueType);
    procedure DefineProperty(const Name: string;
      AReadData: TReaderProc; WriteData: TWriterProc;
      HasData: Boolean); override;
    procedure DefineBinaryProperty(const Name: string;
      AReadData, WriteData: TStreamProc;
      HasData: Boolean); override;
    function EndOfList: Boolean;
    procedure EndReferences;
    procedure FixupReferences;
    function NextValue: TValueType;
    //Please don't use read, better use ReadBinary whenever possible
    //uuups, ReadBinary is protected ..
    procedure Read(var Buf; Count: LongInt); virtual;

    function ReadBoolean: Boolean;
    function ReadChar: Char;
    function ReadWideChar: WideChar;
    function ReadUnicodeChar: UnicodeChar;
    procedure ReadCollection(Collection: TCollection);
    function ReadComponent(Component: tcomponent): tcomponent;
    procedure ReadComponents(AOwner, AParent: tcomponent;
      Proc: TReadComponentsProc);
{$ifndef FPUNONE}
    function ReadFloat: Extended;
    function ReadSingle: Single;
    function ReadDate: TDateTime;
{$endif}
    function ReadCurrency: Currency;
    function ReadIdent: string;
    function ReadInteger: Longint;
    function ReadInt64: Int64;
    function ReadSet(EnumType: Pointer): Integer;
    procedure ReadListBegin;
    procedure ReadListEnd;
    function ReadRootComponent(ARoot: tcomponent): tcomponent;
    function ReadVariant: Variant;
    function ReadString: string;
    function ReadWideString: WideString;
    function ReadUnicodeString: UnicodeString;
    function ReadValue: TValueType;
    procedure CopyValue(Writer: twriter);
    property Driver: TAbstractObjectReader read FDriver;
    property Owner: tcomponent read FOwner write FOwner;
    property Parent: tcomponent read FParent write FParent;
    property OnError: TReaderError read FOnError write FOnError;
    property OnPropertyNotFound: TPropertyNotFoundEvent read FOnPropertyNotFound write FOnPropertyNotFound;
    property OnFindMethod: TFindMethodEvent read FOnFindMethod write FOnFindMethod;
    property OnSetMethodProperty: TSetMethodPropertyEvent read FOnSetMethodProperty write FOnSetMethodProperty;
    property OnSetName: TSetNameEvent read FOnSetName write FOnSetName;
    property OnReferenceName: TReferenceNameEvent read FOnReferenceName write FOnReferenceName;
    property OnAncestorNotFound: TAncestorNotFoundEvent read FOnAncestorNotFound write FOnAncestorNotFound;
    property OnCreateComponent: TCreateComponentEvent read FOnCreateComponent write FOnCreateComponent;
    property OnFindComponentClass: TFindComponentClassEvent read FOnFindComponentClass write FOnFindComponentClass;
    property OnReadStringProperty: TReadWriteStringPropertyEvent read FOnReadStringProperty write FOnReadStringProperty;
  end;

  TAbstractObjectWriter = class
  public
    { Begin/End markers. Those ones who don't have an end indicator, use
      "EndList", after the occurrence named in the comment. Note that this
      only counts for "EndList" calls on the same level; each BeginXXX call
      increases the current level. }
    procedure BeginCollection; virtual; abstract;  { Ends with the next "EndList" }
    procedure BeginComponent(Component: TComponent; Flags: TFilerFlags;
      ChildPos: Integer); virtual; abstract;  { Ends after the second "EndList" }
    procedure BeginList; virtual; abstract;
    procedure EndList; virtual; abstract;
    procedure BeginProperty(const PropName: String); virtual; abstract;
    procedure EndProperty; virtual; abstract;
    //Please don't use write, better use WriteBinary whenever possible
    procedure Write(const Buffer; Count: Longint); virtual;abstract;

    procedure WriteBinary(const Buffer; Count: Longint); virtual; abstract;
    procedure WriteBoolean(Value: Boolean); virtual; abstract;
    // procedure WriteChar(Value: Char);
{$ifndef FPUNONE}
    procedure WriteFloat(const Value: Extended); virtual; abstract;
    procedure WriteSingle(const Value: Single); virtual; abstract;
    procedure WriteDate(const Value: TDateTime); virtual; abstract;
{$endif}
    procedure WriteCurrency(const Value: Currency); virtual; abstract;
    procedure WriteIdent(const Ident: string); virtual; abstract;
    procedure WriteInteger(Value: Int64); virtual; abstract;
    procedure WriteUInt64(Value: QWord); virtual; abstract;
    procedure WriteVariant(const Value: Variant); virtual; abstract;
    procedure WriteMethodName(const Name: String); virtual; abstract;
    procedure WriteSet(Value: LongInt; SetType: Pointer); virtual; abstract;
    procedure WriteString(const Value: String); virtual; abstract;
    procedure WriteWideString(const Value: WideString);virtual;abstract;
    procedure WriteUnicodeString(const Value: UnicodeString);virtual;abstract;
  end;

  TBinaryObjectWriter = class(TAbstractObjectWriter)
  protected
    FStream: TStream;
    FBuffer: Pointer;
    FBufSize: Integer;
    FBufPos: Integer;
    FBufEnd: Integer;
    FSignatureWritten: Boolean;

    procedure WriteWord(w : word); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
    procedure WriteDWord(lw : longword); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
    procedure WriteQWord(qw : qword); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$ifndef FPUNONE}
    procedure WriteExtended(e : extended); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$endif}
    procedure FlushBuffer;
    procedure WriteValue(Value: TValueType);
  public
    constructor Create(Stream: TStream; BufSize: Integer);
    destructor Destroy; override;

    procedure BeginCollection; override;
    procedure BeginComponent(Component: TComponent; Flags: TFilerFlags;
      ChildPos: Integer); override;
    procedure BeginList; override;
    procedure EndList; override;
    procedure BeginProperty(const PropName: String); override;
    procedure EndProperty; override;

    //Please don't use write, better use WriteBinary whenever possible
    procedure Write(const Buffer; Count: Longint); override;
    procedure WriteBinary(const Buffer; Count: LongInt); override;
    procedure WriteBoolean(Value: Boolean); override;
{$ifndef FPUNONE}
    procedure WriteFloat(const Value: Extended); override;
    procedure WriteSingle(const Value: Single); override;
    procedure WriteDate(const Value: TDateTime); override;
{$endif}
    procedure WriteCurrency(const Value: Currency); override;
    procedure WriteIdent(const Ident: string); override;
    procedure WriteInteger(Value: Int64); override;
    procedure WriteUInt64(Value: QWord); override;
    procedure WriteMethodName(const Name: String); override;
    procedure WriteSet(Value: LongInt; SetType: Pointer); override;
    procedure WriteStr(const Value: String);
    procedure WriteString(const Value: String); override;
    procedure WriteWideString(const Value: WideString); override;
    procedure WriteUnicodeString(const Value: UnicodeString); override;
    procedure WriteVariant(const VarValue: Variant);override;
  end;

  twriter = class(tfiler)
  private
    FDriver: TAbstractObjectWriter;
    FDestroyDriver: Boolean;
    FRootAncestor: tcomponent;
    FPropPath: String;
    FAncestors: tstringlist;
    FAncestorPos: Integer;
    FCurrentPos: Integer;
    FOnFindAncestor: TFindAncestorEvent;
    FOnWriteMethodProperty: TWriteMethodPropertyEvent;
    FOnWriteStringProperty:TReadWriteStringPropertyEvent;
    procedure AddToAncestorList(Component: tcomponent);
    procedure WriteComponentData(Instance: tcomponent);
    Procedure DetermineAncestor(Component: tcomponent);
    procedure DoFindAncestor(Component : tcomponent);
  protected
    procedure SetRoot(ARoot: tcomponent); override;
    procedure WriteBinary(AWriteData: TStreamProc);
    procedure WriteProperty(Instance: tpersistent; PropInfo: Pointer);
    procedure WriteProperties(Instance: tpersistent);
    procedure WriteChildren(Component: tcomponent);
    function CreateDriver(Stream: TStream; BufSize: Integer): TAbstractObjectWriter; virtual;
  public
    constructor Create(ADriver: TAbstractObjectWriter);
    constructor Create(Stream: TStream; BufSize: Integer);
    destructor Destroy; override;
    procedure DefineProperty(const Name: string;
      ReadData: TReaderProc; AWriteData: TWriterProc;
      HasData: Boolean); override;
    procedure DefineBinaryProperty(const Name: string;
      ReadData, AWriteData: TStreamProc;
      HasData: Boolean); override;
    //Please don't use write, better use WriteBinary whenever possible
    //uuups, WriteBinary is protected ..
    procedure Write(const Buffer; Count: Longint); virtual;
    procedure WriteBoolean(Value: Boolean);
    procedure WriteCollection(Value: TCollection);
    procedure WriteComponent(Component: tcomponent);
    procedure WriteChar(Value: Char);
    procedure WriteWideChar(Value: WideChar);
    procedure WriteDescendent(ARoot: tcomponent; AAncestor: tcomponent);
{$ifndef FPUNONE}
    procedure WriteFloat(const Value: Extended);
    procedure WriteSingle(const Value: Single);
    procedure WriteDate(const Value: TDateTime);
{$endif}
    procedure WriteCurrency(const Value: Currency);
    procedure WriteIdent(const Ident: string);
    procedure WriteInteger(Value: Longint); overload;
    procedure WriteInteger(Value: Int64); overload;
    procedure WriteSet(Value: LongInt; SetType: Pointer);
    procedure WriteListBegin;
    procedure WriteListEnd;
    procedure WriteRootComponent(ARoot: tcomponent);
    procedure WriteString(const Value: string);
    procedure WriteWideString(const Value: WideString);
    procedure WriteUnicodeString(const Value: UnicodeString);
    procedure WriteVariant(const VarValue: Variant);
    property RootAncestor: tcomponent read FRootAncestor write FRootAncestor;
    property OnFindAncestor: TFindAncestorEvent read FOnFindAncestor write FOnFindAncestor;
    property OnWriteMethodProperty: TWriteMethodPropertyEvent read FOnWriteMethodProperty write FOnWriteMethodProperty;
    property OnWriteStringProperty: TReadWriteStringPropertyEvent read FOnWriteStringProperty write FOnWriteStringProperty;

    property Driver: TAbstractObjectWriter read FDriver;
    property PropertyPath: string read FPropPath;
  end;

{ tstrings class }

  tstrings = class(tpersistent)
  private
    FSpecialCharsInited : boolean;
    FQuoteChar : Char;
    FDelimiter : Char;
    FNameValueSeparator : Char;
    FUpdateCount: Integer;
    FAdapter: IStringsAdapter;
    FLBS : TTextLineBreakStyle;
    FStrictDelimiter : Boolean;
    function GetCommaText: string;
    function GetName(Index: Integer): string;
    function GetValue(const Name: string): string;
    Function GetLBS : TTextLineBreakStyle;
    Procedure SetLBS (AValue : TTextLineBreakStyle);
    procedure ReadData(Reader: TReader);
    procedure SetCommaText(const Value: string);
    procedure SetStringsAdapter(const Value: IStringsAdapter);
    procedure SetValue(const Name, Value: string);
    procedure SetDelimiter(c:Char);
    procedure SetQuoteChar(c:Char);
    procedure SetNameValueSeparator(c:Char);
    procedure WriteData(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: tfiler); override;
    procedure Error(const Msg: string; Data: Integer);
    procedure Error(const Msg: pstring; Data: Integer);
    function Get(Index: Integer): string; virtual; abstract;
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual;
    function GetTextStr: string; virtual;
    procedure Put(Index: Integer; const S: string); virtual;
    procedure PutObject(Index: Integer; AObject: TObject); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetTextStr(const Value: string); virtual;
    procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
    Function DoCompareText(const s1,s2 : string) : PtrInt; virtual;
    Function GetDelimitedText: string;
    Procedure SetDelimitedText(Const AValue: string);
    Function GetValueFromIndex(Index: Integer): string;
    Procedure SetValueFromIndex(Index: Integer; const Value: string);
    Procedure CheckSpecialChars;
  public
    destructor Destroy; override;
    function Add(const S: string): Integer; virtual;
    function AddObject(const S: string; AObject: TObject): Integer; virtual;
    procedure Append(const S: string);
    procedure AddStrings(TheStrings: tstrings); overload; virtual;
    procedure AddStrings(const TheStrings: array of string); overload; virtual;
    procedure Assign(Source: tpersistent); override;
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(Obj: TObject): Boolean; override; overload;
    function Equals(TheStrings: tstrings): Boolean; overload;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetEnumerator: TStringsEnumerator;
    function GetText: PChar; virtual;
    function IndexOf(const S: string): Integer; virtual;
    function IndexOfName(const Name: string): Integer; virtual;
    function IndexOfObject(AObject: TObject): Integer; virtual;
    procedure Insert(Index: Integer; const S: string); virtual; abstract;
    procedure InsertObject(Index: Integer; const S: string;
      AObject: TObject);
    procedure LoadFromFile(const FileName: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure SetText(TheText: PChar); virtual;
    procedure GetNameValue(Index : Integer; Out AName,AValue : String);
    function  ExtractName(Const S:String):String;
    Property TextLineBreakStyle : TTextLineBreakStyle Read GetLBS Write SetLBS;
    property Delimiter: Char read FDelimiter write SetDelimiter;
    property DelimitedText: string read GetDelimitedText write SetDelimitedText;
    Property StrictDelimiter : Boolean Read FStrictDelimiter Write FStrictDelimiter;
    property QuoteChar: Char read FQuoteChar write SetQuoteChar;
    Property NameValueSeparator : Char Read FNameValueSeparator Write SetNameValueSeparator;
    property ValueFromIndex[Index: Integer]: string read GetValueFromIndex write SetValueFromIndex;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: string read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property Names[Index: Integer]: string read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property Values[const Name: string]: string read GetValue write SetValue;
    property Strings[Index: Integer]: string read Get write Put; default;
    property Text: string read GetTextStr write SetTextStr;
    property StringsAdapter: IStringsAdapter read FAdapter write SetStringsAdapter;
  end;

  TStringListSortCompare = function(List: tstringlist; Index1, Index2: Integer): Integer;

  tstringlist = class(tstrings)
  private
    FList: PStringItemList;
    FCount: Integer;
    FCapacity: Integer;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FDuplicates: TDuplicates;
    FCaseSensitive : Boolean;
    FSorted: Boolean;
    FOwnsObjects : Boolean;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Grow;
    procedure InternalClear;
    procedure QuickSort(L, R: Integer; CompareFn: TStringListSortCompare);
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(b : boolean);
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    function Get(Index: Integer): string; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure InsertItem(Index: Integer; const S: string); virtual;
    procedure InsertItem(Index: Integer; const S: string; O: TObject); virtual;
    Function DoCompareText(const s1,s2 : string) : PtrInt; override;

  public
    destructor Destroy; override;
    function Add(const S: string): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: string; Out Index: Integer): Boolean; virtual;
    function IndexOf(const S: string): Integer; override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Sort; virtual;
    procedure CustomSort(CompareFn: TStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OwnsObjects : boolean read FOwnsObjects write FOwnsObjects;
  end;

  TStream = class(TObject)
  private
  protected
    procedure InvalidSeek; virtual;
    procedure Discard(const Count: Int64);
    procedure DiscardLarge(Count: int64; const MaxBufferSize: Longint);
    procedure FakeSeekForward(Offset: Int64; const Origin: TSeekOrigin; const Pos: Int64);
    function  GetPosition: Int64; virtual;
    procedure SetPosition(const Pos: Int64); virtual;
    function  GetSize: Int64; virtual;
    procedure SetSize64(const NewSize: Int64); virtual;
    procedure SetSize(NewSize: Longint); virtual;overload;
    procedure SetSize(const NewSize: Int64); virtual;overload;
    procedure ReadNotImplemented;
    procedure WriteNotImplemented;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual;
    function Write(const Buffer; Count: Longint): Longint; virtual;
    function Seek(Offset: Longint; Origin: Word): Longint; virtual; overload;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual; overload;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    function CopyFrom(Source: TStream; Count: Int64): Int64;
    function ReadComponent(Instance: TComponent): TComponent;
    function ReadComponentRes(Instance: TComponent): TComponent;
    procedure WriteComponent(Instance: TComponent);
    procedure WriteComponentRes(const ResName: string; Instance: TComponent);
    procedure WriteDescendent(Instance, Ancestor: TComponent);
    procedure WriteDescendentRes(const ResName: string; Instance, Ancestor: TComponent);
    procedure WriteResourceHeader(const ResName: string; {!!!:out} var FixupInfo: Integer);
    procedure FixupResourceHeader(FixupInfo: Integer);
    procedure ReadResHeader;
    function ReadByte : Byte;
    function ReadWord : Word;
    function ReadDWord : Cardinal;
    function ReadQWord : QWord;
    function ReadAnsiString : String;
    procedure WriteByte(b : Byte);
    procedure WriteWord(w : Word);
    procedure WriteDWord(d : Cardinal);
    procedure WriteQWord(q : QWord);
    Procedure WriteAnsiString (const S : String);
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize write SetSize64;
  end;

  THandleStream = class(TStream)
  private
    FHandle: THandle;
  protected
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(AHandle: THandle);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Handle: THandle read FHandle;
  end;

  TFileStream = class(THandleStream)
  Private
    FFileName : String;
  public
    constructor Create(const AFileName: string; Mode: Word);
    constructor Create(const AFileName: string; Mode: Word; Rights: Cardinal);
    destructor Destroy; override;
    property FileName : String Read FFilename;
  end;

  TCustomMemoryStream = class(TStream)
  private
    FMemory: Pointer;
    FSize, FPosition: PtrInt;
  protected
    Function GetSize : Int64; Override;
    function GetPosition: Int64; Override;
    procedure SetPointer(Ptr: Pointer; ASize: PtrInt);
  public
    function Read(var Buffer; Count: LongInt): LongInt; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Memory: Pointer read FMemory;
  end;

  TMemoryStream = class(TCustomMemoryStream)
  private
    FCapacity: PtrInt;
    procedure SetCapacity(NewCapacity: PtrInt);
  protected
    function Realloc(var NewCapacity: PtrInt): Pointer; virtual;
    property Capacity: PtrInt read FCapacity write SetCapacity;
  public
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SetSize({$ifdef CPU64}const{$endif CPU64} NewSize: PtrInt); override;
    function Write(const Buffer; Count: LongInt): LongInt; override;
  end;

  TStringStream = class(TStream)
  private
    FDataString: string;
    FPosition: Integer;
  protected
    Function GetSize : Int64; Override;
    function GetPosition: Int64; Override;
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const AString: string);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadString(Count: Longint): string;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteString(const AString: string);
    property DataString: string read FDataString;
  end;

  TOwnerStream = Class(TStream)
  private
  Protected
    FOwner : Boolean;
    FSource : TStream;
  Public
    Constructor Create(ASource : TStream);
    Destructor Destroy; override;
    Property Source : TStream Read FSource;
    Property SourceOwner : Boolean Read Fowner Write FOwner;
  end;

  TFindGlobalComponent = function(const Name: string): TComponent;
  TInitComponentHandler = function(Instance: TComponent; RootAncestor : TClass): boolean;

procedure RegisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
procedure UnregisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
function FindGlobalComponent(const Name: string): TComponent;

function InitInheritedComponent(Instance: TComponent; RootAncestor: TClass): Boolean;
function InitComponentRes(const ResName: string; Instance: TComponent): Boolean;
function ReadComponentRes(const ResName: string; Instance: TComponent): TComponent;
function ReadComponentResEx(HInstance: THandle; const ResName: string): TComponent;
function ReadComponentResFile(const FileName: string; Instance: TComponent): TComponent;
procedure WriteComponentResFile(const FileName: string; Instance: TComponent);
procedure RegisterInitComponentHandler(ComponentClass: TComponentClass;   Handler: TInitComponentHandler);

procedure GlobalFixupReferences;
procedure GetFixupReferenceNames(Root: TComponent; Names: TStrings);
procedure GetFixupInstanceNames(Root: TComponent;
  const ReferenceRootName: string; Names: TStrings);
procedure RedirectFixupReferences(Root: TComponent; const OldRootName,
  NewRootName: string);
procedure RemoveFixupReferences(Root: TComponent; const RootName: string);
procedure RemoveFixups(Instance: TPersistent);
Function FindNestedComponent(Root : TComponent; APath : String; CStyle : Boolean = True) : TComponent;

procedure BeginGlobalLoading;
procedure NotifyGlobalLoading;
procedure EndGlobalLoading;

procedure RegisterClass(AClass: TPersistentClass);
procedure RegisterClasses(AClasses: array of TPersistentClass);
procedure RegisterClassAlias(AClass: TPersistentClass; const Alias: string);
procedure UnRegisterClass(AClass: TPersistentClass);
procedure UnRegisterClasses(AClasses: array of TPersistentClass);
procedure UnRegisterModuleClasses(Module: HMODULE);
function FindClass(const AClassName: string): TPersistentClass;
function GetClass(const AClassName: string): TPersistentClass;

function ExtractStrings(Separators, WhiteSpace: TSysCharSet; Content: PChar; Strings: TStrings): Integer;

implementation

{ tpersistent }

procedure tpersistent.AssignError(Source: tpersistent);
begin
end;

procedure tpersistent.AssignTo(Dest: tpersistent);
begin
end;

procedure tpersistent.DefineProperties(Filer: tfiler);
begin
end;

function tpersistent.GetOwner: tpersistent;
begin
end;

destructor tpersistent.Destroy;
begin
end;

procedure tpersistent.Assign(Source: tpersistent);
begin
end;

function tpersistent.GetNamePath: string;
begin
end;

{ tcomponent }

function tcomponent.GetComObject: IUnknown;
begin
end;

function tcomponent.GetComponent(AIndex: Integer): tcomponent;
begin
end;

function tcomponent.GetComponentCount: Integer;
begin
end;

function tcomponent.GetComponentIndex: Integer;
begin
end;

procedure tcomponent.Insert(AComponent: tcomponent);
begin
end;

procedure tcomponent.ReadLeft(Reader: treader);
begin
end;

procedure tcomponent.ReadTop(Reader: treader);
begin
end;

procedure tcomponent.Remove(AComponent: tcomponent);
begin
end;

procedure tcomponent.RemoveNotification(AComponent: tcomponent);
begin
end;

procedure tcomponent.SetComponentIndex(Value: Integer);
begin
end;

procedure tcomponent.SetReference(Enable: Boolean);
begin
end;

procedure tcomponent.WriteLeft(Writer: twriter);
begin
end;

procedure tcomponent.WriteTop(Writer: twriter);
begin
end;

procedure tcomponent.ChangeName(const NewName: TComponentName);
begin
end;

procedure tcomponent.DefineProperties(Filer: tfiler);
begin
end;

procedure tcomponent.GetChildren(Proc: TGetChildProc; Root: tcomponent);
begin
end;

function tcomponent.GetChildOwner: tcomponent;
begin
end;

function tcomponent.GetChildParent: tcomponent;
begin
end;

function tcomponent.GetOwner: tpersistent;
begin
end;

procedure tcomponent.Loaded;
begin
end;

procedure tcomponent.Loading;
begin
end;

procedure tcomponent.Notification(AComponent: tcomponent;
               Operation: TOperation);
begin
end;

procedure tcomponent.PaletteCreated;
begin
end;

procedure tcomponent.ReadState(Reader: treader);
begin
end;

procedure tcomponent.SetAncestor(Value: Boolean);
begin
end;

procedure tcomponent.SetDesigning(Value: Boolean; SetChildren: Boolean = True);
begin
end;

procedure tcomponent.SetDesignInstance(Value: Boolean);
begin
end;

procedure tcomponent.SetInline(Value: Boolean);
begin
end;

procedure tcomponent.SetName(const NewName: TComponentName);
begin
end;

procedure tcomponent.SetChildOrder(Child: tcomponent; Order: Integer);
begin
end;

procedure tcomponent.SetParentComponent(Value: tcomponent);
begin
end;

procedure tcomponent.Updating;
begin
end;

procedure tcomponent.Updated;
begin
end;

class procedure tcomponent.UpdateRegistry(Register: Boolean;
               const ClassID: string; const ProgID: string);
begin
end;

procedure tcomponent.ValidateRename(AComponent: tcomponent;
               const CurName: string; const NewName: string);
begin
end;

procedure tcomponent.ValidateContainer(AComponent: tcomponent);
begin
end;

procedure tcomponent.ValidateInsert(AComponent: tcomponent);
begin
end;

function tcomponent.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID: TGUID; out Obj): Hresult;
{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
end;

function tcomponent._AddRef: Integer;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
end;

function tcomponent._Release: Integer;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
end;

function tcomponent.iicrGetComponent: tcomponent;
begin
end;

function tcomponent.GetTypeInfoCount(out Count: Integer): HResult; stdcall;
begin
end;

function tcomponent.GetTypeInfo(Index: Integer; LocaleID: Integer;
               out TypeInfo): HResult; stdcall;
begin
end;

function tcomponent.GetIDsOfNames(const IID: TGUID; Names: Pointer;
               NameCount: Integer; LocaleID: Integer;
               DispIDs: Pointer): HResult; stdcall;
begin
end;

function tcomponent.Invoke(DispID: Integer; const IID: TGUID;
               LocaleID: Integer; Flags: Word; var Params; VarResult: Pointer;
               ExcepInfo: Pointer; ArgErr: Pointer): HResult; stdcall;
begin
end;

procedure tcomponent.WriteState(Writer: twriter);
begin
end;

constructor tcomponent.Create(AOwner: tcomponent);
begin
end;

destructor tcomponent.Destroy;
begin
end;

procedure tcomponent.BeforeDestruction;
begin
end;

procedure tcomponent.DestroyComponents;
begin
end;

procedure tcomponent.Destroying;
begin
end;

function tcomponent.ExecuteAction(Action: TBasicAction): Boolean;
begin
end;

function tcomponent.FindComponent(const AName: string): tcomponent;
begin
end;

procedure tcomponent.FreeNotification(AComponent: tcomponent);
begin
end;

procedure tcomponent.RemoveFreeNotification(AComponent: tcomponent);
begin
end;

procedure tcomponent.FreeOnRelease;
begin
end;

function tcomponent.GetEnumerator: TComponentEnumerator;
begin
end;

function tcomponent.GetNamePath: string;
begin
end;

function tcomponent.GetParentComponent: tcomponent;
begin
end;

function tcomponent.HasParent: Boolean;
begin
end;

procedure tcomponent.InsertComponent(AComponent: tcomponent);
begin
end;

procedure tcomponent.RemoveComponent(AComponent: tcomponent);
begin
end;

function tcomponent.SafeCallException(ExceptObject: TObject;
               ExceptAddr: Pointer): HResult;
begin
end;

procedure tcomponent.SetSubComponent(ASubComponent: Boolean);
begin
end;

function tcomponent.UpdateAction(Action: TBasicAction): Boolean;
begin
end;

function tcomponent.IsImplementorOf(const Intf: IInterface): boolean;
begin
end;

procedure tcomponent.ReferenceInterface(const intf: IInterface;
               op: TOperation);
begin
end;

{ tfiler }

procedure tfiler.SetRoot(ARoot: tcomponent);
begin
end;

{ treader }

procedure treader.DoFixupReferences;
begin
end;

function treader.FindComponentClass(const AClassName: string): TComponentClass;
begin
end;

function treader.Error(const Message: string): Boolean;
begin
end;

function treader.FindMethod(ARoot: tcomponent;
               const AMethodName: string): Pointer;
begin
end;

procedure treader.ReadProperty(AInstance: tpersistent);
begin
end;

procedure treader.ReadPropValue(Instance: tpersistent; PropInfo: Pointer);
begin
end;

procedure treader.PropertyError;
begin
end;

procedure treader.ReadData(Instance: tcomponent);
begin
end;

function treader.CreateDriver(Stream: TStream;
               BufSize: Integer): TAbstractObjectReader;
begin
end;

constructor treader.Create(Stream: TStream; BufSize: Integer);
begin
end;

destructor treader.Destroy;
begin
end;

procedure treader.BeginReferences;
begin
end;

procedure treader.CheckValue(Value: TValueType);
begin
end;

procedure treader.DefineProperty(const Name: string; AReadData: TReaderProc;
               WriteData: TWriterProc; HasData: Boolean);
begin
end;

procedure treader.DefineBinaryProperty(const Name: string;
               AReadData: TStreamProc; WriteData: TStreamProc;
               HasData: Boolean);
begin
end;

function treader.EndOfList: Boolean;
begin
end;

procedure treader.EndReferences;
begin
end;

procedure treader.FixupReferences;
begin
end;

function treader.NextValue: TValueType;
begin
end;

procedure treader.Read(var Buf; Count: LongInt);
begin
end;

function treader.ReadBoolean: Boolean;
begin
end;

function treader.ReadChar: Char;
begin
end;

function treader.ReadWideChar: WideChar;
begin
end;

function treader.ReadUnicodeChar: UnicodeChar;
begin
end;

procedure treader.ReadCollection(Collection: TCollection);
begin
end;

function treader.ReadComponent(Component: tcomponent): tcomponent;
begin
end;

procedure treader.ReadComponents(AOwner: tcomponent; AParent: tcomponent;
               Proc: TReadComponentsProc);
begin
end;

function treader.ReadFloat: Extended;
begin
end;

function treader.ReadSingle: Single;
begin
end;

function treader.ReadDate: TDateTime;
begin
end;

function treader.ReadCurrency: Currency;
begin
end;

function treader.ReadIdent: string;
begin
end;

function treader.ReadInteger: Longint;
begin
end;

function treader.ReadInt64: Int64;
begin
end;

function treader.ReadSet(EnumType: Pointer): Integer;
begin
end;

procedure treader.ReadListBegin;
begin
end;

procedure treader.ReadListEnd;
begin
end;

function treader.ReadRootComponent(ARoot: tcomponent): tcomponent;
begin
end;

function treader.ReadVariant: Variant;
begin
end;

function treader.ReadString: string;
begin
end;

function treader.ReadWideString: WideString;
begin
end;

function treader.ReadUnicodeString: UnicodeString;
begin
end;

function treader.ReadValue: TValueType;
begin
end;

procedure treader.CopyValue(Writer: twriter);
begin
end;

{ twriter }

procedure twriter.AddToAncestorList(Component: tcomponent);
begin
end;

procedure twriter.WriteComponentData(Instance: tcomponent);
begin
end;

procedure twriter.DetermineAncestor(Component: tcomponent);
begin
end;

procedure twriter.DoFindAncestor(Component: tcomponent);
begin
end;

procedure twriter.SetRoot(ARoot: tcomponent);
begin
end;

procedure twriter.WriteBinary(AWriteData: TStreamProc);
begin
end;

procedure twriter.WriteProperty(Instance: tpersistent; PropInfo: Pointer);
begin
end;

procedure twriter.WriteProperties(Instance: tpersistent);
begin
end;

procedure twriter.WriteChildren(Component: tcomponent);
begin
end;

function twriter.CreateDriver(Stream: TStream;
               BufSize: Integer): TAbstractObjectWriter;
begin
end;

constructor twriter.Create(ADriver: TAbstractObjectWriter);
begin
end;

constructor twriter.Create(Stream: TStream; BufSize: Integer);
begin
end;

destructor twriter.Destroy;
begin
end;

procedure twriter.DefineProperty(const Name: string; ReadData: TReaderProc;
               AWriteData: TWriterProc; HasData: Boolean);
begin
end;

procedure twriter.DefineBinaryProperty(const Name: string;
               ReadData: TStreamProc; AWriteData: TStreamProc;
               HasData: Boolean);
begin
end;

procedure twriter.Write(const Buffer; Count: Longint);
begin
end;

procedure twriter.WriteBoolean(Value: Boolean);
begin
end;

procedure twriter.WriteCollection(Value: TCollection);
begin
end;

procedure twriter.WriteComponent(Component: tcomponent);
begin
end;

procedure twriter.WriteChar(Value: Char);
begin
end;

procedure twriter.WriteWideChar(Value: WideChar);
begin
end;

procedure twriter.WriteDescendent(ARoot: tcomponent; AAncestor: tcomponent);
begin
end;

procedure twriter.WriteFloat(const Value: Extended);
begin
end;

procedure twriter.WriteSingle(const Value: Single);
begin
end;

procedure twriter.WriteDate(const Value: TDateTime);
begin
end;

procedure twriter.WriteCurrency(const Value: Currency);
begin
end;

procedure twriter.WriteIdent(const Ident: string);
begin
end;

procedure twriter.WriteInteger(Value: Longint);
begin
end;

procedure twriter.WriteInteger(Value: Int64);
begin
end;

procedure twriter.WriteSet(Value: LongInt; SetType: Pointer);
begin
end;

procedure twriter.WriteListBegin;
begin
end;

procedure twriter.WriteListEnd;
begin
end;

procedure twriter.WriteRootComponent(ARoot: tcomponent);
begin
end;

procedure twriter.WriteString(const Value: string);
begin
end;

procedure twriter.WriteWideString(const Value: WideString);
begin
end;

procedure twriter.WriteUnicodeString(const Value: UnicodeString);
begin
end;

procedure twriter.WriteVariant(const VarValue: Variant);
begin
end;

{ tstrings }

function tstrings.GetCommaText: string;
begin
end;

function tstrings.GetName(Index: Integer): string;
begin
end;

function tstrings.GetValue(const Name: string): string;
begin
end;

function tstrings.GetLBS: TTextLineBreakStyle;
begin
end;

procedure tstrings.SetLBS(AValue: TTextLineBreakStyle);
begin
end;

procedure tstrings.ReadData(Reader: TReader);
begin
end;

procedure tstrings.SetCommaText(const Value: string);
begin
end;

procedure tstrings.SetStringsAdapter(const Value: IStringsAdapter);
begin
end;

procedure tstrings.SetValue(const Name: string; const Value: string);
begin
end;

procedure tstrings.SetDelimiter(c: Char);
begin
end;

procedure tstrings.SetQuoteChar(c: Char);
begin
end;

procedure tstrings.SetNameValueSeparator(c: Char);
begin
end;

procedure tstrings.WriteData(Writer: TWriter);
begin
end;

procedure tstrings.DefineProperties(Filer: tfiler);
begin
end;

procedure tstrings.Error(const Msg: string; Data: Integer);
begin
end;

procedure tstrings.Error(const Msg: pstring; Data: Integer);
begin
end;

function tstrings.GetCapacity: Integer;
begin
end;

function tstrings.GetObject(Index: Integer): TObject;
begin
end;

function tstrings.GetTextStr: string;
begin
end;

procedure tstrings.Put(Index: Integer; const S: string);
begin
end;

procedure tstrings.PutObject(Index: Integer; AObject: TObject);
begin
end;

procedure tstrings.SetCapacity(NewCapacity: Integer);
begin
end;

procedure tstrings.SetTextStr(const Value: string);
begin
end;

procedure tstrings.SetUpdateState(Updating: Boolean);
begin
end;

function tstrings.DoCompareText(const s1: string; const s2: string): PtrInt;
begin
end;

function tstrings.GetDelimitedText: string;
begin
end;

procedure tstrings.SetDelimitedText(const AValue: string);
begin
end;

function tstrings.GetValueFromIndex(Index: Integer): string;
begin
end;

procedure tstrings.SetValueFromIndex(Index: Integer; const Value: string);
begin
end;

procedure tstrings.CheckSpecialChars;
begin
end;

destructor tstrings.Destroy;
begin
end;

function tstrings.Add(const S: string): Integer;
begin
end;

function tstrings.AddObject(const S: string; AObject: TObject): Integer;
begin
end;

procedure tstrings.Append(const S: string);
begin
end;

procedure tstrings.AddStrings(TheStrings: tstrings);
begin
end;

procedure tstrings.AddStrings(const TheStrings: array of string);
begin
end;

procedure tstrings.Assign(Source: tpersistent);
begin
end;

procedure tstrings.BeginUpdate;
begin
end;

procedure tstrings.EndUpdate;
begin
end;

function tstrings.Equals(Obj: TObject): Boolean;
begin
end;

function tstrings.Equals(TheStrings: tstrings): Boolean;
begin
end;

procedure tstrings.Exchange(Index1: Integer; Index2: Integer);
begin
end;

function tstrings.GetEnumerator: TStringsEnumerator;
begin
end;

function tstrings.GetText: PChar;
begin
end;

function tstrings.IndexOf(const S: string): Integer;
begin
end;

function tstrings.IndexOfName(const Name: string): Integer;
begin
end;

function tstrings.IndexOfObject(AObject: TObject): Integer;
begin
end;

procedure tstrings.InsertObject(Index: Integer; const S: string;
               AObject: TObject);
begin
end;

procedure tstrings.LoadFromFile(const FileName: string);
begin
end;

procedure tstrings.LoadFromStream(Stream: TStream);
begin
end;

procedure tstrings.Move(CurIndex: Integer; NewIndex: Integer);
begin
end;

procedure tstrings.SaveToFile(const FileName: string);
begin
end;

procedure tstrings.SaveToStream(Stream: TStream);
begin
end;

procedure tstrings.SetText(TheText: PChar);
begin
end;

procedure tstrings.GetNameValue(Index: Integer; out AName: String;
               out AValue: String);
begin
end;

function tstrings.ExtractName(const S: String): String;
begin
end;

{ tstringlist }

procedure tstringlist.ExchangeItems(Index1: Integer; Index2: Integer);
begin
end;

procedure tstringlist.Grow;
begin
end;

procedure tstringlist.InternalClear;
begin
end;

procedure tstringlist.QuickSort(L: Integer; R: Integer;
               CompareFn: TStringListSortCompare);
begin
end;

procedure tstringlist.SetSorted(Value: Boolean);
begin
end;

procedure tstringlist.SetCaseSensitive(b: boolean);
begin
end;

procedure tstringlist.Changed;
begin
end;

procedure tstringlist.Changing;
begin
end;

function tstringlist.Get(Index: Integer): string;
begin
end;

function tstringlist.GetCapacity: Integer;
begin
end;

function tstringlist.GetCount: Integer;
begin
end;

function tstringlist.GetObject(Index: Integer): TObject;
begin
end;

procedure tstringlist.Put(Index: Integer; const S: string);
begin
end;

procedure tstringlist.PutObject(Index: Integer; AObject: TObject);
begin
end;

procedure tstringlist.SetCapacity(NewCapacity: Integer);
begin
end;

procedure tstringlist.SetUpdateState(Updating: Boolean);
begin
end;

procedure tstringlist.InsertItem(Index: Integer; const S: string);
begin
end;

procedure tstringlist.InsertItem(Index: Integer; const S: string; O: TObject);
begin
end;

function tstringlist.DoCompareText(const s1: string; const s2: string): PtrInt;
begin
end;

destructor tstringlist.Destroy;
begin
end;

function tstringlist.Add(const S: string): Integer;
begin
end;

procedure tstringlist.Clear;
begin
end;

procedure tstringlist.Delete(Index: Integer);
begin
end;

procedure tstringlist.Exchange(Index1: Integer; Index2: Integer);
begin
end;

function tstringlist.Find(const S: string; out Index: Integer): Boolean;
begin
end;

function tstringlist.IndexOf(const S: string): Integer;
begin
end;

procedure tstringlist.Insert(Index: Integer; const S: string);
begin
end;

procedure tstringlist.Sort;
begin
end;

procedure tstringlist.CustomSort(CompareFn: TStringListSortCompare);
begin
end;

{ TStream }

procedure TStream.InvalidSeek;
begin
end;

procedure TStream.Discard(const Count: Int64);
begin
end;

procedure TStream.DiscardLarge(Count: int64; const MaxBufferSize: Longint);
begin
end;

procedure TStream.FakeSeekForward(Offset: Int64; const Origin: TSeekOrigin;
               const Pos: Int64);
begin
end;

function TStream.GetPosition: Int64;
begin
end;

procedure TStream.SetPosition(const Pos: Int64);
begin
end;

function TStream.GetSize: Int64;
begin
end;

procedure TStream.SetSize64(const NewSize: Int64);
begin
end;

procedure TStream.SetSize(NewSize: Longint);
begin
end;

procedure TStream.SetSize(const NewSize: Int64);
begin
end;

procedure TStream.ReadNotImplemented;
begin
end;

procedure TStream.WriteNotImplemented;
begin
end;

function TStream.Read(var Buffer; Count: Longint): Longint;
begin
end;

function TStream.Write(const Buffer; Count: Longint): Longint;
begin
end;

function TStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
end;

function TStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
end;

procedure TStream.ReadBuffer(var Buffer; Count: Longint);
begin
end;

procedure TStream.WriteBuffer(const Buffer; Count: Longint);
begin
end;

function TStream.CopyFrom(Source: TStream; Count: Int64): Int64;
begin
end;

function TStream.ReadComponent(Instance: TComponent): TComponent;
begin
end;

function TStream.ReadComponentRes(Instance: TComponent): TComponent;
begin
end;

procedure TStream.WriteComponent(Instance: TComponent);
begin
end;

procedure TStream.WriteComponentRes(const ResName: string;
               Instance: TComponent);
begin
end;

procedure TStream.WriteDescendent(Instance: TComponent; Ancestor: TComponent);
begin
end;

procedure TStream.WriteDescendentRes(const ResName: string;
               Instance: TComponent; Ancestor: TComponent);
begin
end;

procedure TStream.WriteResourceHeader(const ResName: string;
               var FixupInfo: Integer);
begin
end;

procedure TStream.FixupResourceHeader(FixupInfo: Integer);
begin
end;

procedure TStream.ReadResHeader;
begin
end;

function TStream.ReadByte: Byte;
begin
end;

function TStream.ReadWord: Word;
begin
end;

function TStream.ReadDWord: Cardinal;
begin
end;

function TStream.ReadQWord: QWord;
begin
end;

function TStream.ReadAnsiString: String;
begin
end;

procedure TStream.WriteByte(b: Byte);
begin
end;

procedure TStream.WriteWord(w: Word);
begin
end;

procedure TStream.WriteDWord(d: Cardinal);
begin
end;

procedure TStream.WriteQWord(q: QWord);
begin
end;

procedure TStream.WriteAnsiString(const S: String);
begin
end;

{ TCustomMemoryStream }

function TCustomMemoryStream.GetSize: Int64;
begin
end;

function TCustomMemoryStream.GetPosition: Int64;
begin
end;

procedure TCustomMemoryStream.SetPointer(Ptr: Pointer; ASize: PtrInt);
begin
end;

function TCustomMemoryStream.Read(var Buffer; Count: LongInt): LongInt;
begin
end;

function TCustomMemoryStream.Seek(const Offset: Int64;
               Origin: TSeekOrigin): Int64;
begin
end;

procedure TCustomMemoryStream.SaveToStream(Stream: TStream);
begin
end;

procedure TCustomMemoryStream.SaveToFile(const FileName: string);
begin
end;

{ TMemoryStream }

procedure TMemoryStream.SetCapacity(NewCapacity: PtrInt);
begin
end;

function TMemoryStream.Realloc(var NewCapacity: PtrInt): Pointer;
begin
end;

destructor TMemoryStream.Destroy;
begin
end;

procedure TMemoryStream.Clear;
begin
end;

procedure TMemoryStream.LoadFromStream(Stream: TStream);
begin
end;

procedure TMemoryStream.LoadFromFile(const FileName: string);
begin
end;

procedure TMemoryStream.SetSize(NewSize: PtrInt);
begin
end;

function TMemoryStream.Write(const Buffer; Count: LongInt): LongInt;
begin
end;

{ TBinaryObjectReader }

function TBinaryObjectReader.ReadWord: word;
begin
end;

function TBinaryObjectReader.ReadDWord: longword;
begin
end;

function TBinaryObjectReader.ReadQWord: qword;
begin
end;

function TBinaryObjectReader.ReadExtended: extended;
begin
end;

procedure TBinaryObjectReader.SkipProperty;
begin
end;

procedure TBinaryObjectReader.SkipSetBody;
begin
end;

constructor TBinaryObjectReader.Create(Stream: TStream; BufSize: Integer);
begin
end;

destructor TBinaryObjectReader.Destroy;
begin
end;

function TBinaryObjectReader.NextValue: TValueType;
begin
end;

function TBinaryObjectReader.ReadValue: TValueType;
begin
end;

procedure TBinaryObjectReader.BeginRootComponent;
begin
end;

procedure TBinaryObjectReader.BeginComponent(var Flags: TFilerFlags;
               var AChildPos: Integer; var CompClassName: String;
               var CompName: String);
begin
end;

function TBinaryObjectReader.BeginProperty: String;
begin
end;

procedure TBinaryObjectReader.Read(var Buf; Count: LongInt);
begin
end;

procedure TBinaryObjectReader.ReadBinary(const DestData: TMemoryStream);
begin
end;

function TBinaryObjectReader.ReadFloat: Extended;
begin
end;

function TBinaryObjectReader.ReadSingle: Single;
begin
end;

function TBinaryObjectReader.ReadDate: TDateTime;
begin
end;

function TBinaryObjectReader.ReadCurrency: Currency;
begin
end;

function TBinaryObjectReader.ReadIdent(ValueType: TValueType): String;
begin
end;

function TBinaryObjectReader.ReadInt8: ShortInt;
begin
end;

function TBinaryObjectReader.ReadInt16: SmallInt;
begin
end;

function TBinaryObjectReader.ReadInt32: LongInt;
begin
end;

function TBinaryObjectReader.ReadInt64: Int64;
begin
end;

function TBinaryObjectReader.ReadSet(EnumType: Pointer): Integer;
begin
end;

function TBinaryObjectReader.ReadStr: String;
begin
end;

function TBinaryObjectReader.ReadString(StringType: TValueType): String;
begin
end;

function TBinaryObjectReader.ReadWideString: WideString;
begin
end;

function TBinaryObjectReader.ReadUnicodeString: UnicodeString;
begin
end;

procedure TBinaryObjectReader.SkipComponent(SkipComponentInfos: Boolean);
begin
end;

procedure TBinaryObjectReader.SkipValue;
begin
end;


procedure RegisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
begin
end;

procedure UnregisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
begin
end;

function FindGlobalComponent(const Name: string): TComponent;
begin
end;


function InitInheritedComponent(Instance: TComponent; RootAncestor: TClass): Boolean;
begin
end;

function InitComponentRes(const ResName: string; Instance: TComponent): Boolean;
begin
end;

function ReadComponentRes(const ResName: string; Instance: TComponent): TComponent;
begin
end;

function ReadComponentResEx(HInstance: THandle; const ResName: string): TComponent;
begin
end;

function ReadComponentResFile(const FileName: string; Instance: TComponent): TComponent;
begin
end;

procedure WriteComponentResFile(const FileName: string; Instance: TComponent);
begin
end;

procedure RegisterInitComponentHandler(ComponentClass: TComponentClass;   Handler: TInitComponentHandler);
begin
end;


procedure GlobalFixupReferences;
begin
end;

procedure GetFixupReferenceNames(Root: TComponent; Names: TStrings);
begin
end;

procedure GetFixupInstanceNames(Root: TComponent;
  const ReferenceRootName: string; Names: TStrings);
begin
end;

procedure RedirectFixupReferences(Root: TComponent; const OldRootName,
  NewRootName: string);
begin
end;

procedure RemoveFixupReferences(Root: TComponent; const RootName: string);
begin
end;

procedure RemoveFixups(Instance: TPersistent);
begin
end;

Function FindNestedComponent(Root : TComponent; APath : String; CStyle : Boolean = True) : TComponent;
begin
end;


procedure BeginGlobalLoading;
begin
end;

procedure NotifyGlobalLoading;
begin
end;


procedure EndGlobalLoading;
begin
end;

{ TBinaryObjectWriter }

procedure TBinaryObjectWriter.WriteWord(w: word);
begin
end;

procedure TBinaryObjectWriter.WriteDWord(lw: longword);
begin
end;

procedure TBinaryObjectWriter.WriteQWord(qw: qword);
begin
end;

procedure TBinaryObjectWriter.WriteExtended(e: extended);
begin
end;

procedure TBinaryObjectWriter.FlushBuffer;
begin
end;

procedure TBinaryObjectWriter.WriteValue(Value: TValueType);
begin
end;

constructor TBinaryObjectWriter.Create(Stream: TStream; BufSize: Integer);
begin
end;

destructor TBinaryObjectWriter.Destroy;
begin
end;

procedure TBinaryObjectWriter.BeginCollection;
begin
end;

procedure TBinaryObjectWriter.BeginComponent(Component: TComponent;
               Flags: TFilerFlags; ChildPos: Integer);
begin
end;

procedure TBinaryObjectWriter.BeginList;
begin
end;

procedure TBinaryObjectWriter.EndList;
begin
end;

procedure TBinaryObjectWriter.BeginProperty(const PropName: String);
begin
end;

procedure TBinaryObjectWriter.EndProperty;
begin
end;

procedure TBinaryObjectWriter.Write(const Buffer; Count: Longint);
begin
end;

procedure TBinaryObjectWriter.WriteBinary(const Buffer; Count: LongInt);
begin
end;

procedure TBinaryObjectWriter.WriteBoolean(Value: Boolean);
begin
end;

procedure TBinaryObjectWriter.WriteFloat(const Value: Extended);
begin
end;

procedure TBinaryObjectWriter.WriteSingle(const Value: Single);
begin
end;

procedure TBinaryObjectWriter.WriteDate(const Value: TDateTime);
begin
end;

procedure TBinaryObjectWriter.WriteCurrency(const Value: Currency);
begin
end;

procedure TBinaryObjectWriter.WriteIdent(const Ident: string);
begin
end;

procedure TBinaryObjectWriter.WriteInteger(Value: Int64);
begin
end;

procedure TBinaryObjectWriter.WriteUInt64(Value: QWord);
begin
end;

procedure TBinaryObjectWriter.WriteMethodName(const Name: String);
begin
end;

procedure TBinaryObjectWriter.WriteSet(Value: LongInt; SetType: Pointer);
begin
end;

procedure TBinaryObjectWriter.WriteStr(const Value: String);
begin
end;

procedure TBinaryObjectWriter.WriteString(const Value: String);
begin
end;

procedure TBinaryObjectWriter.WriteWideString(const Value: WideString);
begin
end;

procedure TBinaryObjectWriter.WriteUnicodeString(const Value: UnicodeString);
begin
end;

procedure TBinaryObjectWriter.WriteVariant(const VarValue: Variant);
begin
end;


procedure RegisterClass(AClass: TPersistentClass);
begin
end;

procedure RegisterClasses(AClasses: array of TPersistentClass);
begin
end;

procedure RegisterClassAlias(AClass: TPersistentClass; const Alias: string);
begin
end;

procedure UnRegisterClass(AClass: TPersistentClass);
begin
end;

procedure UnRegisterClasses(AClasses: array of TPersistentClass);
begin
end;

procedure UnRegisterModuleClasses(Module: HMODULE);
begin
end;

function FindClass(const AClassName: string): TPersistentClass;
begin
end;

function GetClass(const AClassName: string): TPersistentClass;
begin
end;

{ TFileStream }

constructor TFileStream.Create(const AFileName: string; Mode: Word);
begin
end;

constructor TFileStream.Create(const AFileName: string; Mode: Word;
               Rights: Cardinal);
begin
end;

destructor TFileStream.Destroy;
begin
end;

{ THandleStream }

procedure THandleStream.SetSize(NewSize: Longint);
begin
end;

procedure THandleStream.SetSize(const NewSize: Int64);
begin
end;

constructor THandleStream.Create(AHandle: THandle);
begin
end;

function THandleStream.Read(var Buffer; Count: Longint): Longint;
begin
end;

function THandleStream.Write(const Buffer; Count: Longint): Longint;
begin
end;

function THandleStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
end;

{ TStringStream }

function TStringStream.GetSize: Int64;
begin
end;

function TStringStream.GetPosition: Int64;
begin
end;

procedure TStringStream.SetSize(NewSize: Longint);
begin
end;

constructor TStringStream.Create(const AString: string);
begin
end;

function TStringStream.Read(var Buffer; Count: Longint): Longint;
begin
end;

function TStringStream.ReadString(Count: Longint): string;
begin
end;

function TStringStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
end;

function TStringStream.Write(const Buffer; Count: Longint): Longint;
begin
end;

procedure TStringStream.WriteString(const AString: string);
begin
end;

{ TOwnerStream }

constructor TOwnerStream.Create(ASource: TStream);
begin
end;

destructor TOwnerStream.Destroy;
begin
end;

{ TCollectionItem }

function TCollectionItem.GetIndex: Integer;
begin
end;

procedure TCollectionItem.SetCollection(Value: TCollection);
begin
end;

procedure TCollectionItem.Changed(AllItems: Boolean);
begin
end;

function TCollectionItem.GetOwner: TPersistent;
begin
end;

function TCollectionItem.GetDisplayName: string;
begin
end;

procedure TCollectionItem.SetIndex(Value: Integer);
begin
end;

procedure TCollectionItem.SetDisplayName(const Value: string);
begin
end;

constructor TCollectionItem.Create(ACollection: TCollection);
begin
end;

destructor TCollectionItem.Destroy;
begin
end;

function TCollectionItem.GetNamePath: string;
begin
end;

{ TCollection }

function TCollection.GetCount: Integer;
begin
end;

function TCollection.GetPropName: string;
begin
end;

procedure TCollection.InsertItem(Item: TCollectionItem);
begin
end;

procedure TCollection.RemoveItem(Item: TCollectionItem);
begin
end;

procedure TCollection.DoClear;
begin
end;

function TCollection.GetAttrCount: Integer;
begin
end;

function TCollection.GetAttr(Index: Integer): string;
begin
end;

function TCollection.GetItemAttr(Index: Integer; ItemIndex: Integer): string;
begin
end;

procedure TCollection.Changed;
begin
end;

function TCollection.GetItem(Index: Integer): TCollectionItem;
begin
end;

procedure TCollection.SetItem(Index: Integer; Value: TCollectionItem);
begin
end;

procedure TCollection.SetItemName(Item: TCollectionItem);
begin
end;

procedure TCollection.SetPropName;
begin
end;

procedure TCollection.Update(Item: TCollectionItem);
begin
end;

procedure TCollection.Notify(Item: TCollectionItem;
               Action: TCollectionNotification);
begin
end;

constructor TCollection.Create(AItemClass: TCollectionItemClass);
begin
end;

destructor TCollection.Destroy;
begin
end;

function TCollection.Owner: TPersistent;
begin
end;

function TCollection.Add: TCollectionItem;
begin
end;

procedure TCollection.Assign(Source: TPersistent);
begin
end;

procedure TCollection.BeginUpdate;
begin
end;

procedure TCollection.Clear;
begin
end;

procedure TCollection.EndUpdate;
begin
end;

procedure TCollection.Delete(Index: Integer);
begin
end;

function TCollection.GetEnumerator: TCollectionEnumerator;
begin
end;

function TCollection.GetNamePath: string;
begin
end;

function TCollection.Insert(Index: Integer): TCollectionItem;
begin
end;

function TCollection.FindItemID(ID: Integer): TCollectionItem;
begin
end;

procedure TCollection.Exchange(const Index1: integer; const index2: integer);
begin
end;

procedure TCollection.Sort(const Compare: TCollectionSortCompare);
begin
end;

{ TOwnedCollection }

function TOwnedCollection.GetOwner: TPersistent;
begin
end;

constructor TOwnedCollection.Create(AOwner: TPersistent;
               AItemClass: TCollectionItemClass);
begin
end;


function ExtractStrings(Separators, WhiteSpace: TSysCharSet; Content: PChar; Strings: TStrings): Integer;
begin
end;

end.
