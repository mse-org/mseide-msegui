{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseinplaceedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msegui,mseguiglob,msegraphics,msedrawtext,msegraphutils,
 mserichstring,msetimer,mseevent,msetypes,msestrings,mseeditglob,msedatalist,
 msemenus,mseactions,mseact,mseglob;

const
 defaultundomaxcount = 256;
 defaultundobuffermaxsize = 100000;
 defaultcaretwidth = -1; //use globalcaretwith
 defaultglobalcaretwith = -300; //30% of 'o'

type
 editactionty = (ea_none,ea_beforechange,ea_textchanged,ea_textedited,
                 ea_textentered,ea_undo,
                 ea_indexmoved,{ea_selectindexmoved,}ea_delchar,
                 {ea_selectstart,ea_selectend,}ea_clearselection,
                 ea_deleteselection,ea_copyselection,ea_pasteselection,
                 ea_selectall,ea_exit,ea_caretupdating);

 editactionstatety = (eas_shift,eas_delete);
 editactionstatesty = set of editactionstatety;

 editnotificationinfoty = record
  state: editactionstatesty;
  case action: editactionty of
   ea_exit:(
    dir: graphicdirectionty;
   );
   ea_caretupdating:(
    caretrect: rectty;
    showrect: rectty;
   )
 end;

 editnotificationeventty = procedure(const sender: tobject;
          var info: editnotificationinfoty) of object;

 iedit = interface(inullinterface)
  function hasselection: boolean;
  function getoptionsedit: optionseditty;
  procedure editnotification(var info: editnotificationinfoty);
  function getwidget: twidget;
 end;

 inplaceeditstatety = (ies_focused,ies_poschanging,ies_firstclick,ies_istextedit,
                       ies_forcecaret,ies_textrectvalid);
 inplaceeditstatesty = set of inplaceeditstatety;

 tinplaceedit = class
  private
   fowner: twidget;
   fintf: iedit;
   finfo: drawtextinfoty;
   fbackup: msestring;
   foldtext: msestring;
   fselstart: integer;
   fsellength: halfinteger;
   fcurindex: integer;
   curindexbackup,selstartbackup,sellengthbackup: integer;
   fcaretpos: pointty;
   ftextrect: rectty;
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   fmaxlength: integer;
   fpasswordchar: msechar;
   fmousemovepos: pointty;
   frepeater: tsimpletimer;
   procedure resetoffset;
   function getinsertstate: boolean;
   procedure setinsertstate(const Value: boolean);
   procedure setsellength(const Value: halfinteger);
   procedure setselstart(const Value: integer);
   function getforcecaret: boolean;
   procedure setforcecaret(const avalue: boolean);
   procedure internalupdatecaret(force: boolean = false;
                                             nocaret: boolean = false);
   procedure updateselect;
   procedure updatetextflags(active: boolean);
   function internaldeleteselection(textinput: boolean): boolean;
   procedure invalidatetextrect(const left,right: integer);
   function invalidatepos: integer;
   procedure invalidatetext(textinput,trailing: boolean;
                        startpos: integer = -bigint; endpos: integer = bigint);
              //textinput-> notify client, trailing-> from curindex to right
   procedure notify(var info: editnotificationinfoty); overload;
   procedure notify(action: editactionty); overload;
   procedure settextflags(const Value: textflagsty);
   procedure settextflagsactive(const Value: textflagsty);
   procedure setpasswordchar(const Value: msechar);
   procedure setcaretwidth(const Value: integer);
   procedure settext(const Value: msestring);
   procedure setmaxlength(const Value: integer);
   procedure checkmaxlength;
   procedure movemouseindex(const sender: tobject);
   procedure killrepeater;
   procedure setrichtext(const avalue: richstringty);
   procedure setformat(const avalue: formatinfoarty);
   function nofullinvalidateneeded: boolean;
   procedure setfont(const avalue: tfont);
   function gettextrect: rectty;

  protected
   fstate: inplaceeditstatesty;
   fcaretwidth: integer;
   frow: integer;
   function initactioninfo(aaction: editactionty): editnotificationinfoty;
   procedure setcurindex(const Value: integer);
   procedure deletechar; virtual;
   procedure deleteback; virtual;
   procedure internaldelete(start,len,startindex: integer; selected: boolean); virtual;
   function checkaction(const aaction: editactionty): boolean; overload;
   function checkaction(var info: editnotificationinfoty): boolean; overload;
   procedure enterchars(const chars: msestring); virtual;

   procedure onundo(const sender: tobject);
   procedure oncopy(const sender: tobject);
   procedure oncut(const sender: tobject);
   procedure onpaste(const sender: tobject);
  public
   constructor create(aowner: twidget; editintf: iedit; istextedit: boolean = false);
   destructor destroy; override;
   procedure setup(const text: msestring; cursorindex: integer; shift: boolean;
              const atextrect,aclientrect: rectty;
              const format: formatinfoarty = nil;
              const tabulators: tcustomtabulators = nil;
              const font: tfont = nil; noinvalidate: boolean = false);
   procedure updatepos(const atextrect,aclientrect: rectty);
   procedure setscrollvalue(const avalue: real; const horz: boolean);
   property font: tfont read finfo.font write setfont;

   function beforechange: boolean; //true if not aborted
   procedure begingroup; virtual;
   procedure endgroup; virtual;
   procedure scroll(const dist: pointty; const scrollcaret: boolean = true);
   procedure updatecaret;

   procedure dokeydown(var kinfo: keyeventinfoty);
   procedure mouseevent(var minfo: mouseeventinfoty);
   procedure dopopup(var amenu: tpopupmenu; const popupmenu: tpopupmenu; 
                     var mouseinfo: mouseeventinfoty; 
                     const hasselection, cangridcopy: boolean);
   procedure setfirstclick;
   procedure doactivate;
   procedure dodeactivate;
   procedure dofocus;
   procedure dodefocus;
   procedure dopaint(const canvas: tcanvas);
   procedure poschanged;
   procedure dragstarted; //kills repeater

   procedure clear; virtual;
   procedure initfocus;
   procedure moveindex(newindex: integer; shift: boolean = false;
            donotify: boolean = true); virtual;
   procedure inserttext(const text: msestring; nooverwrite: boolean = true);
   function copytoclipboard: boolean;           //true if copied
   function cuttoclipboard: boolean; virtual;   //true if cut
   function pastefromclipboard: boolean; virtual;        //true if pasted
   procedure deleteselection;
   procedure clearundo;
   procedure undo;
   procedure selectall;
   property forcecaret: boolean read getforcecaret write setforcecaret;

   function optionsedit: optionseditty;
   function canedit: boolean;
   function canundo: boolean;
   function cancopy: boolean;
   function canpaste: boolean;
   function getinsertcaretwidth(const canvas: tcanvas; const afont: tfont): integer;
   property insertstate: boolean read getinsertstate write setinsertstate;
   property selstart: integer read fselstart write setselstart;
   property sellength: halfinteger read fsellength write setsellength;
   function selectedtext: msestring;
   property curindex: integer read fcurindex write setcurindex;
   property caretpos: pointty read fcaretpos;
   function lasttextclipped: boolean; //result of last drawing
   function textclipped: boolean;
   function mousepostotextindex(const apos: pointty): integer;

   property textflags: textflagsty read ftextflags write settextflags;
   property textflagsactive: textflagsty read ftextflagsactive write settextflagsactive;
   property passwordchar: msechar read fpasswordchar write setpasswordchar default #0;
   property maxlength: integer read fmaxlength write setmaxlength default -1;
                //<0-> no limit
   property caretwidth: integer read fcaretwidth write setcaretwidth default defaultcaretwidth;
                //<0-> proportional to width of char 'o', -1024 -> 100%
   property text: msestring read finfo.text.text write settext;
   property oldtext: msestring read foldtext write foldtext;
   property richtext: richstringty read finfo.text write setrichtext;
   property format: formatinfoarty read finfo.text.format write setformat;
   property destrect: rectty read finfo.dest;
   property cliprect: rectty read finfo.clip;
   property textrect: rectty read gettextrect;
 end;

 undotypety = (ut_none,ut_setpos,ut_inserttext,ut_overwritetext,
                 ut_deletetext);
 undoflagty = (uf_selected,uf_backwards);
 undoflagsty = set of undoflagty;

 undoinfoty = record
  text: msestring;     //first!
  utype: undotypety;
  selectstartpos,startpos,endpos: gridcoordty;
  flags: undoflagsty;
  textbefore: msestring;
  link: boolean;
 end;

 pundoinfoty = ^undoinfoty;

 iundo = interface(inullinterface)
  procedure setedpos(const Value: gridcoordty; const select: boolean;
                               const donotify: boolean);
  procedure deletetext(const startpos,endpos: gridcoordty);
  procedure inserttext(const pos: gridcoordty; const text: msestring;
                             selected: boolean;
                             insertbackwards: boolean);
  procedure getselectstart(var selectstartpos: gridcoordty);
  procedure setselectstart(const selectstartpos: gridcoordty);
 end;

 undoliststatety = (uls_forcenew);
 undoliststatesty = set of undoliststatety;

 ttextundolist = class(tdynamicdatalist)
  private
   fintf: iundo;
   flock: integer;
   fundopo: integer;
   flinked: integer;
   fmaxsize: integer;
   fbuffersize: integer;
   fstate: undoliststatesty;
   function getitems(const index: integer): pundoinfoty;
   function checkrecord(atype: undotypety; const astartpos,aendpos: gridcoordty;
              selected: boolean; backwards: boolean; alink: boolean;
              textlength: integer): pundoinfoty;
   property items[const index: integer]: pundoinfoty read getitems;
   function getcanundo: boolean;
   function getcanredo: boolean;
   function getlocked: boolean;
  protected
   procedure freedata(var data); override;      //gibt daten frei
   procedure copyinstance(var data); override;  //nach blockcopy aufgerufen
  public
   constructor create(intf: iundo); reintroduce;
   procedure beginlink(linkto: undotypety; forcenew: boolean);
   procedure endlink(forcenew: boolean);
   procedure setpos(const endpos: gridcoordty; selected: boolean;
         link: boolean = false);
   procedure inserttext(const startpos,endpos: gridcoordty;
            const atext: msestring;
            selected: boolean; backwards: boolean; link: boolean = false);
   procedure overwritetext(const startpos,endpos: gridcoordty;
           const atext,atextbefore: msestring; selected: boolean;
           link: boolean = false);
   procedure deletetext(const startpos,endpos: gridcoordty;
       const atext: msestring; selected: boolean;
       backwards: boolean; link: boolean = false);
   procedure undo;
   procedure redo;
   property canundo: boolean read getcanundo;
   property canredo: boolean read getcanredo;
   property maxcount default defaultundomaxcount;
   property maxsize: integer read fmaxsize write fmaxsize default defaultundobuffermaxsize;
   property locked: boolean read getlocked;
 end;

 tundoinplaceedit = class(tinplaceedit)
  private
  protected
   fundolist: ttextundolist;
   procedure deletechar; override;
   procedure deleteback; override;
   procedure internaldelete(start,len,startindex: integer; selected: boolean); override;
   procedure enterchars(const chars: msestring); override;
  public
   constructor create(aowner: twidget; editintf: iedit; undointf: iundo; istextedit: boolean);
   destructor destroy; override;
   procedure begingroup; override;
   procedure endgroup; override;
   procedure moveindex(newindex: integer; shift: boolean = false;
            donotify: boolean = true); override;
   function cuttoclipboard: boolean; override;
   function pastefromclipboard: boolean; override;
   property undolist: ttextundolist read fundolist;
 end;

var
 globalcaretwidth: integer = defaultglobalcaretwith;

function textendpoint(const start: pointty; const text: msestring): pointty;

implementation
uses
 msekeyboard,sysutils,msesysutils,msebits,msewidgets,classes,msestockobjects;
 
var
 overwrite: boolean; //insertstate

function textendpoint(const start: pointty; const text: msestring): pointty;
var
 y: integer;
begin
 y:= countchars(text,c_linefeed);
 result.y:= start.y + y;
 if y = 0 then begin
  result.x:= start.x + length(text);
 end
 else begin
  result.x:= length(lastline(text));
 end;
end;

{ tinplaceedit }

constructor tinplaceedit.create(aowner: twidget; editintf: iedit;
                     istextedit: boolean = false);
begin
 fowner:= aowner;
 fintf:= editintf;
 fcaretwidth:= defaultcaretwidth;
 fmaxlength:= -1;
 if istextedit then begin
  include(fstate,ies_istextedit);
 end;
end;

destructor tinplaceedit.destroy;
begin
 killrepeater;
 inherited;
end;

procedure tinplaceedit.onundo(const sender: tobject);
begin
 undo;
end;

procedure tinplaceedit.oncopy(const sender: tobject);
begin
 copytoclipboard;
end;

procedure tinplaceedit.oncut(const sender: tobject);
begin
 cuttoclipboard;
end;

procedure tinplaceedit.onpaste(const sender: tobject);
begin
 pastefromclipboard;
end;

procedure tinplaceedit.dopopup(var amenu: tpopupmenu; 
                const popupmenu: tpopupmenu; var mouseinfo: mouseeventinfoty;
                const hasselection, cangridcopy: boolean);
var
 states: array[0..3] of actionstatesty;
 sepchar: msechar;
 bo1: boolean;
begin  
 if canundo then begin
  states[0]:= []; //undo
 end
 else begin
  states[0]:= [as_disabled];
 end;
 bo1:= cancopy or hasselection;
 if bo1 or cangridcopy then begin
  states[1]:= []; //copy
  if bo1 and canedit then begin
   states[2]:= [];
  end
  else begin
   states[2]:= [as_disabled]; //cut
  end;
 end
 else begin
  states[1]:= [as_disabled]; //copy
  states[2]:= [as_disabled]; //cut
 end;
 if canpaste then begin
  states[3]:= []; //paste
 end
 else begin
  states[3]:= [as_disabled];
 end;
 if popupmenu <> nil then begin
  sepchar:= popupmenu.shortcutseparator;
 end
 else begin
  sepchar:= tcustommenu.getshortcutseparator(amenu);
 end;
 tpopupmenu.additems(amenu,fintf.getwidget,mouseinfo,
    [stockobjects.captions[sc_Undo]+sepchar+'(Esc)',
     stockobjects.captions[sc_Copy]+sepchar+
             '('+encodeshortcutname(sysshortcuts[sho_copy])+')',
     stockobjects.captions[sc_Cut]+sepchar+
             '('+encodeshortcutname(sysshortcuts[sho_cut])+')',
     stockobjects.captions[sc_Paste]+sepchar+
             '('+encodeshortcutname(sysshortcuts[sho_paste])+')'],
    [],states,[{$ifdef FPC}@{$endif}onundo,{$ifdef FPC}@{$endif}oncopy,
    {$ifdef FPC}@{$endif}oncut,{$ifdef FPC}@{$endif}onpaste]);
end;

procedure tinplaceedit.notify(var info: editnotificationinfoty);
begin
 fintf.editnotification(info);
end;

procedure tinplaceedit.notify(action: editactionty);
var
 info: editnotificationinfoty;
begin
 info:= initactioninfo(action);
 notify(info);
end;

function tinplaceedit.checkaction(var info: editnotificationinfoty): boolean;
var
 aaction: editactionty;
begin
 aaction:= info.action;
 fintf.editnotification(info);
 result:= aaction = info.action;
end;

function tinplaceedit.checkaction(const aaction: editactionty): boolean;
var
 info: editnotificationinfoty;
begin
 info:= initactioninfo(aaction);
 result:= checkaction(info);
end;

function tinplaceedit.beforechange: boolean;
begin
 result:= checkaction(ea_beforechange);
end;

procedure tinplaceedit.killrepeater;
begin
 freeandnil(frepeater);
end;

procedure tinplaceedit.setup(const text: msestring;
              cursorindex: integer; shift: boolean;
              const atextrect, aclientrect: rectty;
              const format: formatinfoarty = nil;
              const tabulators: tcustomtabulators = nil;
              const font: tfont = nil;
              noinvalidate: boolean = false);
begin
 finfo.text.text:= text;
 fcurindex:= cursorindex;
 ftextrect := atextrect;
 finfo.dest:= atextrect;
// fclientrect:= aclientrect;
 finfo.clip:= aclientrect;
 finfo.font:= font;
 resetoffset;
 finfo.text.format:= copy(format);
 finfo.tabulators:= tabulators;
 if not shift then begin
  fselstart:= fcurindex;
  fsellength:= 0;
 end;
 setselected(finfo.text,fselstart,fsellength);
 if fcurindex > length(text) then begin
  fcurindex:= length(text);
 end;
 if not noinvalidate then begin
  invalidatetext(false,false);
 end;
 internalupdatecaret;
end;

procedure tinplaceedit.updatepos(const atextrect,aclientrect: rectty);
begin
 ftextrect := atextrect;
 finfo.dest:= atextrect;
 finfo.clip:= aclientrect;
 invalidatetext(false,false);
 internalupdatecaret;
end;

procedure tinplaceedit.setfont(const avalue: tfont);
begin
 if finfo.font <> avalue then begin
  finfo.font:= avalue;
  invalidatetext(false,false);
  internalupdatecaret;
 end;
end;

procedure tinplaceedit.clear;
begin
 fsellength:= 0;
 fselstart:= 0;
 finfo.text.text:= '';
 finfo.text.format:= nil;
 clearundo;
 invalidatetext(true,false);
end;

function tinplaceedit.initactioninfo(aaction: editactionty): editnotificationinfoty;
begin
 finalize(result);
 fillchar(result,sizeof(result),0);
 result.action:= aaction;
end;

function tinplaceedit.getinsertcaretwidth(const canvas: tcanvas; const afont: tfont): integer;
var
 int1: integer;
begin
 if fcaretwidth = -1 then begin
  int1:= globalcaretwidth;
 end
 else begin
  int1:= fcaretwidth;
 end;
 if int1 < 0 then begin
  result:= (canvas.getfontmetrics('o',afont).sum * -int1 -
                           int1 div 2) div 1024; //round
  if result = 0 then begin
   result:= 1;
  end
 end
 else begin
  result:= int1;
 end;
end;

procedure tinplaceedit.internalupdatecaret(force: boolean = false; 
                       nocaret: boolean = false);
var
 wstr1: msestring;
 metrics: fontmetricsty;
 po1: pointty;
 canvas: tcanvas;
 afont,font1: tfont;
 actioninfo: editnotificationinfoty;
 int1,int2: integer;
 posbefore: pointty;

begin
 if (ws_destroying in fowner.widgetstate) or
                    (csdestroying in fowner.componentstate) then begin
  exit;  //no createwindow by getcanvas
 end;
 posbefore:= finfo.dest.pos;
 
 if not (canedit or (oe_caretonreadonly in iedit(fintf).getoptionsedit)) then begin
  nocaret:= true;
 end;
 actioninfo:= initactioninfo(ea_caretupdating);
 if fowner.active or (ies_forcecaret in fstate) or force then begin
  canvas:= fowner.getcanvas;
  if fpasswordchar <> #0 then begin
   wstr1:= finfo.text.text;
   finfo.text.text:= stringfromchar(fpasswordchar,length(wstr1));
  end;
  fcaretpos:= textindextopos(canvas,finfo,fcurindex); 
             //updates finfo.res

  int1:= finfo.dest.x + finfo.res.cx;
  int2:= ftextrect.x + ftextrect.cx;
  if int1 < int2 then begin //right margin
   int1:= int2 - int1 + finfo.dest.x;
   if int1 > ftextrect.x then begin
    int1:= ftextrect.x;
   end;
   finfo.dest.x:= int1;
  end;
  int1:= finfo.dest.y + finfo.res.cy;
  int2:= ftextrect.y + ftextrect.cy;
  if int1 < int2 then begin //bottom margin
   int1:= int2 - int1 + finfo.dest.y;
   if int1 > ftextrect.y then begin
    int1:= ftextrect.y;
   end;
   finfo.dest.y:= int1;
  end;
  fcaretpos.x:= fcaretpos.x + finfo.dest.x - posbefore.x; 
  fcaretpos.y:= fcaretpos.y + finfo.dest.y - posbefore.y; 
             //add shift

  if fpasswordchar <> #0 then begin
   finfo.text.text:= wstr1;
  end;
  with finfo,actioninfo do begin
   int1:= getinsertcaretwidth(canvas,font);
   if font = nil then begin
    afont:= canvas.font;
   end
   else begin
    afont:= font;
   end;
   if insertstate and not nocaret then begin
    caretrect.cx:= int1;
    showrect.x:= fcaretpos.x;         //for clamp in view
    showrect.cx:= caretrect.cx div 2;
    if showrect.cx = 0 then begin
     showrect.cx:= 1;
    end;
    caretrect.x:= fcaretpos.x - showrect.cx;
    inc(caretrect.x,afont.caretshift);
   end
   else begin
    font1:= tfont.create;
    font1.assign(afont);
    font1.style:= getcharstyle(text.format,fcurindex).fontstyle;
    if fcurindex < length(text.text) then begin
     metrics:= canvas.getfontmetrics(text.text[fcurindex+1],font1);
    end
    else begin
     metrics:= canvas.getfontmetrics('o',font1);
    end;             
    font1.Free;
    caretrect.cx:= metrics.width;
    if caretrect.cx < int1 then begin
     caretrect.cx:= int1;
    end;
    if not nocaret then begin
     caretrect.x:= fcaretpos.x + metrics.leftbearing;
    end
    else begin
     caretrect.x:= fcaretpos.x;
     caretrect.cx:= 0;
    end;
    showrect.x:= caretrect.x;
    showrect.cx:= caretrect.cx;
   end;

   caretrect.y:= fcaretpos.y - afont.ascent;
   caretrect.cy:= afont.ascent + afont.descent;
   showrect.y:= caretrect.y;
   showrect.cy:= caretrect.cy;

   po1:= nullpoint;
   if ies_focused in fstate then begin
    with showrect do begin    //bring caret into clientrect;
     if x < ftextrect.x then begin
      po1.x:= ftextrect.x - x;
     end
     else begin
      if x + cx > ftextrect.x + ftextrect.cx then begin
       po1.x:= ftextrect.x + ftextrect.cx - x -cx;
      end;
     end;
     if y < ftextrect.y then begin
      po1.y:= ftextrect.y - y;
     end
     else begin
      if y + cy > ftextrect.y + ftextrect.cy then begin
       po1.y:= ftextrect.y + ftextrect.cy - y -cy;
      end;
     end;
    end;
    if not isnullpoint(po1) then begin
     addpoint1(fcaretpos,po1);
     addpoint1(dest.pos,po1);
     addpoint1(caretrect.pos,po1);
     addpoint1(showrect.pos,po1);
    end;
   end;
  end;
  if (ies_poschanging in fstate) or checkaction(actioninfo) then begin
   if (fowner.active or (ies_forcecaret in fstate)) and not nocaret then begin
    fowner.getcaret;
    with application.caret do begin
     bounds:= actioninfo.caretrect;
     show;
    end;
   end;
   if nocaret then begin
    if fowner.hascaret then begin
     application.caret.hide;
    end;
   end;
  end;
 end;
 if (finfo.dest.x <> posbefore.x) or (finfo.dest.y <> posbefore.y) then begin
  invalidatetextrect(minint,bigint);
 end;
end;

function tinplaceedit.getforcecaret: boolean;
begin
 result:= ies_forcecaret in fstate;
end;

procedure tinplaceedit.setforcecaret(const avalue: boolean);
begin
 if avalue then begin
  include(fstate,ies_forcecaret);
 end
 else begin
  exclude(fstate,ies_forcecaret);
 end;
 internalupdatecaret(true);
end;

procedure tinplaceedit.invalidatetextrect(const left,right: integer);
var
 rect1: rectty;
begin
 exclude(fstate,ies_textrectvalid);
 rect1.x:= left;
 rect1.cx:= right-left;
// rect1.y:= fclientrect.y;
// rect1.cy:= fclientrect.cy;
 rect1.y:= finfo.clip.y;
 rect1.cy:= finfo.clip.cy;
// if msegraphutils.intersectrect(fclientrect,rect1,rect1) then begin
 if msegraphutils.intersectrect(finfo.clip,rect1,rect1) then begin
  fowner.invalidaterect(rect1,org_client);
 end;
end;

procedure tinplaceedit.updateselect;
begin
 if fselstart + fsellength > length(finfo.text.text) then begin
  fsellength:= length(finfo.text.text) - fselstart;
 end;
 if fsellength < 0 then begin
  fsellength:= 0;
 end;
 setselected(finfo.text,fselstart,fsellength);
 invalidatetextrect(minint,bigint);
end;

procedure tinplaceedit.resetoffset;
begin
 finfo.dest:= ftextrect;
end;

procedure tinplaceedit.updatetextflags(active: boolean);
var
 textflagsbefore: textflagsty;
begin
 textflagsbefore:= finfo.flags;
 if active then begin
  finfo.flags:= ftextflagsactive;
 end
 else begin
  finfo.flags:= ftextflags;
 end;
 if finfo.flags <> textflagsbefore then begin
  invalidatetext(false,false);
 end;
end;

procedure tinplaceedit.invalidatetext(textinput, trailing: boolean;
                     startpos: integer = -bigint; endpos: integer = bigint);
begin
 if trailing then begin
  invalidatetextrect(invalidatepos,endpos);
 end
 else begin
  invalidatetextrect(startpos,endpos);
 end;
 notify(ea_textchanged);
 if textinput then begin
  notify(ea_textedited);
 end;
 if fcurindex > length(finfo.text.text) then begin
  fcurindex:= length(finfo.text.text);
//  moveindex(fcurindex,
//   (fcurindex <= fselstart) and (fcurindex < fselstart + fsellength),false);
 end;
end;

function tinplaceedit.nofullinvalidateneeded: boolean;
begin
 result:= finfo.flags * [tf_wordbreak,tf_xcentered,tf_right] = [];
             
end;

function tinplaceedit.getinsertstate: boolean;
begin
 result:= not overwrite;
end;

procedure tinplaceedit.setinsertstate(const Value: boolean);
begin
 overwrite:= not value;
 internalupdatecaret;
end;

function tinplaceedit.optionsedit: optionseditty;
begin
 result:= fintf.getoptionsedit;
end;

function tinplaceedit.canedit: boolean;
begin
 result:= not (oe_readonly in iedit(fintf).getoptionsedit);
end;

function tinplaceedit.canundo: boolean;
begin
 result:= fbackup <> finfo.text.text;
end;

function tinplaceedit.cancopy: boolean;
begin
 result:= fsellength > 0;
end;

function tinplaceedit.canpaste: boolean;
begin
 result:= canedit and canpastefromclipboard;
end;

function tinplaceedit.textclipped: boolean;
begin
 msedrawtext.textrect(fowner.getcanvas,finfo);
 result:= not rectinrect(finfo.res,fowner.innerclientrect);
end;

function tinplaceedit.lasttextclipped: boolean;
begin
 result:= not rectinrect(finfo.res,finfo.clip);
end;

function tinplaceedit.mousepostotextindex(const apos: pointty): integer;
begin
 postotextindex(fowner.getcanvas,finfo,apos,result);
end;

procedure tinplaceedit.deleteselection;
begin
 if fsellength > 0 then begin
  clearundo;
 end;
 internaldeleteselection(true); //every time called for ttextedit
end;

procedure tinplaceedit.clearundo;
begin
 fbackup:= finfo.text.text;
 foldtext:= fbackup;
 curindexbackup:= fcurindex;
 selstartbackup:= fselstart;
 sellengthbackup:= fsellength;
end;

procedure tinplaceedit.undo;
begin
 if checkaction(ea_undo) then begin
  finfo.text.text:= fbackup;
  fselstart:= selstartbackup;
  fsellength:= sellengthbackup;
  updateselect;
  curindex:= curindexbackup;
  invalidatetext(false,false);
 end;
end;

procedure tinplaceedit.deleteback;
var
 bo1: boolean;
 ch1: msechar;
begin
 if fcurindex > 0 then begin
  ch1:= finfo.text.text[fcurindex];
 end
 else begin
  ch1:= #0;
 end;
 bo1:= nofullinvalidateneeded and (ch1 <> c_return) and (ch1 <> c_linefeed);
 if (fcurindex > 1) and (finfo.text.text[fcurindex-1] = c_return) and 
               (ch1 = c_linefeed) and (fcurindex > 1) then begin
  richdelete(finfo.text,fcurindex-1,2);
  fcurindex:= fcurindex - 2;
 end
 else begin
  richdelete(finfo.text,fcurindex,1);
  fcurindex:= fcurindex - 1;
 end;
 internalupdatecaret(true);
 invalidatetext(true,bo1);
 notify(ea_indexmoved);
end;

procedure tinplaceedit.deletechar;
var
 bo1: boolean;
 ch1: msechar;
begin
 if fcurindex < length(finfo.text.text) then begin
  ch1:= finfo.text.text[fcurindex+1];
 end
 else begin
  ch1:= #0;
 end;
 bo1:= nofullinvalidateneeded and (ch1 <> c_return) and (ch1 <> c_linefeed);
 if (ch1 = c_linefeed) and (fcurindex > 0) and
          (finfo.text.text = c_return) then begin
  richdelete(finfo.text,fcurindex,2);
 end
 else begin
  richdelete(finfo.text,fcurindex+1,1);
 end;
 invalidatetext(true,bo1);
// if not bo1 then begin
  internalupdatecaret;
// end;
end;

procedure tinplaceedit.dokeydown(var kinfo: keyeventinfoty);
var
 nochars: boolean;
 finished: boolean;
 actioninfo: editnotificationinfoty;
 bo1: boolean;
 opt1: optionseditty;

begin
 with kinfo do begin
  if (es_processed in eventstate) then begin
   exit;
  end;
  opt1:= iedit(fintf).getoptionsedit;
  include(eventstate,es_processed);
  nochars:= true;
  finished:= true;
  actioninfo:= initactioninfo(ea_exit);
  if ss_shift in kinfo.shiftstate then begin
   include(actioninfo.state,eas_shift);
  end;
  if issysshortcut(sho_copy,kinfo) then begin
   finished:= copytoclipboard;
  end
  else begin
   if issysshortcut(sho_paste,kinfo) then begin
    if canedit then begin
     finished:= pastefromclipboard;
    end
    else begin
     finished:= false;
    end;
   end
   else begin
    if issysshortcut(sho_cut,kinfo) then begin
     if canedit then begin
      finished:= cuttoclipboard;
     end
     else begin
      finished:= false;
     end;
    end
    else begin
     finished:= false;
    end;
   end;
  end;
  if finished then begin
   exit;
  end;
  if shiftstate <> [ss_ctrl] then begin
   finished:= true;
   bo1:= true;
   if (key = key_return) or (key = key_enter) then  begin
    removechar1(chars,c_return);
    removechar1(chars,c_linefeed);
    if (shiftstate - [ss_shift] = []) and (oe_linebreak in opt1) and 
          ((oe_shiftreturn in opt1) xor (shiftstate = []))then begin
     finished:= false;
     nochars:= false;
     bo1:= false;
     chars:= chars + lineend;
     fowner.invalidate;
    end;
   end;
   if bo1 then begin
    if (shiftstate = []) then begin
     case key of
      key_return,key_enter: begin
       if checkaction(ea_textentered) then begin
        exclude(eventstate,es_processed);
       end;
      end;
      key_escape: begin
       if canundo and (oe_undoonesc in opt1) then begin
        undo;
       end
       else begin
        exclude(eventstate,es_processed);
       end;
      end;
      key_insert: begin
       insertstate:= not insertstate;
      end;
      key_backspace: begin
       include(actioninfo.state,eas_delete);
       actioninfo.dir:= gd_left;
       if canedit then begin
        if fsellength > 0 then begin
         deleteselection;
        end
        else begin
         if fcurindex > 0 then begin
          deleteback;
         end
         else begin
          if checkaction(actioninfo) then begin
           finished:= false;
          end;
         end;
        end;
       end
       else begin
        exclude(eventstate,es_processed);
       end;
      end;
      key_delete: begin
       if canedit then begin
        if fsellength > 0 then begin
         internaldeleteselection(true);
        end
        else begin
         actioninfo.action:= ea_delchar;
         if checkaction(actioninfo) then begin
          if fcurindex < length(finfo.text.text) then begin
           deletechar;
          end
          else begin
           finished:= false;
          end;
         end;
        end;
       end
       else begin
        exclude(eventstate,es_processed);
       end;
      end;
      key_tab: begin
       exclude(eventstate,es_processed);
       if (finfo.tabulators <> nil) then begin
        nochars:= false;
       end;
      end;
      else begin
       finished:= false;
       nochars:= false;
      end;
     end;
    end
    else begin
     if shiftstate = [ss_shift] then begin
      finished:= false;
      nochars:= false;
     end
     else begin
      finished:= false;
     end;
    end;
   end;
   if not finished then begin
    finished:= true;
    if (shiftstate = []) or (shiftstate = [ss_shift]) then begin
     case key of
      key_tab,key_backtab,key_escape,key_backspace,key_delete: begin //nochars
       finished:= false;
       nochars:= true;
      end;
      key_home: begin
       moveindex(0,shiftstate = [ss_shift]);
      end;
      key_end: begin
       moveindex(length(finfo.text.text),shiftstate = [ss_shift]);
      end;
      key_left: begin
       if (fsellength = length(finfo.text.text)) and (shiftstate <> [ss_shift]) or
           (fcurindex = 0) and 
             ((fsellength = 0) or (shiftstate <> [ss_shift]) or
              (ies_istextedit in fstate)
             ) or
           (opt1 * [oe_readonly,oe_caretonreadonly] =
                   [oe_readonly]) then begin
        actioninfo.dir:= gd_left;
        if checkaction(actioninfo) then begin
         if not(oe_exitoncursor in opt1) then begin
          if shiftstate <> [ss_shift] then begin
           sellength:= 0;
          end;
         end
         else begin
          finished:= false;
         end;
        end;
       end
       else begin
        moveindex(fcurindex-1,shiftstate = [ss_shift]);
       end;
      end;
      key_right: begin
       if (fsellength = length(finfo.text.text)) and (shiftstate <> [ss_shift]) or
         (fcurindex = length(finfo.text.text)) and 
           ((shiftstate <> [ss_shift]) or (fsellength = 0) or 
            (ies_istextedit in fstate) or
            (fsellength = length(finfo.text.text)) and (oe_autoselect in opt1) and
               (shiftstate <> [ss_shift])
           ) or
         (opt1 * [oe_readonly,oe_caretonreadonly] =
                  [oe_readonly]) then begin
        actioninfo.dir:= gd_right;
        if checkaction(actioninfo) then begin
         if not(oe_exitoncursor in opt1) then begin
          if shiftstate <> [ss_shift] then begin
           sellength:= 0;
          end;
         end
         else begin
          finished:= false;
         end;
        end;
       end
       else begin
        moveindex(fcurindex+1,shiftstate = [ss_shift]);
       end;
      end
      else begin
       finished:= false;
       nochars:= false;
      end;
     end;
    end
    else begin
     finished:= false;
     if shiftstate = [ss_ctrl,ss_alt] then begin
      nochars:= false;
     end;
    end;
   end;
  end;
  if not finished then begin
   exclude(eventstate,es_processed);
  end;
  if not (es_processed in eventstate) and not nochars and (chars <> '') and 
                 canedit then begin
   enterchars(chars);
   fselstart:= fcurindex;
   include(eventstate,es_processed);
  end;
 end;
end;

procedure tinplaceedit.setfirstclick;
begin
 include(fstate,ies_firstclick);
 resetoffset;
 finfo.flags:= ftextflags;
end;

procedure tinplaceedit.mouseevent(var minfo: mouseeventinfoty);
var
 po1: pointty;
 int1: integer;
begin
 with minfo do begin
  case eventkind of
   ek_buttonpress: begin
    if (minfo.button = mb_left) and pointinrect(pos,finfo.clip) then begin
     if not fowner.focused and fowner.canfocus and
                (ow_mousefocus in fowner.optionswidget) then begin
      include(fstate,ies_firstclick);
      include(minfo.eventstate,es_processed);
      postotextindex(fowner.getcanvas,finfo,pos,int1);
      moveindex(int1,false);
      internalupdatecaret(true);
      po1:= fcaretpos;
      include(eventstate,es_nofocus);
      if not fowner.setfocus then begin
       exclude(fstate,ies_firstclick);
       exit;
      end;
      if oe_autoselectonfirstclick in fintf.getoptionsedit then begin
       selectall;
       subpoint1(po1,textindextopos(fowner.getcanvas,finfo,int1));
      end
      else begin
       moveindex(int1,false);
       subpoint1(po1,fcaretpos);
      end;
     end
     else begin
      postotextindex(fowner.getcanvas,finfo,pos,int1);
      po1:= textindextopos(fowner.getcanvas,finfo,int1);
      if (ies_firstclick in fstate) then begin
       finfo.flags:= ftextflagsactive;
       if (oe_autoselectonfirstclick in fintf.getoptionsedit) then begin
        selectall;
       end
       else begin
        initfocus;
        moveindex(int1,false);
       end;
      end
      else begin
       moveindex(int1,ss_shift in shiftstate);
      end;
      subpoint1(po1,textindextopos(fowner.getcanvas,finfo,int1));
     end;
     subpoint1(pos,po1);
     po1:= subpoint(ftextrect.pos,pos);
     if (po1.x > 0) or (po1.y > 0) then begin //shift cursor in textrect
      if po1.x < 0 then begin
       po1.x:= 0;
      end;
      if po1.y < 0 then begin
       po1.y:= 0;
      end;
      addpoint1(pos,po1);
      if po1.x > ftextrect.x - finfo.dest.pos.x then begin
       po1.x:= ftextrect.x - finfo.dest.pos.x;
      end;
      if po1.y > ftextrect.y - finfo.dest.pos.y then begin
       po1.y:= ftextrect.y - finfo.dest.pos.y;
      end;
      addpoint1(finfo.dest.pos,po1);
      fowner.scrollcaret(po1);
     end;
    end;
//    exclude(fstate,ies_firstclick);
   end;
   ek_buttonrelease,ek_mousecaptureend: begin
    killrepeater;
    exclude(fstate,ies_firstclick);
   end;
   ek_mousemove: begin
    if fowner.clicked and
      not ((ies_firstclick in fstate) and
            (oe_autoselectonfirstclick in fintf.getoptionsedit)) then begin
     fmousemovepos:= minfo.pos;
     if ies_istextedit in fstate then begin
      fmousemovepos.y:= ftextrect.y + ftextrect.cy div 2;
     end;
     if not pointinrect(pos,ftextrect) then begin
      if frepeater = nil then begin
       movemouseindex(nil);
       frepeater:= tsimpletimer.create(100000,{$ifdef FPC}@{$endif}movemouseindex,true);
      end;
     end
     else begin
      killrepeater;
      movemouseindex(nil);
     end;
    end;
   end;
  end;
 end;
end;

procedure tinplaceedit.movemouseindex(const sender: tobject);
var
 int1: integer;
begin
 postotextindex(fowner.getcanvas,finfo,fmousemovepos,int1);
 moveindex(int1,true);
end;

function tinplaceedit.invalidatepos: integer;
begin
 result:= fcaretpos.x - fowner.getcanvas.getfontmetrics('o',finfo.font).width;
end;

procedure tinplaceedit.inserttext(const text: msestring; nooverwrite: boolean = true);
var
 int1,int2,int3: integer;
begin
 if insertstate or nooverwrite then begin
  richinsert(text,finfo.text,fcurindex+1);
 end
 else begin
  replacetext1(finfo.text.text,fcurindex+1,text);
 end;
 checkmaxlength;
 int3:= fowner.getcanvas.getfontmetrics('o',finfo.font).width;
 int1:= fcaretpos.x - int3;
 moveindex(fcurindex + length(text),false);
 if nofullinvalidateneeded then begin
  if (fcurindex = length(finfo.text.text)) then begin
   int2:= fcaretpos.x + int3;
   invalidatetext(true,false,int1,int2);
  end
  else begin
   invalidatetext(true,false,int1);
  end;
 end
 else begin
  invalidatetext(true,false);
 end;
end;

procedure tinplaceedit.moveindex(newindex: integer; shift: boolean; donotify: boolean);
      //cursor verschieben
var
 anchor: integer;
 selstartbefore,sellengthbefore: integer;
 info: editnotificationinfoty;
 int1: integer;

begin
 selstartbefore:= fselstart;
 sellengthbefore:= fsellength;
 if newindex > length(finfo.text.text) then begin
  newindex:= length(finfo.text.text);
 end
 else begin
  if newindex < 0 then begin
   newindex:= 0;
  end;
 end;
 if shift then begin
  if fcurindex = fselstart then begin
   anchor:= fselstart + fsellength;
  end
  else begin
   anchor:= fselstart;
  end;
  if newindex <= anchor then begin
   fselstart:= newindex;
   fsellength:= anchor-newindex;
  end
  else begin
   fselstart:= anchor;
   fsellength:= newindex - anchor;
  end;
 end
 else begin
  fselstart:= newindex;
  fsellength:= 0;
  notify(ea_clearselection);
 end;
 if (ies_istextedit in fstate) or (sellengthbefore <> fsellength) or
             (selstartbefore <> fselstart) and (fsellength <> 0)   then begin
  updateselect;
 end;
 {
 if shift then begin
  doselectstart;
 end;
 }
 int1:= fcurindex;
 curindex:= newindex;
 if (fcurindex > newindex) and (int1 > newindex) then begin
  curindex:= newindex-1; //linebreak
 end;
 if donotify then begin
  internalupdatecaret(true);
  info:= initactioninfo(ea_indexmoved);
  if shift then begin
   include(info.state,eas_shift);
  end;
  notify(info);
 end;
end;

procedure tinplaceedit.setcurindex(const Value: integer);
var
 int1: integer;
begin
// if fcurindex <> value then begin
  int1:= value;
  if int1 > length(finfo.text.text) then begin
   int1:= length(finfo.text.text);
  end
  else begin
   if int1 < 0 then begin
    int1:= 0;
   end;
  end;
  fcurindex := int1;
  internalupdatecaret(ies_forcecaret in fstate);
// end;
end;

procedure tinplaceedit.setsellength(const Value: halfinteger);
begin
 if fsellength <> value then begin
  fsellength := Value;
  updateselect;
 end;
end;

procedure tinplaceedit.setselstart(const Value: integer);
begin
 if fselstart <> value then begin
  fselstart := Value;
  if fsellength > 0 then begin
   updateselect;
  end;
 end;
end;

function tinplaceedit.copytoclipboard: boolean;
begin
 result:= true;
 if checkaction(ea_copyselection) then begin
  if fsellength > 0 then begin
   msewidgets.copytoclipboard(selectedtext);
  end
  else begin
   result:= false;
  end;
 end;
end;

function tinplaceedit.cuttoclipboard: boolean;
begin
 result:= copytoclipboard;
 deleteselection;
end;

function tinplaceedit.pastefromclipboard: boolean;
var
 int1: integer;
 info: editnotificationinfoty;
 wstr1: msestring;
begin
 info:= initactioninfo(ea_pasteselection);
 result:= true;
 if checkaction(info) then begin
  if msewidgets.pastefromclipboard(wstr1) then begin
   deleteselection;
   int1:= fcurindex;
   inserttext(wstr1);
   fselstart:= int1;
   fsellength:= length(wstr1);
   updateselect;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tinplaceedit.internaldeleteselection(textinput: boolean): boolean;
var
 aselstart,asellength: integer;
begin
 beforechange;
 result:= checkaction(ea_deleteselection);
 if result then begin
  if fsellength > 0 then begin
   aselstart:= fselstart;
   asellength:= fsellength;
   if asellength > 0 then begin
    internaldelete(aselstart,asellength,fcurindex,true);
   end;
   moveindex(fselstart,false);
   sellength:= 0;
   invalidatetext(textinput,nofullinvalidateneeded);
  end;
 end;
end;

procedure tinplaceedit.internaldelete(start, len, startindex: integer;
                                                selected: boolean);
                    //selected is for tundoinplaceedit
begin
 richdelete(finfo.text,start+1,len);
end;

procedure tinplaceedit.selectall;
begin
 if checkaction(ea_selectall) then begin
  resetoffset;
  fcurindex:= 0;
  fselstart:= 0;
  fsellength:= length(finfo.text.text);
  updateselect;
  curindex:= fsellength;
 end;
end;

procedure tinplaceedit.doactivate;
begin
 updatetextflags(true);
 internalupdatecaret;
end;

procedure tinplaceedit.dodeactivate;
begin
 updatetextflags(false);
 application.caret.hide;
end;

procedure tinplaceedit.initfocus;
begin
 resetoffset;
 invalidatetextrect(-bigint,bigint);
 if iedit(fintf).getoptionsedit  * [oe_autoselect,oe_locate] = 
                                              [oe_autoselect] then begin
  selectall;
 end
 else begin
  if oe_endonenter in iedit(fintf).getoptionsedit then begin
   moveindex(bigint,false,false);
  end
  else begin
   if oe_homeonenter in iedit(fintf).getoptionsedit then begin
    moveindex(0,false,false);
   end
  end;
 end;
 clearundo;
end;

procedure tinplaceedit.dofocus;
begin
 include(fstate,ies_focused);
 initfocus;
end;

procedure tinplaceedit.dodefocus;
begin
 exclude(fstate,ies_focused);
 updatetextflags(false);
 if oe_resetselectonexit in iedit(fintf).getoptionsedit then begin
  sellength:= 0;
  resetoffset;
 end;
 internalupdatecaret(true,true);
end;

procedure tinplaceedit.settextflags(const Value: textflagsty);
begin
 if ftextflags <> value then begin
  ftextflags := Value;
  updatetextflags(fowner.focused);
 end;
end;

procedure tinplaceedit.settextflagsactive(const Value: textflagsty);
begin
 if ftextflagsactive <> value then begin
  ftextflagsactive := Value;
  updatetextflags(fowner.active);
 end;
end;

procedure tinplaceedit.dopaint(const canvas: tcanvas);
var
 str1: msestring;
begin
 if length(finfo.text.text) > 0 then begin
  if fpasswordchar <> #0 then begin
   str1:= finfo.text.text;
   finfo.text.text:= stringfromchar(fpasswordchar,length(str1));
  end;
  msedrawtext.drawtext(canvas,finfo);
  if fpasswordchar <> #0 then begin
   finfo.text.text:= str1;
  end;
 end;
end;

function tinplaceedit.gettextrect: rectty;
begin
 if not (ies_textrectvalid in fstate) then begin
  msedrawtext.textrect(fowner.getcanvas,finfo);
  include(fstate,ies_textrectvalid);
 end;
 result:= finfo.res;
end;

procedure tinplaceedit.setpasswordchar(const Value: msechar);
begin
 if fpasswordchar <> value then begin
  fpasswordchar:= Value;
  invalidatetext(false,false);
 end;
end;

procedure tinplaceedit.setcaretwidth(const Value: integer);
begin
 if fcaretwidth <> value then begin
  fcaretwidth:= Value;
  internalupdatecaret;
 end;
end;

procedure tinplaceedit.settext(const Value: msestring);
begin
 finfo.text.text:= Value;
 invalidatetext(false,false);
 if ies_focused in fstate then begin
  internalupdatecaret;
 end;
end;

procedure tinplaceedit.setrichtext(const avalue: richstringty);
begin
 beforechange;
 finfo.text := avalue;
 setlength(finfo.text.format,length(finfo.text.format));
 invalidatetext(false,false);
 if ies_focused in fstate then begin
  internalupdatecaret;
 end;
end;

procedure tinplaceedit.setformat(const avalue: formatinfoarty);
begin
 finfo.text.format:= copy(avalue);
 invalidatetext(false,false);
 if ies_focused in fstate then begin
  internalupdatecaret;
 end;
end;

procedure tinplaceedit.checkmaxlength;
begin
 if (fmaxlength >= 0) and (length(finfo.text.text) > fmaxlength) then begin
  setlength(finfo.text.text,fmaxlength);
  if fcurindex > fmaxlength then begin
   curindex:= fmaxlength;
  end;
  invalidatetext(false,false);
 end;
end;

procedure tinplaceedit.setmaxlength(const Value: integer);
begin
 if fmaxlength <> value then begin
  fmaxlength := Value;
  checkmaxlength;
 end;
end;

procedure tinplaceedit.scroll(const dist: pointty;
           const scrollcaret: boolean = true);
begin
 with finfo do begin
  addpoint1(dest.pos,dist);
  addpoint1(clip.pos,dist);
 end;
 addpoint1(ftextrect.pos,dist);
 if scrollcaret then begin
  fowner.scrollcaret(dist);
 end;
end;

procedure tinplaceedit.updatecaret;
begin
 internalupdatecaret;
end;

procedure tinplaceedit.poschanged;
begin
 if fstate * [ies_focused,ies_poschanging] = [ies_focused] then begin
  include(fstate,ies_poschanging);
  try
   internalupdatecaret;
  finally
   exclude(fstate,ies_poschanging);
  end;
 end;
end;

function tinplaceedit.selectedtext: msestring;
begin
 if fsellength > 0 then begin
  result:= copy(finfo.text.text,fselstart+1,fsellength);
 end
 else begin
  result:= '';
 end;
end;

procedure tinplaceedit.enterchars(const chars: msestring);
begin
 begingroup;
 try
  deleteselection;
  inserttext(chars,false);
 finally
  endgroup;
 end;
end;

procedure tinplaceedit.begingroup;
begin
 //dummy
end;

procedure tinplaceedit.endgroup;
begin
 //dummy
end;

procedure tinplaceedit.setscrollvalue(const avalue: real; const horz: boolean);
var
 rect1: rectty;
 int1: integer;
begin
 rect1:= textrect;
 subsize1(rect1.size,ftextrect.size);
 if horz then begin
  if rect1.cx > 0 then begin
   int1:= -(finfo.dest.x + round(rect1.cx*avalue) - ftextrect.x);
   if int1 <> 0 then begin
    inc(finfo.dest.x,int1);
    fowner.scrollrect(makepoint(int1,0),finfo.clip,true);
   end;
  end;   
 end
 else begin
  if rect1.cy > 0 then begin
   int1:= -(finfo.dest.y + round(rect1.cy*avalue) - ftextrect.y);
   if int1 <> 0 then begin
    inc(finfo.dest.y,int1);
    fowner.scrollrect(makepoint(0,int1),finfo.clip,true);
   end;
  end;   
 end;
end;

procedure tinplaceedit.dragstarted;
begin
 killrepeater;
end;

{ ttextundolist }

constructor ttextundolist.create(intf: iundo);
begin
 fintf:= intf;
 fmaxsize:= defaultundobuffermaxsize;
 inherited create;
 fsize:= sizeof(undoinfoty);
 maxcount:= defaultundomaxcount;
end;

procedure ttextundolist.copyinstance(var data);
begin
 inherited;
 with undoinfoty(data) do begin
  reallocstring(text);
  reallocstring(textbefore);
 end;
end;

procedure ttextundolist.freedata(var data);
begin
 inherited;
 with undoinfoty(data) do begin
  dec(fbuffersize,length(text));
  text:= '';
  textbefore:= '';
 end;
end;

function ttextundolist.getitems(const index: integer): pundoinfoty;
begin
 result:= pundoinfoty(getitempo(index));
end;

function ttextundolist.checkrecord(atype: undotypety; const astartpos,aendpos: gridcoordty;
        selected: boolean; backwards: boolean; alink: boolean;
        textlength: integer): pundoinfoty;

 procedure newrecord;
 begin
  count:= fundopo;
  count:= fcount + 1;
  inc(fbuffersize,textlength);
  while (count > 4) and (fbuffersize > fmaxsize) do begin
   deleteitems(0,1);
  end;
  result:= items[fcount-1];
  with result^ do begin
   utype:= atype;
   fintf.getselectstart(selectstartpos);
   startpos:= astartpos;
   endpos:= aendpos;
   updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(uf_selected),selected);
   updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(uf_backwards),backwards);
  end;
  fundopo:= count;
 end;

