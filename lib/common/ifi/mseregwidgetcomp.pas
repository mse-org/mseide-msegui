{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseregwidgetcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
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
