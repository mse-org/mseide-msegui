{ MSEgui Copyright (c) 1999-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseact;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface

uses
 {$ifdef FPC}classes{$else}Classes{$endif},mseclasses,mserichstring,
 msetypes,mseglob,mseapplication,
 {msekeyboard,}mseevent,msestat,msestatfile,msestrings,typinfo,
 msegraphutils{,msebitmap}
 {$ifdef mse_with_ifi},mseifiglob,mseificomp,mseificompglob{$endif};

const
 defaultactionstates = [];
type
 shapestatety = (shs_disabled,shs_invisible,shs_checked,shs_default, //actionstatesty
                 shs_separator,shs_checkbox,shs_radiobutton,        //menuactionoptionty

                 shs_clicked,shs_mouse,shs_moveclick,shs_focused,shs_active,
                 shs_horz,shs_vert,shs_opposite,shs_ellipsemouse,
                 shs_widgetorg,shs_showfocusrect,shs_showdefaultrect,
                 shs_flat,shs_noanimation,shs_nomouseanimation,
                 shs_noclickanimation,shs_nofocusanimation,shs_focusanimation,
                 shs_checkbutton,
                 {ss_submenu,}shs_menuarrow,shs_noinnerrect);
 shapestatesty = set of shapestatety;

 actionstatety = (as_disabled = ord(shs_disabled),as_invisible=ord(shs_invisible),
                  as_checked=ord(shs_checked),as_default=ord(shs_default),
                  as_repeatshortcut,
                  as_localdisabled,as_localinvisible,as_localchecked,as_localdefault,
                  as_localrepeatshortcut,
                  as_localcaption,
                  as_localimagelist,as_localimagenr,as_localimagenrdisabled,
                  as_localimagecheckedoffset,
                  as_localcolorglyph,as_localcolor,
                  as_localhint,as_localshortcut,as_localshortcut1,as_localtag,
                  as_localgroup,as_localonexecute,as_localonbeforeexecute);
 actionstatesty = set of actionstatety;
 actionstatesarty = array of actionstatesty;

 menuactionoptionty = (mao_separator,mao_checkbox,mao_radiobutton,
                       mao_shortcutcaption,
                       mao_asyncexecute,mao_singleregion,
                       mao_showhint,mao_noshowhint,
                       mao_nocandefocus);
 menuactionoptionsty = set of menuactionoptionty;

const
 actionstatesmask: actionstatesty = 
                            [as_disabled,as_checked,as_invisible,as_default,
                             as_repeatshortcut];
 actionshapestatesconst = [as_disabled,as_invisible,as_checked,as_default];
 actionshapestates: actionstatesty = actionshapestatesconst;
 actionoptionshapestates: menuactionoptionsty = 
                                [mao_separator,mao_checkbox,mao_radiobutton];
 actionoptionshapelshift = ord(shs_separator);

 localactionstates: actionstatesty =
            [as_localdisabled,as_localinvisible,as_localchecked,as_localdefault,
             as_localrepeatshortcut,
             as_localcaption,
             as_localimagelist,as_localimagenr,as_localimagenrdisabled,
             as_localimagecheckedoffset,
             as_localcolorglyph,as_localcolor,
             as_localhint,as_localshortcut,as_localshortcut1,as_localtag,
             as_localgroup,as_localonexecute,as_localonbeforeexecute];
 localactionlshift = ord(as_localdisabled);
 localactionstatestates: actionstatesty =
          [as_localdisabled,as_localinvisible,as_localchecked,as_localdefault,
           as_localrepeatshortcut];
type
 actionoptionty = (ao_updateonidle,ao_localshortcut,ao_globalshortcut,
                   ao_nocandefocus);
const
 defaultactionoptions = [];

type
 tcustomaction = class;
 actioneventty = procedure(const sender: tcustomaction) of object;

 actioninfoty = record
  action: tcustomaction;
  captiontext: msestring;
  caption1: richstringty;
  state: actionstatesty;
  options: menuactionoptionsty;
  shortcut: shortcutarty;
  shortcut1: shortcutarty;
  group: integer;
  imagenr: imagenrty; //imagenrty;
  imagenrdisabled: imagenrty; //-2 -> grayed
  colorglyph: colorty;
  color: colorty;
  imagecheckedoffset: integer;
  imagelist: tobject; //timagelist
  hint: msestring;
  tag: integer;
  tagpointer: pointer;
  onexecute: notifyeventty;
  onbeforeexecute: accepteventty;
 end;
 pactioninfoty = ^actioninfoty;

 iactionlink = interface(iobjectlink)['{987D28B5-4245-4672-AF6D-7E8B5D671982}']
  function getactioninfopo: pactioninfoty;
  procedure actionchanged;
  function loading: boolean;
  function shortcutseparator: msechar;
  procedure calccaptiontext(var ainfo: actioninfoty);
  procedure setshortcuts(const avalue: shortcutarty);
  procedure setshortcuts1(const avalue: shortcutarty);  
 end;

 asynceventty = procedure(const sender: tobject; var atag: integer) of object;

 actionoptionsty = set of actionoptionty;

 tcustomaction = class(tactcomponent,istatfile{,iimagelistinfo}
                    {$ifdef mse_with_ifi},iifilink{$endif})
  private
   fonupdate: actioneventty;
   fstatvarname: msestring;
   fstatfile: tstatfile;
   fonchange: notifyeventty;
   fonasyncevent: asynceventty;
   fonexecuteaction: actioneventty;
{$ifdef mse_with_ifi}
   fifilink: tifiactionlinkcomp;
   function getifilinkkind: ptypeinfo;
   procedure setifilink(const avalue: tifiactionlinkcomp); overload;
{$endif}
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
   procedure setonexecute(const Value: notifyeventty);
   procedure setonbeforeexecute(const avalue: accepteventty);
   procedure setimagenr(const Value: imagenrty);
   procedure setimagenrdisabled(const avalue: imagenrty);
   procedure setcolorglyph(const avalue: colorty);
   procedure setcolor(const avalue: colorty);
   procedure setimagecheckedoffset(const Value: integer);
   function getstate: actionstatesty;
   procedure setstate(const Value: actionstatesty);
   function getgroup: integer;
   procedure setgroup(const Value: integer);
   procedure sethint(const Value: msestring);
   procedure settag(const Value: integer);
   function getenabled: boolean;
   procedure setenabled(const Value: boolean);
   procedure doupdateinfo(const info: linkinfoty);
   procedure dounlinkaction(const info: linkinfoty);
   function getchecked: boolean;
   procedure setchecked(const Value: boolean);
   procedure setoptions(const Value: actionoptionsty);
   procedure setstatfile(const Value: tstatfile);
  protected
   finfo: actioninfoty;
   foptions: actionoptionsty;
   procedure registeronshortcut(const avalue: boolean); virtual;
   procedure loaded; override;
   procedure changed;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure doidle(var again: boolean);
   procedure doasyncevent(var atag: integer); override;
   procedure eventfired(const sender: tobject; const ainfo: actioninfoty);
   procedure doafterunlink; virtual;

  //istatfile, saves state of as_checked
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

  //iimagelistinfo
//   function getimagelist: timagelist;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure doupdate;
   procedure execute;
   procedure updateinfo(const sender: iactionlink);
   property caption: captionty read getcaption write setcaption;
   property state: actionstatesty read getstate write setstate default [];
   property enabled: boolean read getenabled write setenabled;
   property checked: boolean read getchecked write setchecked;
   property group: integer read getgroup write setgroup default 0;
   property imagenr: imagenrty read finfo.imagenr write setimagenr default -1;
   property imagenrdisabled: imagenrty read finfo.imagenrdisabled
                      write setimagenrdisabled default -2;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph default cl_glyph;
   property color: colorty read finfo.color write setcolor default cl_default;
   property imagecheckedoffset: integer read finfo.imagecheckedoffset write setimagecheckedoffset default 0;
   property hint: msestring read finfo.hint write sethint;
   property tagaction: integer read finfo.tag write settag default 0;
   property options: actionoptionsty read foptions write setoptions 
                 default defaultactionoptions;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
{$ifdef mse_with_ifi}
   property ifilink: tifiactionlinkcomp read fifilink write setifilink;
{$endif}

   property onexecute: notifyeventty read finfo.onexecute write setonexecute;
   property onbeforeexecute: accepteventty read finfo.onbeforeexecute
                       write setonbeforeexecute;
   property onexecuteaction: actioneventty read fonexecuteaction write fonexecuteaction;
   property onupdate: actioneventty read fonupdate write fonupdate;
   property onchange: notifyeventty read fonchange write fonchange;
   property onasyncevent: asynceventty read fonasyncevent write fonasyncevent;
 end;

 tnoguiaction = class(tcustomaction)
  protected
  published
   property caption;
   property state;
   property group;
   property tagaction;
//   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
//   property shortcut;
   property statfile;
   property statvarname;
   property options;
   property onexecute;
   property onbeforeexecute;
   property onupdate;
   property onchange;
   property onasyncevent;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;

procedure linktoaction(const sender: iactionlink; const aaction: tcustomaction;
                      var info: actioninfoty);
                  //remove existing link, copy action to instance
procedure setactionchecked(const sender: iactionlink; const value: boolean);
procedure setactioncaption(const sender: iactionlink; const value: msestring);
function isactioncaptionstored(const info: actioninfoty): boolean;

procedure setactionimagenr(const sender: iactionlink; const value: integer);
function isactionimagenrstored(const info: actioninfoty): boolean;
procedure setactionimagenrdisabled(const sender: iactionlink; const value: integer);
function isactionimagenrdisabledstored(const info: actioninfoty): boolean;
procedure setactioncolorglyph(const sender: iactionlink; const value: colorty);
function isactioncolorglyphstored(const info: actioninfoty): boolean;
procedure setactioncolor(const sender: iactionlink; const value: colorty);
function isactioncolorstored(const info: actioninfoty): boolean;
procedure setactionimagecheckedoffset(const sender: iactionlink; const value: integer);
function isactionimagecheckedoffsetstored(const info: actioninfoty): boolean;
procedure setactionhint(const sender: iactionlink; const value: msestring);
function isactionhintstored(const info: actioninfoty): boolean;
procedure setactiontag(const sender: iactionlink; const value: integer);
function isactiontagstored(const info: actioninfoty): boolean;

procedure setactionstate(const sender: iactionlink; const value: actionstatesty);
function isactionstatestored(const info: actioninfoty): boolean;

procedure setactionoptions(const sender: iactionlink; const value: menuactionoptionsty);

procedure setactiongroup(const sender: iactionlink; const value: integer);
function isactiongroupstored(const info: actioninfoty): boolean;
procedure setactiononexecute(const sender: iactionlink;
                             const value: notifyeventty; const aloading: boolean);
function isactiononexecutestored(const info: actioninfoty): boolean;
procedure setactiononbeforeexecute(const sender: iactionlink;
                             const value: accepteventty; const aloading: boolean);
function isactiononbeforeexecutestored(const info: actioninfoty): boolean;

procedure actionbeginload(const sender: iactionlink);
procedure actionendload(const sender: iactionlink);

//procedure actiondoidle(const info: actioninfoty);
//procedure getshortcutlist(out keys: integerarty; out names: msestringarty);
//function checkshortcutcode(const shortcut: shortcutty; const info: keyeventinfoty): boolean;
//function doactionshortcut(const sender: tobject; var info: actioninfoty;
//                        var keyinfo: keyeventinfoty): boolean; //true if done
function doactionexecute(const sender: tobject; var info: actioninfoty;
                               const nocheckbox: boolean = false;
                               const nocandefocus: boolean = false): boolean;
          //true if local checked changed
function doactionexecute1(const sender: tobject; var info: actioninfoty;
                         out changed: boolean;
                         const nocheckbox: boolean = false;
                         const nocandefocus: boolean = false): boolean;
          //true if not canceled

procedure initactioninfo(var info: actioninfoty; aoptions: menuactionoptionsty = []);
procedure actionstatestoshapestates(const source: actioninfoty; var dest: shapestatesty);
procedure shapestatestoactionstates(source: shapestatesty;
              var dest: actionstatesty; const mask: actionstatesty = actionshapestatesconst);
function translateshortcut(const akey: shortcutty): shortcutty;
procedure translateshortcut1(var akey: shortcutty); 
           //update for new modifier layout


implementation
uses
 msebits,sysutils,msekeyboard;

procedure translateshortcut1(var akey: shortcutty);
begin
 if akey and $1000 <> 0 then begin    //update for new modifier layout
  akey:= akey and not $1000 or $0100;
 end;
end;

function translateshortcut(const akey: shortcutty): shortcutty;
begin
 result:= akey;
 translateshortcut1(result);
end;

function doactionexecute1(const sender: tobject; var info: actioninfoty;
                         out changed: boolean;
                         const nocheckbox: boolean = false;
                         const nocandefocus: boolean = false): boolean;
          //true if not canceled
var
 bo1: boolean;
begin
 result:= false;
 changed:= false;
 with info do begin
  if not (as_disabled in state) then begin
   if not nocandefocus and 
     ((action = nil) or not(ao_nocandefocus in action.options)) then begin
    if not application.candefocus then begin
     exit;
    end;
   end;
   if assigned(info.onbeforeexecute) then begin
    bo1:= true;
    info.onbeforeexecute(sender,bo1);
    if not bo1 then begin
     exit;
    end;
   end;
   if not nocheckbox and (mao_checkbox in info.options) then begin
    if action <> nil then begin
     action.checked:= not action.checked;
    end
    else begin
     togglebit1(longword(info.state),ord(as_checked));
     changed:= true;
    end;
   end;
   if assigned(info.onexecute) then begin
    info.onexecute(sender);
   end;
   if info.action <> nil then begin
    info.action.eventfired(sender,info); 
   end;
   result:= true;
  end;
 end;
end;

function doactionexecute(const sender: tobject; var info: actioninfoty;
                         const nocheckbox: boolean = false;
                         const nocandefocus: boolean = false): boolean;
      //true if local checked changed
begin
 doactionexecute1(sender,info,result,nocheckbox,nocandefocus);
end;

procedure actionstatestoshapestates(const source: actioninfoty; var dest: shapestatesty);
begin
 dest:= shapestatesty(replacebits({$ifdef FPC}longword{$else}longword{$endif}(source.state),
           {$ifdef FPC}longword{$else}longword{$endif}(dest),
           {$ifdef FPC}longword{$else}longword{$endif}(actionshapestates)));
 dest:= shapestatesty(replacebits(
  {$ifdef FPC}longword{$else}word{$endif}(
        {$ifdef FPC}longword{$else}word{$endif}(source.options)
               shl {$ifdef FPC}longword{$else}word{$endif}(actionoptionshapelshift)
                                           ),
           {$ifdef FPC}longword{$else}longword{$endif}(dest),
  {$ifdef FPC}longword{$else}word{$endif}(
           {$ifdef FPC}longword{$else}word{$endif}(actionoptionshapestates)
                shl {$ifdef FPC}longword{$else}longword{$endif}(actionoptionshapelshift))
                                           )
                );
end;

procedure shapestatestoactionstates(source: shapestatesty; var dest: actionstatesty;
              const mask: actionstatesty = actionshapestatesconst);
begin
 dest:= actionstatesty(replacebits({$ifdef FPC}longword{$else}longword{$endif}(source),
           {$ifdef FPC}longword{$else}longword{$endif}(dest),
           {$ifdef FPC}longword{$else}longword{$endif}(actionshapestates*mask)));
end;

procedure resetlocalstates(var states: actionstatesty);
begin
 states:= states - localactionstates;
end;

procedure setlocalstates(var states: actionstatesty);
begin
 states:= states + localactionstates;
end;

procedure initactioninfo(var info: actioninfoty;
                     aoptions: menuactionoptionsty = []);
begin
 with info do begin
  imagenr:= -1;
  imagenrdisabled:= -2;
  options:= aoptions;
  colorglyph:= cl_glyph;
  color:= cl_default;
 end;
end;

procedure actionbeginload(const sender: iactionlink);
begin
// include(sender.getactioninfopo^.options,mao_loading);
end;

procedure actionendload(const sender: iactionlink);
begin
// exclude(sender.getactioninfopo^.options,mao_loading);
 sender.actionchanged;
end;

procedure linktoaction(const sender: iactionlink; const aaction: tcustomaction;
                              var info: actioninfoty);
var
 sepchar: msechar;
begin
 with info do begin
  if aaction <> action then begin
   setlinkedcomponent(sender,aaction,tmsecomponent(action),typeinfo(iactionlink));
   if action <> nil then begin
    action.updateinfo(sender);
   end
   else begin
    if state * localactionstates <> localactionstates then begin
     sepchar:= sender.shortcutseparator;
     if not (as_localcaption in state) then begin
      captiontext:= '';
      sender.calccaptiontext(info);
     end;
     if not (as_localshortcut in state) then begin
      shortcut:= nil;
      sender.calccaptiontext(info);
     end;
     if not (as_localshortcut1 in state) then begin
      shortcut1:= nil;
     end;
     if not (as_localimagelist in state) then begin
      imagelist:= nil; //do not unink,imagelist is owned by action
     end;
     if not (as_localimagenr in state) then begin
      imagenr:= -1;
     end;
     if not (as_localimagenrdisabled in state) then begin
      imagenrdisabled:= -2;
     end;
     if not (as_localcolorglyph in state) then begin
      colorglyph:= cl_glyph;
     end;
     if not (as_localcolor in state) then begin
      color:= cl_transparent;
     end;
     if not (as_localimagecheckedoffset in state) then begin
      imagecheckedoffset:= 0;
     end;
     if not (as_localtag in state) then begin
      tag:= 0;
     end;
     if not (as_localgroup in state) then begin
      group:= 0;
     end;
     if not (as_localhint in state) then begin
      hint:= '';
     end;
     if not (as_localonexecute in state) then begin
      onexecute:= nil;
     end;
     if not (as_localonbeforeexecute in state) then begin
      onbeforeexecute:= nil;
     end;
     state:= state - actionstatesty(
                  longword(localactionstatestates) shr localactionlshift);
     sender.actionchanged;
    end;
   end;
  end;
 end;
end;
{
procedure actiondoidle(const info: actioninfoty);
begin
 if info.action <> nil then begin
  info.action.doupdate;
 end;
end;
}
{
function isactionvisiblestored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (ss_localinvisible in state) and
         not ((action = nil) and not(ss_invisible in state));
 end;
end;

function isactioncheckedstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (ss_localchecked in state) and
        not ((action = nil) and not (ss_checked in state));
 end;
end;
}

procedure setactionchecked(const sender: iactionlink; const value: boolean);
var
 po1: pactioninfoty;
 bo1: boolean;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  bo1:= as_checked in state;
  if bo1 <> value then begin
   if not (as_localchecked in state) and (action <> nil) then begin
    action.checked:= value;
   end
   else begin
    updatebit(longword(state),ord(as_checked),value);
    sender.actionchanged;
   end;
  end;
 end;
end;

procedure setactioncaption(const sender: iactionlink; const value: msestring);
var
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  captiontext:= value;
  include(state,as_localcaption);
 end;
 sender.calccaptiontext(po1^);
 sender.actionchanged;
end;

function isactioncaptionstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localcaption in state) and
        not ((action = nil) and (captiontext = ''));
 end;
