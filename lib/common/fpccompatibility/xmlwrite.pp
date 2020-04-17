{
    This file is part of the Free Component Library

    XML writing routines
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org
    Modified in 2006 by Sergei Gorelkin, sergei_gorelkin@mail.ru

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


unit XMLWrite;

{$ifdef fpc}{$MODE objfpc}{$endif}
{$H+}

interface

uses Classes, mclasses, DOM, xmlutils;

Type
  TXMLWriter = Class;
  TSpecialCharCallback = procedure(Sender: TXMLWriter; const s: DOMString; var idx: Integer);

  TNodeInfo = record
    Name: XMLString;
  end;

  TNodeInfoArray = array of TNodeInfo;

  { TXMLWriter }

  TXMLWriter = class(TObject)
  private
    FIndentSize: Integer;
    FStream: TStream;
    FInsideTextNode: Boolean;
    FCanonical: Boolean;
    FIndent: XMLString;
    FNesting: Integer;
    FBuffer: PChar;
    FBufPos: PChar;
    FCapacity: Integer;
    FLineBreak: XMLString;
    FNSHelper: TNSSupport;
    FAttrFixups: TFPList;
    FScratch: TFPList;
    FNSDefs: TFPList;
    FNodes: TNodeInfoArray;
    FUseTab: Boolean;
    procedure SetCanonical(AValue: Boolean);
    procedure SetIndentSize(AValue: Integer);
    procedure SetLineBreak(AValue: XMLString);
    procedure SetUseTab(AValue: Boolean);
    procedure wrtChars(Src: PWideChar; Length: Integer);
    procedure IncNesting;
    procedure DecNesting; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure wrtStr(const ws: XMLString); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure wrtChr(c: WideChar); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure wrtIndent(EndElement: Boolean = False);
    procedure wrtQuotedLiteral(const ws: XMLString);
    procedure ConvWrite(const s: XMLString; const SpecialChars: TSetOfChar; const SpecialCharCallback: TSpecialCharCallback);
    procedure WriteNSDef(B: TBinding);
  protected
    Procedure InitIndentLineBreak;
    // Canonical does not yet quite work
    Property Canonical : Boolean Read FCanonical Write SetCanonical;
  public
    constructor Create(AStream: TStream; ANameTable: THashTable);
    destructor Destroy; override;
    procedure WriteXMLDecl(const aVersion, aEncoding: XMLString;   aStandalone: Integer); virtual;
    procedure WriteStartElement(const Name: XMLString); virtual;
    procedure WriteEndElement(shortForm: Boolean); virtual;
    procedure WriteProcessingInstruction(const Target, Data: XMLString); virtual;
    procedure WriteEntityRef(const Name: XMLString); virtual;
    procedure WriteAttributeString(const Name, Value: XMLString); virtual;
    procedure WriteDocType(const Name, PubId, SysId, Subset: XMLString); virtual;
    procedure WriteString(const Text: XMLString); virtual;
    procedure WriteCDATA(const Text: XMLString); virtual;
    procedure WriteComment(const Text: XMLString); virtual;
    // Only set these before writing !
    // Use tab character instead of space.
    Property UseTab : Boolean Read FUseTab Write SetUseTab;
    // Indent size in number of characters
    Property IndentSize : Integer Read FIndentSize Write SetIndentSize;
    // Default is system setting. Ignored when Canonical = True.
    Property LineBreak : XMLString Read FLineBreak Write SetLineBreak;
  end;

  { TDOMWriter }

  TDOMWriter = class(TXMLWriter)
  Protected
    procedure NamespaceFixup(Element: TDOMElement);
    procedure VisitDocument(Node: TDOMNode);
    procedure VisitDocument_Canonical(Node: TDOMNode);
    procedure VisitElement(Node: TDOMNode);
    procedure VisitFragment(Node: TDOMNode);
    procedure VisitAttribute(Node: TDOMNode);
    procedure VisitEntityRef(Node: TDOMNode);
    procedure VisitDocumentType(Node: TDOMNode);
    procedure VisitPI(Node: TDOMNode);
  Public
    constructor Create(AStream: TStream; aNode : TDOMNode);
    procedure WriteNode(Node: TDOMNode);
  end;


procedure WriteXMLFile(doc: TXMLDocument; const AFileName: String); overload;
procedure WriteXMLFile(doc: TXMLDocument; var AFile: Text); overload;
procedure WriteXMLFile(doc: TXMLDocument; AStream: TStream); overload;

procedure WriteXML(Element: TDOMNode; const AFileName: String); overload;
procedure WriteXML(Element: TDOMNode; var AFile: Text); overload;
procedure WriteXML(Element: TDOMNode; AStream: TStream); overload;

// ===================================================================

implementation

uses SysUtils;

type
  PAttrFixup = ^TAttrFixup;
  TAttrFixup = record
    Attr: TDOMNode;
    Prefix: PHashItem;
  end;

  TTextStream = class(TStream)
  Private
    F : ^Text;
  Public
    constructor Create(var AFile: Text);
    function Write(Const Buffer; Count: Longint): Longint; override;
  end;

{ ---------------------------------------------------------------------
    TTextStream
  ---------------------------------------------------------------------}


constructor TTextStream.Create(var AFile: Text);
begin
  inherited Create;
  f := @AFile;
end;

function TTextStream.Write(const Buffer; Count: Longint): Longint;
var
  s: string;
begin
  if Count>0 then
  begin
    SetString(s, PChar(@Buffer), Count);
    system.Write(f^, s);
  end;
  Result := Count;
end;

{ ---------------------------------------------------------------------
    Auxiliary routines
  ---------------------------------------------------------------------}

const
  AttrSpecialChars = ['<', '>', '"', '&', #0..#$1F];
  TextSpecialChars = ['<', '>', '&', #0..#8, #10..#$1F];
  CDSectSpecialChars = [#0..#8, #11, #12, #14..#$1F, ']'];
  LineEndingChars = [#13, #10];
  QuotStr = '&quot;';
  AmpStr = '&amp;';
  ltStr = '&lt;';
  gtStr = '&gt;';
  IndentChars : Array[Boolean] of char = (' ',#9);

procedure AttrSpecialCharCallback(Sender: TXMLWriter; const s: DOMString;
  var idx: Integer);
begin
  case s[idx] of
    '"': Sender.wrtStr(QuotStr);
    '&': Sender.wrtStr(AmpStr);
    '<': Sender.wrtStr(ltStr);
    // This is *only* to interoperate with broken parsers out there,
    // Delphi ClientDataset parser being one of them.
    '>': if not Sender.FCanonical then
           Sender.wrtStr(gtStr)
         else
           Sender.wrtChr('>');
    // Escape whitespace using CharRefs to be consistent with W3 spec ? 3.3.3
    #9: Sender.wrtStr('&#x9;');
    #10: Sender.wrtStr('&#xA;');
    #13: Sender.wrtStr('&#xD;');
  else
    raise EConvertError.Create('Illegal character');
  end;
end;

procedure TextnodeNormalCallback(Sender: TXMLWriter; const s: DOMString;
  var idx: Integer);
begin
  case s[idx] of
    '<': Sender.wrtStr(ltStr);
    '>': Sender.wrtStr(gtStr); // Required only in ']]>' literal, otherwise optional
    '&': Sender.wrtStr(AmpStr);
    #13:
      begin
        // We normalize #13#10 and #13 to FLineBreak, going somewhat
        // beyond the specs here, see issue #13879.
        Sender.wrtStr(Sender.FLineBreak);
        if (idx < Length(s)) and (s[idx+1] = #10) then
          Inc(idx);
      end;
    #10: Sender.wrtStr(Sender.FLineBreak);
  else
    raise EConvertError.Create('Illegal character');
  end;
end;

procedure TextnodeCanonicalCallback(Sender: TXMLWriter; const s: DOMString;
  var idx: Integer);
begin
  case s[idx] of
    '<': Sender.wrtStr(ltStr);
    '>': Sender.wrtStr(gtStr);
    '&': Sender.wrtStr(AmpStr);
    #13: Sender.wrtStr('&#xD;');
    #10: Sender.wrtChr(#10);
  else
    raise EConvertError.Create('Illegal character');
  end;
end;

procedure CDSectSpecialCharCallback(Sender: TXMLWriter; const s: DOMString;
  var idx: Integer);
begin
  if s[idx]=']' then
  begin
    if (idx <= Length(s)-2) and (s[idx+1] = ']') and (s[idx+2] = '>') then
    begin
      Sender.wrtStr(']]]]><![CDATA[>');
      Inc(idx, 2);
      // TODO: emit warning 'cdata-section-splitted'
    end
    else
      Sender.wrtChr(']');
  end  
  else
    raise EConvertError.Create('Illegal character');
end;

// clone of system.FPC_WIDESTR_COMPARE which cannot be called directly
function Compare(const s1, s2: DOMString): integer;
var
  maxi, temp: integer;
begin
  Result := 0;
  if pointer(S1) = pointer(S2) then
    exit;
  maxi := Length(S1);
  temp := Length(S2);
  if maxi > temp then
    maxi := temp;
  Result := CompareWord(S1[1], S2[1], maxi);
  if Result = 0 then
    Result := Length(S1)-Length(S2);
end;

function SortNSDefs(Item1, Item2: Pointer): Integer;
begin
  Result := Compare(TBinding(Item1).Prefix^.Key, TBinding(Item2).Prefix^.Key);
end;

function SortAtts(Item1, Item2: Pointer): Integer;
var
  p1: PAttrFixup absolute Item1;
  p2: PAttrFixup absolute Item2;
begin
  Result := Compare(p1^.Attr.namespaceURI, p2^.Attr.namespaceURI);
  if Result = 0 then
    Result := Compare(p1^.Attr.localName, p2^.Attr.localName);
end;

const
  TextnodeCallbacks: array[boolean] of TSpecialCharCallback = (
    @TextnodeNormalCallback,
    @TextnodeCanonicalCallback
  );

{ ---------------------------------------------------------------------
    TXMLWriter
  ---------------------------------------------------------------------}


constructor TXMLWriter.Create(AStream: TStream; ANameTable: THashTable);

begin
  inherited Create;
  FStream := AStream;
  // some overhead - always be able to write at least one extra UCS4
  FBuffer := AllocMem(512+32);
  FBufPos := FBuffer;
  FCapacity := 512;
  FCanonical:=False;
  FIndentSize:=2;
  FUseTab:=False;
  FLineBreak := sLineBreak;
  InitIndentLineBreak;
  FNesting := 0;
  SetLength(FNodes, 16);
  FNSHelper := TNSSupport.Create(ANameTable);
  FScratch := TFPList.Create;
  FNSDefs := TFPList.Create;
  FAttrFixups := TFPList.Create;
end;

destructor TXMLWriter.Destroy;
var
  I: Integer;
begin
  for I := FAttrFixups.Count-1 downto 0 do
    Dispose(PAttrFixup(FAttrFixups.List^[I]));
  FAttrFixups.Free;
  FNSDefs.Free;
  FScratch.Free;
  FNSHelper.Free;
  if FBufPos > FBuffer then
    FStream.write(FBuffer^, FBufPos-FBuffer);

  FreeMem(FBuffer);
  inherited Destroy;
end;

procedure TXMLWriter.wrtChars(Src: PWideChar; Length: Integer);
var
  pb: PChar;
  wc: Cardinal;
  SrcEnd: PWideChar;
begin
  pb := FBufPos;
  SrcEnd := Src + Length;
  while Src < SrcEnd do
  begin
    if pb >= @FBuffer[FCapacity] then
    begin
      FStream.write(FBuffer^, FCapacity);
      Dec(pb, FCapacity);
      if pb > FBuffer then
        Move(FBuffer[FCapacity], FBuffer^, pb - FBuffer);
    end;

    wc := Cardinal(Src^);  Inc(Src);
    case wc of
      0..$7F:  begin
        pb^ := char(wc); Inc(pb);
      end;

      $80..$7FF: begin
        pb^ := Char($C0 or (wc shr 6));
        pb[1] := Char($80 or (wc and $3F));
        Inc(pb,2);
      end;

      $D800..$DBFF: begin
        if (Src < SrcEnd) and (Src^ >= #$DC00) and (Src^ <= #$DFFF) then
        begin
          wc := ((LongInt(wc) - $D7C0) shl 10) + LongInt(word(Src^) xor $DC00);
          Inc(Src);

          pb^ := Char($F0 or (wc shr 18));
          pb[1] := Char($80 or ((wc shr 12) and $3F));
          pb[2] := Char($80 or ((wc shr 6) and $3F));
          pb[3] := Char($80 or (wc and $3F));
          Inc(pb,4);
        end
        else
          raise EConvertError.Create('High surrogate without low one');
      end;
      $DC00..$DFFF:
        raise EConvertError.Create('Low surrogate without high one');
      else   // $800 >= wc > $FFFF, excluding surrogates
      begin
        pb^ := Char($E0 or (wc shr 12));
        pb[1] := Char($80 or ((wc shr 6) and $3F));
        pb[2] := Char($80 or (wc and $3F));
        Inc(pb,3);
      end;
    end;
  end;
  FBufPos := pb;
end;

procedure TXMLWriter.wrtStr(const ws: XMLString); { inline }
begin
  wrtChars(PWideChar(ws), Length(ws));
end;

{ No checks here - buffer always has 32 extra bytes }
procedure TXMLWriter.wrtChr(c: WideChar); { inline }
begin
  FBufPos^ := char(ord(c));
  Inc(FBufPos);
end;

procedure TXMLWriter.wrtIndent(EndElement: Boolean);

Var
  L : integer;

begin
  L:=(FNesting-ord(EndElement))*IndentSize+Length(FLineBreak);
  if (L>0) then
    wrtChars(PWideChar(FIndent), L);
end;

procedure TXMLWriter.IncNesting;
var
  I, NewLen, OldLen: Integer;
begin
  Inc(FNesting);
  if FNesting >= Length(FNodes) then
    SetLength(FNodes, FNesting+8);
  if (Length(FIndent)-Length(FLineBreak)) < IndentSize * FNesting then
    begin
    OldLen := Length(FIndent);
    NewLen := (IndentSize*2) * FNesting;
    SetLength(FIndent, NewLen);
    for I := OldLen to NewLen do
      FIndent[I] := IndentChars[UseTab];
    end;
end;

procedure TXMLWriter.DecNesting; { inline }
begin
  if FNesting>0 then dec(FNesting);
end;

procedure TXMLWriter.ConvWrite(const s: XMLString; const SpecialChars: TSetOfChar;
  const SpecialCharCallback: TSpecialCharCallback);
var
  StartPos, EndPos: Integer;
begin
  StartPos := 1;
  EndPos := 1;
  while EndPos <= Length(s) do
  begin
    if (s[EndPos] < #128) and (Char(ord(s[EndPos])) in SpecialChars) then
    begin
      wrtChars(@s[StartPos], EndPos - StartPos);
      SpecialCharCallback(Self, s, EndPos);
      StartPos := EndPos + 1;
    end;
    Inc(EndPos);
  end;
  if StartPos <= length(s) then
    wrtChars(@s[StartPos], EndPos - StartPos);
end;


procedure TXMLWriter.wrtQuotedLiteral(const ws: XMLString);
var
  Quote: WideChar;
begin
  // TODO: need to check if the string also contains single quote
  // both quotes present is a error
  if Pos('"', ws) > 0 then
    Quote := ''''
  else
    Quote := '"';
  wrtChr(Quote);
  ConvWrite(ws, LineEndingChars, @TextnodeNormalCallback);
  wrtChr(Quote);
end;


procedure TXMLWriter.WriteNSDef(B: TBinding);
begin
  wrtChars(' xmlns', 6);
  if B.Prefix^.Key <> '' then
  begin
    wrtChr(':');
    wrtStr(B.Prefix^.Key);
  end;
  wrtChars('="', 2);
  if Assigned(B.uri) then
    ConvWrite(B.uri^.Key, AttrSpecialChars, @AttrSpecialCharCallback);
  wrtChr('"');
end;


procedure TXMLWriter.InitIndentLineBreak;

Var
  I : Integer;

begin
  if FCanonical then
    FLineBreak := #10;
  // Initialize Indent string
  SetLength(FIndent, 100);
  I:=1;
  While I<=Length(FLineBreak) do
    begin
    FIndent[I] := FLineBreak[I];
    Inc(I);
    end;
  While I<=Length(Findent) do
    begin
    FIndent[I]:=IndentChars[UseTab];
    Inc(I);
    end;
end;


procedure TXMLWriter.WriteStartElement(const Name: XMLString);
begin
  if not FInsideTextNode then
    wrtIndent;

  FNSHelper.PushScope;
  IncNesting;
  wrtChr('<');
  wrtStr(Name);
  FNodes[FNesting].Name := Name;
end;

procedure TXMLWriter.WriteEndElement(shortForm: Boolean);
begin
  if shortForm then
    wrtChars('/>', 2)
  else
  begin
    wrtChars('</', 2);
    wrtStr(FNodes[FNesting].Name);
    wrtChr('>');
  end;
  DecNesting;
  FNSHelper.PopScope;
end;

procedure TXMLWriter.WriteString(const Text: XMLString);
begin
  ConvWrite(Text, TextSpecialChars, TextnodeCallbacks[FCanonical]);
end;

procedure TXMLWriter.WriteCDATA(const Text: XMLString);
begin
  if not FInsideTextNode then
    wrtIndent;
  if FCanonical then
    ConvWrite(Text, TextSpecialChars, @TextnodeCanonicalCallback)
  else
  begin
    wrtChars('<![CDATA[', 9);
    ConvWrite(Text, CDSectSpecialChars, @CDSectSpecialCharCallback);
    wrtChars(']]>', 3);
  end;
end;

procedure TXMLWriter.WriteEntityRef(const Name: XMLString);
begin
  wrtChr('&');
  wrtStr(Name);
  wrtChr(';');
end;


procedure TXMLWriter.WriteProcessingInstruction(const Target, Data: XMLString);
begin
  if not FInsideTextNode then wrtIndent;
  wrtStr('<?');
  wrtStr(Target);
  if Data <> '' then
  begin
    wrtChr(' ');
    // TODO: How does this comply with c14n??
    ConvWrite(Data, LineEndingChars, @TextnodeNormalCallback);
  end;
  wrtStr('?>');
end;


procedure TXMLWriter.WriteComment(const Text: XMLString);
begin
  if not FInsideTextNode then wrtIndent;
  wrtChars('<!--', 4);
  // TODO: How does this comply with c14n??
  ConvWrite(Text, LineEndingChars, @TextnodeNormalCallback);
  wrtChars('-->', 3);
end;

procedure TXMLWriter.WriteXMLDecl(const aVersion, aEncoding: XMLString; aStandalone: Integer);
begin
  wrtStr('<?xml version="');
  if aVersion <> '' then
    wrtStr(aVersion)
  else
    wrtStr('1.0');
  wrtChr('"');

  wrtStr(' encoding="');
  wrtStr(aEncoding);
  wrtChr('"');

  if aStandalone >= 0 then
  begin
    wrtStr(' standalone="');
    if aStandalone > 0 then
      wrtStr('yes')
    else
      wrtStr('no');
    wrtChr('"');
  end;

  wrtStr('?>');
end;

procedure TXMLWriter.SetCanonical(AValue: Boolean);
begin
  if FCanonical=AValue then Exit;
  FCanonical:=AValue;
  InitIndentLineBreak;
end;

procedure TXMLWriter.SetIndentSize(AValue: Integer);
begin
  if FIndentSize=AValue then Exit;
  FIndentSize:=AValue;
  InitIndentLineBreak;
end;

procedure TXMLWriter.SetLineBreak(AValue: XMLString);
begin
  if FLineBreak=AValue then Exit;
  FLineBreak:=AValue;
  InitIndentLineBreak;
end;

procedure TXMLWriter.SetUseTab(AValue: Boolean);
begin
  if FUseTab=AValue then Exit;
  FUseTab:=AValue;
  InitIndentLineBreak;
end;

{ ---------------------------------------------------------------------
  TDOMWriter
  ---------------------------------------------------------------------}

procedure TDOMWriter.WriteNode(node: TDOMNode);
begin
  case node.NodeType of
    ELEMENT_NODE:                VisitElement(node);
    ATTRIBUTE_NODE:              VisitAttribute(node);
    TEXT_NODE:                   WriteString(TDOMCharacterData(node).Data);
    CDATA_SECTION_NODE:          WriteCDATA(TDOMCharacterData(node).Data);
    ENTITY_REFERENCE_NODE:       VisitEntityRef(node);
    PROCESSING_INSTRUCTION_NODE: VisitPI(node);
    COMMENT_NODE:                WriteComment(TDOMCharacterData(node).Data);
    DOCUMENT_NODE:
      if FCanonical then
        VisitDocument_Canonical(node)
      else
        VisitDocument(node);
    DOCUMENT_TYPE_NODE:          VisitDocumentType(node);
    ENTITY_NODE,
    DOCUMENT_FRAGMENT_NODE:      VisitFragment(node);
  end;
end;

procedure TDOMWriter.VisitElement(node: TDOMNode);
var
  i: Integer;
  child: TDOMNode;
  SavedInsideTextNode: Boolean;
begin
  WriteStartElement(TDOMElement(node).TagName);

  if nfLevel2 in node.Flags then
    NamespaceFixup(TDOMElement(node))
  else if node.HasAttributes then
    for i := 0 to node.Attributes.Length - 1 do
    begin
      child := node.Attributes.Item[i];
      if FCanonical or TDOMAttr(child).Specified then
        VisitAttribute(child);
    end;
  Child := node.FirstChild;
  if Child = nil then
    WriteEndElement(True)
  else
  begin
    // TODO: presence of zero-length textnodes triggers the indenting logic,
    // while they should be ignored altogeter.
    SavedInsideTextNode := FInsideTextNode;
    wrtChr('>');
    FInsideTextNode := FCanonical or (Child.NodeType in [TEXT_NODE, CDATA_SECTION_NODE]);
    repeat
      WriteNode(Child);
      Child := Child.NextSibling;
    until Child = nil;
    if not (node.LastChild.NodeType in [TEXT_NODE, CDATA_SECTION_NODE]) then
      wrtIndent(True);
    FInsideTextNode := SavedInsideTextNode;
    writeEndElement(False);
  end;
end;

procedure TDOMWriter.VisitEntityRef(node: TDOMNode);
begin
  WriteEntityRef(node.NodeName);
end;

procedure TDOMWriter.VisitPI(node: TDOMNode);
begin
  WriteProcessingInstruction(TDOMProcessingInstruction(node).Target, TDOMProcessingInstruction(node).Data);
end;

constructor TDOMWriter.Create(AStream: TStream; aNode: TDOMNode);

var
  doc: TDOMDocument;
begin
  if aNode.NodeType = DOCUMENT_NODE then
    doc := TDOMDocument(aNode)
  else
    doc := aNode.OwnerDocument;
  Inherited Create(aStream,Doc.Names);
end;


procedure TDOMWriter.VisitDocument(node: TDOMNode);
var
  child: TDOMNode;
begin
  // Here we ignore doc.xmlEncoding and write a fixed utf-8 label,
  // because it is the only output encoding currently supported.
  WriteXMLDecl(TXMLDocument(node).XMLVersion, 'utf-8', (ord(TXMLDocument(node).XMLStandalone)-1) or 1);

  // TODO: now handled as a regular PI, remove this?
  if node is TXMLDocument then
  begin
    if Length(TXMLDocument(node).StylesheetType) > 0 then
    begin
      wrtStr(FLineBreak);
      wrtStr('<?xml-stylesheet type="');
      wrtStr(TXMLDocument(node).StylesheetType);
      wrtStr('" href="');
      wrtStr(TXMLDocument(node).StylesheetHRef);
      wrtStr('"?>');
    end;
  end;

  child := node.FirstChild;
  while Assigned(Child) do
  begin
    WriteNode(Child);
    Child := Child.NextSibling;
  end;
  wrtStr(FLineBreak);
end;

procedure TDOMWriter.VisitDocument_Canonical(Node: TDOMNode);
var
  child, root: TDOMNode;
begin
  root := TDOMDocument(Node).DocumentElement;
  child := node.FirstChild;
  while Assigned(child) and (child <> root) do
  begin
    if child.nodeType in [COMMENT_NODE, PROCESSING_INSTRUCTION_NODE] then
    begin
      WriteNode(child);
      wrtChr(#10);
    end;
    child := child.nextSibling;
  end;
  if root = nil then
    Exit;
  VisitElement(TDOMElement(root));
  child := root.nextSibling;
  while Assigned(child) do
  begin
    if child.nodeType in [COMMENT_NODE, PROCESSING_INSTRUCTION_NODE] then
    begin
      wrtChr(#10);
      WriteNode(child);
    end;
    child := child.nextSibling;
  end;
end;

procedure TXMLWriter.WriteAttributeString(const Name, Value: XMLString);
begin
  wrtChr(' ');
  wrtStr(Name);
  wrtChars('="', 2);
  ConvWrite(Value, AttrSpecialChars, {$IFDEF FPC}@{$ENDIF}AttrSpecialCharCallback);
  wrtChr('"');
end;


procedure TXMLWriter.WriteDocType(const Name, PubId, SysId, Subset: XMLString);
begin
  wrtStr(FLineBreak);
  wrtStr('<!DOCTYPE ');
  wrtStr(Name);
  wrtChr(' ');
  if PubId <> '' then
  begin
    wrtStr('PUBLIC ');
    wrtQuotedLiteral(PubId);
    wrtChr(' ');
    wrtQuotedLiteral(SysId);
  end
  else if SysId <> '' then
  begin
    wrtStr('SYSTEM ');
    wrtQuotedLiteral(SysId);
  end;
  if Subset <> '' then
  begin
    wrtChr('[');
    ConvWrite(Subset, LineEndingChars, @TextnodeNormalCallback);
    wrtChr(']');
  end;
  wrtChr('>');
end;

procedure TDOMWriter.VisitFragment(Node: TDOMNode);
var
  Child: TDOMNode;
begin
  // TODO: TextDecl is probably needed
  // Fragment itself should not be written, only its children should...
  Child := Node.FirstChild;
  while Assigned(Child) do
  begin
    WriteNode(Child);
    Child := Child.NextSibling;
  end;
end;

procedure TDOMWriter.VisitAttribute(Node: TDOMNode);
var
  Child: TDOMNode;
begin
  wrtChr(' ');
  wrtStr(TDOMAttr(Node).Name);
  wrtChars('="', 2);
  Child := Node.FirstChild;
  while Assigned(Child) do
  begin
    case Child.NodeType of
      ENTITY_REFERENCE_NODE:
        VisitEntityRef(Child);
      TEXT_NODE:
        ConvWrite(TDOMCharacterData(Child).Data, AttrSpecialChars, @AttrSpecialCharCallback);
    end;
    Child := Child.NextSibling;
  end;
  wrtChr('"');
end;

procedure TDOMWriter.VisitDocumentType(Node: TDOMNode);
begin
  WriteDocType(Node.NodeName, TDOMDocumentType(Node).PublicID, TDOMDocumentType(Node).SystemID,
               TDOMDocumentType(Node).InternalSubset);
end;

procedure TDOMWriter.NamespaceFixup(Element: TDOMElement);
var
  B: TBinding;
  i, j: Integer;
  node: TDOMNode;
  s: DOMString;
  action: TAttributeAction;
  p: PAttrFixup;
begin
  FScratch.Count := 0;
  FNSDefs.Count := 0;
  if Element.hasAttributes then
  begin
    j := 0;
    for i := 0 to Element.Attributes.Length-1 do
    begin
      node := Element.Attributes[i];
      if TDOMNode_NS(node).NSI.NSIndex = 2 then
      begin
        if TDOMNode_NS(node).NSI.PrefixLen = 0 then
          s := ''
        else
          s := node.localName;
        FNSHelper.DefineBinding(s, node.nodeValue, B);
        if Assigned(B) then  // drop redundant namespace declarations
          FNSDefs.Add(B);
      end
      else if FCanonical or TDOMAttr(node).Specified then
      begin
        // obtain a TAttrFixup record (allocate if needed)
        if j >= FAttrFixups.Count then
        begin
          New(p);
          FAttrFixups.Add(p);
        end
        else
          p := PAttrFixup(FAttrFixups.List^[j]);
        // add it to the working list
        p^.Attr := node;
        p^.Prefix := nil;
        FScratch.Add(p);
        Inc(j);
      end;
    end;
  end;

  FNSHelper.DefineBinding(Element.Prefix, Element.namespaceURI, B);
  if Assigned(B) then
    FNSDefs.Add(B);

  for i := 0 to FScratch.Count-1 do
  begin
    node := PAttrFixup(FScratch.List^[i])^.Attr;
    action := FNSHelper.CheckAttribute(node.Prefix, node.namespaceURI, B);
    if action = aaBoth then
      FNSDefs.Add(B);

    if action in [aaPrefix, aaBoth] then
      PAttrFixup(FScratch.List^[i])^.Prefix := B.Prefix;
  end;

  if FCanonical then
  begin
    FNSDefs.Sort(@SortNSDefs);
    FScratch.Sort(@SortAtts);
  end;

  // now, at last, dump all this stuff.
  for i := 0 to FNSDefs.Count-1 do
    WriteNSDef(TBinding(FNSDefs.List^[I]));

  for i := 0 to FScratch.Count-1 do
  begin
    wrtChr(' ');
    with PAttrFixup(FScratch.List^[I])^ do
    begin
      if Assigned(Prefix) then
      begin
        wrtStr(Prefix^.Key);
        wrtChr(':');
        wrtStr(Attr.localName);
      end
      else
        wrtStr(Attr.nodeName);

      wrtChars('="', 2);
      // TODO: not correct w.r.t. entities
      ConvWrite(attr.nodeValue, AttrSpecialChars, @AttrSpecialCharCallback);
      wrtChr('"');
    end;
  end;
end;


// -------------------------------------------------------------------
//   Interface implementation
// -------------------------------------------------------------------

procedure WriteXMLFile(doc: TXMLDocument; const AFileName: String);
begin
  WriteXML(doc, AFileName);
end;

procedure WriteXMLFile(doc: TXMLDocument; var AFile: Text);
begin
  WriteXML(doc, AFile);
end;

procedure WriteXMLFile(doc: TXMLDocument; AStream: TStream);
begin
  WriteXML(doc, AStream);
end;

procedure WriteXML(Element: TDOMNode; const AFileName: String);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(AFileName, fmCreate);
  try
    WriteXML(Element, fs);
  finally
    fs.Free;
  end;
end;

procedure WriteXML(Element: TDOMNode; var AFile: Text);

var
  S : TStream;

begin
  s := TTextStream.Create(AFile);
  try
    WriteXML(Element,S);
  finally
    s.Free;
  end;
end;

procedure WriteXML(Element: TDOMNode; AStream: TStream);

begin
  with TDOMWriter.Create(AStream, Element) do
  try
    WriteNode(Element);
  finally
    Free;
  end;
end;



end.
