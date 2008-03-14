{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

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
 msesimplewidgets,mseguiglob,msemenus;
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
   frefrect: rectty;
   procedure setstatfile(const avalue: tstatfile);
   procedure setlinkbottom(const avalue: twidget);
   procedure setlinkleft(const avalue: twidget);
   procedure setlinkright(const avalue: twidget);
   procedure setlinktop(const avalue: twidget);
   procedure setclippedpickoffset(const aoffset: pointty);
   procedure setpickoffset(const aoffset: pointty);
   procedure setcolorgrip(const avalue: colorty);
   procedure setgrip(const avalue: stockbitmapty);
   procedure setoptions(const avalue: splitteroptionsty);
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
   property options: splitteroptionsty read foptions write setoptions 
                 default defaultsplitteroptions;
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
   fdist_left: integer;
   fdist_top: integer;
   fdist_right: integer;
   fdist_bottom: integer;
   foptions: spaceroptionsty;
   procedure setlinkleft(const avalue: twidget);
   procedure setlinktop(const avalue: twidget);
   procedure setlinkright(const avalue: twidget);
   procedure setlinkbottom(const avalue: twidget);
   procedure updatespace;
   procedure setdist_left(const avalue: integer);
   procedure setdist_top(const avalue: integer);
   procedure setdist_right(const avalue: integer);
   procedure setdist_bottom(const avalue: integer);
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
   property dist_left: integer read fdist_left 
                                    write setdist_left default 0;
   property dist_top: integer read fdist_top 
                                    write setdist_top default 0;
   property dist_right: integer read fdist_right 
                                    write setdist_right default 0;
   property dist_bottom: integer read fdist_bottom 
                                    write setdist_bottom default 0;
   property options: spaceroptionsty read foptions write foptions default [];
   property optionswidget default defaultoptionswidgetnofocus;
   property visible default false;
 end;

 layoutoptionty = (lao_alignx,lao_placex,lao_aligny,lao_placey);
 layoutoptionsty = set of layoutoptionty; 
const
 defaultlayoutoptions = [];

type  
 placeoptionty = (plo_noinvisible,
                  plo_endmargin,plo_propmargin,plo_syncmaxautosize,
                  plo_synccaptiondistx,plo_synccaptiondisty,
                  plo_syncpaintwidth,plo_syncpaintheight);
 placeoptionsty = set of placeoptionty;
 
 tlayouter = class(tspacer)
  private
   foptionslayout: layoutoptionsty;
   flayoutupdating: integer;
   falign_mode: widgetalignmodety;
   falign_leader: twidget;
   fplace_mindist: integer;
   fplace_maxdist: integer;
   falign_glue: widgetalignmodety;
   fplace_mode: widgetalignmodety;
   fplace_options: placeoptionsty;
   procedure setoptionslayout(const avalue: layoutoptionsty);
   procedure setalign_mode(const avalue: widgetalignmodety);
   procedure setalign_leader(const avalue: twidget);
   procedure setplace_mindist(const avalue: integer);
   procedure setplace_maxdist(const avalue: integer);
   procedure setalign_glue(const avalue: widgetalignmodety);
   procedure setplace_mode(const avalue: widgetalignmodety);
   procedure setplace_options(const avalue: placeoptionsty);
  protected
   function childrenleft: integer;
   function childrentop: integer;
   function childrenright: integer;
   function childrenbottom: integer;
   function childrenwidth: integer;
   function childrenheight: integer;
   procedure updatelayout;
   procedure loaded; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure childautosizechanged(const sender: twidget); override;
   procedure clientrectchanged; override;
   function calcminscrollsize: sizety; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property optionslayout: layoutoptionsty read foptionslayout write setoptionslayout
                           default defaultlayoutoptions;
   property align_mode: widgetalignmodety read falign_mode write setalign_mode
                                     default wam_center;
   property align_leader: twidget read falign_leader write setalign_leader;
   property align_glue: widgetalignmodety read falign_glue write setalign_glue
                                 default wam_none;
   property place_mindist: integer read fplace_mindist write setplace_mindist;
   property place_maxdist: integer read fplace_maxdist write setplace_maxdist
                                     default bigint;
   property place_mode: widgetalignmodety read fplace_mode write setplace_mode 
                                     default wam_start;
   property place_options: placeoptionsty read fplace_options 
                                     write setplace_options default [];
   property optionswidget default defaultgroupboxoptionswidget;
   property visible default true;
 end;
 
implementation
uses
 msebits;
type
 twidget1 = class(twidget);

{ tsplitter }

constructor tsplitter.create(aowner: tcomponent);
begin
 foptions:= defaultsplitteroptions;
 fcolorgrip:= defaultsplittercolorgrip;
 fgrip:= defaultsplittergrip;
 frefrect.x:= -bigint;
 frefrect.y:= -bigint;
 frefrect.cx:= -bigint;
 frefrect.cy:= -bigint;
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
   if fwidgetrect.x <> frefrect.x then begin
    frefrect.x:= fwidgetrect.x;
    fhprop:= 0;
    int1:= fparentwidget.clientsize.cx;
    if (int1 > 0) then begin
     fhprop:= parentclientpos.x / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
    end;
   end;
   if fwidgetrect.y <> frefrect.y then begin
    frefrect.y:= fwidgetrect.y;
    fvprop:= 0;
    int1:= fparentwidget.clientsize.cy;
    if (int1 > 0) then begin
     fvprop:= parentclientpos.y / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
    end;
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
   if fwidgetrect.cx <> frefrect.cx then begin
    frefrect.cx:= fwidgetrect.cx;
    fhsizeprop:= 0;
    int1:= fparentwidget.clientsize.cx;
    if (int1 > 0) then begin
     fhsizeprop:= fwidgetrect.cx / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
    end;
   end;
   if fwidgetrect.cy <> frefrect.cy then begin
    frefrect.cy:= fwidgetrect.cy;
    fvsizeprop:= 0;
    int1:= fparentwidget.clientsize.cy;
    if (int1 > 0) then begin
     fvsizeprop:= fwidgetrect.cy / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
    end;
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
   if an_right in fanchors then begin
    pt1.x:= bounds_cx - size2.cx;
   end;
  end;
  if spo_vsizeprop in foptions then begin
   size2.cy:= round(size1.cy * fvsizeprop);
   if an_bottom in fanchors then begin
    pt1.y:= bounds_cy - size2.cy;
   end;
  end;
  if spo_hprop in foptions then begin
   pt1.x:= pt1.x + round(fhprop * size1.cx) - parentclientpos.x;
  end;
  if spo_vprop in foptions then begin
   pt1.y:= pt1.y + round(fvprop * size1.cy) - parentclientpos.y;
  end;
  pt2:= clippoint(pt1);
//  pt2:= pt1;
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
       size:= size2;
       setclippedpickoffset(pt2);
       frefrect:= fwidgetrect;
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
   if (flinkleft = flinkright) and 
        (foptions * [spo_dockleft,spo_dockright] = 
                           [spo_dockleft,spo_dockright])then begin
    if flinkleft <> nil then begin
     flinkleft.widgetrect:= makerect(bounds_x,flinkleft.bounds_y,bounds_cx,
                                         flinkleft.bounds_cy);
    end;
   end
   else begin
    if (flinkleft <> nil) and (spo_dockleft in foptions) then begin
     flinkleft.bounds_cx:= bounds_x - flinkleft.bounds_x;
    end;
    if (flinkright <> nil) and (spo_dockright in foptions) then begin
     rect1:= flinkright.widgetrect;
     rect1.cx:= rect1.cx + (rect1.x - po1.x);
     rect1.pos.x:= po1.x;
     flinkright.widgetrect:= rect1;
    end;
   end;
   if (flinktop = flinkbottom) and 
        (foptions * [spo_docktop,spo_dockbottom] = 
                           [spo_docktop,spo_dockbottom]) then begin
    if flinktop <> nil then begin
     flinktop.widgetrect:= makerect(flinktop.bounds_x,bounds_y,
                                       flinktop.bounds_cx,bounds_cy);
    end;
   end
   else begin
    if (flinktop <> nil) and (spo_docktop in foptions) then begin
     flinktop.bounds_cy:= bounds_y - flinktop.bounds_y;
    end;
    if (flinkbottom <> nil)  and (spo_dockbottom in foptions) then begin
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
 end
 else begin
  if spo_hprop in foptions then begin
   result.x:= 0;
  end;
 end;
 if flinktop <> nil then begin
  result.y:= result.y - flinktop.bounds_cy + flinktop.bounds_cymin;
 end
 else begin
  if spo_vprop in foptions then begin
   result.y:= 0;
  end;
 end;
end;

procedure tsplitter.setoptions(const avalue: splitteroptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  updatedock;
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

procedure tspacer.setdist_left(const avalue: integer);
begin
 fdist_left:= avalue;
 updatespace;
end;

procedure tspacer.setdist_top(const avalue: integer);
begin
 fdist_top:= avalue;
 updatespace;
end;

procedure tspacer.setdist_right(const avalue: integer);
begin
 fdist_right:= avalue;
 updatespace;
end;

procedure tspacer.setdist_bottom(const avalue: integer);
begin
 fdist_bottom:= avalue;
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
     po1.x:= flinkright.bounds_x - bounds_cx - fdist_right;
    end;
   end
   else begin
    if flinkleft <> nil then begin
     po1.x:= flinkleft.bounds_x + flinkleft.bounds_cx + fdist_left;
    end;
   end;
   if spao_gluebottom in foptions then begin
    if flinkbottom <> nil then begin
     po1.y:= flinkbottom.bounds_y - bounds_cy - fdist_bottom;
    end;
   end
   else begin
    if flinktop <> nil then begin
     po1.y:= flinktop.bounds_y + flinktop.bounds_cy + fdist_top;
    end;
   end;
   pos:= po1;
   addpoint1(po1,pointty(size));
   po1.x:= po1.x + fdist_right;
   po1.y:= po1.y + fdist_bottom;
   if spao_glueright in foptions then begin
    if flinkleft <> nil then begin
     rect1:= flinkleft.widgetrect;
     if an_left in flinkleft.anchors then begin
      rect1.cx:= bounds_x - fdist_left - flinkleft.bounds_x;
     end
     else begin
      rect1.x:= bounds_x - fdist_left - flinkleft.bounds_cx;
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
      rect1.cy:= bounds_y - fdist_top - flinktop.bounds_y;
     end
     else begin
      rect1.y:= bounds_y - fdist_top - flinktop.bounds_cy;
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

{ tlayouter }

constructor tlayouter.create(aowner: tcomponent);
begin
 foptionslayout:= defaultlayoutoptions;
 falign_mode:= wam_center;
// faligny_mode:= wam_center;
 fplace_maxdist:= bigint;
 fplace_mode:= wam_start;
// fplacey_maxdist:= bigint;
 inherited;
 foptionswidget:= defaultgroupboxoptionswidget;
 include(fwidgetstate,ws_visible);
end;

procedure tlayouter.setoptionslayout(const avalue: layoutoptionsty);
const
 mask1: layoutoptionsty = [lao_alignx,lao_placex];
 mask2: layoutoptionsty = [lao_aligny,lao_placey];
var
 lao1,lao2: layoutoptionsty;
begin
 if avalue <> foptionslayout then begin
  lao1:= layoutoptionsty(setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(avalue),
                         {$ifdef FPC}longword{$else}byte{$endif}(foptionslayout),
                         {$ifdef FPC}longword{$else}byte{$endif}(mask1)))*mask1;
  lao2:= layoutoptionsty(setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(avalue),
                         {$ifdef FPC}longword{$else}byte{$endif}(foptionslayout),
                         {$ifdef FPC}longword{$else}byte{$endif}(mask2)))*mask2;
  foptionslayout:= (avalue - (mask1+mask2)) + lao1 + lao2;
  updatelayout;
 end;