var
 undocount: integer;
 forcednew: boolean;
begin
 alink:= alink or (flinked > 0);
 forcednew:= (uls_forcenew in fstate);
 if (fcount = 0) then begin
  newrecord;
  undocount:= fundopo-1;
 end
 else begin
  undocount:= fundopo-1;
  if undocount < 0 then begin
   undocount:= 0;
  end
  else begin
   if undocount >= fcount then begin
    undocount:= fcount - 1;
   end;
  end;
  result:= items[undocount];
 end;
 with result^ do begin
  if atype = ut_setpos then begin
   if utype = ut_setpos then begin
    if forcednew or
           ((selected xor (uf_selected in flags)) or (fundopo = 1)) then begin
     newrecord;
    end
    else begin
     endpos:= aendpos;
    end;
   end
   else begin
    if forcednew or
           ((aendpos.row <> endpos.row) or (aendpos.col <> endpos.col)) then begin
     newrecord;
    end;
   end;
  end
  else begin
   if forcednew or
    (utype <> atype) or
    selected and not(uf_selected in flags) or
    backwards and not(uf_backwards in flags) then begin
    newrecord;
   end
   else begin
    endpos:= aendpos;
    count:= undocount+1; //cut history
   end;
  end;
 end;
 result^.link:= alink;
 exclude(fstate,uls_forcenew);
