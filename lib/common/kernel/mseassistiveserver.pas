{ MSEgui Copyright (c) 2015-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseassistiveserver;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseguiglob,mseglob,msestrings,mseinterfaces,mseact,mseshapes,
 mseassistiveclient,msemenuwidgets,msegrids,msetypes;

type
 iassistiveserver = interface(inullinterface)[miid_iassistiveserver]
  procedure doenter(const sender: iassistiveclient);
  procedure doitementer(const sender: iassistiveclient; //sender can be nil
                            const items: shapeinfoarty; const aindex: integer);
  procedure doitementer(const sender: iassistiveclient; //sender can be nil
                         const items: menucellinfoarty; const aindex: integer);
  procedure doclientmouseevent(const sender: iassistiveclient;
                                          const info: mouseeventinfoty);
  procedure dofocuschanged(const oldwidget,newwidget: iassistiveclient);
  procedure dokeydown(const sender: iassistiveclient;
                                        const info: keyeventinfoty);
  procedure doactionexecute(const sender: tobject; const info: actioninfoty);
  procedure dochange(const sender: iassistiveclient);
  procedure dodataentered(const sender: iassistiveclientdata);
  procedure docellevent(const sender: iassistiveclientgrid; 
                                      const info: celleventinfoty);
  procedure doeditcharenter(const sender: iassistiveclientedit;
                                                const achar: msestring);
end;

var
 assistiveserver: iassistiveserver;
 noassistivedefaultbutton: boolean;
 
implementation
end.
