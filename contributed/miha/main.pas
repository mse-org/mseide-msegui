{ This unit is a part of the example that describes contrib/miha usage 
  Distributed as is.}

unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msemenus,msesimplewidgets,mseactions,GuiMDIChild,
 msedock,msefiledialog,msestat,msestatfile,GuiViewText,msefileutils,mseshapes,
 msebitmap;

type
  tmainfo = class(tmseform)
    MnuMain: tmainmenu;
    ActionExit: taction;
    ActionFileOpen: taction;
    MDIArea: tdockpanel;
    FileDialog: tfiledialog;
    MainSta: tstatfile;
    ActionHideMinimized: taction;
    Img: timagelist;
    procedure OnExecActionExit(const sender: TObject);
    procedure OnExecActionFileOpen(const sender: TObject);
    procedure OnLoadedForm(const sender: TObject);
    procedure OnExecActionHideMin(const sender: TObject);
  private
    FMDI: TMDIController;
  public
    procedure OpenFile(FileName: String);
  end;

var
  mainfo: tmainfo;

implementation

uses
 main_mfm;

procedure tmainfo.OnExecActionExit(const sender: TObject);
begin
  Application.Terminated := True;
end;

procedure tmainfo.OnExecActionFileOpen(const sender: TObject);
var
  I: Integer;
begin
  if FileDialog.Execute = mr_Ok then
  begin
    for I := 0 to High(FileDialog.Controller.FileNames) do
    begin
      OpenFile(FileDialog.Controller.FileNames[I]);
    end;
  end;
end;

procedure tmainfo.OnLoadedForm(const sender: TObject);
begin
  FMDI := TMDIController.Create(mainfo, MDIArea);
  FMDI.Menu := MnuMain.menu.Items[1]; // Menu item for filling by the controller
  
  // Set MDI icons
  FMDI.ActionMinAll.ImageList := Img;
  FMDI.ActionMinAll.ImageNr := 6;
  FMDI.ActionMaxAll.ImageList := Img;
  FMDI.ActionMaxAll.ImageNr := 5;
  
  // Open "readme"
  OpenFile('./GuiMDIChild.pas');
end;

procedure tmainfo.OpenFile(FileName: String);
var
  Editor: TGuiViewTextFo;
begin
  try
    Editor := TGuiViewTextFo(FMDI.ChildByKey(FileName));
    if not Assigned(Editor) then
    begin
      Editor := TGuiViewTextFo.Create(FMDI);
      Editor.Key := FileName;
      Editor.LoadFromFile;
    end;
    Editor.Activate;
  except
    Editor.Free;
  end;
end;

procedure tmainfo.OnExecActionHideMin(const sender: TObject);
begin
  FMDI.HideMinimized := not FMDI.HideMinimized;
  if FMDI.HideMinimized then 
  begin
    ActionHideMinimized.Caption := 'Show minimized';
    ActionHideMinimized.ImageNr := 4;
    ActionHideMinimized.State := ActionHideMinimized.State + [as_checked];
  end
  else begin
    ActionHideMinimized.Caption := 'Hide minimized';
    ActionHideMinimized.ImageNr := 3;
    ActionHideMinimized.State := ActionHideMinimized.State - [as_checked];
  end;
end;

end.