end;

procedure ttextundolist.setpos(const endpos: gridcoordty; selected: boolean;
                        link: boolean = false);
begin
 if flock <> 0 then exit;
 checkrecord(ut_setpos,gridcoordty(nullpoint),endpos,selected,false,link,0);
end;

procedure ttextundolist.inserttext(const startpos,endpos: gridcoordty;
           const atext: msestring; selected: boolean; backwards: boolean;
           link: boolean = false);
begin
 if flock <> 0 then exit;
 with checkrecord(ut_inserttext,startpos,endpos,selected,backwards,link,length(atext))^ do begin
  text:= text + atext;
 end;
end;

procedure ttextundolist.overwritetext(const startpos,endpos: gridcoordty;
             const atext, atextbefore: msestring; selected: boolean;
              link: boolean = false);
begin
 if flock <> 0 then exit;
 with checkrecord(ut_overwritetext,startpos,endpos,selected,false,link,length(atext))^ do begin
  text:= text + atext;
  textbefore:= textbefore + atextbefore;
 end;
end;

procedure ttextundolist.deletetext(const startpos,endpos: gridcoordty;
        const atext: msestring; selected: boolean; backwards: boolean;
        link: boolean = false);
begin
 if flock <> 0 then exit;
 with checkrecord(ut_deletetext,startpos,endpos,selected,backwards,link,length(atext))^ do begin
  if backwards then begin
   text:= atext + text;
  end
  else begin
   text:= text + atext;
  end;
 end;
