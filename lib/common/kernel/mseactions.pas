{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseactions;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseact,mseglob,mseguiglob,msegui,mseevent,mseclasses,msebitmap,
 msekeyboard,msetypes,msestrings,msearrayprops,msestatfile,msestat;

type
 sysshortcutty = (sho_copy,sho_paste,sho_cut,
                  sho_rowinsert,sho_rowappend,sho_rowdelete);
 sysshortcutaty = array[sysshortcutty] of shortcutty;
 psysshortcutaty = ^sysshortcutaty;
 
 taction = class(tcustomaction)
  private
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist);
   procedure setshortcut(const avalue: shortcutty);
   procedure setshortcut1(const avalue: shortcutty);
  protected
   procedure registeronshortcut(const avalue: boolean); override;
   procedure doshortcut(const sender: twidget; var info: keyeventinfoty);
   procedure doafterunlink; override;
  public
  published
   property imagelist: timagelist read getimagelist write setimagelist;
   property shortcut: shortcutty read finfo.shortcut write setshortcut
                                default ord(key_none);
   property shortcut1: shortcutty read finfo.shortcut1 write setshortcut1
                                default ord(key_none);
   property caption;
   property state;
   property group;
   property tagaction;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
   property statfile;
   property statvarname;
   property options;
   property onexecute;
   property onexecuteaction;
   property onupdate;
   property onchange;
   property onasyncevent;
 end;

 tshortcutaction = class(townedpersistent)
  private
   faction: taction;
   fshortcutdefault: shortcutty;
   fshortcut1default: shortcutty;
   fdispname: msestring;
   fhint: msestring;
   procedure setaction(const avalue: taction);
  published
   property action: taction read faction write setaction;
   property shortcutdefault: shortcutty read fshortcutdefault write fshortcutdefault;
   property shortcut1default: shortcutty read fshortcut1default write fshortcut1default;
   property dispname: msestring read fdispname write fdispname;
   property hint: msestring read fhint write fhint;
 end;

 type
  shortcutrecarty = array of 
                     record 
                      name: string;
                      value: integer;
                     end;

 tshortcutcontroller = class;
 tshortcutactions = class(townedpersistentarrayprop)
  private
  protected
   function getitems(const index: integer): tshortcutaction;
  public
   constructor create(const aowner: tshortcutcontroller); reintroduce;
   class function getitemclasstype: persistentclassty; override;
  public
   property items[const index: integer]: tshortcutaction read getitems;
                                                   default;
 end;

 tsysshortcuts = class(tintegerarrayprop)
  private
   fowner: tcomponent;
   fdatapo: psysshortcutaty;
   fshortcuts: shortcutrecarty;
   function getitems(const index: sysshortcutty): shortcutty;
   procedure setitems(const index: sysshortcutty; const avalue: shortcutty);
   function getshortcutrecord(const index: integer): msestring;
   procedure setshortcutcount(const acount: integer);
   procedure setshortcutrecord(const index: integer; const avalue: msestring);
  protected
   procedure setfixcount(const avalue: integer); override;
   procedure dochange(const aindex: integer); override;
   procedure dostatread(const varname: string; const reader: tstatreader);
   procedure dostatwrite(const varname: string; const writer: tstatwriter);
  public
   constructor create(const aowner: tcomponent; const adatapo: psysshortcutaty);
   property items[const index: sysshortcutty]: shortcutty read getitems 
                       write setitems; default;
 end;
 
 shortcutstatinfoty = record
  name: ansistring;
  shortcut: integer;
  shortcut1: integer;
 end;
 shortcutstatinfoarty = array of shortcutstatinfoty;
 shortcutcontrollereventty = procedure(
                        const sender: tshortcutcontroller) of object;   
 tshortcutcontroller = class(tmsecomponent,istatfile)
  private
   factions: tshortcutactions;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fstatinfos: shortcutstatinfoarty;
   fsysshortcuts: tsysshortcuts;
   fsysshortcuts1: tsysshortcuts;
   fonafterupdate: shortcutcontrollereventty;
   procedure setactions(const avalue: tshortcutactions);
   procedure setstatfile(const avalue: tstatfile);
   function getactionrecord(const index: integer): msestring;
   procedure setactionreccount(const acount: integer);
   procedure setactionrecord(const index: integer; const avalue: msestring);
   procedure setsysshortcuts(const avalue: tsysshortcuts);
   procedure setsysshortcuts1(const avalue: tsysshortcuts);
  protected
   procedure updateaction(const aaction: taction); reintroduce;
   //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure doafterupdate;
  published
   property actions: tshortcutactions read factions write setactions;
   property sysshortcuts: tsysshortcuts read fsysshortcuts write setsysshortcuts;
   property sysshortcuts1: tsysshortcuts read fsysshortcuts1 write setsysshortcuts1;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property onafterupdate: shortcutcontrollereventty read fonafterupdate 
                                write fonafterupdate;
 end;

