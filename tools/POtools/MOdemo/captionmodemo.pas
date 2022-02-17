
unit captionmodemo;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  msestrings,
  msetypes;

 // Your enums
type
  mainformty = (
    ma_test1,                 //0 This is a test of internationalization
    ma_test2,                 //1 That is a other test
    ma_test3                  //2 This is the end.
    );

  // your custom array
  mainformaty = array[mainformty] of msestring;

  // Your consts
const
  en_mainformtext: mainformaty = (
    'This is a test of internationalization.',
    'That is a other test.',
    'This is the end.'
    );

var
  lang_mainform: array of msestring;

implementation

initialization

end.
