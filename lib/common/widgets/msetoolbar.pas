{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetoolbar;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,msewidgets,msearrayprops,mseclasses,msebitmap,
 mseact,mseshapes,msemenus,
 msegraphutils,msegraphics,mseevent,
 mseglob,mseguiglob,msegui,msesimplewidgets,
 msestat,msestatfile,msedrag,msestrings;

type

 tcustomtoolbar = class;

 ttoolbutton = class(tindexpersistent,iactionlink)
  private
   finfo: actioninfoty;
   fonupdate: actioneventty;
   procedure setaction(const Value: tcustomaction);
   procedure setimagenr(const Value: integer);
   procedure setcolorglyph(const avalue: colorty);
   function iscolorglyphstored: boolean;
   procedure setcolor(const avalue: colorty);
   function iscolorstored: boolean;
   procedure setimagecheckedoffset(const Value: integer);
   function getstate: actionstatesty;
   function isstatestored: Boolean;
   procedure setstate(const Value: actionstatesty);
   function isimagenrstored: Boolean;
   function isimagecheckedoffsetstored: Boolean;
   function isimageliststored: Boolean;
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist);
   function isgroupstored: Boolean;
   procedure setgroup(const Value: integer);
   procedure changed;
   function getchecked: boolean;
   procedure setchecked(const Value: boolean);
   procedure sethint(const Value: msestring);
   function ishintstored: Boolean;
   procedure setonexecute(const Value: notifyeventty);
   function isonexecutestored: Boolean;
   procedure setoptions(const Value: menuactionoptionsty);
   procedure setshortcut(const value: shortcutty);
   function isshortcutstored: boolean;
   function getenabled: boolean;
   function getvisible: boolean;
   procedure setenabled(const avalue: boolean);
   procedure setvisible(const avalue: boolean);
  protected
   ftag: integer;
   procedure doexecute(const tag: integer; const info: mouseeventinfoty);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   //iactionlink
   procedure actionchanged;
   function getactioninfopo: pactioninfoty;
   procedure doshortcut(var info: keyeventinfoty);
   function getinstance: tobject; override;
   function loading: boolean;
   function shortcutseparator: msechar;
   procedure calccaptiontext(var ainfo: actioninfoty);
   
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); overload; override;
   constructor create(aowner: tcustomtoolbar); reintroduce; overload;
   function toolbar: tcustomtoolbar;
   function index: integer;
   property checked: boolean read getchecked write setchecked;
  published
   property imagelist: timagelist read getimagelist write setimagelist
                    stored isimageliststored;
   property imagenr: integer read finfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph 
                       stored iscolorglyphstored default cl_glyph;
   property color: colorty read finfo.color write setcolor 
                       stored iscolorstored default cl_transparent;
   property imagecheckedoffset: integer read finfo.imagecheckedoffset
              write setimagecheckedoffset
                            stored isimagecheckedoffsetstored default 0;
   property hint: msestring read finfo.hint write sethint stored ishintstored;
   property action: tcustomaction read finfo.action write setaction;
   property state: actionstatesty read getstate write setstate
                             stored isstatestored default [];
   property shortcut: shortcutty read finfo.shortcut write setshortcut
                        stored isshortcutstored default 0;
   property tag: integer read ftag write ftag default 0;
   property options: menuactionoptionsty read finfo.options write setoptions default [];
   property group: integer read finfo.group write setgroup
                             stored isgroupstored default 0;
   property visible: boolean read getvisible write setvisible default true;
   property enabled: boolean read getenabled write setenabled default true;
   property onexecute: notifyeventty read finfo.onexecute write setonexecute
                               stored isonexecutestored;
   property onupdate: actioneventty read fonupdate write fonupdate;
 end;
 ptoolbutton = ^ttoolbutton;

 ttoolbuttons = class(tindexpersistentarrayprop)
  private
   fheight: integer;
   fwidth: integer;
   fimagelist: timagelist;
   fcolorglyph: colorty;
   fcolor: colorty;
   fface: tface;
   procedure setitems(const index: integer; const Value: ttoolbutton);
   function getitems(const index: integer): ttoolbutton; reintroduce;
   procedure setheight(const Value: integer);
   procedure setwidth(const Value: integer);
   procedure setimagelist(const avalue: timagelist);
   procedure setcolorglyph(const avalue: colorty);
   procedure setcolor(const avalue: colorty);
   function getface: tface;
   procedure setface(const avalue: tface);
   procedure createface;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure dochange(const index: integer); override;
  public
   constructor create(const aowner: tcustomtoolbar); reintroduce;
   destructor destroy; override;
   procedure resetradioitems(const group: integer);
   function getcheckedradioitem(const group: integer): ttoolbutton;
   function add: ttoolbutton;
   property items[const index: integer]: ttoolbutton read getitems write setitems; default;
  published
   property width: integer read fwidth write setwidth default 0;
   property height: integer read fheight write setheight default 0;
   property imagelist: timagelist read fimagelist write setimagelist;
   property colorglyph: colorty read fcolorglyph write setcolorglyph default cl_glyph;
   property color: colorty read fcolor write setcolor default cl_transparent;
   property face: tface read getface write setface;
 end;

 toolbaroptionty = ({tbo_autosize,}tbo_dragsource,tbo_dragdest,
                     tbo_dragsourceenabledonly,tbo_dragdestenabledonly,
                     tbo_nohorz,tbo_novert);
 toolbaroptionsty = set of toolbaroptionty;

 toolbarlayoutinfoty = record
  vert: boolean;
  buttons: ttoolbuttons;
  cells: shapeinfoarty;
  stepinfo: framestepinfoty;