end;

function tlayouter.childrenwidth: integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(fwidgets) do begin
  with twidget1(fwidgets[int1]) do begin
   if (not(plo_noinvisible in fplace_options) or isvisible) then begin
    result:= result + fwidgetrect.cx;
   end;
  end;
 end;
end;

function tlayouter.childrenheight: integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(fwidgets) do begin
  with twidget1(fwidgets[int1]) do begin
   if (not(plo_noinvisible in fplace_options) or isvisible) then begin
    result:= result + fwidgetrect.cy;
   end;
  end;
 end;
end;

function tlayouter.childrenleft: integer;
var
 int1: integer;
begin
 result:= bigint;
 for int1:= 0 to high(fwidgets) do begin
  with fwidgets[int1] do begin
   if (not(plo_noinvisible in fplace_options) or isvisible) and 
                                     (fwidgetrect.x < result) then begin
    result:= fwidgetrect.x;
   end;
  end;
 end;
 if result = bigint then begin
  result:= 0;
 end;
end;

function tlayouter.childrenright: integer;
var
 int1: integer;
 int2: integer;
begin
 result:= -bigint;
 for int1:= 0 to high(fwidgets) do begin
  with fwidgets[int1] do begin
   int2:= fwidgetrect.x + fwidgetrect.cx;
   if (not(plo_noinvisible in fplace_options) or isvisible) and 
                                     (int2 > result) then begin
    result:= int2;
   end;
  end;
 end;
 if result = -bigint then begin
  result:= 0;
 end;
