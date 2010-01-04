{ MSEide Copyright (c) 2007-2010 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit msefadeedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msepickwidget,mseimage,msetypes,
 msepointer,msewidgets,msedataedits,mseedit,msegrids,msestrings,msewidgetgrid,
 msecolordialog,mseeditglob,msesimplewidgets,msepropertyeditors,msestatfile,
 msegraphedits,msebitmap,msedatanodes,msefiledialog,mselistbrowser,msesys,
 msegridsglob;

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
   formstatfile: tstatfile;
   reverse: tbooleanedit;
   tbutton3: tbutton;
   tbutton4: tbutton;
   filedialog: tfiledialog;
   fadestatfile: tstatfile;
   procedure mouseev(const sender: twidget; var info: mouseeventinfoty);
   procedure pospaintev(const sender: twidget; const canvas: tcanvas);
   procedure createev(const sender: TObject);
   procedure getcursorshapeev(const sender: tcustompickwidget;
                   const apos: pointty; const shiftstate: shiftstatesty;
                   var shape: cursorshapety; var found: Boolean);
   procedure getpickobjectev(const sender: tcustompickwidget;
                   const rect: rectty; const shiftstate: shiftstatesty;
                   var objects: integerarty);
   procedure paintxorev(const sender: tcustompickwidget; const canvas: tcanvas;
                   const apos: pointty; const offset: pointty;
                   const objects: integerarty);
   procedure endpickev(const sender: tcustompickwidget; const apos: pointty;
                    const ashiftstate: shiftstatesty; const offset: pointty;
                   const objects: integerarty);
   procedure resizeev(const sender: TObject);
   procedure dataenteterev(const sender: TObject);
   procedure rowdeleteev(const sender: tcustomgrid; const aindex: Integer;
                   const acount: Integer);
   procedure gridcellev(const sender: TObject; var info: celleventinfoty);
   procedure rowinsertev(const sender: tcustomgrid; const aindex: Integer;
                   const acount: Integer);
   procedure beforedrawev(const sender: tcol; const canvas: tcanvas;
                   var cellinfo: cellinfoty; var processed: Boolean);
   procedure reverseenteredev(const sender: TObject);
   procedure saveex(const sender: TObject);
   procedure loadex(const sender: TObject);
  private
   fnodepos: integerarty;
   fmarker: pointarty;
   procedure movemarker(apos: integer);
   function findmarker(const apos: pointty): integer; //-1 if not found    
   function limitmarkerpos(const index: integer;
                                      const aoffset: integer): integer;
  protected
   procedure change;
 end;

 tfacefadecoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacefadeposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;
 
 tfacetemplatefadecoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacetemplatefadeposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;
 
implementation

uses
 msefadeedit_mfm,msedatalist;
type
 tpropertyeditor1 = class(tpropertyeditor);
 
procedure editfacefade(const aproperty: tpropertyeditor);
var
 form1: tfadeeditfo;
 int1: integer;
begin
 form1:= tfadeeditfo.create(nil);
 try
  with tcustomface(tpropertyeditor1(aproperty).instance) do begin
   form1.reverse.value:= fade_direction in [gd_left,gd_up];
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
     with tcustomface(instance(int1)) do begin
      if form1.reverse.value then begin
       if fade_direction = gd_right then begin
        fade_direction:= gd_left;
       end
       else begin
        if fade_direction <> gd_left then begin
         fade_direction:= gd_up;
        end;
       end;
      end
      else begin
       if fade_direction = gd_left then begin
        fade_direction:= gd_right;
       end
       else begin
        if fade_direction <> gd_right then begin
         fade_direction:= gd_down;
        end;
       end;
      end;
      fade_pos.assign(form1.fadedisp.face.fade_pos);
      fade_color.assign(form1.fadedisp.face.fade_color);
     end; 
    end;
    modified;
   end;
  end;
 finally
  form1.free;
 end;
end;
 
procedure editfacetemplatefade(const aproperty: tpropertyeditor);
var
 form1: tfadeeditfo;
 int1: integer;
begin
 form1:= tfadeeditfo.create(nil);
 try
  with tfacetemplate(tpropertyeditor1(aproperty).instance) do begin
   form1.reverse.value:= fade_direction in [gd_left,gd_up];
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
     with tfacetemplate(instance(int1)) do begin
      if form1.reverse.value then begin
       if fade_direction = gd_right then begin
        fade_direction:= gd_left;
       end
       else begin
        if fade_direction <> gd_left then begin
         fade_direction:= gd_up;
        end;
       end;
      end
      else begin
       if fade_direction = gd_left then begin
        fade_direction:= gd_right;
       end
       else begin
        if fade_direction <> gd_right then begin
         fade_direction:= gd_down;
        end;
       end;
      end;
      fade_pos.assign(form1.fadedisp.face.fade_pos);
      fade_color.assign(form1.fadedisp.face.fade_color);
     end; 
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
 int1,int2: integer;
 rea1,rea2,rea3: realty;
 rect1: rectty;
 posx: integer;
begin
 if (info.pos.y < fadedisp.height) and sender.isleftbuttondown(info) then begin
  if reverse.value then begin
   posx:= posedit.paintsize.cx - info.pos.x;
  end
  else begin
   posx:= info.pos.x;
  end;
  additem(fnodepos,posx);
  sortarray(fnodepos,ar1);
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
  int1:= 0;
  for int2 := 0 to high(ar1) do begin
   if ar1[int2] = high(ar1) then begin
    int1:= int2 + 1; //grid row
    break;
   end;
  end;
  grid.beginupdate;
  grid.onrowsinserted:= nil;
  grid.insertrow(int1);
  grid.onrowsinserted:= {$ifdef FPC}@{$endif}rowinsertev;
  rect1:= posedit.innerclientrect;
  if rect1.cx = 0 then begin
   rea1:= 0;
  end
  else begin
   rea1:= (posx - rect1.x) / rect1.cx;
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
  grid.setfocus;
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

procedure tfadeeditfo.movemarker(apos: integer);
begin 
 if reverse.value then begin
  apos:= posedit.paintsize.cx - apos;
 end;
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
 if reverse.value then begin
  fadedisp.face.fade_direction:= gd_left;
  fadevert.face.fade_direction:= gd_up;
 end
 else begin
  fadedisp.face.fade_direction:= gd_right;
  fadevert.face.fade_direction:= gd_down;
 end;
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
 if grid.rowcount > 0 then begin
  posed[grid.rowhigh]:= 1;
  posed[0]:= 0;
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
  if int1 + 1 = grid.row then begin
   canvas.drawlines(fmarker,true,cl_red);
  end
  else begin
   canvas.drawlines(fmarker,true,cl_black);
  end;
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
 xpos: integer;
begin
 result:= -1;
 rect1:= posedit.innerclientrect;
 int1:= rect1.y + rect1.cy;
 int4:= high(fnodepos);
 if reverse.value then begin
  xpos:= posedit.paintsize.cx - apos.x;
 end
 else begin
  xpos:= apos.x;
 end;
 if (apos.y < int1) and (apos.y >= int1 - markerheight) then begin
  int2:= xpos - markerhalfwidth;
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
 if reverse.value then begin
  result:= fnodepos[index] - aoffset;
 end
 else begin
  result:= fnodepos[index] + aoffset;
 end;
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

procedure tfadeeditfo.paintxorev(const sender: tcustompickwidget;
               const canvas: tcanvas; const apos: pointty;
               const offset: pointty; const objects: integerarty);
begin
 movemarker(limitmarkerpos(objects[0],offset.x));
 canvas.drawlines(fmarker,true,cl_white);
 canvas.drawline(makepoint(fmarker[1].x,fmarker[1].y-1),
              makepoint(fmarker[1].x,posedit.innerclientpos.y),cl_white);
end;

procedure tfadeeditfo.endpickev(const sender: tcustompickwidget;
               const apos: pointty;  const ashiftstate: shiftstatesty; 
               const offset: pointty;
               const objects: integerarty);
var
 int1: integer;
 rect1: rectty;
 rea1: real;
 offsetx: integer;
begin
 offsetx:= offset.x;
 if reverse.value then begin
  offsetx:= -offsetx;
 end;
 rect1:= sender.innerclientrect;
 int1:= objects[0];
 if rect1.cx = 0 then begin
  rea1:= 0;
 end
 else begin
  rea1:= (fnodepos[int1] - rect1.x + offsetx) / rect1.cx;
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

procedure tfadeeditfo.gridcellev(const sender: TObject;
               var info: celleventinfoty);
begin
 with info do begin
  if (eventkind = cek_enter) and (newcell.row <> cellbefore.row) then begin
   posedit.invalidate; //redraw red marker
  end;
 end;
end;

procedure tfadeeditfo.rowinsertev(const sender: tcustomgrid;
               const aindex: Integer; const acount: Integer);
begin
 grid.beginupdate;
 if aindex < grid.rowhigh then begin
  if aindex = 0 then begin
   colored[0]:= colored[1]; //pos = 0
  end
  else begin
   colored[0]:= blendcolor(0.5,colored[aindex+1],colored[aindex]);
   posed[0]:= (posed[aindex+1] + posed[aindex]) / 2;
  end
 end
 else begin
  colored[0]:= colored[grid.rowhigh];
  if grid.rowhigh = 0 then begin
   posed[0]:= 0;
  end
  else begin
   posed[0]:= 1;
  end;
 end;
 grid.endupdate;
 change;
end;

procedure tfadeeditfo.beforedrawev(const sender: tcol; const canvas: tcanvas;
               var cellinfo: cellinfoty; var processed: Boolean);
begin
 cellinfo.color:= colorty(colortorgb(colored[cellinfo.cell.row]));
end;

procedure tfadeeditfo.reverseenteredev(const sender: TObject);
begin
 change;
end;

procedure tfadeeditfo.saveex(const sender: TObject);
begin
 if filedialog.execute(fdk_save) = mr_ok then begin
  fadestatfile.writestat(filedialog.controller.filename);
 end;
end;

procedure tfadeeditfo.loadex(const sender: TObject);
begin
 if filedialog.execute(fdk_open) = mr_ok then begin
  fadestatfile.readstat(filedialog.controller.filename);
  change;
 end;
end;

{ tfacefadecoloreditor }

function tfacefadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadecoloreditor.edit;
begin
 editfacefade(self);
end;

{ tfacefadeposeditor }

function tfacefadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeposeditor.edit;
begin
 editfacefade(self);
end;

{ tfacetemplatefadecoloreditor }

function tfacetemplatefadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadecoloreditor.edit;
begin
 editfacetemplatefade(self);
end;

{ tfacetemplatefadeposeditor }

function tfacetemplatefadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeposeditor.edit;
begin
 editfacetemplatefade(self);
end;

end.
