unit mseshortcutdialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,msegrids,
 msestrings,msetypes,msewidgetgrid,msedatanodes,mselistbrowser,mseactions,
 msesimplewidgets,msewidgets;
type
 tmseshortcutdialogfo = class(tmseform)
   grid: twidgetgrid;
   sc: ttreeitemedit;
   scdi: tstringedit;
   sc1di: tstringedit;
   tbutton1: tbutton;
   tbutton2: tbutton;
   sc1ed: tstringedit;
   sced: tstringedit;
   defaultbu: tbutton;
   tpopupmenu1: tpopupmenu;
   procedure updaterowvalues(const sender: TObject; const aindex: Integer;
                   const aitem: tlistitem);
   procedure scdikey(const sender: twidget; var info: keyeventinfoty);
   procedure gridcellevent(const sender: TObject; var info: celleventinfoty);
   procedure edactivate(const sender: TObject);
   procedure eddeactivate(const sender: TObject);
   procedure defaultex(const sender: TObject);
   procedure collapseall(const sender: TObject);
   procedure expandall(const sender: TObject);
  private
   fkeyentering: boolean;
   procedure updateedits;
 end;
 
function shortcutdialog(const acontroller: tshortcutcontroller): modalresultty;

implementation
uses
 mseshortcutdialog_mfm,msekeyboard;

type
 tshortcutitem = class(ttreelistedititem)
  private
   fisgroup: boolean;
   fshortcut: shortcutty;
   fshortcut1: shortcutty;
   fshortcutdefault: shortcutty;
   fshortcut1default: shortcutty;
   procedure setshortcut(const avalue: shortcutty);
   procedure setshortcut1(const avalue: shortcutty);
  public
   constructor create(const aitem: tshortcutaction); overload;
   property shortcut: shortcutty read fshortcut write setshortcut;
   property shortcut1: shortcutty read fshortcut1 write setshortcut1;
 end;
 
 tsysshortcutitem = class(tshortcutitem)
  public
   constructor create(const acaption: msestring); overload;
   constructor create(const acontroller: tshortcutcontroller;
                      const aindex: sysshortcutty); overload;
 end;
  
function shortcutdialog(const acontroller: tshortcutcontroller): modalresultty;
var
 fo1: tmseshortcutdialogfo;
 no: tshortcutitem;
 no1: tsysshortcutitem;
 item1: tshortcutaction;
 int1: integer;
 ss1: sysshortcutty;
begin
 fo1:= tmseshortcutdialogfo.create(nil);
 try
  no1:= tsysshortcutitem.create('System');
  for ss1:= low(ss1) to high(ss1) do begin
   no1.add(tsysshortcutitem.create(acontroller,ss1));
  end;
  fo1.sc.itemlist.add(no1);
  with acontroller.actions do begin
   if count > 0 then begin
    if items[0].action <> nil then begin
     no:= tshortcutitem.create(items[0]);
    end
    else begin
     no:= nil;
    end;
    for int1:= 0 to count - 1 do begin
     item1:= items[int1];
     with item1 do begin
      if action = nil then begin
       if no <> nil then begin
        fo1.sc.itemlist.add(no);
       end;
       no:= tshortcutitem.create(item1);
      end
      else begin
       no.add(tshortcutitem.create(item1));
      end;
     end;
    end;
    if no <> nil then begin
     fo1.sc.itemlist.add(no);
    end;
   end;
  end;
  fo1.sc.itemlist.expandall;
  result:= fo1.show(true);
 finally
  fo1.free;
 end; 
end;

{ tshortcutitem }

constructor tshortcutitem.create(const aitem: tshortcutaction);
begin
 inherited create;
 with aitem do begin
  caption:= aitem.dispname;
  fisgroup:= action = nil;
  if action <> nil then begin
   fshortcut:= action.shortcut;
   fshortcut1:= action.shortcut1;
   fshortcutdefault:= shortcutdefault;
   fshortcut1default:= shortcut1default;
  end;
 end;
end;

procedure tshortcutitem.setshortcut(const avalue: shortcutty);
begin
 fshortcut:= avalue;
 change;
end;

procedure tshortcutitem.setshortcut1(const avalue: shortcutty);
begin
 fshortcut1:= avalue;
 change;
end;

{ tsysshortcutitem }

