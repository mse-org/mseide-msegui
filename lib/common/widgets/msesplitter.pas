{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesplitter;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,msewidgets,mseobjectpicker,classes,msegraphutils,msepointer,msetypes,msestrings,
 msegraphics,mseevent,msestat,msestockobjects,mseclasses;
type

 splitteroptionty = (spo_hmove,spo_hprop,spo_vmove,spo_vprop);
 splitteroptionsty = set of splitteroptionty;

const
 defaultsplitteroptions = [];
 defaultsplittercolor = cl_light;
 defaultsplittercolorgrip = cl_shadow;
 defaultsplittergrip = stb_dens25;
 updatepropeventtag = 0;

type
 tsplitter = class(tpublishedwidget,iobjectpicker,istatfile)
  private
   fobjectpicker: tobjectpicker;
   foptions: splitteroptionsty;
   flinktop: twidget;
   flinkleft: twidget;
   flinkright: twidget;
   flinkbottom: twidget;
   fhprop,fvprop: real;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fcolorgrip: colorty;
   fgrip: stockbitmapty;
   fonupdatelayout: notifyeventty;
   procedure setstatfile(const Value: tstatfile);
   procedure setlinkbottom(const Value: twidget);
   procedure setlinkleft(const Value: twidget);
   procedure setlinkright(const Value: twidget);
   procedure setlinktop(const Value: twidget);
   procedure setpickoffset(const aoffset: pointty);
   procedure setcolorgrip(const Value: colorty);
   procedure setgrip(const Value: stockbitmapty);
  protected
   function clippoint(const aoffset: pointty): pointty;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure poschanged; override;
   procedure parentclientrectchanged; override;
   procedure doasyncevent(var atag: integer); override;
   procedure dopaint(const acanvas: tcanvas); override;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   //iobjectpicker
   function getcursorshape(const apos: pointty; var shape: cursorshapety): boolean;
   procedure getpickobjects(const rect: rectty; var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos,offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);
   procedure updatelinkedwidgets(const delta: pointty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure move(const dist: pointty);
  published
   property optionswidget default defaultoptionswidgetnofocus;
   property options: splitteroptionsty read foptions write foptions default defaultsplitteroptions;
   property linkleft: twidget read flinkleft write setlinkleft;
   property linktop: twidget read flinktop write setlinktop;
   property linkright: twidget read flinkright write setlinkright;
   property linkbottom: twidget read flinkbottom write setlinkbottom;

   property color default defaultsplittercolor;
   property grip: stockbitmapty read fgrip write setgrip default defaultsplittergrip;
   property colorgrip: colorty read fcolorgrip write setcolorgrip default defaultsplittercolorgrip;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property onupdatelayout: notifyeventty read fonupdatelayout write fonupdatelayout;
 end;

implementation
uses
 mseguiglob;

type
 twidget1 = class(twidget);

{ tsplitter }

constructor tsplitter.create(aowner: tcomponent);
begin
 foptions:= defaultsplitteroptions;
 fcolorgrip:= defaultsplittercolorgrip;
 fgrip:= defaultsplittergrip;
 inherited;
 color:= defaultsplittercolor;
 optionswidget:= defaultoptionswidgetnofocus;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self),org_widget);
end;

destructor tsplitter.destroy;
begin
 fobjectpicker.Free;
 inherited;
end;

procedure tsplitter.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  fobjectpicker.mouseevent(info);
 end;
end;

procedure tsplitter.beginpickmove(const objects: integerarty);
begin
 //dummy
end;

function tsplitter.getcursorshape(const apos: pointty;
  var shape: cursorshapety): boolean;
begin
 result:= not (csdesigning in componentstate) and
                pointinrect(apos,makerect(nullpoint,fwidgetrect.size));
 if result then begin
  if spo_hmove in foptions then begin
   if spo_vmove in foptions then begin
    shape:= cr_sizeall;
   end
   else begin
    shape:= cr_sizehor;
   end;
  end
  else begin
   if spo_vmove in foptions then begin
    shape:= cr_sizever;
   end
   else begin
    result:= false;
   end;
  end;
 end;
end;

procedure tsplitter.getpickobjects(const rect: rectty;
  var objects: integerarty);
begin
 if (foptions * [spo_hmove,spo_vmove] <> []) and
            not (csdesigning in componentstate) then begin
  setlength(objects,1);
 end;