//  maxbuttons: integer;
  lines: integer;
  buttonsize: sizety;
  defaultsize: sizety;
 end;

 toolbuttoneventty = procedure(const sender: tobject;
              const button: ttoolbutton) of object;

 tcustomtoolbar = class(tcustomstepbox,istatfile)
  private
   flayout: toolbarlayoutinfoty;
   flayoutok: boolean;
   foptions: toolbaroptionsty;
   fonbuttonchanged: toolbuttoneventty;
   fhintedbutton: integer;
   fupdating: integer;
   ffirstbutton: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setbuttons(const Value: ttoolbuttons);
   procedure setoptions(const Value: toolbaroptionsty);
   function gethintpos(index: integer): rectty;
   procedure setfirstbutton(value: integer);
   procedure buttonschanged(const sender: tarrayprop; const index: integer);
   procedure setstatfile(const Value: tstatfile);
   procedure setdragcontroller(const Value: tdragcontroller);
  protected
   procedure buttonchanged(sender: ttoolbutton);
   procedure checkvert(const asize: sizety);
   procedure getautopaintsize(var asize: sizety); override;
   procedure updatelayout;
   procedure clientrectchanged; override;
   procedure dopaint(const canvas: tcanvas); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure showhint(var info: hintinfoty); override;
   procedure dostep(const event: stepkindty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure dragevent(var info: draginfoty); override;
   procedure beginupdate;
   procedure endupdate;
   function buttonatpos(const apos: pointty; const enabledonly: boolean = false): ttoolbutton;

   property buttons: ttoolbuttons read flayout.buttons write setbuttons;
   property firstbutton: integer read ffirstbutton write setfirstbutton default 0;
   property options: toolbaroptionsty read foptions write setoptions default [];
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onbuttonchanged: toolbuttoneventty read fonbuttonchanged write fonbuttonchanged;
   property drag: tdragcontroller read fdragcontroller write setdragcontroller;

 end;

 ttoolbar = class(tcustomtoolbar)
  published
   property frame;
   property onstep;

   property optionswidget default defaultoptionswidgetnofocus;
   property buttons;
   property firstbutton;
   property options;
   property statfile;
   property statvarname;
   property onbuttonchanged;
   property drag;
  end;

implementation
uses
 sysutils,msebits,mseactions;
 
const
 separatorwidth = 3;
type
 tcustomstepframe1 = class(tcustomstepframe);
 
procedure drawtoolbuttons(const canvas: tcanvas;
           var layout: toolbarlayoutinfoty);
var
 int1: integer;
begin
 with layout do begin
  for int1:= 0 to high(cells) do begin
   cells[int1].face:= buttons.fface;
   drawtoolbutton(canvas,cells[int1]);
  end;
 end;
end;

{ ttoolbutton }

constructor ttoolbutton.create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop);
begin
 initactioninfo(finfo);
 inherited;
end;

constructor ttoolbutton.create(aowner: tcustomtoolbar);
begin
 create(aowner,aowner.buttons);
end;

procedure ttoolbutton.objectevent(const sender: tobject; const event: objecteventty);
begin
 inherited;
 if sender = finfo.imagelist then begin
  if event = oe_destroyed then begin
   finfo.imagelist:= nil;
  end;
  changed;
 end;
end;

procedure ttoolbutton.actionchanged;
begin
 changed;
end;

function ttoolbutton.getactioninfopo: pactioninfoty;
begin
 result:= @finfo;
end;

