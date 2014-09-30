{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesplitter;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,msewidgets,mseobjectpicker,classes,mclasses,msegraphutils,
 msepointer,msetypes,
 msestrings,msegraphics,mseevent,msestat,msestatfile,msestockobjects,mseclasses,
 msesimplewidgets,mseguiglob,msemenus;
type

 splitteroptionty = (spo_hmove,spo_hprop,spo_hsizeprop,
                     spo_vmove,spo_vprop,spo_vsizeprop,
                     spo_dockleft,spo_docktop,spo_dockright,spo_dockbottom,
                     spo_hshrinkzero,spo_vshrinkzero,
                     spo_hrefstart,spo_vrefstart,
                     spo_thumbtrack);
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
 splitterstatety = (sps_propnotified);
 splitterstatesty = set of splitterstatety;
 
 tcustomsplitter = class(tscalingwidget,iobjectpicker,istatfile)
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
//   fnotified: integer;
   fregionchangedcount: integer;
   fregionchangedmark: integer;
   frefrect: rectty;
   fshrinkpriority: integer;
   fpropoffsetrecursion: integer;
   fstatpriority: integer;
   fwidgetrectbefore: rectty;
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
   fstate: splitterstatesty;
   procedure postupdatepropevent;
   function clippoint(const aoffset: pointty): pointty;
   procedure calcoffset(const refsize: sizety; 
                      out offset,clippedoffset: pointty; out newsize: sizety);
   procedure setpropoffset(const aoffset: pointty; const asize: sizety);
//   function getminshrinkpos: pointty; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure poschanged1;
   procedure poschanged; override;
   procedure sizechanged; override;
   procedure parentclientrectchanged; override;
   procedure doasyncevent(var atag: integer); override;
   procedure dopaintforeground(const acanvas: tcanvas); override;
   procedure parentwidgetregionchanged(const sender: twidget); override;
   function getshrinkpriority: integer; override;
   procedure tryshrink(const aclientsize: sizety); override;
   procedure loaded; override;
   procedure updatedock;
   procedure updatelinkedwidgets(const delta: pointty);

    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;

    //iobjectpicker
   function getcursorshape(const sender: tobjectpicker;
                                        var shape: cursorshapety): boolean;
   procedure getpickobjects(const sender: tobjectpicker; 
                                          var objects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure pickthumbtrack(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure cancelpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const canvas: tcanvas);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure move(const dist: pointty);

   property options: splitteroptionsty read foptions write setoptions 
                 default defaultsplitteroptions;
   property shrinkpriority: integer read getshrinkpriority 
                                    write fshrinkpriority default 0;
   property linkleft: twidget read flinkleft write setlinkleft;
   property linktop: twidget read flinktop write setlinktop;
   property linkright: twidget read flinkright write setlinkright;
   property linkbottom: twidget read flinkbottom write setlinkbottom;

   property color default defaultsplittercolor;
   property grip: stockbitmapty read fgrip write setgrip 
                                               default defaultsplittergrip;
   property colorgrip: colorty read fcolorgrip write setcolorgrip 
                                               default defaultsplittercolorgrip;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority 
                                       write fstatpriority default 0;
   property onupdatelayout: notifyeventty read fonupdatelayout
                                               write fonupdatelayout;
  published
   property optionswidget default defaultoptionswidgetnofocus;
 end;

 tsplitter = class(tcustomsplitter)
  published
//   property optionswidget;
   property options;
   property shrinkpriority;
   property linkleft;
   property linktop;
   property linkright;
   property linkbottom;

//   property color;
   property grip;
   property colorgrip;
   property statfile;
   property statvarname;
   property statpriority;
   property onupdatelayout;
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

 layoutoptionty = (lao_alignx,lao_placex,lao_aligny,lao_placey,
                   lao_scaleleft,lao_scaletop,
                   lao_scalewidth,lao_scaleheight,
                   lao_scalefont,lao_scalechildfont);
 layoutoptionsty = set of layoutoptionty; 
const
 defaultlayoutoptions = [];

type  
 placeoptionty = (plo_noinvisible,plo_scalesize,
                  plo_endmargin,plo_propmargin,plo_syncmaxautosize,
                  plo_synccaptiondistx,plo_synccaptiondisty,
                  plo_syncpaintwidth,plo_syncpaintheight);
 placeoptionsty = set of placeoptionty;

 widgetlayoutinfoty = record
  widget: twidget;
  pos: pointty;
  size: sizety;
  actpos: pointty;
  actsize: sizety;
  refsize: sizety;
  scalesize: sizety;
  actscalesize: sizety;
  refscalesize: sizety;  
  reffontsize: sizety;
  fontheight: integer;
  actfontheight: integer;
  fontxscale: real;
  actfontxscale: real;
 end;
 pwidgetlayoutinfoty = ^widgetlayoutinfoty;
 widgetlayoutinfoarty = array of widgetlayoutinfoty;

 layouterstatety = (las_propsizing,las_scalesizerefvalid);
 layouterstatesty = set of layouterstatety;
 
 tlayouter = class;
 layoutereventty = procedure(const sender: tlayouter) of object;
  
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
   fwidgetinfos: widgetlayoutinfoarty;
   fstate: layouterstatesty;
   fscalesizeref: sizety;
   ffontsizeref: sizety;
   ffontheightref: integer;
   ffontxscaleref: real;
   fonbeforelayout: layoutereventty;
   fonafterlayout: layoutereventty;
   procedure setoptionslayout(const avalue: layoutoptionsty);
   procedure setalign_mode(const avalue: widgetalignmodety);
   procedure setalign_leader(const avalue: twidget);
   procedure setplace_mindist(const avalue: integer);
   procedure setplace_maxdist(const avalue: integer);
   procedure setalign_glue(const avalue: widgetalignmodety);
   procedure setplace_mode(const avalue: widgetalignmodety);
   procedure setplace_options(const avalue: placeoptionsty);
  protected
   procedure scalebasechanged(const sender: twidget); override;
   function scalesizeref: sizety;
   function childrenleft: integer;
   function childrentop: integer;
   function childrenright: integer;
   function childrenbottom: integer;
   function childrenwidth: integer;
   function childrenheight: integer;
   procedure scalesizerefchanged;
   procedure updatescalesizeref;
   procedure updatelayout;
   procedure loaded; override;
   procedure fontchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure childclientrectchanged(const sender: twidget); override;
   procedure childautosizechanged(const sender: twidget); override;
   procedure clientrectchanged; override;
   function calcminscrollsize: sizety; override;
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   function widgetinfoindex(const awidget: twidget): integer;
   procedure updatewidgetinfo(var ainfo: widgetlayoutinfoty; 
                                    const awidget: twidget);
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
   property place_mindist: integer read fplace_mindist 
                                           write setplace_mindist default 0;
   property place_maxdist: integer read fplace_maxdist write setplace_maxdist
                                     default bigint;
   property place_mode: widgetalignmodety read fplace_mode write setplace_mode 
                                     default wam_start;
   property place_options: placeoptionsty read fplace_options 
                                     write setplace_options default [];
   property optionswidget default defaultgroupboxoptionswidget;
   property onbeforelayout: layoutereventty read fonbeforelayout 
                                                    write fonbeforelayout;
   property onafterlayout: layoutereventty read fonafterlayout 
                                                    write fonafterlayout;
   property visible default true;
 end;
 
implementation
uses
 msebits,math;
type
 twidget1 = class(twidget);

{$define useround}

{ tcustomsplitter }

constructor tcustomsplitter.create(aowner: tcomponent);
begin
// include(fwidgetstate1,ws1_tryshrink);
 foptions:= defaultsplitteroptions;
 fcolorgrip:= defaultsplittercolorgrip;
 fgrip:= defaultsplittergrip;
 frefrect.x:= -bigint;
 frefrect.y:= -bigint;
 frefrect.cx:= -bigint;
 frefrect.cy:= -bigint;
 include(fwidgetstate1,ws1_framemouse);
 inherited;
 color:= defaultsplittercolor;
 optionswidget:= defaultoptionswidgetnofocus;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self),org_widget);