end;

procedure setactiontag(const sender: iactionlink; const value: integer);
var
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  tag:= value;
  include(state,as_localtag);
 end;
 sender.actionchanged;
end;

function isactiontagstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localtag in state) and
         not ((action = nil) and (tag = 0));
 end;
end;

procedure setactionimagenr(const sender: iactionlink; const value: integer);
begin
 with sender.getactioninfopo^ do begin
  imagenr:= value;
  include(state,as_localimagenr);
 end;
 sender.actionchanged;
end;

function isactionimagenrstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localimagenr in state) and
         not ((action = nil) and (imagenr = -1));
 end;
end;

procedure setactionimagenrdisabled(const sender: iactionlink; const value: integer);
begin
 with sender.getactioninfopo^ do begin
  imagenrdisabled:= value;
  include(state,as_localimagenrdisabled);
 end;
 sender.actionchanged;
end;

function isactionimagenrdisabledstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localimagenrdisabled in state) and
         not ((action = nil) and (imagenrdisabled = -2));
 end;
end;

procedure setactioncolorglyph(const sender: iactionlink; const value: colorty);
begin
 with sender.getactioninfopo^ do begin
  colorglyph:= value;
  include(state,as_localcolorglyph);
 end;
 sender.actionchanged;
end;

procedure setactioncolor(const sender: iactionlink; const value: colorty);
begin
 with sender.getactioninfopo^ do begin
  color:= value;
  include(state,as_localcolor);
 end;
 sender.actionchanged;