function ttoolbutton.toolbar: tcustomtoolbar;
begin
 result:= tcustomtoolbar(fowner);
end;

procedure ttoolbutton.setaction(const Value: tcustomaction);
begin
 linktoaction(iactionlink(self),value,finfo);
end;

function ttoolbutton.getstate: actionstatesty;
begin
 result:= finfo.state;
end;

procedure ttoolbutton.setstate(const Value: actionstatesty);
begin
 setactionstate(iactionlink(self),value);
end;

function ttoolbutton.isstatestored: Boolean;
begin
 result:= isactionstatestored(finfo);
end;

function ttoolbutton.getimagelist: timagelist;
begin
 result:= timagelist(finfo.imagelist);
end;

procedure ttoolbutton.setimagelist(const Value: timagelist);
begin
 setactionimagelist(iactionlink(self),value);
end;

function ttoolbutton.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(finfo);
end;

procedure ttoolbutton.setshortcut(const Value: shortcutty);
begin
 setactionshortcut(iactionlink(self),value);
end;

function ttoolbutton.isshortcutstored: Boolean;
begin
 result:= isactionshortcutstored(finfo);
end;

procedure ttoolbutton.setimagenr(const Value: integer);
begin
 setactionimagenr(iactionlink(self),value);
end;

procedure ttoolbutton.setcolorglyph(const avalue: colorty);
begin
 setactioncolorglyph(iactionlink(self),avalue);
end;

function ttoolbutton.iscolorglyphstored: boolean;
begin
 result:= isactioncolorglyphstored(finfo);
end;

procedure ttoolbutton.setcolor(const avalue: colorty);
begin
 setactioncolor(iactionlink(self),avalue);
end;

function ttoolbutton.iscolorstored: boolean;
begin
 result:= isactioncolorstored(finfo);
end;

procedure ttoolbutton.setimagecheckedoffset(const Value: integer);
begin
 setactionimagecheckedoffset(iactionlink(self),value);
end;

function ttoolbutton.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(finfo);
end;

function ttoolbutton.isimagecheckedoffsetstored: Boolean;
begin
 result:= isactionimagecheckedoffsetstored(finfo);
end;

procedure ttoolbutton.sethint(const Value: msestring);
begin
 setactionhint(iactionlink(self),value);
end;

function ttoolbutton.ishintstored: Boolean;
begin
 result:= isactionhintstored(finfo);
end;

procedure ttoolbutton.setonexecute(const Value: notifyeventty);
begin
 setactiononexecute(iactionlink(self),value,csloading in toolbar.componentstate);
end;

function ttoolbutton.isonexecutestored: Boolean;
begin
 result:= isactiononexecutestored(finfo);
end;

procedure ttoolbutton.setgroup(const Value: integer);
begin
 setactiongroup(iactionlink(self),value);
end;

function ttoolbutton.isgroupstored: Boolean;
begin
 result:= isactiongroupstored(finfo);
end;

procedure ttoolbutton.changed;
begin
 tcustomtoolbar(fowner).buttonchanged(self);
end;

function ttoolbutton.index: integer;
begin
 result:= findex;
end;

function ttoolbutton.getchecked: boolean;
begin
 result:= as_checked in finfo.state;
end;

procedure ttoolbutton.setchecked(const Value: boolean);
begin
 if value then begin
  state:= state + [as_checked];
 end
 else begin
  state:= state - [as_checked];
 end;
end;

procedure ttoolbutton.doexecute(const tag: integer; const info: mouseeventinfoty);
begin
 if doactionexecute(self,finfo) then begin
  changed;
 end;
end;

procedure ttoolbutton.setoptions(const Value: menuactionoptionsty);
begin
 if finfo.options <> value then begin
  finfo.options := Value;
  changed;
 end;
end;

procedure ttoolbutton.doshortcut(var info: keyeventinfoty);
begin
 if doactionshortcut(self,finfo,info) then begin
  changed;
 end;
end;

function ttoolbutton.getenabled: boolean;
begin
 result:= not (as_disabled in finfo.state);
end;

procedure ttoolbutton.setenabled(const avalue: boolean);
begin
 if avalue then begin
  state:= state - [as_disabled];
 end
 else begin
  state:= state + [as_disabled];
 end;
end;

function ttoolbutton.getvisible: boolean;
begin
 result:= not (as_invisible in finfo.state);
end;

procedure ttoolbutton.setvisible(const avalue: boolean);
begin
 if avalue then begin
  state:= state - [as_invisible];
 end
 else begin
  state:= state + [as_invisible];
 end;
end;