end;

procedure ttextundolist.undo;
var
 linked: boolean;
begin
 if fundopo < 1 then begin
  exit;
 end;
 inc(flock);
 linked:= true; //compiler warning
 try
  repeat
   if fundopo < 1 then begin
    break;
   end;
   dec(fundopo);
   with items[fundopo]^ do begin
    case utype of
     ut_setpos: begin
      if fundopo > 0 then begin
       with items[fundopo-1]^ do begin
        if uf_selected in flags then begin
         fintf.setselectstart(selectstartpos);
        end;
        fintf.setedpos(endpos,uf_selected in flags,false);
       end;
      end;
     end;
     ut_inserttext: begin
      fintf.deletetext(startpos,endpos);
     end;
     ut_overwritetext: begin
      fintf.deletetext(startpos,endpos);
      fintf.inserttext(startpos,textbefore,uf_selected in flags,false);
     end;
     ut_deletetext: begin
      fintf.inserttext(endpos,text,uf_selected in flags, not(uf_backwards in flags));
     end;
    end;
    if utype <> ut_setpos then begin
     fintf.setedpos(startpos,uf_selected in flags,false);
    end;
    linked:= (fundopo > 0) and items[fundopo-1]^.link;
   end;
  until not linked;
 finally
  dec(flock);
 end;