end;

function isactioncolorglyphstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localcolorglyph in state) and
         not ((action = nil) and (colorglyph = cl_default));
 end;
end;

function isactioncolorstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localcolor in state) and
         not ((action = nil) and (color = cl_default));
 end;
end;

procedure setactionimagecheckedoffset(const sender: iactionlink; const value: integer);
begin
 with sender.getactioninfopo^ do begin
  imagecheckedoffset:= value;
  include(state,as_localimagecheckedoffset);
 end;
 sender.actionchanged;
end;

function isactionimagecheckedoffsetstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localimagecheckedoffset in state) and
         not ((action = nil) and (imagecheckedoffset = 0));
 end;
end;

procedure setactionhint(const sender: iactionlink; const value: msestring);
begin
 with sender.getactioninfopo^ do begin
  hint:= value;
  include(state,as_localhint);
 end;
 sender.actionchanged;
end;

function isactionhintstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localhint in state) and
         not ((action = nil) and (hint = ''));
 end;
end;

procedure setactionstate(const sender: iactionlink; const value: actionstatesty);
var
 startstate,statebefore: actionstatesty;
 bo1: boolean;
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  startstate:= state;
  statebefore:= state;
  state:= actionstatesty(replacebits(
   {$ifdef FPC}longword{$else}longword{$endif}(value),
   {$ifdef FPC}longword{$else}longword{$endif}(state),
              {$ifdef FPC}longword{$else}longword{$endif}(localactionstates)));
  bo1:= state <> statebefore;
  statebefore:= state;
  state:= actionstatesty(replacebits(
   {$ifdef FPC}longword{$else}longword{$endif}(value),
   {$ifdef FPC}longword{$else}longword{$endif}(state),
              {$ifdef FPC}longword{$else}longword{$endif}(actionstatesmask)));
  if statebefore <> state then begin
   if (mao_shortcutcaption in options) and
           (statebefore * [as_disabled] <> state * [as_disabled]) then begin
    sender.calccaptiontext(po1^);
   end;
  end;
  if not sender.loading then begin
{$ifdef FPC}longword{$else}longword{$endif}(state):=
    {$ifdef FPC}longword{$else}longword{$endif}(state) or
      (
       (
        (
        {$ifdef FPC}longword{$else}longword{$endif}(state) xor
        {$ifdef FPC}longword{$else}longword{$endif}(statebefore)
        ) and
        {$ifdef FPC}longword{$else}longword{$endif}(actionstatesmask)
       )
       shl localactionlshift
      );
  end;
  if bo1 and (action <> nil) then begin
   action.updateinfo(sender);
  end;
  if state <> startstate then begin
   sender.actionchanged;
  end;
 end;