function ttoolbutton.getinstance: tobject;
begin
 result:= fowner;
end;

function ttoolbutton.loading: boolean;
begin
 result:= (fowner is tcomponent) and 
               (csloading in tcomponent(fowner).componentstate);
end;

function ttoolbutton.shortcutseparator: msechar;
begin
 result:= ' ';
end;

procedure ttoolbutton.calccaptiontext(var ainfo: actioninfoty);
begin
 mseactions.calccaptiontext(ainfo,shortcutseparator);
end;

{ ttoolbuttons }

constructor ttoolbuttons.create(const aowner: tcustomtoolbar);
begin
 fcolorglyph:= cl_glyph;
 fcolor:= cl_transparent;
 inherited create(aowner,ttoolbutton);
end;

destructor ttoolbuttons.destroy;
begin
 inherited;
 fface.free;
end;

function ttoolbuttons.add: ttoolbutton;
begin
 count:= count + 1;
 result:= items[count-1];
end;

procedure ttoolbuttons.createitem(const index: integer; var item: tpersistent);
begin
 inherited;
 if not (csloading in tcustomtoolbar(fowner).componentstate) then begin
  with ttoolbutton(item) do begin
   if fimagelist <> nil then begin
    imagelist:= fimagelist;
   end;
   if fcolorglyph <> cl_glyph then begin
    colorglyph:= fcolorglyph;
   end;
   if fcolor <> cl_transparent then begin
    color:= fcolor;
   end;
//   state:= state - [as_localimagelist,as_localcolorglyph,as_localcolor];
  end;
 end;
end;

procedure ttoolbuttons.dochange(const index: integer);
var
 int1: integer;
 po1: ptoolbutton;
begin
 if index < 0 then begin
  po1:= pointer(fitems);
  for int1:= 0 to high(fitems) do begin
   po1^.findex:= int1;
   inc(po1);
  end;
 end
 else begin
  ttoolbutton(fitems[index]).findex:= index;
 end;
 inherited;
end;

function ttoolbuttons.getcheckedradioitem(
  const group: integer): ttoolbutton;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to count - 1 do begin
  with items[int1] do begin
   if (finfo.group = group) and
     (mao_radiobutton in finfo.options) and (as_checked in finfo.state) then begin
    result:= items[int1];
    break;
   end;
  end;
 end;
end;

procedure ttoolbuttons.resetradioitems(const group: integer);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  with items[int1] do begin
   if (finfo.group = group) and (as_checked in finfo.state) then begin
    state:= finfo.state - [as_checked];
   end;
  end;
 end;
end;

function ttoolbuttons.getitems(const index: integer): ttoolbutton;
begin
 result:= ttoolbutton(inherited items[index]);
end;

procedure ttoolbuttons.setitems(const index: integer;
  const Value: ttoolbutton);
begin
 inherited items[index].assign(value);
end;

procedure ttoolbuttons.setheight(const Value: integer);
begin
 if fheight <> value then begin
  fheight:= Value;
  dochange(-1);
 end;
end;

procedure ttoolbuttons.setwidth(const Value: integer);
begin
 if fwidth <> value then begin
  fwidth:= Value;
  dochange(-1);
 end;
end;

procedure ttoolbuttons.setimagelist(const avalue: timagelist);
var
 int1: integer;
begin
 setlinkedvar(avalue,tmsecomponent(fimagelist));
 if not (csloading in tcomponent(fowner).componentstate) then begin
  for int1:= 0 to count - 1 do begin
   items[int1].imagelist:= avalue;
  end;
 end;
end;

procedure ttoolbuttons.setcolorglyph(const avalue: colorty);
var
 int1: integer;
begin
 fcolorglyph:= avalue;
 if not (csloading in tcomponent(fowner).componentstate) then begin
  for int1:= 0 to count - 1 do begin
   items[int1].colorglyph:= avalue;
  end;
 end;
end;

procedure ttoolbuttons.setcolor(const avalue: colorty);
var
 int1: integer;
begin
 fcolor:= avalue;
 if not (csloading in tcomponent(fowner).componentstate) then begin
  for int1:= 0 to count - 1 do begin
   items[int1].color:= avalue;
  end;
 end;
end;

procedure ttoolbuttons.createface;
begin
 fface:= tface.create(iface(tcustomtoolbar(fowner)));
end;

function ttoolbuttons.getface: tface;
begin
 tcustomtoolbar(fowner).getoptionalobject(fface,
                               {$ifdef FPC}@{$endif}createface);
 result:= fface;
end;