end;

function tlayouter.childrentop: integer;
var
 int1: integer;
begin
 result:= bigint;
 for int1:= 0 to high(fwidgets) do begin
  with fwidgets[int1] do begin
   if (not(plo_noinvisible in fplace_options) or isvisible) and 
                                     (fwidgetrect.y < result) then begin
    result:= fwidgetrect.y;
   end;
  end;
 end;
 if result = bigint then begin
  result:= 0;
 end;
end;

function tlayouter.childrenbottom: integer;
var
 int1: integer;
 int2: integer;
begin
 result:= -bigint;
 for int1:= 0 to high(fwidgets) do begin
  with fwidgets[int1] do begin
   int2:= fwidgetrect.y + fwidgetrect.cy;
   if (not (plo_noinvisible in fplace_options) or isvisible) and 
                                     (int2 > result) then begin
    result:= int2;
   end;
  end;
 end;
 if result = -bigint then begin
  result:= 0;
 end;
end;

procedure tlayouter.updatelayout;
var
 ar2: integerarty;
 space,margin: integer;
 
 procedure calcarray(const awidgets: widgetarty; const awidth: integer;
                                 const amin,amax: integer);
 var
  int1,int2: integer;
  rea1,rea2: real;
 begin
  margin:= 0;
  if high(awidgets) > 0 then begin
   if plo_propmargin in fplace_options then begin
    rea1:= awidth / (high(awidgets)+2);
   end
   else begin
    rea1:= awidth / high(awidgets);
   end;
   if rea1 < amin then begin
    rea1:= amin;
   end;
   if rea1 > amax then begin
    rea1:= amax;
   end;
   if plo_propmargin in fplace_options then begin
    margin:= round(rea1);
   end;
   rea2:= rea1;
   setlength(ar2,high(awidgets));
   space:= 0;
   for int1:= 0 to high(ar2) do begin
    int2:= round(rea2);
    space:= space + int2;
    ar2[int1]:= int2;
    rea2:= rea2 - ar2[int1] + rea1;
   end;
  end
  else begin
   space:= 0;
   if plo_propmargin in fplace_options then begin
    margin:= awidth div 2;
    if margin < amin then begin
     margin:= amin;
    end;
    if margin > amax then begin
     margin:= amax;
    end;
   end;
  end;
 end;
 