end;

procedure setactionoptions(const sender: iactionlink;
                                          const value: menuactionoptionsty);
const
 mask1: menuactionoptionsty = [mao_showhint,mao_noshowhint];
 mask2: menuactionoptionsty = [mao_checkbox,mao_radiobutton];
var
 optionsbefore: menuactionoptionsty;
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  optionsbefore:= options;
  options:= menuactionoptionsty(setsinglebit(
                         {$ifdef FPC}longword{$else}word{$endif}(value),
                         {$ifdef FPC}longword{$else}word{$endif}(options),
                         {$ifdef FPC}longword{$else}word{$endif}(mask1)));
  options:= menuactionoptionsty(setsinglebit(
                         {$ifdef FPC}longword{$else}word{$endif}(options),
                         {$ifdef FPC}longword{$else}word{$endif}(optionsbefore),
                         {$ifdef FPC}longword{$else}word{$endif}(mask2)));
  if optionsbefore * [mao_shortcutcaption] <> options * 
                                     [mao_shortcutcaption] then begin
   sender.calccaptiontext(po1^);
  end;
 end;
 sender.actionchanged;
end;

function isactionstatestored(const info: actioninfoty): boolean;
begin
 result:= true;
 {
 with info do begin
  result:= (state * localactionstatestates <> []) and
         not ((action = nil) and (state * actionstatesmask = []));
 end;
 }
