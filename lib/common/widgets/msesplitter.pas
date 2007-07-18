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
 msegui,msewidgets,mseobjectpicker,classes,msegraphutils,msepointer,msetypes,
 msestrings,msegraphics,mseevent,msestat,msestatfile,msestockobjects,mseclasses,
 msesimplewidgets,mseguiglob;
type

 splitteroptionty = (spo_hmove,spo_hprop,spo_hsizeprop,
                     spo_vmove,spo_vprop,spo_vsizeprop,
                     spo_dockleft,spo_docktop,spo_dockright,spo_dockbottom);
 splitteroptionsty = set of splitteroptionty;

const
 docksplitteroptions = [spo_dockleft,spo_docktop,spo_dockright,spo_dockbottom];
 defaultsplitteroptions = docksplitteroptions;
 defaultsplittercolor = cl_light;
 defaultsplittercolorgrip = cl_shadow;
 defaultsplittergrip = stb_dens25;
 updatepropeventtag = 0;
 retrypropeventtag = 1;

type
 tsplitter = class(tscalingwidget,iobjectpicker,istatfile)
  private
   fobjectpicker: tobjectpicker;
   foptions: splitteroptionsty;
   flinktop: twidget;
   flinkleft: twidget;
   flinkright: twidget;
   flinkbottom: twidget;
   fhprop,fvprop: real;
   fhsizeprop,fvsizeprop: real;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fcolorgrip: colorty;
   fgrip: stockbitmapty;
   fonupdatelayout: notifyeventty;
   fupdating: integer;
   fpropsetting: integer;
   fnotified: integer;
   fregionchangedcount: integer;
   fregionchangedmark: integer;
   procedure setstatfile(const avalue: tstatfile);
   procedure setlinkbottom(const avalue: twidget);
   procedure setlinkleft(const avalue: twidget);
   procedure setlinkright(const avalue: twidget);
   procedure setlinktop(const avalue: twidget);
   procedure setclippedpickoffset(const aoffset: pointty);
   procedure setpickoffset(const aoffset: pointty);
   procedure setcolorgrip(const avalue: colorty);
   procedure setgrip(const avalue: stockbitmapty);
  protected
   function getmintopleft: pointty; override;
   function clippoint(const aoffset: pointty): pointty;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure poschanged; override;
   procedure sizechanged; override;
   procedure parentclientrectchanged; override;
   procedure doasyncevent(var atag: integer); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure parentwidgetregionchanged(const sender: twidget); override;
   procedure loaded; override;
   procedure updatedock;
   procedure updatelinkedwidgets(const delta: pointty);

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   //iobjectpicker
   function getcursorshape(const apos: pointty; const shiftstate: shiftstatesty;
                                           var shape: cursorshapety): boolean;
   procedure getpickobjects(const rect: rectty; const shiftstate: shiftstatesty;
                                           var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos,offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);
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

 spaceroptionty = (spao_glueright,spao_gluebottom);
 spaceroptionsty = set of spaceroptionty;
 
 tspacer = class(tscalingwidget)
  private
   flinkleft: twidget;
   flinktop: twidget;
   flinkright: twidget;
   flinkbottom: twidget;
   fupdating: integer;
   foffset_left: integer;
   foffset_top: integer;
   foffset_right: integer;
   foffset_bottom: integer;
   foptions: spaceroptionsty;
   procedure setlinkleft(const avalue: twidget);
   procedure setlinktop(const avalue: twidget);
   procedure setlinkright(const avalue: twidget);
   procedure setlinkbottom(const avalue: twidget);
   procedure updatespace;
   procedure setoffset_left(const avalue: integer);
   procedure setoffset_top(const avalue: integer);
   procedure setoffset_right(const avalue: integer);
   procedure setoffset_bottom(const avalue: integer);
  protected
   procedure loaded; override;
   procedure parentwidgetregionchanged(const sender: twidget); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property linkleft: twidget read flinkleft write setlinkleft;
   property linktop: twidget read flinktop write setlinktop;
   property linkright: twidget read flinkright write setlinkright;
   property linkbottom: twidget read flinkbottom write setlinkbottom;
   property offset_left: integer read foffset_left 
                                    write setoffset_left default 0;
   property offset_top: integer read foffset_top 
                                    write setoffset_top default 0;
   property offset_right: integer read foffset_right 
                                    write setoffset_right default 0;
   property offset_bottom: integer read foffset_bottom 
                                    write setoffset_bottom default 0;
   property options: spaceroptionsty read foptions write foptions default [];
   property optionswidget default defaultoptionswidgetnofocus;
   property visible default false;
 end;
 
