unit msetraywidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseclasses,classes,msesimplewidgets,mseguiglob,msebitmap,msegui,mseevent,
 mseglob,msegraphics,msestrings;
type
 ttraywidget = class(teventwidget)
  private
   ficon: tmaskedbitmap;
   ficonchanging: integer;
   fimagelist: timagelist;
   fimagenum: integer;
   fmessageid: longword;
   procedure seticon(const avalue: tmaskedbitmap);
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenum(const avalue: integer);
  protected
   procedure settrayhint;
   procedure sethint(const avalue: msestring); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure objectevent(const sender: tobject;
                            const event: objecteventty); override;
   procedure iconchanged(const sender: tobject);
   procedure dock;
   procedure undock;
   procedure setvisible(const avalue: boolean); override;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure showmessage(const amessage: msestring; const timeoutms: integer);
   procedure cancelmessage;
  published
   property icon: tmaskedbitmap read ficon write seticon;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagenum: integer read fimagenum write setimagenum default -1;
 end;
 
implementation
uses
 mseguiintf,sysutils,msewidgets;

{ ttraywidget }

constructor ttraywidget.create(aowner: tcomponent);
begin
 fimagenum:= -1;
 ficon:= tmaskedbitmap.create(false);
 ficon.onchange:= {$ifdef FPC}@{$endif}iconchanged;
 inherited;
end;

destructor ttraywidget.destroy;
begin
 visible:= false;
 ficon.free;
 inherited;
end;

procedure ttraywidget.dock;
begin
 parentwidget:= nil;
 window.syscontainer:= sywi_tray;
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
   dock;
   iconchanged(nil);
   settrayhint;
   inherited;
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
  dock;
  inherited;
  visible:= true;
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
   bmp1:= tmaskedbitmap.create(false);
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

procedure ttraywidget.dopaint(const acanvas: tcanvas);
begin
 inherited;
 if (fimagelist <> nil) and (fimagenum >= 0) then begin
  fimagelist.paint(acanvas,fimagenum,innerclientrect,
                                           [al_xcentered,al_ycentered]);
 end
 else begin
  if not ficon.isempty then begin
   ficon.paint(acanvas,innerclientrect,[al_xcentered,al_ycentered]);
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

procedure ttraywidget.showmessage(const amessage: msestring;
               const timeoutms: integer);
begin
 if visible then begin
  cancelmessage;
  gui_traymessage(windowpo^,amessage,fmessageid,timeoutms);
 end;
end;

procedure ttraywidget.cancelmessage;
begin
 if fmessageid <> 0 then begin
  gui_canceltraymessage(windowpo^,fmessageid);
  fmessageid:= 0;
 end;
end;

end.
