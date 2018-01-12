{ MSEgui Copyright (c) 2017-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
// under construction
//
unit mseassistivehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseclasses,mseassistiveserver,mseevent,
 mseguiglob,mseglob,msestrings,mseinterfaces,mseact,mseshapes,
 mseassistiveclient,msemenuwidgets,msegrids,msespeak,msetypes,
 msestockobjects,msegraphutils,msegui,msehash,mdb;

type
 assistivehandlerstatety =
  (ahs_active,ahs_nocut,
   ahs_windowactivated,ahs_menuactivated,ahs_menuactivatepending,
   ahs_dropdownlistclosed,ahs_editcharenter,ahs_editchardelete,
   ahs_locatepending,ahs_dropdownpending,
   ahs_textblock,ahs_textblock1);
 assistivehandlerstatesty = set of assistivehandlerstatety;
const
 internalstates = [ahs_active];
type
 tassistivespeak = class(tcustomespeakng)
  public
   constructor create(aowner: tcomponent); override;
  published
   property datapath;
   property options;
   property device;
   property bufferlength;
   property voicedefault;
   property voices;
   property language;
   property identifier;
   property gender;
   property age;
   property variant;
   property volume;
   property rate;
   property pitch;
   property range;
   property wordgap;
   property punctuationlist;
 end;

 tassistivehandler = class;
 tassistivewidgetitem = class;

 assistiveeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclient;
                                                var handled: boolean) of object;
 assistivemouseeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclient;
                  const info: mouseeventinfoty; var handled: boolean) of object;
 assistivefocuschangedeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclient; 
                                  const oldwidget,newwidget: iassistiveclient;
                                                var handled: boolean) of object;
 assistivekeyeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclient;
                    const info: keyeventinfoty; var handled: boolean) of object;
 assistivedataeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientdata;
                                                var handled: boolean) of object;
 assistivecelleventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientgrid;
                   const info: celleventinfoty; var handled: boolean) of object;
 assistiveediteventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientedit;
                                                var handled: boolean) of object;
 assistiveeditstringeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientedit;
                        const atext: msestring; var handled: boolean) of object;
 assistiveeditindexeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientedit;
                            const index: int32; var handled: boolean) of object;
 assistiveeditinputmodeeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientedit;
                  const amode: editinputmodety; var handled: boolean) of object;
 assistiveedittextblockeventty = 
  procedure(const sender: tassistivewidgetitem;
            const handler: tassistivehandler; const intf: iassistiveclientedit;
                 const amode: edittextblockmodety; const atext: msestring;
                                                var handled: boolean) of object;
 assistivedirectioneventty = 
  procedure(const sender: tassistivewidgetitem;
                const handler: tassistivehandler; const intf: iassistiveclient;
                                     const adirection: graphicdirectionty;
                                                var handled: boolean) of object;
 assistivedirectiongrideventty = 
  procedure(const sender: tassistivewidgetitem;
                const handler: tassistivehandler;
                       const intf: iassistiveclientgrid;
                                     const adirection: graphicdirectionty;
                                                var handled: boolean) of object;
 assistivestringeventty = 
  procedure(const sender: tassistivewidgetitem;
                const handler: tassistivehandler;
                  const intf: iassistiveclient; var atext: msestring) of object;
 assistivedataseteventty = 
  procedure(const sender: tassistivewidgetitem;
             const handler: tassistivehandler; const intf: iassistiveclient;
                const akind: assistivedbeventkindty; const adataset: tdataset;
                                                var handled: boolean) of object;

 tassistivewidgetitem = class(tmsecomponent)
  private
   fhandler: tassistivehandler;
   fwidget: twidget;
   fonwindowactivated: assistiveeventty;
   fonwindowdeactivated: assistiveeventty;
   fonwindowclosed: assistiveeventty;
   fonenter: assistiveeventty;
   fonactivate: assistiveeventty;
   fonclientmouseevent: assistivemouseeventty;
   fonkeydown: assistivekeyeventty;
   fonchange: assistiveeventty;
   fondataentered: assistivedataeventty;
   foncellevent: assistivecelleventty;
   foneditcharenter: assistiveeditstringeventty;
   foneditchardelete: assistiveeditstringeventty;
   foneditwithdrawn: assistiveediteventty;
   foneditindexmoved: assistiveeditindexeventty;
   foneditinputmodeset: assistiveeditinputmodeeventty;
   fonedittextblock: assistiveedittextblockeventty;
   fonnavigbordertouched: assistivedirectioneventty;
   fongetcaption: assistivestringeventty;
   fcaption: msestring;
   fongettext: assistivestringeventty;
   fongethint: assistivestringeventty;
   ftext: msestring;
   fhint: msestring;
   fondbvaluechanged: assistivedataeventty;
   fondatasetevent: assistivedataseteventty;
   fongridbordertouched: assistivedirectiongrideventty;
   procedure sethandler(const avalue:tassistivehandler);
   procedure setwidget(const avalue: twidget);
  protected
   procedure linkhandler();
   procedure unlinkhandler();
   procedure objectevent(const sender: tobject;
                                 const event: objecteventty) override;
   procedure dowindowactivated(const sender:tassistivehandler;
                         const aintf: iassistiveclient; var handled: boolean);
   procedure dowindowdeactivated(const sender:tassistivehandler;
                         const aintf: iassistiveclient; var handled: boolean);
   procedure dowindowclosed(const sender:tassistivehandler;
                          const aintf: iassistiveclient; var handled: boolean);
   procedure doenter(const sender:tassistivehandler;
                          const aintf: iassistiveclient; var handled: boolean);
   procedure doactivate(const sender:tassistivehandler;
                          const aintf: iassistiveclient; var handled: boolean);
   procedure doclientmouseevent(const sender:tassistivehandler;
              const aintf: iassistiveclient; const info: mouseeventinfoty;
                                                        var handled: boolean);
   procedure dokeydown(const sender:tassistivehandler;
           const aintf: iassistiveclient; const info: keyeventinfoty;
                                                        var handled: boolean);
   procedure dochange(const sender:tassistivehandler; 
                         const aintf: iassistiveclient; var handled: boolean);
   procedure dodbvaluechanged(const sender:tassistivehandler;
                     const aintf: iassistiveclientdata; var handled: boolean);
   procedure dodataentered(const sender:tassistivehandler;
                     const aintf: iassistiveclientdata; var handled: boolean);
   procedure docellevent(const sender:tassistivehandler;
               const aintf: iassistiveclientgrid; const info: celleventinfoty;
                                                        var handled: boolean);
   procedure dogridbordertouched(const sender:tassistivehandler;
                                         const aintf: iassistiveclientgrid;
                                         const adirection: graphicdirectionty;
                                                         var handled: boolean);
   procedure doeditcharenter(const sender:tassistivehandler;
                const aintf: iassistiveclientedit; const achar: msestring;
                                                        var handled: boolean);
   procedure doeditchardelete(const sender:tassistivehandler;
                const aintf: iassistiveclientedit; const achar: msestring;
                                                        var handled: boolean);
   procedure doeditindexmoved(const sender:tassistivehandler;
                   const aintf: iassistiveclientedit; const aindex: int32;
                                                        var handled: boolean);
   procedure doeditwithdrawn(const sender:tassistivehandler;
                     const aintf: iassistiveclientedit; var handled: boolean);
   procedure doedittextblock(const sender:tassistivehandler;
                     const aintf: iassistiveclientedit;
                     const amode: edittextblockmodety; const atext: msestring;
                                                         var handled: boolean);
   procedure doeditinputmodeset(const sender:tassistivehandler;
              const aintf: iassistiveclientedit; const amode: editinputmodety;
                                                         var handled: boolean);
   procedure donavigbordertouched(const sender:tassistivehandler;
                                         const aintf: iassistiveclient;
                                         const adirection: graphicdirectionty;
                                                         var handled: boolean);
   procedure dodatasetevent(const sender:tassistivehandler;
           const aintf: iassistiveclient; const akind: assistivedbeventkindty;
                                const adataset: tdataset; var handled: boolean);
   function getcaption(const sender: tassistivehandler;
                          const aintf: iassistiveclient): msestring;
   function gettext(const sender: tassistivehandler;
                          const aintf: iassistiveclient): msestring;
   function gethint(const sender: tassistivehandler;
                          const aintf: iassistiveclient): msestring;
  public
   destructor destroy(); override;
  published
   property handler: tassistivehandler read fhandler write sethandler;
   property widget: twidget read fwidget write setwidget;
   property caption: msestring read fcaption write fcaption;
   property text: msestring read ftext write ftext;
   property hint: msestring read fhint write fhint;
   property onwindowactivated: assistiveeventty read fonwindowactivated 
                                                    write fonwindowactivated;
   property onwindowdeactivated: assistiveeventty read fonwindowdeactivated
                                                    write fonwindowdeactivated;
   property onwindowclosed: assistiveeventty read fonwindowclosed
                                                      write fonwindowclosed;
   property onenter: assistiveeventty read fonenter write fonenter;
   property onactivate: assistiveeventty read fonactivate write fonactivate;
   property onclientmouseevent: assistivemouseeventty read fonclientmouseevent
                                                      write fonclientmouseevent;
   property onkeydown: assistivekeyeventty read fonkeydown write fonkeydown;
   property onchange: assistiveeventty read fonchange write fonchange;
   property ondataentered: assistivedataeventty read fondataentered 
                                                        write fondataentered;
   property ondbvaluechanged: assistivedataeventty read fondbvaluechanged 
                                                        write fondbvaluechanged;
   property oncellevent: assistivecelleventty read foncellevent
                                                        write foncellevent;
   property ongridbordertouched: assistivedirectiongrideventty
                read fongridbordertouched write fongridbordertouched;
   property oneditcharenter: assistiveeditstringeventty read foneditcharenter
                                         write foneditcharenter;
   property oneditchardelete: assistiveeditstringeventty read foneditchardelete
                                                       write foneditchardelete;
   property oneditwithdrawn: assistiveediteventty read foneditwithdrawn
                                                        write foneditwithdrawn;
   property oneditindexmoved: assistiveeditindexeventty read foneditindexmoved
                                                       write foneditindexmoved;
   property oneditinputmodeset: assistiveeditinputmodeeventty
                         read foneditinputmodeset write foneditinputmodeset;
   property onedittextblock: assistiveedittextblockeventty
                                  read fonedittextblock write fonedittextblock;
   property onnavigbordertouched: assistivedirectioneventty
                read fonnavigbordertouched write fonnavigbordertouched;
   property ondatasetevent: assistivedataseteventty
                        read fondatasetevent write fondatasetevent;
   property ongetcaption: assistivestringeventty read fongetcaption 
                                                       write fongetcaption;
   property ongettext: assistivestringeventty read fongettext
                                                       write fongettext;
   property ongethint: assistivestringeventty read fongethint
                                                       write fongethint;
 end;

 assistivewidgetdataty = record
  item: tassistivewidgetitem;
 end;
 
 assistivewidgethashdataty = record
  header: pointerhashdataty; //datapointer = interface
  data: assistivewidgetdataty;
 end;
 passistivewidgethashdataty = ^assistivewidgethashdataty;
 
 tassistivewidgetitemlist = class(tpointerhashdatalist)
  protected
   function getrecordsize(): int32 override;   
 end;

 assistiveservereventty = 
  procedure(const sender:tassistivehandler; var handled: boolean) of object;
 assistiveserverclienteventty = 
  procedure(const sender:tassistivehandler;
                 const intf: iassistiveclient; var handled: boolean) of object;
 assistiveserverkeyeventty = 
  procedure(const sender:tassistivehandler;
                 const intf: iassistiveclient; const info: keyeventinfoty;
                                               var handled: boolean) of object;
 assistiveservermouseeventty = 
  procedure(const sender:tassistivehandler;
                 const intf: iassistiveclient; const info: mouseeventinfoty;
                                               var handled: boolean) of object;
 assistiveserverdataeventty = 
  procedure(const sender:tassistivehandler;
             const intf: iassistiveclientdata; var handled: boolean) of object;
 assistiveservercelleventty = 
  procedure(const sender:tassistivehandler;
                 const intf: iassistiveclientgrid; const info: celleventinfoty;
                                               var handled: boolean) of object;
 assistiveservereditstringeventty = 
  procedure(const sender:tassistivehandler;
            const intf: iassistiveclientedit; const achar: msestring;
                                               var handled: boolean) of object;
 assistiveserverediteventty = 
  procedure(const sender:tassistivehandler;
              const intf: iassistiveclientedit; var handled: boolean) of object;
 assistiveservereditindexeventty = 
  procedure(const sender:tassistivehandler;
                        const intf: iassistiveclientedit; const index: int32; 
                                               var handled: boolean) of object;
 assistiveservereditinputmodeeventty = 
  procedure(const sender:tassistivehandler;
                 const intf: iassistiveclientedit; const amode: editinputmodety;
                                               var handled: boolean) of object;
 assistiveserveredittextblockeventty = 
  procedure(const sender:tassistivehandler;
              const intf: iassistiveclientedit;
                 const amode: edittextblockmodety; const atext: msestring;
                                               var handled: boolean) of object;
 assistiveserverdirectioneventty = 
  procedure(const sender:tassistivehandler;
                            const intf: iassistiveclient;
                                     const adirection: graphicdirectionty;
                                                var handled: boolean) of object;
 assistiveservergriddirectioneventty = 
  procedure(const sender:tassistivehandler;
                            const intf: iassistiveclientgrid;
                                     const adirection: graphicdirectionty;
                                                var handled: boolean) of object;

 assistiveserverfocuschangedeventty = 
  procedure(const sender:tassistivehandler;
                 const oldwidget,newwidget: iassistiveclient;
                 var handled: boolean) of object;
 assistiveserveractioneventty = 
   procedure (const sender: tassistivehandler;
                 const intf: iassistiveclient; //intf can be nil
                 const actionobj: tobject; const info: actioninfoty;
                                                var handled: boolean) of object;
 assistiveserveritemeventty = 
   procedure (const sender:tassistivehandler;
                 const intf: iassistiveclient; //intf can be nil
                   const items: shapeinfoarty; const aindex: integer;
                                                var handled: boolean) of object;
 assistiveservermenueventty = 
   procedure (const sender:tassistivehandler;
               const intf: iassistiveclientmenu;
                                    var handled: boolean) of object;
 assistiveservermenuitemeventty = 
   procedure (const sender:tassistivehandler;
               const intf: iassistiveclientmenu;//intf can be nil
                const items: menucellinfoarty; const aindex: integer;
                                                var handled: boolean) of object;
 assistiveserverdataseteventty = 
  procedure(const handler: tassistivehandler; const intf: iassistiveclient;
                const akind: assistivedbeventkindty; const adataset: tdataset;
                                                var handled: boolean) of object;
 speakoptionty = (spo_addtext,spo_hint,spo_parent,spo_path);
 speakoptionsty = set of speakoptionty;
 
 tassistivehandler = class(tmsecomponent,iassistiveserver)
  private
   factive: boolean;
   fspeaker: tassistivespeak;
   fvoicecaption: int32;
   fvoicetext: int32;
   fonwindowactivated: assistiveserverclienteventty;
   fonwindowdeactivated: assistiveserverclienteventty;
   fonwindowclosed: assistiveserverclienteventty;
   fonenter: assistiveserverclienteventty;
   fonactivate: assistiveserverclienteventty;
   fonclientmouseevent: assistiveservermouseeventty;
   fonfocuschanged: assistiveserverfocuschangedeventty;
   fonkeydown: assistiveserverkeyeventty;
   fonchange: assistiveserverclienteventty;
   fondataentered: assistiveserverdataeventty;
   foncellevent: assistiveservercelleventty;
   foneditcharenter: assistiveservereditstringeventty;
   foneditchardelete: assistiveservereditstringeventty;
   foneditwithdrawn: assistiveserverediteventty;
   foneditindexmoved: assistiveservereditindexeventty;
   foneditinputmodeset: assistiveservereditinputmodeeventty;
   fonedittextblock: assistiveserveredittextblockeventty;
   fonnavigbordertouched: assistiveserverdirectioneventty;
   fonitementer: assistiveserveritemeventty;
   fonmenuitementer: assistiveservermenuitemeventty;
   fonactionexecute: assistiveserveractioneventty;
   foptions: assistiveoptionsty;
   fonapplicationactivated: assistiveservereventty;
   fonapplicationdeactivated: assistiveservereventty;
   fonmenuactivated: assistiveservermenueventty;
   fondbvaluechanged: assistiveserverdataeventty;
   fondatasetevent: assistiveserverdataseteventty;
   fongridbordertouched: assistiveservergriddirectioneventty;
   fvoicetextedit: int32;
   procedure setactive(const avalue: boolean);
   procedure setspeaker(const avalue: tassistivespeak);
   procedure setoptions(const avalue: assistiveoptionsty);
  protected
   fstate: assistivehandlerstatesty;
   fspeaklock: int32;
   fdataenteredkeyserial: card32;
   fitems: tassistivewidgetitemlist;
  {$ifdef mse_debugassistive}
   procedure debug(const text: string;
                                      const intf: iassistiveclient);
  {$endif}
   procedure activate();
   procedure deactivate();

   procedure loaded() override;

   procedure startspeak();
   
   procedure registeritem(const aintf: iassistiveclient;
                             const aitem: tassistivewidgetitem);
   procedure unregisteritem(const aintf: iassistiveclient);
   function finditem(aintf: iassistiveclient;
                        out aitem: tassistivewidgetitem): boolean;
   procedure doshortcut(const sender: twidget; var info: keyeventinfoty);
   procedure dospeakagain(const sender: twidget);
   procedure dospeakpath(const sender: twidget);
   procedure checklocatepending(const sender: iassistiveclient);
      
    //iassistiveserver
   procedure doapplicationactivated();
   procedure doapplicationdeactivated();
   procedure dowindowactivated(const sender: iassistiveclient);
   procedure dowindowdeactivated(const sender: iassistiveclient);
   procedure dowindowclosed(const sender: iassistiveclient);
   procedure doenter(const sender: iassistiveclient);
   procedure doactivate(const sender: iassistiveclient);
   procedure doclientmouseevent(const sender: iassistiveclient;
                                           const info: mouseeventinfoty);
   procedure dokeydown(const sender: iassistiveclient;
                                         const info: keyeventinfoty);
   procedure dochange(const sender: iassistiveclient);
   procedure dodataentered(const sender: iassistiveclientdata);
   procedure dodbvaluechanged(const sender: iassistiveclientdata);
   procedure docellevent(const sender: iassistiveclientgrid; 
                                       const info: celleventinfoty);
   procedure dogridbordertouched(const sender: iassistiveclientgrid;
                                       const adirection: graphicdirectionty);

   procedure doeditcharenter(const sender: iassistiveclientedit;
                                                const achar: msestring);
   procedure doeditchardelete(const sender: iassistiveclientedit;
                                                const achar: msestring);
   procedure doeditindexmoved(const sender: iassistiveclientedit;
                                                const aindex: int32);
   procedure doeditwithdrawn(const sender: iassistiveclientedit);
   procedure doedittextblock(const sender: iassistiveclientedit;
                     const amode: edittextblockmodety; const atext: msestring);
   procedure doeditinputmodeset(const sender: iassistiveclientedit;
                                                const amode: editinputmodety);
   procedure donavigbordertouched(const sender: iassistiveclient;
                                       const adirection: graphicdirectionty);
   procedure dofocuschanged(const sender: iassistiveclient;
                                const oldwidget,newwidget: iassistiveclient);
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
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   procedure setstate(const astate: assistivehandlerstatesty);
   procedure resetstate(const astate: assistivehandlerstatesty);
   procedure speakstop(const acancel: boolean = false);
   procedure speakcontinue();
   procedure wait();
   procedure cancel();
   procedure speaktext(const atext: msestring; const avoice: int32 = 0;
                                                const nocut: boolean = false);
   procedure speaktext(const atext: stockcaptionty; const avoice: int32 = 0;
                                                const nocut: boolean = false);
   procedure speakcharacter(const achar: char32; const avoice: int32 = 0;
                                                const nocut: boolean = false);
   procedure speakall(const sender: iassistiveclient; aoptions: speakoptionsty);
   procedure speakgridcell(const sender: iassistiveclientgrid;
                  const acell: gridcoordty; const acaption: boolean);
   procedure speakinput(const sender: iassistiveclientdata);
   procedure speakmenustart(const sender: iassistiveclient);
   procedure speakallmenu(const sender: iassistiveclientmenu;
                                               const ahint: boolean);
   function getcaptiontext(const acaption: msestring): msestring;
   function getcaptiontext(const sender: iassistiveclient): msestring;
   function gettexttext(const sender: iassistiveclient): msestring;
   function gethinttext(const sender: iassistiveclient): msestring;
   property state: assistivehandlerstatesty read fstate;
  published
   property active: boolean read factive write setactive default false;
   property options: assistiveoptionsty read foptions 
                             write setoptions default defaultassistiveoptions;
   property speaker: tassistivespeak read fspeaker write setspeaker;
   property voicecaption: int32 read fvoicecaption 
                                          write fvoicecaption default 0;
   property voicetext: int32 read fvoicetext 
                                          write fvoicetext default 0;
   property voicetextedit: int32 read fvoicetextedit
                                          write fvoicetextedit default 0;
   property onapplicationactivated: assistiveservereventty 
                 read fonapplicationactivated write fonapplicationactivated;
   property onapplicationdeactivated: assistiveservereventty
                read fonapplicationdeactivated write fonapplicationdeactivated;
   property onwindowactivated: assistiveserverclienteventty
                     read fonwindowactivated write fonwindowactivated;
   property onwindowdeactivated: assistiveserverclienteventty
                         read fonwindowdeactivated write fonwindowdeactivated;
   property onwindowclosed: assistiveserverclienteventty read fonwindowclosed
                                                      write fonwindowclosed;
   property onenter: assistiveserverclienteventty read fonenter write fonenter;
   property onactivate: assistiveserverclienteventty read fonactivate 
                                                        write fonactivate;
   property onclientmouseevent: assistiveservermouseeventty 
                      read fonclientmouseevent write fonclientmouseevent;
   property onfocuschanged: assistiveserverfocuschangedeventty 
                           read fonfocuschanged write fonfocuschanged;
   property onkeydown: assistiveserverkeyeventty read fonkeydown
                                                      write fonkeydown;
   property onchange: assistiveserverclienteventty read fonchange 
                                                         write fonchange;
   property ondataentered: assistiveserverdataeventty read fondataentered 
                                                        write fondataentered;
   property ondbvaluechanged: assistiveserverdataeventty read fondbvaluechanged 
                                                        write fondbvaluechanged;
   property oncellevent: assistiveservercelleventty read foncellevent
                                                        write foncellevent;
   property ongridbordertouched: assistiveservergriddirectioneventty
                        read fongridbordertouched write fongridbordertouched;
   property oneditcharenter: assistiveservereditstringeventty
                            read foneditcharenter write foneditcharenter;
   property oneditchardelete: assistiveservereditstringeventty 
                               read foneditchardelete write foneditchardelete;
   property oneditwithdrawn: assistiveserverediteventty read foneditwithdrawn
                                                        write foneditwithdrawn;
   property oneditindexmoved: assistiveservereditindexeventty
                               read foneditindexmoved write foneditindexmoved;
   property oneditinputmodeset: assistiveservereditinputmodeeventty
                         read foneditinputmodeset write foneditinputmodeset;
   property onedittextblock: assistiveserveredittextblockeventty
                                  read fonedittextblock write fonedittextblock;
   property onnavigbordertouched: assistiveserverdirectioneventty
                read fonnavigbordertouched write fonnavigbordertouched;
   property onactionexecute: assistiveserveractioneventty read fonactionexecute
                                                         write fonactionexecute;
   property onitementer: assistiveserveritemeventty read fonitementer 
                                                            write fonitementer;
   property onmenuactivated: assistiveservermenueventty
                        read fonmenuactivated write fonmenuactivated;
   property onmenuitementer: assistiveservermenuitemeventty
                        read fonmenuitementer write fonmenuitementer;
   property ondatasetevent: assistiveserverdataseteventty
                        read fondatasetevent write fondatasetevent;
 end;
 
