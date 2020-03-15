 { MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestatussnotifieritem;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedbusinterface;
type
 tstatusnotifieritem = class(tdbusobject)
  protected
   function getintrospectitems(): string virtual;
 end;

implementation

const
 datadef =
'<interface name="org.kde.StatusNotifierItem">'+lineend+
''+lineend+
'  <property name="Category" type="s" access="read"/>'+lineend+
'  <property name="Id" type="s" access="read"/>'+lineend+
'  <property name="Title" type="s" access="read"/>'+lineend+
'  <property name="Status" type="s" access="read"/>'+lineend+
'  <property name="WindowId" type="i" access="read"/>'+lineend+
'  <property name="IconThemePath" type="s" access="read"/>'+lineend+
'  <property name="Menu" type="o" access="read"/>'+lineend+
'  <property name="ItemIsMenu" type="b" access="read"/>'+lineend+
'  <property name="IconName" type="s" access="read"/>'+lineend+
'  <property name="IconPixmap" type="a(iiay)" access="read">'+lineend+
'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="IconPixmapList"/>'+lineend+
'  </property>'+lineend+
'  <property name="OverlayIconName" type="s" access="read"/>'+lineend+
'  <property name="OverlayIconPixmap" type="a(iiay)" access="read">'+lineend+
'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="IconPixmapList"/>'+lineend+
'  </property>'+lineend+
'  <property name="AttentionIconName" type="s" access="read"/>'+lineend+
'  <property name="AttentionIconPixmap" type="a(iiay)" access="read">'+lineend+
'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="IconPixmapList"/>'+lineend+
'  </property>'+lineend+
'  <property name="AttentionMovieName" type="s" access="read"/>'+lineend+
'  <property name="ToolTip" type="(sa(iiay)ss)" access="read">'+lineend+
'    <annotation name="org.qtproject.QtDBus.QtTypeName" value="ToolTip"/>'+lineend+
'  </property>'+lineend+
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

{ tstatusnotifieritem }

function tstatusnotifieritem.getintrospectitems(): string;
begin
 result:= datadef;
end;

end.