end;

procedure setactiongroup(const sender: iactionlink; const value: integer);
begin
 with sender.getactioninfopo^ do begin
  group:= value;
  include(state,as_localgroup);
 end;
 sender.actionchanged;
end;

function isactiongroupstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localgroup in state) and
         not ((action = nil) and (group = 0));
 end;
end;

procedure setactiononexecute(const sender: iactionlink;
                    const value: notifyeventty; const aloading: boolean);
begin
 with sender.getactioninfopo^ do begin
  onexecute:= value;
  if not aloading then begin //IDE sets csloading while method pointer swapping
   include(state,as_localonexecute);
  end;
 end;
 sender.actionchanged;
end;

function isactiononexecutestored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localonexecute in state) and
        not ((action = nil) and (tmethod(info.onexecute).Code = nil));
                                 //assigned does not work
 end;
end;

procedure setactiononbeforeexecute(const sender: iactionlink;
                    const value: accepteventty; const aloading: boolean);
begin
 with sender.getactioninfopo^ do begin
  onbeforeexecute:= value;
  if not aloading then begin //IDE sets csloading while method pointer swapping
   include(state,as_localonbeforeexecute);
  end;
 end;
 sender.actionchanged;
end;

function isactiononbeforeexecutestored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localonbeforeexecute in state) and
        not ((action = nil) and (tmethod(info.onexecute).Code = nil));
                                 //assigned does not work
 end;
