{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseinplaceedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 msegui,mseguiglob,msegraphics,msedrawtext,msegraphutils,
 mserichstring,msetimer,mseevent,msetypes,msestrings,mseeditglob,msedatalist,
 msemenus,mseactions,mseact,mseglob,msegridsglob,mseassistiveclient,
 mseificompglob{$ifdef mse_with_ifi},mseifiglob{$endif};

const
 defaultundomaxcount = 256;
 defaultundobuffermaxsize = 100000;
 defaultcaretwidth = -1; //use globalcaretwith
 defaultglobalcaretwith = -300; //30% of 'o'

type
 editnotificationeventty = procedure(const sender: tobject;
          var info: editnotificationinfoty) of object;

 iedit = interface(inullinterface)
  function hasselection: boolean;
  function getoptionsedit: optionseditty;
  procedure editnotification(var info: editnotificationinfoty);
  function getwidget: twidget;
  procedure updatecopytoclipboard(var atext: msestring);
  procedure updatepastefromclipboard(var atext: msestring);
  function locatecount: integer;        //number of locate values
  function locatecurrentindex: integer; //index of current row
  procedure locatesetcurrentindex(const aindex: integer);
  function getkeystring(const aindex: integer): msestring; //locate text
  function getedited: boolean;
 end;

 inplaceeditstatety = (ies_focused,ies_emptytext,
                       ies_poschanging,ies_firstclick,ies_istextedit,
                       ies_forcecaret,ies_textrectvalid,ies_touched,
                       ies_edited,
                       ies_cangroupundo,ies_caretposvalid);
 inplaceeditstatesty = set of inplaceeditstatety;

 tinplaceedit = class(tobject,iassistiveclientedit)
  private
   fwidget: twidget;
   fintf: iedit;
   finfo: drawtextinfoty;
   ftextrectbefore: rectty;
   ffont: tfont;
   ffontstyle: fontstylesty;
   ffontcolor: colorty;
   ffontcolorbackground: colorty;
   foldtext: msestring;
   fselstart: integer;
   fsellength: halfinteger;
   fcurindex: integer;
   curindexbackup,selstartbackup,sellengthbackup: integer;
   fupdatecaretcount: integer;
   fmoveindexcount: integer;
   fcaretpos: pointty;
   ftextrect: rectty;
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   fmaxlength: integer;
   fpasswordchar: msechar;
   fmousemovepos: pointty;
   fscrollsum: pointty; //for getcaretpos
   frepeater: tsimpletimer;
   ffiltertext: msestring;
   foptionsedit1: optionsedit1ty;
   procedure resetoffset;
   function getinsertstate: boolean;
   procedure setinsertstate(const Value: boolean);
   procedure setsellength(const avalue: halfinteger);
   procedure setselstart(const avalue: integer);
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
   procedure checktextrect;
   function gettextrect: rectty;

   procedure setfiltertext(const avalue: msestring);
   function getcaretpos: pointty;
  protected
   fupdating: integer;
   fstate: inplaceeditstatesty;
   fcaretwidth: integer;
   frow: integer;
   fbackup: msestring;
   function caretonreadonly(): boolean;
   function initactioninfo(aaction: editactionty): editnotificationinfoty;
   function updateindex(const avalue: int32): int32;
   procedure checkindexvalues;
   procedure setcurindex(const avalue: integer);
   procedure moveindex1(newindex: integer; shift: boolean = false;
                                   donotify: boolean = true);
   procedure deletechar; virtual;
   procedure deleteback; virtual;
   procedure internaldelete(start,len,startindex: integer;
                                           selected: boolean); virtual;
   function checkaction(const aaction: editactionty): boolean; overload;
   function checkaction(var info: editnotificationinfoty): boolean; overload;
   procedure enterchars(const chars: msestring); virtual;
   function locating: boolean;

   procedure onundo(const sender: tobject);
   procedure onredo(const sender: tobject);
   procedure oncopy(const sender: tobject);
   procedure oncut(const sender: tobject);
   procedure onpaste(const sender: tobject);
   procedure onselectall(const sender: tobject);
   procedure redo; virtual;
   function canredo: boolean; virtual;
   function pastefromclipboard(
               const buffer: clipboardbufferty): boolean; virtual;
                                                      //true if pasted
   function copytoclipboard(const buffer: clipboardbufferty): boolean;           //true if copied
   function cuttoclipboard(const buffer: clipboardbufferty): boolean; virtual;   //true if cut
   function getiassistiveclient(): iassistiveclientedit virtual;
    //iassistiveclient
   function getassistiveparent(): iassistiveclient;
   function getinstance: tobject;
   function getassistivewidget(): tobject;
   function getassistivename(): msestring;
   function getassistivecaption(): msestring;
   function getassistivetext(): msestring;
   function getassistivecaretindex(): int32; //-1 -> none
   function getassistivehint(): msestring;
   function getassistiveflags(): assistiveflagsty;
  {$ifdef mse_with_ifi}
   function getifidatalinkintf(): iifidatalink; //can be nil
  {$endif}
  public
   constructor create(aowner: twidget; editintf: iedit;
                                         istextedit: boolean = false);
   destructor destroy; override;
   procedure setup(const text: msestring; cursorindex: integer; shift: boolean;
              const atextrect,aclientrect: rectty;
              const format: formatinfoarty = nil;
              const tabulators: tcustomtabulators = nil;
              const font: tfont = nil; noinvalidate: boolean = false);
   procedure updatepos(const atextrect,aclientrect: rectty);
   procedure movepos(const adist: pointty); //shifts textrects
   procedure setscrollvalue(const avalue: real; const horz: boolean);
   property font: tfont read ffont write setfont;
   property fontstyle: fontstylesty read ffontstyle write ffontstyle default [];
   property fontcolor: colorty read ffontcolor write ffontcolor default cl_none;
   property fontcolorbackground: colorty read ffontcolor write
                                     ffontcolorbackground default cl_none;

   property widget: twidget read fwidget;
   function getfontcanvas: tcanvas;

   function beforechange: boolean; //true if not aborted
   procedure begingroup; virtual;
   procedure endgroup; virtual;
   procedure scroll(const dist: pointty; const scrollcaret: boolean = true);
   procedure beginupdate; //no caret update by index change
   procedure endupdate;
   function updating: boolean;

   procedure updatecaret;

   procedure dokeydown(var kinfo: keyeventinfoty);
   procedure mouseevent(var minfo: mouseeventinfoty);
   procedure updatepopupmenu(var amenu: tpopupmenu; const popupmenu: tpopupmenu;
                     var mouseinfo: mouseeventinfoty;
                     const hasselection: boolean);
   procedure setfirstclick(var ainfo: mouseeventinfoty);
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
   function cuttoclipboard: boolean;            //true if cut
   function pastefromclipboard: boolean;        //true if pasted
   procedure deleteselection;
   procedure clearundo;
   procedure undo; virtual;
   procedure selectall;
   procedure clearselection;
   property forcecaret: boolean read getforcecaret write setforcecaret;

   function optionsedit: optionseditty;
   function canedit: boolean;
   function canundo: boolean; virtual;
   function cancopy: boolean;
   function canpaste: boolean;
   function getinsertcaretwidth(const canvas: tcanvas;
                                              const afont: tfont): integer;
   property insertstate: boolean read getinsertstate write setinsertstate;
   property selstart: integer read fselstart write setselstart;
   property sellength: halfinteger read fsellength write setsellength;
   function selectedtext: msestring;
   function hasselection: boolean;
   property curindex: integer read fcurindex write setcurindex;
   property caretpos: pointty read getcaretpos;
   function lasttextclipped: boolean; //result of last drawing
   function lasttextclipped(const acliprect: rectty): boolean;
   function textclipped: boolean;
   function mousepostotextindex(const apos: pointty): integer;
   function textindextomousepos(const aindex: integer): pointty;

   property optionsedit1: optionsedit1ty read foptionsedit1
                        write foptionsedit1 default defaultoptionsedit1;
   property textflags: textflagsty read ftextflags write settextflags;
   property textflagsactive: textflagsty read ftextflagsactive
                                                 write settextflagsactive;
   property passwordchar: msechar read fpasswordchar
                                         write setpasswordchar default #0;
   property maxlength: integer read fmaxlength write setmaxlength default -1;
                //<0-> no limit
   property caretwidth: integer read fcaretwidth write setcaretwidth
                                                   default defaultcaretwidth;
                //<0-> proportional to width of char 'o', -1024 -> 100%
   property text: msestring read finfo.text.text write settext;
   property oldtext: msestring read foldtext write foldtext;
   property richtext: richstringty read finfo.text write setrichtext;
   property format: formatinfoarty read finfo.text.format write setformat;
   property destrect: rectty read finfo.dest;
   property cliprect: rectty read finfo.clip;
   property textrect: rectty read gettextrect;
   property filtertext: msestring read ffiltertext write setfiltertext;
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
                     const donotify: boolean; const ashowcell: cellpositionty);
  procedure deletetext(const startpos,endpos: gridcoordty);
  procedure inserttext(const pos: gridcoordty; const text: msestring;
                             selected: boolean;
                             insertbackwards: boolean);
  procedure getselectstart(var selectstartpos: gridcoordty);
  procedure setselectstart(const selectstartpos: gridcoordty);
 end;

 ttextundolist = class(tdynamicdatalist)
  private
   fintf: iundo;
   flock: integer;
   fundopo: integer;
   flinked: integer;
   fmaxsize: integer;
   fbuffersize: integer;
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
   procedure beforecopy(var data); override;
  public
   constructor create(intf: iundo); reintroduce;
   procedure clear; override;
   procedure beginlink(linkto: undotypety; forcenew: boolean);
   procedure endlink(forcenew: boolean);
   procedure setpos(const endpos: gridcoordty; selected: boolean;
         alink: boolean = false);
   procedure inserttext(const startpos,endpos: gridcoordty;
            const atext: msestring;
            selected: boolean; backwards: boolean; alink: boolean = false);
   procedure overwritetext(const startpos,endpos: gridcoordty;
           const atext,atextbefore: msestring; selected: boolean;
           alink: boolean = false);
   procedure deletetext(const startpos,endpos: gridcoordty;
       const atext: msestring; selected: boolean;
       backwards: boolean; alink: boolean = false);
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
   function pastefromclipboard(
                     const buffer: clipboardbufferty): boolean; override;
   function cuttoclipboard(const buffer: clipboardbufferty): boolean; override;
  public
   constructor create(aowner: twidget; editintf: iedit; undointf: iundo;
                      istextedit: boolean);
   destructor destroy; override;
   procedure begingroup; override;
   procedure endgroup; override;
   function canundo: boolean; override;
   function canredo: boolean; override;
   procedure undo; override;
   procedure redo; override;
   procedure moveindex(newindex: integer; shift: boolean = false;
            donotify: boolean = true); override;

   property undolist: ttextundolist read fundolist;
 end;

