{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetabs;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msewidgets,mseclasses,msearrayprops,classes,mseshapes,
 mserichstring,msetypes,msegraphics,msegraphutils,mseevent,mseguiglob,msegui,
 mseforms,rtlconsts,msesimplewidgets,msedrag,
 mseobjectpicker,msepointer,msestat,msestatfile,msestrings;

const
 defaulttaboptionswidget = defaultoptionswidget + [ow_subfocus,ow_fontglyphheight];
// defaulttabsize = 20;
 defaulttabsizemin = 20;
 defaulttabsizemax = 200;

type

 tcustomtabbar = class;
 tabstatety = (ts_invisible,ts_disabled,ts_active,ts_updating);
 tabstatesty = set of tabstatety;

 ttab = class(tindexpersistent)
  private
//   ftabbar: ttabbar;
   fcaption: richstringty;
   fstate: tabstatesty;
   fcolor: colorty;
   fcoloractive: colorty;
   fident: integer;
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
   procedure changed;
   procedure setstate(const Value: tabstatesty);
   procedure setcolor(const Value: colorty);
   procedure setcoloractive(const Value: colorty);
   function getactive: boolean;
   procedure setactive(const Value: boolean);
  protected
   ftag: integer;
   procedure execute(const tag: integer; const info: mouseeventinfoty);
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget);
  public
   constructor create(const aowner: tcustomtabbar); reintroduce;
   function tabbar: tcustomtabbar;
   property ident: integer read fident;
   property active: boolean read getactive write setactive;
  published
   property caption: captionty read getcaption write setcaption;
   property state: tabstatesty read fstate write setstate default [];
   property color: colorty read fcolor write setcolor default cl_default;
   property coloractive: colorty read fcoloractive
                 write setcoloractive default cl_default;
   property tag: integer read ftag write ftag default 0;
 end;

 ttabs = class;

 createtabeventty = procedure(const sender: tcustomtabbar; const index: integer;
                         var tab: ttab) of object;
                          
 ttabs = class(tindexpersistentarrayprop)
  private
   fcolor: colorty;
   fcoloractive: colorty;
   fface: tface;
   ffaceactive: tface;
   foncreatetab: createtabeventty;
   procedure setitems(const index: integer; const Value: ttab);
   function getitems(const index: integer): ttab; reintroduce;
   function getface: tface;
   procedure setface(const avalue: tface);
   function getfaceactive: tface;
   procedure setfaceactive(const avalue: tface);
   procedure createface;
   procedure createfaceactive;
   procedure setcolor(const avalue: colorty);
   procedure setcoloractive(const avalue: colorty);
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomtabbar; aclasstype: indexpersistentclassty);
                                         reintroduce;
   destructor destroy; override;
   procedure add(const item: ttab);
   procedure insert(const item: ttab; const aindex: integer);
   procedure additems(const aitems: msestringarty);
   function indexof(const item: ttab): integer;
   property items[const index: integer]: ttab read getitems write setitems; default;
   property oncreatetab: createtabeventty read foncreatetab write foncreatetab;
  published
   property color: colorty read fcolor
                  write setcolor default cl_transparent;
   property coloractive: colorty read fcoloractive
                  write setcoloractive default cl_active;
   property face: tface read getface write setface;
   property faceactive: tface read getfaceactive write setfaceactive;
 end;

 tabbarlayoutinfoty = record
  tabs: ttabs;
  dim: rectty;
  activetab: integer;
  cells: shapeinfoarty;
  firsttab: integer;
  lasttab: integer;
  stepinfo: framestepinfoty;
  options: shapestatesty;
 end;

 movingeventty = procedure(const sender: tobject; var curindex: integer;
                                       var newindex: integer) of object;
 movedeventty = procedure(const sender: tobject; const curindex: integer;
                                       const newindex: integer) of object;
 tabbaroptionty = (tabo_dragsource,tabo_dragdest,
                     tabo_dragsourceenabledonly,tabo_dragdestenabledonly,
                                //no action on disabled pages
                     tabo_vertical,tabo_opposite,
                     tabo_buttonsoutside,tabo_tabsizing,
                     tabo_acttabfirst,tabo_clickedtabfirst,tabo_dblclickedtabfirst,
                     tabo_sorted);
 tabbaroptionsty = set of tabbaroptionty;

 tcustomtabbar = class(tcustomstepbox)
  private
   flayoutinfo: tabbarlayoutinfoty;
   fonactivetabchange: notifyeventty;
   fupdating: integer;
   finternaltabchange: objectprocty;
   fontabmoving: movingeventty;
   fontabmoved: movedeventty;
   fonclientmouseevent: mouseeventty;
   procedure settabs(const Value: ttabs);
   procedure layoutchanged;
   procedure updatelayout;
   function getactivetab: integer;
   procedure setactivetab(const Value: integer);
   procedure tabschanged(const sender: tarrayprop; const index: integer);
   procedure setfirsttab(Value: integer);
   procedure setoptions(const avalue: tabbaroptionsty);
  protected
   foptions: tabbaroptionsty;
   procedure dostep(const event: stepkindty); override;
   procedure doactivetabchanged;
   procedure tabchanged(const sender: ttab);
   procedure tabclicked(const sender: ttab; const info: mouseeventinfoty);
   procedure loaded; override;
   procedure dopaint(const canvas: tcanvas); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure clientrectchanged; override;
   procedure dofontheightdelta(var delta: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   procedure beginupdate;
   procedure endupdate;
   function tabatpos(const apos: pointty; const enabledonly: boolean = false): integer;
   procedure movetab(curindex,newindex: integer);
   function activetag: integer; //0 if no activetab, activetab.tag otherwise
   procedure dragevent(var info: draginfoty); override;
   property activetab: integer read getactivetab write setactivetab;
   property tabs: ttabs read flayoutinfo.tabs write settabs;
   property firsttab: integer read flayoutinfo.firsttab write setfirsttab default 0;
   property onactivetabchange: notifyeventty read fonactivetabchange
                  write fonactivetabchange;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property options: tabbaroptionsty read foptions write setoptions default [];
   property ontabmoving: movingeventty read fontabmoving write fontabmoving;
   property ontabmoved: movedeventty read fontabmoved write fontabmoved;
   property onclientmouseevent: mouseeventty read fonclientmouseevent write fonclientmouseevent;
 end;

 ttabbar = class(tcustomtabbar,istatfile)
  private
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setstatfile(const Value: tstatfile);
   procedure setdragcontroller(const Value: tdragcontroller);
  protected
   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onstep;
//   property invisiblebuttons;

   property tabs;
   property firsttab;
   property onactivetabchange;
   property ontabmoving;
   property ontabmoved;
   property onclientmouseevent;
   property font;
   property options;
   property drag: tdragcontroller read fdragcontroller write setdragcontroller;
 end;

 tcustomtabwidget = class;

 itabpage = interface(inullinterface) ['{AB1D0204-1DCB-4560-99A3-C0D6020B2EA7}']
  procedure settabwidget(const value: tcustomtabwidget);
  function gettabwidget: tcustomtabwidget;
  function getwidget: twidget;
  function getcaption: msestring;
  function getcolortab: colorty;
  function getcoloractivetab: colorty;
  procedure doselect;
  procedure dodeselect;
 end;

 ttabpage = class(tscrollingwidget,itabpage)
  private
   ftabwidget: tcustomtabwidget;
   fcaption: msestring;
   fcolortab,fcoloractivetab: colorty;
   fonselect: notifyeventty;
   fondeselect: notifyeventty;
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
   function getcolortab: colorty;
   procedure setcolortab(const avalue: colorty);
   function getcoloractivetab: colorty;
   procedure setcoloractivetab(const avalue: colorty);
   procedure settabwidget(const value: tcustomtabwidget);
   function gettabwidget: tcustomtabwidget;
   function gettabindex: integer;
   procedure settabindex(const avalue: integer);
  protected
   procedure changed;
   procedure visiblechanged; override;
   procedure enabledchanged; override;
   procedure registerchildwidget(const child: twidget); override;
   procedure designselected(const selected: boolean); override;
   procedure doselect; virtual;
   procedure dodeselect; virtual;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   function isactivepage: boolean;
   property tabwidget: tcustomtabwidget read ftabwidget;
   property tabindex: integer read gettabindex write settabindex;
  published
   property caption: captionty read getcaption write setcaption;
   property colortab: colorty read getcolortab
                  write setcolortab default cl_default;
   property coloractivetab: colorty read getcoloractivetab
                  write setcoloractivetab default cl_default;
   property optionswidget default defaulttaboptionswidget;
   property onchildscaled;
   property onfontheightdelta;
   property onselect: notifyeventty read fonselect write fonselect;
   property ondeselect: notifyeventty read fondeselect write fondeselect;
   property visible default false;
 end;

 ttabform = class(tmseform,itabpage)
  private
   ftabwidget: tcustomtabwidget;
   fcolortab,fcoloractivetab: colorty;
   fonselect: notifyeventty;
   fondeselect: notifyeventty;
   procedure settabwidget(const value: tcustomtabwidget);
   function gettabwidget: tcustomtabwidget;
   procedure changed;
   function getcolortab: colorty;
   procedure setcolortab(const avalue: colorty);
   function getcoloractivetab: colorty;
   procedure setcoloractivetab(const avalue: colorty);
   function gettabindex: integer;
   procedure settabindex(const avalue: integer);
  protected
   procedure visiblechanged; override;
   procedure setcaption(const value: msestring); override;
   procedure doselect; virtual;
   procedure dodeselect; virtual;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   function isactivepage: boolean;
   property tabwidget: tcustomtabwidget read ftabwidget;
   property tabindex: integer read gettabindex write settabindex;
  published
   property colortab: colorty read getcolortab
                  write setcolortab default cl_default;
   property coloractivetab: colorty read getcolortab
                  write setcoloractivetab default cl_active;
   property onselect: notifyeventty read fonselect write fonselect;
   property ondeselect: notifyeventty read fondeselect write fondeselect;
   property visible default false;
 end;

 tpagetab = class(ttab)
  private
   fpageintf: itabpage;
  public
   constructor create(const aowner: tcustomtabbar; const apage: itabpage);
   function page: twidget;
 end;

 tcustomtabwidget = class(tactionwidget,iobjectpicker,istatfile)
  private
   ftabs: tcustomtabbar;
   fobjectpicker: tobjectpicker;
   factivepageindex: integer;
   fonactivepagechanged: notifyeventty;
   fonpageadded: widgeteventty;
   fonpageremoved: widgeteventty;
   ftab_size: integer;
   ftab_sizemin: integer;
   ftab_sizemax: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setstatfile(const value: tstatfile);
   function getitems(const index: integer): twidget;
   procedure setactivepageindex(value: integer);
   function getactivepage: twidget;
   procedure setactivepage(const value: twidget);
   procedure updatesize(const page: twidget);
   function getoptions: tabbaroptionsty;
   procedure setoptions(const Value: tabbaroptionsty);
   function gettab_color: colorty;
   procedure settab_color(const avalue: colorty);
   function gettab_frame: tstepboxframe;
   procedure settab_frame(const avalue: tstepboxframe);
   function gettab_face: tface;
   procedure settab_face(const avalue: tface);
   procedure settab_size(const avalue: integer);
   procedure settab_sizemin(const avalue: integer);
   procedure settab_sizemax(const avalue: integer);
   function gettab_colortab: colorty;
   procedure settab_colortab(const avalue: colorty);
   function gettab_coloractivetab: colorty;
   procedure settab_coloractivetab(const avalue: colorty);
   function gettab_facetab: tface;
   procedure settab_facetab(const avalue: tface);
   function gettab_faceactivetab: tface;
   procedure settab_faceactivetab(const avalue: tface);
   function checktabsizingpos(const apos: pointty): boolean;
   function getidents: integerarty;
  protected
   procedure internaladd(const page: itabpage; aindex: integer);
   procedure internalremove(const page: itabpage);
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure pagechanged(const sender: itabpage);
   procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
   procedure tabchanged;
   procedure loaded; override;
   procedure clientrectchanged; override;
   procedure doactivepagechanged; virtual;
   procedure dopageadded(const apage: twidget); virtual;
   procedure dopageremoved(const apage: twidget); virtual;
   procedure createpagetab(const sender: tcustomtabbar; const index: integer; var tab: ttab);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure childmouseevent(const sender: twidget; var info: mouseeventinfoty); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure dofontheightdelta(var delta: integer); override;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   //iobjectpicker
   function getcursorshape(const apos: pointty;  const shiftstate: shiftstatesty;
                                var shape: cursorshapety): boolean;
    //true if found
   procedure getpickobjects(const rect: rectty;  const shiftstate: shiftstatesty;
                                var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos,offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);

   function checkpickoffset(const aoffset: pointty): pointty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   function indexof(const page: twidget): integer;
   function count: integer;
   procedure clear;
   procedure nextpage(newindex: integer; down: boolean);
   procedure changepage(step: integer);
   procedure movepage(const curindex,newindex: integer);
   procedure add(const aitem: itabpage; const aindex: integer = bigint);
   function pagebyname(const aname: string): twidget;
                   //case sensitive!
                           
   property items[const index: integer]: twidget read getitems; default;
   property activepage: twidget read getactivepage write setactivepage;
   property idents: integerarty read getidents;
   property activepageindex: integer read factivepageindex 
                      write setactivepageindex default -1;
   property onactivepagechanged: notifyeventty read fonactivepagechanged write fonactivepagechanged;
   property onpageadded: widgeteventty read fonpageadded write fonpageadded;
   property onpageremoved: widgeteventty read fonpageremoved write fonpageremoved;
   property optionswidget default defaulttaboptionswidget;
   property options: tabbaroptionsty read getoptions write setoptions default [];
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property tab_frame: tstepboxframe read gettab_frame write settab_frame;
   property tab_face: tface read gettab_face write settab_face;
   property tab_color: colorty read gettab_color write settab_color default cl_default;
   property tab_colortab: colorty read gettab_colortab 
                        write settab_colortab default cl_transparent;
   property tab_coloractivetab: colorty read gettab_coloractivetab 
                        write settab_coloractivetab default cl_active;
   property tab_facetab: tface read gettab_facetab write settab_facetab;
   property tab_faceactivetab: tface read gettab_faceactivetab write settab_faceactivetab;
   property tab_size: integer read ftab_size write settab_size;
   property tab_sizemin: integer read ftab_sizemin write settab_sizemin
                            default defaulttabsizemin;
   property tab_sizemax: integer read ftab_sizemax write settab_sizemax
                            default defaulttabsizemax;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
 end;

 ttabwidget = class(tcustomtabwidget)
  published
   property optionswidget;
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property color;
   property cursor;
   property frame;
   property face;
   property anchors;
   property taborder;
   property hint;
   property popupmenu;
   property onpopup;
   property onshowhint;

   property enabled;
   property visible;
 
   property activepageindex;
   property onactivepagechanged;
   property onpageadded;
   property onpageremoved;
   property options;
   property font;
   property tab_frame;
   property tab_face;
   property tab_color;
   property tab_colortab;
   property tab_coloractivetab;
   property tab_facetab;
   property tab_faceactivetab;
   property tab_size;
   property tab_sizemin;
   property tab_sizemax;
   property statfile;
   property statvarname;
 end;
 
implementation
uses
 msedrawtext,sysutils,msedatalist,msekeyboard,msestockobjects;

type
 twidget1 = class(twidget);

procedure calctablayout(var layout: tabbarlayoutinfoty;
                     const canvas: tcanvas);
var
 int1: integer;
 aval: integer;
 endval: integer;
 rect1: rectty;
begin
 with layout do begin
  cells:= nil;
  setlength(cells,tabs.count);
  if firsttab > high(cells) then begin
   firsttab:= 0;
  end;
  lasttab:= -1;
  if ss_vert in options then begin
   aval:= dim.y;
   endval:= dim.y + dim.cy;
   for int1:= 0 to high(cells) do begin
    with tabs[int1],cells[int1] do begin
//     font:=   canvas.font;
     caption:= fcaption;
     dim.y:= aval;
     rect1:= textrect(canvas,caption,makerect(layout.dim.x,aval,layout.dim.cx,bigint));
     dim.cy:= rect1.cy+4;
     if (ts_invisible in fstate) or (int1 < firsttab) or (aval >= endval) then begin
      include(state,ss_invisible);
     end
     else begin
      inc(aval,dim.cy);
      if (aval < endval) then begin
       lasttab:= int1;
      end;
     end;
     if ts_active in fstate then begin
      if ss_opposite in options then begin
       dim.x:= -1;
      end
      else begin
       dim.x:= 1;
      end;
     end
     else begin
      dim.x:= 0;
     end;
     dim.cx:= layout.dim.cx;
    end;
   end;
  end
  else begin
   aval:= dim.x;
   endval:= dim.x + dim.cx;
   for int1:= 0 to high(cells) do begin
    with tabs[int1],cells[int1] do begin
//     font:=   canvas.font;
     caption:= fcaption;
     dim.x:= aval;
     rect1:= textrect(canvas,caption,makerect(aval,layout.dim.y,bigint,layout.dim.cy));
     dim.cx:= rect1.cx+6;
     if (ts_invisible in fstate) or (int1 < firsttab) or (aval >= endval) then begin
      include(state,ss_invisible);
     end
     else begin
      inc(aval,dim.cx);
      if (aval < endval) then begin
       lasttab:= int1;
      end;
     end;
     if ts_active in fstate then begin
      if ss_opposite in options then begin
       dim.y:= -1;
      end
      else begin
       dim.y:= 1;
      end;
     end
     else begin
      dim.y:= 0;
     end;
     dim.cy:= layout.dim.cy;
    end;
   end;
  end;
  for int1:= 0 to high(cells) do begin
   with tabs[int1],cells[int1] do begin
    state:= state + options * [ss_vert,ss_opposite];
    if ts_active in fstate then begin
     if fcoloractive = cl_default then begin
      color:= tabs.fcoloractive;
     end
     else begin
      color:= fcoloractive;
     end;
     face:= tabs.ffaceactive;
     state:= state + [ss_checked,ss_radiobutton];
    end
    else begin
     if fcolor = cl_default then begin
      color:= tabs.fcolor;
     end
     else begin
      color:= fcolor;
     end;
     face:= tabs.face;
     state:= state + [ss_radiobutton];
    end;
    if ts_disabled in fstate then begin
     include(state,ss_disabled);
    end;
    doexecute:= {$ifdef FPC}@{$endif}execute;
   end;
  end;
  with stepinfo do begin
   up:= 0;
   for int1:= firsttab to high(cells) do begin
    if not (ss_invisible in cells[int1].state) and (up = 0) then begin
     up:= int1-firsttab;
     break;
    end;
   end;
   if up = 0 then begin
    up:= 1;
   end;
   pageup:= lasttab - firsttab + 1;
   pagedown:= 1;
   aval:= 0;
   pagelast:= 0;
   endval:= 0;
   down:= 0;
   if ss_vert in options then begin
    for int1:= firsttab - 1 downto 0 do begin
     with cells[int1] do begin
      dec(pagedown);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(aval,dim.cy);
       if down = 0 then begin
        down:= int1-firsttab;
       end;
      end;
     end;
     if aval >= dim.cy then begin
      break;
     end;
     if int1 = 0 then begin
      dec(pagedown);
     end;
    end;
    for int1:= high(cells) downto 0 do begin
     with cells[int1] do begin
      inc(pagelast);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(endval,dim.cy);
      end;
     end;
     if endval >= dim.cy then begin
      break;
     end;
    end;
    if endval > dim.cy then begin
     dec(pagelast);
    end;
   end
   else begin
    for int1:= firsttab - 1 downto 0 do begin
     with cells[int1] do begin
      dec(pagedown);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(aval,dim.cx);
       if down = 0 then begin
        down:= int1-firsttab;
       end;
      end;
     end;
     if aval >= dim.cx then begin
      break;
     end;
     if int1 = 0 then begin
      dec(pagedown);
     end;
    end;
    for int1:= high(cells) downto 0 do begin
     with cells[int1] do begin
      inc(pagelast);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(endval,dim.cx);
      end;
     end;
     if endval >= dim.cx then begin
      break;
     end;
    end;
    if endval > dim.cx then begin
     dec(pagelast);
    end;
   end;
   if down = 0 then begin
    down:= -1;
   end;
   pagelast:= length(cells)-pagelast-firsttab;
  end;
  inc(lasttab);
  if lasttab > high(cells) then begin
   lasttab:= high(cells);
  end;
 end;
end;

{ ttab }

constructor ttab.create(const aowner: tcustomtabbar);
begin
// fcolor:= aowner.colortab;
// fcoloractive:= aowner.coloractivetab;
 fcolor:= cl_default;
 fcoloractive:= cl_default;
 inherited create(aowner,aowner.flayoutinfo.tabs);
end;

procedure ttab.changed;
begin
 if not (ts_updating in fstate) then begin
  tcustomtabbar(fowner).tabchanged(self);
 end;
end;

function ttab.getcaption: captionty;
begin
 result:= richstringtocaption(fcaption);
end;

procedure ttab.setcaption(const Value: captionty);
begin
 captiontorichstring(value,fcaption);
 changed;
end;
{
function ttab.index: integer;
begin
 if ftabbar <> nil then begin
  result:= ftabbar.tabs.indexof(self);
 end
 else begin
  result:= -1;
 end;
end;
}
function ttab.tabbar: tcustomtabbar;
begin
 result:= tcustomtabbar(fowner);
end;

procedure ttab.setstate(const Value: tabstatesty);
begin
 if fstate <> value then begin
  fstate := Value;
  if (fstate * [ts_invisible,ts_disabled] <> []) and 
       not (csdesigning in tcustomtabbar(fowner).componentstate) then begin
   exclude(fstate,ts_active);
  end;
  changed;
 end;
end;

procedure ttab.execute(const tag: integer; const info: mouseeventinfoty);
begin
 tabbar.tabclicked(self,info);
end;

procedure ttab.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if checkshortcut(info,fcaption,true) then begin
  active:= true;
 end;
end;

procedure ttab.setcolor(const Value: colorty);
begin
 if fcolor <> value then begin
  fcolor := Value;
  changed;
 end;
end;

procedure ttab.setcoloractive(const Value: colorty);
begin
 if fcoloractive <> value then begin
  fcoloractive := Value;
  changed;
 end;
end;

function ttab.getactive: boolean;
begin
 result:= ts_active in fstate;
end;

procedure ttab.setactive(const Value: boolean);
begin
 if value then begin
  state:= fstate + [ts_active];
 end
 else begin
  state:= fstate - [ts_active];
 end;
end;

{ ttabs }

constructor ttabs.create(const aowner: tcustomtabbar; aclasstype: indexpersistentclassty);
begin
 fcolor:= cl_transparent;
 fcoloractive:= cl_active;
 inherited create(aowner,aclasstype);
end;

destructor ttabs.destroy;
begin
 fface.free;
 ffaceactive.free;
 inherited;
end;

procedure ttabs.createface;
begin
 fface:= tface.create(iface(tcustomtabbar(fowner)));
end;

procedure ttabs.createfaceactive;
begin
 ffaceactive:= tface.create(iface(tcustomtabbar(fowner)));
end;

function ttabs.getface: tface;
begin
 tcustomtabbar(fowner).getoptionalobject(fface,{$ifdef FPC}@{$endif}createface);
 result:= fface;
end;

procedure ttabs.setface(const avalue: tface);
begin
 tcustomtabbar(fowner).setoptionalobject(avalue,fface,{$ifdef FPC}@{$endif}createface);
 tcustomtabbar(fowner).layoutchanged;
end;

function ttabs.getfaceactive: tface;
begin
 tcustomtabbar(fowner).getoptionalobject(ffaceactive,
                               {$ifdef FPC}@{$endif}createfaceactive);
 result:= ffaceactive;
end;

procedure ttabs.setfaceactive(const avalue: tface);
begin
 tcustomtabbar(fowner).setoptionalobject(avalue,ffaceactive,
                               {$ifdef FPC}@{$endif}createfaceactive);
 tcustomtabbar(fowner).layoutchanged;
end;

procedure ttabs.setcolor(const avalue: colorty);
begin
 if avalue <> fcolor then begin
  fcolor:= avalue;
  tcustomtabbar(fowner).layoutchanged;
 end;
end;

procedure ttabs.setcoloractive(const avalue: colorty);
begin
 if avalue <> fcoloractive then begin
  fcoloractive:= avalue;
  tcustomtabbar(fowner).layoutchanged;
 end;
end;

procedure ttabs.add(const item: ttab);
begin
 inherited add(item);
end;

procedure ttabs.insert(const item: ttab; const aindex: integer);
begin
 tcustomtabbar(fowner).beginupdate;
 try
  inherited add(item);
  move(count-1,aindex);
 finally
  tcustomtabbar(fowner).endupdate
 end;
end;

procedure ttabs.additems(const aitems: msestringarty);
var
 int1,int2: integer;

begin
 tcustomtabbar(fowner).beginupdate;
 try
  int1:= count;
  count:= count + length(aitems);
  for int2:= 0 to high(aitems) do begin
   items[int1].caption:= aitems[int2];
   inc(int1);
  end;
 finally
  tcustomtabbar(fowner).endupdate;
 end;
end;

procedure ttabs.createitem(const index: integer; var item: tpersistent);
begin
 if item = nil then begin
  if assigned(foncreatetab) then begin
   foncreatetab(tcustomtabbar(fowner),index,ttab(item));
  end;
  if item = nil then begin
   item:= ttab.create(tcustomtabbar(fowner));
  end;
 end;
 ttab(item).findex:= index;
end;

function ttabs.getitems(const index: integer): ttab;
begin
 result:= ttab(inherited items[index]);
end;

function ttabs.indexof(const item: ttab): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(fitems) do begin
  if items[int1] = item then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure ttabs.setitems(const index: integer; const Value: ttab);
begin
 inherited items[index].assign(value);
end;

{ tcustomtabbar }

constructor tcustomtabbar.create(aowner: tcomponent);
begin
 flayoutinfo.tabs:= ttabs.Create(self,nil);
 flayoutinfo.tabs.onchange:= {$ifdef FPC}@{$endif}tabschanged;
 flayoutinfo.activetab:= -1;
 flayoutinfo.lasttab:= -1;
 inherited;
 fwidgetrect.cy:= font.glyphheight + 4;
end;

destructor tcustomtabbar.destroy;
begin
 inherited;
 flayoutinfo.tabs.Free;
end;

procedure tcustomtabbar.settabs(const Value: ttabs);
begin
 flayoutinfo.tabs.assign(Value);
end;

procedure tcustomtabbar.updatelayout;
begin
 with flayoutinfo do begin
  dim:= innerclientrect;
  options:= [];
  if tabo_vertical in foptions then begin
   include(options,ss_vert);
  end;
  if tabo_opposite in foptions then begin
   include(options,ss_opposite);
  end;
  calctablayout(flayoutinfo,getcanvas);
  if tabo_vertical in foptions then begin
   frame.buttonpos:= sbp_top;
   frame.buttonslast:= ((tabo_opposite in foptions) xor
                   (tabo_buttonsoutside in foptions));
  end
  else begin
   frame.buttonpos:= sbp_right;
   frame.buttonslast:= ((tabo_opposite in foptions) xor
                   (tabo_buttonsoutside in foptions));
  end;
  frame.updatebuttonstate(firsttab,stepinfo.pageup,tabs.count);
 end;
 invalidate;
end;

procedure tcustomtabbar.layoutchanged;
begin
 if not (csloading in componentstate)  and
     not ((owner <> nil) and (csloading in owner.ComponentState)) then begin
           //todo: support for cssubcomponent in fpc
  updatelayout;
  invalidate;
 end;
end;

function comptabs(const l,r): integer;
begin
 result:= msecomparetext(ttab(l).fcaption.text,ttab(r).fcaption.text);
end;

procedure tcustomtabbar.tabchanged(const sender: ttab);

 procedure updateactivetabindex;
 var
  int1: integer;
  bo1: boolean;
 begin
  with flayoutinfo do begin
   bo1:= false;
   for int1:= 0 to tabs.count - 1 do begin
    with tabs[int1] do begin
     if ts_active in fstate then begin
      bo1:= true;
      if (activetab <> int1) then begin
       if (activetab >= 0) and (activetab <= high(tabs.fitems)) then begin
        exclude(tabs.items[activetab].fstate,ts_active);
       end;
       activetab:= int1;
      end;
     end;
    end;
   end;
   if not bo1 then begin
    activetab:= -1;
   end;
  end;
 end;

var
 int1,int2: integer;
 bo1: boolean;
 activetabbefore: integer;
begin
 if fupdating = 0 then begin
  with flayoutinfo do begin
   activetabbefore:= activetab;
   updateactivetabindex;
   bo1:= activetabbefore <> activetab;
   if bo1 and assigned(finternaltabchange) then begin
    finternaltabchange;
   end;
   if tabo_sorted in foptions then begin
    sortarray(pointerarty(flayoutinfo.tabs.fitems),{$ifdef FPC}@{$endif}comptabs);
    updateactivetabindex;
   end;
   if bo1 then begin
    if (activetab >= 0) and (activetab <= high(cells)) then begin
     if (tabo_acttabfirst in foptions) and (activetab <> 0) then begin
      flayoutinfo.tabs.move(activetab,0);
      updateactivetabindex;
     end;
     if activetab < firsttab then begin
      firsttab:= activetab;
     end
     else begin
      if activetab >= firsttab + stepinfo.pageup then begin
       firsttab:= activetab + 1;
       int2:= 0;
       if ss_vert in options then begin
        for int1:= activetab downto 0 do begin
         if not (ts_invisible in tabs[int1].fstate) then begin
          inc(int2,cells[int1].dim.cy);
          if int2 >= dim.cy then begin
           break;
          end;
          dec(firsttab);
         end;
        end;
       end
       else begin
        for int1:= activetab downto 0 do begin
         if not (ts_invisible in tabs[int1].fstate) then begin
          inc(int2,cells[int1].dim.cx);
          if int2 >= dim.cx then begin
           break;
          end;
          dec(firsttab);
         end;
        end;
       end;
       if firsttab > activetab then begin
        firsttab:= activetab;
       end;
      end;
     end;
    end;
    doactivetabchanged;
   end;
   layoutchanged;
  end;
 end;
end;

procedure tcustomtabbar.tabclicked(const sender: ttab; const info: mouseeventinfoty);
begin
 if (tabo_clickedtabfirst in foptions) or 
    (tabo_dblclickedtabfirst in foptions) and (ss_double in info.shiftstate) then begin
  movetab(sender.findex,0);
//  flayoutinfo.tabs.move(sender.findex,0);
 end;
 sender.active:= true;
end;

procedure tcustomtabbar.tabschanged(const sender: tarrayprop;
  const index: integer);
begin
 tabchanged(nil);
end;

procedure tcustomtabbar.loaded;
begin
 inherited;
 updatelayout;
 doactivetabchanged;
end;

procedure tcustomtabbar.dopaint(const canvas: tcanvas);
var
 int1,int2,int3: integer;
 color1: colorty;
 rect1: rectty;
begin
// color1:= canvas.color;
 inherited;
 with flayoutinfo do begin
  for int1:= firsttab to lasttab do begin
   {
   cells[int1].font:= canvas.font;
   if cells[int1].color <> cl_default then begin
    canvas.fillrect(cells[int1].dim,cells[int1].color);
   end;
   if cells[int1].state * [ss_mouse] <> [] then begin
    int2:= -2;
   end
   else begin
    int2:= -1;
   end;
   if int1 = activetab then begin
    if faceactive <> nil then begin
     faceactive.paint(canvas,inflaterect(cells[int1].dim,int1));
    end
   end
   else begin
    if face <> nil then begin
     face.paint(canvas,inflaterect(cells[int1].dim,int1));
    end
   end;
   canvas.color:= color1;
   }
   drawtab(canvas,cells[int1]);
  end;
  int1:= high(cells);
  rect1:= innerclientrect;
  if ss_vert in options then begin
   if ss_opposite in options then begin
    int2:= rect1.x;
    color1:= defaultframecolors.shadow.color;
   end
   else begin
    int2:= rect1.x+rect1.cx-1;
    color1:= defaultframecolors.light.effectcolor;
   end;
   int3:= rect1.y+rect1.cy-1;
   if int1 >= 0 then begin
    with cells[int1] do begin
     canvas.drawline(makepoint(int2,dim.y+dim.cy),makepoint(int2,int3),color1);
    end;
   end
   else begin
    canvas.drawline(makepoint(int2,rect1.y),makepoint(int2,int3),color1);
   end;
  end
  else begin
   if ss_opposite in options then begin
    int2:= rect1.y;
    color1:= defaultframecolors.shadow.color;
   end
   else begin
    int2:= rect1.y+rect1.cy-1;
    color1:= defaultframecolors.light.effectcolor;
   end;
   int3:= rect1.x+rect1.cx-1;
   if int1 >= 0 then begin
    with cells[int1] do begin
     canvas.drawline(makepoint(dim.x+dim.cx,int2),makepoint(int3,int2),color1);
    end;
   end
   else begin
    canvas.drawline(makepoint(rect1.x,int2),makepoint(int3,int2),color1);
   end;
  end;
 end;
end;

function tcustomtabbar.getactivetab: integer;
begin
 result:= flayoutinfo.activetab;
end;

procedure tcustomtabbar.setactivetab(const Value: integer);
var
 int1: integer;

begin
 if value < 0 then begin
  if activetab >= 0 then begin
   flayoutinfo.tabs.items[activetab].state:=
       flayoutinfo.tabs.items[activetab].state - [ts_active];
  end;
 end
 else begin
  int1:= value;
  if int1 >= tabs.count then begin
   int1:= tabs.count - 1
  end;
  if int1 >= 0 then begin
   flayoutinfo.tabs.items[int1].state:=
      flayoutinfo.tabs.items[int1].state + [ts_active];
  end;
 end;
end;

function tcustomtabbar.activetag: integer;
   //0 if no activetab, activetab.tag otherwise
begin
 with flayoutinfo do begin
  if activetab < 0 then begin
   result:= 0;
  end
  else begin
   result:= tabs[activetab].ftag;
  end;
 end;
end;

procedure tcustomtabbar.clientmouseevent(var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) and 
                           canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,info);
 end;
 inherited;
 if updatemouseshapestate(flayoutinfo.cells,info,self) then begin