end;

destructor tcustomsplitter.destroy;
begin
 fobjectpicker.Free;
 inherited;
end;

procedure tcustomsplitter.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  fobjectpicker.mouseevent(info);
 end;
end;

function tcustomsplitter.getcursorshape(const sender: tobjectpicker; var shape: cursorshapety): boolean;
begin
 result:= canmouseinteract and
                pointinrect(sender.pos,makerect(nullpoint,fwidgetrect.size));
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

procedure tcustomsplitter.getpickobjects(const sender: tobjectpicker;
                                                var objects: integerarty);
begin
 if (foptions * [spo_hmove,spo_vmove] <> []) and canmouseinteract then begin
  setlength(objects,1);
 end;
end;

function tcustomsplitter.clippoint(const aoffset: pointty): pointty;
var
 int1: integer;
begin
 if fparentwidget <> nil then begin
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
    int1:= widgetminsize.cx;
    if fwidgetrect.cx + result.x < int1 then begin
     result.x:= int1 - fwidgetrect.cx;
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
    int1:= widgetminsize.cx;
    if fwidgetrect.cx - result.x < int1 then begin
     result.x:= - (int1 - fwidgetrect.cx);
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
    int1:= widgetminsize.cy;
    if fwidgetrect.cy + result.y < int1 then begin
     result.y:= int1 - fwidgetrect.cy;
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
    int1:= widgetminsize.cy;
    if fwidgetrect.cy - result.y < int1 then begin
     result.y:= - (int1 - fwidgetrect.cy);
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

procedure tcustomsplitter.paintxorpic(const sender: tobjectpicker; 
                                                         const canvas: tcanvas);
begin
 if fparentwidget <> nil then begin
  canvas.addcliprect(makerect(-fwidgetrect.x,-fwidgetrect.y,
    twidget1(fparentwidget).fwidgetrect.cx,
    twidget1(fparentwidget).fwidgetrect.cy));
 end;
 canvas.drawxorframe(makerect(clippoint(sender.pickoffset),fwidgetrect.size),-4,
            stockobjects.bitmaps[stb_dens25]);
end;

procedure tcustomsplitter.updatelinkedwidgets(const delta: pointty);
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

procedure tcustomsplitter.setclippedpickoffset(const aoffset: pointty);
begin
 inc(fupdating);
 try
  self.pos:= addpoint(self.pos,aoffset);
 finally
  dec(fupdating);
 end;
 updatelinkedwidgets(aoffset);
end;

procedure tcustomsplitter.setpickoffset(const aoffset: pointty);
begin
 setclippedpickoffset(clippoint(aoffset));
end;

procedure tcustomsplitter.move(const dist: pointty);
begin
 setpickoffset(dist);
