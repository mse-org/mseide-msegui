{
    This file is part of the Free Component Library

    TXMLTextReader, a streaming text XML reader
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org
    Modified in 2006 by Sergei Gorelkin, sergei_gorelkin@mail.ru

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit xmltextreader;
{$mode objfpc}{$h+}

interface

uses
  SysUtils, Classes, mclasses, xmlutils, xmlreader, dtdmodel;

type
  TDecoder = record
    Context: Pointer;
    Decode: function(Context: Pointer; InBuf: PChar; var InCnt: Cardinal; OutBuf: PWideChar; var OutCnt: Cardinal): Integer; stdcall;
    Cleanup: procedure(Context: Pointer); stdcall;
  end;

  TGetDecoderProc = function(const AEncoding: string; out Decoder: TDecoder): Boolean; stdcall;
  TXMLSourceKind = (skNone, skInternalSubset, skManualPop);
  TXMLTextReader = class;

  TXMLCharSource = class(TObject)
  private
    FBuf: PWideChar;
    FBufEnd: PWideChar;
    FReader: TXMLTextReader;
    FParent: TXMLCharSource;
    FEntity: TEntityDecl;
    FLineNo: Integer;
    LFPos: PWideChar;
    FXML11Rules: Boolean;
    FSourceURI: XMLString;
    FCharCount: Cardinal;
    FStartNesting: Integer;
    FXMLVersion: TXMLVersion;
    FXMLEncoding: XMLString;
    function GetSourceURI: XMLString;
  protected
    function Reload: Boolean; virtual;
  public
    Kind: TXMLSourceKind;
    constructor Create(const AData: XMLString);
    procedure NextChar;
    procedure NewLine; virtual;
    function SkipUntil(var ToFill: TWideCharBuf; const Delim: TSetOfChar;
      wsflag: PBoolean = nil): WideChar; virtual;
    procedure Initialize; virtual;
    function SetEncoding(const AEncoding: string): Boolean; virtual;
    function Matches(const arg: XMLString): Boolean;
    function MatchesLong(const arg: XMLString): Boolean;
    property SourceURI: XMLString read GetSourceURI write FSourceURI;
  end;

  TElementValidator = object
    FElementDef: TElementDecl;
    FCurCP: TContentParticle;
    FFailed: Boolean;
    FSaViolation: Boolean;
    FContentType: TElementContentType;       // =ctAny when FElementDef is nil
    function IsElementAllowed(Def: TElementDecl): Boolean;
    function Incomplete: Boolean;
  end;

  TNodeDataDynArray = array of TNodeData;
  TValidatorDynArray = array of TElementValidator;

  TCheckNameFlags = set of (cnOptional, cnToken);

  TXMLToken = (xtNone, xtEOF, xtText, xtElement, xtEndElement,
    xtCDSect, xtComment, xtPI, xtDoctype, xtEntity, xtEntityEnd, xtPopElement,
    xtPopEmptyElement, xtPushElement, xtPushEntity, xtPopEntity, xtFakeLF);

  TAttributeReadState = (arsNone, arsText, arsEntity, arsEntityEnd, arsPushEntity);

  TLiteralType = (ltPlain, ltPubid, ltEntity);

  TEntityEvent = procedure(Sender: TXMLTextReader; AEntity: TEntityDecl) of object;

  TXMLTextReader = class(TXMLReader, IXmlLineInfo, IGetNodeDataPtr)
  private
    FSource: TXMLCharSource;
    FNameTable: THashTable;
    FXML11: Boolean;
    FNameTableOwned: Boolean;
    FState: (rsProlog, rsDTD, rsAfterDTD, rsRoot, rsEpilog);
    FHavePERefs: Boolean;
    FInsideDecl: Boolean;
    FValue: TWideCharBuf;
    FEntityValue: TWideCharBuf;
    FName: TWideCharBuf;
    FTokenStart: TLocation;
    FStandalone: Boolean;
    FDocType: TDTDModel;
    FPEMap: THashTable;
    FForwardRefs: TFPList;
    FDTDStartPos: PWideChar;
    FIntSubset: TWideCharBuf;
    FAttrTag: Cardinal;
    FDTDProcessed: Boolean;
    FFragmentMode: Boolean;
    FNext: TXMLToken;
    FCurrEntity: TEntityDecl;
    FIDMap: THashTable;
    FAttrDefIndex: array of Cardinal;

    FNSHelper: TNSSupport;
    FNsAttHash: TDblHashArray;
    FEmptyStr: PHashItem;
    FStdPrefix_xml: PHashItem;
    FStdPrefix_xmlns: PHashItem;
    FStdUri_xml: PHashItem;
    FStdUri_xmlns: PHashItem;

    FColonPos: Integer;
    FValidate: Boolean;            // parsing options, copy of FCtrl.Options
    FPreserveWhitespace: Boolean;
    FExpandEntities: Boolean;
    FIgnoreComments: Boolean;
    FCDSectionsAsText: Boolean;
    FNamespaces: Boolean;
    FDisallowDoctype: Boolean;
    FCanonical: Boolean;
    FMaxChars: Cardinal;
    FOnError: TXMLErrorEvent;
    FCurrAttrIndex: Integer;

    FOnEntity: TEntityEvent;
    procedure CleanAttrReadState;
    procedure SetEOFState;
    procedure SkipQuote(out Delim: WideChar; required: Boolean = True);
    procedure SetSource(ASource: TXMLCharSource);
    function ContextPush(AEntity: TEntityDecl; DummySource: Boolean = False): Boolean;
    function ContextPop(Forced: Boolean = False): Boolean;
    function ParseQuantity: TCPQuant;
    procedure StoreLocation(out Loc: TLocation);
    procedure ValidateAttrValue(AttrDef: TAttributeDef; attrData: PNodeData);
    procedure AddForwardRef(Buf: PWideChar; Length: Integer);
    procedure ClearForwardRefs;
    procedure CallErrorHandler(E: EXMLReadError);
    function  FindOrCreateElDef: TElementDecl;
    function  SkipUntilSeq(const Delim: TSetOfChar; c1: WideChar): Boolean;
    procedure CheckMaxChars(ToAdd: Cardinal);
    function AllocNodeData(AIndex: Integer): PNodeData;
    function AllocAttributeData: PNodeData;
    procedure AllocAttributeValueChunk(var APrev: PNodeData; Offset: Integer);
    procedure AddPseudoAttribute(aName: PHashItem; const aValue: XMLString;
      const nameLoc, valueLoc: TLocation);
    procedure CleanupAttribute(aNode: PNodeData);
    procedure CleanupAttributes;
    procedure SetNodeInfoWithValue(typ: TXMLNodeType; AName: PHashItem = nil);
    function SetupFakeLF(nextstate: TXMLToken): Boolean;
    function AddId(aNodeData: PNodeData): Boolean;
    function QueryInterface(constref iid: TGUID; out obj): HRESULT; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef: Longint; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release: Longint; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    procedure SetFragmentMode(aValue: Boolean);
  protected
    FNesting: Integer;
    FCurrNode: PNodeData;
    FAttrCount: Integer;
    FPrefixedAttrs: Integer;
    FSpecifiedAttrs: Integer;
    FNodeStack: TNodeDataDynArray;
    FValidatorNesting: Integer;
    FValidators: TValidatorDynArray;
    FFreeAttrChunk: PNodeData;
    FAttrCleanupFlag: Boolean;
    // ReadAttributeValue state
    FAttrReadState: TAttributeReadState;
    FAttrBaseSource: TObject;

    procedure DoError(Severity: TErrorSeverity; const descr: string; LineOffs: Integer=0);
    procedure DoErrorPos(Severity: TErrorSeverity; const descr: string;
      const ErrPos: TLocation); overload;
    procedure DoErrorPos(Severity: TErrorSeverity; const descr: string;
      const args: array of const; const ErrPos: TLocation); overload;
    procedure FatalError(const descr: String; LineOffs: Integer=0); overload;
    procedure FatalError(const descr: string; const args: array of const; LineOffs: Integer=0); overload;
    procedure FatalError(Expected: WideChar); overload;
    function  SkipWhitespace(PercentAloneIsOk: Boolean = False): Boolean;
    function  SkipS(required: Boolean = False): Boolean;
    procedure ExpectWhitespace;
    procedure ExpectString(const s: String);
    procedure ExpectChar(wc: WideChar);
    function  CheckForChar(c: WideChar): Boolean;

    procedure RaiseNameNotFound;
    function  CheckName(aFlags: TCheckNameFlags = []): Boolean;
    procedure CheckNCName;
    function ParseLiteral(var ToFill: TWideCharBuf; aType: TLiteralType;
      Required: Boolean): Boolean;
    procedure ExpectAttValue(attrData: PNodeData; NonCDATA: Boolean);   // [10]
    procedure ParseComment(discard: Boolean);                           // [15]
    procedure ParsePI;                                                  // [16]
    procedure ParseXmlOrTextDecl(TextDecl: Boolean);
    procedure ExpectEq;
    procedure ParseDoctypeDecl;                                         // [28]
    procedure ParseMarkupDecl;                                          // [29]
    procedure ParseIgnoreSection;
    procedure ParseStartTag;                                            // [39]
    procedure ParseEndTag;                                              // [42]
    procedure HandleEntityStart;
    procedure HandleEntityEnd;
    procedure DoStartEntity;
    procedure ParseAttribute(ElDef: TElementDecl);
    function  ReadTopLevel: Boolean;
    procedure NextAttrValueChunk;
    function  GetHasLineInfo: Boolean;
    function  GetLineNumber: Integer;
    function  GetLinePosition: Integer;
    function  CurrentNodePtr: PPNodeData;
  public
    function  Read: Boolean; override;
    function  MoveToFirstAttribute: Boolean; override;
    function  MoveToNextAttribute: Boolean; override;
    function  MoveToElement: Boolean; override;
    function  ReadAttributeValue: Boolean; override;
    procedure Close; override;
    procedure ResolveEntity; override;
    function  GetAttribute(i: Integer): XMLString; override;
    function  GetAttribute(const AName: XMLString): XMLString; override;
    function  GetAttribute(const ALocalName, nsuri: XMLString): XMLString; override;
    function  LookupNamespace(const APrefix: XMLString): XMLString; override;
    property  LineNumber: Integer read GetLineNumber;
    property  LinePosition: Integer read GetLinePosition;
  protected
    function  GetXmlVersion: TXMLVersion;
    function  GetXmlEncoding: XMLString;
    function  GetNameTable: THashTable; override;
    function  GetDepth: Integer; override;
    function  GetNodeType: TXmlNodeType; override;
    function  GetName: XMLString; override;
    function  GetValue: XMLString; override;
    function  GetLocalName: XMLString; override;
    function  GetPrefix: XMLString; override;
    function  GetNamespaceUri: XMLString; override;
    function  GetHasValue: Boolean; override;
    function  GetAttributeCount: Integer; override;
    function  GetBaseUri: XMLString; override;
    function  GetIsDefault: Boolean; override;

    function  ResolvePredefined: Boolean;
    function  EntityCheck(NoExternals: Boolean = False): TEntityDecl;
    function PrefetchEntity(AEntity: TEntityDecl): Boolean;
    procedure StartPE;
    function  ParseRef(var ToFill: TWideCharBuf): Boolean;              // [67]
    function  ParseExternalID(out SysID, PubID: XMLString;              // [75]
      out PubIDLoc: TLocation; SysIdOptional: Boolean): Boolean;

    procedure CheckPENesting(aExpected: TObject);
    procedure ParseEntityDecl;
    procedure ParseAttlistDecl;
    procedure ExpectChoiceOrSeq(CP: TContentParticle; MustEndIn: TObject);
    procedure ParseElementDecl;
    procedure ParseNotationDecl;
    function ResolveResource(const ASystemID, APublicID, ABaseURI: XMLString; out Source: TXMLCharSource): Boolean;
    procedure ProcessDefaultAttributes(ElDef: TElementDecl);
    procedure ProcessNamespaceAtts;
    function AddBinding(attrData: PNodeData): Boolean;

    procedure PushVC(aElDef: TElementDecl);
    procedure PopElement;
    procedure ValidateDTD;
    procedure ValidationError(const Msg: string; const args: array of const; LineOffs: Integer = -1);
    procedure ValidationErrorWithName(const Msg: string; LineOffs: Integer = -1);
    procedure DTDReloadHook;
    procedure ConvertSource(SrcIn: TXMLInputSource; out SrcOut: TXMLCharSource);
    procedure SetOptions(AValue: TXMLReaderSettings);
    procedure SetNametable(ANameTable: THashTable);
  public
    constructor Create(var AFile: Text; ANameTable: THashTable); overload;
    constructor Create(AStream: TStream; const ABaseUri: XMLString; ANameTable: THashTable); overload;
    constructor Create(AStream: TStream; const ABaseUri: XMLString; ASettings: TXMLReaderSettings); overload;
    constructor Create(ASrc: TXMLCharSource; AParent: TXMLTextReader); overload;
    constructor Create(const uri: XMLString; ASettings: TXMLReaderSettings); overload;
    constructor Create(ASrc: TXMLInputSource; ASettings: TXMLReaderSettings); overload;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    property OnEntity: TEntityEvent read FOnEntity write FOnEntity;
    { stuff needed for TLoader }
    property Standalone: Boolean read FStandalone;
    property DtdSchemaInfo: TDTDModel read FDocType write FDocType;
    property XML11: Boolean write FXML11;
    property XMLVersion: TXMLVersion read GetXMLVersion;
    property XMLEncoding: XMLString read GetXMLEncoding;
    property IDMap: THashTable read FIDMap write FIDMap;
    property ExpandEntities: Boolean read FExpandEntities;
    property Validate: Boolean read FValidate;
    property PreserveWhitespace: Boolean read FPreserveWhitespace;
    property IgnoreComments: Boolean read FIgnoreComments;
    property FragmentMode: Boolean read FFragmentMode write SetFragmentMode;
    procedure ValidateCurrentNode;
    procedure ValidateIdRefs;
    procedure EntityToSource(AEntity: TEntityDecl; out Src: TXMLCharSource);
    procedure ParseDTD;
  end;

procedure RegisterDecoder(Proc: TGetDecoderProc);

implementation

uses
  UriParser;

type
  TXMLDecodingSource = class(TXMLCharSource)
  private
    FCharBuf: PChar;
    FCharBufEnd: PChar;
    FBufStart: PWideChar;
    FDecoder: TDecoder;
    FHasBOM: Boolean;
    FFixedUCS2: string;
    FBufSize: Integer;
    procedure DecodingError(const Msg: string);
  protected
    function Reload: Boolean; override;
    procedure FetchData; virtual;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    function SetEncoding(const AEncoding: string): Boolean; override;
    procedure NewLine; override;
    function SkipUntil(var ToFill: TWideCharBuf; const Delim: TSetOfChar;
      wsflag: PBoolean = nil): WideChar; override;
    procedure Initialize; override;
  end;

  TXMLStreamInputSource = class(TXMLDecodingSource)
  private
    FAllocated: PChar;
    FStream: TStream;
    FCapacity: Integer;
    FOwnStream: Boolean;
    FEof: Boolean;
  public
    constructor Create(AStream: TStream; AOwnStream: Boolean);
    destructor Destroy; override;
    procedure FetchData; override;
  end;

  TXMLFileInputSource = class(TXMLDecodingSource)
  private
    FFile: ^Text;
    FString: string;
    FTmp: string;
  public
    constructor Create(var AFile: Text);
    procedure FetchData; override;
  end;

  PForwardRef = ^TForwardRef;
  TForwardRef = record
    Value: XMLString;
    Loc: TLocation;
  end;

const
  PubidChars: TSetOfChar = [' ', #13, #10, 'a'..'z', 'A'..'Z', '0'..'9',
    '-', '''', '(', ')', '+', ',', '.', '/', ':', '=', '?', ';', '!', '*',
    '#', '@', '$', '_', '%'];

  NullLocation: TLocation = (Line: 0; LinePos: 0);

{ Decoders }

var
  Decoders: array of TGetDecoderProc;

procedure RegisterDecoder(Proc: TGetDecoderProc);
var
  L: Integer;
begin
  L := Length(Decoders);
  SetLength(Decoders, L+1);
  Decoders[L] := Proc;
end;

function FindDecoder(const AEncoding: string; out Decoder: TDecoder): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(Decoders) do
    if Decoders[I](AEncoding, Decoder) then
    begin
      Result := True;
      Exit;
    end;
end;


function Is_8859_1(const AEncoding: string): Boolean;
begin
  Result := SameText(AEncoding, 'ISO-8859-1') or
            SameText(AEncoding, 'ISO_8859-1') or
            SameText(AEncoding, 'latin1') or
            SameText(AEncoding, 'iso-ir-100') or
            SameText(AEncoding, 'l1') or
            SameText(AEncoding, 'IBM819') or
            SameText(AEncoding, 'CP819') or
            SameText(AEncoding, 'csISOLatin1') or
// This one is not in character-sets.txt, but was used in FPC documentation,
// and still being used in fcl-registry package
            SameText(AEncoding, 'ISO8859-1');
end;


{ TXMLCharSource }

constructor TXMLCharSource.Create(const AData: XMLString);
begin
  inherited Create;
  FLineNo := 1;
  FBuf := PWideChar(AData);
  FBufEnd := FBuf + Length(AData);
  LFPos := FBuf-1;
  FCharCount := Length(AData);
end;

procedure TXMLCharSource.Initialize;
begin
end;

function TXMLCharSource.SetEncoding(const AEncoding: string): Boolean;
begin
  Result := True; // always succeed
end;

function TXMLCharSource.GetSourceURI: XMLString;
begin
  if FSourceURI <> '' then
    Result := FSourceURI
  else if Assigned(FParent) then
    Result := FParent.SourceURI
  else
    Result := '';
end;

function TXMLCharSource.Reload: Boolean;
begin
  Result := False;
end;

procedure TXMLCharSource.NewLine;
begin
  Inc(FLineNo);
  LFPos := FBuf;
end;

function TXMLCharSource.SkipUntil(var ToFill: TWideCharBuf; const Delim: TSetOfChar;
  wsflag: PBoolean): WideChar;
var
  old: PWideChar;
  nonws: Boolean;
begin
  old := FBuf;
  nonws := False;
  repeat
    if FBuf^ = #10 then
      NewLine;
    if (FBuf^ < #255) and (Char(ord(FBuf^)) in Delim) then
      Break;
    if (FBuf^ > #32) or not (Char(ord(FBuf^)) in [#32, #9, #10, #13]) then
      nonws := True;
    Inc(FBuf);
  until False;
  Result := FBuf^;
  BufAppendChunk(ToFill, old, FBuf);
  if Assigned(wsflag) then
    wsflag^ := wsflag^ or nonws;
end;

function TXMLCharSource.Matches(const arg: XMLString): Boolean;
begin
  Result := False;
  if (FBufEnd >= FBuf + Length(arg)) or Reload then
    Result := CompareMem(Pointer(arg), FBuf, Length(arg)*sizeof(WideChar));
  if Result then
  begin
    Inc(FBuf, Length(arg));
    if FBuf >= FBufEnd then
      Reload;
  end;
end;

{ Used to check element name in end-tags, difference from Matches is that
  buffer may be reloaded more than once. XML has no restriction on name
  length, so a name longer than input buffer may be encountered. }
function TXMLCharSource.MatchesLong(const arg: XMLString): Boolean;
var
  idx, len, chunk: Integer;
begin
  Result := False;
  idx := 1;
  len := Length(arg);
  repeat
    if (FBuf >= FBufEnd) and not Reload then
      Exit;
    if FBufEnd >= FBuf + len then
      chunk := len
    else
      chunk := FBufEnd - FBuf;
    if not CompareMem(@arg[idx], FBuf, chunk*sizeof(WideChar)) then
      Exit;
    Inc(FBuf, chunk);
    Inc(idx,chunk);
    Dec(len,chunk);
  until len = 0;
  Result := True;
  if FBuf >= FBufEnd then
    Reload;
end;

{ TXMLDecodingSource }

procedure TXMLDecodingSource.AfterConstruction;
begin
  inherited AfterConstruction;
  FBufStart := AllocMem(4096);
  FBuf := FBufStart;
  FBufEnd := FBuf;
  LFPos := FBuf-1;
end;

destructor TXMLDecodingSource.Destroy;
begin
  FreeMem(FBufStart);
  if Assigned(FDecoder.Cleanup) then
    FDecoder.Cleanup(FDecoder.Context);
  inherited Destroy;
end;

procedure TXMLDecodingSource.FetchData;
begin
end;

procedure TXMLDecodingSource.DecodingError(const Msg: string);
begin
// count line endings to obtain correct error location
  while FBuf < FBufEnd do
  begin
    if (FBuf^ = #10) or (FBuf^ = #13) or (FXML11Rules and ((FBuf^ = #$85) or (FBuf^ = #$2028))) then
    begin
      if (FBuf^ = #13) and (FBuf < FBufEnd-1) and
      ((FBuf[1] = #10) or (FXML11Rules and (FBuf[1] = #$85))) then
        Inc(FBuf);
      LFPos := FBuf;
      Inc(FLineNo);
    end;
    Inc(FBuf);
  end;
  FReader.FatalError(Msg);
end;

function TXMLDecodingSource.Reload: Boolean;
var
  Remainder: PtrInt;
  r, inLeft: Cardinal;
  rslt: Integer;
begin
  if Kind = skInternalSubset then
    FReader.DTDReloadHook;
  Remainder := FBufEnd - FBuf;
  if Remainder > 0 then
    Move(FBuf^, FBufStart^, Remainder * sizeof(WideChar));
  Dec(LFPos, FBuf-FBufStart);
  FBuf := FBufStart;
  FBufEnd := FBufStart + Remainder;

  repeat
    inLeft := FCharBufEnd - FCharBuf;
    if inLeft < 4 then                      // may contain an incomplete char
    begin
      FetchData;
      inLeft := FCharBufEnd - FCharBuf;
      if inLeft <= 0 then
        Break;
    end;
    r := FBufStart + FBufSize - FBufEnd;
    if r = 0 then
      Break;
    rslt := FDecoder.Decode(FDecoder.Context, FCharBuf, inLeft, FBufEnd, r);
    { Sanity checks: r and inLeft must not increase. }
    if inLeft + FCharBuf <= FCharBufEnd then
      FCharBuf := FCharBufEnd - inLeft
    else
      DecodingError('Decoder error: input byte count out of bounds');
    if r + FBufEnd <= FBufStart + FBufSize then
      FBufEnd := FBufStart + FBufSize - r
    else
      DecodingError('Decoder error: output char count out of bounds');

    if rslt = 0 then
      Break
    else if rslt < 0 then
      DecodingError('Invalid character in input stream')
    else
      FReader.CheckMaxChars(rslt);
  until False;

  FBufEnd^ := #0;
  Result := FBuf < FBufEnd;
end;

const
  XmlSign: array [0..4] of WideChar = ('<', '?', 'x', 'm', 'l');

procedure TXMLDecodingSource.Initialize;
begin
  inherited;
  FLineNo := 1;
  FDecoder.Decode := @Decode_UTF8;

  FFixedUCS2 := '';
  if FCharBufEnd-FCharBuf > 1 then
  begin
    if (FCharBuf[0] = #$FE) and (FCharBuf[1] = #$FF) then
    begin
      FFixedUCS2 := 'UTF-16BE';
      FDecoder.Decode := {$IFNDEF ENDIAN_BIG} @Decode_UCS2_Swapped {$ELSE} @Decode_UCS2 {$ENDIF};
    end
    else if (FCharBuf[0] = #$FF) and (FCharBuf[1] = #$FE) then
    begin
      FFixedUCS2 := 'UTF-16LE';
      FDecoder.Decode := {$IFDEF ENDIAN_BIG} @Decode_UCS2_Swapped {$ELSE} @Decode_UCS2 {$ENDIF};
    end;
  end;
  FBufSize := 6;             //  possible BOM and '<?xml'
  Reload;
  if FBuf^ = #$FEFF then
  begin
    FHasBOM := True;
    Inc(FBuf);
  end;
  LFPos := FBuf-1;
  if CompareMem(FBuf, @XmlSign[0], sizeof(XmlSign)) then
  begin
    FBufSize := 3;           // don't decode past XML declaration
    Inc(FBuf, Length(XmlSign));
    FReader.ParseXmlOrTextDecl((FParent <> nil) or (FReader.FState <> rsProlog));
  end;
  FBufSize := 2047;
  if FReader.FXML11 then
    FXml11Rules := True;
end;

function TXMLDecodingSource.SetEncoding(const AEncoding: string): Boolean;
var
  NewDecoder: TDecoder;
begin
  Result := True;
  if (FFixedUCS2 = '') and SameText(AEncoding, 'UTF-8') then
    Exit;
  if FFixedUCS2 <> '' then
  begin
    Result := SameText(AEncoding, FFixedUCS2) or
       SameText(AEncoding, 'UTF-16') or
       SameText(AEncoding, 'unicode');
    Exit;
  end;
// TODO: must fail when a byte-based stream is labeled as word-based.
// see rmt-e2e-61, it now fails but for a completely different reason.
  FillChar(NewDecoder, sizeof(TDecoder), 0);
  if Is_8859_1(AEncoding) then
    FDecoder.Decode := @Decode_8859_1
  else if FindDecoder(AEncoding, NewDecoder) then
    FDecoder := NewDecoder
  else
    Result := False;
end;

procedure TXMLDecodingSource.NewLine;
begin
  case FBuf^ of
    #10: ;
    #13: begin
      // Reload trashes the buffer, it should be consumed beforehand
      if (FBufEnd >= FBuf+2) or Reload then
      begin
        if (FBuf[1] = #10) or (FXML11Rules and (FBuf[1] = #$85)) then
          Inc(FBuf);
      end;
      FBuf^ := #10;
    end;
    #$85, #$2028: if FXML11Rules then
      FBuf^ := #10
    else
      Exit;
  else
    Exit;
  end;
  Inc(FLineNo);
  LFPos := FBuf;
end;

{ TXMLStreamInputSource }

const
  Slack = 16;

constructor TXMLStreamInputSource.Create(AStream: TStream; AOwnStream: Boolean);
begin
  FStream := AStream;
  FCapacity := 4096;
  GetMem(FAllocated, FCapacity+Slack);
  FCharBuf := FAllocated+(Slack-4);
  FCharBufEnd := FCharBuf;
  FOwnStream := AOwnStream;
  FetchData;
end;

destructor TXMLStreamInputSource.Destroy;
begin
  FreeMem(FAllocated);
  if FOwnStream then
    FStream.Free;
  inherited Destroy;
end;

procedure TXMLStreamInputSource.FetchData;
var
  Remainder, BytesRead: Integer;
  OldBuf: PChar;
begin
  Assert(FCharBufEnd - FCharBuf < Slack-4);
  if FEof then
    Exit;
  OldBuf := FCharBuf;
  Remainder := FCharBufEnd - FCharBuf;
  if Remainder < 0 then
    Remainder := 0;
  FCharBuf := FAllocated+Slack-4-Remainder;
  if Remainder > 0 then
    Move(OldBuf^, FCharBuf^, Remainder);
  BytesRead := FStream.Read(FAllocated[Slack-4], FCapacity);
  if BytesRead < FCapacity then
    FEof := True;
  FCharBufEnd := FAllocated + (Slack-4) + BytesRead;
  { Null-termination has been removed:
    1) Built-in decoders don't need it because they respect the buffer length.
    2) It was causing unaligned access errors on ARM CPUs.
  }
  //PWideChar(FCharBufEnd)^ := #0;
end;

{ TXMLFileInputSource }

constructor TXMLFileInputSource.Create(var AFile: Text);
begin
  FFile := @AFile;
  SourceURI := FilenameToURI(TTextRec(AFile).Name);
  FetchData;
end;

procedure TXMLFileInputSource.FetchData;
var
  Remainder: Integer;
begin
  if not Eof(FFile^) then
  begin
    Remainder := FCharBufEnd - FCharBuf;
    if Remainder > 0 then
      SetString(FTmp, FCharBuf, Remainder);
    ReadLn(FFile^, FString);
    FString := FString + #10;    // bad solution...
    if Remainder > 0 then
      Insert(FTmp, FString, 1);
    FCharBuf := PChar(FString);
    FCharBufEnd := FCharBuf + Length(FString);
  end;
end;

{ helper that closes handle upon destruction }
type
  THandleOwnerStream = class(THandleStream)
  public
    destructor Destroy; override;
  end;

destructor THandleOwnerStream.Destroy;
begin
  FileClose(Handle);
  inherited Destroy;
end;

{ TXMLTextReader }

function TXMLTextReader.QueryInterface(constref iid: TGUID; out obj): HRESULT; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if GetInterface(iid,obj) then
    result := S_OK
  else
    result:= E_NOINTERFACE;
end;

function TXMLTextReader._AddRef: Longint; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  result := -1;
end;

function TXMLTextReader._Release: Longint; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  result := -1;
end;

procedure TXMLTextReader.ConvertSource(SrcIn: TXMLInputSource; out SrcOut: TXMLCharSource);
begin
  SrcOut := nil;
  if Assigned(SrcIn) then
  begin
    if Assigned(SrcIn.Stream) then
      SrcOut := TXMLStreamInputSource.Create(SrcIn.Stream, False)
    else if SrcIn.StringData <> '' then
      SrcOut := TXMLStreamInputSource.Create(TStringStream.Create(SrcIn.StringData), True)
    else if (SrcIn.SystemID <> '') then
      ResolveResource(SrcIn.SystemID, SrcIn.PublicID, SrcIn.BaseURI, SrcOut);
  end;
  if (SrcOut = nil) and (FSource = nil) then
    DoErrorPos(esFatal, 'No input source specified', NullLocation);
end;

procedure TXMLTextReader.StoreLocation(out Loc: TLocation);
begin
  Loc.Line := FSource.FLineNo;
  Loc.LinePos := FSource.FBuf-FSource.LFPos;
end;

function TXMLTextReader.ResolveResource(const ASystemID, APublicID, ABaseURI: XMLString; out Source: TXMLCharSource): Boolean;
var
  SrcURI: XMLString;
  Filename: string;
  Stream: TStream;
  fd: THandle;
begin
  Source := nil;
  Result := False;
  if not ResolveRelativeURI(ABaseURI, ASystemID, SrcURI) then
    Exit;
  { TODO: alternative resolvers
    These may be 'internal' resolvers or a handler set by application.
    Internal resolvers should probably produce a TStream
    ( so that internal classes need not be exported ).
    External resolver will produce TXMLInputSource that should be converted.
    External resolver must NOT be called for root entity.
    External resolver can return nil, in which case we do the default }
  if URIToFilename(SrcURI, Filename) then
  begin
    fd := FileOpen(Filename, fmOpenRead + fmShareDenyWrite);
    if fd <> THandle(-1) then
    begin
      Stream := THandleOwnerStream.Create(fd);
      Source := TXMLStreamInputSource.Create(Stream, True);
      Source.SourceURI := SrcURI;
    end;
  end;
  Result := Assigned(Source);
end;

procedure TXMLTextReader.SetSource(ASource: TXMLCharSource);
begin
  ASource.FParent := FSource;
  FSource := ASource;
  FSource.FReader := Self;
  FSource.FStartNesting := FNesting;
end;

procedure TXMLTextReader.FatalError(Expected: WideChar);
begin
// FIX: don't output what is found - anything may be found, including exploits...
  FatalError('Expected "%1s"', [string(Expected)]);
end;

procedure TXMLTextReader.FatalError(const descr: String; LineOffs: Integer);
begin
  DoError(esFatal, descr, LineOffs);
end;

procedure TXMLTextReader.FatalError(const descr: string; const args: array of const; LineOffs: Integer);
begin
  DoError(esFatal, Format(descr, args), LineOffs);
end;

procedure TXMLTextReader.ValidationError(const Msg: string; const Args: array of const; LineOffs: Integer);
begin
  if FValidate then
    DoError(esError, Format(Msg, Args), LineOffs);
end;

procedure TXMLTextReader.ValidationErrorWithName(const Msg: string; LineOffs: Integer);
var
  ws: XMLString;
begin
  SetString(ws, FName.Buffer, FName.Length);
  ValidationError(Msg, [ws], LineOffs);
end;

procedure TXMLTextReader.DoError(Severity: TErrorSeverity; const descr: string; LineOffs: Integer);
var
  Loc: TLocation;
begin
  StoreLocation(Loc);
  if LineOffs >= 0 then
  begin
    Dec(Loc.LinePos, LineOffs);
    DoErrorPos(Severity, descr, Loc);
  end
  else
    DoErrorPos(Severity, descr, FTokenStart);
end;

procedure TXMLTextReader.DoErrorPos(Severity: TErrorSeverity; const descr: string;
  const args: array of const; const ErrPos: TLocation);
begin
  DoErrorPos(Severity, Format(descr, args), ErrPos);
end;

procedure TXMLTextReader.DoErrorPos(Severity: TErrorSeverity; const descr: string; const ErrPos: TLocation);
var
  E: EXMLReadError;
  srcuri: XMLString;
begin
  if Assigned(FSource) then
  begin
    srcuri := FSource.FSourceURI;
    if (srcuri = '') and Assigned(FSource.FEntity) then
      srcuri := FSource.FEntity.FURI;
    E := EXMLReadError.Create(severity, descr, ErrPos.Line, ErrPos.LinePos, srcuri);
  end
  else
    E := EXMLReadError.Create(descr);
  CallErrorHandler(E);
  // No 'finally'! If user handler raises exception, control should not get here
  // and the exception will be freed in CallErrorHandler (below)
  E.Free;
end;

procedure TXMLTextReader.CheckMaxChars(ToAdd: Cardinal);
var
  src: TXMLCharSource;
  total: Cardinal;
begin
  Inc(FSource.FCharCount, ToAdd);
  if FMaxChars = 0 then
    Exit;
  src := FSource;
  total := 0;
  repeat
    Inc(total, src.FCharCount);
    if total > FMaxChars then
      FatalError('Exceeded character count limit');
    src := src.FParent;
  until src = nil;
end;

procedure TXMLTextReader.CallErrorHandler(E: EXMLReadError);
begin
  try
    if Assigned(FOnError) then
      FOnError(E);
    if E.Severity = esFatal then
      raise E;
  except
    FReadState := rsError;
    if ExceptObject <> E then
      E.Free;
    raise;
  end;
end;

function TXMLTextReader.SkipWhitespace(PercentAloneIsOk: Boolean): Boolean;
begin
  Result := False;
  repeat
    Result := SkipS or Result;
    if FSource.FBuf >= FSource.FBufEnd then
    begin
      Result := True;      // report whitespace upon exiting the PE
      if not ContextPop then
        Break;
    end
    else if FSource.FBuf^ = '%' then
    begin
      if (FState <> rsDTD) then
        Break;
// This is the only case where look-ahead is needed
      if FSource.FBuf > FSource.FBufEnd-2 then
        FSource.Reload;

      if (not PercentAloneIsOk) or (Byte(FSource.FBuf[1]) in NamingBitmap[NamePages[hi(Word(FSource.FBuf[1]))]]) or
        ((FSource.FBuf[1] >= #$D800) and (FSource.FBuf[1] <= #$DB7F)) then
      begin
        StartPE;
        Result := True;        // report whitespace upon entering the PE
      end
      else Break;
    end
    else
      Break;
  until False;
end;

procedure TXMLTextReader.ExpectWhitespace;
begin
  if not SkipWhitespace then
    FatalError('Expected whitespace');
end;

function TXMLTextReader.SkipS(Required: Boolean): Boolean;
var
  p: PWideChar;
begin
  Result := False;
  repeat
    p := FSource.FBuf;
    repeat
      if (p^ = #10) or (p^ = #13) or (FXML11 and ((p^ = #$85) or (p^ = #$2028))) then
      begin
        FSource.FBuf := p;
        FSource.NewLine;
        p := FSource.FBuf;
      end
      else if (p^ <> #32) and (p^ <> #9) then
        Break;
      Inc(p);
      Result := True;
    until False;
    FSource.FBuf := p;
  until (FSource.FBuf < FSource.FBufEnd) or (not FSource.Reload);
  if (not Result) and Required then
    FatalError('Expected whitespace');
end;

procedure TXMLTextReader.ExpectString(const s: String);
var
  I: Integer;
begin
  for I := 1 to Length(s) do
  begin
    if FSource.FBuf^ <> WideChar(ord(s[i])) then
      FatalError('Expected "%s"', [s], i-1);
    FSource.NextChar;
  end;
end;

function TXMLTextReader.CheckForChar(c: WideChar): Boolean;
begin
  Result := (FSource.FBuf^ = c);
  if Result then
  begin
    Inc(FSource.FBuf);
    if FSource.FBuf >= FSource.FBufEnd then
      FSource.Reload;
  end;
end;

procedure TXMLTextReader.SkipQuote(out Delim: WideChar; required: Boolean);
begin
  Delim := #0;
  if (FSource.FBuf^ = '''') or (FSource.FBuf^ = '"') then
  begin
    Delim := FSource.FBuf^;
    FSource.NextChar;  // skip quote
    StoreLocation(FTokenStart);
  end
  else if required then
    FatalError('Expected single or double quote');
end;

const
  PrefixDefault: array[0..4] of WideChar = ('x','m','l','n','s');

procedure TXMLTextReader.SetOptions(AValue: TXMLReaderSettings);
begin
  FValidate := AValue.Validate;
  FPreserveWhitespace := AValue.PreserveWhitespace;
  FExpandEntities := AValue.ExpandEntities;
  FCDSectionsAsText := AValue.CDSectionsAsText;
  FIgnoreComments := AValue.IgnoreComments;
  FNamespaces := AValue.Namespaces;
  FDisallowDoctype := AValue.DisallowDoctype;
  FCanonical := AValue.CanonicalForm;
  FMaxChars := AValue.MaxChars;
  FOnError := AValue.OnError;
  SetFragmentMode(AValue.ConformanceLevel = clFragment);
end;

procedure TXMLTextReader.SetFragmentMode(aValue: Boolean);
begin
  FFragmentMode := aValue;
  if FFragmentMode then
    FState := rsRoot
  else
    FState := rsProlog;
end;

constructor TXMLTextReader.Create(ASrc: TXMLInputSource; ASettings: TXMLReaderSettings);
var
  InputSrc: TXMLCharSource;
begin
  SetNametable(ASettings.NameTable);
  SetOptions(ASettings);
  ConvertSource(ASrc, InputSrc);
  FSource := InputSrc;
  FSource.FReader := Self;
end;

constructor TXMLTextReader.Create(const uri: XMLString; ASettings: TXMLReaderSettings);
begin
  SetNametable(ASettings.NameTable);
  SetOptions(ASettings);
  if ResolveResource(uri, '', '', FSource) then
    FSource.FReader := Self
  else
    DoErrorPos(esFatal, 'The specified URI could not be resolved', NullLocation);
end;


procedure TXMLTextReader.SetNametable(ANameTable: THashTable);
begin
  if ANameTable = nil then
  begin
    ANameTable := THashTable.Create(256, True);
    FNameTableOwned := True;
  end;
  FNameTable := ANameTable;
end;

constructor TXMLTextReader.Create(var AFile: Text; ANameTable: THashTable);
begin
  SetNametable(ANameTable);
  FSource := TXMLFileInputSource.Create(AFile);
  FSource.FReader := Self;
end;

constructor TXMLTextReader.Create(AStream: TStream; const ABaseUri: XMLString; ANameTable: THashTable);
begin
  SetNametable(ANameTable);
  FSource := TXMLStreamInputSource.Create(AStream, False);
  FSource.SourceURI := ABaseUri;
  FSource.FReader := Self;
end;

constructor TXMLTextReader.Create(AStream: TStream; const ABaseUri: XMLString; ASettings: TXMLReaderSettings); overload;
begin
  SetNametable(ASettings.NameTable);
  SetOptions(ASettings);
  FSource := TXMLStreamInputSource.Create(AStream, False);
  FSource.SourceURI := ABaseUri;
  FSource.FReader := Self;
end;

constructor TXMLTextReader.Create(ASrc: TXMLCharSource; AParent: TXMLTextReader);
begin
  FNameTable := AParent.FNameTable;
  FSource := ASrc;
  FSource.FReader := Self;

  FValidate := AParent.FValidate;
  FPreserveWhitespace := AParent.FPreserveWhitespace;
  FExpandEntities := AParent.FExpandEntities;
  FCDSectionsAsText := AParent.FCDSectionsAsText;
  FIgnoreComments := AParent.FIgnoreComments;
  FNamespaces := AParent.FNamespaces;
  FDisallowDoctype := AParent.FDisallowDoctype;
  FCanonical := AParent.FCanonical;
  FMaxChars := AParent.FMaxChars;
  FOnError := AParent.FOnError;
end;

destructor TXMLTextReader.Destroy;
var
  cur: PNodeData;
begin
  if FAttrCleanupFlag then
    CleanupAttributes;
  while Assigned(FFreeAttrChunk) do
  begin
    cur := FFreeAttrChunk;
    FFreeAttrChunk := cur^.FNext;
    Dispose(cur);
  end;

  if Assigned(FEntityValue.Buffer) then
    FreeMem(FEntityValue.Buffer);
  FreeMem(FName.Buffer);
  FreeMem(FValue.Buffer);
  if Assigned(FSource) then
    while ContextPop(True) do;     // clean input stack
  FSource.Free;
  FPEMap.Free;
  ClearForwardRefs;
  FNsAttHash.Free;
  FNSHelper.Free;
  FDocType.Release;
  FIDMap.Free;
  FForwardRefs.Free;
  if FNameTableOwned then
    FNameTable.Free;
  inherited Destroy;
end;


procedure TXMLTextReader.AfterConstruction;
begin
  BufAllocate(FName, 128);
  BufAllocate(FValue, 512);

  SetLength(FNodeStack, 16);
  SetLength(FValidators, 16);

  FNesting := 0;
  FValidatorNesting := 0;
  FCurrNode := @FNodeStack[0];
  FCurrAttrIndex := -1;
  FEmptyStr := FNameTable.FindOrAdd('');
  if FNamespaces then
  begin
    FNSHelper := TNSSupport.Create(FNameTable);
    FNsAttHash := TDblHashArray.Create;
    FStdPrefix_xml := FNSHelper.GetPrefix(@PrefixDefault, 3);
    FStdPrefix_xmlns := FNSHelper.GetPrefix(@PrefixDefault, 5);

    FStdUri_xmlns := FNameTable.FindOrAdd(stduri_xmlns);
    FStdUri_xml := FNameTable.FindOrAdd(stduri_xml);
  end;
end;

function TXMLTextReader.CheckName(aFlags: TCheckNameFlags): Boolean;
var
  p: PWideChar;
  NameStartFlag: Boolean;
begin
  p := FSource.FBuf;
  FName.Length := 0;
  FColonPos := -1;
  NameStartFlag := not (cnToken in aFlags);

  repeat
    if NameStartFlag then
    begin
      if (Byte(p^) in NamingBitmap[NamePages[hi(Word(p^))]]) or
        ((p^ = ':') and (not FNamespaces)) then
        Inc(p)
      else if ((p^ >= #$D800) and (p^ <= #$DB7F) and
        (p[1] >= #$DC00) and (p[1] <= #$DFFF)) then
        Inc(p, 2)
      else
      begin
  // here we come either when first char of name is bad (it may be a colon),
  // or when a colon is not followed by a valid NameStartChar
        FSource.FBuf := p;
        Result := False;
        Break;
      end;
      NameStartFlag := False;
    end;

    repeat
      if (Byte(p^) in NamingBitmap[NamePages[$100+hi(Word(p^))]]) or
        ((p^= ':') and ((cnToken in aFlags) or not FNamespaces)) then
        Inc(p)
      else if ((p^ >= #$D800) and (p^ <= #$DB7F) and
        (p[1] >= #$DC00) and (p[1] <= #$DFFF)) then
        Inc(p,2)
      else
        Break;
    until False;

    if (p^ = ':') and (FColonPos < 0) then
    begin
      FColonPos := p-FSource.FBuf+FName.Length;
      NameStartFlag := True;
      Inc(p);
      if p < FSource.FBufEnd then Continue;
    end;

    BufAppendChunk(FName, FSource.FBuf, p);
    Result := (FName.Length > 0);

    FSource.FBuf := p;
    if (p < FSource.FBufEnd) or not FSource.Reload then
      Break;

    p := FSource.FBuf;
  until False;
  if not (Result or (cnOptional in aFlags)) then
    RaiseNameNotFound;
end;

procedure TXMLTextReader.CheckNCName;
begin
  if FNamespaces and (FColonPos <> -1) then
    FatalError('Names of entities, notations and processing instructions may not contain colons', FName.Length);
end;

procedure TXMLTextReader.RaiseNameNotFound;
begin
  if FColonPos <> -1 then
    FatalError('Bad QName syntax, local part is missing')
  else
  // Coming at no cost, this allows more user-friendly error messages
  with FSource do
  if (FBuf^ = #32) or (FBuf^ = #10) or (FBuf^ = #9) or (FBuf^ = #13) then
    FatalError('Whitespace is not allowed here')
  else
    FatalError('Name starts with invalid character');
end;

function TXMLTextReader.ResolvePredefined: Boolean;
var
  wc: WideChar;
begin
  Result := False;
  with FName do
  begin
    if (Length = 2) and (Buffer[1] = 't') then
    begin
      if Buffer[0] = 'l' then
        wc := '<'
      else if Buffer[0] = 'g' then
        wc := '>'
      else Exit;
    end
    else if Buffer[0] = 'a' then
    begin
      if (Length = 3) and (Buffer[1] = 'm') and (Buffer[2] = 'p') then
        wc := '&'
      else if (Length = 4) and (Buffer[1] = 'p') and (Buffer[2] = 'o') and
       (Buffer[3] = 's') then
        wc := ''''
      else Exit;
    end
    else if (Length = 4) and (Buffer[0] = 'q') and (Buffer[1] = 'u') and
      (Buffer[2] = 'o') and (Buffer[3] ='t') then
      wc := '"'
    else
      Exit;
  end; // with
  BufAppend(FValue, wc);
  Result := True;
end;

function TXMLTextReader.ParseRef(var ToFill: TWideCharBuf): Boolean;  // [67]
var
  Code: Integer;
begin
  FSource.NextChar;   // skip '&'
  Result := CheckForChar('#');
  if Result then
  begin
    Code := 0;
    if CheckForChar('x') then
    repeat
      case FSource.FBuf^ of
        '0'..'9': Code := Code * 16 + Ord(FSource.FBuf^) - Ord('0');
        'a'..'f': Code := Code * 16 + Ord(FSource.FBuf^) - (Ord('a') - 10);
        'A'..'F': Code := Code * 16 + Ord(FSource.FBuf^) - (Ord('A') - 10);
      else
        Break;
      end;
      FSource.NextChar;
    until Code > $10FFFF
    else
    repeat
      case FSource.FBuf^ of
        '0'..'9': Code := Code * 10 + Ord(FSource.FBuf^) - Ord('0');
      else
        Break;
      end;
      FSource.NextChar;
    until Code > $10FFFF;

    case Code of
      $01..$08, $0B..$0C, $0E..$1F:
        if FXML11 then
          BufAppend(ToFill, WideChar(Code))
        else
          FatalError('Invalid character reference');
      $09, $0A, $0D, $20..$D7FF, $E000..$FFFD:
        BufAppend(ToFill, WideChar(Code));
      $10000..$10FFFF:
        begin
          BufAppend(ToFill, WideChar($D7C0 + (Code shr 10)));
          BufAppend(ToFill, WideChar($DC00 xor (Code and $3FF)));
        end;
    else
      FatalError('Invalid character reference');
    end;
  end
  else CheckName;
  ExpectChar(';');
end;

const
  AttrDelims: TSetOfChar = [#0, '<', '&', '''', '"', #9, #10, #13];
  GT_Delim: TSetOfChar = [#0, '>'];

{ Parse attribute literal, producing plain string value in AttrData.FValueStr.
  If entity references are encountered and FExpandEntities=False, also builds
  a node chain starting from AttrData.FNext. Node chain is built only for the
  first level. If NonCDATA=True, additionally normalizes whitespace in string value. }

procedure TXMLTextReader.ExpectAttValue(AttrData: PNodeData; NonCDATA: Boolean);
var
  wc: WideChar;
  Delim: WideChar;
  ent: TEntityDecl;
  start: TObject;
  curr: PNodeData;
  StartPos: Integer;
  StartLoc: TLocation;
  entName: PHashItem;
begin
  SkipQuote(Delim);
  AttrData^.FLoc2 := FTokenStart;
  StartLoc := FTokenStart;
  curr := AttrData;
  FValue.Length := 0;
  StartPos := 0;
  start := FSource.FEntity;
  repeat
    wc := FSource.SkipUntil(FValue, AttrDelims);
    if wc = '<' then
      FatalError('Character ''<'' is not allowed in attribute value')
    else if wc = '&' then
    begin
      if ParseRef(FValue) or ResolvePredefined then
        Continue;

      entName := FNameTable.FindOrAdd(FName.Buffer, FName.Length);
      ent := EntityCheck(True);
      if ((ent = nil) or (not FExpandEntities)) and (FSource.FEntity = start) then
      begin
        if FValue.Length > StartPos then
        begin
          AllocAttributeValueChunk(curr, StartPos);
          curr^.FLoc := StartLoc;
        end;
        AllocAttributeValueChunk(curr, FValue.Length);
        curr^.FNodeType := ntEntityReference;
        curr^.FQName := entName;
        StoreLocation(StartLoc);
        curr^.FLoc := StartLoc;
        Dec(curr^.FLoc.LinePos, FName.Length+1);
      end;
      StartPos := FValue.Length;
      if Assigned(ent) then
        ContextPush(ent);
    end
    else if wc <> #0 then
    begin
      FSource.NextChar;
      if (wc = Delim) and (FSource.FEntity = start) then
        Break;
      if (wc = #10) or (wc = #9) or (wc = #13) then
        wc := #32;
      BufAppend(FValue, wc);
    end
    else
    begin
      if (FSource.FEntity = start) or not ContextPop then    // #0
        FatalError('Literal has no closing quote', -1);
      StartPos := FValue.Length;
    end;
  until False;
  if Assigned(attrData^.FNext) then
  begin
    FAttrCleanupFlag := True;
    if FValue.Length > StartPos then
    begin
      AllocAttributeValueChunk(curr, StartPos);
      curr^.FLoc := StartLoc;
    end;
  end;
  if nonCDATA then
    BufNormalize(FValue, attrData^.FDenormalized)
  else
    attrData^.FDenormalized := False;
  SetString(attrData^.FValueStr, FValue.Buffer, FValue.Length);
end;

const
  PrefixChar: array[Boolean] of string = ('', '%');

procedure TXMLTextReader.EntityToSource(AEntity: TEntityDecl; out Src: TXMLCharSource);
begin
  if AEntity.FOnStack then
    FatalError('Entity ''%s%s'' recursively references itself', [PrefixChar[AEntity.FIsPE], AEntity.FName]);

  if (AEntity.FSystemID <> '') and not AEntity.FPrefetched then
  begin
    if not ResolveResource(AEntity.FSystemID, AEntity.FPublicID, AEntity.FURI, Src) then
    begin
      // TODO: a detailed message like SysErrorMessage(GetLastError) would be great here
      ValidationError('Unable to resolve external entity ''%s''', [AEntity.FName]);
      Src := nil;
      Exit;
    end;
  end
  else
  begin
    Src := TXMLCharSource.Create(AEntity.FReplacementText);
    Src.FLineNo := AEntity.FStartLocation.Line;
    Src.LFPos := Src.FBuf - AEntity.FStartLocation.LinePos;
    // needed in case of prefetched external PE
    if AEntity.FSystemID <> '' then
      Src.SourceURI := AEntity.FURI;
  end;

  AEntity.FOnStack := True;
  Src.FEntity := AEntity;
end;

function TXMLTextReader.ContextPush(AEntity: TEntityDecl; DummySource: Boolean): Boolean;
var
  Src: TXMLCharSource;
begin
  Src := nil;
  if Assigned(AEntity) then
    EntityToSource(AEntity, Src);
  if (Src = nil) and DummySource then
  begin
    Src := TXMLCharSource.Create('');
    if FExpandEntities then
      Src.Kind := skManualPop;
  end;
  Result := Assigned(Src);
  if Result then
  begin
    SetSource(Src);
    Src.Initialize;
  end;
end;

function TXMLTextReader.ContextPop(Forced: Boolean): Boolean;
var
  Src: TXMLCharSource;
  Error: Boolean;
begin
  Result := Assigned(FSource.FParent) and (Forced or (FSource.Kind = skNone));
  if Result then
  begin
    Src := FSource.FParent;
    Error := False;
    if Assigned(FSource.FEntity) then
    begin
      FSource.FEntity.FOnStack := False;
      FSource.FEntity.FCharCount := FSource.FCharCount;
// [28a] PE that was started between MarkupDecls may not end inside MarkupDecl
      Error := FSource.FEntity.FBetweenDecls and FInsideDecl;
    end;
    FSource.Free;
    FSource := Src;
// correct position of this error is after PE reference
    if Error then
      FatalError('Parameter entities must be properly nested');
  end;
end;

function TXMLTextReader.EntityCheck(NoExternals: Boolean): TEntityDecl;
var
  RefName: XMLString;
  cnt: Integer;
begin
  Result := nil;
  SetString(RefName, FName.Buffer, FName.Length);
  cnt := FName.Length+2;

  if Assigned(FDocType) then
    Result := FDocType.Entities.Get(FName.Buffer, FName.Length) as TEntityDecl;

  if Result = nil then
  begin
    if FStandalone or (FDocType = nil) or not (FHavePERefs or (FDocType.FSystemID <> '')) then
      FatalError('Reference to undefined entity ''%s''', [RefName], cnt)
    else
      ValidationError('Undefined entity ''%s'' referenced', [RefName], cnt);
    Exit;
  end;

  if FStandalone and Result.ExternallyDeclared then
    FatalError('Standalone constraint violation', cnt);
  if Result.FNotationName <> '' then
    FatalError('Reference to unparsed entity ''%s''', [RefName], cnt);

  if NoExternals and (Result.FSystemID <> '') then
    FatalError('External entity reference is not allowed in attribute value', cnt);

  if not Result.FResolved then
    if Assigned(FOnEntity) then
      FOnEntity(Self, Result);

  // at this point we know the charcount of the entity being included
  if Result.FCharCount >= cnt then
    CheckMaxChars(Result.FCharCount - cnt);
end;

procedure TXMLTextReader.StartPE;
var
  PEnt: TEntityDecl;
begin
  FSource.NextChar;    // skip '%'
  CheckName;
  ExpectChar(';');
  if (FSource.Kind = skInternalSubset) and FInsideDecl then
    FatalError('Parameter entity references cannot appear inside markup declarations in internal subset', FName.Length+2);
  PEnt := nil;
  if Assigned(FPEMap) then
    PEnt := FPEMap.Get(FName.Buffer, FName.Length) as TEntityDecl;
  if PEnt = nil then
  begin
    ValidationErrorWithName('Undefined parameter entity ''%s'' referenced', FName.Length+2);
    // cease processing declarations, unless document is standalone.
    FDTDProcessed := FStandalone;
    Exit;
  end;

  { cache an external PE so it's only fetched once }
  if (PEnt.FSystemID <> '') and (not PEnt.FPrefetched) and (not PrefetchEntity(PEnt)) then
  begin
    FDTDProcessed := FStandalone;
    Exit;
  end;
  CheckMaxChars(PEnt.FCharCount);

  PEnt.FBetweenDecls := not FInsideDecl;
  ContextPush(PEnt);
  FHavePERefs := True;
end;

function TXMLTextReader.PrefetchEntity(AEntity: TEntityDecl): Boolean;
begin
  Result := ContextPush(AEntity);
  if Result then
  try
    FValue.Length := 0;
    FSource.SkipUntil(FValue, [#0]);
    SetString(AEntity.FReplacementText, FValue.Buffer, FValue.Length);
    AEntity.FCharCount := FValue.Length;
    AEntity.FStartLocation.Line := 1;
    AEntity.FStartLocation.LinePos := 1;
    AEntity.FURI := FSource.SourceURI;    // replace base URI with absolute one
  finally
    ContextPop;
    AEntity.FPrefetched := True;
    FValue.Length := 0;
  end;
end;

const
  LiteralDelims: array[TLiteralType] of TSetOfChar = (
    [#0, '''', '"'],                          // ltPlain
    [#0, '''', '"', #13, #10],                // ltPubid
    [#0, '%', '&', '''', '"']                 // ltEntity
  );

function TXMLTextReader.ParseLiteral(var ToFill: TWideCharBuf; aType: TLiteralType;
  Required: Boolean): Boolean;
var
  start: TObject;
  wc, Delim: WideChar;
  dummy: Boolean;
begin
  SkipQuote(Delim, Required);
  Result := (Delim <> #0);
  if not Result then
    Exit;
  ToFill.Length := 0;
  start := FSource.FEntity;
  repeat
    wc := FSource.SkipUntil(ToFill, LiteralDelims[aType]);
    if wc = '%' then       { ltEntity only }
      StartPE
    else if wc = '&' then  { ltEntity }
    begin
      if ParseRef(ToFill) then   // charRefs always expanded
        Continue;
      BufAppend(ToFill, '&');
      BufAppendChunk(ToFill, FName.Buffer, FName.Buffer + FName.Length);
      BufAppend(ToFill, ';');
    end
    else if wc <> #0 then
    begin
      FSource.NextChar;
      if (wc = #10) or (wc = #13) then
        wc := #32
      // terminating delimiter must be in the same context as the starting one
      else if (wc = Delim) and (start = FSource.FEntity) then
        Break;
      BufAppend(ToFill, wc);
    end
    else if (FSource.FEntity = start) or not ContextPop then    // #0
      FatalError('Literal has no closing quote', -1);
  until False;
  if aType = ltPubid then
    BufNormalize(ToFill, dummy);
end;

function TXMLTextReader.SkipUntilSeq(const Delim: TSetOfChar; c1: WideChar): Boolean;
var
  wc: WideChar;
begin
  Result := False;
  StoreLocation(FTokenStart);
  repeat
    wc := FSource.SkipUntil(FValue, Delim);
    if wc <> #0 then
    begin
      FSource.NextChar;
      if (FValue.Length > 0) then
      begin
        if (FValue.Buffer[FValue.Length-1] = c1) then
        begin
          Dec(FValue.Length);
          Result := True;
          Exit;
        end;
      end;
      BufAppend(FValue, wc);
    end;
  until wc = #0;
end;

procedure TXMLTextReader.ParseComment(discard: Boolean);    // [15]
var
  SaveLength: Integer;
begin
  ExpectString('--');
  SaveLength := FValue.Length;
  if not SkipUntilSeq([#0, '-'], '-') then
    FatalError('Unterminated comment', -1);
  ExpectChar('>');

  if not discard then
  begin
    FCurrNode := @FNodeStack[FNesting];
    FCurrNode^.FNodeType := ntComment;
    FCurrNode^.FQName := nil;
    FCurrNode^.FValueStart := @FValue.Buffer[SaveLength];
    FCurrNode^.FValueLength := FValue.Length-SaveLength;
  end;
  FValue.Length := SaveLength;
end;

procedure TXMLTextReader.ParsePI;                    // [16]
begin
  FSource.NextChar;      // skip '?'
  CheckName;
  CheckNCName;
  with FName do
    if (Length = 3) and
     ((Buffer[0] = 'X') or (Buffer[0] = 'x')) and
     ((Buffer[1] = 'M') or (Buffer[1] = 'm')) and
     ((Buffer[2] = 'L') or (Buffer[2] = 'l')) then
  begin
    if not BufEquals(FName, 'xml') then
      FatalError('''xml'' is a reserved word; it must be lowercase', FName.Length)
    else
      FatalError('XML declaration is not allowed here', FName.Length);
  end;

  if FSource.FBuf^ <> '?' then
    SkipS(True);

  FValue.Length := 0;
  if not SkipUntilSeq(GT_Delim, '?') then
    FatalError('Unterminated processing instruction', -1);
  SetNodeInfoWithValue(ntProcessingInstruction,
    FNameTable.FindOrAdd(FName.Buffer, FName.Length));
end;

const
  vers: array[Boolean] of TXMLVersion = (xmlVersion10, xmlVersion11);

procedure TXMLTextReader.ParseXmlOrTextDecl(TextDecl: Boolean);
var
  Delim: WideChar;
  buf: array[0..31] of WideChar;
  I: Integer;
begin
  SkipS(True);
  // [24] VersionInfo: optional in TextDecl, required in XmlDecl
  if (not TextDecl) or (FSource.FBuf^ = 'v') then
  begin
    ExpectString('version');
    ExpectEq;
    SkipQuote(Delim);
    { !! Definition "VersionNum ::= '1.' [0-9]+" per XML 1.0 Fifth Edition
      implies that version literal can have unlimited length. }
    I := 0;
    while (I < 3) and (FSource.FBuf^ <> Delim) do
    begin
      buf[I] := FSource.FBuf^;
      Inc(I);
      FSource.NextChar;
    end;
    if (I <> 3) or (buf[0] <> '1') or (buf[1] <> '.') or
      (buf[2] < '0') or (buf[2] > '9') then
      FatalError('Illegal version number', -1);

    ExpectChar(Delim);
    FSource.FXMLVersion := vers[buf[2] = '1'];

    if TextDecl and (FSource.FXMLVersion = xmlVersion11) and not FXML11 then
      FatalError('XML 1.0 document cannot invoke XML 1.1 entities', -1);

    if TextDecl or (FSource.FBuf^ <> '?') then
      SkipS(True);
  end;

  // [80] EncodingDecl: required in TextDecl, optional in XmlDecl
  if TextDecl or (FSource.FBuf^ = 'e') then
  begin
    ExpectString('encoding');
    ExpectEq;
    SkipQuote(Delim);
    I := 0;
    while (I < 30) and (FSource.FBuf^ <> Delim) and (FSource.FBuf^ < #127) and
      ((Char(ord(FSource.FBuf^)) in ['A'..'Z', 'a'..'z']) or
      ((I > 0) and (Char(ord(FSource.FBuf^)) in ['0'..'9', '.', '-', '_']))) do
    begin
      buf[I] := FSource.FBuf^;
      Inc(I);
      FSource.NextChar;
    end;
    if not CheckForChar(Delim) then
      FatalError('Illegal encoding name', i);

    SetString(FSource.FXMLEncoding, buf, i);
    if not FSource.SetEncoding(FSource.FXMLEncoding) then  // <-- Wide2Ansi conversion here
      FatalError('Encoding ''%s'' is not supported', [FSource.FXMLEncoding], i+1);

    if FSource.FBuf^ <> '?' then
      SkipS(not TextDecl);
  end;

  // [32] SDDecl: forbidden in TextDecl, optional in XmlDecl
  if (not TextDecl) and (FSource.FBuf^ = 's') then
  begin
    ExpectString('standalone');
    ExpectEq;
    SkipQuote(Delim);
    if FSource.Matches('yes') then
      FStandalone := True
    else if not FSource.Matches('no') then
      FatalError('Only "yes" or "no" are permitted as values of "standalone"', -1);
    ExpectChar(Delim);
    SkipS;
  end;

  ExpectString('?>');
  { Switch to 1.1 rules only after declaration is parsed completely. This is to
    ensure that NEL and LSEP within declaration are rejected (rmt-056, rmt-057) }
  if FSource.FXMLVersion = xmlVersion11 then
    FXML11 := True;
end;

procedure TXMLTextReader.DTDReloadHook;
var
  p: PWideChar;
begin
{ FSource converts CR, NEL and LSEP linebreaks to LF, and CR-NEL sequences to CR-LF.
  We must further remove the CR chars and have only LF's left. }
  p := FDTDStartPos;
  while p < FSource.FBuf do
  begin
    while (p < FSource.FBuf) and (p^ <> #13) do
      Inc(p);
    BufAppendChunk(FIntSubset, FDTDStartPos, p);
    if p^ = #13 then
      Inc(p);
    FDTDStartPos := p;
  end;
  FDTDStartPos := TXMLDecodingSource(FSource).FBufStart;
end;

procedure TXMLTextReader.ParseDoctypeDecl;    // [28]
var
  Src: TXMLCharSource;
  DTDName: PHashItem;
  Locs: array [0..2] of TLocation;
  HasAtts: Boolean;
begin
  if FState >= rsDTD then
    FatalError('Markup declaration is not allowed here');
  if FDisallowDoctype then
    FatalError('Document type is prohibited by parser settings');

  ExpectString('DOCTYPE');
  SkipS(True);

  FDocType := TDTDModel.Create(FNameTable);
  FDTDProcessed := True;    // assume success
  FState := rsDTD;

  CheckName;
  SetString(FDocType.FName, FName.Buffer, FName.Length);
  DTDName := FNameTable.FindOrAdd(FName.Buffer, FName.Length);

  if SkipS then
  begin
    StoreLocation(Locs[0]);
    HasAtts := ParseExternalID(FDocType.FSystemID, FDocType.FPublicID, Locs[1], False);
    if HasAtts then
      Locs[2] := FTokenStart;
    SkipS;
  end;

  if CheckForChar('[') then
  begin
    BufAllocate(FIntSubset, 256);
    FSource.Kind := skInternalSubset;
    try
      FDTDStartPos := FSource.FBuf;
      ParseMarkupDecl;
      DTDReloadHook;     // fetch last chunk
      SetString(FDocType.FInternalSubset, FIntSubset.Buffer, FIntSubset.Length);
    finally
      FreeMem(FIntSubset.Buffer);
      FSource.Kind := skNone;
    end;
    ExpectChar(']');
    SkipS;
  end;
  ExpectChar('>');

  if (FDocType.FSystemID <> '') then
  begin
    if ResolveResource(FDocType.FSystemID, FDocType.FPublicID, FSource.SourceURI, Src) then
    begin
      SetSource(Src);
      Src.Initialize;
      try
        Src.Kind := skManualPop;
        ParseMarkupDecl;
      finally
        ContextPop(True);
      end;
    end
    else
    begin
      ValidationError('Unable to resolve external DTD subset', []);
      FDTDProcessed := FStandalone;
    end;
  end;
  FState := rsAfterDTD;
  FValue.Length := 0;
  BufAppendString(FValue, FDocType.FInternalSubset);
  SetNodeInfoWithValue(ntDocumentType, DTDName);
  if HasAtts then
  begin
    if FDocType.FPublicID <> '' then
      AddPseudoAttribute(FNameTable.FindOrAdd('PUBLIC'), FDocType.FPublicID, Locs[0], Locs[1]);
    AddPseudoAttribute(FNameTable.FindOrAdd('SYSTEM'), FDocType.FSystemID, Locs[0], Locs[2]);
  end;
end;

procedure TXMLTextReader.ExpectEq;   // [25]
begin
  if FSource.FBuf^ <> '=' then
    SkipS;
  if FSource.FBuf^ <> '=' then
    FatalError('Expected "="');
  FSource.NextChar;
  SkipS;
end;


{ DTD stuff }

procedure TXMLTextReader.CheckPENesting(aExpected: TObject);
begin
  if FSource.FEntity <> aExpected then
    ValidationError('Parameter entities must be properly nested', [], 0);
end;

function TXMLTextReader.ParseQuantity: TCPQuant;
begin
  case FSource.FBuf^ of
    '?': Result := cqZeroOrOnce;
    '*': Result := cqZeroOrMore;
    '+': Result := cqOnceOrMore;
  else
    Result := cqOnce;
    Exit;
  end;
  FSource.NextChar;
end;

function TXMLTextReader.FindOrCreateElDef: TElementDecl;
var
  p: PHashItem;
begin
  CheckName;
  p := FNameTable.FindOrAdd(FName.Buffer, FName.Length);
  Result := TElementDecl(p^.Data);
  if Result = nil then
  begin
    Result := TElementDecl.Create;
    p^.Data := Result;
  end;
end;

procedure TXMLTextReader.ExpectChoiceOrSeq(CP: TContentParticle; MustEndIn: TObject);     // [49], [50]
var
  Delim: WideChar;
  CurrentCP: TContentParticle;
begin
  Delim := #0;
  repeat
    CurrentCP := CP.Add;
    SkipWhitespace;
    if CheckForChar('(') then
      ExpectChoiceOrSeq(CurrentCP, FSource.FEntity)
    else
      CurrentCP.Def := FindOrCreateElDef;

    CurrentCP.CPQuant := ParseQuantity;
    SkipWhitespace;
    if FSource.FBuf^ = ')' then
      Break;
    if Delim = #0 then
    begin
      if (FSource.FBuf^ = '|') or (FSource.FBuf^ = ',') then
        Delim := FSource.FBuf^
      else
        FatalError('Expected pipe or comma delimiter');
    end
    else
      if FSource.FBuf^ <> Delim then
        FatalError(Delim);
    FSource.NextChar; // skip delimiter
  until False;
  CheckPENesting(MustEndIn);
  FSource.NextChar;

  if Delim = '|' then
    CP.CPType := ctChoice
  else
    CP.CPType := ctSeq;    // '(foo)' is a sequence!
end;

procedure TXMLTextReader.ParseElementDecl;            // [45]
var
  ElDef: TElementDecl;
  CurrentEntity: TObject;
  I: Integer;
  CP: TContentParticle;
  Typ: TElementContentType;
  ExtDecl: Boolean;
begin
  CP := nil;
  Typ := ctUndeclared;         // satisfy compiler
  ExpectWhitespace;
  ElDef := FindOrCreateElDef;
  if ElDef.ContentType <> ctUndeclared then
    ValidationErrorWithName('Duplicate declaration of element ''%s''', FName.Length);

  ExtDecl := FSource.Kind <> skInternalSubset;

  ExpectWhitespace;
  if FSource.Matches('EMPTY') then
    Typ := ctEmpty
  else if FSource.Matches('ANY') then
    Typ := ctAny
  else if CheckForChar('(') then
  begin
    CP := TContentParticle.Create;
    try
      CurrentEntity := FSource.FEntity;
      SkipWhitespace;
      if FSource.Matches('#PCDATA') then       // Mixed section [51]
      begin
        SkipWhitespace;
        Typ := ctMixed;
        while FSource.FBuf^ <> ')' do
        begin
          ExpectChar('|');
          SkipWhitespace;

          with CP.Add do
          begin
            Def := FindOrCreateElDef;
            for I := CP.ChildCount-2 downto 0 do
              if Def = CP.Children[I].Def then
                ValidationError('Duplicate token in mixed section', [], FName.Length);
          end;
          SkipWhitespace;
        end;
        CheckPENesting(CurrentEntity);
        FSource.NextChar;
        if (not CheckForChar('*')) and (CP.ChildCount > 0) then
          FatalError(WideChar('*'));
        CP.CPQuant := cqZeroOrMore;
        CP.CPType := ctChoice;
      end
      else       // Children section [47]
      begin
        Typ := ctChildren;
        ExpectChoiceOrSeq(CP, CurrentEntity);
        CP.CPQuant := ParseQuantity;
      end;
    except
      CP.Free;
      raise;
    end;
  end
  else
    FatalError('Invalid content specification');

  if FDTDProcessed and (ElDef.ContentType = ctUndeclared) then
  begin
    ElDef.ExternallyDeclared := ExtDecl;
    ElDef.ContentType := Typ;
    ElDef.RootCP := CP;
  end
  else
    CP.Free;
end;


procedure TXMLTextReader.ParseNotationDecl;        // [82]
var
  NameStr, SysID, PubID: XMLString;
  Notation: TNotationDecl;
  Entry: PHashItem;
  Src: TXMLCharSource;
  dummy: TLocation;
begin
  Src := FSource;
  ExpectWhitespace;
  CheckName;
  CheckNCName;
  SetString(NameStr, FName.Buffer, FName.Length);
  ExpectWhitespace;
  if not ParseExternalID(SysID, PubID, dummy, True) then
    FatalError('Expected external or public ID');
  if FDTDProcessed then
  begin
    Entry := FDocType.Notations.FindOrAdd(NameStr);
    if Entry^.Data = nil then
    begin
      Notation := TNotationDecl.Create;
      Notation.FName := NameStr;
      Notation.FPublicID := PubID;
      Notation.FSystemID := SysID;
      Notation.FURI := Src.SourceURI;
      Entry^.Data := Notation;
    end
    else
      ValidationError('Duplicate notation declaration: ''%s''', [NameStr]);
  end;
end;

const
  AttrDataTypeNames: array[TAttrDataType] of XMLString = (
    'CDATA',
    'ID',
    'IDREF',
    'IDREFS',
    'ENTITY',
    'ENTITIES',
    'NMTOKEN',
    'NMTOKENS',
    'NOTATION'
  );

procedure TXMLTextReader.ParseAttlistDecl;         // [52]
var
  ElDef: TElementDecl;
  AttDef: TAttributeDef;
  dt: TAttrDataType;
  Found, DiscardIt: Boolean;
  Offsets: array [Boolean] of Integer;
  attrName: PHashItem;
begin
  ExpectWhitespace;
  ElDef := FindOrCreateElDef;
  SkipWhitespace;
  while FSource.FBuf^ <> '>' do
  begin
    CheckName;
    ExpectWhitespace;
    attrName := FNameTable.FindOrAdd(FName.Buffer, FName.Length);
    AttDef := TAttributeDef.Create(attrName, FColonPos);
    try
      AttDef.ExternallyDeclared := FSource.Kind <> skInternalSubset;
// In case of duplicate declaration of the same attribute, we must discard it,
// not modifying ElDef, and suppressing certain validation errors.
      DiscardIt := (not FDTDProcessed) or Assigned(ElDef.GetAttrDef(attrName));

      if CheckForChar('(') then     // [59]
      begin
        AttDef.DataType := dtNmToken;
        repeat
          SkipWhitespace;
          CheckName([cnToken]);
          if not AttDef.AddEnumToken(FName.Buffer, FName.Length) then
            ValidationError('Duplicate token in enumerated attribute declaration', [], FName.Length);
          SkipWhitespace;
        until not CheckForChar('|');
        ExpectChar(')');
        ExpectWhitespace;
      end
      else
      begin
        StoreLocation(FTokenStart);
        // search topside-up so that e.g. NMTOKENS is matched before NMTOKEN
        for dt := dtNotation downto dtCData do
        begin
          Found := FSource.Matches(AttrDataTypeNames[dt]);
          if Found then
            Break;
        end;
        if Found and SkipWhitespace then
        begin
          AttDef.DataType := dt;
          if (dt = dtId) and not DiscardIt then
          begin
            if Assigned(ElDef.IDAttr) then
              ValidationError('Only one attribute of type ID is allowed per element',[])
            else
              ElDef.IDAttr := AttDef;
          end
          else if dt = dtNotation then          // no test cases for these ?!
          begin
            if not DiscardIt then
            begin
              if Assigned(ElDef.NotationAttr) then
                ValidationError('Only one attribute of type NOTATION is allowed per element',[])
              else
                ElDef.NotationAttr := AttDef;
              if ElDef.ContentType = ctEmpty then
                ValidationError('NOTATION attributes are not allowed on EMPTY elements',[]);
            end;
            ExpectChar('(');
            repeat
              SkipWhitespace;
              StoreLocation(FTokenStart);
              CheckName;
              CheckNCName;
              if not AttDef.AddEnumToken(FName.Buffer, FName.Length) then
                ValidationError('Duplicate token in NOTATION attribute declaration',[], FName.Length);

              if (not DiscardIt) and FValidate and
                (FDocType.Notations.Get(FName.Buffer,FName.Length)=nil) then
                AddForwardRef(FName.Buffer, FName.Length);
              SkipWhitespace;
            until not CheckForChar('|');
            ExpectChar(')');
            ExpectWhitespace;
          end;
        end
        else
        begin
          // don't report 'expected whitespace' if token does not match completely
          Offsets[False] := 0;
          Offsets[True] := Length(AttrDataTypeNames[dt]);
          if Found and (FSource.FBuf^ < 'A') then
            ExpectWhitespace
          else
            FatalError('Illegal attribute type for ''%s''', [attrName^.Key], Offsets[Found]);
        end;
      end;
      StoreLocation(FTokenStart);
      if FSource.Matches('#REQUIRED') then
        AttDef.Default := adRequired
      else if FSource.Matches('#IMPLIED') then
        AttDef.Default := adImplied
      else if FSource.Matches('#FIXED') then
      begin
        AttDef.Default := adFixed;
        ExpectWhitespace;
      end
      else
        AttDef.Default := adDefault;

      if AttDef.Default in [adDefault, adFixed] then
      begin
        if AttDef.DataType = dtId then
          ValidationError('An attribute of type ID cannot have a default value',[]);

// See comments to valid-sa-094: PE expansion should be disabled in AttDef.
        ExpectAttValue(AttDef.Data, dt <> dtCDATA);

        if not AttDef.ValidateSyntax(AttDef.Data^.FValueStr, FNamespaces) then
          ValidationError('Default value for attribute ''%s'' has wrong syntax', [attrName^.Key]);
      end;
      if DiscardIt then
        AttDef.Free
      else
        ElDef.AddAttrDef(AttDef);
    except
      AttDef.Free;
      raise;
    end;
    SkipWhitespace;
  end;
end;

procedure TXMLTextReader.ParseEntityDecl;        // [70]
var
  IsPE, Exists: Boolean;
  Entity: TEntityDecl;
  Map: THashTable;
  Item: PHashItem;
  dummy: TLocation;
begin
  Entity := TEntityDecl.Create;
  try
    Entity.ExternallyDeclared := FSource.Kind <> skInternalSubset;
    Entity.FURI := FSource.SourceURI;

    if not SkipWhitespace(True) then
      FatalError('Expected whitespace');
    IsPE := CheckForChar('%');
    if IsPE then                  // [72]
    begin
      ExpectWhitespace;
      if FPEMap = nil then
        FPEMap := THashTable.Create(64, True);
      Map := FPEMap;
    end
    else
      Map := FDocType.Entities;

    Entity.FIsPE := IsPE;
    CheckName;
    CheckNCName;
    Item := Map.FindOrAdd(FName.Buffer, FName.Length, Exists);
    ExpectWhitespace;

    if FEntityValue.Buffer = nil then
      BufAllocate(FEntityValue, 256);

    if ParseLiteral(FEntityValue, ltEntity, False) then
    begin
      SetString(Entity.FReplacementText, FEntityValue.Buffer, FEntityValue.Length);
      Entity.FCharCount := FEntityValue.Length;
      Entity.FStartLocation := FTokenStart;
    end
    else
    begin
      if not ParseExternalID(Entity.FSystemID, Entity.FPublicID, dummy, False) then
        FatalError('Expected entity value or external ID');

      if not IsPE then                // [76]
      begin
        if FSource.FBuf^ <> '>' then
          ExpectWhitespace;
        if FSource.Matches('NDATA') then
        begin
          ExpectWhitespace;
          StoreLocation(FTokenStart);  { needed for AddForwardRef }
          CheckName;
          SetString(Entity.FNotationName, FName.Buffer, FName.Length);
          if FValidate and (FDocType.Notations.Get(FName.Buffer, FName.Length)=nil) then
            AddForwardRef(FName.Buffer, FName.Length);
        end;
      end;
    end;
  except
    Entity.Free;
    raise;
  end;

  // Repeated declarations of same entity are legal but must be ignored
  if FDTDProcessed and not Exists then
  begin
    Item^.Data := Entity;
    Entity.FName := Item^.Key;
  end
  else
    Entity.Free;
end;

procedure TXMLTextReader.ParseIgnoreSection;
var
  IgnoreLoc: TLocation;
  IgnoreLevel: Integer;
  wc: WideChar;
begin
  StoreLocation(IgnoreLoc);
  IgnoreLevel := 1;
  repeat
    FValue.Length := 0;
    wc := FSource.SkipUntil(FValue, [#0, '<', ']']);
    if FSource.Matches('<![') then
      Inc(IgnoreLevel)
    else if FSource.Matches(']]>') then
      Dec(IgnoreLevel)
    else if wc <> #0 then
      FSource.NextChar
    else // PE's aren't recognized in ignore section, cannot ContextPop()
      DoErrorPos(esFatal, 'IGNORE section is not closed', IgnoreLoc);
  until IgnoreLevel=0;
end;

procedure TXMLTextReader.ParseMarkupDecl;        // [29]
var
  IncludeLevel: Integer;
  CurrentEntity: TObject;
  IncludeLoc: TLocation;
  CondType: (ctUnknown, ctInclude, ctIgnore);
begin
  IncludeLevel := 0;
  repeat
    SkipWhitespace;

    if (FSource.FBuf^ = ']') and (IncludeLevel > 0) then
    begin
      ExpectString(']]>');
      Dec(IncludeLevel);
      Continue;
    end;

    if not CheckForChar('<') then
      Break;

    CurrentEntity := FSource.FEntity;

    if FSource.FBuf^ = '?' then
    begin
      ParsePI;
    end
    else
    begin
      ExpectChar('!');
      if FSource.FBuf^ = '-' then
        ParseComment(True)
      else if CheckForChar('[') then
      begin
        if FSource.Kind = skInternalSubset then
          FatalError('Conditional sections are not allowed in internal subset', 1);

        SkipWhitespace;

        CondType := ctUnknown;  // satisfy compiler
        if FSource.Matches('INCLUDE') then
          CondType := ctInclude
        else if FSource.Matches('IGNORE') then
          CondType := ctIgnore
        else
          FatalError('Expected "INCLUDE" or "IGNORE"');

        SkipWhitespace;
        CheckPENesting(CurrentEntity);
        ExpectChar('[');
        if CondType = ctInclude then
        begin
          if IncludeLevel = 0 then
            StoreLocation(IncludeLoc);
          Inc(IncludeLevel);
        end
        else if CondType = ctIgnore then
          ParseIgnoreSection;
      end
      else
      begin
        FInsideDecl := True;
        if FSource.Matches('ELEMENT') then
          ParseElementDecl
        else if FSource.Matches('ENTITY') then
          ParseEntityDecl
        else if FSource.Matches('ATTLIST') then
          ParseAttlistDecl
        else if FSource.Matches('NOTATION') then
          ParseNotationDecl
        else
          FatalError('Illegal markup declaration');

        SkipWhitespace;

        CheckPENesting(CurrentEntity);
        ExpectChar('>');
        FInsideDecl := False;
      end;
    end;
  until False;
  if IncludeLevel > 0 then
    DoErrorPos(esFatal, 'INCLUDE section is not closed', IncludeLoc);
  if FSource.FBuf < FSource.FBufEnd then
    if (FSource.Kind <> skInternalSubset) or (FSource.FBuf^ <> ']') then
      FatalError('Illegal character in DTD');
end;

procedure TXMLTextReader.ParseDTD;
begin
  FSource.Initialize;
  ParseMarkupDecl;
end;

procedure TXMLTextReader.Close;
begin
  FReadState := rsClosed;
  FTokenStart.Line := 0;
  FTokenStart.LinePos := 0;
end;

function TXMLTextReader.GetAttributeCount: Integer;
begin
  result := FAttrCount;
end;

function TXMLTextReader.GetAttribute(i: Integer): XMLString;
begin
  if (i < 0) or (i >= FAttrCount) then
    raise EArgumentOutOfRangeException.Create('index');
  result := FNodeStack[FNesting+i+1].FValueStr;
end;

function TXMLTextReader.GetAttribute(const AName: XMLString): XMLString;
var
  i: Integer;
  p: PHashItem;
begin
  p := FNameTable.Find(PWideChar(AName), Length(AName));
  if Assigned(p) then
    for i := 1 to FAttrCount do
      if FNodeStack[FNesting+i].FQName = p then
      begin
        result := FNodeStack[FNesting+i].FValueStr;
        Exit;
      end;
  result := '';
end;

function TXMLTextReader.GetAttribute(const aLocalName, nsuri: XMLString): XMLString;
var
  i: Integer;
  p: PWideChar;
  p1: PHashItem;
  node: PNodeData;
begin
  p1 := FNameTable.Find(PWideChar(nsuri), Length(nsuri));
  if Assigned(p1) then
    for i := 1 to FAttrCount do
    begin
      node := @FNodeStack[FNesting+i];
      if node^.FNsUri = p1 then
      begin
        P := PWideChar(node^.FQName^.Key);
        if node^.FColonPos > 0 then
          Inc(P, node^.FColonPos+1);
        if (Length(node^.FQName^.Key)-node^.FColonPos-1 = Length(aLocalName)) and
          CompareMem(P, PWideChar(aLocalName), Length(aLocalName)*sizeof(WideChar)) then
        begin
          result := node^.FValueStr;
          Exit;
        end;
      end;
    end;
  result := '';
end;

function TXMLTextReader.GetDepth: Integer;
begin
  result := FNesting;
  if FCurrAttrIndex >= 0 then
    Inc(result);
  if FAttrReadState <> arsNone then
    Inc(result);
end;

function TXMLTextReader.GetNameTable: THashTable;
begin
  result := FNameTable;
end;

function TXMLTextReader.GetNodeType: TXmlNodeType;
begin
  result := FCurrNode^.FNodeType;
end;

function TXMLTextReader.GetName: XMLString;
begin
  if Assigned(FCurrNode^.FQName) then
    result := FCurrNode^.FQName^.Key
  else
    result := '';
end;

function TXMLTextReader.GetIsDefault: Boolean;
begin
  result := FCurrNode^.FIsDefault;
end;

function TXMLTextReader.GetBaseUri: XMLString;
begin
  result := FSource.SourceURI;
end;

function TXMLTextReader.GetXmlVersion: TXMLVersion;
begin
  result := FSource.FXMLVersion;
end;

function TXMLTextReader.GetXmlEncoding: XMLString;
begin
  result := FSource.FXMLEncoding;
end;

{ IXmlLineInfo methods }

function TXMLTextReader.GetHasLineInfo: Boolean;
begin
  result := True;
end;

function TXMLTextReader.GetLineNumber: Integer;
begin
  if (FCurrNode^.FNodeType in [ntElement,ntAttribute,ntEntityReference,ntEndEntity]) or (FAttrReadState <> arsNone) then
    result := FCurrNode^.FLoc.Line
  else
    result := FTokenStart.Line;
end;

function TXMLTextReader.GetLinePosition: Integer;
begin
  if (FCurrNode^.FNodeType in [ntElement,ntAttribute,ntEntityReference,ntEndEntity]) or (FAttrReadState <> arsNone) then
    result := FCurrNode^.FLoc.LinePos
  else
    result := FTokenStart.LinePos;
end;

function TXMLTextReader.CurrentNodePtr: PPNodeData;
begin
  result := @FCurrNode;
end;

function TXMLTextReader.LookupNamespace(const APrefix: XMLString): XMLString;
begin
  if Assigned(FNSHelper) then
    result := FNSHelper.LookupNamespace(APrefix)
  else
    result := '';
end;

function TXMLTextReader.MoveToFirstAttribute: Boolean;
begin
  result := False;
  if FAttrCount = 0 then
    exit;
  FCurrAttrIndex := 0;
  if FAttrReadState <> arsNone then
    CleanAttrReadState;
  FCurrNode := @FNodeStack[FNesting+1];
  result := True;
end;

function TXMLTextReader.MoveToNextAttribute: Boolean;
begin
  result := False;
  if FCurrAttrIndex+1 >= FAttrCount then
    exit;
  Inc(FCurrAttrIndex);
  if FAttrReadState <> arsNone then
    CleanAttrReadState;
  FCurrNode := @FNodeStack[FNesting+1+FCurrAttrIndex];
  result := True;
end;

function TXMLTextReader.MoveToElement: Boolean;
begin
  result := False;
  if FAttrReadState <> arsNone then
    CleanAttrReadState
  else if FCurrNode^.FNodeType <> ntAttribute then
    exit;
  FCurrNode := @FNodeStack[FNesting];
  FCurrAttrIndex := -1;
  result := True;
end;

function TXMLTextReader.ReadAttributeValue: Boolean;
var
  attrNode: PNodeData;
begin
  Result := False;
  if FAttrReadState = arsNone then
  begin
    if (FReadState <> rsInteractive) or (FCurrAttrIndex < 0) then
      Exit;

    attrNode := @FNodeStack[FNesting+FCurrAttrIndex+1];
    if attrNode^.FNext = nil then
    begin
      if attrNode^.FValueStr = '' then
        Exit;   { we don't want to expose empty textnodes }
      FCurrNode := AllocNodeData(FNesting+FAttrCount+1);
      FCurrNode^.FNodeType := ntText;
      FCurrNode^.FValueStr := attrNode^.FValueStr;
      FCurrNode^.FLoc := attrNode^.FLoc2;
    end
    else
      FCurrNode := attrNode^.FNext;
    FAttrReadState := arsText;
    FAttrBaseSource := FSource;
    Result := True;
  end
  else    // already reading, advance to next chunk
  begin
    if FSource = FAttrBaseSource then
    begin
      Result := Assigned(FCurrNode^.FNext);
      if Result then
        FCurrNode := FCurrNode^.FNext;
    end
    else
    begin
      NextAttrValueChunk;
      Result := True;
    end;
  end;
end;

procedure TXMLTextReader.NextAttrValueChunk;
var
  wc: WideChar;
  tok: TAttributeReadState;
begin
  if FAttrReadState = arsPushEntity then
  begin
    Inc(FNesting);
    { make sure that the location is available }
    AllocNodeData(FNesting+FAttrCount+1);
    FAttrReadState := arsText;
  end;

  FCurrNode := @FNodeStack[FNesting+FAttrCount+1];
  StoreLocation(FCurrNode^.FLoc);
  FValue.Length := 0;
  if FAttrReadState = arsText then
  repeat
    wc := FSource.SkipUntil(FValue, [#0, '&', #9, #10, #13]);
    if wc = '&' then
    begin
      if ParseRef(FValue) or ResolvePredefined then
        Continue;
      tok := arsEntity;
    end
    else if wc <> #0 then  { #9,#10,#13 -> replace by #32 }
    begin
      FSource.NextChar;
      BufAppend(FValue, #32);
      Continue;
    end
    else  // #0
      tok := arsEntityEnd;

    if FValue.Length <> 0 then
    begin
      FCurrNode^.FNodeType := ntText;
      FCurrNode^.FQName := nil;
      SetString(FCurrNode^.FValueStr, FValue.Buffer, FValue.Length);
      FAttrReadState := tok;
      Exit;
    end;
    Break;
  until False
  else
    tok := FAttrReadState;

  if tok = arsEntity then
  begin
    HandleEntityStart;
    FAttrReadState := arsText;
  end
  else if tok = arsEntityEnd then
  begin
    HandleEntityEnd;
    FAttrReadState := arsText;
  end;
end;

procedure TXMLTextReader.CleanAttrReadState;
begin
  while FSource <> FAttrBaseSource do
    ContextPop(True);
  FAttrReadState := arsNone;
end;

function TXMLTextReader.GetHasValue: Boolean;
begin
  result := FCurrNode^.FNodeType in [ntAttribute,ntText,ntCDATA,
    ntProcessingInstruction,ntComment,ntWhitespace,ntSignificantWhitespace,
    ntDocumentType];
end;

function TXMLTextReader.GetValue: XMLString;
begin
  if (FCurrAttrIndex>=0) or (FAttrReadState <> arsNone) then
    result := FCurrNode^.FValueStr
  else
    SetString(result, FCurrNode^.FValueStart, FCurrNode^.FValueLength);
end;

function TXMLTextReader.GetPrefix: XMLString;
begin
  if Assigned(FCurrNode^.FPrefix) then
    result := FCurrNode^.FPrefix^.Key
  else
    result := '';
end;

function TXMLTextReader.GetLocalName: XMLString;
begin
  if FNamespaces and Assigned(FCurrNode^.FQName) then
    if FCurrNode^.FColonPos < 0 then
      Result := FCurrNode^.FQName^.Key
    else
      Result := Copy(FCurrNode^.FQName^.Key, FCurrNode^.FColonPos+2, MaxInt)
  else
    Result := '';
end;

function TXMLTextReader.GetNamespaceUri: XMLString;
begin
  if Assigned(FCurrNode^.FNSURI) then
    result := FCurrNode^.FNSURI^.Key
  else
    result := '';
end;

procedure TXMLTextReader.SetEOFState;
begin
  FCurrNode := @FNodeStack[0];
  Finalize(FCurrNode^);
  FillChar(FCurrNode^, sizeof(TNodeData), 0);
  FReadState := rsEndOfFile;
end;

procedure TXMLTextReader.ValidateCurrentNode;
var
  ElDef: TElementDecl;
  AttDef: TAttributeDef;
  attr: PNodeData;
  i: Integer;
begin
  case FCurrNode^.FNodeType of
    ntElement:
      begin
        if (FNesting = 0) and (not FFragmentMode) then
        begin
          if Assigned(FDocType) then
          begin
            if FDocType.FName <> FCurrNode^.FQName^.Key then
              DoErrorPos(esError, 'Root element name does not match DTD', FCurrNode^.FLoc);
          end
          else
            DoErrorPos(esError, 'Missing DTD', FCurrNode^.FLoc);
        end;
        ElDef := TElementDecl(FCurrNode^.FQName^.Data);
        if (ElDef = nil) or (ElDef.ContentType = ctUndeclared) then
          DoErrorPos(esError, 'Using undeclared element ''%s''',[FCurrNode^.FQName^.Key], FCurrNode^.FLoc);

        if not FValidators[FValidatorNesting].IsElementAllowed(ElDef) then
          DoErrorPos(esError, 'Element ''%s'' is not allowed in this context',[FCurrNode^.FQName^.Key], FCurrNode^.FLoc);

        PushVC(ElDef);

        if ElDef = nil then
          Exit;

        { Validate attributes }
        for i := 1 to FAttrCount do
        begin
          attr := @FNodeStack[FNesting+i];
          AttDef := TAttributeDef(attr^.FTypeInfo);
          if AttDef = nil then
            DoErrorPos(esError, 'Using undeclared attribute ''%s'' on element ''%s''',
              [attr^.FQName^.Key, FCurrNode^.FQName^.Key], attr^.FLoc)
          else if ((AttDef.DataType <> dtCdata) or (AttDef.Default = adFixed)) then
          begin
            if FStandalone and AttDef.ExternallyDeclared then
              if attr^.FDenormalized then
                DoErrorPos(esError, 'In a standalone document, externally defined attribute cannot cause value normalization', attr^.FLoc2)
              else if i > FSpecifiedAttrs then
                DoError(esError, 'In a standalone document, attribute cannot have a default value defined externally');

            // TODO: what about normalization of AttDef.Value? (Currently it IS normalized)
            if (AttDef.Default = adFixed) and (AttDef.Data^.FValueStr <> attr^.FValueStr) then
              DoErrorPos(esError, 'Value of attribute ''%s'' does not match its #FIXED default',[attr^.FQName^.Key], attr^.FLoc2);
            if not AttDef.ValidateSyntax(attr^.FValueStr, FNamespaces) then
              DoErrorPos(esError, 'Attribute ''%s'' type mismatch', [attr^.FQName^.Key], attr^.FLoc2);
            ValidateAttrValue(AttDef, attr);
          end;
        end;

        { Check presence of #REQUIRED attributes }
        if ElDef.HasRequiredAtts then
          for i := 0 to ElDef.AttrDefCount-1 do
          begin
            if FAttrDefIndex[i] = FAttrTag then
              Continue;
            AttDef := ElDef.AttrDefs[i];
            if AttDef.Default = adRequired then
              ValidationError('Required attribute ''%s'' of element ''%s'' is missing',
                [AttDef.Data^.FQName^.Key, FCurrNode^.FQName^.Key], 0)
          end;
      end;

    ntEndElement:
      begin
        if FValidators[FValidatorNesting].Incomplete then
          ValidationError('Element ''%s'' is missing required sub-elements', [FCurrNode^.FQName^.Key], -1);
        if FValidatorNesting > 0 then
          Dec(FValidatorNesting);
      end;

    ntText, ntSignificantWhitespace:
      case FValidators[FValidatorNesting].FContentType of
        ctChildren:
          if FCurrNode^.FNodeType = ntText then
            ValidationError('Character data is not allowed in element-only content',[])
          else
          begin
            if FValidators[FValidatorNesting].FSaViolation then
              ValidationError('Standalone constraint violation',[]);
            FCurrNode^.FNodeType := ntWhitespace;
          end;
        ctEmpty:
          ValidationError('Character data is not allowed in EMPTY elements', []);
      end;

    ntCDATA:
      if FValidators[FValidatorNesting].FContentType = ctChildren then
        ValidationError('CDATA sections are not allowed in element-only content',[]);

    ntProcessingInstruction:
      if FValidators[FValidatorNesting].FContentType = ctEmpty then
        ValidationError('Processing instructions are not allowed within EMPTY elements', []);

    ntComment:
      if FValidators[FValidatorNesting].FContentType = ctEmpty then
        ValidationError('Comments are not allowed within EMPTY elements', []);

    ntDocumentType:
      ValidateDTD;
  end;
end;

procedure TXMLTextReader.HandleEntityStart;
begin
  FCurrNode := @FNodeStack[FNesting+(FAttrCount+1)*ord(FAttrReadState<>arsNone)];
  FCurrNode^.FNodeType := ntEntityReference;
  FCurrNode^.FQName := FNameTable.FindOrAdd(FName.Buffer, FName.Length);
  FCurrNode^.FColonPos := -1;
  FCurrNode^.FValueStart := nil;
  FCurrNode^.FValueLength := 0;
  FCurrNode^.FValueStr := '';
  StoreLocation(FCurrNode^.FLoc);
  { point past '&' to first char of entity name }
  Dec(FCurrNode^.FLoc.LinePos, FName.Length+1);
end;

procedure TXMLTextReader.HandleEntityEnd;
begin
  ContextPop(True);
  if FNesting > 0 then Dec(FNesting);
  FCurrNode := @FNodeStack[FNesting+(FAttrCount+1)*ord(FAttrReadState<>arsNone)];
  FCurrNode^.FNodeType := ntEndEntity;
  { point to trailing ';' }
  Inc(FCurrNode^.FLoc.LinePos, Length(FCurrNode^.FQName^.Key));
end;

procedure TXMLTextReader.ResolveEntity;
var
  n: PNodeData;
  ent: TEntityDecl;
begin
  if FCurrNode^.FNodeType <> ntEntityReference then
    raise EInvalidOperation.Create('Wrong node type');

  if FAttrReadState <> arsNone then
  begin
    { copy the EntityReference node to the stack if not already there }
    n := AllocNodeData(FNesting+FAttrCount+1);
    if n <> FCurrNode then
      n^ := FCurrNode^;

    ent := nil;
    if Assigned(FDocType) then
      ent := FDocType.Entities.Get(PWideChar(n^.FQName^.Key),Length(n^.FQName^.Key)) as TEntityDecl;
    ContextPush(ent, True);
    FAttrReadState := arsPushEntity;
  end
  else
    FNext := xtPushEntity;
end;

procedure TXMLTextReader.DoStartEntity;
begin
  Inc(FNesting);
  FCurrNode := AllocNodeData(FNesting);
  ContextPush(FCurrEntity, True);
  FNext := xtText;
end;

// The code below does the bulk of the parsing, and must be as fast as possible.
// To minimize CPU cache effects, methods from different classes are kept together

function TXMLDecodingSource.SkipUntil(var ToFill: TWideCharBuf; const Delim: TSetOfChar;
  wsflag: PBoolean): WideChar;
var
  old: PWideChar;
  nonws: Boolean;
  wc: WideChar;
begin
  nonws := False;
  repeat
    old := FBuf;
    repeat
      wc := FBuf^;
      if (wc = #10) or (wc = #13) or (FXML11Rules and ((wc = #$85) or
        (wc = #$2028))) then
      begin
// strictly this is needed only for 2-byte lineendings
        BufAppendChunk(ToFill, old, FBuf);
        NewLine;
        old := FBuf;
        wc := FBuf^
      end
      else if ((wc < #32) and (not ((wc = #0) and (FBuf >= FBufEnd))) and
        (wc <> #9)) or (wc > #$FFFD) or
        (FXML11Rules and (wc >= #$7F) and (wc <= #$9F)) then
             FReader.FatalError('Invalid character');
      if (wc < #255) and (Char(ord(wc)) in Delim) then
        Break;
// the checks above filter away everything below #32 that isn't a whitespace
      if wc > #32 then
        nonws := True;
      Inc(FBuf);
    until False;
    Result := wc;
    BufAppendChunk(ToFill, old, FBuf);
  until (Result <> #0) or (not Reload);
  if Assigned(wsflag) then
    wsflag^ := wsflag^ or nonws;
end;

const
  TextDelims: array[Boolean] of TSetOfChar = (
    [#0, '<', '&', '>'],
    [#0, '>']
  );

  textNodeTypes: array[Boolean] of TXMLNodeType = (
    ntSignificantWhitespace,
    ntText
  );

function TXMLTextReader.ReadTopLevel: Boolean;
var
  tok: TXMLToken;
begin
  if FNext = xtFakeLF then
  begin
    Result := SetupFakeLF(xtText);
    Exit;
  end;

  StoreLocation(FTokenStart);

  if FNext = xtText then
  repeat
    SkipS;
    if FSource.FBuf^ = '<' then
    begin
      Inc(FSource.FBuf);
      if FSource.FBufEnd < FSource.FBuf + 2 then
        FSource.Reload;
      if FSource.FBuf^ = '!' then
      begin
        Inc(FSource.FBuf);
        if FSource.FBuf^ = '-' then
        begin
          if FIgnoreComments then
          begin
            ParseComment(True);
            Continue;
          end;
          tok := xtComment;
        end
        else
          tok := xtDoctype;
      end
      else if FSource.FBuf^ = '?' then
        tok := xtPI
      else
      begin
        CheckName;
        tok := xtElement;
      end;
    end
    else if FSource.FBuf >= FSource.FBufEnd then
    begin
      if FState < rsRoot then
        FatalError('Root element is missing');
      tok := xtEOF;
    end
    else
      FatalError('Illegal at document level');

    if FCanonical and (FState > rsRoot) and (tok <> xtEOF) then
    begin
      Result := SetupFakeLF(tok);
      Exit;
    end;

    Break;
  until False
  else   // FNext <> xtText
    tok := FNext;

  if FCanonical and (FState < rsRoot) and (tok <> xtDoctype) then
    FNext := xtFakeLF
  else
    FNext := xtText;

  case tok of
    xtElement:
      begin
        if FState > rsRoot then
          FatalError('Only one top-level element allowed', FName.Length)
        else if FState < rsRoot then
        begin
          // dispose notation refs from DTD, if any
          ClearForwardRefs;
          FState := rsRoot;
        end;
        ParseStartTag;
      end;
    xtPI:         ParsePI;
    xtComment:    ParseComment(False);
    xtDoctype:
      begin
        ParseDoctypeDecl;
        if FCanonical then
        begin
          // recurse, effectively ignoring the DTD
          result := ReadTopLevel();
          Exit;
        end;
      end;
    xtEOF:  SetEofState;
  end;
  Result := tok <> xtEOF;
end;

function TXMLTextReader.Read: Boolean;
var
  nonWs: Boolean;
  wc: WideChar;
  InCDATA: Boolean;
  tok: TXMLToken;
begin
  if FReadState > rsInteractive then
  begin
    Result := False;
    Exit;
  end;
  if FReadState = rsInitial then
  begin
    FReadState := rsInteractive;
    FSource.Initialize;
    FNext := xtText;
  end;
  if FAttrReadState <> arsNone then
    CleanAttrReadState;
  if FNext = xtPopEmptyElement then
  begin
    FNext := xtPopElement;
    FCurrNode^.FNodeType := ntEndElement;
    if FAttrCleanupFlag then
      CleanupAttributes;
    FAttrCount := 0;
    FCurrAttrIndex := -1;
    Result := True;
    Exit;
  end;
  if FNext = xtPushElement then
  begin
    if FAttrCleanupFlag then
      CleanupAttributes;
    FAttrCount := 0;
    Inc(FNesting);
    FCurrAttrIndex := -1;
    FNext := xtText;
  end
  else if FNext = xtPopElement then
    PopElement
  else if FNext = xtPushEntity then
    DoStartEntity;

  if FState <> rsRoot then
  begin
    Result := ReadTopLevel;
    Exit;
  end;

  InCDATA := (FNext = xtCDSect);
  StoreLocation(FTokenStart);
  nonWs := False;
  FValue.Length := 0;

  if FNext in [xtCDSect, xtText] then
  repeat
    wc := FSource.SkipUntil(FValue, TextDelims[InCDATA], @nonWs);
    if wc = '<' then
    begin
      Inc(FSource.FBuf);
      if FSource.FBufEnd < FSource.FBuf + 2 then
        FSource.Reload;
      if FSource.FBuf^ = '/' then
        tok := xtEndElement
      else if CheckName([cnOptional]) then
        tok := xtElement
      else if FSource.FBuf^ = '!' then
      begin
        Inc(FSource.FBuf);
        if FSource.FBuf^ = '[' then
        begin
          ExpectString('[CDATA[');
          StoreLocation(FTokenStart);
          InCDATA := True;
          if FCDSectionsAsText or (FValue.Length = 0) then
            Continue;
          tok := xtCDSect;
        end
        else if FSource.FBuf^ = '-' then
        begin
        { Ignoring comments is tricky in validating mode; discarding a comment which
          is the only child of an EMPTY element will make that element erroneously appear
          as valid. Therefore, at this point we discard only comments which are preceded
          by some text (since presence of text already renders an EMPTY element invalid).
          Other comments should be reported to validation part and discarded there. }
          if FIgnoreComments and (FValue.Length > 0) then
          begin
            ParseComment(True);
            Continue;
          end;
          tok := xtComment;
        end
        else
          tok := xtDoctype;
      end
      else if FSource.FBuf^ = '?' then
        tok := xtPI
      else
        RaiseNameNotFound;
    end
    else if wc = #0 then
    begin
      if InCDATA then
        FatalError('Unterminated CDATA section', -1);
      if FNesting > FSource.FStartNesting then
        FatalError('End-tag is missing for ''%s''', [FNodeStack[FNesting-1].FQName^.Key]);

      if Assigned(FSource.FParent) then
      begin
        if FExpandEntities and ContextPop then
          Continue
        else
          tok := xtEntityEnd;
      end
      else
        tok := xtEOF;
    end
    else if wc = '>' then
    begin
      BufAppend(FValue, wc);
      FSource.NextChar;

      if (FValue.Length <= 2) or (FValue.Buffer[FValue.Length-2] <> ']') or
        (FValue.Buffer[FValue.Length-3] <> ']') then Continue;

      if InCData then   // got a ']]>' separator
      begin
        Dec(FValue.Length, 3);
        InCDATA := False;
        if FCDSectionsAsText then
          Continue;
        SetNodeInfoWithValue(ntCDATA);
        FNext := xtText;
        Result := True;
        Exit;
      end
      else
        FatalError('Literal '']]>'' is not allowed in text', 3);
    end
    else if wc = '&' then
    begin
      if FValidators[FValidatorNesting].FContentType = ctEmpty then
        ValidationError('References are illegal in EMPTY elements', []);

      if ParseRef(FValue) or ResolvePredefined then
      begin
        nonWs := True; // CharRef to whitespace is not considered whitespace
        Continue;
      end
      else
      begin
        FCurrEntity := EntityCheck;
        if Assigned(FCurrEntity) and FExpandEntities then
        begin
          ContextPush(FCurrEntity);
          Continue;
        end;
        tok := xtEntity;
      end;
    end;
    if FValue.Length <> 0 then
    begin
      SetNodeInfoWithValue(textNodeTypes[nonWs]);
      FNext := tok;
      Result := True;
      Exit;
    end;
    Break;
  until False
  else   // not (FNext in [xtText, xtCDSect])
    tok := FNext;

  FNext := xtText;

  case tok of
    xtEntity:     HandleEntityStart;
    xtEntityEnd:  HandleEntityEnd;
    xtElement:    ParseStartTag;
    xtEndElement: ParseEndTag;
    xtPI:         ParsePI;
    xtDoctype:    ParseDoctypeDecl;
    xtComment:    ParseComment(False);
    xtEOF:        SetEofState;
  end;
  Result := tok <> xtEOF;
end;

procedure TXMLCharSource.NextChar;
begin
  Inc(FBuf);
  if FBuf >= FBufEnd then
    Reload;
end;

procedure TXMLTextReader.ExpectChar(wc: WideChar);
begin
  if FSource.FBuf^ = wc then
    FSource.NextChar
  else
    FatalError(wc);
end;

// Element name already in FNameBuffer
procedure TXMLTextReader.ParseStartTag;    // [39] [40] [44]
var
  ElDef: TElementDecl;
  IsEmpty: Boolean;
  ElName: PHashItem;
  b: TBinding;
  Len: Integer;
begin
  ElName := FNameTable.FindOrAdd(FName.Buffer, FName.Length);
  ElDef := TElementDecl(ElName^.Data);
  if Assigned(ElDef) then
    Len := ElDef.AttrDefCount+8  { overallocate a bit }
  else
    Len := 0;
  // (re)initialize array of attribute definition tags
  if (Len-8 > Length(FAttrDefIndex)) or (FAttrTag = 0) then
  begin
    SetLength(FAttrDefIndex, Len);
    for Len := 0 to High(FAttrDefIndex) do
      FAttrDefIndex[Len] := FAttrTag;
  end;
  // we're about to process a new set of attributes
{$push}{$r-,q-}
  Dec(FAttrTag);
{$pop}

  IsEmpty := False;
  FAttrCount := 0;
  FCurrAttrIndex := -1;
  FPrefixedAttrs := 0;
  FSpecifiedAttrs := 0;

  FCurrNode := AllocNodeData(FNesting);
  FCurrNode^.FQName := ElName;
  FCurrNode^.FNodeType := ntElement;
  FCurrNode^.FColonPos := FColonPos;
  StoreLocation(FCurrNode^.FLoc);
  Dec(FCurrNode^.FLoc.LinePos, FName.Length);

  if FNamespaces then
  begin
    FNSHelper.PushScope;
    if FColonPos > 0 then
      FCurrNode^.FPrefix := FNSHelper.GetPrefix(FName.Buffer, FColonPos);
  end;

  while (FSource.FBuf^ <> '>') and (FSource.FBuf^ <> '/') do
  begin
    SkipS(True);
    if (FSource.FBuf^ = '>') or (FSource.FBuf^ = '/') then
      Break;
    ParseAttribute(ElDef);
  end;

  if FSource.FBuf^ = '/' then
  begin
    IsEmpty := True;
    FSource.NextChar;
  end;
  ExpectChar('>');

  if Assigned(ElDef) and ElDef.NeedsDefaultPass then
    ProcessDefaultAttributes(ElDef);

  // Adding attributes might have reallocated FNodeStack, so restore FCurrNode once again
  FCurrNode := @FNodeStack[FNesting];

  if FNamespaces then
  begin
    { Assign namespace URIs to prefixed attrs }
    if FPrefixedAttrs <> 0 then
      ProcessNamespaceAtts;
    { Expand the element name }
    if Assigned(FCurrNode^.FPrefix) then
    begin
      b := TBinding(FCurrNode^.FPrefix^.Data);
      if not (Assigned(b) and Assigned(b.uri) and (b.uri^.Key <> '')) then
        DoErrorPos(esFatal, 'Unbound element name prefix "%s"', [FCurrNode^.FPrefix^.Key],FCurrNode^.FLoc);
      FCurrNode^.FNsUri := b.uri;
    end
    else
    begin
      b := FNSHelper.DefaultNSBinding;
      if Assigned(b) then
        FCurrNode^.FNsUri := b.uri;
    end;
  end;

  if not IsEmpty then
  begin
    if not FPreserveWhitespace then   // critical for testsuite compliance
      SkipS;
    FNext := xtPushElement;
  end
  else
    FNext := xtPopEmptyElement;
end;

procedure TXMLTextReader.ParseEndTag;     // [42]
var
  ElName: PHashItem;
begin
  if FNesting <= FSource.FStartNesting then
    FatalError('End-tag is not allowed here');
  if FNesting > 0 then Dec(FNesting);
  Inc(FSource.FBuf);

  FCurrNode := @FNodeStack[FNesting];  // move off the possible child
  FCurrNode^.FNodeType := ntEndElement;
  StoreLocation(FTokenStart);
  FCurrNode^.FLoc := FTokenStart;
  ElName := FCurrNode^.FQName;

  if not FSource.MatchesLong(ElName^.Key) then
    FatalError('Unmatching element end tag (expected "</%s>")', [ElName^.Key], -1);
  if FSource.FBuf^ = '>' then    // this handles majority of cases
    FSource.NextChar
  else
  begin             // gives somewhat incorrect message for <a></aa>
    SkipS;
    ExpectChar('>');
  end;
  FNext := xtPopElement;
end;

procedure TXMLTextReader.ParseAttribute(ElDef: TElementDecl);
var
  attrName: PHashItem;
  attrData: PNodeData;
  AttDef: TAttributeDef;
  i: Integer;
begin
  CheckName;
  attrName := FNameTable.FindOrAdd(FName.Buffer, FName.Length);
  attrData := AllocAttributeData;
  attrData^.FQName := attrName;
  attrData^.FColonPos := FColonPos;
  StoreLocation(attrData^.FLoc);
  Dec(attrData^.FLoc.LinePos, FName.Length);
  FSpecifiedAttrs := FAttrCount;

  if Assigned(ElDef) then
  begin
    AttDef := ElDef.GetAttrDef(attrName);
    // mark attribute as specified
    if Assigned(AttDef) then
      FAttrDefIndex[AttDef.Index] := FAttrTag;
  end
  else
    AttDef := nil;

  attrData^.FTypeInfo := AttDef;
  // check for duplicates
  for i := 1 to FAttrCount-1 do
    if FNodeStack[FNesting+i].FQName = attrName then
      FatalError('Duplicate attribute', FName.Length);

  if FNamespaces then
  begin
    if ((FName.Length = 5) or (FColonPos = 5)) and
      (FName.Buffer[0] = 'x') and (FName.Buffer[1] = 'm') and
      (FName.Buffer[2] = 'l') and (FName.Buffer[3] = 'n') and
      (FName.Buffer[4] = 's') then
    begin
      if FColonPos > 0 then
        attrData^.FPrefix := FStdPrefix_xmlns;
      attrData^.FNsUri := FStdUri_xmlns;
    end
    else if FColonPos > 0 then
    begin
      attrData^.FPrefix := FNSHelper.GetPrefix(FName.Buffer, FColonPos);
      Inc(FPrefixedAttrs);
    end;
  end;

  ExpectEq;
  ExpectAttValue(attrData, Assigned(AttDef) and (AttDef.DataType <> dtCDATA));

  if Assigned(attrData^.FNsUri) then
  begin
    if (not AddBinding(attrData)) and FCanonical then
    begin
      CleanupAttribute(attrData);
      Dec(FAttrCount);
      Dec(FSpecifiedAttrs);
    end;
  end;
end;

procedure TXMLTextReader.AddForwardRef(Buf: PWideChar; Length: Integer);
var
  w: PForwardRef;
begin
  if FForwardRefs = nil then
    FForwardRefs := TFPList.Create;
  New(w);
  SetString(w^.Value, Buf, Length);
  w^.Loc := FTokenStart;
  FForwardRefs.Add(w);
end;

procedure TXMLTextReader.ClearForwardRefs;
var
  I: Integer;
begin
  if Assigned(FForwardRefs) then
  begin
    for I := 0 to FForwardRefs.Count-1 do
      Dispose(PForwardRef(FForwardRefs.List^[I]));
    FForwardRefs.Clear;
  end;
end;

procedure TXMLTextReader.ValidateIdRefs;
var
  I: Integer;
begin
  if Assigned(FForwardRefs) then
  begin
    for I := 0 to FForwardRefs.Count-1 do
      with PForwardRef(FForwardRefs.List^[I])^ do
        if (FIDMap = nil) or (FIDMap.Find(PWideChar(Value), Length(Value)) = nil) then
          DoErrorPos(esError, 'The ID ''%s'' does not match any element', [Value], Loc);
    ClearForwardRefs;
  end;
end;

procedure TXMLTextReader.ProcessDefaultAttributes(ElDef: TElementDecl);
var
  I: Integer;
  AttDef: TAttributeDef;
  attrData: PNodeData;
begin
  for I := 0 to ElDef.AttrDefCount-1 do
  begin
    if FAttrDefIndex[I] <> FAttrTag then  // this one wasn't specified
    begin
      AttDef := ElDef.AttrDefs[I];
      case AttDef.Default of
        adDefault, adFixed: begin
          attrData := AllocAttributeData;
          attrData^ := AttDef.Data^;
          if FCanonical then
            attrData^.FIsDefault := False;

          if FNamespaces then
          begin
            if AttDef.IsNamespaceDecl then
            begin
              if attrData^.FColonPos > 0 then
                attrData^.FPrefix := FStdPrefix_xmlns;
              attrData^.FNsUri := FStdUri_xmlns;
              if (not AddBinding(attrData)) and FCanonical then
                Dec(FAttrCount);
            end
            else if attrData^.FColonPos > 0 then
            begin
              attrData^.FPrefix := FNSHelper.GetPrefix(PWideChar(attrData^.FQName^.Key), attrData^.FColonPos);
              Inc(FPrefixedAttrs);
            end
            else
              attrData^.FNsUri := FEmptyStr;
          end;
        end;
      end;
    end;
  end;
end;


function TXMLTextReader.AddBinding(attrData: PNodeData): Boolean;
var
  nsUri, Pfx: PHashItem;
begin
  nsUri := FNameTable.FindOrAdd(attrData^.FValueStr);
  if attrData^.FColonPos > 0 then
    Pfx := FNSHelper.GetPrefix(@attrData^.FQName^.key[7], Length(attrData^.FQName^.key)-6)
  else
    Pfx := FNSHelper.GetPrefix(nil, 0);  { will return the default prefix }
  { 'xml' is allowed to be bound to the correct namespace }
  if ((nsUri = FStduri_xml) <> (Pfx = FStdPrefix_xml)) or
   (Pfx = FStdPrefix_xmlns) or
   (nsUri = FStduri_xmlns) then
  begin
    if (Pfx = FStdPrefix_xml) or (Pfx = FStdPrefix_xmlns) then
      DoErrorPos(esFatal, 'Illegal usage of reserved prefix ''%s''', [Pfx^.Key], attrData^.FLoc)
    else
      DoErrorPos(esFatal, 'Illegal usage of reserved namespace URI ''%s''', [attrData^.FValueStr], attrData^.FLoc2);
  end;

  if (attrData^.FValueStr = '') and not (FXML11 or (Pfx^.Key = '')) then
    DoErrorPos(esFatal, 'Illegal undefining of namespace', attrData^.FLoc2);

  Result := (Pfx^.Data = nil) or (TBinding(Pfx^.Data).uri <> nsUri);
  if Result then
    FNSHelper.BindPrefix(nsUri, Pfx);
end;

procedure TXMLTextReader.ProcessNamespaceAtts;
var
  I, J: Integer;
  Pfx, AttrName: PHashItem;
  attrData: PNodeData;
  b: TBinding;
begin
  FNsAttHash.Init(FPrefixedAttrs);
  for I := 1 to FAttrCount do
  begin
    attrData := @FNodeStack[FNesting+i];
    if Assigned(attrData^.FNsUri) then
      Continue;
    if (attrData^.FColonPos < 1) then
    begin
      attrData^.FNsUri := FEmptyStr;
      Continue;
    end;

    Pfx := attrData^.FPrefix;
    b := TBinding(Pfx^.Data);
    if not (Assigned(b) and Assigned (b.uri) and (b.uri^.Key <> '')) then
      DoErrorPos(esFatal, 'Unbound attribute name prefix "%s"', [Pfx^.Key], attrData^.FLoc);

    { detect duplicates }
    J := attrData^.FColonPos+1;
    AttrName := attrData^.FQName;

    if FNsAttHash.Locate(b.uri, @AttrName^.Key[J], Length(AttrName^.Key) - J+1) then
      DoErrorPos(esFatal, 'Duplicate prefixed attribute', attrData^.FLoc);

    attrData^.FNsUri := b.uri;
  end;
end;

function TXMLTextReader.ParseExternalID(out SysID, PubID: XMLString;     // [75]
  out PubIDLoc: TLocation; SysIdOptional: Boolean): Boolean;
var
  I: Integer;
  wc: WideChar;
begin
  Result := False;
  if FSource.Matches('SYSTEM') then
    SysIdOptional := False
  else if FSource.Matches('PUBLIC') then
  begin
    ExpectWhitespace;
    ParseLiteral(FValue, ltPubid, True);
    PubIDLoc := FTokenStart;
    SetString(PubID, FValue.Buffer, FValue.Length);
    for I := 1 to Length(PubID) do
    begin
      wc := PubID[I];
      if (wc > #255) or not (Char(ord(wc)) in PubidChars) then
        FatalError('Illegal Public ID literal', -1);
    end;
  end
  else
    Exit;

  if SysIdOptional then
    SkipWhitespace
  else
    ExpectWhitespace;
  if ParseLiteral(FValue, ltPlain, not SysIdOptional) then
    SetString(SysID, FValue.Buffer, FValue.Length);
  Result := True;
end;

procedure TXMLTextReader.ValidateAttrValue(AttrDef: TAttributeDef; attrData: PNodeData);
var
  L, StartPos, EndPos: Integer;
  Entity: TEntityDecl;
begin
  L := Length(attrData^.FValueStr);
  case AttrDef.DataType of
    dtId: begin
      if not AddID(attrData) then
        DoErrorPos(esError, 'The ID ''%s'' is not unique', [attrData^.FValueStr], attrData^.FLoc2);
    end;

    dtIdRef, dtIdRefs: begin
      StartPos := 1;
      while StartPos <= L do
      begin
        EndPos := StartPos;
        while (EndPos <= L) and (attrData^.FValueStr[EndPos] <> #32) do
          Inc(EndPos);
        if (FIDMap = nil) or (FIDMap.Find(@attrData^.FValueStr[StartPos], EndPos-StartPos) = nil) then
          AddForwardRef(@attrData^.FValueStr[StartPos], EndPos-StartPos);
        StartPos := EndPos + 1;
      end;
    end;

    dtEntity, dtEntities: begin
      StartPos := 1;
      while StartPos <= L do
      begin
        EndPos := StartPos;
        while (EndPos <= L) and (attrData^.FValueStr[EndPos] <> #32) do
          Inc(EndPos);
        Entity := TEntityDecl(FDocType.Entities.Get(@attrData^.FValueStr[StartPos], EndPos-StartPos));
        if (Entity = nil) or (Entity.FNotationName = '') then
          ValidationError('Attribute ''%s'' type mismatch', [attrData^.FQName^.Key], -1);
        StartPos := EndPos + 1;
      end;
    end;
  end;
end;

procedure TXMLTextReader.ValidateDTD;
var
  I: Integer;
begin
  if Assigned(FForwardRefs) then
  begin
    for I := 0 to FForwardRefs.Count-1 do
      with PForwardRef(FForwardRefs[I])^ do
        if FDocType.Notations.Get(PWideChar(Value), Length(Value)) = nil then
          DoErrorPos(esError, 'Notation ''%s'' is not declared', [Value], Loc);
  end;
end;

function TXMLTextReader.AddId(aNodeData: PNodeData): Boolean;
var
  e: PHashItem;
begin
  if FIDMap = nil then
    FIDMap := THashTable.Create(256, False);
  e := FIDMap.FindOrAdd(PWideChar(aNodeData^.FValueStr), Length(aNodeData^.FValueStr), Result);
  Result := not Result;
  if Result then
    aNodeData^.FIDEntry := e;
end;

function TXMLTextReader.AllocAttributeData: PNodeData;
begin
  Result := AllocNodeData(FNesting + FAttrCount + 1);
  Result^.FNodeType := ntAttribute;
  Result^.FIsDefault := False;
  Inc(FAttrCount);
end;

procedure TXMLTextReader.AddPseudoAttribute(aName: PHashItem; const aValue: XMLString;
  const nameLoc, valueLoc: TLocation);
begin
  with AllocAttributeData^ do
  begin
    FQName := aName;
    FColonPos := -1;
    FValueStr := aValue;
    FLoc := nameLoc;
    FLoc2 := valueLoc;
  end;
end;

function TXMLTextReader.AllocNodeData(AIndex: Integer): PNodeData;
begin
  {make sure we have an extra slot to place child text/comment/etc}
  if AIndex >= Length(FNodeStack)-1 then
    SetLength(FNodeStack, AIndex * 2 + 2);

  Result := @FNodeStack[AIndex];
  Result^.FNext := nil;
  Result^.FPrefix := nil;
  Result^.FNsUri := nil;
  Result^.FIDEntry := nil;
  Result^.FValueStart := nil;
  Result^.FValueLength := 0;
end;

procedure TXMLTextReader.AllocAttributeValueChunk(var APrev: PNodeData; Offset: Integer);
var
  chunk: PNodeData;
begin
  { when parsing DTD, don't take ownership of allocated data }
  chunk := FFreeAttrChunk;
  if Assigned(chunk) and (FState <> rsDTD) then
  begin
    FFreeAttrChunk := chunk^.FNext;
    chunk^.FNext := nil;
  end
  else { no free chunks, create a new one }
    chunk := AllocMem(sizeof(TNodeData));
  APrev^.FNext := chunk;
  APrev := chunk;
  { assume text node, for entity refs it is overridden later }
  chunk^.FNodeType := ntText;
  chunk^.FQName := nil;
  chunk^.FColonPos := -1;
  { without PWideChar typecast and in $T-, FPC treats '@' result as PAnsiChar... }
  SetString(chunk^.FValueStr, PWideChar(@FValue.Buffer[Offset]), FValue.Length-Offset);
end;

procedure TXMLTextReader.CleanupAttributes;
var
  i: Integer;
begin
  {cleanup only specified attributes; default ones are owned by DTD}
  for i := 1 to FSpecifiedAttrs do
    CleanupAttribute(@FNodeStack[FNesting+i]);
  FAttrCleanupFlag := False;
end;

procedure TXMLTextReader.CleanupAttribute(aNode: PNodeData);
var
  chunk: PNodeData;
begin
  if Assigned(aNode^.FNext) then
  begin
    chunk := aNode^.FNext;
    while Assigned(chunk^.FNext) do
      chunk := chunk^.FNext;
    chunk^.FNext := FFreeAttrChunk;
    FFreeAttrChunk := aNode^.FNext;
    aNode^.FNext := nil;
  end;
end;

procedure TXMLTextReader.SetNodeInfoWithValue(typ: TXMLNodeType; AName: PHashItem = nil);
begin
  FCurrNode := @FNodeStack[FNesting];
  FCurrNode^.FNodeType := typ;
  FCurrNode^.FQName := AName;
  FCurrNode^.FColonPos := -1;
  FCurrNode^.FValueStart := FValue.Buffer;
  FCurrNode^.FValueLength := FValue.Length;
end;

function TXMLTextReader.SetupFakeLF(nextstate: TXMLToken): Boolean;
begin
  FValue.Buffer[0] := #10;
  FValue.Length := 1;
  SetNodeInfoWithValue(ntWhitespace,nil);
  FNext := nextstate;
  Result := True;
end;

procedure TXMLTextReader.PushVC(aElDef: TElementDecl);
begin
  Inc(FValidatorNesting);
  if FValidatorNesting >= Length(FValidators) then
    SetLength(FValidators, FValidatorNesting * 2);

  with FValidators[FValidatorNesting] do
  begin
    FElementDef := aElDef;
    FCurCP := nil;
    FFailed := False;
    FContentType := ctAny;
    FSaViolation := False;
    if Assigned(aElDef) then
    begin
      FContentType := aElDef.ContentType;
      FSaViolation := FStandalone and aElDef.ExternallyDeclared;
    end;
  end;
end;

procedure TXMLTextReader.PopElement;
begin
  if FNamespaces then
    FNSHelper.PopScope;

  if (FNesting = 0) and (not FFragmentMode) then
    FState := rsEpilog;
  FCurrNode := @FNodeStack[FNesting];
  FNext := xtText;
end;

{ TElementValidator }

function TElementValidator.IsElementAllowed(Def: TElementDecl): Boolean;
var
  Next: TContentParticle;
begin
  Result := True;
  // if element is not declared, non-validity has been already reported, no need to report again...
  if Assigned(Def) and Assigned(FElementDef) then
  begin
    case FElementDef.ContentType of

      ctEmpty: Result := False;

      ctChildren, ctMixed: begin
        if FFailed then     // if already detected a mismatch, don't waste time
          Exit;
        if FCurCP = nil then
          Next := FElementDef.RootCP.FindFirst(Def)
        else
          Next := FCurCP.FindNext(Def, 0); { second arg ignored here }
        Result := Assigned(Next);
        if Result then
          FCurCP := Next
        else
          FFailed := True;  // used to prevent extra error at the end of element
      end;
      // ctAny, ctUndeclared: returns True by default
    end;
  end;
end;

function TElementValidator.Incomplete: Boolean;
begin
  if Assigned(FElementDef) and (FElementDef.ContentType = ctChildren) and (not FFailed) then
  begin
    if FCurCP <> nil then
      Result := FCurCP.MoreRequired(0) { arg ignored here }
    else
      Result := FElementDef.RootCP.IsRequired;
  end
  else
    Result := False;
end;

end.
