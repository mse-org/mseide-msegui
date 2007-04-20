program shrinking_testcase;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype console}{$endif}
{$endif}

uses
 {$ifdef FPC}{$ifdef linux}cthreads,{$endif}{$endif}msegui,mseforms,main,dmprint;

begin
 application.createdatamodule(tdmprintmo,dmprintmo);
 application.createform(tmainfo,mainfo);
 application.run;
end.