implementation

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

function tsplitter.getcursorshape(const apos: pointty; const shiftstate: shiftstatesty;
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

procedure tsplitter.getpickobjects(const rect: rectty; const shiftstate: shiftstatesty;
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
 {
  result:= subpoint(
            clipinrect(
              makerect(addpoint(aoffset,fwidgetrect.pos),fwidgetrect.size),
                 twidget1(fparentwidget).paintrect).pos,fwidgetrect.pos);
                 }
  result:= subpoint(
            clipinrect(
              makerect(addpoint(aoffset,fwidgetrect.pos),fwidgetrect.size),
                 twidget1(fparentwidget).clientwidgetrect).pos,fwidgetrect.pos);
 end
 else begin
  result:= aoffset;
 end;
 if [spo_hmove,spo_hprop] * foptions = [] then begin
  result.x:= 0;
 end;
 if [spo_vmove,spo_vprop] * foptions = [] then begin
  result.y:= 0;
 end;
 if flinkleft <> flinkright then begin
  if (flinkleft <> nil)  then begin
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
 end;
 if flinktop <> flinkbottom then begin
  if (flinktop <> nil) then begin
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
 inc(fupdating);
 try
  if flinkleft = flinkright then begin
   if flinkright <> nil then begin
    flinkright.bounds_x:= flinkright.bounds_x + delta.x;
   end;
  end
  else begin
   if flinkleft <> nil then begin
    flinkleft.bounds_cx:= flinkleft.bounds_cx + delta.x;
   end;
   if flinkright <> nil then begin
    rect1:= twidget1(flinkright).fwidgetrect;
    rect1.x:= rect1.x + delta.x;
    rect1.cx:= rect1.cx - delta.x;
    flinkright.widgetrect:= rect1;
   end;
  end;
  if flinktop = flinkbottom then begin
   if flinkbottom <> nil then begin
    flinkbottom.bounds_y:= flinkbottom.bounds_y + delta.y;
   end;
  end
  else begin
   if flinktop <> nil then begin
    flinktop.bounds_cy:= flinktop.bounds_cy + delta.y;
   end;
   if flinkbottom <> nil then begin
    rect1:= twidget1(flinkbottom).fwidgetrect;
    rect1.y:= rect1.y + delta.y;
    rect1.cy:= rect1.cy - delta.y;
    flinkbottom.widgetrect:= rect1;
   end;
  end;
  if canevent(tmethod(fonupdatelayout)) then begin
   fonupdatelayout(self);
  end;
 finally
  dec(fupdating);
 end;
end;

procedure tsplitter.setclippedpickoffset(const aoffset: pointty);
begin
 inc(fupdating);
 try
  self.pos:= addpoint(self.pos,aoffset);
 finally
  dec(fupdating);
 end;
 updatelinkedwidgets(aoffset);
end;

procedure tsplitter.setpickoffset(const aoffset: pointty);
begin
 setclippedpickoffset(clippoint(aoffset));
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

procedure tsplitter.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

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

procedure tsplitter.setlinkbottom(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkbottom));
 updatedock;
end;

procedure tsplitter.setlinkleft(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkleft));
 updatedock;
end;

procedure tsplitter.setlinkright(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkright));
 updatedock;
end;

procedure tsplitter.setlinktop(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinktop));
 updatedock;
end;

procedure tsplitter.poschanged;
var
 int1: integer;
begin
 inherited;
 if (fparentwidget <> nil) then begin
  if not (csloading in componentstate) and (fpropsetting = 0) then begin
   fhprop:= 0;
   fvprop:= 0;
   int1:= fparentwidget.clientsize.cx;
   if (int1 > 0) then begin
    fhprop:= parentclientpos.x / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
   end;
   int1:= fparentwidget.clientsize.cy;
   if (int1 > 0) then begin
    fvprop:= parentclientpos.y / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
   end;
  end;
 end;
end;

procedure tsplitter.sizechanged;
var
 int1: integer;
begin
 inherited;
 if (fparentwidget <> nil) then begin
  if not (csloading in componentstate) and (fpropsetting = 0) then begin
   fhsizeprop:= 0;
   fvsizeprop:= 0;
   int1:= fparentwidget.clientsize.cx;
   if (int1 > 0) then begin
    fhsizeprop:= fwidgetrect.cx / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
   end;
   int1:= fparentwidget.clientsize.cy;
   if (int1 > 0) then begin
    fvsizeprop:= fwidgetrect.cy / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
   end;
  end;
 end;
end;

