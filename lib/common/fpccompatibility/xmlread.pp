{
    This file is part of the Free Component Library

    XML reading routines.
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org
    Modified in 2006 by Sergei Gorelkin, sergei_gorelkin@mail.ru

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit XMLRead;

{$ifdef fpc}
{$MODE objfpc}{$H+}
{$endif}

interface

uses
  SysUtils, Classes, mclasses, DOM, xmlutils, xmlreader, xmltextreader;

type
  TErrorSeverity = xmlreader.TErrorSeverity;
  EXMLReadError = xmlreader.EXMLReadError;
  TXMLInputSource = xmlreader.TXMLInputSource;

const
  esWarning = xmlreader.esWarning;
  esError = xmlreader.esError;
  esFatal = xmlreader.esFatal;

procedure ReadXMLFile(out ADoc: TXMLDocument; const AFilename: String); overload;
procedure ReadXMLFile(out ADoc: TXMLDocument; var f: Text); overload;
procedure ReadXMLFile(out ADoc: TXMLDocument; f: TStream); overload;
procedure ReadXMLFile(out ADoc: TXMLDocument; f: TStream; const ABaseURI: String); overload;

procedure ReadXMLFragment(AParentNode: TDOMNode; const AFilename: String); overload;
procedure ReadXMLFragment(AParentNode: TDOMNode; var f: Text); overload;
procedure ReadXMLFragment(AParentNode: TDOMNode; f: TStream); overload;
procedure ReadXMLFragment(AParentNode: TDOMNode; f: TStream; const ABaseURI: String); overload;

procedure ReadDTDFile(out ADoc: TXMLDocument; const AFilename: String);  overload;
procedure ReadDTDFile(out ADoc: TXMLDocument; var f: Text); overload;
procedure ReadDTDFile(out ADoc: TXMLDocument; f: TStream); overload;
procedure ReadDTDFile(out ADoc: TXMLDocument; f: TStream; const ABaseURI: String); overload;

type
  TXMLErrorEvent = xmlreader.TXMLErrorEvent;
  TDOMParseOptions = xmlreader.TXMLReaderSettings;

  // NOTE: DOM 3 LS ACTION_TYPE enumeration starts at 1
  TXMLContextAction = (
    xaAppendAsChildren = 1,
    xaReplaceChildren,
    xaInsertBefore,
    xaInsertAfter,
    xaReplace);

  TDOMParser = class(TObject)
  private
    FOptions: TDOMParseOptions;
    function GetOnError: TXMLErrorEvent;
    procedure SetOnError(value: TXMLErrorEvent);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(Src: TXMLInputSource; out ADoc: TXMLDocument);
    procedure ParseUri(const URI: XMLString; out ADoc: TXMLDocument);
    function ParseWithContext(Src: TXMLInputSource; Context: TDOMNode;
      Action: TXMLContextAction): TDOMNode;
    property Options: TDOMParseOptions read FOptions;
    property OnError: TXMLErrorEvent read GetOnError write SetOnError;
  end;

  TDecoder = xmltextreader.TDecoder;
  TGetDecoderProc = xmltextreader.TGetDecoderProc;

procedure RegisterDecoder(Proc: TGetDecoderProc);

// =======================================================

implementation

uses
  UriParser, dtdmodel;

type
  TLoader = object
    doc: TDOMDocument;
    reader: TXMLTextReader;
    function CreateCDATANode(currnode: PNodeData): TDOMNode;
    function CreatePINode(currnode: PNodeData): TDOMNode;
    procedure ParseContent(cursor: TDOMNode_WithChildren);

    procedure ProcessXML(ADoc: TDOMDocument; AReader: TXMLTextReader);
    procedure ProcessFragment(AOwner: TDOMNode; AReader: TXMLTextReader);
    procedure ProcessDTD(ADoc: TDOMDocument; AReader: TXMLTextReader);
    procedure ProcessEntity(Sender: TXMLTextReader; AEntity: TEntityDecl);
  end;

procedure RegisterDecoder(Proc: TGetDecoderProc);
begin
  xmltextreader.RegisterDecoder(Proc);
end;

{ TDOMParser }

constructor TDOMParser.Create;
begin
  FOptions := TDOMParseOptions.Create;
end;

destructor TDOMParser.Destroy;
begin
  FOptions.Free;
  inherited Destroy;
end;

function TDOMParser.GetOnError: TXMLErrorEvent;
begin
  result := Options.OnError;
end;

procedure TDOMParser.SetOnError(value: TXMLErrorEvent);
begin
  Options.OnError := value;
end;

procedure TDOMParser.Parse(Src: TXMLInputSource; out ADoc: TXMLDocument);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  ADoc := TXMLDocument.Create;
  Options.NameTable := ADoc.Names;
  Reader := TXMLTextReader.Create(Src, Options);
  try
    ldr.ProcessXML(ADoc, Reader);
  finally
    Reader.Free;
  end;
end;

procedure TDOMParser.ParseUri(const URI: XMLString; out ADoc: TXMLDocument);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  ADoc := TXMLDocument.Create;
  Options.NameTable := ADoc.Names;
  Reader := TXMLTextReader.Create(URI, Options);
  try
    ldr.ProcessXML(ADoc, Reader)
  finally
    Reader.Free;
  end;
end;

function TDOMParser.ParseWithContext(Src: TXMLInputSource;
  Context: TDOMNode; Action: TXMLContextAction): TDOMNode;
var
  Frag: TDOMDocumentFragment;
  node: TDOMNode;
  reader: TXMLTextReader;
  ldr: TLoader;
  doc: TDOMDocument;
begin
  if Action in [xaInsertBefore, xaInsertAfter, xaReplace] then
    node := Context.ParentNode
  else
    node := Context;
  // TODO: replacing document isn't yet supported
  if (Action = xaReplaceChildren) and (node.NodeType = DOCUMENT_NODE) then
    raise EDOMNotSupported.Create('DOMParser.ParseWithContext');

  if not (node.NodeType in [ELEMENT_NODE, DOCUMENT_FRAGMENT_NODE]) then
    raise EDOMHierarchyRequest.Create('DOMParser.ParseWithContext');

  if Context.NodeType = DOCUMENT_NODE then
    doc := TDOMDocument(Context)
  else
    doc := Context.OwnerDocument;

  Options.NameTable := doc.Names;
  reader := TXMLTextReader.Create(Src, Options);
  try
    Frag := doc.CreateDocumentFragment;
    try
      ldr.ProcessFragment(Frag, reader);
      Result := Frag.FirstChild;
      case Action of
        xaAppendAsChildren: Context.AppendChild(Frag);

        xaReplaceChildren: begin
          Context.TextContent := '';     // removes children
          Context.ReplaceChild(Frag, Context.FirstChild);
        end;
        xaInsertBefore: node.InsertBefore(Frag, Context);
        xaInsertAfter:  node.InsertBefore(Frag, Context.NextSibling);
        xaReplace:      node.ReplaceChild(Frag, Context);
      end;
    finally
      Frag.Free;
    end;
  finally
    reader.Free;
  end;
end;

procedure TLoader.ProcessXML(ADoc: TDOMDocument; AReader: TXMLTextReader);
begin
  doc := ADoc;
  reader := AReader;
  reader.OnEntity := @ProcessEntity;
  doc.documentURI := reader.BaseURI;
  reader.FragmentMode := False;
  ParseContent(doc);
  doc.XMLStandalone := reader.Standalone;

  if reader.Validate then
    reader.ValidateIdRefs;

  doc.IDs := reader.IDMap;
  reader.IDMap := nil;
end;

procedure TLoader.ProcessFragment(AOwner: TDOMNode; AReader: TXMLTextReader);
var
  DoctypeNode: TDOMDocumentType;
begin
  doc := AOwner.OwnerDocument;
  reader := AReader;
  reader.OnEntity := @ProcessEntity;
  reader.FragmentMode := True;
  reader.XML11 := doc.XMLVersion = '1.1';
  DoctypeNode := doc.DocType;
  if Assigned(DoctypeNode) then
    reader.DtdSchemaInfo := DocTypeNode.Model.Reference;
  ParseContent(aOwner as TDOMNode_WithChildren);
end;

procedure TLoader.ProcessEntity(Sender: TXMLTextReader; AEntity: TEntityDecl);
var
  DoctypeNode: TDOMDocumentType;
  Ent: TDOMEntity;
  src: TXMLCharSource;
  InnerReader: TXMLTextReader;
  InnerLoader: TLoader;
begin
  DoctypeNode := TDOMDocument(doc).DocType;
  if DoctypeNode = nil then
    Exit;
  Ent := TDOMEntity(DocTypeNode.Entities.GetNamedItem(AEntity.FName));
  if Ent = nil then
    Exit;
  Sender.EntityToSource(AEntity, Src);
  if Src = nil then
    Exit;
  InnerReader := TXMLTextReader.Create(Src, Sender);
  try
    Ent.SetReadOnly(False);
    InnerLoader.ProcessFragment(Ent, InnerReader);
    AEntity.FResolved := True;
  finally
    InnerReader.Free;
    AEntity.FOnStack := False;
    Ent.SetReadOnly(True);
  end;
end;

procedure TLoader.ParseContent(cursor: TDOMNode_WithChildren);
var
  element: TDOMElement;
  currnodeptr: PPNodeData;
  currnode: PNodeData;
begin
  currnodeptr := (reader as IGetNodeDataPtr).CurrentNodePtr;
  if reader.ReadState = rsInitial then
  begin
    if not reader.Read then
      Exit;
    case cursor.NodeType of
      DOCUMENT_NODE, ENTITY_NODE:
        (cursor as TDOMNode_TopLevel).SetHeaderData(reader.XMLVersion,reader.XMLEncoding);
    end;
  end;

  with reader do
  repeat
    if Validate then
      ValidateCurrentNode;

    currnode := currnodeptr^;
    case currnode^.FNodeType of
      ntText:
        cursor.InternalAppend(doc.CreateTextNodeBuf(currnode^.FValueStart, currnode^.FValueLength, False));

      ntWhitespace, ntSignificantWhitespace:
        if PreserveWhitespace then
          cursor.InternalAppend(doc.CreateTextNodeBuf(currnode^.FValueStart, currnode^.FValueLength, currnode^.FNodeType = ntWhitespace));

      ntCDATA:
        cursor.InternalAppend(CreateCDATANode(currnode));

      ntProcessingInstruction:
        cursor.InternalAppend(CreatePINode(currnode));

      ntComment:
        if not IgnoreComments then
          cursor.InternalAppend(doc.CreateCommentBuf(currnode^.FValueStart, currnode^.FValueLength));

      ntElement:
        begin
          element := LoadElement(doc, currnode, reader.AttributeCount);
          cursor.InternalAppend(element);
          cursor := element;
        end;

      ntEndElement:
          cursor := TDOMNode_WithChildren(cursor.ParentNode);

      ntDocumentType:
        cursor.InternalAppend(TDOMDocumentType.Create(doc, DtdSchemaInfo));

      ntEntityReference:
        begin
          cursor.InternalAppend(doc.CreateEntityReference(currnode^.FQName^.Key));
          { Seeing an entity reference while expanding means that the entity
            fails to expand. }
          if not ExpandEntities then
          begin
            { Make reader iterate through contents of the reference,
              to ensure correct validation events and character counts. }
            ResolveEntity;
            while currnodeptr^^.FNodeType <> ntEndEntity do
              Read;
          end;
        end;
    end;
  until not Read;
end;

function TLoader.CreatePINode(currnode: PNodeData): TDOMNode;
var
  s: DOMString;
begin
  SetString(s, currnode^.FValueStart, currnode^.FValueLength);
  result := Doc.CreateProcessingInstruction(currnode^.FQName^.Key, s);
end;

function TLoader.CreateCDATANode(currnode: PNodeData): TDOMNode;
var
  s: XMLString;
begin
  SetString(s, currnode^.FValueStart, currnode^.FValueLength);
  result := doc.CreateCDATASection(s);
end;



procedure TLoader.ProcessDTD(ADoc: TDOMDocument; AReader: TXMLTextReader);
begin
  AReader.DtdSchemaInfo := TDTDModel.Create(AReader.NameTable);
  // TODO: DTD labeled version 1.1 will be rejected - must set FXML11 flag
  doc.AppendChild(TDOMDocumentType.Create(doc, AReader.DtdSchemaInfo));
  AReader.ParseDTD;
end;

{ plain calls }

procedure ReadXMLFile(out ADoc: TXMLDocument; var f: Text);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  ADoc := TXMLDocument.Create;
  Reader := TXMLTextReader.Create(f, ADoc.Names);
  try
    ldr.ProcessXML(ADoc,Reader);
  finally
    Reader.Free;
  end;
end;

procedure ReadXMLFile(out ADoc: TXMLDocument; f: TStream; const ABaseURI: String);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  ADoc := TXMLDocument.Create;
  Reader := TXMLTextReader.Create(f, ABaseURI, ADoc.Names);
  try
    ldr.ProcessXML(ADoc, Reader);
  finally
    Reader.Free;
  end;
end;

procedure ReadXMLFile(out ADoc: TXMLDocument; f: TStream);
begin
  ReadXMLFile(ADoc, f, 'stream:');
end;

procedure ReadXMLFile(out ADoc: TXMLDocument; const AFilename: String);
var
  FileStream: TStream;
begin
  ADoc := nil;
  FileStream := TFileStream.Create(AFilename, fmOpenRead+fmShareDenyWrite);
  try
    ReadXMLFile(ADoc, FileStream, FilenameToURI(AFilename));
  finally
    FileStream.Free;
  end;
end;

procedure ReadXMLFragment(AParentNode: TDOMNode; var f: Text);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  Reader := TXMLTextReader.Create(f, AParentNode.OwnerDocument.Names);
  try
    ldr.ProcessFragment(AParentNode, Reader);
  finally
    Reader.Free;
  end;
end;

procedure ReadXMLFragment(AParentNode: TDOMNode; f: TStream; const ABaseURI: String);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  Reader := TXMLTextReader.Create(f, ABaseURI, AParentNode.OwnerDocument.Names);
  try
    ldr.ProcessFragment(AParentNode, Reader);
  finally
    Reader.Free;
  end;
end;

procedure ReadXMLFragment(AParentNode: TDOMNode; f: TStream);
begin
  ReadXMLFragment(AParentNode, f, 'stream:');
end;

procedure ReadXMLFragment(AParentNode: TDOMNode; const AFilename: String);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFilename, fmOpenRead+fmShareDenyWrite);
  try
    ReadXMLFragment(AParentNode, Stream, FilenameToURI(AFilename));
  finally
    Stream.Free;
  end;