end;

procedure tcustomsplitter.endpickmove(const sender: tobjectpicker);
begin
 setpickoffset(sender.pickoffset);
end;

procedure tcustomsplitter.cancelpickmove(const sender: tobjectpicker);
begin
 widgetrect:= fwidgetrectbefore;
end;

procedure tcustomsplitter.beginpickmove(const sender: tobjectpicker);
begin
 fwidgetrectbefore:= fwidgetrect;
end;

procedure tcustomsplitter.pickthumbtrack(const sender: tobjectpicker);
begin
 setpickoffset(sender.pickoffset);
end;

procedure tcustomsplitter.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tcustomsplitter.dostatread(const reader: tstatreader);
var
 po1,po2: pointty;
begin
 if reader.canstate then begin
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
  setclippedpickoffset(subpoint(po2,po1));
  if foptions * [spo_hmove,spo_hprop] = [spo_hmove,spo_hprop] then begin
   fhprop:= reader.readreal('xprop',fhprop,0,1);
  end;
  if foptions * [spo_vmove,spo_vprop] = [spo_vmove,spo_vprop] then begin
   fvprop:= reader.readreal('yprop',fvprop,0,1);
  end;
 end;
end;

procedure tcustomsplitter.dostatwrite(const writer: tstatwriter);
var
 po1: pointty;
begin
 if writer.canstate then begin
  po1:= parentclientpos;
  writer.writeinteger('x',po1.x);
  writer.writeinteger('y',po1.y);
  writer.writereal('xprop',fhprop);
  writer.writereal('yprop',fvprop);
 end;
end;

procedure tcustomsplitter.statreading;
begin
{
 if fparentwidget <> nil then begin
  postupdatepropevent;
 end;
}
end;

procedure tcustomsplitter.statread;
begin
 //dummy
end;

function tcustomsplitter.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomsplitter.setlinkbottom(const avalue: twidget);
begin
// if flinkbottom <> nil then begin
//  twidget1(flinkbottom).fminshrinkposoffset.y:= 0;
// end;
 setlinkedvar(avalue,tmsecomponent(flinkbottom));
 updatedock;
end;

procedure tcustomsplitter.setlinkleft(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinkleft));
 updatedock;
end;

procedure tcustomsplitter.setlinkright(const avalue: twidget);
begin
// if flinkright <> nil then begin
//  twidget1(flinkright).fminshrinkposoffset.x:= 0;
// end;
 setlinkedvar(avalue,tmsecomponent(flinkright));
 updatedock;
end;

procedure tcustomsplitter.setlinktop(const avalue: twidget);
begin
 setlinkedvar(avalue,tmsecomponent(flinktop));
 updatedock;
end;

procedure tcustomsplitter.poschanged1;
var
 int1,int2,int3: integer;
