 { MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestatusnotifieritem;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedbusinterface,msestrings,msetypes,msebitmap,msedbus;
type
 iconpixmapty = record
  cx,cy: int32;
  data: bytearty;
 end;
 iconpixmaparty = array of iconpixmapty;
 
 tooltipinfoty = record
  iconname: string;
  iconpixmap: iconpixmapty;
  title: string;
  text: string;
 end;
 tooltipinfoarty = array of tooltipinfoty; 
                       //workaround in order to get item typeinfo

 statusnotifiercategoryty = (snc_applicationstatus,snc_communications,
                             snc_systemservices,snc_hardware);
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
   function getcategory: string;
   function getid: string;
  protected
   function getintrospectitems(): string override;
   function getpath(): string override;
   procedure busconnected() override;
   procedure propertiesget(var props: dictentryarty) override;
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
  public
   property statuscategory: statusnotifiercategoryty read fstatuscategory
                         write fstatuscategory default snc_applicationstatus;
   procedure setToolTip(const avalue: tooltipinfoty);
   procedure setId(const avalue: string); //'' -> applicationname
   procedure setTitle(const avalue: string);
   procedure setStatus(const avalue: string);
   procedure setWindowId(const avalue: int32);
   procedure setIconName(const avalue: string);
   procedure setIconPixmap(const avalue: iconpixmaparty);
   procedure setOverlayIconName(const avalue: string);
   procedure setOverlayIconPixmap(const avalue: iconpixmaparty);
   procedure setAtentionIconName(const avalue: string);
   procedure setAtentionIconPixmap(const avalue: iconpixmaparty);
   procedure setAtentionMovieName(const avalue: string);
   property ToolTip: tooltipinfoty read ftooltip;
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
 mseapplication,msegraphics,msegraphutils;
const
// intfname = 'org.freedesktop.StatusNotifierItem';
 intfname = 'org.kde.StatusNotifierItem';
type
// dbuspixelty = packed record b,g,r,a: card8 end; //in network byte order
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
 datadef =
'<interface name="'+intfname+'">'+lineend+
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

function tstatusnotifieritem.getintrospectitems(): string;
begin
 result:= inherited getintrospectitems() + datadef;
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
 write('*statusnoifieritem ');
 if not fservice.dbuscallmethod('org.kde.StatusNotifierWatcher',
             '/StatusNotifierWatcher',
             'org.kde.StatusNotifierWatcher','RegisterStatusNotifierItem',
                                          variantvalue(s1),[],[]) then begin
  writeln('error:'+dbuslasterror);
 end
 else begin
  writeln('OK');
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

function tstatusnotifieritem.getpropintf: string;
begin
 result:= intfname;
end;

procedure tstatusnotifieritem.registeritems(const sender: idbusservice);
begin
 inherited;
 sender.registermethodhandler(intfname,
        'ContextMenu',[dbt_int32,dbt_int32],@contextmenu,nil);
 sender.registermethodhandler(intfname,
        'Activate',[dbt_int32,dbt_int32],@activate,nil);
 sender.registermethodhandler(intfname,
        'SecondaryActivate',[dbt_int32,dbt_int32],@secondaryactivate,nil);
 sender.registermethodhandler(intfname,
        'Scroll',[dbt_int32,dbt_string],@scroll,nil);
end;

procedure tstatusnotifieritem.contextmenu(const amessage: pdbusmessage;
               const adata: pointer; var ahandled: boolean);
var
 x,y: int32;
begin
 if fservice.dbusreadmessage(amessage,[dbt_int32,dbt_int32],[@x,@y]) then begin
writeln('**contextmenu');
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
writeln('**activate');
  fservice.dbusreply(amessage,[]);
  ahandled:= true;
 end
end;

procedure tstatusnotifieritem.secondaryactivate(const amessage: pdbusmessage;
               const adata: pointer; var ahandled: boolean);
var
 x,y: int32;
begin
 if fservice.dbusreadmessage(amessage,[dbt_int32,dbt_int32],[@x,@y]) then begin
writeln('**secondaryactivate');
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
writeln('**scroll');
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
 if fservice.connected then begin
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
