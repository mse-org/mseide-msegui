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
 mseact,mseglob,mseguiglob,msegui,mseevent,mseclasses,msebitmap,msekeyboard,
 msetypes,msestrings;
type
 taction = class(tcustomaction)
  private
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist);
//   function getshortcut: shortcutty;
   procedure setshortcut(const Value: shortcutty);
  protected
   procedure registeronshortcut(const avalue: boolean); override;
   procedure doshortcut(const sender: twidget; var info: keyeventinfoty);
   procedure doafterunlink; override;
  public
  published
   property imagelist: timagelist read getimagelist write setimagelist;
   property shortcut: shortcutty read finfo.shortcut write setshortcut default ord(key_none);
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
   property onupdate;
   property onchange;
   property onasyncevent;
 end;

procedure setactionshortcut(const sender: iactionlink; const value: shortcutty);
function isactionshortcutstored(const info: actioninfoty): boolean;
procedure setactionimagelist(const sender: iactionlink; const value: timagelist);
function isactionimageliststored(const info: actioninfoty): boolean;
 
procedure getshortcutlist(out keys: integerarty; out names: msestringarty);
function getshortcutname(key: shortcutty): msestring;
function checkshortcutcode(const shortcut: shortcutty; const info: keyeventinfoty): boolean;
function doactionshortcut(const sender: tobject; var info: actioninfoty;
                        var keyinfo: keyeventinfoty): boolean; //true if done
procedure calccaptiontext(var info: actioninfoty; const aseparator: msechar);

implementation
uses
 sysutils,mserichstring;
 
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
  if (shortcut <> 0) and not (as_disabled in state) and
                         not (es_processed in keyinfo.eventstate) then begin
   if checkshortcutcode(shortcut,keyinfo) then begin
    doactionexecute(sender,info);
    include(keyinfo.eventstate,es_processed);
    result:= true;
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
procedure taction.setshortcut(const Value: shortcutty);
begin
 finfo.shortcut := Value;
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

end.
