unit mseregwidgetcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 classes,msesimplewidgets,msegrids,mselistbrowser,mseimage,msedispwidgets,
 msedock,mseforms,msemenuwidgets,msesplitter,msetoolbar,msetabs,msedial,
 msechart,msewindowwidget,mseopenglwidget;
initialization
 registerclasses([teventwidget,tbutton,trichbutton,tstockglyphbutton,tdrawgrid,
                 tstringgrid,tlistview,tlabel,tpaintbox,timage,
  tintegerdisp,trealdisp,tdatetimedisp,tstringdisp,tbytestringdisp,tbooleandisp,
  tgroupbox,tscrollbox,tstepbox,tdockpanel,tdockhandle,tmseformwidget,
  tdockformwidget,tmainmenuwidget,
  tsplitter,tspacer,ttoolbar,ttabbar,ttabwidget,ttabpage,
  tdial,tchart,tchartrecorder,twindowwidget{$ifdef FPC},topenglwidget{$endif}]);
end.