procedure setactionshortcut(const sender: iactionlink; const value: shortcutty);
procedure setactionshortcut1(const sender: iactionlink; const value: shortcutty);
function isactionshortcutstored(const info: actioninfoty): boolean;
function isactionshortcut1stored(const info: actioninfoty): boolean;
procedure setactionimagelist(const sender: iactionlink; const value: timagelist);
function isactionimageliststored(const info: actioninfoty): boolean;
 
procedure getshortcutlist(out keys: integerarty; out names: msestringarty);
function getshortcutname(key: shortcutty): msestring;
function getsysshortcutdispname(const aitem: sysshortcutty): msestring;

function isvalidshortcut(const ashortcut: shortcutty): boolean;
function encodeshortcutname(const key: shortcutty): msestring;
function checkshortcutcode(const shortcut: shortcutty; const info: keyeventinfoty): boolean;
function doactionshortcut(const sender: tobject; var info: actioninfoty;
                        var keyinfo: keyeventinfoty): boolean; //true if done
procedure calccaptiontext(var info: actioninfoty; const aseparator: msechar);
function issysshortcut(const ashortcut: sysshortcutty;
                                  const ainfo: keyeventinfoty): boolean;
const
 shift = ord(key_modshift);
 ctrl = ord(key_modctrl);
 alt = ord(key_modalt);
 modmask = shift or ctrl or alt;

 defaultsysshortcuts: sysshortcutaty = 
//sho_copy,            sho_paste,                 sho_cut,   
 (ctrl+ord(key_c),     ctrl+ord(key_v),           ctrl+ord(key_x),
//sho_rowinsert,       sho_rowappend,             sho_rowdelete
  ctrl+ord(key_insert),shift+ctrl+ord(key_insert),ctrl+ord(key_delete));

 defaultsysshortcuts1: sysshortcutaty = 
//sho_copy,            sho_paste,                 sho_cut,   
 (ord(key_none),       shift+ord(key_insert),     shift+ord(key_delete),
//sho_rowinsert,       sho_rowappend,             sho_rowdelete
  ord(key_none),       ord(key_none),             ord(key_none));
var
 sysshortcuts: sysshortcutaty;
 sysshortcuts1: sysshortcutaty;
implementation
uses
 sysutils,mserichstring,msestream,typinfo,mseformatstr;
 
const   
 letterkeycount = ord('z') - ord('a') + 1;
 cipherkeycount = ord('9') - ord('0') + 1;
 functionkeycount = 12;
 misckeycount = ord(key_sysreq) - ord(key_escape) + 1;
 cursorkeycount = ord(key_pagedown) - ord(key_home) + 1;
 specialshortcutcount = ord(high(specialshortcutty))+1;
 specialkeycount = misckeycount + specialshortcutcount + cursorkeycount;
 shortcutcount = (letterkeycount + cipherkeycount) * 2 + //ctrl,shiftctrl
                 3 + //space
                 functionkeycount * 4 +              //none,shift,ctrl,shiftctrl
                 specialkeycount * 4;                //none,shift,ctrl,shiftctrl
 baseshortcutcount = letterkeycount + cipherkeycount + 1 + //Space
                     functionkeycount + specialkeycount;
var
 shortcutkeys: integerarty;
 shortcutnames: msestringarty;
 baseshortcutkeys: integerarty;
 baseshortcutnames: msestringarty;

function issysshortcut(const ashortcut: sysshortcutty;
                                 const ainfo: keyeventinfoty): boolean;
begin
 result:= checkshortcutcode(sysshortcuts[ashortcut],ainfo) or
                           checkshortcutcode(sysshortcuts1[ashortcut],ainfo);
end;

procedure getvalues(var bottom: integer; const prefix: msestring;
            const modvalue: integer; var keys: integerarty; 
            var names: msestringarty);
var
 int1: integer;
 akey: keyty;
