{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseregkernelcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,msestatfile,mseact,mseapplication,msetimer,msethreadcomp,
 msepipestream,msemenus,msegui,msebitmap,mseactions,mseprinter,mseskin,
 mseguithreadcomp;
initialization
 registerclasses([tstatfile,tnoguiaction,tactivator,
                             ttimer,tthreadcomp,tpipereadercomp,
                    tmainmenu,tpopupmenu,tfacecomp,tframecomp,
                    tbitmapcomp,timagelist,taction,
                    tmainmenu,tpopupmenu,
                    tfacecomp,tfacelist,tframecomp,tskincontroller,
//                    tskinextender,
                    tbitmapcomp,timagelist,tshortcutcontroller,
                    taction,tguithreadcomp,
                    tpagesizeselector,tpageorientationselector
                    ]);
end.