//  invalidate;
  include(info.eventstate,es_processed);
 end;
end;

procedure tcustomtabbar.doshortcut(var info: keyeventinfoty; const sender: twidget);
var
 int1,int2: integer;
begin
 if not (csdesigning in componentstate) then begin
  int2:= activetab + 1;
  if int2 >= tabs.count then begin
   int2:= 0;
  end;
  for int1:= int2 to tabs.count - 1 do begin
   if es_processed in info.eventstate then begin
    break;
   end;
   flayoutinfo.tabs[int1].doshortcut(info,sender);
  end;
  for int1:= 0 to int2 - 1 do begin
   if es_processed in info.eventstate then begin
    break;
   end;
   flayoutinfo.tabs[int1].doshortcut(info,sender);
  end;
 end;
 inherited;
end;

procedure tcustomtabbar.clientrectchanged;
begin
 inherited;
 layoutchanged;
end;

procedure tcustomtabbar.dofontheightdelta(var delta: integer);
begin
 if not (tabo_vertical in foptions) then begin
  inherited;
  if delta <> 0 then begin
   synctofontheight;
  end;
 end
 else begin
  layoutchanged;
 end;
end;

procedure tcustomtabbar.synctofontheight;
begin
 inherited;
 if not (tabo_vertical in options) then begin
  bounds_cy:= font.glyphheight + fframe.innerframewidth.cy + 4;
 end;