begin
 int3:= 0;
 if not (spo_hrefstart in foptions) then begin
  int3:= bounds_cx;
 end;
 int2:= bounds_x + int3;
 if frefrect.x <> int2 then begin
  frefrect.x:= int2;
  fhprop:= 0;
  int1:= fparentwidget.clientsize.cx;
  if (int1 > 0) then begin
   fhprop:= (parentclientpos.x+int3) / 
                  {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
  end;
 end;
 int3:= 0;
 if not (spo_vrefstart in foptions) then begin
  int3:= bounds_cy;
 end;
 int2:= bounds_y + int3;
 if frefrect.y <> int2 then begin
  frefrect.y:= int2;
  fvprop:= 0;
  int1:= fparentwidget.clientsize.cy;
  if (int1 > 0) then begin
   fvprop:= (parentclientpos.y+int3) /
                        {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
  end;
 end;
end;

procedure tcustomsplitter.poschanged;
begin
 inherited;
 if (fparentwidget <> nil) then begin
  if not (csloading in componentstate) and (fpropsetting = 0) then begin
   poschanged1;
  end;
 end;
end;

procedure tcustomsplitter.sizechanged;
var
 int1: integer;
begin
 inherited;
 if (fparentwidget <> nil) then begin
  if not (csloading in componentstate) and (fpropsetting = 0) then begin
   if frefrect.cx <> bounds_cx then begin
    frefrect.cx:= bounds_cx;
    fhsizeprop:= 0;
    int1:= fparentwidget.clientsize.cx;
    if (int1 > 0) then begin
     fhsizeprop:= fwidgetrect.cx / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
    end;
   end;
   if frefrect.cy <> bounds_cy then begin
    frefrect.cy:= bounds_cy;
    fvsizeprop:= 0;
    int1:= fparentwidget.clientsize.cy;
    if (int1 > 0) then begin
     fvsizeprop:= fwidgetrect.cy / {$ifdef FPC} real({$endif}int1{$ifdef FPC}){$endif};
    end;
   end;
   poschanged1;
  end;
 end;
end;

procedure tcustomsplitter.calcoffset(const refsize: sizety;
            out offset,clippedoffset: pointty; out newsize: sizety);
//var
// size1: sizety;
var
 int1: integer;
begin
// size1:= fparentwidget.clientsize;
 offset:= nullpoint;
 newsize:= size;
 if spo_hsizeprop in foptions then begin
  newsize.cx:= {$ifdef useround}round{$else}floor{$endif}(refsize.cx * fhsizeprop);
  if not(an_right in fanchors) xor (spo_hrefstart in foptions) then begin
   offset.x:= bounds_cx - newsize.cx;
  end;
 end;
 if spo_vsizeprop in foptions then begin
  newsize.cy:= {$ifdef useround}round{$else}floor{$endif}(refsize.cy * fvsizeprop);
  if not(an_bottom in fanchors) xor (spo_vrefstart in foptions) then begin
   offset.y:= bounds_cy - newsize.cy;
  end;
 end;
 if spo_hprop in foptions then begin
  int1:= 0;
  if not (spo_hrefstart in foptions) then begin
   int1:= bounds_cx;
  end;
  offset.x:= offset.x + {$ifdef useround}round{$else}floor{$endif}(fhprop * refsize.cx) - parentclientpos.x -
                                                                     int1;
 end;
 if (spo_vprop in foptions) then begin
  int1:= 0;
  if not (spo_vrefstart in foptions) then begin
   int1:= bounds_cy;
  end;
  offset.y:= offset.y + {$ifdef useround}round{$else}floor{$endif}(fvprop * refsize.cy) - parentclientpos.y -
                                                                     int1;
 end;
 clippedoffset:= clippoint(offset);
//  pt2:= pt1;
end;

procedure tcustomsplitter.setpropoffset(const aoffset: pointty;
                                                      const asize: sizety);
begin      
 inc(fpropsetting);
 try
  size:= asize;
  setclippedpickoffset(aoffset);
  frefrect:= fwidgetrect;
  with frefrect do begin
   if not(spo_hrefstart in foptions) then begin
    x:= x + cx;
   end;
   if not(spo_vrefstart in foptions) then begin
    y:= y + cy;
   end;
  end;
 finally
  dec(fpropsetting);
 end;
end;

procedure tcustomsplitter.doasyncevent(var atag: integer);
var
 pt1,pt2: pointty;
 size2: sizety;
   
begin //doasyncevent
 inherited;
 case atag of
  updatepropeventtag,retrypropeventtag: begin
   if atag = updatepropeventtag then begin
    exclude(fstate,sps_propnotified);
   end;
   try
    if fparentwidget <> nil then begin
     calcoffset(fparentwidget.clientsize,pt1,pt2,size2);
     if (([spo_hmove,spo_hprop] * foptions <> []) and (pt1.x <> pt2.x) or 
         ([spo_vmove,spo_vprop] * foptions <> []) and (pt1.y <> pt2.y)) and
        (fregionchangedmark <> fregionchangedcount) then begin
      fregionchangedmark:= fregionchangedcount;
      inc(fupdating);
      asyncevent(retrypropeventtag,[peo_local]);
     end
     else begin
      inc(fpropoffsetrecursion);
      if fpropoffsetrecursion < 16 then begin
       setpropoffset(pt2,size2);
       if not(sps_propnotified in fstate) then begin
        fpropoffsetrecursion:= 0;
       end;
      end
      else begin
       fpropoffsetrecursion:= 0;
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

procedure tcustomsplitter.tryshrink(const aclientsize: sizety);
var
 pt1,pt2: pointty;
 size1,size2: sizety;
begin
 if fupdating = 0 then begin
  if spo_hshrinkzero in foptions then begin
   size1.cx:= 0;
  end
  else begin
   size1:= fparentwidget.clientsize;
   if size1.cx > aclientsize.cx then begin
    size1.cx:= aclientsize.cx;
   end;
  end;
  if spo_vshrinkzero in foptions then begin
   size1.cy:= 0;
  end
  else begin
   if size1.cy > aclientsize.cy then begin
    size1.cy:= aclientsize.cy;
   end;
  end;
  calcoffset(size1,pt1,pt2,size2);
  try
   setpropoffset(pt2,size2);
  finally
   updatedock;
  end;
 end;
end;

procedure tcustomsplitter.postupdatepropevent;
begin
 if not (sps_propnotified in fstate) then begin
  include(fstate,sps_propnotified);
  asyncevent(updatepropeventtag,[peo_local,peo_first]);
 end;
end;

procedure tcustomsplitter.parentclientrectchanged;
begin
 inherited;
 if (componentstate * [csloading{,csdesigning}] = []) and canmouseinteract and
              (fparentwidget <> nil) then begin
  postupdatepropevent;
 end;
end;

procedure tcustomsplitter.setcolorgrip(const avalue: colorty);
begin
 if fcolorgrip <> avalue then begin
  fcolorgrip:= avalue;
  invalidate;
 end;
end;

procedure tcustomsplitter.setgrip(const avalue: stockbitmapty);
begin
 if fgrip <> avalue then begin
  fgrip:= avalue;
  invalidate;
 end;
end;

procedure tcustomsplitter.dopaintforeground(const acanvas: tcanvas);
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

procedure tcustomsplitter.parentwidgetregionchanged(const sender: twidget);
begin
 inc(fregionchangedcount);
 inherited;
 if (sender <> nil) and ((sender = flinkleft) or (sender = flinktop) or
                         (sender = flinkright) or (sender = flinkbottom) or
                         (sender = self)) then begin
  updatedock;
 end;
end;

procedure tcustomsplitter.loaded;
begin
 inherited;
 updatedock;
end;

procedure tcustomsplitter.updatedock;
var
 pt1: pointty;
 rect1: rectty;
begin
 if (componentstate * [csloading,csdestroying] = []) and 
             (foptions * docksplitteroptions <> []) and
             (fparentwidget <> nil) and (fupdating = 0) then begin
  inc(fupdating);
  pt1:= addpoint(pos,pointty(size));
  try
   if flinkright <> nil then begin
    with twidget1(flinkright) do begin
//     fminshrinkposoffset.x:= - fwidgetrect.x;
    end;
   end;
   if flinkbottom <> nil then begin
    with twidget1(flinkbottom) do begin
//     fminshrinkposoffset.y:= - fwidgetrect.y;
    end;
   end;
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
     rect1.cx:= rect1.cx + (rect1.x - pt1.x);
     rect1.pos.x:= pt1.x;
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
     rect1.cy:= rect1.cy + (rect1.y - pt1.y);
     rect1.pos.y:= pt1.y;
     flinkbottom.widgetrect:= rect1;
    end;
   end;
  finally
   dec(fupdating);
  end;
 end;
end;
{
function tcustomsplitter.getminshrinkpos: pointty;
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
}
procedure tcustomsplitter.setoptions(const avalue: splitteroptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  if avalue * [spo_hprop,spo_vprop] <> [] then begin
   include(fwidgetstate1,ws1_tryshrink);
  end
  else begin
   exclude(fwidgetstate1,ws1_tryshrink);
  end;
  if spo_thumbtrack in avalue then begin
   fobjectpicker.options:= fobjectpicker.options + [opo_thumbtrack];
  end
  else begin
   fobjectpicker.options:= fobjectpicker.options - [opo_thumbtrack];
  end;
  updatedock;
 end;
end;

function tcustomsplitter.getshrinkpriority: integer;
begin
 result:= fshrinkpriority;
end;

function tcustomsplitter.getstatpriority: integer;
begin
 result:= fstatpriority;
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

function alive(const acomponent: tcomponent): boolean;
begin
 result:= (acomponent <> nil) and 
                       not (csdestroying in acomponent.componentstate);
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
    if alive(flinkright) then begin
     po1.x:= flinkright.bounds_x - bounds_cx - fdist_right;
    end;
   end
   else begin
    if alive(flinkleft) then begin
     po1.x:= flinkleft.bounds_x + flinkleft.bounds_cx + fdist_left;
    end;
   end;
   if spao_gluebottom in foptions then begin
    if alive(flinkbottom) then begin
     po1.y:= flinkbottom.bounds_y - bounds_cy - fdist_bottom;
    end;
   end
   else begin
    if alive(flinktop) then begin
     po1.y:= flinktop.bounds_y + flinktop.bounds_cy + fdist_top;
    end;
   end;
   pos:= po1;
   addpoint1(po1,pointty(size));
   po1.x:= po1.x + fdist_right;
   po1.y:= po1.y + fdist_bottom;
   if spao_glueright in foptions then begin
    if alive(flinkleft) then begin
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
    if alive(flinkright) then begin
     rect1:= flinkright.widgetrect;
     if an_right in flinkright.anchors then begin
      rect1.cx:= rect1.cx + (rect1.x - po1.x);
     end;
     rect1.pos.x:= po1.x;
     flinkright.widgetrect:= rect1;
    end;
   end;
   if spao_gluebottom in foptions then begin
    if alive(flinktop) then begin
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
    if alive(flinkbottom) then begin
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
  lao1:= layoutoptionsty(setsinglebit({$ifdef FPC}longword{$else}word{$endif}(avalue),
                         {$ifdef FPC}longword{$else}word{$endif}(foptionslayout),
                         {$ifdef FPC}longword{$else}word{$endif}(mask1)))*mask1;
  lao2:= layoutoptionsty(setsinglebit({$ifdef FPC}longword{$else}word{$endif}(avalue),
                         {$ifdef FPC}longword{$else}word{$endif}(foptionslayout),
                         {$ifdef FPC}longword{$else}word{$endif}(mask2)))*mask2;
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
  with twidget1(fwidgets[int1]) do begin
   if (not(plo_noinvisible in fplace_options) or isvisible) and 
                                   (fwidgetrect.x < result) and 
                            not (ow1_noalignx in foptionswidget1) then begin
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
  with twidget1(fwidgets[int1]) do begin
   int2:= fwidgetrect.x + fwidgetrect.cx;
   if (not(plo_noinvisible in fplace_options) or isvisible) and
                                     (int2 > result) and 
                            not (ow1_noalignx in foptionswidget1) then begin
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
  with twidget1(fwidgets[int1]) do begin
   if (not(plo_noinvisible in fplace_options) or isvisible) and
                                     (fwidgetrect.y < result) and 
                            not (ow1_noaligny in foptionswidget1) then begin
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
  with twidget1(fwidgets[int1]) do begin
   int2:= fwidgetrect.y + fwidgetrect.cy;
   if (not (plo_noinvisible in fplace_options) or isvisible) and
                                     (int2 > result) and 
                            not (ow1_noaligny in foptionswidget1) then begin
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
 end; //calcarray

 function getalignwidgets: widgetarty;
 var
  int1,int2: integer;
 begin
  setlength(result,widgetcount);
  int2:= 0;
  if (falign_leader <> nil) and 
              (falign_leader.parentwidget = self) then begin
   result[0]:= falign_leader;
   int2:= 1;
  end;
  for int1:= 0 to high(result) do begin
   if fwidgets[int1] <> falign_leader then begin
    if not (ow1_noalignx in fwidgets[int1].optionswidget1) then begin
     result[int2]:= fwidgets[int1];
     inc(int2);
    end;
   end;
  end;
  setlength(result,int2);
 end; //getalignwidgets
 
var
 int1,int2,int3,int4: integer;
 ar1: widgetarty;
 size1: sizety;
 
begin
 if (componentstate * [csloading,csdestroying] = []) and 
                            (flayoutupdating = 0) then begin
  if canevent(tmethod(fonbeforelayout)) then begin
   fonbeforelayout(self);
  end;
  inc(flayoutupdating);
  try  
   updateoptionsscale;
   beginscaling;   
   if widgetcount > 0 then begin
    if (foptionslayout*[lao_placex,lao_placey] <> []) and
                       (plo_scalesize in fplace_options) then begin
        //scale to variable clientsize
     size1:= scalesizeref;
     if lao_placex in foptionslayout then begin
      for int1:= high(fwidgetinfos) downto 0 do begin
       with fwidgetinfos[int1] do begin
        if not (osk_nopropwidth in widget.optionsskin) and 
                                      (refscalesize.cx <> 0) then begin
         widget.clientwidth:= (scalesize.cx * size1.cx) div refscalesize.cx;
        end;
       end;
      end;
     end
     else begin
      for int1:= high(fwidgetinfos) downto 0 do begin
       with fwidgetinfos[int1] do begin
        if not (osk_nopropheight in widget.optionsskin) and 
                                      (refscalesize.cy <> 0) then begin
         widget.clientheight:= (scalesize.cy * size1.cy) div refscalesize.cy;
        end;
       end;
      end;
     end;
    end;
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
     if (align_mode <> wam_none) or (align_glue <> wam_none) then begin
      ar1:= getalignwidgets();
      int2:= 0;
      case falign_glue of
       wam_start: begin
        int2:= innerclientwidgetpos.x;
       end;
       wam_end: begin
        int2:= fwidgetrect.cx - (innerclientwidgetpos.x + innerclientsize.cx);
       end;
       else begin //wam_center
        int2:= (fwidgetrect.cx - 2*innerclientwidgetpos.x -
                                             innerclientsize.cx) div 2;
       end;
      end;
      alignx(align_mode,ar1,align_glue,int2);
     end;
     {
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
        if not (ow1_noalignx in foptionswidget1) then begin
         bounds_x:= bounds_x + int2;
        end;
       end;
      end;
     end;
    }
    end;
    if lao_aligny in foptionslayout then begin
     if (align_mode <> wam_none) or (align_glue <> wam_none) then begin
      ar1:= getalignwidgets();
      int2:= 0;
      case falign_glue of
       wam_start: begin
        int2:= innerclientwidgetpos.y;
       end;
       wam_end: begin
        int2:= fwidgetrect.cy - (innerclientwidgetpos.y + innerclientsize.cy);
       end;
       else begin //wam_center
        int2:= (fwidgetrect.cy - 2*innerclientwidgetpos.y -
                                             innerclientsize.cy) div 2;
       end;
      end;
      aligny(align_mode,ar1,align_glue,int2);
     end;
     {
     if align_mode <> wam_none then begin
      setlength(ar1,widgetcount);
      int2:= 0;
      if (falign_leader <> nil) and (falign_leader.parentwidget = self) then begin
       ar1[0]:= falign_leader;
       int2:= 1;
      end;
      for int1:= 0 to high(ar1) do begin
       if fwidgets[int1] <> falign_leader then begin
        if not (ow1_noaligny in fwidgets[int1].optionswidget1) then begin
         ar1[int2]:= fwidgets[int1];
         inc(int2);
        end;
       end;
      end;
      setlength(ar1,int2);
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
        if not (ow1_noaligny in foptionswidget1) then begin
         bounds_y:= bounds_y + int2;
        end;
       end;
      end;
     end;
     }
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
  if canevent(tmethod(fonafterlayout)) then begin
   fonafterlayout(self);
  end;
 end;
end;

procedure tlayouter.updatescalesizeref;
var
 int1,int3: integer;
 sum: sizety;
 bo1: boolean;
begin
 if plo_scalesize in fplace_options then begin
  if foptionslayout * [lao_placex,lao_placey] <> [] then begin
   sum:= nullsize;
   bo1:= not (plo_noinvisible in fplace_options);
   for int1:= 0 to high(fwidgets) do begin
    with widgets[int1] do begin
     if (bo1 or visible) then begin
      if osk_nopropwidth in optionsskin then begin 
       addsize1(sum,size);
      end
      else begin
       addsize1(sum,framedim);
      end;
     end
     else begin
     end;
    end;
   end;
   if bo1 then begin
    int3:= length(fwidgets);
   end
   else begin
    int3:= 0;
    for int1:= 0 to high(fwidgets) do begin
     if fwidgets[int1].visible then begin
      inc(int3);
     end;
    end;
   end;
   if not (plo_propmargin in fplace_options) then begin
    dec(int3);
   end;
   fscalesizeref:= innerclientsize;
   subsize1(fscalesizeref,sum);
   if int3 > 0 then begin
    int3:= int3 * fplace_mindist;
    fscalesizeref.cx:= fscalesizeref.cx - int3;
    fscalesizeref.cy:= fscalesizeref.cy - int3;
   end;
  end;
 end;
 include(fstate,las_scalesizerefvalid);
end;

function tlayouter.calcminscrollsize: sizety;
var
 int1,int2,int3,int4: integer;
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
 if (high(fwidgets) >= 0) and (align_glue <> wam_none) and 
                                     (align_mode <> wam_none)then begin
  int2:= -bigint;
  int3:= bigint;
  if lao_alignx in foptionslayout then begin
   for int1:= 0 to high(fwidgets) do begin
    with fwidgets[int1] do begin
     if isvisible then begin
      with fwidgetrect do begin
       if x < int3 then begin
        int3:= x;
       end;
       int4:= x + cx;
       if int4 > int2 then begin
        int2:= int4;
       end;
      end;
     end;
    end;  
   end;
   if int2 > int3 then begin
    int2:= int2-int3;
   end
   else begin
    int2:= 0;
   end;
   int2:= int2 + innerframewidth.cx;
   if int2 < bounds_cxmin then begin
    int2:= bounds_cxmin;
   end;
   result.cx:= int2;
  end;   
  if lao_aligny in foptionslayout then begin
   for int1:= 0 to high(fwidgets) do begin
    with fwidgets[int1] do begin
     if isvisible then begin
      with fwidgetrect do begin
       if y < int3 then begin
        int3:= y;
       end;
       int4:= y + cy;
       if int4 > int2 then begin
        int2:= int4;
       end;
      end;
     end;
    end;  
   end;
   if int2 > int3 then begin
    int2:= int2-int3;
   end
   else begin
    int2:= 0;
   end;
   int2:= int2 + innerframewidth.cy;
   if int2 < bounds_cymin then begin
    int2:= bounds_cymin;
   end;
   result.cy:= int2;
  end;
 end;
end;

procedure tlayouter.loaded;
var
 int1: integer;
begin
 inherited;
 for int1:= high(fwidgetinfos) downto 0 do begin
  updatewidgetinfo(fwidgetinfos[int1],nil);
 end;
 updatelayout;
end;

procedure tlayouter.fontchanged;
begin
 inherited;
 if flayoutupdating = 0 then begin
  ffontheightref:= getfont.height;
//  if ffontheightref = 0 then begin
//   ffontheightref:= font.glyphheight;
//  end;
  ffontxscaleref:= getfont.xscale;
  ffontsizeref:= clientsize;
 end;
end;

procedure tlayouter.childclientrectchanged(const sender: twidget);
var
 int1: integer;
begin
 inherited;
 if not (las_propsizing in fstate) then begin
  int1:= widgetinfoindex(sender);
  if int1 >= 0 then begin
   updatewidgetinfo(fwidgetinfos[int1],sender);
  end;
 end;
end;

procedure tlayouter.widgetregionchanged(const sender: twidget);
var
 int1: integer;
begin
 inherited;
 if not (csloading in componentstate) then begin
  if not (las_propsizing in fstate) then begin
   int1:= widgetinfoindex(sender);
   if int1 >= 0 then begin
    updatewidgetinfo(fwidgetinfos[int1],sender);
   end;
  end;
  if not (ws_loadedproc in fwidgetstate) then begin
   scalesizerefchanged;
   if (flayoutupdating = 0) and (plo_scalesize in fplace_options) and
       (sender.optionsskin * [osk_nopropwidth,osk_nopropheight] <> []) then begin
    scalebasechanged(sender);
   end;
   updatelayout;
  end;
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
  scalebasechanged(nil);
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
  if (plo_scalesize in avalue) and 
       (not (plo_scalesize in fplace_options) or 
        ((plo_noinvisible in avalue) xor 
         (plo_noinvisible in fplace_options))) then begin
   exclude(fstate,las_scalesizerefvalid);
   scalebasechanged(nil);
  end;
  fplace_options:= avalue;
  updatelayout;
 end;
end;

procedure tlayouter.clientrectchanged;
var
 refsi: sizety;
 pt1: pointty;
 size1: sizety;
 int1: integer;
begin
 inc(flayoutupdating);
 try
  inherited;
  exclude(fstate,las_scalesizerefvalid);
  if componentstate * [csloading,csdestroying] = [] then begin
   if (foptionslayout * [lao_scalewidth,lao_scaleheight,lao_scalefont,
                         lao_scalechildfont] <> []) and 
         not (las_propsizing in fstate) then begin
    beginscaling;
    include(fstate,las_propsizing);
    try
     if (lao_scalefont in foptionslayout) and (ffontsizeref.cx <> 0) and 
                  (ffontsizeref.cy <> 0) then begin
      font.height:= round((ffontheightref*clientheight)/ffontsizeref.cy);
      if clientheight > 0 then begin
       font.xscale:= (ffontxscaleref * (clientwidth/ffontsizeref.cx))/
                     (clientheight/ffontsizeref.cy);
      end;
     end;
     if foptionslayout * 
               [lao_scalewidth,lao_scaleheight,lao_scalefont] <> [] then begin
      refsi:= innerclientsize;
      for int1:= high(fwidgetinfos) downto 0 do begin
       with fwidgetinfos[int1] do begin
        if (lao_scalechildfont in foptionslayout) and 
                    not (osk_nopropfont in widget.optionsskin) and
                    (twidget1(widget).ffont <> nil) and
                    (reffontsize.cx <> 0) and (reffontsize.cy <> 0) and
                    (refsi.cy > 0) then begin
         twidget1(widget).ffont.height:= 
                              round(fontheight * refsi.cy / reffontsize.cy);
         twidget1(widget).ffont.xscale:= (fontxscale * (refsi.cx/refsi.cy))/
                      (reffontsize.cx/reffontsize.cy);
        end;
        pt1:= widget.pos;
        size1:= widget.clientsize;
        if refsize.cx <> 0 then begin
         if (lao_scaleleft in foptionslayout) and 
                    not (osk_nopropleft in widget.optionsskin) then begin
          pt1.x:= (pos.x * refsi.cx) div refsize.cx;
         end;
         if (lao_scalewidth in foptionslayout) and 
                    not (osk_nopropwidth in widget.optionsskin) then begin
          size1.cx:= (size.cx * refsi.cx) div refsize.cx;
         end;
        end;
        if refsize.cy <> 0 then begin
         if (lao_scaletop in foptionslayout) and 
                    not (osk_noproptop in widget.optionsskin) then begin
          pt1.y:= (pos.y * refsi.cy) div refsize.cy;
         end;
         if (lao_scaleheight in foptionslayout) and 
                    not (osk_nopropheight in widget.optionsskin) then begin
          size1.cy:= (size.cy * refsi.cy) div refsize.cy;
         end;
        end;
        widget.clientsize:= size1;
        widget.pos:= pt1;
       end;
      end;
     end;
    finally
     exclude(fstate,las_propsizing);
     endscaling;
    end;
   end;
  end;
 finally
  dec(flayoutupdating);
 end;
 updatelayout;
end;

procedure tlayouter.childautosizechanged(const sender: twidget);
begin
 inherited;
 updatelayout;
end;

procedure tlayouter.registerchildwidget(const child: twidget);
begin
 setlength(fwidgetinfos,high(fwidgetinfos)+2);
 updatewidgetinfo(fwidgetinfos[high(fwidgetinfos)],child);
 inherited;
end;

procedure tlayouter.unregisterchildwidget(const child: twidget);
var
 int1: integer;
begin
 if not (csdestroying in componentstate) then begin
  int1:= widgetinfoindex(child);
  if int1 >= 0 then begin
   finalize(fwidgetinfos[int1]);
   move(fwidgetinfos[int1+1],fwidgetinfos[int1],
            (high(fwidgetinfos)-int1)*sizeof(widgetlayoutinfoty));
   setlength(fwidgetinfos,high(fwidgetinfos));
  end;
 end;
 inherited;
end;

function tlayouter.widgetinfoindex(const awidget: twidget): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= high(fwidgetinfos) downto 0 do begin
  if fwidgetinfos[int1].widget = awidget then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tlayouter.updatewidgetinfo(var ainfo: widgetlayoutinfoty;
               const awidget: twidget);
var
 size1,size2: sizety;
 int1: integer;
 rea1: real;
begin
  with ainfo do begin
  if awidget <> nil then begin
   widget:= awidget;
  end;
  if not (csloading in componentstate) then begin
   size1:= widget.clientsize;
   if (flayoutupdating = 0) then begin
         //synchronize ref values with changed widget values
    size2:= self.scalesizeref;
    if size1.cx <> actscalesize.cx then begin
     refscalesize.cx:= size2.cx;
     scalesize.cx:= size1.cx;
     actscalesize.cx:= scalesize.cx;
    end;
    if size1.cy <> actscalesize.cy then begin
     refscalesize.cy:= size2.cy;
     scalesize.cy:= size1.cy;
     actscalesize.cy:= scalesize.cy;
    end;
   end;
   size2:= innerclientsize;
   if widget.bounds_x <> actpos.x then begin
    refsize.cx:= size2.cx;
    pos.x:= widget.bounds_x;
    actpos.x:= pos.x;
   end;
   if widget.bounds_y <> actpos.y then begin
    refsize.cy:= size2.cy;
    pos.y:= widget.bounds_y;
    actpos.y:= pos.y;
   end;
   if size1.cx <> actsize.cx then begin
    refsize.cx:= size2.cx;
    size.cx:= size1.cx;
    actsize.cx:= size1.cx;
   end;
   if size1.cy <> actsize.cy then begin
    refsize.cy:= size2.cy;
    size.cy:= size1.cy;
    actsize.cy:= size1.cy;
   end;
   if twidget1(widget).ffont <> nil then begin
    int1:= twidget1(widget).ffont.height;
    rea1:= twidget1(widget).ffont.xscale;
    if (int1 <> actfontheight) or (rea1 <> actfontxscale) then begin
     reffontsize:= size2;
     fontheight:= int1;
     actfontheight:= int1;
     fontxscale:= rea1;
     actfontxscale:= rea1;
    end;
   end;
  end;
 end;
end;

function tlayouter.scalesizeref: sizety;
begin
 if not (las_scalesizerefvalid in fstate) then begin
  updatescalesizeref;
 end;
 result:= fscalesizeref;
end;

procedure tlayouter.scalesizerefchanged;
begin
 if (componentstate * [csloading,csdestroying] = []) and 
                            (flayoutupdating = 0) then begin
  exclude(fstate,las_scalesizerefvalid);
 end;
end;

procedure tlayouter.scalebasechanged(const sender: twidget);
var
 int1: integer;
 size1: sizety;
begin
 if not (csloading in componentstate) then begin
  scalesizerefchanged;
  size1:= scalesizeref;
  for int1:= high(fwidgetinfos) downto 0 do begin
   with fwidgetinfos[int1] do begin
    scalesize:= widget.clientsize;
    actscalesize:= scalesize;
    refscalesize:= size1;
   end;
  end;
 end;
end;

end.