begin
 keys[bottom]:= ord(key_space) + modvalue;
 names[bottom]:= prefix+'+'+spacekeyname;
 inc(bottom);
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
  names[int1]:= prefix+'+'+shortmisckeynames[akey];
 end;
 bottom:= bottom+misckeycount;
 for int1:= bottom to bottom+specialshortcutcount-1 do begin
  keys[int1]:= ord(specialkeys[specialshortcutty(int1-bottom)]) or modvalue;
  names[int1]:= prefix+'+'+specialkeynames[specialshortcutty(int1-bottom)];
 end;
 bottom:= bottom+specialshortcutcount;
 for int1:= bottom to bottom+cursorkeycount-1 do begin
  akey:= keyty(ord(key_home) + int1-bottom);
  keys[int1]:= ord(akey)or modvalue;
  names[int1]:= prefix+'+'+shortcursorkeynames[akey];
 end;
 bottom:= bottom+cursorkeycount;
end;

procedure getshortcutlist(out keys: integerarty; out names: msestringarty);
var
 int1: integer;
 bo1: boolean;
 bottom: integer;
 akey: keyty;
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
   names[int1]:= shortmisckeynames[akey];
  end;
  bottom:= bottom+misckeycount;
  for int1:= bottom to bottom+specialshortcutcount-1 do begin
   keys[int1]:= ord(specialkeys[specialshortcutty(int1-bottom)]);
   names[int1]:= specialkeynames[specialshortcutty(int1-bottom)];
  end;
  for int1:= bottom to bottom+cursorkeycount-1 do begin
   akey:= keyty(ord(key_home) + int1-bottom);
   keys[int1]:= ord(akey);
   names[int1]:= shortcursorkeynames[akey];
  end;
  bottom:= bottom+cursorkeycount;
  for int1:= bottom to bottom + functionkeycount - 1 do begin
   keys[int1]:= (ord(key_f1) + int1-bottom) or key_modshift;
   names[int1]:= 'Shift+F'+inttostr(int1-bottom+1);
  end;
  bottom:= bottom+functionkeycount;
  keys[bottom]:= ord(key_space) or key_modshift;
  names[bottom]:= 'Shift+'+spacekeyname;
  inc(bottom);
  for int1:= bottom to bottom+misckeycount-1 do begin
   akey:= keyty(ord(key_escape) + int1-bottom);
   keys[int1]:= ord(akey)or key_modshift;
   names[int1]:= 'Shift+'+shortmisckeynames[akey];
  end;
  bottom:= bottom+misckeycount;
  for int1:= bottom to bottom+specialshortcutcount-1 do begin
   keys[int1]:= ord(specialkeys[specialshortcutty(int1-bottom)]) or key_modshift;
   names[int1]:= 'Shift+'+specialkeynames[specialshortcutty(int1-bottom)];
  end;
  bottom:= bottom+specialshortcutcount;
  for int1:= bottom to bottom+cursorkeycount-1 do begin
   akey:= keyty(ord(key_home) + int1-bottom);
   keys[int1]:= ord(akey)or key_modshift;
   names[int1]:= 'Shift+'+shortcursorkeynames[akey];
  end;
  bottom:= bottom+cursorkeycount;
  getvalues(bottom,'Ctrl',key_modctrl,keys,names);
  getvalues(bottom,'Shift+Ctrl',key_modshiftctrl,keys,names);
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

//todo: internationalize
function getsysshortcutdispname(const aitem: sysshortcutty): msestring;
const
 list: array[sysshortcutty] of msestring = (
        'Copy','Paste','Cut','Row insert','Row append','Row delete');
begin
 result:= list[aitem];
end;

function isnormalkey(const akey: shortcutty): boolean;
begin
 result:= (akey >= ord(key_0)) and (akey <= ord(key_9)) or
          (akey >= ord(key_a)) and (akey <= ord(key_z)) or
          (akey = ord(key_left)) or
          (akey = ord(key_right)) or
          (akey = ord(key_up)) or
          (akey = ord(key_down)) or
          (akey = ord(key_tab)) or
          (akey = ord(key_space)) or
          (akey = ord(key_return)) or
          (akey = ord(key_enter));
end;

function isnormalshiftkey(const akey: shortcutty): boolean;
begin
 result:= (akey >= ord(key_0)) and (akey <= ord(key_9)) or
          (akey >= ord(key_a)) and (akey <= ord(key_z)) or
          (akey = ord(key_tab));
