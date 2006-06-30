{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesimplewidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msegui,mseguiglob,msetypes,msestrings,msegraphics,mseevent,mseactions,msewidgets,
 mserichstring,mseshapes,Classes,mseclasses,msebitmap,msedrawtext,
 msedrag,msestockobjects;

const
 defaultbuttonwidth = 50;
 defaultbuttonheight = 20;
 defaultlabeltextflags = [tf_ycentered];
 defaultlabeloptionswidget = (defaultoptionswidget + [ow_fontglyphheight]) - 
              [ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 defaultlabelwidgetwidth = 100;
 defaultlabelwidgetheight = 20;

type

 tpaintbox = class(tpublishedwidget)
  private
   fonbeforepaint: painteventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
  protected
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure doonpaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
  published
   property onbeforepaint: painteventty read fonbeforepaint write fonbeforepaint;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
 end;

 teventwidget = class(tcustomeventwidget)
  published
   property onenter;
   property onexit;
   property onfocus;
   property ondefocus;

   property onmouseevent;
   property onchildmouseevent;
   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onloaded;

   property onbeforepaint;
   property onpaint;
   property onafterpaint;

   property onshow;
   property onhide;
   property onactivate;
   property ondeactivate;
   property onresize;
   property onmove;
   property onclosequery;

 end;

 tcustombutton = class(tactionsimplebutton,iactionlink)
  private
   fmodalresult: modalresultty;
   factioninfo: actioninfoty;
   procedure setcaption(const Value: captionty);
   function getframe: tframe;
   procedure setframe(const Value: tframe);
   function getcaption: captionty;
   procedure setonexecute(const value: notifyeventty);
   procedure setaction(const value: tcustomaction); virtual;
   function getactioninfopo: pactioninfoty;
   function isonexecutestored: boolean;
   function iscaptionstored: boolean;
   function getstate: actionstatesty;
   procedure setstate(const value: actionstatesty); virtual;
   function isstatestored: boolean;
   procedure setimagelist(const Value: timagelist);
   function isimageliststored: Boolean;
   procedure setimagenr(const Value: integer);
   function isimagenrstored: Boolean;
   procedure setcolorglyph(const avalue: colorty);
   function iscolorglyphstored: boolean;
   procedure setcaptionpos(const avalue: captionposty);
  protected
   function gethint: msestring; override;
   procedure sethint(const Value: msestring); override;
   function ishintstored: boolean; override;

   procedure actionchanged;
   procedure readstate(reader: treader); override;
   procedure loaded; override;
   procedure enabledchanged; override;
   procedure visiblechanged; override;
   procedure doexecute; override;
   procedure doenter; override;
   procedure doexit; override;
   procedure dopaint(const canvas: tcanvas); override;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure synctofontheight; override;

   property bounds_cx default defaultbuttonwidth;
   property bounds_cy default defaultbuttonheight;
   property frame: tframe read getframe write setframe;
   property action: tcustomaction read factioninfo.action write setaction;
   property caption: captionty read getcaption write setcaption stored iscaptionstored;
   property captionpos: captionposty read finfo.captionpos write setcaptionpos
                              default cp_center;
   property imagelist: timagelist read factioninfo.imagelist write setimagelist
                    stored isimageliststored;
   property imagenr: integer read factioninfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property colorglyph: colorty read factioninfo.colorglyph write setcolorglyph
                      stored iscolorglyphstored default cl_glyph;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property modalresult: modalresultty read fmodalresult write fmodalresult
                                default mr_none;
   property onexecute: notifyeventty read factioninfo.onexecute
                            write setonexecute stored isonexecutestored;
  published
   property state: actionstatesty read getstate write setstate stored isstatestored;
 end;

 tbutton = class(tcustombutton)
  published
   property action;
   property caption;
   property captionpos;
   property font;
   property modalresult;
   property imagelist;
   property imagenr;
   property colorglyph;
   property options;
   property onexecute;
 end;

 tstockglyphbutton = class(tcustombutton)
  private
   fglyph: stockglyphty;
   procedure setglyph(const avalue: stockglyphty);
   procedure setstate(const avalue: actionstatesty); override;
   procedure setaction(const avalue: tcustomaction); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property glyph: stockglyphty read fglyph write setglyph default stg_none;
   property action;
   property caption;
   property captionpos;
   property font;
   property modalresult;
   property colorglyph;
   property options;
   property onexecute;
 end;

 tcustomlabel = class(tpublishedwidget)
  private
   fcaption: richstringty;
   ftextflags: textflagsty;
   procedure setcaption(const Value: msestring);
   function getcaption: msestring;
   procedure settextflags(const Value: textflagsty);
  protected
   procedure dopaint(const canvas: tcanvas); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure synctofontheight; override;
   property caption: msestring read getcaption write setcaption;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property textflags: textflagsty read ftextflags write settextflags default defaultlabeltextflags;
 end;

 tlabel = class(tcustomlabel)
  published
   property optionswidget default defaultlabeloptionswidget;
   property caption;
   property font;
   property textflags;
   property bounds_cx default defaultlabelwidgetwidth;
   property bounds_cy default defaultlabelwidgetheight;
 end;
 
 tgroupboxframe = class(tcaptionframe)
  public
   constructor create(const intf: iframe);
  published
   property levelo default -1;
   property leveli default 1;
   property captiondist default - 4;
   property captionoffset default 4;
 end;

 tscalingwidget = class(tpublishedwidget)
  private
   fonfontheightdelta: fontheightdeltaeventty;
   fonchildscaled: notifyeventty;
  protected
   procedure dofontheightdelta(var delta: integer); override;
  public
   procedure dochildscaled(const sender: twidget); override;
  published
   property onfontheightdelta: fontheightdeltaeventty read fonfontheightdelta
                     write fonfontheightdelta;
   property onchildscaled: notifyeventty read fonchildscaled write fonchildscaled;
 end;

 tgroupbox = class(tscalingwidget)
  protected
   procedure createframe; override;
  public
   procedure initnewcomponent; override;
 end;

 tscrollbox = class(tscalingwidget)
  private
   function getframe: tscrollboxframe;
   procedure setframe(const value: tscrollboxframe);
  protected
   procedure createframe; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property frame: tscrollboxframe read getframe write setframe;
 end;

 tstepboxframe = class(tcustomstepframe)
  published
   property levelo;
   property leveli;
   property framewidth;
   property colorframe;
   property colorclient;
   property colorbutton;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property caption;
   property captionpos;
   property font;
   property buttonsize;
   property buttonpos;
   property buttonslast;
   property buttonsinline;
   property buttonsinvisible;
   property buttonsvisible;
 end;

 stepdirty = (sd_right,sd_up,sd_left,sd_down);

 stepeventty = procedure (const sender: tobject; const stepkind: stepkindty) of object;

 tcustomstepbox = class(tpublishedwidget,istepbar,idragcontroller)
  private
   fonstep: stepeventty;
   function getframe: tstepboxframe;
   procedure setframe(const value: tstepboxframe);
  protected
   fdragcontroller: tdragcontroller;
//   finvisiblebuttons: stepkindsty;
   procedure createframe; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dostep(const event: stepkindty); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   property onstep: stepeventty read fonstep write fonstep;
//   property invisiblebuttons: stepkindsty read finvisiblebuttons write setinvisiblebuttons;

  published
   property frame: tstepboxframe read getframe write setframe;
   property optionswidget default defaultoptionswidgetnofocus;
 end;

 tstepbox = class(tcustomstepbox)
  published
   property onstep;
//   property invisiblebuttons;
 end;

implementation
uses
 msegraphutils,msekeyboard,sysutils;

{ tcustombutton }

constructor tcustombutton.create(aowner: tcomponent);
begin
 initactioninfo(factioninfo);
 inherited;
 include(fwidgetstate,ws_nodesignframe);
 size:= makesize(defaultbuttonwidth,defaultbuttonheight);
end;

procedure tcustombutton.synctofontheight;
begin
 inherited;
 bounds_cy:= font.glyphheight + innerclientframewidth.cy + 6;
end;

procedure tcustombutton.doexecute;
begin
 if assigned(factioninfo.onexecute) then begin
  factioninfo.onexecute(self);
 end;
 if fmodalresult <> mr_none then begin
  window.modalresult:= fmodalresult;
 end;
end;                                           

procedure tcustombutton.dopaint(const canvas: tcanvas);
begin
 finfo.font:= getfont;
 inherited;
end;

function tcustombutton.checkfocusshortcut(var info: keyeventinfoty): boolean;
begin
 result:= inherited checkfocusshortcut(info) or
     (bo_focusonshortcut in options) and
          mserichstring.checkshortcut(info,factioninfo.caption1,true) and canfocus;
end;

procedure tcustombutton.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if not (es_processed in info.eventstate) then begin
  if (bo_executeonshortcut in options) and
           mserichstring.checkshortcut(info,factioninfo.caption1,true) and
           not (ss_disabled in finfo.state) or
     (finfo.state * [ss_invisible,ss_disabled,ss_default] = [ss_default]) and
       (info.key = key_return) and (info.shiftstate = []) then begin
   include(info.eventstate,es_processed);
   if (fmodalresult = mr_cancel) or window.candefocus then begin
    doexecute;
   end
   else begin
    exclude(info.eventstate,es_processed);
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

function tcustombutton.getframe: tframe;
begin
 result:= tframe(fframe);
end;

procedure tcustombutton.setframe(const Value: tframe);
begin
 fframe.Assign(value);
end;

procedure tcustombutton.enabledchanged;
begin
 inherited;
 {
 if enabled then begin
  state:= state - [as_disabled];
 end
 else begin
  state:= state + [as_disabled];
 end;
 }
 invalidate;
end;

procedure tcustombutton.visiblechanged;
begin
 inherited;
 {
 if visible then begin
  state:= state - [as_invisible];
 end
 else begin
  state:= state + [as_invisible];
 end;
 }
end;

procedure tcustombutton.actionchanged;
begin
 actioninfotoshapeinfo(self,factioninfo,finfo);
 if csdesigning in componentstate then begin
  exclude(finfo.state,ss_invisible);
 end;
end;

function tcustombutton.getactioninfopo: pactioninfoty;
begin
 result:= @factioninfo;
end;

procedure tcustombutton.setaction(const value: tcustomaction);
begin
 linktoaction(iactionlink(self),value,factioninfo);
end;

procedure tcustombutton.setonexecute(const value: notifyeventty);
begin
 setactiononexecute(iactionlink(self),value);
end;

function tcustombutton.isonexecutestored: boolean;
begin
 result:= isactiononexecutestored(factioninfo);
end;

function tcustombutton.getcaption: captionty;
begin
 result:= factioninfo.captiontext;
end;

procedure tcustombutton.setcaption(const Value: captionty);
begin
 setactioncaption(iactionlink(self),value);
end;

function tcustombutton.iscaptionstored: boolean;
begin
 result:= isactioncaptionstored(factioninfo);
end;

procedure tcustombutton.setimagelist(const Value: timagelist);
begin
 setactionimagelist(iactionlink(self),Value);
end;

function tcustombutton.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(factioninfo);
end;

procedure tcustombutton.setimagenr(const Value: integer);
begin
 setactionimagenr(iactionlink(self),Value);
end;

function tcustombutton.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(factioninfo);
end;

procedure tcustombutton.setcolorglyph(const avalue: colorty);
begin
 setactioncolorglyph(iactionlink(self),avalue);
end;

function tcustombutton.iscolorglyphstored: boolean;
begin
 result:= isactioncolorglyphstored(factioninfo);
end;

function tcustombutton.gethint: msestring;
begin
 result:= factioninfo.hint;
end;

procedure tcustombutton.sethint(const Value: msestring);
begin
 setactionhint(iactionlink(self),value);
end;

function tcustombutton.ishintstored: boolean;
begin
 result:= isactionhintstored(factioninfo);
end;

function tcustombutton.getstate: actionstatesty;
begin
 result:= factioninfo.state;
end;

procedure tcustombutton.setstate(const value: actionstatesty);
begin
 setactionstate(iactionlink(self),value);
 visible:= not (as_invisible in factioninfo.state);
 enabled:= not (as_disabled in factioninfo.state);
end;

function tcustombutton.isstatestored: boolean;
begin
 result:= isactionstatestored(factioninfo);
end;

procedure tcustombutton.setcaptionpos(const avalue: captionposty);
begin
 if avalue <> finfo.captionpos then begin
  if avalue in [cp_left,cp_right] then begin
   finfo.captionpos:= avalue;
  end
  else begin
   finfo.captionpos:= cp_center;
  end;
  invalidate;
 end;
end;

{
procedure tcustombutton.setenabled(const Value: boolean);
begin
 inherited;
 if value then begin
  state:= state -[ss_disabled];
 end
 else begin
  state:= state +[ss_disabled];
 end;
end;

function tcustombutton.isenabledstored: Boolean;
begin
 result:= isactionenabledstored(factioninfo);
end;


procedure tcustombutton.setvisible(const Value: boolean);
begin
 inherited;
 setactionvisible(iactionlink(self),value);
end;

function tcustombutton.isvisiblestored: Boolean;
begin
 result:= isactionvisiblestored(factioninfo);
end;
}
procedure tcustombutton.readstate(reader: treader);
begin
 actionbeginload(iactionlink(self));
 inherited;
end;

procedure tcustombutton.loaded;
begin
 inherited;
 actionendload(iactionlink(self));
// actionchanged;
end;
{
procedure tcustombutton.doidle;
begin
 actiondoidle(factioninfo);
 inherited;
end;
}
procedure tcustombutton.doenter;
var
 int1: integer;
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget1:= fparentwidget.widgets[int1];
   if widget1 is tcustombutton then begin
    with tcustombutton(widget1) do begin
     if ss_default in finfo.state then begin
      exclude(finfo.state,ss_default);
      invalidate;
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustombutton.doexit;
var
 int1: integer;
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget1:= fparentwidget.widgets[int1];
   if widget1 is tcustombutton then begin
    with tcustombutton(widget1) do begin
     if as_default in factioninfo.state then begin
      if not (ss_default in finfo.state) then begin
       include(finfo.state,ss_default);
       invalidate;
      end;
     end;
    end;
   end;
  end;
 end;
 inherited;
end;
{
function tcustombutton.getobjectlink: iobjectlink;
begin
 result:= iactionlink(self);
end;
}
{ tstockglyphbutton }

constructor tstockglyphbutton.create(aowner: tcomponent);
begin
 inherited;
 imagelist:= stockobjects.glyphs;
 glyph:= stg_none;
end;

procedure tstockglyphbutton.setglyph(const avalue: stockglyphty);
begin
 fglyph:= avalue;
 imagenr:= ord(avalue);
end;

procedure tstockglyphbutton.setstate(const avalue: actionstatesty);
begin
 inherited setstate(avalue + [as_localimagelist,as_localimagenr]);
end;

procedure tstockglyphbutton.setaction(const avalue: tcustomaction);
begin
 inherited;
 glyph:= glyph;
 imagelist:= stockobjects.glyphs;
end;

{ tcustomlabel }

constructor tcustomlabel.create(aowner: tcomponent);
begin
 ftextflags:= defaultlabeltextflags;
 inherited;
 foptionswidget:= defaultlabeloptionswidget;
 fwidgetrect.cx:= defaultlabelwidgetwidth;
 fwidgetrect.cy:= defaultlabelwidgetheight;
end;

procedure tcustomlabel.dopaint(const canvas: tcanvas);
begin
 inherited;
 drawtext(canvas,fcaption,innerclientrect,ftextflags,font);
end;

function tcustomlabel.getcaption: msestring;
begin
 result:= richstringtocaption(fcaption);
end;

procedure tcustomlabel.setcaption(const Value: msestring);
begin
 captiontorichstring(Value,fcaption);
 invalidate;
end;

procedure tcustomlabel.settextflags(const Value: textflagsty);
begin
 if ftextflags <> value then begin
  ftextflags:= Value;
  invalidate;
 end;
end;

procedure tcustomlabel.synctofontheight;
begin
 syncsinglelinefontheight;
end;

{ tgroupboxframe }

constructor tgroupboxframe.create(const intf: iframe);
begin
 inherited;
 fi.levelo:= -1;
 fi.leveli:= 1;
 captiondist:= -4;
 captionoffset:= 4;
end;

{ tscalingwidget }

procedure tscalingwidget.dochildscaled(const sender: twidget);
begin
 if canevent(tmethod(fonchildscaled)) then begin
  fonchildscaled(self);
 end
 else begin
  inherited;
 end;
end;

procedure tscalingwidget.dofontheightdelta(var delta: integer);
begin
 if canevent(tmethod(fonfontheightdelta)) then begin
  fonfontheightdelta(self,delta);
 end;
 inherited;
end;

{ tgroupbox }

procedure tgroupbox.initnewcomponent;
begin
 inherited;
 createframe;
end;

procedure tgroupbox.createframe;
begin
 tgroupboxframe.create(iframe(self));
end;

{ tscrollbox }

constructor tscrollbox.create(aowner: tcomponent);
begin
 inherited;
 createframe;
end;

procedure tscrollbox.createframe;
begin
 tscrollboxframe.create(iframe(self),self);
end;

function tscrollbox.getframe: tscrollboxframe;
begin
 result:= tscrollboxframe(inherited getframe);
end;

procedure tscrollbox.mouseevent(var info: mouseeventinfoty);
begin
 tscrollframe(fframe).mouseevent(info);
 inherited;
end;

procedure tscrollbox.setframe(const value: tscrollboxframe);
begin
 inherited setframe(value);
end;

procedure tscrollbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 tscrollboxframe(fframe).updateclientrect;
end;

{ tcustomstepbox }

constructor tcustomstepbox.create(aowner: tcomponent);
begin
 inherited;
 createframe;
 if fdragcontroller = nil then begin
  fdragcontroller:= tdragcontroller.create(idragcontroller(self));
 end;
 optionswidget:= defaultoptionswidgetnofocus;
end;

destructor tcustomstepbox.destroy;
begin
 fdragcontroller.Free;
 inherited;
end;

procedure tcustomstepbox.createframe;
begin
 tstepboxframe.create(iframe(self),istepbar(self));
end;

procedure tcustomstepbox.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  fdragcontroller.clientmouseevent(info);
 end;
end;

procedure tcustomstepbox.mouseevent(var info: mouseeventinfoty);
begin
 tstepboxframe(fframe).mouseevent(info);
 inherited;
end;

function tcustomstepbox.getframe: tstepboxframe;
begin
 result:= tstepboxframe(inherited getframe);
end;

procedure tcustomstepbox.setframe(const value: tstepboxframe);
begin
 inherited setframe(value);
end;

procedure tcustomstepbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 tscrollboxframe(fframe).updateclientrect;
end;

procedure tcustomstepbox.dostep(const event: stepkindty);
begin
 if canevent(tmethod(fonstep)) then begin
  fonstep(self,event);
 end;
end;

{ tpaintbox }

procedure tpaintbox.dobeforepaint(const canvas: tcanvas);
var
 saveindex: integer;
begin
 inherited;
 if canevent(tmethod(fonbeforepaint)) then begin
  saveindex:= canvas.save;
  canvas.move(clientwidgetpos);
  fonbeforepaint(self,canvas);
  canvas.restore(saveindex);
 end;
end;

procedure tpaintbox.doonpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,canvas);
 end;
end;

procedure tpaintbox.doafterpaint(const canvas: tcanvas);
var
 saveindex: integer;
begin
 inherited;
 if canevent(tmethod(fonafterpaint)) then begin
  saveindex:= canvas.save;
  canvas.move(clientwidgetpos);
  fonafterpaint(self,canvas);
  canvas.restore(saveindex);
 end;
end;

end.

