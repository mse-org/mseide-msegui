unit dbf_reg;

{===============================================================================
||         TDbf Component         ||         http://tdbf.sf.net               ||
===============================================================================}
(*
  tDBF is supplied "AS IS". The author disclaims all warranties,
  expressed or implied, including, without limitation, the warranties of
  merchantability and or fitness for any purpose. The author assumes no
  liability for damages, direct or consequential, which may result from the
  use of TDBF.

  TDbf is licensed under the LGPL (lesser general public license).

  You are allowed to use this component in any project free of charge.
  You are
  - NOT allowed to claim that you have created this component.  You are
  - NOT allowed to copy this component's code into your own component and
      claim that the code is your idea.

*)

interface

{$I dbf_common.inc}

procedure Register;

implementation

{$ifndef FPC}
{$R dbf.dcr}
{$endif}

uses
  SysUtils,
  Classes,
{$ifdef KYLIX}
  QGraphics,
  QControls,
  QForms,
  QDialogs,
{$else}
  Controls,
  Forms,
  Dialogs,
{$endif}
  dbf,
  dbf_dbffile,
  dbf_idxfile,
  dbf_fields,
  dbf_common,
  dbf_str
{$ifndef FPC}
  ,ExptIntf
{$endif}
{$ifdef DELPHI_6}
  ,DesignIntf,DesignEditors
{$else}
{$ifndef FPC}
  ,DsgnIntf
{$else}
  ,PropEdits
  ,LazarusPackageIntf
  ,LResources
  {,ComponentEditors}
{$endif}
{$endif}
  ;

//==========================================================
//============ DESIGNONLY ==================================
//==========================================================
(*
//==========================================================
//============ TFilePathProperty
//==========================================================
type
  TFilePathProperty = class(TStringProperty)
  public
    function GetValue: string; override;
  end;

function TFilePathProperty.GetValue: string;
begin
  Result := inherited GetValue;
  if Result = EmptyStr then
  begin
    SetValue(ExtractFilePath(ToolServices.GetProjectName));
    Result := inherited GetValue;
  end;
end;
*)

//==========================================================
//============ TTableNameProperty
//==========================================================
type
  TTableNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure TTableNameProperty.Edit; {override;}
var
  FileOpen: TOpenDialog;
  Dbf: TDbf;
begin
  FileOpen := TOpenDialog.Create(Application);
  try
    with fileopen do begin
      Dbf := GetComponent(0) as TDbf;
{$ifndef FPC}
      if Dbf.FilePath = EmptyStr then
        FileOpen.InitialDir := ExtractFilePath(ToolServices.GetProjectName)
      else
{$endif}
        FileOpen.InitialDir := Dbf.AbsolutePath;
      Filename := GetValue;
      Filter := 'Dbf table|*.dbf';
      if Execute then begin
        SetValue(Filename);
      end;
    end;
  finally
    Fileopen.free;
  end;
end;

function TTableNameProperty.GetAttributes: TPropertyAttributes; {override;}
begin
  Result := [paDialog, paRevertable];
end;

//==========================================================
//============ TIndexFileNameProperty
//==========================================================

type
  TIndexFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure TIndexFileNameProperty.Edit; {override;}
var
  FileOpen: TOpenDialog;
  IndexDef: TDbfIndexDef;
  Indexes: TDbfIndexDefs;
  Dbf: TDbf;
