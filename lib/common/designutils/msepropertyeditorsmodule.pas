unit msepropertyeditorsmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msestringcontainer,msestrings;

type
 stringconststy = (
  openimagefile,            //0 Open image file
  invalidsetitem,           //1 Invalid set item
  unknown,                  //2 Unknown
  wrongpropertyvalue,       //3 Wrong property value
  invalidmethodname,        //4 Invalid method name
  str_methodname,           //5 Method name
  exists,                   //6 exists
  wishdestroy,              //7 Do you wish to destroy
  wishdelete,               //8 Do you wish to delete items
  str_to,                   //9 to
  emptydate,                //10 Empty date
  emptytime,                //11 Empty time
  wishclear,                //12 Do you wish to clear
  texteditor,               //13 Texteditor
  invalidcomponentname      //14 Invalid component name
 );

 tmsepropertyeditorsmo = class(tmsedatamodule)
   c: tstringcontainer;
 end;
implementation
uses
 msepropertyeditorsmodule_mfm;
end.
