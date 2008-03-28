unit mseifiglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
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
 ificommandcodety = (icc_none,icc_close,icc_release);
 iificommand = interface(inullinterface)
                         ['{693DEACE-508E-465F-826A-801C3979C39E}'] 
  procedure executeificommand(var acommand: ificommandcodety);
 end;
implementation
end.
