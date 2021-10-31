program ${%PROGRAMNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef mswindows}{$apptype console}{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cthreads,msecwstring,{$endif}{$endif}
 sysutils;
begin
end.
