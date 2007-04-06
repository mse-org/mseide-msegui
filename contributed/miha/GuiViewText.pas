{ This unit is a part of the example that describes contrib/miha usage. 
  Distributed as is.}

unit GuiViewText;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 msegui,mseclasses,mseforms,GuiMDIChild,msedataedits,mseactions,msetextedit,
 mserichstring,msegraphutils,msewidgetgrid;

type
  TGuiViewTextFo = class(TGuiMDIChildFo)
    Editor: ttextedit;
    WidgetGrid: twidgetgrid;
  protected
    procedure SetKey(AValue: String); override;
  public
    procedure LoadFromFile;
  end;

implementation

uses
  GuiViewText_mfm;

procedure TGuiViewTextFo.SetKey(AValue: String);
begin
  inherited;
  DragDock.Caption := AValue;
end;

procedure TGuiViewTextFo.LoadFromFile();
begin
  Editor.LoadFromFile(Key, True);
end;

end.
