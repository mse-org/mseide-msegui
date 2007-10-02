{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseactions;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 {$ifdef FPC}classes{$else}Classes{$endif},mseclasses,mseshapes,mserichstring,
 msetypes,mseguiglob,msegui,
 msebitmap,msekeyboard,mseevent,msestat,msestatfile,msestrings,msegraphics;

const
 defaultactionstates = [];
type
// menuoptionty = (mo_shortcutcaption,ss_checkbox,ss_radiobutton,);
// actionstylesty = set of actionstylety;

 tcustomaction = class;
 actioneventty = procedure(const sender: tcustomaction) of object;

 actioninfoty = record
  action: tcustomaction;
  captiontext: msestring;
  caption1: richstringty;
  state: actionstatesty;
  options: menuactionoptionsty;
  shortcut: shortcutty;
  group: integer;
  imagenr: integer;
  imagenrdisabled: integer; //-2 -> grayed
  colorglyph: colorty;
  color: colorty;
  imagecheckedoffset: integer;
  imagelist: timagelist;
  hint: msestring;
  tag: integer;
  onexecute: notifyeventty;
 end;
 pactioninfoty = ^actioninfoty;

 iactionlink = interface(iobjectlink)
  function getactioninfopo: pactioninfoty;
  procedure actionchanged;
  function loading: boolean;
  function shortcutseparator: msechar;
 end;
 
 asynceventty = procedure(const sender: tobject; var atag: integer) of object;
 
 actionoptionty = (ao_updateonidle,ao_localshortcut,ao_globalshortcut);
 actionoptionsty = set of actionoptionty;

 tcustomaction = class(tguicomponent,istatfile)
  private
   fonupdate: actioneventty;
   foptions: actionoptionsty;
   fstatvarname: msestring;
   fstatfile: tstatfile;
   fonchange: notifyeventty;
   fonasyncevent: asynceventty;
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
   procedure setonexecute(const Value: notifyeventty);
   procedure setimagenr(const Value: integer);
   procedure setimagenrdisabled(const avalue: integer);
   procedure setcolorglyph(const avalue: colorty);
   procedure setcolor(const avalue: colorty);
   procedure setimagecheckedoffset(const Value: integer);
   procedure setimagelist(const Value: timagelist);
   function getstate: actionstatesty;
   procedure setstate(const Value: actionstatesty);
   function getgroup: integer;
   procedure setgroup(const Value: integer);
   procedure sethint(const Value: msestring);
   procedure setshortcut(const Value: shortcutty);
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
   procedure loaded; override;
   procedure changed;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure doidle(var again: boolean);
   procedure doshortcut(const sender: twidget; var info: keyeventinfoty);
   procedure doasyncevent(var atag: integer); override;
   procedure eventfired(const sender: tobject; const ainfo: actioninfoty);

   //istatfile, saves state of as_checked
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
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
   property imagelist: timagelist read finfo.imagelist write setimagelist;
   property imagenr: integer read finfo.imagenr write setimagenr default -1;
   property imagenrdisabled: integer read finfo.imagenrdisabled 
                      write setimagenrdisabled default -2;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph default cl_glyph;
   property color: colorty read finfo.color write setcolor default cl_transparent;
   property imagecheckedoffset: integer read finfo.imagecheckedoffset write setimagecheckedoffset default 0;
   property shortcut: shortcutty read finfo.shortcut write setshortcut default ord(key_none);
   property hint: msestring read finfo.hint write sethint;
   property tagaction: integer read finfo.tag write settag default 0;
   property options: actionoptionsty read foptions write setoptions default [];
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onexecute: notifyeventty read finfo.onexecute write setonexecute;
   property onupdate: actioneventty read fonupdate write fonupdate;
   property onchange: notifyeventty read fonchange write fonchange;
   property onasyncevent: asynceventty read fonasyncevent write fonasyncevent;
 end;

 taction = class(tcustomaction)
  published
   property caption;
   property state;
   property group;
   property tagaction;
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
   property shortcut;
   property statfile;
   property statvarname;
   property options;
   property onexecute;
   property onupdate;
   property onchange;
   property onasyncevent;
 end;

procedure linktoaction(const sender: iactionlink; const aaction: tcustomaction;
                      var info: actioninfoty);
                  //remove existing link, copy action to instance
procedure setactionchecked(const sender: iactionlink; const value: boolean);
procedure setactioncaption(const sender: iactionlink; const value: msestring);
function isactioncaptionstored(const info: actioninfoty): boolean;

procedure setactionimagelist(const sender: iactionlink; const value: timagelist);
function isactionimageliststored(const info: actioninfoty): boolean;
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
procedure setactionshortcut(const sender: iactionlink; const value: shortcutty);
function isactionshortcutstored(const info: actioninfoty): boolean;
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

procedure actionbeginload(const sender: iactionlink);
procedure actionendload(const sender: iactionlink);

//procedure actiondoidle(const info: actioninfoty);
procedure actioninfotoshapeinfo(var actioninfo: actioninfoty;
            var shapeinfo: shapeinfoty); overload;
procedure actioninfotoshapeinfo(const sender: twidget; var actioninfo: actioninfoty;
                                    var shapeinfo: shapeinfoty); overload;

procedure getshortcutlist(out keys: integerarty; out names: msestringarty);
function getshortcutname(key: shortcutty): msestring;
function getshortcutcode(const info: keyeventinfoty): shortcutty;
function doactionshortcut(const sender: tobject; var info: actioninfoty;
                        var keyinfo: keyeventinfoty): boolean; //true if done
function doactionexecute(const sender: tobject; var info: actioninfoty;
                               const nocheckbox: boolean = false): boolean;
      //true if local checked changed

procedure initactioninfo(var info: actioninfoty; aoptions: menuactionoptionsty = []);
procedure actionstatestoshapestates(const source: actioninfoty; var dest: shapestatesty);
procedure shapestatestoactionstates(source: shapestatesty;
              var dest: actionstatesty; const mask: actionstatesty = actionshapestatesconst);
procedure calccaptiontext(var info: actioninfoty; const aseparator: msechar);

implementation
uses
 msebits,sysutils,typinfo;

const
 letterkeycount = ord('z') - ord('a') + 1;
 cipherkeycount = ord('9') - ord('0') + 1;
 functionkeycount = 12;
 misckeycount = ord(key_sysreq) - ord(key_escape) + 1;
 cursorkeycount = ord(key_pagedown) - ord(key_home) + 1;
 specialkeycount = misckeycount + cursorkeycount;
 shortcutcount = (letterkeycount + cipherkeycount) * 2 + //ctrl,shiftctrl
                 functionkeycount * 4 +              //none,shift,ctrl,shiftctrl
                 specialkeycount * 4;                //none,shift,ctrl,shiftctrl

var
 shortcutkeys: integerarty;
 shortcutnames: msestringarty;

function doactionexecute(const sender: tobject; var info: actioninfoty;
                         const nocheckbox: boolean = false): boolean;
      //true if local checked changed
begin
 result:= false;
 with info do begin
  if not (as_disabled in state) then begin
   if not nocheckbox and (mao_checkbox in info.options) then begin
    if action <> nil then begin
     action.checked:= not action.checked;
    end
    else begin
     togglebit1(longword(info.state),ord(as_checked));
     result:= true;
    end;
   end;
   if assigned(info.onexecute) then begin
    info.onexecute(sender);
   end;
   if info.action <> nil then begin
    info.action.eventfired(sender,info); 
   end;
  end;
 end;
end;

function doactionshortcut(const sender: tobject; var info: actioninfoty;
                        var keyinfo: keyeventinfoty): boolean;
                          //true if done
var
 key: word;
begin
 result:= false;
 with info do begin
  if (shortcut <> 0) and not (as_disabled in state) and
                         not (es_processed in keyinfo.eventstate) then begin
   key:= getshortcutcode(keyinfo);
   if key = shortcut then begin
    doactionexecute(sender,info);
    include(keyinfo.eventstate,es_processed);
    result:= true;
   end;
  end;
 end;
end;

procedure actionstatestoshapestates(const source: actioninfoty; var dest: shapestatesty);
begin
 dest:= shapestatesty(replacebits({$ifdef FPC}longword{$else}longword{$endif}(source.state),
           {$ifdef FPC}longword{$else}longword{$endif}(dest),
           {$ifdef FPC}longword{$else}longword{$endif}(actionshapestates)));
 dest:= shapestatesty(replacebits(
  {$ifdef FPC}longword{$else}word{$endif}(
        {$ifdef FPC}longword{$else}byte{$endif}(source.options)
               shl {$ifdef FPC}longword{$else}word{$endif}(actionoptionshapelshift)
                                           ),
           {$ifdef FPC}longword{$else}longword{$endif}(dest),
  {$ifdef FPC}longword{$else}word{$endif}(
           {$ifdef FPC}longword{$else}byte{$endif}(actionoptionshapestates)
                shl {$ifdef FPC}longword{$else}word{$endif}(actionoptionshapelshift))
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

procedure initactioninfo(var info: actioninfoty; aoptions: menuactionoptionsty = []);
begin
 with info do begin
  imagenr:= -1;
  imagenrdisabled:= -2;
  options:= aoptions;
  colorglyph:= cl_glyph;
  color:= cl_transparent;
 end;
end;

procedure getshortcutlist(out keys: integerarty; out names: msestringarty);
var
 int1: integer;
 bo1: boolean;
 bottom: integer;
 akey: keyty;
 
 procedure getvalues(const prefix: msestring; const modvalue: integer);
 var
  int1: integer;
 begin
  for int1:= bottom to bottom+cipherkeycount-1 do begin
   keys[int1]:= ord(key_0) + int1-bottom + modvalue;
   names[int1]:= prefix+'+'+msestring(msechar(int1-bottom+ord('0')));
  end;
  bottom:= bottom + cipherkeycount;
  for int1:= bottom to bottom+letterkeycount-1 do begin
   keys[int1]:= ord(key_a) + int1-bottom + modvalue;
   names[int1]:= prefix+'+'+msestring(msechar(int1-bottom+ord('A')));
  end;
  bottom:= bottom + letterkeycount;
  for int1:= bottom to bottom + functionkeycount - 1 do begin
   keys[int1]:= (ord(key_f1) + int1-bottom) or modvalue;
   names[int1]:= prefix+'+F'+inttostr(int1-bottom+1);
  end;
  bottom:= bottom+functionkeycount;
  for int1:= bottom to bottom+misckeycount-1 do begin
   akey:= keyty(ord(key_escape) + int1-bottom);
   keys[int1]:= ord(akey)or modvalue;
   names[int1]:= prefix+'+'+misckeynames[akey];
  end;
  bottom:= bottom+misckeycount;
  for int1:= bottom to bottom+cursorkeycount-1 do begin
   akey:= keyty(ord(key_home) + int1-bottom);
   keys[int1]:= ord(akey)or modvalue;
   names[int1]:= prefix+'+'+cursorkeynames[akey];
  end;
  bottom:= bottom+cursorkeycount;
 end;
 
begin
 bo1:= false;
 if shortcutkeys = nil then begin
  setlength(shortcutkeys,shortcutcount);
  bo1:= true;
 end;
 if shortcutnames = nil then begin
  setlength(shortcutnames,shortcutcount);
  bo1:= true;
 end;
 keys:= shortcutkeys;
 names:= shortcutnames;
 if bo1 then begin
  bottom:= 0;
  for int1:= bottom to bottom + functionkeycount - 1 do begin
   keys[int1]:= ord(key_f1) + int1-bottom;
   names[int1]:= 'F'+inttostr(int1-bottom+1);
  end;
  bottom:= bottom+functionkeycount;
  for int1:= bottom to bottom+misckeycount-1 do begin
   akey:= keyty(ord(key_escape) + int1-bottom);
   keys[int1]:= ord(akey);
   names[int1]:= misckeynames[akey];
  end;
  bottom:= bottom+misckeycount;
  for int1:= bottom to bottom+cursorkeycount-1 do begin
   akey:= keyty(ord(key_home) + int1-bottom);
   keys[int1]:= ord(akey);
   names[int1]:= cursorkeynames[akey];
  end;
  bottom:= bottom+cursorkeycount;
  for int1:= bottom to bottom + functionkeycount - 1 do begin
   keys[int1]:= (ord(key_f1) + int1-bottom) or key_modshift;
   names[int1]:= 'Shift+F'+inttostr(int1-bottom+1);
  end;
  bottom:= bottom+functionkeycount;
  for int1:= bottom to bottom+misckeycount-1 do begin
   akey:= keyty(ord(key_escape) + int1-bottom);
   keys[int1]:= ord(akey)or key_modshift;
   names[int1]:= 'Shift+'+misckeynames[akey];
  end;
  bottom:= bottom+misckeycount;
  for int1:= bottom to bottom+cursorkeycount-1 do begin
   akey:= keyty(ord(key_home) + int1-bottom);
   keys[int1]:= ord(akey)or key_modshift;
   names[int1]:= 'Shift+'+cursorkeynames[akey];
  end;
  bottom:= bottom+cursorkeycount;
  getvalues('Ctrl',key_modctrl);
  getvalues('Shift+Ctrl',key_modshiftctrl);
 end;
end;

function getshortcutname(key: shortcutty): msestring;
var
 keys: integerarty;
 names: msestringarty;
 int1,int2: integer;
begin
 int2:= key;
 result:= '';
 getshortcutlist(keys,names);
 for int1:= 0 to high(keys) do begin
  if keys[int1] = int2 then begin
   result:= names[int1];
   break;
  end;
 end;
end;

function getshortcutcode(const info: keyeventinfoty): shortcutty;
begin
 with info do begin
  if (key >= key_0) and (key <= key_9) then begin
   result:= ord(info.keynomod);
  end
  else begin   
   result:= ord(info.key);
  end;
  if ss_shift in info.shiftstate then begin
   result:= result or key_modshift;
  end;
  if ss_ctrl in info.shiftstate then begin
   result:= result or key_modctrl;
  end;
  if ss_alt in info.shiftstate then begin
   result:= result or key_modalt;
  end;
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

procedure actioninfotoshapeinfo(var actioninfo: actioninfoty;
            var shapeinfo: shapeinfoty);
begin
 with actioninfo do begin
  actionstatestoshapestates(actioninfo,shapeinfo.state);
  shapeinfo.caption:= caption1;
  shapeinfo.imagelist:= imagelist;
  shapeinfo.imagenr:= imagenr;
  shapeinfo.imagenrdisabled:= imagenrdisabled;
  shapeinfo.colorglyph:= colorglyph;
  shapeinfo.color:= color;
  shapeinfo.imagecheckedoffset:= imagecheckedoffset;
 end;
end;

procedure actioninfotoshapeinfo(const sender: twidget; var actioninfo: actioninfoty;
                                    var shapeinfo: shapeinfoty);
var
 statebefore: actionstatesty;
begin
 if not (csloading in sender.componentstate) then begin
  with actioninfo do begin
   statebefore:= state;
   if (sender.enabled) <> not (as_disabled in state) then begin
    sender.enabled:= not(as_disabled in state);
   end;
   if (sender.visible) <> not (as_invisible in state) then begin
    sender.visible:= not(as_invisible in state);
   end;
   state:= statebefore; //restore localflag
   actioninfotoshapeinfo(actioninfo,shapeinfo);
   sender.invalidate;
  end;
 end;
end;

procedure calccaptiontext(var info: actioninfoty; const aseparator: msechar);
var
 str1: msestring;
begin
 str1:= info.captiontext;
 if (info.shortcut <> 0) and (mao_shortcutcaption in info.options)
           {and not (as_disabled in info.state)} then begin
{           
  if mao_shortcutright in info.options then begin
   str1:= str1 + c_tab;
  end
  else begin
   str1:= str1 + ' ';
  end;
}
  str1:= str1 + aseparator + '('+getshortcutname(info.shortcut)+')';
 end;
 captiontorichstring(str1,info.caption1);
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
      calccaptiontext(info,sepchar);
     end;
     if not (as_localshortcut in state) then begin
      shortcut:= 0;
      calccaptiontext(info,sepchar);
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
     state:= state - actionstatesty(
                  longword(localactionstatestates) shr localactionlshift);
     sender.actionchanged;
    end;
 {
    if not (as_localimagelist in state) then begin
     setactionimagelist(sender,nil);
    end;
    resetlocalstates(state);
 }
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
 calccaptiontext(po1^,sender.shortcutseparator);
 sender.actionchanged;
end;

function isactioncaptionstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localcaption in state) and
        not ((action = nil) and (captiontext = ''));
 end;
end;

procedure setactionshortcut(const sender: iactionlink; const value: shortcutty);
var
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  shortcut:= value;
  include(state,as_localshortcut);
 end;
 calccaptiontext(po1^,sender.shortcutseparator);
 sender.actionchanged;
end;

function isactionshortcutstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localshortcut in state) and
         not ((action = nil) and (shortcut = ord(key_none)));
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

procedure setactionimagelist(const sender: iactionlink; const value: timagelist);
begin
 with sender.getactioninfopo^ do begin
  if not (as_localimagelist in state) then begin
   imagelist:= nil; //do not unink,imagelist is owned by action
  end;
  setlinkedcomponent(sender,value,tmsecomponent(imagelist));
  include(state,as_localimagelist);
 end;
 sender.actionchanged;
end;

function isactionimageliststored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localimagelist in state) and
         not ((action = nil) and (imagelist = nil));
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
         not ((action = nil) and (colorglyph = cl_glyph));
 end;