end;


procedure ReadDTDFile(out ADoc: TXMLDocument; var f: Text);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  ADoc := TXMLDocument.Create;
  Reader := TXMLTextReader.Create(f, ADoc.Names);
  try
    ldr.ProcessDTD(ADoc,Reader);
  finally
    Reader.Free;
  end;
end;

procedure ReadDTDFile(out ADoc: TXMLDocument; f: TStream; const ABaseURI: String);
var
  Reader: TXMLTextReader;
  ldr: TLoader;
begin
  ADoc := TXMLDocument.Create;
  Reader := TXMLTextReader.Create(f, ABaseURI, ADoc.Names);
  try
    ldr.ProcessDTD(ADoc,Reader);
  finally
    Reader.Free;
  end;
end;

procedure ReadDTDFile(out ADoc: TXMLDocument; f: TStream);
begin
  ReadDTDFile(ADoc, f, 'stream:');
end;

procedure ReadDTDFile(out ADoc: TXMLDocument; const AFilename: String);
var
  Stream: TStream;
begin
  ADoc := nil;
  Stream := TFileStream.Create(AFilename, fmOpenRead+fmShareDenyWrite);
  try
    ReadDTDFile(ADoc, Stream, FilenameToURI(AFilename));
  finally
    Stream.Free;
  end;
end;




end.