end;

procedure ttextundolist.redo;
var
 linked: boolean;
begin
 if fundopo >= fcount then begin
  exit;
 end
 else begin
  inc(flock);
  try
   repeat
    with items[fundopo]^ do begin
     case utype of
      ut_setpos: begin
       fintf.setedpos(endpos,uf_selected in flags,false);
      end;
      ut_inserttext: begin
       fintf.inserttext(startpos,text,uf_selected in flags,false);
      end;
      ut_overwritetext: begin
       fintf.deletetext(startpos,endpos);
       fintf.inserttext(startpos,text,uf_selected in flags,false);
      end;
      ut_deletetext: begin
       fintf.deletetext(endpos,gridcoordty(textendpoint(pointty(endpos),text)));
      end;
     end;
     if utype <> ut_setpos then begin
      fintf.setedpos(endpos,uf_selected in flags,false);
     end;
     inc(fundopo);
     linked:= (fundopo < fcount) and items[fundopo-1]^.link;
    end;
   until not linked;
  finally
   dec(flock);
  end;
 end;
end;

function ttextundolist.getcanundo: boolean;
begin
 result:= (fundopo > 2);
end;

function ttextundolist.getcanredo: boolean;
begin
 result:= fundopo < fcount;
end;

procedure ttextundolist.beginlink(linkto: undotypety; forcenew: boolean);
var
 po1: pundoinfoty;