end;

function isactioncolorstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localcolor in state) and
         not ((action = nil) and (color = cl_transparent));
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
// obj1: tobject;
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
//   include(state,as_localstate);
   if (mao_shortcutcaption in options) and
           (statebefore * [as_disabled] <> state * [as_disabled]) then begin
    calccaptiontext(po1^,sender.shortcutseparator);
   end;
  end;
//  obj1:= sender.getinstance;
//  if not ((obj1 is tcomponent) and 
//            (csloading in tcomponent(obj1).componentstate)) then begin
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
 mask: menuactionoptionsty = [mao_showhint,mao_noshowhint];
var
 optionsbefore: menuactionoptionsty;
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  optionsbefore:= options;
  options:= menuactionoptionsty(setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(value),
                         {$ifdef FPC}longword{$else}byte{$endif}(options),
                         {$ifdef FPC}longword{$else}byte{$endif}(mask)));
  if optionsbefore * [mao_shortcutcaption] <> options * 
                                     [mao_shortcutcaption] then begin
   calccaptiontext(po1^,sender.shortcutseparator);
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

 {tcustomaction}

constructor tcustomaction.create(aowner: tcomponent);
begin
 initactioninfo(finfo);
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
 imagelist:= nil;
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
procedure tcustomaction.setimagelist(const Value: timagelist);
begin
 if value <> finfo.imagelist then begin
  setlinkedvar(value,tmsecomponent(finfo.imagelist));
  changed;
 end;
