{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetraywidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseclasses,classes,mclasses,msesimplewidgets,mseguiglob,msebitmap,msegui,mseevent,
 mseglob,msegraphics,msestrings,msetimer,msemenus;
type
 ttraywidget = class(teventwidget)
  private
   ficon: tmaskedbitmap;
   ficonchanging: integer;
   fimagelist: timagelist;
   fimagenum: integer;
   fmessageid: longword;
   ftimer: tsimpletimer;
   fcaption: msestring;
   procedure seticon(const avalue: tmaskedbitmap);
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenum(const avalue: integer);
   procedure setcaption(const avalue: msestring);
  protected
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
   function dock: boolean; //true if OK
   procedure undock;
   procedure setvisible(const avalue: boolean); override;
   procedure loaded; override;
   procedure dopopup(var amenu: tpopupmenu; 
                    var mouseinfo: mouseeventinfoty); override;

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure showmessage(const amessage: msestring; const timeoutms: integer = 0);
   procedure cancelmessage;
  published
   property icon: tmaskedbitmap read ficon write seticon;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagenum: integer read fimagenum write setimagenum default -1;
   property caption: msestring read fcaption write setcaption;
 end;
 
implementation
uses
 mseguiintf,sysutils,msewidgets;

{ ttraywidget }

constructor ttraywidget.create(aowner: tcomponent);
begin
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
end;

function ttraywidget.dock: boolean;
var
 bo1: boolean;
begin
 result:= true;
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
end;

procedure ttraywidget.undock;
begin
 if ownswindow then begin
  window.syscontainer:= sywi_none;
 end;
end;

procedure ttraywidget.setvisible(const avalue: boolean);
begin
 if (componentstate * [csdesigning,csloading] = []) and 
                                           (avalue <> visible) then begin
  if avalue then begin
   if dock() then begin
    setcaption(fcaption);
    iconchanged(nil);
    settrayhint;
    inherited;
   end;
  end
  else begin
   cancelmessage;
   inherited;
   undock;
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

procedure ttraywidget.seticon(const avalue: tmaskedbitmap);
begin
 ficon.assign(avalue);
end;

procedure ttraywidget.settrayhint;
begin
 if ownswindow then begin
  gui_settrayhint(windowpo^,hint);
 end;
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
     bmp1.masked:= fimagelist.masked;
     fimagelist.getimage(fimagenum,bmp1);
    end;
    invalidate;
    bmp1.colormask:= false;
    if ownswindow and not (csdesigning in componentstate) then begin
     getwindowicon(bmp1,icon1,mask1,true);
     gui_settrayicon(windowpo^,icon1,mask1);
    end;
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
               const timeoutms: integer);
begin
 if visible then begin
  cancelmessage;
  if amessage <> '' then begin
   gui_traymessage(windowpo^,amessage,fmessageid,timeoutms);
   if timeoutms > 0 then begin
    ftimer:= tsimpletimer.create(timeoutms*1000,{$ifdef FPC}@{$endif}dotimer,
                true,[to_single]);
   end;
  end;
 end;
end;

procedure ttraywidget.cancelmessage;
begin
 if fmessageid <> 0 then begin
  freeandnil(ftimer);
  gui_canceltraymessage(windowpo^,fmessageid);
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

{$ifdef mswindows}
procedure ttraywidget.showhint(const aid: int32; var info: hintinfoty);
begin
 //dummy;
end;
{$endif}

end.