begin
  FileOpen := TOpenDialog.Create(Application);
  try
    with fileopen do begin
      IndexDef := GetComponent(0) as TDbfIndexDef;
      Indexes := TDbfIndexDefs(IndexDef.Collection);
      Dbf := TDbf(Indexes.FOwner);
      FileOpen.InitialDir := Dbf.AbsolutePath;
      Filename := GetValue;
      Filter := 'Simple index (ndx)|*.ndx'{|Multiple index (mdx)|*.mdx'};
      if Execute then begin
        SetValue(ExtractFileName(Filename));
      end;
    end;
  finally
    Fileopen.free;
  end;
end;

function TIndexFileNameProperty.GetAttributes: TPropertyAttributes; {override;}
begin
  Result := [paDialog, paRevertable];
end;

//==========================================================
//============ TSortFieldProperty
//==========================================================

type
  TSortFieldProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;


function TSortFieldProperty.GetAttributes: TPropertyAttributes; {override;}
begin
  Result := [paValueList, paSortList, paRevertable];
end;

procedure TSortFieldProperty.GetValues(Proc: TGetStrProc);
var
  IndexDef: TDbfIndexDef;
  Indexes: TDbfIndexDefs;
  Dbf: TDbf;
  I: integer;
begin
  IndexDef := GetComponent(0) as TDbfIndexDef;
  Indexes := TDbfIndexDefs(IndexDef.Collection);
  Dbf :=  TDbf(Indexes.FOwner);
  for I := 0 to Dbf.FieldCount-1 do
  begin
    Proc(Dbf.Fields[i].FieldName);
  end;
end;

//==========================================================
//============ TIndexNameProperty
//==========================================================

type
  TIndexNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
    function GetValue: string; override;
  end;

function TIndexNameProperty.GetAttributes: TPropertyAttributes; {override;}
begin
  Result := [paValueList, paRevertable];
end;

procedure TIndexNameProperty.GetValues(Proc: TGetStrProc);
var
  Dbf: TDbf;
  I: Integer;
begin
  Dbf := GetComponent(0) as TDbf;
  Dbf.UpdateIndexDefs;
  for I := 0 to Dbf.Indexes.Count - 1 do
    Proc(Dbf.Indexes[I].IndexFile);
end;

procedure TIndexNameProperty.SetValue(const Value: string); {override}
var
  Dbf: TDbf;
begin
  Dbf := GetComponent(0) as TDbf;
  Dbf.IndexName := Value;
end;

function TIndexNameProperty.GetValue: string; {override;}
var
  Dbf: TDbf;
begin
  Dbf := GetComponent(0) as TDbf;
  Result := Dbf.IndexName;
end;

//==========================================================
//============ TVersionProperty
//==========================================================
type
  TVersionProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure TVersionProperty.Edit; {override;}
begin
  ShowMessage(
    Format(STRING_VERSION,[TDBF_MAJOR_VERSION, TDBF_MINOR_VERSION]) +
      ' : a dBase component'+#13+
      'for Delphi and c++ builder with no BDE.'+#13+
      #13 +
      'To get the latest version, please visit'+#13+
      'the website: http://www.tdbf.net'+#13+
      'or SourceForge: http://tdbf.sf.net');
end;

function TVersionProperty.GetAttributes: TPropertyAttributes; {override;}
begin
  Result := [paDialog, paReadOnly, paRevertable];
end;

//==========================================================
//============ TNativeFieldTypeProperty
//==========================================================
type
  TNativeFieldTypeProperty = class(TCharProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

procedure TNativeFieldTypeProperty.SetValue(const Value: string);
var
  L: Longint;
begin
  if Length(Value) = 0 then L := 0 else
  if Value[1] = '#' then L := StrToInt(Copy(Value, 2, Maxint))
  else L := Ord(Value[1]);
  SetOrdValue(L);
end;

function TNativeFieldTypeProperty.GetAttributes: TPropertyAttributes; {override;}
begin
  result := [paRevertable,paValueList];
end;

procedure TNativeFieldTypeProperty.GetValues(Proc: TGetStrProc);
begin
  Proc('C Character');
  Proc('N Numeric');
  Proc('D Date');
  Proc('L Logical');
  Proc('M Memo');
  Proc('B Blob');
  Proc('F Float');
  Proc('O Double');
  Proc('I Integer');
  Proc('G Graphic');
  Proc('+ AutoIncrement');
  Proc('@ DateTime');
end;

//==========================================================
//============ initialization
//==========================================================
function IDE_DbfDefaultPath:string;
begin
{$ifndef FPC}
  if ToolServices<>nil then
    Result := ExtractFilePath(ToolServices.GetProjectName)
  else
{$endif}
    Result := GetCurrentDir
end;

{$ifdef FPC}
procedure RegisterUnitDbf;
{$else}
procedure Register;
{$endif}
begin
  Dbf.DbfBasePath := IDE_DbfDefaultPath;
  RegisterComponents('Data Access', [TDbf]);
//  RegisterPropertyEditor(TypeInfo(string), TDbf, 'FilePath', TFilePathProperty);
  RegisterPropertyEditor(TypeInfo(string), TDbf, 'TableName', TTableNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TDbf, 'Version', TVersionProperty);
  RegisterPropertyEditor(TypeInfo(string), TDbf, 'IndexName', TIndexNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TDbfIndexDef, 'IndexFile', TIndexFileNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TDbfIndexDef, 'SortField', TSortFieldProperty);
  RegisterPropertyEditor(TypeInfo(char), TDbfFieldDef, 'NativeFieldType', TNativeFieldTypeProperty);
end;

{$ifdef FPC}
procedure Register;
begin
  RegisterUnit('Dbf', @RegisterUnitDbf);
end;
{$endif}

{$ifdef FPC}
initialization
  {$i tdbf.lrs}
{$endif}

end.