end;
{
function tcustomaction.getimagenr: integer;
begin
 result:= finfo.imagenr;
end;
}
procedure tcustomaction.setimagenr(const Value: integer);
begin
 finfo.imagenr:= value;
 changed;
end;

procedure tcustomaction.setimagenrdisabled(const avalue: integer);
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

procedure tcustomaction.setshortcut(const Value: shortcutty);
begin
 finfo.shortcut := Value;
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
   calccaptiontext(po1^,sepchar);
   bo1:= true;
  end;
  if not (as_localshortcut in state) and
              (shortcut <> finfo.shortcut) then begin
   shortcut:= finfo.shortcut;
   calccaptiontext(po1^,sepchar);
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

procedure tcustomaction.doshortcut(const sender: twidget; var info: keyeventinfoty);
begin
 if not (es_local in info.eventstate) and (ao_globalshortcut in foptions) or 
        (es_local in info.eventstate) and (ao_localshortcut in foptions) and
                (owner <> nil) and issubcomponent(owner,sender) then begin
  doupdate;
  if doactionshortcut(self,finfo,info) then begin
   changed;
  end;
 end;
end;

procedure tcustomaction.execute;
begin
 if doactionexecute(self,finfo) then begin
  changed;
 end;
// if assigned(finfo.onexecute) then begin
//  finfo.onexecute(self);
// end;
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
    if [ao_globalshortcut,ao_localshortcut] * value <> [] then begin
     application.registeronshortcut({$ifdef FPC}@{$endif}doshortcut);
    end
    else begin
     application.unregisteronshortcut({$ifdef FPC}@{$endif}doshortcut);
    end;
   end;
  end;
 end;
end;

procedure tcustomaction.dostatread(const reader: tstatreader);
begin
 checked:= reader.readboolean('checked',checked);
end;

procedure tcustomaction.dostatwrite(const writer: tstatwriter);
begin
 writer.writeboolean('checked',checked);
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
// if (tmethod(finfo.onexecute).data = tmethod(ainfo.onexecute).data) and
//    (tmethod(finfo.onexecute).code = tmethod(ainfo.onexecute).code) then begin
  sendchangeevent(oe_fired);
// end;
end;

end.