end;

 {tcustomaction}

constructor tcustomaction.create(aowner: tcomponent);
begin
 initactioninfo(finfo);
 finfo.action:= self;
 foptions:= defaultactionoptions;
 inherited;
end;

procedure tcustomaction.dounlinkaction(const info: linkinfoty);
begin
 linktoaction(iactionlink(info.dest),nil,
                           iactionlink(info.dest).getactioninfopo^);
end;

destructor tcustomaction.destroy;
begin
 if fobjectlinker <> nil then begin
  fobjectlinker.forall({$ifdef FPC}@{$endif}dounlinkaction,typeinfo(iactionlink));
 end;
 doafterunlink;
 options:= [];
 inherited;
end;

procedure tcustomaction.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

function tcustomaction.getcaption: captionty;
begin
 result:= finfo.captiontext;
end;

procedure tcustomaction.setcaption(const Value: msestring);
begin
 finfo.captiontext:= value;
 changed;
end;
{
function tcustomaction.getimagelist: timagelist;
begin
 result:= finfo.imagelist;
end;
}
{
function tcustomaction.getimagenr: integer;
begin
 result:= finfo.imagenr;
end;
}
procedure tcustomaction.setimagenr(const Value: imagenrty);
begin
 finfo.imagenr:= value;
 changed;
end;

procedure tcustomaction.setimagenrdisabled(const avalue: imagenrty);
begin
 finfo.imagenrdisabled:= avalue;
 changed;
end;

procedure tcustomaction.setcolorglyph(const avalue: colorty);
begin
 finfo.colorglyph:= avalue;
 changed;
end;

procedure tcustomaction.setcolor(const avalue: colorty);
begin
 finfo.color:= avalue;
 changed;
end;

procedure tcustomaction.setimagecheckedoffset(const Value: integer);
begin
 finfo.imagecheckedoffset:= value;
 changed;