var
 int1,int2,int3,int4: integer;
 ar1: widgetarty;
 
begin
 if (componentstate * [csloading,csdestroying] = []) and 
                            (flayoutupdating = 0) then begin
  inc(flayoutupdating);
  try  
   updateoptionsscale;
   beginscaling;
   if widgetcount > 0 then begin
    if plo_syncmaxautosize in fplace_options then begin
     syncmaxautosize(fwidgets);
    end;
    if plo_syncpaintwidth in fplace_options then begin
     int1:= -1;
     if (lao_alignx in foptionslayout) and 
                              (falign_glue in [wam_start,wam_end]) then begin
      int1:= innerclientsize.cx;
     end;
     syncpaintwidth(fwidgets,int1);
    end;
    if plo_syncpaintheight in fplace_options then begin
     int1:= -1;
     if (lao_aligny in foptionslayout) and
                         (falign_glue in [wam_start,wam_end]) then begin
      int1:= innerclientsize.cy;
     end;
     syncpaintheight(fwidgets);
    end;
    if plo_synccaptiondistx in fplace_options then begin
     synccaptiondistx(fwidgets);
    end;
    if plo_synccaptiondisty in fplace_options then begin
     synccaptiondisty(fwidgets);
    end;
    if lao_alignx in foptionslayout then begin
     if align_mode <> wam_none then begin
      setlength(ar1,widgetcount);
      int2:= 0;
      if (falign_leader <> nil) and (falign_leader.parentwidget = self) then begin
       ar1[0]:= falign_leader;
       int2:= 1;
      end;
      for int1:= 0 to high(ar1) do begin
       if fwidgets[int1] <> falign_leader then begin
        ar1[int2]:= fwidgets[int1];
        inc(int2);
       end;
      end;
      alignx(align_mode,ar1);
     end;
     int2:= 0;
     case falign_glue of
      wam_start: begin
       int2:= innerclientwidgetpos.x - childrenleft;
      end;
      wam_center: begin
       int2:= innerclientwidgetpos.x + 
              (innerclientsize.cx - childrenleft - childrenright) div 2;
      end;
      wam_end: begin
       int2:= innerclientwidgetpos.x + innerclientsize.cx - childrenright;
      end;
     end;
     if int2 <> 0 then begin
      for int1:= 0 to high(fwidgets) do begin
       with fwidgets[int1] do begin
        bounds_x:= bounds_x + int2;
       end;
      end;
     end;
    end;
    if lao_aligny in foptionslayout then begin
     if align_mode <> wam_none then begin
      setlength(ar1,widgetcount);
      int2:= 0;
      if (falign_leader <> nil) and (falign_leader.parentwidget = self) then begin
       ar1[0]:= falign_leader;
       int2:= 1;
      end;
      for int1:= 0 to high(ar1) do begin
       if fwidgets[int1] <> falign_leader then begin
        ar1[int2]:= fwidgets[int1];
        inc(int2);
       end;
      end;
      aligny(align_mode,ar1);
     end;
     int2:= 0;
     case falign_glue of
      wam_start: begin
       int2:= innerclientwidgetpos.y - childrentop;
      end;
      wam_center: begin
       int2:= innerclientwidgetpos.y + 
              (innerclientsize.cy - childrentop - childrenbottom) div 2;
      end;
      wam_end: begin
       int2:= innerclientwidgetpos.y + innerclientsize.cy - childrenbottom;
      end;
     end;
     if int2 <> 0 then begin
      for int1:= 0 to high(fwidgets) do begin
       with fwidgets[int1] do begin
        bounds_y:= bounds_y + int2;
       end;
      end;
     end;
    end;
    if (fplace_mode <> wam_none) and 
            (foptionslayout * [lao_placex,lao_placey] <> []) then begin
     if plo_noinvisible in fplace_options then begin
      ar1:= getvisiblewidgets;
     end
     else begin
      ar1:= copy(fwidgets);
     end;
     if lao_placex in foptionslayout then begin
      sortwidgetsxorder(ar1,self);
      int4:= childrenwidth;
      calcarray(ar1,innerclientsize.cx - int4,fplace_mindist,fplace_maxdist);
      if plo_endmargin in fplace_options then begin
       placexorder(innerclientpos.x + margin,ar2,ar1,
                                           innerclientframe.right + margin);
      end
      else begin
       case fplace_mode of 
        wam_start: begin
         int3:= innerclientpos.x + margin;
        end;
        wam_center: begin
         int3:= innerclientpos.x + (innerclientsize.cx - int4 - space) div 2;
        end;
        wam_end: begin
         int3:= innerclientpos.x + innerclientsize.cx - int4 - space - margin;
        end;
       end;
       placexorder(int3,ar2,ar1);
      end;
     end;
     if (lao_placey in foptionslayout) and (fplace_mode <> wam_none) then begin
      sortwidgetsyorder(ar1,self);
      int4:= childrenheight;
      calcarray(ar1,innerclientsize.cy - int4,fplace_mindist,fplace_maxdist);
      if plo_endmargin in fplace_options then begin
       placeyorder(innerclientpos.y + margin,ar2,ar1,
                                           innerclientframe.bottom + margin);
      end
      else begin
       case fplace_mode of 
        wam_start: begin
         int3:= innerclientpos.y + margin;
        end;
        wam_center: begin
         int3:= innerclientpos.y + (innerclientsize.cy - int4 - space) div 2;
        end;
        wam_end: begin
         int3:= innerclientpos.y + innerclientsize.cy - int4 - space - margin;
        end;
       end;
       placeyorder(int3,ar2,ar1);
      end;
     end;
    end;
   end;
  finally
   endscaling;
   dec(flayoutupdating);
  end;
 end;
