
unit captionpodemo;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  msestrings,
  msetypes;

 // Your enums
type
  conflangfoty = (
    my_test1,                 //0 This is a test of internationalization
    my_test2,                 //1 That is a other test
    my_test3                  //2 This is the end.
    );

  // your custom array
  conflangfoaty = array[conflangfoty] of msestring;

  // Your consts
const
  en_conflangfotext: conflangfoaty = (
    'This is a test of internationalization.',
    'That is a other test.',
    'This is the end.'
    );

var
  lang_conflangfo: array of msestring;

implementation

initialization

end.
