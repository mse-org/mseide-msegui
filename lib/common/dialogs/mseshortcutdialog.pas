unit mseshortcutdialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
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
   procedure beforedrawnode(const sender: tcol; const canvas: tcanvas;
                   var cellinfo: cellinfoty; var processed: Boolean);
   procedure beforedraw(const sender: tcol; const canvas: tcanvas;
                   var cellinfo: cellinfoty; var processed: Boolean);
   procedure beforedraw1(const sender: tcol; const canvas: tcanvas;
                   var cellinfo: cellinfoty; var processed: Boolean);
   procedure keyhint(const sender: TObject; var info: hintinfoty);
  private
   fkeyentering: boolean;
   frootnodes: treelistedititemarty;
   procedure updateedits;
   procedure checkconflict;
 end;
 
function shortcutdialog(const acontroller: tshortcutcontroller): modalresultty;

implementation
uses
 mseshortcutdialog_mfm,msekeyboard,msedatalist;

const
 errorcolor = cl_ltred;
 
type
 tshortcutitem = class(ttreelistedititem)
  private
   fisgroup: boolean;
   fshortcut: shortcutty;
   fshortcut1: shortcutty;
   fshortcutdefault: shortcutty;
   fshortcut1default: shortcutty;
   fconflict: boolean;
   fconflict1: boolean;
   procedure setshortcut(const avalue: shortcutty);
   procedure setshortcut1(const avalue: shortcutty);
  public
   constructor create(const aitem: tshortcutaction); overload;
   procedure resetconflict;
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
 int1,int2: integer;
 ss1: sysshortcutty;
begin
 fo1:= tmseshortcutdialogfo.create(nil);
 try
  no1:= tsysshortcutitem.create('System');
  for ss1:= low(ss1) to high(ss1) do begin
   no1.add(tsysshortcutitem.create(acontroller,ss1));
  end;
  fo1.sc.itemlist.add(no1);
  additem(pointerarty(fo1.frootnodes),no1);
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
        additem(pointerarty(fo1.frootnodes),no);
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
     additem(pointerarty(fo1.frootnodes),no);
    end;
   end;
  end;
  fo1.sc.itemlist.expandall;
  fo1.checkconflict;
  result:= fo1.show(true);
  if result = mr_ok then begin
   acontroller.sysshortcuts.beginupdate;
   acontroller.sysshortcuts1.beginupdate;
   for ss1:= low(ss1) to high(ss1) do begin
    with tsysshortcutitem(no1[ord(ss1)]) do begin
     acontroller.sysshortcuts[ss1]:= fshortcut;
     acontroller.sysshortcuts1[ss1]:= fshortcut1;
    end;
   end;
   acontroller.sysshortcuts.endupdate;
   acontroller.sysshortcuts1.endupdate;
   fo1.sc.itemlist.expandall;
   int2:= ord(high(ss1)) + 2;
   for int1:= int2 to fo1.grid.rowhigh do begin
    with tshortcutitem(fo1.sc[int1]) do begin
     if not fisgroup then begin
      with acontroller.actions[int1-int2].action do begin
       shortcut:= fshortcut;
       shortcut1:= fshortcut1;
      end;
     end;
    end;
   end;
   acontroller.doafterupdate;
  end;
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

procedure tshortcutitem.resetconflict;
var
 int1: integer;
begin
 fconflict:= false;
 fconflict1:= false;
 for int1:= 0 to count - 1 do begin
  tshortcutitem(fitems[int1]).resetconflict;
 end;
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
 if sc.item <> nil then begin
  with tshortcutitem(sc.item) do begin
   if fisgroup and (fconflict or fconflict1) then begin
    sc.color:= errorcolor;
   end
   else begin
    sc.color:= cl_default;
   end;
  end;
 end;
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
      include(eventstate,es_processed);
     end;
     checkconflict;
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
  cek_buttonrelease: begin
   if iscellclick(info) then begin
    if info.cell.row >= 0 then begin
     if not tshortcutitem(sc.item).fisgroup then begin
      case info.cell.col of
       1: begin
        sced.setfocus;
       end;
       2: begin
        sc1ed.setfocus;
       end;
      end;
     end;
    end;
   end;
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
  checkconflict;
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

procedure tmseshortcutdialogfo.checkconflict;
var
 int1,int2,int3,int4: integer;
 rootnode1: tshortcutitem;
 rootnode2: tshortcutitem;
 node1: tshortcutitem;
 scut,scut1: shortcutty;
 conflict,conflict1: boolean;
