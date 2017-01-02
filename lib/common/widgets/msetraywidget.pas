{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetraywidget; 
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef mswindows}
 {$ifndef mse_no_dbus}
  {$define mse_usedbus} 
 {$endif}
{$endif}
interface
uses
 mseclasses,classes,mclasses,msesimplewidgets,mseguiglob,msebitmap,msegui,
 mseevent,mseglob,msegraphics,msestrings,msetimer,msemenus,msegraphutils
 {$ifdef mse_usedbus},msestatusnotifieritem{$endif};
 
type
 traywidgetoptionty = (two_usedbus);
 traywidgetoptionsty = set of traywidgetoptionty;
 
 ttraywidget = class(teventwidget)
  private
   ficon: tmaskedbitmap;
   ficonchanging: integer;
   fimagelist: timagelist;
   fimagenum: integer;
   fmessageid: longword;
   ftimer: tsimpletimer;
   fcaption: msestring;
   foptions: traywidgetoptionsty;
   fondbusactivate: notifyeventty;
   fondbussecondaryactivate: notifyeventty;
   procedure seticon(const avalue: tmaskedbitmap);
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenum(const avalue: integer);
   procedure setcaption(const avalue: msestring);
   procedure setoptions(const avalue: traywidgetoptionsty);
  protected
  {$ifdef mse_usedbus}
   fstatusnotifieritem: tstatusnotifieritem;
   procedure dbusdocontextmenu(const sender: tstatusnotifieritem;
                                               const apos: pointty);
   procedure dbusdoactivate(const sender: tstatusnotifieritem;
                                               const apos: pointty);
   procedure dbusdosecondaryactivate(const sender: tstatusnotifieritem;
                                               const apos: pointty);
  {$endif} 
  {$ifdef mswindows}
   procedure showhint(const aid: int32; var info: hintinfoty); override;
  {$endif}
   procedure dotimer(const sender: tobject);
   procedure settrayhint;
   procedure sethint(const avalue: msestring); override;
   procedure dopaintforeground(const acanvas: tcanvas); override;
   procedure objectevent(const sender: tobject;
                            const event: objecteventty); override;
   procedure iconchanged(const sender: tobject);
  {$ifdef mse_usedbus}
   function hasdbus: boolean;
  {$endif}
   function dock: boolean; //true if OK
   procedure undock;
   procedure setvisible(const avalue: boolean); override;
   procedure loaded; override;
   procedure updatewindowinfo(var info: windowinfoty) override;
   procedure dopopup(var amenu: tpopupmenu; 
                    var mouseinfo: mouseeventinfoty); override;

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure showmessage(const amessage: msestring;
                                     const timeoutms: integer = 0);
   procedure showmessage(const amessage: msestring; const atitle: msestring;
                                     const timeoutms: integer = 0);
                              //for dbus org.freedesktop.Notifications
   procedure cancelmessage();
  published
   property icon: tmaskedbitmap read ficon write seticon;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagenum: integer read fimagenum write setimagenum default -1;
   property caption: msestring read fcaption write setcaption;
   property options: traywidgetoptionsty read foptions 
                                          write setoptions default [];
   property ondbusactivate: notifyeventty read fondbusactivate write
                                                             fondbusactivate;
   property ondbussecondaryactivate: notifyeventty 
                 read fondbussecondaryactivate write fondbussecondaryactivate;
 end;
 
implementation
uses
 mseguiintf,sysutils,msewidgets;

{ ttraywidget }

constructor ttraywidget.create(aowner: tcomponent);
begin
(*
 {$ifdef mse_usedbus}
 if not (csdesigning in componentstate) then begin
  fstatusnotifieritem:= tstatusnotifieritem.create();
  fstatusnotifieritem.oncontextmenu:= @dbusdocontextmenu;
 end;
 {$endif} 
*)
 fimagenum:= -1;
 ficon:= tcenteredbitmap.create(bmk_rgb{false});
 ficon.onchange:= {$ifdef FPC}@{$endif}iconchanged;
 inherited;
end;

destructor ttraywidget.destroy;
begin
 visible:= false;
 undock();
 freeandnil(ftimer);
 ficon.free;
 inherited;
{$ifdef mse_usedbus}
 fstatusnotifieritem.free();
{$endif} 
end;