end;

{
function tcustomaction.gethint: msestring;
begin
 result:= finfo.hint;
end;
}
procedure tcustomaction.sethint(const Value: msestring);
begin
 finfo.hint:= value;
 changed;
end;

function tcustomaction.getstate: actionstatesty;
begin
 result:= finfo.state;
end;

procedure tcustomaction.setstate(const Value: actionstatesty);
begin
 if value * actionstatesmask <> finfo.state * actionstatesmask then begin
  finfo.state:= actionstatesty(replacebits(
        {$ifdef FPC}longword{$else}longword{$endif}(value),
        {$ifdef FPC}longword{$else}longword{$endif}(finfo.state),
        {$ifdef FPC}longword{$else}longword{$endif}(actionstatesmask)));
  changed;
 end;
end;

function tcustomaction.getgroup: integer;
begin
 result:= finfo.group;
end;

procedure tcustomaction.setgroup(const Value: integer);
begin
 finfo.group:= value;
 changed;
end;

procedure tcustomaction.settag(const Value: integer);
begin
 finfo.tag := Value;
 changed;
end;

procedure tcustomaction.setonexecute(const Value: notifyeventty);
begin
 if not issamemethod(tmethod(value),tmethod(finfo.onexecute)) then begin
  finfo.onexecute := Value;
  changed;
 end;
end;

procedure tcustomaction.setonbeforeexecute(const avalue: accepteventty);
begin
 if not issamemethod(tmethod(avalue),tmethod(finfo.onbeforeexecute)) then begin
  finfo.onbeforeexecute := avalue;
  changed;
 end;
end;

procedure tcustomaction.loaded;
begin
 inherited;
 changed;
end;

procedure tcustomaction.updateinfo(const sender: iactionlink);
var
 bo1: boolean;
 mask: actionstatesty;
 po1: pactioninfoty;
 sepchar: msechar;
begin
 bo1:= false;
 po1:= sender.getactioninfopo;
 with po1^ do begin
  sepchar:= sender.shortcutseparator;
  if not (as_localcaption in state) and
              (captiontext <> finfo.captiontext) then begin
   captiontext:= finfo.captiontext;
   sender.calccaptiontext(po1^);
   bo1:= true;
  end;
  if not (as_localshortcut in state) and
              (shortcut <> finfo.shortcut) then begin
   shortcut:= finfo.shortcut;
   sender.calccaptiontext(po1^);
   bo1:= true;
  end;
  if not (as_localshortcut1 in state) and
              (shortcut1 <> finfo.shortcut1) then begin
   shortcut1:= finfo.shortcut1;
   bo1:= true;
  end;
  if not (as_localimagelist in state) and
              (imagelist <> finfo.imagelist) then begin
   imagelist:= finfo.imagelist;
   bo1:= true;
  end;
  if not (as_localimagenr in state) and
              (imagenr <> finfo.imagenr) then begin
   imagenr:= finfo.imagenr;
   bo1:= true;
  end;
  if not (as_localimagenrdisabled in state) and
              (imagenrdisabled <> finfo.imagenrdisabled) then begin
   imagenrdisabled:= finfo.imagenrdisabled;
   bo1:= true;
  end;
  if not (as_localcolorglyph in state) and
              (colorglyph <> finfo.colorglyph) then begin
   colorglyph:= finfo.colorglyph;
   bo1:= true;
  end;
  if not (as_localcolor in state) and
              (color <> finfo.color) then begin
   color:= finfo.color;
   bo1:= true;
  end;
  if not (as_localimagecheckedoffset in state) and
              (imagecheckedoffset <> finfo.imagecheckedoffset) then begin
   imagecheckedoffset:= finfo.imagecheckedoffset;
   bo1:= true;
  end;
  if not (as_localtag in state) and
              (tag <> finfo.tag) then begin
   tag:= finfo.tag;
   bo1:= true;
  end;
  if not (as_localgroup in state) and
              (group <> finfo.group) then begin
   group:= finfo.group;
   bo1:= true;
  end;
  if not (as_localhint in state) and
              (hint <> finfo.hint) then begin
   hint:= finfo.hint;
   bo1:= true;
  end;
  if not (as_localonexecute in state) and
         not issamemethod(tmethod(onexecute),tmethod(finfo.onexecute)) then begin
   onexecute:= finfo.onexecute;
   bo1:= true;
  end;
  if not (as_localonbeforeexecute in state) and
         not issamemethod(tmethod(onbeforeexecute),
                     tmethod(finfo.onbeforeexecute)) then begin
   onbeforeexecute:= finfo.onbeforeexecute;
   bo1:= true;
  end;
  mask:= actionstatesmask -
   actionstatesty(
    {$ifdef FPC}longword{$else}longword{$endif}(
    {$ifdef FPC}longword{$else}longword{$endif}(state * localactionstatestates) shr
                            localactionlshift)
                 );
