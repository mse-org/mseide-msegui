unit main_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 mseclasses,main;

const
 objdata: record size: integer; data: array[0..870] of byte end =
      (size: 871; data: (
  84,80,70,48,7,116,109,97,105,110,102,111,6,109,97,105,110,102,111,8,
  98,111,117,110,100,115,95,120,3,47,2,8,98,111,117,110,100,115,95,121,
  3,78,1,9,98,111,117,110,100,115,95,99,120,3,16,1,9,98,111,117,
  110,100,115,95,99,121,2,52,12,98,111,117,110,100,115,95,99,120,109,105,
  110,3,16,1,12,98,111,117,110,100,115,95,99,121,109,105,110,2,52,12,
  98,111,117,110,100,115,95,99,120,109,97,120,3,16,1,12,98,111,117,110,
  100,115,95,99,121,109,97,120,2,52,26,99,111,110,116,97,105,110,101,114,
  46,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,11,0,27,
  99,111,110,116,97,105,110,101,114,46,102,114,97,109,101,46,108,111,99,97,
  108,112,114,111,112,115,49,11,0,16,99,111,110,116,97,105,110,101,114,46,
  98,111,117,110,100,115,1,2,0,2,0,3,16,1,2,52,0,7,111,112,
  116,105,111,110,115,11,7,102,111,95,109,97,105,110,19,102,111,95,116,101,
  114,109,105,110,97,116,101,111,110,99,108,111,115,101,17,102,111,95,115,99,
  114,101,101,110,99,101,110,116,101,114,101,100,15,102,111,95,97,117,116,111,
  114,101,97,100,115,116,97,116,16,102,111,95,97,117,116,111,119,114,105,116,
  101,115,116,97,116,10,102,111,95,115,97,118,101,112,111,115,13,102,111,95,
  115,97,118,101,122,111,114,100,101,114,12,102,111,95,115,97,118,101,115,116,
  97,116,101,0,7,99,97,112,116,105,111,110,6,18,84,105,109,101,108,101,
  115,115,32,77,83,69,32,99,108,111,99,107,13,119,105,110,100,111,119,111,
  112,97,99,105,116,121,5,0,0,0,0,0,0,0,128,255,255,15,109,111,
  100,117,108,101,99,108,97,115,115,110,97,109,101,6,9,116,109,97,105,110,
  102,111,114,109,0,6,116,108,97,98,101,108,7,116,108,97,98,101,108,49,
  14,111,112,116,105,111,110,115,119,105,100,103,101,116,49,11,19,111,119,49,
  95,102,111,110,116,103,108,121,112,104,104,101,105,103,104,116,14,111,119,49,
  95,97,117,116,111,104,101,105,103,104,116,0,8,98,111,117,110,100,115,95,
  120,2,16,8,98,111,117,110,100,115,95,121,2,8,9,98,111,117,110,100,
  115,95,99,120,3,240,0,9,98,111,117,110,100,115,95,99,121,2,36,17,
  102,111,110,116,46,115,104,97,100,111,119,95,99,111,108,111,114,4,6,0,
  0,160,18,102,111,110,116,46,115,104,97,100,111,119,95,115,104,105,102,116,
  120,2,2,11,102,111,110,116,46,104,101,105,103,104,116,2,26,9,102,111,
  110,116,46,110,97,109,101,6,11,115,116,102,95,100,101,102,97,117,108,116,
  12,102,111,110,116,46,111,112,116,105,111,110,115,11,16,102,111,111,95,97,
  110,116,105,97,108,105,97,115,101,100,50,0,15,102,111,110,116,46,108,111,
  99,97,108,112,114,111,112,115,11,16,102,108,112,95,115,104,97,100,111,119,
  95,99,111,108,111,114,17,102,108,112,95,115,104,97,100,111,119,95,115,104,
  105,102,116,120,17,102,108,112,95,115,104,97,100,111,119,95,115,104,105,102,
  116,121,10,102,108,112,95,104,101,105,103,104,116,11,102,108,112,95,111,112,
  116,105,111,110,115,0,9,116,101,120,116,102,108,97,103,115,11,12,116,102,
  95,120,99,101,110,116,101,114,101,100,12,116,102,95,121,99,101,110,116,101,
  114,101,100,0,13,114,101,102,102,111,110,116,104,101,105,103,104,116,2,36,
  0,0,6,116,116,105,109,101,114,7,116,116,105,109,101,114,49,8,105,110,
  116,101,114,118,97,108,4,32,161,7,0,7,111,110,116,105,109,101,114,7,
  5,111,110,116,105,109,7,101,110,97,98,108,101,100,9,4,108,101,102,116,
  2,8,3,116,111,112,2,8,0,0,0)
 );

initialization
 registerobjectdata(@objdata,tmainfo,'');
end.