procedure tsplitter.doasyncevent(var atag: integer);
var
 pt1,pt2: pointty;
 size2: sizety;
 
 procedure calcoffset;
 var
  size1: sizety;
 begin
  size1:= fparentwidget.clientsize;
  pt1:= nullpoint;
  size2:= size;
  if spo_hsizeprop in foptions then begin
   size2.cx:= round(size1.cx * fhsizeprop);
  end;
  if spo_vsizeprop in foptions then begin
   size2.cy:= round(size1.cy * fvsizeprop);
  end;
  if spo_hprop in foptions then begin
   pt1.x:= round(fhprop * size1.cx) - parentclientpos.x;
  end;
  if spo_vprop in foptions then begin
   pt1.y:= round(fvprop * size1.cy) - parentclientpos.y;
  end;
  pt2:= clippoint(pt1);
 end;
  
begin //doasyncevent
 inherited;
 case atag of
  updatepropeventtag,retrypropeventtag: begin
   if atag = updatepropeventtag then begin
    dec(fnotified);
   end;
   try
    if fparentwidget <> nil then begin
     calcoffset;
     if (([spo_hmove,spo_hprop] * foptions <> []) and (pt1.x <> pt2.x) or 
         ([spo_vmove,spo_vprop] * foptions <> []) and (pt1.y <> pt2.y)) and
        (fregionchangedmark <> fregionchangedcount) then begin
      fregionchangedmark:= fregionchangedcount;
      inc(fupdating);
      asyncevent(retrypropeventtag);
     end
     else begin
      inc(fpropsetting);
      try
       setclippedpickoffset(pt2);
       size:= size2;
      finally
       dec(fpropsetting);
      end;
     end;
    end;
   finally
    if atag = retrypropeventtag then begin
     dec(fupdating);
     if fupdating = 0 then begin
      updatedock;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsplitter.parentclientrectchanged;
begin
 inherited;
 if (componentstate * [csloading,csdesigning] = []) and
              (fparentwidget <> nil) and (fnotified = 0) then begin
  inc(fnotified);
  asyncevent(updatepropeventtag);
 end;
end;

procedure tsplitter.setcolorgrip(const avalue: colorty);
begin
 if fcolorgrip <> avalue then begin
  fcolorgrip:= avalue;
  invalidate;
 end;
end;

procedure tsplitter.setgrip(const avalue: stockbitmapty);
begin
 if fgrip <> avalue then begin
  fgrip:= avalue;
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
 end;
end;

procedure tsplitter.parentwidgetregionchanged(const sender: twidget);
begin
 inc(fregionchangedcount);
 inherited;
 if (sender <> nil) and ((sender = flinkleft) or (sender = flinktop) or
                         (sender = flinkright) or (sender = flinkbottom) or
                         (sender = self)) then begin
  updatedock;
 end;
end;

procedure tsplitter.loaded;
begin
 inherited;
 updatedock;
end;

procedure tsplitter.updatedock;
var
 po1: pointty;
 rect1: rectty;
begin
 if (componentstate * [csloading,csdestroying] = []) and 
             (foptions * docksplitteroptions <> []) and
             (fparentwidget <> nil) and (fupdating = 0) then begin
  inc(fupdating);
  po1:= addpoint(pos,pointty(size));
  try  
   if flinkleft = flinkright then begin
    if flinkleft <> nil then begin
     flinkleft.widgetrect:= makerect(bounds_x,flinkleft.bounds_y,bounds_cx,
                                         flinkleft.bounds_cy);
    end;
   end
   else begin
    if flinkleft <> nil then begin
     flinkleft.bounds_cx:= bounds_x - flinkleft.bounds_x;
    end;
    if flinkright <> nil then begin
     rect1:= flinkright.widgetrect;
     rect1.cx:= rect1.cx + (rect1.x - po1.x);
     rect1.pos.x:= po1.x;
     flinkright.widgetrect:= rect1;
    end;
   end;
   if flinktop = flinkbottom then begin
    if flinktop <> nil then begin
     flinktop.widgetrect:= makerect(flinktop.bounds_x,bounds_y,
                                       flinktop.bounds_cx,bounds_cy);
    end;
   end
   else begin
    if flinktop <> nil then begin
     flinktop.bounds_cy:= bounds_y - flinktop.bounds_y;
    end;
    if flinkbottom <> nil then begin
     rect1:= flinkbottom.widgetrect;
     rect1.cy:= rect1.cy + (rect1.y - po1.y);
     rect1.pos.y:= po1.y;
     flinkbottom.widgetrect:= rect1;
    end;
   end;
  finally
   dec(fupdating);
  end;
 end;
end;

function tsplitter.getmintopleft: pointty;
var
 int1: integer;
