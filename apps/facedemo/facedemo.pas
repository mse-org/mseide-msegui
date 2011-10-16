program facedemo;   
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC}{$ifdef linux}cthreads,{$endif}{$endif}msegui,mseforms,main;
begin
 application.createform(tmainfo,mainfo);
 application.run;
end.
