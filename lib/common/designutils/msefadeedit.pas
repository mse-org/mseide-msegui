{ MSEide Copyright (c) 2007-2013 by Martin Schreiber
   
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
 msegridsglob,mseobjectpicker,mseifiglob,msearrayprops,msesplitter;

type
 nodeinfoty = record
  nodepos: integerarty;
  marker: pointarty;
  grid: tcustomgrid;
  posed: trealedit;
  colored: tcoloredit;
  opaed: tcoloredit;
 end;
 pnodeinfoty = ^nodeinfoty;

 tfadeeditfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   formstatfile: tstatfile;
   reverse: tbooleanedit;
   tbutton3: tbutton;
   tbutton4: tbutton;
   filedialog: tfiledialog;
   fadestatfile: tstatfile;
   clearbu: tbutton;
   splitopa: tbooleanedit;
   cont2: tsimplewidget;
   cont1: tsimplewidget;
   tsimplewidget7: tsimplewidget;
   layouter: tlayouter;
   opagrid: twidgetgrid;
   opaposed: trealedit;
   opacolored: tcoloredit;
   grid: twidgetgrid;
   posed: trealedit;
   colored: tcoloredit;
   opaed: tcoloredit;
   splitter: tsplitter;
   posedit: tpickwidget;
   tsimplewidget3: tsimplewidget;
   tsimplewidget2: tsimplewidget;
   tsimplewidget4: tsimplewidget;
   fadedisp: tsimplewidget;
   tsimplewidget5: tsimplewidget;
   tsimplewidget6: tsimplewidget;
   fadevert: tsimplewidget;
   opaedit: tpickwidget;
   opadisp: tsimplewidget;
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
   procedure clearopaexe(const sender: TObject);
   procedure fadestatupdateexe(const sender: TObject; const filer: tstatfiler);
   procedure sepopaset(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
  private
   fnodeinfo: nodeinfoty;
   fnodeinfoopa: nodeinfoty;
//   ffadepos,ffadeopapos: trealarrayprop;
//   ffadecolor,ffadeopacolor: tcolorarrayprop;
   fopacitycleared: boolean;
   fopa: boolean;
   fopasynced: boolean;
   procedure movemarker(const atag: integer; apos: integer);
   function findmarker(const atag: integer; const apos: pointty): integer;
                                                           //-1 if not found    
   function limitmarkerpos(const atag: integer; const index: integer;
                                      const aoffset: integer): integer;
   procedure setopasynced(const avalue: boolean);
  protected
   function nodeinfo(const atag: integer): pnodeinfoty;
   function syncexe: boolean;
   procedure change;
   procedure doasyncevent(var atag: integer); override;
   property opasynced: boolean read fopasynced write setopasynced;
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
//   ffadepos:= fadepos;
//   ffadeopapos:= fadeopapos;
//   ffadecolor:= fadecolor;
//   ffadeopacolor:= fadeopacolor;
   reverse.value:= fadedirection in [gd_left,gd_up];
  end;
  if opa then begin
   form1.grid.rowcount:= fadeopapos.count;
   for int1:= 0 to form1.grid.rowhigh do begin
    form1.posed[int1]:= fadeopapos[int1];
    form1.colored[int1]:= fadeopacolor[int1];
   end;
   form1.fopacitycleared:= true;
   form1.splitopa.enabled:= false;
   form1.opasynced:= true;
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
   form1.fopacitycleared:= fadeopapos.count = 0;
   bo1:= bo1 or form1.fopacitycleared;
//   form1.splitopa.value:= bo1;
   form1.clearbu.enabled:= bo1 and not form1.fopacitycleared;
   form1.opasynced:= bo1;
   form1.opagrid.rowcount:= fadeopapos.count;
   for int1:= 0 to form1.opagrid.rowhigh do begin
    form1.opaposed[int1]:= fadeopapos[int1];
    form1.opacolored[int1]:= fadeopacolor[int1];
   end;
   form1.grid.datacols[3].visible:= bo1 and not form1.fopacitycleared;
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
    fadeopapos.assign(form1.fadedisp.face.fade_opapos);
    fadeopacolor.assign(form1.fadedisp.face.fade_opacolor);
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
  with nodeinfo(sender.tag)^ do begin
   additem(nodepos,posx);
   sortarray(nodepos,ar1);
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
   if opaed <> nil then begin
    opaed[int1]:= blendcolor(rea3,opaed[int1-1],opaed[int1+1]);
   end;
   grid.endupdate;
   change;
   grid.setfocus;
  end;
 end;
end;

procedure tfadeeditfo.createev(const sender: TObject);
var
 rect1: rectty;
begin
 rect1:= posedit.innerclientrect;
 with fnodeinfo do begin
  grid:= self.grid;
  posed:= self.posed;
  colored:= self.colored;
  opaed:= self.opaed;
  setlength(marker,3);
  marker[0].y:= rect1.y + rect1.cy - 1;
  marker[1].y:= marker[0].y - markerheight;
  marker[2].y:= marker[0].y;
 end;
 with fnodeinfoopa do begin
  grid:= self.opagrid;
  posed:= self.opaposed;
  colored:= self.opacolored;
  opaed:= nil;
  marker:= copy(fnodeinfo.marker);
 end;
end;

procedure tfadeeditfo.movemarker(const atag: integer; apos: integer);
begin 
 if reverse.value then begin
  apos:= posedit.paintsize.cx - apos;
 end;
 with nodeinfo(atag)^ do begin
  marker[0].x:= apos - markerhalfwidth;
  marker[1].x:= apos;
  marker[2].x:= apos + markerhalfwidth;
 end;
end;

procedure tfadeeditfo.change;
var
 rect1: rectty;

 procedure update(var anodeinfo: nodeinfoty);
 var
  int1: integer;
 begin
  with anodeinfo do begin
   if grid.rowcount < 3 then begin
    nodepos:= nil;
   end
   else begin
    setlength(nodepos,grid.rowcount - 2);
   end;
   if grid.rowcount > 0 then begin
    posed[grid.rowhigh]:= 1;
    posed[0]:= 0;
   end;
   for int1:= 1 to grid.rowcount - 2 do begin
    nodepos[int1-1]:= rect1.x + round(posed[int1] * rect1.cx);
   end;
  end;
 end;//update

var
 int1: integer;
// rea1: real;
begin
 if reverse.value then begin
  fadedisp.face.fade_direction:= gd_left;
  opadisp.face.fade_direction:= gd_left;
  fadevert.face.fade_direction:= gd_up;
 end
 else begin
  fadedisp.face.fade_direction:= gd_right;
  opadisp.face.fade_direction:= gd_right;
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
   for int1:= grid.rowhigh downto 0 do begin
    fade_pos[int1]:= posed[int1];
    fade_color[int1]:= colored[int1];
   end;
   if fopacitycleared then begin
    fade_opapos.count:= 0;
    opagrid.clear;
   end
   else begin
    fade_opapos.count:= opagrid.rowcount;
    for int1:= opagrid.rowhigh downto 0 do begin
     fade_opapos[int1]:= opaposed[int1];
     fade_opacolor[int1]:= opacolored[int1];
    end;
   end;
  end;
  fadevert.face.fade_pos.assign(fade_pos);
  fadevert.face.fade_color.assign(fade_color);
  fadevert.face.fade_opapos.assign(fade_opapos);
  fadevert.face.fade_opacolor.assign(fade_opacolor);
  opadisp.face.fade_pos.assign(fade_opapos);
  opadisp.face.fade_color.assign(fade_opacolor);
 end;
 update(fnodeinfo);
 update(fnodeinfoopa);
 posedit.invalidate;
 opaedit.invalidate;
end;

procedure tfadeeditfo.pospaintev(const sender: twidget; const canvas: tcanvas);
var
 int1: integer;
begin
 with nodeinfo(sender.tag)^ do begin
  for int1:= 0 to high(nodepos) do begin
   movemarker(sender.tag,nodepos[int1]);
   if int1 + 1 = grid.row then begin
    canvas.drawlines(marker,true,cl_red);
   end
   else begin
    canvas.drawlines(marker,true,cl_black);
   end;
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
  int1:= findmarker(sender.tag,picker.pos);
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
  int1:= findmarker(sender.tag,picker.pickrect.pos);
  if int1 >= 0 then begin
   setlength(objects,1);
   objects[0]:= int1;
  end;
 end;
end;

function tfadeeditfo.findmarker(const atag: integer; 
                                       const apos: pointty): integer;
var
 rect1: rectty;
 int1,int2,int3,int4: integer;
 xpos: integer;
begin
 with nodeinfo(atag)^ do begin
  result:= -1;
  rect1:= posedit.innerclientrect;
  int1:= rect1.y + rect1.cy;
  int4:= high(nodepos);
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
    if (nodepos[int1] >= int2) and (nodepos[int1] <= int3) and 
         not ((int1 < int4) and (nodepos[int1+1] = rect1.x)) then begin
     result:= int1;
     break;
    end;
   end;
  end;
 end;
end;

function tfadeeditfo.limitmarkerpos(const atag: integer; const index: integer;
                                               const aoffset: integer): integer;
var
 rect1: rectty;
 
begin
 with nodeinfo(atag)^ do begin
  if reverse.value then begin
   result:= nodepos[index] - aoffset;
  end
  else begin
   result:= nodepos[index] + aoffset;
  end;
  if (index > 0) and (result < nodepos[index-1]) then begin
   result:= nodepos[index-1];
  end
  else begin
   if index < high(nodepos) then begin
    if result >= nodepos[index+1] then begin
     result:= nodepos[index+1];
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
end;

procedure tfadeeditfo.paintxorev(const sender: tcustompickwidget;
                                  const picker: tobjectpicker;
                                  const canvas: tcanvas);
begin
 movemarker(sender.tag,limitmarkerpos(sender.tag,picker.currentobjects[0],
                                              picker.pickoffset.x));
 with nodeinfo(sender.tag)^ do begin
  canvas.drawlines(marker,true,cl_white);
  canvas.drawline(makepoint(marker[1].x,marker[1].y-1),
              makepoint(marker[1].x,posedit.innerclientpos.y),cl_white);
 end;
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
 with nodeinfo(sender.tag)^ do begin
  if rect1.cx = 0 then begin
   rea1:= 0;
  end
  else begin
   rea1:= (nodepos[int1] - rect1.x + offsetx) / rect1.cx;
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
 end;
 change;
end;

procedure tfadeeditfo.resizeev(const sender: TObject);
begin
 change;
end;

procedure tfadeeditfo.dataenteterev(const sender: TObject);
begin
 grid.sort;
 opagrid.sort;
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
   if tmsecomponent(sender).tag = 0 then begin
    posedit.invalidate; //redraw red marker
   end
   else begin
    opaedit.invalidate; //redraw red marker
   end;
  end;
 end;
end;

procedure tfadeeditfo.rowinsertev(const sender: tcustomgrid;
               const aindex: Integer; const acount: Integer);
begin
 if sender.userinput then begin
  with nodeinfo(sender.tag)^ do begin
   grid.beginupdate;
   if aindex < grid.rowhigh then begin
    if aindex = 0 then begin
     colored[0]:= colored[1]; //pos = 0
     if sender.tag = 0 then begin
      opaed[0]:= opaed[1]; //pos = 0
     end;
     posed[0]:= 0;
    end
    else begin
     colored[aindex]:= blendcolor(0.5,colored[aindex+1],colored[aindex-1]);
     if sender.tag = 0 then begin
      opaed[aindex]:= blendcolor(0.5,opaed[aindex+1],opaed[aindex-1]);
     end;
     posed[aindex]:= (posed[aindex+1] + posed[aindex-1]) / 2;
    end
   end
   else begin
    if grid.rowhigh = 0 then begin
     posed[aindex]:= 0;
    end
    else begin
     colored[aindex]:= colored[grid.rowhigh-1];
     if sender.tag = 0 then begin
      opaed[aindex]:= opaed[grid.rowhigh-1];
     end;
     posed[aindex]:= 1;
    end;
   end;
   grid.endupdate;
  end;
  change;
 end
 else begin
  asyncevent;
 end;
end;

procedure tfadeeditfo.beforedrawev(const sender: tcol; const canvas: tcanvas;
               var cellinfo: cellinfoty; var processed: Boolean);
begin
 if sender.grid.tag = 0 then begin
  cellinfo.color:= colorty(colortorgb(colored[cellinfo.cell.row]));
 end
 else begin
  cellinfo.color:= colorty(colortorgb(opacolored[cellinfo.cell.row]));
 end;
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

function tfadeeditfo.syncexe: boolean;

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
 result:= askyesno(
  'Do you want to synchronize opacity gradient'+lineend+
                      'with color gradient?','Confirmation');
 if result then begin
  grid.beginupdate;
  try
   fopacitycleared:= false;
   int2:= 0;
   if grid.rowcount < fadedisp.face.fade_opapos.count then begin
    if grid.rowcount = 0 then begin
     grid.rowcount:= 1;
     posed[0]:= 0;
    end;
    if (grid.rowcount < 2) and (grid.rowcount < fadedisp.face.fade_opapos.count) then begin
     grid.rowcount:= 2;
     posed[1]:= 1;
     colored[1]:= colored[0];
    end;
   end;
   for int1:= 1 to fadedisp.face.fade_opapos.count-2 do begin
    while posed[int2] < fadedisp.face.fade_opapos[int1] do begin
     inc(int2);
    end;
    if posed[int2] <> fadedisp.face.fade_opapos[int1] then begin
     grid.insertrow(int2);
     posed[int2]:= fadedisp.face.fade_opapos[int1];
     colored[int2]:= scale(posed[int2],posed[int2-1],posed[int2+1],
                            colored[int2-1],colored[int2+1]);
    end;
   end;
   int2:= 0;
   for int1:= 0 to grid.rowhigh do begin
    while (int2 < fadedisp.face.fade_opapos.count) and
                      (fadedisp.face.fade_opapos[int2] < posed[int1]) do begin
     inc(int2);
    end;
    case fadedisp.face.fade_opapos.count of
     0: begin
      opaed[int1]:= cl_white;
     end;
     1: begin
      opaed[int1]:= fadedisp.face.fade_opacolor[0];
     end;
     else begin
      if int2 >= fadedisp.face.fade_opacolor.count then begin
       opaed[int1]:= 
              fadedisp.face.fade_opacolor[fadedisp.face.fade_opacolor.count-1];
      end
      else begin
       if int2 = 0 then begin
        opaed[int1]:= 
              fadedisp.face.fade_opacolor[0];
       end
       else begin
        opaed[int1]:= scale(posed[int1],fadedisp.face.fade_opapos[int2-1],
                           fadedisp.face.fade_opapos[int2],
                           fadedisp.face.fade_opacolor[int2-1],
                           fadedisp.face.fade_opacolor[int2]);
       end;
      end;
     end;
    end;
   end;
   grid.datacols[3].visible:= true;
  finally
   grid.endupdate;
  end;
//  syncbu.enabled:= false;
  clearbu.enabled:= true;
  change;
 end;
end;

procedure tfadeeditfo.clearopaexe(const sender: TObject);
begin
 if askyesno(
  'Do you want to remove opacity gradient?','Confirmation') then begin
  fopacitycleared:= true;
  opasynced:= true;  
  grid.datacols[3].visible:= false;
  change;
  clearbu.enabled:= false;
//  syncbu.enabled:= true;
 end;
end;

procedure tfadeeditfo.setopasynced(const avalue: boolean);
var
 bo1: boolean;
 int1: integer;
begin
 fopasynced:= avalue or fopa;
 grid.datacols[3].visible:= fopasynced;
 bo1:= not fopasynced;
 opaedit.visible:= bo1;
 opagrid.visible:= bo1;
 splitter.visible:= bo1;
 if fopasynced then begin
  splitter.linktop:= nil;
  grid.height:= layouter.height;
  cont1.top:= 4;  
 end
 else begin
  fopacitycleared:= false;
  cont1.top:= opaedit.bottom+4;  
  splitter.linktop:= grid;
  opagrid.rowcount:= fadedisp.face.fade_opapos.count;
  for int1:= 0 to opagrid.rowhigh do begin
   opaposed[int1]:= fadedisp.face.fade_opapos[int1];
   opacolored[int1]:= fadedisp.face.fade_opacolor[int1];
  end;
 end;
 cont1.bottom:= cont2.height;
 grid.fixrows[-1].visible:= fopasynced;
 splitopa.value:= not fopasynced;
end;

procedure tfadeeditfo.fadestatupdateexe(const sender: TObject;
               const filer: tstatfiler);
var
 bo1: boolean;
begin
 bo1:= opasynced;
 if not filer.iswriter or fopa then begin
  bo1:= false;
 end;
 filer.updatevalue('opasynced',bo1);
 opasynced:= bo1;
end;

procedure tfadeeditfo.sepopaset(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 if (avalue = opasynced) and not avalue then begin
  accept:= syncexe;
 end;
 if accept then begin
  opasynced:= not avalue;
  if avalue then begin
   change;
  end;
 end;
end;

function tfadeeditfo.nodeinfo(const atag: integer): pnodeinfoty;
begin
 if atag = 0 then begin
  result:= @fnodeinfo;
 end
 else begin
  result:= @fnodeinfoopa;
 end;
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