begin
 if flock = 0 then begin
  if (flinked = 0) then begin
   if forcenew then begin
    include(fstate,uls_forcenew);
   end;
   if (fundopo > 0) then begin
    po1:= items[fundopo-1];
    if (po1^.utype = linkto) then begin
     po1^.link:= true;
    end;
   end;
  end;
  inc(flinked);
 end;
end;

procedure ttextundolist.endlink(forcenew: boolean);
begin
 if flock = 0 then begin
  dec(flinked);
  if flinked = 0 then begin
   if forcenew then begin
    include(fstate,uls_forcenew);
   end;
   if fundopo > 0 then begin
    items[fundopo-1]^.link:= false;
   end;
  end;
 end;
end;

function ttextundolist.getlocked: boolean;
begin
 result:= flock <> 0;
end;

{ tundoinplaceedit }

constructor tundoinplaceedit.create(aowner: twidget; editintf: iedit; undointf: iundo; istextedit: boolean);
begin
 inherited create(aowner,editintf,istextedit);
 fundolist:= ttextundolist.create(undointf);
end;

destructor tundoinplaceedit.destroy;
begin
 fundolist.Free;
 inherited;
end;

procedure tundoinplaceedit.enterchars(const chars: msestring);
begin
 if insertstate then begin
  fundolist.beginlink(ut_inserttext,false);
  try
   deleteselection;
   fundolist.inserttext(makegridcoord(fcurindex,frow),
           makegridcoord(fcurindex+length(chars),frow),chars,false,false);
   inherited;
  finally
   fundolist.endlink(false);
  end;
 end
 else begin
  fundolist.beginlink(ut_overwritetext,false);
  try
   deleteselection;
   fundolist.overwritetext(makegridcoord(fcurindex,frow),makegridcoord(fcurindex+length(chars),frow),
                       chars,copy(finfo.text.text,fcurindex+1,length(chars)),false);
   inherited;
  finally
   fundolist.endlink(false);
  end;
 end;
