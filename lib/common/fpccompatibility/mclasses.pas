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
{$ifdef FPC}
 {$mode objfpc}
 {$h+}
 { determine the type of the resource/form file }
 {$define Win16Res}
 {$define classesinline}

 {$INLINE ON}
{$endif}

{$if defined(FPC) and (fpc_fullversion >= 020601)}
 {$define mse_fpc_2_6_2}
{$ifend}

interface

uses
 classes,typinfo,sysutils,msetypes,msesystypes {$ifndef FPC},classes_del{$endif};

type
 ar8ty = array[0..7] of byte;
{$ifndef FPC}
  TTextLineBreakStyle = (tlbsLF,tlbsCRLF,tlbsCR);
  TValueType = (vaNull, vaList, vaInt8, vaInt16, vaInt32, vaExtended,
    vaString, vaIdent, vaFalse, vaTrue, vaBinary, vaSet, vaLString,
    vaNil, vaCollection, vaSingle, vaCurrency, vaDate, vaWString, vaInt64,
    vaUTF8String, vaUString, vaQWord);
const
  feInvalidHandle : THandle = THandle(-1);  //return value on FileOpen error
type
{$endif}
{$ifndef mse_fpc_2_6_2}
 tbytes = array of byte;
{$endif}
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
  {$ifndef FPC}
    function Equals(Obj: TObject) : boolean;virtual;
    { IUnknown }
    function QueryInterface(const IID: TGUID;out Obj): Hresult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  {$endif}
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
    FDesignInfo: Longint;
    FVCLComObject: Pointer;
    FComponentStyle: TComponentStyle;
