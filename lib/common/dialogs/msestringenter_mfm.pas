unit msestringenter_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 mseclasses,msestringenter;

const
 objdata: record size: integer; data: array[0..2502] of byte end =
      (size: 2503; data: (
  84,80,70,48,14,116,115,116,114,105,110,103,101,110,116,101,114,102,111,13,
  115,116,114,105,110,103,101,110,116,101,114,102,111,14,111,112,116,105,111,110,
  115,119,105,100,103,101,116,49,11,13,111,119,49,95,97,117,116,111,115,99,
  97,108,101,14,111,119,49,95,97,117,116,111,104,101,105,103,104,116,0,13,
  111,112,116,105,111,110,115,119,105,100,103,101,116,11,13,111,119,95,97,114,
  114,111,119,102,111,99,117,115,15,111,119,95,97,114,114,111,119,102,111,99,
  117,115,105,110,16,111,119,95,97,114,114,111,119,102,111,99,117,115,111,117,
  116,11,111,119,95,115,117,98,102,111,99,117,115,17,111,119,95,100,101,115,
  116,114,111,121,119,105,100,103,101,116,115,9,111,119,95,104,105,110,116,111,
  110,0,7,118,105,115,105,98,108,101,8,8,98,111,117,110,100,115,95,120,
  3,84,1,8,98,111,117,110,100,115,95,121,3,67,1,9,98,111,117,110,
  100,115,95,99,120,3,142,1,9,98,111,117,110,100,115,95,99,121,2,70,
  12,98,111,117,110,100,115,95,99,120,109,105,110,3,200,0,12,98,111,117,
  110,100,115,95,99,121,109,105,110,2,70,23,99,111,110,116,97,105,110,101,
  114,46,111,112,116,105,111,110,115,119,105,100,103,101,116,11,13,111,119,95,
  109,111,117,115,101,102,111,99,117,115,11,111,119,95,116,97,98,102,111,99,
  117,115,13,111,119,95,97,114,114,111,119,102,111,99,117,115,15,111,119,95,
  97,114,114,111,119,102,111,99,117,115,105,110,16,111,119,95,97,114,114,111,
  119,102,111,99,117,115,111,117,116,11,111,119,95,115,117,98,102,111,99,117,
  115,19,111,119,95,109,111,117,115,101,116,114,97,110,115,112,97,114,101,110,
  116,17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,0,
  29,99,111,110,116,97,105,110,101,114,46,102,114,97,109,101,46,102,114,97,
  109,101,105,95,98,111,116,116,111,109,2,10,26,99,111,110,116,97,105,110,
  101,114,46,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,11,
  12,102,114,108,95,102,105,98,111,116,116,111,109,0,27,99,111,110,116,97,
  105,110,101,114,46,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,
  115,49,11,0,18,99,111,110,116,97,105,110,101,114,46,111,110,108,97,121,
  111,117,116,7,9,108,97,121,111,117,116,101,120,101,16,99,111,110,116,97,
  105,110,101,114,46,98,111,117,110,100,115,1,2,0,2,0,3,142,1,2,
  70,0,7,111,112,116,105,111,110,115,11,17,102,111,95,115,99,114,101,101,
  110,99,101,110,116,101,114,101,100,13,102,111,95,99,108,111,115,101,111,110,
  101,115,99,17,102,111,95,108,111,99,97,108,115,104,111,114,116,99,117,116,
  115,15,102,111,95,97,117,116,111,114,101,97,100,115,116,97,116,16,102,111,
  95,97,117,116,111,119,114,105,116,101,115,116,97,116,0,13,119,105,110,100,
  111,119,111,112,97,99,105,116,121,5,0,0,0,0,0,0,0,128,255,255,
  8,111,110,108,97,121,111,117,116,7,9,108,97,121,111,117,116,101,120,101,
  15,109,111,100,117,108,101,99,108,97,115,115,110,97,109,101,6,8,116,109,
  115,101,102,111,114,109,0,6,116,108,97,98,101,108,3,108,97,98,14,111,
  112,116,105,111,110,115,119,105,100,103,101,116,49,11,14,111,119,49,95,97,
  117,116,111,104,101,105,103,104,116,0,13,111,112,116,105,111,110,115,119,105,
  100,103,101,116,11,13,111,119,95,109,111,117,115,101,119,104,101,101,108,17,
  111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,0,8,116,
  97,98,111,114,100,101,114,2,1,8,98,111,117,110,100,115,95,120,2,7,
  8,98,111,117,110,100,115,95,121,2,12,9,98,111,117,110,100,115,95,99,
  120,3,128,1,9,98,111,117,110,100,115,95,99,121,2,16,7,97,110,99,
  104,111,114,115,11,7,97,110,95,108,101,102,116,6,97,110,95,116,111,112,
  8,97,110,95,114,105,103,104,116,0,7,99,97,112,116,105,111,110,6,3,
  108,97,98,9,116,101,120,116,102,108,97,103,115,11,12,116,102,95,121,99,
  101,110,116,101,114,101,100,12,116,102,95,119,111,114,100,98,114,101,97,107,
  0,0,0,9,116,108,97,121,111,117,116,101,114,10,116,108,97,121,111,117,
  116,101,114,49,8,98,111,117,110,100,115,95,120,2,8,8,98,111,117,110,
  100,115,95,121,2,36,9,98,111,117,110,100,115,95,99,120,3,127,1,9,
  98,111,117,110,100,115,95,99,121,2,22,7,97,110,99,104,111,114,115,11,
  7,97,110,95,108,101,102,116,6,97,110,95,116,111,112,8,97,110,95,114,
  105,103,104,116,0,12,111,112,116,105,111,110,115,115,99,97,108,101,11,11,
  111,115,99,95,101,120,112,97,110,100,121,11,111,115,99,95,115,104,114,105,
  110,107,121,17,111,115,99,95,101,120,112,97,110,100,115,104,114,105,110,107,
  120,17,111,115,99,95,101,120,112,97,110,100,115,104,114,105,110,107,121,0,
  13,111,112,116,105,111,110,115,108,97,121,111,117,116,11,10,108,97,111,95,
  112,108,97,99,101,120,10,108,97,111,95,97,108,105,103,110,121,0,10,97,
  108,105,103,110,95,103,108,117,101,7,9,119,97,109,95,115,116,97,114,116,
  13,112,108,97,99,101,95,109,105,110,100,105,115,116,2,8,13,112,108,97,
  99,101,95,109,97,120,100,105,115,116,2,8,13,112,108,97,99,101,95,111,
  112,116,105,111,110,115,11,13,112,108,111,95,101,110,100,109,97,114,103,105,
  110,0,7,108,105,110,107,116,111,112,7,3,108,97,98,8,100,105,115,116,
  95,116,111,112,2,8,0,7,116,98,117,116,116,111,110,6,99,97,110,99,
  101,108,14,111,112,116,105,111,110,115,119,105,100,103,101,116,49,11,19,111,
  119,49,95,102,111,110,116,103,108,121,112,104,104,101,105,103,104,116,13,111,
  119,49,95,97,117,116,111,115,99,97,108,101,13,111,119,49,95,97,117,116,
  111,119,105,100,116,104,19,111,119,49,95,97,117,116,111,115,105,122,101,97,
  110,114,105,103,104,116,0,13,111,112,116,105,111,110,115,119,105,100,103,101,
  116,11,11,111,119,95,116,97,98,102,111,99,117,115,13,111,119,95,97,114,
  114,111,119,102,111,99,117,115,15,111,119,95,97,114,114,111,119,102,111,99,
  117,115,105,110,16,111,119,95,97,114,114,111,119,102,111,99,117,115,111,117,
  116,17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,0,
  8,116,97,98,111,114,100,101,114,2,2,8,98,111,117,110,100,115,95,120,
  3,77,1,8,98,111,117,110,100,115,95,121,2,0,9,98,111,117,110,100,
  115,95,99,120,2,50,9,98,111,117,110,100,115,95,99,121,2,22,12,98,
  111,117,110,100,115,95,99,120,109,105,110,2,50,5,115,116,97,116,101,11,
  15,97,115,95,108,111,99,97,108,99,97,112,116,105,111,110,0,7,99,97,
  112,116,105,111,110,6,7,38,67,97,110,99,101,108,11,109,111,100,97,108,
  114,101,115,117,108,116,7,9,109,114,95,99,97,110,99,101,108,13,114,101,
  102,102,111,110,116,104,101,105,103,104,116,2,16,0,0,7,116,98,117,116,
  116,111,110,2,111,107,14,111,112,116,105,111,110,115,119,105,100,103,101,116,
  49,11,19,111,119,49,95,102,111,110,116,103,108,121,112,104,104,101,105,103,
  104,116,13,111,119,49,95,97,117,116,111,115,99,97,108,101,13,111,119,49,
  95,97,117,116,111,119,105,100,116,104,0,13,111,112,116,105,111,110,115,119,
  105,100,103,101,116,11,11,111,119,95,116,97,98,102,111,99,117,115,13,111,
  119,95,97,114,114,111,119,102,111,99,117,115,15,111,119,95,97,114,114,111,
  119,102,111,99,117,115,105,110,16,111,119,95,97,114,114,111,119,102,111,99,
  117,115,111,117,116,17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,
  101,116,115,0,8,116,97,98,111,114,100,101,114,2,1,8,98,111,117,110,
  100,115,95,120,3,19,1,8,98,111,117,110,100,115,95,121,2,0,9,98,
  111,117,110,100,115,95,99,120,2,50,9,98,111,117,110,100,115,95,99,121,
  2,22,12,98,111,117,110,100,115,95,99,120,109,105,110,2,50,5,115,116,
  97,116,101,11,10,97,115,95,100,101,102,97,117,108,116,15,97,115,95,108,
  111,99,97,108,100,101,102,97,117,108,116,15,97,115,95,108,111,99,97,108,
  99,97,112,116,105,111,110,0,7,99,97,112,116,105,111,110,6,3,38,79,
  75,11,109,111,100,97,108,114,101,115,117,108,116,7,5,109,114,95,111,107,
  13,114,101,102,102,111,110,116,104,101,105,103,104,116,2,16,0,0,11,116,
  115,116,114,105,110,103,101,100,105,116,5,118,97,108,117,101,13,111,112,116,
  105,111,110,115,119,105,100,103,101,116,11,13,111,119,95,109,111,117,115,101,
  102,111,99,117,115,11,111,119,95,116,97,98,102,111,99,117,115,13,111,119,
  95,97,114,114,111,119,102,111,99,117,115,15,111,119,95,97,114,114,111,119,
  102,111,99,117,115,105,110,16,111,119,95,97,114,114,111,119,102,111,99,117,
  115,111,117,116,17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,
  116,115,0,16,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,
  11,0,17,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,49,
  11,0,8,98,111,117,110,100,115,95,120,2,0,8,98,111,117,110,100,115,
  95,121,2,0,9,98,111,117,110,100,115,95,99,120,3,11,1,9,98,111,
  117,110,100,115,95,99,121,2,22,7,97,110,99,104,111,114,115,11,7,97,
  110,95,108,101,102,116,6,97,110,95,116,111,112,8,97,110,95,114,105,103,
  104,116,0,12,111,112,116,105,111,110,115,101,100,105,116,49,11,17,111,101,
  49,95,97,117,116,111,112,111,112,117,112,109,101,110,117,14,111,101,49,95,
  107,101,121,101,120,101,99,117,116,101,13,111,101,49,95,115,97,118,101,118,
  97,108,117,101,13,111,101,49,95,115,97,118,101,115,116,97,116,101,0,11,
  111,112,116,105,111,110,115,101,100,105,116,11,12,111,101,95,117,110,100,111,
  111,110,101,115,99,13,111,101,95,99,108,111,115,101,113,117,101,114,121,16,
  111,101,95,99,104,101,99,107,109,114,99,97,110,99,101,108,14,111,101,95,
  115,104,105,102,116,114,101,116,117,114,110,20,111,101,95,114,101,115,101,116,
  115,101,108,101,99,116,111,110,101,120,105,116,15,111,101,95,101,120,105,116,
  111,110,99,117,114,115,111,114,13,111,101,95,101,110,100,111,110,101,110,116,
  101,114,13,111,101,95,97,117,116,111,115,101,108,101,99,116,25,111,101,95,
  97,117,116,111,115,101,108,101,99,116,111,110,102,105,114,115,116,99,108,105,
  99,107,0,13,114,101,102,102,111,110,116,104,101,105,103,104,116,2,16,0,
  0,0,0)
 );

initialization
 registerobjectdata(@objdata,tstringenterfo,'');
end.