procedure ttoolbuttons.setface(const avalue: tface);
begin
 tcustomtoolbar(fowner).setoptionalobject(avalue,fface,
                               {$ifdef FPC}@{$endif}createface);
 tcustomtoolbar(fowner).invalidate;
end;

{ tcustomtoolbar }

constructor tcustomtoolbar.create(aowner: tcomponent);
begin
 flayout.buttons:= ttoolbuttons.create(self);
 flayout.buttons.onchange:= {$ifdef FPC}@{$endif}buttonschanged;
 fhintedbutton:= -2;
 inherited;
end;

destructor tcustomtoolbar.destroy;
begin
 inherited;
 flayout.buttons.Free;
end;

procedure tcustomtoolbar.checkvert(const asize: sizety);
begin
 with flayout do begin
  vert:= asize.cy > asize.cx;
  if (tbo_novert in foptions) then begin
   vert:= false;
  end;
  if (tbo_nohorz in foptions) then begin
   vert:= true;
  end;
  buttonsize:= asize;
  if vert then begin
   if buttons.fwidth > 0 then begin
    buttonsize.cx:= buttons.fwidth;
   end;
   if buttons.fheight = 0 then begin
    buttonsize.cy:= buttonsize.cx;
   end
   else begin
    buttonsize.cy:= buttons.fheight;
   end;
  end
  else begin
   if buttons.fheight > 0 then begin
    buttonsize.cy:= buttons.fheight;
   end;
   if buttons.fwidth = 0 then begin
    buttonsize.cx:= buttonsize.cy;
   end
   else begin
    buttonsize.cx:= buttons.fwidth;
   end;
  end;
 end;
end;

procedure tcustomtoolbar.getautopaintsize(var asize: sizety);
var
 int1: integer;
 size1: sizety;
begin
 with flayout do begin
  if (defaultsize.cx = 0) or (buttons.width = 0) or 
           (defaultsize.cy = 0) or (buttons.height = 0) then begin
   size1:= asize;
   if fframe <> nil then begin
    size1.cx:= size1.cx - fframe.framei_left - fframe.framei_right;
    size1.cy:= size1.cy - fframe.framei_top - fframe.framei_bottom;
   end;
   checkvert(size1);
   if vert then begin
    defaultsize.cx:= buttonsize.cx;
    for int1:= 0 to buttons.count - 1 do begin
     with buttons[int1] do begin
      if not (as_invisible in state) then begin
       if mao_separator in options then begin
        inc(defaultsize.cy,separatorwidth);
       end
       else begin
        inc(defaultsize.cy,buttonsize.cy);
       end;
      end;
     end;
    end;
   end
   else begin
    defaultsize.cy:= buttonsize.cy;
    for int1:= 0 to buttons.count - 1 do begin
     with buttons[int1] do begin
      if not (as_invisible in state) then begin
       if mao_separator in options then begin
        inc(defaultsize.cx,separatorwidth);
       end
       else begin
        inc(defaultsize.cx,buttonsize.cx);
       end;
      end;
     end;
    end;
   end;
   if fframe <> nil then begin
    defaultsize.cx:= defaultsize.cx + fframe.framei_left + fframe.framei_right;
    defaultsize.cy:= defaultsize.cy + fframe.framei_top + fframe.framei_bottom;
   end;
  end;
  asize:= defaultsize;
 end;
end;

procedure tcustomtoolbar.updatelayout;
var
 int1,int2,int3: integer;
 rect1,rect2: rectty;
 endxy: integer;
 buttonsizecxy: integer;
 bu1: stepbuttonposty;
 loopcount: integer;
 size1: sizety; 
