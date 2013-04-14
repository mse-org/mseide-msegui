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
 msegridsglob,mseobjectpicker,mseifiglob,msearrayprops;

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
   opaed: tcoloredit;
   syncbu: tbutton;
   tsimplewidget1: tsimplewidget;
   tsimplewidget2: tsimplewidget;
   tsimplewidget3: tsimplewidget;
   tsimplewidget4: tsimplewidget;
   tsimplewidget5: tsimplewidget;
   tsimplewidget6: tsimplewidget;
   clearbu: tbutton;
   procedure mouseev(const sender: twidget; var info: mouseeventinfoty);
   procedure pospaintev(const sender: twidget; const canvas: tcanvas);
   procedure createev(const sender: TObject);
   procedure getcursorshapeev(const sender: tcustompickwidget;
                   const picker: tobjectpicker;
                   var shape: cursorshapety; var found: Boolean);
   procedure getpickobjectev(const sender: tcustompickwidget;
                             const picker: tobjectpicker;
                             var objects: integerarty);
   procedure paintxorev(const sender: tcustompickwidget; 
                          const picker: tobjectpicker; const canvas: tcanvas);
   procedure endpickev(const sender: tcustompickwidget; 
                             const picker: tobjectpicker);
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
   procedure syncexe(const sender: TObject);
   procedure clearopaexe(const sender: TObject);
   procedure fadestatupdateexe(const sender: TObject; const filer: tstatfiler);
  private
   fnodepos: integerarty;
   fmarker: pointarty;
   ffadepos,ffadeopapos: trealarrayprop;
   ffadecolor,ffadeopacolor: tcolorarrayprop;
   fopacitycleared: boolean;
   fopa: boolean;
   procedure movemarker(apos: integer);
   function findmarker(const apos: pointty): integer; //-1 if not found    
   function limitmarkerpos(const index: integer;
                                      const aoffset: integer): integer;
  protected
   procedure change;
   procedure doasyncevent(var atag: integer); override;
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

 tfacefadeopacoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacefadeopaposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;
 
 tfacetemplatefadeopacoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacetemplatefadeopaposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;
 
implementation

uses
 msefadeedit_mfm,msedatalist,msearrayutils;
type
 tpropertyeditor1 = class(tpropertyeditor);

function editfade(var fadedirection: graphicdirectionty; const opa: boolean;
               const fadepos,fadeopapos: trealarrayprop;
               const fadecolor,fadeopacolor: tcolorarrayprop): modalresultty;
var
 form1: tfadeeditfo;
 int1: integer;
 bo1: boolean;
