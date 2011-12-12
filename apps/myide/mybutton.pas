unit mybutton;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msesimplewidgets,mseevent,msegraphics,classes,msegraphutils,mseact,mseguiglob;
 
const
 defaultcolorclicked = cl_red;
 
type
 tmybutton = class(tbutton)
  private
   fcolorclicked: colorty;
   procedure setcolorclicked(const avalue: colorty);
  protected
   procedure checkcolor;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property colorclicked: colorty read fcolorclicked 
                  write setcolorclicked default defaultcolorclicked;
 end;
  
implementation
uses
 mseshapes;
 
{ tmybutton }

constructor tmybutton.create(aowner: tcomponent);
begin
 fcolorclicked:= defaultcolorclicked;
 inherited;
end;

procedure tmybutton.checkcolor;
begin
 with finfo do begin
  if shs_clicked in state then begin
   color:= fcolorclicked;
  end
  else begin
   color:= self.color;
  end;
 end;
end;

procedure tmybutton.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 checkcolor;
end;

procedure tmybutton.dokeydown(var info: keyeventinfoty);
begin
 inherited;
 checkcolor;
end;

procedure tmybutton.dokeyup(var info: keyeventinfoty);
begin
 inherited;
 checkcolor;
end;

procedure tmybutton.setcolorclicked(const avalue: colorty);
begin
 if fcolorclicked <> avalue then begin
  fcolorclicked:= avalue;
  checkcolor;
  invalidate;
 end;
end;

end.
