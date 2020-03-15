{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguithreadcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msethreadcomp,msegui,msetypes{msestrings};
type
 tguithreadcomp = class(tthreadcomp)
  private
   fdialogtext: msestring;
   fdialogcaption: msestring;
  public
   function runwithwaitdialog: boolean;
        //true if not canceled
  published
   property dialogtext: msestring read fdialogtext write fdialogtext;
   property dialogcaption: msestring read fdialogcaption write fdialogcaption;
 end;

implementation

{ tguithreadcomp }

function tguithreadcomp.runwithwaitdialog: boolean;
begin
 result:= application.waitdialog(self,fdialogtext,fdialogcaption);
end;

end.