implementation
uses
 msekeyboard,sysutils,msesysutils,mserichstring,msemenus,mseactions,
 msegridsglob,mseeditglob,typinfo;
 
type
 twidget1 = class(twidget);
 tpopupmenuwidget1 = class(tpopupmenuwidget);
 tmenuitem1 = class(tmenuitem);
 
{ tassistivespeak }

constructor tassistivespeak.create(aowner: tcomponent);
begin
 inherited;
 setsubcomponent(true);
end;

{ tassistivewidgetitem }

destructor tassistivewidgetitem.destroy();
begin
 handler:= nil;
 inherited;
end;

procedure tassistivewidgetitem.sethandler(const avalue:tassistivehandler);
begin
 unlinkhandler();
 setlinkedvar(avalue,tmsecomponent(fhandler));
 linkhandler();
end;

procedure tassistivewidgetitem.setwidget(const avalue: twidget);
begin
 unlinkhandler();
 setlinkedvar(avalue,tmsecomponent(fwidget));
 linkhandler();
end;

procedure tassistivewidgetitem.linkhandler();
begin
 if (fwidget <> nil) and (fhandler <> nil) and 
            not (csdesigning in componentstate) then begin
  fhandler.registeritem(twidget1(fwidget).getiassistiveclient,self);
 end;