var
 globalcaretwidth: integer = defaultglobalcaretwith;

function textendpoint(const start: pointty; const text: msestring): pointty;

implementation
uses
 msekeyboard,sysutils,msesysutils,msebits,msewidgets,classes,
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 mseassistiveserver;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 twidget1 = class(twidget);

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
 fwidget:= aowner;
 fintf:= editintf;
 fcaretwidth:= defaultcaretwidth;
 fmaxlength:= -1;
 ffontcolor:= cl_none;
 ffontcolorbackground:= cl_none;
 foptionsedit1:= defaultoptionsedit1;
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

procedure tinplaceedit.onredo(const sender: tobject);
begin
 redo;
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

procedure tinplaceedit.onselectall(const sender: tobject);
begin
 selectall();
end;

procedure tinplaceedit.updatepopupmenu(var amenu: tpopupmenu;
                const popupmenu: tpopupmenu; var mouseinfo: mouseeventinfoty;
                const hasselection{, cangridcopy}: boolean);
var
 states: array of actionstatesty;
 sepchar: msechar;
 bo1: boolean;
 undoindex,redoindex,copyindex,cutindex,pasteindex: integer;
begin
 if ies_cangroupundo in fstate then begin
  setlength(states,5);
  undoindex:= 0;
  redoindex:= 1;
  copyindex:= 2;
  cutindex:= 3;
  pasteindex:= 4;
  if canredo then begin
   states[redoindex]:= [];
  end
  else begin
   states[redoindex]:= [as_disabled];
  end;
 end
 else begin
  setlength(states,4);
  undoindex:= 0;
  redoindex:= 0; //invalid
  copyindex:= 1;
  cutindex:= 2;
  pasteindex:= 3;
 end;
 if canundo then begin
  states[undoindex]:= []; //undo
 end
 else begin
  states[undoindex]:= [as_disabled];
 end;
 bo1:= (cancopy or hasselection) and (passwordchar = #0);
 if bo1 {or cangridcopy} then begin
  states[copyindex]:= []; //copy
  if bo1 and canedit then begin
   states[cutindex]:= [];
  end
  else begin
   states[cutindex]:= [as_disabled]; //cut
  end;
 end
 else begin
  states[copyindex]:= [as_disabled]; //copy
  states[cutindex]:= [as_disabled]; //cut
 end;
 if canpaste then begin
  states[pasteindex]:= []; //paste
 end
 else begin
  states[pasteindex]:= [as_disabled];
 end;
 if popupmenu <> nil then begin
  sepchar:= popupmenu.shortcutseparator;
 end
 else begin
  sepchar:= tcustommenu.getshortcutseparator(amenu);
 end;
 if ies_cangroupundo in fstate then begin
  tpopupmenu.additems(amenu,fintf.getwidget,mouseinfo,
{$ifdef mse_dynpo}
   [lang_stockcaption[ord(sc_Undohk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_groupundo])+')',
      lang_stockcaption[ord(sc_Redohk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_groupredo])+')',
      lang_stockcaption[ord(sc_Copyhk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_copy])+')',
      lang_stockcaption[ord(sc_Cuthk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_cut])+')',
      lang_stockcaption[ord(sc_Pastehk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_paste])+')',
      lang_stockcaption[ord(sc_Select_allhk)]+sepchar+
{$else}
   [sc(sc_Undohk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_groupundo])+')',
      sc(sc_Redohk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_groupredo])+')',
      sc(sc_Copyhk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_copy])+')',
      sc(sc_Cuthk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_cut])+')',
      sc(sc_Pastehk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_paste])+')',
      sc(sc_Select_allhk)+sepchar+
{$endif}
              '('+encodeshortcutname(sysshortcuts[sho_selectall])+')'],
     [[mao_nocandefocus],[mao_nocandefocus],[mao_nocandefocus],
              [mao_nocandefocus],[mao_nocandefocus]],
               states,[@onundo,@onredo,@oncopy,@oncut,@onpaste,@onselectall]);
 end
 else begin
  tpopupmenu.additems(amenu,fintf.getwidget,mouseinfo,
{$ifdef mse_dynpo}
     [lang_stockcaption[ord(sc_Undohk)]+sepchar+'(Esc)',
      lang_stockcaption[ord(sc_Copyhk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_copy])+')',
      lang_stockcaption[ord(sc_Cuthk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_cut])+')',
      lang_stockcaption[ord(sc_Pastehk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_paste])+')',
      lang_stockcaption[ord(sc_Select_allhk)]+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_selectall])+')'],
{$else}
     [sc(sc_Undohk)+sepchar+'(Esc)',
      sc(sc_Copyhk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_copy])+')',
      sc(sc_Cuthk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_cut])+')',
      sc(sc_Pastehk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_paste])+')',
      sc(sc_Select_allhk)+sepchar+
              '('+encodeshortcutname(sysshortcuts[sho_selectall])+')'],
{$endif}


     [[mao_nocandefocus],[mao_nocandefocus],[mao_nocandefocus],
      [mao_nocandefocus],[mao_nocandefocus]],
               states,[@onundo,@oncopy,@oncut,@onpaste,@onselectall]);
 end;
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