//  if as_localstate in state then begin
//   mask:= mask - actionstatesmask;
//  end;
  {
  if ss_localchecked in state then begin
   exclude(mask,ss_checked);
  end;
  }
  if state * mask <> finfo.state * mask then begin
   bo1:= true;
   state:= actionstatesty(
          replacebits({$ifdef FPC}longword{$else}longword{$endif}(finfo.state),
          {$ifdef FPC}longword{$else}longword{$endif}(state),
          {$ifdef FPC}longword{$else}longword{$endif}(mask)));
  end;
 end;
 if bo1 then begin
  sender.actionchanged;
 end;
end;

procedure tcustomaction.doupdateinfo(const info: linkinfoty);
begin
 updateinfo(iactionlink(info.dest));
end;

procedure tcustomaction.changed;
begin
 if not (csloading in componentstate) then begin
  if fobjectlinker <> nil then begin
   fobjectlinker.forall({$ifdef FPC}@{$endif}doupdateinfo,typeinfo(iactionlink));
  end;
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;

procedure tcustomaction.doupdate;
begin
 if assigned(fonupdate) and not (csdesigning in componentstate) then begin
  fonupdate(self);
 end;
end;

procedure tcustomaction.doidle(var again: boolean);
begin
 doupdate;
end;

procedure tcustomaction.execute;
begin
 if doactionexecute(self,finfo) then begin
  changed;
 end;
end;

procedure tcustomaction.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 inherited;
 if (event = oe_destroyed) and (sender = finfo.imagelist) then begin
  finfo.imagelist:= nil;
  changed;
 end;
end;

function tcustomaction.getenabled: boolean;
begin
 result:= not (as_disabled in finfo.state);
end;

procedure tcustomaction.setenabled(const Value: boolean);
begin
 if value then begin
  state:= finfo.state - [as_disabled];
 end
 else begin
  state:= finfo.state + [as_disabled];
 end;
end;

function tcustomaction.getchecked: boolean;
begin
 result:= as_checked in finfo.state;
end;

procedure tcustomaction.setchecked(const Value: boolean);
begin
 if value then begin
  state:= state + [as_checked];
 end
 else begin
  state:= state - [as_checked];
 end;
end;

procedure tcustomaction.setoptions(const Value: actionoptionsty);
var
 delta: actionoptionsty;
begin
 delta:= actionoptionsty({$ifdef FPC}longword{$else}byte{$endif}(foptions) xor
             {$ifdef FPC}longword{$else}byte{$endif}(value));
 if delta <> [] then begin
  foptions := Value;
  if not (csdesigning in componentstate) then begin
   if ao_updateonidle in delta then begin
    if ao_updateonidle in value then begin
     application.registeronidle({$ifdef FPC}@{$endif}doidle);
    end
    else begin
     application.unregisteronidle({$ifdef FPC}@{$endif}doidle);
    end;
   end;
   if [ao_globalshortcut,ao_localshortcut] * delta <> [] then begin
    registeronshortcut([ao_globalshortcut,ao_localshortcut] * value <> []);
   end;
  end;
 end;
end;

procedure tcustomaction.dostatread(const reader: tstatreader);
begin
 if reader.candata then begin
  checked:= reader.readboolean('checked',checked);
 end;
end;

procedure tcustomaction.dostatwrite(const writer: tstatwriter);
begin
 if writer.candata then begin
  writer.writeboolean('checked',checked);
 end;
end;

procedure tcustomaction.statreading;
begin
 //dummy
end;

procedure tcustomaction.statread;
begin
 //dummy
end;

function tcustomaction.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomaction.doasyncevent(var atag: integer);
begin
 if canevent(tmethod(fonasyncevent)) then begin
  fonasyncevent(self,atag);
 end;
end;

procedure tcustomaction.eventfired(const sender: tobject;
               const ainfo: actioninfoty);
begin
 if canevent(tmethod(fonexecuteaction)) then begin
  fonexecuteaction(self);
 end;
 sendchangeevent(oe_fired);
{$ifdef mse_with_ifi}
 if fifiserverintf <> nil then begin
  fifiserverintf.execute(iificlient(self));
 end;
{$endif}
end;

procedure tcustomaction.registeronshortcut(const avalue: boolean);
begin
 //dummy
end;

procedure tcustomaction.doafterunlink;
begin
 //dummy
end;

{$ifdef mse_with_ifi}
function tcustomaction.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifilink);
end;

procedure tcustomaction.setifilink(const avalue: tifiactionlinkcomp);
begin
 mseificomp.setifilinkcomp(iifilink(self),avalue,tifilinkcomp(fifilink));
end;
{$endif}

end.

