{ MSEgui Copyright (c) 2015-2018 by Martin Schreiber

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
 assistiveoptionty = (
  aso_textfirst,
  aso_nodefaultbutton,
  aso_noreturnbutton,    //do not execute button by return key
  aso_returntogglevalue, //ttogglegtraphdataedit togglevalue by return key
  aso_tabnavig,aso_widgetnavig,aso_nearestortho,
  aso_menunavig,aso_gridnavig,
  aso_noreturnkeymenuexecute,
  aso_nomenumousemove,
  aso_nogridmousemove,
  aso_saverate,aso_savevolume,
  aso_savelanguage,aso_savegender,aso_saveage,
  aso_savepitch,aso_saverange,
  aso_savecapitals,aso_savewordgap
 );

 assistiveoptionsty = set of assistiveoptionty;
 assistivedbeventkindty = (adek_none,adek_bof,adek_eof);
const
 defaultassistiveoptions = [aso_textfirst,aso_nodefaultbutton,
                            aso_returntogglevalue,
                            aso_tabnavig,aso_widgetnavig,
                            aso_menunavig,aso_gridnavig,
                            aso_noreturnkeymenuexecute,
                            aso_nomenumousemove,aso_nogridmousemove];

type
 iassistiveserver = interface(inullinterface)[miid_iassistiveserver]
  procedure doapplicationactivated();
  procedure doapplicationdeactivated();
  procedure dowindowactivated(const sender: iassistiveclient);
  procedure dowindowdeactivated(const sender: iassistiveclient);
  procedure dowindowclosed(const sender: iassistiveclient);
  procedure doenter(const sender: iassistiveclient);
  procedure doactivate(const sender: iassistiveclient);
  procedure dodeactivate(const sender: iassistiveclient);
  procedure doclientmouseevent(const sender: iassistiveclient;
                                          const info: mouseeventinfoty);
  procedure dofocuschanged(const sender: iassistiveclient;
                                const oldwidget,newwidget: iassistiveclient);
  procedure dokeydown(const sender: iassistiveclient;
                                        const info: keyeventinfoty);
  procedure dochange(const sender: iassistiveclient);
  procedure dodbvaluechanged(const sender: iassistiveclientdata);
  procedure dodataentered(const sender: iassistiveclientdata);
  procedure docellevent(const sender: iassistiveclientgrid;
                                      const info: celleventinfoty);
  procedure dogridbordertouched(const sender: iassistiveclientgrid;
                                       const adirection: graphicdirectionty);

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
  procedure dotabordertouched(const sender: iassistiveclient;
                                                        const adown: boolean);

  procedure doactionexecute(const sender: iassistiveclient;//sender can be nil
                            const senderobj: tobject; const info: actioninfoty);
  procedure doitementer(const sender: iassistiveclient;    //sender can be nil
                            const items: shapeinfoarty; const aindex: integer);
  procedure domenuactivated(const sender: iassistiveclientmenu);
  procedure doitementer(const sender: iassistiveclientmenu;//sender can be nil
                         const items: menucellinfoarty; const aindex: integer);
  procedure dodatasetevent(const sender: iassistiveclient;
                const akind: assistivedbeventkindty;
                                  const adataset: pointer); //tdataset
end;

var
 assistiveserver: iassistiveserver;
 assistiveoptions: assistiveoptionsty;

implementation
end.