procedure ttraywidget.setoptions(const avalue: traywidgetoptionsty);
begin
 if avalue <> foptions then begin
  foptions:= avalue;
 {$ifdef mse_usedbus}
  if (two_usedbus in foptions) and (fstatusnotifieritem = nil) then begin
   fstatusnotifieritem:= tstatusnotifieritem.create();
   fstatusnotifieritem.oncontextmenu:= @dbusdocontextmenu;
   fstatusnotifieritem.onactivate:= @dbusdoactivate;
   fstatusnotifieritem.onsecondaryactivate:= @dbusdosecondaryactivate;
  end
  else begin
   freeandnil(fstatusnotifieritem);
  end;
 {$endif}
 end;
end;

function ttraywidget.dock: boolean;
var
 bo1: boolean;
begin
 result:= true;
{$ifdef mse_usedbus}
 if hasdbus then begin
  //nothing to do
 end
 else begin
{$endif}
  if (parentwidget <> nil) or (window.syscontainer <> sywi_tray) then begin
   bo1:= visible;
   visible:= false;
   parentwidget:= nil;
   try
    window.syscontainer:= sywi_tray;
   except
    result:= false;
    exit;
   end;
   visible:= bo1;
  end;
{$ifdef mse_usedbus}
 end;
{$endif}
end;

procedure ttraywidget.undock;
begin
 if ownswindow then begin
  window.syscontainer:= sywi_none;
 end;
end;

{$ifdef mse_usedbus}
function ttraywidget.hasdbus(): boolean;
begin
 result:= (fstatusnotifieritem <> nil) and 
                                     fstatusnotifieritem.checkdesktop();
end;
{$endif}

procedure ttraywidget.setvisible(const avalue: boolean);
begin
{$ifdef mse_usedbus}
 if (componentstate * [csdesigning,csloading] = []) and 
  (hasdbus and (avalue <> fstatusnotifieritem.active) or
    not hasdbus and (avalue <> visible)) then begin
{$else}
 if (componentstate * [csdesigning,csloading] = []) and 
                                           (avalue <> visible) then begin
{$endif}
  if avalue then begin
   if dock() then begin
    setcaption(fcaption);
    iconchanged(nil);
    settrayhint;
   {$ifdef mse_usedbus}
    if hasdbus then begin
     fstatusnotifieritem.active:= true;
    end
    else begin
   {$endif} 
     inherited;
   {$ifdef mse_usedbus}
    end;
   {$endif}
   end;
  end
  else begin
   cancelmessage();
   {$ifdef mse_usedbus}
    if hasdbus then begin
     fstatusnotifieritem.active:= false;
    end
    else begin
   {$endif}
     inherited;
   {$ifdef mse_usedbus}
    end;
   {$endif}
   undock();
  end;
 end
 else begin
  inherited;
 end;
end;

procedure ttraywidget.loaded;
begin
 if not(csdesigning in componentstate) and visible then begin
  visible:= false;
  inherited;
  if dock() then begin
   visible:= true;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure ttraywidget.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= info.options + [wo_embedded,wo_noframe];
end;

procedure ttraywidget.seticon(const avalue: tmaskedbitmap);
begin
 ficon.assign(avalue);
end;

procedure ttraywidget.settrayhint();
{$ifdef mse_usedbus}
var
 tt1: tooltipinfoty;
{$endif}
begin
{$ifdef mse_usedbus}
 if hasdbus then begin
  tt1.title:= stringtoutf8(hint);
  fstatusnotifieritem.settooltip(tt1);
 end
 else begin
{$endif}
  if ownswindow then begin
   gui_settrayhint(windowpo^,hint);
  end;
{$ifdef mse_usedbus}
 end;
{$endif}
end;

procedure ttraywidget.iconchanged(const sender: tobject);
var
 icon1,mask1: pixmapty;
 bmp1: tmaskedbitmap;
begin
 if not (csloading in componentstate) then begin
  if ficonchanging = 0 then begin
   inc(ficonchanging);
   bmp1:= tmaskedbitmap.create(bmk_rgb{false});
   try
    if (fimagelist = nil) or (fimagenum < 0) then begin
     bmp1.assign(ficon);
    end
    else begin
//     bmp1.masked:= fimagelist.masked;
     fimagelist.getimage(fimagenum,bmp1);
    end;
    invalidate;
    bmp1.colormask:= false;
   {$ifdef mse_usedbus}
    if hasdbus then begin
     fstatusnotifieritem.seticonpixmap(bmp1);
    end
    else begin
   {$endif} 
     if ownswindow and not (csdesigning in componentstate) then begin
      getwindowicon(bmp1,icon1,mask1,true);
      gui_settrayicon(windowpo^,icon1,mask1);
     end;
   {$ifdef mse_usedbus}
    end;
   {$endif}
   finally
    dec(ficonchanging); 
    bmp1.free;
   end;
  end;
 end;