function tinplaceedit.locating: boolean;
begin
 result:= iedit(fintf).getoptionsedit * [oe_locate,oe_readonly] =
                                           [oe_locate,oe_readonly];
end;

procedure tinplaceedit.setup(const text: msestring;
              cursorindex: integer; shift: boolean;
              const atextrect, aclientrect: rectty;
              const format: formatinfoarty = nil;
              const tabulators: tcustomtabulators = nil;
              const font: tfont = nil;
              noinvalidate: boolean = false);
begin
// exclude(fstate,ies_emptytext);
 finfo.text.text:= text;
 ffiltertext:= '';
 if locating then begin
  fcurindex:= 0;
 end
 else begin
  fcurindex:= cursorindex;
 end;
 ftextrect := atextrect;
 finfo.dest:= atextrect;
 finfo.clip:= aclientrect;
 if atextrect.cx < 0 then begin
  ftextrect.cx:= 0;
  finfo.dest.cx:= 0;
 end;
 if atextrect.cy < 0 then begin
  ftextrect.cy:= 0;
  finfo.dest.cy:= 0;
 end;
 if aclientrect.cx < 0 then begin
  finfo.clip.cx:= 0;
 end;
 ffont:= font;
 resetoffset;
 finfo.text.format:= copy(format);
 finfo.tabulators:= tabulators;
 if not shift then begin
  fselstart:= updateindex(fcurindex);
  fsellength:= 0;
 end;
 setselected1(finfo.text,fselstart,fsellength);
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

procedure tinplaceedit.movepos(const adist: pointty);
begin
 addpoint1(ftextrect.pos,adist);
 addpoint1(finfo.dest.pos,adist);
 addpoint1(finfo.clip.pos,adist);
 invalidatetext(false,false);
 internalupdatecaret;
end;

procedure tinplaceedit.setfont(const avalue: tfont);
begin
 if ffont <> avalue then begin
  ffont:= avalue;
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
  result:= (canvas.getfontmetrics('o',afont).sum * - int1 -
                           int1 div 2) div 1024; //round
  if result = 0 then begin
   result:= 1;
  end
 end
 else begin
  result:= int1;
 end;
end;

function tinplaceedit.caretonreadonly(): boolean;
begin
 result:= (oe_caretonreadonly in fintf.getoptionsedit) or fwidget.canassistive;
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
 posbefore: rectty;
 updatecaretcountref: integer;
// options1: optionseditty;
 haspasswordchar: boolean;

begin
 if (fupdating > 0) or (ws_destroying in fwidget.widgetstate) or
                    (csdestroying in fwidget.componentstate) then begin
  exit;  //no createwindow by getcanvas
 end;
 wstr1:= ''; //compiler warning
 inc(fupdatecaretcount);
 updatecaretcountref:= fupdatecaretcount;
 posbefore:= finfo.dest;
