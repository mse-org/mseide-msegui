unit main_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 mseclasses,main;

const
 objdata: record size: integer; data: array[0..494] of byte end =
      (size: 495; data: (
  84,80,70,48,7,116,109,97,105,110,102,111,6,109,97,105,110,102,111,8,
  98,111,117,110,100,115,95,120,3,129,0,8,98,111,117,110,100,115,95,121,
  3,15,1,9,98,111,117,110,100,115,95,99,120,3,85,1,9,98,111,117,
  110,100,115,95,99,121,3,166,0,26,99,111,110,116,97,105,110,101,114,46,
  102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,11,0,27,99,
  111,110,116,97,105,110,101,114,46,102,114,97,109,101,46,108,111,99,97,108,
  112,114,111,112,115,49,11,0,16,99,111,110,116,97,105,110,101,114,46,98,
  111,117,110,100,115,1,2,0,2,0,3,85,1,3,166,0,0,7,111,112,
  116,105,111,110,115,11,7,102,111,95,109,97,105,110,19,102,111,95,116,101,
  114,109,105,110,97,116,101,111,110,99,108,111,115,101,15,102,111,95,97,117,
  116,111,114,101,97,100,115,116,97,116,16,102,111,95,97,117,116,111,119,114,
  105,116,101,115,116,97,116,10,102,111,95,115,97,118,101,112,111,115,12,102,
  111,95,115,97,118,101,115,116,97,116,101,0,13,119,105,110,100,111,119,111,
  112,97,99,105,116,121,5,0,0,0,0,0,0,0,128,255,255,15,109,111,
  100,117,108,101,99,108,97,115,115,110,97,109,101,6,8,116,109,115,101,102,
  111,114,109,0,7,116,98,117,116,116,111,110,8,116,98,117,116,116,111,110,
  49,8,98,111,117,110,100,115,95,120,3,144,0,8,98,111,117,110,100,115,
  95,121,2,72,9,98,111,117,110,100,115,95,99,120,2,50,9,98,111,117,
  110,100,115,95,99,121,2,22,5,115,116,97,116,101,11,15,97,115,95,108,
  111,99,97,108,99,97,112,116,105,111,110,17,97,115,95,108,111,99,97,108,
  111,110,101,120,101,99,117,116,101,0,7,99,97,112,116,105,111,110,6,4,
  69,120,105,116,11,102,111,110,116,46,120,115,99,97,108,101,2,1,15,102,
  111,110,116,46,108,111,99,97,108,112,114,111,112,115,11,10,102,108,112,95,
  120,115,99,97,108,101,0,9,111,110,101,120,101,99,117,116,101,7,13,101,
  120,105,116,111,110,101,120,101,99,117,116,101,0,0,0)
 );

initialization
 registerobjectdata(@objdata,tmainfo,'');
end.
