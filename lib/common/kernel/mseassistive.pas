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
 mseguiglob,mseglob,msestrings;

type
 iassistiveclient = interface(inullinterface)
  function getinstance: tobject;
  function getassistivename(): msestring;
 end;

 iassistiveserver = interface(inullinterface)
  procedure doenter(const sender: iassistiveclient);
  procedure clientmouseevent(const sender: iassistiveclient;
                                          var info: mouseeventinfoty);
 end;

var
 assistiveserver: iassistiveserver;
 
implementation
end.