begin
 form1:= tfadeeditfo.create(nil);
 try
  with form1 do begin
   fopa:= opa;
   ffadepos:= fadepos;
   ffadeopapos:= fadeopapos;
   ffadecolor:= fadecolor;
   ffadeopacolor:= fadeopacolor;
   reverse.value:= fadedirection in [gd_left,gd_up];
  end;
  if opa then begin
   form1.grid.rowcount:= fadeopapos.count;
   for int1:= 0 to form1.grid.rowhigh do begin
    form1.posed[int1]:= fadeopapos[int1];
    form1.colored[int1]:= fadeopacolor[int1];
   end;    
  end
  else begin
   bo1:= (fadepos.count = fadeopapos.count) and (fadepos.count <> 0);
   form1.grid.rowcount:= fadepos.count;
   for int1:= 0 to form1.grid.rowhigh do begin
    form1.posed[int1]:= fadepos[int1];
    form1.colored[int1]:= fadecolor[int1];
    bo1:= bo1 and (fadepos[int1] = fadeopapos[int1]);
   end;
   if bo1 then begin
    for int1:= 0 to form1.grid.rowhigh do begin
     form1.opaed[int1]:= fadeopacolor[int1];
     bo1:= bo1 and (fadepos[int1] = fadeopapos[int1]);
    end;
   end;
   form1.syncbu.enabled:= not bo1;
   form1.clearbu.enabled:= bo1;
   form1.grid.datacols[3].visible:= bo1 and not opa;
  end;
  form1.change;
  result:= form1.show(true);
  if result = mr_ok then begin
   if form1.reverse.value then begin
    if fadedirection = gd_right then begin
     fadedirection:= gd_left;
    end
    else begin
     if fadedirection <> gd_left then begin
      fadedirection:= gd_up;
     end;
    end;
   end
   else begin
    if fadedirection = gd_left then begin
     fadedirection:= gd_right;
    end
    else begin
     if fadedirection <> gd_right then begin
      fadedirection:= gd_down;
     end;
    end;
   end;
   if opa then begin
    fadeopapos.assign(form1.fadedisp.face.fade_pos);
    fadeopacolor.assign(form1.fadedisp.face.fade_color);
   end
   else begin
    fadepos.assign(form1.fadedisp.face.fade_pos);
    fadecolor.assign(form1.fadedisp.face.fade_color);
    if form1.grid.datacols[3].visible then begin
     fadeopapos.assign(form1.fadedisp.face.fade_opapos);
     fadeopacolor.assign(form1.fadedisp.face.fade_opacolor);
    end
    else begin
     if form1.fopacitycleared then begin
      fadeopapos.count:= 0;
      fadeopacolor.count:= 0;
     end;
    end;
   end;
  end;
 finally
  form1.free;
 end;
end;

procedure editfacefade(const aproperty: tpropertyeditor; const opa: boolean);
var
 direct: graphicdirectionty;
 fadepos,fadeopapos: trealarrayprop;
 fadecolor,fadeopacolor: tcolorarrayprop;
 int1: integer;
begin
 with tcustomface(tpropertyeditor1(aproperty).instance) do begin
  direct:= fade_direction; 
  fadepos:= fade_pos;
  fadeopapos:= fade_opapos;
  fadecolor:= fade_color;
  fadeopacolor:= fade_opacolor;
  if editfade(direct,opa,fade_pos,fade_opapos,
                               fade_color,fade_opacolor) = mr_ok then begin
   fade_direction:= direct;
   with tpropertyeditor1(aproperty) do begin
    for int1:= 1 to count - 1 do begin
     with tcustomface(tpropertyeditor1(aproperty).instance(int1)) do begin
      fade_direction:= direct;
      if opa then begin
       fade_opapos.assign(fadeopapos);
       fade_opacolor.assign(fadeopacolor);
      end
      else begin
       fade_opapos.assign(fadepos);
       fade_opacolor.assign(fadecolor);
      end;
     end;
    end;    
    modified;
   end;
  end;
 end;
end;
{ 
procedure editfacefade(const aproperty: tpropertyeditor; const trans: boolean);
var
 form1: tfadeeditfo;
 int1: integer;
 bo1: boolean;
begin
 form1:= tfadeeditfo.create(nil);
 try
  with tcustomface(tpropertyeditor1(aproperty).instance) do begin
   form1.reverse.value:= fade_direction in [gd_left,gd_up];
   if trans then begin
    form1.grid.rowcount:= fade_transpos.count;
    for int1:= 0 to form1.grid.rowhigh do begin
     form1.posed[int1]:= fade_transpos[int1];
     form1.colored[int1]:= fade_transcolor[int1];
    end;    
   end
   else begin
    bo1:= fade_pos.count = fade_transpos.count;
    form1.grid.rowcount:= fade_pos.count;
    for int1:= 0 to form1.grid.rowhigh do begin
     form1.posed[int1]:= fade_pos[int1];
     form1.colored[int1]:= fade_color[int1];
     bo1:= bo1 and (fade_pos[int1] = fade_transpos[int1]);
    end;
    if bo1 then begin
     for int1:= 0 to form1.grid.rowhigh do begin
      form1.transed[int1]:= fade_transcolor[int1];
      bo1:= bo1 and (fade_pos[int1] = fade_transpos[int1]);
     end;
    end;
    syncbu.enabled:= not bo1;
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
      if trans then begin
       fade_transpos.assign(form1.fadedisp.face.fade_pos);
       fade_transcolor.assign(form1.fadedisp.face.fade_color);
      end
      else begin
       fade_pos.assign(form1.fadedisp.face.fade_pos);
       fade_color.assign(form1.fadedisp.face.fade_color);
      end;
     end; 
    end;
    modified;
   end;
  end;
 finally
  form1.free;
 end;
end;
}