end;

function isvalidshortcut(const ashortcut: shortcutty): boolean;
var
 key: word;
begin
 key:= ashortcut and not modmask;
 result:= key <> 0;
 if result then begin
  if ashortcut and modmask = 0 then begin
   result:= not isnormalkey(key);
  end
  else begin
   if ashortcut and modmask = shift then begin
    result:= not isnormalshiftkey(key);
   end;
  end;
 end;
end;

function encodeshortcutname(const key: shortcutty): msestring;
var
 bo1: boolean;
 int1: integer;
 k1: shortcutty;
 mstr1: msestring;
begin
 bo1:= false;
 if baseshortcutkeys = nil then begin
  setlength(baseshortcutkeys,baseshortcutcount);
  bo1:= true;
 end;
 if baseshortcutnames = nil then begin
  setlength(baseshortcutnames,baseshortcutcount);
  bo1:= true;
 end;
 if bo1 then begin
  int1:= 0;
  getvalues(int1,'',0,baseshortcutkeys,baseshortcutnames);
  for int1:= 0 to high(baseshortcutnames) do begin
   baseshortcutnames[int1]:= copy(baseshortcutnames[int1],2,bigint);
           //remove '+'
  end;
 end;
 k1:= key and not modmask;
 mstr1:= '';
 for int1:= 0 to high(baseshortcutkeys) do begin
  if baseshortcutkeys[int1] = k1 then begin
   mstr1:= baseshortcutnames[int1];
   break;
  end;
 end;
 if mstr1 = '' then begin
  if key = 0 then begin
   result:= '';
  end
  else begin
   result:= '$'+hextostr(key,4);
  end;
 end
 else begin
  result:= '';
  if (key and shift) <> 0 then begin
   result:= result + 'Shift+';
  end;
  if (key and alt) <> 0 then begin
   result:= result + 'Alt+';
  end;
  if (key and ctrl) <> 0 then begin
   result:= result + 'Ctrl+';
  end;
  result:= result + mstr1;
 end;
end;

procedure calccaptiontext(var info: actioninfoty; const aseparator: msechar);
var
 str1: msestring;
begin
 str1:= info.captiontext;
 if (info.shortcut <> 0) and (mao_shortcutcaption in info.options) then begin
  str1:= str1 + aseparator + '('+getshortcutname(info.shortcut)+')';
 end;
 captiontorichstring(str1,info.caption1);
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

procedure setactionshortcut1(const sender: iactionlink; const value: shortcutty);
var
 po1: pactioninfoty;
begin
 po1:= sender.getactioninfopo;
 with po1^ do begin
  shortcut1:= value;
  include(state,as_localshortcut1);
 end;
// calccaptiontext(po1^,sender.shortcutseparator);
 sender.actionchanged;
end;

function isactionshortcutstored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localshortcut in state) and
         not ((action = nil) and (shortcut = ord(key_none)));
 end;
end;

function isactionshortcut1stored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localshortcut1 in state) and
         not ((action = nil) and (shortcut = ord(key_none)));
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

function checkshortcutcode(const shortcut: shortcutty;
                             const info: keyeventinfoty): boolean;
var
 acode: shortcutty;
begin
 result:= false;
 if shortcut <> 0 then begin
  with info do begin
   acode:= 0;
   if ss_shift in info.shiftstate then begin
    acode:= acode or key_modshift;
   end;
   if ss_ctrl in info.shiftstate then begin
    acode:= acode or key_modctrl;
   end;
   if ss_alt in info.shiftstate then begin
    acode:= acode or key_modalt;
   end;
   result:= (acode or ord(info.key) = shortcut) or 
            (acode or ord(info.keynomod) = shortcut);
  end;
 end;
end;

function getshortcutcodenomod(const info: keyeventinfoty): shortcutty;
begin
 with info do begin
  result:= ord(info.keynomod);
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

function doactionshortcut(const sender: tobject; var info: actioninfoty;
                        var keyinfo: keyeventinfoty): boolean;
                          //true if done
var
 key: word;
begin
 result:= false;
 with info do begin
  if not (as_disabled in state) and 
           not (es_processed in keyinfo.eventstate) then begin
   if shortcut <> 0 then begin
    if checkshortcutcode(shortcut,keyinfo) then begin
     doactionexecute(sender,info);
     result:= true;
    end;
   end;
   if not result then begin
    if shortcut1 <> 0 then begin
     if checkshortcutcode(shortcut1,keyinfo) then begin
      doactionexecute(sender,info);
      result:= true;
     end;
    end;
   end;
   if result then begin
    include(keyinfo.eventstate,es_processed);
   end;
  end;
 end;
