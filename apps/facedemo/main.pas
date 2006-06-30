unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msemenus,msedataedits,msestat;

type
 tmainfo = class(tmseform)
   buttonface1: tfacecomp;
   mainmenu1: tmainmenu;
   mainmenuframe: tframecomp;
   mainmenuitemframe: tframecomp;
   buttonface2: tfacecomp;
   popupitemframe: tframecomp;
   popupframe: tframecomp;
   tstatfile1: tstatfile;
   tstringedit1: tstringedit;
   tstringedit2: tstringedit;
   tstringedit3: tstringedit;
   tstringedit4: tstringedit;
   tstringedit5: tstringedit;
   tstringedit6: tstringedit;
   tstringedit7: tstringedit;
   tstringedit8: tstringedit;
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
end.