//    function GetComObject: IUnknown;
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
    FComponents: TFpList;
    FFreeNotifies: TFpList;
    FComponentState: TComponentState;
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
  {$ifdef FPC}
    { IUnknown }
    function QueryInterface(
     {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID: TGUID;
      out Obj): Hresult; virtual; {$IFNDEF msWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef: Integer; {$IFNDEF msWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release: Integer; {$IFNDEF msWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
  {$endif}
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
//    function GetEnumerator: TComponentEnumerator;
    function GetNamePath: string; override;
    function GetParentComponent: tcomponent; dynamic;
    function HasParent: Boolean; dynamic;
    procedure InsertComponent(AComponent: tcomponent);
    procedure RemoveComponent(AComponent: tcomponent);
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;
    procedure SetSubComponent(ASubComponent: Boolean);
    function UpdateAction(Action: TBasicAction): Boolean; dynamic;
//    property ComObject: IUnknown read GetComObject;
//    function IsImplementorOf (const Intf:IInterface):boolean;
//    procedure ReferenceInterface(const intf:IInterface;op:TOperation);
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
  pcomponent = ^tcomponent;

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

  TCollectionEnumerator = class
  private
    FCollection: TCollection;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent: TCollectionItem;
    function MoveNext: Boolean;
    property Current: TCollectionItem read GetCurrent;
  end;

  TCollectionItemClass = class of TCollectionItem;
  TCollectionSortCompare = function (Item1, Item2: TCollectionItem): Integer;

  TCollection = class(TPersistent)
  private
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
    FItemClass: TCollectionItemClass;
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
    FIgnoreChildren: Boolean;
  protected
    FRoot: tcomponent;
    FLookupRoot: tcomponent;
    FAncestor: tpersistent;
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
  protected
   freader: treader;
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
    function ReadSet(EnumType: ptypeinfo): Integer; virtual; abstract;
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

    function ReadWord : word; 
                         {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
    function ReadDWord : longword; 
                         {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
    function ReadQWord : qword; 
                         {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$ifndef FPUNONE}
    function ReadExtended : extended; 
                         {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
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
    function ReadSet(EnumType: ptypeinfo): Integer; override;
    function ReadStr: String; override;
    function ReadString(StringType: TValueType): String; override;
    function ReadWideString: WideString;override;
    function ReadUnicodeString: UnicodeString;override;
    procedure SkipComponent(SkipComponentInfos: Boolean); override;
    procedure SkipValue; override;
  end;

  seterroreventty = procedure (const reader: treader;
                    const atype: ptypeinfo; const aitemname: string;
                                            var avalue: integer) of object;

  treader = class(tfiler)
  private
    FDriver: TAbstractObjectReader;
    FOwner: tcomponent;
    FParent: tcomponent;
    FFixups: TObject;
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
    fonseterror: seterroreventty;
    procedure DoFixupReferences;
    function FindComponentClass(const AClassName: string): TComponentClass;
  protected
    FLoaded: TFpList;
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
    function readset(settype: ptypeinfo): longword;
    function readenum(const enumtype: ptypeinfo): longword;
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
    property OnPropertyNotFound: TPropertyNotFoundEvent 
                            read FOnPropertyNotFound write FOnPropertyNotFound;
    property OnFindMethod: TFindMethodEvent read FOnFindMethod 
                                                           write FOnFindMethod;
    property OnSetMethodProperty: TSetMethodPropertyEvent 
                           read FOnSetMethodProperty write FOnSetMethodProperty;
    property OnSetName: TSetNameEvent read FOnSetName write FOnSetName;
    property OnReferenceName: TReferenceNameEvent read FOnReferenceName 
                                                      write FOnReferenceName;
    property OnAncestorNotFound: TAncestorNotFoundEvent 
                          read FOnAncestorNotFound write FOnAncestorNotFound;
    property OnCreateComponent: TCreateComponentEvent 
                           read FOnCreateComponent write FOnCreateComponent;
    property OnFindComponentClass: TFindComponentClassEvent 
                        read FOnFindComponentClass write FOnFindComponentClass;
    property OnReadStringProperty: TReadWriteStringPropertyEvent 
                        read FOnReadStringProperty write FOnReadStringProperty;
    property onseterror: seterroreventty read fonseterror write fonseterror;
  end;

  TAbstractObjectWriter = class
  protected
   fwriter: twriter;
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
    FDestroyDriver: Boolean;
    FOnWriteMethodProperty: TWriteMethodPropertyEvent;
    FOnWriteStringProperty:TReadWriteStringPropertyEvent;
    procedure AddToAncestorList(Component: tcomponent);
    procedure WriteComponentData(Instance: tcomponent);
    Procedure DetermineAncestor(Component: tcomponent);
    procedure DoFindAncestor(Component : tcomponent);
  protected
    FPropPath: String;
    FAncestors: tstringlist;
    FAncestorPos: Integer;
    FRootAncestor: tcomponent;
    FOnFindAncestor: TFindAncestorEvent;
    FDriver: TAbstractObjectWriter;
    FCurrentPos: Integer;
    procedure SetRoot(ARoot: tcomponent); override;
    procedure WriteBinary(AWriteData: TStreamProc);
    procedure WriteProperty(Instance: tpersistent; PropInfo: Pointer);
    procedure WriteProperties(Instance: tpersistent);
    procedure WriteChildren(Component: tcomponent);
    function CreateDriver(Stream: TStream;
                  BufSize: Integer): TAbstractObjectWriter; virtual;
    function getclassname(const aobj: tobject): shortstring; virtual;
  public
    constructor Create(ADriver: TAbstractObjectWriter); overload;
    constructor Create(Stream: TStream; BufSize: Integer); overload;
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
    procedure writeset(value: longword; settype: ptypeinfo);
    procedure writeenum(value: longint; enumtype: ptypeinfo);
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

TStringsEnumerator = class
  private
    FStrings: TStrings;
    FPosition: Integer;
  public
    constructor Create(AStrings: TStrings);
    function GetCurrent: String;
    function MoveNext: Boolean;
    property Current: String read GetCurrent;
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
    procedure Error(const Msg: string; Data: Integer); overload;
    procedure Error(const Msg: pstring; Data: Integer); overload;
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
    function Equals(Obj: TObject): Boolean; overload; override;
    function Equals(TheStrings: tstrings): Boolean; reintroduce; overload;
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
    procedure InsertItem(Index: Integer; const S: string); overload; virtual;
    procedure InsertItem(Index: Integer; const S: string; O: TObject);
                                                   overload; virtual;
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
    procedure SetSize(NewSize: Longint); overload; virtual;
    procedure SetSize(const NewSize: Int64); overload; virtual;
    procedure ReadNotImplemented;
    procedure WriteNotImplemented;
    function getmemory: pointer; virtual;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual; overload;
    function Write(const Buffer; Count: Longint): Longint; virtual; overload;
    function read(var buffer; const count: longint; 
                          out acount: longint): syserrorty; virtual; overload;
    function write(const buffer; const count: longint;
                          out acount: longint): syserrorty; virtual; overload;
    function Seek(Offset: Longint; Origin: Word): Longint; overload; virtual;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
                                             overload; virtual;
    procedure ReadBuffer(var Buffer; Count: Longint);
    function tryreadbuffer(var buffer; count: longint): syserrorty;
    procedure WriteBuffer(const Buffer; Count: Longint);
    function trywritebuffer(const buffer; count: longint): syserrorty;
    function readdatastring: string; virtual;
             //read available data
    procedure writedatastring(const value: string); virtual;
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
    property memory: pointer read getmemory; //nil if not suported
  end;

  THandleStream = class(TStream)
  private
  protected
    FHandle: filehandlety;
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(AHandle: THandle);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Handle: filehandlety read FHandle;
  end;

  TFileStream = class(THandleStream)
  Private
    FFileName : String;
  public
    constructor Create(const AFileName: string; Mode: Word); overload;
    constructor Create(const AFileName: string; Mode: Word; Rights: Cardinal);
                                            overload;
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
    function getmemory: pointer; override;
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
    function getmemory: pointer; override;
  public
    constructor Create(const AString: string);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadString(Count: Longint): string;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteString(const AString: string);
    property DataString: string read FDataString;
  end;
{$ifdef FPC}
{$ifdef UNICODE}
  TResourceStream = class(TCustomMemoryStream)
  private
    Res: TFPResourceHandle;
    Handle: TFPResourceHGLOBAL;
    procedure Initialize(Instance: TFPResourceHMODULE; Name, ResType: PWideChar; NameIsID: Boolean);
  public
    constructor Create(Instance: TFPResourceHMODULE; const ResName: WideString; ResType: PWideChar);
    constructor CreateFromID(Instance: TFPResourceHMODULE; ResID: Integer; ResType: PWideChar);
    destructor Destroy; override;
  end;
{$else}
  TResourceStream = class(TCustomMemoryStream)
  private
    Res: TFPResourceHandle;
    Handle: TFPResourceHGLOBAL;
    procedure Initialize(Instance: TFPResourceHMODULE; Name, ResType: PChar; NameIsID: Boolean);
  public
    constructor Create(Instance: TFPResourceHMODULE; const ResName: string; ResType: PChar);
    constructor CreateFromID(Instance: TFPResourceHMODULE; ResID: Integer; ResType: PChar);
    destructor Destroy; override;
  end;
{$endif UNICODE}
{$endif}

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
procedure beginsuspendgloballoading;
procedure endsuspendgloballoading;

function CollectionsEqual(C1, C2: TCollection): Boolean; overload;
function CollectionsEqual(C1, C2: TCollection; Owner1,
                           Owner2: TComponent): Boolean; overload;

procedure RegisterClass(AClass: TPersistentClass);
procedure RegisterClasses(AClasses: array of TPersistentClass);
procedure RegisterClassAlias(AClass: TPersistentClass; const Alias: string);
procedure UnRegisterClass(AClass: TPersistentClass);
procedure UnRegisterClasses(AClasses: array of TPersistentClass);
procedure UnRegisterModuleClasses(Module: HMODULE);
function FindClass(const AClassName: string): TPersistentClass;
function GetClass(const AClassName: string): TPersistentClass;

function ExtractStrings(Separators, WhiteSpace: TSysCharSet; Content: PChar; Strings: TStrings): Integer;

{$ifndef FPUNONE}
{$IFNDEF FPC_HAS_TYPE_EXTENDED}
function ExtendedToDouble(e : pointer) : double;
procedure DoubleToExtended(d : double; e : pointer);
{$endif}
{$endif}

{$ifndef FPC}
resourcestring
  SStreamNoReading              = 'Reading from %s is not supported';
  SStreamNoWriting              = 'Writing to %s is not supported';
  SRangeError                   = 'Range error';
  SStreamInvalidSeek            = 'Invalid stream operation %s.Seek';
  SEmptyStreamIllegalReader     = 'Illegal Nil stream for TReader constructor';
  SEmptyStreamIllegalWriter     = 'Illegal Nil stream for TWriter constructor';
  SErrNoVariantSupport          = 'No variant support for properties. Please use the variants unit in your project and recompile';
  SUnsupportedPropertyVariantType = 'Unsupported property variant type %d';
  SUnknownPropertyType          = 'Unknown property type %d';

Const
  FilerSignature : Array[1..4] of char = 'TPF0';
{$endif}

implementation

uses
 {$ifdef MSWINDOWS}windows,{$endif}rtlconsts,msesysintf,msesys;

{$ifndef FPC}
{$define endian_little}
{$define FPC_HAS_TYPE_EXTENDED}
{$endif}

Const
  // Ratio of Pointer and Word Size.
  WordRatio = SizeOf(Pointer) Div SizeOf(Word);

Type
  TLinkedListItem = Class
  Public
    Next : TLinkedListItem;
  end;
  TLinkedListItemClass = Class of TLinkedListItem;

  { TLinkedListVisitor }

  TLinkedListVisitor = Class
    Function Visit(Item : TLinkedListItem) : Boolean; virtual; abstract;
  end;
  { TLinkedList }

  TLinkedList = Class
  private
    FItemClass: TLinkedListItemClass;
    FRoot: TLinkedListItem;
    function GetCount: Integer;
  Public
    Constructor Create(AnItemClass : TLinkedListItemClass); virtual;
    Destructor Destroy; override;
    Procedure Clear;
    Function Add : TLinkedListItem;
    Procedure ForEach(Visitor: TLinkedListVisitor);
    Procedure RemoveItem(Item : TLinkedListItem; FreeItem : Boolean = False);
    Property Root : TLinkedListItem Read FRoot;
    Property ItemClass : TLinkedListItemClass Read FItemClass;
    Property Count : Integer Read GetCount;
  end;

{ TLinkedList }

function TLinkedList.GetCount: Integer;

Var
  I : TLinkedListItem;

begin
  I:=FRoot;
  Result:=0;
  While I<>Nil do
    begin
    I:=I.Next;
    Inc(Result);
    end;
end;

constructor TLinkedList.Create(AnItemClass: TLinkedListItemClass);
begin
  FItemClass:=AnItemClass;
end;

destructor TLinkedList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TLinkedList.Clear;

Var
   I : TLinkedListItem;

begin
  // Can't use visitor, because it'd kill the next pointer...
  I:=FRoot;
  While I<>Nil do
    begin
    FRoot:=I;
    I:=I.Next;
    FRoot.Next:=Nil;
    FreeAndNil(FRoot);
    end;
end;

function TLinkedList.Add: TLinkedListItem;
begin
  Result:=FItemClass.Create;
  Result.Next:=FRoot;
  FRoot:=Result;
end;

procedure TLinkedList.ForEach(Visitor : TLinkedListVisitor);

Var
  I : TLinkedListItem;

begin
  I:=FRoot;
  While (I<>Nil) and Visitor.Visit(I) do
    I:=I.Next;
end;

procedure TLinkedList.RemoveItem(Item: TLinkedListItem; FreeItem : Boolean = False);

Var
  I : TLinkedListItem;

begin
  If (Item<>Nil) and (FRoot<>Nil) then
    begin
    If (Item=FRoot) then
      FRoot:=Item.Next
    else
      begin
      I:=FRoot;
      While (I.Next<>Nil) and (I.Next<>Item) do
        I:=I.Next;
      If (I.Next=Item) then
        I.Next:=Item.Next;
      end;
    If FreeItem Then
      Item.Free;
    end;
end;


{****************************************************************************}
{*                             TPersistent                                  *}
{****************************************************************************}

{$ifndef FPC}
function tpersistent.Equals(Obj: TObject) : boolean;
begin
 result:= Obj = Self;
end;

function tpersistent.QueryInterface(const IID: TGUID;
                            out Obj): HResult; stdcall;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function tpersistent._AddRef: Integer; stdcall;
begin
 Result := -1;
end;

function tpersistent._Release: Integer; stdcall;
begin
 Result := -1;
end;
{$endif}

procedure TPersistent.AssignError(Source: TPersistent);

Var SourceName : String;

begin
  If Source<>Nil then
    SourceName:=Source.ClassName
  else
    SourceName:='Nil';
  raise EConvertError.CreateFmt (SAssignError,[SourceName,ClassName]);
end;



procedure TPersistent.AssignTo(Dest: TPersistent);


begin
  Dest.AssignError(Self);
end;


procedure TPersistent.DefineProperties(Filer: TFiler);

begin
end;


function  TPersistent.GetOwner: TPersistent;

begin
  Result:=Nil;
end;

destructor TPersistent.Destroy;
begin
//  If Assigned(FObservers) then
//    begin
//    FPONotifyObservers(Self,ooFree,Nil);
//    FreeAndNil(FObservers);
//    end;
  inherited Destroy;
end;
{
procedure TPersistent.FPOAttachObserver(AObserver: TObject);
Var
   I : IFPObserver;

begin
   If Not AObserver.GetInterface(SGUIDObserver,I) then
     Raise EObserver.CreateFmt(SErrNotObserver,[AObserver.ClassName]);
   If not Assigned(FObservers) then
     FObservers:=TFPList.Create;
   FObservers.Add(AObserver);
end;

procedure TPersistent.FPODetachObserver(AObserver: TObject);
Var
  I : IFPObserver;

begin
  If Not AObserver.GetInterface(SGUIDObserver,I) then
    Raise EObserver.CreateFmt(SErrNotObserver,[AObserver.ClassName]);
  If Assigned(FObservers) then
    begin
    FObservers.Remove(AObserver);
    If (FObservers.Count=0) then
      FreeAndNil(FObservers);
    end;
end;

procedure TPersistent.FPONotifyObservers(ASender: TObject;
  AOperation: TFPObservedOperation; Data : Pointer);
Var
  O : TObject;
  I : Integer;
  Obs : IFPObserver;

begin
  If Assigned(FObservers) then
    For I:=FObservers.Count-1 downto 0 do
      begin
      O:=TObject(FObservers[i]);
      If O.GetInterface(SGUIDObserver,Obs) then
        Obs.FPOObservedChanged(Self,AOperation,Data);
      end;
end;
}
procedure TPersistent.Assign(Source: TPersistent);

begin
  If Source<>Nil then
    Source.AssignTo(Self)
  else
    AssignError(Nil);
end;

function  TPersistent.GetNamePath: string;

Var OwnerName :String;
    TheOwner: TPersistent;

begin
 Result:=ClassName;
 TheOwner:=GetOwner;
 If TheOwner<>Nil then
   begin
   OwnerName:=TheOwner.GetNamePath;
   If OwnerName<>'' then Result:=OwnerName+'.'+Result;
   end;
end;

{****************************************************************************}
{*                             TComponent                                   *}
{****************************************************************************}
(*
function TComponent.GetComObject: IUnknown;
begin
  { Check if VCLComObject is not assigned - we need to create it by    }
  { the call to CreateVCLComObject routine. If in the end we are still }
  { have no valid VCLComObject pointer we need to raise an exception   }
  if not Assigned(VCLComObject) then
    begin
      if Assigned(CreateVCLComObjectProc) then
        CreateVCLComObjectProc(Self);
      if not Assigned(VCLComObject) then
        raise EComponentError.CreateFmt(SNoComSupport,[Name]);
    end;
  { VCLComObject is IVCComObject but we need to return IUnknown }
  IVCLComObject(VCLComObject).QueryInterface(IUnknown, Result);
end;
*)
Function  TComponent.GetComponent(AIndex: Integer): TComponent;

begin
  If not assigned(FComponents) then
    Result:=Nil
  else
    Result:=TComponent(FComponents.Items[Aindex]);
end;
{
function TComponent.IsImplementorOf (const Intf:IInterface):boolean;
var ref : IInterfaceComponentReference;
begin
 result:=assigned(intf) and supports(intf,IInterfaceComponentReference,ref);
 if result then
   result:=ref.getcomponent=self;
end;

procedure TComponent.ReferenceInterface(const intf:IInterface;op:TOperation);
var ref : IInterfaceComponentReference;
    comp : TComponent;
begin
 if assigned(intf) and supports(intf,IInterfaceComponentReference,ref) then
   begin
    comp:=ref.getcomponent;
    if op = opInsert then
      comp.FreeNotification(Self)
    else
      comp.RemoveFreeNotification(Self); 
   end;
end;
}
Function  TComponent.GetComponentCount: Integer;

begin
  If not assigned(FComponents) then
    result:=0
  else
    Result:=FComponents.Count;
end;


Function  TComponent.GetComponentIndex: Integer;

begin
  If Assigned(FOwner) and Assigned(FOwner.FComponents) then
    Result:=FOWner.FComponents.IndexOf(Self)
  else
    Result:=-1;
end;


Procedure TComponent.Insert(AComponent: TComponent);

begin
  If not assigned(FComponents) then
    FComponents:=TFpList.Create;
  FComponents.Add(AComponent);
  AComponent.FOwner:=Self;
end;


procedure tcomponent.readleft(reader: treader);

var
 int1: integer;
begin
 int1:= reader.readinteger;
 if (int1 < 0) or (int1 > $7fff) then begin
  int1:= 0;  //limit to positive values
 end;
 longrec(fdesigninfo).lo:= int1;
end;


procedure tcomponent.readtop(reader: treader);
var
 int1: integer;
begin
 int1:= reader.readinteger;
 if (int1 < 0) or (int1 > $7fff) then begin
  int1:= 0;  //limit to positive values
 end;
 longrec(fdesigninfo).hi:= int1;
end;


Procedure TComponent.Remove(AComponent: TComponent);

begin
  AComponent.FOwner:=Nil;
  If assigned(FCOmponents) then
    begin
    FComponents.Remove(AComponent);
    IF FComponents.Count=0 then
      begin
      FComponents.Free;
      FComponents:=Nil;
      end;
    end;
end;


Procedure TComponent.RemoveNotification(AComponent: TComponent);

begin
  if FFreeNotifies<>nil then
    begin
    FFreeNotifies.Remove(AComponent);
    if FFreeNotifies.Count=0 then
      begin
      FFreeNotifies.Free;
      FFreeNotifies:=nil;
      Exclude(FComponentState,csFreeNotification);
      end;
    end;
end;


Procedure TComponent.SetComponentIndex(Value: Integer);

Var Temp,Count : longint;

begin
  If Not assigned(Fowner) then exit;
  Temp:=getcomponentindex;
  If temp<0 then exit;
  If value<0 then value:=0;
  Count:=Fowner.FComponents.Count;
  If Value>=Count then value:=count-1;
  If Value<>Temp then
    begin
    FOWner.FComponents.Delete(Temp);
    FOwner.FComponents.Insert(Value,Self);
    end;
end;


Procedure TComponent.SetReference(Enable: Boolean);

var
  Field: ^TComponent;
begin
  if Assigned(Owner) then
  begin
    Field := Owner.FieldAddress(Name);
    if Assigned(Field) then
      if Enable then
        Field^ := Self
      else
        Field^ := nil;
  end;
end;


Procedure TComponent.WriteLeft(Writer: TWriter);

begin
  Writer.WriteInteger(smallint(LongRec(FDesignInfo).Lo));
end;


Procedure TComponent.WriteTop(Writer: TWriter);

begin
  Writer.WriteInteger(smallint(LongRec(FDesignInfo).Hi));
end;


Procedure TComponent.ChangeName(const NewName: TComponentName);

begin
  FName:=NewName;
end;


Procedure TComponent.DefineProperties(Filer: TFiler);

Var Ancestor : TComponent;
    Temp : longint;

begin
  Temp:=0;
  Ancestor:=TComponent(Filer.Ancestor);
  If Assigned(Ancestor) then Temp:=Ancestor.FDesignInfo;
  Filer.Defineproperty('left',{$ifdef FPC}@{$endif}readleft,
                              {$ifdef FPC}@{$endif}writeleft,
                       (longrec(FDesignInfo).Lo<>Longrec(temp).Lo));
  Filer.Defineproperty('top',{$ifdef FPC}@{$endif}readtop,
                             {$ifdef FPC}@{$endif}writetop,
                       (longrec(FDesignInfo).Hi<>Longrec(temp).Hi));
end;


Procedure TComponent.GetChildren(Proc: TGetChildProc; Root: TComponent);

begin
  // Does nothing.
end;


Function  TComponent.GetChildOwner: TComponent;

begin
 Result:=Nil;
end;


Function  TComponent.GetChildParent: TComponent;

begin
  Result:=Self;
end;

{
Function  TComponent.GetEnumerator: TComponentEnumerator;

begin
  Result:=TComponentEnumerator.Create(Self);
end;
}
Function  TComponent.GetNamePath: string;

begin
  Result:=FName;
end;


Function  TComponent.GetOwner: TPersistent;

begin
  Result:=FOwner;
end;


Procedure TComponent.Loaded;

begin
  Exclude(FComponentState,csLoading);
end;

Procedure TComponent.Loading;

begin
  Include(FComponentState,csLoading);
end;


Procedure TComponent.Notification(AComponent: TComponent;
  Operation: TOperation);

Var Runner : Longint;

begin
  If (Operation=opRemove) and Assigned(FFreeNotifies) then
    begin
    FFreeNotifies.Remove(AComponent);
            If FFreeNotifies.Count=0 then
      begin
      FFreeNotifies.Free;
      FFreenotifies:=Nil;
      end;
    end;
  If assigned(FComponents) then
    For Runner:=0 To FComponents.Count-1 do
      TComponent(FComponents.Items[Runner]).Notification(AComponent,Operation);
end;


procedure TComponent.PaletteCreated;
  begin
  end;


Procedure TComponent.ReadState(Reader: TReader);

begin
  Reader.ReadData(Self);
end;


Procedure TComponent.SetAncestor(Value: Boolean);

Var Runner : Longint;

begin
  If Value then
    Include(FComponentState,csAncestor)
  else
    Exclude(FCOmponentState,csAncestor);
  if Assigned(FComponents) then
    For Runner:=0 To FComponents.Count-1 do
      TComponent(FComponents.Items[Runner]).SetAncestor(Value);
end;


Procedure TComponent.SetDesigning(Value: Boolean; SetChildren : Boolean = True);

Var Runner : Longint;

begin
  If Value then
    Include(FComponentState,csDesigning)
  else
    Exclude(FComponentState,csDesigning);
  if Assigned(FComponents) and SetChildren then
    For Runner:=0 To FComponents.Count - 1 do
      TComponent(FComponents.items[Runner]).SetDesigning(Value);
end;

Procedure TComponent.SetDesignInstance(Value: Boolean);

begin
  If Value then
    Include(FComponentState,csDesignInstance)
  else
    Exclude(FComponentState,csDesignInstance);
end;

Procedure TComponent.SetInline(Value: Boolean);

begin
  If Value then
    Include(FComponentState,csInline)
  else
    Exclude(FComponentState,csInline);
end;


Procedure TComponent.SetName(const NewName: TComponentName);

begin
  If FName=NewName then exit;
  If (NewName<>'') and not IsValidIdent(NewName) then
    Raise EComponentError.CreateFmt(SInvalidName,[NewName]);
  If Assigned(FOwner) Then
    FOwner.ValidateRename(Self,FName,NewName)
  else
    ValidateRename(Nil,FName,NewName);
  SetReference(False);
  ChangeName(NewName);
  Setreference(True);
end;


Procedure TComponent.SetChildOrder(Child: TComponent; Order: Integer);

begin
  // does nothing
end;


Procedure TComponent.SetParentComponent(Value: TComponent);

begin
  // Does nothing
end;


Procedure TComponent.Updating;

begin
  Include (FComponentState,csUpdating);
end;


Procedure TComponent.Updated;

begin
  Exclude(FComponentState,csUpdating);
end;


class Procedure TComponent.UpdateRegistry(Register: Boolean; const ClassID, ProgID: string);

begin
  // For compatibility only.
end;


Procedure TComponent.ValidateRename(AComponent: TComponent;
  const CurName, NewName: string);

begin
//!! This contradicts the Delphi manual.
  If (AComponent<>Nil) and (CompareText(CurName,NewName)<>0) and (AComponent.Owner = Self) and
     (FindComponent(NewName)<>Nil) then
      raise EComponentError.Createfmt(SDuplicateName,[newname]);
  If (csDesigning in FComponentState) and (FOwner<>Nil) then
    FOwner.ValidateRename(AComponent,Curname,Newname);
end;


Procedure TComponent.ValidateContainer(AComponent: TComponent);

begin
  AComponent.ValidateInsert(Self);
end;


Procedure TComponent.ValidateInsert(AComponent: TComponent);

begin
  // Does nothing.
end;


Procedure TComponent.WriteState(Writer: TWriter);

begin
  Writer.WriteComponentData(Self);
end;


Constructor TComponent.Create(AOwner: TComponent);

begin
  FComponentStyle:=[csInheritable];
  If Assigned(AOwner) then AOwner.InsertComponent(Self);
end;


Destructor TComponent.Destroy;

Var
  I : Integer;
  C : TComponent;

begin
  Destroying;
  If Assigned(FFreeNotifies) then
    begin
    I:=FFreeNotifies.Count-1;
    While (I>=0) do
      begin
      C:=TComponent(FFreeNotifies.Items[I]);
      // Delete, so one component is not notified twice, if it is owned.
      FFreeNotifies.Delete(I);
      C.Notification (self,opRemove);
      If (FFreeNotifies=Nil) then
        I:=0
      else if (I>FFreeNotifies.Count) then
        I:=FFreeNotifies.Count;
      dec(i);
      end;
    FreeAndNil(FFreeNotifies);
    end;
  DestroyComponents;
  If FOwner<>Nil Then FOwner.RemoveComponent(Self);
  inherited destroy;
end;


Procedure TComponent.BeforeDestruction;
begin
  if not(csDestroying in FComponentstate) then
    Destroying;
end;


Procedure TComponent.DestroyComponents;

Var acomponent: TComponent;

begin
  While assigned(FComponents) do
    begin
    aComponent:=TComponent(FComponents.Last);
    Remove(aComponent);
    Acomponent.Destroy;
    end;
end;


Procedure TComponent.Destroying;

Var Runner : longint;

begin
  If csDestroying in FComponentstate Then Exit;
  include (FComponentState,csDestroying);
  If Assigned(FComponents) then
    for Runner:=0 to FComponents.Count-1 do
      TComponent(FComponents.Items[Runner]).Destroying;
end;


function TComponent.ExecuteAction(Action: TBasicAction): Boolean;
begin
  if Action.HandlesTarget(Self) then
   begin
     Action.ExecuteTarget(Self);
     Result := True;
   end
  else
   Result := False;
end;


Function  TComponent.FindComponent(const AName: string): TComponent;

Var I : longint;

begin
  Result:=Nil;
  If (AName='') or Not assigned(FComponents) then exit;
  For i:=0 to FComponents.Count-1 do
    if (CompareText(TComponent(FComponents[I]).Name,AName)=0) then
      begin
      Result:=TComponent(FComponents.Items[I]);
      exit;
      end;
end;


Procedure TComponent.FreeNotification(AComponent: TComponent);

begin
  If (Owner<>Nil) and (AComponent=Owner) then exit;
  If not (Assigned(FFreeNotifies)) then
    FFreeNotifies:=TFpList.Create;
  If FFreeNotifies.IndexOf(AComponent)=-1 then
    begin
    FFreeNotifies.Add(AComponent);
    AComponent.FreeNotification (self);
    end;
end;


procedure TComponent.RemoveFreeNotification(AComponent: TComponent);
begin
  RemoveNotification(AComponent);
  AComponent.RemoveNotification (self);
end;


Procedure TComponent.FreeOnRelease;
begin
  if Assigned(VCLComObject) then
    IVCLComObject(VCLComObject).FreeOnRelease;
end;


Function  TComponent.GetParentComponent: TComponent;

begin
  Result:=Nil;
end;


Function  TComponent.HasParent: Boolean;

begin
  Result:=False;
end;


Procedure TComponent.InsertComponent(AComponent: TComponent);

begin
  AComponent.ValidateContainer(Self);
  ValidateRename(AComponent,'',AComponent.FName);
  Insert(AComponent);
  AComponent.SetReference(True);
  If csDesigning in FComponentState then
    AComponent.SetDesigning(true);
  Notification(AComponent,opInsert);
end;


Procedure TComponent.RemoveComponent(AComponent: TComponent);

begin
  Notification(AComponent,opRemove);
  AComponent.SetReference(False);
  Remove(AComponent);
  Acomponent.Setdesigning(False);
  ValidateRename(AComponent,AComponent.FName,'');
end;


Function  TComponent.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject).SafeCallException(ExceptObject, ExceptAddr)
  else
    Result := inherited SafeCallException(ExceptObject, ExceptAddr);
end;

procedure TComponent.SetSubComponent(ASubComponent: Boolean);
begin
  if ASubComponent then
    Include(FComponentStyle, csSubComponent)
  else
    Exclude(FComponentStyle, csSubComponent);
end;


function TComponent.UpdateAction(Action: TBasicAction): Boolean;
begin
  if Action.HandlesTarget(Self) then
    begin
      Action.UpdateTarget(Self);
      Result := True;
    end
  else
    Result := False;
end;

{$ifdef FPC}
function TComponent.QueryInterface(
{$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID: TGUID;
 out Obj): HResult;{$IFNDEF msWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject).QueryInterface(IID, Obj)
  else
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TComponent._AddRef: Integer;{$IFNDEF msWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject)._AddRef
  else
    Result := -1;
end;

function TComponent._Release: Integer;{$IFNDEF msWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject)._Release
  else
    Result := -1;
end;
{$endif}

function TComponent.iicrGetComponent: TComponent;

begin
  result:=self;
end;

function TComponent.GetTypeInfoCount(out Count: Integer): HResult; stdcall;
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject).GetTypeInfoCount(Count)
  else
    Result := E_NOTIMPL;
end;

function TComponent.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject).GetTypeInfo(Index, LocaleID, TypeInfo)
  else
    Result := E_NOTIMPL;
end;

function TComponent.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
  LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject).GetIDsOfNames(IID, Names, NameCount, LocaleID, DispIDs)
  else
    Result := E_NOTIMPL;
end;

function TComponent.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult; stdcall;
begin
  if Assigned(VCLComObject) then
    Result := IVCLComObject(VCLComObject).Invoke(DispID, IID, LocaleID, Flags, Params,
      VarResult, ExcepInfo, ArgErr)
  else
    Result := E_NOTIMPL;
end;

{****************************************************************************}
{*                        TStringsEnumerator                                *}
{****************************************************************************}

constructor TStringsEnumerator.Create(AStrings: TStrings);
begin
  inherited Create;
  FStrings := AStrings;
  FPosition := -1;
end;

function TStringsEnumerator.GetCurrent: String;
begin
  Result := FStrings[FPosition];
end;

function TStringsEnumerator.MoveNext: Boolean;
begin
  Inc(FPosition);
  Result := FPosition < FStrings.Count;
end;

{****************************************************************************}
{*                             TStrings                                     *}
{****************************************************************************}

// Function to quote text. Should move maybe to sysutils !!
// Also, it is not clear at this point what exactly should be done.

{ //!! is used to mark unsupported things. }

Function QuoteString (Const S : String; Quote : String) : String;
Var
  I,J : Integer;
begin
  J:=0;
  Result:=S;
  for i:=1to length(s) do
   begin
     inc(j);
     if S[i]=Quote then
      begin
        System.Insert(Quote,Result,J);
        inc(j);
      end;
   end;
  Result:=Quote+Result+Quote;
end;

{
  For compatibility we can't add a Constructor to TSTrings to initialize
  the special characters. Therefore we add a routine which is called whenever
  the special chars are needed.
}

Procedure Tstrings.CheckSpecialChars;

begin
  If Not FSpecialCharsInited then
    begin
    FQuoteChar:='"';
    FDelimiter:=',';
    FNameValueSeparator:='=';
    FSpecialCharsInited:=true;
    FLBS:= ttextlinebreakstyle(DefaultTextLineBreakStyle);
    end;
end;

Function TStrings.GetLBS : TTextLineBreakStyle;
begin
  CheckSpecialChars;
  Result:=FLBS;
end;

Procedure TStrings.SetLBS (AValue : TTextLineBreakStyle);
begin
  CheckSpecialChars;
  FLBS:=AValue;
end;

procedure TStrings.SetDelimiter(c:Char);
begin
  CheckSpecialChars;
  FDelimiter:=c;
end;


procedure TStrings.SetQuoteChar(c:Char);
begin
  CheckSpecialChars;
  FQuoteChar:=c;
end;

procedure TStrings.SetNameValueSeparator(c:Char);
begin
  CheckSpecialChars;
  FNameValueSeparator:=c;
end;


function TStrings.GetCommaText: string;

Var
  C1,C2 : Char;
  FSD : Boolean;

begin
  CheckSpecialChars;
  FSD:=StrictDelimiter;
  C1:=Delimiter;
  C2:=QuoteChar;
  Delimiter:=',';
  QuoteChar:='"';
  StrictDelimiter:=False;
  Try
    Result:=GetDelimitedText;
  Finally
    Delimiter:=C1;
    QuoteChar:=C2;
    StrictDelimiter:=FSD;
  end;
end;


Function TStrings.GetDelimitedText: string;

Var
  I : integer;
  p : pchar;
  c : set of char;
  S : String;
  
begin
  CheckSpecialChars;
  result:='';
  if StrictDelimiter then
    c:=[#0,Delimiter]
  else  
    c:=[#0..' ',QuoteChar,Delimiter];
  For i:=0 to count-1 do
    begin
    S:=Strings[i];
    p:=pchar(S);
    while not(p^ in c) do
     inc(p);
// strings in list may contain #0
    if (p<>pchar(S)+length(S)) and not StrictDelimiter then
      Result:=Result+QuoteString(S,QuoteChar)
    else
      Result:=Result+S;
    if I<Count-1 then 
      Result:=Result+Delimiter;
    end;
  If (Length(Result)=0) and (Count=1) then
    Result:=QuoteChar+QuoteChar;
end;

procedure TStrings.GetNameValue(Index : Integer; Out AName,AValue : String);

Var L : longint;

begin
  CheckSpecialChars;
  AValue:=Strings[Index];
  L:=Pos(FNameValueSeparator,AValue);
  If L<>0 then
    begin
    AName:=Copy(AValue,1,L-1);
    System.Delete(AValue,1,L);
    end
  else
    AName:='';
end;

function TStrings.ExtractName(const s:String):String;
var
  L: Longint;
begin
  CheckSpecialChars;
  L:=Pos(FNameValueSeparator,S);
  If L<>0 then
    Result:=Copy(S,1,L-1)
  else
    Result:='';
end;

function TStrings.GetName(Index: Integer): string;

Var
  V : String;

begin
  GetNameValue(Index,Result,V);
end;

Function TStrings.GetValue(const Name: string): string;

Var
  L : longint;
  N : String;

begin
  Result:='';
  L:=IndexOfName(Name);
  If L<>-1 then
    GetNameValue(L,N,Result);
end;

Function TStrings.GetValueFromIndex(Index: Integer): string;

Var
  N : String;

begin
  GetNameValue(Index,N,Result);
end;

Procedure TStrings.SetValueFromIndex(Index: Integer; const Value: string);

begin
  If (Value='') then
    Delete(Index)
  else
    begin
    If (Index<0) then
      Index:=Add('');
    CheckSpecialChars;
    Strings[Index]:=GetName(Index)+FNameValueSeparator+Value;
    end;
end;

procedure TStrings.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  BeginUpdate;
  try
    Clear;
    while not Reader.EndOfList do
      Add(Reader.ReadString);
  finally
    EndUpdate;
  end;
  Reader.ReadListEnd;
end;


Procedure TStrings.SetDelimitedText(const AValue: string);
var i,j:integer;
    aNotFirst:boolean;
begin
 CheckSpecialChars;
 BeginUpdate;

 i:=1;
 j:=1;
 aNotFirst:=false;

 try
  Clear;
  If StrictDelimiter then
    begin
    // Easier, faster loop.
    While I<=Length(AValue) do
      begin
      If (AValue[I] in [FDelimiter,#0]) then
        begin
        Add(Copy(AValue,J,I-J));
        J:=I+1;
        end;
      Inc(i);
      end;
    If (Length(AValue)>0) then
      Add(Copy(AValue,J,I-J));  
    end
  else 
    begin
    while i<=length(AValue) do begin
     // skip delimiter
     if aNotFirst and (i<=length(AValue)) and (AValue[i]=FDelimiter) then inc(i);

     // skip spaces
     while (i<=length(AValue)) and (Ord(AValue[i])<=Ord(' ')) do inc(i);
    
     // read next string
     if i<=length(AValue) then begin
      if AValue[i]=FQuoteChar then begin
       // next string is quoted
       j:=i+1;
       while (j<=length(AValue)) and
             ( (AValue[j]<>FQuoteChar) or
               ( (j+1<=length(AValue)) and (AValue[j+1]=FQuoteChar) ) ) do begin
        if (j<=length(AValue)) and (AValue[j]=FQuoteChar) then inc(j,2)
                                                          else inc(j);
       end;
       // j is position of closing quote
       Add( StringReplace (Copy(AValue,i+1,j-i-1),
                           FQuoteChar+FQuoteChar,FQuoteChar, [rfReplaceAll]));
       i:=j+1;
      end else begin
       // next string is not quoted
       j:=i;
       while (j<=length(AValue)) and
             (Ord(AValue[j])>Ord(' ')) and
             (AValue[j]<>FDelimiter) do inc(j);
       Add( Copy(AValue,i,j-i));
       i:=j;
      end;
     end else begin
      if aNotFirst then Add('');
     end;

     // skip spaces
     while (i<=length(AValue)) and (Ord(AValue[i])<=Ord(' ')) do inc(i);

     aNotFirst:=true;
    end;
    end;
 finally
   EndUpdate;
 end;
end;

Procedure TStrings.SetCommaText(const Value: string);

Var
  C1,C2 : Char;

begin
  CheckSpecialChars;
  C1:=Delimiter;
  C2:=QuoteChar;
  Delimiter:=',';
  QuoteChar:='"';
  Try
    SetDelimitedText(Value);
  Finally
    Delimiter:=C1;
    QuoteChar:=C2;
  end;
end;


Procedure TStrings.SetStringsAdapter(const Value: IStringsAdapter);

begin
end;



Procedure TStrings.SetValue(const Name, Value: string);

Var L : longint;

begin
  CheckSpecialChars;
  L:=IndexOfName(Name);
  if L=-1 then
   Add (Name+FNameValueSeparator+Value)
  else
   Strings[L]:=Name+FNameValueSeparator+value;
end;



procedure TStrings.WriteData(Writer: TWriter);
var
  i: Integer;
begin
  Writer.WriteListBegin;
  for i := 0 to Count - 1 do
    Writer.WriteString(Strings[i]);
  Writer.WriteListEnd;
end;



procedure TStrings.DefineProperties(Filer: TFiler);
var
  HasData: Boolean;
begin
  if Assigned(Filer.Ancestor) then
    // Only serialize if string list is different from ancestor
    if Filer.Ancestor.InheritsFrom(TStrings) then
      HasData := not Equals(TStrings(Filer.Ancestor))
    else
      HasData := True
  else
    HasData := Count > 0;
  Filer.DefineProperty('Strings', {$ifdef FPC}@{$endif}ReadData,
                                {$ifdef FPC}@{$endif}WriteData, HasData);
end;


Procedure TStrings.Error(const Msg: string; Data: Integer);
begin
  Raise EStringListError.CreateFmt(Msg,[Data])
                   {$ifdef FPC} at get_caller_addr(get_frame){$endif};
end;


Procedure TStrings.Error(const Msg: pstring; Data: Integer);
begin
  Raise EStringListError.CreateFmt(Msg^,[Data])
                   {$ifdef FPC} at get_caller_addr(get_frame){$endif};
end;


Function TStrings.GetCapacity: Integer;

begin
  Result:=Count;
end;



Function TStrings.GetObject(Index: Integer): TObject;

begin
  Result:=Nil;
end;



Function TStrings.GetTextStr: string;

Var P : Pchar;
    I,L,NLS : Longint;
    S,NL : String;

begin
  CheckSpecialChars;
  // Determine needed place
  Case FLBS of
    tlbsLF   : NL:=#10;
    tlbsCRLF : NL:=#13#10;
    tlbsCR   : NL:=#13;
  end;
  L:=0;
  NLS:=Length(NL);
  For I:=0 to count-1 do
    L:=L+Length(Strings[I])+NLS;
  Setlength(Result,L);
  P:=Pointer(Result);
  For i:=0 To count-1 do
    begin
    S:=Strings[I];
    L:=Length(S);
    if L<>0 then
      System.Move(Pointer(S)^,P^,L);
    P:=P+L;
    For L:=1 to NLS do
      begin
      P^:=NL[L];
      inc(P);
      end;
    end;
end;



Procedure TStrings.Put(Index: Integer; const S: string);

Var Obj : TObject;

begin
  Obj:=Objects[Index];
  Delete(Index);
  InsertObject(Index,S,Obj);
end;



Procedure TStrings.PutObject(Index: Integer; AObject: TObject);

begin
  // Empty.
end;



Procedure TStrings.SetCapacity(NewCapacity: Integer);

begin
  // Empty.
end;

Function GetNextLine (Const Value : String; Var S : String; Var P : Integer) : Boolean;

Var 
  PS : PChar;
  IP,L : Integer;
  
begin
  L:=Length(Value);
  S:='';
  Result:=False;
  If ((L-P)<0) then
    exit;
  if ((L-P)=0) and (not (value[P] in [#10,#13])) Then
    Begin
      s:=value[P];
      inc(P);
      result:= true;
      Exit;
    End;
  PS:=PChar(Value)+P-1;
  IP:=P;
  While ((L-P)>=0) and (not (PS^ in [#10,#13])) do 
    begin
    P:=P+1;
    Inc(PS);
    end;
  SetLength (S,P-IP);
  System.Move (Value[IP],Pointer(S)^,P-IP);
  If (P<=L) and (Value[P]=#13) then 
    Inc(P);
  If (P<=L) and (Value[P]=#10) then
    Inc(P); // Point to character after #10(#13)
  Result:=True;
end;

Procedure TStrings.SetTextStr(const Value: string);

Var
  S : String;
  P : Integer;

begin
  Try
    beginUpdate;
    Clear;
    P:=1;
    While GetNextLine (Value,S,P) do
      Add(S);
  finally
    EndUpdate;
  end;
end;

Procedure TStrings.SetUpdateState(Updating: Boolean);

begin
//  FPONotifyObservers(Self,ooChange,Nil);
end;

destructor TSTrings.Destroy;

begin
  inherited destroy;
end;



Function TStrings.Add(const S: string): Integer;

begin
  Result:=Count;
  Insert (Count,S);
end;



Function TStrings.AddObject(const S: string; AObject: TObject): Integer;

begin
  Result:=Add(S);
  Objects[result]:=AObject;
end;



Procedure TStrings.Append(const S: string);

begin
  Add (S);
end;



Procedure TStrings.AddStrings(TheStrings: TStrings);

Var Runner : longint;

begin
  try
    beginupdate;
    For Runner:=0 to TheStrings.Count-1 do
      self.AddObject (Thestrings[Runner],TheStrings.Objects[Runner]);
  finally
    EndUpdate;
  end;
end;

Procedure TStrings.AddStrings(const TheStrings: array of string);

Var Runner : longint;

begin
  try
    beginupdate;
    if Count + High(TheStrings)+1 > Capacity then
      Capacity := Count + High(TheStrings)+1;
    For Runner:=Low(TheStrings) to High(TheStrings) do
      self.Add(Thestrings[Runner]);
  finally
    EndUpdate;
  end;
end;

Procedure TStrings.Assign(Source: TPersistent);

Var
  S : TStrings;

begin
  If Source is TStrings then
    begin
    S:=TStrings(Source);
    BeginUpdate;
    Try
      clear;
      FSpecialCharsInited:=S.FSpecialCharsInited;
      FQuoteChar:=S.FQuoteChar;
      FDelimiter:=S.FDelimiter;
      FNameValueSeparator:=S.FNameValueSeparator;
      FLBS:=S.FLBS;
      AddStrings(S);
    finally
      EndUpdate;
    end;
    end
  else
    Inherited Assign(Source);
end;



Procedure TStrings.BeginUpdate;

begin
   if FUpdateCount = 0 then SetUpdateState(true);
   inc(FUpdateCount);
end;



Procedure TStrings.EndUpdate;

begin
  If FUpdateCount>0 then
     Dec(FUpdateCount);
  if FUpdateCount=0 then
    SetUpdateState(False);
end;



Function TStrings.Equals(Obj: TObject): Boolean;

begin
  if Obj is TStrings then
    Result := Equals(TStrings(Obj))
  else
    Result := inherited Equals(Obj);
end;



Function TStrings.Equals(TheStrings: TStrings): Boolean;

Var Runner,Nr : Longint;

begin
  Result:=False;
  Nr:=Self.Count;
  if Nr<>TheStrings.Count then exit;
  For Runner:=0 to Nr-1 do
    If Strings[Runner]<>TheStrings[Runner] then exit;
  Result:=True;
end;



Procedure TStrings.Exchange(Index1, Index2: Integer);

Var
  Obj : TObject;
  Str : String;

begin
  Try
    beginUpdate;
    Obj:=Objects[Index1];
    Str:=Strings[Index1];
    Objects[Index1]:=Objects[Index2];
    Strings[Index1]:=Strings[Index2];
    Objects[Index2]:=Obj;
    Strings[Index2]:=Str;
  finally
    EndUpdate;
  end;
end;


function TStrings.GetEnumerator: TStringsEnumerator;
begin
  Result:=TStringsEnumerator.Create(Self);
end;


Function TStrings.GetText: PChar;
begin
  Result:=StrNew(Pchar(Self.Text));
end;


Function TStrings.DoCompareText(const s1,s2 : string) : PtrInt;
  begin
    result:=CompareText(s1,s2);
  end;


Function TStrings.IndexOf(const S: string): Integer;
begin
  Result:=0;
  While (Result<Count) and (DoCompareText(Strings[Result],S)<>0) do Result:=Result+1;
  if Result=Count then Result:=-1;
end;


Function TStrings.IndexOfName(const Name: string): Integer;
Var
  len : longint;
  S : String;
begin
  CheckSpecialChars;
  Result:=0;
  while (Result<Count) do
    begin
    S:=Strings[Result];
    len:=pos(FNameValueSeparator,S)-1;
    if (len>0) and (DoCompareText(Name,Copy(S,1,Len))=0) then
      exit;
    inc(result);
    end;
  result:=-1;
end;


Function TStrings.IndexOfObject(AObject: TObject): Integer;
begin
  Result:=0;
  While (Result<count) and (Objects[Result]<>AObject) do Result:=Result+1;
  If Result=Count then Result:=-1;
end;


Procedure TStrings.InsertObject(Index: Integer; const S: string;
  AObject: TObject);

begin
  Insert (Index,S);
  Objects[Index]:=AObject;
end;



Procedure TStrings.LoadFromFile(const FileName: string);
Var
        TheStream : TFileStream;
begin
  TheStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(TheStream);
  finally
    TheStream.Free;
  end;
end;



Procedure TStrings.LoadFromStream(Stream: TStream);
{
   Borlands method is no good, since a pipe for
   instance doesn't have a size.
   So we must do it the hard way.
}
Const
  BufSize = 1024;
  MaxGrow = 1 shl 29;

Var
  Buffer     : AnsiString;
  BytesRead,
  BufLen,
  I,BufDelta     : Longint;
begin
  // reread into a buffer
  try
    beginupdate;
    Buffer:='';
    BufLen:=0;
    I:=1;
    Repeat
      BufDelta:=BufSize*I;
      SetLength(Buffer,BufLen+BufDelta);
      BytesRead:=Stream.Read(Buffer[BufLen+1],BufDelta);
      inc(BufLen,BufDelta);
      If I<MaxGrow then
        I:=I shl 1;
    Until BytesRead<>BufDelta;
    SetLength(Buffer, BufLen-BufDelta+BytesRead);
    SetTextStr(Buffer);
    SetLength(Buffer,0);
  finally
    EndUpdate;
  end;
end;


Procedure TStrings.Move(CurIndex, NewIndex: Integer);
Var
  Obj : TObject;
  Str : String;
begin
  BeginUpdate;
  Obj:=Objects[CurIndex];
  Str:=Strings[CurIndex];
  Delete(Curindex);
  InsertObject(NewIndex,Str,Obj);
  EndUpdate;
end;



Procedure TStrings.SaveToFile(const FileName: string);

Var TheStream : TFileStream;

begin
  TheStream:=TFileStream.Create(FileName,fmCreate);
  try
    SaveToStream(TheStream);
  finally
    TheStream.Free;
  end;
end;



Procedure TStrings.SaveToStream(Stream: TStream);
Var
  S : String;
begin
  S:=Text;
  if S = '' then Exit;
  Stream.WriteBuffer(Pointer(S)^,Length(S));
end;




Procedure TStrings.SetText(TheText: PChar);

Var S : String;

begin
  If TheText<>Nil then
    S:=StrPas(TheText)
  else
    S:='';
  SetTextStr(S);  
end;


{****************************************************************************}
{*                             TStringList                                  *}
{****************************************************************************}


Procedure TStringList.ExchangeItems(Index1, Index2: Integer);

Var P1,P2 : Pointer;

begin
  P1:=Pointer(Flist^[Index1].FString);
  P2:=Pointer(Flist^[Index1].FObject);
  Pointer(Flist^[Index1].Fstring):=Pointer(Flist^[Index2].Fstring);
  Pointer(Flist^[Index1].FObject):=Pointer(Flist^[Index2].FObject);
  Pointer(Flist^[Index2].Fstring):=P1;
  Pointer(Flist^[Index2].FObject):=P2;
end;



Procedure TStringList.Grow;

Var
  NC : Integer;

begin
  NC:=FCapacity;
  If NC>=256 then
    NC:=NC+(NC Div 4)
  else if NC=0 then
    NC:=4
  else
    NC:=NC*4;
  SetCapacity(NC);
end;

Procedure TStringList.InternalClear;

Var
  I: Integer;

begin
  if FOwnsObjects then
    begin
      For I:=0 to FCount-1 do
        begin
          Flist^[I].FString:='';
          freeandnil(Flist^[i].FObject);
        end;
    end
  else
    begin
      For I:=0 to FCount-1 do
        Flist^[I].FString:='';
    end;
  FCount:=0;
  SetCapacity(0);
end;

Procedure TStringList.QuickSort(L, R: Integer; CompareFn: TStringListSortCompare);
var
  Pivot, vL, vR: Integer;
begin
  if R - L <= 1 then begin // a little bit of time saver
    if L < R then
      if CompareFn(Self, L, R) > 0 then
        ExchangeItems(L, R);

    Exit;
  end;

  vL := L;
  vR := R;

  Pivot := L + Random(R - L); // they say random is best

  while vL < vR do begin
    while (vL < Pivot) and (CompareFn(Self, vL, Pivot) <= 0) do
      Inc(vL);

    while (vR > Pivot) and (CompareFn(Self, vR, Pivot) > 0) do
      Dec(vR);

    ExchangeItems(vL, vR);

    if Pivot = vL then // swap pivot if we just hit it from one side
      Pivot := vR
    else if Pivot = vR then
      Pivot := vL;
  end;

  if Pivot - 1 >= L then
    QuickSort(L, Pivot - 1, CompareFn);
  if Pivot + 1 <= R then
    QuickSort(Pivot + 1, R, CompareFn);
end;


Procedure TStringList.InsertItem(Index: Integer; const S: string);
begin
  Changing;
  If FCount=Fcapacity then Grow;
  If Index<FCount then
    System.Move (FList^[Index],FList^[Index+1],
                 (FCount-Index)*SizeOf(TStringItem));
  Pointer(Flist^[Index].Fstring):=Nil;  // Needed to initialize...
  Flist^[Index].FString:=S;
  Flist^[Index].Fobject:=Nil;
  Inc(FCount);
  Changed;
end;


Procedure TStringList.InsertItem(Index: Integer; const S: string; O: TObject);
begin
  Changing;
  If FCount=Fcapacity then Grow;
  If Index<FCount then
    System.Move (FList^[Index],FList^[Index+1],
                 (FCount-Index)*SizeOf(TStringItem));
  Pointer(Flist^[Index].Fstring):=Nil;  // Needed to initialize...
  Flist^[Index].FString:=S;
  Flist^[Index].FObject:=O;
  Inc(FCount);
  Changed;
end;


Procedure TStringList.SetSorted(Value: Boolean);

begin
  If FSorted<>Value then
    begin
    If Value then sort;
    FSorted:=VAlue
    end;
end;



Procedure TStringList.Changed;

begin
  If (FUpdateCount=0) Then
   begin
   If Assigned(FOnChange) then
     FOnchange(Self);
//   FPONotifyObservers(Self,ooChange,Nil);
   end;
end;



Procedure TStringList.Changing;

begin
  If FUpdateCount=0 then
    if Assigned(FOnChanging) then
      FOnchanging(Self);
end;



Function TStringList.Get(Index: Integer): string;

begin
  If (Index<0) or (INdex>=Fcount)  then
    Error (SListIndexError,Index);
  Result:=Flist^[Index].FString;
end;



Function TStringList.GetCapacity: Integer;

begin
  Result:=FCapacity;
end;



Function TStringList.GetCount: Integer;

begin
  Result:=FCount;
end;



Function TStringList.GetObject(Index: Integer): TObject;

begin
  If (Index<0) or (INdex>=Fcount)  then
    Error (SListIndexError,Index);
  Result:=Flist^[Index].FObject;
end;



Procedure TStringList.Put(Index: Integer; const S: string);

begin
  If Sorted then
    Error(SSortedListError,0);
  If (Index<0) or (INdex>=Fcount)  then
    Error (SListIndexError,Index);
  Changing;
  Flist^[Index].FString:=S;
  Changed;
end;



Procedure TStringList.PutObject(Index: Integer; AObject: TObject);

begin
  If (Index<0) or (INdex>=Fcount)  then
    Error (SListIndexError,Index);
  Changing;
  Flist^[Index].FObject:=AObject;
  Changed;
end;



Procedure TStringList.SetCapacity(NewCapacity: Integer);

Var NewList : Pointer;
    MSize : Longint;

begin
  If (NewCapacity<0) then
     Error (SListCapacityError,NewCapacity);
  If NewCapacity>FCapacity then
    begin
    GetMem (NewList,NewCapacity*SizeOf(TStringItem));
    If NewList=Nil then
      Error (SListCapacityError,NewCapacity);
    If Assigned(FList) then
      begin
      MSize:=FCapacity*Sizeof(TStringItem);
      System.Move (FList^,NewList^,MSize);
    {$ifdef FPC}
      FillWord (Pchar(NewList)[MSize],(NewCapacity-FCapacity)*WordRatio, 0);
    {$else}
      Fillchar(Pchar(NewList)[MSize],(NewCapacity-FCapacity)*sizeof(pointer),0);
    {$endif}
      FreeMem (Flist,MSize);
      end;
    Flist:=NewList;
    FCapacity:=NewCapacity;
    end
  else if NewCapacity<FCapacity then
    begin
    if NewCapacity = 0 then
    begin
      FreeMem(FList);
      FList := nil;
    end else
    begin
      GetMem(NewList, NewCapacity * SizeOf(TStringItem));
      System.Move(FList^, NewList^, NewCapacity * SizeOf(TStringItem));
      FreeMem(FList);
      FList := NewList;
    end;
    FCapacity:=NewCapacity;
    end;
end;



Procedure TStringList.SetUpdateState(Updating: Boolean);

begin
  If Updating then
    Changing
  else
    Changed
end;



destructor TStringList.Destroy;

begin
  InternalClear;
  Inherited destroy;
end;



Function TStringList.Add(const S: string): Integer;

begin
  If Not Sorted then
    Result:=FCount
  else
    If Find (S,Result) then
      Case DUplicates of
        DupIgnore : Exit;
        DupError : Error(SDuplicateString,0)
      end;
   InsertItem (Result,S);
end;

Procedure TStringList.Clear;

begin
  if FCount = 0 then Exit;
  Changing;
  InternalClear;
  Changed;
end;

Procedure TStringList.Delete(Index: Integer);

begin
  If (Index<0) or (Index>=FCount) then
    Error(SlistINdexError,Index);
  Changing;
  Flist^[Index].FString:='';
  if FOwnsObjects then
    FreeAndNil(Flist^[Index].FObject);
  Dec(FCount);
  If Index<FCount then
    System.Move(Flist^[Index+1],
                Flist^[Index],
                (Fcount-Index)*SizeOf(TStringItem));
  Changed;
end;



Procedure TStringList.Exchange(Index1, Index2: Integer);

begin
  If (Index1<0) or (Index1>=FCount) then
    Error(SListIndexError,Index1);
  If (Index2<0) or (Index2>=FCount) then
    Error(SListIndexError,Index2);
  Changing;
  ExchangeItems(Index1,Index2);
  changed;
end;


procedure TStringList.SetCaseSensitive(b : boolean);
  begin
        if b<>FCaseSensitive then
          begin
                FCaseSensitive:=b;
            if FSorted then
              sort;
          end;
  end;


Function TStringList.DoCompareText(const s1,s2 : string) : PtrInt;
  begin
        if FCaseSensitive then
          result:=AnsiCompareStr(s1,s2)
        else
          result:=AnsiCompareText(s1,s2);
  end;


Function TStringList.Find(const S: string; Out Index: Integer): Boolean;

var
  L, R, I: Integer;
  CompareRes: PtrInt;
begin
  Result := false;
  // Use binary search.
  L := 0;
  R := Count - 1;
  while (L<=R) do
  begin
    I := L + (R - L) div 2;
    CompareRes := DoCompareText(S, Flist^[I].FString);
    if (CompareRes>0) then
      L := I+1
    else begin
      R := I-1;
      if (CompareRes=0) then begin
         Result := true;
         if (Duplicates<>dupAccept) then
            L := I; // forces end of while loop
      end;
    end;
  end;
  Index := L;
end;



Function TStringList.IndexOf(const S: string): Integer;

begin
  If Not Sorted then
    Result:=Inherited indexOf(S)
  else
    // faster using binary search...
    If Not Find (S,Result) then
      Result:=-1;
end;



Procedure TStringList.Insert(Index: Integer; const S: string);

begin
  If Sorted then
    Error (SSortedListError,0)
  else
    If (Index<0) or (Index>FCount) then
      Error (SListIndexError,Index)
    else
      InsertItem (Index,S);
end;


Procedure TStringList.CustomSort(CompareFn: TStringListSortCompare);

begin
  If Not Sorted and (FCount>1) then
    begin
    Changing;
    QuickSort(0,FCount-1, CompareFn);
    Changed;
    end;
end;

function StringListAnsiCompare(List: TStringList; Index1, Index: Integer): Integer;

begin
  Result := List.DoCompareText(List.FList^[Index1].FString,
    List.FList^[Index].FString);
end;

Procedure TStringList.Sort;

begin
  CustomSort(@StringListAnsiCompare);
end;

{****************************************************************************}
{*                             TStream                                      *}
{****************************************************************************}

procedure TStream.ReadNotImplemented;
begin
  raise EStreamError.CreateFmt(SStreamNoReading, [ClassName])
                       {$ifdef FPC}  at get_caller_addr(get_frame){$endif};
end;

procedure TStream.WriteNotImplemented;
begin
  raise EStreamError.CreateFmt(SStreamNoWriting, [ClassName])
                       {$ifdef FPC}  at get_caller_addr(get_frame){$endif};
end;

function TStream.Read(var Buffer; Count: Longint): Longint;
begin
  ReadNotImplemented;
  Result := 0;
end;

function TStream.Write(const Buffer; Count: Longint): Longint;
begin
  WriteNotImplemented;
  Result := 0;
end;


  function TStream.GetPosition: Int64;

    begin
       Result:=Seek(0,soCurrent);
    end;

  procedure TStream.SetPosition(const Pos: Int64);

    begin
       Seek(pos,soBeginning);
    end;

  procedure TStream.SetSize64(const NewSize: Int64);

    begin
      // Required because can't use overloaded functions in properties
      SetSize(NewSize);
    end;

  function TStream.GetSize: Int64;

    var
       p : int64;

    begin
       p:=Seek(0,soCurrent);
       GetSize:=Seek(0,soEnd);
       Seek(p,soBeginning);
    end;

  procedure TStream.SetSize(NewSize: Longint);

    begin
    // We do nothing. Pipe streams don't support this
    // As wel as possible read-ony streams !!
    end;

  procedure TStream.SetSize(const NewSize: Int64);

    begin
      // Backwards compatibility that calls the longint SetSize
      if (NewSize<Low(longint)) or
         (NewSize>High(longint)) then
        raise ERangeError.Create(SRangeError);
      SetSize(longint(NewSize));
    end;

  function TStream.Seek(Offset: Longint; Origin: Word): Longint;

    type
      TSeek64 = function(const offset:Int64;Origin:TSeekorigin):Int64 of object;
    var
      CurrSeek,
      TStreamSeek : TSeek64;
      CurrClass   : TClass;
    begin
      // Redirect calls to 64bit Seek, but we can't call the 64bit Seek
      // from TStream, because then we end up in an infinite loop
      CurrSeek:=nil;
      CurrClass:=Classtype;
      while (CurrClass<>nil) and
            (CurrClass<>TStream) do
       CurrClass:=CurrClass.Classparent;
      if CurrClass<>nil then
       begin
         CurrSeek:= {$ifdef FPC}@{$endif}Self.Seek;
         TStreamSeek:={$ifdef FPC}@{$endif}TStream(@CurrClass).Seek;
         if TMethod(TStreamSeek).Code=TMethod(CurrSeek).Code then
          CurrSeek:=nil;
       end;
      if {$ifndef FPC}@{$endif}CurrSeek <> nil then
       Result:=Seek(Int64(offset),TSeekOrigin(origin))
      else
       raise EStreamError.CreateFmt(SSeekNotImplemented,[ClassName]);
    end;

  procedure TStream.Discard(const Count: Int64);

  const
    CSmallSize      =255;
    CLargeMaxBuffer =32*1024; // 32 KiB
  var
    Buffer: array[1..CSmallSize] of Byte;

  begin
    if Count=0 then
      Exit;
    if Count<=SizeOf(Buffer) then
      ReadBuffer(Buffer,Count)
    else
      DiscardLarge(Count,CLargeMaxBuffer);
  end;

  procedure TStream.DiscardLarge(Count: int64; const MaxBufferSize: Longint);

  var
    Buffer: array of Byte;

  begin
    if Count=0 then
       Exit;
    if Count>MaxBufferSize then
      SetLength(Buffer,MaxBufferSize)
    else
      SetLength(Buffer,Count);
    while (Count>=Length(Buffer)) do
      begin
      ReadBuffer(Buffer[0],Length(Buffer));
      Dec(Count,Length(Buffer));
      end;
    if Count>0 then
      ReadBuffer(Buffer[0],Count);
  end;

  procedure TStream.InvalidSeek;

  begin
    raise EStreamError.CreateFmt(SStreamInvalidSeek, [ClassName])
                     {$ifdef FPC} at get_caller_addr(get_frame){$endif};
  end;

  procedure TStream.FakeSeekForward(Offset: Int64;  const Origin: TSeekOrigin; const Pos: Int64);

//  var
//    Buffer: Pointer;
//    BufferSize, i: LongInt;

  begin
    if Origin=soBeginning then
       Dec(Offset,Pos);
    if (Offset<0) or (Origin=soEnd) then
      InvalidSeek;
    if Offset>0 then
      Discard(Offset);
   end;

 function TStream.Seek(const Offset: Int64; Origin: TSeekorigin): Int64;

    begin
      // Backwards compatibility that calls the longint Seek
      if (Offset<Low(longint)) or
         (Offset>High(longint)) then
        raise ERangeError.Create(SRangeError);
      Result:=Seek(longint(Offset),ord(Origin));
    end;

function TStream.read(var buffer; const count: longint;
               out acount: longint): syserrorty;
var
 po1: pbyte;
 int1,int2: integer;
begin
 result:= sye_ok;
 int2:= count;
 po1:= @buffer;
 repeat
  int1:= read(po1^,int2);
  if int1 <= 0 then begin
   break;
  end;
  int2:= int2 - int1;
  inc(po1,int1);
 until int2 <= 0;
 acount:= count - int2;
 if int1 < 0 then begin
  result:= syelasterror;
 end
 else begin
  if (int2 > 0) then begin
   result:= sye_read;
  end;
 end;
end;

function TStream.tryreadbuffer(var buffer; count: longint): syserrorty;
var
 int1: integer;
begin
 result:= read(buffer,count,int1);
end;

procedure TStream.ReadBuffer(var Buffer; Count: Longint);
begin
 if tryreadbuffer(buffer,count) <> sye_ok then begin 
  Raise EReadError.Create(SReadError);
 end;
end;

function TStream.write(const buffer; const count: longint;
                                   out acount: longint): syserrorty;
var
 po1: pbyte;
 int1,int2: integer;
begin
 result:= sye_ok;
 int2:= count;
 po1:= @buffer;
 repeat
  int1:= write(po1^,int2);
  if int1 <= 0 then begin
   break;
  end;
  int2:= int2 - int1;
  inc(po1,int1);
 until int2 <= 0;
 acount:= count - int2;
 if int1 < 0 then begin
  result:= syelasterror;
 end
 else begin
  if (int2 > 0) then begin
   result:= sye_write;
  end;
 end;
end;

function TStream.trywritebuffer(const buffer; count: longint): syserrorty;
var
 int1: integer;
begin
 result:= write(buffer,count,int1);
end;

procedure TStream.WriteBuffer(const Buffer; Count: Longint);
begin
 if trywritebuffer(buffer,count) <> sye_ok then begin
  Raise EWriteError.Create(SWriteError);
 end;
end;

  function TStream.CopyFrom(Source: TStream; Count: Int64): Int64;

    var
       Buffer: Pointer;
       BufferSize, i: LongInt;

    const
       MaxSize = $20000;
    begin

       Result:=0;
       if Count=0 then
         Source.Position:=0;   // This WILL fail for non-seekable streams...
       BufferSize:=MaxSize;
       if (Count>0) and (Count<BufferSize) then
         BufferSize:=Count;    // do not allocate more than needed

       GetMem(Buffer,BufferSize);
       try
         if Count=0 then
         repeat
           i:=Source.Read(buffer^,BufferSize);
           if i>0 then
             WriteBuffer(buffer^,i);
           Inc(Result,i);
         until i<BufferSize
         else
         while Count>0 do
         begin
           if Count>BufferSize then
             i:=BufferSize
           else
             i:=Count;
           Source.ReadBuffer(buffer^,i);
           WriteBuffer(buffer^,i);
           Dec(count,i);
           Inc(Result,i);
         end;
       finally
         FreeMem(Buffer);
       end;

    end;

function TStream.readdatastring: string;
begin
 setlength(result,size-position);
 setlength(result,read(pointer(result)^,length(result)));
end;

procedure TStream.writedatastring(const value: string);
begin
 if value <> '' then begin
  writebuffer(pointer(value)^,length(value));
 end;
end;

  function TStream.ReadComponent(Instance: TComponent): TComponent;

    var
      Reader: TReader;

    begin

      Reader := TReader.Create(Self, 4096);
      try
        Result := Reader.ReadRootComponent(Instance);
      finally
        Reader.Free;
      end;

    end;

  function TStream.ReadComponentRes(Instance: TComponent): TComponent;

    begin

      ReadResHeader;
      Result := ReadComponent(Instance);

    end;

  procedure TStream.WriteComponent(Instance: TComponent);

    begin

      WriteDescendent(Instance, nil);

    end;

  procedure TStream.WriteComponentRes(const ResName: string; Instance: TComponent);

    begin

      WriteDescendentRes(ResName, Instance, nil);

    end;

  procedure TStream.WriteDescendent(Instance, Ancestor: TComponent);

    var
       Driver : TAbstractObjectWriter;
       Writer : TWriter;

    begin

       Driver := TBinaryObjectWriter.Create(Self, 4096);
       Try
         Writer := TWriter.Create(Driver);
         Try
           Writer.WriteDescendent(Instance, Ancestor);
         Finally
           Writer.Destroy;
         end;
       Finally
         Driver.Free;
       end;

    end;

  procedure TStream.WriteDescendentRes(const ResName: string; Instance, Ancestor: TComponent);

    var
      FixupInfo: Integer;

    begin

      { Write a resource header }
      WriteResourceHeader(ResName, FixupInfo);
      { Write the instance itself }
      WriteDescendent(Instance, Ancestor);
      { Insert the correct resource size into the resource header }
      FixupResourceHeader(FixupInfo);

    end;

  procedure TStream.WriteResourceHeader(const ResName: string; {!!!: out} var FixupInfo: Integer);
    var
      ResType, Flags : word;
    begin
       ResType:=NtoLE(word($000A));
       Flags:=NtoLE(word($1030));
       { Note: This is a Windows 16 bit resource }
       { Numeric resource type }
       WriteByte($ff);
       { Application defined data }
       WriteWord(ResType);
       { write the name as asciiz }
       WriteBuffer(ResName[1],length(ResName));
       WriteByte(0);
       { Movable, Pure and Discardable }
       WriteWord(Flags);
       { Placeholder for the resource size }
       WriteDWord(0);
       { Return current stream position so that the resource size can be
         inserted later }
       FixupInfo := Position;
    end;

  procedure TStream.FixupResourceHeader(FixupInfo: Integer);

    var
       ResSize,TmpResSize : Integer;

    begin

      ResSize := Position - FixupInfo;
      TmpResSize := NtoLE(longword(ResSize));

      { Insert the correct resource size into the placeholder written by
        WriteResourceHeader }
      Position := FixupInfo - 4;
      WriteDWord(TmpResSize);
      { Seek back to the end of the resource }
      Position := FixupInfo + ResSize;

    end;

  procedure TStream.ReadResHeader;
    var
      ResType, Flags : word;
    begin
       try
         { Note: This is a Windows 16 bit resource }
         { application specific resource ? }
         if ReadByte<>$ff then
           raise EInvalidImage.Create(SInvalidImage);
         ResType:=LEtoN(ReadWord);
         if ResType<>$000a then
           raise EInvalidImage.Create(SInvalidImage);
         { read name }
         while ReadByte<>0 do
           ;
         { check the access specifier }
         Flags:=LEtoN(ReadWord);
         if Flags<>$1030 then
           raise EInvalidImage.Create(SInvalidImage);
         { ignore the size }
         ReadDWord;
       except
         on EInvalidImage do
           raise;
         else
           raise EInvalidImage.create(SInvalidImage);
       end;
    end;

  function TStream.ReadByte : Byte;

    var
       b : Byte;

    begin
       ReadBuffer(b,1);
       ReadByte:=b;
    end;

  function TStream.ReadWord : Word;

    var
       w : Word;

    begin
       ReadBuffer(w,2);
       ReadWord:=w;
    end;

  function TStream.ReadDWord : Cardinal;

    var
       d : Cardinal;

    begin
       ReadBuffer(d,4);
       ReadDWord:=d;
    end;

  function TStream.ReadQWord: QWord;
    var
       q: QWord;
    begin
      ReadBuffer(q,8);
      ReadQWord:=q;

    end;

  Function TStream.ReadAnsiString : String;

  Var
    TheSize : Longint;
    P : PByte ;
  begin
    ReadBuffer (TheSize,SizeOf(TheSize));
    SetLength(Result,TheSize);
    // Illegal typecast if no AnsiStrings defined.
    if TheSize>0 then
     begin
       ReadBuffer (Pointer(Result)^,TheSize);
       P:= pointer(pchar(Pointer(Result))+TheSize);
       p^:=0;
     end;
   end;

  Procedure TStream.WriteAnsiString (const S : String);

  Var L : Longint;

  begin
    L:=Length(S);
    WriteBuffer (L,SizeOf(L));
    WriteBuffer (Pointer(S)^,L);
  end;

  procedure TStream.WriteByte(b : Byte);

    begin
       WriteBuffer(b,1);
    end;

  procedure TStream.WriteWord(w : Word);

    begin
       WriteBuffer(w,2);
    end;

  procedure TStream.WriteDWord(d : Cardinal);

    begin
       WriteBuffer(d,4);
    end;

  procedure TStream.WriteQWord(q: QWord);
    begin
      WriteBuffer(q,8);
    end;

function TStream.getmemory: pointer;
begin
 result:= nil;
end;


{****************************************************************************}
{*                             TCustomMemoryStream                          *}
{****************************************************************************}

procedure TCustomMemoryStream.SetPointer(Ptr: Pointer; ASize: PtrInt);

begin
  FMemory:=Ptr;
  FSize:=ASize;
end;


function TCustomMemoryStream.GetSize: Int64;

begin
  Result:=FSize;
end;

function TCustomMemoryStream.GetPosition: Int64;
begin
  Result:=FPosition;
end;


function TCustomMemoryStream.Read(var Buffer; Count: LongInt): LongInt;

begin
  Result:=0;
  If (FSize>0) and (FPosition<Fsize) and (FPosition>=0) then
    begin
    Result:=FSize-FPosition;
    If Result>Count then Result:=Count;
    Move ((pchar(FMemory)+FPosition)^,Buffer,Result);
    FPosition:=Fposition+Result;
    end;
end;


function TCustomMemoryStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;

begin
  Case Word(Origin) of
    soFromBeginning : FPosition:=Offset;
    soFromEnd       : FPosition:=FSize+Offset;
    soFromCurrent   : FPosition:=FPosition+Offset;
  end;
  Result:=FPosition;
  {$IFDEF DEBUG}
  if Result < 0 then
    raise Exception.Create('TCustomMemoryStream');
  {$ENDIF}
end;


procedure TCustomMemoryStream.SaveToStream(Stream: TStream);

begin
  if FSize>0 then Stream.WriteBuffer (FMemory^,FSize);
end;


procedure TCustomMemoryStream.SaveToFile(const FileName: string);

Var S : TFileStream;

begin
  S:=TFileStream.Create (FileName,fmCreate);
  Try
    SaveToStream(S);
  finally
    S.free;
  end;
end;

function TCustomMemoryStream.getmemory: pointer;
begin
 result:= fmemory;
end;

{****************************************************************************}
{*                             TMemoryStream                                *}
{****************************************************************************}


Const TMSGrow = 4096; { Use 4k blocks. }

procedure TMemoryStream.SetCapacity(NewCapacity: PtrInt);

begin
  SetPointer (Realloc(NewCapacity),Fsize);
  FCapacity:=NewCapacity;
end;


function TMemoryStream.Realloc(var NewCapacity: PtrInt): Pointer;

begin
  If NewCapacity<0 Then
    NewCapacity:=0
  else
    begin
      // if growing, grow at least a quarter
      if (NewCapacity>FCapacity) and (NewCapacity < (5*FCapacity) div 4) then
        NewCapacity := (5*FCapacity) div 4;
      // round off to block size.
      NewCapacity := (NewCapacity + (TMSGrow-1)) and not (TMSGROW-1);
    end;
  // Only now check !
  If NewCapacity=FCapacity then
    Result:=FMemory
  else
    begin
    {$ifdef FPC}
      Result:= Reallocmem(FMemory,Newcapacity);
    {$else}
      Reallocmem(FMemory,Newcapacity);
      result:= fmemory;
    {$endif}
      If (Result=Nil) and (Newcapacity>0) then
        Raise EStreamError.Create(SMemoryStreamError);
    end;
end;


destructor TMemoryStream.Destroy;

begin
  Clear;
  Inherited Destroy;
end;


procedure TMemoryStream.Clear;

begin
  FSize:=0;
  FPosition:=0;
  SetCapacity (0);
end;


procedure TMemoryStream.LoadFromStream(Stream: TStream);

begin
  Stream.Position:=0;
  SetSize(Stream.Size);
  If FSize>0 then Stream.ReadBuffer(FMemory^,FSize);
end;


procedure TMemoryStream.LoadFromFile(const FileName: string);

Var S : TFileStream;

begin
  S:=TFileStream.Create (FileName,fmOpenRead or fmShareDenyWrite);
  Try
    LoadFromStream(S);
  finally
    S.free;
  end;
end;


procedure TMemoryStream.SetSize({$ifdef CPU64}const{$endif CPU64} NewSize: PtrInt);

begin
  SetCapacity (NewSize);
  FSize:=NewSize;
  IF FPosition>FSize then
    FPosition:=FSize;
end;

function TMemoryStream.Write(const Buffer; Count: LongInt): LongInt;

Var NewPos : PtrInt;

begin
  If (Count=0) or (FPosition<0) then begin
   result:= 0;
   exit;
  end;
  NewPos:=FPosition+Count;
  If NewPos>Fsize then
    begin
    IF NewPos>FCapacity then
      SetCapacity (NewPos);
    FSize:=Newpos;
    end;
  System.Move (Buffer,(pchar(FMemory)+FPosition)^,Count);
  FPosition:=NewPos;
  Result:=Count;
end;

{****************************************************************************}
{*                       TBinaryObjectReader                                *}
{****************************************************************************}

{$ifndef FPUNONE}
{$IFNDEF FPC_HAS_TYPE_EXTENDED}
function ExtendedToDouble(e : pointer) : double;
var mant : qword;
    exp : smallint;
    sign : boolean;
    d : qword;
begin
  move(pbyte(e)[0],mant,8); //mantissa         : bytes 0..7
  move(pbyte(e)[8],exp,2);  //exponent and sign: bytes 8..9
  mant:=LEtoN(mant);
  exp:=LEtoN(word(exp));
  sign:=(exp and $8000)<>0;
  if sign then begin 
   exp:=exp and $7FFF;
  end;
  case exp of
   0: begin
    mant:= 0;  //if denormalized, value is too small for double,
                      //so it's always zero
   end;
   $7FFF: begin
    exp:=2047; //either infinity or NaN
    if mant and $3fffffffffffffff = 0 then begin
     mant:= 0;     //infinity
    end;
   end
   else begin
    dec(exp,16383-1023);
    if (exp>=-51) and (exp<=0) then begin //can be denormalized
     mant:=mant shr (-exp);
     exp:=0;
    end
    else begin
     if (exp<-51) or (exp>2046) then begin //exponent too large.
      Result:=0;
      exit;
     end
     else begin //normalized value
      mant:=mant shl 1; //hide most significant bit
     end;
    end;
   end;
  end;
  d:=word(exp);
  d:=d shl 52;

  mant:=mant shr 12;
  d:=d or mant;
  if sign then d:=d or $8000000000000000;
  Result:=pdouble(@d)^;
end;
{$ENDIF}
{$endif}

function TBinaryObjectReader.ReadWord : word; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
begin
  Read(Result,2);
  Result:=LEtoN(Result);
end;

function TBinaryObjectReader.ReadDWord : longword; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
begin
  Read(Result,4);
  Result:=LEtoN(Result);
end;

function TBinaryObjectReader.ReadQWord : qword; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
begin
  Read(Result,8);
 {$ifdef FPC}
  Result:=LEtoN(Result);
 {$endif}
end;

{$IFDEF FPC_DOUBLE_HILO_SWAPPED}
procedure SwapDoubleHiLo(var avalue: double); {$ifdef CLASSESINLINE}inline{$endif CLASSESINLINE}
var dwo1 : dword;
type tdoublerec = array[0..1] of dword;
begin
  dwo1:= tdoublerec(avalue)[0];
  tdoublerec(avalue)[0]:=tdoublerec(avalue)[1];
  tdoublerec(avalue)[1]:=dwo1;
end;
{$ENDIF FPC_DOUBLE_HILO_SWAPPED}

{$ifndef FPUNONE}
function TBinaryObjectReader.ReadExtended : extended;
                           {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$IFNDEF FPC_HAS_TYPE_EXTENDED}
var ext : array[0..9] of byte;
{$ENDIF}
begin
  {$IFNDEF FPC_HAS_TYPE_EXTENDED}
  Read(ext[0],10);
  Result:=ExtendedToDouble(@(ext[0]));
  {$IFDEF FPC_DOUBLE_HILO_SWAPPED}
  SwapDoubleHiLo(result);
  {$ENDIF}
  {$ELSE}
  Read(Result,sizeof(Result));
  {$ENDIF}
end;
{$endif}

constructor TBinaryObjectReader.Create(Stream: TStream; BufSize: Integer);
begin
  inherited Create;
  If (Stream=Nil) then
    Raise EReadError.Create(SEmptyStreamIllegalReader);
  FStream := Stream;
  FBufSize := BufSize;
  GetMem(FBuffer, BufSize);
end;

destructor TBinaryObjectReader.Destroy;
begin
  { Seek back the amount of bytes that we didn't process until now: }
  FStream.Seek(Integer(FBufPos) - Integer(FBufEnd), soFromCurrent);

  if Assigned(FBuffer) then
    FreeMem(FBuffer, FBufSize);

  inherited Destroy;
end;

function TBinaryObjectReader.ReadValue: TValueType;
var
  b: byte;
begin
  Read(b, 1);
  Result := TValueType(b);
end;

function TBinaryObjectReader.NextValue: TValueType;
begin
  Result := ReadValue;
  { We only 'peek' at the next value, so seek back to unget the read value: }
  Dec(FBufPos);
end;

procedure TBinaryObjectReader.BeginRootComponent;
var
  Signature: LongInt;
begin
  { Read filer signature }
  Read(Signature, 4);
  {$ifdef FPC}
  if Signature <> LongInt(unaligned(FilerSignature)) then
  {$else}
  if Signature <> LongInt(FilerSignature) then
  {$endif}
    raise EReadError.Create(SInvalidImage);
end;

procedure TBinaryObjectReader.BeginComponent(var Flags: TFilerFlags;
  var AChildPos: Integer; var CompClassName, CompName: String);
var
  Prefix: Byte;
  ValueType: TValueType;
begin
  { Every component can start with a special prefix: }
  Flags := [];
  if (Byte(NextValue) and $f0) = $f0 then
  begin
    Prefix := Byte(ReadValue);
    Flags := TFilerFlags({$ifdef FPC}longword{$else}byte{$endif}(Prefix and $0f));
    if ffChildPos in Flags then
    begin
      ValueType := ReadValue;
      case ValueType of
        vaInt8:
          AChildPos := ReadInt8;
        vaInt16:
          AChildPos := ReadInt16;
        vaInt32:
          AChildPos := ReadInt32;
        else
          raise EReadError.Create(SInvalidPropertyValue);
      end;
    end;
  end;

  CompClassName := ReadStr;
  CompName := ReadStr;
end;

function TBinaryObjectReader.BeginProperty: String;
begin
  Result := ReadStr;
end;

procedure TBinaryObjectReader.ReadBinary(const DestData: TMemoryStream);
var
  BinSize: LongInt;
begin
  BinSize:=LongInt(ReadDWord);
  DestData.Size := BinSize;
  Read(DestData.Memory^, BinSize);
end;

{$ifndef FPUNONE}
function TBinaryObjectReader.ReadFloat: Extended;
begin
  Result:= ReadExtended;
end;

function TBinaryObjectReader.ReadSingle: Single;
begin
{$ifdef FPC}
  Result:= single(ReadDWord);
{$else}
  Result:= single(ar4ty(ReadDWord()));
{$endif}
end;
{$endif}

function TBinaryObjectReader.ReadCurrency: Currency;
begin
 {$ifdef FPC}
  Result:=currency(ReadQWord);
 {$else}
  Result:=currency(ar8ty(ReadQWord()));
 {$endif}
end;

{$ifndef FPUNONE}
function TBinaryObjectReader.ReadDate: TDateTime;
begin
 {$ifdef FPC}
  Result:= TDateTime(ReadQWord);
 {$else}
  Result:= TDateTime(ar8ty(ReadQWord()));
 {$endif}
end;
{$endif}

function TBinaryObjectReader.ReadIdent(ValueType: TValueType): String;
var
  i: Byte;
begin
  case ValueType of
    vaIdent:
      begin
        Read(i, 1);
        SetLength(Result, i);
        Read(Pointer(@Result[1])^, i);
      end;
    vaNil:
      Result := 'nil';
    vaFalse:
      Result := 'False';
    vaTrue:
      Result := 'True';
    vaNull:
      Result := 'Null';
  end;
end;

function TBinaryObjectReader.ReadInt8: ShortInt;
begin
  Read(Result, 1);
end;

function TBinaryObjectReader.ReadInt16: SmallInt;
begin
  Result:=SmallInt(ReadWord);
end;

function TBinaryObjectReader.ReadInt32: LongInt;
begin
  Result:=LongInt(ReadDWord);
end;

function TBinaryObjectReader.ReadInt64: Int64;
begin
  Result:=Int64(ReadQWord);
end;

function TBinaryObjectReader.ReadSet(EnumType: ptypeinfo): Integer;
type
  tset = set of 0..31;
var
  Name: String;
  Value: Integer;
begin
  try
    Result := 0;
    while True do
    begin
      Name := ReadStr;
      if Length(Name) = 0 then
        break;
      Value := GetEnumValue(PTypeInfo(EnumType), Name);
      if Value = -1 then begin
       if (freader <> nil) and assigned(freader.fonseterror) then begin
        freader.fonseterror(freader,enumtype,name,value);
       end;
       if value = -1 then begin
        raise EReadError.Create(SInvalidPropertyValue);
       end
       else begin
        if value = -2 then begin
         continue; //skip
        end;
       end;
      end;
      include(tset(result),Value);
    end;
  except
    SkipSetBody;
    raise;
  end;
end;

function TBinaryObjectReader.ReadStr: String;
var
  i: Byte;
begin
  Read(i, 1);
  SetLength(Result, i);
  if i > 0 then
    Read(Pointer(@Result[1])^, i);
end;

function TBinaryObjectReader.ReadString(StringType: TValueType): String;
var
  b: Byte;
  i: Integer;
begin
  case StringType of
    vaLString, vaUTF8String:
      i:=ReadDWord;
    else
    //vaString:
      begin
        Read(b, 1);
        i := b;
      end;
  end;
  SetLength(Result, i);
  if i > 0 then
    Read(Pointer(@Result[1])^, i);
end;


function TBinaryObjectReader.ReadWideString: WideString;
var
  len: DWord;
{$IFDEF ENDIAN_BIG}
  i : integer;
{$ENDIF}
begin
  len := ReadDWord;
  SetLength(Result, len);
  if (len > 0) then
  begin
    Read(Pointer(@Result[1])^, len*2);
    {$IFDEF ENDIAN_BIG}
    for i:=1 to len do
      Result[i]:=widechar(SwapEndian(word(Result[i])));
    {$ENDIF}
  end;
end;

function TBinaryObjectReader.ReadUnicodeString: UnicodeString;
var
  len: DWord;
{$IFDEF ENDIAN_BIG}
  i : integer;
{$ENDIF}
begin
  len := ReadDWord;
  SetLength(Result, len);
  if (len > 0) then
  begin
    Read(Pointer(@Result[1])^, len*2);
    {$IFDEF ENDIAN_BIG}
    for i:=1 to len do
      Result[i]:=UnicodeChar(SwapEndian(word(Result[i])));
    {$ENDIF}
  end;
end;

procedure TBinaryObjectReader.SkipComponent(SkipComponentInfos: Boolean);
var
  Flags: TFilerFlags;
  Dummy: Integer;
  CompClassName, CompName: String;
begin
  if SkipComponentInfos then
    { Skip prefix, component class name and component object name }
    BeginComponent(Flags, Dummy, CompClassName, CompName);

  { Skip properties }
  while NextValue <> vaNull do
    SkipProperty;
  ReadValue;

  { Skip children }
  while NextValue <> vaNull do
    SkipComponent(True);
  ReadValue;
end;

procedure TBinaryObjectReader.SkipValue;

  procedure SkipBytes(Count: LongInt);
  var
    Dummy: array[0..1023] of Byte;
    SkipNow: Integer;
  begin
    while Count > 0 do
    begin
      if Count > 1024 then
        SkipNow := 1024
      else
        SkipNow := Count;
      Read(Dummy, SkipNow);
      Dec(Count, SkipNow);
    end;
  end;

var
  Count: LongInt;
begin
  case ReadValue of
    vaNull, vaFalse, vaTrue, vaNil: ;
    vaList:
      begin
        while NextValue <> vaNull do
          SkipValue;
        ReadValue;
      end;
    vaInt8:
      SkipBytes(1);
    vaInt16:
      SkipBytes(2);
    vaInt32:
      SkipBytes(4);
    vaExtended:
      SkipBytes(10);
    vaString, vaIdent:
      ReadStr;
    vaBinary, vaLString:
      begin
        Count:=LongInt(ReadDWord);
        SkipBytes(Count);
      end;
    vaWString:
      begin
        Count:=LongInt(ReadDWord);
        SkipBytes(Count*sizeof(widechar));
      end;
{$ifdef FPC}
    vaUString:
      begin
        Count:=LongInt(ReadDWord);
        SkipBytes(Count*sizeof(widechar));
      end;
{$endif}
    vaSet:
      SkipSetBody;
    vaCollection:
      begin
        while NextValue <> vaNull do
        begin
          { Skip the order value if present }
          if NextValue in [vaInt8, vaInt16, vaInt32] then
            SkipValue;
          SkipBytes(1);
          while NextValue <> vaNull do
            SkipProperty;
          ReadValue;
        end;
        ReadValue;
      end;
    vaSingle:
{$ifndef FPUNONE}
      SkipBytes(Sizeof(Single));
{$else}
      SkipBytes(4);
{$endif}
    {!!!: vaCurrency:
      SkipBytes(SizeOf(Currency));}
    vaDate, vaInt64:
      SkipBytes(8);
  end;
end;

{ private methods }

procedure TBinaryObjectReader.Read(var Buf; Count: LongInt);
var
  CopyNow: LongInt;
  Dest: Pointer;
begin
  Dest := @Buf;
  while Count > 0 do
  begin
    if FBufPos >= FBufEnd then
    begin
      FBufEnd := FStream.Read(FBuffer^, FBufSize);
      if FBufEnd = 0 then
        raise EReadError.Create(SReadError);
      FBufPos := 0;
    end;
    CopyNow := FBufEnd - FBufPos;
    if CopyNow > Count then
      CopyNow := Count;
    Move(PChar(FBuffer)[FBufPos], Dest^, CopyNow);
    Inc(FBufPos, CopyNow);
    Inc(pchar(Dest), CopyNow);
    Dec(Count, CopyNow);
  end;
end;

procedure TBinaryObjectReader.SkipProperty;
begin
  { Skip property name, then the property value }
  ReadStr;
  SkipValue;
end;

procedure TBinaryObjectReader.SkipSetBody;
begin
  while Length(ReadStr) > 0 do;
end;

{ Object filing routines }

var
  IntConstList: TThreadList;

type
  TIntConst = class
    IntegerType: PTypeInfo;             // The integer type RTTI pointer
    IdentToIntFn: TIdentToInt;          // Identifier to Integer conversion
    IntToIdentFn: TIntToIdent;          // Integer to Identifier conversion
    constructor Create(AIntegerType: PTypeInfo; AIdentToInt: TIdentToInt;
      AIntToIdent: TIntToIdent);
  end;

constructor TIntConst.Create(AIntegerType: PTypeInfo; AIdentToInt: TIdentToInt;
  AIntToIdent: TIntToIdent);
begin
  IntegerType := AIntegerType;
  IdentToIntFn := AIdentToInt;
  IntToIdentFn := AIntToIdent;
end;

procedure RegisterIntegerConsts(IntegerType: Pointer; IdentToIntFn: TIdentToInt;
  IntToIdentFn: TIntToIdent);
begin
  IntConstList.Add(TIntConst.Create(IntegerType, IdentToIntFn, IntToIdentFn));
end;

function FindIntToIdent(AIntegerType: Pointer): TIntToIdent;
var
  i: Integer;
begin
  with IntConstList.LockList do
  try
    for i := 0 to Count - 1 do
      if TIntConst(Items[i]).IntegerType = AIntegerType then begin
       result:= TIntConst(Items[i]).IntToIdentFn;
       exit;
      end;
    Result := nil;
  finally
    IntConstList.UnlockList;
  end;
end;

function FindIdentToInt(AIntegerType: Pointer): TIdentToInt;
var
  i: Integer;
begin
  with IntConstList.LockList do
  try
    for i := 0 to Count - 1 do
      with TIntConst(Items[I]) do
        if TIntConst(Items[I]).IntegerType = AIntegerType then begin
         result:= IdentToIntFn;
         exit;
        end;
    Result := nil;
  finally
    IntConstList.UnlockList;
  end;
end;

function IdentToInt(const Ident: String; var Int: LongInt;
  const Map: array of TIdentMapEntry): Boolean;
var
  i: Integer;
begin
  for i := Low(Map) to High(Map) do
    if CompareText(Map[i].Name, Ident) = 0 then
    begin
      Int := Map[i].Value;
      result:= true;
      exit;
    end;
  Result := False;
end;

function IntToIdent(Int: LongInt; var Ident: String;
  const Map: array of TIdentMapEntry): Boolean;
var
  i: Integer;
begin
  for i := Low(Map) to High(Map) do
    if Map[i].Value = Int then
    begin
      Ident := Map[i].Name;
      result:= true;
      exit;
    end;
  Result := False;
end;

function GlobalIdentToInt(const Ident: String; var Int: LongInt):boolean;
var
  i : Integer;
begin
  with IntConstList.LockList do
    try
      for i := 0 to Count - 1 do
        if TIntConst(Items[I]).IdentToIntFn(Ident, Int) then begin
         result:= true;
         Exit;
        end;
      Result := false;
    finally
      IntConstList.UnlockList;
    end;
end;

Var
  InitHandlerList : TList;
  FindGlobalComponentList : TList;

Type
  TInitHandler = Class(TObject)
    AHandler : TInitComponentHandler;
    AClass : TComponentClass;
  end;
{$ifdef FPC}
function CreateComponentfromRes(const res : string;Inst : THandle;var Component : TComponent) : Boolean;
  var
    ResStream : TResourceStream;
  begin
    result:=true;

    if Inst=0 then
      Inst:=HInstance;

    try
      ResStream:=TResourceStream.Create(Inst,res,RT_RCDATA);
      try
        Component:=ResStream.ReadComponent(Component);
      finally
        ResStream.Free;
      end;
    except
      on EResNotFound do
        result:=false;
    end;
  end;
{$endif}

function DefaultInitHandler(Instance: TComponent; RootAncestor: TClass): Boolean;

  function doinit(_class : TClass) : boolean;
    begin
      result:=false;
      if (_class{.ClassType}=TComponent) or (_class{.ClassType}=RootAncestor) then
        exit;
      result:=doinit(_class.ClassParent);
  {$ifdef FPC}
      result:=CreateComponentfromRes(_class.ClassName,0,Instance) or result;
  {$endif}
    end;

  begin
    GlobalNameSpace.BeginWrite;
    try
      result:=doinit(Instance.ClassType);
    finally
      GlobalNameSpace.EndWrite;
    end;
  end;

function InitInheritedComponent(Instance: TComponent; RootAncestor: TClass): Boolean;
Var
  I : Integer;
begin
  I:=0;
  if not Assigned(InitHandlerList) then begin
    Result := True;
    Exit;
  end;
  Result:=False;
  With InitHandlerList do
    begin
    I:=0;
    // Instance is the normally the lowest one, so that one should be used when searching.
    While Not result and (I<Count) do
      begin
      If (Instance.InheritsFrom(TInitHandler(Items[i]).AClass)) then
        Result:=TInitHandler(Items[i]).AHandler(Instance,RootAncestor);
      Inc(I);
      end;
    end;
end;

function InitComponentRes(const ResName: String; Instance: TComponent): Boolean;

begin
  { !!!: Too Win32-specific }
  InitComponentRes := False;
end;

function ReadComponentRes(const ResName: String; Instance: TComponent): TComponent;

begin
  { !!!: Too Win32-specific }
  ReadComponentRes := nil;
end;

function ReadComponentResEx(HInstance: THandle; const ResName: String): TComponent;

begin
  { !!!: Too Win32-specific in VCL }
  ReadComponentResEx := nil;
end;

function ReadComponentResFile(const FileName: String; Instance: TComponent): TComponent;
var
  FileStream: TStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead {!!!:or fmShareDenyWrite});
  try
    Result := FileStream.ReadComponentRes(Instance);
  finally
    FileStream.Free;
  end;
end;

procedure WriteComponentResFile(const FileName: String; Instance: TComponent);
var
  FileStream: TStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    FileStream.WriteComponentRes(Instance.ClassName, Instance);
  finally
    FileStream.Free;
  end;
end;

procedure RegisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
  begin
    if not(assigned(FindGlobalComponentList)) then
      FindGlobalComponentList:=TList.Create;
    if FindGlobalComponentList.IndexOf(
     Pointer({$ifndef FPC}@{$endif}AFindGlobalComponent))<0 then
      FindGlobalComponentList.Add(
         Pointer({$ifndef FPC}@{$endif}AFindGlobalComponent));
  end;

procedure UnregisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
  begin
    if assigned(FindGlobalComponentList) then
      FindGlobalComponentList.Remove(
              Pointer({$ifndef FPC}@{$endif}AFindGlobalComponent));
  end;

function FindGlobalComponent(const Name: string): TComponent;
  var
  	i : sizeint;
  begin
    result:=nil;
    if assigned(FindGlobalComponentList) then
      begin
      	for i:=FindGlobalComponentList.Count-1 downto 0 do
      	  begin
      	    result:=TFindGlobalComponent(FindGlobalComponentList[i])(name);
      	    if assigned(result) then
      	      break;
      	  end;
      end;
  end;

procedure RegisterInitComponentHandler(ComponentClass: TComponentClass;   Handler: TInitComponentHandler);
Var
  I : Integer;
  H: TInitHandler;
begin
  If (InitHandlerList=Nil) then
    InitHandlerList:=TList.Create;
  H:=TInitHandler.Create;
  H.Aclass:=ComponentClass;
  H.AHandler:=Handler;
  try
    With InitHandlerList do
      begin
        I:=0;
        While (I<Count) and not H.AClass.InheritsFrom(TInitHandler(Items[I]).AClass) do
          Inc(I);
        { override? }
        if (I<Count) and (TInitHandler(Items[I]).AClass=H.AClass) then
          begin
            TInitHandler(Items[I]).AHandler:=Handler;
            H.Free;
          end
        else
          InitHandlerList.Insert(I,H);
      end;
   except
     H.Free;
     raise;
  end;
end;


type
  // Quadruple representing an unresolved component property.

  { TUnresolvedReference }

  TUnresolvedReference = class(TlinkedListItem)
  Private
    FRoot: TComponent;     // Root component when streaming
    FPropInfo: PPropInfo;  // Property to set.
    FGlobal,               // Global component.
    FRelative : string;    // Path relative to global component.
    Function Resolve(Instance : TPersistent) : Boolean; // Resolve this reference
    Function RootMatches(ARoot : TComponent) : Boolean; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE} // True if Froot matches or ARoot is nil.
    Function NextRef : TUnresolvedReference; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
  end;

  tfixups = class(tlinkedlist)
   public
    constructor create; reintroduce;
    function newreference(const aprop: ppropinfo): TUnResolvedReference;
  end;
  
  TLocalUnResolvedReference = class(TUnresolvedReference)
    Finstance : TPersistent;
  end;
 
  tlocalfixups = class(tlinkedlist)
   public
    constructor create; reintroduce;
    function newreference(const ainstance: tpersistent;
                       const aprop: ppropinfo): TLocalUnResolvedReference;
  end;
  // Linked list of TPersistent items that have unresolved properties.  

  { TUnResolvedInstance }

  TUnResolvedInstance = Class(TLinkedListItem)
    Instance : TPersistent; // Instance we're handling unresolveds for
    FUnresolved : tfixups; // The list
    Destructor Destroy; override;
    Function AddReference(ARoot : TComponent; APropInfo : PPropInfo; AGlobal,ARelative : String) : TUnresolvedReference;
    Function RootUnresolved : TUnresolvedReference; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE} // Return root element in list.
    Function ResolveReferences : Boolean; // Return true if all unresolveds were resolved.
  end;

  // Builds a list of TUnResolvedInstances, removes them from global list on free.
  TBuildListVisitor = Class(TLinkedListVisitor)
    List : TFPList;
    Procedure Add(Item : TlinkedListItem); // Add TUnResolvedInstance item to list. Create list if needed
    Destructor Destroy; override; // All elements in list (if any) are removed from the global list.
  end;
  
  // Visitor used to try and resolve instances in the global list
  TResolveReferenceVisitor = Class(TBuildListVisitor)
    Function Visit(Item : TLinkedListItem) : Boolean; override;
  end;
  
  // Visitor used to remove all references to a certain component.
  TRemoveReferenceVisitor = Class(TBuildListVisitor)
    FRef : String;
    FRoot : TComponent;
    Constructor Create(ARoot : TComponent;Const ARef : String);
    Function Visit(Item : TLinkedListItem) : Boolean; override;
  end;

  // Visitor used to collect reference names.
  TReferenceNamesVisitor = Class(TLinkedListVisitor)
    FList : TStrings;
    FRoot : TComponent;
    Function Visit(Item : TLinkedListItem) : Boolean; override;
    Constructor Create(ARoot : TComponent;AList : TStrings);
  end;

  // Visitor used to collect instance names.  
  TReferenceInstancesVisitor = Class(TLinkedListVisitor)
    FList : TStrings;
    FRef  : String;
    FRoot : TComponent;
    Function Visit(Item : TLinkedListItem) : Boolean; override;
    Constructor Create(ARoot : TComponent;Const ARef : String; AList : TStrings);
  end;
  
  // Visitor used to redirect links to another root component.
  TRedirectReferenceVisitor = Class(TLinkedListVisitor)
    FOld,
    FNew : String;
    FRoot : TComponent;
    Function Visit(Item : TLinkedListItem) : Boolean; override;
    Constructor Create(ARoot : TComponent;Const AOld,ANew : String);
  end;

  
var
  NeedResolving : TLinkedList;
  ResolveSection : TRTLCriticalSection;

{ TUnresolvedReference }

Function TUnresolvedReference.Resolve(Instance : TPersistent) : Boolean;

Var
  C : TComponent;

begin
  C:=FindGlobalComponent(FGlobal);
  Result:=(C<>Nil);
  If Result then
    begin
    C:=FindNestedComponent(C,FRelative);
    Result:=C<>Nil;
    If Result then
      SetObjectProp(Instance, FPropInfo,C);
    end;
end; 

Function TUnresolvedReference.RootMatches(ARoot : TComponent) : Boolean; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}

begin
  Result:=(ARoot=Nil) or (ARoot=FRoot);
end;

Function TUnResolvedReference.NextRef : TUnresolvedReference;

begin
  Result:=TUnresolvedReference(Next);
end;

{ tfixups }

constructor tfixups.create;
begin
 inherited create(TUnresolvedReference);
end;

function tfixups.newreference(const aprop: ppropinfo): TUnResolvedReference;
begin
 result:= tunresolvedreference(root);
 while result <> nil do begin
  if (result.fpropinfo = aprop) then begin
   exit;
  end;
  result:= tunresolvedreference(result.next);
 end;
 result:= tunresolvedreference(add);
end;

{ tlocalfixups }

constructor tlocalfixups.create;
begin
 inherited create(TLocalUnresolvedReference);
end;

function tlocalfixups.newreference(const ainstance: tpersistent;
               const aprop: ppropinfo): TLocalUnResolvedReference;
begin
 result:= tlocalunresolvedreference(root);
 while result <> nil do begin
  if ((result.finstance) = ainstance) and (result.fpropinfo = aprop) then begin
   exit;
  end;
  result:= tlocalunresolvedreference(result.next);
 end;
 result:= tlocalunresolvedreference(add);
end;

{ TUnResolvedInstance }

destructor TUnResolvedInstance.Destroy;
begin
  FUnresolved.Free;
  inherited Destroy;
end;

function TUnResolvedInstance.AddReference(ARoot: TComponent;
  APropInfo: PPropInfo; AGlobal, ARelative: String): TUnresolvedReference;
begin
  If (FUnResolved = Nil) then begin
   FUnResolved:= tfixups.create;
  end;
  Result:= FUnResolved.newreference(apropinfo);
  Result.FGlobal:=AGLobal;
  Result.FRelative:=ARelative;
  Result.FPropInfo:=APropInfo;
  Result.FRoot:=ARoot;
end;

Function TUnResolvedInstance.RootUnresolved : TUnresolvedReference; 

begin
  Result:=Nil;
  If Assigned(FUnResolved) then
    Result:=TUnresolvedReference(FUnResolved.Root);
end;

Function TUnResolvedInstance.ResolveReferences:Boolean;

Var
  R,RN : TUnresolvedReference;

begin
  R:=RootUnResolved;
  While (R<>Nil) do
    begin
    RN:=R.NextRef;
    If R.Resolve(Self.Instance) then
      FUnresolved.RemoveItem(R,True);
    R:=RN;
    end;
  Result:=RootUnResolved=Nil;
end;

{ TReferenceNamesVisitor }

Constructor TReferenceNamesVisitor.Create(ARoot : TComponent;AList : TStrings);

begin
  FRoot:=ARoot;
  FList:=AList;
end;

Function TReferenceNamesVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  R : TUnresolvedReference;

begin
  R:=TUnResolvedInstance(Item).RootUnresolved;
  While (R<>Nil) do
    begin
    If R.RootMatches(FRoot) then
      If (FList.IndexOf(R.FGlobal)=-1) then 
        FList.Add(R.FGlobal);
    R:=R.NextRef;
    end;
  Result:=True;
end;

{ TReferenceInstancesVisitor }

Constructor TReferenceInstancesVisitor.Create(ARoot : TComponent; Const ARef : String;AList : TStrings);

begin
  FRoot:=ARoot;
  FRef:=UpperCase(ARef);
  FList:=AList;
end;

Function TReferenceInstancesVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  R : TUnresolvedReference;

begin
  R:=TUnResolvedInstance(Item).RootUnresolved;
  While (R<>Nil) do
    begin
    If (FRoot=R.FRoot) and (FRef=UpperCase(R.FGLobal)) Then
      If Flist.IndexOf(R.FRelative)=-1 then
        Flist.Add(R.FRelative);
    R:=R.NextRef;
    end;
  Result:=True;
end;

{ TRedirectReferenceVisitor }

Constructor TRedirectReferenceVisitor.Create(ARoot : TComponent; Const AOld,ANew  : String);

begin
  FRoot:=ARoot;
  FOld:=UpperCase(AOld);
  FNew:=ANew;
end;

Function TRedirectReferenceVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  R : TUnresolvedReference;

begin
  R:=TUnResolvedInstance(Item).RootUnresolved;
  While (R<>Nil) do
    begin
    If R.RootMatches(FRoot) and (FOld=UpperCase(R.FGLobal)) Then
      R.FGlobal:=FNew;
    R:=R.NextRef;
    end;
  Result:=True;
end;

{ TRemoveReferenceVisitor }

Constructor TRemoveReferenceVisitor.Create(ARoot : TComponent; Const ARef  : String);

begin
  FRoot:=ARoot;
  FRef:=UpperCase(ARef);
end;

Function TRemoveReferenceVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  I : Integer;
  UI : TUnResolvedInstance;
  R : TUnresolvedReference;
  L : TFPList;
  
begin
  UI:=TUnResolvedInstance(Item);
  R:=UI.RootUnresolved;
  L:=Nil;
  Try
    // Collect all matches.
    While (R<>Nil) do
      begin
      If R.RootMatches(FRoot) and ((FRef = '') or (FRef=UpperCase(R.FGLobal))) Then
        begin
        If Not Assigned(L) then
          L:=TFPList.Create;
        L.Add(R);
        end;
      R:=R.NextRef;
      end;
    // Remove all matches.
    IF Assigned(L) then
      begin
      For I:=0 to L.Count-1 do
        UI.FUnresolved.RemoveItem(TLinkedListitem(L[i]),True);
      end;
    // If any references are left, leave them.
    If UI.FUnResolved.Root=Nil then
      begin
      If List=Nil then
        List:=TFPList.Create;
      List.Add(UI);
      end;
  Finally
    L.Free;
  end;
  Result:=True;
end;

{ TBuildListVisitor }

Procedure TBuildListVisitor.Add(Item : TlinkedListItem);

begin
  If (List=Nil) then
    List:=TFPList.Create;
  List.Add(Item);
end;  

Destructor TBuildListVisitor.Destroy;

Var
  I : Integer;

begin
  If Assigned(List) then
    For I:=0 to List.Count-1 do
      NeedResolving.RemoveItem(TLinkedListItem(List[I]),True);
  FreeAndNil(List);
  Inherited;
end;

{ TResolveReferenceVisitor }

Function TResolveReferenceVisitor.Visit(Item : TLinkedListItem) : Boolean; 

begin
  If TUnResolvedInstance(Item).ResolveReferences then
    Add(Item);
  Result:=True;  
end;

// Add an instance to the global list of instances which need resolving.
Function FindUnresolvedInstance(AInstance: TPersistent) : TUnResolvedInstance;

begin
  Result:=Nil;
  EnterCriticalSection(ResolveSection);
  Try
    If Assigned(NeedResolving) then
      begin
      Result:=TUnResolvedInstance(NeedResolving.Root);
      While (Result<>Nil) and (Result.Instance<>AInstance) do
        Result:=TUnResolvedInstance(Result.Next);
      end;
  finally
    LeaveCriticalSection(ResolveSection);
  end;
end;

Function AddtoResolveList(AInstance: TPersistent) : TUnResolvedInstance;

begin
  Result:=FindUnresolvedInstance(AInstance);
  If (Result=Nil) then
    begin
    EnterCriticalSection(ResolveSection);
    Try
      If not Assigned(NeedResolving) then
        NeedResolving:=TLinkedList.Create(TUnResolvedInstance);
      Result:=NeedResolving.Add as TUnResolvedInstance;
      Result.Instance:=AInstance;
    finally
      LeaveCriticalSection(ResolveSection);
    end;
    end;
end;

// Walk through the global list of instances to be resolved.  

Procedure VisitResolveList(V : TLinkedListVisitor);

begin
  EnterCriticalSection(ResolveSection);
  Try
    try
      NeedResolving.Foreach(V);
    Finally
      FreeAndNil(V);
    end;  
  Finally
    LeaveCriticalSection(ResolveSection);
  end;  
end;

procedure GlobalFixupReferences;

begin
  If (NeedResolving=Nil) then 
    Exit;
  GlobalNameSpace.BeginWrite;
  try
    VisitResolveList(TResolveReferenceVisitor.Create);
  finally
    GlobalNameSpace.EndWrite;
  end;
end;

procedure GetFixupReferenceNames(Root: TComponent; Names: TStrings);

begin
  If (NeedResolving=Nil) then 
    Exit;
  VisitResolveList(TReferenceNamesVisitor.Create(Root,Names));
end;

procedure GetFixupInstanceNames(Root: TComponent; const ReferenceRootName: string; Names: TStrings);

begin
  If (NeedResolving=Nil) then
    Exit;
  VisitResolveList(TReferenceInstancesVisitor.Create(Root,ReferenceRootName,Names));
end;

procedure RedirectFixupReferences(Root: TComponent; const OldRootName, NewRootName: string);

begin
  If (NeedResolving=Nil) then
      Exit;
  VisitResolveList(TRedirectReferenceVisitor.Create(Root,OldRootName,NewRootName));
end;

procedure RemoveFixupReferences(Root: TComponent; const RootName: string);

begin
  If (NeedResolving=Nil) then
      Exit;
  VisitResolveList(TRemoveReferenceVisitor.Create(Root,RootName));
end;

procedure RemoveFixups(Instance: TPersistent);

begin
  // This needs work.
{
  if not Assigned(GlobalFixupList) then
    exit;

  with GlobalFixupList.LockList do
    try
      for i := Count - 1 downto 0 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if (CurFixup.FInstance = Instance) then
        begin
          Delete(i);
          CurFixup.Free;
        end;
      end;
    finally
      GlobalFixupList.UnlockList;
    end;
}
end;

Function FindNestedComponent(Root : TComponent; APath : String; CStyle : Boolean = True) : TComponent;

  Function GetNextName : String; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
  
  Var
    P : Integer;
    CM : Boolean;
    
  begin
    P:=Pos('.',APath);
    CM:=False;
    If (P=0) then
      begin
      If CStyle then
        begin
        P:=Pos('->',APath);
        CM:=P<>0;
        end;
      If (P=0) Then
        P:=Length(APath)+1;
      end;
    Result:=Copy(APath,1,P-1);
    Delete(APath,1,P+Ord(CM));
  end;

Var
  C : TComponent;
  S : String;
begin
  If (APath='') then
    Result:=Nil
  else
    begin
    Result:=Root;
    While (APath<>'') And (Result<>Nil) do
      begin
      C:=Result;
      S:=Uppercase(GetNextName);
      Result:=C.FindComponent(S);
      If (Result=Nil) And (S='OWNER') then
        Result:=C;
      end;
    end;
end;

type
 tglobloadlist = class(tfplist)
  protected
   fsuspended: integer;
  public
   procedure beginsuspend;
   procedure endsuspend;
 end;
 
threadvar
  GlobalLoaded: tglobloadlist;
  GlobalLists: TFpList;

{ tglobloadlist }

procedure tglobloadlist.beginsuspend;
begin
 inc(fsuspended);
end;

procedure tglobloadlist.endsuspend;
begin
 dec(fsuspended);
end;

procedure beginsuspendgloballoading;
begin
 if globalloaded <> nil then begin
  globalloaded.beginsuspend;
 end;
end;

procedure endsuspendgloballoading;
begin
 if globalloaded <> nil then begin
  globalloaded.endsuspend;
 end;
end;

procedure BeginGlobalLoading;

begin
  if not Assigned(GlobalLists) then
    GlobalLists := TFpList.Create;
  GlobalLists.Add(GlobalLoaded);
  GlobalLoaded := tglobloadlist.Create;
end;

procedure NotifyGlobalLoading;
var
  i: Integer;
begin
  for i := 0 to GlobalLoaded.Count - 1 do
    TComponent(GlobalLoaded[i]).Loaded;
end;

procedure EndGlobalLoading;
begin
  { Free the memory occupied by BeginGlobalLoading }
  GlobalLoaded.Free;
  GlobalLoaded := tglobloadlist(GlobalLists.Last);
  GlobalLists.Delete(GlobalLists.Count - 1);
  if GlobalLists.Count = 0 then
  begin
    GlobalLists.Free;
    GlobalLists := nil;
  end;
end;

function CollectionsEqual(C1, C2: TCollection): Boolean;
begin
  // !!!: Implement this
  CollectionsEqual:=false;
end;

function CollectionsEqual(C1, C2: TCollection; Owner1, Owner2: TComponent): Boolean;

  procedure stream_collection(s : tstream;c : tcollection;o : tcomponent);
    var
      w : twriter;
    begin
      w:=twriter.create(s,4096);
      try
        w.root:=o;
        w.flookuproot:=o;
        w.writecollection(c);
      finally
        w.free;
      end;
    end;

  var
    s1,s2 : tmemorystream;
  begin
    result:=false;
    if (c1.classtype<>c2.classtype) or
      (c1.count<>c2.count) then
      exit;
    if c1.count = 0 then
      begin
      result:= true;
      exit;
      end;
    s1:=tmemorystream.create;
    try
      s2:=tmemorystream.create;
      try
        stream_collection(s1,c1,owner1);
        stream_collection(s2,c2,owner2);
        result:=(s1.size=s2.size) and
        {$ifdef FPC}
         (CompareChar(s1.memory^,s2.memory^,s1.size) = 0);
        {$else}
         Comparemem(s1.memory,s2.memory,s1.size);
        {$endif}
      finally
        s2.free;
      end;
    finally
      s1.free;
    end;
  end;


{ *********************************************************************
  *                         TFiler                                    *
  *********************************************************************}

procedure TFiler.SetRoot(ARoot: TComponent);
begin
  FRoot := ARoot;
end;

{****************************************************************************}
{*                             TREADER                                      *}
{****************************************************************************}

type
  TFieldInfo = packed record
    FieldOffset: LongWord;
    ClassTypeIndex: Word;
    Name: ShortString;
  end;

  PFieldClassTable = ^TFieldClassTable;
  TFieldClassTable =
{$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
{$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
    Count: Word;
   {$ifdef FPC}
    Entries: array[Word] of TPersistentClass;
   {$else}
    Entries: array[Word] of ^TPersistentClass;
   {$endif}
  end;

  PFieldTable = ^TFieldTable;
  TFieldTable =
{$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
{$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
    FieldCount: Word;
    ClassTable: PFieldClassTable;
    // Fields: array[Word] of TFieldInfo;  Elements have variant size!
  end;

function getfieldclasstable(const aclass: tclass): pfieldclasstable;
begin
 pointer(result):= ppointer(pchar(pointer(aclass))+vmtFieldTable)^;
 if result <> nil then begin
  result:= pfieldtable(pointer(result))^.classtable;
 end;
end;

function GetFieldClass(Instance: TObject; const ClassName: string): TPersistentClass;
var
  UClassName: String;
  ClassType: TClass;
  ClassTable: PFieldClassTable;
  i: Integer;
begin
  // At first, try to locate the class in the class tables
  UClassName := UpperCase(ClassName);
  ClassType := Instance.ClassType;
  while ClassType <> TPersistent do
  begin
    classtable:= getfieldclasstable(classtype);
    if Assigned(ClassTable) then
      for i := 0 to ClassTable^.Count - 1 do
      begin
      {$ifdef FPC}
        Result := ClassTable^.Entries[i];
      {$else}
        Result := ClassTable^.Entries[i]^;
      {$endif}
        if UpperCase(Result.ClassName) = UClassName then
          exit;
      end;
     // Try again with the parent class type
     ClassType := ClassType.ClassParent;
  end;
  Result := GetClass(ClassName);
end;


constructor TReader.Create(Stream: TStream; BufSize: Integer);
begin
  inherited Create;
  If (Stream=Nil) then
    Raise EReadError.Create(SEmptyStreamIllegalReader);
  FDriver := CreateDriver(Stream, BufSize);
  fdriver.freader:= self;
end;

destructor TReader.Destroy;
begin
  FDriver.Free;
  inherited Destroy;
end;

function TReader.CreateDriver(Stream: TStream; BufSize: Integer): TAbstractObjectReader;
begin
  Result := TBinaryObjectReader.Create(Stream, BufSize);
end;

procedure TReader.BeginReferences;
begin
  FLoaded := TFpList.Create;
end;

procedure TReader.CheckValue(Value: TValueType);
begin
  if FDriver.NextValue <> Value then
    raise EReadError.Create(SInvalidPropertyValue)
  else
    FDriver.ReadValue;
end;

procedure TReader.DefineProperty(const Name: String; AReadData: TReaderProc;
  WriteData: TWriterProc; HasData: Boolean);
begin
  if Assigned(AReadData) and (UpperCase(Name) = UpperCase(FPropName)) then
  begin
    AReadData(Self);
    SetLength(FPropName, 0);
  end;
end;

procedure TReader.DefineBinaryProperty(const Name: String;
  AReadData, WriteData: TStreamProc; HasData: Boolean);
var
  MemBuffer: TMemoryStream;
begin
  if Assigned(AReadData) and (UpperCase(Name) = UpperCase(FPropName)) then
  begin
    { Check if the next property really is a binary property}
    if FDriver.NextValue <> vaBinary then
    begin
      FDriver.SkipValue;
      FCanHandleExcepts := True;
      raise EReadError.Create(SInvalidPropertyValue);
    end else
      FDriver.ReadValue;

    MemBuffer := TMemoryStream.Create;
    try
      FDriver.ReadBinary(MemBuffer);
      FCanHandleExcepts := True;
      AReadData(MemBuffer);
    finally
      MemBuffer.Free;
    end;
    SetLength(FPropName, 0);
  end;
end;

function TReader.EndOfList: Boolean;
begin
  Result := FDriver.NextValue = vaNull;
end;

procedure TReader.EndReferences;
begin
  FLoaded.Free;
  FLoaded := nil;
end;

function TReader.Error(const Message: String): Boolean;
begin
  Result := False;
  if Assigned(FOnError) then
    FOnError(Self, Message, Result);
end;

function TReader.FindMethod(ARoot: TComponent; const AMethodName: String): Pointer;
var
  ErrorResult: Boolean;
begin
  Result := ARoot.MethodAddress(AMethodName);
  ErrorResult := Result = nil;

  { always give the OnFindMethod callback a chance to locate the method }
  if Assigned(FOnFindMethod) then
    FOnFindMethod(Self, AMethodName, Result, ErrorResult);

  if ErrorResult then
    raise EReadError.Create(SInvalidPropertyValue);
end;

procedure TReader.DoFixupReferences;

Var
  R,RN : TLocalUnresolvedReference;
  G : TUnresolvedInstance;
  Ref : String;
  C : TComponent;
  P : integer;
  L : TLinkedList;
  
begin
  If Assigned(FFixups) then
    begin
    L:=TLinkedList(FFixups);
    R:=TLocalUnresolvedReference(L.Root);
    While (R<>Nil) do
      begin
      RN:=TLocalUnresolvedReference(R.Next);
      Ref:=R.FRelative;
      If Assigned(FOnReferenceName) then
        FOnReferenceName(Self,Ref);
      C:=FindNestedComponent(R.FRoot,Ref);
      If Assigned(C) then
        SetObjectProp(R.FInstance,R.FPropInfo,C)
      else begin
        P:=Pos('.',R.FRelative);
        If (P<>0) then begin
          G:= AddToResolveList(R.FInstance);
          G.Addreference(R.FRoot,R.FPropInfo,Copy(R.FRelative,1,P-1),Copy(R.FRelative,P+1,Length(R.FRelative)-P));
        end;
      end;
      L.RemoveItem(R,True);
      R:=RN;
      end;
    FreeAndNil(FFixups);
    end;
end;

procedure TReader.FixupReferences;
var
  i: Integer;
begin
  DoFixupReferences;
  GlobalFixupReferences;
  for i := 0 to FLoaded.Count - 1 do
    TComponent(FLoaded[I]).Loaded;
end;


function TReader.NextValue: TValueType;
begin
  Result := FDriver.NextValue;
end;

procedure TReader.Read(var Buf; Count: LongInt);
begin
  //This should give an exception if read is not implemented (i.e. TTextObjectReader)
  //but should work with TBinaryObjectReader.
  Driver.Read(Buf, Count);
end;

procedure TReader.PropertyError;
begin
  FDriver.SkipValue;
  raise EReadError.CreateFmt(SUnknownProperty,[FPropName]);
end;

function TReader.ReadBoolean: Boolean;
var
  ValueType: TValueType;
begin
  ValueType := FDriver.ReadValue;
  if ValueType = vaTrue then
    Result := True
  else if ValueType = vaFalse then
    Result := False
  else
    raise EReadError.Create(SInvalidPropertyValue);
end;

function TReader.ReadChar: Char;
var
  s: String;
begin
  s := ReadString;
  if Length(s) = 1 then
    Result := s[1]
  else
    raise EReadError.Create(SInvalidPropertyValue);
end;

function TReader.ReadWideChar: WideChar;

var
  W: WideString;
  
begin
  W := ReadWideString;
  if Length(W) = 1 then
    Result := W[1]
  else
    raise EReadError.Create(SInvalidPropertyValue);
end;
            
function TReader.ReadUnicodeChar: UnicodeChar;

var
  U: UnicodeString;
  
begin
  U := ReadUnicodeString;
  if Length(U) = 1 then
    Result := U[1]
  else
    raise EReadError.Create(SInvalidPropertyValue);
end;
            
procedure TReader.ReadCollection(Collection: TCollection);
var
  Item: TCollectionItem;
begin
  Collection.BeginUpdate;
  if not EndOfList then
    Collection.Clear;
  while not EndOfList do begin
    ReadListBegin;
    Item := Collection.Add;
    while NextValue<>vaNull do
      ReadProperty(Item);
    ReadListEnd;
  end;
  Collection.EndUpdate;
  ReadListEnd;
end;

function TReader.ReadComponent(Component: TComponent): TComponent;
var
  Flags: TFilerFlags;

  function Recover(var Component: TComponent): Boolean;
  begin
    Result := False;
    if ExceptObject.InheritsFrom(Exception) then
    begin
      if not ((ffInherited in Flags) or Assigned(Component)) then
        Component.Free;
      Component := nil;
      FDriver.SkipComponent(False);
      Result := Error(Exception(ExceptObject).Message);
    end;
  end;

var
  CompClassName, Name: String;
  n, ChildPos: Integer;
  SavedParent, SavedLookupRoot: TComponent;
  ComponentClass: TComponentClass;
  C, NewComponent: TComponent;
  SubComponents: TList;
begin
  FDriver.BeginComponent(Flags, ChildPos, CompClassName, Name);
  SavedParent := Parent;
  SavedLookupRoot := FLookupRoot;
  SubComponents := nil;
  try
    Result := Component;
    if not Assigned(Result) then
      try
        if ffInherited in Flags then
        begin
          { Try to locate the existing ancestor component }

          if Assigned(FLookupRoot) then
            Result := FLookupRoot.FindComponent(Name)
          else
            Result := nil;

          if not Assigned(Result) then
          begin
            if Assigned(FOnAncestorNotFound) then
              FOnAncestorNotFound(Self, Name,
                FindComponentClass(CompClassName), Result);
            if not Assigned(Result) then
              raise EReadError.CreateFmt(SAncestorNotFound, [Name]);
          end;

          Parent := Result.GetParentComponent;
          if not Assigned(Parent) then
            Parent := Root;
        end else
        begin
          Result := nil;
          ComponentClass := FindComponentClass(CompClassName);
          if Assigned(FOnCreateComponent) then
            FOnCreateComponent(Self, ComponentClass, Result);
          if not Assigned(Result) then
          begin
            NewComponent := TComponent(ComponentClass.NewInstance);
            if ffInline in Flags then
              NewComponent.FComponentState :=
                NewComponent.FComponentState + [csLoading, csInline];
            NewComponent.Create(Owner);

            { Don't set Result earlier because else we would come in trouble
              with the exception recover mechanism! (Result should be NIL if
              an error occured) }
            Result := NewComponent;
          end;
          Include(Result.FComponentState, csLoading);
        end;
      except
        if not Recover(Result) then
          raise;
      end;

    if Assigned(Result) then
      try
        Include(Result.FComponentState, csLoading);

        { create list of subcomponents and set loading}
        SubComponents := TList.Create;
        for n := 0 to Result.ComponentCount - 1 do
        begin
          C := Result.Components[n];
          if csSubcomponent in C.ComponentStyle
          then begin
            SubComponents.Add(C);
            Include(C.FComponentState, csLoading);
          end;
        end;

        if not (ffInherited in Flags) then
          try
            Result.SetParentComponent(Parent);
            if Assigned(FOnSetName) then
              FOnSetName(Self, Result, Name);
            Result.Name := Name;
            if FindGlobalComponent(Name) = Result then
              Include(Result.FComponentState, csInline);
          except
            if not Recover(Result) then
              raise;
          end;
        if not Assigned(Result) then
          exit;
        if csInline in Result.ComponentState then
          FLookupRoot := Result;

        { Read the component state }
        Include(Result.FComponentState, csReading);
        for n := 0 to Subcomponents.Count - 1 do
          Include(TComponent(Subcomponents[n]).FComponentState, csReading);

        Result.ReadState(Self);

        Exclude(Result.FComponentState, csReading);
        for n := 0 to Subcomponents.Count - 1 do
          Exclude(TComponent(Subcomponents[n]).FComponentState, csReading);

        if ffChildPos in Flags then
          Parent.SetChildOrder(Result, ChildPos);

        { Add component to list of loaded components, if necessary }
        if (not ((ffInherited in Flags) or (csInline in Result.ComponentState))) or
          (FLoaded.IndexOf(Result) < 0)
          then begin
            for n := 0 to Subcomponents.Count - 1 do
              FLoaded.Add(Subcomponents[n]);
            FLoaded.Add(Result);
          end;
      except
        if ((ffInherited in Flags) or Assigned(Component)) then
          Result.Free;
        raise;
      end;
  finally
    Parent := SavedParent;
    FLookupRoot := SavedLookupRoot;
    Subcomponents.Free;
  end;
end;

procedure TReader.ReadData(Instance: TComponent);
var
  SavedOwner, SavedParent: TComponent;
  
begin
  { Read properties }
  while not EndOfList do
    ReadProperty(Instance);
  ReadListEnd;

  { Read children }
  SavedOwner := Owner;
  SavedParent := Parent;
  try
    Owner := Instance.GetChildOwner;
    if not Assigned(Owner) then
      Owner := Root;
    Parent := Instance.GetChildParent;

    while not EndOfList do
      ReadComponent(nil);
    ReadListEnd;
  finally
    Owner := SavedOwner;
    Parent := SavedParent;
  end;

  { Fixup references if necessary (normally only if this is the root) }
  If (Instance=FRoot) then
    DoFixupReferences;
end;

{$ifndef FPUNONE}
function TReader.ReadFloat: Extended;
begin
  if FDriver.NextValue = vaExtended then
  begin
    ReadValue;
    Result := FDriver.ReadFloat
  end else
    Result := ReadInteger;
end;

function TReader.ReadSingle: Single;
begin
  if FDriver.NextValue = vaSingle then
  begin
    FDriver.ReadValue;
    Result := FDriver.ReadSingle;
  end else
    Result := ReadInteger;
end;
{$endif}

function TReader.ReadCurrency: Currency;
begin
  if FDriver.NextValue = vaCurrency then
  begin
    FDriver.ReadValue;
    Result := FDriver.ReadCurrency;
  end else
    Result := ReadInteger;
end;

{$ifndef FPUNONE}
function TReader.ReadDate: TDateTime;
begin
  if FDriver.NextValue = vaDate then
  begin
    FDriver.ReadValue;
    Result := FDriver.ReadDate;
  end else
    Result := ReadInteger;
end;
{$endif}

function TReader.ReadIdent: String;
var
  ValueType: TValueType;
begin
  ValueType := FDriver.ReadValue;
  if ValueType in [vaIdent, vaNil, vaFalse, vaTrue, vaNull] then
    Result := FDriver.ReadIdent(ValueType)
  else
    raise EReadError.Create(SInvalidPropertyValue);
end;


function TReader.ReadInteger: LongInt;
begin
  case FDriver.ReadValue of
    vaInt8:
      Result := FDriver.ReadInt8;
    vaInt16:
      Result := FDriver.ReadInt16;
    vaInt32:
      Result := FDriver.ReadInt32;
  else
    raise EReadError.Create(SInvalidPropertyValue);
  end;
end;

function TReader.ReadInt64: Int64;
begin
  if FDriver.NextValue = vaInt64 then
  begin
    FDriver.ReadValue;
    Result := FDriver.ReadInt64;
  end else
    Result := ReadInteger;
end;

function treader.readset(settype: ptypeinfo): longword; 
begin
 if fdriver.nextvalue = vaset then begin
  fdriver.readvalue;
  result:= fdriver.readset(
                 gettypedata(settype)^.comptype{$ifndef FPC}^{$endif});
 end 
 else begin
  result:= readinteger;
 end;
end;

procedure TReader.ReadListBegin;
begin
  CheckValue(vaList);
end;

procedure TReader.ReadListEnd;
begin
  CheckValue(vaNull);
end;

function TReader.ReadVariant: variant;
var
  nv: TValueType;
begin
{$ifdef FPC}
  { Ensure that a Variant manager is installed }
  if not Assigned(VarClearProc) then
    raise EReadError.Create(SErrNoVariantSupport);
{$endif}
  FillChar(Result,sizeof(Result),0);

  nv:=NextValue;
  case nv of
    vaNil:
      begin
        Result:= {$ifdef FPC}system.{$endif}unassigned;
        readvalue;
      end;
    vaNull:
      begin
        Result:= {$ifdef FPC}system.{$endif}null;
        readvalue;
      end;
    { all integer sizes must be split for big endian systems }
    vaInt8,vaInt16,vaInt32:
      begin
        Result:=ReadInteger;
      end;
    vaInt64:
      begin
        Result:=ReadInt64;
      end;
    vaQWord:
      begin
        Result:=QWord(ReadInt64);
      end;
    vaFalse,vaTrue:
      begin
        Result:=(nv<>vaFalse);
      end;
    vaCurrency:
      begin
        Result:=ReadCurrency;
      end;
{$ifndef fpunone}
    vaSingle:
      begin
        Result:=ReadSingle;
      end;
    vaExtended:
      begin
        Result:=ReadFloat;
      end;
    vaDate:
      begin
        Result:=ReadDate;
      end;
{$endif fpunone}
    vaWString,vaUTF8String:
      begin
        Result:=ReadWideString;
      end;
    vaString:
      begin
        Result:=ReadString;
      end;
    vaUString:
      begin
        Result:=ReadUnicodeString;
      end;
    else
      raise EReadError.CreateFmt(SUnsupportedPropertyVariantType, [Ord(nv)]);
  end;
end;

procedure TReader.ReadProperty(AInstance: TPersistent);
var
  Path: String;
  Instance: TPersistent;
  DotPos, NextPos: PChar;
  PropInfo: PPropInfo;
  Obj: TObject;
  Name: String;
  Skip: Boolean;
  Handled: Boolean;
  OldPropName: String;

  function HandleMissingProperty(IsPath: Boolean): boolean;
  begin
    Result:=true;
    if Assigned(OnPropertyNotFound) then begin
      // user defined property error handling
      OldPropName:=FPropName;
      Handled:=false;
      Skip:=false;
      OnPropertyNotFound(Self,Instance,FPropName,IsPath,Handled,Skip);
      if Handled and (not Skip) and (OldPropName<>FPropName) then
        // try alias property
        PropInfo := GetPropInfo(Instance.ClassInfo, FPropName);
      if Skip then begin
        FDriver.SkipValue;
        Result:=false;
        exit;
      end;
    end;
  end;

begin
  try
    Path := FDriver.BeginProperty;
    try
      Instance := AInstance;
      FCanHandleExcepts := True;
      DotPos := PChar(Path);
      while True do
      begin
        NextPos := StrScan(DotPos, '.');
        if Assigned(NextPos) then
          FPropName := Copy(String(DotPos), 1, Integer(NextPos - DotPos))
        else
        begin
          FPropName := DotPos;
          break;
        end;
        DotPos := NextPos + 1;

        PropInfo := GetPropInfo(Instance.ClassInfo, FPropName);
        if not Assigned(PropInfo) then begin
          if not HandleMissingProperty(true) then exit;
          if not Assigned(PropInfo) then
            PropertyError;
        end;

        if PropInfo^.PropType^.Kind = tkClass then
          Obj := TObject(GetObjectProp(Instance, PropInfo))
        else
          Obj := nil;

        if not (Obj is TPersistent) then
        begin
          { All path elements must be persistent objects! }
          FDriver.SkipValue;
          raise EReadError.Create(SInvalidPropertyPath);
        end;
        Instance := TPersistent(Obj);
      end;

      PropInfo := GetPropInfo(Instance.ClassInfo, FPropName);
      if Assigned(PropInfo) then
        ReadPropValue(Instance, PropInfo)
      else
      begin
        FCanHandleExcepts := False;
        Instance.DefineProperties(Self);
        FCanHandleExcepts := True;
        if Length(FPropName) > 0 then begin
          if not HandleMissingProperty(false) then exit;
          if not Assigned(PropInfo) then
            PropertyError;
        end;
      end;
    except
      on e: Exception do
      begin
        SetLength(Name, 0);
        if AInstance.InheritsFrom(TComponent) then
          Name := TComponent(AInstance).Name;
        if Length(Name) = 0 then
          Name := AInstance.ClassName;
        raise EReadError.CreateFmt(SPropertyException,
          [Name, DotSep, Path, e.Message]);
      end;
    end;
  except
    on e: Exception do
      if not FCanHandleExcepts or not Error(E.Message) then
        raise;
  end;
end;

procedure TReader.ReadPropValue(Instance: TPersistent; PropInfo: Pointer);
const
  NullMethod: TMethod = (Code: nil; Data: nil);
var
  PropType: PTypeInfo;
  Value: LongInt;
{  IdentToIntFn: TIdentToInt; }
  Ident: String;
  Method: TMethod;
  Handled: Boolean;
  TmpStr: String;
begin
  if not Assigned(PPropInfo(PropInfo)^.SetProc) then
    raise EReadError.Create(SReadOnlyProperty);

{$ifdef FPC}
  PropType := PPropInfo(PropInfo)^.PropType;
{$else}
  PropType := PPropInfo(PropInfo)^.PropType^;
{$endif}
  case PropType^.Kind of
    tkInteger:
      if FDriver.NextValue = vaIdent then
      begin
        Ident := ReadIdent;
        if GlobalIdentToInt(Ident,Value) then
          SetOrdProp(Instance, PropInfo, Value)
        else
          raise EReadError.Create(SInvalidPropertyValue);
      end else
        SetOrdProp(Instance, PropInfo, ReadInteger);
{$ifdef FPC}
    tkBool:
      SetOrdProp(Instance, PropInfo, Ord(ReadBoolean));
{$endif}
    tkChar:
      SetOrdProp(Instance, PropInfo, Ord(ReadChar));
    tkWChar{$ifdef FPC},tkUChar{$endif}:
      SetOrdProp(Instance, PropInfo, Ord(ReadWideChar));
    tkEnumeration:
      begin
        Value := GetEnumValue(PropType, ReadIdent);
        if Value = -1 then
          raise EReadError.Create(SInvalidPropertyValue);
        SetOrdProp(Instance, PropInfo, Value);
      end;
{$ifndef FPUNONE}
    tkFloat:
      SetFloatProp(Instance, PropInfo, ReadFloat);
{$endif}
    tkSet:
      begin
        CheckValue(vaSet);
        SetOrdProp(Instance, PropInfo,
        {$ifdef FPC}
          FDriver.ReadSet(GetTypeData(PropType)^.CompType));
        {$else}
          FDriver.ReadSet(GetTypeData(PropType)^.CompType^));
        {$endif}
      end;
    tkMethod:
      if FDriver.NextValue = vaNil then
      begin
        FDriver.ReadValue;
        SetMethodProp(Instance, PropInfo, NullMethod);
      end else
      begin
        Handled:=false;
        Ident:=ReadIdent;
        if Assigned(OnSetMethodProperty) then
          OnSetMethodProperty(Self,Instance,PPropInfo(PropInfo),Ident,
                              Handled);
        if not Handled then begin
          Method.Code := FindMethod(Root, Ident);
          Method.Data := Root;
          if Assigned(Method.Code) then
            SetMethodProp(Instance, PropInfo, Method);
        end;
      end;
    {$ifdef FPC}
    tkSString, tkLString, tkAString:
    {$else}
    tkString, tkLString:
    {$endif}
      begin
        TmpStr:=ReadString;
        if Assigned(FOnReadStringProperty) then
          FOnReadStringProperty(Self,Instance,PropInfo,TmpStr);
        SetStrProp(Instance, PropInfo, TmpStr);
      end;
    {$ifdef FPC}
    tkUstring:
      SetUnicodeStrProp(Instance,PropInfo,ReadUnicodeString);
    {$endif}
    tkWString:
      SetWideStrProp(Instance,PropInfo,ReadWideString);
    tkVariant:
      begin
        SetVariantProp(Instance,PropInfo,ReadVariant);
      end;
    tkClass:
      case FDriver.NextValue of
        vaNil:
          begin
            FDriver.ReadValue;
            SetOrdProp(Instance, PropInfo, 0)
          end;
        vaCollection:
          begin
            FDriver.ReadValue;
            ReadCollection(TCollection(GetObjectProp(Instance, PropInfo)));
          end
        else begin
          If Not Assigned(FFixups) then begin
//            FFixups:=TLinkedList.Create(TLocalUnresolvedReference);
           FFixups:= tlocalfixups.create;
          end;
//          With tfixups(FFixups).newreference(instance,propinfo) do begin
          With TLocalUnresolvedReference(tlocalfixups(FFixups).add) do begin
           FInstance:= Instance;
           FRoot:= Root;
           FPropInfo:= PropInfo;
           FRelative:= ReadIdent;
          end;
        end;
      end;
    tkInt64{$ifdef FPC}, tkQWord{$endif}:
     SetInt64Prop(Instance, PropInfo, ReadInt64);
    else
      raise EReadError.CreateFmt(SUnknownPropertyType, [Ord(PropType^.Kind)]);
  end;
end;

function TReader.ReadRootComponent(ARoot: TComponent): TComponent;
var
  Dummy, i: Integer;
  Flags: TFilerFlags;
  CompClassName, CompName, ResultName: String;
  localloaded: boolean;
begin
  FDriver.BeginRootComponent;
  Result := nil;
  {!!!: GlobalNameSpace.BeginWrite;  // Loading from stream adds to name space
  try}
    try
      FDriver.BeginComponent(Flags, Dummy, CompClassName, CompName);
      if not Assigned(ARoot) then
      begin
        { Read the class name and the object name and create a new object: }
        Result := TComponentClass(FindClass(CompClassName)).Create(nil);
        Result.Name := CompName;
      end else
      begin
        Result := ARoot;

        if not (csDesigning in Result.ComponentState) then
        begin
          Result.FComponentState :=
            Result.FComponentState + [csLoading, csReading];

          { We need an unique name }
          i := 0;
          { Don't use Result.Name directly, as this would influence
            FindGlobalComponent in successive loop runs }
          ResultName := CompName;
          while Assigned(FindGlobalComponent(ResultName)) do
          begin
            Inc(i);
            ResultName := CompName + '_' + IntToStr(i);
          end;
          Result.Name := ResultName;
        end;
      end;

      FRoot := Result;
      FLookupRoot := Result;
      localloaded:= not (Assigned(GlobalLoaded) and 
                                      (globalloaded.fsuspended <= 0));
      if localloaded then begin
       FLoaded:= TFpList.Create;
      end
      else begin
       FLoaded:= GlobalLoaded;
      end;
      try
        if FLoaded.IndexOf(FRoot) < 0 then begin
         FLoaded.Add(FRoot);
        end;
        FOwner := FRoot;
        FRoot.FComponentState := FRoot.FComponentState + [csLoading, csReading];
        FRoot.ReadState(Self);
        Exclude(FRoot.FComponentState, csReading);

        if localloaded then begin
         for i := 0 to FLoaded.Count - 1 do begin
          TComponent(FLoaded[i]).Loaded;
         end;
        end;

      finally
       if localloaded then begin
        FLoaded.Free;
       end;
       FLoaded := nil;
      end;
      GlobalFixupReferences;
    except
      RemoveFixupReferences(ARoot, '');
      if not Assigned(ARoot) then
        Result.Free;
      raise;
    end;
  {finally
    GlobalNameSpace.EndWrite;
  end;}
end;

procedure TReader.ReadComponents(AOwner, AParent: TComponent;
  Proc: TReadComponentsProc);
var
  Component: TComponent;
begin
  Root := AOwner;
  Owner := AOwner;
  Parent := AParent;
  BeginReferences;
  try
    while not EndOfList do
    begin
      FDriver.BeginRootComponent;
      Component := ReadComponent(nil);
      if Assigned(Proc) then
        Proc(Component);
    end;
    ReadListEnd;
    FixupReferences;
  finally
    EndReferences;
  end;
end;


function TReader.ReadString: String;
var
  StringType: TValueType;
begin
  StringType := FDriver.ReadValue;
  if StringType in [vaString, vaLString,vaUTF8String] then
    begin
      Result := FDriver.ReadString(StringType);
      if (StringType=vaUTF8String) then
        Result:=utf8Decode(Result);
    end
  else if StringType in [vaWString] then
    Result:= FDriver.ReadWidestring
  else if StringType in [vaUString] then
    Result:= FDriver.ReadUnicodeString
  else
    raise EReadError.Create(SInvalidPropertyValue);
end;


function TReader.ReadWideString: WideString;
var
 s: String;
 i: Integer;
 vt:TValueType;
begin
  if NextValue in [vaWString,vaUString,vaUTF8String] then
    //vaUTF8String needs conversion? 2008-09-06 mse, YES!! AntonK
    begin
      vt:=ReadValue;
      if vt=vaUTF8String then
        Result := utf8decode(fDriver.ReadString(vaLString))
      else
        Result := FDriver.ReadWideString
    end
  else
    begin
      //data probable from ObjectTextToBinary
      s := ReadString;
      setlength(result,length(s));
      for i:= 1 to length(s) do begin
        result[i]:= widechar(ord(s[i])); //no code conversion
    end;
  end;
end;


function TReader.ReadUnicodeString: UnicodeString;
var
 s: String;
 i: Integer;
 vt:TValueType;
begin
  if NextValue in [vaWString,vaUString,vaUTF8String] then
    //vaUTF8String needs conversion? 2008-09-06 mse, YES!! AntonK
    begin
      vt:=ReadValue;
      if vt=vaUTF8String then
        Result := utf8decode(fDriver.ReadString(vaLString))
      else
        Result := FDriver.ReadWideString
    end
  else
    begin
      //data probable from ObjectTextToBinary
      s := ReadString;
      setlength(result,length(s));
      for i:= 1 to length(s) do begin
        result[i]:= UnicodeChar(ord(s[i])); //no code conversion
    end;
  end;
end;


function TReader.ReadValue: TValueType;
begin
  Result := FDriver.ReadValue;
end;

procedure TReader.CopyValue(Writer: TWriter);

  procedure CopyBytes(Count: Integer);
{  var
    Buffer: array[0..1023] of Byte; }
  begin
{!!!:    while Count > 1024 do
    begin
      FDriver.Read(Buffer, 1024);
      Writer.Driver.Write(Buffer, 1024);
      Dec(Count, 1024);
    end;
    if Count > 0 then
    begin
      FDriver.Read(Buffer, Count);
      Writer.Driver.Write(Buffer, Count);
    end;}
  end;

{var
  s: String;
  Count: LongInt; }
begin
  case FDriver.NextValue of
    vaNull:
      Writer.WriteIdent('NULL');
    vaFalse:
      Writer.WriteIdent('FALSE');
    vaTrue:
      Writer.WriteIdent('TRUE');
    vaNil:
      Writer.WriteIdent('NIL');
    {!!!: vaList, vaCollection:
      begin
        Writer.WriteValue(FDriver.ReadValue);
        while not EndOfList do
          CopyValue(Writer);
        ReadListEnd;
        Writer.WriteListEnd;
      end;}
    vaInt8, vaInt16, vaInt32:
      Writer.WriteInteger(ReadInteger);
{$ifndef FPUNONE}
    vaExtended:
      Writer.WriteFloat(ReadFloat);
{$endif}
    {!!!: vaString:
      Writer.WriteStr(ReadStr);}
    vaIdent:
      Writer.WriteIdent(ReadIdent);
    {!!!: vaBinary, vaLString, vaWString:
      begin
        Writer.WriteValue(FDriver.ReadValue);
        FDriver.Read(Count, SizeOf(Count));
        Writer.Driver.Write(Count, SizeOf(Count));
        CopyBytes(Count);
      end;}
    {!!!: vaSet:
      Writer.WriteSet(ReadSet);}
{$ifndef FPUNONE}
    vaSingle:
      Writer.WriteSingle(ReadSingle);
{$endif}
    {!!!: vaCurrency:
      Writer.WriteCurrency(ReadCurrency);}
{$ifndef FPUNONE}
    vaDate:
      Writer.WriteDate(ReadDate);
{$endif}
    vaInt64:
      Writer.WriteInteger(ReadInt64);
  end;
end;

function TReader.FindComponentClass(const AClassName: String): TComponentClass;

var
  PersistentClass: TPersistentClass;
  UClassName: shortstring;

  procedure FindInFieldTable(RootComponent: TComponent);
  var
    FieldClassTable: PFieldClassTable;
    Entry: TPersistentClass;
    i: Integer;
    ComponentClassType: TClass;
  begin
    ComponentClassType:= RootComponent.ClassType;
    // it is not necessary to look in the FieldTable of TComponent,
    // because TComponent doesn't have published properties that are
    // descendants of TComponent
    while ComponentClassType <> TComponent do begin
      fieldclasstable:= getfieldclasstable(componentclasstype);
      if assigned(FieldClassTable) then begin
        for i:= 0 to FieldClassTable^.Count -1 do begin
         {$ifdef FPC}
          Entry:= FieldClassTable^.Entries[i];
         {$else}
          Entry:= FieldClassTable^.Entries[i]^;
         {$endif}
          //writeln(format('Looking for %s in field table of class %s. Found %s',
            //[AClassName, ComponentClassType.ClassName, Entry.ClassName]));
          if (UpperCase(Entry.ClassName) = UClassName) and
                             Entry.InheritsFrom(TComponent) then begin
            Result:= TComponentClass(Entry);
            Exit;
          end;
        end;
      end;
      // look in parent class
      ComponentClassType:= ComponentClassType.ClassParent;
    end;
  end;

begin
  Result := nil;
  UClassName:=UpperCase(AClassName);
  FindInFieldTable(Root);

  if (Result=nil) and assigned(LookupRoot) and (LookupRoot<>Root) then
    FindInFieldTable(LookupRoot);

  if (Result=nil) then begin
    PersistentClass := GetClass(AClassName);
    if {$ifndef FPC}(persistentclass <> nil) and{$endif}
             PersistentClass.InheritsFrom(TComponent) then
      Result := TComponentClass(PersistentClass);
  end;

  if (Result=nil) and assigned(OnFindComponentClass) then
    OnFindComponentClass(Self, AClassName, Result);

  if (Result=nil) or (not Result.InheritsFrom(TComponent)) then
    raise EClassNotFound.CreateFmt(SClassNotFound, [AClassName]);
end;

function treader.readenum(const enumtype: ptypeinfo): longword;
begin
 result:= GetEnumValue(enumtype, ReadIdent);
 if integer(result) = -1 then begin
  raise EReadError.Create(SInvalidPropertyValue);
 end;
end;

{****************************************************************************}
{*                             TWriter                                      *}
{****************************************************************************}


constructor TWriter.Create(ADriver: TAbstractObjectWriter);
begin
  inherited Create;
  FDriver := ADriver;
end;

constructor TWriter.Create(Stream: TStream; BufSize: Integer);
begin
  inherited Create;
  If (Stream=Nil) then
    Raise EWriteError.Create(SEmptyStreamIllegalWriter);
  FDriver := CreateDriver(Stream, BufSize);
  fdriver.fwriter:= self;
  FDestroyDriver := True;
end;

destructor TWriter.Destroy;
begin
  if FDestroyDriver then
    FDriver.Free;
  inherited Destroy;
end;

function TWriter.CreateDriver(Stream: TStream; BufSize: Integer): TAbstractObjectWriter;
begin
  Result := TBinaryObjectWriter.Create(Stream, BufSize);
end;

Type
  TPosComponent = Class(TObject)
    FPos : Integer;
    FComponent : TComponent;
    Constructor Create(APos : Integer; AComponent : TComponent);
  end;

Constructor TPosComponent.Create(APos : Integer; AComponent : TComponent);

begin
  FPos:=APos;
  FComponent:=AComponent;
end;

// Used as argument for calls to TComponent.GetChildren:
procedure TWriter.AddToAncestorList(Component: TComponent);
begin
  FAncestors.AddObject(Component.Name,TPosComponent.Create(FAncestors.Count,Component));
end;

procedure TWriter.DefineProperty(const Name: String;
  ReadData: TReaderProc; AWriteData: TWriterProc; HasData: Boolean);
begin
  if HasData and Assigned(AWriteData) then
  begin
    // Write the property name and then the data itself
    Driver.BeginProperty(FPropPath + Name);
    AWriteData(Self);
    Driver.EndProperty;
  end;
end;

procedure TWriter.DefineBinaryProperty(const Name: String;
  ReadData, AWriteData: TStreamProc; HasData: Boolean);
begin
  if HasData and Assigned(AWriteData) then
  begin
    // Write the property name and then the data itself
    Driver.BeginProperty(FPropPath + Name);
    WriteBinary(AWriteData);
    Driver.EndProperty;
  end;
end;

procedure TWriter.Write(const Buffer; Count: Longint);
begin
  //This should give an exception if write is not implemented (i.e. TTextObjectWriter)
  //but should work with TBinaryObjectWriter.
  Driver.Write(Buffer, Count);
end;

procedure TWriter.SetRoot(ARoot: TComponent);
begin
  inherited SetRoot(ARoot);
  // Use the new root as lookup root too
  FLookupRoot := ARoot;
end;

procedure TWriter.WriteBinary(AWriteData: TStreamProc);
var
  MemBuffer: TMemoryStream;
  BufferSize: Longint;
begin
  { First write the binary data into a memory stream, then copy this buffered
    stream into the writing destination. This is necessary as we have to know
    the size of the binary data in advance (we're assuming that seeking within
    the writer stream is not possible) }
  MemBuffer := TMemoryStream.Create;
  try
    AWriteData(MemBuffer);
    BufferSize := MemBuffer.Size;
    Driver.WriteBinary(MemBuffer.Memory^, BufferSize);
  finally
    MemBuffer.Free;
  end;
end;

procedure TWriter.WriteBoolean(Value: Boolean);
begin
  Driver.WriteBoolean(Value);
end;

procedure TWriter.WriteChar(Value: Char);
begin
  WriteString(Value);
end;

procedure TWriter.WriteWideChar(Value: WideChar);
begin
  WriteWideString(Value);
end;

procedure TWriter.WriteCollection(Value: TCollection);
var
  i: Integer;
begin
  Driver.BeginCollection;
  if Assigned(Value) then
    for i := 0 to Value.Count - 1 do
    begin
      { Each collection item needs its own ListBegin/ListEnd tag, or else the
        reader wouldn't be able to know where an item ends and where the next
        one starts }
      WriteListBegin;
      WriteProperties(Value.Items[i]);
      WriteListEnd;
    end;
  WriteListEnd;
end;

procedure TWriter.DetermineAncestor(Component : TComponent);

Var
  I : Integer;

begin
  // Should be set only when we write an inherited with children.
  if Not Assigned(FAncestors) then
    exit;
  I:=FAncestors.IndexOf(Component.Name);
  If (I=-1) then
    begin
    FAncestor:=Nil;
    FAncestorPos:=-1;
    end
  else
    With TPosComponent(FAncestors.Objects[i]) do
      begin
      FAncestor:=FComponent;
      FAncestorPos:=FPos;
      end;
end;

procedure TWriter.DoFindAncestor(Component : TComponent);

Var
  C : TComponent;

begin
  if Assigned(FOnFindAncestor) then
    if (Ancestor=Nil) or (Ancestor is TComponent) then
      begin
      C:=TComponent(Ancestor);
      FOnFindAncestor(Self,Component,Component.Name,C,FRootAncestor);
      Ancestor:=C;
      end;
end;

procedure TWriter.WriteComponent(Component: TComponent);

var
  SA : TPersistent;
  SR, SRA : TComponent;
begin
  SR:=FRoot;
  SA:=FAncestor;
  SRA:=FRootAncestor;
  Try
    Component.FComponentState:=Component.FComponentState+[csWriting];
    Try
      // Possibly set ancestor.
      DetermineAncestor(Component);
      DoFindAncestor(Component); // Mainly for IDE when a parent form had an ancestor renamed...
      // Will call WriteComponentData.
      Component.WriteState(Self);
      FDriver.EndList;
    Finally
      Component.FComponentState:=Component.FComponentState-[csWriting];
    end;
  Finally
    FAncestor:=SA;
    FRoot:=SR;
    FRootAncestor:=SRA;
  end;
end;

procedure TWriter.WriteChildren(Component : TComponent);

Var
  SRoot, SRootA : TComponent;
  SList : TStringList;
  SPos : Integer;
  I : Integer;
  
begin
  // Write children list. 
  // While writing children, the ancestor environment must be saved
  // This is recursive...
  SRoot:=FRoot;
  SRootA:=FRootAncestor;
  SList:=FAncestors;
  SPos:=FCurrentPos;
  try
    FAncestors:=Nil;
    FCurrentPos:=0;
    FAncestorPos:=-1;
    if csInline in Component.ComponentState then
       FRoot:=Component;
    if (FAncestor is TComponent) then
       begin
       FAncestors:=TStringList.Create;
       if csInline in TComponent(FAncestor).ComponentState then
         FRootAncestor := TComponent(FAncestor);
       TComponent(FAncestor).GetChildren(
                   {$ifdef FPC}@{$endif}AddToAncestorList,FRootAncestor);
       FAncestors.Sorted:=True;
       end;
    try
      Component.GetChildren({$ifdef FPC}@{$endif}WriteComponent, FRoot);
    Finally
      If Assigned(Fancestors) then
        For I:=0 to FAncestors.Count-1 do 
          FAncestors.Objects[i].Free;
      FreeAndNil(FAncestors);
    end;    
  finally
    FAncestors:=Slist;
    FRoot:=SRoot;
    FRootAncestor:=SRootA;
    FCurrentPos:=SPos;
    FAncestorPos:=Spos;
  end;
end;

procedure TWriter.WriteComponentData(Instance: TComponent);
var 
  Flags: TFilerFlags;
begin
  Flags := [];
  If (Assigned(FAncestor)) and  //has ancestor
     (not (csInline in Instance.ComponentState) or // no inline component
      // .. or the inline component is inherited
      (csAncestor in Instance.Componentstate) and (FAncestors <> nil)) then
    Flags:=[ffInherited]
  else If csInline in Instance.ComponentState then
    Flags:=[ffInline];
  If (FAncestors<>Nil) and ((FCurrentPos<>FAncestorPos) or (FAncestor=Nil)) then
    Include(Flags,ffChildPos);
  FDriver.BeginComponent(Instance,Flags,FCurrentPos);
  If (FAncestors<>Nil) then
    Inc(FCurrentPos);
  WriteProperties(Instance);
  WriteListEnd;
  // Needs special handling of ancestor.
  If not IgnoreChildren then
    WriteChildren(Instance);
end;

procedure TWriter.WriteDescendent(ARoot: TComponent; AAncestor: TComponent);
begin
  FRoot := ARoot;
  FAncestor := AAncestor;
  FRootAncestor := AAncestor;
  FLookupRoot := ARoot;

  WriteComponent(ARoot);
end;

{$ifndef FPUNONE}
procedure TWriter.WriteFloat(const Value: Extended);
begin
  Driver.WriteFloat(Value);
end;

procedure TWriter.WriteSingle(const Value: Single);
begin
  Driver.WriteSingle(Value);
end;
{$endif}

procedure TWriter.WriteCurrency(const Value: Currency);
begin
  Driver.WriteCurrency(Value);
end;

{$ifndef FPUNONE}
procedure TWriter.WriteDate(const Value: TDateTime);
begin
  Driver.WriteDate(Value);
end;
{$endif}

procedure TWriter.WriteIdent(const Ident: string);
begin
  Driver.WriteIdent(Ident);
end;

procedure TWriter.WriteInteger(Value: LongInt);
begin
  Driver.WriteInteger(Value);
end;

procedure TWriter.WriteInteger(Value: Int64);
begin
  Driver.WriteInteger(Value);
end;

procedure twriter.writeset(value: longword; settype: ptypeinfo); 

begin
 driver.writeset(value,
                 gettypedata(settype)^.comptype{$ifndef FPC}^{$endif});
end;

procedure twriter.writeenum(value: longint; enumtype: ptypeinfo); 

begin
 driver.writeident(getenumname(enumtype,value));
end;

procedure TWriter.WriteVariant(const VarValue: Variant);
begin
  Driver.WriteVariant(VarValue);
end;

procedure TWriter.WriteListBegin;
begin
  Driver.BeginList;
end;

procedure TWriter.WriteListEnd;
begin
  Driver.EndList;
end;

procedure TWriter.WriteProperties(Instance: TPersistent);
var PropCount,i : integer;
    PropList  : PPropList;
begin
  PropCount:=GetPropList(Instance,PropList);
  if PropCount>0 then 
    try
      for i := 0 to PropCount-1 do
        if IsStoredProp(Instance,PropList^[i]) then
          WriteProperty(Instance,PropList^[i]);
    Finally    
      Freemem(PropList);
    end;
  Instance.DefineProperties(Self);
end;


procedure TWriter.WriteProperty(Instance: TPersistent; PropInfo: Pointer);
var
  HasAncestor: Boolean;
  PropType: PTypeInfo;
  Value, DefValue: LongInt;
  Ident: String;
  IntToIdentFn: TIntToIdent;
{$ifndef FPUNONE}
  FloatValue, DefFloatValue: Extended;
{$endif}
  MethodValue: TMethod;
  DefMethodValue: TMethod;
  WStrValue, WDefStrValue: WideString;
  StrValue, DefStrValue: String;
  UStrValue, UDefStrValue: UnicodeString;
  AncestorObj: TObject;
  C,Component: TComponent;
  ObjValue: TObject;
  SavedAncestor: TPersistent;
  SavedPropPath, Name: String;
  Int64Value, DefInt64Value: Int64;
  VarValue, DefVarValue : tvardata;
  BoolValue, DefBoolValue: boolean;
  Handled: Boolean;

begin
  // do not stream properties without getter
  if not Assigned(PPropInfo(PropInfo)^.GetProc) then
    exit;
  // properties without setter are only allowed, if they are subcomponents
  PropType := PPropInfo(PropInfo)^.PropType{$ifndef FPC}^{$endif};
  if not Assigned(PPropInfo(PropInfo)^.SetProc) then begin
    if PropType^.Kind<>tkClass then
      exit;
    ObjValue := TObject(GetObjectProp(Instance, PropInfo));
    if not ObjValue.InheritsFrom(TComponent) or
       not (csSubComponent in TComponent(ObjValue).ComponentStyle) then
      exit;
  end;

  { Check if the ancestor can be used }
  HasAncestor := Assigned(Ancestor) and ((Instance = Root) or
    (Instance.ClassType = Ancestor.ClassType));
  //writeln('TWriter.WriteProperty Name=',PropType^.Name,' Kind=',GetEnumName(TypeInfo(TTypeKind),ord(PropType^.Kind)),' HasAncestor=',HasAncestor);

  case PropType^.Kind of
    tkInteger, tkChar, tkEnumeration, tkSet, tkWChar:
      begin
        Value := GetOrdProp(Instance, PropInfo);
        if HasAncestor then
          DefValue := GetOrdProp(Ancestor, PropInfo)
        else
          DefValue := PPropInfo(PropInfo)^.Default;
        // writeln(PPropInfo(PropInfo)^.Name, ', HasAncestor=', ord(HasAncestor), ', Value=', Value, ', Default=', DefValue);
        if (Value <> DefValue) or (DefValue=longint($80000000)) then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          case PropType^.Kind of
            tkInteger:
              begin
                // Check if this integer has a string identifier
                IntToIdentFn := FindIntToIdent(PPropInfo(PropInfo)^.PropType);
                if Assigned(IntToIdentFn) and IntToIdentFn(Value, Ident) then
                  // Integer can be written a human-readable identifier
                  WriteIdent(Ident)
                else
                  // Integer has to be written just as number
                  WriteInteger(Value);
              end;
            tkChar:
              WriteChar(Chr(Value));
            tkWChar:
              WriteWideChar(WideChar(Value));
            tkSet:
              Driver.WriteSet(Value, GetTypeData(PropType)^.CompType);
            tkEnumeration:
              WriteIdent(GetEnumName(PropType, Value));
          end;
          Driver.EndProperty;
        end;
      end;
{$ifndef FPUNONE}
    tkFloat:
      begin
        FloatValue := GetFloatProp(Instance, PropInfo);
        if HasAncestor then
          DefFloatValue := GetFloatProp(Ancestor, PropInfo)
        else
          begin
          DefValue :=PPropInfo(PropInfo)^.Default;
          DefFloatValue:=PSingle(@PPropInfo(PropInfo)^.Default)^;
          end;
        if (FloatValue<>DefFloatValue) or (DefValue=longint($80000000)) then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteFloat(FloatValue);
          Driver.EndProperty;
        end;
      end;
{$endif}
    tkMethod:
      begin
        MethodValue := GetMethodProp(Instance, PropInfo);
        if HasAncestor then
          DefMethodValue := GetMethodProp(Ancestor, PropInfo)
        else begin
          DefMethodValue.Data := nil;
          DefMethodValue.Code := nil;
        end;

        Handled:=false;
        if Assigned(OnWriteMethodProperty) then
          OnWriteMethodProperty(Self,Instance,PPropInfo(PropInfo),MethodValue,
            DefMethodValue,Handled);
        if (not Handled) and
          (MethodValue.Code <> DefMethodValue.Code) and
          ((not Assigned(MethodValue.Code)) or
          ((Length(FLookupRoot.MethodName(MethodValue.Code)) > 0))) then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          if Assigned(MethodValue.Code) then
            Driver.WriteMethodName(FLookupRoot.MethodName(MethodValue.Code))
          else
            Driver.WriteMethodName('');
          Driver.EndProperty;
        end;
      end;
{$ifdef FPC}
    tkSString, tkLString, tkAString:
{$else}
    tkString, tkLString:
{$endif}
      begin
        StrValue := GetStrProp(Instance, PropInfo);
        if HasAncestor then
          DefStrValue := GetStrProp(Ancestor, PropInfo)
        else
          SetLength(DefStrValue, 0);

        if StrValue <> DefStrValue then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          if Assigned(FOnWriteStringProperty) then
            FOnWriteStringProperty(Self,Instance,PropInfo,StrValue);
          WriteString(StrValue);
          Driver.EndProperty;
        end;
      end;
    tkWString:
      begin
        WStrValue := GetWideStrProp(Instance, PropInfo);
        if HasAncestor then
          WDefStrValue := GetWideStrProp(Ancestor, PropInfo)
        else
          SetLength(WDefStrValue, 0);

        if WStrValue <> WDefStrValue then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteWideString(WStrValue);
          Driver.EndProperty;
        end;
      end;
{$ifdef FPC}
    tkUString:
      begin
        UStrValue := GetUnicodeStrProp(Instance, PropInfo);
        if HasAncestor then
          UDefStrValue := GetUnicodeStrProp(Ancestor, PropInfo)
        else
          SetLength(UDefStrValue, 0);

        if UStrValue <> UDefStrValue then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteUnicodeString(UStrValue);
          Driver.EndProperty;
        end;
      end;
{$endif}
    tkVariant:
      begin
        { Ensure that a Variant manager is installed }
  {$ifdef FPC}
        if not assigned(VarClearProc) then
          raise EWriteError.Create(SErrNoVariantSupport);
  {$endif}
        VarValue := tvardata(GetVariantProp(Instance, PropInfo));
        if HasAncestor then
          DefVarValue := tvardata(GetVariantProp(Ancestor, PropInfo))
        else
          FillChar(DefVarValue,sizeof(DefVarValue),0);
{$ifdef FPC}
        if (CompareByte(VarValue,DefVarValue,sizeof(VarValue)) <> 0) then
{$else}
        if Comparemem(@VarValue,@DefVarValue,sizeof(VarValue)) then
{$endif}
          begin
            Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
            { can't use variant() typecast, pulls in variants unit }
            WriteVariant(pvariant(@VarValue)^);
            Driver.EndProperty;
          end;
      end;
    tkClass:
      begin
        ObjValue := TObject(GetObjectProp(Instance, PropInfo));
        if HasAncestor then
        begin
          AncestorObj := TObject(GetObjectProp(Ancestor, PropInfo));
          if (AncestorObj is TComponent) and
             (ObjValue is TComponent) then
          begin
            //writeln('TWriter.WriteProperty AncestorObj=',TComponent(AncestorObj).Name,' OwnerFit=',TComponent(AncestorObj).Owner = FRootAncestor,' ',TComponent(ObjValue).Name,' OwnerFit=',TComponent(ObjValue).Owner = Root);
            if (AncestorObj<> ObjValue) and
             (TComponent(AncestorObj).Owner = FRootAncestor) and
             (TComponent(ObjValue).Owner = Root) and
             (UpperCase(TComponent(AncestorObj).Name) = UpperCase(TComponent(ObjValue).Name)) then
            begin
              // different components, but with the same name
              // treat it like an override
              AncestorObj := ObjValue;
            end;
          end;
        end else
          AncestorObj := nil;

        if not Assigned(ObjValue) then
          begin
          if ObjValue <> AncestorObj then
            begin
            Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
            Driver.WriteIdent('NIL');
            Driver.EndProperty;
            end
          end
        else if ObjValue.InheritsFrom(TPersistent) then
          begin
          { Subcomponents are streamed the same way as persistents }
          if ObjValue.InheritsFrom(TComponent)
            and ((not (csSubComponent in TComponent(ObjValue).ComponentStyle)) 
                 or ((TComponent(ObjValue).Owner<>Instance) and (TComponent(ObjValue).Owner<>Nil))) then
            begin
            Component := TComponent(ObjValue);
            if (ObjValue <> AncestorObj)
                and not (csTransient in Component.ComponentStyle) then
              begin
              Name:= '';
              C:= Component;
              While (C<>Nil) and (C.Name<>'') do
                begin
                If (Name<>'') Then
                  Name:='.'+Name;
                if C.Owner = LookupRoot then
                  begin
                  Name := C.Name+Name;
                  break;
                  end
                else if C = LookupRoot then
                  begin
                  Name := 'Owner' + Name;
                  break;
                  end;
                Name:=C.Name + Name;
                C:= C.Owner;
                end;
              if (C=nil) and (Component.Owner=nil) then 
                if (Name<>'') then              //foreign root
                  Name:=Name+'.Owner';
              if Length(Name) > 0 then
                begin
                Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
                WriteIdent(Name);
                Driver.EndProperty;
                end;  // length Name>0
              end; //(ObjValue <> AncestorObj)
            end // ObjValue.InheritsFrom(TComponent)
          else if ObjValue.InheritsFrom(TCollection) then
            begin
            if (not HasAncestor) or (not CollectionsEqual(TCollection(ObjValue),
              TCollection(GetObjectProp(Ancestor, PropInfo)),root,rootancestor)) then
              begin
              Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
              SavedPropPath := FPropPath;
              try
                SetLength(FPropPath, 0);
                WriteCollection(TCollection(ObjValue));
              finally
                FPropPath := SavedPropPath;
                Driver.EndProperty;
              end;
              end;
            end // Tcollection
          else
            begin
            SavedAncestor := Ancestor;
            SavedPropPath := FPropPath;
            try
              FPropPath := FPropPath + PPropInfo(PropInfo)^.Name + '.';
              if HasAncestor then
                Ancestor := TPersistent(GetObjectProp(Ancestor, PropInfo));
              WriteProperties(TPersistent(ObjValue));
            finally
              Ancestor := SavedAncestor;
              FPropPath := SavedPropPath;
            end;
            end;
          end; // Inheritsfrom(TPersistent)
      end;
    tkInt64 {$ifdef FPC}, tkQWord{$endif}:
      begin
        Int64Value := GetInt64Prop(Instance, PropInfo);
        if HasAncestor then
          DefInt64Value := GetInt64Prop(Ancestor, PropInfo)
        else
          DefInt64Value := 0;
        if Int64Value <> DefInt64Value then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteInteger(Int64Value);
          Driver.EndProperty;
        end;
      end;
{$ifdef FPC}
    tkBool:
      begin
        BoolValue := GetOrdProp(Instance, PropInfo)<>0;
        if HasAncestor then
          DefBoolValue := GetOrdProp(Ancestor, PropInfo)<>0
        else
          begin
          DefBoolValue := PPropInfo(PropInfo)^.Default<>0;
          DefValue:=PPropInfo(PropInfo)^.Default;
          end;
        // writeln(PPropInfo(PropInfo)^.Name, ', HasAncestor=', ord(HasAncestor), ', Value=', Value, ', Default=', DefBoolValue);
        if (BoolValue<>DefBoolValue) or (DefValue=longint($80000000)) then
          begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteBoolean(BoolValue);
          Driver.EndProperty;
          end;
      end;
{$endif}
  end;
end;

procedure TWriter.WriteRootComponent(ARoot: TComponent);
begin
  WriteDescendent(ARoot, nil);
end;

procedure TWriter.WriteString(const Value: String);
begin
  Driver.WriteString(Value);
end;

procedure TWriter.WriteWideString(const Value: WideString);
begin
  Driver.WriteWideString(Value);
end;

procedure TWriter.WriteUnicodeString(const Value: UnicodeString);
begin
  Driver.WriteUnicodeString(Value);
end;

function twriter.getclassname(const aobj: tobject): shortstring;
begin
 result:= aobj.classname;
end;

{****************************************************************************}
{*                         TBinaryObjectWriter                              *}
{****************************************************************************}

{$ifndef FPUNONE}
{$IFNDEF FPC_HAS_TYPE_EXTENDED}
procedure DoubleToExtended(d : double; e : pointer);
var mant : qword;
    exp : smallint;
    sign : boolean;
begin
  mant:= (qword(d) and $000FFFFFFFFFFFFF) shl 12;
  exp := (qword(d) shr 52) and $7FF;
  sign:= (qword(d) and $8000000000000000) <> 0;
  case exp of
   0: begin
    if mant <> 0 then begin //denormalized value: hidden bit is 0. normalize it
     exp:=16383-1022;
     while (mant and $8000000000000000) = 0 do begin
      dec(exp);
      mant:= mant shl 1;
     end;
     dec(exp); //don't shift, most significant bit is not hidden in extended
    end;
   end;
   2047: begin
    exp:= $7FFF; //either infinity or NaN
    mant:= qword(d) and $000FFFFFFFFFFFFF or $8000000000000000;
   end;
   else begin
    inc(exp,16383-1023);
    mant:= (mant shr 1) or $8000000000000000; //unhide hidden bit
   end;
  end;
  if sign then exp:=exp or $8000;
  mant:=NtoLE(mant);
  exp:=NtoLE(word(exp));
  move(mant,pbyte(e)[0],8); //mantissa         : bytes 0..7
  move(exp,pbyte(e)[8],2);  //exponent and sign: bytes 8..9
end;
{$ENDIF}
{$endif}

procedure TBinaryObjectWriter.WriteWord(w : word); 
                     {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
begin
  w:=NtoLE(w);
  Write(w,2);
end;

procedure TBinaryObjectWriter.WriteDWord(lw : longword); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
begin
  lw:=NtoLE(lw);
  Write(lw,4);
end;

procedure TBinaryObjectWriter.WriteQWord(qw : qword); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
begin
{$ifdef FPC}
  qw:=NtoLE(qw);
{$endif}
  Write(qw,8);
end;

{$ifndef FPUNONE}
procedure TBinaryObjectWriter.WriteExtended(e : extended); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
{$IFNDEF FPC_HAS_TYPE_EXTENDED}
var ext : array[0..9] of byte;
{$ENDIF}
begin
{$IFNDEF FPC_HAS_TYPE_EXTENDED}
  {$IFDEF FPC_DOUBLE_HILO_SWAPPED}
  { SwapDoubleHiLo defined in reader.inc }
  SwapDoubleHiLo(e);
  {$ENDIF FPC_DOUBLE_HILO_SWAPPED}
  DoubleToExtended(e,@(ext[0]));
  Write(ext[0],10);
{$ELSE}
  Write(e,sizeof(e));
{$ENDIF}
end;
{$endif}

constructor TBinaryObjectWriter.Create(Stream: TStream; BufSize: Integer);
begin
  inherited Create;
  If (Stream=Nil) then
    Raise EWriteError.Create(SEmptyStreamIllegalWriter);
  FStream := Stream;
  FBufSize := BufSize;
  GetMem(FBuffer, BufSize);
end;

destructor TBinaryObjectWriter.Destroy;
begin
  // Flush all data which hasn't been written yet
  FlushBuffer;

  if Assigned(FBuffer) then
    FreeMem(FBuffer, FBufSize);

  inherited Destroy;
end;

procedure TBinaryObjectWriter.BeginCollection;
begin
  WriteValue(vaCollection);
end;

procedure TBinaryObjectWriter.BeginComponent(Component: TComponent;
  Flags: TFilerFlags; ChildPos: Integer);
var
  Prefix: Byte;
begin
  if not FSignatureWritten then
  begin
    Write(FilerSignature, SizeOf(FilerSignature));
    FSignatureWritten := True;
  end;

  { Only write the flags if they are needed! }
  if Flags <> [] then
  begin
    Prefix := {$ifdef FPC}longword{$else}byte{$endif}(Flags) or $f0;
    Write(Prefix, 1);
    if ffChildPos in Flags then
      WriteInteger(ChildPos);
  end;
  if fwriter <> nil then begin
   WriteStr(fwriter.getclassname(Component));
  end
  else begin   
   WriteStr(Component.ClassName);
  end;
  WriteStr(Component.Name);
end;

procedure TBinaryObjectWriter.BeginList;
begin
  WriteValue(vaList);
end;

procedure TBinaryObjectWriter.EndList;
begin
  WriteValue(vaNull);
end;

procedure TBinaryObjectWriter.BeginProperty(const PropName: String);
begin
  WriteStr(PropName);
end;

procedure TBinaryObjectWriter.EndProperty;
begin
end;

procedure TBinaryObjectWriter.WriteBinary(const Buffer; Count: LongInt);
begin
  WriteValue(vaBinary);
  WriteDWord(longword(Count));
  Write(Buffer, Count);
end;

procedure TBinaryObjectWriter.WriteBoolean(Value: Boolean);
begin
  if Value then
    WriteValue(vaTrue)
  else
    WriteValue(vaFalse);
end;

{$ifndef FPUNONE}
procedure TBinaryObjectWriter.WriteFloat(const Value: Extended);
begin
  WriteValue(vaExtended);
  WriteExtended(Value);
end;

procedure TBinaryObjectWriter.WriteSingle(const Value: Single);
begin
  WriteValue(vaSingle);
{$ifdef FPC}
  WriteDWord(longword(Value));
{$else}
  WriteDWord(longword(ar4ty(Value)));
{$endif}
end;
{$endif}

procedure TBinaryObjectWriter.WriteCurrency(const Value: Currency);
begin
  WriteValue(vaCurrency);
{$ifdef FPC}
  WriteQWord(qword(Value));
{$else}
  WriteQWord(qword(ar8ty(Value)));
{$endif}
end;


{$ifndef FPUNONE}
procedure TBinaryObjectWriter.WriteDate(const Value: TDateTime);
begin
  WriteValue(vaDate);
{$ifdef FPC}
  WriteQWord(qword(Value));
{$else}
  WriteQWord(qword(ar8ty(Value)));
{$endif}
end;
{$endif}

procedure TBinaryObjectWriter.WriteIdent(const Ident: string);
begin
  { Check if Ident is a special identifier before trying to just write
    Ident directly }
  if UpperCase(Ident) = 'NIL' then
    WriteValue(vaNil)
  else if UpperCase(Ident) = 'FALSE' then
    WriteValue(vaFalse)
  else if UpperCase(Ident) = 'TRUE' then
    WriteValue(vaTrue)
  else if UpperCase(Ident) = 'NULL' then
    WriteValue(vaNull) else
  begin
    WriteValue(vaIdent);
    WriteStr(Ident);
  end;
end;

procedure TBinaryObjectWriter.WriteInteger(Value: Int64);
var
  s: ShortInt;
  i: SmallInt;
  l: Longint;
begin
  { Use the smallest possible integer type for the given value: }
  if (Value >= -128) and (Value <= 127) then
  begin
    WriteValue(vaInt8);
    s := Value;
    Write(s, 1);
  end else if (Value >= -32768) and (Value <= 32767) then
  begin
    WriteValue(vaInt16);
    i := Value;
    WriteWord(word(i));
{$ifdef FPC}
  end else if (Value >= -$80000000) and (Value <= $7fffffff) then
{$else}
  end else if (Value >= $80000000) and (Value <= $7fffffff) then
{$endif}
  begin
    WriteValue(vaInt32);
    l := Value;
    WriteDWord(longword(l));
  end else
  begin
    WriteValue(vaInt64);
    WriteQWord(qword(Value));
  end;
end;

procedure TBinaryObjectWriter.WriteUInt64(Value: QWord);
var
  s: ShortInt;
  i: SmallInt;
  l: Longint;
begin
  { Use the smallest possible integer type for the given value: }
  if (Value <= 127) then
  begin
    WriteValue(vaInt8);
    s := Value;
    Write(s, 1);
  end else if (Value <= 32767) then
  begin
    WriteValue(vaInt16);
    i := Value;
    WriteWord(word(i));
  end else if (Value <= $7fffffff) then
  begin
    WriteValue(vaInt32);
    l := Value;
    WriteDWord(longword(l));
  end else
  begin
{$ifdef FPC}
    WriteValue(vaQWord);
{$else}
    WriteValue(vaint64);
{$endif}
    WriteQWord(Value);
  end;
end;


procedure TBinaryObjectWriter.WriteMethodName(const Name: String);
begin
  if Length(Name) > 0 then
  begin
    WriteValue(vaIdent);
    WriteStr(Name);
  end else
    WriteValue(vaNil);
end;

procedure TBinaryObjectWriter.WriteSet(Value: LongInt; SetType: Pointer);
type
  tset = set of 0..31;
var
  i: Integer;
begin
  WriteValue(vaSet);
  for i := 0 to 31 do
  begin
    if (i in tset(Value)) then
      WriteStr(GetEnumName(PTypeInfo(SetType), i));
  end;
  WriteStr('');
end;

procedure TBinaryObjectWriter.WriteString(const Value: String);
var
  i: Integer;
  b: byte;
begin
  i := Length(Value);
  if i <= 255 then
  begin
    WriteValue(vaString);
    b := i;
    Write(b, 1);
  end else
  begin
    WriteValue(vaLString);
    WriteDWord(longword(i));
  end;
  if i > 0 then
    Write(Value[1], i);
end;

procedure TBinaryObjectWriter.WriteWideString(const Value: WideString);
var len : longword;
{$IFDEF ENDIAN_BIG}
    i : integer;
    ws : widestring;
{$ENDIF}
begin
  WriteValue(vaWString);
  len:=Length(Value);
  WriteDWord(len);
  if len > 0 then
  begin
    {$IFDEF ENDIAN_BIG}
    setlength(ws,len);
    for i:=1 to len do
      ws[i]:=widechar(SwapEndian(word(Value[i])));
    Write(ws[1], len*sizeof(widechar));
    {$ELSE}
    Write(Value[1], len*sizeof(widechar));
    {$ENDIF}
  end;
end;
                      
procedure TBinaryObjectWriter.WriteUnicodeString(const Value: UnicodeString);
var len : longword;
{$IFDEF ENDIAN_BIG}
    i : integer;
    us : UnicodeString;
{$ENDIF}
begin
  WriteValue(vaUString);
  len:=Length(Value);
  WriteDWord(len);
  if len > 0 then
  begin
    {$IFDEF ENDIAN_BIG}
    setlength(us,len);
    for i:=1 to len do
      us[i]:=widechar(SwapEndian(word(Value[i])));
    Write(us[1], len*sizeof(UnicodeChar));
    {$ELSE}
    Write(Value[1], len*sizeof(UnicodeChar));
    {$ENDIF}
  end;
end;

procedure TBinaryObjectWriter.WriteVariant(const VarValue: variant);
begin
  { The variant manager will handle varbyref and vararray transparently for us
  }
  case (tvardata(VarValue).vtype and varTypeMask) of
    varEmpty:
      begin
        WriteValue(vaNil);
      end;
    varNull:
      begin
        WriteValue(vaNull);
      end;
    { all integer sizes must be split for big endian systems }
    varShortInt,varSmallInt,varInteger,varInt64:
      begin
        WriteInteger(VarValue);
      end;
{$ifdef FPC}
    varQWord:
      begin
        WriteUInt64(VarValue);
      end;
{$endif}
    varBoolean:
      begin
        WriteBoolean(VarValue);
      end;
    varCurrency:
      begin
        WriteCurrency(VarValue);
      end;
{$ifndef fpunone}
    varSingle:
      begin
        WriteSingle(VarValue);
      end;
    varDouble:
      begin
        WriteFloat(VarValue);
      end;
    varDate:
      begin
        WriteDate(VarValue);
      end;
{$endif fpunone}
    varOleStr,varString:
      begin
        WriteWideString(VarValue);
      end;
    else
      raise EWriteError.CreateFmt(SUnsupportedPropertyVariantType, [Ord(tvardata(VarValue).vtype)]);
  end;
end;


procedure TBinaryObjectWriter.FlushBuffer;
begin
  FStream.WriteBuffer(FBuffer^, FBufPos);
  FBufPos := 0;
end;

procedure TBinaryObjectWriter.Write(const Buffer; Count: LongInt);
var
  CopyNow: LongInt;
  SourceBuf: PChar;
begin
  SourceBuf:=@Buffer;
  while Count > 0 do
  begin
    CopyNow := Count;
    if CopyNow > FBufSize - FBufPos then
      CopyNow := FBufSize - FBufPos;
    Move(SourceBuf^, PChar(FBuffer)[FBufPos], CopyNow);
    Dec(Count, CopyNow);
    Inc(FBufPos, CopyNow);
    inc(SourceBuf, CopyNow);
    if FBufPos = FBufSize then
      FlushBuffer;
  end;
end;

procedure TBinaryObjectWriter.WriteValue(Value: TValueType);
var
  b: byte;
begin
  b := byte(Value);
  Write(b, 1);
end;

procedure TBinaryObjectWriter.WriteStr(const Value: String);
var
  i: integer;
  b: byte;
begin
  i := Length(Value);
  if i > 255 then
    i := 255;
  b := i;
  Write(b, 1);
  if i > 0 then
    Write(Value[1], i);
end;

var
  ClassList : TThreadlist;
  ClassAliasList : TStringList;

procedure RegisterClass(AClass: TPersistentClass);
var
aClassname : String;
begin
  //Classlist is created during initialization.
 {
  if classlist = nil then begin
   classlist:= tthreadlist.create; 
         //initialization order sometimes wrong in FPC
  end;
  if classaliaslist = nil then begin
   classaliaslist:= tstringlist.create; 
         //initialization order sometimes wrong in FPC
  end;
 }
  with Classlist.Locklist do
     try
      while Indexof(AClass) = -1 do
         begin
           aClassname := AClass.ClassName;
           if GetClass(aClassName) <> nil then  //class alread registered!
                 Begin
                 //raise an error
                 exit;
                 end;
          Add(AClass);
          if AClass = TPersistent then break;
          AClass := TPersistentClass(AClass.ClassParent);
         end;
     finally
       ClassList.UnlockList;
     end;
end;

procedure RegisterClasses(AClasses: array of TPersistentClass);
var
I : Integer;
begin
for I := low(aClasses) to high(aClasses) do
       RegisterClass(aClasses[I]);
end;

procedure RegisterClassAlias(AClass: TPersistentClass; const Alias: string);
  var
    I : integer;
  begin
    i := ClassAliasList.IndexOf(Alias);
    if I = -1 then
      ClassAliasList.AddObject( Alias, TObject(AClass) );
  end;

procedure UnRegisterClass(AClass: TPersistentClass);
begin
 //dummy
end;

procedure UnRegisterClasses(AClasses: array of TPersistentClass);
begin
 //dummy
end;

procedure UnRegisterModuleClasses(Module: HMODULE);
begin
 //dummy
end;

function FindClass(const AClassName: string): TPersistentClass;

begin
  Result := GetClass(AClassName);
  if not Assigned(Result) then
    raise EClassNotFound.CreateFmt(SClassNotFound, [AClassName]);
end;

function GetClass(const AClassName: string): TPersistentClass;
var
I : Integer;
begin
  with ClassList.LockList do
   try
    for I := 0 to Count-1 do
       begin
        Result := TPersistentClass(Items[I]);
        if Result.ClassNameIs(AClassName) then Exit;
       end;
       I := ClassAliasList.Indexof(AClassName);
       if I >= 0 then  //found
          Begin
          Result := TPersistentClass(ClassAliasList.Objects[i]);
          exit;
          end;
       Result := nil;
    finally
      ClassList.Unlocklist;
    end;
end;

{****************************************************************************}
{*                             TFileStream                                  *}
{****************************************************************************}

constructor TFileStream.Create(const AFileName: string; Mode: Word);

begin
  Create(AFileName,Mode,438);
end;


constructor TFileStream.Create(const AFileName: string; Mode: Word; Rights: Cardinal);

begin
  FFileName:=AFileName;
  If (Mode and fmCreate) > 0 then
{$ifdef FPC}
    FHandle:=FileCreate(AFileName,Mode,Rights)
{$else}
    FHandle:=FileCreate(AFileName,Rights)
{$endif}
  else
    FHAndle:=FileOpen(AFileName,Mode);

  If (THandle(FHandle) = feInvalidHandle) then
    If Mode=fmcreate then
      raise EFCreateError.createfmt(SFCreateError,[AFileName])
    else
      raise EFOpenError.Createfmt(SFOpenError,[AFilename]);
end;


destructor TFileStream.Destroy;

begin
  FileClose(FHandle);
end;

{****************************************************************************}
{*                             THandleStream                                *}
{****************************************************************************}

Constructor THandleStream.Create(AHandle: THandle);

begin
  Inherited Create;
  FHandle:=AHandle;
end;


function THandleStream.Read(var Buffer; Count: Longint): Longint;

begin
  Result:=FileRead(FHandle,Buffer,Count);
  If Result=-1 then Result:=0;
end;


function THandleStream.Write(const Buffer; Count: Longint): Longint;

begin
  Result:=FileWrite (FHandle,Buffer,Count);
  If Result=-1 then Result:=0;
end;

Procedure THandleStream.SetSize(NewSize: Longint);

begin
  SetSize(Int64(NewSize));
end;


Procedure THandleStream.SetSize(const NewSize: Int64);

begin
  syserror(sys_truncatefile(FHandle,NewSize));
end;


function THandleStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;

begin
  Result:=FileSeek(FHandle,Offset,ord(Origin));
end;

{****************************************************************************}
{*                             TStringStream                                *}
{****************************************************************************}

function TStringStream.GetSize: Int64;
begin
  Result:=Length(FDataString);
end;

function TStringStream.GetPosition: Int64;
begin
  Result:=FPosition;
end;

procedure TStringStream.SetSize(NewSize: Longint);

begin
 Setlength(FDataString,NewSize);
 If FPosition>NewSize then FPosition:=NewSize;
end;


constructor TStringStream.Create(const AString: string);

begin
  Inherited create;
  FDataString:=AString;
end;


function TStringStream.Read(var Buffer; Count: Longint): Longint;

begin
  Result:=Length(FDataString)-FPosition;
  If Result>Count then Result:=Count;
  // This supposes FDataString to be of type AnsiString !
  Move (Pchar(FDataString)[FPosition],Buffer,Result);
  FPosition:=FPosition+Result;
end;


function TStringStream.ReadString(Count: Longint): string;

Var NewLen : Longint;

begin
  NewLen:=Length(FDataString)-FPosition;
  If NewLen>Count then NewLen:=Count;
  SetLength(Result,NewLen);
  Read (Pointer(Result)^,NewLen);
end;


function TStringStream.Seek(Offset: Longint; Origin: Word): Longint;

begin
  Case Origin of
    soFromBeginning : FPosition:=Offset;
    soFromEnd       : FPosition:=Length(FDataString)+Offset;
    soFromCurrent   : FPosition:=FPosition+Offset;
  end;
  If FPosition>Length(FDataString) then
    FPosition:=Length(FDataString)
  else If FPosition<0 then
    FPosition:=0;
  Result:=FPosition;
end;


function TStringStream.Write(const Buffer; Count: Longint): Longint;

begin
  Result:=Count;
  SetSize(FPosition+Count);
  // This supposes that FDataString is of type AnsiString)
  Move (Buffer,PChar(FDataString)[Fposition],Count);
  FPosition:=FPosition+Count;
end;


procedure TStringStream.WriteString(const AString: string);

begin
  Write (PChar(Astring)[0],Length(AString));
end;

function TStringStream.getmemory: pointer;
begin
 result:= pointer(fdatastring);
end;

{$ifdef FPC}
{****************************************************************************}
{*                             TResourceStream                              *}
{****************************************************************************}

{$ifdef UNICODE}
procedure TResourceStream.Initialize(Instance: TFPResourceHMODULE; Name, ResType: PWideChar; NameIsID: Boolean);
  begin
    Res:=FindResource(Instance, Name, ResType);
    if Res=0 then
      if NameIsID then
        raise EResNotFound.CreateFmt(SResNotFound,[IntToStr(PtrInt(Name))])
      else
        raise EResNotFound.CreateFmt(SResNotFound,[Name]);
    Handle:=LoadResource(Instance,Res);
    if Handle=0 then
      if NameIsID then
        raise EResNotFound.CreateFmt(SResNotFound,[IntToStr(PtrInt(Name))])
      else
        raise EResNotFound.CreateFmt(SResNotFound,[Name]);
    SetPointer(LockResource(Handle),SizeOfResource(Instance,Res));
  end;

constructor TResourceStream.Create(Instance: TFPResourceHMODULE; const ResName: WideString; ResType: PWideChar);
  begin
    inherited create;
    Initialize(Instance,PWideChar(ResName),ResType,False);
  end;
constructor TResourceStream.CreateFromID(Instance: TFPResourceHMODULE; ResID: Integer; ResType: PWideChar);
  begin
    inherited create;
    Initialize(Instance,PWideChar(ResID),ResType,True);
  end;
{$else UNICODE}

procedure TResourceStream.Initialize(Instance: TFPResourceHMODULE; Name, ResType: PChar; NameIsID: Boolean);
  begin
    Res:=FindResource(Instance, Name, ResType);
    if Res=0 then
      if NameIsID then
        raise EResNotFound.CreateFmt(SResNotFound,[IntToStr(PtrInt(Name))])
      else
        raise EResNotFound.CreateFmt(SResNotFound,[Name]);
    Handle:=LoadResource(Instance,Res);
    if Handle=0 then
      if NameIsID then
        raise EResNotFound.CreateFmt(SResNotFound,[IntToStr(PtrInt(Name))])
      else
        raise EResNotFound.CreateFmt(SResNotFound,[Name]);
    SetPointer(LockResource(Handle),SizeOfResource(Instance,Res));
  end;

constructor TResourceStream.Create(Instance: TFPResourceHMODULE; const ResName: string; ResType: PChar);
  begin
    inherited create;
    Initialize(Instance,pchar(ResName),ResType,False);
  end;
constructor TResourceStream.CreateFromID(Instance: TFPResourceHMODULE; ResID: Integer; ResType: PChar);
  begin
    inherited create;
    Initialize(Instance,pchar(PtrInt(ResID)),ResType,True);
  end;
{$endif UNICODE}


destructor TResourceStream.Destroy;
  begin
    UnlockResource(Handle);
    FreeResource(Handle);
    inherited destroy;
  end;
{$endif}

{****************************************************************************}
{*                             TOwnerStream                                 *}
{****************************************************************************}

constructor TOwnerStream.Create(ASource: TStream);
begin
  FSource:=ASource;
end;

destructor TOwnerStream.Destroy;
begin
  If FOwner then
    FreeAndNil(FSource);
  inherited Destroy;
end;

{****************************************************************************}
{*                             TCollectionItem                              *}
{****************************************************************************}


function TCollectionItem.GetIndex: Integer;

begin
  if FCollection<>nil then
    Result:=FCollection.FItems.IndexOf(Pointer(Self))
  else
    Result:=-1;
end;



procedure TCollectionItem.SetCollection(Value: TCollection);

begin
  IF Value<>FCollection then
    begin
    If FCollection<>Nil then FCollection.RemoveItem(Self);
    if Value<>Nil then Value.InsertItem(Self);
    FCollection:=Value;
    end;
end;



procedure TCollectionItem.Changed(AllItems: Boolean);

begin
 If (FCollection<>Nil) and (FCollection.UpdateCount=0) then
  begin
  If AllItems then
    FCollection.Update(Nil)
  else
    FCollection.Update(Self);
  end;
end;



function TCollectionItem.GetNamePath: string;

begin
  If FCollection<>Nil then
    Result:=FCollection.GetNamePath+'['+IntToStr(Index)+']'
  else
    Result:=ClassName;
end;


function TCollectionItem.GetOwner: TPersistent;

begin
  Result:=FCollection;
end;



function TCollectionItem.GetDisplayName: string;

begin
  Result:=ClassName;
end;



procedure TCollectionItem.SetIndex(Value: Integer);

Var Temp : Longint;

begin
  Temp:=GetIndex;
  If (Temp>-1) and (Temp<>Value) then
    begin
    FCollection.FItems.Move(Temp,Value);
    Changed(True);
    end;
end;


procedure TCollectionItem.SetDisplayName(const Value: string);

begin
  Changed(False);
end;



constructor TCollectionItem.Create(ACollection: TCollection);

begin
  Inherited Create;
  SetCollection(ACollection);
end;



destructor TCollectionItem.Destroy;

begin
  SetCollection(Nil);
  Inherited Destroy;
end;

{****************************************************************************}
{*                          TCollectionEnumerator                           *}
{****************************************************************************}

constructor TCollectionEnumerator.Create(ACollection: TCollection);
begin
  inherited Create;
  FCollection := ACollection;
  FPosition := -1;
end;

function TCollectionEnumerator.GetCurrent: TCollectionItem;
begin
  Result := FCollection.Items[FPosition];
end;

function TCollectionEnumerator.MoveNext: Boolean;
begin
  Inc(FPosition);
  Result := FPosition < FCollection.Count;
end;

{****************************************************************************}
{*                             TCollection                                  *}
{****************************************************************************}

function TCollection.Owner: TPersistent;
begin
  result:=getowner;
end;


function TCollection.GetCount: Integer;

begin
  Result:=FItems.Count;
end;


Procedure TCollection.SetPropName;

Var
  TheOwner : TPersistent;
  PropList : PPropList;
  I, PropCount : Integer;

begin
  FPropName:='';
  TheOwner:=GetOwner;
  if (TheOwner=Nil) Or (TheOwner.Classinfo=Nil) Then Exit;
  // get information from the owner RTTI
  PropCount:=GetPropList(TheOwner, PropList);
  Try
    For I:=0 To PropCount-1 Do
      If (PropList^[i]^.PropType^.Kind=tkClass) And
         (GetObjectProp(TheOwner, PropList^[i], ClassType)=Self) Then
        Begin
          FPropName:=PropList^[i]^.Name;
          Exit;
        End;
  Finally
    FreeMem(PropList);
  End;
end;


function TCollection.GetPropName: string;

Var
  TheOwner : TPersistent;

begin
  Result:=FPropNAme;
  TheOwner:=GetOwner;
  If (Result<>'') or (TheOwner=Nil) Or (TheOwner.Classinfo=Nil) then exit;
  SetPropName;
  Result:=FPropName;
end;


procedure TCollection.InsertItem(Item: TCollectionItem);
begin
  If Not(Item Is FitemClass) then
    exit;
  FItems.add(Pointer(Item));
  Item.FID:=FNextID;
  inc(FNextID);
  SetItemName(Item);
  Notify(Item,cnAdded);
  Changed;
end;


{$ifdef mse_fpc_2_6_2} 
procedure TCollection.RemoveItem(Item: TCollectionItem);
Var
 I : Integer;
begin
 Notify(Item,cnExtracting);
 I:=FItems.IndexOfItem(Item,fromEnd);
 If (I<>-1) then
   FItems.Delete(I);
 Item.FCollection:=Nil;
 Changed;
end;

{$else}

procedure TCollection.RemoveItem(Item: TCollectionItem);
begin
Notify(Item,cnExtracting);
FItems.Remove(Pointer(Item));
Item.FCollection:=Nil;
Changed;
end;
{$endif}

function TCollection.GetAttrCount: Integer;
begin
  Result:=0;
end;


function TCollection.GetAttr(Index: Integer): string;
begin
  Result:='';
end;


function TCollection.GetItemAttr(Index, ItemIndex: Integer): string;
begin
  Result:=TCollectionItem(FItems.Items[ItemIndex]).DisplayName;
end;


function TCollection.GetEnumerator: TCollectionEnumerator;
begin
  Result := TCollectionEnumerator.Create(Self);
end;


function TCollection.GetNamePath: string;
var o : TPersistent;
begin
  o:=getowner;
  if assigned(o) and (propname<>'') then 
     result:=o.getnamepath+'.'+propname
   else
     result:=classname;
end;


procedure TCollection.Changed;
begin
  if FUpdateCount=0 then
    Update(Nil);
end;


function TCollection.GetItem(Index: Integer): TCollectionItem;
begin
  Result:=TCollectionItem(FItems.Items[Index]);
end;


procedure TCollection.SetItem(Index: Integer; Value: TCollectionItem);
begin
  TCollectionItem(FItems.items[Index]).Assign(Value);
end;


procedure TCollection.SetItemName(Item: TCollectionItem);
begin
end;



procedure TCollection.Update(Item: TCollectionItem);
begin
//  FPONotifyObservers(Self,ooChange,Pointer(Item));
end;


constructor TCollection.Create(AItemClass: TCollectionItemClass);
begin
  inherited create;
  FItemClass:=AItemClass;
  FItems:=TFpList.Create;
end;


destructor TCollection.Destroy;
begin
  BeginUpdate; // Prevent OnChange
  DoClear;
  FItems.Free;
  Inherited Destroy;
end;


function TCollection.Add: TCollectionItem;
begin
  Result:=FItemClass.Create(Self);
end;


procedure TCollection.Assign(Source: TPersistent);
Var I : Longint;
begin
  If Source is TCollection then
    begin
    Clear;
    For I:=0 To TCollection(Source).Count-1 do
     Add.Assign(TCollection(Source).Items[I]);
    exit;
    end
  else
    Inherited Assign(Source);
end;


procedure TCollection.BeginUpdate;
begin
  inc(FUpdateCount);
end;


procedure TCollection.Clear;
begin
  if FItems.Count=0 then
    exit; // Prevent Changed
  BeginUpdate;
  try
    DoClear;
  finally
    EndUpdate;
  end;    
end;


procedure TCollection.DoClear;
begin
  While FItems.Count>0 do TCollectionItem(FItems.Last).Free;
end;


procedure TCollection.EndUpdate;
begin
  dec(FUpdateCount);
  if FUpdateCount=0 then
    Changed;
end;


function TCollection.FindItemID(ID: Integer): TCollectionItem;
Var
          I : Longint;
begin
  For I:=0 to Fitems.Count-1 do
   begin
     Result:=TCollectionItem(FItems.items[I]);
     If Result.Id=Id then
       exit;
   end;
  Result:=Nil;
end;


procedure TCollection.Delete(Index: Integer);
Var
  Item : TCollectionItem;
begin
  Item:=TCollectionItem(FItems[Index]);
  Notify(Item,cnDeleting);
  Item.Free;
end;


function TCollection.Insert(Index: Integer): TCollectionItem;
begin
  Result:=Add;
  Result.Index:=Index;
end;


procedure TCollection.Notify(Item: TCollectionItem;Action: TCollectionNotification);
begin
{
  if Assigned(FObservers) then
    Case Action of
      cnAdded      : FPONotifyObservers(Self,ooAddItem,Pointer(Item));
      cnExtracting : FPONotifyObservers(Self,ooDeleteItem,Pointer(Item));
      cnDeleting   : FPONotifyObservers(Self,ooDeleteItem,Pointer(Item));
    end;
}
end;

procedure TCollection.Sort(Const Compare : TCollectionSortCompare);

begin
  BeginUpdate;
  try
    FItems.Sort(TListSortCompare(Compare));
  Finally
    EndUpdate;
  end;
end;

procedure TCollection.Exchange(Const Index1, index2: integer);

begin
  FItems.Exchange(Index1,Index2);
//  FPONotifyObservers(Self,ooChange,Nil);
end;

{****************************************************************************}
{*                             TOwnedCollection                             *}
{****************************************************************************}



Constructor TOwnedCollection.Create(AOwner: TPersistent; AItemClass: TCollectionItemClass);

Begin
  FOwner := AOwner;
  inherited Create(AItemClass);
end;



Function TOwnedCollection.GetOwner: TPersistent;

begin
  Result:=FOwner;
end;

function ExtractStrings(Separators, WhiteSpace: TSysCharSet; Content: PChar; Strings: TStrings): Integer;
var
  b, c : pchar;

  procedure SkipWhitespace;
    begin
      while (c^ in Whitespace) do
        inc (c);
    end;

  procedure AddString;
    var
      l : integer;
      s : string;
    begin
      l := c-b;
      if l > 0 then
        begin
          if assigned(Strings) then
            begin
              setlength(s, l);
              move (b^, s[1],l);
              Strings.Add (s);
            end;
          inc (result);
        end;
    end;

var
  quoted : char;
begin
  result := 0;
  c := Content;
  Quoted := #0;
  Separators := Separators + [#13, #10] - ['''','"'];
  SkipWhitespace;
  b := c;
  while (c^ <> #0) do
    begin
      if (c^ = Quoted) then
        begin
          if ((c+1)^ = Quoted) then
            inc (c)
          else
            Quoted := #0
        end
      else if (Quoted = #0) and (c^ in ['''','"']) then
        Quoted := c^;
      if (Quoted = #0) and (c^ in Separators) then
        begin
          AddString;
          inc (c);
          SkipWhitespace;
          b := c;
        end
      else
        inc (c);
    end;
  if (c <> b) then
    AddString;
end;

procedure CommonInit;
begin
//  InitCriticalSection(SynchronizeCritSect);
//  ExecuteEvent:=RtlEventCreate;
//  SynchronizeTimeoutEvent:=RtlEventCreate;
//  DoSynchronizeMethod:=false;
//  MainThreadID:=GetCurrentThreadID;
{$ifdef FPC}
  InitCriticalsection(ResolveSection);
{$else}
  InitializeCriticalsection(ResolveSection);
{$endif}
//  InitHandlerList:=Nil;
//  FindGlobalComponentList:=nil;
  IntConstList := TThreadList.Create;
//  if classlist = nil then begin
   ClassList := TThreadList.Create;
//  end;
//  if classaliaslist = nil then begin
   ClassAliasList := TStringList.Create;
//  end;
  { on unix this maps to a simple rw synchornizer }
  GlobalNameSpace := TMultiReadExclusiveWriteSynchronizer.Create;
  RegisterInitComponentHandler(TComponent,@DefaultInitHandler);
end;


procedure CommonCleanup;
var
  i: Integer;
begin
  GlobalNameSpace.BeginWrite;
  with IntConstList.LockList do
    try
      for i := 0 to Count - 1 do
        TIntConst(Items[I]).Free;
    finally
      IntConstList.UnlockList;
    end;
    IntConstList.Free;
  ClassList.Free;
  ClassAliasList.Free;
  RemoveFixupReferences(nil, '');
{$ifdef FPC}
  DoneCriticalsection(ResolveSection);
{$else}
  DeleteCriticalsection(ResolveSection);
{$endif}
  GlobalLists.Free;
 // ComponentPages.Free;
  FreeAndNil(NeedResolving);
  globalnamespace.endwrite;
  
  { GlobalNameSpace is an interface so this is enough }
//  GlobalNameSpace:=nil;

  if (InitHandlerList<>Nil) then
    for i := 0 to InitHandlerList.Count - 1 do
      TInitHandler(InitHandlerList.Items[I]).Free;
  InitHandlerList.Free;
  InitHandlerList:=Nil;
  FindGlobalComponentList.Free;
  FindGlobalComponentList:=nil;
//  DoneCriticalSection(SynchronizeCritSect);
//  RtlEventDestroy(ExecuteEvent);
//  RtlEventDestroy(SynchronizeTimeoutEvent);
end;

initialization
 commoninit;
finalization
 commoncleanup;
end.