end;

procedure tassistivewidgetitem.unlinkhandler();
begin
 if (fhandler <> nil) and (fwidget <> nil) and 
                               not (csdesigning in componentstate) then begin
  fhandler.unregisteritem(twidget1(fwidget).getiassistiveclient());
 end;
end;

procedure tassistivewidgetitem.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (event = oe_destroyed) and (sender = fwidget) then begin
  unlinkhandler();
 end;
 inherited;
end;

procedure tassistivewidgetitem.dowindowactivated(const sender:tassistivehandler;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonwindowactivated)) then begin
  fonwindowactivated(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dowindowdeactivated(
              const sender:tassistivehandler; const aintf: iassistiveclient;
               var handled: boolean);
begin
 if canevent(tmethod(fonwindowdeactivated)) then begin
  fonwindowdeactivated(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dowindowclosed(const sender:tassistivehandler;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonwindowclosed)) then begin
  fonwindowclosed(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doenter(const sender:tassistivehandler;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonenter)) then begin
  fonenter(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doactivate(const sender:tassistivehandler;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonactivate)) then begin
  fonactivate(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doclientmouseevent(
              const sender:tassistivehandler; const aintf: iassistiveclient;
               const info: mouseeventinfoty; var handled: boolean);
begin
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,sender,aintf,info,handled);
 end;
end;

procedure tassistivewidgetitem.dokeydown(const sender:tassistivehandler;
               const aintf: iassistiveclient; const info: keyeventinfoty;
               var handled: boolean);
begin
 if canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,sender,aintf,info,handled);
 end;