procedure editfacetemplatefade(const aproperty: tpropertyeditor;
                                                   const opa: boolean);
var
 direct: graphicdirectionty;
 fadepos,fadeopapos: trealarrayprop;
 fadecolor,fadeopacolor: tcolorarrayprop;
 int1: integer;
begin
 with tfacetemplate(tpropertyeditor1(aproperty).instance) do begin
  direct:= fade_direction; 
  fadepos:= fade_pos;
  fadeopapos:= fade_opapos;
  fadecolor:= fade_color;
  fadeopacolor:= fade_opacolor;
  if editfade(direct,opa,fade_pos,fade_opapos,
                               fade_color,fade_opacolor) = mr_ok then begin
   fade_direction:= direct;
   with tpropertyeditor1(aproperty) do begin
    for int1:= 1 to count - 1 do begin
     with tfacetemplate(tpropertyeditor1(aproperty).instance(int1)) do begin
      fade_direction:= direct;
      if opa then begin
       fade_opapos.assign(fadeopapos);
       fade_opacolor.assign(fadeopacolor);
      end
      else begin
       fade_opapos.assign(fadepos);
       fade_opacolor.assign(fadecolor);
      end;
     end;
    end;    
    modified;
   end;
  end;
 end;
end;
{
procedure editfacetemplatefade(const aproperty: tpropertyeditor;
                                           const trans: boolean);
var
 form1: tfadeeditfo;
 int1: integer;
begin
 form1:= tfadeeditfo.create(nil);
 try
  with tfacetemplate(tpropertyeditor1(aproperty).instance) do begin
   form1.reverse.value:= fade_direction in [gd_left,gd_up];
   if trans then begin
    form1.grid.rowcount:= fade_transpos.count;
    for int1:= 0 to form1.grid.rowhigh do begin
     form1.posed[int1]:= fade_transpos[int1];
     form1.colored[int1]:= fade_transcolor[int1];
    end;
   end
   else begin
    form1.grid.rowcount:= fade_pos.count;
    for int1:= 0 to form1.grid.rowhigh do begin
     form1.posed[int1]:= fade_pos[int1];
     form1.colored[int1]:= fade_color[int1];
    end;
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
      if trans then begin
       fade_transpos.assign(form1.fadedisp.face.fade_pos);
       fade_transcolor.assign(form1.fadedisp.face.fade_color);
      end
      else begin
       fade_pos.assign(form1.fadedisp.face.fade_pos);
       fade_color.assign(form1.fadedisp.face.fade_color);
      end;
     end; 
    end;
    modified;
   end;
  end;
 finally
  form1.free;
 end;
end;
}
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
   if int1 < 1 then begin
    colored[0]:= defaultfadecolor;
   end;
   if int1 < 2 then begin
    colored[1]:= defaultfadecolor1;
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
  opaed[int1]:= blendcolor(rea3,opaed[int1-1],opaed[int1+1]);
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
// rea1: real;
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
  if grid.datacols[3].visible then begin
   fade_opapos.count:= grid.rowcount;
   for int1:= grid.rowhigh downto 0 do begin
    fade_pos[int1]:= posed[int1];
    fade_color[int1]:= colored[int1];
    fade_opapos[int1]:= posed[int1];
    fade_opacolor[int1]:= opaed[int1];
   end;
  end
  else begin
   fade_opapos.count:= 0;
   for int1:= grid.rowhigh downto 0 do begin
    fade_pos[int1]:= posed[int1];
    fade_color[int1]:= colored[int1];
   end;
  end;
  fadevert.face.fade_pos.assign(fade_pos);
  fadevert.face.fade_color.assign(fade_color);
  fadevert.face.fade_opapos.assign(fade_opapos);
  fadevert.face.fade_opacolor.assign(fade_opacolor);
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
                         const picker: tobjectpicker;
                         var shape: cursorshapety; var found: Boolean);