begin
 if fupdating <> 0 then begin
  flayoutok:= false;
 end
 else begin
  inc(fupdating);
  try
   loopcount:= 0;
   tcustomstepframe1(fframe).neededbuttons:= [];
   repeat
    flayoutok:= true;
    rect1:= innerclientrect;
    rect2:= rect1;
    inc(loopcount);
    with flayout do begin
     defaultsize:= nullsize;
     checkvert(rect1.size);
     bu1:= frame.buttonpos;
     if frame.buttonpos in [sbp_top,sbp_right] then begin
      if vert then begin
       frame.buttonpos:= sbp_top;
      end
      else begin
       frame.buttonpos:= sbp_right;
      end;
     end
     else begin
      if vert then begin
       frame.buttonpos:= sbp_bottom;
      end
      else begin
       frame.buttonpos:= sbp_left;
      end;
     end;
     rect1.size:= buttonsize;
     if vert then begin
      if rect1.cx > 0 then begin
       lines:= rect2.cx div rect1.cx;
       if lines <= 0 then begin
        lines:= 1;
       end;
      end
      else begin
       lines:= 1;
      end;
     end
     else begin
      if rect1.cy > 0 then begin
       lines:= rect2.cy div rect1.cy;
       if lines <= 0 then begin
        lines:= 1;
       end;
      end
      else begin
       lines:= 1;
      end;
     end;
  
     cells:= nil; //finalize
     setlength(cells,buttons.count); //max
     if vert then begin
      endxy:= rect2.y + rect2.cy;
     end
     else begin
      endxy:= rect2.x + rect2.cx;
     end;
     if vert then begin
      buttonsizecxy:= rect1.cy;
     end
     else begin
      buttonsizecxy:= rect1.cx;
     end;
     int3:= lines - 1;
     with stepinfo do begin
      pagelast:= buttons.count;
      pageup:= stepinfo.pagelast;
      up:= 0;
      if ffirstbutton >= pagelast then begin
       ffirstbutton:= 0; //count changed
      end;
      for int1:= ffirstbutton to pagelast - 1 do begin
       with cells[int1] do begin
        color:= cl_parent;
        actioninfotoshapeinfo(buttons[int1].finfo,cells[int1]);
        include(state,ss_flat);
        if ss_checkbox in state then begin
         include(state,ss_checkbutton);
        end;
        doexecute:= {$ifdef FPC}@{$endif}buttons[int1].doexecute;
        if not (as_invisible in buttons[int1].state) then begin
         if mao_separator in buttons[int1].options then begin
          if vert then begin
           rect1.cy:= separatorwidth;
          end
          else begin
           rect1.cx:= separatorwidth;
          end;
         end
         else begin
          if vert then begin
           rect1.cy:= buttonsizecxy;
          end
          else begin
           rect1.cx:= buttonsizecxy;
          end;
          if up = 0 then begin
           up:= int1 - ffirstbutton;
          end;
         end;
         if vert and (rect1.y + rect1.cy > endxy) or
             not vert and (rect1.x + rect1.cx > endxy) then begin
          if stepinfo.pageup = buttons.count then begin //first loop
           pageup:= int1;
          end;
          if (int3 > 0) then begin
           dec(int3);
           if vert then begin
            inc(rect1.x,rect1.cx);
            rect1.y:= rect2.y;
           end
           else begin
            inc(rect1.y,rect1.cy);
            rect1.x:= rect2.x;
           end;
          end
          else begin
           pagelast:= int1;
           break;
          end;
         end;
         dim:= rect1;
         if vert then begin
          inc(rect1.y,rect1.cy);
         end
         else begin
          inc(rect1.x,rect1.cx);
         end;
        end
        else begin
         include(state,ss_invisible);
        end;
       end;
      end;
      pagedown:= 0;
      down:= 0;
      if vert then begin
       int2:= rect2.cy;
      end
      else begin
       int2:= rect2.cx;
      end;
      for int1:= ffirstbutton - 1 downto 0 do begin
       if not (as_invisible in buttons[int1].state)then begin
        if mao_separator in buttons[int1].options then begin
         dec(int2,separatorwidth);
        end
        else begin
         if vert then begin
          dec(int2,buttons.height);
         end
         else begin
          dec(int2,buttons.fwidth);
         end;
         if down = 0 then begin
          down:= int1 - ffirstbutton;
         end;
        end;
        if int2 < 0 then begin
         pagedown:= int1 + 1;
         break;
        end;
       end;
      end;
      pagelast:= pagelast - ffirstbutton;
      pageup:= pageup - ffirstbutton;
      pagedown:= pagedown - ffirstbutton;
      if up = 0 then begin
       up:= 1;
      end;
      if down = 0 then begin
       down:= -1;
      end;
      frame.updatebuttonstate(ffirstbutton,pagelast,buttons.count);
     end;
     if flayoutok then begin
      size1:= self.size;
      checkautosize;
      if (size1.cx <> bounds_cx) or (size1.cy <> bounds_cy) then begin
       tcustomstepframe1(fframe).neededbuttons:= [];
                  //try again
      end;
     end;
    end;
   until flayoutok or (loopcount > 8);
   invalidate;
  finally
   dec(fupdating);
  end;
 end;
end;

procedure tcustomtoolbar.buttonchanged(sender: ttoolbutton);
var
 int1: integer;
 button1: ttoolbutton;
 bo1: boolean;