end;

function tsplitter.clippoint(const aoffset: pointty): pointty;
begin
 if fparentwidget <> nil then begin
  result:= subpoint(
            clipinrect(
              makerect(addpoint(aoffset,fwidgetrect.pos),fwidgetrect.size),
                 twidget1(fparentwidget).paintrect).pos,fwidgetrect.pos);
 end
 else begin
  result:= aoffset;
 end;
 if not (spo_hmove in foptions) then begin
  result.x:= 0;
 end;
 if not (spo_vmove in foptions) then begin
  result.y:= 0;
 end;
 if flinkleft <> nil then begin
  with twidget1(flinkleft) do begin
   if fwidgetrect.cx + result.x < bounds_cxmin then begin
    result.x:= bounds_cxmin - fwidgetrect.cx;
   end;
   if bounds_cxmax > 0 then begin
    if fwidgetrect.cx + result.x > bounds_cxmax then begin
     result.x:= bounds_cxmax - fwidgetrect.cx;
    end;
   end;
  end;
 end;
 if flinktop <> nil then begin
  with twidget1(flinktop) do begin
   if fwidgetrect.cy + result.y < bounds_cymin then begin
    result.y:= bounds_cymin - fwidgetrect.cy;
   end;
   if bounds_cymax > 0 then begin
    if fwidgetrect.cy + result.y > bounds_cymax then begin
     result.y:= bounds_cymax - fwidgetrect.cy;
    end;
   end;
  end;
 end;
 if flinkright <> nil then begin
  with twidget1(flinkright) do begin
   if fwidgetrect.cx - result.x < bounds_cxmin then begin
    result.x:= - (bounds_cxmin - fwidgetrect.cx);
   end;
   if bounds_cxmax > 0 then begin
    if fwidgetrect.cx - result.x > bounds_cxmax then begin
     result.x:= - (bounds_cxmax - fwidgetrect.cx);
    end;
   end;
  end;
 end;
 if flinkbottom <> nil then begin
  with twidget1(flinkbottom) do begin
   if fwidgetrect.cy - result.y < bounds_cymin then begin
    result.y:= - (bounds_cymin - fwidgetrect.cy);
   end;
   if bounds_cymax > 0 then begin
    if fwidgetrect.cy - result.y > bounds_cymax then begin
     result.y:= - (bounds_cymax - fwidgetrect.cy);
    end;
   end;
  end;
 end;
end;

procedure tsplitter.paintxorpic(const canvas: tcanvas; const apos,
  offset: pointty; const objects: integerarty);
begin
 if fparentwidget <> nil then begin
  canvas.addcliprect(makerect(-fwidgetrect.x,-fwidgetrect.y,
    twidget1(fparentwidget).fwidgetrect.cx,
    twidget1(fparentwidget).fwidgetrect.cy));
 end;
 canvas.drawxorframe(makerect(clippoint(offset),fwidgetrect.size),-4,
            stockobjects.bitmaps[stb_dens25]);
end;

procedure tsplitter.updatelinkedwidgets(const delta: pointty);
var
 rect1: rectty;
begin
 if flinkleft <> nil then begin
  flinkleft.bounds_cx:= flinkleft.bounds_cx + delta.x;
 end;
 if flinkright <> nil then begin
  rect1:= twidget1(flinkright).fwidgetrect;
  rect1.x:= rect1.x + delta.x;
//  if an_right in flinkbottom.anchors then begin
   rect1.cx:= rect1.cx - delta.x;
//  end;
  flinkright.widgetrect:= rect1;
 end;
 if flinktop <> nil then begin
  flinktop.bounds_cy:= flinktop.bounds_cy + delta.y;
 end;
 if flinkbottom <> nil then begin
  rect1:= twidget1(flinkbottom).fwidgetrect;
  rect1.y:= rect1.y + delta.y;
//  if an_bottom in flinkbottom.anchors then begin
   rect1.cy:= rect1.cy - delta.y;
//  end;
  flinkbottom.widgetrect:= rect1;
 end;
 if canevent(tmethod(fonupdatelayout)) then begin
  fonupdatelayout(self);
 end;
end;

procedure tsplitter.setpickoffset(const aoffset: pointty);
var
 po1: pointty;
