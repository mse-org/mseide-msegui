unit main_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 mseclasses,main;

const
 objdata: record size: integer; data: array[0..97] of byte end =
      (size: 98; data: (
  84,80,70,48,7,116,109,97,105,110,102,111,6,109,97,105,110,102,111,8,
  98,111,117,110,100,115,95,120,3,35,1,8,98,111,117,110,100,115,95,121,
  3,247,0,9,98,111,117,110,100,115,95,99,120,3,147,1,9,98,111,117,
  110,100,115,95,99,121,3,24,1,15,109,111,100,117,108,101,99,108,97,115,
  115,110,97,109,101,6,9,116,109,97,105,110,102,111,114,109,0,0)
 );

initialization
 registerobjectdata(@objdata,tmainfo,'');
end.