end;

procedure ttraywidget.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 inherited;
 if (sender = fimagelist) and (event = oe_changed) then begin
  iconchanged(nil);
 end;
end;

procedure ttraywidget.setimagelist(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fimagelist));
 iconchanged(nil);
end;

procedure ttraywidget.setimagenum(const avalue: integer);
begin
 if avalue <> fimagenum then begin
  fimagenum:= avalue;
  iconchanged(nil);
 end;
end;

procedure ttraywidget.dopaintforeground(const acanvas: tcanvas);
begin
 inherited;
 if (fimagelist <> nil) and (fimagenum >= 0) then begin
  fimagelist.paint(acanvas,fimagenum,innerclientrect,ficon.alignment);
 end
 else begin
  if not ficon.isempty then begin
   ficon.paint(acanvas,innerclientrect,ficon.alignment);
  end;
 end;
end;

procedure ttraywidget.sethint(const avalue: msestring);
begin
 inherited;
 if not (csloading in componentstate) then begin
  settrayhint;
 end;
end;

procedure ttraywidget.dopopup(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
begin
 {$ifdef mswindows}
 if ownswindow then begin
  gui_settrayhint(windowpo^,'');
  try
   inherited;
  finally
   gui_settrayhint(windowpo^,hint);
  end;
 end
 else begin
  inherited;
 end;
 {$else}
 inherited;
 {$endif}
end;

procedure ttraywidget.showmessage(const amessage: msestring;
                        const atitle: msestring; const timeoutms: integer = 0);
begin
{$ifdef mse_usedbus}
 if visible or hasdbus and fstatusnotifieritem.active then begin
{$else}
 if visible then begin
{$endif}
  cancelmessage;
  if amessage <> '' then begin
  {$ifdef mse_usedbus}
   if hasdbus then begin
    fstatusnotifieritem.showmessage(amessage,atitle,fmessageid,timeoutms);
   end
   else begin
  {$endif}
    gui_traymessage(windowpo^,amessage,fmessageid,timeoutms);
  {$ifdef mse_usedbus}
   end;
  {$endif}
   if timeoutms > 0 then begin
    ftimer:= tsimpletimer.create(timeoutms*1000,{$ifdef FPC}@{$endif}dotimer,
                true,[to_single]);
   end;
  end;
 end;
end;

procedure ttraywidget.showmessage(const amessage: msestring;
               const timeoutms: integer);
begin
 showmessage(amessage,'',timeoutms);
end;

procedure ttraywidget.cancelmessage;
begin
 if fmessageid <> 0 then begin
  freeandnil(ftimer);
 {$ifdef mse_usedbus}
  if hasdbus then begin
   fstatusnotifieritem.cancelmessage(fmessageid);
  end
  else begin
 {$endif}
   gui_canceltraymessage(windowpo^,fmessageid);
 {$ifdef mse_usedbus}
  end;
 {$endif}
  fmessageid:= 0;
 end;
end;

procedure ttraywidget.dotimer(const sender: tobject);
begin
 cancelmessage;
end;

procedure ttraywidget.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 if ownswindow then begin
  window.caption:= fcaption;
 end;
end;

{$ifdef mse_usedbus}
procedure ttraywidget.dbusdocontextmenu(const sender: tstatusnotifieritem;
               const apos: pointty);
begin
 if popupmenu <> nil then begin
  popupmenu.show(nil,apos);
 end;
end;

procedure ttraywidget.dbusdoactivate(const sender: tstatusnotifieritem;
               const apos: pointty);
begin
 if canevent(tmethod(fondbusactivate)) then begin
  fondbusactivate(self);
 end;
end;

procedure ttraywidget.dbusdosecondaryactivate(const sender: tstatusnotifieritem;
               const apos: pointty);
begin
 if canevent(tmethod(fondbussecondaryactivate)) then begin
  fondbussecondaryactivate(self);
 end;
end;
{$endif}

{$ifdef mswindows}
procedure ttraywidget.showhint(const aid: int32; var info: hintinfoty);
begin
 //dummy;
end;
{$endif}

end.
