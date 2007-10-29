unit mseifiglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob;
type

 iifiwidget = interface;
 
 iifiserver = interface(inullinterface)
  procedure valuechanged(const sender: iifiwidget);
 end;
 
 iifiwidget = interface(inullinterface)['{E3523E5B-604C-46CE-88D4-55C9970BCF9A}']
  procedure setifiserverintf(const aintf: iifiserver);
  function getifiserverintf: iifiserver;
 end;
 
implementation
end.