begin
 result:= fwidgetrect.pos;
 if flinkleft <> nil then begin
  result.x:= result.x - flinkleft.bounds_cx + flinkleft.bounds_cxmin;
 end;
 if flinktop <> nil then begin
  result.y:= result.y - flinktop.bounds_cy + flinktop.bounds_cymin;
 end;
end;

{ tspacer }

constructor tspacer.create(aowner: tcomponent);
begin
 inherited;
 foptionswidget:= defaultoptionswidgetnofocus;
 fwidgetstate:= fwidgetstate - (defaultwidgetstates-defaultwidgetstatesinvisible);
end;

procedure tspacer.setlinkleft(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkleft));
 updatespace;
end;

procedure tspacer.setlinktop(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinktop));
 updatespace;
end;

procedure tspacer.setlinkright(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkright));
 updatespace;
end;

procedure tspacer.setlinkbottom(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkbottom));
 updatespace;
end;

procedure tspacer.setoffset_left(const avalue: integer);
begin
 foffset_left:= avalue;
 updatespace;
end;

procedure tspacer.setoffset_top(const avalue: integer);
begin
 foffset_top:= avalue;
 updatespace;
end;

procedure tspacer.setoffset_right(const avalue: integer);
begin
 foffset_right:= avalue;
 updatespace;
end;

procedure tspacer.setoffset_bottom(const avalue: integer);
begin
 foffset_bottom:= avalue;
 updatespace;
end;

procedure tspacer.updatespace;
var
 po1: pointty;
 rect1: rectty;
begin
 if (componentstate * [csloading,csdestroying] = []) and 
    (fparentwidget <> nil) and (fupdating = 0) then begin
  inc(fupdating);
  try  
   po1:= pos;
   if spao_glueright in foptions then begin
    if flinkright <> nil then begin
     po1.x:= flinkright.bounds_x - bounds_cx - foffset_right;
    end;
   end
   else begin
    if flinkleft <> nil then begin
     po1.x:= flinkleft.bounds_x + flinkleft.bounds_cx + foffset_left;
    end;
   end;
   if spao_gluebottom in foptions then begin
    if flinkbottom <> nil then begin
     po1.y:= flinkbottom.bounds_y - bounds_cy - foffset_bottom;
    end;
   end
   else begin
    if flinktop <> nil then begin
     po1.y:= flinktop.bounds_y + flinktop.bounds_cy + foffset_top;
    end;
   end;
   pos:= po1;
   addpoint1(po1,pointty(size));
   po1.x:= po1.x + foffset_right;
   po1.y:= po1.y + foffset_bottom;
   if spao_glueright in foptions then begin
    if flinkleft <> nil then begin
     rect1:= flinkleft.widgetrect;
     if an_left in flinkleft.anchors then begin
      rect1.cx:= bounds_x - foffset_left - flinkleft.bounds_x;
     end
     else begin
      rect1.x:= bounds_x - foffset_left - flinkleft.bounds_cx;
     end;
     flinkleft.widgetrect:= rect1;
    end;
   end
   else begin
    if flinkright <> nil then begin
     rect1:= flinkright.widgetrect;
     if an_right in flinkright.anchors then begin
      rect1.cx:= rect1.cx + (rect1.x - po1.x);
     end;
     rect1.pos.x:= po1.x;
     flinkright.widgetrect:= rect1;
    end;
   end;
   if spao_gluebottom in foptions then begin
    if flinktop <> nil then begin
     rect1:= flinktop.widgetrect;
     if an_top in flinktop.anchors then begin
      rect1.cy:= bounds_y - foffset_top - flinktop.bounds_y;
     end
     else begin
      rect1.y:= bounds_y - foffset_top - flinktop.bounds_cy;
     end;
     flinktop.widgetrect:= rect1;
    end;
   end
   else begin
    if flinkbottom <> nil then begin
     rect1:= flinkbottom.widgetrect;
     if an_bottom in flinkbottom.anchors then begin
      rect1.cy:= rect1.cy + (rect1.y - po1.y);
     end;
     rect1.pos.y:= po1.y;
     flinkbottom.widgetrect:= rect1;
    end;
   end;
  finally
   dec(fupdating);
  end;
 end;
end;

procedure tspacer.loaded;
begin
 inherited;
 updatespace;
end;

procedure tspacer.parentwidgetregionchanged(const sender: twidget);
begin
 inherited;
 if (sender <> nil) and ((sender = flinkleft) or (sender = flinktop) or
                         (sender = flinkright) or (sender = flinkbottom) or
                         (sender = self)) then begin
  updatespace;
 end;
end;

end.
