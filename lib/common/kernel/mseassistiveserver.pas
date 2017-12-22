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
 mseassistiveclient,msemenuwidgets,msegrids,msetypes,msegraphutils;

type

 editinputmodety = (eim_insert,eim_overwrite);
 edittextblockmodety = (etbm_delete,etbm_cut,etbm_copy,etbm_insert,etbm_paste);
 assistiveoptionty = (aso_nodefaultbutton,aso_widgetnavig);
 assistiveoptionsty = set of assistiveoptionty;
const
 defaultassistiveoptions = [aso_nodefaultbutton,aso_widgetnavig];
 
type
 iassistiveserver = interface(inullinterface)[miid_iassistiveserver]
  procedure dowindowactivated(const sender: iassistiveclient);
  procedure dowindowdeactivated(const sender: iassistiveclient);
  procedure dowindowclosed(const sender: iassistiveclient);
  procedure doenter(const sender: iassistiveclient);
  procedure doactivate(const sender: iassistiveclient);
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
  procedure doeditchardelete(const sender: iassistiveclientedit;
                                                const achar: msestring);
  procedure doeditwithdrawn(const sender: iassistiveclientedit);
  procedure doeditindexmoved(const sender: iassistiveclientedit;
                                                const aindex: int32);
  procedure doeditinputmodeset(const sender: iassistiveclientedit;
                                                const amode: editinputmodety);
  procedure doedittextblock(const sender: iassistiveclientedit;
                    const amode: edittextblockmodety; const atext: msestring);
  procedure donavigbordertouched(const sender: iassistiveclient;
                                       const adirection: graphicdirectionty);

  procedure doitementer(const sender: iassistiveclient; //sender can be nil
                            const items: shapeinfoarty; const aindex: integer);
  procedure doitementer(const sender: iassistiveclient; //sender can be nil
                         const items: menucellinfoarty; const aindex: integer);
end;

var
 assistiveserver: iassistiveserver;
 assistiveoptions: assistiveoptionsty;
 
implementation
end.