end;

{ taction }

function taction.getimagelist: timagelist;
begin
 result:= timagelist(finfo.imagelist);
end;

procedure taction.setimagelist(const Value: timagelist);
begin
 if value <> finfo.imagelist then begin
  setlinkedvar(value,tmsecomponent(finfo.imagelist));
  changed;
 end;
end;
{
function taction.getshortcut: shortcutty;
begin
 result:= shortcutty(finfo.shortcut);
end;
}
procedure taction.setshortcut(const avalue: shortcutty);
begin
 finfo.shortcut:= avalue;
 changed;
end;

procedure taction.setshortcut1(const avalue: shortcutty);
begin
 finfo.shortcut1:= avalue;
 changed;
end;

procedure taction.registeronshortcut(const avalue: boolean);
begin
 if avalue then begin
  application.registeronshortcut({$ifdef FPC}@{$endif}doshortcut);
 end
 else begin
  application.unregisteronshortcut({$ifdef FPC}@{$endif}doshortcut);
 end;
end;

procedure taction.doshortcut(const sender: twidget; var info: keyeventinfoty);
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

procedure taction.doafterunlink;
begin
 imagelist:= nil;
end;

{ tshortcutactions }

constructor tshortcutactions.create(const aowner: tshortcutcontroller);
begin
 inherited create(aowner,tshortcutaction);
end;

class function tshortcutactions.getitemclasstype: persistentclassty;
begin
 result:= tshortcutaction;
end;

function tshortcutactions.getitems(const index: integer): tshortcutaction;
begin
 result:= tshortcutaction(inherited getitems(index));
end;

{ tshortcutcontroller }

constructor tshortcutcontroller.create(aowner: tcomponent);
begin
 factions:= tshortcutactions.create(self);
 fsysshortcuts:= tsysshortcuts.create(self,@mseactions.sysshortcuts);
 fsysshortcuts1:= tsysshortcuts.create(self,@mseactions.sysshortcuts1);
 inherited;
end;

destructor tshortcutcontroller.destroy;
begin
 inherited;
 factions.free;
 fsysshortcuts.free;
 fsysshortcuts1.free;
end;

procedure tshortcutcontroller.setactions(const avalue: tshortcutactions);
begin
 factions.assign(avalue);
end;

procedure tshortcutcontroller.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tshortcutcontroller.setactionreccount(const acount: integer);
begin
 fstatinfos:= nil;
 setlength(fstatinfos,acount);
end;

procedure tshortcutcontroller.setactionrecord(const index: integer;
               const avalue: msestring);
begin
 with fstatinfos[index] do begin
  decoderecord(avalue,[@name,@shortcut,@shortcut1],'sii');
 end;
end;

procedure tshortcutcontroller.dostatread(const reader: tstatreader);
begin
 fsysshortcuts.dostatread('sysshortcuts',reader);
 fsysshortcuts1.dostatread('sysshortcuts1',reader);
 reader.readrecordarray('shortcuts',{$ifdef FPC}@{$endif}setactionreccount,
           {$ifdef FPC}@{$endif}setactionrecord);
end;

function tshortcutcontroller.getactionrecord(const index: integer): msestring;
begin
 with tshortcutaction(factions[index]) do begin
  if action <> nil then begin
   result:= encoderecord([ownernamepath(action),integer(action.shortcut),
                       integer(action.shortcut1)]);
  end
  else begin
   result:= '';
  end;
 end;
end;

procedure tshortcutcontroller.dostatwrite(const writer: tstatwriter);
begin
 fsysshortcuts.dostatwrite('sysshortcuts',writer);
 fsysshortcuts1.dostatwrite('sysshortcuts1',writer);
 writer.writerecordarray('shortcuts',factions.count,
                               {$ifdef FPC}@{$endif}getactionrecord);
end;

procedure tshortcutcontroller.statreading;
begin
 //dummy
end;

procedure tshortcutcontroller.doafterupdate;
begin
 if canevent(tmethod(fonafterupdate)) then begin
  fonafterupdate(self);
 end;
end;

procedure tshortcutcontroller.statread;
var
 int1: integer;
