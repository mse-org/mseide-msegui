program demo;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
uses
 {$ifdef FPC}{$ifdef linux}cthreads,{$endif}{$endif}msegui,mseforms,main;
begin
 application.createform(tmainfo,mainfo);
 application.run;
end.