end;

procedure tcustomtabbar.doactivetabchanged;
begin
 if canevent(tmethod(fonactivetabchange)) then begin
  fonactivetabchange(self);
 end;
end;

procedure tcustomtabbar.beginupdate;
begin
 inc(fupdating);
end;

procedure tcustomtabbar.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  tabchanged(nil);
 end;
end;

function tcustomtabbar.tabatpos(const apos: pointty; const enabledonly: boolean = false): integer;
begin
 begin
  if enabledonly then begin
   result:= findshapeatpos(flayoutinfo.cells,apos,[ss_invisible,ss_disabled]);
  end
  else begin
   result:= findshapeatpos(flayoutinfo.cells,apos,[ss_invisible]);
  end;
 end;
end;

procedure tcustomtabbar.movetab(curindex,newindex: integer);
begin
 if canevent(tmethod(fontabmoving)) then begin
  fontabmoving(self,curindex,newindex);
 end;
 flayoutinfo.tabs.move(curindex,newindex);
 if canevent(tmethod(fontabmoved)) then begin
  fontabmoved(self,curindex,newindex);
 end;
end;

procedure tcustomtabbar.dostep(const event: stepkindty);
begin
 firsttab:= frame.executestepevent(event,flayoutinfo.stepinfo,flayoutinfo.firsttab);