begin
 if canevent(tmethod(fonbuttonchanged)) then begin
  fonbuttonchanged(self,sender);
 end;
 with flayout do begin
  for int1:= 0 to buttons.count - 1 do begin
   button1:= buttons[int1];
   if int1 >= length(cells) then begin
    break;
   end;
   if button1 = sender then begin
    with cells[int1] do begin
     bo1:= (ss_invisible in state) xor (as_invisible in button1.finfo.state);
     actionstatestoshapestates(button1.finfo,state);
     imagenr:= buttons[int1].finfo.imagenr;
     colorglyph:= buttons[int1].finfo.colorglyph;
     color:= buttons[int1].finfo.color;
     imagelist:= timagelist(buttons[int1].finfo.imagelist);
     doexecute:= {$ifdef FPC}@{$endif}buttons[int1].doexecute;
     invalidaterect(dim);
     if bo1 then begin
      updatelayout;
     end;
    end;
    break;
   end;
  end;
 end;
end;

procedure tcustomtoolbar.setbuttons(const Value: ttoolbuttons);
begin
 flayout.buttons.assign(Value);
end;
{
procedure ttoolbar.setimagebase(const Value: integer);
begin
 if fimagebase <> value then begin
  fimagebase:= Value;
  invalidate;
 end;
end;

procedure ttoolbar.setimagelist(const Value: timagelist);
begin
 setcomponentvar(value,tmsecomponent(fimagelist));
 invalidate;
end;
}
procedure tcustomtoolbar.setoptions(const Value: toolbaroptionsty);
const
 mask: toolbaroptionsty = [tbo_nohorz,tbo_novert];
var
 valbefore: toolbaroptionsty;
begin
 if foptions <> value then begin
  valbefore:= foptions;
  foptions:= toolbaroptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}byte{$endif}(value),
       {$ifdef FPC}longword{$else}byte{$endif}(foptions),
       {$ifdef FPC}longword{$else}byte{$endif}(mask)));
  if ({$ifdef FPC}longword{$else}byte{$endif}(valbefore) xor 
       {$ifdef FPC}longword{$else}byte{$endif}(foptions)) and 
       {$ifdef FPC}longword{$else}byte{$endif}(mask) <> 0 then begin
   updatelayout;
  end;
 end;
end;

procedure tcustomtoolbar.setfirstbutton(value: integer);
begin
 if value >= flayout.buttons.count - 1 then begin
  value:= flayout.buttons.count - 1;
 end;
 if value < 0 then begin
  value:= 0;
 end;
 if ffirstbutton <> value then begin
  ffirstbutton:= value;
  updatelayout;
 end;
end;

procedure tcustomtoolbar.buttonschanged(const sender: tarrayprop; const index: integer);
begin
 updatelayout;
end;

procedure tcustomtoolbar.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure tcustomtoolbar.dopaint(const canvas: tcanvas);
begin
 inherited;
 drawtoolbuttons(canvas,flayout)
end;

function tcustomtoolbar.gethintpos(index: integer): rectty;
begin
 result:= flayout.cells[index].dim;
 inc(result.cy,12);
end;

procedure tcustomtoolbar.clientmouseevent(var info: mouseeventinfoty);

var
 int1: integer;
begin
 inherited;
 if not (csdesigning in componentstate) or 
                            (ws1_designactive in fwidgetstate1) then begin
  with flayout do begin
   if updatemouseshapestate(cells,info,self) then begin
//    shapeinfotobuttons;
   end;
   if info.eventkind = ek_clientmouseleave then begin
    if fhintedbutton >= 0 then begin
     application.hidehint;
     fhintedbutton:= -1;
    end;
   end;
   if (info.eventkind in [ek_mousemove,ek_mousepark]) then begin
    int1:= getmouseshape(flayout.cells);
    if (int1 >= 0) then begin
     if int1 <> fhintedbutton then begin
      if getshowhint and (info.eventkind = ek_mousepark) or 
                  (application.activehintedwidget = self) then begin
       if not (ss_separator in flayout.cells[int1].state) then begin
        fhintedbutton:= int1;
        if (buttons[int1].hint <> '') and application.active then begin
         application.showhint(self,buttons[int1].hint,gethintpos(int1),cp_bottomleft,
                        -1,[hfl_noautohidemove]);
        end
        else begin
         application.hidehint;
        end;
       end;
      end
      else begin
       application.hidehint;
      end;
     end;
    end
    else begin
     application.hidehint;
     fhintedbutton:= -1;
    end;
   end;
  end;
 end;
end;

procedure tcustomtoolbar.showhint(var info: hintinfoty);
begin
 inherited;
end;

