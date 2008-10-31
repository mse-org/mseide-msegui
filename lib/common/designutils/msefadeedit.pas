unit msefadeedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msepickwidget,mseimage,msetypes,
 msepointer,msewidgets,msedataedits,mseedit,msegrids,msestrings,msewidgetgrid,
 msecolordialog,mseeditglob,msesimplewidgets,msepropertyeditors,msestatfile;

type
 tfadeeditfo = class(tmseform)
   posedit: tpickwidget;
   fadedisp: tsimplewidget;
   grid: twidgetgrid;
   colored: tcoloredit;
   posed: trealedit;
   fadevert: tsimplewidget;
   tbutton1: tbutton;
   tbutton2: tbutton;
   tstatfile1: tstatfile;
   procedure mouseev(const sender: twidget; var info: mouseeventinfoty);
   procedure pospaintev(const sender: twidget; const canvas: tcanvas);
   procedure createev(const sender: TObject);
   procedure getcursorshapeev(const sender: tcustompickwidget;
                   const apos: pointty; const shiftstate: shiftstatesty;
                   var shape: cursorshapety; var found: Boolean);
   procedure getpickobjectev(const sender: tcustompickwidget;
                   const rect: rectty; const shiftstate: shiftstatesty;
                   var objects: integerarty);
   procedure paintxotev(const sender: tcustompickwidget; const canvas: tcanvas;
                   const apos: pointty; const offset: pointty;
                   const objects: integerarty);
   procedure endpickev(const sender: tcustompickwidget; const apos: pointty;
                   const offset: pointty; const objects: integerarty);
   procedure resizeev(const sender: TObject);
   procedure dataenteterev(const sender: TObject);
   procedure rowdeleteev(const sender: tcustomgrid; const aindex: Integer;
                   const acount: Integer);
  private
   fnodepos: integerarty;
   fmarker: pointarty;
   procedure movemarker(const apos: integer);
   function findmarker(const apos: pointty): integer; //-1 if not found    
   function limitmarkerpos(const index: integer;
                                      const aoffset: integer): integer;
  protected
   procedure change;
 end;

 tfadecoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;  
   procedure edit; override; 
 end;
 
 tfadeposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;   
   procedure edit; override; 
 end;
 
implementation

uses
 msefadeedit_mfm,msedatalist;
type
 tpropertyeditor1 = class(tpropertyeditor);
 
procedure editfade(const aproperty: tpropertyeditor);
var
 form1: tfadeeditfo;
 int1: integer;
begin
 form1:= tfadeeditfo.create(nil);
 try
  with tcustomface(tpropertyeditor1(aproperty).instance) do begin
   form1.grid.rowcount:= fade_pos.count;
   for int1:= 0 to form1.grid.rowhigh do begin
    form1.posed[int1]:= fade_pos[int1];
    form1.colored[int1]:= fade_color[int1];
   end;
   form1.change;
  end;
  if form1.show(true) = mr_ok then begin
   with tpropertyeditor1(aproperty) do begin
    for int1:= 0 to count - 1 do begin
     tcustomface(instance(int1)).fade_pos.assign(form1.fadedisp.face.fade_pos);
     tcustomface(instance(int1)).fade_color.assign(
                                     form1.fadedisp.face.fade_color);
    end;
    modified;
   end;
  end;
 finally
  form1.free;
 end;
end;
 
{ tfadeeditfo }

const
 markerhalfwidth = 2;
 markerheight = markerhalfwidth+1; 
 
procedure tfadeeditfo.mouseev(const sender: twidget; var info: mouseeventinfoty);
var
 ar1: integerarty;
 int1: integer;
 rea1,rea2,rea3: realty;
 rect1: rectty;
begin
 if (info.pos.y < fadedisp.height) and sender.isleftbuttondown(info) then begin
  additem(fnodepos,info.pos.x);
  sortarray(fnodepos,ar1);
  orderarray(ar1,fnodepos);
  if grid.rowcount < 2 then begin
   int1:= grid.rowcount;
   grid.rowcount:= 2;
   posed[0]:= 0;
   posed[1]:= 1;
   if int1 > 1 then begin
    colored[0]:= cl_light;
   end;
   if int1 > 2 then begin
    colored[1]:= cl_shadow;
   end;
  end;
  int1:= ar1[high(ar1)] + 1; //grid row
  grid.beginupdate;
  grid.insertrow(int1);
  rect1:= posedit.innerclientrect;
  if rect1.cx = 0 then begin
   rea1:= 0;
  end
  else begin
   rea1:= (info.pos.x - rect1.x) / rect1.cx;
  end;
  if rea1 < posed[int1-1] then begin
   rea1:= posed[int1-1];
  end;
  if rea1 > posed[int1+1] then begin
   rea1:= posed[int1+1];
  end;
  posed[int1]:= rea1;
  rea2:= posed[int1+1] - posed[int1-1];
  if rea2 = 0 then begin
   rea3:= 0;
  end
  else begin
   rea3:= (rea1 - posed[int1-1]) / rea2;
  end;
  grid.row:= int1;
  grid.focuscell(makegridcoord(1,int1));
  colored[int1]:= blendcolor(rea3,colored[int1-1],colored[int1+1]);
  grid.endupdate;
  change;
 end;
end;

procedure tfadeeditfo.createev(const sender: TObject);
var
 rect1: rectty;
begin
 rect1:= posedit.innerclientrect;
 setlength(fmarker,3);
 fmarker[0].y:= rect1.y + rect1.cy - 1;
 fmarker[1].y:= fmarker[0].y - markerheight;
 fmarker[2].y:= fmarker[0].y;
end;