end;

procedure tcustomtabbar.setfirsttab(Value: integer);
begin
 with flayoutinfo do begin
  if value >= tabs.count - 1 then begin
   value:= tabs.count - 1;
  end;
  if value < 0 then begin
   value:= 0;
  end;
  if firsttab <> value then begin
   firsttab:= value;
   layoutchanged;
  end;
 end;
end;

procedure tcustomtabbar.setoptions(const avalue: tabbaroptionsty);
var
 optionsbefore: tabbaroptionsty;
 delta: tabbaroptionsty;
begin
 if avalue <> foptions then begin
  optionsbefore:= foptions;
  foptions:= avalue;
  delta:= tabbaroptionsty({$ifdef FPC}longword{$else}word{$endif}(avalue) xor
                 {$ifdef FPC}longword{$else}word{$endif}(optionsbefore));
  if not (csloading in componentstate) then begin
   if (delta * [tabo_sorted,tabo_acttabfirst] <> []) then begin
    tabchanged(nil);
   end;
  end;
  if delta * [tabo_vertical,tabo_opposite,tabo_buttonsoutside] <> [] then begin
   layoutchanged;
  end;
 end;
end;
{
procedure tcustomtabbar.setinvisiblebuttons(const Value: stepkindsty);
begin
 inherited;
 if not (csloading in componentstate) then begin
  updatelayout;
 end;
end;
}
procedure tcustomtabbar.dragevent(var info: draginfoty);
var
 int1: integer;

 function candest: boolean;
 begin
  with info do begin
   if (dragobject^ is ttagdragobject) and (dragobject^.sender = self) and
    ((tabo_dragdest in foptions) or (csdesigning in componentstate)) then begin
    int1:= tabatpos(pos,(tabo_dragdestenabledonly in foptions) and 
                            not(csdesigning in componentstate));
    result:= (ttagdragobject(dragobject^).tag <> int1) and
                ((int1 >= 0) {or (csdesigning in componentstate)});
   end
   else begin
    result:= false;
   end;
  end;
 end;

