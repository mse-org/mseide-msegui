{ MSEgui Copyright (c) 2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseassistive;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseguiglob,mseglob,msestrings,mseinterfaces,mseact;

type
 iassistiveclient = interface(inullinterface)[miid_iassistiveclient]
  function getinstance: tobject;
  function getassistivename(): msestring;
 end;

 iassistiveserver = interface(inullinterface)[miid_iassistiveserver]
  procedure doenter(const sender: iassistiveclient);
  procedure clientmouseevent(const sender: iassistiveclient;
                                          const info: mouseeventinfoty);
  procedure dofocuschanged(const oldwidget,newwidget: iassistiveclient);
  procedure dokeydown(const sender: iassistiveclient;
                                        const info: keyeventinfoty);
  procedure doactionexecute(const sender: tobject; const info: actioninfoty);
  procedure dochange(const sender: iassistiveclient);
 end;

var
 assistiveserver: iassistiveserver;
 
implementation
end.
