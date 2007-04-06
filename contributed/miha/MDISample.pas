{ This is a main unit of the example that describes contrib/miha usage. 
  Distributed as is.}

program MDISample;
 {$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
 {$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
 {$endif}

uses
  {$ifdef FPC}{$ifdef linux}cthreads,{$endif}{$endif}msegui,mseforms,main,
  GuiStyle;

begin
  SetDesktopSkin;
  application.createform(tmainfo,mainfo);
  application.run;
end.
