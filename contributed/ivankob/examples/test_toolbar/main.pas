unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msetoolbar,msebitmap,msegraphedits,msedataedits,
 msesimplewidgets,msemenus,mselistbrowser;

type
 tmainfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   tbutton3: tbutton;
   tbutton4: tbutton;
   tbutton5: tbutton;
   tbutton6: tbutton;
   tbutton7: tbutton;
   tbutton8: tbutton;
   tfacecomp1: tfacecomp;
   tframecomp2: tframecomp;
   timagelist2: timagelist;
   tmainmenu1: tmainmenu;
   tselector1: tselector;
   ttoolbar1: ttoolbar;
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
end.
