<<<<<<< HEAD
program demo;   
=======
program demo;  
>>>>>>> a8b14b9af3f9800f64ba6d2070dd40353e33a4cb
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
uses
 {$ifdef FPC}{$ifdef linux}cthreads,{$endif}{$endif}msegui,mseforms,main;
begin
 application.createform(tmainfo,mainfo);
 application.run;
end.