begin
 if not fdragcontroller.beforedragevent(info) then begin
  with info do begin
   case eventkind of
    dek_begin: begin
     if (dragobject^ = nil) and not (tabo_sorted in foptions) and
      ((tabo_dragsource in foptions) or (csdesigning in componentstate)) then begin
      int1:= tabatpos(pos,(tabo_dragsourceenabledonly in foptions) and
                  not (csdesigning in componentstate));
      if int1 >= 0 then begin
       ttagdragobject.create(self,dragobject^,fdragcontroller.pickpos,int1);
      end;
     end;
    end;
    dek_check: begin
     if candest then begin
      accept:= true;
     end;
    end;
    dek_drop: begin
     if candest then begin
//      flayoutinfo.tabs.move(ttagdragobject(dragobject^).tag,int1);
      movetab(ttagdragobject(dragobject^).tag,int1);
     end;
    end;
   end;
  end;
 end;
 fdragcontroller.afterdragevent(info);
 if not info.accept then begin
  inherited;
 end;
end;

{ ttabbar }

procedure ttabbar.dostatread(const reader: tstatreader);
begin
 flayoutinfo.tabs.dostatread(reader);
 activetab:= reader.readinteger('activetab',activetab);
end;

procedure ttabbar.dostatwrite(const writer: tstatwriter);
begin
 flayoutinfo.tabs.dostatwrite(writer);
 writer.writeinteger('activetab',activetab);
end;

function ttabbar.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure ttabbar.setdragcontroller(const Value: tdragcontroller);
begin
 fdragcontroller.assign(Value);
end;

procedure ttabbar.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure ttabbar.statreading;
begin
 //dummy
end;

procedure ttabbar.statread;
begin
 //dummy
end;

{ ttabpage }

constructor ttabpage.create(aowner: tcomponent);
begin
 inherited;
 fcolortab:= cl_default;
 fcoloractivetab:= cl_default;
 foptionswidget:= defaulttaboptionswidget;
 exclude(fwidgetstate,ws_visible);
end;

procedure ttabpage.loaded;
begin
 if fparentwidget is tcustomtabwidget then begin
  include(fwidgetstate,ws_nodesignvisible);
 end;
 inherited;
end;

procedure ttabpage.changed;
begin
 if ftabwidget <> nil then begin
  ftabwidget.pagechanged(itabpage(self));
 end;
end;

function ttabpage.getcaption: captionty;
begin
 result:= fcaption;
end;

procedure ttabpage.setcaption(const Value: captionty);
begin
 fcaption:= value;
 changed;
end;

function ttabpage.getcolortab: colorty;
begin
 result:= fcolortab;
end;

procedure ttabpage.setcolortab(const avalue: colorty);
begin
 fcolortab:= avalue;
 changed;
end;

function ttabpage.getcoloractivetab: colorty;
begin
 result:= fcoloractivetab;
end;

procedure ttabpage.setcoloractivetab(const avalue: colorty);
begin
 fcoloractivetab:= avalue;
 changed;
end;

procedure ttabpage.registerchildwidget(const child: twidget);
begin
 if child is ttabpage then begin
  child.parentwidget:= parentwidget;
 end
 else begin
  inherited;
 end;
end;

function ttabpage.gettabwidget: tcustomtabwidget;
begin
 result:= ftabwidget;
end;

procedure ttabpage.settabwidget(const value: tcustomtabwidget);
begin
 ftabwidget:= value;
end;

procedure ttabpage.visiblechanged;
begin
 inherited;
 changed;
end;

procedure ttabpage.enabledchanged;
begin
 inherited;
 changed;
end;

procedure ttabpage.designselected(const selected: boolean);
begin
 inherited;
 if selected then begin
  if ftabwidget <> nil then begin
   ftabwidget.activepage:= self;
  end;
 end;
end;

function ttabpage.isactivepage: boolean;
begin
 result:= (ftabwidget <> nil) and (ftabwidget.activepage = self);
end;

function ttabpage.gettabindex: integer;
begin
 if tabwidget = nil then begin
  result:= -1;
 end
 else begin
  result:= tabwidget.indexof(self);
 end;
end;

procedure ttabpage.settabindex(const avalue: integer);
begin
 if tabwidget <> nil then begin
  tabwidget.movepage(tabindex,avalue);
 end;