var
// rect1: rectty;
 int1{,int2,int3}: integer;
begin
// if picker.shiftstate = [] then begin
  int1:= findmarker(picker.pos);
  if int1 >= 0 then begin
   shape:= cr_sizehor;
   found:= true;
  end;
// end;
end;

procedure tfadeeditfo.getpickobjectev(const sender: tcustompickwidget;
               const picker: tobjectpicker; var objects: integerarty);
var
 int1: integer;
begin
 if picker.shiftstate = [ss_left] then begin
  int1:= findmarker(picker.pickrect.pos);
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
                                  const picker: tobjectpicker;
                                  const canvas: tcanvas);
begin
 movemarker(limitmarkerpos(picker.currentobjects[0],picker.pickoffset.x));
 canvas.drawlines(fmarker,true,cl_white);
 canvas.drawline(makepoint(fmarker[1].x,fmarker[1].y-1),
              makepoint(fmarker[1].x,posedit.innerclientpos.y),cl_white);
end;

procedure tfadeeditfo.endpickev(const sender: tcustompickwidget;
                                           const picker: tobjectpicker);
var
 int1: integer;
 rect1: rectty;
 rea1: real;
 offsetx: integer;
begin
 offsetx:= picker.pickoffset.x;
 if reverse.value then begin
  offsetx:= -offsetx;
 end;
 rect1:= sender.innerclientrect;
 int1:= picker.currentobjects[0];
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
 if sender.userinput then begin
  grid.beginupdate;
  if aindex < grid.rowhigh then begin
   if aindex = 0 then begin
    colored[0]:= colored[1]; //pos = 0
    opaed[0]:= opaed[1]; //pos = 0
    posed[0]:= 0;
   end
   else begin
    colored[aindex]:= blendcolor(0.5,colored[aindex+1],colored[aindex-1]);
    opaed[aindex]:= blendcolor(0.5,opaed[aindex+1],opaed[aindex-1]);
    posed[aindex]:= (posed[aindex+1] + posed[aindex-1]) / 2;
   end
  end
  else begin
   if grid.rowhigh = 0 then begin
    posed[aindex]:= 0;
   end
   else begin
    colored[aindex]:= colored[grid.rowhigh-1];
    opaed[aindex]:= opaed[grid.rowhigh-1];
    posed[aindex]:= 1;
   end;
  end;
  grid.endupdate;
  change;
 end
 else begin
  asyncevent;
 end;
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

procedure tfadeeditfo.doasyncevent(var atag: integer);
begin
 inherited;
 change;
end;

procedure tfadeeditfo.syncexe(const sender: TObject);

 function scale(const apos,lopos,hipos: real;
                const locolor,hicolor: colorty): colorty;
 begin
  if apos = lopos then begin
   result:= locolor;
  end
  else begin
   if apos = hipos then begin
    result:= hicolor;
   end
   else begin
    if lopos = hipos then begin
     if locolor = hicolor then begin
      result:= locolor;
     end
     else begin
      result:= blendcolor(0.5,locolor,hicolor);
     end;
    end
    else begin
     result:= blendcolor((apos-lopos)/(hipos-lopos),locolor,hicolor);
    end;
   end;
  end;
 end; //scale
          
var
 int1,int2: integer;