end;

procedure tassistivewidgetitem.dochange(const sender:tassistivehandler;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonchange)) then begin
  fonchange(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dodbvaluechanged(const sender: tassistivehandler;
               const aintf: iassistiveclientdata; var handled: boolean);
begin
 if canevent(tmethod(fondbvaluechanged)) then begin
  fondbvaluechanged(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dodataentered(const sender:tassistivehandler;
               const aintf: iassistiveclientdata; var handled: boolean);
begin
 if canevent(tmethod(fondataentered)) then begin
  fondataentered(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.docellevent(const sender:tassistivehandler;
               const aintf: iassistiveclientgrid; const info: celleventinfoty;
               var handled: boolean);
begin
 if canevent(tmethod(foncellevent)) then begin
  foncellevent(self,sender,aintf,info,handled);
 end;
end;

procedure tassistivewidgetitem.dogridbordertouched(
              const sender: tassistivehandler;
               const aintf: iassistiveclientgrid;
               const adirection: graphicdirectionty; var handled: boolean);
begin
 if canevent(tmethod(fongridbordertouched)) then begin
  fongridbordertouched(self,sender,aintf,adirection,handled);
 end;
end;

procedure tassistivewidgetitem.doeditcharenter(const sender:tassistivehandler;
               const aintf: iassistiveclientedit; const achar: msestring;
               var handled: boolean);
begin
 if canevent(tmethod(foneditcharenter)) then begin
  foneditcharenter(self,sender,aintf,achar,handled);
 end;
end;

procedure tassistivewidgetitem.doeditchardelete(const sender:tassistivehandler;
               const aintf: iassistiveclientedit; const achar: msestring;
               var handled: boolean);
begin
 if canevent(tmethod(foneditchardelete)) then begin
  foneditchardelete(self,sender,aintf,achar,handled);
 end;
end;

procedure tassistivewidgetitem.doeditindexmoved(const sender:tassistivehandler;
               const aintf: iassistiveclientedit; const aindex: int32;
               var handled: boolean);
begin
 if canevent(tmethod(foneditindexmoved)) then begin
  foneditindexmoved(self,sender,aintf,aindex,handled);
 end;
end;

procedure tassistivewidgetitem.doeditwithdrawn(const sender:tassistivehandler;
               const aintf: iassistiveclientedit; var handled: boolean);
begin
 if canevent(tmethod(foneditwithdrawn)) then begin
  foneditwithdrawn(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doedittextblock(const sender:tassistivehandler;
               const aintf: iassistiveclientedit;
               const amode: edittextblockmodety; const atext: msestring;
               var handled: boolean);
begin
 if canevent(tmethod(fonedittextblock)) then begin
  fonedittextblock(self,sender,aintf,amode,atext,handled);
 end;
end;

procedure tassistivewidgetitem.doeditinputmodeset(
              const sender:tassistivehandler; const aintf: iassistiveclientedit;
               const amode: editinputmodety; var handled: boolean);
begin
 if canevent(tmethod(foneditinputmodeset)) then begin
  foneditinputmodeset(self,sender,aintf,amode,handled);
 end;
end;

procedure tassistivewidgetitem.donavigbordertouched(
              const sender:tassistivehandler; const aintf: iassistiveclient;
               const adirection: graphicdirectionty; var handled: boolean);
begin
 if canevent(tmethod(fonnavigbordertouched)) then begin
  fonnavigbordertouched(self,sender,aintf,adirection,handled);
 end;
end;

procedure tassistivewidgetitem.dodatasetevent(const sender: tassistivehandler;
               const aintf: iassistiveclient;
               const akind: assistivedbeventkindty; const adataset: tdataset;
               var handled: boolean);
begin
 if canevent(tmethod(fondatasetevent)) then begin
  fondatasetevent(self,sender,aintf,akind,adataset,handled);
 end;
end;

function tassistivewidgetitem.getcaption(const sender: tassistivehandler;
               const aintf: iassistiveclient): msestring;
begin
 result:= fcaption;
 if canevent(tmethod(fongetcaption)) then begin
  fongetcaption(self,sender,aintf,result);
 end;
end;

function tassistivewidgetitem.gettext(const sender: tassistivehandler;
               const aintf: iassistiveclient): msestring;
begin
 result:= ftext;
 if canevent(tmethod(fongettext)) then begin
  fongettext(self,sender,aintf,result);
 end;
end;

function tassistivewidgetitem.gethint(const sender: tassistivehandler;
               const aintf: iassistiveclient): msestring;
begin
 result:= fhint;
 if canevent(tmethod(fongethint)) then begin
  fongethint(self,sender,aintf,result);
 end;
end;

{ tassistivewidgetitemlist }

function tassistivewidgetitemlist.getrecordsize(): int32;
begin
 result:= sizeof(assistivewidgethashdataty);
end;

{tassistivehandler }

constructor tassistivehandler.create(aowner: tcomponent);
begin
 foptions:= defaultassistiveoptions;
 fspeaker:= tassistivespeak.create(nil);
 fitems:= tassistivewidgetitemlist.create();
 inherited;
end;

destructor tassistivehandler.destroy();
begin
 inherited;
 fspeaker.free();
 fitems.free();
end;

procedure tassistivehandler.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  factive:= avalue;
  if not (csloading in componentstate) then begin
   if avalue then begin
    activate();
   end
   else begin
    deactivate();
   end;
  end;
 end;
end;

procedure tassistivehandler.activate();
begin
 if not (csdesigning in componentstate) then begin
  fspeaklock:= 0;
  application.registeronshortcut(@doshortcut);
  fspeaker.active:= true;
  assistiveserver:= iassistiveserver(self);
  assistiveoptions:= options;
  fstate:= [ahs_active];
//  include(fstate,ahs_active);
  application.invalidate();
 end;
end;

procedure tassistivehandler.deactivate();
begin
 if not (csdesigning in componentstate) then begin
  application.unregisteronshortcut(@doshortcut);
  assistiveserver:= nil;
  assistiveoptions:= [];
  fspeaker.active:= false;
  exclude(fstate,ahs_active);
  application.invalidate();
 end;
end;

procedure tassistivehandler.setspeaker(const avalue: tassistivespeak);
begin
 fspeaker.assign(avalue);
end;

procedure tassistivehandler.setoptions(const avalue: assistiveoptionsty);
begin
 foptions:= avalue;
 if ahs_active in fstate then begin
  assistiveoptions:= foptions;
 end;
end;

procedure tassistivehandler.loaded();
begin
 inherited;
 if factive then begin
  factive:= false;
  active:= true;
 end;
end;

procedure tassistivehandler.wait();
begin
 fspeaker.wait();
end;

procedure tassistivehandler.cancel();
begin
 if (fspeaklock <= 0) then begin
  if not (ahs_nocut in fstate) then begin
   fspeaker.cancel();
  end;
  exclude(fstate,ahs_nocut);
 end;
end;

function tassistivehandler.getcaptiontext(const acaption: msestring): msestring;
var
 capt1: richstringty;
begin
 captiontorichstring(acaption,capt1);
 result:= capt1.text;
end;

function tassistivehandler.getcaptiontext(
                                 const sender: iassistiveclient): msestring;
var
 item1: tassistivewidgetitem;
begin
 result:= '';
 if finditem(sender,item1) then begin
  result:= item1.getcaption(self,sender);
 end;
 if result = '' then begin
  result:= getcaptiontext(sender.getassistivecaption());
 end;
end;

function tassistivehandler.gettexttext(
              const sender: iassistiveclient): msestring;
var
 item1: tassistivewidgetitem;
begin
 result:= '';
 if finditem(sender,item1) then begin
  result:= item1.gettext(self,sender);
 end;
 if result = '' then begin
  result:= sender.getassistivetext();
 end;
end;

function tassistivehandler.gethinttext(
              const sender: iassistiveclient): msestring;
var
 item1: tassistivewidgetitem;
begin
 result:= '';
 if finditem(sender,item1) then begin
  result:= item1.gethint(self,sender);
 end;
 if result = '' then begin
  result:= sender.getassistivehint();
 end;
end;

procedure tassistivehandler.speaktext(const atext: msestring;
               const avoice: int32 = 0; const nocut: boolean = false);
begin
 if fspeaklock <= 0 then begin
  if nocut then begin
   include(fstate,ahs_nocut);
  end;
  fspeaker.speak(atext,[so_endpause],avoice);
 end;
end;

procedure tassistivehandler.speaktext(const atext: stockcaptionty;
               const avoice: int32 = 0; const nocut: boolean = false);
begin
 speaktext(stockobjects.captions[atext],avoice,nocut);
end;

procedure tassistivehandler.speakcharacter(const achar: char32;
               const avoice: int32 = 0; const nocut: boolean = false);
begin
 if fspeaklock <= 0 then begin
  if nocut then begin
   include(fstate,ahs_nocut);
  end;
  fspeaker.speakcharacter(achar,[so_endpause],avoice);
 end;
end;

procedure tassistivehandler.speakall(const sender: iassistiveclient;
                                                   aoptions: speakoptionsty);
var
 fla1: assistiveflagsty;
 s1: msestring;
 w1: tpopupmenuwidget1;
 intf2: iassistiveclient;
 i1: int32;
begin
 intf2:= sender.getassistiveparent();
 if spo_path in aoptions then begin
  exclude(aoptions,spo_parent);
  if intf2 <> nil then begin
   speakall(intf2,aoptions);
   include(aoptions,spo_addtext);
   intf2:= nil;
  end;
 end
 else begin
  if not (spo_parent in aoptions) then begin
   intf2:= nil;
  end;
 end; 
 fla1:= sender.getassistiveflags();
 i1:= fvoicetext;
 if [asf_inplaceedit,asf_textedit] * fla1 <> [] then begin
  i1:= fvoicetextedit;
 end;
 pointer(w1):= sender.getinstance();
 if not (spo_addtext in aoptions) then begin
  startspeak();
 end;
 s1:= '';
 if asf_menu in fla1 then begin
  if w1 is tpopupmenuwidget then begin
   speakallmenu(tmenuitem1(w1.flayout.menu).getiassistiveclient(),
                                                   spo_hint in aoptions);
   exit;
  end; 
 end;
 if (intf2 <> nil) and (asf_message in intf2.getassistiveflags()) then begin
  speakall(intf2,aoptions - [spo_addtext,spo_parent]);
 end;
 if fla1 * [asf_grid,asf_popup] = [asf_grid,asf_popup] then begin
  if spo_parent in aoptions then begin
   speaktext(sc_selection,fvoicecaption);
  end;
  with iassistiveclientgrid(sender) do begin
   speaktext(getassistivecellcaption(getassistivefocusedcell()),fvoicecaption);
   speaktext(getassistivecelltext(getassistivefocusedcell()),i1);
  end;
  exit;
 end;
 if asf_button in fla1 then begin
  if asf_disabled in fla1 then begin
   s1:= stockobjects.captions[sc_disabledbutton] + ' ';
  end
  else begin
   s1:= stockobjects.captions[sc_button] + ' ';
  end;
 end;
 s1:= s1 + getcaptiontext(sender);
 speaktext(s1,fvoicecaption);
 speaktext(gettexttext(sender),i1);
 if spo_hint in aoptions then begin
  speaktext(gethinttext(sender),fvoicecaption);
 end;
end;

procedure tassistivehandler.speakgridcell(const sender: iassistiveclientgrid;
               const acell: gridcoordty; const acaption: boolean);
begin
 if acaption then begin
  speaktext(sender.getassistivecellcaption(
                            mgc(acell.col,-1)),fvoicecaption);
 end;
 speaktext(sender.getassistivecelltext(acell),fvoicetext);
end;

procedure tassistivehandler.speakinput(const sender: iassistiveclientdata);
begin
 startspeak();
 speaktext(sc_input,fvoicecaption);
 speaktext(getcaptiontext(iassistiveclient(sender)),fvoicecaption);
 speaktext(gettexttext(sender),fvoicetextedit);
end;

procedure tassistivehandler.speakmenustart(const sender: iassistiveclient);
begin
 speaktext(sc_menu,fvoicecaption);
end;

procedure tassistivehandler.setstate(const astate: assistivehandlerstatesty);
begin
 fstate:= fstate + (astate-internalstates);
end;

procedure tassistivehandler.resetstate(const astate: assistivehandlerstatesty);
begin
 fstate:= fstate - (astate-internalstates);
end;

procedure tassistivehandler.speakstop(const acancel: boolean = false);
begin
 if acancel then begin
  cancel;
 end;
 inc(fspeaklock);
end;

procedure tassistivehandler.speakcontinue();
begin
 dec(fspeaklock);
end;

procedure tassistivehandler.startspeak();
begin
 cancel();
end;

procedure tassistivehandler.registeritem(const aintf: iassistiveclient;
                     const aitem: tassistivewidgetitem);
begin
 with passistivewidgethashdataty(fitems.add(aintf))^ do begin
  data.item:= aitem;
 end;
end;

procedure tassistivehandler.unregisteritem(const aintf: iassistiveclient);
begin
 fitems.delete(aintf,true);
end;

function tassistivehandler.finditem(aintf: iassistiveclient;
               out aitem: tassistivewidgetitem): boolean;
var
 p1: passistivewidgethashdataty;
begin
 result:= false;
 aitem:= nil;
 p1:= pointer(fitems.find(aintf));
 if p1 <> nil then begin
  aitem:= p1^ .data.item;
  result:= true;
 end;
end;

procedure tassistivehandler.doshortcut(const sender: twidget;
               var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  if checkactionshortcut(assistiveshortcuts[shoa_speakagain],info) then begin
   dospeakagain(sender);
  end
  else begin
   if not (es_processed in info.eventstate) then begin
    if checkactionshortcut(assistiveshortcuts1[shoa_speakagain],info) then begin
     dospeakagain(sender);
    end
    else begin
     if not (es_processed in info.eventstate) then begin
      if checkactionshortcut(assistiveshortcuts[shoa_speakpath],info) then begin
       dospeakpath(sender);
      end
      else begin
       if not (es_processed in info.eventstate) then begin
        if checkactionshortcut(
                assistiveshortcuts1[shoa_speakpath],info) then begin
         dospeakpath(sender);
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tassistivehandler.dospeakagain(const sender: twidget);
begin
 speakall(twidget1(sender).getiassistiveclient(),[spo_hint,spo_parent]);
end;

procedure tassistivehandler.dospeakpath(const sender: twidget);
begin
 speakall(twidget1(sender).getiassistiveclient(),[spo_hint,spo_path]);
end;

procedure tassistivehandler.checklocatepending(const sender: iassistiveclient);
begin
 if asf_hasdropdown in sender.getassistiveflags then begin
  setstate([ahs_locatepending]);
 end;
end;

{$ifdef mse_debugassistive}
procedure tassistivehandler.debug(const text: string;
                                      const intf: iassistiveclient);
var
 wi1: twidget;
begin
 debugwrite('*'+text+settostring(ptypeinfo(typeinfo(assistivehandlerstatesty)),
                                                       int32(fstate),true)+':');
 if intf <> nil then begin
  pointer(wi1):= intf.getassistivewidget();
  if wi1 <> nil then begin
   debugwrite(wi1.name);
  end
  else begin
   debugwrite('NIL');
  end;
 end;
 debugwriteln('');
end;
{$endif}

procedure tassistivehandler.doapplicationactivated();
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('applicationactivated',nil);
{$endif}
 b1:= false;
 if canevent(tmethod(fonapplicationactivated)) then begin
  fonapplicationactivated(self,b1);
 end;
end;

procedure tassistivehandler.doapplicationdeactivated();
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('applicationdeactivated',nil);
{$endif}
 b1:= false;
 if canevent(tmethod(fonapplicationdeactivated)) then begin
  fonapplicationdeactivated(self,b1);
 end;
 if not b1 then begin
  cancel();
 end;
end;

procedure tassistivehandler.dowindowactivated(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 fla1: assistiveflagsty;
begin
{$ifdef mse_debugassistive}
 debug('windowactivated',sender);
{$endif}
 setstate([ahs_windowactivated]);
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dowindowactivated(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonwindowactivated)) then begin
   fonwindowactivated(self,sender,b1);
  end;
  if not b1 then begin
   fla1:= sender.getassistiveflags();
   if asf_menu in fla1 then begin
   {
    setstate([ass_menuactivated]);
    if not (ass_menuactivatepending in fstate) then begin
     startspeak();
     speakmenustart(sender);
    end;
   }
   end
   else begin
    if fstate*[ahs_dropdownlistclosed,ahs_dropdownpending] = [] then begin
     startspeak();
  //   speaktext(sc_windowactivated,fvoicecaption);
     speaktext(getcaptiontext(sender),fvoicecaption);
     speaktext(gettexttext(sender),fvoicetext);
    end;
   end;
  end;
 end;
 resetstate([ahs_menuactivatepending,ahs_dropdownpending]);
end;

procedure tassistivehandler.dowindowdeactivated(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('windowdeactivated',sender);
{$endif}
 if sender.getassistiveflags() * [asf_popup,asf_grid] = 
                                     [asf_popup,asf_grid] then begin
  setstate([ahs_dropdownlistclosed]);
 end;
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dowindowdeactivated(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonwindowdeactivated)) then begin
   fonwindowdeactivated(self,sender,b1);
  end;
  if not b1 then begin
  end;
 end;
 resetstate([ahs_windowactivated]);
end;

procedure tassistivehandler.dowindowclosed(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('windowclosed',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dowindowclosed(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonwindowclosed)) then begin
   fonwindowclosed(self,sender,b1);
  end;
 end;
end;

procedure tassistivehandler.doenter(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('enter',sender);
{$endif}
 resetstate([ahs_dropdownpending]);
 if (ahs_editcharenter in fstate) and 
           (sender.getassistiveflags*[asf_popup,asf_grid] = 
                                  [asf_popup,asf_grid]) then begin
  setstate([ahs_dropdownpending]);
 end;
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doenter(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonenter)) then begin
   fonenter(self,sender,b1);
  end;
 end;
 resetstate([ahs_editcharenter]);
end;

procedure tassistivehandler.doactivate(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 fla1: assistiveflagsty;
 opt1: speakoptionsty;
begin
{$ifdef mse_debugassistive}
 debug('activate',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doactivate(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonactivate)) then begin
   fonactivate(self,sender,b1);
  end;
  if twidget(sender.getassistivewidget).focused then begin
   if not b1 then begin
    fla1:= sender.getassistiveflags();
    if asf_menu in fla1 then begin
    end
    else begin
     if fla1*[asf_grid,asf_popup] = [asf_grid,asf_popup] then begin
      speaktext(sc_selection,fvoicecaption);
      speakgridcell(iassistiveclientgrid(sender),
                   tcustomgrid(sender.getassistivewidget()).focusedcell,true);
     end
     else begin
      if not (ahs_dropdownlistclosed in fstate) then begin
       opt1:= [];
       if ahs_windowactivated in fstate then begin
        opt1:= [spo_addtext]
       end;
       speakall(sender,opt1);
      end;
     end;
    end;
   end;
  end;
 end;
 if asf_focused in sender.getassistiveflags() then begin
  resetstate([ahs_windowactivated,ahs_dropdownlistclosed]);
 end;
end;

procedure tassistivehandler.doclientmouseevent(const sender: iassistiveclient;
               const info: mouseeventinfoty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('clientmouseevent',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doclientmouseevent(self,sender,info,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonclientmouseevent)) then begin
   fonclientmouseevent(self,sender,info,b1);
  end;
 end;
end;

procedure tassistivehandler.dofocuschanged(const sender: iassistiveclient;
         const oldwidget: iassistiveclient; const newwidget: iassistiveclient);
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('focuschanged',sender);
{$endif}
 b1:= false;
 if canevent(tmethod(fonfocuschanged)) then begin
  fonfocuschanged(self,oldwidget,newwidget,b1);
 end;
end;

procedure tassistivehandler.dokeydown(const sender: iassistiveclient;
               const info: keyeventinfoty);
//var
// fla1: assistiveflagsty;
begin
{$ifdef mse_debugassistive}
 debug('keydown',sender);
{$endif}
 if not (es_child in info.eventstate) then begin
 {
  if (info.key = key_return) and 
                (info.shiftstate*keyshiftstatesmask = []) then begin
   if info.serial <> fdataenteredkeyserial then begin
    speakall(sender,false,true);
   end;
  end;
 }
  fdataenteredkeyserial:= 0;
 end;
end;

procedure tassistivehandler.doactionexecute(const sender: iassistiveclient;
                          const senderobj: tobject;  const info: actioninfoty);
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('actionexecute',sender);
{$endif}
 b1:= false;
 if canevent(tmethod(fonactionexecute)) then begin
  fonactionexecute(self,sender,senderobj,info,b1);
 end;
end;

procedure tassistivehandler.dochange(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('change',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dochange(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self,sender,b1);
  end;
 end;
end;

procedure tassistivehandler.dodataentered(const sender: iassistiveclientdata);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('dataentered',sender);
{$endif}
 fdataenteredkeyserial:= 0;
 if application.keyeventinfo <> nil then begin
  fdataenteredkeyserial:= application.keyeventinfo^.serial;
 end;
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doenter(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonenter)) then begin
   fonenter(self,sender,b1);
  end;
  if not b1 then begin
   speakinput(sender);
  end;
 end;
end;

procedure tassistivehandler.dodbvaluechanged(const sender: iassistiveclientdata);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('change',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dodbvaluechanged(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fondbvaluechanged)) then begin
   fondbvaluechanged(self,sender,b1);
  end;
  if not b1 then begin
   startspeak();
   speaktext(gettexttext(sender),fvoicetext);
  end;
 end;
end;

procedure tassistivehandler.docellevent(const sender: iassistiveclientgrid;
               const info: celleventinfoty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 f1: assistiveflagsty;
begin
{$ifdef mse_debugassistive}
 debug('cellevent',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.docellevent(self,sender,info,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foncellevent)) then begin
   foncellevent(self,sender,info,b1);
  end;
  if {not b1 and} twidget(sender.getassistivewidget()).active then begin
   with info do begin
    case eventkind of
     cek_enter: begin
      f1:= sender.getassistiveflags();
      if not b1 and ((cellbefore.col <> cell.col) or 
                         (cellbefore.row <> cell.row)) and 
                                       not (asf_scrolllimit in f1) then begin
       if not (ahs_locatepending in fstate) then begin
        startspeak();
       end;
       speakgridcell(sender,cell,cellbefore.col <> cell.col);
      end;
      resetstate([ahs_locatepending]);
     end;
    end;
   end;
  end;
 end;
end;

procedure tassistivehandler.dogridbordertouched(
              const sender: iassistiveclientgrid;
               const adirection: graphicdirectionty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 ca1: stockcaptionty;
begin
{$ifdef mse_debugassistive}
 debug('gridbordertouched',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dogridbordertouched(self,sender,adirection,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fongridbordertouched)) then begin
   fongridbordertouched(self,sender,adirection,b1);
  end;
  if not b1 and twidget(sender.getassistivewidget()).active then begin
   case adirection of
    gd_left: begin
     ca1:= sc_firstcol;
    end;
    gd_up: begin
     if asf_db in sender.getassistiveflags then begin
      ca1:= sc_bof;
     end
     else begin
      ca1:= sc_firstrow;
     end;
    end;
    gd_right: begin
     ca1:= sc_lastcol;
    end;
    gd_down: begin
     if asf_db in sender.getassistiveflags then begin
      ca1:= sc_eof;
     end
     else begin
      ca1:= sc_lastrow;
     end;
    end;
    else begin
     exit;
    end;
   end;
   startspeak();
   speaktext(ca1,fvoicecaption);
  end;
 end;
end;

procedure tassistivehandler.doeditcharenter(const sender: iassistiveclientedit;
               const achar: msestring);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('editcharenter',sender);
{$endif}
 setstate([ahs_editcharenter]);
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doeditcharenter(self,sender,achar,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foneditcharenter)) then begin
   foneditcharenter(self,sender,achar,b1);
  end;
  if not b1 then begin
   if not (ahs_textblock1 in fstate) then begin
    startspeak();
   end
   else begin
    speaktext(sc_input,fvoicecaption);
   end;
   exclude(fstate,ahs_textblock1);
   if length(achar) = 1 then begin
    speakcharacter(getucs4char(achar,1),fvoicetext);
   end
   else begin
    speaktext(achar,fvoicetext);
   end;
  end;
 end;
 checklocatepending(sender);
end;

procedure tassistivehandler.doeditchardelete(const sender: iassistiveclientedit;
               const achar: msestring);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('editchardelete',sender);
{$endif}
 setstate([ahs_textblock,ahs_editchardelete]);
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dochange(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self,sender,b1);
  end;
 end;
 if not b1 then begin
  startspeak();
  speaktext(sc_deleted,fvoicecaption);
  if length(achar) = 1 then begin
   speakcharacter(getucs4char(achar,1),fvoicetext);
  end
  else begin
   speaktext(achar,fvoicetext);
  end;
 end;
 checklocatepending(sender);
end;

procedure tassistivehandler.doeditindexmoved(const sender: iassistiveclientedit;
               const aindex: int32);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 s1: msestring;
begin
{$ifdef mse_debugassistive}
 debug('editindexmoved',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doeditindexmoved(self,sender,aindex,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foneditindexmoved)) then begin
   foneditindexmoved(self,sender,aindex,b1);
  end;
  if not b1 then begin
   if not (ahs_textblock in fstate) then begin
    startspeak();
   end;
   s1:= sender.getassistivetext();
   if aindex < length(s1) then begin
    if aindex = 0 then begin
     speaktext(sc_beginoftext,fvoicecaption);
    end;
    speakcharacter(getucs4char(s1,aindex+1),fvoicetext);
   end
   else begin
    speaktext(sc_endoftext,fvoicecaption);
   end;
  end;
 end;
 exclude(fstate,ahs_textblock);
end;

procedure tassistivehandler.doeditwithdrawn(const sender: iassistiveclientedit);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('editwithdrawn',sender);
{$endif}
 include(fstate,ahs_textblock);
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doeditwithdrawn(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foneditwithdrawn)) then begin
   foneditwithdrawn(self,sender,b1);
  end;
  if not b1 then begin
   startspeak();
   speaktext(sc_withdrawn,fvoicecaption);
   speaktext(sender.getassistivetext(),fvoicetext);
  end;
 end;
end;

procedure tassistivehandler.doedittextblock(const sender: iassistiveclientedit;
               const amode: edittextblockmodety; const atext: msestring);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 sc1: stockcaptionty;
begin
{$ifdef mse_debugassistive}
 debug('edittextblock',sender);
{$endif}
 fstate:= fstate + [ahs_textblock,ahs_textblock1];
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doedittextblock(self,sender,amode,atext,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonedittextblock)) then begin
   fonedittextblock(self,sender,amode,atext,b1);
  end;
  if not b1 then begin
   case amode of
    etbm_delete: begin
     sc1:= sc_deleted;
    end;
    etbm_cut: begin
     sc1:= sc_cut;
    end;
    etbm_copy: begin
     sc1:= sc_copied;
    end;
    etbm_insert: begin
     sc1:= sc_inserted;
    end;
    etbm_paste: begin
     sc1:= sc_pasted;
    end;
    else begin
     exit;
    end;
   end;
   startspeak();
   speaktext(sc1,fvoicecaption);
   speaktext(atext,fvoicetext);
  end;
 end;
end;

procedure tassistivehandler.doeditinputmodeset(
              const sender: iassistiveclientedit; const amode: editinputmodety);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
{$ifdef mse_debugassistive}
 debug('editinputmodeset',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doeditinputmodeset(self,sender,amode,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foneditinputmodeset)) then begin
   foneditinputmodeset(self,sender,amode,b1);
  end;
  if not b1 then begin
   startspeak();
   speaktext(sc_inputmode,fvoicecaption);
   case amode of
    eim_insert: begin
     speaktext(sc_insert,fvoicetext);
    end;
    eim_overwrite: begin
     speaktext(sc_overwrite,fvoicetext);
    end;
   end;
  end;
 end;
end;

procedure tassistivehandler.donavigbordertouched(const sender: iassistiveclient;
               const adirection: graphicdirectionty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 ca1: stockcaptionty;
begin
{$ifdef mse_debugassistive}
 debug('navigbordertouched',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.donavigbordertouched(self,sender,adirection,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonnavigbordertouched)) then begin
   fonnavigbordertouched(self,sender,adirection,b1);
  end;
  if not b1 then begin
   case adirection of
    gd_left: begin
     ca1:= sc_leftborder;
    end;
    gd_up: begin
     ca1:= sc_topborder;
    end;
    gd_right: begin
     ca1:= sc_rightborder;
    end;
    gd_down: begin
     ca1:= sc_bottomborder;
    end;
    else begin
     exit;
    end;
   end;
   startspeak();
   speaktext(ca1,fvoicecaption);
  end;
 end;
end;

procedure tassistivehandler.doitementer(const sender: iassistiveclient;
               const items: shapeinfoarty; const aindex: integer);
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('shapeitementer',sender);
{$endif}
 b1:= false;
 if canevent(tmethod(fonitementer)) then begin
  fonitementer(self,sender,items,aindex,b1);
 end;
 if not b1 then begin
  //todo
 end;
end;

procedure tassistivehandler.speakallmenu(const sender: iassistiveclientmenu;
                                           const ahint: boolean);
begin
 startspeak();
 speakmenustart(sender);
 speaktext(getcaptiontext(sender.getassistiveselfcaption()),fvoicecaption);
 speaktext(getcaptiontext(sender.getassistivecaption()),fvoicetext);
 if ahint then begin
  speaktext(sender.getassistivehint(),fvoicecaption);
 end;
end;

procedure tassistivehandler.domenuactivated(const sender: iassistiveclientmenu);
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('menuactivated',sender);
{$endif}
 setstate([ahs_menuactivated]);
 b1:= false;
 if canevent(tmethod(fonmenuactivated)) then begin
  fonmenuactivated(self,sender,b1);
 end;
 if not b1 then begin
  speakallmenu(sender,false);
 end;
end;

procedure tassistivehandler.doitementer(const sender: iassistiveclientmenu;
               const items: menucellinfoarty; const aindex: integer);
var
 b1: boolean;
begin
{$ifdef mse_debugassistive}
 debug('menuitementer',sender);
{$endif}
 b1:= false;
 if canevent(tmethod(fonmenuitementer)) then begin
  fonmenuitementer(self,sender,items,aindex,b1);
 end;
 if not b1 then begin
  if not (ahs_menuactivated in fstate) then begin
   startspeak();
   speaktext(getcaptiontext(iassistiveclient(sender)),fvoicetext);
  end;
 end;
 resetstate([ahs_menuactivated]);
end;

procedure tassistivehandler.dodatasetevent(const sender: iassistiveclient;
               const akind: assistivedbeventkindty; const adataset: pointer);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 sc1: stockcaptionty;
begin
{$ifdef mse_debugassistive}
 debug('datasetevent',sender);
{$endif}
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dodatasetevent(self,sender,akind,tdataset(adataset),b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fondatasetevent)) then begin
   fondatasetevent(self,sender,akind,tdataset(adataset),b1);
  end;
  if not b1 then begin
   case akind of 
    adek_bof: begin
     sc1:= sc_bof;
    end;
    adek_eof: begin
     sc1:= sc_eof;
    end;
    else begin
     sc1:= sc_none;
    end;
   end;
   if sc1 <> sc_none then begin
    startspeak();
    speaktext(sc1,fvoicecaption);
   end;
  end;
 end;
end;

end.