// options1:= fintf.getoptionsedit;
 if not (canedit or caretonreadonly()) then begin
  nocaret:= true;
 end;
 actioninfo:= initactioninfo(ea_caretupdating);
 if fwidget.active or (ies_forcecaret in fstate) or force then begin
  canvas:= getfontcanvas;
  haspasswordchar:= (fpasswordchar <> #0) and not (ies_emptytext in fstate);
  if haspasswordchar then begin
   wstr1:= finfo.text.text;
   finfo.text.text:= stringfromchar(fpasswordchar,length(wstr1));
  end;
//  fcaretpos:= textindextopos(canvas,finfo,fcurindex);
  fcaretpos:= textindextomousepos(fcurindex);
             //updates finfo.res
  include(fstate,ies_caretposvalid);
  fscrollsum:= nullpoint;
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

  if haspasswordchar then begin
   finfo.text.text:= wstr1;
  end;
  with finfo,actioninfo do begin
   int1:= getinsertcaretwidth(canvas,ffont);
   afont:= canvas.font;
   if insertstate and not nocaret then begin
    caretrect.cx:= int1;
    showrect.x:= fcaretpos.x;         //for clamp in view
    showrect.cx:= caretrect.cx div 2;
    if showrect.cx = 0 then begin
     showrect.cx:= 1;
    end;
    caretrect.x:= fcaretpos.x - showrect.cx;
    inc(caretrect.x,afont.caretshift);
    if showrect.x > caretrect.x then begin
     showrect.x:= caretrect.x;
    end;
    int1:= caretrect.x+caretrect.cx-(showrect.x+showrect.cx);
    if int1 > 0 then begin
     showrect.cx:= showrect.cx+int1;
    end;
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
     if not (tf_clipi in flags) then begin
      addpoint1(dest.pos,po1);
      int1:= dest.x - ftextrect.x;
      if int1 > 0 then begin //use cliprect space
       int2:= ftextrect.x - clip.x;
       if int1 > int2 then begin
        int1:= int2;
       end;
       po1.x:= po1.x - int1;
       dest.x:= dest.x - int1;
      end;
     end
     else begin
      if tf_right in flags then begin
       dest.cx:= dest.cx + po1.x;
      end
      else begin
       if tf_xcentered in flags then begin
        dest.x:= dest.x + po1.x;
        int1:= dest.x - ftextrect.x;
        int2:= ftextrect.y+ftextrect.cx - (dest.x+dest.cx);
        if int2 > int1 then begin //adjust to textrect
         int1:= int2;
        end;
        dest.x:= dest.x - int1;
        dest.cx:= dest.cx + 2*int1;
       end
       else begin
        dest.x:= dest.x + po1.x;
        dest.cx:= dest.cx - po1.x;
       end;
      end;
      if tf_bottom in flags then begin
       dest.cy:= dest.cy + po1.y;
      end
      else begin
       if tf_ycentered in flags then begin
        dest.y:= dest.y + po1.y;
        int1:= dest.y - ftextrect.y;
        int2:= ftextrect.y+ftextrect.cy - (dest.y+dest.cy);
        if int2 > int1 then begin //adjust to textrect
         int1:= int2;
        end;
        dest.y:= dest.y - int1;
        dest.cy:= dest.cy + 2*int1;
       end
       else begin
        dest.y:= dest.y + po1.y;
        dest.cy:= dest.cy - po1.y;
       end;
      end;
     end;
     addpoint1(fcaretpos,po1);
     addpoint1(caretrect.pos,po1);
     addpoint1(showrect.pos,po1);
    end;
   end;
  end;
  if (ies_poschanging in fstate) or checkaction(actioninfo) then begin
   if updatecaretcountref <> fupdatecaretcount then begin
    exit;
   end;
   if (fwidget.activefocused or (ies_forcecaret in fstate)) and
                                                         not nocaret then begin
    fwidget.getcaret;
    with application.caret do begin
     bounds:= actioninfo.caretrect;
     show;
    end;
   end;
   if nocaret then begin
    if fwidget.hascaret then begin
     application.caret.hide;
    end;
   end;
  end;
 end;
 if (finfo.dest.x <> posbefore.x) or (finfo.dest.y <> posbefore.y) or
                 (finfo.dest.cx <> posbefore.cx) or
                                 (finfo.dest.cy <> posbefore.cy) then begin
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
 rect1.y:= finfo.clip.y;
 rect1.cy:= finfo.clip.cy;
 if msegraphutils.intersectrect(finfo.clip,rect1,rect1) then begin
  fwidget.invalidaterect(rect1,org_client);
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
 setselected1(finfo.text,fselstart,fsellength);
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
  resetoffset;
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
var
 m1: editinputmodety;
begin
 overwrite:= not value;
 internalupdatecaret;
 if twidget1(fwidget).canassistive() then begin
  m1:= eim_insert;
  if overwrite then begin
   m1:= eim_overwrite;
  end;
  assistiveserver.doeditinputmodeset(getiassistiveclient(),m1);
 end;
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
 result:= (ies_edited in fstate) or not (ies_emptytext in fstate) and
                               (fbackup <> finfo.text.text) or fintf.getedited;
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
// msedrawtext.textrect(getfontcanvas,finfo);
// result:= not rectinrect(finfo.res,fowner.innerclientrect);
 result:= not rectinrect(gettextrect,fwidget.innerclientrect);
end;

function tinplaceedit.lasttextclipped: boolean;
begin
 result:= not rectinrect(finfo.res,finfo.clip);
end;

function tinplaceedit.lasttextclipped(const acliprect: rectty): boolean;
begin
 result:= not rectinrect(finfo.res,intersectrect(finfo.clip,acliprect));
end;

function tinplaceedit.mousepostotextindex(const apos: pointty): integer;
var
 mstr1: msestring;
begin
 if (fpasswordchar <> #0) and not (ies_emptytext in fstate) then begin
  mstr1:= finfo.text.text;
  finfo.text.text:= stringfromchar(fpasswordchar,length(mstr1));
  postotextindex(getfontcanvas,finfo,apos,result);
  finfo.text.text:= mstr1;
 end
 else begin
  if ies_emptytext in fstate then begin
   result:= 0;
  end
  else begin
   postotextindex(getfontcanvas,finfo,apos,result);
  end;
 end;
end;

function tinplaceedit.textindextomousepos(const aindex: integer): pointty;
var
 mstr1: msestring;
begin
 ftextrectbefore:= finfo.res;
 if (fpasswordchar <> #0) and not (ies_emptytext in fstate) then begin
  mstr1:= finfo.text.text;
  finfo.text.text:= stringfromchar(fpasswordchar,length(mstr1));
  result:= textindextopos(getfontcanvas,finfo,aindex);
  finfo.text.text:= mstr1;
 end
 else begin
  if ies_emptytext in fstate then begin
   result:= textindextopos(getfontcanvas,finfo,0);
  end
  else begin
   result:= textindextopos(getfontcanvas,finfo,aindex);
  end;
 end;
 checktextrect;
end;

procedure tinplaceedit.deleteselection;
var
 s1: msestring;
begin
 if twidget1(fwidget).canassistive() then begin
  s1:= selectedtext();
 end;
 if fsellength > 0 then begin
  clearundo;
 end;
 internaldeleteselection(true); //every time called for ttextedit
 if (s1 <> '') and twidget1(fwidget).canassistive() then begin
  assistiveserver.doedittextblock(getiassistiveclient(),etbm_delete,s1);
 end;
end;

procedure tinplaceedit.clearundo;
begin
 if ies_emptytext in fstate then begin
  fbackup:= '';
 end
 else begin
  fbackup:= finfo.text.text;
 end;
 exclude(fstate,ies_edited);
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
  fstate:= fstate - [ies_touched,ies_edited];
  notify(ea_undone);
  if twidget1(fwidget).canassistive() then begin
   assistiveserver.doeditwithdrawn(getiassistiveclient);
  end;
 end;
end;

procedure tinplaceedit.deleteback;
var
 bo1: boolean;
 ch1: msechar;
 s1: msestring;
begin
 if ies_emptytext in fstate then begin
  exit;
 end;
 if fcurindex > 0 then begin
  ch1:= finfo.text.text[fcurindex];
 end
 else begin
  ch1:= #0;
 end;
 bo1:= nofullinvalidateneeded and (ch1 <> c_return) and (ch1 <> c_linefeed);
 if (fcurindex > 1) and
                ((card16(ch1) and $fc00 = $dc00) or
                 (finfo.text.text[fcurindex-1] = c_return) and
                              (ch1 = c_linefeed)) then begin
  s1:= copy(finfo.text.text,fcurindex-1,2);
  richdelete(finfo.text,fcurindex-1,2);
  fcurindex:= fcurindex - 2;
 end
 else begin
  s1:= copy(finfo.text.text,fcurindex,1);
  richdelete(finfo.text,fcurindex,1);
  fcurindex:= fcurindex - 1;
 end;
 fstate:= fstate + [ies_touched,ies_edited];
 internalupdatecaret(true);
 if twidget1(fwidget).canassistive() then begin
  assistiveserver.doeditchardelete(getiassistiveclient(),s1);
 end;
 invalidatetext(true,bo1);
 notify(ea_indexmoved);
end;

procedure tinplaceedit.deletechar;
var
 bo1: boolean;
 ch1: msechar;
 s1: msestring;
begin
 if ies_emptytext in fstate then begin
  exit;
 end;
 if fcurindex < length(finfo.text.text) then begin
  ch1:= finfo.text.text[fcurindex+1];
 end
 else begin
  ch1:= #0;
 end;
 bo1:= nofullinvalidateneeded and (ch1 <> c_return) and (ch1 <> c_linefeed);
 if (card16(ch1) and $fc00 = $d800) or
          (ch1 = c_linefeed) and (fcurindex > 0) and
                                     (finfo.text.text = c_return) then begin
  s1:= copy(finfo.text.text,fcurindex+1,2);
  richdelete(finfo.text,fcurindex+1,2);
 end
 else begin
  s1:= copy(finfo.text.text,fcurindex+1,1);
  richdelete(finfo.text,fcurindex+1,1);
 end;
 fstate:= fstate + [ies_touched,ies_edited];
 invalidatetext(true,bo1);
 if twidget1(fwidget).canassistive() then begin
  assistiveserver.doeditchardelete(getiassistiveclient(),s1);
 end;
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
 locating1: boolean;
 shiftstate1,shiftstate2: shiftstatesty;
 int1: integer;
 ismultilinectrl: boolean;
 s1: msestring;

begin
 with kinfo do begin
  shiftstate1:= shiftstate * keyshiftstatesmask;
  if (es_processed in eventstate) then begin
   exit;
  end;
  opt1:= iedit(fintf).getoptionsedit;
  locating1:= opt1 * [oe_locate,oe_readonly] = [oe_locate,oe_readonly];
  include(eventstate,es_processed);
  actioninfo:= initactioninfo(ea_exit);
  if ss_shift in shiftstate1 then begin
   include(actioninfo.state,eas_shift);
  end;
  nochars:= true;
  finished:= true;
  if not(oe1_noselectall in foptionsedit1) and
                               issysshortcut(sho_selectall,kinfo) then begin
   selectall;
  end
  else begin
   if issysshortcut(sho_copy,kinfo) then begin
    if (passwordchar = #0) and hasselection then begin
     finished:= copytoclipboard(cbb_clipboard);;
    end
    else begin
     finished:= false;
    end;
   end
   else begin
    if issysshortcut(sho_paste,kinfo) then begin
     if canedit then begin
      finished:= pastefromclipboard(cbb_clipboard);
     end
     else begin
      finished:= false;
     end;
    end
    else begin
     if issysshortcut(sho_cut,kinfo) then begin
      if canedit and (passwordchar = #0) and hasselection then begin
       finished:= cuttoclipboard(cbb_clipboard);
      end
      else begin
       finished:= false;
      end;
     end
     else begin
      finished:= false;
      if ies_cangroupundo in fstate then begin
       if issysshortcut(sho_groupundo,kinfo) then begin
        if canundo then begin
         undo;
         finished:= true;
        end;
       end
       else begin
        if issysshortcut(sho_groupredo,kinfo) then begin
         if canredo then begin
          redo;
          finished:= true;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  if finished then begin
   exit;
  end;
  ismultilinectrl:= (oe1_multiline in foptionsedit1) and
                                    ((key = key_end) or (key = key_home));
  if (shiftstate1 <> [ss_ctrl]) or ismultilinectrl then begin
   finished:= true;
   bo1:= true;
   if (key = key_return) {or (key = key_enter)} then  begin
    removechar1(chars,c_return);
    removechar1(chars,c_linefeed);
    if (shiftstate1 - [ss_shift] = []) and (oe_linebreak in opt1) and
          ((oe_shiftreturn in opt1) xor (shiftstate1 = []))then begin
     finished:= false;
     nochars:= false;
     bo1:= false;
     chars:= chars + lineend;
     fwidget.invalidate;
    end;
   end;
   if bo1 then begin
    if (shiftstate1 = []) then begin
     case key of
      key_return{,key_enter}: begin
       if checkaction(ea_textentered) then begin
        exclude(eventstate,es_processed);
       end;
      end;
      key_escape: begin
       if canundo and (oe_undoonesc in opt1) and
                        not (ies_cangroupundo in fstate) then begin
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
       if locating1 then begin
        filtertext:= copy(filtertext,1,length(filtertext)-1);
       end
       else begin
        include(actioninfo.state,eas_delete);
        actioninfo.dir:= gd_left;
        if canedit then begin
         if fsellength > 0 then begin
          deleteselection;
         end
         else begin
          if fcurindex > 0 then begin
           actioninfo.action:= ea_delchar;
           if checkaction(actioninfo) then begin
            deleteback;
           end;
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
      end;
      key_delete: begin
       if canedit then begin
        if fsellength > 0 then begin
         s1:= selectedtext();
         internaldeleteselection(true);
         if twidget1(fwidget).canassistive() then begin
          assistiveserver.doedittextblock(getiassistiveclient(),
                                                       etbm_delete,s1);
         end;
        end
        else begin
         actioninfo.action:= ea_delchar;
         actioninfo.dir:= gd_none;
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
     if shiftstate1 = [ss_shift] then begin
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
    shiftstate2:= shiftstate1;
    if ismultilinectrl then begin
     exclude(shiftstate2,ss_ctrl);
    end;
    if (shiftstate2 = []) or (shiftstate2 = [ss_shift]) then begin
     case key of
      key_tab,key_backtab,key_escape,key_backspace,key_delete: begin //nochars
       finished:= false;
       nochars:= true;
      end;
      key_home: begin
       if locating1 and (shiftstate2 = []) then begin
        filtertext:= '';
       end
       else begin
        if not (oe1_multiline in foptionsedit1) or
                                 (ss_ctrl in shiftstate1) then begin
         moveindex1(0,ss_shift in shiftstate1);
        end
        else begin
         int1:= mousepostotextindex(mp(-bigint,fcaretpos.y));
         moveindex1(int1,ss_shift in shiftstate1);
        end;
       end;
      end;
      key_end: begin
       if locating1 and (shiftstate2 = []) then begin
        filtertext:= finfo.text.text;
       end
       else begin
        if not (oe1_multiline in foptionsedit1) or
                                 (ss_ctrl in shiftstate1) then begin
         moveindex1(length(finfo.text.text),ss_shift in shiftstate1);
        end
        else begin
         int1:= mousepostotextindex(mp(bigint,fcaretpos.y));
         moveindex1(int1,ss_shift in shiftstate1);
        end;
       end;
      end;
      key_left: begin
       if not(oe_nofirstarrownavig in opt1) and (shiftstate1 <> [ss_shift]) and
             ((fsellength = length(finfo.text.text)) or
              not(ies_touched in fstate) and
              (fcurindex = length(finfo.text.text))
             ) or
          (fcurindex = 0) and
             ((fsellength = 0) or (shiftstate1 <> [ss_shift]) or
              (ies_istextedit in fstate)
             ) or
          (oe_readonly in opt1) and not caretonreadonly()then begin
        actioninfo.dir:= gd_left;
        if checkaction(actioninfo) then begin
         if not(oe_exitoncursor in opt1) then begin
          if shiftstate1 <> [ss_shift] then begin
           sellength:= 0;
          end;
         end
         else begin
          finished:= false;
         end;
        end;
       end
       else begin
        moveindex1(fcurindex-1,shiftstate1 = [ss_shift]);
       end;
      end;
      key_right: begin
       if not(oe_nofirstarrownavig in opt1) and (shiftstate1 <> [ss_shift]) and
              ((fsellength = length(finfo.text.text)) or
               not(ies_touched in fstate) and
               (fcurindex = 0)
              ) or
         (fcurindex = length(finfo.text.text)) and
           ((shiftstate1 <> [ss_shift]) or (fsellength = 0) or
            (ies_istextedit in fstate) or
            (fsellength = length(finfo.text.text)) and
                     (oe_autoselect in opt1) and (shiftstate1 <> [ss_shift])
           ) or
         (oe_readonly in opt1) and not caretonreadonly() then begin
        actioninfo.dir:= gd_right;
        if checkaction(actioninfo) then begin
         if not(oe_exitoncursor in opt1) or
             ((fsellength = length(finfo.text.text)) and (fsellength <> 0)) and
             (shiftstate1 <> [ss_shift]) and
             (oe_nofirstarrownavig in opt1) then begin
          if shiftstate1 <> [ss_shift] then begin
           sellength:= 0;
          end;
         end
         else begin
          finished:= false;
         end;
        end;
       end
       else begin
        moveindex1(fcurindex+1,shiftstate1 = [ss_shift]);
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
     if (shiftstate1 = [ss_ctrl,ss_alt]) and
                              not (ss_second in shiftstate) then begin
      nochars:= false;
     end;
    end;
   end;
  end;
  if not finished then begin
   exclude(eventstate,es_processed);
  end;
  if not (es_processed in eventstate) and not nochars and (chars <> '') then begin
   if locating1 then begin
    filtertext:= filtertext + chars;
    include(eventstate,es_processed);
   end
   else begin
    if canedit then begin
     enterchars(chars);
     fselstart:= updateindex(fcurindex);
     include(eventstate,es_processed);
    end;
   end;
  end;
 end;
end;

procedure tinplaceedit.setfirstclick(var ainfo: mouseeventinfoty);
begin
 include(fstate,ies_firstclick);
 resetoffset;
 finfo.flags:= ftextflags;    //restore flags before activate
end;

procedure tinplaceedit.mouseevent(var minfo: mouseeventinfoty);
var
 po1: pointty;
 int1: integer;
 opt1: optionseditty;
 autoselect1: boolean;
begin
 with minfo do begin
  if es_drag in eventstate then begin
   killrepeater;
  end
  else begin
   opt1:= fintf.getoptionsedit;
   autoselect1:= (oe_autoselectonfirstclick in opt1) and
               (opt1 * [oe_locate,oe_readonly] <> [oe_locate,oe_readonly]);
   case eventkind of
    ek_buttonpress: begin
     if pointinrect(pos,finfo.clip) and
      (minfo.button = mb_left) or (minfo.button = mb_middle) and
                                    not (oe_readonly in opt1) then begin
      if not ((minfo.button = mb_middle) and
                (minfo.shiftstate * shiftstatesmask <> [ss_middle])) then begin
       if not fwidget.focused and fwidget.canfocus and
                  (ow_mousefocus in fwidget.optionswidget) then begin
        if minfo.button = mb_left then begin
         include(fstate,ies_firstclick);
        end;
        include(minfo.eventstate,es_processed);
        int1:= mousepostotextindex(pos);
        moveindex(int1,false);
        internalupdatecaret(true);
        po1:= fcaretpos;
        include(eventstate,es_nofocus);
        if not fwidget.setfocus then begin
         exclude(fstate,ies_firstclick);
         exit;
        end;
        if autoselect1 and (minfo.button = mb_left) then begin
         selectall;
         subpoint1(po1,textindextomousepos(int1));
        end
        else begin
         moveindex(int1,false);
         subpoint1(po1,fcaretpos);
        end;
       end
       else begin
        int1:= mousepostotextindex(pos);
        po1:= textindextomousepos(int1);
        if (ies_firstclick in fstate) then begin
         finfo.flags:= ftextflagsactive;
         if autoselect1 and (minfo.button = mb_left) then begin
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
        subpoint1(po1,textindextomousepos(int1));
       end;
       if (minfo.button = mb_middle) and
               not (oe_readonly in fintf.getoptionsedit) then begin
                         //cold be changed by moveindex
        addpoint1(po1,textindextomousepos(int1));
        clearselection;
        pastefromclipboard(cbb_primary);
        subpoint1(po1,textindextomousepos(int1));
       end;
       subpoint1(pos,po1);
       if pos.x < ftextrect.x then begin
        pos.x:= ftextrect.x;
       end;
       if pos.x > ftextrect.x + ftextrect.cx then begin
        pos.x:= ftextrect.x + ftextrect.cx;
       end;
       if pos.y < ftextrect.y then begin
        pos.y:= ftextrect.y;
       end;
       if pos.y > ftextrect.y + ftextrect.cy then begin
        pos.y:= ftextrect.y + ftextrect.cy;
       end;
      end;
     end;
    end;
    ek_buttonrelease,ek_mousecaptureend: begin
     killrepeater;
     exclude(fstate,ies_firstclick);
    end;
    ek_mousemove: begin
     if fwidget.clicked and
       not ((ies_firstclick in fstate) and autoselect1) then begin
      fmousemovepos:= minfo.pos;
      if not pointinrect(pos,ftextrect) then begin
       if frepeater = nil then begin
        movemouseindex(nil);
        frepeater:= tsimpletimer.create(100000,
                     {$ifdef FPC}@{$endif}movemouseindex,true,[]);
       end;
      end
      else begin
       killrepeater;
       movemouseindex(nil);
      end;
     end;
    end;
    else;
   end;
  end;
 end;
end;

procedure tinplaceedit.movemouseindex(const sender: tobject);
begin
 moveindex(mousepostotextindex(fmousemovepos),true);
 if passwordchar = #0 then begin
  copytoclipboard(cbb_primary);
 end;
// msewidgets.copytoclipboard(selectedtext,cbb_primary);
end;

function tinplaceedit.invalidatepos: integer;
begin
 result:= fcaretpos.x - getfontcanvas.getfontmetrics('o').width;
end;

procedure tinplaceedit.inserttext(const text: msestring;
                                       nooverwrite: boolean = true);
var
 int1,int2,int3: integer;
begin
 if ies_emptytext in fstate then begin
  finfo.text.text:= '';
 end;
 if insertstate or nooverwrite then begin
  richinsert(text,finfo.text,fcurindex+1);
 end
 else begin
  replacetext1(finfo.text.text,fcurindex+1,text);
 end;
 checkmaxlength;
 if ies_emptytext in fstate then begin
  notify(ea_resetemptytext); //remove empty_text settings
 end;
 int3:= getfontcanvas.getfontmetrics('o').width;
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
 {
 if twidget1(fwidget).canassistive() then begin
  assistiveserver.doedittextblock(getiassistiveclient(),etbm_insert,text);
 end;
 }
end;

procedure tinplaceedit.moveindex(newindex: integer; shift: boolean;
                                                         donotify: boolean);
      //cursor verschieben
var
 anchor: integer;
 selstartbefore,sellengthbefore: integer;
 info: editnotificationinfoty;
 int1: integer;
 moveindexcountref: integer;

begin
 if (newindex <> 0) and (ies_emptytext in fstate) then begin
  exit;
 end;
 include(fstate,ies_touched);
 inc(fmoveindexcount);
 moveindexcountref:= fmoveindexcount;
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
 if finfo.text.text <> '' then begin
  if (newindex < fcurindex) and
           (card16(finfo.text.text[newindex]) and $fc00 = $d800) then begin
   dec(newindex); //surrogate pair
  end
  else begin
   if (newindex > fcurindex) and
           (card16(finfo.text.text[newindex]) and $fc00 = $d800) then begin
    inc(newindex); //surrogate pair
   end;
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
  if moveindexcountref <> fmoveindexcount then begin
   exit;
  end;
 end;
 if (ies_istextedit in fstate) or (sellengthbefore <> fsellength) or
             (selstartbefore <> fselstart) and (fsellength <> 0)   then begin
  updateselect;
 end;
 int1:= fcurindex;
 curindex:= newindex;
 if moveindexcountref <> fmoveindexcount then begin
  exit;
 end;
 if (fcurindex > newindex) and (int1 > newindex) then begin
  curindex:= newindex-1; //linebreak
 end;
 if donotify then begin
  internalupdatecaret(true);
  if moveindexcountref <> fmoveindexcount then begin
   exit;
  end;
  info:= initactioninfo(ea_indexmoved);
  if shift then begin
   include(info.state,eas_shift);
  end;
  notify(info);
  {
  if twidget1(fwidget).canassistive() then begin
   assistiveserver.doeditindexmoved(getiassistiveclient(),fcurindex);
  end;
  }
 end;
end;

procedure tinplaceedit.moveindex1(newindex: integer; shift: boolean = false;
               donotify: boolean = true);
begin
 moveindex(newindex,shift,donotify);
 if twidget1(fwidget).canassistive() then begin
  assistiveserver.doeditindexmoved(getiassistiveclient(),fcurindex);
 end;
end;

function tinplaceedit.updateindex(const avalue: int32): int32;
begin
 result:= avalue;
 if result > length(finfo.text.text) then begin
  result:= length(finfo.text.text);
 end
 else begin
  if result < 0 then begin
   result:= 0;
  end;
 end;
 if (finfo.text.text <> '') and
             (card16(finfo.text.text[result]) and $fc00 = $d800) then begin
  inc(result); //surrogate pair
 end;
end;

procedure tinplaceedit.setcurindex(const avalue: integer);
begin
 include(fstate,ies_touched);
 fcurindex:= updateindex(avalue);
 exclude(fstate,ies_caretposvalid);
 internalupdatecaret(ies_forcecaret in fstate);
end;

procedure tinplaceedit.setsellength(const avalue: halfinteger);
begin
 if fsellength <> avalue then begin
  fsellength:= updateindex(fselstart+avalue) - fselstart;
  updateselect;
 end;
end;

procedure tinplaceedit.setselstart(const avalue: integer);
begin
 if fselstart <> avalue then begin
  fselstart:= updateindex(avalue);
  if fsellength > 0 then begin
   updateselect;
  end;
 end;
end;

function tinplaceedit.copytoclipboard(const buffer: clipboardbufferty): boolean;
var
 mstr1: msestring;
 info: editnotificationinfoty;
begin
 info:= initactioninfo(ea_copyselection);
 info.bufferkind:= buffer;
 result:= true;
 if checkaction(info) then begin
  if fsellength > 0 then begin
   mstr1:= selectedtext;
   fintf.updatecopytoclipboard(mstr1);
   msewidgets.copytoclipboard(mstr1,info.bufferkind);
   if twidget1(fwidget).canassistive() then begin
    assistiveserver.doedittextblock(getiassistiveclient(),etbm_copy,
                                                            selectedtext);
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tinplaceedit.copytoclipboard: boolean;
begin
 result:= copytoclipboard(cbb_clipboard);
end;

function tinplaceedit.cuttoclipboard(const buffer: clipboardbufferty): boolean;
var
 s1: msestring;
begin
 s1:= selectedtext;
 result:= copytoclipboard(buffer);
 deleteselection;
 if twidget1(fwidget).canassistive() then begin
  assistiveserver.doedittextblock(getiassistiveclient(),etbm_cut,
                                                          s1);
 end;
end;

function tinplaceedit.getiassistiveclient(): iassistiveclientedit;
begin
 result:= iassistiveclientedit(self);
end;

function tinplaceedit.getassistiveparent(): iassistiveclient;
begin
 result:= twidget1(fwidget).getassistiveparent();
end;

function tinplaceedit.getinstance: tobject;
begin
 result:= twidget1(fwidget).getinstance();
end;

function tinplaceedit.getassistivewidget(): tobject;
begin
 result:= twidget1(fwidget).getassistivewidget();
end;

function tinplaceedit.getassistivename(): msestring;
begin
 result:= twidget1(fwidget).getassistivename();
end;

function tinplaceedit.getassistivecaption(): msestring;
begin
 result:= twidget1(fwidget).getassistivecaption();
end;

function tinplaceedit.getassistivetext(): msestring;
begin
 result:= twidget1(fwidget).getassistivetext();
end;

function tinplaceedit.getassistivecaretindex(): int32;
begin
 result:= twidget1(fwidget).getassistivecaretindex();
end;

function tinplaceedit.getassistivehint(): msestring;
begin
 result:= twidget1(fwidget).getassistivehint();
end;

function tinplaceedit.getassistiveflags(): assistiveflagsty;
begin
 result:= twidget1(fwidget).getassistiveflags();
 include(result,asf_inplaceedit);
end;

function tinplaceedit.getifidatalinkintf(): iifidatalink;
begin
 result:= twidget1(fwidget).getifidatalinkintf();
end;

function tinplaceedit.cuttoclipboard: boolean;
begin
 result:= cuttoclipboard(cbb_clipboard);
end;

function tinplaceedit.pastefromclipboard(
                     const buffer: clipboardbufferty): boolean;
var
 int1: integer;
 info: editnotificationinfoty;
 wstr1: msestring;
begin
 info:= initactioninfo(ea_pasteselection);
 info.bufferkind:= buffer;
 result:= true;
 if checkaction(info) then begin
  if msewidgets.pastefromclipboard(wstr1,info.bufferkind) then begin
   fintf.updatepastefromclipboard(wstr1);
   deleteselection;
   int1:= fcurindex;
   inserttext(wstr1);
   fselstart:= int1;
   fsellength:= length(wstr1);
   updateselect;
   if twidget1(fwidget).canassistive() then begin
    assistiveserver.doedittextblock(getiassistiveclient(),etbm_paste,wstr1);
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tinplaceedit.pastefromclipboard: boolean;
begin
 result:= pastefromclipboard(cbb_clipboard);
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
   include(fstate,ies_edited);
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
 if ies_emptytext in fstate then begin
  exit;
 end;
 if checkaction(ea_selectall) then begin
  resetoffset;
  fcurindex:= 0;
  fselstart:= 0;
  fsellength:= length(finfo.text.text);
  updateselect;
  if oe_homeonenter in optionsedit then begin
   curindex:= 0;
  end
  else begin
   curindex:= fsellength;
  end;
 end;
end;

procedure tinplaceedit.clearselection;
begin
 fstate:= fstate + [ies_touched,ies_edited];
 if fsellength > 0 then begin
  fsellength:= 0;
  updateselect;
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
var
 opt1: optionseditty;
begin
 ffiltertext:= '';
 resetoffset;
 invalidatetextrect(-bigint,bigint);
 opt1:= iedit(fintf).getoptionsedit;
 if opt1 * [oe_locate,oe_readonly] = [oe_locate,oe_readonly] then begin
  curindex:= 0;
  fselstart:= 0;
  fsellength:= 0;
  updateselect;
 end
 else begin
  if ies_emptytext in fstate then begin
   moveindex(0,false,false);
  end
  else begin
   if (oe_autoselect in opt1) then begin
    selectall;
   end
   else begin
    if oe_endonenter in opt1 then begin
     moveindex(bigint,false,false);
    end
    else begin
     if oe_homeonenter in opt1 then begin
      moveindex(0,false,false);
     end
    end;
   end;
  end;
 end;
 clearundo();
 exclude(fstate,ies_touched);
 updatecaret();
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
  ftextflags := Value+[tf_clipo];
  updatetextflags(fwidget.focused);
 end;
end;

procedure tinplaceedit.settextflagsactive(const Value: textflagsty);
begin
 if ftextflagsactive <> value then begin
  ftextflagsactive:= Value+[tf_clipo];
  updatetextflags(fwidget.active);
 end;
end;

procedure tinplaceedit.dopaint(const canvas: tcanvas);
var
 str1: msestring;
 co1,co2: rgbtriplety;
 haspasswordchar: boolean;
begin
 str1:= '';
 ftextrectbefore:= finfo.res;
 if length(finfo.text.text) > 0 then begin
  canvas.save();
  haspasswordchar:= (fpasswordchar <> #0) and not (ies_emptytext in fstate);
  if haspasswordchar then begin
   str1:= finfo.text.text;
   finfo.text.text:= stringfromchar(fpasswordchar,length(str1));
  end;
  if ffont <> nil then begin
   canvas.font:= ffont;
  end;
  if ffontstyle <> [] then begin
   canvas.font.style:= ffontstyle;
  end;
  if ffontcolor <> cl_none then begin
   canvas.font.color:= ffontcolor;
  end;
  if ffontcolorbackground <> cl_none then begin
   canvas.font.colorbackground:= ffontcolorbackground;
  end;
  with defaulteditfontcolors do begin
   if canvas.font.color = cl_default then begin
    canvas.font.color:= text;
   end;
   if canvas.font.colorbackground = cl_default then begin
    canvas.font.colorbackground:= textbackground;
   end;
   co1:= colortorgb(cl_selectedtext);
   co2:= colortorgb(cl_selectedtextbackground);
   setcolormapvalue(cl_selectedtext,selectedtext);
   setcolormapvalue(cl_selectedtextbackground,selectedtextbackground);
  end;
  msedrawtext.drawtext(canvas,finfo);
  setcolormapvalue(cl_selectedtext,co1.red,co1.green,co1.blue);
  setcolormapvalue(cl_selectedtextbackground,co2.red,co2.green,co2.blue);
  if haspasswordchar then begin
   finfo.text.text:= str1;
  end;
  canvas.restore();
 end;
 checktextrect;
end;

procedure tinplaceedit.checktextrect;
var
 info: editnotificationinfoty;
begin
 include(fstate,ies_textrectvalid);
 if (ftextrectbefore.cx <> finfo.res.cx) or
                        (ftextrectbefore.cy <> finfo.res.cy) then begin
  info:= initactioninfo(ea_textsizechanged);
  info.sizebefore:= ftextrectbefore.size;
  info.newsize:= finfo.res.size;
  checkaction(info);
 end;
end;

function tinplaceedit.gettextrect: rectty;
begin
 if not (ies_textrectvalid in fstate) then begin
  ftextrectbefore:= finfo.res;
  msedrawtext.textrect(getfontcanvas,finfo);
  checktextrect;
 end;
 result:= finfo.res;
end;

function tinplaceedit.getfontcanvas: tcanvas;
begin
 result:= fwidget.getcanvas;
 if ffont <> nil then begin
  result.font:= ffont;
 end;
 if ffontstyle <> [] then begin
  result.font.style:= ffontstyle;
 end;
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

procedure tinplaceedit.checkindexvalues();
begin
 fcurindex:= updateindex(fcurindex);
 fselstart:= updateindex(fselstart);
 fsellength:= updateindex(fselstart+fsellength)-fselstart;
end;

procedure tinplaceedit.settext(const Value: msestring);
begin
 finfo.text.text:= Value;
 checkindexvalues();
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
 checkindexvalues();
 if ies_focused in fstate then begin
  internalupdatecaret;
 end;
end;

procedure tinplaceedit.setformat(const avalue: formatinfoarty);
begin
 finfo.text.format:= copy(avalue);
 updateselect();
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
  fwidget.scrollcaret(dist);
 end;
end;

procedure tinplaceedit.updatecaret;
//var
// int1: integer;
begin
// int1:= fupdating;
// fupdating:= 0;
 internalupdatecaret;
// fupdating:= int1;
end;

function tinplaceedit.getcaretpos: pointty;
begin
 if not (ies_caretposvalid in fstate) then begin
  fcaretpos:= textindextomousepos(fcurindex);
  include(fstate,ies_caretposvalid);
  fscrollsum:= nullpoint;
 end;
 result:= addpoint(fcaretpos,fscrollsum);
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
  if twidget1(fwidget).canassistive() then begin
   assistiveserver.doeditcharenter(getiassistiveclient(),chars);
  end;
  inserttext(chars,false);
 finally
  endgroup;
 end;
 {
 if twidget1(fwidget).canassistive() then begin
  assistiveserver.doeditcharenter(getiassistiveclient(),chars);
 end;
 }
end;

procedure tinplaceedit.begingroup;
begin
 //dummy
end;

procedure tinplaceedit.endgroup;
begin
 //dummy
end;

procedure tinplaceedit.beginupdate;
begin
 application.caret.remove;
 inc(fupdating);
end;

procedure tinplaceedit.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  internalupdatecaret;
  invalidatetextrect(minint,bigint);
 end;
 application.caret.restore;
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
    fwidget.scrollrect(makepoint(int1,0),finfo.clip,true);
    inc(finfo.dest.x,int1);
    inc(fscrollsum.x,int1);
   end;
  end;
 end
 else begin
  if rect1.cy > 0 then begin
   int1:= -(finfo.dest.y + round(rect1.cy*avalue) - ftextrect.y);
   if int1 <> 0 then begin
    fwidget.scrollrect(makepoint(0,int1),finfo.clip,true);
    inc(finfo.dest.y,int1);
    inc(fscrollsum.y,int1);
   end;
  end;
 end;
end;

procedure tinplaceedit.dragstarted;
begin
 killrepeater;
end;

procedure tinplaceedit.setfiltertext(const avalue: msestring);
var
 int1,int2,int3: integer;
 foundindex: integer;
 mstr1: msestring;
 casesensitive: boolean;
begin
 if avalue <> '' then begin
  int1:= fintf.locatecount;
  if int1 > 0 then begin
   casesensitive:= oe_casesensitive in fintf.getoptionsedit;
   if casesensitive then begin
    mstr1:= avalue;
   end
   else begin
    mstr1:= mseuppercase(avalue);
   end;
   foundindex:= -1;
   int2:= fintf.locatecurrentindex;
   if int2 < 0 then begin
    int2:= 0;
   end;
   if casesensitive then begin
    for int3:= int2 to int1 - 1 do begin
     if msecomparestrlen(mstr1,fintf.getkeystring(int3)) = 0 then begin
      foundindex:= int3;
      break;
     end;
    end;
   end
   else begin
    for int3:= int2 to int1 - 1 do begin
     if msecomparetextlenupper(mstr1,fintf.getkeystring(int3)) = 0 then begin
      foundindex:= int3;
      break;
     end;
    end;
   end;
   if foundindex < 0 then begin
    if casesensitive then begin
     for int3:= int2-1 downto 0 do begin
      if msecomparestrlen(mstr1,fintf.getkeystring(int3)) = 0 then begin
       foundindex:= int3;
       break;
      end;
     end;
    end
    else begin
     for int3:= int2-1 downto 0 do begin
      if msecomparetextlenupper(mstr1,fintf.getkeystring(int3)) = 0 then begin
       foundindex:= int3;
       break;
      end;
     end;
    end;
   end;
   if foundindex >= 0 then begin
    fintf.locatesetcurrentindex(foundindex);
    ffiltertext:= avalue;
    fselstart:= 0;
    fsellength:= length(ffiltertext);
    curindex:= fselstart+fsellength;
    updateselect;
   end;
  end;
 end
 else begin
  ffiltertext:= '';
  fselstart:= 0;
  fsellength:= 0;
  curindex:= 0;
  updateselect;
 end;
end;

function tinplaceedit.updating: boolean;
begin
 result:= fupdating > 0;
end;

procedure tinplaceedit.redo;
begin
 //dummy
end;

function tinplaceedit.canredo: boolean;
begin
 result:= false;
end;

function tinplaceedit.hasselection: boolean;
begin
 result:= (fsellength > 0) or fintf.hasselection();
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

procedure ttextundolist.beforecopy(var data);
begin
 inherited;
 with undoinfoty(data) do begin
  stringaddref(text);
  stringaddref(textbefore);
//  reallocstring(text);
//  reallocstring(textbefore);
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
 result:= nil;
 alink:= alink or (flinked > 0);
 forcednew:= (dls_forcenew in fstate);
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
 exclude(fstate,dls_forcenew);
end;

procedure ttextundolist.setpos(const endpos: gridcoordty; selected: boolean;
                        alink: boolean = false);
begin
 if flock <> 0 then exit;
 checkrecord(ut_setpos,gridcoordty(nullpoint),endpos,selected,false,alink,0);
end;

procedure ttextundolist.inserttext(const startpos,endpos: gridcoordty;
           const atext: msestring; selected: boolean; backwards: boolean;
           alink: boolean = false);
begin
 if flock <> 0 then exit;
 with checkrecord(ut_inserttext,startpos,endpos,selected,backwards,alink,length(atext))^ do begin
  text:= text + atext;
 end;
end;

procedure ttextundolist.overwritetext(const startpos,endpos: gridcoordty;
             const atext, atextbefore: msestring; selected: boolean;
              alink: boolean = false);
begin
 if flock <> 0 then exit;
 with checkrecord(ut_overwritetext,startpos,endpos,selected,false,
                                              alink,length(atext))^ do begin
  text:= text + atext;
  textbefore:= textbefore + atextbefore;
 end;
end;

procedure ttextundolist.deletetext(const startpos,endpos: gridcoordty;
        const atext: msestring; selected: boolean; backwards: boolean;
        alink: boolean = false);
begin
 if flock <> 0 then exit;
 with checkrecord(ut_deletetext,startpos,endpos,selected,backwards,
                                              alink,length(atext))^ do begin
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
        fintf.setedpos(endpos,uf_selected in flags,false,cep_nearest);
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
      fintf.inserttext(endpos,text,uf_selected in flags,
                                       not(uf_backwards in flags));
     end;
     else;
    end;
    if utype <> ut_setpos then begin
     fintf.setedpos(startpos,uf_selected in flags,false,cep_nearest);
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
       fintf.setedpos(endpos,uf_selected in flags,false,cep_nearest);
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
      else;
     end;
     if utype <> ut_setpos then begin
      fintf.setedpos(endpos,uf_selected in flags,false,cep_nearest);
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
    include(fstate,dls_forcenew);
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
    include(fstate,dls_forcenew);
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

procedure ttextundolist.clear;
begin
 fundopo:= 0;
 inherited;
end;

{ tundoinplaceedit }

constructor tundoinplaceedit.create(aowner: twidget; editintf: iedit;
              undointf: iundo; istextedit: boolean);
begin
 inherited create(aowner,editintf,istextedit);
 include(fstate,ies_cangroupundo);
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

function tundoinplaceedit.cuttoclipboard(
                   const buffer: clipboardbufferty): boolean;
begin
 fundolist.beginlink(ut_none,true);
 try
  result:= inherited cuttoclipboard(buffer);
 finally
  fundolist.endlink(true);
 end;
end;

function tundoinplaceedit.pastefromclipboard(
                     const buffer: clipboardbufferty): boolean;
begin
 fundolist.beginlink(ut_none,true);
 try
  result:= inherited pastefromclipboard(buffer);
 finally
  fundolist.endlink(true);
 end;
end;

procedure tundoinplaceedit.begingroup;
begin
 inherited;
 fundolist.beginlink(ut_none,true);
end;

procedure tundoinplaceedit.endgroup;
begin
 fundolist.endlink(true);
 inherited;
end;

procedure tundoinplaceedit.redo;
begin
 fundolist.redo;
end;

procedure tundoinplaceedit.undo;
begin
 fundolist.undo;
end;

function tundoinplaceedit.canundo: boolean;
begin
 result:= fundolist.canundo;
end;

function tundoinplaceedit.canredo: boolean;
begin
 result:= fundolist.canredo;
end;

end.