end;

procedure ttabpage.doselect;
begin
 if canevent(tmethod(fonselect)) then begin
  fonselect(self);
 end;
end;

procedure ttabpage.dodeselect;
begin
 if canevent(tmethod(fondeselect)) then begin
  fondeselect(self);
 end;
end;

{ ttabform }

constructor ttabform.create(aowner: tcomponent);
begin
 fcolortab:= cl_default;
 fcoloractivetab:= cl_active;
 inherited create(aowner);
 exclude(fwidgetstate,ws_visible);
end;

procedure ttabform.loaded;
begin
 if fparentwidget is tcustomtabwidget then begin
  include(fwidgetstate,ws_nodesignvisible);
 end;
 inherited;
end;

procedure ttabform.changed;
begin
 if ftabwidget <> nil then begin
  ftabwidget.pagechanged(itabpage(self));
 end;
end;

function ttabform.getcolortab: colorty;
begin
 result:= fcolortab;
end;

procedure ttabform.setcolortab(const avalue: colorty);
begin
 fcolortab:= avalue;
 changed;
end;

function ttabform.getcoloractivetab: colorty;
begin
 result:= fcoloractivetab;
end;

procedure ttabform.setcoloractivetab(const avalue: colorty);
begin
 fcoloractivetab:= avalue;
 changed;
end;

function ttabform.gettabwidget: tcustomtabwidget;
begin
 result:= ftabwidget;
end;

function ttabform.isactivepage: boolean;
begin
 result:= (ftabwidget <> nil) and (ftabwidget.activepage = self);
end;

procedure ttabform.setcaption(const value: msestring);
begin
 inherited;
 changed;
end;

procedure ttabform.settabwidget(const value: tcustomtabwidget);
begin
 ftabwidget:= value;
end;

procedure ttabform.visiblechanged;
begin
 inherited;
 changed;
end;

function ttabform.gettabindex: integer;
begin
 if tabwidget = nil then begin
  result:= -1;
 end
 else begin
  result:= tabwidget.indexof(self);
 end;
end;

procedure ttabform.settabindex(const avalue: integer);
begin
 if tabwidget <> nil then begin
  tabwidget.movepage(tabindex,avalue);
 end;
end;

procedure ttabform.doselect;
begin
 if canevent(tmethod(fonselect)) then begin
  fonselect(self);
 end;
end;

procedure ttabform.dodeselect;
begin
 if canevent(tmethod(fondeselect)) then begin
  fondeselect(self);
 end;
end;

{ tcustomtabwidget }

constructor tcustomtabwidget.create(aowner: tcomponent);
begin
 factivepageindex:= -1;
 ftab_sizemin:= defaulttabsizemin;
 ftab_sizemax:= defaulttabsizemax;
 inherited;
 foptionswidget:= defaulttaboptionswidget;
 ftabs:= tcustomtabbar.create(self);
 ftab_size:= ftabs.size.cy;
 ftabs.SetSubComponent(true);
 ftabs.tabs.oncreatetab:= {$ifdef FPC}@{$endif}createpagetab;
 exclude(ftabs.fwidgetstate,ws_iswidget);
 ftabs.parentwidget:= self;
 ftabs.finternaltabchange:= {$ifdef FPC}@{$endif}tabchanged;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self),org_widget);
end;

destructor tcustomtabwidget.destroy;
begin
 fobjectpicker.free;
 ftabs.free;
 inherited;
end;

procedure tcustomtabwidget.clear;
begin
 while count > 0 do begin
  items[count-1].Free;
 end;
end;

function tcustomtabwidget.getitems(const index: integer): twidget;
begin
 result:= tpagetab(ftabs.tabs[index]).page;
end;

procedure tcustomtabwidget.pagechanged(const sender: itabpage);
var
 widget1: twidget1;
 int1: integer;
 activepageindexbefore: integer;
begin
 if not (ws_destroying in fwidgetstate) then begin
  widget1:= twidget1(sender.getwidget);
  int1:= indexof(widget1);
  if not (csloading in componentstate) then begin
   activepageindexbefore:= factivepageindex;
   ftabs.tabs[int1].caption:= sender.getcaption;
   ftabs.tabs[int1].color:= sender.getcolortab;
   ftabs.tabs[int1].coloractive:= sender.getcoloractivetab;
   if not widget1.enabled then begin
    ftabs.tabs[int1].state:= ftabs.tabs[int1].state + [ts_disabled];
   end
   else begin
    ftabs.tabs[int1].state:= ftabs.tabs[int1].state - [ts_disabled];
   end;
   if widget1.isvisible and (widget1.enabled or 
                    (csdesigning in widget1.componentstate)) then begin
    setactivepageindex(int1);
   end
   else begin
    if (activepageindexbefore = int1) and not (csdestroying in componentstate) then begin
     changepage(1);
     if factivepageindex = activepageindexbefore then begin
      setactivepageindex(-1); //select none
     end;
    end;
   end;
  end
  else begin
   with ftabs.tabs[int1] do begin
    include(fstate,ts_updating);
    caption:= sender.getcaption; //no updatelayout
    exclude(fstate,ts_updating);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.loaded;
var
 int1: integer;
begin
 inc(fdesignchangedlock);
 inherited;
 ftabs.loaded;
 updatesize(nil);
 int1:= factivepageindex;
 factivepageindex:= -1;
 activepageindex:= int1;
 dec(fdesignchangedlock);
end;

procedure tcustomtabwidget.updatesize(const page: twidget);
var
 rect1: rectty;

 procedure updatepagesize(const apage: twidget);
 var
  rect2: rectty;
 begin
  with rect2 do begin
   if tabo_vertical in ftabs.options then begin
    cx:= rect1.cx - ftabs.bounds_cx;
    y:= rect1.y;
    cy:= rect1.cy;
    if tabo_opposite in ftabs.options then begin
     x:= rect1.x;
    end
    else begin
     x:= rect1.x + ftabs.bounds_cx;
    end;
   end
   else begin
    cy:= rect1.cy - ftabs.bounds_cy;
    x:= rect1.x;
    cx:= rect1.cx;
    if tabo_opposite in ftabs.options then begin
     y:= rect1.y;
    end
    else begin
     y:= rect1.y + ftabs.bounds_cy;
    end;
   end;
  end;
  apage.widgetrect:= rect2;
 end;

var
 int1: integer;

begin
 if not (csloading in componentstate) then begin
  rect1:= innerwidgetrect;
  if page <> nil then begin
   updatepagesize(page);
  end
  else begin
   if tabo_vertical in ftabs.options then begin
    if tabo_opposite in ftabs.options then begin
     ftabs.setwidgetrect(makerect(rect1.x+rect1.cx-ftab_size,rect1.y,
                                         ftab_size,rect1.cy));
    end
    else begin
     ftabs.setwidgetrect(makerect(rect1.x,rect1.y,ftab_size,rect1.cy));
    end;
   end
   else begin
    if tabo_opposite in ftabs.options then begin
     ftabs.setwidgetrect(makerect(rect1.x,rect1.y+rect1.cy-ftab_size,
                                         rect1.cx,ftab_size));
    end
    else begin
     ftabs.setwidgetrect(makerect(rect1.x,rect1.y,rect1.cx,ftab_size));
    end;
   end;
   for int1:= 0 to ftabs.tabs.count - 1 do begin
    updatepagesize(items[int1]);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.internaladd(const page: itabpage; aindex: integer);
var
 tab: tpagetab;
 widget1: twidget1;
begin
 widget1:= twidget1(page.getwidget);
 if indexof(widget1) < 0 then begin
  if aindex > count then begin
   aindex:= count;
  end;
  widget1.visible:= false;
  tab:= tpagetab.create(ftabs,page);
  if not (csloading in componentstate) then begin
   ftabs.tabs.insert(tab,aindex);
   with widget1 do begin
    parentwidget:= self;
    anchors:= [an_bottom,an_top,an_left,an_right];
   end;
   updatesize(widget1);
  end
  else begin
   ftabs.tabs.beginupdate;
   ftabs.tabs.insert(tab,aindex);
   ftabs.tabs.endupdate(true);
  end;
  include(widget1.fwidgetstate,ws_nodesignvisible);
  page.settabwidget(self);
  pagechanged(page);
  if not (csloading in componentstate) then begin
   activepageindex:= aindex;
  end;
  dopageadded(widget1);
 end;
end;

procedure tcustomtabwidget.internalremove(const page: itabpage);
var
 int1: integer;
 widget1: twidget1;
 activebefore: integer;