end;

function tlayouter.calcminscrollsize: sizety;
begin
 result:= inherited calcminscrollsize;
 if lao_placex in foptionslayout then begin
  result.cx:= childrenwidth + high(fwidgets) * fplace_mindist + innerframewidth.cx;
  if plo_propmargin in fplace_options then begin
   result.cx:= result.cx + 2 * fplace_mindist;
  end;
 end;
 if lao_placey in foptionslayout then begin
  result.cy:= childrenheight + high(fwidgets) * fplace_mindist + innerframewidth.cy;
  if plo_propmargin in fplace_options then begin
   result.cy:= result.cy + 2 * fplace_mindist;
  end;
 end;
end;

procedure tlayouter.loaded;
begin
 inherited;
 updatelayout;
end;

procedure tlayouter.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if not (ws_loadedproc in fwidgetstate) then begin
  updatelayout;
 end;
end;

procedure tlayouter.setalign_mode(const avalue: widgetalignmodety);
begin
 if avalue <> falign_mode then begin
  falign_mode:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.setalign_glue(const avalue: widgetalignmodety);
begin
 if falign_glue <> avalue then begin
  falign_glue:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.setalign_leader(const avalue: twidget);
begin
 if falign_leader <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(falign_leader));
  updatelayout;
 end;
end;

procedure tlayouter.setplace_mindist(const avalue: integer);
begin
 if fplace_mindist <> avalue then begin
  fplace_mindist:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.setplace_maxdist(const avalue: integer);
begin
 if fplace_maxdist <> avalue then begin
  fplace_maxdist:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.setplace_mode(const avalue: widgetalignmodety);
begin
 if fplace_mode <> avalue then begin
  fplace_mode:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.setplace_options(const avalue: placeoptionsty);
begin
 if fplace_options <> avalue then begin
  fplace_options:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure tlayouter.childautosizechanged(const sender: twidget);
begin
 inherited;
 updatelayout;
end;

end.