begin
 conflict:= false;
 conflict1:= false;
 for int1:= 0 to high(frootnodes) do begin
  tshortcutitem(frootnodes[int1]).resetconflict;
 end;
 for int1:= 0 to high(frootnodes) do begin
  rootnode1:= tshortcutitem(frootnodes[int1]);
  with rootnode1 do begin
   for int2:= 0 to count - 1 do begin
    node1:= tshortcutitem(fitems[int2]);
    with node1 do begin
     scut:= fshortcut;
     scut1:= fshortcut1;
     for int3:= int2 + 1 to rootnode1.count - 1 do begin
             //leafs in current node
      with tshortcutitem(rootnode1.fitems[int3]) do begin
       if (scut <> 0) then begin
        if fshortcut = scut then begin
         node1.fconflict:= true;
         rootnode1.fconflict:= true;
         fconflict:= true;
         conflict:= true;
        end;
        if fshortcut1 = scut then begin
         node1.fconflict:= true;
         conflict:= true;
         rootnode1.fconflict:= true;
         fconflict1:= true;
         conflict1:= true;
        end;
       end;       
       if (scut1 <> 0) then begin
        if fshortcut = scut1 then begin
         node1.fconflict1:= true;
         conflict1:= true;
         rootnode1.fconflict1:= true;
         fconflict:= true;
         conflict:= true;
        end;
        if fshortcut1 = scut1 then begin
         node1.fconflict1:= true;
         conflict1:= true;
         rootnode1.fconflict1:= true;
         fconflict1:= true;
        end;
       end;       
      end;
     end;     
     for int4:= int1+1 to high(frootnodes) do begin
               //remaining nodes
      rootnode2:= tshortcutitem(frootnodes[int4]);       
      for int3:= 0 to rootnode2.count - 1 do begin
       with tshortcutitem(rootnode2.fitems[int3]) do begin
        if (scut <> 0) then begin
         if fshortcut = scut then begin
          node1.fconflict:= true;
          conflict:= true;
          rootnode1.fconflict:= true;
          fconflict:= true;
          rootnode2.fconflict:= true;
         end;
         if fshortcut1 = scut then begin
          node1.fconflict:= true;
          conflict:= true;
          rootnode1.fconflict:= true;
          fconflict1:= true;
          conflict1:= true;
          rootnode2.fconflict1:= true;
         end;
        end;       
        if (scut1 <> 0) then begin
         if fshortcut = scut1 then begin
          node1.fconflict1:= true;
          conflict1:= true;
          rootnode1.fconflict1:= true;
          fconflict:= true;
          conflict:= true;
          rootnode2.fconflict:= true;
         end;
         if fshortcut1 = scut1 then begin
          node1.fconflict1:= true;
          conflict1:= true;
          rootnode1.fconflict1:= true;
          fconflict1:= true;
          rootnode2.fconflict1:= true;
         end;
        end;       
       end;
      end;     
     end;
    end;
   end;
  end; 
 end;
 with grid.fixrows[-1] do begin
  if conflict then begin
   captions[1].font.color:= cl_red;
  end
  else begin
   captions[1].font.color:= cl_text;
  end;
  if conflict1 then begin
   captions[2].font.color:= cl_red;
  end
  else begin
   captions[2].font.color:= cl_text;
  end;
 end;
 grid.invalidate;
 updateedits;
end;

procedure tmseshortcutdialogfo.beforedrawnode(const sender: tcol;
               const canvas: tcanvas; var cellinfo: cellinfoty;
               var processed: Boolean);
begin
 with tshortcutitem(cellinfo.datapo^) do begin
  if fisgroup and (fconflict or fconflict1) then begin
   cellinfo.color:= errorcolor;
  end;
 end;
end;

procedure tmseshortcutdialogfo.beforedraw(const sender: tcol;
               const canvas: tcanvas; var cellinfo: cellinfoty;
               var processed: Boolean);
begin
 with tshortcutitem(sc[cellinfo.cell.row]) do begin
  if not fisgroup then begin
   if fconflict then begin
    cellinfo.color:= errorcolor;
   end
   else begin
    if fshortcut <> fshortcutdefault then begin
     cellinfo.color:= cl_infobackground;
    end;
   end; 
  end;
 end;
end;

procedure tmseshortcutdialogfo.beforedraw1(const sender: tcol;
               const canvas: tcanvas; var cellinfo: cellinfoty;
               var processed: Boolean);
begin
 with tshortcutitem(sc[cellinfo.cell.row]) do begin
  if not fisgroup then begin
   if fconflict1 then begin
    cellinfo.color:= errorcolor;
   end
   else begin
    if fshortcut1 <> fshortcut1default then begin
     cellinfo.color:= cl_infobackground;
    end;
   end;
  end;
 end;
end;

procedure tmseshortcutdialogfo.keyhint(const sender: TObject;
               var info: hintinfoty);
begin
 if not twidget(sender).active then begin
  info.caption:= '';
 end;
end;

end.