procedure tfadeeditfo.movemarker(const apos: integer);
begin
 fmarker[0].x:= apos - markerhalfwidth;
 fmarker[1].x:= apos;
 fmarker[2].x:= apos + markerhalfwidth;
end;

procedure tfadeeditfo.change;
var
 int1: integer;
 rea1: real;
 rect1: rectty;
begin
 rect1:= posedit.innerclientrect;
 with fadedisp.face do begin
  fade_pos.count:= grid.rowcount;
  for int1:= grid.rowhigh downto 0 do begin
   fade_pos[int1]:= posed[int1];
   fade_color[int1]:= colored[int1];
  end;
  fadevert.face.fade_pos.assign(fade_pos);
  fadevert.face.fade_color.assign(fade_color);
 end;
 if grid.rowcount < 3 then begin
  fnodepos:= nil;
 end
 else begin
  setlength(fnodepos,grid.rowcount - 2);
 end;
 for int1:= 1 to grid.rowcount - 2 do begin
  fnodepos[int1-1]:= rect1.x + round(posed[int1] * rect1.cx);
 end;
 posedit.invalidate;
end;

procedure tfadeeditfo.pospaintev(const sender: twidget; const canvas: tcanvas);
var
 int1: integer;
begin
 for int1:= 0 to high(fnodepos) do begin
  movemarker(fnodepos[int1]);
  canvas.drawlines(fmarker,true,cl_black);
 end;
end;

procedure tfadeeditfo.getcursorshapeev(const sender: tcustompickwidget;
               const apos: pointty; const shiftstate: shiftstatesty;
               var shape: cursorshapety; var found: Boolean);
var
 rect1: rectty;
 int1,int2,int3: integer;
begin
 if shiftstate = [] then begin
  int1:= findmarker(apos);
  if int1 >= 0 then begin
   shape:= cr_sizehor;
   found:= true;
  end;
 end;
end;

procedure tfadeeditfo.getpickobjectev(const sender: tcustompickwidget;
               const rect: rectty; const shiftstate: shiftstatesty;
               var objects: integerarty);
var
 int1: integer;
begin
 if shiftstate = [ss_left] then begin
  int1:= findmarker(rect.pos);
  if int1 >= 0 then begin
   setlength(objects,1);
   objects[0]:= int1;
  end;
 end;
end;

function tfadeeditfo.findmarker(const apos: pointty): integer;
var
 rect1: rectty;
 int1,int2,int3,int4: integer;
begin
 result:= -1;
 rect1:= posedit.innerclientrect;
 int1:= rect1.y + rect1.cy;
 int4:= high(fnodepos);
 if (apos.y < int1) and (apos.y >= int1 - markerheight) then begin
  int2:= apos.x - markerhalfwidth;
  int3:= int2 + 2 * markerhalfwidth + 1;
  for int1:= 0 to int4 do begin
   if (fnodepos[int1] >= int2) and (fnodepos[int1] <= int3) and 
        not ((int1 < int4) and (fnodepos[int1+1] = rect1.x)) then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

function tfadeeditfo.limitmarkerpos(const index: integer; const aoffset: integer): integer;
var
 rect1: rectty;
begin
 result:= fnodepos[index] + aoffset;
 if (index > 0) and (result < fnodepos[index-1]) then begin
  result:= fnodepos[index-1];
 end
 else begin
  if index < high(fnodepos) then begin
   if result >= fnodepos[index+1] then begin
    result:= fnodepos[index+1];
   end
   else begin
    if result < 0 then begin
     result:= 0;
    end;
   end;
  end
  else begin
   rect1:= posedit.innerclientrect;
   rect1.x:= rect1.x + rect1.cx;
   if result >= rect1.x then begin
    result:= rect1.x - 1;
   end;
  end;
 end;
end;

procedure tfadeeditfo.paintxotev(const sender: tcustompickwidget;
               const canvas: tcanvas; const apos: pointty;
               const offset: pointty; const objects: integerarty);
begin
 movemarker(limitmarkerpos(objects[0],offset.x));
 canvas.drawlines(fmarker,true,cl_white);
 canvas.drawline(makepoint(fmarker[1].x,fmarker[1].y-1),
              makepoint(fmarker[1].x,posedit.innerclientpos.y),cl_white);
end;

procedure tfadeeditfo.endpickev(const sender: tcustompickwidget;
               const apos: pointty; const offset: pointty;
               const objects: integerarty);
var
 int1: integer;
 rect1: rectty;
 rea1: real;
begin
 rect1:= sender.innerclientrect;
 int1:= objects[0];
 if rect1.cx = 0 then begin
  rea1:= 0;
 end
 else begin
  rea1:= (fnodepos[int1] - rect1.x + offset.x) / rect1.cx;
 end;
 if rea1 < posed[int1] then begin
  rea1:= posed[int1];
 end;
 if rea1 > posed[int1+2] then begin
  rea1:= posed[int1+2];
 end;
 posed[int1+1]:= rea1;
 grid.focuscell(makegridcoord(1,int1+1));
 grid.setfocus;
 change;
end;

procedure tfadeeditfo.resizeev(const sender: TObject);
begin
 change;
end;

procedure tfadeeditfo.dataenteterev(const sender: TObject);
begin
 grid.sort;
 change;
end;

procedure tfadeeditfo.rowdeleteev(const sender: tcustomgrid; const aindex: Integer;
               const acount: Integer);
begin
 if grid.rowcount > 0 then begin
  posed[grid.rowhigh]:= 1;
  posed[0]:= 0;
 end;
 change;
end;

{ tfadecoloreditor }

function tfadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfadecoloreditor.edit;
begin
 editfade(self);
end;

{ tfadeposeditor }

function tfadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfadeposeditor.edit;
begin
 editfade(self);
end;

end.