begin
 for int1:= 0 to factions.count - 1 do begin
  with factions[int1] do begin
   if action <> nil then begin
    updateaction(action);
   end;
  end;
 end;
 doafterupdate;
end;

function tshortcutcontroller.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tshortcutcontroller.updateaction(const aaction: taction);
var
 int1: integer;
 str1: ansistring;
begin
 str1:= ownernamepath(aaction);
 for int1:= 0 to high(fstatinfos) do begin
  with fstatinfos[int1] do begin
   if str1 = name then begin
    aaction.shortcut:= shortcut;
    aaction.shortcut1:= shortcut1;
   end;
  end;
 end;
end;

procedure tshortcutcontroller.setsysshortcuts(const avalue: tsysshortcuts);
begin
 fsysshortcuts.assign(avalue);
end;

procedure tshortcutcontroller.setsysshortcuts1(const avalue: tsysshortcuts);
begin
 fsysshortcuts1.assign(avalue);
end;

{ tshortcutaction }

procedure tshortcutaction.setaction(const avalue: taction);
begin
 with tshortcutcontroller(fowner) do begin
  setlinkedvar(avalue,tmsecomponent(faction));
  if (avalue <> nil) then begin
   if csdesigning in componentstate then begin
    shortcutdefault:= avalue.shortcut;
    shortcut1default:= avalue.shortcut1;
   end
   else begin
    updateaction(avalue);
   end;
  end;
 end;  
end;

{ tsysshortcuts }

constructor tsysshortcuts.create(const aowner: tcomponent;
            const adatapo: psysshortcutaty);
var
 sc1: sysshortcutty;
begin
 inherited create;
 inherited setfixcount(ord(high(sysshortcutty))+1);
 fowner:= aowner;
 fdatapo:= adatapo;
 for sc1:= low(sc1) to high(sc1) do begin
  fitems[ord(sc1)]:= ord(fdatapo^[sc1]); //init with current values
 end;
end;

function tsysshortcuts.getitems(const index: sysshortcutty): shortcutty;
begin
 result:= inherited getitems(ord(index));
end;

procedure tsysshortcuts.setitems(const index: sysshortcutty;
               const avalue: shortcutty);
begin
 inherited setitems(ord(index),ord(avalue));
end;

procedure tsysshortcuts.setfixcount(const avalue: integer);
begin
 //dummy
end;

procedure tsysshortcuts.dochange(const aindex: integer);
var
 sc1: sysshortcutty;
begin
 inherited;
 if (fowner <> nil) and not (csdesigning in fowner.componentstate) then begin
  if aindex < 0 then begin
   for sc1:= low(sc1) to high(sc1) do begin
    fdatapo^[sc1]:= fitems[ord(sc1)];
   end;
  end
  else begin
   fdatapo^[sysshortcutty(aindex)]:= fitems[aindex];
  end;
 end;
end;

procedure tsysshortcuts.setshortcutcount(const acount: integer);
begin
 setlength(fshortcuts,count);
end;

procedure tsysshortcuts.setshortcutrecord(const index: integer;
               const avalue: msestring);
begin
 with fshortcuts[index] do begin
  decoderecord(avalue,[@name,@value],'si');
 end;
end;

procedure tsysshortcuts.dostatread(const varname: string;
               const reader: tstatreader);
var
 int1,int2: integer;
begin
 fshortcuts:= nil;
 reader.readrecordarray(varname,{$ifdef FPC}@{$endif}setshortcutcount,
           {$ifdef FPC}@{$endif}setshortcutrecord);
 for int1:= 0 to high(fshortcuts) do begin
  with fshortcuts[int1] do begin
   int2:= getenumvalue(typeinfo(sysshortcutty),name);
   if int2 >= 0 then begin
    items[sysshortcutty(int2)]:= value;
   end;
  end;
 end;
 fshortcuts:= nil;
end;

function tsysshortcuts.getshortcutrecord(const index: integer): msestring;
begin
 result:= encoderecord([getenumname(typeinfo(sysshortcutty),index),fitems[index]]);
end;

procedure tsysshortcuts.dostatwrite(const varname: string;
               const writer: tstatwriter);
begin
 writer.writerecordarray(varname,count,
                               {$ifdef FPC}@{$endif}getshortcutrecord);
end;

initialization
 sysshortcuts:= defaultsysshortcuts; 
 sysshortcuts1:= defaultsysshortcuts1; 
finalization
end.
