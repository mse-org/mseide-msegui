unit msetraywidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msesimplewidgets,mseguiglob;
type
 ttraywidget = class(teventwidget)
  protected
   procedure dock;
   procedure undock;
   procedure setvisible(const avalue: boolean); override;
   procedure loaded; override;
 end;
 
implementation
uses
 mseguiintf,sysutils;
 
{ ttraywidget }

procedure ttraywidget.dock;
begin
 parentwidget:= nil;
 window.syscontainer:= sywi_tray;
end;

procedure ttraywidget.undock;
begin
 if window.haswinid and ownswindow then begin
  window.syscontainer:= sywi_none;
 end;
end;

procedure ttraywidget.setvisible(const avalue: boolean);
begin
 if not(csdesigning in componentstate) and (avalue <> visible) then begin
  if avalue then begin
   dock;
//sleep(1000);
   inherited;
  end
  else begin
   inherited;
   undock;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure ttraywidget.loaded;
begin
 if not(csdesigning in componentstate) and visible then begin
  visible:= false;
  dock;
  visible:= true;
 end;
 inherited;
end;

end.