constructor tsysshortcutitem.create(const acaption: msestring);
begin
 inherited create;
 caption:= acaption;
 fisgroup:= true;
end;

constructor tsysshortcutitem.create(const acontroller: tshortcutcontroller;
                                           const aindex: sysshortcutty);
begin
 inherited create;
 caption:= getsysshortcutdispname(aindex);
 with acontroller do begin
  fshortcut:= sysshortcuts[aindex];
  fshortcut1:= sysshortcuts1[aindex];
  fshortcutdefault:= defaultsysshortcuts[aindex];
  fshortcut1default:= defaultsysshortcuts1[aindex];
 end;
end;

{ tmseshortcutdialogfo }
 
procedure tmseshortcutdialogfo.updaterowvalues(const sender: TObject;
               const aindex: Integer; const aitem: tlistitem);
begin
 with tshortcutitem(aitem) do begin
  if fisgroup then begin  
   scdi[aindex]:= '';
   sc1di[aindex]:= '';
  end
  else begin
   scdi[aindex]:= encodeshortcutname(fshortcut);
   sc1di[aindex]:= encodeshortcutname(fshortcut1);
  end;
 end;
end;

procedure tmseshortcutdialogfo.updateedits;
begin
 sced.value:= scdi.value;
 sc1ed.value:= sc1di.value;
end;

procedure tmseshortcutdialogfo.scdikey(const sender: twidget;
               var info: keyeventinfoty);
var
 mstr1: msestring;
 sc1: shortcutty;
begin
 mstr1:= '';
 sc1:= 0;
 with info do begin
  if eventkind = ek_keypress then begin
   fkeyentering:= true;
  end;
  if ss_shift in shiftstate then begin
   mstr1:= mstr1+'Shift+';
   sc1:= sc1 + ord(key_modshift);
  end;   
  if ss_ctrl in shiftstate then begin
   mstr1:= mstr1+'Ctrl+';
   sc1:= sc1 + ord(key_modctrl);
  end;   
  if ss_alt in shiftstate then begin
   mstr1:= mstr1+'Alt+';
   sc1:= sc1 + ord(key_modalt);
  end;   
  case key of
   key_shift,key_alt,key_control: begin
    if eventkind = ek_keyrelease then begin
     if mstr1 = '' then begin
      fkeyentering:= false;
      updateedits;
     end;
    end
    else begin
     tstringedit(sender).value:= mstr1;
    end;
   end
   else begin
    if eventkind = ek_keypress then begin
     fkeyentering:= false;
     sc1:= sc1 + ord(key);
     if isvalidshortcut(sc1) or (keyty(sc1) = key_delete) then begin
      if keyty(sc1) = key_delete then begin
       sc1:= 0;
      end; 
      if sender.tag = 0 then begin
       tshortcutitem(sc.item).shortcut:= sc1;
      end
      else begin
       tshortcutitem(sc.item).shortcut1:= sc1;
      end;
     end;
     updateedits;
    end;
   end;
  end;
 end;
end;

procedure tmseshortcutdialogfo.gridcellevent(const sender: TObject;
               var info: celleventinfoty);
var
 bo1: boolean;
begin
 case info.eventkind of
  cek_focusedcellchanged: begin
   updateedits;
   bo1:= not ((sc.item = nil) or tshortcutitem(sc.item).fisgroup);
   sced.enabled:= bo1;
   sc1ed.enabled:= bo1;
   defaultbu.enabled:= bo1;
  end;
 end;
end;

procedure tmseshortcutdialogfo.edactivate(const sender: TObject);
begin
 with tstringedit(sender) do begin
  frame.colorframe:= cl_red;
 end;
end;

procedure tmseshortcutdialogfo.eddeactivate(const sender: TObject);
begin
 with tstringedit(sender) do begin
  frame.colorframe:= cl_black;
 end;
end;

procedure tmseshortcutdialogfo.defaultex(const sender: TObject);
begin
 with tshortcutitem(sc.item) do begin
  shortcut:= fshortcutdefault;
  shortcut1:= fshortcut1default;
  updateedits;
 end;
end;

procedure tmseshortcutdialogfo.collapseall(const sender: TObject);
begin
 sc.itemlist.collapseall;
end;

procedure tmseshortcutdialogfo.expandall(const sender: TObject);
begin
 sc.itemlist.expandall;
end;

end.