begin
 if askyesno(
  'Do you want to synchronize opacity gradient'+lineend+
                      'with color gradient?','Confirmation') then begin
  grid.beginupdate;
  try
   fopacitycleared:= false;
   int2:= 0;
   if grid.rowcount < ffadeopapos.count then begin
    if grid.rowcount = 0 then begin
     grid.rowcount:= 1;
     posed[0]:= 0;
    end;
    if (grid.rowcount < 2) and (grid.rowcount < ffadeopapos.count) then begin
     grid.rowcount:= 2;
     posed[1]:= 1;
     colored[1]:= colored[0];
    end;
   end;
   for int1:= 1 to ffadeopapos.count-2 do begin
    while posed[int2] < ffadeopapos[int1] do begin
     inc(int2);
    end;
    if posed[int2] <> ffadeopapos[int1] then begin
     grid.insertrow(int2);
     posed[int2]:= ffadeopapos[int1];
     colored[int2]:= scale(posed[int2],posed[int2-1],posed[int2+1],
                            colored[int2-1],colored[int2+1]);
    end;
   end;
   int2:= 0;
   for int1:= 0 to grid.rowhigh do begin
    while (int2 < ffadeopapos.count) and
                              (ffadeopapos[int2] < posed[int1]) do begin
     inc(int2);
    end;
    case ffadeopapos.count of
     0: begin
      opaed[int1]:= cl_white;
     end;
     1: begin
      opaed[int1]:= ffadeopacolor[0];
     end;
     else begin
      if int2 >= ffadeopacolor.count-1 then begin
       opaed[int1]:= ffadeopacolor[ffadeopacolor.count-1];
      end
      else begin
       opaed[int1]:= scale(posed[int1],ffadeopapos[int2],
                           ffadeopapos[int2+1],ffadeopacolor[int2],
                           ffadeopacolor[int2+1])
      end;
     end;
    end;
   end;
   grid.datacols[3].visible:= true;
  finally
   grid.endupdate;
  end;
  syncbu.enabled:= false;
  clearbu.enabled:= true;
  change;
 end;
end;

procedure tfadeeditfo.clearopaexe(const sender: TObject);
begin
 if askyesno(
  'Do you want to remove opacity gradient?','Confirmation') then begin
  grid.datacols[3].visible:= false;
  change;
  clearbu.enabled:= false;
  syncbu.enabled:= true;
  fopacitycleared:= true;
 end;
end;

procedure tfadeeditfo.fadestatupdateexe(const sender: TObject;
               const filer: tstatfiler);
var
 bo1: boolean;
begin
 bo1:= grid.datacols[3].visible;
 if not filer.iswriter or fopa then begin
  bo1:= false;
 end;
 filer.updatevalue('opasynced',bo1);
 grid.datacols[3].visible:= bo1 and not fopa;
end;

{ tfacefadecoloreditor }

function tfacefadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadecoloreditor.edit;
begin
 editfacefade(self,false);
end;

{ tfacefadeposeditor }

function tfacefadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeposeditor.edit;
begin
 editfacefade(self,false);
end;

{ tfacetemplatefadecoloreditor }

function tfacetemplatefadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadecoloreditor.edit;
begin
 editfacetemplatefade(self,false);
end;

{ tfacetemplatefadeposeditor }

function tfacetemplatefadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeposeditor.edit;
begin
 editfacetemplatefade(self,false);
end;

{ tfacefadeopacoloreditor }

function tfacefadeopacoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeopacoloreditor.edit;
begin
 editfacefade(self,true);
end;

{ tfacefadeopaposeditor }

function tfacefadeopaposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeopaposeditor.edit;
begin
 editfacefade(self,true);
end;

{ tfacetemplatefadeopacoloreditor }

function tfacetemplatefadeopacoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeopacoloreditor.edit;
begin
 editfacetemplatefade(self,true);
end;

{ tfacetemplatefadeopaposeditor }

function tfacetemplatefadeopaposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeopaposeditor.edit;
begin
 editfacetemplatefade(self,true);
end;

end.
