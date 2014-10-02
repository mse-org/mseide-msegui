{ MSEgui Copyright (c) 1999-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedispwidgets;

{$ifdef FPC}
 {$mode objfpc}{$h+}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 classes,mclasses,msegui,mseguiglob,msewidgets,msegraphics,
 msedrawtext,msegraphutils,
 msemenus,msetypes,msestrings,mseformatstr,mseevent,mseclasses,mserichstring
 {$ifdef mse_with_ifi}
  ,mseificomp,mseifiglob,mseificompglob,typinfo,msedatalist
 {$endif};

const
 defaultdisptextflags = [tf_ycentered];
 defaultdispwidgetwidth = 100;
 defaultdispwidgetheight = 20;
 defaultdispwidgetoptions = (defaultoptionswidget -
                                 [ow_mousefocus,ow_tabfocus,ow_arrowfocus]){ +
                                 [ow_fontglyphheight]};

 defaultdispwidgetoptions1 = defaultoptionswidget1 + [ow1_fontglyphheight];

type

 tdispframe = class(tcustomcaptionframe)
  public
   constructor create(const intf: icaptionframe);
  published
   property options;
   property levelo default -1;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;

   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;
   
   property optionsskin;

   property colorclient;
   property caption;
   property captiontextflags;
   property captionpos;
   property captiondist;
//   property captiondistouter;
//   property captionframecentered;
   property captionoffset;
//   property captionnoclip;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
 end;

 dispwidgetoptionty = (dwo_hintclippedtext,dwo_nogray,
                                       dwo_showlocal,dwo_showutc);
 dispwidgetoptionsty = set of dispwidgetoptionty;
 
 tdispwidget = class(tpublishedwidget{$ifdef mse_with_ifi},iifidatalink{$endif})
  private
   finfo: drawtextinfoty;
   ftext: msestring;
   foptions: dispwidgetoptionsty;
   ftextflags: textflagsty;
   ftextrectvalid: boolean;
   fonchange: notifyeventty;
   procedure updatetextflags;
   procedure settextflags(const value: textflagsty);
   procedure settext(const avalue: msestring);
  protected
{$ifdef mse_with_ifi}
   fifilink: tifilinkcomp;
   function getdefaultifilink: iifilink; override;
    //iifidatalink
   function getifilinkkind: ptypeinfo;
   procedure setifilink(const avalue: tifilinkcomp);
   function ifigriddata: tdatalist;
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   function getgriddata: tdatalist;
   function getvalueprop: ppropinfo;
   procedure updatereadonlystate;
{$endif}
   procedure invalidatetext;
   procedure setoptions(const avalue: dispwidgetoptionsty); virtual;
   procedure valuechanged; virtual;
   procedure formatchanged;
   function getvaluetext: msestring; virtual; abstract;
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure clientrectchanged; override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure fontchanged; override;
   procedure internalcreateframe; override;
   procedure doloaded; override;
   procedure showhint(var info: hintinfoty); override;
   procedure enabledchanged; override;
   function verticalfontheightdelta: boolean; override;
   class function classskininfo: skininfoty; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent(const ascale: real); override;
   procedure synctofontheight; override;
   procedure clear; virtual;
  published
   property text: msestring read ftext write settext;
                //overrides valuetext
   property disptext: msestring read finfo.text.text;
   property bounds_cx default defaultdispwidgetwidth;
   property bounds_cy default defaultdispwidgetheight;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property textflags: textflagsty read ftextflags write settextflags
                default defaultdisptextflags;
   property optionswidget default defaultdispwidgetoptions;
   property optionswidget1 default defaultdispwidgetoptions1;
   property options: dispwidgetoptionsty read foptions write setoptions default [];
   property onchange: notifyeventty read fonchange write fonchange;
   property onshowhint;
 end;

 tbasestringdisp = class(tdispwidget)
  private
  {$ifdef mse_with_ifi}
   function getifilink: tifistringlinkcomp;
   procedure setifilink(const avalue: tifistringlinkcomp);
  {$endif}
  protected
  published
{$ifdef mse_with_ifi}
   property ifilink: tifistringlinkcomp read getifilink write setifilink;
{$endif}
 end;

 tcustomstringdisp = class(tbasestringdisp)
  private
   fvalue: msestring;
   fondatachange: updatestringeventty;
   procedure setvalue(const Value: msestring);
  protected
   function getvaluetext: msestring; override;
   procedure valuechanged; override;
  public
   procedure clear; override;
   property value: msestring read fvalue write setvalue;
  published
   property ondatachange: updatestringeventty read fondatachange 
                                                    write fondatachange;
 end;
 
 tstringdisp = class(tcustomstringdisp)
  published
   property value;
 end;

 tcustomrichstringdisp = class(tbasestringdisp)
  private
//   fvalue: richstringty;
   fondatachange: updaterichstringeventty;
   procedure setvalue(const avalue: msestring);
   procedure setrichvalue(const avalue: richstringty);
  protected
   function getvaluetext: msestring; override;
   procedure valuechanged; override;
  public
   procedure clear; override;
   property value: msestring read finfo.text.text write setvalue;
   property richvalue: richstringty read finfo.text write setrichvalue;
  published
   property ondatachange: updaterichstringeventty read fondatachange
                                                      write fondatachange;
 end;

 trichstringdisp = class(tcustomrichstringdisp)
  published
   property value;
 end;
  
 tbytestringdisp = class(tdispwidget)
  private
   fvalue: string;
   fondatachange: updateansistringeventty;
   fbase: numbasety;
   procedure setvalue(const Value: string);
   procedure setbase(const Value: numbasety);
  protected
   function getvaluetext: msestring; override;
   procedure valuechanged; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
  published
   property value: string read fvalue write setvalue;
   property ondatachange: updateansistringeventty read fondatachange 
                                                       write fondatachange;
   property base: numbasety read fbase write setbase default nb_hex;
 end;

const
 defaultnumdisptextflags = defaultdisptextflags + [tf_right];

type
 tnumdisp = class(tdispwidget)
  protected
  public
   constructor create(aowner: tcomponent); override;
  published
   property textflags default defaultnumdisptextflags;
 end;

 tcustomintegerdisp = class(tnumdisp)
  private
   fvalue: integer;
   fondatachange: updateintegereventty;
   fbase: numbasety;
   fbitcount: integer;
   procedure setvalue(const Value: integer);
   procedure setbase(const Value: numbasety);
   procedure setbitcount(const Value: integer);
  {$ifdef mse_with_ifi}
   function getifilink: tifiintegerlinkcomp;
   procedure setifilink(const avalue: tifiintegerlinkcomp);
  {$endif}
  protected
   function getvaluetext: msestring; override;
   procedure valuechanged; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property value: integer read fvalue write setvalue default 0;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
   property ondatachange: updateintegereventty read fondatachange
                                                       write fondatachange;
{$ifdef mse_with_ifi}
   property ifilink: tifiintegerlinkcomp read getifilink write setifilink;
{$endif}
 end;

 tintegerdisp = class(tcustomintegerdisp)
  published
   property value;
 end;
 
 tcustomint64disp = class(tnumdisp)
  private
   fvalue: int64;
   fondatachange: updateint64eventty;
   fbase: numbasety;
   fbitcount: integer;
   procedure setvalue(const Value: int64);
   procedure setbase(const Value: numbasety);
   procedure setbitcount(const Value: integer);
  {$ifdef mse_with_ifi}
   function getifilink: tifiint64linkcomp;
   procedure setifilink(const avalue: tifiint64linkcomp);
  {$endif}
  protected
   function getvaluetext: msestring; override;
   procedure valuechanged; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property value: int64 read fvalue write setvalue default 0;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 64;
   property ondatachange: updateint64eventty read fondatachange
                                                       write fondatachange;
{$ifdef mse_with_ifi}
   property ifilink: tifiint64linkcomp read getifilink write setifilink;
{$endif}
 end;

 tint64disp = class(tcustomint64disp)
  published
   property value;
 end;
 
 tcustomrealdisp = class(tnumdisp)
  private
   fvalue: realty;
   fondatachange: updaterealeventty;
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   procedure setvalue(const avalue: realty);
   procedure readvalue(reader: treader);
//   procedure writevalue(writer: twriter);
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  {$ifdef mse_with_ifi}
   function getifilink: tifireallinkcomp;
   procedure setifilink(const avalue: tifireallinkcomp);
  {$endif}
  protected
   procedure valuechanged; override;
   function getvaluetext: msestring; override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property value: realty read fvalue write setvalue {stored false};
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
   property ondatachange: updaterealeventty read fondatachange 
                                                    write fondatachange;
{$ifdef mse_with_ifi}
   property ifilink: tifireallinkcomp read getifilink write setifilink;
{$endif}
 end;

 trealdisp = class(tcustomrealdisp)
  published
   property value{stored false};
 end;
 
 tcustomdatetimedisp = class(tnumdisp)
  private
   fvalue: tdatetime;
   fondatachange: updatedatetimeeventty;
   fformat: msestring;
   fkind: datetimekindty;
   fconvert: dateconvertty;
   procedure setvalue(const avalue: tdatetime);
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
   procedure readvalue(reader: treader);
//   procedure writevalue(writer: twriter);
  {$ifdef mse_with_ifi}
   function getifilink: tifidatetimelinkcomp;
   procedure setifilink(const avalue: tifidatetimelinkcomp);
  {$endif}
  protected
   procedure setoptions(const avalue: dispwidgetoptionsty); override;
   procedure valuechanged; override;
   function getvaluetext: msestring; override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property value: tdatetime read fvalue write setvalue;
  published
   property format: msestring read fformat write setformat;
   property ondatachange: updatedatetimeeventty read fondatachange 
                                                         write fondatachange;
   property kind: datetimekindty read fkind write setkind default dtk_date;
{$ifdef mse_with_ifi}
   property ifilink: tifidatetimelinkcomp read getifilink write setifilink;
{$endif}
 end;

 tdatetimedisp = class(tcustomdatetimedisp)
  published
   property value{ stored false};
 end;
  
 tcustombooleandisp = class(tdispwidget)
  private
   fvalue: boolean;
   fondatachange: updatebooleaneventty;
   ftext_false: msestring;
   ftext_true: msestring;
   procedure setvalue(const Value: boolean);
   procedure settext_false(const avalue: msestring);
   procedure settext_true(const avalue: msestring);
  protected
   procedure valuechanged; override;
   function getvaluetext: msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property value: boolean read fvalue write setvalue default false;
  published
   property textflags default defaultdisptextflags + [tf_xcentered];
   property ondatachange: updatebooleaneventty read fondatachange 
                                                       write fondatachange;
   property text_false: msestring read ftext_false write settext_false;
   property text_true: msestring read ftext_true write settext_true;
 end;
 
 tbooleandisp = class(tcustombooleandisp)
  published
   property value;
 end;

implementation
uses
 sysutils,msereal,math,msestreaming,msedate,msebits;

{ tdispframe }

constructor tdispframe.create(const intf: icaptionframe);
begin
 inherited;
// clientcolor:= cl_foreground;
 fi.levelo:= -1;
 inflateframe1(fi.innerframe,1);
 internalupdatestate;
end;

{ tdispwidget }

constructor tdispwidget.create(aowner: tcomponent);
begin
 inherited;
 foptionswidget:= defaultdispwidgetoptions;
 foptionswidget1:= defaultdispwidgetoptions1;
 fwidgetrect.cx:= defaultdispwidgetwidth;
 fwidgetrect.cy:= defaultdispwidgetheight;
 ftextflags:= defaultdisptextflags;
 finfo.flags:= ftextflags;
end;

class function tdispwidget.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_dispwidget;
end;

procedure tdispwidget.initnewcomponent(const ascale: real);
begin
 inherited;
 internalcreateframe;
 fframe.scale(ascale);
// synctofontheight;
end;

procedure tdispwidget.settextflags(const value: textflagsty);
begin
 if ftextflags <> value then begin
  ftextflags:= value;
  updatetextflags;
  invalidatetext;
 end;
end;

procedure tdispwidget.clientrectchanged;
begin
 ftextrectvalid:= false;
 inherited;
 finfo.dest:= innerclientrect;
end;

procedure tdispwidget.getautopaintsize(var asize: sizety);
var
 fram1: framety;
begin
 if fframe = nil then begin
  fram1:= nullframe;
 end
 else begin
  fram1:= fframe.framei;
 end;
 if not ftextrectvalid then begin
  msedrawtext.textrect(getcanvas,finfo);
  ftextrectvalid:= true;
 end;
 asize.cx:= finfo.res.size.cx + fram1.left + fram1.right;
 asize.cy:= finfo.res.size.cy + fram1.top + fram1.bottom;
end;

procedure tdispwidget.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
 drawtext(canvas,finfo);
 ftextrectvalid:= true;
end;

procedure tdispwidget.fontchanged;
begin
 finfo.font:= getfont;
 invalidatetext;
 inherited;
end;

procedure tdispwidget.internalcreateframe;
begin
 tdispframe.create(iscrollframe(self));
end;

procedure tdispwidget.settext(const avalue: msestring);
begin
 ftext:= avalue;
 if avalue = '' then begin
  finfo.text.text:= getvaluetext;
 end
 else begin
  finfo.text.text:= avalue;
 end;
 invalidatetext;
end;

procedure tdispwidget.valuechanged;
begin
 if ftext = '' then begin
  finfo.text.text:= getvaluetext;
  ftextrectvalid:= false;
  invalidatetext;
 end;
{$ifdef mse_with_ifi}
 if not (ws_loadedproc in fwidgetstate) then begin
  if fifiserverintf <> nil then begin
   fifiserverintf.valuechanged(iifidatalink(self));
  end;
 end;
{$endif}
 if canevent(tmethod(fonchange)) then begin
  fonchange(self);
 end;
end;

{$ifdef mse_with_ifi}
function tdispwidget.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

procedure tdispwidget.setifilink(const avalue: tifilinkcomp);
begin
 mseificomp.setifilinkcomp(iifidatalink(self),avalue,fifilink);
end;

function tdispwidget.ifigriddata: tdatalist;
begin
 result:= nil;
end;

procedure tdispwidget.updateifigriddata(const sender: tobject; 
                                                const alist: tdatalist);
begin
 //dummy
end;

function tdispwidget.getgriddata: tdatalist;
begin
 result:= nil;
end;

function tdispwidget.getvalueprop: ppropinfo;
begin
 result:= getpropinfo(self,'value');
end;

procedure tdispwidget.updatereadonlystate;
begin
 //dummy
end;

{$endif}

procedure tdispwidget.formatchanged;
begin
 if ftext = '' then begin
  finfo.text.text:= getvaluetext;
  invalidatetext;
 end;
end;

procedure tdispwidget.doloaded;
begin
 inherited;
 valuechanged;
end;

procedure tdispwidget.showhint(var info: hintinfoty);
begin
 if (dwo_hintclippedtext in foptions) and getshowhint and 
                                   textclipped(getcanvas,finfo) then begin
  info.caption:= finfo.text.text;
 end;
 inherited;
end;

function tdispwidget.verticalfontheightdelta: boolean;
begin
 result:= tf_rotate90 in textflags;
end;

procedure tdispwidget.synctofontheight;
begin
 syncsinglelinefontheight;
end;

procedure tdispwidget.updatetextflags;
begin
 if not (csloading in componentstate) then begin
  if isenabled or (dwo_nogray in foptions) then begin
   finfo.flags:= ftextflags;
  end
  else begin
   finfo.flags:= ftextflags + [tf_grayed];
  end;
 end;
end;

procedure tdispwidget.enabledchanged;
begin
 inherited;
 updatetextflags;
 invalidate;
end;

procedure tdispwidget.setoptions(const avalue: dispwidgetoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue-[dwo_showlocal,dwo_showutc];
  updatetextflags;
  invalidatetext;
 end;
end;

procedure tdispwidget.invalidatetext;
begin
 ftextrectvalid:= false;
 invalidate;
 checkautosize;
end;

procedure tdispwidget.clear;
begin
 //dummy
end;

{$ifdef mse_with_ifi}

function tdispwidget.getdefaultifilink: iifilink;
begin
 result:= iifidatalink(self);
end;

function tbasestringdisp.getifilink: tifistringlinkcomp;
begin
 result:= tifistringlinkcomp(fifilink);
end;

procedure tbasestringdisp.setifilink(const avalue: tifistringlinkcomp);
begin
 inherited setifilink(avalue);
end;

{$endif}

{ tcustomstringdisp }

function tcustomstringdisp.getvaluetext: msestring;
begin
 result:= fvalue;
end;

procedure tcustomstringdisp.setvalue(const Value: msestring);
begin
 if fvalue <> value then begin
  fvalue := Value;
  valuechanged;
 end;
end;

procedure tcustomstringdisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 inherited;
end;

procedure tcustomstringdisp.clear;
begin
 value:= '';
end;

{ tcustomrichstringdisp }

procedure tcustomrichstringdisp.setvalue(const avalue: msestring);
begin
// if fvalue <> value then begin
 finfo.text.text:= avalue;
 finfo.text.format:= nil;
 valuechanged;
// end;
end;

procedure tcustomrichstringdisp.setrichvalue(const avalue: richstringty);
begin
 finfo.text:= avalue;
 valuechanged;
end;

function tcustomrichstringdisp.getvaluetext: msestring;
begin
 result:= finfo.text.text;
end;

procedure tcustomrichstringdisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,finfo.text);
 end;
 inherited;
end;

procedure tcustomrichstringdisp.clear;
begin
 richvalue:= emptyrichstring;
end;

{ tbytestringdisp }

constructor tbytestringdisp.create(aowner: tcomponent);
begin
 fbase:= nb_hex; 
 inherited;
end;

function tbytestringdisp.getvaluetext: msestring;
begin
 if length(fvalue) > 256 then begin
  result:= bytestrtostr(copy(fvalue,1,256),fbase,true)+'...';
 end
 else begin
  result:= bytestrtostr(fvalue,fbase,true);
 end;
end;

procedure tbytestringdisp.setbase(const Value: numbasety);
begin
 if fbase <> value then begin
  fbase:= Value;
  formatchanged;
 end;
end;

procedure tbytestringdisp.setvalue(const Value: string);
begin
 if fvalue <> value then begin
  fvalue := Value;
  valuechanged;
 end;
end;

procedure tbytestringdisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 inherited;
end;

procedure tbytestringdisp.clear;
begin
 value:= '';
end;

{ tnumdisp }

constructor tnumdisp.create(aowner: tcomponent);
begin
 inherited;
 ftextflags:= defaultnumdisptextflags;
 finfo.flags:= ftextflags;
end;

{ tcustomintegerdisp }

constructor tcustomintegerdisp.create(aowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

{$ifdef mse_with_ifi}

function tcustomintegerdisp.getifilink: tifiintegerlinkcomp;
begin
 result:= tifiintegerlinkcomp(fifilink);
end;

procedure tcustomintegerdisp.setifilink(const avalue: tifiintegerlinkcomp);
begin
 inherited setifilink(avalue);
end;
{$endif}

function tcustomintegerdisp.getvaluetext: msestring;
begin
 result:= intvaluetostr(fvalue,fbase,fbitcount);
end;

procedure tcustomintegerdisp.setbase(const Value: numbasety);
begin
 if fbase <> value then begin
  fbase := Value;
  formatchanged;
 end;
end;

procedure tcustomintegerdisp.setbitcount(const Value: integer);
begin
 if fbitcount <> value then begin
  fbitcount := Value;
  formatchanged;
 end;
end;

procedure tcustomintegerdisp.setvalue(const Value: integer);
begin
// if fvalue <> value then begin
  fvalue := Value;
  valuechanged;
// end;
end;

procedure tcustomintegerdisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 inherited;
end;

procedure tcustomintegerdisp.clear;
begin
 value:= 0;
end;

{ tcustomint64disp }

constructor tcustomint64disp.create(aowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 64;
 inherited;
end;

{$ifdef mse_with_ifi}

function tcustomint64disp.getifilink: tifiint64linkcomp;
begin
 result:= tifiint64linkcomp(fifilink);
end;

procedure tcustomint64disp.setifilink(const avalue: tifiint64linkcomp);
begin
 inherited setifilink(avalue);
end;
{$endif}

function tcustomint64disp.getvaluetext: msestring;
begin
 result:= intvaluetostr(fvalue,fbase,fbitcount);
end;

procedure tcustomint64disp.setbase(const Value: numbasety);
begin
 if fbase <> value then begin
  fbase := Value;
  formatchanged;
 end;
end;

procedure tcustomint64disp.setbitcount(const Value: integer);
begin
 if fbitcount <> value then begin
  fbitcount := Value;
  formatchanged;
 end;
end;

procedure tcustomint64disp.setvalue(const Value: int64);
begin
// if fvalue <> value then begin
  fvalue := Value;
  valuechanged;
// end;
end;

procedure tcustomint64disp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 inherited;
end;

procedure tcustomint64disp.clear;
begin
 value:= 0;
end;

{ tcustomrealdisp }

constructor tcustomrealdisp.create(aowner: tcomponent);
begin
 fvalue:= emptyreal;
 fvaluerange:= 1;
 inherited;
end;

procedure tcustomrealdisp.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;
{
procedure tcustomrealdisp.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;
}
procedure tcustomrealdisp.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tcustomrealdisp.defineproperties(filer: tfiler);
begin
 inherited;
 filer.DefineProperty('val',{$ifdef FPC}@{$endif}readvalue,nil,false);
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

function tcustomrealdisp.getvaluetext: msestring;
begin
 result:= realtytostrrange(fvalue,fformat,fvaluerange,fvaluestart);
end;

procedure tcustomrealdisp.setvalue(const avalue: realty);
begin
 if fvalue <> avalue then begin
  fvalue := avalue;
  valuechanged;
 end;
end;

{$ifdef mse_with_ifi}

function tcustomrealdisp.getifilink: tifireallinkcomp;
begin
 result:= tifireallinkcomp(fifilink);
end;

procedure tcustomrealdisp.setifilink(const avalue: tifireallinkcomp);
begin
 inherited setifilink(avalue);
end;
{$endif}

procedure tcustomrealdisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,real(fvalue));
 end;
 inherited;
end;

procedure tcustomrealdisp.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tcustomrealdisp.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tcustomrealdisp.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tcustomrealdisp.clear;
begin
 value:= emptyreal;
end;

{ tcustomdatetimedisp }

constructor tcustomdatetimedisp.create(aowner: tcomponent);
begin
 fvalue:= emptydatetime;
 inherited;
end;

procedure tcustomdatetimedisp.setvalue(const avalue: tdatetime);
begin
 if fvalue <> avalue then begin
  fvalue := avalue;
  valuechanged;
 end;
end;

procedure tcustomdatetimedisp.setformat(const avalue: msestring);
begin
 fformat := avalue;
 formatchanged;
end;

{$ifdef mse_with_ifi}
function tcustomdatetimedisp.getifilink: tifidatetimelinkcomp;
begin
 result:= tifidatetimelinkcomp(fifilink);
end;

procedure tcustomdatetimedisp.setifilink(const avalue: tifidatetimelinkcomp);
begin
 inherited setifilink(avalue);
end;
{$endif}

procedure tcustomdatetimedisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 inherited;
end;

function tcustomdatetimedisp.getvaluetext: msestring;
var
 dt1: tdatetime;
begin
 dt1:= fvalue;
 checkdatereconvert(fconvert,dt1);
 case fkind of 
  dtk_time: begin
   result:= mseformatstr.timetostring(dt1,fformat);
  end;
  dtk_date: begin
   result:= mseformatstr.datetostring(dt1,fformat);
  end;
  else begin
   result:= mseformatstr.datetimetostring(dt1,fformat);
  end;
 end;
end;

procedure tcustomdatetimedisp.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

procedure tcustomdatetimedisp.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;
{
procedure tcustomdatetimedisp.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;
}
procedure tcustomdatetimedisp.defineproperties(filer: tfiler);
begin
 inherited;
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,nil,false);
end;

procedure tcustomdatetimedisp.setoptions(const avalue: dispwidgetoptionsty);
{$ifndef FPC}
const
 mask1: dispwidgetoptionsty = [dwo_showlocal,dwo_showutc];
{$endif}
var
 opt1: dispwidgetoptionsty;
begin
 opt1:= foptions;
 inherited;
 foptions:= dispwidgetoptionsty(
 {$ifdef FPC}
      replacebits(setsinglebit(longword(avalue),longword(opt1),
                         longword([dwo_showlocal,dwo_showutc])),
                  longword(foptions),
                  longword([dwo_showlocal,dwo_showutc])));
 {$else}
      replacebits(setsinglebit(byte(avalue),byte(opt1),
                         byte(mask1)),byte(foptions),byte(mask1)));
 {$endif}
 fconvert:= dc_none;
 if dwo_showutc in foptions then begin
  fconvert:= dc_tolocal;
 end;
 if dwo_showlocal in foptions then begin
  fconvert:= dc_toutc;
 end;
 formatchanged;
end;

procedure tcustomdatetimedisp.clear;
begin
 value:= emptydatetime;
end;

{ tcustombooleandisp }

constructor tcustombooleandisp.create(aowner: tcomponent);
begin
 ftext_true:= 'T';
 ftext_false:= 'F';
 inherited;
 finfo.flags:= finfo.flags + [tf_xcentered];
end;

function tcustombooleandisp.getvaluetext: msestring;
begin
 if fvalue then begin
  result:= ftext_true;
 end
 else begin
  result:= ftext_false;
 end;
end;

procedure tcustombooleandisp.setvalue(const Value: boolean);
begin
 if fvalue <> value then begin
  fvalue := Value;
  valuechanged;
 end;
end;

procedure tcustombooleandisp.valuechanged;
begin
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 inherited;
end;

procedure tcustombooleandisp.settext_false(const avalue: msestring);
begin
 ftext_false:= avalue;
 formatchanged;
end;

procedure tcustombooleandisp.settext_true(const avalue: msestring);
begin
 ftext_true:= avalue;
 formatchanged;
end;

procedure tcustombooleandisp.clear;
begin
 value:= false;
end;

end.