end;

procedure tundoinplaceedit.internaldelete(start, len, startindex: integer; selected: boolean);
begin
 fundolist.deletetext(makegridcoord(startindex,frow),makegridcoord(start,frow),
                        copy(finfo.text.text,start+1,len),selected,false);
 inherited;
end;

procedure tundoinplaceedit.deleteback;
begin
 fundolist.deletetext(makegridcoord(fcurindex,frow),makegridcoord(fcurindex-1,frow),
                       finfo.text.text[fcurindex],false,true);
 inherited;
end;

procedure tundoinplaceedit.deletechar;
begin
 fundolist.deletetext(makegridcoord(fcurindex,frow),makegridcoord(fcurindex,frow),
                       finfo.text.text[fcurindex+1],false,false);
 inherited;
end;

procedure tundoinplaceedit.moveindex(newindex: integer; shift: boolean = false;
            donotify: boolean = true);
begin
 inherited;
 fundolist.setpos(makegridcoord(fcurindex,frow),shift);
end;

function tundoinplaceedit.cuttoclipboard: boolean;
begin
 fundolist.beginlink(ut_none,true);
 try
  result:= inherited cuttoclipboard;
 finally
  fundolist.endlink(true);
 end;
end;

function tundoinplaceedit.pastefromclipboard: boolean;
begin
 fundolist.beginlink(ut_none,true);
 try
  result:= inherited pastefromclipboard;
 finally
  fundolist.endlink(true);
 end;
end;

procedure tundoinplaceedit.begingroup;
begin
 fundolist.beginlink(ut_none,true);
end;

procedure tundoinplaceedit.endgroup;
begin
 fundolist.endlink(true);
end;

end.
