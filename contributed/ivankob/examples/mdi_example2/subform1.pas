unit subform1;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msegui,mseclasses,mseforms,msedock,msedataedits,msegraphics,msegraphutils,classes;

type

  mygripframety = class (tgripframe)
  protected
   procedure drawgripbutton(
    const acanvas: tcanvas;
    const kind: dockbuttonrectty;
    const arect: rectty;
    const acolorglyph,acolorbutton: colorty
   ); override;
  end;

 tsubform1fo = class(tdockform)
   tstringedit1: tstringedit;
   procedure subformactivated(const sender: TObject);
   procedure subformdestroyed(const sender: TObject);
  protected
   procedure internalcreateframe; override;   
 end;
  
var
 mygripframe: mygripframety;
   
implementation

uses
 subform1_mfm,
 mainform,
 mseshapes
;

function scalerect(const arect: rectty; ascale: extended = 1; acenter: boolean = true):rectty;
begin
 with arect do begin
  result.cx:= round(cx * ascale);
  result.cy:= round(cy * ascale);
  if acenter then begin
   result.x:= round(x + cx*(1 - ascale)/2);
   result.y:= round(y + cy*(1 - ascale)/2);
  end;
 end;
end;

procedure tsubform1fo.subformactivated(const sender: TObject);
begin
 mainfo.subformactivated(self);
end;

procedure tsubform1fo.subformdestroyed(const sender: TObject);
begin
 mainfo.listchanged;
end;

procedure mygripframety.drawgripbutton(
    const acanvas: tcanvas;
    const kind: dockbuttonrectty;
    const arect: rectty;
    const acolorglyph,acolorbutton: colorty
);
var
 lw: integer;
begin
 with acanvas,arect do begin
  lw:= linewidth;

  case kind of
   
   dbr_close: begin
    fillrect( arect, cl_red);     
    linewidth:= 3;    
    
    if grip_size >= 8 then begin
     draw3dframe(acanvas, arect,1,defaultframecolors);
     drawcross(inflaterect(scalerect(arect,0.8),-2),cl_yellow);
    end else begin
     drawcross(scalerect(arect,0.8),cl_yellow);
    end;
    
   end;
   else begin
    inherited;
   end;
   
  end;
  linewidth:= lw;
 end;
end;

procedure tsubform1fo.internalcreateframe;
begin
 mygripframety.create(iframe(self),dragdock);
end;



end.