begin
 po1:= clippoint(aoffset);
 self.pos:= addpoint(self.pos,po1);
 updatelinkedwidgets(po1);
end;

procedure tsplitter.move(const dist: pointty);
begin
 setpickoffset(dist);
end;

procedure tsplitter.endpickmove(const apos, offset: pointty;
  const objects: integerarty);
begin
 setpickoffset(offset);
end;

procedure tsplitter.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

   //istatfile
procedure tsplitter.dostatread(const reader: tstatreader);
var
 po1,po2: pointty;
begin
 po1:= parentclientpos;
 if spo_hmove in foptions then begin
  po2.x:= reader.readinteger('x',po1.x);
 end
 else begin
  po2.x:= po1.x;
 end;
 if spo_vmove in foptions then begin
  po2.y:= reader.readinteger('y',po1.y);
 end
 else begin
  po2.y:= po1.y;
 end;
 setpickoffset(subpoint(po2,po1));
end;

procedure tsplitter.dostatwrite(const writer: tstatwriter);
var
 po1: pointty;
begin
 po1:= parentclientpos;
 writer.writeinteger('x',po1.x);
 writer.writeinteger('y',po1.y);
end;

procedure tsplitter.statreading;
begin
 //dummy
end;

procedure tsplitter.statread;
begin
 //dummy
end;

function tsplitter.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tsplitter.setlinkbottom(const Value: twidget);
begin
 setlinkedvar(Value,tmsecomponent(flinkbottom));
end;

procedure tsplitter.setlinkleft(const Value: twidget);
begin
 setlinkedvar(Value,tmsecomponent(flinkleft));
end;

procedure tsplitter.setlinkright(const Value: twidget);
begin
 setlinkedvar(Value,tmsecomponent(flinkright));
end;

procedure tsplitter.setlinktop(const Value: twidget);
begin
 setlinkedvar(Value,tmsecomponent(flinktop));
end;

procedure tsplitter.poschanged;
var
 int1: integer;
begin
 inherited;
 if (fparentwidget <> nil) then begin
  if not (csloading in componentstate) then begin
   int1:= fparentwidget.clientsize.cx;
   if (int1 > 0) then begin
    fhprop:= parentclientpos.x / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
   end
   else begin
    fhprop:= 0;
   end;

   int1:= fparentwidget.clientsize.cy;
   if (int1 > 0) then begin
    fvprop:= parentclientpos.y / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
   end
   else begin
    fvprop:= 0;
   end;
  end;
 end
 else begin
  fhprop:= 0;
  fvprop:= 0;
 end;
end;

procedure tsplitter.doasyncevent(var atag: integer);
var
 po1: pointty;
 size1: sizety;
begin
 inherited;
 case atag of
  updatepropeventtag: begin
   if fparentwidget <> nil then begin
    size1:= fparentwidget.clientsize;
    po1:= nullpoint;
    if spo_hprop in foptions then begin
     po1.x:= round(fhprop * size1.cx) - parentclientpos.x;
    end;
    if spo_vprop in foptions then begin
     po1.y:= round(fvprop * size1.cy) - parentclientpos.y;
    end;
    setpickoffset(po1);
   end;
  end;
 end;
end;

procedure tsplitter.parentclientrectchanged;
begin
 inherited;
 if (componentstate * [csloading,csdesigning] = []) and
              (fparentwidget <> nil) then begin
  asyncevent(updatepropeventtag);
 end;
end;

procedure tsplitter.setcolorgrip(const Value: colorty);
begin
 if fcolorgrip <> value then begin
  fcolorgrip:= Value;
  invalidate;
 end;
end;

procedure tsplitter.setgrip(const Value: stockbitmapty);
begin
 if fgrip <> value then begin
  fgrip:= Value;
  invalidate;
 end;
end;

procedure tsplitter.dopaint(const acanvas: tcanvas);
begin
 inherited;
 if fgrip <> stb_none then begin
  with acanvas do begin
   brush:= stockobjects.bitmaps[fgrip];
   color:= fcolorgrip;
   fillrect(innerclientrect,cl_brushcanvas);
  end;
//  stockobjects.bitmaps[fgrip].paint(acanvas,clientrect,
//         [al_xcentered,al_ycentered,al_tiled],fcolorgrip,cl_transparent);
 end;
end;

end.
