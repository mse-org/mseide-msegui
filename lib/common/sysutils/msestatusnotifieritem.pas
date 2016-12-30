 { MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
// for internal use in MSEgui only
//
unit msestatusnotifieritem;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedbusinterface,msestrings,msetypes,msebitmap,msedbus,msegraphutils,
 mseevent;
type
 desktopkindty = (desk_none,desk_freedesktop,desk_kde);

 iconpixmapty = record
  cx,cy: int32;
  data: bytearty;
 end;
 iconpixmaparty = array of iconpixmapty;
 
 tooltipinfoty = record
  iconname: string;
  iconpixmap: array of iconpixmapty;
  title: string;
  text: string;
 end;
 tooltipinfoarty = array of tooltipinfoty; 
                       //workaround in order to get item typeinfo

 statusnotifiercategoryty = (snc_applicationstatus,snc_communications,
                             snc_systemservices,snc_hardware);
 tstatusnotifieritem = class;
 statusnotifierposprocty = procedure(const sender: tstatusnotifieritem;
                                               const apos: pointty) of object;
 tstatusnotifieritem = class(tdbusobject)
  private
   fstatuscategory: statusnotifiercategoryty;
   fid: string;
   fid1: string; //possibly updated from applicationname
   ftitle: string;
   fstatus: string;
   fwindowid: int32;
   ficonname: string;
   ficonpixmap: iconpixmaparty;
   foverlayiconname: string;
   foverlayiconpixmap: iconpixmaparty;
   fatentioniconname: string;
   fatentioniconpixmap: iconpixmaparty;
   fatentionmoviename: string;
   ftooltip: tooltipinfoty;
   factive: boolean;
   foncontextmenu: statusnotifierposprocty;
   fonactivate: statusnotifierposprocty;
   fmessageid: card32;
   function getcategory: string;
   function getid: string;
   procedure setactive(const avalue: boolean);
  protected
   fdesktopkind: desktopkindty;
   function getintrospectitems(): string override;
   function getpath(): string override;
   procedure busconnected() override;
   procedure propertiesget(var props: dictentryarty) override;
   procedure propertyget(const amessage: pdbusmessage;
                   const aname: string; var avalue: variantvaluety) override;
   function getpropintf: string override;
   procedure registeritems(const sender: idbusservice) override;
   procedure contextmenu(const amessage: pdbusmessage; const adata: pointer;
                                                        var ahandled: boolean);
   procedure activate(const amessage: pdbusmessage; const adata: pointer;
                                                        var ahandled: boolean);
   procedure secondaryactivate(const amessage: pdbusmessage; const adata: pointer;
                                                        var ahandled: boolean);
   procedure scroll(const amessage: pdbusmessage; const adata: pointer;
                                                        var ahandled: boolean);
   function checkdesktop(): boolean;
   procedure receiveevent(const event: tobjectevent) override;
  public
   constructor create();
   destructor destroy(); override;
   property desktopkind: desktopkindty read fdesktopkind;
   function showmessage(const message: msestring; const title: msestring;
                          out messageid: card32;
                          const timeoutms: card32 = 0): boolean;
   function cancelmessage(const messageid: card32): boolean;

   property active: boolean read factive write setactive;
   property statuscategory: statusnotifiercategoryty read fstatuscategory
                         write fstatuscategory default snc_applicationstatus;
   procedure setToolTip(const avalue: tooltipinfoty);
   procedure setId(const avalue: string); //'' -> applicationname
   procedure setTitle(const avalue: string);
   procedure setStatus(const avalue: string);
   procedure setWindowId(const avalue: int32);
   procedure setIconName(const avalue: string);
   procedure setIconPixmap(const avalue: tmaskedbitmap);
   procedure setIconPixmap(const avalue: iconpixmaparty);
   procedure setOverlayIconName(const avalue: string);
   procedure setOverlayIconPixmap(const avalue: iconpixmaparty);
   procedure setAtentionIconName(const avalue: string);
   procedure setAtentionIconPixmap(const avalue: iconpixmaparty);
   procedure setAtentionMovieName(const avalue: string);
   property ToolTip: tooltipinfoty read ftooltip;
   property oncontextmenu: statusnotifierposprocty read foncontextmenu 
                                                        write foncontextmenu;
   property onactivate: statusnotifierposprocty read fonactivate 
                                                        write fonactivate;
  published
   property Category: string read getcategory;
   property Id: string read getid;
   property Title: string read ftitle;
   property Status: string read fstatus;
   property WindowId: int32 read fwindowid;
   property IconName: string read ficonname;
   property IconPixmap: iconpixmaparty read ficonpixmap;
   property OverlayIconName: string read foverlayiconname;
   property OverlayIconPixmap: iconpixmaparty read foverlayiconpixmap;
   property AtentionIconName: string read fatentioniconname;
   property AtentionIconPixmap: iconpixmaparty read fatentioniconpixmap;
   property AtentionMovieName: string read fatentionmoviename;
 end;

function bitmaptoiconpixmap(const abitmap: tmaskedbitmap): iconpixmapty;

implementation
uses
 mseapplication,msegraphics,sysutils;
type
 dbuspixelty = packed record a,r,g,b: card8 end; //in network byte order
 pdbuspixelty = ^dbuspixelty;
 
function bitmaptoiconpixmap(const abitmap: tmaskedbitmap): iconpixmapty;
var
 p1: pdbuspixelty;
 p1a: prgbtriplety;
 p2: pcard8;
 pe: pointer;
 bmp1: tmaskedbitmap;
 i1: int32;
begin
 bmp1:= tmaskedbitmap.create(abitmap.kind);
 bmp1.assign(abitmap);
 bmp1.kind:= bmk_rgb;
 with result do begin
  cx:= abitmap.width;
  cy:= abitmap.height;
  setlength(data,cx*cy*4);
  if (cx <> 0) and (cy <> 0) then begin
   p1:= pdbuspixelty(pointer(data));
   p1a:= bmp1.scanline[0];
   if bmp1.masked then begin
    bmp1.graymask:= true;
    for i1:= 0 to cy-1 do begin
     p2:= bmp1.mask.scanline[i1];
     pe:= p2+cx;
     while p2 < pe do begin
      p1^.r:= p1a^.red;
      p1^.g:= p1a^.green;
      p1^.b:= p1a^.blue;
      p1^.a:= p2^;
      inc(p1);
      inc(p1a);
      inc(p2);
     end;
    end;
   end
   else begin
    p1:= pdbuspixelty(pointer(data));
    pe:= p1 + cx*cy;
    while p1 < pe do begin
     p1^.r:= p1a^.red;
     p1^.g:= p1a^.green;
     p1^.b:= p1a^.blue;
     p1^.a:= $ff;
     inc(p1);
     inc(p1a);
    end;
   end;
  end;
  {
  p1:= pdbuspixelty(pointer(data));
  pe:= p1 + cx*cy;
  while p1 < pe do begin
   swapendian(card32(p1^));
   inc(p1);
  end;
  }
 end;
 bmp1.free;
end;

const
 datadef1 =
'<interface name="';
 datadef2 =
'">'+lineend+
''+lineend+
'  <property name="Category" type="s" access="read"/>'+lineend+
'  <property name="Id" type="s" access="read"/>'+lineend+
'  <property name="Title" type="s" access="read"/>'+lineend+
'  <property name="Status" type="s" access="read"/>'+lineend+
'  <property name="WindowId" type="i" access="read"/>'+lineend+
//'  <property name="IconThemePath" type="s" access="read"/>'+lineend+
//'  <property name="Menu" type="o" access="read"/>'+lineend+
//'  <property name="ItemIsMenu" type="b" access="read"/>'+lineend+
'  <property name="IconName" type="s" access="read"/>'+lineend+
'  <property name="IconPixmap" type="a(iiay)" access="read"/>'+lineend+
//'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="IconPixmapList"/>'+lineend+
//'  </property>'+lineend+
'  <property name="OverlayIconName" type="s" access="read"/>'+lineend+
'  <property name="OverlayIconPixmap" type="a(iiay)" access="read"/>'+lineend+
//'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="IconPixmapList"/>'+lineend+
//'  </property>'+lineend+
'  <property name="AttentionIconName" type="s" access="read"/>'+lineend+
'  <property name="AttentionIconPixmap" type="a(iiay)" access="read"/>'+lineend+
//'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="IconPixmapList"/>'+lineend+
//'  </property>'+lineend+
'  <property name="AttentionMovieName" type="s" access="read"/>'+lineend+
'  <property name="ToolTip" type="(sa(iiay)ss)" access="read"/>'+lineend+
//'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="ToolTip"/>'+lineend+
//'  </property>'+lineend+
'  <method name="ContextMenu">'+lineend+
'      <arg name="x" type="i" direction="in"/>'+lineend+
'      <arg name="y" type="i" direction="in"/>'+lineend+
'  </method>'+lineend+
''+lineend+
'  <method name="Activate">'+lineend+
'      <arg name="x" type="i" direction="in"/>'+lineend+
'      <arg name="y" type="i" direction="in"/>'+lineend+
'  </method>'+lineend+
''+lineend+
'  <method name="SecondaryActivate">'+lineend+
'      <arg name="x" type="i" direction="in"/>'+lineend+
'      <arg name="y" type="i" direction="in"/>'+lineend+
'  </method>'+lineend+
''+lineend+
'  <method name="Scroll">'+lineend+
'    <arg name="delta" type="i" direction="in"/>'+lineend+
'    <arg name="orientation" type="s" direction="in"/>'+lineend+
'  </method>'+lineend+
''+lineend+
'  <signal name="NewTitle">'+lineend+
'  </signal>'+lineend+
''+lineend+
'  <signal name="NewIcon">'+lineend+
'  </signal>'+lineend+
''+lineend+
'  <signal name="NewAttentionIcon">'+lineend+
'  </signal>'+lineend+
''+lineend+
'  <signal name="NewOverlayIcon">'+lineend+
'  </signal>'+lineend+
''+lineend+
'  <signal name="NewToolTip">'+lineend+
'  </signal>'+lineend+
''+lineend+
'  <signal name="NewStatus">'+lineend+
'    <arg name="status" type="s"/>'+lineend+
'  </signal>'+lineend+
''+lineend+
'</interface>'+lineend;

const
 interfacestart: array[desktopkindty] of string = (
  '','org.freedesktop.','org.kde.');
  
constructor tstatusnotifieritem.create();
begin
 inherited create(nil);
 checkdesktop();
end;

destructor tstatusnotifieritem.destroy();
begin
 inherited;
 active:= false;
 freeandnil(fservice);
end;

function tstatusnotifieritem.showmessage(const message: msestring;
                         const title: msestring;
               out messageid: card32; const timeoutms: card32 = 0): boolean;
var
 s1,s2,s3: string;
 c1: card32;
 p1: pointer;
begin
 inc(fmessageid);
 s1:= getid;
 s2:= stringtoutf8(title);
 s3:= stringtoutf8(message);
 if fmessageid = 0 then begin
  inc(fmessageid);
 end;
 messageid:= fmessageid;
 p1:= nil;
 result:= fservice.dbuscallmethod('org.freedesktop.Notifications',
           '/org/freedesktop/Notifications','org.freedesktop.Notifications',
           'Notify',
           [variantvalue(s1),variantvalue(fmessageid),
            variantvalue(''),
            variantvalue(s2),
            variantvalue(s3),
            variantvalue(@p1,typeinfo(stringarty)),
            variantvalue(@p1,typeinfo(dictentryarty),[vf_dict]),
            variantvalue(int32(timeoutms))],[dbt_uint32],[@c1]);
end;

function tstatusnotifieritem.cancelmessage(
              const messageid: card32): boolean;
begin
 result:= fservice.dbuscallmethod('org.freedesktop.Notifications',
           '/org/freedesktop/Notifications','org.freedesktop.Notifications',
           'CloseNotification',[variantvalue(messageid)],[],[]);
end;

const
 categorynames: array[statusnotifiercategoryty] of string = (
  //snc_applicationstatus,snc_communications,snc_systemservices,snc_hardware
       'ApplicationStatus',  'Communications',  'SystemServices',  'Hardware');  

function tstatusnotifieritem.getcategory: string;
begin
 result:= categorynames[fstatuscategory];
end;

function tstatusnotifieritem.getid: string;
begin
 fid1:= fid;
 if fid1 = '' then begin
  fid1:= stringtoutf8(application.applicationname);
 end;
 result:= fid1;
end;

function tstatusnotifieritem.checkdesktop(): boolean;
var
 b1,b2: boolean;
 desk1: desktopkindty;
begin
 if fservice = nil then begin
  fservice:= tdbusservice.create();
  try
   b1:= false;
   if fservice.connect() then begin
    for desk1:= desktopkindty(1) to high(desk1) do begin
     if fservice.dbusgetproperty(interfacestart[desk1]+'StatusNotifierWatcher',
      '/StatusNotifierWatcher',interfacestart[desk1]+'StatusNotifierWatcher',
      'IsStatusNotifierHostRegistered',[dbt_boolean],[@b2]) then begin
      if b2 then begin
       fdesktopkind:= desk1;
       break;
      end;
     end;
    end;
   end;
   if fdesktopkind = desk_none then begin
    fservice.destroy();
    fservice:= nil;
   end;
  except
   fservice.destroy;
   fservice:= nil;
   raise;
  end;
 end;
 result:= fservice <> nil;
end;

procedure tstatusnotifieritem.setactive(const avalue: boolean);
begin
 if avalue <> factive then begin
  if factive then begin
   fservice.destroy;
   fservice:= nil;
   factive:= false;
  end
  else begin
   if checkdesktop() then begin
    factive:= true;
    fservice.registerobject(idbusobject(self));
   end;
  end;
 end;
end;

function tstatusnotifieritem.getintrospectitems(): string;
begin
 result:= inherited getintrospectitems() + 
 datadef1+getpropintf()+datadef2;
end;

function tstatusnotifieritem.getpath(): string;
begin
 result:= inherited getpath()+'StatusNotifierItem';
end;

procedure tstatusnotifieritem.busconnected();
var
 s1: string;
begin
 inherited;
// s1:= fservice.dbusname;
 s1:= fservice.dbusid;
 if not fservice.dbuscallmethod(
             interfacestart[fdesktopkind]+'StatusNotifierWatcher',
             '/StatusNotifierWatcher',
             interfacestart[fdesktopkind]+'StatusNotifierWatcher',
             'RegisterStatusNotifierItem',variantvalue(s1),[],[]) then begin
 end;
end;

procedure tstatusnotifieritem.propertiesget(var props: dictentryarty);
begin
 setlength(props,1);
 with props[0] do begin
  name:= 'ToolTip';
  setvariantvalue(@ftooltip,itemtypeinfo(typeinfo(tooltipinfoarty)),
                                                           value,[vf_var]);
 end;
end;

procedure tstatusnotifieritem.propertyget(const amessage: pdbusmessage;
               const aname: string; var avalue: variantvaluety);
begin
 if aname = 'ToolTip' then begin
  setvariantvalue(@ftooltip,itemtypeinfo(typeinfo(tooltipinfoarty)),
                                                           avalue,[vf_var]);
 end;
end;

function tstatusnotifieritem.getpropintf: string;
begin
 result:= interfacestart[fdesktopkind]+'StatusNotifierItem';
end;

procedure tstatusnotifieritem.registeritems(const sender: idbusservice);
begin
 inherited;
 sender.registermethodhandler(getpropintf(),
        'ContextMenu',[dbt_int32,dbt_int32],@contextmenu,nil);
 sender.registermethodhandler(getpropintf(),
        'Activate',[dbt_int32,dbt_int32],@activate,nil);
 sender.registermethodhandler(getpropintf(),
        'SecondaryActivate',[dbt_int32,dbt_int32],@secondaryactivate,nil);
 sender.registermethodhandler(getpropintf(),
        'Scroll',[dbt_int32,dbt_string],@scroll,nil);
end;

procedure tstatusnotifieritem.receiveevent(const event: tobjectevent);
begin
 inherited;
 if (event.kind = ek_objectdata) and (event is tpointobjectevent) and
                                             assigned(foncontextmenu) then begin
  foncontextmenu(self,tpointobjectevent(event).data);
 end;
end;

procedure tstatusnotifieritem.contextmenu(const amessage: pdbusmessage;
               const adata: pointer; var ahandled: boolean);
var
 x,y: int32;
begin
 if fservice.dbusreadmessage(amessage,[dbt_int32,dbt_int32],[@x,@y]) then begin
  application.postevent(tpointobjectevent.create(mp(x,y),ievent(self)));
      //deadlock in dbus library if called directly because of modal call
  fservice.dbusreply(amessage,[]);
  ahandled:= true;
 end
end;

procedure tstatusnotifieritem.activate(const amessage: pdbusmessage;
               const adata: pointer; var ahandled: boolean);
var
 x,y: int32;
begin
 if fservice.dbusreadmessage(amessage,[dbt_int32,dbt_int32],[@x,@y]) then begin
  fservice.dbusreply(amessage,[]);
  if assigned(fonactivate) then begin
   fonactivate(self,mp(x,y));
  end;
  ahandled:= true;
 end
end;

procedure tstatusnotifieritem.secondaryactivate(const amessage: pdbusmessage;
               const adata: pointer; var ahandled: boolean);
var
 x,y: int32;
begin
 if fservice.dbusreadmessage(amessage,[dbt_int32,dbt_int32],[@x,@y]) then begin
  if assigned(fonactivate) then begin
   foncontextmenu(self,mp(x,y));
  end;
  fservice.dbusreply(amessage,[]);
  ahandled:= true;
 end
end;

procedure tstatusnotifieritem.scroll(const amessage: pdbusmessage;
               const adata: pointer; var ahandled: boolean);
var
 delta: int32;
 orientation: string;
begin
 if fservice.dbusreadmessage(amessage,[dbt_int32,dbt_string],
                                                [@delta,@orientation]) then begin
  fservice.dbusreply(amessage,[]);
  ahandled:= true;
 end
end;

procedure tstatusnotifieritem.setId(const avalue: string);
begin
 fid:= avalue;
end;

procedure tstatusnotifieritem.setTitle(const avalue: string);
begin
 ftitle:= avalue;
 propchangesignal('NewTitle');
end;

procedure tstatusnotifieritem.setStatus(const avalue: string);
begin
 fstatus:= avalue;
 if (fservice <> nil) and fservice.connected then begin
  fservice.dbussignal(rootpath(),getpropintf(),'NewStatus',
                                               variantvalue(fstatus));
 end;
end;

procedure tstatusnotifieritem.setWindowId(const avalue: int32);
begin
 fwindowid:= avalue;
end;

procedure tstatusnotifieritem.setIconName(const avalue: string);
begin
 ficonname:= avalue;
 propchangesignal('NewIcon');
end;

procedure tstatusnotifieritem.setIconPixmap(const avalue: tmaskedbitmap);
var
 ar1: iconpixmaparty;
begin
 ar1:= nil;
 if (avalue <> nil) and avalue.hasimage() then begin
  setlength(ar1,1);
  ar1[0]:= bitmaptoiconpixmap(avalue);
 end;
 seticonpixmap(ar1);
end;

procedure tstatusnotifieritem.setIconPixmap(const avalue: iconpixmaparty);
begin
 ficonpixmap:= avalue;
 propchangesignal('NewIcon');
end;

procedure tstatusnotifieritem.setOverlayIconName(const avalue: string);
begin
 foverlayiconname:= avalue;
 propchangesignal('NewOverlayIcon');
end;

procedure tstatusnotifieritem.setOverlayIconPixmap(
              const avalue: iconpixmaparty);
begin
 foverlayiconpixmap:= avalue;
 propchangesignal('NewOverlayIcon');
end;

procedure tstatusnotifieritem.setAtentionIconName(const avalue: string);
begin
 fatentioniconname:= avalue;
 propchangesignal('NewAttentionIcon');
end;

procedure tstatusnotifieritem.setAtentionIconPixmap(
              const avalue: iconpixmaparty);
begin
 fatentioniconpixmap:= avalue;
 propchangesignal('NewAttentionIcon');
end;

procedure tstatusnotifieritem.setAtentionMovieName(const avalue: string);
begin
 fatentionmoviename:= avalue;
end;

procedure tstatusnotifieritem.setToolTip(const avalue: tooltipinfoty);
begin
 ftooltip:= avalue;
 propchangesignal('NewToolTip');
end;

end.