begin
 if ftabs <> nil then begin
  widget1:= twidget1(page.getwidget);
  int1:= indexof(widget1);
  if int1 >= 0 then begin
   activebefore:= factivepageindex;
   if factivepageindex >= 0 then begin
    if factivepageindex > int1 then begin
     dec(factivepageindex);
    end
    else begin
     if factivepageindex = int1 then begin
      factivepageindex:= -1;
     end;
    end;
   end;
   ftabs.flayoutinfo.activetab:= factivepageindex;
   ftabs.tabs.delete(int1);
   with widget1 do begin
    exclude(fwidgetstate,ws_nodesignvisible);
    if page.gettabwidget = self then begin
     page.settabwidget(nil);
    end;
   end;
   dopageremoved(widget1);
   if (activebefore <> factivepageindex) and (factivepageindex = -1) then begin
    nextpage(activebefore,true);
    if factivepageindex = -1 then begin
     doactivepagechanged;
    end;
   end;
  end;
 end;
end;

procedure tcustomtabwidget.registerchildwidget(const child: twidget);
var
 intf: itabpage;
begin
 inherited;
 if twidget1(child).getcorbainterface(typeinfo(itabpage),intf) then begin
  internaladd(intf,bigint);
 end;
end;

procedure tcustomtabwidget.add(const aitem: itabpage; const aindex: integer = bigint);
begin
 internaladd(aitem,aindex);
end;

procedure tcustomtabwidget.unregisterchildwidget(const child: twidget);
var
 intf: itabpage;
begin
 inherited;
 if not (csdestroying in componentstate) and
              twidget1(child).getcorbainterface(typeinfo(itabpage),intf) then begin
  internalremove(intf);
 end;
end;

function tcustomtabwidget.indexof(const page: twidget): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to count-1 do begin
  if items[int1] = page then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tcustomtabwidget.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
 int1: integer;
 widget1: twidget1;
begin
 for int1:= 0 to high(fwidgets) do begin
  exclude(twidget1(fwidgets[int1]).fwidgetstate1,ws1_isstreamed);
 end;
 for int1:= 0 to count-1 do begin
  widget1:= twidget1(items[int1]);
  if widget1.owner = root then begin
   proc(widget1);
   include(widget1.fwidgetstate1,ws1_isstreamed);
  end;
 end;
 for int1:= 0 to widgetcount - 1 do begin
  widget1:= twidget1(fwidgets[int1]);
  if not (ws1_isstreamed in widget1.fwidgetstate1) and
    (widget1.owner = root) and 
              (ws_iswidget in widget1.fwidgetstate) then begin
   proc(widget1);
  end;
 end;
end;

procedure tcustomtabwidget.setactivepageindex(Value: integer);
var
 int1: integer;
begin
 if value <> factivepageindex then begin
  if csloading in componentstate then begin
   factivepageindex:= value;
   exit;
  end;
  if (value >= 0) then begin
   ftabs.flayoutinfo.tabs.checkindex(value);
  end
  else begin
   value:= -1;
  end;
  if factivepageindex >= 0 then begin
   if not canparentclose(items[factivepageindex]) then begin
    ftabs.tabs[factivepageindex].active:= true;
    exit;
   end;
   int1:= factivepageindex;
   factivepageindex:= -1;
   if not (csloading in componentstate) then begin
    tpagetab(ftabs.tabs[int1]).fpageintf.dodeselect;
    if (factivepageindex <> -1) then begin
     exit;
    end;
   end;
   items[int1].visible:= false;
   if (factivepageindex <> -1) or items[int1].visible then begin
    exit;
   end;
   ftabs.tabs[int1].active:= false; //if items[int1] was already invisible
  end;
  factivepageindex := Value;
  if value >= 0 then begin
   defaultfocuschild:= items[value];
   if not (csloading in componentstate) then begin
    tpagetab(ftabs.tabs[value]).fpageintf.doselect;
    if factivepageindex <> value then begin
     exit;
    end;
   end;
   with items[value] do begin
    bringtofront; //needed in design mode where all widgets are visible
    visible:= true;
    if self.entered and canfocus then begin
     setfocus;
    end;
   end;
  end
  else begin
   defaultfocuschild:= nil;
  end;
  if (value = factivepageindex) then begin
   doactivepagechanged;
   if value >= 0 then begin
    ftabs.tabs[value].active:= true
   end;
  end;
 end;
end;

procedure tcustomtabwidget.tabchanged;
begin
 activepageindex:= ftabs.activetab;
end;

function tcustomtabwidget.count: integer;
begin
 result:= ftabs.tabs.count;
end;

function tcustomtabwidget.getactivepage: twidget;
begin
 if factivepageindex >= 0 then begin
  result:= items[factivepageindex];
 end
 else begin
  result:= nil;
 end;
end;

procedure tcustomtabwidget.setactivepage(const value: twidget);
begin
 if value = nil then begin
  setactivepageindex(-1);
 end
 else begin
  setactivepageindex(indexof(value));
 end;
end;

procedure tcustomtabwidget.clientrectchanged;
var
 size1: sizety;
begin
 inherited;
 if not (csloading in componentstate) then begin
  size1:= innerclientsize;
  if tabo_vertical in ftabs.foptions then begin
   if size1.cx < tab_size then begin
    tab_size:= size1.cx
   end
   else begin
    updatesize(nil);
   end;
  end
  else begin
   if size1.cy < tab_size then begin
    tab_size:= size1.cy
   end
   else begin
    updatesize(nil);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.doactivepagechanged;
begin
 if canevent(tmethod(fonactivepagechanged)) then begin
  fonactivepagechanged(self);
 end;
 designchanged;
end;

procedure tcustomtabwidget.dopageadded(const apage: twidget);
begin
 if canevent(tmethod(fonpageadded)) then begin
  fonpageadded(self,apage);
 end;
end;

procedure tcustomtabwidget.dopageremoved(const apage: twidget);
begin
 if canevent(tmethod(fonpageremoved)) then begin
  fonpageremoved(self,apage);
 end;
end;

procedure tcustomtabwidget.nextpage(newindex: integer; down: boolean);
var
 int1: integer;
begin
 if count > 0 then begin
  if (newindex >= count) or (newindex < 0) then begin
   if down then begin
    newindex:= count - 1;
   end
   else begin
    newindex:= 0;
   end;
  end;
  int1:= newindex;
  repeat
   if (items[int1].enabled) or (csdesigning in componentstate) then begin
    setactivepageindex(int1);
    break;
   end
   else begin
    if down then begin
     dec(int1);
     if int1 < 0 then begin
      int1:= count - 1;
     end;
    end
    else begin
     inc(int1);
     if int1 >= count then begin
      int1:= 0;
     end;
    end;
   end;
  until int1 = newindex;
  if not ((items[int1].enabled) or (csdesigning in componentstate)) then begin
   setactivepageindex(-1);
  end;
 end;
end;

procedure tcustomtabwidget.changepage(step: integer);
begin
 nextpage(activepageindex+step,step < 0);
end;

procedure tcustomtabwidget.movepage(const curindex,newindex: integer);
begin
 ftabs.movetab(curindex,newindex);
end;

procedure tcustomtabwidget.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (shiftstate = [ss_ctrl]) or (shiftstate = [ss_shift,ss_ctrl]) then begin
   include(eventstate,es_processed);
   case key of
    key_tab: begin
     changepage(1);
    end;
    key_backtab: begin
     changepage(-1);
    end
    else begin
     exclude(eventstate,es_processed);
    end;
   end;
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomtabwidget.childmouseevent(const sender: twidget; var info: mouseeventinfoty);
begin
 if not ftabs.fdragcontroller.active and ((sender = self) or (sender = ftabs))  then begin
  translatewidgetpoint1(info.pos,sender,self);
  fobjectpicker.mouseevent(info);
  translatewidgetpoint1(info.pos,self,sender);
 end;
end;

procedure tcustomtabwidget.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 fobjectpicker.restorexorpic(canvas);
end;

procedure tcustomtabwidget.synctofontheight;
begin
 inherited;
 if not (tabo_vertical in options) then begin
  ftabs.synctofontheight;
  tab_size:= ftabs.bounds_cy;
 end;
end;


procedure tcustomtabwidget.dofontheightdelta(var delta: integer);
begin
 if not (tabo_vertical in options) then begin
  synctofontheight;
 end;
end;

function tcustomtabwidget.checktabsizingpos(const apos: pointty): boolean;
begin
 with ftabs,moverect(ftabs.paintrect,ftabs.fwidgetrect.pos) do begin
  if tabo_tabsizing in foptions then begin
   if tabo_vertical in foptions then begin
    if tabo_opposite in foptions then begin
     result:= pointinrect(apos,makerect(x-sizingtol,y,sizingwidth,cy));
    end
    else begin
     result:= pointinrect(apos,makerect(x+cx-sizingtol,y,sizingwidth,cy));
    end;
   end
   else begin
    if tabo_opposite in foptions then begin
     result:= pointinrect(apos,makerect(y,y-sizingtol,cx,sizingwidth));
    end
    else begin
     result:= pointinrect(apos,makerect(y,y+cy-sizingtol,cx,sizingwidth));
    end;
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tcustomtabwidget.getidents: integerarty;
begin
 result:= ftabs.flayoutinfo.tabs.idents;