procedure tcustomtoolbar.dostep(const event: stepkindty);
begin
 firstbutton:= frame.executestepevent(event,flayout.stepinfo,ffirstbutton);
end;

procedure tcustomtoolbar.beginupdate;
begin
 inc(fupdating);
end;

procedure tcustomtoolbar.endupdate;
begin
 dec(fupdating);
 updatelayout;
end;
{
procedure tcustomtoolbar.setinvisiblebuttons(const Value: stepkindsty);
begin
 inherited;
 if not (csloading in componentstate) then begin
  updatelayout;
 end;
end;
}
function tcustomtoolbar.buttonatpos(const apos: pointty; const enabledonly: boolean = false): ttoolbutton;
var
 int1: integer;
begin
 begin
  if enabledonly then begin
   int1:= findshapeatpos(flayout.cells,apos,[ss_invisible,ss_disabled]);
  end
  else begin
   int1:= findshapeatpos(flayout.cells,apos,[ss_invisible]);
  end;
  if int1 >= 0 then begin
   result:= flayout.buttons[int1];
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tcustomtoolbar.dragevent(var info: draginfoty);
var
 button1: ttoolbutton;

 function candest: boolean;
 begin
  with info do begin
   if (tbo_dragdest in foptions) and (dragobject^.sender = self) and
     (dragobject^ is tobjectdragobject) then begin
    button1:= buttonatpos(pos,tbo_dragdestenabledonly in foptions);
    result:= (button1 <> nil) and (tobjectdragobject(dragobject).data <> button1);
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
     if (dragobject^ = nil) and (tbo_dragsource in foptions) then begin
      button1:= buttonatpos(pos,tbo_dragsourceenabledonly in foptions);
      if button1 <> nil then begin
       tobjectdragobject.create(self,dragobject^,fdragcontroller.pickpos,button1);
      end;
     end;
    end;
    dek_check: begin
     if candest then begin
      accept:= true;
     end
     else begin
      inherited;
     end;
    end;
    dek_drop: begin
     if candest then begin
      buttons.move(ttoolbutton(tobjectdragobject(dragobject^).data).index,button1.index);
     end
     else begin
      inherited;
     end;
    end;
   end;
  end;
 end;
 fdragcontroller.afterdragevent(info);
end;

procedure tcustomtoolbar.doshortcut(var info: keyeventinfoty; const sender: twidget);
var
 int1: integer;
begin
 for int1:= 0 to flayout.buttons.count - 1 do begin
  if es_processed in info.eventstate then begin
   exit;
  end;
  flayout.buttons[int1].doshortcut(info);
 end;
 inherited;
end;

function tcustomtoolbar.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomtoolbar.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tcustomtoolbar.dostatread(const reader: tstatreader);
begin
 flayout.buttons.dostatread(reader);
end;

procedure tcustomtoolbar.dostatwrite(const writer: tstatwriter);
begin
 flayout.buttons.dostatwrite(writer);
end;

procedure tcustomtoolbar.statreading;
begin
 //dummy
end;

procedure tcustomtoolbar.statread;
begin
 //dummy
end;

procedure tcustomtoolbar.setdragcontroller(const Value: tdragcontroller);
begin
 fdragcontroller.Assign(Value);
end;

{ tdocktoolbar }
{
constructor tdocktoolbar.create(aowner: tcomponent);
begin
 if fdragcontroller = nil then begin
  fdragcontroller:= tdockcontroller.create(idockcontroller(self));
 end;
 inherited;
end;

procedure tdocktoolbar.createframe;
begin
 tgripframe.create(iframe(self));
end;

function tdocktoolbar.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tdocktoolbar.setframe(const avalue: tgripframe);
begin
 inherited setframe(avalue);
end;

function tdocktoolbar.getdrag: tdockcontroller;
begin
 result:= tdockcontroller(fdragcontroller);
end;

procedure tdocktoolbar.setdragcontroller(const avalue: tdockcontroller);
begin
 inherited setdragcontroller(avalue);
end;

function tdocktoolbar.checkdock(var info: draginfoty): boolean;
begin
 result:= true;
end;

function tdocktoolbar.gethandlerect: rectty;
begin
 if fframe = nil then begin
  result:= clientrect;
 end
 else begin
  result:= tgripframe(fframe).handlerect;
 end;
end;

function tdocktoolbar.gethidebuttonrect: rectty;
begin
 if fframe = nil then begin
  result:= nullrect;
 end
 else begin
  result:= tgripframe(fframe).hidebuttonrect;
 end;
end;

function tdocktoolbar.getplacementrect: rectty;
begin
 result:= innerpaintrect;
end;
 }
end.