end;

procedure tcustomtabwidget.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

   //istatfile
procedure tcustomtabwidget.dostatread(const reader: tstatreader);
begin
 ftabs.flayoutinfo.tabs.dostatread(reader);
 if tabo_tabsizing in options then begin
  tab_size:= reader.readinteger('tabsize',tab_size);
 end;
 ftabs.firsttab:= reader.readinteger('firsttab',ftabs.firsttab);
 setactivepageindex(reader.readinteger('index',activepageindex,-1,count-1));
end;

procedure tcustomtabwidget.dostatwrite(const writer: tstatwriter);
begin
 ftabs.flayoutinfo.tabs.dostatwrite(writer);
 if tabo_tabsizing in options then begin
  writer.writeinteger('tabsize',tab_size);
 end;
 writer.writeinteger('firsttab',ftabs.firsttab);
 writer.writeinteger('index',activepageindex);
end;

procedure tcustomtabwidget.statreading;
begin
 //dummy;
end;

procedure tcustomtabwidget.statread;
begin
 //dummy;
end;

function tcustomtabwidget.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

   //iobjectpicker
function tcustomtabwidget.getcursorshape(const apos: pointty;  const shiftstate: shiftstatesty;
                                var shape: cursorshapety): boolean;
    //true if found
begin
 result:= checktabsizingpos(apos);
 if result then begin
  if tabo_vertical in ftabs.foptions then begin
   shape:= cr_sizehor;
  end
  else begin
   shape:= cr_sizever;
  end;
 end
end;

procedure tcustomtabwidget.getpickobjects(const rect: rectty;  const shiftstate: shiftstatesty;
                                 var objects: integerarty);
begin
 if checktabsizingpos(rect.pos) then begin
  setlength(objects,1);
 end;
end;

procedure tcustomtabwidget.beginpickmove(const objects: integerarty);
begin
end;

function tcustomtabwidget.checkpickoffset(const aoffset: pointty): pointty;
begin
 result:= aoffset;
 with ftabs do begin
  if tabo_opposite in foptions then begin
   result.x:= -result.x;
   result.y:= -result.y;
  end;
  if tabo_vertical in foptions then begin
   if tab_size + result.x > tab_sizemax then begin
    result.x:= tab_sizemax - tab_size;
   end;
   if tab_size + result.x > self.paintrect.cx then begin
    result.x:= self.paintrect.cx - tab_size;
   end;
   if tab_size + result.x < tab_sizemin then begin
    result.x:= tab_sizemin - tab_size;
   end;
  end
  else begin
   if tab_size + result.y > tab_sizemax then begin
    result.y:= tab_sizemax - tab_size;
   end;
   if tab_size + result.y > self.paintrect.cy then begin
    result.y:= self.paintrect.cy - tab_size;
   end;
   if tab_size + result.y < tab_sizemin then begin
    result.y:= tab_sizemin - tab_size;
   end;
  end;
  if tabo_opposite in foptions then begin
   result.x:= -result.x;
   result.y:= -result.y;
  end;
 end;
end;

procedure tcustomtabwidget.endpickmove(const apos,offset: pointty; const objects: integerarty);
var
 offset1: pointty;
begin
 offset1:= checkpickoffset(offset);
 with ftabs do begin
  if tabo_vertical in foptions then begin
   if tabo_opposite in foptions then begin
    tab_size:= tab_size - offset1.x;
   end
   else begin
    tab_size:= tab_size + offset1.x;
   end;
  end
  else begin
   if tabo_opposite in foptions then begin
    tab_size:= tab_size - offset1.y;
   end
   else begin
    tab_size:= tab_size + offset1.y;
   end;
  end;
 end;
end;

procedure tcustomtabwidget.paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);
var
 offset1: pointty;
begin
 offset1:= checkpickoffset(offset);
 with ftabs,ftabs.fwidgetrect do begin
  if tabo_vertical in options then begin
   if tabo_opposite in foptions then begin
    canvas.drawline(makepoint(x+offset1.x,y),makepoint(x+offset1.x,y+cy-1),cl_white);
   end
   else begin
    canvas.drawline(makepoint(x+cx+offset1.x,y),makepoint(x+cx+offset1.x,y+cy-1),cl_white);
   end;
  end
  else begin
   if tabo_opposite in foptions then begin
    canvas.drawline(makepoint(x,y+offset1.y),makepoint(cx-1,y+offset1.y),cl_white);
   end
   else begin
    canvas.drawline(makepoint(x,y+cy+offset1.y),makepoint(cx-1,y+cy+offset1.y),cl_white);
   end;
  end;
 end;
end;

function tcustomtabwidget.getoptions: tabbaroptionsty;
begin
 result:= ftabs.options;
end;

procedure tcustomtabwidget.setoptions(const Value: tabbaroptionsty);
var
 optionsbefore: tabbaroptionsty;
begin
 optionsbefore:= ftabs.options;
 ftabs.options:= value;
 if (tabbaroptionsty({$ifdef FPC}longword{$else}word{$endif}(optionsbefore) xor
            {$ifdef FPC}longword{$else}word{$endif}(ftabs.options)) *
    [tabo_vertical,tabo_opposite] <> []) then begin
  updatesize(nil);
 end;
end;

function tcustomtabwidget.gettab_color: colorty;
begin
 Result := ftabs.color;
end;

procedure tcustomtabwidget.settab_color(const avalue: colorty);
begin
 ftabs.color:= avalue;
end;

function tcustomtabwidget.gettab_frame: tstepboxframe;
begin
 Result := ftabs.frame;
end;

procedure tcustomtabwidget.settab_frame(const avalue: tstepboxframe);
begin
 ftabs.frame:= avalue;
end;

function tcustomtabwidget.gettab_face: tface;
begin
 Result:= ftabs.face;
end;

procedure tcustomtabwidget.settab_face(const avalue: tface);
begin
 ftabs.face:= avalue;
end;

function tcustomtabwidget.gettab_colortab: colorty;
begin
 result:= ftabs.tabs.color;
end;

procedure tcustomtabwidget.settab_colortab(const avalue: colorty);
begin
 ftabs.tabs.color:= avalue;
end;

function tcustomtabwidget.gettab_coloractivetab: colorty;
begin
 result:= ftabs.tabs.coloractive;
end;

procedure tcustomtabwidget.settab_coloractivetab(const avalue: colorty);
begin
 ftabs.tabs.coloractive:= avalue;
end;

function tcustomtabwidget.gettab_facetab: tface;
begin
 result:= ftabs.tabs.face;
end;

procedure tcustomtabwidget.settab_facetab(const avalue: tface);
begin
 ftabs.tabs.face:= avalue;
end;

function tcustomtabwidget.gettab_faceactivetab: tface;
begin
 result:= ftabs.tabs.faceactive;
end;

procedure tcustomtabwidget.settab_faceactivetab(const avalue: tface);
begin
 ftabs.tabs.faceactive:= avalue;
end;

procedure tcustomtabwidget.createpagetab(const sender: tcustomtabbar;
  const index: integer; var tab: ttab);
begin
 tab:= tpagetab.create(sender,nil);
end;

procedure tcustomtabwidget.settab_size(const avalue: integer);
begin
 if ftab_size <> avalue then begin
  ftab_size:= avalue;
  if ftab_size < ftab_sizemin then begin
   ftab_size:= ftab_sizemin;
  end
  else begin
   if ftab_size > ftab_sizemax then begin
    ftab_size:= ftab_sizemax;
   end;
  end;
  if not (csloading in componentstate) then begin
   updatesize(nil);
  end;
 end;
end;

procedure tcustomtabwidget.settab_sizemin(const avalue: integer);
begin
 ftab_sizemin:= avalue;
 if avalue > ftab_size then begin
  tab_size:= avalue;
 end;
end;

procedure tcustomtabwidget.settab_sizemax(const avalue: integer);
begin
 ftab_sizemax:= avalue;
 if avalue < ftab_size then begin
  tab_size:= avalue;
 end;
end;

function tcustomtabwidget.pagebyname(const aname: string): twidget;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  result:= items[int1];
  if result.name = aname then begin
   exit;
  end;
 end;
 raise exception.create('Tabpage '''+aname+''' not found.');
end;

{ tpagetab }

constructor tpagetab.create(const aowner: tcustomtabbar; const apage: itabpage);
begin
 fpageintf:= apage;
 inherited create(aowner);
end;

function tpagetab.page: twidget;
begin
 result:= fpageintf.getwidget;
end;

end.
